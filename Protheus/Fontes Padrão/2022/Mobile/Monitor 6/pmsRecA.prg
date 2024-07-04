#include "eadvpl.ch"
#include "_pmspalm.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �SelRecTsk �Autor  �Reynaldo Miyashit   � Data �  12.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � janela de escolha de tarefa                                ���
�������������������������������������������������������������������������͹��
���Parametros� aAFUItem - Apontamentos a ser validado e salvo             ���
���          � oSayProj - objeto Say no qual sera mostrado o projeto      ���
���          � oSayTask - objeto Say no qual sera mostrada a tarefa       ���
���          � oSayTaskDes - objeto Say no qual sera mostrada descricao da���
���          �               tarefa                                       ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SelRecTsk(aAFUItem, oSayProj, oSayTask, oSayTaskDes)
	Local oDlg    := Nil // janela principal
	Local oMenu   := Nil // menu
	Local oBrowse := Nil // browse
	Local oCol    := Nil // coluna

	// arrays necess�rios para
	// utiliza��o com o browse
	Local aHeader := {}
	Local aTasks  := {}

	Local oBtnOk  := Nil
	Local oBtnCancel := Nil

	Define Dialog oDlg Title APP_NAME
		@ 20, 05 Say "Tarefas" Bold Of oDlg

		@ 40, 05 Say "Selecione a tarefa:" Of oDlg
		
		// carrega as tarefas que podem ser fazer apontamento
		AF9FillRecurs(@aTasks)

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
		
		@ 145, 05 Button oBtnOk     Caption "OK"     Action SelTskOK(@aAFUItem, oBrowse, aTasks, oSayProj, oSayTask, oSayTaskDes) Size 35, 10 Of oDlg
		@ 145, 55 Button oBtnCancel Caption "Cancel" Action ChooseCancel() Size 45, 10 Of oDlg
		
	Activate Dialog oDlg
	
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �SelTskOK  �Autor  �Reynaldo Miyashita  � Data �  12.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � adiciona o codigo do projeto e tarefa para o Apontamento   ���
�������������������������������������������������������������������������͹��
���Parametros� aAFUItem - o apontamento a ser incluido                    ���
���          � oBrowse  - oBrowse que contem a tarefa escolhida           ���
���          � aTasks   - array utilizado para exibir no browse           ���
���          � oSayProj - objeto Say no qual sera mostrada o projeto      ���
���          � oSayTask - objeto Say no qual sera mostrada a tarefa       ���
���          � oSayTaskDes - objeto Say no qual sera mostrada descricao da���
���          �               tarefa                                       ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SelTskOK(aAFUItem, oBrowse, aTasks, oSayProj, oSayTask, oSayTaskDes)
	Local nSelItem := GetOption(oBrowse, aTasks)
	
	CloseDialog()

	If nSelItem > 0
		aAFUItem[SUB_AFU_FILIAL] := aTasks[nSelItem][SUB_AF9_FILIAL]
		aAFUItem[SUB_AFU_PROJET] := aTasks[nSelItem][SUB_AF9_PROJET]
		aAFUItem[SUB_AFU_REVISA] := aTasks[nSelItem][SUB_AF9_REVISA]
		aAFUItem[SUB_AFU_TAREFA] := aTasks[nSelItem][SUB_AF9_TAREFA]
		
		SetText(oSayProj, aAFUItem[SUB_AFU_PROJET])
		SetText(oSayTask, aAFUItem[SUB_AFU_TAREFA])
		SetText(oSayTaskDes, aTasks[nSelItem][SUB_AF9_DESCRI])
	EndIf
	
