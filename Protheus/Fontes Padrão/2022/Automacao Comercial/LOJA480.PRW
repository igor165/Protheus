#INCLUDE "LOJA480.CH"
#INCLUDE "PROTHEUS.CH"

//Posicoes do array aItens
#DEFINE _PRODUTO   1
#DEFINE _QUANT	    2
#DEFINE _PRCVEN    3
#DEFINE _TOTAL	    4
#DEFINE _TES       5
#DEFINE _CF  	    6
#DEFINE _PRUNIT    7
#DEFINE _DESCON	    8
#DEFINE _LOCAL     9
#DEFINE _IMPOSTOS  10  //Array de Impostos
#DEFINE _IMPSEPAR  11  

//Posicao dos impostos nos arrays aCabecalho e aItens
#DEFINE _CODIMP    1
#DEFINE _CPOBASE   2
#DEFINE _CPOVALOR  3
#DEFINE _CPOALIQ   4
#DEFINE _BASIMP    5
#DEFINE _VLRIMP    6
#DEFINE _ALQIMP    7
#DEFINE _INCNOTA   8

//Posicoes do array aCabecalho
#DEFINE _CLIENTE   1
#DEFINE _LOJA	    2
#DEFINE _EMISSAO   3
#DEFINE _VLRBRUT	4
#DEFINE _VLRMERC   5
#DEFINE _IMPCABEC  6  //Array de Impostos
#DEFINE _DESCONTO  7

//Posicoes do array aLivro
#DEFINE _LFTES     1
#DEFINE _LFCF      2
#DEFINE _LFALQIMP  3
#DEFINE _LFVALCONT 4

Static nMaxItens   	:= If(Empty(SuperGetMV("MV_NUMITEN")),999,SuperGetMV("MV_NUMITEN")) 	// Conteudo do parametro MV_NUMITEN
Static aNumGlobs   	:= {}																    // Numero das faturas globais
Static oTempTable	:= Nil 																	//Objeto tabela temporaria

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LOJA480	³ Autor ³ Vendas Clientes       ³ Data ³ 12/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geracao da fatura global(Loc. Mexico)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Loja480()     											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programador ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³27.09.17³DMINA-725  ³Se modifica grupo de preguntas LJA480³±±
±±³            ³        ³MEXICO     ³para captura de datos Uso CFDi, Tipo ³±±
±±³            ³        ³           ³de relación y uuids relacionados, mis³±±
±±³            ³        ³           ³mos que son guardados en los campos  ³±±
±±³            ³        ³           ³F2_USOCFDI, F2_RELSAT y  F2_UUIDREL  ³±±
±±³            ³        ³           ³dentro de la función Lj480Grava.     ³±±
±±³  Marco A.  ³06/03/18³DMINA-726  ³Se replican para V12.1.17, issues:   ³±±
±±³            ³        ³           ³ DMINA-64, DMINA-445, DMINA-871,     ³±±
±±³            ³        ³           ³ DMINA-817, DMINA-1082 y DMINA-1337; ³±±
±±³            ³        ³           ³ para Esquema CFDI 3.3 (MEX)         ³±±
±±³LuisEnríquez³26/06/18³DMINA-2624 ³Número de presupuesto (L1_NUM) en    ³±±
±±³            ³        ³(MEX)      ³código de producto para informar en  ³±±
±±³            ³        ³           ³atributo NoIdentificacion del CFDI.  ³±±
±±³            ³        ³           ³Reestablecer generación de arreglo de³±±   
±±³            ³        ³           ³ítems, sumarizando según MV_GLAGLUT, ³±±
±±³            ³        ³           ³el cual debe configurarse = "1".     ³±±
±±³            ³        ³           ³Informar total descuento en enc. NF  ³±±
±±³            ³        ³           ³SF2 y xml.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Loja480()
Local nTipoOper		:= 1
Local cPerg			:= "LJA480"
Local cProdGen		:= ""
Local dData   
Local lGeraGlobal	:= .T.
Local aArea			:= GetArea()

Private cUsoCFDI	:= ""
Private cRelSAt		:= ""
Private cUUIDRel	:= ""

//Verifica o conteudo configurado no parametro MV_NUMITEN, pois nao eh permitindo configurar mais que 1061 (que eh o limite possivel de '01' a 'ZZ' para o campo D2_ITEM)
If TamSx3("D2_ITEM")[1] == 2 .And. nMaxItens > 1061
	MsgAlert(STR0034+" 1061") //"O valor configurado no parâmetro MV_NUMITEN deve ser no máximo" ### " 1061"
	Return Nil
EndiF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis utilizadas para parametros                         ³
//³mv_par01             // Data de Emissao dos Comprovantes     ³
//³mv_par02             // Codigo do Produto Generico           ³
//³mv_par03             // Operacao                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Se o produto generico nao for preenchido gera a Fatura Global com os itens vendidos
If !Pergunte(cPerg,.T.)
   Return (Nil)
Else 
   dData    := mv_par01
   nTipoOper := mv_par03  //1-Gerar ou 2-Excluir
   If cPaisLoc == "MEX"
   	   cUsoCFDI	:= MV_PAR04
       cRelSAT	:= MV_PAR05
       cUUIDRel	:= MV_PAR06
   EndIF
   If dData != dDatabase
      Aviso(STR0031,STR0024,{OemtoAnsi(STR0030)})  //"Atencao###""Nao e possivel gerar/excluir Fatura Global com data distinta da Database!"###"OK"
      Return (Nil)      
   EndIf   
EndIf
cProdGen := mv_par02

If nTipoOper == 1
	DbSelectArea("SF3")
	DbSetOrder(1) 
	If DbSeek(xFilial()+DToS(dData))
		DbSelectArea("SF2")
		DbSetOrder(1)
		While SF3->(!Eof()) .AND. xFilial() == SF3->F3_FILIAL .AND. DTOS(dData) == DTOS(SF3->F3_ENTRADA) .AND. lGeraGlobal
			If SF3->F3_TIPOMOV == "V" .AND. SF3->F3_TIPO == "N"
				If DbSeek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA)
					If SF2->F2_GLOBAL == "1"  //Jah foi gerada Fatura Global para a data desejada
						lGeraGlobal  := .F.
					EndIf
				EndIf
			EndIf
			SF3->(DbSkip())
		End
	EndIf
EndIf

If lGeraGlobal
   Lj480Global(dData,cProdGen,nTipoOper)
Else
   Aviso(STR0031,STR0002+DToC(dData)+STR0003,{OemtoAnsi(STR0030)})  //"Atencao"###"A Fatura Global do dia "###" ja foi gerada!"###"OK"
EndIf   

