/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DESAG     ºAutor  ³Patricia Rajao      º Data ³  14/05/10   º±±
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
Function DESAG (aTrbs)
Local	lRet		:=	.T.
Local	lProcessa	:=	.T.
Local	nX			:=	0
Local	aStru		:=	{}
Local	cArq		:=	""
Local	cDbf		:=	"F3_FILIAL='"+cFilAnt+"' .AND. DToS (F3_ENTRADA)>='"+DToS (MV_PAR01)+"' .AND. DToS (F3_ENTRADA)<='"+DToS (MV_PAR02)+"' .AND. F3_TIPO=='S'"
Local	cTop		:=	"F3_FILIAL='"+cFilAnt+"' AND F3_ENTRADA>='"+DToS (MV_PAR01)+"' AND F3_ENTRADA<='"+DToS (MV_PAR02)+"' AND F3_TIPO='S'"
Local	aSF3		:=	{"SF3", ""}
Local	bBxCanc 	:= 	{||!SE5->(Eof ()) .And. xFilial ("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO==xFilial ("SE5")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO .And. TemBxCanc(SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_SEQ)}
Local	bRetDatP	:=	{|| Iif (xFilial ("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO==xFilial ("SE5")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO, SE5->E5_DATA, CToD ("  /  /  "))}
Local   cInscA1     := GetNewPar("MV_IMA1","")
Local   cInscA2     := GetNewPar("MV_IMA2","")  
Local   cAtiv		:= GetNewPar("MV_ATVCONT","")
Local   cCidade		:= GetNewPar("MV_CIDADE","")  
Local	cFornIss	:= ""
Local   cPreFix		:= ""
Local	cRecIss		:= ""  
Local   cInscr      := ""
Local	nAlq		:= 0
Local   cDat        := ""  
Local	cSerie		:= ""

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄ¿       	
	//³Arquivo TXT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÙ 
	aCampos	:=	{}
	AADD(aCampos,{"NF" 	,   "C"	,006,0})
	AADD(aCampos,{"SERIE" ,"C"	,003,0})
	AADD(aCampos,{"CAMPO","C"	,591,0})
	
	cAls	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cAls,"TSC")
	IndRegua("TSC",cAls,"NF+SERIE")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄ¿       	
	//³Arquivo TXT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÙ 
	aCampos	:=	{}
	AADD(aCampos,{"NF" 	,   "C"	,009,0})
	AADD(aCampos,{"SERIE",	"C"	,003,0})
	AADD(aCampos,{"MODELO",	"C"	,004,0})
	AADD(aCampos,{"DIA",	"N"	,002,0})    
	AADD(aCampos,{"MES",	"N"	,002,0})
	AADD(aCampos,{"ANO",	"N"	,004,0})
	AADD(aCampos,{"VALTRIB","C"	,012,2})    
	AADD(aCampos,{"VALCONT","C"	,012,2})
	AADD(aCampos,{"NATUREZA","N",006,0})
	AADD(aCampos,{"ATIV"	,"C",011,0})    
	AADD(aCampos,{"INSCRM" ,"C",015,0})
	AADD(aCampos,{"CNPJ",	"C"	,015,0})
	AADD(aCampos,{"RAZAO",	"C"	,101,0})    
	AADD(aCampos,{"CEP",   "C"	,009,0})
	AADD(aCampos,{"END",	"C"	,101,0})
	AADD(aCampos,{"NUMERO","C"	,006,0})    
	AADD(aCampos,{"BAIRRO","C"	,031,0})
	AADD(aCampos,{"CIDADE","C"	,029,0})
	AADD(aCampos,{"UF"	  ,"C"	,002,0})    
	AADD(aCampos,{"IMPRET","C"	,001,0})
	AADD(aCampos,{"TRIBFD","C"  ,001,0})
	
	cAls	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cAls,"TSP")
	IndRegua("TSP",cAls,"NF+SERIE")  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento para alimentar os TRBs criados acima³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea ("SF3")
	SF3->(DbSetOrder (1))
	FsQuery (aSF3, 1, cTop, cDbf, SF3->(IndexKey ()))

	SX6->(DbSeek (xFilial ("SX6")+"MV_SERIE"))
	While !SX6->(Eof ()) .And. xFilial ("SX6")==SX6->X6_FIL .And. "MV_SERIE"$SX6->X6_VAR
		cSerie += SX6->X6_CONTEUD
		SX6->(DbSkip ())	
	End
					
	SF3->(DbGoTop ())
	Do While !SF3->(Eof ())
		If Substr(SF3->F3_CFO,1,1)<"5"
			DbSelectArea ("SA2")
			SA2->(DbSetOrder (1))
			If SA2->(DbSeek (xFilial ("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
				If !TSC->(DbSeek (SF3->F3_NFISCAL+SF3->F3_SERIE)) 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³POSICIONANDO O TITULO PAGO PARA PEGAR A DATA DE PAGAMENTO³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SF1->(DbSetOrder (1))
					SF1->(DbSeek (xFilial ("SF1")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
					SE2->(DbSetOrder (6))
					cPreFix:= IiF(Empty (SF1->F1_PREFIXO), &(SuperGetMV("MV_2DUPREF")), SF1->F1_PREFIXO)
					SE2->(DbSeek (xFilial ("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+cPreFix+SF1->F1_DOC+SE2->E2_PARCELA))
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³APOS CHEGAR NO TITULO DE ISS, POISIONO NA BAIXA DO MESMO, ATRAVES DO DBEVAL VERIFICANDO O TEMBXCANC³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SE5->(DbSetOrder (7), DbSeek (xFilial ("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³PEGO A DATA DE PAGAMENTO PARA ENVIAR NO ARQUIVO³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SE5->(DbEval ({|| .T.},, bBxCanc))
					
					If !Empty (SF3->F3_RECISS)
						cRecIss		:=	Iif (SF3->F3_RECISS$"1S", "1", "0")
					Else
						cRecIss		:=	Iif (SA2->A2_RECISS$"12", "1", "0")
					EndIf

					cInscr := Iif (Empty (SA2->A2_INSCRM), SA2->A2_CGC,Iif(cInscA2==" " ,"",&(cInscA2)))

					RecLock ("TSC", .T.)
					TSC->NF	   := SF3->F3_NFISCAL		
					TSC->SERIE := SF3->F3_SERIE
					TSC->CAMPO := Alltrim(SubStr (cSerie, Iif(At (SubStr (SerieNfId("SF3",2,"F3_SERIE"), 1, 3), cSerie)>0,At (SubStr (SerieNfId("SF3",2,"F3_SERIE"), 1, 3), cSerie)+4,At (SubStr (SerieNfId("SF3",2,"F3_SERIE"), 1, 3), cSerie)+5), 2))+";"					
					TSC->CAMPO := Alltrim(TSC->CAMPO)+Alltrim(Substr(SF3->F3_NFISCAL,1,10))+";"+Alltrim(Str(SF3->F3_BASEICM,10,2))+";"
					TSC->CAMPO := Alltrim(TSC->CAMPO)+Alltrim(Str(SF3->F3_VALCONT,10,2))+";"+Alltrim(Str(SF3->F3_ALIQICM,03,1))+";"
					TSC->CAMPO := Alltrim(TSC->CAMPO)+StrZero(Day(SF3->F3_ENTRADA),2) + StrZero(Month(SF3->F3_ENTRADA),2) + StrZero(Year(SF3->F3_ENTRADA),4)+";"
					TSC->CAMPO := Alltrim(TSC->CAMPO)+StrZero(Day(Eval (bRetDatP)),2) + StrZero(Month(Eval (bRetDatP)),2) + StrZero(Year(Eval (bRetDatP)),4)+";"
					TSC->CAMPO := Alltrim(TSC->CAMPO)+Alltrim(Substr(SA2->A2_CGC,1,14))+";"+Alltrim(Substr(SA2->A2_NOME,1,150))+";"+Alltrim(Substr(cInscr,1,15))+";"
					TSC->CAMPO := Alltrim(TSC->CAMPO)+cRecIss+";"+Alltrim(Substr(SA2->A2_CEP,1,08))+";"+Alltrim(Substr(Substr (SA2->A2_END,1, At (",", SA2->A2_END)-1),1,200))+";"
			   		TSC->CAMPO := Alltrim(TSC->CAMPO)+Alltrim(Substr(Substr (SA2->A2_END, At(",",SA2->A2_END)+1, Len (AllTrim (SA2->A2_END))),1,6))+";"+Alltrim(Substr(SA2->A2_BAIRRO,1,50))+";"
				    TSC->CAMPO := Alltrim(TSC->CAMPO)+Alltrim(Substr(SA2->A2_MUN,1,50))+";"+Alltrim(Substr(SA2->A2_EST,1,2))+";"+Alltrim(Substr(SA2->A2_DDD,1,2))+";" 
			    	MsUnLock()
				EndIf	
		    EndIf
		Else         
    	  	DbSelectArea ("SA1")
			SA1->(DbSetOrder (1))
			If SA1->(DbSeek (xFilial ("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
				If !TSP->(DbSeek (SF3->F3_NFISCAL+SF3->F3_SERIE)) 
	
		   			If !Empty(SF3->F3_RECISS)
						cRecIss		:=	Iif (SF3->F3_RECISS$"1S", "1", "0")
					Else
						cRecIss		:=	Iif (SA1->A1_RECISS$"12", "1", "0")
					EndIf
		
					cInscr := Iif (Empty (SA1->A1_INSCRM), SA1->A1_CGC,Iif(cInscA1==" " ,"",&(cInscA1)))       
		
					RecLock ("TSP", .T.)
					TSP->NF	   := RetNf(SF3->F3_NFISCAL,9,"N")		
					TSP->SERIE := SF3->F3_SERIE    
					TSP->MODELO:= RetNf(Alltrim(SubStr (cSerie, Iif(At (SubStr (SerieNfId("SF3",2,"F3_SERIE"), 1, 3), cSerie)>0,At (SubStr (SerieNfId("SF3",2,"F3_SERIE"), 1, 3), cSerie)+4,At (SubStr (SerieNfId("SF3",2,"F3_SERIE"), 1, 3), cSerie)+5), 2)),4,"N")
					TSP->DIA   := Day(SF3->F3_ENTRADA)
					TSP->MES   := Month(SF3->F3_ENTRADA)
					TSP->ANO   := Year(SF3->F3_ENTRADA)
					TSP->VALTRIB :=StrZero(SF3->F3_BASEICM,12,2)
					TSP->VALCONT := StrZero(SF3->F3_VALCONT,12,2)
					TSP->NATUREZA:= IIf(SF3->F3_ISENICM>0,2,IIf(!Empty(SF3->F3_DTCANC),5,1))
					TSP->ATIV 	:= PADL(Alltrim(Iif(cAtiv=="" ,"",&(cAtiv))),11)
			   		TSP->INSCRM := PADL(Alltrim(cInscr),15)
				    TSP->CNPJ   := PADL(Alltrim(SA1->A1_CGC),15)
				    TSP->RAZAO  := SA1->A1_NOME
				    TSP->CEP    := PADL(Alltrim(SA1->A1_CEP),9)
				    TSP->END	:= Substr (SA1->A1_END, 1, (At (",", SA1->A1_END))-1)
				    TSP->NUMERO := PADL(Alltrim(Substr (SA1->A1_END, Iif(At(",",SA1->A1_END)>0,At(",",SA1->A1_END)+1,0), Len (AllTrim (SA1->A1_END)))),6)
				    TSP->BAIRRO := SA1->A1_BAIRRO
				    TSP->CIDADE := SA1->A1_MUN
				    TSP->UF 	:= SA1->A1_EST
				    TSP->IMPRET := cRecIss
				    TSP->TRIBFD	:= Iif(AllTrim(cCidade) <> AllTrim(SA1->A1_MUN),"0","1")
			    	MsUnLock()
			  	EndIf
			EndIf    
	EndIf
	SF3->(DbSkip ())
	EndDo
	FsQuery (aSF3, 2)
EndIf
Return 