#include "eadvpl.ch"
#include "_pmspalm.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PalmAFU  �Autor  �Reynaldo Miyashita  � Data �  09.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotinas para manipulacao do arquivo HAFU                   ���
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
���Funcao    �AFUFill   �Autor  �Reynaldo Miyashita  � Data �  09.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Le os registros AFU do banco e preenche um array           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� aItems - array que sera preenchido com os registros do BD  ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFUFill(aItems)
	Local aTemp := {}
	Local nPerQuant := 0

	aItems := {}
	nSyncID := 0
	
	dbSelectArea("AFU")
	dbGoTop()

	nSyncID := Val(AFU->AFU_SYNCID)
	
	While !AFU->(EoF())
		
		// preenche o array apenas com o apontamento de recursos
		// nao excluidos
		If AFU->AFU_SYNCFL <> "E"
			AFUInitItem(@aTemp)

			// projeto, tarefa, recurso, data inicio, data fim , horas apontadas
			aTemp[SUB_AFU_FILIAL] := AFU->AFU_FILIAL
			aTemp[SUB_AFU_PROJET] := AFU->AFU_PROJET
			aTemp[SUB_AFU_REVISA] := AFU->AFU_REVISA
			aTemp[SUB_AFU_TAREFA] := AFU->AFU_TAREFA
			aTemp[SUB_AFU_RECURS] := AFU->AFU_RECURS
			aTemp[SUB_AFU_DATA]   := CToD(AFU->AFU_DATA)
			aTemp[SUB_AFU_HORAI]  := AFU->AFU_HORAI
			aTemp[SUB_AFU_HORAF]  := AFU->AFU_HORAF
			aTemp[SUB_AFU_HQUANT] := AFU->AFU_HQUANT
			aTemp[SUB_AFU_SYNCID] := AFU->AFU_SYNCID
			aTemp[SUB_AFU_SYNCFL] := AFU->AFU_SYNCFL
			
			// utilizar a funcao aClone()
			aAdd(aItems, aClone(aTemp))
		EndIf

		If Val(AFU->AFU_SYNCID) > nSyncID
			nSyncID := Val(AFU->AFU_SYNCID)
		EndIf
		
		AFU->(dbSkip())
	End
Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFUSave   �Autor  �Reynaldo Miyashita  � Data �  09.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Salva um registro na tabela AFU a partir de um array       ���
�������������������������������������������������������������������������͹��
���Parametros� aAFUItem - array que contem os valores a serem salvos no   ���
���          �            AFU                                             ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFUSave(aAFUItem)
	dbSelectArea("AFU")
	dbGoBottom()
	dbAppend()

	AFU->AFU_FILIAL := aAFUItem[SUB_AFU_FILIAL]
	AFU->AFU_PROJET := aAFUItem[SUB_AFU_PROJET]
	AFU->AFU_REVISA := aAFUItem[SUB_AFU_REVISA]
	AFU->AFU_DATA   := DToC(aAFUItem[SUB_AFU_DATA])
	AFU->AFU_TAREFA := aAFUItem[SUB_AFU_TAREFA]
	AFU->AFU_RECURS := aAFUItem[SUB_AFU_RECURS]
	AFU->AFU_HORAI  := aAFUItem[SUB_AFU_HORAI]
	AFU->AFU_HORAF  := aAFUItem[SUB_AFU_HORAF]
	AFU->AFU_HQUANT := aAFUItem[SUB_AFU_HQUANT]

	AFU->AFU_SYNCFL := "N"

	nSyncID++
	AFU->AFU_SYNCID := AllTrim(Str(nSyncID))
Return .T.


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Funcao    �AFUInitItem �Autor  �Reynaldo Miyashita  � Data �  09.08.04   ���
���������������������������������������������������������������������������͹��
���Desc.     � Salva um registro na tabela AFU a partir de um array         ���
���������������������������������������������������������������������������͹��
���Parametros� aAFUItem - array que contem os valores a serem salvos no     ���
���          �            AFU                                               ���
���������������������������������������������������������������������������͹��
���Uso       � Palm                                                         ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function AFUInitItem(aAFUItem)

	aAFUItem := Array(11)
	
	aAFUItem[SUB_AFU_FILIAL] := ""
	aAFUItem[SUB_AFU_PROJET] := ""
	aAFUItem[SUB_AFU_REVISA] := ""
	aAFUItem[SUB_AFU_TAREFA] := ""
	aAFUItem[SUB_AFU_RECURS] := ""
	aAFUItem[SUB_AFU_DATA]   := CToD("  /  /  ")
	aAFUItem[SUB_AFU_HORAI]  := ""
	aAFUItem[SUB_AFU_HORAF]  := ""
	aAFUItem[SUB_AFU_HQUANT] := 0
	aAFUItem[SUB_AFU_SYNCID] := ""
	aAFUItem[SUB_AFU_SYNCFL] := ""
	
Return( .T. )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFUSetStat�Autor  �Reynaldo Miyashita  � Data �  09.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Seta o status de um registro na tabela AFU                 ���
�������������������������������������������������������������������������͹��
���Parametros� cKey     - chave para busca do registro do AFU             ���
���          � nSelItem - item selecionado no browse                      ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFUSetStatus(cKey, cStatus)
	Local lReturn := .F.

	If !Empty(cKey)
		dbSelectArea("AFU")
		dbSetOrder(1)
		lReturn := AFU->(dbSeek(cKey))
	
		If lReturn
			AFU->AFU_SYNCFL := cStatus
		EndIf
	EndIf
