#include "eadvpl.ch"
#include "_pmspalm.ch"
#include "pmspalmb.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �OpenTable �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � abre um arquivo de banco de dados e cria um alias          ���
�������������������������������������������������������������������������͹��
���Parametros� cFile     - nome do arquivo a ser aberto                   ���
���          � cAlias    - alias a ser associado com o arquivo            ���
���          � lShared   - abre o arquivo compartilhado/exclusivo         ���
���          � lReadOnly - abre o arquivo somente                         ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OpenTable(cFile, cAlias, lShared, lReadOnly)
	Local lReturn := .F.
	
	Default lShared   := UA_SHARED
	Default lReadOnly := UA_READWRITE

	If !File(AllTrim(cFile))
		lReturn := .F.
	Else
		lReturn := dbUseArea(.T., "LOCAL", cFile, cAlias, lShared, lReadOnly)
	EndIf
Return lReturn


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �GetIndexes�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � retorna todos os indices de um alias especificado          ���
�������������������������������������������������������������������������͹��
���Parametros� aIndexes - array a ser preenchido com os indices           ���
���          � cAlias   - alias a ser recuperado os indices               ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GetIndexes(aIndexes, cAlias)
	Local lReturn := .T.
	Local aBuffer   := {}

	aIndexes := {}
	
	dbSelectArea("ADVIND")
	ADVIND->(dbSetOrder(2))
	ADVIND->(dbGotop())
	
	While !ADVIND->(Eof())
		If Trim(ADVIND->TBLNAME)==Trim(cAlias)
			aBuffer := {}
	
			aAdd(aBuffer, ADVIND->TBLNAME)
			aAdd(aBuffer, AllTrim(ADVIND->NOME_IDX))
			aAdd(aBuffer, ADVIND->EXPRE)
			
			aAdd(aIndexes, aClone(aBuffer))
		EndIf
		ADVIND->(dbSkip())
	End
Return lReturn


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �IsSel     �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � exclui uma confirmacao do AFF                              ���
�������������������������������������������������������������������������͹��
���Parametros� oBrowse  - contem o oBrowse a ser validado                 ���
���          � aItems   - confirmacao escolhida para exclusao             ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function IsSel(oBrowse, aItems)
	Local nSelItem := 0
	Local lReturn  := .F.

	If Len(aItems) == 0
		nSelItem := 0
	Else
		nSelItem := GridRow(oBrowse)
	EndIf
	
	If nSelItem == 0
		lReturn := .F.
	Else
		lReturn := .T.
	EndIf		
Return lReturn


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �GetOption �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � retorna o item selecionado no oBrowse                      ���
�������������������������������������������������������������������������͹��
���Parametros� oBrowse  - oBrowse que se quer descobrir o selecionado     ���
���          � aItems   - array de confirmacaoes utilizadas com o oBrowse ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GetOption(oBrowse, aItems)
	Local nSelItem := 0

	If Len(aItems) == 0
		nSelItem := 0
	Else
		nSelItem := GridRow(oBrowse)
	EndIf
Return nSelItem


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ChooseCanc�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � cancela a escolha de uma tarefa                            ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ChooseCancel()
	CloseDialog()
Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CalcPerTas�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � calcula a quantidade da tarefa em porcentagem              ���
�������������������������������������������������������������������������͹��
���Parametros� nQuantTotal - quantidade tarefa                            ���
���          � nSelItem - confirmacao escolhida para exclusao             ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CalcPerTask(nQuantTotal, nQuant)
Return (100 * nQuant) / nQuantTotal


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CalcQtdTas�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � calcula a quantidade da tarefa                             ���
�������������������������������������������������������������������������͹��
���Parametros� nQuantTotal - quantidade tarefa                            ���
���          � nPerQuant   - confirmacao escolhida para exclusao          ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CalcQtdTask(nQuantTotal, nPerQuant)
Return (nQuantTotal * nPerQuant) / 100


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �InitSyncc �Autor  �Adriano Ueda        � Data �  20/02/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � funcao para executar a sincronizaco com o MCS              ���
�������������������������������������������������������������������������͹��
���Parametros� nenhum                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function InitSync()
	Local aPMSTables  := {}     // tabelas utilizadas
	Local aPMSIndexes := {}     // indices utilizados
	
	Local i := 0
	Local j := 0
	
	Local cFile := ""
	Local cExp  := ""

	// fecha os arquivos
	dbCloseAll()

	// executa a sincronizacao
	DoSync()
  
	// abre o arquivo de indice
	If !OpenTable("ADV_IND", "ADVIND", .F., .T.)
		DoSync()
		//MsgAlert("N�o foi poss�vel abrir o arquivo ADV_IND.")
		Return Nil
	EndIf
	
	dbCreateIndex(AllTrim(ADVIND->NOME_IDX), AllTrim(ADVIND->EXPRE),)

	// adicione na rotina as
	// tabelas a serem abertas
	aPMSTables := TableLoad()	
	
	For i := 1 To Len(aPMSTables)
		If !OpenTable(aPMSTables[i][PMS_TABLE], aPMSTables[i][PMS_ALIAS])
			MsgAlert(STR0001 + aPMSTables[i][PMS_TABLE]) //"N�o foi poss�vel abrir a tabela "
			
			// TODO
			// executar uma operacao de log
			// END TODO			
		Else
			MsgStatus(STR0002 + aPMSTables[i][PMS_TABLE] + "...") //"Abrindo "

			// TODO
			// executar uma operacao de log
			// END TODO
			
			GetIndexes(aPMSIndexes, aPMSTables[i][PMS_TABLE])
		
			For j := 1 To Len(aPMSIndexes)
				cFile := aPMSIndexes[j][PMS_IDX_FILENAME]
				cExp  := aPMSIndexes[j][PMS_IDX_EXP]

				If !File(cFile)
					MsgStatus(STR0003 + cFile + "...") //"Criando "

					// TODO
					// executar uma operacao de log
					// END TODO
					
					dbSelectArea(aPMSTables[i][PMS_ALIAS])
					dbCreateIndex(cFile, cExp)
				Else
					MsgStatus(STR0004 + cFile + "...") //"Reindexando "

					// TODO
					// executar uma operacao de log
					// END TODO
					
					dbSelectArea(aPMSTables[i][PMS_ALIAS])
					dbSetIndex(cFile)
				EndIf
			Next 
		EndIf
	Next 

	// limpa a mensagem de status
	ClearStatus()
Return .T.