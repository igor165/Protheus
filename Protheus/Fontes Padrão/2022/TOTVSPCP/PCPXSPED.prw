#Include "Protheus.ch"
#Include "TbIconn.ch"

Static oSD3 := NIL
Static oSB1 := NIL
Static oSC2 := NIL

/*------------------------------------------------------------------------//
//Programa:	  PCPLayout 
//Autor:	  Ricardo Prandi 
//Data:		  11/09/2018
//Descricao:  Funcao responsavel pela montagem do layout das tabelas
//            tempor·rias do bloco K para o PCP
//Parametros: 1 - cBloco   - Nome do bloco para geracao do Layout
//            2 - aCampos  - Array com os campos que dever„o ser criados
//            3 - aIndices - Array com os Ìndices que dever„o ser criados
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/
Function PCPLayout(cBloco,aCampos,aIndices,cVersSped)

Local nTamFil		:= TamSX3("D1_FILIAL" )[1]
Local nTamDt		:= TamSX3("D1_DTDIGIT")[1]
Local nTamOP		:= TamSX3("D3_OP"     )[1]
Local nTamCod		:= TamSX3("B1_COD"    )[1]
// ------ Tamanhos conforme especificado no Guia EFD ------
Local nTamReg		:= 4
Local aTamQtd		:= {16,If(cVersSped < '013',3,6)}

Do Case
	Case cBloco == "K230"
		//Criacao do Arquivo de Trabalho - BLOCO K230              
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"DT_INI_OP"	,"D",nTamDt				,0})
		AADD(aCampos,{"DT_FIN_OP"	,"D",nTamDt				,0})
		AADD(aCampos,{"COD_DOC_OP"	,"C",nTamOP				,0})
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD_ENC"		,"N",aTamQtd[1],aTamQtd[2]})
		AADD(aCampos,{"QTDORI"		,"N",aTamQtd[1],aTamQtd[2]}) // Nao integra Bloco K
		// Indices
		AADD(aIndices,{"FILIAL","COD_DOC_OP","COD_ITEM"})
	
	Case cBloco == "K235"
		//Criacao do Arquivo de Trabalho - BLOCO K235             
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"DT_SAIDA"	,"D",nTamDt				,0})
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtd[1],aTamQtd[2]})
		AADD(aCampos,{"COD_INS_SU"	,"C",nTamCod			,0})
		AADD(aCampos,{"COD_DOC_OP"	,"C",nTamOP				,0}) // Nao integra Bloco K
		AADD(aCampos,{"EMPENHO"		,"C",1					,0}) // Nao integra Bloco K
		// Indices
		AADD(aIndices,{"FILIAL","COD_DOC_OP","COD_ITEM"})
	
	Case cBloco == "K260"
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Criacao do Arquivo de Trabalho - BLOCO K260              ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"COD_OP_OS"	,"C",nTamOP				,0})
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"DT_SAIDA"	,"D",nTamDt				,0})
		AADD(aCampos,{"QTD_SAIDA"	,"N",aTamQtd[1],aTamQtd[2]})
		AADD(aCampos,{"DT_RET"		,"D",nTamDt				,0})
		AADD(aCampos,{"QTD_RET"		,"N",aTamQtd[1],aTamQtd[2]})
		// Indices
		AADD(aIndices,{"FILIAL","COD_OP_OS","COD_ITEM"})
		
	Case cBloco == "K265"
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Criacao do Arquivo de Trabalho - BLOCO K265              ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"COD_OP_OS"	,"C",nTamOP				,0}) // Nao integra Bloco K
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD_CONS"	,"N",aTamQtd[1],aTamQtd[2]})
		AADD(aCampos,{"QTD_RET"		,"N",aTamQtd[1],aTamQtd[2]})
		// Indices
		AADD(aIndices,{"FILIAL","COD_OP_OS","COD_ITEM"})
		
	Case cBloco == "K290"
		//CriaÁ„o do Arquivo de Trabalho - BLOCO K290
		aCampos := {}
		AADD(aCampos,{"FILIAL"      ,"C",nTamFil            ,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"         ,"C",nTamReg            ,0})
		AADD(aCampos,{"DT_INI_OP"   ,"D",nTamDt             ,0})
		AADD(aCampos,{"DT_FIN_OP"	,"D",nTamDt				,0})
		AADD(aCampos,{"COD_DOC_OP"	,"C",nTamOP				,0})
		// Indices
		AADD(aIndices,{"FILIAL","COD_DOC_OP"})
		
	Case cBloco == "K291"
		//CriaÁ„o do Arquivo de Trabalho - BLOCO K291
		aCampos := {}
		AADD(aCampos,{"FILIAL"      ,"C",nTamFil            ,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"         ,"C",nTamReg            ,0})
		AADD(aCampos,{"COD_DOC_OP"	,"C",nTamOP				,0}) // Nao integra Bloco K
		AADD(aCampos,{"COD_ITEM "   ,"C",nTamCod            ,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtd[1],aTamQtd[2]})
		// Indices
		AADD(aIndices,{"FILIAL","COD_DOC_OP","COD_ITEM"})
		
	Case cBloco == "K292"
		//CriaÁ„o do Arquivo de Trabalho - BLOCO K292
		aCampos := {}
		AADD(aCampos,{"FILIAL"      ,"C",nTamFil            ,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"         ,"C",nTamReg            ,0})
		AADD(aCampos,{"COD_DOC_OP"	,"C",nTamOP				,0}) // Nao integra Bloco K
		AADD(aCampos,{"COD_ITEM "   ,"C",nTamCod            ,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtd[1],aTamQtd[2]})
		// Indices
		AADD(aIndices,{"FILIAL","COD_DOC_OP","COD_ITEM"})
		
EndCase

Return {aCampos,aIndices}

/*------------------------------------------------------------------------//
//Programa:	  REGANTG 
//Autor:	  Ricardo Peixoto
//Data:		  11/10/2018
//Descricao:  Funcao responsavel pelo ajuste do legado SD3
//Parametros: 1 - dDataDe		- Data Inicial da Apuracao   
//			  2 - dDataAte		- Data Final da Apuracao 
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGANTG(dDataDe,dDataAte)

Local cQuery	 := ""
Local cAliasTmp  := GetNextAlias()
Local cMes       := Month(dDataDe)
Local cAno       := Year(dDataDe)
Local lInicializ := .T.
Local dData

//Verifica se È primeira vez
cQuery := " select count (*) REGISTROS from "+RetSqlName("SD3") + " SD3 where SD3.D3_PERBLK <> '" + PADR(Nil,tamSX3('D3_PERBLK')[1]) + "' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
If (cAliasTmp)->REGISTROS > 0
	lInicializ := .F.
EndIf
(cAliasTmp)->(dbCloseArea())

If lInicializ == .T.
	dData := FirstDate(dDataDe)
	dData := DaySub(dData,1)
	cMes := Month(dData)
	cAno := Year(dData)
	cQuery := " UPDATE "+RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2) + STR(cAno,4) + "' WHERE D3_EMISSAO <= '" + DtoS(dData) + "' "
	MATExecQry(cQuery)
EndIf

Return

/*------------------------------------------------------------------------//
//Programa:	  REGESTOR 
//Autor:	  Ricardo Peixoto
//Data:		  11/10/2018
//Descricao:  Funcao responsavel pelo ajuste de estornos considerados em sped posterior
//Parametros: 1 - dDataDe		- Data Inicial da Apuracao   
//			  2 - dDataAte		- Data Final da Apuracao 
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGESTOR(dDataDe,dDataAte)

Local cQuery	 := ""
Local cAliasTmp  := GetNextAlias()
Local cMes       := Month(dDataDe)
Local cAno       := Year(dDataDe)
Local cFuncSubst:= If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX","SUBSTR","SUBSTRING")

cQuery := " UPDATE "+RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2) + STR(cAno,4) + "' " +;
			" WHERE D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +;
			" AND D3_PERBLK <> '" + PADR(Nil,tamSX3('D3_PERBLK')[1]) + "' " +;
			" AND '01/"+STR(cMes,2)+'/'+STR(cAno,4)+"' < '01/'"+MatiConcat()+cFuncSubst+"(D3_PERBLK,1,2)"+MatiConcat()+"'/'"+MatiConcat()+cFuncSubst+"(D3_PERBLK,3,4) "
MATExecQry(cQuery)

Return

/*------------------------------------------------------------------------//
//Programa:	  SETPERBLK 
//Autor:	  Ricardo Peixoto
//Data:		  24/10/2018
//Descricao:  Funcao responsavel pelo ajuste do campo PERBLK
//Parametros: 1 - cPERBLK		- Conte˙do atual D3_PERBLK
//			  2 - iSD3RECNO		- Recno a ser alterado
//			  2 - cMes			- Mes da extraÁ„o
//			  2 - cAno			- Ano da extraÁ„o
//Uso: 		  PCPXSPED
//------------------------------------------------------------------------*/

Function SETPERBLK(cPERBLK, iSD3RECNO, cMes, cAno)
Local cQuery		:= ""

//carrega o periodo em que o registro foi considerado no bloco
If cPERBLK == PADR(Nil,tamSX3('D3_PERBLK')[1])
	//grava D3 como processado
	cQuery := " UPDATE " + RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2)+STR(cAno,4) + "' WHERE R_E_C_N_O_ = " + STR(iSD3RECNO)
	MATExecQry(cQuery)
ElseIf (CtoD('01/'+STR(cMes,2)+'/'+STR(cAno,4)) - CtoD('01/'+SubStr(cPERBLK,1,2)+'/'+SubStr(cPERBLK,3,4))) < 0
	//grava D3 como processado
	cQuery := " UPDATE " + RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2)+STR(cAno,4) + "' WHERE R_E_C_N_O_ = " + STR(iSD3RECNO)
	MATExecQry(cQuery)
EndIf

Return


