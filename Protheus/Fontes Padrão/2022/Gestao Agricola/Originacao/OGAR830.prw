#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "OGAR830.ch"
#include "report.ch"

Static oFnt14C  := TFont():New("Arial", 14, 14, , .T., , , , .T., .F., .F.)
Static oFnt18C  := TFont():New("Arial", 18, 18, , .T., , , , .T., .F., .F.)

/*/{Protheus.doc} OGAR830
Comparativo Recebimento x Faturamento
@author tamyris.ganzenmueller
@since 03/12/2018
@version 1.0

@type function
/*/

Static __lQuebUnNeg := .F.
Static __lQuebProd := .F.
Static __nTipMerc as numeric  
Static __nPosicao   
Static __nTipUnMed
Static __nDatRef  
Static __cPerIni   := ""
Static __cPerFim   := ""
Static __cFilIni   := ""
Static __cFilFim   := "ZZZZZZZZZ"
Static __cUnMeProd := ""
Static __cUnMedQtd := ""
Static __cUnMedPla := ""
Static __cCodPro   := ""

Function OGAR830()

	Local oReport := Nil
	
	Pergunte("OGAR830", .T.)	

	
	oReport := ReportDef()
	oReport:PrintDialog()
	
	
Return

/*/{Protheus.doc} ReportDef
//TODO Descrição auto-gerada.
@author tamyris.ganzenmueller
@since 20/09/2018
@version 1.0

@type Static function
/*/
Static Function ReportDef()

	Local oReport := Nil
	Local cTitle := STR0002 + "(" + __cPerIni + "-" + __cPerFim + ")"
	
	If ValType(MV_PAR15) = 'N'
		__lQuebUnNeg := MV_PAR15 == 1
		__lQuebProd := MV_PAR16 == 1
		__nTipMerc   := MV_PAR11  
		__nPosicao   := MV_PAR12  
		__nTipUnMed  := MV_PAR13  
		__nDatRef    := MV_PAR17
	Else
		__lQuebUnNeg := MV_PAR15 == '1'
		__lQuebProd := MV_PAR16 == '1'
		__nTipMerc   := Val(MV_PAR11)  
		__nPosicao   := Val(MV_PAR12)  
		__nTipUnMed  := Val(MV_PAR13)
		__nDatRef    := Val(MV_PAR17)
	EndIF
	
	__cPerIni := AllTrim(StrZero (Month(MV_PAR05),2)) + "/" +  AllTrim(Str(Year(MV_PAR05)))  
	__cPerFim := AllTrim(StrZero (Month(MV_PAR06),2)) + "/" +  AllTrim(Str(Year(MV_PAR06)))
	
	cFilBkp := cFilAnt
	cFilAnt := MV_PAR01
	__cFilIni := FWCodEmp() + FWUnitBusiness() 
	cFilAnt := cFilBkp
	__cFilFim := MV_PAR02

	oReport := TReport():New("OGAR830", cTitle, , {|oReport| PrintReport(oReport)}, STR0002) //"Comparativo de Volumes e Valores"
	oReport:SetPortrait(.T.) // Define a orientação default
	oReport:cFontBody := 'Courier New'
	oReport:HideParamPage()
	oReport:HideFooter() 
	oReport:SetTotalInLine(.F.)
	oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	oReport:nFontBody := 08 // Tamanho da fonte
	oReport:nDevice := 6 // Tipo de impressão 6-PDF
	oReport:SetLandScape()
		
	oSection1 := TRSection():New( oReport, "Cabeçalho", )
	oSection2 := TRSection():New( oReport, "Dados", )
			
	TRCell():New( oSection1, "CABEC_MESANO" , , "" , PesqPict('N8W', 'N8W_MESANO')	, TamSX3("N8W_MESANO")[1]+8)	
	TRCell():New( oSection1, "CABEC_VOLREC" , , STR0003 , "@!" , 22) //Volume de Vendas 
	TRCell():New( oSection1, "CABEC_VOLRE2" , , ""      , "@!" , 1)	 //Para ajuste da impressão em Excel
	TRCell():New( oSection1, "CABEC_VOLFAT" , , STR0003 , "@!" , 16) //Volume de Vendas
	TRCell():New( oSection1, "CABEC_VOLFA2" , , ""      , "@!" , 1)	 //Para ajuste da impressão em Excel
	TRCell():New( oSection1, "CABEC_OBSERV" , , STR0011 , "@!" , 22) //"Posição"
	
	TRCell():New( oSection2, "N8W_MESANO" ,  , ""  , PesqPict('N8W', 'N8W_MESANO')	, TamSX3("N8W_MESANO")[1]+2)	
	TRCell():New( oSection2, "N8W_VOLREC" ,  , "" , "999,999,999,999.99" , 15)
	TRCell():New( oSection2, "N8W_PERREC" ,  , "" , "999.99" , 6)
	TRCell():New( oSection2, "N8W_VOLFAT" ,  , "" , "999,999,999,999.99" , 15)
	TRCell():New( oSection2, "N8W_PERFAT" ,  , "" , "999.99" , 6)
	TRCell():New( oSection2, "N8W_OBSERV" ,  , "" , "@!" , 20)
	
	oBreak1 := TRBreak():New( oSection2, "", STR0004 , .f. ) //Total	
	TRFunction():New(oSection2:Cell("N8W_VOLREC") , Nil, "SUM" , oBreak1, , , , .f., .f. )
	TRFunction():New(oSection2:Cell("N8W_PERREC") , Nil, "SUM" , oBreak1, , , , .f., .f. )
	TRFunction():New(oSection2:Cell("N8W_VOLFAT") , Nil, "SUM" , oBreak1, , , , .f., .f. )
	TRFunction():New(oSection2:Cell("N8W_PERFAT") , Nil, "SUM" , oBreak1, , , , .f., .f. )
	
	//Total Geral
	oSum1 := TRFunction():New(oSection2:Cell("N8W_VOLREC") , Nil, "SUM" , , , , , .f., .f. )
	oSum1:SetEndReport(.T.)
	oSum5 := TRFunction():New(oSection2:Cell("N8W_VOLFAT") , Nil, "SUM" , , , , , .f., .f. )
	oSum5:SetEndReport(.T.)
		
