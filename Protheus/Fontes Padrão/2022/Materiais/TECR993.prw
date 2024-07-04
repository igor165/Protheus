#INCLUDE "REPORT.CH"
#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "TECR993.ch"

Static cAutoPerg := "TECR993"

//-------------------------------------------------------------------
/*/{Protheus.doc} TECR993
Monta as definiçoes do relatorio de Custos Operacionais.

@author fabiana.silva
@since 06/11/2019
@version P12.1.27
/*/
//-------------------------------------------------------------------
Function TECR993()
	Local oReport 		:= Nil
	Local cPerg			:= "TECR993"
	Local oTempTabl0 	:= NIL //Tabela Totalizador
	Local oTempTabl1 	:= NIL //Tabela Quebra 1 - Cliente
	Local oTempTabl2 	:= NIL //Tabela Quebra2 - Contrato
	Local oTempTabl3 	:= NIL //Tabela Quebra3 - Local
	Local oTempTable 	:= NIL //Tabela Detalhe - Itens RH
	Local aQbrTables 	:= {}
	Local aFieldQ 		:= {}
	Local aIndQ 		:= {}
	Local cAliasT 		:= ""
	Local cPictTot 		:= ""
	Local nC 			:= 0
	Local lRet 			:= .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PARAMETROS                                                             ³
	//³ MV_PAR01 : Cliente de?                                                 ³
	//³ MV_PAR02 : Cliente ate?                                                ³
	//³ MV_PAR03 : Contrato  de ?                                              ³
	//³ MV_PAR04 : Contrato ate?                                               ³
	//³ MV_PAR05 : Local de?                                                   ³
	//³ MV_PAR06 : Local ate?                                                  ³
	//³ MV_PAR07 : Produto   de ?                                              ³
	//³ MV_PAR08 : Produto ate?                                                ³
	//³ MV_PAR09 : Grupo de?                                                   ³
	//³ MV_PAR10 : Grupo ate?                                                  ³
	//³ MV_PAR11 : Data Fim superior a ?                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//Exibe dialog de perguntes ao usuario
If AliasInDic("TXG")	
	
	If Pergunte(cPerg,.T.)
		//Cria a Estrutura do relatório

		aFieldQ := {}
		aIndQ := {}
		cAliasT := GetNextAlias()
		cPictTot := ""
		oTempTabl0 := CreateStruct(0, cAliasT, @aFieldQ,  @aIndQ, @cPictTot) //Tabela Totalizador
		aAdd(aQbrTables, {oTempTabl0, cAliasT, aClone(aFieldQ), aClone(aIndQ), {}, {}, cPictTot})
		lRet := lRet .AND. ValType(aTail(aQbrTables)[1]) <> NIL
		
		aFieldQ := {}
		aIndQ := {}
		cAliasT := GetNextAlias()
		cPictTot := ""
		oTempTabl1 := CreateStruct(1, cAliasT, @aFieldQ, @aIndQ, @cPictTot) //Quebra 1 - Clienbte
		aAdd(aQbrTables, {oTempTabl1, cAliasT, aClone(aFieldQ), aClone(aIndQ), {}, {}, cPictTot})
		lRet := lRet .AND. ValType(aTail(aQbrTables)[1]) <> NIL
		
		aFieldQ := {}
		aIndQ := {}
		cAliasT := GetNextAlias()
		cPictTot := ""
		oTempTabl2 := CreateStruct(2, cAliasT, @aFieldQ, @aIndQ, @cPictTot) //Tabela Quebra2 - Contrato
		aAdd(aQbrTables, {oTempTabl2, cAliasT, aClone(aFieldQ), aClone(aIndQ), {}, {}, cPictTot})
		lRet := lRet .AND. ValType(aTail(aQbrTables)[1]) <> NIL
		
		aFieldQ := {}
		aIndQ := {}
		cAliasT := GetNextAlias()
		cPictTot := ""
		oTempTabl3 := CreateStruct(3, cAliasT, @aFieldQ,@aIndQ, @cPictTot) //Tabela Quebra3 - Local
		aAdd(aQbrTables, {oTempTabl3, cAliasT, aClone(aFieldQ), aClone(aIndQ), {}, {}, cPictTot})
		lRet := lRet .AND. ValType(aTail(aQbrTables)[1]) <> NIL
		
		aFieldQ := {}
		aIndQ := {}
		cAliasT := GetNextAlias()
		cPictTot := ""
		oTempTable := CreateStruct(4, cAliasT, @aFieldQ, @aIndQ, @cPictTot)
		aAdd(aQbrTables, {oTempTable, cAliasT, aClone(aFieldQ),{ }, {}, {}, cPictTot}) //Tabela 4  - Itens de RH
		lRet := lRet .AND. ValType(aTail(aQbrTables)[1]) <> NIL
		
		//Pinta o relatorio a partir das perguntas escolhidas
		If lRet
			oReport := ReportDef(cPerg, aQbrTables)
			oReport:PrintDialog()
		Else
				Help( " ", 1, "TECR993", Nil, STR0001, 1 ) //"Falha na criação das tabelas temporárias"
		EndIf
		For nC := 1 to Len(aQbrTables)
		
			If Valtype(aQbrTables[nC, 01]) <> NIL
				aQbrTables[nC, 01]:Delete()
				FreeObj(aQbrTables[nC, 01])
			EndIf
		Next nC

	EndIf
