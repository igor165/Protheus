#include "pmspalma.ch"
#include "eadvpl.ch"
#include "_pmspalm.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DlgAF9All �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � confirmacao em lote das tarefas                            ���
�������������������������������������������������������������������������͹��
���Parametros� aAFFItems - array no qual ser incluida a confirmacao       ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DlgAF9All(aAFFItems)
	Local oDlg    := Nil  // janela principal
	Local oMenu   := Nil  // menu
	Local oBrowse := Nil  // browse
	Local oCol    := Nil  // coluna

	// arrays necess�rios para
	// utiliza��o com o browse
	Local aHeader := {}
	Local aTasks  := {}
	
	Local oBtnOk  := Nil
	Local oBtnCancel := Nil
	
	Local oChk := Nil
	Local lChk := .F.
	
	Define Dialog oDlg Title STR0001 //APP_NAME //"Confirma��o por lote"

		@ 20, 05 Say STR0002 Of oDlg //"Selecione a(s) tarefa(s):"
		
		// carrega as tarefas que podem ser fazer confirmacao
		AF9FillConfir(@aTasks)
		
		aAdd(aHeader, STR0003) //"Filial"
		aAdd(aHeader, STR0004) //"Revis�o"
		aAdd(aHeader, STR0005) //"Projeto"
		aAdd(aHeader, STR0006) //"Tarefa"
		aAdd(aHeader, STR0007) //"Descri��o da Tarefa"
		aAdd(aHeader, STR0008) //"Quantidade"

		// mostra browse com as ocorrencias existentes
		@ 35, 05 Browse oBrowse Size 150, 95 Of oDlg
		Set Browse oBrowse Array aTasks

		Add Column oCol To oBrowse Array Element SUB_AF9_MARK   Header "" Width 10 Mark
		Add Column oCol To oBrowse Array Element SUB_AF9_FILIAL Header aHeader[1] Width  20
		Add Column oCol To oBrowse Array Element SUB_AF9_REVISA Header aHeader[2] Width  50
		Add Column oCol To oBrowse Array Element SUB_AF9_PROJET Header aHeader[3] Width  50
		Add Column oCol To oBrowse Array Element SUB_AF9_TAREFA Header aHeader[4] Width  50
		Add Column oCol To oBrowse Array Element SUB_AF9_DESCRI Header aHeader[5] Width 100
		Add Column oCol To oBrowse Array Element SUB_AF9_QUANT  Header aHeader[6] Width  60

		@ 145, 05 Button oBtnOk     Caption STR0009     Action ConfLote(@aAFFItems, @aTasks) Size 35, 10 Of oDlg //"OK"
		@ 145, 55 Button oBtnCancel Caption STR0010 Action CloseDialog() Size 45, 10 Of oDlg //"Cancel"
		
		@ 145, 110 Checkbox oChk Var lChk Caption STR0011 Action MarkAll(@oBrowse, @aTasks, lChk) Size 45, 12 Of oDlg //"Todas"
	Activate Dialog oDlg
Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ConfLote  �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � confirma as tarefas selecionadas                           ���
�������������������������������������������������������������������������͹��
���Parametros� aAFFItems - array no qual serao inseridas as confirmacoes  ���
���          � aTasks    - array com as tarefas selecionadas              ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ConfLote(aAFFItems, aTasks)
	Local ni := 0
	Local aAFFTemp := {}
	
	If Len(aTasks) > 0
		For ni := 1 To Len(aTasks)
			If aTasks[ni][SUB_AF9_MARK]
				AFFInitItem(@aAFFTemp)

				aAFFTemp[SUB_AFF_PROJET] := aTasks[ni][SUB_AF9_PROJET]
				aAFFTemp[SUB_AFF_TAREFA] := aTasks[ni][SUB_AF9_TAREFA]
				aAFFTemp[SUB_AFF_FILIAL] := aTasks[ni][SUB_AF9_FILIAL]
				aAFFTemp[SUB_AFF_REVISA] := aTasks[ni][SUB_AF9_REVISA]

				DlgAFFInclude(@aAFFItems, aAFFTemp)
				//DlgAFFIncLote(aAFFItems, aTasks[ni])
			EndIf
		Next
	Else
		MsgAlert(STR0012) //"N�o h� nenhuma tarefa para ser confirmada!"
	EndIf	
	
	CloseDialog()
Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DlgAFFInc �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � inclui uma confirmacao para uma tarefa                     ���
�������������������������������������������������������������������������͹��
���Parametros� aTasks   - array no qual serao inseridas a confirmacao     ���
���          � aAF9Item - array com a tarefa a ser inserida               ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*Function DlgAFFIncLote(aTasks, aAF9Item)
	Local oDlg   := Nil

	Local oBtnCalen := Nil	
	Local oBtnOk     := Nil
	Local oBtnCancel := Nil
 	Local cKey   := Nil
		
	Local oGetPer   := Nil
	Local oGetQtd  := Nil
	
	Local nTemp := 0
	Local nQtd  := 0

	Local aTasks    := {}	
	Local oCboTasks := Nil
	Local oCboProjs := Nil
	Local oChk      := Nil
	
	Local oChoose   := Nil
	
	Local nSelTask  := 1
	Local nSelProj  := 1
	
	Local aProjs := {}
	
	Local cDate := DToC(Date())
	//Local aAF9Item := {}
	
	Local oSayProj := Nil
	Local oSayTask := Nil
	Local oSayDate := Nil
	
	Local cProj := ""
	Local cTask := ""

	Local lCheck   := .F.	
	
	Local aAFFItem := {}


	AFFInitItem(@aAFFItem)
	
	aAFFItem[SUB_AFF_PROJET] := aAF9Item[SUB_AF9_PROJET]
	aAFFItem[SUB_AFF_FILIAL] := aAF9Item[SUB_AF9_FILIAL]
	aAFFItem[SUB_AFF_REVISA] := aAF9Item[SUB_AF9_REVISA]
	aAFFItem[SUB_AFF_TAREFA] := aAF9Item[SUB_AF9_TAREFA]

	AFFSetAE(@aAFFItem, lCheck)
	
	Define Dialog oDlg Title APP_NAME
		@  20, 05 Say "Inclus�o de Confirma��o" Bold Of oDlg			

		@  38, 05 Say "Projeto:"       Of oDlg
		@  38, 50 Say aAF9Item[SUB_AF9_PROJET] Of oDlg
		
		@  50, 05 Say "Tarefa:"        Of oDlg
		@  50, 50 Say aAF9Item[SUB_AF9_TAREFA] Of oDlg

		@  82, 05 To 82, 155 Of oDlg
				
		@  87, 05 Say "Data ref:"      Of oDlg
		@  87, 50 Say oSayDate Prompt DToC(aAFFItem[SUB_AFF_DATA]) Of oDlg
		@  87, 105 Button oBtnCalen Caption "..." Action aAFFItem[SUB_AFF_DATA] := GetDate(aAFFItem[SUB_AFF_DATA], oSayDate) Size 15, 10 Of oDlg

		@  99, 05 Say "% Exec.:"     Of oDlg  // calculado
		@  99, 50 Get oGetPer Var nTemp Picture "@E 999.99" Valid VldPer(@aAFFItem, Round(nTemp, 4), oGetQtd) Of oDlg

		@ 111, 05 Say "Qtd. Exec.:"       Of oDlg  
		@ 111, 50 Get oGetQtd Var nQtd Picture "@E 999999.9999" Valid VldQtd(@aAFFItem, nQtd, oGetPer) Of oDlg

		@ 125, 03 CheckBox oChk Var lCheck Caption "Gerar Autoriz. Entrega" Action AFFSetAE(@aAFFItem, lCheck) Of oDlg
		SetText(oChk, lCheck)		
		
		@ 140, 05 To 140, 155 Of oDlg    

		@ 146, 05 Button oBtnOk     Caption "OK" Action VldAFFSave(@aAFFItem, nQtd, aTasks) Size 35, 10 Of oDlg
		@ 146, 55 Button oBtnCancel Caption "Cancel" Action CloseDialog() Size 45, 10 Of oDlg					
	Activate Dialog oDlg