Return oReport

/*/{Protheus.doc} PrintReport
Imprime o conteudo do relatório
@author tamyris.ganzenmueller
@since 20/09/2018
@version undefined
@param oReport, object, objeto do relatório
@type function
/*/
Static Function PrintReport(oReport)
	Local cNomeEmp    := ""
	Local cNmFil      := ""
	Local cAliasQry   := GetNextAlias()
	Local nN8WSLDVEN := 0
	Local nN8WQTDVEN := 0
	Local nN8WSLDREC := 0
	Local nN8WQTDREC := 0
	Local cChaveAtu   := ""
	Local cChave   := ""
	Local cCodProd := ""
	Local cGrpProd := ""
	Local cFilN8W  := ""
	Local cSafra   := ""
	
	oReport:SetCustomText( {|| AGRARCabec(oReport, @cNomeEmp, @cNmFil) } ) // Cabeçalho customizado
	
	If oReport:nDevice <> 4 //Planilha
		oReport:Say(200, 1200,   STR0002, oFnt18C) //Título
	Else
		oReport:PrintText(STR0002, 200, 1000,, )  //Produto
	EndIf
		
	cQuery := " SELECT N8Y_UM1PRO, N8W_SAFRA, N8W_FILIAL, N8W_CODPRO, N8W_GRPROD, "
	cQuery += " N8W_SLDVEN, N8W_QTDVEN, N8W_SLDREC, N8W_QTDREC  FROM " + RetSqlName("N8Y") + " N8Y "
	cQuery += " INNER JOIN " + RetSqlName("N8W") + " N8W ON N8W.D_E_L_E_T_ = '' " 
	cQuery += " AND N8W.N8W_FILIAL = N8Y.N8Y_FILIAL AND N8W.N8W_CODPLA = N8Y.N8Y_CODPLA "
	cQuery += " WHERE N8Y.D_E_L_E_T_ = '' " 
	IF __nDatRef == 1 //Mais atual
		cQuery += "AND N8Y_ATIVO = '1' "
	Else //Data Informada
		cQuery += "AND N8Y_CODPLA IN ( SELECT MAX(N8YB.N8Y_CODPLA) FROM " +  RetSqlName("N8Y") + " N8YB "
		cQuery += " WHERE N8YB.N8Y_FILIAL = N8Y.N8Y_FILIAL "
		cQuery += " AND N8YB.N8Y_SAFRA  = N8Y.N8Y_SAFRA  "
		cQuery += " AND N8YB.N8Y_GRPROD = N8Y.N8Y_GRPROD "
		cQuery += " AND N8YB.N8Y_CODPRO = N8Y.N8Y_CODPRO "
		cQuery += " AND N8YB.N8Y_DTATUA <= '" + DtoS(MV_PAR18) + "'"
		cQuery += " AND N8YB.D_E_L_E_T_ = ' '"
		cQuery += " )"
	EndIF
	cQuery += " AND N8Y.N8Y_FILIAL >= '" + __cFilIni + "'"
	cQuery += " AND N8Y.N8Y_FILIAL <= '" + __cFilFim + "'"
	cQuery += " AND N8Y.N8Y_SAFRA  >= '" + MV_PAR03 + "'"
	cQuery += " AND N8Y.N8Y_SAFRA  <= '" + MV_PAR04 + "'"
	cQuery += " AND N8Y.N8Y_CODPRO >= '" + MV_PAR07 + "'"
	cQuery += " AND N8Y.N8Y_CODPRO <= '" + MV_PAR08 + "'"
	cQuery += " AND N8Y.N8Y_GRPROD >= '" + MV_PAR09 + "'"
	cQuery += " AND N8Y.N8Y_GRPROD <= '" + MV_PAR10 + "'"
	cQuery += " AND N8W.N8W_MESANO >= '" + __cPerIni + "'"
	cQuery += " AND N8W.N8W_MESANO <= '" + __cPerFim + "'"
	cQuery += " AND N8W.D_E_L_E_T_ = '' "
	
	IF __nTipMerc <> 3
		cQuery += " AND N8W.N8W_TIPMER = '" + AllTrim(Str(__nTipMerc)) + "'"
	EndIf
	
	cQuery += " ORDER BY N8W_SAFRA "
		
	IF __lQuebProd //Quebra por Produto
		cQuery += " , N8W_CODPRO, N8W_GRPROD "
	EndIF
	
	IF __lQuebUnNeg //Quebra por Unid Negocio
		cQuery += " , N8W_FILIAL "
	EndIF
	cQuery	:=	ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!EOF())
	
		cChaveAtu := (cAliasQry)->N8W_SAFRA
		IF __lQuebProd //Quebra por Produto
			cChaveAtu += (cAliasQry)->N8W_GRPROD+(cAliasQry)->N8W_CODPRO
		EndIF
		IF __lQuebUnNeg
			cChaveAtu += (cAliasQry)->N8W_FILIAL 
		EndIF
		
		If (!empty(cChave) .And. cChave <> cChaveAtu) .Or. Empty(cChave)
			
			If (!empty(cChave) .And. cChave <> cChaveAtu) //Só imprime se for ultimo registro da quebra
				printPlan(oReport, cCodProd, cGrpProd, cFilN8W, cSafra, nN8WSLDVEN, nN8WQTDVEN, nN8WSLDREC, nN8WQTDREC )
			EndIf
			
			nN8WSLDVEN := 0  
			nN8WQTDVEN := 0  
			nN8WSLDREC := 0  
			nN8WQTDREC := 0  
			
			cChave := cChaveAtu
			cSafra := (cAliasQry)->N8W_SAFRA
			
			IF __lQuebUnNeg //Quebra por Unid Negocio
				cFilN8W := (cAliasQry)->N8W_FILIAL 
			EndIF
			IF __lQuebProd //Quebra por Produto
				cCodProd := (cAliasQry)->N8W_CODPRO
				cGrpProd := (cAliasQry)->N8W_GRPROD
			EndIF
			
			__cCodPro   := (cAliasQry)->N8W_CODPRO
			__cUnMeProd := Posicione("SB1",1,xFilial("SB1")+(cAliasQry)->N8W_CODPRO,'B1_UM')
			__cUnMedPla := (cAliasQry)->N8Y_UM1PRO
					
			//SE NÃO TEM CODIGO DE PRODUTO INFORMADO E TEM O GRUPO DO PRODUTO INFORMADO NO ITEM DO PLANO
			If Empty((cAliasQry)->N8W_CODPRO) .AND. !Empty((cAliasQry)->N8W_GRPROD)
				dbSelectArea("SB1")
				SB1->(dbSetOrder(4)) //B1_FILIAL+B1_GRUPO+B1_COD
				If SB1->(dbSeek( FWxFilial("SB1") + (cAliasQry)->N8W_GRPROD  )) 
					__cCodPro := SB1->B1_COD //pega o primeiro codigo de produto do grupo de produto
					If  Empty(__cUnMeProd)	
						//SE UNIDADE DE MEDIDA ESTA EM BRANCO NO ITEM DO PLANO
						__cUnMeProd := SB1->B1_UM
					EndIf
				EndIf
			EndIf
			
			__cUnMedQtd := AllTrim(IIF(__nTipUnMed == 1, __cUnMeProd , MV_PAR14 ) )
			If Empty(__cUnMedQtd)
				__cUnMedQtd := __cUnMedPla
			EndIF
		
		EndIF
		
		__cUnMedPla := (cAliasQry)->N8Y_UM1PRO
		__cCodPro   := (cAliasQry)->N8W_CODPRO
				
		nN8WSLDVEN += ConvUnMed((cAliasQry)->N8W_SLDVEN ,1,__cCodPro) 
		nN8WQTDVEN += ConvUnMed((cAliasQry)->N8W_QTDVEN ,1,__cCodPro)  
		nN8WSLDREC += ConvUnMed((cAliasQry)->N8W_SLDREC ,1,__cCodPro)  
		nN8WQTDREC += ConvUnMed((cAliasQry)->N8W_QTDREC ,1,__cCodPro)  
		
		(cAliasQry)->(dbSkip())
	EndDo
	
	If !empty(cSafra)
		printPlan(oReport, cCodProd, cGrpProd, cFilN8W, cSafra, nN8WSLDVEN, nN8WQTDVEN, nN8WSLDREC, nN8WQTDREC )
	EndIF
	
