#include "pmspalmc.ch"
#include "eadvpl.ch"
#include "_pmspalm.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³VldAFFSaveºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ valida e salva a confirmacao no AFF                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aAFFItem - confirmacao a ser validada e salva              º±±
±±º          ³ nQtd     - quantidade a ser validada                       º±±
±±º          ³ aItems   - array de confirmacoes para ser exibido no browseº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldAFFSave(aAFFItem, nQtd, aItems)
	Local lReturn := .F.
	Local nAF9Quant := AF9GetQuant(aAFFItem[SUB_AFF_FILIAL] + aAFFItem[SUB_AFF_PROJET];
	                             + aAFFItem[SUB_AFF_REVISA] + aAFFItem[SUB_AFF_TAREFA])

	If aAFFItem[SUB_AFF_FILIAL] == Nil .Or.;
	   aAFFItem[SUB_AFF_PROJET] == Nil .Or.;
	   aAFFItem[SUB_AFF_REVISA] == Nil .Or.;
	   aAFFItem[SUB_AFF_TAREFA] == Nil
		
		MsgAlert(STR0001) //"Selecione um projeto e uma tarefa para ser confirmada!"
		lReturn := .F.		
	Else
		If Empty(aAFFItem[SUB_AFF_FILIAL]) .Or.;
		   Empty(aAFFItem[SUB_AFF_PROJET]) .Or.;
		   Empty(aAFFItem[SUB_AFF_REVISA]) .Or.;
		   Empty(aAFFItem[SUB_AFF_TAREFA])
			MsgAlert(STR0001) //"Selecione um projeto e uma tarefa para ser confirmada!"
			lReturn := .F.
		Else
			If nQtd > nAF9Quant .Or. nQtd < 0.00
				If !lMsgInvQtd
					MsgAlert(STR0002, APP_NAME) //"Quantidade inválida!"
					lMsgInvQtd := .F.
				EndIf
				lReturn := .F.
			Else
				AFFSave(aAFFItem)
				AFFFill(@aItems)
		
				CloseDialog()
		
				lReturn := .T.
			EndIf
		EndIf
	EndIf
