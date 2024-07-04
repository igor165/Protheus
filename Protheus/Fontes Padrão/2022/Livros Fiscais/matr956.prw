#INCLUDE "MATR956.CH"
#DEFINE MASCVAL "@E 9999,999,999,999.99"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MATR956   ³ Autor ³Gustavo G. Rueda       ³ Data ³13.05.2005|±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³DEMONSTRATIVO DAS ENTRADAS E SAIDAS DE MERCADORIAS.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 -> lRet = Retorno sempre .T.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATR956 ()
	Local 	NomeProg	:= 	"MATR956"
	Local 	aArea		:= 	GetArea ()
	Local 	cPerg		:= 	"MTR956"
	Local	lRet		:=	.T.
	Local 	cTitulo  	:=	STR0001	//"Demonstrativo das Entradas e Saídas de mercadorias"
	Local 	cDesc1  	:= 	STR0002	//"Relação de entradas e saídas de mercadorias no mês de referencia de acordo com o layout 17.986, de 10/12/2004 do Rio Grande do Norte."
	Local 	cDesc2  	:= 	""
	Local 	cDesc3  	:= 	""
	Local 	wnrel   	:= 	NomeProg
	Local	cString		:=	""
	Local 	Tamanho 	:= 	"P" 	// P/M/G
	Private Limite 		:= 	80		// 80/132/220
	Private lEnd    	:= 	.F.		// Controle de cancelamento do relatorio
	Private m_pag   	:= 	1  		// Contador de Paginas
	Private nLastKey	:=	0  		// Controla o cancelamento da SetPrint e SetDefault
	Private aReturn 	:= 	{STR0003, 1, STR0004, 2, 2, 1, "", 1 }	//"Zebrado"###"Administracao"
	//
	Pergunte (cPerg, .F.)
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
	RptStatus ({|lEnd| R956Proc (@lEnd, cTitulo, wnrel, Tamanho)}, cTitulo)
	//
	If (aReturn[5]==1)
		Set Printer To 	
	   	ourspool(wnrel)
	Endif
	MS_FLUSH()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura area ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea (aArea)
