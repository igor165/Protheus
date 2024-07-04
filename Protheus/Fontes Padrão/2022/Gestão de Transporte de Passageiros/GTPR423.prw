#INCLUDE 'Protheus.ch'
#INCLUDE 'GTPR423.CH'

Static lBOracle	:= Trim(TcGetDb()) = 'ORACLE'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPR423
(long_description)
@type function
@author Flavio Martins / Henrique Toyoda
@since 29/10/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Function GTPR423()

Private oReport := ReportDef()

If oReport <> Nil
	oReport:PrintDialog()
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
(long_description)
@type function
@author Flavio Martins / Henrique Toyoda
@since 29/10/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function ReportDef()

Local oReport := TReport():New("GTPR423" + "_" + StrTran(Time(), ":", ""), STR0002, "GTPR423", {|oReport| ReportPrint(oReport, cTmpGI2)}, STR0003)	// "Relatório DER"	### "Listará as quantidade por trecho x tarifas"	
Local cTmpGI2 := GetNextAlias()

oReport:SetLandscape()
oReport:HideParamPage()
		
If Pergunte(oReport:uParam, .T.)
	If Empty(MV_PAR01) .OR. (Empty(MV_PAR06) .And. Empty(MV_PAR07))
		Help(,,"Help", "GTPR423", STR0004 , 1, 0)	// "Favor, ao menos, preencher o código do orgão, a data inicial e/ou a data final."
		Return 
	EndIf				
			
	G423RetLin(@cTmpGI2)
	Return(oReport)
Else
	Alert(STR0005)	// "Cancelado pelo usuário."
EndIf
						
Return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
(long_description)
@type function
@author Flavio Martins / Henrique Toyoda
@since 29/10/2018
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport, cTmpGI2)

Local oArial10N  := TFont():New("Arial", 10, 10, , .T., , , , .T., .F.)	// Negrito	
Local oArial08N  := TFont():New("Arial", 08, 08, , .T., , , , .T., .F.)	// Negrito	
Local aTotais    := {0, 0, 0, 0, 0, 0, 0, 0, 0}	// Convencional:Ida,Volta | Multipla:Ida,Volta | Total:Ida,Volta | Parcial:Ida,Volta | TOTAIS
Local aInfs      := {}
Local nLnIni     := 200
Local nColIni    := 050
Local nLnFim     := 200
Local nColFim    := 2500
Local nVlTotal   := 0
Local nAlqICMS   := SuperGetMv("MV_GTPICM", , 12)
Local nAlqIASP   := SuperGetMv("MV_GTPIAS", ,  2)
Local nVlICMS    := 0
Local nVlIASP    := 0
Local nX         := 0
Local nTotOrd    := 0
Local nTotRT     := 0
Local nProx      := 0
Local cMedLot    := ''
Local cISento    := AllTrim(GTPGetRules("ISENTOIMP")) //Relação dos tipos de linhas com isenção de impostos
Local lSegLin    := .F.
Local lTerLin    := .F.
Local lLim       := .F.

