#INCLUDE "JURRPAD024.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWPrintSetup.ch'
#INCLUDE "RPTDEF.CH"

Static __lAuto := .F. // Execu��o via automa��o de testes

//-------------------------------------------------------------------
/*/{Protheus.doc} JURRPAR024
Rotina para o processamento do relatorio em FWMSPRINTER.

@author Mauricio Canalle
@since 03/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURRPAD024(dDtIni, dDtFim, cEscritorio, cQuebra, cRelatorio, lAutomato, cNameAuto)
Local aArea := Getarea()

Local oFont14N := TFont():New("Times New Roman", 9, 14, .T., .T.)
Local oFont10  := TFont():New("Times New Roman", 9, 10, .T., .F.)
Local oFont09  := TFont():New("Courier New", 9, 07, .T., .F.)
Local oFont09N := TFont():New("Courier New", 9, 07, .T., .T.)
Local oFont10N := TFont():New("Times New Roman", 9, 08, .T., .T.)
Local oFont12N := TFont():New("Times New Roman", 9, 12, .T., .T.)

Local oPrint2
Local lAdjustToLegacy := .F. // Inibe legado de resolu��o com a TMSPrinter
Local nLargTxt 		  := 900 // largura em pixel para alinhamento da funcao sayalign
Local nLin            := 03
Local lNewPage        := .T. // controla pagina nova - salto de pagina
Local nCntPage        := 1  // contador de pagina     
Local cEscrit         := ''  // controle de quebra por escritorio
Local cDtCanc         := '' // controle de quebra por data de cancelamento
Local aTotEsc         := {0,0,0,0,0,0,0,0,0,0,0} // Total por escritorio
Local aTotGer         := {0,0,0,0,0,0,0,0,0,0,0} // Total Geral
Local nHonor          := 0
Local nImpostos       := 0
Local nDespesas       := 0
Local nHonorLiq       := 0
Local nTotGeral       := 0
Local nI              := 0
Local nCol            := 0
Local nCotacao        := 1
Local cMoeNac         := SuperGetMv("MV_JMOENAC",,"01")

Default lAutomato := .F.
Default cNameAuto := ""

	__lAuto := lAutomato

   	JA024QryRel(dDtIni, dDtFim, cEscritorio)   // query principal do relat�rio
	
	If !TMP->(Eof())
		If __lAuto //Alterar o nome do arquivo de impress�o para o padr�o de impress�o automatica
			oPrint2 := FWMsPrinter():New(cNameAuto, IMP_SPOOL,,, .T.,,,) // Inicia o relat�rio
			oPrint2:cPrinter   := "PDF" // Seta impress�o padr�o para n�o ocorrer o erro Runtime Printer.exe
			oPrint2:CFILENAME  := cNameAuto
			oPrint2:CFILEPRINT := oPrint2:CPATHPRINT + oPrint2:CFILENAME
		Else
			oPrint2 := FWMsPrinter():New(cRelatorio, IMP_PDF, lAdjustToLegacy,, .T.,,, "PDF" )
		EndIf

		oPrint2:SetResolution(78) // Tamanho estipulado
		oPrint2:SetLandscape()
		oPrint2:SetPaperSize(0, 210, 297 )   // tamanho da folha 
		oPrint2:SetMargin(10,10,10,10)
			
		While !TMP->(Eof())
		    If lNewpage  // NOVA PAGINA - cabecalho
		    	JA024NewPage(@nLin, oPrint2, oFont10N, oFont10, nLargTxt, oFont14N, dDtIni, dDtFim)
		    	
		    	lNewPage := .F.
		    Endif	

	        If cEscrit <> TMP->NXA_CESCR   // controle de quebra por escritorio     	
	        	oPrint2:Say(nlin, 001, STR0001+": "+TMP->NXA_CESCR+' - '+alltrim(Posicione('NS7', 1, xFilial('NS7')+TMP->NXA_CESCR, 'NS7_NOME')), oFont12N) // Escrit�rio
			
		       	nLin += 20
	        	
	        	cEscrit := TMP->NXA_CESCR
	        	cDtCanc := ''  // sempre que quebra o escritorio for�o a impressao da data de Cancelamento
	        Endif
	        
	        If cDtCanc <> TMP->NXA_DTCANC  // controle de quebra por data de cancelamento
				If !__lAuto
	        		oPrint2:Say(nlin, 001, STR0017+' '+dtoc(stod(TMP->NXA_DTCANC)), oFont10N) // Data de Cancelamento:
				Endif
		       	nLin += 15
	        	
	        	cDtCanc := TMP->NXA_DTCANC
	        Endif

			nCotacao := 1
			If TMP->NXA_CMOEDA <> cMoeNac  // MOEDA DIFERENTE DA MOEDA NACIONAL
				If CTP->(DbSeek(xFilial('CTP') + TMP->NXA_DTCANC + TMP->NXA_CMOEDA))
			       nCotacao := CTP->CTP_TAXA
			    Endif
			Endif
			
			nHonor    := (TMP->NXA_VLFATH + TMP->NXA_VLACRE - TMP->NXA_VLDESC) * nCotacao
			nImpostos := (TMP->NXA_IRRF + TMP->NXA_CSLL + TMP->NXA_PIS + TMP->NXA_COFINS) * nCotacao
			nDespesas := TMP->NXA_VLFATD * nCotacao

			nHonorLiq := IIf(nHonor > 0 .And. nHonor > nImpostos , nHonor - nImpostos, 0)
			nTotGeral := nHonor + nDespesas - nImpostos
			
			oPrint2:Say(nlin, 010, TMP->NXA_COD, oFont09)
			oPrint2:Say(nlin, 055, alltrim(TMP->NXA_CCLIEN)+'/'+alltrim(TMP->NXA_CLOJA)+'-'+alltrim(Posicione('SA1', 1, xFilial('SA1')+TMP->NXA_CCLIEN+TMP->NXA_CLOJA, 'A1_NREDUZ')), oFont09)
			oPrint2:Say(nlin, 215, Transform(TMP->NXA_VLFATH * nCotacao, '@e 999,999,999.99'), oFont09) // Honor. Bruto
			oPrint2:Say(nlin, 275, Transform(TMP->NXA_VLACRE * nCotacao, '@e 999,999,999.99'), oFont09) // Acr�scimo
			oPrint2:Say(nlin, 335, Transform(TMP->NXA_VLDESC * nCotacao, '@e 999,999,999.99'), oFont09) // Desconto
			oPrint2:Say(nlin, 395, Transform(nHonor,                     '@e 999,999,999.99'), oFont09) // Honor�rio
			oPrint2:Say(nlin, 455, Transform(TMP->NXA_IRRF * nCotacao,   '@e 999,999,999.99'), oFont09) // IRRF
			oPrint2:Say(nlin, 515, Transform(TMP->NXA_PIS * nCotacao,    '@e 999,999,999.99'), oFont09) // PIS
			oPrint2:Say(nlin, 575, Transform(TMP->NXA_COFINS * nCotacao, '@e 999,999,999.99'), oFont09) // COFINS
			oPrint2:Say(nlin, 635, Transform(TMP->NXA_CSLL * nCotacao,   '@e 999,999,999.99'), oFont09) // CSLL
			oPrint2:Say(nlin, 695, Transform(nHonorLiq,                  '@e 999,999,999.99'), oFont09) // Honor. L�quido
			oPrint2:Say(nlin, 755, Transform(TMP->NXA_VLFATD * nCotacao, '@e 999,999,999.99'), oFont09) // DESPESAS
			oPrint2:Say(nlin, 815, Transform(nTotGeral,                  '@e 999,999,999.99'), oFont09) // Total L�quido
			
			aTotEsc[01] += TMP->NXA_VLFATH * nCotacao
			aTotEsc[02] += TMP->NXA_VLACRE * nCotacao
			aTotEsc[03] += TMP->NXA_VLDESC * nCotacao
			aTotEsc[04] += nHonor
			aTotEsc[05] += TMP->NXA_IRRF * nCotacao
			aTotEsc[06] += TMP->NXA_PIS * nCotacao
			aTotEsc[07] += TMP->NXA_COFINS * nCotacao
			aTotEsc[08] += TMP->NXA_CSLL * nCotacao
			aTotEsc[09] += nHonorLiq
			aTotEsc[10] += TMP->NXA_VLFATD * nCotacao
			aTotEsc[11] += nTotGeral
						
			nLin += 15
				
			TMP->(DbSkip())
			
			If cEscrit <> TMP->NXA_CESCR   // total do escritorio
			   nLin += 5
			   
			   oPrint2:Line( nLin, 01, nLin, nLargTxt, CLR_BLACK, "-1")
			   
			   nLin += 15
			   nCol := 215
			   
			   For nI := 1 to Len(aTotEsc)
			       oPrint2:Say(nlin, nCol, Transform(aTotEsc[nI], '@e 999,999,999.99'), oFont09)
			       
			      nCol += 60
			       
			       aTotGer[nI] += aTotEsc[nI] 
			   Next
			   
			   aTotEsc := {0,0,0,0,0,0,0,0,0,0,0}
			   
			   nLin += 15
			   
			   If !TMP->(Eof()) .and. cQuebra == '1'   // quebra pagina por escritorio
			   		oPrint2:SayAlign(If(nLin > 580, nLin, 580), 01, Strzero(nCntPage, 3), oFont10, nLargTxt, 200, CLR_BLACK, 1, 0)  // numero da pagina
			   		oPrint2:EndPage() // Finaliza a p�gina
  		   
			   		nLin     := 03
			   		lNewPage := .T.
			   		nCntPage++
			   Endif    
			Endif
			
			// CONTROLE DE SALTO DE PAGINA
			If nLin >= 500 .or. TMP->(Eof()) 
			    If TMP->(Eof())  .and.  cQuebra == '2'   // total geral - sem quebra por escritorio
		           JA024ImpTot(@nLin, oPrint2, aTotGer, oFont09N, nLargTxt)   // imprime o total geral
			    Endif
			
				oPrint2:SayAlign(If(nLin > 580, nLin, 580), 01, Strzero(nCntPage, 3), oFont10, nLargTxt, 200, CLR_BLACK, 1, 0)  // numero da pagina
	       	
				oPrint2:EndPage() // Finaliza a p�gina
  		   
				nLin     := 03
				lNewPage := .T.
				nCntPage++
				
				// total geral - quebra por escritorio
				If TMP->(Eof()) .and. cQuebra == '1'
				   JA024NewPage(@nLin, oPrint2, oFont10N, oFont10, nLargTxt, oFont14N, dDtIni, dDtFim)
				   
				   JA024ImpTot(@nLin, oPrint2, aTotGer, oFont09N, nLargTxt)   // imprime o total geral
					If !__lAuto
						oPrint2:SayAlign(If(nLin > 580, nLin, 580), 01, Strzero(nCntPage, 3), oFont10, nLargTxt, 200, CLR_BLACK, 1, 0)  // numero da pagina
					EndIf
				   oPrint2:EndPage() // Finaliza a p�gina
				Endif
			Endif
		End
		
		oPrint2:Preview()
	Endif
	
	TMP->(DbCloseArea())
	
	RestArea(aArea)
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} JA024QryRel
Rotina para o processamento da query principal do relatorio em FWMSPRINTER.

@author Mauricio Canalle
@since 03/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA024QryRel(dDtIni, dDtFim, cEscritorio)
Local cQuery      := ""
Local aArea       := GetArea() 
Local TMP         := GetNextAlias()
Local lCpoGrosHon := NXA->(ColumnPos("NXA_VGROSH")) > 0 // @12.1.2310
 
 	cQuery := "SELECT NXA_CESCR, NXA_COD, NXA_CCLIEN, NXA_CLOJA, NXA_VLFATH + " + Iif(lCpoGrosHon, "NXA_VGROSH", "0") + " NXA_VLFATH, NXA_VLACRE, NXA_VLDESC, NXA_IRRF, NXA_PIS, NXA_COFINS, NXA_CSLL, NXA_VLFATD, NXA_DTCANC, NXA_CMOEDA"
 	cQuery += " FROM "+RetSqlName('NXA')
 	cQuery += " WHERE  NXA_FILIAL = '"+xFilial("NXA")+"' AND NXA_DTCANC >= '"+dtos(dDtIni)+"' AND NXA_DTCANC <= '"+dtos(dDtFim)+"' AND NXA_TIPO = 'FT' AND NXA_SITUAC ='2' AND D_E_L_E_T_ = ' '"
 	
 	If !empty(cEscritorio)
       cQuery += " AND NXA_CESCR = '"+cEscritorio+"'"	
 	Endif
 	
 	cQuery += " ORDER BY NXA_CESCR, NXA_DTCANC, NXA_COD"
    
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
     
	RestArea(aArea)
  
Return  

//-------------------------------------------------------------------
/*/{Protheus.doc} JA024ImpTot
Rotina para impress�o dos totais do relatorio em FWMSPRINTER.

