#INCLUDE "UBAR007.ch"
#include "protheus.ch"
#include "report.ch"

Static __cCampDX7 := "DX7_MIC,DX7_RES,DX7_FIBRA,DX7_UI,DX7_SFI,DX7_ELONG,DX7_LEAF,DX7_AREA,DX7_CSP,DX7_MAISB,DX7_RD,DX7_COUNT,DX7_UHM,DX7_SCI"
//-------------------------------------------------------------------
/*/{Protheus.doc} UBAR007
Função de relatorio Confirmacao de Take-Up
@author Janaina F. B. Duarte
@since 30/03/2017
@version 1.0                                    
/*/
//-------------------------------------------------------------------
Function UBAR007(cReserva)
	
	Private oReport := Nil
	
  	if Funname() = "OGC020"
		dbSelectArea( "DXP" )
		DXP->( dbSetOrder( 1 ) )
		dbSeek( xFilial( "DXP" ) + cReserva )  
	endIf	      
  	
  	//Somente imprime o report se a reserva estiver com status Take-Up efetuado
	if DXP->DXP_STATUS == "2" //Take-Up efetuado
	else
	   Help( , , STR0022, ,STR0019, 1, 0 ) // Atenção # "Somente é possível emitir o Termo para Reservas com Take-Up concluído."
	   return
	endIf
	    
	oReport:= ReportDef(cReserva) // Obtem o objeto do TReport ja construido pela função ReportDef()
	oReport:PrintDialog() // Executa a Impressão
	
Return

/*/{Protheus.doc} ReportDef
//Definicoes do report e impressao do cabecalho
@author janaina.duarte
@since 31/03/2017
@version 1.0

@type function
/*/
Static Function ReportDef(cReserva)
	
	Local oReport		:= Nil
	Local oSection1 	:= Nil
	Local oStruDX7 	    := FwFormStruct(1, "DX7", {|cCampo| ALLTRIM(cCampo) $ __cCampDX7}) // Obtem a estrutura da DX7
	Local nIt			:= 0
	Local cReserva := Iif(!isBlind(),cReserva,cResevUBA)   
    Local lautomato := Iif(!isBlind(),.F.,.T.)
   
	
	IF lautomato
		dbSelectArea( "DXP" )
		DXP->( dbSetOrder( 1 ) )
		dbSeek( xFilial( "DXP" ) + cReserva )
	EndIf
 	oReport := TReport():New("UBAR007", STR0001, , {|oReport| PrintReport(oReport)}, STR0001) //"Confirmação de Take-Up"
	oReport:SetLandscape() // Define a orientação default
	oReport:cFontBody := 'Courier New'
	oReport:HideParamPage()
	oReport:HideFooter() 
	oReport:SetTotalInLine(.F.)
	oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	oReport:nFontBody := 8 // Tamanho da fonte
	oReport:oPage:setPaperSize(9) // Seta a Folha para A4, porem não desabilita o campo
	
	oSection1 := TRSection():New(oReport,STR0001,{"DXQ", "DX7"}, /*aOrder*/, /*lLoadCells*/, /*lLoadOrder*/, /*uTotalText*/, ;
									/*lTotalInLine*/, /*lHeaderPage*/, /*lHeaderBreak*/, /*lPageBreak*/, /*lLineBreak*/, /*nLeftMargin*/, /*lLineStyle*/,;
									 /*nColSpace*/, /*lAutoSize*/, /*cCharSeparator*/, /*nLinesBefore*/, /*nCols*/, /*nClrBack*/, /*nClrFore*/, /*nPercentage*/)
 
	TRCell():New(oSection1, "DXQ_FILORG"	, /*cAlias*/, STR0009	,PesqPict('DXQ',"DXQ_FILORG")	,TamSX3("DXQ_FILORG")[1]+10,/*lPixel*/,/*{|| code-block de impressao }*/, /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, /*lBold*/)
	TRCell():new(oSection1, "DXQ_TIPO"		, /*cAlias*/, STR0010	,PesqPict('DXQ',"DXQ_TIPO")		,TamSX3("DXQ_TIPO")[1]+3,/*lPixel*/,/*{|| code-block de impressao }*/, /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/ , /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, /*lBold*/)
	TRCell():new(oSection1, "DXQ_BLOCO"	, /*cAlias*/, STR0011	,PesqPict('DXQ',"DXQ_BLOCO")	,TamSX3("DXQ_BLOCO")[1]+3,/*lPixel*/,/*{|| code-block de impressao }*/, /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, /*lBold*/)
	TRCell():new(oSection1, "DXQ_QUANT"	, /*cAlias*/, STR0012	,PesqPict('DXQ',"DXQ_QUANT")	,TamSX3("DXQ_QUANT")[1]+3,/*lPixel*/,/*{|| code-block de impressao }*/, /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, /*lBold*/)
	TRCell():new(oSection1, "DXQ_PSBRUT"	, /*cAlias*/, STR0013	,PesqPict('DXQ',"DXQ_PSBRUT")	,TamSX3("DXQ_PSBRUT")[1]+3,/*lPixel*/,/*{|| code-block de impressao }*/, /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, /*lBold*/)
	TRCell():new(oSection1, "DXQ_PSLIQU"	, /*cAlias*/, STR0014	,PesqPict('DXQ',"DXQ_PSLIQU")	,TamSX3("DXQ_PSLIQU")[1]+3,/*lPixel*/,/*{|| code-block de impressao }*/, /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, /*lBold*/)

	For nIt := 1 To Len(oStruDX7:AFIELDS) // Adiciona as Células com os campos da DX7 - Layout HVI	
		TRCell():new(oSection1, AllTrim(oStruDX7:AFIELDS[nIt][3])	, /*cAlias*/, AllTrim(oStruDX7:AFIELDS[nIt][1]), PesqPict('DX7', AllTrim(oStruDX7:AFIELDS[nIt][3]))	,TamSX3(AllTrim(oStruDX7:AFIELDS[nIt][3]))[1]+3,/*lPixel*/,/*{|| code-block de impressao }*/, /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, /*lBold*/)		
	Next nIt	

