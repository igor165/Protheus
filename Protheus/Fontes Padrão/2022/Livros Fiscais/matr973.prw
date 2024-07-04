#INCLUDE "matr973.ch"
#INCLUDE "Protheus.ch"
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATR973   ³ Autor ³ Liber de Esteban         ³ Data ³ 02.10.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Registro de Apuracao do ISS - Valinhos						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MATR973                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Matr973()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define Variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local titulo	:=	STR0001 //"Registro de Apuracao do ISS"
Local cDesc1	:=	STR0002 //"Este relatório ira imprimir os Registro de Apuraçãao referentes a Imposto Sobre "
Local cDesc2	:=	STR0003 //"Servicos de Qualquer Natureza, conforme o periodo informado."
Local cDesc3	:=	""
Local cString	:= "SF3"
Local wnrel		:= "MATR973"  	// Nome do Arquivo utiLizado no Spool
Local nomeprog	:= "MATR973"  	// nome do programa

Local lImpLivro	:= .F.
Local lImpTermo	:= .F.
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

Private Tamanho := "G"
Private Limite  := 200
Private aOrdem  := {}
Private cPerg   := "MTR973"
Private aReturn	:=	{ STR0004, 1,STR0005, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private lEnd	:= .F.// Controle de cancelamento do relatorio
Private m_pag	:= 1  // Contador de Paginas
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault
Private nPagina	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas como parametros                            ³
//³ mv_par01 = Data Inicial											³
//³ mv_par02 = Data Final											³
//³ mv_par03 = Livro Selecionado									³
//³ mv_par04 = Modelo a ser impresso (1 - Saidas / 2 - Entradas)	³
//³ mv_par05 = Imprime (1 - Livro / 2 - Termos / 3 - Livro e Termos)³
//³ mv_par06 = Página inicial										³
//³ mv_par07 = Representante Legal                                  ³
//³ mv_par08 = Responsavel Contabil                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lVerpesssen
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel	:=	"MATR973"
	wnrel	:=	SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)

	If nLastKey == 27
		dbClearFilter()
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		dbClearFilter()
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao de Termo / Livro                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case mv_par05==1 ; lImpLivro:=.T. ; lImpTermo:=.F.
		Case mv_par05==2 ; lImpLivro:=.F. ; lImpTermo:=.T.
		Case mv_par05==3 ; lImpLivro:=.T. ; lImpTermo:=.T.
	EndCase

	nPagina	:= mv_par06

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa relatorio                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lImpLivro
		RptStatus({|lEnd| Imp973Rel(@lEnd,wnRel,cString,Tamanho, nPagina)},titulo)
	EndIf
	If lImpTermo
		Imp973Term()
	EndIf

	dbSelectArea(cString)
	dbClearFilter()
	Set Device To Screen
	Set Printer To

	If (aReturn[5] = 1)
		dbCommitAll()
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
EndIf

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Imp973Rel ³ Autor ³ Liber de Esteban      ³ Data ³02/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Imp973Rel()

Local aLay	    := {}
Local aDetail   := {}

Local lQuery    := .F.
Local lHouveMov := .F.

Local cAliasSF3 	:= "SF3"
Local cArqInd   	:= ""

Local cCNPJ		:= ""
Local cNumIni	:= ""
Local cNumFim	:= ""
Local cReten	:= ""
Local cServ		:= ""

Local dData		:= cToD("//")

Local nMes		:= 0
Local nValDoc	:= 0
Local nBase		:= 0
Local nAliq		:= 0
Local nISS 		:= 0
Local nISSRet	:= 0
Local nTotISS	:= 0
Local nTotRet	:= 0

