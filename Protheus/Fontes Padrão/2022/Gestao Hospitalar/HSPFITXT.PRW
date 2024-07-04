#INCLUDE "HSPFITXT.ch"
#include "protheus.CH"
#include "topconn.CH"
#include "colors.ch" 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPFITXT  º Autor ³ Saude              º Data ³  22/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ FICHAS PERSONALIZAVEIS                                     º±± 
±±º          ³ cNomeArq  = nome do arquivo de texto                       º±±
±±º          ³ cModImp   = Modo de impressão das fichas                   º±± 
±±º                        0=Txt C/Cabec                                  º±± 
±±º                        1=Txt S/Cabec                                  º±± 
±±º                        2=Fic.Pad.Txt                                  º±± 
±±º                        3=Fic.Pad.Img                                  º±± 
±±º                        4=Imagem                                       º±±
±±º                        5=Etiqueta                                     º±± 
±±º          ³ nQtdLin   = quantidade de linhas por pagina                º±± 
±±º          ³ nQtdVias  = quantidade de vias do documento                º±± 
±±º          ³ cTPFont   = caracterisitca da fonte                        º±± 
±±º          ³ cTamLin   = tamanho da linha do arquivo                    º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
                                                                                
// Parametros da func cabec
// cabec(cTitulo,cCabec1,cCabec2,cNomPrg,nTamanho,nChar,aCustomText,lPerg,cLogo)
// Lista de Funções do objeto oPrint
//oPrint:= TMSPrinter():New(cTitRel)//construtor da classe
//oPrint:SetPortrait()   			//** Para Imprimir em Formato Retrato
//oPrint:Preview()
//oPrint:Print()
//oPrint:EndPage()
//oPrint:StartPage()
//oPrint:SayBitmap(linha,coluna,bitmap,largura,altura,nao utilizado,auto-ajuste) // Tem que estar abaixo do RootPath
//oPrint:Say(nRow, nCol, cText, oFont, nWidth, nClrText, uParam7, nAlign) // uParam7 -> Mantido por compatibilidade, caso informado deve ser NIL.
//oPrint:Line(nTop, nLeft, nBottom, nRight, oPen) // oPen := tPen():New(nStyle, nWidth, nRGBColor, oWnd)
//oPrint:Setup()
//oPrint:End()
//oPrint:SetLandscape()  			//** Para Imprimir em Formato Paisagem
//oPrint:Box(nTop, nLeft, nBottom, nRight, oPen) // oPen := tPen():New(nStyle, nWidth, nRGBColor, oWnd)
// nStyle
//  #define PS_SOLID            0
//  #define PS_DASH             1
//  #define PS_DOT              2
//  #define PS_DASHDOT          3
//  #define PS_DASHDOTDOT       4
//  #define PS_NULL             5
//  #define PS_INSIDEFRAME      6


//oPrint:FillRect(aCoords1,oBrush) // aCoords1	:= {0060,0150,0210,0200} // oBrush   := TBrush():New("",RGB(0,0,0))                   

Function HSPFITXT(cNomeArq, cModImp, nQtdLin, nQtdVias, cTPFont, cTamLin)

Local Titulo := "", Cabec1 := "", Cabec2 := ""
Local nVias := 0, nLin := 0, mLinhaArq := "", nForImp := 0
Local cCaminho := AllTrim(GetMV("MV_DIRTXT")) 
Local aTxtCabec := {}, aTxtDetal := {}, aTxtRodap := {}, cTxtBasic := "", nIniDetal := 0, nTotDetal := 0
Local oFonPad := TFont():New("Arial",, 10,, .F.,,,, .F., .F.), aFont := {{oFonPad, 0}}
Local oTPen, oTBrush
 
Local lTagMI := .F., lLigaMI := .F., nPosMI := 0
Local lTagQL := .F., lLigaQL := .F., nPosQL := 0
Local lTagQV := .F., lLigaQV := .F., nPosQV := 0
Local lTagTF := .F., lLigaTF := .F., nPosTF := 0
Local lTagTL := .F., lLigaTL := .F., nPosTL := 0
 
Local nTLinImp := 50
Local lTagBM := .F., nPosBM := 0, aParBM := {}, aBitMap := {}
Local lTagCB := .F., nPosCB := 0, aParCB := {}, aCodBar := {}
Local lTagDF := .F., nPosDF := 0, aParDF := {"Arial", 10, .F., .F., .F., "0"}
Local lTagDL := .F., nPosDL := 0, aParDL := {}, aDesLin := {}
Local lTagDB := .F., nPosDB := 0, aParDB := {}, aDesBox := {}
Local lTagDR := .F., nPosDR := 0, aParDR := {}, aDesRec := {}
Local lTagIC := .F., lTagFC := .F., lTxtCabec := .F.
Local lTagID := .F., lTagFD := .F., lTxtDetal := .F., nPosID := 0
Local lTagIR := .F., lTagFR := .F., lTxtRodap := .F.
Local NomeProg := "HSPFITXT"
Local cNewLine := ""
 
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ VERIFICA A EXISTENCIA DO ARQUIVO ANTES DE ABRI-LO  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !Empty( cCaminho )
	If !File( cCaminho + cNomeArq ) // + ".TXT" )
		MsgStop(STR0003 + cNomeArq + STR0004 + cCaminho + STR0005,STR0006) //"Arquivo "###" no Caminho "###"... NAO EXISTE. Operacao cancelada."###"Atencao"
		Return( Nil )
	EndIf
Else
	MsgStop(STR0007,STR0006)  //"Parametro MV_DIRTXT sem dados...Operacao cancelada."###"Atencao"
	Return( Nil )
EndIf

cModImp  := IIf(cModImp  == Nil, "0", cModImp )
nQtdLin  := IIf(nQtdLin  == Nil,  55, nQtdLin )
nQtdVias := IIf(nQtdVias == Nil,   1, nQtdVias)
cTPFont  := IIf(cTPFont  == Nil, "2", cTPFont )
cTamLin  := IIf(cTamLin  == Nil, "1", cTamLin )
nTLinImp := 50
 
//nQtdLin  := (nQtdLin * nTLinImp)


