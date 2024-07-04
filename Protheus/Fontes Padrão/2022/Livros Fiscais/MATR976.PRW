#INCLUDE "MATR976.CH"                                                             
#INCLUDE "PROTHEUS.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATR976   ºAutor  ³Luciana Pires       º Data ³  20/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Emiss„o do Livro de Registro e Apuracao de ISS - Modelo I   º±±
±±º          ³do Municipio de Florianópolis - Decreto Mun. 2.154 23/12/03 º±±
±±º          ³Portaria SMR n.02 de 13/01/06.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATR976
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local Titulo	:= OemToAnsi(STR0001)  	//"Livro de reg. de apuração do ISS - MODELO I"
Local cDesc1  	:= OemToAnsi(STR0002) 	//"Este relatório ira imprimir os Registro de Apuraçãao referentes a Imposto Sobre "
Local cDesc2  	:= OemToAnsi(STR0003) 	//"Servicos de Qualquer Natureza, conforme o periodo informado."
Local cDesc3  	:= OemToAnsi("")
Local cString  	:= "SF3"
Local lDic        := .F. 				// Habilita/Desabilita Dicionario
Local lComp       := .T. 				// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro     := .T. 				// Habilita/Desabilita o Filtro
Local wnrel    	:= "MATR976" 			// Nome do Arquivo utilizado no Spool      
Local nomeprog	:= "MATR976"  			// nome do programa

Private Tamanho := "G" 					// P/M/G
Private Limite  := 220 					// 80/132/220
Private aOrdem  := {}  					// Ordem do Relatorio
Private cPerg   := "MTR976"  			// Pergunta do Relatorio
Private nPagina	:= 0
Private aReturn := { STR0004, 1,STR0005, 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"

Private lEnd    := .F.					// Controle de cancelamento do relatorio
Private m_pag   := 1  					// Contador de Paginas
Private nLastKey:= 0  					// Controla o cancelamento da SetPrint e SetDefault

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                   ³
//³ mv_par01             // Data Inicial                                   ³
//³ mv_par02             // Data Final                                     ³
//³ mv_par03             // Livro Selecionado                              ³
//³ mv_par04             // Pagina Inicial                                 ³
//³ mv_par05             // Imprime (1-Livro / 2-Termos / 3-Livro e Termos)³
//³ mv_par06             // Numero CMC                                     ³
//³ mv_par07             // Numero Livro                                   ³
//³ mv_par08             // Numero Páginas                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel	:= SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)

nPagina	:=	mv_par04

If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif
SetDefault(aReturn,cString)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao de Termo / Livro                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case mv_par05==1 ; 	lImpLivro:=.T. ; lImpTermos:=.F.
	Case mv_par05==2 ; 	lImpLivro:=.F. ; lImpTermos:=.T.
	Case mv_par05==3 ; 	lImpLivro:=.T. ; lImpTermos:=.T.
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa relatorio                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lImpLivro 
	RptStatus({|lEnd| R976Livro(@lEnd,wnRel,cString,Tamanho,cPerg)},Titulo)
Endif

If lImpTermos
	R976ImpTerm(cPerg, nPagina)
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Ambiente                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cString)
dbSetOrder(1)
If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	Ourspool(wnrel)
Endif

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Function  ³R976Livro ³ Autor ³ Luciana Pires         ³ Data ³ 21/09/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressao do Livro de Registro de ISS - Modelo I           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR976()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function R976Livro(lEnd,wnRel,cString,Tamanho,cPerg)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de Variaveis                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aLay      := Array(20)
Local aLaySt    := Array(20)
Local aLayAj    := Array(26)

Local cAliasSF3 := "SF3"
Local cPeriodo  := StrZero(day(mv_par01),2) + "/" + StrZero(Month(mv_par01),2) + "/" + StrZero(Year(mv_par01),4) +" à "+StrZero(day(mv_par02),2) + "/" + StrZero(Month(mv_par02),2) + "/" + StrZero(Year(mv_par02),4)
Local cFiltroUsr:= aReturn[7]            

Local lQuery    := .F.

Local nX        := 0
Local nLin		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas no cabecalho.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cNome		:= SM0->M0_NOMECOM
Local cCGC		:= Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")
Local cCMC		:= mv_par06
Local nLivro	:= mv_par07

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas nas informacoes.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cSer		:= ""
Local cSerView:= ""
Local cNFIni	:= ""
Local cNFFim	:= ""
Local cEsp		:= ""
Local cdtCanc	:= ""
Local cCFPS 	:= ""
Local cConta	:= ""
Local cSeek		:= ""
Local cSitTrib	:= ""
Local cSitT2	:= ""

Local nValCont	:= 0
Local nBsCalc 	:= 0
Local nAliq   	:= 0
Local nValISS 	:= 0
Local nCont		:= 0
Local nTotComp		:= 0
Local nTotRete		:= 0
Local nTotComRet	:= 0
Local nValIssAp		:= 0
Local nTotDev		:= 0

Local dData		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para totalizacao da pagina                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nValContTP	:= 0
Local nBsCalcTP 	:= 0
Local nValISSTP  	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Controle                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lHouveMov    	:= .F.
Local lIssSt		:= GetNewPar("MV_APISSST",.F.)
Local lQuaAjuste	:= GetNewPar("MV_ISSAJU","")
Local aQdrAjuste 	:= {} 
Local aTotAjuste    := {}
LOcal aNotas		:= {}

Local cChaveSFT		:= ""
Local aAreaSFT		:= {}

#IFDEF TOP
	Local aStruSF3  := {}
	Local aCamposSF3:= {}

	Local cQuery    := ""   
	Local cCmpQry	:= ""
#ELSE 
	Local cChave    := ""
	Local cFiltro   := ""       
#ENDIF

dbSelectArea("SF3")
dbSetOrder(1)