Else
	Help( " ", 1, "TECR993", Nil, STR0002, 1 )  //"Tabela TXG não existe no dicionário de Dados"
EndIf
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} reportDef
Monta as definiçoes do relatorio de Custos Operacionais

@author fabiana.silva
@since 06/11/2019
@version P12.1.27
@param cPerg - Pergunte do relatório
@param aQbrTables - Array de tabelas
@return  Nil
/*/
//-------------------------------------------------------------------------------------
Static Function ReportDef(cPerg, aQbrTables)

	Local cTitulo 		:= STR0003 //"Custos Operacionais"
	Local oReport 		:= NIL
	Local oSection0 	:= nil
	Local oSection01 	:= nil
	Local oSection1 	:= nil
	Local oSection11 	:= nil
	Local oSection12 	:= nil
	Local oSect121 		:= nil
	Local oSect122 		:= NIL
	Local oSect1221 	:= NIL
	Local oSect1222		:= NIL
	Local oSect12221	:= NIL
	Local oBreak0 		:= NIL
	Local oBreak1 		:= NIL
	Local oBreak12 		:= NIL
	Local oBreak122 	:= NIL
	Local oBreak1222 	:= NIL
	Local cMoeda := SuperGetMV( "MV_SIMB1",.f. , "R$" ) 
	Local cAlias := ""
	

	cAlias := aQbrTables[05,02]
	
	oReport 	:= TReport():New(cPerg, cTitulo, cPerg , {|oReport| PrintReport(oReport, aQbrTables)}, STR0003 )  //"Custos Operacionais"
	oSection1:= TRSection():New(oReport, STR0004 ,{cAlias, "SA1"}, /*<aOrder>*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/,/*<lTotalInLine .T.*/ , /*<lHeaderPage> */.f., /*<lHeaderBreak>*/ .f. , /*<lPageBreak>*/ .F. , /*<lLineBreak>*/ ,/* <nLeftMargin>*/ 5 , /*<lLineStyle> */, /*<nColSpace>*/ , /*<lAutoSize> */, /*<cCharSeparator>*/ , /*<nLinesBefore> */, /*<nCols> */, /*<nClrBack> */, /*<nClrFore> */, /*<nPercentage> */ ) //"Cliente"
	oBreak1 = TRBreak():New( oSection1 , {|| (cAlias)->(TFJ_CODENT+TFJ_LOJA) },""  , .F. ,  , .F. )
	TRPosition():New(oSection1,"SA1", 1,{|| xFilial("SA1")+(cAlias)->(TFJ_CODENT+TFJ_LOJA )})  
	
	DEFINE CELL NAME "TFJ_CODENT"	OF oSection1 ALIAS cAlias
	DEFINE CELL NAME "TFJ_LOJA"	OF oSection1 ALIAS cAlias
	DEFINE CELL NAME "A1_NOME"	OF oSection1 ALIAS cAlias
	DEFINE CELL NAME "A1_CGC"	OF oSection1 ALIAS cAlias

		oSection11 := TRSection():New(oSection1, STR0005, {aQbrTables[02,02]}, /*<aOrder>*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/,/*<lTotalInLine .T.*/ , /*<lHeaderPage> */.f., /*<lHeaderBreak>*/ .f. , /*<lPageBreak>*/ .F. , /*<lLineBreak>*/ ,/* <nLeftMargin>*/ 10 , /*<lLineStyle> */, /*<nColSpace>*/ , /*<lAutoSize> */, /*<cCharSeparator>*/ , /*<nLinesBefore> */, /*<nCols> */, /*<nClrBack> */, /*<nClrFore> */, /*<nPercentage> */ ) //"Custos do Cliente"
		oSection11:SetHeaderSection(.F.)
		oSection11:SetParentQuery(.f.)
		oSection11:SetRelation({|| (cAlias)->(TFJ_CODENT+TFJ_LOJA) }, aQbrTables[02,02] ,1,.F.)
		oSection11:SetParentFilter({|cParam| (aQbrTables[02,02])->(TFJ_CODENT+TFJ_LOJA) == cParam },{|| (cAlias)->(TFJ_CODENT+TFJ_LOJA) })
	
			DEFINE CELL NAME "TXG_CODIGO"	OF oSection11 ALIAS aQbrTables[02,02]
			DEFINE CELL NAME "TXG_DESCR"	OF oSection11 ALIAS aQbrTables[02,02]
			DEFINE CELL NAME "TXG_MOEDA"    OF oSection11 ALIAS aQbrTables[02,02]  SIZE Len(cMoeda) Block {|| cMoeda } 
			DEFINE CELL NAME "TXG_TOTAL"	OF oSection11 ALIAS aQbrTables[02,02] SIZE lEN(aQbrTables[02,07]) PICTURE aQbrTables[02,07]
			
		oSection12 := TRSection():New(oSection1, STR0006, {cAlias, "CN9"}, /*<aOrder>*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/ ,/*<lTotalInLine .T.*/ , /*<lHeaderPage> */.f., /*<lHeaderBreak>*/ .f. , /*<lPageBreak>*/ .F. , /*<lLineBreak>*/ ,/* <nLeftMargin>*/ 10 , /*<lLineStyle> */, /*<nColSpace>*/ , /*<lAutoSize> */, /*<cCharSeparator>*/ , /*<nLinesBefore> */, /*<nCols> */, /*<nClrBack> */, /*<nClrFore> */, /*<nPercentage> */ ) //"Contrato"
		oBreak12 := TRBreak():New( oSection12 , {|| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV) },""  , .F. ,  , .F. )
		oSection12:SetParentQuery(.f.)
		oSection12:SetRelation({|| (cAlias)->(TFJ_CODENT+TFJ_LOJA) }, cAlias ,1,.F.)
		oSection12:SetParentFilter({|cParam| (cAlias)->(TFJ_CODENT+TFJ_LOJA) == cParam },{|| (cAlias)->(TFJ_CODENT+TFJ_LOJA) })
		TRPosition():New(oSection12,"CN9", 1,{|| xFilial("CN9")+(cAlias)->(TFJ_CONTRT+TFJ_CONREV )}) 
			
		DEFINE CELL NAME "TFJ_CONTRT"	OF oSection12 ALIAS cAlias
		DEFINE CELL NAME "TFJ_CONREV"	OF oSection12 ALIAS cAlias
		
			oSect121 := TRSection():New(oSection12, STR0007, {aQbrTables[03,02]}, /*<aOrder>*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/,/*<lTotalInLine .T.*/ , /*<lHeaderPage> */.f., /*<lHeaderBreak>*/ .f. , /*<lPageBreak>*/ .F. , /*<lLineBreak>*/ ,/* <nLeftMargin>*/ 15 , /*<lLineStyle> */, /*<nColSpace>*/ , /*<lAutoSize> */, /*<cCharSeparator>*/ , /*<nLinesBefore> */, /*<nCols> */, /*<nClrBack> */, /*<nClrFore> */, /*<nPercentage> */ ) //"Custos do Contrato"
			oSect121:SetHeaderSection(.F.)
			oSect121:SetParentQuery(.f.)
			oSect121:SetRelation({|| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV) }, cAlias,1,.F.)
			oSect121:SetParentFilter({|cParam| (aQbrTables[03,02])->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV) == cParam },{|| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV) })
	
			DEFINE CELL NAME "TXG_CODIGO"	OF oSect121 ALIAS aQbrTables[03,02]
			DEFINE CELL NAME "TXG_DESCR"	OF oSect121 ALIAS aQbrTables[03,02]
			DEFINE CELL NAME "TXG_MOEDA"    OF oSect121 ALIAS aQbrTables[03,02]  SIZE Len(cMoeda) Block {|| cMoeda } 
			DEFINE CELL NAME "TXG_TOTAL"	OF oSect121 ALIAS aQbrTables[03,02] SIZE lEN(aQbrTables[03,07]) PICTURE aQbrTables[03,07]
	
			oSect122 := TRSection():New(oSection12, STR0008, {cAlias, "ABS"}, /*<aOrder>*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/,/*<lTotalInLine .T.*/ , /*<lHeaderPage> */.f., /*<lHeaderBreak>*/ .f. , /*<lPageBreak>*/ .F. , /*<lLineBreak>*/ ,/* <nLeftMargin>*/ 15 , /*<lLineStyle> */, /*<nColSpace>*/ , /*<lAutoSize> */, /*<cCharSeparator>*/ , /*<nLinesBefore> */, /*<nCols> */, /*<nClrBack> */, /*<nClrFore> */, /*<nPercentage> */ ) //"Local"
			oSect122:SetParentQuery(.f.)
			oSect122:SetRelation({|| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV) }, cAlias ,1,.F.)
			oSect122:SetParentFilter({|cParam| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV) == cParam },{|| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV) })
			oBreak122 := TRBreak():New( oSect122 , {|| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV+TFL_CODIGO+TFL_LOCAL) },""  , .F. ,  , .F. )
			TRPosition():New(oSect122,"ABS", 1,{|| xFilial("ABS")+(cAlias)->(TFL_LOCAL )}) 		
			
			DEFINE CELL NAME "TFL_CODIGO"	OF oSect122 ALIAS cAlias
			DEFINE CELL NAME "TFL_LOCAL"	OF oSect122 ALIAS cAlias
			DEFINE CELL NAME "TFL_LOCAL"	OF oSect122 ALIAS cAlias			
			DEFINE CELL NAME "ABS_DESCRI"	OF oSect122 ALIAS cAlias
			DEFINE CELL NAME "TFL_DTINI"	OF oSect122 ALIAS cAlias
			DEFINE CELL NAME "TFL_DTFIM"	OF oSect122 ALIAS cAlias
			
				oSect1221 := TRSection():New(oSect122, STR0009, {aQbrTables[04,02]}, /*<aOrder>*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/,/*<lTotalInLine .T.*/ , /*<lHeaderPage> */.f., /*<lHeaderBreak>*/ .f. , /*<lPageBreak>*/ .F. , /*<lLineBreak>*/ ,/* <nLeftMargin>*/ 20 , /*<lLineStyle> */, /*<nColSpace>*/ , /*<lAutoSize> */, /*<cCharSeparator>*/ , /*<nLinesBefore> */, /*<nCols> */, /*<nClrBack> */, /*<nClrFore> */, /*<nPercentage> */ ) //"Custos do Local"
				oSect1221:SetHeaderSection(.F.)
				oSect1221:SetParentQuery(.f.)
				oSect1221:SetRelation({|| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV+TFL_CODIGO+TFL_LOCAL) }, aQbrTables[04,02] ,1,.F.)
				oSect1221:SetParentFilter({|cParam| (aQbrTables[04,02])->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV+TFL_CODIGO+TFL_LOCAL) == cParam },{|| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV+TFL_CODIGO+TFL_LOCAL) })
		
				DEFINE CELL NAME "TXG_CODIGO"	OF oSect1221 ALIAS aQbrTables[04,02]
				DEFINE CELL NAME "TXG_DESCR"	OF oSect1221 ALIAS aQbrTables[04,02]
				DEFINE CELL NAME "TXG_MOEDA"    OF oSect1221 ALIAS aQbrTables[04,02]  SIZE Len(cMoeda) Block {|| cMoeda } 
				DEFINE CELL NAME "TXG_TOTAL"	OF oSect1221 ALIAS aQbrTables[04,02] SIZE lEN(aQbrTables[04,07]) PICTURE aQbrTables[04,07]
			
				oSect1222 := TRSection():New(oSect122, STR0010, {cAlias, "TFF"}, /*<aOrder>*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/,/*<lTotalInLine .T.*/ , /*<lHeaderPage> */.f., /*<lHeaderBreak>*/ .f. , /*<lPageBreak>*/ .F. , /*<lLineBreak>*/ ,/* <nLeftMargin>*/ 20 , /*<lLineStyle> */, /*<nColSpace>*/ , /*<lAutoSize> */, /*<cCharSeparator>*/ , /*<nLinesBefore> */, /*<nCols> */, /*<nClrBack> */, /*<nClrFore> */, /*<nPercentage> */ ) //"Item RH"
				oBreak122 := TRBreak():New( oSect1222 , {|| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV+TFL_CODIGO+TFL_LOCAL+TFF_COD+TFF_ITEM) },""  , .F. ,  , .F. )
				oSect1222:SetParentQuery(.f.)
				oSect1222:SetRelation({|| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV+TFL_CODIGO+TFL_LOCAL) }, cAlias ,1,.F.)
				oSect1222:SetParentFilter({|cParam| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV+TFL_CODIGO+TFL_LOCAL) == cParam },{|| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV+TFL_CODIGO+TFL_LOCAL) })
				TRPosition():New(oSect122,"TFF", 1,{|| xFilial("TFF")+(cAlias)->(TFF_COD )}) 		

				DEFINE CELL NAME "TFF_COD"	OF oSect1222 ALIAS cAlias			
				DEFINE CELL NAME "TFF_ITEM"	OF oSect1222 ALIAS cAlias
				DEFINE CELL NAME "TFF_PRODUT"	OF oSect1222 ALIAS cAlias			
				DEFINE CELL NAME "B1_DESC"	OF oSect1222 ALIAS cAlias
				DEFINE CELL NAME "B1_GRUPO"	OF oSect1222 ALIAS cAlias
				DEFINE CELL NAME "TFF_PERINI"	OF oSect1222 ALIAS cAlias			
				DEFINE CELL NAME "TFF_PERFIM"	OF oSect1222 ALIAS cAlias		

					oSect12221 := TRSection():New(oSect1222, STR0011, {cAlias}, /*<aOrder>*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/,/*<lTotalInLine .T.*/ , /*<lHeaderPage> */.f., /*<lHeaderBreak>*/ .f. , /*<lPageBreak>*/ .F. , /*<lLineBreak>*/ ,/* <nLeftMargin>*/ 25 , /*<lLineStyle> */, /*<nColSpace>*/ , /*<lAutoSize> */, /*<cCharSeparator>*/ , /*<nLinesBefore> */, /*<nCols> */, /*<nClrBack> */, /*<nClrFore> */, /*<nPercentage> */ ) //"Custos do Item RH"
					oSect12221:SetHeaderSection(.F.)
					oSect12221:SetParentQuery(.f.)
					oSect12221:SetRelation({|| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV+TFL_CODIGO+TFL_LOCAL+TFF_COD+TFF_ITEM) }, cAlias ,1,.F.)
					oSect12221:SetParentFilter({|cParam| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV+TFL_CODIGO+TFL_LOCAL+TFF_COD+TFF_ITEM) == cParam },{|| (cAlias)->(TFJ_CODENT+TFJ_LOJA+TFJ_CONTRT+TFJ_CONREV+TFL_CODIGO+TFL_LOCAL+TFF_COD+TFF_ITEM) })
			
					DEFINE CELL NAME "TXG_CODIGO"	OF oSect12221 ALIAS cAlias
					DEFINE CELL NAME "TXG_DESCR"	OF oSect12221 ALIAS cAlias
					DEFINE CELL NAME "TXG_MOEDA"    OF oSect12221 ALIAS cAlias  SIZE Len(cMoeda) Block {|| cMoeda } 
					DEFINE CELL NAME "TXG_TOTAL"	OF oSect12221 ALIAS cAlias SIZE lEN(aQbrTables[05,07]) PICTURE aQbrTables[05,07]

			
			oSection01 := TRSection():New(oReport, STR0012, {aQbrTables[01,02]}, /*<aOrder>*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/ ,/*<lTotalInLine .F.*/ , /*<lHeaderPage> */.f., /*<lHeaderBreak>*/ .f. , /*<lPageBreak>*/ .F. , /*<lLineBreak>*/.F. ,/* <nLeftMargin>*/ 0 , /*<lLineStyle> */, /*<nColSpace>*/ , /*<lAutoSize> */, /*<cCharSeparator>*/ , /*<nLinesBefore> */, /*<nCols> */, /*<nClrBack> */, /*<nClrFore> */, /*<nPercentage> */ ) //"Total Geral "
		    oBreak0 := TRBreak():New( oSection01 , {|| ""  },""  , .F. ,  , .F. )
		    oSection01:SetParentQuery(.F.)

			DEFINE CELL NAME "TXG_CODIGO"	OF oSection01 ALIAS aQbrTables[01,02] TITLE STR0013 //"TOTAL GERAL"
			DEFINE CELL NAME "TXG_DESCR"	OF oSection01 ALIAS aQbrTables[01,02] TITLE " "
			DEFINE CELL NAME "TXG_MOEDA"    OF oSection01 ALIAS aQbrTables[01,02]  TITLE " " SIZE Len(cMoeda) Block {|| cMoeda } 
			DEFINE CELL NAME "TXG_TOTAL"	OF oSection01 ALIAS aQbrTables[01,02] TITLE " " SIZE lEN(aQbrTables[01,07]) PICTURE aQbrTables[01,07]


