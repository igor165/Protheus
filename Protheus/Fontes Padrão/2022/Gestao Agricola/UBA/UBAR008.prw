#INCLUDE "UBAR008.ch"
#include "protheus.ch"
#include "report.ch"

Static _cAliasRel := ""
Static _CRLF:= CHR(13)+CHR(10) 
Static _aCamposHVI := {}
Static _nMaxL := 3100
Static _aCabec := {}
Static _lCabec := .T.
Static _nPageWidth 	:= 118
Static _nPagina    := 0
//-------------------------------------------------------------------
/*/{Protheus.doc} UBAR008
Relatório Blocos Vinculados a Reserva 
@author Marcelo Ferrari
@since 30/06/2017
@version 1.0                                    
/*/
//-------------------------------------------------------------------
Function UBAR008(cQuery, cReserva)
	
	oReport:= ReportDef(cQuery,cReserva)
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef
//Definicoes do report e impressao do cabecalho
@author Marcelo Ferrari
@since 30/06/2017
@version 1.0
@type function
/*/
Static Function ReportDef(cQuery,cReserva)
	
	Local oReport	:= Nil
    Local aArUbar008 := GetArea()
    Local cNewQuery := Iif(!isBlind(),cQuery,cQueryUBA)   
    
    Default cReserva := Nil
    
    cNewQuery += " ORDER BY DXP.DXP_CLIENT, DXP.DXP_LJCLI, DXP.DXP_CODCTP "

	_cAliasRel := GetSqlAll(cNewQuery)
	dbSelectArea( "DXP" )
	DXP->( dbSetOrder( 1 ) )
	
    aAdd(_aCamposHVI , {"DX7_MIC", AgrTitulo("DX7_MIC")})
    aAdd(_aCamposHVI , {"DX7_RES", AgrTitulo("DX7_RES")})
    aAdd(_aCamposHVI , {"DX7_FIBRA", AgrTitulo("DX7_FIBRA")})
    aAdd(_aCamposHVI , {"DX7_UI", AgrTitulo("DX7_UI")})
    aAdd(_aCamposHVI , {"DX7_SFI", AgrTitulo("DX7_SFI")})
    aAdd(_aCamposHVI , {"DX7_ELONG", AgrTitulo("DX7_ELONG")})
    aAdd(_aCamposHVI , {"DX7_LEAF", AgrTitulo("DX7_LEAF")})
    aAdd(_aCamposHVI , {"DX7_AREA", AgrTitulo("DX7_AREA")})
    aAdd(_aCamposHVI , {"DX7_CSP", AgrTitulo("DX7_CSP")})
    aAdd(_aCamposHVI , {"DX7_CG", AgrTitulo("DX7_CG")})
    aAdd(_aCamposHVI , {"DX7_MAISB", AgrTitulo("DX7_MAISB")})
    aAdd(_aCamposHVI , {"DX7_RD", AgrTitulo("DX7_RD")})
    aAdd(_aCamposHVI , {"DX7_COUNT", AgrTitulo("DX7_COUNT")})
    aAdd(_aCamposHVI , {"DX7_UHM", AgrTitulo("DX7_UHM")})
    aAdd(_aCamposHVI , {"DX7_SCI", AgrTitulo("DX7_SCI")})

  	if Funname() = "OGC010"
		dbSeek( xFilial( "DXP" ) + cReserva )
	EndIf
	
	oReport := TReport():New("UBAR008", STR0001, , {|oReport| PrintReport(oReport)}, STR0001) //"Agenda Take-up / Blocos vinculados a reserva"
	oReport:SetPortrait(.T.) // Define a orientação default
	oReport:cFontBody := 'Courier New'
	oReport:HideParamPage()
	oReport:HideFooter() 
	oReport:SetTotalInLine(.F.)
	oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	oReport:nFontBody := 8 // Tamanho da fonte
	oReport:oPage:setPaperSize(9) // Seta a Folha para A4, porem não desabilita o campo
	oReport:HideHeader()
	
	DXP->(DbCloseArea())
	
	RestArea(aArUbar008)
	
Return oReport


/*/{Protheus.doc} PrintReport
//Impressao das linhas do relatorio
@author Marcelo Ferrari
@since 31/03/2017
@version 1.0
@param oReport, object, descricao
@type function
/*/
Static Function PrintReport(oReport)
	
	Local aArrayMast	:= UBAR008QRY()
	Local aArrayDet	    := {}
	Local aArrayTFL	    := {}
	Local aArrayTot	    := {}
	Local nLin 	:= 0
	Local nIt1  := 0
	Local nCab  := 0
	Local cNmClaCli 	:= ""
	Local cCliente  	:= ""
	Local cNmClaInt 	:= ""
	Local cNomeEmp      := ""
	Local cNmFil        := ""
	Local cNomFil1		:= ""
	Local cNomFil2		:= ""
	Local aColR         := {10, 400, 700, 1000, 1250, 1600, 1950} 
	Local aColC         := {10, 10, 580, 1600, 500, 850, 10, 1400, 2000, 10, 10}
	Local cFardaoAnt    := Nil
	//Local nH            := 0
	Local cTiposAcc     := ""
	Local cStr          := "" 
	Local nAc           := 0
	Local nMxC          := 0
	
	Local nCliFardo := 0 
	Local nCliPLiq  := 0
	Local nCliPBrut := 0

	Private _aTitCols   := {}
	
	_aCabec := AGRARCabec(oReport, @cNomeEmp, @cNmFil)
	//oReport:SetCustomText( {|| _aCabec } ) // Cabeçalho customizado
	PrintCabec()
	
	//########### Início - Cabeçalho Reserva #######################
	
	_aTitCols := {}
	//nLin := 7 //oReport:Row()
	For nCab := 2 to Len(aArrayMast)

/*MODELO DO CABEÇALHO
======================================================================================================================
Cliente: 000001/01 - CLIENTE 1 XWXWXWXWX XWXWXWXWXWX XWXWXWXWXWX
Contrato: 000017/001         Tipo Padrão: 10-2                                     Entrega de: 20/09/2017 a 22/12/2017
                             Tipos Aceitáveis : |21-1 (10%), 21-2 (7%), 21-3 (6%), 21-4 (5%),31-2 (0%), 31-3 (99%)   |
                                                |....se precisar adiciona mais linhas...                             |
Take-up: 000003              Agendamento para: dd/mm/yyyy hh:mm:ss       Efetuado em: 28/06/2017 15:31:16      
Class. Ext.: 000001 - CLASSIFICADOR 1                                                                      Safra: 2017
Class. Int.: 000002 - CLASSIFICADOR 2
----------------------------------------------------------------------------------------------------------------------        
Posições: 
 CLIENTE          = 10
 CONTRATO         = 10
 TIPO PADRÃO      = 500
   AGENDAM PARA   = 500
   ENTREGA DE     = 1750
 TIPOS ACEITÁVEIS = 500 
   1A LINHA       = 950....2100
   2A LINHA       = 950....2100  
 TAKE-UP          = 10
   EFETUADO EM    = 1250
   SAFRA          = 2000
 CLASSIFICADOR EXT= 10
 CLASSIFICADOR INT= 10
*/

		oReport:SkipLine()
		nLin := GetLinha(oReport)
		oReport:PrintText(Replicate("=", _nPageWidth), nLin, 10 )
		oReport:SkipLine(1)
		nLin := GetLinha(oReport)
		//"Cliente"
		cCliente := AllTrim(aArrayMast[1][3]) + ": " + AllTrim(aArrayMast[nCab][1]) + "/" + AllTrim(aArrayMast[nCab][2]) + " - " + AllTrim(aArrayMast[nCab][3])
		oReport:PrintText(cCliente, nLin, aColC[1])
		oReport:SkipLine()
		nLin := GetLinha(oReport)
		
		
		//"Contrato"
		cStr := AllTrim(aArrayMast[1][4]) + ": " + AllTrim(aArrayMast[nCab][4]) + "/" + AllTrim(aArrayMast[nCab][5])
		oReport:PrintText(cStr, nLin, aColC[2])
		
		//"Tipo Padrão"
		cStr := AllTrim(aArrayMast[1][18]) + ": " + AllTrim(aArrayMast[nCab][18])
		oReport:PrintText(cStr, nLin, aColC[3])
		nLin := GetLinha(oReport)

		//Entrega
		cStr := STR0004 + ": " + Substr(aArrayMast[nCab][6], 7, 2) + "/" + Substr(aArrayMast[nCab][6], 5, 2) + "/" + Substr(aArrayMast[nCab][6], 1, 4) ; //"Entrega De"
							   + " " + STR0005 + " " ;
							   + Substr(aArrayMast[nCab][7], 7, 2) + "/" + Substr(aArrayMast[nCab][7], 5, 2) + "/" + Substr(aArrayMast[nCab][7], 1, 4) //"a" 
        oReport:PrintText(cStr, nLin, aColC[4])
		oReport:SkipLine()
		nLin := GetLinha(oReport)

		oReport:PrintText(STR0023, nLin, aColC[5])  //Tipos opcionais
		
		//Monta texto Tipos opcionais
		aTpAc := aClone(aArrayMast[nCab][19])
		nMxC  := 76
		cStr  := ""
		cTiposAcc := ""
		cSep  := ", "
		For nAc := 1 to len(aTpAc)
		   cStr := aTpAc[nAc] + cSep  
		   If Len(cTiposAcc + cStr) <= nMxC
		      cTiposAcc += cStr
		   Else
		      cTiposAcc := "|" + cTiposAcc + Replicate(" ", nMxC - Len(cTiposAcc) - 2) + "|"
		      oReport:PrintText(cTiposAcc, nLin, aColC[6])
		      oReport:SkipLine()
		      nLin := GetLinha(oReport)		      
		      cTiposAcc := cStr
		   EndIF
		Next nAc 
		cTiposAcc := SubStr(cTiposAcc, 1, Len(cTiposAcc) - 2)  // Retira ", "
		cTiposAcc := "|" + cTiposAcc + Replicate(" ", nMxC - Len(cTiposAcc) - 2) + "|"
        oReport:PrintText(cTiposAcc, nLin, aColC[6])
		oReport:SkipLine()
		nLin := GetLinha(oReport)		      

		oReport:PrintText(STR0024, nLin, aColC[5]+240)  //HVI:

		//Monta texto HVI
		aTpHvi := aClone(aArrayMast[nCab][20])
		nMxC  := 76
		cStr  := ""
		cTiposHvi := ""
		cSep  := ", "
		For nAc := 1 to len(aTpHvi)
		   cStr := aTpHvi[nAc] + cSep  
		   If Len(cTiposHvi + cStr) <= nMxC
		      cTiposHvi += cStr
		   Else
		      cTiposHvi := "|" + cTiposHvi + Replicate(" ", nMxC - Len(cTiposHvi)-2) + "|"
		      oReport:PrintText(cTiposHvi, nLin, aColC[6])
		      oReport:SkipLine()
		      nLin := GetLinha(oReport)		      
		      cTiposHvi := cStr
		   EndIF
		Next nAc 
		cTiposHvi := SubStr(cTiposHvi, 1, Len(cTiposHvi) - 2)  // Retira ", "
		cTiposHvi := "|" + cTiposHvi + Replicate(" ", nMxC - Len(cTiposHvi) -2 ) + "|"
        oReport:PrintText(cTiposHvi, nLin, aColC[6])
		oReport:SkipLine()
		nLin := GetLinha(oReport)		      



		//"Take-Up" - Cod Reserva: 
		cStr := AllTrim(aArrayMast[1][8]) + AllTrim(aArrayMast[nCab][8])
		oReport:PrintText(cStr, nLin, aColC[7])
		
		
		//"Agendamento para" dd/mm/yyyy hh:mm:ss
		cStr := STR0007 + Day2Str(aArrayMast[nCab][9])   + "/" +  ;
		                  Month2Str(aArrayMast[nCab][9]) + "/" +  ;
		                  Year2Str(aArrayMast[nCab][9])  + " " +  ;
		                  aArrayMast[nCab][10]
		oReport:PrintText(cStr, nLin, aColC[3])


		//"Efetuado Em" dd/mm/yyyy hh:mm:ss
		cStr := STR0025 +  Day2Str(aArrayMast[nCab][11])   + "/" +  ;
		                   Month2Str(aArrayMast[nCab][11]) + "/" +  ;
		                   Year2Str(aArrayMast[nCab][11])  + " " +  ;
		                   aArrayMast[nCab][12]
		oReport:PrintText(cStr, nLin, aColC[8])

		oReport:SkipLine()
		nLin := GetLinha(oReport)	

		//"Nome Classificador Externo" (Cliente)
		cStr := AllTrim(aArrayMast[1][14]) + ": " + AllTrim(aArrayMast[nCab][14]) + " - " + AllTrim(aArrayMast[nCab][15])
		oReport:PrintText(cStr, nLin, aColC[10])

		//"Safra"
		cStr := AllTrim(aArrayMast[1][13]) + ": " +  AllTrim(aArrayMast[nCab][13])
		oReport:PrintText(cStr, nLin, aColC[9]) 

		oReport:SkipLine()
		nLin := GetLinha(oReport)
		
		//"Nome Classificador Interno"
		cStr := AllTrim(aArrayMast[1][16]) + ": " + AllTrim(aArrayMast[nCab][16]) + " - " + AllTrim(aArrayMast[nCab][17])
		oReport:PrintText(cStr, nLin, aColC[11])
		nLin := GetLinha(oReport)
		
		oReport:SkipLine()
		nLin := GetLinha(oReport)
		oReport:PrintText(Replicate("-", _nPageWidth), nLin,10)
		oReport:SkipLine()
		//########### FIM - Cabeçalho Reserva #######################
		
		//########### Início - Itens da Reserva #######################
		aArrayDet   := {}
		aArrayDet	:= UBAR008DET(aArrayMast[nCab][8])
		nLin := GetLinha(oReport) // Pega a linha atual
		oReport:PrintText(_aTitCols[1]  ,nLin, aColR[1])  //"Origem"
	    oReport:PrintText(_aTitCols[4]  ,nLin, aColR[2])  //"Bloco"
	    oReport:PrintText(_aTitCols[8]  ,nLin, aColR[3])  //"Safra"
	    oReport:PrintText(_aTitCols[9]  ,nLin, aColR[4])  //"Cl.Coml."
	    		
	    oReport:PrintText(_aTitCols[5]  ,nLin, aColR[5])  //"Fardos"
	    oReport:PrintText(_aTitCols[6]  ,nLin, aColR[6])  //"Peso Bruto""
	    oReport:PrintText(_aTitCols[7]  ,nLin, aColR[7])  //""Peso Líquido" 
		oReport:SkipLine()
		
		nLin := GetLinha(oReport)
		oReport:PrintText(Replicate("-", _nPageWidth), nLin,10)
		oReport:SkipLine()
	
		cFardaoAnt  := nil
		For nIt1 := 1 To Len(aArrayDet)
			//aColR         := {10, 400, 650, 850, 1250, 1500, 1800}
			cNomFil1 := Alltrim(aArrayDet[nIt1][1])
			nLin := GetLinha(oReport)		
			oReport:PrintText(cNomFil1          ,nLin, aColR[1])  //Origem (Filial)		
	        oReport:PrintText(aArrayDet[nIt1][4],nLin, aColR[2])  //Bloco
	
	        oReport:PrintText(aArrayDet[nIt1][8],nLin, aColR[3])  //Safra

	        cStr := ValidTipo( aArrayDet[nIt1][9], aArrayMast[nCab][19], aArrayMast[nCab][18])
	        oReport:PrintText(cStr, nLin, aColR[4]-50)  //Bloco

	        oReport:PrintText(aArrayDet[nIt1][9],nLin, aColR[4])  //Cl.Coml.
	        
	        oReport:PrintText(TRANSFORM(aArrayDet[nIt1][5] ,"@E 999999")      ,nLin, aColR[5])  //Fardos (Quantidade)
	        oReport:PrintText(TRANSFORM(aArrayDet[nIt1][6] ,"@E 9,999,999.99"),nLin, aColR[6])  //Peso Bruto
	        oReport:PrintText(TRANSFORM(aArrayDet[nIt1][7] ,"@E 9,999,999.99"),nLin, aColR[7])  //Peso Líquido 
	        oReport:SkipLine(1)
	        nLin := GetLinha(oReport)
	        
	        //Acumula os valores para o total do cliente
	        nCliFardo += aArrayDet[nIt1][5] 
	        nCliPLiq  += aArrayDet[nIt1][6]
	        nCliPBrut += aArrayDet[nIt1][7]
		Next nIt1

		IF Len(aArrayDet) = 0
		   	oReport:SkipLine(1)
	        nLin := GetLinha(oReport)
		EndIF

		If nCab <  Len(aArrayMast) 
			If aArrayMast[nCab][1] != aArrayMast[nCab+1][1] 
			   //Chama função que imprime informações do cabeçalho
			   UBAR008TCL(oReport, nCliFardo, nCliPLiq, nCliPBrut, aColR)
			   //Zera os valores dos totais
			   nCliFardo := 0 
	           nCliPLiq  := 0
	           nCliPBrut := 0
			EndIf
		EndIf

	Next nCab
	
	//Imprime o total do Cliente do último conjunto
	UBAR008TCL(oReport, nCliFardo, nCliPLiq, nCliPBrut, aColR)
	
	//########### FIM - Itens da Reserva #######################
	
	//########### Início - Total da Filial #######################
	oReport:SkipLine(1)
	nLin := GetLinha(oReport)
	oReport:PrintText(Replicate("_",_nPageWidth), nLin,10)
	//
	aArrayTFL	:= UBAR008TFL(aArrayMast)
	oReport:SkipLine(2)
	nLin := GetLinha(oReport)
	For nIt1 := 1 To Len(aArrayTFL)
		If nIt1 = 1 
			oReport:PrintText("          " + STR0015 + ": ",nLin,10)  //"Total Filial"
		End If
		cNomFil2 := Alltrim(aArrayTFL[nIt1][1]) + ' - ' + Alltrim(FWFilialName(cEmpAnt,aArrayTFL[nIt1][1],1))
		nLin := GetLinha(oReport)	
		oReport:PrintText(cNomFil2 ,nLin, 700)
		oReport:PrintText(TRANSFORM(aArrayTFL[nIt1][2],"@E 999999")        ,nLin, aColR[5])  //Fardos
        oReport:PrintText(TRANSFORM(aArrayTFL[nIt1][3],"@E 9,999,999.99")  ,nLin, aColR[6])  //Peso Bruto		
        oReport:PrintText(TRANSFORM(aArrayTFL[nIt1][4],"@E 9,999,999.99")  ,nLin, aColR[7])  //Peso Liquido
		oReport:SkipLine(1)
	Next nIt1
	nLin := GetLinha(oReport)
	oReport:PrintText(Replicate(".", _nPageWidth), nLin,10)
	//########### FIM - Total da Filial #######################
	
	//########### Início - Totais por Tipo #######################
	aArrayTot	:= UBAR008Tot(aArrayMast)
	oReport:SkipLine(1)
	For nIt1 := 1 To Len(aArrayTot)
		nLin := GetLinha(oReport)
		If nIt1 = 1 
			oReport:PrintText("          " + STR0016 + ": ",nLin,10) //"Totais por Tipo"
		End If
		oReport:PrintText(aArrayTot[nIt1][1],nlin,700)  //Tipo
		oReport:PrintText(TRANSFORM(aArrayTot[nIt1][2],"@E 999999")        ,nLin, aColR[5])//Fardos
        oReport:PrintText(TRANSFORM(aArrayTot[nIt1][3],"@E 9,999,999.99")  ,nLin, aColR[6])  //Peso Bruto		
        oReport:PrintText(TRANSFORM(aArrayTot[nIt1][4],"@E 9,999,999.99")  ,nLin, aColR[7]) //Peso Liquido
		oReport:SkipLine(1)
	Next nIt1
	nLin := GetLinha(oReport)
	oReport:PrintText(Replicate("_", _nPageWidth), nLin,10)
	//########### FIM - Totais por Tipo #######################

	If Funname() = "OGC010"
		//########### Início - Rodapé #######################
		oReport:SkipLine(5)
		nLin := GetLinha(oReport)
		oReport:PrintText(cNmClaCli,nLin,50) 			
		oReport:PrintText(cNmClaInt,nLin,1400) 			
		oReport:SkipLine(1)
		nLin := GetLinha(oReport)
		oReport:PrintText(cCliente,nLin,50)
		oReport:PrintText(cNomeEmp,nLin,1400)
		//########### FIM - Rodapé #######################
	EndIF
	