For nVias := 1 To nQtdVias

	FT_FUse( ALLTRIM(cCaminho) + ALLTRIM(cNomeArq) ) //+ ".TXT" ) /* ABRE O ARQUIVO TXT */
	FT_FGOTOP()

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  	  ³ LOOP NO ARQUIVO PARA LEITURA DAS LINHAS            ³
  	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
 
	While !FT_FEof()     
 
		mLinhaArq := IIF(Empty(cNewLine),FT_FReadln(),cNewLine)  /* LEITURA DA LINHA E ATRIBUICAO DA LEITURA A VARIAVEL mLinhaArq */
  
		If !Empty(mLinhaArq) /* SE A LINHA NAO ESTIVER VAZIA */
   
			lTagMI := IIf(!lLigaMI, (nPosMI := AT("#MI", mLinhaArq)) > 0, .F.) // 0=Não ou 1=Sim, sinaliza utilização da função Cabec no relatório
			lTagQL := IIf(!lLigaQL, (nPosQL := AT("#QL", mLinhaArq)) > 0, .F.) // sinaliza a quantidade de linhas por pagina
			lTagQV := IIf(!lLigaQV, (nPosQV := AT("#QV", mLinhaArq)) > 0, .F.) // sinaliza a quantidade de vias por ficha
			lTagTF := IIf(!lLigaTF, (nPosTF := AT("#TF", mLinhaArq)) > 0, .F.) // 1=Comprimido ou 2=Normal, sinaliza o tipo de fonte (Compactado ou Normal)
			lTagTL := IIf(!lLigaTF, (nPosTL := AT("#TL", mLinhaArq)) > 0, .F.) // 1=P ou 2=M ou 3=G, sinaliza o tamanho da pagina P, M ou G
			    
			lTagBM := (nPosBM := AT("#BM", mLinhaArq)) > 0 // sinaliza impressão de logotipo
			lTagCB := (nPosCB := AT("#CB", mLinhaArq)) > 0 // sinaliza impressão de código de barras			
			lTagDF := (nPosDF := AT("#DF", mLinhaArq)) > 0 // sinaliza definição da fonte que será utilizada para imprimir a linha
			lTagDL := (nPosDL := AT("#DL", mLinhaArq)) > 0 // sinaliza impressão de Linha
			lTagDB := (nPosDB := AT("#DB", mLinhaArq)) > 0 // sinaliza impressão de Box
			lTagDR := (nPosDR := AT("#DR", mLinhaArq)) > 0 // sinaliza impressão de Fill Rectangle
			    
			lTagIC := IIf(!lTagIC, AT("#IC", mLinhaArq) > 0, lTagIC) //sinaliza o inicio do agrupamento do cabecalho
			lTagFC := IIf(!lTagFC, AT("#FC", mLinhaArq) > 0, lTagFC) //sinaliza o fim do agrupamento do cabecalho
			   
			lTagID := IIf(!lTagID, (nPosID := AT("#ID", mLinhaArq)) > 0, lTagID) // sinaliza o inicio dos detalhes
			lTagFD := IIf(!lTagFD,            AT("#FD", mLinhaArq)  > 0, lTagFD) // Sinaliza o final dos detalhes
			    
			lTagIR := IIf(!lTagIR, AT("#IR", mLinhaArq) > 0, lTagIR) // Sinaliza o inicio do rodape
			lTagFR := IIf(!lTagFR, AT("#FR", mLinhaArq) > 0, lTagFR) // Sinaliza o final do rodape
   
		Else
             
			lTagMI := .F.
			lTagQL := .F.
			lTagQV := .F.
			lTagTF := .F.
			lTagTL := .F.
			    
			lTagDF := .F.
			lTagBM := .F.
			lTagCB := .F.			
			lTagDL := .F.
			lTagDB := .F.
			lTagDR := .F.
    
		EndIf
  
		If lTagMI
			mLinhaArq := SubStr(mLinhaArq, nPosMI + 3, 1)
			cModImp   := IIf(cModImp == Nil, mLinhaArq, cModImp)
			lLigaMI   := .T.
		ElseIf lTagQL
			mLinhaArq := Val(AllTrim(SubStr(mLinhaArq, nPosQL + 3)))
			nQtdLin   := IIf(nQtdLin == Nil, IIf(mLinhaArq > 0, mLinhaArq, 55), nQtdLin)
			lLigaQL   := .T.
		ElseIf lTagQV
			mLinhaArq := Val(AllTrim(SubStr(mLinhaArq, nPosQV + 3)))
			nQtdVias  := IIf(nQtdVias == Nil, IIf(mLinhaArq > 0, mLinhaArq, 1), nQtdVias)
			lLigaQV   := .T.
		ElseIf lTagTF
			mLinhaArq := SubStr(mLinhaArq, nPosTF + 3, 1)
			cTPFont   := IIf(cTPFont == Nil, mLinhaArq, cTPFont)
			lLigaTF   := .T.
		ElseIf lTagTL
			mLinhaArq := SubStr(mLinhaArq, nPosTL + 3, 1)
			cTamLin   := IIf(cTamLin == Nil, mLinhaArq, cTamLin)
			lLigaTL   := .T.
		ElseIf lTagDL
			mLinhaArq := AllTrim(SubStr(mLinhaArq, nPosDL + 3))
			aParDL    := &(mLinhaArq)
			aAdd(aDesLin, aClone(aParDL))
		ElseIf lTagDB
			mLinhaArq := AllTrim(SubStr(mLinhaArq, nPosDB + 3))
			aParDB := &(mLinhaArq)
			aAdd(aDesBox, aClone(aParDB))
		ElseIf lTagDR
			mLinhaArq := AllTrim(SubStr(mLinhaArq, nPosDR + 3))
			aParDR := &(mLinhaArq)
			aAdd(aDesRec, aClone(aParDR))
		ElseIf lTagDF
			mLinhaArq := AllTrim(SubStr(mLinhaArq, nPosDF + 3))
			aParDF := &(mLinhaArq)
			aAdd(aFont, {TFont():New(aParDF[1],, aParDF[2],, aParDF[3],,,, aParDF[4], aParDF[5]), &("HS_Color(" + aParDF[6] + ")")})
		    If lTxtCabec
			     aAdd(aTxtCabec, "#DF" + AllTrim(Str(Len(aFont))))
			ElseIf lTxtDetal
				aAdd(aTxtDetal, "#DF" + AllTrim(Str(Len(aFont))))
			ElseIf lTxtRodap
				aAdd(aTxtRodap, "#DF" + AllTrim(Str(Len(aFont))))
			Else
				cTxtBasic += "#DF" + AllTrim(Str(Len(aFont))) + Chr(13) + Chr(10)
			EndIf
		ElseIf lTagBM
			mLinhaArq := AllTrim(SubStr(mLinhaArq, nPosBM + 3))
			aParBM    := &(mLinhaArq)
			aAdd(aBitMap, aClone(aParBM))
			If lTxtCabec
				aAdd(aTxtCabec, "#BM" + AllTrim(Str(Len(aBitMap))))
			ElseIf lTxtDetal
				aAdd(aTxtDetal, "#BM" + AllTrim(Str(Len(aBitMap))))
			ElseIf lTxtRodap
				aAdd(aTxtRodap, "#BM" + AllTrim(Str(Len(aBitMap))))
			Else
				cTxtBasic += "#BM" + AllTrim(Str(Len(aBitMap))) + Chr(13) + Chr(10)
			EndIf
		ElseIf lTagCB
			mLinhaArq := AllTrim(SubStr(mLinhaArq, nPosCB + 3))
			aParCB    := &(mLinhaArq)
			aAdd(aCodBar, aClone(aParCB))
			If lTxtCabec
				aAdd(aTxtCabec, "#CB" + AllTrim(Str(Len(aCodBar))))
			ElseIf lTxtDetal
				aAdd(aTxtDetal, "#CB" + AllTrim(Str(Len(aCodBar))))
			ElseIf lTxtRodap
				aAdd(aTxtRodap, "#CB" + AllTrim(Str(Len(aCodBar))))
			Else
				cTxtBasic += "#CB" + AllTrim(Str(Len(aCodBar))) + Chr(13) + Chr(10)
			EndIf			
		ElseIf lTagIC .And. !lTxtCabec
			lTxtCabec := .T.
		ElseIf lTagFC
			lTagIC    := .F.
			lTagFC    := .F.
			lTxtCabec := .F.
		ElseIf lTxtCabec
			aAdd(aTxtCabec, FS_ParseL(mLinhaArq))
		ElseIf lTagID .And. !lTxtDetal
			lTxtDetal := .T.             
			nTotDetal := Val(SubStr(mLinhaArq, nPosID + 3, 2))
		ElseIf lTagFD
			lTagID    := .F.
			lTagFD    := .F.
			lTxtDetal := .F.
		ElseIf lTxtDetal
			FS_TxtToArray(@aTxtDetal, FS_ParseL(mLinhaArq))
		ElseIf lTagIR .And. !lTxtRodap
			lTxtRodap := .T.
		ElseIf lTagFR
			lTagIR    := .F.
			lTagFR    := .F.
			lTxtRodap := .F.
		ElseIf lTxtRodap
			aAdd(aTxtRodap, FS_ParseL(mLinhaArq))
		ElseIf AT("#;", mLinhaArq) > 0
			FT_FSkip() 
			cNewLine := SUBSTR(mLinhaArq,1,AT("#;", mLinhaArq)-1) + LTrim(FT_FReadLn())
			Loop  
		ElseIf Len(aTxtCabec) == 0 .And. Len(aTxtDetal) == 0 .And. Len(aTxtRodap) == 0
			If !Empty(mLinhaArq) /* SE A LINHA NAO ESTIVER VAZIA */
				cTxtBasic += FS_ParseL(mLinhaArq) + Chr(13) + Chr(10)
			Else
				cTxtBasic += mLinhaArq + Chr(13) + Chr(10)
			EndIf                             
		EndIf
  
		cNewLine := ""
		FT_FSkip()
  
	End                                
 
	FT_FUse() /* FECHA O ARQUIVO TXT */
 
	__nPagFic := 0
	M_PAG     := 1
 
	If !Empty(cTxtBasic) // Modo Basico
  
		nLin := nQtdLin + nTLinImp
		mLinhaArq := ""
		nPosDF    := 1
		nPosBM    := 0
		nPosCB    := 0		
  
		While !Empty(cTxtBasic)
			If nLin > nQtdLin 
				If cModImp == "4" // 4=Imagem
					__nPagFic++
					If __nPagFic > 1
						oPrint:EndPage()
					EndIf
					oPrint:StartPage()
					nLin   := 0
					nPosDF := 1
					nPosBM := 0
					nPosCB := 0					
      
					For nPosDL := 1 To Len(aDesLin)
						oPrint:Line(aDesLin[nPosDL][1], aDesLin[nPosDL][2], aDesLin[nPosDL][3], aDesLin[nPosDL][4])
					Next nPosDL
      
					For nPosDB := 1 To Len(aDesBox)
						oTPen := Nil
						If Len(aDesBox[nPosDB]) >= 5
						oTPen := tPen():New(aDesBox[nPosDB][5][1], aDesBox[nPosDB][5][2], &("HS_Color(" + aDesBox[nPosDB][5][3] + ")"))
						EndIf
						oPrint:Box(aDesBox[nPosDB][1], aDesBox[nPosDB][2], aDesBox[nPosDB][3], aDesBox[nPosDB][4], oTPen)
					Next nPosDB
      
					For nPosDR := 1 To Len(aDesRec)
						oTBrush := Nil
						If Len(aDesRec[nPosDR]) >= 2
							oTBrush := tBrush():New("", &("HS_Color(" + aDesRec[nPosDR][2] + ")"))
						EndIf
						oPrint:FillRect(aDesRec[nPosDR][1], oTBrush)
					Next nPosDR
      
				ElseIf cModImp == "1" // 1=Txt S/Cabec
					__nPagFic++
					If __nPagFic > 1
						oPrint:EndPage()
					EndIf
					oPrint:StartPage()
					nLin   := 0
					nPosDF := 1
					nPosBM := 0
					nPosCB := 0	
					
					//Cabec(Titulo, Cabec1, Cabec2, NomeProg, H44GetTam(), H44GetTip())
					//	nLin := 6
					//__nPagFic++
				Else           
					Cabec(Titulo, Cabec1, Cabec2, NomeProg, H44GetTam(), H44GetTip())
					nLin := 6
					__nPagFic++
					// SendPrtInfo(H44GetTam(), H44GetTip())
					// nLin := 0
					// If __nPagFic > 1
					// 	Eject
					// EndIf
				EndIf
			EndIf 

			mLinhaArq := SubStr(cTxtBasic, 1, At(Chr(13) + Chr(10), cTxtBasic) - 1) // Atribui a linha atual a ser tabalhada
			// Valida se após a soma de linhas com a imagem se será ultrapassado o limite da pagina, caso positivo sai do loop e quebra a pagina
    		If cModImp == "4" .AND. SubStr(mLinhaArq, 1, 3) == "#BM" // 4=Imagem E LOGOTIPO				
				nPosBM := Val(SubStr(mLinhaArq, 4))
				If (nLin + aBitMap[nPosBM][4]) >  nQtdLin // Deve quebrar a pagina pois tamanho da imagem já estourou
					  nLin := (nQtdLin + 1 )
					  Loop
				EndIf
    		EndIf    		
			cTxtBasic := SubStr(cTxtBasic, At(Chr(13) + Chr(10), cTxtBasic) + 2) // Retira a linha atual da variavel cTxtBasic e atribua com o restante da string			    
			If SubStr(mLinhaArq, 1, 3) == "#DF" // Sinaliza troca de Font
				nPosDF := Val(SubStr(mLinhaArq, 4))
				Loop
			EndIf 
    
			If cModImp == "4" // 4=Imagem
				If SubStr(mLinhaArq, 1, 3) == "#BM" //sinaliza impressão de logotipo
					nPosBM := Val(SubStr(mLinhaArq, 4))
					oPrint:SayBitMap(nLin, aBitMap[nPosBM][1], aBitMap[nPosBM][2], aBitMap[nPosBM][3], aBitMap[nPosBM][4],, aBitMap[nPosBM][5])
					nLin += aBitMap[nPosBM][4]
				ElseIf SubStr(mLinhaArq, 1, 3) == "#CB" //sinaliza impressão de codigo de barras					
					nPosCB := Val(SubStr(mLinhaArq, 4))                                                                                                             
					MSBAR3(aCodBar[nPosCB][1], aCodBar[nPosCB][2], aCodBar[nPosCB][3], aCodBar[nPosCB][4], oPrint, aCodBar[nPosCB][6], aCodBar[nPosCB][7], aCodBar[nPosCB][8], aCodBar[nPosCB][9], aCodBar[nPosCB][10], aCodBar[nPosCB][11], aCodBar[nPosCB][12], aCodBar[nPosCB][13], aCodBar[nPosCB][14])
					nLin += aCodBar[nPosCB][9]
				Else
					oPrint:Say(nLin, 000, RTrim(mLinhaArq), aFont[nPosDF][1],, aFont[nPosDF][2], /*nBkMode*/)
					nLin += nTLinImp
				EndIf  // MSBAR(cTipoBar, nLinBar, nColBar, QRY->GGQ_CDPROT, oPrn, lDigBar, cCorBar, lHOriBar, nLargBar, nAltuBar, lBanbar, cFonBar, cModBar, .F.)						

			Else    
				//oPrint:Say(nLin, 000, RTrim(mLinhaArq),aFont[nPosDF][1],, aFont[nPosDF][2], /*nBkMode*/) /* IMPRIME A LINHA LIDA E INTERPRETADA */
				//nLin+=nTLinImp
				@ nLin,000 PSAY RTrim(mLinhaArq)
				nLin++
			EndIf   
		End
  
	Else // Ficha com Cabecalho, Detalhes e Rodape. Tags #IC, #ID, #IR
  
		nTotDetal := IIf(nTotDetal <= 0, Len(aTxtDetal), nTotDetal)
		nIniDetal := 1
    
		While nIniDetal <= Len(aTxtDetal) .And. nTotDetal > 0
			If cModImp == "4" // 4=Imagem
				__nPagFic++
				If __nPagFic > 1
					oPrint:EndPage()
				EndIf
				oPrint:StartPage()
				nLin   := 0
				nPosDF := 1
				nPosBM := 0
				nPosCB := 0				
		     
				For nPosDL := 1 To Len(aDesLin)
					oPrint:Line(aDesLin[nPosDL][1], aDesLin[nPosDL][2], aDesLin[nPosDL][3], aDesLin[nPosDL][4])
				Next nPosDL
		      
				For nPosDB := 1 To Len(aDesBox)
					oTPen := Nil
					If Len(aDesBox[nPosDB]) >= 5
						oTPen := tPen():New(aDesBox[nPosDB][5][1], aDesBox[nPosDB][5][2], &("HS_Color(" + aDesBox[nPosDB][5][3] + ")"))
					EndIf
					oPrint:Box(aDesBox[nPosDB][1], aDesBox[nPosDB][2], aDesBox[nPosDB][3], aDesBox[nPosDB][4], oTPen)
				Next nPosDB
     
				For nPosDR := 1 To Len(aDesRec)
					oTBrush := Nil
				If Len(aDesRec[nPosDR]) >= 2
					oTBrush := tBrush():New("", &("HS_Color(" + aDesRec[nPosDR][2] + ")"))
				EndIf
					oPrint:FillRect(aDesRec[nPosDR][1], oTBrush)
				Next nPosDR
      
			ElseIf cModImp == "1" // 1=Txt S/Cabec
				Cabec(Titulo, Cabec1, Cabec2, NomeProg, H44GetTam(), H44GetTip())
				nLin := 6  
				__nPagFic++
			Else      
				__nPagFic++
				SendPrtInfo(H44GetTam(), H44GetTip())
				nLin := 0           
				If __nPagFic > 1
					Eject
				EndIf
			EndIf   
                 
			For nForImp := 1 To Len(aTxtCabec)
				If SubStr(aTxtCabec[nForImp], 1, 3) == "#DF" // Sinaliza troca de Font
					nPosDF := Val(SubStr(aTxtCabec[nForImp], 4))
					Loop
				EndIf 
		    
				If cModImp == "4" // 4=Imagem
					If SubStr(aTxtCabec[nForImp], 1, 3) == "#BM" //sinaliza impressão de logotipo
						nPosBM := Val(SubStr(aTxtCabec[nForImp], 4))
						oPrint:SayBitMap(nLin, aBitMap[nPosBM][1], aBitMap[nPosBM][2], aBitMap[nPosBM][3], aBitMap[nPosBM][4],, aBitMap[nPosBM][5])
						nLin += aBitMap[nPosBM][4]
					ElseIf SubStr(mLinhaArq, 1, 3) == "#CB" //sinaliza impressão de codigo de barras
						nPosCB := Val(SubStr(aTxtCabec[nForImp], 4))                                                                                                             
