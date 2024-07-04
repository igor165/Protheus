/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ISSNET    �Autor  �Microsiga           � Data �  27/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para processamento do livro fiscal de ISS onde ar-   ���
���          � mazenas as informacoes em um arquivo trabalho para poste-  ���
���          � riores leituras no .INI                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ISSNET (aTrbs)
Local	lProcessa	:=	.T.
Local	nX			:=	0
Local	cDbf		:=	"F3_FILIAL='"+xFilial ("SF3")+"' .AND. DToS (F3_ENTRADA)>='"+DToS (MV_PAR01)+"' .AND. DToS (F3_ENTRADA)<='"+DToS (MV_PAR02)+"' .AND. F3_TIPO=='S' .AND. SUBSTRING (F3_CFO,1,1)<'5' "
Local	cTop		:=	"F3_FILIAL='"+xFilial ("SF3")+"' AND F3_ENTRADA>='"+DToS (MV_PAR01)+"' AND F3_ENTRADA<='"+DToS (MV_PAR02)+"' AND F3_TIPO='S' AND SUBSTRING (F3_CFO,1,1)<'5' "
Local	aSF3		:=	{"SF3", ""}
Local	bBxCanc 	:= 	{||!SE5->(Eof ()) .And. xFilial ("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO==xFilial ("SE5")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO .And. TemBxCanc(SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_SEQ)}
Local	bRetDatP	:=	{|| Iif (xFilial ("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO==xFilial ("SE5")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO, SE5->E5_DATA, CToD ("  /  /  "))}
Local   cCampo      := GetMv("MV_IMA2")
Local	cRecIss		:=	""  
Local   cInscr      := ""
Local 	cMunic		:= GetNewPar("MV_CIDADE","")
If Len (aTrbs)>0
	For nX := 1 To Len (aTrbs)
		If File (aTrbs[nX,1]+GetDBExtension ())
			DbSelectArea (aTrbs[nX,2])
			DbCloseArea ()
			Ferase (aTrbs[nX,1]+GetDBExtension ())
			Ferase (aTrbs[nX,1]+OrdBagExt ())
		Endif
	Next (nX)
	
	lProcessa	:=	.F.
EndIf

If lProcessa                                                                                   

	//�����������Ŀ
	//�Arquivo TXT�
	//�������������
	aCampos	:=	{}
	AADD(aCampos,{"NF" 	,   "C"	,TamSX3("F2_DOC")[1],0})
	AADD(aCampos,{"SERIE" ,"C"	,003,0})
	AADD(aCampos,{"CAMPO","C"	,591,0})
	
	cAls	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cAls,"Arq")
	IndRegua("Arq",cAls,"NF+SERIE")

	//��������������������������������������������������Ŀ
	//�Processamento para alimentar os TRBs criados acima�
	//����������������������������������������������������
	DbSelectArea ("SF3")
	SF3->(DbSetOrder (1))
	FsQuery (aSF3, 1, cTop, cDbf, SF3->(IndexKey ()))			

	SF3->(DbGoTop ())
	Do While !SF3->(Eof ())
			DbSelectArea ("SA2")
			SA2->(DbSetOrder (1))
			If SA2->(DbSeek (xFilial ("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA)) 
				If !ARQ->(DbSeek (SF3->F3_NFISCAL+SF3->F3_SERIE)) 
					//���������������������������������������������������������Ŀ
					//�POSICIONANDO O TITULO PAGO PARA PEGAR A DATA DE PAGAMENTO�
					//�����������������������������������������������������������
					SF1->(DbSetOrder (1))
					SF1->(DbSeek (xFilial ("SF1")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
					SE2->(DbSetOrder (6))
					SE2->(DbSeek (xFilial ("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC+SE2->E2_PARCELA))
				
					//���������������������������������������������������������������������������������������������������Ŀ
					//�APOS CHEGAR NO TITULO DE ISS, POISIONO NA BAIXA DO MESMO, ATRAVES DO DBEVAL VERIFICANDO O TEMBXCANC�
					//�����������������������������������������������������������������������������������������������������
					SE5->(DbSetOrder (7), DbSeek (xFilial ("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO))
					//�����������������������������������������������Ŀ
					//�PEGO A DATA DE PAGAMENTO PARA ENVIAR NO ARQUIVO�
					//�������������������������������������������������
					SE5->(DbEval ({|| .T.},, bBxCanc))
					
					If !Empty(SF3->F3_RECISS)
						cRecIss		:=	Iif (SF3->F3_RECISS$"1S", "1", "0")
					Else
						cRecIss		:=	Iif (SA2->A2_RECISS$"12", "1", "0")
					EndIf
				
					cInscr := Iif(!Empty(cCampo) ,&(cCampo),SA2->A2_INSCRM)

					RecLock ("ARQ", .T.)
					ARQ->NF	   := SF3->F3_NFISCAL		
					ARQ->SERIE := SF3->F3_SERIE
					ARQ->CAMPO := Alltrim(If(!Empty(cInscr) .And. !(cInscr==SA2->A2_CGC) .And. Alltrim(cMunic)==Alltrim(SA2->A2_MUN),"13","4"))+";"
					ARQ->CAMPO := Alltrim(ARQ->CAMPO)+Alltrim(Substr(SF3->F3_NFISCAL,1,10))+";"+Alltrim(Str(SF3->F3_BASEICM,10,2))+";"
					ARQ->CAMPO := Alltrim(ARQ->CAMPO)+Alltrim(Str(SF3->F3_VALCONT,10,2))+";"+Alltrim(Str(SF3->F3_ALIQICM,03,1))+";"
					ARQ->CAMPO := Alltrim(ARQ->CAMPO)+StrZero(Day(SF3->F3_ENTRADA),2) + StrZero(Month(SF3->F3_ENTRADA),2) + StrZero(Year(SF3->F3_ENTRADA),4)+";"
					ARQ->CAMPO := Alltrim(ARQ->CAMPO)+StrZero(Day(Eval (bRetDatP)),2) + StrZero(Month(Eval (bRetDatP)),2) + StrZero(Year(Eval (bRetDatP)),4)+";"
					ARQ->CAMPO := Alltrim(ARQ->CAMPO)+Alltrim(Substr(SA2->A2_CGC,1,14))+";"+Alltrim(Substr(SA2->A2_NOME,1,150))+";"+Alltrim(Substr(cInscr,1,15))+";"
					ARQ->CAMPO := Alltrim(ARQ->CAMPO)+cRecIss+";"+Alltrim(Substr(SA2->A2_CEP,1,08))+";"+Alltrim(Substr( Substr(SA2->A2_END, At(" ",SA2->A2_END)+1, (At (",", SA2->A2_END)-At (" ", SA2->A2_END))-1),1,200))+";"
			   		ARQ->CAMPO := Alltrim(ARQ->CAMPO)+Alltrim(Substr( Substr(SA2->A2_END, At(",",SA2->A2_END)+1, Len (AllTrim (SA2->A2_END))),1,6))+";"+Alltrim(Substr(SA2->A2_BAIRRO,1,50))+";"
				    ARQ->CAMPO := Alltrim(ARQ->CAMPO)+Alltrim(Substr(SA2->A2_MUN,1,50))+";"+Alltrim(Substr(SA2->A2_EST,1,2))+";"+Alltrim(Substr(SA2->A2_DDD,1,2))+";" 
					ARQ->CAMPO := Alltrim(ARQ->CAMPO)+IIF(Alltrim(SF3->F3_ISSST) == "2", "0", "1")+";"
			    	MsUnLock()
				EndIf	
		
		EndIf
	SF3->(DbSkip ())
	EndDo
	FsQuery (aSF3, 2)
EndIf
Return