Return lReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DlgAFFViewºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ janela da visualizacao da confirmacao                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aItems   - contem as confirmacoes adicionadas              º±±
±±º          ³ nSelItem - confirmacao selecionada para ser visualizada    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DlgAFFView(aItems, nSelItem)
	Local oDlg         := Nil // janela principal
	Local oButtonClose := Nil
	Local oSayTaskDes  := Nil
	Local oChk         := Nil
	Local oChoose      := Nil

	Local aAFFItem     := Nil 
	Local lCheck       := .F.
		
	aAFFItem := AFFSeek(AFFGetKey(aItems, nSelItem))
	
	If aAFFItem[SUB_AFF_CONFIR] == AUT_ENTREGA_SIM
		lCheck := .T.
	Else
		lCheck := .F.
	EndIf

	If !Empty(aAFFItem)
		Define Dialog oDlg Title STR0003 //APP_NAME //"Visualização de Confirmação"
			//@ 20, 05 Say "Visualização de Confirmação" Bold Of oDlg

			@ 20, 05 Say STR0004       Of oDlg //"Projeto:"
			@ 20, 50 Say aAFFItem[SUB_AFF_PROJET] Of oDlg
			
			@ 34, 05 Say STR0005        Of oDlg //"Tarefa:"
			@ 34, 50 Say aAFFItem[SUB_AFF_TAREFA] Of oDlg

			@  48, 05 Say STR0006    Of oDlg		 //"Descrição:"
			@  48, 50 Say oSayTaskDes Prompt Space(30) Of oDlg
			SetText(oSayTaskDes, AllTrim(AF9ItemDesc(aAFFItem[SUB_AFF_FILIAL] + aAFFItem[SUB_AFF_PROJET] +;
			                                 aAFFItem[SUB_AFF_REVISA] + aAFFItem[SUB_AFF_TAREFA])))
	
			@ 64, 05 Button oChoose Caption STR0007 Action ShowDetails(aAFFItem) Size 50, 10 of oDlg		 //"Detalhes"
			//DisableControl(oChoose)
			
			@ 80, 05 To 00, 155 Of oDlg

			@ 84, 05 Say STR0008      Of oDlg //"Data Ref:"
			@ 84, 50 Say aAFFItem[SUB_AFF_DATA] Of oDlg
	
			@ 98, 05 Say STR0009       Of oDlg   //"% Exec.:"
			@ 98, 50 Say Transform(aAFFItem[SUB_AFF_PERC], "@E 999.99") Of oDlg
	
			@ 112, 05 Say STR0010    Of oDlg  // calculado //"Qtd Exec.:"
			@ 112, 50 Say Transform(aAFFItem[SUB_AFF_QUANT], "@E 999999.9999") Of oDlg

			@ 126, 03 CheckBox oChk Var lCheck Caption STR0011 Of oDlg  //"Gerar Autoriz. Entrega"
			SetText(oChk, lCheck)
			DisableControl(oChk)
			
			@ 140, 05 To 00, 155 Of oDlg
			
			@ 145, 05 Button oButtonClose Caption STR0012 Action CloseDialog() Size 35, 10 Of oDlg //"OK"
						
		Activate Dialog oDlg
	EndIf
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DlgAFFChanºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ valida e salva a confirmacao no AFF                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aItems   - confirmacao a ser validada e salva              º±±
±±º          ³ nSelItem - quantidade a ser validada                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DlgAFFChange(aItems, nSelItem)
	Local aAFFItem   := Nil  // informacoes da confirmacao
	Local cKey       := ""   // chave da confirmacao

	// objetos de interface
	Local oDlg        := Nil  // janela principal
	Local oBtnCalen   := Nil	 // botao - Calendario
	Local oBtnOk      := Nil  // botao - Ok
	Local oBtnCancel  := Nil  // botao = Cancel
	Local oChk        := Nil  // checkbox - "Gera AE"
	Local oGet1       := Nil  // get - "Quantidade Executada"
	Local oGet2       := Nil  // get - "% Executada"
	Local oSay        := Nil  // say - data escolhida
	Local oSayTaskDes := Nil
	Local oChoose     := Nil

	// variaveis temporarias
	Local nQtdExec    := 0    // quantidade executada
	Local nPerExec    := 0    // porcentagem executada
	Local lCheck      := .F.  // gera autorizacao de entrega
		
	aAFFItem := AFFSeek(AFFGetKey(aItems, nSelItem))

	nPerExec := aAFFItem[SUB_AFF_PERC]
	nQtdExec := aAFFItem[SUB_AFF_QUANT]

	If aAFFItem[SUB_AFF_CONFIR] == AUT_ENTREGA_SIM
		lCheck := .T.
	Else
		lCheck := .F.
	EndIf
	
	If !Empty(aAFFItem)
		cKey := AFFGetKey(aItems, nSelItem)		
	
		Define Dialog oDlg Title STR0013 //APP_NAME //"Alteração de Confirmação"
			
			@  20, 05 Say STR0004           Of oDlg //"Projeto:"
			@  20, 50 Say aAFFItem[SUB_AFF_PROJET] Of oDlg
			
			@  34, 05 Say STR0005            Of oDlg //"Tarefa:"
			@  34, 50 Say aAFFItem[SUB_AFF_TAREFA] Of oDlg

			@  48, 05 Say STR0006         Of oDlg		 //"Descrição:"
			@  48, 50 Say oSayTaskDes Prompt Space(30) Of oDlg
			SetText(oSayTaskDes, AllTrim(AF9ItemDesc(aAFFItem[SUB_AFF_FILIAL] + aAFFItem[SUB_AFF_PROJET] +;
			                                         aAFFItem[SUB_AFF_REVISA] + aAFFItem[SUB_AFF_TAREFA])))

			@  64, 05 Button oChoose Caption "Detalhes" Action ShowDetails(aAFFItem) Size 50, 10 of oDlg
			//DisableControl(oChoose)
				
			@  80, 05 To 00, 155 Of oDlg

			@  84, 05 Say STR0008                    Of oDlg //"Data Ref:"
			@  84, 50 Say oSay Prompt aAFFItem[SUB_AFF_DATA] Of oDlg

			@  98, 05 Say STR0009       Of oDlg   //"% Exec.:"
			@  98, 50 Get oGet2 Var nPerExec Picture "@E 999.99" Valid VldPer(@aAFFItem, Round(nPerExec, 4), oGet1) Of oDlg  

			@ 112, 05 Say STR0014     Of oDlg //"Qtd. Exec.:"
			@ 112, 50 Get oGet1 Var nQtdExec Picture "@E 999999.9999" Valid VldQtd(@aAFFItem, Round(nQtdExec, 2), oGet2) Of oDlg

			@ 126, 03 CheckBox oChk Var lCheck Caption STR0011 Action AFFSetAE(@aAFFItem, lCheck) Of oDlg //"Gerar Autoriz. Entrega"
			SetText(oChk, lCheck)
				
			@ 140, 05 To 00, 155 Of oDlg

			@ 145, 05 Button oBtnOk     Caption STR0012     Action AFFChangeWrite(cKey, aAFFItem, @aItems) Size 35, 10 Of oDlg //"OK"
			@ 145, 55 Button oBtnCancel Caption STR0015 Action CloseDialog() Size 45, 10 Of oDlg					 //"Cancel"
		Activate Dialog oDlg
	EndIf
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ChooseTaskºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ janela de escolha de tarefa                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aAFFItem - confirmacao a ser validada e salva              º±±
±±º          ³ oSayProj - objeto Say no qual sera mostrado o projeto      º±±
±±º          ³ oSayTask - objeto Say no qual sera mostrada a tarefa       º±±
±±º          ³ oSayTaskDes - objeto Say no qual sera mostrada a descricao º±±
±±º          ³            da tarefa                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ChooseTask(aAFFItem, oSayProj, oSayTask, oSayTaskDes)
	Local oDlg  := Nil // janela principal
	Local oMenu := Nil // menu
	
	// itens do menu
	Local oItem1 := Nil
	Local oItem2 := Nil
	Local oItem3 := Nil
	Local oItem4 := Nil
	Local oItem5 := Nil
	
	// browse
	Local oBrowse := Nil
	
	// coluna
	Local oCol    := Nil

	// arrays necessários para
	// utilização com o browse
	Local aHeader := {}	
	Local aTasks  := {}
	
	Local oBtnOk  := Nil
	Local oBtnCancel := Nil
	
	Define Dialog oDlg Title APP_NAME
		@ 20, 05 Say STR0016 Bold Of oDlg //"Tarefas"

		@ 40, 05 Say STR0017 Of oDlg //"Selecione a tarefa:"
		
		// carrega as tarefas que podem ser fazer confirmacao
		AF9FillConfir(@aTasks)

		aAdd(aHeader, "Filial")
		aAdd(aHeader, "Revisão")
		aAdd(aHeader, "Projeto")
		aAdd(aHeader, "Tarefa")
		aAdd(aHeader, "Descrição da Tarefa")
		aAdd(aHeader, "Quantidade")

		// mostra browse com as ocorrencias existentes	
		@ 55, 05 Browse oBrowse Size 150, 75 On Click BrowseClick(oDlg, oBrowse, aTasks) Of oDlg
		Set Browse oBrowse Array aTasks
		Add Column oCol To oBrowse Array Element SUB_AF9_FILIAL Header aHeader[1] Width  20
		Add Column oCol To oBrowse Array Element SUB_AF9_PROJET Header aHeader[3] Width  50
		Add Column oCol To oBrowse Array Element SUB_AF9_TAREFA Header aHeader[4] Width  50
		Add Column oCol To oBrowse Array Element SUB_AF9_DESCRI Header aHeader[5] Width 100
		Add Column oCol To oBrowse Array Element SUB_AF9_QUANT  Header aHeader[6] Width  60 Picture "@E 999,999,999.9999" Align Right
		
		@ 145, 05 Button oBtnOk     Caption STR0012 Action ChooseOK(@aAFFItem, oBrowse, aTasks, oSayProj, oSayTask, oSayTaskDes)     Size 35, 10 Of oDlg //"OK"
		@ 145, 55 Button oBtnCancel Caption STR0015 Action ChooseCancel() Size 45, 10 Of oDlg	 //"Cancel"
		
	Activate Dialog oDlg
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ChooseOK  ºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ adiciona o codigo do projeto e tarefa para a confirmacao   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aAFFItem - a confirmacao a ser incluida                    º±±
±±º          ³ oBrowse  - oBrowse que contem a tarefa escolhida           º±±
±±º          ³ aItems   - array utilizado para exibir no browse           º±±
±±º          ³ oSayProj - objeto Say no qual sera mostrada o projeto      º±±
±±º          ³ oSayTask - objeto Say no qual sera mostrada a tarefa       º±±
±±º          ³ oSayTaskDes - objeto Say no qual sera mostrada a descricao º±±
±±º          ³            da tarefa                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ChooseOK(aAFFItem, oBrowse, aItems, oSayProj, oSayTask, oSayTaskDes)
	Local nSelItem := GetOption(oBrowse, aItems)
	
	CloseDialog()

	If nSelItem > 0
		aAFFItem[SUB_AFF_PROJET] := aItems[nSelItem][SUB_AF9_PROJET]
		aAFFItem[SUB_AFF_FILIAL] := aItems[nSelItem][SUB_AF9_FILIAL]
		aAFFItem[SUB_AFF_REVISA] := aItems[nSelItem][SUB_AF9_REVISA]
		aAFFItem[SUB_AFF_TAREFA] := aItems[nSelItem][SUB_AF9_TAREFA]
		
		SetText(oSayProj, aAFFItem[SUB_AFF_PROJET])
		SetText(oSayTask, aAFFItem[SUB_AFF_TAREFA])
		SetText(oSayTaskDes, aItems[nSelItem][SUB_AF9_DESCRI])
	EndIf
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³AFFValidFiºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ valida a confirmacao                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aAFFItem - a confirmacao a ser validada                    º±±
±±º          ³ nField   - campo a ser validado                            º±±
±±º          ³ nValue   - valor a ser validado                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFFValidField(aAFFItem, nField, nValue)
	Local lReturn := .F.
	Local nAF9Quant := AF9GetQuant(aAFFItem[SUB_AFF_FILIAL] + aAFFItem[SUB_AFF_PROJET];
	                             + aAFFItem[SUB_AFF_REVISA] + aAFFItem[SUB_AFF_TAREFA])
	
	Do Case
		Case nField == SUB_AFF_FILIAL
			lReturn := .T.
		Case nField == SUB_AFF_PROJET
			lReturn := .T.
		Case nField == SUB_AFF_REVISA
			lReturn := .T.
		Case nField == SUB_AFF_DATA
			lReturn := .T.			
		Case nField == SUB_AFF_TAREFA
			lReturn := .T.

		Case nField == SUB_AFF_QUANT
			If nValue > nAF9Quant .Or. nValue < 0.00
				lReturn := .F.
			Else
				lReturn := .T.
			EndIf
			
		Case nField == SUB_AFF_OCORRE
			lReturn := .T.
		Case nField == SUB_AFF_CODMEM
			lReturn := .T.
		Case nField == SUB_AFF_USER
			lReturn := .T.
		Case nField == SUB_AFF_CONFIR
			lReturn := .T.
		Case nField == SUB_AFF_SYNCID
			lReturn := .T.
		Case nField == SUB_AFF_SYNCFL
			lReturn := .T.
		
		Case nField == SUB_AFF_PERC
			If nValue > 100.00 .Or. nValue < 0.00
				lReturn := .F.
			Else
				lReturn := .T.
			EndIf
			
		Otherwise
			lReturn := .F.
	EndCase
	
	If lReturn
		aAFFItem[nField] := nValue
	EndIf
