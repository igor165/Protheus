#Include "Protheus.Ch"
#Include "MatrBol2.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MATRBOL1  ³ Autor ³Sergio S. Fuzinaka     ³ Data  ³ 18.07.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³RDMAKE do Livros de Compras/Vendas IVA                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Bolivia                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR ³ DATA   ³ BOPS    ³          MOTIVO DA ALTERACAO          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Fernando    ³28/10/08³154004   ³Mudancas nos livros de compras e vendas³±±
±±³ Separovic   ³        ³         ³IVA                                    ³±±
±±³Jonathan Glez³06/12/16³SERINN001³Se modifica uso de tablas temporales   ³±±
±±³             ³        ³     -713³por motivo de limpieza de CTREE.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MatrBol2()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis     	                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTitulo	:= OemToAnsi(STR0001)	//"Livro IVA de Compras/Vendas"
Local cDescr1	:= OemToAnsi(STR0002)	//"Este programa tem como objetivo imprimir o relatorio Livro IVA de Compras/Vendas"
Local cPerg	 	:= "MTRBO2"
Local cNomeProg	:= "MATRBOL2" 
Local cString	:= "SF3"  
Local cOrdem	:= ""

Private cTam	:= "G"
Private lEnd	:= .F.
Private aReturn	:= {STR0004, 1, STR0005, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey:= 0
Private m_pag	:= 1
Private wnRel	:= ""
Private aL		:= Array(9)

If (cPaisLoc == "BOL" .Or. (cPaisLoc == "URU" .And. GetNewPar("MV_LOCBURU",.F.))) .And. LocBol()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o LayOut do Relatorio                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LayOut(@aL)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ajusta o Grupo de Perguntas                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnRel := SetPrint(cString,cNomeProg,cPerg,cTitulo,cDescr1,,,.F.,,.T.,cTam,,.T.)
	If nLastKey == 27
		Return Nil
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return Nil
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ RPTSTATUS monta janela com a regua de processamento    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RptStatus({|| Imprime()},cTitulo)
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Imprime    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 25.06.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina de Impressao do Livro de Compras IVA                  ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Imprime()
Local nLivro	:= mv_par01			//Livro: 1-Compras ou 2-Vendas
Local dDtIni	:= mv_par02
Local dDtFim	:= mv_par03
Local cFolha	:= STR(mv_par06-1, 3)
Local nImpExclu := mv_par07  // 1- Imprime ou 2- Nao imprime
Local cRG		:= mv_par09      
Local cResp		:= Upper(mv_par10)  
Local cFiltro	:= ""
Local cAlias	:= "SF3" 
Local cAlias2	:= "SF3" 
Local cAliasTel := "SF1"
Local cEmissNF	:= ""
Local cCondicao	:= ""
Local cIndexSF3	:= ""
Local cIndexTel := ""
Local cIndex2	:= ""
Local cDebug	:= ""  
Local cEspecie  := ""
Local cCLIEFOR  := "" 
Local cSerieAtu := nil
Local cSerieAnt := nil      
Local cDatNFAnt := ""
Local cNFAtu	:= nil 
Local cRazSoc	:= ""
Local cNIT		:= ""   
Local cFilDe    := cFilAnt
Local cFilAte   := cFilAnt
Local cFilOld   := cFilAnt 
Local cAutoriz  := "" 
Local cOrdem	:= ""
Local cChaveSf3 := "" 
Local lQuery	:= .F. 
Local lVALIMP	:= .F. 
Local lPassag 	:= .F. 
Local lImport   := .F. 
Local lDataTel  := .F. 
Local lFistNFs  := .F.
Local aDados	:= {}
Local aAreaSM0  := SM0->(GetArea()) 
Local aAreaSF3  := SF3->(GetArea())
Local aImpostos	:= {} 
Local aArea   	:= {}   
Local aFistNFs  := {}
Local aTotPar	:= {}		//Totais Parciais
Local aTotGer	:= {}		//Totais Gerais 
Local nIndex	:= 0  
Local nTotalICE := 0
Local nAuxNFAtu := 0
Local nNFAtu2	:= nil
Local nNFAnt	:= nil   
Local nNum      := 0  
Local nNum2     := 0 
Local nTotGer	:= 0
Local nLin		:= 0  
Local nTotalTel := 0
Local nx        := 0
local nPos      := 0
Local dDataTel  := "" 
Local cArqTrab  :=""
Local cAliasSF3 :="" 
Local aEstrSF3  :={}
Local cFilSF3   :=""  
Local cSelect   :=""
 
Private oTmpTable
Private aOrder    := {}

cFilDe  := mv_par04 
cFilAte := mv_par05
// Processa todo o arquivo de filiais ou apenas a filial atual
SM0->(MsSeek(cEmpAnt+cFilDe,.T.))

While !SM0->(Eof()) .And.;
 	 	SM0->M0_CODIGO == cEmpAnt .And.;
  	 	SM0->M0_CODFIL <= cFilAte
  	 	
	// inicializacoes --------------------------------------------------
	nLin	 := 0    
	cFiltro	 := ""
	cAlias	 := "SF3" 
	cAlias2	 := "SF3" 
	cAliasTel:= "SF1"
	cEmissNF := ""
	cCondicao:= ""
	cDebug	 := ""  
	cEspecie := ""
	cCLIEFOR := "" 
	cSerieAtu:= nil
	cSerieAnt:= nil      
	cDatNFAnt:= ""
	cNFAtu	 := nil 
	cRazSoc	 := ""
	cNIT     := "" 
	cAutoriz := ""  
	
	lQuery	:= .F. 
	lVALIMP	:= .F.

	aDados    := {}
	aImpostos := {} 
	aArea     := {}  
	aFistNFs  := {}
	
	nIndex	  := 0  
	nTotalICE := 0
	nAuxNFAtu := 0
	nNFAtu2	  := nil
	nNFAnt    := nil   
	nNum      := 0 
	nTotGer	  := 0  
	nNUMDES   := 0
	nF1TipC   := 0 
	nF2TipC   := 0 

    aTotPar	:= {OemToAnsi(STR0008),0,0,0,0,0}		//Totais Parciais
	aTotGer	:= {OemToAnsi(STR0009),0,0,0,0,0}		//Totais Gerais 
	lPassag := cPaisLoc == "BOL" .And. GetNewPar("MV_PASSBOL",.F.)

	cArqTrab  :=""
	cAliasSF3 :="" 
	aEstrSF3  :={}
	cFilSF3   :=""
						
	cFilAnt := SM0->M0_CODFIL 
	
	#IFDEF TOP
	    If TcSrvType() <> "AS/400"
	    	lQuery := .T.
	    Endif
	#ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta aImpostos com as informacoes do IVA              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SFB")
	dbSetOrder(1)
	dbGoTop()
	
	AADD(aImpostos,{"IVA",""})                
	While !SFB->(Eof()) 
		If aScan(aImpostos,{|x| SFB->FB_CODIGO $ x[1]}) > 0
			aImpostos[aScan(aImpostos,{|x| SFB->FB_CODIGO $ x[1]})][2] := SFB->FB_CPOLVRO
		Endif	
		dbSkip()
	Enddo                 
	aSort(aImpostos,,,{|x,y| x[2] < y[2]})
	
	AAdd(aImpostos[1],SF3->(FieldPos("F3_BASIMP"+aImpostos[1][2])))	//[3] Base de Calculo
	AAdd(aImpostos[1],SF3->(FieldPos("F3_VALIMP"+aImpostos[1][2])))	//[4] Valor do Imposto    
	         
	
	dbSelectArea("SF3")
	dbSetOrder(1)
	  
	lVALIMP := .T.
	
	// primeiras notas de cada serie ---------------
	If nLivro <> 1
		If lQuery
			cSelect := "%F3_SERIE,"+Iif(SerieNfId("SF3",3,"F3_SERIE")<>"F3_SERIE",SerieNfId("SF3",3,"F3_SERIE")+", ","")+" MAX(F3_NFISCAL) as NF%"
			cAlias2 := GetNextAlias()
			BeginSql Alias cAlias2
				Column F3_EMISSAO as Date
				SELECT %Exp:cSelect%
				FROM %Table:SF3% SF3
				WHERE F3_FILIAL = %Exp:xFilial("SF3")% AND 
					F3_EMISSAO > %Exp:dDtIni% AND 
					F3_FORMUL = 'S' AND
					SF3.%NotDel% 
					GROUP BY F3_SERIE
			EndSql 
			cDebug := GetLastQuery()[2]		//Para debugar a query     
			
			While !((cAlias2)->(Eof()))
				AADD(aFistNFs,{(cAlias2)->F3_SERIE,(cAlias2)->NF})     	     
				(cAlias2)->(DbSkip())
			Enddo	
		Else            
		    
			cIndex2 := CriaTrab(Nil,.F.)
			cFiltro	:= "F3_FILIAL == '"+ xFilial("SF3") + "' .And. "
			
			If (nLivro == 1 .And. mv_par11 == 2) .Or. nLivro == 2
			   	cFiltro	+= "Dtos(F3_EMISSAO) < '"+Dtos(dDtIni)+"' .AND. F3_FORMUL == 'S'"
			IndRegua(cAlias2,cIndex2,"F3_EMISSAO,F3_FILIAL,F3_NFISCAL",,cFiltro,STR0017) //"Selecionando registros..." 		

			Else
				cFiltro	+= "Dtos(F3_ENTRADA) < '"+Dtos(dDtIni)+"' .AND. F3_FORMUL == 'S'"
			IndRegua(cAlias2,cIndex2,"F3_ENTRADA,F3_FILIAL,F3_NFISCAL",,cFiltro,STR0017) //"Selecionando registros..." 				

			EndIf 
		
			nIndex := RetIndex("SF3")
			dbSetIndex(cIndex2+OrdBagExt())
			dbSetOrder(nIndex+1)
	   		dbGoTop()	
	   		 
	   		// tipos de serie
	   		DbSelectArea("SX5") 
		 	DbSeek (xFilial("SX5")+"01") 
		 	
		 	While xFilial("SX5") == X5_FILIAL .AND. X5_TABELA == "01"
		 		AADD(aFistNFs,{SX5->X5_CHAVE,"0"}) 
		 		SX5->(DbSkip())
			Enddo	
		    
		    
			While !((cAlias2)->(Eof()))       
				conout((cAlias2)->&(SerieNfId("SF3",3,"F3_SERIE")))
				For nNum:=1 to Len(aFistNFs)
					If (ALLTRIM(aFistNFs[nNum][1]) == ALLTRIM((cAlias2)->F3_SERIE) .OR. ;
						 (Empty(aFistNFs[nNum][1]) .AND. Empty((cAlias2)->F3_SERIE))) .AND. VAL(aFistNFs[nNum][2]) < VAL((cAlias2)->F3_NFISCAL)
						aFistNFs[nNum][2] := (cAlias2)->F3_NFISCAL
					Endif
				Next	           	     
		
				(cAlias2)->(DbSkip())
			Enddo	
		
		 	dbSelectArea("SF3")
			RetIndex("SF3")
			dbClearFilter()
			Ferase(cIndexSF3+OrdBagExt())
		Endif
	Endif
	
	
	If lQuery
		cCondicao := "%" 
		If nLivro == 1 //compras
			cCondicao += "((F3_TIPOMOV = 'C')" //fornecedor
			cCondicao += " OR "        
			cCondicao += "(F3_TIPOMOV = 'V' AND (F3_ESPECIE IN ('NCC','NCE','NDC','NDE'))))" //cliente
			cCondicao += " AND F3_RECIBO <> '1'"
		Else
			cCondicao += "((F3_TIPOMOV = 'V')" //cliente
			cCondicao += " OR "        
			cCondicao += "(F3_TIPOMOV = 'C' AND (F3_ESPECIE IN ('NCP','NCI','NDP','NDI'))))" //fornecedor
		Endif   
		cCondicao += " AND"
		cCondicao += "%"
	
		cAlias := GetNextAlias()  
		If (nLivro == 1 .And. mv_par11== 2) .Or. nLivro == 2
		
			BeginSql Alias cAlias   
				Column F3_DTCANC  as Date 
				Column F3_DTLANC  as Date
	 			Column F3_DTPASSA as Date  
		 		Column F3_ENTRADA as Date
		 		Column F3_EMISSAO as Date
				SELECT *
				FROM %Table:SF3% SF3
				WHERE F3_FILIAL = %Exp:xFilial("SF3")% AND 
				   	((F3_COMPANH  = ' ' AND F3_LOJCOMP  = ' ' AND F3_EMISSAO >= %Exp:dDtIni% AND F3_EMISSAO <= %Exp:dDtFim%) OR
			         (F3_COMPANH <> ' ' AND F3_LOJCOMP <> ' ' AND F3_DTPASSA >= %Exp:dDtIni% AND F3_DTPASSA <= %Exp:dDtFim%) OR
		    	     (F3_EMISSAO <= %Exp:dDtFim% AND F3_TIPCOMP = 'T')) AND
			 		%exp:cCondicao% 
				 	SF3.%NotDel% 
			   	ORDER BY F3_SERIE, F3_EMISSAO, F3_NFISCAL //%Order:SF3%
			EndSql   
		
		Else   
			BeginSql Alias cAlias   
				Column F3_DTCANC  as Date 
				Column F3_DTLANC  as Date
		 		Column F3_DTPASSA as Date  
	 			Column F3_ENTRADA as Date
	 			Column F3_EMISSAO as Date
				SELECT *
				FROM %Table:SF3% SF3
				WHERE F3_FILIAL = %Exp:xFilial("SF3")% AND 
				   	((F3_COMPANH  = ' ' AND F3_LOJCOMP  = ' ' AND F3_ENTRADA >= %Exp:dDtIni% AND F3_ENTRADA <= %Exp:dDtFim%) OR
		        	 (F3_COMPANH <> ' ' AND F3_LOJCOMP <> ' ' AND F3_DTPASSA >= %Exp:dDtIni% AND F3_DTPASSA <= %Exp:dDtFim%) OR
			         (F3_ENTRADA <= %Exp:dDtFim% AND F3_TIPCOMP = 'T')) AND
				 	%exp:cCondicao% 
				 	SF3.%NotDel% 
		   		ORDER BY F3_SERIE, F3_ENTRADA, F3_NFISCAL //%Order:SF3%
		EndSql 
		       
		EndIf
	
		cDebug := GetLastQuery()[2]		//Para debugar a query  

	Else 
	
		If nLivro == 1 //compras
			cCondicao := "((F3_TIPOMOV == 'C')" //fornecedor
			cCondicao += " .OR. "        
			cCondicao += "(F3_TIPOMOV == 'V' .AND. (ALLTRIM(F3_ESPECIE) $ 'NCC,NCE,NDC,NDE')))" //cliente
			cCondicao += " AND F3_RECIBO <> '1'"
		Else
			cCondicao := "((F3_TIPOMOV == 'V')" //cliente
			cCondicao += " .OR. "        
			cCondicao += "(F3_TIPOMOV == 'C' .AND. (ALLTRIM(F3_ESPECIE) $ 'NCP,NCI,NDP,NDI')))" //fornecedor
		Endif   
		
		cIndexSF3 := CriaTrab(Nil,.F.)
		cFiltro	:= "F3_FILIAL == '"+ xFilial("SF3") + "' .And. "

		If nLivro == 1 .And. mv_par11 == 2
			cFiltro += "((Empty(F3_COMPANH) .AND. Empty(F3_LOJCOMP) .AND. Dtos(F3_EMISSAO) >= '"+Dtos(dDtIni)+"' .AND. Dtos(F3_EMISSAO) <= '"+Dtos(dDtFim)+"')  .OR."
			cFiltro +=  "(!Empty(F3_COMPANH).AND.!Empty(F3_LOJCOMP) .AND. Dtos(F3_DTPASSA) >= '"+Dtos(dDtIni)+"' .AND. Dtos(F3_DTPASSA) <= '"+Dtos(dDtFim)+"')) .OR. "
			cFiltro	+= "Dtos(F3_EMISSAO) <= '"+Dtos(dDtFim)+"' .AND. F3_TIPCOMP == 'T' .AND."
			cFiltro	+= cCondicao  
			cOrdem := "F3_FILIAL+Dtos(F3_EMISSAO)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM)"
		
		Else
			cFiltro += "((Empty(F3_COMPANH) .AND. Empty(F3_LOJCOMP) .AND. Dtos(F3_ENTRADA) >= '"+Dtos(dDtIni)+"' .AND. Dtos(F3_ENTRADA) <= '"+Dtos(dDtFim)+"')  .OR."
			cFiltro +=  "(!Empty(F3_COMPANH).AND.!Empty(F3_LOJCOMP) .AND. Dtos(F3_DTPASSA) >= '"+Dtos(dDtIni)+"' .AND. Dtos(F3_DTPASSA) <= '"+Dtos(dDtFim)+"')) .OR. "
			cFiltro	+= "Dtos(F3_ENTRADA) <= '"+Dtos(dDtFim)+"' .AND. F3_TIPCOMP == 'T' .AND."
			cFiltro	+= cCondicao 
			cOrdem := "F3_FILIAL+Dtos(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM)"
		EndIf
	
	   	IndRegua(cAlias,cIndexSF3,cOrdem,,cFiltro,STR0017) //"Selecionando registros..." 
		nIndex := RetIndex("SF3")
		dbSetIndex(cIndexSF3+OrdBagExt())
		dbSetOrder(nIndex+1)
		dbGoTop()	
	Endif  
		
	// arquivo temporario ---------------------------------------------------------------------------  
	If nLivro == 1	//Compras  
		cAliasSF3:= GetNextAlias()   
	 	aEstrSF3 := SF3->(DbStruct())

		//Creacion de Objeto
		aOrder	:=	{"F3_EMISSAO","F3_NFISCAL"} //JGR
		oTmpTable := FWTemporaryTable():New(cAliasSF3) //JGR
		oTmpTable:SetFields( aEstrSF3 ) //JGR
		oTmpTable:AddIndex("I01", aOrder) //JGR
		oTmpTable:Create() //JGR

	 	cFilSF3 := xFilial("SF3")
   	 	While !((cAlias)->(Eof()))     
	 	   
	 	    If (cAlias)->F3_TIPCOMP == 'T'   
	 	    	
		 	    DbSelectArea("SE5") 
		 	  	Dbsetorder(7)
		 		DbSeek (xFilial("SE5")+(cAlias)->F3_SERIE+padr((cAlias)->F3_NFISCAL, TAMSX3("E5_NUMERO")[1]))  
		 		
		 		nTotalTel := 0 
		 		dDataTel  := "" 
		 		lDataTel  := .F. 
		 		
		 		While ((cAlias)->F3_SERIE == SE5->E5_PREFIXO .And. ; 
		 	 		padr((cAlias)->F3_NFISCAL, TAMSX3("E5_NUMERO")[1]) == SE5->E5_NUMERO) .And. !SE5->(Eof())
		 	   		
		 	   		If (cAlias)->F3_CLIEFOR == SE5->E5_CLIFOR .And. (cAlias)->F3_LOJA == SE5->E5_LOJA .And. ;
		 	   	  		Dtos(SE5->E5_DATA) >= Dtos(dDtIni) .And. Dtos(SE5->E5_DATA) <= Dtos(dDtFim)
		 	   			
		 	   			nTotalTel += SE5->E5_VALOR
		 	   			
		 	   			If !lDataTel
		 	   				dDataTel := SE5->E5_DATA          
			 	   			lDataTel := .T.
		 	   			Endif
		 	   			
		 	   		Endif
		 		     
		 		   	SE5->(DbSkip())
		 		Enddo  
		 		
		 		If lDataTel      
		 			nTotalTel :=xMoeda(nTotalTel,Val(SE5->E5_MOEDA),1,SE5->E5_DATA,MsDecimais(1))

			 	 	(cAliasSF3)->(DbAppend())		 		 		
			   		For nNum := 1 To Len(aEstrSF3)
		 		   		cCpo := aEstrSF3[nNum,1]
		 		   		(cAliasSF3)->(&cCpo) := (cAlias)->&cCpo
		 	   		Next    
				 	 				 	                                                                                                                   
					// Credito IVA			 				 	
				 	(cAliasSF3)->(&(FieldName(aImpostos[1][4]))) := (nTotalTel / (cAliasSF3)->F3_VALCONT) * (cAliasSF3)->(FieldGet(aImpostos[1][4])) 
				 	// Valor Liquido ABC
				 	(cAliasSF3)->(&(FieldName(aImpostos[1][3]))) := nTotalTel - (cAliasSF3)->(FieldGet(aImpostos[1][4]))
				 	
				    (cAliasSF3)->F3_EMISSAO := dDataTel
				 	(cAliasSF3)->F3_VALCONT := nTotalTel   
				 	lDataTel := .F.
				 Endif	    	    
	 	    Else
	 	    	(cAliasSF3)->(DbAppend()) 
	 		 		 		
		 		For nNum := 1 To Len(aEstrSF3)
		 			cCpo := aEstrSF3[nNum,1]
		 			(cAliasSF3)->(&cCpo) := (cAlias)->&cCpo
		 		Next     
		 		
		 		// deve ser impresso a data da passagem aerea e nao a emissao da mesma 
		 		If lPassag .And. !Empty((cAlias)->F3_COMPANH) .And. !Empty((cAlias)->F3_LOJCOMP)
					(cAliasSF3)->F3_EMISSAO := (cAlias)->F3_DTPASSA
				Endif  
			Endif		 			
				 		
			(cAlias)->(DbSkip())
	 	Enddo
	Else
		cAliasSF3 := cAlias
	Endif         
	 	
   	While !(cAliasSF3)->(Eof())
	
		cChaveSf3 := (cAliasSF3)->F3_FILIAL+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aborta impressao                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEnd
			Exit
		Endif   
		lImport := .F. // indica se existe uma Poliza de Importacion ou nao para que seja ou nao impressa a serie
		
		If !Empty((cAliasSF3)->F3_TIPCOMP) 
			If (cAliasSF3)->F3_TIPCOMP == "A"
				cAutoriz := "1"
			Else
				If (cAliasSF3)->F3_TIPCOMP == "R"	  
					cAutoriz := "2"
		    	Else
					If (cAliasSF3)->F3_TIPCOMP == "P"	  
						cAutoriz := "3"
					Else
						cAutoriz := (cAliasSF3)->F3_NUMAUT
			   		Endif 
				Endif  
			Endif
		Else 
			cAutoriz := (cAliasSF3)->F3_NUMAUT
		Endif
		
		If !Empty((cAliasSF3)->F3_RAZSOC) 
			cRazSoc := (cAlias)->F3_RAZSOC
			cNIT	:= (cAlias)->F3_NIT
		EndIf	     
		
		If nLivro == 1	//Compras  		
			
			If (cAliasSF3)->F3_TIPO == "B" .OR. (cAliasSF3)->F3_TIPOMOV = "V"              
				cRazSoc := Posicione("SA1",1,xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,"A1_NOME")
				cNIT	:= Posicione("SA1",1,xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,"A1_CGC") 
				If Empty(cNIT)
					cNIT := Posicione("SA1",1,xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,"A1_RG") 
				Endif
				cNFAtu   := (cAliasSF3)->F3_NFISCAL
				cEmissNF := (cAliasSF3)->F3_EMISSAO
			Else 
			 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se as informacoes da companhia area estao preenchidas.³
				//³Se sim, os dados no livro devem ser da companhia aerea.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lPassag .And. !Empty((cAliasSF3)->F3_COMPANH) .And. !Empty((cAliasSF3)->F3_LOJCOMP)
					cRazSoc := Posicione("SA2",1,xFilial("SA2")+(cAliasSF3)->F3_COMPANH+(cAliasSF3)->F3_LOJCOMP,"A2_NOME")
					cNIT	:= Posicione("SA2",1,xFilial("SA2")+(cAliasSF3)->F3_COMPANH+(cAliasSF3)->F3_LOJCOMP,"A2_CGC")
					cNFAtu   := (cAliasSF3)->F3_PASSAGE  
					cEmissNF := (cAliasSF3)->F3_DTPASSA 
				Else
					// caso tenha uma politica de importacao ela deve ser impressa no lugar da NF
		 			If !Empty(nNUMDES := Posicione("SF1",1,xFilial("SF1")+(cAliasSF3)->F3_NFISCAL,"F1_NUMDES"))
		 				lImport := .T.
		  				cRazSoc := Posicione("SA2",1,xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,"A2_NOME")
						cNIT	:= Posicione("SA2",1,xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,"A2_CGC")
						cNFAtu  := nNUMDES
						cEmissNF:= (cAliasSF3)->F3_EMISSAO  	
					Else 
						cRazSoc := Posicione("SA2",1,xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,"A2_NOME")
						cNIT	:= Posicione("SA2",1,xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,"A2_CGC")
						cNFAtu   := (cAliasSF3)->F3_NFISCAL
						cEmissNF := (cAliasSF3)->F3_EMISSAO  
					Endif
				Endif
			EndIf	
		Else   // vendas ----------------------------------------------------------------------------------------------		
			
			If (cAliasSF3)->F3_TIPO == "B" .OR. (cAliasSF3)->F3_TIPOMOV = "C"                  
				cRazSoc := Posicione("SA2",1,xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,"A2_NOME")
				cNIT	:= Posicione("SA2",1,xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,"A2_CGC")
				cNFAtu   := (cAliasSF3)->F3_NFISCAL
				cEmissNF := (cAliasSF3)->F3_EMISSAO
			Else
				cRazSoc := ''
				If Empty(cRazSoc) 
					cRazSoc := Iif(!empty((cAlias)->F3_DTCANC), 'A N U L A D A', Posicione("SA1",1,xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,"A1_NOME"))
				EndIf
				If Empty(cNIT)
					cNIT	:= Iif(!empty((cAlias)->F3_DTCANC), '0', Posicione("SA1",1,xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,"A1_CGC"))  
				
					If Empty(cNIT)
						cNIT := Iif(!empty((cAlias)->F3_DTCANC), '0', Posicione("SA1",1,xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,"A1_RG"))
					Endif
				EndIf	
				cNFAtu   := (cAliasSF3)->F3_NFISCAL
				cEmissNF := (cAliasSF3)->F3_EMISSAO
			EndIf	
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados da Nota Fiscal                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		// serie da nota fiscal atual
	   	cSerieAtu := (cAliasSF3)->F3_SERIE 
		
		// caso tenha mudado a serie, utilizado para imprimir as notas anteriores q foram deletadas 
		if (cSerieAnt <> cSerieAtu) .and. nLivro <> 1 
		
		   	lFistNFs := .F.
			
			For nNum:=1 to Len(aFistNFs) 
				If ALLTRIM(aFistNFs[nNum][1]) == ALLTRIM(cSerieAtu)
					nNFAnt := val(aFistNFs[nNum][2])
					lFistNFs := .T.
				Endif
			Next
			
			If !lFistNFs
				nNFAnt := Val((cAliasSF3)->F3_NFISCAL)
			Endif
		
		Endif	
	  	   
		// se a nota foi excluida	
	  	If nImpExclu == 1 .AND. nNFAnt <> nil .AND. nLivro <> 1 .AND. (cAliasSF3)->F3_FORMUL == 'S'
	  		nAuxNFAtu := val(cNFAtu) 	
	  		for nNum:=nNFAnt+1 to nAuxNFAtu-1     
			  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Impressao do cabecalho do relatorio    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 	AADD(aDados,{"","",STR0052,Iif(Empty((cAliasSF3)->F3_SERIE),padr(strzero(nNum, len((cAliasSF3)->F3_NFISCAL)), len((cAliasSF3)->F3_NFISCAL)),padr(strzero(nNum, len((cAliasSF3)->F3_NFISCAL)), len((cAliasSF3)->F3_PASSAGE))+SPACE(4)),; ///-> tirar a série
			 				"","","","","","","","",cChaveSf3 })
			next                                                                                                                            
	 	Endif        
	    
	    // verifica se a nota deve ser impressa no livro escolhido
	   	If lImprime(nLivro, (cAliasSF3)->F3_TIPOMOV, ALLTRIM((cAliasSF3)->F3_ESPECIE))    
		 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do cabecalho do relatorio    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( nLin > 56 .Or. nLin == 0 )
		 		If (aTotPar[2]+aTotPar[3]+aTotPar[4]+aTotPar[5]+aTotPar[6]) > 0
					FmtLin(,aL[01],,,@nLin)
					FmtLin(aTotPar,aL[04],,,@nLin)		//Parciais
					FmtLin({"",""},aL[06],,,@nLin)
					aSubTot:=aTotGer
					FmtLin(aSubTot,aL[09],,,@nLin)		//Totais
					FmtLin({"",""},aL[08],,,@nLin)	
					aTotPar	:= {OemToAnsi(STR0008),0,0,0,0,0}		//Totais Parciais
				Endif
				nLin := CabecRel(nLivro,@cFolha)
			Endif
			// verifica se a nota nao foi anulada
		    if empty((cAliasSF3)->F3_DTCANC)    

		   	  	If Valtype(cEmissNF)=="D"
		   			cEmissNF := Strzero(Day(cEmissNF),2)+"/"+Strzero(Month(cEmissNF),2)+"/"+Strzero(Year(cEmissNF),4)
		   		ElseIf Valtype(cEmissNF)=="C"
			   		cEmissNF := Substr(cEmissNF,7,2)+"/"+Substr(cEmissNF,5,2)+"/"+Substr(cEmissNF,1,4)
		   		EndIf
		   		
	   			nPos := Ascan(aDados,{|x|x[12]==cChaveSf3})
				If nPos > 0
					aDados[nPos,07] += (cAliasSF3)->F3_VALCONT                                  				//07 Total da Nota Fiscal (A)
					aDados[nPos,08] += Iif(lVALIMP,FieldGet(FieldPos("F3_VALIMP"+mv_par08)),0) 				//08 Total ICE. (B)
					aDados[nPos,09] += (cAliasSF3)->F3_EXENTAS													//09 Total Importes Exentos (C)          
			   
            	If aImpostos[1][3] > 0 .AND. (cAlias)->F3_VALIMP5 == 0 //Importe Neto (A-B-C)
	                	aDados[nPos, 10] := (cAlias)->(FieldGet(aImpostos[1][3]))
	            Elseif (cAlias)->F3_VALIMP5 > 0
		                aDados[nPos, 10] := (cAlias)->F3_VALCONT-(cAlias)->F3_VALIMP5
             	Else 
	                	aDados[nPos, 10] := 0
            	Endif					
					 
					
				   //	aDados[nPos,10] += Iif(aImpostos[1][3] > 0,(cAliasSF3)->(FieldGet(aImpostos[1][3])),0)	//10 Importe Neto (A-B-C)
					aDados[nPos,11] += Iif(aImpostos[1][4] > 0,(cAliasSF3)->(FieldGet(aImpostos[1][4])),0)	//11 Credito Fiscal IVA
				Else
					AADD(aDados,{Iif((MV_PAR11==1 .And. nLivro == 1),(cAliasSF3)->F3_ENTRADA,cEmissNF),; 		//01 Data
									cNIT,;                                                                 		//02 Numero de NiT
									cRazSoc,; 															   		//03 Nome Cli/For
							   	    Iif(lImport,padr(cNFAtu,len(SF1->F1_NUMDES)),  Iif(!Empty((cAliasSF3)->F3_SERIE),padr(cNFAtu,len((cAliasSF3)->F3_PASSAGE)) + SPACE(4),padr(cNFAtu,len((cAliasSF3)->F3_PASSAGE)))    ),; ///-> tirar a série
									Replicate(" ",15-LEN(AllTrim(cAutoriz))) + AllTrim(cAutoriz),;				// 05 Numero de Autorizacao - (cAliasSF3)->F3_NUMAUT
							   	    Iif(!empty((cAlias)->F3_DTCANC), '0', Iif(Empty((cAliasSF3)->F3_CODCTR),Replicate(" ",14),Replicate(" ",14-LEN(AllTrim((cAliasSF3)->F3_CODCTR))) + AllTrim((cAliasSF3)->F3_CODCTR))),;
							   	    (cAliasSF3)->F3_VALCONT,;													//07 Total da Nota Fiscal (A)
							   	    Iif(lVALIMP,FieldGet(FieldPos("F3_VALIMP"+mv_par08)),0),;					//08 Total ICE. (B)
							   	    (cAliasSF3)->F3_EXENTAS,; 													//09 Total Importes Exentos (C)            							   	           										   	    
							   	    Iif(aImpostos[1][3]>0 .And. (cAliasSF3)->F3_VALIMP5 == 0, (cAliasSF3)->(FieldGet(aImpostos[1][3])), Iif((cAliasSF3)->F3_VALIMP5 > 0, (cAliasSF3)->F3_VALCONT-(cAliasSF3)->F3_VALIMP5,0)),;	//10 Importe Neto (A-B-C)												,;
									Iif(aImpostos[1][4] > 0,(cAliasSF3)->(FieldGet(aImpostos[1][4])),0),;		//11 Credito Fiscal IVA
									cChaveSf3}) 																//12 Chave   
				EndIf                
		   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   		//³ Imprime dados da Nota Fiscal           ³
		   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   	//	FmtLin(aDados,aL[03],,,@nLin)			   
			Else // se a nota foi anulada  
				If nImpExclu == 1
					AADD(aDados,{Iif((MV_PAR11==1 .And. nLivro == 1),(cAliasSF3)->F3_ENTRADA,cEmissNF),cNIT,cRazSoc, ;
					     Iif(Empty((cAliasSF3)->F3_SERIE),padr(cNFAtu,len(F3_PASSAGE)),padr(cNFAtu,len(F3_PASSAGE))+ SPACE(4)),;   ///-> tirar a série
			 				"","0","0.00","","","0.00","0.00","",cChaveSf3 })        
		   		Endif	     
			Endif                                               
		    
	 	    If (cAliasSF3)->F3_FORMUL == 'S'
			    // na proxima rodada do while nNFAnt tera o valor da nota fiscal anterior
				nNFAnt := val(cNFAtu)       
			Endif
		Else // caso a nota nao seja do livro especificado a numeracao avanca para q neste livro nao seja impressa como excluida
			If (cAliasSF3)->F3_FORMUL == 'S'
				nNFAnt := val(cNFAtu)
				nNFAnt++   
			Endif
		Endif
		
		If (cAliasSF3)->F3_FORMUL = 'S'
		    // ultima data da nota da serie anterior
		    // cDatNFAnt := (cAliasSF3)->F3_EMISSAO
		    // na proxima rodada do while cSerieAnt tera o valor da serie da nota fiscal anterior  
			cSerieAnt := (cAliasSF3)->F3_SERIE
		Endif
		
		dbSelectArea(cAliasSF3)
		(cAliasSF3)->(dbSkip())
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime dados da Nota Fiscal           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nx := 1 to len(aDados)
		If ( nLin > 56 .Or. nLin == 0 )
			If (aTotPar[2]+aTotPar[3]+aTotPar[4]+aTotPar[5]+aTotPar[6]) > 0
				FmtLin(,aL[01],,,@nLin)
				FmtLin(aTotPar,aL[04],,,@nLin)		//Parciais
				FmtLin({"",""},aL[06],,,@nLin)
				aSubTot:=aTotGer
				FmtLin(aSubTot,aL[09],,,@nLin)		//Totais
				FmtLin({"",""},aL[08],,,@nLin)	
				aTotPar	:= {OemToAnsi(STR0008),0,0,0,0,0}		//Totais Parciais				
		  	Endif
			nLin := CabecRel(nLivro,@cFolha)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aculadores Totais ( Parcial e Geral )  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Total da Nota Fiscal	
		If Valtype(aDados[nx,07])=="N"
			aTotPar[2] += aDados[nx,07]
			aTotGer[2] += aDados[nx,07]
		EndIf
		//Total ICE
		If Valtype(aDados[nx,08])=="N"
			aTotPar[3] += aDados[nx,08]
			aTotGer[3] += aDados[nx,08]
		EndIf		
		//Total Importes Exentos
		If Valtype(aDados[nx,09])=="N"
			aTotPar[4] += aDados[nx,09]
			aTotGer[4] += aDados[nx,09]
		EndIf
		//Total Importe Neto   
		If Valtype(aDados[nx,10])=="N"
			aTotPar[5] += aDados[nx,10]
			aTotGer[5] += aDados[nx,10]
		EndIf
		//Total Credito Fiscal IVA
		If Valtype(aDados[nx,11])=="N"
			aTotPar[6] += aDados[nx,11]
			aTotGer[6] += aDados[nx,11]  
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Relatorio      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FmtLin(aDados[nx],aL[03],,,@nLin)	
	next

	If (aTotPar[2]+aTotPar[3]+aTotPar[4]+aTotPar[5]+aTotPar[6]) > 0
		FmtLin(,aL[01],,,@nLin)
		FmtLin(aTotPar,aL[04],,,@nLin)		//Parciais
		FmtLin({cRG,cResp},aL[06],,,@nLin)
		FmtLin(aTotGer,aL[07],,,@nLin)		//Totais
		FmtLin({OemToAnsi(STR0026),Upper(OemToAnsi(STR0030))},aL[08],,,@nLin)	
	EndIf                     
	  
	SM0->(DbSkip())		
Enddo	// end while de filiais

SM0->(RestArea(aAreaSM0))
cFilAnt := SM0->M0_CODFIL

If lQuery  
	dbSelectArea(cAlias)
	dbCloseArea()
Else 
  	dbSelectArea("SF3")
	RetIndex("SF3")
	dbClearFilter()
	Ferase(cIndexSF3+OrdBagExt())
Endif
	
If aReturn[5]==1
   dbCommitAll()
   Set Printer To
   OurSpool(wnRel)
Endif

MS_FLUSH() 

// deleta a tabela temporaria
If nLivro == 1	//Compras  
	If !Empty(cAliasSF3)
		DbSelectArea(cAliasSF3)
		DbCloseArea()

		If oTmpTable <> Nil   //JGR
			oTmpTable:Delete()  //JGR
			oTmpTable := Nil //JGR
		Endif //JGR
		DbSelectArea("SF3")
	EndIf
Endif	
Return Nil 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CabecRel   ³Autor ³ Sergio S. Fuzinaka    ³ Data ³ 25.06.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cabecalho do Relatorio                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CabecRel(nLivro,cFolha)

Local nLin		:= 0
Local cMesini	:= StrZero(Month(mv_par02),2)	
Local cAnoini	:= StrZero(Year(mv_par02),4)  

nLin := 1
If nLivro == 1	//Compras
	@ nLin, 001 PSay Upper(OemToAnsi(STR0019))+"  "+cMesini+"/"+cAnoini//+" - "+cMesfim+"/"+cAnofim
Else
	@ nLin, 001 PSay Upper(OemToAnsi(STR0020))+"  "+cMesini+"/"+cAnoini//+" - "+cMesfim+"/"+cAnofim
Endif 	         
cFolha := soma1(cFolha,3) 
@ nLin, 197 PSay Upper(OemToAnsi(STR0021))+cFolha
nLin := (nLin+3)
@ nLin, 001 PSay Upper(OemToAnsi(STR0022))+SM0->M0_NOMECOM
@ nLin, 150 PSay Upper(OemToAnsi(STR0023))+SM0->M0_CGC
nLin := (nLin+1)                     
@ nLin, 001 PSay Upper(OemToAnsi(STR0024))+SM0->M0_FILIAL  //CalcXFil(cFilAnt) 
@ nLin, 025 PSay Upper(OemToAnsi(STR0025))+SM0->M0_ENDENT
nLin := (nLin+2)
FmtLin(,aL[02],,,@nLin)
@ nLin, 000 PSay Upper(OemToAnsi(STR0003))
nLin := (nLin+1)
FmtLin(,aL[01],,,@nLin)
if nLivro == 1	//Compras
	@ nLin, 000 PSay Upper(OemToAnsi(STR0006))
	nLin := (nLin+1)
	@ nLin, 000 PSay Upper(OemToAnsi(STR0007))
	nLin := (nLin+1)
else
	@ nLin, 000 PSay Upper(OemToAnsi(STR0031))
	nLin := (nLin+1)
	@ nLin, 000 PSay Upper(OemToAnsi(STR0032))
	nLin := (nLin+1)
endif
FmtLin(,aL[01],,,@nLin)     
 
Return( nLin )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CabecRel   ³Autor ³ Fernando Separovic    ³ Data ³ 25.06.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se uma nota deve ou nao ser impressa               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/         
Static Function lImprime(nLivro, cTipoMov, cEspecie)  

	Local lImpressao := .F.

	If nLivro == 1 // compras
		If cTipoMov == "C" .AND. cEspecie <> "NCP" ;
						   .AND. cEspecie <> "NCI" ;
						   .AND. cEspecie <> "NDP" ;
						   .AND. cEspecie <> "NDI" 
			lImpressao := .T.
		Else    
			If cTipoMov == "V" .AND. (cEspecie == "NCC" .OR. ;
			                          cEspecie == "NCE" .OR. ;
							          cEspecie == "NDC" .OR. ;
							          cEspecie == "NDE") 
				lImpressao := .T.
			Else
				lImpressao := .F.  
			Endif
		Endif
	Else
		If cTipoMov == "V" .AND. cEspecie <> "NCC" ;
		                   .AND. cEspecie <> "NCE" ;
						   .AND. cEspecie <> "NDC" ;
						   .AND. cEspecie <> "NDE" 
			lImpressao := .T.
		Else 
			If cTipoMov == "C" .AND. (cEspecie == "NCP" .OR. ;
			                          cEspecie == "NCI" .OR. ;
						              cEspecie == "NDP" .OR. ;
						              cEspecie == "NDI")
				lImpressao := .T.
			Else
		   		lImpressao := .F.
	   		Endif  
	   	Endif              	
	Endif
	
	return lImpressao

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LayOut     ³Autor ³ Sergio S. Fuzinaka    ³ Data ³ 25.06.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Layout do Relatorio                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LayOut(aL)

aL[01] := "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aL[02] := "                                                                                                                                +------------------------------------------------------------------------------------+"
aL[03] := "| ########## | ############### | ######################################## | ################ | ############### | ############## |############### |############### |############### |############### |############### |"
aL[04] := "                                                                                                               | ############## |############### |############### |############### |############### |############### |"
aL[05] := "                                                                                                               +-----------------------------------------------------------------------------------------------------+"
aL[06] := " ####################   ######################################################                                 +-----------------------------------------------------------------------------------------------------+"
aL[07] := " --------------------   ------------------------------------------------------                                 | ############## |############### |############### |############### |############### |############### |"
aL[08] := "         ####                      ###############################                                             +-----------------------------------------------------------------------------------------------------+"
aL[09] := "                                                                                                               | ############## |############### |############### |############### |############### |############### |"

Return Nil
