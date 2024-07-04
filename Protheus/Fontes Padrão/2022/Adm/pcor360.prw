
#INCLUDE "pcor360.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE CELLTAMDATA 420

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOR360  ³ AUTOR ³ Edson Maricate        ³ DATA ³ 18/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de impressao do demonstrativo saldo/Periodo         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOR360                                                      ³±±
±±³_DESCRI_  ³ Programa de impressao do demonstrativo saldo/periodo         ³±±
±±³_FUNC_    ³ Esta funcao devera ser utilizada com a sua chamada normal a  ³±±
±±³          ³ partir do Menu do sistema.                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOR360(aPerg)

Local aArea		:= GetArea()
Local lOk			:= .F.
Local lEnd			:= .F. 
Local aVarPriv 	:= {}

Private aSavPar	
Private cCadastro	:= STR0001 //"Demonstrativo de Saldos por Periodo"
Private nLin		:= 10000
Private aPeriodos

Default aPerg := {}

If Len(aPerg) == 0
	
	If Pergunte("PCR360",.T.)	
		oPrint := PcoPrtIni(cCadastro,.T.,2,,@lOk,"")
		
	Else
		RestArea(aArea)
		Return
		
	Endif
	
Else

	aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
	oPrint := PcoPrtIni(cCadastro,.T.,2,,@lOk,"")

EndIf

If lOk
	//salva parametros para nao conflitar com parambox
	aSavPar := {MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06, MV_PAR07, MV_PAR08, MV_PAR09}
	
	dbSelectArea("AKN")
	dbSetOrder(1)
	lOk := !Empty(MV_PAR01) .And. dbSeek(xFilial("AKN")+MV_PAR01)

	If lOk
		If SuperGetMV("MV_PCO_AKN",.F.,"2")!="1"  //1-Verifica acesso por entidade
			lOk := .T.                        // 2-Nao verifica o acesso por entidade
		Else
			nDirAcesso := PcoDirEnt_User("AKN", AKN->AKN_CODIGO, __cUserID, .F.)
		    If nDirAcesso == 0 //0=bloqueado
				Aviso(STR0010,STR0011,{STR0012},2)//"Atenção"###"Usuario sem acesso a esta configuração de visao gerencial. "###"Fechar"
				lOk := .F.
			Else
	    		lOk := .T.
			EndIf
		EndIf
	
		//impressao do relatorio
		If lOk
			
			aPeriodos := PcoRetPer(aSavPar[2]/*dIniPer*/, aSavPar[3]/*dFimPer*/, Alltrim(aSavPar[5])/*cTipoPer*/, aSavPar[6]==1/*lAcumul*/)
			
			//processamento do relatorio
			aVarPriv := {}
			aAdd(aVarPriv, {"aPeriodos", aClone(aPeriodos)})                
			aAdd(aVarPriv, {"aSavPar", aClone(aSavPar)})
			
			aProcessa := PcoCubeVis(MV_PAR01,Len(aPeriodos)*4,"Pcor360Sld",MV_PAR07,MV_PAR08,MV_PAR09,,aVarPriv)
            //impressao do relatorio
			RptStatus( {|lEnd| PCOR360Imp(@lEnd,oPrint,aProcessa)})
		EndIf
	EndIf
	
	//finaliza relatorio
	PcoPrtEnd(oPrint)
EndIf

RestArea(aArea)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoR360Sld³ Autor ³ Edson Maricate        ³ Data ³18/02/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de processamento do demonstrativo saldo / periodo.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PcoR360Sld                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd - Variavel para cancelamento da impressao pelo usuario³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PcoR360Sld(cConfig,cChave)

Local aRetorno := {}
Local aRetIni,aRetFim
Local nCrdIni
Local nDebIni
Local nCrdFim
Local nDebFim
Local ny

For ny := 1 to Len(aPeriodos)

	dIni := CtoD(Subs(aPeriodos[ny],1,10))
	dFim := CtoD(Subs(aPeriodos[ny],14))

	aRetIni := PcoRetSld(cConfig,cChave,dIni)
	nCrdIni := aRetIni[1, aSavPar[4]]
	nDebIni := aRetIni[2, aSavPar[4]]

	aRetFim := PcoRetSld(cConfig,cChave,dFim)
	nCrdFim := aRetFim[1, aSavPar[4]]
	nDebFim := aRetFim[2, aSavPar[4]]

	nSldIni := nCrdIni-nDebIni
	nMovCrd := nCrdFim-nCrdIni	
	nMovDeb := nDebFim-nDebIni
	nMovPer := nMovCrd-nMovDeb

	aAdd(aRetorno,nSldIni)
	aAdd(aRetorno,nMovCrd)
	aAdd(aRetorno,nMovDeb)
	aAdd(aRetorno,nMovPer)

Next

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoR360Imp³ Autor ³ Edson Maricate        ³ Data ³18/02/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de impressao do demonstrativo de saldos/periodo.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOR360Imp(lEnd)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd - Variavel para cancelamento da impressao pelo usuario³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoR360Imp(lEnd,oPrint,aProcessa)

Local nx, ny, nZ, nW, nCol, nAlvo
Local cQuebra := ""
Local aColFix := { 10, 450, 1200 }
Local aTitFix := {STR0002, STR0003, STR0004} //"Codigo"###"Descricao"###"Movimentos"
Local aLinMov  := {STR0005, STR0006, STR0007, STR0008} //"Saldo Inicial: "###"Mov.Credito (C):"###"Mov.Debito (D)"###"Saldo Final (C - D):"
Local aColAux := {}
Local aColunas := {}
Local aAuxCol, aImprFinal
Local nColuna, nLinha, nTamLin := 50
Local nBlocoImp

