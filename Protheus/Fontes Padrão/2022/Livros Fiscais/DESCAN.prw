/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥DESCAN    ∫Autor  ≥Microsiga           ∫ Data ≥  08/08/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Funcao para processamento do livro fiscal de ISS onde ar-   ∫±±
±±∫          ≥ mazenas as informacoes em um arquivo trabalho para poste-  ∫±±
±±∫          ≥ riores leituras no .INI                                    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/ 
Function DESCAN (aTrbs)
Local	lRet		:=	.T.
Local	lProcessa	:=	.T.
Local	nX			:=	0
Local	aStru		:=	{}
Local	cArq		:=	""
Local	cDbf		:=	"F3_FILIAL='"+xFilial ("SF3")+"' .AND. DToS (F3_ENTRADA)>='"+DToS (MV_PAR01)+"' .AND. DToS (F3_ENTRADA)<='"+DToS (MV_PAR02)+"' .AND. F3_TIPO=='S' "
Local	cTop		:=	"F3_FILIAL='"+xFilial ("SF3")+"' AND F3_ENTRADA>='"+DToS (MV_PAR01)+"' AND F3_ENTRADA<='"+DToS (MV_PAR02)+"' AND F3_TIPO='S' "
Local	cDbfI		:=	"FI_FILIAL='"+xFilial ("SFI")+"' .AND. DToS (FI_DTMOVTO)>='"+DToS (MV_PAR01)+"' .AND. DToS (FI_DTMOVTO)<='"+DToS (MV_PAR02)+"' .AND. FI_ISS >0 "
Local	cTopI		:=	"FI_FILIAL='"+xFilial ("SFI")+"' AND FI_DTMOVTO>='"+DToS (MV_PAR01)+"' AND FI_DTMOVTO<='"+DToS (MV_PAR02)+"' AND FI_ISS >0 "
Local	cDbfD		:=	"D2_FILIAL='"+xFilial ("SD2")+"' .AND. DToS (D2_EMISSAO)>='"+DToS (MV_PAR01)+"' .AND. DToS (D2_EMISSAO)<='"+DToS (MV_PAR02)+"' .AND. !Empty(D2_PDV) .AND. Substr(D2_CF,1,1)$'5,6,7' .AND. D2_VALISS >0 "
Local	cTopD		:=	"D2_FILIAL='"+xFilial ("SD2")+"' AND D2_EMISSAO>='"+DToS (MV_PAR01)+"' AND D2_EMISSAO<='"+DToS (MV_PAR02)+"' AND D2_PDV <> ' ' AND (D2_CF LIKE '5%' OR D2_CF LIKE '6%' OR D2_CF LIKE '7%') AND D2_VALISS >0"
Local	aSF3		:=	{"SF3", ""}
Local	aSFI		:=	{"SFI", ""}
Local	aSD2		:=	{"SD2", ""}
Local	cRecIss		:=	""


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
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥TRB para o registro A1≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aStru	:=	{} 
	aAdd (aStru, {"A1_INSCM",		"C",	15,	0})
	aAdd (aStru, {"A1_CONT",		"C",	01,	0})
	aAdd (aStru, {"A1_CNPJ",		"C",	14,	0})
	aAdd (aStru, {"A1_RAZAO",		"C",	60,	0})
	aAdd (aStru, {"A1_TIPLOG", 		"C",	03,	0})
	aAdd (aStru, {"A1_NOMELOG",		"C",	40,	0})
	aAdd (aStru, {"A1_NUMLOG",		"C",	05,	0})
	aAdd (aStru, {"A1_COMPL",		"C",	40,	0})
	aAdd (aStru, {"A1_BAIRRO",		"C",	30,	0})
	aAdd (aStru, {"A1_CEP",			"C",	08,	0})
	aAdd (aStru, {"A1_CIDADE",		"C",	40,	0})
	aAdd (aStru, {"A1_ESTADO",		"C",	02,	0})	
	aAdd (aStru, {"A1_TIPOJUR",		"C",	01,	0})
	aAdd (aStru, {"A1_QTD",		    "N",	04,	0})
	cArq	:=	CriaTrab (aStru)
	aAdd (aTrbs, {cArq, "TA1"})
	
	DbUseArea (.T., __LocalDriver, cArq, "TA1")
	IndRegua ("TA1", cArq, "A1_CNPJ")
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥TA2 para o registro A2≥  
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ                     
	aStru	:=	{} 
	aAdd (aStru, {"A2_CNPJ",   "C",	    14,	0})
	aAdd (aStru, {"A2_INSCM",	"C",	15,	0})
	aAdd (aStru, {"A2_CONT",	"C",	01,	0})
	aAdd (aStru, {"A2_EMISSAO",	"C",	08,	0})
	aAdd (aStru, {"A2_DOC",		"C",	TamSX3("F2_DOC")[1],	0})
	aAdd (aStru, {"A2_CODBARR",	"N",	09,	0})
	aAdd (aStru, {"A2_SERIE",   "C",	02,	0})
	aAdd (aStru, {"A2_VALTOT",  "N",	13,	2})
	aAdd (aStru, {"A2_VALIMP",	"N",	13,	2})
	aAdd (aStru, {"A2_RET",		"C",	01,	0})    
	aAdd (aStru, {"A2_QTD",	    "N",	04,	0})	
	aAdd (aStru, {"A2_VTOTAL",  "N",	13,	2})
	aAdd (aStru, {"A2_VTIMP",	"N",	13,	2})
	aAdd (aStru, {"A2_VTRET",	"N",	13,	2})
	
	cArq	:=	CriaTrab (aStru)
	aAdd (aTrbs, {cArq, "TA2"})
	
	DbUseArea (.T., __LocalDriver, cArq, "TA2")
	IndRegua ("TA2", cArq, "A2_CNPJ+A2_EMISSAO")

	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥TA3 para o registro A3≥  
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ                     
	aStru	:=	{} 
	aAdd (aStru, {"A3_CNPJ",		"C",	14,	0}) 
	aAdd (aStru, {"A3_EMISSAO",		"C",	08,	0})
	aAdd (aStru, {"A3_DOC",	    	"C",	TamSX3("F2_DOC")[1],	0})
	aAdd (aStru, {"A3_SERIE", 	    "C",	02,	0})
	aAdd (aStru, {"A3_IDSERV",		"C",	04,	0})
	aAdd (aStru, {"A3_DESC",		"C",	64,	0})
	aAdd (aStru, {"A3_ALIQ",	    "N",	05,	2})
	aAdd (aStru, {"A3_BASE",		"N",	13,	2})
	aAdd (aStru, {"A3_QTD",		    "N",	04,	0})
	aAdd (aStru, {"A3_VTBASE",		"N",	13,	2})
			
	cArq	:=	CriaTrab (aStru)
	aAdd (aTrbs, {cArq, "TA3"})
	
	DbUseArea (.T., __LocalDriver, cArq, "TA3")
	IndRegua ("TA3", cArq, "A3_CNPJ+A3_EMISSAO")

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥TA9 para o registro A9≥  
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ                     
	aStru	:=	{} 
	aAdd (aStru, {"A9_QTD",		 "N",	07,	0})
	aAdd (aStru, {"A9_VTOTAL",	 "N",	13,	2})
	aAdd (aStru, {"A9_VBASE", 	 "N",	13,	2})
	aAdd (aStru, {"A9_VIMP",	 "N",	13, 2})
	aAdd (aStru, {"A9_VRET",	 "N",	13,	2})

	cArq	:=	CriaTrab (aStru)
	aAdd (aTrbs, {cArq, "TA9"})
	
	DbUseArea (.T., __LocalDriver, cArq, "TA9")


	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥TRB para o registro A1 - Servicos Pretados≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aStru	:=	{} 
	aAdd (aStru, {"P1_INSCM",		"C",	15,	0})
	aAdd (aStru, {"P1_CONT",		"C",	01,	0})
	aAdd (aStru, {"P1_CNPJ",		"C",	14,	0})
	aAdd (aStru, {"P1_RAZAO",		"C",	60,	0})
	aAdd (aStru, {"P1_TIPLOG", 		"C",	03,	0})
	aAdd (aStru, {"P1_NOMELOG",		"C",	40,	0})
	aAdd (aStru, {"P1_NUMLOG",		"C",	05,	0})
	aAdd (aStru, {"P1_COMPL",		"C",	40,	0})
	aAdd (aStru, {"P1_BAIRRO",		"C",	30,	0})
	aAdd (aStru, {"P1_CEP",	   		"C",	08,	0})
	aAdd (aStru, {"P1_CIDADE",		"C",	40,	0})
	aAdd (aStru, {"P1_ESTADO",		"C",	02,	0})	
	aAdd (aStru, {"P1_TIPOJUR",		"C",	01,	0})
	aAdd (aStru, {"P1_QTD",		    "N",	04,	0})

	cArq	:=	CriaTrab (aStru)
	aAdd (aTrbs, {cArq, "TP1"})
	
	DbUseArea (.T., __LocalDriver, cArq, "TP1")
	IndRegua ("TP1", cArq, "P1_CNPJ")
    
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥TB1 para o registro B1≥  
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ                     
	aStru	:=	{} 
	aAdd (aStru, {"B1_INSCM",		"C",	15,	0})
	aAdd (aStru, {"B1_CONT",		"C",	01,	0})
	aAdd (aStru, {"B1_CNPJ",		"C",	14,	0})
	aAdd (aStru, {"B1_DOC",	   		"C",	TamSX3("F2_DOC")[1],	0})  
	aAdd (aStru, {"B1_SERIE", 	    "C",	TamSx3("F3_SERIE")[1],	0})
	aAdd (aStru, {"B1_CODBARR",		"N",	09,	0})
	aAdd (aStru, {"B1_EMISSAO",		"C",	08,	0})
	aAdd (aStru, {"B1_VALTOT",	    "N",	13,	2})
	aAdd (aStru, {"B1_VALIMP",		"N",	13,	2})
	aAdd (aStru, {"B1_RET",			"C",	01,	0})
	aAdd (aStru, {"B1_TPOPER", 		"C",	01,	0})
	aAdd (aStru, {"B1_TIPOJUR",		"C",	01,	0})
	aAdd (aStru, {"B1_QTD",		    "N",	04,	0})
	aAdd (aStru, {"B1_SDOC", 	    "C",	02,	0})
		
	cArq	:=	CriaTrab (aStru)
	aAdd (aTrbs, {cArq, "TB1"})
	
	DbUseArea (.T., __LocalDriver, cArq, "TB1")
	IndRegua ("TB1", cArq, "B1_DOC+B1_SERIE+B1_CNPJ")
	
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥TB2 para o registro B2≥  
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aStru	:=	{}                     
	aAdd (aStru, {"B2_CNPJ",			"C",	14,	0})
	aAdd (aStru, {"B2_DOC",	    	"C",	002,0})
	aAdd (aStru, {"B2_SERIE", 	   	"C",	02,	0})
	aAdd (aStru, {"B2_IDSERV",		"C",	04,	0})
	aAdd (aStru, {"B2_DESC",			"C",	64,	0})
	aAdd (aStru, {"B2_ALIQ",	    	"N",	05,	2})
	aAdd (aStru, {"B2_BASE",			"N",	13,	2})
	aAdd (aStru, {"B2_QTD",		   	"N",	04,	0})
	
	cArq	:=	CriaTrab (aStru)
	aAdd (aTrbs, {cArq, "TB2"})
	
	DbUseArea (.T., __LocalDriver, cArq, "TB2")
	IndRegua ("TB2", cArq, "B2_DOC+B2_SERIE+B2_CNPJ")
  

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥TB3 para o registro B3≥  
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aStru	:=	{}                     
	aAdd (aStru, {"B3_EMISSAO",		"C",	08,	0})
	aAdd (aStru, {"B3_NUMMAQ",	   	"C",	03,	0})
	aAdd (aStru, {"B3_NUMINI", 	    "C",	TamSX3("F2_DOC")[1],	0})
	aAdd (aStru, {"B3_NUMFIM",		"C",	TamSX3("F2_DOC")[1],	0})
	aAdd (aStru, {"B3_VTOTAL",		"N",	13,	2})
	
	cArq	:=	CriaTrab (aStru)
	aAdd (aTrbs, {cArq, "TB3"})
	
	DbUseArea (.T., __LocalDriver, cArq, "TB3")
	IndRegua ("TB3", cArq, "B3_EMISSAO+B3_NUMMAQ")



	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥TB4 para o registro B4≥  
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aStru	:=	{}                     
	aAdd (aStru, {"B4_ALIQ",	   	"N",	05,	2})
	aAdd (aStru, {"B4_VBASE", 	    "N",	13,	2})
	aAdd (aStru, {"B4_VIMP",		"N",	13,	2})

	
	cArq	:=	CriaTrab (aStru)
	aAdd (aTrbs, {cArq, "TB4"})
	
	DbUseArea (.T., __LocalDriver, cArq, "TB4")
	IndRegua ("TB4", cArq, "STR(B4_ALIQ,5,2)")

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥TRG Registro Geral≥  
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aStru	:=	{}                 
	aAdd (aStru, {"CNPJ",   		"C",	015,	0})	    
	aAdd (aStru, {"CAMPO",			"C",	261,	0})
	
	cArq	:=	CriaTrab (aStru)
	aAdd (aTrbs, {cArq, "TRG"})
	
	DbUseArea (.T., __LocalDriver, cArq, "TRG")
	IndRegua ("TRG", cArq, "CNPJ")
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Processamento para alimentar os TRBs criados acima≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	DbSelectArea ("SF3")
	SF3->(DbSetOrder (1))
	FsQuery (aSF3, 1, cTop, cDbf, SF3->(IndexKey ()))
	SF3->(DbGoTop ())                                                                       
	Do While !SF3->(Eof ()) 

		If Left (SF3->F3_CFO, 1)>="5"
		    //Prestador
			DbSelectArea ("SA1")
			SA1->(DbSetOrder (1))
			If SA1->(DbSeek (xFilial ("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
				If !TP1->(DbSeek (SA1->A1_CGC))
					RecLock ("TP1", .T.)
					TP1->P1_INSCM   := AllTrim (SA1->A1_INSCRM)
					TP1->P1_CONT    := Iif("CANDEIAS"$UPPER(SA1->A1_MUN),"S","N")
					TP1->P1_CNPJ    := SA1->A1_CGC
					TP1->P1_RAZAO   := AllTrim (SA1->A1_NOME)
					TP1->P1_TIPLOG  := Iif(Substr(UPPER(SA1->A1_END),1,1)$"R","R.",Substr(UPPER(SA1->A1_END),1,3))
					TP1->P1_NOMELOG := SubStr(AllTrim (SA1->A1_END),Iif(At (" ", SA1->A1_END)>0,At (" ", SA1->A1_END)+1,1),Iif (AT(",", SA1->A1_END) > 0,Iif((AT(",", SA1->A1_END)>At (" ", SA1->A1_END)),(AT(",", SA1->A1_END)- At (" ", SA1->A1_END)),AT(",", SA1->A1_END)) - 1, 40))
					TP1->P1_NUMLOG  := Iif(At (",", SA1->A1_END)>0,AllTrim (SubStr (SA1->A1_END, At (",", SA1->A1_END)+1)),"")
					TP1->P1_COMPL   := ""
					TP1->P1_BAIRRO  :=	AllTrim (SA1->A1_BAIRRO)
					TP1->P1_CEP     :=	AllTrim (SA1->A1_CEP)
					TP1->P1_CIDADE  := AllTrim (SA1->A1_MUN)
					TP1->P1_ESTADO  :=	AllTrim (SA1->A1_EST)
					TP1->P1_TIPOJUR := SA1->A1_PESSOA
					TP1->P1_QTD     += 1
					MsUnLock()
				EndIf
	   
		
				If !Empty(SF3->F3_RECISS)
					cRecIss		:=	Iif (SF3->F3_RECISS$"1S", "S", "N")
				Else
					cRecIss		:=	Iif (SA1->A1_RECISS$"1S", "S", "N")
				EndIf
				
				If !TB1->(DbSeek (SF3->F3_NFISCAL+SF3->F3_SERIE+SA1->A1_CGC))
					RecLock ("TB1", .T.)
					TB1->B1_CNPJ       	:= SA1->A1_CGC
					TB1->B1_DOC       	:= SF3->F3_NFISCAL
					TB1->B1_SERIE       := SF3->F3_SERIE  
					TB1->B1_INSCM       := SA1->A1_INSCRM
					TB1->B1_CONT       	:= Iif("CANDEIAS"$SA1->A1_MUN,"S","N")
					TB1->B1_CODBARRA   	:= 0
	            	TB1->B1_EMISSAO  		:= Dtos(SF3->F3_EMISSAO)
					TB1->B1_VALTOT     	:= SF3->F3_VALCONT
					TB1->B1_VALIMP     	:= SF3->F3_VALICM
					TB1->B1_RET        	:= cRecIss     
					TB1->B1_TPOPER   		:= Iif (!Empty (SF3->F3_DTCANC) .Or. "CANCELAD"$SF3->F3_OBSERV,"C","E")
					TB1->B1_TIPOJUR    	:= SA1->A1_PESSOA  
					TB1->B1_SDOC       	:= SerieNfId("SF3",2,"F3_SERIE") 
					MsUnLock()    
				End If                              
			
				If !TB2->(DbSeek (SF3->F3_NFISCAL+SF3->F3_SERIE+SA1->A1_CGC)) 
					RecLock ("TB2", .T.)
					TB2->B2_CNPJ    	:= SA1->A1_CGC  
					TB2->B2_DOC     	:= SF3->F3_NFISCAL					
					//Nao serah necessario atribuir a funcao SerieNfId para o campo serie da tabela TB2
					//Pois ele eh utilizado somente para a quebra do registro, e nao eh gravado no arquivo texto
					TB2->B2_SERIE   	:= SF3->F3_SERIE	
					TB2->B2_IDSERV  	:= Iif(!Empty(SF3->F3_CFPS) ,SF3->F3_CFPS,"")
					TB2->B2_DESC    	:= ""
					TB2->B2_ALIQ    	:= SF3->F3_ALIQICM
					TB2->B2_BASE    	+= SF3->F3_BASEICM
					MsUnLock()
	            End If
			EndIf
			
		Else 
			//⁄ƒƒƒƒƒƒƒø
			//≥TOMADOR≥
			//¿ƒƒƒƒƒƒƒŸ
			DbSelectArea ("SA2")
			SA2->(DbSetOrder (1))
			If SA2->(DbSeek (xFilial ("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA))  
				If !TA1->(DbSeek (SA2->A2_CGC))
					RecLock ("TA1", .T.)
					TA1->A1_INSCM   := AllTrim (SA2->A2_INSCRM)
					TA1->A1_CONT    := Iif("CANDEIAS"$UPPER(SA2->A2_MUN),"S","N")
					TA1->A1_CNPJ    := SA2->A2_CGC
					TA1->A1_RAZAO   := AllTrim (SA2->A2_NOME)
					TA1->A1_TIPLOG  := Substr(UPPER(SA2->A2_END),1,3)
					TA1->A1_NOMELOG := SubStr(AllTrim (SA2->A2_END),Iif(At (" ", SA2->A2_END)>0,At (" ", SA2->A2_END)+1,1),Iif (AT(",", SA2->A2_END) > 0,Iif((AT(",", SA2->A2_END)>At (" ", SA2->A2_END)),(AT(",", SA2->A2_END)- At (" ", SA2->A2_END)),AT(",", SA2->A2_END)) - 1, 40))
					TA1->A1_NUMLOG  := Iif(At (",", SA2->A2_END)>0,AllTrim (SubStr (SA2->A2_END, At (",", SA2->A2_END)+1)),"")
					TA1->A1_COMPL   := ""
					TA1->A1_BAIRRO  :=	AllTrim (SA2->A2_BAIRRO)
					TA1->A1_CEP     :=	AllTrim (SA2->A2_CEP)
					TA1->A1_CIDADE  := AllTrim (SA2->A2_MUN)
					TA1->A1_ESTADO  :=	AllTrim (SA2->A2_EST)
					TA1->A1_TIPOJUR := SA2->A2_TIPO
					TA1->A1_QTD     += 1
					MsUnLock()
				EndIf
		
				If !Empty(SF3->F3_RECISS)
					cRecIss		:=	Iif (SF3->F3_RECISS$"2N", "N", "S")
				Else
					cRecIss		:=	Iif (SA2->A2_RECISS$"2N", "N", "S")
				EndIf
			    
			If !TA2->(DbSeek (SA2->A2_CGC+DTOS(SF3->F3_EMISSAO)))
					RecLock ("TA2", .T.)
					TA2->A2_CNPJ    :=	SA2->A2_CGC 
					TA2->A2_EMISSAO := Dtos(SF3->F3_EMISSAO)	
					TA2->A2_DOC     :=	SF3->F3_NFISCAL
					TA2->A2_SERIE   :=	SerieNfId("SF3",2,"F3_SERIE")
					TA2->A2_INSCM   := AllTrim (SA2->A2_INSCRM)
					TA2->A2_CONT    := Iif("CANDEIAS"$UPPER(SA1->A1_MUN),"S","N")
					TA2->A2_DOC     :=	SF3->F3_NFISCAL
					TA2->A2_CODBARR := 0
					TA2->A2_VALTOT  := SF3->F3_VALCONT
					TA2->A2_VALIMP  := SF3->F3_VALICM
					TA2->A2_RET     := cRecIss

				ELSE					
					RecLock ("TA2", .F.)          
                EndIf					
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥VALOR TOTAL,TOTAL IMPOSTO E TOTAL IMPOSTO RETIDO ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ	

				TA2->A2_VTOTAL  += SF3->F3_VALCONT
				TA2->A2_VTIMP   += SF3->F3_VALICM
				TA2->A2_VTRET   += Iif(cRecIss$"S",SF3->F3_VALICM,0) 
				TA2->A2_QTD     += 1
				MsUnLock() 
				                                                          
				If !TA3->(DbSeek (SA2->A2_CGC+DTOS(SF3->F3_EMISSAO)))
					RecLock ("TA3", .T.)
					TA3->A3_CNPJ    :=	SA2->A2_CGC 
					TA3->A3_EMISSAO := Dtos(SF3->F3_EMISSAO)   
					TA3->A3_DOC     :=	SF3->F3_NFISCAL
					TA3->A3_SERIE   :=	SerieNfId("SF3",2,"F3_SERIE")	
					TA3->A3_IDSERV  := Iif(!Empty(SF3->F3_CFPS) ,SF3->F3_CFPS,"")
					TA3->A3_DESC    := ""
					TA3->A3_ALIQ    := SF3->F3_ALIQICM
					TA3->A3_BASE    := SF3->F3_BASEICM  

                Else                    
                	RecLock ("TA3", .F.)
                End If

		        //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥TOTAL VALOR BASE≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ	
				TA3->A3_VTBASE  += SF3->F3_BASEICM 
				TA3->A3_QTD     += 1 
				MsUnLock() 
			EndIf
		EndIf	
	
		SF3->(DbSkip ())
	EndDo
	FsQuery (aSF3, 2)
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥TB3 Registro B3 - PDV OU EF≥  
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ   
dbSelectArea("SFI")              
SFI->(DbSetOrder (1))
FsQuery (aSFI, 1, cTopI, cDbfI, SFI->(IndexKey ()))
SFI->(DbGoTop ())       

While SFI->(!Eof())                                              
	If !TB3->(DbSeek (DTOS(SFI->FI_DTMOVTO)+SFI->FI_PDV)) 
		RecLock ("TB3", .T.)
		TB3->B3_EMISSAO :=	DTOS(SFI->FI_DTMOVTO)
		TB3->B3_NUMMAQ :=	SFI->FI_PDV
		TB3->B3_NUMINI  :=	SFI->FI_NUMINI
		TB3->B3_NUMFIM  :=	SFI->FI_NUMFIM
		TB3->B3_VTOTAL  :=	SFI->FI_VALCON+SFI->FI_DESC	+SFI->FI_CANCEL+SFI->FI_ISS
		MsUnLock()
	EndIf
	SFI->(DbSkip ())
EndDo
FsQuery (aSFI, 2)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥TB4 Registro B4 - PDV OU ECF≥  
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ   
dbSelectArea("SD2")              
SD2->(DbSetOrder (1))
FsQuery (aSD2, 1, cTopD, cDbfD, SD2->(IndexKey ()))
SD2->(DbGoTop ())       

While SD2->(!Eof())                                              
	If !TB4->(DbSeek (Str(SD2->D2_ALIQISS,5,2))) 
		RecLock ("TB4", .T.)
		TB4->B4_ALIQ    := SD2->D2_ALIQISS
	Else
		RecLock ("TB4", .F.)              
	EndIf	
		TB4->B4_VBASE   +=	SD2->D2_BASEISS
		TB4->B4_VIMP    +=	SD2->D2_VALISS
		MsUnLock()

	SD2->(DbSkip ())
EndDo
FsQuery (aSD2, 2)
   	
GeraRegDesCan()
Return (lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GeraRegistros∫Autor  ≥Microsiga           ∫ Data ≥  09/08/2006 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Funcao para processamento do livro fiscal de ISS onde ar-      ∫±±
±±∫          ≥ mazenas as informacoes em um arquivo trabalho para poste-     ∫±±
±±∫          ≥ riores leituras no .INI                                       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function GeraRegDesCan()
Local nQtdA1 :=0
Local nQtdA2 :=0
Local nQtdA3 :=0   
Local nVTotal :=0
Local nVTBase :=0
Local nVTImp  :=0
Local nVTRet  :=0

dbSelectArea("TA1")
TA1->(dbGoTop())
While TA1->(!eof()) 
	
	IF TA1->(dbSeek(TA1->A1_CNPJ))	
		IF !TRG->(dbSeek(TA1->A1_CNPJ))  
			RecLocK("TRG",.T.)
 			   	TRG->CNPJ	:= TA1->A1_CNPJ						
                TRG->CAMPO	:="A1"+TA1->A1_INSCM+TA1->A1_CONT+TA1->A1_CNPJ+TA1->A1_RAZAO+TA1->A1_TIPLOG+TA1->A1_NOMELOG+TA1->A1_NUMLOG+TA1->A1_COMPL+TA1->A1_BAIRRO+ TA1->A1_CEP+TA1->A1_CIDADE+TA1->A1_ESTADO+TA1->A1_TIPOJUR
                nQtdA1      += TA1->A1_QTD
    	    IF TA2->(dbseek(TA1->A1_CNPJ)) 
	           While TA2->(!eof()) .and.TA1->A1_CNPJ == TA2->A2_CNPJ
				     RecLocK("TRG",.T.)	
   				     TRG->CNPJ	:=TA2->A2_CNPJ						
   	                 TRG->CAMPO	:="A2"+TA2->A2_INSCM+TA2->A2_CONT+TA2->A2_EMISSAO+RetNf(TA2->A2_DOC,6,"C")+Space((6-Len(RetNf(TA2->A2_DOC,6,"C"))))+StrZero(TA2->A2_CODBARRA,9)+TA2->A2_SERIE+NUM2CHR(TA2->A2_VALTOT,13,2)+NUM2CHR(TA2->A2_VALIMP,13,2)+TA2->A2_RET
	                 nVTotal    += TA2->A2_VTOTAL
	                 nVTImp     += TA2->A2_VTIMP
	                 nVTRet     += TA2->A2_VTRET
	                 nQtdA2     += TA2->A2_QTD
				     TA2->(dbSkip())		            
			   EndDo 
			Endif
	   	    IF TA3->(dbseek(TA1->A1_CNPJ)) 
	           While TA3->(!eof()) .and.TA1->A1_CNPJ == TA3->A3_CNPJ
				     RecLocK("TRG",.T.)	
   				     TRG->CNPJ	:=TA3->A3_CNPJ						
   	                 TRG->CAMPO	:="A3"+TA3->A3_IDSERV+TA3->A3_DESC+NUM2CHR(TA3->A3_ALIQ,5,2)+NUM2CHR(TA3->A3_BASE,13,2)
	                 nVTbase    += TA3->A3_VTBASE
   	                 nQtdA3     += TA3->A3_QTD
    			     TA3->(dbSkip())		            
			   EndDo 
			Endif		  
		EndIf    
    EndIf
    MsUnlock() 
	TA1->(dbSkip())    
EndDo
  
  RecLocK("TA9",.T.)  
  TA9->A9_QTD	 := nQtdA1+nQtdA2+nQtdA3
  TA9->A9_VTOTAL := nVTotal
  TA9->A9_VBASE	 := nVTBase
  TA9->A9_VIMP   := nVTImp
  TA9->A9_VRET   :=nVTRet
  MsUnlock()    	

return
‹‹‹‹‹‹‹‹‹‹‹‹‹‹