Return oReport


/*/{Protheus.doc} PrintReport
//Impressao das linhas do relatorio
@author janaina.duarte
@since 31/03/2017
@version 1.0
@param oReport, object, descricao
@type function
/*/
Static Function PrintReport(oReport)
	
	Local aArrayMast		:= UBAR007QRY()
	Local aArrayDet	   	:= {}
	Local aArrayTFL	   	:= {}
	Local aArrayTot	   	:= {}
	Local nLin 			:= 0
	Local nIt1  			:= 0
	Local cNmClaCli 		:= Posicione("NNA",1,xFilial("NNA")+DXP->DXP_CLAEXT,"NNA_NOME") //Nome do Classificador do Cliente
	Local cCliente  		:= AllTrim(aArrayMast[1][3]) //Empresa do Classificador Cliente
	Local cNmClaInt 		:= Posicione("NNA",1,xFilial("NNA")+DXP->DXP_CLAINT,"NNA_NOME") //Nome do Classificador Interno
	Local cNomeEmp      	:= ""
	Local cNmFil        	:= ""
	Local cNomFil2		:= ""
	Local oSection1		:= oReport:Section(1) // Obtém a seção de campos da DXQ e DX7
	Local nIt2				:= 0
	
	Private _aCells		:= oSection1:aCell // Obtém as células da seção 1
	
	oReport:oPage:setPaperSize(9) // Seta a Folha para A4 para impressão
	oReport:SetCustomText( {|| AGRARCabec(oReport, @cNomeEmp, @cNmFil) } ) // Cabeçalho customizado
	
	//########### Início - Cabeçalho Reserva #######################
	nLin := oReport:Row()
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()
	oReport:PrtLeft(STR0002 + ": " + AllTrim(aArrayMast[1][11]) + "/" + AllTrim(aArrayMast[1][12]) + " - " + AllTrim(aArrayMast[1][3]) ) //"Cliente"
	oReport:SkipLine()
	oReport:PrtLeft(STR0003 + ": " + AllTrim(aArrayMast[1][4]) + "/" + AllTrim(aArrayMast[1][5])) //"Contrato"
	oReport:PrtCenter(STR0004 + ": " +  Substr(aArrayMast[1][6], 7, 2) + "/" + Substr(aArrayMast[1][6], 5, 2) + "/" + Substr(aArrayMast[1][6], 1, 4) ; //"Entrega De"
						+ " " + STR0005 + " " + Substr(aArrayMast[1][7], 7, 2) + "/" + Substr(aArrayMast[1][7], 5, 2) + "/" + Substr(aArrayMast[1][7], 1, 4)) //"a"
	oReport:SkipLine()
	oReport:PrtLeft(STR0006 + ": " + AllTrim(aArrayMast[1][8]) ) //"Take-Up"
	oReport:PrtCenter(STR0007 + ": " +  Day2Str(aArrayMast[1][9]) + "/" + Month2Str(aArrayMast[1][9]) + "/" + Year2Str(aArrayMast[1][9]) +  Space(12)) //"Efetuado Em"
	oReport:PrtRight(STR0008 + ": " +  AllTrim(aArrayMast[1][10]) +  Space(5)) //"Safra"
	oReport:SkipLine(2)
	nLin := oReport:Row()
	oReport:ThinLine()
	oReport:SkipLine(2)
	//########### FIM - Cabeçalho Reserva #######################
	
	//########### Início - Itens da Reserva #######################
	
	aArrayDet	:= UBAR007DET(aArrayMast[1][8]) // Query que retorna o array com os dados para os campos DXQ e DX7
	oSection1:Init() // Inicia a impressão da seção 1
	
	For nIt1 := 1 To Len(aArrayDet) // Popula as respectivas células com os dados provenientes do array
		For nIt2 := 1 To Len(_aCells)		
			If ValType(oSection1:Cell(_aCells[nIt2]:cName)) != 'U'
				If 	_aCells[nIt2]:cName == "DXQ_FILORG"
					oSection1:Cell(_aCells[nIt2]:cName):SetValue(Alltrim(aArrayDet[nIt1][nIt2]) + ' - ' + Alltrim(FWFilialName(cEmpAnt,aArrayDet[nIt1][nIt2],1))) //Origem (Filial)
				EndIf
				oSection1:Cell(_aCells[nIt2]:cName):SetValue(aArrayDet[nIt1][nIt2])
			EndIf			
		Next nIt2					
		oSection1:Printline()				
	Next nIt1
	
	oSection1:Finish() // Finaliza a seção 1
	
	//########### FIM - Itens da Reserva #######################
	
	//########### Início - Colunas Específicas #######################
	oReport:SkipLine()
	nLin := oReport:Row() // Pega a linha atual
	oReport:PrintText(STR0009,nLin,10)//"Origem"
	oReport:PrintText(STR0010,nLin,1200)  //"Tipo"	
   	oReport:PrintText(STR0012,nLin,1550)  //"Fardos"
   	oReport:PrintText(STR0013,nLin,1885)  //"Peso Bruto""
   	oReport:PrintText(STR0014,nLin,2232)  //""Peso Líquido" 
	oReport:SkipLine(1)
	oReport:FatLine()
	oReport:SkipLine()
	
	//########### Fim - Colunas Específicas #######################
	
	//########### Início - Total da Filial #######################
	
	aArrayTFL	:= UBAR007TFL(aArrayMast[1][8])
	
	For nIt1 := 1 To Len(aArrayTFL)
		cNomFil2 := Alltrim(aArrayTFL[nIt1][1]) + ' - ' + Alltrim(FWFilialName(cEmpAnt,aArrayTFL[nIt1][1],1))
		
		nLin := oReport:Row()	
		oReport:PrintText(STR0015 + " " + SUBSTR(cNomFil2, 1, 40) ,nLin,10) //"Total Filial"
		oReport:PrintText(TRANSFORM(aArrayTFL[nIt1][2],"@E 999999"),nLin,1550)  //Fardos
       oReport:PrintText(TRANSFORM(aArrayTFL[nIt1][3],"@E 999,999,999.99"),nLin,1770)  //Peso Bruto		
       oReport:PrintText(TRANSFORM(aArrayTFL[nIt1][4],"@E 999,999,999.99"),nLin,2140)  //Peso Liquido
		oReport:SkipLine(1)
	Next nIt1
	//
	oReport:SkipLine(1)
	oReport:ThinLine()
	//
	//########### FIM - Total da Filial #######################
	
	//########### Início - Totais por Tipo #######################
	aArrayTot	:= UBAR007Tot(aArrayMast[1][8])
	oReport:SkipLine(2)
	
	For nIt1 := 1 To Len(aArrayTot)
		nLin := oReport:Row()
		If nIt1 = 1 
			oReport:PrintText(STR0016,nLin,10) //"Totais por Tipo"
		End If
		oReport:PrintText(aArrayTot[nIt1][1],nlin,1200)  //Tipo
		oReport:PrintText(TRANSFORM(aArrayTot[nIt1][2],"@E 999999"),nLin,1550)  //Fardos
       oReport:PrintText(TRANSFORM(aArrayTot[nIt1][3],"@E 999,999,999.99"),nLin,1770)  //Peso Bruto		
       oReport:PrintText(TRANSFORM(aArrayTot[nIt1][4],"@E 999,999,999.99"),nLin,2140)  //Peso Liquido
		oReport:SkipLine(1)
	Next nIt1

	oReport:SkipLine(1)
	oReport:ThinLine()
	//########### FIM - Totais por Tipo #######################

	//########### Início - Rodapé #######################
	oReport:SkipLine(5)
	nLin := oReport:Row()
	oReport:PrintText(STR0017,nLin,50) //"Take-Up realizado mediante apresentação de listagem completa com resultados de HVI,"
	oReport:SkipLine(1)
	nLin := oReport:Row()
	oReport:PrintText(STR0018,nLin,50) // "cujas análises foram feitas em laboratórios credenciados."
	oReport:SkipLine(5)
			
	nLin := oReport:Row()
	oReport:PrintText(Replicate("_",50),nLin,50) 	
	oReport:PrintText(Replicate("_",50),nLin,1400) 	
	oReport:SkipLine(2)
	nLin := oReport:Row()
	oReport:PrintText(cNmClaCli,nLin,50) 			
	oReport:PrintText(cNmClaInt,nLin,1400) 			
	oReport:SkipLine(1)
	nLin := oReport:Row()
	oReport:PrintText(cCliente,nLin,50)
	oReport:PrintText(cNomeEmp,nLin,1400) 			

	//########### FIM - Rodapé #######################
	
