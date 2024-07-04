#INCLUDE "MATR912.ch" 
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MATR912   ³ Autor ³ Henry Fila            ³ Data ³ 06.10.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio de ISS de Entrada Mod. 56            ³±±
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

Function MATR912()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define Variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea	  := GetArea()
Local Titulo  := OemToAnsi(STR0001)  //"Impressao do Registro de Entradas com ISS"
Local cDesc1  := OemToAnsi(STR0002 ) //"     Este programa ira emitir o relatorio de entradas com ISS "
Local cDesc2  := OemToAnsi(STR0003) //"de acordo com os parametros configurados pelo usuario"
Local cDesc3  := OemToAnsi("")
Local cString := "SF3"
Local lDic    := .F. 	// Habilita/Desabilita Dicionario
Local lComp   := .F. 	// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro := .T. 	// Habilita/Desabilita o Filtro
Local wnrel   := "MATR912"  	// Nome do Arquivo utilizado no Spool
Local nomeprog:= "MATR912"  	// nome do programa
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para Gestão Corporativa                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
Local nPosFil		:= 0
Local nForFilial	:= 0
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
Private aDados  	:= {}
Private aDriver 	:= ReadDriver()
Private lAglFil		:= .F.
Private lSelFil		:= .F.   
Private aFilsCalc	:= {}
Private aFilAtiv	:= {}
Private cFilSF1		:= ''
Private cFilSF3		:= ''
Private cFilBack	:= cFilAnt
Private cArqAbert	:=	GetNewPar("MV_MTR912A","")
Private cArqEncer	:=	GetNewPar("MV_MTR912E","")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variáveis para impressões                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
Private Tamanho := "G" // P/M/G
Private Limite  := 220 // 80/132/220
Private aOrdem  := {}  // Ordem do Relatorio
Private cPerg   := "MTR912"  // Pergunta do Relatorio
Private aReturn := { STR0004, 1,STR0005, 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"

Private lEnd    := .F.// Controle de cancelamento do relatorio
Private m_pag   := 1  // Contador de Paginas
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault

If lVerpesssen
	// Variaveis para impressão no termo
	AADD(aDados,{"D_I_A",Day(dDatabase)})
	AADD(aDados,{"M_E_S",MesExtenso(Month(dDatabase))})
	AADD(aDados,{"A_N_O",Year(dDatabase)})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia para a SetPrinter                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)
	If ( nLastKey==27 )
		dbSelectArea('SF3')
		dbSetOrder(1)
		dbClearFilter()
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao de Termo / Livro                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case mv_par08==1
			lImpLivro:=.T.
			lImpTermos:=.F.
		Case mv_par08==2
			lImpLivro:=.F.
			lImpTermos:=.T.
		Case mv_par08==3
			lImpLivro:=.T.
			lImpTermos:=.T.
	EndCase

	nPagina	:=	IIF(mv_par04<2, 2, mv_par04)

	If nLastKey==27
		dbClearFilter()
		cFilAnt	:= cFilBack
		Return
	EndIf

	SetDefault(aReturn,cString)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recebe filtro definido pelo usuario                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilterUser	:=	aReturn[7]

	// Variáveis para gestão corporativa 
	lSelFil		:= ( mv_par06 == 1 ) 
	lAglFil		:= ( mv_par10 == 1 )  
	aFilsCalc	:= MatFilCalc( lSelFil, , , (lSelFil .and. lAglFil), , 4 )

	If Empty(aFilsCalc)
		cFilAnt	:= cFilBack
		Return
	EndIf

	// Se Seleciona Filiais, guarda as filiais dos arquivos para uso posterior
	If lSelFil
		For nForFilial := 1 to Len( aFilsCalc )
			If aFilsCalc[ nForFilial, 1 ]
				cFilAnt := aFilsCalc[ nForFilial, 2 ]
				aAdd( aFilAtiv, { cFilAnt, xFilial('SF3'), xFilial('SF1'), xFilial('SA1'), xFilial('SA2') } )
			EndIf
		Next

		// Se aglutina filiais, monta a string conforme as filiais de cada tabela envolvida
			cFilAnt	:= aFilAtiv[1,1]
			For nPosFil := 1 to Len(aFilAtiv)
				cFilSF1	+= IIf(nPosFil==1,"('","'")+aFilAtiv[nPosFil,3]+IIf(nPosFil==Len(aFilAtiv),"')","',")	
				cFilSF3	+= IIf(nPosFil==1,"('","'")+aFilAtiv[nPosFil,2]+IIf(nPosFil==Len(aFilAtiv),"')","',")
			Next

	// Se não seleciona Filiais, não irá aglutinar CNPJ
	Else
		aAdd( aFilAtiv, { cFilAnt, xFilial('SF3'), xFilial('SF1'), xFilial('SA1'), xFilial('SA2') } )
		cFilSF1	:= "('"+aFilAtiv[1,3]+"')"
		cFilSF3	:= "('"+aFilAtiv[1,2]+"')" 
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa relatorio                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lImpLivro
		RptStatus( { |lEnd| ImpDet( @lEnd, wnRel, cString, nomeprog, Titulo ) }, Titulo )
		
	ElseIf lImpTermos .and. !lImpLivro	// Impressao somente dos Termos
		If !lAglFil
			SM0->(dbSetOrder(1))
			For nForFilial := 1 to Len(aFilAtiv)
				cFilAnt	:= aFilAtiv[nForFilial,1]
				SM0->(dbSeek(cEmpAnt+cFilAnt))
				TERMGO(cArqAbert,cArqEncer,cPerg,aDriver[4],aDados)
			Next	
		Else
			TERMGO(cArqAbert,cArqEncer,cPerg,aDriver[4],aDados)
		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura Ambiente                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SF3')
	dbClearFilter()
	Set Device To Screen
	Set Printer To

	If ( aReturn[5] = 1 )
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
±±³Programa  ³IMPDET    ³ Autor ³ Henry Fila            ³ Data ³ 24.03.03 ³±±
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