Return( .T. )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �GetAFUDate�Autor  �Reynaldo Miyashita  � Data �  12.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Atribui a data escolhida no calendario para o apontamento  ���
�������������������������������������������������������������������������͹��
���Parametros� aItem    - array que contem dados da tarefa e recurso para ���
���          �            o apontamento                                   ���
���          � oSayDate - objeto para visualizar a data de apontamento    ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GetAFUDate( aItem ,oSayDate )
	Local dTemp := date()

	If !Empty( aItem[SUB_AFU_DATA] )
		dTemp := aItem[SUB_AFU_DATA] 
	EndIf

	dTemp := SelectDate("Selecione a data...", dTemp)
	
	/*
	deve ser mantida a repeti��o do comando abaixo, pois existe um bug. 
	Que quando a data est� em branco a data selecionada � mostrada parcialmente.
	*/	
	SetText(oSayDate, DToC(dTemp))
	SetText(oSayDate, DToC(dTemp))
	
	aItem[SUB_AFU_DATA]  := dTemp
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �GetAE8Recu�Autor  �Reynaldo Miyashita  � Data �  13.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Atribui o codigo do recurlso para o apontamento            ���
�������������������������������������������������������������������������͹��
���Parametros� aItem    - array que contem dados da tarefa e recurso para ���
���          �            o apontamento                                   ���
���          � oSayRecurso - objeto p/visualizar o codigo do apontamento  ���
���          � oSayRecDescri - objeto p/visualizar a descricao do recurso ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GetAE8Recurs( aAFUItem ,oSayRecurso ,oSayRecDescri ) 
	Local oDlg    := Nil // janela principal
	Local oMenu   := Nil // menu
	Local oBrowse := Nil // browse
	Local oCol    := Nil // coluna

	// arrays necess�rios para
	// utiliza��o com o browse	
	Local aHeader := {}	
	Local aRecursos  := {}

	Local oBtnOk  := Nil
	Local oBtnCancel := Nil

	If Empty(aAFUItem[SUB_AFU_FILIAL]) .AND. ;
	   Empty(aAFUItem[SUB_AFU_PROJET])
		MsgAlert("Informe um projeto.")
	Else
		Define Dialog oDlg Title APP_NAME
			@ 20, 05 Say "Recursos" Bold Of oDlg
	
			@ 40, 05 Say "Selecione o recurso:" Of oDlg
			
			AE8Fill(@aRecursos)
	
			aAdd(aHeader, "Filial")
			aAdd(aHeader, "Recurso")
			aAdd(aHeader, "Descricao")
	
			// mostra browse com as ocorrencias existentes	
			@ 55, 05 Browse oBrowse Size 150, 75 On Click BrwRecClick(oDlg, oBrowse, aRecursos) Of oDlg
			Set Browse oBrowse Array aRecursos
			Add Column oCol To oBrowse Array Element SUB_AE8_RECURS Header aHeader[2] Width  50
			Add Column oCol To oBrowse Array Element SUB_AE8_DESCRI Header aHeader[3] Width 100
			
			@ 145, 05 Button oBtnOk     Caption "OK"     Action SelRecOK(@aAFUItem, oBrowse, aRecursos, oSayRecurso ,oSayRecDescri ) Size 35, 10 Of oDlg
			@ 145, 55 Button oBtnCancel Caption "Cancel" Action ChooseCancel() Size 45, 10 Of oDlg
			
		Activate Dialog oDlg
	EndIf
			
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �BrwRecClic�Autor  �Reynaldo Miyashita  � Data �  13.08.04   ���
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
Function BrwRecClick(oDlg, oBrowse, aItens)
//Local lReturn := .F.
//Return lReturn
Return .F.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �SelRecOK  �Autor  �Reynaldo Miyashita  � Data �  13.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � tratamento do botao OK no browse de selecao de recursos    ���
�������������������������������������������������������������������������͹��
���Parametros� aAFUItem  - array que contem dados da tarefa e recurso para���
���          �            o apontamento                                   ���
���          � oBrowse - objeto browse p/visualizar o recursos            ���
���          � aRecursos - array com os recursos                          ���
���          � oSayRecurso - objeto p/visualizar o codigo do apontamento  ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SelRecOK(aAFUItem, oBrowse, aRecursos ,oSayRecurso ,oSayRecDescri ) 
	Local nSelItem := GetOption(oBrowse, aRecursos)
	Local cDescricao := ""
	
	CloseDialog()

	If nSelItem > 0
		aAFUItem[SUB_AFU_RECURS] := aRecursos[nSelItem][SUB_AE8_RECURS]
		cDescricao := AE8ItemDesc(aAFUItem[SUB_AFU_FILIAL]+aAFUItem[SUB_AFU_RECURS])
		
		//deve ser mantida a repeti��o do comando abaixo, pois existe um bug. 
		//Mostra parcialmente o conteudo que foi atribuido no objeto
		SetText(oSayRecurso   ,aAFUItem[SUB_AFU_RECURS])
		SetText(oSayRecurso   ,aAFUItem[SUB_AFU_RECURS])

		//deve ser mantida a repeti��o do comando abaixo, pois existe um bug. 
		//Mostra parcialmente o conteudo que foi atribuido no objeto
		SetText(oSayRecDescri ,cDescricao )
		SetText(oSayRecDescri ,cDescricao )
		
	EndIf
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DlgAFUExc �Autor  �Reynaldo Miyashita  � Data �  12.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � janela de exclusao do apontamento                          ���
�������������������������������������������������������������������������͹��
���Parametros� aItens   - array de apontamentos (utilizado com o oBrowse  ���
���          � nSelItem - confirmacao escolhida para exclusao             ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DlgAFUExc(aItens, nSelItem)
	Local oDlg         := Nil

	Local oButtonClose := Nil
	Local oBtnCancel   := Nil
	Local oChoose      := Nil
	Local oSayTaskDes  := Nil

	Local aAFUItem     := {}

	aAFUItem := AFUSeek(AFUGetKey(aItens, nSelItem))

	If !Empty(aAFUItem)
		Define Dialog oDlg Title "Exclus�o de Apontamento"

			@  20, 05 Say "Projeto:" Of oDlg 
			@  20, 50 Say aAFUItem[SUB_AFU_PROJET] Of oDlg
			
			@  34, 05 Say "Tarefa:" Of oDlg
			@  34, 50 Say aAFUItem[SUB_AFU_TAREFA] Of oDlg

			@  48, 05 Say "Descri��o:" Of oDlg
			@  48, 50 Say oSayTaskDes Prompt Space(30) Of oDlg
			SetText(oSayTaskDes, AllTrim(AF9ItemDesc(aAFUItem[SUB_AFU_FILIAL] + aAFUItem[SUB_AFU_PROJET] +;
			                             aAFUItem[SUB_AFU_REVISA] + aAFUItem[SUB_AFU_TAREFA])))

			@  64, 05 Button oChoose Caption "Detalhes" Action ShowRecDetail(aAFUItem) Size 50, 10 of oDlg
			
			//@  80, 05 To 80, 155 Of oDlg
			@  80, 05 To 0, 155 Of oDlg

			@  82, 05 Say "Recurso:"      Of oDlg
			@  82, 55 Say aAFUItem[SUB_AFU_RECURS] Of oDlg
	
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
			
			@ 145, 05 Button oButtonClose Caption "OK"     Action AFUExcOk(@aItens, nSelItem) Size 35, 10 Of oDlg
			@ 145, 55 Button oBtnCancel   Caption "Cancel" Action CloseDialog() Size 45, 10 Of oDlg
			
		Activate Dialog oDlg
		
	EndIf
	
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFUExcOK  �Autor  �Reynaldo Miyashita  � Data �  12.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � exclui um apontamento da AFU                               ���
�������������������������������������������������������������������������͹��
���Parametros� aItens   - array de apontamento (utilizado com o oBrowse)  ���
���          � nSelItem - apontamento escolhida para exclusao             ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFUExcOk(aItens, nSelItem)
	AFUMarkDel(AFUGetKey(aItens, nSelItem))
	
	AFUFill(@aItens)
	
	CloseDialog()
	
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DlgAFUChan�Autor  �Reynaldo Miyashita  � Data �  11.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � valida e salva a confirmacao no AFU                        ���
�������������������������������������������������������������������������͹��
���Parametros� aItens   - confirmacao a ser validada e salva              ���
���          � nSelItem - quantidade a ser validada                       ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DlgAFUChange(aItens, nSelItem)
	Local aAFUItem   := {}  // informacoes da confirmacao
	Local cKey       := ""   // chave da confirmacao

	// objetos de interface
	Local oDlg        := Nil // janela principal
	Local oBtnCalen   := Nil // botao - Calendario
	Local oBtnOk      := Nil // botao - Ok
	Local oBtnCancel  := Nil // botao = Cancel
	Local oBtnRecurs  := Nil // botao = Recursos

	Local oSayProj := Nil
	Local oSayTask := Nil
	Local oSayDate := Nil
	Local oSayTaskDes := Nil
	Local oSayRecurso := Nil
	Local oSayRecDescri := Nil

	Local oGetHoraI 	:= NIL 
	Local oGetHoraF 	:= NIL 
	Local oGetHQUANT 	:= NIL 
	Local oChoose     	:= Nil

	// variaveis temporarias
	Local cHoraI   := "" // Hora inicial
	Local cHoraF   := "" // Hora Final
	Local nHQuant  := 0  // Quantidade de Horas
	
	aAFUItem := AFUSeek(AFUGetKey(aItens, nSelItem))

	cKey     := AFUGetKey(aItens, nSelItem)
	cHoraI   := aAFUItem[SUB_AFU_HORAI]
	cHoraF   := aAFUItem[SUB_AFU_HORAF]
	nHQuant  := aAFUItem[SUB_AFU_HQUANT]

	Define Dialog oDlg Title "Altera��o de Apontamento" //APP_NAME		
		
		// -------------------------------------------------------------------

		@  20, 05 Say "Projeto:" Of oDlg 
		@  20, 50 Say aAFUItem[SUB_AFU_PROJET] Of oDlg
		
		@  34, 05 Say "Tarefa:" Of oDlg 
		@  34, 50 Say aAFUItem[SUB_AFU_TAREFA] Of oDlg
		
		@  48, 05 Say "Descri��o:" Of oDlg 
		@  48, 50 Say oSayTaskDes Prompt Space(30) Of oDlg
		SetText(oSayTaskDes, AllTrim(AF9ItemDesc(aAFUItem[SUB_AFU_FILIAL] + aAFUItem[SUB_AFU_PROJET] +;
		                                         aAFUItem[SUB_AFU_REVISA] + aAFUItem[SUB_AFU_TAREFA])))
		                                         
		@  64, 05 Button oChoose Caption "Detalhes" Action ShowRecDetail(aAFUItem) Size 50, 10 of oDlg

		//@  80, 05 To 80, 155 Of oDlg
		@  80, 05 To 0, 155 Of oDlg

		@  82, 05 Say "Recurso:" Of oDlg
		@  82, 55 Say oSayRecurso Prompt aAFUItem[SUB_AFU_RECURS] Of oDlg
//		@  84,120 Button oBtnRecurs Caption "..." Action GetAE8Recurs( @aAFUItem ,oSayRecurso ,oSayRecDescri )  Size 15, 08 Of oDlg

		@  94, 05 Say "Descri��o:" Of oDlg      
		@  94, 55 Say oSayRecDescri Prompt AE8ItemDesc(aAFUItem[SUB_AFU_FILIAL]+aAFUItem[SUB_AFU_RECURS]) Of oDlg
	
		@ 106, 05 Say "Data:" Of oDlg
		@ 106, 55 Say oSayDate Prompt DToC(aAFUItem[SUB_AFU_DATA]) Of oDlg
//		@ 108, 105 Button oBtnCalen Caption "..." Action GetAFUDate( @aAFUItem ,oSayDate ) Size 15, 08 Of oDlg

		@ 118, 05 Say "Hora Inicial:" of oDlg
		@ 118, 55 Get oGetHoraI Var cHoraI Picture "@R 99:99" Valid VldHoraI( cHoraI ,cHoraF ,aAFUItem ,aItens ,oGetHoraI ,oGetHQUANT ,nSelItem ) Of oDlg

		@ 118, 85 Say "Hora Final:"    Of oDlg
		@ 118,130 Get oGetHoraF Var cHoraF Picture "@R 99:99" Valid VldHoraF( cHoraF ,cHoraI ,aAFUItem ,aItens ,oGetHoraF ,oGetHQUANT ,nSelItem ) Of oDlg
		
		@ 130, 05 Say "Qtde.Horas:"    Of oDlg
		@ 130, 55 Get oGetHQUANT Var nHQuant Picture "@E 999,999,999.99" Valid VldHQuant( cHoraI ,cHoraF ,nHQuant ) Of oDlg

		//@ 142, 05 To 142, 155 Of oDlg
		@ 142, 05 To 0, 155 Of oDlg

		@ 146, 05 Button oBtnOk     Caption "OK"     Action VldAFUUpd( cKey ,cHoraI ,cHoraF ,nHQuant ,aAFUItem ,@aItens ,nSelItem ) Size 35, 10 Of oDlg
		@ 146, 55 Button oBtnCancel Caption "Cancel" Action CloseDialog() Size 45, 10 Of oDlg
		
	Activate Dialog oDlg
	
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �VldAFUUpd�Autor  �Reynaldo Miyashita  � Data �  12.08.04    ���
�������������������������������������������������������������������������͹��
���Desc.     � valida e altera o apontamento no AFU                       ���
�������������������������������������������������������������������������͹��
���Parametros� cKey     - Chave para pesquisa do registro para alteracao  ���
���          � cHoraI   - Hora inicial do apontamento                     ���
���          � cHoraF   - Hora Final do apontamento                       ���
���          � nHQuant  - Quantidade de horas do apontamento              ���
���          � aAFUItem - Apontamento a ser validada e salva              ���
���          � aItens   - Array com os Apontamentos                       ���
���          � nSelItem - posicao no array aItens do apontamento a ser    ���
���          �            alterado                                        ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VldAFUUpd( cKey ,cHoraI ,cHoraF ,nHQuant ,aAFUItem ,aItens ,nSelItem )
	Local lReturn := .F.

	Default nSelItem := 0

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
					If Substr(cHoraF,1,2) + Substr(cHoraF,4,2) < Substr(cHoraI,1,2) + Substr(cHoraI,4,2)
						MsgAlert("Hora Final n�o pode ser maior que a Hora Inicial. Verifique.", APP_NAME)
					Else						
					    // verifica se o recurso jah foi apontado.
						If ! ( HoraIApp( cHoraI ,cHoraF ,aAFUItem ,aItens ,nSelItem ) .AND. HoraFApp( cHoraI ,cHoraF ,aAFUItem ,aItens ,nSelItem ) )
							// valida a quantidade de horas
							If VldHQuant( cHoraI ,cHoraF ,nHQuant )
								// validar se apontamento j� foi feito (FILIAL+PROJETO+REVISAO+TAREFA+RECURSO+HORAINICIAL)
								aAFUItem[SUB_AFU_HORAI]  := cHoraI 
								aAFUItem[SUB_AFU_HORAF]  := cHoraF
								aAFUItem[SUB_AFU_HQUANT] := nHQuant
		
							  	AFUChange( cKey, aAFUItem, aItens)
						
								CloseDialog()
						
								lReturn := .T.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
Return lReturn