#IFDEF TOP

	If TcSrvType()<>"AS/400"

	    aAdd(aCamposSF3,"F3_FILIAL")
   	    aAdd(aCamposSF3,"F3_ENTRADA")
   	    aAdd(aCamposSF3,"F3_DTCANC")           
   	    aAdd(aCamposSF3,"F3_ALIQICM")   
   	    aAdd(aCamposSF3,"F3_NFISCAL")
   	    aAdd(aCamposSF3,"F3_SERIE")
   	    If (SerieNfId("SF3",3,"F3_SERIE")<>"F3_SERIE")
   	    	aAdd(aCamposSF3,SerieNfId("SF3",3,"F3_SERIE"))
   	    Endif
   	    aAdd(aCamposSF3,"F3_CFO")
   	    aAdd(aCamposSF3,"F3_CLIEFOR")
   	    aAdd(aCamposSF3,"F3_LOJA")
   	    aAdd(aCamposSF3,"F3_ESPECIE")
   	    aAdd(aCamposSF3,"F3_BASEICM")
   	    aAdd(aCamposSF3,"F3_CONTA")
   	    aAdd(aCamposSF3,"F3_CFPS")
   	    aAdd(aCamposSF3,"F3_VALCONT")
   	    aAdd(aCamposSF3,"F3_TIPO")
   	    aAdd(aCamposSF3,"F3_VALICM")
		aAdd(aCamposSF3,"F3_NRLIVRO")
		aAdd(aCamposSF3,"F3_NFELETR")

    	aStruSF3  := SF3->(MTR976Str(aCamposSF3,@cCmpQry))
    	SF3->(dbCloseArea())

		lQuery    := .T.
		cAliasSF3 := "F3_MTR976"

		cQuery := "SELECT  "
		cQuery += cCmpQry
		cQuery += "FROM "+RetSqlName("SF3")+" "
		cQuery += "WHERE F3_FILIAL='"+xFilial("SF3")+"' AND "
		cQuery += "F3_TIPO='S' AND "
		cQuery += "F3_CFO >='5' AND "
		cQuery += "F3_ENTRADA>='"+Dtos(mv_par01)+"' AND "
		cQuery += "F3_ENTRADA<='"+Dtos(mv_par02)+"' AND "
		If mv_par03<>"*"
			cQuery	+=	"F3_NRLIVRO='"+mv_par03+"' AND "
		EndIf
		cQuery += "D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY F3_ENTRADA,F3_NFISCAL,F3_SERIE,F3_CFPS,F3_ALIQICM,F3_CONTA,F3_ESPECIE "

	    cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
	
		For nX := 1 To len(aStruSF3)
			If aStruSF3[nX][2] <> "C" 
				TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
			EndIf
		Next nX
	
		dbSelectArea(cAliasSF3)	
	Else

#ENDIF

	cArqInd	:=	CriaTrab(NIL,.F.)
	cChave	:=	"DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CFPS+STR(F3_ALIQICM)+F3_CONTA+F3_ESPECIE"
	cFiltro :=  " F3_FILIAL=='"+xFilial()+"' .AND. F3_TIPO=='S' "
	cFiltro	+=	" .AND. F3_CFO >='5'"
	cFiltro	+=	" .AND. dtos(F3_ENTRADA) >='"+dtos(mv_par01)+"' .and. dtos(F3_ENTRADA)<='"+dtos(mv_par02)+"'"

	If mv_par03<>"*"
		cFiltro	+=	".AND. F3_NRLIVRO=='"+mv_par03+"'"
	EndIf

	IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,STR0026) //"Selecionando Registros..."

	#IFNDEF TOP
		DbSetIndex(cArqInd+OrdBagExt())
	#ENDIF

	(cAliasSF3)->(dbGotop())
	SetRegua(LastRec())

#IFDEF TOP
	EndIf
#ENDIF

// Layout
R976LayOut(@aLay)

dbSelectArea(cAliasSF3)
SetRegua(LastRec())
(cAliasSF3)->(DbGoTop())

