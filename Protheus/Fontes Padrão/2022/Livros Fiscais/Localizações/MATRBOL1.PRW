#Include "Protheus.Ch"
#Include "MatrBol1.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MATRBOL1  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 18.07.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³RDMAKE do Livros de Compras/Vendas IVA                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Bolivia                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³06/07/15³PCREQ-4256³Se elimina la funcion AjustaSX1() la  ³±±
±±³            ³        ³          ³hace modificacion a SX1 por motivo de ³±±
±±³            ³        ³          ³adecuacion a fuentes a nuevas estruc- ³±±
±±³            ³        ³          ³turas SX para Version 12.             ³±±
±±³M.Camargo   ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8		           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MatrBol1()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTitulo	:= OemToAnsi(STR0001)	//"Livro IVA de Compras/Vendas"
Local cDescr1	:= OemToAnsi(STR0002)	//"Este programa tem como objetivo imprimir o relatorio Livro IVA de Compras/Vendas"
Local cPerg	 	:= "MTRBO1"
Local cNomeProg	:= "MATRBOL1" 
Local cString	:= "SF3"

Private cTam	:= "G"
Private lEnd	:= .F.
Private aReturn	:= {STR0004, 1, STR0005, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey:= 0
Private m_pag	:= 1
Private wnRel	:= ""
Private aL		:= Array(8)

If cPaisLoc == "BOL" .And. LocBol()
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

Local cFiltro	:= ""
Local cAlias	:= "SF3"
Local nLivro	:= mv_par01			//Livro: 1-Compras ou 2-Vendas
Local dDtIni	:= mv_par02
Local dDtFim	:= mv_par03
Local cRG		:= mv_par04
Local cResp		:= Upper(mv_par05)
Local cCondicao	:= ""
Local cIndex	:= ""                                 
Local nIndex	:= 0
Local cDebug	:= ""
Local lQuery	:= .F.
Local aDados	:= Array(11)
Local cRazSoc	:= ""
Local cNIT		:= ""
Local nTotGer	:= 0
Local nLin		:= 0
Local nFolha	:= 0
Local aImpostos	:= {}
Local aTotPar	:= {OemToAnsi(STR0008),0,0,0,0,0}		//Totais Parciais
Local aTotGer	:= {OemToAnsi(STR0009),0,0,0,0,0}		//Totais Gerais  
Local cOrdem	:= ""
Local lPassag 	:= 	cPaisLoc == "BOL" .And. GetNewPar("MV_PASSBOL",.F.) .And.;
					SF3->(FieldPos("F3_COMPANH")) > 0 .And. ;
					SF3->(FieldPos("F3_LOJCOMP")) > 0 .And. ;
					SF3->(FieldPos("F3_PASSAGE")) > 0 .And. ;
					SF3->(FieldPos("F3_DTPASSA")) > 0 .And. ;
					SF1->(FieldPos("F1_COMPANH")) > 0 .And. ;
					SF1->(FieldPos("F1_LOJCOMP")) > 0 .And. ;
					SF1->(FieldPos("F1_PASSAGE")) > 0 .And. ;
					SF1->(FieldPos("F1_DTPASSA")) > 0

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

If lQuery
	cCondicao := "%"
	cCondicao += IIf(nLivro == 1,"F3_TIPOMOV = 'C' AND","F3_TIPOMOV = 'V' AND")
	cCondicao += "%"

	cAlias := GetNextAlias()  
	
		If (nLivro == 1 .And. mv_par06 == 2) .Or. nLivro == 2
		cFiltro	+= "Dtos(F3_EMISSAO) >= '"+Dtos(dDtIni)+"' .And. "
		cFiltro	+= "Dtos(F3_EMISSAO) <= '"+Dtos(dDtFim)+"'" 
	
		BeginSql Alias cAlias
			Column F3_EMISSAO as Date
			Column F3_ENTRADA as Date
			SELECT *
			FROM %Table:SF3% SF3
			WHERE F3_FILIAL = %Exp:xFilial("SF3")% AND 
				F3_EMISSAO >= %Exp:dDtIni% AND 
				F3_EMISSAO <= %Exp:dDtFim% AND 
				%exp:cCondicao%
				SF3.%NotDel% 
			ORDER BY F3_FILIAL,F3_EMISSAO,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_CFO,F3_ALIQICM
		EndSql 
		
	Else
		cFiltro	+= "Dtos(F3_ENTRADA) >= '"+Dtos(dDtIni)+"' .And. "
		cFiltro	+= "Dtos(F3_ENTRADA) <= '"+Dtos(dDtFim)+"'"  

		
		BeginSql Alias cAlias
			Column F3_ENTRADA as Date
			Column F3_EMISSAO as Date
			SELECT *
			FROM %Table:SF3% SF3
			WHERE F3_FILIAL = %Exp:xFilial("SF3")% AND 
				F3_ENTRADA >= %Exp:dDtIni% AND 
				F3_ENTRADA <= %Exp:dDtFim% AND 
				%exp:cCondicao%
				SF3.%NotDel% 
			ORDER BY F3_FILIAL,F3_ENTRADA,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_CFO,F3_ALIQICM
		EndSql 
	
	EndIf
		
	cDebug := GetLastQuery()[2]		//Para debugar a query
	
Else
	cIndex	:= CriaTrab(Nil,.F.)
	cFiltro	:= "F3_FILIAL == '"+ xFilial("SF3") + "' .And. "
	cFiltro += IIf(nLivro == 1,"F3_TIPOMOV == 'C'","F3_TIPOMOV == 'V'")+" .And. "
	If (nLivro == 1 .And. mv_par06 == 2) .Or. nLivro == 2
	 	cFiltro	+= "Dtos(F3_EMISSAO) >= '"+Dtos(dDtIni)+"' .And. "
		cFiltro	+= "Dtos(F3_EMISSAO) <= '"+Dtos(dDtFim)+"'"                                    
		cOrdem := "F3_FILIAL+Dtos(F3_EMISSAO)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM)"
   
   	Else
		cFiltro	+= "Dtos(F3_ENTRADA) >= '"+Dtos(dDtIni)+"' .And. "
		cFiltro	+= "Dtos(F3_ENTRADA) <= '"+Dtos(dDtFim)+"'"
		cOrdem := "F3_FILIAL+Dtos(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM)"
   		Endif

	IndRegua(cAlias,cIndex,cOrdem,,cFiltro,STR0017) //"Selecionando registros..."
	nIndex := RetIndex("SF3")
	dbSetIndex(cIndex+OrdBagExt())
	dbSetOrder(nIndex+1)
	dbGoTop()	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta array de com os itens do SF3          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
SetRegua(RecCount())

aItens := {}
While !(cAlias)->(Eof())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aborta impressao                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lEnd
		Exit
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( nLin > 60 .Or. nLin == 0 )
		If (aTotPar[2]+aTotPar[3]+aTotPar[4]+aTotPar[5]+aTotPar[6]) > 0
			FmtLin(,aL[01],,,@nLin)
			FmtLin(aTotPar,aL[04],,,@nLin)		//Parciais
			aTotPar	:= {OemToAnsi(STR0008),0,0,0,0,0}		//Totais Parciais
			FmtLin(,aL[05],,,@nLin)
		Endif
		nLin := CabecRel(nLivro,@nFolha)
	Endif


	If !Empty((cAlias)->F3_RAZSOC) 
		cRazSoc := (cAlias)->F3_RAZSOC
		cNIT	:= (cAlias)->F3_NIT
	Else	

		If nLivro == 1	//Compras
			If (cAlias)->F3_TIPO <> "B"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se as informacoes da companhia area estao preenchidas.³
				//³Se sim, os dados no livro devem ser da companhia aerea.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lPassag .And. !Empty((cAlias)->F3_COMPANH) .And. !Empty((cAlias)->F3_LOJCOMP)
					cRazSoc := Posicione("SA2",1,xFilial("SA2")+(cAlias)->F3_COMPANH+(cAlias)->F3_LOJCOMP,"A2_NOME")
					cNIT	:= Posicione("SA2",1,xFilial("SA2")+(cAlias)->F3_COMPANH+(cAlias)->F3_LOJCOMP,"A2_CGC")
				Else 
					cRazSoc := Posicione("SA2",1,xFilial("SA2")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA,"A2_NOME")
					cNIT	:= Posicione("SA2",1,xFilial("SA2")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA,"A2_CGC")
				Endif
			Else                
				cRazSoc := Posicione("SA1",1,xFilial("SA1")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA,"A1_NOME")
				cNIT	:= Posicione("SA1",1,xFilial("SA1")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA,"A1_CGC")
			EndIf	
		Else
			If (cAlias)->F3_TIPO <> "B"
				cRazSoc := Iif(Trim((cAlias)->F3_DTCANC) <> '', 'A N U L A D A', Posicione("SA1",1,xFilial("SA1")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA,"A1_NOME"))
				cNIT	:= Iif(Trim((cAlias)->F3_DTCANC) <> '', '0', Posicione("SA1",1,xFilial("SA1")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA,"A1_CGC"))
			Else                
				cRazSoc := Posicione("SA2",1,xFilial("SA2")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA,"A2_NOME")
				cNIT	:= Posicione("SA2",1,xFilial("SA2")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA,"A2_CGC")
			EndIf	
		Endif	

	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados da Nota Fiscal                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDados[01] := Iif((MV_PAR06==2 .And. nLivro == 1) .Or. nLivro == 2,(cAlias)->F3_EMISSAO,(cAlias)->F3_ENTRADA)   
	aDados[02] := cNIT
	aDados[03] := cRazSoc
	aDados[04] := (cAlias)->F3_NFISCAL
	aDados[05] := (cAlias)->F3_NUMAUT					//Numero de Autorizacao
	If Empty((cAlias)->F3_CODCTR)						//Codigo de Controle
		aDados[06] := ""
	Else
		aDados[06] := Iif(Trim((cAlias)->F3_DTCANC) <> '', '0', (cAlias)->F3_CODCTR)
	Endif
	aDados[07] := Iif(Trim((cAlias)->F3_DTCANC) <> '', 0, (cAlias)->F3_VALCONT)		//Total da Nota Fiscal (A)
	aDados[08] := (cAlias)->F3_VALIMP5		//Total ICE. (B)
	aDados[09] := (cAlias)->F3_EXENTAS		//Total Importes Exentos (C)

	If aImpostos[1][3] > 0 .AND. (cAlias)->F3_VALIMP5 == 0 //Importe Neto (A-B-C)
		aDados[10] := Iif(Trim((cAlias)->F3_DTCANC) <> '', 0, (cAlias)->(FieldGet(aImpostos[1][3])))
	Elseif (cAlias)->F3_VALIMP5 > 0
		aDados[10] := Iif(Trim((cAlias)->F3_DTCANC) <> '', 0, (cAlias)->F3_VALCONT-(cAlias)->F3_VALIMP5)
	Else 
		aDados[10] := 0
	Endif

	If aImpostos[1][4] > 0					//Credito Fiscal IVA
		aDados[11] := Iif(Trim((cAlias)->F3_DTCANC) <> '', 0, (cAlias)->(FieldGet(aImpostos[1][4])))
	Else
		aDados[11] := 0
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aculadores Totais ( Parcial e Geral )  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Total da Nota Fiscal	
	aTotPar[2] += aDados[07]
	aTotGer[2] += aDados[07]
	//Total ICE
	aTotPar[3] += aDados[08]
	aTotGer[3] += aDados[08]
	//Total Importes Exentos
	aTotPar[4] += aDados[09]
	aTotGer[4] += aDados[09]
	//Total Importe Neto
	aTotPar[5] += aDados[10]
	aTotGer[5] += aDados[10]
	//Total Credito Fiscal IVA
	aTotPar[6] += aDados[11]
	aTotGer[6] += aDados[11]
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime dados da Nota Fiscal           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FmtLin(aDados,aL[03],,,@nLin)	
	
	dbSelectArea(cAlias)
	(cAlias)->(dbSkip())
EndDo	

If (aTotPar[2]+aTotPar[3]+aTotPar[4]+aTotPar[5]+aTotPar[6]) > 0
	FmtLin(,aL[01],,,@nLin)
	FmtLin(aTotPar,aL[04],,,@nLin)		//Parciais
	FmtLin({cRG,cResp},aL[06],,,@nLin)
	FmtLin(aTotGer,aL[07],,,@nLin)		//Totais
	FmtLin({OemToAnsi(STR0026),Upper(OemToAnsi(STR0030))},aL[08],,,@nLin)	
EndIf                     

If lQuery
	dbSelectArea(cAlias)
	dbCloseArea()
Else
  	dbSelectArea("SF3")
	RetIndex("SF3")
	dbClearFilter()
	Ferase(cIndex+OrdBagExt())
Endif
	
If aReturn[5]==1
   dbCommitAll()
   Set Printer To
   OurSpool(wnRel)
Endif

MS_FLUSH()
	
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
Static Function CabecRel(nLivro,nFolha)

Local nLin		:= 0
Local cMes		:= StrZero(Month(mv_par02),2)	
Local cAno		:= StrZero(Year(mv_par02),4)

nLin := 1
If nLivro == 1	//Compras
	@ nLin, 001 PSay Upper(OemToAnsi(STR0019))+"  "+cMes+"/"+cAno
Else
	@ nLin, 001 PSay Upper(OemToAnsi(STR0020))+"  "+cMes+"/"+cAno
Endif	
@ nLin, 197 PSay Upper(OemToAnsi(STR0021))+StrZero(++nFolha,4)
nLin := (nLin+3)
@ nLin, 001 PSay Upper(OemToAnsi(STR0022))+SM0->M0_NOMECOM
@ nLin, 150 PSay Upper(OemToAnsi(STR0023))+SM0->M0_CGC 
nLin := (nLin+1)
@ nLin, 001 PSay Upper(OemToAnsi(STR0024))+cFilAnt
@ nLin, 025 PSay Upper(OemToAnsi(STR0025))+SM0->M0_ENDENT
nLin := (nLin+2)
FmtLin(,aL[02],,,@nLin)
@ nLin, 000 PSay Upper(OemToAnsi(STR0003))
nLin := (nLin+1)
FmtLin(,aL[01],,,@nLin)
If nLivro == 1	//Compras
   @ nLin, 000 PSay Upper(OemToAnsi(STR0006)) 
Else    	//Vendas
   @ nLin, 000 PSay Upper(OemToAnsi(STR0036)) 
Endif	
nLin := (nLin+1)
@ nLin, 000 PSay Upper(OemToAnsi(STR0007))
nLin := (nLin+1)
FmtLin(,aL[01],,,@nLin)

Return( nLin )

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

aL[01] := 	"+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aL[02] := 	"                                                                                                                          +------------------------------------------------------------------------------------+"
// STR0006	"|          |                 |                                          |  NUMERO DE   |    NUMERO DE    |     CODIGO     |     TOTAL      |      TOTAL     |    VALORES     |     VALOR      |     CREDITO    |"
// STR0007	"|   FECHA  |  NUMERO DE NIT  | NOMBRE O RAZON SOCIAL                    |  FACTURA     |   AUTORIZACION  |  DE CONTROL    | FACTURA (A)    |    I.C.E. (B)  |   EXENTOS (C)  | NETO (A-B-C)   |  FISCAL I.V.A. |"
aL[03] := 	"| ######## | ############### | ######################################## | ############ | ############### | ############## |############### |############### |############### |############### |############### |"
aL[04] := 	"                                                                                                         | ############## |############### |############### |############### |############### |############### |"
aL[05] := 	"                                                                                                         +-----------------------------------------------------------------------------------------------------+"
aL[06] := 	" ####################   ######################################################                           +-----------------------------------------------------------------------------------------------------+"
aL[07] := 	" --------------------   ------------------------------------------------------                           | ############## |############### |############### |############### |############### |############### |"
aL[08] := 	"         ####                      ###############################                                       +-----------------------------------------------------------------------------------------------------+"

Return Nil

