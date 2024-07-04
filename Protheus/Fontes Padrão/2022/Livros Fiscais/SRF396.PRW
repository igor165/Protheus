#Include "Protheus.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SRF396    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 19.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Estoque da Declaracao Especial de Informacoes Relativas a   ³±±
±±³          ³Tributacao de Cigarros - DIF-Cigarros                       ³±±
±±³          ³                                                            ³±±
±±³          ³Preparacao do meio-magnetico para Importacao de:            ³±±
±±³          ³- SRF396B - Layout do Livro de Apuracao de IPI              ³±±
±±³          ³- SRF396C - Layout de Selos                                 ³±±
±±³          ³- SRF396D - Layout de Insumos                               ³±±
±±³          ³- SRF396E - Layout de Produtos Acabados                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SRF396(cLayout)

Local aCpos 	:= {"",""}
Local dDtIni	:= mv_par01
Local dDtFim	:= mv_par02
Local cAliasSD1	:= ""
Local aStruSD1	:= ""
Local cQuerySD1	:= ""
Local cIndSD1	:= ""
Local cCondSD1	:= ""
Local nIndSD1	:= 0
Local cAliasSD2	:= ""
Local aStruSD2	:= ""
Local cQuerySD2	:= ""
Local cIndSD2	:= ""
Local cCondSD2	:= ""
Local nIndSD2	:= 0
Local nX		:= 0
Local lQuery	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera o arquivo temporario conforme layout            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraTRB(cLayout)

Do Case
	Case cLayout == "B"							//Layout do Livro de Apuracao do IPI
		_aTotal[99] := .F.	
		SRF396B()
		
	Case cLayout == "C"							//Layout de Selos
		_aTotal[99] := .T.
		
	Case cLayout == "D"							//Layout de Insumos
		aCpos[1] := GetNewPar("MV_IN396D0","")	//Tabela de Insumos ( SB5 )
		If SB5->(FieldPos(aCpos[1])) > 0
			_aTotal[99] := .T.
		Endif
		
	Otherwise 		  							//Layout de Produtos Acabados
		aCpos[1] := GetNewPar("MV_SRFCD","")	//Codigo SRF ( SB5 )		
		If SB5->(FieldPos(aCpos[1])) > 0
			_aTotal[99] := .T.
		Endif
EndCase

If _aTotal[99]	//Executa o Processamento do LayOut

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica ambiente CodeBase e/ou Top                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			lQuery := .T.
		Endif
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera Saldo Iniciais dos Selos por Classe             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cLayout == "C"							//Layout de Selos
	    SldIni(lQuery,dDtIni,dDtFim)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Query/Filtro Entradas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	dbSetOrder(6)
	If lQuery
		cAliasSD1 := "SD1Top"
		aStruSD1  := SD1->(dbStruct())
		cQuerySD1 := "SELECT * "
		cQuerySD1 += "FROM "+RetSqlName("SD1")+" "
		cQuerySD1 += "WHERE D1_FILIAL='"+xFilial("SD1")+"' AND "
		cQuerySD1 += "D1_DTDIGIT >= '"+Dtos(dDtIni)+"' AND "
		cQuerySD1 += "D1_DTDIGIT <= '"+Dtos(dDtFim)+"' AND "	
		cQuerySD1 += "D_E_L_E_T_ = ' ' "
		cQuerySD1 += "ORDER BY "+SqlOrder(SD1->(IndexKey()))
	
		cQuerySD1 := ChangeQuery(cQuerySD1)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySD1),cAliasSD1)
	
		For nX := 1 To len(aStruSD1)
			If aStruSD1[nX][2] <> "C" .And. FieldPos(aStruSD1[nX][1])<>0
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSD1)	
		dbGoTop()
	Else
		cAliasSD1	:= "SD1"
	    cIndSD1		:= CriaTrab(NIL,.F.)
	    cCondSD1	:= 'D1_FILIAL=="'+xFilial("SD1")+'".And.'
	   	cCondSD1	+= 'DTOS(D1_DTDIGIT)>="'+DTOS(dDtIni)+'" .And. DTOS(D1_DTDIGIT)<="'+DTOS(dDtFim)+'" '
	    IndRegua(cAliasSD1,cIndSD1,SD1->(IndexKey()),,cCondSD1)
	    nIndSD1		:= RetIndex("SD1")
		#IFNDEF TOP
			dbSetIndex(cIndSD1+OrdBagExt())
		#ENDIF
		dbSelectArea(cAliasSD1)
	    dbSetOrder(nIndSD1+1)
	    dbGoTop()
	Endif    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Query/Filtro Saidas                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD2")
	dbSetOrder(5)
	If lQuery
		cAliasSD2 := "SD2Top"
		aStruSD2  := SD2->(dbStruct())
		cQuerySD2 := "SELECT * "
		cQuerySD2 += "FROM "+RetSqlName("SD2")+" "
		cQuerySD2 += "WHERE D2_FILIAL='"+xFilial("SD2")+"' AND "
		cQuerySD2 += "D2_EMISSAO >= '"+Dtos(dDtIni)+"' AND "
		cQuerySD2 += "D2_EMISSAO <= '"+Dtos(dDtFim)+"' AND "	
		cQuerySD2 += "D_E_L_E_T_ = ' ' "
		cQuerySD2 += "ORDER BY "+SqlOrder(SD2->(IndexKey()))
	
		cQuerySD2 := ChangeQuery(cQuerySD2)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySD2),cAliasSD2)
	
		For nX := 1 To Len(aStruSD2)
			If aStruSD2[nX][2] <> "C" .And. FieldPos(aStruSD2[nX][1])<>0
				TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSD2)	
		dbGoTop()
	Else
		cAliasSD2	:= "SD2"
	    cIndSD2		:= CriaTrab(NIL,.F.)
	    cCondSD2	:= 'D2_FILIAL=="'+xFilial("SD2")+'".And.'
	   	cCondSD2	+= 'DTOS(D2_EMISSAO)>="'+DTOS(dDtIni)+'" .And. DTOS(D2_EMISSAO)<="'+DTOS(dDtFim)+'" '
	    IndRegua(cAliasSD2,cIndSD2,SD2->(IndexKey()),,cCondSD2)
	    nIndSD2		:= RetIndex("SD2")
		#IFNDEF TOP
			dbSetIndex(cIndSD2+OrdBagExt())
		#ENDIF
		dbSelectArea(cAliasSD2)
	    dbSetOrder(nIndSD2+1)
	    dbGoTop()
	Endif    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa LayOut ( Selos, Insumos ou Acabados )       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case cLayout == "C"		//Layout de Selos
			SRF396C(cAliasSD1,cAliasSD2)
		Case cLayout == "D"		//Layout de Insumos
			SRF396D(cAliasSD1,cAliasSD2,aCpos)
		Otherwise 				//Layout de Produtos Acabados
			SRF396E(cAliasSD1,cAliasSD2,aCpos)
	EndCase

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha Query/Filtro Entradas/Saidas                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQuery
		dbSelectArea(cAliasSD1)
		dbCloseArea()
		
		dbSelectArea(cAliasSD2)
		dbCloseArea()		
	Else
	  	dbSelectArea("SD1")
		RetIndex("SD1")
		dbClearFilter()
		Ferase(cIndSD1+OrdBagExt())
		
	  	dbSelectArea("SD2")
		RetIndex("SD2")
		dbClearFilter()
		Ferase(cIndSD2+OrdBagExt())		
	EndIf
	
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SRF396B    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 11.04.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Layout do Livro de Apuracao de IPI                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SRF396B()

Local nTpApur	:= mv_par01		//Tipo de Apuracao do IPI ( 1-Normal ou 2-NCM )
Local cTRB		:= ""
Local nX		:= 0
Local cAlias	:= ""
Local cDecen	:= ""
Local aApuracao	:= {}
Local aXNcm		:= {}
Local dDtIni	:= CtoD("")
Local dDtFim	:= CtoD("")
Local aNcm		:= {	{"22011000","22090000"},;
						{"24022000","24022000"},;
						{"84291110","84295900"},;
						{"84321000","84339090"},;
						{"87011000","87060090"},;
						{"87111000","87119000"} }

If nTpApur == 1		//Normal
	For nX := 1 To 3
		cDecen	:= Str(nX,1)
		cAlias	:= "IP"+cDecen
		Do Case
			Case nX == 1
				dDtIni := StoD(StrZero(Year(dDmaInc),4)+StrZero(Month(dDmaInc),2)+"01")
				dDtFim := StoD(StrZero(Year(dDmaInc),4)+StrZero(Month(dDmaInc),2)+"10")
				Processa({||cTRB:=ResumeF3("IP",dDtIni,dDtFim,"*",.F.,.T.,0,.F.,2,"  ","ZZ",,,,.T.,cAlias,.F.,.F.)})
			Case nX == 2
				dDtIni := StoD(StrZero(Year(dDmaInc),4)+StrZero(Month(dDmaInc),2)+"11")
				dDtFim := StoD(StrZero(Year(dDmaInc),4)+StrZero(Month(dDmaInc),2)+"20")
				Processa({||cTRB:=ResumeF3("IP",dDtIni,dDtFim,"*",.F.,.T.,0,.F.,2,"  ","ZZ",,,,.T.,cAlias,.F.,.F.)})
			Case nX == 3
				dDtIni := StoD(StrZero(Year(dDmaInc),4)+StrZero(Month(dDmaInc),2)+"21")
				dDtFim := LastDay(dDmaInc)
				Processa({||cTRB:=ResumeF3("IP",dDtIni,dDtFim,"*",.F.,.T.,0,.F.,2,"  ","ZZ",,,,.T.,cAlias,.F.,.F.)})
		EndCase
		dbSelectArea(cAlias)
		dbGoTop()
		While !Eof()
			RecLock("TIP",.T.)
			TIP->DECEN		:= cDecen
			TIP->CFOP		:= (cAlias)->CFOP
			TIP->VALCONT	:= (cAlias)->VALCONT
			TIP->BASEIPI	:= (cAlias)->BASEICM
			TIP->VALIPI		:= (cAlias)->VALICM
			TIP->ISENTO		:= (cAlias)->ISENICM
			TIP->OUTROS		:= (cAlias)->OUTRICM
			MsUnlock()
			dbSkip()
		Enddo
		(cAlias)->(dbCloseArea())
		FErase(cTRB+GetDbExtension())
		FErase(cTRB+OrdBagExt())
	Next

Else	//Por NCM

	If ExistBlock("JOINCM")			// PE para inserir outros NCM's
		aXNcm := ExecBlock("JOINCM",.F.,.F.)
		If !Empty(Len(aXNcm))
			For nX := 1 To Len(aXNcm)
				AADD(aNcm,{aXNcm[nX][1],aXNcm[nX][2]})
			Next
		Endif	
	Endif
	
	For nX := 1 To 3
		aApuracao	:= {}
		cDecen		:= Str(nX,1)
		Do Case
			Case nX == 1
				dDtIni := StoD(StrZero(Year(dDmaInc),4)+StrZero(Month(dDmaInc),2)+"01")
				dDtFim := StoD(StrZero(Year(dDmaInc),4)+StrZero(Month(dDmaInc),2)+"10")
				Processa({||aApuracao:=ResumeIP(dDtIni,dDtFim,"*",1,.F.,2,"  ","ZZ",aNcm,3)})
			Case nX == 2
				dDtIni := StoD(StrZero(Year(dDmaInc),4)+StrZero(Month(dDmaInc),2)+"11")
				dDtFim := StoD(StrZero(Year(dDmaInc),4)+StrZero(Month(dDmaInc),2)+"20")
				Processa({||aApuracao:=ResumeIP(dDtIni,dDtFim,"*",1,.F.,2,"  ","ZZ",aNcm,3)})
			Case nX == 3
				dDtIni := StoD(StrZero(Year(dDmaInc),4)+StrZero(Month(dDmaInc),2)+"21")
				dDtFim := LastDay(dDmaInc)
				Processa({||aApuracao:=ResumeIP(dDtIni,dDtFim,"*",1,.F.,2,"  ","ZZ",aNcm,3)})
		EndCase
		RecLock("TIP",.T.)
		TIP->DECEN := cDecen
		If Len(aApuracao) > 0
			TIP->CFOP		:= aApuracao[1][01]
			TIP->VALCONT	:= aApuracao[1][11]
			TIP->BASEIPI	:= aApuracao[1][03]
			TIP->VALIPI		:= aApuracao[1][04]
			TIP->ISENTO		:= aApuracao[1][05]
			TIP->OUTROS		:= aApuracao[1][06]
		Endif
		MsUnlock()
	Next
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SRF396C    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 19.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Layout de Selos                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SRF396C(cAliasSD1,cAliasSD2,aCpos)

Local dDtIni		:= mv_par01
Local dDtFim		:= mv_par02
Local cDecen		:= ""
Local cCodigo		:= ""							//Codigo de Selos
Local nRecno		:= 0
Local nEstIni		:= 0
Local cAplic		:= GetNewPar("MV_IN396C0","")	//Aplicados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Adquiridas                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SFN")
dbSetOrder(2)
dbSeek(xFilial("SFN")+Dtos(dDtIni),.T.)
While !Eof() .And. SFN->FN_DATA<=dDtFim
	cDecen	:= Left(Dtos(dDtIni),6)+IIf(Day(SFN->FN_DATA)<=10,"1",IIf(Day(SFN->FN_DATA)<=20,"2","3"))
	dbSelectArea("TRB")
	cCodigo	:= StrZero(Val(SFN->FN_CLASSE),2)
	If cCodigo <> "00"
		If !dbSeek(cDecen+cCodigo)
			RecLock("TRB",.T.)
			TRB->DECEN		:= cDecen
			TRB->TIPSELO	:= cCodigo
		Else
			RecLock("TRB",.F.)
		Endif
			TRB->ADQUIR += Int(SFN->FN_QTDE)
		MsUnlock()
	Endif
	dbSelectArea("SFN")
	dbSkip()
Enddo	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Saidas                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasSD2)
While !Eof()
	If IsSelo((cAliasSD2)->D2_COD)
		cDecen	:= Left(Dtos(dDtIni),6)+IIf(Day((cAliasSD2)->D2_EMISSAO)<=10,"1",IIf(Day((cAliasSD2)->D2_EMISSAO)<=20,"2","3"))
		dbSelectArea("TRB")
		cCodigo	:= StrZero(Val(RetClasse((cAliasSD2)->D2_COD)),2)
		If cCodigo <> "00" .And. Alltrim((cAliasSD2)->D2_CF)$cAplic
			If !dbSeek(cDecen+cCodigo)
				RecLock("TRB",.T.)
				TRB->DECEN		:= cDecen
				TRB->TIPSELO	:= cCodigo
			Else
				RecLock("TRB",.F.)
			Endif
				TRB->APLIC += Int((cAliasSD2)->D2_QUANT)
			MsUnlock()
		Endif
	Endif	
	dbSelectArea(cAliasSD2)
	dbSkip()
Enddo	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Estoque Final                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGoTop()
While !Eof()
	RecLock("TRB",.F.)
    Do Case
    	Case Right(TRB->DECEN,1) == "1"
			TRB->ESTINI := RetSldIni(TRB->TIPSELO)
	    	
    	Case Right(TRB->DECEN,1) == "2"
			nRecno	:= Recno()
			cDecen 	:= Left(TRB->DECEN,6)			
			cCodigo := TRB->TIPSELO			
			If !dbSeek(cDecen+"1"+cCodigo)
				nEstIni := RetSldIni(cCodigo)
			Else
				nEstIni	:= TRB->ESTFIM
			Endif
			dbGoTo(nRecno)
			TRB->ESTINI := nEstIni			

    	Case Right(TRB->DECEN,1) == "3"
			nRecno 	:= Recno()
			cDecen 	:= Left(TRB->DECEN,6)
			cCodigo := TRB->TIPSELO
			If !dbSeek(cDecen+"2"+cCodigo)
				If !dbSeek(cDecen+"1"+cCodigo)
					nEstIni := RetSldIni(cCodigo)
				Else
					nEstIni	:= TRB->ESTFIM				
				Endif
			Else
				nEstIni	:= TRB->ESTFIM				
			Endif
			dbGoTo(nRecno)
			TRB->ESTINI := nEstIni			
	EndCase
    TRB->ESTFIM	:= (TRB->ESTINI + TRB->ADQUIR) - TRB->APLIC
	MsUnlock()
	dbSelectArea("TRB")
	dbSkip()
Enddo	

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SRF396D    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 19.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Layout de Insumos                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SRF396D(cAliasSD1,cAliasSD2,aCpos)

Local dDtIni		:= mv_par01
Local dDtFim		:= mv_par02
Local cDecen		:= ""			//Decendio
Local cCodigo		:= ""
Local cAdquir		:= GetNewPar("MV_IN396D1","")	//Adquiridos
Local cRecTrans		:= GetNewPar("MV_IN396D2","")	//Recebidos por Transferencia
Local cOutEnt		:= GetNewPar("MV_IN396D3","")	//Outras Entradas
Local cVendido		:= GetNewPar("MV_IN396D4","")	//Vendidos
Local cTransf		:= GetNewPar("MV_IN396D5","")	//Transferidos
Local cOutSai		:= GetNewPar("MV_IN396D6","")	//Outras Saidas
Local nD1_Quant		:= 0
Local nD2_Quant		:= 0
Local nTotEnt		:= 0
Local nTotSai		:= 0
Local nRecno		:= 0
Local nEstIni		:= 0
Local cProd			:= ""
Local cLoc			:= ""
Local aRetPrUt		:= {}	//Array das quantidades produzidas e utilizadas

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Entradas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasSD1)
While !Eof()
	If IsInsu((cAliasSD1)->D1_COD,aCpos[1]) .And. AtuEst((cAliasSD1)->D1_TES)
		cCodigo := StrZero(Val(RetCont((cAliasSD1)->D1_COD,aCpos[1])),3)
		If !Empty(Val(cCodigo))
			cDecen	:= Left(Dtos(dDtIni),6)+IIf(Day((cAliasSD1)->D1_DTDIGIT)<=10,"1",IIf(Day((cAliasSD1)->D1_DTDIGIT)<=20,"2","3"))
			cProd	:= (cAliasSD1)->D1_COD
			cLoc	:= (cAliasSD1)->D1_LOCAL
			dbSelectArea("TRB")
			If !dbSeek(cDecen+cCodigo)
				RecLock("TRB",.T.)
				TRB->PRODUTO	:= cProd
				TRB->LOC		:= cLoc
				TRB->DECEN		:= cDecen
				TRB->INSUMO		:= cCodigo
				TRB->NCM		:= RetNCM((cAliasSD1)->D1_COD)
				If Right(cDecen,1) == "1"
					TRB->ESTINI	:= CalcEst(cProd,cLoc,dDtIni)[1]
				Endif
			Else
				RecLock("TRB",.F.)
				If Right(cDecen,1) == "1" .And. (TRB->PRODUTO+TRB->LOC <> cProd+cLoc) .And. TRB->LIDO <> "S"
					TRB->LIDO	:= "S"
					TRB->ESTINI	+= CalcEst(cProd,cLoc,dDtIni)[1]
				Endif
			Endif
			If  (cAliasSD1)->D1_TIPO == "N"		
				nD1_Quant 		:= (cAliasSD1)->D1_QUANT
				TRB->ADQUIR		+= IIf(Alltrim((cAliasSD1)->D1_CF) $ cAdquir	,nD1_Quant,0)	//Adquiridos
				TRB->RECTRANS	+= IIf(Alltrim((cAliasSD1)->D1_CF) $ cRecTrans	,nD1_Quant,0)	//Recebidos por Transferencia
			Endif
			TRB->OUTENT		+= IIf(Alltrim((cAliasSD1)->D1_CF) $ cOutEnt	,nD1_Quant,0)	//Outras Entradas
			MsUnlock()
		Endif
	Endif	
	dbSelectArea(cAliasSD1)
	dbSkip()
Enddo	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Saidas                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasSD2)
While !Eof()
	If IsInsu((cAliasSD2)->D2_COD,aCpos[1]) .And. AtuEst((cAliasSD2)->D2_TES)
		cCodigo	:= StrZero(Val(RetCont((cAliasSD2)->D2_COD,aCpos[1])),3)
		If !Empty(Val(cCodigo))
			cDecen	:= Left(Dtos(dDtIni),6)+IIf(Day((cAliasSD2)->D2_EMISSAO)<=10,"1",IIf(Day((cAliasSD2)->D2_EMISSAO)<=20,"2","3"))
			cProd	:= (cAliasSD2)->D2_COD
			cLoc	:= (cAliasSD2)->D2_LOCAL
			dbSelectArea("TRB")
			If !dbSeek(cDecen+cCodigo)
				RecLock("TRB",.T.)
				TRB->PRODUTO	:= cProd
				TRB->LOC		:= cLoc
				TRB->DECEN		:= cDecen
				TRB->INSUMO		:= cCodigo
				TRB->NCM		:= RetNCM((cAliasSD2)->D2_COD)
				If Right(cDecen,1) == "1"
					TRB->ESTINI	:= CalcEst(cProd,cLoc,dDtIni)[1]
				Endif			
			Else
				RecLock("TRB",.F.)
				If Right(cDecen,1) == "1" .And. (TRB->PRODUTO+TRB->LOC <> cProd+cLoc) .And. TRB->LIDO <> "S"
					TRB->LIDO	:= "S"
					TRB->ESTINI	+= CalcEst(cProd,cLoc,dDtIni)[1]
				Endif							
			Endif
			If  (cAliasSD2)->D2_TIPO == "N"		
				nD2_Quant 		:= (cAliasSD2)->D2_QUANT
				TRB->VENDIDO	+= IIf(Alltrim((cAliasSD2)->D2_CF) $ cVendido 	,nD2_Quant,0)	//Vendidos
				TRB->TRANSF		+= IIf(Alltrim((cAliasSD2)->D2_CF) $ cTransf	,nD2_Quant,0)	//Transferidos
			Endif
			TRB->OUTSAI		+= IIf(Alltrim((cAliasSD2)->D2_CF) $ cOutSai	,nD2_Quant,0)	//Outras Saidas
			MsUnlock()
		Endif
	Endif	
	dbSelectArea(cAliasSD2)
	dbSkip()
Enddo	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Estoque Final                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGoTop()
While !Eof()
	RecLock("TRB",.F.)
    Do Case
    	Case Right(TRB->DECEN,1) == "2"
			nRecno	:= Recno()
			cDecen 	:= Left(TRB->DECEN,6)
			cCodigo := TRB->INSUMO			
			cProd	:= TRB->PRODUTO
			cLoc	:= TRB->LOC
			If !dbSeek(Left(cDecen,6)+"1"+cCodigo)
				nEstIni := CalcEst(cProd,cLoc,dDtIni)[1]
			Else
				nEstIni	:= TRB->ESTFIM				
			Endif
			dbGoTo(nRecno)
			TRB->ESTINI := nEstIni			

    	Case Right(TRB->DECEN,1) == "3"
			nRecno 	:= Recno()
			cDecen 	:= Left(TRB->DECEN,6)
			cCodigo := TRB->INSUMO
			cProd	:= TRB->PRODUTO
			cLoc	:= TRB->LOC
			If !dbSeek(cDecen+"2"+cCodigo)
				If !dbSeek(cDecen+"1"+cCodigo)
					nEstIni := CalcEst(cProd,cLoc,dDtIni)[1]
				Else
					nEstIni	:= TRB->ESTFIM				
				Endif
			Else
				nEstIni	:= TRB->ESTFIM				
			Endif
			dbGoTo(nRecno)			
			TRB->ESTINI := nEstIni			
	EndCase
	aRetPrUt	:= RetPrUt(TRB->PRODUTO,TRB->LOC,dDtIni,dDtFim)	//Retorna quantidade produzida/utilizada
	TRB->PRODUZ	:= aRetPrUt[1]		//Produzido
	TRB->UTILIZ	:= aRetPrUt[2]		//Utilizado
	nTotEnt 	:= (TRB->ESTINI + TRB->PRODUZ  + TRB->ADQUIR + TRB->RECTRANS + TRB->OUTENT)
	nTotSai		:= (TRB->UTILIZ + TRB->VENDIDO + TRB->TRANSF + TRB->OUTSAI)  
    TRB->ESTFIM	:= (nTotEnt - nTotSai)    		
	MsUnlock()
	dbSelectArea("TRB")
	dbSkip()
Enddo	

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SRF396E    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 19.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Layout de Produtos Acabados                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SRF396E(cAliasSD1,cAliasSD2,aCpos)

Local dDtIni		:= mv_par01
Local dDtFim		:= mv_par02
Local cDecen		:= ""
Local cCodSRF		:= ""							//Codigo SRF
Local cCodClas		:= ""							//Codigo da Classe
Local cRecTrans		:= GetNewPar("MV_IN396E0","")	//Recebidos por Transferencia
Local cDevol		:= GetNewPar("MV_IN396E1","")	//Devolvidos
Local cOutEnt		:= GetNewPar("MV_IN396E2","")	//Outras Entradas
Local cVendido		:= GetNewPar("MV_IN396E3","")	//Vendidos
Local cTransf		:= GetNewPar("MV_IN396E4","")	//Transferidos
Local cOutSai		:= GetNewPar("MV_IN396E5","")	//Outras Saidas
Local nD1_Quant		:= 0
Local nD2_Quant		:= 0
Local nTotEnt		:= 0
Local nTotSai		:= 0
Local nRecno		:= 0
Local nEstIni		:= 0
Local cProd			:= ""
Local cLoc			:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Entradas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasSD1)
While !Eof()
	If IsSelo((cAliasSD1)->D1_COD) .And. AtuEst((cAliasSD1)->D1_TES)
		cCodSRF		:= StrZero(Val(RetCont((cAliasSD1)->D1_COD,aCpos[1])),3)
		cCodClas	:= Str(Val(RetCLasse((cAliasSD1)->D1_COD)),1)
		If !Empty(Val(cCodSRF)) .And. !Empty(cCodClas)
			cDecen 	:= Left(Dtos(dDtIni),6)+IIf(Day((cAliasSD1)->D1_DTDIGIT)<=10,"1",IIf(Day((cAliasSD1)->D1_DTDIGIT)<=20,"2","3"))
			cProd	:= (cAliasSD1)->D1_COD
			cLoc	:= (cAliasSD1)->D1_LOCAL
			dbSelectArea("TRB")
			If !dbSeek(cDecen+cCodSRF+cCodClas)
				RecLock("TRB",.T.)
				TRB->PRODUTO	:= cProd
				TRB->LOC		:= cLoc
				TRB->DECEN		:= cDecen
				TRB->SRF		:= cCodSRF
				TRB->CLAS		:= cCodClas
				TRB->PRUNIT		:= (cAliasSD1)->D1_VUNIT
				If Right(cDecen,1) == "1"
					TRB->ESTINI	:= Int(CalcEst(cProd,cLoc,dDtIni)[1])
				Endif
			Else
				RecLock("TRB",.F.)
				If Right(cDecen,1) == "1" .And. (TRB->PRODUTO+TRB->LOC <> cProd+cLoc) .And. TRB->LIDO <> "S"
					TRB->LIDO	:= "S"
					TRB->ESTINI	+= Int(CalcEst(cProd,cLoc,dDtIni)[1])
				Endif
			Endif
			nD1_Quant 		:= Int((cAliasSD1)->D1_QUANT)
			TRB->RECTRANS	+= IIf(Alltrim((cAliasSD1)->D1_CF) $ cRecTrans .And. (cAliasSD1)->D1_TIPO == "N",nD1_Quant,0)	//Recebidos por Transferencia
			TRB->DEVOL		+= IIf(Alltrim((cAliasSD1)->D1_CF) $ cDevol    .And. (cAliasSD1)->D1_TIPO == "D",nD1_Quant,0)	//Devolvidos
			TRB->OUTENT		+= IIf(Alltrim((cAliasSD1)->D1_CF) $ cOutEnt   .And. (cAliasSD1)->D1_TIPO == "N",nD1_Quant,0)	//Outras Entradas
			MsUnlock()
		Endif
	Endif	
	dbSelectArea(cAliasSD1)
	dbSkip()
Enddo	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Saidas                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasSD2)
While !Eof()
	If IsSelo((cAliasSD2)->D2_COD) .And. AtuEst((cAliasSD2)->D2_TES)
		cCodSRF		:= StrZero(Val(RetCont((cAliasSD2)->D2_COD,aCpos[1])),3)
		cCodClas	:= Str(Val(RetCLasse((cAliasSD2)->D2_COD)),1)
		If !Empty(Val(cCodSRF)) .And. !Empty(cCodClas)		
			cDecen	:= Left(Dtos(dDtIni),6)+IIf(Day((cAliasSD2)->D2_EMISSAO)<=10,"1",IIf(Day((cAliasSD2)->D2_EMISSAO)<=20,"2","3"))
			cProd	:= (cAliasSD2)->D2_COD
			cLoc	:= (cAliasSD2)->D2_LOCAL
			dbSelectArea("TRB")
			If !dbSeek(cDecen+cCodSRF+cCodClas)
				RecLock("TRB",.T.)
				TRB->PRODUTO	:= cProd
				TRB->LOC		:= cLoc
				TRB->DECEN		:= cDecen
				TRB->SRF		:= cCodSRF
				TRB->CLAS		:= cCodClas
				TRB->PRUNIT		:= (cAliasSD2)->D2_PRUNIT
				If Right(cDecen,1) == "1"
					TRB->ESTINI	:= Int(CalcEst(cProd,cLoc,dDtIni)[1])
				Endif
			Else
				RecLock("TRB",.F.)
				If Right(cDecen,1) == "1" .And. (TRB->PRODUTO+TRB->LOC <> cProd+cLoc) .And. TRB->LIDO <> "S"
					TRB->LIDO	:= "S"						
					TRB->ESTINI	+= Int(CalcEst(cProd,cLoc,dDtIni)[1])
				Endif
			Endif
			If  (cAliasSD2)->D2_TIPO == "N"		
				nD2_Quant 		:= Int((cAliasSD2)->D2_QUANT)
				TRB->VENDIDO	+= IIf(Alltrim((cAliasSD2)->D2_CF) $ cVendido 	,nD2_Quant				,0)	//Vendidos
				TRB->TRANSF		+= IIf(Alltrim((cAliasSD2)->D2_CF) $ cTransf	,nD2_Quant				,0)	//Transferidos
				TRB->OUTSAI		+= IIf(Alltrim((cAliasSD2)->D2_CF) $ cOutSai	,nD2_Quant				,0)	//Outras Saidas
				TRB->TOTAL		+= IIf(Alltrim((cAliasSD2)->D2_CF) $ cVendido 	,(cAliasSD2)->D2_TOTAL	,0)	//Total Vendido
			Endif
			MsUnlock()
		Endif
	Endif	
	dbSelectArea(cAliasSD2)
	dbSkip()
Enddo	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Estoque Final por Decendio                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGoTop()
While !Eof()
	RecLock("TRB",.F.)
    Do Case
    	Case Right(TRB->DECEN,1) == "2"
			nRecno	:= Recno()
			cDecen 	:= Left(TRB->DECEN,6)
			cCodSRF := TRB->SRF
			cCodClas:= TRB->CLAS			
			cProd	:= TRB->PRODUTO
			cLoc	:= TRB->LOC
			If !dbSeek(cDecen+"1"+cCodSRF+cCodClas)
				nEstIni := Int(CalcEst(cProd,cLoc,dDtIni)[1])
			Else
				nEstIni	:= TRB->ESTFIM				
			Endif
			dbGoTo(nRecno)
			TRB->ESTINI := nEstIni			

    	Case Right(TRB->DECEN,1) == "3"
			nRecno 	:= Recno()
			cDecen 	:= Left(TRB->DECEN,6)
			cCodSRF := TRB->SRF
			cCodClas:= TRB->CLAS
			cProd	:= TRB->PRODUTO
			cLoc	:= TRB->LOC
			If !dbSeek(cDecen+"2"+cCodSRF+cCodClas)
				If !dbSeek(cDecen+"1"+cCodSRF+cCodClas)
					nEstIni := Int(CalcEst(cProd,cLoc,dDtIni)[1])
				Else
					nEstIni	:= TRB->ESTFIM				
				Endif
			Else
				nEstIni	:= TRB->ESTFIM				
			Endif
			dbGoTo(nRecno)			
			TRB->ESTINI := nEstIni			
	EndCase
	TRB->PM		:= IIf(TRB->VENDIDO == 0,TRB->PRUNIT, TRB->TOTAL / TRB->VENDIDO)	//Preco Medio
	TRB->PRODUZ	:= Int(RetPrUt(TRB->PRODUTO,TRB->LOC,dDtIni,dDtFim)[1])			//Retorna quantidade produzida
	nTotEnt 	:= (TRB->ESTINI  + TRB->PRODUZ  + TRB->RECTRANS + TRB->DEVOL + TRB->OUTENT)
	nTotSai		:= (TRB->VENDIDO + TRB->TRANSF  + TRB->OUTSAI)  
    TRB->ESTFIM	:= (nTotEnt - nTotSai)    		
	MsUnlock()
	dbSelectArea("TRB")
	dbSkip()
Enddo	

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IsSelo     ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 19.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se o Produto utiliza Selo                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IsSelo(cProduto)

Local aArea	:= GetArea()
Local lRet	:= .F.

dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+cProduto)
	If SB1->B1_SELO == "1"	//Produto utiliza Selo
		lRet := .T.
	Endif
Endif	
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IsInsu     ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 19.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se e Insumo                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IsInsu(cProduto,cCpos)

Local aArea	:= GetArea()
Local lRet	:= .F.

dbSelectArea("SB5")
dbSetOrder(1)
If dbSeek(xFilial("SB5")+cProduto)
	If !Empty(SB5->&(cCpos))
		lRet := .T.
	Endif
Endif	
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetPrUt    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 19.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna quantidade produzida/utilizada do produto ( SD3 )    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetPrUt(cProduto,cLocal,dDtIni,dDtFim)

Local aArea	:= GetArea()
Local aRet	:= {0,0}

dbSelectArea("SD3")
dbSetOrder(7)
dbSeek(xFilial("SD3")+cProduto+cLocal+Dtos(dDtIni),.T.)
While !Eof() .And. SD3->D3_FILIAL+SD3->D3_COD+SD3->D3_LOCAL==xFilial("SD3")+cProduto+cLocal .And. SD3->D3_EMISSAO<=dDtFim
	If Left(SD3->D3_CF,2)=="PR" .And. SD3->D3_ESTORNO<>"S"
		aRet[1] += SD3->D3_QUANT	//Produzida
	Endif
	If Left(SD3->D3_CF,2)=="RE"
		aRet[2] += SD3->D3_QUANT	//Utilizada
	Endif
	dbSkip()
Enddo	
RestArea(aArea)

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetClasse  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 19.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a Classe do Selo do Produto                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetClasse(cProduto)

Local aArea	:= GetArea()
Local cRet	:= ""

dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+cProduto)
	cRet := SB1->B1_CLASSE
Endif	
RestArea(aArea)

Return(cRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetCont    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 19.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o conteudo do campo do SB5                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetCont(cProduto,cCpos)

Local aArea	:= GetArea()
Local cRet	:= ""

dbSelectArea("SB5")
dbSetOrder(1)
If dbSeek(xFilial("SB5")+cProduto)
	cRet := SB5->&(cCpos)
Endif	
RestArea(aArea)

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetNCM     ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 19.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o NCM do Produto                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetNCM(cProduto)

Local aArea	:= GetArea()
Local cRet	:= ""

dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+cProduto)
	cRet := StrZero(Val(SB1->B1_POSIPI),8)
Endif	
RestArea(aArea)

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³AtuEst     ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 19.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se a TES atualiza Estoque                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtuEst(cTES)

Local aArea	:= GetArea()
Local lRet	:= .F.

dbSelectArea("SF4")
dbSetOrder(1)
If dbSeek(xFilial("SF4")+cTES)
	If SF4->F4_ESTOQUE == "S"	//Atualiza Estoque
		lRet := .T.
	Endif
Endif	
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTRB    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 19.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios conforme LayOut                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTRB(cLayOut)

Local aStru	:= {}
Local cArq	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Saldos Iniciais do Selo                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru,{"CLASSE"	,"C",003,0})	//Classe do Selo
AADD(aStru,{"QTDE"		,"N",012,0})	//Quantidade Inicial

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"SLD")
IndRegua("SLD",cArq,"CLASSE") 

