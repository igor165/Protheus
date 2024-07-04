#include "eadvpl.ch"
#include "_pmspalm.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � palmaff  �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotinas para manipulacao do arquivo HAFF                   ���
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
���Funcao    �AFFFill   �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Le os registros AFF do banco e preenche um array           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� aItems - array que sera preenchido com os registros do BD  ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function AFFFill(aItems)
	Local aTemp     := {}
	Local nPerQuant := 0
	
	aItems := {}
	nSyncID := 0
	
	dbSelectArea("AFF")
	dbGoTop()

	nSyncID := Val(AFF->AFF_SYNCID)
	
	While !AFF->(EoF())
		
		// preenche o array apenas com as confirmacoes
		// nao excluidas
		If AFF->AFF_SYNCFL <> "E"
			AFFInitItem(@aTemp)
	
			nPerQuant := CalcPerTask(AF9GetQuant(AFF->AFF_FILIAL + AFF->AFF_PROJET + AFF->AFF_REVISA + AFF->AFF_TAREFA),;
			                                     AFF->AFF_QUANT)
	
			// projeto, tarefa, data, quantidade, ocorrencia, usuario 
			aTemp[SUB_AFF_FILIAL] := AFF->AFF_FILIAL
			aTemp[SUB_AFF_PROJET] := AFF->AFF_PROJET
			aTemp[SUB_AFF_REVISA] := AFF->AFF_REVISA
			aTemp[SUB_AFF_TAREFA] := AFF->AFF_TAREFA
			
			aTemp[SUB_AFF_DATA]   := CToD(AFF->AFF_DATA)
			aTemp[SUB_AFF_QUANT]  := AFF->AFF_QUANT
			aTemp[SUB_AFF_OCORRE] := AFF->AFF_OCORRE
			aTemp[SUB_AFF_CODMEM] := AFF->AFF_CODMEM
			
			aTemp[SUB_AFF_USER]   := AFF->AFF_USER
			aTemp[SUB_AFF_CONFIR] := AFF->AFF_CONFIR
			aTemp[SUB_AFF_SYNCID] := AFF->AFF_SYNCID
			aTemp[SUB_AFF_SYNCFL] := AFF->AFF_SYNCFL
			
			aTemp[SUB_AFF_PERC]   := nPerQuant
			
			// utilizar a funcao aClone()
			aAdd(aItems, aClone(aTemp))
		EndIf    

		If Val(AFF->AFF_SYNCID) > nSyncID
			nSyncID := Val(AFF->AFF_SYNCID)
		EndIf

		AFF->(dbSkip())
	End
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFFSave   �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Salva um registro no AFF a partir de um array              ���
�������������������������������������������������������������������������͹��
���Parametros� aAFFItem - array que contem os valores a serem salvos no   ���
���          �            AFF                                             ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFFSave(aAFFItem)
	dbSelectArea("AFF")
	dbGoBottom()
	Append Blank
	
	AFF->AFF_FILIAL := aAFFItem[SUB_AFF_FILIAL]
	AFF->AFF_PROJET := aAFFItem[SUB_AFF_PROJET]
	AFF->AFF_REVISA := aAFFItem[SUB_AFF_REVISA]
	AFF->AFF_DATA   := DToC(aAFFItem[SUB_AFF_DATA])
	AFF->AFF_TAREFA := aAFFItem[SUB_AFF_TAREFA]
	AFF->AFF_QUANT  := aAFFItem[SUB_AFF_QUANT]
	AFF->AFF_OCORRE := ""
	AFF->AFF_CODMEM := ""
	AFF->AFF_USER   := ""
	AFF->AFF_CONFIR := aAFFItem[SUB_AFF_CONFIR]
	AFF->AFF_SYNCFL := "N"
	
	nSyncID++
	AFF->AFF_SYNCID := AllTrim(Str(nSyncID))
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFFInitIte�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Salva um registro no AFF a partir de um array              ���
�������������������������������������������������������������������������͹��
���Parametros� aAFFItem - array que contem os valores a serem salvos no   ���
���          �            AFF                                             ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFFInitItem(aAFFItem)
	aAFFItem := {Nil, Nil, Nil, Nil, Nil, Nil,;
	             Nil, Nil, Nil, Nil, Nil, Nil,;
	             Nil}
	
	aAFFItem[SUB_AFF_FILIAL] := ""
	aAFFItem[SUB_AFF_PROJET] := ""
	aAFFItem[SUB_AFF_REVISA] := ""
	aAFFItem[SUB_AFF_TAREFA] := ""
	
	aAFFItem[SUB_AFF_DATA]   := Date()
	aAFFItem[SUB_AFF_QUANT]  := 0
	aAFFItem[SUB_AFF_OCORRE] := ""
	aAFFItem[SUB_AFF_CODMEM] := ""
	
	aAFFItem[SUB_AFF_USER]   := ""
	aAFFItem[SUB_AFF_CONFIR] := AUT_ENTREGA_NAO
	aAFFItem[SUB_AFF_SYNCID] := ""
	aAFFItem[SUB_AFF_SYNCFL] := ""
	