Return Nil


/*/{Protheus.doc} AGRARCabec
//Cabecalho customizado do report
@author Marcelo Ferrari
@since 30/06/2017
@version 1.0
@param oReport, object, descricao
@type function
/*/
Static Function AGRARCabec(oReport, cNmEmp , cNmFilial)
	Local aCabec := {}
	Local cChar	 := CHR(160)  // caracter dummy para alinhamento do cabeçalho
	Local cStr   := ""
	Local cStrE  := ""
	Local cStrM  := ""
	Local cStrD  := ""
	Local nHalfWidth := _nPageWidth / 2 

	If SM0->(Eof())
		SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	Endif

	cNmEmp	 := AllTrim( SM0->M0_NOME )
	cNmFilial:= AllTrim( SM0->M0_FILIAL )
	

	// Linha 1
	AADD(aCabec, "") // Esquerda

	// Linha 2 
	AADD(aCabec, cChar) //Esquerda
	cStr := RptFolha + TRANSFORM(oReport:Page(),'999999')
	aCabec[2] += Space(_nPageWidth - Len(cStr) - 1 ) + cStr // Direita

	// Linha 3
	cStrE := "SIGA /" + oReport:ReportName() + "/v." + cVersao  //Esquerda
	cStrM := oReport:cRealTitle // Meio
	cStrD := STR0017 +":" + Dtoc(dDataBase)   // Direita //"Dt.Ref:"
	cStr := cStrE + Space( nHalfWidth - ( len(cStrE) + (Len(cStrM)/2))) + cStrM + Space( nHalfWidth - ( Len(cStrD) + (Len(cStrM)/2))) + cStrD
	AADD(aCabec,  cStr)

	// Linha 4
	cStrE := RptHora + oReport:cTime    //Esquerda  
	cStrD := RptEmiss + oReport:cDate   // Direita
	cStr := cStrE + Space( _nPageWidth - (len(cStrE) + Len(cStrD) ) ) + cStrD
	AADD(aCabec, cStr ) 

	// Linha 5
	AADD(aCabec, STR0018 +":" + cNmEmp) //Esquerda //"Empresa"
    //AADD(aCabec, Replicate("_", _nPageWidth) )

