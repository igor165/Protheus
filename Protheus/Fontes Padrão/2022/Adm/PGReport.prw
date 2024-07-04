#INCLUDE "PROTHEUS.CH"
#include "pmsc200.ch"
#include "PROTHEUS.CH"
#include "msgraphi.ch"
#include "pmsicons.ch"

Static aEstiloCab := {2,3,7,0,2,3,7,2,3,7}
Static aFontesCab	:= {2,2,2,2,1,1,1,3,3,3}
Static aEstiloDet := {2,3,7,4,0,2,3,7,4,2,3,7,4}
Static aFontesDet	:= {2,2,2,2,2,1,1,1,1,3,3,3,3}
Static aTotais	:= {}
Static aMedia	:= {}
Static nLastCab	:= 837881
Static cLoad		:= ""
Static lSenha		:= .F.
Static cPlnSenha		:= ""
Static cArqPln		:= ""
Static aLineCalc	:= {}
Static aCabReport	:= {}
Static aCabCol		:= {}
Static nTamCol		:= 0
Static nPgrLin		:= 0
Static nSetCab		:= 0
Static cNamePgr	:= ""
Static cPergunte
Static lRodape
Static nPgrFnt
Static cDetail
Static nOrient
Static aFiltros
Static lForceLand
Static cCallProc	
Static cVrsCfg	

Function PgrIni(cSX1,;	// Grupo de perguntas do relatorio
					cNomeRel,; // Nome do Relatorio
					lImpRoda,; // Indica se imprime rodape
					nFonte,; // Fonte padrao utilizada no relatorio
					cDetRel,; // Texto com detalhes do relatorio ( Opcional )
					nPortLand,; // Orientação da pagina ( Opcional )
					aFilter,; // Filtros para processamento do relatorio ( Opcional )
					lForce,; // Forca a utilização no formato Landscape ( Opcional )
					cVersao) // Versão atual do relatorio ( Opcional ) 

Default nPortLand	:= 1
Default aFilter	:= {}
Default lForce		:= .F.
Default cVersao	:= "001"

cVrsCfg		:= cVersao
lForceLand	:= lForce
aTotais		:= {}
aMedia		:= {}
aLineCalc	:= {}
aCabReport	:= {}
aCabCol		:= {}
nTamCol		:= 0
nPgrLin		:= 20000
nSetCab		:= 0
cArqPln		:= "\PROFILE\"+AllTrim(ProcName(1))+".PGR"
cCallProc	:= ProcName(1)
cPergunte	:= cSX1
cNamePgr		:= cNomeRel
lRodape		:= lImpRoda
nPgrFnt		:= nFonte
cDetail		:= cDetRel
nOrient		:= nPortLand
aFiltros 	:= aFilter

Return

Function PgrDialog(lOk)

ChkPLN(cArqPLN)

Return PcoPrtIni(AllTrim(cNamePgr),lForceLand,nPgrFnt,lRodape,@lOk,cPergunte,cDetail,.F.,nOrient,aFiltros)


Function PgrAddCab(	lAutoAlign,; // 1 Auto alinhamento ligado 
							nAutoAlign,; // 2 Auto alinhamento sera efetuado pela coluna 2 ( opcional )
							nAltCab,; // 3 Altura do cabeçalho
							nAltLin,; // 4 Altura da linha
							cAlias,; // 5 Alias opcional
							aCampos ,;// 6 Campos fixos calculados pelo sistema disponiveis ao usuario
							aCpsExc ,; // 7 Campos que nao podem ser selecionados
							nStilPad,; // 8 Estilo padrao do cabecalho
							nStilo,; // 9 Estilo padrao da celula
							nFontePad,; // 10 Fonte Padrao do cabecalho
							nFonte,; // 11 Fonte Padrao da celula
							nColorCab,; // 12 Cor do Cabecalho padrao
							nColorCell,; // 13 Cor da Celula padrao
							cNameCab,;  // 14 Nome do Cabeçalho
							lCabChange,;  // 15 Imprime o cabeçalho nas mudancas dos detalhes
							lIniPag )  // 16 Sempre inicia uma nova pagina para este cabeçalho

Default aCpsExc	:= {}
Default nStilPad	:= 1 
Default nStilo	:= 1 
Default nFontePad	:= 2
Default nFonte	:= 2
Default nColorCab	:= RGB(255,255,255)
Default nColorCell:= RGB(255,255,255)
Default cNameCab	:= "Detalhes"
Default lCabChange := .T.
Default lIniPag := .F.

If cAlias <> Nil .And. cNameCab == Nil
	dbSelectArea("SX2")
	dbSetOrder(1)
	dbSeek(cAlias)
	cNameCab := X2NOME()
EndIf
							
aAdd(aCabReport,{lAutoAlign,nAutoAlign,nAltCab,cAlias,{},{},nAltLin,aCampos,aCpsExc,nStilPad,nFontePad,nColorCab,nColorCell,nStilo,nFonte,Nil,cNameCab,lCabChange,lIniPag})
nTamCol		:= 20

Return .T.

Function PgrCabCell(	nCab,;	// Numero de referencia do cabeçalho ( obrigatorio )
							nTamanho,; // Tamanho da celula ( obrigatorio )
							nEstilo,; 	// Estilo da celula do cabeçalho ( obrigatorio )
							nFonte,;	// Fonte ( obrigatorio )
							nColor,; //Cor de fundo ( obrigatorio )
							lAlignCell,; // Alinhado a direita ? ( obrigatorio )
							cCampo,; // Campo de referencia do cabeçalho  ( obrigatorio )
							xReserv1,; // Reservado
							cPicture,;  // Picture ( opcional )
							nStiloCab,; // Estilo do cabecalho
							nFonteCab,; // Fonte do cabecalho
							nColorCab,; // Cor do Cabecalho
							cBlock,;	// Bloco de codigo para interpretacao de formulas
							cSayCab )	// Texto do cabecalho
							

Default nStiloCab	:= aCabReport[nCab,14]
Default nEstilo		:= aCabReport[nCab,10]
Default nColor		:= aCabReport[nCab,13]
Default nColorCab := aCabReport[nCab,12]

If Substr(cCampo,1,1) <> "$"
	dbSelectArea("SX3")
	dbSetOrder(2)
	If MsSeek(cCampo)
		If cSayCab == Nil 
			cSayCab := AllTrim(X3TITULO())
		EndIf
		If cPicture == Nil
			cPicture := X3_PICTURE
		EndIf
	EndIf
EndIf
aAdd(aCabReport[nCab][5],{nEstilo,nFonte,nColor,lAlignCell,cCampo,xReserv1,cPicture,nStiloCab,nFonteCab,nColorCab,xReserv1,cSayCab,nTamanho,cBlock})
aAdd(aCabReport[nCab][6],nTamCol)
nTamCol += nTamanho

Return


Function PgrSetCab(oPrint,nCab) // Seta o cabeçalho para impressão
Local nx
Local aCab := {}
nSetCab	:= nCab  
If aCabReport[nCab][2] == 0 .And. aCabReport[nCab][1]
	aAdd(aCab,0)
	For nx := 1 to Len(aCabReport[nCab][6])-1
		aAdd(aCab,aCabReport[nCab][6][nx])
	Next nx
	PcoPrtCol(aCab,aCabReport[nCab][1],aCabReport[nCab][2])
Else
	PcoPrtCol(aCabReport[nCab][6],aCabReport[nCab][1],aCabReport[nCab][2])
EndIf


Return


Function PgrEndCab(nCab)

aAdd(aCabReport[nCab][6],nTamCol)

Return 


Function PgrPrtCalc(cCampo,xValor)

aAdd(aLineCalc,{cCampo,xValor})

Return

Function PgrGetCalc(cCampo)
Local xValor	
Local nPos := aScan(aLineCalc,{|x| x[1] == cCampo})
If nPos > 0
	xValor := aLineCalc[nPos][2]
EndIf

Return xValor

Function PgrAddLin(oPrint) // 	Tamanho do salto de linha

aLineCalc	:= {}

Return

Function PgrEndLin(oPrint,nSize) // 	Tamanho do salto de linha
Local aProcForm	:= {}
Local lImprCab		:= .F.
Local lImprDet		:= .F.
Local nx
Default nSize := 30

If PcoPrtLim(nPgrLin) .Or. ( nLastCab<>nSetCab .And. aCabReport[nSetCab,18]) .Or. (aCabReport[nSetCab,19] .And. nPgrLin > 200 )
	If PcoPrtLim(nPgrLin) .Or. aCabReport[nSetCab,19]
		nPgrLin := 200
		PcoPrtCab(oPrint)
		nPgrLin += aCabReport[nSetCab][3]+5
	EndIf
	For nx := 1 to Len(aCabReport[nSetCab][5]) // Imprime todas as celulas configuradas do cabecalho
		If aEstiloCab[aCabReport[nSetCab][5][nx][1]] <> 0
						PcoPrtCell(	PcoPrtPos(nx),;  // nPosX
										nPgrLin,; //nPosY
										PcoPrtTam(nx),; // nTamanho
										aCabReport[nSetCab][3],; //nAltura 
										aCabReport[nSetCab][5][nx][12],; // cSay
										oPrint,; //oPrint
										aEstiloCab[aCabReport[nSetCab][5][nx][1]],; //Estilo da PcoPrint
										aFontesCab[aCabReport[nSetCab][5][nx][1]],; //nFonte
										aCabReport[nSetCab][5][nx][10],; //nColor
										,; //cToolTip
										aCabReport[nSetCab][5][nx][4],; //lAlinDir
										,; //cCampo
										) //cPicture
			lImprCab := .T.
		EndIf
	Next
	If lImprCab
		nLastCab:= nSetCab
		nPgrLin += aCabReport[nSetCab][3]+5
	EndIf
EndIf



nCntLet := 0
nCount := 0						
For nx := 1 to Len(aCabReport[nSetCab][5]) // Imprime todas as celulas configuradas da linha
			If Substr(aCabReport[nSetCab][5][nx][5],1,1)== "$" // Campo Fixo Calculado
				xValor := PgrGetCalc(aCabReport[nSetCab][5][nx][5])
				nCntLet++
				If nCntLet > 26
					nCntLet	:= 1
					nCount++
				EndIf
				If nCount > 0
					&(Chr(64+nCntLet)+Chr(48+nCount)) := xValor
				Else
					&(Chr(64+nCntLet)) := xValor
				EndIf
				If aEstiloDet[aCabReport[nSetCab][5][nx][8]] <> 0
					PcoPrtCell(	PcoPrtPos(nx),;  // nPosX
									nPgrLin,; //nPosY
									PcoPrtTam(nx),; // nTamanho
									aCabReport[nSetCab][7],; //nAltura 
									xValor,; // cSay
									oPrint,; //oPrint
									aEstiloDet[aCabReport[nSetCab][5][nx][8]],; //nStilo
									aFontesDet[aCabReport[nSetCab][5][nx][8]],; //nFonte
									aCabReport[nSetCab][5][nx][3],; //nColor
									aCabReport[nSetCab][5][nx][12],; //cToolTip
									aCabReport[nSetCab][5][nx][4],; //lAlinDir
									,; //cCampo
									aCabReport[nSetCab][5][nx][7] ) //cPicture
					lImprDet	:= .T.								
				EndIf
			ElseIf Substr(aCabReport[nSetCab][5][nx][5],1,1)=="%"
				nCntLet++
				If nCntLet > 26
					nCntLet	:= 1
					nCount++
				EndIf
				If nCount > 0
					aAdd(aProcForm,{nx,Chr(64+nCntLet)+Chr(48+nCount)})
				Else
					aAdd(aProcForm,{nx,Chr(64+nCntLet)})
				EndIf
			Else
				dbSelectArea(aCabReport[nSetCab][4])
				xValor := &(aCabReport[nSetCab][5][nx][5])
				nCntLet++
				If nCntLet > 26
					nCntLet	:= 1
					nCount++
				EndIf
				If nCount > 0
					&(Chr(64+nCntLet)+Chr(48+nCount)) := xValor
				Else
					&(Chr(64+nCntLet)) := xValor
				EndIf
				If aEstiloDet[aCabReport[nSetCab][5][nx][8]] <> 0				
					PcoPrtCell(	PcoPrtPos(nx),;  // nPosX
									nPgrLin,; //nPosY
									PcoPrtTam(nx),; // nTamanho
									aCabReport[nSetCab][7],; //nAltura 
									xValor,; // cSay
									oPrint,; //oPrint
									aEstiloDet[aCabReport[nSetCab][5][nx][8]],; //nStilo
									aFontesDet[aCabReport[nSetCab][5][nx][8]],; //nFonte
									aCabReport[nSetCab][5][nx][3],; //nColor
									aCabReport[nSetCab][5][nx][12],; //cToolTip
									aCabReport[nSetCab][5][nx][4],; //lAlinDir
									,; //cCampo
									aCabReport[nSetCab][5][nx][7] ) //cPicture
					lImprDet	:= .T.								
				EndIf
			EndIf
Next nx

bBlock  := ErrorBlock({|e| ChecErro(e)}) // salva o manipulador de erro padrao
cBlock	:= ""
cCmpPLN	:= aCabReport[nSetCab][16]

For nx := 1 to Len(aProcForm)
	Begin Sequence
	If RepVar(@cBlock,aCabReport[nSetCab][5][aProcForm[nx,1]][14] )==-1
		Alert("Erro processando o campo " + "="+cBlock)
		Return .F.
	EndIf
	xValor := &(cBlock)
	&(aProcForm[nx,2]) := xValor
	If aEstiloDet[aCabReport[nSetCab][5][aProcForm[nx,1]][8]] <> 0	
		PcoPrtCell(	PcoPrtPos(aProcForm[nx,1]),;  // nPosX
						nPgrLin,; //nPosY
						PcoPrtTam(aProcForm[nx,1]),; // nTamanho
						aCabReport[nSetCab][7],; //nAltura 
						xValor,; // cSay
						oPrint,; //oPrint
						aEstiloDet[aCabReport[nSetCab][5][aProcForm[nx,1]][8]],; //nStilo
						aFontesDet[aCabReport[nSetCab][5][aProcForm[nx,1]][8]],; //nFonte
						aCabReport[nSetCab][5][aProcForm[nx,1]][3],; //nColor
						aCabReport[nSetCab][5][aProcForm[nx,1]][12],; //cToolTip
						aCabReport[nSetCab][5][aProcForm[nx,1]][4],; //lAlinDir
						,; //cCampo
						aCabReport[nSetCab][5][aProcForm[nx,1]][7] ) //cPicture
		lImprDet	:= .T.
	EndIf
	Recover
		Alert("Erro na formula "+aCabReport[nSetCab][5][aProcForm[nx,1]][12])
	End Sequence
