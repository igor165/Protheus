#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA301   ºAutor  ³Marcio Lopes        º Data ³  15/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz o tratamento para a geracao do arquivo SFT, que sera    º±±
±±º          ³utilizado dentro do LOJA300                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ExpL1 - Define se gera a query                              º±±
±±º          ³ExpD1 - Data Inicial                                        º±±
±±º          ³ExpD2 - Data Final                                          º±±
±±º          ³ExpA1 - Array do arquivo SD2                                º±±
±±º          ³ExpC1 - Legenda                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³BOPS  ³ Manutencao Efetuada                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³07/05/07  ³Marcio Lopes   ³125094³Gravacao do campo FT_VALCONT         ³±±
±±³30/05/07  ³Marcio Lopes   ³126785³Quando o produto tiver a Legenda "I" ³±±
±±³          ³               ³      ³Isento, o sistema não deve considerar³±±
±±³          ³               ³      ³o campo D2_PICM, pois esta em branco.³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA301( lGeraQry, dDataIni, dDataFin, aArraySD2, ;
                  cLegenda )

Local aArea		:= GetArea()			// Guarda a area atual

If lGeraQry
	LJ301SQRYD2( dDataIni, dDataFin )
Else
	If Len( aArraySD2 ) == 0
		LJ301GASD2( @aArraySD2 )
	Else
		LJ301GERSFT( aArraySD2, cLegenda )
	EndIf
EndIf
RestArea(aArea)

Return(.T.)
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ301SQRYD2ºAutor  ³Marcio Lopes        º Data ³  15/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera a query do SD2, contendo as informacoes para confrontar º±±
±±º          ³com o arquivo SF3                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ExpD1 - Data Inicial                                         º±±
±±º          ³ExpD2 - Data Final                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ301SQRYD2( dDataIni, dDataFin )

Local cQuery 						// Variavel utilizada na query
Local aStruSD2  					// Estrutura do arquivo
Local cAliasSD2 					// Alia do SD2
Local nX							// Variavel do FOR

cQuery 	  := "" 				
aStruSD2  := {}				
cAliasSD2 := "TMPSD2"		
nX		  := 0				

DbSelectArea("SD2")
DbSetOrder(3)

#IFDEF TOP
	aStruSD2 := dbStruct()
	cQuery   := "SELECT 	D2_FILIAL	, D2_PDV, D2_TES    , D2_CF	, " + ;
				 "D2_PICM	, D2_ALIQISS, D2_COD, D2_CLIENTE, D2_ORIGLAN, " + ;
				 "D2_LOJA	, D2_SERIE	, D2_DOC, D2_EMISSAO, D2_TIPO " 
	cQuery += " FROM " + RetSqlName('SD2')
	cQuery += " WHERE D2_FILIAL = '" + xFilial('SD2') + 	"' AND D2_EMISSAO >= '" + dToS(dDataIni) + "' AND D2_EMISSAO <= '" + dToS(dDataFin) + ;
															"' AND D2_PDV <> '' AND D2_ORIGLAN = 'LO' ORDER BY D2_FILIAL, D2_DOC"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cAliasSD2)
	For nX := 1 To len(aStruSD2)
		If aStruSD2[nX][2] <> "C" .And. FieldPos(aStruSD2[nX][1])<>0
			TcSetField(	cAliasSD2, aStruSD2[nX][1], aStruSD2[nX][2], aStruSD2[nX][3], ;
						aStruSD2[nX][4] )
		EndIf
	Next nX
#ENDIF

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ301GASD2ºAutor  ³Marcio Lopes        º Data ³  16/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera a array que sera utiliada para a gravacao do arquivo   º±±
±±º          ³SFT                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ301GASD2(aArraySD2)

Local cFilialSD2 := xFilial("SD2")      // Filial SD2
Local cDados	 := ""					// Guarda o registro anterior
Local nPos       := 0					// Posicao do Ascan
Local nX		 := 0					// Contador do Vetor
Local cDoc		 := ""					// Numero da nota

dbSelectArea( "TMPSD2" )

