#INCLUDE "OGAR840.ch"
#include "protheus.ch"
#include "report.ch"

/*/{Protheus.doc} OGAR840
Impressão do Plano de Vendas
@author tamyris.ganzenmueller
@since 14/02/2019
@version 1.0

@type function
/*/
Function OGAR840()

	Local oReport := Nil
	
	Private __cUnMeProd := ""
	Private __cUnMedQtd := ""
	Private __cUnMedPla := ""
	Private __cMoeda1   := AllTrim(SuperGetMv("MV_SIMB"+"1"))
	Private __cMoeda2   := AllTrim(SuperGetMv("MV_SIMB"+"2"))
	Private __cTitle    := ""
	Private __nTipMer  
	Private __nPosic
	Private __nUnMed
	Private __nDetal 
	Private oBreak1 
	Private cAliasQry   := GetNextAlias()
	
	Pergunte("OGAR840", .T.)
		
	If ValType(MV_PAR11) = 'N'
		__nTipMer := MV_PAR11
		__nPosic  := MV_PAR12
		__nUnMed  := MV_PAR13
		 __nDetal  := MV_PAR15
		__cTitle   := IIf(MV_PAR12 = 1,STR0002,STR0001) 
	Else
		__nTipMer := Val(MV_PAR11)
		__nPosic  := Val(MV_PAR12)
		__nUnMed  := Val(MV_PAR13)
		__nDetal  := Val(MV_PAR15)
		__cTitle  := IIf(MV_PAR12 = "1",STR0002,STR0001) 
	EndIF
	 
	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef
//TODO Descrição auto-gerada.
@author tamyris.ganzenmueller
@since 14/02/2019
@version 1.0