Return Nil


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
	aCabec[2] += Space(7) // Meio
	aCabec[2] += Space(9) + RptFolha + TRANSFORM(oReport:Page(),'999999') // Direita

	// Linha 3
	AADD(aCabec, "SIGA /" + oReport:ReportName() + "/v." + cVersao) //Esquerda
	aCabec[3] += Space(7) + oReport:cRealTitle // Meio
	aCabec[3] += Space(9) + STR0020 +":" + Dtoc(dDataBase)   // Direita //"Dt.Ref:"

	// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	aCabec[4] += Space(7) // Meio
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

	// Linha 5
	AADD(aCabec, STR0021 +":" + cNmEmp) //Esquerda //"Empresa"
	aCabec[5] += Space(8) // Meio

Return aCabec

/*/{Protheus.doc} UBAR007QRY
//Monta o array com as informacoes da RESERVA
@author janaina.duarte
@since 31/03/2017
@version undefined

@type function
/*/
Static Function UBAR007QRY()

	Local aArrayMast	:= {}
   	Local cAliasNJR 	:= GetNextAlias()
	Local cQryNJR  	:= "" 
	Local cCliente	:= ""
		
	cQryNJR := "SELECT NJR_CODCTR, NJR_CODENT, NJR_LOJENT, NNY_ITEM, NNY_DATINI, NNY_DATFIM, NJ0_CODCLI, NJ0_LOJCLI"
	cQryNJR += " FROM "+ RetSqlName("NJR") + " NJRTMP"
	cQryNJR += " INNER JOIN " + retSqlName('NNY')+" NNYTMP" +" ON"
	cQryNJR += " NNYTMP.D_E_L_E_T_ = ''"
	cQryNJR += " AND NJRTMP.NJR_CODCTR = NNYTMP.NNY_CODCTR"
	cQryNJR += " AND NJRTMP.NJR_FILIAL = NNYTMP.NNY_FILIAL"
	cQryNJR += "  AND NNY_ITEM = '"+DXP->DXP_ITECAD+"' "  

	cQryNJR += " INNER JOIN " + retSqlName('NJ0')+" NJ0TMP" +" ON"
	cQryNJR += " NJ0TMP.D_E_L_E_T_ = ''"
	cQryNJR += " AND NJ0TMP.NJ0_CODENT = NJRTMP.NJR_CODENT"
   	cQryNJR += " AND NJ0TMP.NJ0_LOJENT = NJRTMP.NJR_LOJENT"	
	
	cQryNJR += " WHERE NJRTMP.D_E_L_E_T_ = ''"
	cQryNJR += " AND NJRTMP.NJR_FILIAL	= '"+xFilial("NJR")+"'"
	cQryNJR += " AND NJRTMP.NJR_CODCTR = '"+DXP->DXP_CODCTP+"'"
	
	If Select(cAliasNJR) > 0
		(cAliasNJR)->( dbCloseArea() )
	EndIf
		
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryNJR ), cAliasNJR, .F., .T. )

	//Seleciona a tabela 
	dbSelectArea(cAliasNJR)
	dbGoTop()
    
    cCliente   := Posicione('SA1',1,XFILIAL('SA1')+(cAliasNJR)->NJ0_CODCLI+(cAliasNJR)->NJ0_LOJCLI,'A1_NOME')
    
	aAdd( aArrayMast, { (cAliasNJR)->NJR_CODENT, (cAliasNJR)->NJR_LOJENT, cCliente, ;
					    (cAliasNJR)->NJR_CODCTR, (cAliasNJR)->NNY_ITEM, (cAliasNJR)->NNY_DATINI, (cAliasNJR)->NNY_DATFIM, ; 
					    DXP->DXP_CODIGO, DXP->DXP_DATTKP, DXP->DXP_SAFRA, (cAliasNJR)->NJR_CODENT,(cAliasNJR)->NJR_LOJENT  } )		
  	(cAliasNJR)->(DbCloseArea())
		
