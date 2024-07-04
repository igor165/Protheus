#Include "Protheus.ch"
#Include "MATR926.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATR926      ³Autor³Gustavo G. Rueda      ³ Data ³ 31.08.2004		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime Relacao de fornecedores e notas fiscais conforme art. 223	³±±
±±³          ³inciso II do anexo IX do Decreto 73.080/2002-RICMS-MG.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Matr926 ()
	Local 	aArea		:= 	GetArea ()
	Local 	cPerg		:= 	"MTR926"
	Local 	nOpca		:=	0
	Local	lRet		:=	.T.
	Local 	cTitulo  	:= STR0030	//"Decreto 73.080/2002-RICMS-MG (Art. 223 inciso II do anexo IX)."
	Local 	cDesc1  	:= STR0064
	Local 	cDesc2  	:= ""
	Local 	cDesc3  	:= ""
	Local 	wnrel   	:= "Matr926"
	Local 	NomeProg	:= "Matr926"	
	Local	cString		:=	""
	Local 	Tamanho 	:= 	"G" 	// P/M/G
	Local 	lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
	Private Limite     :=  220    	// 80/132/220
	Private lEnd    	:= 	.F.		// Controle de cancelamento do relatorio
	Private m_pag   	:= 	1  		// Contador de Paginas
	Private nLastKey	:=	0  		// Controla o cancelamento da SetPrint e SetDefault
	Private aReturn 	:= {STR0031, 1, STR0032, 2, 2, 1, "", 1 }	//"Zebrado"###"Administracao"
	//
	If lVerpesssen
		Pergunte (cPerg, .F.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| STR0030 = "Matr916 - Relacao das entradas e saidas de mercadorias em estabelecimento de produtor. "|
		//| STR0033	= "Destinados aos adquirentes de sucatas provenientes de fora do Estado, para fazer jus ao"|
		//| STR0034	= "credito do imposto relativo a operacao.                                                "|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FormBatch (OemToAnsi (STR0030), {;
			OemToAnsi (STR0033), OemToAnsi (STR0034)},;
			{{5, .T., {|o| Pergunte (cPerg, .T.)}},;
			{ 1, .T., {|o| nOpca := 1, o:oWnd:End()}},;
			{ 2, .T., {|o| nOpca := 2, o:oWnd:End()}}})
		//
		If (nOpca==1)				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Envia para a SetPrinter                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			wnrel	:=	SetPrint (cString, NomeProg, cPerg, @cTitulo, cDesc1, cDesc2, cDesc3, .F.,, .F., Tamanho,, .F.)
			//
			If (nLastKey==27)
				Return (lRet)
			Endif
			//
			SetDefault (aReturn, cString)
			//
			If (nLastKey==27)
				Return (lRet)
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preparacao do inicio de processamento do arquivo pre-formatado          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RptStatus ({|lEnd|R926ProcRel (@lEnd)}, cTitulo)
			//
			If (aReturn[5]==1)
				Set Printer To 	
				ourspool(wnrel)
			Endif
			MS_FLUSH()
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura area ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RestArea (aArea)
	EndIf
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R926ProcRel  ³Autor³Gustavo G. Rueda      ³ Data ³ 31.08.2004		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento das informacoes necessarias para o relatorio.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R926ProcRel (lEnd)
	Local	lRet		:=	.T.	
	Local	cAliasSF3	:=	"SF3"
	Local	cQuery		:=	""
	Local	aStrTrb		:=	{}	
	Local	cArqTrb		:=	""
	Local	cAliasSa2	:=	"SA2"
	Local	cChave		:=	""
	Local	cIndSf3		:=	""
	Local	nAliqSd1	:=	0
	Local	nValCont	:=	0
	Local	nBaseIcm	:=	0
	Local	nValIcm		:=	0
	Local	nIsenIcm	:=	0
	Local	nOutrIcm	:=	0
	Local	nItem		:=	0
	Local	cMVEXCTES	:=	GetNewPar("MV_EXCTES","")
	Local	cMVEXCCFO	:=	GetNewPar("MV_EXCCFO","")
	Local 	lR926FILT	:=	ExistBlock("R926FILT")
	//
	#IFDEF TOP
		Local	aStruSF3	:=	{}
		Local	nSf3		:=	0
		Local	aCamposSf3	:=	{}
	#ENDIF
	//
	aAdd (aStrTrb, {"TRB_DIAENT",	"C",	002,	0})	//Dia Entrada
	aAdd (aStrTrb, {"TRB_ESPEC",	"C",	003,	0})	//Especie NF
	aAdd (aStrTrb, {"TRB_SERIE",	"C",	SerieNfId("SF3",6,"F3_SERIE"),	0})	//Serie NF
	aAdd (aStrTrb, {"TRB_NUMNF",	"C",	TamSX3("F2_DOC")[1],	0})	//Numero NF
	aAdd (aStrTrb, {"TRB_DATANF",	"D",	008,	0})	//Data NF
	aAdd (aStrTrb, {"TRB_RAZAO",	"C",	037,	0})	//Razao Social NF
	aAdd (aStrTrb, {"TRB_IE",		"C",	014,	0})	//Inscr. Estadual
	aAdd (aStrTrb, {"TRB_CGC",		"C",	014,	0})	//CGC
	aAdd (aStrTrb, {"TRB_UF",		"C",	002,	0})	//Estado 
	aAdd (aStrTrb, {"TRB_VLRCON",	"N",	016,	2})	//Valor Contabil
	aAdd (aStrTrb, {"TRB_CFOP",		"C",	004,	0})	//CFOP
	aAdd (aStrTrb, {"TRB_BSCALC",	"N",	016,	2})	//Base de Calculo
	aAdd (aStrTrb, {"TRB_ALIQ",		"N",	005,	2})	//Aliquota
	aAdd (aStrTrb, {"TRB_IMPCR",	"N",	016,	2})	//Imposto Creditado
	aAdd (aStrTrb, {"TRB_ISENT",	"N",	016,	2})	//Isentas
	aAdd (aStrTrb, {"TRB_OUTR",		"N",	016,	2})	//Outras
	//
	//Para Seek
	aAdd (aStrTrb, {"TRB_FORN",		"C",	006,	0})	//Forncedor
	aAdd (aStrTrb, {"TRB_LOJA",		"C",	002,	0})	//Loja
	//
	cArqTrb	:=	CriaTrab (aStrTrb)
	DbUseArea (.T., __LocalDriver, cArqTrb,"TRB")
	IndRegua ("TRB", cArqTrb, "TRB_NUMNF+TRB_SERIE+TRB_FORN+TRB_LOJA+TRB_CFOP+StrZero (TRB_ALIQ, 5, 2)")
	//
	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
		    cAliasSF3	:= 	"ProcRel"
			aStruSF3  	:= 	SF3->(dbStruct())
			//
			aAdd (aCamposSf3, "F3_EMISSAO")
	    	aAdd (aCamposSf3, "F3_FILIAL")
	    	aAdd (aCamposSf3, "F3_NFISCAL")
	    	aAdd (aCamposSf3, "F3_SERIE")
	    	aAdd (aCamposSf3, "F3_CLIEFOR")
	    	aAdd (aCamposSf3, "F3_LOJA")
	    	aAdd (aCamposSf3, "F3_CFO")
	    	aAdd (aCamposSf3, "F3_ESPECIE")
	    	aAdd (aCamposSf3, "F3_ENTRADA")
	    	aAdd (aCamposSf3, "F3_VALCONT")
	    	aAdd (aCamposSf3, "F3_BASEICM")
	    	aAdd (aCamposSf3, "F3_ALIQICM")
	    	aAdd (aCamposSf3, "F3_VALICM")
	    	aAdd (aCamposSf3, "F3_ISENICM")
	    	aAdd (aCamposSf3, "F3_OUTRICM")
	    	aAdd (aCamposSf3, "A2_NOME")
	    	aAdd (aCamposSf3, "A2_CGC")
	    	aAdd (aCamposSf3, "A2_INSCR")
	    	aAdd (aCamposSf3, "A2_EST")
	    	//
	    	cQuery	:=	"SELECT "
	    	For nSf3 := 1 To (Len (aCamposSf3)-1)
	    		cQuery	+=	aCamposSf3[nSf3]+", "
	    	Next (nSf3)
    		cQuery	+=	aCamposSf3[Len (aCamposSf3)]+" "
			//
			cQuery	+=	"FROM "
			cQuery	+=	RetSqlName ("SF3")+" SF3, "+RetSqlName ("SA2")+" SA2 "
			cQuery	+=	"WHERE "
			cQuery	+=	"SF3.F3_CLIEFOR=SA2.A2_COD AND "
			cQuery	+=	"SF3.F3_LOJA=SA2.A2_LOJA AND "
			cQuery	+=	"SF3.F3_FILIAL='"+xFilial ("SF3")+"' AND "
			cQuery	+=	"SF3.F3_ENTRADA>='"+DToS (MV_PAR01)+"' AND "
			cQuery	+=	"SF3.F3_ENTRADA<='"+DToS (MV_PAR02)+"' AND "
			cQuery	+=	"SF3.F3_TIPO NOT IN ('D','B') AND "
			cQuery	+=	"SF3.D_E_L_E_T_<>'*' AND "
			cQuery	+=	"SA2.D_E_L_E_T_<>'*' AND "
			cQuery	+=	"SUBSTRING(SF3.F3_CFO,1,1) IN('2') "
			//
			cQuery 	:= 	ChangeQuery (cQuery)
	    	//
			DbUseArea (.T., "TOPCONN", TcGenQry (,,cQuery), cAliasSF3, .T., .T.)
			//
			For nSF3 := 1 To (Len (aStruSF3))
				If (aStruSF3[nSF3][2]<>"C") 
					TcSetField (cAliasSF3, aStruSF3[nSF3][1], aStruSF3[nSF3][2], aStruSF3[nSF3][3], aStruSF3[nSF3][4])
				EndIf
			Next (nSF3)
		    
		Else
	#ENDIF	 
			DbSelectArea (cAliasSF3)
			cIndSF3		:=	CriaTrab (NIL,.F.)
			cChave		:=	IndexKey ()
			cQuery		:=	"SF3->F3_FILIAL=='"+xFilial ("SF3")+"' "
			cQuery		+=	".And. (DToS (SF3->F3_ENTRADA)>='"+DToS (MV_PAR01)+"') .And. (DToS (SF3->F3_ENTRADA)<='"+DToS (MV_PAR02)+"') "
			cQuery		+=	".And. (Left (SF3->F3_CFO, 1)$'2') .And. !SF3->F3_TIPO$'DB' "
			//
			IndRegua (cAliasSF3, cIndSF3, cChave,, cQuery, STR0035) //"Selec.Notas fiscais..."
	#IFDEF TOP
		Endif
	#ENDIF
	//
	DbSelectArea (cAliasSf3)
		SetRegua ((cAliasSf3)->(LastRec ()))
		//
		(cAliasSf3)->(DbGoTop ())
	Do While !(cAliasSf3)->(Eof ())
		//
		nItem	:=	0
		//
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso exista mais de um SF3 para a mesma nota fiscal desconsidero, este SEEK evita de gravar mais de uma vez dados referente a mesma NF.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TRB->(DbSeek ((cAliasSf3)->F3_NFISCAL+(cAliasSf3)->F3_SERIE+(cAliasSf3)->F3_CLIEFOR+(cAliasSf3)->F3_LOJA))
			(cAliasSf3)->(DbSkip ())
			Loop
		EndIf
		//
		#IFNDEF TOP
	    	DbSelectArea ("SA2")
	    		SA2->(DbSetOrder (1))
	    	SA2->(DbSeek (xFilial ("SA2")+(cAliasSf3)->F3_CLIEFOR+(cAliasSf3)->F3_LOJA))
	    	cAliasSa2	:=	"SA2"
	    #ELSE
	    	cAliasSa2	:=	cAliasSf3
        #ENDIF
        //
        DbSelectArea ("SF1")
        	SF1->(DbSetOrder (1))
        SF1->(DbSeek (xFilial ("SF1")+(cAliasSf3)->F3_NFISCAL+(cAliasSf3)->F3_SERIE+(cAliasSf3)->F3_CLIEFOR+(cAliasSf3)->F3_LOJA))
        //
        DbSelectArea ("SD1")
        	SD1->(DbSetOrder (1))
        SD1->(DbSeek (xFilial ("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
        //
        Do While !(SD1->(Eof ())) .And. (SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA==SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
        	//
        	DbSelectArea ("SB1")
        		SB1->(DbSetOrder (1))
        	SB1->(DbSeek (xFilial ("SB1")+SD1->D1_COD))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o ponto de entrada para efetuar outros filtros no SB1.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        	If lR926FILT
				If !ExecBlock("R926FILT",.F.,.F.)
	        		SD1->(dbSkip())
	        		Loop
	   			Endif
			Endif
			//
        	If !(SB1->B1_GRUPO>=MV_PAR06 .And. SB1->B1_GRUPO<=MV_PAR07) .Or.;
        		!(SD1->D1_TES>=MV_PAR08 .And. SD1->D1_TES<=MV_PAR09)
        		SD1->(DbSkip ())
        		Loop
        	EndIf
        	// Verificacao da TES e do CFOP que nao deve entrar no relatorio de sucata
        	If (AllTrim(SD1->D1_TES)$cMVEXCTES) .Or. (AllTrim(SD1->D1_CF)$cMVEXCCFO)
	       		SD1->(DbSkip ())
        		Loop
        	EndIf
	        //
	        nItem++
	        //
	        nAliqSd1	:=	xMagValFis (1,, "SF1", nItem, "LF_ALIQICMS")
	        nValCont	:=	xMagValFis (1,, "SF1", nItem, "LF_VALCONT")
	        nBaseIcm	:=	xMagValFis (1,, "SF1", nItem, "LF_BASEICM")
	        nValIcm		:=	xMagValFis (1,, "SF1", nItem, "LF_VALICM")
	        nIsenIcm	:=	xMagValFis (1,, "SF1", nItem, "LF_ISENICM")
	        nOutrIcm	:=	xMagValFis (1,, "SF1", nItem, "LF_OUTRICM")
		    //
	        DbSelectArea ("SF4")
	        	SF4->(DbSetOrder (1))
	        SF4->(DbSeek (xFilial ("SF4")+SD1->D1_TES))	        
	        //	        
	        If !(TRB->(DbSeek (SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SubStr (AllTrim (SD1->D1_CF), 1, 4)+StrZero (nAliqSd1, 5, 2))))
	        	RecLock ("TRB", .T.)
					TRB_DIAENT	:=	StrZero (Day ((cAliasSf3)->F3_ENTRADA), 2)
					TRB_ESPEC	:=	(cAliasSf3)->F3_ESPECIE
					TRB_SERIE	:=	SerieNfId("SD1",2,"D1_SERIE")
					TRB_NUMNF	:=	SD1->D1_DOC
					TRB_DATANF	:=	SD1->D1_EMISSAO
					TRB_RAZAO	:=	(cAliasSa2)->A2_NOME
					TRB_IE		:=	(cAliasSa2)->A2_INSCR
					TRB_CGC		:=	(cAliasSa2)->A2_CGC
					TRB_UF		:=	(cAliasSa2)->A2_EST
					TRB_CFOP	:=	SD1->D1_CF
					TRB_ALIQ	:=	nAliqSd1
					TRB_FORN	:=	SD1->D1_FORNECE
					TRB_LOJA	:=	SD1->D1_LOJA
	    	Else                                           
	        	RecLock ("TRB", .F.)
	        EndIf
				TRB_VLRCON	+=	nValCont
				TRB_BSCALC	+=	nBaseIcm
				TRB_IMPCR	+=	nValIcm
				TRB_ISENT	+=	nIsenIcm
				TRB_OUTR	+=	nOutrIcm
	       	MsUnLock ()
        	//
        	SD1->(DbSkip ())
		EndDo
		//
		IncRegua ()
		//
		(cAliasSf3)->(DbSkip ())
	EndDo
	//
	#IFDEF TOP
		(cAliasSf3)->(DbCloseArea ())
	#ELSE
	  	DbSelectArea (cAliasSf3)
		RetIndex (cAliasSf3)
		Set Filter to
		Ferase (cIndSF3+OrdBagExt())
	#ENDIF
	//
	DbSelectArea("TRB")
		Ferase (cArqTrb+GetDBExtension ())
		Ferase (cArqTrb+OrdBagExt ())
	IndRegua ("TRB", cArqTrb, "TRB->TRB_DIAENT+TRB_ESPEC+TRB_SERIE+TRB_NUMNF+DTOS (TRB_DATANF)")
	//
	R926ImpRel (@lEnd)
	//
	DbSelectArea("TRB")
		TRB->(DbCloseArea ())
		Ferase (cArqTrb+GetDBExtension ())
		Ferase (cArqTrb+OrdBagExt ())
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R926ImpRel   ³Autor³Gustavo G. Rueda      ³ Data ³ 31.08.2004		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do relatorio de acordo com a estrutura gerada na funcao ³±±
±±³          ³ProcRel.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R926ImpRel (lEnd)
	Local	lRet		:=	.T.
	Local	nLin		:=	99
	Local	aLay		:=	R926Lay ()
	Local	aDados		:=	{}
	Local	cDataNf		:=	""
	Local	cValCont	:=	""
	Local	cBaseIcm	:=	""
	Local	cAliq		:=	""
	Local	cImpCred	:=	""
	Local	cIsentas	:=	""
	Local	cOutras		:=	""
	Local	nFolha		:=	1
	Local	nTotVC		:=	0
	Local	nTotBI		:=	0
	Local	nTotIC		:=	0
	Local	nTotIsent	:=	0
	Local	nTotOutr	:=	0
	Local	nLinPag		:=	65
	//
	If Interrupcao(lEnd)
		Return (lRet)
	Endif
	//
	DbSelectArea ("TRB")
		SetRegua (TRB->(LastRec ()))
		TRB->(DbGoTop ())
	//
	Do While !(TRB->(Eof ()))
		If (nLin>=nLinPag)
			R926Cabec (@nFolha, @nLin, aLay)
		EndIf
		//
		cDataNf	:=	StrZero (Day (TRB_DATANF), 2)
		cDataNf	+=	"/"
		cDataNf	+=	StrZero (Month (TRB_DATANF), 2)
		cDataNf	+=	"/"
		cDataNf	+=	StrZero (Year (TRB_DATANF), 4)
		//
		nTotVC		+=	TRB_VLRCON
		cValCont	:=	Transform (TRB_VLRCON, "@E 9,999,999,999.99")
		nTotBI		+=	TRB_BSCALC
		cBaseIcm	:=	Transform (TRB_BSCALC, "@E 9,999,999,999.99")
		cAliq		:=	Transform (TRB_ALIQ, "@E 99.99")
		nTotIC		+=	TRB_IMPCR
		cImpCred	:=	Transform (TRB_IMPCR, "@E 9,999,999,999.99")
		nTotIsent	+=	TRB_ISENT
		cIsentas	:=	Transform (TRB_ISENT, "@E 9,999,999,999.99")
		nTotOutr	+=	TRB_OUTR
		cOutras		:=	Transform (TRB_OUTR, "@E 9,999,999,999.99")
		//
		aDados	:=	{TRB_DIAENT, TRB_ESPEC, TRB_SERIE, TRB_NUMNF, cDataNf, TRB_RAZAO, TRB_IE, TRB_CGC, TRB_UF, cValCont, TRB_CFOP, cBaseIcm, cAliq, cImpCred, cIsentas, cOutras}
		FmtLin (aDados, aLay[18],,, @nLin)
		//
		IncRegua ()
		//
		TRB->(DbSkip ())
	EndDo
	//
	If (nTotVC+nTotBI+nTotIC+nTotIsent+nTotOutr>0)
		If (nLin>=nLinPag-11)	//11-Significa a qtd de linha necessarias para imprimir o roda[e do relatorio.(totais e assinatura)
			R926Cabec (@nFolha, @nLin, aLay)
		EndIf
		//
		aDados	:=	{Transform (nTotVc, "@E 9,999,999,999.99"), Transform (nTotBI, "@E 9,999,999,999.99"), Transform (nTotIc, "@E 9,999,999,999.99"),;
			Transform (nTotIsent, "@E 9,999,999,999.99"), Transform (nTotOutr, "@E 9,999,999,999.99")}
		FmtLin (aDados, aLay[20],,, @nLin)
		//
		FmtLin (,aLay[21],,, @nLin)
		//
		aDados	:=	{R926Centr (AllTrim (SM0->M0_CIDENT)+", "+StrZero (Day (dDataBase), 2)+" DE "+MesExtenso (Month (dDataBase))+" DE "+StrZero (Year (dDataBase), 4)+".", 40)}
		FmtLin (aDados, aLay[22],,, @nLin)
		//
		FmtLin (,aLay[23],,, @nLin)
		FmtLin (,aLay[24],,, @nLin)
		FmtLin (,aLay[25],,, @nLin)
		FmtLin (,aLay[26],,, @nLin)
		//
		aDados	:=	{R926Centr (MV_PAR03, 40)}
		FmtLin (aDados, aLay[27],,, @nLin)
		//
		aDados	:=	{R926Centr (MV_PAR04, 40)}
		FmtLin (aDados, aLay[28],,, @nLin)
		//
		FmtLin (,aLay[29],,, @nLin)
	EndIf
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R926LAY      ³Autor³Gustavo G. Rueda      ³ Data ³ 31.08.2004		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Define a estrutura do layout a ser impresso.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R926LAY
	Local	aLayOut	:=	{}
							//"         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
							//"1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	aAdd (aLayOut, STR0001)	//"                        RELACAO DOS FORNECEDORES E DAS NOTAS FISCAIS A SEREM AUTENTICADAS EM ATENDIMENTO AO ARTIGO 223 INCISO II ANEXO IX DO DECRETO 43.080/2002 - RICMS-MG                              "
	aAdd (aLayOut, STR0002)	//"                                                                                                                                                                                                         "
	aAdd (aLayOut, STR0003)	//" DATA IMPRESSAO: ##########                                                       ########################################                                                                     FOLHA:####" 
	aAdd (aLayOut, STR0004)	//"                                                                                         CNPJ(M.F.): ##############                                                                                      "
	aAdd (aLayOut, STR0005)	//"                                                                                             IE: ##############                                                                                          "
	aAdd (aLayOut, STR0006)	//"                                                                                             IM: ##############                                                                                          "
	aAdd (aLayOut, STR0007)	//"                                                                                                                                                                                                         "
	aAdd (aLayOut, STR0008)	//"                                                                                       MES REFERENCIA: ##########/####                                                                                   "
	aAdd (aLayOut, STR0009)	//"                                                                                                                                                                                                         "
	aAdd (aLayOut, STR0010)	//"                                                                                                                              +-------------------------------------------------------------------------+"
	aAdd (aLayOut, STR0011)	//"                                                                                                                              |             ICMS - VALORES FISCAIS - OPERACOES DO IMPOSTO               |"
	aAdd (aLayOut, STR0012)	//"                                                                                                                              +---------------------------------------+---------------------------------+"
	aAdd (aLayOut, STR0013)	//"                                                                                                                              |              COM CREDITO              |           SEM CREDITO           |"
	aAdd (aLayOut, STR0014)	//"+---+---+---+---------+----------+-------------------------------------+--------------+--------------+--+----------------+----+----------------+-----+----------------+----------------+----------------+"
	aAdd (aLayOut, STR0015)	//"|DIA|ESP|SER| NUMERO  | DATA NF  |           RAZAO SOCIAL              |   INSCRICAO  | CNPJ (M.F.)  |UF| VALOR CONTABIL |CFOP|  BASE CALCULO  |ALIQ |     IMPOSTO    |     ISENTAS    |     OUTRAS     |"
	aAdd (aLayOut, STR0016)	//"|ENT|   |   |   NF    |          |                                     |   ESTADUAL   |              |  |                |    |                | (%) |    CREDITADO   | NAO TRIBUTADAS |                |"
	aAdd (aLayOut, STR0017)	//"+---+---+---+---------+----------+-------------------------------------+--------------+--------------+--+----------------+----+----------------+-----+----------------+----------------+----------------+"
	aAdd (aLayOut, STR0018)	//"| ##|###|###|#########|##########|#####################################|##############|##############|##|################|####|################|#####|################|################|################|"
	aAdd (aLayOut, STR0019)	//"+---+---+---+---------+----------+-------------------------------------+--------------+--------------+--+----------------+----+----------------+-----+----------------+----------------+----------------+"
	aAdd (aLayOut, STR0020)	//"|                                                                                                   SOMA|################|----|################|-----|################|################|################|"
	aAdd (aLayOut, STR0021)	//"+-------------------------------------------------------------------------------------------------------+----------------+----+----------------+-----+----------------+----------------+----------------+"
	aAdd (aLayOut, STR0022)	//"|                                                                                 ########################################                                                                              |"
	aAdd (aLayOut, STR0023)	//"|                                                                                                                                                                                                       |"
	aAdd (aLayOut, STR0024)	//"|                                                                                                                                                                                                       |"
	aAdd (aLayOut, STR0025)	//"|                                                                                                                                                                                                       |"
	aAdd (aLayOut, STR0026)	//"|                                                                                 ________________________________________                                                                              |"
	aAdd (aLayOut, STR0027)	//"|                                                                                 ########################################                                                                              |"
	aAdd (aLayOut, STR0028)	//"|                                                                                 ########################################                                                                              |"
	aAdd (aLayOut, STR0029)	//"+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
Return (aLayOut)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³R926Centr ³ Autor ³Gustavo G. Rueda       ³ Data ³31.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria pergunta no SX1.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cTexto -> Texto R926Centrdo no espaco delimitado            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTexto -> Texto a ser centralizado.                         ³±±
±±³          ³nTam -> Tamanho do espaco disponivel para o texto.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R926Centr (cTexto, nTam)
	Local	nN		:=	0
	Local	cRet	:=	""
	//
	nN		:=	(nTam-(Len (AllTrim (cTexto))))/2
	cRet	:=	Space (NoRound (nN))+AllTrim (cTexto)+Space (NoRound (nN))
Return (cRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³R926Cabec ³ Autor ³Gustavo G. Rueda       ³ Data ³31.08.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta os cabecalhos das paginas.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nFolha -> Numero da folha a ser gerada o cabecalho.         ³±±
±±³          ³nLin -> Numero da linha para impressao.                     ³±±
±±³          ³aLay -> Layout utilizado para impressao.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R926Cabec (nFolha, nLin, aLay)
	Local	cDataImp	:=	""
	Local	aDados		:=	{}
	Local	nInd		:=	0
	Local	lRet		:=	.T.
	//
	If !(nFolha==1)
		FmtLin (,aLay[19],,, @nLin)
	EndIf
	//
	nLin	:=	0
	@ nLin,000 PSAY aValImp(Limite)
	//
	FmtLin (,aLay[1],,, @nLin)
	FmtLin (,aLay[2],,, @nLin)
	//
	cDataImp	:=	StrZero (Day (dDataBase), 2)+"/"+StrZero (Month (dDataBase), 2)+"/"+StrZero (Year (dDataBase), 4)
	aDados	:=	{cDataImp, R926Centr (SM0->M0_NOMECOM, 40), StrZero (nFolha, 3)}
	FmtLin (aDados, aLay[3],,, @nLin)
	nFolha++
	//
	aDados	:=	{SM0->M0_CGC}
	FmtLin (aDados, aLay[4],,, @nLin)
	//
	aDados	:=	{SM0->M0_INSC}
	FmtLin (aDados, aLay[5],,, @nLin)
	//
	aDados	:=	{MV_PAR05}
	FmtLin (aDados, aLay[6],,, @nLin)
	//
	FmtLin (,aLay[7],,, @nLin)
	//
	aDados	:=	{Space (10-Len (MesExtenso (Month (MV_PAR01))))+MesExtenso (Month (MV_PAR01)), StrZero (Year (MV_PAR01), 4)}
	FmtLin (aDados, aLay[8],,, @nLin)
	//
	For nInd := 9 To 17
		FmtLin (,aLay[nInd],,, @nLin)
	Next (nId)
Return (lRet)
