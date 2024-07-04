/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ISSJABO   ºAutor  ³Microsiga           º Data ³  27/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para processamento do livro fiscal de ISS onde ar-   º±±
±±º          ³ mazenas as informacoes em um arquivo trabalho para poste-  º±±
±±º          ³ riores leituras no .INI                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ISSJABO (aTrbs)
Local	lRet		:=	.T.
Local	lProcessa	:=	.T.
Local	nX			:=	0
Local	aStru		:=	{}
Local	cArq		:=	""
Local	cDbf		:=	"F3_FILIAL='"+xFilial ("SF3")+"' .AND. DToS (F3_ENTRADA)>='"+DToS (MV_PAR01)+"' .AND. DToS (F3_ENTRADA)<='"+DToS (MV_PAR02)+"' .AND. F3_TIPO=='S' "
Local	cTop		:=	"F3_FILIAL='"+xFilial ("SF3")+"' AND F3_ENTRADA>='"+DToS (MV_PAR01)+"' AND F3_ENTRADA<='"+DToS (MV_PAR02)+"' AND F3_TIPO='S' "
Local	aSF3		:=	{"SF3", ""}
Local	bRetDatP	:=	{|| Iif (xFilial ("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO==xFilial ("SE5")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO, SE5->E5_DATA, CToD ("  /  /  "))}
Local	cFornIss	:=	""
Local	cRecIss		:=	""
Local   cCodMun     :=  ""
Local	nAlq		:=	0

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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TRB para o registro E³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd (aStru, {"TRE_CNPJ",		"C",	20,	0})
	aAdd (aStru, {"TRE_CMC",		"C",	07,	0})
	aAdd (aStru, {"TRE_RAZAO",		"C",	55,	0})
	aAdd (aStru, {"TRE_LOGRAD",		"C",	35,	0})
	aAdd (aStru, {"TRE_NUMIMO",		"C",	05,	0})
	aAdd (aStru, {"TRE_COMPL",		"C",	12,	0})
	aAdd (aStru, {"TRE_BAIRRO",		"C",	19,	0})
	aAdd (aStru, {"TRE_MUNIC",		"C",	25,	0})
	aAdd (aStru, {"TRE_ESTADO",		"C",	02,	0})
	aAdd (aStru, {"TRE_CEP",		"C",	09,	0})
	aAdd (aStru, {"TRE_DDDFO",		"C",	02,	0})
	aAdd (aStru, {"TRE_FONE",		"C",	08,	0})
	aAdd (aStru, {"TRE_DDDFA",		"C",	02,	0})
	aAdd (aStru, {"TRE_FAX",		"C",	08,	0})	
	aAdd (aStru, {"TRE_EMAIL",		"C",	35,	0})
	aAdd (aStru, {"TRE_ESTRAN",		"C",	01,	0})
	
	cArq	:=	CriaTrab (aStru)
	aAdd (aTrbs, {cArq, "TRE"})
	
	DbUseArea (.T., __LocalDriver, cArq, "TRE")
	IndRegua ("TRE", cArq, "TRE_CNPJ")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TRB para o registro M³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd (aStru, {"TRM_CNPJ",		"C",	20,	0})
	aAdd (aStru, {"TRM_SITUAC",		"C",	01,	0})
	aAdd (aStru, {"TRM_SERIE",		"C",	02,	0})
	aAdd (aStru, {"TRM_NUMERO",		"C",	TamSX3("F2_DOC")[1],0})
	aAdd (aStru, {"TRM_DATA",		"D",	08,	0})
	aAdd (aStru, {"TRM_VLRSER",		"N",	11,	2})
	aAdd (aStru, {"TRM_VLRALQ",		"N",	05,	2})
	aAdd (aStru, {"TRM_VLRBAS",		"N",	11,	2})
	aAdd (aStru, {"TRM_VLRISS",		"N",	11,	2})
	aAdd (aStru, {"TRM_RETIDO",		"C",	01,	0})
	aAdd (aStru, {"TRM_BASELE",		"C",	05,	0})
	aAdd (aStru, {"TRM_CODISS",		"C",	05,	0})
	aAdd (aStru, {"TRM_TPDOC",		"C",	01,	0})
	
	cArq	:=	CriaTrab (aStru)
	aAdd (aTrbs, {cArq, "TRM"})
	
	DbUseArea (.T., __LocalDriver, cArq, "TRM")
	IndRegua ("TRM", cArq, "TRM_NUMERO+TRM_SERIE+TRM_CNPJ+StrZero (TRM_VLRALQ, 2)")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TRB para o registro O³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd (aStru, {"TRO_CNPJ",		"C",	20,	0})
	aAdd (aStru, {"TRO_TIPO",		"C",	01,	0})
	aAdd (aStru, {"TRO_SERIE",		"C",	TamSX3("F3_SERIE")[1],0})
	aAdd (aStru, {"TRO_NUMERO",		"C",	TamSX3("F2_DOC")[1],0})
	aAdd (aStru, {"TRO_EMISSA",		"D",	08,	0})
	aAdd (aStru, {"TRO_PAGTO",		"D",	08,	0})
	aAdd (aStru, {"TRO_VLRSER",		"N",	11,	2})
	aAdd (aStru, {"TRO_VLRALQ",		"N",	05,	2})
	aAdd (aStru, {"TRO_VLRBAS",		"N",	11,	2})
	aAdd (aStru, {"TRO_VLRISS",		"N",	11,	2})
	aAdd (aStru, {"TRO_RETIDO",		"C",	01,	0})
	aAdd (aStru, {"TRO_SEQREC",		"C",	06,	0})
	aAdd (aStru, {"TRO_BASELE",		"C",	05,	0})
	aAdd (aStru, {"TRO_CODISS",		"C",	05,	0})
	aAdd (aStru, {"TRO_TPDOC",		"C",	01,	0})
	aAdd (aStru, {"TRO_SDOC",		"C",	02,	0})
	aAdd (aStru, {"TRO_CODEST",		"C",	02,	0})
	aAdd (aStru, {"TRO_CODMUN",		"C",	05,	0})
	
	cArq	:=	CriaTrab (aStru)
	aAdd (aTrbs, {cArq, "TRO"})
	
	DbUseArea (.T., __LocalDriver, cArq, "TRO")
	IndRegua ("TRO", cArq, "TRO_NUMERO+TRO_SERIE+TRO_CNPJ+StrZero (TRO_VLRALQ, 2)")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consistencia para performance, pois dependendo da selecao no wizard, ³
	//³  envio movimentacoes de ENTRADA ou SAIDA.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !("M"$_aTotal[014])	//Registro "M" eh para NFs emitidas
		cDbf	+=	" .AND. Left (F3_CFO, 1)<'5' "
		cTop	+=	" AND SUBSTRING(F3_CFO, 1, 1)<'5' "
	EndIf
	
	If !("O"$_aTotal[014])	//Registro "O" eh para NFs recebidas
		cDbf	+=	" .AND. Left (F3_CFO, 1)>='5' "
		cTop	+=	" AND SUBSTRING(F3_CFO, 1, 1)>='5' "
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento para alimentar os TRBs criados acima³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea ("SF3")
		SF3->(DbSetOrder (1))
	FsQuery (aSF3, 1, cTop, cDbf, SF3->(IndexKey ()))
	SF3->(DbGoTop ())
	Do While !SF3->(Eof ()) .And. Left (AllTrim (_aTotal[008][1][2]), 1)$"C"

		If Left (SF3->F3_CFO, 1)>="5"
			DbSelectArea ("SA1")
			SA1->(DbSetOrder (1))
			If SA1->(DbSeek (xFilial ("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
				If !TRE->(DbSeek (SA1->A1_CGC))
					RecLock ("TRE", .T.)
					TRE->TRE_CNPJ	:=	SA1->A1_CGC
					TRE->TRE_CMC	:=	AllTrim (SA1->A1_INSCRM)
					TRE->TRE_RAZAO	:=	AllTrim (SA1->A1_NOME)
					TRE->TRE_LOGRAD	:=	AllTrim (SubStr (SA1->A1_END, 1, At (",", SA1->A1_END)-1))
					TRE->TRE_NUMIMO	:=	AllTrim (SubStr (SA1->A1_END, At (",", SA1->A1_END)+1))
					TRE->TRE_COMPL	:=	""
					TRE->TRE_BAIRRO	:=	AllTrim (SA1->A1_BAIRRO)
					TRE->TRE_MUNIC	:=	AllTrim (SA1->A1_MUN)
					TRE->TRE_ESTADO	:=	AllTrim (SA1->A1_EST)
					TRE->TRE_CEP	:=	Left (AllTrim (SA1->A1_CEP), 5)+"-"+Right (AllTrim (SA1->A1_CEP), 3)
					TRE->TRE_DDDFO	:=	Iif (Len (AllTrim (SA1->A1_TEL))>=10, Left (AllTrim (SA1->A1_TEL), 2), "00")
					TRE->TRE_FONE	:=	Iif (Len (AllTrim (SA1->A1_TEL))>=10, SubStr (AllTrim (SA1->A1_TEL), 3, 8), SubStr (AllTrim (SA1->A1_TEL), 1, 8))
					TRE->TRE_DDDFA	:=	Iif (Len (AllTrim (SA1->A1_FAX))>=10, Left (AllTrim (SA1->A1_FAX), 2), "00")
					TRE->TRE_FAX	:=	Iif (Len (AllTrim (SA1->A1_FAX))>=10, SubStr (AllTrim (SA1->A1_FAX), 3, 8), SubStr (AllTrim (SA1->A1_FAX), 1, 8))
					TRE->TRE_EMAIL	:=	AllTrim (SA1->A1_EMAIL)
					TRE->TRE_ESTRAN	:=	Iif ("EX"$SA1->A1_EST, "S", "N")
					MsUnLock()
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³QUANDO O ISS NAO FOR RETIDO OS VALORES DE BASE / ALIQUOTA / ISSQN DEVEM ESTAR ZERADOS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(SF3->F3_RECISS)
					cRecIss		:=	Iif (SF3->F3_RECISS$"1S", "S", "N")
				Else
					cRecIss		:=	Iif (SA1->A1_RECISS$"1S", "S", "N")
				EndIf
				
				If !TRM->(DbSeek (SF3->F3_NFISCAL+SF3->F3_SERIE+SA1->A1_CGC+StrZero (SF3->F3_ALIQICM, 2)))
					RecLock ("TRM", .T.)
					TRM->TRM_CNPJ	:=	SA1->A1_CGC    
					TRM->TRM_SITUAC	:=	Iif (Empty (SF3->F3_DTCANC), "E", "C")
					TRM->TRM_SERIE	:=	SF3->F3_SERIE
					TRM->TRM_NUMERO	:=	SF3->F3_NFISCAL
					TRM->TRM_DATA	:=	SF3->F3_ENTRADA
					TRM->TRM_VLRALQ	:=	SF3->F3_ALIQICM
					TRM->TRM_BASELE	:=	""
					TRM->TRM_RETIDO	:=	cRecIss
					TRM->TRM_CODISS	:=	StrTran(SF3->F3_CODISS,".","")
					TRM->TRM_TPDOC	:=	Iif(SF3->F3_ESPECIE$"CF","F","A") 
				Else
					RecLock ("TRM", .F.)
				EndIf
				TRM->TRM_VLRSER	+=	SF3->F3_VALCONT
				TRM->TRM_VLRBAS	+=	SF3->F3_BASEICM
				TRM->TRM_VLRISS	+=	SF3->F3_VALICM

				MsUnLock()
			EndIf
		Else
			DbSelectArea ("SA2")
			SA2->(DbSetOrder(1))
			If SA2->(DbSeek (xFilial ("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
				If (Alltrim(SA2->A2_COD_MUN) == "07901" .And. AllTrim(SA2->A2_EST) == "PE" )
					SF3->(DbSkip ())
					Loop
				Endif
				If !TRE->(DbSeek (SA2->A2_CGC))
					RecLock ("TRE", .T.)
					TRE->TRE_CNPJ	:=	SA2->A2_CGC
					TRE->TRE_CMC	:=	AllTrim (SA2->A2_INSCRM)
					TRE->TRE_RAZAO	:=	AllTrim (SA2->A2_NOME)
					TRE->TRE_LOGRAD	:=	AllTrim (SubStr (SA2->A2_END, 1, At (",", SA2->A2_END)-1))
					TRE->TRE_NUMIMO	:=	AllTrim (SubStr (SA2->A2_END, At (",", SA2->A2_END)+1))
					TRE->TRE_COMPL	:=	""
					TRE->TRE_BAIRRO	:=	AllTrim (SA2->A2_BAIRRO)
					TRE->TRE_MUNIC	:=	AllTrim (SA2->A2_MUN)
					TRE->TRE_ESTADO	:=	AllTrim (SA2->A2_EST)
					TRE->TRE_CEP	:=	Left (AllTrim (SA2->A2_CEP), 5)+"-"+Right (AllTrim (SA2->A2_CEP), 3)
					TRE->TRE_DDDFO	:=	Iif (Len (AllTrim (SA2->A2_TEL))>=10, Left (AllTrim (SA2->A2_TEL), 2), "00")
					TRE->TRE_FONE	:=	Iif (Len (AllTrim (SA2->A2_TEL))>=10, SubStr (AllTrim (SA2->A2_TEL), 3, 8), SubStr (AllTrim (SA2->A2_TEL), 1, 8))
					TRE->TRE_DDDFA	:=	Iif (Len (AllTrim (SA2->A2_FAX))>=10, Left (AllTrim (SA2->A2_FAX), 2), "00")
					TRE->TRE_FAX	:=	Iif (Len (AllTrim (SA2->A2_FAX))>=10, SubStr (AllTrim (SA2->A2_FAX), 3, 8), SubStr (AllTrim (SA2->A2_FAX), 1, 8))
					TRE->TRE_EMAIL	:=	AllTrim (SA2->A2_EMAIL)
					TRE->TRE_ESTRAN	:=	Iif ("EX"$SA2->A2_EST, "S", "N")
					MsUnLock()
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³QUANDO O ISS NAO FOR RETIDO OS VALORES DE BASE / ALIQUOTA / ISSQN DEVEM ESTAR ZERADOS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty (SF3->F3_RECISS)
					cRecIss		:=	Iif (SF3->F3_RECISS$"2N", "S", "N")
				Else
					cRecIss		:=	Iif (SA2->A2_RECISS$"2N", "S", "N")
				EndIf
				nAlq	:=	If ("S"$cRecIss, SF3->F3_ALIQICM,0)
				
				If !TRO->(DbSeek (SF3->F3_NFISCAL+SF3->F3_SERIE+SA2->A2_CGC+StrZero (nAlq, 2)))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³POSICIONANDO O TITULO PAGO PARA PEGAR A DATA DE PAGAMENTO³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SF1->(DbSetOrder (1))
					SF1->(DbSeek (xFilial ("SF1")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
					SE2->(DbSetOrder (6))
					If (SE2->(DbSeek (xFilial ("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC)))
						cFornIss	:=	PadR (SuperGetMV ("MV_MUNIC"), TamSx3("E2_FORNECE")[1])+"00"
						If !(Empty (SE2->E2_FORNISS))							
							cFornIss	:=	SE2->E2_FORNISS+SE2->E2_LOJAISS
						EndIf
						SE2->(DbSeek (xFilial ("SE2")+cFornIss+SE2->(E2_PREFIXO+E2_NUM+E2_PARCISS)))
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³APOS CHEGAR NO TITULO DE ISS, POISIONO NA BAIXA DO MESMO, ATRAVES DO DBEVAL VERIFICANDO O TEMBXCANC³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SE5->(DbSetOrder (7), DbSeek (xFilial ("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO))
					
					RecLock ("TRO", .T.)
					TRO->TRO_CNPJ		:=	SA2->A2_CGC
					TRO->TRO_TIPO		:=	"N"
					TRO->TRO_SERIE	:=	SF3->F3_SERIE
					TRO->TRO_NUMERO	:=	SF3->F3_NFISCAL
					TRO->TRO_EMISSA	:=	SF3->F3_EMISSAO
					TRO->TRO_PAGTO	:=	Eval (bRetDatP)
					TRO->TRO_VLRALQ	:=	nAlq
					TRO->TRO_SEQREC	:=	""
					TRO->TRO_BASELE	:=	""
					TRO->TRO_RETIDO	:=	cRecIss
					TRO->TRO_CODISS	:=	StrTran(SF3->F3_CODISS,".","")
					TRO->TRO_SDOC	:=	SerieNfId("SF3",2,"F3_SERIE")
					
					If	Alltrim(SF3->F3_ESPECIE) == "NFSE"
						TRO->TRO_TPDOC := "E"
					ElseIf	"CF"$Alltrim(SF3->F3_ESPECIE)
						TRO->TRO_TPDOC := "F"
					ElseIf	Alltrim(SF3->F3_ESPECIE) == "RPS"
						TRO->TRO_TPDOC := "R"
					ElseIf	"NF"$Alltrim(SF3->F3_ESPECIE)
						TRO->TRO_TPDOC := "N"
					ElseIf	"P"$Alltrim(SF3->F3_ESPECIE)
						TRO->TRO_TPDOC := "P"
					Else
						TRO->TRO_TPDOC := "O"
					EndIf		
										
					TRO->TRO_CODEST	:=	UfCodIBGE(SF3->F3_ESTADO)
					
					If !Empty(SF1->F1_INCISS)
						cCodMun := SF1->F1_INCISS
					Else
						cCodMun := Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_CODMUN")
					EndIf

					TRO->TRO_CODMUN	:= cCodMun
				Else
					RecLock ("TRO", .F.)
				EndIf
				TRO->TRO_VLRSER	+=	SF3->F3_VALCONT
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³QUANDO O ISS NAO FOR RETIDO OS VALORES DE BASE / ALIQUOTA / ISSQN DEVEM ESTAR ZERADOS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ("S"$cRecIss)
					TRO->TRO_VLRBAS	+=	SF3->F3_BASEICM
					TRO->TRO_VLRISS	+=	SF3->F3_VALICM
				EndIf

				MsUnLock()
			EndIf
		EndIf	
	
		SF3->(DbSkip ())
	EndDo
	FsQuery (aSF3, 2)
EndIf
Return (lRet)