Next

// restaura o manipulador de erros padrao
ErrorBlock(bBlock)


If lImprDet
	nLastCab:= nSetCab
	nPgrLin += Max(nSize,aCabReport[nSetCab][7]+4)
EndIf


Return


Function ChkPLN(cArqPLN)
    
Local aFunc	
Local lCompativel := .F.
Local nx	:= 0
Local cWrite	:= ""  
Local cMvFldPln := ""
Local nCount	:= 0
Local ny

If !File(cArqPLN)

	cWrite := AllTrim(cCallProc)+"003"+cVrsCfg+Chr(13)+Chr(10)  // arquivo sem codificacao
	cWrite += " "+Chr(13)+Chr(10)
	cWrite += Embaralha(Padr(cNamePgr,80)+Str(nOrient,1)+Str(nPgrFnt,1)+If(lForceLand,"1","2"), 1)+Chr(13)+Chr(10)
	For nx := 1 to Len(aCabReport)
		// campos padroes
		cMvFldPln:= ""
		For nCount := 1 to Len(aCabReport[nx][5])
			cMvFldPln := Str(nx,4)+("_"+Padr(aCabReport[nx][5][nCount][5],10)+;   
											If(aCabReport[nx][5][nCount][1]<>Nil,Str(aCabReport[nx][5][nCount][1],2),"  ")+; //Estilo  11,2
											If(aCabReport[nx][5][nCount][2]<>Nil,Str(aCabReport[nx][5][nCount][2],2),"  ")+; //Fonte  15,2
											If(aCabReport[nx][5][nCount][3]<> Nil,Str(aCabReport[nx][5][nCount][3],10),SPACE(10))+; //Cor 17,10
											If(aCabReport[nx][5][nCount][4],"1","2")+; // Alinhamento 27,1
											If(aCabReport[nx][5][nCount][7]<>Nil,Padr(aCabReport[nx][5][nCount][7],30),SPACE(30))+; //Picture celula 28,30
											If(aCabReport[nx][5][nCount][8]<>Nil,Str(aCabReport[nx][5][nCount][8],2),SPACE(2))+; //Estilo cabecalho 58,2
											If(aCabReport[nx][5][nCount][9]<>Nil,Str(aCabReport[nx][5][nCount][9],2),"  ")+; //Fonte do cabecalho 60,2
											If(aCabReport[nx][5][nCount][10]<>Nil,Str(aCabReport[nx][5][nCount][10],10),SPACE(10))+; //Cor do cabecalho 62,10
											If(aCabReport[nx][5][nCount][12]<>Nil,Padr(aCabReport[nx][5][nCount][12],30),SPACE(30))+; //Texto do cabecalho 72,30
											If(aCabReport[nx][5][nCount][13]<>Nil,Str(aCabReport[nx][5][nCount][13],3),SPACE(3))+; //Tamanho da coluna 102,3
											"#")
	
			cWrite += cMvFldPln+Chr(13)+Chr(10)
	
		Next

		cMvFldPln := Str(nx,4)+("_@"+If(aCabReport[nx,1],"1","2")+; // Auto Align
								Str(aCabReport[nx,3],3)+; // Altura Cabecalho
								Str(aCabReport[nx,2],2)+; // Celula de Auto Size
								Str(aCabReport[nx,7],3)+; // Espaçamento
								If(aCabReport[nx,18],"1","2")+; // Imprime cabecalho entre as alteracoes
								If(aCabReport[nx,19],"1","2")+; // Salta pagina no cabecalho
								"#")
		
		cWrite += cMvFldPln+Chr(13)+Chr(10)
	
	Next
	
	
	MemoWrit(cArqPLN,cWrite)
	
EndIf

lSenha := .F.

If FT_FUse(cArqPLN)<> -1
	FT_FGOTOP()
	cPLNVer	:= FT_FREADLN()
	If AllTrim(cPLNVer) == AllTrim(cCallProc)+"103"+cVrsCfg
		FT_FSKIP()
		cPLNSenha := FT_FREADLN()
		FT_FSKIP()
		cNamePgr := Substr(Embaralha(FT_FREADLN(),0),1,80)
		nOrient := Val(Substr(Embaralha(FT_FREADLN(),0),81,1))
		nPgrFnt := Val(Substr(Embaralha(FT_FREADLN(),0),82,1))
		lForceLand	:= If(Substr(Embaralha(FT_FREADLN(),0),83,1)=="1",.T.,.F.)
		FT_FSKIP()			
		lSenha := .T.			
		lCompativel := .T.		
	ElseIf AllTrim(cPLNVer) == AllTrim(cCallProc)+"003"+cVrsCfg
		FT_FSKIP()		
		FT_FSKIP()
		cNamePgr := Substr(Embaralha(FT_FREADLN(),0),1,80)
		nOrient := Val(Substr(Embaralha(FT_FREADLN(),0),81,1))
		nPgrFnt := Val(Substr(Embaralha(FT_FREADLN(),0),82,1))
		lForceLand	:= If(Substr(Embaralha(FT_FREADLN(),0),83,1)=="1",.T.,.F.)		
		FT_FSKIP()			
		lSenha	:= .F.
		lCompativel := .T.
	EndIf
		
	If lCompativel
		For nx := 1 to Len(aCabReport)
			aFunc	:= aCabReport[nx][8]
			aCabReport[nx,16] := ReadCab(nx)
			cPln1SX6	:= aCabReport[nx,16]
			aCpsVar2	:= {}
			aCampos2	:= {}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem do array de campos selecionados                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While At("#",cPln1SX6) <> 0
				nPosSep := At("#",cPln1SX6)
				
				If Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),1,1)=="|"
					aAdd(aCpsVar2,{,,,,,,,})
					aCpsVar2[Len(aCpsVar2)][1] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),02,10)  // nome
					aCpsVar2[Len(aCpsVar2)][2] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),13,25)  // titulo
					aCpsVar2[Len(aCpsVar2)][4] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),70,01)  // tipo
					aCpsVar2[Len(aCpsVar2)][5] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),72,02))  // tamanhho
					aCpsVar2[Len(aCpsVar2)][6] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),75,01))  // decimal
					aCpsVar2[Len(aCpsVar2)][7] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),77,60)	 // picture
			
					Do Case
						Case aCpsVar2[Len(aCpsVar2)][4]=="C"
							aCpsVar2[Len(aCpsVar2)][3] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30)
						Case aCpsVar2[Len(aCpsVar2)][4]=="N"
							aCpsVar2[Len(aCpsVar2)][3] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30))
						Case aCpsVar2[Len(aCpsVar2)][4]=="D"
							aCpsVar2[Len(aCpsVar2)][3] := CTOD(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30))
					EndCase		
			
					aCpsVar2[Len(aCpsVar2)][8] := "_|"+PadR(aCpsVar2[Len(aCpsVar2)][1], 10, " ")+;                // nome
																	"|"+PadR(aCpsVar2[Len(aCpsVar2)][2], 25, " ")+;                 // titulo
																	"|"+PadR(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30), 30, " ")+;  // valor  - direto do arquivo
																	"|"+PadR(aCpsVar2[Len(aCpsVar2)][4], 1, " ")+;                   // tipo
																	"|"+StrZero(aCpsVar2[Len(aCpsVar2)][5],2,0)+;                 // tamanho
																	"|"+StrZero(aCpsVar2[Len(aCpsVar2)][6],1,0)+;                 // decimal
																	"|"+PadR(aCpsVar2[Len(aCpsVar2)][7], 60, " ")
				ElseIf Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),1,1)=="@"
					cCab := AllTrim(Substr(cPln1Sx6, 2, nPosSep-2))
			
					aCabReport[nx,1] := If(Substr(cCab,2,1)=="1",.T.,.F.)
					aCabReport[nx,3] := Val(Substr(cCab,3,3))
					aCabReport[nx,2] := Val(Substr(cCab,6,2))
					aCabReport[nx,7] := Val(Substr(cCab,8,3))					
					aCabReport[nx,18] := If(Substr(cCab,11,1)=="1",.T.,.F.)
					aCabReport[nx,19] := If(Substr(cCab,12,1)=="1",.T.,.F.)
				Else
					aAdd(aCampos2,{,})
					aCampos2[Len(aCampos2)][2] := AllTrim(Substr(cPln1Sx6, 2, nPosSep-2))
					If Substr(aCampos2[Len(aCampos2)][2],1,1)=="%"
						aCampos2[Len(aCampos2)][1] := "="+Substr(aCampos2[Len(aCampos2)][2],2,9)
					ElseIf Substr(aCampos2[Len(aCampos2)][2],1,1)=="$"
						nPosFunc := aScan(aFunc,{|x| AllTrim(x[2])==AllTrim(Substr(aCampos2[Len(aCampos2)][2],1,10))})
						If nPosFunc > 0
							aCampos2[Len(aCampos2)]	[1] := aFunc[nPosFunc][1]
						EndIf
					Else
						dbSelectArea("SX3")
						dbSetOrder(2)
						dbSeek(Substr(aCampos2[Len(aCampos2)][2],1,10))
						aCampos2[Len(aCampos2)][1] := X3TITULO()
					EndIf
				Endif
				cPln1Sx6 := Substr(cPln1SX6,nPosSep+1,Len(cPln1SX6)-nPosSep)
			End
			
			AtuFields(nx,aCampos2, aCpsVar2)
	
			FT_FSKIP()
		Next
	Else
		If AllTrim(UPPER(cArqPLN))==AllTrim(UPPER("\PROFILE\"+AllTrim(cCallProc)+".PGR"))
			FT_FUSE()
			FErase(cArqPLN)
			Aviso("Configuração Incompativel","O arquivo de configuração padrao esta imcompativel com as configurações atuais deste relatorio. Um novo arquivo de confugurações sera criado neste momento.",{'Ok'},2)
			ChkPLN("\PROFILE\"+AllTrim(cCallProc)+".PGR") // Carrega as configurações padroes			
		Else
			Aviso("Configuração Incompativel","O arquivo de configuração selecionado não é compativel com este relatorio. Verique o arquivo selecionado ou o relatorio escolhido. Serão utilizadas as configurações padrões deste relatório.",{'Ok'},2)
			ChkPLN("\PROFILE\"+AllTrim(cCallProc)+".PGR") // Carrega as configurações padroes
		EndIf
	EndIf
	
	FT_FUSE()

Else
	Aviso("Falha na Abertura.","Erro na abertura do arquivo. Verifique a existencia do arquivo selecionado.",{'Ok'},2)
EndIf


Return

Function PgrLoad(PcoPrtTit,oSayTit,oFormato,oDlg)
Local oMenu
Local ni
Local lOk	:= .F.
Local aDir := Directory("*.PGR")


MENU oMenu POPUP
	MENUITEM "Procurar..." ACTION PgrOpen(@PcoPrtTit,@oSayTit,@oFormato)
	For ni := 1 To Len(aDir)
		If FT_FUse(AllTrim(aDir[ni][1]))<> -1
			FT_FGOTOP()
			cPLNVer	:= FT_FREADLN()
			If FT_FREADLN() == AllTrim(cCallProc)+"103"+cVrsCfg .Or. FT_FREADLN() == AllTrim(cCallProc)+"003"+cVrsCfg
				FT_FSKIP()
				FT_FSKIP() 
				MenuAddItem( AllTrim(Substr(Embaralha(FT_FREADLN(),0),1,80))+" - "+AllTrim(aDir[ni][1]),AllTrim(Substr(Embaralha(FT_FREADLN(),0),1,80))+" - "+AllTrim(aDir[ni][1]),.T.,.T. , ,,,oMenu, MontaBlock("{ || PgrOpen(,,,'"+aDir[ni][1]+"') }" ), ,,.F., ,, .F. )
			EndIf
		EndIf
		FT_FUSE()
	Next
ENDMENU

oMenu:Activate(200,180,oDlg)

PcoPrtTit := cNamePgr
oFormato:nOption := nOrient
oSayTit:Refresh()
oFormato:Refresh()


Return 
      
Function PgrLoadRfs(PcoPrtTit,oSayTit,oFormato)

PcoPrtTit := cNamePgr
oFormato:nOption := nOrient
oSayTit:Refresh()
oFormato:Refresh()

Return 

Function PgrOpen(PcoPrtTit,oSayTit,oFormato,cFile)
Local aRet	:= {}



If cFile<>Nil .or.ParamBox({	{6,"Arquivo",SPACE(50),"","File(mv_par01)","", 55 ,.T.,"Arquivo .PGR |*.PGR"}	},"Carregar configurações",aRet) 

	If cFile <> Nil
		aAdd(aRet,cFile)
	EndIf
	If ".PGR" $ aRet[1]
		cArqPln := AllTrim(aRet[1])
	Else
		cArqPln := Alltrim(aRet[1])+".PGR"
	EndIf
	ChkPLN(cArqPLN)
	If PcoPrtTit<> Nil
		PcoPrtTit := cNamePgr
		oFormato:nOption := nOrient
		oSayTit:Refresh()
		oFormato:Refresh()
	EndIf
					
EndIf


Return

Function PgrSave()

Local nx			:= 0
Local cWrite	:= ""
Local aRet		:= {}

If ParamBox({	{3,"Salvar em",If(AllTrim(UPPER(cArqPLN))==AllTrim(UPPER("\PROFILE\"+AllTrim(cCallProc)+".PGR")),1,2),{"Configuração padrão do relatorio","Arquivo de Configuração"},90,,.F.},;
					{6,"Arquivo ",If(AllTrim(UPPER(cArqPLN))==AllTrim(UPPER("\PROFILE\"+AllTrim(cCallProc)+".PGR")),SPACE(50),Padr(cArqPLN,50)),"","","", 55 ,.F.,"Arquivos .PGR |*.PGR"}	},"Salvar configurações",aRet) 
					
	If (aRet[1] == 2 .And. !Empty(aRet[2])) .Or. aRet[1] ==1
		If aRet[1] == 2
			If ".PGR" $ aRet[2]
				cArqPln := AllTrim(aRet[2])
			Else
				cArqPln := Alltrim(aRet[2])+".PGR"
			EndIf
		ElseIf aRet[1] == 1
			cArqPln	:= AllTrim(UPPER("\PROFILE\"+AllTrim(cCallProc)+".PGR"))
		EndIf
	
		If !Empty(cArqPLN)
			If lSenha
				cWrite := AllTrim(cCallProc)+"103"+cVrsCfg+Chr(13)+Chr(10)  // arquivo sem codificacao
				cWrite += cPLNSenha+Chr(13)+Chr(10)	
				cWrite += Embaralha(	Padr(cNamePgr,80)+Str(nOrient,1)+Str(nPgrFnt,1)+If(lForceLand,"1","2"), 1)+Chr(13)+Chr(10)
			Else
				cWrite := AllTrim(cCallProc)+"003"+cVrsCfg+Chr(13)+Chr(10)  // arquivo sem codificacao
				cWrite += " "+Chr(13)+Chr(10)
				cWrite += Embaralha(Padr(cNamePgr,80)+Str(nOrient,1)+Str(nPgrFnt,1)+If(lForceLand,"1","2"), 1)+Chr(13)+Chr(10)
			EndIf
		
			For nx := 1 to Len(aCabReport)
				cPln1SX6 := aCabReport[nx,16]
				While At("#",cPln1SX6) <> 0
					nPosSep := At("#",cPln1SX6)
					cWrite += Str(nx,4)+substr(cPln1SX6,1,nPosSep)+Chr(13)+Chr(10)
				
					cPln1Sx6 := Substr(cPln1SX6,nPosSep+1,Len(cPln1SX6)-nPosSep)			
				End
			Next
		
			
			MemoWrit(cArqPLN,cWrite)
			
		EndIf
		Aviso("Gravação efetuada com sucesso","Arquivo "+AllTrim(cArqPln)+" gravado com sucesso!",{"Ok"},2)
	Else
		Aviso("Gravação não efetuada","Arquivo de configuração invalido ou nao informado!",{"Fechar"},2)
	EndIf
EndIf
	
Return


Function PgrCfg(nCab)

If !Empty(cArqPLN)
	PgrFields(nCab,aCabReport[nCab][9],aCabReport[nCab][8],aCabReport[nCab][16],cArqPln,cNamePgr)
Else
	Aviso("Falha na Abertura.","Erro na abertura do arquivo. Verifique a existencia do arquivo selecionado.",{'Ok'},2)
EndIf


Return



Function PgrFields(nCab,aCamposExc,aFunc,cCmpPln,cArqPln,cDescri)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nAlign	:= aCabReport[nCab][2]
Local lAlignCell	:= .F.
Local oAlignCell
Local cPicture	:= ""
Local cCpoDescri	:= ""
Local nCpoTam	:= ""
Local nCnt1 := 0 
Local nCor1		:= 0
Local nCor2		:= 0
Local nCor3		:= 0
Local nCorCab1		:= 0
Local nCorCab2		:= 0
Local nCorCab3		:= 0
Local nx := 0
Local nCampos1
Local nCampos2
Local nPos1      := 0
Local nPos2      := 0
Local cCampoAux
Local aCampos1   := {}
Local aCampos2   := {} 
Local aCpsVar2   := {}
Local aCamposA   := {}
Local aCamposB   := {}
Local nFonte		:= 0
Local aBtn       := Array(7)
Local oEstilo2
Local oEstilo1
Local oCampos1
Local oCampos2
Local oBtn1
Local oBtn2
Local nEstilo1	:= 0
Local nEstilo2	:= 0
Local lCampos1   := .T.
Local lCampos2   := .F.
Local cPln1SX6   := cCmpPln
Local aAuxVar := {}  


DEFAULT aCamposExc := {}
DEFAULT cCmpPln	 := ""

nOrdSX3  := SX3->(IndexOrd())
nRegSX3  := SX3->(Recno())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do array de campos selecionados                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While At("#",cPln1SX6) <> 0
	nPosSep := At("#",cPln1SX6)
	
	If Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),1,1)=="|"
		aAdd(aCpsVar2,{,,,,,,,})
		aCpsVar2[Len(aCpsVar2)][1] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),02,10)  // nome
		aCpsVar2[Len(aCpsVar2)][2] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),13,25)  // titulo
		aCpsVar2[Len(aCpsVar2)][4] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),70,01)  // tipo
		aCpsVar2[Len(aCpsVar2)][5] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),72,02))  // tamanhho
		aCpsVar2[Len(aCpsVar2)][6] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),75,01))  // decimal
		aCpsVar2[Len(aCpsVar2)][7] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),77,60)	 // picture

		Do Case
			Case aCpsVar2[Len(aCpsVar2)][4]=="C"
				aCpsVar2[Len(aCpsVar2)][3] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30)
			Case aCpsVar2[Len(aCpsVar2)][4]=="N"
				aCpsVar2[Len(aCpsVar2)][3] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30))
			Case aCpsVar2[Len(aCpsVar2)][4]=="D"
				aCpsVar2[Len(aCpsVar2)][3] := CTOD(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30))
		EndCase		

		aCpsVar2[Len(aCpsVar2)][8] := "_|"+PadR(aCpsVar2[Len(aCpsVar2)][1], 10, " ")+;                // nome
														"|"+PadR(aCpsVar2[Len(aCpsVar2)][2], 25, " ")+;                 // titulo
														"|"+PadR(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30), 30, " ")+;  // valor  - direto do arquivo
														"|"+PadR(aCpsVar2[Len(aCpsVar2)][4], 1, " ")+;                   // tipo
														"|"+StrZero(aCpsVar2[Len(aCpsVar2)][5],2,0)+;                 // tamanho
														"|"+StrZero(aCpsVar2[Len(aCpsVar2)][6],1,0)+;                 // decimal
														"|"+PadR(aCpsVar2[Len(aCpsVar2)][7], 60, " ")
	ElseIf Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),1,1)=="@"
		nPosFunc := 0
	Else
		aAdd(aCampos2,{,})
		aCampos2[Len(aCampos2)][2] := AllTrim(Substr(cPln1Sx6, 2, nPosSep-2))
		If Substr(aCampos2[Len(aCampos2)][2],1,1)=="%"
			aCampos2[Len(aCampos2)][1] := "="+Substr(aCampos2[Len(aCampos2)][2],2,9)
		ElseIf Substr(aCampos2[Len(aCampos2)][2],1,1)=="$"
			nPosFunc := aScan(aFunc,{|x| AllTrim(x[2])==AllTrim(Substr(aCampos2[Len(aCampos2)][2],1,10))})
			If nPosFunc > 0
				aCampos2[Len(aCampos2)]	[1] := aFunc[nPosFunc][1]
			EndIf
		Else