While (cAliasSF3)->(!Eof())  

	Mr976Cabec(@nLin,aLay,@nPagina,cNome,nLivro,cCMC,cPeriodo,cCGC)
	nCont 		:= 0
	nValCont 	:= 0
	nBsCalc 	:= 0
	nValISS 	:= 0 
	nValContTP	:= 0
	nBsCalcTP	:= 0
	nValISSTP	:= 0
    	
	While (cAliasSF3)->(!Eof()) .And. nLin <= 57
	
		IncRegua()
		If Interrupcao(@lEnd)
		    Exit
	 	Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Considera filtro do usuario                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cFiltroUsr).and.!(&cFiltroUsr)
			(cAliasSF3)->(dbSkip())
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aglutina lancamentos de mesma Data + Especie + Serie + CFPS + |
		//|CST + Aliq + Canceladas sendo da mesma sequencia de nº de notas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNFIni	:= Iif(Empty((cAliasSF3)->F3_NFELETR),(cAliasSF3)->F3_NFISCAL,Alltrim((cAliasSF3)->F3_NFELETR))
		cNFFim	:= Iif(Empty((cAliasSF3)->F3_NFELETR),(cAliasSF3)->F3_NFISCAL,Alltrim((cAliasSF3)->F3_NFELETR))
		dData	:= (cAliasSF3)->F3_ENTRADA
		cEsp	:= (cAliasSF3)->F3_ESPECIE 
		cdtCanc	:= Iif(!Empty((cAliasSF3)->F3_DTCANC),"S","N")
        nAliq 	:= (cAliasSF3)->F3_ALIQICM         
	    cSer 	:= (cAliasSF3)->F3_SERIE        
	    cSerView:= ALLTRIM((cAliasSF3)->&(SerieNfId("SF3",3,"F3_SERIE"))) 
	    cCFPS 	:= (cAliasSF3)->F3_CFPS    
	    cConta	:= (cAliasSF3)->F3_CONTA        
                                             
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Buscando Situacao Tributaria                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aAreaSFT := SFT->(GetArea())
		SFT->(dbSetOrder(1)) // FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA, FT_ITEM, FT_PRODUTO
		If (cAliasSF3)->F3_CFO >= "5"
			SD2->(dbSetOrder(3))
			If SD2->(dbSeek(xFilial("SD2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				cChaveSFT := xFilial("SFT") + 'S' + (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_NFISCAL + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA 
				cChaveSFT += Padr(SD2->D2_ITEM,TamSX3("FT_ITEM")[1]) + AllTrim(SD2->D2_COD)
				If SFT->(dbSeek(cChaveSFT))
					cSitTrib 	:= SFT->FT_CSTISS
				Else
					cSitTrib	:= SD2->D2_CLASFIS
				Endif
			Endif
        Else
			SD1->(dbSetOrder(1))
			If SD1->(dbSeek(xFilial("SD1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				cChaveSFT := xFilial("SFT") + 'E' + (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_NFISCAL + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA 
				cChaveSFT += Padr(SD1->D1_ITEM,TamSX3("FT_ITEM")[1]) + AllTrim(SD1->D1_COD)
				If SFT->(dbSeek(cChaveSFT))
					cSitTrib 	:= SFT->FT_CSTISS
				Else
					cSitTrib	:= SD1->D1_CLASFIS
				Endif
			Endif
		Endif
		SFT->(RestArea(aAreaSFT))

		cSeek := dtos(dData)+cEsp+cSer+cConta+cCFPS+Str(nAliq,5,2)+cDtCanc
		While !Eof() .And. cSeek == dtos((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_ESPECIE+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CONTA+(cAliasSF3)->F3_CFPS+Str((cAliasSF3)->F3_ALIQICM,5,2)+Iif(!Empty((cAliasSF3)->F3_DTCANC),"S","N")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Buscando Situacao Tributaria para comparacao,   ³
			//³pois se for diferente também quebro a chave.    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			aAreaSFT := SFT->(GetArea())
			SFT->(dbSetOrder(1)) // FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA, FT_ITEM, FT_PRODUTO
			If (cAliasSF3)->F3_CFO >= "5"
				SD2->(dbSetOrder(3))
				If SD2->(dbSeek(xFilial("SD2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					cChaveSFT := xFilial("SFT") + 'S' + (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_NFISCAL + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA 
					cChaveSFT += Padr(SD2->D2_ITEM,TamSX3("FT_ITEM")[1]) + AllTrim(SD2->D2_COD)
					If SFT->(dbSeek(cChaveSFT))
						cSitT2 	:= SFT->FT_CSTISS
					Else
						cSitT2	:= SD2->D2_CLASFIS
					Endif
				Endif
	        Else
				SD1->(dbSetOrder(1))
				If SD1->(dbSeek(xFilial("SD1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					cChaveSFT := xFilial("SFT") + 'E' + (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_NFISCAL + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA 
					cChaveSFT += Padr(SD1->D1_ITEM,TamSX3("FT_ITEM")[1]) + AllTrim(SD1->D1_COD)
					If SFT->(dbSeek(cChaveSFT))
						cSitT2 	:= SFT->FT_CSTISS
					Else
						cSitT2	:= SD1->D1_CLASFIS
					Endif
				Endif
			Endif
			SFT->(RestArea(aAreaSFT))

			If cSitTrib <> cSitT2
				Exit		
			Endif	
			
			nCont ++

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a próxima nota está na sequencia    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If nCont > 1 .And. (Val(cNFFim)+1) <> Iif(Empty((cAliasSF3)->F3_NFELETR),Val((cAliasSF3)->F3_NFISCAL),Val((cAliasSF3)->F3_NFELETR))
				Exit		
			Else
				cNFFim 	:= Iif(Empty((cAliasSF3)->F3_NFELETR),(cAliasSF3)->F3_NFISCAL,Alltrim((cAliasSF3)->F3_NFELETR))
				nValCont 	+= (cAliasSF3)->F3_VALCONT      
				nBsCalc 	+= (cAliasSF3)->F3_BASEICM
				nValISS 	+= (cAliasSF3)->F3_VALICM		
			Endif
							
			(cAliasSF3)->(DbSkip())
		Enddo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprimo a linha do relatorio pois mudou a chave ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		lHouveMov := .T.             
		If cdtCanc == "S" .And. MV_PAR09 == 1
			nValCont	:= 0
			nBsCalc 	:= 0
			nAliq		:= 0
			nValISS 	:= 0
		Endif

		FmtLin({	dData,;
					cEsp,;
					cSerView,;
					Iif(cNFIni==cNFFim,cNFIni,cNFIni + " a "+ cNFFim),;
					Iif(cdtCanc == "S","sim","não"),;
					TransForm(nValCont,"@e 999,999,999,999,999,999.99"),;
					cConta,;
					cCFPS,;
					cSitTrib,;
					TransForm(nBsCalc,"@e 999,999,999,999,999,999.99"),;
					TransForm(nAliq,"@e 9,999,999.99"),;
					TransForm(nValISS,"@e 999,999,999,999,999,999.99")},aLay[16],,,@nLin)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Acumula os valores tot. página³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
		nValContTP	+= nValCont
		nBsCalcTP	+= nBsCalc
		nValISSTP	+= nValISS			

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Zera as variaveis de impressao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		nCont 		:= 0
		nValCont 	:= 0
		nBsCalc 	:= 0
		nValISS 	:= 0
	Enddo                       
	
	If nLin > 57
		FmtLin({},aLay[17],,,@nLin)	
		FmtLin({TransForm(nValContTP,"@e 999,999,999,999,999,999.99"),TransForm(nBsCalcTP,"@e 999,999,999,999,999,999.99"),"",TransForm(nValISSTP,"@e 999,999,999,999,999,999.99")},aLay[18],,,@nLin)	
		FmtLin({},aLay[19],,,@nLin)	
		
		lHouveMov 	:= .F.             				
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Completa o preenchimento da pagina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nlin <= 57 .And. lHouveMov
		While nLin <= 57
			FmtLin({,,,,,,,,,,,},aLay[16],,,@nLin)
		EndDo
		FmtLin({},aLay[17],,,@nLin)
		FmtLin({TransForm(nValContTP,"@e 999,999,999,999,999,999.99"),TransForm(nBsCalcTP,"@e 999,999,999,999,999,999.99"),"",TransForm(nValISSTP,"@e 999,999,999,999,999,999.99")},aLay[18],,,@nLin)	
		FmtLin({},aLay[19],,,@nLin)	                                         		
	Endif
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime informacao que nao houve movimento                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lHouveMov
	nlin    := 0
	Mr976Cabec(@nLin,aLay,@nPagina,cNome,nLivro,cCMC,cPeriodo,cCGC)	
	FmtLin({},aLay[20],,,@nLin)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Completa o preenchimento da pagina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While nLin <= 57
		FmtLin({,,,,,,,,,,,},aLay[16],,,@nLin)
	EndDo
	FmtLin({},aLay[17],,,@nLin)
	FmtLin({TransForm(nValContTP,"@e 999,999,999,999,999,999.99"),TransForm(nBsCalcTP,"@e 999,999,999,999,999,999.99"),"",TransForm(nValISSTP,"@e 999,999,999,999,999,999.99")},aLay[18],,,@nLin)	
	FmtLin({},aLay[19],,,@nLin)	
EndIf

If !lQuery
	RetIndex("SF3")	
	dbClearFilter()	    		
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasSF3)
	dbCloseArea()
Endif

//Quadro de ajuste
If !Empty(lQuaAjuste)

	aQdrAjuste := a954Ret(.T.,"",MV_PAR01,MV_PAR02)
	
	For nX:=1 to Len(aQdrAjuste)	
   		AADD(aNotas,{aQdrAjuste[NX,1],aQdrAjuste[NX,2],aQdrAjuste[NX,3],aQdrAjuste[NX,4],aQdrAjuste[NX,5],"",;
		TransForm(aQdrAjuste[NX,6],"@E 999,999,999,999.99")} ) 
		nValIssAp += aQdrAjuste[NX,6]
	next NX 

	aTotAjuste := FisApur("IS",Year(MV_PAR01),Month(MV_PAR01),	3, 1, mv_par03, .F.,{}, 1, .F., "",0, .F.)
   
  	For nX:=1 to Len(aTotAjuste)
  		IF aTotAjuste[NX,1] == "111" .AND. aTotAjuste[NX,4]<> "111.00"
  			AADD(aNotas,{SUBSTR(aTotAjuste[NX,5],1,5),SUBSTR(aTotAjuste[NX,5],7,3),SUBSTR(aTotAjuste[NX,5],11,9),;
				SUBSTR(aTotAjuste[NX,5],21,5),SUBSTR(aTotAjuste[NX,5],27,3),TransForm(aTotAjuste[NX,3],"@E 999,999,999,999.99"),""})
			nTotComp += aTotAjuste[NX,3]
		ENDIF
	Next NX    
	nTotComRet := nTotComp + nValIssAp        
	
	// Layout
	R976Ajuste(@aLayAj)  
 	nLin := 0	
	Mr976Cabec(@nLin,aLayAj,@nPagina,cNome,nLivro,cCMC,cPeriodo,cCGC, .F.)
	
	FmtLin({},aLayAj[11],,,@nLin)	
	FmtLin({TransForm(nValISSTP,"@E 999,999,999,999.99")},aLayAj[12],,,@nLin)	
	FmtLin({},aLayAj[13],,,@nLin) 
	FmtLin({},aLayAj[14],,,@nLin)
	FmtLin({},aLayAj[15],,,@nLin)		
	FmtLin({},aLayAj[16],,,@nLin)
	FmtLin({},aLayAj[17],,,@nLin)
	FmtLin({},aLayAj[18],,,@nLin)
 	FmtLin({},aLayAj[19],,,@nLin)
		                                                  		
    If  Len(aNotas) > 0
   
		For nX:=1 to Len(aNotas)  
	   		If nLin > 57
				nLin = 0
				Mr976Cabec(@nLin,aLayAj,@nPagina,cNome,nLivro,cCMC,cPeriodo,cCGC, .F.)
				FmtLin({},aLayAj[11],,,@nLin)	
				FmtLin({TransForm(nValISSTP,"@E 999,999,999,999.99")},aLayAj[12],,,@nLin)	
				FmtLin({},aLayAj[13],,,@nLin) 
				FmtLin({},aLayAj[14],,,@nLin)
				FmtLin({},aLayAj[15],,,@nLin)		
				FmtLin({},aLayAj[16],,,@nLin)
				FmtLin({},aLayAj[17],,,@nLin)
				FmtLin({},aLayAj[18],,,@nLin)
			 	FmtLin({},aLayAj[19],,,@nLin)
			Endif
			FmtLin({aNotas[NX,1],aNotas[NX,2],aNotas[NX,3],aNotas[NX,4],aNotas[NX,5],aNotas[NX,6],;
				aNotas[NX,7]},aLayAj[20],,,@nLin)
				
		Next NX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Completa o preenchimento da pagina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While nLin <= 57
			FmtLin({,,,,,,},aLayAj[20],,,@nLin)
		EndDo  
	    
		FmtLin({},aLayAj[21],,,@nLin) 
		
		FmtLin({TransForm(nTotComp,"@E 999,999,999,999.99"),TransForm(nValIssAp,"@E 999,999,999,999.99"),TransForm(nTotComRet,"@E 999,999,999,999.99")},aLayAj[22],,,@nLin)  
	
		FmtLin({},aLayAj[23],,,@nLin)
		
		nTotDev := nValISSTP-nTotComRet
		
		If nTotDev >= 0
			FmtLin({TransForm((nTotDev),"@E 999,999,999,999.99")},aLayAj[24],,,@nLin)  
	   	Else
	  		nTotDev := nTotDev*(-1)
	  		FmtLin({"Sld.Credor: "+alltrim(TransForm((nTotDev),"@E 999,999,999,999.99"))},aLayAj[24],,,@nLin) 
	  	Endif
		FmtLin({},aLayAj[25],,,@nLin)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime informacao que nao houve movimento                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   
	   	FmtLin({},aLayAj[26],,,@nLin)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Completa o preenchimento da pagina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While nLin <= 57
			FmtLin({,,,,,,},aLayAj[20],,,@nLin)
		EndDo
		FmtLin({},aLayAj[23],,,@nLin)
		FmtLin({TransForm(nValISSTP,"@E 999,999,999,999.99")},aLayAj[24],,,@nLin)
		FmtLin({},aLayAj[25],,,@nLin)	
	EndIf
Endif
//Apuração do ISS - Substituto tributário
If lIssSt
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas nas informacoes.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSer	 := ""
	cSerView:= ""
	cNFIni	 := ""
	cNFFim	 := ""
	cEsp	 := ""
	cCFPS 	 := ""
	cConta	 := ""
	cSeek	 := ""
	cSitTrib := ""
	cSitT2	 := ""
	
	nValCont	:= 0
	nBsCalc 	:= 0
	nAliq   	:= 0
	nValISS 	:= 0
	nCont		:= 0
	
	dData		:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para totalizacao da pagina                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValContTP	:= 0
	nBsCalcTP 	:= 0
	nValISSTP  	:= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis para Controle                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lHouveMov    	:= .F.
	
	#IFDEF TOP
	aStruSF3  := {}
	aCamposSF3:= {}
	
	cQuery    := ""   
	cCmpQry	:= ""
	#ELSE 
	cChave    := ""
	cFiltro   := ""       
	#ENDIF
	
	dbSelectArea("SF3")
	dbSetOrder(1)
	
	#IFDEF TOP
	
		If TcSrvType()<>"AS/400"
	
		    aAdd(aCamposSF3,"F3_FILIAL")
	   	    aAdd(aCamposSF3,"F3_ENTRADA")      
	   	    aAdd(aCamposSF3,"F3_ALIQICM")   
	   	    aAdd(aCamposSF3,"F3_NFISCAL")
	   	    aAdd(aCamposSF3,"F3_SERIE")
	   	    If (SerieNfId("SF3",3,"F3_SERIE")<>"F3_SERIE")
   	    		aAdd(aCamposSF3,SerieNfId("SF3",3,"F3_SERIE"))
   	    	Endif
	   	    aAdd(aCamposSF3,"F3_CFO")
	   	    aAdd(aCamposSF3,"F3_CLIEFOR")
	   	    aAdd(aCamposSF3,"F3_LOJA")
	   	    aAdd(aCamposSF3,"F3_ESPECIE")
	   	    aAdd(aCamposSF3,"F3_BASEICM")
	   	    aAdd(aCamposSF3,"F3_CONTA")
	   	    aAdd(aCamposSF3,"F3_CFPS")
	   	    aAdd(aCamposSF3,"F3_VALCONT")
	   	    aAdd(aCamposSF3,"F3_TIPO")
	   	    aAdd(aCamposSF3,"F3_VALICM")
			aAdd(aCamposSF3,"F3_NRLIVRO")
			aAdd(aCamposSF3,"F3_NFELETR")
	
	    	aStruSF3  := SF3->(MTR976Str(aCamposSF3,@cCmpQry))
	    	SF3->(dbCloseArea())
	
			lQuery    := .T.
			cAliasSF3 := "F3_MTR976"
	
			cQuery := "SELECT  "
			cQuery += cCmpQry
			cQuery += "FROM "+RetSqlName("SF3")+" "
			cQuery += "WHERE F3_FILIAL='"+xFilial("SF3")+"' AND "
			cQuery += "F3_TIPO='S' AND "
			cQuery += "F3_CFO < '5' AND "
			cQuery += "F3_ENTRADA>='"+Dtos(mv_par01)+"' AND "
			cQuery += "F3_ENTRADA<='"+Dtos(mv_par02)+"' AND "
			If mv_par03<>"*"
				cQuery	+=	"F3_NRLIVRO='"+mv_par03+"' AND "
			EndIf
			cQuery += "D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY F3_ENTRADA,F3_NFISCAL,F3_SERIE,F3_CFPS,F3_ALIQICM,F3_CONTA,F3_ESPECIE "
	
		    cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
		
			For nX := 1 To len(aStruSF3)
				If aStruSF3[nX][2] <> "C" 
					TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
				EndIf
			Next nX
		
			dbSelectArea(cAliasSF3)	
		Else
	
	#ENDIF
	
		cArqInd	:=	CriaTrab(NIL,.F.)
		cChave	:=	"DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CFPS+STR(F3_ALIQICM)+F3_CONTA+F3_ESPECIE"
		cFiltro :=  " F3_FILIAL=='"+xFilial()+"' .AND. F3_TIPO=='S' "
		cFiltro	+=	" .AND. F3_CFO <'5'"
		cFiltro	+=	" .AND. dtos(F3_ENTRADA) >='"+dtos(mv_par01)+"' .and. dtos(F3_ENTRADA)<='"+dtos(mv_par02)+"'"
	
		If mv_par03<>"*"
			cFiltro	+=	".AND. F3_NRLIVRO=='"+mv_par03+"'"
		EndIf
	
		IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,STR0038) //"Selecionando Registros..."
	
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF
	
		(cAliasSF3)->(dbGotop())
		SetRegua(LastRec())
	
	#IFDEF TOP
		EndIf
	#ENDIF
	
	// Layout
	R976LaySt(@aLaySt)
	
	dbSelectArea(cAliasSF3)
	SetRegua(LastRec())
	(cAliasSF3)->(DbGoTop())
	
	While (cAliasSF3)->(!Eof())  
	
		Mr976Cabec(@nLin,aLaySt,@nPagina,cNome,nLivro,cCMC,cPeriodo,cCGC)
		nCont 		:= 0
		nValCont 	:= 0
		nBsCalc 	:= 0
		nValISS 	:= 0 
		nValContTP	:= 0
		nBsCalcTP	:= 0
		nValISSTP	:= 0
	    	
		While (cAliasSF3)->(!Eof()) .And. nLin <= 57
		
			IncRegua()
			If Interrupcao(@lEnd)
			    Exit
		 	Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Considera filtro do usuario                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cFiltroUsr).and.!(&cFiltroUsr)
				(cAliasSF3)->(dbSkip())
				Loop
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aglutina lancamentos de mesma Data + Especie + Serie + CFPS + |
			//|CST + Aliq sendo da mesma sequencia de nº de notas             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNFIni	  := Iif(Empty((cAliasSF3)->F3_NFELETR),(cAliasSF3)->F3_NFISCAL,Alltrim((cAliasSF3)->F3_NFELETR))
			cNFFim	  := Iif(Empty((cAliasSF3)->F3_NFELETR),(cAliasSF3)->F3_NFISCAL,Alltrim((cAliasSF3)->F3_NFELETR))
			dData	  := (cAliasSF3)->F3_ENTRADA
			cEsp	  := (cAliasSF3)->F3_ESPECIE 
		    nAliq 	  := (cAliasSF3)->F3_ALIQICM         
		    cSer 	  := (cAliasSF3)->F3_SERIE    
		    cSerView := ALLTRIM((cAliasSF3)->&(SerieNfId("SF3",3,"F3_SERIE")))     
		    cCFPS    := (cAliasSF3)->F3_CFPS    
		    cConta	  := (cAliasSF3)->F3_CONTA        
	                                             
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Buscando Situacao Tributaria                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
			aAreaSFT := SFT->(GetArea())
			SFT->(dbSetOrder(1)) // FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA, FT_ITEM, FT_PRODUTO
			If (cAliasSF3)->F3_CFO < "5"
				SD1->(dbSetOrder(1))
				If SD1->(dbSeek(xFilial("SD1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					cChaveSFT := xFilial("SFT") + 'E' + (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_NFISCAL + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA 
					cChaveSFT += Padr(SD1->D1_ITEM,TamSX3("FT_ITEM")[1]) + AllTrim(SD1->D1_COD)
					If SFT->(dbSeek(cChaveSFT))
						cSitTrib 	:= SFT->FT_CSTISS
					Else
						cSitTrib	:= SD1->D1_CLASFIS
					Endif
				Endif		
	        Else
				SD2->(dbSetOrder(3))
				If SD2->(dbSeek(xFilial("SD2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					cChaveSFT := xFilial("SFT") + 'S' + (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_NFISCAL + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA 
					cChaveSFT += Padr(SD2->D2_ITEM,TamSX3("FT_ITEM")[1]) + AllTrim(SD2->D2_COD)
					If SFT->(dbSeek(cChaveSFT))
						cSitTrib 	:= SFT->FT_CSTISS
					Else
						cSitTrib	:= SD2->D2_CLASFIS
					Endif
				Endif
			Endif
			SFT->(RestArea(aAreaSFT))
	
			cSeek := dtos(dData)+cEsp+cSer+cConta+cCFPS+Str(nAliq,5,2)
			While !Eof() .And. cSeek == dtos((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_ESPECIE+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CONTA+(cAliasSF3)->F3_CFPS+Str((cAliasSF3)->F3_ALIQICM,5,2)
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Buscando Situacao Tributaria para comparacao,   ³
				//³pois se for diferente também quebro a chave.    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
				aAreaSFT := SFT->(GetArea())
				SFT->(dbSetOrder(1)) // FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA, FT_ITEM, FT_PRODUTO
				If (cAliasSF3)->F3_CFO < "5"
					SD1->(dbSetOrder(1))
					If SD1->(dbSeek(xFilial("SD1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
						cChaveSFT := xFilial("SFT") + 'E' + (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_NFISCAL + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA 
						cChaveSFT += Padr(SD1->D1_ITEM,TamSX3("FT_ITEM")[1]) + AllTrim(SD1->D1_COD)
						If SFT->(dbSeek(cChaveSFT))
							cSitT2 	:= SFT->FT_CSTISS
						Else
							cSitT2	:= SD1->D1_CLASFIS
						Endif
					Endif
				Else
					SD2->(dbSetOrder(3))
					If SD2->(dbSeek(xFilial("SD2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
						cChaveSFT := xFilial("SFT") + 'S' + (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_NFISCAL + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA 
						cChaveSFT += Padr(SD2->D2_ITEM,TamSX3("FT_ITEM")[1]) + AllTrim(SD2->D2_COD)
						If SFT->(dbSeek(cChaveSFT))
							cSitT2 	:= SFT->FT_CSTISS
						Else
							cSitT2	:= SD2->D2_CLASFIS
						Endif
					Endif
				Endif
				SFT->(RestArea(aAreaSFT))
	
				If cSitTrib <> cSitT2
					Exit		
				Endif	
				
				nCont ++
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se a próxima nota está na sequencia    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
				If nCont > 1 .And. (Val(cNFFim)+1) <> Iif(Empty((cAliasSF3)->F3_NFELETR),Val((cAliasSF3)->F3_NFISCAL),Val((cAliasSF3)->F3_NFELETR))
					Exit		
				Else
					cNFFim 	:= Iif(Empty((cAliasSF3)->F3_NFELETR),(cAliasSF3)->F3_NFISCAL,Alltrim((cAliasSF3)->F3_NFELETR))
					nValCont 	+= (cAliasSF3)->F3_VALCONT      
					nBsCalc 	+= (cAliasSF3)->F3_BASEICM
					nValISS 	+= (cAliasSF3)->F3_VALICM		
				Endif
								
				(cAliasSF3)->(DbSkip())
			Enddo
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprimo a linha do relatorio pois mudou a chave ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
			lHouveMov := .T.             
	
			FmtLin({	dData,;
						cEsp,;
						cSerView,;
						Iif(cNFIni==cNFFim,cNFIni,cNFIni + " a "+ cNFFim),;
						TransForm(nValCont,"@e 999,999,999,999,999,999.99"),;
						cConta,;
						cCFPS,;
						cSitTrib,;
						TransForm(nBsCalc,"@e 999,999,999,999,999,999.99"),;
						TransForm(nAliq,"@e 9,999,999.99"),;
						TransForm(nValISS,"@e 999,999,999,999,999,999.99")},aLaySt[16],,,@nLin)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Acumula os valores tot. página³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
			nValContTP	+= nValCont
			nBsCalcTP	+= nBsCalc
			nValISSTP	+= nValISS			
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Zera as variaveis de impressao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
			nCont 		:= 0
			nValCont 	:= 0
			nBsCalc 	:= 0
			nValISS 	:= 0
		Enddo                       
		
		If nLin > 57
			FmtLin({},aLaySt[17],,,@nLin)	
			FmtLin({TransForm(nValContTP,"@e 999,999,999,999,999,999.99"),TransForm(nBsCalcTP,"@e 999,999,999,999,999,999.99"),"",TransForm(nValISSTP,"@e 999,999,999,999,999,999.99")},aLaySt[18],,,@nLin)	
			FmtLin({},aLaySt[19],,,@nLin)	
			
			lHouveMov 	:= .F.             				
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Completa o preenchimento da pagina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nlin <= 57 .And. lHouveMov
			While nLin <= 57
				FmtLin({,,,,,,,,,,,},aLaySt[16],,,@nLin)
			EndDo
			FmtLin({},aLaySt[17],,,@nLin)
			FmtLin({TransForm(nValContTP,"@e 999,999,999,999,999,999.99"),TransForm(nBsCalcTP,"@e 999,999,999,999,999,999.99"),"",TransForm(nValISSTP,"@e 999,999,999,999,999,999.99")},aLaySt[18],,,@nLin)	
			FmtLin({},aLaySt[19],,,@nLin)	                                         		
		Endif
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime informacao que nao houve movimento                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lHouveMov
		nlin    := 0
		Mr976Cabec(@nLin,aLaySt,@nPagina,cNome,nLivro,cCMC,cPeriodo,cCGC)	
		FmtLin({},aLaySt[20],,,@nLin)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Completa o preenchimento da pagina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While nLin <= 57
			FmtLin({,,,,,,,,,,,},aLaySt[16],,,@nLin)
		EndDo
		FmtLin({},aLaySt[17],,,@nLin)
		FmtLin({TransForm(nValContTP,"@e 999,999,999,999,999,999.99"),TransForm(nBsCalcTP,"@e 999,999,999,999,999,999.99"),"",TransForm(nValISSTP,"@e 999,999,999,999,999,999.99")},aLaySt[18],,,@nLin)	
		FmtLin({},aLaySt[19],,,@nLin)	
	EndIf
	
	If !lQuery
		RetIndex("SF3")	
		dbClearFilter()	
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	Endif
Endif	

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTR976Str ºAutor  ³Luciana Pires       º Data ³  24/09/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar um array apenas com os campos utilizados na query    º±±
±±º          ³para passagem na funcao TCSETFIELD                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aCampos: campos a serem tratados na query                   º±±
±±º          ³cCmpQry: string contendo os campos para select na query     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR976                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
#IFDEF TOP
Static Function MTR976Str(aCampos,cCmpQry)

Local	aRet	:=	{}
Local	nX		:=	0
Local	aTamSx3	:=	{}

For nX := 1 To Len(aCampos)
	If(FieldPos(aCampos[nX])>0)
		aTamSx3 := TamSX3(aCampos[nX])
		aAdd (aRet,{aCampos[nX],aTamSx3[3],aTamSx3[1],aTamSx3[2]})
		cCmpQry	+=	aCampos[nX]+", "
	EndIf
Next(nX)

If(Len(cCmpQry)>0)
	cCmpQry	:=	" " + SubStr(cCmpQry,1,Len(cCmpQry)-2) + " "
EndIf 
	
Return(aRet)
#ENDIF



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³R976LayOut³ Autor ³ Luciana Pires         ³ Data ³ 21/09/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ LayOut do Registro de Apuração do ISS Modelo 1             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function R976LayOut(aLay)

                    //  1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
                    //  01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

aLay[01] := STR0006 // "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLay[02] := STR0007 // "| LIVRO DE REGISTRO DE APURAÇÃO DO ISS - MODELO I                                                                                                                                                                          |"
aLay[03] := STR0008 // "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLay[04] := STR0009 // "+-------------------------------------------------------------------------------------------------------------------------------------------------+------------------------------------+-----------------------------------+"
aLay[05] := STR0010 // "| Razão Social: ################################################################################################################################# | Livro nº.: ############            | Folha nº.: ############           |"
aLay[06] := STR0011 // "+------------------------------------------------------------------+------------------------------------------------------------------------------+------------------------------------+-----------------------------------+"
aLay[07] := STR0012 // "| CMC: ####################################                        | CNPJ-MF: ####################################                                | Período: ############################                                  |"
aLay[08] := STR0013 // "+------------------------------------------------------------------+------------------------------------------------------------------------------+------------------------------------------------------------------------+"
aLay[09] := STR0014 // "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLay[10] := STR0015 // "|                                                                                              APURAÇÃO DO ISS - CONTRIBUINTE                                                                                              |"
aLay[11] := STR0016 // "+------------------------------------------------------------------+-----------------------------+----------------------+-------------------------+------------------------------------------------------------------------+"
aLay[12] := STR0017 // "|                          DOCUMENTOS FISCAIS                      |            VALOR            |        CÓDIGO        |     CÓDIGOS FISCAIS     |                           CÁLCULO DO IMPOSTO                           |"
aLay[13] := STR0018 // "+------------+------+-------+------------------------------+-------+                             +                      +-----------------+-------+----------------------------+--------------+----------------------------+"
aLay[14] := STR0019 // "|    DATA    | ESP. | SÉRIE |            NÚMERO            | CANC. |           CONTÁBIL          |       CONTÁBIL       |       CFPS      |  CST  |       BASE DE CÁLCULO      |   ALÍQUOTA   |        VALOR DO ISS        |"
aLay[15] := STR0020 // "+------------+------+-------+------------------------------+-------+-----------------------------+----------------------+-----------------+-------+----------------------------+--------------+----------------------------+"
aLay[16] := STR0021 // "| ########## | #### | ##### | ############################ | ##### | ########################### | #################### | ############### | ##### | ########################## | ############ | ########################## |"
aLay[17] := STR0022 // "+------------------------------------------------------------------+-----------------------------+----------------------+-----------------+-------+----------------------------+--------------+----------------------------+"
aLay[18] := STR0023 // "                                                   TOTAL DA PÁGINA | ########################### |                                                | ########################## | ############ | ########################## |"
aLay[19] := STR0024 // "                                                                   +-----------------------------+------------------------------------------------+----------------------------+--------------+----------------------------+"
aLay[20] := STR0025 // "|     *** NAO HOUVE MOVIMENTO ***                          |       |                             |                      |                 |       |                            |              |                            |"

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³R976LaySt ³ Autor ³ Natalia Antonucci     ³ Data ³ 24/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ LayOut do Registro de Apuração do ISS Substituto tributario³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function R976LaySt(aLaySt)

                      // 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
                      // 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
aLaySt[01] := STR0006 //"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLaySt[02] := STR0007 //"| LIVRO DE REGISTRO DE APURAÇÃO DO ISS - MODELO I                                                                                                                                                                          |"
aLaySt[03] := STR0008 //"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLaySt[04] := STR0009 //"+-------------------------------------------------------------------------------------------------------------------------------------------------+------------------------------------+-----------------------------------+"
aLaySt[05] := STR0010 //"| Razão Social: ################################################################################################################################# | Livro nº.: ############            | Folha nº.: ############           |"
aLaySt[06] := STR0011 //"+------------------------------------------------------------------+------------------------------------------------------------------------------+------------------------------------+-----------------------------------+"
aLaySt[07] := STR0012 //"| CMC: ####################################                        | CNPJ-MF: ####################################                                | Período: ############################                                  |"
aLaySt[08] := STR0013 //"+------------------------------------------------------------------+------------------------------------------------------------------------------+------------------------------------------------------------------------+"                      
aLaySt[09] := STR0014 //"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLaySt[10] := STR0027 //"|                                                                                              APURAÇÃO DO ISS - SUBSTITUTO TRIBUTÁRIO                                                                                     |"
aLaySt[11] := STR0028 //"+------------------------------------------------------------------+-----------------------------+----------------------+-------------------------+------------------------------------------------------------------------+"
aLaySt[12] := STR0029 //"|                          DOCUMENTOS FISCAIS                      |            VALOR            |        CÓDIGO        |     CÓDIGOS FISCAIS     |                           CÁLCULO DO IMPOSTO                           |"
aLaySt[13] := STR0030 //"+------------+------+-------+--------------------------------------+                             +                      +-----------------+-------+----------------------------+--------------+----------------------------+"
aLaySt[14] := STR0031 //"|    DATA    | ESP. | SÉRIE |            NÚMERO                    |            CONTÁBIL         |       CONTÁBIL       |       CFPS      |  CST  |       BASE DE CÁLCULO      |   ALÍQUOTA   |        VALOR DO ISS        |"
aLaySt[15] := STR0032 //"+------------+------+-------+--------------------------------------+-----------------------------+----------------------+-----------------+-------+----------------------------+--------------+----------------------------+"
aLaySt[16] := STR0033 //"| ########## | #### | ##### | #################################### | ########################### | #################### | ############### | ##### | ########################## | ############ | ########################## |"
aLaySt[17] := STR0034 //"+------------------------------------------------------------------+-----------------------------+----------------------+-----------------+-------+----------------------------+--------------+----------------------------+"
aLaySt[18] := STR0035 //"                                                   TOTAL DA PÁGINA | ########################### |                                                | ########################## | ############ | ########################## |"
aLaySt[19] := STR0036 //"                                                                   +-----------------------------+------------------------------------------------+----------------------------+--------------+----------------------------+"
aLaySt[20] := STR0037 //"|     *** NAO HOUVE MOVIMENTO ***                                  |                             |                      |                 |       |                            |              |                            |"

Return(.T.)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³R976Ajuste³ Autor ³ Natalia Antonucci     ³ Data ³ 11/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ LayOut do Quadro de ajuste                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function R976Ajuste(aLayAj)

                      // 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
                      // 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
aLayAj[01] := STR0006 //"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLayAj[02] := STR0007 //"| LIVRO DE REGISTRO DE APURAÇÃO DO ISS - MODELO I                                                                                                                                                                          |"
aLayAj[03] := STR0008 //"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLayAj[04] := STR0009 //"+-------------------------------------------------------------------------------------------------------------------------------------------------+------------------------------------+-----------------------------------+"
aLayAj[05] := STR0010 //"| Razão Social: ################################################################################################################################# | Livro nº.: ############            | Folha nº.: ############           |"
aLayAj[06] := STR0011 //"+------------------------------------------------------------------+------------------------------------------------------------------------------+------------------------------------+-----------------------------------+"
aLayAj[07] := STR0012 //"| CMC: ####################################                        | CNPJ-MF: ####################################                                | Período: ############################                                  |"
aLayAj[08] := STR0013 //"+------------------------------------------------------------------+------------------------------------------------------------------------------+------------------------------------------------------------------------+"                      
aLayAj[09] := STR0014 //"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLayAj[10] := STR0039 //"|                                                                                                   QUADRO DE AJUSTE                                                                                                       |"
aLayAj[11] := STR0040 //"+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------------+"
aLayAj[12] := STR0041 //"| Valor do ISS Apurado no Periodo                                                                                                                                                             | ########################## |"
aLayAj[13] := STR0042 //"+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------------+"
aLayAj[14] := STR0043 //"| Ajuste (-)                                                                                                                                                                                  |                            |"
aLayAj[15] := STR0044 //"+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+                            |"
aLayAj[16] := STR0045 //"|                          DOCUMENTOS FISCAIS                      |                   CÓDIGOS FISCAIS                  |                    VALOR DO ISS A RECUPERAR       				    |                            |"
aLayAj[17] := STR0046 //"+---------------+--------------------------------------------------+----------------------------------------------------+---------------------------------------------------------------------+                            |"
aLayAj[18] := STR0047 //"|     ESP.      |     SÉRIE     |            NÚMERO                |          CFPS            |           CST           |         COMPENSAÇÃO      |              RETENÇÃO NA FONTE           |                            |"
aLayAj[19] := STR0048 //"+---------------+--------------------------------------------------+--------------------------+-------------------------+--------------------------+------------------------------------------+						     |"
aLayAj[20] := STR0049 //"| ############# | ############# | ################################ | ######################## | ####################### | ######################## | ######################################## |                            |"
aLayAj[21] := STR0050 //"+---------------+--------------------------------------------------+--------------------------+-------------------------+--------------------------+------------------------------------------+----------------------------+"
aLayAj[22] := STR0051 //"| Total dos Ajustes                                                                                                     | ######################## | ######################################## | ########################## |"
aLayAj[23] := STR0052 //"+-----------------------------------------------------------------------------------------------------------------------+--------------------------+------------------------------------------+----------------------------+"
aLayAj[24] := STR0053 //"| Total do ISS Devido                                                                                                    																	    | ########################## |"
aLayAj[25] := STR0054 //"+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------------+"
aLayAj[26] := STR0055 //"|     *** NAO HOUVE MOVIMENTO ***                                  |                          |                         |                          |                                          |                            |"
Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Mr976Cabec  ³ Autor ³ Luciana Pires      ³ Data ³ 21/09/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Imp do Cabecaçho do Reg de Apur de ISS Mod 1      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR976()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Mr976Cabec(nLin,aLay,nPagina,cNome,nLivro,cCMC,cPeriodo,cCGC,lQuadro)

Default lQuadro := .T.

nLin := 0
@ nLin,000 Psay aValImp(Limite)
nLin++
FmtLin({},aLay[01],,,@nLin)
FmtLin({},aLay[02],,,@nLin)
FmtLin({},aLay[03],,,@nLin)
FmtLin({},aLay[04],,,@nLin)
FmtLin({cNome,StrZero(nLivro,12),StrZero(nPagina,12)},aLay[05],,,@nLin)
FmtLin({},aLay[06],,,@nLin)
FmtLin({cCMC,cCGC,cPeriodo},aLay[07],,,@nLin)
FmtLin({},aLay[08],,,@nLin)
FmtLin({},aLay[09],,,@nLin)
FmtLin({},aLay[10],,,@nLin)
If lQuadro
	FmtLin({},aLay[11],,,@nLin)
	FmtLin({},aLay[12],,,@nLin)
	FmtLin({},aLay[13],,,@nLin)
	FmtLin({},aLay[14],,,@nLin)
	FmtLin({},aLay[15],,,@nLin)
Endif
nPagina +=1

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R976ImpTerm() ³ Autor ³ Luciana Pires      ³ Data ³21/09/07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime termos de Abertura e Encerramento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR976()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function R976ImpTerm(cPerg, nPagina)

Local cArqAbert	:= GetNewPar("MV_ABR976","")
Local cArqEncer	:= GetNewPar("MV_ENC976","")
Local aDriver 	:= ReadDriver()
Local aDados    := {}

AADD(aDados,{"D_I_A",Day(dDatabase)})
AADD(aDados,{"M_E_S",Alltrim(MesExtenso(Month(dDatabase)))})
AADD(aDados,{"A_N_O",Year(dDatabase)})
AADD(aDados,{"P_A_G",nPagina-1})

AADD(aDados,{"M_O_D","Modelo 1"})
AADD(aDados,{"R_E_G","REGISTRO DE APURAÇÃO DO ISS"})

If !Empty(cArqAbert) .And. !Empty(cArqEncer)
	TERMGO(cArqAbert,cArqEncer,cPerg,aDriver[4],aDados)
Endif

Return(.T.)