Return aCabec

/*/{Protheus.doc} UBAR008QRY
//Monta o array com as informacoes da RESERVA
@author Marcelo Ferrari
@since 30/06/2017
@version undefined

@type function
/*/
Static Function UBAR008QRY()
	Local aArrayMast	:= {}
    Local cAliasNJR 	:= GetNextAlias()
	Local cQryNJR  	    := "" 
	Local cCliente		:= ""
	Local lSair := .T.
	Local cAliasLocal   := ""

	Local aTiposAce     := {}
	Local aTiposHVI     := {}
	Local cQryN7E       := ""
	Local cQryN7H       := ""
		
    if Funname() = "OGC020"
	   (_cAliasRel)->(DbGoTop())
	   cAliasLocal := _cAliasRel
	   lSair := .F.
	Else
	   cAliasLocal := "DXP"
	EndIf
	
	aArrayMast := {}
	While !((_cAliasRel)->(EOF())) 
	
		cQryNJR := "SELECT NJR_CODCTR, NJR_CODENT, NJR_LOJENT, NNY_ITEM, " 
		cQryNJR += " NNY_DATINI, NNY_DATFIM, NJ0_CODCLI, NJ0_LOJCLI, NJR_TIPALG "
		cQryNJR += " FROM "+ RetSqlName("NJR") + " NJRTMP"
		cQryNJR += " INNER JOIN " + retSqlName('NNY')+" NNYTMP" +" ON "
		cQryNJR += "     NNYTMP.D_E_L_E_T_ = ''"
		cQryNJR += " AND NJRTMP.NJR_CODCTR = NNYTMP.NNY_CODCTR"
		cQryNJR += " AND NJRTMP.NJR_FILIAL = NNYTMP.NNY_FILIAL"
		cQryNJR += "  AND NNY_ITEM = '"+(cAliasLocal)->DXP_ITECAD+"' "  
	
		cQryNJR += " INNER JOIN " + retSqlName('NJ0')+" NJ0TMP" +" ON "
		cQryNJR += "     NJ0TMP.D_E_L_E_T_ = ''"
		cQryNJR += " AND NJ0TMP.NJ0_CODENT = NJRTMP.NJR_CODENT"
	    cQryNJR += " AND NJ0TMP.NJ0_LOJENT = NJRTMP.NJR_LOJENT"	
		
		cQryNJR += " WHERE NJRTMP.D_E_L_E_T_ = ''"
		cQryNJR += " AND NJRTMP.NJR_FILIAL	= '"+xFilial("NJR")+"' "
		cQryNJR += " AND NJRTMP.NJR_CODCTR = '"+(cAliasLocal)->DXP_CODCTP+"' "
		
		If Select(cAliasNJR) > 0
			(cAliasNJR)->( dbCloseArea() )
		EndIf
			
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryNJR ), cAliasNJR, .F., .T. )
	
		//Seleciona a tabela 
		dbSelectArea(cAliasNJR)
		dbGoTop()

	    cCliente   := Posicione('SA1',1,XFILIAL('SA1')+(cAliasNJR)->NJ0_CODCLI+(cAliasNJR)->NJ0_LOJCLI,'A1_NOME')

	    if Funname() = "OGC010"
		   DXP->(dbSeek( xFilial( "DXP" ) + cReserva ))
	    EndIf
	    
	    If Funname() = "OGC020"
	       DXP->(dbSeek( xFilial( "DXP" ) + (_cAliasRel)->DXP_CODIGO ))	    
	    EndIf
	    
	    //Classificação aceitável do contrato
	    cQryN7E := GetSqlAll( "SELECT N7E_FILIAL, N7E_CODCTR, N7E_TIPACE, N7E_PERCEN, N7E_ORDEM " + ;
	                          " FROM " + retSqlName('N7E') + " N7E "  + ;
	                          " WHERE N7E_FILIAL = '"+xFilial("N7E")+"' " + ;
	                          " AND N7E_CODCTR = '" + (cAliasNJR)->NJR_CODCTR + "' " + ;
	                          " AND D_E_L_E_T_ = '' " + ;
	                          " ORDER BY N7E_ORDEM " )
	    
        aTiposAce := {}
        While !( (cQryN7E)->(EOF()) )
           aAdd(aTiposAce, (cQryN7E)->N7E_TIPACE + IIF( !Empty((cQryN7E)->N7E_PERCEN), " (" + AllTrim(STR((cQryN7E)->N7E_PERCEN))+"%)", "" ) )
           (cQryN7E)->(DbSkip())
        End	

        cQryN7H := GetSqlAll( "SELECT N7H_CAMPO, N7H_HVIDES, N7H_VLRINI, N7H_VLRFIM " + ;
                              " FROM " + retSqlName('N7H') + " N7H " + ;
                              " WHERE N7H_FILIAL = '"+xFilial("N7H")+"' " + ;
                              " AND N7H_CODCTR = '" + (cAliasNJR)->NJR_CODCTR + "' " + ;
                              " AND D_E_L_E_T_ = '' " + ; 
                              " ORDER BY N7H_ITEM " )

        aTiposHVI := {}
        While !( (cQryN7H)->(EOF()) )
           aAdd(aTiposHVI, AllTrim((cQryN7H)->N7H_HVIDES) + " (" + AllTrim(STR((cQryN7H)->N7H_VLRINI))+" - " + AllTrim(STR((cQryN7H)->N7H_VLRFIM)) + ")" )   
           (cQryN7H)->(DbSkip())
        End	

        //Adiciona o Titulo dos campos na primeira linha do array
	    If Empty(aArrayMast)
			aAdd(aArrayMast, {AgrTitulo("NJR_CODENT")   ;  //1
			                  , AgrTitulo("NJR_LOJENT") ;  
			                  , AgrTitulo("NJ0_CODCLI") ;
			                  , AgrTitulo("NJR_CODCTR") ;
			                  , AgrTitulo("NNY_ITEM")   ;  //5
			                  , AgrTitulo("NNY_DATINI") ;
			                  , AgrTitulo("NNY_DATFIM") ;
			                  , STR0002                 ; //AgrTitulo("DXP_CODIGO") - Cliente solicitou Cod Reserva
			                  , AgrTitulo("DXP_DATAGD") ;
			                  , AgrTitulo("DXP_HORAGD") ;  //10
			                  , AgrTitulo("DXP_DATTKP") ;
			                  , AgrTitulo("DXP_HORTKP") ;
			                  , AgrTitulo("DXP_SAFRA")  ;
			                  , AgrTitulo("DXP_CLAEXT") ;
			                  , AgrTitulo("NNA_NOME")   ;  //15
			                  , AgrTitulo("DXP_CLAINT") ;
			                  , AgrTitulo("NNA_NOME")   ;
			                  , AgrTitulo("NJR_TIPALG") ;
			                  , AgrTitulo("N7E_TIPACE") ;
			                  , STR0024 } )               //20 Qualidade Algodão
		EndIF

		aAdd( aArrayMast, { (cAliasNJR)->NJR_CODENT ;                    
		                    , (cAliasNJR)->NJR_LOJENT ;
		                    , cCliente ;
		                    , (cAliasNJR)->NJR_CODCTR ; 
		                    , (cAliasNJR)->NNY_ITEM ;
		                    , (cAliasNJR)->NNY_DATINI ; 
		                    , (cAliasNJR)->NNY_DATFIM ; 
		                    , DXP->DXP_CODIGO ;
		                    , DXP->DXP_DATAGD ; 
		                    , DXP->DXP_HORAGD ; 
		                    , DXP->DXP_DATTKP ;
		                    , DXP->DXP_HORTKP ;
		                    , DXP->DXP_SAFRA ;
		                    , DXP->DXP_CLAEXT ; 
		                    , Posicione("NNA",1,xFilial("NNA")+DXP->DXP_CLAEXT,"NNA_NOME") ;
		                    , DXP->DXP_CLAINT ;
		                    , Posicione("NNA",1,xFilial("NNA")+DXP->DXP_CLAINT,"NNA_NOME") ;
		                    , (cAliasNJR)->NJR_TIPALG ; 
		                    , aTiposAce, aTiposHVI } )		
	  	
	  	(cAliasNJR)->(DbCloseArea())
	  	
	  	If !(lSair)
	  	   (_cAliasRel)->(DbSkip())
	  	Else
	  	   //Quando _cAliasRel = "DXP" sai do while
	  	   Exit
	  	EndIf
	End	
		