Return */


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �MarkAll   �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � marca todos os elementos de um browse                      ���
�������������������������������������������������������������������������͹��
���Parametros� oBrowse - com as tarefas selecionadas                      ���
���          � aTasks  - array com as tarefas associadas ao browse        ���
���          � lChk    - indica se as tarefas serao marcadas ou nao       ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MarkAll(oBrowse, aTasks, lChk)
	Local lReturn := .F.
	Local ni := 0

	For ni := 1 To Len(aTasks)
		aTasks[ni][SUB_AFF_MARK] := lChk
	Next
	
	SetArray(@oBrowse, @aTasks)
Return lReturn


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ShowDetail�Autor  �Adriano Ueda        � Data �  20/02/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � janela de exclusao da confirmacao                          ���
�������������������������������������������������������������������������͹��
���Parametros� aAFFItem - confirmacao cujos detalhes serao mostrados      ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ShowDetails(aAFFItem)
	Local lReturn := .F.
	
	Local oDlg         := Nil
	Local oButtonClose := Nil
	
	Define Dialog oDlg Title APP_NAME
		@ 18, 05 Say STR0013 Bold Of oDlg //"Detalhes da tarefa"

		@ 36, 05 Say STR0004                  Of oDlg //"Revis�o"
		@ 36, 50 Say aAFFItem[SUB_AFF_REVISA] Of oDlg
		
		@ 50, 05 Say STR0014                  Of oDlg //"Filial:"
		@ 50, 50 Say aAFFItem[SUB_AFF_FILIAL] Of oDlg
		
		@ 64, 05 Say STR0015                  Of oDlg //"Projeto:"
		@ 64, 50 Say aAFFItem[SUB_AFF_PROJET] Of oDlg
		
		@ 82, 05 To 00, 155 Of oDlg
		
		@ 86, 05 Say STR0016                  Of oDlg //"Tarefa:"
		@ 86, 50 Say aAFFItem[SUB_AFF_TAREFA] Of oDlg
		
		@ 100, 05 Say STR0017             Of oDlg //"Descri��o:"
		@ 100, 50 Say AllTrim(AF9ItemDesc(aAFFItem[SUB_AFF_FILIAL] + aAFFItem[SUB_AFF_PROJET] +;
		                                  aAFFItem[SUB_AFF_REVISA] + aAFFItem[SUB_AFF_TAREFA])) Of oDlg

		@ 114, 05 Say STR0018            Of oDlg //"Quant.:"
		@ 114, 50 Say Transform(AF9GetQuant(aAFFItem[SUB_AFF_FILIAL] + aAFFItem[SUB_AFF_PROJET] +;
		                                    aAFFItem[SUB_AFF_REVISA] + aAFFItem[SUB_AFF_TAREFA]),;
		                                   "@E 999999.9999") Of oDlg
		@ 140, 05 To 00, 155 Of oDlg
		
		@ 145, 05 Button oButtonClose Caption STR0009     Action CloseDialog() Size 35, 10 Of oDlg //"OK"
	Activate Dialog oDlg