Local nModelo	:= mv_par04
Local cModelo 	:= STR(nModelo,1)
Local nQtdLinha	:= 55
Local Li        := 100
Local nX		:= 0

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
        
   		lQuery    := .T.
		cAliasSF3 := GetNextAlias()
		
	    aAdd(aCamposSF3,"F3_FILIAL")
   	    aAdd(aCamposSF3,"F3_ENTRADA")
   	    aAdd(aCamposSF3,"F3_NFISCAL")
   	    aAdd(aCamposSF3,"F3_SERIE")
   	    aAdd(aCamposSF3,"F3_CLIEFOR")
   	    aAdd(aCamposSF3,"F3_LOJA")
   	    aAdd(aCamposSF3,"F3_CFO")
   	    aAdd(aCamposSF3,"F3_ALIQICM")   
   	    aAdd(aCamposSF3,"F3_ESPECIE")
   	    aAdd(aCamposSF3,"F3_BASEICM")
   	    aAdd(aCamposSF3,"F3_ISENICM")
   	    aAdd(aCamposSF3,"F3_OUTRICM")
   	    aAdd(aCamposSF3,"F3_VALCONT")
   	    aAdd(aCamposSF3,"F3_TIPO")
   	    aAdd(aCamposSF3,"F3_VALICM")
   	    aAdd(aCamposSF3,"F3_DOCOR")
   	    aAdd(aCamposSF3,"F3_RECISS")
   	    aAdd(aCamposSF3,"F3_DTCANC")
		aAdd(aCamposSF3,"F3_CODISS")
		aAdd(aCamposSF3,"F3_NRLIVRO")
		aAdd(aCamposSF3,"F3_OBSERV")
		aAdd(aCamposSF3,"F3_FORMULA")
		
    	aStruSF3  := SF3->(SF3Stru(aCamposSF3,@cCmpQry))
    	SF3->(dbCloseArea())
		
		cQuery    := "SELECT "
		cQuery    += cCmpQry
		cQuery    += "FROM " + RetSqlName("SF3") + " SF3 "
		cQuery    += "WHERE "
		cQuery    += "F3_FILIAL = '" + xFilial("SF3") + "' AND "
		If nModelo == 1
			cQuery    += "F3_CFO >= '5'  AND "
		Else
			cQuery    += "F3_CFO < '5' AND "
		Endif
		cQuery    += "F3_ENTRADA >= '" + Dtos(mv_par01) + "' AND "
		cQuery    += "F3_ENTRADA <= '" + Dtos(mv_par02) + "' AND "
		cQuery    += "((F3_TIPO = 'S') OR "
		cQuery    += "(F3_TIPO = 'L' AND F3_CODISS <> '')) AND "
		cQuery    += "F3_DTCANC = '' AND "
		If mv_par03<>"*"
			cQuery	+=	"F3_NRLIVRO='"+mv_par03+"' AND "
		EndIf
		cQuery    += "F3_OBSERV NOT LIKE '%CANCELAD%' AND "
		cQuery    += "SF3.D_E_L_E_T_ = ' ' "
		cQuery    += "ORDER BY F3_ENTRADA,F3_SERIE,F3_NFISCAL,F3_TIPO,F3_CLIEFOR,F3_LOJA"
		
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
		cChave	:=	"DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_TIPO+F3_CLIEFOR+F3_LOJA"
		cFiltro :=  "F3_FILIAL == '" + xFilial("SF3") + "' .AND. 
		If nModelo == 1
			cFiltro :=  "F3_CFO >= '5" + Space(Len(F3_CFO)-1) + "' .And."
		Else                                                              
			cFiltro :=  "F3_CFO < '5" + Space(Len(F3_CFO)-1) + "' .And."
		Endif
		cFiltro	+=	"DtoS(F3_ENTRADA) >= '" + DtoS(mv_par01) + "' .And. DtoS(F3_ENTRADA) <= '" + DtoS(mv_par02) + "' .And. "
		cFiltro	+=	"(F3_TIPO $ ' SN' .Or. "
		cFiltro	+=	"(F3_TIPO = 'L' .And. !EMPTY(F3_CODISS))) .And. "
		cFiltro +=  "Empty(F3_DTCANC) .And. !('CANCELAD'$F3_OBSERV) "
		If mv_par03<>"*"
			cFiltro	+=	".And. F3_NRLIVRO=='"+mv_par03+"'"
		EndIf
		
		IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,STR0006) //"Selecionando Registros..."
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF
		
#IFDEF TOP
	Endif
#ENDIF

aLay := RLayout(nModelo)

dbSelectArea(cAliasSF3)
SetRegua(LastRec())
(cAliasSF3)->(DbGoTop())