Return aArrayMast

/*/{Protheus.doc} UBAR008DET
//Monta o array com as informacoes dos itens da RESERVA
@author Marcelo Ferrari
@since 30/06/2017
@version undefined

@type function
/*/
Static Function UBAR008DET(cReserva)

	Local aArrayDet 	:= {}
    Local cAliasDXQ 	:= GetNextAlias()
	Local cQryDXQ  	    := "" 

	cQryDXQ := "SELECT DISTINCT DXQ_FILORG, DXQ_ITEM, DXQ_TIPO, DXQ_BLOCO, DXQ_QUANT, "
	cQryDXQ +=                " DXQ_PSBRUT, DXQ_PSLIQU, DXD_SAFRA, DXD_CLACOM "
    cQryDXQ += " FROM " + RetSqlName("DXQ") + " DXQ " 
    cQryDXQ += " INNER JOIN " + RetSqlName("DXD") + " DXD ON DXQ.DXQ_BLOCO = DXD.DXD_CODIGO "
    cQryDXQ +=     " AND DXQ.DXQ_FILORG = DXD.DXD_FILIAL "
    cQryDXQ +=     " AND DXD.D_E_L_E_T_ = '' "
	cQryDXQ += " WHERE 1=1 "
	cQryDXQ += "  AND DXQ.DXQ_FILIAL = '"+xFilial("DXQ")+"' "
	cQryDXQ += "  AND DXQ.DXQ_CODRES = '"+cReserva+"' "
	cQryDXQ += "  AND DXQ.D_E_L_E_T_ = '' "
	cQryDXQ += " ORDER BY DXQ_FILORG, DXQ_BLOCO "
	
	If Select(cAliasDXQ) > 0
		(cQryDXQ)->( dbCloseArea() )
	EndIf
		
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryDXQ ), cAliasDXQ, .F., .T. )

	//Seleciona a tabela 
	dbSelectArea(cAliasDXQ)
	dbGoTop()
	While (cAliasDXQ)->(!Eof()) 
		aAdd( aArrayDet, { (cAliasDXQ)->DXQ_FILORG, (cAliasDXQ)->DXQ_ITEM,   ;
					       (cAliasDXQ)->DXQ_TIPO,   (cAliasDXQ)->DXQ_BLOCO,  ;
					       (cAliasDXQ)->DXQ_QUANT,  (cAliasDXQ)->DXQ_PSBRUT, ; 
					       (cAliasDXQ)->DXQ_PSLIQU, (cAliasDXQ)->DXD_SAFRA,  ;
					       (cAliasDXQ)->DXD_CLACOM, ;
					     } )
		(cAliasDXQ)->(DbSkip())
	EndDo

  	(cAliasDXQ)->(DbCloseArea())

    If Empty(_aTitCols)
		aAdd(_aTitCols, AgrTitulo("DXQ_FILORG"))
		aAdd(_aTitCols, AgrTitulo("DXQ_ITEM"))
		aAdd(_aTitCols, AgrTitulo("DXQ_TIPO"))
		aAdd(_aTitCols, AgrTitulo("DXQ_BLOCO"))
		aAdd(_aTitCols, AgrTitulo("DXQ_QUANT"))
		aAdd(_aTitCols, AgrTitulo("DXQ_PSBRUT"))
		aAdd(_aTitCols, AgrTitulo("DXQ_PSLIQU"))
		aAdd(_aTitCols, AgrTitulo("DXD_SAFRA"))
		aAdd(_aTitCols, AgrTitulo("DXD_CLACOM"))
	EndIF
		