Return lReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³VldPer    ºAutor  ³Adriano Ueda        º Data ³  12/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ valida a porcentagem digitada                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aAFFItem - a confirmacao a ser incluida                    º±±
±±º          ³ nPer     -                                                 º±±
±±º          ³ oQtd     -                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Palm                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldPer(aAFFItem, nPer, oQtd)
	Local lReturn := .F.
	Local nAF9Quant := AF9GetQuant(aAFFItem[SUB_AFF_FILIAL] + aAFFItem[SUB_AFF_PROJET];
	                             + aAFFItem[SUB_AFF_REVISA] + aAFFItem[SUB_AFF_TAREFA])

	If aAFFItem[SUB_AFF_FILIAL] == Nil .Or.;
	   aAFFItem[SUB_AFF_PROJET] == Nil .Or.;
	   aAFFItem[SUB_AFF_REVISA] == Nil .Or.;
	   aAFFItem[SUB_AFF_TAREFA] == Nil
		MsgAlert(STR0001) //"Selecione um projeto e uma tarefa para ser confirmada!"
		lReturn := .T.
	Else
		If Empty(aAFFItem[SUB_AFF_FILIAL]) .Or.;
		   Empty(aAFFItem[SUB_AFF_PROJET]) .Or.;
		   Empty(aAFFItem[SUB_AFF_REVISA]) .Or.;
		   Empty(aAFFItem[SUB_AFF_TAREFA])
			MsgAlert(STR0001) //"Selecione um projeto e uma tarefa para ser confirmada!"
			lReturn := .T.
		Else
			If !AFFValidField(@aAFFItem, SUB_AFF_PERC, nPer)
				MsgAlert(STR0024, APP_NAME) //"Porcentagem inválida!"
				lReturn := .F.
			Else
		
				// salva a porcentagem
				aAFFItem[SUB_AFF_PERC] := nPer
		
				// calcula a quantidade, baseada na quantidade da tarefa
				aAFFItem[SUB_AFF_QUANT] := CalcQtdTask(nAF9Quant, nPer)
		
				// exibe a quantidade calculada
				SetText(oQtd, Transform(aAFFItem[SUB_AFF_QUANT], "@E 999999.9999"))
				
				lReturn := .T.
			EndIf
		EndIf
	EndIf
Return lReturn