//						MSBAR3(aCodBar[nPosCB][1], nLin, aCodBar[nPosCB][2], aCodBar[nPosCB][3], oPrint, aCodBar[nPosCB][4], aCodBar[nPosCB][5], aCodBar[nPosCB][6], aCodBar[nPosCB][7], aCodBar[nPosCB][8], aCodBar[nPosCB][9], aCodBar[nPosCB][10], aCodBar[nPosCB][11], aCodBar[nPosCB][12])						
						MSBAR3(aCodBar[nPosCB][1], aCodBar[nPosCB][2], aCodBar[nPosCB][3], aCodBar[nPosCB][4], oPrint, aCodBar[nPosCB][5], aCodBar[nPosCB][6], aCodBar[nPosCB][7], aCodBar[nPosCB][8], aCodBar[nPosCB][9], aCodBar[nPosCB][10], aCodBar[nPosCB][11], aCodBar[nPosCB][12], aCodBar[nPosCB][13])						
						nLin += aCodBar[nPosCB][8]
					Else
						oPrint:Say(nLin, 000, RTrim(aTxtCabec[nForImp]), aFont[nPosDF][1],, aFont[nPosDF][2], /*nBkMode*/)
						nLin += nTLinImp
					EndIf 
				Else    
					@ nLin,000 PSAY RTrim( aTxtCabec[nForImp] )
					nLin++
				EndIf 
			Next nForImp
    
			For nForImp := nIniDetal To IIf(nIniDetal + (nTotDetal-1) > Len(aTxtDetal), Len(aTxtDetal), nIniDetal + (nTotDetal-1))
				If nLin > (nQtdLin - (Len(aTxtRodap) * nTLinImp))
					Exit
				Else
					If SubStr(aTxtDetal[nForImp], 1, 3) == "#DF" // Sinaliza troca de Font
						nPosDF := Val(SubStr(aTxtDetal[nForImp], 4))
						Loop
					EndIf
					
					If cModImp == "4" // 4=Imagem
						If SubStr(aTxtDetal[nForImp], 1, 3) == "#BM" //sinaliza impressão de logotipo
							nPosBM := Val(SubStr(aTxtDetal[nForImp], 4))
							
							oPrint:SayBitMap(nLin, aBitMap[nPosBM][1], aBitMap[nPosBM][2], aBitMap[nPosBM][3], aBitMap[nPosBM][4],, aBitMap[nPosBM][5])
							nLin += aBitMap[nPosBM][4]
						ElseIf SubStr(mLinhaArq, 1, 3) == "#CB" //sinaliza impressão de codigo de barras
							nPosCB := Val(SubStr(aTxtDetal[nForImp], 4))                                                                                                             
							MSBAR3(aCodBar[nPosCB][1], aCodBar[nPosCB][2], aCodBar[nPosCB][3], aCodBar[nPosCB][4], oPrint, aCodBar[nPosCB][5], aCodBar[nPosCB][6], aCodBar[nPosCB][7], aCodBar[nPosCB][8], aCodBar[nPosCB][9], aCodBar[nPosCB][10], aCodBar[nPosCB][11], aCodBar[nPosCB][12], aCodBar[nPosCB][13])
							nLin += aCodBar[nPosCB][8]
						Else
							oPrint:Say(nLin, 000, RTrim(aTxtDetal[nForImp]), aFont[nPosDF][1],, aFont[nPosDF][2], /*nBkMode*/)
							nLin += nTLinImp
						EndIf
					Else
						@ nLin,000 PSAY RTrim( aTxtDetal[nForImp] )
						nLin++
					EndIf
				EndIf
			Next
	   
			nIniDetal := nForImp
	   
			For nForImp := 1 To Len(aTxtRodap)
				If SubStr(aTxtRodap[nForImp], 1, 3) == "#DF" // Sinaliza troca de Font
					nPosDF := Val(SubStr(aTxtRodap[nForImp], 4))
					Loop
				EndIf
				
				If cModImp == "4" // 4=Imagem
					If SubStr(aTxtRodap[nForImp], 1, 3) == "#BM" //sinaliza impressão de logotipo
						nPosBM := Val(SubStr(aTxtRodap[nForImp], 4))
						oPrint:SayBitMap(nLin, aBitMap[nPosBM][1], aBitMap[nPosBM][2], aBitMap[nPosBM][3], aBitMap[nPosBM][4],, aBitMap[nPosBM][5])
						nLin += aBitMap[nPosBM][4]
					ElseIf SubStr(mLinhaArq, 1, 3) == "#CB" //sinaliza impressão de codigo de barras
						nPosCB := Val(SubStr(aTxtRodap[nForImp], 4))                                                                                                             
						MSBAR3(aCodBar[nPosCB][1], aCodBar[nPosCB][2], aCodBar[nPosCB][3], aCodBar[nPosCB][4], oPrint, aCodBar[nPosCB][5], aCodBar[nPosCB][6], aCodBar[nPosCB][7], aCodBar[nPosCB][8], aCodBar[nPosCB][9], aCodBar[nPosCB][10], aCodBar[nPosCB][11], aCodBar[nPosCB][12], aCodBar[nPosCB][13])
						nLin += aCodBar[nPosCB][8]
					Else
						oPrint:Say(nLin, 000, RTrim(aTxtRodap[nForImp]), aFont[nPosDF][1],, aFont[nPosDF][2], /*nBkMode*/)
						nLin += nTLinImp
					EndIf
				Else
					oPrint:Say(nLin, 000, RTrim( aTxtRodap[nForImp]), aFont[nPosDF][1],, aFont[nPosDF][2], /*nBkMode*/)
					nLin++
				EndIf
			Next nForImp
    	End
	EndIf
  
	If cModImp == "4" // 4=Imagem
		oPrint:EndPage()
	EndIf

 Next nVias
  
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_ITENSF º Autor ³ Saude              º Data ³  23/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//aCpos := {{Campo, Picture, cAliasOrig, cCpoOrig, cCondOrig, nTamCpo}}