@author Mauricio Canalle
@since 03/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA024ImpTot(nLin, oPrint2, aTotGer, oFont09N, nLargTxt)
Local nI
Local nCol := 215

    nLin += 20
			   
	oPrint2:Say(nlin, 055, STR0018, oFont09N)  // TOTAL GERAL
	For nI := 1 to Len(aTotGer)
		oPrint2:Say(nlin, nCol, Transform(aTotGer[nI], '@e 999,999,999.99'), oFont09N)
       
		nCol += 60
	Next
			   		
	nLin += 6	
	oPrint2:Line( nLin, 215, nLin, nLargTxt, CLR_BLACK, "-1")
	nLin += 3
	oPrint2:Line( nLin, 215, nLin, nLargTxt, CLR_BLACK, "-1")
   		
 Return

 
//-------------------------------------------------------------------
/*/{Protheus.doc} JA024NewPage
Rotina para impress�o de nova p�gina (cabe�alho) do relatorio em FWMSPRINTER.

@author Mauricio Canalle
@since 03/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA024NewPage(nLin, oPrint2, oFont10N, oFont10, nLargTxt, oFont14N, dDtIni, dDtFim)
    oPrint2:StartPage() // Inicia uma nova p�gina      
    
    nLin := 03
	If !__lAuto			
		oPrint2:Say(nlin, 001, dtoc(dDataBase), oFont10) 
	EndIf			
   	nLin += 15
			 
   	oPrint2:SayAlign( nLin, 01,  STR0002+" "+Posicione("CTO",1,xFilial("CTO")+SuperGetMv("MV_JMOENAC",,"01"),"CTO_SIMB"), oFont14N, nLargTxt, 200, CLR_BLACK, 2, 0 )  // FATURAS CANCELADAS EM
		    	
   	nLin += 15
	If !__lAuto
		oPrint2:Say(nLin+10, 001, STR0003+" "+ dtoc(dDtIni) + ' a ' + dtoc(dDtFim), oFont10) // Periodo:
	EndIf		    			    	
   	nLin += 15
		    	
   	oPrint2:Line( nLin, 01, nLin, nLargTxt, CLR_BLACK, "-1") 
		    	
   	nLin += 12
		    	
   	// Cabecalho
		    	
   	oPrint2:Say(nlin, 010, STR0004, oFont10N) // Fatura
   	oPrint2:Say(nlin, 055, STR0005, oFont10N) // Cliente
   	oPrint2:Say(nlin, 230, STR0006, oFont10N) // Honor. Bruto
   	oPrint2:Say(nlin, 298, STR0007, oFont10N) // Acr�scimo
   	oPrint2:Say(nlin, 360, STR0008, oFont10N) // Desconto
   	oPrint2:Say(nlin, 418, STR0009, oFont10N) // Honor�rio
   	oPrint2:Say(nlin, 490, STR0010, oFont10N) // IRRF
   	oPrint2:Say(nlin, 560, STR0011, oFont10N) // PIS
   	oPrint2:Say(nlin, 605, STR0012, oFont10N) // COFINS
   	oPrint2:Say(nlin, 672, STR0013, oFont10N) // CSLL
   	oPrint2:Say(nlin, 703, STR0014, oFont10N) // Honor. L�quido
   	oPrint2:Say(nlin, 784, STR0015, oFont10N) // Despesas
   	oPrint2:Say(nlin, 828, STR0016, oFont10N) // Total L�quido
		    	
   	nLin += 12
		    	
   	oPrint2:Line( nLin, 01, nLin, nLargTxt, CLR_BLACK, "-1") 
		    	
   	nLin += 12

Return