Return aArrayDet

/*/{Protheus.doc} UBAR008TOT
//Monta o array com os totais por tipo
@author Marcelo Ferrari
@since 30/06/2017
@version 1.0
@param cReserva, characters, descricao
@type function
/*/
Static Function UBAR008TOT(aArrayMast)

	Local aArrayTot 	:= {}
    Local cAliasDXQ 	:= GetNextAlias()
	Local cQryDXQ  	    := "" 
	Local nI := 0
	Local cInCodReserva := ""

	For nI := 2 to Len(aArrayMast) - 1
	   cInCodReserva += "'" + aArrayMast[nI][8] + "',"
	Next nI	
	cInCodReserva += "'" + aArrayMast[Len(aArrayMast)][8] + "'"		
	cQryDXQ := "SELECT DXQ_TIPO, SUM(DXQ_QUANT) AS QUANT, SUM(DXQ_PSBRUT) AS PSBRUT, SUM(DXQ_PSLIQU) AS PSLIQU "
	cQryDXQ += " FROM "+ RetSqlName("DXQ") + " DXQTMP"
	cQryDXQ += " WHERE DXQTMP.D_E_L_E_T_ = ''"
	cQryDXQ += "   AND DXQTMP.DXQ_FILIAL = '"+xFilial("DXQ")+"' "
	cQryDXQ += "   AND DXQTMP.DXQ_CODRES IN ("+cInCodReserva+") "
	cQryDXQ += "   GROUP BY DXQ_TIPO "
	
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