//			aCampos2[Len(aCampos2)][1] := Substr(aCampos2[Len(aCampos2)][2],70,30)
			dbSelectArea("SX3")
			dbSetOrder(2)
			dbSeek(Substr(aCampos2[Len(aCampos2)][2],1,10))
			aCampos2[Len(aCampos2)][1] := X3TITULO()
		EndIf
	Endif
	cPln1Sx6 := Substr(cPln1SX6,nPosSep+1,Len(cPln1SX6)-nPosSep)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do array de campos disponiveis                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
If !Empty(aCabReport[nCab][4]).And. (dbSeek(aCabReport[nCab][4]))
	While SX3->X3_ARQUIVO == aCabReport[nCab][4]
		If cNivel >= SX3->X3_NIVEL .And. SX3->X3_CONTEXT <> "V"
			cCampoAux := SX3->X3_CAMPO
			If Len(aCampos1) <> 0
				If  (nPosCampo := AScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCamposExc,cCampoAux)) == 0
					aAdd(aCampos1,{X3Descric(),;
										Padr(SX3->X3_CAMPO,10)+;   
										Str(aCabReport[nCab,14],2)+; //Estilo da celula padrao
										Str(aCabReport[nCab,15],2)+; //Estilo da celula padrao
										Str(aCabReport[nCab,13],10)+; //Estilo da celula padrao
										If(X3_TIPO=="N","1","2")+; // Alinhamento 
										Padr(SX3->X3_PICTURE,30)+; //Picture celula 28,30
										Str(aCabReport[nCab,10],2)+; //Estilo cabecalho 58,2
										Str(aCabReport[nCab,11],2)+; //Fonte do cabecalho 60,2
										Str(aCabReport[nCab,12],10)+; //Cor do cabecalho 62,10
										Padr(X3DESCRIC(),30)+; //Texto do cabecalho 72,30
										Str((X3_TAMANHO*5.3),3); //Tamanho da coluna 102,3					
										})


				Endif
			Else
				If  (nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCamposExc,cCampoAux)) == 0
					aAdd(aCampos1,{X3Descric(),;
										Padr(SX3->X3_CAMPO,10)+;   
										Str(aCabReport[nCab,14],2)+; //Estilo da celula padrao
										Str(aCabReport[nCab,15],2)+; //Estilo da celula padrao
										Str(aCabReport[nCab,13],10)+; //Estilo da celula padrao
										If(X3_TIPO=="N","1","2")+; // Alinhamento 
										Padr(SX3->X3_PICTURE,30)+; //Picture celula 28,30
										Str(aCabReport[nCab,10],2)+; //Estilo cabecalho 58,2
										Str(aCabReport[nCab,11],2)+; //Fonte do cabecalho 60,2
										Str(aCabReport[nCab,12],10)+; //Cor do cabecalho 62,10
										Padr(X3DESCRIC(),30)+; //Texto do cabecalho 72,30
										Str((X3_TAMANHO*5.3),3); //Tamanho da coluna 102,3					
										})
				Endif
			Endif
		Endif
		dbSkip()
	End
Endif
For nx := 1 to Len(aFunc)
	If Len(aCampos1) <> 0
		If  (nPosCampo := AScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := AScan(aCamposExc,aFunc[nx][2])) == 0
			aAdd(aCampos1,{aFunc[nx][1],aFunc[nx][2]})
		Endif
	Else
		If  (nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := AScan(aCamposExc,aFunc[nx][2])) == 0
			aAdd(aCampos1,{aFunc[nx][1],aFunc[nx][2]})
		Endif
	Endif
Next
aSort(aCampos1,,, {|x,y| x[1] < y[1]})
aCampos3 := aClone(aCampos1)
aCampos4 := aClone(aCampos2)
aCamposA  := {}
aCamposB  := {}
For nCnt1 := 1 to Len(aCampos1)
	aAdd(aCamposA,aCampos1[nCnt1][1])
Next

RenFld(@aCamposB, aCampos2)

DEFINE MSDIALOG oDlg1 FROM 00,00 TO 500,700 TITLE STR0027 PIXEL //"Selecione os campos"
@ 157,05 SAY STR0091 PIXEL OF oDlg1  //"Variaveis globais"

@ 165,05 LISTBOX oCpoSel FIELDS HEADER STR0092, STR0093, STR0094 MESSAGE;
STR0095;
ON DBLCLICK PMSEdtValPln(@aCpsVar2, oCpoSel) SIZE 230,65 OF oDlg1 PIXEL

aAuxVar := aClone(aCpsVar2)

If Len(aAuxVar) < 1
	aAdd(aAuxVar, {"","","","","","","",""})
EndIf

oCpoSel:SetArray(aAuxVar)
oCpoSel:bLine:={||{aAuxVar[oCpoSel:nAt,1], aAuxVar[oCpoSel:nAt,2], Transform(aAuxVar[oCpoSel:nAt,3], aAuxVar[oCpoSel:nAt,7])}}
oCpoSel:Refresh()

@18,05  SAY STR0028 PIXEL OF oDlg1  //"Campos Disponiveis"
@18,143 SAY STR0029 PIXEL OF oDlg1  //"Campos Selecionados"
@35,245 SAY STR0030 PIXEL OF oDlg1  //"Mover"
@40,242 SAY STR0031 PIXEL OF oDlg1  //"Campos"

@26,05  LISTBOX oCampos1 VAR nCampos1 ITEMS aCamposA SIZE 90,110 ON DBLCLICK;
AddFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB) PIXEL OF oDlg1
oCampos1:SetArray(aCamposA)
oCampos1:bChange    := {|| nCampos2 := 0,oCampos2:Refresh(),lCampos1 := .T.,lCampos2 := .F.}
oCampos1:bGotFocus  := {|| lCampos1 := .T.,lCampos2 := .F.}