Return 

Static Function printPlan(oReport, cCodPro, cGrProd, cFilN8W, cSafra, nPrev, nVend, nPrRec, nVendRec)
	Local cAliasQry2 := GetNextAlias()
	Local cTxProd := ""
	Local oS1		:= oReport:Section( 1 )
	Local oS2		:= oReport:Section( 2 )
	Local cChave    := ""
	
	Private nN8WQTDVEN := 0, nN8WVLTDE2 := 0 , nN8WVLTODE := 0
	Private nN8WQTDREC := 0, nN8WVLRTD2 := 0 , nN8WVLRTDE := 0
	Private nN8WSLDVEN := 0, nN8WVTPDE2 := 0 , nN8WVLTPDE := 0
	Private nN8WSLDREC := 0, nN8WVPRTD2 := 0 , nN8WVPRTD1 := 0
		
	If __lQuebProd //Quebra por produto
		If !Empty(cCodPro)
			cTxProd := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodPro,'B1_DESC')) + " - "
		Else
			cTxProd := AllTrim(Posicione("SBM", 1, FwxFilial("SBM")+cGrProd, "BM_DESC")) + " - "
		EndIf
	EndIf
	
	If !Empty(cSafra)
		cTxProd += + STR0006 + " " +  AllTrim(cSafra) //Safra
	EndIf
	
	If !Empty(cFilN8W)
		cTxProd += " - " + STR0008 + " " + cFilN8W //Unid. Negoc
	EndIf
	
	cTxtSubTit := Padr(STR0009,30) +  Padr("X",30) + STR0010 //Recebimento ## Faturamento
	
	oReport:SkipLine(3)
	nLin := oReport:Row()
	    	
	If oReport:nDevice <> 4 //Planilha
		
		oReport:Say(nLin, 1000, cTxProd , oFnt14C)  //Produto
		oReport:SkipLine(3)
		
		nLin := oReport:Row()
		oReport:Say(nLin, 250, cTxtSubTit , oFnt14C) 
		oReport:SkipLine(3)
		
		oS1:Init()
		oS1:Cell("CABEC_MESANO"):SetValue("")
		oS1:Cell("CABEC_VOLREC"):SetValue(__cUnMedQtd + Space(11) +  "(%)" )
		oS1:Cell("CABEC_VOLFAT"):SetValue(__cUnMedQtd + Space(7) +  "(%)" )
	Else
		oReport:PrintText(cTxProd, nLin, 1000,, )  //Produto
		oReport:SkipLine(3)
		
		nLin := oReport:Row()
		oReport:PrintText(cTxtSubTit, nLin, 900,, )  //Produto 
		oReport:SkipLine(3)
		
		oS1:Init()
		oS1:Cell("CABEC_MESANO"):SetValue("")
		oS1:Cell("CABEC_VOLREC"):SetValue(__cUnMedQtd)
		oS1:Cell("CABEC_VOLRE2"):SetValue("(%)" )
		oS1:Cell("CABEC_VOLFAT"):SetValue(__cUnMedQtd)
		oS1:Cell("CABEC_VOLFA2"):SetValue("(%)")
		
	EndIF

	oS1:PrintLine( )
	oS1:Finish()
	
	oS2:Init()
	
	cQuery2 := " SELECT  N8W_MESANO, N8Y_UM1PRO, " 
	
	/*Faturamento - Vendido*/
	cQuery2 += "  N8W_QTDVEN,  "
	
	/*Recebimento - Vendido */
	cQuery2 += "  N8W_QTDREC, "

	/*Faturamento - A Vender */
	cQuery2 += "  N8W_SLDVEN, "
	
	/*Financeiro - A Vender*/
	cQuery2 += "  N8W_SLDREC"

	cQuery2 += " FROM " + RetSqlName("N8Y") + " N8Y "
	cQuery2 += " INNER JOIN " + RetSqlName("N8W") + " N8W ON N8W.D_E_L_E_T_ = '' " 
	cQuery2 += " AND N8W.N8W_FILIAL = N8Y.N8Y_FILIAL AND N8W.N8W_CODPLA = N8Y.N8Y_CODPLA "
	cQuery2 += " WHERE N8Y.D_E_L_E_T_ = '' " 
	IF __nDatRef == 1 //Mais atual
		cQuery2 += "AND N8Y_ATIVO = '1' "
	Else //Data Informada
		cQuery2 += "AND N8Y_CODPLA IN ( SELECT MAX(N8YB.N8Y_CODPLA) FROM " +  RetSqlName("N8Y") + " N8YB "
		cQuery2 += " WHERE N8YB.N8Y_FILIAL = N8Y.N8Y_FILIAL "
		cQuery2 += " AND N8YB.N8Y_SAFRA  = N8Y.N8Y_SAFRA  "
		cQuery2 += " AND N8YB.N8Y_GRPROD = N8Y.N8Y_GRPROD "
		cQuery2 += " AND N8YB.N8Y_CODPRO = N8Y.N8Y_CODPRO "
		cQuery2 += " AND N8YB.N8Y_DTATUA <= '" + DtoS(MV_PAR18) + "'"
		cQuery2 += " AND N8YB.D_E_L_E_T_ = ' '"
		cQuery2 += " )"
	EndIF
	cQuery2 += " AND N8W.N8W_FILIAL >= '" + __cFilIni + "'"
	cQuery2 += " AND N8W.N8W_FILIAL <= '" + __cFilFim + "'"
	cQuery2 += " AND N8Y.N8Y_SAFRA =  '" + cSafra + "'"
	cQuery2 += " AND N8W.N8W_CODPRO >= '" + MV_PAR07 + "'"
	cQuery2 += " AND N8W.N8W_CODPRO <= '" + MV_PAR08 + "'"
	cQuery2 += " AND N8W.N8W_GRPROD >= '" + MV_PAR09 + "'"
	cQuery2 += " AND N8W.N8W_GRPROD <= '" + MV_PAR10 + "'"
	cQuery2 += " AND N8W.N8W_MESANO >= '" + __cPerIni + "'"
	cQuery2 += " AND N8W.N8W_MESANO <= '" + __cPerFim + "'"
	cQuery2 += " AND N8W.D_E_L_E_T_ = '' "
	
	If !Empty(cFilN8W)
		cQuery2 += " AND N8W_FILIAL = '" + cFilN8W + "'"
	EndIf
	If !Empty(cCodPro)
		cQuery2 += " AND N8W_CODPRO = '" + cCodPro + "'"
	EndIf
	If !Empty(cGrProd)
		cQuery2 += " AND N8W_GRPROD = '" + cGrProd + "'"
	EndIf
	IF __nTipMerc <> 3
		cQuery2 += " AND N8W.N8W_TIPMER = '" + AllTrim(Str(__nTipMerc)) + "'"
	EndIf
	cQuery2 += "   ORDER BY  N8W_DTINIC "
	cQuery2	:=	ChangeQuery( cQuery2 )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery2 ), cAliasQry2, .F., .T. )

	(cAliasQry2)->(dbGoTop())
	While (cAliasQry2)->(!EOF())
	
		If !empty(cChave) .And. cChave <> (cAliasQry2)->N8W_MESANO
		
			PrintLine(oS2, cChave, nPrev, nVend, nPrRec, nVendRec)
			
		EndIF
		
		If (!empty(cChave) .And. cChave <> (cAliasQry2)->N8W_MESANO) .Or. empty(cChave)
			
			 cChave := (cAliasQry2)->N8W_MESANO
			 
			 nN8WQTDVEN := 0 
			 nN8WVLTDE2 := 0 
			 nN8WVLTODE := 0 
			 nN8WQTDREC := 0 
			 nN8WVLRTD2 := 0 
			 nN8WVLRTDE := 0 
			 nN8WSLDVEN := 0 
			 nN8WVTPDE2 := 0 
			 nN8WVLTPDE := 0 
			 nN8WSLDREC := 0 
			 nN8WVPRTD2 := 0 
			 nN8WVPRTD1 := 0 
		EndIf
		
		__cUnMedPla := (cAliasQry2)->N8Y_UM1PRO
				
		nN8WQTDVEN += ConvUnMed((cAliasQry2)->N8W_QTDVEN ,1,__cCodPro) 
		nN8WQTDREC += ConvUnMed((cAliasQry2)->N8W_QTDREC ,1,__cCodPro)  
		nN8WSLDVEN += ConvUnMed((cAliasQry2)->N8W_SLDVEN ,1,__cCodPro)  
		nN8WSLDREC += ConvUnMed((cAliasQry2)->N8W_SLDREC ,1,__cCodPro)  
		
		(cAliasQry2)->(dbSkip())
		
	EndDo
	
	/*Imprime último registro da quebra*/
	If !Empty(cChave)
	
		PrintLine(oS2, cChave, nPrev, nVend, nPrRec, nVendRec)
		
	EndIF

	oS2:Finish()
	