/*/{Protheus.doc} UBAR008TFL
//Monta o array com os totais por filial
@author Marcelo Ferrari
@since 30/06/2017
@version 1.0
@param cReserva, characters, descricao
@type function
/*/
Static Function UBAR008TFL(aArrayMast)

	Local aArrayTFL 	:= {}
    Local cAliasDXQ 	:= GetNextAlias()
	Local cQryDXQ  	    := "" 
	Local nI := 0
	Local cInCodReserva := ""
	
	
	For nI := 2 to Len(aArrayMast) - 1
	   cInCodReserva += "'" + aArrayMast[nI][8] + "',"
	Next nI	
	cInCodReserva += "'" + aArrayMast[Len(aArrayMast)][8] + "'"
	cQryDXQ := "SELECT DXQ_FILORG, SUM(DXQ_QUANT) AS QUANT, SUM(DXQ_PSBRUT) AS PSBRUT, SUM(DXQ_PSLIQU) AS PSLIQU "
	cQryDXQ += " FROM "+ RetSqlName("DXQ") + " DXQTMP"
	cQryDXQ += " WHERE DXQTMP.D_E_L_E_T_ = ''"
	cQryDXQ += "   AND DXQTMP.DXQ_CODRES IN ( "+cInCodReserva+") "
	cQryDXQ += "   GROUP BY DXQ_FILORG "
	
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