(cTmpGI2)->(DbGoTop())
While !(cTmpGI2)->(Eof())
	If oReport:Cancel()
		Exit
	EndIf
	oReport:IncMeter()
	
	nLnIni   := 640
	nColIni  := 030
	nLnFim   := 200
	nColFim  := 2500
	
	// Retorna a média de lugares associado aos horários relacionados aos serviços dos bilhetes. 
	cMedLot	:= G423MedLot((cTmpGI2)->GI2_COD, MV_PAR06, MV_PAR07, 2)
	
	// array com os totais de cada tipo de viagem (ORDINARIAS/REFORÇO TOTAL)
	// viagens do tipo MULTIPLAS/REFORÇO PARCIAL sempre serão zeradas 
	G423TViag((cTmpGI2)->GI2_NUMLIN, MV_PAR06, MV_PAR07, @nTotOrd, @nTotRT)
	
	G423RetTrc((cTmpGI2)->GI2_NUMLIN, @aInfs, nTotOrd, nTotRT)

	ImprCabec(oReport, oArial10N, @cTmpGI2, cMedLot, nTotOrd, nTotRT)
		
	lLim     := .F.
	aTotais  := {{0, 0, 0, 0, 0, 0, 0, 0, 0}}
	nVlTotal := 0
	
	For nX := 1 To Len(aInfs)
		If nLnIni > (oReport:PageHeight()-320)
			oReport:EndPage()
			ImprCabec(oReport, oArial10N, @cTmpGI2, cMedLot, nTotOrd, nTotRT)
			nLnIni   := 0640
			nColIni  := 0030
			nLnFim   := 0200
			nColFim  := 2500
			lLim     := .F.
		ElseIf lLim
			nLnIni   := nLnIni + 180
		EndIf
		
		oReport:Box(nLnIni, nColIni,      nLnIni+180, nColIni+0500)	// Box Secao
		oReport:Box(nLnIni, nColIni+0500, nLnIni+180, nColIni+0700) // Valor Box Secao
		oReport:Box(nLnIni, nColIni+0700, nLnIni+180, nColIni+0900) // Valor ida Ordinaria
		oReport:Box(nLnIni, nColIni+0900, nLnIni+180, nColIni+1100) // Valor Volta Ordinaria
		oReport:Box(nLnIni, nColIni+1100, nLnIni+180, nColIni+1300) // Valor ida Multipla
		oReport:Box(nLnIni, nColIni+1300, nLnIni+180, nColIni+1500) // Valor Volta Multipla
		oReport:Box(nLnIni, nColIni+1500, nLnIni+180, nColIni+1700) // Valor ida Reforço total
		oReport:Box(nLnIni, nColIni+1700, nLnIni+180, nColIni+1900) // Valor Volta Reforço total
		oReport:Box(nLnIni, nColIni+1900, nLnIni+180, nColIni+2100) // Valor ida Reforço Parcial
		oReport:Box(nLnIni, nColIni+2100, nLnIni+180, nColIni+2300) // Valor Volta Reforço Parcial
		oReport:Box(nLnIni, nColIni+2300, nLnIni+180, nColIni+2500) // Valor VGM Reforço Parcial
		oReport:Box(nLnIni, nColIni+2500, nLnIni+180, nColIni+2700) // Valor Tarifa
		oReport:Box(nLnIni, nColIni+2700, nLnIni+180, nColIni+2900) // Valor Total 1
		oReport:Box(nLnIni, nColIni+2900, nLnIni+180, nColIni+3100) // Valor Total 2 
		oReport:Box(nLnIni, nColIni+3100, nLnIni+180, nColIni+3300) // Valor Total 3

		oReport:Say(nLnIni+050, nColIni+0050, AllTrim(aInfs[nX][5]) + " - " + aInfs[nX][3], oArial08N)	// Seção autorizada
		oReport:Say(nLnIni+100, nColIni+0050, AllTrim(aInfs[nX][6]) + " - " + aInfs[nX][4], oArial08N)	// Seção autorizada
		
		nProx  := IIF(nX == Len(aInfs), Len(aInfs), nX+1)
		nProx2 := IIF(nX == Len(aInfs), Len(aInfs), IIF(nX > (Len(aInfs)-2), Len(aInfs), nX+2))
		
		nLin1 := 080
		nLin2 := 000
		nLin3 := 000
		
		If AllTrim(aInfs[nX][5]) + AllTrim(aInfs[nX][6]) == AllTrim(aInfs[nProx][5]) + AllTrim(aInfs[nProx][6]) .And. AllTrim(aInfs[nX][13]) != AllTrim(aInfs[nProx][13])
			lSegLin := .T.
			nLin1 := 050
			nLin2 := 100
			nLin3 := 000
		EndIf
		
		If AllTrim(aInfs[nX][5]) + AllTrim(aInfs[nX][6]) == AllTrim(aInfs[nProx2][5]) + AllTrim(aInfs[nProx2][6]) .And. AllTrim(aInfs[nX][13]) != AllTrim(aInfs[nProx2][13])
			lTerLin := .T.
			nLin1 := 030
			nLin2 := 080
			nLin3 := 130
		EndIf
		
		oReport:Say(nLnIni+080  , nColIni+0560, AllTrim(aInfs[nX][13]), oArial08N)								// Cod Seção
		oReport:Say(nLnIni+nLin1, nColIni+0760, AllTrim(Str(aInfs[nX][9])), oArial08N)							// Ordinaria Ida
		oReport:Say(nLnIni+nLin2, nColIni+0760, AllTrim(IIF(lSegLin, Str(aInfs[nProx ][9]), "")), oArial08N)	// Ordinaria Ida//Segunda linha
		oReport:Say(nLnIni+nLin3, nColIni+0760, AllTrim(IIF(lTerLin, Str(aInfs[nProx2][9]), "")), oArial08N)	// Ordinaria Ida//terceira linha
		
		oReport:Say(nLnIni+nLin1, nColIni+0950, AllTrim(Str(aInfs[nX][10])), oArial08N)							// Ordinaria Volta
		oReport:Say(nLnIni+nLin2, nColIni+0950, AllTrim(IIF(lSegLin, Str(aInfs[nProx ][10]), "")), oArial08N)	// Ordinaria Volta//Segunda linha
		oReport:Say(nLnIni+nLin3, nColIni+0950, AllTrim(IIF(lTerLin, Str(aInfs[nProx2][10]), "")), oArial08N)	// Ordinaria Volta//terceira linha
		
		oReport:Say(nLnIni+nLin1, nColIni+1160, AllTrim(Str(0)), oArial08N)										// Multipla ida
		oReport:Say(nLnIni+nLin2, nColIni+1160, AllTrim(IIF(lSegLin, Str(0), "")), oArial08N)					// Multipla ida//Segunda linha
		oReport:Say(nLnIni+nLin3, nColIni+1160, AllTrim(IIF(lTerLin, Str(0), "")), oArial08N)					// Multipla ida//terceira linha
		
		oReport:Say(nLnIni+nLin1, nColIni+1350, AllTrim(Str(0)), oArial08N)										// Multipla Volta
		oReport:Say(nLnIni+nLin2, nColIni+1350, AllTrim(IIF(lSegLin, Str(0), "")), oArial08N)					// Multipla Volta//Segunda linha
		oReport:Say(nLnIni+nLin3, nColIni+1350, AllTrim(IIF(lTerLin, Str(0), "")), oArial08N)					// Multipla Volta//terceira linha
		
		oReport:Say(nLnIni+nLin1, nColIni+1560, AllTrim(Str(aInfs[nX][11])), oArial08N)							// Reforço Total Ida
		oReport:Say(nLnIni+nLin2, nColIni+1560, AllTrim(IIF(lSegLin, Str(aInfs[nProx ][11]), "")), oArial08N)	// Reforço Total Ida//Segunda linha
		oReport:Say(nLnIni+nLin3, nColIni+1560, AllTrim(IIF(lTerLin, Str(aInfs[nProx2][11]), "")), oArial08N)	// Reforço Total Ida//terceira linha
		
		oReport:Say(nLnIni+nLin1, nColIni+1750, AllTrim(Str(aInfs[nX][12])), oArial08N)							// Reforço Total Volta
		oReport:Say(nLnIni+nLin2, nColIni+1750, AllTrim(IIF(lSegLin, Str(aInfs[nProx ][12]), "")), oArial08N)	// Reforço Total Volta//Segunda linha
		oReport:Say(nLnIni+nLin3, nColIni+1750, AllTrim(IIF(lTerLin, Str(aInfs[nProx2][12]), "")), oArial08N)	// Reforço Total Volta//terceira linha
		
		oReport:Say(nLnIni+nLin1, nColIni+1960, AllTrim(Str(0)), oArial08N)										// Reforço Parcial Ida
		oReport:Say(nLnIni+nLin2, nColIni+1960, AllTrim(IIF(lSegLin, Str(0), "")), oArial08N)					// Reforço Parcial Ida//Segunda linha
		oReport:Say(nLnIni+nLin3, nColIni+1960, AllTrim(IIF(lTerLin, Str(0), "")), oArial08N)					// Reforço Parcial Ida//terceira linha
		
		oReport:Say(nLnIni+nLin1, nColIni+2150, AllTrim(Str(0)), oArial08N)										// Reforço Parcial Volta
		oReport:Say(nLnIni+nLin2, nColIni+2150, AllTrim(IIF(lSegLin, Str(0), "")), oArial08N)					// Reforço Parcial Volta//Segunda linha
		oReport:Say(nLnIni+nLin3, nColIni+2150, AllTrim(IIF(lTerLin, Str(0), "")), oArial08N)					// Reforço Parcial Volta//terceira linha
		
		oReport:Say(nLnIni+nLin1, nColIni+2360, AllTrim(Str(0)), oArial08N)										// VGM
		oReport:Say(nLnIni+nLin2, nColIni+2360, AllTrim(IIF(lSegLin, Str(0), "")), oArial08N)					// VGM//Segunda linha
		oReport:Say(nLnIni+nLin3, nColIni+2360, AllTrim(IIF(lTerLin, Str(0), "")), oArial08N)					// VGM//terceira linha
		
		oReport:Say(nLnIni+nLin1, nColIni+2550, Transform(aInfs[nX][7],	"@E 999,999.99"), oArial08N)									// Tarifa
		oReport:Say(nLnIni+nLin2, nColIni+2550, AllTrim(IIF(lSegLin, Transform(aInfs[nProx ][7], "@E 999,999.99"), "")), oArial08N)		// Tarifa//Segunda linha
		oReport:Say(nLnIni+nLin3, nColIni+2550, AllTrim(IIF(lTerLin, Transform(aInfs[nProx2][7], "@E 999,999.99"), "")), oArial08N)		// Tarifa//terceira linha

		oReport:Say(nLnIni+nLin1, nColIni+2760, AllTrim(Str(aInfs[nX][9] + aInfs[nX][10] + aInfs[nX][11] + aInfs[nX][12])), oArial08N)										//Totais(1)
		oReport:Say(nLnIni+nLin2, nColIni+2760, AllTrim(IIF(lSegLin, Str(aInfs[nProx ][9]+aInfs[nProx ][10]+aInfs[nProx ][11]+aInfs[nProx ][12]), "")), oArial08N)	//Totais(1)//Segunda linha
		oReport:Say(nLnIni+nLin3, nColIni+2760, AllTrim(IIF(lTerLin, Str(aInfs[nProx2][9]+aInfs[nProx2][10]+aInfs[nProx2][11]+aInfs[nProx2][12]), "")), oArial08N)	//Totais(1)//terceira linha
		
		oReport:Say(nLnIni+nLin1, nColIni+2960, AllTrim(Str(0)), oArial08N)										//Totais(2)
		oReport:Say(nLnIni+nLin2, nColIni+2960, AllTrim(IIF(lSegLin, Str(0), "")), oArial08N)					//Totais(2)//Segunda linha
		oReport:Say(nLnIni+nLin3, nColIni+2960, AllTrim(IIF(lTerLin, Str(0), "")), oArial08N)					//Totais(2)//terceira linha
		
		oReport:Say(nLnIni+nLin1, nColIni+3160, AllTrim(Str(0)), oArial08N)										//Totais(3)
		oReport:Say(nLnIni+nLin2, nColIni+3160, AllTrim(IIF(lSegLin, Str(0), "")), oArial08N)					//Totais(3)//Segunda linha
		oReport:Say(nLnIni+nLin3, nColIni+3160, AllTrim(IIF(lTerLin, Str(0), "")), oArial08N)					//Totais(3)//terceira linha
		
		aTotais[1][1] += aInfs[nX][09]
		aTotais[1][2] += aInfs[nX][10]
		aTotais[1][5] += aInfs[nX][11]
		aTotais[1][6] += aInfs[nX][12]
		aTotais[1][9] += aInfs[nX][09]+aInfs[nX][10]+aInfs[nX][11]+aInfs[nX][12]
		
		nVlTotal += ((aInfs[nX][09]+aInfs[nX][10]+aInfs[nX][11]+aInfs[nX][12]) * aInfs[nX][7])
		
		If lSegLin
			aTotais[1][1] += aInfs[nProx][09]
			aTotais[1][2] += aInfs[nProx][10]
			aTotais[1][5] += aInfs[nProx][11]
			aTotais[1][6] += aInfs[nProx][12]
			aTotais[1][9] += aInfs[nProx][09]+aInfs[nProx][10]+aInfs[nProx][11]+aInfs[nProx][12]
			nVlTotal += ((aInfs[nProx][09]+aInfs[nProx][10]+aInfs[nProx][11]+aInfs[nProx][12]) * aInfs[nProx][7])
		EndIf
		
		If lTerLin
			aTotais[1][1] += aInfs[nProx2][09]
			aTotais[1][2] += aInfs[nProx2][10]
			aTotais[1][5] += aInfs[nProx2][11]
			aTotais[1][6] += aInfs[nProx2][12]
			aTotais[1][9] += aInfs[nProx2][09]+aInfs[nProx2][10]+aInfs[nProx2][11]+aInfs[nProx2][12]
			nVlTotal += ((aInfs[nProx2][09]+aInfs[nProx2][10]+aInfs[nProx2][11]+aInfs[nProx2][12]) * aInfs[nProx2][7])
		EndIf
		
		nLnIni+= 180
	Next nX
	
	//----------------------------------------------------------------------------------------------------------------------
	//-----------------------------------TOTAL DA LINHA---------------------------------------------------------------------
	oReport:Box(nLnIni, nColIni,      nLnIni+80, nColIni+0500) // Box Secao
	oReport:Box(nLnIni, nColIni+0500, nLnIni+80, nColIni+0700) // Box Código Secao
	oReport:Box(nLnIni, nColIni+0700, nLnIni+80, nColIni+0900) // ida Ordinaria
	oReport:Box(nLnIni, nColIni+0900, nLnIni+80, nColIni+1100) // Volta Ordinaria
	oReport:Box(nLnIni, nColIni+1100, nLnIni+80, nColIni+1300) // ida Multipla
	oReport:Box(nLnIni, nColIni+1300, nLnIni+80, nColIni+1500) // Volta Multipla
	oReport:Box(nLnIni, nColIni+1500, nLnIni+80, nColIni+1700) // ida Reforço total
	oReport:Box(nLnIni, nColIni+1700, nLnIni+80, nColIni+1900) // Volta Reforço total
	oReport:Box(nLnIni, nColIni+1900, nLnIni+80, nColIni+2100) // ida Reforço Parcial
	oReport:Box(nLnIni, nColIni+2100, nLnIni+80, nColIni+2300) // Volta Reforço Parcial
	oReport:Box(nLnIni, nColIni+2300, nLnIni+80, nColIni+2500) // VGM Reforço Parcial
	oReport:Box(nLnIni, nColIni+2500, nLnIni+80, nColIni+2700) // Tarifa
	oReport:Box(nLnIni, nColIni+2700, nLnIni+80, nColIni+2900) // Total 1
	oReport:Box(nLnIni, nColIni+2900, nLnIni+80, nColIni+3100) // Total 2 
	oReport:Box(nLnIni, nColIni+3100, nLnIni+80, nColIni+3300) // Total 3
			
	oReport:Say(nLnIni+20, nColIni+0050, STR0018, oArial10N)	// "TOTAL DA LINHA"
			
	oReport:Say(nLnIni+20, nColIni+0700+0050, AllTrim(Str(aTotais[1][1])), oArial10N)	// Total ida Ordinaria         
	oReport:Say(nLnIni+20, nColIni+0900+0050, AllTrim(Str(aTotais[1][2])), oArial10N)	// Total Volta Ordinaria       
	oReport:Say(nLnIni+20, nColIni+1100+0050, AllTrim(Str(0))            , oArial10N)	// Total ida Multipla          
	oReport:Say(nLnIni+20, nColIni+1300+0050, AllTrim(Str(0))            , oArial10N)	// Total Volta Multipla        
	oReport:Say(nLnIni+20, nColIni+1500+0050, AllTrim(Str(aTotais[1][5])), oArial10N)	// Total ida Reforço total     
	oReport:Say(nLnIni+20, nColIni+1700+0050, AllTrim(Str(aTotais[1][6])), oArial10N)	// Total Volta Reforço total   
	oReport:Say(nLnIni+20, nColIni+1900+0050, AllTrim(Str(0))            , oArial10N)	// Total ida Reforço Parcial   
	oReport:Say(nLnIni+20, nColIni+2100+0050, AllTrim(Str(0))            , oArial10N)	// Total Volta Reforço Parcial 
	oReport:Say(nLnIni+20, nColIni+2300+0050, AllTrim(Str(0))            , oArial10N)	// Total VGM Reforço Parcial   
	oReport:Say(nLnIni+20, nColIni+2700+0050, AllTrim(Str(aTotais[1][9])), oArial10N)	// Total Total 1               
	oReport:Say(nLnIni+20, nColIni+2900+0050, AllTrim(Str(0))            , oArial10N)	// Total Total 2               
	oReport:Say(nLnIni+20, nColIni+3100+0050, AllTrim(Str(0))            , oArial10N)	// Total Total 3               
	
	If (nLnIni+370) > (oReport:PageHeight()-320)
		oReport:EndPage()
		oReport:StartPage()
		nLnIni := 250
	Else
		nLnIni += 80
	EndIf
	
	If (cTmpGI2)->GI2_TIPLIN $ cISento // Verifica se o tipo da linha é isento de impostos
		nAlqICMS := 0
		nAlqIASP := 0
	EndIf
		
	nVlICMS := (nVlTotal * nAlqICMS) / 100
	nVlIASP := ((nVlTotal - nVlICMS) * nAlqIASP) / 100
	
	//---------------------------------------------------------------------------------------------------------------------
	//-----------------------------------------------RECEITA TOTAL---------------------------------------------------------
	oReport:Box(nLnIni,     nColIni,      nLnIni+180, nColIni+2100) //Vazio
	oReport:Box(nLnIni,     nColIni+2100, nLnIni+180, nColIni+2700)	// Box Receita total
	oReport:Box(nLnIni+180, nColIni+2100, nLnIni+360, nColIni+2700)	// Box Receita liquida
	oReport:Box(nLnIni,     nColIni+2700, nLnIni+180, nColIni+3300)	// Box Valor receita total
	oReport:Box(nLnIni+180, nColIni+2700, nLnIni+360, nColIni+3300)	// Box Valor receita liquida
			
	oReport:Say(nLnIni+40 , nColIni+2100+0050, STR0019, oArial10N)											// "RECEITA TOTAL"
	oReport:Say(nLnIni+90 , nColIni+2100+0050, STR0020 + AllTrim(Str(nAlqICMS)) + "%)", oArial10N)			// "IMPOSTO A RECOLHER (ICMS "
	oReport:Say(nLnIni+220, nColIni+2100+0050, STR0022, oArial10N)											// "RECEITA LÍQUIDA"
	oReport:Say(nLnIni+270, nColIni+2100+0050, STR0023 + AllTrim(Str(nAlqIASP)) + "%)", oArial10N)			// "IMPOSTO A RECOLHER (IASP "
	oReport:Say(nLnIni+40 , nColIni+2700+0050, Transform(nVlTotal, "@E 999,999.99"), oArial10N)
	oReport:Say(nLnIni+90 , nColIni+2700+0050, Transform(nVlICMS , "@E 999,999.99"), oArial10N)
	oReport:Say(nLnIni+220, nColIni+2700+0050, Transform(nVlTotal-nVlICMS, "@E 999,999.99"), oArial10N)
	oReport:Say(nLnIni+270, nColIni+2700+0050, Transform(nVlIASP , "@E 999,999.99"), oArial10N)
			
	oReport:EndPage()
	(cTmpGI2)->(DbSkip())
	nTotOrd := 0
	nTotRT  := 0
