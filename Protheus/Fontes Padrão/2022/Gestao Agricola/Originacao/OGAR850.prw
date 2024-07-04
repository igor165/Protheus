#INCLUDE "OGAR850.ch"
#include "protheus.ch"
#include "report.ch"

/*/{Protheus.doc} OGAR850
Impressão do Plano de Vendas
@author tamyris.ganzenmueller
@since 14/02/2019
@version 1.0

@type function
/*/
Function OGAR850()

	Local oReport := Nil
	
	Private __cUnMeProd := ""
	Private __cUnMedQtd := ""
	Private __cUnMedPla := ""
	Private __cCodPro   := ""
	Private cAliasQry   := GetNextAlias()
	Private __cFilIni := ""
	Private __cFilFim := ""
	Private __nTipMer  
	Private __nPosic
	Private __nUnMed
	Private __nDatRef 
	Private __lAutomato := .f.

	Pergunte("OGAR850", .T.)
	 
	cFilBkp := cFilAnt
	cFilAnt := MV_PAR01
	__cFilIni := FWCodEmp() + FWUnitBusiness() 
	cFilAnt := cFilBkp
	__cFilFim := MV_PAR02
	
	If ValType(MV_PAR11) = 'N'
		__nTipMer := MV_PAR09
		__nPosic  := MV_PAR10
		__nUnMed  := MV_PAR11
		__nDatRef := MV_PAR13
	Else
		__nTipMer := Val(MV_PAR09)
		__nPosic  := Val(MV_PAR10)
		__nUnMed  := Val(MV_PAR11)
		__nDatRef := Val(MV_PAR13)
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
	
	oReport := TReport():New("OGAR850", STR0008, , {|oReport| PrintReport(oReport)}, STR0008) //"Cronograma x Meta"
	oReport:SetPortrait(.T.) // Define a orientação default
	oReport:cFontBody := 'Courier New'
	oReport:HideParamPage()
	oReport:HideFooter() 
	oReport:SetTotalInLine(.F.)
	oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	If  ! __lAutomato
		oReport:nDevice := 6 // Tipo de impressão 6-PDF
	EndIf
	oReport:SetLandScape()
	
	oSCabec   := TRSection():New( oReport, "Quebra" , )
	oSection1 := TRSection():New( oReport, "Cabeçalho", )
	oSection2 := TRSection():New( oReport, "Dados", )
	
	TRCell():New(oSCabec,"CHAVE","","","@!",200)
			
	/*
	TRCell():New( oSection1, "CABEC_MESANO" , , STR0001 , PesqPict('NNY', 'NNY_MESEMB')	, TamSX3("NNY_MESEMB")[1]) //"Período"	
	TRCell():New( oSection1, "CABEC_VOLUME" , , STR0002 , "@!",15) //"Volume Planejado"
	TRCell():New( oSection1, "CABEC_POSICA" , , STR0003 , "@!",20) //"Posição"
	TRCell():New( oSection1, "CABEC_REALIZ" , , STR0004 , "@!",15) //"Realizado" 
	TRCell():New( oSection1, "CABEC_PERREA" , , STR0005 , "@!",6)  //"% Realizado"
	TRCell():New( oSection1, "CABEC_META"   , , STR0006 , "@!",15) //"Meta"*/
		
	TRCell():New( oSection2, "T_MESANO" , , STR0001 , PesqPict('NNY', 'NNY_MESEMB')	, TamSX3("NNY_MESEMB")[1]) 	
	TRCell():New( oSection2, "T_VOLUME" , , STR0002 , "999,999,999,999.99" , 15) //"Volume Planejado"  
	TRCell():New( oSection2, "T_POSICA" , , STR0003 , "@!",20)                   //"Posição"           
	TRCell():New( oSection2, "T_REALIZ" , , STR0004 , "999,999,999,999.99" , 15) //"Realizado"         
	TRCell():New( oSection2, "T_PERREA" , , STR0005 , "999.99" , 6)              //"% Realizado"       
	TRCell():New( oSection2, "T_META"   , , STR0006 , "999,999,999,999.99" , 15) //"Meta"              
	
	oBreak1  := TRBreak():New(oSection2, "" , STR0007, .F., 'BRKSUB',  .F.)	//"Sub-total"
		
    TRFunction():New(oSection2:Cell("T_VOLUME") , Nil, "SUM" , oBreak1, , , , .f., .f. )
	TRFunction():New(oSection2:Cell("T_REALIZ") , Nil, "SUM" , oBreak1, , , , .f., .f. )
	TRFunction():New(oSection2:Cell("T_PERREA") , Nil, "SUM" , oBreak1, , , , .f., .f. )
	TRFunction():New(oSection2:Cell("T_META")   , Nil, "SUM" , oBreak1, , , , .f., .f. )
	
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
	
	oSHeader := oReport:Section( 1 )
	oS1		 := oReport:Section( 2 )
	oS2		 := oReport:Section( 3 )
	
	oReport:SetCustomText( {|| AGRARCabec(oReport, @cNomeEmp, @cNmFil) } ) // Cabeçalho customizado
	
	cQuery := " SELECT N8W_FILIAL, N8W_SAFRA, N8W_GRPROD, N8W_CODPRO, N8W_DTINIC, N8W_TIPMER, N8W_MOEDA, N8W_MESANO, N8Y_UM1PRO, "
	cQuery += " N8W_QTDVEN , " //Vendido - Faturamento
	cQuery += " N8W_QTDREC , " //Vendido - Recebimento
	cQuery += " N8W_SLDVEN , " //A Vender - Faturamento
	cQuery += " N8W_SLDREC , " //A Vender - Recebimento 
	cQuery += " N8W_QTDFAT  " //Faturado
	
	cQuery += " FROM " + RetSqlName("N8Y") + " N8Y "
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
		cQuery += " AND N8YB.N8Y_DTATUA <= '" + DtoS(MV_PAR14) + "'"
		cQuery += " AND N8YB.D_E_L_E_T_ = ' '"
		cQuery += " )"
	EndIF
	cQuery += " AND N8Y.N8Y_FILIAL >= '" + __cFilIni + "'"
	cQuery += " AND N8Y.N8Y_FILIAL <= '" + __cFilFim + "'"
	cQuery += " AND N8Y.N8Y_SAFRA >=  '" + MV_PAR03 + "'"
	cQuery += " AND N8Y.N8Y_SAFRA <=  '" + MV_PAR04 + "'"
	cQuery += " AND N8Y.N8Y_CODPRO >= '" + MV_PAR05 + "'"
	cQuery += " AND N8Y.N8Y_CODPRO <= '" + MV_PAR06 + "'"
	cQuery += " AND N8W.N8W_DTINIC >= '" + DtoS(MV_PAR07) + "'"
	cQuery += " AND N8W.N8W_DTFINA <= '" + DtoS(MV_PAR08) + "'"
	cQuery += " AND N8W.D_E_L_E_T_ = '' "
	IF __nTipMer <> 3
		cQuery += " AND N8W.N8W_TIPMER = '" + AllTrim(Str(__nTipMer)) + "'"
	EndIf
	cQuery += "   ORDER BY  N8W_FILIAL, N8W_SAFRA, N8W_GRPROD, N8W_CODPRO, N8W_DTINIC "
	
	cQuery	:=	ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!EOF())
		
		If oReport:Cancel()
		    Return( Nil )
	    EndIf
	    
	    /*Impressão das Unidades de Medida e Preço - Cabeçalho*/
	    If  ( Empty(cChave) .Or. cChave <> (cAliasQry)->(N8W_FILIAL+N8W_SAFRA+N8W_GRPROD+N8W_CODPRO) )
					
			__cUnMedPla := (cAliasQry)->N8Y_UM1PRO
			__cUnMeProd := Posicione("SB1",1,xFilial("SB1")+(cAliasQry)->N8W_CODPRO,'B1_UM')
			
			__cCodPro  := (cAliasQry)->N8W_CODPRO
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
			
			__cUnMedQtd := AllTrim(IIF(__nUnMed == 1, __cUnMeProd , MV_PAR12 ) )
			If Empty(__cUnMedQtd)
				__cUnMedQtd := (cAliasQry)->N8Y_UM1PRO
			EndIF
	
			oS2:Finish()
			
			/*Cabeçalho - novo produ*/
			oReport:skipLine(1)
						
			oSHeader:Init()
			cChave   := (cAliasQry)->(N8W_FILIAL+N8W_SAFRA+N8W_GRPROD+N8W_CODPRO)
			cTexto := STR0009 + (cAliasQry)->N8W_FILIAL + " - " + STR0010 + AllTrim((cAliasQry)->N8W_SAFRA)  + " - " + STR0011  //"Filial: " ## " - Safra: "##  " - Produto: "
			If !Empty((cAliasQry)->N8W_CODPRO)
				cTexto += AllTrim((cAliasQry)->N8W_CODPRO )+ " " + Posicione("SB1",1,xFilial("SB1")+(cAliasQry)->N8W_CODPRO,'B1_DESC')
			Else
				cTexto += AllTrim((cAliasQry)->N8W_GRPROD )+ " " + AllTrim(Posicione("SBM", 1, FwxFilial("SBM")+(cAliasQry)->N8W_GRPROD, "BM_DESC"))
			EndIf 
			cTexto += "(" + __cUnMedQtd + ")"
			oSHeader:Cell("CHAVE"):SetValue(cTexto)
			
		   	oSHeader:PrintLine()
		   	oSHeader:Finish()
		    					
			oS2:Init()
			
		EndIf
		
		/*Busca Valor da Meta do Mês*/
		cAno  := AllTrim(Str(YEAR(StoD((cAliasQry)->N8W_DTINIC))))
		cMes  := AllTrim(Str(MONTH(StoD((cAliasQry)->N8W_DTINIC))))
		nMeta := getVlMeta((cAliasQry)->N8W_CODPRO,cAno,cMes)
		nPerc := 0
		
		/*Tipo de Mercado e Moeda*/
		cTipMerDes := IIF((cAliasQry)->N8W_TIPMER == '1'," MI "," ME ")
		cMoedaDes  := "(" + AllTrim(SuperGetMv("MV_SIMB"+AllTrim(Str((cAliasQry)->N8W_MOEDA)))) + ") "
		
		nMeta := getVlMeta((cAliasQry)->N8W_CODPRO,(cAliasQry)->N8W_GRPROD,cAno,cMes)
		
		oS2:Cell( "T_MESANO"):SetValue((cAliasQry)->N8W_MESANO )
		oS2:Cell( "T_META"):SetValue(ConvUnMed(nMeta,1,__cCodPro))
		
		If __nPosic == 1 //Faturamento
		
			/*Vendido*/
			If (cAliasQry)->N8W_QTDVEN <> 0
				
				nPerc := 0
				If !Empty(nMeta)
					nPerc := (cAliasQry)->N8W_QTDVEN / (nMeta) * 100
				EndIF
				
				oS2:Cell( "T_POSICA"):SetValue(STR0012 + cTipMerDes + cMoedaDes ) //VENDIDO
				oS2:Cell( "T_VOLUME"):SetValue(ConvUnMed((cAliasQry)->N8W_QTDVEN,1,__cCodPro)) 
				oS2:Cell( "T_REALIZ"):SetValue(ConvUnMed((cAliasQry)->N8W_QTDFAT,1,__cCodPro))
				oS2:Cell( "T_PERREA"):SetValue(nPerc)
		
				oS2:PrintLine( )
				
			EndIf
			
			/*A Vender*/
			If (cAliasQry)->N8W_SLDVEN <> 0
				
				nPerc := 0
				If !Empty(nMeta)
					nPerc := (cAliasQry)->N8W_SLDVEN / nMeta * 100
				EndIF
				
				oS2:Cell( "T_POSICA"):SetValue(STR0013 + cTipMerDes + cMoedaDes ) //A VENDER
				oS2:Cell( "T_VOLUME"):SetValue(ConvUnMed((cAliasQry)->N8W_SLDVEN,1,__cCodPro)) 
				oS2:Cell( "T_REALIZ"):SetValue(0)
				oS2:Cell( "T_PERREA"):SetValue(nPerc)
				
				oS2:PrintLine( )
			
			EndIF
		Else
	
			/*Vendido*/
			If (cAliasQry)->N8W_QTDREC <> 0
			
				nPerc := 0
				If !Empty(nMeta)
					nPerc := (cAliasQry)->N8W_QTDREC / nMeta * 100
				EndIF
				
				oS2:Cell( "T_POSICA"):SetValue(STR0012 + cTipMerDes + cMoedaDes ) //VENDIDO
				oS2:Cell( "T_VOLUME"):SetValue(ConvUnMed((cAliasQry)->N8W_QTDREC,1,__cCodPro))
				oS2:Cell( "T_REALIZ"):SetValue(ConvUnMed((cAliasQry)->N8W_QTDFAT,1,__cCodPro))
				oS2:Cell( "T_PERREA"):SetValue(nPerc)
								
				oS2:PrintLine( )
				
			EndIf
			
			/*A Vender*/
			If (cAliasQry)->N8W_SLDREC <> 0
				nPerc := 0
				If !Empty(nMeta)
					nPerc := (cAliasQry)->N8W_SLDREC / nMeta * 100
				EndIF
				
				oS2:Cell( "T_POSICA"):SetValue(STR0013 + cTipMerDes + cMoedaDes ) //"A VENDER"
				oS2:Cell( "T_VOLUME"):SetValue(ConvUnMed((cAliasQry)->N8W_SLDREC,1,__cCodPro))   
				oS2:Cell( "T_REALIZ"):SetValue(0)
				oS2:Cell( "T_PERREA"):SetValue(nPerc)
				
				oS2:PrintLine( )
			
			EndIF
		EndIF
		
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
	IF __nDatRef == 1 //Mais atual
		aCabec[3] += Space(9) + "Dt.Ref:" +":" + Dtoc(dDataBase)   // Direita //"Dt.Ref:"
	Else
		aCabec[3] += Space(9) + "Dt.Ref:" +":" + Dtoc(MV_PAR14)   // Direita //"Dt.Ref:"
	EndIF

	// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	aCabec[4] += Space(9) // Meio
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

	// Linha 5
	AADD(aCabec, "Empresa" + ":" + cNmEmp) //Esquerda //"Empresa"
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
		Else //Conversão do preço
			nQtUM	:= AGRX001(__cUnMedQtd, __cUnMedPla ,1, cCodPro)
		EndIf
	EndIf
	
	nValor := Round(nvalor * nQtUM ,2)
	