If Empty(aColunas)
	//configura o tamanho e os titulos das colunas
	aColAux := aClone(aColFix)
	aAuxTit := aClone(aTitFix)
	nCol := aColFix[3] + 350

	For nY := 1 TO Len(aPeriodos)
		If aColAux[Len(aColAux)] < 2800
			aAdd(aColAux, nCol)
			nCol += CELLTAMDATA				
			aAdd(aAuxTit, aPeriodos[nY])
		Else 
			aAdd(aColunas, {aClone(aColAux), aClone(aAuxTit)})
			aColAux := {}
			aAuxTit := {}
			aAdd(aColAux, aColFix[3])
			aAdd(aAuxTit, aTitFix[3])
			nCol := aColFix[3] + 350
			aAdd(aColAux, nCol)
			aAdd(aAuxTit, aPeriodos[nY])
			nCol += CELLTAMDATA				
		EndIf
	Next
	aAdd(aColunas, {aClone(aColAux), aClone(aAuxTit)})
EndIf

For nx := 1 To Len(aProcessa)

	If !(aProcessa[nx,17] $ "34") // Nao e linha sem valor nem traco
		If PcoPrtLim(nLin+(nTamLin*4))     //sempre considerar o bloco para salto
			nLin := 200
			PcoPrtCab(oPrint)
			nLin+=20
		EndIf
		
		If cQuebra<>aProcessa[nx,3]
			nLin+= 25
			PcoPrtCol({10})
			PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,aProcessa[nx,3],oPrint,1,2,/*RgbColor*/)
			nLin+=50
			cQuebra := aProcessa[nx,3]
		EndIf
	    
	    aAuxCol := {}
	    
		For nZ := 1 TO Len(aColunas)
			If nZ == 1 //diminuir 03 colunas fixas
				aAdd(aAuxCol, Len(aColunas[nZ][1])-3 )
			Else
				aAdd(aAuxCol, Len(aColunas[nZ][1])-1 )
			EndIf
		Next
		
		nProc := 1
		nAlvo := 0
		aImprFinal := {}
	    //linha de teste nao tirar //comentario
		//somente para popular o array aProcessa com numeros sequenciais para conferencia
		//AEVAL(aProcessa[nX][2],{|cX,nXyz| aProcessa[nx][2][nXyz]:=nXyz})
	
	    //Quebra aProcessa[nx][2] em blocos de impressao
	    For nColuna := 1 TO Len(aAuxCol)
	    	nCols := aAuxCol[nColuna]
	    	nAlvo += (4*nCols) //4 LINHAS
	    	aCols := {}
	    	For nLinha:=1 TO 4  //4 LINHAS SALDO/CRED/DEB/CRED-DEB
	    	    aAdd(aCols, aClone(ARRAY(nCols)))
	    	    aFill(aCols[nLinha], 0)
	    	    For nW:=1 TO nCols
	    	    	aCols[nLinha][nW] := aProcessa[nX][2][nProc+(4*(nW-1))]  // 4 linhas por isto seq 4 e 4
	    	    Next
	    	    nProc++
	    	Next
	    	nProc := nAlvo+1
	    	aAdd(aImprFinal, aClone(aCols))
		Next
		
		If lEnd
			PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,STR0009,oPrint,2,1,RGB(230,230,230)) //"Impressao cancelada pelo operador..."
		Endif
		
		For nBlocoImp := 1 TO Len(aAuxCol)
		
			nColImp := 1   //imprime sempre na 1a. coluna
		
			//Verificar se quebra Pagina
		   	If PcoPrtLim(nLin+(nTamLin*4))        //sempre considerar o bloco para salto
		   		nLin := 200
				PcoPrtCab(oPrint)
				nLin+=20
			EndIf
				
		    //impressao do cabecalho da linha detalhe
		  
			PcoPrtCol(aColunas[nBlocoImp][1])
		    For nZ := 1 TO Len(aColunas[nBlocoImp][2])
		    	PcoPrtCell(PcoPrtPos(nZ), nLin, PcoPrtTam(nZ), 30, aColunas[nBlocoImp][2][nZ],oPrint,2,1,RGB(230,230,230))
			Next
	        nLin += nTamLin
	        
			If nBlocoImp == 1  //no primeiro bloco imprime codigo/descricao da conta
				PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,aProcessa[nx,1],oPrint,1,2,/*RgbColor*/) 
				PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60,aProcessa[nx,6],oPrint,1,2,/*RgbColor*/) 
				nColImp := Len(aColFix)  //qdo for o 1o. bloco impressao
			EndIf
			
	        //aqui imprime a linha detalhe (4 linhas SALDO CRE DEB CRE-DEB)
	        For nLinha:=1  TO 4				
	        	PcoPrtCell(PcoPrtPos(nColImp),nLin,PcoPrtTam(nColImp),60,aLinMov[nLinha],oPrint,1,2,/*RgbColor*/,"") 
	        	//imprime os valores de cada periodo
		 		For nColuna := 1 TO aAuxCol[nBlocoImp]
					PcoPrtCell(PcoPrtPos(nColuna+nColImp),nLin,PcoPrtTam(nColuna+nColImp),60,Transform(aImprFinal[nBlocoImp][nLinha][nColuna],"@E 999,999,999,999.99"),oPrint,1,2,/*RgbColor*/,"",.T.,,,,.T.) 
				Next
				nLin += nTamLin
			Next
			
			nLin += nTamLin
			
		Next
	Endif    
Next

Return