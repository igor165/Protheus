#include "eadvpl.ch"    
#include "_pmspalm.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �pmsrec    �Autor  �Reynaldo Miyashita  � Data �  09.08.2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcoes de interface com o usuario                         ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DlgAptRec �Autor  �Reynaldo Miyashita  � Data �  09.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Janela de gerenciamento de Apontamento de recursos         ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DlgAptRec()
	Local oDlg    := Nil // janela principal
	Local oMenu   := Nil // menu
	Local oItem1  := Nil // menu Visualizar
	Local oItem2  := Nil // menu Incluir
	Local oItem3  := Nil // menu Alterar
	Local oItem4  := Nil // menu Excluir
	Local oItem5  := Nil // menu Fechar
	Local oBrowse := Nil // browse
	Local oCol    := Nil // coluna

	// arrays necessarios para
	// utilizacao com o browse
	Local aHeader := {}
	Local aItens  := {}

	Define Dialog oDlg Title "Apontamento de recursos"
		Add Menubar oMenu Caption "Apontamento" Of oDlg
		
		Add MenuItem oItem1 Caption "Visualizar" Action MnuClick(oBrowse, aItens, MNU_VISUALIZAR) Of oMenu //"Visualizar"
		Add MenuItem oItem2 Caption "Incluir"    Action MnuClick(oBrowse, aItens, MNU_INCLUIR)    Of oMenu //"Incluir"
		Add MenuItem oItem3 Caption "Alterar"    Action MnuClick(oBrowse, aItens, MNU_ALTERAR)    Of oMenu //"Alterar"
		Add MenuItem oItem4 Caption "Excluir"    Action MnuClick(oBrowse, aItens, MNU_EXCLUIR)    Of oMenu //"Excluir"
		Add MenuItem oItem5 Caption "Fechar"     Action CloseDialog() Of oMenu //"Fechar"

		@ 20, 05 Say "Apontamentos existentes:" Of oDlg
		
		aAdd(aHeader, "Filial")
		aAdd(aHeader, "Projeto")
		aAdd(aHeader, "Tarefa")
		aAdd(aHeader, "Recurso")
		aAdd(aHeader, "Data")
		aAdd(aHeader, "Hr Ini")
		aAdd(aHeader, "Hr Fin")
		aAdd(aHeader, "Hr Qtd")

		// carrega aItens com as ocorrencias existentes
		AFUFill(@aItens)

		// mostra browse com as ocorrencias existentes	
		@ 35, 05 Browse oBrowse Size 150, 100 On Click BrwClick(oDlg, oBrowse, aItens) Of oDlg
		Set Browse oBrowse Array aItens

		Add Column oCol To oBrowse Array Element SUB_AFU_PROJET Header aHeader[02] Width 60
		Add Column oCol To oBrowse Array Element SUB_AFU_TAREFA Header aHeader[03] Width 60
		Add Column oCol To oBrowse Array Element SUB_AFU_RECURS Header aHeader[04] Width 60 
		Add Column oCol To oBrowse Array Element SUB_AFU_DATA   Header aHeader[05] Width 40
		Add Column oCol To oBrowse Array Element SUB_AFU_HORAI  Header aHeader[06] Width 30
		Add Column oCol To oBrowse Array Element SUB_AFU_HORAF  Header aHeader[07] Width 30
		Add Column oCol To oBrowse Array Element SUB_AFU_HQUANT Header aHeader[08] Width 40  Picture "@E 999,999,999.99" Align Right
	Activate Dialog oDlg
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �BrwClick  �Autor  �Reynaldo Miyashita  � Data �  11.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� oDlg    - janela que contem os registro do AFU             ���
���          � oBrowse - browse                                           ���
���          � aItens  - items contidos no browse                         ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function BrwClick(oDlg, oBrowse, aItens)
//Local lReturn := .F.
//Return lReturn
Return .F.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �MnuClick  �Autor  �Reynaldo Miyashita   � Data �  11.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Processa a selecao dos menus                               ���
�������������������������������������������������������������������������͹��
���Parametros� oBrowse - browse que contem os registro do AFU             ���
���          � aItens  - items que estao no browse                        ���
���          � nOp     - identificador do menu                            ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MnuClick(oBrowse, aItens, nOp)
	Local lReturn  := .F.

	Do Case
		Case nOp == MNU_ALTERAR
			If !IsSel(oBrowse, aItens)
				MsgAlert("N�o h� nenhum registro para ser alterado!", APP_NAME)
			Else
				DlgAFUChange(@aItens, GetOption(oBrowse, aItens))
				lReturn := .T.
			EndIf
	
		Case nOp == MNU_INCLUIR
			DlgAFUInclude(@aItens, {})
			lReturn := .T.
			
		Case nOp == MNU_VISUALIZAR
			If !IsSel(oBrowse, aItens)
				MsgAlert("N�o h� nenhum registro para ser visualizado!", APP_NAME)
			Else
				DlgAFUView(@aItens, GetOption(oBrowse, aItens))
				lReturn := .T.
			EndIf
				
		Case nOp == MNU_EXCLUIR
			If !IsSel(oBrowse, aItens)
				MsgAlert("N�o h� nenhum registro para ser exclu�do!", APP_NAME)
			Else
				DlgAFUExc(@aItens, GetOption(oBrowse, aItens))
				lReturn := .T.
			EndIf

	EndCase
	
	// atualizar o browse com as confirmacoes
	If lReturn
		SetArray(oBrowse, aItens)
	EndIf