/*/{Protheus.doc} UBAR008TCL
//Imprime o totalizador por cliente.
@author Marcelo Ferrari
@since 13/07/2017
@version 1.0
@param oReport,  nCliFardo, nCliPLiq, nClipBrut, aColR
@type function
/*/
Static Function UBAR008TCL(oReport, nCliFardo, nCliPLiq, nCliPBrut, aColR)
    Local nLin := 0

	//########### Início - Total da Filial #######################
	nLin := GetLinha(oReport)
	oReport:PrintText(Replicate("_",_nPageWidth), nLin,10)
	oReport:SkipLine(2)
	nLin := GetLinha(oReport)
	oReport:PrintText("          " + STR0006 + ": ",nLin,10)  //"Total CLIENTE"
	oReport:PrintText(TRANSFORM(nCliFardo ,"@E 999999")        ,nLin, aColR[5])  //Fardos
    oReport:PrintText(TRANSFORM(nCliPLiq  ,"@E 9,999,999.99")  ,nLin, aColR[6])  //Peso Bruto		
    oReport:PrintText(TRANSFORM(nCliPBrut ,"@E 9,999,999.99")  ,nLin, aColR[7])  //Peso Liquido
	oReport:SkipLine(1)

	nLin := GetLinha(oReport)
	oReport:PrintText(Replicate(".", _nPageWidth), nLin,10)
	//########### FIM - Total da Filial #######################
	
	nLin := GetLinha(oReport)
	oReport:PrintText(Replicate("_", _nPageWidth), nLin,10)
