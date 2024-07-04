/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ISSJAC    ºAutor  ³Microsiga           º Data ³  11/10/06   º±±
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
Function ISSJAC (aTrbs)
Local	lRet		:=	.T.
Local	lProcessa	:=	.T.
Local	nX			:=	0
Local	aStru		:=	{}
Local	cArq		:=	""
Local	cDbf		:=	"F3_FILIAL='"+xFilial ("SF3")+"' .AND. DToS (F3_ENTRADA)>='"+DToS (MV_PAR01)+"' .AND. DToS (F3_ENTRADA)<='"+DToS (MV_PAR02)+"' .AND. F3_TIPO=='S'" 
Local	cTop		:=	"F3_FILIAL='"+xFilial ("SF3")+"' AND F3_ENTRADA>='"+DToS (MV_PAR01)+"' AND F3_ENTRADA<='"+DToS (MV_PAR02)+"' AND F3_TIPO='S'"
Local	aSF3		:=	{"SF3", ""}
Local	bBxCanc 	:= 	{||!SE5->(Eof ()) .And. xFilial ("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO==xFilial ("SE5")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO .And. TemBxCanc(SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_SEQ)}
Local	bRetDatP	:=	{|| Iif (xFilial ("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO==xFilial ("SE5")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO, SE5->E5_DATA, CToD ("  /  /  "))}
Local   cCampo      := GetNewPar("MV_IMA2","")
Local   cCampo1     := GetNewPar("MV_IMA1","")
Local   cAtiv     	:= GetNewPar("MV_ATVCONT","") 
Local	cFornIss	:=	""
Local	cRecIss		:=	""  
Local   cInscr      := ""
Local	nAlq		:=	0
Local   cDat        := ""
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
AADD(aCampos,{"NF"		,"C"	,006,0})
AADD(aCampos,{"SERIE"	,"C"	,003,0})
AADD(aCampos,{"CAMPO"	,"C"	,591,0})

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"Arq")
IndRegua("Arq",cAls,"NF+SERIE") 
  

aCampos	:=	{}
AADD(aCampos,{"NF" 		,"N"	,009,0})
AADD(aCampos,{"SERIE"	,"N"	,004,0})
AADD(aCampos,{"DIA"		,"N"	,002,0})
AADD(aCampos,{"MES" 	,"N"	,002,0})
AADD(aCampos,{"ANO"		,"N"	,004,0})
AADD(aCampos,{"VALTRIB"	,"N"	,012,2})
AADD(aCampos,{"VALCONT" ,"N"	,012,2})
AADD(aCampos,{"NATUREZA","N"	,006,0})
AADD(aCampos,{"ATIV"	,"C"	,011,0})
AADD(aCampos,{"INSCR"	,"C"	,015,0})
AADD(aCampos,{"CNPJ"	,"C"	,015,0})
AADD(aCampos,{"RAZAO"	,"C"	,101,0}) 
AADD(aCampos,{"CEP"		,"C"	,009,0})
AADD(aCampos,{"END"		,"C"	,101,0})
AADD(aCampos,{"NUMERO"	,"C"	,006,0})
AADD(aCampos,{"BAIRRO"	,"C"	,031,0})
AADD(aCampos,{"CIDADE"	,"C"	,029,0})
AADD(aCampos,{"ESTADO"	,"C"	,002,0})
AADD(aCampos,{"IMPRET"	,"N"	,001,0})

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"ARP")
IndRegua("ARP",cAls,"NF+SERIE") 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento para alimentar os TRBs criados acima³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea ("SF3")
	SF3->(DbSetOrder (1))
	FsQuery (aSF3, 1, cTop, cDbf, SF3->(IndexKey ()))
	SF3->(DbGoTop ())
	Do While !SF3->(Eof ())
		If !empty(SF3->F3_DTCANC) .Or. "CANCELAD"$SF3->F3_OBSERV
	   		SF3->(DbSkip ())
	   		loop
   		EndIf
		If Substr (SF3->F3_CFO, 1)>="5"   
			//ÚÄÄÄÄÄÄÄÄÄ¿
			//³Prestador³
			//ÀÄÄÄÄÄÄÄÄÄÙ
		  	DbSelectArea ("SA1")
			SA1->(DbSetOrder (1))
			If SA1->(DbSeek (xFilial ("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
				If !ARP->(DbSeek (SF3->F3_NFISCAL+SF3->F3_SERIE))
					If !Empty(SF3->F3_RECISS)
						cRecIss		:=	Iif (SF3->F3_RECISS$"1S", "1", "0")
					Else
						cRecIss		:=	Iif (SA1->A1_RECISS$"12", "1", "0")
					EndIf				

					cInscr := Iif (Empty (SA1->A1_INSCRM), SA1->A1_CGC,Iif(cCampo1=="" ,"",&(cCampo1)))

					RecLock ("ARP", .T.)  
					ARP->NF			:= Val(SF3->F3_NFISCAL)		
					ARP->SERIE		:= Val(SF3->F3_SERIE)
				    ARP->DIA		:= Day(SF3->F3_ENTRADA)
					ARP->MES		:= Month(SF3->F3_ENTRADA)
					ARP->ANO		:= Year(SF3->F3_ENTRADA)
					ARP->VALTRIB 	:= SF3->F3_BASEICM
					ARP->VALCONT 	:= SF3->F3_VALCONT
					ARP->NATUREZA	:= IIf(SF3->F3_ISENICM>0,2,IIf(!Empty(SF3->F3_DTCANC),5,1	))
			   		ARP->ATIV		:= PADL(Alltrim(Iif(cAtiv <>"" .And. !Empty(cAtiv) ,&(cAtiv),"")),11)
				    ARP->INSCR		:= PADL(Alltrim(cInscr),15)
				    ARP->CNPJ		:= PADL(Alltrim(SA1->A1_CGC),15)
				    ARP->RAZAO		:= SA1->A1_NOME
				    ARP->CEP 		:= PADL(Alltrim(SA1->A1_CEP),9)
				    ARP->END 		:= Substr (SA1->A1_END, At(" ",SA1->A1_END)+1,Iif(At (",", SA1->A1_END)>0,(At (",", SA1->A1_END)-At (" ", SA1->A1_END))-1,len(SA1->A1_END)))
				    ARP->NUMERO 	:= PADL(Alltrim(Iif(At(",",SA1->A1_END)>0,Substr (SA1->A1_END, At(",",SA1->A1_END)+1, Len (AllTrim (SA1->A1_END))),0)),6)
				    ARP->BAIRRO 	:= SA1->A1_BAIRRO
				    ARP->CIDADE 	:= SA1->A1_MUN
				    ARP->ESTADO 	:= SA1->A1_EST
				    ARP->IMPRET		:= Val(cRecIss)
			    	MsUnLock()
				EndIf	
			EndIf	
		Else
			//ÚÄÄÄÄÄÄÄ¿
			//³Tomador³
			//ÀÄÄÄÄÄÄÄÙ
			DbSelectArea ("SA2")
			SA2->(DbSetOrder (1))
			If SA2->(DbSeek (xFilial ("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
				If !ARQ->(DbSeek (SF3->F3_NFISCAL+SF3->F3_SERIE))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³POSICIONANDO O TITULO PAGO PARA PEGAR A DATA DE PAGAMENTO³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SF1->(DbSetOrder (1))
					SF1->(DbSeek (xFilial ("SF1")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
					SE2->(DbSetOrder (6))
					SE2->(DbSeek (xFilial ("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC+SE2->E2_PARCELA))
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³APOS CHEGAR NO TITULO DE ISS, POISIONO NA BAIXA DO MESMO, ATRAVES DO DBEVAL VERIFICANDO O TEMBXCANC³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SE5->(DbSetOrder (7), DbSeek (xFilial ("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³PEGO A DATA DE PAGAMENTO PARA ENVIAR NO ARQUIVO³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SE5->(DbEval ({|| .T.},, bBxCanc))
					
					If !Empty(SF3->F3_RECISS)
						cRecIss		:=	Iif (SF3->F3_RECISS$"1S", "1", "0")
					Else
						cRecIss		:=	Iif (SA2->A2_RECISS$"12", "1", "0")
					EndIf
				

					cInscr := Iif (Empty (SA2->A2_INSCRM), SA2->A2_CGC,Iif(cCampo=="" ,"",&(cCampo)))

					RecLock ("ARQ", .T.)
					ARQ->NF	   := SF3->F3_NFISCAL		
					ARQ->SERIE := SF3->F3_SERIE						
				   ARQ->CAMPO := Alltrim(Str(Val(SerieNfId("SF3",2,"F3_SERIE"))))+";"+Alltrim(Substr(SF3->F3_NFISCAL,1,10))+";"+Alltrim(Str(SF3->F3_BASEICM,10,2))+";"
					ARQ->CAMPO := Alltrim(ARQ->CAMPO)+Alltrim(Str(SF3->F3_VALCONT,10,2))+";"+Alltrim(Str(SF3->F3_ALIQICM,03,1))+";"
					ARQ->CAMPO := Alltrim(ARQ->CAMPO)+StrZero(Day(SF3->F3_ENTRADA),2) + StrZero(Month(SF3->F3_ENTRADA),2) + StrZero(Year(SF3->F3_ENTRADA),4)+";"
					ARQ->CAMPO := Alltrim(ARQ->CAMPO)+StrZero(Day(Eval (bRetDatP)),2) + StrZero(Month(Eval (bRetDatP)),2) + StrZero(Year(Eval (bRetDatP)),4)+";"
					ARQ->CAMPO := Alltrim(ARQ->CAMPO)+Alltrim(Substr(SA2->A2_CGC,1,14))+";"+Alltrim(Substr(SA2->A2_NOME,1,150))+";"+Alltrim(Substr(cInscr,1,15))+";"
					ARQ->CAMPO := Alltrim(ARQ->CAMPO)+cRecIss+";"+Alltrim(Substr(SA2->A2_CEP,1,08))+";"+Alltrim(Substr(Substr (SA2->A2_END, At(" ",SA2->A2_END)+1, (At (",", SA2->A2_END)-At (" ", SA2->A2_END))-1),1,200))+";"
			   		ARQ->CAMPO := Alltrim(ARQ->CAMPO)+Alltrim(Substr(Substr (SA2->A2_END, At(",",SA2->A2_END)+1, Len (AllTrim (SA2->A2_END))),1,6))+";"+Alltrim(Substr(SA2->A2_BAIRRO,1,50))+";"
				   ARQ->CAMPO := Alltrim(ARQ->CAMPO)+Alltrim(Substr(SA2->A2_MUN,1,50))+";"+Alltrim(Substr(SA2->A2_EST,1,2))+";"+Alltrim(Substr(SA2->A2_DDD,1,2))+";" 
			    	MsUnLock()
				EndIf	
			EndIf	
		EndIf
	SF3->(DbSkip ())
	EndDo
	FsQuery (aSF3, 2)
EndIf
Return 