EndDo	

oReport:Finish()
oReport:lNoPrint := .F.

(cTmpGI2)->(DbCloseArea())
		
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G423RetLin
Retorna as linhas cadastradas
@type function
@author Flavio Martins / Henrique Toyoda
@since 29/10/2018
@version 1.0
@param cTmpGI2, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Function G423RetLin(cTmpGI2)

Local cStatus := ''
Local cTpLin  := ''	
Local cFilGI1 := xFilial("GI1", xFilial("GI2"))

cTpLin := "%GI2.GI2_TIPLIN BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'%"
	
If MV_PAR08 == 1
	cStatus := "%GI2.GI2_MSBLQL = '2'%"
ElseIf MV_PAR08 == 2
	cStatus := "%GI2.GI2_MSBLQL = '1'%"
Else
	cStatus := "%GI2.GI2_MSBLQL IN ('1', '2')%"
EndIf
				
BeginSql Alias cTmpGI2
	SELECT GI2.GI2_FILIAL, GI2.GI2_COD, GI2.GI2_PREFIX, GI2.GI2_LOCINI, GI2.GI2_LOCFIM, GI2.GI2_NUMLIN, GI2.GI2_TIPLIN, 
	       GI2.GI2_CATEG, GI1ORI.GI1_DESCRI DESCORI, GI1ORI.GI1_CODINT CODINT_ORI, GI1DES.GI1_DESCRI DESCDES, GI1DES.GI1_CODINT CODINT_DES 
	FROM %Table:GI2% GI2 
	INNER JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %Exp:cFilGI1% AND GI1ORI.GI1_COD = GI2.GI2_LOCINI AND GI1ORI.%NotDel%
	INNER JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %Exp:cFilGI1% AND GI1DES.GI1_COD = GI2.GI2_LOCFIM AND GI1DES.%NotDel%
	WHERE GI2.GI2_FILIAL = %xFilial:GI2% AND 
	      GI2.GI2_COD = (SELECT MIN(GI2_COD) FROM %Table:GI2% GI22 WHERE GI22.GI2_NUMLIN = GI2.GI2_NUMLIN AND GI22.%NotDel%) AND 
	      GI2.GI2_NUMLIN BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05% AND 
	      GI2.GI2_HIST = '2' AND 
	      GI2.GI2_ORGAO = %Exp:MV_PAR01% AND 
	      %Exp:cStatus% AND 
	      %Exp:cTpLin% AND
	      GI2.%NotDel%
	ORDER BY GI2.GI2_FILIAL, REPLICATE('0', %Exp:TamSX3("GI2_NUMLIN")[1]% - LEN(GI2.GI2_NUMLIN)) + RTRIM(LTRIM(GI2.GI2_NUMLIN))		