Return nValor

			
/*{Protheus.doc} getVlMeta
Retorna o valor da meta financeira para o mês
@author tamyris.g
@since 20/02/2018
@type function */
Static Function getVlMeta(cCodPro,cGrpProd,cAno,cMes)
	
	Local nMeta := 0
	Local nQtUM := 1
	
	//Verifica se já tem outra meta cadastrada para o produto/ano
	cAliasQry2  := GetNextAlias()
	
	cQuery := "SELECT * FROM " + RetSqlName("NCZ") + " NCZ "
	If Empty(cCodPro) //Por grupo de produto
		cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + " ' AND B1_GRUPO = '" + cGrpProd + "' AND SB1.D_E_L_E_T_ = '' "
	EndIf 
	cQuery += " WHERE NCZ.NCZ_FILIAL = '" + xFilial("NCZ") + " '"
	
	If !Empty(cCodPro) //Por produto
		cQuery += " AND   NCZ.NCZ_CODPRO = '" + cCodPro + "' "
	Else //Por grupo de produto
		cQuery += " AND   NCZ.NCZ_CODPRO = SB1.B1_COD "
	EndIf
	
	cQuery += " AND   NCZ.NCZ_ANO    = '" + cAno + "' "
	cQuery += " AND   NCZ.NCZ_DATFIM = '' "
	cQuery += " AND   NCZ.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY NCZ_DATINI ASC "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry2,.F.,.T.)

	dbSelectArea(cAliasQry2)
	(cAliasQry2)->(dbGoTop())
	While (cAliasQry2)->(!EOF())
		
		nMeta += &((cAliasQry2)->( "NCZ_VLME" +  PADL(cMes,2,"0")  ))  
		
		//Converter p/ Unid Medida do Plano
		IF (cAliasQry2)->NCZ_UM1PRO <> __cUnMedPla
			nQtUM	:= AGRX001((cAliasQry2)->NCZ_UM1PRO,__cUnMedPla,1, cCodPro)
			
			nMeta := Round(nMeta * nQtUM ,2)
		EndIf 
		
		(cAliasQry2)->(dbSkip())
	EndDo
		
	(cAliasQry2)->(DbcloseArea())
	
Return nMeta