Local aLay	    	:= RetLayOut()
Local aStruSF3  	:= SF3->(dbStruct())
Local aDetail   	:= {}
Local aTotCod   	:= {}

Local cQuery  	  	:= ""
Local cAliasSF3	 	:= "SF3"
Local cArqInd  	 	:= ""
Local cChave   	 	:= ""
Local cFiltro  	 	:= ""       
Local cMun     	 	:= ""
Local cCampo   	 	:= ""
Local cAliasB   	:= ""
Local cFilterUser 	:= aReturn[7]
Local cCidade		:= Alltrim(GetNewPar("MV_CIDADE",""))                                                                                   

Local nTotal    	:= 0
Local nTotIss   	:= 0
Local nToBIss   	:= 0
Local nAliqIss  	:= 0
Local nPagina   	:= IIF(mv_par04<2, 2, mv_par04)
Local nQtdLinha 	:= 55
Local nPosAliq  	:= 0
Local nValDoc   	:= 0
Local li        	:= 100

Local lQuery    	:= .F.
Local lHouveMov 	:= .F.
Local lImprime  	:= .T.

Local nX			:= 0
Local dDataRec		:= Ctod("//")
Local dDataComp 	:= Ctod("//")
Local nValRec		:= 0

Local nIssRet		:=	0
Local cCampoIss 	:= ""
Local cRecIss 		:= ""

Local cNotAnt		:=	""
Local nValIss 		:=	0
Local nValBIss 		:=	0         

Local lValDoc		:= GetNewPar("MV_VAL912",.F.)
Local lDevolucao	:= .F.
Local lIssRet		:= GetNewPar("MV_F3RECIS",.F.)
Local lEmiEnt		:= GetNewPar("MV_EMIENT",.F.)
Local lVsEmEnt      := GetNewPar("MV_VSEMENT",.T.)  
Local cForMinISS	:= GetNewPar("MV_FMINISS","1")
Local nValMinISS    := Iif(cForMinISS == '1', GetNewPar("MV_VRETISS",0), GetNewPar("MV_VBASISS",0))
Local lAchouCF		:= .F.

Local nQtdMeses := DateDiffMonth(mv_par01, mv_par02)
Local dDataIni := Ctod("//")
Local dDataFim := Ctod("//")
Local nCont := 0

#IFDEF TOP

	Local cName 	:= ""
	Local cQryAd	:= ""
	
#ENDIF

Local cFilBack := cFilAnt
Local nForFilial

SM0->(dbSetOrder(1))
For nForFilial = 1 To Len( aFilAtiv )

	cFilAnt	:= aFilAtiv[nForFilial,1]
	SM0->(dbSeek(cEmpAnt+cFilAnt))
	If !lAglFil   
		nTotal    	:= 0
		nTotIss   	:= 0
		nToBIss   	:= 0
		nAliqIss  	:= 0
		nPosAliq  	:= 0
		nValDoc   	:= 0
		nX			:= 0
		nValRec		:= 0
		nIssRet		:=	0
		cNotAnt		:=	""
		nValIss 		:=	0
		nValBIss 		:=	0       
		nPagina		:=	IIF(mv_par04<2, 2, mv_par04)
		cFilSF3	:= "('"+aFilAtiv[nForFilial,2]+"')" 
		cFilSF1	:= "('"+aFilAtiv[nForFilial,3]+"')"		// colocar variaveis a limpar por filial
	EndIf