EndSql
	
Return 

//------------------------------------------------------------------------------------------ 
/*/{Protheus.doc} G423RetTrc
(long_description)
@type function
@author Flavio Martins / Henrique Toyoda
@since 29/10/2018
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Function G423RetTrc(cNumLin, aInfs, nTotOrd, nTotRT)

Local aArea     := GetArea()
Local cAliasQry	:= GetNextAlias()
Local cAliasTar	:= ""
Local nPos		:= 0
Local nTarifa	:= 0
Local cStatus	:= ''
Local cCCS		:= ''
Local lExtra	:= .F.
Local cFilGI1   := xFilial("GI1", xFilial("GI2"))

Default nTotOrd := 0
Default nTotRT  := 0	

aInfs := {}

If MV_PAR09 == 1
	cStatus := "%GI4.GI4_MSBLQL = '2'%"
ElseIf MV_PAR09 == 2
	cStatus := "%GI4.GI4_MSBLQL = '1'%"
Else
	cStatus := "%GI4.GI4_MSBLQL IN ('1', '2')%"
EndIf
	
If MV_PAR10 == 1
	cCCS := "%GI4.GI4_CCS <> ''%"
ElseIf MV_PAR10 == 2
	cCCS := "%GI4.GI4_CCS = ''%"
Else
	cCCS := "%GI4.GI4_CCS = GI4.GI4_CCS%"
EndIf
	
BeginSql Alias cAliasQry
		SELECT T.SENTIDO, T.LINHA, T.TARIFA, T.LOCORI, T.LOCDES, T.CCS, T.DESCORI, T.DESCDES, T.CODINT_ORI, T.CODINT_DES, T.VIAGEM_EXTRA, T.DATA_VENDA, T.KM, T.HISTORICO, SUM(T.TOT_BILHETES) TOT_BILHETES
		FROM
			(
				SELECT CASE WHEN GI2_KMIDA > 0 THEN 'IDA' WHEN GI2_KMVOLT > 0 THEN 'VOLTA' END SENTIDO, 
				       GI4.GI4_LINHA LINHA, 
				       GI4.GI4_TAR TARIFA, 
				       GI4.GI4_LOCORI LOCORI, 
				       GI4.GI4_LOCDES LOCDES, 
				       CASE WHEN GI4.GI4_CCS = '' THEN '0' ELSE GI4.GI4_CCS END CCS, 
				       CASE WHEN GYN.GYN_EXTRA IS NULL THEN 'F' ELSE GYN.GYN_EXTRA END VIAGEM_EXTRA, 
				       GI1ORI.GI1_DESCRI DESCORI, 
				       GI1DES.GI1_DESCRI DESCDES, 
				       GI1ORI.GI1_CODINT CODINT_ORI, 
				       GI1DES.GI1_CODINT CODINT_DES, 
				       GIC.GIC_DTVEND DATA_VENDA,  
				       CASE WHEN GI2.GI2_KMIDA > 0 THEN GI2.GI2_KMIDA WHEN GI2.GI2_KMVOLT > 0 THEN GI2.GI2_KMVOLT END KM, 
				       G5G.G5G_VALOR AS HISTORICO, 
				       COUNT(GIC.GIC_CODIGO) TOT_BILHETES
				FROM %Table:GI2% GI2 
				INNER JOIN %Table:GI4% GI4 ON GI4.GI4_FILIAL = GI2.GI2_FILIAL AND 
				                              GI4.GI4_LINHA = GI2.GI2_COD AND 
				                              GI4.GI4_HIST = '2' AND 
				                              GI4.GI4_KM > 0 AND 
				                              %Exp:cStatus% AND 
				                              %Exp:cCCS% AND 
				                              GI4.%NotDel% 
				INNER JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %Exp:cFilGI1% AND 
				                                 GI1ORI.GI1_COD = GI4.GI4_LOCORI AND 
				                                 GI1ORI.%NotDel%
				INNER JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %Exp:cFilGI1% AND 
				                                 GI1DES.GI1_COD = GI4.GI4_LOCDES AND 
				                                 GI1DES.%NotDel%
				LEFT JOIN %Table:GIC% GIC ON GIC.GIC_FILIAL = GI2.GI2_FILIAL AND 
				                             GIC.GIC_LINHA  = GI2.GI2_COD AND 
				                             GIC.GIC_LOCORI = GI4.GI4_LOCORI AND 
				                             GIC.GIC_LOCDES = GI4.GI4_LOCDES AND 
				                             GIC.GIC_DTVEND BETWEEN %exp:Dtos(MV_PAR06)% AND %exp:Dtos(MV_PAR07)% AND 
											 (
											   (GIC.GIC_TIPO IN ('I', 'T', 'E', 'M') AND GIC.GIC_STATUS IN ('V', 'E', 'T') AND
											   GIC.GIC_CHVBPE = '') OR 
											   (GIC.GIC_TIPO IN ('P', 'W') AND GIC.GIC_STATUS = 'E' AND GIC.GIC_CHVBPE = '') OR
											   (GIC.GIC_CHVBPE <> '' AND GIC.GIC_STATUS = 'V')) AND
											   GIC.%NotDel%
				LEFT JOIN %Table:GYN% GYN ON GYN.GYN_FILIAL = GI2.GI2_FILIAL AND 
				                             GYN.GYN_CODIGO = GIC.GIC_CODSRV AND 
				                             GYN.%NotDel%
				LEFT JOIN  %Table:G5G% G5G ON G5G.G5G_FILIAL = GI2.GI2_FILIAL AND 
				                              G5G.G5G_CODLIN = GI2.GI2_COD AND 
				                              G5G.G5G_CODIGO = (SELECT MAX(G5G_CODIGO) 
				                                                FROM %Table:G5G% G5G2 
				                                                WHERE G5G2.G5G_FILIAL = GI2.GI2_FILIAL AND
				                                                	  G5G2.G5G_VIGENC <= CASE WHEN GIC.GIC_DTVEND IS NULL THEN %Exp:Dtos(MV_PAR07)% ELSE GIC.GIC_DTVEND END AND 
				                                                      G5G2.G5G_TPREAJ = '1' AND 
				                                                      G5G2.G5G_VIGENC != '' AND 
				                                                      G5G2.G5G_CODLIN = GI2.GI2_COD AND 
				                                                      ( 
				                                                        (G5G2.G5G_LOCORI = GI4.GI4_LOCORI AND G5G2.G5G_LOCDES = GI4.GI4_LOCDES) OR 
				                                                        (G5G2.G5G_LOCORI = GI4.GI4_LOCDES AND G5G2.G5G_LOCDES = GI4.GI4_LOCORI) 
				                                                      ) AND
				                                                      G5G2.%NotDel%
				                                               ) AND
				                              G5G.%NotDel%
				WHERE GI2.GI2_FILIAL = %xFilial:GI2% AND 
				      GI2.GI2_HIST   = '2' AND 
				      GI2.GI2_NUMLIN = %exp:cNumLin% AND 
				      (GI2.GI2_KMIDA > 0 OR GI2.GI2_KMVOLT > 0) AND 
				      GI2.%NotDel%
				GROUP BY GI4.GI4_LINHA, GI4.GI4_TAR, GI4.GI4_LOCORI, GI4.GI4_LOCDES, GI4.GI4_CCS, GYN.GYN_EXTRA, GIC.GIC_DTVEND, GI1ORI.GI1_DESCRI, GI1DES.GI1_DESCRI, GI1ORI.GI1_CODINT, GI1DES.GI1_CODINT, GI2.GI2_KMIDA, GI2.GI2_KMVOLT, G5G.G5G_VALOR
			) T 
		GROUP BY T.SENTIDO, T.LINHA, T.TARIFA, T.LOCORI, T.LOCDES, T.CCS, T.DESCORI, T.DESCDES, T.CODINT_ORI, T.CODINT_DES, T.DATA_VENDA, T.VIAGEM_EXTRA, T.KM, T.HISTORICO
		ORDER BY CAST(T.CCS AS NUMERIC(6,0)), T.LOCORI, T.LOCDES 	
EndSql
	 	
(cAliasQry)->(DbGoTop())
While !(cAliasQry)->(Eof())
	If !Empty((cAliasQry)->(HISTORICO))
		nTarifa := (cAliasQry)->HISTORICO
	Else
		cAliasTar := GetNextAlias()
		BeginSql Alias cAliasTar
			SELECT GIC_TAR TARIFA, COUNT(*) TOTAL
			FROM %Table:GIC% GIC 
			INNER JOIN %Table:GI2% GI2 ON GI2.GI2_COD = GIC.GIC_LINHA AND GI2.GI2_HIST = '2' AND GI2.GI2_NUMLIN = %Exp:cNumLin% AND GI2.%NotDel%
			WHERE GIC_FILIAL = %xFilial:GIC% AND 
			      GIC_DTVEND BETWEEN %Exp:Dtos(MV_PAR06)% AND %Exp:Dtos(MV_PAR07)% AND 
			      GIC_TIPO IN ('I', 'P', 'W') AND 
			      GIC_STATUS = 'V' AND
	              (
				    (GIC_LOCORI = %Exp:(cAliasQry)->LOCORI% AND GIC_LOCDES = %Exp:(cAliasQry)->LOCDES%) OR
					(GIC_LOCORI = %Exp:(cAliasQry)->LOCDES% AND GIC_LOCDES = %Exp:(cAliasQry)->LOCORI%)
				  )
			GROUP BY GIC_TAR 
			ORDER BY COUNT(*) DESC	
		EndSql

		(cAliasTar)->(DbGoTop())
		If !(cAliasTar)->(Eof())
			nTarifa := (cAliasTar)->TARIFA
		Else
			nTarifa := 0
		EndIf
		(cAliasTar)->(DbCloseArea())
	EndIf
		
	If nTarifa == 0
		nTarifa := (cAliasQry)->TARIFA
	EndIf

	lExtra := ((cAliasQry)->VIAGEM_EXTRA == 'T') .And. nTotRT > 0
	If (nPos := aScan(aInfs, {|x| x[15] == PadL(AllTrim((cAliasQry)->CCS), 4, "0")})) == 0
			
		If AllTrim((cAliasQry)->SENTIDO) == "IDA"
 			aAdd(aInfs, {(cAliasQry)->LOCORI, ; 						// Cod. Localidade Origem
 						 (cAliasQry)->LOCDES, ; 						// Cod. Localidade Destino
						 (cAliasQry)->DESCORI, ; 						// Descrição Origem
						 (cAliasQry)->DESCDES, ;				 		// Descrição Destino
						 (cAliasQry)->CODINT_ORI, ;						// Cod. Int. Origem 
						 (cAliasQry)->CODINT_DES, ;					 	// Cod. Int. Destino
					     nTarifa, ;										// Tarifa
						 lExtra, ;										// Viagem Extra
						 IIF(lExtra, 0, (cAliasQry)->TOT_BILHETES), ; 	// Total Bilhetes Ida
						 0, ;											// Total Bilhetes Volta	
						 IIF(lExtra, (cAliasQry)->TOT_BILHETES, 0), ; 	// Total Bilhetes Reforço Total Ida
						 0, ;											// Total Bilhetes Reforço Total Volta
						 (cAliasQry)->CCS, ;							// CCS
						 (cAliasQry)->KM, ;								// KM
						 PadL(AllTrim((cAliasQry)->CCS), 4, "0")})							
		Else
 			aAdd(aInfs, {(cAliasQry)->LOCORI, ; 						// Cod. Localidade Origem
 						 (cAliasQry)->LOCDES, ; 						// Cod. Localidade Destino
						 (cAliasQry)->DESCORI, ; 						// Descrição Origem
						 (cAliasQry)->DESCDES, ; 						// Descrição Destino
						 (cAliasQry)->CODINT_ORI, ;						// Cod. Int. Origem 
						 (cAliasQry)->CODINT_DES, ;				 		// Cod. Int. Destino
						 nTarifa, ;										// Tarifa
						 lExtra, ;										// Viagem Extra
						 0, ; 											// Total Bilhetes Ida
						 IIF(lExtra, 0, (cAliasQry)->TOT_BILHETES), ;	// Total Bilhetes Volta	
						 0, ; 											// Total Bilhetes Reforço Total Ida
						 IIF(lExtra, (cAliasQry)->TOT_BILHETES, 0), ;	// Total Bilhetes Reforço Total Volta
						 (cAliasQry)->CCS, ;							// CCS
						 (cAliasQry)->KM, ;								// KM
						 PadL(AllTrim((cAliasQry)->CCS), 4, "0")})	
		EndIf 
 			
	Else
		If AllTrim((cAliasQry)->SENTIDO) == "IDA"
			If !(lExtra)
				aInfs[nPos][9] += (cAliasQry)->TOT_BILHETES // Total Bilhetes Ordinarias Ida
			Else
				aInfs[nPos][11] += (cAliasQry)->TOT_BILHETES // Total Bilhetes Reforço Total Ida
			EndIf
		Else
			If !(lExtra)
				aInfs[nPos][10] += (cAliasQry)->TOT_BILHETES // Total Bilhetes Ordinárias Volta
			Else
				aInfs[nPos][12] += (cAliasQry)->TOT_BILHETES // Total Bilhetes Reforço Total Volta
			EndIf
		EndIf 	
	EndIf 
		
	(cAliasQry)->(DbSkip())			
EndDo
 	
(cAliasQry)->(DbCloseArea()) 	

RestArea(aArea)

Return

//------------------------------------------------------------------------------------------ 
/*/{Protheus.doc} G425MedLot
Retorna a média de lugares associado ao horários relacionados ao serviços dos bilhetes.
@type function
@author Flavio Martins / Henrique Toyoda
@since 29/10/2018
@version 1.0
@param cLinhaAtu, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------  
Function G423MedLot(cLinhaAtu, dDtIni, dDtFim, nOpc)
Local aArea    := GetArea()
Local cTmpGID  := GetNextAlias()
Local nLugares := 0
	 
