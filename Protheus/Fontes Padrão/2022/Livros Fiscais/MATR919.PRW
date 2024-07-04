#INCLUDE "MATR919.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MATR919   ³ Autor ³ Mary C. Hergert       ³ Data ³ 13.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Livro ISS - Modelo Porto Alegre/RS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MATR919()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define Variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local Titulo      := OemToAnsi(STR0001)  //"Impressao do Registro de Entradas com ISS"
Local cDesc1      := OemToAnsi(STR0002 ) //"     Este programa ira emitir o relatorio de entradas com ISS "
Local cDesc2      := OemToAnsi(STR0003)  //"de acordo com os parametros configurados pelo usuario"
Local cDesc3      := OemToAnsi("")
Local cString     := "SF3"
Local lDic        := .F. 	// Habilita/Desabilita Dicionario
Local lComp       := .T. 	// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro     := .T. 	// Habilita/Desabilita o Filtro
Local wnrel       := "MATR919"  	// Nome do Arquivo utilizado no Spool
Local nomeprog    := "MATR919"  	// nome do programa

Private Tamanho := "M" // P/M/G
Private Limite  := 132 // 80/132/220
Private aOrdem  := {}  // Ordem do Relatorio
Private cPerg   := "MTR919"  // Pergunta do Relatorio
Private aReturn := { STR0004, 1,STR0005, 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"

Private lEnd    := .F.// Controle de cancelamento do relatorio
Private m_pag   := 1  // Contador de Paginas
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                  ³
//³ mv_par01             // Data Inicial                                  ³
//³ mv_par02             // Data Final                                    ³
//³ mv_par03             // Livro Selecionado                             ³
//³ mv_par04             // Pagina Inicial                                ³
//³ mv_par05             // Nro do CCM                                    ³
//³ mv_par06             // Livro ou Livro+termos ou Termos               ³
//| mv_par07             // Valor da Estimativa                           |
//| mv_par08             // Valor do ISSQN sobre a Estimativa             | 
//| mv_par09             // Valor do ISSQN recolhido dentro do periodo    |
//| mv_par10             // Data do recolhimento do ISSQN no periodo      |
//| mv_par11             // ISSQN recolhido por intimacao ou ato infracao |
//| mv_par12             // Data da intimacao                             |
//| mv_par13             // Numero do ato de infracao                     |
//| mv_par14             // Se deseja apresentar o ISS Retido em Devol.   |
//| mv_par15             // Imprimir notas canceladas                     |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para a SetPrinter                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)
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
	Case mv_par06 == 1 
	     lImpLivro  := .T. 
	     lImpTermos := .F.
	Case mv_par06 == 2 
	     lImpLivro  := .F. 
	     lImpTermos := .T.
	Case mv_par06 == 3 
	     lImpLivro  := .T. 
	     lImpTermos := .T.
EndCase    

If lImpLivro 
	RptStatus({|lEnd| ImpDet(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)
EndIf

If lImpTermos
	R990ImpTerm(cPerg)
EndIf

dbSelectArea(cString)
dbClearFilter()
Set Device To Screen
Set Printer To

If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IMPDET    ³ Autor ³ Mary C. Hergert       ³ Data ³ 13.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpDet()

Local aLay	    := RetLayOut()
Local aDetail   := {}
Local aTotCod   := {}

Local cAliasSF3 := "SF3"
Local cArqInd   := ""

Local dDataImp  := Ctod("//")

Local lQuery    := .F.
Local lHouveMov := .F.

Local nTotal    := 0
Local nTotIss   := 0
Local nToBIss   := 0
Local nTotDed   := 0
Local nPagina   := mv_par04
Local nValDed	:= 0
Local nValLiq	:= 0
Local nValRet	:= 0                                  
Local nRetISS	:= 0
Local li        := 100

#IFDEF TOP
	Local aStruSF3  := {}
	Local aCamposSF3:= {}

	Local cQuery    := ""   
	Local cCmpQry	:= ""

	Local nX        := 0
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
   	    aAdd(aCamposSF3,"F3_DTCANC")
   	    aAdd(aCamposSF3,"F3_OBSERV")
   	    aAdd(aCamposSF3,"F3_RECISS")
    	//
    	aStruSF3  := SF3->(Mtr919Str(aCamposSF3,@cCmpQry))

		lQuery    := .T.
		cAliasSF3 := "F3_MATR919"
		
		cQuery    := "SELECT "
		cQuery    += cCmpQry
		cQuery    += "FROM " + RetSqlName("SF3") + " SF3 "
		cQuery    += "WHERE "
		cQuery    += "F3_FILIAL = '" + xFilial("SF3") + "' AND "
		cQuery    += "F3_CFO >= '5" + SPACE(LEN(F3_CFO)-1) + "' AND "	
		cQuery    += "F3_ENTRADA >= '" + Dtos(mv_par01) + "' AND "
		cQuery    += "F3_ENTRADA <= '" + Dtos(mv_par02) + "' AND "
		// Somente a parte referente ao servico do documento
		cQuery    += "F3_TIPO = 'S' AND "
		If mv_par03<>"*"
			cQuery	+=	"F3_NRLIVRO='"+mv_par03+"' AND "
		EndIf
		// Imprimir notas candeladas
		If MV_PAR15 == 2
			cQuery    += "F3_DTCANC = '" + Space(Len(Dtos(SF3->F3_DTCANC))) + "' AND "
			cQuery    += "F3_OBSERV NOT LIKE '%CANCELAD%' AND "
		EndIf
		cQuery    += "SF3.D_E_L_E_T_ = ' ' "               
		cQuery    += "ORDER BY " + SqlOrder(SF3->(IndexKey()))
	
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
		cFiltro :=  "F3_FILIAL == '" + xFilial("SF3") + "' .AND. F3_CFO >= '5" + Space(Len(F3_CFO)-1) + "' .And."
		cFiltro	+=	"DtoS(F3_ENTRADA) >= '" + DtoS(mv_par01) + "' .And. DtoS(F3_ENTRADA) <= '" + DtoS(mv_par02) + "' .And. "
		// Somente a parte referente ao servico do documento
		cFiltro	+=	"F3_TIPO == 'S' "
		If MV_PAR15 == 2
			cFiltro +=  " .And. Empty(F3_DTCANC) .And. !('CANCELAD'$F3_OBSERV) "
		EndIf
		If mv_par03<>"*"
			cFiltro	+=	".And. F3_NRLIVRO=='"+mv_par03+"'"
		EndIf
			
		IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,STR0006)  //"Selecionando Registros..."
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF                
		(cAliasSF3)->(dbGotop())
		SetRegua(LastRec())

#IFDEF TOP
	Endif    
#ENDIF


While (cAliasSF3)->(!Eof())                  

	nMes := Month((cAliasSF3)->F3_ENTRADA)

    dDataImp := (cAliasSF3)->F3_ENTRADA
	li       := Mr919Cabec(@nPagina,(cAliasSF3)->F3_ENTRADA)
	aTotCod  := {}
	nTotal   := 0
	nTotIss  := 0
	nToBIss  := 0                               
	nTotDed  := 0   

	While (cAliasSF3)->(!Eof()) .And. Month((cAliasSF3)->F3_ENTRADA) == nMes

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O valor do ISS retido na operacao sera lancado em deducoes, ³
		//³visto que nao e devido pela empresa (sera pago pelo cliente)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValRet := 0
		nRetIss := 0
		If mv_par14 == 1
			// Analisa o ISS Retido pelo SF3
			If (cAliasSF3)->F3_RECISS$"S1"
				nValRet := (cAliasSF3)->F3_BASEICM
				nRetISS := (cAliasSF3)->F3_VALICM
			Endif	
		Endif

		// Valor das Deducoes e Valor Liquido
       	If (cAliasSF3)->F3_ISENICM > 0 .Or. (cAliasSF3)->F3_OUTRICM > 0 .Or. ((cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM + (cAliasSF3)->F3_BASEICM == 0)
        	nValDed := 0
        	nValLiq := 0
        Else 
        	nValDed := (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM + nValRet
        	nValLiq := (cAliasSF3)->F3_BASEICM - nValRet 
        Endif
        
		lHouveMov := .T.

		aDetail := {StrZero(Day((cAliasSF3)->F3_ENTRADA),2),;
					(cAliasSF3)->F3_NFISCAL,;				
                    (cAliasSF3)->F3_SERIE,;	
					(cAliasSF3)->F3_ESPECIE,;
					TransForm((cAliasSF3)->F3_VALCONT,"@e 99,999,999.99"),;
					TransForm(nValDed,"@e 99,999,999.99"),;
					TransForm(nValLiq,"@e 99,999,999.99")}
				
		FmtLin(aDetail,aLay[15],,,@Li)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Acumula total                                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(F3_DTCANC) .And. !('CANCELAD'$F3_OBSERV)
			nTotal   += (cAliasSF3)->F3_VALCONT
			nTotIss  += ((cAliasSF3)->F3_VALICM - nRetISS)
			nToBIss  += nValLiq
			nTotDed  += nValDed
		EndIf
			
		(cAliasSF3)->(dbSkip())
    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao for fim de arquivo salta pagina com saldo a transportar          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(cAliasSF3)->(Eof()) .And. ( Li > 57 ) .And. Month((cAliasSF3)->F3_ENTRADA) == nMes
			FmtLin({},aLay[17],,,@Li)
			FmtLin({TransForm(nTotal ,"@e 99,999,999.99"),TransForm(nTotDed ,"@e 99,999,999.99"),TransForm(nToBIss,"@e 99,999,999.99")},aLay[20],,,@Li)
			FmtLin({},aLay[19],,,@Li)			                             
			li := Mr919Cabec(@nPagina,(cAliasSF3)->F3_ENTRADA)
		Endif	
		
	EndDo	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime total                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FmtLin({},aLay[17],,,@Li)
	FmtLin({TransForm(nTotal ,"@e 99,999,999.99"),TransForm(nTotDed ,"@e 99,999,999.99"),TransForm(nToBIss,"@e 99,999,999.99")},aLay[18],,,@Li)
	FmtLin({},aLay[19],,,@Li)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime quadro de resumo                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( Li > 47) 
		li := Mr919Cabec(@nPagina,dDataImp)
	Endif	

	FmtLin({},aLay[22],,,@Li)	 
	FmtLin({},aLay[22],,,@Li)	
	FmtLin({},aLay[23],,,@Li)
	FmtLin({},aLay[24],,,@Li)	
	FmtLin({TransForm(nToBIss ,"@e 99,999,999.99"),TransForm(nTotIss ,"@e 99,999,999.99")},aLay[25],,,@Li)		
	FmtLin({TransForm(mv_par07,"@e 99,999,999.99"),TransForm(mv_par08,"@e 99,999,999.99")},aLay[29],,,@Li)	
	FmtLin({dToC(mv_par10),TransForm(mv_par09,"@e 99,999,999.99")},aLay[30],,,@Li)	
	FmtLin({dToC(mv_par12)},aLay[31],,,@Li)	
	FmtLin({Alltrim(Str(mv_par13)),TransForm(mv_par11,"@e 99,999,999.99")},aLay[32],,,@Li)		
 	FmtLin({},aLay[26],,,@Li)	
 	FmtLin({},aLay[27],,,@Li)	
	Li += 4
	FmtLin({},aLay[33],,,@Li)	
	FmtLin({},aLay[34],,,@Li)	
EndDo

If !lHouveMov
	li:= Mr919Cabec(@nPagina,mv_par01)
	FmtLin({},aLay[28],,,@Li)		
	
	FmtLin({},aLay[17],,,@Li)
	FmtLin({TransForm(nTotal ,"@e 99,999,999.99"),TransForm(nTotDed ,"@e 99,999,999.99"),TransForm(nToBIss,"@e 99,999,999.99")},aLay[18],,,@Li)
	FmtLin({},aLay[19],,,@Li)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime quadro de resumo                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FmtLin({},aLay[22],,,@Li)	
	FmtLin({},aLay[22],,,@Li)	
	FmtLin({},aLay[23],,,@Li)
	FmtLin({},aLay[24],,,@Li)	
	FmtLin({TransForm(nToBIss ,"@e 99,999,999.99"),TransForm(nTotIss ,"@e 99,999,999.99")},aLay[25],,,@Li)		
 	FmtLin({},aLay[26],,,@Li)	
 	FmtLin({},aLay[27],,,@Li)	
Endif

If !lQuery
	RetIndex("SF3")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasSF3)
	dbCloseArea()
Endif
		
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Mr919Cabec³ Autor ³ Mary C. Hergert       ³ Data ³ 13.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o cabecalho do relatorio                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com o LayOut                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Mr919Cabec(nPagina,dDataImp)

Local li   := 0
Local aLay := RetLayOut()

Local cCCM        := mv_par05

Local nMV_ALIQISS := GetMv("MV_ALIQISS")

Local cMesIncid   := MesExtenso(Month(dDataImp))
Local cAno        := Ltrim(Str(Year(dDataImp)))

@ Li,000 PSAY AvalImp(Limite)

FmtLin({},aLay[01],,,@Li)
FmtLin({StrZero(nPagina,5)},aLay[02],,,@Li)
FmtLin({},aLay[03],,,@Li)
FmtLin({},aLay[04],,,@Li)
FmtLin({},aLay[05],,,@Li)
FmtLin({SM0->M0_NOMECOM,SM0->M0_ENDENT},aLay[06],,,@Li)
FmtLin({},aLay[05],,,@Li)
FmtLin({Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),SM0->M0_INSC,Iif(!Empty(cCCM),mv_par05," "),cMesIncid,cAno},aLay[07],,,@Li)
FmtLin({},aLay[05],,,@Li)
FmtLin({},aLay[08],,,@Li)
FmtLin({TransForm(nMV_ALIQISS,"@e 999.99")},aLay[09],,,@Li)
FmtLin({},aLay[10],,,@Li)
FmtLin({},aLay[11],,,@Li)
FmtLin({},aLay[12],,,@Li)
FmtLin({},aLay[13],,,@Li)
FmtLin({},aLay[14],,,@Li)

nPagina++

Return(li)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RetLayOut | Autor ³ Mary C. Hergert       ³ Data ³ 13.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o LayOut a ser impresso                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com o LayOut                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RetLayOut()

Local aLay := Array(40)

//
//                     1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
aLay[01] := "+---------------------------------------------------------------------------------------------------------------------------------+"
aLay[02] := STR0007 //"| REGISTRO DE SERVICOS PRESTADOS                                                                                     PAGINA ####  |"
aLay[03] := "|                                                                                                                                 |"
aLay[04] := STR0008 //"| IMPOSTO SOBRE SERVICOS                                                                                                          |"
aLay[05] := "|                                                                                                                                 |"
aLay[06] := STR0009 //"| ########################################                     Endereco: #############################                            |"
aLay[07] := STR0010 //"| C.N.P.J.: #################   Inscr. Est.: ###############   Inscr. Munic.: ###############        MES: ##########    ANO: #### |"
aLay[08] := "|=================================================================================================================================|" 
aLay[09] := STR0011 //"|                                                                                                           ALIQUOTA DE: ###### % |"
aLay[10] := "|---------+--------------------------------------------+------------------------+------------------------+------------------------|"
aLay[11] := STR0012 //"|         |          DOCUMENTOS COMPROBATORIOS         |                        |                        |                        |"
aLay[12] := STR0013 //"|   DIA   +----------------+-------------+-------------+         TOTAL          |        DEDUCOES        |   LIQUIDO TRIBUTAVEL   |"
aLay[13] := STR0014 //"|         |     NUMERO     |    SERIE    |   ESPECIE   |                        |                        |                        |"
aLay[14] := "|=========+================+=============+=============+========================+========================+========================|"
aLay[15] := "|   ##    |     ######     |     ###     |     ###     |    ################    |    ################    |    ################    |" 
aLay[16] := "|         |                |             |             |                        |                        |                        |"
aLay[17] := "|---------+----------------+-------------+-------------+------------------------+------------------------+------------------------|"
aLay[18] := STR0015 //"| TOTAL DO MES                                         |    ################    |    ################    |    #################   |"
aLay[19] := "+---------------------------------------------------------------------------------------------------------------------------------+"
aLay[20] := STR0016 //"| A TRANSPORTAR                                        |    ################    |    ################    |    #################   |"
aLay[21] := "+---------------------------------------------------------------------------------------------------------------------------------+"
aLay[22] := "                                                                                                                                   "
aLay[23] := STR0017 //"+====================================================  R E S U M O  ==============================================================+" 
aLay[24] := "|                                                                                                                                 |"
aLay[25] := STR0018 //"| A) SOMA MENSAL DO LIQUIDO TRIBUTAVEL:    R$ ################                             IMP.:     R$ ################          |"
aLay[26] := "|                                                                                                                                 |"
aLay[27] := "+=================================================================================================================================+"
aLay[28] := STR0019 //"| *** NAO HOUVE MOVIMENTACAO ***         |             |                        |                        |                        |" 
aLay[29] := STR0020 //"| B) ESTIMATIVA MENSAL................:    R$ ################                             IMP.:     R$ ################          |"
aLay[30] := STR0021 //"| C) TOTAL RECOLHIDO, DO MES, EM  ##########                                                         R$ ################          |"
aLay[31] := STR0022 //"| D) TOTAL RECOLHIDO EM ##########, POR INTIMACAO                                                                                 |"
aLay[32] := STR0023 //"|    OU ATO DE INFRACAO No. ##########                                                               R$ ################          |"
aLay[33] := "  _____/_____/_______                                  __________________________________________________________________________  "
aLay[34] := STR0024 //"                                                                               Assinatura do Responsavel                           "

Return(aLay)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Mtr919Str ºAutor  ³Mary Hergert        º Data ³  26/12/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar um array apenas com os campos utilizados na query    º±±
±±º          ³para passagem na funcao TCSETFIELD                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aCampos: campos a serem tratados na query                   º±±
±±º          ³cCmpQry: string contendo os campos para select na query     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Matr919                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Static Function Mtr919Str(aCampos,cCmpQry)
	Local	aRet	:=	{}
	Local	nX		:=	0
	Local	aTamSx3	:=	{}
	//
	For nX := 1 To Len(aCampos)
		If(FieldPos(aCampos[nX])>0)
			aTamSx3 := TamSX3(aCampos[nX])
			aAdd (aRet,{aCampos[nX],aTamSx3[3],aTamSx3[1],aTamSx3[2]})
			//
			cCmpQry	+=	aCampos[nX]+", "
		EndIf
	Next(nX)
	//
	If(Len(cCmpQry)>0)
		cCmpQry	:=	" " + SubStr(cCmpQry,1,Len(cCmpQry)-2) + " "
	EndIf
Return(aRet)