/*------------------------------------------------------------------------//
//Programa:	  REGK230 
//Autor:	  Ricardo Prandi 
//Data:		  10/09/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K230
//Parametros: 1 - cAliK230		- Alias do arquivo de trabalho do Bloco
//            2 - cAliK235      - Alias do arquivo de trabalho do K235
//            3 - cAli0210      - Alias do arquivo de trabalho do 0210   
//			  4 - dDataDe		- Data Inicial da Apuracao   
//			  5 - dDataAte		- Data Final da Apuracao 
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK230(cAliK230,cAliK235,cAli0210,dDataDe,dDataAte,lRepross)

Local cQuery	 := ""
Local cAliasTmp  := GetNextAlias()
Local cDadosProd := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cSVSFilial := ""
Local cMes       := Month(dDataDe)
Local cAno       := Year(dDataDe)
Local cChamada   := If (lRepross, "SPEDFISCAL", "MATR241   ")
Local cCharSoma  := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ")
Local OVALMINIMO

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("SVS") + " WHERE VS_FILIAL ='"+xFilial("SVS")+"' AND VS_MESSPED = '" + STR(cMes,2) + "' AND VS_ANOSPED = '" + STR(cAno,4) + "' AND VS_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

If TCGetDB() $ "DB2/400/INFORMIX"

	If TCIsView("VWORDEM")
		cQuery := " DROP VIEW VWORDEM "
		MATExecQry(cQuery)
	EndIf  
	    
	//Busca os dados para geraÁ„o do K230
	cQuery := " CREATE VIEW VWORDEM AS " +; 
	" SELECT Sum(CASE " +; 
	            " WHEN SD3C.D3_CF LIKE ( 'DE%' ) THEN ( " +; 
	            " SD3C.D3_QUANT *- 1 ) " +; 
	            " WHEN SD3C.D3_CF LIKE ( 'RE%' ) THEN " +; 
	            " ( SD3C.D3_QUANT ) " +; 
	            " ELSE 0 " +; 
	        " END) AS QUANT, " +; 
	        " SD3C.D3_COD, " +; 
	        " SD3C.D3_OP " +; 
	" FROM   " + RetSqlName("SD3") + " SD3C " +; 
	        " JOIN " + RetSqlName("SB1") + " SB1 " +; 
	            " ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " +; 
	            " AND SB1.B1_COD = SD3C.D3_COD " +; 
	            " AND SB1.D_E_L_E_T_ <> '*' " +; 
	        " JOIN " + RetSqlName("SC2") + " SC2 " 
	//n„o usar ChangeQuery pois converte errado o create view
	cQuery += " ON SD3C.D3_OP = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "
	cQuery += 	" AND SC2.C2_FILIAL = '" + xFilial('SC2') + "' " +; 
	            " AND SC2.D_E_L_E_T_ <> '*' " +; 
	            " AND SC2.C2_ITEM <> 'OS' " +; 
	            " AND SC2.C2_TPPR IN ( 'I', ' ' ) " +; 
	        " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
	            " ON SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " +; 
	            " AND SB1_OP.B1_COD = SC2.C2_PRODUTO " +; 
	            " AND SB1_OP.D_E_L_E_T_ <> '*' " +; 
	        " LEFT JOIN " + RetSqlName("SD3") + " SD3 " +; 
			   " ON SD3.D3_FILIAL = '" + xFilial('SD3') + "' " +; 
		       " AND SD3.D_E_L_E_T_ <> '*' " +; 
		       " AND SD3.D3_OP = SD3C.D3_OP " +; 
		       " AND SD3.D3_CF IN ( 'PR0', 'PR1' ) " +; 
		       " AND SD3.D3_COD NOT LIKE 'MOD%' " +; 
		       " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "
	            
	cQuery += " AND SB1.B1_TIPO "
	
	cQuery += " IN (" + cTipo03 + "," + cTipo04 + ") " +; 
	         " AND SD3.D_E_L_E_T_ <> '*' " +;
	" WHERE  SD3C.D3_FILIAL = '" + xFilial('SD3') + "' " +; 
	        " AND SD3C.D3_COD <> SC2.C2_PRODUTO " +; 
	        " AND SD3C.D_E_L_E_T_ <> '*' " +; 
	" GROUP  BY SD3C.D3_OP, " +; 
	            " SD3C.D3_COD, " +; 
	            " SD3C.D3_FILIAL "
	//n„o usar ChangeQuery pois converte errado o create view
	MATExecQry(cQuery)
	
	
	
	cQuery := " SELECT SUM(SD3.D3_QUANT) AS QUANT, " +;
	                 " SD3.D3_OP, " +;
	                 " SD3.D3_COD, " +;
	                 " SD3.D3_FILIAL, " +;
	                 " SD3.D3_PERBLK, " +;
	                 " SD3.R_E_C_N_O_ AS SD3RECNO, " +;
	                 " SD3.D3_ESTORNO, "                 
	
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO), " 
	Else
		cQuery += "SB1.B1_TIPO, "
	EndIf
	
	cQuery += " SC2.C2_DATPRI AS DTINI, " +; 
	          " SC2.C2_DATRF AS DTFIM, " +; 
	          " SC2.C2_QUANT AS QTDORI, "
	cQuery += " (SELECT Min(ORDEM.QUANT)  " +; 
		            " FROM   VWORDEM ORDEM  " +; 
		            " WHERE  ORDEM.D3_OP = SD3.D3_OP) AS VALMINIMO " +;
	     " FROM "+RetSqlName("SD3") + " SD3 " +;
	     " JOIN "+RetSqlName("SB1") + " SB1 " +; 
	       " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	      " AND SB1.B1_COD     = SD3.D3_COD " +; 
	      " AND SB1.D_E_L_E_T_ <> '*' "
	      
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
		                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
		                " AND SBZ.D_E_L_E_T_ <> '*' "
	EndIf
	
	cQuery += " JOIN " + RetSqlName("SC2") + " SC2 " +; 
	            " ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD " +; 
	           " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
	           " AND SC2.D_E_L_E_T_ <> '*' " +;
	           " AND SC2.C2_ITEM    <> 'OS' " +; 
	           " AND SC2.C2_PRODUTO = SD3.D3_COD " +; 
	           " AND SC2.C2_TPPR    IN ('I',' ') "
	
	cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
	           " AND SD3.D_E_L_E_T_ <> '*' " +; 
	           " AND SD3.D3_OP      <> ' ' " +; 
	           " AND SD3.D3_CF      IN ('PR0','PR1') " +; 
	           " AND SD3.D3_COD     NOT LIKE 'MOD%' " +; 
	           " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
	           " AND SB1.B1_CCCUSTO = ' ' "
	            
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) " 
	Else
		cQuery += " AND SB1.B1_TIPO "
	EndIf
	
	cQuery += " IN (" + cTipo03 + "," + cTipo04 + ") " +; 
	          " AND SD3.D_E_L_E_T_ <> '*' "
	cQuery += " AND SD3.D3_ESTORNO <> 'S' "
	cQuery += " GROUP BY SD3.D3_OP, " +; 
	                " SD3.D3_COD, " +; 
	                " SD3.D3_FILIAL, "
	
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO), " 
	Else
		cQuery += " SB1.B1_TIPO, "
	EndIf
	
	cQuery += " SC2.C2_DATPRI, " +; 
	          " SC2.C2_DATRF, " +; 
	          " SC2.C2_QUANT, "
	          
	cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_ESTORNO "

Else

	//Busca os dados para geraÁ„o do K230
	cQuery := " SELECT Sum(SD3.D3_QUANT)                         AS QUANT, " +;
				"        SD3.D3_OP, " +;
				"        SD3.D3_COD, " +;
				"        SD3.D3_FILIAL, " +;
				"        SD3.D3_PERBLK, " +;
				"        SD3.R_E_C_N_O_                            AS SD3RECNO, " +;
				"        SD3.D3_ESTORNO, " +;
				"        SB1.B1_TIPO, " +;
				"        SC2.C2_DATPRI                             AS DTINI, " +;
				"        SC2.C2_DATRF                              AS DTFIM, " +;
				"        SC2.C2_QUANT                              AS QTDORI, " +;
				"        ORDEM.VALMINIMO " +;
				" FROM   " + RetSqlName("SD3") + " SD3 " +;
				"        JOIN " + RetSqlName("SB1") + " SB1 " +;
				"          ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " +;
				"             AND SB1.B1_COD = SD3.D3_COD " +;
				"             AND SB1.D_E_L_E_T_ <> '*' " +;
				"        JOIN " + RetSqlName("SC2") + " SC2 "
				//tratamento para a concatenÁ„o no postgres.		
				If TCGetDB() $ "POSTGRES"
					cQuery += "	ON SD3.D3_OP = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) "
				Else
					cQuery += "	ON SD3.D3_OP = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD " 
				EndIf	

				cQuery +="    AND SC2.C2_FILIAL = '" + xFilial('SC2') + "' " +;
				"             AND SC2.D_E_L_E_T_ <> '*' " +;
				"             AND SC2.C2_ITEM <> 'OS' " +;
				"             AND SC2.C2_PRODUTO = SD3.D3_COD " +;
				"             AND SC2.C2_TPPR IN ( 'I', ' ' ) " +;
				"         JOIN   (SELECT ORDEM01.D3_OP, Min(ORDEM01.QUANT) AS VALMINIMO " +;
				"                 FROM   (SELECT Sum(CASE " +;
				"                                      WHEN SD3C.D3_CF LIKE ( 'DE%' ) THEN ( " +;
				"                                      SD3C.D3_QUANT *- 1 ) " +;
				"                                      WHEN SD3C.D3_CF LIKE ( 'RE%' ) THEN " +;
				"                                      ( SD3C.D3_QUANT ) " +;
				"                                      ELSE 0 " +;
				"                                    END) AS QUANT, " +;
				"                                SD3C.D3_COD, " +;
				"                                SD3C.D3_OP " +;
				"                         FROM   " + RetSqlName("SD3") + " SD3C " +;
				"                                JOIN " + RetSqlName("SB1") + " SB1 " +;
				"                                  ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " +;
				"                                     AND SB1.B1_COD = SD3C.D3_COD " +;
				"                                     AND SB1.D_E_L_E_T_ <> '*' " +;
				"                                JOIN " + RetSqlName("SC2") + " SC2 "

				//tratamento para a concatenÁ„o no postgres.		
				If TCGetDB() $ "POSTGRES"
					cQuery += "	ON SD3C.D3_OP = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) "
				Else
					cQuery += "	ON SD3C.D3_OP = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD " 
				EndIf	
				
				cQuery += "                                     AND SC2.C2_FILIAL = '" + xFilial('SC2') + "' " +;
				"                                     AND SC2.D_E_L_E_T_ <> '*' " +;
				"                                     AND SC2.C2_ITEM <> 'OS' " +;
				"                                     AND SC2.C2_TPPR IN ( 'I', ' ' ) " +;
				"                                JOIN " + RetSqlName("SB1") + " SB1_OP " +;
				"                                  ON SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " +;
				"                                     AND SB1_OP.B1_COD = SC2.C2_PRODUTO " +;
				"									  AND SB1_OP.B1_TIPO NOT IN (" + cTipo05 + ") " +;
				"                                     AND SB1_OP.D_E_L_E_T_ <> '*' " +;
				"                         WHERE  SD3C.D3_FILIAL = '" + xFilial('SD3') + "' " +;
				"                                AND SD3C.D3_COD <> SC2.C2_PRODUTO " +;
				"                                AND SD3C.D_E_L_E_T_ <> '*' " +;
				"                         GROUP  BY SD3C.D3_OP, " +;
				"                                   SD3C.D3_COD, " +;
				"                                   SD3C.D3_FILIAL) ORDEM01 " +;
				"                         GROUP  BY ORDEM01.D3_OP) ORDEM " +;
				"           ON ORDEM.D3_OP = SD3.D3_OP " +;     
				" WHERE  SD3.D3_FILIAL = '" + xFilial('SD3') + "' " +;
				"        AND SD3.D_E_L_E_T_ <> '*' " +;
				"        AND SD3.D3_OP <> ' ' " +;
				"        AND SD3.D3_CF IN ( 'PR0', 'PR1' ) " +;
				"        AND SD3.D3_COD NOT LIKE 'MOD%' " +;
				"        AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +;
				"        AND SB1.B1_CCCUSTO = ' ' " +;
				"        AND SB1.B1_TIPO IN (" + cTipo03 + "," + cTipo04 + ") " +;
				"        AND SD3.D_E_L_E_T_ <> '*' " +;
				"        AND SD3.D3_ESTORNO <> 'S' " +;
				" GROUP  BY SD3.D3_OP, " +;
				"           SD3.D3_COD, " +;
				"           SD3.D3_FILIAL, " +;
				"           SB1.B1_TIPO, " +;
				"           SC2.C2_DATPRI, " +;
				"           SC2.C2_DATRF, " +;
				"           SC2.C2_QUANT, " +;
				"           SD3.D3_PERBLK, " +;
				"           SD3.R_E_C_N_O_, " +;
				"           SD3.D3_ESTORNO, " +;
				"           ORDEM.VALMINIMO "
	
	
	

EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

cSVSFilial := xFilial("SVS")

While !(cAliasTmp)->(Eof())

	OVALMINIMO := (cAliasTmp)->VALMINIMO
	If OVALMINIMO != Nil .And. OVALMINIMO < 0
		//verifica se tem 235
		dbSelectArea("SVT")
		dbSetOrder(2)
		dbSeek(xFilial("SVT")+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP)
		While !Eof() .And. VT_OP == (cAliasTmp)->D3_OP
			OVALMINIMO := 1
			SVT->(dbSkip())
		End
	EndIf

	If OVALMINIMO != Nil .And. OVALMINIMO < 0
		(cAliasTmp)->(dbSkip())
	Else
	
		SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
		
		//grava tabela fÌsica para guardar histÛrico
		SVS->(dbSetOrder(2))
		If !SVS->(dbSeek(cSVSFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
	
			//************************************************************************
			// Bloco K230
			//************************************************************************
			Reclock("SVS",.T.)
			SVS->VS_PRGORI  := cChamada
			SVS->VS_FILIAL  := cSVSFilial
			SVS->VS_MESSPED := STR(cMes,2)
			SVS->VS_ANOSPED := STR(cAno,4)
			SVS->VS_REG     := "K230"
			SVS->VS_DTINIOP := GetIniProd((cAliasTmp)->D3_OP)
			SVS->VS_DTFIMOP := If(StoD((cAliasTmp)->DTFIM) > dDataAte,StoD(""),StoD((cAliasTmp)->DTFIM))
			SVS->VS_OP      := (cAliasTmp)->D3_OP
			SVS->VS_PRODUTO := (cAliasTmp)->D3_COD
			SVS->VS_QTDENC  := (cAliasTmp)->QUANT
			SVS->VS_QTDORI  := (cAliasTmp)->QTDORI
			SVS->(MsUnlock())
			
			(cAliasTmp)->(dbSkip())
			
		Else
			//************************************************************************
			// Bloco K230 - ajuste de quantidades em multiplos apontamentos
			//************************************************************************	
			SVS->(dbSeek(cSVSFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		    While SVS->(!Eof()) .And. SVS->VS_FILIAL == cSVSFilial .And. SVS->VS_MESSPED == STR(cMes,2) .And. SVS->VS_ANOSPED == STR(cAno,4) .And. SVS->VS_OP == (cAliasTmp)->D3_OP .And. SVS->VS_PRODUTO == (cAliasTmp)->D3_COD .And. SVS->VS_PRGORI == cChamada
		    	RecLock("SVS",.F.,.T.)
		    	SVS->VS_QTDENC += (cAliasTmp)->QUANT
		    	SVS->(MsUnlock())
				SVS->(dbSkip())
		    EndDo
			(cAliasTmp)->(dbSkip())
		EndIf
	
	EndIf
			
EndDo

(cAliasTmp)->(dbCloseArea())

If TCIsView("VWORDEM")
	cQuery := " DROP VIEW VWORDEM "
	MATExecQry(cQuery)
EndIf

//Inicia a Gravacao das Producoes Zeradas, nas situacoes em que houveram apenas Requisicoes no Periodo de Apuracao
cQuery := " SELECT DISTINCT SVT.VT_OP, " +;
                          " SC2.C2_DATRF, " +;
                          " SC2.C2_PRODUTO, " +;
                          " SC2.C2_QUANT, "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) AS TIPO "
Else
	cQuery += "SB1.B1_TIPO AS TIPO "
EndIf

cQuery += " FROM " + RetSqlName("SVT") + " SVT "

cQuery += 	" JOIN " + RetSqlName("SC2") + " SC2 " +;
          	" ON SVT.VT_FILIAL = '" + xFilial("SVT") + "' " +;
          	" AND SC2.C2_FILIAL = '" + xFilial("SC2") + "' " +;
          	" AND SC2.D_E_L_E_T_ <> '*' " 
			//tratamento para a concatenÁ„o no postgres.		
			If TCGetDB() $ "POSTGRES"
				cQuery += " AND SVT.VT_OP     = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) "
			Else
				cQuery += " AND SVT.VT_OP     = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD " 
			EndIf			
          	 
          	cQuery += " AND NOT EXISTS (SELECT 1 " +;
		  	" 					FROM " + RetSqlName("SVS") + " SVS " +;
		  	" 					WHERE SVS.VS_FILIAL = '" + xFilial("SVS") + "' " +;
		  	" 					AND SVT.VT_FILIAL  = '" + xFilial("SVT") + "' " +;
			" 					AND SVS.VS_OP      = SVT.VT_OP " +;
			"                   AND SVS.VS_MESSPED = SVT.VT_MESSPED " +;
			"                   AND SVS.VS_ANOSPED = SVT.VT_ANOSPED ) "

cQuery += " JOIN "+RetSqlName("SB1") + " SB1 " +;
		  " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +;
		  " AND SB1.B1_COD     = SC2.C2_PRODUTO " +;
		  " AND SB1.D_E_L_E_T_ <> '*' "
      
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += 	" LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
			  	" ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
				" AND SBZ.BZ_COD     = SB1.B1_COD " +; 
			  	" AND SBZ.D_E_L_E_T_ <> '*' "
EndIf

cQuery += " WHERE SVT.D_E_L_E_T_ <> '*' "
                                
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())

	If !((cAliasTmp)->TIPO $ (cTipo03+"|"+cTipo04))
		cQuery := " DELETE FROM " + RetSqlName("SVT") + " WHERE VT_FILIAL ='"+xFilial("SVT")+"' AND VT_MESSPED = '" + STR(cMes,2) + "' AND VT_ANOSPED = '" + STR(cAno,4) + "' AND VT_OP = '" + (cAliasTmp)->VT_OP + "' AND VT_PRODUTO = '" + (cAliasTmp)->C2_PRODUTO + "' AND VT_PRGORI = '" + cChamada + "' "
		MATExecQry(cQuery)

		If (cAliK235)->(MsSeek(cSVSFilial+(cAliasTmp)->VT_OP)) // FILIAL+COD_DOC_OP+COD_ITEM
			While (cAliK235)->(FILIAL+COD_DOC_OP) == cSVSFilial+(cAliasTmp)->VT_OP
				Reclock(cAliK235,.F.)
				DbDelete()
				(cAliK235)->(MsUnLock())
				(cAliK235)->(dbSkip())
			EndDo
		EndIf

		(cAliasTmp)->(dbSkip())
		Loop	
	EndIf

	//grava tabela fÌsica para guardar histÛrico
	SVS->(dbSetOrder(2))
	If !SVS->(dbSeek(cSVSFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->VT_OP+(cAliasTmp)->C2_PRODUTO+ cChamada ))

		//*************************************************************************************
		// Bloco K230 - nas situacoes em que houveram apenas Requisicoes no Periodo de Apuracao
		//*************************************************************************************
		RecLock("SVS",.T.)
		SVS->VS_PRGORI  := cChamada
		SVS->VS_FILIAL  := cSVSFilial
		SVS->VS_MESSPED := STR(cMes,2)
		SVS->VS_ANOSPED := STR(cAno,4)
		SVS->VS_REG     := "K230"
		SVS->VS_DTINIOP := GetIniProd((cAliasTmp)->VT_OP)
		SVS->VS_DTFIMOP := If(STOD((cAliasTmp)->C2_DATRF) > dDataAte, StoD(""), STOD((cAliasTmp)->C2_DATRF))
		SVS->VS_OP      := (cAliasTmp)->VT_OP
		SVS->VS_PRODUTO := (cAliasTmp)->C2_PRODUTO
		SVS->VS_QTDENC  := 0
		SVS->VS_QTDORI  := (cAliasTmp)->C2_QUANT
		SVS->(MsUnlock())
		
		(cAliasTmp)->(dbSkip())	
	Else
		//************************************************************************
		// Bloco K230 - ajuste de quantidades em multiplos apontamentos
		//************************************************************************	
		SVS->(dbSeek(cSVSFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->VT_OP+(cAliasTmp)->C2_PRODUTO+ cChamada ))
	    While SVS->(!Eof()) .And. SVS->VS_FILIAL == cSVSFilial .And. SVS->VS_MESSPED == STR(cMes,2) .And. SVS->VS_ANOSPED == STR(cAno,4) .And. SVS->VS_OP == (cAliasTmp)->VT_OP .And. SVS->VS_PRODUTO == (cAliasTmp)->C2_PRODUTO .And. SVS->VS_PRGORI == cChamada
	    	RecLock("SVS",.F.,.T.)
	    	SVS->VS_QTDENC += (cAliasTmp)->C2_QUANT
	    	SVS->(MsUnlock())
			SVS->(dbSkip())
	    EndDo
		(cAliasTmp)->(dbSkip())
	EndIf	
	
EndDo

(cAliasTmp)->(dbCloseArea())

//******************************************
// Grava tabela tempor·ria para rodar o SPED
//******************************************
SVS->(dbSetOrder(2))
SVS->(dbSeek(cSVSFilial+STR(cMes,2)+STR(cAno,4)))
While SVS->(!Eof()) .And. SVS->VS_FILIAL == cSVSFilial .And. SVS->VS_MESSPED == STR(cMes,2) .And. SVS->VS_ANOSPED == STR(cAno,4)
	If SVS->VS_PRGORI == cChamada
		Reclock(cAliK230,.T.)
		(cAliK230)->FILIAL			:= cSVSFilial
		(cAliK230)->REG				:= "K230"
		(cAliK230)->DT_INI_OP		:= SVS->VS_DTINIOP
		(cAliK230)->DT_FIN_OP		:= SVS->VS_DTFIMOP
		(cAliK230)->COD_DOC_OP		:= SVS->VS_OP
		(cAliK230)->COD_ITEM		:= SVS->VS_PRODUTO
		(cAliK230)->QTD_ENC			:= SVS->VS_QTDENC
		(cAliK230)->QTDORI			:= SVS->VS_QTDORI
		(cAliK230)->(MsUnLock())
	EndIf
	SVS->(dbSkip())
EndDo
MsUnlock()


//gravaÁ„o de OPs encerradas no perÌodo, mas sem movimentaÁıes no mesmo.
cQuery := " SELECT VS_OP, VS_PRODUTO, max(SVS.R_E_C_N_O_)  AS REQSVS, C2_DATRF " +;
          	" FROM " + RetSqlName("SVS") + " SVS " +;
          	" LEFT JOIN " + RetSqlName("SC2") + " SC2 "
			//tratamento para a concatenÁ„o no postgres.		
			If TCGetDB() $ "POSTGRES"
				cQuery += " ON TRIM(C2_NUM" + cCharSoma + "C2_ITEM" + cCharSoma + "C2_SEQUEN" + cCharSoma + "C2_ITEMGRD)  = VS_OP " 
			Else
				cQuery += " ON C2_NUM" + cCharSoma + "C2_ITEM" + cCharSoma + "C2_SEQUEN" + cCharSoma + "C2_ITEMGRD  = VS_OP " 
			EndIf
          	
          	cQuery += " AND SC2.D_E_L_E_T_ <> '*' " +;
          	" AND C2_FILIAL = VS_FILIAL " +;
          	" WHERE VS_DTFIMOP <> C2_DATRF " +;
          	" AND VS_DTFIMOP = '        ' " +;
          	" AND VS_FILIAL = '" + xFilial("SVS") + "' " +;
          	" AND ( SELECT COUNT(*) FROM " + RetSqlName("SVS") + " SVS2 WHERE VS_FILIAL = '" + xFilial("SVS") + "' AND SVS2.VS_OP = SVS.VS_OP AND SVS2.VS_DTFIMOP <> '        ' ) = 0 " +;
          	" GROUP BY VS_OP, VS_PRODUTO, C2_DATRF "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

SVS->(dbSetOrder(2))
While !(cAliasTmp)->(Eof())

	//possui encerramento em periodo posterior ao sped. n„o gerar pendencia
	If STOD((cAliasTmp)->C2_DATRF) <= dDataAte

		SVS->(dbGoTo((cAliasTmp)->REQSVS))
		
		//grava temporaria para arquivo sped
		Reclock(cAliK230,.T.)
		(cAliK230)->FILIAL			:= cSVSFilial
		(cAliK230)->REG				:= "K230"
		(cAliK230)->DT_INI_OP		:= SVS->VS_DTINIOP
		(cAliK230)->DT_FIN_OP		:= STOD((cAliasTmp)->C2_DATRF)
		(cAliK230)->COD_DOC_OP		:= SVS->VS_OP
		(cAliK230)->COD_ITEM		:= SVS->VS_PRODUTO
		(cAliK230)->QTD_ENC			:= 0
		(cAliK230)->QTDORI			:= SVS->VS_QTDORI
		
		//clonar com qtd zerada (cAliK230)->QTD_ENC
		RecLock("SVS",.T.)
		SVS->VS_PRGORI  := cChamada
		SVS->VS_FILIAL  := cSVSFilial
		SVS->VS_MESSPED := STR(cMes,2)
		SVS->VS_ANOSPED := STR(cAno,4)
		SVS->VS_REG     := "K230"
		SVS->VS_DTINIOP := (cAliK230)->DT_INI_OP
		SVS->VS_DTFIMOP := (cAliK230)->DT_FIN_OP
		SVS->VS_OP      := (cAliK230)->COD_DOC_OP
		SVS->VS_PRODUTO := (cAliK230)->COD_ITEM
		SVS->VS_QTDENC  := (cAliK230)->QTD_ENC
		SVS->VS_QTDORI  := (cAliK230)->QTDORI
		SVS->(MsUnlock())
		
		(cAliK230)->(MsUnLock())
		
	EndIf	
	
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())


//Gravacao do Registro 0210 com base nas producoes do Registro K230
If !lEstMov
	(cAliK230)->(dbGoTop())
	While !(cAliK230)->(Eof())
		REG0210(cAli0210,(cAliK230)->COD_ITEM,(cAliK230)->DT_INI_OP,(cAliK230)->DT_INI_OP,(cAliK230)->COD_DOC_OP,.F.,lRePross)
		(cAliK230)->(dbSkip())
	EndDo
EndIf

Return

/*------------------------------------------------------------------------//
//Programa:	  REGK235 
//Autor:	  Ricardo Prandi 
//Data:		  11/09/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K235
//Parametros: 1 - cAliK235      - Alias do arquivo de trabalho do K235
//            2 - dDataDe		    - Data Inicial da Apuracao   
//			      3 - dDataAte	   	- Data Final da Apuracao
//            4 - cAliK270      - Alias do arquivo de trabalho do K270
//            5 - cAliK275      - Alias do arquivo de trabalho do K275
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK235(cAliK235,dDataDe,dDataAte,cAliK270,cAliK275,lRepross)

Local cQuery		:= ""
Local cUpdateD3		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cSD4Filial	:= ""
Local cSVTFilial    := ""
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local aProdNeg	    := {}
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local cChamada      := If (lRepross, "SPEDFISCAL", "MATR241   ")
Local cCharSoma     := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ") //n„o usar ChangeQuery para update e create

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

ProcLogAtu('PCP K235',"PCP K235 - Inicio de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("SVT") + " WHERE VT_FILIAL ='"+xFilial("SVT")+"' AND VT_MESSPED = '" + STR(cMes,2) + "' AND VT_ANOSPED = '" + STR(cAno,4) + "' AND VT_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

ProcLogAtu('PCP K235',"PCP K235 - Seleciona query    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

If TCGetDB() $ "DB2/400/INFORMIX"

	ProcLogAtu('PCP K235',"PCP K235 - DB2    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

	If TCIsView("VWORDEM")
		cQuery := " DROP VIEW VWORDEM "
		MATExecQry(cQuery)
	EndIf 	
	
	//Busca os dados para geraÁ„o do K235
	cQuery := " CREATE VIEW VWORDEM AS " +; 
							" SELECT Sum(CASE " +; 
				                " WHEN SD3C.D3_CF LIKE ( 'DE%' ) THEN (SD3C.D3_QUANT *- 1 ) " +; 
				                " WHEN SD3C.D3_CF LIKE ( 'RE%' ) THEN ( SD3C.D3_QUANT ) " +; 
				                " ELSE 0 " +; 
				            " END) AS QUANT, " +; 
				        " SD3C.D3_COD, " +; 
				        " SD3C.D3_OP " +; 
				" FROM   " + RetSqlName("SD3") + " SD3C " +; 
				        " JOIN " + RetSqlName("SB1") + " SB1 " +; 
				            " ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " +; 
				            " AND SB1.B1_COD = SD3C.D3_COD " +; 
				            " AND SB1.D_E_L_E_T_ <> '*' " +; 
				        " JOIN " + RetSqlName("SC2") + " SC2 "
	//n„o usar ChangeQuery pois converte errado o create view
	cQuery += " ON SD3C.D3_OP = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "
	cQuery += 	            " AND SC2.C2_FILIAL = '" + xFilial('SC2') + "' " +; 
				            " AND SC2.D_E_L_E_T_ <> '*' " +; 
				            " AND SC2.C2_ITEM <> 'OS' " +; 
				            " AND SC2.C2_TPPR IN ( 'I', ' ' ) " +; 
				        " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
				            " ON SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " +; 
				            " AND SB1_OP.B1_COD = SC2.C2_PRODUTO " +; 
				            " AND SB1_OP.D_E_L_E_T_ <> '*' " +; 
				        " LEFT JOIN " + RetSqlName("SD3") + " SD3 " +; 
						    " ON SD3.D3_FILIAL = '" + xFilial('SD3') + "' " +; 
						    " AND SD3.D3_OP = SD3C.D3_OP " +; 
						    " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
				            " AND SD3.D_E_L_E_T_ <> '*' " +; 
				            " AND SD3.D3_CF         <> 'DE1' "
				        
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
		                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		               " AND SBZ_OP.BZ_COD     = SC2.C2_PRODUTO " +; 
		               " AND SBZ_OP.D_E_L_E_T_ <> '*' " 
	EndIF
	            
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += " AND SB1.B1_TIPO "
	EndIf
	
	cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
	cQuery += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
	          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
	Else
		cQuery += " AND SB1_OP.B1_TIPO "
	EndIf
	
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") " +;
				" WHERE  SD3C.D3_FILIAL = '" + xFilial('SD3') + "' " +; 
				        " AND SD3C.D3_COD <> SC2.C2_PRODUTO " +; 
				        " AND SD3C.D_E_L_E_T_ <> '*' " +; 
				        " AND SD3C.D3_ESTORNO <> 'S' " +;
				" GROUP  BY SD3C.D3_OP, " +; 
				        " SD3C.D3_COD, " +; 
				        " SD3C.D3_FILIAL"
	//n„o usar ChangeQuery pois converte errado o create view
	MATExecQry(cQuery)
	
	cQuery := " SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) " +; 
	                          " ELSE 0 END) AS QUANT, " +;
	                 " SD3.D3_COD, "+; 
	                 " SD3.D3_OP, " +; 
	                 " MAX(D3_EMISSAO) AS D3_EMISSAO, " +; 
	                 " SD3.D3_FILIAL, " +;
	                 " SD3.D3_PERBLK, " +;
	                 " SD3.R_E_C_N_O_ AS SD3RECNO, " +;
	                 " SD3.D3_ESTORNO, " +; 
					 " SD3.D3_TRT, " +;
				" (SELECT Min(D4_PRDORG) D4_PRDORG " +;
			        " FROM " + RetSqlName("SD4") + " SD4  where SD4.D4_FILIAL = SD3.D3_FILIAL " +;
			                 " AND SD4.D4_COD = SD3.D3_COD " +;
			                 " AND SD4.D4_OP = SD3.D3_OP " +;
							 " AND SD4.D4_TRT = SD3.D3_TRT " +;
			                 " AND SD4.D_E_L_E_T_ <> '*' " +;
							 " GROUP  BY SD4.D4_TRT ) AS PRDORG " +;
	            " FROM " + RetSqlName("SD3") + " SD3 " +;
	            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
	              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	             " AND SB1.B1_COD     = SD3.D3_COD " +; 
	             " AND SB1.D_E_L_E_T_ <> '*' "
	
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
		                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
		                " AND SBZ.D_E_L_E_T_ <> '*' "
	EndIf
	
	cQuery += "JOIN " + RetSqlName("SC2") + " SC2 " +; 
	           " ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD " +; 
	          " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
	          " AND SC2.D_E_L_E_T_ <> '*' " +; 
	          " AND SC2.C2_ITEM   <> 'OS' " +; 
	          " AND SC2.C2_TPPR   IN ('I',' ') " +; 
	         " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
	           " ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	          " AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
	          " AND SB1_OP.D_E_L_E_T_ <> '*' "
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
		                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		               " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
		               " AND SBZ_OP.D_E_L_E_T_ <> '*' " 
	EndIF
	
	cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
				" AND SD3.D3_COD <> SC2.C2_PRODUTO " +;
	            " AND SD3.D_E_L_E_T_ <> '*' " +; 
	            " AND SD3.D3_OP     <> ' ' " +; 
	            " AND (SD3.D3_CF  LIKE ('RE%') " +; 
	            "  OR  SD3.D3_CF  LIKE ('DE%')) " +; 
	            " AND SB1.B1_CCCUSTO = ' ' " +; 
	            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
	            " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' " +; 
	            " AND SD3.D3_CF         <> 'DE1' "
	            
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += " AND SB1.B1_TIPO "
	EndIf
	
	cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
	cQuery += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
	          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
	Else
		cQuery += " AND SB1_OP.B1_TIPO "
	EndIf
	
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
	cQuery += " AND (SELECT Min(ORDEM.QUANT) " +;
	        		" FROM VWORDEM ORDEM where ORDEM.D3_OP = SD3.D3_OP) >= 0"
	cQuery += " AND SD3.D3_ESTORNO <> 'S' "
	cQuery += " GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
	cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_ESTORNO, SD3.D3_TRT "   
	cQuery += " HAVING (Sum(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT * -1) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) ELSE 0 END)) <> 0 "
	cQuery += "ORDER BY 4,3,2"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	ProcLogAtu('PCP K235',"PCP K235 - Busca concluÌda    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	If lEstMov
		dbSelectArea("SD4")
		dbSetOrder(2) // D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
	EndIf
	 
	//Carrega as filiais uma ˙nica vez
	cSD4Filial := xFilial("SD4")
	cSVTFilial := xFilial("SVT")
	
	While !(cAliasTmp)->(Eof())
	
		SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
	
		//grava tabela fÌsica para guardar histÛrico
		SVT->(dbSetOrder(2))
		If !SVT->(dbSeek(cSVTFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
	
			//************************************************************************
			// Bloco K235
			//************************************************************************
			Reclock("SVT",.T.)
			SVT->VT_PRGORI  := cChamada
			SVT->VT_FILIAL  := cSVTFilial
			SVT->VT_MESSPED := STR(cMes,2)
			SVT->VT_ANOSPED := STR(cAno,4)
			SVT->VT_REG     := "K235"
			SVT->VT_DTSAIDA := StoD((cAliasTmp)->D3_EMISSAO)
			SVT->VT_PRODUTO := (cAliasTmp)->D3_COD
			SVT->VT_QUANT   := (cAliasTmp)->QUANT
			SVT->VT_PRODORI := (cAliasTmp)->PRDORG //GetSubst((cAliasTmp)->D3_COD,(cAliasTmp)->D3_OP,dDataDe,dDataAte)
			SVT->VT_OP      := (cAliasTmp)->D3_OP
			 
			If lEstMov
				If SD4->(MsSeek(cSD4Filial+(cAliasTmp)->(D3_OP+D3_COD)))
					SVT->VT_EMPENHO := "S"
				EndIf
			EndIf
			
			SVT->(MsUnlock())
			
			(cAliasTmp)->(dbSkip())
			
		Else
			//************************************************************************
			// Bloco K235 - ajuste de quantidades em multiplos apontamentos
			//************************************************************************	
			SVT->(dbSeek(cSVTFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		    While SVT->(!Eof()) .And. SVT->VT_FILIAL == cSVTFilial .And. SVT->VT_MESSPED == STR(cMes,2) .And. SVT->VT_ANOSPED == STR(cAno,4) .And. SVT->VT_OP == (cAliasTmp)->D3_OP .And. SVT->VT_PRODUTO == (cAliasTmp)->D3_COD .And. SVT->VT_PRGORI == cChamada 
		    	RecLock("SVT",.F.,.T.)
		    	SVT->VT_QUANT += (cAliasTmp)->QUANT
		    	SVT->(MsUnlock())
				SVT->(dbSkip())
		    EndDo
			(cAliasTmp)->(dbSkip())
		EndIf
			
		
	EndDo
	
	(cAliasTmp)->(dbCloseArea())
	
	
	If TCIsView("VWORDEM")
		cQuery := " DROP VIEW VWORDEM "
		MATExecQry(cQuery)
	EndIf
	
Else

	ProcLogAtu('PCP K235',"PCP K235 - SQL POST ORACLE    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	If TCIsView("VWSEL2")
		cQuery := " DROP VIEW VWSEL2 "
		MATExecQry(cQuery)
	EndIf
	If TCIsView("VWSEL1")
		cQuery := " DROP VIEW VWSEL1 "
		MATExecQry(cQuery)
	EndIf		
	
	//Busca os dados para geraÁ„o do K235
	cQuery := " CREATE VIEW VWSEL1 AS "
	
	cQuery +=   " SELECT SD3_1.QUANT, " +;
				"		SD3_1.D3_COD, " +;
				"		SD3_1.D3_OP, " +;
				"       SD3_1.D3_EMISSAO, " +;
				"       SD3_1.D3_FILIAL, " +;
				"       SD3_1.D3_PERBLK, " +;
				"       SD3_1.R_E_C_N_O_ AS SD3RECNO, " +;
				"       SD3_1.D3_ESTORNO, " +;
				"       SD3_1.D3_TRT, " +;
				"       SB1_SD3_1.B1_TIPO, " +;
				"       PRDORG " +;
				" FROM (SELECT  SUM(CASE " +;
				"						WHEN SD3.D3_CF LIKE ( 'DE%' ) THEN ( SD3.D3_QUANT *- 1 ) " +;
				"						WHEN SD3.D3_CF LIKE ( 'RE%' ) THEN ( SD3.D3_QUANT ) " +;
				"						ELSE 0 " +;
				"					END) AS QUANT, " +;
				"				SD3.D3_COD, " +;
				"				SD3.D3_OP, " +;
				"				Max(D3_EMISSAO) AS D3_EMISSAO, " +;
				"				SD3.D3_FILIAL, " +;
				"				SD3.D3_PERBLK, " +;
				"				SD3.R_E_C_N_O_ AS SD3RECNO, " +;
				"				SD3.D3_ESTORNO, " +;
				"				SD3.D3_TRT, " +;
				"				SD3.R_E_C_N_O_, " +;
				"				(SELECT Min(D4_PRDORG) D4_PRDORG " +;
				"					FROM   " + RetSqlName("SD4") + " SD4 " +;
				"					WHERE  SD4.D4_FILIAL  = SD3.D3_FILIAL " +;
				"							AND SD4.D4_COD = SD3.D3_COD " +;
				"							AND SD4.D4_OP  = SD3.D3_OP " +;
				"							AND SD4.D4_TRT = SD3.D3_TRT " +;
				"							AND SD4.D_E_L_E_T_ <> '*' " +;
				"					GROUP  BY SD4.D4_TRT) AS PRDORG " +;
				"			FROM   " + RetSqlName("SD3") + " SD3 " +;
				"			LEFT JOIN "+;
				"      			(SELECT SD4.D4_OP"+;
				"        			FROM " + RetSqlName("SD4") + " SD4"+;
				" 					INNER JOIN " + RetSqlName("SB1") + " SB1 ON (SB1.B1_FILIAL = '" + xFilial('SB1') + "' "+;
				"										AND SB1.B1_COD = SD4.D4_COD "+; 
				"										AND SB1.D_E_L_E_T_ = ' ') "+;
				"					WHERE SD4.D4_FILIAL = '" + xFilial('SD4') + "'"+;				
				" 						AND SD4.D_E_L_E_T_ <> '*'"+;
				"						AND SB1.B1_TIPO NOT IN ("+cTipo05+") "+;
				" 						AND SD4.D4_QTDEORI < 0) SD4 ON SD3.D3_OP = SD4.D4_OP"+;				
				"			WHERE  SD3.D3_FILIAL = '" + xFilial('SD3') + "' " +;
				"					AND SD3.D_E_L_E_T_ <> '*' " +;
				"					AND SD3.D3_OP <> ' ' " +;
				"					AND ( SD3.D3_CF LIKE ( 'RE%' ) " +;
				"						OR SD3.D3_CF LIKE ( 'DE%' ) ) " +;
				" 					AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +;
				"					AND SD3.D_E_L_E_T_ <> '*' " +;
				"					AND SD3.D3_CF <> 'DE1' " +;
				"					AND SD3.D3_ESTORNO <> 'S' " +;
				"					AND SD4.D4_OP IS NULL "+;
				"			GROUP BY SD3.D3_COD, " +;
				"					SD3.D3_OP, " +;
				"					D3_EMISSAO, " +;
				"					SD3.D3_FILIAL, " +;
				"					SD3.D3_PERBLK, " +;
				"					SD3.R_E_C_N_O_, " +;
				"					SD3.D3_ESTORNO, " +;
				"					SD3.D3_TRT " +;
				"			HAVING ( SUM(CASE " +;
				"							WHEN SD3.D3_CF LIKE ( 'DE%' ) THEN ( SD3.D3_QUANT * -1 ) " +;
				"							WHEN SD3.D3_CF LIKE ( 'RE%' ) THEN ( SD3.D3_QUANT ) " +;
				"							ELSE 0 " +;
				"						END) ) <> 0 ) SD3_1 " +;
				" JOIN (SELECT SB1_SD3.B1_COD, " +;
				"				SB1_SD3.B1_TIPO " +;
				"		FROM   " + RetSqlName("SB1") + " SB1_SD3 " +;
				"		WHERE SB1_SD3.D_E_L_E_T_ <> '*' " +;
				"				AND SB1_SD3.B1_FILIAL = '" + xFilial('SB1') + "' " +;
				"				AND SB1_SD3.B1_CCCUSTO = ' ' " +;
				"				AND SB1_SD3.B1_COD NOT LIKE 'MOD%' " +;
				"				AND SB1_SD3.B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")) SB1_SD3_1 " +;
				"		ON SB1_SD3_1.B1_COD = SD3_1.D3_COD " +;
				" JOIN (SELECT SC2.C2_PRODUTO, "
				//tratamento para a concatenÁ„o no postgres.		
				If TCGetDB() $ "POSTGRES"
					cQuery += "	TRIM(SC2.C2_NUM " + cCharSoma + " SC2.C2_ITEM " + cCharSoma + " SC2.C2_SEQUEN " + cCharSoma + " SC2.C2_ITEMGRD) C2_OP "
				Else
					cQuery += "	SC2.C2_NUM " + cCharSoma + " SC2.C2_ITEM " + cCharSoma + " SC2.C2_SEQUEN " + cCharSoma + " SC2.C2_ITEMGRD C2_OP "
				EndIf	

				cQuery +=		"		FROM   " + RetSqlName("SC2") + " SC2 " +;
				"		WHERE SC2.C2_FILIAL = '" + xFilial('SC2') + "' " +;
				"				AND SC2.D_E_L_E_T_ <> '*' " +;
				"				AND SC2.C2_ITEM <> 'OS' " +;
				"				AND SC2.C2_TPPR IN ( 'I', ' ' )) SC2_1 " +;
				"		ON  SD3_1.D3_OP = SC2_1.C2_OP " +; 
				"		AND SD3_1.D3_COD <> SC2_1.C2_PRODUTO " +;
				" JOIN (SELECT SB1_OP.B1_COD, " +;
				"				SB1_OP.B1_TIPO " +;
				"		FROM   " + RetSqlName("SB1") + " SB1_OP " +;
				"		WHERE  SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " +;
				"				AND SB1_OP.D_E_L_E_T_ <> '*' " +;
				"				AND SB1_OP.B1_CCCUSTO = ' ' " +;
				"				AND SB1_OP.B1_COD NOT LIKE 'MOD%' " +;
				"				AND SB1_OP.B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")) SB1_OP_1 " +;
				"		ON SB1_OP_1.B1_COD = SC2_1.C2_PRODUTO " +;
				" JOIN (SELECT SB1_SD3_2.B1_COD, " +;
                " 		SB1_SD3_2.B1_TIPO " +;
			    "       FROM " + RetSqlName("SB1") + " SB1_SD3_2  " +;
				" 	    WHERE SB1_SD3_2.D_E_L_E_T_ <> '*' " +;
				" 		AND SB1_SD3_2.B1_FILIAL = '" + xFilial('SB1') + "' " +;
				" 		AND SB1_SD3_2.B1_CCCUSTO = ' '                                       " +;
				" 		AND SB1_SD3_2.B1_COD NOT LIKE 'MOD%'                                 " +;
				" 		AND SB1_SD3_2.B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")) SB1_SD3_2 " +;
				" 		ON SB1_SD3_2.B1_COD = SD3_1.D3_COD " +;
				"       AND SD3_1.QUANT <> 0 "   

	cUpdateD3 := " UPDATE " + RetSqlName("SD3") + " " +;
				" SET D3_PERBLK = '" + STR(cMes,2) + STR(cAno,4) + "' " +;
				" WHERE R_E_C_N_O_ IN " +; 
				"	(SELECT R_E_C_N_O_ " +;
				"	FROM " +;
				"		(SELECT SD3_1.R_E_C_N_O_, SD3_1.D3_OP, SD3_1.D3_COD " +;
				"		FROM   " + RetSqlName("SD3") + " SD3_1 " +;
				"		WHERE  SD3_1.D3_FILIAL = '" + xFilial('SD3') + "' " +;
				"			AND SD3_1.D_E_L_E_T_ <> '*' " +;
				"			AND SD3_1.D3_OP <> ' ' " +;
				"			AND (SD3_1.D3_CF LIKE ('RE%') " +;
				"			OR SD3_1.D3_CF LIKE ('DE%')) " +;
				" 			AND SD3_1.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +;
				"			AND SD3_1.D_E_L_E_T_ <> '*' " +;
				"			AND SD3_1.D3_CF <> 'DE1' " +;
				"			AND SD3_1.D3_OP NOT IN (SELECT SD4.D4_OP " +;
				"									FROM   " + RetSqlName("SD4") + " SD4 " +;
				"									WHERE  SD4.D4_FILIAL = '" + xFilial('SD4') + "' " +;
				"										AND SD4.D_E_L_E_T_ <> '*' " +;
				"										AND SD4.D4_QTDEORI < 0) " +;
				"									AND SD3_1.D3_ESTORNO <> 'S') SD3_2 " +;
				"		JOIN " +;
				"			(SELECT SB1_SD3.B1_COD, " +;
				"				SB1_SD3.B1_TIPO " +;
				"			FROM   " + RetSqlName("SB1") + " SB1_SD3 " +;
				"			WHERE SB1_SD3.D_E_L_E_T_ <> '*' " +;
				"				AND SB1_SD3.B1_FILIAL = '" + xFilial('SB1') + "' " +;
				"				AND SB1_SD3.B1_CCCUSTO = ' ' " +;
				"				AND SB1_SD3.B1_COD NOT LIKE 'MOD%' " +;
				"				AND SB1_SD3.B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")) SB1_SD3_1 " +;
				"		ON SB1_SD3_1.B1_COD = SD3_2.D3_COD " +;
				"		JOIN " +;
				"			(SELECT SC2.C2_PRODUTO, "

				//tratamento para a concatenÁ„o no postgres.		
				If TCGetDB() $ "POSTGRES"
					cUpdateD3 += "	TRIM(SC2.C2_NUM " + cCharSoma + " SC2.C2_ITEM " + cCharSoma + " SC2.C2_SEQUEN " + cCharSoma + " SC2.C2_ITEMGRD) C2_OP "
				Else
					cUpdateD3 += "	SC2.C2_NUM " + cCharSoma + " SC2.C2_ITEM " + cCharSoma + " SC2.C2_SEQUEN " + cCharSoma + " SC2.C2_ITEMGRD C2_OP "
				EndIf

				cUpdateD3 +=	"			FROM   " + RetSqlName("SC2") + " SC2 " +;
				"			WHERE " +;
				"			SC2.C2_FILIAL = '" + xFilial('SC2') + "' " +;
				"			AND SC2.D_E_L_E_T_ <> '*' " +;
				"			AND SC2.C2_ITEM <> 'OS' " +;
				"			AND SC2.C2_TPPR IN ( 'I', ' ' )) SC2_1 " +;
				"		ON SD3_2.D3_OP = SC2_1.C2_OP " +;
				"			AND SD3_2.D3_COD <> SC2_1.C2_PRODUTO " +;
				"		JOIN (SELECT SB1_OP.B1_COD, " +;
				"				SB1_OP.B1_TIPO " +;
				"			FROM   " + RetSqlName("SB1") + " SB1_OP " +;
				"			WHERE  SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " +;
				"				AND SB1_OP.D_E_L_E_T_ <> '*' " +;
				"				AND SB1_OP.B1_CCCUSTO = ' ' " +;
				"				AND SB1_OP.B1_COD NOT LIKE 'MOD%' " +;
				"				AND SB1_OP.B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")) SB1_OP_1 " +;
				"		ON SB1_OP_1.B1_COD = SC2_1.C2_PRODUTO) "
	                    
	ProcLogAtu('PCP K235',"PCP K235 - Montagem query 1    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//executa update para marcar d3_perblk
	/*cUpdateD3 := " UPDATE " + RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2) + STR(cAno,4) + "' " + cUpdateD3*/
	MATExecQry(cUpdateD3)
	
	ProcLogAtu('PCP K235',"PCP K235 - Registros marcados    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//cria view para leitura
	MATExecQry(cQuery)
	
	ProcLogAtu('PCP K235',"PCP K235 - Montagem query 2    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
		
	
	cQuery :=   " CREATE VIEW VWSEL2 AS " +;
				"	SELECT  VWSEL1_1.QUANT, " +;
				"			VWSEL1_1.D3_COD, " +;
				"			VWSEL1_1.D3_OP, " +;
				"			VWSEL1_1.D3_EMISSAO, " +;
				"			VWSEL1_1.D3_FILIAL, " +;
				"			VWSEL1_1.D3_PERBLK, " +;
				"			VWSEL1_1.SD3RECNO, " +;
				"			VWSEL1_1.D3_ESTORNO, " +;
				"			VWSEL1_1.D3_TRT, " +;
				"			VWSEL1_1.PRDORG " +;
				"	FROM   ( SELECT QUANT, D3_COD, D3_OP, D3_EMISSAO, D3_FILIAL, D3_PERBLK, SD3RECNO, D3_ESTORNO, D3_TRT, PRDORG " +;
				"				FROM VWSEL1 ) VWSEL1_1 " +;
				"	LEFT JOIN (SELECT VOP.D3_OP " +;
				"				FROM VWSEL1 VOP " +;
				"				WHERE VOP.QUANT < 0 " +;
				"					AND VOP.B1_TIPO IN ("+cTipo03+","+cTipo04+") ) VWSEL1_2 " +;
				"				ON VWSEL1_2.D3_OP = VWSEL1_1.D3_OP " +;
				"				AND VWSEL1_2.D3_OP IS NULL "	
				 
		
	//cria view 2 para leitura
	MATExecQry(cQuery)
	
	ProcLogAtu('PCP K235',"PCP K235 - Montagem query 3    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//varre view para otimizar calculo de quantidades
	cQuery := "	SELECT " +;
				" Sum(QUANT) AS QUANT2, " +;
				" MIN(D3_EMISSAO) AS D3_EMISSAO, " +;
				" D3_COD, " +;
				" MIN(PRDORG) AS PRDORG, " +;
				" D3_OP " +;
				" FROM VWSEL2 " +;
				" GROUP BY D3_OP, " +;
						 " D3_COD "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	ProcLogAtu('PCP K235',"PCP K235 - Busca concluÌda    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	If lEstMov
		dbSelectArea("SD4")
		dbSetOrder(2) // D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
	EndIf
	 
	//Carrega as filiais uma ˙nica vez
	cSD4Filial := xFilial("SD4")
	cSVTFilial := xFilial("SVT")
	
	While !(cAliasTmp)->(Eof())
	
		//grava tabela fÌsica para guardar histÛrico
		SVT->(dbSetOrder(2))
		If !SVT->(dbSeek(cSVTFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
	
			//************************************************************************
			// Bloco K235
			//************************************************************************
			Reclock("SVT",.T.)
			SVT->VT_PRGORI  := cChamada
			SVT->VT_FILIAL  := cSVTFilial
			SVT->VT_MESSPED := STR(cMes,2)
			SVT->VT_ANOSPED := STR(cAno,4)
			SVT->VT_REG     := "K235"
			SVT->VT_DTSAIDA := StoD((cAliasTmp)->D3_EMISSAO)
			SVT->VT_PRODUTO := (cAliasTmp)->D3_COD
			SVT->VT_QUANT   := (cAliasTmp)->QUANT2
			SVT->VT_PRODORI := (cAliasTmp)->PRDORG //GetSubst((cAliasTmp)->D3_COD,(cAliasTmp)->D3_OP,dDataDe,dDataAte)
			SVT->VT_OP      := (cAliasTmp)->D3_OP
			 
			If lEstMov
				If SD4->(MsSeek(cSD4Filial+(cAliasTmp)->(D3_OP+D3_COD)))
					SVT->VT_EMPENHO := "S"
				EndIf
			EndIf
			
			SVT->(MsUnlock())
			
			(cAliasTmp)->(dbSkip())
			
		Else
			//************************************************************************
			// Bloco K235 - ajuste de quantidades em multiplos apontamentos
			//************************************************************************	
			SVT->(dbSeek(cSVTFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		    While SVT->(!Eof()) .And. SVT->VT_FILIAL == cSVTFilial .And. SVT->VT_MESSPED == STR(cMes,2) .And. SVT->VT_ANOSPED == STR(cAno,4) .And. SVT->VT_OP == (cAliasTmp)->D3_OP .And. SVT->VT_PRODUTO == (cAliasTmp)->D3_COD .And. SVT->VT_PRGORI == cChamada 
		    	RecLock("SVT",.F.,.T.)
		    	SVT->VT_QUANT += (cAliasTmp)->QUANT2
		    	SVT->(MsUnlock())
				SVT->(dbSkip())
		    EndDo
			(cAliasTmp)->(dbSkip())
		EndIf
			
		
	EndDo
	
	(cAliasTmp)->(dbCloseArea())
	
	
	If TCIsView("VWSEL2")
		cQuery := " DROP VIEW VWSEL2 "
		MATExecQry(cQuery)
	EndIf
	If TCIsView("VWSEL1")
		cQuery := " DROP VIEW VWSEL1 "
		MATExecQry(cQuery)
	EndIf	

EndIf	



ProcLogAtu('PCP K235',"PCP K235 - Limpar histÛrico    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
// Limpa T4H (275) antecipadamente para o caso de devoluÁ„o no periodo
cQuery := " DELETE FROM " + RetSqlName("T4H") + " WHERE T4H_MESSPE = '" + STR(cMes,2) + "' AND T4H_ANOSPE = '" + STR(cAno,4) + "' AND T4H_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

ProcLogAtu('PCP K235',"PCP K235 - Gravar temporaria    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
//******************************************
// Grava tabela tempor·ria para rodar o SPED
//******************************************
SVT->(dbSetOrder(2))
SVT->(dbSeek(cSVTFilial+STR(cMes,2)+STR(cAno,4)))
While SVT->(!Eof()) .And. SVT->VT_FILIAL == cSVTFilial .And. SVT->VT_MESSPED == STR(cMes,2) .And. SVT->VT_ANOSPED == STR(cAno,4)
	If SVT->VT_PRGORI == cChamada
		If SVT->VT_QUANT > 0
			Reclock(cAliK235,.T.)
			(cAliK235)->FILIAL     := cSVTFilial
			(cAliK235)->REG        := "K235"
			(cAliK235)->DT_SAIDA   := SVT->VT_DTSAIDA
			(cAliK235)->COD_ITEM   := SVT->VT_PRODUTO
			(cAliK235)->QTD        := SVT->VT_QUANT
			(cAliK235)->COD_DOC_OP := SVT->VT_OP
			(cAliK235)->COD_INS_SU := SVT->VT_PRODORI
			(cAliK235)->EMPENHO    := SVT->VT_EMPENHO
			(cAliK235)->(MsUnLock())
		Else	
			//************************************************************************
			// Bloco K275 para componentes e acabado. N„o cria para produto retrabalho
			//************************************************************************
			Reclock("T4H",.T.)
			T4H->T4H_PRGORI := cChamada
			T4H->T4H_FILIAL := cSVTFilial //chave
			T4H->T4H_MESSPE := STR(cMes,2)
			T4H->T4H_ANOSPE := STR(cAno,4)
			T4H->T4H_REG    := "K275"
			T4H->T4H_PRODUT := SVT->VT_PRODUTO
			T4H->T4H_QTD_NE := SVT->VT_QUANT * -1
			T4H->T4H_INS_SU := SVT->VT_PRODORI
			T4H->T4H_OP     := SVT->VT_OP //chave
			T4H->T4H_BLK_CO := "K235" //controle interno - bloco corrigido
			T4H->T4H_CF     := "DE0"
			T4H->(MsUnlock())
			// Eliminar K235 para devoluÁ„o
			RecLock("SVT", .F.)
			SVT->(DBDelete())
			SVT->(MsUnlock())
		EndIf
	EndIf
	SVT->(dbSkip())
			
EndDo
MsUnlock()

ProcLogAtu('PCP K235',"PCP K235 - MarcaÁ„o de registros    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//***************************************
//Busca os dados para marcaÁ„o de leitura
//***************************************
cQuery := " SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) " +; 
                          " ELSE 0 END) AS QUANT, " +;
                 " SD3.D3_COD, "+; 
                 " SD3.D3_OP, " +; 
                 " MAX(D3_EMISSAO) AS D3_EMISSAO, " +; 
                 " SD3.D3_FILIAL, " +;
                 " SD3.D3_PERBLK, " +;
                 " SD3.R_E_C_N_O_ AS SD3RECNO " +; 
            " FROM " + RetSqlName("SD3") + " SD3 " +;
            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
             " AND SB1.B1_COD     = SD3.D3_COD " +; 
             " AND SB1.D_E_L_E_T_ <> '*' "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
	                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
	                " AND SBZ.D_E_L_E_T_ <> '*' "
EndIf

cQuery += "JOIN " + RetSqlName("SC2") + " SC2 " 
		//tratamento para a concatenÁ„o no postgres.		
		If TCGetDB() $ "POSTGRES"
			cQuery += " ON SD3.D3_OP      = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) "        
		Else
			cQuery += " ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "
		EndIf

		cQuery +=  " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
          " AND SC2.D_E_L_E_T_ <> '*' " +; 
          " AND SC2.C2_ITEM   <> 'OS' " +; 
          " AND SC2.C2_TPPR   IN ('I',' ') " +; 
         " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
           " ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
          " AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
          " AND SB1_OP.D_E_L_E_T_ <> '*' "
          
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
	                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	               " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
	               " AND SBZ_OP.D_E_L_E_T_ <> '*' " 
EndIF

cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
            " AND SD3.D_E_L_E_T_ <> '*' " +; 
            " AND SD3.D3_OP     <> ' ' " +; 
            " AND (SD3.D3_CF  LIKE ('PR%')) " +; 
            " AND SB1.B1_CCCUSTO = ' ' " +; 
            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
            " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
            " AND SD3.D_E_L_E_T_ <> '*' " +; 
            " AND SD3.D3_CF         <> 'DE1' " +;                      
            " AND (SELECT COUNT(*) FROM " + RetSqlName("SD4") + " SD4 " +; 
            "      WHERE SD4.D4_FILIAL  = '" + xFilial('SD4') + "' " +; 
            "      AND SD4.D4_OP     = SD3.D3_OP " +;
            "      AND SD4.D_E_L_E_T_ <> '*' " +; 
            "      AND SD4.D4_QTDEORI < 0) = 0 "
            
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += " AND SB1.B1_TIPO "
EndIf

cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQuery += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
          
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
Else
	cQuery += " AND SB1_OP.B1_TIPO "
EndIf

cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_ "   
cQuery += "HAVING (Sum(CASE WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) ELSE 0 END)) <> 0 "
cQuery += "ORDER BY 4,3,2"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

ProcLogAtu('PCP K235',"PCP K235 - Fim de funÁ„o   : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

Return



/*------------------------------------------------------------------------//
//Programa:	  REGK290 
//Autor:	  Ricardo Peixoto
//Data:		  21/09/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K290
//Parametros: 1 - cAliK290      - Alias do arquivo de trabalho do K290
//            2 - dDataDe		- Data Inicial da Apuracao   
//			  3 - dDataAte		- Data Final da Apuracao
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK290(cAliK290,dDataDe,dDataAte,lRepross)

Local cQuery		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cSVUFilial    := ""
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local aProdNeg	    := {}
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local cChamada   := If (lRepross, "SPEDFISCAL", "MATR241   ")
Local cCharSoma  := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ")

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("SVU") + " WHERE VU_MESSPED = '" + STR(cMes,2) + "' AND VU_ANOSPED = '" + STR(cAno,4) + "' AND VU_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

//Busca os dados para geraÁ„o do K290
cQuery := " SELECT SUM(SD3.D3_QUANT) AS QUANT, " +;
                 " SD3.D3_OP, " +;
                 " SD3.D3_COD, " +;
                 " SD3.D3_FILIAL, " +;
                 " SD3.D3_PERBLK, " +;
                 " SD3.R_E_C_N_O_ AS SD3RECNO, SD3.D3_ESTORNO, "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO), " 
Else
	cQuery += "SB1.B1_TIPO, "
EndIf

cQuery += " SC2.C2_DATPRI AS DTINI, " +; 
          " SC2.C2_DATRF AS DTFIM, " +; 
          " SC2.C2_QUANT AS QTDORI " +; 
     " FROM "+RetSqlName("SD3") + " SD3 " +;
     " JOIN "+RetSqlName("SB1") + " SB1 " +; 
       " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
      " AND SB1.B1_COD     = SD3.D3_COD " +; 
      " AND SB1.D_E_L_E_T_ <> '*' "
      
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
	                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
	                " AND SBZ.D_E_L_E_T_ <> '*' "
EndIf

cQuery += " JOIN " + RetSqlName("SC2") + " SC2 "
			//tratamento para a concatenÁ„o no postgres.		
			If TCGetDB() $ "POSTGRES"
				cQuery +=    " ON SD3.D3_OP      = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) "
          	Else
				cQuery +=    " ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "        
			EndIf

         	cQuery += " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
           " AND SC2.D_E_L_E_T_ <> '*' " +;
           " AND SC2.C2_ITEM    <> 'OS' " +; 
           " AND SC2.C2_PRODUTO = SD3.D3_COD " +; 
           " AND SC2.C2_TPPR    IN ('I',' ') "
           
// validaÁ„o de empenho negativo
cQuery += " JOIN " + RetSqlName("SD4") + " SD4 " +; 
          " ON SD4.D4_FILIAL  = '" + xFilial('SD4') + "' " +; 
          " AND SD4.D4_OP     = SD3.D3_OP " +; 
          " AND SD4.D4_QTDEORI < 0 " +;
          " AND SD4.D4_COD = ( SELECT B1_COD FROM " + RetSqlName("SB1") + " SB1D4 WHERE SB1D4.b1_filial = '" + xFilial('SB1') + "' AND SB1D4.B1_COD = SD4.D4_COD AND SB1D4.B1_TIPO IN ( "+cTipo03+","+cTipo04+" ) AND SB1D4.D_E_L_E_T_ <> '*' )" +;
          " AND SD4.D_E_L_E_T_ <> '*' "
          
cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
           " AND SD3.D_E_L_E_T_ <> '*' " +; 
           " AND SD3.D3_OP      <> ' ' " +; 
           " AND SD3.D3_CF      IN ('PR0','PR1') " +; 
           " AND SD3.D3_COD     NOT LIKE 'MOD%' " +; 
           " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
           " AND SB1.B1_CCCUSTO = ' ' " 
            
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) " 
Else
	cQuery += " AND SB1.B1_TIPO "
EndIf

cQuery += " IN (" + cTipo03 + "," + cTipo04 + "," + cTipo06 + ") " +; 
         " AND SD3.D_E_L_E_T_ <> '*' " +;
         " AND SD3.D3_ESTORNO <> 'S' " +;
       " GROUP BY SD3.D3_OP, " +; 
                " SD3.D3_COD, " +; 
                " SD3.D3_FILIAL, "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO), " 
Else
	cQuery += " SB1.B1_TIPO, "
EndIf

cQuery += " SC2.C2_DATPRI, " +; 
          " SC2.C2_DATRF, " +; 
          " SC2.C2_QUANT, "
          
cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_ESTORNO "          

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

cSVUFilial := xFilial("SVU")

While !(cAliasTmp)->(Eof())

	SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)

	//grava tabela fÌsica para guardar histÛrico
	SVU->(dbSetOrder(1))
	If !SVU->(dbSeek(cSVUFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+ cChamada))

		//************************************************************************
		// Bloco K290
		//************************************************************************
		Reclock("SVU",.T.)
		SVU->VU_PRGORI  := cChamada
		SVU->VU_FILIAL  := cSVUFilial
		SVU->VU_MESSPED := STR(cMes,2)
		SVU->VU_ANOSPED := STR(cAno,4)
		SVU->VU_REG     := "K290"
		SVU->VU_DTINIOP := GetIniProd((cAliasTmp)->D3_OP)
		SVU->VU_DTFIMOP := If(StoD((cAliasTmp)->DTFIM) > dDataAte,StoD(""),StoD((cAliasTmp)->DTFIM))
		SVU->VU_OP      := (cAliasTmp)->D3_OP
		SVU->(MsUnlock())			
		
	EndIf
			
	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(dbCloseArea())




//Inicia a Gravacao das Producoes Zeradas, nas situacoes em que houveram apenas Requisicoes no Periodo de Apuracao
cQuery := " SELECT DISTINCT SVW.VW_OP, " +;
                          " SC2.C2_DATRF, " +;
                          " SC2.C2_PRODUTO, " +;
                          " SC2.C2_QUANT " +;
            " FROM " + RetSqlName("SVW") + " SVW " +;
            " JOIN " + RetSqlName("SC2") + " SC2 " +;
            " ON SVW.VW_FILIAL = '" + xFilial("SVW") + "' " +;
            " AND SC2.C2_FILIAL = '" + xFilial("SC2") + "' " 
            //tratamento para a concatenÁ„o no postgres.		
			If TCGetDB() $ "POSTGRES"
				cQuery += " AND SVW.VW_OP     = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) "  
            Else
				cQuery += " AND SVW.VW_OP     = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD " 
           	EndIf
			cQuery +=   " AND NOT EXISTS (SELECT 1 " +;
                            	" FROM " + RetSqlName("SVU") + " SVU " +;
                            	" WHERE SVU.VU_FILIAL = '" + xFilial("SVU") + "' " +;
                            	" AND SVW.VW_FILIAL = '" + xFilial("SVW") + "' " +;
                                " AND SVU.VU_OP     = SVW.VW_OP " +;
								" AND SVU.VU_MESSPED = SVW.VW_MESSPED " +;
								" AND SVU.VU_ANOSPED = SVW.VW_ANOSPED ) "
                                
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())

	//grava tabela fÌsica para guardar histÛrico
	SVU->(dbSetOrder(1))
	If !SVU->(dbSeek(cSVUFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->VW_OP+ cChamada))

		//************************************************************************
		// Bloco K290
		//************************************************************************
		Reclock("SVU",.T.)
		SVU->VU_PRGORI  := cChamada
		SVU->VU_FILIAL  := cSVUFilial
		SVU->VU_MESSPED := STR(cMes,2)
		SVU->VU_ANOSPED := STR(cAno,4)
		SVU->VU_REG     := "K290"
		SVU->VU_DTINIOP := GetIniProd((cAliasTmp)->VW_OP)
		SVU->VU_DTFIMOP := If(STOD((cAliasTmp)->C2_DATRF) > dDataAte, StoD(""), STOD((cAliasTmp)->C2_DATRF))
		SVU->VU_OP      := (cAliasTmp)->VW_OP
		SVU->(MsUnlock())
		
	EndIf
	(cAliasTmp)->(dbSkip())
	
EndDo

(cAliasTmp)->(dbCloseArea())

//******************************************
// Grava tabela tempor·ria para rodar o SPED
//******************************************
SVU->(dbSetOrder(1))
SVU->(dbSeek(cSVUFilial+STR(cMes,2)+STR(cAno,4)))
While SVU->(!Eof()) .And. SVU->VU_FILIAL == cSVUFilial .And. SVU->VU_MESSPED == STR(cMes,2) .And. SVU->VU_ANOSPED == STR(cAno,4)
	If SVU->VU_PRGORI == cChamada
		Reclock(cAliK290,.T.)
		(cAliK290)->FILIAL			:= cSVUFilial
		(cAliK290)->REG				:= "K290"
		(cAliK290)->DT_INI_OP		:= SVU->VU_DTINIOP
		(cAliK290)->DT_FIN_OP		:= SVU->VU_DTFIMOP
		(cAliK290)->COD_DOC_OP		:= SVU->VU_OP
		(cAliK290)->(MsUnLock())
	EndIf
	SVU->(dbSkip())
EndDo
MsUnlock()

//gravaÁ„o de OPs encerradas no perÌodo, mas sem movimentaÁıes no mesmo.
cQuery := " SELECT VU_OP, max(SVU.R_E_C_N_O_)  AS REQSVU, C2_DATRF " +;
          	" FROM " + RetSqlName("SVU") + " SVU " +;
          	" LEFT JOIN " + RetSqlName("SC2") + " "
			//tratamento para a concatenÁ„o no postgres.		
			If TCGetDB() $ "POSTGRES"
				cQuery += " ON TRIM(C2_NUM" + cCharSoma + "C2_ITEM" + cCharSoma + "C2_SEQUEN" + cCharSoma + "C2_ITEMGRD)  = VU_OP " 
            Else
				cQuery += " ON C2_NUM" + cCharSoma + "C2_ITEM" + cCharSoma + "C2_SEQUEN" + cCharSoma + "C2_ITEMGRD  = VU_OP " 
           	EndIf

			cQuery += " AND C2_FILIAL = VU_FILIAL " +;
          	" WHERE VU_DTFIMOP <> C2_DATRF " +;
          	" AND VU_DTFIMOP = '        ' " +;
          	" AND VU_FILIAL = '" + xFilial("SVU") + "' " +;
          	" AND ( SELECT COUNT(*) FROM " + RetSqlName("SVU") + " SVU2 WHERE VU_FILIAL = '" + xFilial("SVU") + "' AND SVU2.VU_OP = SVU.VU_OP AND SVU2.VU_DTFIMOP <> '        ' ) = 0 " +;
          	" GROUP BY VU_OP, C2_DATRF "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

SVU->(dbSetOrder(1))
While !(cAliasTmp)->(Eof())
	SVU->(dbGoTo((cAliasTmp)->REQSVU))
	
	//grava temporaria para arquivo sped
	Reclock(cAliK290,.T.)
	(cAliK290)->FILIAL			:= cSVUFilial
	(cAliK290)->REG				:= "K290"
	(cAliK290)->DT_INI_OP		:= SVU->VU_DTINIOP
	(cAliK290)->DT_FIN_OP		:= STOD((cAliasTmp)->C2_DATRF)
	(cAliK290)->COD_DOC_OP		:= SVU->VU_OP	
	
	If SVU->VU_PRGORI == cChamada .And. SVU->VU_FILIAL == cSVUFilial .And. SVU->VU_MESSPED == STR(cMes,2) .And. SVU->VU_ANOSPED == STR(cAno,4) .And. SVU->VU_REG == "K290" .And. SVU->VU_OP == (cAliK290)->COD_DOC_OP
	
		RecLock("SVU",.F.)
		SVU->VU_DTFIMOP := STOD((cAliasTmp)->C2_DATRF)
		SVU->(MsUnlock())
	
	Else
	
		//clonar com qtd zerada (cAliK230)->QTD_ENC
		RecLock("SVU",.T.)
		SVU->VU_PRGORI  := cChamada
		SVU->VU_FILIAL  := cSVUFilial
		SVU->VU_MESSPED := STR(cMes,2)
		SVU->VU_ANOSPED := STR(cAno,4)
		SVU->VU_REG     := "K290"
		SVU->VU_DTINIOP := (cAliK290)->DT_INI_OP
		SVU->VU_DTFIMOP := (cAliK290)->DT_FIN_OP
		SVU->VU_OP      := (cAliK290)->COD_DOC_OP
		SVU->(MsUnlock())
	
	EndIf
	
	(cAliK290)->(MsUnLock())	
	
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())


Return


/*------------------------------------------------------------------------//
//Programa:	  PROCK292 
//Autor:	  Ricardo Peixoto 
//Data:		  21/09/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K292
//Parametros: 1 - cAliK292      - Alias do arquivo de trabalho do K292
//            2 - dDataDe		- Data Inicial da Apuracao   
//			  3 - dDataAte		- Data Final da Apuracao
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK292(cAliK292,dDataDe,dDataAte,lRepross)

Local cQuery		:= ""
Local cUpdateD3		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cSVWFilial    := xFilial("SVV")
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local aProdNeg	    := {}
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local cChamada      := If (lRepross, "SPEDFISCAL", "MATR241   ")
Local cCharSoma     := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ") //n„o usar ChangeQuery para update e create
Local lREGK290NEW	:= SuperGetMV("MV_BLK290N",.F.,.F.)

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

ProcLogAtu('PCP K292',"PCP K292 - InÌcio de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

If lREGK290NEW
	REGK290NEW(cAliK292,dDataDe,dDataAte,cChamada)
	Return
EndIf

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("SVW") + " WHERE VW_MESSPED = '" + STR(cMes,2) + "' AND VW_ANOSPED = '" + STR(cAno,4) + "' AND VW_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

If TCGetDB() $ "DB2/400/INFORMIX"

	ProcLogAtu('PCP K292',"PCP K292 - INFORMIX    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

	If TCIsView("VWORDEM")
		cQuery := " DROP VIEW VWORDEM "
		MATExecQry(cQuery)
	EndIf 
	
	//Busca os dados para geraÁ„o do K292
	cQuery := " CREATE VIEW VWORDEM AS " +;
	" SELECT Sum(CASE " +;
	                " WHEN SD3C.D3_CF LIKE ( 'DE%' ) THEN ( " +;
	                " SD3C.D3_QUANT *- 1 ) " +;
	                " WHEN SD3C.D3_CF LIKE ( 'RE%' ) THEN " +;
	                " ( SD3C.D3_QUANT ) " +;
	                " ELSE 0 " +;
	            " END) AS QUANT, " +;
	        " SD3C.D3_COD, " +;
	        " SD3C.D3_OP " +;
	" FROM   " + RetSqlName("SD3") + " SD3C " +;
	        " JOIN " + RetSqlName("SB1") + " SB1 " +;
	            " ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " +;
	            " AND SB1.B1_COD = SD3C.D3_COD " +;
	            " AND SB1.D_E_L_E_T_ <> '*' " +;
	        " JOIN " + RetSqlName("SC2") + " SC2 "
	//n„o usar ChangeQuery pois converte errado o create view
	cQuery += " ON SD3C.D3_OP = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "

	cQuery += " AND SC2.C2_FILIAL = '" + xFilial('SC2') + "' " +;
	            " AND SC2.D_E_L_E_T_ <> '*' " +;
	            " AND SC2.C2_ITEM <> 'OS' " +;
	            " AND SC2.C2_TPPR IN ( 'I', ' ' ) " +;
	        " JOIN " + RetSqlName("SB1") + " SB1_OP " +;
	            " ON SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " +;
	            " AND SB1_OP.B1_COD = SC2.C2_PRODUTO " +;
	            " AND SB1_OP.D_E_L_E_T_ <> '*' " +;
	        " LEFT JOIN " + RetSqlName("SD3") + " SD3 " +;
	            " ON SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
				" AND SD3.D3_OP = SD3C.D3_OP " +;
	            " AND (SD3.D3_CF  LIKE ('RE%') " +; 
	            "  OR  SD3.D3_CF  LIKE ('DE%')) " +; 
	            " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' " +;
	" WHERE  SD3C.D3_FILIAL = '" + xFilial('SD3') + "' " +;
	        " AND SD3C.D3_COD <> SC2.C2_PRODUTO " +;
	        " AND SD3C.D_E_L_E_T_ <> '*' " +;
	" GROUP  BY SD3C.D3_OP, " +;
	            " SD3C.D3_COD, " +;
	            " SD3C.D3_FILIAL"
	//n„o usar ChangeQuery pois converte errado o create view
	MATExecQry(cQuery)
	
	
	
	cQuery := " SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) " +; 
	                          " ELSE 0 END) AS QUANT, " +;
	                 " SD3.D3_COD, "+; 
	                 " SD3.D3_OP, " +; 
	                 " MAX(D3_EMISSAO) AS D3_EMISSAO, " +; 
	                 " SD3.D3_FILIAL, " +;
	                 " SD3.D3_PERBLK, " +;
	                 " SD3.R_E_C_N_O_ AS SD3RECNO, SD3.D3_ESTORNO " +;
	            " FROM " + RetSqlName("SD3") + " SD3 " +;
	            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
	              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	             " AND SB1.B1_COD     = SD3.D3_COD " +; 
	             " AND SB1.D_E_L_E_T_ <> '*' "
	
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
		                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
		                " AND SBZ.D_E_L_E_T_ <> '*' "
	EndIf
	
	cQuery += "JOIN " + RetSqlName("SC2") + " SC2 " +; 
	           " ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD " +; 
	          " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
	          " AND SC2.D_E_L_E_T_ <> '*' " +; 
	          " AND SC2.C2_ITEM   <> 'OS' " +; 
	          " AND SC2.C2_TPPR   IN ('I',' ') " +; 
	         " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
	           " ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	          " AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
	          " AND SB1_OP.D_E_L_E_T_ <> '*' "
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
		                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		               " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
		               " AND SBZ_OP.D_E_L_E_T_ <> '*' " 
	EndIF
	
	cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
				" AND SD3.D3_COD <> SC2.C2_PRODUTO " +;
	            " AND SD3.D_E_L_E_T_ <> '*' " +; 
	            " AND SD3.D3_OP     <> ' ' " +; 
	            " AND (SD3.D3_CF  LIKE ('RE%') " +; 
	            "  OR  SD3.D3_CF  LIKE ('DE%')) " +; 
	            " AND SB1.B1_CCCUSTO = ' ' " +; 
	            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
	            " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' "
	            
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += " AND SB1.B1_TIPO "
	EndIf
	
	cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cQuery += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
	          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
	Else
		cQuery += " AND SB1_OP.B1_TIPO "
	EndIf
	
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cQuery += " AND (SELECT Min(ORDEM.QUANT) " +;
	        		" FROM VWORDEM ORDEM where ORDEM.D3_OP = SD3.D3_OP)  < 0 "
	cQuery += " AND SD3.D3_ESTORNO <> 'S' "
	cQuery += " GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
	cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_ESTORNO "          
	
	cQuery += "HAVING (Sum(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT * -1) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) ELSE 0 END)) <> 0 "
	cQuery += "ORDER BY 4,3,2"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	While !(cAliasTmp)->(Eof())
			
		SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
		
		//grava tabela fÌsica para guardar histÛrico
		SVW->(dbSetOrder(1))
		If !SVW->(dbSeek(cSVWFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
	
			//************************************************************************
			// Bloco K292
			//************************************************************************
			Reclock("SVW",.T.)
			SVW->VW_PRGORI  := cChamada
			SVW->VW_FILIAL  := cSVWFilial
			SVW->VW_MESSPED := STR(cMes,2)
			SVW->VW_ANOSPED := STR(cAno,4)
			SVW->VW_REG     := "K292"
			SVW->VW_OP      := (cAliasTmp)->D3_OP
			SVW->VW_PRODUTO := (cAliasTmp)->D3_COD
			SVW->VW_QUANT   := (cAliasTmp)->QUANT
			SVW->(MsUnlock())
			
		Else
	
			//************************************************************************
			// Bloco K292 - ajuste de quantidades em multiplos apontamentos
			//************************************************************************
			SVW->(dbSeek(cSVWFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		    While SVW->(!Eof()) .And. SVW->VW_FILIAL == cSVWFilial .And. SVW->VW_MESSPED == STR(cMes,2) .And. SVW->VW_ANOSPED == STR(cAno,4) .And. SVW->VW_OP == (cAliasTmp)->D3_OP .And. SVW->VW_PRODUTO == (cAliasTmp)->D3_COD .And. SVW->VW_PRGORI == cChamada
		    	RecLock("SVW",.F.,.T.)		    	
		    	SVW->VW_QUANT += (cAliasTmp)->QUANT
		    	SVW->(MsUnlock())
				SVW->(dbSkip())
		    EndDo
		
		EndIf		
			
		(cAliasTmp)->(dbSkip())
	EndDo
	
	(cAliasTmp)->(dbCloseArea())
	
	If TCIsView("VWORDEM")
		cQuery := " DROP VIEW VWORDEM "
		MATExecQry(cQuery)
	EndIf

Else

	ProcLogAtu('PCP K292',"PCP K292 - SQL/ORA    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	If TCIsView("VWSEL1")
		cQuery := " DROP VIEW VWSEL1 "
		MATExecQry(cQuery)
	EndIf
	
	//Busca os dados para geraÁ„o do K292
	cQuery := " CREATE VIEW VWSEL1 AS "
	
	cQuery +=   " SELECT SUM(CASE " +;
				" 	WHEN SD3.D3_CF LIKE ( 'DE%' ) THEN ( SD3.D3_QUANT *- 1 ) " +;
				" 	WHEN SD3.D3_CF LIKE ( 'RE%' ) THEN ( SD3.D3_QUANT ) " +;
				" 	ELSE 0 " +;
				" END) AS QUANT, " +;
				" SD3.D3_COD, " +;
				" SD3.D3_OP, " +;
				" MAX(D3_EMISSAO) AS D3_EMISSAO, " +;
				" SD3.D3_FILIAL, " +;
				" SD3.D3_PERBLK, " +;
				" SD3.R_E_C_N_O_  AS SD3RECNO, " +;
				" SD3.D3_ESTORNO " +;
				" FROM   ((Select ORDEM.D3_OP " +;
				" 			from   (SELECT Sum(CASE " +;
				" 								WHEN SD3C_N2.D3_CF LIKE ( 'DE%' ) THEN ( " +;
				" 									SD3C_N2.D3_QUANT *- 1 ) " +;
				" 								WHEN SD3C_N2.D3_CF LIKE ( 'RE%' ) THEN ( " +;
				" 									SD3C_N2.D3_QUANT ) " +;
				" 								ELSE 0 " +;
				" 							END) AS QUANT, " +;
				" 					SD3C_N2.D3_COD, " +;
				" 					SD3C_N2.D3_OP " +;
				" 	FROM   " + RetSqlName("SD3") + " SD3C_N2 " +;
				" 	WHERE  SD3C_N2.D3_FILIAL = '" + xFilial('SD3') + "' " +;
				" 			AND SD3C_N2.D_E_L_E_T_ <> '*' " +;
				" 	GROUP  BY SD3C_N2.D3_OP, " +;
				" 			SD3C_N2.D3_COD, " +;
				" 			SD3C_N2.D3_FILIAL " +;
				" 	HAVING Sum(CASE " +;
				" 				WHEN SD3C_N2.D3_CF LIKE ( 'DE%' ) THEN ( " +;
				" 					SD3C_N2.D3_QUANT *- 1 ) " +;
				" 				WHEN SD3C_N2.D3_CF LIKE ( 'RE%' ) THEN ( " +;
				" 					SD3C_N2.D3_QUANT ) " +;
				" 				ELSE 0 " +;
				" 				END) < 0) ORDEM " +;
				" 	JOIN " +; 
				" 		(SELECT SB1_SD3.B1_COD, " +;
				" 				SB1_SD3.B1_TIPO " +;
				" 			FROM   " + RetSqlName("SB1") + " SB1_SD3 " +;
				" 			WHERE SB1_SD3.D_E_L_E_T_ <> '*' " +;
				" 					AND SB1_SD3.B1_FILIAL = '" + xFilial('SB1') + "' " +;
				" 					AND SB1_SD3.B1_TIPO IN ("+cTipo03+","+cTipo04+")) SB1_SD3_1_N2  " +;
				" 		ON SB1_SD3_1_N2.B1_COD = ORDEM.D3_COD " +; 
				" 		JOIN " +; 
				" 		(SELECT SC2_N2.C2_PRODUTO, "
				//tratamento para a concatenÁ„o no postgres.		
				If TCGetDB() $ "POSTGRES"
					cQuery +=   "	TRIM(SC2_N2.C2_NUM " + cCharSoma + " SC2_N2.C2_ITEM " + cCharSoma + " SC2_N2.C2_SEQUEN " + cCharSoma + " SC2_N2.C2_ITEMGRD) C2_OP "
				Else
					cQuery +=   "	SC2_N2.C2_NUM " + cCharSoma + " SC2_N2.C2_ITEM " + cCharSoma + " SC2_N2.C2_SEQUEN " + cCharSoma + " SC2_N2.C2_ITEMGRD C2_OP "
				EndIf
			
				cQuery += " 			FROM   " + RetSqlName("SC2") + " SC2_N2 " +;
				" 			WHERE SC2_N2.C2_FILIAL = '" + xFilial('SC2') + "' " +;
				" 				AND SC2_N2.D_E_L_E_T_ <> '*' " +;
				" 				AND SC2_N2.C2_ITEM <> 'OS' " +;
				" 				AND SC2_N2.C2_TPPR IN ( 'I', ' ' )) SC2_1_N2 " +;
				" 		ON ORDEM.D3_OP = SC2_1_N2.C2_OP " +; 
				" 			AND ORDEM.D3_COD <> SC2_1_N2.C2_PRODUTO " +;
				" 		JOIN (SELECT SB1_OP_N2.B1_COD, " +;
				" 					SB1_OP_N2.B1_TIPO " +;
				" 			FROM   " + RetSqlName("SB1") + " SB1_OP_N2 " +;
				" 			WHERE  SB1_OP_N2.B1_FILIAL = '" + xFilial('SB1') + "' " +;
				" 					AND SB1_OP_N2.D_E_L_E_T_ <> '*' ) SB1_OP_N2 " +;
				" 					ON SB1_OP_N2.B1_COD = SC2_1_N2.C2_PRODUTO))  SD3_NEG " +; 
				" 	 JOIN " + RetSqlName("SD3") + " SD3 ON SD3_NEG.D3_OP = SD3.D3_OP " +;
			    "     JOIN " + RetSqlName("SB1") + " SB1 " +;
			    "      ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " +;
			    "        AND SB1.B1_COD = SD3.D3_COD " +;
			    "           AND SB1.D_E_L_E_T_ <> '*' " +;
			    "      JOIN " + RetSqlName("SC2") + " SC2 " 
			    //tratamento para a concatenÁ„o no postgres.		
				If TCGetDB() $ "POSTGRES"
					cQuery +=   "	ON SD3.D3_OP = TRIM(SC2.C2_NUM " + cCharSoma + " SC2.C2_ITEM " + cCharSoma + " SC2.C2_SEQUEN " + cCharSoma + " SC2.C2_ITEMGRD) "
				Else
					cQuery +=   "	ON SD3.D3_OP = SC2.C2_NUM " + cCharSoma + " SC2.C2_ITEM " + cCharSoma + " SC2.C2_SEQUEN " + cCharSoma + " SC2.C2_ITEMGRD "
				EndIf
			
				cQuery +=	"           AND SC2.C2_FILIAL = '" + xFilial('SC2') + "' " +;
			    "           AND SC2.D_E_L_E_T_ <> '*' " +;
			    "           AND SC2.C2_ITEM <> 'OS' " +;
			    "           AND SC2.C2_TPPR IN ( 'I', ' ' ) " +;
			    "      JOIN " + RetSqlName("SB1") + " SB1_OP " +;
			    "        ON SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " +;
			    "           AND SB1_OP.B1_COD = SC2.C2_PRODUTO " +;
			    "           AND SB1_OP.D_E_L_E_T_ <> '*' " +;
			    " WHERE  SD3.D3_FILIAL = '" + xFilial('SD3') + "' " +;
				"          AND SD3.D3_COD <> SC2.C2_PRODUTO " +;
				"          AND SD3.D_E_L_E_T_ <> '*' " +;
				"          AND SD3.D3_OP <> ' ' " +;
				"          AND ( SD3.D3_CF LIKE ( 'RE%' ) " +;
				"                 OR SD3.D3_CF LIKE ( 'DE%' ) ) " +;
				"          AND SB1.B1_CCCUSTO = ' ' " +;
				"          AND SB1.B1_COD NOT LIKE 'MOD%' " +;
				" 		   AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +;
				"          AND SD3.D_E_L_E_T_ <> '*' " +;
				"          AND SB1.B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") " +;
				"          AND SB1_OP.B1_CCCUSTO = ' ' " +;
				"          AND SB1_OP.B1_COD NOT LIKE 'MOD%' " +;
				"          AND SB1_OP.B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") " +;
				"          AND SD3.D3_ESTORNO <> 'S' " +;
				"   GROUP  BY SD3.D3_OP, " +;
				"             SD3.D3_COD, " +;
				"             SD3.D3_FILIAL, " +;
				"             SD3.D3_PERBLK, " +;
				"             SD3.R_E_C_N_O_, " +;
				"             SD3.D3_ESTORNO " +;
				"   HAVING ( Sum(CASE " +;
				"                  WHEN SD3.D3_CF LIKE ( 'DE%' ) THEN ( SD3.D3_QUANT * -1 ) " +;
				"                  WHEN SD3.D3_CF LIKE ( 'RE%' ) THEN ( SD3.D3_QUANT ) " +;
				"                  ELSE 0 " +;
				"                END) ) <> 0   "	
	
	cUpdateD3 := " FROM " + RetSqlName("SD3") + " SD3 " +;
	            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
	              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	             " AND SB1.B1_COD     = SD3.D3_COD " +; 
	             " AND SB1.D_E_L_E_T_ <> '*' "
	
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
		                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
		                " AND SBZ.D_E_L_E_T_ <> '*' "
	EndIf
	
	cUpdateD3 += "JOIN " + RetSqlName("SC2") + " SC2 " 
	            //tratamento para a concatenÁ„o no postgres.		
				If TCGetDB() $ "POSTGRES"
					cUpdateD3 +=   " ON SD3.D3_OP      = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) "
				Else
					cUpdateD3 +=   " ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "
				EndIf
			
			  cUpdateD3 += " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
	          " AND SC2.D_E_L_E_T_ <> '*' " +; 
	          " AND SC2.C2_ITEM   <> 'OS' " +; 
	          " AND SC2.C2_TPPR   IN ('I',' ') " +; 
	         " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
	           " ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	          " AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
	          " AND SB1_OP.D_E_L_E_T_ <> '*' "
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
		                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		               " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
		               " AND SBZ_OP.D_E_L_E_T_ <> '*' " 
	EndIF
	
	cUpdateD3 += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
				" AND SD3.D3_COD <> SC2.C2_PRODUTO " +;
	            " AND SD3.D_E_L_E_T_ <> '*' " +; 
	            " AND SD3.D3_OP     <> ' ' " +; 
	            " AND (SD3.D3_CF  LIKE ('RE%') " +; 
	            "  OR  SD3.D3_CF  LIKE ('DE%')) " +; 
	            " AND SB1.B1_CCCUSTO = ' ' " +; 
	            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
	            " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' "
	            
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cUpdateD3 += " AND SB1.B1_TIPO "
	EndIf
	
	cUpdateD3 += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cUpdateD3 += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
	          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
	Else
		cUpdateD3 += " AND SB1_OP.B1_TIPO "
	EndIf
	
	cUpdateD3 += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cUpdateD3 += " AND (select min(QUANT) from ( " +;
						" SELECT Sum(CASE " +;
									 " WHEN SD3C.D3_CF LIKE ( 'DE%' ) THEN ( SD3C.D3_QUANT *- 1 ) " +;
									 " WHEN SD3C.D3_CF LIKE ( 'RE%' ) THEN ( SD3C.D3_QUANT ) " +;
									 " ELSE 0 " +;
								   " END)        AS QUANT, " +;
							   " SD3C.D3_COD, " +;
							   " SD3C.D3_OP " +;
						" FROM   "+RetSqlName("SD3") + " SD3C " +;
							   " JOIN "+RetSqlName("SB1") + " SB1 " +;
								 " ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " +;
									" AND SB1.B1_COD = SD3C.D3_COD " +;
									" AND SB1.D_E_L_E_T_ <> '*' " +;
									" AND SB1.B1_TIPO IN ("+cTipo03+","+cTipo04+") " +;
							   " JOIN "+RetSqlName("SC2") + " SC2 "
								//tratamento para a concatenÁ„o no postgres.		
								If TCGetDB() $ "POSTGRES"
									cUpdateD3 +=  " ON SD3C.D3_OP = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) "
								Else
									cUpdateD3 +=  " ON SD3C.D3_OP = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "
								EndIf							
								
								cUpdateD3 += 	" AND SC2.C2_FILIAL = '" + xFilial('SC2') + "' " +;
									" AND SC2.D_E_L_E_T_ <> '*' " +;
									" AND SC2.C2_ITEM <> 'OS' " +;
									" AND SC2.C2_TPPR IN ( 'I', ' ' ) " +;
							   " JOIN "+RetSqlName("SB1") + " SB1_OP " +;
								 " ON SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " +;
									" AND SB1_OP.B1_COD = SC2.C2_PRODUTO " +;
									" AND SB1_OP.D_E_L_E_T_ <> '*' " +;
						" WHERE  SD3C.D3_FILIAL = '" + xFilial('SD3') + "' " +;
							   " AND SD3C.D3_COD <> SC2.C2_PRODUTO " +;
							   " AND SD3C.D_E_L_E_T_ <> '*' " +;
							   " AND SD3C.D3_OP = SD3.D3_OP " +;
						" GROUP  BY SD3C.D3_OP, " +;
								  " SD3C.D3_COD, " +;
								  " SD3C.D3_FILIAL " +;
						" ) ORDEM )  < 0 "
	cUpdateD3 += " AND SD3.D3_ESTORNO <> 'S' "	
	
	If  TCGetDB() $ "ORACLE"

			cUpdateD3 := " FROM "+;
			"   (SELECT D3_COD, "+;
			"           D3_OP, "+;
			"           R_E_C_N_O_ "+;
			" 	 FROM " + RetSqlName("SD3") + " SD3 "+;
			"    WHERE D_E_L_E_T_ <> '*' "+;
			"      AND D3_FILIAL = '" + xFilial('SD3') + "' "+; 
			"      AND D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "+; 
			"      AND D_E_L_E_T_ <> '*' "+;
			"      AND D3_OP <> ' ' "+;
			"      AND (D3_CF LIKE ('RE%') "+;
			"           OR D3_CF LIKE ('DE%')) "+;
			"      AND D3_ESTORNO <> 'S' ) SD3 "+;
			" JOIN "

		cUpdateD3 += "   (SELECT B1_COD "+;
			"    FROM " + RetSqlName("SB1") + " SB1 "+;
			"    WHERE B1_FILIAL = '" + xFilial('SB1') + "' "+; 
			"      AND D_E_L_E_T_ <> '*' "+;
			"      AND B1_CCCUSTO = ' ' "+;
			"      AND B1_COD NOT LIKE 'MOD%' "+;
			"      AND B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+")) SB1 ON SB1.B1_COD = SD3.D3_COD "+;	
			" JOIN "

		cUpdateD3 += "   (SELECT C2_PRODUTO, " +;
			"           C2_NUM" + cCharSoma + "C2_ITEM" + cCharSoma + "C2_SEQUEN" + cCharSoma + "C2_ITEMGRD AS C2_OP  "+;
			"    FROM " + RetSqlName("SC2") + " SC2 "+;
			"    WHERE C2_FILIAL = '" + xFilial('SC2') + "' "+; 
			"      AND D_E_L_E_T_ <> '*' "+; 
			"      AND C2_ITEM <> 'OS' "+; 
			"      AND C2_TPPR IN ('I', "+; 
			"                      ' ') ) SC2 ON SD3.D3_OP = SC2.C2_OP "+; 
			" AND SD3.D3_COD <> SC2.C2_PRODUTO "+; 
			" JOIN "
			
		cUpdateD3 += "   (SELECT B1_COD "+; 
			"    FROM " + RetSqlName("SB1") + " SB1 "+;
			"    WHERE D_E_L_E_T_ <> '*' "+;
			"      AND B1_FILIAL = '" + xFilial('SB1') + "' "+; 
			"      AND B1_CCCUSTO = ' ' "+;
			"      AND B1_COD NOT LIKE 'MOD%' "+;
			"      AND B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") ) SB1_OP1 ON SB1_OP1.B1_COD = SC2.C2_PRODUTO  "+;
			" JOIN "

		cUpdateD3 += "   (SELECT SD3C.D3_OP, "+; 
			"           Min(QUANT) "+; 
			"    FROM "+; 
			"      (SELECT Sum(CASE "+; 
			"                      WHEN D3_CF LIKE ('DE%') THEN (D3_QUANT *- 1) "+; 
			"                      WHEN D3_CF LIKE ('RE%') THEN (D3_QUANT) "+; 
			"                      ELSE 0 "+; 
			"                  END) AS QUANT, "+; 
			"              D3_COD, "+; 
			"              D3_OP "+; 
			"       FROM " + RetSqlName("SD3") + " SD3 "+;
			"       WHERE D3_FILIAL = '" + xFilial('SD3') + "' "+;
			"         AND D_E_L_E_T_ <> '*' GROUP  BY D3_OP, "+;
			"                                         D3_COD, "+;
			"                                         D3_FILIAL ) SD3C "+;
			"    JOIN "
		cUpdateD3 += " (SELECT B1_COD "+;
			"       FROM " + RetSqlName("SB1") + " SB1 "+;
			"       WHERE D_E_L_E_T_ <> '*' "+;
			"         AND B1_FILIAL = '" + xFilial('SB1') + "' "+;
			"         AND B1_TIPO IN ('PI', "+;
			"                         'PA') ) SB1 ON SB1.B1_COD = SD3C.D3_COD "+;
			"    JOIN " 

		cUpdateD3 += " (SELECT C2_PRODUTO, "+;
			"        C2_NUM" + cCharSoma + "C2_ITEM" + cCharSoma + "C2_SEQUEN" + cCharSoma + "C2_ITEMGRD AS C2_OP  "+;
			"    	FROM " + RetSqlName("SC2") + " SC2 "+;
			"   	WHERE C2_FILIAL = '" + xFilial('SC2') + "' "+; 
			"         AND D_E_L_E_T_ <> '*' "+;
			"         AND C2_ITEM <> 'OS' "+;
			"         AND C2_TPPR IN ('I', "+;
			"                         ' ') ) SC2_2 ON SD3C.D3_OP = SC2_2.C2_OP "+;
			"    JOIN "
		
		cUpdateD3 += " (SELECT B1_COD "+;
			"       FROM " + RetSqlName("SB1") + " SB1 "+;
			"       WHERE B1_FILIAL = '" + xFilial('SB1') + "' "+;
			"         AND D_E_L_E_T_ <> '*' ) SB1_OP_2 ON SB1_OP_2.B1_COD = SC2_2.C2_PRODUTO "+;
			"    AND SD3C.D3_COD <> SC2_2.C2_PRODUTO "+;
			"    GROUP BY SD3C.D3_OP "+;
			"    HAVING Min(QUANT) < 0) SD3_NEGAT ON SD3.D3_OP = SD3_NEGAT.D3_OP "

	EndIf

	ProcLogAtu('PCP K292',"PCP K292 - Montagem query 1    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//executa update para marcar d3_perblk
	cUpdateD3 := " UPDATE " + RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2) + STR(cAno,4) + "' " +;
				" 	WHERE R_E_C_N_O_ IN " +;
				" (SELECT SD3.R_E_C_N_O_ " + cUpdateD3 + " ) "

	MATExecQry(cUpdateD3)
	
	ProcLogAtu('PCP K292',"PCP K292 - Registros marcados    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	//cria view para leitura
	MATExecQry(cQuery)
	
	ProcLogAtu('PCP K292',"PCP K292 - Montagem query 2    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//varre view para otimizar calculo de quantidades
	cQuery := "	SELECT " +;
				" Sum(QUANT) AS QUANT, " +;
				" D3_COD, " +;
				" D3_OP " +;
				" FROM VWSEL1 " +;
				" GROUP BY D3_OP, " +;
						 " D3_COD "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	ProcLogAtu('PCP K292',"PCP K292 - Busca concluÌda    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	While !(cAliasTmp)->(Eof())
			
		//grava tabela fÌsica para guardar histÛrico
		SVW->(dbSetOrder(1))
		If !SVW->(dbSeek(cSVWFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
	
			//************************************************************************
			// Bloco K292
			//************************************************************************
			Reclock("SVW",.T.)
			SVW->VW_PRGORI  := cChamada
			SVW->VW_FILIAL  := cSVWFilial
			SVW->VW_MESSPED := STR(cMes,2)
			SVW->VW_ANOSPED := STR(cAno,4)
			SVW->VW_REG     := "K292"
			SVW->VW_OP      := (cAliasTmp)->D3_OP
			SVW->VW_PRODUTO := (cAliasTmp)->D3_COD
			SVW->VW_QUANT   := (cAliasTmp)->QUANT
			SVW->(MsUnlock())
			
		Else
	
			//************************************************************************
			// Bloco K292 - ajuste de quantidades em multiplos apontamentos
			//************************************************************************
			SVW->(dbSeek(cSVWFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		    While SVW->(!Eof()) .And. SVW->VW_FILIAL == cSVWFilial .And. SVW->VW_MESSPED == STR(cMes,2) .And. SVW->VW_ANOSPED == STR(cAno,4) .And. SVW->VW_OP == (cAliasTmp)->D3_OP .And. SVW->VW_PRODUTO == (cAliasTmp)->D3_COD .And. SVW->VW_PRGORI == cChamada
		    	RecLock("SVW",.F.,.T.)		    	
		    	SVW->VW_QUANT += (cAliasTmp)->QUANT
		    	SVW->(MsUnlock())
				SVW->(dbSkip())
		    EndDo
		
		EndIf		
			
		(cAliasTmp)->(dbSkip())
	EndDo
	
	(cAliasTmp)->(dbCloseArea())
	
	If TCIsView("VWSEL1")
		cQuery := " DROP VIEW VWSEL1 "
		MATExecQry(cQuery)
	EndIf
	
EndIf

fGravaK292(cAliK292,cSVWFilial,cMes,cAno,cChamada)

ProcLogAtu('PCP K292',"PCP K292 - Fim de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

Return


/*/{Protheus.doc} REGK290NEW
	Processamento alternativo do registro k292 para performance.
	@type  Function
	@author mauricio.joao
	@since 24/08/2022
	@version 1.0
	@param param_name, param_type, param_descr

	/*/
Function REGK290NEW(cAliK292,dDataDe,dDataAte,cChamada)

Local cQuery		:= ""
Local cSVWFilial	:= xFilial("SVV")
Local CSVVFilial	:= ""
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)

Local nOp as numeric
Local nX as numeric
Local nBulk as numeric
Local nMovs as numeric

Local oBulkSVV as object
Local oBulkSVW as object
Local aFields as array

fColetaSB1()
fColetaSC2()
fColetaSD3(dDataDe,dDataAte)

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("SVV") + " WHERE VV_MESSPED = '" + STR(cMes,2) + "' AND VV_ANOSPED = '" + STR(cAno,4) + "' AND VV_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

cQuery := " DELETE FROM " + RetSqlName("SVW") + " WHERE VW_MESSPED = '" + STR(cMes,2) + "' AND VW_ANOSPED = '" + STR(cAno,4) + "' AND VW_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

aOPs := oSD3:GetNames()
oGroup := JsonObject():New() //Agrupador de movimentaÁıes por operaÁ„o
oCoProd := JsonObject():New() //Identificador de ops com co produÁ„o

oBulkSVW := FWBulk():new(RetSqlName("SVW"))

aFields := {}
aAdd(aFields, {"VW_PRGORI"})
aAdd(aFields, {"VW_FILIAL"})
aAdd(aFields, {"VW_MESSPED"})
aAdd(aFields, {"VW_ANOSPED"})
aAdd(aFields, {"VW_REG"})
aAdd(aFields, {"VW_OP"})
aAdd(aFields, {"VW_PRODUTO"})
aAdd(aFields, {"VW_QUANT"})

oBulkSVW:setFields(aFields)

oBulkSVV := FWBulk():new(RetSqlName("SVV"))

aFields := {}
aAdd(aFields, {"VV_PRGORI"})
aAdd(aFields, {"VV_FILIAL"})
aAdd(aFields, {"VV_MESSPED"})
aAdd(aFields, {"VV_ANOSPED"})
aAdd(aFields, {"VV_REG"})
aAdd(aFields, {"VV_OP"})
aAdd(aFields, {"VV_PRODUTO"})
aAdd(aFields, {"VV_QUANT"})

oBulkSVV:setFields(aFields)

For nOp := 1 to len(aOPs)    

    cOp := aOPs[nOp]
    aRecnos := oSD3[cOp]:GetNames()
    oGroup[cOp] := JsonObject():New() 

    For nX := 1 to len(aRecnos)        
        cCod    := oSD3[cOp][aRecnos[nX]]:GetJsonText('COD')
        cCf     := oSD3[cOp][aRecnos[nX]]:GetJsonText('CF')      
        cQuant  := oSD3[cOp][aRecnos[nX]]:GetJsonText('QUANT')
        cTipo   := oSD3[cOp][aRecnos[nX]]:GetJsonText('TIPO')
        cRecno  := oSD3[cOp][aRecnos[nX]]:GetJsonText('RECNO')

        If left(cCf,2) == 'DE' .and. cTipo $ ""+cTipo03+"|"+cTipo04+"" 
            If !oGroup[cOp]:HasProperty(cCod)
                oGroup[cOp][cCod] := Val(cQuant)
            Else
                oGroup[cOp][cCod] += Val(cQuant)
            EndIf        
        EndIf

        If left(cCf,2) $ 'RE|PR'  .and. cTipo $ ""+cTipo00+"|"+cTipo01+"|"+cTipo02+"|"+cTipo03+"|"+cTipo04+"|"+cTipo05+"|"+cTipo06+"|"+cTipo10+""
            If !oGroup[cOp]:HasProperty(cCod)
                oGroup[cOp][cCod] := Val(cQuant)
            Else
                oGroup[cOp][cCod] += Val(cQuant)
            EndIf        
        EndIf

    Next nX  

    oDadosBulk := JsonObject():New()
    aGroup := oGroup[cOp]:GetNames()
    //Carrega as filiais uma ˙nica vez
    cSVWFilial := xFilial("SVW")
    CSVVFILIAL := xFilial("SVV")

	lBulk := .F.
    For nX := 1 to len(aGroup) 
        //Valida se existe produto negativo apÛs o agrupamento dos movimentos.
        //Identifica que È co produÁ„o.
        If oGroup[cOp][aGroup[nX]] < 0 
			lBulk := .T. 
			Exit			
        EndIf
    Next nX  

	If lBulk
		aMovimentos := oSD3[cOp]:GetNames()
		For nMovs := 1 to len(aMovimentos)  
			cCod        := oSD3[cOp][aMovimentos[nMovs]]:GetJsonText('COD')
			cCf         := Left(oSD3[cOp][aMovimentos[nMovs]]:GetJsonText('CF'),2)     
			nQuant      := Val(oSD3[cOp][aMovimentos[nMovs]]:GetJsonText('QUANT'))
			cTipo       := oSD3[cOp][aMovimentos[nMovs]]:GetJsonText('TIPO')
			dEmissao    := STOD(oSD3[cOp][aMovimentos[nMovs]]:GetJsonText('EMISSAO'))
			cRecno      := oSD3[cOp][aMovimentos[nMovs]]:GetJsonText('RECNO')		

			If (left(cCf,2) $ 'RE|PR' .and.;
			!(cTipo $ ""+cTipo00+"|"+cTipo01+"|"+cTipo02+"|"+cTipo03+"|"+cTipo04+"|"+cTipo05+"|"+cTipo06+"|"+cTipo10+"")) .or.;
			(left(cCf,2) == 'DE' .and. !(cTipo $ ""+cTipo03+"|"+cTipo04+""))
				Loop     
			EndIf

			//Validar a data de emissao, sÛ vai pro bulk o que estiver dentro do prazo.
			If dEmissao >= dDataDe .AND. dEmissao <= dDataAte
				lBulk := .T.
				If !oDadosBulk:HasProperty(cCod)
					oDadosBulk[cCod] := JsonObject():New()  
					If !oDadosBulk[cCod]:HasProperty(cCf)
						oDadosBulk[cCod][cCf] := JsonObject():New()  
						oDadosBulk[cCod][cCf]['QUANT'] := nQuant
						oDadosBulk[cCod][cCf]['RECNO'] := "'"+cRecno+"',"
					EndIf
				Else
					If oDadosBulk[cCod]:HasProperty('DE')
						oDadosBulk[cCod]['DE']['QUANT'] += nQuant
						oDadosBulk[cCod]['DE']['RECNO'] += "'"+cRecno+"',"
					Else
						oDadosBulk[cCod][cCf]['QUANT'] += nQuant
						oDadosBulk[cCod][cCf]['RECNO'] += "'"+cRecno+"',"
					EndIf
				EndIf
			EndIf 
		Next nMov

		//Faz o bulk
		aBulk := oDadosBulk:GetNames()
		cRecnos := ''
		For nBulk := 1 to len(aBulk)                
			If oDadosBulk[aBulk[nBulk]]:HasProperty("RE") .AND. oDadosBulk[aBulk[nBulk]]['RE']['QUANT'] != NIL                   
				oBulkSVW:addData({cChamada,cSVWFilial,STR(cMes,2),STR(cAno,4),'K292',cOp,aBulk[nBulk],oDadosBulk[aBulk[nBulk]]['RE']['QUANT']})  
				cRecnos += oDadosBulk[aBulk[nBulk]]['RE']['RECNO']
			EndIf

			If oDadosBulk[aBulk[nBulk]]:HasProperty("DE") .AND. oDadosBulk[aBulk[nBulk]]['DE']['QUANT'] != NIL .AND. oDadosBulk[aBulk[nBulk]]['DE']['QUANT'] > 0                       
				oBulkSVW:addData({cChamada,cSVWFilial,STR(cMes,2),STR(cAno,4),'K292',cOp,aBulk[nBulk],oDadosBulk[aBulk[nBulk]]['DE']['QUANT']}) 		
				cRecnos += oDadosBulk[aBulk[nBulk]]['DE']['RECNO']
			EndIf
				//K291 PR E DE
			If oDadosBulk[aBulk[nBulk]]:HasProperty("PR") .AND. oDadosBulk[aBulk[nBulk]]['PR']['QUANT'] != NIL                         
				oBulkSVV:addData({cChamada,cSVVFilial,STR(cMes,2),STR(cAno,4),'K291',cOp,aBulk[nBulk],oDadosBulk[aBulk[nBulk]]['PR']['QUANT']})  			                  
			EndIf

			If oDadosBulk[aBulk[nBulk]]:HasProperty("DE") .AND. oDadosBulk[aBulk[nBulk]]['DE']['QUANT'] != NIL .AND. oDadosBulk[aBulk[nBulk]]['DE']['QUANT'] < 0                       
				oBulkSVV:addData({cChamada,cSVVFilial,STR(cMes,2),STR(cAno,4),'K291',cOp,aBulk[nBulk],oDadosBulk[aBulk[nBulk]]['DE']['QUANT']*-1}) 		
				cRecnos += oDadosBulk[aBulk[nBulk]]['DE']['RECNO']
			EndIf 

		
		Next nBulk

		oBulkSVV:Flush()
		oBulkSVW:Flush()		
		
		//executa update para marcar d3_perblk
		If !Empty(cRecnos)
			cRecnos := left(cRecnos,len(cRecnos)-1)
			cQuery := " UPDATE " + RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2) + STR(cAno,4) + "' " +;
						" 	WHERE R_E_C_N_O_ IN ("+cRecnos+")" 
		
			MATExecQry(cQuery )
		EndIf
		FwFreeObj(oDadosBulk)
	EndIf	

Next nOp

oBulkSVW:Close()
oBulkSVW:Destroy()
oBulkSVV:Close()
oBulkSVV:Destroy()
FwFreeObj(oBulkSVW)

fGravaK292(cAliK292,cSVWFilial,cMes,cAno,cChamada)

fLimpezaDic()

Return 

/*/{Protheus.doc} fGravaK292
	Grava a SVW
	@type  Static Function
	@author mauricio.joao
	@since 24/08/2022
	@version 1.0
/*/
Static Function fGravaK292(cAliK292,cSVWFilial,cMes,cAno,cChamada)	

	ProcLogAtu('PCP K292',"PCP K292 - Cria tempor·ria    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

	//******************************************
	// Grava tabela tempor·ria para rodar o SPED
	//******************************************
	SVW->(dbSetOrder(1))
	SVW->(dbSeek(cSVWFilial+STR(cMes,2)+STR(cAno,4)))
	While SVW->(!Eof()) .And. SVW->VW_FILIAL == cSVWFilial .And. SVW->VW_MESSPED == STR(cMes,2) .And. SVW->VW_ANOSPED == STR(cAno,4)
		If SVW->VW_PRGORI == cChamada
			If SVW->VW_QUANT > 0
				Reclock(cAliK292,.T.)
				(cAliK292)->FILIAL     := SVW->VW_FILIAL
				(cAliK292)->REG        := "K292"
				(cAliK292)->COD_DOC_OP := SVW->VW_OP
				(cAliK292)->COD_ITEM   := SVW->VW_PRODUTO
				(cAliK292)->QTD        := SVW->VW_QUANT
				(cAliK292)->(MsUnLock())
			Else
				RecLock("SVW", .F.)
				SVW->(DBDelete())
				SVW->(MsUnLock())
			EndIf
		EndIf
		SVW->(dbSkip())
	EndDo
	MsUnlock()
Return 

/*/{Protheus.doc} fLimpezaDic
	Limpeza de dicion·rio
	@type  Static Function
	@author mauricio.joao
	@since 24/08/2022
	@version 1.0
/*/
Static Function fLimpezaDic()
Local cQuery := ""

ProcLogAtu('PCP K291 E K292',"PCP K291 E K292 - Limpeza de dicion·rio    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

// limpa registros deletados
cQuery := " DELETE FROM " + RetSqlName("SVU") + " WHERE D_E_L_E_T_ = '*' "
MATExecQry(cQuery)
cQuery := " DELETE FROM " + RetSqlName("SVW") + " WHERE D_E_L_E_T_ = '*' "
MATExecQry(cQuery)
cQuery := " DELETE FROM " + RetSqlName("SVV") + " WHERE D_E_L_E_T_ = '*' "
MATExecQry(cQuery)

cQuery := " DELETE FROM " + RetSqlName("SVS") + " WHERE D_E_L_E_T_ = '*' AND VS_FILIAL ='"+xFilial("SVS")+"' "
MATExecQry(cQuery)
cQuery := " DELETE FROM " + RetSqlName("SVT") + " WHERE D_E_L_E_T_ = '*' AND VT_FILIAL ='"+xFilial("SVT")+"' "
MATExecQry(cQuery)

cQuery := " DELETE FROM " + RetSqlName("T4H") + " WHERE D_E_L_E_T_ = '*' "
MATExecQry(cQuery)
cQuery := " DELETE FROM " + RetSqlName("T4G") + " WHERE D_E_L_E_T_ = '*' "
MATExecQry(cQuery)

cQuery := " DELETE FROM " + RetSqlName("T4E") + " WHERE D_E_L_E_T_ = '*' "
MATExecQry(cQuery)
cQuery := " DELETE FROM " + RetSqlName("T4F") + " WHERE D_E_L_E_T_ = '*' "
MATExecQry(cQuery)

ProcLogAtu('PCP K291 E K292',"PCP K291 E K292 - Fim de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
Return



/*/{Protheus.doc} fColetaSB1
    Cria um objeto json com dados de produto (sb1).
    @type  Static Function
    @author mauricio.joao
    @since 12/08/2022
    @version 1.0
	lCpoBZTP Private da MATXSPED.
/*/
Static Function fColetaSB1()
Local oStatement
Local cQuery
Local cAliasSB1 := GetNextAlias()
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")

oSB1 := JsonObject():New()

oStatement := FWPreparedStatement():New()
cQuery := "SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_TIPO FROM " + RETSQLNAME("SB1") + " SB1 "	
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
						" ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
					" AND SBZ.BZ_COD     = SB1.B1_COD " +; 
					" AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
oStatement:SetQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,, oStatement:GetFixQuery() ),cAliasSB1) 

While (cAliasSB1)->(!Eof()) 
    
    cIndex := (cAliasSB1)->(B1_COD) 

    oSB1[cIndex] := JSonObject():New()
    oSB1[cIndex]['PRODUTO'] := (cAliasSB1)->(B1_COD)
    oSB1[cIndex]['TIPO']    := (cAliasSB1)->(B1_TIPO)

(cAliasSB1)->(DbSkip())

EndDo

oStatement:Destroy()
FwFreeObj(oStatement)

Return .T.


/*/{Protheus.doc} fColetaSC2
    Cria um objeto json com dados de ordens de produÁ„o (sc2).
    @type  Static Function
    @author mauricio.joao
    @since 12/08/2022
    @version 1.0
/*/
Static Function fColetaSC2()
Local oStatement
Local cQuery
Local cAliasSC2 := GetNextAlias()

oSC2 := JsonObject():New()

oStatement := FWPreparedStatement():New()
cQuery := "SELECT SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD FROM " + RETSQLNAME("SC2") + " SC2 "
cQuery += " WHERE SC2.D_E_L_E_T_ = ' ' AND SC2.C2_FILIAL = '"+xFilial("SC2")+"' "
cQuery += " AND SC2.C2_ITEM <> 'OS' AND SC2.C2_TPPR IN ( 'I', ' ' )  "

oStatement:SetQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,, oStatement:GetFixQuery() ),cAliasSC2) 

While (cAliasSC2)->(!Eof()) 
    
    cIndex := (cAliasSC2)->(C2_NUM)+(cAliasSC2)->(C2_ITEM)+(cAliasSC2)->(C2_SEQUEN)+(cAliasSC2)->(C2_ITEMGRD)
	
    oSC2[cIndex] := cIndex

(cAliasSC2)->(DbSkip())

EndDo

oStatement:Destroy()
FwFreeObj(oStatement)

Return .T.

/*/{Protheus.doc} fColetaSD3
	Cria um objeto json com dados de movimentaÁ„o interna (sd3).
	@type  Static Function
	@author mauricio.joao
	@since 18/08/2022
	@version 1.0
/*/

Static Function fColetaSD3(dDataDe,dDataAte)
Local oPrepare  as object 
Local cAliasSD3 := GetNextAlias()	
Local lOpFechadas := SUPERGETMV('MV_BLK290', .F., .F.) //PERFORMANCE.

oSD3 := JsonObject():New()

cQuery := " SELECT SD3.D3_FILIAL, SD3.D3_OP, SD3.R_E_C_N_O_, SD3.D3_EMISSAO, SD3.D3_COD, SD3.D3_CF, (CASE "
cQuery +=                    " WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT * - 1) "
cQuery +=                    " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) "
cQuery +=                    " WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT)"
cQuery +=                    " ELSE 0 "
cQuery +=                    " END) QUANT "
cQuery += " FROM " + RETSQLNAME("SD3") + " SD3 "
cQuery += " WHERE SD3.D_E_L_E_T_ = ' ' "
cQuery += " AND SD3.D3_FILIAL = '"+xFilial("SD3")+"' "
If lOpFechadas
	cQuery += " AND SD3.D3_EMISSAO BETWEEN '"+dtos(dDataDe)+"' AND '"+dtos(dDataAte)+"' "
EndIf
cQuery += " AND SD3.D3_OP <> '' "
cQuery += " AND SD3.D3_ESTORNO = ''  "
cQuery += " AND SD3.D3_COD NOT LIKE 'MOD%' "
cQuery += " ORDER BY SD3.D3_OP, SD3.D3_COD "
    
cQuery := ChangeQuery(cQuery)

oPrepare := FWPreparedStatement():New(cQuery) 

DbUseArea(.T.,"TOPCONN",TCGENQRY(,, oPrepare:GetFixQuery() ),cAliasSD3) 

While (cAliasSD3)->(!Eof())
    cIndex := (cAliasSD3)->(D3_OP)

	If oSC2:HasProperty(cIndex)
		cRecno := CValToChar((cAliasSD3)->(R_E_C_N_O_))

		//ValidaÁ„o se o produto da movimentaÁ„o est· no filtro do oSB1
		If !oSB1:HasProperty((cAliasSD3)->(D3_COD))
			(cAliasSD3)->(DbSkip())
			Loop
		EndIf
			
		cTipo := oSB1[(cAliasSD3)->(D3_COD)]["TIPO"]

		If !oSD3:HasProperty(cIndex)
			oSD3[cIndex] := JSonObject():New()   
		EndIf

		If !oSD3[cIndex]:HasProperty(cRecno)
			oSD3[cIndex][cRecno] := JSonObject():New()
			oSD3[cIndex][cRecno]['COD']     := (cAliasSD3)->(D3_COD)
			oSD3[cIndex][cRecno]['CF']      := (cAliasSD3)->(D3_CF)
			oSD3[cIndex][cRecno]['QUANT']   := (cAliasSD3)->(QUANT)
			oSD3[cIndex][cRecno]['EMISSAO'] := (cAliasSD3)->(D3_EMISSAO)
			oSD3[cIndex][cRecno]['TIPO']    := cTipo
			oSD3[cIndex][cRecno]['RECNO']   := cRecno
		EndIf
	EndIf 	 

(cAliasSD3)->(DbSkip())

EndDo

Return .T.

/*------------------------------------------------------------------------//
//Programa:	  PROCK291 
//Autor:	  Ricardo Peixoto 
//Data:		  24/09/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K291
//Parametros: 1 - cAliK291      - Alias do arquivo de trabalho do K291
//            2 - dDataDe		- Data Inicial da Apuracao   
//			  3 - dDataAte		- Data Final da Apuracao
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK291(cAliK291,dDataDe,dDataAte,lRepross)

Local cQuery		:= ""
Local cUpdateD3		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cSVVFilial    := xFilial("SVV")
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local aProdNeg	    := {}
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local cChamada      := If (lRepross, "SPEDFISCAL", "MATR241   ")
Local cCharSoma     := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ") //n„o usar ChangeQuery para update e create
Local lREGK290NEW	:= SuperGetMV("MV_BLK290N",.F.,.F.)

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

ProcLogAtu('PCP K291',"PCP K291 - InÌcio de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

If lREGK290NEW
	fGravaK291(cAliK291,cSVVFilial,cMes,cAno,cChamada)
	Return
EndIf

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("SVV") + " WHERE VV_MESSPED = '" + STR(cMes,2) + "' AND VV_ANOSPED = '" + STR(cAno,4) + "' AND VV_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

If TCGetDB() $ "DB2/400/INFORMIX"

	ProcLogAtu('PCP K291',"PCP K291 - INFORMIX    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

	If TCIsView("VWORDEM")
		cQuery := " DROP VIEW VWORDEM "
		MATExecQry(cQuery)
	EndIf 
	
	//Busca os dados para geraÁ„o do K291
	cQuery := " CREATE VIEW VWORDEM AS " +;
	" SELECT Sum(CASE " +; 
	                " WHEN SD3C.D3_CF LIKE ( 'DE%' ) THEN ( " +; 
	                " SD3C.D3_QUANT *- 1 ) " +; 
	                " WHEN SD3C.D3_CF LIKE ( 'RE%' ) THEN " +; 
	                " ( SD3C.D3_QUANT ) " +; 
	                " ELSE 0 " +; 
	            " END) AS QUANT, " +; 
	        " SD3C.D3_COD, " +; 
	        " SD3C.D3_OP " +; 
	" FROM   " + RetSqlName("SD3") + " SD3C " +; 
	        " JOIN " + RetSqlName("SB1") + " SB1 " +; 
	            " ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " +; 
	            " AND SB1.B1_COD = SD3C.D3_COD " +; 
	            " AND SB1.D_E_L_E_T_ <> '*' " +; 
	        " JOIN " + RetSqlName("SC2") + " SC2 "
	//n„o usar ChangeQuery pois converte errado o create view
	cQuery += " ON SD3C.D3_OP = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "
	cQuery += " AND SC2.C2_FILIAL = '" + xFilial('SC2') + "' " +; 
	            " AND SC2.D_E_L_E_T_ <> '*' " +; 
	            " AND SC2.C2_ITEM <> 'OS' " +; 
	            " AND SC2.C2_TPPR IN ( 'I', ' ' ) " +; 
	        " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
	            " ON SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " +; 
	            " AND SB1_OP.B1_COD = SC2.C2_PRODUTO " +; 
	            " AND SB1_OP.D_E_L_E_T_ <> '*' " +; 
	        " LEFT JOIN " + RetSqlName("SD3") + " SD3 " +;
	        	" ON SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
	            " AND SD3.D3_OP = SD3C.D3_OP " +; 
	            " AND (SD3.D3_CF  LIKE ('PR%') " +; 
	            "  OR  SD3.D3_CF  LIKE ('DE%') " +; 
	            "  OR  SD3.D3_CF  LIKE ('RE%')) " +; 
	            " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' "  +; 
	" WHERE  SD3C.D3_FILIAL = '" + xFilial('SD3') + "' " +; 
	        " AND SD3C.D3_COD <> SC2.C2_PRODUTO " +; 
	        " AND SD3C.D_E_L_E_T_ <> '*' " +; 
	" GROUP  BY SD3C.D3_OP, " +; 
	            " SD3C.D3_COD, " +; 
	            " SD3C.D3_FILIAL "
	//n„o usar ChangeQuery pois converte errado o create view
	MATExecQry(cQuery)            
	            
	            
	cQuery := " SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT) " +; 
	                          " WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT * -1) " +; 
	                          " ELSE 0 END) AS QUANT, " +;
	                 " SD3.D3_COD, "+; 
	                 " SD3.D3_OP, " +; 
	                 " MAX(D3_EMISSAO) AS D3_EMISSAO, " +; 
	                 " SD3.D3_FILIAL, " +;
	                 " SD3.D3_PERBLK, " +;
	                 " SD3.R_E_C_N_O_ AS SD3RECNO, SD3.D3_ESTORNO " +; 
	            " FROM " + RetSqlName("SD3") + " SD3 " +;
	            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
	              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	             " AND SB1.B1_COD     = SD3.D3_COD " +; 
	             " AND SB1.D_E_L_E_T_ <> '*' "
	
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
		                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
		                " AND SBZ.D_E_L_E_T_ <> '*' "
	EndIf
	
	cQuery += "JOIN " + RetSqlName("SC2") + " SC2 " +; 
	           " ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD " +; 
	          " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
	          " AND SC2.D_E_L_E_T_ <> '*' " +; 
	          " AND SC2.C2_ITEM   <> 'OS' " +; 
	          " AND SC2.C2_TPPR   IN ('I',' ') " +; 
	         " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
	           " ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	          " AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
	          " AND SB1_OP.D_E_L_E_T_ <> '*' "
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
		                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		               " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
		               " AND SBZ_OP.D_E_L_E_T_ <> '*' " 
	EndIF
	
	cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' " +; 
	            " AND SD3.D3_OP     <> ' ' " +; 
	            " AND (SD3.D3_CF  LIKE ('PR%') " +; 
	            "  OR  SD3.D3_CF  LIKE ('DE%') " +; 
	            "  OR  SD3.D3_CF  LIKE ('RE%')) " +; 
	            " AND SB1.B1_CCCUSTO = ' ' " +; 
	            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
	            " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' " 
	            
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += " AND SB1.B1_TIPO "
	EndIf
	
	cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cQuery += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
	          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
	Else
		cQuery += " AND SB1_OP.B1_TIPO "
	EndIf
	
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cQuery += " AND (SELECT Min(ORDEM.QUANT) " +;
        			" FROM VWORDEM ORDEM where ORDEM.D3_OP = SD3.D3_OP) < 0 "
    cQuery += " AND SD3.D3_ESTORNO <> 'S' "
	cQuery += " GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
	cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_ESTORNO "          
	
	cQuery += " HAVING (Sum(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT) " +; 
	                          " WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT * -1) ELSE 0 END)) <> 0 "
	cQuery += " ORDER BY 4,3,2"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)	
		
	While !(cAliasTmp)->(Eof())
		
		SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
			
		//grava tabela fÌsica para guardar histÛrico
		SVV->(dbSetOrder(1))
		If !SVV->(dbSeek(cSVVFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		
			//************************************************************************
			// Bloco K291
			//************************************************************************
			Reclock("SVV",.T.)
			SVV->VV_PRGORI  := cChamada
			SVV->VV_FILIAL  := cSVVFilial
			SVV->VV_MESSPED := STR(cMes,2)
			SVV->VV_ANOSPED := STR(cAno,4)
			SVV->VV_REG     := "K291"
			SVV->VV_OP      := (cAliasTmp)->D3_OP
			SVV->VV_PRODUTO := (cAliasTmp)->D3_COD
			SVV->VV_QUANT   := (cAliasTmp)->QUANT
			SVV->(MsUnlock())
			
		Else
			//************************************************************************
			// Bloco K291 - ajuste de quantidades em multiplos apontamentos
			//************************************************************************
			SVV->(dbSeek(cSVVFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		    While SVV->(!Eof()) .And. SVV->VV_FILIAL == cSVVFilial .And. SVV->VV_MESSPED == STR(cMes,2) .And. SVV->VV_ANOSPED == STR(cAno,4) .And. SVV->VV_OP == (cAliasTmp)->D3_OP .And. SVV->VV_PRODUTO == (cAliasTmp)->D3_COD .And. SVV->VV_PRGORI == cChamada
		    	RecLock("SVV",.F.,.T.)		    	
		    	SVV->VV_QUANT += (cAliasTmp)->QUANT
		    	SVV->(MsUnlock())
				SVV->(dbSkip())
		    EndDo
		
		EndIf
		
		(cAliasTmp)->(dbSkip())
	EndDo
	
	(cAliasTmp)->(dbCloseArea())
	
	If TCIsView("VWORDEM")
		cQuery := " DROP VIEW VWORDEM "
		MATExecQry(cQuery)
	EndIf
	
Else

	ProcLogAtu('PCP K291',"PCP K291 - SQL/ORA    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	If TCIsView("VWSEL1")
		cQuery := " DROP VIEW VWSEL1 "
		MATExecQry(cQuery)
	EndIf
	
	//Busca os dados para geraÁ„o do K291
	cQuery := " CREATE VIEW VWSEL1 AS "
	cQuery += " SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT) " +; 
	                          " WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT * -1) " +; 
	                          " ELSE 0 END) AS QUANT, " +;
	                 " SD3.D3_COD, "+; 
	                 " SD3.D3_OP, " +; 
	                 " MAX(D3_EMISSAO) AS D3_EMISSAO, " +; 
	                 " SD3.D3_FILIAL, " +;
	                 " SD3.D3_PERBLK, " +;
	                 " SD3.R_E_C_N_O_ AS SD3RECNO, SD3.D3_ESTORNO "
	cUpdateD3 := " FROM " + RetSqlName("SD3") + " SD3 " +;
	            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
	              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	             " AND SB1.B1_COD     = SD3.D3_COD " +; 
	             " AND SB1.D_E_L_E_T_ <> '*' " +;
	             " AND SB1.B1_TIPO IN ("+cTipo03+","+cTipo04+") "
	
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
		                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
		                " AND SBZ.D_E_L_E_T_ <> '*' "
	EndIf
	
	cUpdateD3 += "JOIN " + RetSqlName("SC2") + " SC2 "
				//tratamento para a concatenÁ„o no postgres.		
				If TCGetDB() $ "POSTGRES"
					cUpdateD3 +=  " ON SD3.D3_OP      = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) "
				Else
					cUpdateD3 +=  " ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "
				EndIf							
				
			  cUpdateD3 +=  " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
	          " AND SC2.D_E_L_E_T_ <> '*' " +; 
	          " AND SC2.C2_ITEM   <> 'OS' " +; 
	          " AND SC2.C2_TPPR   IN ('I',' ') " +; 
	         " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
	           " ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	          " AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
	          " AND SB1_OP.D_E_L_E_T_ <> '*' "
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
		                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		               " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
		               " AND SBZ_OP.D_E_L_E_T_ <> '*' " 
	EndIF
	
	cUpdateD3 += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' " +; 
	            " AND SD3.D3_OP     <> ' ' " +; 
	            " AND (SD3.D3_CF  LIKE ('PR%') " +; 
	            "  OR  SD3.D3_CF  LIKE ('DE%') " +; 
	            "  OR  SD3.D3_CF  LIKE ('RE%')) " +; 
	            " AND SB1.B1_CCCUSTO = ' ' " +; 
	            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
	            " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' " 
	            
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cUpdateD3 += " AND SB1.B1_TIPO "
	EndIf
	
	cUpdateD3 += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cUpdateD3 += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
	          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
	Else
		cUpdateD3 += " AND SB1_OP.B1_TIPO "
	EndIf
	
	cUpdateD3 += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cUpdateD3 += " AND (select min(QUANT) from ( " +;
						" SELECT Sum(CASE " +;
									 " WHEN SD3C.D3_CF LIKE ( 'DE%' ) THEN ( SD3C.D3_QUANT *- 1 ) " +;
									 " WHEN SD3C.D3_CF LIKE ( 'RE%' ) THEN ( SD3C.D3_QUANT ) " +;
									 " ELSE 0 " +;
								   " END)        AS QUANT, " +;
							   " SD3C.D3_COD, " +;
							   " SD3C.D3_OP " +;
						" FROM   "+RetSqlName("SD3") + " SD3C " +;
							   " JOIN "+RetSqlName("SB1") + " SB1 " +;
								 " ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " +;
									" AND SB1.B1_COD = SD3C.D3_COD " +;
									" AND SB1.D_E_L_E_T_ <> '*' " +;
							   " JOIN "+RetSqlName("SC2") + " SC2 " 
								//tratamento para a concatenÁ„o no postgres.		
								If TCGetDB() $ "POSTGRES"
									cUpdateD3 +=  " ON SD3C.D3_OP = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) "								
								Else
									cUpdateD3 +=  " ON SD3C.D3_OP = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "
								EndIf

								cUpdateD3 +=	" AND SC2.C2_FILIAL = '" + xFilial('SC2') + "' " +;
									" AND SC2.D_E_L_E_T_ <> '*' " +;
									" AND SC2.C2_ITEM <> 'OS' " +;
									" AND SC2.C2_TPPR IN ( 'I', ' ' ) " +;
							   " JOIN "+RetSqlName("SB1") + " SB1_OP " +;
								 " ON SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " +;
									" AND SB1_OP.B1_COD = SC2.C2_PRODUTO " +;
									" AND SB1_OP.D_E_L_E_T_ <> '*' " +;
						" WHERE  SD3C.D3_FILIAL = '" + xFilial('SD3') + "' " +;
							   " AND SD3C.D3_COD <> SC2.C2_PRODUTO " +;
							   " AND SD3C.D_E_L_E_T_ <> '*' " +;
							   " AND SD3C.D3_OP = SD3.D3_OP " +;
						" GROUP  BY SD3C.D3_OP, " +;
								  " SD3C.D3_COD, " +;
								  " SD3C.D3_FILIAL " +;
						" ) ORDEM ) < 0 "
	cUpdateD3 += " AND SD3.D3_ESTORNO <> 'S' "

	If  TCGetDB() $ "ORACLE"

			cUpdateD3 := " FROM "+;
		"  (SELECT D3_COD,    "+;
		"         D3_OP,"+;
		"		  D3_CF,"+;
		"		  D3_QUANT,"+;
		"		  D3_EMISSAO,"+;
		"		  D3_FILIAL,"+;
		"		  D3_PERBLK,"+;
		"		  D3_ESTORNO,"+;
		"          R_E_C_N_O_"+;
		"   FROM "+RetSqlName("SD3")+" SD3 "+;
		"   WHERE D_E_L_E_T_ <> '*' "+;
		"     AND D3_FILIAL = '" + xFilial('SD3') + "' "+;
		"     AND D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "+; 		
		"     AND D_E_L_E_T_ <> '*' "+;
		"     AND D3_OP <> ' ' "+;
		"     AND (D3_CF LIKE ('PR%') "+;
		"          OR D3_CF LIKE ('DE%') "+;
		"          OR D3_CF LIKE ('RE%')) "+;
		"     AND D3_ESTORNO <> 'S' ) SD3 "+;
		"JOIN "

		cUpdateD3 += "   (SELECT B1_COD "+;
		"   FROM "+RetSqlName("SB1")+" SB1"+;
		"   WHERE B1_FILIAL = '" + xFilial('SB1') + "'  "+;
		"     AND D_E_L_E_T_ <> '*' "+;
		"     AND B1_CCCUSTO = ' ' "+;
		"     AND B1_COD NOT LIKE 'MOD%' "+;
		"     AND B1_TIPO IN ("+cTipo03+", "+;
		"                     "+cTipo04+") ) SB1 ON SB1.B1_COD = SD3.D3_COD "+;
		"JOIN "

		cUpdateD3 += "  (SELECT C2_PRODUTO, SC2.C2_NUM"+ cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD AS C2_OP"+;
		"   FROM "+RetSqlName("SC2")+" SC2 "+;
		"   WHERE C2_FILIAL = '" + xFilial('SC2') + "'  "+;
		"     AND D_E_L_E_T_ <> '*' "+;
		"     AND C2_ITEM <> 'OS' "+;
		"     AND C2_TPPR IN ('I', "+;
		"                     ' ') ) SC2 ON SD3.D3_OP = SC2.C2_OP "+;
		"JOIN "

		cUpdateD3 += "  (SELECT B1_COD "+;
		"   FROM "+RetSqlName("SB1")+" SB1 "+;
		"   WHERE D_E_L_E_T_ <> '*' "+;
		"     AND B1_FILIAL = '" + xFilial('SB1') + "'  "+;
		"     AND B1_CCCUSTO = ' ' "+;
		"     AND B1_COD NOT LIKE 'MOD%' "+;
		"      AND B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+")) SB1_OP1 ON SB1_OP1.B1_COD = SC2.C2_PRODUTO "+;	
		"JOIN "

		cUpdateD3 += "  (SELECT SD3C.D3_OP, "+;
		"          Min(QUANT) "+;
		"   FROM "+;
		"     (SELECT Sum(CASE "+;
		"                     WHEN D3_CF LIKE ('DE%') THEN (D3_QUANT *- 1) "+;
		"                     WHEN D3_CF LIKE ('RE%') THEN (D3_QUANT) "+;
		"                     ELSE 0 "+;
		"                 END) AS QUANT, "+;
		"             D3_COD, "+;
		"             D3_OP "+;
		"      FROM "+RetSqlName("SD3")+" SD3 "+;
		"      WHERE D3_FILIAL = '" + xFilial('SD3') + "'  "+;
		"        AND D_E_L_E_T_ <> '*' GROUP  BY D3_OP, "+;
		"                                        D3_COD, "+;
		"                                        D3_FILIAL ) SD3C "+;
		"   JOIN "

		cUpdateD3 += "     (SELECT B1_COD "+;
		"      FROM "+RetSqlName("SB1")+" SB1 "+;
		"      WHERE D_E_L_E_T_ <> '*' "+;
		"        AND B1_FILIAL = '" + xFilial('SB1') + "' ) SB1 ON SB1.B1_COD = SD3C.D3_COD "+;
		"   JOIN "

		cUpdateD3 += "  (SELECT C2_PRODUTO, SC2.C2_NUM"+ cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD AS C2_OP "+;
		"      FROM "+RetSqlName("SC2")+" SC2 "+;
		"      WHERE C2_FILIAL = '" + xFilial('SC2') + "'  "+;
		"        AND D_E_L_E_T_ <> '*' "+;
		"        AND C2_ITEM <> 'OS' "+;
		"        AND C2_TPPR IN ('I', "+;
		"                        ' ') ) SC2_2 ON SD3C.D3_OP = SC2_2.C2_OP "+;
		"   JOIN "

		cUpdateD3 += "     (SELECT B1_COD "+;
		"      FROM "+RetSqlName("SB1")+" SB1 "+;
		"      WHERE B1_FILIAL = '" + xFilial('SB1') + "' "+;
		"        AND D_E_L_E_T_ <> '*' ) SB1_OP_2 ON SB1_OP_2.B1_COD = SC2_2.C2_PRODUTO "+;
		"   AND SD3C.D3_COD <> SC2_2.C2_PRODUTO "+;
		"   GROUP BY SD3C.D3_OP "+;
		"   HAVING Min(QUANT) < 0) SD3_NEGAT ON SD3.D3_OP = SD3_NEGAT.D3_OP  "
	ENDIF
	
	cQuery += cUpdateD3 //compartilha where para update e select
	cQuery += " GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
	cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_ESTORNO "          
	
	cQuery += " HAVING (Sum(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT) " +; 
	                          " WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT * -1) ELSE 0 END)) <> 0 "
	

	ProcLogAtu('PCP K291',"PCP K291 - Montagem query 1    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//executa update para marcar d3_perblk
	cUpdateD3 := " UPDATE " + RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2) + STR(cAno,4) + "' " +;
				" 	WHERE R_E_C_N_O_ IN " +;
				" (SELECT SD3.R_E_C_N_O_ " + cUpdateD3 + " ) "	
	
	MATExecQry(cUpdateD3)
	
	ProcLogAtu('PCP K291',"PCP K291 - Registros marcados    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//cria view para leitura
	MATExecQry(cQuery)
	
	ProcLogAtu('PCP K291',"PCP K291 - Montagem query 2    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//varre view para otimizar calculo de quantidades
	cQuery := "	SELECT " +;
				" Sum(QUANT) AS QUANT, " +;
				" D3_COD, " +;
				" D3_OP " +;
				" FROM VWSEL1 " +;
				" GROUP BY D3_OP, " +;
						 " D3_COD "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	ProcLogAtu('PCP K291',"PCP K291 - Busca concluÌda    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//Carrega as filiais uma ˙nica vez
	cSVVFilial := xFilial("SVV")
	
	While !(cAliasTmp)->(Eof())
		
		//grava tabela fÌsica para guardar histÛrico
		SVV->(dbSetOrder(1))
		If !SVV->(dbSeek(cSVVFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		
			//************************************************************************
			// Bloco K291
			//************************************************************************
			Reclock("SVV",.T.)
			SVV->VV_PRGORI  := cChamada
			SVV->VV_FILIAL  := cSVVFilial
			SVV->VV_MESSPED := STR(cMes,2)
			SVV->VV_ANOSPED := STR(cAno,4)
			SVV->VV_REG     := "K291"
			SVV->VV_OP      := (cAliasTmp)->D3_OP
			SVV->VV_PRODUTO := (cAliasTmp)->D3_COD
			SVV->VV_QUANT   := (cAliasTmp)->QUANT
			SVV->(MsUnlock())
			
		Else
			//************************************************************************
			// Bloco K291 - ajuste de quantidades em multiplos apontamentos
			//************************************************************************
			SVV->(dbSeek(cSVVFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		    While SVV->(!Eof()) .And. SVV->VV_FILIAL == cSVVFilial .And. SVV->VV_MESSPED == STR(cMes,2) .And. SVV->VV_ANOSPED == STR(cAno,4) .And. SVV->VV_OP == (cAliasTmp)->D3_OP .And. SVV->VV_PRODUTO == (cAliasTmp)->D3_COD .And. SVV->VV_PRGORI == cChamada
		    	RecLock("SVV",.F.,.T.)		    	
		    	SVV->VV_QUANT += (cAliasTmp)->QUANT
		    	SVV->(MsUnlock())
				SVV->(dbSkip())
		    EndDo
		
		EndIf
		
		(cAliasTmp)->(dbSkip())
	EndDo
	
	(cAliasTmp)->(dbCloseArea())
	
	If TCIsView("VWSEL1")
		cQuery := " DROP VIEW VWSEL1 "
		MATExecQry(cQuery)
	EndIf
	
EndIf

fGravaK291(cAliK291,cSVVFilial,cMes,cAno,cChamada)

fLimpezaDic()

Return

/*/{Protheus.doc} fGravaK291
	@type  Static Function
	@author user
	@since 24/08/2022
	@version 1.0
/*/
Static Function fGravaK291(cAliK291,cSVVFilial,cMes,cAno,cChamada)

	ProcLogAtu('PCP K291',"PCP K291 - Cria tempor·ria    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

	//******************************************
	// Grava tabela tempor·ria para rodar o SPED
	//******************************************
	SVV->(dbSetOrder(1))
	SVV->(dbSeek(cSVVFilial+STR(cMes,2)+STR(cAno,4)))
	While SVV->(!Eof()) .And. SVV->VV_FILIAL == cSVVFilial .And. SVV->VV_MESSPED == STR(cMes,2) .And. SVV->VV_ANOSPED == STR(cAno,4)
		If SVV->VV_PRGORI == cChamada
			If SVV->VV_QUANT > 0
				Reclock(cAliK291,.T.)
				(cAliK291)->FILIAL     := SVV->VV_FILIAL
				(cAliK291)->REG        := "K291"
				(cAliK291)->COD_DOC_OP := SVV->VV_OP
				(cAliK291)->COD_ITEM   := SVV->VV_PRODUTO
				(cAliK291)->QTD        := SVV->VV_QUANT
				(cAliK291)->(MsUnLock())
			Else
				RecLock("SVV", .F.)
				SVV->(DBDelete())
				SVV->(MsUnLock())
			EndIf
		EndIf
		SVV->(dbSkip())
	EndDo
	MsUnlock()
Return 


/*------------------------------------------------------------------------//
//Programa:	  PROCK275
//Autor:	  Ricardo Peixoto 
//Data:		  05/10/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K275
//            CorreÁıes: K235, K265
//Parametros: 1 - cAliK275      - Alias do arquivo de trabalho do K275
//            2 - dDataDe		- Data Inicial da Apuracao   
//			  3 - dDataAte		- Data Final da Apuracao
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK275PRO(cAliK275,dDataDe,dDataAte,lRepross)

Local cQuery		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cT4HFilial    := ""
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local aProdNeg	    := {}
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local nSaldo		:= 0
Local cChamada   	:= If (lRepross, "SPEDFISCAL", "MATR241   ")
Local cCharSoma     := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ") //n„o usar ChangeQuery para update e create

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

//Tabela para o perÌodo j· limpa.

ProcLogAtu('PCP K275',"PCP K275 - Inicio de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

If(TCGetDB() $ "ORACLE/DB2/400/INFORMIX")

	//Busca os dados para geraÁ„o do K275
	cQuery := " SELECT 'K235' AS BLOCO," +;
						" SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) " +; 
	                          " WHEN SD3.D3_CF LIKE ('ER%') THEN (SD3.D3_QUANT*-1) " +; 
	                          " WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) " +; 
	                          " ELSE 0 END) AS QUANT, " +;
	                 " SD3.D3_COD, "+; 
	                 " SD3.D3_OP, " +; 
	                 " MAX(D3_EMISSAO) AS D3_EMISSAO, " +; 
	                 " SD3.D3_FILIAL, " +;
	                 " SD3.D3_PERBLK, " +;
	                 " SD3.R_E_C_N_O_ AS SD3RECNO, SD3.d3_cf, SC2.C2_PRODUTO, SD4.D4_PRDORG " +; 
	            " FROM " + RetSqlName("SD3") + " SD3 " +;
	            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
	              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	             " AND SB1.B1_COD     = SD3.D3_COD " +; 
	             " AND SB1.D_E_L_E_T_ <> '*' "
	
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
		                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
		                " AND SBZ.D_E_L_E_T_ <> '*' "
	EndIf
	
	cQuery += " LEFT JOIN " + RetSqlName("SD4") + " SD4 ON SD4.D4_FILIAL = SD3.D3_FILIAL AND SD4.D4_COD = SD3.D3_COD AND SD4.D4_OP = SD3.D3_OP "+;
			  " AND SD4.D4_TRT = SD3.D3_TRT AND SD4.D4_LOTECTL = SD3.D3_LOTECTL AND SD4.D4_NUMLOTE = SD3.D3_NUMLOTE "+;
			  " AND SD4.D4_LOCAL = SD3.D3_LOCAL AND SD4.D4_ORDEM = SD3.D3_ORDEM AND SD4.D_E_L_E_T_ <> '*' " /*AND SD4.D4_OPORIG = '' AND SD4.D4_SEQ = ''*/
	
	cQuery += "JOIN " + RetSqlName("SC2") + " SC2 " +; 
	           " ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD " +; 
	          " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
	          " AND SC2.D_E_L_E_T_ <> '*' " +; 
	          " AND SC2.C2_ITEM   <> 'OS' " +; 
	          " AND SC2.C2_TPPR   IN ('I',' ') " +; 
	         " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
	           " ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	          " AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
	          " AND SB1_OP.D_E_L_E_T_ <> '*' "
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
		                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		               " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
		               " AND SBZ_OP.D_E_L_E_T_ <> '*' " 
	EndIF
	
	cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' " +; 
	            " AND SD3.D3_OP     <> ' ' " +; 
	            " AND (SD3.D3_CF  LIKE ('RE%') OR SD3.D3_CF  LIKE ('DE%') OR SD3.D3_CF  LIKE ('ER%') OR SD3.D3_CF  LIKE ('PR%') )" +;
	            " AND SB1.B1_CCCUSTO = ' ' " +; 
	            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
	            " AND (D3_EMISSAO < '" + DtoS(dDataDe) + "'  AND (D3_PERBLK = '" + PADR(Nil,tamSX3('D3_PERBLK')[1]) + "' OR D3_PERBLK = '" + STR(cMes,2)+STR(cAno,4) + "  ')) " +;
	            " AND SD3.D_E_L_E_T_ <> '*' " +; 
	            " AND (SELECT COUNT(*) FROM " + RetSqlName("SD4") + " SD4 " +; 
	            "      WHERE SD4.D4_FILIAL  = '" + xFilial('SD4') + "' " +; 
	            "      AND SD4.D4_OP     = SD3.D3_OP " +;
	            "      AND SD4.D_E_L_E_T_ <> '*' " +; 
	            "      AND SD4.D4_QTDEORI < 0) = 0 "
	            
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += " AND SB1.B1_TIPO "
	EndIf
	
	cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cQuery += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
	          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
	Else
		cQuery += " AND SB1_OP.B1_TIPO "
	EndIf
	
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
	cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.d3_cf, SC2.C2_PRODUTO, SD4.D4_PRDORG "
	
	cQuery += " UNION "
	cQuery += " SELECT 'K265' AS BLOCO," +;
						" SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) " +; 
	                          " WHEN SD3.D3_CF LIKE ('ER%') THEN (SD3.D3_QUANT*-1) " +; 
	                          " WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) " +; 
	                          " ELSE 0 END) AS QUANT, " +;
	                 " SD3.D3_COD, "+; 
	                 " SD3.D3_OP, " +; 
	                 " MAX(D3_EMISSAO) AS D3_EMISSAO, " +; 
	                 " SD3.D3_FILIAL, " +;
	                 " SD3.D3_PERBLK, " +;
	                 " SD3.R_E_C_N_O_ AS SD3RECNO, SD3.d3_cf, SC2.C2_PRODUTO, SD4.D4_PRDORG " +; 
	            " FROM " + RetSqlName("SD3") + " SD3 " +;
	            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
	              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	             " AND SB1.B1_COD     = SD3.D3_COD " +; 
	             " AND SB1.D_E_L_E_T_ <> '*' "
	
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
		                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
		                " AND SBZ.D_E_L_E_T_ <> '*' "
	EndIf
	
	cQuery += " LEFT JOIN " + RetSqlName("SD4") + " SD4 ON SD4.D4_FILIAL = SD3.D3_FILIAL AND SD4.D4_COD = SD3.D3_COD AND SD4.D4_OP = SD3.D3_OP "+;
			  " AND SD4.D4_TRT = SD3.D3_TRT AND SD4.D4_LOTECTL = SD3.D3_LOTECTL AND SD4.D4_NUMLOTE = SD3.D3_NUMLOTE "+;
			  " AND SD4.D4_LOCAL = SD3.D3_LOCAL AND SD4.D4_ORDEM = SD3.D3_ORDEM AND SD4.D_E_L_E_T_ <> '*' " /*AND SD4.D4_OPORIG = '' AND SD4.D4_SEQ = ''*/
	
	cQuery += "JOIN " + RetSqlName("SC2") + " SC2 " +; 
	           " ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD " +; 
	          " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
	          " AND SC2.D_E_L_E_T_ <> '*' " +; 
	          " AND SC2.C2_ITEM   <> 'OS' " +; 
	          " AND SC2.C2_TPPR   IN ('R') " +; 
	         " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
	           " ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	          " AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
	          " AND SB1_OP.D_E_L_E_T_ <> '*' "
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
		                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		               " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
		               " AND SBZ_OP.D_E_L_E_T_ <> '*' " 
	EndIF
	
	cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' " +; 
	            " AND SD3.D3_OP     <> ' ' " +; 
	            " AND (SD3.D3_CF  LIKE ('RE%') OR SD3.D3_CF  LIKE ('DE%') OR SD3.D3_CF  LIKE ('ER%') OR SD3.D3_CF  LIKE ('PR%') )" +;
	            " AND SB1.B1_CCCUSTO = ' ' " +; 
	            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
	            " AND (D3_EMISSAO < '" + DtoS(dDataDe) + "'  AND (D3_PERBLK = '" + PADR(Nil,tamSX3('D3_PERBLK')[1]) + "' OR D3_PERBLK = '" + STR(cMes,2)+STR(cAno,4) + "  ')) " +;
	            " AND SD3.D_E_L_E_T_ <> '*' "  
	            
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += " AND SB1.B1_TIPO "
	EndIf
	
	cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cQuery += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
	          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
	Else
		cQuery += " AND SB1_OP.B1_TIPO "
	EndIf
	
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
	cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.d3_cf, SC2.C2_PRODUTO, SD4.D4_PRDORG "
	   
	cQuery += "ORDER BY 4,3,2"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	//Carrega as filiais uma ˙nica vez
	cT4HFilial := xFilial("T4H")
	
	While !(cAliasTmp)->(Eof())
		
		//grava tabela fÌsica para guardar histÛrico
		T4H->(dbSetOrder(2))
		If !T4H->(dbSeek(cT4HFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada))
		
			// nao cria 275 para RE
			SVK->(dbSetOrder(2))
			If (!SVK->(dbSeek(cT4HFilial+(cAliasTmp)->C2_PRODUTO+(cAliasTmp)->D3_COD+ cChamada)) .AND. !SVK->(dbSeek(cT4HFilial+(cAliasTmp)->D3_COD+(cAliasTmp)->C2_PRODUTO+ cChamada))) .Or. (cAliasTmp)->D3_CF == "ER0" 
		
				//************************************************************************
				// Bloco K275 para componentes e acabado. N„o cria para produto retrabalho
				//************************************************************************
				Reclock("T4H",.T.)
				T4H->T4H_PRGORI  := cChamada
				T4H->T4H_FILIAL := cT4HFilial //chave
				T4H->T4H_MESSPE := STR(cMes,2)
				T4H->T4H_ANOSPE := STR(cAno,4)
				T4H->T4H_REG    := "K275"
				T4H->T4H_PRODUT := (cAliasTmp)->D3_COD
				If (cAliasTmp)->QUANT >= 0
					T4H->T4H_QTD_PO := (cAliasTmp)->QUANT
				Else
					T4H->T4H_QTD_NE := (cAliasTmp)->QUANT * -1
				EndIf
				If (cAliasTmp)->BLOCO == "K235" .Or. (cAliasTmp)->BLOCO == "K255"
					T4H->T4H_INS_SU := (cAliasTmp)->D4_PRDORG //GetSubst((cAliasTmp)->D3_COD,(cAliasTmp)->D3_OP,dDataDe,dDataAte)
				Else
					T4H->T4H_INS_SU := ""
				EndIf
				T4H->T4H_OP     := (cAliasTmp)->D3_OP //chave
				T4H->T4H_BLK_CO := (cAliasTmp)->BLOCO //controle interno - bloco corrigido
				T4H->T4H_CF     := (cAliasTmp)->D3_CF
				T4H->(MsUnlock())
			EndIf
			
		Else		
			//**************************************************************
			// Bloco K275 - atualiza quantidades para multiplos apontamentos
			//**************************************************************
			T4H->(dbSeek(cT4HFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada))
		    While T4H->(!Eof()) .And. T4H->T4H_FILIAL == cT4HFilial .And. T4H->T4H_MESSPE == STR(cMes,2) .And. T4H->T4H_ANOSPE == STR(cAno,4) .And. T4H->T4H_OP == (cAliasTmp)->D3_OP .And. T4H->T4H_PRODUT == (cAliasTmp)->D3_COD .And. T4H->T4H_PRGORI == cChamada
		    	RecLock("T4H",.F.,.T.)
		    	
		    	nSaldo := T4H->T4H_QTD_PO - T4H->T4H_QTD_NE
		    	nSaldo += (cAliasTmp)->QUANT
		    	
		    	If nSaldo >= 0
					T4H->T4H_QTD_PO := nSaldo
					T4H->T4H_QTD_NE := 0
				Else
					T4H->T4H_QTD_NE := nSaldo * -1
					T4H->T4H_QTD_PO := 0
				EndIf
				
				T4H->(MsUnlock())
				T4H->(dbSkip())
		    EndDo
		
		EndIf
	
		If lRepross
			SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
		EndIf	
		(cAliasTmp)->(dbSkip())
	
	EndDo
	
	(cAliasTmp)->(dbCloseArea())

Else

	
	If TCIsView("VWSEL1")
		cQuery := " DROP VIEW VWSEL1 "
		MATExecQry(cQuery)
	EndIf 
	
	//Busca os dados para geraÁ„o do K275
	cQuery := " SELECT SD3_SD4_1.BLOCO,  " +; 
						" SD3_SD4_1.QUANT, " +;  
						" SD3_SD4_1.D3_COD, " +;  
						" SD3_SD4_1.D3_OP, " +;  
						" SD3_SD4_1.D3_EMISSAO, " +;  
						" SD3_SD4_1.D3_FILIAL, " +;  
						" SD3_SD4_1.D3_PERBLK, " +;  
						" SD3_SD4_1.SD3RECNO, " +;  
						" SD3_SD4_1.D3_CF, " +; 
						" SD3_SD4_1.D4_PRDORG, " +; 
						" SC2_1.C2_PRODUTO " +; 
				" FROM (SELECT SD3_1.BLOCO,  " +; 
								" SD3_1.QUANT,  " +; 
								" SD3_1.D3_COD,  " +; 
								" SD3_1.D3_OP,  " +; 
								" SD3_1.D3_EMISSAO,  " +; 
								" SD3_1.D3_FILIAL,  " +; 
								" SD3_1.D3_PERBLK,  " +; 
								" SD3_1.SD3RECNO,  " +; 
								" SD3_1.D3_CF, " +; 
								" SD4_1.D4_PRDORG " +; 
						" FROM   (SELECT 'K235' AS BLOCO, " +; 
										" Sum(CASE " +; 
									   		" WHEN SD3.D3_CF LIKE ( 'DE%' ) THEN ( SD3.D3_QUANT * -1 ) " +; 
									   		" WHEN SD3.D3_CF LIKE ( 'RE%' ) THEN ( SD3.D3_QUANT ) " +; 
									   		" WHEN SD3.D3_CF LIKE ( 'ER%' ) THEN ( SD3.D3_QUANT * -1 )  " +;
									   		" WHEN SD3.D3_CF LIKE ( 'PR%' ) THEN ( SD3.D3_QUANT ) " +; 
									   		" ELSE 0 " +; 
									   	" END) AS QUANT, " +; 
									   	" D3_COD,  " +;
									   	" D3_OP,  " +;
									   	" Cast(Max(D3_EMISSAO) AS CHAR(8)) AS D3_EMISSAO, " +; 
									   	" D3_FILIAL,  " +;
									   	" D3_PERBLK,  " +;
									   	" R_E_C_N_O_ AS SD3RECNO, " +; 
									   	" D3_CF,  " +;
									   	" D3_TRT,  " +;
									   	" D3_LOTECTL,  " +;
									   	" D3_NUMLOTE,  " +;
									   	" D3_LOCAL,  " +;
									   	" D3_ORDEM  " +;
								   	" FROM   " + RetSqlName("SD3") + " AS SD3 " +;  
								   	" WHERE  ( D3_FILIAL = '" + xFilial('SD3') + "' ) " +;  
								   			" AND ( D_E_L_E_T_ <> '*' )  " +; 
								   			" AND ( D3_OP <> ' ' ) " +;  
								   			" AND ( D3_CF LIKE 'RE%' " +;  
								   					" OR D3_CF LIKE 'DE%' " +;  
								   					" OR D3_CF LIKE 'ER%' " +;  
								   					" OR D3_CF LIKE 'PR%' ) " +;  
						   					" AND (D3_EMISSAO < '" + DtoS(dDataDe) + "'  AND (D3_PERBLK = '" + PADR(Nil,tamSX3('D3_PERBLK')[1]) + "' OR D3_PERBLK = '" + STR(cMes,2)+STR(cAno,4) + "  ')) " +;
								   			" AND ( D_E_L_E_T_ <> '*' ) " +;  
								   			" AND ( D3_OP NOT IN (SELECT D4_OP " +;  
								   									" FROM   " + RetSqlName("SD4") + " AS SD4 " +;  
								   									" WHERE  ( D4_FILIAL = '" + xFilial('SD4') + "' ) " +;  
								   										" AND ( D_E_L_E_T_ <> '*' ) " +;  
								   										" AND ( D4_QTDEORI < 0 )) ) " +;  
								   	" GROUP  BY D3_OP, D3_COD, D3_FILIAL, D3_PERBLK, R_E_C_N_O_, D3_CF, D3_TRT, D3_LOTECTL, D3_NUMLOTE, D3_LOCAL, D3_ORDEM) AS SD3_1 " +;  
						" LEFT OUTER JOIN (SELECT D4_FILIAL, " +;  
												" D4_COD, " +;  
												" D4_OP, " +;  
												" D4_TRT, " +;  
												" D4_LOTECTL, " +;  
												" D4_NUMLOTE, " +;  
												" D4_LOCAL, " +;  
												" D4_ORDEM, " +;  
												" D4_PRDORG " +;  
											" FROM   " + RetSqlName("SD4") + " " +;  
											" WHERE  ( D_E_L_E_T_ <> '*' )) AS SD4_1 " +;  
											" ON SD4_1.D4_FILIAL       = SD3_1.D3_FILIAL " +;  
												" AND SD4_1.D4_COD     = SD3_1.D3_COD " +;  
												" AND SD4_1.D4_OP      = SD3_1.D3_OP " +;  
												" AND SD4_1.D4_TRT     = SD3_1.D3_TRT " +;  
												" AND SD4_1.D4_LOTECTL = SD3_1.D3_LOTECTL " +;  
												" AND SD4_1.D4_NUMLOTE = SD3_1.D3_NUMLOTE " +;  
												" AND SD4_1.D4_LOCAL   = SD3_1.D3_LOCAL " +;  
												" AND SD4_1.D4_ORDEM   = SD3_1.D3_ORDEM ) SD3_SD4_1 " +; 
				" JOIN (SELECT B1_COD " +; 
						" FROM   " + RetSqlName("SB1") + " AS SB1 " +;  
						" WHERE  ( B1_CCCUSTO = ' ' ) " +;  
							" AND ( B1_COD NOT LIKE 'MOD%' ) " +;  
							" AND ( B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") ) " +; 
							" AND SB1.B1_FILIAL = '" + xFilial('SB1') + "' " +; 
							" AND SB1.D_E_L_E_T_ <> '*') SB1_SD3_1 " +; 
						" ON SB1_SD3_1.B1_COD = SD3_SD4_1.D3_COD " 
						//tratamento para a concatenÁ„o no postgres.		
						If TCGetDB() $ "POSTGRES"
							cQuery +=  " JOIN (SELECT C2_PRODUTO, TRIM(C2_NUM " + cCharSoma + " C2_ITEM " + cCharSoma + " C2_SEQUEN " + cCharSoma + " C2_ITEMGRD) AS C2_OP " 								
						Else
							cQuery +=  " JOIN (SELECT C2_PRODUTO, C2_NUM " + cCharSoma + " C2_ITEM " + cCharSoma + " C2_SEQUEN " + cCharSoma + " C2_ITEMGRD AS C2_OP "
						EndIf

						cQuery += " FROM " + RetSqlName("SC2") + " AS SC2 " +; 
						" WHERE (C2_FILIAL = '" + xFilial('SC2') + "') " +; 
							" AND (D_E_L_E_T_ <> '*') " +; 
							" AND (C2_ITEM <> 'OS') " +; 
							" AND (C2_TPPR IN ('I', ' '))) SC2_1 " +; 
						" ON SD3_SD4_1.D3_OP = SC2_1.C2_OP " +; 
				" JOIN (SELECT B1_COD " +; 
						" FROM   " + RetSqlName("SB1") + " AS SB1_OP " +;  
						" WHERE  ( B1_CCCUSTO = ' ' ) " +;  
							" AND ( B1_COD NOT LIKE 'MOD%' ) " +;  
							" AND ( B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") ) " +;  
							" AND SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " +; 
							" AND SB1_OP.D_E_L_E_T_ <> '*') SB1_OP_1 " +; 
						" ON SC2_1.C2_PRODUTO = SB1_OP_1.B1_COD " +; 
				" UNION " +; 
				" SELECT SD3_SD4_1.BLOCO, " +;  
						" SD3_SD4_1.QUANT, " +;  
						" SD3_SD4_1.D3_COD, " +;  
						" SD3_SD4_1.D3_OP, " +;  
						" SD3_SD4_1.D3_EMISSAO, " +;  
						" SD3_SD4_1.D3_FILIAL, " +;  
						" SD3_SD4_1.D3_PERBLK, " +;  
						" SD3_SD4_1.SD3RECNO, " +;  
						" SD3_SD4_1.D3_CF, " +; 
						" SD3_SD4_1.D4_PRDORG, " +; 
						" SC2_1.C2_PRODUTO " +; 
				" FROM (SELECT SD3_1.BLOCO, " +;  
							" SD3_1.QUANT, " +;  
							" SD3_1.D3_COD, " +;  
							" SD3_1.D3_OP, " +;  
							" SD3_1.D3_EMISSAO, " +;  
							" SD3_1.D3_FILIAL, " +;  
							" SD3_1.D3_PERBLK, " +;  
							" SD3_1.SD3RECNO, " +;  
							" SD3_1.D3_CF, " +; 
							" SD4_1.D4_PRDORG " +; 
						" FROM   (SELECT 'K265' AS BLOCO, " +;  
										" Sum(CASE " +;  
											" WHEN SD3.D3_CF LIKE ( 'DE%' ) THEN ( SD3.D3_QUANT * -1 ) " +;  
											" WHEN SD3.D3_CF LIKE ( 'RE%' ) THEN ( SD3.D3_QUANT ) " +;  
											" WHEN SD3.D3_CF LIKE ( 'ER%' ) THEN ( SD3.D3_QUANT * -1 ) " +;  
											" WHEN SD3.D3_CF LIKE ( 'PR%' ) THEN ( SD3.D3_QUANT ) " +;  
											" ELSE 0 " +;  
										" END) AS QUANT, " +;  
										" D3_COD, " +;  
										" D3_OP, " +;  
										" Cast(Max(D3_EMISSAO) AS CHAR(8)) AS D3_EMISSAO, " +;  
										" D3_FILIAL, " +;  
										" D3_PERBLK, " +;  
										" R_E_C_N_O_                       AS SD3RECNO, " +;  
										" D3_CF, " +;  
										" D3_TRT, " +;  
										" D3_LOTECTL, " +;  
										" D3_NUMLOTE, " +;  
										" D3_LOCAL, " +;  
										" D3_ORDEM " +;  
								" FROM   " + RetSqlName("SD3") + " AS SD3 " +;  
								" WHERE  ( D3_FILIAL = '" + xFilial('SD3') + "' ) " +;  
										" AND ( D_E_L_E_T_ <> '*' )  " +; 
										" AND ( D3_OP <> ' ' ) " +;  
										" AND ( D3_CF LIKE 'RE%' " +;  
												" OR D3_CF LIKE 'DE%' " +;  
												" OR D3_CF LIKE 'ER%' " +;  
												" OR D3_CF LIKE 'PR%' ) " +;  
										" AND (D3_EMISSAO < '" + DtoS(dDataDe) + "'  AND (D3_PERBLK = '" + PADR(Nil,tamSX3('D3_PERBLK')[1]) + "' OR D3_PERBLK = '" + STR(cMes,2)+STR(cAno,4) + "  ')) " +;
										" AND ( D_E_L_E_T_ <> '*' ) " +;   
								" GROUP  BY D3_OP, D3_COD, D3_FILIAL, D3_PERBLK, R_E_C_N_O_, D3_CF, D3_TRT, D3_LOTECTL, D3_NUMLOTE, D3_LOCAL, D3_ORDEM) AS SD3_1 " +;  
								" LEFT OUTER JOIN (SELECT D4_FILIAL, " +;  
														" D4_COD, " +;  
														" D4_OP, " +;  
														" D4_TRT, " +;  
														" D4_LOTECTL, " +;  
														" D4_NUMLOTE, " +;  
														" D4_LOCAL, " +;  
														" D4_ORDEM, " +;  
														" D4_PRDORG " +;  
													" FROM   " + RetSqlName("SD4") + " " +;  
													" WHERE  ( D_E_L_E_T_ <> '*' )) AS SD4_1 " +;  
													" ON SD4_1.D4_FILIAL       = SD3_1.D3_FILIAL " +;  
														" AND SD4_1.D4_COD     = SD3_1.D3_COD " +;  
														" AND SD4_1.D4_OP      = SD3_1.D3_OP " +;  
														" AND SD4_1.D4_TRT     = SD3_1.D3_TRT " +;  
														" AND SD4_1.D4_LOTECTL = SD3_1.D3_LOTECTL " +;  
														" AND SD4_1.D4_NUMLOTE = SD3_1.D3_NUMLOTE " +;  
														" AND SD4_1.D4_LOCAL   = SD3_1.D3_LOCAL " +;  
														" AND SD4_1.D4_ORDEM   = SD3_1.D3_ORDEM ) SD3_SD4_1 " +; 
				" JOIN (SELECT B1_COD " +; 
						" FROM   " + RetSqlName("SB1") + " AS SB1 " +;  
						" WHERE  ( B1_CCCUSTO = ' ' ) " +;  
								" AND ( B1_COD NOT LIKE 'MOD%' ) " +;  
								" AND ( B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") ) " +; 
								" AND SB1.B1_FILIAL = '" + xFilial('SB1') + "' " +; 
								" AND SB1.D_E_L_E_T_ <> '*') SB1_SD3_1 " +; 
						" ON SB1_SD3_1.B1_COD = SD3_SD4_1.D3_COD " 
				//tratamento para a concatenÁ„o no postgres.		
				If TCGetDB() $ "POSTGRES"
					cQuery +=  " JOIN (SELECT C2_PRODUTO, TRIM(C2_NUM " + cCharSoma + " C2_ITEM " + cCharSoma + " C2_SEQUEN " + cCharSoma + " C2_ITEMGRD) AS C2_OP " 					
				Else
					cQuery +=  " JOIN (SELECT C2_PRODUTO, C2_NUM " + cCharSoma + " C2_ITEM " + cCharSoma + " C2_SEQUEN " + cCharSoma + " C2_ITEMGRD AS C2_OP "				
				EndIf

				cQuery += " FROM " + RetSqlName("SC2") + " AS SC2 " +; 
						" WHERE (C2_FILIAL = '" + xFilial('SC2') + "') " +; 
								" AND (D_E_L_E_T_ <> '*') " +; 
								" AND (C2_ITEM <> 'OS') " +; 
								" AND (C2_TPPR IN ( 'R' ))) SC2_1 " +; 
						" ON SD3_SD4_1.D3_OP = SC2_1.C2_OP " +; 
				" JOIN (SELECT B1_COD " +; 
						" FROM   " + RetSqlName("SB1") + " AS SB1_OP " +;  
						" WHERE  ( B1_CCCUSTO = ' ' ) " +;  
								" AND ( B1_COD NOT LIKE 'MOD%' ) " +;  
								" AND ( B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") ) " +;  
								" AND SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " +; 
								" AND SB1_OP.D_E_L_E_T_ <> '*') SB1_OP_1 " +; 
						" ON SC2_1.C2_PRODUTO = SB1_OP_1.B1_COD "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	ProcLogAtu('PCP K275',"PCP K275 - Montagem query 1    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	While !(cAliasTmp)->(Eof()) //mantida leitura geral para marcar PERBLK
		SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
		(cAliasTmp)->(dbSkip())
	EndDo
	
	(cAliasTmp)->(dbCloseArea())
	
	ProcLogAtu('PCP K275',"PCP K275 - Registros marcados    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//cria view para leitura
	cQuery := " CREATE VIEW VWSEL1 AS " + cQuery 
	MATExecQry(cQuery)
	
	ProcLogAtu('PCP K275',"PCP K275 - Montagem query 2    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//varre view para otimizar calculo de quantidades
	cQuery := "	SELECT " +; 
					" BLOCO, " +; 
					" Sum(QUANT) AS QUANT2, " +; 
					" D3_OP, " +; 
					" D3_COD, " +; 		
					" Min(D3_EMISSAO) AS D3_EMISSAO, " +; 
					" Min(D3_FILIAL) AS D3_FILIAL, " +; 
					" Min(C2_PRODUTO) AS C2_PRODUTO, " +; 
					" Min(D4_PRDORG) AS D4_PRDORG, " +; 
					" D3_CF " +; 
				" FROM VWSEL1 " +; 
				" GROUP BY D3_OP, " +; 
				         " D3_COD, " +; 
						 " BLOCO, " +; 
						 " D3_CF "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	//Carrega as filiais uma ˙nica vez
	cT4HFilial := xFilial("T4H")
	
	ProcLogAtu('PCP K275',"PCP K275 - Finalizando buscas    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	While !(cAliasTmp)->(Eof())
		
		//grava tabela fÌsica para guardar histÛrico
		T4H->(dbSetOrder(2))
		If !T4H->(dbSeek(cT4HFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada))
		
			// nao cria 275 para RE
			SVK->(dbSetOrder(2))
			If (!SVK->(dbSeek(cT4HFilial+(cAliasTmp)->C2_PRODUTO+(cAliasTmp)->D3_COD)) .AND. !SVK->(dbSeek(cT4HFilial+(cAliasTmp)->D3_COD+(cAliasTmp)->C2_PRODUTO))) .Or. (cAliasTmp)->D3_CF == "ER0" 
		
				//************************************************************************
				// Bloco K275 para componentes e acabado. N„o cria para produto retrabalho
				//************************************************************************
				Reclock("T4H",.T.)
				T4H->T4H_PRGORI  := cChamada
				T4H->T4H_FILIAL := cT4HFilial //chave
				T4H->T4H_MESSPE := STR(cMes,2)
				T4H->T4H_ANOSPE := STR(cAno,4)
				T4H->T4H_REG    := "K275"
				T4H->T4H_PRODUT := (cAliasTmp)->D3_COD
				If (cAliasTmp)->QUANT2 >= 0
					T4H->T4H_QTD_PO := (cAliasTmp)->QUANT2
				Else
					T4H->T4H_QTD_NE := (cAliasTmp)->QUANT2 * -1
				EndIf
				If (cAliasTmp)->BLOCO == "K235" .Or. (cAliasTmp)->BLOCO == "K255"
					T4H->T4H_INS_SU := (cAliasTmp)->D4_PRDORG //GetSubst((cAliasTmp)->D3_COD,(cAliasTmp)->D3_OP,dDataDe,dDataAte)
				Else
					T4H->T4H_INS_SU := ""
				EndIf
				T4H->T4H_OP     := (cAliasTmp)->D3_OP //chave
				T4H->T4H_BLK_CO := (cAliasTmp)->BLOCO //controle interno - bloco corrigido
				T4H->T4H_CF     := (cAliasTmp)->D3_CF
				T4H->(MsUnlock())
			EndIf
			
		Else		
			//**************************************************************
			// Bloco K275 - atualiza quantidades para multiplos apontamentos
			//**************************************************************
			T4H->(dbSeek(cT4HFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada))
		    While T4H->(!Eof()) .And. T4H->T4H_FILIAL == cT4HFilial .And. T4H->T4H_MESSPE == STR(cMes,2) .And. T4H->T4H_ANOSPE == STR(cAno,4) .And. T4H->T4H_OP == (cAliasTmp)->D3_OP .And. T4H->T4H_PRODUT == (cAliasTmp)->D3_COD .And. T4H->T4H_PRGORI == cChamada
		    	RecLock("T4H",.F.,.T.)
		    	
		    	nSaldo := T4H->T4H_QTD_PO - T4H->T4H_QTD_NE
		    	nSaldo += (cAliasTmp)->QUANT2
		    	
		    	If nSaldo >= 0
					T4H->T4H_QTD_PO := nSaldo
					T4H->T4H_QTD_NE := 0
				Else
					T4H->T4H_QTD_NE := nSaldo * -1
					T4H->T4H_QTD_PO := 0
				EndIf
				
				T4H->(MsUnlock())
				T4H->(dbSkip())
		    EndDo
		
		EndIf
		
		(cAliasTmp)->(dbSkip())
	
	EndDo
	
	(cAliasTmp)->(dbCloseArea())
	
	If TCIsView("VWSEL1")
		cQuery := " DROP VIEW VWSEL1 "
		MATExecQry(cQuery)
	EndIf 
	
EndIf //else sem postgres

ProcLogAtu('PCP K275',"PCP K275 - Gravar temporaria    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//******************************************
// Grava tabela tempor·ria para rodar o SPED
//******************************************
T4H->(dbSetOrder(2))
T4H->(dbSeek(cT4HFilial+STR(cMes,2)+STR(cAno,4)))
While T4H->(!Eof()) .And. T4H->T4H_FILIAL == cT4HFilial .And. T4H->T4H_MESSPE == STR(cMes,2) .And. T4H->T4H_ANOSPE == STR(cAno,4)
	If T4H->T4H_PRGORI == cChamada .And. (T4H->T4H_QTD_NE != 0 .Or. T4H->T4H_QTD_PO != 0)
		If T4H->T4H_CF != "ER0" .And. T4H->T4H_CF != "PR0" //nao mostrar acabado, ser· eliminado no K270
			Reclock(cAliK275,.T.)
			(cAliK275)->FILIAL     := cT4HFilial //chave
			(cAliK275)->REG        := "K275"
			(cAliK275)->COD_ITEM   := T4H->T4H_PRODUT
			(cAliK275)->QTD_COR_P  := T4H->T4H_QTD_PO
			(cAliK275)->QTD_COR_N  := T4H->T4H_QTD_NE
			(cAliK275)->COD_INS_SU := T4H->T4H_INS_SU
			(cAliK275)->COD_OP_OS  := T4H->T4H_OP //chave
			(cAliK275)->CHAVE      := "K270" + T4H->T4H_OP //chave
			(cAliK275)->(MsUnLock())
		EndIf
	EndIf
	If (T4H->T4H_QTD_NE == 0 .And. T4H->T4H_QTD_PO == 0)
		RecLock("T4H", .F.)
		T4H->(DBDelete())
		T4H->(MsUnLock())
	EndIf
	T4H->(dbSkip())
EndDo
MsUnlock()

ProcLogAtu('PCP K275',"PCP K275 - Fim de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

Return



/*------------------------------------------------------------------------//
//Programa:	  PROCK270
//Autor:	  Ricardo Peixoto 
//Data:		  05/10/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K270
//            CorreÁıes: K230, K260, K291, K292
//Parametros: 1 - cAliK270      - Alias do arquivo de trabalho do K270
//            2 - dDataDe		- Data Inicial da Apuracao   
//			  3 - dDataAte		- Data Final da Apuracao
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK270PRO(cAliK270,dDataDe,dDataAte,lRepross)

Local cQuery		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cT4HFilial    := ""
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local aProdNeg	    := {}
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local cPA           := ''
Local cChamada   := If (lRepross, "SPEDFISCAL", "MATR241   ")
Local cCharSoma  := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ")

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("T4G") + " WHERE T4G_MESSPE = '" + STR(cMes,2) + "' AND T4G_ANOSPE = '" + STR(cAno,4) + "' AND T4G_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

//Busca os dados para geraÁ„o do K270
cQuery := " SELECT " +;
			" SC2.C2_NUM, " +;
			" (SELECT MIN(D3_EMISSAO) FROM " + RetSqlName("SD3") + " WHERE D3_FILIAL = T4H_FILIAL AND D3_OP = T4H_OP AND D3_COD = T4H_PRODUT)     AS DTINI," +;
			" SC2.C2_datrf      AS DTFIM, " +;
			" T4H_OP, " +;
			" C2_PRODUTO, " +;
			" T4H_BLK_CO, " +;
		    " T4H_PRODUT, " +;
		    " T4H_QTD_PO, " +;
		    " T4H_QTD_NE, " +;
		    " T4H_BLK_CO " +;
			" from " + RetSqlName("T4H") + " T4H " +;
			       " JOIN " + RetSqlName("SC2") + " SC2 " 
				   //tratamento para a concatenÁ„o no postgres.		
					If TCGetDB() $ "POSTGRES"
						cQuery +=  " ON T4H_OP = TRIM(SC2.C2_NUM " + cCharSoma + " SC2.C2_ITEM " + cCharSoma + " SC2.C2_SEQUEN " + cCharSoma + " SC2.C2_ITEMGRD) " 			           					
					Else
						cQuery +=  " ON T4H_OP = SC2.C2_NUM " + cCharSoma + " SC2.C2_ITEM " + cCharSoma + " SC2.C2_SEQUEN " + cCharSoma + " SC2.C2_ITEMGRD " 			          				
					EndIf

					cQuery += " AND SC2.D_E_L_E_T_ <> '*' " +;
						" AND SC2.C2_PRODUTO = T4H.T4H_PRODUT " +;
						" AND SC2.C2_FILIAL = T4H.T4H_FILIAL " +;
			" WHERE T4H_FILIAL = '" + xFilial('T4H') + "' " +; 
            " AND T4H_MESSPE = '" + STR(cMes,2) + "' AND T4H_ANOSPE = '" + STR(cAno,4) + "' " +;
            " AND T4H_PRGORI = '" + cChamada + "' " +;
            " AND T4H.D_E_L_E_T_ <> '*' "


cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)


//Carrega as filiais uma ˙nica vez
cT4GFilial := xFilial("T4G")

While !(cAliasTmp)->(Eof())
	
	//********************************
	// Troca codigo do produto RE x PA
	//********************************
	cPA := (cAliasTmp)->C2_PRODUTO
	SVK->(dbSetOrder(1))
	SVK->(dbSeek(cT4GFilial+(cAliasTmp)->C2_PRODUTO ))
    While SVK->(!Eof()) .And. SVK->VK_FILIAL == cT4GFilial .And. SVK->VK_COD == (cAliasTmp)->C2_PRODUTO
    	cPA := SVK->VK_PRDORI
		SVK->(dbSkip())
    EndDo
	
	//grava tabela fÌsica para guardar histÛrico
	T4G->(dbSetOrder(2))
	If !T4G->(dbSeek(cT4GFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->T4H_OP+cPA+ cChamada ))
	
		//************************************************************************
		// Bloco K270
		//************************************************************************
		Reclock("T4G",.T.)
		T4G->T4G_PRGORI  := cChamada
		T4G->T4G_FILIAL  := cT4GFilial //chave
		T4G->T4G_MESSPE := STR(cMes,2)
		T4G->T4G_ANOSPE := STR(cAno,4)
		T4G->T4G_REG    := "K270"
		T4G->T4G_DT_INI := Dtos(FirstDate(Stod((cAliasTmp)->DTINI)))
		T4G->T4G_DT_FIN := Dtos(LastDate(Stod((cAliasTmp)->DTINI)))
		T4G->T4G_COD_OP := (cAliasTmp)->T4H_OP //chave
		T4G->T4G_COD_IT := cPA
		T4G->T4G_QTD_PO := (cAliasTmp)->T4H_QTD_PO
		T4G->T4G_QTD_NE := (cAliasTmp)->T4H_QTD_NE
		//controle interno - bloco corrigido
		Do Case
			Case (cAliasTmp)->T4H_BLK_CO == 'K235'
				T4G->T4G_ORIGEM := '1'
				T4G->T4G_BLK_CO := 'K230'
			Case (cAliasTmp)->T4H_BLK_CO == 'K255'
				T4G->T4G_ORIGEM := '2'
				T4G->T4G_BLK_CO := 'K250'
			Case (cAliasTmp)->T4H_BLK_CO == 'K215'
				T4G->T4G_ORIGEM := '3'
				T4G->T4G_BLK_CO := 'K210'
			Case (cAliasTmp)->T4H_BLK_CO == 'K265'
				T4G->T4G_ORIGEM := '4'
				T4G->T4G_BLK_CO := 'K260'
			Case (cAliasTmp)->T4H_BLK_CO == 'K220'
				T4G->T4G_ORIGEM := '5'
				T4G->T4G_BLK_CO := 'K220'
			Case (cAliasTmp)->T4H_BLK_CO == 'K291'
				T4G->T4G_ORIGEM := '6'
				T4G->T4G_BLK_CO := 'K291'
			Case (cAliasTmp)->T4H_BLK_CO == 'K292'
				T4G->T4G_ORIGEM := '7'
				T4G->T4G_BLK_CO := 'K292'
			Case (cAliasTmp)->T4H_BLK_CO == 'K301'
				T4G->T4G_ORIGEM := '8'
				T4G->T4G_BLK_CO := 'K301'
			Case (cAliasTmp)->T4H_BLK_CO == 'K302'
				T4G->T4G_ORIGEM := '9'
				T4G->T4G_BLK_CO := 'K302'
		EndCase
		T4G->(MsUnlock())
		
		//eliminar T4H do acabado
		cQuery := " DELETE FROM " + RetSqlName("T4H") + " WHERE T4H_MESSPE = '" + STR(cMes,2) + "' AND T4H_ANOSPE = '" + STR(cAno,4) + "' AND T4H_OP = '"+(cAliasTmp)->T4H_OP+"' AND T4H_PRODUT = '"+cPA+"' AND T4H_PRGORI = '" + cChamada + "' "
		MATExecQry(cQuery)

	EndIf
	
	(cAliasTmp)->(dbSkip())

EndDo

(cAliasTmp)->(dbCloseArea())


//Busca os dados para geraÁ„o do K270 quando tem somente REQ, sem PRO
cQuery := " SELECT " +;
			" SC2.C2_NUM, " +;
			" (SELECT MIN(D3_EMISSAO) FROM " + RetSqlName("SD3") + " WHERE D3_FILIAL = T4H_FILIAL AND D3_OP = T4H_OP AND D3_COD = T4H_PRODUT)     AS DTINI," +;
			" SC2.C2_datrf      AS DTFIM, " +;
			" T4H_OP, " +;
			" C2_PRODUTO, " +;
			" T4H_BLK_CO, " +;
		    " T4H_PRODUT, " +;
		    " T4H_QTD_PO, " +;
		    " T4H_QTD_NE, " +;
		    " T4H_BLK_CO " +;
			" from " + RetSqlName("T4H") + " T4H " +;
			       " JOIN " + RetSqlName("SC2") + " SC2 " 
				   //tratamento para a concatenÁ„o no postgres.		
					If TCGetDB() $ "POSTGRES"
						cQuery +=   " ON T4H_OP = TRIM(SC2.C2_NUM " + cCharSoma + " SC2.C2_ITEM " + cCharSoma + " SC2.C2_SEQUEN " + cCharSoma + " SC2.C2_ITEMGRD) "			           			           					
					Else
						cQuery +=   " ON T4H_OP = SC2.C2_NUM " + cCharSoma + " SC2.C2_ITEM " + cCharSoma + " SC2.C2_SEQUEN " + cCharSoma + " SC2.C2_ITEMGRD "			          			          				
					EndIf

					cQuery += " AND SC2.D_E_L_E_T_ <> '*' " +;
			            " AND SC2.C2_FILIAL = T4H.T4H_FILIAL " +;
			" WHERE T4H_FILIAL = '" + xFilial('T4H') + "' " +; 
            " AND T4H_MESSPE = '" + STR(cMes,2) + "' AND T4H_ANOSPE = '" + STR(cAno,4) + "' " +;
            " AND T4H_PRGORI = '" + cChamada + "' " +;
            " AND T4H.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	
	//********************************
	// Troca codigo do produto RE x PA
	//********************************
	cPA := (cAliasTmp)->C2_PRODUTO
	SVK->(dbSetOrder(1))
	SVK->(dbSeek(cT4GFilial+(cAliasTmp)->C2_PRODUTO))
    While SVK->(!Eof()) .And. SVK->VK_FILIAL == cT4GFilial .And. SVK->VK_COD == (cAliasTmp)->C2_PRODUTO
    	cPA := SVK->VK_PRDORI
		SVK->(dbSkip())
    EndDo
	
	//grava tabela fÌsica para guardar histÛrico
	T4G->(dbSetOrder(2))
	If !T4G->(dbSeek(cT4GFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->T4H_OP+cPA+ cChamada ))
	
		//************************************************************************
		// Bloco K270
		//************************************************************************
		Reclock("T4G",.T.)
		T4G->T4G_PRGORI  := cChamada
		T4G->T4G_FILIAL  := cT4GFilial //chave
		T4G->T4G_MESSPE := STR(cMes,2)
		T4G->T4G_ANOSPE := STR(cAno,4)
		T4G->T4G_REG    := "K270"
		T4G->T4G_DT_INI := Dtos(FirstDate(Stod((cAliasTmp)->DTINI)))
		T4G->T4G_DT_FIN := Dtos(LastDate(Stod((cAliasTmp)->DTINI)))
		T4G->T4G_COD_OP := (cAliasTmp)->T4H_OP //chave
		T4G->T4G_COD_IT := cPA
		T4G->T4G_QTD_PO := 0
		T4G->T4G_QTD_NE := 0
		//controle interno - bloco corrigido
		Do Case
			Case (cAliasTmp)->T4H_BLK_CO == 'K235'
				T4G->T4G_ORIGEM := '1'
				T4G->T4G_BLK_CO := 'K230'
			Case (cAliasTmp)->T4H_BLK_CO == 'K255'
				T4G->T4G_ORIGEM := '2'
				T4G->T4G_BLK_CO := 'K250'
			Case (cAliasTmp)->T4H_BLK_CO == 'K215'
				T4G->T4G_ORIGEM := '3'
				T4G->T4G_BLK_CO := 'K210'
			Case (cAliasTmp)->T4H_BLK_CO == 'K265'
				T4G->T4G_ORIGEM := '4'
				T4G->T4G_BLK_CO := 'K260'
			Case (cAliasTmp)->T4H_BLK_CO == 'K220'
				T4G->T4G_ORIGEM := '5'
				T4G->T4G_BLK_CO := 'K220'
			Case (cAliasTmp)->T4H_BLK_CO == 'K291'
				T4G->T4G_ORIGEM := '6'
				T4G->T4G_BLK_CO := 'K291'
			Case (cAliasTmp)->T4H_BLK_CO == 'K292'
				T4G->T4G_ORIGEM := '7'
				T4G->T4G_BLK_CO := 'K292'
			Case (cAliasTmp)->T4H_BLK_CO == 'K301'
				T4G->T4G_ORIGEM := '8'
				T4G->T4G_BLK_CO := 'K301'
			Case (cAliasTmp)->T4H_BLK_CO == 'K302'
				T4G->T4G_ORIGEM := '9'
				T4G->T4G_BLK_CO := 'K302'
		EndCase
		T4G->(MsUnlock())
		
	EndIf
	(cAliasTmp)->(dbSkip())

EndDo
(cAliasTmp)->(dbCloseArea())

//eliminar T4H do acabado
cQuery := " DELETE FROM " + RetSqlName("T4H") + " WHERE T4H_MESSPE = '" + STR(cMes,2) + "' AND T4H_ANOSPE = '" + STR(cAno,4) + "' AND T4H_CF = 'ER0' AND T4H_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

//Iniciando calculo para 291 e 292
cQuery := " SELECT SC2.C2_datpri     AS DTINI, " +; 
				  " SC2.C2_datrf      AS DTFIM, " +; 
				  " CASE " +; 
			        "   WHEN SD3.D3_ESTORNO = 'S'  AND SD3.D3_CF LIKE ( 'ER%' ) THEN 'K291' " +; 
					"	WHEN SD3.D3_ESTORNO = 'S'  AND SD3.D3_CF LIKE ( 'RE%' ) THEN 'K291' " +; 
					"	WHEN SD3.D3_ESTORNO <> 'S' AND SD3.D3_CF LIKE ( 'PR%' ) THEN 'K291' " +; 
					"	WHEN SD3.D3_ESTORNO <> 'S' AND SD3.D3_CF LIKE ( 'DE%' ) THEN 'K291' " +; 
					"	ELSE 'K292' " +; 
			      " END AS BLOCO, " +; 
				  " SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT) " +; 
                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT*-1) " +;
                          " WHEN SD3.D3_CF LIKE ('ER%') THEN (SD3.D3_QUANT*-1) " +;
                          " WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) " +; 
                          " ELSE 0 END) AS QUANT, " +;
                 " SD3.D3_COD, "+; 
                 " SD3.D3_OP, " +; 
                 " MAX(D3_EMISSAO) AS D3_EMISSAO, " +; 
                 " SD3.D3_FILIAL, " +;
                 " SD3.D3_PERBLK, " +;
                 " SD3.R_E_C_N_O_ AS SD3RECNO, SD3.D3_CF, D3_ESTORNO " +; 
            " FROM " + RetSqlName("SD3") + " SD3 " +;
            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
             " AND SB1.B1_COD     = SD3.D3_COD " +; 
             " AND SB1.D_E_L_E_T_ <> '*' "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
	                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
	                " AND SBZ.D_E_L_E_T_ <> '*' "
EndIf

cQuery += "JOIN " + RetSqlName("SC2") + " SC2 "
			//tratamento para a concatenÁ„o no postgres.		
			If TCGetDB() $ "POSTGRES"
				cQuery +=   " ON SD3.D3_OP      = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) "			           			           					
			Else
				cQuery +=   " ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "			          			          				
			EndIf

			cQuery += " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
          " AND SC2.D_E_L_E_T_ <> '*' " +; 
          " AND SC2.C2_ITEM   <> 'OS' " +; 
          " AND SC2.C2_TPPR   IN ('I',' ') " +; 
         " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
           " ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
          " AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
          " AND SB1_OP.D_E_L_E_T_ <> '*' "
          
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
	                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	               " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
	               " AND SBZ_OP.D_E_L_E_T_ <> '*' " 
EndIF

// validaÁ„o de empenho negativo
cQuery += " JOIN " + RetSqlName("SD4") + " SD4 " +; 
          " ON SD4.D4_FILIAL  = '" + xFilial('SD4') + "' " +; 
          " AND SD4.D4_OP     = SD3.D3_OP " +; 
          " AND SD4.D4_QTDEORI < 0 " +;
          " AND SD4.D_E_L_E_T_ <> '*' "

cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
            " AND SD3.D_E_L_E_T_ <> '*' " +; 
            " AND SD3.D3_OP     <> ' ' " +; 
            " AND (SD3.D3_CF  LIKE ('RE%') " +; 
            "  OR  SD3.D3_CF  LIKE ('ER%') " +; 
            "  OR  SD3.D3_CF  LIKE ('DE%') " +;
            "  OR  SD3.D3_CF  LIKE ('PR%')) " +;
            " AND SB1.B1_CCCUSTO = ' ' " +; 
            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
            " AND (SD3.D3_EMISSAO < '" + DtoS(dDataDe) + "'  AND (SD3.D3_PERBLK = '" + PADR(Nil,tamSX3('D3_PERBLK')[1]) + "' OR SD3.D3_PERBLK = '" + STR(cMes,2)+STR(cAno,4) + "  ')) " +; 
            " AND SD3.D_E_L_E_T_ <> '*' " 
            
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += " AND SB1.B1_TIPO "
EndIf

cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQuery += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
          
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
Else
	cQuery += " AND SB1_OP.B1_TIPO "
EndIf

cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_CF, D3_ESTORNO, C2_datpri, C2_datrf "          

cQuery += "ORDER BY 4,3,2"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

//Carrega as filiais uma ˙nica vez
cSVWFilial := xFilial("SVV")

While !(cAliasTmp)->(Eof())

	//grava tabela fÌsica para guardar histÛrico
	T4G->(dbSetOrder(2))
	If !T4G->(dbSeek(cSVWFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
	
		//************************************************************************
		// Bloco K270
		//************************************************************************
		Reclock("T4G",.T.)
		T4G->T4G_PRGORI  := cChamada
		T4G->T4G_FILIAL  := cT4GFilial //chave
		T4G->T4G_MESSPE := STR(cMes,2)
		T4G->T4G_ANOSPE := STR(cAno,4)
		T4G->T4G_REG    := 'K270'
		T4G->T4G_DT_INI := Dtos(FirstDate(Stod((cAliasTmp)->DTINI)))
		T4G->T4G_DT_FIN := Dtos(LastDate(Stod((cAliasTmp)->DTINI)))
		T4G->T4G_COD_OP := (cAliasTmp)->D3_OP //chave
		T4G->T4G_COD_IT := (cAliasTmp)->D3_COD
		If (cAliasTmp)->QUANT >= 0
			T4G->T4G_QTD_PO := (cAliasTmp)->QUANT
		Else
			T4G->T4G_QTD_NE := (cAliasTmp)->QUANT * -1
		EndIf
		T4G->T4G_BLK_CO := (cAliasTmp)->BLOCO
		If T4G->T4G_BLK_CO == 'K291'
			T4G->T4G_ORIGEM := '6'
		Else
			T4G->T4G_ORIGEM := '7'
		EndIf
		T4G->(MsUnlock())
		
	Else
	
		//************************************************************************
		// Bloco K270 - ajuste de quantidades em multiplos apontamentos
		//************************************************************************
		T4G->(dbSetOrder(2))
		T4G->(dbSeek(cSVWFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
	    While T4G->(!Eof()) .And. T4G->T4G_FILIAL == cT4GFilial .And. T4G->T4G_MESSPE == STR(cMes,2) .And. T4G->T4G_ANOSPE == STR(cAno,4) .And. T4G->T4G_COD_OP == (cAliasTmp)->D3_OP .And. T4G->T4G_COD_IT == (cAliasTmp)->D3_COD .And. T4G->T4G_PRGORI == cChamada 
	    	RecLock("T4G",.F.,.T.)
	    	
	    	nSaldo := T4G->T4G_QTD_PO - T4G->T4G_QTD_NE
	    	nSaldo += (cAliasTmp)->QUANT
	    	
	    	If nSaldo >= 0
				T4G->T4G_QTD_PO := nSaldo
				T4G->T4G_QTD_NE := 0
			Else
				T4G->T4G_QTD_NE := nSaldo * -1
				T4G->T4G_QTD_PO := 0
			EndIf
			T4G->(MsUnlock())
			T4G->(dbSkip())
	    EndDo
	
	EndIf
	
	SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(dbCloseArea())

//******************************************
// Grava tabela tempor·ria para rodar o SPED
//******************************************
T4G->(dbSetOrder(2))
T4G->(dbSeek(cT4GFilial+STR(cMes,2)+STR(cAno,4)))
While T4G->(!Eof()) .And. T4G->T4G_FILIAL == cT4GFilial .And. T4G->T4G_MESSPE == STR(cMes,2) .And. T4G->T4G_ANOSPE == STR(cAno,4)
	If T4G->T4G_PRGORI == cChamada
		Reclock(cAliK270,.T.)
		(cAliK270)->FILIAL     := T4G->T4G_FILIAL //chave
		(cAliK270)->REG        := T4G->T4G_REG
		(cAliK270)->COD_ITEM   := T4G->T4G_COD_IT
		(cAliK270)->DT_INI_AP  := Stod(T4G->T4G_DT_INI)
		(cAliK270)->DT_FIN_AP  := Stod(T4G->T4G_DT_FIN)
		(cAliK270)->QTD_COR_P  := T4G->T4G_QTD_PO
		(cAliK270)->QTD_COR_N  := T4G->T4G_QTD_NE
		(cAliK270)->ORIGEM     := T4G->T4G_ORIGEM
		(cAliK270)->COD_OP_OS  := T4G->T4G_COD_OP //chave
		(cAliK270)->CHAVE      := "K270" + T4G->T4G_COD_OP //chave
		(cAliK270)->(MsUnLock())
	EndIf
	T4G->(dbSkip())
EndDo
MsUnlock()



//*****************************************
//Iniciando marcaÁ„o nos estornos n„o lidos
//*****************************************
cQuery := " SELECT SD3.R_E_C_N_O_ AS SD3RECNO, SD3.D3_PERBLK " +; 
		  " FROM "+RetSqlName("SD3") + " SD3 " +;
		  " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
            " AND SD3.D_E_L_E_T_ <> '*' " +; 
		    " AND (SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "') " +;
		    " AND SD3.D3_ESTORNO = 'S' " +; 
		    " AND SD3.D3_PERBLK = '" + PADR(Nil,tamSX3('D3_PERBLK')[1]) + "'

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())	
	SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(dbCloseArea())

Return



/*------------------------------------------------------------------------//
//Programa:	  REGK265 
//Autor:	  Ricardo Peixoto 
//Data:		  19/10/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K265
//Parametros: 1 - cAliK265      - Alias do arquivo de trabalho do K265
//            2 - dDataDe		- Data Inicial da Apuracao   
//			  3 - dDataAte		- Data Final da Apuracao
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK265(cAliK265,dDataDe,dDataAte,lRepross,l300)

Local cQuery		:= ""
Local cUpdateD3		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cSD4Filial	:= ""
Local cT4FFilial    := ""
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local aProdNeg	    := {}
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local cPA           := ''
Local cChamada   	:= If (lRepross, "SPEDFISCAL", "MATR241   ")
Local cCharSoma     := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ") //n„o usar ChangeQuery para update e create

Default l300 := .F.

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If l300
	cChamada := "MATC300   "
EndIf

ProcLogAtu('PCP K265',"PCP K265 - Inicio de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("T4F") + " WHERE T4F_MESAPU = '" + STR(cMes,2) + "' AND T4F_ANOAPU = '" + STR(cAno,4) + "' AND T4F_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)
cQuery := " DELETE FROM " + RetSqlName("T4E") + " WHERE T4E_MESAPU = '" + STR(cMes,2) + "' AND T4E_ANOAPU = '" + STR(cAno,4) + "' AND T4E_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

ProcLogAtu('PCP K265',"PCP K265 - Limpa view    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

If TCGetDB() $ "ORACLE/DB2/400/INFORMIX"

	//Busca os dados para geraÁ„o do K265
	cQuery := " SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) " +;
	                          " WHEN SD3.D3_CF LIKE ('ER%') THEN (SD3.D3_QUANT*-1) " +; 
	                          " ELSE 0 END) AS QUANT, " +;
	                 " SD3.D3_COD, "+; 
	                 " SD3.D3_OP, " +; 
	                 " MAX(D3_EMISSAO) AS D3_EMISSAO, " +; 
	                 " SD3.D3_FILIAL, " +;
	                 " SD3.D3_PERBLK, " +;
	                 " SD3.R_E_C_N_O_ AS SD3RECNO, SD3.D3_estorno, SC2.C2_PRODUTO, SD3.D3_CF " +; 
	            " FROM " + RetSqlName("SD3") + " SD3 " +;
	            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
	              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	             " AND SB1.B1_COD     = SD3.D3_COD " +; 
	             " AND SB1.D_E_L_E_T_ <> '*' "
	
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
		                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
		                " AND SBZ.D_E_L_E_T_ <> '*' "
	EndIf
	
	cQuery += "JOIN " + RetSqlName("SC2") + " SC2 "+;
				" ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "+;
				" AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
	        	" AND SC2.D_E_L_E_T_ <> '*' " +; 
	        	" AND SC2.C2_ITEM   <> 'OS' " +; 
	        	" AND SC2.C2_TPPR   IN ('R') " +; 
	        	" JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
	        	" ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	        	" AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
	        	" AND SB1_OP.D_E_L_E_T_ <> '*' "
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
		                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		               " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
		               " AND SBZ_OP.D_E_L_E_T_ <> '*' " 
	EndIF
	
	cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' " +; 
	            " AND SD3.D3_OP     <> ' ' " +; 
	            " AND (SD3.D3_CF  LIKE ('RE%') OR SD3.D3_CF  LIKE ('DE%') OR SD3.D3_CF  LIKE ('ER%') ) " +;
	            " AND SB1.B1_CCCUSTO = ' ' " +; 
	            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
	            " AND D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' " 
	            
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += " AND SB1.B1_TIPO "
	EndIf
	
	cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cQuery += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
	          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
	Else
		cQuery += " AND SB1_OP.B1_TIPO "
	EndIf
	
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
	cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_ESTORNO, SC2.C2_PRODUTO, SD3.D3_CF "   
	cQuery += "ORDER BY 4,3,2"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	//Carrega as filiais uma ˙nica vez
	cSD4Filial := xFilial("SD4")
	cT4FFilial := xFilial("T4F")
	
	While !(cAliasTmp)->(Eof())
	
		If lRepross
			SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
		EndIf	
	
		If (cAliasTmp)->D3_ESTORNO != 'S'
		
			//grava tabela fÌsica para guardar histÛrico
			T4F->(dbSetOrder(1))
			If !T4F->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		
				SVK->(dbSetOrder(2))
				If !SVK->(dbSeek(cT4FFilial+(cAliasTmp)->C2_PRODUTO+(cAliasTmp)->D3_COD+ cChamada )) .AND. !SVK->(dbSeek(cT4FFilial+(cAliasTmp)->D3_COD+(cAliasTmp)->C2_PRODUTO+ cChamada ))
				
					//************************************************************************
					// Bloco K265
					//************************************************************************
					Reclock("T4F",.T.)
					T4F->T4F_PRGORI  := cChamada
					T4F->T4F_FILIAL  := cT4FFilial
					T4F->T4F_MESAPU  := STR(cMes,2)
					T4F->T4F_ANOAPU  := STR(cAno,4)
					T4F->T4F_REG     := "K265"
					T4F->T4F_PRODUT  := (cAliasTmp)->D3_COD
					If (cAliasTmp)->QUANT > 0
						T4F->T4F_QTDCON  := (cAliasTmp)->QUANT
						T4F->T4F_QTDRET  := 0
					Else
						T4F->T4F_QTDRET  := (cAliasTmp)->QUANT * -1
						T4F->T4F_QTDCON  := 0
					EndIf
					T4F->T4F_OP      := (cAliasTmp)->D3_OP
					T4F->(MsUnlock())
					(cAliasTmp)->(dbSkip())
					
				Else
				
					cPA := (cAliasTmp)->D3_COD
					SVK->(dbSetOrder(1))
					SVK->(dbSeek(cT4FFilial+(cAliasTmp)->D3_COD))
				    While SVK->(!Eof()) .And. SVK->VK_FILIAL == cT4FFilial .And. SVK->VK_COD == (cAliasTmp)->D3_COD
				    	cPA := SVK->VK_PRDORI
						SVK->(dbSkip())
				    EndDo
				
					//********************************************************************************************
					//Grava tabela fÌsica para guardar histÛrico no K260 para quantidade de saÌda do retrabalhado
					//********************************************************************************************
					T4E->(dbSetOrder(1))
					If !T4E->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+cPA+ cChamada ))
				
						//************************************************************************
						// Bloco K260
						//************************************************************************
						Reclock("T4E",.T.)
						T4E->T4E_PRGORI  := cChamada
						T4E->T4E_FILIAL  := cT4FFilial
						T4E->T4E_MESAPU  := STR(cMes,2)
						T4E->T4E_ANOAPU  := STR(cAno,4)
						T4E->T4E_REG     := "K260"
						T4E->T4E_OP      := (cAliasTmp)->D3_OP
						T4E->T4E_PRODUT  := cPA
						T4E->T4E_QTSAID  := (cAliasTmp)->QUANT
						T4E->T4E_QTRET   := 0
						T4E->(MsUnlock())
							
						(cAliasTmp)->(dbSkip())
					Else
						//************************************************************************
						// Bloco K260 - ajuste de quantidades em multiplos apontamentos
						//************************************************************************	
						T4E->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+cPA+ cChamada ))
					    While T4E->(!Eof()) .And. T4E->T4E_FILIAL == cT4FFilial .And. T4E->T4E_MESAPU == STR(cMes,2) .And. T4E->T4E_ANOAPU == STR(cAno,4) .And. T4E->T4E_OP == (cAliasTmp)->D3_OP .And. T4E->T4E_PRODUT == cPA .And. T4E->T4E_PRGORI == cChamada
					    	RecLock("T4E",.F.,.T.)		    	
					    	T4E->T4E_QTSAID  += (cAliasTmp)->QUANT
					    	T4E->T4E_QTRET   := 0
					    	T4E->(MsUnlock())
							T4E->(dbSkip())
					    EndDo
						(cAliasTmp)->(dbSkip())
					EndIf
					//********************************************************************************************
					//grava tabela fÌsica para guardar histÛrico no K260 para quantidade de saÌda do retrabalhado
					//********************************************************************************************
				
					
				EndIf
			Else
				//************************************************************************
				// Bloco K265 - ajuste de quantidades em multiplos apontamentos
				//************************************************************************	
				T4F->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
			    While T4F->(!Eof()) .And. T4F->T4F_FILIAL == cT4FFilial .And. T4F->T4F_MESAPU == STR(cMes,2) .And. T4F->T4F_ANOAPU == STR(cAno,4) .And. T4F->T4F_OP == (cAliasTmp)->D3_OP .And. T4F->T4F_PRODUT == (cAliasTmp)->D3_COD .And. T4F->T4F_PRGORI == cChamada
			    	RecLock("T4F",.F.,.T.)
			    	
			    	If (cAliasTmp)->QUANT > 0
						T4F->T4F_QTDCON  += (cAliasTmp)->QUANT
					Else
						T4F->T4F_QTDRET  += (cAliasTmp)->QUANT * -1
					EndIf
			    	
			    	T4F->(MsUnlock())
					T4F->(dbSkip())
			    EndDo
				(cAliasTmp)->(dbSkip())
			EndIf
				
				
		Else
			(cAliasTmp)->(dbSkip())
		EndIf
			
		
	EndDo

Else

	If TCIsView("VWSEL1")
		cQuery := " DROP VIEW VWSEL1 "
		MATExecQry(cQuery)
	EndIf
	
	//Busca os dados para geraÁ„o do K265
	cQuery := " CREATE VIEW VWSEL1 AS "
	cQuery += " SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) " +;
	                          " WHEN SD3.D3_CF LIKE ('ER%') THEN (SD3.D3_QUANT*-1) " +; 
	                          " ELSE 0 END) AS QUANT, " +;
	                 " SD3.D3_COD, "+; 
	                 " SD3.D3_OP, " +; 
	                 " MAX(D3_EMISSAO) AS D3_EMISSAO, " +; 
	                 " SD3.D3_FILIAL, " +;
	                 " SD3.D3_PERBLK, " +;
	                 " SD3.R_E_C_N_O_ AS SD3RECNO, SD3.D3_ESTORNO, SC2.C2_PRODUTO, SD3.D3_CF "
	cUpdateD3 := " FROM " + RetSqlName("SD3") + " SD3 " +;
	            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
	              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	             " AND SB1.B1_COD     = SD3.D3_COD " +; 
	             " AND SB1.D_E_L_E_T_ <> '*' "
	
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
		                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
		                " AND SBZ.D_E_L_E_T_ <> '*' "
	EndIf
	
	cUpdateD3 += "JOIN " + RetSqlName("SC2") + " SC2 "
			//tratamento para a concatenÁ„o no postgres.		
			If TCGetDB() $ "POSTGRES"
				cUpdateD3 +=   " ON SD3.D3_OP      = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) "			           			           					
			Else
				cUpdateD3 +=   " ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "			          			          				
			EndIf

			cUpdateD3 += " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
	        	" AND SC2.D_E_L_E_T_ <> '*' " +; 
	        	" AND SC2.C2_ITEM   <> 'OS' " +; 
	        	" AND SC2.C2_TPPR   IN ('R') " +; 
	        	" JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
	    		" ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	        	" AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
	        	" AND SB1_OP.D_E_L_E_T_ <> '*' "
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
		                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		               " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
		               " AND SBZ_OP.D_E_L_E_T_ <> '*' " 
	EndIF
	
	cUpdateD3 += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' " +; 
	            " AND SD3.D3_OP     <> ' ' " +; 
	            " AND (SD3.D3_CF  LIKE ('RE%') OR SD3.D3_CF  LIKE ('DE%') OR SD3.D3_CF  LIKE ('ER%') ) " +;
	            " AND SB1.B1_CCCUSTO = ' ' " +; 
	            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
	            " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
	            " AND SD3.D_E_L_E_T_ <> '*' " +;
	            " AND SD3.D3_ESTORNO <> 'S' "
	            
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cUpdateD3 += " AND SB1.B1_TIPO "
	EndIf
	
	cUpdateD3 += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cUpdateD3 += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
	          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
	Else
		cUpdateD3 += " AND SB1_OP.B1_TIPO "
	EndIf
	
	cUpdateD3 += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cQuery += cUpdateD3 //compartilha where para update e select
	cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
	cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_ESTORNO, SC2.C2_PRODUTO, SD3.D3_CF "   
	
	//executa update para marcar d3_perblk
	cUpdateD3 := " UPDATE " + RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2) + STR(cAno,4) + "' " + cUpdateD3
	MATExecQry(cUpdateD3)
	
	ProcLogAtu('PCP K265',"PCP K265 - Registros marcados    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//cria view para leitura
	MATExecQry(cQuery)
	
	ProcLogAtu('PCP K265',"PCP K265 - Montagem query 2    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//varre view para otimizar calculo de quantidades
	cQuery := "	SELECT " +;
				" Sum(CASE WHEN D3_CF LIKE ( 'RE%' ) THEN ( QUANT ) ELSE 0 END) AS QUANTPOS, " +;
				" Sum(CASE WHEN D3_CF LIKE ( 'DE%' ) THEN ( QUANT *- 1 ) ELSE 0 END) AS QUANTNEG, " +;
				" SUM(QUANT) AS QUANT, " +;
				" D3_COD, " +;
				" D3_OP, " +;
				" MIN(D3_EMISSAO) AS D3_EMISSAO, " +;
				" MIN(D3_FILIAL) AS D3_FILIAL, " +;
				" MIN(C2_PRODUTO) AS C2_PRODUTO " +;
				" FROM VWSEL1 " +;
				" GROUP BY D3_OP, " +;
						 " D3_COD "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	ProcLogAtu('PCP K265',"PCP K265 - Busca concluÌda    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	
	//Carrega as filiais uma ˙nica vez
	cSD4Filial := xFilial("SD4")
	cT4FFilial := xFilial("T4F")
	
	ProcLogAtu('PCP K265',"PCP K265 - Leitura de movimentos    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	While !(cAliasTmp)->(Eof())
	
		//grava tabela fÌsica para guardar histÛrico
		T4F->(dbSetOrder(1))
		If !T4F->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
	
			SVK->(dbSetOrder(2))
			If !SVK->(dbSeek(cT4FFilial+(cAliasTmp)->C2_PRODUTO+(cAliasTmp)->D3_COD)) .AND. !SVK->(dbSeek(cT4FFilial+(cAliasTmp)->D3_COD+(cAliasTmp)->C2_PRODUTO))
			
				//************************************************************************
				// Bloco K265
				//************************************************************************
				Reclock("T4F",.T.)
				T4F->T4F_PRGORI  := cChamada
				T4F->T4F_FILIAL  := cT4FFilial
				T4F->T4F_MESAPU  := STR(cMes,2)
				T4F->T4F_ANOAPU  := STR(cAno,4)
				T4F->T4F_REG     := "K265"
				T4F->T4F_PRODUT  := (cAliasTmp)->D3_COD
				T4F->T4F_QTDCON  := (cAliasTmp)->QUANTPOS
				T4F->T4F_QTDRET  := (cAliasTmp)->QUANTNEG
				T4F->T4F_OP      := (cAliasTmp)->D3_OP
				T4F->(MsUnlock())
				(cAliasTmp)->(dbSkip())
				
			Else
			
				cPA := (cAliasTmp)->D3_COD
				SVK->(dbSetOrder(1))
				SVK->(dbSeek(cT4FFilial+(cAliasTmp)->D3_COD))
			    While SVK->(!Eof()) .And. SVK->VK_FILIAL == cT4FFilial .And. SVK->VK_COD == (cAliasTmp)->D3_COD
			    	cPA := SVK->VK_PRDORI
					SVK->(dbSkip())
			    EndDo
			
				//********************************************************************************************
				//Grava tabela fÌsica para guardar histÛrico no K260 para quantidade de saÌda do retrabalhado
				//********************************************************************************************
				T4E->(dbSetOrder(1))
				If !T4E->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+cPA+ cChamada ))
			
					//************************************************************************
					// Bloco K260
					//************************************************************************
					Reclock("T4E",.T.)
					T4E->T4E_PRGORI  := cChamada
					T4E->T4E_FILIAL  := cT4FFilial
					T4E->T4E_MESAPU  := STR(cMes,2)
					T4E->T4E_ANOAPU  := STR(cAno,4)
					T4E->T4E_REG     := "K260"
					T4E->T4E_OP      := (cAliasTmp)->D3_OP
					T4E->T4E_PRODUT  := cPA
					T4E->T4E_QTSAID  := (cAliasTmp)->QUANT
					T4E->T4E_QTRET   := 0
					T4E->(MsUnlock())
						
					(cAliasTmp)->(dbSkip())
				Else
					//************************************************************************
					// Bloco K260 - ajuste de quantidades em multiplos apontamentos
					//************************************************************************	
					T4E->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+cPA+ cChamada ))
				    While T4E->(!Eof()) .And. T4E->T4E_FILIAL == cT4FFilial .And. T4E->T4E_MESAPU == STR(cMes,2) .And. T4E->T4E_ANOAPU == STR(cAno,4) .And. T4E->T4E_OP == (cAliasTmp)->D3_OP .And. T4E->T4E_PRODUT == cPA .And. T4E->T4E_PRGORI == cChamada
				    	RecLock("T4E",.F.,.T.)		    	
				    	T4E->T4E_QTSAID  += (cAliasTmp)->QUANT
				    	T4E->T4E_QTRET   := 0
				    	T4E->(MsUnlock())
						T4E->(dbSkip())
				    EndDo
					(cAliasTmp)->(dbSkip())
				EndIf
				//********************************************************************************************
				//grava tabela fÌsica para guardar histÛrico no K260 para quantidade de saÌda do retrabalhado
				//********************************************************************************************
			
				
			EndIf
		Else
			//************************************************************************
			// Bloco K265 - ajuste de quantidades em multiplos apontamentos
			//************************************************************************	
			T4F->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		    While T4F->(!Eof()) .And. T4F->T4F_FILIAL == cT4FFilial .And. T4F->T4F_MESAPU == STR(cMes,2) .And. T4F->T4F_ANOAPU == STR(cAno,4) .And. T4F->T4F_OP == (cAliasTmp)->D3_OP .And. T4F->T4F_PRODUT == (cAliasTmp)->D3_COD .And. T4F->T4F_PRGORI == cChamada
		    	RecLock("T4F",.F.,.T.)
		    	T4F->T4F_QTDCON  := (cAliasTmp)->QUANTPOS
				T4F->T4F_QTDRET  := (cAliasTmp)->QUANTNEG
		    	T4F->(MsUnlock())
				T4F->(dbSkip())
		    EndDo
			(cAliasTmp)->(dbSkip())
		EndIf
				
			
		
	EndDo
	
EndIf

(cAliasTmp)->(dbCloseArea())

ProcLogAtu('PCP K265',"PCP K265 - CriaÁ„o de tempor·ria    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//******************************************
// Grava tabela tempor·ria para rodar o SPED
//******************************************
T4F->(dbSetOrder(1))
T4F->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)))
While T4F->(!Eof()) .And. T4F->T4F_FILIAL == cT4FFilial .And. T4F->T4F_MESAPU == STR(cMes,2) .And. T4F->T4F_ANOAPU == STR(cAno,4)
	If T4F->T4F_PRGORI == cChamada
		Reclock(cAliK265,.T.)
		(cAliK265)->FILIAL     := T4F->T4F_FILIAL
		(cAliK265)->REG        := T4F->T4F_REG
		(cAliK265)->COD_ITEM   := T4F->T4F_PRODUT
		(cAliK265)->QTD_CONS   := T4F->T4F_QTDCON
		(cAliK265)->QTD_RET    := T4F->T4F_QTDRET
		(cAliK265)->COD_OP_OS  := T4F->T4F_OP
		(cAliK265)->(MsUnLock())
	EndIf
	T4F->(dbSkip())
EndDo
MsUnlock()

ProcLogAtu('PCP K265',"PCP K265 - Fim de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

Return

/*------------------------------------------------------------------------//
//Programa:	  REGK260 
//Autor:	  Ricardo Peixoto 
//Data:		  19/10/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K260
//Parametros: 1 - cAliK265      - Alias do arquivo de trabalho do K260
//            2 - dDataDe		- Data Inicial da Apuracao   
//			  3 - dDataAte		- Data Final da Apuracao
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK260(cAliK260,dDataDe,dDataAte,lRepross)

Local cQuery		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cSD4Filial	:= ""
Local cT4EFilial    := ""
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local aProdNeg	    := {}
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local cPA           := ''
Local cChamada   := If (lRepross, "SPEDFISCAL", "MATR241   ")
Local cCharSoma  := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ")

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

//Limpeza da tabela feita na funÁ„o K265

//Busca os dados para geraÁ„o do K260
cQuery := " SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) " +; 
                          " ELSE 0 END) AS QUANT, " +;
                 " SD3.D3_COD, "+; 
                 " SD3.D3_OP, " +; 
                 " MAX(D3_EMISSAO) AS D3_EMISSAO, " +; 
                 " SD3.D3_FILIAL, " +;
                 " SD3.D3_PERBLK, " +;
                 " SD3.R_E_C_N_O_ AS SD3RECNO, SD3.D3_ESTORNO, SC2.C2_PRODUTO, SD3.D3_CF, " +; 
                 " SC2.C2_DATPRI AS DTINI, " +; 
          		 " SC2.C2_DATRF AS DTFIM " +; 
            " FROM " + RetSqlName("SD3") + " SD3 " +;
            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
             " AND SB1.B1_COD     = SD3.D3_COD " +; 
             " AND SB1.D_E_L_E_T_ <> '*' "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
	                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
	                " AND SBZ.D_E_L_E_T_ <> '*' "
EndIf

cQuery += "JOIN " + RetSqlName("SC2") + " SC2 "
			//tratamento para a concatenÁ„o no postgres.		
			If TCGetDB() $ "POSTGRES"
				cQuery +=   " ON SD3.D3_OP      = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) "			           			           					
			Else
				cQuery +=   " ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "			          			          				
			EndIf

			cQuery += " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
        	" AND SC2.D_E_L_E_T_ <> '*' " +; 
        	" AND SC2.C2_ITEM   <> 'OS' " +; 
        	" AND SC2.C2_TPPR   IN ('R') " +; 
        	" JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
			" ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
			" AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
			" AND SB1_OP.D_E_L_E_T_ <> '*' "
          
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
					" ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
					" AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
					" AND SBZ_OP.D_E_L_E_T_ <> '*' " 
EndIF

cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
            " AND SD3.D_E_L_E_T_ <> '*' " +; 
            " AND SD3.D3_OP     <> ' ' " +; 
            " AND (SD3.D3_CF  LIKE ('PR%') ) " +;
            " AND SB1.B1_CCCUSTO = ' ' " +; 
            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
            " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
            " AND SD3.D_E_L_E_T_ <> '*' "  +;
            " AND SD3.D3_ESTORNO <> 'S' "
            
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += " AND SB1.B1_TIPO "
EndIf

cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
cQuery += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
          
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
Else
	cQuery += " AND SB1_OP.B1_TIPO "
EndIf

cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_ESTORNO, SC2.C2_PRODUTO, SD3.D3_CF, SC2.C2_DATPRI, SC2.C2_DATRF "   
cQuery += "ORDER BY 4,3,2"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

//Carrega as filiais uma ˙nica vez
cSD4Filial := xFilial("SD4")
cT4EFilial := xFilial("T4E")

While !(cAliasTmp)->(Eof())

	SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)

	cPA := (cAliasTmp)->D3_COD
	SVK->(dbSetOrder(1))
	SVK->(dbSeek(cT4EFilial+(cAliasTmp)->D3_COD))
    While SVK->(!Eof()) .And. SVK->VK_FILIAL == cT4EFilial .And. SVK->VK_COD == (cAliasTmp)->D3_COD
    	cPA := SVK->VK_PRDORI
		SVK->(dbSkip())
    EndDo

	//grava tabela fÌsica para guardar histÛrico
	T4E->(dbSetOrder(1))
	If !T4E->(dbSeek(cT4EFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+cPA+ cChamada ))

		//************************************************************************
		// Bloco K260
		//************************************************************************
		Reclock("T4E",.T.)
		T4E->T4E_PRGORI  := cChamada
		T4E->T4E_FILIAL  := cT4EFilial
		T4E->T4E_MESAPU  := STR(cMes,2)
		T4E->T4E_ANOAPU  := STR(cAno,4)
		T4E->T4E_REG     := "K260"
		T4E->T4E_OP      := (cAliasTmp)->D3_OP
		T4E->T4E_PRODUT  := cPA
		T4E->T4E_DTSAID  := Stod((cAliasTmp)->DTINI)
		T4E->T4E_QTSAID  := 0
		T4E->T4E_DTRET   := If(StoD((cAliasTmp)->DTFIM) > dDataAte,StoD(""),StoD((cAliasTmp)->DTFIM))
		T4E->T4E_QTRET   := (cAliasTmp)->QUANT
		T4E->T4E_SEMRET  := "S" //Indicador de OP sem produto retrabalho - validador
		T4E->(MsUnlock())
			
	Else
		//************************************************************************
		// Bloco K260 - ajuste de quantidades em multiplos apontamentos
		//************************************************************************	
		T4E->(dbSeek(cT4EFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+cPA+ cChamada ))
	    While T4E->(!Eof()) .And. T4E->T4E_FILIAL == cT4EFilial .And. T4E->T4E_MESAPU == STR(cMes,2) .And. T4E->T4E_ANOAPU == STR(cAno,4) .And. T4E->T4E_OP == (cAliasTmp)->D3_OP .And. T4E->T4E_PRODUT == cPA .And. T4E->T4E_PRGORI == cChamada
	    	RecLock("T4E",.F.,.T.)		    	
	    	T4E->T4E_QTRET   += (cAliasTmp)->QUANT
			T4E->T4E_DTSAID  := Stod((cAliasTmp)->DTINI)
			T4E->T4E_DTRET   := If(StoD((cAliasTmp)->DTFIM) > dDataAte,StoD(""),StoD((cAliasTmp)->DTFIM))
			T4E->(MsUnlock())
			T4E->(dbSkip())
	    EndDo
	EndIf
		
	(cAliasTmp)->(dbSkip())
	
EndDo

(cAliasTmp)->(dbCloseArea())

//******************************************
// Grava tabela tempor·ria para rodar o SPED
//******************************************
T4E->(dbSetOrder(1))
T4E->(dbSeek(cT4EFilial+STR(cMes,2)+STR(cAno,4)))
While T4E->(!Eof()) .And. T4E->T4E_FILIAL == cT4EFilial .And. T4E->T4E_MESAPU == STR(cMes,2) .And. T4E->T4E_ANOAPU == STR(cAno,4)
	If T4E->T4E_PRGORI == cChamada
		Reclock(cAliK260,.T.)
		(cAliK260)->FILIAL     := T4E->T4E_FILIAL
		(cAliK260)->REG        := T4E->T4E_REG
		(cAliK260)->COD_ITEM   := T4E->T4E_PRODUT
		(cAliK260)->COD_OP_OS  := T4E->T4E_OP	
		(cAliK260)->DT_SAIDA   := T4E->T4E_DTSAID
		(cAliK260)->QTD_SAIDA  := T4E->T4E_QTSAID
		(cAliK260)->DT_RET     := T4E->T4E_DTRET
		(cAliK260)->QTD_RET    := T4E->T4E_QTRET	
		(cAliK260)->(MsUnLock())
	EndIf
	T4E->(dbSkip())
EndDo
MsUnlock()


Return



/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ REGK235V12     ≥ Autor ≥ Materiais        ≥ Data ≥ 28/07/14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Funcao responsavel pela gravacao do Registro K235           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cAliasTRB   = Alias do arquivo de trabalho do Bloco         ≥±±
±±≥          ≥ dDataDe     = Data Inicial da Apuracao                      ≥±±
±±≥          ≥ dDataAte    = Data Final da Apuracao                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function REGK235V12(cAliK235,dDataDe,dDataAte,cAliK270,cAliK275)

Local cQuery	:= ""
Local cAliasTmp	:= GetNextAlias()
Local cSD4Filial:= ""
Local cDadosProd:= SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local aProdNeg	:= {}
Local cCharSoma  := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ")

cQuery := "SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) "
cQuery += "WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) ELSE 0 END) QUANT, "
cQuery += "SD3.D3_COD, SD3.D3_OP, MAX(D3_EMISSAO) D3_EMISSAO, SD3.D3_FILIAL FROM "+RetSqlName("SD3")+" SD3 "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIF
//tratamento para a concatenÁ„o no postgres.		
If TCGetDB() $ "POSTGRES"
	cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) AND "	           			           					
Else
	cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD AND "		          			          				
EndIf

cQuery += "SC2.C2_FILIAL = '"+xFilial('SC2')+"' AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_ITEM <> 'OS' AND SC2.C2_TPPR IN ('I',' ') "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1_OP ON SB1_OP.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1_OP.B1_COD = SC2.C2_PRODUTO AND SB1_OP.D_E_L_E_T_ = ' ' "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ_OP ON SBZ_OP.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ_OP.BZ_COD = SB1.B1_COD AND SBZ_OP.D_E_L_E_T_ = ' ' " 
EndIF
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' AND SD3.D_E_L_E_T_ = ' ' AND "
cQuery += "SD3.D3_ESTORNO = ' ' AND SD3.D3_OP <> ' ' AND "
cQuery += "(SD3.D3_CF LIKE ('RE%') OR SD3.D3_CF LIKE ('DE%')) AND SB1.B1_CCCUSTO = ' ' AND "
cQuery += "SB1.B1_COD NOT LIKE 'MOD%' AND D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND "
cQuery += "'"+DtoS(dDataAte)+"' AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_CF <> 'DE1' AND "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += "SB1.B1_TIPO "
EndIf
cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") AND "
cQuery += "SB1_OP.B1_CCCUSTO = ' ' AND SB1_OP.B1_COD NOT LIKE 'MOD%' AND "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
Else
	cQuery += "SB1_OP.B1_TIPO "
EndIf
cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL "
cQuery += "Having (Sum(CASE WHEN SD3.D3_CF LIKE ( 'DE%' ) THEN ( SD3.D3_QUANT * -1 ) "
cQuery += "WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) ELSE 0 END)) <> 0 "
cQuery += "ORDER BY 4,3,2"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

If lEstMov
	dbSelectArea("SD4")
	dbSetOrder(2) // D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
EndIf

cSD4Filial := xFilial("SD4")
While !(cAliasTmp)->(Eof())
	If (cAliasTmp)->QUANT >= 0
		Reclock(cAliK235,.T.)
		(cAliK235)->FILIAL          := (cAliasTmp)->D3_FILIAL
		(cAliK235)->REG             := "K235"
		(cAliK235)->DT_SAIDA        := StoD((cAliasTmp)->D3_EMISSAO)
		(cAliK235)->COD_ITEM        := (cAliasTmp)->D3_COD
		(cAliK235)->QTD             := (cAliasTmp)->QUANT
		(cAliK235)->COD_DOC_OP      := (cAliasTmp)->D3_OP
		(cAliK235)->COD_INS_SU      := GetSubst((cAliasTmp)->D3_COD,(cAliasTmp)->D3_OP,dDataDe,dDataAte)
		If lEstMov
			If SD4->(MsSeek(cSD4Filial+(cAliK235)->(COD_DOC_OP+COD_ITEM)))
				(cAliK235)->EMPENHO := "S"
			EndIf
		EndIf
		(cAliK235)->(MsUnLock())
		nRegsto++
		(cAliasTmp)->(dbSkip())
	Else
		AADD(aProdNeg,{(cAliasTmp)->D3_FILIAL,"K235",StoD((cAliasTmp)->D3_EMISSAO),(cAliasTmp)->D3_COD,(cAliasTmp)->QUANT,;
			(cAliasTmp)->D3_OP,GetSubst((cAliasTmp)->D3_COD,(cAliasTmp)->D3_OP,dDataDe,dDataAte)}) 
		(cAliasTmp)->(dbSkip())
	EndIf
EndDo

If Len(aProdNeg) > 0
	REGK27X(cAliK270,cAliK275,dDataDe,dDataAte,aProdNeg,aProdNeg[1][2])
EndIf	

(cAliasTmp)->(dbCloseArea())

Return


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ REGK230V12     ≥ Autor ≥ Materiais        ≥ Data ≥ 28/07/14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Funcao responsavel pela gravacao do Registro K230           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cAliasTRB   = Alias do arquivo de trabalho do Bloco         ≥±±
±±≥          ≥ cAliK235    = Alias do arquivo de trabalho do K235          ≥±±
±±≥          ≥ cAli0210    = Alias do arquivo de trabalho do 0210          ≥±±
±±≥          ≥ dDataDe     = Data Inicial da Apuracao                      ≥±±
±±≥          ≥ dDataAte    = Data Final da Apuracao                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function REGK230V12(cAliK230,cAliK235,cAli0210,dDataDe,dDataAte,lRepross)

Local cQuery	:= ""
Local cFilSC2	:= xFilial("SC2")
Local cAliasTmp	:= GetNextAlias()
Local cDadosProd:= SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cCharSoma  := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ")

cQuery := "SELECT SUM(SD3.D3_QUANT) QUANT, SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO), " 
Else
	cQuery += "SB1.B1_TIPO, "
EndIf
cQuery += "SC2.C2_DATPRI DTINI, SC2.C2_DATRF DTFIM, SC2.C2_QUANT QTDORI FROM "+RetSqlName("SD3")+" SD3 "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
//tratamento para a concatenÁ„o no postgres.		
If TCGetDB() $ "POSTGRES"
	cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) AND "	           			           					
Else
	cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD AND "		          			          				
EndIf
cQuery += "SC2.C2_FILIAL = '"+xFilial('SC2')+"' AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_ITEM <> 'OS' AND "
cQuery += "SC2.C2_PRODUTO = SD3.D3_COD AND SC2.C2_TPPR IN ('I',' ') "
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO = ' ' AND "
cQuery += "SD3.D3_OP <> ' ' AND SD3.D3_CF IN ('PR0','PR1') AND SD3.D3_COD NOT LIKE 'MOD%' AND "
cQuery += "SD3.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' AND "
cQuery += "SB1.B1_CCCUSTO = ' ' AND " 
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) " 
Else
	cQuery += "SB1.B1_TIPO "
EndIf
cQuery += " IN ("+cTipo03+","+cTipo04+") AND SD3.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO), " 
Else
	cQuery += "SB1.B1_TIPO, "
EndIf
cQuery += "SC2.C2_DATPRI, SC2.C2_DATRF, SC2.C2_QUANT "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	Reclock(cAliK230,.T.)
	(cAliK230)->FILIAL			:= (cAliasTmp)->D3_FILIAL
	(cAliK230)->REG				:= "K230"
	(cAliK230)->DT_INI_OP		:= GetIniProd((cAliasTmp)->D3_OP)
	(cAliK230)->DT_FIN_OP		:= If(StoD((cAliasTmp)->DTFIM) > dDataAte,StoD(""),StoD((cAliasTmp)->DTFIM))
	(cAliK230)->COD_DOC_OP		:= (cAliasTmp)->D3_OP
	(cAliK230)->COD_ITEM		:= (cAliasTmp)->D3_COD
	(cAliK230)->QTD_ENC			:= (cAliasTmp)->QUANT
	(cAliK230)->QTDORI			:= (cAliasTmp)->QTDORI
	(cAliK230)->(MsUnLock())
	nRegsto++
	(cAliasTmp)->(dbSkip())
EndDo

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Inicia a Gravacao das Producoes Zeradas, nas situacoes    ≥
//≥ em que houveram apenas Requisicoes no Periodo de Apuracao ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

dbselectArea(cAliK230)
dbSetOrder(1)
dbSelectArea("SC2")
dbSetOrder(1)
(cAliK235)->(dbGoTop())

While !(cAliK235)->(Eof())
	If !(cAliK230)->(DBSeek((cAliK235)->FILIAL+(cAliK235)->COD_DOC_OP))
		If (SC2->(MsSeek(cFilSC2+(cAliK235)->COD_DOC_OP)))
			Reclock(cAliK230,.T.)
			(cAliK230)->FILIAL			:= (cAliK235)->FILIAL
			(cAliK230)->REG				:= "K230"
			(cAliK230)->DT_INI_OP		:= GetIniProd((cAliK235)->COD_DOC_OP)
			(cAliK230)->DT_FIN_OP		:= If(SC2->C2_DATRF > dDataAte,StoD(""),SC2->C2_DATRF)
			(cAliK230)->COD_DOC_OP		:= (cAliK235)->COD_DOC_OP
			(cAliK230)->COD_ITEM		:= SC2->C2_PRODUTO
			(cAliK230)->QTD_ENC			:= 0
			(cAliK230)->QTDORI			:= SC2->C2_QUANT
			(cAliK230)->(MsUnLock())
			nRegsto++
		EndIf
	EndIf
	(cAliK235)->(dbSkip())
EndDo

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Gravacao do Registro 0210 com base nas producoes do Registro K230        ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If !lEstMov
	(cAliK230)->(dbGoTop())
	While !(cAliK230)->(Eof())
		REG0210(cAli0210,(cAliK230)->COD_ITEM,dDataDe,dDataAte,(cAliK230)->COD_DOC_OP,.T.,lRePross)
		(cAliK230)->(dbSkip())
	EndDo
EndIf

(cAliasTmp)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTabTmp
Cria tabelas tempor·rias do bloco parametrizado.
    
@author Renan Roeder
@since  Nov 13, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------

Function PCPTabTemp(cBloco)
Local cAliasTRB := ""
Local nX := 0
Local aStrReg := {}
//Local cVerBlk := VerBlocoK(dDataDe)
Local aLayout := {}

aLayout := SPDLayout(cBloco)

cAliasTRB := UPPER(cBloco)+"_"+CriaTrab(,.F.)

// aStrReg
//      [1] := Alias da tabela temporaria a ser criada
//      [2] := Nome da tabela temporaria criada via dbcreate no driver sqlite
//      [3,n] := Conjunto de nome de indices da tabela quando a tabela È cria 
//      [4] := Objeto criado via FWTemporaryTable
//
aStrReg := {cAliasTRB ,NIL ,{} ,NIL}

aStrReg[4] := FWTemporaryTable():New( aStrReg[1] ) 
aStrReg[4]:SetFields( aClone(aLayout[1]) )
For nX := 1 to len(aLayout[2])
    aStrReg[4]:AddIndex(StrZero(nX,2), aClone(aLayout[2,nX]) )
Next nX
aStrReg[4]:Create()

Return cAliasTRB

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ REGK26X        ≥ Autor ≥ Materiais        ≥ Data ≥ 11/08/16 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Funcao responsavel pela gravacao dos Registros K260 e K265  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cAliK260    = Alias do arquivo de trabalho do K260          ≥±±
±±≥          ≥ cAliK265    = Alias do arquivo de trabalho do K265          ≥±±
±±≥          ≥ dDataDe     = Data Inicial da Apuracao                      ≥±±
±±≥          ≥ dDataAte    = Data Final da Apuracao                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function REGK26X(cAliK260,cAliK265,dDataDe,dDataAte)

If Existblock("REGK26X")
	Execblock("REGK26X",.F.,.F.,{cAliK260,cAliK265,dDataDe,dDataAte})
EndIf

Return

/*/{Protheus.doc} VldBlkTp
	FunÁao para validar o conte˙do dos par‚metros MV_BLKTP.
	N„o È permitido informar nos par‚metros MV_BLKTP o mesmo valor padr„o definido.
	Por exemplo:
	MV_BLKTP02 o default È tipo 'EM'
    MV_BLKTP05 se informar 'SP','EM' barrar o processamento do bloco K
	Pois, o tipo 'EM' est· redundante.
	@type  Function
	@author ana.paula
	@since 22/07/2022
	/*/
Function VldBlkTp(aTipos)

Local aValidacao := {}
Local lRet       := .T.
Local nExist     := 0
Local nTipo      := 0
Local cTipos := ''
Default aTipos     := {}

If Empty(aTipos)
    cTipos := ''
    cTipos += If(SuperGetMv("MV_BLKTP00",.F.,"'ME'")== " ","'ME'", SuperGetMv("MV_BLKTP00",.F.,"'ME'")) + ','// 00: Mercadoria Revenda
    cTipos += If(SuperGetMv("MV_BLKTP01",.F.,"'MP'")== " ","'MP'", SuperGetMv("MV_BLKTP01",.F.,"'MP'")) + ',' // 01: Materia-Prima
    cTipos += If(SuperGetMv("MV_BLKTP02",.F.,"'EM'")== " ","'EM'", SuperGetMv("MV_BLKTP02",.F.,"'EM'")) + ',' // 02: Embalagem
    cTipos += If(SuperGetMv("MV_BLKTP03",.F.,"'PP'")== " ","'PP'", SuperGetMv("MV_BLKTP03",.F.,"'PP'")) + ',' // 03: Produto em Processo
    cTipos += If(SuperGetMv("MV_BLKTP04",.F.,"'PA'")== " ","'PA'", SuperGetMv("MV_BLKTP04",.F.,"'PA'")) + ',' // 04: Produto Acabado
    cTipos += If(SuperGetMv("MV_BLKTP05",.F.,"'SP'")== " ","'SP'", SuperGetMv("MV_BLKTP05",.F.,"'SP'")) + ',' // 05: SubProduto
    cTipos += If(SuperGetMv("MV_BLKTP06",.F.,"'PI'")== " ","'PI'", SuperGetMv("MV_BLKTP06",.F.,"'PI'")) + ',' // 06: Produto Intermediario
    cTipos += If(SuperGetMv("MV_BLKTP10",.F.,"'OI'")== " ","'OI'", SuperGetMv("MV_BLKTP10",.F.,"'OI'"))  // 10: Outros Insumos
   
   aTipos := STRTOKARR( cTipos, ',')
EndIf

For nTipo := 1 to len(aTipos)
	nExist := aScan(aValidacao,{|x|x==aTipos[nTipo]})
	If nExist <= 0
		Aadd(aValidacao, aTipos[nTipo])
	else
		lRet := .F.
		exit
	EndIf
Next nTipo
	
Return lRet
