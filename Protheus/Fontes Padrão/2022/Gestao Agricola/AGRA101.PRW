#INCLUDE "AGRA101.ch"
#include 'protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGRA101  º Autor ³ Ricardo Tomasi     º Data ³  09/08/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para Transferencia de NFS entre Compromissos Futurosº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Clientes Microsga                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AGRA101()
	Local cQuery   := ''
	Local aCpos    := Array(0)
	Local aCampos  := Array(0)
	Local nX       := 0
	Local aStruSD2 := SD2->(dbStruct())

	Private cPerg      := 'AGRAA1'
	Private cMarca     := GetMark()
	Private cUMDesti   := ''
	Private cCadastro  := STR0001 //"Alt. Comp. Futuro"
	Private aRotina    := {;
	{ "Tranferir" ,"AGRA101A" ,0,2} ;
	}
	Private nTtMarcado := 0

	If .Not. Pergunte(cPerg,.T.)
		Return()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definição das colunas a serem mostradas no browser.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aCampos, 'D2_NUMCP'  ); aAdd(aCampos, 'D2_SERIE'  ); aAdd(aCampos, 'D2_DOC'   )
	aAdd(aCampos, 'D2_EMISSAO'); aAdd(aCampos, 'D2_CLIENTE'); aAdd(aCampos, 'D2_LOJA'  )
	aAdd(aCampos, 'D2_COD'    ); aAdd(aCampos, 'D2_UM'     ); aAdd(aCampos, 'D2_QUANT' )
	aAdd(aCampos, 'D2_PRCVEN' ); aAdd(aCampos, 'D2_TOTAL'  ); aAdd(aCampos, 'D2_CODROM')

	//Ajuste SONARQUBE
	Aadd(aCpos,{'D2_OK','',' '})
	For nX := 1 To Len(aStruSD2)
		If aStruSD2[nX,1] != 'D2_OK'
			AAdd(aCpos,{aStruSD2[nX,1],' ',Trim(RetTitle(aStruSD2[nX,1])),PesqPict("SD2",aStruSD2[nX,1])})
		EndIf
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra tabela para listagem de contratos.                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SD2')
	cQuery := "D2_FILIAL=='"+xFilial('SD2') +"'"
	cQuery += " .And. D2_SERIE>='"          +MV_PAR01      +"' .And. D2_SERIE<='"          +MV_PAR02      +"'"
	cQuery += " .And. D2_DOC>='"            +MV_PAR03      +"' .And. D2_DOC<='"            +MV_PAR04      +"'"
	cQuery += " .And. DToS(D2_EMISSAO)>='"  +DToS(MV_PAR05)+"' .And. DTos(D2_EMISSAO)<='"  +DTos(MV_PAR06)+"'"
	cQuery += " .And. D2_NUMCP>='"          +MV_PAR07      +"' .And. D2_NUMCP<='"          +MV_PAR08      +"'"
	IndRegua('SD2',CriaTrab(NIL,.F.),'D2_FILIAL+D2_SERIE+D2_DOC',,cQuery,"Selecionando Registros ...")

	MarkBrowse('SD2','D2_OK',,aCpos,,cMarca,,,,,'AGRA101B()')

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGRA101A º Autor ³ Ricardo Tomasi     º Data ³  09/08/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para inclusão de Compromisso Futuro.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Clientes Microsga                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AGRA101A()
	Local cNumCPAnt := ''
	Local cNumCPNov := MV_PAR09

	If .Not. ApMsgYesNo("Tem certesa que deseja tranferir os itens para um novo compromisso ("+cNumCPNov+")?","Tranferencia de Compromisso Futuro")
		Return()
	EndIf

	dbSelectArea('SD2')
	dbGotop()
	While .Not. Eof()
		If SD2->D2_OK == cMarca
			dbSelectArea('NO1')
			dbSetOrder(1)
			cNumCPAnt := SD2->D2_NUMCP

			//Altera Saldo a Entregar (+) no Compromisso de Origem
			If .Not. Empty(cNumCPAnt)
				If dbSeek(xFilial('NO1')+cNumCPAnt)
					RecLock('NO1',.f.)
					NO1->NO1_SALDO += AGRX001(SD2->D2_UM,NO1->NO1_UM1PRO,SD2->D2_QUANT)
					MsUnLock()
				EndIf
			EndIf

			//Altera Saldo a Entregar (-) no Compromisso de Destino
			If .Not. Empty(cNumCPNov)
				If dbSeek(xFilial('NO1')+cNumCPNov)
					RecLock('NO1',.f.)
					NO1->NO1_SALDO -= AGRX001(SD2->D2_UM,NO1->NO1_UM1PRO,SD2->D2_QUANT)
					MsUnLock()
				EndIf
			EndIf

			RecLock('SD2',.F.)
			SD2->D2_OK    := '  '
			SD2->D2_NUMCP := cNumCPNov
			MsUnLock()
		EndIf
		dbSelectArea('SD2')
		dbSkip()
	EndDo

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGRA101B º Autor ³ Ricardo Tomasi     º Data ³  09/08/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para inclusão de Compromisso Futuro.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Clientes Microsga                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AGRA101B()
	Local aAreaAnt := GetArea()
	Local lPerOrig := .f.
	Local lPerDest := .f.
	Local nQtMarca := 0

	If SD2->D2_OK <> cMarca //Marcar

		//Validar se o CP Destino tem saldo...
		If .Not. Empty(MV_PAR09)
			dbSelectArea('NO1')
			dbSetOrder(1)
			dbSeek(xFilial('NO1')+MV_PAR09)
			If NO1->NO1_FCHFAT <> 'S'
				If NO1->NO1_CODCLI+NO1->NO1_LOJCLI==SD2->D2_CLIENTE+SD2->D2_LOJA
					NN1->(dbSeek(xFilial('NN1')+NO1->NO1_SAFRA))
					If NO1->NO1_CODPRO==NN1->NN1_CODPRO
						nQtMarca := AGRX001(SD2->D2_UM,NO1->NO1_UM1PRO,SD2->D2_QUANT)
						If NO1->NO1_SALDO >= (nTtMarcado+nQtMarca)
							lPerDest := .t.
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			lPerDest := .t.
		EndIf

		//Validar se o CP Origem não esta fechado...
		If .Not. Empty(SD2->D2_NUMCP)
			dbSelectArea('NO1')
			dbSetOrder(1)
			dbSeek(xFilial('NO1')+SD2->D2_NUMCP)
			If NO1->NO1_FCHFAT <> 'S'
				lPerOrig := .t.
			EndIf
		Else
			lPerOrig := .t.
		EndIf

		If lPerOrig .And. lPerDest
			If .Not. Empty(MV_PAR09)
				nTtMarcado += nQtMarca
			EndIf
			RecLock('SD2',.f.)
			SD2->D2_OK := cMarca
			MsUnLock()
		EndIf

	Else //Desmarcar

		If .Not. Empty(MV_PAR09)
			dbSelectArea('NO1')
			dbSetOrder(1)
			dbSeek(xFilial('NO1')+MV_PAR09)
			nTtMarcado -= AGRX001(SD2->D2_UM,NO1->NO1_UM1PRO,SD2->D2_QUANT)
		EndIf
		RecLock('SD2',.f.)
		SD2->D2_OK := '  '
		MsUnLock()

	EndIf

	RestArea(aAreaAnt)
Return()