@type Static function
/*/
Static Function ReportDef()

	Local oReport := Nil
	
	oReport := TReport():New("OGAR840", __cTitle, , {|oReport| PrintReport(oReport)}, __cTitle) //"Cronograma Faturamento"
	oReport:SetPortrait(.T.) // Define a orientação default
	oReport:cFontBody := 'Courier New'
	oReport:HideParamPage()
	oReport:HideFooter() 
	oReport:SetTotalInLine(.F.)
	oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	oReport:nDevice := 6 // Tipo de impressão 6-PDF
	oReport:SetLandScape()
	
	oSCabec   := TRSection():New( oReport, "Quebra" , )
	oSection1 := TRSection():New( oReport, "Cabeçalho", )
	oSection2 := TRSection():New( oReport, "Dados", )
	
	TRCell():New(oSCabec,"CHAVE","","","@!",200)
			
	TRCell():New( oSection1, "CABEC_CTRC"   , , STR0008 , PesqPict('NJR', 'NJR_CODCTR')	, TamSX3("NJR_CODCTR")[1]+2) //"Contrato"
	If __nDetal == 2 //Regra Fiscal
		TRCell():New(oSection1, "CABEC_ITEM", , STR0014 , PesqPict('N9A', 'N9A_SEQPRI')	, TamSX3("N9A_ITEM")[1]+TamSX3("N9A_SEQPRI")[1]+2) //"Item"
	EndIF
	TRCell():New( oSection1, "CABEC_MESANO" , , STR0009 , PesqPict('NNY', 'NNY_MESEMB')	, TamSX3("NNY_MESEMB")[1]+8) //"Período"	
	TRCell():New( oSection1, "CABEC_VOLUME" , , STR0003 , "@!",21) //"Volume Vendido"
	TRCell():New( oSection1, "CABEC_VOLUM2" , , "" , "@!", 1)	   //Para ajuste da impressão em Excel
	
	If __nDetal == 2 //Regra Fiscal
		TRCell():New( oSection1, "CABEC_OBSERV" , , STR0015, "@!" , 22) //"Observações"
	EndIF
	
	TRCell():New( oSection2, "T_CTRC"   , "(cAliasQry)->NJR_CODCTR" , "" , PesqPict('NJR', 'NJR_CODCTR') , TamSX3("NJR_CODCTR")[1]+2)
	If __nDetal == 2 //Regra Fiscal
		TRCell():New( oSection2, "T_ITEM"   , "(cAliasQry)->N9A_SEQPRI" , "" , PesqPict('N9A', 'N9A_SEQPRI') , TamSX3("N9A_ITEM")[1]+TamSX3("N9A_SEQPRI")[1]+2)
	EndIF
	TRCell():New( oSection2, "T_MESANO" ,  , "" , PesqPict('NNY', 'NNY_MESEMB') , TamSX3("NNY_MESEMB")[1]+2)	
	TRCell():New( oSection2, "T_QTPRVE" ,  , "" , "999,999,999,999.99" , 15)
	TRCell():New( oSection2, "T_PERVEN" ,  , "" , "999.99" , 6)
	If __nDetal == 2 //Regra Fiscal
		TRCell():New( oSection2, "T_OBSERV" ,  , "" , "@!" , 20)
	EndIF

	oBreak1  := TRBreak():New(oSection2, { || (cAliasQry)->NJR_CODCTR } , STR0010, .F., 'BRKSUB',  .F.)	//"Sub-total"
		
    TRFunction():New(oSection2:Cell("T_QTPRVE") , Nil, "SUM" , oBreak1, , , , .f., .f. )
	TRFunction():New(oSection2:Cell("T_PERVEN") , Nil, "SUM" , oBreak1, , , , .f., .f. )
	
	oBreak2 := TRBreak():New( oSection2, "", STR0006 , .f. ) //Total	
	TRFunction():New(oSection2:Cell("T_QTPRVE") , Nil, "SUM" , oBreak2, , , , .f., .f. )
	TRFunction():New(oSection2:Cell("T_PERVEN") , Nil, "SUM" , oBreak2, , , , .f., .f. )
	
Return oReport

/*/{Protheus.doc} PrintReport
Imprime o conteudo do relatório
@author tamyris.ganzenmueller
@since 14/02/2019
@version undefined
@param oReport, object, objeto do relatório
@type function
/*/
Static Function PrintReport(oReport)
	Local cNomeEmp  := ""
	Local cNmFil    := ""
	Local cChave    := ""
	Local cMesAno   := ""
	Local nTotPer   := 0
	Local cDB := TcGetDB()
	
	oSHeader := oReport:Section( 1 )
	oS1		 := oReport:Section( 2 )
	oS2		 := oReport:Section( 3 )
	
	oReport:SetCustomText( {|| AGRARCabec(oReport, @cNomeEmp, @cNmFil) } ) // Cabeçalho customizado
	
	IF __nPosic == 1 /*Faturamento*/ .And.  __nDetal == 1 /*Contrato*/   
		cQuery := " SELECT N9A_FILORG, NJR_CODSAF, NJR_CODPRO, NJR_CODCTR," 
		
		If cDb = "ORACLE"
			cQuery += " to_char(to_date(nny_datfim),'yyyy') AS ANO , to_char(to_date(nny_datfim),'mm') AS MES, NNY_MESEMB,  "   		
		ElseIf cDb = 'MSSQL'
			cQuery += "YEAR(NNY_DATFIM) AS ANO, MONTH(NNY_DATFIM) AS MES, NNY_MESEMB,  "      
		ENDIF
		
		cQuery += "       SUM(CASE WHEN N9A.N9A_QTDNF > N9A.N9A_QUANT THEN N9A.N9A_QTDNF ELSE N9A.N9A_QUANT END) AS QTDVEN "
	Else
		cQuery := " SELECT N9A_FILORG, N9A_ITEM, N9A_SEQPRI, N9A_VLUFPR, NJR_CODSAF, NJR_CODPRO, NJR_FILIAL, NJR_CODCTR, NNY_MESEMB, N9A_QTDNF, N9A_QUANT, "
		
		If cDb = "ORACLE"
			cQuery += " to_char(to_date(nny_datfim),'yyyy') AS ANO , to_char(to_date(nny_datfim),'mm') AS MES  "   		
		ElseIf cDb = 'MSSQL'
			cQuery += "YEAR(NNY_DATFIM) AS ANO, MONTH(NNY_DATFIM) AS MES  "      
		ENDIF		
	EndIf
	
	cQuery += " FROM "+ RetSqlName("NJR") + " NJR "	
    
    cQuery +=  " INNER JOIN "+ RetSqlName("NNY") + " NNY ON NNY.NNY_FILIAL = '" + xFilial( 'NNY' ) + "'"   
	cQuery +=                                         " AND NNY.D_E_L_E_T_ = '' " 
	cQuery +=                                         " AND NNY.NNY_CODCTR = NJR.NJR_CODCTR "
	
	cQuery +=  " INNER JOIN "+ RetSqlName("N9A") + " N9A ON N9A.N9A_FILIAL = '" + xFilial( 'N9A' ) + "'"   
	cQuery +=                                         " AND N9A.D_E_L_E_T_ = '' " 
	cQuery +=                                         " AND N9A.N9A_CODCTR = NJR.NJR_CODCTR "
	cQuery +=                                         " AND N9A.N9A_ITEM   = NNY.NNY_ITEM "
	
	cQuery += "  WHERE NJR.NJR_FILIAL = '" + xFilial( 'NJR' ) + "'"	 
	cQuery +=    " AND NJR.D_E_L_E_T_ = '' "	 
	cQuery +=    " AND NJR.NJR_TIPO   = '2' "				 //TIPO 2=VENDA
	
	cQuery +=    " AND N9A.N9A_FILORG >= '" + mv_par01 + "'" //FILIAL
	cQuery +=    " AND N9A.N9A_FILORG <= '" + mv_par02 + "'" //FILIAL   
	
	cQuery +=    " AND NJR.NJR_CODSAF >= '" + mv_par03 + "'" //SAFRA
	cQuery +=    " AND NJR.NJR_CODSAF <= '" + mv_par04 + "'" //SAFRA
	
	cQuery +=    " AND NJR.NJR_CODPRO >= '" + mv_par05 + "'" //PRODUTO
	cQuery +=    " AND NJR.NJR_CODPRO <= '" + mv_par06 + "'" //PRODUTO
	
	cQuery +=    " AND NJR.NJR_CTREXT >= '" + mv_par07 + "'" //CONTRATO
	cQuery +=    " AND NJR.NJR_CTREXT <= '" + mv_par08 + "'" //CONTRATO
	
	cQuery +=    " AND NNY.NNY_DATFIM >= '" + DtoS(mv_par09) + "'" //MÊS EMBARQUE
	cQuery +=    " AND NNY.NNY_DATFIM <= '" + DtoS(mv_par10) + "'" //MÊS EMBARQUE
	
	If __nTipMer <> 3 //Ambos
        cQuery +=    " AND NJR.NJR_TIPMER =  '"+ cValToChar(__nTipMer) + "' " //MERCADO
    EndIf
	
	cQuery += IIF(__nPosic == 1 .And.  __nDetal == 1 , " GROUP BY ", " ORDER BY ") 
	cQuery += "  N9A_FILORG, NJR_CODSAF, NJR_CODPRO, NJR_CODCTR,"
	
	If cDb = "ORACLE"
		cQuery += " to_char(to_date(nny_datfim),'yyyy') , to_char(to_date(nny_datfim),'mm'),NNY_MESEMB   		
	ElseIf cDb = 'MSSQL'
		cQuery += " YEAR(NNY_DATFIM), MONTH(NNY_DATFIM), NNY_MESEMB "      
	ENDIF
	
	cQuery	:=	ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!EOF())
		
		If oReport:Cancel()
		    Return( Nil )
	    EndIf
	    
	    /*Impressão das Unidades de Medida e Preço - Cabeçalho*/
	    If  ( Empty(cChave) .Or. cChave <> (cAliasQry)->(N9A_FILORG+NJR_CODSAF+NJR_CODPRO) )
			
			nTotPer := 0
				
			__cUnMeProd := Posicione("SB1",1,xFilial("SB1")+(cAliasQry)->NJR_CODPRO,'B1_UM')
			__cUnMedQtd := AllTrim(IIF(__nUnMed == 1, __cUnMeProd , MV_PAR14 ) )
			
			oS1:Finish()
			oS2:Finish()
			
			oReport:skipLine(1)
						
			oSHeader:Init()
			cChave   := (cAliasQry)->(N9A_FILORG+NJR_CODSAF+NJR_CODPRO)
			cTexto := STR0011 + (cAliasQry)->N9A_FILORG + " - " + STR0012 + AllTrim((cAliasQry)->NJR_CODSAF)  + " - " + STR0013 + AllTrim((cAliasQry)->NJR_CODPRO )+ " " + Posicione("SB1",1,xFilial("SB1")+(cAliasQry)->NJR_CODPRO,'B1_DESC') //"Filial: " ## " - Safra: "##  " - Produto: " 
			oSHeader:Cell("CHAVE"):SetValue(cTexto)
			
		   	oSHeader:PrintLine()
		   	oSHeader:Finish()
		   	
		   	If oReport:nDevice <> 4 //Planilha
	    		oS1:Init()
				oS1:Cell("CABEC_CTRC"):SetValue("")
				oS1:Cell("CABEC_MESANO"):SetValue("")
				oS1:Cell("CABEC_VOLUME"):SetValue(__cUnMedQtd + Space(13) +  "(%)" )
			Else
				oS1:Init()
				oS1:Cell("CABEC_CTRC"):SetValue("")
				oS1:Cell("CABEC_MESANO"):SetValue("")
				oS1:Cell("CABEC_VOLUME"):SetValue(__cUnMedQtd)
				oS1:Cell("CABEC_VOLUM2"):SetValue("(%)" )
			endIf
					
			oS1:PrintLine( )
			oS1:Finish()
			
			oS2:Init()
			
			/*Impressão da Posição a Vender*/
			If  __nDetal == 2 //Regra Fiscal
				lPrint := printPlan(oS2, (cAliasQry)->N9A_FILORG , (cAliasQry)->NJR_CODSAF , (cAliasQry)->NJR_CODPRO )
				If lPrint
					oReport:skipLine(1)
				EndIF
			EndIF
		EndIf
		
		/*Busca Valor da Meta do Mês*/
		cAno  := IIf(cDb = "ORACLE", (cAliasQry)->ANO, AllTrim(Str((cAliasQry)->ANO)) )
		cMes  := IIf(cDb = "ORACLE", (cAliasQry)->MES, AllTrim(Str((cAliasQry)->MES)) )
		nMeta := getVlMeta((cAliasQry)->NJR_CODPRO,cAno,cMes,__cUnMeProd)
		nPerc := 0
		
		/*Busca Tipo Mercado e Moeda*/
		cTipMerCtr := Posicione('NJR', 1, xFilial('NJR') + (cAliasQry)->NJR_CODCTR , 'NJR_TIPMER')
		cMoedaCtr  := Posicione('NJR', 1, xFilial('NJR') + (cAliasQry)->NJR_CODCTR , 'NJR_MOEDA')
		
		/*Impressão dos Dados*/
		If __nPosic == 1 .And.  __nDetal == 1 //Faturamento e Contrato
		
			/*Un Med do Produto. Moeda: MI-R$; ME-U$*/
			nTotPer   := (cAliasQry)->QTDVEN			
		Else
			//Retorna Qtd Financeiro
			If __nPosic == 1 //Faturamento
				nTotQtd := IIF((cAliasQry)->N9A_QTDNF > (cAliasQry)->N9A_QUANT,(cAliasQry)->N9A_QTDNF,(cAliasQry)->N9A_QUANT)
			Else
				nTotQtd := getQtdFin() //Financeiro
			EndIF
			
			/*Un Med do Produto. Moeda: MI-R$; ME-U$*/
			nTotPer   += nTotQtd					
		EndIf
		
		If __nDetal == 1 //Quebra por Contrato
			cStrMesAno := (cAliasQry)->NJR_CODCTR + cMes + cAno
		else //Quebra por RF
			cStrMesAno := (cAliasQry)->(NJR_CODCTR+N9A_ITEM+N9A_SEQPRI) + cMes + cAno
		EndIF
		 		
		If ( __nPosic == 1 .And. __nDetal == 1 ) .Or. Empty(cMesAno) .Or. cMesAno <> cStrMesAno
			
			cMesAno := cStrMesAno
				
			If !Empty(nMeta)
				nPerc := Round(nTotPer / nMeta * 100 , 2)
			EndIF
			
			//Converte Unidade de Medida
			nTotPer := ConvUnMed(nTotPer,1,(cAliasQry)->NJR_CODPRO) 
			
			oS2:Cell( "T_MESANO"):SetValue((cAliasQry)->NNY_MESEMB )
			oS2:Cell( "T_CTRC"):SetValue((cAliasQry)->NJR_CODCTR )
			oS2:Cell( "T_PERVEN"):SetValue(Round(nPerc,2) )
			oS2:Cell( "T_QTPRVE"):SetValue(nTotPer)
			
			If __nDetal == 2 //Por Regra Fiscal
				cTipMerDes := IIF(cTipMerCtr=='1'," MI "," ME ")
				cMoedaDes  := "(" + AllTrim(SuperGetMv("MV_SIMB"+AllTrim(Str(cMoedaCtr)))) + ") "
				
				oS2:Cell( "T_OBSERV"):SetValue(STR0017 + cTipMerDes + cMoedaDes ) //VENDIDO
				oS2:Cell( "T_ITEM"):SetValue((cAliasQry)->N9A_ITEM + "-" + (cAliasQry)->N9A_SEQPRI )
			EndIF 
							
			//Data para conversão da moeda 
			dDataConv := dDataBase
			If !Empty((cAliasQry)->MES)
				dDataConv := StoD( cAno + PADL(cMes,2,"0") + '01' )
				dDataConv := LastDay(dDataConv) 
			EndIF
			
			oS2:PrintLine( )
			
			If mv_par12 == 2 /*Financeiro*/ .Or. __nDetal == 2 /*Regra Fiscal*/ 
				nTotPer := 0
			EndIf
			
		EndIf
		
		(cAliasQry)->(dbSkip())
	EndDo
	
	oS2:Finish()
	
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
	aCabec[3] += Space(9) + "Dt.Ref:" +":" + Dtoc(dDataBase)   // Direita //"Dt.Ref:"

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
	
	If __cUnMeProd <> __cUnMedQtd
		If nTipo == 1 //Conversão de volume
			nQtUM	:= AGRX001(__cUnMeProd, __cUnMedQtd ,1, cCodPro)
		Else //Conversão do preço
			nQtUM	:= AGRX001(__cUnMedQtd, __cUnMeProd ,1, cCodPro)
		EndIf
	EndIf
	
	nValor := Round(nvalor * nQtUM ,2)
	