While !Eof()
	If nPos > 0
		If cDoc <> TMPSD2->D2_DOC
			AADD( aArraySD2[nPos], cFilialSD2 + TMPSD2->D2_DOC + TMPSD2->D2_SERIE + TMPSD2->D2_CLIENTE + TMPSD2->D2_LOJA )
		EndIf
	Else
		++nX
		AADD( aArraySD2, { 	LjSitTrib("TMPSD2"), DtoS(TMPSD2->D2_EMISSAO), TMPSD2->D2_PDV, Str(TMPSD2->D2_PICM, 5,2), ;
							cFilialSD2 + TMPSD2->D2_DOC + TMPSD2->D2_SERIE + TMPSD2->D2_CLIENTE + TMPSD2->D2_LOJA } )
	EndIf
	cDoc := TMPSD2->D2_DOC
	dbSkip()
	nPos := Ascan( aArraySD2, {|X| X[1] + X[2] + X[3] + X[4] == LjSitTrib("TMPSD2") + DtoS(TMPSD2->D2_EMISSAO) + TMPSD2->D2_PDV + Str(TMPSD2->D2_PICM, 5,2) } )
End

Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ301GERSFTºAutor  ³Marcio Lopes        º Data ³  16/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava as informacoes no arquivo SFT a partir do SD2          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpA1 - Array utilizada para buscar as informacoes no SD2 e  º±±
±±º          ³gravar o arquivo SFT                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ301GERSFT( aArraySD2, cLegenda )

Local nX 		 := 0								// Contator para o FOR
Local nI		 := 0								// Contador para o FOR
Local nPos       := 0								// Retorno do ASCAN
Local cFilialSD2 := xFilial("SD2")					// Guarda a filial SD2
Local nIss		 := SuperGetMV("MV_ALIQISS")   		// Retorna o valor do ISS

dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SA1")
dbSetorder(1)

dbSelectArea("SD2")
dbSetOrder(3)


If cLegenda == "I"
	nPos := Ascan( 	aArraySD2, {|X| X[1] + X[2] + X[3] == ;
					cLegenda + DtoS(SF3->F3_EMISSAO) + SF3->F3_PDV } )

Else
	nPos := Ascan( 	aArraySD2, {|X| X[1] + X[2] + X[3] + X[4] == ;
					cLegenda + DtoS(SF3->F3_EMISSAO) + SF3->F3_PDV + Str(SF3->F3_ALIQICM, 5,2) } )
EndIf
If nPos > 0
	For nI := 5 to Len(aArraySD2[nPos]) 
		dbSelectArea("SD2")
		dbSeek(aArraySD2[nPos, nI])
		While !Eof() .AND. 	aArraySD2[nPos, nI] == cFilialSD2 + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA
			If cLegenda == "I"
				Lj301GrvSFT("I", cLegenda)
			Else
				If SF3->F3_ALIQICM == SD2->D2_PICM
					Lj301GrvSFT("I", cLegenda)
				EndIf
			EndIf
			SD2->(dbSkip())
		End
	Next nI
	
	SD2->(dbSetOrder(7))
	If ChkFile("SLX")
		dbSelectArea("SLX")
		dbSetOrder(2)
		dbSeek(xFilial("SLX") + DtoS(SF3->F3_EMISSAO) + SF3->F3_PDV )
		While !Eof() .AND. SLX->LX_FILIAL == SF3->F3_FILIAL .AND. DtoS(SLX->LX_DTMOVTO) ==  DtoS(SF3->F3_EMISSAO) .AND. SLX->LX_PDV == SF3->F3_PDV
			If cLegenda == SLX->LX_LEGENDA
				Set Deleted OFF
				SD2->(DbSeek( cFilialSD2 + SLX->LX_PDV + SLX->LX_SERIE + SLX->LX_CUPOM ) )
				While !SD2->(Eof()) .AND. SD2->D2_PDV == SLX->LX_PDV .AND. SD2->D2_SERIE == SLX->LX_SERIE .AND. SD2->D2_DOC == SLX->LX_CUPOM
					Do Case
						Case cLegenda == "T"
							If SLX->LX_PRODUTO == SD2->D2_COD .AND. SLX->LX_ITEM == SD2->D2_ITEM .AND. SF3->F3_ALIQICM == SD2->D2_PICM
								Lj301GrvSFT("C", cLegenda)
							EndIf
						Case cLegenda == "F"
							If SLX->LX_PRODUTO == SD2->D2_COD .AND. SLX->LX_ITEM == SD2->D2_ITEM .AND. SF3->F3_ICMSRET == SD2->D2_ICMSRET
								Lj301GrvSFT("C", cLegenda)
							EndIf
						Case cLegenda == "S"
							If SLX->LX_PRODUTO == SD2->D2_COD .AND. SLX->LX_ITEM == SD2->D2_ITEM
								Lj301GrvSFT("C", cLegenda)
							EndIf
					OtherWise
							If SLX->LX_PRODUTO == SD2->D2_COD .AND. SLX->LX_ITEM == SD2->D2_ITEM
								Lj301GrvSFT("C", cLegenda)
							EndIf
					EndCase
					SD2->(dbSkip())
				End
				Set Deleted ON
			EndIf
			SLX->(dbSkip())
		End
	EndIf
		
