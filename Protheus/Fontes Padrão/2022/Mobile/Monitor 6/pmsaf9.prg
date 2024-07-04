 #include "_pmspalm.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � palmaf9  �Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotinas para manipulacao do arquivo HAF9                   ���
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
���Funcao    �AF9FillCon�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Le os registros AF9 do banco e preenche um array           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� aTasks - array que sera preenchido com os registros do BD  ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function AF9FillConfir(aTasks)
	Local aTemp := {}

	// aTasks e passada por referencia	
	aTasks := {}
	
	dbSelectArea("AF9")
	dbGoTop()
		
	While !AF9->(EoF())
	    // inclui somente se a tarefa permite confirmacao
		If AF9->AF9_CONFIR != 0
			// inicializa o item
			AF9InitItem(@aTemp)
			
			// projeto, tarefa, data, quantidade, ocorrencia, usuario 
			aTemp[SUB_AF9_FILIAL] := AF9->AF9_FILIAL
			aTemp[SUB_AF9_PROJET] := AF9->AF9_PROJET
			aTemp[SUB_AF9_REVISA] := AF9->AF9_REVISA
			aTemp[SUB_AF9_TAREFA] := AF9->AF9_TAREFA
			              
			aTemp[SUB_AF9_NIVEL ] := AF9->AF9_NIVEL 
			aTemp[SUB_AF9_DESCRI] := AF9->AF9_DESCRI
			aTemp[SUB_AF9_UM    ] := AF9->AF9_UM    
			aTemp[SUB_AF9_QUANT ] := AF9->AF9_QUANT 
			
			aTemp[SUB_AF9_COMPOS] := AF9->AF9_COMPOS
			aTemp[SUB_AF9_EMAIL ] := AF9->AF9_EMAIL 
			aTemp[SUB_AF9_GRPCOM] := AF9->AF9_GRPCOM  
			aTemp[SUB_AF9_ORDEM ] := AF9->AF9_ORDEM
	
			// SUB_AF9_MARK e utilizado no listbox
			aTemp[SUB_AF9_MARK  ] := .F.
	
			// utilizar a funcao aClone()
			aAdd(aTasks, aClone(aTemp))
		EndIf
		
		AF9->(dbSkip())
	End
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AF9FillRec�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Le os registros AF9 do banco e preenche um array           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros� aTasks - array que sera preenchido com os registros do BD  ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function AF9FillRecurs(aTasks)
	Local aTemp := {}

	// aTasks e passada por referencia	
	aTasks := {}
	
	dbSelectArea("AF9")
	dbGoTop()
		
	While !AF9->(EoF())
	    // inclui somente se a tarefa permite apontamento de recurso
		//If AF9->AF9_RECURS != 0
		If AF9->AF9_APTREC != 0
			// inicializa o item
			AF9InitItem(@aTemp)
			
			// projeto, tarefa, data, quantidade, ocorrencia, usuario 
			aTemp[SUB_AF9_FILIAL] := AF9->AF9_FILIAL
			aTemp[SUB_AF9_PROJET] := AF9->AF9_PROJET
			aTemp[SUB_AF9_REVISA] := AF9->AF9_REVISA
			aTemp[SUB_AF9_TAREFA] := AF9->AF9_TAREFA
			
			aTemp[SUB_AF9_NIVEL ] := AF9->AF9_NIVEL 
			aTemp[SUB_AF9_DESCRI] := AF9->AF9_DESCRI
			aTemp[SUB_AF9_UM    ] := AF9->AF9_UM    
			aTemp[SUB_AF9_QUANT ] := AF9->AF9_QUANT 
			
			aTemp[SUB_AF9_COMPOS] := AF9->AF9_COMPOS
			aTemp[SUB_AF9_EMAIL ] := AF9->AF9_EMAIL 
			aTemp[SUB_AF9_GRPCOM] := AF9->AF9_GRPCOM  
			aTemp[SUB_AF9_ORDEM ] := AF9->AF9_ORDEM
	
			// SUB_AF9_MARK e utilizado no listbox
			aTemp[SUB_AF9_MARK  ] := .F.
	
			// utilizar a funcao aClone()
			aAdd(aTasks, aClone(aTemp))
		EndIf
				
		AF9->(dbSkip())
	End
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AF9GetDesc�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Recupera a descricao de todas as tarefas e projetos        ���
���          � do AF9 e AFF                                               ���
�������������������������������������������������������������������������͹��
���Parametros� aProjs - descricao dos projetos                            ���
���          � aTasks - descricao das tarefas                             ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function AF9GetDesc(aProjs, aTasks)
	Local cProject := ""
	
	aTasks := {}
	
	dbSelectArea("AF9")
	dbSetOrder(1)
	dbGoTop()

	While !AF9->(EoF())
		aAdd(aTasks, AF9->AF9_DESCRI)
		
		If cProject # AF9->AF9_PROJET
			aAdd(aProjs, AF9->AF9_PROJET)			
		EndIf
		
		cProject := AF9->AF9_PROJET
		AF9->(dbSkip())
	End
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AF9GetQuan�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Recupera a quantidade de uma determinada tarefa            ���
�������������������������������������������������������������������������͹��
���Parametros� cKey - codigo que identifica unicamente um registro, a ser ���
���          �        pesquisado no AF9.                                  ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function AF9GetQuant(cKey)
	Local nAF9Quant := 0

	If !Empty(cKey)
		dbSelectArea("AF9")
		AF9->(dbSetOrder(1))       //  AF9_FILIAL + AF9_PROJET + AF9_REVISA + AF9_TAREFA

		If AF9->(dbSeek(cKey, .F.))
			nAF9Quant := AF9->AF9_QUANT	
		EndIf
	EndIf
Return nAF9Quant

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AF9ItemDes�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Recupera a descricao de um item do AF9                     ���
�������������������������������������������������������������������������͹��
���Parametros� cKey   - item a ser recuperada a descricao                 ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function AF9ItemDesc(cKey)
	Local cAF9Desc := ""

	If !Empty(cKey)
		dbSelectArea("AF9")
		AF9->(dbSetOrder(1))       //  AF9_FILIAL + AF9_PROJET + AF9_REVISA + AF9_TAREFA

		If AF9->(dbSeek(cKey, .F.))
			cAF9Desc := AF9->AF9_DESCRI
		EndIf
	EndIf
Return cAF9Desc


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �AF9InitIte�Autor  �Adriano Ueda        � Data �  12/16/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Inicializa um array que armazenara um registro do AF9      ���
�������������������������������������������������������������������������͹��
���Parametros� aAF9Item - array onde sera armazenado as informacoes do    ���
���          �            registro do AF9                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function AF9InitItem(aAF9Item)

	// inicializa o item
	aAF9Item := {Nil, Nil, Nil, Nil, Nil, Nil, Nil,;
	             Nil, Nil, Nil, Nil, Nil, Nil, Nil}
Return