Function HS_ITENSF(cAlias, nOrdem, cCondicao, aCpos, nItensTot, cGrpBy, aCpoQbr, lTitSx3)
Local aArea     := GetArea()
Local nCtaIte   := 0
Local cSql      := ""
Local aStruct   := {}, aJoin := {}, nJoin := 0, nCpos := 0
Local aRet      := {}
Local cLinha    := ""
Local aPos      := {}//Nome Campo, Posicao aCpos, Posicao aCpoQbr, Ultimo Valor
Local nPos      := 0
Local lImpQbr   := .F.
Local lImpCab   := .T.
Local lDistinct := .F.
Local nTabela   := 0    
Local lCpAlias	:= .F.
Local aStruRec	:= {}		// Array criado para pegar o recno de campo memo

Private cQuery    := ""
Private cPref     := ""
 
Default nItensTot := 0
Default cGrpBy    := ""               
Default aCpoQbr   := {}
Default lTitSx3   := .F.
 
	
If ValType(cAlias) == "C"
	cAlias     := {cAlias}
	nOrdem     := {nOrdem}
	cCondicao  := {cCondicao}
	aCpos      := {aCpos}
	nItensTot  := {nItensTot}
EndIf
	
For nTabela := 1 to Len(cAlias)
	 
	cSql  += IIF(!Empty(cSql)," UNION ","") + " SELECT " 
	aJoin := {}
	//{{Campo, Picture, cAliasOrig, cCpoOrig, cCondOrig, cAliasCpo}}
	For nCpos := 1 To Len(aCpos[nTabela])
			   	  
		lCpAlias := (Len(aCpos[nTabela][nCpos]) == 7) .And. !Empty(aCpos[nTabela][nCpos, 7])
   
		If !Empty(aCpos[nTabela][nCpos][5])

			aAdd(aJoin, "LEFT JOIN " + RetSqlName(aCpos[nTabela][nCpos, 3]) + " " + aCpos[nTabela][nCpos, 3] + " " + ;
				"ON " + aCpos[nTabela][nCpos, 3] + "." + PrefixoCpo(aCpos[nTabela][nCpos, 3]) + "_FILIAL = '" + xFilial(aCpos[nTabela][nCpos, 3]) + "' AND " + ;
				aCpos[nTabela][nCpos, 3] + ".D_E_L_E_T_ <> '*' AND " + aCpos[nTabela][nCpos, 5])
		EndIf
		
		aStruRec := Hs_CfgSX3(aCpos[nTabela][nCpos, 1])
		
		If Len(aStruRec) > 0 .and. aStruRec[SX3->(FieldPos("X3_TIPO"))] == "M"	//Tratamento para campos Memo (pega o RECNO do mesmo)
			aCpos[nTabela][nCpos, 4] := cAlias[nTabela]+".R_E_C_N_O_ "
		EndIf
	  
		cSql += IIF(!Empty(aCpos[nTabela][nCpos, 4]), aCpos[nTabela][nCpos, 4], "") + " "
		
		If !lCpAlias
			cSql += aCpos[nTabela][nCpos, 1] 
		Else
			cSql += IIF(!Empty(aCpos[nTabela][nCpos, 4]),aCpos[nTabela][nCpos, 7],aCpos[nTabela][nCpos, 1]+" "+aCpos[nTabela][nCpos, 7])	  
		EndIf
	  
		cSql += IIf(nCpos < Len(aCpos[nTabela]), ", ", " ")
 	  
		If ((nPos := aScan(aCpoQbr,{|aVet| aVet == aCpos[nTabela][nCpos, 1] .Or. (lCpAlias .And. aVet == aCpos[nTabela][nCpos, 7]) })) > 0) ;
			.And. (lCpAlias .And. (aScan(aPos,{|aVet| aVet[1] == aCpos[nTabela][nCpos, 7] }) ) == 0)
			aAdd(aPos,{IIF(lCpAlias,aCpos[nTabela][nCpos, 7],aCpos[nTabela][nCpos, 1]),nCpos, nPos, IIF(Len(TamSx3(aCpos[nTabela][nCpos, 1])) > 0, IIF(TamSx3(aCpos[nTabela][nCpos, 1])[3] == "N",0,""),"")})//Nome Campo, Posicao aCpos, Posicao aCpoQbr, Ultimo Valor    
		EndIf
	Next nCpos

	lDistinct := IIF(!lDistinct,"DISTINCT" $ cSql,lDistinct)
	
	aSort(aPos,,,{|x,y| x[3] < y[3]})    
	 	
	cSql += "FROM " + RetSqlName(cAlias[nTabela]) + " " + cAlias[nTabela] + " "
	 
	For nJoin := 1 To Len(aJoin)
		cSql += aJoin[nJoin] + " "
	next nJoin
	 
	cSql += "WHERE " + cCondicao[nTabela] + " "
	 	