Return nValor


/*/{Protheus.doc} ConvUnMePV
//Converter unidade de medida do plano de vendas (a vender)
@author tamyris.g	
@since 24/09/2018
@version 1.0
@param nValor - Valor que será convertido
       nTipo - 1 - conversão de volume / 2-conversão de preço
@type function
/*/
Static Function ConvUnMePV(nValor,nTipo,cCodPro)
	Local nQtUM := 1
	
	If __cUnMedPla <> __cUnMedQtd
		If nTipo == 1 //Conversão de volume
			nQtUM	:= AGRX001(__cUnMedPla, __cUnMedQtd ,1, cCodPro)
		Else //Conversão do preço
			nQtUM	:= AGRX001(__cUnMedQtd, __cUnMedPla ,1, cCodPro)
		EndIf
	EndIf
	
	nValor := Round(nvalor * nQtUM ,2)
	
Return nValor


/*{Protheus.doc} getQtdFin
Retorna a quantidade recebimento financeiro
@author tamyris.g
@since 20/02/2018
@type function
*/
Static Function getQtdFin()	
	Local nTotQtd := 0
	Local cAliasN9K	:= GetNextAlias()
	Local cAliasN9J := GetNextAlias()
	
	/*Previsões financeiras*/
	dbSelectArea("NN7")
	NN7->(dbGoTop())
	NN7->( dbSetOrder( 1 ) )
	NN7->( dbSeek( xFilial( "NN7" ) + (cAliasQry)->( NJR_CODCTR ) ) )
	While .Not. NN7->( Eof() ) .And. NN7->NN7_FILIAL = xFilial("NN7") .And. NN7->NN7_CODCTR = (cAliasQry)->NJR_CODCTR
			
		IF NN7->NN7_TIPEVE == '1'
			BeginSql Alias cAliasN9K
				SELECT SUM(N9K_QTDVNC) AS N9K_QTDVNC
				  FROM %table:N9K% N9K
				 WHERE N9K_FILORI  = %Exp:(cAliasQry)->NJR_FILIAL%
				   AND N9K_CODCTR  = %Exp:(cAliasQry)->NJR_CODCTR%
				   AND N9K_ITEMPE  = %Exp:(cAliasQry)->N9A_ITEM%
				   AND N9K_ITEMRF  = %Exp:(cAliasQry)->N9A_SEQPRI%	 
				   AND N9K_SEQPF   = %Exp:NN7->NN7_ITEM% 
                   AND N9K.%notDel%
			EndSQL
			
			DbSelectArea( cAliasN9K )		
			(cAliasN9K)->( dbGoTop() )
			IF .Not. (cAliasN9K)->( Eof( ) )
				nTotQtd := (cAliasN9K)->N9K_QTDVNC
			EndIF
			(cAliasN9K)->(dbCloseArea())		
		Else
			BeginSql Alias cAliasN9J
				SELECT SUM(N9J_QTDE - N9J_QTDEVT ) AS N9J_QTDE  
				  FROM %table:N9J% N9J
				 WHERE N9J_FILIAL  = %Exp:(cAliasQry)->NJR_FILIAL%
				   AND N9J_CODCTR  = %Exp:(cAliasQry)->NJR_CODCTR%
				   AND N9J_ITEMPE  = %Exp:(cAliasQry)->N9A_ITEM%
				   AND N9J_ITEMRF  = %Exp:(cAliasQry)->N9A_SEQPRI%
				   AND N9J_SEQPF   = %Exp:NN7->NN7_ITEM%	      
				   AND N9J.%notDel%
			EndSQL
			
			DbSelectArea( cAliasN9J )		
			(cAliasN9J)->( dbGoTop() )
			IF .Not. (cAliasN9J)->( Eof( ) )
				nTotQtd := (cAliasN9J)->N9J_QTDE
			EndIF
			(cAliasN9J)->(dbCloseArea())
		EndIf
		
		NN7->( dbSkip() )
	EndDo
