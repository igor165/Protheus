#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TMKA510.CH"

#DEFINE WFTYPE_INFORMATION 		1
#DEFINE WFTYPE_AUTHORIZATION 	2
#DEFINE TK510_DEFAULTS "TMK001/TMK002/TMK003/TMK004/TMK005/TMK006/TMK007/TMK008/TMK009" //Lista de ocorrencias padrao do sistema

// Tabela de Acoes de SLA
// Conforme definicoes obtidas de SU9->U9_ACAOSLA
#Define acaoNEHUMA		'0'
#Define acaoINICIAR		'1'
#Define acaoFINALIZAR	'2'
#Define acaoATUALIZAR	'3'
#Define acaoPAUSAR		'4'

//TK510ATECM - atualiza processo no ECM - numero da tarefa seguinte
#DEFINE NTASKAPR 3 //Prox. Tarefa - Aprovacao
#DEFINE NTASKREP 4 //Prox. Tarefa - Reprovacao

Static aTransfere		:= {}	// 1-Cod. Grupo destino, 2-Cod. Operador
Static lRodizio			:= .F.	// Indica se houve rodizio na selecao do operado
Static cIncMemo			:= ""	// Incidente registrado pelo usuário
Static aSA1Box			:= {}	// Indice do campo de tipo de perfil do cliente
Static cChAnex			:= ""	// Codigo do chamado ao qual o atual esta anexado
Static cFilChAnex		:= ""	// Codigo da filial do chamado ao qual o atual esta anexado
Static aRecSubstitutos	:= {}	// Vetor para controlar os atendentes em recursiva para evitar um LOOPING
Static lCompartilhou	:= .F.	// Identifica se ocorreu um compartilhamento no chamado corrente
Static aRecorrencia		:= {}	// Configuracao da recorrencia do chamado
Static cIncOBS 			:= ""	// Observações do chamado
Static lTransfAuto		:= .F. // controla a transferencia automatica

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMK510FILL    ºAutor  ³Vendas Cliente  º Data ³  22/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gatilho para preencher dados da entidada no atendimento.    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMK510FILL()
Local cEmail:= TkEntidade(M->ADE_ENTIDAD,M->ADE_CHAVE,7)
Local cTel	:= TkEntidade(M->ADE_ENTIDAD,M->ADE_CHAVE,6)
Local cDDD	:= TkEntidade(M->ADE_ENTIDAD,M->ADE_CHAVE,9)

	If Empty(cEmail)
		cEmail := Space(TamSX3("ADE_EMAIL")[1])
	EndIf
    If Empty(cTel)
    	cTel :=  Space(TamSX3("ADE_TELRET")[1])
    EndIf
	If Empty(cDDD)
		cDDD :=  Space(TamSX3("ADE_DDDRET")[1])
	EndIf
	M->ADE_DDDRET := cDDD
	M->ADE_TELRET := cTel
	M->ADE_EMAIL  := cEmail

Return cEmail


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMK510SUBJ    ºAutor  ³Michel W. Mosca º Data ³  21/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta padrao para selecionar o assunto do atendimento.   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMK510SUBJ()
Local oDlgSu9														// Tela
Local oLbx1                                                         // Listbox
Local nPosLbx  := 0                                                 // Posicao do List
Local aItems   := {}                                                // Array com os itens
Local nPos     := 0                                                 // Posicao no array
Local lRet     := .F.                                               // Retorno da funcao
Local cCodSubject := ""		//Codigos de assuntos validos para o atendimento

DbSelectArea("SKK")
DbSetOrder(1)
DbSeek(xFilial("SKK")+M->ADE_GRUPO)
While !EOF() .AND. SKK->KK_CODSU0 == M->ADE_GRUPO
   	cCodSubject += SKK->KK_CODSKQ + "/"
	DbSkip()
End
DbSelectArea("SKK")
DbCloseArea()

DbSelectArea("SX5")
DbSetOrder(1)
DbSeek(xFilial("SX5") + "T1")
While !EOF() .AND. SX5->X5_TABELA == "T1"
    If SX5->X5_CHAVE $ cCodSubject
    	aAdd(aItems, {SX5->X5_CHAVE, X5DESCRI()})
    End
	DbSkip()
End

If Len(aItems) > 0
	DEFINE MSDIALOG oDlgSu9 FROM  50,003 TO 260,500 TITLE STR0001 PIXEL  //"Assuntos"

		@ 03,10 LISTBOX oLbx1 VAR nPosLbx FIELDS HEADER ;
				STR0002,;	//"Código"
				STR0003,;	//"Chave"
				SIZE 233,80 OF oDlgSu9 PIXEL NOSCROLL
		oLbx1:SetArray(aItems)
	    oLbx1:bLine:={||{aItems[oLbx1:nAt,1],;
						 aItems[oLbx1:nAt,2] }}

	    oLbx1:BlDblClick := {||(lRet:= .T.,nPos:= oLbx1:nAt, oDlgSu9:End())}
		oLbx1:Refresh()

	    DEFINE SBUTTON FROM 88,175 TYPE 1 ENABLE OF oDlgSu9 ACTION (lRet:= .T.,nPos := oLbx1:nAt,oDlgSu9:End())
	    DEFINE SBUTTON FROM 88,210 TYPE 2 ENABLE OF oDlgSu9 ACTION (lRet:= .F.,oDlgSu9:End())

	ACTIVATE MSDIALOG oDlgSu9 CENTERED
Else
	Help(" ",1,"ASSUNTOS" )
	lRet := .F.
EndIf

If lRet
	DbSelectArea("SX5")
	DbSetOrder(1)
	lRet := DbSeek(xFilial("SX5") + "T1" + aItems[nPos,1])
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMK510BGRVIT  ºAutor  ³Venda Cliente   º Data ³  22/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao utilizada antes da gravacao dos dados do atendimento.º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510BGRVIT()

Local aAreaADE 	:= ADE->(GetArea())
Local aAreaSIX 	:= SIX->(GetArea())
Local aAreaSM0 	:= SM0->(GetArea())
Local aArea 	:= GetArea()
Local lRet 		:= .T.				// Retorno da funcao.
Local cNumAux	:= M->ADE_CODIGO	// Codigo sequencial do atendimento.
Local lEncComp  := SuperGetMv("MV_TMKCOMP",,.F.)	// Indica se verificará a integridade dos chamados filhos ao encerrar o chamado pai.
Local lTmkGrv   := ExistBlock("TK510GRV")  // Ponto de entrada para validações antes da gravação do Atendimento
Local aRetDup	:= {}
Local cAviso	:= ""
Local cSep		:= ""
Local nX		:= 0
Local nY		:= 0
Local nTamFil	:= FWSizeFilial()
Local cFilSM0	:= ""
Local aRetRegra:= {}  // regras de transferencia automatica
Local nPosRec	:= aScan(aHeader, {|x| AllTrim(x[2]) == "ADF_REC_WT"})
Local nOcoPos	:= aScan(aHeader, {|x| AllTrim(x[2]) == "ADF_CODSU9"})
Local lTemTransf := .F.
Local lAutomatico:= ExecSchedule()

lTransfAuto := .F.  // variavel estatica que controla a transferencia automatica

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o chamado sofreu alteração de outro operador, ³
//³ caso o tempo configurado no parãmetro MV_TMKTPCH, tenha   ³
//³ expirado.												  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ParamIXB[3] == 4 .AND.;
	!(Type("lTk503Auto") == "L" .AND. lTk503Auto ) .AND.;
	( TkOperador() <> Posicione("ADE",1,xFilial("ADE")+cNumAux,"ADE_OPEUSO") )
	Aviso(	STR0012,; //"Help Desk"
			STR0174,; //"Este chamado foi alterado por outro operador e não poderá ser manipulado. Caso deseje, feche o chamado e efetue uma nova alteração."
			{"OK"})
	RestArea(aAreaADE)
	RestArea(aAreaSIX)
	RestArea(aAreaSM0)
	RestArea(aArea)
	Return(.F.)
EndIf

cIncMemo	:= M->ADE_INCIDE
cIncOBS 	:= M->ADE_OBSMEM
cChAnex 	:= ""
cFilChAnex	:= ""

// mudar o uso do PARAMIXB.
If ParamIXB[3] == 3 //Inclusao

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Impede que sejam feitos 2 atendimentos com o mesmo numero³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("ADE")
	DbSetOrder(1)
	cMay := "ADE" + ALLTRIM(xFilial("ADE")) + cNumAux
	While (DbSeek(xFilial("ADE") + cNumAux) .OR. !MayIUseCode(cMay))
		cNumAux := Soma1(cNumAux,Len(cNumAux))
		cMay 	:= "ADE" + ALLTRIM(xFilial("ADE")) + cNumAux
	End

	If (cNumAux <> M->ADE_CODIGO)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao estiver usando a entrada automatica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Help(" ",1,"NUMSEQ",,cNumAux,4,15)
		M->ADE_CODIGO := cNumAux
	Endif

	If __lSX8
		ConfirmSX8()
	Endif
Else
	cChAnex := ADE->ADE_CHANEX
	cFilChAnex := ADE->ADE_FLCHAN
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar a integridade do chamado                                             ³
//³- Não pode encerrar o chamado pai, havendo um chamado filho aberto ou pendente.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->ADE_STATUS == "3" .AND. lEncComp
	DbSelectArea("ADE")
	DbSetOrder(21) // ADE_FILIAL + ADE_CHORIG
	If MsSeek( xFilial("ADE")+M->ADE_CODIGO )
		While ADE->(!EOF()) .AND.;
			ADE->ADE_CHORIG == M->ADE_CODIGO

			If ADE->ADE_STATUS <> "3"
                    	lRet := .F.
                    	Help(" ",1,"CHFABERTO" )
                    	Exit
			EndIf
			ADE->(DbSkip())
		End
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se ha chamados abertos em ³
	//³outras filiais                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet

		DbSelectArea("SIX")
		DbSetOrder(1) //INDICE+ORDEM

		DbSelectArea("SM0")
		DbSetOrder(1) //M0_CODIGO+M0_CODFIL
		DbSeek(cEmpAnt)

		While SM0->(!Eof()) .AND. SM0->M0_CODIGO == cEmpAnt
			cFilSM0 := Left(SM0->M0_CODFIL,nTamFil)
			If cFilSM0 <> cFilAnt
				If SIX->(DbSeek("ADEM"))
					If AllTrim(Upper(SIX->CHAVE)) == "ADE_FILIAL+ADE_FILORI+ADE_CHORIG"
						DbSelectArea("ADE")
						DbSetOrder(22) // ADE_FILIAL+ADE_FILORI+ADE_CHORIG
						If ADE->(DbSeek( cFilSM0+xFilial("ADE")+M->ADE_CODIGO ))
							While ADE->(!EOF()) .AND.;
								ADE->ADE_CHORIG == M->ADE_CODIGO .AND.;
								ADE->ADE_FILORI == xFilial("ADE")

								If ADE->ADE_STATUS <> "3"
			                    	lRet := .F.
			                    	Help(" ",1,"CHFABERTO" )
			                    	Exit
								EndIf
								ADE->(DbSkip())
							End
						EndIf
					EndIf
				EndIf
			EndIf
			SM0->(DbSkip())
		End
	EndIf
EndIf

If lRet .AND. M->ADE_STATUS == "3"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se há registro de monitoração para ³
	//³Encerramento do Chamado                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TK510RegMon(	3, 	"ADE")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida a duplicidade de informacoes do chamado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. INCLUI .AND. Empty(aTransfere) .AND. !(Type("lTk503Auto") == "L" .AND. lTk503Auto )
	aRetDup := VldDuplicidade()
	If Len(aRetDup) > 0

		lRet := .F.

		cAviso += STR0130 //"O(s) chamado(s) a seguir repetem as mesmas informações:"

		For nX := 1 to Len(aRetDup)
			cSep := ""
			If aRetDup[nX][1]== "*"
				cAviso +=  CRLF +  CRLF + STR0131 //"Duplicidade no cabeçalho com o(s) chamado(s): "
				For nY := 1 to Len(aRetDup[nX][2])
					cAviso	+= cSep + aRetDup[nX][2][nY]
					cSep	:= ", "
				Next nX
			Else
				cAviso +=  CRLF +  CRLF +STR0132 + aRetDup[nX][1] + STR0133 //"Duplicidade no item "###" com o(s) chamado(s): "
				For nY := 1 to Len(aRetDup[nX][2])
					cAviso	+= cSep + aRetDup[nX][2][nY]
					cSep	:= ", "
				Next nX
			EndIf
		Next nX

		cAviso += CRLF + CRLF + STR0128 //"Deseja abrir este chamado mesmo assim?"

		lRet := (Aviso(STR0134, cAviso, {STR0075,STR0076},3,STR0129) == 1) //"Sim"###"Não"###"Dados duplicados"

	EndIf
EndIf

if lRet .and. INCLUI
	lTemTransf := .F.

	// TFEGRP Transferencia automatica de chamados
	// retorna as regras validas para o chamado
	aRetRegra := TK560REGRA(M->ADE_ASSUNT, M->ADE_GRUPO)
	if Len(aRetRegra) > 0
		// verificar se ja existe transferencia e dar uma mensagem
		For nX := 1 to Len(aCols)
			//Salta linhas deletadas ou previamente incluidas
			If aTail(aCols[nX]) .OR. (aCols[nX,nPosRec] > 0)
				Loop
			EndIf

			// nao permite que tenha interacao de transferencia se existe uma regra de transferencia automatica
			If aCols[nX][nOcoPos] == "TMK001"
				lTemTransf := .T.
				Exit
			Endif
		Next

		// grupo diferente = transferencia
		if Len(aRetRegra) > 0  // aRetRegra[1,2] <> M->ADE_GRUPO
			// nao tem transferencia incluida manualmente
			if ! lTemTransf
				if aRetRegra[1,2] <> M->ADE_GRUPO
					cTxtMsg := STR0175+CRLF+CRLF // "O grupo e operador abaixo foram selecionados para este chamado:"
					cTxtMsg += STR0176+aRetRegra[1,2]+" "+Posicione("SU0",1,xFilial("AAV")+aRetRegra[1,2],"U0_NOME")+CRLF // "Grupo    : "
					cTxtMsg += STR0177+aRetRegra[1,3]+" "+Posicione("SU7",1,xFilial("AAV")+aRetRegra[1,3],"U7_NOME")+CRLF // "Operaror : "
				Else
					cTxtMsg := STR0178+CRLF+CRLF // "O operador abaixo foi selecionado para ser alocado neste chamado:"
					cTxtMsg += STR0177+aRetRegra[1,3]+" "+Posicione("SU7",1,xFilial("AAV")+aRetRegra[1,3],"U7_NOME")+CRLF // "Operaror : "
				Endif
				cTxtMsg += CRLF+STR0179+CRLF+CRLF  // "Confirma a Transferencia do chamado ?"
				cTxtMsg += STR0180+CRLF // "(Clique em [NAO] para manter o chamado com voce)"

				lMsgTransf := .T.
				if ! lAutomatico
					lMsgTransf := Aviso(STR0181, cTxtMsg,{STR0182,STR0183},3,STR0184)	== 1 // "Transferencia automatica de chamados"###"Sim"###"Nao"###"Localizada Regra de Transferencia"
				Endif

				if lMsgTransf
					lTransfAuto := .T.
					if aRetRegra[1,2] <> M->ADE_GRUPO
						aTransfere := {}
						Tk510TransfAt(.T.)
					Else
						Tk510IncAcols(	"TMK001", STR0185+aRetRegra[1,3]+" "+Alltrim(Posicione("SU7",1,xFilial("AAV")+aRetRegra[1,3],"U7_NOME")) + STR0186,Nil,; // "Chamado Transferido para Operaror : "###" [Transferencia Automatica]"
							aRetRegra[1,3],M->ADE_ASSUNT, M->ADE_CODSB1	, M->ADE_GRUPO	, M->ADE_CODCAT,;
							M->ADE_CODORI, M->ADE_NCAUSA	, M->ADE_CODEFE, M->ADE_CODCAM	,;
							.F., .T.		) //"Chamado Transferido para Operaror : "###" [Transferencia Automatica]"
					Endif
				Endif
			Endif
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena a ultima configuracao de recorrencia feita³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aRecorrencia) > 0
	aRecorrencia[4] := AllTrim(M->ADE_STRREC)
EndIf

If lTmkGrv
	lRet:= ExecBlock('TK510GRV',.F.,.F.)
End if

RestArea(aAreaADE)
RestArea(aAreaSIX)
RestArea(aAreaSM0)
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMK510GRVIT   ºAutor  ³Venda Cliente   º Data ³  22/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao utilizada na gravacao dos dados do atendimento.	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510GRVIT()
Local aArea 		:= GetArea()				// Salva a area atual
Local aAreaSU0		:= SU0->(Getarea())
Local nItem 		:= 0
Local nRecNo		:= 0
Local nOcoPos 		:= 0						// ADF_CODSU9
Local nObsPos 		:= 0
Local nItmPos 		:= 0
Local nActPos 		:= 0
Local nGrpPos 		:= 0
Local cCodOper  	:= TkOperador()
Local cPendCh		:= "2"						// Indica se deve assumir pendencia de chamado (1=Sim/ 2=Nao/ 3=Pergunte)
Local lAssumeCh 	:= .F.						// Flag indicando que assumira a pendencia
Local nFirstItem	:= ""						// Armazena o código do primeiro item que foi criado
Local lRunAct		:= .T.						// Se é para executar ou não o TkRunAct, alterado somente pelo PE TKRUNACT
Local lTKRUNACT		:= ExistBlock("TKRUNACT")	// Ponto de Entrada acionado para forcar a execução da ação da linha
Local lTK500INC     := ExistBlock("TK500INC")	// Ponto de Entrada acionado para possibilitar a alteração do campo INCIDENCIA
Local cIncMemoTMP   := ""
Local lFNCOpen		:= .F.						// Se a FNC está em aberto no QNC
Local lTK510End     := ExistBlock("TK510END")  //  Ponto de Entrada após a gravação do atendimento
Local cOpcDefault 	:= ""						// Opcao de alocacao padrao
Local lAutoSel		:= .F.						// Selecao automatica de operador
Local lGrv510PC		:= .T.
Local lAut1			:= .F.
Local aRetRegra:= {}  // regras de transferencia automatica
Local lAutomatico:= ExecSchedule()

Local lTela         := ''
Local lReproSLA	 := .F.							//Se teve alguma ocorrência de reprogramação de SLA - "TMK006"

Local lErroTMK	:= .F.
Local oError		:= ErrorBlock({|e| Tk510Error(e), lErroTMK := .T.})
Local aRegsWF		:= {}

lAut1 := Iif(type('lTmk503Auto')=='L',lTmk503Auto,.F.)

If !Empty(cCodOper)
	cPendCh := SU7->U7_PENDCHA
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha outro analista manipulando o mesmo chamado      	  |
//³ So libera se o analista estiver ha mais de 2 horas alocado.    	  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TK510UsrLock("U", ADE->ADE_CODIGO, cCodOper)

If lTK500INC
	cIncMemoTMP := Execblock("TK500INC",.F.,.F.,{cIncMemo,SUK->UK_CODIGO})
	If Valtype(cIncMemoTMP) == "C"
		cIncMemo := cIncMemoTMP
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava campo incidente  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(ADE->ADE_CODINC)
	MSMM(ADE->ADE_CODINC,TamSx3("ADE_INCIDE")[1],,cIncMemo,1,,,"ADE","ADE_CODINC")
Else
	DbSelectArea("ADE")
	DbSetOrder(1)
	If MsSeek(xFilial("ADE")+ADE->ADE_CODIGO)
		BEGIN TRANSACTION
			RecLock("ADE", .F.)
			REPLACE ADE_CODDEC WITH INVERTE(ADE->ADE_CODIGO)
			MsUnlock()
			MSMM(,TamSx3("ADE_INCIDE")[1],,cIncMemo,1,,,"ADE","ADE_CODINC")
		END TRANSACTION
	EndIf
EndIf
cIncMemo := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava campo Observacoes|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(ADE->ADE_CODOBS)
	MSMM(ADE->ADE_CODOBS,TamSx3("ADE_OBSMEM")[1],,cIncOBS,1,,,"ADE","ADE_CODOBS")
Else
	DbSelectArea("ADE")
	DbSetOrder(1)
	If MsSeek(xFilial("ADE")+ADE->ADE_CODIGO)
		BEGIN TRANSACTION
			RecLock("ADE", .F.)
			REPLACE ADE_CODDEC WITH INVERTE(ADE->ADE_CODIGO)
			MsUnlock()
			MSMM(,TamSx3("ADE_OBSMEM")[1],,cIncOBS,1,,,"ADE","ADE_CODOBS")
		END TRANSACTION
	EndIf
EndIf
cIncOBS := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi gerado FNC e se ela ainda está   ³
//³ em aberto. Se estiver em aberto, não deixa o     ³
//³ operador assumir a pendência do chamado.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(ADE->ADE_FNC) .AND. !Empty(ADE->ADE_FNCREV)
	dbSelectArea("QI2")
	dbSetOrder(2)
	dbSeek(xFilial("QI2")+ADE->ADE_FNC+ADE->ADE_FNCREV)
    If Empty(QI2->QI2_CONREA)
		lFNCOpen := .T.
	EndIf
EndIf

If ExistBlock( "TK510GPC" )
	If !(ValType(lGrv510PC := ExecBlock("TK510GPC", .F., .F., { ADE->ADE_CODIGO, cCodOper } )) == "L")
		lGrv510PC := .T.
	EndIf
EndIf

If lGrv510PC

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Verifica se deve assumir a              |
	//|pendencia de atendimento do chamado		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !lTransfAuto .and. (ADE->ADE_OPERAD <> cCodOper) .AND. (cPendCh <> "2") .AND. Empty(aTransfere) .AND. !lCompartilhou .AND. (!lFNCOpen)
		If cPendCh == "1"  //Assume a pendencia
			lAssumeCh := .T.

		ElseIf cPendCh == "3" .AND. ! lAutomatico 	//Pergunte
			If MsgYesNo(STR0040, STR0016) 	// "Deseja assumir a pendência deste chamado?" # "Atenção"
				lAssumeCh := .T.
			EndIf

		EndIf
		If lAssumeCh
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o Operador/Grupo que assumiu o chamado. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BEGIN TRANSACTION
				RecLock("ADE", .F.)
				REPLACE ADE_OPERAD WITH cCodOper
				REPLACE ADE_GRUPO  WITH SU7->U7_POSTO
				MsUnlock()
			END TRANSACTION
		EndIf

	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Distribui o chamado automaticamente para grupos com regras de distribuicao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If INCLUI

	if ! lTransfAuto	// se for transferencia automatica ignora a distribuicao automatica
		If ! lAutomatico
			cOpcDefault := AllTrim(SuperGetMv("MV_TMKALOC",,""))
			SU0->(DbSetOrder(1))
			SU0->(MsSeek(xFilial("SU0")+ADE->ADE_GRUPO))
			If (SU0->U0_TPALOC $ '2/3/4' .OR. (Empty(SU0->U0_TPALOC) .AND. cOpcDefault $ '2/3/4'))
				lAutoSel := MsgNoyes(STR0142) //"Deseja distribuir este chamado automaticamente?"
			EndIf
		ElseIf (Empty(ADE->ADE_OPERAD) .AND. !Empty(ADE->ADE_GRUPO))
			lAutoSel := .T.
		EndIf
	Endif

 	If lAutoSel // .and. Empty(aRetRegra[1,3])
		cCodOper := Tk510OpAuto( ADE->ADE_GRUPO, @cOpcDefault, .F., .F. )
		If !Empty(cCodOper)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o Operador selecionado atuomaticamente. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BEGIN TRANSACTION
				RecLock("ADE", .F.)
				REPLACE ADE_OPERAD WITH cCodOper
				MsUnlock()

				If cOpcDefault == "4"
					SU7->(dbSetOrder(1))
					If SU7->(MsSeek(xFilial("SU7")+cCodOper))
						If SoftLock("SU7")
					    	SU7->U7_DTRODZ  := If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
					    	SU7->U7_HRRODZ	:= StrTran(Time(),":","")
						    SU7->(MsUnlock())
						EndIf
					EndIf
				EndIf

			END TRANSACTION
		EndIf
	EndIf
EndIf

For nItem:=1 To Len(ParamIXB[1])
	If AllTrim(ParamIXB[1][nItem][2]) == "ADF_OBS" .AND. ParamIXB[1][nItem][8]=="M"
		nObsPos := nItem
	EndIf
	If AllTrim(ParamIXB[1][nItem][2]) == "ADF_ITEM"
		nItmPos := nItem
	EndIf
	If AllTrim(ParamIXB[1][nItem][2]) == "ADF_CODSUQ"
		nActPos := nItem
	EndIf
	If AllTrim(ParamIXB[1][nItem][2]) == "ADF_CODSU9"
		nOcoPos := nItem
	EndIf
	If AllTrim(ParamIXB[1][nItem][2]) == "ADF_CODSU0"
		nGrpPos := nItem
	EndIf
Next nItem

If nObsPos > 0
	For nItem:=1 To Len(ParamIXB[2])
		If !ParamIXB[2][nItem][Len(ParamIXB[2][nItem])]
			nRecNo := 0
			DbSelectArea("ADF")
			nRecNo := ParamIXB[2][nItem][Len(ParamIXB[2][nItem])-1]

			If lTKRUNACT
				lRunAct := ExecBlock("TKRUNACT", .F., .F., {ParamIXB[1], ParamIXB[2], nItem})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se houve alguma ocorrência de reprogramação de SLA.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nRecno <> 0 .And. !lReproSLA
				If AllTrim(ParamIXB[2][nItem][nOcoPos]) == "TMK006"
					lReproSLA := .T.
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ser for inclusão ou se o PE solicitar, executa a ação.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (nRecNo==0 .And. !lTKRUNACT) .Or. (lRunAct .And. lTKRUNACT)
				If Empty(nFirstItem)
					nFirstItem := ParamIXB[2][nItem][nItmPos]
				EndIf
            	TkRunAct(ParamIXB[1], ParamIXB[2], nItem, nObsPos, nItmPos, nActPos, nOcoPos, nGrpPos,,,,,,,,lReproSLA,@aRegsWF)
    		EndIf
			If nRecno <> 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava campos MEMO      |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbGoTo(ParamIXB[2][nItem][Len(ParamIXB[2][nItem])-1])
				MSMM(ADF->ADF_CODOBS,TamSx3("ADF_OBS")[1],,ParamIXB[2][nItem][nObsPos],1,,,"ADF","ADF_CODOBS")
			EndIf
		EndIf
	Next nItem
	ParamIXB[4] := aRegsWF
EndIf

aTransfere 		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche a data final dos itens inseridos no atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TKPUTDTFIM(ADE->ADE_CODIGO, nFirstItem)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se há registro de monitoração para ³
//³Abertura de Chamado                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If INCLUI
	TK510RegMon(	1, 	"ADE")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se há registro de monitoração para ³
//³Alteracao de Chamado                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ALTERA
	TK510RegMon(	2, 	"ADE")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa a mudanca na recorrencia do chamado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !IsInCallStack("GenRecurrence") .AND.;
	Len(aRecorrencia) > 0 .AND. !(aRecorrencia[2] == aRecorrencia[4])

	If !lAut1
		If !Empty(aRecorrencia[4])
			If !Empty(aRecorrencia[2])
				MsgRun(STR0117,STR0057, {|| TkDelRec(aRecorrencia[1], aRecorrencia[3] )}) //"Eliminando chamados anteriores desta recorrência"###"Aguarde"
			EndIf
			If MsgYesNo(STR0118) //"Deseja processar os chamados recorrentes agora?"
				MsgRun(STR0119,STR0057, {|| TkRecorren(Nil,aRecorrencia[1]) })//"Processando os novos chamados desta recorrência"###"Aguarde"
			EndIf
		Else
			If MsgYesNo(STR0120)//"Deseja remover os chamados recorrentes não encerrados?"
				MsgRun(STR0117,STR0057, {|| TkDelRec(aRecorrencia[1], aRecorrencia[3] )})//"Eliminando chamados anteriores desta recorrência"###"Aguarde"
			EndIf
		EndIf
	Endif

EndIf

//Se inclusao e operador assume chamado na inclusao = sim
//verifica se deseja assumir o chamado
If (Procname(8)<> 'TK510CRIAREPLICA')
	If INCLUI .and. Posicione("SU7",4,xFilial("SU7") + __cUserId,"U7_ASSCHI")=="3"
   		If  !MsgYesNo(STR0040, STR0016) 	// "Deseja assumir a pendência deste chamado?" # "Atenção"
			RecLock("ADE", .F.)
			REPLACE ADE->ADE_OPERAD	WITH ""
			MsUnlock()
	   Endif
	EndIf
Endif

If lTK510End
	ExecBlock('TK510END',.F.,.F.)
Endif

ErrorBlock(oError)
RestArea(aAreaSU0)
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKPUTDTFIM    ºAutor  ³Venda Cliente   º Data ³  04/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza a data final dos itens do chamado                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TKPUTDTFIM(cCodChama, nFirstItem)
Local aAreaADF := ADF->(GetArea())
Local aAreaADFAux
Local cDate
Local cTime

DbSelectArea("ADF")
DbSetOrder(1)
If MsSeek( xFilial("ADF")+cCodChama )
	While ADF->(!EOF()) .AND.;
		ADF->ADF_CODIGO == cCodChama

   		If Empty(ADF->ADF_HORAF) .AND.;
			ADF->ADF_ITEM >= nFirstItem

			cDate := ADF->ADF_DATA
			cTime := ""
			aAreaADFAux := ADF->(GetArea())
			ADF->(DbSkip())
			If ADF->(!EOF()) .AND.;
				ADF->ADF_CODIGO == cCodChama .AND.;
				ADF->ADF_DATA == cDate

				cTime := ADF->ADF_HORA
			ElseIf ADF->(EOF()) .OR.;
				ADF->ADF_CODIGO <> cCodChama

				cTime := Time()
			EndIf
			RestArea(aAreaADFAux)
			If !Empty(cTime)
				RecLock("ADF", .F.)
				REPLACE ADF->ADF_HORAF WITH cTime
				MsUnlock()
			EndIf
		EndIf

		ADF->(DbSkip())
	End
EndIf

RestArea(aAreaADF)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkRunAct      ºAutor  ³Venda Cliente   º Data ³  22/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa as acoes previstas em Ocorrencias ou Acoes do Help- º±±
±±º          ³-Desk para cada Item do chamado de Help-Desk.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ TkRunAct(ExpA1,ExpN2,ExpN3,ExpN4,						  º±±
±±º			 |			ExpN5,ExpN6,ExpN7)       						  º±±
±±º			 |			               									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 =  	aHeader dos itens do chamado          			  º±±
±±º          ³ExpA1 =  	aCols dos itens do chamado          			  º±±
±±º          ³ExpN2 =	Linha do aCols que deve ser avaliada   			  º±±
±±º          ³ExpN3 =  	Observacao do Item 								  º±±
±±º          ³ExpN4 =  	Numero do Item do chamado						  º±±
±±º          ³ExpN5 =  	Codigo da acao  								  º±±
±±º          ³ExpN6 =  	Codigo da ocorrencia  							  º±±
±±º          ³ExpN7 =  	Codigo do Grupo de Atendimento					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkRunAct(	aHeaderADF				, aColsADF					, nItem		, nObsPos				,;
							nItmPos					, nActPos					, nOcoPos	, nGrpPos				,;
							cStatus					, dRealiz					, cTPACAO	, lCancelStatusControl	,;
							lCancelSonReplication	, lCancelFatherReplication	, cFilOri	, lReproSLA			,;
							aRegsWF )
Local aAreaADE										:= ADE->(GetArea())
Local cObsAux										:= ""					// Armazena a observacao informado pelo usuario
Local aQNCParam										:= {}					// Lista de parametros enviados ao QNC
																			// aQNCParam[1] = Cod. Produto
																			// aQNCParam[2] = Area
Local aSLARegister 									:= {}
Local nCriticidade 									:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Utilizado o GETMV de proposito, para que sempre se pegue o ultimo valor. |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cUltimo 										:= SuperGetMv("MV_TMKQNC",.F.,"")	// Indica a uçtima vez que atualizou as tabelas de Depto./Usuarios do QNC.
Local cTextErr 										:= ""		  						// Armazena o erro para cada funcionalidade
Local e          									:= Nil
Local aRetQNCGera 									:= {}		  						// Retorno da rotina automática GeraFNC - {Filial do FNC, Codigo Sequencial da FNC, Revisao da FNC}
Local cGrpQNC										:= ""		  						// Armazena o Grupo responsável pela correção do produto(QNC)
Local cGrpTMK										:= ""								// Armazena o Grupo responsável pela correção do produto(TMK)
Local cQAACod										:= ""		   						// Armazena o codigo do Usuario QNC - Tabela QAA
Local lRevisao 										:= .F.								// Identifica quando deve ser criada uma nova revisao da FNC existente
Local aArea 										:= GetArea()
Local aAreaSM0 									:= {}
Local lRevisaFNC 									:= SuperGetMv("MV_TMKREV",,.T.)	// Indica se utilizara a revisao ao criar uma nova FNC.
Local lGeraFNC 										:= .F.		   						// Indica se deverá ser gerado a FNC
Local cGroupAnt 									:= ""		   						// Armazena o codigo da equipe anterior a FNC
Local cOperaAnt 									:= ""		   						// Armazena o codigo do analista anterior a FNC
Local lCancela 										:= .F.		   						// Indica se o usuario cancelou a geração da FNC
Local lAvalSLA 										:= .T.		   						// Indica se deverá ser avaliado o SLA
Local cCodWFTemplate 								:= ""	   							// Armazena o codigo do Template de Workflow
Local lTKREPLICA									:= ExistBlock("TKREPLICA")			// Ponto de Entrada para confirmar se deve replica informacoes para outros chamados
Local lTKREPFILHO 									:= ExistBlock("TKREPFILHO")			// Ponto de Entrada para confirmar se deve replica informacoes para chamados filhos (compartilhados)
Local lTKREPPAI 									:= ExistBlock("TKREPPAI")			// Ponto de Entrada para confirmar se deve replica informacoes para chamados pai
Local lTKATURPL										:= ExistBlock("TKATURPL") 			// Ponto de Entrada acionado apos atualizar o chamado replicado.
Local lTKENVWOR										:= ExistBlock("TKENVWOR") 			// Ponto de Entrada acionado antes de chamar o envio do workflow (Utilizado para cancelar o envio do mesmo)
Local lReplica										:= .T.
Local lRetReplica									:= Nil
Local cCodADE 										:= ""
Local cCodSB1 										:= ""
Local cTargetGroup									:= ""								// Grupo que ocorrerá o cálculo de SLA
Local lEnvWorkflow									:= .T.
Local lFndCall										:= .F.								// Indica se existe chamado a ser vinculado
Local nOpcBusca										:= SuperGetMv("MV_TMKFNDC",,1)		// Opcao para exibir ou nao a tela de associcao de chamados na reabertura da FNC (1=Sempre;2=Nunca;3=Pergunta)
Local lGrvStatusAut									:= .T. 								// No controle de status automatico usado para controlar a gravacao
Local cOpQNCDDES  := SuperGetMv("MV_QNCDDES",,"")
Local aChamRel										:= {}								// Lista de chamados relacionados
Local aMenorSLA										:= {}								// Menor prazo de SLA entre chamados associados
Local nPausedTime									:= 0								// Tempo pausado no SLA
Local cDepOriQNC 									:= ""
Local lAltFil										:= .F.								// Indica se deve alterar a filial
Local cFilTransf									:= xFilial("SU0")					// Filial de destino
Local nTipoCmpSLA									:= SuperGetMV("MV_TMKASLA",,0)		// Tipo de comparacao de SLAs
Local lTkAvalSla									:= ExistBlock("TKAVALSLA")			// Ponto de Entrada verificar se devrá ser avaliado o SLA.
Local oWFTemplate									:= Nil
Local lToFather										:= .T.
Local lToSon										:= .F.
Local aList											:= {}
Local nCount										:= 1
Local nFil											:= 0								// Auxiliar de loop sobre filiais
Local lReplicaFilial								:= .F.
Local aFiliais										:= {}								// Lista de filiais para replica de informacoes
Local cFilBkp										:= ""								// Armazena a filial corrente
Local cOperRep										:= ""								// Operador que disparou a replica
Local nTamFil										:= FWSizeFilial()					// Tamanho do campo filial
Local cFilSM0										:= ""								// Filial posicionada no SM0
Local cAcaoSLA										:= (.F.)							// Acao SLA gerada por uma ocorrencia
Local cCHPai										:=  ""								//Armazena o codigo do chamado principal, caso o chamado esteja associado
Local cFlChan										:= ""								//Armazena filial do chamado principal
Local lAltStatus									:=  .T.								//Indica se o staus do chamado pai deve ser replicado para os filhos
Local cCodOper										:= TkOperador()
Local lAut1     									:= .F.

Default cStatus 				:= ""
Default dRealiz 				:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
Default lCancelStatusControl	:= .F.
Default lCancelSonReplication	:= .F.
Default lCancelFatherReplication:= .F.
Default cFilOri					:= cFilAnt
Default lReproSLA				:= .F.
Default aRegsWF					:= {}

PRIVATE lMsErroAuto := .F.
lAut1 := Iif(type('lTmk503Auto')=='L',lTmk503Auto,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tipos de comparacao de SLAs (MV_TMKASLA)                ³
//³0 - Desabilita a comparacao na associacao               ³
//³1 - Compara e replica o SLA apenas entre chamados       ³
//³2 - Compara e replica o SLA ao gerar uma FNC no chamado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Garantir que esta posicionado no ADE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ADE->(!Eof()) .AND. !Empty(ADE->ADE_CODIGO)
	cCodADE := ADE->ADE_CODIGO
	cCodSB1 := ADE->ADE_CODSB1
	cCHPai  := ADE->ADE_CHANEX
Else
	Return Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o que deve ser executado pela acao |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SUQ")
DbSetOrder(1)

If !Empty(aColsADF[nItem][nActPos]) .AND. MsSeek(xFilial("SUQ")+aColsADF[nItem][nActPos])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena o codigo do Template de Workflow   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodWFTemplate := SUQ->UQ_WFTEMPL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle de status automático no chamado³
	//³de Service Desk. Nao se aplica a replica ³
	//³para chamados compartilhados.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	SUQ->UQ_STATCH $ "1|2|3|" .AND.;
		!lCancelStatusControl

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se um chamado encerrado poderá ser reaberto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	ADE->ADE_STATUS == "3" 	.AND.;
			SUQ->UQ_STATCH $ "1|2|"	.AND.;
			Tk510ChEncerra(cCodADE, aColsADF[nItem][nGrpPos])

			lGrvStatusAut := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a atualizacao do status do chamado  ³
		//³pai deve ser replicado para os chamados filhos. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lAltStatus := Iif((SUQ->UQ_STREP == "2" .AND. !Empty(ADE->ADE_CHANEX)),.F.,.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o status do chamado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGrvStatusAut .AND. lAltStatus
			DbSelectArea("ADE")
			DbSetOrder(1)                    						
			If MsSeek(xFilial("ADE")+cCodADE) 			
				RecLock("ADE", .F.)				
				REPLACE ADE->ADE_STATUS	WITH SUQ->UQ_STATCH
				ADE->(MsUnlock())
			EndIf		  
		EndIf		
	EndIf

	If SUQ->UQ_STATCH == "3"
		RecLock("ADE", .F.) 
		If (SUQ->UQ_STREP == "1" .AND. !Empty(ADE->ADE_CHANEX))
			REPLACE ADE->ADE_STATUS	WITH SUQ->UQ_STATCH
		EndIf
		REPLACE ADE->ADE_DENCCH WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )  
		REPLACE ADE->ADE_HENCCH WITH Time()  
		ADE->(MsUnlock())	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa rotina para criar uma FNC           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lGeraFNC := .F.
	If SUQ->UQ_GERFNC == "1"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza atualizacao diaria dos dados de integracao QNC|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cUltimo) .OR. CTOD(SubStr( cUltimo, 1, At( "-", cUltimo ) - 1 )) <> dDataBase

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o parametro MV_TMKQNC que indica quando foi feita a ultima atualizacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectarea("SX6")
			DbSetOrder(1)
			If DbSeek(xFilial("SX6") + "MV_TMKQNC")
				RecLock("SX6",.F.)
				PutMv("MV_TMKQNC",DtoC(dDatabase)+"-"+Time())
				SX6->(MsUnLock())
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica na base de chamados por chamados semelhantes |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("ADE")
		DbSetOrder(1)
		MsSeek(xFilial("ADE")+cCodADE)
		RegToMemory("ADE",.F.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for reabertura de FNC, analisa se deve ser exibida a tela para associacao³
		//³de chamados novamente, conforme o parametro MV_TMKFNDC:                     ³
		//³(1=Sempre;2=Nunca;3=Pergunta)                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(ADE->ADE_FNC)
			If  nOpcBusca == 1		//Sempre
				lFndCall := Tk510FndCal(@lCancela)
			ElseIf nOpcBusca == 3	//Pergunta
				If MsgYesNo(STR0055,STR0016)//"Deseja realizar a pesquisa para associação a chamados existentes?"###"Atenção"
					lFndCall := Tk510FndCal(@lCancela)
				EndIf
			EndIf
		Else
			If lAut1 // Desabilitar pesquisa de chamados (Rotina Automatica)
				lFndCall := .F.
			Else
				lFndCall := Tk510FndCal(@lCancela)
			Endif
		EndIf

		If !lFndCall
			If !lCancela
				cQAACod := ""
				cQAACod := RDZRetEnt("SU7",xFilial("SU7") + TkOperador(),"QAA",,,,.F.)
				lRevisao := .F.
				aQNCParam := {}
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se o chamado ja possui FNC criada.           |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRevisaFNC
					DbSelectArea("ADE")
					DbSetOrder(1)
					If MsSeek(xFilial("ADE")+cCodADE)
						If !Empty(ADE->ADE_FNC) .AND. !Empty(ADE->ADE_FNCREV)
							lRevisao := .T.
							aAdd(aQNCParam, {"QI2_FILIAL"	, ADE->ADE_FNCFIL})
							aAdd(aQNCParam, {"QI2_FNC"		, ADE->ADE_FNC})
							aAdd(aQNCParam, {"QI2_REV"		, Soma1(ADE->ADE_FNCREV)})
						EndIf
					EndIf
				EndIf

				aAdd(aQNCParam, {"QI2_CODPRO", cCodSB1})
				aAdd(aQNCParam, {"QI2_FILORI", xFilial("QAD") })

				cGrpQNC := POSICIONE("SB1",1,xFilial("SB1")+cCodSB1,"B1_CODQAD")
				If Empty(cGrpQNC)
					cGrpQNC := cOpQNCDDES
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| Busca Departamento/Setor (QNC) vinculado ao Grupo de Atendimento (TMK)|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cDepOriQNC := Posicione("QAD",3,xFilial("QAD")+ADE->ADE_GRUPO,"QAD_CUSTO")

				If Empty(cDepOriQNC)
					cDepOriQNC := SuperGetMv("MV_QNCDORI",,"")
				EndIf

				aAdd(aQNCParam, {"QI2_ORIDEP", cDepOriQNC })

				//Busca o grupo de atendimento vinculado ao departamento/setor do QNC.
				If !Empty(cGrpQNC)
					cGrpTMK := Posicione("QAD",1,xFilial("QAD")+cGrpQNC,"QAD_GRPTMK")
				EndIf

				aAdd(aQNCParam, {"QI2_DESDEP", padr(cGrpQNC, TamSx3("QI2_DESDEP")[1]) })
				aAdd(aQNCParam, {"QI2_FILDEP", cFilAnt })

				aAdd(aQNCParam, {"QI2_MAT", cQAACod })
				aAdd(aQNCParam, {"QI2_FILMAT", cFilAnt })

				If ADE->ADE_SEVCOD == "1"	//Requisição de alteração de especificação
					aAdd(aQNCParam, {"QI2_PRIORI"	, "1"})
					aAdd(aQNCParam, {"QI2_TPFIC"	, "3"})		//MELHORIA
				ElseIf ADE->ADE_SEVCOD = '2'
					aAdd(aQNCParam, {"QI2_PRIORI"	, "1"})		//BAIXA
					aAdd(aQNCParam, {"QI2_TPFIC"	, "2"})		//Nao Conformidade
				ElseIf ADE->ADE_SEVCOD = '3'
					aAdd(aQNCParam, {"QI2_PRIORI"	, "2"})		//Prioridade Media
					aAdd(aQNCParam, {"QI2_TPFIC"	, "2"})		//Nao Conformidade
				Else
					aAdd(aQNCParam, {"QI2_PRIORI"	, "3"})		//Prioridade Alta
					aAdd(aQNCParam, {"QI2_TPFIC"	, "2"})		//Nao Conformidade
				EndIf

				aAdd(aQNCParam, {"QI2_STATUS", "3"})	//PROCEDE
				aAdd(aQNCParam, {"QI2_MEMO1", 	MSMM(ADE->ADE_CODINC,TamSx3("ADE_INCIDE")[1])})
				aAdd(aQNCParam, {"QI2_DESCR", 	ADE->ADE_PLVCHV})
				aAdd(aQNCParam, {"QI2_CODORI", 	ADE->ADE_CODORI})
				aAdd(aQNCParam, {"QI2_CODEFE", 	ADE->ADE_CODEFE})
				aAdd(aQNCParam, {"QI2_CODCAT", 	ADE->ADE_CODCAT})
				aAdd(aQNCParam, {"QI2_CODCAU", 	ADE->ADE_CODCAU})
				aAdd(aQNCParam, {"QI2_ANO", ALLTRIM(STR(Year(dDataBase)))})//??????????
				If ADE->ADE_ENTIDA == "SA1"	 //CLIENTES
					aAdd(aQNCParam,{"QI2_CODCLI"	, SUBSTR(ADE->ADE_CHAVE,1,TamSX3("A1_COD")[1])})
					aAdd(aQNCParam,{"QI2_LOJCLI"	, SUBSTR(ADE->ADE_CHAVE,TamSX3("A1_COD")[1]+1,2)})
				EndIf
				Aadd(aQNCParam,{"QI2_ORIGEM"	,"TMK"})

				lGeraFNC := .T.
			Else
				DbSelectArea("ADF")
				DbSetOrder(1)
				If MsSeek(xFilial("ADF")+cCodADE+aColsADF[nItem][nItmPos])
					RecLock("ADF", .F.)
					DbDelete()
					ADF->(MsUnlock())
					Return
				EndIf
			EndIf
		Else
			DbSelectArea("ADE")
			DbSetOrder(1)
			If MsSeek(xFilial("ADE")+cCodADE)
				RecLock("ADE", .F.)
				REPLACE ADE->ADE_CHANEX	WITH M->ADE_CHANEX
				REPLACE ADE->ADE_STATUS	WITH "2"
				REPLACE ADE->ADE_FLCHAN	WITH cFilAnt
				ADE->(MsUnlock())

				//Atualiza a observacao do item do atendimento
				cObsAux := aColsADF[nItem][nObsPos]
				aColsADF[nItem][nObsPos] := STR0058 + M->ADE_CHANEX + STR0059 + CRLF + MSMM(ADE->ADE_CODINC,TamSx3("ADE_INCIDE")[1])		//O seu chamado foi associado ao chamado: XXXXXX, que apresenta a mesma ocorrência já registrada em nossa base.
				aColsADF[nItem][nObsPos] += CRLF + CRLF
			EndIf
			lAvalSLA := .F.

			If nTipoCmpSLA > 0
				Tk510CompSLA(ADE->ADE_CHANEX,ADE->ADE_CODIGO)
			EndIf

		EndIf
	Else
		//Compara SLAs dos chamados associados (com acao preenchida)
		If nTipoCmpSLA > 0 .AND. !Empty(ADE->ADE_CHANEX) .AND. aColsADF[nItem][nOcoPos] == "TMK002"
			Tk510CompSLA(ADE->ADE_CHANEX,ADE->ADE_CODIGO)
		EndIf
	EndIf
Else
	//Compara SLAs dos chamados associados (sem acao preenchida)
	If nTipoCmpSLA > 0 .AND. !Empty(ADE->ADE_CHANEX) .AND. aColsADF[nItem][nOcoPos] == "TMK002"
		Tk510CompSLA(ADE->ADE_CHANEX,ADE->ADE_CODIGO)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no item do chamado                |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ADF")
DbSetOrder(1)
DbSeek(xFilial("ADF")+cCodADE+aColsADF[nItem][nItmPos])

BEGIN TRANSACTION

    aRetRegra := {"",""}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza uma transferencia de area |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ALLTRIM(aColsADF[nItem][nOcoPos]) == "TMK001"
		If Len(aTransfere)>0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se eh para outra filial.  ³
			//³Se sim, cria uma replica do chamado³
			//³na filial destino.                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SU0")
			DbSetOrder(1)
			If MsSeek( xFilial("SU0")+aTransfere[1])
				If 	!Empty(SU0->U0_FILORI) .AND. !Empty(SU0->U0_GRPORI) .AND.	xFilial("SU0")<>SU0->U0_FILORI
                    lAltFil			:= .T.
                    aTransfere[1]	:= SU0->U0_GRPORI
                    cFilTransf		:= SU0->U0_FILORI
				EndIf
			EndIf

			DbSelectArea("ADE")
			DbSetOrder(1)
			If MsSeek(xFilial("ADE")+cCodADE)
				BEGIN TRANSACTION
				RecLock("ADE", .F.)
				REPLACE ADE->ADE_GRUPO 	WITH aTransfere[1]
				REPLACE ADE->ADE_OPERAD	WITH aTransfere[2]
				MsUnlock()
				END TRANSACTION
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se há registro de monitoração para ³
				//³Transferencia de Chamado                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TK510RegMon(	5, 	"ADE")

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o rodizio do operador³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRodizio
				SU7->(dbSetOrder(1))
				SU7->(msSeek(xFilial("SU7") + aTransfere[2] ))
				If SoftLock("SU7")
			    	SU7->U7_DTRODZ  := If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
			    	SU7->U7_HRRODZ	:= StrTran(Time(),":","")
				    SU7->(MsUnlock())
				EndIf
				lRodizio := .F.
			EndIf

		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a reprogramação do chamado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ALLTRIM(aColsADF[nItem][nOcoPos]) == "TMK006"
		lAvalSLA := .F.
		TK510kSave()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desassociacao de chamado:                                    ³
	//³Procura novamente pelo menor SLA entre os chamados associados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ALLTRIM(aColsADF[nItem][nOcoPos]) == "TMK007" .AND. !Empty(cChAnex)

		If nTipoCmpSLA > 0

			nPausedTime := Tk510GetPause(cChAnex,cFilChAnex)

			//Cria lista de chamados associados
			aChamRel	:= Tk510ChFilho(ADE->ADE_CODIGO,xFilial("ADE"))

			//Restaura prazos de SLA anteriores
			Tk510RestSLA(ADE->ADE_CODIGO)

			//Atualiza todos os chamados com o SLA encontrado
			Tk510UpdFilho(aChamRel,ADE->ADE_REGSLA)

		EndIf

	EndIf

	If lGeraFNC
		DbSelectArea("ADE")
		DbSetOrder(1)
		If MsSeek(xFilial("ADE")+cCodADE)
			cGroupAnt := ADE->ADE_GRUPO
			cOperaAnt := ADE->ADE_OPERAD
			RecLock("ADE", .F.)
			REPLACE ADE->ADE_OPERAD	WITH ""
			If !Empty(cGrpTMK)
				REPLACE ADE->ADE_GRUPO 	WITH cGrpTMK
			EndIf
			MsUnlock()
		EndIf
	Else
		DbSelectArea("ADE")
		DbSetOrder(1)
		MsSeek(xFilial("ADE")+cCodADE)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Este ponto de entrada tem a função de permitir ou não o ³
	//³ tratamento do controle de SLA.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAvalSLA .And. lTkAvalSla
		lAvalSLA := ExecBlock("TKAVALSLA",.F.,.F.,{cCodADE})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para controle de SLA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(ADE->ADE_RECORR == "1")
		If lAvalSLA
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza a restauracao do registro de SLA original do chamado.³
			//³Adequacao ao novo modelo de comp. de SLA.                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(ADE->ADE_CHANEX) .AND. !Empty(ADE->ADE_SLAANT)
				TK510SLAAT()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for transferencia, utiliza o grupo de destino para o calculo³
			//³de SLA.                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aTransfere) > 0
				cTargetGroup := aTransfere[1]
			Else
				cTargetGroup := aColsADF[nItem][nGrpPos]
			EndIf

			DbSelectArea("SU9")	// Tabela de Ocorrencias
			SU9->(DbSetOrder(2))
			If	SU9->(DbSeek(xFilial("SU9")+aColsADF[nItem][nOcoPos]) .AND. (SU9->U9_ACAOSLA <> "0")) .OR.;
				(UPPER(aColsADF[nItem][nOcoPos]) == 'TMK001')

				//nCriticidade := TK510Critic()

				cAcaoSLA := If((aColsADF[nItem][nOcoPos] == 'TMK001'),acaoATUALIZAR,SU9->U9_ACAOSLA)

				aSLARegister :=	TK510SLA(;
								cAcaoSLA,;
								nItem,;
								If(lAltFil,cFilTransf,nil),;
								cTargetGroup,;
								nCriticidade,;
								aColsADF[nItem][nItmPos],;
								lReproSLA)

				If Len(aSLARegister) > 0
					DbSelectArea("ADE")		// Chamados de Help Desk
					ADE->(DbSetOrder(1))
					If ADE->(DbSeek(xFilial("ADE")+cCodADE))

						RecLock("ADE", .F.)
						REPLACE ADE->ADE_REGSLA	WITH aSLARegister[1]					//Registro de SLA gerado

						If !Empty(ADE->ADE_CHANEX)
							Tk510Vecto(xFilial("ADE"),cCodADE)
					 	Else

							REPLACE ADE->ADE_DTEXPI	WITH aSLARegister[2]					//Data para expirar SLA
							REPLACE ADE->ADE_HREXPI	WITH aSLARegister[4]				//Hora para expirar o SLA

	 						If TK510NewFields()
								REPLACE ADE->ADE_SESLA	WITH AllTrim(Str(aSLARegister[3]))	//Severidade usada no chamado
							Else
								REPLACE ADE->ADE_SEVSLA	WITH aSLARegister[3]				//Severidade usada no chamado
							EndIf

						EndIf
						//REPLACE ADE->ADE_CRITIC WITH nCriticidade					//Criticidade encontrada pela formula
						MsUnlock()

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Replica SLA alterado para os filhos³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nTipoCmpSLA > 0
							aChamRel := Tk510ChFilho(cCodADE,xFilial("ADE"))
							If Len(aTransfere) > 0
								Tk510UpdFilho(aChamRel,aSLARegister[1],.T.,cFilTransf,.T.)
							Else
								Tk510UpdFilho(aChamRel,aSLARegister[1],.T.)
						    EndIf

						EndIf

					EndIf

					If	cAcaoSLA == acaoINICIAR		// 1
						TK510RegMon(6,"ADE")
					ElseIf	cAcaoSLA == acaoPAUSAR		// 4
						TK510RegMon(7,"ADE")
					ElseIf	cAcaoSLA == acaoFINALIZAR	// 2
						TK510RegMon(8,"ADE")
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If lGeraFNC

		DbSelectArea("ADE")
		DbSetOrder(1)
		If MsSeek(xFilial("ADE")+cCodADE)
			RecLock("ADE", .F.)
			REPLACE ADE->ADE_OPERAD	WITH cOperaAnt
			REPLACE ADE->ADE_GRUPO 	WITH cGroupAnt
			MsUnlock()
		EndIf

		aAdd(aQNCParam, {"QI2_CONPRE", 	ADE->ADE_DTEXPI })
		If !lAut1
			MsgRun(STR0005,"", {|| aRetQNCGera:= QNCGera(	1,;		//1- Inclusao // "Aguarde...Criando FNC"
														aQNCParam,;	//2- Lista de parametros do QNC
														,;   		//3- Habilidade
														cCodADE) } )//4- Cod. Chamado
		Else
			aRetQNCGera:= QNCGera(1,aQNCParam,,cCodADE)
		ENdif

		If Len(aRetQNCGera)>=2  .AND. !Empty(aRetQNCGera[2])
			DbSelectArea("ADE")
			DbSetOrder(1)
			If MsSeek(xFilial("ADE")+cCodADE)
				RecLock("ADE", .F.)
				REPLACE ADE->ADE_OPERAD	WITH ""
				If !Empty(cGrpTMK)
					REPLACE ADE->ADE_GRUPO 	WITH cGrpTMK
				EndIf
				REPLACE ADE->ADE_FNCFIL WITH aRetQNCGera[1]
				REPLACE ADE->ADE_FNC	WITH aRetQNCGera[2]
				REPLACE ADE->ADE_FNCREV	WITH aRetQNCGera[3]
				REPLACE ADE->ADE_CHANEX	WITH ""
				REPLACE ADE->ADE_FLCHAN	WITH ""
				MsUnlock()
			EndIf

			DbSelectArea("ADF")
			DbSetOrder(1)
			If MsSeek(xFilial("ADF")+cCodADE+aColsADF[nItem][nItmPos])
				RecLock("ADF", .F.)
				REPLACE ADF->ADF_FNC	WITH aRetQNCGera[2]
				REPLACE ADF->ADF_FNCREV	WITH aRetQNCGera[3]
				MsUnlock()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se há registro de monitoração para ³
			//³Abertura de FNC                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TK510RegMon(	4, 	"ADE")


			If Empty(cQAACod)
				Help( " ",1,"TKNUSUQNC")
			EndIf
		Else
			DisarmTransaction()
			Help( " ",1,"QNCGERA",,STR0008 + CRLF + STR0009 + CRLF + STR0010,1,1)	 //"Não foi possivel criar a Ficha" # "de não conformidade.     " # "Por favor, tente novamente.   "
			If lMsErroAuto
				Mostraerro()
			EndIf
			cObsAux := aColsADF[nItem][nObsPos]
			aColsADF[nItem][nObsPos] := STR0011 //"Não foi possivel criar a Ficha de não conformidade - QNCGera()"
			aColsADF[nItem][nObsPos] += CRLF + CRLF

			If !Empty(cObsAux)
				aColsADF[nItem][nObsPos] += STR0007 + cObsAux				//"Comentario Analista:"
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava campos MEMO      |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("ADF")
	DbSetOrder(1)
	If DbSeek(xFilial("ADF")+cCodADE+aColsADF[nItem][nItmPos])
		RecLock("ADF", .F.)
		If !Empty(ADF->ADF_CODOBS)
			MSMM(ADF->ADF_CODOBS,TamSx3("ADF_OBS")[1],,aColsADF[nItem][nObsPos],1,,,"ADF","ADF_CODOBS")
		ElseIf Empty(ADF->ADF_CODOBS) .And. !Empty(aColsADF[nItem][nObsPos])
			MSMM(,TamSx3("ADF_OBS")[1],,aColsADF[nItem][nObsPos],1,,,"ADF","ADF_CODOBS")
		EndIf
		Replace ADF->ADF_FILORI	With cFilOri

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso seja associacao de chamados ³
		//³Grava os campos para historico   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ALLTRIM(aColsADF[nItem][nOcoPos]) == "TMK002"
			ADF->ADF_FILASS := ADE->ADE_FLCHAN
			ADF->ADF_CODASS := ADE->ADE_CHANEX
		EndIf

		MsUnlock()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza contador de chamados associados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TK510CONT(cCodADE)

	If !(IsInCallStack("TKUPDCALL")) .OR. (ALLTRIM(aColsADF[nItem][nOcoPos]) == "TMK002")

		cFlChan := ADE->ADE_FLCHAN

		If !Empty(cCHPai)

			TK510CONT(cCHPai,cFlChan)

		ElseIf (ALLTRIM(aColsADF[nItem][nOcoPos]) == "TMK007" .AND. !Empty(cChAnex))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento realizado para chamada no momento da³
			//³desassociacao                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TK510CONT(cChAnex,cFlChan)

		EndIf

    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa ponto de entrada para validar o envio do workflow.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTKENVWOR
		If !ExecBlock("TKENVWOR",.T.,.T.)
			lEnvWorkflow := .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se esta habilitado o envio de workflow ³
	//³a partir do chamado filho.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	!Empty(ADE->ADE_CHORIG) .AND.;
		!SuperGetMv("MV_TKNOTWF",,.T.)
	 	lEnvWorkflow := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa rotina de envio de workflow         |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cCodWFTemplate) .And. lEnvWorkflow
		//Envio de workflow pelo ECM (integracao)
		If FunName() $ "TMKA503A|TMKA510A"
			aAdd(aRegsWF,{cCodWFTemplate,cCodADE,aColsADF[nItem][nItmPos]})
		Else
			Tk510WF(cCodWFTemplate,cCodADE,aColsADF[nItem][nItmPos])
		EndIf
	EndIf

END TRANSACTION

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o que deve ser executado pela acao |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SUQ")
DbSetOrder(1)
If !Empty(aColsADF[nItem][nActPos]) .AND. MsSeek(xFilial("SUQ")+aColsADF[nItem][nActPos])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria os chamados compartilhados              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SUQ->UQ_COMPART $ "13"
		lCompartilhou := .T.
		Tk510IComp(@aColsADF[nItem][nObsPos])
	EndIf
EndIf

If SUQ->UQ_REPLICA == "1" .AND. (AllTrim(SUQ->UQ_SOLUCAO) == AllTrim(aColsADF[nItem][4]))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Evita que a rotina entre em Loop³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SUQ->UQ_COMPART $ "1|3"
		cActionBkp := aColsADF[nItem][nActPos]
		aColsADF[nItem][nActPos] := ""
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Replicacao de informacoes em chamados associados  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !Empty(cCodADE)

		DbSelectArea("ADE")
		DbSetOrder(4) //ADE_FILIAL+ ADE_CHANEX
		aFiliais 	:= Tk510Filiais()
		cFilBkp		:= cFilAnt
		cOperRep	:= TkOperador()
		For nFil := 1 to Len(aFiliais)
			cFilAnt := aFiliais[nFil]
			MsSeek(xFilial("ADE")+cCodADE)
			While 	!ADE->(EOF()) 						.AND.;
					ADE->ADE_FILIAL == xFilial("ADE") 	.AND.;
					ADE->ADE_CHANEX == cCodADE
				lReplica := .T.
				If lTKREPLICA
					lRetReplica := ExecBlock("TKREPLICA", .F., .F., {cCodADE, ADE->ADE_CODIGO})
					If ValType(lRetReplica)=="L"
						lReplica := lRetReplica
					EndIf
				EndIf
				If lReplica
					If !lAut1
						MsgRun(STR0056, STR0057, {||TkUpdCall(	/*cFil */,;							// "Replicando informações para chamados associados" # "Aguarde"
															aColsADF[nItem][nActPos]/*cCodAction*/,;
															/*cCodReview*/,;
															aColsADF[nItem][nObsPos],;
															/*cTPACAO*/,;
															cOperRep,;
															aColsADF[nItem][nGrpPos],;
															cStatus,;
															/*dPrazo*/,;
															dRealiz,;
															ADE->ADE_CODIGO,;
															aColsADF[nItem][nOcoPos],,,.T.,.T.,.T.,If(cFilAnt<>cFilBkp,cFilBkp,cFilAnt),,aRegsWF)})
					Else
						TkUpdCall(	/*cFil */,aColsADF[nItem][nActPos]/*cCodAction*/,/*cCodReview*/,aColsADF[nItem][nObsPos],;
									/*cTPACAO*/,cOperRep,aColsADF[nItem][nGrpPos],cStatus,/*dPrazo*/,dRealiz,ADE->ADE_CODIGO,;
									aColsADF[nItem][nOcoPos],,,,,,If(cFilAnt<>cFilBkp,cFilBkp,cFilAnt),,aRegsWF)
					Endif
					If lTKATURPL
						ExecBlock("TKATURPL", .F., .F., {cCodADE, ADE->ADE_CODIGO})
					EndIf
				EndIf
				ADE->(DbSkip())
			End
	    Next nFil
	    cFilAnt := cFilBkp
	EndIf

	// Verifica para quem é a réplica (Relação de Compartilhamento), por padrão a réplica é somente para o pai.
	If SUQ->UQ_REPLDES == "2" .Or. Empty(SUQ->UQ_REPLDES)
		lToFather	:= IF( lCancelFatherReplication, .F., .T. )
		lToSon		:= .F.
	ElseIf SUQ->UQ_REPLDES == "1"
		lToFather	:= .F.
		lToSon		:= IF( lCancelSonReplication, .F., .T. )
	ElseIf SUQ->UQ_REPLDES == "3"
		lToFather	:= IF( lCancelFatherReplication, .F., .T. )
		lToSon		:= IF( lCancelSonReplication, .F., .T. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Replica os dados para o chamado original ou para os chamados filhos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("ADE")
	DbSetOrder(1)
	MsSeek(xFilial("ADE")+cCodADE)

	If !Empty(cCodADE)

		// Atualiza o chamado pai
		If lToFather .AND. !Empty(ADE->ADE_CHORIG)

			// Se o chamado pai for de outra filial, configura a filial corretamente.
			lReplicaFilial := .F.
			cFilAntBkp	:= Space(FWGETTAMFILIAL)
			If  !Empty(ADE->ADE_FILORI) .AND.;
				ADE->ADE_FILORI <> cFilAnt

				cFilAntBkp := cFilAnt
				lReplicaFilial := .T.
				cFilAnt := ADE->ADE_FILORI
			EndIf

			lReplica := .T.

	     	If lTKREPPAI
				lRetReplica := ExecBlock("TKREPPAI",.F.,.F.,{ADE->ADE_CHORIG})
				If ValType(lRetReplica) == "L"
					lReplica := lRetReplica
				EndIf
	   		EndIf

		    If lReplica
				// Se encontrar o chamado replica o item
				DbSetOrder(1) //ADE_FILIAL+ADE_CODIGO
				If MsSeek(xFilial("ADE") + ADE->ADE_CHORIG)
					TkUpdCall(	/*cFil */,;
								aColsADF[nItem][nActPos]/*cCodAction*/,;
								/*cCodReview*/,;
								aColsADF[nItem][nObsPos],;
								cTPACAO,;
								cCodOper,;
								aColsADF[nItem][nGrpPos],;
								cStatus,;
								/*dPrazo */,;
								dRealiz,;
								ADE->ADE_CODIGO,;
								aColsADF[nItem][nOcoPos],;
								,;
								,;
								.T.,;
								.T.,;
								,;
								If(cFilAnt<>cFilBkp,cFilBkp,cFilAnt),;
								,;
								aRegsWF)
				EndIf
			EndIf

			If lReplicaFilial
				lReplicaFilial := .F.
				cFilAnt := cFilAntBkp
			EndIf
		EndIf

		// Atualiza os chamados filhos
		If lToSon
			// Cria a lista de chamados a terem o item a ser replicado adicionado
			aList := {}

			// Localiza os chamados filhos na filial atual
			ADE->(DbSetOrder(21)) // ADE_FILIAL+ADE_CHORIG
			If MsSeek( xFilial("ADE") + cCodADE )
				While 	ADE->ADE_FILIAL + ADE->ADE_CHORIG == xFilial("ADE") + cCodADE .And.;
						ADE->(!EOF())
					aAdd( aList, { xFilial( "ADE" ), ADE->ADE_CODIGO } )
					ADE->(DbSkip())
				End
			ENdIf

			// Localiza os chamados filhos em outras filiais
			DbSelectArea( "SX1" )
			DbSetOrder( 1 )
			DbSelectArea("SM0")
			aAreaSM0 := SM0->(GetArea())
			SM0->( DbSetOrder( 1 ) )
			If SM0->( DbSeek( cEmpAnt ) )
				While SM0->( !Eof() ) .AND. SM0->M0_CODIGO == cEmpAnt
					cFilSM0 := Left(SM0->M0_CODFIL,nTamFil)
					If cFilSM0 <> cFilAnt
						DbSelectArea( "ADE" )
						DbSetOrder( 22 ) // ADE_FILIAL+ADE_FILORI+ADE_CHORIG
						If ADE->( DbSeek( cFilSM0 + xFilial("ADE") + cCodADE ) )
							While ADE->(!EOF()) .AND. ADE->ADE_CHORIG == cCodADE .AND. ADE->ADE_FILORI == xFilial("ADE")
								aAdd( aList, { cFilSM0, ADE->ADE_CODIGO } )
								ADE->(DbSkip())
							End
						EndIf
					EndIf
					SM0->(DbSkip())
				End
			EndIf
			RestArea(aAreaSM0)

			// Para todos os chamados filhos encontrados
			For nCount := 1 To Len( aList )
				lReplicaFilial := .F.
				If cFilAnt <> aList[nCount][1]
					cFilAntBkp := cFilAnt
					lReplicaFilial := .T.
					cFilAnt := aList[nCount][1]
				EndIf

				lReplica := .T.

		     	If lTKREPFILHO
					lRetReplica := ExecBlock("TKREPFILHO",.F.,.F.,{aList[nCount][2]})
					If ValType(lRetReplica) == "L"
						lReplica := lRetReplica
					EndIf
		   		EndIf

				If lReplica
					// Se encontrar o chamado replica o item
					DbSelectArea( "ADE" )
					DbSetOrder( 1 )
					If ADE->(DbSeek( aList[nCount][1] + aList[nCount][2] ) )
						TkUpdCall(	/*cFil */,;
									aColsADF[nItem][nActPos]/*cCodAction*/,;
									/*cCodReview*/,;
									aColsADF[nItem][nObsPos],;
									cTPACAO,;
									cCodOper,;
									aColsADF[nItem][nGrpPos],;
									cStatus,;
									/*dPrazo */,;
									dRealiz,;
									ADE->ADE_CODIGO,;
									aColsADF[nItem][nOcoPos],;
									,;
									,;
									.T.,;
									,;
									.T.,;
									If(cFilAnt<>cFilBkp,cFilBkp,cFilAnt),;
									,;
									aRegsWF)
					EndIf
				EndIf

				If lReplicaFilial
					cFilAnt := cFilAntBkp
				EndIf
			Next
		EndIf
	EndIf

	If SUQ->UQ_COMPART $ "1|3"
		aColsADF[nItem][nActPos] := cActionBkp
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona no atendimento atual³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("ADE")
	DbSetOrder(1)
	MsSeek(xFilial("ADE")+cCodADE)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transfere o chamado de filial³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAltFil
	Tk510TrFil(cCodADE,cFilTransf)
EndIf

// Projeto TDI TEGJD7 - Atualizacao do recurso atual no chamado
// nao deve executar se nao esta gerando FNC
QNCGRVOPE(lGerafnc)  // continda no QNCXFUN

RestArea(aAreaADE)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMK510CRGIT   ºAutor  ³Venda Cliente   º Data ³  22/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao utilizada na selecao de dados do atendimento.  	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510CRGIT()
Local nItem 		:= 0
Local nObsPos 		:= 0	//ADF_OBS
Local nOcoPos 		:= 0   	//ADF_CODSU9
Local nOcoDescPos 	:= 0   	//ADF_NMSU9
Local nActPos 		:= 0	//ADF_CODSUQ
Local nActDescPos 	:= 0	//ADF_NMSUQ
Local nOpePos 		:= 0	//ADF_CODSU7
Local nOpeDescPos 	:= 0	//ADF_NMSU7
Local nGrpPos		:= 0	//ADF_CODSU0
Local nGrpDescPos 	:= 0	//ADF_NMGRUP
Local nCpos         := 0    //linha do acols
Local bAuxAdd				//Armazena o CodeBlock para adicao da GetDados
Local bAuxChg				//Armazena o CodeBlock para alteracao da GetDados
Local lTK510INIT	:= ExistBlock("TK510INIT")  //Ponto de Entrada executado no inicio do atendimento
Local lDisableObj	:= .F.	//Indica se a tela de atendimento estará desabilitada.
Local lOpenWin		:= .T.	//Indica se a tela sera aberta
Local cGrupo		:= ""
Local aCpoVirt      := {}
Local cFilAtu		:= cFilAnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso seja uma inclusao, nao ha dados para serem carregados da SYP |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ParamIXB[3]!=3
	For nItem:=1 To Len(ParamIXB[1])
		If AllTrim(ParamIXB[1][nItem][2]) == "ADF_OBS" .AND. ParamIXB[1][nItem][8]=="M"
			nObsPos := nItem
		EndIf
		If AllTrim(ParamIXB[1][nItem][2]) == "ADF_CODSU9"
			nOcoPos := nItem
		EndIf
		If AllTrim(ParamIXB[1][nItem][2]) == "ADF_NMSU9"
			nOcoDescPos := nItem
		EndIf
		If AllTrim(ParamIXB[1][nItem][2]) == "ADF_CODSUQ"
			nActPos := nItem
		EndIf
		If AllTrim(ParamIXB[1][nItem][2]) == "ADF_NMSUQ"
			nActDescPos := nItem
		EndIf
		If AllTrim(ParamIXB[1][nItem][2]) == "ADF_CODSU7"
			nOpePos := nItem
		EndIf
		If AllTrim(ParamIXB[1][nItem][2]) == "ADF_NMSU7"
			nOpeDescPos := nItem
		EndIf
		If AllTrim(ParamIXB[1][nItem][2]) == "ADF_CODSU0"
			nGrpPos := nItem
		EndIf
		If AllTrim(ParamIXB[1][nItem][2]) == "ADF_NMGRUP"
			nGrpDescPos := nItem
		EndIf

		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek(AllTrim(ParamIXB[1][nItem][2])) .And. X3_PROPRI == "U" .And. X3_CONTEXT == "V"
			aAdd(aCpoVirt,{nItem,X3_RELACAO})
		EndIf
	Next nItem

	DbSelectArea("ADF")

	For nItem:=1 To Len(ParamIXB[2])
		If nObsPos > 0
			DbSelectArea("ADF")
			DbGoTo(ParamIXB[2][nItem][Len(ParamIXB[2][nItem])-1])
			ParamIXB[2][nItem][nObsPos] := MSMM(ADF->ADF_CODOBS,TamSx3("ADF_OBS")[1])
		EndIf
		If nOcoPos > 0 .AND. nOcoDescPos > 0
			If ALLTRIM(ParamIXB[2][nItem][nOcoPos]) $ TK510_DEFAULTS
				ParamIXB[2][nItem][nOcoDescPos] := Tk510DefOcName(ALLTRIM(ParamIXB[2][nItem][nOcoPos]))
			Else
				If !Empty(ADF->ADF_FILORI) .AND. (cFilAnt <> ADF->ADF_FILORI) .AND.;
					(FWModeAccess("SU9",1) == "E" .OR. FWModeAccess("SU9",2) == "E" .OR. FWModeAccess("SU9",3) == "E" )
					cFilAnt := ADF->ADF_FILORI
				EndIf
				ParamIXB[2][nItem][nOcoDescPos] := POSICIONE("SU9", 2, xFilial("SU9")+ParamIXB[2][nItem][nOcoPos],"U9_DESC")
				cFilAnt := cFilAtu
			EndIf
		EndIf
		If nActPos > 0 .AND. nActDescPos > 0
			If !Empty(ADF->ADF_FILORI) .AND. (cFilAnt <> ADF->ADF_FILORI) .AND.;
				(FWModeAccess("SUQ",1) == "E" .OR. FWModeAccess("SUQ",2) == "E" .OR. FWModeAccess("SUQ",3) == "E" )
				cFilAnt := ADF->ADF_FILORI
			EndIf
			ParamIXB[2][nItem][nActDescPos] := POSICIONE("SUQ", 1, xFilial("SUQ")+ParamIXB[2][nItem][nActPos],"UQ_DESC")
			cFilAnt := cFilAtu
		EndIf
		If nOpePos > 0 .AND. nOpeDescPos > 0
			If !Empty(ADF->ADF_FILORI)	.AND. (cFilAnt <> ADF->ADF_FILORI) .AND.;
				(FWModeAccess("SU7",1) == "E" .OR. FWModeAccess("SU7",2) == "E" .OR. FWModeAccess("SU7",3) == "E" )
				cFilAnt := ADF->ADF_FILORI
			EndIf
			ParamIXB[2][nItem][nOpeDescPos] := POSICIONE("SU7",1,XFILIAL("SU7") + ParamIXB[2][nItem][nOpePos], "U7_NOME")
			cFilAnt := cFilAtu
		EndIf
		If nGrpPos > 0 .AND. nGrpDescPos > 0
			If !Empty(ADF->ADF_FILORI) .AND. (cFilAnt <> ADF->ADF_FILORI) .AND.;
				(FWModeAccess("SU0",1) == "E" .OR. FWModeAccess("SU0",2) == "E" .OR. FWModeAccess("SU0",3) == "E" )
				cFilAnt := ADF->ADF_FILORI
			EndIf
			ParamIXB[2][nItem][nGrpDescPos] := POSICIONE("SU0",1,xFilial("SU0")+ParamIXB[2][nItem][nGrpPos],"U0_NOME")
			cFilAnt := cFilAtu
		EndIf

		If Len(aCpoVirt)>0
			For nCpos:=1 To Len(aCpoVirt)
				ParamIXB[2][nItem][aCpoVirt[nCpos][1]]:= &(aCpoVirt[nCpos][2])
			Next nCpos
		Endif
	Next nItem

	M->ADE_INCIDE := MSMM(M->ADE_CODINC,TamSx3("ADE_INCIDE")[1])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ha outro analista manipulando o mesmo chamado      	  |
	//³ So libera se o analista estiver ha mais de 2 horas alocado.    	  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ParamIXB[3]==4
		If !TK510UsrLock("L", M->ADE_CODIGO, TkOperador())
			lDisableObj := .T.

			If Type("INCLUI") == "L"
				INCLUI := .F.
			EndIf
			If Type("ALTERA") == "L"
				ALTERA := .F.
			EndIf
		EndIf
	EndIf
    M->ADE_OBSMEM := MSMM(M->ADE_CODOBS,TamSx3("ADE_OBSMEM")[1])
EndIf

aTransfere 	:= {}
cIncMemo 		:= ""
lCompartilhou	:= .F.
lRodizio 		:= .F.
cIncOBS 		:= ""
aRecorrencia	:= {M->ADE_CODIGO,AllTrim(M->ADE_STRREC),M->ADE_DATA,AllTrim(M->ADE_STRREC)}

ParamIXB[4]:oBrowse:nOpc := 2
bAuxChg := ParamIXB[4]:oBrowse:bChange
ParamIXB[4]:oBrowse:bChange := {||Eval(bAuxChg),Tk510ChgGet(oGetd)}
bAuxAdd := ParamIXB[4]:oBrowse:bAdd
ParamIXB[4]:oBrowse:bAdd := { || Eval(bAuxAdd),Tk510ChgGet(oGetd)}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se um chamado encerrado poderá ser reaberto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->ADE_STATUS == "3" .And. ParamIXB[3] <> 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura pelo Operador para saber qual o Grupo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SU7")
	DbSetOrder(1)
	If MsSeek(xFilial("SU7") + TkOperador())
		cGrupo:= SU7->U7_POSTO
	Else
		cGrupo:= SuperGetMV("MV_POSTO")
	Endif

	If Tk510ChEncerra(M->ADE_CODIGO, cGrupo)

		Help(" ",1,"ENCERRAHD")
		If ParamIXB[3]==4
			//lDisableObj := .T.
			lOpenWin := .F.
		EndIf
	Else
		Help(" ",1,"REABREHD")
		M->ADE_STATUS := "1"
		M->ADE_OPERAD := TkOperador()
		M->ADE_NMOPER := POSICIONE('SU7',1,XFILIAL('SU7') + M-> ADE_OPERAD, 	'U7_NOME')
		M->ADE_GRUPO  := cGrupo
		M->ADE_DESCGP := POSICIONE('SU0',1,XFILIAL('SU0') + M->ADE_GRUPO,		'U0_NOME')
	EndIf
EndIf

If lDisableObj
	ParamIXB[4]:Disable()
	ParamIXB[7]:Disable()
EndIf

If Type("M->ADE_TIPPRF") == "C"
	If !Empty(M->ADE_TIPPRF)
		Help('',1,'Service Desk',, Tk510PrfDesc(M->ADE_ENTIDA, M->ADE_CHAVE, 1) + CRLF + Tk510PrfDesc(M->ADE_ENTIDA, M->ADE_CHAVE, 2), 1,0)
	EndIf
EndIf

If lTK510INIT
	ExecBlock("TK510INIT",.F.,.F., {ParamIXB[3]})
EndIf

Return lOpenWin

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510ChEncerraºAutor  ³Venda Cliente   º Data ³  03/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o chamado ja ultapassou o prazo para Reabertura.º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510ChEncerra(cCodChama, cGrupo)
Local lRet := .T.
Local aAreaSU0 := SU0->(GetArea())
Local aAreaADF := ADF->(GetArea())
Local aAreaSUQ := SUQ->(GetArea())
Local cDiffTime := 0
Local dDtEncerra := If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o campo do Posto de Venda que foi solicitado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU0")
DbSetOrder(1)
If 	!Empty(cGrupo) 						.AND.;
	MsSeek(xFilial("SU0") + cGrupo)  	.AND.;
	SU0->U0_REABCHA $ "|2|3|4|5|6|7|8|"

	If SU0->U0_REABCHA <> "8"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem a data da última interação que encerrou o chamado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("ADF")
		DbSetOrder(1)  // ADF_FILIAL+ADF_CODIGO+ADF_ITEM
		If MsSeek(xFilial("ADF")+cCodChama)
			While ADF->(!EOF()) .AND.;
				ADF->ADF_CODIGO == cCodChama

				If 	(!Empty(ADF->ADF_CODSUQ) .AND.;
					 SUQ->(MsSeek( xFilial("SUQ")+ADF->ADF_CODSUQ )) .AND. SUQ->UQ_STATCH == "3")

					dDtEncerra := ADF->ADF_DATA
				EndIf
				ADF->(DbSkip())
			End

		EndIf

		cDiffTime := If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )-dDtEncerra
		If SU0->U0_REABCHA == "2"
			If cDiffTime <= 1
				lRet := .F.
			EndIf
		ElseIf SU0->U0_REABCHA == "3"
			If cDiffTime <= 2
				lRet := .F.
			EndIf
		ElseIf SU0->U0_REABCHA == "4"
			If cDiffTime <= 4
				lRet := .F.
			EndIf
		ElseIf SU0->U0_REABCHA == "5"
			If cDiffTime <= 8
				lRet := .F.
			EndIf
		ElseIf SU0->U0_REABCHA == "6"
			If cDiffTime <= 15
				lRet := .F.
			EndIf
		ElseIf SU0->U0_REABCHA == "7"
			If cDiffTime <= 30
				lRet := .F.
			EndIf
		ElseIf SU0->U0_REABCHA == "8"
			lRet := .F.
		EndIf

	Else
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaSU0)
RestArea(aAreaADF)
RestArea(aAreaSUQ)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK510UsrLock³ Autor ³ Vendas Clientes    ³ Data ³ 15/08/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se permite alteração do getdados de atendimento.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºSintaxe   ³ TK510UsrLock(cTipo, cCod, cOper)							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³	cTipo = Comando, sendo:									  º±±
±±º          ³	"L" - Bloqueia o chamado                  				  º±±
±±º          ³	"U" - Desbloqueia o chamado               				  º±±
±±º          ³	                            							  º±±
±±º          ³	cCod  = Codigo do chamado   							  º±±
±±º          ³	cOper = Codigo do operador  							  º±±
±±º          ³	lMsg  = Exibe a janela de aviso							  º±±
±±º          ³	lVisualiza = Controla a visualizacao 						º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Resultado do comando                                       º±±
±±º          ³															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Uso       ³ Help Desk                                        		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510UsrLock(cTipo, cCod, cSU7, lMsg, lVisualiza)
Local lRet 			:= .F.
Local nTimeDiff 	:= 0	//Tempo desde que o chamado foi iniciado por outro operador
Local cCurrOper		:= cSU7	//Operador Atual
Local aArea			:= GetArea()
Local lLocked		:= .F.
Local nTmpMinCh		:= SuperGetMv("MV_TMKTPCH",,60)  

DEFAULT lMsg 	:= .T.
DEFAULT lVisualiza := .T.

If Upper(cTipo) == "L"
	lLocked	  := ADE->(SimpleLock())
	nTmpMinCh := IIf(nTmpMinCh < 1,1,nTmpMinCh)
	nTimeDiff := Seconds() - ADE->ADE_SECUSO
	nTimeDiff /= 60
	If  lLocked .AND.;
		Empty(ADE->ADE_OPEUSO) .OR.;
	 	Iif(!(Type("lTk503Auto") <> "U" .And. lTk503Auto),ADE->ADE_OPEUSO==cCurrOper,.F.) .OR.;
		ADE->ADE_DATUSO < If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ) .OR.;
		(nTimeDiff > 0 .AND. nTimeDiff > nTmpMinCh)
		DbSelectArea("ADE")
		DbSetOrder(1)
		If dbSeek(xFilial("ADE")+cCod) .AND. ADE->(!EOF())
			BEGIN TRANSACTION
				RecLock("ADE", .F.)
				REPLACE ADE->ADE_OPEUSO WITH cCurrOper
				REPLACE ADE->ADE_SECUSO WITH Seconds()
				REPLACE ADE->ADE_DATUSO WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
				ADE->(MsUnlock())
				END TRANSACTION
				lRet := .T.
			EndIf
	Else
		ADE->(MsUnlock())
		If !( Type("lTk503Auto") <> "U" .AND. lTk503Auto ) .AND. lMsg
			If Aviso(STR0012,; //"Help Desk"
						STR0013 + Chr(10)+Chr(13)+""+Chr(10)+Chr(13)+; //"Este chamado encontra-se em atendimento pelo Analista - "
						ADE->ADE_OPEUSO+" - " + FATPDObfuscate(AllTrim(Posicione("SU7", 1, xFilial("SU7")+ADE->ADE_OPEUSO, "U7_NOME")),"U7_NOME",,.T.) +Chr(10)+Chr(13)+; // nome do usuario
						Chr(10)+Chr(13)+STR0190 ,;  		// "Deseja visualizar o chamado ?"
						{STR0182,STR0183},3,STR0016) == 2	// "Atenção"

				lRet := lVisualiza := .F.
			Endif
		ElseIf ( Type("lTk503Auto") <> "U" .AND. lTk503Auto )
			//Se for rotina automática, faz a gravação do log.
			AutoGRLog(STR0135)	//"Chamado não processado, pois encontra-se em atendimento."
		EndIf
	EndIf

	FATPDLogUser("TK510USRLO")  

ElseIf Upper(cTipo) == "U"
	DbSelectArea("ADE")
	DbSetOrder(1)
	If dbSeek(xFilial("ADE")+cCod) .AND. ADE->(!EOF())
		If 	!Empty(ADE->ADE_OPEUSO) .AND.;
			ADE->ADE_OPEUSO==cCurrOper
			BEGIN TRANSACTION
				RecLock("ADE", .F.)
				REPLACE ADE->ADE_OPEUSO WITH ""
				REPLACE ADE->ADE_SECUSO WITH Seconds()
				REPLACE ADE->ADE_DATUSO WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
				MsUnlock()
			END TRANSACTION
			lRet := .T.
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK510ChgGet ³ Autor ³ Vendas Clientes    ³ Data ³ 25/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se permite alteração do getdados de atendimento.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Help Desk                                        		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510ChgGet(oGetd)
Local nHeader 	:= 0 	//Auxiliar usado em Loop
Local nPosRecNo	:= 0	//Armazena a posicao do RecNo no aHeader
Local nPosCodSU7:= 0	//Armazena a posicao do Codigo do Analista  no aHeader
Local nPosCodSU9:= 0 	//Armazena a posicao do Codigo da Ocorrencia no aHeader
Local cEditType := SuperGetMv("MV_TMKEDI",,"1")		//Indica o tipo de edicao que sera utilizado pelo sistema de help desk (1-Tudo/2-Novo/3-Novo+usuario)

If INCLUI .OR. ALTERA

	For nHeader := 1 To Len(oGetd:aHeader)
		If IsHeadRec(oGetd:aHeader[nHeader,2])
			nPosRecNo := nHeader
		ElseIf AllTrim(oGetd:aHeader[nHeader,2]) == "ADF_CODSU7"
			nPosCodSU7 := nHeader
		ElseIf AllTrim(oGetd:aHeader[nHeader,2]) == "ADF_CODSU9"
			nPosCodSU9 := nHeader
		EndIf
	Next nHeader

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite alterar e inserir registros inseridos pelo sistema    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//If !(aCols[oGetd:oBrowse:nAt][nPosCodSU9] $ TK510_DEFAULTS)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permite alterar e inserir registros no chamado                    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cEditType == "1"
		oGetd:oBrowse:nOpc := 3
	Else
		oGetd:oBrowse:nOpc := 4
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Permite apenas inserir registros no chamado                    	 |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cEditType == "2"
			If nPosRecNo > 0
				If oGetd:aCols[oGetd:oBrowse:nAt][nPosRecNo] == 0 // Novo registro
					oGetd:oBrowse:aAlter := aAlterADF
			   		oGetd:lDelete := .T.
			   		oGetd:lInsert := .T.
			   		oGetd:lUpdate := .T.
				Else
			   		oGetd:lDelete := .F.
			   		oGetd:lInsert := .T.
			   		oGetd:lUpdate := .F.
				EndIf
			EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Permite alterar e inserir registros no chamado do proprio analista|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf cEditType == "3"
		   	If nPosCodSU7 > 0
		   		If oGetd:aCols[oGetd:oBrowse:nAt][nPosRecNo] >= 0 .And. oGetd:aCols[oGetd:oBrowse:nAt][nPosCodSU7] == TkOperador()
					oGetd:oBrowse:aAlter := aAlterADF
			   		oGetd:lDelete := .T.
			   		oGetd:lInsert := .T.
			   		oGetd:lUpdate := .T.
		   		Else
			   		oGetd:lDelete := .F.
			   		oGetd:lInsert := .T.
			   		oGetd:lUpdate := .F.
		   		EndIf
		   	EndIf
		EndIf
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK510OcoTmk ³ Autor ³ Vendas Clientes    ³ Data ³ 25/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o do OCORRENCIA Informado na getdados HelpDesk     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Help Desk                                        		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510OcoTmk(cOperador,lLote)
Local lRet	   		:= .T.				 									//Retorno da funcao
Local aArea	   		:= GetArea()		 									//Salva a area atual
Local nPOcorren		:= 0				 									//Ocorrencia
Local nPDescOco		:= 0				 									//Descricao da Ocorrencia
Local cAuxiliar		:=  &( ReadVar() )	   									//Le o conteudo da getdados do campo UD_OCORREN
Local lManipSLA		:= .F.				  									//Indica se a ocorrencia manipula SLA
Local nItem																	//Utilizado em loop
Local nPosOBS  		:= aScan(aHeader, {|x| AllTrim(x[2]) == "ADF_OBS"})	//Indica a posição da observação no array
Local nTipoCmpSLA	:= SuperGetMV("MV_TMKASLA",,0)					   		//Tipo de comparacao de SLAs
Local lTk510OcSLA	:= Existblock("TKOCOSLA") 								//Ponto de entrada para permitir utilizar
Local lAvalTpAcao	:= .T.													//Indica se vai avaliar o tipo de acao de SLA na ocorrencia

Default lLote := .F.

If !lLote
	For nItem:=1 To Len(aHeader)
		If AllTrim(aHeader[nItem][2]) == "ADF_CODSU9"
			nPOcorren := nItem
		EndIf
		If AllTrim(aHeader[nItem][2]) == "ADF_NMSU9"
			nPDescOco := nItem
		EndIf
	Next nItem
EndIf

If !Empty(M->ADF_CODSU9)
	DbSelectarea("SU9")
	DbSetorder( 1 )
	If MsSeek( xFilial("SU9")+M->ADE_ASSUNT+cAuxiliar ) .And. !lLote

		aCols[n][nPOcorren] := SU9->U9_CODIGO
		If nPDescOco > 0
			aCols[n][nPDescOco] := SU9->U9_DESC
		Endif
		lManipSLA := SU9->U9_ACAOSLA $ "1234"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Permite ocultar a mensagem e liberar o uso da ocorrencia³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lManipSLA .AND. lTk510OcSLA
			lAvalTpAcao := ExecBlock("TKOCOSLA", .F., .F., {SU9->U9_CODIGO})
			If ValType(lAvalTpAcao)<>"L"
				lAvalTpAcao := .T.
			EndIf
		EndIf

	ElseIf !Found() .AND. !AllTrim(M->ADF_CODSU9) $ TK510_DEFAULTS
		Help(" ",1,"OCORRENCIA")
		lRet := .F.
	Endif
Else
	aCols[n][nPDescOco] := Space(TamSX3("ADF_NMSU9")[1])
Endif

If !lLote
	DbSelectArea("SUX")
	DbSetOrder(1)
	SUX->(DbSeek(xFilial("SUX") + SU9->U9_TIPOOCO))
	If !Empty(SUX->UX_TEXTO)
		If SUX->UX_HABTXT == "3"//(1=Sim;2=Não;3=Pergunta)
			If MsgYesNo(STR0083)//Deseja utilizar o texto padrão para esta ocorrência?
				aCols[n,nPosOBS] := SUX->UX_TEXTO
			Else
				aCols[n,nPosOBS] := ""
			EndIf
		ElseIf SUX->UX_HABTXT == "1"
			aCols[n,nPosOBS] := SUX->UX_TEXTO
		Else
			aCols[n,nPosOBS] := ""
		EndIF
	EndIF
EndIf

lRefresh:=.T.
RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK510AcaTmk ³ Autor ³ Vendas Clientes    ³ Data ³ 25/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o da ACAO Informado na getdados help desk          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Help Desk                                        		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TK510AcaTmk(lLote)

Local lRet		:= .T.					//Retorno da funcao
Local aArea		:= GetArea()			//Salva a area atual
Local nPAcao   	:= 0					//Acao
Local nPDescAca	:= 0					//Descricao da Acao
Local nPOcorr	:= 0					//Ocorrência
Local cAuxiliar :=  &( ReadVar() )		//Le o conteudo do campo UD_SOLUCAO na getdados
Local nItem								//Utilizado em loop
Local lFind		:= .F.					//Indica se o conteudo selecionado é valido
Local lIntTMS   := SuperGetMV('MV_INTTMS')  //Verifica integração com o TMS

Default lLote   := .F.

If !lLote
	For nItem:=1 To Len(aHeader)
		If AllTrim(aHeader[nItem][2]) == "ADF_CODSUQ"
			nPAcao := nItem
		EndIf
		If AllTrim(aHeader[nItem][2]) == "ADF_NMSUQ"
			nPDescAca := nItem
		EndIf
		If AllTrim(aHeader[nItem][2]) == "ADF_CODSU9"
			nPOcorr := nItem
		EndIf
	Next nItem

	aCols[n][nPAcao]    := Space(TamSx3("ADF_CODSUQ")[1])
	If nPDescAca > 0
		aCols[n][nPDescAca] := ""
	EndIf
EndIf

If !Empty(M->ADF_CODSUQ)
	DbSelectarea("SUQ")
	DbSetorder(1)
	If DbSeek(xFilial("SUQ")+cAuxiliar)
		If SUQ->UQ_VALIDO <> "2"
			If !lLote
				aCols[n][nPAcao]    := SUQ->UQ_SOLUCAO
				If nPDescAca > 0
					aCols[n][nPDescAca] := SUQ->UQ_DESC
				EndIf
			EndIf
		Else
			If !lLote
				aCols[n][nPAcao]    := Space(TamSx3("ADF_CODSUQ")[1])
			EndIf
			lRet := .F.
			MsgStop(STR0015, STR0016) // "A ação escolhida está cadastrada como inválida." // "Atenção"
		Endif
	Else
		Help(" ",1,"ACAO")
		lRet := .F.
	Endif
	If lRet
		If (lLote .AND. !Empty(M->ADF_CODSU9)) .Or. (!lLote .AND. !Empty(aCols[n][nPOcorr]))
			DbSelectArea("SUR")
			DbSetOrder(1)
			If DbSeek(xFilial("SUR")+Iif(lLote,M->ADF_CODSU9,aCols[n][nPOcorr]) )
				While SUR->(!EOF()) .AND. SUR->UR_CODREC == Iif(lLote,M->ADF_CODSU9,aCols[n][nPOcorr])

					If SUR->UR_CODSOL == cAuxiliar
						lFind := .T.
					EndIf
					SUR->(DbSkip())
				End
			EndIf
		EndIf
		If !lFind
			If !lLote
				aCols[n][nPAcao]    := Space(TamSx3("ADF_CODSUQ")[1])
				aCols[n][nPDescAca] := ""
			EndIf
			Aviso(STR0016, STR0017 + CRLF + CRLF + STR0018, {"OK"}) //"Atenção" # "A ação selecionada não está associada à Ocorrência em uso." # "Por favor, utilize o F3 e selecione uma ação associada à Ocorrência em uso."
			lRet := .F.
		EndIf
	EndIf
	If !lLote .AND. lRet .And. lIntTMS
		If !aCols[n][Len(aCols[n])]
			If !Tk510AcTms(SUQ->UQ_ACAOTMS)
				aCols[n][nPAcao]    := Space(TamSx3("ADF_CODSUQ")[1])
				aCols[n][nPDescAca] := ""
				lRet                := .F.
			EndIf
		EndIf
	EndIf
EndIf

lRefresh:=.T.
RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetFieldPos   ºAutor³Vendas Clientes   º Data ³  18/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a posicao do campo no aHeader/aCols.            	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetFieldPos(cField, nPos, aAuxHeader)
Local nItem := 0 //Posicao no aheader
Local lRet:=.F. //Retorno da funcao

Default aAuxHeader := ParamIXB[1]

For nItem:=1 To Len(aAuxHeader)
	If AllTrim(aAuxHeader[nItem][2]) == cField
		nPos := nItem
		lRet := .T.
		Exit
	EndIf
Next nItem

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510TRANSFAT ºAutor³Vendas Clientes   º Data ³  04/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Transfere um atendimento para outra equipe.             	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510TransfAt(lModo)
// lModo -> .T. indica que foi chamado pela transferencia automatica de chamados e nao deve exibir telas

Local lRet:=.F. //Retorno da funcao
Local oDlg
Local oGroup
Local oGrpName
Local cGrpName := Space(TamSx3("U0_NOME")[1])
Local oMemo
Local cMemo:= ""
Local aCoordenadas 	:= MsAdvSize(.T.)
Local aChamados		:= {M->ADE_CODIGO}
Local oAssunto 		:= Nil
Local cDescAssunto 	:= POSICIONE('SX5',1,XFILIAL('SX5')+'T1'+M->ADE_ASSUNT,'SX5->X5_DESCRI')
Local oDescAssunto 	:= NIl
Local oProduto 		:= Nil
Local oDescProduto 	:= Nil
Local cDescProduto 	:= Posicione("SB1",1,xFilial("SB1")+M->ADE_CODSB1,"SB1->B1_DESC")
Local cFilAntBkp   	:= cFilAnt
Local cFilRef		:= ""
Local cGrpAtend	   	:= ""
Local cGrpAnt		:= ""
Local lF3Grpo		:= .F.
Local cOpcSel		:= ""
Local nPosCodSU9	:= 0
Local nPosRecno		:= 0
Local lExistTrf		:= .T.
Local nCont			:= 0
Local aTrfInfAux	:= {}
Local lObfNOper		:= FATPDIsObfuscate("U7_NOME",,.T.)  

Local cPrdAnt		:= M->ADE_CODSB1
Local cAssuAnt		:= M->ADE_ASSUNT
Local cCatAnt		:= M->ADE_CODCAT
Local cOriAnt		:= M->ADE_CODORI
Local cCauAnt		:= M->ADE_CODCAU
Local cEfeAnt		:= M->ADE_CODEFE
Local cCampAnt		:= M->ADE_CODCAM

Local oCategoria   := Nil
Local oDescCateg   := Nil
Local cDescCateg   := M->ADE_NCATEG

Local oOrigem      := Nil
Local oDescOrig    := Nil
Local cDescOrig    := M->ADE_NORIGE

Local oCausa       := Nil
Local oDescCausa   := Nil
Local cDescCausa   := M->ADE_NCAUSA

Local oEfeito      := Nil
Local oDescEfeito  := Nil
Local cDescEfeito  := M->ADE_NEFEIT

Local oCampanha    := Nil
Local oDescCampan  := Nil
Local cDescCampan  := M->ADE_DSCCAM

Local oOperador := Nil
Local cNomeOperador := ""
Local oNomeOperador := Nil

Local aRetRegra := {}
Local cGrupo    := ""
Local lAutomatico:= ExecSchedule()

Default lModo := .F.

Private cProduto  := M->ADE_CODSB1
Private cAssunto  := M->ADE_ASSUNT
Private cGroup 	  := Space(TamSX3("U0_CODIGO")[1])
Private cOperador := Space(TamSX3("U7_COD")[1])
Private cCategoria:= M->ADE_CODCAT
Private cOrigem   := M->ADE_CODORI
Private cCausa    := M->ADE_CODCAU
Private cEfeito   := M->ADE_CODEFE
Private cCampanha := M->ADE_CODCAM

// TFEGRP Transferencia automatica de chamados
if lModo
	lModo := .F.
Endif

If !( Type("aVarTrf") == "A" .or. Type("aTrfAux") == "A" .or. Type("aTrfVld") == "A" )
	_SetOwnerPrvt( "aVarTrf" , {} )
	_SetOwnerPrvt( "aTrfAux" , {} )
	_SetOwnerPrvt( "aTrfVld" , {} )
EndIf

If ( Type("oGetD") == "O" )
	nPosCodSU9	:= GdFieldPos("ADF_CODSU9", oGetD:aHeader)
	nPosRecno	:= aScan(aHeader, {|x| AllTrim(x[2]) == "ADF_REC_WT"})
	If ( Len(aTransfere) > 0 )
		For nCont := 1 To Len(oGetD:aCols)
			If ( AllTrim(oGetD:aCols[ nCont, nPosCODSU9 ]) == "TMK001") .and. ;
							!( oGetD:aCols[ nCont, Len(aCols[nCont]) ] ) .and. ;
							Empty(oGetD:aCols[ nCont, nPosRecno ])
				lExistTrf := .F.
				Exit
			EndIf
		Next
		If (lExistTrf)
			aTrfInfAux := aClone(aTransfere)
			aTransfere := {}
		EndIf
	EndIf
EndIf

//Verifica se existe a nova consulta do grupo
dbSelectArea("SXB")
dbSetOrder(1)
If SXB->(dbSeek("TMKSU0"))
	lF3Grpo := .T.
EndIf

If INCLUI .OR. ALTERA

	if INCLUI
		// TFEGRP Transferencia automatica de chamados
		// avalia as regras de transferencia automatica
		aRetRegra := TK560REGRA(M->ADE_ASSUNTO, M->ADE_GRUPO)
		if ! Empty(aRetRegra)
			cTxtMsg := STR0187+CRLF+CRLF // "Foi localizada uma regra de transferencia automatica para este chamado:"

			if aRetRegra[1,2] <> M->ADE_GRUPO
				cTxtMsg += STR0176+aRetRegra[1,2]+" "+Posicione("SU0",1,xFilial("AAV")+aRetRegra[1,2],"U0_NOME")+CRLF // "Grupo    : "
				cGroup := aRetRegra[1,2]
			Endif

			if !Empty(aRetRegra[1,3]) .and. aRetRegra[1,3] <> M->ADE_OPERAD
				cTxtMsg += STR0177+aRetRegra[1,3]+" "+Posicione("SU7",1,xFilial("AAV")+aRetRegra[1,3],"U7_NOME")+CRLF // "Operaror : "
				cOperador := aRetRegra[1,3]
			Endif

			cTxtMsg += CRLF+STR0188 // "Verifique as informacoes na tela de transferencia."

			if ! lModo .and. ! lAutomatico
				Aviso(STR0181, cTxtMsg,{"Ok"},3,STR0184) // "Transferencia automatica de chamados"###"Localizada Regra de Transferencia"
			Endif
		Endif
	Endif

	cGrpAnt := cGroup  // controla a validacao de grupo

	If ( Len(aTransfere) <= 0 )
		lRet := .T.
		While .T.
			if ! lModo .and. ! lAutomatico  
				oDlg := TDialog():New(aCoordenadas[7],000,aCoordenadas[6]/1.1,aCoordenadas[5]/2.2,STR0019,,,,,,,,oMainWnd,.T.) //"Transferencia de área"

				@ 001,005 SAY STR0084 PIXEL SIZE 55,9 OF oDlg //Assunto
				@ 011,005 MSGET oAssunto Var cAssunto SIZE 030,9 PICTURE "@!" OF oDlg Pixel F3 "T1" VALID Iif(ExistCpo("SX5","T1"+cAssunto),(M->ADE_ASSUNT := cAssunto, cDescAssunto := Posicione("SX5",1,xFilial("SX5")+"T1"+cAssunto,"SX5->X5_DESCRI"),.T.),.F.) When Empty(cGroup)
				@ 011,040 MSGET oDescAssunto Var cDescAssunto SIZE oDlg:nClientWidth/2-45,9 PICTURE "@!" OF oDlg Pixel When .F.

				@ 026,005 SAY STR0086 PIXEL SIZE 55,9 OF oDlg //Grupo:
				@ 036,005 MSGET oGroup Var cGroup SIZE 015,9 PICTURE PesqPict("SU0", "U0_CODIGO") OF oDlg Pixel F3 IIf(!lF3Grpo,"TMK014","TMKSU0") VALID Tk510AVlGr(cGroup,cAssunto,aChamados,@cGrpName,@cOperador,@cNomeOperador,@cGrpAnt) When !Empty(cAssunto)
				@ 036,030 MSGET oGrpName Var cGrpName SIZE oDlg:nClientWidth/2-035,9 PICTURE PesqPict("SU0", "U0_NOME") OF oDlg Pixel When .F.

				@ 051,005 SAY STR0088 PIXEL SIZE 55,9 OF oDlg //Usuário:
				@ 061,005 MSGET oOperador Var cOperador SIZE 030,9 PICTURE PesqPict("SU7", "U7_COD") OF oDlg Pixel F3 "TMK018" VALID Iif(!Empty(cOperador),TK510VldUser(cGroup,cOperador,@cNomeOperador),.T.) When !Empty(cAssunto) .And. TK510VldGrupo(cGroup,,2)
				
				@ 061,040 MSGET oNomeOperador Var cNomeOperador SIZE oDlg:nClientWidth/2-045,9 PICTURE "@!" OF oDlg Pixel When .F.   
				If FATPDActive() .And. FTPDUse(.T.)
					oNomeOperador:lObfuscate := lObfNOper
				EndIf

				@ 080,005 SAY STR0085 PIXEL SIZE 55,9 OF oDlg //Produto
				@ 080,040 MSGET oProduto Var cProduto SIZE 60,9 PICTURE PesqPict("SB1", "B1_COD") OF oDlg Pixel F3 "TMK019" VALID Iif(Tk510VldCpTr(1,cProduto,@cFilRef),(cDescProduto := Posicione("SB1",1,cFilRef+cProduto,"SB1->B1_DESC"),.T.),.F.)
				@ 080,105 MSGET oDescProduto Var cDescProduto SIZE oDlg:nClientWidth/2-110,9 OF oDlg Pixel When .F.

				@ 095,005 SAY STR0093 PIXEL SIZE 55,9 OF oDlg //Categoria
				@ 095,040 MSGET oCategoria Var cCategoria SIZE 60,9 PICTURE PesqPict("ADE", "ADE_CODCAT") OF oDlg Pixel F3 Posicione("SX3", 2, "ADE_CODCAT","X3_F3") VALID(cDescCateg := "", Iif(!Empty(cCategoria),  Iif(Tk510JValid(3),(cDescCateg := FQNCNTAB('4',cCategoria),.T.),.F.)  ,.T.) )
				@ 095,105 MSGET oDescCateg Var cDescCateg SIZE oDlg:nClientWidth/2-110,9 OF oDlg Pixel When .F.

				@ 110,005 SAY STR0094 PIXEL SIZE 55,9 OF oDlg //Origem
				@ 110,040 MSGET oOrigem Var cOrigem SIZE 60,9 PICTURE PesqPict("ADE", "ADE_CODORI") OF oDlg Pixel F3 Posicione("SX3", 2, "ADE_CODORI","X3_F3") VALID ( cDescOrig := "", Iif(!Empty(cOrigem),Iif(Tk510JValid(4),(cDescOrig := FQNCNTAB('3',cOrigem),.T.),.F.),.T.) )
				@ 110,105 MSGET oDescOrig Var cDescOrig SIZE oDlg:nClientWidth/2-110,9 OF oDlg Pixel When .F.

				@ 125,005 SAY STR0095 PIXEL SIZE 55,9 OF oDlg //Causa
				@ 125,040 MSGET oCausa Var cCausa SIZE 60,9 PICTURE PesqPict("ADE", "ADE_CODCAU") OF oDlg Pixel F3 Posicione("SX3", 2, "ADE_CODCAU","X3_F3") VALID ( cDescCausa := "", Iif(!Empty(cCausa),Iif(Tk510JValid(5),(cDescCausa := FQNCNTAB('1',cCausa), .T.),.F.),.T.) )
				@ 125,105 MSGET oDescCausa Var cDescCausa SIZE oDlg:nClientWidth/2-110,9 OF oDlg Pixel When .F.

				@ 140,005 SAY STR0096 PIXEL SIZE 55,9 OF oDlg //Efeito
				@ 140,040 MSGET oEfeito Var cEfeito SIZE 60,9 PICTURE PesqPict("ADE", "ADE_CODEFE") OF oDlg Pixel F3 Posicione("SX3", 2, "ADE_CODEFE","X3_F3") VALID (cDescEfeito := "", Iif(!Empty(cEfeito),Iif(Tk510JValid(6),(cDescEfeito := FQNCNTAB('2',cEfeito) ,.T.),.F.),.T.))
				@ 140,105 MSGET oDescEfeito Var cDescEfeito SIZE oDlg:nClientWidth/2-110,9 OF oDlg Pixel When .F.

				@ 155,005 SAY STR0097 PIXEL SIZE 55,9 OF oDlg //Campanha
				@ 155,040 MSGET oCampanha Var cCampanha SIZE 60,9 PICTURE PesqPict("ADE", "ADE_CODCAM") OF oDlg Pixel F3 "TMK006" VALID (cDescCampan := "", Iif(!Empty(cCampanha),Iif(Tk510JValid(1),(cDescCampan := POSICIONE('SUO',1,XFILIAL('SUO') + cCampanha, 'UO_DESC') , .T.),.F.),.T.))
				@ 155,105 MSGET oDescCampan Var cDescCampan SIZE oDlg:nClientWidth/2-110,9 OF oDlg Pixel When .F.

				@ 165,005 SAY STR0021 PIXEL SIZE 55,9 OF oDlg //"Motivo"
				oMemo:= TMultiGet():New(175,005,{|u|if(Pcount()>0,cMemo:=u,cMemo)},oDlg,oDlg:nClientWidth/2-10,oDlg:nClientHeight/2-210,,,,,,.T.)
				oMemo:lWordWrap := .T.

			    DEFINE SBUTTON FROM oDlg:nClientHeight/2-30,005 TYPE 1 ENABLE OF oDlg ACTION (lRet:= .T.,oDlg:End())
			    DEFINE SBUTTON FROM oDlg:nClientHeight/2-30,040 TYPE 2 ENABLE OF oDlg ACTION (lRet:= .F.,oDlg:End())

				FATPDLogUser("TK510TRANS")

				oDlg:Activate(,,,.T.)

				//Valida se a combinacao de assunto/produto/categoria/origem/causa/efeito e campanha eh valida
				If lRet .And. !TK510CombVld(cAssunto,cGroup,2)
					Loop
				EndIf

			EndIf

			If lRet .or. lAutomatico
				M->ADE_CODSB1	:= Iif(!Empty(cProduto)		,cProduto	,M->ADE_CODSB1	)
				M->ADE_ASSUNT	:= Iif(!Empty(cAssunto)		,cAssunto	,M->ADE_ASSUNT	)
				M->ADE_CODCAT	:= Iif(!Empty(cCategoria)	,cCategoria	,M->ADE_CODCAT	)
				M->ADE_CODORI	:= Iif(!Empty(cOrigem)		,cOrigem	,M->ADE_CODORI	)
				M->ADE_CODCAU	:= Iif(!Empty(cCausa)		,cCausa		,M->ADE_CODCAU	)
				M->ADE_CODEFE	:= Iif(!Empty(cEfeito)		,cEfeito	,M->ADE_CODEFE	)
				M->ADE_CODCAM	:= Iif(!Empty(cCampanha)	,cCampanha	,M->ADE_CODCAM	)
				M->ADE_NCATEG	:= Iif(!Empty(cDescCateg)	,cDescCateg	,M->ADE_NCATEG	)
				M->ADE_NORIGE	:= Iif(!Empty(cDescOrig)	,cDescOrig	,M->ADE_NORIGE	)
				M->ADE_NCAUSA	:= Iif(!Empty(cDescCausa)	,cDescCausa	,M->ADE_NCAUSA	)
				M->ADE_NEFEIT	:= Iif(!Empty(cDescEfeito)	,cDescEfeito,M->ADE_NEFEIT	)
				M->ADE_DSCCAM	:= Iif(!Empty(cDescCampan)	,cDescCampan,M->ADE_DSCCAM	)
			EndIf

			//Caso o sistema tenha atribuido um atendente automatico
			lRodizio := .F.

			If lRet .AND. Empty(cOperador)
				cOperador := Tk510OpAuto(cGroup,@cOpcSel,.F.)
				If cOpcSel == "4"
					lRodizio := .T.
				EndIf
			EndIf

			//Valida se o operador de destino esta INATIVO e busca via recursiva os substitutos
			If lRet .AND. !Empty(cOperador) .and. ! lAutomatico

				aRecSubstitutos := {} //Limpa o vetor de recursiva

				//Considera o grupo de origem na transferencia entre filiais
				DbSelectArea("SU0")
				DbSetOrder(1)
				MsSeek(xFilial("SU0")+cGroup)

			  	If	!Empty(SU0->U0_FILORI) .AND. !Empty(SU0->U0_GRPORI) .AND. xFilial("SU0") <> SU0->U0_FILORI

  					cFilAnt 	:= SU0->U0_FILORI
  					cGrpAtend	:= SU0->U0_GRPORI

  				EndIf

				cOperador := TK510StatOper(cOperador)

				If Empty(cOperador)
					cOperador := Space(6)
					cNomeOperador := ""

					MsgAlert(STR0091)
					Loop
				Else
					//Valida se o operador identificado (informadou ou substitutivo) atende ao grupo do direcionamento
					If !Empty(cGrpAtend)
						dbSelectArea("AG9")
						AG9->(dbSetOrder(1))
						If !AG9->(MsSeek(xFilial("AG9")+cOperador+cGrpAtend ))
							MsgAlert(STR0092)
							Loop
						Else
							Exit
						EndIf
					Else
						Exit
					EndIf
				EndIf
			Else
				Exit
			EndIf
		EndDo
	Else
		if ! lAutomatico
			Aviso(STR0016, STR0022 + CRLF + STR0023, {"OK"}) //"Atenção" # "Já foi solicitado a transferéncia deste chamado. " # "A transferência será realizada no momento que o atendimento for gravado."
		Endif
		lRet := .F.
	EndIf

	cFilAnt := cFilAntBkp

	If lRet .AND. !Empty(cGroup)
		If ((lModo .or. lAutomatico) .and. ! Empty(cGroup)) .or. (! lAutomatico .and. MsgYesNo(STR0024, STR0016)) 	// "Confirma a transferência do chamado?" # "Atenção"
			Tk510TGrp(cGroup,cOperador)
			if (lModo .or. lAutomatico) .and. ! Empty(aRetRegra)
				if M->ADE_GRUPO == aRetRegra[1,2]  // mesmo grupo
					if ! Empty(aRetRegra[1,3]) .and. M->ADE_OPERAD <> aRetRegra[1,2]  // tem operador diferente do chamado
						cMemo := Alltrim(cMemo)+if(Empty(cMemo),"",Chr(10)+Chr(13))+STR0185+aRetRegra[1,3]+" "+Alltrim(Posicione("SU7",1,xFilial("AAV")+aRetRegra[1,3],"U7_NOME")) + STR0186 // " Chamado Transferido para Operaror : "###" [Transferencia Automatica] "
					Endif
				Else
					if ! Empty(aRetRegra[1,3]) .and. M->ADE_OPERAD <> aRetRegra[1,2]  // tem operador diferente do chamado
						cMemo := Alltrim(cMemo)+if(Empty(cMemo),"",Chr(10)+Chr(13))+STR0189+aRetRegra[1,2]+" "+Posicione("SU0",1,xFilial("AAV")+aRetRegra[1,2],"U0_NOME")+; // "Chamado Transferido para a Area: "
									STR0177+aRetRegra[1,3]+" "+Alltrim(Posicione("SU7",1,xFilial("AAV")+aRetRegra[1,3],"U7_NOME")) + STR0186  // " Operaror : "###" [Transferencia Automatica] "
					Else
						cMemo := Alltrim(cMemo)+if(Empty(cMemo),"",Chr(10)+Chr(13))+STR0189+aRetRegra[1,2]+" "+Posicione("SU0",1,xFilial("AAV")+aRetRegra[1,2],"U0_NOME") +STR0186  // "Chamado Transferido para a Area: "### " [Transferencia Automatica] "
					Endif
				Endif
			Else
				cMemo := STR0025 + cGrpName + CRLF + STR0026 + " " + cMemo //"Chamado Transferido para área :" # "Motivo Analista:"
			Endif

			Tk510IncAcols(	"TMK001", cMemo ,,cOperador,;
							cAssunto, cProduto	, cGroup	, cCategoria,;
							cOrigem	, cCausa	, cEfeito	, cCampanha	,;
							.F., lModo		) //"Chamado Transferido para área :" # "Motivo Analista:"


			aVarTrf := {}
			aTrfAux := {}

			aTrfAux := { cGroup, cOperador }

			aAdd( aVarTrf, cGrpName		)
			aAdd( aVarTrf, cOperador	)
			aAdd( aVarTrf, cAssunto 	)
			aAdd( aVarTrf, cProduto 	)
			aAdd( aVarTrf, cGroup 		)
			aAdd( aVarTrf, cCategoria 	)
			aAdd( aVarTrf, cOrigem 		)
			aAdd( aVarTrf, cCausa 		)
			aAdd( aVarTrf, cEfeito 		)
			aAdd( aVarTrf, cCampanha	)

			If ( Len(aTrfVld) > 0 .and. Type("oGetD") == "O" )
				aScan( aTrfVld, { |x| x[12] := .F. } )
				aAdd( aTrfVld, { M->ADE_DESCGP,;
								 M->ADE_OPERAD,;
								 M->ADE_ASSUNT,;
								 M->ADE_CODSB1,;
								 M->ADE_GRUPO,;
								 M->ADE_CODCAT,;
								 M->ADE_CODORI,;
								 M->ADE_CODCAU,;
								 M->ADE_CODEFE,;
								 M->ADE_CODCAM,;
								 Len(oGetD:aCols) ,;
								 .T.,;
								 M->ADE_DESCAS,;
								 M->ADE_NMPROD,;
								 M->ADE_NMOPER,;
								 M->ADE_DESCGP,;
								 M->ADE_ASSANT,;
								 M->ADE_NCATEG,;
								 M->ADE_NORIGE,;
								 M->ADE_NCAUSA,;
								 M->ADE_NEFEIT,;
								 M->ADE_DSCCAM 	} )
			ElseIf Type("oGetD") == "O"
				aAdd( aTrfVld, { M->ADE_DESCGP,;
								 M->ADE_OPERAD,;
								 M->ADE_ASSUNT,;
								 M->ADE_CODSB1,;
								 M->ADE_GRUPO,;
								 M->ADE_CODCAT,;
								 M->ADE_CODORI,;
								 M->ADE_CODCAU,;
								 M->ADE_CODEFE,;
								 M->ADE_CODCAM,;
								 Len(oGetD:aCols) ,;
								 .T.,;
								 M->ADE_DESCAS,;
								 M->ADE_NMPROD,;
								 M->ADE_NMOPER,;
								 M->ADE_DESCGP,;
								 M->ADE_ASSANT,;
								 M->ADE_NCATEG,;
								 M->ADE_NORIGE,;
								 M->ADE_NCAUSA,;
								 M->ADE_NEFEIT,;
								 M->ADE_DSCCAM 	} )

			EndIf

		Else
			lRet := .F.
		EndIf
	EndIf
EndIf

//Se cancelou, restaura variaveis de memoria
If !lRet
	M->ADE_CODSB1	:= cPrdAnt
	M->ADE_ASSUNT	:= cAssuAnt
	M->ADE_CODCAT	:= cCatAnt
	M->ADE_CODORI	:= cOriAnt
	M->ADE_CODCAU	:= cCauAnt
	M->ADE_CODEFE	:= cEfeAnt
	M->ADE_CODCAM	:= cCampAnt
	If Len(aTrfInfAux) > 0
		aTransfere		:= aClone(aTrfInfAux)
	EndIf
Else

	If Type("lAltTransf") == "L"
		lAltTransf := .t.
	EndIf

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TK510AteGA ºAutor³ Vendas e CRM       º Data ³  27/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o grupo passado por parâmetro atende ao assuntoº±±
±±º          ³do chamado.                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510AteGA( cGroup, cAssunto )

Local aArea	:= GetArea()
Local lRet	:= .F.

Default cAssunto := M->ADE_ASSUNT

DbSelectArea("SKK")
DbSetOrder(1)
If SKK->(DbSeek( xFilial("SKK") + cGroup ))
	While 	SKK->KK_FILIAL == xFilial("SKK")  .And.;
			SKK->KK_CODSU0 == cGroup
		If SKK->KK_CODSKQ == cAssunto
			lRet := .T.
			Exit
		EndIf
		SKK->(DbSkip())
	End
EndIf

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510TGrp     ºAutor³Vendas Clientes   º Data ³  04/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Define o novo grupo de atendimento para onde o chamado deveº±±
±±º          ³ser transferido.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510TGrp(cGroup,cOperad)

aTransfere := {}
aAdd(aTransfere, cGroup)
aAdd(aTransfere, cOperad)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510ClrGrp   ºAutor³Vendas Clientes   º Data ³  15/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Limpa a lista de grupos para transferencia do chamado       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510ClrGrp()
Local lRet := .T.
aTransfere := {}
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510IncAcols ºAutor³Vendas Clientes   º Data ³  04/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclui uma nova linha no aCols de Atendimento.          	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510IncAcols(	cOco	, cObs		, cAction	, cOperador	,;
						cAssunto, cProduto	, cGroup	, cCategoria,;
						cOrigem	, cCausa	, cEfeito	, cCampanha	,;
						lGrava	, lTransfere)
// lTransfere -> .T. a rotina deve gravar mesmo que tenha regra pois foi chamada pela Runact

Local lRet := .F.
Local nPosOco := 0
Local nPosDescOco := 0
Local nPosObs	:= 0
Local nPosIt	:= 0
Local nHeader	:= 0
Local nPosAct	:= 0
Local nPosDescAct:= 0
Local nPosOperador := 0
Local nPosGrupo := 0
Local nPosNome  := 0
Local lAdiciona	:= .T.
Local cOpcDefault := SuperGetMv("MV_TMKALOC",,"")
Local lMudaGrupo  := .F.
Local nTamOper	:= TamSX3("ADE_OPERAD")[1]
Local aRetRegra := {}
Local lContinua := .T.

Default cAction := Space(TamSX3("ADF_CODSUQ")[1])
Default cOperador := Space(nTamOper)
Default cAssunto := ""
Default cProduto := ""
Default cGroup   := ""
Default cCategoria 	:= ""
Default cOrigem    	:= ""
Default cCausa     	:= ""
Default cEfeito		:= ""
Default cCampanha	:= ""
Default lGrava		:= .T.
Default lTransfere := .F.

If Type("oGetD") == "O"
	aCols 	:= aClone(oGetD:aCols)
	aHeader	:= aClone(oGetD:aHeader)
	N		:= aClone(oGetD:nAt)
EndIf

if lContinua
	//Atualiza os campos caso o Assunto e produto tenham sido alterados
	If !Empty(cAssunto) .Or. !Empty(cProduto)
		If ALTERA .AND. lGrava
			dbSelectArea("ADE")
			RecLock("ADE",.F.)
				If !Empty(cAssunto) .AND. (cAssunto <> ADE->ADE_ASSUNT)
					ADE->ADE_ASSANT := ADE->ADE_ASSUNT
					ADE->ADE_ASSUNT := cAssunto
				EndIf

				If !Empty(cProduto) .AND. (cProduto <> ADE->ADE_CODSB1)
					ADE->ADE_PRDANT	:= ADE->ADE_CODSB1
					ADE->ADE_CODSB1	:= cProduto
				EndIf

				ADE->ADE_OPERAD := cOperador

			MsUnlock()
		EndIf

		If !Empty(cAssunto)
			M->ADE_ASSUNT 	:= cAssunto
			M->ADE_DESCAS	:= Posicione("SX5",1,xFilial("SX5")+"T1"+cAssunto,"SX5->X5_DESCRI")
		EndIf

		If !Empty(cProduto)
			M->ADE_CODSB1	:= cProduto
			M->ADE_NMPROD 	:= Posicione("SB1",1,xFilial("SB1")+cProduto,"SB1->B1_DESC")
		EndIf

		If M->ADE_OPERAD <> cOperador
			M->ADE_OPERAD := cOperador
			M->ADE_NMOPER := POSICIONE('SU7',1,XFILIAL('SU7') + M-> ADE_OPERAD, 'U7_NOME')
		EndIf

		If !Empty(cGroup) .And. M->ADE_GRUPO <> cGroup
			lMudaGrupo := .F.
			M->ADE_GRUPO	:= cGroup
			M->ADE_DESCGP	:= POSICIONE('SU0',1,XFILIAL('SU0')+M->ADE_GRUPO,'U0_NOME')

			//Limpa o campo do OPERADOR quando o novo grupo for do tipo
			SU0->(dbSetOrder(1))
			SU0->(msSeek(xFilial("SU0")+cGroup ))

			If !Empty(SU0->U0_TPALOC)
				cOpcDefault := SU0->U0_TPALOC
			EndIf

			If cOpcDefault == "1" //Sem alocacao
				M->ADE_OPERAD := Space(nTamOper)
				M->ADE_NMOPER := ""
			EndIf

		EndIf

	EndIf

	//Tratamento das mudancas de demais informacoes do atendimento
	If ALTERA .AND. lGrava
		dbSelectArea("ADE")
		RecLock("ADE",.F.)
	EndIf

	If !Empty(cCategoria)
		M->ADE_CODCAT := cCategoria
		Iif(ALTERA .AND. lGrava,ADE->ADE_CODCAT := cCategoria,M->ADE_CODCAT := cCategoria)
	EndIf

	If !Empty(cOrigem)
		M->ADE_CODORI := cOrigem
		Iif(ALTERA .AND. lGrava,ADE->ADE_CODORI := cOrigem,M->ADE_CODORI := cOrigem)
	EndIf

	If !Empty(cCausa)
		M->ADE_CODCAU := cCausa
		Iif(ALTERA .AND. lGrava,ADE->ADE_CODCAU := cCausa,M->ADE_CODCAU := cCausa)
	EndIf

	If !Empty(cEfeito)
		M->ADE_CODEFE := cEfeito
		Iif(ALTERA .AND. lGrava,ADE->ADE_CODEFE := cEfeito,M->ADE_CODEFE := cEfeito)
	EndIf

	If !Empty(cCampanha)
		M->ADE_CODCAM := cCampanha
		Iif(ALTERA .AND. lGrava,ADE->ADE_CODCAM := cCampanha,M->ADE_CODCAM := cCampanha)
	EndIf

	If ALTERA .AND. lGrava
		MsUnlock()
	EndIf

	If GetFieldPos("ADF_CODSU9", @nPosOco, aHeader)
		If GetFieldPos("ADF_NMSU9", @nPosDescOco, aHeader)
			GetFieldPos("ADF_OBS", @nPosObs, aHeader)
			GetFieldPos("ADF_ITEM", @nPosIt, aHeader)
			GetFieldPos("ADF_CODSUQ", @nPosAct, aHeader)
			GetFieldPos("ADF_NMSUQ", @nPosDescAct, aHeader)
			GetFieldPos("ADF_CODSU7", @nPosOperador, aHeader)
			GetFieldPos("ADF_CODSU0", @nPosGrupo, aHeader)
			GetFieldPos("ADF_NMSU7", @nPosNome, aHeader)

			//Inclui uma nova linha no aCols
			If Type("oGetD") == "O"
				lAdiciona := !oGetD:lNewLine
			EndIf

			If lAdiciona
				Aadd(aCols,Array(Len(aHeader)+1))
			Else
				If Type("oGetD") == "O"
					oGetD:lNewLine := .F.
				EndIf
			EndIf

			For nHeader := 1 To Len(aHeader)
				If nHeader == nPosOco
					aCols[Len(aCols)][nHeader] := cOco
				ElseIf nHeader == nPosDescOco
					aCols[Len(aCols)][nHeader] := Tk510DefOcName(cOco)
				ElseIf nHeader == nPosAct
					aCols[Len(aCols)][nHeader] := cAction
				ElseIf nHeader == nPosDescAct .AND. !Empty(cAction)
					aCols[Len(aCols)][nHeader] := POSICIONE("SUQ", 1, xFilial("SUQ")+cAction,"UQ_DESC")
				ElseIf nHeader == nPosIt
					If Len(aCols) > 1
						If aHeader[nHeader][8] == "C"
							aCols[Len(aCols)][nHeader] := Soma1(aCols[Len(aCols)-1][nHeader])
						EndIf
					Else
						If aHeader[nHeader][8] == "C"
							aCols[Len(aCols)][nHeader] := "001"
						EndIf
					EndIf
				ElseIf nHeader == nPosObs
					aCols[Len(aCols)][nHeader] := cObs
				ElseIf IsHeadAlias(aHeader[nHeader,2])
					aCols[Len(aCols)][nHeader] := "ADF"
				ElseIf IsHeadRec(aHeader[nHeader,2])
					aCols[Len(aCols)][nHeader] := 0
				Else
					aCols[Len(aCols)][nHeader] := CriaVar(aHeader[nHeader,2],.T.)
				Endif
			Next nHeader
			aCols[Len(aCols)][Len(aHeader)+1] := .F.
		EndIf
	EndIf
Endif

If Type("oGetD") == "O"
	oGetD:aCols	:= aClone(aCols)
	oGetD:Refresh()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510DefOcNameºAutor³Vendas Clientes   º Data ³  04/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o nome de ocorrencias padrao.                   	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510DefOcName(cName)
Local cRet :=""
Local aAreaSU9 := SU9->(GetArea())

DbSelectArea("SU9")
DbSetOrder(2)
If MsSeek(xFilial("SU9")+cName)
	cRet := SU9->U9_DESC
ElseIf cName == "TMK001"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Transferencia de area             	 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRet := STR0028 //"Transferir"
ElseIf cName == "TMK002"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Associando um chamado anterior    	 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRet := STR0029 //"Chamado Associado"
ElseIf cName == "TMK003"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Etapa do Plano de Acao concluida  	 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRet := STR0030 // "Nova etapa do Plano de Ação"
ElseIf cName == "TMK004"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Etapa do Plano de Acao concluida  	 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRet := STR0045 // "Resposta de Workflow - Aprovado"
ElseIf cName == "TMK005"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Etapa do Plano de Acao concluida  	 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRet := STR0046 // "Resposta de Workflow - Reprovado"
ElseIf cName == "TMK006"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Etapa do Plano de Acao concluida  	 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRet := STR0054 // "Reprogramação do prazo SLA"
ElseIf cName == "TMK007"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Associando um chamado anterior    	 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRet := STR0061 // "Chamado Desassociado"
ElseIf cName == "TMK008"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Distribuicao em Lote de chamados  	 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRet := STR0098 // "Chamado Distribuido"

ElseIf cName == "TMK009"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Distribuicao em Lote de chamados  	 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRet := STR0099 // "Chamado Assumido"

Else
	cRet := ""
EndIf

RestArea(aAreaSU9)
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510FndCal   ºAutor³Vendas Clientes   º Data ³  04/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca um chamado com as mesmas caracteristicas para asso-  º±±
±±º          ³-ciar ao chamado atual.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510FndCal(lCancela)
Local oFindInCalls 	:= HelpDeskFindCalls():New()
Local cText 		:= STR0031 //"Confirma a associação do chamado atual ao chamado anterior No #001?"
Local lRet 			:= .F.
Local lQAtuTMK 		:= IsInCallStack("QATUTMK")
Local nOpcSel		:= 0
Local lAutomatico:= ExecSchedule()

Default lCancela := .F.

	If ! lAutomatico .AND. !lQAtuTMK
		If INCLUI .OR. ALTERA
			If Empty(M->ADE_CHANEX)
				If oFindInCalls:showDialog(M->ADE_CODSB1,M->ADE_PLVCHV,@lCancela)
					//Usuário selecionou um chamado para associar o atual
					cText := StrTran(cText, "#001", oFindInCalls:cSelCall)
					If TmkOK(cText)
						M->ADE_CHANEX := oFindInCalls:cSelCall
						M->ADE_STATUS := "2"
						M->ADE_FLCHAN	:= cFilAnt
						Tk510IncAcols("TMK002", STR0032 + oFindInCalls:cSelCall + CRLF + STR0033) // "Associado ao chamado: " # "Status do chamado alterado para 2=Pendente."
						lRet := .T.
					EndIf
				EndIf
			Else
				nOpcSel := Aviso(STR0062,STR0063,{STR0064,STR0065,STR0066},1,STR0016) // "Confirmação" "Selecione a opção para o chamado?" "Associar" "Desassociar" "Sair" "Atenção"
				If nOpcSel == 1
					If oFindInCalls:showDialog(M->ADE_CODSB1,M->ADE_PLVCHV,@lCancela)
						//Usuário selecionou um chamado para associar o atual
						cText := StrTran(cText, "#001", oFindInCalls:cSelCall)
						If TmkOK(cText)
							M->ADE_CHANEX := oFindInCalls:cSelCall
							M->ADE_STATUS := "2"
							M->ADE_FLCHAN	:= cFilAnt
							Tk510IncAcols("TMK002", STR0032 + oFindInCalls:cSelCall + CRLF + STR0033) // "Associado ao chamado :" # "Status do chamado alterado para 2=Pendente."
							lRet := .T.
						EndIf
			   		EndIf
		   		ElseIf nOpcSel == 2
					M->ADE_CHANEX := ""
					M->ADE_STATUS := "1"
					M->ADE_FLCHAN	:= ""
					Tk510IncAcols("TMK007", STR0067) // "Desassociado e status do chamado alterado para 1=Aberto."
					lRet := .T.
				Else
					Return(.F.)
				EndIf
			EndIf
		EndIf
	EndIf

	TMKFree( oFindInCalls )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QATUTMK       ºAutor³Vendas Clientes   º Data ³  13/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada pelo QNC para notificar alteracoes na     º±±
±±º          ³ficha de Nao conformidade para o TMK.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ QATUTMK(	ExpC1,ExpC2,ExpC3,ExpC4,						  º±±
±±º			 |			ExpC5,ExpC6,ExpC7,ExpC8,						  º±±
±±º			 |			ExpD9,ExpD10)  									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 =  	Filial do Responsavel pela correcao				  º±±
±±º          ³ExpC2 =	Codigo da Etapa Atual							  º±±
±±º          ³ExpC3 =  	Codigo da Revisao Atual							  º±±
±±º          ³ExpC4 =  	Descricao da Etapa Atual						  º±±
±±º          ³ExpC5 =  	Codigo da Etapa Atual							  º±±
±±º          ³ExpC6 =  	Codigo do Responsavel pela Etapa Atual			  º±±
±±º          ³ExpC7 =  	Area do Responsavel pela Etapa Atual			  º±±
±±º          ³ExpC8 =  	Codigo da proxima Etapa							  º±±
±±º          ³ExpD9 =  	Prazo da Etapa									  º±±
±±º          ³ExpD10 = 	Data da Realizacao da Etapa						  º±±
±±º          ³ExpD11 = 	Codigo do chamado          						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QATUTMK(	cFil,		cCodAction,		cCodReview,	cDescEtapa,;
					cTPACAO,	cResponsavel,	cArea,		cStatus,;
					dPrazo,		dRealiz,		cCodChamado, aIncEtp,;
					cMemo)
Local lRet := .T.
Local lTKATUFNC		:= ExistBlock("TKATUFNC")
Local cGrpTMK := ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza as informacoes do chamado	 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("ADE")
	DbSetOrder(1) //ADE_FILIAL+ADE_CODIGO
	If !Empty(cCodChamado) .AND. MsSeek(xFilial("ADE")+cCodChamado)

		cGrpTMK := Posicione("QAD",1,xFilial("QAD")+cArea,"QAD_GRPTMK")

		TkUpdCall(	cFil,		cCodAction,		cCodReview,		cDescEtapa,;
					cTPACAO,	cResponsavel,	cGrpTMK,		cStatus,;
					dPrazo,		dRealiz,		cCodChamado,	,aIncEtp,;
					cMemo)

		If lTKATUFNC
			ExecBlock("TKATUFNC", .F., .F., {cCodChamado, cStatus})
		EndIf
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |TkUpdCall		ºAutor³Vendas Clientes   º Data ³  13/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza as informacoes do chamado de help desk.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkUpdCall(			cFil					, cCodAction	, cCodReview			, cDescEtapa			,;
							cTPACAO					, cResponsavel	, cArea					, cStatus				,;
				   			dPrazo					, dRealiz		, cCodChamado			, cCodOco				,;
				   			aIncEtp					, cMemo			, lCancelStatusControl	, lCancelSonReplication	,;
				   			lCancelFatherReplication, cFilOrig		, cOpcLote			, aRegsWF )
Local aArea 			:= GetArea()
Local aHeaderADF		:= {}
Local aColsADF 			:= {}/*
								aColsADF[][1] = ADF_OBS
								aColsADF[][2] = ADF_ITEM
								aColsADF[][3] = ADF_CODSUQ
								aColsADF[][4] = ADF_CODSU9
								aColsADF[][5] = ADF_CODSU0 */
Local cAction 			:= ""	//Indica se ha acao relativa a conclusao da etapa do QNC
Local oSLARegister 		:= SLARegister():New()	//Objeto SLARegister
Local cLastItem			:= "000"
Local nItem				:= 1					//Utilizado em Loop
Local nObsPos 			:= 1
Local nItmPos 			:= 2
Local nActPos 			:= 3
Local nOcoPos 			:= 4
Local nGrpPos 			:= 5
Local cMatResp			:= ""	//Indica o analista responsavel pela geracao da FNC
Local cGrpResp			:= ""	//Indica por qual equipe foi gerada a FNC
Local lFind				:= .F. 	//Indica se a FNC foi gerada atraves de um chamado de help desk
Local lRejeita			:= .F.	//Indica se houve uma rejeição da FNC.
Local lTKREJFNC			:= ExistBlock("TKREJFNC")	//P.E. utilizado para notificar a ocorrencia de uma rejeição de FNC.
Local lTKUPCALL			:= ExistBlock("TKUPCALL")	 	//P.E. utilizado para notificar a ocorrencia de uma rejeição de FNC.
Local lGravaRetFNC  	:= SuperGetMv("MV_TKGRFNC",,.T.)	//Indica se gravara o retorno da FNC mesmo nao cadastrado no Etapa x Ocorrencias.
Local nOperPos			:= 0
Local lAchouSKQ			:= .F.
Local aNewItens			:= {}
Local aActionItens		:= {}
Local nReturnLine		:= 0
Local lHasValidAction	:= .F.
Local nItemPos			:= 0
Local nX 				:= 0
Local nY				:= 0
Local cPassos			:= ""
Local lReproSLA	 		:= .F.	//Se teve alguma ocorrência de reprogramação de SLA - "TMK006"

Default dRealiz 					:= ""
Default cCodOco 					:= ""
Default aIncEtp 					:= {}
Default lCancelStatusControl		:= .F.
Default lCancelSonReplication		:= .F.
Default lCancelFatherReplication	:= .F.
Default cMemo						:= ""
Default	cFilOrig					:= cFilAnt
Default cOpcLote					:= ""	//Processos em Lote: 1-Distribuir; 2-Transferência; 3- Encerrar e 4-Assumir
Default aRegsWF						:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua o processamento relativo as atualizações configuradas³
//³para quando há uma mudança de etapa no QNC.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "ADE" )
DbSetOrder( 1 )
If ADE->( MsSeek( xFilial( "ADE" ) + cCodChamado ) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega o próximo item ou um número a mais do último número pego.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLastItem := GetLastIt( cCodChamado )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o Array aIncEtp esteja zerado, quer dizer que não há Etapas Paralelas Inconsistente	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aIncEtp) == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura por alguma ação/ocorrencia/ação específica SKQ para a próxima etapa. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SKQ")
		DbSetOrder(1)	// Cod. Etapa Qnc
		If !Empty(cStatus) .And. DbSeek( xFilial("SKQ") + cStatus )
			While	SKQ->(!EOF()) .And.;
				SKQ->KQ_FILIAL == xFilial( "SKQ" ) .And.;
				SKQ->KQ_CODQID == Padr(cStatus,TAMSX3("KQ_CODQID")[1])
				If Empty( SKQ->KQ_MOMENTO ) .Or. SKQ->KQ_MOMENTO == "1"
					lAchouSKQ := .T.
					Exit
				EndIf
				SKQ->(DbSkip())
			End

			If lAchouSKQ
				aAdd( aColsADF, {} )
				aAdd( aColsADF[ Len( aColsADF ) ], "" )
				aAdd( aColsADF[ Len( aColsADF ) ], cLastItem )
				aAdd( aColsADF[ Len( aColsADF ) ], IF( !Empty( SKQ->KQ_CODSUQ ), SKQ->KQ_CODSUQ, "AZAZAZ" ) )
				aAdd( aColsADF[ Len( aColsADF ) ], SKQ->KQ_CODOCO )
				aAdd( aColsADF[ Len( aColsADF ) ], cArea )
				aAdd( aNewItens, cLastItem )
				aAdd( aActionItens, SKQ->KQ_ACAO )
				lAchouSKQ := .F.
			EndIf
		EndIf

	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ For Array aIncEtp para gravação das Ações das Etapas Paralelas Inconsistente				³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aIncEtp)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura por alguma ação/ocorrencia/ação específica SKQ para a próxima etapa. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SKQ")
			DbSetOrder(1)	// Cod. Etapa Qnc
			If DbSeek( xFilial("SKQ") + AllTrim(aIncEtp[nX][2]) )
				While	SKQ->(!EOF()) .And.;
					SKQ->KQ_FILIAL == xFilial( "SKQ" ) .And.;
					SKQ->KQ_CODQID == Padr(Alltrim(aIncEtp[nX][2]),TamSx3("KQ_CODQID")[1] )
					If Empty( SKQ->KQ_MOMENTO ) .Or. SKQ->KQ_MOMENTO == "1"
						lAchouSKQ := .T.
						Exit
					EndIf
					SKQ->(DbSkip())
				End

				If lAchouSKQ
					aAdd( aColsADF, {} )
					aAdd( aColsADF[ Len( aColsADF ) ], "" )
					aAdd( aColsADF[ Len( aColsADF ) ], If( nX == 1, cLastItem, Soma1(cLastItem)) )
					aAdd( aColsADF[ Len( aColsADF ) ], IF( !Empty( SKQ->KQ_CODSUQ ), SKQ->KQ_CODSUQ, "AZAZAZ" ) )
					aAdd( aColsADF[ Len( aColsADF ) ], SKQ->KQ_CODOCO )
					aAdd( aColsADF[ Len( aColsADF ) ], cArea )
					aAdd( aNewItens, If( nX == 1, cLastItem, Soma1(cLastItem)) )
					aAdd( aActionItens, SKQ->KQ_ACAO )
				EndIf
			EndIf

		Next

	EndIf

	lAchouSKQ := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura por alguma ação/ocorrencia/ação específica SKQ para a etapa anterior. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SKQ")
	DbSetOrder(1)	// Cod. Etapa Qnc
	If !Empty(cTPACAO) .And. DbSeek( xFilial("SKQ") + cTPACAO )
		While	SKQ->(!EOF()) .And.;
			SKQ->KQ_FILIAL == xFilial( "SKQ" ) .And.;
			SKQ->KQ_CODQID == Padr(cTPACAO,TAMSX3("KQ_CODQID")[1])
			If SKQ->KQ_MOMENTO == "2"
				lAchouSKQ := .T.
				Exit
			EndIf
			SKQ->(DbSkip())
		End

		If lAchouSKQ
			cLastItem := If( Len( aColsADF ) == 1, cLastItem, Soma1(cLastItem) )
			aAdd( aColsADF, {} )
			aAdd( aColsADF[ Len( aColsADF ) ], "" )
			aAdd( aColsADF[ Len( aColsADF ) ], cLastItem )
			aAdd( aColsADF[ Len( aColsADF ) ], IF( !Empty( SKQ->KQ_CODSUQ ), SKQ->KQ_CODSUQ, "AZAZAZ" ) )
			aAdd( aColsADF[ Len( aColsADF ) ], SKQ->KQ_CODOCO )
			aAdd( aColsADF[ Len( aColsADF ) ], cArea )
			aAdd( aNewItens, cLastItem )
			aAdd( aActionItens, SKQ->KQ_ACAO )
			lAchouSKQ := .F.
		EndIf
	EndIf

	If Len( aColsADF ) == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se não encontrar nenhum item cadastrado no SKQ, verifica³
		//³se a função veio da atualização do QNC, se sim, adiciona³
		//³Ocorrência padrão do TMK para retorno de FNC.           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( !Empty( cStatus ) .Or. !Empty( cTPACAO ) ) .Or. Empty(cCodOco)
			If !lGravaRetFNC
				Return
			EndIf
			aAdd( aColsADF, {} )
			aAdd( aColsADF[ Len( aColsADF ) ], "" )
			aAdd( aColsADF[ Len( aColsADF ) ], cLastItem )
			aAdd( aColsADF[ Len( aColsADF ) ], "AZAZAZ" )
			aAdd( aColsADF[ Len( aColsADF ) ], "TMK003" )
			aAdd( aColsADF[ Len( aColsADF ) ], cArea )
			aAdd( aNewItens, cLastItem )
			aAdd( aActionItens, "" )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso contrário, adiciona a ação e ocorrência passadas pelo parâmetro.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else
			aAdd( aColsADF, {} )
			aAdd( aColsADF[ Len( aColsADF ) ], "" )
			aAdd( aColsADF[ Len( aColsADF ) ], cLastItem )
			aAdd( aColsADF[ Len( aColsADF ) ], cCodAction )
			aAdd( aColsADF[ Len( aColsADF ) ], cCodOco )
			aAdd( aColsADF[ Len( aColsADF ) ], cArea )
			aAdd( aNewItens, cLastItem )
			aAdd( aActionItens, "" )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os novos itens do atendimento. |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea( "ADF" )
	DbSetOrder( 1 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se houve alguma ocorrência de reprogramação de SLA.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MsSeek( xFilial("ADF") + cCodChamado )
		While ADF->(!EOF()) .And. (ADF->ADF_FILIAL + ADF->ADF_CODIGO) == (xFilial("ADF") + cCodChamado) .And. !lReproSLA
			If AllTrim(ADF->ADF_CODSU9) == "TMK006"
				lReproSLA := .T.
			EndIf
			ADF->(DbSkip())
		EndDo
	EndIf

	For nItem := 1 To Len( aColsADF )
		If !MsSeek( xFilial("ADF") + cCodChamado + aColsADF[nItem][2] )
			BEGIN TRANSACTION
				RecLock( "ADF", .T. )
				REPLACE ADF_FILIAL	WITH xFilial( "ADF" )
				REPLACE ADF_CODIGO 	WITH cCodChamado
				REPLACE ADF_ITEM 	WITH aColsADF[nItem][2]
				If aColsADF[nItem][3] <> "AZAZAZ"
					REPLACE ADF_CODSUQ	WITH aColsADF[nItem][3]
				EndIf
				REPLACE ADF_CODSU9 	WITH aColsADF[nItem][4]
				REPLACE ADF_CODSU0 	WITH aColsADF[nItem][5]
				REPLACE ADF_CODSU7	WITH cResponsavel
				REPLACE ADF_DATA	WITH If( !Empty( dRealiz ), dRealiz, If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ) )
				REPLACE ADF_HORA	WITH Time()
				REPLACE ADF_HORAF	WITH Time()
				If !Empty(cFilOrig)
					REPLACE ADF->ADF_FILORI	WITH cFilOrig
				EndIf
				MsUnlock()
			END TRANSACTION
		EndIf
	Next
	DbSelectArea("ADF")
	DbCloseArea()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura por alguma ação válida.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lHasValidAction := aScan( aColsADF, { |x| x[3] <> "AZAZAZ" } ) > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se houver alguma ação válida, carrega o aCols e o aHeader³
	//³para o processamento pelo TkRunAct.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lHasValidAction
		aColsADF := {}
		aHeaderADF := {}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega o aCols do atendimento, utilizado no WF   |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LoadACols(cCodChamado, @aColsADF, @aHeaderADF)

		For nItem:=1 To Len(aHeaderADF)
			If AllTrim(aHeaderADF[nItem][2]) == "ADF_OBS" .AND. aHeaderADF[nItem][8]=="M"
				nObsPos := nItem
			EndIf
			If AllTrim(aHeaderADF[nItem][2]) == "ADF_ITEM"
				nItmPos := nItem
			EndIf
			If AllTrim(aHeaderADF[nItem][2]) == "ADF_CODSUQ"
				nActPos := nItem
			EndIf
			If AllTrim(aHeaderADF[nItem][2]) == "ADF_CODSU9"
				nOcoPos := nItem
			EndIf
			If AllTrim(aHeaderADF[nItem][2]) == "ADF_CODSU0"
				nGrpPos := nItem
			EndIf
			If AllTrim(aHeaderADF[nItem][2]) == "ADF_CODSU7"
				nOperPos := nItem
			EndIf
		Next nItem

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza a área e o responsável das novas linhas.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nItem := 1 To Len( aNewItens )
			If aScan( aColsADF, { |x| AllTrim(x[nItmPos]) == AllTrim( aNewItens[nItem] ) } ) > 0
				If nGrpPos > 0
					aColsADF[nItem][nGrpPos] := cArea
				EndIf
				If nOperPos > 0
					aColsADF[nItem][nOperPos] := cResponsavel
				EndIf
			EndIf
		Next
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Indica rejeicao da FNC no QNC     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AllTrim(cStatus)=="5"
		lRejeita := .T.
		nReturnLine := Len( aColsADF )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se houver uma ação/ocorrência/ação específica cadastrada.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aScan( aActionItens, { |x| !Empty(x) } ) > 0
		For nItem := 1 To Len( aNewItens )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se houver uma ação específica da linha, efetua o seu comportamento.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( aActionItens[ nItem ] )
			   	DbSelectArea("ADE")
				DbSetOrder(1)
				If ADE->( MsSeek( xFilial("ADE") + cCodChamado ) )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se a ação encontrada no SKQ estiver para encerrar o chamado. ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If AllTrim(aActionItens[ nItem ]) == "1"
						// Encerra o chamado
						BEGIN TRANSACTION
						RecLock("ADE", .F.)
						REPLACE ADE_STATUS WITH "3"
						MsUnlock()
						END TRANSACTION

						// Encerra o SLA
						If !Empty(ADE->ADE_REGSLA)
							If oSLARegister:load( ADE->ADE_REGSLA ) .AND. oSLARegister:StatusRegister <> "2"
								oSLARegister:finish()
								oSLARegister:save()
							EndIf
						EndIf

						// Adiciona observação a linha
						If nObsPos > 0
							nItemPos := aScan( aColsADF, { |x| AllTrim(x[nItmPos]) == AllTrim( aNewItens[nItem] ) } )
							If nItemPos > 0
								aColsADF[nItemPos][nObsPos] := STR0034 + CRLF + AllTrim( aColsADF[nItem][nObsPos] ) // "Chamado encerrado. "
							EndIf
						EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se a ação encontrada no SKQ estiver para retornar a pendência. |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIf AllTrim(aActionItens[ nItem ]) == "2"
						// Indica a necessidade de rejeitar
						lRejeita := .T.
						nItemPos := aScan( aColsADF, { |x| AllTrim(x[nItmPos]) == AllTrim( aNewItens[nItem] ) } )
						If nItemPos > 0
							nReturnLine := nItemPos
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna pendencia para o analista de atendimento. |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRejeita
		lFind := .F.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura pelo primeiro Grupo/Analista que atendeu o chamado. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea( "ADF" )
		DbSetOrder( 1 )
		If ADF->( MsSeek( xFilial("ADF") + ADE->ADE_CODIGO ) )
			While !EOF() .And. ADE->ADE_CODIGO == ADF->ADF_CODIGO
				If	ADE->ADE_FNC 	== ADF->ADF_FNC .AND.;
					ADE->ADE_FNCREV == ADF->ADF_FNCREV

					cGrpResp := ADF->ADF_CODSU0
					cMatResp := ADF->ADF_CODSU7
					lFind := .T.
					Exit
				EndIf
				DbSkip()
			End
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o analista continua na equipe. |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SU7")
		DbSetOrder(1)
		If !( SU7->( MsSeek( xFilial( "SU7" ) + cMatResp ) ) .And. SU7->U7_POSTO == cGrpResp )
			cMatResp := ""
		EndIf

		If lFind
			BEGIN TRANSACTION
				RecLock("ADE", .F.)
				REPLACE ADE->ADE_GRUPO 	WITH cGrpResp
				REPLACE ADE->ADE_OPERAD	WITH cMatResp
				MsUnlock()
			END TRANSACTION
		EndIf

		// Adiciona observação a linha
		If nObsPos > 0
			If nReturnLine > 0
				aColsADF[nReturnLine][nObsPos] := STR0035 + CRLF + AllTrim( aColsADF[nReturnLine][nObsPos] ) //"Pendencia de atendimento retornado para analista de Help Desk. "
			EndIf
		EndIf

		If lTKREJFNC
			ExecBlock( "TKREJFNC", .F., .F., { ADE->ADE_CODIGO, ADE->ADE_FNCFIL, ADE->ADE_FNC, ADE->ADE_FNCREV } )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa as acoes relativas ao Item|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nItem := 1 To Len( aNewItens )
		nItemPos := aScan( aColsADF, { |x| AllTrim(x[nItmPos]) == AllTrim( aNewItens[nItem] ) } )
		If nItemPos > 0
			// Adiciona observação a linha
			If nObsPos > 0
				If Empty( cCodOco )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso a Variavel cStatus esteja preecnhida quer dizer que NÃO houve Etapas Paralelas			³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty( cStatus )
						If !Empty(cMemo)
							aColsADF[nItemPos][nObsPos] += cMemo
					    Else
					   	 	aColsADF[nItemPos][nObsPos] += STR0036 + cStatus + " - " + AllTrim( Posicione( "QID", 1, xFilial( "QID" ) + cStatus, "QID_DESCTP" ) ) + "." //"Foi para o passo: "
						EndiF
					Else

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifico as Etapas Paralelas Inconsistente para gravação do campo memo da ADF				³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Len(aIncEtp) > 0

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Alimento a variavel cPassos com as Etapas Paralelas Inconsistente 	 						³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nY := 1 To Len(aIncEtp)
								If nY == 1
									cPassos := aIncEtp[nY][2] + " - " + AllTrim( Posicione("QID",1,xFilial("QID")+aIncEtp[nY][2],"QID_DESCTP") )
								Else
									cPassos += ", " + aIncEtp[nY][2] + " - " + AllTrim( Posicione("QID",1,xFilial("QID")+aIncEtp[nY][2],"QID_DESCTP") )
							    EndIf
						    Next

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Gravo as Etapas Paralelas Inconsistente no Campo Memo dos Itens do Chamado					³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aColsADF[nItemPos][nObsPos] := STR0124 + cPassos  + "."	//"Foram para o(s) passo(s): "
							aColsADF[nItemPos][nObsPos] += CRLF + cMemo

						Else

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Caso a cStatus esteja em Branco e Não há Incons. Etapas Paralelas será o Ultimo Passo		³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aColsADF[nItemPos][nObsPos] += STR0041 + " - " + AllTrim( cDescEtapa ) + "." //"Último passo do plano de ação: "
							aColsADF[nItemPos][nObsPos] += CRLF + cMemo

						EndIf
					EndIf
				Else
					aColsADF[nItemPos][nObsPos] += AllTrim( cDescEtapa ) + "."
				EndIf
			EndIf

			If nActPos > 0
				If Empty(aColsADF[nItemPos][nActPos])
					aColsADF[nItemPos][nActPos]:= "AZAZAZ"
				EndIf
			EndIf

			Private ParamIXB := { aHeaderADF, aColsADF }
			TkRunAct(	aHeaderADF				, aColsADF					, nItemPos	, nObsPos				,;
						nItmPos					, nActPos					, nOcoPos	, nGrpPos				,;
						cStatus					, dRealiz					, cTPACAO	, lCancelStatusControl	,;
						lCancelSonReplication	, lCancelFatherReplication	, cFilOrig  , lReproSLA				,;
						aRegsWF	)
		EndIf
	Next
EndIf

If lTKUPCALL
	ExecBlock("TKUPCALL", .F., .F., {cCodChamado, cStatus, cOpcLote})
EndIf

TMKFree( oSLARegister )

RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |GetLastIt		ºAutor³Vendas Clientes   º Data ³  11/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o proximo codigo disponivel para item do atendimen-º±±
±±º          ³-to.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetLastIt(cCodCall)
Local cItem 	:= "000"
Local aArea 	:= GetArea()
Local cQuery 	:= ""
Local cAlias	:= "ADF"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem aHeader, aCols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("ADF")
	DbSetOrder(1)

	cQuery := "SELECT ADF_ITEM, ADF_FILIAL, ADF_CODIGO "
	cQuery += "FROM "+RetSqlName("ADF")+" ADF  WHERE "
	cQuery += "ADF.ADF_FILIAL = '" + xFilial("ADF") + "' AND "
	cQuery += "ADF.ADF_CODIGO = '" + cCodCall + "' AND "
	cQuery += "ADF.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY ADF.ADF_ITEM "

	cQuery	:= ChangeQuery(cQuery)
	cAlias := GetNextAlias()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

	While 	!(cAlias)->(EOF()) 					.AND.;
			(cAlias)->ADF_FILIAL == xFilial("ADF") .AND.;
			(cAlias)->ADF_CODIGO == cCodCall

		cItem := (cAlias)->ADF_ITEM
		(cAlias)->(DbSkip())
	End

	cItem := Soma1(cItem)

	DbSelectArea(cAlias)
	DbCloseArea()

	RestArea(aArea)
Return cItem

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |LoadACols		ºAutor³Vendas Clientes   º Data ³  11/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega o aCols e aHeader para atualizacao do atendimento. º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LoadACols(cCodCall, aColsADF, aHeaderADF)
Local aArea := GetArea()		// Salva a area
Local nX	:= 0 				// Contador de colunas
Local nUsado := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o cabecalho da GetDados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetorder(1)
DbSeek("ADF")
While !Eof() .AND. (X3_ARQUIVO == "ADF")

	If x3Uso(X3_USADO)
		nUsado++

		Aadd(aHeaderADF,{	X3TITULO(),;			// 01
						X3_CAMPO,;				// 02
						X3_PICTURE,;			// 03
						X3_TAMANHO,;			// 04
						X3_DECIMAL,;			// 05
						X3_VALID,;				// 06
						X3_USADO,;				// 07
						X3_TIPO,;				// 08
						X3_ARQUIVO,;			// 09
						X3_CONTEXT,;			// 10
						X3_PROPRI 	} )			// 11
	Endif
	DbSkip()
End
// Inclui coluna de registro atraves de funcao generica
ADHeadRec("ADF", aHeaderADF)
nUsado += 2


DbSelectArea("ADF")
DbSetorder(1)
MsSeek(xFilial("ADF") + cCodCall)

While !EOF() .AND. (ADF->ADF_FILIAL == xFilial("ADF") .AND. ADF->ADF_CODIGO == cCodCall)

	AADD(aColsADF,Array(nUsado+1))

	For nX := 1 to Len(aHeaderADF)

		If (aHeaderADF[nX][10] != "V" .AND. aHeaderADF[nX][08] != "M")
			aColsADF[Len(aColsADF)][nX] := FieldGet(FieldPos(aHeaderADF[nX][2]))
		Else
			If IsHeadAlias(aHeaderADF[nX][2])
				aColsADF[Len(aColsADF)][nX] := "ADF"
			ElseIf IsHeadRec(aHeaderADF[nX][2])
				aColsADF[Len(aColsADF)][nX] := Recno()
			ElseIf (aHeaderADF[nX][08] != "M")
				aColsADF[Len(aColsADF)][nX] := CriaVar(aHeaderADF[nX][2],.T.)
			ElseIf (aHeaderADF[nX][08] == "M")
				aColsADF[Len(aColsADF)][nX] := ""
			Else
				aColsADF[Len(aColsADF)][nX] := FieldGet(FieldPos(aHeaderADF[nX][2]))
			Endif
		Endif
		aColsADF[Len(aColsADF)][nUsado+1] := .F.

	Next nX

	DbSelectArea("ADF")
	DbSkip()
End

RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510SLA		ºAutor³Vendas Clientes   º Data ³  11/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controla o processo de SLA a partir da ocorrencia.      	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510SLA(cAcaoSLA, nItem, cFilTransf, cGrupoAtend, nCriticidade, cKeyInfo, lReproSLA)

Local oSLAService	:= SLAService():New()	// Objeto SLAService
Local aSLARegister	:= {}					// Array de retorno com dados do SLA
Local cCodRespons	:= RetCodUsr()			// Primeiro usuario responsavel pelo SLA
Local codService	:= ""					// Codigo do Servico de SLA
Local cTimeShift	:= ""					// Turno de trabalho do grupo de atendimento
Local lFimSla		:= .F.
Local lContinue		:= (cAcaoSLA == acaoINICIAR) .or. (cAcaoSLA == acaoATUALIZAR) .or. (cAcaoSLA == acaoPAUSAR)
Local cFilBKP		:= cFilAnt				// Filial Atual
Local lLoadService	:= nil
Local cDtInicioSLA	:= CTOD("")				// Data do inicio do SLA.
Local cHrInicioSLA	:= ""					// Hora do inicio do SLA.
Local nTimePaused	:= 0					// Pausa acumulada de SLA.
Local lTransFereFil	:= !Empty(cFilTransf)	// Identifica uma transfgerencia de chamado entre filiais
Local lAutomatico:= ExecSchedule()
Local lTkFimSLA		:= ExistBlock("TKFIMSLA")
Local cDtExpRepro	:= CTOD("")				// Data de expiração informada na reprogramação do SLA
Local cHrExpRepro	:= ""					// Hora de expiração informada na reprogramação do SLA
Local lTkVerCont	:= ExistBlock("TKVERCONT")	// Ponto de Entrada verificar se devrá forçar o calculo baseado no contrato.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Troca de Filial para carregar o respectivo contrato de SLA ³
//³quando for uma operacao de TRANSFERENCIA de chamado.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAnt	:= If(lTransFereFil,cFilTransf,cFilAnt)

// Seleciona o Servico de SLA
dbSelectArea("SU0")	// Grupo de Atendimento
dbSetOrder(1)
If SU0->(DBSeek(xFilial("SU0")+cGrupoAtend))
	codService	:= SU0->U0_SERVSLA
EndIf
// Seleciona o Turno de Trabalho
If !Empty(cGrupoAtend)
	If  SU0->(DBSeek(xFilial("SU0")+cGrupoAtend)) .And. !Empty(SU0->U0_TURNO)
		cTimeShift := SU0->U0_TURNO
	EndIf
EndIf
// Seleciona o Responsavel pelo SLA
If !Empty(cCodRespons)
	DbSelectArea("SK8")
	DbSetorder(2) //K8_FILIAL+K8_CODUSU
	If DbSeek(xFilial("SK8")+cCodRespons)
		cCodRespons := SK8->K8_CODRESP
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Filial.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAnt	:= cFilBKP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Este ponto de entrada tem a função de forçar que o SLA  ³
//³ avalie o contrato, mesmo que o chamado tenha sido       ³
//³ reprogramado.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTkVerCont
	lTkVerCont := ExecBlock("TKVERCONT",.F.,.F.,{ADE->ADE_CODIGO,lReproSLA})
	If ValType(lTkVerCont) == "L"
		lReproSLA := lTkVerCont
	EndIf
EndIf

If cAcaoSLA == acaoINICIAR .or. lTransFereFil

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se ja houver um SLA para o chamado ³
	//³ Finaliza antes de iniciar um novo  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( ADE->ADE_REGSLA )
		If lTransFereFil
			// Armazena dados do registro origem na transferencia
			oSLAService:oSLARegister:load( ADE->ADE_REGSLA )
			cDtInicioSLA := oSLAService:oSLARegister:createdDate
			cHrInicioSLA := oSLAService:oSLARegister:createdHour
			nTimePaused  := oSLAService:oSLARegister:PausedTime
			If lReproSLA
				cDtExpRepro := oSLAService:oSLARegister:dateToExpire
				cHrExpRepro := oSLAService:oSLARegister:hourToExpire
			EndIf
		Endif

		If oSLAService:finish( ADE->ADE_REGSLA )
			oSLAService:save()
		EndIf
		oSLAService	:= SLAService():New()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Troca de Filial para carregar o respectivo contrato de SLA ³
	//³quando for uma operacao de TRANSFERENCIA de chamado.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilAnt			:= If(!Empty(cFilTransf),cFilTransf,cFilAnt)
	lLoadService	:= oSLAService:load( codService )

	If lLoadService
		If !lReproSLA
			If oSLAService:find( cTimeShift )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cria um novo registro para o servido de SLA encontrado ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If oSLAService:start(cCodRespons, , cTimeShift, cDtInicioSLA, cHrInicioSLA, nTimePaused)
					//Salva o registro de SLA (SK5)
					oSLAService:oSLARegister:keyInfo := cKeyInfo
					oSLAService:save()
				EndIf
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houver uma reprogramação no prazo do SLA (TMK006), ³
			//³ ignora o contrato e suas severidades.				  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oSLAService:start(cCodRespons, , cTimeShift, cDtInicioSLA, cHrInicioSLA, nTimePaused, lReproSLA, cDtExpRepro, cHrExpRepro)
				//Salva o registro de SLA (SK5)
				oSLAService:oSLARegister:keyInfo := cKeyInfo
				oSLAService:save()
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura a Filial.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilAnt			:= cFilBKP

	If (Empty(ADE->ADE_HINISL).Or. Empty(ADE->ADE_REGSLA));
	  .AND. !Empty(oSLAService:getRegisterID())

		BEGIN TRANSACTION
			RecLock("ADE", .F.)
			REPLACE ADE->ADE_DINISL WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
			REPLACE ADE->ADE_HINISL WITH Time()
			MsUnlock()
		END TRANSACTION

	EndIf

ElseIf cAcaoSLA == acaoFINALIZAR .and. (!Empty(ADE->ADE_REGSLA))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega e finaliza o reg. de SLA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oSLAService:finish( ADE->ADE_REGSLA )
		oSLAService:save()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria um novo registro, caso seja executado a ação de  ³
	//³ finaliza após um registro pausado.                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (oSLAService:getRegStatus() == "2" .And. oSLAService:getRegPaused())
		If !lReproSLA
			If oSLAService:load( codService )
				oSLAService:oSLARegister:load( ADE->ADE_REGSLA )
				oSLAService:showDialog := "2"		//Inibe a janela de severidade
				If oSLAService:find( cTimeShift )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cria um novo registro para o SLA encontrado ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If oSLAService:update(cCodRespons, ADE->ADE_REGSLA, cTimeShift)
						//Salva o registro de SLA (SK5)
						oSLAService:oSLARegister:keyInfo := cKeyInfo
						oSLAService:save()
					Else
						If oSLAService:start(cCodRespons, , cTimeShift)
							//Salva o registro de SLA (SK5)
							oSLAService:oSLARegister:keyInfo := cKeyInfo
						 	oSLAService:save()
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Encerra o registro que foi gerado.			³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If oSLAService:finish(oSLAService:oSLARegister:RegisterID)
						oSLAService:save()
					EndIf
					lFimSla := .T.
				EndIf
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houver uma reprogramação no prazo do SLA (TMK006), ³
			//³ ignora o contrato e suas severidades.				  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oSLAService:load( codService )
				If oSLAService:update(cCodRespons, ADE->ADE_REGSLA, cTimeShift, Nil, lReproSLA)
					//Salva o registro de SLA (SK5)
					oSLAService:oSLARegister:keyInfo := cKeyInfo
					oSLAService:save()
				EndIf
				If oSLAService:finish(oSLAService:oSLARegister:RegisterID)
					oSLAService:save()
				EndIf
				lFimSla := .T.
	        EndIf
		EndIf
    EndIf

	If  !Empty(oSLAService:getRegisterID())

		BEGIN TRANSACTION
			RecLock("ADE", .F.)
			REPLACE ADE->ADE_DENCSL WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
			REPLACE ADE->ADE_HENCSL WITH Time()
			MsUnlock()
		END TRANSACTION

	EndIf
ElseIf cAcaoSLA == acaoATUALIZAR

    If lAutomatico .and. (Empty(ADE->ADE_REGSLA))
		lContinue := SuperGetMv("MV_TMKUSLA",,.T.)
    ElseIf (Empty(ADE->ADE_REGSLA))
	    If SuperGetMv("MV_TMKPSLA",,.F.)
	    	lContinue := IW_MsgBox('O chamado nao possui SLA. Deseja iniciar um SLA? ', 'TK510SLA-Controle de SLA',"YESNO")
	    Else
		    lContinue := SuperGetMv("MV_TMKUSLA",,.T.)
		EndIf
    EndIf

	If lContinue
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza reg. de SLA ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lReproSLA
			If oSLAService:load( codService )
				oSLAService:oSLARegister:load( ADE->ADE_REGSLA )
				If oSLAService:find( cTimeShift )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cria um novo registro para o SLA encontrado ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If oSLAService:update(cCodRespons, ADE->ADE_REGSLA, cTimeShift)
						//Salva o registro de SLA (SK5)
						oSLAService:oSLARegister:keyInfo := cKeyInfo
						oSLAService:save()
					Else
						If oSLAService:start(cCodRespons, , cTimeShift)
							//Salva o registro de SLA (SK5)
							oSLAService:oSLARegister:keyInfo := cKeyInfo
							oSLAService:save()
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houver uma reprogramação no prazo do SLA (TMK006), ³
			//³ ignora o contrato e suas severidades.				  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oSLAService:load( codService )
				If oSLAService:update(cCodRespons, ADE->ADE_REGSLA, cTimeShift, Nil, lReproSLA)
					//Salva o registro de SLA (SK5)
					oSLAService:oSLARegister:keyInfo := cKeyInfo
					oSLAService:save()
				EndIf
	        EndIf
		EndIf

        If !Empty(oSLAService:getRegisterID())

			BEGIN TRANSACTION
    			RecLock("ADE", .F.)
    			REPLACE ADE->ADE_DATUSL WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
    			REPLACE ADE->ADE_HATUSL WITH Time()
    			MsUnlock()
			END TRANSACTION

    		// caso nao tenha gravado o SLA
		    If (Empty(ADE->ADE_HINISL) .or. Empty(ADE->ADE_REGSLA))

    			BEGIN TRANSACTION
    				RecLock("ADE", .F.)
    				REPLACE ADE->ADE_DINISL WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
    				REPLACE ADE->ADE_HINISL WITH Time()
    				MsUnlock()
    			END TRANSACTION

    		EndIf
    	EndIf
    EndIf

ElseIf cAcaoSLA == acaoPAUSAR .and. (!Empty(ADE->ADE_REGSLA))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pausa reg. de SLA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oSLAService:load( codService )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria um novo registro para o SLA encontrado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oSLAService:pause(cCodRespons, ADE->ADE_REGSLA, cTimeShift)
			//Salva o registro de SLA (SK5)
			oSLAService:oSLARegister:keyInfo := cKeyInfo
			oSLAService:save()
		EndIf
	EndIf
	If !Empty(oSLAService:getRegisterID())

		BEGIN TRANSACTION
			RecLock("ADE", .F.)
			If Empty(ADE->ADE_HPSE1S)
				REPLACE ADE->ADE_DPSE1S WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
				REPLACE ADE->ADE_HPSE1S WITH Time()
			EndIf
			REPLACE ADE->ADE_DPSEUL WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
			REPLACE ADE->ADE_HPSEUL WITH Time()
			MsUnlock()
		END TRANSACTION

	EndIf

EndIf

If lContinue
	TK510PrtEnt(oSLAService, ADE->ADE_CODIGO, "Chamado Help Desk")
EndIf

If (lContinue .Or. lFimSla) .AND. !Empty(oSLAService:getRegisterID())
	aAdd(aSLARegister, oSLAService:getRegisterID())
	aAdd(aSLARegister, oSLAService:getDateToExpire())
	aAdd(aSLARegister, oSLAService:getSeverity())
	aAdd(aSLARegister, oSLAService:oSLARegister:hourToExpire)
EndIf

If lTkFimSLA
	ExecBlock("TKFIMSLA",.F.,.F.,{aSLARegister})
Endif

TMKFree( oSLAService )

Return aSLARegister

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |TK510PrtEnt	ºAutor³Vendas Clientes   º Data ³  14/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Registra as entidades que serão utilizadas para localizar  º±±
±±º          ³ o contrato de SLA                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510PrtEnt(oSLAService, cChave, cNomeChave)
Local lLog := SuperGetMv("MV_TKSLALG",,.F.)
Local cFileLog := ""                 //Path do arquivo de log a ser gravado
Local nAux                           //Auxilia na construcao do arquivo de log
Local cText := ""
Local nI	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Grava o Log se estiver habilitado. |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLog

	cText := "-------------------------------------------------" + CRLF
	cText += "  " + DtoC(If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )) + " " + TIME() + " " + CRLF
	cText += cNomeChave + ": " + cChave + CRLF
	For nI := 1 To Len(oSLAService:entities)
		cText += "[" + AllTrim(Str(nI)) + "] = " + oSLAService:entities[nI]:entityName + " = " + oSLAService:entities[nI]:entityValue + CRLF
	Next nI

	If !Empty(oSLAService:getRegisterID())
		cText += "No do Registro de SLA: " + oSLAService:getRegisterID() + CRLF
	Else
		cText += "Nao encontrou um contrato de SLA." + CRLF
	EndIf
	cText += "-------------------------------------------------"  + CRLF


	cFileLog  := ALLTRIM(GetPvProfString(GetEnvServer(),"startpath","",GetADV97()))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Monta o nome do arquivo de log que sera grava no StartPath (SIGAADV)          |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Subs(cFileLog,Len(cFileLog),1) <> "\"
		cFileLog += "\"
	Endif

	cFileLog += "TMKSLALOG.LOG"

	If File(cFileLog)
		nAux := fOpen(cFileLog, FO_READWRITE+FO_SHARED)
	Else
		nAux := fCreate(cFileLog,0)
	EndIf

	If nAux != -1
	   	FSeek(nAux,0,2)
		FWrite(nAux, AllTrim(cText + CRLF))
		FClose(nAux)
	EndIf
EndIf
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510Critic	ºAutor³Vendas Clientes   º Data ³  14/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula criticidade para o chamado do Help-desk atraves 	  º±±
±±º          ³ de formula padronizada                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510Critic()
Local nCriticidade := 0							//Criticidade a ser calculada pela formula
Local nCliPerfil 	:= 0						//Perfil do Cliente
Local nProdPerfil 	:= 0						//Perfil do Produto
Local nSevCod		:= Val(ADE->ADE_SEVCOD)		//Severidade escolhida no chamado

/*DbSelectArea("SB1")
DbSetOrder(1)
If DbSeek(xFilial("SB1")+ADE->ADE_CODSB1)
	nProdPerfil := SB1->B1_PERFIL
	If Empty(nProdPerfil)
		nProdPerfil := 1
	EndIf
EndIf

DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek(xFilial("SA1")+ADE->ADE_CHAVE)
	nCliPerfil := SA1->A1_PERFIL
	If Empty(nCliPerfil)
		nCliPerfil := 1
	EndIf
EndIf*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar formula para definir criticidade/severidade 			 ³
//³ (Perfil cliente * 4) + (Peso Rotina * 3) + (Tipo Problema * 200) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nCriticidade := ((nCliPerfil * 4) + (nProdPerfil * 3) + (nSevCod * 200))
If ValType(nCriticidade) <> "N"
	nCriticidade := 0
EndIf

If Empty(nCriticidade)
	nCriticidade := SuperGetMv("MV_TMKSEV",,100)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada p/ substituir o valor calculado pela formula ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("TK510FORMU")
	nCriticidade := ExecBlock("TK510FORMU",.F.,.F.,{nCriticidade})
	If ValType(nCriticidade) <> "N"
		nCriticidade := 0
	EndIf
EndIf

Return nCriticidade


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tk510KBase       ³Autor  ³Vendas Clientes  ³ Data ³ 01/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada do botão do banco de conhecimento.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HELP DESK  						                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk510KBase()

Local aRotBack := aClone(aRotina)							// Backup do vetor aRotina
Local aSArea   := GetArea()									// Backup da area atual
Local cChave   := ""										// Chave de busca
Local aSavAhead:= Iif(Type("aHeader")=="A",aHeader,{})		// Backup do aheader
Local aSavAcol := Iif(Type("aCols")=="A",aCols,{})			// Backup do acols
Local nSavN    := Iif(Type("aCols")=="A",n,0)				// Backup do numero da linha atual
Local lRet     := .T.										// Retorno da funcao

Local cCampoSav:= cCampo  	//Nome do campo
Local oGetdSav := oGetd		//Objeto MsGetDados
Local aTelaSav := aTela		//Array passado na funcao Obrigatorio
Local aGetsSav :=aGets		//Array passado na funcao Obrigatorio
Local cCadastroSav := cCadastro 	//"Atendimento"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Altera n para getdados do banco de conhecimento.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
n:=1

aRotina := {}
Aadd(aRotina,{STR0037,"MsDocument", 0 , 4})   // "Conhecimento"

cChave   := M->ADE_CODIGO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama a alteração dos dados da entidade.			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ADE")
DbSetOrder(1)
If MsSeek(xFilial("ADE") + cChave)
	MsDocument( Alias(), RecNo(), 1)
Else
	Help( " ",1,"SEMCHAMADO",,STR0038 + CRLF + STR0039,1,1)			                    // "Não é possivel anexar um documento " # " antes de incluir o chamado"
	lRet := .F.
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Integridade dos Dados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	aHeader := aSavAHead
	aCols   := aSavaCol
	n       := nSavN
	cCampo	:= cCampoSav
	oGetd 	:= oGetdSav
	aTela	:= aTelaSav
	aGets	:= aGetsSav
	cCadastro	:= cCadastroSav
Endif

aRotina := {}
aRotina := aClone(aRotBack)
RestArea(aSArea)

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk510JobSendWF³ Autor ³ Vendas Clientes   ³ Data ³ 21/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para o envio de WorkFlow fora da thread de atendimento±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMKA271       	        						          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk510JobSendWF(cCodTemplate, aHeaderADF, aColsADF, cCodChamado, nItem, nItemPos, cEmp, cFil)
Local bBlock := {||}
Local bErro := ErrorBlock()   	//Armazena o tratamento de erro padrao do protheus
Local cTextErr := ""
Local lErro := .F.

Private nModulo    := 99    					// Nao conta como novo usuario

	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO "TMK" TABLES "ADE","ADF","SB1","SA1","SU5","SUH","SU9","SUQ","SU7","SU0"

	DbSelectArea("ADE")
	DbSetOrder(1) //ADE_FILIAL+ADE_CODIGO
	MsSeek(xFilial("ADE")+cCodChamado)

	bBlock := {|err|lErro := .T.}
	ErrorBlock(bBlock)
	Tk510WF(cCodTemplate, ADE->ADE_CODIGO, aColsADF[nItem][nItmPos])
	ErrorBlock(bErro)
	/*If lErro
		cTextErr := CRLF + Replicate("*", 73) + CRLF + "[" + DToC(Date()) + " " + Time() + "] Mensagem do Sistema : Não foi possivel enviar o WorkFlow ao destinatário." + CRLF + Replicate("*", 73)
		DbSelectArea("ADF")
		DbSetOrder(1)
		If DbSeek(xFilial("ADF")+cCodChamado+aColsADF[nItem][nItemPos])
			cTextErr := MSMM(ADF->ADF_CODOBS,TamSx3("ADF_OBS")[1]) + cTextErr
			If !Empty(ADF->ADF_CODOBS)
				MSMM(ADF->ADF_CODOBS,TamSx3("ADF_OBS")[1],,cTextErr,1,,,"ADF","ADF_CODOBS")
			Else
				BEGIN TRANSACTION
					RecLock("ADF", .F.)
					MSMM(,TamSx3("ADF_OBS")[1],,cTextErr,1,,,"ADF","ADF_CODOBS")
					MsUnlock()
				END TRANSACTION
			EndIf
		EndIf
	EndIf                            	*/
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TK510Fecha    ³ Autor ³ Vendas Clientes   ³ Data ³ 18/08/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao executada no encerramento da tela de atendimento.    |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMKA271       	        						          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TK510Fecha()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha outro analista manipulando o mesmo chamado      	  |
//³ So libera se o analista estiver ha mais de 2 horas alocado.    	  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TK510UsrLock("U", M->ADE_CODIGO, TkOperador())

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510Imprime  ºAutor³Vendas Clientes   º Data ³  24/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime um atendimento.                                 	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510Imprime()

TMKR506(M->ADE_CODIGO)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510ValAss   ºAutor³Vendas Clientes   º Data ³  13/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao na digitacao do assunto no Teleatendimento.   	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510ValAss()
Local cAssunto 	:= &(ReadVar())
Local aAreaSKK 	:= SKK->(GetArea())
Local lRet		:= .F.

DbSelectArea("SKK")
DbSetOrder(1)
MsSeek(xFilial("SKK")+M->ADE_GRUPO)
While !EOF() .AND. SKK->KK_CODSU0 == M->ADE_GRUPO
   	If SKK->KK_CODSKQ == cAssunto
   		lRet := .T.
   		Exit
   	EndIf
	DbSkip()
End

If !lRet
	Help(" ",1,"ASSUNTOS" )
EndIf

RestArea(aAreaSKK)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TK510TATE    ³ Autor ³Vendas CRM          ³ Data ³04/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o Tempo de Atendimento Medio de um chamado.         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510TAME(	cCodChama, 	dDataIni, 	dDataFim, 	cCodSU0Ini,;
					cCodSU0Fim, cCodSU7Ini, cCodSU7Fim)
Local cQuery := ""
Local cAlias := ""
Local nHoras := 0
Local nDifHr := 0

Default cCodChama 	:= ""
Default dDataIni 	:= ""
Default dDataFim 	:= ""
Default cCodSU0Ini 	:= ""
Default cCodSU0Fim 	:= ""
Default cCodSU7Ini 	:= ""
Default cCodSU7Fim 	:= ""

DbSelectArea("ADF")

cQuery := "SELECT	ADF_DATA, ADF_HORA, ADF_HORAF "
cQuery += "FROM "+ RetSqlName("ADF") + " ADF "
cQuery += "WHERE ADF_FILIAL = '" + xFilial("ADF") + "' AND "

If !Empty(cCodChama)
	cQuery += " ADF_CODIGO = '" + cCodChama + "' AND "
EndIf

If !Empty(dDataIni) .AND. !Empty(dDataFim)
	cQuery += " ADF_DATA BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' AND "
EndIf

If Empty(cCodChama)
	cQuery += " ADF_CODSU0 BETWEEN '" + cCodSU0Ini + "' AND '" + cCodSU0Fim + "' AND "
EndIf

If Empty(cCodChama)
	cQuery += " ADF_CODSU7 BETWEEN '" + cCodSU7Ini + "' AND '" + cCodSU7Fim + "' AND "
EndIf

cQuery += " ADF.D_E_L_E_T_=' ' "

cQuery	:= ChangeQuery(cQuery)
cAlias := GetNextAlias()
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
TCSetField(cAlias, "ADF_DATA"	, "D")

While (cAlias)->(!EOF())
	If !Empty((cAlias)->ADF_HORAF)
		nDifHr := SubtHoras((cAlias)->ADF_DATA,(cAlias)->ADF_HORA,(cAlias)->ADF_DATA,(cAlias)->ADF_HORAF)
		If nDifHr > 0
			nHoras += nDifHr
		EndIf
	EndIf
	(cAlias)->(DbSkip())
End
(cAlias)->(dbCloseArea())

Return IntToHora(nHoras)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TK510TATE    ³ Autor ³Vendas CRM          ³ Data ³04/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o Tempo de Medio de Atendimento                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510TMA(	cCodChama, 	dDataIni, 	dDataFim, 	cCodSU0Ini,;
					cCodSU0Fim, cCodSU7Ini, cCodSU7Fim)
Local cQuery := ""
Local cAlias := ""
Local nHoras := 0
Local nItens := 0
Local nDifHr := 0

DbSelectArea("ADF")

cQuery := "SELECT	ADF_DATA, ADF_HORA, ADF_HORAF "
cQuery += "FROM "+ RetSqlName("ADF") + " ADF "
cQuery += "WHERE ADF_FILIAL = '" + xFilial("ADF") + "' AND "

 	If !Empty(cCodChama)
	cQuery += " ADF_CODIGO = '" + cCodChama + "' AND "
EndIf

If !Empty(dDataIni) .AND. !Empty(dDataFim)
	cQuery += " ADF_DATA BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' AND "
EndIf

If Empty(cCodChama)
	cQuery += " ADF_CODSU0 BETWEEN '" + cCodSU0Ini + "' AND '" + cCodSU0Fim + "' AND "
EndIf

If Empty(cCodChama)
	cQuery += " ADF_CODSU7 BETWEEN '" + cCodSU7Ini + "' AND '" + cCodSU7Fim + "' AND "
EndIf

cQuery += "ADF.D_E_L_E_T_=' ' "

cQuery	:= ChangeQuery(cQuery)
cAlias := GetNextAlias()
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
TCSetField(cAlias, "ADF_DATA"	, "D")

While (cAlias)->(!EOF())
	If !Empty((cAlias)->ADF_HORAF)
		nDifHr := SubtHoras((cAlias)->ADF_DATA,(cAlias)->ADF_HORA,(cAlias)->ADF_DATA,(cAlias)->ADF_HORAF)
		If nDifHr > 0
			nHoras += nDifHr
			nItens +=1
		EndIf
	EndIf
	(cAlias)->(DbSkip())
End
nHoras := nHoras / nItens
(cAlias)->(dbCloseArea())

Return IntToHora(nHoras)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tk510PrfDesc ³ Autor ³Vendas CRM          ³ Data ³27/05/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o Tempo de Medio de Atendimento                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510PrfDesc(cEntidade, cChave, nTipo)
Local cRet 		:= ""
Local aArea		:= GetArea()
Local aAreaSX3 	:= SX3->(GetArea())
Local nPos 		:= 0
Local lTK510DPRF:= ExistBlock("TK510PROFILE") // Ponto de entrada para o preenchimento de informações do profile de entidades personalizadas
Local lTK510APRF:= ExistBlock("TK510TOBS")	  // Ponto de entrada para o preenchimento de informações adicionais das observacoes do Perfil
Local cPRFRet	:= ""

Default nTipo := 1

Do Case
	Case (cEntidade == "SA1")
		DbSelectArea("SA1")
		DbSetOrder(1)
		If 	MsSeek( xFilial("SA1")+cChave )		.AND.;
			(Empty(SA1->A1_PRF_VLD) .OR. SA1->A1_PRF_VLD >= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ))

			If nTipo == 1
				If Len(aSA1Box) <= 0
					DbSelectArea("SX3")
					DbSetOrder(2)
					If MsSeek("A1_TIPPRFL")
						aSA1Box := &('{"' + StrTran(AllTrim( X3CBox() ),';','","') + '"}')
					EndIf
				EndIf

				nPos := aScan(aSA1Box, SA1->A1_TIPPRFL + "=")
				If nPos > 0
				     cRet := Substr(aSA1Box[nPos],At("=",aSA1Box[nPos])+1,Len(aSA1Box[nPos]))
				EndIf
			ElseIf nTipo == 2
				cRet := SA1->A1_PRF_OBS
				if !empty(ADE->ADE_CODOBS)
				   cRet := cRet + CRLF + MSMM(ADE->ADE_CODOBS, TamSx3("ADE_OBSMEM")[1])
				endif
			EndIf
		EndIf

	Otherwise
		If lTK510DPRF
			cPRFRet := ExecBlock("TK510PROFILE",.F.,.F., {cEntidade, cChave, nTipo})
			If Type("cPRFRet") == "C"
				cRet := cPRFRet
			EndIf
		EndIf
End

If ( lTK510APRF .and. (nTipo == 2) )
	If ( ValType( uRet := ExecBlock("TK510TOBS",.F.,.F., {cEntidade, cChave, nTipo, cRet}) ) == "C" )
		cRet := uRet
	EndIf
EndIf

RestArea(aAreaSX3)
RestArea(aArea)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510ReprogSLAºAutor³Vendas Clientes   º Data ³  29/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Reprograma o prazo do SLA de um chamado.                	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510ReprogSLA()
Local aAreaADE := ADE->(GetArea())

If INCLUI .OR. ALTERA
	If TK510kReclass(M->ADE_CODIGO)
		DbSelectArea("ADE")
		DbSetOrder(1)
		If MsSeek( xFilial("ADE") + M->ADE_CODIGO )
			M->ADE_DTEXPI := ADE->ADE_DTEXPI
			M->ADE_HREXPI := ADE->ADE_HREXPI
			M->ADE_CODORI := ADE->ADE_CODORI
			M->ADE_CODEFE:= ADE->ADE_CODEFE
			M->ADE_CODCAU:= ADE->ADE_CODCAU
			M->ADE_CODCAT := ADE->ADE_CODCAT
			M->ADE_SEVCOD := ADE->ADE_SEVCOD
		EndIf
	EndIf
EndIf

RestArea(aAreaADE)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510RegMon   ºAutor³Vendas Clientes   º Data ³  17/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se ha regras de monitoracao de chamados no Serviceº±±
±±º          ³Desc                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Service Desk                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK510RegMon(nEvento, cAlias)
Local lUseJob := SuperGetMv("MV_TKUSEJB",,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se usa JOB para enviar o WF.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUseJob
	StartJob("TK510RegMJB", GetEnvServer(), .F.,	nEvento,				(cAlias)->ADE_CODIGO,	(cAlias)->ADE_CHAVE,		(cAlias)->ADE_CODSB1,;
													(cAlias)->ADE_SEVCOD,	(cAlias)->ADE_CODORI,	(cAlias)->ADE_CODEFE,		(cAlias)->ADE_CODCAT,;
													(cAlias)->ADE_CODCAU,	(cAlias)->ADE_GRUPO,	cEmpAnt, 					cFilAnt )
Else
	TK510LRegMon(	nEvento,				(cAlias)->ADE_CODIGO,	(cAlias)->ADE_CHAVE,		(cAlias)->ADE_CODSB1,;
					(cAlias)->ADE_SEVCOD,	(cAlias)->ADE_CODORI,	(cAlias)->ADE_CODEFE,		(cAlias)->ADE_CODCAT,;
					(cAlias)->ADE_CODCAU,	(cAlias)->ADE_GRUPO)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510RegMon   ºAutor³Vendas Clientes   º Data ³  17/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se ha regras de monitoracao de chamados no Serviceº±±
±±º          ³Desc, iniciado a partir de Job.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Service Desk                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510RegMJB(nEvento,	cCodChamado,	cCodEnt,	cCodSB1,;
								cSevCod,	cCodOri,		cCodEfe,	cCodCat,;
								cCodCau,	cCodGrupo,		cEmp, 		cFil )
Private nModulo    := 99    					// Nao conta como novo usuario

PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO "TMK" TABLES "ADE","ADF","SB1","SA1","SU5","SUH","SU9","SUQ","SU7","SU0","AGC","AGD"

DbSelectArea("ADE")
DbSetOrder(1) //ADE_FILIAL+ADE_CODIGO
MsSeek(xFilial("ADE")+cCodChamado)

TK510LRegMon(	nEvento,	cCodChamado,	cCodEnt,	cCodSB1,;
				cSevCod,	cCodOri,		cCodEfe,	cCodCat,;
				cCodCau,	cCodGrupo)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510WFACh    ºAutor³Vendas Clientes   º Data ³  20/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se há workflow de autorização com tempo limite de º±±
±±º          ³ resposta ultrapassado, iniciado a partir de Job.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Service Desk                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510WFACh(cEmp, cFil)
Local oWFTemplate	:= Nil
Local cHeadSKW		:= ""
Local nAuthStatus	:= 0
Local oNow			:= Nil
Local oLimitDate	:= Nil
Local dLastValidDate:= Nil
Local nHours		:= 0
Local cResp			:= ""
Local aAreaSKW		:= Nil
Local aAreaADE		:= Nil
Local aAreaADF		:= Nil
Local cJobName		:=	getWebJob()		//Nome do Job (Working Thread) em execucao


//ECM
Local aUsersECM		:= {}			//array com os usuarios que receberao notificacao do ECM
Local cXML			:= '' 			//xml com dados para envio do formulario ECM
Local cECMUser		:= ''    		//Usuario com acesso ao ECM
Local cECMPsw  		:= ''	    	//Senha de acesso ao ECM
Local nPos 			:= 0    			//Posicao do array utilizado no tratamento de erro.
Local aRetECM 	  	:= {} 			//Array com retorno da funcao BIStartTask.
Local nCountUser 		:= 0				//contador para percorrer o array de usuarios quando for wf informativo
Local cParams


While Right(cJobName,1) == "_"
	cJobName := Substr(cJobName, 1, rat("_", cJobName)-1)
Enddo

If Empty(cEmp)
	cEmp := GetPvProfString(cJobName,"EMPRESA","01",GetAdv97())
	cFil := GetPvProfString(cJobName,"FILIAL","01",GetAdv97())
EndIf

PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO "TMK" TABLES "ADE","ADF","SB1","SA1","SU5","SUH","SU9","SUQ","SU7","SU0", "SKY", "SKW"


cECMUser := SuperGetMv("MV_ECMUSER",,"adm")     //Usuario com acesso ao ECM
cECMPsw  := SuperGetMv("MV_ECMPSW",,"adm")      //Senha de acesso ao ECM

DbSelectArea("SKW")
aAreaSKW := SKW->(GetArea())

DbSelectArea("ADE")
DbSetOrder(9)

If ADE->(MsSeek( xFilial("ADE") + "2")) // Procura por chamados pendentes
	While	xFilial("ADE") == ADE->ADE_FILIAL //.And.;
			//"2" == ADE->ADE_STATUS
		If ( ADE->ADE_STATUS == "2" )
			If ADE->ADE_WFASTA == "5"
				DbSelectArea("ADF")
				DbSetOrder(1)
				If MsSeek( xFilial("ADF") + ADE->ADE_CODIGO )
					While 	ADF->ADF_FILIAL == xFilial("ADF") .AND.;
							ADF->ADF_CODIGO == ADE->ADE_CODIGO
						If !Empty(ADF->ADF_CODSKW)
							DbSelectArea("SKW")
							DbSetOrder(1)
							If MsSeek( xFilial("SKW") + ADF->ADF_CODSKW )

								aAreaSKY := SKY->(GetArea())
								DbSelectArea("SKY")
								DbSetOrder(1)
								If MsSeek( xFilial("SKY") + SKW->KW_MODELO ) //carrega o modelo de workflow


								 	If SKY->KY_TPWF == "2" //verifica se e de autorizacao
										cHeadSKW := SKW->KW_LOTEAPR
										If !(SKW->KW_AUTORIZ $ '12') //verifica se esta pendente (3 ou '')
											nHours := SKY->KY_TEMPOLI
											If nHours > 0
												oNow := TMKDateTime():This(dDatabase, Time())
												oLimitDate := TMKDateTime():This(SKW->KW_DATE, SKW->KW_TIME)
												dLastValidDate := Nil
												While nHours > 0
													If dLastValidDate <> oLimitDate:getDate()
														oLimitDate:setDate(DataValida( oLimitDate:getDate() ))
														dLastValidDate := oLimitDate:getDate()
													EndIf
													oLimitDate:plusHours(1)
													nHours -= 1
												End
												If oLimitDate:lessThan( oNow )
													If Empty(SKY->KY_TEMPORE) .Or. SKY->KY_TEMPORE == "1"
														cResp := "1"
													Else
														cResp := "2"
													EndIf
												EndIf

												If !Empty(cResp) .And. oLimitDate:lessThan( oNow )
													DbSelectArea("SKW")
													IF Empty(SKW->KW_AUTORIZ)
														RecLock("SKW", .F.)
														REPLACE SKW->KW_AUTORIZ WITH cResp
														REPLACE SKW->KW_OBS WITH STR0148 // "Resposta padrão por passar do tempo limite"
														REPLACE SKW->KW_TPAPROV WITH 'A' //tipo de aprovacao - automatica
														SKW->(MsUnLock())
													EndIf

													DbSetOrder(3)
													If MsSeek( xFilial("SKW") + cHeadSKW )
														While	SKW->KW_FILIAL == xFilial("SKW") .And.;
																SKW->KW_LOTEAPR == cHeadSKW .And. oLimitDate:lessThan( oNow )
															IF Empty(SKW->KW_AUTORIZ)
																RecLock("SKW", .F.)
																REPLACE SKW->KW_AUTORIZ WITH cResp
																REPLACE SKW->KW_OBS WITH STR0148 // "Resposta padrão por passar do tempo limite"
																REPLACE SKW->KW_TPAPROV WITH 'A' //tipo de aprovacao - automatica
																SKW->(MsUnLock())
															EndIf
															SKW->(DBSkip())
														End
													EndIf

													DbSetOrder(1)
													If MsSeek( xFilial("SKW") + cHeadSKW )
														aAreaADF := ADF->(GetArea())
														aAreaADE := ADE->(GetArea())

														RespAut510( ADE->ADE_CODIGO, ADF->ADF_ITEM )

														ADF->(RestArea(aAreaADF))
														ADE->(RestArea(aAreaADE))
													EndIf

												EndIf
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
						ADF->(DbSkip())
					End
				EndIf
			EndIf
		EndIf

		ADE->(DbSkip())
	End
EndIf

SKW->(RestArea(aAreaSKW))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510CFNC     ºAutor³Vendas Clientes   º Data ³  13/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta a ficha criada pelo chamado.                   	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510CFNC()

Local aArea		:= GetArea()
Local aAreaADE	:= ADE->(GetArea())
Local aAreaQI2	:= QI2->(GetArea())
Local lConsulta	:= .T.
Local lFncPai	:= .F.
Local cChamPAI	:= ""
Local cFilPai	:= cFilAnt
Local cFilAtu	:= cFilAnt
Local lFncOrig	:= !Empty(ADE->ADE_FNC)
Local cChamado	:= ADE->ADE_CODIGO

SaveInter()

Private INCLUI := .F.
Private ALTERA := .F.
Private EXCLUI := .F.
Private aRotina := {}

aAdd(aRotina, { STR0001 , "AxPesqui" , 0 , 1,,.F.} )  //"Pesquisar"
aAdd(aRotina, { STR0002 , "QNC040Alt", 0 , 2} )  //"Visualizar"

DbSelectArea("ADE")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o chamado original esta associado. Caso positivo, verifica se a ultima associacao (chamado pai) possui FNC.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Empty(ADE->ADE_CHANEX)
	cFilAnt := ADE->ADE_FLCHAN
	ADE->(MsSeek(xFilial("ADE")+ADE_CHANEX))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ao posicionar no chamado associado, verifica se o mesmo tambem esta associado.  						  ³
	//³Se estiver, passa para o proximo. Se nao estiver significa que e o pai, entao verifica se possui FNC   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(ADE->ADE_CHANEX) .And. !Empty(ADE->ADE_FNC)
		lFncPai := .T.
		cChamPAI:= ADE->ADE_CODIGO
		cFilPai	:= cFilAnt
	EndIf
EndDo

cFilAnt := cFilAtu

If lFncOrig .And. lFncPai //Chamado original e pai possuem FNC
	If Aviso(STR0012,STR0069+CRLF+; //"Help Desk"###"O chamado atual possui FNC, porém esta associado a outro chamado que também possui FNC."
                     STR0070,{STR0071,STR0072},2,STR0073) == 1//"Qual FNC deseja visualizar?"###"Ch.Atual"###"Ch.Pai"###"Consulta a FNC"
		ADE->(MsSeek(xFilial("ADE")+cChamado))
	Else
		cFilAnt := cFilPai
		ADE->(MsSeek(xFilial("ADE")+cChamPai))
	EndIf
ElseIf !lFncOrig .And. lFncPai //Chamado original não possui FNC e chamado pai possui
	If Aviso(STR0012,STR0074,{STR0075,STR0076},2,STR0073) == 1 //"Help Desk"###"O chamado atual não possui FNC, deseja consultar a FNC do chamado pai da associação?"###"Sim"###"Não"###"Consulta a FNC"
		cFilAnt := cFilPai
		ADE->(MsSeek(xFilial("ADE")+cChamPAI))
	Else
		lConsulta := .F.
	EndIf
ElseIf lFncOrig .And. !lFncPai //Chamado original possui FNC e chamado pai não possui
	ADE->(MsSeek(xFilial("ADE")+cChamado))
Else //Chamado original e pai não possuem FNC
	Aviso(STR0012,STR0077,{"Ok"},1,STR0073) //"Help Desk"###"Não foi gerada FNC."###"Consulta a FNC"
	lConsulta := .F.
EndIf

If lConsulta
	dbSelectArea("QI2")
	dbSetOrder(2)

	If DbSeek(xFilial("QI2")+ADE->(ADE_FNC+ADE_FNCREV))
		QNC040Alt("QI2",QI2->(Recno()),2)
	Else
		Aviso(STR0012,STR0078+ADE->ADE_FNC+"-"+ADE->ADE_FNCREV+STR0079+Alltrim(ADE->ADE_CODIGO)+STR0080,{"Ok"},1,STR0073)//"Help Desk"###"A FNC "###", do chamado: "###" não foi encontrada."###"Consulta a FNC"
	EndIf
EndIf

cFilAnt := cFilAtu

RestInter()

RestArea(aAreaADE)
RestArea(aAreaQI2)
RestArea(aArea)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA510LOAD   ºAutor³Vendas Clientes   º Data ³  08/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao executada na inicialização do TeleAtendimento com a º±±
±±º          ³exclusiva finalidade de corrigir o Modelo de Atendimento do º±±
±±º          ³Service Desk                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKA510LOAD()

CriaBotoes001()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaBotoes001 ºAutor³Vendas Clientes   º Data ³  08/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria novos botoes no Modelo de Atendimento padrao do Servi-º±±
±±º          ³-ce Desk.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaBotoes001()
Local aSKJ 		:= {}																//Registros a serem inseridos
Local aEstrutSKJ:= {"KJ_FILIAL",	"KJ_CODIGO",	"KJ_CODTELE", 	"KJ_TIPO",; 	//Estrutura do SKJ
					"KJ_NOME",		"KJ_NOMESPA",	"KJ_NOMEENG",	"KJ_NOMEPTG",;
					"KJ_POSICAO",	"KJ_AJUDA",		"KJ_AJUDASP",	"KJ_AJUDAEN",	"KJ_AJUDAPT",	"KJ_IMAGEM",;
					"KJ_CDBLOCK",	"KJ_USERLVL"}
Local nKACodigo := "000001" 														// Codigo do Modelo de Atendimento padrao do Service Desk
Local nCount	:= 0
Local nCols		:= 0
Local nItens	:= 0
Local aAreasSKJ := SKJ->(GetArea())
Local aUltBtn	:= {"0", "0"}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Botoes criados apos o P10 R 1.3     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aSKJ,{xFilial("SKJ"),"",nKACodigo,"1","Compart"				, "Compart"				, "Shared"				, "Compart"				,	"0","Consulta os chamados compartilhados por este chamado"	, "Consulta los llamados compartidos por este llamado"	, "Query shared calls by this call"			, "Consulta os chamados compartilhados por este chamado", "bmpgroup"	,"Tk510IConGr"		,"0"})
AAdd(aSKJ,{xFilial("SKJ"),"",nKACodigo,"1","Reprogr"				, "Reprogr"				, "Re-Sched"			, "Reprogr"				,	"0","Reprograma o prazo de SLA dos chamados"				, "Programa de nuevo el plazo de SLA de los llamados"	, "Redefines the term of SLA of the calls"	, "Reprograma o prazo de SLA dos chamados"				, "S4SB014N"	,"TK510ReprogSLA"	,"0"})
AAdd(aSKJ,{xFilial("SKJ"),"",nKACodigo,"2","FNC"					, "FNC"					, "NCF"					, "FNC"	   				,	"0","Consulta a FNC do chamado"								, "Consulta la FNC del llamado"							, "Queries FNC of the call"					, "Consulta a FNC do chamado"							, "QNCIMG16"	,"TK510CFNC"		,"0"})
AAdd(aSKJ,{xFilial("SKJ"),"",nKACodigo,"2","Perfil"				, "Perfil"				, "Profile"				, "Perfil" 				,	"0","Consulta Perfil do Contato"							, "Consulta Perfil de contacto"							, "Contact's Profile"						, "Consulta Perfil do Contato"							, "CRDIMG16"	,"TK510PROF"		,"0"})
AAdd(aSKJ,{xFilial("SKJ"),"",nKACodigo,"2",STR0121					, STR0121				, STR0121				, STR0121  				,	"0",STR0122													, STR0122												, STR0122									, STR0122												, "DEVOLNF"		,"Tk510Recor"		,"0"})

nItens := Len(aSKJ)
DbSelectArea("SKJ")
DbSetOrder(3)     //KJ_FILIAL+KJ_CODTELE+KJ_CODIGO
If DbSeek( xFilial("SKJ")+nKACodigo )
	While SKJ->(!EOF()) .AND.;
		SKJ->KJ_CODTELE == nKACodigo

		If KJ_TIPO == "1"
			If aUltBtn[1] < SKJ->KJ_POSICAO
				aUltBtn[1] := SKJ->KJ_POSICAO
			EndIf
		Else
			If aUltBtn[2] < SKJ->KJ_POSICAO
				aUltBtn[2] := SKJ->KJ_POSICAO
			EndIf
		EndIf

		For nCount := 1 To nItens
			If Len(aSKJ[nCount])>0 .AND. aSKJ[nCount][15] $ SKJ->KJ_CDBLOCK
				// Botao ja existe no Modelo
				aSKJ[nCount] := {}
			EndIf
		Next nCount
		SKJ->(DbSkip())
	End
EndIf

nItens := Len(aSKJ)
For nCount := 1 To nItens
	If Len(aSKJ[nCount])>0
		aSKJ[nCount][2] := TKNUMERO('SKJ','KJ_CODIGO')
		ConfirmSX8()
		aUltBtn[Val(aSKJ[nCount][4])] := Soma1(aUltBtn[Val(aSKJ[nCount][4])], TamSX3("KJ_POSICAO")[1])
		aSKJ[nCount][9] := aUltBtn[Val(aSKJ[nCount][4])]
		RecLock("SKJ",.T.)
		For nCols:=1 To Len(aSKJ[nCount])
			If FieldPos(aEstrutSKJ[nCols])>0
				FieldPut(FieldPos(aEstrutSKJ[nCols]),aSKJ[nCount,nCols])
			EndIf
		Next nCols
		dbCommit()
		MsUnLock()
	EndIf
Next nCount

RestArea(aAreasSKJ)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA510CBOXºAutor  ³Vendas e CRM       º Data ³  10/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³A partir do nome do campo, localiza no SX3 e retorna array  º±±
±±º          ³de 2 posicoes {codigo,descrição} do X3_CBOX                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKA510CBOX(cCampoX3)

Local nI 		:= 0
Local aBox 	:= {}
Local aBoxAux  := {}
Local aRet     := {}

Default cCampoX3 := ""

dbSelectArea("SX3")
dbSetOrder(2)
If !Empty(cCampoX3) .And. MsSeek(cCampoX3,.F.)

	aBox := STRTOKARR(AllTrim(X3Cbox()), ';')
	For nI := 1 to Len(aBox)
		aBoxAux := STRTOKARR(aBox[nI], '=')
		aAdd(aRet,aBoxAux )
	Next nI

EndIf

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510CompSLAºAutor³Vendas CRM          º Data ³  03/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a comparacao de SLA entre chamados que geram ou nao  º±±
±±º          ³FNC.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do chamado pai                               º±±
±±º          ³ExpC2 - Codigo do chamado atual                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510CompSLA(cChamadoPai,cChamadoAtu)

Local aArea			:= GetArea()
Local aAreaADE		:= ADE->(GetArea())
Local aAreaSK5		:= SK5->(GetArea())
Local oSLAChPai		:= Nil
Local oSLAChAtu		:= Nil
Local aFilhos		:= {}
Local lPaiComFNC	:= .F.
Local nTipoCmpSLA	:= SuperGetMV("MV_TMKASLA",,0)		// Tipo de comparacao de SLAs
Local lPossuiSLA	:= .T.
Local lTkCmpSLA		:= ExistBlock("TKCMPSLA")
Local lRetPE		:= .T.

Default cChamadoAtu	:= ADE->ADE_CODIGO

If nTipoCmpSLA == 0
	Return Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada que permite validar a associacao de SLAs³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTkCmpSLA
	lRetPE := ExecBlock("TKCMPSLA", .F., .F., {cChamadoPai,cChamadoAtu})
	If ValType(lRetPE) == "L" .AND. !lRetPE
		RestArea(aAreaSK5)
		RestArea(aAreaADE)
		RestArea(aArea)
		Return .F.
	EndIf
EndIf

DbSelectArea("SK5")
DbSetOrder(1) //K5_FILIAL+K5_CODIGO+K5_ITEM

DbSelectArea("ADE")
DbSetOrder(1)

If MsSeek(xFilial("ADE")+cChamadoPai) .AND. ADE->ADE_STATUS <> "3"

	aFilhos 	:= Tk510ChFilho(cChamadoPai,xFilial("ADE"))
	lPaiComFNC	:= !Empty(ADE->ADE_FNC)
	lPossuiSLA	:= !Empty(ADE->ADE_REGSLA)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o chamado pai (chamado que recebera' as associacoes) possuir FNC,       ³
	//³a data do chamado pai deve prevalecer, independente da data dos chamados.  ³
	//³Se o pai nao possuir FNC, ocorre a comparacao normal, onde a data do menor ³
	//³chamado deve prevalecer                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lPaiComFNC
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o pai tiver SLA iniciado, replica o SLA para os filhos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lPaiComFNC
			ADE->(MsSeek(xFilial("ADE")+cChamadoPai))
			Tk510UpdFilho(aFilhos,ADE->ADE_REGSLA)

	    EndIf

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O chamado pai possui FNC, a data deste chamado prevalece³
		//³sobre todos os outros chamados                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTipoCmpSLA >= 2
			ADE->(MsSeek(xFilial("ADE")+cChamadoPai))
			Tk510UpdFilho(aFilhos,ADE->ADE_REGSLA)
		EndIf
	EndIf
EndIf

TMKFree( oSLAChPai )
TMKFree( oSLAChAtu )

RestArea(aAreaSK5)
RestArea(aAreaADE)
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510SimSLAºAutor  ³Vendas e CRM       º Data ³  02/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Simula o prazo de SLA de um chamado caso uma FNC fosse aber-º±±
±±º          ³ta para o chamado corrente                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do chamado pai                               º±±
±±º          ³ExpO2 - Objeto (referencia) do controle de SLA simulado     º±±
±±º          ³ExpC3 - Codigo do chamado filho                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510SimSLA(cChPai,oSLASimu,cChFilho,aVencSLA)

Local aArea			:= GetArea()
Local aAreaSU0		:= SU0->(GetArea())
Local aAreaADE		:= ADE->(GetArea())
Local lGerFNC		:= .F.
Local nX			:= 0
Local nPosEnt		:= 0
Local aDataPrev		:= {}
Local aEntChamado	:= {}
Local codService	:= ""
Local cTimeShift	:= ""
Local cSLA			:= ""
Local lOk			:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acessa o chamado pai e obtem dados do grupo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ADE")
DbSetOrder(1)//ADE_FILIAL+ADE_CODIGO

If !MsSeek(xFilial("ADE")+cChPai)
	RestArea(aAreaSU0)
	RestArea(aArea)
	Return .F.
EndIf

dbSelectArea("SU0")
dbSetOrder(1)
lOk := MsSeek(xFilial("SU0")+ADE->ADE_GRUPO)

If lOk .AND. !Empty(SU0->U0_SERVSLA)
	codService	:= SU0->U0_SERVSLA
	If !Empty(SU0->U0_TURNO)
		cTimeShift := SU0->U0_TURNO
	EndIf
Else
	lOk := .F.
	RestArea(aAreaSU0)
	RestArea(aArea)
	Return lOk
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega os valores do chamado atual³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEntChamado := Tk510ReadEnt(codService,cChFilho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria objeto de tratamento de SLA para simulacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSLASimu:= SLAService():New()
oSLASimu:load( codService )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o objeto do SLA com valores das entidades do chamado³
//³atual (com excecao do grupo de atendimento)                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(oSLASimu:Entities)

	If oSLASimu:Entities[nX]:EntityName == "SU0"
		Loop
	EndIf

	nPosEnt := aScan(aEntChamado,{|x|x[1] == AllTrim(oSLASimu:Entities[nX]:EntityName)})

	If nPosEnt > 0
		oSLASimu:Entities[nX]:EntityValue := aEntChamado[nPosEnt][2]
	EndIf

Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Com os valores de entidades atualizados, executa a busca pelo SLA correto³
//³e verifica o prazo para conclusao do mesmo                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSLA 		:= oSLASimu:oSLARegister:findSLA(oSLASimu:entities)
aVencSLA	:= oSLASimu:oSLARegister:getTerm(cSLA,oSLASimu:getSeverity(),cTimeShift)

oSLASimu:start(,,cTimeShift)

RestArea(aAreaSU0)
RestArea(aAreaADE)
RestArea(aArea)

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510ReadEntºAutor  ³Vendas Clientes   º Data ³  03/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega lista das entidades utilizadas na avaliacao do SLA  º±±
±±º          ³de acordo com o servico e chamado utilizado                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do servico SLA                               º±±
±±º          ³ExpC2 - Codigo do chamado                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510ReadEnt(cCodService,cChamado)

Local aArea			:= GetArea()
Local aAreaADE		:= ADE->(GetArea())
Local aAreaADF		:= ADF->(GetArea())
Local cFilSUJ		:= xFilial("SUJ")
Local aEntidades	:= {}
Local nTamItem		:= TamSX3("ADF_ITEM")[1]
Local cCampo		:= ""

//Posiciona chamado
DbSelectArea("ADE")
DbSetOrder(1)//ADE_FILIAL+ADE_CODIGO
MsSeek(xFilial("ADE")+cChamado)

DbSelectArea("ADF")
DbSetOrder(1)//ADF_FILIAL+ADF_CODIGO+ADF_ITEM
MsSeek(xFilial("ADF")+cChamado+Replicate("z",nTamItem),.T.)
DbSkip(-1)

DbSelectArea("SUJ")
DbSetOrder(1) //UJ_FILIAL+UJ_CODIGO+UJ_ENTIDA
MsSeek(cFilSUJ + cCodService)

While !SUJ->(Eof()) 			.AND.;
	SUJ->UJ_FILIAL == cFilSUJ 	.AND.;
	SUJ->UJ_CODIGO == cCodService

	cCampo := AllTrim(SUJ->UJ_VALOR)
	AAdd(aEntidades,{AllTrim(SUJ->UJ_ENTIDA), &(cCampo) })

	SUJ->(DbSkip())
End

RestArea(aAreaADF)
RestArea(aAreaADE)
RestArea(aArea)

Return aEntidades

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510RestSLAºAutor  ³Vendas CRM        º Data ³  04/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Restaura o registro de controle de SLA original para os cha-º±±
±±º          ³mados passados via parametro                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - Codigo (ou array com codigos) do(s) chamado(s)      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510RestSLA(aChamado)

Local aArea		:= GetArea()
Local aAreaADE	:= ADE->(GetArea())
Local aAreaSK5	:= SK5->(GetArea())
Local nX		:= 0
Local cFilBkp	:= cFilAnt
Local cNovoSLA	:= ""

If ValType(aChamado) == "C"
	aChamado := &("{{'"+cFilAnt+"','"+aChamado+"'}}")
EndIf

DbSelectArea("SK5")
DbSetOrder(1)

DbSelectArea("ADE")
DbSetOrder(1)

For nX := 1 to Len(aChamado)

	cFilAnt := aChamado[nX][1]

	If MsSeek(xFilial("ADE")+aChamado[nX][2]) .AND. !Empty(ADE->ADE_SLAANT) .AND. !Empty(ADE->ADE_SLAANT)

		If cFilAnt == ADE->ADE_FLSLAN
			SK5->(MsSeek(xFilial("SK5")+ADE->ADE_SLAANT))
			cNovoSLA := SK5->K5_CODIGO
		Else
			cNovoSLA := Tk510CpSla(ADE->ADE_FLSLAN,cFilAnt,ADE->ADE_SLAANT)
			SK5->(MsSeek(xFilial("SK5")+cNovoSLA))
		EndIf

		RecLock("ADE", .F.)

		REPLACE ADE->ADE_REGSLA	WITH cNovoSLA		  		// Registro de SLA gerado
		REPLACE ADE->ADE_SLAANT	WITH ""						// Codigo do SLA anterior
		REPLACE ADE->ADE_FLSLAN WITH ""
		REPLACE ADE->ADE_DTEXPI	WITH SK5->K5_DTEXPIR			// Data para expirar o SLA
		REPLACE ADE->ADE_SESLA	WITH SK5->K5_SEVE			// Severidade usada no chamado
		REPLACE ADE->ADE_HREXPI	WITH SK5->K5_HREXPIR		//Hora para expirar o SLA

		MsUnlock()

		//Atualiza previsao da FNC
		Tk510UpdFNC(ADE->ADE_FNC,ADE->ADE_FNCREV,ADE->ADE_DTEXPI)

	ElseIf ADE->(dbSeek(xFilial("ADE")+aChamado[nX][2]))

		If Empty(ADE->ADE_REGSLA)

			Begin Transaction

				RecLock("ADE", .F.)

				ADE->ADE_FLSLAN := ""
				ADE->ADE_DTEXPI	:= CToD("")

				If TK510NewFields()
					ADE->ADE_SESLA	:= ""
				Else
					ADE->ADE_SEVSLA	:= ""
				EndIf

				ADE->ADE_HREXPI	:= ""
				ADE->(MsUnlock())

			End Transaction

		ElseIf SK5->(MsSeek(xFilial("SK5")+ADE->ADE_REGSLA))

			cNovoSLA := SK5->K5_CODIGO

			Begin Transaction

				RecLock("ADE", .F.)

				ADE->ADE_FLSLAN := ""
				ADE->ADE_DTEXPI	:= SK5->K5_DTEXPIR			// Data para expirar o SLA

				If TK510NewFields()
					ADE->ADE_SESLA	:= SK5->K5_SEVE			// Severidade usada no chamado
				Else
					ADE->ADE_SEVSLA	:= SK5->K5_SEVERID		// Severidade usada no chamado
				EndIf

				ADE->ADE_HREXPI	:= SK5->K5_HREXPIR		//Hora para expirar o SLA
				ADE->(MsUnlock())

			End Transaction

			//Atualiza previsao da FNC
			Tk510UpdFNC(ADE->ADE_FNC,ADE->ADE_FNCREV,ADE->ADE_DTEXPI)

		EndIf

	EndIf

Next nX

RestArea(aAreaADE)
RestArea(aAreaSK5)
RestArea(aArea)

cFilAnt := cFilBkp

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510ChFilhoºAutor  ³Vendas CRM        º Data ³  09/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna uma relacao de codigos de chamados associados ao    º±±
±±º          ³chamado principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do chamado principal                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510ChFilho(cChamadoPai,cFilPai,lRecursivo)

Local aRet		:= {}
Local aArea		:= GetArea()
Local aAreaADE	:= ADE->(GetArea())
Local aFiliais	:= Tk510Filiais()
Local cFilADE	:= "" //xFilial("ADE")
Local aFilhos	:= {}
Local nX 		:= 0
Local nFil		:= 0
Local cFilBkp	:= cFilAnt
Local lFlChan	:= .F.

Default cFilPai		:= xFilial("ADE")
Default lRecursivo	:= .F.

If FWModeAccess("ADE") == "C"
	aFiliais := {cFilAnt}
EndIf

lFlChan := Iif ( !Empty(ADE->ADE_FLCHAN), .T. , .F. )

DbSelectArea("ADE")
DbSetOrder(4)//ADE_FILIAL+ADE_CHANEX

For nFil := 1 to Len(aFiliais)

	cFilAnt := aFiliais[nFil]
	cFilADE	:= xFilial("ADE")

	MsSeek(cFilADE+cChamadoPai)

	While !ADE->(Eof()) 			.AND.;
		ADE->ADE_FILIAL == cFilADE 	.AND.;
		ADE->ADE_CHANEX == cChamadoPai

	    If lFlChan .AND. ADE->ADE_FLCHAN <> cFilPai
	    	ADE->(DbSkip())
	    	Loop
	    EndIf


		If lRecursivo
			AAdd(aRet,{ cFilAnt , ADE->ADE_CODIGO ,cChamadoPai})
		Else
			AAdd(aRet,{ cFilAnt , ADE->ADE_CODIGO })
		EndIf

		aFilhos := Tk510ChFilho(ADE->ADE_CODIGO,xFilial("ADE"),.T.)

		For nX := 1 to Len(aFilhos)
			AAdd(aRet,aFilhos[nX])
		Next nX

		ADE->(DbSkip())

	End

Next nFil

RestArea(aAreaADE)
RestArea(aArea)
cFilAnt := cFilBkp

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510UpdFilhoºAutor  ³Vendas CRM       º Data ³  09/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza os chamados associados a outro com o mesmo registroº±±
±±º          ³de SLA, de acordo com o parametro                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - Lista de chamados relacionados                      º±±
±±º          ³ExpC2 - Codigo do registro do SLA a ser gravado nos chamadosº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510UpdFilho(aFilhos,cCodSK5,lForce,cFilSK5,lTransfere)

Local aArea	   		:= GetArea()
Local aAreaADE		:= ADE->(GetArea())
Local aAreaSK5		:= SK5->(GetArea())
Local cFilBkp		:= cFilAnt
Local cFilADE		:= "" //xFilial("ADE")
Local cNovoSLA		:= ""
Local nX			:= 0
Local nRecSK5		:= 0
Local bTKUpdFlh		:= {|Pai,Filho,RegSLA| If(ExistBlock("TKUPDFLH"),ExecBlock("TKUPDFLH",.F.,.F.,{Pai,Filho,RegSLA}),.T.)}
Local cADECodPai	:= ADE->ADE_CODIGO
Local cFilK5Pai		:= ""
Local lAtuData		:= .T.
Local aCampos		:= {}

Default lForce	:= .F.
Default cFilSK5	:= cFilAnt
Default lTransfere := .F.

DbSelectArea("SK5")
DbSetOrder(1)

cFilAnt := cFilSK5
If Empty(cCodSK5) .OR. !MsSeek(xFilial("SK5")+cCodSK5)
	cFilAnt := cFilBkp
	Return Nil
EndIf

cFilAnt := cFilBkp
nRecSK5 := SK5->(Recno())

DbSelectArea("ADE")
DbSetOrder(1)	//ADE_FILIAL+ADE_CODIGO

For nX := 1 to Len(aFilhos)

	cFilAnt := aFilhos[nX][1]
	cFilADE := xFilial("ADE")

	If(cFilSK5 <> cFilAnt)
		SK5->(DbSeek(cFilSK5+cCodSK5))
	Else
		SK5->(DbGoTo(nRecSK5))
	EndIf

	If ADE->(MsSeek(cFilADE+aFilhos[nX][2])) .AND. (ADE->ADE_REGSLA <> cCodSK5 .OR. lForce)

		If Eval(bTKUpdFlh, cADECodPai, aFilhos[nX][2], ADE->ADE_REGSLA)

            If !Empty(ADE->ADE_SLAANT)
            	TK510SLAAT()
            EndIf

			If lTransfere
				cFilK5Pai	:= cFilSK5
			Else
				cFilK5Pai	:= Iif((cFilSK5 <> cFilAnt),cFilSK5,cFilAnt)
            EndIf

            If (Len(aFilhos[nX])>2)
       	 		lAtuData:= TK510CPSK5(ADE->ADE_CODIGO,ADE->ADE_CHANEX,cFilBkp,cFilK5Pai,,aFilhos)
            Else
            	lAtuData:= TK510CPSK5(ADE->ADE_CODIGO,ADE->ADE_CHANEX,cFilBkp,cFilK5Pai)
			EndIF

			If lAtuData
				Aadd(aCampos,SK5->K5_DTEXPIR)
				Aadd(aCampos,SK5->K5_HREXPIR)
			   	If TK510NewFields()
					Aadd(aCampos,SK5->K5_SEVE)
				Else
					Aadd(aCampos,SK5->K5_SEVERID)
			    EndIf
			Else
				aCampos := TK510RTPRZ(cFilBkp)
			EndIf

			If Len(aCampos) == 0 .OR. Len(aCampos)<3
				Aadd(aCampos,SK5->K5_DTEXPIR)
				Aadd(aCampos,SK5->K5_HREXPIR)
			   	If TK510NewFields()
					Aadd(aCampos,SK5->K5_SEVE)
				Else
					Aadd(aCampos,SK5->K5_SEVERID)
			    EndIf
			EndIf

			RecLock("ADE", .F.)

			REPLACE ADE->ADE_DTEXPI	WITH aCampos[1]			// Data para expirar o SLA
			If TK510NewFields()
				REPLACE ADE->ADE_SESLA	WITH aCampos[3]			// Severidade usada no chamado
			Else
				REPLACE ADE->ADE_SEVSLA	WITH aCampos[3]			// Severidade usada no chamado
			EndIf

			REPLACE ADE->ADE_HREXPI	WITH aCampos[2]		//Hora para expirar o SLA
		   ADE->( MsUnlock() )

			//Atualiza previsao da FNC
			Tk510UpdFNC(ADE->ADE_FNC,ADE->ADE_FNCREV,ADE->ADE_DTEXPI)

		EndIf

	EndIf

Next nX

RestArea(aAreaSK5)
RestArea(aAreaADE)
RestArea(aArea)

cFilAnt := cFilBkp

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510MenorSLAºAutor  ³Vendas CRM       º Data ³  10/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Determina qual o menor SLA entre uma lista de chamados      º±±
±±º          ³associados                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - Lista de chamados relacionados                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510MenorSLA(aChamRel)

Local aArea		  := GetArea()
Local aAreaSK5	  := SK5->(GetArea())
Local aAreaADE	  := ADE->(GetArea())
Local cRegSK5	  := ""
Local cFilSK5	  := ""
Local nX		  := 0
Local oMenorSLA	  := Nil
Local oSLAAtu	  := Nil
Local cFilBkp	  := cFilAnt
Local lTKMenorSLA := ExistBlock("TKMenorSLA")	// Determina se existe a rotina do PE criada o RPO
Local aRet        := {}							// Conteudo de retorno  do PE

DbSelectArea("SK5")
DbSetOrder(1)

DbSelectArea("ADE")
DbSetOrder(1)

For nX := 1 to Len(aChamRel)
	cFilant := aChamRel[nX][1]
	If 	ADE->(MsSeek(xFilial("ADE")+aChamRel[nX][2])) .AND.;
		!Empty(ADE->ADE_REGSLA) .AND. SK5->(MsSeek(xFilial("SK5")+ADE->ADE_REGSLA))

		oSLAAtu := TmkDateTime():This(SK5->K5_DTEXPIR,SK5->K5_HREXPIR)

		If oMenorSLA <> Nil
			If oSLAAtu:diffInHours(oMenorSLA,.F.) < 0
				oMenorSLA 	:= oSLAAtu:Clone()
				cRegSK5		:= SK5->K5_CODIGO
				cFilSK5		:= cFilAnt
			EndIf
		Else
			oMenorSLA := oSLAAtu:Clone()
			cRegSK5		:= SK5->K5_CODIGO
			cFilSK5		:= cFilAnt
		EndIf

		oSLAAtu := Nil

	EndIf
Next nX

TMKFree( oMenorSLA )
TMKFree( oSLAAtu )

If lTKMenorSLA
	aRet := ExecBlock("TKMenorSLA", .F., .F., {aChamRel})
	If ValType(aRet)=="A" .and. !Empty(aRet)
		cFilSK5 := aRet[1]
		cRegSK5 := aRet[2]
	EndIf
EndIf

RestArea(aAreaSK5)
RestArea(aAreaADE)
RestArea(aArea)

cFilAnt := cFilBkp

Return {cFilSK5,cRegSK5}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510GetPauseºAutor  ³Vendas CRM       º Data ³  11/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtem o tempo de pausa no SLA de um chamado                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do chamado                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510GetPause(cChamado,cFilialCh)

Local aArea		:= GetArea()
Local aAreaADE	:= ADE->(GetArea())
Local aAreaSK5	:= SK5->(GetArea())
Local nPausa	:= 0
Local cFilBkp	:= cFilAnt

Default cFilialCh	:= cFilAnt

cFilAnt := cFilialCh

DbSelectArea("SK5")
DbSetOrder(1)

DbSelectArea("ADE")
DbSetOrder(1)

If 	ADE->(MsSeek(xFilial("ADE")+cChamado)) .AND. !Empty(ADE->ADE_REGSLA) .AND.;
	SK5->(MsSeek(xFilial("SK5")+ADE->ADE_REGSLA))

	nPausa := SK5->K5_PAUSEDT

EndIf

RestArea(aAreaADE)
RestArea(aAreaSK5)
RestArea(aArea)

cFilAnt := cFilBkp

Return nPausa

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510IncPauseºAutor  ³Vendas CRM       º Data ³  11/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclui uma pausa em um chamado determinado apos desvincular º±±
±±º          ³chamados anexos e restaurar o SLA anterior.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do chamado                                   º±±
±±º          ³ExpN2 - Tempo que o SLA ficou em pausa                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510IncPause(cChamado,cFilCh,nPausedTime)

Local aArea	  		:= GetArea()
Local aAreaADE		:= ADE->(GetArea())
Local aAreaSK5 		:= SK5->(GetArea())
Local aAreaSK8 		:= SK8->(GetArea())
Local aAreaSU0		:= SU0->(GetArea())
Local oSLAService	:= SLAService():New()	// Objeto SLAService
Local cCodRespons	:= RetCodUsr()			// Primeiro usuario responsavel pelo SLA
Local codService	:= ""					// Codigo do Servico de SLA
Local cTimeShift	:= ""					// Turno de trabalho do grupo de atendimento
Local nSeveridade	:= 0
Local cFilBkp		:= cFilAnt

DbSelectArea("ADE")
DbSetOrder(1)

cFilAnt := cFilCh

If !MsSeek(xFilial("ADE")+cChamado)
	cFilAnt := cFilBkp
	RestArea(aAreaADE)
	RestArea(aArea)
	Return Nil
EndIf

DbSelectArea("SK5")
DbSetOrder(1)
If !Empty(ADE->ADE_REGSLA) .AND. MsSeek(xFilial("SK5")+ADE->ADE_REGSLA)
	nSeveridade	:= Val(SK5->K5_SEVE)
EndIf

dbSelectArea("SU0")
dbSetOrder(1)
If MsSeek(xFilial("SU0")+ADE->ADE_GRUPO)
	codService	:= SU0->U0_SERVSLA
EndIf

If !Empty(cCodRespons)
	DbSelectArea("SK8")
	DbSetorder(2) //K8_FILIAL+K8_CODUSU
	If DbSeek(xFilial("SK8")+cCodRespons)
		cCodRespons := SK8->K8_CODRESP
	EndIf
EndIf

If !Empty(ADE->ADE_GRUPO)
	DbSelectArea("SU0")
	DbSetOrder(1)
	If SU0->(MsSeek( xFilial("SU0") + ADE->ADE_GRUPO)) .And. !Empty(SU0->U0_TURNO)
		cTimeShift := SU0->U0_TURNO
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pausa reg. de SLA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(codService) .AND. oSLAService:load( codService )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria um novo registro para o SLA encontrado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oSLAService:pause(cCodRespons, ADE->ADE_REGSLA, cTimeShift)

		oSLAService:save()

		RecLock("ADE", .F.)

		REPLACE ADE->ADE_REGSLA	WITH oSLAService:getRegisterID()  				//Registro de SLA gerado
		REPLACE ADE->ADE_DTEXPI	WITH oSLAService:getDateToExpire()				//Data para expirar SLA
		REPLACE ADE->ADE_SESLA	WITH AllTrim(Str(oSLAService:getSeverity()))	//Severidade usada no chamado
		REPLACE ADE->ADE_HREXPI	WITH oSLAService:oSLARegister:hourToExpire	//Hora para expirar o SLA

		If Empty(ADE->ADE_HPSE1S)
			REPLACE ADE->ADE_DPSE1S WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
			REPLACE ADE->ADE_HPSE1S WITH Time()
		EndIf
		REPLACE ADE->ADE_DPSEUL WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
		REPLACE ADE->ADE_HPSEUL WITH Time()

		MsUnlock()

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza reg. de SLA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSLAService:oSLARegister:load( ADE->ADE_REGSLA )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria um novo registro para o SLA encontrado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSLAService:oSLARegister:SeverityCode := nSeveridade//;oSLAService:oSLARegister:StatusRegister := "2"; oSLAService:oSLARegister:Paused := .T.
	If oSLAService:update(cCodRespons, ADE->ADE_REGSLA,cTimeShift, 0)
		oSLAService:save()
	Else
		If oSLAService:start(cCodRespons, , cTimeShift)
			//Salva o registro de SLA (SK5)
		 	oSLAService:save()
		EndIf
	EndIf

	RecLock("ADE", .F.)

	REPLACE ADE->ADE_REGSLA	WITH oSLAService:getRegisterID()  				//Registro de SLA gerado
	REPLACE ADE->ADE_DTEXPI	WITH oSLAService:getDateToExpire()				//Data para expirar SLA
	REPLACE ADE->ADE_SESLA	WITH AllTrim(Str(oSLAService:getSeverity()))	//Severidade usada no chamado
	REPLACE ADE->ADE_HREXPI	WITH oSLAService:oSLARegister:hourToExpire	//Hora para expirar o SLA
	REPLACE ADE->ADE_DATUSL WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
	REPLACE ADE->ADE_HATUSL WITH Time()
	REPLACE ADE->ADE_DINISL WITH If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
	REPLACE ADE->ADE_HINISL WITH Time()

	MsUnlock()

EndIf

TMKFree( oSLAService )

RestArea(aAreaSU0)
RestArea(aAreaSK8)
RestArea(aAreaADE)
RestArea(aAreaSK5)
RestArea(aArea)

cFilAnt := cFilBkp

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510NewFieldsºAutor  ³Vendas CRM      º Data ³  11/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o sistema está trabalhando com os campos        º±±
±±º          ³que foram substituidos por serem númericos.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510NewFields()
	Local aAreaSX3	:= SX3->(GetArea())
	Local lRet		:= .F.

	SX3->(DbSelectArea( "SX3" ))
	SX3->( DbSetOrder(2) )

	lRet := SX3->( DbSeek( PadR("K9_SEVE", Len(SX3->X3_CAMPO) ) ) )

	SX3->(RestArea(aAreaSX3))
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510TrFilºAutor  ³Vendas CRM          º Data ³  20/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Transfere o chamado para a filial indicada                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do chamado                                   º±±
±±º          ³ExpC2 - Filial de destino                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510TrFil(cCodAte,cFilDest)

Local aRecADF  		:= {}				  		// Registros da ADF a serem transferidos
Local aChamAnex		:= {}						// Lista de chamados anexados a este
Local nCount   		:= 0				   		// Auxiliar de loop
Local nX	   		:= 0				   		// Auxiliar de loop
Local cRegSLA  		:= ""				   		// Registro do SLA
Local cFilAntBkp	:= cFilAnt			   		// Filial atual
Local cNovoAt		:= cCodAte					// Codigo do novo atendimento
Local lNovoNum 		:= .F.				   		// Indica se deve confirmar novo numero
Local cMsg	   		:= ""				   		// Mensagem apresentada apos mudanca de numero no chamado
Local lTk510AltCh	:= ExistBlock("TKALTNCH")	// Ponto de entrada na alteração do chamado

aChamAnex := Tk510ChFilho(cCodAte,xFilial("ADE"))

Begin Transaction

DbSelectArea("ADE")
DbSetOrder(1)

If FWModeAccess("ADE",3) == "E" .AND. ADE->(MsSeek(xFilial("ADE")+cCodAte))

	//Localiza o contrato de SLA
	cRegSLA	:= ADE->ADE_REGSLA

	//Caso a filial destino ja tenha um chamado com o mesmo numero, gera um novo numero
	cFilAnt := cFilDest

	If ADE->(MsSeek(xFilial("ADE")+cCodAte))
		cNovoAt	:= GetNumADE()
		lNovoNum:= .T.
	Endif

	cFilAnt := cFilAntBkp

	//Altera o registro do chamado
	ADE->(MsSeek(xFilial("ADE")+cCodAte))

	RecLock("ADE",.F.)
	ADE->ADE_FILIAL	:= cFilDest
	ADE->ADE_FILORI	:= cFilAnt
	ADE->ADE_CODIGO	:= cNovoAt
	MsUnLock()

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Troca a filial se a tabela for exclusiva³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FWModeAccess("ADF",3) == "E"

	DbSelectArea("ADF")
	DbSetOrder(1) //ADF_FILIAL+ADF_CODIGO+ADF_ITEM
	MsSeek(xFilial("ADF")+cCodAte)

	While !Eof() .AND. ADF->ADF_FILIAL == xFilial("ADF") .AND. ADF->ADF_CODIGO == cCodATE
		AAdd(aRecADF,Recno())
		DbSkip()
	End

	For nCount := 1 to Len(aRecADF)
		DbGoTo(aRecADF[nCount])
		RecLock("ADF",.F.)
		ADF->ADF_FILIAL := cFilDest
		ADF->ADF_CODIGO	:= cNovoAt
		MsUnLock()
	Next nCount

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os chamados anexos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ADE->(DbSetOrder(1))
For nX := 1 to Len(aChamAnex)
	cFilAnt := aChamAnex[nX][1]
	If ADE->(MsSeek(xFilial("ADE") + aChamAnex[nX][2] ))
		If ADE->ADE_CHANEX == cCodAte
			RecLock("ADE",.F.)
			If ADE->ADE_CHANEX <> cNovoAt
				ADE->ADE_CHANEX := cNovoAt
			EndIF
			ADE->ADE_FLCHAN	:= cFilDest
			MsUnLock()
		EndIf

	EndIf
Next nX

cFilAnt := cFilAntBkp

//Confirma numero sequencial
If lNovoNum .AND. __lSX8
	cFilAnt := cFilDest
	ConfirmSX8()
	cFilAnt := cFilAntBkp
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a transferência dos documentos do banco de conhecimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TK510ArqAnexo(cFilAnt,cFilDest,cCodAte,cNovoAt)

End Transaction

//Nofitica o usuario sobre a mudanca de numero
If lNovoNum
	If !( Type("lTk503Auto") <> "U" .AND. lTk503Auto )
		cMsg := STR0108 + cCodAte + STR0109 + CRLF //"Ao transferir o chamado atual ("###") para outra filial, foi encontrado um chamado com o mesmo número."
		cMsg += STR0110 + cNovoAt // "O novo número do chamado atual é: "
		Aviso(STR0019,cMsg,{"Ok"},3,STR0111) //"Transferencia de área"###"Alteração do número do chamado"
	EndIf
	If lTk510AltCh
		ExecBlock("TKALTNCH", .F., .F., {cCodAte,cNovoAt})
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510VldGrupo ºAutor  ³Bruno D. Borges º Data ³  12/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o grupo informado na tela de TRANSFERENCIA eh com-º±±
±±º          ³pativel com o assunto informado                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510VldGrupo(cGrupo,cAssunto,nTipoValid,aChamados)

Local aAreaBKP	:= GetArea()
Local aAreaSU0	:= SU0->(GetArea())
Local aAreaADE	:= SU0->(GetArea())
Local lRetorno	:= .F.
Local nX		:= 0

Default nTipoValid 	:= 1
Default aChamados	:= {}

//Validacao do grupo
If nTipoValid == 1

	//Valida se o assunto esta vinculado ao grupo informado
	dbSelectArea("SKK")
	SKK->(dbSetOrder(1))
	SKK->(MsSeek(xFilial("SKK")+cGrupo ))
	While SKK->(!Eof()) .And. SKK->KK_FILIAL + SKK->KK_CODSU0 == xFilial("SKK")+cGrupo
		If SKK->KK_CODSU0 == cGrupo .And. SKK->KK_CODSKQ == cAssunto
			lRetorno := .T.
			Exit
		EndIf

		SKK->(dbSkip())
	EndDo

	If !lRetorno
		MsgAlert(STR0087) //"Atenção, o grupo informado não está configurado para ser tratado com o assunto informado."
	EndIf

	//Valida se o chamado possui FNC associada
	If lRetorno
		dbSelectArea("SU0")
		dbSetOrder(1)
		MsSeek(xFilial("SU0")+cGrupo)
		If !Empty(SU0->U0_FILORI) .AND. cFilAnt <> SU0->U0_FILORI
			ADE->(DbSetOrder(1))
			For nX := 1 to Len(aChamados)
				ADE->(MsSeek(xFilial("ADE")+aChamados[nX]))
				If !Empty(ADE->ADE_FNC)
					lRetorno := .F.
					MsgAlert(STR0106 + aChamados[nX] + STR0107) //"O chamado " ### " possui uma FNC associada e não poderá ser transferido para outra filial."
					Exit
				EndIf
			Next nX
		EndIf
	EndIf

	//Valida se o grupo nao eh o mesmo
	If lRetorno
		ADE->(DbSetOrder(1))
		For nX := 1 to Len(aChamados)
			If ADE->(MsSeek(xFilial("ADE")+aChamados[nX]))
				If ADE->ADE_GRUPO == cGrupo
					lRetorno := .F.
					Exit
				EndIf
			ElseIf Type("M->ADE_GRUPO") == "C" .AND. M->ADE_GRUPO == cGrupo
				lRetorno := .F.
				Exit
			EndIf
		Next nX
		If !lRetorno
			MsgAlert(STR0106 + aChamados[nX] + STR0112 + cGrupo) //" já pertence ao grupo de destino:"
		EndIf
	EndIf

//Validacao do campo ATENDENTE conforme grupo
Else
	dbSelectArea("SU0")
	SU0->(dbSetOrder(1))
	SU0->(MsSeek(xFilial("SU0")+cGrupo ))
	If SU0->U0_RECCHAM == "1" //Recebe o chamado
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf
EndIf

RestArea(aAreaADE)
RestArea(aAreaSU0)
RestArea(aAreaBKP)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510VldUser  ºAutor  ³Bruno D. Borges º Data ³  12/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o usuario informado com o grupo selecionado       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510VldUser(cGrupo,cOperador,cNomeOperador)

Local aArea		:= GetArea()
Local lRetorno	:= .F.
Local cFilAntBkp:= cFilAnt
Local lOperAtiv := .T.

DbSelectArea("SU0")
DbSetOrder(1)
MsSeek(xFilial("SU0")+cGrupo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o grupo pertence a outra filial, altera a filial e posiciona no³
//³registro original                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SU0->U0_FILORI) .AND. !Empty(SU0->U0_GRPORI) .AND. xFilial("SU0") <> SU0->U0_FILORI

	cFilAnt := SU0->U0_FILORI
	cGrupo	:= SU0->U0_GRPORI
	MsSeek(xFilial("SU0")+cGrupo)

EndIf

If ExistCpo("SU7",cOperador,1)
	lOperAtiv := Posicione("SU7",1,xFilial("SU7")+cOperador,"U7_VALIDO") == "1"
	If lOperAtiv
		dbSelectArea("AG9")
		AG9->(dbSetOrder(1))
		AG9->(MsSeek(xFilial("AG9")+cOperador ))
		While AG9->(!Eof()) .And. AG9->AG9_FILIAL+AG9->AG9_CODSU7 == xFilial("AG9")+cOperador
			If AG9->AG9_CODSU0 == cGrupo
				lRetorno := .T.
				Exit
			EndIf

			AG9->(dbSkip())
		EndDo
	Else
		MsgAlert(STR0191)//"O Operador informado esta invalido para atendimento."
	EndIf
EndIf

If !lRetorno .And. lOperAtiv
	MsgAlert(STR0090)
Else
	cNomeOperador := Posicione("SU7",1,xFilial("SU7")+cOperador,"SU7->U7_NOME")
EndIf

cFilAnt := cFilAntBkp

RestArea(aArea)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510StatOper ºAutor  ³Bruno D. Borges º Data ³  12/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Identifica se o operador de destino esta INATIVO por status º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cOperador = Codigo do operador                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510StatOper(cOperador,lRetorno,lSoValida)

Local aAreaBKP     := GetArea()
Local dDataDia     := dDataBase //congela a data base
Local cHoraDia     := SubStr(Time(),1,5) //congela a hora
Local cRetOperador := ""
Local nRecnoSU7    := 0

Default lRetorno	:= .T.
Default lSoValida	:= .F.

dbSelectArea("SU7")
SU7->(dbSetOrder(1))
SU7->(MsSeek(xFilial("SU7")+cOperador ))
nRecnoSU7 := SU7->(RecNo())

dbSelectArea("AGF")
AGF->(dbSetOrder(2))
AGF->(MsSeek(xFilial("AGF")+cOperador+DToS(dDataDia),.T. ))
While AGF->(!Eof()) .And. AGF->AGF_FILIAL + AGF->AGF_OPERAD == xFilial("AGF")+cOperador
	If dDataDia >= AGF->AGF_DTINI .And. dDataDia <= AGF->AGF_DTFIM
		lRetorno := .F.

		If (dDataDia == AGF->AGF_DTINI .And. cHoraDia < AGF->AGF_HRINI) .Or. (dDataDia == AGF->AGF_DTFIM .And. cHoraDia > AGF->AGF_HRFIM)
			lRetorno := .T.
		EndIf

		If !lRetorno
			Exit
		EndIf
	EndIf
	AGF->(dbSkip())
EndDo

//Chama funcao para avaliar o substituto do operador
If !lRetorno .AND. !lSoValida
	//Adiciona no vetor de historico da recursiva para evitar um LOOPING
	AAdd(aRecSubstitutos,cOperador)

	//Encerra o Looping da recursiva
	If AScan(aRecSubstitutos,{|x| x == SU7->U7_SUBSTIT } ) > 0
		Return("")
	EndIf

	cRetOperador := TK510StatOper(SU7->U7_SUBSTIT)
	SU7->(dbGoTo(nRecnoSU7))
	If !Empty(cRetOperador)
		lRetorno := .T.
	EndIf
Else
	cRetOperador := cOperador
EndIf

RestArea(aAreaBKP)

Return(cRetOperador)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510CombVld  ºAutor  ³Bruno D. Borges º Data ³  12/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que valida as informacoes da tela de transferencia   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAssunto = Codigo do novo assunto do atendimento           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510CombVld(cAssunto,cGrupo,nTipoAcao)

Local lRetorno 		:= .T.
Local aAreaBKP		:= GetArea()
Local cMenRet  		:= ""
Local cFilAntBkp	:= cFilAnt
Local lTKVLDTRN		:= ExistBlock("TKVLDTRN")
Local lRetPE		:= .T.

If Empty(cGrupo)
	If nTipoAcao == 2
		cMenRet += " - " + STR0113 + Chr(13) + Chr(10) //"Grupo não informado;"
		lRetorno := .F.
	EndIf
Else
	DbSelectArea("SU0")
	DbSetOrder(1)
	If MsSeek( xFilial("SU0")+cGrupo)
		If !Empty(SU0->U0_FILORI)
			cFilAnt := SU0->U0_FILORI
		EndIf
	EndIf
EndIf

cAssunto := Padr(cAssunto,TamSX3("AG8_ASSUNT")[1])

SB1->(DbSetOrder(1))

dbSelectArea("AG8")
AG8->(dbSetOrder(1))

//1a. validacao: Assunto x Categoria
If !Empty(cCategoria) .And. !AG8->(MsSeek(xFilial("AG8")+cAssunto+"4"+cCategoria ))
	cMenRet += " - " + STR0100 + Chr(13) + Chr(10) //"Categoria não associada ao assunto;"
	lRetorno := .F.
EndIf

//2a. validacao: Assunto x Origem
If !Empty(cOrigem) .And. !AG8->(MsSeek(xFilial("AG8")+cAssunto+"3"+cOrigem ))
	cMenRet += " - " + STR0101 + Chr(13) + Chr(10) //"Origem não associada ao assunto;"
	lRetorno := .F.
EndIf

//3a. validacao: Assunto x Causa
If !Empty(cCausa) .And. !AG8->(MsSeek(xFilial("AG8")+cAssunto+"1"+cCausa ))
	cMenRet += " - " + STR0102 + Chr(13) + Chr(10) //"Causa não associada ao assunto;"
	lRetorno := .F.
EndIf

//4a. validacao: Assunto x Efeito
If !Empty(cEfeito) .And. !AG8->(MsSeek(xFilial("AG8")+cAssunto+"2"+cEfeito ))
	cMenRet += " - " + STR0103 + Chr(13) + Chr(10) //"Efeito não associado ao assunto;"
	lRetorno := .F.
EndIf

//4a. validacao: Assunto x Campanha
If !Empty(cCampanha) .And. !AG8->(MsSeek(xFilial("AG8")+cAssunto+"0"+cCampanha ))
	cMenRet += " - " + STR0104 + Chr(13) + Chr(10)
	lRetorno := .F.
EndIf

//5a. validacao: Assunto x Produto
If nTipoAcao == 2
	If !Empty(cProduto)
		If AG8->(MsSeek(xFilial("AG8")+cAssunto+"9"))
			If !AG8->(MsSeek(xFilial("AG8")+cAssunto+"9"+cProduto ))
				cMenRet += " - " + STR0125 + Chr(13) + Chr(10) //"Produto não associado ao assunto"
				lRetorno := .F.
			ElseIf !SB1->(MsSeek(xFilial("SB1")+cProduto))
				cMenRet += " - " + STR0126 + Chr(13) + Chr(10) //"Produto não cadastrado"
				lRetorno := .F.
			EndIf
		ElseIf !SB1->(MsSeek(xFilial("SB1")+cProduto))
			cMenRet += " - " + STR0126 + Chr(13) + Chr(10)
			lRetorno := .F.
		EndIf
	ElseIf Empty(cProduto)
		cMenRet += " - " + STR0127 + Chr(13) + Chr(10) //"Produto não informado"
		lRetorno := .F.
	EndIf
EndIf

If !lRetorno
	MsgAlert(STR0105+Chr(13)+Chr(10)+cMenRet) //"Atenção, o assunto indicado para transferência não possui amarração de Assuntos x Inf. Chamados. Abaixo as inconsistências localizadas: "
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para validar a transferencia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .AND. lTKVLDTRN
	lRetPE := ExecBlock("TKVLDTRN", .F., .F., {cAssunto	, cGrupo	, cOperador	, cProduto	,;
												cCategoria	, cOrigem	, cCausa	, cEfeito	,;
												cCampanha	})
	If ValType(lRetPE) == "L"
		lRetorno := lRetPE
	EndIf
EndIf

cFilAnt := cFilAntBkp

RestArea(aAreaBKP)

Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510UpdFNCºAutor  ³Vendas Clientes    º Data ³  10/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza a data prevista de conclusao da FNC                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo da FNC                                       º±±
±±º          ³ExpC2 - Revisao da FNC                                      º±±
±±º          ³ExpD3 - Data prevista de conclusao                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510UpdFNC(cFNC,cRev,dDataFim)

Local aArea 	:= {}
Local aAreaQI2	:= {}

If !Empty(cFNC)

	aArea 	:= GetArea()
	aAreaQI2:= QI2->(GetArea())

    DbSelectArea("QI2")
    DbSetOrder(2) //QI2_FILIAL+QI2_FNC+QI2_REV

    If DbSeek(xFilial("QI2")+cFNC+cRev)
    	RecLock("QI2",.F.)
    	QI2->QI2_CONPRE := dDataFim
    	MsUnLock()
    EndIf

	RestArea(aAreaQI2)
	RestArea(aArea)

EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510PrFilºAutor  ³Vendas CRM          º Data ³  21/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta padrao de produtos entre filiais do sistema        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Service Desk                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510PrFil()

Local cFilAntBkp	:= cFilAnt
Local cFiltrSU0		:= SU0->(DbFilter())
Local aAreaSU0		:= SU0->(GetArea())
Local nTamAssunt	:= TamSX3("AG8_ASSUNT")[1]
Local cQuery		:= ""
Local lRet			:= .F.
Local nRetorno		:= 0

If Empty(cAssunto)
	MsgStop("Selecione o assunto antes de selecionar um produto")
	Return lRet
EndIf

cAssunto := cAssunto + Space(nTamAssunt-Len(cAssunto))

DbSelectArea("SU0")
DbClearFilter()
DbSetOrder(1)
MsSeek(xFilial("SU0")+cGroup)

If !Empty(SU0->U0_FILORI)
	cFilAnt := SU0->U0_FILORI
	SU0->(MsSeek(xFilial("SU0") + SU0->U0_GRPORI))
EndIf

DbSelectArea("AG8")
DbSetOrder(1)//AG8_FILIAL+AG8_ASSUNT+AG8_TIPO+AG8_COD

If !MsSeek(xFilial("AG8")+cAssunto+"9")

	lRet := ConPad1(,,,"SB1")

Else

	cQuery += "SELECT B1_COD, B1_DESC, SB1.R_E_C_N_O_ SB1RECNO "
	cQuery += " FROM " + RetSqlName( "SB1" ) + " SB1 "
	cQuery += " INNER JOIN " + RetSqlName("AG8") + " AG8 ON AG8_FILIAL = '"+xFilial("AG8")+"'"
	cQuery += " AND AG8_COD = B1_COD AND AG8_TIPO = '9' AND AG8_ASSUNT = '"+cAssunto+"'"
	cQuery += " AND AG8.D_E_L_E_T_ = ' '"
	cQuery += " WHERE B1_FILIAL = '" + xFilial( "SB1" ) + "'"
	cQuery += " AND SB1.D_E_L_E_T_ = ' '"

	If Tk510F3Qry( cQuery, 'SB1QRY', 'SB1RECNO', @nRetorno,,{"B1_COD","B1_DESC"}, "SB1" )
		SB1->( dbGoto( nRetorno ) )
		lRet := .T.
	EndIf

EndIf

If !Empty(cFiltrSU0)
	DbSelectArea("SU0")
	Set Filter To &cFilterSU0
EndIf

cFilAnt := cFilAntBkp

RestArea(aAreaSU0)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510VldCpTrºAutor  ³Vendas CRM        º Data ³  21/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida um item na filial de destino                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Service Desk                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510VldCpTr(nTipo,cItemValid,cFilRef)

Local cFilAntBkp	:= cFilAnt
Local aArea			:= GetArea()
Local cFiltrSU0		:= SU0->(DbFilter())
Local aAreaSU0		:= SU0->(GetArea())
Local lRet			:= .F.

DbSelectArea("SU0")
DbClearFilter()
DbSetOrder(1)
If MsSeek(xFilial("SU0")+cGroup) .AND. !Empty(SU0->U0_FILORI)
	cFilAnt := SU0->U0_FILORI
	SU0->(MsSeek(xFilial("SU0")+SU0->U0_GRPORI))
EndIf

If nTipo == 1 //Produto
	cFilRef	:= xFilial("SB1")
	lRet 	:= Empty(cItemValid) .OR. ExistCpo("SB1",cItemValid)
EndIf

If !Empty(cFiltrSU0)
	DbSelectArea("SU0")
	Set Filter To &cFilterSU0
EndIf

cFilAnt := cFilAntBkp

RestArea(aAreaSU0)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510RecorºAutor  ³Vendas CRM          º Data ³  26/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe a interface de configuracao de recorrencia do chamado º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510Recor()

Local nModo		:= 0
Local lExclude	:= .F.
Local cOldRec	:= ""

If !Empty(M->ADE_FNC)
	MsgStop(STR0114) //"Este chamado já possui uma FNC e não pode ser tratado como recorrente. Por favor, inclua um novo chamado"
	Return Nil
EndIF

If M->ADE_STATUS <> "1"
	MsgStop(STR0116) //"Para utilizar a recorrência, o chamado deve estar com o status 'Em aberto'"
	Return Nil
EndIF

If INCLUI
	nModo 	:= 2
ElseIf ALTERA
	nModo 	:= 3
	cOldRec	:= ADE->ADE_STRREC
Else
	nModo 	:= 0
EndIf

M->ADE_STRREC := TmkRecorr( dDataBase, M->ADE_STRREC, nModo, @lExclude )

If lExclude
	M->ADE_STRREC	:= ""
EndIf

If Empty(M->ADE_STRREC)
	M->ADE_RECORR := "2"
Else
	M->ADE_RECORR := "1"
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMKSU0		ºAutor³ Vendas CRM       º Data ³  03/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função utilizada na consulta padrão do grupo, para filtrar º±±
±±º          ³ filtrar os grupos por assunto.							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Service Desk                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKSU0(cAssunto)

Local lRet 	   := .F.
Local nRetorno := 0
Local cQuery   := ""

DEFAULT cAssunto := M->ADE_ASSUNT

cQuery := "SELECT DISTINCT SU0.U0_CODIGO, SU0.U0_NOME, SU0.R_E_C_N_O_ SU0RECNO"
cQuery += "	 FROM " + RetSQLName("SU0") + " SU0, " + RetSqlName("SKK") + " SKK "
cQuery += "	 WHERE "
cQuery += "		SU0.U0_FILIAL  = '" + xFilial("SU0") + "' AND "
cQuery += "	    SKK.KK_FILIAL  = '" + xFilial("SKK") + "' AND "
cQuery += "		SKK.KK_CODSU0  = SU0.U0_CODIGO AND "
cQuery += "		SKK.KK_CODSKQ  = '" + cAssunto + "' AND "
cQuery += "		SKK.D_E_L_E_T_ = ' '  AND "
cQuery += "		SU0.D_E_L_E_T_ = ' ' "

//Monta a nova janela de consulta padrão, utilizando a query para a filtragem.
If Tk510F3Qry( cQuery, "TMKSU0", "SU0RECNO", @nRetorno,, {"U0_CODIGO","U0_NOME"}, "SU0" )
	SU0->(dbGoto(nRetorno))
	lRet := .T.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510OpAutoºAutor  ³Vendas CRM         º Data ³  27/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona um operador automaticamente para o grupo enviado  º±±
±±º          ³via parametro                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510OpAuto(cGrupo,cOpcSel,lLote,lMemoria)

Local aArea				:= GetArea()
Local aAreaSU0			:= SU0->(GetArea())
Local cQueryOper		:= ""
Local cOpcDefault		:= SuperGetMv("MV_TMKALOC",,"")
Local bQueryOper		:= {|| Iif(Select("TMP_OPER") > 0,TMP_OPER->(dbCloseArea()), Nil), DbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryOper), "TMP_OPER", .F., .T.)	, dbSelectArea("TMP_OPER") }
Local aOperadores		:= {}
Local cOperAutomatico	:= ""
Local aOperHab			:= {}
Local aSituOper			:= {}
Local lAutomatico		:= .F.
Local lCalcHabilid		:= .F.
Local cFilAntBkp		:= cFilAnt

Default cOpcSel			:= ""
Default lLote			:= .T.
Default lMemoria		:= .T.

DbSelectArea("SU0")
DbSetOrder(1)
MsSeek(xFilial("SU0")+cGrupo)

If !Empty(SU0->U0_GRPORI) .AND. !Empty(SU0->U0_FILORI) .AND. xFilial("SU0")<>SU0->U0_FILORI

	cFilAnt	:= SU0->U0_FILORI
	cGrupo	:= SU0->U0_GRPORI
	MsSeek(xFilial("SU0")+cGrupo)

EndIf

If !Empty(SU0->U0_TPALOC)
	cOpcDefault := SU0->U0_TPALOC
EndIf

If !lLote .AND. cOpcDefault $ "2/4" .AND. SU0->U0_USAHAB = "1"
	lAutomatico	:= SU0->U0_AUTOSEL == "1"
	lCalcHabilid:= .T.
	aOperHab 	:= Tk510Habil(cGrupo,lMemoria,"ADE")
EndIf

//OPERADOR FIXO
If cOpcDefault == "3" .And. !Empty(SU0->U0_OPALOC)
	cOperAutomatico:= SU0->U0_OPALOC

//MENOR NUMERO DE CHAMADOS
ElseIf cOpcDefault == "2"

	cQueryOper := " SELECT AG9_CODSU7, "
	cQueryOper += "        (SELECT COUNT(*) AS TOTCHAM "
	cQueryOper += "         FROM " + RetSQLName("ADE") + " ADE "
	cQueryOper += "         WHERE ADE_FILIAL = '" + xFilial("ADE") + "' AND ADE.D_E_L_E_T_ = ' ' AND "
	cQueryOper += "               ADE_OPERAD = AG9_CODSU7 AND ADE_STATUS IN ('1','2')) AS TOTCHAM "
	cQueryOper += " FROM " + RetSQLName("AG9") + " AG9 "
	cQueryOper += " WHERE AG9_FILIAL = '" + xFilial("AG9") + "' AND AG9_CODSU0 = '" + cGrupo + "' AND AG9.D_E_L_E_T_ = ' ' "
	cQueryOper += " ORDER BY TOTCHAM "

	Eval(bQueryOper)

	If !lCalcHabilid
		If TMP_OPER->(!Eof())
			cOperAutomatico := TMP_OPER->AG9_CODSU7
		EndIf
	Else
		While TMP_OPER->(!Eof())
			AAdd(aSituOper,{TMP_OPER->AG9_CODSU7,TMP_OPER->TOTCHAM})
			TMP_OPER->(DbSkip())
		End
		cOperAutomatico := Tk510SelOp(aOperHab,aSituOper,cOpcDefault,lAutomatico)
	EndIf

	TMP_OPER->(dbCloseArea())


//RODIZIO DE OPERADORES
ElseIf cOpcDefault == "4"

	cQueryOper := " SELECT AG9_CODSU7, U7_DTRODZ, U7_HRRODZ, SU7.R_E_C_N_O_ AS REGNO "
	cQueryOper += " FROM " + RetSQLName("AG9") + " AG9, " + RetSQLName("SU7") + " SU7 "
	cQueryOper += " WHERE AG9_FILIAL = '" + xFilial("AG9") + "' AND AG9_CODSU0 = '" + cGrupo + "' AND AG9.D_E_L_E_T_ = ' ' AND "
	cQueryOper += "       U7_FILIAL = '" + xFilial("SU7") + "' AND U7_COD = AG9_CODSU7 AND SU7.D_E_L_E_T_ = ' ' "
	cQueryOper += " ORDER BY U7_DTRODZ, U7_HRRODZ "

	Eval(bQueryOper)

	If !lCalcHabilid
	    If TMP_OPER->(!Eof())
	    	cOperAutomatico := TMP_OPER->AG9_CODSU7
	    EndIF
    Else
    	While TMP_OPER->(!Eof())
			AAdd(aSituOper,{TMP_OPER->AG9_CODSU7,TMP_OPER->U7_DTRODZ,TMP_OPER->U7_HRRODZ})
			TMP_OPER->(DbSkip())
		End
		cOperAutomatico := Tk510SelOp(aOperHab,aSituOper,cOpcDefault,lAutomatico)
    EndIf

    TMP_OPER->(dbCloseArea())

Else
	cOperAutomatico:= ""
EndIf

cOpcSel := cOpcDefault
cFilAnt := cFilAntBkp

RestArea(aAreaSU0)
RestArea(aArea)

Return cOperAutomatico

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldDuplicidadeºAutor  ³Vendas CRM      º Data ³  02/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Avalia a duplicidade de chamados pela chave unica do grupo  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldDuplicidade(nOpcao)

Local aArea		  := GetArea()
Local aAreaSU0	  := SU0->(GetArea())
Local cQueryADE   := ""
Local aDuplicados := {}
Local aCampos	  := {}
Local lUsaADF	  := .F.
Local cChave	  := ""
Local nPosRec	  := aScan(aHeader, {|x| AllTrim(x[2]) == "ADF_REC_WT"})
Local nCol		  := 0
Local nX		  := 1
Local nPos		  := 0
Local nDup		  := 0
Local cTipo		  := ""

dbSelectArea("SU0")

cGrupo := M->ADE_GRUPO

SU0->(dbSetOrder(1))
SU0->(dbSeek(xFilial("SU0")+cGrupo ))

cChave := AllTrim(SU0->U0_CHAVUNI)

If !Empty(cChave)

	If Select("TMP_DUPL") > 0
		TMP_DUPL->(dbCloseArea())
	EndIf

	aCampos	:= StrToKArr(cChave,"+")

	lUsaADF := At("ADF",cChave) > 0

	If lUsaADF //Chave considera cabecalho e itens

		For nX := 1 to Len(aCols)

			//Salta linhas deletadas ou previamente incluidas
			If aTail(aCols[nX]) .OR. (aCols[nX][nPosRec] > 0)
				Loop
			EndIf

			cQueryADE := "SELECT DISTINCT ADE_CODIGO FROM "
			cQueryADE += RetSQLName("ADE") + " ADE, "
			cQueryADE += RetSQLName("ADF") + " ADF "
			cQueryADE += "WHERE ADE_FILIAL = '" + xFilial("ADE") + "' AND ADE_STATUS IN ('1','2') AND ADE.D_E_L_E_T_ = ' ' "
			cQueryADE += "AND ADE_GRUPO = '" + cGrupo  + "' AND ADE_CODIGO <> '" + M->ADE_CODIGO + "' "

			For nPos := 1 to Len(aCampos)
				If Left(aCampos[nPos],3) == "ADE"
					cTipo := Valtype(M->&(aCampos[nPos]))
					If cTipo == "D"
						cQueryADE += "AND " + aCampos[nPos] + " = '" + DtoS(M->&(aCampos[nPos])) + "' "
					ElseIf cTipo == "N"
						cQueryADE += "AND " + aCampos[nPos] + " = " + M->&(aCampos[nPos]) + " "
					Else
						cQueryADE += "AND " + aCampos[nPos] + " = '" + M->&(aCampos[nPos]) + "' "
					EndIf
				EndIf
			Next nX

			For nPos := 1 to Len(aCampos)
				If Left(aCampos[nPos],3) == "ADF"
					nCol := aScan(aHeader,{|x|AllTrim(x[2])==AllTrim(aCampos[nPos])})
					If nCol > 0
						cTipo := Valtype(aCols[nX][nCol])
						If cTipo == "D"
							cQueryADE += "AND " + aCampos[nPos] + " = '" + DtoS(aCols[nX][nCol]) + "' "
						ElseIf cTipo == "N"
							cQueryADE += "AND " + aCampos[nPos] + " = " + aCols[nX][nCol] + " "
						Else
							cQueryADE += "AND " + aCampos[nPos] + " = '" + aCols[nX][nCol] + "' "
						EndIf
					EndIf
				EndIf
			Next nX

			cQueryADE += "AND ADF_FILIAL = '" + xFilial("ADF") + "' AND ADF_CODIGO = ADE_CODIGO AND ADF.D_E_L_E_T_ = ' '"

			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryADE), "TMP_DUPL", .F., .T.)

			If TMP_DUPL->(!Eof())
				AAdd(aDuplicados,{cValToChar(nX),{}})
				nDup++
			EndIf
			While TMP_DUPL->(!Eof())
				AAdd(aDuplicados[nDup][2],TMP_DUPL->ADE_CODIGO)
				TMP_DUPL->(dbSkip())
			EndDo
			TMP_DUPL->(dbCloseArea())

		Next nX

	Else //Chave considera apenas cabecalho

		cQueryADE := "SELECT DISTINCT ADE_CODIGO FROM "
		cQueryADE += RetSQLName("ADE") + " ADE "
		cQueryADE += "WHERE ADE_FILIAL = '" + xFilial("ADE") + "' AND ADE_STATUS IN ('1','2') AND ADE.D_E_L_E_T_ = ' ' "
		cQueryADE += "AND ADE_GRUPO = '" + cGrupo  + "' AND ADE_CODIGO <> '" + M->ADE_CODIGO + "' "

		For nPos := 1 to Len(aCampos)
			If Left(aCampos[nPos],3) == "ADE"
				cTipo := Valtype(M->&(aCampos[nPos]))
				If cTipo == "D"
					cQueryADE += "AND " + aCampos[nPos] + " = '" + DtoS(M->&(aCampos[nPos])) + "' "
				ElseIf cTipo == "N"
					cQueryADE += "AND " + aCampos[nPos] + " = " + M->&(aCampos[nPos]) + " "
				Else
					cQueryADE += "AND " + aCampos[nPos] + " = '" + M->&(aCampos[nPos]) + "' "
				EndIf
			EndIf
		Next nX

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryADE), "TMP_DUPL", .F., .T.)

		If TMP_DUPL->(!Eof())
			AAdd(aDuplicados,{"*",{}})
			nDup++
		EndIf
		While TMP_DUPL->(!Eof())
			AAdd(aDuplicados[nDup][2],TMP_DUPL->ADE_CODIGO)
			TMP_DUPL->(dbSkip())
		EndDo
		TMP_DUPL->(dbCloseArea())

	EndIf

EndIf

RestArea(aAreaSU0)
RestArea(aArea)

Return aDuplicados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510ArqAnexoºAutor  ³Vendas Clientes    º Data ³  03/09/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Transfere os documentos da base de conhecimento da filial  º±±
±±º		     ³ origem para a filial destino.			                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Filial de origem                                   º±±
±±º          ³ ExpC2 - Filial de destino                                  º±±
±±º          ³ ExpC3 - Código do atendimento        	                  º±±
±±º          ³ ExpC4 - Novo código de atendimento	                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKA510                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK510ArqAnexo(cFilOri,cFilDest,cCodAte,cNovoAt)

Local aArea			:= GetArea()
Local nPos 			:= 0
Local nPos2			:= 0
Local nI 			:= 0
Local nCount		:= 1
Local cFilBkp		:= cFilOri
Local aRecACB		:= {}
Local cEntidade		:= "ADE"
Local cDirDocOri	:= ""
Local cDirDocDest 	:= ""
Local cAnexoGrv		:= ""
Local cAnexo 		:= ""
Local cDescri 		:= ""
Local cCodObj 		:= ""
Local cKeyWrd 		:= ""
Local lDocOk		:= .F.
Local lDirDocExcl	:= FWModeAccess("ACB",3)=="E"	//Se o banco de conhecimento for exclusivo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o array com o recno dos documentos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsDocArray(cEntidade,cFilOri+cCodAte,,,,1,@aRecACB)

If Len(aRecACB) > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Diretório da filial origem  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDirDocOri := MsDocPath()

	//Mudo para a filial destino
	cFilAnt := cFilDest

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Diretório da filial destino ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDirDocDest := MsDocPath()

	//Volta para filial origem
	cFilAnt := cFilBkp

   	dbSelectArea("ACB")
    dbSetOrder(2)	 	//ACB_FILIAL+ACB_OBJETO

	For nI := 1 To Len(aRecACB)

		ACB->(dbGoto(aRecACB[nI]))

		cAnexo  := AllTrim(ACB->ACB_OBJETO)
        cDescri := AllTrim(ACB->ACB_DESCRI)
        cCodObj := ACB->ACB_CODOBJ

	   	nPos := RAt(If(IsSrvUnix(), "/", "\"), cAnexo)
		cAnexoGrv := SubStr( cAnexo , nPos+1 )

		nCount := 1

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe o objeto na filial destino				³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While lDirDocExcl .And. ACB->(dbSeek(cFilDest+AllTrim(SubStr(cAnexoGrv,nPos+1))))
			nPos2     := Rat(".",cAnexoGrv)
			cAnexoGrv := SubStr(cAnexoGrv,1,nPos2-1)+"("+cValToChar(nCount)+")"+SubStr(cAnexoGrv,nPos2,Len(cAnexoGrv))
			nCount++
		EndDo

		cKeyWrd := ""

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega a palavra-chave   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("ACC")
		dbSetOrder(1)	//ACC_FILIAL+ACC_CODOBJ
		If ACC->(dbSeek(xFilial("ACC")+cCodObj))
			cKeyWrd := AllTrim(ACC->ACC_KEYWRD)
		EndIf

		If lDirDocExcl
			lDocOk := __CopyFile(cDirDocOri + "\" + cAnexo, cDirDocDest + "\" + cAnexoGrv )
		Else
			lDocOk := File(cDirDocDest + "\" + cAnexoGrv)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz a cópia do arquivo da filial origem para a filial destino³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lDocOk
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Altera para a filial destino³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cFilAnt := cFilDest

			If lDirDocExcl
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inclui registro no banco de conhecimento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("ACB",.T.)
				ACB->ACB_FILIAL := xFilial("ACB")
				ACB->ACB_CODOBJ := GetSxeNum("ACB","ACB_CODOBJ")
				ACB->ACB_OBJETO	:= cAnexoGrv
				ACB->ACB_DESCRI	:= cDescri
				ACB->(MsUnLock())
				ConfirmSx8()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inclui a palavra-chave de pesquisa³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cKeyWrd)
					RecLock("ACC",lDirDocExcl)
					ACC->ACC_FILIAL	:= xFilial("ACC")
					ACC->ACC_CODOBJ	:= ACB->ACB_CODOBJ
					ACC->ACC_KEYWRD := cKeyWrd
					ACC->(MsUnLock())
				EndIf
			Else
				AC9->(dbSeek(xFilial("AC9")+cCodObj+cEntidade))
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inclui amarração entre registro do banco e entidade³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AC9",lDirDocExcl)
			AC9->AC9_FILIAL	:= xFilial("AC9")
			AC9->AC9_FILENT	:= xFilial("ADE")
			AC9->AC9_ENTIDA	:= cEntidade
			AC9->AC9_CODENT	:= cFilDest+cNovoAt
			AC9->AC9_CODOBJ	:= ACB->ACB_CODOBJ
			AC9->(MsUnLock())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Volta para a filial origem³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cFilAnt := cFilBkp

			If lDirDocExcl
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Apaga o arquivo da filial origem³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Ferase(cDirDocOri + "\" + cAnexo)

				ACB->(dbGoto(aRecACB[nI]))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Deleta o registro da relação de objetos X entidades³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("AC9")
				dbSetOrder(1)	//AC9_FILIAL+AC9_CODOBJ+AC9_ENTIDA
				If AC9->(dbSeek(xFilial("AC9")+ACB->ACB_CODOBJ+cEntidade))
					RecLock("AC9",.F.)
					AC9->(dbDelete())
					AC9->(MsUnLock())
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Deleta o registro da palavra-chave                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("ACC")
				dbSetOrder(1)	//ACC_FILIAL+ACC_CODOBJ
				If ACC->(dbSeek(xFilial("ACC")+ACB->ACB_CODOBJ))
					RecLock("ACC",.F.)
					ACC->(dbDelete())
					ACC->(MsUnLock())
		        EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Deleta o registro do banco de conhecimento         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("ACB")
				RecLock("ACB",.F.)
				ACB->(dbDelete())
				ACB->(MsUnLock())
			EndIf
		EndIf
	Next nI

EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510HabilºAutor  ³Vendas CRM          º Data ³  24/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona operadores que atendem as habilidades necessarias º±±
±±º          ³para o chamado atual.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do grupo de atendimento de destino           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510Habil(cGrupo,lMemoria,cTab)

Local aArea		:= GetArea()
Local aCampos	:= {}
Local aHabXPeso	:= {}
Local aOperXhab	:= {}
Local lOperOk	:= .T.
Local cFilAGQ	:= xFilial("AGQ")
Local cCampo	:= ""
Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local nX		:= 0
Local nY		:= 0
Local nPos		:= 0
Local nBase		:= Val(Replicate("9",TamSX3("AGM_PESO")[1]))

Default lMemoria	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Encontra quais campos devem ser avaliados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT DISTINCT AGM_COD,AGM_CAMPO FROM " + RetSqlName("AGO") + " AGO "
cQuery += " INNER JOIN " + RetSqlName("AGM") + " AGM ON AGM_FILIAL = '" + xFilial("AGM") + "' AND AGM_COD = AGO_ITHAB AND AGM.D_E_L_E_T_ = ''"
cQuery += " WHERE AGO_FILIAL = '"+xFilial("AGO")+"' AND AGO.D_E_L_E_T_ = ''"

cQuery	:= ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

While !Eof()
	AAdd(aCampos,{(cAlias)->AGM_COD,(cAlias)->AGM_CAMPO})
	DbSkip()
End

(cAlias)->(DbCloseArea())

If Len(aCampos) > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Avalia os itens de habilidade de acordo com os campos utilizados³
	//³no chamado atual                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cWhere	:= " AND ( "

	For nX := 1 to Len(aCampos)

		If lMemoria
			cCampo := AllTrim(Upper( M->&(aCampos[nX][2]) ))
		Else
			cCampo := AllTrim(Upper( (cTab)->&(aCampos[nX][2]) ))
		EndIf

		If nX > 1
			cWhere += " OR "
		EndIf

		cWhere	+= "(AGO_ITHAB = '" + aCampos[nX][1] + "' AND AGO_FAIXDE <= '"+cCampo+"' AND AGO_FAIXAT >= '"+cCampo+"')"

	Next nX

	cWhere	+= ") "

	cQuery := "SELECT AGN_HABILI,AGM_PESO FROM " + RetSqlName("AGO") + " AGO "
	cQuery += "INNER JOIN " + RetSqlName("AGN") + " AGN ON AGN_FILIAL = '" + xFilial("AGN") + "' AND AGN_COD = AGO_COD AND AGN.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN " + RetSqlName("AGM") + " AGM ON AGM_FILIAL = '" + xFilial("AGM") + "' AND AGM_COD = AGO_ITHAB AND AGM.D_E_L_E_T_ = '' "
	cQuery += "WHERE AGO_FILIAL = '" + xFilial("AGO") + "' AND AGO.D_E_L_E_T_ = ''"

	cQuery += cWhere

	cQuery	:= ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

	While !Eof()
		nPos := aScan(aHabXPeso,{|x|x[1] == (cAlias)->AGN_HABILI })
		If nPos == 0
			AAdd(aHabXPeso,{(cAlias)->AGN_HABILI, (nBase - Val((cAlias)->AGM_PESO)) })
		Else
			aHabXPeso[nPos][2] += (nBase - Val((cAlias)->AGN_HABILI))
		EndIf
		DbSkip()
	End

	(cAlias)->(DbCloseArea())

EndIf

If Len(aHabXPeso) > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona os operadores ativos do grupo para comparacao de habilidades³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT U7_COD,U7_NOME FROM " + RetSqlName("SU7") + " SU7"
	cQuery += " INNER JOIN " + RetSqlName("AG9") + " AG9 ON AG9_FILIAL = '" + xFilial("AG9") + "' AND AG9_CODSU7 = U7_COD"
	cQuery += " AND AG9_CODSU0 = '" + cGrupo + "' AND AG9.D_E_L_E_T_ = ''"
	cQuery += " WHERE U7_FILIAL = '" + xFilial("SU7") + "' AND U7_VALIDO = '1' AND SU7.D_E_L_E_T_ = ''"

	cQuery	:= ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

	While !Eof()
		TK510StatOper((cAlias)->U7_COD,@lOperOk)
		If lOperOk
			AAdd(aOperXhab,{(cAlias)->U7_COD,(cAlias)->U7_NOME,0,{}})
			//{Codigo, Nome, Pontuacao alcancada, {lista de habilidades}}
		EndIf
		DbSkip()
	End

	(cAlias)->(DbCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega as habilidades de cada operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("AGQ")
	DbSetOrder(1) //AGQ_FILIAL+AGQ_OPERAD+AGQ_HABILI

	For nX := 1 to Len(aOperXhab)
		AGQ->(DbSeek(cFilAGQ + aOperXhab[nX][1]))
		While !AGQ->(Eof()) .AND. AGQ->AGQ_FILIAL == cFilAGQ .AND. AGQ->AGQ_OPERAD == aOperXhab[nX][1]
			AAdd(aOperXhab[nX][4],AGQ->AGQ_HABILI)
			AGQ->(DbSkip())
		End
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acumula total por operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aOperXhab)
		For nY := 1 to Len(aHabXPeso)
			//Se o operador possui a habilidade, pontua o acumulado daquela habilidade
			nPos := aScan(aOperXhab[nX][4],aHabXPeso[nY][1])
			If nPos > 0
				aOperXhab[nX][3] += aHabXPeso[nY][2]
			EndIf
		Next nX
	Next nX

	ASort(aOperXhab,,,{|x,y| x[3] > y[3] })

EndIf

RestArea(aArea)

Return aOperXhab

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510SelOpºAutor  ³Microsiga           º Data ³  24/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Permite ao usuario selecionar o operador adequado entre os  º±±
±±º          ³operadores contidos no grupo.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510SelOp(aOperHab,aSituOper,cOpcDefault,lAuto)

Local cOpSel		:= ""
Local aOperadores	:= {}
Local aTitulos		:= {}
Local oOk			:= LoadBitmap( GetResources(), "LBOK" )
Local oNo			:= LoadBitmap( GetResources(), "LBNO" )
Local oDlg			:= Nil
Local oLbx			:= Nil
Local cVar			:= Nil
Local bLDblClick	:= {||aEval(oLbx:aArray, {|x|x[1] := .F.}), oLbx:aArray[oLbx:nAt,1] := .T.,cOpSel := oLbx:aArray[oLbx:nAt,3], oLbx:Refresh()}
Local lObfNOper		:= FATPDIsObfuscate("U7_NOME",,.T.) 

Local nX			:= 0
Local nItem			:= 0
Local nPos			:= 0
Local lAutomatico:= ExecSchedule()
Local aPDCols		:= {}

//Se for executado sem interface, nao deve exibir a tela
If !lAuto .AND. lAutomatico
	lAuto := .T.
EndIf

//aOperHab: {Codigo, Nome, Pontuacao alcancada, {lista de habilidades}}

If cOpcDefault == "2" 	//Menor numero
	aTitulos := {" ", STR0020, STR0002,STR0138,STR0139} //"Nome"###"Código"###"Pontos"###"Qtd. Atendimentos"
	For nX := 1 to Len(aOperHab)

		nItem++
		AAdd(aOperadores,{.F.,aOperHab[nX][2],aOperHab[nX][1],aOperHab[nX][3],0})
		nPos := aScan(aSituOper,{|x|x[1] == aOperHab[nX][1]})

		If nPos > 0
			aOperadores[nItem][5] := aSituOper[nPos][2]
		EndIf

	Next nX

	aPDCols := {.F.,lObfNOper,.F.,.F.,.F.}

Else	//Rodizio
	aTitulos := {" ", STR0020, STR0002,STR0138,STR0140,STR0141} //"Nome"###"Código"###"Pontos"###"Dia Ult.Rodízio"###"Hora Ult.Rodízio"
	For nX := 1 to Len(aOperHab)

		nItem++
		AAdd(aOperadores,{.F.,aOperHab[nX][2],aOperHab[nX][1],aOperHab[nX][3],""})
		nPos := aScan(aSituOper,{|x|x[1] == aOperHab[nX][1]})

		If nPos > 0
			aOperadores[nItem][5] := aSituOper[nPos][2] + aSituOper[nPos][3]
		EndIf

	Next nX
	aPDCols := {.F.,lObfNOper,.F.,.F.,.F.,.F.} 
EndIf

If Len(aOperadores) > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O array aOperadores ate este ponto estara ordenado pela pontuacao          ³
	//³(maior->menor). A rotina ReOrdArr ira ordenar este mesmo array pela data   ³
	//³do rodizio (mais antigo -> mais recente) ou pela quantidade de atendimentos³
	//³ (menor->maior), nos casos onde ha empate nas potuacoes                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aOperadores := ReOrdArr(aOperadores,4,5,.F.)

	If !lAuto

		While Empty(cOpSel)
			DEFINE MSDIALOG oDlg TITLE STR0136 FROM 0,0 TO 240,500 PIXEL //"Selecione o operador de destino"

			oLbx := TWBrowse():New(10,10,230,95,,aTitulos,,oDlg,,,,,bLDblClick,,,,,,,,,.T.)
			oLbx:SetArray( aOperadores )

			If cOpcDefault == "2"
				oLbx:aColSizes	:= {5,65,30,30,65}
				oLbx:bLine := {|| {Iif(aOperadores[oLbx:nAt,1],oOk,oNo),;
			    	                   aOperadores[oLbx:nAt,2],;
			    	                   aOperadores[oLbx:nAt,3],;
			    	                   aOperadores[oLbx:nAt,4],;
			        	               aOperadores[oLbx:nAt,5]}}
			Else
				oLbx:aColSizes	:= {5,65,30,30,40,40}
				oLbx:bLine := {|| {Iif(aOperadores[oLbx:nAt,1],oOk,oNo),;
			    	                   aOperadores[oLbx:nAt,2],;
			    	                   aOperadores[oLbx:nAt,3],;
			    	                   aOperadores[oLbx:nAt,4],;
			    	                   DtoC(StoD(Substr(aOperadores[oLbx:nAt,5],1,8))),;
			        	               Substr(aOperadores[oLbx:nAt,5],9,2)+":"+Substr(aOperadores[oLbx:nAt,5],11,2)+":"+Substr(aOperadores[oLbx:nAt,5],13,2)}}
			EndIf

			If FATPDActive() .And. FTPDUse(.T.)
				oLbx:aObfuscatedCols := aPDCols
			EndIf

			DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg

			ACTIVATE MSDIALOG oDlg CENTER

			If Empty(cOpSel)
				MsgStop(STR0137) //"Selecione o operador que receberá o chamado"
			EndIf
		End

	Else
		//Se a rotina for automatica, pega o primeiro operador (melhor colocado)
		cOpSel := aOperadores[1][3]
	EndIf
EndIf

Return cOpSel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReOrdArr  ºAutor  ³Vendas CRM          º Data ³  25/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Reordena um array ja ordenado a partir de outra posicao     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReOrdArr(aArray,nPosRef,nPosOrd,lAsc)

Local nX	  := 0
Local nIni	  := 1
Local nQtd    := 1
Local xAnt

For nX := 1 to Len(aArray)
	If aArray[nX][nPosRef] <> xAnt
		If nQtd > 1
			If lAsc
				aSort(aArray,nIni,nQtd,{|x,y|x[nPosOrd]>y[nPosOrd]})
			Else
				aSort(aArray,nIni,nQtd,{|x,y|x[nPosOrd]<y[nPosOrd]})
			EndIf
		EndIf
		xAnt := aArray[nX][nPosRef]
		nIni := nX
		nQtd := 1
	Else
		nQtd++
	EndIf
Next nX

If nQtd > 1
	If lAsc
		aSort(aArray,nIni,nQtd,{|x,y|x[nPosOrd]>y[nPosOrd]})
	Else
		aSort(aArray,nIni,nQtd,{|x,y|x[nPosOrd]<y[nPosOrd]})
	EndIf
EndIf

Return aArray

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510PROF ºAutor  ³Vendas CRM          º Data ³  06/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta o perfil do contato do atendimento atual           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510PROF()

Local lRet		:= .T.
Local cCliente	:= AllTrim(M->ADE_CHAVE)
Local cContato	:= M->ADE_CODCON
Local cEntidade	:= M->ADE_ENTIDA
Local aInfo		:= GetApoInfo("TMKC010.PRW")

SaveInter()

Private aDados		:= Array(7)
Private cCadastro	:= STR0143 //"Informacoes gerenciais das entidades"
Private aRotina		:= {{STR0144,"AxPesqui", 0 , 1 , , .F.},;	//"Pesquisar"
						{STR0145,"TK010Con", 0 , 2 , , .T.} }	//"Consulta"

Private aTELA[0][0],aGETS[0]

INCLUI := .F.
ALTERA := .F.

If lRet .AND. Empty(cContato)
	lRet := .F.
	MsgInfo(STR0146)	//"Selecione um contato antes de consultar seu perfil"
EndIf

If lRet .AND. Empty(cCliente)
	lRet := .F.
	MsgInfo(STR0147) //"Selecione uma entidade antes de consultar seu perfil"
EndIf

If lRet .AND. DtoS(aInfo[4]) > "20090212"
	TK010Con(,,,,cContato,cEntidade,cCliente)
EndIf

RestInter()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510CpSlaºAutor  ³Vendas CRM          º Data ³  22/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Copia o registro do SLA de uma filial para a outra          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510CpSla(cFilOri,cFilDest,cRegSLA)

Local aArea			:= GetArea()
Local aAreaSK5		:= SK5->(GetArea())
Local cNovoSLA		:= ""
Local cFilAntBkp	:= cFilAnt
Local aRegsSLA		:= {}
Local aCampos		:= {}
Local nTamItem		:= TamSX3("K5_ITEM")[1]
Local nCount,nX

cFilAnt := cFilOri

DbSelectArea("SK5")
DbSetOrder(1)
DbSeek( xFilial("SK5") + cRegSLA )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Copia os registros do SLA pai     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While	!SK5->(EOF())					.And.;
		K5_FILIAL == xFilial("SK5")		.And.;
		K5_CODIGO == cRegSLA

		aCampos := {}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz o cache das informações do registro SLA.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCount := 1 To SK5->(FCount())
			If !(AllTrim(SK5->(FieldName(nCount))) $ "K5_FILIAL|K5_CODIGO|K5_ITEM")
				aAdd(aCampos, {nCount, SK5->(FieldGet(nCount))})
			EndIf
		Next

		AAdd(aRegsSLA,aCampos)

	SK5->(DbSkip())
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura o registro SLA do chamado filho.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAnt := cFilDest

cNovoSLA := GetSXENum("SK5","K5_CODIGO")

For nX := 1 to Len(aRegsSLA)

	aCampos := aClone(aRegsSLA[nX])

	RecLock("SK5", .T.)
	For nCount := 1 To Len(aCampos)
		SK5->(FieldPut(aCampos[nCount,1], aCampos[nCount,2]))
	Next
	SK5->K5_FILIAL	:= xFilial("SK5")
	SK5->K5_CODIGO	:= cNovoSLA
	SK5->K5_ITEM	:= StrZero(nX,nTamItem)
	MsUnLock()

Next nX

If __lSX8
	ConfirmSX8()
Endif

cFilAnt := cFilAntBkp

RestArea(aAreaSK5)
RestArea(aArea)

Return cNovoSLA

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510FiliaisºAutor  ³Vendas CRM        º Data ³  26/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna as filiais pertencentes a mesma empresa/grupo de em-º±±
±±º          ³presas atual.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk510Filiais()

Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local aFiliais	:= {}
Local cGrpAtu	:= FWGrpCompany()
Local aSM0		:= FWLoadSM0()
Local nX		:= 0

For nX := 1 to Len(aSM0)
	If aSM0[nX][1] == cGrpAtu
		AAdd(aFiliais,aSM0[nX][2])
	EndIf
Next nX

RestArea(aAreaSM0)
RestArea(aArea)

Return aFiliais



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510LocHtmlWFºAutor  ³Vendas CRM          º Data ³  17/08/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe o arquivo Html do WF no servidor.		 	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510	                                                    º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³ExpL: Verdadeiro / Falso			                            º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ExpC1: Codigo do Template WF	    							º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tk510LocHtmlWF(cCodWFTemplate)

Local lRet 		:= .T.						//Retorno Logico
Local cPathWF 	:= "\workflow\"				//Caminho da Pasta Workflow
Local aArea 	:= GetArea()				//Area Atual
Local aAreaSKY  := SKY->(GetArea())        //Area SKY
Local cHtmlFile := ""						//Arquivo Html

DbSelectArea("SKY")
DbSetOrder(1)

If DbSeek(xFilial("SKY")+cCodWFTemplate)

	Do Case
		Case SKY->KY_TPWF == "1"  //Informativo
			cHtmlFile := AllTrim( IIF(!Empty(SKY->KY_HTML),SKY->KY_HTML,"WFW520.htm") )
		Case SKY->KY_TPWF == "2"  //Autorizacao
			cHtmlFile := AllTrim( IIF(!Empty(SKY->KY_HTML),SKY->KY_HTML,"WFW520A.htm") )
		OtherWise
			cHtmlFile := AllTrim(SKY->KY_HTML)
	EndCase

EndIf

If !File(cPathWF+cHtmlFile)
	Aviso(STR0152,STR0153+cHtmlFile+STR0154,{STR0155},2)
	lRet := .F.
EndIf

RestArea(aArea)
RestArea(aAreaSKY)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510Xml   ºAutor  ³Vendas CRM          º Data ³19/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria XML com os dados do atendimento.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                    º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ExpC1: Codigo do atendimento                               º±±
±±º          ³ExpC2: Codigo do item do atendimento                       º±±
±±º          ³ExpC3: Mensagem para o corpo do email                      º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³ExpC: xml com os dados do atendimento                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tk510Xml(cCodChamado, cCodItem, cCorpoEmail)

Local aArea				:= GetArea()				//area atual
Local aAreaADE			:= ADE->(GetArea())		//cabecalho do teleatendimento
Local aAreaADF			:= ADF->(GetArea())		//itens do teleatendimento
Local cXml				:= ''					//xml com os dados
Local cCriticidade 		:= ''					//nivel de criticidade do chamado
Local cStatus 			:= ''					//status do chamado
Local cStatusWF			:= ''					//status da aprovacao
Local cStaItemWF			:= ''					//status do item
Local lInclusao			:= .F.					//defini se eh inclusao ou alteracao do chamado

If Type("INCLUI") == 'U'
	lInclusao := .F.
Else
	lInclusao := INCLUI
EndIf

Default cCorpoEmail := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o XML baseado no fichario teleatendimento.xsl do ECM  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("ADE")
DbSetOrder(1)

If DbSeek(xFilial("ADE")+cCodChamado)

	Do Case
		Case ADE->ADE_SEVCOD == "5"
			cCriticidade := STR0195 // "Crítica"
		Case ADE->ADE_SEVCOD == "4"
			cCriticidade := STR0196 // "Alta"
		Case ADE->ADE_SEVCOD == "3"
			cCriticidade := STR0198 // "Média"
		Case ADE->ADE_SEVCOD == "2"
			cCriticidade := STR0198 // "Baixa"
		Case ADE->ADE_SEVCOD == "1"
			cCriticidade := STR0199 // "Alteração de especificação"
	EndCase

	Do Case
		Case ADE->ADE_STATUS == "3"
			cStatus := STR0200	// "Encerrado"
		Case ADE->ADE_STATUS == "2"
			cStatus := STR0201	// "Pendente"
		Case ADE->ADE_STATUS == "1"
			cStatus := STR0202	// "Em Aberto"
	EndCase

	Do Case
		Case ADE->ADE_WFASTA == "5" .OR. Empty(ADE->ADE_WFASTA)
			cStatusWF := STR0203 //	"Aguardando Resposta"
		Case ADE->ADE_WFASTA == "4"
			cStatusWF := STR0204 // "Reprovado"
		Case ADE->ADE_WFASTA == "3"
			cStatusWF := STR0205 // "Aprovado"
		Case ADE->ADE_WFASTA == "2"
			cStatusWF := STR0206 // "Aprovado/Reprovado"
		Case ADE->ADE_WFASTA == "1"
			cStatusWF := STR0207 // "Sem workflow de autorização"
	EndCase





	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³monta o cabecalho do xml com os dados do cabecalho do teleatendimento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cXml += '<?xml version="1.0" encoding="ISO-8859-1"?>'
	cXml += '<?xml-stylesheet type="text/xsl" href="teleatendimento.xsl"?>'
	cXml += '<TMKA510>'
	cXml += '<MSG>'
	cXml += '<value>'+cCorpoEmail+'</value>'
	cXml += '</MSG>'
	cXml += '<ADE_CODIGO>'
	cXml += '<value>'+ADE->ADE_CODIGO+'</value>'
	cXml += '</ADE_CODIGO>'
	cXml += '<CODITEM>'
	cXml += '<value>'+cCodItem+'</value>'
	cXml += '</CODITEM>'
	cXml += '<ADE_CODCON>'
	cXml += '<value>'+ADE->ADE_CODCON+'</value>'
	cXml += '</ADE_CODCON>'
	cXml += '<ADE_NMCONT>'
	cXml += '<value>'+POSICIONE('SU5',1,XFILIAL('SU5')+ADE->ADE_CODCON,'U5_CONTAT') +'</value>'
	cXml += '</ADE_NMCONT>'
	cXml += '<ADE_ENTIDA>'
	cXml += '<value>'+ADE->ADE_ENTIDA+'</value>'
	cXml += '</ADE_ENTIDA>'
	cXml += '<ADE_NMENT>'
	cXml += '<value>'+ POSICIONE('SX2',1,ADE->ADE_ENTIDA,'X2NOME()') +'</value>'
	cXml += '</ADE_NMENT>'
	cXml += '<ADE_TIPPRF>'
	cXml += '<value>'+Tk510PrfDesc(ADE->ADE_ENTIDA, ADE->ADE_CHAVE)+'</value>'
	cXml += '</ADE_TIPPRF>'
	cXml += '<ADE_CHAVE>'
	cXml += '<value>'+ADE->ADE_CHAVE+'</value>'
	cXml += '</ADE_CHAVE>'
	cXml += '<ADE_DESCCH>'
	cXml += '<value>'+TKENTIDADE(ADE->ADE_ENTIDA,ADE->ADE_CHAVE,1)+'</value>'
	cXml += '</ADE_DESCCH>'
	cXml += '<ADE_EMAIL>'
	cXml += '<value>'+ADE->ADE_EMAIL+'</value>'
	cXml += '</ADE_EMAIL>'
	cXml += '<ADE_DDDRET>'
	cXml += '<value>'+ADE->ADE_DDDRET+'</value>'
	cXml += '</ADE_DDDRET>'
	cXml += '<ADE_TELRET>'
	cXml += '<value>'+ADE->ADE_TELRET+'</value>'
	cXml += '</ADE_TELRET>'
	cXml += '<ADE_CODSB1>'
	cXml += '<value>'+ADE->ADE_CODSB1+'</value>'
	cXml += '</ADE_CODSB1>'
	cXml += '<ADE_NMPROD>'
	cXml += '<value>'+POSICIONE('SB1',1,XFILIAL('SB1') +ADE->ADE_CODSB1, 'B1_DESC')+'</value>'
	cXml += '</ADE_NMPROD>'
	cXml += '<ADE_DATA>'
	cXml += '<value>'+Dtoc(ADE->ADE_DATA)+'</value>'
	cXml += '</ADE_DATA>'
	cXml += '<ADE_HORA>'
	cXml += '<value>'+ADE->ADE_HORA+'</value>'
	cXml += '</ADE_HORA>'
	cXml += '<ADE_TECNIC>'
	cXml += '<value>'+ADE->ADE_TECNIC+'</value>'
	cXml += '</ADE_TECNIC>'
	cXml += '<ADE_NMTEC>'
	cXml += '<value>'+POSICIONE('AA1',1,XFILIAL('AA1') + ADE->ADE_TECNIC, 'AA1_NOMTEC')+'</value>'
	cXml += '</ADE_NMTEC>'
	cXml += '<ADE_SEVCOD>'
	cXml += '<value>'+cCriticidade+'</value>'
	cXml += '</ADE_SEVCOD>'
	cXml += '<ADE_STATUS>'
	cXml += '<value>'+cStatus+'</value>'
	cXml += '</ADE_STATUS>'
	cXml += '<ADE_DCHREP>'
	cXml += '<value>'+TKENTIDADE(ADE->ADE_ENTREP,ADE->ADE_CHVREP,1)+'</value>'
	cXml += '</ADE_DCHREP>'
	cXml += '<ADE_DDDREP>'
	cXml += '<value>'+ADE->ADE_DDDREP+'</value>'
	cXml += '</ADE_DDDREP>'
	cXml += '<ADE_TELREP>'
	cXml += '<value>'+ADE->ADE_TELREP+'</value>'
	cXml += '</ADE_TELREP>'
	cXml += '<ADE_TIPO>'
	cXml += '<value>'+ADE->ADE_TIPO+'</value>'
	cXml += '</ADE_TIPO>'
	cXml += '<ADE_WFASTA>'
	cXml += '<value>'+cStatusWF+'</value>'
	cXml += '</ADE_WFASTA>'
	cXml += '<STATUS>'
	cXml += '<value>'+Upper("Em Aprovação")+'</value>' //Em aprovacao
	cXml += '</STATUS>'


	cXml += '<itens>' //define no xml que inicia a area geral dos itens

	DbSelectArea("ADF")
	DbSetOrder(1)

	If DbSeek(xFilial("ADF")+ADF->ADF_CODIGO)

		While ADF->(!EOF()) .AND. ADF->ADF_FILIAL == xFilial("ADF") .AND.  ADF->ADF_CODIGO == ADE->ADE_CODIGO

		Do Case
			Case ADF->ADF_SKWSTA == '3'
				cStaItemWF := STR0208 // "Aguardando Autorização"
			Case ADF->ADF_SKWSTA == '2'
				cStaItemWF := STR0209 // "Reprovado"
			Case ADF->ADF_SKWSTA == '1'
				cStaItemWF := STR0210 // "Autorizado"
		EndCase



			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³joga cada um dos itens do teleatendimento para o xml                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cXml += '<item>'
			cXml += '<ADF_ITEM>'
			cXml += '<value>'+ADF->ADF_ITEM+'</value>'
			cXml += '</ADF_ITEM>'
			cXml += '<ADF_CODSU9>'
			cXml += '<value>'+ADF->ADF_CODSU9+'</value>'
			cXml += '</ADF_CODSU9>'
			cXml += '<ADF_NMSU9>'
			cXml += '<value>'+POSICIONE('SU9', 2, xFilial('SU9')+ADF->ADF_CODSU9,'U9_DESC')+'</value>'
			cXml += '</ADF_NMSU9>'
			cXml += '<ADF_CODSUQ>'
			cXml += '<value>'+ADF->ADF_CODSUQ+'</value>'
			cXml += '</ADF_CODSUQ>'
			cXml += '<ADF_NMSUQ>'
			cXml += '<value>'+POSICIONE('SUQ', 1, xFilial('SUQ')+ADF->ADF_CODSUQ,'UQ_DESC')+'</value>'
			cXml += '</ADF_NMSUQ>'
			cXml += '<ADF_CODSU7>'
			cXml += '<value>'+ADF->ADF_CODSU7+'</value>'
			cXml += '</ADF_CODSU7>'
			cXml += '<ADF_NMSU7>'
			cXml += '<value>'+POSICIONE('SU7',1,XFILIAL('SU7') + ADF->ADF_CODSU7, 'U7_NOME')+'</value>'
			cXml += '</ADF_NMSU7>'
			cXml += '<ADF_CODSU0>'
			cXml += '<value>'+ADF->ADF_CODSU0+'</value>'
			cXml += '</ADF_CODSU0>'
			cXml += '<ADF_NMGRUP>'
			cXml += '<value>'+POSICIONE('SU0',1,XFILIAL('SU0')+ POSICIONE('SU7', 1, XFILIAL('SU7')+ TKOPERADOR(),'U7_POSTO'),'U0_NOME')+'</value>'
			cXml += '</ADF_NMGRUP>'
			cXml += '<ADF_OBS>'
			cXml += '<value>'+IF(!lInclusao,MSMM(ADE->ADE_CODOBS),"")+'</value>' //tratamento para pegar o campo memo
			cXml += '</ADF_OBS>'
			cXml += '<ADF_DATA>'
			cXml += '<value>'+Dtoc(ADF->ADF_DATA)+'</value>'
			cXml += '</ADF_DATA>'
			cXml += '<ADF_HORA>'
			cXml += '<value>'+ADF->ADF_HORA+'</value>'
			cXml += '</ADF_HORA>'
			cXml += '<ADF_HORAF>'
			cXml += '<value>'+ADF->ADF_HORAF+'</value>'
			cXml += '</ADF_HORAF>'
			cXml += '<ADF_FNC>'
			cXml += '<value>'+ADF->ADF_FNC+'</value>'
			cXml += '</ADF_FNC>'
			cXml += '<ADF_FNCREV>'
			cXml += '<value>'+ADF->ADF_FNCREV+'</value>'
			cXml += '</ADF_FNCREV>'
			cXml += '<ADF_SKWSTA>'
			cXml += '<value>'+cStaItemWF+'</value>'
			cXml += '</ADF_SKWSTA>'

			cXml += '</item>'



			ADF->(DbSkip())

		End
	EndIf

	cXml += '</itens>' //finaliza no xml a area geral dos itens

	cXml += '</TMKA510>'

EndIf

RestArea(aAreaADF) //Restaura area - itens do chamado
RestArea(aAreaADE) //Restaura area - cabecalho do chamado
RestArea(aArea) //Restaura area - atual


Return(cXML)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510CardData   ºAutor  ³Vendas CRM          º Data ³19/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria XML com os dados do atendimento.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                    º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ExpC1: Codigo do atendimento                               º±±
±±º          ³ExpC2: Codigo do item do atendimento                       º±±
±±º          ³ExpC3: Mensagem para o corpo do email                      º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³ExpC: xml com os dados do atendimento                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tk510CardData(cCodChamado, cCodItem, cCorpoEmail)

Local aArea				:= GetArea()				//area atual
Local aAreaADE			:= ADE->(GetArea())		//cabecalho do teleatendimento
Local aAreaADF			:= ADF->(GetArea())		//itens do teleatendimento
Local oView
Local oModelADE
Local oModelADF
Local lFirst := .T.
Local aCardData := {}
Local nTamFNMSU9 := 0
Local nTamFNMSUQ := 0
Local nTamFNMSU7 := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o XML baseado no fichario teleatendimento.xsl do ECM  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("ADE")
DbSetOrder(1)

If DbSeek(xFilial("ADE")+cCodChamado)

	oView := FwLoadView('WFTMKA510')
	oView:oModel:SetOperation(3)
	oView:oModel:Activate()

	oModelADE := oView:GetModel('ADEMASTER')
	oModelADF := oView:GetModel('ADFDETAIL')

	oModelADE:SetValue('ADE_CODIGO', ADE->ADE_CODIGO)
	oModelADE:SetValue('ADE_CODCON', ADE->ADE_CODCON)
	oModelADE:SetValue('ADE_NMCONT', Pad( POSICIONE('SU5',1,XFILIAL('SU5')+ADE->ADE_CODCON,'U5_CONTAT') , TamSX3("ADE_NMCONT")[1] ) )
	oModelADE:SetValue('ADE_ENTIDA', ADE->ADE_ENTIDA)
	oModelADE:SetValue('ADE_NMENT', Pad( POSICIONE('SX2',1,ADE->ADE_ENTIDA,'X2NOME()') ,TamSX3("ADE_NMENT" )[1] ) )
	oModelADE:SetValue('ADE_CODSB1', ADE->ADE_CODSB1)
	oModelADE:SetValue('ADE_NMPROD', Pad( POSICIONE('SB1',1,XFILIAL('SB1') +ADE->ADE_CODSB1, 'B1_DESC') , TamSX3("ADE_NMPROD")[1] ) )
	oModelADE:SetValue('ADE_DATA', ADE->ADE_DATA)
	oModelADE:SetValue('ADE_SEVCOD', ADE->ADE_SEVCOD)

	DbSelectArea("ADF")
	DbSetOrder(1)

	If DbSeek(xFilial("ADF")+ADE->ADE_CODIGO)
		nTamFNMSU9 := TamSX3("ADF_NMSU9")[1]
		nTamFNMSUQ := TamSX3("ADF_NMSUQ")[1]
		nTamFNMSU7 := TamSX3("ADF_NMSU7")[1]

		While ADF->(!EOF()) .AND. ADF->ADF_FILIAL == xFilial("ADF") .AND.  ADF->ADF_CODIGO == ADE->ADE_CODIGO

			If lFirst
				lFirst := .F.
			Else
				oModelADF:AddLine()
			EndIf

			oModelADF:SetValue('ADF_ITEM', ADF->ADF_ITEM)
			oModelADF:SetValue('ADF_CODSU9', ADF->ADF_CODSU9)
			oModelADF:SetValue('ADF_NMSU9', Pad( POSICIONE('SU9', 2, xFilial('SU9')+ADF->ADF_CODSU9,'U9_DESC') ,nTamFNMSU9 ) )
			oModelADF:LoadValue('ADF_CODSUQ', ADF->ADF_CODSUQ)
			oModelADF:SetValue('ADF_NMSUQ', Pad( POSICIONE('SUQ', 1, xFilial('SUQ')+ADF->ADF_CODSUQ,'UQ_DESC') ,nTamFNMSUQ ) )
			oModelADF:SetValue('ADF_CODSU7', ADF->ADF_CODSU7)
			oModelADF:SetValue('ADF_NMSU7', Pad( POSICIONE('SU7',1,XFILIAL('SU7') + ADF->ADF_CODSU7, 'U7_NOME') ,nTamFNMSU7 ) )
			oModelADF:SetValue('ADF_SKWSTA', ADF->ADF_SKWSTA)

			ADF->(DbSkip())

		End
	EndIf

	aCardData := FWViewCardData(oView)

EndIf

RestArea(aAreaADF) //Restaura area - itens do chamado
RestArea(aAreaADE) //Restaura area - cabecalho do chamado
RestArea(aArea) //Restaura area - atual


Return(aCardData)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510Body  ºAutor  ³Vendas CRM          º Data ³19/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria HTML corpo do email de wf com os dados do atendimento º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                    º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ExpC1: Codigo do atendimento                               º±±
±±º          ³ExpC2: Codigo do item do atendimento                       º±±
±±º          ³ExpC3: Mensagem para o corpo do email                      º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³ExpC: xml com os dados do atendimento                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tk510Body(cCodChamado, cCodItem, cCorpoEmail)

Local aArea				:= GetArea()				//area atual
Local aAreaADE			:= ADE->(GetArea())		//cabecalho do teleatendimento
Local aAreaADF			:= ADF->(GetArea())		//itens do teleatendimento
Local cHtml				:= ''					//Html com os dados
Local cCriticidade 		:= ''					//nivel de criticidade do chamado
Local cStatus 			:= ''					//status do chamado
Local cStatusWF			:= ''					//status da aprovacao
Local cStaItemWF			:= ''					//status do item
Local lInclusao			:= .F.					//defini se eh inclusao ou alteracao do chamado

If Type("INCLUI") == 'U'
	lInclusao := .F.
Else
	lInclusao := INCLUI
EndIf

Default cCorpoEmail := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Html  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("ADE")
DbSetOrder(1)

If DbSeek(xFilial("ADE")+cCodChamado)

	Do Case
		Case ADE->ADE_SEVCOD == '5'
			cCriticidade := STR0195	//'Crítica'
		Case ADE->ADE_SEVCOD == '4'
			cCriticidade := STR0196	//'Alta'
		Case ADE->ADE_SEVCOD == '3'
			cCriticidade := STR0197	//'Média'
		Case ADE->ADE_SEVCOD == '2'
			cCriticidade := STR0198 //'Baixa'
		Case ADE->ADE_SEVCOD == '1'
			cCriticidade := STR0195	//'Alteração de especificação'
	EndCase

	Do Case
		Case ADE->ADE_STATUS == '3'
			cStatus := STR0200	//'Encerrado'
		Case ADE->ADE_STATUS == '2'
			cStatus := STR0201	//'Pendente'
		Case ADE->ADE_STATUS == '1'
			cStatus := STR0202	//'Em Aberto'
	EndCase

	Do Case
		Case ADE->ADE_WFASTA == '5' .OR. ADE->ADE_WFASTA == ''
			cStatusWF := STR0203 //'Aguardando Resposta'
		Case ADE->ADE_WFASTA == '4'
			cStatusWF := STR0204 // 'Reprovado'
		Case ADE->ADE_WFASTA == '3'
			cStatusWF := STR0205 // 'Aprovado'
		Case ADE->ADE_WFASTA == '2'
			cStatusWF := STR0206 // 'Aprovado/Reprovado'
		Case ADE->ADE_WFASTA == '1'
			cStatusWF := STR0207 // 'Sem workflow de autorização'
	EndCase



	cHtml += '<html>'
	cHtml += '<head>'
	cHtml += '<META http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">'
	cHtml += '<style type="text/css">'
	cHtml += '.TabItens{font-family:Verdana;font-size:12px;}'
	cHtml += '#TabCab{font-family:Verdana;font-size:12px;font-weight: bold;}'
	cHtml += '#Cab{font-family:Verdana;}'
	cHtml += '</style>'
	cHtml += '<title>'+STR0208+'</title>' // Teleatendimento
	cHtml += '</head>'
	cHtml += '<body>'
	cHtml += '<table cellspacing="0" cellpadding="2" border="0" style="text-align: left; width: 1100px; height: 49px;">'
	cHtml += '<td>'
	cHtml += '<h3 id="Cab">'+STR0208+'</h3>' // Teleatendimento
	cHtml += '<h5>'+cCorpoEmail+'</h5>'

	cHtml += '<form enctype="" action="" method="post"><input type="hidden" name="wdkcontrol" id="wdkcontrol">'

	cHtml += '<table cellspacing="0" cellpadding="5" border="1" id="TabCab">'
	cHtml += '<tr>'

	cHtml += '<td>'+STR0209+'</td><td><input readonly maxlength="40" size="40" name="ADE_CODIGO" type="text" value="'+ADE->ADE_CODIGO+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0210+'</td><td><input readonly maxlength="40" size="40" name="ADE_CODCON" type="text" value="'+ADE->ADE_CODCON+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0211+'</td><td><input readonly maxlength="40" size="40" name="ADE_NMCONT" type="text" value="'+POSICIONE('SU5',1,XFILIAL('SU5')+ADE->ADE_CODCON,'U5_CONTAT') +'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0212+'</td><td><input readonly maxlength="40" size="40" name="ADE_ENTIDA" type="text" value="'+ADE->ADE_ENTIDA+'"></td>'

	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0213+'</td><td><input readonly maxlength="40" size="40" name="ADE_NMENT" type="text" value="'+ POSICIONE('SX2',1,ADE->ADE_ENTIDA,'X2NOME()') +'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0214+'</td><td><input readonly maxlength="40" size="40" name="ADE_TIPPRF" type="text" value="'+Tk510PrfDesc(ADE->ADE_ENTIDA, ADE->ADE_CHAVE)+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0215+'</td><td><input readonly maxlength="40" size="40" name="ADE_CHAVE" type="text" value="'+ADE->ADE_CHAVE+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0216+'</td><td><input readonly maxlength="40" size="40" name="ADE_DESCCH" type="text" value="'+TKENTIDADE(ADE->ADE_ENTIDA,ADE->ADE_CHAVE,1)+'"></td>'
	cHtml += '</tr>'

	cHtml += '<tr>'
	cHtml += '<td>'+STR0217+'</td><td><input readonly maxlength="40" size="40" name="ADE_EMAIL" type="text" value="'+ADE->ADE_EMAIL+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>DDD:</td><td><input readonly maxlength="40" size="40" name="ADE_DDDRET" type="text" value="'+ADE->ADE_DDDRET+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0218+'</td><td><input readonly maxlength="40" size="40" name="ADE_TELRET" type="text" value="'+ADE->ADE_TELRET+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0219+'</td><td><input readonly maxlength="40" size="40" name="ADE_CODSB1" type="text" value="'+ADE->ADE_CODSB1+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'

	cHtml += '<td>'+STR0220+'</td><td><input readonly maxlength="40" size="40" name="ADE_NMPROD" type="text" value="'+POSICIONE('SB1',1,XFILIAL('SB1') +ADE->ADE_CODSB1, 'B1_DESC')+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0221+'</td><td><input readonly maxlength="40" size="40" name="ADE_DATA" type="text" value="'+Dtoc(ADE->ADE_DATA)+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0222+'</td><td><input readonly maxlength="40" size="40" name="ADE_HORA" type="text" value="'+ADE->ADE_HORA+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0223+'</td><td><input readonly maxlength="40" size="40" name="ADE_TECNIC" type="text" value="'+ADE->ADE_TECNIC+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0224+'</td><td><input readonly maxlength="40" size="40" name="ADE_NMTEC" type="text" value="'+POSICIONE('AA1',1,XFILIAL('AA1') + ADE->ADE_TECNIC, 'AA1_NOMTEC')+'"></td>'

	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0225+'</td><td><input readonly maxlength="40" size="40" name="ADE_SEVCOD" type="text" value="'+cCriticidade+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0226+'</td><td><input readonly maxlength="40" size="40" name="ADE_STATUS" type="text" value="'+cStatus+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0227+'</td><td><input readonly maxlength="40" size="40" name="ADE_DCHREP" type="text" value="'+TKENTIDADE(ADE->ADE_ENTREP,ADE->ADE_CHVREP,1)+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0228+'</td><td><input readonly maxlength="40" size="40" name="ADE_DDDREP" type="text" value="'+ADE->ADE_DDDREP+'"></td>'
	cHtml += '</tr>'

	cHtml += '<tr>'
	cHtml += '<td>'+STR0218+'</td><td><input readonly maxlength="40" size="40" name="ADE_TELREP" type="text" value="'+ADE->ADE_TELREP+'"></td>'
	cHtml += '</tr>'
	cHtml += '<tr>'
	cHtml += '<td>'+STR0229+'</td><td><input readonly maxlength="40" size="40" name="ADE_TIPO" type="text" value="'+ADE->ADE_TIPO+'"></td>'
	cHtml += '</tr>'
	cHtml += '</table>'

	cHtml += '<br>'
	cHtml += '<h4 id="Cab">Itens do teleatendimento</h4>'
	cHtml += '<table cellspacing="0" cellpadding="0" bordercolor="Black" border="1" tablename="itens" style="width: 1100px;" class="TabItens" nodeletebutton="true" noaddbutton="true">'
	cHtml += '<tr>'
	cHtml += '<th style="text-align: center; font-family: Verdana;">Item</th>'
	cHtml += '<th style="text-align: center;">'+STR0230+'</th>'
	cHtml += '<th style="text-align: center;">'+STR0231+'</th>'
	cHtml += '<th style="text-align: center;">'+STR0232+'</th>'
	cHtml += '<th style="text-align: center;">'+STR0233+'</th>'
	cHtml += '<th style="text-align: center;">'+STR0234+'</th>'
	cHtml += '<th style="text-align: center;">'+STR0235+'</th>'
	cHtml += '<th style="text-align: center;">'+STR0236+'</th>'
	cHtml += '<th style="text-align: center;">'+STR0237+'</th>'
	cHtml += '<th style="text-align: center;">'+STR0238+'</th>'
	cHtml += '<th style="text-align: center;">'+STR0239+'</th>'
	cHtml += '<th style="text-align: center;">'+STR0240+'</th>'
	cHtml += '<th style="text-align: center;">'+STR0241+'</th>'
	cHtml += '<th style="text-align: center;">'+STR0242+'</th>'
	cHtml += '<th style="text-align: center;">'+STR0243+'</th>'
	cHtml += '<th style="text-align: center;">'+STR0244+'</th>'

	cHtml += '</tr>'

	DbSelectArea("ADF")
	DbSetOrder(1)

	If DbSeek(xFilial("ADF")+cCodChamado)

		While ADF->(!EOF()) .AND. ADF->ADF_FILIAL == xFilial("ADF") .AND.  ADF->ADF_CODIGO == ADE->ADE_CODIGO

		Do Case
			Case ADF->ADF_SKWSTA == "3"
				cStaItemWF := STR0245 //'Aguardando Autorização'
			Case ADF->ADF_SKWSTA == "2"
				cStaItemWF := STR0246 	//'Reprovado'
			Case ADF->ADF_SKWSTA == "1"
				cStaItemWF := STR0247	//'Autorizado'
		EndCase


		cHtml += '<tr>'
		cHtml += '<td><input readonly maxlength="2" size="2" name="ADF_ITEM" type="text" value="'+ADF->ADF_ITEM+'"></td>'
		cHtml += '<td><input readonly maxlength="40" size="40" name="ADF_CODSU9" type="text" value="'+ADF->ADF_CODSU9+'"></td>'
		cHtml += '<td><input readonly maxlength="35" size="35" name="ADF_NMSU9" type="text" value="'+POSICIONE('SU9', 2, xFilial('SU9')+ADF->ADF_CODSU9,'U9_DESC')+'"></td>'
		cHtml += '<td><input readonly maxlength="2" size="2" name="ADF_CODSUQ" type="text" value="'+ADF->ADF_CODSUQ+'"></td>'
		cHtml += '<td><input readonly maxlength="10" size="10" name="ADF_NMSUQ" type="text" value="'+POSICIONE('SUQ', 1, xFilial('SUQ')+ADF->ADF_CODSUQ,'UQ_DESC')+'"></td>'
		cHtml += '<td><input readonly maxlength="5" size="5" name="ADF_CODSU7" type="text" value="'+ADF->ADF_CODSU7+'"></td>'
		cHtml += '<td><input readonly maxlength="10" size="10" name="ADF_NMSU7" type="text" value="'+POSICIONE('SU7',1,XFILIAL('SU7') + ADF->ADF_CODSU7, 'U7_NOME')+'"></td>'
		cHtml += '<td><input readonly maxlength="10" size="10" name="ADF_CODSU0" type="text" value="'+ADF->ADF_CODSU0+'"></td>'
		cHtml += '<td><input readonly maxlength="10" size="10" name="ADF_NMGRUP" type="text" value="'+POSICIONE('SU0',1,XFILIAL('SU0')+ POSICIONE('SU7', 1, XFILIAL('SU7')+ TKOPERADOR(),'U7_POSTO'),'U0_NOME')+'"></td>'
		cHtml += '<td><input readonly maxlength="10" size="10" name="ADF_OBS" type="text" value="'+MSMM(ADF->ADF_CODOBS)+'"></td>'
		cHtml += '<td><input readonly maxlength="10" size="10" name="ADF_DATA" type="text" value="'+Dtoc(ADF->ADF_DATA)+'"></td>'
		cHtml += '<td><input readonly maxlength="10" size="10" name="ADF_HORA" type="text" value="'+ADF->ADF_HORA+'"></td>'
		cHtml += '<td><input readonly maxlength="10" size="10" name="ADF_HORAF" type="text" value="'+ADF->ADF_HORAF+'"></td>'
		cHtml += '<td><input readonly maxlength="10" size="10" name="ADF_FNC" type="text" value="'+ADF->ADF_FNC+'"></td>'
		cHtml += '<td><input readonly maxlength="10" size="10" name="ADF_FNCREV" type="text" value="'+ADF->ADF_FNCREV+'"></td>'
		cHtml += '<td><input readonly maxlength="10" size="10" name="ADF_SKWSTA" type="text" value="'+cStaItemWF+'"></td>'
		cHtml += '</tr>'


			ADF->(DbSkip())

		End
	EndIf


	cHtml += '</table>'
	cHtml += '</form>'
	cHtml += '</td>''
	cHtml += '</table>'
	cHtml += '</body>'
	cHtml += '</html>'



EndIf

RestArea(aAreaADF) //Restaura area - itens do chamado
RestArea(aAreaADE) //Restaura area - cabecalho do chamado
RestArea(aArea) //Restaura area - atual


Return(cHtml)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510ECM   ºAutor  ³Vendas CRM          º Data ³19/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria um processo de teleatendimento no ECM.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                    º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ExpC1: Codigo do template de workflow                      º±±
±±º          ³ExpC2: Codigo do atendimento                               º±±
±±º          ³ExpC3: Codigo do item do atendimento                       º±±
±±º          ³ExpC4: Funcao executada no retorno                         º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³ExpL: Verdadeiro                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tk510ECM(cCodWFTemplate, cCodADE, cCodADF,cCodeBlk)

Local aArea			:= GetArea()				// tabela atual
Local aRet			:= {} 						//Array com retorno da funcao BIStartTask.
Local lTK510ATTF	:= ExistBlock("TK510ATTF")	//Ponto de Entrada para envio de anexo no workflow
Local lTK510UFL		:= ExistBlock("TK510UFL") 	//Ponto de entrada para alteração dos usuários fluig
Local cAnexoPE		:= ""						//retorno do ponto de entrada do anexo
Local aAnexo		:= {}						//Array com dados do anexo
Local cCorpoEmail	:= Posicione("SKY",1,xFilial("SKY")+cCodWFTemplate, "KY_BODY")  		//verifica o corpo do email configurado no template
Local cAssunto		:= Posicione("SKY",1,xFilial("SKY")+cCodWFTemplate, "KY_SUBJECT")  		 //verifica o corpo do email configurado no template
Local lIsAuto		:= (Posicione("SKY",1,xFilial("SKY")+cCodWFTemplate, "KY_TPWF") == "2" ) //verifica se e de autorizacao
Local cECMUser		:= SuperGetMv("MV_ECMUSER",,"adm")     		//Usuario com acesso ao ECM
Local cECMPsw		:= SuperGetMv("MV_ECMPSW",,"adm")      		//Senha de acesso ao ECM
Local cXml			:= ""										//Retorna XML com os dados da proposta.
Local nPos			:= 0    									//Posicao do array utilizado no tratamento de erro.
Local cProcesso		:= IIF(lIsAuto, "TMKA510A"	,"TMKA510I")	//Processo do ECM (autorizacao ou informativo)
Local cCodUser		:= RetCodUsr()				//usuario corrente
Local aUsers									//array com os usuarios que receberao o wf
Local nUser_i									//contador para percorrer array de usuarios e incluir registro de wf
Local cEmail									//email que recebera o workflow
Local cLoteApr 		:= ''						//codigo do wf principal (quando ha varios wf para o mesmo item de chamado)
Local nCountUser	:= 0						//contador para percorrer o array de usuarios quando for wf informativo
Local lRet			:= .F.
Local lErro			:= .F.
Local cIDECM		:= ""
Local cUserId
Local aUserFluig	:= {}
Local aUserWF		:= {}
Local aCardData
Local nI
Local nX			:= 0
Local aIDECM		:= {}
Local aUserWF2		:= {}
Local cInfo			:= ""
Local nIdEcm		:= 0
Local nTamIdEcm := 0

Default cCodeBlk 	:= ''
Default cCodADF		:= ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega os usuarios que receberao o WF                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aUsers := FindUserWF(cCodWFTemplate)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Prepara os anexos                                              ³
//³Array no formato definido pelo ECM                          ³
//³{<descricao>, <nome fisico>, <conteudo>}                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTK510ATTF // Adiciona arquivos anexos por ponto de entrada
	cAnexoPE := ExecBlock("TK510ATTF",.F.,.F., {cCodADE, cCodWFTemplate})
	aAnexo:= AjAnexoWF(cAnexoPE)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³verificar se o template esta configurado para solicitar anexos  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Posicione("SKY",1,xFilial("SKY")+cCodWFTemplate, "KY_ANEXA") == "1" .AND. !IsInCallStack("TK510LSendWF") //se for chamado pela regra de monitoracao nao abre anexos
	aAnexo :=AjAnexoWF(AnexoWF())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³cria o processo de WF no ECM                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMv("MV_CRMWFFG",,.T.)
	For nI := 1 To Len(aUsers)
		// ID do usuario no Fluig
		cUserId := FWWFColleagueId(AllTrim(aUsers[nI]))
		If !Empty(cUserId)
			Aadd(aUserWF, cUserId) // ID do usuario no Fluig
		EndIf
	Next

	If lTK510UFL
		aUserFluig := ExecBlock("TK510UFL",.F.,.F.,{cCodADE,cCodWFTemplate,aUserWF})
		If ValType(aUserFluig) == "A" .And. !Empty(aUserFluig)
			aUserWF := aUserFluig
		EndIf
	EndIf

	If Len(aUserWF) > 0
		// Id. do usuario no Fluig logado no Protheus
		cUserId := FWWFColleagueId(cCodUser)

		//Cria XML com os dados do atendimento
		aCardData := Tk510CardData(cCodADE, cCodADF, cCorpoEmail )

		//Envia uma solicitação de aprovação no fluig para cada aprovador do modelo de workflow
		For nX := 1 To Len(aUserWF)
			aAdd(aUserWF2,aUserWF[nX])

			cIDECM := AllTrim(Str(FWECMStartProcess(SuperGetMv("MV_TMKPROC",,"TMKA510"), /*nNextTask*/, /*cComments*/, aCardData, aAnexo, cUserId, aUserWF2, .T.)))
			aAdd(aIDECM,cIDECM)
			aUserWF2 := {}

		Next nX

		If FWWFIsError()
			lErro := .T.
			msgStop(STR0152+ FWWFGetError()[2])
		ElseIf !Empty(aIDECM)
			cInfo := STR0192 //"Processos "
			For nIdEcm := 1 To Len(aIDECM)
				cInfo += aIDECM[nIdEcm]
				If nIdEcm < Len(aIDECM)
					cInfo += "/ "
				EndIf
			Next nIdEcm

			MsgInfo(cInfo+STR0193,"Fluig") //" iniciados com sucesso."
		EndIf
	Else
		MsgStop( STR0194 ) //"O superior não possui usuário no Fluig, a solicitação não pode ser iniciada"
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o XML com os dados da proposta.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cXml := Tk510Xml(cCodADE, cCodADF, cCorpoEmail )

	aRet := BIStartTask(cProcesso,cCodADE+cCodADF+LTRIM(STR(SECONDS())),cProcesso,"",cXml,aAnexo,.T.,0,aUsers,cECMUser,"MD5:" + md5(cECMPsw))

	nPos := aScan( aRet, { |x| x[1] == "ERROR" } )
	If nPos > 0//se ocorreu erros
		lErro := .T.
		MsgStop( STR0152 + aRet[nPos][2] )
	Else
		cIDECM := aRet[3][2]
	EndIf
EndIf

If !lErro
	lRet := .T.
	nTamIdEcm := Len( aIDECM )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³cria registros na skw pra cada workflow enviado (por usuario)      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nUser_i := 1 to Len(aUsers)
		cEmail := UsrRetMail(aUsers[nUser_i])
	    //                (cUser,          cEmail,cAssunto,cCodeBlk,cLoteApr,cModelo,       dDate,cTime,    nTipoAuth,        cIDECM)
		If nTamIdEcm >= nUser_i
			cLoteApr:=WFAddSKW(aUsers[nUser_i],cEmail,cAssunto,cCodeBlk,cLoteApr,cCodWFTemplate,Date(),Time(), IIF(lIsAuto,2,1), aIDECM[nUser_i])
		Else
			cLoteApr:=WFAddSKW(aUsers[nUser_i],cEmail,cAssunto,cCodeBlk,cLoteApr,cCodWFTemplate,Date(),Time(), IIF(lIsAuto,2,1), "")
		EndIf
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³grava no item o codigo de wf (quando ha mais de um wf, grava o pai)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cCodADF) //quando vem da Regra de Monitoracao, nao esta associado a nenhum item especifico
		WFAtuStADF(cCodADE, cCodADF, /*cStatus*/, cLoteApr)
	EndIf


EndIf




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for workflow de autorização, altera o status do chamado para    ³
//³pendente (apenas se ele não estiver encerrado)                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIsAuto .AND. (!Empty(cCodADF)) //quando vem da Regra de Monitoracao, nao esta associado a nenhum item especifico
	WFAtuStADE(cCodADE)
	WFAtuStADF(cCodADE,nil, "3")

EndIf



RestArea(aArea)


Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510Email ºAutor  ³Vendas CRM          º Data ³19/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envia um email de WF direto pelo Send Mail                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                    º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ExpC1: Codigo do template de workflow                      º±±
±±º          ³ExpC2: Codigo do atendimento                               º±±
±±º          ³ExpC3: Codigo do item do atendimento                       º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³ExpL: Verdadeiro                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tk510Email(cCodWFTemplate, cCodADE, cCodADF)

Local aArea		 := GetArea()
Local aAreaSKY	 := SKY->(GetArea())			//Area SKY - templates de WF (master)
Local lTK510ATTF := ExistBlock("TK510ATTF")		//Ponto de Entrada para envio de anexo no workflow
Local lTK510HTM	 := ExistBlock("TK510HTM") 		//Ponto de entrada para alteração do HTML de corpo do e-mail do Workflow
Local cEmailDest := ''							//E-Mail do destinatario
Local cAssunto 	 := Posicione("SKY",1,xFilial("SKY")+cCodWFTemplate, "KY_SUBJECT") //Assunto da mensagem
Local cPathAnexo := ''							//Anexa o banner TOTVS11 Workflow
Local cHtml		 := '' 							//Corpo do email com os dados
Local cAccount	 := SuperGetMv("MV_RELAUSR") 	//Conta do remetente
Local cPassword	 := SuperGetMv("MV_RELAPSW") 	//Senha do remetente
Local cCtaEmail	 := SuperGetMv("MV_RELACNT")	//Conta Autenticacao Ex.: fuladetal@fulano.com.br
Local cServer	 := SuperGetMV("MV_RELSERV")	//Servidor SMTP
Local nX		 := 0							//Incremento para loop
Local aUsers	 := {}							//array com os usuarios destinatarios de email
Local cCorpoEmail:= Posicione("SKY",1,xFilial("SKY")+cCodWFTemplate, "KY_BODY")  //verifica o corpo do email configurado no template
Local lRet		 := .F.
Local cFrom		 := UsrRetMail(__cUserID)		//E-mail do usuário
Local aRetHtm	 := {}
Local cEmailTo	 := ""
Local cEmailCc	 := ""
Local cEmailCco  := ""
Local lOperAuth	 := (SKY->(ColumnPos("KY_AUTHSRV") > 0 .And. (Posicione("SKY",1,xFilial("SKY")+cCodWFTemplate,"KY_AUTHSRV") == "2")))

If lOperAuth 	//A autenticação no servidor será feita pela conta/senha conforme os dados do cadastro de operadores
	cAccount  := Posicione("SU7",4,xFilial("SU7") + __cUserID,"U7_CONTA")
	cPassword := Posicione("SU7",4,xFilial("SU7") + __cUserID,"U7_SENHA")
	// Captura a senha do operador sem criptografia
	If !Empty(cPassword)
		cPassword := Embaralha(cPassword,1)
	Endif
	cAccount  := AllTrim(cAccount)
	cPassword := AllTrim(cPassword)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega os usuarios que receberao o WF                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aUsers := FindUserWF(cCodWFTemplate)

For nX := 1 to Len(aUsers)
	cEmailDest +=  UsrRetMail(aUsers[nX]) + "; "
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³remove possiveis "" do campo de emails      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While At('"',cEmailDest) > 0
	cEmailDest:= SubStr(cEmailDest,1, At('"',cEmailDest)-1) + SubStr(cEmailDest,At('"',cEmailDest)+1,Len(cEmailDest))
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona E-mail E-mail quando houver                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk510MacroMail(cCodWFTemplate,@cEmailTo,@cEmailCc,@cEmailCco)

//ÚÄÄÄÄÄÄÄÄÄ¿
//³ anexos  ³
//ÀÄÄÄÄÄÄÄÄÄÙ
If lTK510ATTF // Adiciona arquivos anexos por ponto de entrada
	cPathAnexo := ExecBlock("TK510ATTF",.F.,.F., {cCodADE, cCodWFTemplate})
ElseIF Posicione("SKY",1,xFilial("SKY")+cCodWFTemplate, "KY_ANEXA") == "1" .AND. !IsInCallStack("TK510LSendWF") //verificar se o template esta configurado para solicitar anexo e se for chamado pela regra de monitoracao nao abre anexos
	cPathAnexo := AnexoWF()
EndIf

cHtml := Tk510Body(cCodADE, cCodADF, cCorpoEmail) // monta o corpo do email

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Ponto de entrada para alterar o e-mail do destinatário,  |
//| assunto e o código HTML do e-mail.			             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTK510HTM
	aRetHtm := ExecBlock("TK510HTM",.F.,.F.,{cCodADE,cCodWFTemplate,IIf(!Empty(cEmailTo),cEmailTo,cEmailDest),cAssunto,cHtml})
	If ValType(aRetHtm) == "A" .And. Len(aRetHtm) == 3 .And. !(Empty(aRetHtm[1]) .Or. Empty(aRetHtm[2]) .Or. Empty(aRetHtm[3]))
		If !Empty(cEmailTo)
			cEmailTo := aRetHtm[1]
		Else
			cEmailDest := aRetHtm[1]
		EndIf
		cAssunto   := aRetHtm[2]
		cHtml	   := aRetHtm[3]
	EndIf
EndIf

If !lOperAuth .And. !Empty(cAccount) .And. !Empty(cPassword)
	cFrom := AllTrim(cCtaEmail)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o email   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TkAccount(@cAccount,@cPassword)
	lRet:= TkSendMail(cAccount,cPassword,cServer,cFrom,cEmailDest,cAssunto,cHtml,cPathAnexo,cEmailTo,cEmailCc,cEmailCco,lOperAuth)
EndIf


SKY->(RestArea(aAreaSKY))
RestArea(aArea)

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk510WF    ºAutor  ³Vendas CRM          º Data ³19/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Analisa se envia o email direto ou pelo ECM                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                    º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ExpC1: Codigo do template de workflow                      º±±
±±º          ³ExpC2: Codigo do atendimento                               º±±
±±º          ³ExpC3: Codigo do item do atendimento                       º±±
±±º          ³ExpC4: Funcao executada no retorno                         º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³ExpL: Verdadeiro                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tk510WF(cCodWFTemplate, cCodADE, cCodADF, cCodeBlk)

Local aArea			:= GetArea()
Local aAreaSKY		:= SKY->(GetArea())	//Area SKY - templates de WF (master)
Local lInformativo 	:= (Posicione("SKY",1,xFilial("SKY")+cCodWFTemplate, "KY_TPWF") == "1" ) //verifica tipo de wf (informativo ou autorizacao)
Local lRet 			:= .F.

Default cCodeBlk := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for informativo envia direto, se for autorizacao envia pelo ECM    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lInformativo
	lRet:= Tk510Email(cCodWFTemplate, cCodADE, cCodADF)
Else
	lRet:= Tk510ECM(cCodWFTemplate, cCodADE, cCodADF,cCodeBlk)
EndIf


SKY->(RestArea(aAreaSKY))
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FindUserWF ºAutor  ³Vendas CRM          º Data ³19/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca lista de destinatarios para receber o workflow       º±±
±±º          ³de acordo com o que estiver cadastrado no template         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do template de workflow                     º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³ExpA1: Lista de usuarios {codigo,email)                    º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºUso       ³TMKA510                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FindUserWF(cCodWFTemplate)
Local aRet		:= {}				//array com os emails que receberao workflow
Local aArea 		:= GetArea()			//Area Atual
Local aAreaSKY	:= SKY->(GetArea())	//Area SKY - templates de WF (master)
Local aAreaAGZ	:= AGZ->(GetArea())	//Area ZZA - usuarios que receberao o WF (detail)

DbSelectArea("SKY")
DbSetOrder(1)

If DbSeek(xFilial("SKY")+cCodWFTemplate)

	DbSelectArea("AGZ")
	DbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica no cadastro do template de WF, quais usuarios deverao receber o WF  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If DbSeek(xFilial("SKY")+ cCodWFTemplate)
		While !Eof() .AND. AGZ->AGZ_FILIAL == xFilial("AGZ") .AND. AGZ->AGZ_TEMPWF == cCodWFTemplate
			Aadd(aRet,AGZ->AGZ_CODUSU) //pega o codigo do usuario e o email cadastrado no template pra receber o WF
			DbSkip()
		End
	EndIf

	AGZ->(RestArea(aAreaAGZ))

EndIf

SKY->(RestArea(aAreaSKY))
RestArea(aArea)

return aRet






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetArqs    ºAutor  ³Vendas CRM          º Data ³ 19/04/2012º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre tela para selecao de multiplos arquivos               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do template de workflow                     º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºUso       ³TMKA510                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GetArqs()

Local oButtonAdd
Local oButtonClose
Local oButtonConf
Local oButtonRem
Local oListBoxFile
Local aLista := {}
Local nListBoxFile := 1
Local oPanelAll
Local oPanelList
Local oPanelRight
Local oPanelTop
Local oSayTam
Local oSayTop
Local oDlgAttach
Local nMV_TMKSEAN	:= SuperGetMV("MV_TMKSEAN", .F., 1)
Local nTotalSize :=0


If !IsBlind()



	DEFINE MSDIALOG oDlgAttach TITLE STR0161 FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL //"Anexar Arquivos"

	@ 000, 000 MSPANEL oPanelAll SIZE 250, 150 OF oDlgAttach COLORS 0, 16777215 RAISED
	@ 000, 000 MSPANEL oPanelTop SIZE 249, 015 OF oPanelAll COLORS 0, 16777215 RAISED
	@ 002, 002 SAY oSayTop PROMPT STR0162 SIZE 196, 010 OF oPanelTop COLORS 0, 16777215 PIXEL //"Selecione os arquivos"
	@ 015, 199 MSPANEL oPanelRight SIZE 050, 119 OF oPanelAll COLORS 0, 16777215 RAISED
	@ 010, 004 BUTTON oButtonAdd PROMPT STR0163 SIZE 040, 010 OF oPanelRight ACTION AddArquivo(@oListBoxFile,@oSayTam, @aLista,nMV_TMKSEAN,@nTotalSize) PIXEL //"ADICIONAR"
	@ 024, 004 BUTTON oButtonRem PROMPT STR0164 SIZE 040, 010 OF oPanelRight ACTION RemoveAnexo(@oListBoxFile,@oSayTam, @aLista, @nTotalSize) PIXEL //"REMOVER"
	@ 015, 000 MSPANEL oPanelList SIZE 199, 119 OF oPanelAll COLORS 0, 16777215 RAISED
	@ 000, 000 LISTBOX oListBoxFile FIELDS HEADER STR0165, STR0166, STR0167 SIZE 198,133 OF oPanelList //"Arquivo","Tamanho","Tamanho (bytes)"
	@ 134, 000 MSPANEL oPanel1 SIZE 249, 015 OF oPanelAll COLORS 0, 16777215 RAISED
	@ 004, 001 SAY oSayTam PROMPT STR0168 + ":" SIZE 106, 007 OF oPanel1 COLORS 0, 16777215 PIXEL //"Tamanho Total:"
	@ 000, 195 BUTTON oButtonConf PROMPT STR0169 SIZE 050, 012 OF oPanel1 ACTION IIF(oDlgAttach:End(),oDlgAttach:End(),) PIXEL //"CONFIRMAR"


	oListBoxFile:SetArray( aLista )

	If Len( aLista ) = 0
		oListBoxFile:bLine:={|| { "", "", ""} }
	Else
		oListBoxFile:bLine:={||{ aLista[oListBoxFile:nAt,1],aLista[oListBoxFile:nAt,2],aLista[oListBoxFile:nAt,3] }}
	EndIf


	// Don't change the Align Order
	oPanelAll:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelTop:Align := CONTROL_ALIGN_TOP
	oPanel1:Align := CONTROL_ALIGN_BOTTOM
	oPanelRight:Align := CONTROL_ALIGN_RIGHT
	oPanelList:Align := CONTROL_ALIGN_ALLCLIENT
	oListBoxFile:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgAttach CENTERED
EndIf





Return aLista




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AddArq     ºAutor  ³Vendas CRM          º Data ³19/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que abre a janela para que sejam selecionados os    º±±
±±º          ³arquivos a serem adicionados ao worflow                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AddArquivo(oList,oSayTam, aLista, nVisualiza, nTotalSize)

Local nVisibilidade	:= Nil
Local cAnexo		:= ""
Local cDrive		:=""
Local cFile		:=""
Local cDir		:=""
Local cExten		:=""
Local nHandle		:= 0
Local cArq		:=""
Local aDirectory
Local nAttSize

default aLista :={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Controle de segurança de visualização dos diretórios do servidor e remote.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nVisualiza == 1
	nVisibilidade := Nil													// Exibe todos os diretórios do servidor e do cliente
ElseIf nVisualiza == 2
	nVisibilidade := GETF_ONLYSERVER										// Somente exibe o diretório do servidor
ElseIf nVisualiza == 3
	nVisibilidade := GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE	// Somente exibe o diretório do cliente
EndIf

cAnexo := cGetFile(STR0164 + " (*.*)|*.*", STR0162,0,"",.T.,nVisibilidade, If(nVisibilidade==56, .F., .T.)) //Todos os arquivos (*.*)|*.* Selecione o arquivo

SplitPath( cAnexo, @cDrive, @cDir, @cFile, @cExten )

cFileName := cFile+cExten

aDirectory := Directory(cAnexo)

If (ValType(aDirectory) == "A" .AND. Len(aDirectory) == 1 )
	nAttSize := aDirectory[1][2]
	nTotalSize +=  nAttSize
EndIf


If nTotalSize < 1048576 // limite de 1 MB
	Aadd(aLista,{cFile+cExten,cAnexo,nAttSize})

	oList:SetArray( aLista)
	oList:bLine:={||{ aLista[oList:nAt,1], aLista[oList:nAt,2], aLista[oList:nAt,3] }}
	oList:Refresh()
Else
	nTotalSize -= nAttSize
	MsgStop(STR0171,STR0172)//"O tamanho total dos arquivos ultrapassa o limite de 1 MB. O arquivo selecionado não poderá ser anexado.","Tamanho limite no total dos arquivos: 1MB"
EndIf

oSayTam:SetText(STR0168 + ":" + " " + cValToChar(Round((nTotalSize / 1024),0)) + " kb") //"Tamanho Total:"

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RemoveAnexoºAutor  ³Vendas CRM          º Data ³19/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que remove da lista de arquivos anexos o arquivo    º±±
±±º          ³selecionado                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKA510                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function RemoveAnexo(oList,oSayTam, aLista,nTotalSize)


If Len(aLista) > 0
	nTotalSize := nTotalSize - (aLista[oList:nAt][3])
Else
	nTotalSize := 0
EndIf

ADEL(aLista,oList:nAt)

ASIZE(aLista,Len(aLista) - 1)

oList:SetArray(aLista)
oList:bLine:={||{ aLista[oList:nAt,1], aLista[oList:nAt,2], aLista[oList:nAt,3] }}
oList:Refresh()

oSayTam:SetText(STR0168 + ":" + " " + cValToChar(Round((nTotalSize / 1024),0)) + " kb") //"Tamanho Total:"


Return Nil




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AnexoWF    ºAutor  ³Vendas CRM          º Data ³   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre dialog p/ selecionar arquivos para anexo no WF        º±±
±±º          ³Permite selecionar mais de um arquivo, mas compacta todos  º±±
±±º          ³gerando um unico arquivo compactado que sera enviado como  º±±
±±º          ³anexo do email. Limitacao de 1MB (motivo: limitacao do     º±±
±±º          ³compilador).                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpC1: caminho (path) do arquivo compactado para anexo     º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºUso       ³                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AnexoWF()

Local aArqs 		:= {} 				//array com os arquivos selecionados para anexar
Local aNomes 		:= {}				//array com o caminho dos arquivos no diretorio temporario para anexar
Local nX			:= 1 				//incremento do loop
Local cTempDir	:= "\workflow\anexos\"	//diretorio temporario dos arquivos a serem anexados
Local cArquivoTar := '' 				//caminho do arquivo compactado
Local nHandleOri	:= -1 				//handle do arquivo original
Local nHandleDest	:= -1 				//handle do arquivo gravado
Local cNomeAqr	:= '' 				//nome + extensao do arquivo
Local cPathArq	:= '' 				//caminho completo -> path + nome + extensao
Local nTamArq		:= 0	 				//tamanho do arquivo
Local cArq		:= '' 				//conteudo do arquivo que sera lido

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Os arquivos selecionados sao jogados em um diretorio temporario padrao    ³
//³(que sera automaticamente criado se ainda nao existir). Isso eh           ³
//³necessario porque a funcao TarCompress nao aceita arquivos do remote      ³
//³                                                                          ³
//³No final, todos os arquivos desse diretorio padrao serao compactados em   ³
//³um unico arquivo TAR.                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


aArqs := GetArqs() //seleciona os arquivos para anexar

If Len(aArqs) > 0
	//cria os diretorios, se nao existirem
	If !ExistDir("\workflow")
		MakeDir("\workflow")
	EndIf
	MakeDir(cTempDir)

	//copia os arquivos para o servidor
	For nX:= 1 to Len(aArqs)
		cNomeAqr := aArqs[nX][1]
		cPathArq := aArqs[nX][2]

		If SubStr(cPathArq,1,1) = '\'  //se ja estiver no servidor
			nHandleOri := FOpen(cPathArq )

			If nHandleOri <> -1
				nTamArq := FSEEK(nHandleOri,0,2) //tamanho do arquivo

				FSEEK(nHandleOri, 0)  //posiciona o ponteiro no inicio do arquivo novamente
				FRead(nHandleOri, @cArq, nTamArq)

				nHandleDest:= FCreate(cTempDir + "\" + cNomeAqr)

				FWrite(nHandleDest, cArq) // Insere texto no arquivo
				FClose(nHandleOri)
				FClose(nHandleDest)

			EndIf

		Else//se estiver no remote
			CpyT2S(cPathArq, cTempDir)
		EndIf

		Aadd(aNomes, cTempDir + "\" + aArqs[nX][1])

	Next

	//aArquivoTar := {{SubStr(cNomeAqr,1,AT(".",cNomeAqr)-1),"\"+cNomeAqr}}
	cArquivoTar := cTempDir + "\anexo_" + __cUserId + LTRIM(STR(SECONDS())) + ".tar"
	TarCompress( aNomes, cArquivoTar)

EndIf

//Return aArquivoTar
Return cArquivoTar



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjAnexoWF  ºAutor  ³Vendas CRM          º Data ³ 19/04/2012º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta array com os dados do anexo no formato esperado      º±±
±±º          ³pelo ECM.                                                  º±±
±±º          ³                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: caminho do arquivo                                  º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³ExpA1: Array com dados do anexo no padrao do ECM           º±±
±±º          ³{<descricao>, <nome fisico>, <conteudo>}                   º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºUso       ³                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AjAnexoWF(cAnexo)

Local aRet 		:= {}	//retorno com dados no padrao do ECM
Local cArq		:= '' 	//vai receber o conteudo do arquivo
Local cDrive		:= ''	//drive do arquivo (por exemplo C:/)
Local cDir		:= ''	//diretorio do arquivo
Local cFile		:= ''	//nome do arquivo
Local cExten		:= ''	//extensao do arquivo

SplitPath( cAnexo, @cDrive, @cDir, @cFile, @cExten )

nHandle := FOpen(cAnexo)		//abre o arquivo
If nHandle <> -1
	nTamArq := FSEEK(nHandle,0,2) //tamanho do arquivo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³valida tamanho do arquivo | limitcao do compilador - 1 MB                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTamArq < 1048576
		FSEEK(nHandle, 0)  //posiciona o ponteiro no inicio do arquivo novamente
		FRead(nHandle, @cArq, nTamArq)	 // carrega os dados do arquivo na variavel cArq
		//aRet := {cFile,(cFile+cExten),cArq}  //formata a saida com os campos descricao, nome fisico e conteudo
		//aRet := {{cFile,(cFile+cExten)}}  //formata a saida com os campos descricao, nome fisico e conteudo
		aRet := {{cFile,cAnexo}}
	Else

		MsgStop(STR0171) //"O tamanho do arquivo excede o máximo permitido (1MB)"

	EndIf
EndIf

Return aRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WFAtuStADE ºAutor  ³Vendas CRM          º Data ³ 19/04/2012º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera o status geral do chamado (ADE)                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - codigo do chamado                                  º±±
±±º          ³ExpC2 - status dos wf's do chamado                         º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºUso       ³TMKA510A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function WFAtuStADE(cCodChamado, cStatusWF)

Local aArea 			:= GetArea()
Local aAreaADE	 	:= ADE->(GetArea())	//chamado
Local cStatus			:= '2'				//status do chamado =  pendente
Default cStatusWF		:= '5' 				//status do wf = aguardando resposta

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³cStatusWF (status workflow)                                                 ³
//³1 - sem workflow de autorizacao                                             ³
//³2 - com wf aprovados e reprovados                                           ³
//³3 - aprovado                                                                ³
//³4 - reprovado                                                               ³
//³5 - aguardando resposta                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³cStatus (status do chamado)                                                 ³
//³1 - Em aberto                                                               ³
//³2 - Pendente                                                                ³
//³3 - Encerrado                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³se nao tiver nenhum worflow aguardando resposta atualiza status do chamado para aberto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cStatusWF $ '234'
	cStatus := '1'
EndIf


DbSelectArea("ADE")
DbSetOrder(1)
If 	MsSeek(xFilial("ADE")+cCodChamado).AND. ADE->ADE_STATUS <> "3"

	BEGIN TRANSACTION
		RecLock("ADE", .F.)
		REPLACE ADE->ADE_STATUS WITH cStatus
		IF ADE->(FieldPos("ADE_WFASTA")) > 0
			REPLACE ADE->ADE_WFASTA WITH cStatusWF
		EndIf
		MsUnlock()
	END TRANSACTION
EndIf

RestArea(aAreaADE) //Restaura area - cabecalho do chamado
RestArea(aArea) //Restaura area - atual

Return nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WFAtuStADF ºAutor  ³Vendas CRM          º Data ³19/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera o status do item do chamado                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - codigo do chamado (ADE)                            º±±
±±º          ³ExpC2 - codigo do item    (ADF)                            º±±
±±º          ³ExpC3 - status do wf                                       º±±
±±º          ³ExpC4 - codigo do modelo de workflow                       º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºUso       ³TMKA510A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function WFAtuStADF(cCodChamado, cCodItem, cStatus, cCodSKW)

DbSelectArea("ADF")
DbSetOrder(1)
	If DbSeek(xFilial("ADF")+cCodChamado)

		While ADF->(!EOF()) .AND. ADF->ADF_FILIAL == xFilial("ADF") .AND.  ADF->ADF_CODIGO == cCodChamado

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³se recebeu o codigo do item atualiza apenas ele, senao atualiza todos       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If 	Empty(cCodItem) .OR. ADF->ADF_ITEM == cCodItem
				BEGIN TRANSACTION
					RecLock("ADF", .F.)
					If !Empty(cStatus)
						If ADF->(FieldPos("ADF_SKWSTA")) > 0
							REPLACE ADF->ADF_SKWSTA WITH cStatus	//altera o status de wf do item do chamado
						EndIf
					EndIf

					If !Empty(cCodSKW)
						REPLACE ADF->ADF_CODSKW WITH cCodSKW	//grava o codigo do workflow associado ao item
					EndIf


					ADF->(MsUnlock())
				END TRANSACTION

			EndIf
			ADF->(DbSkip())
		End
	EndIf
Return nil





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TkEcmWFRet    ºAutor³Vendas Clientes   º Data ³ 19/04/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recebe o retorno do workflow de aprovacao.                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - ID do processo no protheus                          º±±
±±º          ³ExpC2 - parametros de retorno do ECM.Esse campo eh uma      º±±
±±º          ³        string com tags que separam cada valor de retorno.  º±±
±±º          ³ExpC3 - ID do processo no ECM                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function TkEcmWFRet(cIdPrt,cParams,cIdECM)

Local lTK510WFRE		:= ExistBlock("TK510WFRE")
Local cStatus  		:= EntreTags(cParams, "<STATUS>"	, "</STATUS>") 	//status da tarefa no ECM
Local cObsEcm    		:= EntreTags(cParams, "<OBS>"		, "</OBS>")		//observacao apos aprovaacao ou reprovacao
Local cChamado		:= EntreTags(cParams, "<CODADE>"	, "</CODADE>")	//codigo do chamado
Local cItemCh      	:= EntreTags(cParams, "<CODITEM>"	, "</CODITEM>")	//item do chamado
Local cUsuario 		:= EntreTags(cParams, "<USER>"		, "</USER>") 		//codigo do usuario
Local cStaItemWF		:= '' //Status do workflow (item do chamado) (1 - aprovado | 2 - Reprovado | 3 - Pendente)
Local cStaADEWF		:= '' //Status do chamado, considerando todos os workflows (2 - Aprovado/Reprovado |	3 - Aprovado |	4 - Reprovado | 5 - Aguardando resposta)
Local cObsSKW			:= '' //observacao da SKW
Local cCodOco			:= '' //codigo da ocorrencia -> TMK004 = aprovado | TMK005 = reprovado
Local cObsADE			:= '' //observacao do chamado
Local cFlgAuto		:= PADR(AllTrim(SuperGetMv("MV_FLGAUTO",,"")),TamSX3("U7_COD")[1])	//Parametro que irá indicar qual o código do Operador padrão a ser atribuido nas interações automáticas acionadas no Protheus pelo Fluig

//codigo pai dos registros de workflow
Local cCodWFPai		:= ADF->(Posicione("ADF",1,xFilial("ADF")+ PADR(cChamado,Len(ADF->ADF_CODIGO))+ PADR(cItemCh,Len(ADF->ADF_ITEM)), "ADF_CODSKW"))
//Tipo de aprovacao do workflow ->  '1' = aprovado    |   '2' = reprovado    | '' = pendente
Local cStatusItem		:= SKW->(Posicione("SKW",4, xFilial("SKW") + PADR(cIdECM,Len(SKW->KW_IDECM)) + PADR(cUsuario,Len(SKW->KW_USER)), "KW_AUTORIZ"))
//bloco de codigo a ser executado no retorno do ECM
Local cBlkRet			:= SKW->(Posicione("SKW",4,xFilial("SKW") + PADR(cIdECM,Len(SKW->KW_IDECM)) + PADR(cUsuario,Len(SKW->KW_USER)), "KW_CODEBLK"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a aprovacao for automatica (job executado quando ultrapassa o prazo) o   ³
//³ECM chama essa funcao, mas a atualizacao do protheus ja foi feita pelo job. ³
//³Entao sai da funcao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !(cStatusItem $ '12') //se o workflow nao esta aprovado

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³verifica se tem alguma funcao especifica pra ser executada,                 ³
	//³senao executa os procedimentos padroes                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cBlkRet)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o status na tabela de controle de aprovacao                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		WFStaMult(cIdECM, cStatus, cUsuario,'U',cObsEcm)

		Eval({||&cBlkRet})
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o status na tabela de controle de aprovacao                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		WFStaMult(cIdECM, cStatus, cUsuario, 'U',cObsEcm)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o workflow esta aprovado (avalia multiaprovacao).               ³
		//³Internamente, se a qtde de aprovadores/reprovadores for atingida,           ³
		//³atualiza os outros registros de wf com o tipo automatico e atualiza no ECM  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cStaItemWF := GetStaWF(cChamado, cItemCh, @cObsSKW)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza item do chamado com o status do workflow                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		WFAtuStADF(cChamado, cItemCh, cStaItemWF)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica status geral do chamado. Se o chamado possui algum workflow pendente ainda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cStaADEWF := GetStaGeral(cChamado) //internamente eu vejo qual o codigo do chamado (mestre) e entao eu busco o status de todos os wf daquele chamado

		If cStaADEWF == '3'
			cObsADE := STR0042 + CRLF //"Chamado Aprovado"
			cCodOco := "TMK004"
		ElseIf  cStaADEWF == '4'
			cObsADE := STR0043 + CRLF //"Chamado Reprovado"
			cCodOco := "TMK005"
		EndIf

		If cStaADEWF $ '34'

			cObsADE +=  cObsSKW
			TkUpdCall(	/*cFil*/,;
						""/*cCodAction*/,;
						/*cCodReview*/,;
						cObsADE,;
						/*cTPACAO*/,;
						cFlgAuto,;
						Iif(!Empty(cFlgAuto),Posicione("SU7", 1, xFilial("SU7")+cFlgAuto, "U7_POSTO"),""),;
						"",;
						/*dPrazo*/,;
						If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ),;
						cChamado,;
						cCodOco)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³//Atualiza status geral do chamado                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		WFAtuStADE(cChamado, cStaADEWF)


		If lTK510WFRE
			ExecBlock("TK510WFRE", .F., .F., {cChamado, SKW->KW_CODIGO})
		EndIf

	EndIf //If !Empty(cBlkRet)

EndIf //se o workflow nao esta aprovado

Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WFStaMult     ºAutor³Vendas & CRM      º Data ³ 19/04/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o status recebido do ECM na tabela de controle     º±±
±±º          ³de aprovacao                                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Id ECM                                               º±±
±±º          ³ExpC2: status do workflow ->  1 = aprovado | 2 = reprovado  º±±
±±º          ³ExpC3: usuario                                              º±±
±±º          ³ExpC4: tipo de aprovacao -> A = automatica | U = usuario    º±±
±±º          ³ExpC5: observacao recebida do ECM                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function WFStaMult(cIdECM, cStatus, cUsuario, cTpAprov, cObsEcm)

Local aArea 			:= GetArea()			// tabela atual
Local aAreaSKW 		:= SKW->(GetArea()) 	// tabela de registros de workflow

Local cStaWF			:= IIF(cStatus = 'S', '1', '2') //trata o status. 1-> aprovado | 2-> reprovado

Default cObsEcm 		:= ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³se o item do chamado tem algum workflow associado    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Empty(cIdECM)

	DbSelectArea("SKW")
	DbSetOrder(4) //filial + IdECM + Usuario

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³se encontrou o workflow associado ao item do chamado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SKW->(DbSeek( xFilial("SKW") + PADR(cIdECM,Len(SKW->KW_IDECM)) + PADR(cUsuario,Len(SKW->KW_USER))))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³atualiza o a resposta da aprovacao e a forma da resposta (automatica ou manual)       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("SKW",.F.)
			SKW->KW_AUTORIZ 	:= cStaWF
			SKW->KW_TPAPROV  	:= cTpAprov
			SKW->KW_OBS		:= cObsEcm
		SKW->(MsUnLock())
	EndIf

EndIf


SKW->(RestArea(aAreaSKW))
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetStaWF      ºAutor³Vendas & CRM      º Data ³ 19/04/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o status geral do workflow (considerando a          º±±
±±º          ³multiaprovacao, quando tiver). Se o status for diferente de º±±
±±º          ³pendente e for multiaprovacao, atualiza os registros deste  º±±
±±º          ³wf que ainda estiverem pendentes.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: codigo do chamado                                    º±±
±±º          ³ExpC2: item do chamado                                      º±±
±±º          ³ExpC3: observacao do wf (parametro passado por referencia)  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpC: Status geral do workflow (avaliando a multiaprovacao) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GetStaWF(cChamado, cItemCh, cObsSKW)

Local aArea 			:= GetArea()			// tabela atual
Local aAreaSKW 		:= SKW->(GetArea()) 	// tabela de registros de workflow
Local aAreaADF		:= ADF->(GetArea()) 	// tabela de itens de chamado
Local aAreaSKY		:= SKY->(GetArea()) 	// tabela de modelos de workflow

//codigo pai dos registros de workflow
Local cCodWFPai		:= Posicione("ADF",1,xFilial("ADF")+PADR(cChamado,Len(ADF->ADF_CODIGO))+PADR(cItemCh,Len(ADF->ADF_ITEM)), "ADF_CODSKW")

Local nAprovado		:= 0	//contador com a qtde de aprovacoes do wf
Local nReprovado		:= 0	//contador com a qtde de rejeicoes do wf

Local cModelo			:= ''//codigo do modelo (template) de workflow
Local cCondicao 		:= ''//determina se a aprovacao eh por percentual ou por quantidade
Local nValorCond		:= 0 //quantidade ou percentual minimo para definir o status do wf
Local nTotalUser		:= 0	//quantidade total de usuarios que ira avaliar o wf
Local nQtdeMin		:= 0	//quantidade minima para aprovacao (apos avaliacao de percentual)

Local cStaGeral		:= '3'//status geral do wf apos avaliar multiaprovacao (1 - aprovado | 2 - reprovado | 3 - pendente)
Local cCdUsrF			:= ""
Local lCancel := .F.

Default cObsSKW := ''

DbSelectArea("SKW")
DbSetOrder(3) //filial + KW_LOTEAPR + usuario  ->  KW_LOTEAPR = codigo do workflow que encabeca os outros (wf pai)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³se encontrou o workflow associado ao item do chamado      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF SKW->(DbSeek( xFilial("SKW") + PADR(cCodWFPai,Len(SKW->KW_LOTEAPR))))

	cModelo := SKW->KW_MODELO //guarda o modelo para depois buscar os dados de configuracao do modelo de wf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³verifica todos os registros de workflow associados ao item do chamado      ³
	//³(quando for multiaprovacao tera um registro pra cada aprovador)            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While SKW->(!EOF()) .AND. SKW->KW_FILIAL == xFilial("SKW") .AND. SKW->KW_LOTEAPR == cCodWFPai
		Do Case
			Case SKW->KW_AUTORIZ == '1'
				nAprovado++
				cStaGeral := '1'
			Case SKW->KW_AUTORIZ == '2'
				nReprovado++
				cStaGeral := '2'
		EndCase
		cObsSKW += CRLF + STR0047 + SKW->KW_EMAIL + CRLF // "E-mail do aprovador: "
		cObsSKW += STR0044 + SKW->KW_OBS //"Comentário do aprovador: "
		SKW->(DbSkip())
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³verifica configuracoes do modelo de wf      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCondicao 	:= Posicione("SKY",1,xFilial("SKY")+PADR(cModelo,Len(SKY->KY_CODIGO)), "KY_MULTICO")
	nValorCond	:= Posicione("SKY",1,xFilial("SKY")+PADR(cModelo,Len(SKY->KY_CODIGO)), "KY_MULTIVA")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³avalia qual eh a qtde nubuna de aprovadores ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCondicao == '2' //aprovacao por quantidade
		nQtdeMin := nValorCond
	Else //aprovacao por percentual
		nTotalUser := WFTotUser(cModelo) //busca total de aprovadores do wf
		nQtdeMin :=  Int(nValorCond * nTotalUser/100)
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³se for multiaprovacao, analisa se a quantidade necessaria ja respondeu o chamado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTotalUser > 1
		Do Case
			Case nAprovado  >= nQtdeMin // aprovado
				cStaGeral := '1'
			Case nReprovado >= nQtdeMin // reprovado
				cStaGeral := '2'
			Otherwise	//pendente
				cStaGeral := '3'
		EndCase
	EndIF
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aprova automaticamente os registros pendentes quando a quantidade minima  ³
//³necessaria de respostas for atingida                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTotalUser > 1 .AND. cStaGeral <> '3' //Se for multiaprovacao e status geral do chamado diferente de pendente (aguardando resposta)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³faz a aprovacao/rejeicao automatica dos registros pendentes do workflow   ³
	//³(multiaprovacao)                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SKW")
	DbSetOrder(3) //filial + codWorkflowPai

	IF DbSeek( xFilial("SKW") + PADR(cCodWFPai,Len(SKW->KW_LOTEAPR)) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³procura por registros de wf pendentes para aprovar ou reprovar automaticamente   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While SKW->(!EOF()) .AND. SKW->KW_FILIAL == xFilial("SKW") .AND. SKW->KW_LOTEAPR == cCodWFPai

			If SKW->KW_AUTORIZ <> '1' .AND. SKW->KW_AUTORIZ <> '2' // status = pendente ('3' ou ' ')

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³atualiza o a resposta da aprovacao e a forma da resposta = automatica            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("SKW",.F.)
				SKW->KW_AUTORIZ := cStaGeral
				SKW->KW_TPAPROV  := "A"
				MsUnLock()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza status no ECM - abre outra thread pra nao dar dead lock no ECM          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//StartJob("TK510ATECM",GetEnvServer(),.F.,cChamado, cItemCh, Trim(SKW->KW_IDECM), Trim(SKW->KW_USER), IIF(cStaGeral == '1' ,'S', 'N'), .T.,cEmpAnt,cFilAnt)


				If !Empty(SKW->KW_IDECM)
					cCdUsrF := FWWFUserId(VAL(SKW->KW_IDECM))
					If !Empty(cCdUsrF)
						lCancel := FWECMCancelProcess(VAL(SKW->KW_IDECM),cCdUsrF,STR0248) //"Aprovação/ Reprovação Automatica."
						If FWWFIsError()
							aError := FWWFGetError()
							MsgStop(aError[2])
						EndIf
					EndIf
				EndIf

			EndIf

			SKW->(DbSkip())
		End

	EndIf


EndIf

ADF->(RestArea(aAreaADF))
SKY->(RestArea(aAreaSKY))
SKW->(RestArea(aAreaSKW))
RestArea(aArea)

Return cStaGeral


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetStaGeral   ºAutor³Vendas & CRM      º Data ³ 19/04/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pega o status geral do chamado. Considerando os status de   º±±
±±º          ³workflow de cada item do chamado.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: codigo do chamado                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpC: Status do chamado                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GetStaGeral(cChamado)

Local aArea 			:= GetArea()			// tabela atual
Local aAreaADF		:= ADF->(GetArea()) 	// tabela de itens de chamado

Local nAprovado		:= 0		//contador com a qtde de aprovacoes do wf
Local nReprovado		:= 0		//contador com a qtde de rejeicoes do wf
Local nPendente		:= 0		//contador com a qtde de wf pendentes de resposta

Local cStaGeral		:= '5'	//(2 - Aprovado/Reprovado |	3 - Aprovado |	4 - Reprovado | 5 - Aguardando resposta)

DbSelectArea("ADF")
DbSetOrder(1) //filial + codChamado + Item

cChamado := PADR(cChamado,Len(ADF->ADF_CODIGO))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³se encontrou os itens do chamado              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF DbSeek( xFilial("ADF") + cChamado )


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³verifica status de todos os itens do chamado  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ADF->(!EOF()) .AND. ADF->ADF_FILIAL == xFilial("ADF") .AND. ADF->ADF_CODIGO == cChamado

		Do Case
			Case ADF->ADF_SKWSTA == '1'
				nAprovado++
			Case ADF->ADF_SKWSTA == '2'
				nReprovado++
			Case ADF->ADF_SKWSTA == '3'
				nPendente++
		EndCase

		ADF->(DbSkip())
	End


EndIf


Do Case
	Case nPendente > 0 //possui wf pendente de aprovacao
		cStaGeral := '5'
	Case nAprovado > 0 .And. nReprovado > 0 //possui wf aprovados e reprovados
		cStaGeral := '2'
	Case nAprovado > 0 //possui somente wf aprovados
		cStaGeral := '3'
	Case nReprovado > 0 //possui somente wf reprovados
		cStaGeral := '4'
EndCase


ADF->(RestArea(aAreaADF))
RestArea(aArea)

Return cStaGeral




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WFTotUser     ºAutor³Vendas & CRM      º Data ³ 19/04/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pega o total de usuarios que recebeu o workflow             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1:codigo do template de workflow                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpN: Quantidade total de usuarios cadastrados no template  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function WFTotUser(cCodWF)

Local aArea		:= GetArea()
Local aAreaAGZ	:= AGZ->(GetArea())
Local nTotUser	:= 0

DbSelectArea("AGZ")
DbSetOrder(1)

If	DbSeek( xFilial("AGZ") + cCodWF)

	While AGZ->(!EOF()).AND. AGZ->AGZ_FILIAL == xFilial("AGZ") .AND. AGZ->AGZ_TEMPWF == cCodWF
		nTotUser++
		AGZ->(DbSkip())
	End

EndIf


AGZ->(RestArea(aAreaAGZ))
RestArea(aArea)

Return nTotUser

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EntreTags     ºAutor³Vendas & CRM      º Data ³ 19/04/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a SubString entre duas tags de uma String           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: Texto completo                                       º±±
±±º          ³ExpC2: tag inicial                                          º±±
±±º          ³ExpC3: tag final                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpC: string extraida entre as 2 tags                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EntreTags(cTexto, cTagIni, cTagFim)

Local cStrRet := '' 				// texto que sera extraido e retornado
Local nPosIni := At(cTagIni,cTexto)	// posicao inicial da tag
Local nPosFim := At(cTagFim,cTexto)	// posicao final da tag

cStrRet := Substr(cTexto, (nPosIni + Len(cTagIni)), (nPosFim-nPosIni-Len(cTagIni)) )

Return cStrRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WFAddSKW      ºAutor³Vendas & CRM      º Data ³19/04/2012   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Adiciona registro na SKW (registros de workflow)            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: usuario                                              º±±
±±º          ³ExpC2: email                                                º±±
±±º          ³ExpC3: assunto                                              º±±
±±º          ³ExpC4: bloco de codigo de retorno                           º±±
±±º          ³ExpC5: codigo do workflow pai (que encabeca os outros wf    º±±
±±º          ³       do mesmo item do chamado                             º±±
±±º          ³ExpC6: codigo do modelo (template) de workflow              º±±
±±º          ³ExpC7: data                                                 º±±
±±º          ³ExpC8: hora                                                 º±±
±±º          ³ExpC9: tipo de aprovacao -> A = automatica | U = usuario    º±±
±±º          ³ExpC10:ID do processo no ECM                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpC: retorna o codigo do workflow pai dos wf               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function WFAddSKW(cUser,cEmail,cAssunto,cCodeBlk,cLoteApr,cModelo,dDate,cTime,nTipoAuth,cIdECM)

Local aArea		:= GetArea()
Local aAreaSKW	:= SKW->(GetArea())
Local cRetCodSKW


BEGIN TRANSACTION
	DbSelectArea("SKW")
	DbSetOrder(1) //KW_FILIAL+KW_CODIGO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclusao SKW            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SKW",.T.)
	SKW->KW_CODIGO 	:= GetSx8Num("SKW","KW_CODIGO")
	SKW->KW_FILIAL	:= xFilial("SKW")
	SKW->KW_USER 		:= cUser
	SKW->KW_EMAIL  	:= cEmail
	SKW->KW_SUBJECT	:= cAssunto
	SKW->KW_CODEBLK	:= cCodeBlk
	SKW->KW_IDECM		:= cIdECM

	If SKW->(FieldPos("KW_LOTEAPR")) > 0
		If Empty(cLoteApr) //quando for o pai(o primeiro), o parametro vem vazio. Preenche com o proprio codigo
			cLoteApr := SKW->KW_CODIGO
		EndIf
		SKW->KW_LOTEAPR := cLoteApr  //codigo do wf pai que encabeca os outros
	EndIf
	If SKW->(FieldPos("KW_MODELO")) > 0
		SKW->KW_MODELO := cModelo
	EndIf
	If SKW->(FieldPos("KW_DATE")) > 0
		SKW->KW_DATE := dDate
	EndIf
	If SKW->(FieldPos("KW_TIME")) > 0
		SKW->KW_TIME := cTime
	EndIf
	If ( nTipoAuth == 2 )
		SKW->KW_AUTORIZ := ""		//Aguardando aprovacao
	Else
		SKW->KW_AUTORIZ := "0"	//Workflow Informativo
	EndIf


	MsUnlock()
	ConfirmSX8()
	cRetCodSKW := SKW->KW_CODIGO


END TRANSACTION

SKW->(RestArea(aAreaSKW))
RestArea(aArea)

Return cLoteApr


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK510ATECM ºAutor  ³Vendas CRM          º Data ³19/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o status do processo de teleatendimento no ECM.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: codigo do chamado                                   º±±
±±º		    ³ExpC2: item do chamado                                     º±±
±±º		    ³ExpC3: ID no ECM                                           º±±
±±º		    ³ExpC4: codigo do usuario                                   º±±
±±º		    ³ExpC5: status (aprovado ou reprovado) -> 'S' ou 'N'        º±±
±±º		    ³ExpL6: Inicializa ambiente? quando for via job             º±±
±±º		    ³ExpC7: empresa (para inicializar o ambiente)               º±±
±±º		    ³ExpC8: filial  (para inicializar o ambiente)               º±±
±±º		    ³ExpC9: codigo do usuario                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL: Retorno da atualizacao no ECM                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TK510ATECM(cCodChamado,cItemChamado,cIdECM,cCodUser,cStatus, lSetEnv,cEmpAnt,cFilAnt )

Local aRet 		:= {}							   			// Array com status do processo
Local lRet		:= .F.										// retorno da funcao. True quando nao der erro na atualizacao do ECM
Local cMD5 		:= ""										// Senha em MD5 do usuario
Local nPos 		:= 0 							   			// Posicao do array
Local oXML 		:= Nil										// Objeto XML com dados do chamado
Local cXML 		:= ""										// XML da proposta no formato string
Local cError 		:= ""						   				// Caso a funcao XmlParser retornar um erro a varivel sera preenchida
Local cWarning 	:= "" 										// Caso a funcao XmlParserretornar uma advertencia a varivel sera preenchida
Local cComments 	:= IIF(cStatus=="S",STR0156,STR0157) // Aprovacao Automatica - Reprovacao Automatica
Local nNextTask 	:= IIF(cStatus=="S",NTASKAPR,NTASKREP)			// Reprovacao Automatica
Local xStatus   	:= IIF(cStatus=="S",Upper(STR0158),Upper(STR0159))	// Aprovado/Reprovado
Local aUsers		:={cCodUser}									//usuario do ECM


Default lSetEnv := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³verifica se precisa inicializar o ambiente (quando usa outra thread)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSetEnv
	Sleep(4000)
	RpcSetEnv(cEmpAnt,cFilAnt)
EndIf


cMD5   := PswMD5GetPass(cCodUser) //criptografa a senha
cXML   := Tk510Xml(cCodChamado,cItemChamado) //gera o xml


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza ECM        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := BIUpdateTask(cIdECM,cComments,cXML,{},.T.,nNextTask,aUsers,cCodUser,"MD5:"+cMD5)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³verifica retorno do ECM (se ocorreu algum erro)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := aScan( aRet, { |x| x[1] == "ERROR" } )
If nPos > 0
	msgStop(STR0156 + " "+aRet[nPos][2] )
Else
	lRet := .T.
Endif

Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RespAut510 ºAutor  ³Vendas CRM          º Data ³19/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza ECM quando tiver aprovacao automatica por limite  º±±
±±º          ³de tempo atingido.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1: codigo do chamado                                   º±±
±±º          ³ExpC2: item do chamado                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function RespAut510(cChamado,cItemCh)

Local cObsSKW 	:= ''
Local cObs		:= ''
Local cStaItemWF 	:= ''
Local cCodOco		:= ''
Local lTK510WFRE	:= ExistBlock("TK510WFRE")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o workflow esta aprovado (avalia multiaprovacao).            ³
	//³Internamente, se a qtde de aprovadores/reprovadores for atingida,        ³
	//³atualiza os outros com o tipo automatico e atualiza no ECM.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cStaItemWF := GetStaWF(cChamado, cItemCh, &cObsSKW)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza item do chamado com o status do workflow                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WFAtuStADF(cChamado, cItemCh, cStaItemWF)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica status geral do chamado. Se o chamado possui algum workflow pendente ainda      ³
	//³Internamente a funcao ve qual o codigo do chamado (mestre) e entao busca o status        ³
	//³de todos os wf daquele chamado                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cStaADEWF := GetStaGeral(cChamado)


	If cStaADEWF == '3'
		cObs := STR0042 + CRLF //"Chamado Aprovado"
		cCodOco := "TMK004"
	ElseIf  cStaADEWF == '4'
		cObs := STR0043 + CRLF //"Chamado Reprovado"
		cCodOco := "TMK005"
	EndIf

	If cStaADEWF $ '34'

		cObs +=  cObsSKW
		TkUpdCall(	/*cFil*/,;
					""/*cCodAction*/,;
					/*cCodReview*/,;
					cObs,;
					/*cTPACAO*/,;
					TkOperador(),;
					Posicione("SU7", 1, xFilial("SU7")+TkOperador(), "U7_POSTO"),;
					"",;
					/*dPrazo*/,;
					If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ),;
					cChamado,;
					cCodOco)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza status geral do chamado        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WFAtuStADE(cChamado, cStaADEWF)


	If lTK510WFRE
		ExecBlock("TK510WFRE", .F., .F., {cChamado, SKW->KW_CODIGO})
	EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUNCAO	 ³TK510CONT     ºAutor  ³ Vendas CRM      º Data ³  16/04/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a alteracao do campo referente ao contador de      º±±
±±º		     ³ chamados associados ao chamado pai.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510CONT(cChPai,cFilChan)

Local aArea			:= GetArea()							//Armazena a ultima area utilizada
Local aAreaADE		:= ADE->(GetArea())                    //Armazena area ADE
Local cQuery		:= ""									//Query para Count de chamados associados
Local cAlias		:= GetNextAlias()		   				//Alias para a Query
Local lQtAss		:= .F.									//Informa a existencia do campo ADE_QTASS
Local lFilChan		:= .F.					   				//Informa a existencia do campo ADE_FLCHAN
Local aFiliais		:= Tk510Filiais()		 				//Array com as filiais da Empresa
Local nCountFor		:= 0                      				//Contador utilizado no FOR

Default cFilChan	:= xFilial("ADE")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query para realizar o Count de chamados associados   	  ³
//³Nao foi utilizado filtro por filial devido a possibilidade ³
//³de conter chamados associados em outra filial      		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery += " SELECT COUNT(ADE_CODIGO) ASSOC "
cQuery += " FROM " + RetSqlName("ADE") + " ADE "
cQuery += " WHERE ADE.ADE_CHANEX = '" + cChPai + "' "
cQuery += " AND ADE.D_E_L_E_T_ = ' ' "

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

dbSelectArea("ADE")
dbSetOrder(1)//ADE_FILIAL+ADE_CODIGO

For nCountFor:=1 to Len(aFiliais)

	If !Empty(cFilChan) .AND.(aFiliais[nCountFor] <> cFilChan)
		Loop
	EndIf

	If ADE->(dbSeek(aFiliais[nCountFor]+cChPai))

			Begin Transaction

				RecLock("ADE", .F.)

				ADE->ADE_QTASS := (cAlias)->ASSOC

				ADE->(MsUnlock())

			End Transaction

			Exit

	EndIf

Next nCountFor

(cAlias)->(DbCloseArea())

RestArea(aAreaADE)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUNCAO	 ³TK510CPSK5    ºAutor  ³ Vendas CRM      º Data ³  17/04/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a verificacao do chamado principal, informando     º±±
±±º		     ³se o chamado filho deve assumir o vencimento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ .T. - Chamado filho deve assumir data/hora chamado pai     º±±
±±º		     ³ .F. - Chamado filho permanece com sua data/hora            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK510CPSK5(cChamado,cChPai,cFilPai,cFilSK5,lRTPRZ,aFilhos)

Local aArea				:= GetArea()					//Armazena a ultima area utilizada
Local aAraSK5			:= SK5->( GetArea() )          //Armazena area SK5
Local dAbFilho			:= ADE->ADE_DATA               //Data de abertura do chamado filho
Local dDataPai			:= CToD("")                    //Data vencimento chamado pai
Local cHoraPai			:= ""							//Hora vencimento chamado pai
Local lRet				:= .T.                         //Retorno da funcao
Local cQuery			:= ""                          //Query dados do chamado
Local cAlias			:= GetNextAlias()			   //Alias para query chamado filho
Local cFilAvo			:= ""                          //Filial do chamado que o pai esta associado
Local nCountFor			:=0                            //Contador do For

Default	 cFilPai		:= xFilial("ADE")
Default	 cFilSK5		:= cFilPai
Default lRTPRZ			:= .F.							//Indica que nao deve ser chamado recursivamente
Default aFilhos			:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento parametros vazio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cFilPai)
	cFilPai:= cFilAnt
	cFilSK5:= cFilPai
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento pai associado a outro chamado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aFilhos)>0

	cFilAvo:= cFilPai

	For nCountFor:=1 to Len(aFilhos)

		If aFilhos[nCountFor][2] == AllTrim(cChPai)
			cFilPai:= aFilhos[nCountFor][1]
			Exit
		EndIf

	Next nCountFor

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o chamado filho esteja encerrado, nao altera o vencimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ADE->ADE_STATUS == "3"
	lRet := .F.
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca pelo registro do chamado pai ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery:="SELECT ADE_STATUS STATUSPAI,ADE_REGSLA REGSLAPAI, ADE_CHANEX CHANEX "
	cQuery+="FROM " + RetSQLName("ADE") + " ADE "
	cQuery+="WHERE ADE.ADE_FILIAL = '" + cFilPai + "' "
	cQuery+=	" AND ADE.ADE_CODIGO = '" + cChPai + "' "
	cQuery+=	" AND ADE.D_E_L_E_T_ = ' ' "

	cQuery	:= ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

	If (cAlias)->( !EOF() ) .AND. !lRTPRZ .AND. !Empty( (cAlias)->CHANEX )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso o chamado pai esteja associado a outro   ³
		//³chamado, realiza a chamada recursiva da funcao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet:= TK510CPSK5(cChamado,(cAlias)->CHANEX,cFilAvo,cFilSK5)

	Else

		If (cAlias)->( !EOF() )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso o chamado pai esteja encerrado, nao altera o vencimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim( (cAlias)->STATUSPAI ) == "3"
			    lRet:= .F.
			Else

				dbSelectArea("SK5")
				dbSetOrder(1)
				If dbSeek( cFilSK5+(cAlias)->REGSLAPAI )
					dDataPai := SK5->K5_DTEXPIR
					cHoraPai := SK5->K5_HREXPIR
				Else
					lRet := .F.
				EndIf

			EndIf

		Else

			lRet:= .F.

		EndIf

		If lRet

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O chamado filho deve manter seu vencimento caso:³
			//³1) O chamado pai tenha sua data/hora inferior   ³
			//³a data de abertura do chamado filho             ³
			//³2) O chamado pai esteja vencido                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (dDataPai < dAbFilho) .OR. (dDataPai < dDatabase) .OR. (dDataPai == dDatabase .AND. cHoraPai < Time())
				lRet := .F.
			EndIf

		EndIf

	EndIf

	(cAlias)->(dbCloseArea())

EndIF

RestArea(aAraSK5)

RestArea(aArea)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUNCAO	 ³TK510RTPRZ    ºAutor  ³ Vendas CRM      º Data ³  17/04/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a restauracao do prazo do chamado filho sem        º±±
±±º		     ³ dessasocia-lo do chamado pai.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK510RTPRZ(cFilPai)

Local aArea				:= GetArea()					//Armazena a ultima area utilizada
Local aAreaSK5			:= SK5->( GetArea() )          //Armazena area SK5
Local aAreaADE			:= ADE->(GetArea())            //Armazena area ADE
Local cChPai			:= ADE->ADE_CHANEX             //Chamado pai
Local lVctoPai			:= .F.                         //Informa se o chamado deve utilizar o vencimento do chamado pai
Local nCountFor			:= 0                           //Contador do For
Local cQuery			:= ""                          //Query busca dados do chamado pai
Local cAlias			:= GetNextAlias()             //Alias para Query
Local aFilhos			:= {}                         //Array com os filhos do chamado
Local aRet				:= {}                         //Array de retorno

dbSelectArea("SK5")
dbSetOrder(1) //K5_FILIAL+K5_CODIGO+K5_ITEM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca pelo registro do chamado pai ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery:="SELECT ADE_REGSLA REGSLA, ADE_CHANEX CHANEX, ADE_FLCHAN FLCHAN "
cQuery+="FROM " + RetSQLName("ADE") + " ADE "
cQuery+="WHERE ADE.ADE_FILIAL = '" + cFilPai + "' "
cQuery+=		" AND ADE.ADE_CODIGO = '" + cChPai + "' "
cQuery+=		" AND ADE.D_E_L_E_T_ = ' ' "

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

If (cAlias)->( !EOF() ) .AND. !Empty((cAlias)->CHANEX)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza o tratamento caso o chamado pai esteja associado a outro   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty((cAlias)->FLCHAN)
		aFilhos := Tk510ChFilho((cAlias)->CHANEX,(cAlias)->FLCHAN)
    Else
    	aFilhos := Tk510ChFilho((cAlias)->CHANEX,xFilial("ADE"))
    EndIf

	If Len(aFilhos)>0

		For nCountFor:=1 to Len(aFilhos)

			If aFilhos[nCountFor][2] == AllTrim(cChPai)
				cFilPai:= aFilhos[nCountFor][1]
				Exit
			EndIf

		Next nCountFor

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Compara com o chamado que o pai esta associado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lVctoPai := TK510CPSK5(ADE->ADE_CODIGO,cChPai,cFilPai,,.T.)

	EndIf

EndIf

If lVctoPai
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna o vencimento e severidade do chamado pai ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SK5->(dbSeek(cFilPai+(cAlias)->REGSLA))

		Aadd(aRet,SK5->K5_DTEXPIR)
		Aadd(aRet,SK5->K5_HREXPIR)
		If TK510NewFields()
			Aadd(aRet,SK5->K5_SEVE)
		Else
			Aadd(aRet,SK5->K5_SEVERID)
		EndIf

	EndIf

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna o vencimento e severidade do chamado filho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SK5->(dbSeek(xFilial("SK5")+ADE->ADE_REGSLA))

		Aadd(aRet,SK5->K5_DTEXPIR)
		Aadd(aRet,SK5->K5_HREXPIR)
		If TK510NewFields()
			Aadd(aRet,SK5->K5_SEVE)
		Else
			Aadd(aRet,SK5->K5_SEVERID)
		EndIf

	EndIf

EndIf

(cAlias)->(dbCloseArea())
RestArea(aAreaSK5)
RestArea(aAreaADE)
RestArea(aArea)

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUNCAO	 ³TK510SLAAT    ºAutor  ³ Vendas CRM      º Data ³  17/04/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a restauracao do registro de SLA original do       º±±
±±º		     ³ chamado para adequar ao novo modelo de controle de SLA.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK510SLAAT()

Local aArea				:= GetArea()					//Armazena a ultima area utilizada
Local aAreaSK5			:= SK5->( GetArea() )          //Armazena area SK5
Local aAreaADE			:= ADE->(GetArea())            //Armazena area ADE
Local cFilChamado		:= xFilial("ADE")              //Filial do chamado
Local cChamado			:= ADE->ADE_CODIGO             //Codigo do Chamado

dbSelectArea("SK5")
dbSetOrder(1)

If dbSeek(xFilial("SK5")+ADE->ADE_SLAANT)
	dbSelectArea("ADE")
	dbSetOrder(1)
	If dbSeek(cFilChamado+cChamado)

		Begin Transaction

			RecLock("ADE", .F.)

			ADE->ADE_SLAANT := ""
			ADE->ADE_FLSLAN := cFilAnt
			ADE->ADE_REGSLA	:= SK5->K5_CODIGO
			ADE->ADE_DTEXPI := SK5->K5_DTEXPIR

			If TK510NewFields()
				ADE->ADE_SESLA	:= SK5->K5_SEVE
			Else
				ADE->ADE_SEVSLA	:= SK5->K5_SEVERID
			EndIf

			ADE->ADE_HREXPI	:= SK5->K5_HREXPIR
			ADE->(MsUnlock())

		End Transaction

	EndIf
EndIf

RestArea(aAreaADE)
RestArea(aAreaSK5)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUNCAO	 ³Tk510Vecto    ºAutor  ³ Vendas CRM      º Data ³  17/04/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para tratamento do prazo de SLA caso o chamado      º±±
±±º		     ³ filho esteja alterando seu SLA.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510Vecto(cFilChamado, cChamado)

Local aArea			:= GetArea()								//Armazena a ultima area utilizada
Local aAreaSK5		:= SK5->( GetArea() )        		   		//Armazena area SK5
Local aAreaADE		:= ADE->( GetArea() )        		   		//Armazena area ADE
Local cChPai		:= ADE->ADE_CHANEX             		  		//Codigo chamado pai
Local cSLACh		:= ADE->ADE_REGSLA             		  		//Registo SK5 de SLA
Local cFilPai		:= ""                          		  		//Filial chamado pai
Local cFilAvo		:= ""						   		  		//Filial do chamado ao qual o chamado pai esta associado
Local cChVecto		:= ""                          		  		//Codigo do chamado com o vencimento correto
Local cFilVecto		:= ""                          		  		//Filial do chamado com o vencimento correto
Local cRegSLAVecto	:= ""                          				//Registo SK5 de SLA correto
Local cQuery		:= ""                          				//Query para buscar dados chamado pai
Local cAlias		:= GetNextAlias()                      		//Alias para a Query
Local lFlChan		:= .F.                                 		//Informa existencia e preenchimento campo ADE_FLCHAN

lFlChan := Iif ( !Empty(ADE->ADE_FLCHAN), .T. , .F. )

If lFlChan
	cFilPai := ADE->ADE_FLCHAN
Else
	cFilPai := xFilial("ADE")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca pelo registro do chamado pai ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery:= "SELECT ADE_REGSLA SLAPAI, ADE_CHANEX CHANEX "
If lFlChan
	cQuery+=", ADE_FLCHAN FLCHAN "
EndIf
cQuery+= "FROM " + RetSQLName("ADE") + " ADE "
cQuery+= "WHERE ADE.ADE_FILIAL = '" + cFilPai + "' "
cQuery+= 		" AND ADE.ADE_CODIGO = '" + cChPai + "' "
cQuery+= 		" AND ADE.D_E_L_E_T_ = ' ' "

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

If (cAlias)->( !EOF() )

	If ( !Empty( (cAlias)->CHANEX ) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso o chamado pai esteja associado a outro chamado                    ³
		//³Verifica se o chamado pai esta utilizando o vencimento do outro chamado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFilAvo:= Iif(lFlChan,(cAlias)->FLCHAN, xFilial("ADE") )

		If TK510CPSK5(cChPai,(cAlias)->CHANEX,cFilAvo)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o chamado filho esta utilizando o vencimento do outro chamado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TK510CPSK5(cChamado,(cAlias)->CHANEX,cFilAvo)
				cChVecto := (cAlias)->CHANEX
				cFilVecto := cFilAvo
				cRegSLAVecto:= Posicione("ADE",1,cFilVecto+cChVecto,"ADE_REGSLA")
		    Else
		    	cChVecto := cChamado
            	cFilVecto :=cFilChamado
            	cRegSLAVecto := cSLACh
		    EndIf

		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o chamado filho esta utilizando o vencimento do pai³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TK510CPSK5(cChamado,cChPai,cFilPai,,.T.)
				cChVecto := cChPai
				cFilVecto := cFilPai
    			cRegSLAVecto := (cAlias)->SLAPAI
    		Else
    			cChVecto := cChamado
            	cFilVecto :=cFilChamado
            	cRegSLAVecto := cSLACh

            EndIF

        EndIf

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o chamado filho esta utilizando o vencimento do pai³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TK510CPSK5(cChamado,cChPai,cFilPai)
			cChVecto := cChPai
			cFilVecto := cFilPai
   			cRegSLAVecto := (cAlias)->SLAPAI
    		Else
    			cChVecto := cChamado
            	cFilVecto :=cFilChamado
            	cRegSLAVecto := cSLACh
            EndIF

	EndIf

EndIf

If !Empty(cChVecto) .AND. !Empty(cFilVecto) .AND. !Empty(cRegSLAVecto)
	dbSelectArea("SK5")
	dbSetOrder(1)
	If dbSeek(cFilVecto+cRegSLAVecto)
		dbSelectArea("ADE")
		dbSetOrder(1)
		If dbSeek(cFilChamado+cChamado)
			Begin Transaction

 				RecLock("ADE", .F.)
	    		ADE->ADE_DTEXPI := SK5->K5_DTEXPIR
				ADE->ADE_HREXPI	:= SK5->K5_HREXPIR
				If TK510NewFields()
					ADE->ADE_SESLA	:= SK5->K5_SEVE
				Else
					ADE->ADE_SEVSLA := SK5->K5_SEVERID
				EndIf

				ADE->(MsUnlock())

			End Transaction

		EndIF
	EndIf

EndIf

(cAlias)->(dbCloseArea())

RestArea(aAreaADE)
RestArea(aAreaSK5)
RestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Tk510AcTms³ Autor ³Marcelo Coutinho       ³ Data ³13.04.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se executa as funções do TMS.                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet:                                                       ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510AcTms(cTipo)

Local nPosITEM := aScan(aHeader, {|x| AllTrim(x[2]) == "ADF_ITEM"  }) //Posicao do campo na tabela
Local cItem    := aCols[n][nPosItem] //Item do Grid
Local lRet     := .T.          //Controle de Retorno
Local nN       := n            //Posiçao do Browse original

nModulo := 43 //Código do Módulo TMS (Transportation Management System)
n       := 1

If cTipo == "01" //Tracking

	If !Empty(M->ADE_CHAVE)
		TMSC020( SubStr(M->ADE_CHAVE,1,TamSx3("DT6_CLIREM")[1]), SubStr(M->ADE_CHAVE,(TamSx3("DT6_CLIREM")[1]+1),TamSx3("DT6_LOJREM")[1]))
		lRet := .T.
	Else
		Help("",1,"TMKA51001") //(P)Não foi possível encontrar o Cliente para efetuar o filtro dos registros de Tracking (posicionamento). //(S)Informe o Contato para localização do cliente!
      lRet := .F.
	EndIf
ElseIf cTipo $ "02/03/04/05/06" //Cotação de Frete

	If !Empty(M->ADE_CHAVE) .And. !Empty(M->ADE_DDDRET) .And. !Empty(M->ADE_TELRET)

		If cTipo == "02" //Inclusão
			If DT4->DT4_NUMATD <> M->ADE_CODIGO
				lRet := (TMSA040Mnt( "DT4", 0, 3,,,,, .T., M->ADE_DDDRET, M->ADE_TELRET, M->ADE_CODIGO, cItem, M->ADE_CODSB1, M->ADE_NMPROD)>0)
			Else
				Help("",1,"TMKA51002") //(P)Já existe Cotação de Frete para o atendimento em execução. /(S)Para efetuar outra Cotação de Frete, deve-se iniciar um novo atendimento!
      		lRet := .F.
			EndIf
     	ElseIf cTipo == "06" //Histórico
			TMSA040(,,, M->ADE_DDDRET, M->ADE_TELRET)
			lRet := .T.

		Else
			DT4->(DbSetOrder(8))
			If DT4->(DbSeek(xFilial("DT4")+M->ADE_CODIGO))
			   If     cTipo == "03" //Alteração
					lRet := (TMSA040Mnt( "DT4", DT4->( RECNO() ), 4,,,,, .T., M->ADE_DDDRET, M->ADE_TELRET, M->ADE_CODIGO, cItem)>0)

   		   ElseIf cTipo == "04" //Cancelamento
					lRet := (TMSA040Mnt( "DT4", DT4->( RECNO() ), 5,,,,, .T., M->ADE_DDDRET, M->ADE_TELRET, M->ADE_CODIGO, cItem)>0)

      		ElseIf cTipo == "05" //Confirmação
					lRet := (TMSA040Mnt( "DT4", DT4->( RECNO() ), 6,,,,, .T., M->ADE_DDDRET, M->ADE_TELRET, M->ADE_CODIGO, cItem)>0)

				EndIf
			Else
				Help("",1,"TMKA51003") //(P)Não há Cotação de Frete vinculada ao atendimento! /(S)Para efetuar as ações de alteração, cancelamento ou confirmação, é necessário que haja uma Cotação de Frete para o atendimento. Insira uma Cotação de Frete!
		      lRet := .F.
			EndIf
		EndIf
	Else
		Help("",1,"TMKA51004") //(P)Não foi possível encontrar o Cliente para efetuar a Cotação de Frete. //(S)Informe o Contato, DDD e Telefone para localização do cliente!
      lRet := .F.
	EndIf
ElseIf cTipo $ "07/08/09/10/11" //Solicitação de Coleta

	If !Empty(M->ADE_DDDRET) .And. !Empty(M->ADE_TELRET)

		If cTipo == "07" //Inclusão
			If DT5->DT5_NUMATD <> M->ADE_CODIGO
				lRet := TMSA460Mnt( "DT5", 0, 3, M->ADE_DDDRET, M->ADE_TELRET, M->ADE_CODIGO, cItem)
			Else
				Help("",1,"TMKA51005") //(P)Já existe Solicitação de Coleta para o atendimento em execução. /(S)Para efetuar outra Solicitação de Coleta, deve-se iniciar um novo atendimento!
      		lRet := .F.
			EndIf

		ElseIf cTipo == "11" //Histórico
			TMSA460(,,,,,M->ADE_DDDRET,M->ADE_TELRET)
			lRet := .T.

		Else
			DT5->(DbSetOrder(6))
			If DT5->(DbSeek(xFilial("DT5")+M->ADE_CODIGO))
				If     cTipo == "08" //Alteração
					lRet := TMSA460Mnt( "DT5", DT5->( RECNO() ), 4, M->ADE_DDDRET, M->ADE_TELRET, M->ADE_CODIGO, cItem)

				ElseIf cTipo == "09" //Cancelamento/Exlusão
					lRet := TMSA460Mnt( "DT5", DT5->( RECNO() ), 5, M->ADE_DDDRET, M->ADE_TELRET, M->ADE_CODIGO, cItem)

				ElseIf cTipo == "10" //Confirmação/Liberação
					lRet := TMSA460Lib( "DT5", DT5->( RECNO() ), 6, M->ADE_DDDRET, M->ADE_TELRET, M->ADE_CODIGO, cItem)

				EndIf
			Else
				Help("",1,"TMKA51006") //(P)Não há Solicitação de Coleta vinculada ao atendimento! /(S)Para efetuar as ações de alteração, cancelamento ou confirmação, é necessário que haja uma Solicitação de Coleta para o atendimento. Insira uma Solicitação de Coleta!
		      lRet := .F.
			EndIf
		EndIf
	Else
		Help("",1,"TMKA51007")  //(P)Não foi possível encontrar o Cliente para efetuar a Cotação de Frete. //(S)Informe o Contato, DDD e Telefone para localização do cliente!
      lRet := .F.
	EndIf
EndIf

nModulo := 13  //Código do Módulo TMK (Telemarketing)
n       := nN  //Posição do Browse original

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ExecSchedule³ Autor ³ Aldo Barbosa dos Santos      ³01/07/11³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna se o programa esta sendo executado via schedule     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ExecSchedule()  // funcao utilizada para testes de rotinas automaticas
Local lRetorno := .T.

lRetorno := IsBlind()

Return( lRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUNCAO	 ³ Tk510Error   ºAutor  ³ Vendas CRM      º Data ³  10/06/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para tratamento de erro.						      º±±
±±º		     ³ 									                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510Error(e)

Local cMsg := ""

cMsg := Replicate("*",40) + CRLF
cMsg += STR0249 + " ....: "   + Iif(type("ADE->ADE_FILIAL")=="C",ADE->ADE_FILIAL,"") + CRLF 	//"FILIAL"
cMsg += STR0250 + " ...: " 	  + Iif(Type("ADE->ADE_CODIGO")=="C",ADE->ADE_CODIGO,"") + CRLF   	//"CHAMADO"
cMsg += STR0251 + ": " 		  + GetEnvServer() + CRLF											//"ENVIRONMENT"
cMsg += STR0252 + " ...: " 	  + GETSERVERIP() + CRLF											//"IP SERV"
cMsg += STR0253 + " ......: " + GetPvProfString("TCP","PORT","7000",GetAdv97()) + CRLF			//"PORT"
cMsg += STR0254 + " ....: "   + AllTrim(Str(ThreadID())) + CRLF									//"THREAD"
cMsg += STR0255 + " ...: " 	  + cUserName + CRLF												//"USUARIO"
cMsg += Replicate("*",40) + CRLF

ConOut(cMsg + e:ErrorStack )

If InTransact()
	DisarmTransaction()
	If !IsBlind()
		Alert(e:ErrorStack)
		Final(STR0256)	//"Ocorreu algum problema. Contate o administrador do sistema."
	Else
		__Quit()
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUNCAO	 ³ Tk510MacroMailºAutor ³ Vendas CRM      º Data ³  23/02/18  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para Macro executar campos de WorkFlow    	      º±±
±±º		     ³ 									                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA510                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk510MacroMail(cCodWFTemplate,cEmail,cEmailCc,cEmailCco)

Default cCodWFTemplate	:= ""
Default cEmail			:= ""
Default cEmailCc		:= ""
Default cEmailCco		:= ""

SKY->(DBSetOrder(1))
If SKY->(MsSeek(xFilial("SKY")+cCodWFTemplate))
	If !Empty(AllTrim(SKY->KY_TO))
		cEmail := AllTrim(&(AllTrim(SKY->KY_TO)))     + "; "
	EndIf
	If !Empty(AllTrim(SKY->KY_CC))
		cEmailCc := AllTrim(&(AllTrim(SKY->KY_CC)))   + "; "
	EndIf
	If !Empty(AllTrim(SKY->KY_CCO))
		cEmailCco := AllTrim(&(AllTrim(SKY->KY_CCO))) + "; "
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/ {Protheus.doc} Tk510TAxEn

Funcao que verifica se o registro da entidade informada foi utilizada
em algum Teleatendimento (Tabela ADE) e pode ser excluido.

@sample	Tk510TAxEn(cEntidade, cFilEntida, cChaveEnt, @cMsgErro)

@param		cEntidade Entidade do registro a ser verificada
@param      cFilEntida Filial do registro da entidade a ser verificada
@param      cChaveEnt Chave de identificacao da entidade a ser
			verificada

@return     lPodeExclu Indica se pode ser excluido ou o registro
            avaliado

@author     Rafael Mota Previdi
@since		25/06/2019
@version	P12
/*/
//-------------------------------------------------------------------

Function Tk510TAxEn(cEntidade, cFilEntida, cChaveEnt)

	Local lPodeExclu   := .T.
	Local cAliasQry    := ""
	Local aArea        := GetArea()

	Default cEntidade  := ""
	Default cFilEntida := ""
	Default cChaveEnt  := ""

	cAliasQry  := GetNextAlias()
	BeginSQL Alias cAliasQry
		SELECT
			AC8.AC8_CODENT
		FROM
			%table:AC8% AC8
		WHERE
			AC8.AC8_FILIAL = %xfilial:AC8%
				AND
			AC8.AC8_ENTIDA = %exp:cEntidade%
				AND
			AC8.AC8_FILENT = %exp:cFilEntida%
				AND
			AC8.AC8_CODENT = %exp:cChaveEnt%
				AND
			EXISTS(
					SELECT
						ADE.ADE_CHAVE
					FROM
						%table:ADE% ADE
					WHERE
						ADE.ADE_FILIAL = %xfilial:ADE%
							AND
						ADE.ADE_CODCON = AC8.AC8_CODCON
							AND
						ADE.ADE_ENTIDA = AC8.AC8_ENTIDA
							AND
						ADE.ADE_CHAVE = AC8.AC8_CODENT
							AND
						ADE.%NotDel%
					)
				AND
			AC8.%NotDel%
	EndSQL

	If !(lPodeExclu := (cAliasQry)->(EOF()))
		Help(" ",1,"TMKNDELREL")
	EndIf
	(cAliasQry)->(DbCloseArea())

	RestArea(aArea)
	aSize(aArea, 0)

Return( lPodeExclu )

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive
