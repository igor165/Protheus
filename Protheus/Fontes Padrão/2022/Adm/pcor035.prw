#INCLUDE "pcor035.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE CELLTAMDATA 420
/*/
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOR035  � AUTOR � Reynaldo Tetsu Miyashita � DATA � 20-01-2004 ���
������������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa de impressao da planilha orcamentaria.                 ���
������������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                         ���
������������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOR035                                                         ���
���_DESCRI_  � Programa de impressao da planilha orcamentaria.                 ���
���_FUNC_    � Esta funcao devera ser utilizada com a sua chamada normal a     ���
���          � partir do Menu do sistema.                                      ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Function PCOR035(lCallPrg, aPerg)
Local aArea			:= GetArea()
Local aAreaAK1TMP
Local aAreaAKO
Local aAreaAK2TMP
Local lOk	:= .F.
Local oPrint
Local cR1, cR2, lPrintRel, bPrintRel, aPerVisao
Private nLin	:= 200

Default lCallPrg := .F.
Default aPerg := {}

If lCallPrg
	aAreaAK1TMP	:= TMPAK1->(GetArea())
	aAreaAKO	:= AKO->(GetArea())
	aAreaAK2TMP := TMPAK2->(GetArea())
	lOk := .T.
Else
	//quando chamado a partir do menu
	If Pergunte("PCRVIS", .T.)
		dbSelectArea("AKN")
		dbSetOrder(1)
		lOk := !Empty(MV_PAR01) .And. dbSeek(xFilial("AKN")+MV_PAR01)
		If lOk
			cR1 := NIL
			cR2 := NIL
			lPrintRel := .T.
			bPrintRel := {||PCOR035(.T.)}
			aPerVisao := {Str(MV_PAR02,1), MV_PAR03, MV_PAR04}
			PCO180EXE("AKN", AKN->(Recno()), 2, cR1, cR2, aPerVisao, lPrintRel, bPrintRel)
		EndIf
    EndIf
    Return   //retorna sempre pois ja gerou relatorio 
EndIf

If lOk
	// inicializa o oPrint
	If Len(aPerg) == 0
		oPrint := PcoPrtIni(STR0001,.T.,2,,@lOk,"PCR035",STR0014) //"Planilha Orcamentaria (Mod.2)"###"Este relatorio apresentara todos os itens orcamentarios referente a execucao da visao gerencial."
	Else
		aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
		oPrint := PcoPrtIni(STR0001,.T.,2,,@lOk,"",STR0014) //"Planilha Orcamentaria (Mod.2)"###"Este relatorio apresentara todos os itens orcamentarios referente a execucao da visao gerencial."
	EndIf

	If lOk
	
		RptStatus( {|lEnd| PCOR035Imp(@lEnd,oPrint)})
    	PcoPrtEnd(oPrint)
    	
	EndIf
EndIf

RestArea(aAreaAK1TMP)
RestArea(aAreaAKO)
RestArea(aAreaAK2TMP)
RestArea(aArea)

Return( NIL )

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOR035Imp� Autor � Reynaldo Tetsu Miyashita � Data �20-01-2004���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de impressao da planilha orcamentaria.                  ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �PCOR035Imp(lEnd)                                               ���
����������������������������������������������������������������������������Ĵ��
���Parametros� lEnd - Variavel para cancelamento da impressao pelo usuario   ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function PCOR035Imp(lEnd ,oPrint)
Local aPeriodo 		:= {}
Local lDescricao	:= .T.
Local nTam			:= 0
Local nX
    
// obtem os periodos
aPeriodo := PCO035CalcPer( TMPAK1->AK1_TPPERI ,TMPAK1->AK1_INIPER ,TMPAK1->AK1_FIMPER )	

aNovPer := {}   
For nX := 1 TO Len(aPeriodo)
	If aPeriodo[nX] >= mv_par01 .And. aPeriodo[nX] <= mv_par02
		aAdd(aNovPer, aPeriodo[nX])
	EndIf
Next

aPeriodo := AClone(aNovPer)

If Empty(aNovPer)
	HELP("  ",1,"PCOR0151")
EndIf

While ! Empty(aPeriodo)
	
	aNovPer := {}   
	aColDescr := {}
	nLin := 200
	If lDescricao
		nTam := 2150
	Else
		nTam := 20
	Endif
	
	While ((nTam+CELLTAMDATA)<=3100)
		If empty(aPeriodo)
			Exit
		Endif			
		aAdd( aNovPer ,aPeriodo[1])
		aDel( aPeriodo ,1)
		aSize( aPeriodo ,len(aPeriodo)-1)
		nTam += CELLTAMDATA
	End 
	
	// monta cabecalho principal
	PcoPrtCab(oPrint)
	PcoPrtCol({20,370,470,2075,2250})	
	PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,TMPAK1->AK1_CODIGO,oPrint,4,2,/*RgbColor*/,STR0002) //"Codigo"
	PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60,"",oPrint,4,2,/*RgbColor*/,"")
	PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),60,TMPAK1->AK1_DESCRI,oPrint,4,2,/*RgbColor*/,STR0003) //"Descricao"
	PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),60,DTOC(TMPAK1->AK1_INIPER),oPrint,4,2,/*RgbColor*/,STR0004) //"Dt.Inicio"
	PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),60,DTOC(TMPAK1->AK1_FIMPER),oPrint,4,2,/*RgbColor*/,STR0005) //"Dt.Fim"
	nLin+=70
	
	aTamCols := {}
	If lDescricao
		aColDescr := {STR0006 ,STR0007 ,STR0003 ,STR0008 ,"" } //"C.O.G."###"Nivel"###"Descricao"###"Tipo"
		aTamCols := {20,370,470,2050,2200}
	Else
		aColDescr := {"" }
		aTamCols := {20}
	Endif	
	PcoPrtCol(aTamCols)
	PCOR035TitCol( @oPrint ,aColDescr )
	
	dbSelectArea("AKO")
	dbSetOrder(3)
	MsSeek(xFilial()+PadR(TMPAK1->AK1_CODIGO,Len(AKO->AKO_CODIGO))+"001")
	While !Eof() .And. 	AKO_FILIAL+AKO_CODIGO+AKO_NIVEL==;
						xFilial("AKO")+PadR(TMPAK1->AK1_CODIGO,Len(AKO->AKO_CODIGO))+"001"
		// Dados da classe orcamentaria
		PCOR035CO( AKO_CODIGO ,AKO_CO ,	aNovPer ,aTamCols ,@oPrint ,lDescricao ,aColDescr ,aTamCols )
		dbSelectArea("AKO")
		dbSkip()
	End 
	lDescricao := .F.
End
	
Return( NIL )

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOR035CO � Autor � Reynaldo Tetsu Miyashita � Data �20-01-2004���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de impressao da planilha orcamentaria do Centro         ���
���          �orcamentario.                                                  ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �PCOR035CO( cVisGer,cCO,aPeriodo,aTamanho,oPrint                ���
���          �          ,lDescricao,aColDescr )                              ���
����������������������������������������������������������������������������Ĵ��
���Parametros� cVisGer    - Orcamento                                        ���
���          � cCO        - Conta Orcamentaria                               ���
���          � aPeriodo   - Datas do periodo                                 ���
���          � aTamanho   - Tamanho das colunas                              ���
���          � oPrint     - objeto TMSPrinter                                ���
���          � lDescricao - Se existe coluna de descricao na pagina atual    ���
���          � aColDescr  - Cabecalho das colunas                            ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function PCOR035CO(cVisGer, cCO, aPeriodo, aTamanho, oPrint, lDescricao, aColDescr)

Local aArea		:= GetArea()
Local aAreaTMPAK2	:= TMPAK2->(GetArea())
Local aAreaAKO	:= AKO->(GetArea())
    
	If AKO_NIVEL =="001" .OR. ;
		(AKO->AKO_CO >= mv_par03 .And. AKO->AKO_CO <= mv_par04)

		PcoPrtCol(aTamanho)
		If PcoPrtLim(nLin)
			nLin := 200
			PcoPrtCab(oPrint)
			PcoPrtCol(aTamanho)
			PCOR035TitCol( @oPrint ,aColDescr )
		EndIf
		
		If lDescricao
			PcoPrtCell(PcoPrtPos(1),nLin,,60,AKO->AKO_CO,oPrint,1,3)
			PcoPrtCell(PcoPrtPos(2),nLin,,60,AKO->AKO_NIVEL,oPrint,1,3)
			PcoPrtCell(PcoPrtPos(3),nLin,,60,SPACE((VAL(AKO->AKO_NIVEL)-1)*3)+AKO->AKO_DESCRI,oPrint,1,3)
			If AKO->AKO_CLASSE == "1"
				PcoPrtCell(PcoPrtPos(4),nLin,,60,STR0009,oPrint,1,3) //"Sintetica"
			Else
				PcoPrtCell(PcoPrtPos(4),nLin,,60,STR0010,oPrint,1,3) //"Analitica"
			EndIf
		Else
			PcoPrtCell(PcoPrtPos(1),nLin,,60,"",oPrint,1,3)
		EndIf
		nLin+= 70
		
		// itens da conta orcamentaria
		PCOR035COIt(cVisGer , cCO, aPeriodo, aTamanho, @oPrint, lDescricao, aColDescr)
	EndIf
	
	dbSelectArea("AKO")
	dbSetOrder(2)
	MsSeek(xFilial()+cVisGer+cCO)
	While !Eof() .And. AKO->AKO_FILIAL+AKO->AKO_CODIGO+AKO->AKO_COPAI==xFilial("AKO")+cVisGer+cCO
		// Conta orcamentaria
		PCOR035CO( AKO_CODIGO, AKO_CO ,	aPeriodo ,aTamanho ,@oPrint ,lDescricao ,aColDescr )
		dbSelectArea("AKO")
		dbSkip()
	End
	
	RestArea(aAreaTMPAK2)
	RestArea(aAreaAKO)
	RestArea(aArea)
	