Return nTotQtd
			
/*{Protheus.doc} getVlMeta
Retorna o valor da meta financeira para o mês
@author tamyris.g
@since 20/02/2018
@type function */
Static Function getVlMeta(cCodPro,cAno,cMes,cUnidMed)
	
	Local nMeta := 0
	Local nQtUM := 1
	
	//Verifica se já tem outra meta cadastrada para o produto/ano
	cAliasQry2  := GetNextAlias()
	cQuery := "SELECT * "
	cQuery += " FROM " + RetSqlName("NCZ") + " NCZ "
	cQuery += " WHERE NCZ.NCZ_FILIAL = '" + xFilial("NCZ") + " '"
	cQuery += " AND   NCZ.NCZ_CODPRO = '" + cCodPro + "' "
	cQuery += " AND   NCZ.NCZ_ANO    = '" + cAno + "' "
	cQuery += " AND   NCZ.NCZ_DATFIM = '' "
	cQuery += " AND   NCZ.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY NCZ_DATINI ASC "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry2,.F.,.T.)

	dbSelectArea(cAliasQry2)
	(cAliasQry2)->(dbGoTop())
	If (cAliasQry2)->(!Eof() )
		
		nMeta := &((cAliasQry2)->( "NCZ_VLME" +  PADL(cMes,2,"0")  ))  
		
		//Converter Unid Medida 
		IF (cAliasQry2)->NCZ_UM1PRO <> cUnidMed
			nQtUM	:= AGRX001((cAliasQry2)->NCZ_UM1PRO,cUnidMed,1, cCodPro)
			
			nMeta := Round(nMeta * nQtUM ,2)
		EndIf 
				
	EndIf
	(cAliasQry2)->(DbcloseArea())
	