BeginSql Alias cTmpGID

	SELECT AVG(GID.GID_LOTACA) LUGARES
	FROM %Table:GI2% GI2
	INNER JOIN %Table:GID% GID ON GID.GID_FILIAL = %xFilial:GID%
		AND GID.GID_LINHA = GI2.GI2_COD
		AND GID.GID_HIST = '2'
		AND GID.%NotDel%
	WHERE GI2.GI2_FILIAL = %xFilial:GI2%
		AND GI2.GI2_COD = %Exp:cLinhaAtu%
		AND GI2.GI2_HIST = '2'
		AND GI2.%NotDel%

EndSql
 	
If nOpc == 2 .And. !(cTmpGID)->(Eof()) 
	nLugares := (cTmpGID)->LUGARES
EndIf

(cTmpGID)->(DbCloseArea())

RestArea(aArea)
 	
Return AllTrim(Str(Round(nLugares, 0)))

//------------------------------------------------------------------------------------------  
/*/{Protheus.doc} G423TViag(cNumLin, dDtIni, dDtFim, @nTotOrd, nTotRT)
Retorna o total de viagens para aquela linha e periodo informado.
@type function
@author Flavio Martins
@since 29/10/2018
@version 1.0
@param cLinhaAtu, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/ 
//------------------------------------------------------------------------------------------  
Function G423TViag(cNumLin, dDtIni, dDtFim, nTotOrd, nTotRT)

Local aArea     := GetArea() 
Local cTmpViag	:= GetNextAlias()
Local nTotOrd   := 0
Local nTotRT    := 0 
Local lTemBilhe := G423TBilhe(cNumLin, dDtIni, dDtFim)

BeginSql Alias cTmpViag
	SELECT GYN.GYN_CODIGO, GYN.GYN_EXTRA, COUNT(DISTINCT(GYN.GYN_CODIGO)) TOT_VIAGENS
	FROM %Table:GI2% GI2
	LEFT JOIN %Table:GYN% GYN ON GYN.GYN_FILIAL = GI2.GI2_FILIAL AND GYN.GYN_LINCOD = GI2.GI2_COD AND GYN.%NotDel%
	WHERE GI2_FILIAL = %xFilial:GI2% AND 
	      GI2.GI2_HIST = '2' AND 
	      GI2.GI2_NUMLIN = %Exp:cNumLin% AND
	      GYN.GYN_DTINI BETWEEN %Exp:Dtos(dDtIni)% AND %Exp:Dtos(dDtFim)% AND  
	      GI2.%NotDel%
	GROUP BY GYN.GYN_CODIGO, GYN.GYN_EXTRA
	HAVING GYN.GYN_EXTRA IS NOT NULL		 		
EndSql
	
If !(cTmpViag)->(Eof())
	While !(cTmpViag)->(Eof())
		If (cTmpViag)->GYN_EXTRA != 'T'
			nTotOrd++		// Total de viagens ORDINARIAS
		Else
			If lTemBilhe
				nTotRT++		// Total de viagens REFORCO TOTAL
			EndIf
		EndIf
		(cTmpViag)->(DbSkip())
	EndDo
EndIf
(cTmpViag)->(DbCloseArea())

RestArea(aArea)
 	
Return

//------------------------------------------------------------------------------------------  
/*/{Protheus.doc} G423TBilhe(cNumLin, dDtIni, dDtFim )
Retorna se há bilhetes para a linha no período informado em viagens extras.
@type function
@author Flavio Martins
@since 29/10/2018
@version 1.0
@param cLinhaAtu, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/ 
//------------------------------------------------------------------------------------------  
Function G423TBilhe(cNumLin, dDtIni, dDtFim)