Next nTabela
  
If !Empty(cGrpBy)
	cSql += " GROUP BY " + cGrpBy
EndIf
	 
If !lDistinct
	cSql += " ORDER BY "
	If !Empty(cGrpBy)
		cSql += cGrpBy
	ElseIf Len(aPos) > 0
		For nPos := 1 to Len(aPos)
			cSql += aPos[nPos][1]+IIF(nPos == Len(aPos),"",", ")
		Next nPos
	Else
		cSql +=  SqlOrder((cAlias[1])->(IndexKey(nOrdem[1])))
	EndIF
EndIf
                          
	 
cSql := ChangeQuery(cSql)
 
TCQuery cSql New Alias "TMP" + cAlias[1]
 
cQuery := "TMP" + cAlias[1]

For nTabela := 1 To Len(cAlias)
	nCtaIte := 0
	For nCpos := 1 To Len(aCpos[nTabela])
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek(aCpos[nTabela][nCpos, 1])
			aStruct := HS_CfgSx3(aCpos[nTabela][nCpos, 1])
			If aStruct[Sx3->(FieldPos("X3_CONTEXT"))] <> "V" .And. aStruct[Sx3->(FieldPos("X3_TIPO"))] $ "D/N"
				TCSetField(cQuery, aCpos[nTabela][nCpos, 1], aStruct[Sx3->(FieldPos("X3_TIPO"))], aStruct[Sx3->(FieldPos("X3_TAMANHO"))], aStruct[Sx3->(FieldPos("X3_DECIMAL"))])
			EndIf
		EndIf
	Next nCpos

	DbSelectArea(cQuery)
	
	Do While !Eof()
	 
		cLinha := ""
	  
		For nPos := 1 to Len(aPos)//NOme campo, pos acpo, pos acpoqbr, ultimo valor
			DbSelectArea(cQuery)
			If &(aPos[nPos, 1]) # aPos[nPos, 4]
				aPos[nPos, 4] := &(aPos[nPos, 1]) 
	    
				If !lImpQbr 
					cLinha += chr(13) + chr(10) 
					If lTitSx3 .And. lImpCab
						lImpCab := .F.
						cLinha += FS_ImpCab(aPos, aCpos[nTabela], lTitSx3)
						For nCpos := 1 to Len(aCpos[nTabela])     
	       					lCpAlias := (Len(aCpos[nTabela][nCpos]) == 7) .And. !Empty(aCpos[nTabela][nCpos, 7])
	       					If ((nPos := aScan(aCpoQbr,{|aVet| aVet == aCpos[nTabela][nCpos, 1] .Or. (lCpAlias .And. aVet == aCpos[nTabela][nCpos, 7]) })) == 0)
	        					cLinha += FS_ImpCpo(aCpos[nTabela], nCpos, lTitSx3)+" "
	       					EndIf   
	      				Next nCpos    
	      				cLinha += chr(13) + chr(10) 
	     			EndIf
	     			cLinha += FS_ImpCab(aPos, aCpos[nTabela])
	     			lImpQbr := .T.
	    		EndIf          
	    
			EndIf
		Next nPos
	  
		For nCpos := 1 to Len(aCpos[nTabela])     
			lCpAlias := (Len(aCpos[nTabela][nCpos]) == 7) .And. !Empty(aCpos[nTabela][nCpos, 7])	   
			If ((aScan(aCpoQbr,{|aVet| aVet == aCpos[nTabela][nCpos, 1] .Or. (lCpAlias .And. aVet == aCpos[nTabela][nCpos, 7]) })) == 0)   
				cLinha += FS_ImpCpo(aCpos[nTabela], nCpos)+" "
			EndIf
	    Next nCpos    
	  
		aAdd(aRet, cLinha)
		nCtaIte++
	  
		If IIf(nItensTot[nTabela] >  0, nCtaIte >= nItensTot[nTabela], .F.)
			Exit
		EndIf                                                                                        	
  
		lImpQbr := .F.
		DbSkip()
	End                         
