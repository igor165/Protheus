#INCLUDE "OGAR820.ch"
#include "protheus.ch"
#include "report.ch"

/*/{Protheus.doc} OGAR820
Impressão do Plano de Vendas
@author tamyris.ganzenmueller
@since 20/09/2018
@version 1.0

@type function
/*/
Function OGAR820()

	Local oReport := Nil
	
	Private __cCodPro   := "" 
	Private __cUnMedPla := ""
	Private __cUnMeProd := ""
	Private __cUnMedQtd := ""
	Private __cUnMedPrc := ""
	Private __cMoeda1   := AllTrim(SuperGetMv("MV_SIMB"+"1"))
	Private __cMoeda2   := AllTrim(SuperGetMv("MV_SIMB"+"2"))
	Private nLin := 200
	Private __cFilIni := ""
	Private __cFilFim := ""
	Private __lQuebSafra := .F.
	Private __lQuebUnNeg := .F.
	Private __lQuebPer   := .F.
	Private __nCronog
	Private __nUnQtde     
	Private __nUnPrc 
	Private __nDtRef
	
	Pergunte("OGAR820", .T.)
	
	cFilBkp := cFilAnt
	cFilAnt := MV_PAR01
	__cFilIni := FWCodEmp() + FWUnitBusiness() 
	cFilAnt := cFilBkp
	__cFilFim := MV_PAR02
	
	If ValType(MV_PAR11) = 'N'
		__lQuebSafra := MV_PAR11 == 1
		__lQuebUnNeg := MV_PAR12 == 1
		__lQuebPer   := MV_PAR13 == 1
		__nCronog    := MV_PAR14 
		__nUnQtde    := MV_PAR15
		__nUnPrc     := MV_PAR17
		__nDtRef     := MV_PAR19
	Else
		__lQuebSafra := MV_PAR11 == '1'
		__lQuebUnNeg := MV_PAR12 == '1'
		__lQuebPer   := MV_PAR13 == '1'
		__nCronog    := Val(MV_PAR14)
		__nUnQtde    := Val(MV_PAR15)
		__nUnPrc     := Val(MV_PAR17)
		__nDtRef     := Val(MV_PAR19)
	EndIF
	
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
	
	Local cTxTitle := IIf(__nCronog == 1, STR0008, STR0009 ) //"Faturamento", "Financeiro"
	cTxTitle += " - " + STR0002
	
	oReport := TReport():New("OGAR820", cTxTitle, , {|oReport| PrintReport(oReport)}, cTxTitle) //"Cronograma de Vendas"
	oReport:SetPortrait(.T.) // Define a orientação default
	oReport:cFontBody := 'Courier New'
	oReport:HideParamPage()
	oReport:HideFooter() 
	oReport:SetTotalInLine(.F.)
	oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	oReport:nFontBody := 08 // Tamanho da fonte
	oReport:nDevice := 6 // Tipo de impressão 6-PDF
	oReport:SetLandScape()
		
	oSCabec   := TRSection():New( oReport, "Quebra" , )
	oSection1 := TRSection():New( oReport, "Cabeçalho", )
	oSection2 := TRSection():New( oReport, "Dados", )
			
	TRCell():New(oSCabec,"CHAVE","","","@!",200)
	TRCell():New( oSection1, "CABEC_MESANO" , , "" , PesqPict('N8W', 'N8W_MESANO')	, TamSX3("N8W_MESANO")[1]+8)	
	TRCell():New( oSection1, "CABEC_VOLUME" , , STR0003 , "@!" , 21) //"Volume de Vendas"
	TRCell():New( oSection1, "CABEC_VOLUM2" , , "" , "@!"	, 1)	 //Para ajuste da impressão em Excel
	TRCell():New( oSection1, "CABEC_OBSERV" , , STR0006 , "@!" , 22) //"Observações"
	
	TRCell():New( oSection2, "N8W_MESANO" ,  , ""  , PesqPict('N8W', 'N8W_MESANO')	, TamSX3("N8W_MESANO")[1]+2)	
	TRCell():New( oSection2, "N8W_QTPRVE" ,  , "" , "999,999,999,999.99" , 15)
	TRCell():New( oSection2, "N8W_PERVEN" ,  , "" , "999.99" , 6)
	TRCell():New( oSection2, "N8W_OBSERV" ,  , "" , "@!" , 20)

	oBreak1 := TRBreak():New( oSection2, "", STR0007 , .f. ) //Total	
	
	TRFunction():New(oSection2:Cell("N8W_QTPRVE") , Nil, "SUM" , oBreak1, , , , .f., .f. )
	TRFunction():New(oSection2:Cell("N8W_PERVEN") , Nil, "SUM" , oBreak1, , , , .f., .f. )
	
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
	Local cNomeEmp      := ""
	Local cNmFil        := ""
	Local cAliasQry := GetNextAlias()
	Local nN8WSLDVEN := 0
	Local nN8WQTDVEN := 0
	Local cChaveAtu   := ""
	Local cChave   := ""
	Local cCodProd := ""
	Local cGrpProd := ""
	Local cFilN8W  := ""
	Local cSafra   := ""
	
	oReport:SetCustomText( {|| AGRARCabec(oReport, @cNomeEmp, @cNmFil) } ) // Cabeçalho customizado

	cQuery := " SELECT N8Y_UM1PRO, N8W_CODPRO, N8W_GRPROD, N8W_FILIAL, N8W_SAFRA, N8W_SLDVEN, N8W_QTDVEN, N8W_SLDREC, N8W_QTDREC  FROM " + RetSqlName("N8Y") + " N8Y "
	cQuery += " INNER JOIN " + RetSqlName("N8W") + " N8W ON N8W.D_E_L_E_T_ = '' " 
	cQuery += " AND N8W.N8W_FILIAL = N8Y.N8Y_FILIAL AND N8W.N8W_CODPLA = N8Y.N8Y_CODPLA "
	cQuery += " WHERE N8Y.D_E_L_E_T_ = '' " 
	
	IF __nDtRef == 1 //Mais atual
		cQuery += "AND N8Y_ATIVO = '1' "
	Else //Data Informada
		cQuery += "AND N8Y_CODPLA IN ( SELECT MAX(N8YB.N8Y_CODPLA) FROM " +  RetSqlName("N8Y") + " N8YB "
		cQuery += " WHERE N8YB.N8Y_FILIAL = N8Y.N8Y_FILIAL "
		cQuery += " AND N8YB.N8Y_SAFRA  = N8Y.N8Y_SAFRA  "
		cQuery += " AND N8YB.N8Y_GRPROD = N8Y.N8Y_GRPROD "
		cQuery += " AND N8YB.N8Y_CODPRO = N8Y.N8Y_CODPRO "
		cQuery += " AND N8YB.N8Y_DTATUA <= '" + DtoS(MV_PAR20) + "'"
		cQuery += " AND N8YB.D_E_L_E_T_ = ' '"
		cQuery += " )"
	EndIF
	
	cQuery += " AND N8Y.N8Y_SAFRA >= '" + MV_PAR03 + "'"
	cQuery += " AND N8Y.N8Y_SAFRA <= '" + MV_PAR04 + "'"
	/*Precisa converter*/
	cQuery += " AND N8Y.N8Y_FILIAL >= '" + __cFilIni + "'"
	cQuery += " AND N8Y.N8Y_FILIAL <= '" + __cFilFim + "'"
	
	cQuery += " AND N8W.N8W_DTFINA >= '" + DtoS(LastDay(MV_PAR09)) + "'"
	cQuery += " AND N8W.N8W_DTFINA <= '" + DtoS(LastDay(MV_PAR10)) + "'"
	
	cQuery += " AND N8Y.N8Y_GRPROD >= '" + MV_PAR05 + "'"
	cQuery += " AND N8Y.N8Y_GRPROD <= '" + MV_PAR06 + "'"
	
	cQuery += " AND N8Y.N8Y_CODPRO >= '" + MV_PAR07 + "'"
	cQuery += " AND N8Y.N8Y_CODPRO <= '" + MV_PAR08 + "'"
	
	cQuery += " AND N8W.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY N8W_CODPRO, N8W_GRPROD "
	IF __lQuebUnNeg //Quebra por Unid Negócio
		cQuery += " , N8W_FILIAL "
	EndIF
	IF __lQuebSafra //Quebra por Safra
		cQuery += " , N8W_SAFRA "
	EndIF
	cQuery	:=	ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!EOF())
	
		cChaveAtu := (cAliasQry)->N8W_GRPROD+(cAliasQry)->N8W_CODPRO
		IF __lQuebSafra //Quebra por Safra
			cChaveAtu += (cAliasQry)->N8W_SAFRA
		EndIF
		IF __lQuebUnNeg //Quebra por Unid Negocio
			cChaveAtu += (cAliasQry)->N8W_FILIAL 
		EndIF
		
		If (!empty(cChave) .And. cChave <> cChaveAtu) .Or. Empty(cChave)
			
			If (!empty(cChave) .And. cChave <> cChaveAtu) //Só imprime se for ultimo registro da quebra
				printPlan(oReport, cCodProd, cGrpProd, cFilN8W, cSafra, nN8WSLDVEN, nN8WQTDVEN )
			EndIf
			
			nN8WSLDVEN := 0  
			nN8WQTDVEN := 0  
			
			cChave := cChaveAtu
			cCodProd := (cAliasQry)->N8W_CODPRO
			cGrpProd := (cAliasQry)->N8W_GRPROD
			
			IF __lQuebSafra //Quebra por Safra
				cSafra := (cAliasQry)->N8W_SAFRA
			EndIF
			IF __lQuebUnNeg //Quebra por Unid Negocio
				cFilN8W := (cAliasQry)->N8W_FILIAL 
			EndIF
						
			__cUnMedPrc := MV_PAR18 //Unidade Informada
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
			
			//Determina unidade de medida quantidade
			__cUnMedQtd := AllTrim(IIF(__nUnQtde == 1, __cUnMeProd , MV_PAR16 ) )
			If Empty(__cUnMedQtd)
				__cUnMedQtd := __cUnMedPla
			EndIF
			
			//Determina unidade de medida do preço
			If __nUnPrc == 1 //Un Produto
				__cUnMedPrc := __cUnMeProd
			ElseIf __nUnPrc == 2 //Unidade Preço
				__cUnMedPrc := Posicione("SB5",1,xFilial("SB5")+__cCodPro,'B5_UMPRC')
			EndIf
			
		EndIF
		
		__cUnMedPla := (cAliasQry)->N8Y_UM1PRO
		__cCodPro   := (cAliasQry)->N8W_CODPRO
		
		If __nCronog == 1 //Faturamento
			nN8WSLDVEN += ConvUnMed((cAliasQry)->N8W_SLDVEN ,1,__cCodPro) 
			nN8WQTDVEN += ConvUnMed((cAliasQry)->N8W_QTDVEN ,1,__cCodPro)  
		Else
			nN8WSLDVEN += ConvUnMed((cAliasQry)->N8W_SLDREC ,1,__cCodPro) 
			nN8WQTDVEN += ConvUnMed((cAliasQry)->N8W_QTDREC ,1,__cCodPro)
		EndIF
		
		(cAliasQry)->(dbSkip())
	EndDo
	
	If !empty(cCodProd) .And. !empty(cGrpProd)
		printPlan(oReport, cCodProd, cGrpProd, cFilN8W, cSafra, nN8WSLDVEN, nN8WQTDVEN)
	EndIF
	