Return( NIL )


/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOR035COIt � Autor � Reynaldo Tetsu Miyashita � Data �20-01-2004���
������������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de impressao da planilha orcamentaria da classe           ���
���          �orcamentaria.                                                    ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   �PCOR035COIt( cVisGer,cCO,aPeriodo,aTamanho,oPrint        ���
���          �            ,lDescricao ,aColDescr )                             ���
������������������������������������������������������������������������������Ĵ��
���Parametros� cVisGer    - Orcamento                                          ���
���          � cCO        - Conta Orcamentaria                                 ���
���          � aPeriodo   - Datas do periodo                                   ���
���          � aTamanho   - Tamanho das colunas                                ���
���          � oPrint     - objeto TMSPrinter                                  ���
���          � lDescricao - Se existe coluna de descricao na pagina atual      ���
���          � aColDescr  - Cabecalho das colunas                              ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
Static Function PCOR035COIt( cVisGer, cCO ,aPeriodo ,aTamanho ,oPrint ,lDescricao ,aColDescr )

Local aArea			:= GetArea()
Local aAreaTMPAK2	:= TMPAK2->(GetArea())    
Local aAuxArea 		:= {}
Local cDescricao	:= ""
Local cUM 			:= ""  
Local aClassDescr	:= {}
Local aClassTam		:= {}
Local nX 			:= 0
Local nCol 			:= 150 //200
Local lTitle
Local cDesCla       := Space(Len(AK6->AK6_DESCRI))

	If lDescricao		
		aClassDescr := {STR0011 ,STR0003 ,STR0012,"UM",STR0013 } //"Classe Orc."###"Descricao"###"Identificador"###"Operacao"
		//aClassTam	:= {200 ,370 ,1160 ,1950 ,2050 }
		aClassTam	:= {150 ,320 ,1110 ,1900 ,2000 }
		nCol := 2250
	Endif
	
	For nX := 1 To len(aPeriodo)
		aadd( aClassDescr ,DTOC(aPeriodo[nX]) )
		aAdd( aClassTam	,nCol )
		nCol+=CELLTAMDATA
	Next nX
	
	dbSelectArea("TMPAK2")
	dbSetOrder(1)
	
	If MsSeek(xFilial("AK2")+PadR(cVisGer,Len(TMPAK2->AK2_ORCAME))+cCO+DTOS(aPeriodo[1]))
        lTitle := .T.

		While TMPAK2->AK2_FILIAL+TMPAK2->AK2_ORCAME+TMPAK2->AK2_CO+DTOS(TMPAK2->AK2_PERIOD)== ;
				xFilial("AK2")+PadR(cVisGer,Len(TMPAK2->AK2_ORCAME))+cCO+DTOS(aPeriodo[1])
		
		    If (TMPAK2->AK2_CLASSE >= mv_par05 .And. TMPAK2->AK2_CLASSE <= mv_par06) .And. ;
				(TMPAK2->AK2_OPER >= mv_par07 .And. TMPAK2->AK2_OPER <= mv_par08)		    
		    
			    If lTitle
			    	PcoPrtCol( aClassTam )
					PCOR035TitCol( @oPrint ,aClassDescr )
					lTitle := .F.
	            EndIf
	            
				PcoPrtCol( aClassTam )
				If PcoPrtLim(nLin)
					nLin := 200
					PcoPrtCab(oPrint) 
					PcoPrtCol( aTamanho )			
					PCOR035TitCol( @oPrint ,aColDescr )
					PcoPrtCol( aClassTam )
					PCOR035TitCol( @oPrint ,aClassDescr )
				
				EndIf
				
				If lDescricao
					
					If !Empty(TMPAK2->AK2_CHAVE)
						aAuxArea := GetArea()
						AK6->(dbSetOrder(1))
						AK6->(dbSeek(xFilial()+TMPAK2->AK2_CLASSE))
						If !Empty(AK6->AK6_VISUAL)
							dbSelectArea(Substr(TMPAK2->AK2_CHAVE,1,3))
							dbSetOrder(Val(Substr(TMPAK2->AK2_CHAVE,4,2)))
							dbSeek(Substr(TMPAK2->AK2_CHAVE,6,Len(TMPAK2->AK2_CHAVE)))
							cDescricao := alltrim(&(AK6->AK6_VISUAL))						
							cUM := allTrim(&(AK6->AK6_UM))
						Else
							cDescricao:= ""
							cUM := ""    
						EndIf
						RestArea(aAuxArea)
						
					EndIf                 
					
					cDescCla := Posicione("AK6", 1, xFilial("AK6")+TMPAK2->AK2_CLASSE, "AK6_DESCRI")

					PcoPrtCell(PcoPrtPos(1),nLin,,60,TMPAK2->AK2_CLASSE ,oPrint,1,3)			
					PcoPrtCell(PcoPrtPos(2),nLin,,60,cDescCla,oPrint,1,3)			
					PcoPrtCell(PcoPrtPos(3),nLin,,60,cDescricao ,oPrint,1,3)			
					PcoPrtCell(PcoPrtPos(4),nLin,,60,cUM ,oPrint,1,3)
					PcoPrtCell(PcoPrtPos(5),nLin,,60,TMPAK2->AK2_OPER ,oPrint,1,3)
					PCO035ValPer(cVisGer, cCO, aPeriodo, TMPAK2->AK2_ID, @oPrint, 5 )
				Else
					PCO035ValPer(cVisGer, cCO, aPeriodo, TMPAK2->AK2_ID, @oPrint )
				Endif
				// avanco de linha
				nLin+=30
			EndIf
			TMPAK2->(dbSkip())
			
		End
		// avanco de linha
		nLin+=60
	EndIf
	RestArea(aAreaTMPAK2)
	RestArea(aArea)
	