Return Nil

/*/{Protheus.doc} PrintLine
//Cabecalho customizado do report
@author tamyris.g
@since 31/03/2017
@version 1.0
@param oReport, object, descricao
@type function
/*/
Static Function PrintLine(oS2, cChave, nPrev, nVend, nPrRec, nVendRec)
	Local nPerc := 0
	
	If __nPosicao <> 2 //Vendido ou Ambos
			
		If nN8WQTDREC <> 0 .Or. nN8WQTDVEN <> 0
		 
			oS2:Cell( "N8W_MESANO"):SetValue(cChave )
			oS2:Cell( "N8W_OBSERV"):SetValue( STR0012 ) //VENDIDO
			
			/*Recebimento*/
			If __nPosicao  == 3 //Ambos
				nPerc := nN8WQTDREC / (nVendRec + nPrRec ) * 100
			Else
				nPerc := nN8WQTDREC / nVendRec * 100
			EndIf
			oS2:Cell( "N8W_VOLREC"):SetValue(nN8WQTDREC)
			oS2:Cell( "N8W_PERREC"):SetValue(Round(nPerc,2)) 
			
			/*Faturamento*/
			If __nPosicao  == 3 //Ambos
				nPerc := nN8WQTDVEN / (nVend + nPrev ) * 100
			Else
				nPerc := nN8WQTDVEN / nVend * 100
			EndIF
			oS2:Cell( "N8W_VOLFAT"):SetValue(nN8WQTDVEN) 
			oS2:Cell( "N8W_PERFAT"):SetValue(Round(nPerc,2)) 
			           
			oS2:PrintLine( )
			
		EndIf
	EndIF
	
	If __nPosicao <> 1 //A Vender ou Ambos
		
		If nN8WSLDREC <> 0 .Or. nN8WSLDVEN <> 0
		 
			oS2:Cell( "N8W_MESANO"):SetValue(cChave)
			oS2:Cell( "N8W_OBSERV"):SetValue( STR0013 ) //A VENDER 
				
			/*Recebimento*/
			If __nPosicao  == 3 //Ambos
				nPerc := nN8WSLDREC / (nVendRec + nPrRec ) * 100
			Else
				nPerc := nN8WSLDREC / nPrRec * 100
			EndIf
			oS2:Cell( "N8W_VOLREC"):SetValue(nN8WSLDREC)
			oS2:Cell( "N8W_PERREC"):SetValue(Round(nPerc,2)) 
			
			/*Faturamento*/
			If __nPosicao  == 3 //Ambos
				nPerc := nN8WSLDVEN /  (nVend + nPrev) * 100
			Else
				nPerc := nN8WSLDVEN / nPrev * 100
			EndIF
			oS2:Cell( "N8W_VOLFAT"):SetValue(nN8WSLDVEN) 
			oS2:Cell( "N8W_PERFAT"):SetValue(Round(nPerc,2)) 
			           
			oS2:PrintLine( )
			
		EndIf
			
	EndIf			