Return lReturn


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFUSeek   �Autor  �Reynaldo Miyashita  � Data �  09.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Procura um determinado registro na tabela AFU              ���
�������������������������������������������������������������������������͹��
���Parametros� cKey     - chave para busca do registro do AFU             ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFUSeek(cKey)
	Local lReturn := .F.
	Local aTemp := {}

	If !Empty(cKey)
		dbSelectArea("AFU")
		dbSetOrder(1)
		lReturn := AFU->(dbSeek(cKey))
	
		If lReturn
			AFUInitItem(@aTemp)
			
			// projeto, tarefa, recurso, data inicio, data fim, horas apontadas
			aTemp[SUB_AFU_FILIAL] := AFU->AFU_FILIAL
			aTemp[SUB_AFU_PROJET] := AFU->AFU_PROJET
			aTemp[SUB_AFU_REVISA] := AFU->AFU_REVISA
			aTemp[SUB_AFU_TAREFA] := AFU->AFU_TAREFA
			
			aTemp[SUB_AFU_RECURS] := AFU->AFU_RECURS
			aTemp[SUB_AFU_DATA]   := CToD(AFU->AFU_DATA)
			aTemp[SUB_AFU_HORAI]  := AFU->AFU_HORAI
			aTemp[SUB_AFU_HORAF]  := AFU->AFU_HORAF
			aTemp[SUB_AFU_HQUANT] := AFU->AFU_HQUANT
			aTemp[SUB_AFU_SYNCID] := AFU->AFU_SYNCID
			aTemp[SUB_AFU_SYNCFL] := AFU->AFU_SYNCFL
		EndIf
	EndIf
Return aTemp


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFUGetKey �Autor  �Reynaldo Miyashita  � Data �  09.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna a chave de um item selecionado no browse           ���
�������������������������������������������������������������������������͹��
���Parametros� aItems - array que contem os registro do AFU               ���
���          � nSelItem - item selecionado no browse                      ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFUGetKey(aItems, nSelItem)
Return aItems[nSelItem][SUB_AFU_SYNCID]


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFUChange �Autor  �Reynaldo Miyashita  � Data �  09.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � salva as alteracoes em um registro no AFU                  ���
�������������������������������������������������������������������������͹��
���Parametros� aItems - array que contem os registro do AFU               ���
���          � nSelItem - item selecionado no banco dados                 ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFUChange( cKey, aAFUItem, aItems)
	Local lReturn := .F.

	If !Empty(cKey)
		dbSelectArea("AFU")
		dbSetOrder(1)
		lReturn := AFU->(dbSeek(cKey))
	
		If lReturn
			AFU->AFU_FILIAL := aAFUItem[SUB_AFU_FILIAL] 
			AFU->AFU_PROJET := aAFUItem[SUB_AFU_PROJET]
			AFU->AFU_REVISA := aAFUItem[SUB_AFU_REVISA]
			AFU->AFU_DATA   := DToC(aAFUItem[SUB_AFU_DATA])
			AFU->AFU_TAREFA := aAFUItem[SUB_AFU_TAREFA]
			AFU->AFU_RECURS := aAFUItem[SUB_AFU_RECURS]
			AFU->AFU_HORAI  := aAFUItem[SUB_AFU_HORAI] 
			AFU->AFU_HORAF  := aAFUItem[SUB_AFU_HORAF]
			AFU->AFU_HQUANT := aAFUItem[SUB_AFU_HQUANT]
		
			// se o flag == "N",
			// entao o registro existe apenas
			// no Palm, e nao deve ser marcado
			// com alteracao
			
			If AllTrim(AFU->AFU_SYNCFL) == ""
				AFU->AFU_SYNCFL := "A"
			EndIf
		EndIf
	
		AFUFill(@aItems)
	EndIf
	
Return lReturn


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFUMarkDel�Autor  �Reynaldo Miyashita  � Data �  09.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Altera o status do registro no AFU para exclusao pelo job  ���
�������������������������������������������������������������������������͹��
���Parametros� cKey - identificador do registro no AFU                    ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFUMarkDel(cKey)
Return AFUSetStatus(cKey, "E")


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFUDelete �Autor  �Reynaldo Miyashita  � Data �  09.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Deleta um registro no AFU                                  ���
�������������������������������������������������������������������������͹��
���Parametros� cKey - identificador do registro no AFU                    ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFUDelete(cKey)
	Local lReturn := .F.
	
	dbSelectArea("AFU")
	dbSetOrder(1)
	lReturn := AFU->(dbSeek(cKey))
	
	If lReturn 
		AFU->(dbDelete())
	EndIf
	
Return lReturn

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFUGetStat�Autor  �Reynaldo Miyashita  � Data �  09.08.04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Recupera o status de um registro no AFU                    ���
�������������������������������������������������������������������������͹��
���Parametros� cKey - chave do registro do AFU                            ���
�������������������������������������������������������������������������͹��
���Retorno   � E - registro excluido                                      ���
���          � A - registro alterado                                      ���
���          � N - registro incluido                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFUGetStatus(cKey)
	Local cReturn := ""

	If !Empty(cKey)
		dbSelectArea("AFU")
		dbSetOrder(1)
		If AFU->(dbSeek(cKey))
			cReturn := AllTrim(AFU->AFU_SYNCFL)
		EndIf
	EndIf
	
Return cReturn