Return oReport

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Gera o relatorio de Custos Operacionais

@author fabiana.silva
@since 06/11/2019
@version P12.1.27
@param oReport - Objeto report
@param aQbrTables - Array de tabelas
@return  oReport - Objeto Report
/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport(oReport, aQbrTables)
	Local oSection1 	:= oReport:Section(1)
	Local oSection01 	:= oReport:Section(2)
	Local cAlias2 		:= GetNextAlias()
	Local nChvOrc  		:= 0
	Local nPos 			:= 0
	Local nTotal 		:= 0
	Local nPosF 		:= 0
	Local nC 			:= 0
	Local nY 			:= 0
	Local cCodTab 		:= space(TamSX3("TFJ_CODTAB")[1])
	Local lRet 			:= .T. //Imprime Report
	Local aPlanKey 		:= {}
	Local aFieldPos	 	:= {}
	Local aTmpField 	:= {}
	Local aTabPE 		:= {}

	BeginSql Alias cAlias2

		SELECT
		X.*,
		Y.*
		FROM
		(
		SELECT TFJ.TFJ_CODENT,
		TFJ.TFJ_LOJA,
		SA1.A1_NOME,
		SA1.A1_CGC,
		TFJ.TFJ_CODIGO,
		TFJ.TFJ_CONTRT,
		TFJ.TFJ_CONREV,
		TFL.TFL_CODIGO,
		TFL.TFL_LOCAL,
		ABS.ABS_DESCRI,
		TFL.TFL_DTINI,
		TFL.TFL_DTFIM,
		TFF.TFF_COD,
		TFF.TFF_ITEM,
		TFF.TFF_PRODUT,
		SB1.B1_DESC,
		SB1.B1_GRUPO,
		TFF.TFF_PERINI,
		TFF.TFF_PERFIM,
		TFF.TFF_PRCVEN,
		TFF.TFF_QTDVEN,
		TFF.TFF_PLACOD,
		TFF.TFF_PLAREV,
		TFF.R_E_C_N_O_ AS TFF_REC
		From
		%table:TFF% TFF
		INNER JOIN %table:SB1% SB1 ON (SB1.%NotDel%  AND SB1.B1_FILIAL = %xfilial:SB1% AND SB1.B1_COD = TFF.TFF_PRODUT AND SB1.B1_GRUPO BETWEEN %exp:MV_PAR09% AND  %exp:MV_PAR10%  AND SB1.B1_COD BETWEEN   %exp:MV_PAR07% AND  %exp:MV_PAR08%  )
		INNER JOIN %table:ABS% ABS ON (ABS.%NotDel%  AND ABS.ABS_FILIAL = %xfilial:ABS% AND ABS.ABS_LOCAL BETWEEN %exp:MV_PAR05% AND  %exp:MV_PAR06% )
		INNER JOIN %table:TFL% TFL ON (TFL.%NotDel%  AND TFL.TFL_FILIAL = %xfilial:TFL% AND TFL.TFL_CODIGO = TFF_CODPAI AND TFL.TFL_LOCAL = ABS.ABS_LOCAL )
		INNER JOIN %table:SA1% SA1 ON (SA1.%NotDel%  AND SA1.A1_FILIAL = %xfilial:SA1% AND SA1.A1_COD BETWEEN %exp:MV_PAR01% AND  %exp:MV_PAR02% )
		INNER JOIN %table:TFJ% TFJ ON ( TFJ.TFJ_CODTAB = %exp:cCodTab% AND TFJ.TFJ_STATUS = '1'  AND TFJ.%NotDel%  AND TFJ.TFJ_FILIAL = %xfilial:TFJ% AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND TFJ.TFJ_CONTRT BETWEEN  %exp:MV_PAR03% AND  %exp:MV_PAR04%  AND TFJ.TFJ_CODENT||TFJ.TFJ_LOJA = SA1.A1_COD || SA1.A1_LOJA )
		WHERE
		TFF.TFF_PERFIM >= %exp:MV_PAR11% AND
		TFF.%NotDel%  AND TFF.TFF_FILIAL = %xfilial:TFF% )X,
		( SELECT DISTINCT TXG.TXG_CODIGO, TXG.TXG_DESCR FROM %table:TXG% TXG WHERE TXG.%NotDel%  AND TXG.TXG_FILIAL = %xfilial:TXG% ) Y
		ORDER BY X.TFJ_CODENT, X.TFJ_LOJA, X.TFJ_CONTRT, X.TFL_LOCAL, X.TFF_REC,  Y.TXG_CODIGO
	EndSql

	If !( cAlias2)->(Eof())
		//Busca a posição dos campos do alias de origem(query) para inserção
		For nC := 1 to Len(aQbrTables)
			(aQbrTables[nC, 02])->(DbSetOrder(1))
			//Indice da Quebra
			aTmpField := {}
			For nY := 1 to Len(aQbrTables[nC, 04])
				aAdd(aTmpField,( cAlias2)->(FieldPos(aQbrTables[nC, 04][nY])) )
			Next nY
			aQbrTables[nC, 05 ] :=  aClone(aTmpField)

			//Campos da Quebra
			aTmpField := {}
			For nY := 1 to Len(aQbrTables[nC, 03]) - 1
				aAdd(aTmpField,( cAlias2)->(FieldPos(aQbrTables[nC, 03][nY, 01])) )
			Next nY
			aQbrTables[nC, 06] := aClone(aTmpField)

		Next nC
	EndIf

	TXG->(DbSetOrder(1))
	Do While !( cAlias2)->(Eof())
		nTotal := 0
		If nChvOrc <> (cAlias2)->TFF_REC
			aPlanKey := {} //Zera os campos
			nChvOrc := (cAlias2)->TFF_REC
			TFF->(DbGoTo(nChvOrc))
			If !Empty(TFF->TFF_CALCMD)
				aPlanKey := ConvXML2Ar(TFF->TFF_CALCMD, aQbrTables[05,07])
			EndIf
			nPosF := Len(aPlanKey)
		EndIf
		If nPosF > 0 .AND. TXG->(DbSeek(xFilial("TXG")+(cAlias2)->(TXG_CODIGO+TFF_PLACOD)))
			nPos := 1
			Do While TXG->(!Eof())  .AND.  TXG->(TXG_FILIAL+TXG_CODIGO+TXG_PLANIL) =  xFilial("TXG")+(cAlias2)->(TXG_CODIGO+TFF_PLACOD)

				If  (nPos := aScan(aPlanKey, {|c| c[1] ==  Upper(AllTrim(TXG->TXG_CELULA))}, nPos, nPosF) ) > 0
					nTotal += (cAlias2)->TFF_QTDVEN * aPlanKey[nPos][02] * TXG->TXG_MULTI
				Else
					nPos := 1
				EndIf
				TXG->(dbSkip(1))
			EndDo

		EndIf

		AtualizaReg(cAlias2, nTotal, aQbrTables, 0, .T.)
		(cAlias2)->(dbSkip(1))

	EndDo

	If Len(aPlanKey) > 0
		aPlanKey := NIL
	EndIf

	For nC := 1 to Len(aQbrTables)
		(aQbrTables[nC, 02])->(DbSetOrder(1))
		(aQbrTables[nC, 02])->(DbGoTop())
	Next nC

	If ExistBlock("AtR993")
		aEval(aQbrTables, { |q| aAdd(aTabPE, {q[2], aClone(q[3]), aClone(q[4]) } ) } )
		lRet := ExecBlock("AtR993", .F., .F., {oReport, aTabPE})
		lRet := Valtype(lRet) = "L" .AND. lRet
	EndIf
	
	If lRet
		oSection1:Print()
		oSection01:Print()
	EndIf