Return( NIL ) 

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOR035TitCol � Autor � Reynaldo Tetsu Miyashita � Data �2!-01-2004���
��������������������������������������������������������������������������������Ĵ��
���Descri��o �Titulo das colunas do relatorio                                    ���
��������������������������������������������������������������������������������Ĵ��
���Sintaxe   �PCOR035TitCol( oPrint ,aColDescr )                                 ���
��������������������������������������������������������������������������������Ĵ��
���Parametros� oPrint  - objeto TMSPrinter                                       ���
���          � aColDescr  - Cabecalho das colunas                                ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Static Function PCOR035TitCol( oPrint ,aColDescr )
Local nX := 0

	For nX := 1 To len(aColDescr)
		PcoPrtCell(PcoPrtPos(nX),nLin,PcoPrtTam(nX),30,aColDescr[nX],oPrint,2,1,RGB(230,230,230))
	Next nX                       
	
	nLin+=75
	
Return( NIL )


/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    �PCO035CalcPer � Autor � Reynaldo Tetsu Miyashita � Data �21-01-2004���
��������������������������������������������������������������������������������Ĵ��
���Descri��o �Calcula as datas do periodo de acordo com o tipo de periodo        ���
��������������������������������������������������������������������������������Ĵ��
���Sintaxe   �PCO035CalcPer( nTipo ,dIniPer ,dFimPer )                           ���
��������������������������������������������������������������������������������Ĵ��
���Parametros� nTipo - Tipo do periodo a ser calculado                           ���
���          � dIniPer - Data de inicio do periodo                               ���
���          � dFimPer - Data do fim do periodo                                  ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
STATIC FUNCTION PCO035CalcPer( nTipo ,dIniPer ,dFimPer )
Local dX 		:= ctod("  / /  ")
Local dINI 		:= ctod("  / /  ")
Local aPeriodo 	:= {}