@26,143 LISTBOX oCampos2 VAR nCampos2 ITEMS aCamposB SIZE 90,110 ON DBLCLICK;
DelFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB) PIXEL OF oDlg1
oCampos2:SetArray(aCamposB)
oCampos2:bChange    := {|| nCampos1 := 0,nPos2:=oCampos2:nAT,oCampos1:Refresh(),lCampos1 := .F.,lCampos2 := .T.,;
									If(oCampos2:nAT>0,cCpoDescri := Substr(aCampos2[oCampos2:nAT,2],70,30),Nil),oCpoDescri:Refresh(),;
									If(oCampos2:nAT>0,cPicture := Substr(aCampos2[oCampos2:nAT,2],26,30),Nil),oPicture:Refresh(),;
									If(oCampos2:nAT>0,nEstilo1 := Val(Substr(aCampos2[oCampos2:nAT,2],11,2)),Nil),oEstilo1:Refresh(),;
									If(oCampos2:nAT>0,nEstilo2 := Val(Substr(aCampos2[oCampos2:nAT,2],56,2)),Nil),oEstilo2:Refresh(),;
									If(oCampos2:nAT>0,nCor1 := ConvRGB(Val(Substr(aCampos2[oCampos2:nAT,2],15,10)))[1],Nil),oCor1:Refresh(),;
									If(oCampos2:nAT>0,nCor2 := ConvRGB(Val(Substr(aCampos2[oCampos2:nAT,2],15,10)))[2],Nil),oCor2:Refresh(),;
									If(oCampos2:nAT>0,nCor3 := ConvRGB(Val(Substr(aCampos2[oCampos2:nAT,2],15,10)))[3],Nil),oCor3:Refresh(),;
									If(oCampos2:nAT>0,nCorCab1 := ConvRGB(Val(Substr(aCampos2[oCampos2:nAT,2],60,10)))[1],Nil),oCorCab1:Refresh(),;
									If(oCampos2:nAT>0,nCorCab2 := ConvRGB(Val(Substr(aCampos2[oCampos2:nAT,2],60,10)))[2],Nil),oCorCab2:Refresh(),;
									If(oCampos2:nAT>0,nCorCab3 := ConvRGB(Val(Substr(aCampos2[oCampos2:nAT,2],60,10)))[3],Nil),oCorCab3:Refresh(),;
									If(oCampos2:nAT>0,lAlignCell := If(Substr(aCampos2[oCampos2:nAT,2],25,1)=="1",.T.,.F.),Nil),oAlignCell:Refresh(),;
									If(oCampos2:nAT>0,nCpoTam		:= Val(Substr(aCampos2[oCampos2:nAT,2],100,3)),Nil),oCpoTam:Refresh()	}
									
oCampos2:bGotFocus  := {|| lCampos1 := .F.,lCampos2 := .T.}

@18,270 SAY "Descrição" PIXEL OF oDlg1  
@ 26,270 MSGET oCpoDescri VAR cCpoDescri  Of oDlg1 Pixel Size 65, 08 ON CHANGE aCampos2[oCampos2:nAT,2] := Substr(aCampos2[oCampos2:nAT,2],1,69)+Padr(cCpoDescri,30)+Substr(aCampos2[oCampos2:nAT,2],100) 

@ 40,270 SAY "Tamanho ( Pixel )" PIXEL OF oDlg1  
@ 48,270 MSGET oCpoTam VAR nCpoTam Of oDlg1 Picture "@E 999" Pixel Size 65, 09 ON CHANGE aCampos2[oCampos2:nAT,2] := Substr(aCampos2[oCampos2:nAT,2],1,99)+Str(nCpoTam,3)+Substr(aCampos2[oCampos2:nAT,2],103) 

@ 62,270 SAY "Picture" PIXEL OF oDlg1  
@ 70,270 MSGET oPicture VAR cPicture Of oDlg1 Pixel Size 65, 09 ON CHANGE aCampos2[oCampos2:nAT,2] := Substr(aCampos2[oCampos2:nAT,2],1,25)+Padr(cPicture,30)+Substr(aCampos2[oCampos2:nAT,2],56) 

@ 84,278 SAY "Cor Cabecalho (RGB)" PIXEL OF oDlg1
@ 164,535 BTNBMP oBtn2 RESOURCE "PMSCOLOR"   SIZE 20,20 Of oDLG1 PIXEL ACTION (PgrSelColor(@nCorCab1,@nCorCab2,@nCorCab3),(aCampos2[oCampos2:nAT,2] := Substr(aCampos2[oCampos2:nAT,2],1,59)+Str(RGB(nCorCab1,nCorCab2,nCorCab3),10)+Substr(aCampos2[oCampos2:nAT,2],70)))
@ 92,270 MSGET oCorCab1 VAR nCorCab1 Of oDlg1 Pixel Picture "@E 999" Size 20, 09 Valid Positivo(nCorCab1) .And. nCorCab1 <= 255 ON CHANGE aCampos2[oCampos2:nAT,2] := Substr(aCampos2[oCampos2:nAT,2],1,59)+Str(RGB(nCorCab1,nCorCab2,nCorCab3),10)+Substr(aCampos2[oCampos2:nAT,2],70) 
@ 92,292 MSGET oCorCab2 VAR nCorCab2 Of oDlg1 Pixel Picture "@E 999" Size 20, 09 Valid Positivo(nCorCab2) .And. nCorCab2 <= 255 ON CHANGE aCampos2[oCampos2:nAT,2] := Substr(aCampos2[oCampos2:nAT,2],1,59)+Str(RGB(nCorCab1,nCorCab2,nCorCab3),10)+Substr(aCampos2[oCampos2:nAT,2],70) 
@ 92,314 MSGET oCorCab3 VAR nCorCab3 Of oDlg1 Pixel Picture "@E 999" Size 20, 09 Valid Positivo(nCorCab1) .And. nCorCab1 <= 255 ON CHANGE aCampos2[oCampos2:nAT,2] := Substr(aCampos2[oCampos2:nAT,2],1,59)+Str(RGB(nCorCab1,nCorCab2,nCorCab3),10)+Substr(aCampos2[oCampos2:nAT,2],70) 

@ 106,278 SAY "Cor Linha (RGB)" PIXEL OF oDlg1
@ 208,535 BTNBMP oBtn3 RESOURCE "PMSCOLOR"   SIZE 20,20 Of oDLG1 PIXEL ACTION (PgrSelColor(@nCor1,@nCor2,@nCor3),(aCampos2[oCampos2:nAT,2] :=Substr(aCampos2[oCampos2:nAT,2],1,14)+Str(RGB(nCor1,nCor2,nCor3),10)+Substr(aCampos2[oCampos2:nAT,2],25) ))//ACTION UpField(@aCampos2,oCampos2,@aCamposB,nPos2);
@ 114,270 MSGET oCor1 VAR nCor1 Of oDlg1 Pixel Picture "@E 999" Size 20, 09 Valid Positivo(nCor1) .And. nCor1 <= 255 ON CHANGE aCampos2[oCampos2:nAT,2] :=Substr(aCampos2[oCampos2:nAT,2],1,14)+Str(RGB(nCor1,nCor2,nCor3),10)+Substr(aCampos2[oCampos2:nAT,2],25) 
@ 114,292 MSGET oCor2 VAR nCor2 Of oDlg1 Pixel Picture "@E 999" Size 20, 09 Valid Positivo(nCor2) .And. nCor2 <= 255 ON CHANGE aCampos2[oCampos2:nAT,2] :=Substr(aCampos2[oCampos2:nAT,2],1,14)+Str(RGB(nCor1,nCor2,nCor3),10)+Substr(aCampos2[oCampos2:nAT,2],25) 
@ 114,314 MSGET oCor3 VAR nCor3 Of oDlg1 Pixel Picture "@E 999" Size 20, 09 Valid Positivo(nCor1) .And. nCor1 <= 255 ON CHANGE aCampos2[oCampos2:nAT,2] :=Substr(aCampos2[oCampos2:nAT,2],1,14)+Str(RGB(nCor1,nCor2,nCor3),10)+Substr(aCampos2[oCampos2:nAT,2],25) 

@ 130,270 CHECKBOX oAlignCell VAR lAlignCell PROMPT "Alinhar a direita" of oDlg1 SIZE 60,09 On Change aCampos2[oCampos2:nAT,2] := Substr(aCampos2[oCampos2:nAT,2],1,24)+If(lAlignCell,"1","2")+Substr(aCampos2[oCampos2:nAT,2],26) 

@ 142,270 SAY "Estilo do Cabecalho" PIXEL OF oDlg1
@ 299,545 BTNBMP oBtn3 RESOURCE BMP_ZOOM_IN   SIZE 20,20 Of oDLG1 PIXEL ACTION ShowCab()
@ 149,288 MSGET oEstilo1 VAR nEstilo1 Of oDlg1 Picture "@E 99" Valid Positivo(nEstilo1) .And. nEstilo1 <= Len(aEstiloCab) Pixel Size 47, 09 ON CHANGE aCampos2[oCampos2:nAT,2] := Substr(aCampos2[oCampos2:nAT,2],1,10)+Str(nEstilo1,2)+Substr(aCampos2[oCampos2:nAT,2],13) 

@ 163,270 SAY "Estilo da Linha" PIXEL OF oDlg1
@ 339,545 BTNBMP oBtn3 RESOURCE BMP_ZOOM_IN   SIZE 20,20 Of oDLG1 PIXEL ACTION ShowLinha()
@ 171,288 MSGET oEstilo2 VAR nEstilo2 Of oDlg1 Picture "@E 99" Valid Positivo(nEstilo2) .And. nEstilo2 <= Len(aEstiloDet) Pixel Size 47, 09 ON CHANGE aCampos2[oCampos2:nAT,2] := Substr(aCampos2[oCampos2:nAT,2],1,55)+Str(nEstilo2,2)+Substr(aCampos2[oCampos2:nAT,2],58)


@26,98  BUTTON aBtn[1] PROMPT STR0032 SIZE 42,11 PIXEL; //" Add.Todos >>"
ACTION AddAllFld(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB)

@38,98  BUTTON aBtn[2] PROMPT STR0033 SIZE 42,11 PIXEL;  //"&Adicionar >>"
ACTION AddFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB) WHEN lCampos1

@50,98  BUTTON aBtn[3] PROMPT STR0034 SIZE 42,11 PIXEL; //"<< &Remover "
ACTION DelFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB) WHEN lCampos2

@62,98  BUTTON aBtn[4] PROMPT STR0035  SIZE 42,11 PIXEL;  //"<< Rem.Todos"
ACTION DelAllFld(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB)

@76,98  BUTTON aBtn[6] PROMPT STR0079  SIZE 42,11 PIXEL;  //"Formula >>"
ACTION AddFormula(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nCab)

@88,98  BUTTON aBtn[6] PROMPT "Editar >>"  SIZE 42,11 PIXEL;  //"Editar"
ACTION EdtFormula(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nCab)

@100,98  BUTTON aBtn[7] PROMPT "Acumulador >>"  SIZE 42,11 PIXEL;  
ACTION AddAcumul(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB,nCab)


@125,98 BUTTON aBtn[5] PROMPT "Restaurar >>"  SIZE 42,11 PIXEL;  
ACTION RestFields(@aCampos1,oCampos1,@aCampos2,oCampos2,aCampos3,aCampos4,@aCamposA,@aCamposB)

@115,490 BTNBMP oBtn1 RESOURCE BMP_SETA_UP   SIZE 25,25 ACTION UpField(@aCampos2,oCampos2,@aCamposB,nPos2);
MESSAGE STR0037  WHEN lCampos2  //"Mover campo para cima"

@150,490 BTNBMP oBtn2 RESOURCE BMP_SETA_DOWN SIZE 25,25 ACTION DwField(@aCampos2,oCampos2,@aCamposB,nPos2);
MESSAGE STR0038 WHEN lCampos2  //"Mover campo para baixo"

@ 143,05 CHECKBOX oUsado VAR lSenha PROMPT STR0108 SIZE 86, 10 ON CHANGE ProtArq() OF oDlg1 PIXEL //"Proteger arquivo com senha"

@ 235, 05 BUTTON STR0096 SIZE 42, 11 PIXEL ACTION AddVarPln(@aCpsVar2, @oCpoSel)
@ 235, 60 BUTTON STR0097 SIZE 42, 11 PIXEL ACTION DelVarPln(@aCpsVar2, @oCpoSel)
@ 235,115 BUTTON STR0098 SIZE 42, 11 PIXEL ACTION EdtVarPln(@aCpsVar2, @oCpoSel)

ACTIVATE DIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||AtuFields(nCab,aCampos2, aCpsVar2),oDlg1:End()},{|| oDlg1:End()},,) CENTERED

dbSelectArea("SX3")
dbSetOrder(nOrdSX3)
dbGoTo(nRegSX3)

Return Nil