Return ()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R956Base  ³ Autor ³Gustavo G. Rueda       ³ Data ³16/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta o TRB com a base a ser processada.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 - Variavel de controle para Criacao/Delecao do TRB.   ³±±
±±³          ³ExpA1 - Trb criado 1-Alias, 2-Nome Fisico.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 -> lRet = Retorno sempre .T.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATR956                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R956Base (nOpcao, aTrb)
	Local	aStru		:=	{}
	Local	cArq		:=	""
	Local	aSf3		:=	{"SF3", ""}
	Local	cAno		:=	StrZero (MV_PAR02, 4)
	Local	cMes		:=	StrZero (MV_PAR01, 2)
	Local	cQuery		:=	"F3_FILIAL='"+xFilial ("SF3")+"' AND F3_ENTRADA>='"+cAno+cMes+"01"+"' AND F3_ENTRADA<='"+cAno+cMes+"31"+"' AND F3_TIPO NOT IN ('D','B') AND F3_DTCANC='' AND F3_CODISS='' AND SUBSTRING(F3_CFO, 1, 1) NOT IN ('7')"



	Local	cFilter		:=	'F3_FILIAL="'+xFilial ("SF3")+'" .And. DToS (F3_ENTRADA)>="'+cAno+cMes+"01"+'" .And. DToS (F3_ENTRADA)<="'+cAno+cMes+"31"+'" .And. !F3_TIPO$"DB" .And. Empty (F3_DTCANC) .And. Empty (F3_CODISS) .And. !SubStr (F3_CFO, 1, 1)$"7" '
	Local	lContrib	:= 	.F.
	Local	lMVR956A1	:=	!GetNewPar ("MV_R956A1", "XXX")=="XXX"
	Local	nMVR956A1	:=	Iif (lMVR956A1, SA1->(FieldPos (SuperGetMv ("MV_R956A1"))), 0)
	Local	lExcessao	:=	.F.
	//
	//Finaliza o TRB criado para processamento.
	If (nOpcao==2)
		FsQuery (aSf3, 2)
		//
		DbSelectArea (aTrb[1])
			(aTrb[1])->(DbCloseArea ())
		Ferase (aTrb[2]+GetDBExtension ())
		Ferase (aTrb[2]+OrdBagExt ())
		//
		Return (.T.)
	EndIf
	//
	If !(lMVR956A1)
		xMagHelpFis (STR0005,;	//"Parâmetro não existe"
			STR0006,;	//"Parâmetro [MV_R956A1] não existe no cadastro de parâmetros (Tabela SX6)."
			STR0007)	//"Para que seja tratado Hospitais, Casas de Saúde e Estabelecimento Congenêres é necessário criar o parâmetro MV_R956A1 e relaionar um campo da tabela SA1 que identificque através de S=SIM ou N=NAO este tratamento."
	Else
		If (nMVR956A1)==0
			xMagHelpFis (STR0008,;	//"Campo não existe"
				STR0009,;	//"Campo relaionado no parâmetro [MV_R956A1] não existe no dicionario de dados para a tabela SA1."
				STR0010)	//"Para que seja tratado Hospitais, Casas de Saúde e Estabelecimento Congenêres é necessário criar um campo na tabela SA1 com tamanho <1>, do tipo <caracter> com a seguinte Lista de opções <S=Sim; N=Nao>."
		EndIf
	EndIf
	//
	aAdd (aStru, {"ENTSAI",		"C",	01,		0})
	aAdd (aStru, {"ITEM",		"C",	01,		0})
	aAdd (aStru, {"VLRCONT",	"N",	17,		2})
	aAdd (aStru, {"VLRBASE",	"N",	17,		2})
	//
	cArq	:=	CriaTrab (aStru)
	DbUseArea (.T., __LocalDriver, cArq, "TRB")
	IndRegua ("TRB", cArq, "ENTSAI+ITEM")
	//
	aTrb	:=	{"TRB", cArq}
	//
	DbSelectArea ("SF3")
		SF3->(DbSetOrder (3))	
	FsQuery (aSf3, 1, cQuery, cFilter, SF3->(IndexKey ()))
	ProcRegua (LastRec ())
	SF3->(DbGoTop ())
	//
	Do While !SF3->(Eof ())		
		If (SubStr (SF3->F3_CFO, 1, 1)>="5")
			DbSelectArea ("SA1")
				SA1->(DbSetOrder (1))
			SA1->(DbSeek (xFilial ("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
			//
			If (AllTrim (SF3->F3_CFO)$"618/619/545/645/553/653/751/563/663") .Or.;
				(AllTrim (SF3->F3_CFO)$"6107/6108/5258/6258/5307/6307/5357/6357") .Or.;
				"ISENT"$Upper (SA1->A1_INSCR) .Or. (Empty(SA1->A1_INSCR) .And. SA1->A1_TIPO!="L")
				lContrib := .F.
				//
				If (nMVR956A1)<>0 .And. ("S"$SA1->(FieldGet (nMVR956A1)))
					lExcessao	:=	.T.
				Else
					lExcessao	:=	.F.
				EndIf
			Else          
				lContrib := .T.
			EndIf
		EndIf
		//
		//Aquisicoes interestaduais
		If (SubStr (SF3->F3_CFO, 1, 1)=="2")	
			If (TRB->(DbSeek ("E1")))
				RecLock ("TRB", .F.)
			Else
				RecLock ("TRB", .T.)
					TRB->ENTSAI	:=	"E"
					TRB->ITEM	:=	"1"
			EndIf
		//Aquisicoes internas
		ElseIf (SubStr (SF3->F3_CFO, 1, 1)=="1")
			If (TRB->(DbSeek ("E1")))
				RecLock ("TRB", .F.)
			Else
				RecLock ("TRB", .T.)
					TRB->ENTSAI	:=	"E"
					TRB->ITEM	:=	"2"
			EndIf
		//Aquisicoes do exterior
		ElseIf (SubStr (SF3->F3_CFO, 1, 1)=="3")
			If (TRB->(DbSeek ("E3")))
				RecLock ("TRB", .F.)
			Else
				RecLock ("TRB", .T.)
					TRB->ENTSAI	:=	"E"
					TRB->ITEM	:=	"3"
			EndIf
		//Saidas Internas Contribuintes
		ElseIf (SubStr (SF3->F3_CFO, 1, 1)=="5") .And. lContrib
			If (TRB->(DbSeek ("S1")))
				RecLock ("TRB", .F.)
			Else
				RecLock ("TRB", .T.)
					TRB->ENTSAI	:=	"S"
					TRB->ITEM	:=	"1"
			EndIf
		//Saidas Internas para Nao-Contribuintes, exceto Hospitais, Casas de saude, e Estabelecimentos Congeneres
		ElseIf (SubStr (SF3->F3_CFO, 1, 1)=="5") .And. !lContrib .And. !lExcessao
			If (TRB->(DbSeek ("S2")))
				RecLock ("TRB", .F.)
			Else
				RecLock ("TRB", .T.)
					TRB->ENTSAI	:=	"S"
					TRB->ITEM	:=	"2"
			EndIf
		//Saidas Internas para Hospitais, Casas de saude, e Estabelecimentos Congeneres
		ElseIf (SubStr (SF3->F3_CFO, 1, 1)=="5") .And. !lContrib .And. lExcessao
			If (TRB->(DbSeek ("S3")))
				RecLock ("TRB", .F.)
			Else
				RecLock ("TRB", .T.)
					TRB->ENTSAI	:=	"S"
					TRB->ITEM	:=	"3"
			EndIf
		//Saidas Interestaduais
		ElseIf (SubStr (SF3->F3_CFO, 1, 1)=="6")
			If (TRB->(DbSeek ("S4")))
				RecLock ("TRB", .F.)
			Else
				RecLock ("TRB", .T.)
					TRB->ENTSAI	:=	"S"
					TRB->ITEM	:=	"4"
			EndIf
		Else
			RecLock ("TRB", .F.)
		Endif
		TRB->VLRCONT	+=	SF3->F3_VALCONT
		TRB->VLRBASE	+=	SF3->F3_BASEICM
		MsUnLock ()	
		//
		SF3->(DbSkip ())
		IncProc ()
	EndDo
Return (.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R956Proc  ³ Autor ³Gustavo G. Rueda       ³ Data ³16/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime a Relatorio.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 - Variavel de controle para cancelamento do relatorio ³±±
±±³          ³ExpC1 - Titulo do Relatorio.                                ³±±
±±³          ³ExpC2 - Nome do Arquivo.                                    ³±±
±±³          ³ExpN3 - Tamanho do Relatorio (P)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 -> lRet = Retorno sempre .T.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATR956                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R956Proc (lEnd, cTitulo, wnrel, Tamanho)
	Local	aLay		:=	R956Lay ()
	Local	nLin		:=	1
	Local	nI 			:=	0	
	Local	aTrb		:=	{}
	Local	aBase		:=	{}
	Local	aTotalE		:=	{0, 0, 0}
	Local	aTotalS		:=	{0, 0, 0}
	//
	R956Base (1, @aTrb)
	//
	For nI := 1 To Len (aLay)
		//Essa verficacao eh para ter um padrao quando estiver imprimindo os valores do quadro 2
		aBase	:=	{0, 0, "", 0}
		//
		If (nI==7)
			aBase	:=	{SM0->M0_NOMECOM}
			
		ElseIf (nI==10)
			aBase	:=	{SM0->M0_INSC, SM0->M0_CGC}
			
		ElseIf (nI==13)
			aBase	:=	{Subs(SM0->M0_CIDENT,1,40), Subs(SM0->M0_CEPENT,1,8), Subs(SM0->M0_TEL,1,43)}
			
		ElseIf (nI==16)
			aBase	:=	{SM0->M0_FAX, MV_PAR03}
			
		ElseIf (nI==22)	//Aquisicoes interestaduais
			aBase[3]	:=	"6"
			If ((aTrb[1])->(DbSeek ("E1")))
				aBase	:=	{Transform ((aTrb[1])->VLRCONT, MASCVAL), Transform ((aTrb[1])->VLRBASE, MASCVAL), "6",  Transform ((aTrb[1])->VLRCONT*0.06, MASCVAL)}
				aTotalE[1]	+=		(aTrb[1])->VLRCONT
				aTotalE[2]	+=		(aTrb[1])->VLRBASE
				aTotalE[3]	+=		(aTrb[1])->VLRCONT*0.06
			EndIf
			
		ElseIf (nI==24)	//Aquisicoes em operacoes internas de mercadorias
			aBase[3]	:=	"3"
			If ((aTrb[1])->(DbSeek ("E2")))
				aBase	:=	{Transform ((aTrb[1])->VLRCONT, MASCVAL), Transform ((aTrb[1])->VLRBASE, MASCVAL), "3", Transform ((aTrb[1])->VLRCONT*0.03, MASCVAL)}
				aTotalE[1]	+=		(aTrb[1])->VLRCONT
				aTotalE[2]	+=		(aTrb[1])->VLRBASE
				aTotalE[3]	+=		(aTrb[1])->VLRCONT*0.03
			EndIf
			
		ElseIf (nI==25)	//Aquisicoes do exterior
			aBase[3]	:=	" "
			If ((aTrb[1])->(DbSeek ("E3")))
				aBase	:=	{Transform ((aTrb[1])->VLRCONT, MASCVAL), Transform ((aTrb[1])->VLRBASE, MASCVAL), "", ""}
				aTotalE[1]	+=		(aTrb[1])->VLRCONT
				aTotalE[2]	+=		(aTrb[1])->VLRBASE
//				aTotalE[3]	+=		(aTrb[1])->VLRCONT*(0/100)    ???
			EndIf
			
		ElseIf (nI==26)	//TOTAL DAS AQUISICOES
			aBase	:=	{Transform (aTotalE[1], MASCVAL), Transform (aTotalE[2], MASCVAL), Transform (aTotalE[3], MASCVAL)}
			aTotalE	:=	{0, 0, 0}
			
		ElseIf (nI==28)	//Saidas internas para contribuintes
			aBase[3]	:=	"3"
			If ((aTrb[1])->(DbSeek ("S1")))
				aBase	:=	{Transform ((aTrb[1])->VLRCONT, MASCVAL), Transform ((aTrb[1])->VLRBASE, MASCVAL), "3", Transform((aTrb[1])->VLRCONT*0.03, MASCVAL)}
				aTotalS[1]	+=		(aTrb[1])->VLRCONT
				aTotalS[2]	+=		(aTrb[1])->VLRBASE				
				aTotalS[3]	+=		(aTrb[1])->VLRCONT*0.03
			EndIf
			
		ElseIf (nI==32)	//Saidas internas para nao-contribuintes, exceto Hospitais, Casas de Saude e Estabelecimentos Congeneres
			aBase[3]	:=	"3"
			If ((aTrb[1])->(DbSeek ("S2")))
				aBase	:=	{Transform ((aTrb[1])->VLRCONT, MASCVAL), Transform ((aTrb[1])->VLRBASE, MASCVAL), "3", Transform((aTrb[1])->VLRCONT*0.03, MASCVAL)}
				aTotalS[1]	+=		(aTrb[1])->VLRCONT
				aTotalS[2]	+=		(aTrb[1])->VLRBASE
				aTotalS[3]	+=		(aTrb[1])->VLRCONT*0.03
			EndIf
			
		ElseIf (nI==35)	//Saidas internas para Hospitais, Casas de Saude e Estabelecimentos Congeneres
			aBase[3]	:=	"0"
			If ((aTrb[1])->(DbSeek ("S3")))
				aBase	:=	{Transform ((aTrb[1])->VLRCONT, MASCVAL), Transform ((aTrb[1])->VLRBASE, MASCVAL), "0", Transform(0, MASCVAL)}		//(aTrb[1])->VLRCONT*(0/100)
				aTotalS[1]	+=		(aTrb[1])->VLRCONT
				aTotalS[2]	+=		(aTrb[1])->VLRBASE
//				aTotalS[3]	+=		(aTrb[1])->VLRCONT*(0/100)
			EndIf
			
		ElseIf (nI==36)	//Saidas interestaduais
			aBase[3]	:=	"0"
			If ((aTrb[1])->(DbSeek ("S4")))
				aBase	:=	{Transform ((aTrb[1])->VLRCONT, MASCVAL), Transform ((aTrb[1])->VLRBASE, MASCVAL), "0", Transform(0, MASCVAL)}		//(aTrb[1])->VLRCONT*(0/100)
				aTotalS[1]	+=		(aTrb[1])->VLRCONT
				aTotalS[2]	+=		(aTrb[1])->VLRBASE
//				aTotalS[3]	+=		(aTrb[1])->VLRCONT*(0/100)
			EndIf
			
		ElseIf (nI==37)	//TOTAL DAS SAIDAS
			aBase	:=	{Transform (aTotalS[1], MASCVAL), Transform (aTotalS[2], MASCVAL), Transform (aTotalS[3], MASCVAL)}
			aTotalS	:=	{0, 0, 0}
			
		ElseIf (nI==47) .Or. (nI==56)	//Datas
			aBase	:=	{StrZero (Day (dDataBase), 2)+"/"+StrZero (Month (dDataBase), 2)+"/"+StrZero (Year (dDataBase), 4)}
		EndIf
		//
		FmtLin (aBase, aLay[nI],,, @nLin)
	Next (nI)
	//
	R956Base (2, aTrb)
Return (.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R956Lay   ³ Autor ³Gustavo G. Rueda       ³ Data ³16/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Layout de impressao.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   |ExpA1 - Array contendo o layout a ser utilizado.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       |MATR956                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R956Lay ()
	Local	aRet	:=	{}
	//	                  1         2         3         4         5         6         7         8
	//           12345678901234567890123456789012345678901234567890123456789012345678901234567890
	aAdd (aRet, STR0011)	//"              DEMONSTRATIVO DAS ENTRADAS E SAÍDAS DE MERCADORIAS"
	aAdd (aRet, STR0012+StrZero (MV_PAR01, 2)+"/"+StrZero (MV_PAR02, 4))	//"                           MES REFERENCIA: "
	aAdd (aRet, STR0013)	//"+------------------------------------------------------------------------------+"
	aAdd (aRet, STR0014)	//"|1. IDENTIFICACAO DO ESTABELECIMENTO                                           |"
	aAdd (aRet, STR0015)	//"+------------------------------------------------------------------------------+"
	aAdd (aRet, STR0016)	//"|RAZAO SOCIAL                                                                  |"
	aAdd (aRet, STR0017)	//"|##############################################################################|"
	aAdd (aRet, STR0018)	//"+--------------------------------------+---------------------------------------+"
	aAdd (aRet, STR0019)	//"|INSCRICAO ESTADUAL                    |CNPJ                                   |"
	aAdd (aRet, STR0020)	//"|######################################|#######################################|"
	aAdd (aRet, STR0021)	//"+------------------------------+--------+--------------------------------------+"
	aAdd (aRet, STR0022)	//"|MUNICIPIO                     |CEP     |FONES                                 |"
	aAdd (aRet, STR0023)	//"|##############################|########|######################################|"
	aAdd (aRet, STR0024)	//"+--------------------+---------+--------+--------------------------------------+"
	aAdd (aRet, STR0025)	//"|FAX                 |E-MAIL                                                   |"
	aAdd (aRet, STR0026)	//"|####################|#########################################################|"
	aAdd (aRet, STR0027)	//"+--------------------+---------------------------------------------------------+"
	aAdd (aRet, STR0028)	//"|2. DADOS DAS OPERACOES                                                        |"
	aAdd (aRet, STR0029)	//"+------------------------------+--------------+--------------------------------+"
	aAdd (aRet, STR0030)	//"|OPERACAO                      |  VLR CONTABIL|  BASE CALCULO| %|          ICMS|"
	aAdd (aRet, STR0031)	//"+------------------------------+--------------+-----------------+--------------+"
	aAdd (aRet, STR0032)	//"|Aquisicao interestaduais      |##############|##############|#%|##############|"
	aAdd (aRet, STR0033)	//"|Aquisicao em operacoes inter- |              |              |  |              |"
	aAdd (aRet, STR0034)	//"| nas de mercadorias           |##############|##############|#%|##############|"
	aAdd (aRet, STR0035)	//"|Aquisicao do exterior         |##############|##############|##|##############|"
	aAdd (aRet, STR0036)	//"|TOTAL DAS AQUISICOES          |##############|##############|  |##############|"
	aAdd (aRet, STR0037)	//"|                              |              |              |  |              |"	
	aAdd (aRet, STR0038)	//"|Saidas internas contribuintes |##############|##############|#%|##############|"
	aAdd (aRet, STR0039)	//"|Saidas internas para nao con- |              |              |  |              |"
	aAdd (aRet, STR0040)	//"| tribuintes, exceto Hospitais,|              |              |  |              |"
	aAdd (aRet, STR0041)	//"| Casas de saude e Estabeleci- |              |              |  |              |"
	aAdd (aRet, STR0042)	//"| mentos congeneres            |##############|##############|#%|##############|"
	aAdd (aRet, STR0043)	//"|Saidas internas para Hospi-   |              |              |  |              |"
	aAdd (aRet, STR0044)	//"| tais, Casas de saude e Esta- |              |              |  |              |"
	aAdd (aRet, STR0045)	//"| belecimentos congeneres      |##############|##############|#%|##############|"
	aAdd (aRet, STR0046)	//"|Saidas interestaduais         |##############|##############|#%|##############|"
	aAdd (aRet, STR0047)	//"|TOTAL DAS SAIDAS              |##############|##############|  |##############|"
	aAdd (aRet, STR0048)	//"+------------------------------+--------------+-----------------+--------------+"
	aAdd (aRet, STR0049)	//"|DECLARO, SOB AS PENAS DA LEI, QUE AS INFORMACOES CONSTANTES DESTE DEMONSTRA-  |"
	aAdd (aRet, STR0050)	//"| TIVO SAO A EXPRESSAO DA VERDADE.                                             |"
	aAdd (aRet, STR0051)	//"|                                                                              |"
	aAdd (aRet, STR0051)	//"|                                                                              |"
	aAdd (aRet, STR0052)	//"|____________________________________________                                  |"
	aAdd (aRet, STR0053)	//"|NOME POR EXTENSO                                                              |"
	aAdd (aRet, STR0051)	//"|                                                                              |"
	aAdd (aRet, STR0051)	//"|                                                                              |"
	aAdd (aRet, STR0054)	//"|########## _________________________________                                  |"
	aAdd (aRet, STR0055)	//"|  DATA     ASSINTAURA DO TITULAR/RESPONSAVEL                                  |"
	aAdd (aRet, STR0056)	//"+------------------------------------------------------------------------------+"
	aAdd (aRet, STR0057)	//"                                                                                "
	aAdd (aRet, STR0056)	//"+------------------------------------------------------------------------------+"
	aAdd (aRet, STR0058)	//"|DATA DA APRESENTACAO                                                          |"
	aAdd (aRet, STR0056)	//"+------------------------------------------------------------------------------+"
	aAdd (aRet, STR0051)	//"|                                                                              |"
	aAdd (aRet, STR0051)	//"|                                                                              |"
	aAdd (aRet, STR0067)	//"|########## ________________________________________                           |"
	aAdd (aRet, STR0059)	//"|  DATA     ASSINTAURA DO SERVIDOR - ORGAO RECEBEDOR                           |"
	aAdd (aRet, STR0056)	//"+------------------------------------------------------------------------------+"
Return (aRet)