Return nMeta

/*{Protheus.doc} printPlan
Imprime o plano de vendas
@author tamyris.g
@since 20/02/2019
@type function */
Static Function printPlan(oS2, cFilN8W, cSafra, cCodPro )
	Local cAliasQry3 := GetNextAlias()
	Local lPrint := .F. 
	
	cFilBkp := cFilAnt
	cFilAnt := cFilN8W
	cFilIni := FWCodEmp() + FWUnitBusiness() 
	cFilAnt := cFilBkp

	cQuery3 := " SELECT  N8W_DTINIC, N8W_TIPMER, N8W_MOEDA, N8Y_UM1PRO, "
	
	If MV_PAR12 == 1 //Faturamento
		cQuery3 += " SUM(N8W_SLDVEN) AS N8W_SLDVEN "
	Else //Recebimento
		cQuery3 += " SUM(N8W_SLDREC) AS N8W_SLDREC "
	EndIf
	
	cQuery3 += " FROM " + RetSqlName("N8Y") + " N8Y "
	cQuery3 += " INNER JOIN " + RetSqlName("N8W") + " N8W ON N8W.D_E_L_E_T_ = '' AND N8W.N8W_FILIAL = N8Y.N8Y_FILIAL AND N8W.N8W_CODPLA = N8Y.N8Y_CODPLA "
	cQuery3 += " WHERE N8Y.D_E_L_E_T_ = '' AND N8Y_ATIVO = '1' "
	cQuery3 += "  AND N8W_CODPRO     = '" + cCodPro + "'"
	cQuery3 += "  AND N8Y.N8Y_SAFRA  = '" + cSafra + "'"
	cQuery3 += "  AND N8Y.N8Y_FILIAL = '" + cFilIni + "'"
	cQuery3 += "  AND N8W.N8W_DTINIC >= '" + DtoS(mv_par09) + "'"
	cQuery3 += "  AND N8W.N8W_DTFINA <= '" + DtoS(mv_par10) + "'"
	cQuery3 += "  AND N8W.D_E_L_E_T_ = '' "
	cQuery3 += " GROUP BY N8W_DTINIC, N8W_TIPMER, N8W_MOEDA, N8Y_UM1PRO "
	cQuery3 += " ORDER BY N8W_DTINIC "
	cQuery3	:=	ChangeQuery( cQuery3 )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery3 ), cAliasQry3, .F., .T. )

	(cAliasQry3)->(dbGoTop())
	While (cAliasQry3)->(!EOF())
		
		__cUnMedPla := (cAliasQry3)->N8Y_UM1PRO
		
		cTipMerDes := IIF((cAliasQry3)->N8W_TIPMER == '1'," MI "," ME ")
		cMoedaDes  := "(" + AllTrim(SuperGetMv("MV_SIMB"+AllTrim(Str((cAliasQry3)->N8W_MOEDA)))) + ") "
		nMeta := getVlMeta(cCodPro,AllTrim(Str(YEAR(StoD((cAliasQry3)->N8W_DTINIC)))),AllTrim(Str(MONTH(StoD((cAliasQry3)->N8W_DTINIC)))),__cUnMedPla)
		nPerc := 0
		
		oS2:Cell( "T_CTRC"):SetValue("")
		oS2:Cell( "T_ITEM"):SetValue("")
		oS2:Cell( "T_MESANO"):SetValue(AGRMESANO( ANOMES(  StoD((cAliasQry3)->N8W_DTINIC) ) , 1)      )
		oS2:Cell( "T_OBSERV"):SetValue(STR0018 + cTipMerDes + cMoedaDes )
			
		If MV_PAR12 == 1 //Faturamento		
			/*A Vender*/
			If (cAliasQry3)->N8W_SLDVEN <> 0				
				If !Empty(nMeta)
					nPerc := Round((cAliasQry3)->N8W_SLDVEN / nMeta * 100 , 2)
				EndIF
				oS2:Cell( "T_PERVEN"):SetValue(Round(nPerc,2) )
				oS2:Cell( "T_QTPRVE"):SetValue(ConvUnMePV((cAliasQry3)->N8W_SLDVEN,1,cCodPro))
				
				lPrint := .T.
				oS2:PrintLine( )			
			EndIF
		Else				
			/*A Vender*/
			If (cAliasQry3)->N8W_SLDREC <> 0				
				If !Empty(nMeta)
					nPerc := Round((cAliasQry3)->N8W_SLDREC / nMeta * 100 , 2)
				EndIF
				oS2:Cell( "T_PERVEN"):SetValue(Round(nPerc,2))
				oS2:Cell( "T_QTPRVE"):SetValue(ConvUnMePV((cAliasQry3)->N8W_SLDREC,1,cCodPro))
				
				lPrint := .T.
				oS2:PrintLine( )			
			EndIF		
		EndIf
		
		(cAliasQry3)->(dbSkip())
		
	EndDo
	
	if lPrint
		oBreak1:Execute(.T.)
		oBreak1:Printtotal()
	EndIF
	 
Return lPrint
