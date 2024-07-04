/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³RetConj     ³ Autor ³ Luciana Pires        ³ Data ³ 11.09.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³Retorna o valor bruto da nota caso seja conjugada              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³dData    - Data da entrada da nota                             ³±±
±±³           ³cNFiscal - Numero da nota fiscal                               ³±±
±±³           ³cSerie   - Serie  da nota fiscal                               ³±±
±±³           ³cClieFor - Cli/For da nota fiscal                              ³±±
±±³           ³cLoja    - Loja do Cli/For da nota fiscal                      ³±±
±±³           ³cTipo    - Entrada / Saida                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RetConj(dData, cNFiscal, cSerie, cClieFor, cLoja, cTipo)
Local aArea			:= GetArea()
Local cAlias      	:= "SFT"
Local cIndex      	:= ""
Local cQuery		:= ""
Local lQuery      	:= .F.
Local lConjugada	:= .F.
Local nValBrut		:= 0   

#IFDEF TOP
	Local nX          := 0
	Local aStruSFT    := {}
#ELSE
	Local cChave	:= ""
#ENDIF


DbSelectArea("SFT")
SFT->(DbSetOrder(2))
ProcRegua(LastRec())

#IFDEF TOP
	If ( TcSrvType()!="AS/400" )
		lQuery := .T.
		cAlias := "FT_DSGRAM"
		aStru  := SFT->(dbStruct())
		cQuery := "SELECT SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_TIPO "
		cQuery += "FROM "+RetSqlName("SFT")+" SFT "
		cQuery += "WHERE SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
		cQuery +=       "SFT.FT_ENTRADA='"+DTOS(dData)+"' AND "
		cQuery +=       "SFT.FT_NFISCAL='"+cNfiscal+"' AND "
		cQuery +=       "SFT.FT_SERIE='"+cSerie+"' AND "
		cQuery +=       "SFT.FT_CLIEFOR='"+cClieFor+"' AND "
		cQuery +=       "SFT.FT_LOJA='"+cLoja+"' AND "
		cQuery +=       "SFT.FT_TIPOMOV='"+cTipo+"'  "
		cQuery += "ORDER BY "+SqlOrder("FT_FILIAL+FT_TIPOMOV+DTOS(FT_ENTRADA)+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA")
		cQuery	:= ChangeQuery(cQuery)                       			
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)   
		
		For nX := 1 To len(aStruSFT)
			If aStruSFT[nX][2] <> "C" .And. FieldPos(aStruSFT[nX][1])<>0
				TcSetField(cAlias,aStruSFT[nX][1],aStruSFT[nX][2],aStruSFT[nX][3],aStruSFT[nX][4])
			EndIf                                                               		
		Next nX
		dbSelectArea(cAlias)	
	Else
#ENDIF

	cIndex := CriaTrab(NIL,.F.)  
    cChave :=	IndexKey()
	cQuery := "FT_FILIAL='"+xFilial("SFT")+"' .AND. "
	cQuery += "DTOS(FT_ENTRADA)=='"+DTOS(dData)+"' .AND. "
	cQuery += "FT_NFISCAL=='"+cNFiscal+"' .AND. "
	cQuery += "FT_SERIE=='"+cSerie+"' .AND. "
	cQuery += "FT_CLIEFOR=='"+cClieFor+"' .AND. "
	cQuery += "FT_LOJA=='"+cLoja+"' .AND. "
	cQuery += "FT_TIPOMOV=='"+cTipo+"'  "	

    IndRegua(cAlias,cIndex,cChave,,cQuery)
    nIndex := RetIndex(cAlias)
		
	#IFNDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
	#ENDIF    
	dbSelectArea("SFT")
    dbSetOrder(nIndex+1)
    dbSelectArea(cAlias)
    ProcRegua(LastRec())
   	dbGoTop()
#IFDEF TOP
	Endif                                           
#ENDIF

Do While !(cAlias)->(Eof())
    
	If (cAlias)->FT_TIPO<>"S" 	// Se achar com esta chave o tipo igual a "N" é uma Nota Fiscal conjugada, pois no ini a query
		lConjugada := .T.		// eh somente por Notas tipo "S" - Servico.
            
		If cTipo == "S"
			DbSelectArea("SF2")
			SF2->(DbSetOrder(1))
				                
			If SF2->(dbSeek(xFilial("SF2")+(cAlias)->FT_NFISCAL+(cAlias)->FT_SERIE+(cAlias)->FT_CLIEFOR+(cAlias)->FT_LOJA))
				nValBrut := SF2->F2_VALBRUT
			Endif
		Else
			DbSelectArea("SF1")
			SF1->(DbSetOrder(1))
				                
			If SF1->(dbSeek(xFilial("SF1")+(cAlias)->FT_NFISCAL+(cAlias)->FT_SERIE+(cAlias)->FT_CLIEFOR+(cAlias)->FT_LOJA))
				nValBrut := SF1->F1_VALBRUT
			Endif			
		Endif
	Endif		 	
	
	If lConjugada				// Se já descobri que é conjugada nao preciso mais verificar.
		Exit
	EndIf
	(cAlias)->(dbSkip())		
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui area de trabalho utilizada - SFT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lQuery
	RetIndex("SFT")	
	dbClearFilter()	
	Ferase(cIndex+OrdBagExt())
Else
	dbSelectArea(cAlias)
	dbCloseArea()
Endif
    
RestArea (aArea)

Return(nValBrut)