Return lReturn


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DlgAFFExc �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � janela de exclusao da confirmacao                          ���
�������������������������������������������������������������������������͹��
���Parametros� aTasks   - array de confirmacoes (utilizado com o oBrowse  ���
���          � nSelItem - confirmacao escolhida para exclusao             ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DlgAFFExc(aTasks, nSelItem)
	// janela principal
	Local oDlg         := Nil
	Local oButtonClose := Nil
	Local oBtnCancel   := Nil
	Local oChk         := Nil
	Local oChoose      := Nil
	Local oSayTaskDes  := Nil

	Local aAFFItem     := Nil
	Local lCheck       := .F.
	
	aAFFItem := AFFSeek(AFFGetKey(aTasks, nSelItem))

	If aAFFItem[SUB_AFF_CONFIR] == AUT_ENTREGA_SIM
		lCheck := .T.
	Else
		lCheck := .F.
	EndIf

	If !Empty(aAFFItem)
		Define Dialog oDlg Title STR0023 //"Exclus�o de Confirma��o"
			//@ 20, 05 Say "Exclus�o de Confirma��o" Bold Of oDlg

			@  20, 05 Say STR0015            Of oDlg //"Projeto:"
			@  20, 50 Say aAFFItem[SUB_AFF_PROJET] Of oDlg
			
			@  34, 05 Say STR0016            Of oDlg //"Tarefa:"
			@  34, 50 Say aAFFItem[SUB_AFF_TAREFA] Of oDlg

			@  48, 05 Say STR0017            Of oDlg //"Descri��o:"
			@  48, 50 Say oSayTaskDes Prompt Space(30) Of oDlg
			SetText(oSayTaskDes, AllTrim(AF9ItemDesc(aAFFItem[SUB_AFF_FILIAL] + aAFFItem[SUB_AFF_PROJET] +;
			                                         aAFFItem[SUB_AFF_REVISA] + aAFFItem[SUB_AFF_TAREFA])))

			@  64, 05 Button oChoose Caption STR0024 Size 50, 10 of oDlg //"Detalhes"
			
			@  80, 05 To 00, 155 Of oDlg
	
			@  84, 05 Say STR0025      Of oDlg //"Data Ref:"
			@  84, 50 Say aAFFItem[SUB_AFF_DATA] Of oDlg
	
			@  98, 05 Say STR0026       Of oDlg   //"% Exec.:"
			@  98, 50 Say Transform(aAFFItem[SUB_AFF_PERC], "@E 999.99") Of oDlg
	
			@ 112, 05 Say STR0027     Of oDlg //"Qtd Exec.:"
			@ 112, 50 Say Transform(aAFFItem[SUB_AFF_QUANT], "@E 999999.9999") Of oDlg

			@ 126, 03 CheckBox oChk Var lCheck Caption STR0028 Of oDlg  //"Gerar Autoriz. Entrega"
			SetText(oChk, lCheck)
			DisableControl(oChk)
	
			@ 140, 05 To 00, 155 Of oDlg
			
			@ 145, 05 Button oButtonClose Caption STR0009     Action AFFExcOk(@aTasks, nSelItem) Size 35, 10 Of oDlg //"OK"
			@ 145, 55 Button oBtnCancel   Caption STR0010 Action CloseDialog()              Size 45, 10 Of oDlg //"Cancel"
		Activate Dialog oDlg
	EndIf
Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFFExcOK  �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � exclui uma confirmacao do AFF                              ���
�������������������������������������������������������������������������͹��
���Parametros� aTasks   - array de confirmacoes (utilizado com o oBrowse  ���
���          � nSelItem - confirmacao escolhida para exclusao             ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFFExcOk(aTasks, nSelItem)

	//If AFFGetStatus(AFFGetKey(aTasks, nSelItem)) == ""
		AFFMarkDel(AFFGetKey(aTasks, nSelItem))
	//Else
	//	AFFDelete(AFFGetKey(aTasks, nSelItem))
	//	Pack
	//EndIf
	
	AFFFill(@aTasks)
	
	CloseDialog()
Return Nil