#IFDEF TOP
		
	lQuery    := .T.
	cAliasSF3 := "QRYSF3"
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Esta rotina foi escrita para adicionar no select os campos do SC6  ³
    //³usados no filtro do usuario quando houver, a rotina acrecenta      ³
    //³somente os campos que forem adicionados ao filtro testando         ³
    //³se os mesmo já existem no select ou se forem definidos novamente   ³
    //³pelo o usuario no filtro.                                          ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   	
	If !Empty(aReturn[7])
		For nX := 1 To SF3->(FCount())
			cName := SF3->(FieldName(nX))
		 	If AllTrim( cName ) $ aReturn[7]
	      		If aStruSF3[nX,2] <> "M"  
	      		    If !cName $ cQuery .And. !cName $ cQryAd
		        	  	cQryAd += "SF3." + cName +","
		            EndIf 	
		       	EndIf
			EndIf 			       	
		Next nX
  	EndIf    
	
	
	For nCont := 0 to nQtdMeses	
   		// Inicializando variaveis.
   		lHouveMov := .F.
   		aTotCod  := {}
   		nTotal   := 0
		nTotIss  := 0
		nToBIss  := 0 
   		
   		// Na primeira passagem, a data inicial eh o proprio parametro. Nas proximas, sera o primeiro dia do mes seguinte. 	
   		dDataIni := Iif(nCont == 0, mv_par01, FirstDate(MonthSum(dDataIni, 1)))		   				   				   	
        
   		// Validacao para periodos nao fechados, cuja data final nao seja o ultimo dia do mes. 
   		// Se a data final calculada for superior ao parametro (mv_par02) atribuo o proprio parametro a ela.
   		dDataFim := IIf(LastDate(dDataIni) > mv_par02, mv_par02, LastDate(dDataIni))  
   
		cQuery    := "SELECT "
		cQuery    += cQryAd
		
		If lValDoc
			cQuery    += "SF3.F3_FILIAL,SF3.F3_NFISCAL,SF3.F3_SERIE,"
			cQuery    += Iif(SerieNfId("SF3",3,"F3_SERIE")<>"F3_SERIE","SF3."+SerieNfId("SF3",3,"F3_SERIE")+",","")
			cQuery    += "SF3.F3_CLIEFOR,SF3.F3_LOJA,SF3.F3_TIPO," 
			cQuery    += "SF3.F3_VALICM,SF3.F3_EMISSAO,SF3.F3_ENTRADA,SF3.F3_ESPECIE,SF3.F3_CODISS,SF3.F3_BASEICM,SF3.F3_ISENICM,"
			cQuery    += "SF3.F3_OUTRICM,SF3.F3_ALIQICM,SF3.F3_CFO,SF3.F3_OBSERV,SF3.F3_VALCONT, SF3.F3_RECISS, SF3.F3_ISSST "
			cQuery    += "FROM " + RetSqlName("SF3")+ " SF3 "
		Else
			cQuery    += "SF3.F3_FILIAL,SF3.F3_NFISCAL,SF3.F3_SERIE,"
			cQuery    += Iif(SerieNfId("SF3",3,"F3_SERIE")<>"F3_SERIE","SF3."+SerieNfId("SF3",3,"F3_SERIE")+",","")
			cQuery    += "SF3.F3_CLIEFOR,SF3.F3_LOJA,SF3.F3_TIPO,"
			cQuery    += "SF3.F3_VALICM,SF3.F3_EMISSAO,SF3.F3_ENTRADA,SF3.F3_ESPECIE,SF3.F3_CODISS,SF3.F3_BASEICM,SF3.F3_ISENICM,"
			cQuery    += "SF3.F3_OUTRICM,SF3.F3_ALIQICM,SF3.F3_CFO,SF3.F3_OBSERV,SF3.F3_VALCONT,SF1.F1_VALBRUT, SF3.F3_RECISS,SF3.F3_ISSST,SF1.F1_BASEICM,SF1.F1_VALICM"
			cQuery    += "FROM " + RetSqlName("SF3")+ " SF3 , " + RetSqlName("SF1")+ " SF1 "                      
		Endif
		cQuery    += "WHERE "
		cQuery    += "SF3.F3_FILIAL IN "+cFilSF3+" AND "
   			cQuery    += "SF3.F3_CFO <'5"+SPACE(LEN(SF3->F3_CFO)-1)+"' AND "	
		If  !lEmiEnt
			cQuery    += "SF3.F3_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' AND "
		Else
			cQuery    += "SF3.F3_ENTRADA BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' AND "
		EndIf
		cQuery    += "SF3.F3_DTCANC = '"+Space(Len(Dtos(SF3->F3_DTCANC)))+"' AND "
		cQuery    += "SF3.F3_TIPO = 'S' AND "
		If mv_par03<>"*"
			cQuery	+=	"SF3.F3_NRLIVRO='"+mv_par03+"' AND "
		EndIf
		cQuery    += "SF3.F3_OBSERV NOT LIKE '%CANCELAD%' AND "
		cQuery    += "SF3.D_E_L_E_T_ = ' '"
		If !lValDoc
  				   cQuery    += "AND SF1.F1_FILIAL IN " + cFilSF1 + " AND SF1.F1_DOC = SF3.F3_NFISCAL AND "
		   cQuery    += "SF1.F1_SERIE = SF3.F3_SERIE AND SF1.F1_FORNECE = SF3.F3_CLIEFOR AND SF1.F1_LOJA = SF3.F3_LOJA AND "
		   cQuery    += "SF1.D_E_L_E_T_ = ' ' "
		Endif   

		If !lEmiEnt
			cQuery    += "ORDER BY SF3.F3_EMISSAO,SF3.F3_SERIE,SF3.F3_NFISCAL,SF3.F3_CLIEFOR,SF3.F3_LOJA"
		Else
			cQuery    += "ORDER BY SF3.F3_ENTRADA,SF3.F3_SERIE,SF3.F3_NFISCAL,SF3.F3_CLIEFOR,SF3.F3_LOJA"
		Endif
	
	    cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
	
		For nX := 1 To len(aStruSF3)
			If aStruSF3[nX][2] <> "C" 
				TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
			EndIf
		Next nX
	
		dbSelectArea(cAliasSF3)	
	