Local aArea     := GetArea() 
Local cTmpBilhe := GetNextAlias()
Local lTemBilhe := .F.

BeginSql Alias cTmpBilhe
	SELECT COUNT(GI2.GI2_COD) BILHETES 
	FROM %Table:GI2% GI2
	INNER JOIN %Table:GYN% GYN ON GYN.GYN_FILIAL = GI2.GI2_FILIAL AND GYN.GYN_LINCOD = GI2.GI2_COD AND GYN.%NotDel%
	INNER JOIN %Table:GIC% GIC ON GIC.GIC_FILIAL = GI2.GI2_FILIAL AND GIC.GIC_LINHA  = GI2.GI2_COD AND GIC.%NotDel%
	WHERE GI2.GI2_FILIAL = %xFilial:GI2% AND
		  GI2.GI2_NUMLIN = %Exp:cNumLin% AND 
          GI2.GI2_HIST   = '2' AND
	      GYN.GYN_DTINI BETWEEN %Exp:Dtos(dDtIni)% AND %Exp:Dtos(dDtFim)% AND
	      GIC.GIC_CODSRV = GYN.GYN_CODIGO AND
          GIC.GIC_DTVEND BETWEEN %Exp:Dtos(dDtIni)% AND %Exp:Dtos(dDtFim)% AND 
          ( 
	         (GIC.GIC_TIPO IN ('I', 'T', 'E', 'M') AND GIC.GIC_STATUS IN ('V', 'E', 'T') AND GIC.GIC_CHVBPE = '') OR 
	         (GIC.GIC_TIPO IN ('P', 'W') AND GIC.GIC_STATUS = 'E' AND GIC.GIC_CHVBPE = '') OR
			 (GIC.GIC_CHVBPE <> '' AND GIC.GIC_STATUS = 'V')
	      ) AND GI2.%NotDel%  