Return 


/*/{Protheus.doc} GetLinha
Retorna a linha corrente do report com ajuste para o cabeçalho da página
@author Marcelo Ferrari
@since 30/06/2017
@version 1.0
@param oReport 
@Return nL Integer
/*/
Static Function GetLinha(oReport)
   Local nL := oReport:Row()
   If nL + 10 > _nMaxL
      oReport:EndPage()
      oReport:SetStartPage(.T.)
      oReport:HideHeader()
      PrintCabec()
      nL := oReport:Row()
   EndIf
   
   If nL < 30
      oReport:SkipLine()
      nL := GetLinha(oReport)
   EndIf
Return nL 

/*/{Protheus.doc} PrintCabec
  Imprime o cabeçalho da página do relatório
@author Marcelo Ferrari
@since 30/06/2017
@version 1.0
@param  
@Return
/*/
Static Function PrintCabec()
   Local nI := 0
   Local cStartPath := GetSrvProfString("Startpath","")
   Local cNameFile  := ""
   Local cStr       := ""  

   cStartPath := AjuBarPath(cStartPath)
   cNameFile  := cStartPath+"lgrl"+cEmpAnt+cFilAnt+".bmp"
   If !File(cNameFile)
      cNameFile := cStartPath+"lgrl"+cEmpAnt+".bmp"
   Endif   
   If _lCabec 
	   oReport:SayBitmap(000,000, cNameFile, 150,045) // Tem que estar abaixo do RootPath
	   
	   // Linha 2 
	   _nPagina    := _nPagina + 1
	   cStr := RptFolha + TRANSFORM(_nPagina,'999999')
	   _aCabec[2] := Space(_nPageWidth - Len(cStr) - 1 ) + cStr // Direita
	   
	   For nI := 2 to len(_aCabec)
	      oReport:PrtLeft(_aCabec[nI])
	      oReport:Skipline(1)
	   Next nI
   Else
      _lCabec := .T.
   EndIf
   oReport:ThinLine()
   oReport:Skipline(1)
Return 

/*/{Protheus.doc} ValidTipo
  Valida o tipo do bloco com os tipos opcionais contrato 
@author Marcelo Ferrari
@since 30/06/2017
@version 1.0
@param  cTipo, aTpAC, aTpPdr
@Return cRet
/*/
Static Function ValidTipo( cTipo, aTpAc, cTpPdr)
   Local cRet := "*"
   Local lOk := .F.
   Local nI  := 0
   
   If cTipo != cTpPdr
      For nI := 1 TO LEN(aTpAc)
         If cTipo == aTpAc[nI]
            lOk := .T.
            cRet := " "
            Exit
         EndIf  
      Next nI
   Else
      cRet := " "
   EndIf
Return cRet