Next nTabela
 
DbSelectArea(cQuery)
DbCloseArea()
RestArea(aArea)
Return( IIf(Len(aRet) > 0,aRet,{""}))


Static Function FS_ImpCab(aPos, aCpos, lTitSx3)
 Local aArea     := GetArea() 
 Local nI
 Local cRet := ""
 
 Default lTitSx3 := .F.
           
 For nI := 1 to Len(aPos)
  cRet += FS_ImpCpo(aCpos, aPos[nI, 2], lTitSx3)+" "
 Next nI
 
 cRet += chr(13)+chr(10)          
 RestArea(aArea)

Return(cRet)


Static Function FS_ImpCpo(aCpos, nCpos, lTitSx3)

Local aArea     := GetArea() 
Local cRet      := ""    
Local lCpAlias  := (Len(aCpos[nCpos]) >= 7) .And. !Empty(aCpos[nCpos, 7])
Local lTitCpo   := (Len(aCpos[nCpos]) == 8) .And. !Empty(aCpos[nCpos, 8])
Local cCampo   := ""
Local cTitulo  := ""
 
Default lTitSx3 := .F.
 
DbSelectArea("SX3")
DbSetOrder(2)                        
	 
If DbSeek(aCpos[nCpos, 1])
	aStruct := HS_CfgSx3(aCpos[nCpos, 1])   
 
	If lTitSx3                
 		cRet := IIF(lTitCpo,aCpos[nCpos, 8],Trim(aStruct[Sx3->(FieldPos("X3_TITULO"))])) 
   		cRet := &(IIF(aStruct[Sx3->(FieldPos("X3_TIPO"))] == "N","PADL('","PADR('")+cRet+"',"+Str(aCpos[nCpos, 6])+")")
		Return(cRet)
	EndIf                  

	cCampo := IIF(lCpAlias,aCpos[nCpos, 7],aCpos[nCpos, 1])
	 
	DbSelectArea(cQuery)
	 
	If aStruct[Sx3->(FieldPos("X3_TIPO"))] == "D"
		cRet := PadR(DTOC(IIF(VALTYPE(&(cCampo)) == 'D',&(cCampo),STOD(&(cCampo)))), aCpos[nCpos, 6])
	ElseIf aStruct[Sx3->(FieldPos("X3_TIPO"))] == "M"	//Tratamento para campos MEMO (posiciona no RECNO para pegar o conteudo).
		&(aStruct[Sx3->(FieldPos("X3_ARQUIVO"))]+"->(DbGoTo("+AllTrim(Str(&(cCampo)))+"))")
		cRet :=	&(aStruct[Sx3->(FieldPos("X3_ARQUIVO"))]+"->"+cCampo)
	Else
		cRet := PadR(Transform(&(cCampo), IIf(!Empty(aCpos[nCpos, 2]), aCpos[nCpos, 2], aStruct[Sx3->(FieldPos("X3_PICTURE"))])), aCpos[nCpos, 6])
	EndIf