Return lReturn


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DlgAFUView�Autor  �Reynaldo Miyashita  � Data �  11.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � janela da visualizacao da confirmacao                      ���
�������������������������������������������������������������������������͹��
���Parametros� aItens   - contem as confirmacoes adicionadas              ���
���          � nSelItem - confirmacao selecionada para ser visualizada    ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DlgAFUView(aItens, nSelItem)
// janela principal
	Local oDlg         := Nil

	Local oButtonClose := Nil
	Local oSayTaskDes  := Nil
	Local oChoose      := Nil

	Local aAFUItem     := {}

	aAFUItem := AFUSeek(AFUGetKey(aItens, nSelItem))
	
	Define Dialog oDlg Title "Visualiza��o do Apontamento" //APP_NAME

		@  20, 05 Say "Projeto:" Of oDlg 
		@  20, 50 Say aAFUItem[SUB_AFU_PROJET] Of oDlg
		
		@  32, 05 Say "Tarefa:" Of oDlg
		@  32, 50 Say aAFUItem[SUB_AFU_TAREFA] Of oDlg

		@  42, 05 Say "Descri��o:" Of oDlg
		@  42, 50 Say oSayTaskDes Prompt Space(30) Of oDlg
		SetText(oSayTaskDes, AllTrim(AF9ItemDesc(aAFUItem[SUB_AFU_FILIAL] + aAFUItem[SUB_AFU_PROJET] +;
		                                 aAFUItem[SUB_AFU_REVISA] + aAFUItem[SUB_AFU_TAREFA])))
           
		@  54, 05 Button oChoose Caption "Detalhes" Action ShowRecDetail(aAFUItem) Size 50, 10 of oDlg
		
		//@  80, 05 To 80, 155 Of oDlg
		@  68, 05 To 0, 155 Of oDlg

		@  72, 05 Say "Recurso:"      Of oDlg
		@  72, 55 Say aAFUItem[SUB_AFU_RECURS] Of oDlg

		@  82, 05 Say "Descri��o:" Of oDlg   
		@  82, 55 Say AE8ItemDesc(aAFUItem[SUB_AFU_FILIAL]+aAFUItem[SUB_AFU_RECURS]) Of oDlg

		@  92, 05 Say "Data:" Of oDlg   
		@  92, 55 Say aAFUItem[SUB_AFU_DATA] Of oDlg

		@ 102, 05 Say "Hora Inicial:"    Of oDlg
		@ 102, 55 Say aAFUItem[SUB_AFU_HORAI] Of oDlg

		@ 114, 05 Say "Hora Final:"    Of oDlg
		@ 114, 55 Say aAFUItem[SUB_AFU_HORAF] Of oDlg
		
		@ 124, 05 Say "Qtde.Horas:"    Of oDlg
		@ 124, 55 Say Transform( aAFUItem[SUB_AFU_HQUANT] ,"@E 999,999,999.99" ) Of oDlg
		
		//@ 136, 05 To 136, 155 Of oDlg
		@ 136, 05 To 0, 155 Of oDlg
		
		@ 144, 05 Button oButtonClose Caption "OK" Action CloseDialog() Size 35, 10 Of oDlg

	Activate Dialog oDlg

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ShowRecDet�Autor  �Reynaldo Miyashita  � Data �  11.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � janela de detalhes do projeto e tarefa                     ���
�������������������������������������������������������������������������͹��
���Parametros� aAFUItem - Apontamento do recurno do projeto e tarefa cujos���
���                       detalhes serao mostrados                        ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ShowRecDetail(aAFUItem)
	Local oDlg         := Nil
	Local oButtonClose := Nil

	Define Dialog oDlg Title APP_NAME
		@  17, 05 Say "Detalhes da tarefa" Bold Of oDlg

		@  31, 05 Say "Filial:"                Of oDlg 
		@  31, 55 Say aAFUItem[SUB_AFU_FILIAL] Of oDlg
		
		@  41, 05 Say "Projeto:"               Of oDlg
		@  41, 55 Say aAFUItem[SUB_AFU_PROJET] Of oDlg
		
		@  51, 05 Say "Revis�o"                Of oDlg 
		@  51, 55 Say aAFUItem[SUB_AFU_REVISA] Of oDlg
		
		//@ 65, 05 To 65, 155 Of oDlg
		@  65, 05 To 0, 155 Of oDlg
		
		@  68, 05 Say "Tarefa:"                Of oDlg
		@  68, 55 Say aAFUItem[SUB_AFU_TAREFA] Of oDlg
		
		@  78, 05 Say "Descri��o:"             Of oDlg
		@  78, 55 Say AllTrim(AF9ItemDesc(aAFUItem[SUB_AFU_FILIAL] + aAFUItem[SUB_AFU_PROJET] +;
		                                  aAFUItem[SUB_AFU_REVISA] + aAFUItem[SUB_AFU_TAREFA])) Of oDlg

		@  88, 05 Say "Recurso.:"              Of oDlg
		@  88, 55 Say aAFUItem[SUB_AFU_RECURS] Of oDlg
		
		@  98, 05 Say "Descri��o:" Of oDlg   
		@  98, 55 Say AE8ItemDesc(aAFUItem[SUB_AFU_FILIAL]+aAFUItem[SUB_AFU_RECURS]) Of oDlg
	
		@ 108, 05 Say "Data.:"               Of oDlg
		@ 108, 55 Say aAFUItem[SUB_AFU_DATA] Of oDlg
		
		@ 118, 05 Say "Hora Inicial:"         Of oDlg
		@ 118, 55 Say aAFUItem[SUB_AFU_HORAI] Of oDlg

		@ 118, 85 Say "Hora Final:"           Of oDlg
		@ 118,130 Say aAFUItem[SUB_AFU_HORAF] Of oDlg
		
		@ 128, 05 Say "Qtde.Horas:"           Of oDlg
		@ 128, 55 Say Transform( aAFUItem[SUB_AFU_HQUANT] ,"@E 999,999,999.99" ) Of oDlg
		
		//@ 140, 05 To 140, 155 Of oDlg
		@ 140, 05 To 0, 155 Of oDlg
		
		@ 144, 05 Button oButtonClose Caption "OK" Action CloseDialog() Size 35, 10 Of oDlg
		
	Activate Dialog oDlg
	
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DlgAFUIncl�Autor  �Reynaldo Miyashita  � Data �  11.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � mostra a janela de inclusao de confirmacao                 ���
�������������������������������������������������������������������������͹��
���Parametros� aItens  - items contidos no browse (sera atualizado com a  ���
���          �           confirmacao inserida                             ���
���          � aAFUItemPre - apontamento pre-selecionado                  ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DlgAFUInclude(aItens ,aAFUItemPre )
	Local oDlg       := Nil
	Local oBtnRecurs := Nil
	Local oBtnCalen  := Nil
	Local oBtnOk     := Nil
	Local oBtnCancel := Nil
	Local oGetHoraI  := Nil
	Local oGetHoraF  := Nil
	Local oGetHQUANT := Nil

	Local cHoraI  := Space(05)
	Local cHoraF  := Space(05)
	Local nHQuant := 0

	Local oChoose   := Nil

	Local oSayProj := Nil
	Local oSayTask := Nil
	Local oSayDate := Nil
	Local oSayTaskDes := Nil
	Local oSayRecurso := Nil
	Local oSayRecDescri := Nil

	Local aAFUItem := {}
	Local lBatch   := .F.

	If (aAFUItemPre == Nil) .Or. (Len(aAFUItemPre) == 0)
		lBatch := .F.
	Else
		lBatch := .T.
	EndIf
	
	If !lBatch
		AFUInitItem(@aAFUItem)
	Else
		aAFUItem := aClone(aAFUItemPre)
	EndIf
	
	// carrega OS APONTAMENTOS
	AFUFill(@aItens)
	
	Define Dialog oDlg Title "Inclus�o de Apontamento"  //APP_NAME 

		// -------------------------------------------------------------------

		@  20, 05 Say "Projeto:" Of oDlg 
		@  20, 50 Say oSayProj Prompt Space(15) Of oDlg
		SetText(oSayProj, aAFUItem[SUB_AFU_PROJET])	
		
		@  34, 05 Say "Tarefa:" Of oDlg 
		@  34, 50 Say oSayTask Prompt Space(15) Of oDlg
		SetText(oSayTask, aAFUItem[SUB_AFU_TAREFA])
		
		@  48, 05 Say "Descri��o:" Of oDlg 
		@  48, 50 Say oSayTaskDes Prompt Space(30) Of oDlg
		SetText(oSayTaskDes, AllTrim(AF9ItemDesc(aAFUItem[SUB_AFU_FILIAL] + aAFUItem[SUB_AFU_PROJET] +;
		                                         aAFUItem[SUB_AFU_REVISA] + aAFUItem[SUB_AFU_TAREFA])))
		If lBatch
			@  64, 05 Button oChoose Caption "Detalhes" Action ShowRecDetail(aAFUItem) Size 50, 10 of oDlg
		Else
			@  64, 05 Button oChoose Caption "Selecionar" Action SelRecTsk(@aAFUItem, oSayProj, oSayTask, oSayTaskDes) Size 50, 10 of oDlg
		EndIf

		//@  80, 05 To 80, 155 Of oDlg
		@  80, 05 To 0, 155 Of oDlg

		@  82, 05 Say "Recurso:" Of oDlg
		@  82, 55 Say oSayRecurso Prompt Space(15) Of oDlg
		@  84,120 Button oBtnRecurs Caption "..." Action GetAE8Recurs( @aAFUItem ,oSayRecurso ,oSayRecDescri )  Size 15, 08 Of oDlg

		@  94, 05 Say "Descri��o:" Of oDlg      
		@  94, 55 Say oSayRecDescri Prompt AE8ItemDesc(aAFUItem[SUB_AFU_FILIAL]+aAFUItem[SUB_AFU_RECURS]) Of oDlg
		
		@ 106, 05 Say "Data:" Of oDlg      
		@ 106, 55 Say oSayDate Prompt DToC(aAFUItem[SUB_AFU_DATA]) Of oDlg
		@ 108, 105 Button oBtnCalen Caption "..." Action GetAFUDate( @aAFUItem ,oSayDate ) Size 15, 08 Of oDlg

		@ 118, 05 Say "Hora Inicial:" of oDlg
		@ 118, 55 Get oGetHoraI Var cHoraI Picture "@R 99:99" Valid VldHoraI( cHoraI ,cHoraF ,aAFUItem ,aItens ,oGetHoraI ,oGetHQUANT ) Of oDlg

		@ 118, 85 Say "Hora Final:"    Of oDlg
		@ 118,130 Get oGetHoraF Var cHoraF Picture "@R 99:99" Valid VldHoraF( cHoraF ,cHoraI ,aAFUItem ,aItens ,oGetHoraF ,oGetHQUANT ) Of oDlg
		
		@ 130, 05 Say "Qtde.Horas:"    Of oDlg
		@ 130, 55 Get oGetHQUANT Var nHQuant Picture "@E 999,999,999.99" Valid VldHQuant( cHoraI ,cHoraF ,nHQuant ) Of oDlg

		//@ 142, 05 To 142, 155 Of oDlg
		@ 142, 05 To 0, 155 Of oDlg

		@ 146, 05 Button oBtnOk     Caption "OK" Action VldAFUSave( @aAFUItem ,cHoraI ,cHoraF ,nHQuant ,aItens ) Size 35, 10 Of oDlg

		@ 146, 55 Button oBtnCancel Caption "Cancel" Action CloseDialog() Size 45, 10 Of oDlg
	
	Activate Dialog oDlg
	
Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �VldAFUSave�Autor  �Reynaldo Miyashita  � Data �  12.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � valida e salva a confirmacao no AFU                        ���
�������������������������������������������������������������������������͹��
���Parametros� aAFUItem - Apontamento a ser validada e salva              ���
���          � cHoraI   - Hora Inicial                                    ���
���          � cHoraF   - Hora Final                                      ���
���          � nHQuant  - quantidade de horas a ser validada              ���
���          � aItens   - array de apontamentos para ser exibido no browse���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VldAFUSave( aAFUItem ,cHoraI ,cHoraF ,nHQuant ,aItens )
	Local lReturn := .F.

	If aAFUItem[SUB_AFU_FILIAL] == Nil .Or.;
	   aAFUItem[SUB_AFU_PROJET] == Nil .Or.;
	   aAFUItem[SUB_AFU_REVISA] == Nil .Or.;
	   aAFUItem[SUB_AFU_TAREFA] == Nil
		
		MsgAlert("Selecione um projeto e uma tarefa para ser apontado!", APP_NAME)
	Else
		If Empty(aAFUItem[SUB_AFU_FILIAL]) .Or.;
		   Empty(aAFUItem[SUB_AFU_PROJET]) .Or.;
		   Empty(aAFUItem[SUB_AFU_REVISA]) .Or.;
		   Empty(aAFUItem[SUB_AFU_TAREFA])
			MsgAlert("Selecione um projeto e uma tarefa para ser apontado!", APP_NAME)
		Else
			// recurso nao foi informado existe
			If Empty(aAFUItem[SUB_AFU_RECURS])
				MsgAlert("Selecione um recurso para ser apontado!", APP_NAME)
			Else
				// hora inicial ou final n�o foi informado.
				If Empty(cHoraI) .or. Empty(cHoraF)
					MsgAlert("Informe a Hora Inicial e a Hora Final. Verifique.", APP_NAME)
				Else
					// Hora final > hora inicial
					If Substr(cHoraF,1,2)+Substr(cHoraF,4,2) < Substr(cHoraI,1,2)+Substr(cHoraI,4,2)
						MsgAlert("Hora Final n�o pode ser maior que a Hora Inicial. Verifique.", APP_NAME)
						
					Else   
						// verifica se o recurso jah foi apontado.
						If ! ( HoraIApp( cHoraI ,cHoraF ,aAFUItem ,aItens ) .AND. HoraFApp( cHoraI ,cHoraF ,aAFUItem ,aItens ) )
							// valida a quantidade de horas
							If VldHQuant( cHoraI ,cHoraF ,nHQuant )
								// validar se apontamento j� foi feito (FILIAL+PROJETO+REVISAO+TAREFA+RECURSO+HORAINICIAL)
								aAFUItem[SUB_AFU_HORAI]  := cHoraI 
								aAFUItem[SUB_AFU_HORAF]  := cHoraF
								aAFUItem[SUB_AFU_HQUANT] := nHQuant
							  	AFUSave(aAFUItem)
								AFUFill(@aItens)
								
								CloseDialog()

								lReturn := .T.
							EndIf
						Endif
						
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
Return( lReturn )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �VldHoraI  �Autor  �Reynaldo Miyashita  � Data �  18.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � valida o valor informado na hora Inicio                    ���
�������������������������������������������������������������������������͹��
���Parametros� cHora    - Hora Inicio                                     ���
���          � cHoraF   - Hora Final                                      ���
���          � aAFUItem - array de apontamentos AFU                       ���
���          � aItens   - array com os apontamentos                       ���
���          � oGetTime - Objeto de hora Inicio                           ���
���          � oGetQtde - Objeto quantidade de horas                      ���
���          � nSelItem - posicao no array aItens a ser validado          ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VldHoraI(cHora, cHoraF, aAFUItem, aItens, oGetTime, oGetQtde, nSelItem)
	Local lRetorno := .F.
	Local nQtdHora := 0

	Default nSelItem := 0

	If Empty(cHora) .Or. Empty(cHoraF)
		lRetorno := .T.
	Else
		If Empty(aAFUItem[SUB_AFU_RECURS])
			MsgAlert("Recurso n�o informado. Verifique.", APP_NAME)
			lRetorno := .T.	
		Else        
			// ajusta a hora informada
			cHora := AjustaHora( cHora )
			
			// valida a hora
			If VldHora( cHora )
				// verifica se hora inicio eh menor q hora fim
				If Substr(cHora,1,2)+Substr(cHora,4,2) < SubStr(cHoraF,1,2)+Substr(cHoraF,4,2)
					// verifica se j� houve apontamento
					If !HoraIApp(cHora, cHoraF, aAFUItem, aItens, nSelItem)
				
						nQtdHora := PmsHrUtil( aAFUItem[SUB_AFU_FILIAL] ,aAFUItem[SUB_AFU_PROJET] ,aAFUItem[SUB_AFU_RECURS] ,aAFUItem[SUB_AFU_DATA], cHora ,cHoraF ,AE8ItCalen(aAFUItem[SUB_AFU_FILIAL]+aAFUItem[SUB_AFU_RECURS]) )
						
						SetText(oGetTime, cHora)
						SetText(oGetQtde, nQtdHora)
						lRetorno := .T.
					EndIf
				Else
					MsgAlert("Hora Inicial deve ser maior que a Hora Final. Verifique.", APP_NAME)
				EndIf
			
			EndIf
		EndIf
	EndIf
	
Return lRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �VldHoraF  �Autor  �Reynaldo Miyashita  � Data �  18.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � valida o valor informado na hora Final                     ���
�������������������������������������������������������������������������͹��
���Parametros� cHora    - Hora Final                                      ���
���          � cHoraI   - Hora Inicio                                     ���
���          � aAFUItem - array de apontamentos AFU                       ���
���          � aItens   - array com os apontamentos                       ���
���          � oGetTime - Objeto de hora Final                            ���
���          � oGetQtde - Objeto quantidade de horas                      ���
���          � nSelItem - posicao no array aItens a ser validado          ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VldHoraF(cHora, cHoraI, aAFUItem, aItens, oGetTime, oGetQtde, nSelItem)
	Local lRetorno := .F.
	Local nQtdHora := 0

	Default nSelItem := 0

	If Empty(cHora) .Or. empty(cHoraI)
		lRetorno := .T.
	Else
		If Empty(aAFUItem[SUB_AFU_RECURS])
			MsgAlert("Recurso n�o informado. Verifique.", APP_NAME)
			lRetorno := .T.
		Else        
			// ajusta a hora informada
			cHora := AjustaHora(cHora)
			
			// valida a hora
			If VldHora(cHora)
				
				// verifica se hora inicio eh menor q hora fim
				If Substr(cHoraI,1,2)+Substr(cHoraI,4,2) < SubStr(cHora,1,2)+Substr(cHora,4,2)

					// verifica se j� houve apontamento
					If ! HoraFApp(cHoraI, cHora, aAFUItem, aItens, nSelItem)
						nQtdHora := PmsHrUtil(aAFUItem[SUB_AFU_FILIAL], aAFUItem[SUB_AFU_PROJET], aAFUItem[SUB_AFU_RECURS], aAFUItem[SUB_AFU_DATA], cHoraI, cHora, AE8ItCalen(aAFUItem[SUB_AFU_FILIAL]+aAFUItem[SUB_AFU_RECURS]) )
					
						SetText(oGetTime, cHora)
						//Alert("teste")
						//Alert(nQtdHora)
						//Alert("teste2")
						SetText(oGetQtde, nQtdHora)
						lRetorno := .T.
					EndIf
				Else
					MsgAlert("Hora Final n�o pode ser maior que a Hora Inicial. Verifique.", APP_NAME)
				EndIf
			EndIf
		EndIf
	EndIf
Return lRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �VldHQuant �Autor  �Reynaldo Miyashita  � Data �  18.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � valida a qtde de horas informado para o apontamento        ���
�������������������������������������������������������������������������͹��
���Parametros� cHoraI  - Hora Inicio                                      ���
���          � cHoraF  - Hora Final                                       ���
���          � nHQuant - Quantidade de horas                              ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VldHQuant( cHoraI ,cHoraF ,nHQuant )
	Local lRetorno := .T.
	//Alert(nHQuant)
	If ! (empty(cHoraI) .OR. empty(cHoraF))
		If nHQuant > (Val(Substr(cHoraF,1,2)) - Val(Substr(cHoraI,1,2)) + ;
		             (Val(Substr(cHoraF,4,2))/60) - (Val(Substr(cHoraI,4,2)) / 60)) .Or. nHQuant > 24
			lRetorno := .F.
		EndIf
	EndIf
		
Return lRetorno