Return aArrayMast

/*/{Protheus.doc} UBAR007DET
//Monta o array com as informacoes dos itens da RESERVA
@author janaina.duarte
@since 31/03/2017
@version undefined

@type function
/*/
Static Function UBAR007DET(cReserva)

	Local aArrayDet 	:= {}
   	Local cAliasDXQ 	:= GetNextAlias()
	Local cQryDXQ  	:= ""
	Local cCellsCmp	:= ""
	Local cDXQGrp		:= ""
	Local nIt			:= 0
	Local aSepCmps	:= {}
	Local cSepCmps	:= "{"
	Local cAuxCmps	:= ""
	
	For nIt := 1 To Len(_aCells) // Monta os campos do SELECT com a Células definidas pelo Layout do TREPORT.		
		If "DX7" $ _aCells[nIt]:cName // Se forem Células da DX7 atribui a função AVG para média aritimética
			cCellsCmp 	+= "AVG(" + _aCells[nIt]:cName + ") AS " + _aCells[nIt]:cName
			cAuxCmps	+= _aCells[nIt]:cName
		Else
			cCellsCmp 	+= _aCells[nIt]:cName
			cAuxCmps	+= _aCells[nIt]:cName
			cDXQGrp	+= _aCells[nIt]:cName + ","
		EndIf
	
		If nIt != Len(_aCells)
			cCellsCmp 	+= ","
			cAuxCmps	+= ","
		EndIf		
	Next nIt
	
	aSepCmps := Separa(cAuxCmps, ",") // Monta o array com as células habilitadas
	
	cQryDXQ := "SELECT DXQ_ITEM," + cCellsCmp
	cQryDXQ += " FROM "+ RetSqlName("DXQ") + " DXQTMP"
	 
	cQryDXQ += " LEFT JOIN "+ RetSqlName("DXI") + " DXITMP ON"
	cQryDXQ += " DXITMP.DXI_BLOCO = DXQTMP.DXQ_BLOCO"
	cQryDXQ += " AND DXITMP.D_E_L_E_T_ = ''"
	cQryDXQ += " AND DXITMP.DXI_FILIAL = '"+xFilial("DXI")+"' "
	
	cQryDXQ += " LEFT JOIN "+ RetSqlName("DX7") + " DX7TMP ON"
	cQryDXQ += " DX7TMP.DX7_FARDO = DXITMP.DXI_CODIGO"
	cQryDXQ += " AND DX7TMP.D_E_L_E_T_ = ''"
	cQryDXQ += " AND DX7TMP.DX7_FILIAL = '"+xFilial("DX7")+"'"
	
	cQryDXQ += " WHERE DXQTMP.D_E_L_E_T_ = ''"
	cQryDXQ += " AND DXQTMP.DXQ_FILIAL = '"+xFilial("DXQ")+"'"	
	cQryDXQ += " AND DXQTMP.DXQ_CODRES = '"+cReserva+"'"
	cQryDXQ +=  Iif(!Empty(cDXQGrp) , " GROUP BY DXQ_ITEM," + Substr(cDXQGrp, 1, Len(cDXQGrp) - 1), "")
	cQryDXQ += " ORDER BY DXQ_ITEM"
	
	If Select(cAliasDXQ) > 0
		(cQryDXQ)->( dbCloseArea() )
	EndIf
		
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryDXQ ), cAliasDXQ, .F., .T. )

	//Seleciona a tabela 
	dbSelectArea(cAliasDXQ)
	dbGoTop()
    
   	For nIt := 1 To Len(aSepCmps) // Adiciona o Alias aos campos para uso posterior na montagem do array de retorno com os dados
   		cSepCmps += "(cAliasDXQ)->" + aSepCmps[nIt]  
   		If nIt != Len(aSepCmps)
   			cSepCmps += ","
   		EndIf
   	Next nIt
   	
   	cSepCmps += "}"
   	
	While (cAliasDXQ)->(!Eof()) // Monta o array com os dados da query
		aAux := &(cSepCmps)
		aAdd( aArrayDet, aAux )	
		
		(cAliasDXQ)->(DbSkip())
	EndDo
	
  	(cAliasDXQ)->(DbCloseArea())
		