While (cAliasSF3)->(!Eof())
	
	nMes := Month((cAliasSF3)->F3_ENTRADA)
	
	lHouveMov := .T.
    
    dDataImp := (cAliasSF3)->F3_ENTRADA
	R973Cabec(@nPagina,(cAliasSF3)->F3_ENTRADA,@Li,nModelo)
	nTotISS	:= 0
	nTotRet	:= 0
	
	While (cAliasSF3)->(!Eof()) .And. Month((cAliasSF3)->F3_ENTRADA) == nMes
		
		IncRegua()
		If Interrupcao(@lEnd)
		    Exit
	 	Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao for fim de arquivo salta pagina com saldo a transportar          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(cAliasSF3)->(Eof()) .And. ( Li > nQtdLinha ) .And. Month((cAliasSF3)->F3_ENTRADA) == nMes
			R973Total(nModelo,Li,nTotISS,nTotRet)
			R973Cabec(@nPagina,(cAliasSF3)->F3_ENTRADA,@Li,nModelo)
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Informacoes que serao impressas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dData	:= (cAliasSF3)->F3_ENTRADA
		cNumIni	:= (cAliasSF3)->F3_NFISCAL
		cServ	:= (cAliasSF3)->F3_CODISS
		cReten	:= STR0007 //"Nao"
		nValDoc	:= (cAliasSF3)->F3_VALCONT
		nBase	:= (cAliasSF3)->F3_BASEICM
		nAliq	:= (cAliasSF3)->F3_ALIQICM
		nISS	:= (cAliasSF3)->F3_VALICM
		nISSRet := 0
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisa se NF Lote           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSF3)->F3_TIPO = "L" .And. !Empty((cAliasSF3)->F3_DOCOR)
			cNumFim := (cAliasSF3)->F3_DOCOR
		Else
			cNumFim := cNumIni
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisa se ISS retido        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cRecISS := (cAliasSF3)->F3_RECISS
		If (cRecISS$"S1" .And. nModelo == 1) .Or. (cRecISS$"N2" .And. nModelo == 2)
			nISSRet += (cAliasSF3)->F3_VALICM
			cReten	:= STR0008 //"Sim"
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca CNPJ                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nModelo == 2
			DbSelectArea("SA2")	//Cadastro de Fornecedor
			("SA2")->(DbSetOrder (1))
			("SA2")->(MsSeek (xFilial ("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			
			cCNPJ	:=	Transform(SA2->A2_CGC,IIF(RetPessoa(SA2->A2_CGC) == "J","@R 99.999.999/9999-99","@R 999.999.999-99"))
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Acumula total                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nISS	-= nISSRet
		nTotISS	+= nISS
		nTotRet	+= nISSRet
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime informacoes            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nModelo == 1
			aDetail := { dData,;
						cNumIni,;
						cNumFim,;
						cServ,;
						cReten,;
						TransForm(nValDoc,"@E 999,999,999,999.99"),;
						TransForm(nBase,"@E 999,999,999,999.99"),;
						TransForm(nALiq,"@E 99.99"),;
						TransForm(nISS,"@E 999,999,999,999.99"),;
						TransForm(nISSRet,"@E 999,999,999,999.99")}
		Else
			aDetail := { dData,;
						cNumIni,;
						cCNPJ,;
						cServ,;
						cReten,;
						TransForm(nValDoc,"@E 999,999,999,999.99"),;
						TransForm(Iif(nISSRet>0,nBase,0),"@E 999,999,999,999.99"),;
						TransForm(Iif(nISSRet>0,nALiq,0),"@E 99.99"),;
						TransForm(Iif(nISSRet>0,nISSRet,0),"@E 999,999,999,999.99")}
		Endif
		FmtLin(aDetail,aLay[11],,,@Li)
		
		(cAliasSF3)->(dbSkip())
		
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Completa o preenchimento da pagina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := Li to nQtdLinha          
		FmtLin({},aLay[15],,,@Li)	
	Next

	R973Total(nModelo,Li,nTotISS,nTotRet)
EndDo

If !lHouveMov

	R973Cabec(@nPagina,mv_par01,@Li,nModelo)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Completa o preenchimento da pagina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := Li to nQtdLinha
		FmtLin({},aLay[15],,,@Li)	
	Next

	R973Total(nModelo,Li,nTotISS,nTotRet)
Endif

If !lQuery
	RetIndex("SF3")
	dbClearFilter()
	Ferase(cArqInd+OrdBagExt())
	FErase(cArqInd+GetDBExtension())
Else
	dbSelectArea(cAliasSF3)
	dbCloseArea()
Endif

Return(nPagina)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R973Cabec ³ Autor ³ Liber de Esteban      ³ Data ³02/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o cabecalho do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPagina  -> Numero da Pagina a ser Impressa                 ³±±
±±³          ³dDataImp -> Mes que esta sendo impresso                     ³±±
±±³          ³Li       -> Linha corrente da impressao                     ³±±
±±³          ³nModelo  -> modelo de impressao(entradas ou saidas)         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R973Cabec(nPagina,dDataImp,Li,nModelo)

Local aLay 		:= RLayOut(nModelo)
Local cMesIncid	:= MesExtenso(Month(dDataImp))
Local cAno		:= Ltrim(Str(Year(dDataImp)))

Li := 0

FmtLin({},aLay[01],,,@Li)
FmtLin({},aLay[04],,,@Li)
FmtLin({StrZero(nPagina,4)},aLay[02],,,@Li)
FmtLin({cMesIncid,cAno},aLay[03],,,@Li)
FmtLin({},aLay[04],,,@Li)
FmtLin({SM0->M0_NOMECOM,SM0->M0_ENDENT,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),SM0->M0_INSC,SM0->M0_INSCM},aLay[05],,,@Li)
FmtLin({},aLay[04],,,@Li)
FmtLin({},aLay[06],,,@Li)
FmtLin({},aLay[07],,,@Li)
FmtLin({},aLay[08],,,@Li)
FmtLin({},aLay[09],,,@Li)	
FmtLin({},aLay[10],,,@Li)

nPagina += 1

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RLayOut  | Autor ³ Liber de Esteba       ³ Data ³02/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o layout de impressao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aLay -> Array com o layout                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nModelo -> modelo de impressao(entradas ou saidas)         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RLayOut(nModelo)

Local aLay := Array(40)

If nModelo == 1

//                         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16         17       18        19        20        21        22
//	            "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
	aLay[01] :=           "+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[02] := STR0009 //"|                                                                             PREFEITURA DO MUNICIPIO DE VALINHOS                                                                            FOLHA #### |"
	aLay[03] := STR0010 //"|                                                                     LIVRO DE REGISTRO DE SERVICOS PRESTADOS - MODELO 1                                   COMPETENCIA:   MES ############   ANO ####   |"
	aLay[04] :=           "|                                                                                                                                                                                                       |"
	aLay[05] := STR0011 //"|   ###########################################    Endereco : #################################    CNPJ : #################    I.E. : ###############    Inscricao Municipal : ##################       |"
	aLay[06] :=           "+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[07] :=           "|1|            |2|                   |3|   SERVICO PRESTADO:    |4|              |5|                     |6|                     |7|              |8|                     |9|                           |"
	aLay[08] := STR0012 //"|     DATA     |      NOTA FISCAL      |    SUBITEM DA LISTA DE   |    RETENCAO    |    VALOR BRUTO DOS    |    BASE DE CALCULO    |    ALIQUOTA    |       IMPOSTO A       |    IMPOSTO RETIDO PELO    |"
	aLay[09] := STR0013 //"|              |    Num.  |A|  Num.    |         SERVICO          |   (SIM / NAO)  |     SERVICOS (R$)     |                       |      (%)       |     RECOLHER (R$)     |       TOMADOR (R$)        |"
	aLay[10] :=           "|==============+=======================+==========================+================+=======================+=======================+================+=======================+===========================|"
    aLay[11] :=           "|  ##/##/##    | ######### A ######### |           ##.##          |      ###       |  ###############,##   |  ###############,##   |     ##,##      |  ###############,##   |   ###############,##      |"
    aLay[12] :=           "|--------------+-----------------------+--------------------------+----------------+-----------------------+-----------------------+----------------+-----------------------+---------------------------|"
	aLay[13] := STR0014 //"                                                                                                           |10| TOTAL DO MES OU TRANSPORTE (R$).....|  ###############,##   |   ###############,##      |"
	aLay[14] :=           "                                                                                                           |----------------------------------------+-----------------------+---------------------------|"
	aLay[15] :=           "|              |                       |                          |                |                       |                       |                |                       |                           |"
Else
	aLay[01] :=           "+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[02] := STR0021 //"|                                                                            PREFEITURA DO MUNICIPIO DE VALINHOS                                                                           FOLHA #### |"
	aLay[03] := STR0015 //"|                                                                LIVRO DE REGISTRO DE SERVICOS TOMADOS DE TERCEIROS - MODELO 2                           COMPETENCIA:   MES ############   ANO ####   |"
	aLay[04] :=           "|                                                                                                                                                                                                     |"
	aLay[05] := STR0022 //"|   ###########################################    Endereco : #################################   CNPJ : #################   I.E. : ###############   Inscricao Municipal : ######################### |"
	aLay[06] :=           "+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[07] :=           "|1|            |2|                |3|                          |4|                        |5|              |6|                     |7|                     |8|              |9|                       |"
	aLay[08] := STR0016 //"|     DATA     |    NOTA FISCAL   |      C.N.P.J. / C.P.F.     |     SUBITEM DA LISTA     |    RETENCAO    |    VALOR BRUTO DOS    |    BASE DE CALCULO    |    ALIQUOTA    |        IMPOSTO A        |"
	aLay[09] := STR0017 //"|              |                  |        DO PRESTADOR        |        DE SERVICOS       |  (SIM / NAO)   |     SERVICOS (R$)     |                       |      (%)       |      RECOLHER (R$)      |"
	aLay[10] :=           "|==============+==================+============================+==========================+================+=======================+=======================+================+=========================|"
    aLay[11] :=           "|  ##/##/##    |    #########     |    #####################   |          ##.##           |       ###      |  ###############,##   |  ###############,##   |     ##,##      |   ###############,##    |"
    aLay[12] :=           "|--------------+------------------+----------------------------+--------------------------+----------------+-----------------------+-----------------------+----------------+-------------------------|"
	aLay[13] := STR0018 //"                                                                                                                                   |10| TOTAL DO MES OU TRANSPORTE (R$).....|   ###############,##    |"
	aLay[14] :=           "                                                                                                                                   |----------------------------------------+-------------------------|"
	aLay[15] :=           "|              |                  |                            |                          |                |                       |                       |                |                         |"
Endif

Return(aLay)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³R973Total ³Autor  ³Liber de Esteban       ³ Data ³ 02/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Imprime totais do relatorio                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nModelo   -> Modelo a ser impresso (1 Saidas ou 3 Entradas)  ³±±
±±³          ³Li        -> Numero da linha que sera impressa               ³±±
±±³          ³nTotISS   -> Valor total do documento fiscal                 ³±±
±±³          ³nTotRet   -> Total de imposto Retido                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R973Total(nModelo,Li,nTotISS,nTotRet)

Local aLay 		:= RLayout(nModelo)                                  
Local aDetail 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime total                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

FmtLin({},aLay[12],,,@Li)
If nModelo == 1
	aDetail := {TransForm(nTotISS,"@E 999,999,999,999.99"),;
				TransForm(nTotRet,"@E 999,999,999,999.99")}
Else
	aDetail := {TransForm(nTotRet,"@E 999,999,999,999.99")}
EndIf
FmtLin(aDetail,aLay[13],,,@Li)
FmtLin({},aLay[14],,,@Li)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SF3Stru  ³ Autor ³ Liber de Esteban      ³ Data ³02/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma array com os campos utiLizados na query           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet: Array contendo a estrutura dos campos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aCampos -> Campos a serem tratados na query                 ³±±
±±³          ³cCmpQry -> String com os campos para select na query        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
#IFDEF TOP
Static Function SF3Stru(aCampos,cCmpQry)

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
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Imp973Term ³ Autor ³ Liber de esteban   ³ Data ³02/10/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime termos de Abertura e Encerramento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet: Array contendo a estrutura dos campos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Imp973Term()

Local cArqAbert	:= GetNewPar("MV_973ABR","")
Local cArqEncer	:= GetNewPar("MV_973ENC","")
Local aDriver	:=	ReadDriver()
Local aDados    := {}

AADD(aDados,{"D_I_A",Day(dDatabase)})
AADD(aDados,{"M_E_S",Alltrim(MesExtenso(Month(dDatabase)))})
AADD(aDados,{"A_N_O",Year(dDatabase)})
AADD(aDados,{"P_A_G",IIf(nPagina > MV_PAR06, nPagina-1,nPagina)})
AADD(aDados,{"T_I_T",IIF(mv_par04 == 1,PadL(STR0019,45),STR0020)}) //"LIVRO DE REGISTRO DE SERVIÇOS PRESTADOS"###"LIVRO DE REGISTRO DE SERVICOS TOMADOS DE TERCEIROS"
AADD(aDados,{"R_E_P",PadR(MV_PAR07,47)})

If !Empty(cArqAbert) .And. !Empty(cArqEncer)
	TERMGO(cArqAbert,cArqEncer,cPerg,aDriver[4],aDados)
Endif

Return .T.