ElseIf !Empty(aCpos[nCpos, 4])                                                                                     
	cCampo := IIF(lTitCpo .And. lTitSx3,aCpos[nCpos, 8],IIF(lCpAlias,aCpos[nCpos, 7],aCpos[nCpos, 1]))
	 
	If !lTitSx3
		If !Empty(aCpos[nCpos, 2])
	   		cCampo := Transform(&(cQuery+"->"+cCampo),aCpos[nCpos, 2])
   		Else
    		cCampo := &(cQuery+"->"+cCampo)
  		EndIf
  		cRet := PadR(cCampo, aCpos[nCpos, 6])
 	Else
  		cRet := &(IIF(!Empty(aCpos[nCpos, 2]),"PADL('","PADR('")+cCampo+"',"+Str(aCpos[nCpos, 6])+")")
 	EndIf
EndIf 

RestArea(aArea)

Return(cRet)
 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ParseL º Autor ³ Saude              º Data ³  24/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FS_ParseL( mLinhaArq )
Local nPosicao := 0
Local nTamanho := 0
Local cWLinha  := ""
Local lAIniTxt := ""          
Local nI
Local cTpTempor := "" 
Private cTempor  := ""

If AT("#"+"A", mLinhaArq) == 0
	cWLinha := mLinhaArq