RestArea(aArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj480Global  ³ Autor ³ Vendas Clientes       ³ Data ³ 12/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geracao da Fatura Global a partir dos comprovantes do dia     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj480Global(dData,cProduto,nTipoOper)						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data de emissao dos comprovantes					     ³±±
±±³          ³ ExpC2 = Codigo do produto generico      					     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj480Global(dData,cProduto,nTipoOper)
Local nPosItem  	:= 0
Local nPosImps  	:= 0
Local nItem     	:= 0
Local nX			:= 0
Local nY        	:= 0
Local nValBrut  	:= 0
Local nValMerc  	:= 0
Local nValImps  	:= 0
Local nTaxaMoeda	:= 1
Local nTamCodCli  	:= TamSx3("A1_COD")[1]
Local nTamCodLoja 	:= TamSx3("A1_LOJA")[1]
Local nCnt      	:= 0  						//Controla a qtde de comprovantes que irao gerar a Fatura Global
Local aRecnoSF2		:= {}						//Recno
Local cIndexSD2 	:= ""
Local cAliasSD2 	:= "SD2"
Local cCampoBase  	:= ""
Local cCampoValor 	:= ""
Local cCampoAliq  	:= ""
Local cNumComprov 	:= ""
Local cSerComprov 	:= ""
Local cChaveSF2   	:= ""
Local lGenerico   	:= !Empty(cProduto)  //Determina se usa produto generico
Local lQuery      	:= .F.
Local lFound      	:= .F.
Local aCabecalho  	:= {}
Local aItens      	:= {}
Local aTesImpInf  	:= {}
Local aRecnosSF2  	:= {}
Local aImpVarSD2  	:= {}
Local aRecnoSF3   	:= {}                                                      
Local aCabAux	  	:= {}					//Cabecalho
Local nAuxCont	  	:= 0					//Auxiliar de contador de Loop
Local lIncluir	  	:= .T.           		//Se inclui no primeiro Loop
Local nPosCab	  	:= 1					//Posicao do Cabecalho
Local cTexNum	  	:= ""					//Texto para a mensagem
Local cTexNumDel  	:= ""					//Texto para a mensagem
Local cNfOrig		:= ""					//Guarda o Numero da Nota Fiscal de Origem
Local cSerOrig		:= ""					//Guarda a Serie da Nota Fiscal de Origem
Local lPergGrCFD 	:= .T. 					//Variavel para controlar se ira ou nao exibir a mensagem perguntando se deseja gerar o CFD (Comprovante Fiscal Digital)
Local lGeraCFD		:= .T.					//Variavel para controlar se continua gerando CFD (Comprovante Fiscal Digital) para os proximos documentos F2_NEXTDOC
Local aMsgCert		:= {}					//Array que será alimentado com as informacoes dos CFDs (Comprovante Fiscal Digital) gerados

//Parametro que determina a forma de aglutinar os produtos na fatura global. Se 1, considera
//apenas codigo do produto e TES. Se 2, considera, alem dos dois anteriores, o preco unitario e
//preco de tabela
Local nOpcSepara  	:= SuperGetMV("MV_GLAGLUT")
#IFDEF TOP
Local cQuery    	:= ""
Local cAliasTRB 	:= "SD2TRB"
#ELSE
Local nIndice
Local cFiltro   	:= ""
Local cChave    	:= ""
#ENDIF

Private cSerie    	:= Space(TamSX3("F2_SERIE")[1])
Private cNumNota  	:= Space(TamSX3("F2_DOC")[1])
Private cCondPg		:= Space(TamSX3("F2_COND")[1])

If nTipoOper == 1  //Gerar
	DbSelectArea("SD2")
	SD2->(DbSetOrder(5)) //D2_FILIAL + DTOS(D2_EMISSAO) + D2_NUMSEQ
	#IFDEF TOP
		lQuery  := .T.
		If TcSrvType() != "AS/400"
			aStruSD2  := dbStruct()
			cAliasSD2 := "SD2TMP"
			lQuery := .T.
			cQuery := "SELECT SD2.* "
			If cPaisLoc == "MEX"
				DbSelectArea("SX3")
				SX3->(DbSetOrder(2)) //X3_CAMPO
				SX3->(DbSeek("L1_NUM"))
				aAdd(aStruSD2, {SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				cQuery += ", L1_NUM "
				DbSelectArea("SD2")
			EndIf
			cQuery += "FROM "+RetSqlName("SD2")+" SD2,"+RetSqlName("SF2")+" SF2,"+RetSqlName("SF4")+" SF4 "
			If cPaisLoc == "MEX"
				cQuery += ", "+RetSqlName("SL1")+" SL1"
			EndIf
			cQuery += "WHERE "
			cQuery += "D2_FILIAL = F2_FILIAL AND "
			cQuery += "D2_DOC = F2_DOC AND "
			cQuery += "D2_SERIE = F2_SERIE AND "
			cQuery += "D2_TIPO = F2_TIPO AND "
			cQuery += "D2_ORIGLAN = 'LO' AND "
			cQuery += "D2_TES = F4_CODIGO AND "
			cQuery += "SD2.D_E_L_E_T_=' ' AND "
			cQuery += "F2_GLOBAL <> '1' AND "
			cQuery += "F2_NFORI = '' AND " 
			cQuery += "F2_NFCUPOM = '' AND "
			cQuery += "F2_FILIAL = '"+xFilial("SF2")+"' AND "
			cQuery += "F2_EMISSAO  = '"+DTOS(mv_par01)+"' AND "
			cQuery += "F2_TIPO = 'N' AND "
			cQuery += "SF2.D_E_L_E_T_=' ' AND "
			cQuery += "F4_FILIAL = '"+xFilial('SF4')+"' AND "
			cQuery += "F4_GLOBAL = '1' AND "
			cQuery += "SF4.D_E_L_E_T_=' '"
			If cPaisLoc == "MEX"
				cQuery += " AND "
				cQuery += "L1_FILIAL = '"+xFilial('SL1')+"' AND "
				cQuery += "L1_DOC = D2_DOC AND "
				cQuery += "L1_SERIE = D2_SERIE AND "
				cQuery += "SL1.D_E_L_E_T_=' '"
			EndIf			
			cQuery += " ORDER BY "+ SqlOrder(SD2->(IndexKey()))
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.T.,.T.)
			For nX := 1 To Len(aStruSD2)
				If aStruSD2[nX,2] != "C"
					TcSetField(cAliasTRB,aStruSD2[nX,1],aStruSD2[nX,2],aStruSD2[nX,3],aStruSD2[nX,4])
				EndIf
			Next nX
			Processa( {|lEnd| Lj480CriaTmp(aStruSD2, cAliasSD2, cAliasTRB)},,STR0004)        //"Organizando registros..."
		Else
			DbSeek(xFilial()+DTOS(mv_par01))
		EndIf
	#ELSE
		cFiltro := "D2_FILIAL=='"+xFilial("SD2")+"'.AND. DTOS(D2_EMISSAO)=='"+DTOS(dData)+"'"
		cFiltro += " .AND. D2_TIPO == 'N'"
		cFiltro += " .AND. D2_ORIGLAN == 'LO'"
		cChave  := SD2->(IndexKey())
		cIndexSD2 := CriaTrab(NIL,.F.)
		
		IndRegua(cAliasSD2,cIndexSD2,cChave,,cFiltro,STR0005)   //"Filtrando registros..."
		nIndice	:=	RetIndex(cAliasSD2)
		dbSetIndex(cIndexSD2+OrdBagExt())
		DbSetOrder(nIndice+1)
	#ENDIF
	
	aCabAux := {SuperGetMv("MV_CLIPADG",,SuperGetMv("MV_CLIPAD")),SuperGetMv("MV_LOJAPAD"),dData}
	
	SA1->(DbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
	SA1->(DbSeek(xFilial("SA1")+Padr(aCabAux[_CLIENTE],nTamCodCli)+Padr(aCabAux[_LOJA],nTamCodLoja)))
	cCondPg := SA1->A1_COND	
	DbSelectArea(cAliasSD2)
	DbGoTop()
	
	While !Eof()
		
		If cPaisLoc == "MEX"
			cProduto  := (cAliasSD2)->L1_NUM
		ElseIf !lGenerico
			cProduto  := (cAliasSD2)->D2_COD
		EndIf
		
		//Filtra o TES que nao eh Global
		#IFNDEF TOP
			SF4->(DbSetOrder(1)) //F4_FILIAL + F4_CODIGO
			If SF4->(DbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
				If SF4->F4_GLOBAL != '1'
					(cAliasSD2)->(DbSkip())
					Loop
				EndIf
			EndIf
		#ENDIF
		//Armazenar os recnos dos comprovantes do SF2 para atualizacao posterior do campo F2_NFORI e F2_SERIORI
		If cNumComprov != (cAliasSD2)->D2_DOC .OR. cSerComprov != (cAliasSD2)->D2_SERIE
			SF2->(DbSetOrder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
			If SF2->(DbSeek(xFilial("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+;
				(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
				
				#IFNDEF TOP
					If SF2->F2_GLOBAL == "1"
						(cAliasSD2)->(DbSkip())
						Loop
					EndIf
					
					If !Empty(SF2->F2_NFORI)
						(cAliasSD2)->(DbSkip())
						Loop
					EndIf 
					
					If !Empty(SF2->F2_NFCUPOM)
						(cAliasSD2)->(DbSkip())
						Loop
					EndIf
				#ENDIF
				While SF2->(!Eof()) .AND. xFilial("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+;
					(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA == SF2->F2_FILIAL+SF2->F2_DOC+;
					SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
					
					If SF2->F2_TIPO  == "N"
						Aadd(aRecnosSF2,SF2->(Recno()))
						cNumComprov  := (cAliasSD2)->D2_DOC
						cSerComprov  := (cAliasSD2)->D2_SERIE
						nCnt++
						Exit
					EndIf
					SF2->(DbSkip())
				End
			Else
				(cAliasSD2)->(DbSkip())
				Loop
			EndIf
		EndIf
		If nOpcSepara == 1  //Aglutina por produto e TES		
			nPosItem  := aScan(aItens,{|x| x[_PRODUTO] == cProduto;
				.AND. x[_TES] == (cAliasSD2)->D2_TES})
		Else  //Aglutina por produto, TES, preco unitario e preco de tabela
			nPosItem  := aScan(aItens,{|x| x[_PRODUTO] == cProduto;
				.AND.	x[_TES] == (cAliasSD2)->D2_TES ;
				.AND.	x[_PRCVEN] ==(cAliasSD2)->D2_PRCVEN;
				.AND.	x[_PRUNIT] ==(cAliasSD2)->D2_PRUNIT})
		Endif
		
		If nPosItem == 0
			Aadd(aItens,{cProduto,(cAliasSD2)->D2_QUANT,(cAliasSD2)->D2_PRCVEN,(cAliasSD2)->D2_TOTAL,;
			(cAliasSD2)->D2_TES,(cAliasSD2)->D2_CF,(cAliasSD2)->D2_PRUNIT,(cAliasSD2)->D2_DESCON,;
			(cAliasSD2)->D2_LOCAL,{},0})
			nItem  := Len(aItens)
		Else
			//Jah existe um produto em aItens com o mesmo codigo e TES
			aItens[nPosItem][_QUANT]   += (cAliasSD2)->D2_QUANT
			aItens[nPosItem][_TOTAL]   += (cAliasSD2)->D2_TOTAL
			aItens[nPosItem][_DESCON]  += (cAliasSD2)->D2_DESCON			
			If nOpcSepara == 1
				aItens[nPosItem][_PRCVEN]  := aItens[nPosItem][_TOTAL]/aItens[nPosItem][_QUANT]
			Endif
			nItem  := nPosItem
		EndIf
		
		//Armazenar os impostos no array aItens
		aTesImpInf  := TesImpInf((cAliasSD2)->D2_TES)
		For nX := 1 to Len(aTesImpInf)
			cCampoBase  := aTesImpInf[nX][7]
			cCampoValor := aTesImpInf[nX][2]
			cCampoAliq  := aTesImpInf[nX][10]
			nPosImps    := aScan(aItens[nItem][_IMPOSTOS],{|x| x[_CPOBASE] == cCampoBase})
			If nPosImps == 0
				Aadd(aItens[nItem][_IMPOSTOS],{aTesImpInf[nX][1],cCampoBase,cCampoValor,;
				cCampoAliq,(cAliasSD2)->&(cCampoBase),(cAliasSD2)->&(cCampoValor),(cAliasSD2)->&(cCampoAliq),;
				aTesImpInf[nX][3]})
				nPosImps  := Len(aItens[nItem][_IMPOSTOS])
			Else
				//Jah existe um imposto em aItens[7] que grava no mesmo campo
				aItens[nItem][_IMPOSTOS][nPosImps][_BASIMP] += (cAliasSD2)->&(cCampoBase)
				aItens[nItem][_IMPOSTOS][nPosImps][_VLRIMP]  += (cAliasSD2)->&(cCampoValor)
			EndIf
			If aTesImpInf[nX][3] == "1"  //Imposto incide na NF
				aItens[nItem][_IMPSEPAR]  += (cAliasSD2)->&(cCampoValor)
			EndIf
		Next nX
		
		SF4->(DbSetOrder(1)) //F4_FILIAL + F4_CODIGO
		SF4->(DbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))
		
		DbSkip()
	End
	
	If Len(aItens) == 0
        Aviso(STR0031,STR0006,{OemtoAnsi(STR0030)})  //"Atencao"###"Nenhum comprovante foi selecionado! Verifique os dados de selecao!"###"OK"
	Else
		If MsgYesNo(STR0020+AllTrim(Str(nCnt))+STR0021+DtoC(dData)+chr(13)+; //"Foram selecionados "###" comprovantes do dia "
			STR0022) //"Confirma a geracao da Fatura Global?"
            
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza a quebra conforme o MV_NUMITEN³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX  := 1 to Len(aItens)
				If nAuxCont >= nMaxItens .OR. lIncluir
					If nAuxCont >= nMaxItens
						nPosCab++
					EndIf					

					Aadd(aCabecalho,{aCabAux[_CLIENTE],aCabAux[_LOJA],dData,aItens[nX][_TOTAL]+aItens[nX][_IMPSEPAR],aItens[nX][_TOTAL],{},aItens[nX][_DESCON]})
					
					For nY := 1 to Len(aItens[nX][_IMPOSTOS])
                               
						cCampoBase  := "F2_"+Substr(aItens[nX][_IMPOSTOS][nY][_CPOBASE],4)
						cCampoValor := "F2_"+Substr(aItens[nX][_IMPOSTOS][nY][_CPOVALOR],4)

						Aadd(aCabecalho[nPosCab][_IMPCABEC],{aItens[nX][_IMPOSTOS][nY][_CODIMP],cCampoBase,;
						cCampoValor,"",aItens[nX][_IMPOSTOS][nY][_BASIMP],;
						aItens[nX][_IMPOSTOS][nY][_VLRIMP]})
					
					Next nY	
					lIncluir := .F.
					nAuxCont := 1
				Else

					aCabecalho[nPosCab][_VLRBRUT] += aItens[nX][_TOTAL] + aItens[nX][_IMPSEPAR]
  					aCabecalho[nPosCab][_VLRMERC] += aItens[nX][_TOTAL]		
  					aCabecalho[nPosCab][_DESCONTO]+= aItens[nX][_DESCON]					

					For nY := 1 to Len(aItens[nX][_IMPOSTOS])
						
						cCampoBase  := "F2_"+Substr(aItens[nX][_IMPOSTOS][nY][_CPOBASE],4)
						cCampoValor := "F2_"+Substr(aItens[nX][_IMPOSTOS][nY][_CPOVALOR],4)
						nPosImps    := aScan(aCabecalho[nPosCab][_IMPCABEC],{|x| x[_CPOBASE] == cCampoBase})
						
						If nPosImps == 0
						
							Aadd(aCabecalho[nPosCab][_IMPCABEC],{aItens[nX][_IMPOSTOS][nY][_CODIMP],cCampoBase,;
							cCampoValor,"",aItens[nX][_IMPOSTOS][nY][_BASIMP],aItens[nX][_IMPOSTOS][nY][_VLRIMP]})
						
						Else
							aCabecalho[nPosCab][_IMPCABEC][nPosImps][_BASIMP] += aItens[nX][_IMPOSTOS][nY][_BASIMP]
							aCabecalho[nPosCab][_IMPCABEC][nPosImps][_VLRIMP] += aItens[nX][_IMPOSTOS][nY][_VLRIMP]
						EndIf
					Next nY

					nAuxCont++				

				EndIf
			Next nX
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua a gravacao da Fatura Global e seus dados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Lj480Grava(aCabecalho,aItens,aRecnosSF2,dData,aCabAux,@cNfOrig,@cSerOrig)
														
				For nX := 1 To Len(aNumGlobs)
					cTexNum += aNumGlobs[nX][2]+STR0008+aNumGlobs[nX][1]+","
				Next nX

				aNumGlobs := {}
                
				MsgInfo(STR0007+cTexNum+STR0009+Dtoc(dData)+STR0010) //"Fatura Global de serie/numero "###"/"###" referente ao dia "###" gerada com sucesso!"
     			If SA1->(FieldPos("A1_MODCFD")) > 0
					DbSelectArea("SF2")
					SF2->(DbSetOrder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
					While !Empty(cNfOrig) .And. SF2->( DbSeek( xFilial("SF2") + cNfOrig + cSerOrig ) )
						cNfOrig  := SF2->F2_NEXTDOC
						cSerOrig := SF2->F2_NEXTSER
						If lGeraCFD
							LOJXGERCFD(.F., lPergGrCFD, @aMsgCert)
						EndIf
						
						//Caso os campos F2_APROFOL ou F2_CERTFOL estiverem vazios eh porque o usuario optou por nao gerar o CFD.
						//Desta forma nao continua gerando CFD para os proximos documentos (F2_NEXTDOC)
						If Empty(SF2->F2_APROFOL) .Or. Empty(SF2->F2_CERTFOL)
							lGeraCFD := .F.
						EndIf
						lPergGrCFD  := .F. //Seta a variavel para .F. para nao exibir novamente a mensagem perguntando se deseja gerar CFD
					End
					
					//Exibe tela com dados dos CFDs (Comprovante Fiscal Digital) gerados
					LJXListFol(aMsgCert)
				EndIf	
			EndIf
		EndIf
	EndIf
	
	If lQuery
		DbSelectArea(cAliasSD2)
		dbCloseArea()
		DbSelectArea("SD2")
	Else
		DbSelectArea(cAliasSD2)
		dbClearFilter()
		RetIndex("SD2")

		If( ValType(oTempTable) == "O")
		  oTempTable:Delete()
		  FreeObj(oTempTable)
		  oTempTable := Nil
		EndIf		
	EndIf
Else   //Excluir
   DbSelectArea("SF3")
   SF3->(DbSetOrder(1)) //F3_FILIAL + DTOS(F3_ENTRADA) + F3_NFISCAL + F3_SERIE + F3_CLIEFOR + F3_LOJA + F3_CFO + STR(F3_ALIQICM,5,2)
   If DbSeek(xFilial("SF3")+DTOS(dData))
      While !Eof() .AND. xFilial("SF3")+DTOS(dData) == SF3->F3_FILIAL+DTOS(SF3->F3_EMISSAO)
         If SF3->F3_TIPOMOV == "V" .AND. SF3->F3_TIPO == "N"
            SF2->(DbSetOrder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
            If SF2->(DbSeek(xFilial("SF2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
               If SF2->F2_GLOBAL == "1"
                  lFound  := .T.       
                  Aadd(aRecnoSF3,Recno())  //Armazena os recnos dos registros do LF para posterior exclusao
                  aAdd(aRecnoSF2,SF2->(Recno()))
               EndIf
            EndIf
         EndIf   
         DbSkip()
      End
   EndIf                                                  
   If !lFound
      Aviso(STR0031,STR0028+DTOC(dData)+STR0029,{OemtoAnsi(STR0030)})    //"Atencao"###"Fatura Global do dia "###" nao encontrada."###"OK"
   Else
      
      For nX := 1 To Len(aRecnoSF2)
		 SF2->(DbGoto(aRecnoSF2[nX]))	         
         cTexNumDel += SF2->F2_SERIE + "-" + SF2->F2_DOC + ", "
      Next nX
      
      If !Empty(cTexNumDel)
	      If MsgYesNo(STR0026 + cTexNumDel + STR0027 + DTOC(SF2->F2_EMISSAO) + "?") //"Confirma a exclusao da Fatura Global "###" gerada no dia "
		      Begin Transaction
			      For nX := 1 To Len(aRecnoSF2)		      
			      
			         SF2->(DbGoto(aRecnoSF2[nX]))
			         cChaveSF2 := xFilial("SF2")+SF2->F2_SERIE+SF2->F2_DOC
			         
		             //Exclui os itens da Fatura Global
		             DbSelectArea("SD2")
		             SD2->(DbSetOrder(3)) //D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
		             If DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
		                While !Eof() .AND. xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA ==;
		                   SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
		                   If SD2->D2_TIPO == "N"
		                      Reclock("SD2",.F.)
		                      DbDelete()
		                      MsUnlock()
		                   EndIf
		                   DbSkip()
		                End   
		             EndIf
		             //Exclui a Fatura Global         
		             DbSelectArea("SF2")         
		             Reclock("SF2",.F.)
		             DbDelete()
		             MsUnlock()
		
		             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		             //³Atualiza os campos de NF original dos comprovantes³
		             //³que geraram a Fatura Global                       ³         
		             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                        
		             DbSetOrder(6)   
		             While DbSeek(cChaveSF2) .AND. cChaveSF2 == xFilial("SF2")+SF2->F2_SERIORI+SF2->F2_NFORI
		                If SF2->F2_TIPO == "N" .AND. DTOS(SF2->F2_EMISSAO) == DTOS(dData)
		                   RecLock("SF2",.F.)
		                   SF2->F2_NFORI    := Space(Len(F2_NFORI))
		                   SF2->F2_SERIORI  := Space(Len(F2_SERIORI))
		                   MsUnlock()
		                EndIf
		             End   
		             //Exclui o(s) registro(s) do Livro Fiscal
		             DbSelectArea("SF3")
			      Next nX
			         
		          For nX := 1 to Len(aRecnoSF3)
		             DbGoto(aRecnoSF3[nX])
		             Reclock("SF3",.F.)
		             DbDelete()
		             MsUnlock()            
		          Next nX
			  End Transaction	      
	    	  Aviso(STR0032,STR0033,{OemtoAnsi(STR0030)}) //"Confirmacao"###"Fatura Global excluida com sucesso!"###"OK"
	      EndIf
	  EndIf
   EndIf
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj480Grava ³ Autor ³Vendas Clientes        ³ Data ³ 12/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera a Fatura Global e seus itens                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJA480                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os dados do cabecalho da Fatura Global    ³±±
±±³          ³ ExpA2 = Array com os itens da Fatura Global                 ³±±
±±³          ³ ExpA3 = Array com os Recnos dos comprovantes que originam a ³±±
±±³          ³ Fatura Global                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj480Grava( aCabecalho , aItens , aRecnosSF2 , dData , ;
							aCabAux	   , cNfOrig, cSerOrig )

Local cAliasNF	  := ""
Local cNumAnt     := Space(TamSX3("F2_DOC")[1])
Local cTipoGrv    := "N"
Local cEspecie    := "NF"
Local cEstado     := ""
Local cTipoCli    := ""
Local cItem       := Repl("0",TamSx3("D2_ITEM")[1])
Local cCampoBase  := ""
Local cCampoValor := ""
Local cCampoAliq  := ""
Local nAltera     := SuperGetMV("MV_ALTNUM",,1)
Local nX		  := 0
Local nY		  := 0
Local nZ          := 0
Local nW		  := 0
Local nTamCodCli  := TamSx3("A1_COD")[1]
Local nTamCodLoja := TamSx3("A1_LOJA")[1]
Local nMoedaCor   := 1
Local nTxMoeda    := 0
Local lExiste     := .T.
Local lGrava      := .T.
Local lRet        := .F.
Local aTipos      := {}
Local nContAux	  := 1
Local nContMxIt	  := 1											// Controle da quebra de nota
Local nPosArSD2	  := 0    										// Posicao do array do SD2 que deve comecar a gravar
Local lAcumPos	  := .T.										// Se guarda a ultima posicao do array
Local aRecProxF2  := {}											// Array com os Recnos do SF2 que precisam do NEXTDOC
Local aImpPrepAr  := {}											// Array com os impostos para o aLivro
Local nTaxaMoeda  := 1											// Moeda
Local aGetBook          										// Informacoes para o Livro
Local aLivro      := {}											// Livro Fiscal (SF3)
Local cSerieF2	  := ""											// Grava a mesma serie da nota nos itens
Local cPadrao	  := "702"                                    	// Contabilizacao - Codigo Padrao (Lancamento Padrao: 702=Fatura Global)
Local lPadrao  	  := VerPadrao(cPadrao)							// Contabilizacao - Verifica se o codigo Padronizado existe
Local nHdlPrv  	  := 0											// Contabilizacao
Local nTotal   	  := 0											// Contabilizacao
Local cArquivo 	  := ""											// Contabilizacao
Local lAglutina   := .T.										// Contabilizacao (Aglutina Lancamentos)
Local aLancCtb 	  := {} 								   		// Contabilizacao

DbSelectArea("SA1")
dbSetOrder(1)
If DbSeek(xFilial("SA1")+Padr(aCabAux[_CLIENTE],nTamCodCli)+Padr(aCabAux[_LOJA],nTamCodLoja))
   cEstado   := SA1->A1_EST
   cTipoCli  := SA1->A1_TIPO
EndIf


For nZ := 1 To Len(aCabecalho)

	If !Lj480Sx5NF(SuperGetMv("MV_LOJANF"))    
	   Return (lRet)
	EndIf


	DbSelectArea("SF2")
	dbSetOrder(1)
	
	cNumAnt         := cNumNota
	cAliasNF		:= "SF2"                                                       
	AADD (aTipos,{"SF2","C"})
	AADD (aTipos,{"SF2","N"})
	AADD (aTipos,{"SF2"," "})
	AADD (aTipos,{"SF1","D"})
	
	//Controle da numeracao da NF usando MayIUseCode
	While lExiste
	   lExiste  := !aNumNaoExiste(cAliasNF,cSerie,cNumNota,aCabAux[_CLIENTE],aCabAux[_LOJA],cEspecie,"LOJ")
	   If lExiste 
	      cNumNota := PadR( StrZero(Val(cNumNota)+1,Len(AllTrim(cNumNota))) , TamSX3("F2_DOC")[1] )
	   Else
	      If cNumAnt <> cNumNota
		     If nAltera == 1                                             
			    MsgInfo(STR0011+ cNumAnt +STR0012+ cNumNota,STR0013)		          //" O Numero do Documento foi alterado de: "###" para: "###"Numero"
		     ElseIf nAltera == 2                                                                  
			    lGrava := MsgYesNo(STR0014+ cNumAnt +STR0015+ cNumNota ) //" O documento no.: "###" ja existe, confirma alteracao da numeracao para: "
		     Else                                                                             
			    MsgInfo(STR0014+cNumAnt+STR0016,STR0017) //" O documento no.: "###" ja existe "###"Numero do Documento "
	   		    lGrava := .F.
		     EndIf
	      EndIf
	   EndIf   
	End
    
	If Len(aRecProxF2) > 0
		aRecProxF2[Len(aRecProxF2)][2] := cNumNota
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravar informa‡”es para a Factura de Sa¡da (SD2/SF2)...      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGrava

		Begin Transaction

		RecLock("SF2",.T.)
		
		Aadd(aRecProxF2,{SF2->(Recno()),""})
		Aadd(aNumGlobs,{cNumNota,cSerie})
		
		REPLACE F2_FILIAL  WITH xFilial()	
		REPLACE F2_TIPO    WITH cTipoGrv
		REPLACE F2_ESPECIE WITH cEspecie	
		REPLACE F2_DOC     WITH cNumNota
		REPLACE F2_SERIE   WITH cSerie
		REPLACE F2_EMISSAO WITH aCabecalho[nZ][_EMISSAO]   	
		REPLACE F2_CLIENTE WITH aCabecalho[nZ][_CLIENTE]   	
		REPLACE F2_LOJA    WITH aCabecalho[nZ][_LOJA]
		REPLACE F2_VALBRUT WITH aCabecalho[nZ][_VLRBRUT]		
		REPLACE F2_VALMERC WITH aCabecalho[nZ][_VLRMERC]   	
		REPLACE F2_VALFAT  WITH aCabecalho[nZ][_VLRBRUT]
		REPLACE F2_DESCONT WITH aCabecalho[nZ][_DESCONTO]	
		REPLACE F2_EST     WITH cEstado
		REPLACE F2_TIPOCLI WITH cTipoCli
		REPLACE F2_HORA	   WITH SubStr(Time(),1,5)	
		REPLACE F2_GLOBAL  WITH "1"	
		REPLACE F2_MOEDA   WITH nMoedaCor
		REPLACE F2_TXMOEDA WITH nTxMoeda
		REPLACE F2_TIPODOC WITH "01"
		If cPaisLoc == "MEX"
			REPLACE F2_USOCFDI WITH cUsoCFDI
			REPLACE F2_RELSAT WITH cRelSAT
			REPLACE F2_UUIDREL WITH ALLTRIM(cUUIDREL)
		EndIf
		REPLACE F2_COND WITH cCondPg	
	    //Gravar os Impostos Variaveis do Cabecalho
	    For nX := 1 to Len(aCabecalho[nZ][_IMPCABEC])
	       cCampoBase := aCabecalho[nZ][_IMPCABEC][nX][_CPOBASE]         
	       If FieldPos(cCampoBase) > 0
	          SF2->(FieldPut(FieldPos(cCampoBase),aCabecalho[nZ][_IMPCABEC][nX][_BASIMP]))                 
	       EndIf
	       cCampoValor := aCabecalho[nZ][_IMPCABEC][nX][_CPOVALOR]         
	       If FieldPos(cCampoValor) > 0
	          SF2->(FieldPut(FieldPos(cCampoValor),aCabecalho[nZ][_IMPCABEC][nX][_VLRIMP]))                 
	       EndIf       
	    Next nX
	    MsUnlock()// padrao
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz contabilizacao Online³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPadrao .AND. cPaisLoc == "MEX"
			
			aLancCtb := {{"F2_DTLANC",dDataBase,"SF2",SF2->(Recno()),0,0,0}} //Campo Flag de Contabilizacao a ser atualizado
			
			nHdlPrv:=HeadProva("","LOJA480",Substr(cUsername,1,6),@cArquivo)
				
			If  nHdlPrv > 0
				nTotal+=DetProva(nHdlPrv,cPadrao,"LOJA480","")
			EndIf
						
			If  nTotal > 0
				RodaProva(nHdlPrv,nTotal)
				cA100Incl(cArquivo,nHdlPrv,3,"",.F.,lAglutina,,,,aLancCtb)
			EndIf
				
		EndIf
	    
	    
	    
	    DbSelectArea("SD2")
	    dbSetOrder(1)
	    SB1->(dbSetOrder(1))     
	    SF4->(dbSetOrder(1))         
	    
	    cSerieF2 := cSerie	
	    
	    //Gravar os itens da Fatura Global
	    For nX := nContAux to Len(aItens)	
		
			If nContMxIt <= nMaxItens

		        SB1->( DbSeek(xFilial("SB1")+aItens[nX][_PRODUTO]))
			    SF4->( DbSeek(xFilial("SF4")+aItens[nX][_TES]))
		    
		        cItem := SomaIt(cItem)
		        RecLock("SD2",.T.)
				REPLACE D2_FILIAL  WITH xFilial("SD2")
				REPLACE D2_DOC     WITH cNumNota
				REPLACE D2_SERIE   WITH cSerieF2
				REPLACE D2_ESPECIE WITH cEspecie
				REPLACE D2_CLIENTE WITH aCabAux[_CLIENTE]   	
				REPLACE D2_LOJA    WITH aCabAux[_LOJA]   	 
				REPLACE D2_EMISSAO WITH aCabAux[_EMISSAO]   	
				REPLACE D2_TIPO    WITH cTipoGrv
				REPLACE D2_EST     WITH cEstado            
				REPLACE D2_ITEM    WITH cItem		
				REPLACE D2_COD     WITH aItens[nX][_PRODUTO]		
				REPLACE D2_UM      WITH SB1->B1_UM
				REPLACE D2_GRUPO   WITH SB1->B1_GRUPO		
				REPLACE D2_LOCAL   WITH aItens[nX][_LOCAL]		
				REPLACE D2_TES     WITH aItens[nX][_TES]		
				REPLACE D2_CF      WITH aItens[nX][_CF]		
				REPLACE D2_QUANT   WITH aItens[nX][_QUANT]		
				REPLACE D2_PRCVEN  WITH aItens[nX][_PRCVEN]
				REPLACE D2_PRUNIT  WITH aItens[nX][_PRUNIT]		
				REPLACE D2_TOTAL   WITH aItens[nX][_TOTAL]
				REPLACE D2_DESCON  WITH aItens[nX][_DESCON]		
				REPLACE D2_PESO    WITH SB1->B1_PESO
				REPLACE D2_GRUPO   WITH SB1->B1_GRUPO
				REPLACE D2_TP      WITH SB1->B1_TIPO
				REPLACE D2_NUMSEQ  WITH ProxNum()       
				REPLACE D2_ORIGLAN WITH "LO"		
				// Foi necessario gravar todos os campos referentes ao remito para não
				// ocorrer nenhum problema com a integridade referencial
				REPLACE D2_REMITO  WITH cNumNota	  //Gravar este campo para ser ignorado nos recalculos			
				REPLACE D2_SERIREM WITH cSerieF2
				REPLACE D2_ITEMREM WITH cItem		          
			    REPLACE D2_TIPODOC WITH "01"			
		        //Gravar os Impostos Variaveis dos itens
		        For nY := 1 to Len(aItens[nX][_IMPOSTOS])
		           cCampoBase := aItens[nX][_IMPOSTOS][nY][_CPOBASE]
		           If FieldPos(cCampoBase) > 0
		              SD2->(FieldPut(FieldPos(cCampoBase),aItens[nX][_IMPOSTOS][nY][_BASIMP]))                 
		           EndIf
		           cCampoValor := aItens[nX][_IMPOSTOS][nY][_CPOVALOR]         
		           If FieldPos(cCampoValor) > 0
		              SD2->(FieldPut(FieldPos(cCampoValor),aItens[nX][_IMPOSTOS][nY][_VLRIMP]))                 
		           EndIf                  
		           cCampoAliq := aItens[nX][_IMPOSTOS][nY][_CPOALIQ]
		           If FieldPos(cCampoAliq) > 0
		              SD2->(FieldPut(FieldPos(cCampoAliq),aItens[nX][_IMPOSTOS][nY][_ALQIMP]))                 
		           EndIf           
		        Next nY    		             
		        MsUnlock()

				aImpPrepAr	:= Lj480PrepAr(nX,aItens)
			    aLivro      := GetBook(	@aGetBook	, aImpPrepAr	, "V"	, nTaxaMoeda	,;
			    						aLivro		, "S"			, Nil	, .T.			,; 
			    						Nil			, cSerieF2	)		    			    
		    
		    Else
		    	If lAcumPos
		    		nPosArSD2 := nX
					lAcumPos := .F.
				EndIf		    
		    EndIf
	
		    nContMxIt++
	    
	    Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reinicializa as variaveis para o proximo Loop³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nContMxIt	:= 	1
	    nContAux 	:= 	nPosArSD2
	    cItem    	:= 	Repl("0",TamSx3("D2_ITEM")[1])
		lAcumPos    := .T.
			    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza a numeracao da NF no SX5³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    LjLocAtuSX5()    
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizar os comprovantes com o numero da Fatura Global gerada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If nZ == 1
		    DbSelectArea("SF2")
		    DbSetOrder(1)
		    //Guarda o numero e serie da NF de Origem
		    cNfOrig  := cNumNota
		    cSerOrig := cSerieF2
		    For nX := 1 to Len(aRecnosSF2)
		       DbGoto(aRecnosSF2[nX])
		       Reclock("SF2",.F.)
		       SF2->F2_NFORI    := cNumNota
		       SF2->F2_SERIORI  := cSerieF2
		       MsUnlock()
		    Next nX
		EndIf	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inclui o cliente e loja³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nW := 2 To Len(aLivro)
			If Empty(aLivro[nW][5])
				aLivro[nW][5] := aCabAux[_CLIENTE]
			EndIf
			If Empty(aLivro[nW][6])
				aLivro[nW][6] := aCabAux[_LOJA]
            EndIf
		Next nW
	    
	    //Grava o Livro Fiscal
	    Lj480Livro(cEspecie,dData,aLivro)

		aImpPrepAr	:= {}
	    aLivro		:= {}
		End Transaction	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³PE para gravar no SD2 campos de apoio aos processos contabeis³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
        If FindFunction("U_LJ480GRVNF")
			U_LJ480GRVNF(aCabecalho, nZ, aNumGlobs)							      		      						  
	    EndIf	    	  

		lRet   := .T.
	EndIf

Next nZ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o F2_NEXTDOC dos Recno´s anteriores³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aRecProxF2) > 0
	DbSelectArea("SF2")
	DbSetOrder(1)
	For nX := 1 to Len(aRecProxF2)-1
		DbGoto(aRecProxF2[nX][1])
		Reclock("SF2",.F.)
		SF2->F2_NEXTDOC  := aRecProxF2[nX][2]
		SF2->F2_NEXTSER  := cSerieF2
		MsUnlock()
	Next nX	    
EndIf

FreeUsedCode()

Return (lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj480Sx5NF   ³ Autor ³ Vendas Clientes       ³ Data ³ 12/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obter a serie e numero da NF                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj480Sx5NF(cMvSerie)               							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Serie do parametro MV_LOJANF                          ³±±
±±³          ³ ExpA2 = Array para controle de multiplas faturas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA480                          							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj480Sx5NF(cMvSerie)
Local aArea 	:= GetArea()
Local aSerNf	:= {}
Local aRecnos	:= {}                             
Local oDlgLojaNota    
Local oNumNota
Local lTudo 	:= .T.
Local nOpcA 	:= 0
Local nContErr  := 0                  
Local nX
Local lRetorno  := .T.
Local nTamSerie	:= TamSX3("L1_SERIE")[1]

If Empty(cMvSerie)
	While .T.
		DbSelectArea("SX5")
		DbSeek(cFilial+"01")
		aSerNf := {}
		lTudo  := .T.
		While cFilial+"01" == X5_FILIAL+X5_TABELA
			If !MSRLock() .OR. SubStr(X5Descri(),1,1) = "*"
				lTudo := .F.
				Exit
			Endif

			Aadd(aRecnos,Recno())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se a S‚rie for CPF, n„o mostra no aChoice, pois ‚ utilizada ³
			//³ internamente para emissao de Cupom Fiscal.					³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Trim(SX5->X5_TABELA) == "01" .AND. Trim(SX5->X5_CHAVE) == "CPF"
				DbSkip()
				Loop
			ElseIf Trim(SX5->X5_TABELA) == "01" .AND. Trim(SX5->X5_CHAVE) == "CP"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso seja Nota fiscal n„o exibe a s‚rie CP ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSkip()
				Loop
			EndIf

			Aadd(aSerNF,{Padr(X5_CHAVE,TamSx3("L1_SERIE")[1]),Trim(X5Descri())})
			DbSkip()
		End

		If !lTudo
			nContErr ++
			If nContErr > 10
				DbSeek( cFilial+"01" )
				While cFilial+"01" == X5_FILIAL+X5_TABELA
					MsUnlock()
					DbSkip()
				End
				Help(" ",1,"NOTAPRESA")
				nContErr := 0
			EndIf
			Inkey(1)
			Loop
		EndIf
		Exit
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trata s‚rie e numero da nota fiscal  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgLojaNota TITLE STR0018 From 10,30 To 16,58 //"Numeracao da Nota Fiscal Global"

	@ 1, 2 TO 30, 108 OF oDlgLojaNota PIXEL

	@ 10, 5 SAY STR0019 SIZE 22, 7 OF oDlgLojaNota PIXEL  //"N.Fiscal"

	@ 9, 25 MSGET cSerie  PICTURE "@!";
	VALID Lj480VldSer() F3 "01";
	SIZE 15, 10 OF oDlgLojaNota PIXEL

	@ 9,55 MSGET oNumNota VAR cNumNota PICTURE PesqPict("SF2","F2_DOC");
	VALID Lj480Zera() ;
	SIZE 47, 10 OF oDlgLojaNota PIXEL

	DEFINE SBUTTON FROM 31,42 TYPE 1 ACTION If(Lj480VldDoc(),;
	(lRetorno := .T.,nOpca := 1, oDlgLojaNota:End()),;
	nOpca := 0);
	ENABLE OF oDlgLojaNota
	DEFINE SBUTTON FROM 31,73 TYPE 2 ACTION (lRetorno := .F.,oDlgLojaNota:End()) ENABLE OF oDlgLojaNota

	ACTIVATE MSDIALOG oDlgLojaNota CENTERED
Else
	cMVSerie := PadR(If(SubStr(cMVSerie,1,1)=="&",&(SubStr(cMVSerie,2,Len(cMVSerie))),cMVSerie), nTamSerie)
	DbSelectArea("SX5")
	DbSeek(xFilial()+"01"+cMVSerie)
	If Eof()
		HELP(" ",1,"ERROSERIE")
		Return .F.
	Endif

	While !MsrLock()
		InKey(1)
		nContErr++
		If nContErr > 10
			Help(" ",1,"NOTAPRESA")
			nCOntErr := 0
		EndIf
	End
	aAdd(aRecnos,Recno())
	cNumNota := Substr(X5Descri(),1,TamSx3("L1_DOC")[1])
	cSerie := cMvSerie
EndIf

//Liberando registros locados
For nX := 1 to Len(aRecnos)
	dbGoto(aRecnos[nX])
	MsUnlock()
Next nX
	
RestArea(aArea)

Return lRetorno


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³Lj480VldSe³ Autor ³ Vendas Clientes       ³ Data ³ 12/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Validar a serie da Fatura                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA010B                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj480VldSer()
Local lRet := .T.
Local aArea:= GetArea()

DbSelectArea("SX5")
dbSetOrder(1)
DbSeek(xFilial()+"01"+cSerie)
If !Found()
	Help(" ",1,"LJ480SERIE")
	lRet := .F.
EndIf
cNumNota := AllTrim(SX5->X5_DESCRI)
RestArea(aArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Lj480Zera   ³ Autor ³ Vendas Clientes    ³ Data ³ 12/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Agregar zeros a esquerda do numero da NF                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj480Zera()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja480                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj480Zera()
If !Empty(cNumNota)
	cNumNota := PadR( cNumNota , TamSX3("F2_DOC")[1] )
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³Lj480VldDoc  ³ Autor ³ Vendas Clientes    ³ Data ³ 12.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao³ Validar o n£mero da Fatura                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA480                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj480VldDoc()
Local lRet := .T.
Local aArea:= GetArea()

cNumNota := If(cNumNota ==Nil ,"",cNumNota)
cSerie   := If(cSerie   ==Nil ,Space(TamSx3("L1_SERIE")[1]),cSerie)
cNumNota := PadR( cNumNota , TamSX3("F2_DOC")[1] )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Consiste duplicidade de digitacao de Nota Fiscal.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF2")
dbSetOrder(1)

If Empty(cNumNota)
	Help(" ",1,"LJ480VAZIO")
	lRet := .F.
Else
	DbSeek(xFilial("SF2")+cNumNota+cSerie)
	If Found()
		Help(" ",1,"LJ480EXIST")
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³Lj480VldProd ³ Autor ³ Vendas Clientes    ³ Data ³ 12.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao³ Validar o codigo do produto digitado na Pergunta           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA480                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj480VldProd()
Local lRet  := .T.

DbSelectArea("SB1")
DbSetOrder(1)
If !Empty(mv_par02) .AND. !DbSeek(xFilial()+mv_par02)
   lRet  := .F.
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³Lj480Livro   ³ Autor ³ Vendas Clientes    ³ Data ³ 12.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao³ Gerar os registros do Livro Fiscal                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA480                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj480Livro(cEspecie,dData,aLivro)
Local cEspec        := Padr(cEspecie,Len(criavar("F3_ESPECIE",.F.)))
Local cEspTmp	    := MVNOTAFIS+"|"+GetSESNew('NDC',"1")+"|"+GetSESNew('NDI',"2")+"|"+GetSESNew('NCI',"2")+"|"+GetSESNew('NCC',"2")
Local cTipContNF    := If(ValType(lFiscal)== "L" .AND. lFiscal ,SuperGetMV("MV_CONTNFI",,"I"),SuperGetMV("MV_CONTNF"))
Local nX            := 0
Local nY            := 0
                                                                  	
cNumNota := PadR( cNumNota , TamSX3("F3_NFISCAL")[1] )

DbSelectArea("SF3")
DbSetOrder(5)
//Exclui os registros de mesma numeracao que estao cancelados
If DbSeek( xFilial("SF3")+cSerie+cNumNota)
	While !Eof() .AND. (xFilial("SF3")+cSerie+cNumNota) == (SF3->F3_FILIAL+SF3->F3_SERIE+SF3->F3_NFISCAL)
	   If !Empty(SF3->F3_DTCANC)
	      If cTipContNF == "M" .AND. Alltrim(F3_ESPECIE)$ cEspTmp .OR. (cTipContNF == "I" .AND. Alltrim(F3_ESPECIE)==	Alltrim(cEspec))	   
			 RecLock("SF3",.F.)
			 dbDelete()
			 MsUnLock()
		  EndIf
	   Endif
	   DbSkip()
	End
EndIf

For nX := 2 To Len( aLivro )
	RecLock( "SF3",.T. )
	For nY := 1 To Len( aLivro[1] )
		SF3->( FieldPut(FieldPos(aLivro[1,nY]),aLivro[nX,nY]) )
	Next nY
	REPLACE F3_FILIAL  WITH xFilial("SF3")
	REPLACE F3_NFISCAL WITH cNumNota
	REPLACE F3_SERIE   WITH cSerie	
	REPLACE F3_ENTRADA WITH dData	
	MsUnLock()
Next nX

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³Lj480VldTES  ³ Autor ³ Vendas Clientes    ³ Data ³ 20.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao³ Validar o TES Global, para que nao permita gerar Livro     ³±±
±±³          ³ Fiscal                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gatilho dos campos F4_GERALF e F4_GLOBAL                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj480VldTES()
Local lRet  := .T.

If M->F4_GERALF == "1" .AND. M->F4_GLOBAL == "1"
   MsgStop(STR0023)    //"Nao e possivel gerar Livro Fiscal para um TES global!"
   lRet  := .F.
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj480CriaTm³ Autor ³Vendas Clientes        ³ Data ³ 12/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria temporario a partir da selecao dos registros(TOP)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJA480(TOPCONNECT)                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj480CriaTmp(aStruTmp, cAliasTmp, cAlias)
Local nI, nF
Local nPosOrig
Local nPosDest
Local nTotalRec		:= 0

nTotalRec := SD2->(RecCount())

nF := (cAlias)->(FCount())

//Cria tabela temporaria
oTempTable := LjCrTmpTbl(cAliasTmp, aStruTmp)

(cAlias)->(DbGoTop())

ProcRegua( nTotalRec )

While !(cAlias)->(Eof())
	
	IncProc()
	
	(cAliasTmp)->(DbAppend())
      For nI := 1 To Len(aStruTmp)
      	nPosDest := (cAliasTmp)->(FieldPos(aStruTmp[nI,1]))
      	nPosOrig := (cAlias)->(FieldPos(aStruTmp[nI,1]))
      	If nPosDest > 0 .AND. nPosOrig > 0
			(cAliasTmp)->(FieldPut(nPosDest,(cAlias)->(FieldGet(nPosOrig)))) 
		EndIf
	Next nI
	(cAlias)->(DbSkip())
End
(cAlias)->(dbCloseArea())
DbSelectArea(cAliasTmp)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj480PrepArºAutor  ³Vendas Clientes    º Data ³  29/19/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Preparacao de array para geracao do livro                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³  ExpN1 - Linha atual do aItens                             º±±
±±º          ³  ExpA2 - Itens aglutinados do SD2                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³  ExpA1 - Informacoes para serem gravadas no SF3.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA480                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj480PrepAr(nY,aItens)
Local nCampoBase	:= 0								// Base
Local nCampoVlr 	:= 0								// Valor 
Local nCampoAliq	:= 0								// Aliquota
Local aInfo	    	:=	TesImpInf(aItens[nY][_TES])		// Informacoes com TES
Local aReturn		:=	{0,0,0,0,0,{}}					// Retorno
Local nPosCpoBas	:= 0								// Posicao campo base
Local nPosCpoVlr	:= 0								// Posicao valor
Local nPosCpoAlq	:= 0								// Posicao aliquota
Local nX			:= 0								// Controle de For

aReturn[1]	:=	aItens[nY][_QUANT]		
aReturn[2]	:=	aItens[nY][_PRCVEN]
aReturn[3]	:=	aItens[nY][_TOTAL]
aReturn[4]	:=	0
aReturn[5]	:=	0

For nX	:=	1	To	Len(aInfo)
    
	nPosCpoBas	:= aScan(aItens[nY][_IMPOSTOS],{|x| x[_CPOBASE] == aInfo[nX][7] })
	nPosCpoVlr	:= aScan(aItens[nY][_IMPOSTOS],{|x| x[_CPOVALOR]== aInfo[nX][2] })
	nPosCpoAlq	:= aScan(aItens[nY][_IMPOSTOS],{|x| x[_CPOALIQ] == aInfo[nX][10]})

    If nPosCpoBas > 0
    	nCampoBase  :=aItens[nY][_IMPOSTOS][nPosCpoBas][_BASIMP]
    EndIf

	If nPosCpoVlr > 0    
	    nCampoVlr   := aItens[nY][_IMPOSTOS][nPosCpoVlr][_VLRIMP]
	EndIf    

    If nPosCpoAlq > 0
		nCampoAliq  := aItens[nY][_IMPOSTOS][nPosCpoAlq][_ALQIMP]
	EndIf
    
    AAdd(aReturn[6],Array(18))
	aReturn[6][nX][1]	:= aInfo[nX][1]
	aReturn[6][nX][2]	:= nCampoAliq
	aReturn[6][nX][3]	:= nCampoBase
	aReturn[6][nX][4]	:= nCampoVlr
	aReturn[6][nX][5]	:= aInfo[nX][3]+aInfo[nX][4]+aInfo[nX][5]
	aReturn[6][nX][6]	:= "D2_VALIMP"+Substr(aInfo[nX][2],10)
	aReturn[6][nX][7]	:= "D2_BASIMP"+Substr(aInfo[nX][2],10)
	aReturn[6][nX][8]	:= "F2_VALIMP"+Substr(aInfo[nX][2],10)
	aReturn[6][nX][9]	:= "F2_BASIMP"+Substr(aInfo[nX][2],10)
	aReturn[6][nX][17] := Substr(aInfo[nX][2],10)
Next nX                                     

Return(aReturn)