aStru	:= {}
cArq	:= ""

Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ LayOut do Livro Apuracao de IPI                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cLayOut == "B"
		AADD(aStru,{"DECEN"		,"C",001,0})	
		AADD(aStru,{"CFOP"		,"C",004,0})
		AADD(aStru,{"VALCONT"	,"N",012,2})
		AADD(aStru,{"BASEIPI"	,"N",012,2})
		AADD(aStru,{"VALIPI"	,"N",012,2})
		AADD(aStru,{"ISENTO"	,"N",012,2})
		AADD(aStru,{"OUTROS"	,"N",012,2})

		cArq := CriaTrab(aStru)
		dbUseArea(.T.,__LocalDriver,cArq,"TIP")
		IndRegua("TIP",cArq,"DECEN")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ LayOut Selos                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cLayOut == "C"
		AADD(aStru,{"DECEN"		,"C",007,0})	//Decendio
		AADD(aStru,{"TIPSELO"	,"C",002,0})	//Tipo de Selo de Controle
		AADD(aStru,{"ESTINI"	,"N",010,0})	//Estoque Inicial
		AADD(aStru,{"ADQUIR"	,"N",014,0})	//Adquiridos
		AADD(aStru,{"RECTRANS"	,"N",010,0})	//Recebidos por Transferencia
		AADD(aStru,{"OUTENT"	,"N",010,0})	//Outras Entradas
		AADD(aStru,{"APLIC"		,"N",010,0})	//Aplicados
		AADD(aStru,{"INUTIL"	,"N",010,0})	//Inutilizados
		AADD(aStru,{"TRANSF"	,"N",010,0})	//Transferidos
		AADD(aStru,{"DEVOL"		,"N",010,0})	//Devolvidos
		AADD(aStru,{"APREEND"	,"N",010,0})	//Apreendidos
		AADD(aStru,{"OUTSAI"	,"N",010,0})	//Outras Saidas
		AADD(aStru,{"ESTFIM"	,"N",010,0})	//Estoque Final
		
		cArq := CriaTrab(aStru)
		dbUseArea(.T.,__LocalDriver,cArq,"TRB")
		IndRegua("TRB",cArq,"DECEN+TIPSELO")
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ LayOut Insumos                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cLayOut == "D"	
		AADD(aStru,{"PRODUTO"	,"C",015,0})	//Produto
		AADD(aStru,{"LOC"		,"C",002,0})	//Local de Deposito
		AADD(aStru,{"DECEN"		,"C",007,0})	//Decendio
		AADD(aStru,{"INSUMO"	,"C",003,0})	//Codigo de Insumos (Anexo B do LayOut)
		AADD(aStru,{"NCM"		,"C",008,0})	//Codigo NCM (Anexo B do LayOut)
		AADD(aStru,{"ESTINI"	,"N",015,3})	//Estoque Inicial
		AADD(aStru,{"PRODUZ"	,"N",013,3})	//Produzidos
		AADD(aStru,{"ADQUIR"	,"N",013,3})	//Adquiridos
		AADD(aStru,{"RECTRANS"	,"N",013,3})	//Recebidos por Transferencia
		AADD(aStru,{"OUTENT"	,"N",013,3})	//Outras Entradas
		AADD(aStru,{"UTILIZ"	,"N",013,3})	//Utilizados
		AADD(aStru,{"INUTIL"	,"N",013,3})	//Inutilizados
		AADD(aStru,{"VENDIDO"	,"N",013,3})	//Vendidos
		AADD(aStru,{"TRANSF"	,"N",013,3})	//Transferidos para outro Estabelecimento
		AADD(aStru,{"OUTSAI"	,"N",013,3})	//Outras Saidas
		AADD(aStru,{"ESTFIM"	,"N",015,3})	//Estoque Final
		AADD(aStru,{"LIDO"		,"C",001,0})	//Flag de Registro Lido
		
		cArq := CriaTrab(aStru)
		dbUseArea(.T.,__LocalDriver,cArq,"TRB")
		IndRegua("TRB",cArq,"DECEN+INSUMO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ LayOut Produtos Acabados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cLayOut == "E"	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tabela de Entrada/Saida                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aStru,{"PRODUTO"	,"C",015,0})	//Produto
		AADD(aStru,{"LOC"		,"C",002,0})	//Local de Deposito
		AADD(aStru,{"DECEN"		,"C",007,0})	//Decendio
		AADD(aStru,{"SRF"		,"C",003,0})	//Codigo SRF
		AADD(aStru,{"CLAS"		,"C",001,0})	//Codigo de Classe ( Anexo C )
		AADD(aStru,{"ESTINI"	,"N",010,0})	//Estoque Inicial
		AADD(aStru,{"PM"		,"N",005,2})	//Preco Medio
		AADD(aStru,{"PRODUZ"	,"N",010,0})	//Produzidos
		AADD(aStru,{"RECTRANS"	,"N",010,0})	//Recebidos por Transferencia
		AADD(aStru,{"DEVOL"		,"N",010,0})	//Devolvidos
		AADD(aStru,{"OUTENT"	,"N",010,0})	//Outras Entradas
		AADD(aStru,{"VENDIDO"	,"N",010,0})	//Vendidos
		AADD(aStru,{"APREEND"	,"N",010,0})	//Apreendidos
		AADD(aStru,{"INUTIL"	,"N",010,0})	//Inutilizados
		AADD(aStru,{"TRANSF"	,"N",010,0})	//Transferidos para outro Estabelecimento
		AADD(aStru,{"OUTSAI"	,"N",010,0})	//Outras Saidas
		AADD(aStru,{"ESTFIM"	,"N",010,0})	//Estoque Final
		AADD(aStru,{"PRUNIT"	,"N",015,2})	//Preco Unitario
		AADD(aStru,{"TOTAL"		,"N",015,2})	//Total Vendido
		AADD(aStru,{"LIDO"		,"C",001,0})	//Flag de Registro Lido
						
		cArq := CriaTrab(aStru)
		dbUseArea(.T.,__LocalDriver,cArq,"TRB")
		IndRegua("TRB",cArq,"DECEN+SRF+CLAS")
EndCase

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetSldIni  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 19.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o Saldo Inicial da Classe de Selo                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetSldIni(cClasse)

Local aArea	:= GetArea()
Local nRet	:= 0
Local cSeek	:= StrZero(Val(cClasse),3)

dbSelectArea("SLD")
If dbSeek(cSeek)
	nRet := SLD->QTDE
Endif

RestArea(aArea)
Return(nRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SldIni     ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 19.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera Saldos Iniciais dos Selos por Classe                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SldIni(lQuery,dDtIni,dDtFim)

Local cAlias	:= "SD2"
Local aStru		:= {}
Local cQuery	:= ""
Local nX		:= 0
Local cSeek		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Entradas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SFN")
dbSetOrder(2)
If dbSeek(xFilial("SFN"))
	While !Eof() .And. SFN->FN_FILIAL==xFilial("SFN") .And. SFN->FN_DATA < dDtIni
		dbSelectArea("SLD")		//Saldo Inicial
		dbSetOrder(1)
		cSeek := StrZero(Val(SFN->FN_CLASSE),3)
		If !dbSeek(cSeek)
			RecLock("SLD",.T.)
			SLD->CLASSE := cSeek
		Else
			RecLock("SLD",.F.)
		Endif
		SLD->QTDE += Int(SFN->FN_QTDE)	//Qtde. Inicial
		MsUnlock()
		dbSelectArea("SFN")
		dbSkip()
	Enddo	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Saidas                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD2")
dbSetOrder(5)
If lQuery
	cAlias	:= "SD2Top"
	aStru 	:= SD2->(dbStruct())
	cQuery	:= "SELECT D2_FILIAL, D2_EMISSAO, D2_COD, D2_QUANT "
	cQuery 	+= "FROM "+RetSqlName("SD2")+" "
	cQuery  += "WHERE D2_FILIAL='"+xFilial("SD2")+"' AND "
	cQuery 	+= "D2_EMISSAO < '"+Dtos(dDtIni)+"' AND "
	cQuery  += "D_E_L_E_T_ = ' ' "
	cQuery  += "ORDER BY "+SqlOrder(SD2->(IndexKey()))

	cQuery 	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	For nX := 1 To Len(aStru)
	If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
		  TcSetField(cAlias,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
	EndIf
	Next nX
	dbSelectArea(cAlias)
Else
	(cAlias)->(dbSeek(xFilial("SD2"),.T.))
Endif

While (cAlias)->(!Eof()) .And. xFilial("SD2")==(cAlias)->D2_FILIAL .And. (cAlias)->D2_EMISSAO < dDtIni
	If SB1->(dbSeek(xFilial("SB1")+(cAlias)->D2_COD))
		If SB1->B1_SELO=="1"
			cSeek := StrZero(Val(SB1->B1_CLASSE),3)
			If SLD->(dbseek(cSeek))
				RecLock("SLD",.F.)
				SLD->QTDE -= Int((cAlias)->D2_QUANT)
				MsUnlock()
			Endif
		Endif
	Endif
	(cAlias)->(dbSkip())
Enddo

If lQuery
	dbSelectArea(cAlias)
	dbCloseArea()
Endif

Return Nil