Return( .T. )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFFSetStat�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Seta o status de um registro no AFF                        ���
�������������������������������������������������������������������������͹��
���Parametros� cKey     - chave para busca do registro do AFF             ���
���          � cStatus  - status do registro                              ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFFSetStatus(cKey, cStatus)
	Local lReturn := .F.

	If !Empty(cKey)
		dbSelectArea("AFF")
		dbSetOrder(1)
		lReturn := AFF->(dbSeek(cKey))
	
		If lReturn
			AFF->AFF_SYNCFL := cStatus
		EndIf
	EndIf
Return lReturn


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFFSeek   �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Procura um determinado registro no AFF                     ���
�������������������������������������������������������������������������͹��
���Parametros� cKey     - chave para busca do registro do AFF             ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function AFFSeek(cKey)
	Local lReturn := .F.
	Local aTemp := {}
	Local nPerQuant := 0
	
	If !Empty(cKey)
		dbSelectArea("AFF")
		dbSetOrder(1)
		lReturn := AFF->(dbSeek(cKey))
	
		If lReturn
			AFFInitItem(@aTemp)
			
			nPerQuant := CalcPerTask(AF9GetQuant(AFF->AFF_FILIAL + AFF->AFF_PROJET + AFF->AFF_REVISA + AFF->AFF_TAREFA),;
			            AFF->AFF_QUANT)
	
			// projeto, tarefa, data, quantidade, ocorrencia, usuario
			aTemp[SUB_AFF_FILIAL] := AFF->AFF_FILIAL
			aTemp[SUB_AFF_PROJET] := AFF->AFF_PROJET
			aTemp[SUB_AFF_REVISA] := AFF->AFF_REVISA
			aTemp[SUB_AFF_TAREFA] := AFF->AFF_TAREFA
			aTemp[SUB_AFF_DATA]   := CToD(AFF->AFF_DATA)
			aTemp[SUB_AFF_QUANT]  := AFF->AFF_QUANT
			aTemp[SUB_AFF_OCORRE] := AFF->AFF_OCORRE
			aTemp[SUB_AFF_CODMEM] := AFF->AFF_CODMEM
			aTemp[SUB_AFF_USER]   := AFF->AFF_USER
			aTemp[SUB_AFF_CONFIR] := AFF->AFF_CONFIR
			aTemp[SUB_AFF_SYNCID] := AFF->AFF_SYNCID
			aTemp[SUB_AFF_SYNCFL] := AFF->AFF_SYNCFL
			aTemp[SUB_AFF_PERC]   := nPerQuant
		EndIf
	EndIf