EndSql
	
If !(cTmpBilhe)->(Eof()) .And. (cTmpBilhe)->BILHETES > 0 
	lTemBilhe := .T.
EndIf
(cTmpBilhe)->(DbCloseArea())

RestArea(aArea)

Return lTemBilhe

 //------------------------------------------------------------------------------------------  
/*/{Protheus.doc} ImprCabec(oReport, cTmpGI2, cMedLot, aTotViag)
Imprime o cabeçalho do relatório
@type function
@author Flavio Martins / Henrique Toyoda
@since 29/10/2018
@version 1.0
@param cLinhaAtu, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/ 
//------------------------------------------------------------------------------------------  
Static Function ImprCabec(oReport, oArial10N, cTmpGI2, cMedLot, nTotOrd, nTotRT)

Local cDescrLin	:= IIF(!(cTmpGI2)->(Eof()), AllTrim((cTmpGI2)->GI2_PREFIX) + ' - ' + AllTrim((cTmpGI2)->DESCORI) + '/' + AllTrim((cTmpGI2)->DESCDES), "")
Local cNumLin	:= (cTmpGI2)->GI2_NUMLIN
Local cPerRef   := DtoC(MV_PAR06) + STR0025 + DtoC(MV_PAR07)	// " até "
Local nLnIni	:= 250
Local nColIni	:= 030

oReport:StartPage()

oReport:Box(nLnIni, nColIni, nLnIni+250, nColIni+2700)
oReport:Box(nLnIni, nColIni+2700, nLnIni+250, nColIni+3300)

oReport:Say(nLnIni+50 , nColIni+50  , STR0024 + cPerRef  , oArial10N) 		// "Período de Referência: "   
oReport:Say(nLnIni+110, nColIni+50  , STR0006 + cDescrLin, oArial10N) 		// "Linha: "
oReport:Say(nLnIni+110, nColIni+2500, STR0007 + cMedLot  , oArial10N)   	// "Lotação: "
oReport:Say(nLnIni+170, nColIni+50  , STR0026 + cNumLin  , oArial10N)		// "Número da linha: "

oReport:Say(nLnIni+30,  nColIni+2720, STR0016, oArial10N)					// "ORDINÁRIAS "
oReport:Say(nLnIni+70,  nColIni+2720, STR0028, oArial10N)					// "MÚLTIPLAS "
oReport:Say(nLnIni+110, nColIni+2720, STR0008, oArial10N)					// "REFORÇO TOTAL "
oReport:Say(nLnIni+150, nColIni+2720, STR0027, oArial10N)					// "REFORÇO PARCIAL "
oReport:Say(nLnIni+200, nColIni+2720, STR0015, oArial10N)					// "T O T A L "

oReport:Say(nLnIni+30, nColIni+3100 , PadL(nTotOrd, 5), oArial10N)					//'ORDINÁRIAS'
oReport:Say(nLnIni+30, nColIni+3200 , PadL(nTotOrd * Val(cMedLot), 6), oArial10N)	//'ORDINÁRIAS'

oReport:Say(nLnIni+70, nColIni+3100 , PadL(0, 5), oArial10N)						//'MULTIPAS'
oReport:Say(nLnIni+70, nColIni+3200 , PadL(0, 6), oArial10N)						//'MULTIPLAS'

oReport:Say(nLnIni+150, nColIni+3100, PadL(0, 5), oArial10N)						//'REFORÇO PARCIAL'
oReport:Say(nLnIni+150, nColIni+3200, PadL(0, 6), oArial10N)						//'REFORÇO PARCIAL'

oReport:Say(nLnIni+110, nColIni+3100, PadL(nTotRT, 5), oArial10N)					//'REFORÇO TOTAL'
oReport:Say(nLnIni+110, nColIni+3200, PadL(nTotRT * Val(cMedLot), 6), oArial10N)	//'ORDINÁRIAS'

oReport:Say(nLnIni+200, nColIni+3100, PadL(nTotOrd + nTotRT,5), oArial10N)					//'T O T A L'
oReport:Say(nLnIni+200, nColIni+3200, PadL((nTotOrd + nTotRT)* Val(cMedLot),6), oArial10N)	//'T O T A L'

oReport:Box(nLnIni+250, nColIni, nLnIni+390, nColIni+500) 			// Box Secao Autorizada
oReport:Box(nLnIni+250, nColIni+500, nLnIni+390, nColIni+700) 		// Box Codigo Secao

oReport:Box(nLnIni+250, nColIni+700 , nLnIni+320, nColIni+1100) 	// Box Convencional
oReport:Box(nLnIni+250, nColIni+1100, nLnIni+320, nColIni+1500)		// Box Multipla
oReport:Box(nLnIni+250, nColIni+1500, nLnIni+320, nColIni+1900)		// Box Reforço Total
oReport:Box(nLnIni+250, nColIni+1900, nLnIni+320, nColIni+2500)		// Box Reforço Parcial
oReport:Box(nLnIni+250, nColIni+2500, nLnIni+390, nColIni+2700) 	// Box Tarifa
oReport:Box(nLnIni+250, nColIni+2700, nLnIni+320, nColIni+3300) 	// Box Totais

oReport:Box(nLnIni+320, nColIni+700, nLnIni+390, nColIni+900)		// Box Ida Ordinaria
oReport:Box(nLnIni+320, nColIni+900, nLnIni+390, nColIni+1100)		// Box Volta Ordinaria

oReport:Box(nLnIni+320, nColIni+1100, nLnIni+390, nColIni+1300)		// Box Ida Multipla
oReport:Box(nLnIni+320, nColIni+1300, nLnIni+390, nColIni+1500)		// Box Volta Multipla

oReport:Box(nLnIni+320, nColIni+1500, nLnIni+390, nColIni+1700)		// Box Ida Reforço Total
oReport:Box(nLnIni+320, nColIni+1700, nLnIni+390, nColIni+1900)		// Box Volta Reforço Total

oReport:Box(nLnIni+320, nColIni+1900, nLnIni+390, nColIni+2100)		// Box Ida Reforço Parcial
oReport:Box(nLnIni+320, nColIni+2100, nLnIni+390, nColIni+2300)		// Box Volta Reforço Parcial
oReport:Box(nLnIni+320, nColIni+2300, nLnIni+390, nColIni+2500)		// Box VGM
oReport:Box(nLnIni+320, nColIni+2700, nLnIni+390, nColIni+2900)		// Box Totais 1
oReport:Box(nLnIni+320, nColIni+2900, nLnIni+390, nColIni+3100)		// Box Totais 2
oReport:Box(nLnIni+320, nColIni+3100, nLnIni+390, nColIni+3300)		// Box Totais 3

oReport:Say(nLnIni+270, nColIni+50  , STR0009, oArial10N)			// "SEÇÃO"
oReport:Say(nLnIni+310, nColIni+50  , STR0010, oArial10N)			// "AUTORIZADA"

oReport:Say(nLnIni+270, nColIni+530 , STR0011, oArial10N)			// "CÓDIGO"
oReport:Say(nLnIni+310, nColIni+540 , STR0009, oArial10N)			// "SEÇÃO"

oReport:Say(nLnIni+270, nColIni+800 , STR0001, oArial10N)			// "ORDINÁRIA"
oReport:Say(nLnIni+340, nColIni+760 , STR0012, oArial10N)			// "IDA"
oReport:Say(nLnIni+340, nColIni+950 , STR0013, oArial10N)			// "VOLTA"

oReport:Say(nLnIni+270, nColIni+1240, STR0014, oArial10N)			// "MÚLTIPLA"
oReport:Say(nLnIni+340, nColIni+1160, STR0012, oArial10N)			// "IDA"
oReport:Say(nLnIni+340, nColIni+1350, STR0013, oArial10N)			// "VOLTA"

oReport:Say(nLnIni+270, nColIni+1590, STR0008, oArial10N)			// "REFORÇO TOTAL "
oReport:Say(nLnIni+340, nColIni+1560, STR0012, oArial10N)			// "IDA"
oReport:Say(nLnIni+340, nColIni+1750, STR0013, oArial10N)			// "VOLTA"

oReport:Say(nLnIni+270, nColIni+2070, STR0027, oArial10N)			// "REFORÇO PARCIAL"
oReport:Say(nLnIni+340, nColIni+1960, STR0012, oArial10N)			// "IDA"
oReport:Say(nLnIni+340, nColIni+2150, STR0013, oArial10N)			// "VOLTA"
oReport:Say(nLnIni+340, nColIni+2360, "VGM", oArial10N)				

oReport:Say(nLnIni+300, nColIni+2550, STR0021, oArial10N)			// "TARIFA"
oReport:Say(nLnIni+270, nColIni+2950, STR0017, oArial10N)			// "TOTAIS"
oReport:Say(nLnIni+340, nColIni+2790, "(1)"  , oArial10N)					
oReport:Say(nLnIni+340, nColIni+2990, "(2)"  , oArial10N)					
oReport:Say(nLnIni+340, nColIni+3190, "(3)"  , oArial10N)					
 
Return

