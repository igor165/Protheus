#include "pmspalmc.ch"
#include "eadvpl.ch"
#include "_pmspalm.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �VldAFFSave�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � valida e salva a confirmacao no AFF                        ���
�������������������������������������������������������������������������͹��
���Parametros� aAFFItem - confirmacao a ser validada e salva              ���
���          � nQtd     - quantidade a ser validada                       ���
���          � aItems   - array de confirmacoes para ser exibido no browse���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
					MsgAlert(STR0002, APP_NAME) //"Quantidade inv�lida!"
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DlgAFFView�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � janela da visualizacao da confirmacao                      ���
�������������������������������������������������������������������������͹��
���Parametros� aItems   - contem as confirmacoes adicionadas              ���
���          � nSelItem - confirmacao selecionada para ser visualizada    ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
		Define Dialog oDlg Title STR0003 //APP_NAME //"Visualiza��o de Confirma��o"
			//@ 20, 05 Say "Visualiza��o de Confirma��o" Bold Of oDlg

			@ 20, 05 Say STR0004       Of oDlg //"Projeto:"
			@ 20, 50 Say aAFFItem[SUB_AFF_PROJET] Of oDlg
			
			@ 34, 05 Say STR0005        Of oDlg //"Tarefa:"
			@ 34, 50 Say aAFFItem[SUB_AFF_TAREFA] Of oDlg

			@  48, 05 Say STR0006    Of oDlg		 //"Descri��o:"
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DlgAFFChan�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � valida e salva a confirmacao no AFF                        ���
�������������������������������������������������������������������������͹��
���Parametros� aItems   - confirmacao a ser validada e salva              ���
���          � nSelItem - quantidade a ser validada                       ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	
		Define Dialog oDlg Title STR0013 //APP_NAME //"Altera��o de Confirma��o"
			
			@  20, 05 Say STR0004           Of oDlg //"Projeto:"
			@  20, 50 Say aAFFItem[SUB_AFF_PROJET] Of oDlg
			
			@  34, 05 Say STR0005            Of oDlg //"Tarefa:"
			@  34, 50 Say aAFFItem[SUB_AFF_TAREFA] Of oDlg

			@  48, 05 Say STR0006         Of oDlg		 //"Descri��o:"
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ChooseTask�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � janela de escolha de tarefa                                ���
�������������������������������������������������������������������������͹��
���Parametros� aAFFItem - confirmacao a ser validada e salva              ���
���          � oSayProj - objeto Say no qual sera mostrado o projeto      ���
���          � oSayTask - objeto Say no qual sera mostrada a tarefa       ���
���          � oSayTaskDes - objeto Say no qual sera mostrada a descricao ���
���          �            da tarefa                                       ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

	// arrays necess�rios para
	// utiliza��o com o browse
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
		aAdd(aHeader, "Revis�o")
		aAdd(aHeader, "Projeto")
		aAdd(aHeader, "Tarefa")
		aAdd(aHeader, "Descri��o da Tarefa")
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ChooseOK  �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � adiciona o codigo do projeto e tarefa para a confirmacao   ���
�������������������������������������������������������������������������͹��
���Parametros� aAFFItem - a confirmacao a ser incluida                    ���
���          � oBrowse  - oBrowse que contem a tarefa escolhida           ���
���          � aItems   - array utilizado para exibir no browse           ���
���          � oSayProj - objeto Say no qual sera mostrada o projeto      ���
���          � oSayTask - objeto Say no qual sera mostrada a tarefa       ���
���          � oSayTaskDes - objeto Say no qual sera mostrada a descricao ���
���          �            da tarefa                                       ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFFValidFi�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � valida a confirmacao                                       ���
�������������������������������������������������������������������������͹��
���Parametros� aAFFItem - a confirmacao a ser validada                    ���
���          � nField   - campo a ser validado                            ���
���          � nValue   - valor a ser validado                            ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �VldPer    �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � valida a porcentagem digitada                              ���
�������������������������������������������������������������������������͹��
���Parametros� aAFFItem - a confirmacao a ser incluida                    ���
���          � nPer     -                                                 ���
���          � oQtd     -                                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
				MsgAlert(STR0024, APP_NAME) //"Porcentagem inv�lida!"
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