/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddFields  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move campo disponivel para array de campos selecionados       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AddFields(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0
Local nPos1 := oCampos1:nAt
Local nPos2 := oCampos2:nAt

If nPos1 <> 0 .And. Len(aCampos1) <> 0
	aAdd(aCampos2,{aCampos1[nPos1][1],aCampos1[nPos1][2]})
	aDel(aCampos1,nPos1)
	aSize(aCampos1,Len(aCampos1)-1)
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposA  := {}
	aCamposB  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos1:SetArray(aCamposA)
	If Len(aCamposA) > 0
		oCampos1:nAt := 1
	EndIf
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:Refresh()
	oCampos1:SetFocus()
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddFormula ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona um campo de formula nos campos selecionados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AddFormula(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB,nCab)
Local nCnt1 := 0
Local aRet	:= {}

If ParamBox({	{1,STR0081,SPACE(9),"","","","", 85 ,.T.},;  //"Titulo"
	{3,STR0082,2,{STR0083,STR0084,STR0085},60,,.F.},; //"Tipo"###"Caracter"###"Numerico"###"Data"
	{1,STR0086,220,"@E 999","","","", 30 ,.F.},;  //"Tamanho"
	{1,STR0088,SPACE(30),"","","","", 85 ,.F.},; //"Picture"
	{1,STR0089,SPACE(80),"","","","", 85 ,.T.} },"Incluir Formula",@aRet) //"Formula"###"Configuracoes"
	
	Do Case
		Case aRet[2]==1
			cTipo := "C"
		Case aRet[2]==2
			cTipo := "N"
		Case aRet[2]==3
			cTipo := "D"
	EndCase
	aAdd(aCampos2,{"="+aRet[1],Padr(	"%"+aRet[1],10)+; 
										Str(aCabReport[nCab,14],2)+; //Estilo da celula padrao
										Str(aCabReport[nCab,15],2)+; //Estilo da celula padrao
										Str(aCabReport[nCab,13],10)+; //Estilo da celula padrao
										If(cTipo=="N","1","2")+; // Alinhamento 
										Padr(aRet[4],30)+; //Picture celula 26,30
										Str(aCabReport[nCab,10],2)+; //Estilo cabecalho 56,2
										Str(aCabReport[nCab,11],2)+; //Fonte do cabecalho 58,2
										Str(aCabReport[nCab,12],10)+; //Cor do cabecalho 60,10
										Padr(aRet[1],30)+; //Texto do cabecalho 70,30
										Str(aRet[3],3)+; //Tamanho da coluna 100,3					
										cTipo+; // Tipo da formula 103,1
										Str(0,2)+; // Decimais 104,2
										Padr(aRet[5],80); // Formula 106,80
										})
	aCamposA  := {}
	aCamposB  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos1:SetArray(aCamposA)
	If Len(aCamposA) > 0
		oCampos1:nAt := 1
	EndIf
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:Refresh()
	oCampos1:SetFocus()
	
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddAcumul  ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona um campo acumulador ao relatorio                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AddAcumul(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB,nCab)
Local nCnt1 	:= 0
Local aRet		:= {}
Local cFormula	:= "" 
Local aTpGrafico:= {"1=Linha",;
							"2=Area",;
							"3=Pontos",;
							"4=Barra"   ,;
							"5=Piramide"  ,;
							"6=Cilindro"    ,;
							"7=Barra Horizontal",;
							"8=Piramide Horizontal",;
							"9=Cilindro Horizontal",;
							"10=Pizza",;
							"11=Forma",;
							"12=Linha Rapida",;
							"13=Flechas",;
							"14=Gantt",;
							"15=Bolha" }


If ParamBox({	{1,STR0081,SPACE(9),"","","","", 85 ,.T.},;  //"Titulo"
	{3,STR0082,2,{STR0083,STR0084,STR0085},60,,.F.},; //"Tipo"###"Caracter"###"Numerico"###"Data"
	{3,"Acumular",1,{"Totalizar","Valor Minimo","Valor Maximo","Contador","Valor Medio"},60,,.F.},; 
	{1,STR0086,220,"@E 999","","","", 30 ,.F.},;  //"Tamanho"
	{1,STR0088,SPACE(30),"","","","", 85 ,.F.},; //"Picture"
	{1,"Agrupar por",SPACE(20),"","","","", 85 ,.F.},;
	{1,"Texto do Grupo",SPACE(20),"","","","", 85 ,.F.},;
	{1,"Valor",SPACE(20),"","","","", 85 ,.T.},;
	{5, "Imprimir resultados do Acumulador no final do relatorio.", .T., 160,,.F.},;
	{1,"Nome do Grafico",SPACE(40),"","","","", 85 ,.F.},;
	{1,"Nome Serie",SPACE(40),"","","","", 85 ,.F.},;
	{3,"Tipo do Grafico",4,aTpGrafico,80,"",.F.}	  },"Incluir Acumulador",@aRet) //"Formula"###"Configuracoes"

	Do Case
		Case aRet[2]==1
			cTipo := "C"
		Case aRet[2]==2
			cTipo := "N"
		Case aRet[2]==3
			cTipo := "D"
	EndCase 
	Do Case
		Case aRet[3] == 1
			cFormula := "PgrTotal("+If(Empty(aRet[6]),"'Totalizador - '"+AllTrim(aRet[1]),AllTrim(aRet[6]))+","+AllTrim(aRet[8])+","+AllTrim(aRet[7])+","+AllTrim(aRet[5])+","+If(aRet[9],".T.",".F.")+",'"+Alltrim(aRet[10])+"','"+Alltrim(aRet[11])+"',"+Str(aRet[12],2,0)+")"
		Case aRet[3] == 2
			cFormula := "PgrMin("+If(Empty(aRet[6]),"'Valor Minimo - '"+AllTrim(aRet[1]),AllTrim(aRet[6]))+","+AllTrim(aRet[8])+","+AllTrim(aRet[7])+","+AllTrim(aRet[5])+","+If(aRet[9],".T.",".F.")+")"
		Case aRet[3] == 3
			cFormula := "PgrMax("+If(Empty(aRet[6]),"'Valor Maximo - '"+AllTrim(aRet[1]),AllTrim(aRet[6]))+","+AllTrim(aRet[8])+","+AllTrim(aRet[7])+","+AllTrim(aRet[5])+","+If(aRet[9],".T.",".F.")+")"
		Case aRet[3] == 4
			cFormula := "PgrCount("+If(Empty(aRet[6]),"'Contador - '"+AllTrim(aRet[1]),AllTrim(aRet[6]))+","+AllTrim(aRet[8])+","+AllTrim(aRet[7])+","+AllTrim(aRet[5])+","+If(aRet[9],".T.",".F.")+",'"+Alltrim(aRet[10])+"','"+Alltrim(aRet[11])+"',"+Str(aRet[12],2,0)+")"
		Case aRet[3] == 5
			cFormula := "PgrMedia("+If(Empty(aRet[6]),"'Valor Medio - '"+AllTrim(aRet[1]),AllTrim(aRet[6]))+","+AllTrim(aRet[8])+","+AllTrim(aRet[7])+","+AllTrim(aRet[5])+","+If(aRet[9],".T.",".F.")+")"
	EndCase
	aAdd(aCampos2,{"="+aRet[1],Padr(	"%"+aRet[1],10)+; 
										Str(aCabReport[nCab,14],2)+; //Estilo da celula padrao
										Str(aCabReport[nCab,15],2)+; //Estilo da celula padrao
										Str(aCabReport[nCab,13],10)+; //Estilo da celula padrao
										If(cTipo=="N","1","2")+; // Alinhamento 
										Padr(aRet[5],30)+; //Picture celula 26,30
										Str(aCabReport[nCab,10],2)+; //Estilo cabecalho 56,2
										Str(aCabReport[nCab,11],2)+; //Fonte do cabecalho 58,2
										Str(aCabReport[nCab,12],10)+; //Cor do cabecalho 60,10
										Padr(aRet[1],30)+; //Texto do cabecalho 70,30
										Str(aRet[4],3)+; //Tamanho da coluna 100,3					
										cTipo+; // Tipo da formula 103,1
										Str(0,2)+; // Decimais 104,2
										Padr(cFormula,80); // Formula 106,80
										})
	aCamposA  := {}
	aCamposB  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos1:SetArray(aCamposA)
	If Len(aCamposA) > 0
		oCampos1:nAt := 1
	EndIf
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:Refresh()
	oCampos1:SetFocus()
	
EndIf

Return Nil



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EdtFormula ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Edita a formula .                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function EdtFormula(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB,nCab)
Local nPos2 := oCampos2:nAt
Local nTipo	:= ""

Local nCnt1 := 0
Local aRet	:= {}

If nPos2 > 0 .And. Len(aCampos2) > 0
	If Substr(aCampos2[nPos2][2],1,1)=="%"
		//%123456789012%C%99%2%12345678901234567890123456789012345%123456789012345678901234567890123456789012345678901234567890¨
		Do case
			Case Substr(aCampos2[nPos2][2],103,1)=="C"
				nTipo := 1
			Case Substr(aCampos2[nPos2][2],103,1)=="N"
				nTipo := 2
			Case Substr(aCampos2[nPos2][2],103,1)=="D"
				nTipo := 3
		EndCase
		If ParamBox({	{1,STR0081,Padr(Substr(aCampos2[nPos2][2],2,9),9),"","","","", 85 ,.T.},;  //"Titulo"
			{3,STR0082,nTipo,{STR0083,STR0084,STR0085},60,,.F.},; //"Tipo"###"Caracter"###"Numerico"###"Data"
			{1,STR0086,Val(Substr(aCampos2[nPos2][2],100,3)),"@E 999","","","", 30 ,.F.},;  //"Tamanho"
			{1,STR0088,Substr(aCampos2[nPos2][2],26,30),"","","","", 85 ,.F.},; //"Picture"
			{1,STR0089,Padr(Substr(aCampos2[nPos2][2],106,80),80),"","","","", 85 ,.T.} },STR0090,@aRet) //"Formula"###"Configuracoes"
			
			Do Case
				Case aRet[2]==1
					cTipo := "C"
				Case aRet[2]==2
					cTipo := "N"
				Case aRet[2]==3
					cTipo := "D"
			EndCase
			aCampos2[nPos2] := {"="+aRet[1],Padr(	"%"+aRet[1],10)+; 
										Str(aCabReport[nCab,14],2)+; //Estilo da celula padrao
										Str(aCabReport[nCab,15],2)+; //Estilo da celula padrao
										Str(aCabReport[nCab,13],10)+; //Estilo da celula padrao
										If(cTipo=="N","1","2")+; // Alinhamento 
										Padr(aRet[4],30)+; //Picture celula 26,30
										Str(aCabReport[nCab,10],2)+; //Estilo cabecalho 56,2
										Str(aCabReport[nCab,11],2)+; //Fonte do cabecalho 58,2
										Str(aCabReport[nCab,12],10)+; //Cor do cabecalho 60,10
										Padr(aRet[1],30)+; //Texto do cabecalho 70,30
										Str(aRet[3],3)+; //Tamanho da coluna 100,3					
										cTipo+; // Tipo da formula 103,1
										Str(0,2)+; // Decimais 104,2
										Padr(aRet[5],80); // Decimais 106,80
										}

			aCamposA  := {}
			aCamposB  := {}
			For nCnt1 := 1 to Len(aCampos1)
				aAdd(aCamposA,aCampos1[nCnt1][1])
			Next
			
			RenFld(@aCamposB, aCampos2)
			
			oCampos1:SetArray(aCamposA)
			If Len(aCamposA) > 0
				oCampos1:nAt := 1
			EndIf
			oCampos1:Refresh()
			oCampos2:SetArray(aCamposB)
			oCampos2:Refresh()
			oCampos1:SetFocus()
			
		EndIf
	EndIf
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DelFields  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move campo selecionados para array de campos disponiveis      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DelFields(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0

Local nPos1 := oCampos1:nAt
Local nPos2 := oCampos2:nAt

If nPos2 <> 0 .And. Len(aCampos2) <> 0 
	If Substr(aCampos2[nPos2][2],1,1) != "%"
		aAdd(aCampos1,{aCampos2[nPos2][1],aCampos2[nPos2][2]})
		aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	EndIf
	aDel(aCampos2,nPos2)
	aSize(aCampos2,Len(aCampos2)-1)
	aCamposA  := {}
	aCamposB  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos1:SetArray(aCamposA)
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt := 1
	oCampos2:Refresh()
	oCampos2:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddAllFld  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move todos os campos do array de campos disponiveis para      ³±±
±±³          ³array de campos selecionados.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AddAllFld(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0

If Len(aCampos1) <> 0
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCampos2,{aCampos1[nCnt1][1],aCampos1[nCnt1][2]})
	Next
	aCampos1 := {}
	aCamposA := {}
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposB  := {}
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos1:SetArray(aCamposA)
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt := 1
	oCampos2:Refresh()
	oCampos2:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DelAllFld  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move todos os campos do array de campos selecionados para     ³±±
±±³          ³array de campos disponiveis.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DelAllFld(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0

If Len(aCampos2) <> 0
	For nCnt1 := 3 to Len(aCampos2)
		If Substr(aCampos2[nCnt1][2], 1, 1) # "%"
			aAdd(aCampos1,{aCampos2[nCnt1][1],aCampos2[nCnt1][2]})
		Endif
	Next
	aCampos2   := {{STR0078,STR0122},{STR0046,STR0100}} //"Codigo"###"Descricao" //"COD"###"Descricao"
	aCamposB := {}
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposA  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos1:SetArray(aCamposA)
	If Len(aCamposA) > 0
		oCampos1:nAt   := 1
	EndIf
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:Refresh()
	oCampos1:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UpField    ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move o campo para uma posicao acima dentro do array           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function UpField(aCampos2,oCampos2,aCamposB,nPos2)
Local cCampoAux
      
DEFAULT nPos2 := oCampos2:nAt

If nPos2 <> 1 .And. nPos2 <> 0 
	cCampoAux := aCampos2[nPos2-1][1]
	aCampos2[nPos2-1][1] := aCampos2[nPos2][1]
	aCampos2[nPos2][1] := cCampoAux
	cCampoAux := aCampos2[nPos2-1][2]
	aCampos2[nPos2-1][2] := aCampos2[nPos2][2]
	aCampos2[nPos2][2] := cCampoAux
	aCamposB  := {}
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt:=nPos2-1
	oCampos2:Refresh()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UpField    ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move o campo para uma posicao abaixo dentro do array          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DwField(aCampos2,oCampos2,aCamposB,nPos2)
Local cCampoAux

DEFAULT nPos2 := oCampos2:nAt

If nPos2 < Len(aCampos2) .And. nPos2 <> 0 
	cCampoAux := aCampos2[nPos2+1][1]
	aCampos2[nPos2+1][1] := aCampos2[nPos2][1]
	aCampos2[nPos2][1] := cCampoAux
	cCampoAux := aCampos2[nPos2+1][2]
	aCampos2[nPos2+1][2] := aCampos2[nPos2][2]
	aCampos2[nPos2][2] := cCampoAux
	aCamposB  := {}
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt:=nPos2+1
	oCampos2:Refresh()
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RestFields ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Restaura arrays originais                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RestFields(aCampos1,oCampos1,aCampos2,oCampos2,aCampos3,aCampos4,aCamposA,aCamposB)
Local nCnt1 := 0

aCampos1  := aClone(aCampos3)
aCampos2  := aClone(aCampos4)
aSort(aCampos1,,, {|x,y| x[1] < y[1]})
aCamposA  := {}
aCamposB  := {}
For nCnt1 := 1 to Len(aCampos1)
	aAdd(aCamposA,aCampos1[nCnt1][1])
Next

RenFld(@aCamposB, aCampos2)

oCampos1:SetArray(aCamposA)
oCampos2:SetArray(aCamposB)
If Len(aCampos1) > 0
	oCampos1:nAt := 1
	oCampos1:Refresh()
	oCampos1:SetFocus()
Else
	If Len(aCampos2) > 0
		oCampos2:nAt := 1
		oCampos2:Refresh()
		oCampos2:SetFocus()
	Else
		oCampos1:Refresh()
		oCampos2:Refresh()
	Endif
EndIf
Return Nil



Static Function AtuCab()

Local aFunc	
Local nx	:= 0
Local cWrite	:= ""  
Local cMvFldPln := ""
Local nCount	:= 0
Local ny


For nx := 1 to Len(aCabReport)
	aFunc	:= aCabReport[nx][8]
	cPln1SX6	:= aCabReport[nx,16]
	aCpsVar2	:= {}
	aCampos2	:= {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do array de campos selecionados                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While At("#",cPln1SX6) <> 0
		nPosSep := At("#",cPln1SX6)
		
		If Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),1,1)=="|"
			aAdd(aCpsVar2,{,,,,,,,})
			aCpsVar2[Len(aCpsVar2)][1] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),02,10)  // nome
			aCpsVar2[Len(aCpsVar2)][2] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),13,25)  // titulo
			aCpsVar2[Len(aCpsVar2)][4] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),70,01)  // tipo
			aCpsVar2[Len(aCpsVar2)][5] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),72,02))  // tamanhho
			aCpsVar2[Len(aCpsVar2)][6] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),75,01))  // decimal
			aCpsVar2[Len(aCpsVar2)][7] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),77,60)	 // picture
	
			Do Case
				Case aCpsVar2[Len(aCpsVar2)][4]=="C"
					aCpsVar2[Len(aCpsVar2)][3] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30)
				Case aCpsVar2[Len(aCpsVar2)][4]=="N"
					aCpsVar2[Len(aCpsVar2)][3] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30))
				Case aCpsVar2[Len(aCpsVar2)][4]=="D"
					aCpsVar2[Len(aCpsVar2)][3] := CTOD(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30))
			EndCase		
	
			aCpsVar2[Len(aCpsVar2)][8] := "_|"+PadR(aCpsVar2[Len(aCpsVar2)][1], 10, " ")+;                // nome
															"|"+PadR(aCpsVar2[Len(aCpsVar2)][2], 25, " ")+;                 // titulo
															"|"+PadR(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30), 30, " ")+;  // valor  - direto do arquivo
															"|"+PadR(aCpsVar2[Len(aCpsVar2)][4], 1, " ")+;                   // tipo
															"|"+StrZero(aCpsVar2[Len(aCpsVar2)][5],2,0)+;                 // tamanho
															"|"+StrZero(aCpsVar2[Len(aCpsVar2)][6],1,0)+;                 // decimal
															"|"+PadR(aCpsVar2[Len(aCpsVar2)][7], 60, " ")
		ElseIf Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),1,1)=="@"
			nPosFunc	:= 0
		Else
			aAdd(aCampos2,{,})
			aCampos2[Len(aCampos2)][2] := AllTrim(Substr(cPln1Sx6, 2, nPosSep-2))
			If Substr(aCampos2[Len(aCampos2)][2],1,1)=="%"
				aCampos2[Len(aCampos2)][1] := "="+Substr(aCampos2[Len(aCampos2)][2],2,9)
			ElseIf Substr(aCampos2[Len(aCampos2)][2],1,1)=="$"
				nPosFunc := aScan(aFunc,{|x| AllTrim(x[2])==AllTrim(Substr(aCampos2[Len(aCampos2)][2],1,10))})
				If nPosFunc > 0
					aCampos2[Len(aCampos2)]	[1] := aFunc[nPosFunc][1]
				EndIf
			Else
				dbSelectArea("SX3")
				dbSetOrder(2)
				dbSeek(Substr(aCampos2[Len(aCampos2)][2],1,10))
				aCampos2[Len(aCampos2)][1] := X3TITULO()
			EndIf
		Endif
		cPln1Sx6 := Substr(cPln1SX6,nPosSep+1,Len(cPln1SX6)-nPosSep)
	End
		
	AtuFields(nx,aCampos2, aCpsVar2)