Return oReport
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaReg
Verifica se Atualiza ou Insere o Registro

@author fabiana.silva
@since 06/11/2019
@version P12.1.27
@param cAliasOrig - Alias de Origem - Query
@param nTotal - Total da Agrupador
@param aQbrTables - Array de tabelas
@param nPosPai - Posicao do Pai
@param lSeekFil - Localiza os Registros nos filhos do array aQbrTables
@return nil
/*/
//-------------------------------------------------------------------------------------
Static Function AtualizaReg(cAliasOrig, nTotal, aQbrTables, nPosPai, lSeekFil)
	Local nC 			:= 0
	Local nY 			:= 0
	Local cChave 		:= ""
	Local cAliasD 		:= ""
	Local cAliasDest 	:= ""
	Local aFieldPos 	:= {}

	If nPosPai > 0
		cAliasDest := aQbrTables[nPosPai, 02]
		aFieldPos := aClone(aQbrTables[nPosPai, 06])
		If !lSeekFil
			RecLock(cAliasDest, .T.)
	
			For nC := 1 to Len(aFieldPos)
				(cAliasDest)->(FieldPut(nC, (cAliasOrig)->(FieldGet(aFieldPos[nC]))))
			Next nC
	
		Else
	
			RecLock(cAliasDest, .F.)
		EndIf
	
		(cAliasDest)->TXG_TOTAL += nTotal
		(cAliasDest)->(MsUnLock())
	
	EndIf

	nPosPai += 1
	For nC := nPosPai to Len(aQbrTables)
		cAliasD := aQbrTables[nC,02]
		cChave := ""
		If nPosPai = 5
			lSeekFil := .F.
		EndIf
		If lSeekFil //.OR. nPosPai = 4
			cChave := ""
			For nY := 1 to Len(aQbrTables[nC, 05])
				cChave += (cAliasOrig)->(FieldGet(aQbrTables[nC, 05][nY]))
			Next nY

			lSeekFil := (cAliasD)->(DbSeek(cChave))
		EndIf
		//Chamada recurssiva da rotina para processar os filhos
		AtualizaReg(cAliasOrig,nTotal, aQbrTables, nC, lSeekFil)
		Exit
	Next nC

Return
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ConvXML2Ar
Converte o XML da planilha em array com valores numericos informados

@author fabiana.silva
@since 06/11/2019
@version P12.1.27
@param cXML - XML a ser convrtido
@param lSeekFil - Localiza os Registros nos filhos do array aQbrTables
@return aPlanKey - Array contendo a seguinte estrutura
		aPlanKey[n, 01] - Nome de Celula (Maiúsculo)
        aPlanKey[n, 02] - Valor
/*/
//-------------------------------------------------------------------------------------
Static Function ConvXML2Ar(cXML, cDefPicture)
	Local oPlanil 	:= {}
	Local aDtObj 	:= {}
	Local aPlanKey 	:= {}
	Local cError 	:= ""
	Local cWarning 	:= ""
	Local nC 		:= 0
	Local nPos 		:= 0
	Local cPicture := ""
	
	oPlanil := XmlParser(cXml, "_", @cError, @cWarning)

	If Empty(cError)

		aDtObj :=   ClassDataArr(oPlanil:_FWMODELSHEET:_MODEL_SHEET:_MODEL_CELLS:_ITEMS)

		If (nPos := ascan(aDtObj, { |a| a[1] == "_ITEM"}) ) > 0
			If Valtype(aDtObj[nPos][02]) = "O"
				aAdd(aObj, aDtObj[nPos][02])
			Else
				aObj := aClone(aDtObj[nPos][02])
			EndIf

			For  nC := 1 to  Len(aObj)

				If (!AttIsMemberOf(aObj[nc], "_DELETED") .OR. aObj[nc]:_DELETED:TEXT ="0") .AND. ;
				(AttIsMemberOf(aObj[nc], "_NAME") .AND. !Empty(aObj[nc]:_NAME:TEXT))  .AND. ;
				(AttIsMemberOf(aObj[nc], "_VALUE") .AND. !Empty(Val(aObj[nc]:_VALUE:TEXT)))
				
					If AttIsMemberOf(aObj[nc], "_PICTURE") .AND. !Empty(aObj[nc]:_PICTURE:TEXT)
						cPicture := aObj[nc]:_PICTURE:TEXT
					Else
						cPicture := cDefPicture
					EndIf
					
					cPicture := StrTran(StrTran(StrTran(cPicture, "@E", ""),","),"@")
					
					cPicture := AllTrim(Transform(Val(aObj[nc]:_VALUE:TEXT), cPicture))
					
					If Val(cPicture) > 0
				
						aAdd(aPlanKey, {Upper(AllTrim(aObj[nc]:_NAME:TEXT)), Val(cPicture)})
					EndIf
				EndIf
			Next nC
		EndIf

		aDtObj := {}
		FreeObj(oPlanil)
		aSort(aPlanKey,,,{|x,y| x[1] < Y[1]})
	EndIf
	