Return 
	
Static Function printPlan(oReport, cCodPro, cGrProd, cFilN8W,  cSafra, nPrev, nVend)
	Local cAliasQry2 := GetNextAlias()
	Local cAno := ""
	Local cChave := ""
	Private nN8WQTDVEN := 0, nN8WVLTDE2 := 0 , nN8WVLTODE := 0 , nN8WVLTOFI := 0, nN8WVLTFI2 := 0 
	Private nN8WQTDREC := 0, nN8WVLRTD2 := 0 , nN8WVLRTDE := 0 , nN8WVLRTFI := 0, nN8WVLRTF2 := 0
	Private nN8WSLDVEN := 0, nN8WVTPDE2 := 0 , nN8WVLTPDE := 0 , nN8WVLTPFI := 0, nN8WVTPFI2 := 0
	Private nN8WSLDREC := 0, nN8WVPRTD2 := 0 , nN8WVPRTD1 := 0 , nN8WVPRTF1 := 0, nN8WVPRTF2 := 0
	
	Private cTipMer := ""
	Private cMoeda  := ""
	Private cMesAno := ""
	
	Private oSHeader := oReport:Section( 1 )
	Private oS1		 := oReport:Section( 2 )
	Private oS2		 := oReport:Section( 3 )
		
	If !Empty(cCodPro)
		cTxProd := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodPro,'B1_DESC')) 
	Else
		cTxProd := AllTrim(Posicione("SBM", 1, FwxFilial("SBM")+cGrProd, "BM_DESC"))
	EndIf
	
	If !empty(cFilN8W)
		cTxProd += " - " + STR0010 + " " + cFilN8W //Unid Negoc
	EndIf
	
	If !empty(cSafra)
		cTxProd += " - " + STR0011 + " " +  cSafra //Safra
	EndIf  
	
	If !__lQuebPer //Não tem quebra por período
		
		oS1:Finish()
		oS2:Finish()
		
		oReport:skipLine(1)
					
		oSHeader:Init()
		oSHeader:Cell("CHAVE"):SetValue(cTxProd)
		oSHeader:PrintLine()
	   	oSHeader:Finish()
    	    	
    	If oReport:nDevice <> 4 //Planilha
    		
    		oS1:Init()
			oS1:Cell("CABEC_MESANO"):SetValue("")
			oS1:Cell("CABEC_VOLUME"):SetValue(__cUnMedQtd + Space(13) +  "(%)" )
			oS1:Cell("CABEC_OBSERV"):SetValue("")
		Else
		
			oS1:Init()
			oS1:Cell("CABEC_MESANO"):SetValue("")
			oS1:Cell("CABEC_VOLUME"):SetValue(__cUnMedQtd)
			oS1:Cell("CABEC_VOLUM2"):SetValue("(%)" )
			oS1:Cell("CABEC_OBSERV"):SetValue("")
		endIf
				
		oS1:PrintLine( )
		oS1:Finish()
		
		oS2:Init()
	EndIF

	cQuery2 := " SELECT N8Y_UM1PRO, N8W_MESANO, N8W_TIPMER, N8W_MOEDA, "
	
	If __nCronog == 1 //Faturamento
		/*Vendido */
		cQuery2 += " N8W_QTDVEN, " 
		/*A Vender */
		cQuery2 += " N8W_SLDVEN"
	Else //Recebimento
		/*Vendido */
		cQuery2 += " N8W_QTDREC, "
		/*A Vender */
		cQuery2 += " N8W_SLDREC"
	EndIF
	cQuery2 += " FROM " + RetSqlName("N8Y") + " N8Y "
	cQuery2 += " INNER JOIN " + RetSqlName("N8W") + " N8W ON N8W.D_E_L_E_T_ = '' " 
	cQuery2 += " AND N8W.N8W_FILIAL = N8Y.N8Y_FILIAL AND N8W.N8W_CODPLA = N8Y.N8Y_CODPLA "
	cQuery2 += " WHERE N8Y.D_E_L_E_T_ = '' " 
	IF __nDtRef == 1 //Mais atual
		cQuery2 += "AND N8Y_ATIVO = '1' "
	Else //Data Informada
		cQuery2 += "AND N8Y_CODPLA IN ( SELECT MAX(N8YB.N8Y_CODPLA) FROM " +  RetSqlName("N8Y") + " N8YB "
		cQuery2 += " WHERE N8YB.N8Y_FILIAL = N8Y.N8Y_FILIAL "
		cQuery2 += " AND N8YB.N8Y_SAFRA  = N8Y.N8Y_SAFRA  "
		cQuery2 += " AND N8YB.N8Y_GRPROD = N8Y.N8Y_GRPROD "
		cQuery2 += " AND N8YB.N8Y_CODPRO = N8Y.N8Y_CODPRO "
		cQuery2 += " AND N8YB.N8Y_DTATUA <= '" + DtoS(MV_PAR20) + "'"
		cQuery2 += " AND N8YB.D_E_L_E_T_ = ' '"
		cQuery2 += " )"
	EndIF
	cQuery2 += " AND N8Y_CODPRO = '" + cCodPro + "'"
	cQuery2 += " AND N8Y_GRPROD = '" + cGrProd + "'"
	cQuery2 += " AND N8Y.N8Y_SAFRA >= '" + MV_PAR03 + "'"
	cQuery2 += " AND N8Y.N8Y_SAFRA <= '" + MV_PAR04 + "'"
	cQuery2 += " AND N8Y.N8Y_FILIAL >= '" + __cFilIni + "'"
	cQuery2 += " AND N8Y.N8Y_FILIAL <= '" + __cFilFim + "'"
	cQuery2 += " AND N8W.N8W_DTFINA >= '" + DtoS(LastDay(MV_PAR09)) + "'"
	cQuery2 += " AND N8W.N8W_DTFINA <= '" + DtoS(LastDay(MV_PAR10)) + "'"
	cQuery2 += " AND N8W.D_E_L_E_T_ = '' "
	
	If !Empty(cFilN8W)
		cQuery2 += " AND N8W_FILIAL = '" + cFilN8W + "'"
	EndIf
	If !Empty(cSafra)
		cQuery2 += " AND N8W_SAFRA = '" + cSafra + "'"
	EndIf
	cQuery2 += " ORDER BY N8W_DTINIC, N8W_TIPMER, N8W_MOEDA " "
	cQuery2	:=	ChangeQuery( cQuery2 )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery2 ), cAliasQry2, .F., .T. )

	(cAliasQry2)->(dbGoTop())
	While (cAliasQry2)->(!EOF())
		
		//Quebra por período
		If ( __lQuebPer .And. ( __nCronog == 1  .And. (nN8WQTDVEN <> 0 .Or. nN8WSLDVEN <> 0) .Or. ; 
		                        __nCronog == 2  .And. (nN8WQTDREC <> 0 .Or. nN8WSLDREC <> 0) ) ) 
		                           
            If Empty(cAno) .Or. cAno <> Substr( (cAliasQry2)->N8W_MESANO, 4 , 4 )
            	
            	If !Empty(cAno)
            		oS2:Finish()
        		EndIf
        		
        		cAno :=  Substr( (cAliasQry2)->N8W_MESANO, 4 , 4 )
            	
            	oS1:Finish()
				oS2:Finish()
				
				oReport:skipLine(1)
							
				oSHeader:Init()
				oSHeader:Cell("CHAVE"):SetValue(cTxProd  + " - " + cAno)
				oSHeader:PrintLine()
			   	oSHeader:Finish()
				
				If oReport:nDevice <> 4 //Planilha
		    		
		    		oS1:Init()
					oS1:Cell("CABEC_MESANO"):SetValue("")
					oS1:Cell("CABEC_VOLUME"):SetValue(__cUnMedQtd + Space(13) +  "(%)" )
					oS1:Cell("CABEC_OBSERV"):SetValue("")
				Else
				
					oS1:Init()
					oS1:Cell("CABEC_MESANO"):SetValue("")
					oS1:Cell("CABEC_VOLUME"):SetValue(__cUnMedQtd)
					oS1:Cell("CABEC_VOLUM2"):SetValue("(%)" )
					oS1:Cell("CABEC_OBSERV"):SetValue("")
				endIf
            	
				oS1:PrintLine( )
				oS1:Finish()
				
				oS2:Init()
            	
	        Endif
		EndIf
		
		If !empty(cChave) .And. cChave <> (cAliasQry2)->N8W_MESANO + (cAliasQry2)->N8W_TIPMER  + AllTrim(Str((cAliasQry2)->N8W_MOEDA,2))
			
			printN8W(nPrev,nVend)
			
		EndIf
		
		If (!empty(cChave) .And. cChave <> (cAliasQry2)->N8W_MESANO + (cAliasQry2)->N8W_TIPMER  + AllTrim(Str((cAliasQry2)->N8W_MOEDA,2))) .Or. empty(cChave)
			
			 cChave  := (cAliasQry2)->N8W_MESANO + (cAliasQry2)->N8W_TIPMER  + AllTrim(Str((cAliasQry2)->N8W_MOEDA,2))
			 cTipMer := IIF( (cAliasQry2)->N8W_TIPMER == '1', " MI ", " ME " )
			 cMoeda  := "(" + SuperGetMv("MV_SIMB"+AllTrim(Str((cAliasQry2)->N8W_MOEDA,2))) + ")"
			 cMesAno := (cAliasQry2)->N8W_MESANO 
			 
			 nN8WQTDVEN := 0 		 
			 nN8WQTDREC := 0			 
			 nN8WSLDVEN := 0 
			 nN8WSLDREC := 0 
			 	
		EndIf
		
		__cUnMedPla := (cAliasQry2)->N8Y_UM1PRO
				
		If __nCronog == 1 //Faturamento
		
			nN8WQTDVEN += ConvUnMed((cAliasQry2)->N8W_QTDVEN ,1,__cCodPro) 
			
			nN8WSLDVEN += ConvUnMed((cAliasQry2)->N8W_SLDVEN ,1,__cCodPro)  
		
		Else
		
			nN8WQTDREC += ConvUnMed((cAliasQry2)->N8W_QTDREC ,1,__cCodPro)  
			
			nN8WSLDREC += ConvUnMed((cAliasQry2)->N8W_SLDREC ,1,__cCodPro)  
		
		EndIF
		(cAliasQry2)->(dbSkip())
		
	EndDo
	
	/*Imprime Último Registro*/
	printN8W(nPrev,nVend)

	oS2:Finish()
	
	