Next

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AtuCab    ³ Autor ³ Adriano Ueda         ³ Data ³ 29-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para salvar a planilha com senha                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 : Arrays contendo os campos                            ³±±
±±³          ³ ExpA2 : Arrays contendo as variaveis                         ³±±
±±³          ³ ExpC1 : Nome do arquivo                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtuFields(nCab,aCampos, aVars)
Local cMvFldPln	:= ""
Local nCount		:= 0

aCabReport[nCab][5] := {}
aCabReport[nCab][6] := {}
nTamanho := 20
aAdd(aCabReport[nCab][6],nTamanho )
// campos e formulas

For nCount := 1 to Len(aCampos)
	nTamanho += Val(Substr(aCampos[nCount][2],100,3))
	cMvFldPln += ("_"+aCampos[nCount][2]+"#")
	If Substr(aCampos[nCount][2],1,1) == "%"
		aAdd(aCabReport[nCab][5],{ If(Substr(aCampos[nCount][2],11,2)=="",Nil,Val(Substr(aCampos[nCount][2],11,2))),;
											If(Substr(aCampos[nCount][2],13,2)=="",Nil,Val(Substr(aCampos[nCount][2],13,2))),;
											If(Substr(aCampos[nCount][2],15,10)=="",Nil,Val(Substr(aCampos[nCount][2],15,10))),;
											If(Substr(aCampos[nCount][2],25,1)=="1",.T.,.F.),;
											AllTrim(Substr(aCampos[nCount][2],1,10)),;
											,;
											Substr(aCampos[nCount][2],26,30),;
											If(Substr(aCampos[nCount][2],56,2)=="",,Val(Substr(aCampos[nCount][2],56,2))),;
											If(Substr(aCampos[nCount][2],58,2)=="",Nil,Val(Substr(aCampos[nCount][2],58,2))),;
											If(Substr(aCampos[nCount][2],60,10)=="",Nil,Val(Substr(aCampos[nCount][2],60,10))),;
											,;
											Substr(aCampos[nCount][2],70,30),;
											If(Substr(aCampos[nCount][2],100,3)=="",Nil,Val(Substr(aCampos[nCount][2],100,3))),;
											If(Substr(aCampos[nCount][2],106,80)=="",Nil,Substr(aCampos[nCount][2],106,80)) } )
	Else	
		aAdd(aCabReport[nCab][5],{ If(Substr(aCampos[nCount][2],11,2)=="",Nil,Val(Substr(aCampos[nCount][2],11,2))),;
											If(Substr(aCampos[nCount][2],13,2)=="",Nil,Val(Substr(aCampos[nCount][2],13,2))),;
											If(Substr(aCampos[nCount][2],15,10)=="",Nil,Val(Substr(aCampos[nCount][2],15,10))),;
											If(Substr(aCampos[nCount][2],25,1)=="1",.T.,.F.),;
											AllTrim(Substr(aCampos[nCount][2],1,10)),;
											,;
											Substr(aCampos[nCount][2],26,30),;
											If(Substr(aCampos[nCount][2],56,2)=="",,Val(Substr(aCampos[nCount][2],56,2))),;
											If(Substr(aCampos[nCount][2],58,2)=="",Nil,Val(Substr(aCampos[nCount][2],58,2))),;
											If(Substr(aCampos[nCount][2],60,10)=="",Nil,Val(Substr(aCampos[nCount][2],60,10))),;
											,;
											Substr(aCampos[nCount][2],70,30),;
											If(Substr(aCampos[nCount][2],100,3)=="",Nil,Val(Substr(aCampos[nCount][2],100,3))),;
											"" } )
	EndIf											
	
	aAdd(aCabReport[nCab][6],nTamanho )
Next

// variaveis
For nCount := 1 To Len(aVars)
	If !Empty(aVars[nCount][1])
		If Chr(0) $ aVars[nCount][8]
			cMvFldPln += RetNulos(aVars[nCount][8]) +"#"
		Else
			cMvFldPln += aVars[nCount][8] +"#"
		Endif
	EndIf
Next

cMvFldPln += ("_@"+If(aCabReport[nCab,1],"1","2")+; // Auto Align
						Str(aCabReport[nCab,3],3)+; // Altura Cabecalho
						Str(aCabReport[nCab,2],2)+; // Celula de Auto Size
						Str(aCabReport[nCab,7],3)+; // Espaçamento
						If(aCabReport[nCab,18],"1","2")+; // Imprime cabecalho entre as alteracoes
						If(aCabReport[nCab,19],"1","2")+; // Imprime cabecalho entre as alteracoes
						"#")

cCmpPLN	:= cMvFldPln


aCabReport[nCab][16] := cCmpPln 

Return


Function PgrSelColor(nColorR,nColorG,nColorB)

Local aItens := {}
Local nX     := 0
Local lOk    := .F.
Local oPanel
Local cBlock 
Local nY     := 0

Private nRed   := nColorR
Private nGreen := nColorG
Private nBlue  := nColorB
Private oDlg
	
   // monta a tela
	DEFINE MSDIALOG oDlg FROM 0,0  TO 150,325 TITLE "Palheta de cores " Of oMainWnd PIXEL 
	
		// monta quadros de cores
		MostraCor( 2 ,nColorR ,nColorG ,nColorB ,oDlg )
		
		// monta o box para "juntar" os objetos para definicao de cores.
		@  2 ,4 TO 70,160 Label "" Of oDlg PIXEL
		
		For ny := 1 to 255 STEP 20
			For nx := 1 to 255 STEP 20
				oPanel := tPanel():New( 10+(4*ny/20),10+(4*(nx/20)),"",oDlg,,.T.,.T.,,RGB(nx ,ny , 255-((nx+ny)/2)) ,4,4,.F.,.F.)
				cBlock:= "{|| nRed:="+Str(nx)+",nGreen:="+Str(ny)+",nBlue:="+STR(255-((nx+ny)/2))+",MostraCor( 2, nRed ,nGreen ,nBlue ,oDLG ) }"
				oPanel:bLClicked := MontaBlock(cBlock)
			Next
		Next ny
		
		For ny := 1 to 255 STEP 20
			oPanel := tPanel():New( 10+(4*ny/20),70,"",oDlg,,.T.,.T.,,RGB(ny ,ny , ny ) ,4,4,.F.,.F.)
			cBlock:= "{|| nRed:=nRed+((255-nRed)/255)*"+Str(ny)+",nGreen:=nGreen+((255-nGreen)/255)*"+Str(ny)+",nBlue:=nBlue+((255-nBlue)/255)*"+Str(ny)+",MostraCor( 2, NoROund(nRed,0) ,NoRound(nGreen,0) ,NoRound(nBlue,0) ,oDLG ) }"
			oPanel:bLClicked := MontaBlock(cBlock)
		Next ny


		@  10 ,80 SAY "Red" Of oDlg PIXEL SIZE 30 ,8
		@  10 ,102 MSGET nRed Picture "@E 999" VALID {nRed:=iif(nRed>255,255,iif(nRed<0,0,nRed)) ,MostraCor( 2, nRed ,nGreen ,nBlue ,oDLG )}  PIXEL SIZE 15,8
		@  30,80 SAY "Green" Of oDlg PIXEL SIZE 30 ,8
		@  30,102 MSGET nGreen Picture "@E 999" VALID {nGreen:=iif(nGreen>255,255,iif(nGreen<0,0,nGreen)) ,MostraCor( 2, nRed ,nGreen ,nBlue ,oDLG ) } PIXEL SIZE 15,8
		@  50,80 SAY "Blue" Of oDlg PIXEL SIZE 30 ,8
		@  50,102 MSGET nBlue Picture "@E 999" VALID {nBlue:=iif(nBlue>255,255,iif(nBlue<0,0,nBlue)) ,MostraCor( 2, nRed ,nGreen ,nBlue ,oDLG ) } PIXEL SIZE 15,8
		
		@ 70,266 BTNBMP oBtn1 RESOURCE "PCOFXOK"   SIZE 25,25 ACTION ( nColorR := nRed ,nColorG := nGreen ,nColorB := nBlue ,MostraCor( 1 ,nRed ,nGreen ,nBlue ,oDLG ) ,lok := .T.,oDlg:End() ) 
		oBtn1:cToolTip := "Confirmar"
		@ 95,266 BTNBMP oBtn2 RESOURCE "PCOFXCANCEL"   SIZE 25,25 ACTION ( oDlg:End() )
		oBtn2:cToolTip := "Cancelar"

	ACTIVATE MSDIALOG oDlg CENTERED

Return( lOk )



Static Function MostraCor( nPainel ,nRed ,nGreen ,nBlue ,oDLG ) 
Local oPanel 
Local nY := 0
	
	If nPainel == 1
		// quadro da cor atual da barra
		oPanel := tPanel():New( 45,133,"",oDlg,,.T.,.T.,,RGB(nRed ,nGreen ,nBlue) ,20,20,.T.,.T.)
	Else
		// quadro secundario de cor selecionada 
		oPanel := tPanel():New(  10,133,"",oDlg,,.T.,.T.,,RGB(nRed ,nGreen ,nBlue) ,20,20,.T.,.T.)

		If nPainel == 2

			For ny := 1 to 255 STEP 20
				If ny > 230
					oPanel := tPanel():New( 10+(4*ny/20),70,"",oDlg,,.T.,.T.,,RGB(255,255,255 ) ,4,4,.F.,.F.)
					cBlock:= "{|| nRed:=255,nGreen:=255,nBlue:=255,MostraCor( 3, NoROund(nRed,0) ,NoRound(nGreen,0) ,NoRound(nBlue,0) ,oDLG ) }"
					oPanel:bLClicked := MontaBlock(cBlock)
				Else
					If ny<126
						oPanel := tPanel():New( 10+(4*ny/20),70,"",oDlg,,.T.,.T.,,RGB( NoRound((nRed/126)*ny,0),NoRound((nGreen/126)*ny,0) ,NoRound((nBlue/126)*ny,0)) ,4,4,.F.,.F.)
						cBlock:= "{|| nRed:="+Str(NoRound((nRed/126)*ny,0) )+",nGreen:="+Str(NoRound((nGreen/126)*ny,0))+",nBlue:="+Str(NoRound((nBlue/126)*ny,0) )+",MostraCor( 3, NoROund(nRed,0) ,NoRound(nGreen,0) ,NoRound(nBlue,0) ,oDLG ) }"
						oPanel:bLClicked := MontaBlock(cBlock)
					Else
						oPanel := tPanel():New( 10+(4*ny/20),70,"",oDlg,,.T.,.T.,,RGB( NoRound(nRed+((255-nRed)/126)*(ny-126),0),NoRound(nGreen+((255-nGreen)/126)*(ny-126),0) ,NoRound(nBlue+((255-nBlue)/126)*(ny-126),0)) ,4,4,.F.,.F.)
						cBlock:= "{|| nRed:="+Str(NoRound(nRed+((255-nRed)/126)*(ny-126),0) )+",nGreen:="+Str(NoRound(nGreen+((255-nGreen)/126)*(ny-126),0))+",nBlue:="+Str(NoRound(nBlue+((255-nBlue)/126)*(ny-126),0) )+",MostraCor( 3, NoROund(nRed,0) ,NoRound(nGreen,0) ,NoRound(nBlue,0) ,oDLG ) }"
						oPanel:bLClicked := MontaBlock(cBlock)
					EndIf
				EndIf
			Next ny
		EndIf

	Endif
	