Return .T.


/*/{Protheus.doc} AGRARCabec
//Cabecalho customizado do report
@author janaina.duarte
@since 31/03/2017
@version 1.0
@param oReport, object, descricao
@type function
/*/
Static Function AGRARCabec(oReport, cNmEmp , cNmFilial)
	Local aCabec := {}
	Local cChar	 := CHR(160)  // caracter dummy para alinhamento do cabeçalho

	If SM0->(Eof())
		SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	Endif

	cNmEmp	 := AllTrim( SM0->M0_NOME )
	cNmFilial:= AllTrim( SM0->M0_FILIAL )

	// Linha 1
	AADD(aCabec, "__LOGOEMP__") // Esquerda

	// Linha 2 
	AADD(aCabec, cChar) //Esquerda
	aCabec[2] += Space(9) // Meio
	aCabec[2] += Space(9) + RptFolha + TRANSFORM(oReport:Page(),'999999') // Direita

	// Linha 3
	AADD(aCabec, "SIGA /" + oReport:ReportName() + "/v." + cVersao) //Esquerda
	aCabec[3] += Space(9) + oReport:cRealTitle // Meio
	IF __nDatRef == 1 //Mais atual
		aCabec[3] += Space(9) + "Dt.Ref:" +":" + Dtoc(dDataBase)   // Direita //"Dt.Ref:"
	Else
		aCabec[3] += Space(9) + "Dt.Ref:" +":" + Dtoc(MV_PAR18)   // Direita //"Dt.Ref:"
	EndIF

	// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	aCabec[4] += Space(9) // Meio
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

	// Linha 5
	AADD(aCabec, "STR0007" + ":" + cNmEmp) //Esquerda //"Empresa"
	aCabec[5] += Space(9) // Meio

Return aCabec

/*/{Protheus.doc} ConvUnMed
//Converter unidade de medida
@author tamyris.g	
@since 24/09/2018
@version 1.0
@param nValor - Valor que será convertido
       nTipo - 1 - conversão de volume / 2-conversão de preço
@type function
/*/
Static Function ConvUnMed(nValor,nTipo,cCodPro)
	Local nQtUM := 1
	
	If __cUnMedPla <> __cUnMedQtd
		If nTipo == 1 //Conversão de volume
			nQtUM	:= AGRX001(__cUnMedPla, __cUnMedQtd ,1, cCodPro)
		Else
			nQtUM	:= AGRX001(__cUnMedQtd, __cUnMedPla ,1, cCodPro)
		EndIF
	EndIf
		
	nValor := Round(nvalor * nQtUM ,2)
	
Return nValor