EndIf
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj301GrvSFTºAutor  ³Marcio Lopes        º Data ³  16/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava as informacoes no arquivo SFT a partir do SD2          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpA1 - Array utilizada para buscar as informacoes no SD2 e  º±±
±±º          ³gravar o arquivo SFT                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj301GrvSFT( cTipoNF, cLegenda )

Reclock("SFT", .T.)
REPLACE FT_FILIAL 	WITH xFilial("SFT")
REPLACE FT_ENTRADA  WITH SF3->F3_ENTRADA
REPLACE FT_EMISSAO  WITH SF3->F3_EMISSAO
REPLACE FT_NFISCAL 	WITH SD2->D2_DOC
REPLACE FT_SERIE 	WITH SD2->D2_SERIE
REPLACE FT_CLIEFOR 	WITH SD2->D2_CLIENTE
REPLACE FT_LOJA 	WITH SD2->D2_LOJA
REPLACE FT_ESTADO 	WITH SF3->F3_ESTADO

Do Case
	Case cLegenda == "S"
		REPLACE FT_ALIQICM	WITH SuperGetMV("MV_ALIQISS")
		REPLACE FT_BASEICM	WITH SD2->D2_BASEISS
		REPLACE FT_VALICM	WITH SD2->D2_VALISS	
		REPLACE FT_TIPO		WITH "S"
	Case cLegenda == "F"
		REPLACE FT_ICMSRET	WITH SD2->D2_ICMSRET
		REPLACE FT_TIPO		WITH SD2->D2_TIPO
	Case cLegenda == "T"
		REPLACE FT_ALIQICM	WITH SD2->D2_PICM
		REPLACE FT_BASEICM	WITH SD2->D2_BASEICM
		REPLACE FT_VALICM	WITH SD2->D2_VALICM
		REPLACE FT_TIPO		WITH SD2->D2_TIPO
	Case cLegenda == "I"
		REPLACE FT_ISENICM WITH SD2->D2_TOTAL
		REPLACE FT_TIPO		WITH SD2->D2_TIPO
EndCase
If cTipoNF == "C"
	REPLACE FT_OBSERV	WITH "NF CANCELADA"
	REPLACE FT_DTCANC	WITH SLX->LX_DTMOVTO
EndIf
REPLACE FT_PDV		WITH SD2->D2_PDV
REPLACE FT_ESPECIE	WITH SF3->F3_ESPECIE
REPLACE FT_CFOP 	WITH SD2->D2_CF
REPLACE FT_PRODUTO	WITH SD2->D2_COD
REPLACE FT_ITEM		WITH SD2->D2_ITEM
REPLACE FT_CLASFIS	WITH SD2->D2_CLASFIS
REPLACE FT_SEGURO	WITH SD2->D2_SEGURO
REPLACE FT_BASEINS	WITH SD2->D2_BASEINS
REPLACE FT_ALIQINS	WITH SD2->D2_ALIQINS
REPLACE FT_VALINS	WITH SD2->D2_VALINS
REPLACE FT_QUANT	WITH SD2->D2_QUANT
REPLACE FT_TOTAL	WITH SD2->D2_TOTAL
REPLACE FT_VALCONT	WITH SD2->D2_TOTAL
REPLACE FT_PESO		WITH SD2->D2_PESO
REPLACE FT_NFORI	WITH SD2->D2_NFORI
REPLACE FT_ITEMORI	WITH SD2->D2_ITEMORI
REPLACE FT_ALIQPS3	WITH SD2->D2_ALIQPS3
REPLACE FT_SERORI	WITH SD2->D2_SERIORI
REPLACE FT_PRCUNIT	WITH SD2->D2_PRUNIT
REPLACE FT_DESCONT	WITH SD2->D2_DESC
REPLACE FT_ALIQIPI	WITH SD2->D2_IPI
REPLACE FT_ESTOQUE	WITH SD2->D2_EST
REPLACE FT_TIPOMOV	WITH "S"
If SF4->(DbSeek(xFilial("SF4") + SD2->D2_TES))
	REPLACE FT_CFOEXT 	WITH SF4->F4_CFEXT
	If SF4->(FieldPos("F4_CTIPI")) > 0
		REPLACE FT_CTIPI	WITH SF4->F4_CTIPI
	Else
		REPLACE FT_CTIPI	WITH Space(2)
	EndIf
EndIf
REPLACE FT_IDENTF3	WITH SF3->F3_IDENTFT
MsUnlock()

Return NIL