Return aTemp


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFFGetKey �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna a chave de um item selecionado no browse           ���
�������������������������������������������������������������������������͹��
���Parametros� aItems - array que contem os registro do AFF               ���
���          � nSelItem - item selecionado no browse                      ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFFGetKey(aItems, nSelItem)
Return aItems[nSelItem][SUB_AFF_SYNCID]


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFFChangeW�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � salva as alteracoes em um registro no AFF                  ���
�������������������������������������������������������������������������͹��
���Parametros� cKey     - chave para busca do registro do AFF             ���
���          � aAFFItem - array que contem o registro a ser gravado       ���
���          � aItems   - array que contem os registros do AFF            ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFFChangeWrite(cKey, aAFFItem, aItems)
	Local lReturn := .F.

	If !Empty(cKey)	
		dbSelectArea("AFF")
		dbSetOrder(1)
		lReturn := AFF->(dbSeek(cKey))
	
		If lReturn
			AFF->AFF_FILIAL := aAFFItem[SUB_AFF_FILIAL]
			AFF->AFF_PROJET := aAFFItem[SUB_AFF_PROJET]
			AFF->AFF_REVISA := aAFFItem[SUB_AFF_REVISA]
			AFF->AFF_DATA   := DToC(aAFFItem[SUB_AFF_DATA])
			AFF->AFF_TAREFA := aAFFItem[SUB_AFF_TAREFA]
			AFF->AFF_QUANT  := aAFFItem[SUB_AFF_QUANT]
			AFF->AFF_OCORRE := ""
			AFF->AFF_CODMEM := ""
			AFF->AFF_USER   := aAFFItem[SUB_AFF_USER]
			AFF->AFF_CONFIR := aAFFItem[SUB_AFF_CONFIR]

			// se o flag == "N",
			// entao o registro existe apenas
			// no Palm, e nao deve ser marcado
			// com alteracao
			
			If AllTrim(AFF->AFF_SYNCFL) == ""
				AFF->AFF_SYNCFL := "A"
			EndIf
		EndIf
	
		AFFFill(@aItems)
	EndIf
				
	CloseDialog()
Return lReturn


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFFMarkDel�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Altera o status do registro no AFF para exclusao pelo job  ���
�������������������������������������������������������������������������͹��
���Parametros� cKey - identificador do registro no AFF                    ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFFMarkDel(cKey)
Return AFFSetStatus(cKey, "E")


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFFDelete �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Deleta um registro no AFF                                  ���
�������������������������������������������������������������������������͹��
���Parametros� cKey - identificador do registro no AFF                    ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFFDelete(cKey)
	Local lReturn := .F.
	
	dbSelectArea("AFF")
	dbSetOrder(1)
	lReturn := AFF->(dbSeek(cKey))
	
	If lReturn
		AFF->(dbDelete())
	EndIf
Return lReturn


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFFSetAE  �Autor  �Adriano Ueda        � Data �  03/02/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Seta a indicacao de geracao de Autorizacao de Entrega      ���
�������������������������������������������������������������������������͹��
���Parametros� aAFFItem - confirmacao (AFF) a ser setada (passada por ref)���
���          � lCheck   - indica se sera gera uma confirmacao de entrega  ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFFSetAE(aAFFItem, lCheck)
	If lCheck
		aAFFItem[SUB_AFF_CONFIR] := AUT_ENTREGA_SIM
	Else
		aAFFItem[SUB_AFF_CONFIR] := AUT_ENTREGA_NAO
	EndIf
Return lCheck


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AFFGetStat�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Recupera o status de um registro no AFF                    ���
�������������������������������������������������������������������������͹��
���Parametros� cKey - chave do registro do AFF                            ���
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
Function AFFGetStatus(cKey)
	Local cReturn := ""

	If !Empty(cKey)
		dbSelectArea("AFF")
		dbSetOrder(1)
		If AFF->(dbSeek(cKey))
			cReturn := AllTrim(AFF->AFF_SYNCFL)
		EndIf
	EndIf
	
Return cReturn