Do Case 
	// Semanal
	Case nTipo == "1"
		dIni := dIniPer
		If DOW(dIniPer)<>1
			dIni -= DOW(dIniPer)-1
		EndIf
	OtherWise
		dIni := CTOD("01/"+StrZero(MONTH(dIniPer),2,0)+"/"+StrZero(YEAR(dIniPer),4,0))
EndCase
dx := dIni
While dx < dFimPer
	aAdd( aPeriodo ,dX )
	Do Case  		
		// Semanal
		Case nTipo == "1"
			dx += 7
		// Quinzenal
		Case nTipo == "2"
			If DAY(dx) == 01
				dx	:= CTOD("15/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
			Else
				dx += 35
				dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
			EndIf
		// Mensal
		Case nTipo == "3"
			dx += 35
			dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
		// Bimestral
		Case nTipo == "4"
			dx += 62
			dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
		// Semestral
		Case nTipo == "5"
			dx += 185
			dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
		// Anual
		Case nTipo == "6"
			dx += 370
			dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
	EndCase
End

Return( aPeriodo )

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    �PCO035ValPer  � Autor � Reynaldo Tetsu Miyashita � Data �21-01-2004���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Valor da coluna data(periodo) da classe orcamentaria atual        ���
��������������������������������������������������������������������������������Ĵ��
���Sintaxe   �PCO035ValPer( cVisGer ,cCO ,aPeriodo ,cID ,oPrint ,nCol ) ���
��������������������������������������������������������������������������������Ĵ��
���Parametros� cVisGer - Orcamento                                               ���
���          � cCO     - Conta Orcamentaria                                      ���
���          � aPeriodo- array com as datas do periodo                           ���
���          � cID     - ID da atual classe Orcamentaria                         ���
���          � oPrint  - objeto TMSPrinter                                       ���
���          � nCol    - Posicao inicial da coluna                               ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
STATIC FUNCTION PCO035ValPer(cVisGer, cCO, aPeriodo, cID, oPrint, nCol)
Local nX 		:= 0
Local aAreaTMPAK2 	:= TMPAK2->(GetArea())
Local cPicture	:= ""

DEFAULT nCol 	:= 0

	dbSelectArea("TMPAK2")
		
	// varre o periodo
	For nX := 1 to len(aPeriodo)
		// busca pela tabela TMPAK2
		IF MsSeek(xFilial("AK2")+PadR(cVisGer,Len(TMPAK2->AK2_ORCAME))+cCO+DTOS(aPeriodo[nX])+cID )
			
			PcoPrtCell(PcoPrtPos(nCol+nX),nLin,,60,PcoPlanCel(TMPAK2->AK2_VALOR,TMPAK2->AK2_CLASSE,,@cPicture),oPrint,1,3,,,.T.)
			dbSelectArea("TMPAK2")
			dbSkip()
		EndIf
	Next nX
	
	RestArea( aAreaTMPAK2 )
	
Return( NIL )