Return Nil

/*/{Protheus.doc} printN8W
//Imprime linha
@author tamyris.g
@since 06/03/2019
@version 1.0
@param oReport, object, descricao
@type function
/*/
Static Function printN8W(nPrev,nVend)

	Local nPerc := 0

	If __nCronog == 1 //Faturamento
			
		/*Vendido*/
		If nN8WQTDVEN <> 0
			
			nPerc := nN8WQTDVEN / (nPrev + nVend) * 100
			
			oS2:Cell( "N8W_OBSERV"):SetValue(STR0012 + cTipMer + cMoeda ) //VENDIDO
			oS2:Cell( "N8W_MESANO"):SetValue(cMesAno)
			oS2:Cell( "N8W_PERVEN"):SetValue(Round(nPerc,2) )
			
			oS2:Cell( "N8W_QTPRVE"):SetValue(nN8WQTDVEN)
			
			oS2:PrintLine( )
			
		EndIf
		
		/*A Vender*/
		If nN8WSLDVEN <> 0
			
			nPerc := nN8WSLDVEN / (nPrev + nVend) * 100
			
			oS2:Cell( "N8W_OBSERV"):SetValue(STR0013 + cTipMer + cMoeda ) //A VENDER
			oS2:Cell( "N8W_MESANO"):SetValue(cMesAno)
			oS2:Cell( "N8W_PERVEN"):SetValue(Round(nPerc,2) )
			
			oS2:Cell( "N8W_QTPRVE"):SetValue(nN8WSLDVEN)			
			oS2:PrintLine( )
		
		EndIF
	Else

		/*Vendido*/
		If nN8WQTDREC <> 0
			nPerc := nN8WQTDREC / (nPrev + nVend) * 100
			
			oS2:Cell( "N8W_OBSERV"):SetValue(STR0012 + cTipMer + cMoeda ) //VENDIDO
			oS2:Cell( "N8W_MESANO"):SetValue(cMesAno)
			oS2:Cell( "N8W_PERVEN"):SetValue(Round(nPerc,2) )
			
			oS2:Cell( "N8W_QTPRVE"):SetValue(nN8WQTDREC)
			
			oS2:PrintLine( )
			
		EndIf
		
		/*A Vender*/
		If nN8WSLDREC <> 0
			
			nPerc := nN8WSLDREC / (nPrev + nVend) * 100
			
			oS2:Cell( "N8W_OBSERV"):SetValue(STR0013 + cTipMer + cMoeda ) //A VENDER
			oS2:Cell( "N8W_MESANO"):SetValue(cMesAno)
			oS2:Cell( "N8W_PERVEN"):SetValue(Round(nPerc,2) )
			
			oS2:Cell( "N8W_QTPRVE"):SetValue(nN8WSLDREC)
			
			oS2:PrintLine( )
		
		EndIF
	EndIf
			
Return

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

	IF __nDtRef == 1 //Mais atual
		aCabec[3] += Space(9) + "Dt.Ref:" +":" + Dtoc(dDataBase)   // Direita //"Dt.Ref:"
	Else
		aCabec[3] += Space(9) + "Dt.Ref:" +":" + Dtoc(MV_PAR20)   // Direita //"Dt.Ref:"
	EndIF

	// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	aCabec[4] += Space(9) // Meio
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

	// Linha 5
	AADD(aCabec, "STR0010" + ":" + cNmEmp) //Esquerda //"Empresa"
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
	
	If nTipo == 1 //Conversão de volume
		If __cUnMedPla <> __cUnMedQtd
			nQtUM	:= AGRX001(__cUnMedPla, __cUnMedQtd ,1, cCodPro)
		EndIF 
	Else //Conversão do preço
		If __cUnMedQtd <> __cUnMedPrc
			nQtUM	:= AGRX001(__cUnMedPrc, __cUnMedQtd ,1, cCodPro)
		EndIf
	EndIf
	
	nValor := Round(nvalor * nQtUM ,2)
	
Return nValor