#ELSE

		dbSelectArea("SF3")
		cArqInd	:=	CriaTrab(NIL,.F.)
		cChave	:=	"DTOS(F3_EMISSAO)+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA"
		cFiltro :=  "F3_FILIAL $ '"+cFilSF3+"' .AND. F3_CFO <'5"+Space(Len(SF3->F3_CFO)-1)+"' .And."
		cFiltro	+=	"DtoS(F3_EMISSAO) >='"+DtoS(dDataIni)+"' .And. DtoS(F3_EMISSAO)<='"+DtoS(dDataFim)+"' .And. "
		cFiltro +=  "Empty(F3_DTCANC) .And. !(F3_OBSERV$'CANCELAD') .And. F3_TIPO == 'S' "
		
		If mv_par03<>"*"
			cFiltro	+=	".And. F3_NRLIVRO=='"+mv_par03+"'"
		EndIf
			
		IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,STR0006)  //"Selecionando Registros..."
		DbSetIndex(cArqInd+OrdBagExt())
		(cAliasSF3)->(dbGotop())
		SetRegua(LastRec())
	
#ENDIF
			
		cNotAnt	:=	xFilial("SF3")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
		
		While (cAliasSF3)->(!Eof())                  
			
			nMes := IIf(!lEmiEnt,Month((cAliasSF3)->F3_EMISSAO),Month((cAliasSF3)->F3_ENTRADA))
		
			li := Mr912Cabec( @nPagina, Iif(!lEmiEnt,(cAliasSF3)->F3_EMISSAO,(cAliasSF3)->F3_ENTRADA))                               
			aTotCod  := {}
			nTotal   := 0
			nTotIss  := 0
			nToBIss  := 0                               
			lHouveMov:= .F.     
				
			While (cAliasSF3)->(!Eof()) .And. Iif(!lEmiEnt,Month((cAliasSF3)->F3_EMISSAO) == nMes,Month((cAliasSF3)->F3_ENTRADA) == nMes) 
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Considera filtro do usuario                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cFilterUser) .And. !(&cFilterUser)
					(cAliasSF3)->(dbSkip())
					Loop
				Endif	
				
			   If !lValDoc
				  If !lQuery
					 SF1->(dbSetOrder(1))
					 SF1->(dbSeek(xFilial("SF1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					 nValDoc := SF1->F1_VALBRUT				  
				  Else   
				     nValDoc := (cAliasSF3)->F1_VALBRUT  
				  Endif
			   Endif	  
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³De acordo com o parametro, o valor do documento sera o valor contabil ou a base de ISS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lValDoc 
	                    
					//Este Trecho do Fonte verificava se o cliente possuia nota fiscal com reducao de base de calculo, porem ficou definido que o campo
					//de valor do documento fiscal deve sempre ser o F3_VALCONT
					/* 					
					lRedIss := .F.									
					CD2->(dbSetOrder(2))
					CD2->(dbSeek(xFilial("CD2")+"E"+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))							
					While ("CD2")->(!Eof()) .AND. AllTrim(CD2->CD2_IMP) == "ISS"
					    If CD2->CD2_PREDBC > 0
					    	lRedIss := .T.
					    EndIf
					    ("CD2")->(dbskip())
					EndDo				
																																																		
					nValDoc := Iif((cAliasSF3)->F3_BASEICM+(cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM == 0,;
								(cAliasSF3)->F3_VALCONT,;  
								If (lRedIss,(cAliasSF3)->F3_VALCONT,(cAliasSF3)->F3_BASEICM+(cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM))											
				    */
				    
				    nValDoc := (cAliasSF3)->F3_VALCONT
				Endif
			                    
				lHouveMov := .T.
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busca municipio do SA2 ou SA1 de acordo com o tipo                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lDevolucao := "DEVOLUCAO" $ (cAliasSF3)->F3_OBSERV // Retorna .T. se a nota for de devolucao
			
				cAliasB    := Iif( lDevolucao, "SA1",       "SA2"       )
				cCampo     := Iif( lDevolucao, "A1_MUN",    "A2_MUN"    )
				cCampoIss  := Iif( lDevolucao, "A1_RECISS", "A2_RECISS" )
				cRecIss    := ""
	
				IF !Empty((cAliasSF3)->F3_ISSST)
					cIssSt	   	:= (cAliasSF3)->F3_ISSST
				Else
					cIssSt		:= ""	
				EndIf

				(cAliasB)->(dbSetOrder(1))
				lAchouCF := (cAliasB)->(MsSeek(xFilial(cAliasB)+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))

				If lIssRet .And. !Empty((cAliasSF3)->F3_RECISS)
					cRecIss :=If((cAliasSF3)->F3_RECISS$"12",If((cAliasSF3)->F3_RECISS=="1","N","S"),(cAliasSF3)->F3_RECISS)
				ElseIf lAchouCF
					cRecIss :=(cAliasB)->(FieldGet(FieldPos(cCampoIss)))
					cRecIss :=If(cRecIss$"12",If(cRecIss=="1","N","S"),cRecIss)
				EndIf

				If (!Empty(cCidade) .And. Alltrim((cAliasB)->(FieldGet(FieldPos(cCampo)))) $ cCidade) .Or.;
					(Empty(cCidade) .And. ("SP" $ Alltrim((cAliasB)->(FieldGet(FieldPos(cCampo)))) .Or. ;
					"SAO PAULO" $ Alltrim((cAliasB)->(FieldGet(FieldPos(cCampo)))))) .Or. cIssSt == "1"
					cMun := "1"
				Else
					cMun := "2"
				Endif

				If (cForMinISS == "1" .And. (cAliasSF3)->F3_VALICM <= nValMinISS) .Or. (cForMinISS == "2" .And. (cAliasSF3)->F3_BASEICM <= nValMinISS)
					cRecIss := "N"
				ElseIf lDevolucao
					cRecIss := Iif(cRecIss == "S","N","S")
				Endif
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta linha detalhe                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nIssRet	:=	0
				If cRecIss == "S"
		           	nIssRet   := (cAliasSF3)->F3_VALICM
				Else    
					nIssRet   := 0.00
				Endif
					
				aDetail := {StrZero(Day(IIf(lVsEmEnt,(cAliasSF3)->F3_ENTRADA,(cAliasSF3)->F3_EMISSAO)),2),;
					(cAliasSF3)->F3_ESPECIE,;
					(cAliasSF3)->&(SerieNfId("SF3",3,"F3_SERIE")),;				
					(cAliasSF3)->F3_NFISCAL,;				
					TransForm(nValDoc,"@e 99,999,999.99"),;
					Iif ((cAliasSF3)->F3_ISENICM+(cAliasSF3)->F3_OUTRICM>0, "", (cAliasSF3)->F3_CODISS),;	//Conforme Consulta IOB e Art. 85 $4 do Decreto 44.540, toda nota deve ser escriturada e em caso da nao retencao, o quadro de retencao nao deve ser gerado.
					TransForm((cAliasSF3)->F3_BASEICM,"@e 99,999,999.99"),;
					TransForm((cAliasSF3)->F3_ALIQICM,"@e 999.99"),;
					TransForm(nIssRet ,"@e 99,999,999.99"),;
					Padr(Mtr912Cnpj( (cAliasSF3)->F3_CLIEFOR, (cAliasSF3)->F3_LOJA, lDEvolucao, (cAliasSF3)->F3_CFO ),20),;
	 				cMun,;
					(cAliasSF3)->F3_OBSERV}								
								
				FmtLin(aDetail,aLay[14],,,@Li)
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Acumula por aliquota                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
				nPosAliq := Ascan(aTotCod,{|x| x[1] == (cAliasSF3)->F3_CODISS .And. x[2] == (cAliasSF3)->F3_ALIQICM })
			
				If nPosAliq == 0
			        SF6->(dbSeek(xFilial()))
		            While !SF6->(EOF())
		    	        If SF6->F6_TIPOIMP=="5" .And. SF6->F6_MESREF==nMes .And. SF6->F6_ANOREF==Year((cAliasSF3)->F3_EMISSAO)
		    	  			dDataRec :=SF6->F6_DTARREC
				   			nValRec  :=SF6->F6_VALOR
			       			Exit
				       	Endif 
				        SF6->(dbSkip())
					Enddo
					Aadd(aTotCod,{ (cAliasSF3)->F3_CODISS, (cAliasSF3)->F3_ALIQICM,(cAliasSF3)->F3_BASEICM, If(cRecIss=="S",(cAliasSF3)->F3_VALICM,0),dDataRec,nValRec } )
				Else                                                 
					aTotCod[ nPosAliq, 3] += (cAliasSF3)->F3_BASEICM
					aTotCod[ nPosAliq, 4] += If(cRecIss=="S",(cAliasSF3)->F3_VALICM,0)
				Endif				
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Acumula total                                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nValIss 	:=	If(cRecIss=="S",(cAliasSF3)->F3_VALICM,0)
				nValBIss 	:=	(cAliasSF3)->F3_BASEICM		
				
				nTotal  += nValDoc
				nTotIss += nValIss
				nToBIss += nValBIss
						
				(cAliasSF3)->(dbSkip())
			    
		   		If cNotAnt==xFilial("SF3")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
		   			If !lValDoc
						nTotal  -= nValDoc
					EndIf
		   		Else
					cNotAnt	:=	xFilial("SF3")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se nao for fim de arquivo salta pagina com saldo a transportar          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				If ( Li > 54 ) .And. (cAliasSF3)->(!Eof()) .And. IIf(!lEmiEnt,Month((cAliasSF3)->F3_EMISSAO),Month((cAliasSF3)->F3_ENTRADA)) == nMes

					FmtLin({},aLay[18],,,@Li)
					FmtLin({TransForm(nTotal ,"@e 99,999,999.99"),TransForm(nToBIss,"@e 99,999,999.99"),TransForm(nTotIss,"@e 99,999,999.99")},aLay[19],,,@Li)
					FmtLin({},aLay[18],,,@Li)
					li := Mr912Cabec( @nPagina, (cAliasSF3)->F3_EMISSAO )
				Endif	
					
			EndDo	
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime total                                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If lHouveMov
				For nX := li to nQtdLinha
					FmtLin({},aLay[15],,,@Li)	
				Next nX
				
				FmtLin({},aLay[16],,,@Li)
				FmtLin({TransForm(nTotal ,"@e 99,999,999.99"),TransForm(nToBIss,"@e 99,999,999.99"),TransForm(nTotIss,"@e 99,999,999.99")},aLay[17],,,@Li)
				FmtLin({},aLay[18],,,@Li)
				
				li := 0
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Imprime Rodape                                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				FmtLin({StrZero(nPagina,5)},aLay[20],,,@Li)	
				FmtLin({},aLay[21],,,@Li)
				FmtLin({},aLay[22],,,@Li)
				FmtLin({},aLay[23],,,@Li)	
				
				For nX := 1 to Len(aTotCod)
					FmtLin({TransForm(aTotCod[ nX, 3 ] ,"@e 99,999,999.99"),;
					aTotCod[ nX, 1 ],;
					TransForm(aTotCod[ nX, 2 ] ,"@e 999.99"       ),;
					TransForm(aTotCod[ nX, 4 ] ,"@e 99,999,999.99")	,;			
					aTotCod[ nX, 5 ],;
					TransForm(aTotCod[ nX, 6 ],"@e 99,999,999.99"),;
					""},aLay[24],,,@Li)		
				Next nX
				
				FmtLin({},aLay[25],,,@Li)	
				FmtLin({TransForm(nToBIss,"@e 99,999,999.99"),TransForm( nTotIss ,"@e 99,999,999.99"),TransForm( 0,"@e 99,999,999.99")},aLay[26],,,@Li)		
				FmtLin({},aLay[25],,,@Li)	
				FmtLin({cCidade+" "+STR0020},aLay[28],,,@Li)	//"Municipio (1=Sao Paulo, 2=Outros)."
				nPagina++	
			Else
				lHouveMov := .T.
				FmtLin({},aLay[27],,,@Li)		
				
				For nX := li to nQtdLinha
					FmtLin({},aLay[15],,,@Li)	
				Next nX
				
				FmtLin({},aLay[16],,,@Li)
				FmtLin({TransForm(nTotal ,"@e 99,999,999.99"),TransForm(nToBIss,"@e 99,999,999.99"),TransForm(nTotIss,"@e 99,999,999.99")},aLay[17],,,@Li)
				FmtLin({},aLay[18],,,@Li)
			Endif
		EndDo
			
		If !lHouveMov
			li := Mr912Cabec( @nPagina, dDataIni )
			FmtLin({},aLay[27],,,@Li)		
				
			For nX := li to nQtdLinha
				FmtLin({},aLay[15],,,@Li)	
			Next nX
			
			FmtLin({},aLay[16],,,@Li)
			FmtLin({TransForm(nTotal ,"@e 99,999,999.99"),TransForm(nToBIss,"@e 99,999,999.99"),TransForm(nTotIss,"@e 99,999,999.99")},aLay[17],,,@Li)
			FmtLin({},aLay[18],,,@Li)
		Endif
			
		If !lQuery
			RetIndex("SF3")	
			dbClearFilter()	
			Ferase(cArqInd+OrdBagExt())
		Else
			dbSelectArea(cAliasSF3)
			dbCloseArea()
		Endif
#IFDEF TOP	
	Next nCont	
#ENDIF
		
	If mv_par08 > 1 
		TERMGO(cArqAbert,cArqEncer,cPerg,aDriver[4],aDados)
	EndIf

	If lAglFil
		Exit
	EndIf

Next nForFilial

cFilAnt := cFilBack
		
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Mr912Cabec³ Autor ³ Henry Fila            ³ Data ³ 24.03.03 ³±±
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

Static Function Mr912Cabec( nPagina, dDataImp )

Local li        := 0
Local aLay      := RetLayOut()
Local cCCM      := If(!Empty(mv_par05),mv_par05,SM0->M0_INSCM) 
Local cMesIncid := MesExtenso(Month(dDataImp))
Local cAno      := Ltrim(Str(Year(dDataImp)))

@ Li,000 PSAY AvalImp(Limite)

FmtLin({},aLay[01],,,@Li)
FmtLin({StrZero(nPagina,5)},aLay[02],,,@Li)
FmtLin({},aLay[03],,,@Li)
FmtLin({},aLay[04],,,@Li)
FmtLin({cMesIncid,cAno},aLay[05],,,@Li)
FmtLin({},aLay[06],,,@Li)
FmtLin({SM0->M0_NOMECOM,AllTrim(SM0->M0_ENDENT),Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),SM0->M0_INSC,Iif(!Empty(cCCM),cCCM,"")},aLay[07],,,@Li)
FmtLin({},aLay[08],,,@Li)
FmtLin({},aLay[09],,,@Li)
FmtLin({},aLay[10],,,@Li)
FmtLin({},aLay[11],,,@Li)
FmtLin({},aLay[12],,,@Li)
FmtLin({},aLay[13],,,@Li)

nPagina++

Return(li)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RetLayOut ³ Autor ³ Henry Fila            ³ Data ³ 24.03.03 ³±±
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

Local aLay := Array(28)

//
//                     1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890


aLay[01] := "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLay[02] := STR0007 //"| REGISTRO DE SERVICOS TOMADOS OU INTERMEDIADOS DE TERCEIROS                                                                                                                                                   PAGINA #### |"
aLay[03] := "|                                                                                                                                                                                                                          |"
aLay[04] := STR0008 //"| IMPOSTO SOBRE SERVICOS                                                                                                                                                                           | MES DE INCIDENCIA/ANO |"
aLay[05] := "|                                                                                                                                                                                                  |  ########## / ####    |"
aLay[06] := "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
aLay[07] := STR0009//"| ######################################## Endereco : #############################  CNPJ : #################       IE : ###############         CCM : #####                                                                        |"
aLay[08] := "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
aLay[09] := STR0010//"|DOCUMENTO                                             |RETENCAO DO ISS NA FONTE                                        |PRESTADOR DO SERVICO                                                                              
aLay[10] := "|------------------------------------------------------+----------------------------------------------------------------+--------------------------------------------------------------------------------------------------|"
aLay[11] := STR0011//"| DIA| ESPECIE | SERIE | NUMERO    |  VALOR DO DOCTO   | CODIGO DO   |  BASE DE CALCULO | ALIQUOTA |VALOR DO ISS RETIDO |      CNPJ/CPF       |MUNICIPIO|                             OBSERVACOES                          
aLay[12] := STR0012//"|    |         | SUBS. |           |                   | RECOLHIMENTO|                  |          |                    |                     |         |                                                                  
aLay[13] := "|====+=========+=======+===========+===================+=============+==================+==========+====================+=====================+=========+==================================================================|"
aLay[14] := "| ## | ######  |  ###  | ######### |  ################ | ############|  ##############  |  ######  |  ################# | ####################|    #    |##################################################################|"
aLay[15] := "|    |         |       |           |                   |             |                  |          |                    |                     |         |                                                                  |"
aLay[16] := "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
aLay[17] := STR0013//"|TOTAL DO MES  |       |           |  ################ |             |  ################|          |  ################# |                     |         |                                                                  
aLay[18] := "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
aLay[19] := STR0014//"|A TRANSPORTAR |       |           |  ################ |             |  ################|          |  ################# |                     |         |                                                                  |"

aLay[20] := STR0015 //"RESUMO DO MES POR CODIGO DE RECOLHIMENTO                                          |RECOLHIMENTOS RELATIVOS AO MES DE INCIDENCIA                                                                                PAGINA ######"
aLay[21] := "+---------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|"
aLay[22] := STR0016 //"|      BASE DE CALCULO      |  CODIGO DO RECOLHIMENTO  | ALIQUOTA |        IMPOSTO RETIDO| DATA DE RECOLHIMENTO |         VALOR RECOLHIDO|                                   OBSERVACOES                                   |"
aLay[23] := "|===========================+==========================+==========+======================+======================+========================+=================================================================================|"
aLay[24] := "|    ###################### |       ############       | ######   |   ################## |       ##########     |       ################ |################################################################################ |"    
aLay[25] := "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
aLay[26] := STR0017 //"| ##################        |                TOTAIS               |   ################## |                      |       ################ |                                                                                 |"
aLay[27] := STR0018//"| *** NAO HOUVE MOVIMENTACAO ***   |                   |             |                  |          |                    |                     |         |                                                                  |"
aLay[28] := STR0019
Return(aLay)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Mtr912Cnpj³ Autor ³ Henry Fila            ³ Data ³20/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorno do Cnpj do F3                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpC1 : Codigo do Cliente no F3                             ³±±
±±³          ³ExpC2 : Loja do Cliente no F3                               ³±±
±±³          ³ExpC3 : Tipo do F3                                          ³±±
±±³          ³ExpC4 : CFO do F3                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Mtr912Cnpj(cCliFor, cLoja, lDevolucao, cCfo)

Local aArea   := GetArea()
Local aAreaSA1:= SA1->(GetArea())
Local aAreaSA2:= SA2->(GetArea())
Local cCnpj   := ""
Local cAliasB := ""
Local cCampo  := ""

If Left( cCfo, 1) >= "5" 
	cAliasB := Iif( lDevolucao, "SA2", "SA1" )
	cCampo  := Iif( lDevolucao, "A2_CGC", "A1_CGC" )
Else	
	cAliasB := Iif( lDevolucao, "SA1", "SA2" )
	cCampo  := Iif( lDevolucao, "A1_CGC", "A2_CGC" )
EndIf	

(cAliasB)->(dbSetOrder(1))
If (cAliasB)->(MsSeek(xFilial(cAliasB)+cCliFor+cLoja))
	cCnpj := (cAliasB)->(FieldGet(FieldPos(cCampo)))
EndIf

RestArea(aAreaSA1)
RestArea(aAreaSA2)
RestArea(aArea)

Return(cCnpj)