Return aArrayDet

/*/{Protheus.doc} UBAR007TOT
//Monta o array com os totais por tipo
@author janaina.duarte
@since 31/03/2017
@version 1.0
@param cReserva, characters, descricao
@type function
/*/
Static Function UBAR007TOT(cReserva)

	Local aArrayTot 	:= {}
   	Local cAliasDXQ 	:= GetNextAlias()
	Local cQryDXQ  	:= "" 
		
	cQryDXQ := "SELECT DXQ_TIPO, SUM(DXQ_QUANT) AS QUANT, SUM(DXQ_PSBRUT) AS PSBRUT, SUM(DXQ_PSLIQU) AS PSLIQU"
	cQryDXQ += " FROM "+ RetSqlName("DXQ") + " DXQTMP"
	cQryDXQ += " WHERE DXQTMP.D_E_L_E_T_ = ''"
	cQryDXQ += " AND DXQTMP.DXQ_FILIAL = '"+xFilial("DXQ")+"'"
	cQryDXQ += " AND DXQTMP.DXQ_CODRES = '"+cReserva+"'"
	cQryDXQ += " GROUP BY DXQ_TIPO"
	
	If Select(cAliasDXQ) > 0
		(cQryDXQ)->( dbCloseArea() )
	EndIf
		
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryDXQ ), cAliasDXQ, .F., .T. )

	//Seleciona a tabela 
	dbSelectArea(cAliasDXQ)
	dbGoTop()
    
	While (cAliasDXQ)->(!Eof()) 

		aAdd( aArrayTot, { (cAliasDXQ)->DXQ_TIPO, (cAliasDXQ)->QUANT, ;
					    (cAliasDXQ)->PSBRUT, (cAliasDXQ)->PSLIQU} )	
		
		(cAliasDXQ)->(DbSkip())
	EndDo
	
  	(cAliasDXQ)->(DbCloseArea())
		