Return( NIL )



Static Function ShowCab()
Local oDlg
                               
DEFINE MSDIALOG oDlg FROM 0,0  TO 142,478 TITLE "Estilos de Cabeçalhos" Of oMainWnd PIXEL 

@00,00 BITMAP oBmp1 RESNAME "PGRESTCAB" SIZE 500,500 NOBORDER PIXEL Of oDlg

ACTIVATE MSDIALOG oDlg CENTERED
                                     
Return                                        

Static Function ShowLinha()
Local oDlg

DEFINE MSDIALOG oDlg FROM 0,0  TO 200,465 TITLE "Estilos de Detalhes" Of oMainWnd PIXEL 

@00,00 BITMAP oBmp1 RESNAME "PgrEstDet" SIZE 500,500 NOBORDER PIXEL Of oDlg

ACTIVATE MSDIALOG oDlg CENTERED

Return

Function PgrInUse()

Return !Empty(aCabReport)


Function PgrEdit(cTitulo,nPortLand,nFontes)
Local aRet 	:= {}
Local nx
Local aCombo	:= {}

nOrient := nPortLand
If lSenha
	If Senhabox({{1, "Senha", SPACE(10), "@A!", "", "", "", 30, .T.}}, "Configurações Protegidas. Informe a Senha de acesso.", @aRet) 
		If Encript(aRet[1], 1)#cPLNSenha
			Alert("Senha de acesso incorreta!")
			Return .F.
		EndIf
	Else
		Return .F.
	EndIf
EndIf


For nx := 1 to Len(aCabReport)
	aAdd(aCombo,aCabReport[nx][17])
Next

If EditDlg1(aCombo)
	cTitulo := cNamePgr
	nFontes := nPgrFnt
EndIf



Return



Static Function EditDlg1(aCombo)


Local oDlg2,oBmp1,oGrp3,oGet4,oGrp5,oChk8,oGet9,oSay10,oSay11,oSay12,oGet13,oSay14,oGet15,oSBtn16,oSBtn17,oSBtn19,oSay20,oBmp22,oCombo,oSay24,oCombo25,oChk24,oChk25,oSBtn27
oDlg2 := MSDIALOG():Create()
oDlg2:cName := "oDlg2"
oDlg2:cCaption := "Protheus Graphic Report - Editor de Layout "
oDlg2:nLeft := 0
oDlg2:nTop := 0
oDlg2:nWidth := 508
oDlg2:nHeight := 395
oDlg2:lShowHint := .F.
oDlg2:lCentered := .T.

oBmp1 := TBITMAP():Create(oDlg2)
oBmp1:cName := "oBmp1"
oBmp1:cCaption := "oBmp1"
oBmp1:nLeft := 17
oBmp1:nTop := 10
oBmp1:nWidth := 379
oBmp1:nHeight := 26
oBmp1:lShowHint := .F.
oBmp1:lReadOnly := .F.
oBmp1:Align := 0
oBmp1:lVisibleControl := .T.
oBmp1:cResName := "PcoImpr2"
oBmp1:lStretch := .F.
oBmp1:lAutoSize := .F.

oGrp3 := TGROUP():Create(oDlg2)
oGrp3:cName := "oGrp3"
oGrp3:cCaption := "Titulo"
oGrp3:nLeft := 19
oGrp3:nTop := 44
oGrp3:nWidth := 195
oGrp3:nHeight := 84
oGrp3:lShowHint := .F.
oGrp3:lReadOnly := .F.
oGrp3:Align := 0
oGrp3:lVisibleControl := .T.

oGet4 := TGET():Create(oDlg2)
oGet4:cName := "oGet4"
oGet4:nLeft := 31
oGet4:nTop := 60
oGet4:nWidth := 169
oGet4:nHeight := 21
oGet4:lShowHint := .F.
oGet4:lReadOnly := .F.
oGet4:Align := 0
oGet4:cVariable := "cNamePgr"
oGet4:bSetGet := {|u| If(PCount()>0,cNamePgr:=u,cNamePgr) }
oGet4:lVisibleControl := .T.
oGet4:lPassword := .F.
oGet4:lHasButton := .F.

oGrp5 := TGROUP():Create(oDlg2)
oGrp5:cName := "oGrp5"
oGrp5:nLeft := 18
oGrp5:nTop := 140
oGrp5:nWidth := 375
oGrp5:nHeight := 179
oGrp5:lShowHint := .F.
oGrp5:lReadOnly := .F.
oGrp5:Align := 0
oGrp5:lVisibleControl := .T.

oGet9 := TGET():Create(oDlg2)
oGet9:cName := "oGet9"
oGet9:nLeft := 129
oGet9:nTop := 228
oGet9:nWidth := 71
oGet9:nHeight := 21
oGet9:lShowHint := .F.
oGet9:lReadOnly := .F.
oGet9:Align := 0
oGet9:cVariable := "aCabReport[oCombo:nAT,2]"
oGet9:bSetGet := {|u| If(PCount()>0,aCabReport[oCombo:nAT,2]:=u,aCabReport[oCombo:nAT,2]) }
oGet9:lVisibleControl := .T.
oGet9:lPassword := .F.
oGet9:lHasButton := .F.
oGet9:bWhen := {|| aCabReport[1,1] }

oSay11 := TSAY():Create(oDlg2)
oSay11:cName := "oSay11"
oSay11:cCaption := "Celula p/ Auto-Size"
oSay11:nLeft := 28
oSay11:nTop := 231
oSay11:nWidth := 95
oSay11:nHeight := 17
oSay11:lShowHint := .F.
oSay11:lReadOnly := .F.
oSay11:Align := 0
oSay11:lVisibleControl := .T.
oSay11:lWordWrap := .F.
oSay11:lTransparent := .F.

oSay12 := TSAY():Create(oDlg2)
oSay12:cName := "oSay12"
oSay12:cCaption := "Tam.Cabeçalho"
oSay12:nLeft := 27
oSay12:nTop := 195
oSay12:nWidth := 77
oSay12:nHeight := 17
oSay12:lShowHint := .F.
oSay12:lReadOnly := .F.
oSay12:Align := 0
oSay12:lVisibleControl := .T.
oSay12:lWordWrap := .F.
oSay12:lTransparent := .F.

oGet13 := TGET():Create(oDlg2)
oGet13:cName := "oGet13"
oGet13:nLeft := 106
oGet13:nTop := 193
oGet13:nWidth := 95
oGet13:nHeight := 21
oGet13:lShowHint := .F.
oGet13:lReadOnly := .F.
oGet13:Align := 0
oGet13:cVariable := "aCabReport[oCombo:nAT,3]"
oGet13:bSetGet := {|u| If(PCount()>0,aCabReport[oCombo:nAT,3]:=u,aCabReport[oCombo:nAT,3]) }
oGet13:lVisibleControl := .T.
oGet13:lPassword := .F.
oGet13:lHasButton := .F. 
oGet13:Picture := "@E 999"

oSay14 := TSAY():Create(oDlg2)
oSay14:cName := "oSay14"
oSay14:cCaption := "Espaç.Linhas"
oSay14:nLeft := 216
oSay14:nTop := 195
oSay14:nWidth := 65
oSay14:nHeight := 17
oSay14:lShowHint := .F.
oSay14:lReadOnly := .F.
oSay14:Align := 0
oSay14:lVisibleControl := .T.
oSay14:lWordWrap := .F.
oSay14:lTransparent := .F.

oGet15 := TGET():Create(oDlg2)
oGet15:cName := "oGet15"
oGet15:nLeft := 285
oGet15:nTop := 193
oGet15:nWidth := 94
oGet15:nHeight := 21
oGet15:lShowHint := .F.
oGet15:lReadOnly := .F.
oGet15:Align := 0
oGet15:cVariable := "aCabReport[oCombo:nAT,7]"
oGet15:bSetGet := {|u| If(PCount()>0,aCabReport[oCombo:nAT,7]:=u,aCabReport[oCombo:nAT,7]) }
oGet15:lVisibleControl := .T.
oGet15:lPassword := .F.
oGet15:lHasButton := .F.
oGet15:Picture := "@E 999"

oSBtn16 := SBUTTON():Create(oDlg2)
oSBtn16:cName := "oSBtn16"
oSBtn16:nLeft := 421
oSBtn16:nTop := 11
oSBtn16:nWidth := 61
oSBtn16:nHeight := 22
oSBtn16:lShowHint := .F.
oSBtn16:lReadOnly := .F.
oSBtn16:Align := 0
oSBtn16:lVisibleControl := .T.
oSBtn16:nType := 1
oSBtn16:bLClicked := {|| lRet := .T.,nPgrFnt:= oCombo25:nAT,AtuCab(),oDlg2:End() }

oSBtn17 := SBUTTON():Create(oDlg2)
oSBtn17:cName := "oSBtn17"
oSBtn17:nLeft := 421
oSBtn17:nTop := 41
oSBtn17:nWidth := 61
oSBtn17:nHeight := 22
oSBtn17:lShowHint := .F.
oSBtn17:lReadOnly := .F.
oSBtn17:Align := 0
oSBtn17:lVisibleControl := .T.
oSBtn17:nType := 2
oSBtn17:bLClicked := {|| oDlg2:End() }

oSBtn19 := SBUTTON():Create(oDlg2)
oSBtn19:cName := "oSBtn19"
oSBtn19:cCaption := "oSBtn19"
oSBtn19:nLeft := 302
oSBtn19:nTop := 227
oSBtn19:nWidth := 61
oSBtn19:nHeight := 22
oSBtn19:lShowHint := .F.
oSBtn19:lReadOnly := .F.
oSBtn19:Align := 0
oSBtn19:lVisibleControl := .T.
oSBtn19:nType := 11
oSBtn19:bLClicked := {|| PgrCfg(oCombo:nAT) }

oSay20 := TSAY():Create(oDlg2)
oSay20:cName := "oSay20"
oSay20:cCaption := "Config.Celulas"
oSay20:nLeft := 213
oSay20:nTop := 230
oSay20:nWidth := 71
oSay20:nHeight := 17
oSay20:lShowHint := .F.
oSay20:lReadOnly := .F.
oSay20:Align := 0
oSay20:lVisibleControl := .T.
oSay20:lWordWrap := .F.
oSay20:lTransparent := .F.

oBmp22 := TBITMAP():Create(oDlg2)
oBmp22:cName := "oBmp22"
oBmp22:cCaption := "oBmp22"
oBmp22:nLeft := 230
oBmp22:nTop := 48
oBmp22:nWidth := 161
oBmp22:nHeight := 79
oBmp22:lShowHint := .F.
oBmp22:lReadOnly := .F.
oBmp22:Align := 0
oBmp22:lVisibleControl := .T.
oBmp22:cResName := "PgrEdt"
oBmp22:lStretch := .F.
oBmp22:lAutoSize := .F.

oCombo := TCOMBOBOX():Create(oDlg2)
oCombo:cName := "oCombo"
oCombo:nLeft := 31
oCombo:nTop := 157
oCombo:nWidth := 351
oCombo:nHeight := 21
oCombo:lShowHint := .F.
oCombo:lReadOnly := .F.
oCombo:Align := 0
oCombo:cVariable := "cCombo"
oCombo:bSetGet := {|u| If(PCount()>0,cCombo:=u,cCombo) }
oCombo:lVisibleControl := .T.
oCombo:aItems := aCombo
oCombo:nAt := 1

@ 127,14 CHECKBOX oChk8 VAR aCabReport[oCombo:nAt,1] PROMPT "Justificar tamanho das celulas automaticamente" SIZE 139, 10  OF oDlg2 PIXEL ON CHANGE oGet9:Refresh()
@ 137,14 CHECKBOX oChk26 VAR aCabReport[oCombo:nAt,18] PROMPT "Imprimir o cabeçalho nas mudanças de detalhes" SIZE 139, 10  OF oDlg2 PIXEL 
@ 147,14 CHECKBOX oChk28 VAR aCabReport[oCombo:nAt,19] PROMPT "Quebrar nova pagina na impressao do cabeçalho" SIZE 139, 10  OF oDlg2 PIXEL 

oSay24 := TSAY():Create(oDlg2)
oSay24:cName := "oSay24"
oSay24:cCaption := "Fonte"
oSay24:nLeft := 29
oSay24:nTop := 83
oSay24:nWidth := 65
oSay24:nHeight := 17
oSay24:lShowHint := .F.
oSay24:lReadOnly := .F.
oSay24:Align := 0
oSay24:lVisibleControl := .T.
oSay24:lWordWrap := .F.
oSay24:lTransparent := .F.

oCombo25 := TCOMBOBOX():Create(oDlg2)
oCombo25:cName := "oCombo25"
oCombo25:nLeft := 32
oCombo25:nTop := 97
oCombo25:nWidth := 167
oCombo25:nHeight := 21
oCombo25:lShowHint := .F.
oCombo25:lReadOnly := .F.
oCombo25:Align := 0
oCombo25:lVisibleControl := .T.
oCombo25:aItems := { "Courrie New","Arial"}
oCombo25:nAt := nPgrFnt