Else 
 
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ LOOP NA LINHA SE ELA TIVER MACRO PARA INTERPRETAR SE NAO IMPRIME A LINHA DIRETAMENTE  ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	WHILE (nPosicao := AT("#"+"A", mLinhaArq)) > 0 
  
		nTamanho := Val(SubStr(mLinhaArq, nPosicao+2, aT(" ",SubStr(mLinhaArq, nPosicao+2))-1))  /* PEGA O TAMANHO DA INSTRUCAO DA MACRO */
   
		If nTamanho > 1023
			For nI := 1 to nTamanho/1023
				FT_FSkip()
				mLinhaArq += FT_FReadLn()
			Next nI
		EndIf

    
		cTempor  := SUBS( mLinhaArq , nPosicao + aT(" ",SubStr(mLinhaArq, nPosicao)) + 1, nTamanho ) /* PEGA A INSTRUCAO DA MACRO            */
		cTempor  := &(cTempor)                                  /* INTERPRETA A INSTRUCAO DA MACRO      */
       cTpTempor := VALTYPE(cTempor)
		/* LINHA DE SUBSTITUICAO COM CARACTERES ANTERIORES A MACRO INTERPRETADA DA LINHA LIDA. */
		cWLinha    := cWLinha + SUBS( mLinhaArq , 1, nPosicao-1 ) 
		
		lAIniTxt := .T.  
  
		If cTpTempor == "N"
			cTempor := STR( cTempor )
		ElseIf cTpTempor == "D"
			cTempor := DTOC( cTempor )
		ElseIf cTpTempor == "A"
			cTempor := FS_ArrayTotxt(cTempor, cWLinha)
			lAIniTxt := .F.
		EndIf

		/* EXTRAI A MACRO SUA INSTRUCAO E SEUS CARACTERES ANTERIORES DA LINHA LIDA PARA NAO LE-LA NOVAMENTE. */
		mLinhaArq  := SUBS( mLinhaArq , (nPosicao + 7 + nTamanho) , (Len(mLinhaArq) - nPosicao + 7 + nTamanho) ) 
   
		If lAIniTxt
			cWLinha := cWLinha + cTempor        /* ACRESCENTA A MACRO LIDA NA LINHA DE SUBSTITUICAO      */
		Else
			cWLinha := cTempor
		EndIf 
	End
  
EndIf 
Return( cWLinha )


Static Function FS_TxtToArray(aTxtDetal, cTexto)
Local nLinha := 0
 
If Empty(AllTrim(cTexto))
	aAdd(aTxtDetal, MemoLine(cTexto,, nLinha))
Else
	For nLinha := 1 To MLCount(cTexto)
		aAdd(aTxtDetal, MemoLine(cTexto,, nLinha))
	Next nLinha
EndIf 

 
Return(Nil)                                  


Static Function FS_ArrayTotxt(aTexto, cIniTxt)
Local cTexto := "", nLinha := 1
 
For nLinha := 1 To Len(aTexto)
	cTexto += cIniTxt + aTexto[nLinha] + Chr(13) + Chr(10)
Next nLinha
 
Return(cTexto)


Function HS_Color(vColor)
Local nRGBColor := 0
               
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
//                        Low Intensity colors
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
If ValType(vColor) == "A"
	If Len(vColor) >= 3
		nRGBColor := RGB(vColor[1], vColor[2], vColor[3])
	EndIf 
ElseIf vColor == 0 
	nRGBColor := CLR_BLACK//             0               // RGB(   0,   0,   0 )
ElseIf vColor == 1 
	nRGBColor := CLR_BLUE//        8388608               // RGB(   0,   0, 128 )
ElseIf vColor == 2 
	nRGBColor := CLR_GREEN//         32768               // RGB(   0, 128,   0 )
ElseIf vColor == 3 
	nRGBColor := CLR_CYAN//        8421376               // RGB(   0, 128, 128 )
ElseIf vColor == 4 
	nRGBColor := CLR_RED//             128               // RGB( 128,   0,   0 )
ElseIf vColor == 5
	nRGBColor := CLR_MAGENTA//     8388736               // RGB( 128,   0, 128 )
ElseIf vColor == 6
	nRGBColor := CLR_BROWN//         32896               // RGB( 128, 128,   0 )
ElseIf vColor == 7
	nRGBColor := CLR_HGRAY//      12632256               // RGB( 192, 192, 192 )
ElseIf vColor == 8
	nRGBColor := CLR_LIGHTGRAY//  CLR_HGRAY
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
//                       High Intensity Colors
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
ElseIf vColor == 9
	nRGBColor := CLR_GRAY//        8421504               // RGB( 128, 128, 128 )
ElseIf vColor == 10
	nRGBColor := CLR_HBLUE//      16711680               // RGB(   0,   0, 255 )
ElseIf vColor == 11
	nRGBColor := CLR_HGREEN//        65280               // RGB(   0, 255,   0 )
ElseIf vColor == 12
	nRGBColor := CLR_HCYAN//      16776960               // RGB(   0, 255, 255 )
ElseIf vColor == 13
	nRGBColor := CLR_HRED//            255               // RGB( 255,   0,   0 )
ElseIf vColor == 14
	nRGBColor := CLR_HMAGENTA//   16711935               // RGB( 255,   0, 255 )
ElseIf vColor == 15
	nRGBColor := CLR_YELLOW//        65535               // RGB( 255, 255,   0 )
ElseIf vColor == 16
	nRGBColor := CLR_WHITE//      16777215               // RGB( 255, 255, 255 )
Else
	nRGBColor := vColor // CASO TENHA PASSADO VALOR DO RGB DEFINIDO
EndIf
 
Return(nRGBColor)