Return aPlanKey

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CreateStruct
Cria as tabelas temporárias
@author fabiana.silva
@since 06/11/2019
@version P12.1.27
@param nOption - Opção da Tabela
@param cTblAlias - Alias da Tabela
@param aFields - Campos da Tabela - Retorno referencia
@param aIndice - Campos da Tabela - Retorno referencia
@param cPictTot - Picture do totalizador - Retorno referencia
@return oTempTable - Objeto FWTemporaryTable
/*/
//-------------------------------------------------------------------------------------
Static Function CreateStruct( nOption, cTblAlias, aFields, aIndice, cPictTot)
	Local oTempTable 	:= NIL
	Local nC 			:= 0
	Local aCampos 		:= {}
	Local nDecQtde		:= GETSX3CACHE("TFF_QTDVEN", "X3_DECIMAL")
	Local nDecPrc		:= GETSX3CACHE("TFF_PRCVEN", "X3_DECIMAL") * 2
	Local nDecimais		:= nDecQtde + nDecPrc

	Do Case
		Case nOption  = 0 //Totalizador
		aIndice :=  { "TXG_CODIGO"}
		aCampos := { "TXG_CODIGO", "TXG_DESCR", "TFF_PRCVEN" }

		Case nOption  = 1 //Cliente
		aIndice :=  {"TFJ_CODENT", "TFJ_LOJA", "TXG_CODIGO"}
		aCampos := {"TFJ_CODENT", "TFJ_LOJA", "TXG_CODIGO", "TXG_DESCR", "TFF_PRCVEN" }

		Case nOption  = 2 //Contrato
		aIndice :=  {"TFJ_CODENT", "TFJ_LOJA", "TFJ_CONTRT", "TFJ_CONREV",  "TXG_CODIGO"}
		aCampos := {"TFJ_CODENT", "TFJ_LOJA", "TFJ_CONTRT", "TFJ_CONREV", "TXG_CODIGO", "TXG_DESCR", "TFF_PRCVEN" }

		Case nOption = 3 //Local
		aIndice :=  {"TFJ_CODENT", "TFJ_LOJA", "TFJ_CONTRT", "TFJ_CONREV", "TFL_CODIGO", "TFL_LOCAL", "TXG_CODIGO"}
		aCampos := {"TFJ_CODENT", "TFJ_LOJA", "TFJ_CONTRT", "TFJ_CONREV",  "TFL_CODIGO", "TFL_LOCAL",  "TXG_CODIGO", "TXG_DESCR", "TFF_PRCVEN" }

		Case nOption  = 4
		aIndice :=  {"TFJ_CODENT", "TFJ_LOJA", "TFJ_CONTRT","TFJ_CONREV", "TFL_CODIGO", "TFL_LOCAL", "TFF_ITEM", "TXG_CODIGO"}
		aCampos := {"TFJ_CODENT", "TFJ_LOJA", "A1_NOME", "A1_CGC", "TFJ_CODIGO","TFJ_CONTRT", "TFJ_CONREV", "TFL_CODIGO", "TFL_LOCAL", "ABS_DESCRI", "TFL_DTINI", "TFL_DTFIM", "TFF_COD", "TFF_ITEM", "TFF_PRODUT", "B1_DESC ", "B1_GRUPO", "TFF_PERINI", "TFF_PERFIM", "TXG_CODIGO", "TXG_DESCR", "TFF_PRCVEN" }

	EndCase
	//--------------------------
	//Monta os campos da tabela
	//--------------------------
	If Len(aCampos) > 0
	
		For nC := 1 to Len(aCampos)
			aadd(aFields,{aCampos[nC],GETSX3CACHE(aCampos[nC], "X3_TIPO"), GETSX3CACHE(aCampos[nC], "X3_TAMANHO"),GETSX3CACHE(aCampos[nC], "X3_DECIMAL")})
		Next nC
	
		aTail(aFields)[01] := "TXG_TOTAL"
		aTail(aFields)[03] :=  (( aTail(aFields)[03] - aTail(aFields)[04]  ) + nDecimais ) +  ((4 - nOption ) * 2) 
		aTail(aFields)[04] :=  nDecimais
		
		nC := 1
		For nC := 1 to aTail(aFields)[03]-(aTail(aFields)[04]+1)
			cPictTot := "9"+cPictTot
			If nC % 3 = 0
				cPictTot := ","+cPictTot
			EndIf
		Next
		
		If Left(cPictTot,1)= ","
			cPictTot := Substr(cPictTot, 2)
		EndIf
		
		cPictTot := "@E " + cPictTot + "."+Replicate("9", 2)
	
		oTempTable := FWTemporaryTable():New( cTblAlias, aFields )
		If Len(aIndice) > 0
			oTempTable:AddIndex("01", aIndice )
		EndIf
		oTempTable:Create()
	EndIf
	
Return oTempTable

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPergTRp
Retorna o nome do Pergunte utilizado no relatório
Função utilizada na automação
@author Junior Geraldo
@since 29/05/2020
@return cAutoPerg, string, nome do pergunte
/*/
//-------------------------------------------------------------------------------------
Static Function GetPergTRp()

Return cAutoPerg