@ 165,12 CHECKBOX oChk24 VAR lSenha PROMPT "Proteger edição com senha de acesso" SIZE 339, 10 ON CHANGE ProtArq() OF oDlg2 PIXEL 

@ 175,12 CHECKBOX oChk25 VAR lForceLand PROMPT "Permitir apenas impressao em orientação Landscape" SIZE 339, 10  OF oDlg2 PIXEL 


oSBtn27 := SBUTTON():Create(oDlg2)
oSBtn27:cName := "oSBtn27"
oSBtn27:cCaption := "oSBtn27"
oSBtn27:nLeft := 421
oSBtn27:nTop := 72
oSBtn27:nWidth := 61
oSBtn27:nHeight := 22
oSBtn27:lShowHint := .F.
oSBtn27:lReadOnly := .F.
oSBtn27:Align := 0
oSBtn27:lVisibleControl := .T.
oSBtn27:nType := 13
oSBtn27:bLClicked := {|| AtuCab(),PgrSave() }

oDlg2:Activate()

Return


Static Function Dlg1(aCombo)

Local lRet := .F.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ProtArq   ³ Autor ³ Adriano Ueda         ³ Data ³ 22-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controla a protecao do arquivo com senha                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProtArq() 
Local aRet := {}
Local cTitulo := ""
			
If lSenha
	// arquivo estava desprotegido
	cTitulo := "Proteger arquivo com senha"
Else
	cTitulo := "Desproteger arquivo"
EndIf

If Senhabox({{1, "Senha", SPACE(10), "@A!", "", "", "", 30, .T.}}, cTitulo, @aRet) 
	If lSenha
		// arquivo estava desprotegido
		cPLNSenha := Encript(aRet[1], 1)
		Alert("Arquivo protegido com sucesso!")
	Else
		// arquivo estava protegido
		If Encript(aRet[1], 1)==cPLNSenha
			Alert("Arquivo desprotegido com sucesso!")
			cPLNSenha := ""			
		Else
			Alert("Senha incorreta. Verifique a senha informada!")

			// volta estado original do check
			lSenha := !lSenha
			oUsado:lActive := !oUsado:lActive
			oUsado:Refresh()
		EndIf
	EndIf
Else
	// volta estado original do check
	lSenha := !lSenha
	oUsado:lActive := !oUsado:lActive
	oUsado:Refresh()
	
EndIf
Return .T.



Function PgrTotal(cQuebra,nValor,cTexto,cPicture,lImprime,cGrafico,nTpGrafico,nSerie,nColor)

Local nPos := aScan(aTotais,{|x| x[1] == cQuebra .And. x[6] == 1})
Default cPicture := "999,999,999,999,999.99"
Default cTexto := ""
Default lImprime := .T.
Default nColor := CLR_BLUE

If nPos > 0
	aTotais[nPos][3] += nValor
Else
	aAdd(aTotais,{cQuebra,cTexto,nValor,cPicture,lImprime,1,cGrafico,nTpGrafico,nSerie,nColor})
	nPos := Len(aTotais)
EndIf

Return aTotais[nPos][3]


Function PgrEnd(oPrint)
Local aGraphic	:= {}
Local ni
Local lFirst := .T.
Local nx,ny,nz
Local oDlgTot
Local oGraphic

MAKEDIR("\PMSBMP\")

If !Empty(aTotais)
	For nx := 1 to Len(aTotais)
		If aTotais[nx][7] <> Nil
			nPosGraphic := aScan(aGraphic,{|x| x[1] == aTotais[nx][7] })
			If nPosGraphic > 0
				nPosSerie := aScan(aGraphic[nPosGraphic,2],{|x| x[1] == aTotais[nx][8] })
				If nPosSerie > 0 
					aAdd(aGraphic[nPosGraphic,2,nPosSerie,4],{Alltrim(aTotais[nx,1]),aTotais[nx,3]})
				Else
					aAdd(aGraphic[nPosGraphic,2],{aTotais[nx][8],aTotais[nx][9],aTotais[nx][10],{{Alltrim(aTotais[nx,1]),aTotais[nx,3]}}})
				EndIf
			Else
				aAdd(aGraphic,{aTotais[nx][7],{{aTotais[nx][8],aTotais[nx][9],aTotais[nx][10],{{Alltrim(aTotais[nx,1]),aTotais[nx,3]}}}}})
			EndIf
		EndIf
		If aTotais[nx,5]
			If lFirst
				nPgrLin += 50
				PcoPrtCol({20,600,1550,2400},.T.,2)
				PcoPrtCell(PcoPrtPos(1),nPgrLin,PcoPrtTam(2),30,"Totais",oPrint,5,2)
				PcoPrtCell(PcoPrtPos(3),nPgrLin,PcoPrtTam(3),30,"Valor",oPrint,5,2,,,.T.)
				nPgrLin+=55
				lFirst := .F.
			EndIf
			PcoPrtCell(PcoPrtPos(1),nPgrLin,PcoPrtTam(1),30,Alltrim(aTotais[nx,1]),oPrint,3,2,RGB(230,230,230))
			PcoPrtCell(PcoPrtPos(2),nPgrLin,PcoPrtTam(2),30,Alltrim(aTotais[nx,2]),oPrint,3,2,RGB(230,230,230))
			PcoPrtCell(PcoPrtPos(3),nPgrLin,PcoPrtTam(3),30,Transform(aTotais[nx,3],aTotais[nx,4]),oPrint,3,2,RGB(230,230,230),,.T.)
			nPgrLin+=35
			If PcoPrtLim(nPgrLin) 
				nPgrLin := 200
				PcoPrtCab(oPrint)
				nPgrLin += 55
			EndIf
		EndIf
	Next
EndIf	   

PcoPrtCol({20,60,1390,1450,1650,2400},.T.,2)

DEFINE FONT oFont NAME "Arial" SIZE 0, -11 

For nx := 1 to Len(aGraphic)
	aSeries := {}
	DEFINE MSDIALOG oDlgTot TITLE "" From 0,0 To  0,0 of oMainWnd PIXEL STYLE nOR(WS_VISIBLE,WS_POPUP)
	
	@ 1,1 MSGRAPHIC oGraphic SIZE 300,200 OF oDlgTot FONT oFont
	
	oGraphic:SetMargins( 0, 10, 10,10 )
	oGraphic:SetFont( oFont )
	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( aGraphic[nx,1], "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )
	For ny := 1 to Len(aGraphic[nx,2])
		aAdd(aSeries,{aGraphic[nx,2,ny,1],aGraphic[nx,2,ny,3]})
		nSerie	:= oGraphic:CreateSerie( aGraphic[nx,2,ny,2] )
		oGraphic:l3D := .F.
	
		For nz := 1 to Len(aGraphic[nx,2,ny,4])
			oGraphic:Add(nSerie,aGraphic[nx,2,ny,4,nz,2],aGraphic[nx,2,ny,4,nz,1],aGraphic[nx,2,ny,3])
		Next
	Next ny 
	      
	ACTIVATE MSDIALOG oDlgTot ON INIT (oGraphic:SaveToBMP( "Graph.BMP","\PMSBMP\"  ),oDlgTot:End())
	nPgrLin := 200
	PcoPrtCab(oPrint)
	nPgrLin += 55

	PcoPrtCell(PcoPrtPos(2),nPgrLin,PcoPrtTam(2),PcoPrtTam(2)*0.6,"\PMSBMP\Graph.BMP" ,oPrint,8)
	For ni := 1 to len(aSeries)
		PcoPrtCell(PcoPrtPos(4),nPgrLin+20+((ni-1)*35),PcoPrtTam(1),30,"" ,oPrint,2,1,aSeries[ni,2])
		PcoPrtCell(PcoPrtPos(5),nPgrLin+20+((ni-1)*35),PcoPrtTam(5),30,aSeries[ni,1] ,oPrint,5,1)
	Next

	nPgrLin+= (PcoPrtTam(1)*0.6) + 5
Next nx

PcoPrtEnd(oPrint)

Return

Function ReadCab(nx)
Local cRead := ""

FT_FGOTOP()
FT_FSKIP()
FT_FSKIP()
FT_FSKIP()

While !FT_FEOF()
	If Val(Substr(FT_FREADLN(),1,4))==nx .And. !Empty(FT_FREADLN())
		cRead += Substr(FT_FREADLN(),5)
	EndIf	
	FT_FSKIP()
End

Return cRead


Function PgrMin(cQuebra,nValor,cTexto,cPicture,lImprime)

Local nPos := aScan(aTotais,{|x| x[1] == cQuebra .And. x[6] == 2})
Default cPicture := "999,999,999,999,999.99"
Default cTexto := ""
Default lImprime := .T.

If nPos > 0
	If nValor < aTotais[nPos][3] 
		aTotais[nPos][3] := nValor
	EndIf
Else
	aAdd(aTotais,{cQuebra,cTexto,nValor,cPicture,lImprime,2})
	nPos := Len(aTotais)
EndIf

Return aTotais[nPos][3]


Function PgrMax(cQuebra,nValor,cTexto,cPicture,lImprime)

Local nPos := aScan(aTotais,{|x| x[1] == cQuebra .And. x[6] == 3})
Default cPicture := "999,999,999,999,999.99"
Default cTexto := ""
Default lImprime := .T.

If nPos > 0
	If nValor > aTotais[nPos][3] 
		aTotais[nPos][3] := nValor
	EndIf
Else
	aAdd(aTotais,{cQuebra,cTexto,nValor,cPicture,lImprime,3})
	nPos := Len(aTotais)
EndIf

Return aTotais[nPos][3]


Function PgrCount(cQuebra,nValor,cTexto,cPicture,lImprime,cGrafico,nTpGrafico,nSerie,nColor)

Local nPos := aScan(aTotais,{|x| x[1] == cQuebra .And. x[6] == 4})
Default cPicture := "999,999,999,999,999.99"
Default cTexto := ""
Default lImprime := .T.
Default nColor := CLR_BLUE

If nPos > 0
	aTotais[nPos][3] ++
Else
	aAdd(aTotais,{cQuebra,cTexto,nValor,cPicture,lImprime,4,cGrafico,nTpGrafico,nSerie,nColor})
	nPos := Len(aTotais)
EndIf

Return aTotais[nPos][3]


Function PgrMedia(cQuebra,nValor,cTexto,cPicture,lImprime)

Local nPos := aScan(aTotais,{|x| x[1] == cQuebra .And. x[6] == 5})
Local nPosMedia := aScan(aMedia,{|x| x[1] == cQuebra })
Default cPicture := "999,999,999,999,999.99"
Default cTexto := ""
Default lImprime := .T.


If nPosMedia > 0 // Recalcula a Media
	aMedia[nPosMedia][2]++
	aMedia[nposMedia][3] += nValor
	aMedia[nPosMedia][4] := aMedia[nPosMedia][3]/aMedia[nPosMedia][2]
Else
	aAdd(aMedia,{cQuebra,1,nValor,nValor})
	nPosMedia := Len(aMedia)
EndIf
If nPos > 0
	aTotais[nPos][3] := aMedia[nPosMedia][4]
Else
	aAdd(aTotais,{cQuebra,cTexto,aMedia[nPosMedia][4],cPicture,lImprime,5})
	nPos := Len(aTotais)
EndIf

Return aTotais[nPos][3]


Function PgrCancel(oPrint) 

PgrEndLin(oPrint) 

nPgrLin += 50
PcoPrtCol({20,1550,2400},.T.,2)
PcoPrtCell(PcoPrtPos(1),nPgrLin,PcoPrtTam(1),30,"IMPRESSAO CANCELADA PELO USUARIO",oPrint,5,2)


Return


Function PgList(cAlias,nOrder)
Local aArea		:= GetArea()
Local lOk		:= .F.
Local lEnd
Local cDescri

dbSelectArea("SX2")
dbSetOrder(1)
dbSeek(cAlias)
cDescri := X2NOME()

// Inicializa o uso da função PGReport
PgrIni(	"",cDescri,.T.,2,,2,{{7,"Filtro : "+cDescri,cAlias,""}},,cAlias)



//---------------------------------------------------------------------------------------
// Definicao do cabecalho de detalhes 

PgrAddCab(	.T.,2,50,40,cAlias,{},	,,,,,,,cDescri,.T.,.F.) 

		
// Finaliza a definição do 2o cabecalho - Alocacao de Recursos
PgrEndCab(1)
//---------------------------------------------------------------------------------------

// Monta a Dialog ( substituição da antiga SetPrint ) 
oPrint := PgrDialog(@lOk)

If lOk
	// Imprime o relatorio
	RptStatus( {|lEnd| PgListImp(lEnd,oPrint,cAlias,nOrder)})
	PgrEnd(oPrint)
EndIf


dbSelectArea(cAlias)
RetIndex(cAlias)
Set Filter To
dbSetOrder(1)

RestArea(aArea)
Return


Static Function PgListImp(lEnd,oPrint,cAlias,nOrder)
Local aArea		:= GetArea()
Local cNomeArq := CriaTrab(NIL,.F.)

If !Empty(PrtGetFilter(1))
	dbSelectArea(cAlias)
	dbSetOrder(nOrder)
	IndRegua(cAlias,cNomeArq,IndexKey(),,PrtGetFilter(1),"Selecionando registros no servidor, aguarde..")
	SetRegua(LastRec())
	dbSeek(xFilial())
Else
	dbSelectArea(cAlias)
	dbSetOrder(nOrder)
	SetRegua(LastRec())
	dbSeek(xFilial())
EndIf


While !Eof()
	IncRegua()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lEnd
		PgrCancel(oPrint)
	   Exit
	EndIf

	PgrSetCab(oPrint,1)  // Seta o cabeçalho para impressao

	PgrAddLin(oPrint) // imprime a linha do cabecalho 1 de acordo com as configurações 
	
	PgrEndLin(oPrint,32) // Finaliza a linha e pula linha 	
	
	dbSelectArea(cAlias)
	dbSkip()
End


RestArea(aArea)
Return
