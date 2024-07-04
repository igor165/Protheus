#INCLUDE "MATR948.CH" 
#INCLUDE "PROTHEUS.CH" 
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MATR948   ³ Autor ³ Mary C. Hergert       ³ Data ³17/02/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Livro ISS - Campinas - SP                      ³±±
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

Function MATR948()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define Variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local Titulo      := OemToAnsi(STR0001)  //"Impressao dos Livros de ISS de Campinas - SP"
Local cDesc1      := OemToAnsi(STR0002)  //"Este programa ira emitir o relatorio com as movimentações de ISSQN - "
Local cDesc2      := OemToAnsi(STR0003)  //"Campinas - SP, de acordo com os parametros configurados pelo usuario."
Local cDesc3      := OemToAnsi("")
Local cString     := "SF3"
Local lDic        := .F. 	// Habilita/Desabilita Dicionario
Local lComp       := .T. 	// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro     := .T. 	// Habilita/Desabilita o Filtro
Local wnrel       := "MATR948"  	// Nome do Arquivo utiLizado no Spool
Local nomeprog    := "MATR948"  	// nome do programa
Local nPagina     := 0
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

Private Tamanho := "G" // P/M/G
Private Limite  := 220 // 80/132/220
Private aOrdem  := {}  // Ordem do Relatorio
Private cPerg   := "MTR948"  // Pergunta do Relatorio
Private aReturn := { STR0004, 1,STR0005, 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"

Private lEnd    := .F.// Controle de cancelamento do relatorio
Private m_pag   := 1  // Contador de Paginas
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utiLizadas para parametros                            ³
//³ mv_par01 = Data Inicial											³
//³ mv_par02 = Data Final											³
//³ mv_par03 = Livro Selecionado									³
//³ mv_par04 = Modelo a ser impresso (1 - Saidas / 2 - Entradas)	³
//³ mv_par05 = Página inicial										³
//³ mv_par06 = Imprime (1 - Livro / 2 - Termos / 3 - Livro e Termos)³
//³ mv_par07 = Data Recol. (data em que o ISSQN sera recolhido)		³
//³ MV_PAR08 = Banco (banco onde o ISSQN sera recolhido)			³
//³ MV_PAR09 = Guia (numero da guia de recolhimento)				³
//³ MV_PAR10 = Observações do livro                                 ³       
//³ MV_PAR11 = Coluna Observações                                   ³       
//³ MV_PAR12 = Nro. Páginas                                         ³       
//³ MV_PAR13 = Cons. NF Cancelada                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lVerpesssen
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia para a SetPrint                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		Case MV_PAR06 == 3 
			lImpLivro  := .T. 
			lImpTermos := .T.
	EndCase    
																										
				
	If lImpLivro 
		RptStatus({|lEnd| nPagina := ImpDet(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)
	EndIf

	If lImpTermos
		Mtr948Term(cPerg,nPagina,mv_par04)
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IMPDET    ³ Autor ³ Mary C. Hergert       ³ Data ³17/02/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpDet()

Local aLay	    := {}
Local aDetail   := {}
Local aTotCod   := {}

Local cAliasSF3 := "SF3"
Local cArqInd   := ""
Local cInscr	:= ""
Local cCNPJ		:= ""
Local cIM		:= ""
Local cIndex	:= ""
Local cNumero	:= ""
Local cObs		:= ""         
Local cNome		:= ""
Local cMun		:= ""
Local cSerie	:= ""
Local cTipo		:= ""
Local cFiltroUsr:= aReturn[7]

Local dData		:= cToD("//")
Local lQuery    := .F.
Local lHouveMov := .F.
Local nValMat	:= 0
Local nValDoc	:= 0
Local nValSub	:= 0
Local nBase		:= 0
Local nISS 		:= 0
Local nModelo	:= mv_par04    
Local nIsentas	:= 0
Local nTotMat	:= 0
Local nTotSub	:= 0
Local nTIsentas	:= 0
Local nQtdLinha	:= 49
Local nX		:= 0
Local nTotal    := 0
Local nTotIss   := 0
Local nToBIss   := 0
Local nPagina   := mv_par05
Local nValRet	:= 0                                  
Local nRetISS	:= 0
Local Li        := 100                                               
Local nAliq		:= 0
Local nTamObs	:=	55
Local aDetObs	:=	{}
Local nI		:=	0


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
   	    aAdd(aCamposSF3,"F3_EMISSAO")
   	    aAdd(aCamposSF3,"F3_NFISCAL")
   	    aAdd(aCamposSF3,"F3_SERIE")
   	    If SerieNfId("SF3",3,"F3_SERIE")<>"F3_SERIE"
   	    	aAdd(aCamposSF3,"F3_SDOC")
   	    Endif	
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
   	    aAdd(aCamposSF3,"F3_RECISS")                     
   	    aAdd(aCamposSF3,"F3_ISSSUB")                 
   	    aAdd(aCamposSF3,"F3_DTCANC")
		aAdd(aCamposSF3,"F3_CODISS")
		aAdd(aCamposSF3,"F3_NRLIVRO")
		aAdd(aCamposSF3,"F3_OBSERV")		
		aAdd(aCamposSF3,"F3_FORMULA")
		aAdd(aCamposSF3,"F3_ISSMAT")
		
    	//
    	aStruSF3  := SF3->(MTR948Str(aCamposSF3,@cCmpQry))
    	SF3->(dbCloseArea())

		lQuery    := .T.
		cAliasSF3 := "SF3"
		
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
		cQuery    += "F3_EMISSAO >= '" + Dtos(mv_par01) + "' AND "
		cQuery    += "F3_EMISSAO <= '" + Dtos(mv_par02) + "' AND "
		cQuery    += "(F3_TIPO IN ('S','N',' ') OR "
		cQuery    += "(F3_TIPO = 'L' AND F3_CODISS <> '')) "

		If mv_par03<>"*"
			cQuery	+=	" AND F3_NRLIVRO='"+mv_par03+"' "
		EndIf

		If MV_PAR13==2 
			cQuery    += "AND F3_DTCANC = '' "
			cQuery    += " AND F3_OBSERV NOT LIKE '%CANCELAD%' "
		EndIf
		
		cQuery    += " AND SF3.D_E_L_E_T_ = ' ' "
		cQuery    += "ORDER BY F3_EMISSAO,F3_SERIE,F3_NFISCAL,F3_TIPO,F3_CLIEFOR,F3_LOJA"
	
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
		cChave	:=	"DTOS(F3_EMISSAO)+F3_SERIE+F3_NFISCAL+F3_TIPO+F3_CLIEFOR+F3_LOJA"
		cFiltro :=  "F3_FILIAL == '" + xFilial("SF3") + "' .AND. 
		If nModelo == 1
			cFiltro :=  "F3_CFO >= '5" + Space(Len(F3_CFO)-1) + "' .And."
		Else                                                              
			cFiltro :=  "F3_CFO < '5" + Space(Len(F3_CFO)-1) + "' .And."
		Endif
		cFiltro	+=	"DtoS(F3_EMISSAO) >= '" + DtoS(mv_par01) + "' .And. DtoS(F3_EMISSAO) <= '" + DtoS(mv_par02) + "' .And. "
		cFiltro	+=	"(F3_TIPO $ ' SN' .Or. "
		cFiltro	+=	"(F3_TIPO = 'L' .And. !EMPTY(F3_CODISS))) "

		If MV_PAR13==2
			cFiltro +=  " .And. Empty(F3_DTCANC) .And. !('CANCELAD'$F3_OBSERV) "
		EndIf
		
		If mv_par03<>"*"
			cFiltro	+=	" .And. F3_NRLIVRO=='"+mv_par03+"'"
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

// Layout
aLay := RetLayout(nModelo)

dbSelectArea(cAliasSF3)
SetRegua(LastRec())
(cAliasSF3)->(DbGoTop())

While (cAliasSF3)->(!Eof())                  

	nMes := Month((cAliasSF3)->F3_EMISSAO)

    dDataImp := (cAliasSF3)->F3_EMISSAO
	Mr948Cabec(@nPagina,(cAliasSF3)->F3_EMISSAO,@Li,nModelo)
	aTotCod  := {}
	nTotal   := 0
	nTotIss  := 0
	nToBIss  := 0
	nTotMat  := 0
	nTotSub  := 0
	nTIsentas:= 0

	While (cAliasSF3)->(!Eof()) .And. Month((cAliasSF3)->F3_EMISSAO) == nMes

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
		
		If (cAliasSF3)->F3_TIPO == 'N'
			If Empty((cAliasSF3)->F3_ISSSUB)
				(cAliasSF3)->(dbSkip())
				Loop
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o cLiente/fornecedor do documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValRet := 0
		nRetISS := 0
		If Left((cAliasSF3)->F3_CFO,1) $ "123"
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			cInscr	:= SA2->A2_INSCR
			cCNPJ	:= SA2->A2_CGC
			cIM		:= SA2->A2_INSCRM
			cNome	:= SA2->A2_NOME
			cMun	:= SA2->A2_MUN
			If SA2->A2_RECISS$"S1"
				nValRet	+= Iif(Empty(F3_DTCANC),(cAliasSF3)->F3_BASEICM ,0)
				nRetISS	+= Iif(Empty(F3_DTCANC),(cAliasSF3)->F3_VALICM,0)
			Endif
		Else
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			cInscr	:= SA1->A1_INSCR
			cCNPJ	:= SA1->A1_CGC
			cIM		:= SA1->A1_INSCRM
			cNome	:= SA1->A1_NOME
			cMun	:= SA1->A1_MUN
			If SA1->A1_RECISS$"S1"                
				nValRet += Iif(Empty(F3_DTCANC),(cAliasSF3)->F3_BASEICM,0)
				nRetISS += Iif(Empty(F3_DTCANC),(cAliasSF3)->F3_VALICM,0)
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisa o ISS Retido pelo SF3³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValRet := 0
		nRetISS := 0
		If (cAliasSF3)->F3_RECISS$"S1"
			nValRet += Iif(Empty(F3_DTCANC),(cAliasSF3)->F3_BASEICM,0)
			nRetISS += Iif(Empty(F3_DTCANC),(cAliasSF3)->F3_VALICM,0)
		Endif                             
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisa ISS Subempreitada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValSub += Iif(Empty(F3_DTCANC),(cAliasSF3)->F3_ISSSUB,0)                      
		
		nValDoc	+= Iif(Empty(F3_DTCANC),(cAliasSF3)->F3_VALCONT,0)
		cIndex 	:= xFilial("SF3")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
		cTipo	:= (cAliasSF3)->F3_TIPO
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso tenha mais de um SF3 (codigo de ISS diferente) e/ou produtos na nota fiscal, ³
		//³ira acumular para apresentar apenas uma Linha                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSF3)->F3_TIPO $ " N"
			nValMat += Iif(Empty(F3_DTCANC),(cAliasSF3)->F3_VALCONT,0)
			(cAliasSF3)->(dbSkip())
			If cIndex <> xFilial("SF3")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Zera as variaveis de impressao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nValDoc		:= 0
				nValMat		:= 0
				nValSub		:= 0
				nBase		:= 0
				nALiq		:= 0
				nISS		:= 0
				nRetISS		:= 0
				nIsentas	:= 0
			Endif
			Loop
		Else
			nValMat += Iif(Empty(F3_DTCANC),(cAliasSF3)->F3_ISSMAT,0)	
			nBase	+= Iif(Empty(F3_DTCANC),(cAliasSF3)->F3_BASEICM,0)
			nISS	+= Iif(Empty(F3_DTCANC),(cAliasSF3)->F3_VALICM,0)
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Informacoes que serao impressas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dData	:= (cAliasSF3)->F3_EMISSAO
		cNumero	:= (cAliasSF3)->F3_NFISCAL 
		nAliq	:= Iif(Empty(F3_DTCANC),(cAliasSF3)->F3_ALIQICM,0)
		cSerie	:= (cAliasSF3)->&(SerieNfId("SF3",3,"F3_SERIE"))     
		nIsentas:= Iif(Empty(F3_DTCANC),(cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM,0)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Composicao da coluna observacoes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MV_PAR11 == 1
			cObs	:=  Iif(!Empty((cAliasSF3)->F3_FORMULA),Formula((cAliasSF3)->F3_FORMULA),(cAliasSF3)->F3_OBSERV)
		ElseIf MV_PAR11 == 2
			cObs	:= cNome
		Else                
			cObs	:= cMun
		Endif
		
		If nValRet > 0
			cObs := Iif(!Empty(cObs),Alltrim(cObs) + " - ISS Retido","ISS Retido")
		Endif
		
		If !Empty(F3_DTCANC)
			cObs := Iif(!Empty(cObs),Iif(Alltrim(cObs)$"NF CANCELADA",Alltrim(cObs),Alltrim(cObs) + " - NF CANCELADA"),"NF CANCELADA")
		EndIf
		cObs	:=	Iif(cObs==Nil, "", cObs)
		
		(cAliasSF3)->(dbSkip())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se alterou a chave, imprime o registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cIndex <> xFilial("SF3")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA .Or.;
			(nALiq <> (cAliasSF3)->F3_ALIQICM .And. cTipo == "S") .Or. (cAliasSF3)->(Eof())
		
			cIndex := xFilial("SF3")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA

			lHouveMov := .T.             
			
			If nModelo == 1
			
				aDetail := {cNumero,;
							cSerie,;	
							StrZero(Day(dData),2),;
							TransForm(nValDoc,"@E 99,999,999.99"),;
							TransForm(nValMat,"@E 99,999,999.99"),;
							TransForm(nValSub,"@E 99,999,999.99"),;
							TransForm(nBase,"@E 99,999,999.99"),;
							TransForm(nALiq,"@E 999.99"),;
							TransForm(nISS-nRetISS,"@E 99,999,999.99"),;
							TransForm(nIsentas,"@E 99,999,999.99"),;
							Iif(MlCount(cObs,nTamObs)>1,MemoLine(cObs,nTamObs,1),cObs)}
				FmtLin(aDetail,aLay[15],,,@Li)
				For nI := 2 To MlCount(cObs,nTamObs)
					aDetObs := {"",;
								"",;	
								"",;
								"",;
								"",;
								"",;
								"",;
								"",;
								"",;
								"",;
								MemoLine(cObs,nTamObs,nI)}
					FmtLin(aDetObs,aLay[15],,,@Li)
				Next nI
			Else
				aDetail := {cIM,;
							cCNPJ,;
							dToC(dData),;
							cNumero,;
							TransForm(nValDoc,"@E 99,999,999.99"),;
							TransForm(nValMat,"@E 99,999,999.99"),;
							TransForm(nValSub,"@E 99,999,999.99"),;
							TransForm(nBase,"@E 99,999,999.99"),;
							TransForm(nALiq,"@E 999.99"),;
							TransForm(nISS-nRetISS,"@E 99,999,999.99")}
					
				FmtLin(aDetail,aLay[14],,,@Li)
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Acumula total                                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotal   += nValDoc
			nTotIss  += nISS - nRetISS
			nToBIss  += nBase
			nTotMat  += nValMat
			nTotSub  += nValSub                   
			nTIsentas+= nIsentas
			    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao for fim de arquivo salta pagina com saldo a transportar          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(cAliasSF3)->(Eof()) .And. ( Li > 55 ) .And. Month((cAliasSF3)->F3_EMISSAO) == nMes
				If nModelo == 1
					FmtLin({},aLay[16],,,@Li)
					aDetail := {TransForm(nTotal,"@E 99,999,999.99"),;
								TransForm(nTotMat,"@E 99,999,999.99"),;
								TransForm(nTotSub,"@E 99,999,999.99"),;
								TransForm(nToBIss,"@E 99,999,999.99"),;
								TransForm(nTotISS,"@E 99,999,999.99"),;
								TransForm(nTIsentas,"@E 99,999,999.99")}
					FmtLin(aDetail,aLay[17],,,@Li)
					FmtLin({},aLay[31],,,@Li)			                             
				Else
					FmtLin({},aLay[19],,,@Li)
					aDetail := {TransForm(nTotal,"@E 99,999,999.99"),;
								TransForm(nTotMat,"@E 99,999,999.99"),;
								TransForm(nTotSub,"@E 99,999,999.99"),;
								TransForm(nToBIss,"@E 99,999,999.99"),;
								TransForm(nTotISS,"@E 99,999,999.99")}
					FmtLin(aDetail,aLay[20],,,@Li)
					FmtLin({},aLay[34],,,@Li)			                             
				Endif 
				Mr948Cabec(@nPagina,(cAliasSF3)->F3_EMISSAO,@Li,nModelo)
			Endif	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Zera as variaveis de impressao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValDoc		:= 0
			nValMat		:= 0
			nValSub		:= 0
			nBase		:= 0
			nALiq		:= 0
			nISS		:= 0
			nRetISS		:= 0
			nIsentas	:= 0
		Endif
	EndDo	                                     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Completa o preenchimento da pagina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := Li to nQtdLinha          
		If nModelo == 1
			FmtLin({},aLay[32],,,@Li)	
		Else                            
			FmtLin({},aLay[35],,,@Li)	
		Endif
	Next

	Mtr948Tot(nModelo,Li,nTotal,nTotMat,nTotSub,nToBISS,nTotISS,nTIsentas,lHouveMov)
EndDo

If !lHouveMov

	Mr948Cabec(@nPagina,mv_par01,@Li,nModelo)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Completa o preenchimento da pagina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := Li to nQtdLinha          
		If nModelo == 1
			FmtLin({},aLay[32],,,@Li)	
		Else                            
			FmtLin({},aLay[35],,,@Li)	
		Endif
	Next

	Mtr948Tot(nModelo,Li,nTotal,nTotMat,nTotSub,nToBISS,nTotISS,nTIsentas,lHouveMov)
Endif

If !lQuery
	RetIndex("SF3")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasSF3)
	dbCloseArea()
Endif
		
Return(nPagina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Mr948Cabec³ Autor ³ Mary C. Hergert       ³ Data ³17/02/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o cabecalho do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPagina  = Numero da Pagina a ser Impressa                  ³±±
±±³          ³dDataImp = Mes que esta sendo impresso                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mr948Cabec(nPagina,dDataImp,Li,nModelo)

Local aLay 			:= RetLayOut(nModelo)
Local cIM			:= SM0->M0_INSCM
Local cMesIncid		:= MesExtenso(Month(dDataImp))
Local cAno			:= Ltrim(Str(Year(dDataImp)))

Li := 0

@ Li,000 PSAY AvalImp(Limite)

If nModelo == 1
	FmtLin({},aLay[01],,,@Li)
	FmtLin({},aLay[05],,,@Li)
	FmtLin({StrZero(nPagina,4)},aLay[02],,,@Li)
	FmtLin({cMesIncid,cAno},aLay[03],,,@Li)
	FmtLin({SM0->M0_NOMECOM,Substr(SM0->M0_ENDENT,1,29),Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),SM0->M0_INSC,Iif(!Empty(cIM),cIM," ")},aLay[04],,,@Li)
	FmtLin({},aLay[05],,,@Li)
	FmtLin({},aLay[06],,,@Li)
	FmtLin({},aLay[07],,,@Li)
	FmtLin({},aLay[08],,,@Li)
	FmtLin({},aLay[09],,,@Li)	
	FmtLin({},aLay[10],,,@Li)
	FmtLin({},aLay[11],,,@Li)
	FmtLin({},aLay[12],,,@Li)
	FmtLin({},aLay[13],,,@Li)
	FmtLin({},aLay[14],,,@Li)
Else
	FmtLin({},aLay[01],,,@Li)
	FmtLin({},aLay[05],,,@Li)
	FmtLin({StrZero(nPagina,4)},aLay[02],,,@Li)
	FmtLin({cMesIncid,cAno},aLay[03],,,@Li)
	FmtLin({SM0->M0_NOMECOM,Substr(SM0->M0_ENDENT,1,29),Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),SM0->M0_INSC,Iif(!Empty(cIM),cIM," ")},aLay[04],,,@Li)
	FmtLin({},aLay[05],,,@Li)
	FmtLin({},aLay[06],,,@Li)
	FmtLin({},aLay[07],,,@Li)
	FmtLin({},aLay[08],,,@Li)
	FmtLin({},aLay[09],,,@Li)	
	FmtLin({},aLay[10],,,@Li)
	FmtLin({},aLay[11],,,@Li)
	FmtLin({},aLay[12],,,@Li)
	FmtLin({},aLay[13],,,@Li)
Endif                

nPagina += 1
	
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RetLayOut | Autor ³ Mary C. Hergert       ³ Data ³17/02/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o LayOut a ser impresso                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com o LayOut                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum             	                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetLayOut(nModelo)

Local aLay := Array(40)

If nModelo == 1
	aLay[01] := "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[02] := STR0007 //"|                                                            REGISTRO DE NOTAS FISCAIS DE SERVICOS DO IMPOSTO SOBRE SERVICOS DE QUALQUER NATUREZA                                                               FOLHA #### |"
	aLay[03] := STR0008 //"|                                                                                                                                                                                COMPETENCIA:  MES ############   ANO #### |"
	aLay[04] := STR0009 //"| ########################################    Endereco : #############################    CNPJ : #################    I.E. : ###############    Inscricao Municipal : ##################                                   |"
	aLay[05] := "|                                                                                                                                                                                                                          |"
	aLay[06] := "|==========================================================================================================================================================================================================================|"
	aLay[07] := STR0010 //"|                      |                                                                                                                   |  OPERACOES IMUNES  |                                                          |"
	aLay[08] := STR0011 //"|      NOTA FISCAL     |                                               OPERACOES TRIBUTADAS                                                |     OU ISENTAS     |                                                          |"
	aLay[09] := "|-------------------------+-------------------------------------------------------------------------------------------------------------------+--------------------|                                                       |"
	aLay[10] := STR0012 //"|        |       |     |                    |             DEDUCOES LEGAIS             |                    |          |                    |                    |                       OBSERVACOES                        |"
	aLay[11] := STR0013 //"|        |       |     |   VALOR TOTAL DA   +--------------------+--------------------+                    | ALiQUOTA |      IMPOSTO       |                    |                                                          |"
	aLay[12] := STR0014 //"| NUMERO | SERIE | DIA |     NOTA FISCAL    |      VALOR DO      |      VALOR DA      |  BASE DE CALCULO   |    %     |       DEVIDO       |       VALOR        |                                                          |"
	aLay[13] := STR0015 //"|        |       |     |                    |      MATERIAL      |    SUBEMPREITADA   |                    |          |                    |                    |                                                          |"
	aLay[14] := "|===========+=======+=====+====================+====================+====================+====================+==========+====================+====================+=======================================================|"
	aLay[15] := "| ######### |  ###  | ##  |  ################  |  ################  |  ################  |  ################  |  ######  |  ################  |  ################  |  #################################################### |"
	aLay[16] := "|-------------------------+--------------------+--------------------+--------------------+--------------------+----------+--------------------+--------------------+-------------------------------------------------------|"
	aLay[17] := STR0016 //"|    A TRANSPORTAR     |  ################  |  ################  |  ################  |  ################  |          |  ################  |  ################  |                                                          |"
	aLay[18] := "|-------------------------+--------------------+--------------------+--------------------+--------------------+----------+--------------------+--------------------+----------------------------------------------------------|"
	aLay[19] := STR0017 //"|     TOTAL DO MES     |  ################  |  ################  |  ################  |  ################  |          |  ################  |  ################  |                                                          |"
	aLay[20] := "|-------------------------+----------------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------|"
	aLay[21] := STR0018 //"|                      |                                              INFORMACOES SOBRE O RECOLHIMENTO DO IMPOSTO                                               |                                                          |"
	aLay[22] := "|                      |----------------------------------------------------------------------------------------------------------------------------------------|                                                          |"
	aLay[23] := STR0019 //"|                      |                        |      DATA DO      |                                                  |                                        |                                                          |"
	aLay[24] := STR0020 //"|                      |     IMPOSTO DEVIDO     |    RECOLHIMENTO   |                      BANCO                       |          NUMERO DO DOCUMENTO           |                                                          |"
	aLay[25] := "|                      |------------------------+-------------------+--------------------------------------------------+----------------------------------------|                                                          |"
	aLay[26] := "|                      |      ################  |      ########     | ################################################ | ###################################### |                                                          |"   
	aLay[27] := "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	aLay[28] := STR0021 //"| OBSERVACOES: ########################################################################################################################################################################################################### |"
	aLay[29] := "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	aLay[30] := "|                                                                                                                                                                                                                          |"
	aLay[31] := "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"			
	aLay[32] := "|           |       |     |                    |                    |                    |                    |          |                    |                    |                                                       |"
	aLay[33] := STR0022 //"|                          *** NAO HOUVE MOVIMENTACAO ***                             |                    |          |                    |                    |                                                          |"        
Else     
	aLay[01] := "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[02] := STR0023 //"|                                                                                       REGISTRO DE SERVICOS TOMADOS                                                                                            FOLHA #### |"
	aLay[03] := STR0024 //"|                                                                                                                                                                                COMPETENCIA:  MES ############   ANO #### |"
	aLay[04] := STR0025 //"| ########################################    Endereco : #############################    CNPJ : #################    I.E. : ###############    Inscricao Municipal : ##################                                   |"
	aLay[05] := "|                                                                                                                                                                                                                          |"            
	aLay[06] := "|==========================================================================================================================================================================================================================|"
	aLay[07] := STR0026 //"|                   PRESTADOR DO SERVICO                  |           NOTA FISCAL           |                                                     OPERACOES TRIBUTADAS                                                     |"
	aLay[08] := "|---------------------------------------------------------+---------------------------------+------------------------------------------------------------------------------------------------------------------------------|"	
	aLay[09] := STR0027 //"|                            |                            |                  |              |                      |                DEDUCOES LEGAIS              |                      |          |                       |"
	aLay[10] := STR0028 //"|         INSCRICAO          |                            |                  |              |      VALOR DA        |----------------------+----------------------|                      | ALiQUOTA |        IMPOSTO        |"
	aLay[11] := STR0029 //"|         MUNICIPAL          |            CNPJ            |       DATA       |    NUMERO    |     NOTA FISCAL      |       VALOR DO       |       VALOR DA       |    BASE DE CALCULO   |    %     |        DEVIDO         |"
	aLay[12] := STR0030 //"|                            |                            |                  |              |                      |       MATERIAL       |     SUBEMPREITADA    |                      |          |                       |"
	aLay[13] := "|----------------------------+----------------------------+------------------+--------------+----------------------+----------------------+----------------------+----------------------+----------+-----------------------|"
	aLay[14] := "|     ##################     |     ##################     |     ########     |    ######    |     ################ |     ################ |     ################ |     ################ |  ######  |      ################ |"    
	aLay[15] := "|----------------------------+----------------------------+------------------+--------------+----------------------+----------------------+----------------------+----------------------+----------+-----------------------|"
	aLay[16] := STR0031 //"|                             *** NAO HOUVE MOVIMENTACAO ***                                |                      |                      |                      |                      |          |                       |"
	aLay[17] := "|----------------------------+----------------------------+---------------------------------+----------------------+----------------------+----------------------+----------------------+----------+-----------------------|"
	aLay[18] := STR0032 //"|                            |                            |           TOTAL DO MES          |     ################ |     ################ |     ################ |     ################ |          |      ################ |"    
	aLay[19] := "|----------------------------+----------------------------+---------------------------------+----------------------+----------------------+----------------------+----------------------+----------+-----------------------|"
	aLay[20] := STR0033 //"|                            |                            |       TOTAL A TRANSPORTAR       |     ################ |     ################ |     ################ |     ################ |          |      ################ |"    
	aLay[21] := "|-------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------|"
	aLay[22] := STR0034 //"|                                                                                           |                                         INFORMACOES SOBRE O RECOLHIMENTO DO IMPOSTO                                          |"
	aLay[23] := "|                                                                                           |------------------------------------------------------------------------------------------------------------------------------|"
	aLay[24] := STR0035 //"|                                                                                           |                        |      DATA DO      |                                          |                                      |"
	aLay[25] := STR0036 //"|                                                                                           |     IMPOSTO DEVIDO     |   RECOLHIMENTO    |                  BANCO                   |          NUMERO DO DOCUMENTO         |"
	aLay[26] := "|                                                                                           |------------------------+-------------------+------------------------------------------+--------------------------------------|"
	aLay[27] := "|                                                                                           |      ################  |     ########      | ######################################## | #################################### |"
	aLay[28] := "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	aLay[29] := STR0037 //"| OBSERVACOES: ########################################################################################################################################################################################################### |"
	aLay[30] := "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	aLay[31] := "|                                                                                                                                                                                                                          |"   
	aLay[32] := "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	aLay[33] := "|                                                                                                                                                                                                                          |"   
	aLay[34] := "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[35] := "|                            |                            |                  |              |                      |                      |                      |                      |          |                       |"
Endif     

Return(aLay)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Mtr948Tot ºAutor  ³Mary C. Hergert     º Data ³ 17/02/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime totais do relatorio                                 º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³Nenhum                                                      º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³nModelo   = Modelo a ser impresso (1 Saidas ou 3 Entradas)  º±±
±±º          ³Li        = Numero da linha que sera impressa               º±±
±±º          ³nTotal    = Valor total do documento fiscal                 º±±
±±º          ³nTotMat   = Total referente a produtos no documento         º±±
±±º          ³nToSub    = Total referente a subempreitada                 º±±
±±º          ³nToBISS   = Total da base de iss                            º±±
±±º          ³nTotISS   = Total do iss                                    º±±
±±º          ³nTIsentas = Total de isentas                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mtr948Tot(nModelo,Li,nTotal,nTotMat,nTotSub,nToBISS,nTotISS,nTIsentas,lHouveMov)

Local aLay 		:= RetLayout(nModelo)                                  
Local aDetail 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime total                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModelo == 1
	FmtLin({},aLay[18],,,@Li)
	aDetail := {TransForm(nTotal,"@E 99,999,999.99"),;
				TransForm(nTotMat,"@E 99,999,999.99"),;
				TransForm(nTotSub,"@E 99,999,999.99"),;
				TransForm(nToBIss,"@E 99,999,999.99"),;
				TransForm(nTotISS,"@E 99,999,999.99"),;
				TransForm(nTIsentas,"@E 99,999,999.99")}
	FmtLin(aDetail,aLay[19],,,@Li)
	FmtLin({},aLay[20],,,@Li)			                             
Else
	FmtLin({},aLay[17],,,@Li)
	aDetail := {TransForm(nTotal,"@E 99,999,999.99"),;
				TransForm(nTotMat,"@E 99,999,999.99"),;
				TransForm(nTotSub,"@E 99,999,999.99"),;
				TransForm(nToBIss,"@E 99,999,999.99"),;
				TransForm(nTotISS,"@E 99,999,999.99")}
	FmtLin(aDetail,aLay[18],,,@Li)
	FmtLin({},aLay[21],,,@Li)			                             
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime quadro de resumo                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModelo == 1               
	FmtLin({},aLay[21],,,@Li)
	FmtLin({},aLay[22],,,@Li)
	FmtLin({},aLay[23],,,@Li)
	FmtLin({},aLay[24],,,@Li)
	FmtLin({},aLay[25],,,@Li)
	FmtLin({TransForm(nTotIss,"@E 99,999,999.99"),dToC(MV_PAR07),MV_PAR08,MV_PAR09},aLay[26],,,@Li)
	FmtLin({},aLay[27],,,@Li)
	If lHouveMov
		FmtLin({MV_PAR10},aLay[28],,,@Li)
	Else
		FmtLin({STR0038},aLay[28],,,@Li)
	Endif
	FmtLin({},aLay[29],,,@Li)
	FmtLin({},aLay[30],,,@Li)
	FmtLin({},aLay[31],,,@Li)
Else                          
	FmtLin({},aLay[22],,,@Li)
	FmtLin({},aLay[23],,,@Li)
	FmtLin({},aLay[24],,,@Li)
	FmtLin({},aLay[25],,,@Li)
	FmtLin({},aLay[26],,,@Li)
	FmtLin({TransForm(nTotIss,"@E 99,999,999.99"),dToC(MV_PAR07),MV_PAR08,MV_PAR09},aLay[27],,,@Li)
	FmtLin({},aLay[28],,,@Li)
	If lHouveMov
		FmtLin({MV_PAR10},aLay[29],,,@Li)
	Else
		FmtLin({STR0038},aLay[29],,,@Li)
	Endif
	FmtLin({},aLay[30],,,@Li)
	FmtLin({},aLay[31],,,@Li)
	FmtLin({},aLay[32],,,@Li)
	FmtLin({},aLay[33],,,@Li)
	FmtLin({},aLay[34],,,@Li)
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTR948Str ºAutor  ³Mary Hergert        º Data ³  26/12/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar um array apenas com os campos utiLizados na query    º±±
±±º          ³para passagem na funcao TCSETFIELD                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aCampos: campos a serem tratados na query                   º±±
±±º          ³cCmpQry: string contendo os campos para select na query     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR948                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
#IFDEF TOP
Static Function MTR948Str(aCampos,cCmpQry)

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
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mtr948Term  ³ Autor ³ Mary C. Hergert    ³ Data ³17/02/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime termos de Abertura e Encerramento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Matr948                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Mtr948Term(cPerg,nPagina,nModelo)

Local cArqAbert	:= GetNewPar("MV_ABR948","")
Local cArqEncer	:= GetNewPar("MV_ENC948","")
Local aDriver 	:= ReadDriver()
Local aDados    := {}

AADD(aDados,{"D_I_A",Day(dDatabase)})
AADD(aDados,{"M_E_S",Alltrim(MesExtenso(Month(dDatabase)))})
AADD(aDados,{"A_N_O",Year(dDatabase)})
AADD(aDados,{"P_A_G",nPagina-1})

If nModelo == 1
	AADD(aDados,{"M_O_D","Modelo 1"})
	AADD(aDados,{"R_E_G","REGISTRO DE NOTAS FISCAIS"})
Else
	AADD(aDados,{"M_O_D","Modelo 3"})
	AADD(aDados,{"R_E_G","REGISTRO DE SERVICOS TOMADOS"})
Endif

If !Empty(cArqAbert) .And. !Empty(cArqEncer)
	TERMGO(cArqAbert,cArqEncer,cPerg,aDriver[4],aDados)
Endif

Return .T.