Return aArrayTot


/*/{Protheus.doc} UBAR007TFL
//Monta o array com os totais por filial
@author janaina.duarte
@since 03/04/2017
@version 1.0
@param cReserva, characters, descricao
@type function
/*/
Static Function UBAR007TFL(cReserva)

	Local aArrayTFL 	:= {}
   	Local cAliasDXQ 	:= GetNextAlias()
	Local cQryDXQ  	:= "" 
		
	cQryDXQ := "SELECT DXQ_FILORG, SUM(DXQ_QUANT) AS QUANT, SUM(DXQ_PSBRUT) AS PSBRUT, SUM(DXQ_PSLIQU) AS PSLIQU"
	cQryDXQ += " FROM "+ RetSqlName("DXQ") + " DXQTMP"
	cQryDXQ += " WHERE DXQTMP.D_E_L_E_T_ = ''"
	cQryDXQ += " AND DXQTMP.DXQ_CODRES = '"+cReserva+"'"
	cQryDXQ += " GROUP BY DXQ_FILORG"
	
	If Select(cAliasDXQ) > 0
		(cQryDXQ)->( dbCloseArea() )
	EndIf
		
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryDXQ ), cAliasDXQ, .F., .T. )

	//Seleciona a tabela 
	dbSelectArea(cAliasDXQ)
	dbGoTop()
    
	While (cAliasDXQ)->(!Eof()) 

		aAdd( aArrayTFL, { (cAliasDXQ)->DXQ_FILORG, (cAliasDXQ)->QUANT, ;
					    (cAliasDXQ)->PSBRUT, (cAliasDXQ)->PSLIQU} )	
		
		(cAliasDXQ)->(DbSkip())
	EndDo
	
  	(cAliasDXQ)->(DbCloseArea())
		
Return aArrayTFL
