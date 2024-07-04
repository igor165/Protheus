#include "RwMake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "CTBR460.ch"

#define PIX_DIF_COLUNA_VALORES			130		// Pixel inicial para impressao dos tracos das colunas dinamicas
#define PIX_INICIAL_VALORES				470		// Pixel para impressao do traco vertical
#define PIX_EQUIVALENTE					340		// Pixel inicial para impressao das colunas dinamicas

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBR460   º Autor ³ Totvs              º Data ³  06/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Livro Diario Simplificado - Peru                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CTBR460                                                     º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³26/06/15³PCREQ-4256³Se elimina la funcion AjustaSx1() la  ³±±
±±³            ³        ³          ³cual realiza modificacion a SX1 por   ³±±
±±³            ³        ³          ³motivo de adecuacion a fuentes a nueva³±±
±±³            ³        ³          ³estructura de SX para Version 12.     ³±±
±±³Jonathan Glz³09/10/15³PCREQ-4261³Merge v12.1.8                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBR460()

Local cPerg		:= "CTR460"
Local olReport


/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ mv_par01 - Data inicial?  - Data inicial dos livros fiscais      ³
³ mv_par02 - Data Final? - Data final dos livros fiscais           ³
³ mv_par03 - Seleciona filiais? - Filiais para considerar no filtro³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
If FindFunction("TRepInUse") .And. TRepInUse()
	Pergunte(cPerg,.F.)

	olReport := CTBRelat(cPerg)
	olReport:SetParam(cPerg)
	olReport:PrintDialog()
EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBRelat  ³ Autor ³ Totvs                 ³ Data | 06/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Criação do objeto TReport para a impressão do relatorio.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBRelat( cPerg )           				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Perguntas dos parametros                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBRelat( cPerg )

Local clNomProg		:= FunName()
Local clTitulo 		:= STR0001 //"Livro Diario Simplificado"
Local clDesc   		:= STR0001 //"Livro Diario Simplificado"
Local olReport

olReport:=TReport():New(clNomProg,clTitulo,cPerg,{|olReport| CTBProc(olReport)},clDesc)
olReport:SetLandscape()					// Formato paisagem
olReport:oPage:nPaperSize	:= 8 		// Impressão em papel A3
olReport:lHeaderVisible 	:= .F. 		// Não imprime cabeçalho do protheus
olReport:lFooterVisible 	:= .F.		// Não imprime rodapé do protheus
olReport:lParamPage			:= .F.		// Não imprime pagina de parametros

Return olReport

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBProc   ³ Autor ³ Totvs                 ³ Data | 06/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressão do relatorio.								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBProc( ExpC1 )         				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Objeto tReport                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBProc( olReport )

Local nReg			:= 0 //Quantidade de registros impressos
Local nPag			:= 0 //Quantidade de paginas por pagina
Local nCol			:= 0
Local clSql			:= ""

Local aCnts			:= {}
Local aCntsAtivo 	:= { "10", "12", "16", "20", "21", "33", "34", "38", "39" }
Local aCntsPassivo 	:= { "4011", "4017", "402", "42", "46" }
Local aCntsPatrim 	:= { "50", "58", "59" }
Local aCntsGasto 	:= { "60", "61", "62", "63", "65", "66", "67", "68", "69", "96", "97" }
Local aCntsIngress 	:= { "70", "75", "76", "77", "79" }
Local aCntsEspecif	:= { "4011", "4017", "402" }
Local aEquivale 	:= { "10", "12", "16", "20", "21", "33", "34", "38", "39",;
						 "4011", "4017", "402", "42", "46", "50", "58", "59",;
						 "60", "61", "62", "63", "65", "66", "67", "68", "69",;
						 "96", "97", "70", "75", "76", "77", "79" }

Local nTotalCols	:= Len( aEquivale )
Local aValores	 	:= Array( nTotalCols )
Local aTotais		:= Array( nTotalCols )

Local nInc			:= 0 
Local nPos			:= 0
Local nPosEquiv		:= 0
Local nCnts			:= 0 
Local cStrCnts		:= ""
Local cStrFil		:= ""
Local oFont 		:= TFont():New( "Courier New",, -06 )
Local aVert			:= { 5, 130, 250, PIX_INICIAL_VALORES }
Local nIniDin		:= PIX_INICIAL_VALORES					// Pixel redimencionado dinamicamente
Local nLimitrofe	:= 4850
Local nLinHist 		:= 1 
Local aHistorico	:= {}
Local aSelFil		:= {}
Local nRowStart		:= 0

// Se aFil nao foi enviada, exibe tela para selecao das filiais
If MV_PAR03 == 1
	aSelFil := AdmGetFil()

	If Len( aSelFil ) <= 0
		Return
	EndIf 
EndIf

// Inicia o array totalizador com zero
aFill( aTotais, 0 )

// Gera um string com as contas para selecao na query
aAdd( aCnts, aCntsAtivo   )
aAdd( aCnts, aCntsPassivo )
aAdd( aCnts, aCntsPatrim  )
aAdd( aCnts, aCntsGasto   )
aAdd( aCnts, aCntsIngress )
For nInc := 1 To Len( aCnts )
	For nCnts := 1 To Len( aCnts[nInc] )
		cStrCnts += "'" + aCnts[nInc][nCnts] + "'"
		
		If nInc < Len( aCnts ) .OR. ( nInc == Len( aCnts ) .and. nCnts < Len( aCnts[nInc] ) )
			cStrCnts += ", "
		EndIf
	Next
Next

//Query para trazer o saldo das contas
clSql := "SELECT CT2_NODIA, CT2_DATA, CT2_HIST, CT2_DC, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_MOEDLC, CT2_DOC, CT2_LINHA, CT2.R_E_C_N_O_ " 
clSql += "FROM " + RetSqlName( "CT2" ) + " CT2"
clSql += "WHERE CT2_DATA >= '" + DtoS( MV_PAR01 ) + "' AND "
clSql += "CT2_DATA <= '" + DtoS( MV_PAR02 ) + "' AND "
clSql += "CT2_MOEDLC = '01' AND "
clSql += "CT2_TPSALD = '1' AND "
clSql += "CT2_DC <= '3' AND "

// Filtro de filiais
If MV_PAR03 == 1
	For nInc := 1 To Len( aSelFil )
		cStrFil += "'" + aSelFil[nInc] + "'"

		If nInc < Len( aSelFil )
			cStrFil += ", "
		EndIf
	Next

	clSql += "CT2_FILIAL IN ( " + cStrFil + " ) AND "
Else
	clSql += "CT2_FILIAL = '" + xFilial( "CT2" ) + "' AND "
EndIf

clSql += "( ( substring( CT2_DEBITO, 1, 2 ) IN ( " + cStrCnts + " ) OR "
For nInc := 1 To Len( aCntsEspecif )
	clSql += " substring( CT2_DEBITO, 1, " + Trim( Str( Len( aCntsEspecif[nInc] ) ) ) + " ) = '" + aCntsEspecif[nInc]
	
	If nInc < Len( aCntsEspecif )
		clSql += "' OR "
	EndIf
Next
clSql += "' ) OR "

clSql += "( substring( CT2_CREDIT, 1, 2 ) IN ( " + cStrCnts + " ) OR "
For nInc := 1 To Len( aCntsEspecif )
	clSql += " substring( CT2_CREDIT, 1, " + Trim( Str( Len( aCntsEspecif[nInc] ) ) ) + " ) = '" + aCntsEspecif[nInc]

	If nInc < Len( aCntsEspecif )
		clSql += "' OR "
	EndIf
Next
clSql += "' ) ) AND "

If TcSrvType() == "AS/400"
	clSql += " @DELETED@ <> '*' "
Else
	clSql += " CT2.D_E_L_E_T_ <> '*' "
Endif

clSql := ChangeQuery( clSql  )
dbUseArea( .T., "TOPCONN", TcGenQry( ,, clSql ), "PER",.T.,.T.)

TCSetField( "PER", "CT2_DATA",   "D", 08, 0 )
TCSetField( "PER", "CT2_VALOR",  "N", TamSX3( "CT2_VALOR" )[1], TamSX3( "CT2_VALOR" )[2] )

DbSelectArea( "PER" )
PER->( DbGoTop() )
If PER->( !Eof() )
	FCabR460( olReport, nCol, aCntsAtivo, aCntsPassivo, aCntsPatrim, aCntsGasto, aCntsIngress ) //Impressão do cabeçalho
EndIf

// Determina o pixel vertical inicial
nRowStart		:= olReport:Row()

PER->(dbGoTop())
olReport:SetMeter( RecCount() )

While PER->(!Eof())
	If olReport:Cancel()
		Exit
	EndIf

	If PER->CT2_DC == "1"
		nPosEquiv 	:= PIX_EQUIVALENTE
		nPos 		:= aScan( aEquivale, { |x| x == PER->CT2_DEBITO .OR. x == substr( PER->CT2_DEBITO, 1, 2 ) })
		aVert		:= { 5, 130, 250, PIX_INICIAL_VALORES }
		If nPos > 0
			nPosEquiv += PIX_DIF_COLUNA_VALORES * nPos
	
			olReport:Say( olReport:Row(), olReport:Col()+0010, PER->CT2_NODIA, 					oFont )
			olReport:Say( olReport:Row(), olReport:Col()+0130, DtoC(PER->CT2_DATA), 				oFont )
			olReport:Say( olReport:Row(), nPosEquiv, Transform(PER->CT2_VALOR,"@E 999999999.99"),	oFont )

			// Imprime o historico
			aHistorico := FR460Hist( PER->CT2_HIST )
			For nLinHist := 1 To Len( aHistorico )
				olReport:Say( olReport:Row(), olReport:Col()+0250, aHistorico[nLinHist], 			oFont )

				nIniDin	:= PIX_INICIAL_VALORES
				For nInc := 1 To Len( aTotais )
					nIniDin += PIX_DIF_COLUNA_VALORES
					aAdd( aVert, nIniDin )
				Next
	
				nLimitrofe := nIniDin
				olReport:Box(olReport:Row()+2,olReport:Col()-004, olReport:Row()+2, nLimitrofe )
				
				FR460Prnt( olReport, aVert )														// Imprime a linhas verticais e passa para proxima linha
				olReport:SkipLine( 1 )
			Next

			// Ajusta os totalizadores
			aTotais[nPos] += PER->CT2_VALOR
		EndIf
	ElseIf PER->CT2_DC == "2"
		nPosEquiv 	:= PIX_EQUIVALENTE
		nPos 		:= aScan( aEquivale, { |x| x == PER->CT2_CREDIT .OR. x == substr( PER->CT2_CREDIT, 1, 2 ) })
		aVert		:= { 5, 130, 250, PIX_INICIAL_VALORES }
		If nPos > 0
			nPosEquiv += PIX_DIF_COLUNA_VALORES * nPos

			olReport:Say( olReport:Row(), olReport:Col()+0010, PER->CT2_NODIA, 					oFont )
			olReport:Say( olReport:Row(), olReport:Col()+0130, DtoC(PER->CT2_DATA), 				oFont )
			olReport:Say( olReport:Row(), nPosEquiv, Transform(PER->CT2_VALOR,"@E 999999999.99"), 	oFont )

			// Imprime o historico
			aHistorico := FR460Hist( PER->CT2_HIST )
			For nLinHist := 1 To Len( aHistorico )
				olReport:Say( olReport:Row(), olReport:Col()+0250, aHistorico[nLinHist], 			oFont )

				nIniDin	:= PIX_INICIAL_VALORES
				For nInc := 1 To Len( aTotais )
					nIniDin += PIX_DIF_COLUNA_VALORES
					aAdd( aVert, nIniDin )
				Next

				nLimitrofe := nIniDin
				olReport:Box(olReport:Row()+2,olReport:Col()-004, olReport:Row()+2, nLimitrofe )

				FR460Prnt( olReport, aVert )														// Imprime a linhas verticais e passa para proxima linha
				olReport:SkipLine( 1 )
			Next

			// Ajusta os totalizadores
			aTotais[nPos] += PER->CT2_VALOR
		EndIf
	Else
		// PARTIDA DOBRADA - Credito
		nLimitrofe := nIniDin
		olReport:Box(olReport:Row()+2,olReport:Col()-004, olReport:Row()+2, nLimitrofe )

		nPosEquiv 	:= PIX_EQUIVALENTE
		nPos 		:= aScan( aEquivale, { |x| x == PER->CT2_CREDIT .OR. x == substr( PER->CT2_CREDIT, 1, 2 ) })
		aVert		:= { 5, 130, 250, PIX_INICIAL_VALORES }
		If nPos > 0
			nPosEquiv += PIX_DIF_COLUNA_VALORES * nPos

			olReport:Say( olReport:Row(), olReport:Col()+0010, PER->CT2_NODIA, 					oFont )
			olReport:Say( olReport:Row(), olReport:Col()+0130, DtoC(PER->CT2_DATA), 				oFont )
			olReport:Say( olReport:Row(), nPosEquiv, Transform(PER->CT2_VALOR,"@E 999999999.99"), 	oFont )

			// Ajusta os totalizadores
			aTotais[nPos] += PER->CT2_VALOR
		EndIf

		// Debito
		nPosEquiv 	:= PIX_EQUIVALENTE
		nPos 		:= aScan( aEquivale, { |x| x == PER->CT2_DEBITO .OR. x == substr( PER->CT2_DEBITO, 1, 2 ) })
		aVert		:= { 5, 130, 250, PIX_INICIAL_VALORES }
		If nPos > 0
			nPosEquiv += PIX_DIF_COLUNA_VALORES * nPos

			olReport:Say( olReport:Row(), olReport:Col()+0010, PER->CT2_NODIA, 		oFont )
			olReport:Say( olReport:Row(), olReport:Col()+0130, DtoC(PER->CT2_DATA), 	oFont )
			olReport:Say( olReport:Row(), nPosEquiv, Transform(PER->CT2_VALOR,"@E 999999999.99"), 	oFont )

			// Ajusta os totalizadores
			aTotais[nPos] += PER->CT2_VALOR
		EndIf

		// Imprime o historico
		aHistorico := FR460Hist( PER->CT2_HIST )
		For nLinHist := 1 To Len( aHistorico )
			olReport:Say( olReport:Row(), olReport:Col()+0250, aHistorico[nLinHist], 				oFont )

			nIniDin	:= PIX_INICIAL_VALORES
			For nInc := 1 To Len( aTotais )
				nIniDin += PIX_DIF_COLUNA_VALORES
				aAdd( aVert, nIniDin )
			Next

			FR460Prnt( olReport, aVert )														// Imprime a linhas verticais e passa para proxima linha
			olReport:SkipLine( 1 )
		Next
	EndIf

	olReport:OnPageBreak( { || FCabR460( olReport, nCol, aCntsAtivo, aCntsPassivo, aCntsPatrim, aCntsGasto, aCntsIngress ) } )
	If nPag > 80
		If nReg > 0
			FTotR460( olReport, nCol, aTotais )
		EndIf
		
		olReport:EndPage()
		nPag := 0
		olReport:setRow( nRowStart )
	EndIf

	DbSelectArea("PER")
	PER->( DbSkip() )
	
	olReport:IncMeter()

	nPag++				// Quantidade de registros por pagina
	nReg++				// Quantidade de registros impressos
End

If nReg > 0
	FTotR460( olReport, nCol, aTotais )
EndIf

If MV_PAR04 == 1 .And. MV_PAR05 == 1
	GerArq(AllTrim(MV_PAR08))
	GerArqL4(AllTrim(MV_PAR08))
ElseIf MV_PAR04 == 1
	GerArq(AllTrim(MV_PAR08))
EndIF

PER->( DbCLoseArea() )

Return olReport

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FCabR460  ³ Autor ³ Totvs                 ³ Data | 06/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cabeçalho do relatorio.								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FCabR460(Expo1,ExpN1,ExpA1)  				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 = Objeto tReport                                      ³±±
±±³          ³ExpN1 = Posição da coluna de impressão                      ³±±
±±³          ³ExpA1 = Array com as contas do ativo                        ³±±
±±³          ³ExpA2 = Array com as contas do passivo                      ³±±
±±³          ³ExpA3 = Array com as contas de patrimonio                   ³±±
±±³          ³ExpA4 = Array com as contas de gasto                        ³±±
±±³          ³ExpA5 = Array com as contas de receita                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FCabR460( olReport, nCol, aCntsAtivo, aCntsPassivo, aCntsPatrim, aCntsGasto, aCntsIngress  )
Local nInc			:= 0
Local nColPix		:= olReport:Col() + 10
Local aVert			:= { 130, 250, PIX_INICIAL_VALORES }
Local nIniDin		:= PIX_INICIAL_VALORES					// Pixel redimencionado dinamicamente
Local oFont 		:= TFont():New( "Courier New",, -06 )
Local nLimitrofe	:= 4850
Local nTamPad		:= 0
Local nCharPCol		:= 14							// Quantidade de caracteres por coluna

nCol := olReport:Col() + 10

olReport:PrintText( STR0002 + AllTrim( Str(Month(Date())))+"/"+AllTrim(Str(Year(Date())))	,olReport:Row()   ,nColPix) //Periodo
olReport:PrintText( STR0003 + AllTrim( SM0->M0_CGC)											,olReport:Row()+35,nColPix) //RUC
olReport:PrintText( STR0004 + AllTrim( Capital( SM0->M0_NOMECOM ) )						,olReport:Row()+40,nColPix) //Nome Contribuinte
olReport:SkipLine( 2 )

// Primeira linha
nTamPad	:= Len( aCntsAtivo ) * nCharPCol
olReport:Say( olReport:Row(), nColPix+0010, PadC( STR0014, 10 ),	oFont )		// Correlativo - Coluna 1
olReport:Say( olReport:Row(), nColPix+0130, PadC( STR0005, 10 ),		oFont )		// Data do Periodo - Coluna 2
olReport:Say( olReport:Row(), nColPix+0250, STR0007,    				oFont )		// Operacao Mensal - Coluna 3
olReport:Say( olReport:Row(), nIniDin, PadC( STR0008, nTamPad ), 		oFont )
nIniDin += ( PIX_DIF_COLUNA_VALORES * Len( aCntsAtivo ) )
aAdd( aVert, nIniDin )

nTamPad	:= Len( aCntsPassivo ) * nCharPCol
olReport:Say( olReport:Row(), nIniDin, PadC( STR0009, nTamPad ), 	oFont )		// Passivo
nIniDin += ( PIX_DIF_COLUNA_VALORES * Len( aCntsPassivo ) )
aAdd( aVert, nIniDin )

nTamPad	:= Len( aCntsPatrim ) * nCharPCol
olReport:Say( olReport:Row(), nIniDin, PadC( STR0010, nTamPad ),	oFont )		// Patrimonio
nIniDin += ( PIX_DIF_COLUNA_VALORES * Len( aCntsPatrim ) )
aAdd( aVert, nIniDin )

nTamPad	:= Len( aCntsGasto ) * nCharPCol
olReport:Say( olReport:Row(), nIniDin, PadC( STR0011, nTamPad ),		oFont )		// Despesas
nIniDin += ( PIX_DIF_COLUNA_VALORES * Len( aCntsGasto ) )
aAdd( aVert, nIniDin )

nTamPad	:= Len( aCntsIngress ) * nCharPCol
olReport:Say( olReport:Row(), nIniDin, PadC( STR0012, nTamPad ),		oFont )		// Receitas
nIniDin += ( PIX_DIF_COLUNA_VALORES * Len( aCntsIngress ) )
aAdd( aVert, nIniDin )

nLimitrofe := nIniDin
olReport:Box(olReport:Row()-004,olReport:Col()-004, olReport:Row()+064, nLimitrofe )
FR460Prnt( olReport, aVert )													// Imprime a linhas verticais e passa para proxima linha
olReport:SkipLine( 1 )

// Cria a linha entre o tipo de conta e suas respectivas contas
olReport:Box(olReport:Row()-004,PIX_INICIAL_VALORES, olReport:Row()-004, nLimitrofe )

// Segunda linha
olReport:Say( olReport:Row(), nColPix+0130, PadC( STR0006, 10 ), 	oFont )		// Periodo

// Imprime as contas
nIniDin	:= PIX_INICIAL_VALORES
For nInc := 1 To Len( aCntsAtivo )
	olReport:Say( olReport:Row(), nIniDin, PadC( aCntsAtivo[nInc], 14 ), oFont )
	nIniDin += PIX_DIF_COLUNA_VALORES
	
	aAdd( aVert, nIniDin )
Next

For nInc := 1 To Len( aCntsPassivo )
	olReport:Say( olReport:Row(), nIniDin, PadC( aCntsPassivo[nInc], 14 ), oFont )
	nIniDin += PIX_DIF_COLUNA_VALORES
	
	aAdd( aVert, nIniDin )
Next

For nInc := 1 To Len( aCntsPatrim )
	olReport:Say( olReport:Row(), nIniDin, PadC( aCntsPatrim[nInc], 14 ), oFont )
	nIniDin += PIX_DIF_COLUNA_VALORES
	
	aAdd( aVert, nIniDin )
Next

For nInc := 1 To Len( aCntsGasto )
	olReport:Say( olReport:Row(), nIniDin, PadC( aCntsGasto[nInc], 14 ), oFont )
	nIniDin += PIX_DIF_COLUNA_VALORES
	
	aAdd( aVert, nIniDin )
Next

For nInc := 1 To Len( aCntsIngress )
	olReport:Say( olReport:Row(), nIniDin, PadC( aCntsIngress[nInc], 14 ), oFont )
	nIniDin += PIX_DIF_COLUNA_VALORES
	
	aAdd( aVert, nIniDin )
Next

FR460Prnt( olReport, aVert )														// Imprime a linhas verticais e passa para proxima linha
olReport:SkipLine( 1 )

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FTotR460  ³ Autor ³ Totvs                 ³ Data | 06/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cabeçalho do relatorio.								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FTotR460(Expo1,ExpN1,ExpA1)  				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 = Objeto tReport                                      ³±±
±±³          ³ExpN1 = Posição da coluna de impressão                      ³±±
±±³          ³ExpA1 = Array com as contas do ativo                        ³±±
±±³          ³ExpA2 = Array com as contas do passivo                      ³±±
±±³          ³ExpA3 = Array com as contas de patrimonio                   ³±±
±±³          ³ExpA4 = Array com as contas de gasto                        ³±±
±±³          ³ExpA5 = Array com as contas de receita                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FTotR460( olReport, nCol, aTotais )
Local nInc			:= 0
Local nColPix		:= olReport:Col() + 10
Local aVert			:= { PIX_INICIAL_VALORES }
Local nIniDin		:= PIX_INICIAL_VALORES					// Pixel redimencionado dinamicamente
Local oFont 		:= TFont():New( "Courier New",, -06 )
Local nLimitrofe	:= 4850

nCol := olReport:Col() + 10

// Segunda linha
olReport:Say( olReport:Row(), nColPix, STR0013, 			oFont )		// Totais

nIniDin	:= PIX_INICIAL_VALORES
For nInc := 1 To Len( aTotais )
	olReport:Say( olReport:Row(), nIniDin, Transform(aTotais[nInc], "@E 999999999.99" ), oFont )
	nIniDin += PIX_DIF_COLUNA_VALORES
	
	aAdd( aVert, nIniDin )
Next

nLimitrofe := nIniDin
olReport:Box(olReport:Row()-004,olReport:Col()-004, olReport:Row()+031, nLimitrofe )

FR460Prnt( olReport, aVert )												// Imprime a linhas verticais e passa para proxima linha
olReport:SkipLine( 1 )

Return


/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FR460Prnt ³ Autor ³ Totvs                 ³ Data | 07/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime as linhas verticais e horizontais do relatorio      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FR460Prnt( ExpA1 )         				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 = Array com as colunas                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR460Prnt( olReport, aCol )
Local nInc 		:= 1
Local nLinPix	:= 34

For nInc := 1 To Len( aCol )
	olReport:Box( olReport:Row()-004, aCol[nInc], olReport:Row()+nLinPix, aCol[nInc] ) 			// traco vertical
Next

Return

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FR460Hist ³ Autor ³ Totvs                 ³ Data | 10/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Divide o hisorico em linhas.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FRR460Hist( cHist )         				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 = Array com as linhas de historico                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR460Hist( cHist )
Local aRet		:= {}
Local cAux		:= ""
Local nTamLin	:= 20

cHist := AllTrim( cHist )
If Len( cHist ) <= nTamLin
	aAdd( aRet, cHist )
Else
	cAux := cHist
	While !Empty( cAux )
		aAdd( aRet, substr( cAux, 1, nTamLin ) )
		cAux := substr( cAux, nTamLin + 1 )
	End
EndIf

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq   ³ Autor ³                     ³ Data ³ 20.07.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ 5.2 LIBRO DIARIO DE FORMATO SIMPLIFICADO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Diretorio de criacao do arquivo.                    ³±±
±±³            ³ cArq - Nome do arquivo com extensao do arquivo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Peru - 5.2 LIBRO DIARIO DE FORMATO SIMPLIFICADO     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArq(cDir)

	Local nHdl    := 0
	Local nTotal1 := 1
	Local nCont   := 0
	Local nContX  := 0
	Local cLin    := ""
	Local cSep    := "|"
	Local cArq    := ""
	Local cCredx  := ""
	Local cDebx   := ""	
	Local cLetra  := ""
	Local cSerNfx := ""	
	Local cHistX  := ""

	FOR nCont:=LEN(ALLTRIM(cDir)) TO 1 STEP -1
		IF SUBSTR(cDir,nCont,1)=='\'
			cDir:=Substr(cDir,1,nCont)
			EXIT
		ENDIF
	NEXT

	//Nome do arquivo TXT conforme layout - SUNAT
	cArq += "LE"                            // Fixo  'LE'
	cArq +=  AllTrim(SM0->M0_CGC)           // Ruc
	cArq +=  AllTrim(Str(Year(MV_PAR02)))   // Ano
	cArq +=  AllTrim(Strzero(Month(MV_PAR02),2))  // Mes
	cArq +=  "00"                            // Fixo '00'
	cArq += "050200"                         // Fixo '050200'
	cArq += "00"                             // Fixo '00'
	cArq += "1"
	cArq += "1"
	cArq += "1"
	cArq += "1"
	cArq += ".TXT" // Extensao

	nHdl := fCreate(cDir+cArq)
	If nHdl <= 0
		ApMsgStop("Ocorreu um erro ao criar o arquivo.")
	Else

		DBSELECTAREA('PER')
		DBGOTOP()
		While ! Eof()
			cDebx  := PER->CT2_DEBITO
			cCredx := PER->CT2_CREDITO
			IF PER->CT2_VALOR > 0
				IF  cDebx == cCredx
					nContX++

					cLetra:= "D"
					cLin:=""
					//01 - Periodo
					cLin += SubStr(DTOS(MV_PAR02),1,6)+"00"
					cLin += cSep

					//02 - Código Único de la Operación (CUO), que es la llave única o clave única o clave primaria del software contable
					cLin += AllTrim(CT2_NODIA)+ALLTRIM(PER->CT2_LINHA)+cLetra
					cLin += cSep

					//03 - Número correlativo del asiento contable identificado en el campo 2.
					cLin += "M"+ Strzero(nContX,9)
					cLin += cSep

					//04 - Código de la cuenta contable desagregado en subcuentas al nivel máximo de dígitos utilizado, según la estructura 5.3
					cLin += AllTrim(CT2_DEBITO)
					cLin += cSep

					//05 - Código de la Unidad de Operación, de la Unidad Económica Administrativa, de la Unidad de Negocio - Não obrigatório
					cLin += ""
					cLin += cSep

					//06 - Código del Centro de Costos, Centro de Utilidades o Centro de Inversión, de corresponder - Não obrigatório
					cLin += ""
					cLin += cSep

					//07 - Tipo de Moneda de origen (TABLA 4)
					If SYF->(Dbseek(xFilial("SYF")+(GetMV("MV_SIMB"+AllTrim(STR(VAL(PER->CT2_MOEDLC))))))) .And. !Empty(AllTrim(SYF->YF_ISO))
						cLin += AllTrim(SYF->YF_ISO)
					Else
						cLin += ""
					EndIf
					cLin += cSep

					//08 - tipo de documento de identidad del emisor  - Não obrigatório
					cLin += ""
					cLin += cSep

					//09 - numero de documento de identidad del emisor - Não obrigatório
					cLin += ""
					cLin += cSep

					//10 - Tipo de Comprobante de Pago o Documento asociada a la operación, de corresponder - Tabla 10

					cRecCT2 := ""
					cRecCT2 := ALLTRIM(STR(INT((PER->R_E_C_N_O_))))
					aArea:=Getarea()
					nRecOri := int(val(CV3->CV3_RECORI))
					cTipDocX:="00"
					cSerieX:= ""
					If dBOrdRecDes()
						If dbSeek(xFilial("CV3")+cRecCT2,.F.)
							dbSelectArea(CV3->CV3_TABORI)
							nRecOri := int(val(CV3->CV3_RECORI))
							If CV3->CV3_TABORI $ "SF1|SF2"
								If CV3->CV3_TABORI == "SF1"
									SF1->(dbGoTo(nRecOri))
									If SF1->(Recno())==nRecOri
										cTipDocX:= SF1->F1_TPDOC
										If EMPTY(SF1->F1_SERIE)
											cSerieX:= SF1->F1_SERIE2
										Else
											cSerieX:= SF1->F1_SERIE
										EndIf
									Else
										cSerieX:= ""
									EndIf
								Else
									SF2->(dbGoTo(nRecOri))
									If SF2->(Recno())==nRecOri
										cTipDocX:= SF2->F2_TPDOC
										If EMPTY(SF2->F2_SERIE)
											cSerieX:= SF2->F2_SERIE2
										Else
											cSerieX:= SF2->F2_SERIE
										EndIf
									Else
										cSerieX:= ""
									EndIf
								EndIf
							Endif
						EndIf
					endif
					cLin += AllTrim(cTipDocX)
					cLin += cSep

					//11 - Número de serie del comprobante de pago o documento asociada a la operación, de corresponder

					cSerNfx := Alltrim(cSerieX)
					nTotal1:=Len(cSerNfx)+1
					cTipDocX:=Alltrim(cTipDocX)
					cSerieNfx:=cSerNfx

					If !(cTipDocX $ "50|05")
						For nTotal1:=Len(cSerNfx)+1 to 4
							cSerieNfx:="0"+cSerieNfx
						Next
					EndIf

					If cTipDocX == "00"
						cLin += ""
					Else
						cLin += AllTrim(cSerieNfx)
					EndIf
					cLin += cSep
					RestArea(aArea)

					//12 - Número del comprobante de pago o documento asociada a la operación
					cLin += AllTrim(PER->CT2_DOC)
					cLin += cSep

					//13 - Fecha contable - Não obrigatório
					cLin += ""
					cLin += cSep

					//14 - Fecha de vencimiento - Não obrigatório
					cLin += ""
					cLin += cSep

					//15  - Data da contabilizacao Fecha de la operación o emisión
					cLin += SubStr(DTOC(PER->CT2_DATA),1,6)+SubStr(DTOS(PER->CT2_DATA),1,4)
					cLin += cSep

					//16 - Glosa o descripción de la naturaleza de la operación registrada, de ser el caso.
					cHistX := ""
					cLin += StrTran(StrTran(StrTran(cHistX,"/"," "),"\"," "),"|"," ")
					cLin += cSep

					//17 - Glosa referencial, de ser el caso - Não obrigatório
					cLin += ALLTRIM(STR(PER->CT2_VALOR,17,2))
					cLin += cSep

					//18  - Conta Debito - Movimientos del Debe
					cLin += ALLTRIM(STR(PER->CT2_VALOR,17,2))
					cLin += cSep

					//19 - Conta Credito - Movimientos del Haber
					cLin +="0.00"
					cLin += cSep

					//20 - Dato Estructurado: Código del libro, campo 1, campo 2 y campo 3 del Registro de Ventas e Ingresos o del Registro de Compras,
					//separados con el carácter "&", de corresponder. - Não obrigatório

					cLin += ""
					cLin += cSep

					//21 - Indica el estado de la operación
					cLin += '1'
					cLin += cSep

					cLin += chr(13)+chr(10)
					fWrite(nHdl,cLin)
					cLin:=""

					cLetra:="H"

					cLin:=""
					//01 - Periodo
					cLin += SubStr(DTOS(MV_PAR02),1,6)+"00"
					cLin += cSep

					//02 - Código Único de la Operación (CUO), que es la llave única o clave única o clave primaria del software contable
					cLin += AllTrim(CT2_NODIA)+ALLTRIM(PER->CT2_LINHA)+cLetra
					cLin += cSep

					//03 - Número correlativo del asiento contable identificado en el campo 2.
					cLin += "M"+ Strzero(nContX,9)
					cLin += cSep

					//04 - Código de la cuenta contable desagregado en subcuentas al nivel máximo de dígitos utilizado, según la estructura 5.3
					cLin += AllTrim(CT2_DEBITO)
					cLin += cSep

					//05 - Código de la Unidad de Operación, de la Unidad Económica Administrativa, de la Unidad de Negocio - Não obrigatório
					cLin += ""
					cLin += cSep

					//06 - Código del Centro de Costos, Centro de Utilidades o Centro de Inversión, de corresponder - Não obrigatório
					cLin += ""
					cLin += cSep

					//07 - Tipo de Moneda de origen (TABLA 4)
					If SYF->(Dbseek(xFilial("SYF")+(GetMV("MV_SIMB"+AllTrim(STR(VAL(PER->CT2_MOEDLC))))))) .And. !Empty(AllTrim(SYF->YF_ISO))
						cLin += AllTrim(SYF->YF_ISO)
					Else
						cLin += ""
					EndIf
					cLin += cSep

					//08 - tipo de documento de identidad del emisor  - Não obrigatório
					cLin += ""
					cLin += cSep

					//09 - numero de documento de identidad del emisor - Não obrigatório
					cLin += ""
					cLin += cSep

					//10 - Tipo de Comprobante de Pago o Documento asociada a la operación, de corresponder - Tabla 10

					cRecCT2 := ""
					cRecCT2 := ALLTRIM(STR(INT((PER->R_E_C_N_O_))))
					aArea:=Getarea()
					nRecOri := int(val(CV3->CV3_RECORI))
					cTipDocX:="00"
					cSerieX:= ""
					If dBOrdRecDes()
						If dbSeek(xFilial("CV3")+cRecCT2,.F.)
							dbSelectArea(CV3->CV3_TABORI)
							nRecOri := int(val(CV3->CV3_RECORI))
							If CV3->CV3_TABORI $ "SF1|SF2"
								If CV3->CV3_TABORI == "SF1"
									SF1->(dbGoTo(nRecOri))
									If SF1->(Recno())==nRecOri
										cTipDocX:= SF1->F1_TPDOC
										If EMPTY(SF1->F1_SERIE)
											cSerieX:= SF1->F1_SERIE2
										Else
											cSerieX:= SF1->F1_SERIE
										EndIf
									Else
										cSerieX:= ""
									EndIf
								Else
									SF2->(dbGoTo(nRecOri))
									If SF2->(Recno())==nRecOri
										cTipDocX:= SF2->F2_TPDOC
										If EMPTY(SF2->F2_SERIE)
											cSerieX:= SF2->F2_SERIE2
										Else
											cSerieX:= SF2->F2_SERIE
										EndIf
									Else
										cSerieX:= ""
									EndIf
								EndIf
							Endif
						EndIf
					endif
					cLin += AllTrim(cTipDocX)
					cLin += cSep

					//11 - Número de serie del comprobante de pago o documento asociada a la operación, de corresponder

					cSerNfx:= Alltrim(cSerieX)
					nTotal1 := Len(cSerNfx)+1
					cTipDocX:= Alltrim(cTipDocX)
					cSerieNfx:= cSerNfx

					If !(cTipDocX $ "50|05")
						For nTotal1:=Len(cSerNfx)+1 to 4
							cSerieNfx:="0"+cSerieNfx
						Next
					EndIf

					If cTipDocX == "00"
						cLin += ""
					Else
						cLin += AllTrim(cSerieNfx)
					EndIf
					cLin += cSep
					RestArea(aArea)

					//12 - Número del comprobante de pago o documento asociada a la operación
					cLin += AllTrim(PER->CT2_DOC)
					cLin += cSep

					//13 - Fecha contable - Não obrigatório
					cLin += ""
					cLin += cSep

					//14 - Fecha de vencimiento - Não obrigatório
					cLin += ""
					cLin += cSep

					//15  - Data da contabilizacao Fecha de la operación o emisión
					cLin += SubStr(DTOC(PER->CT2_DATA),1,6)+SubStr(DTOS(PER->CT2_DATA),1,4)
					cLin += cSep

					//16 - Glosa o descripción de la naturaleza de la operación registrada, de ser el caso.
					cHistX := ""
					cLin += StrTran(StrTran(StrTran(cHistX,"/"," "),"\"," "),"|"," ")

					//17 - Glosa referencial, de ser el caso - Não obrigatório
					cLin += ""
					cLin += cSep

					//18  - Conta Debito - Movimientos del Debe
					cLin += "0.00"
					cLin += cSep

					//19 - Conta Credito - Movimientos del Haber
					cLin += ALLTRIM(STR(PER->CT2_VALOR,17,2))
					cLin += cSep

					//20 - Dato Estructurado: Código del libro, campo 1, campo 2 y campo 3 del Registro de Ventas e Ingresos o del Registro de Compras,
					//separados con el carácter "&", de corresponder. - Não obrigatório

					cLin += ""
					cLin += cSep

					//21 - Indica el estado de la operación
					cLin += '1'
					cLin += cSep

					cLin += chr(13)+chr(10)
					fWrite(nHdl,cLin)
					cLin:=""

				ELSE   // contas diferentes
					nContX++
					lDeb  := .F.
					lCred := .F.

					If PER->CT2_DC =="3"
						lDeb  := .T.
						lCred := .T.
					ElseIf PER->CT2_DC =="1"
						lDeb  := .T.
					ElseIf PER->CT2_DC =="2"
						lCred := .T.
					EndIf

					If lDeb
						cLetra:="D"
						cLin:=""
						//01 - Periodo
						cLin += SubStr(DTOS(MV_PAR02),1,6)+"00"
						cLin += cSep

						//02 - Código Único de la Operación (CUO), que es la llave única o clave única o clave primaria del software contable
						cLin += AllTrim(CT2_NODIA)+ALLTRIM(PER->CT2_LINHA)+cLetra
						cLin += cSep

						//03 - Número correlativo del asiento contable identificado en el campo 2.
						cLin += "M"+ Strzero(nContX,9)
						cLin += cSep

						//04 - Código de la cuenta contable desagregado en subcuentas al nivel máximo de dígitos utilizado, según la estructura 5.3
						cLin += AllTrim(CT2_DEBITO)
						cLin += cSep

						//05 - Código de la Unidad de Operación, de la Unidad Económica Administrativa, de la Unidad de Negocio - Não obrigatório
						cLin += ""
						cLin += cSep

						//06 - Código del Centro de Costos, Centro de Utilidades o Centro de Inversión, de corresponder - Não obrigatório
						cLin += ""
						cLin += cSep

						//07 - Tipo de Moneda de origen (TABLA 4)
						If SYF->(Dbseek(xFilial("SYF")+(GetMV("MV_SIMB"+AllTrim(STR(VAL(PER->CT2_MOEDLC))))))) .And. !Empty(AllTrim(SYF->YF_ISO))
							cLin += AllTrim(SYF->YF_ISO)
						Else
							cLin += ""
						EndIf
						cLin += cSep

						//08 - tipo de documento de identidad del emisor  - Não obrigatório
						cLin += ""
						cLin += cSep

						//09 - numero de documento de identidad del emisor - Não obrigatório
						cLin += ""
						cLin += cSep

						//10 - Tipo de Comprobante de Pago o Documento asociada a la operación, de corresponder - Tabla 10

						cRecCT2 := ""
						cRecCT2 := ALLTRIM(STR(INT((PER->R_E_C_N_O_))))
						aArea:=Getarea()
						nRecOri := int(val(CV3->CV3_RECORI))
						cTipDocX:="00"
						cSerieX:= ""
						If dBOrdRecDes()
							If dbSeek(xFilial("CV3")+cRecCT2,.F.)
								dbSelectArea(CV3->CV3_TABORI)
								nRecOri := int(val(CV3->CV3_RECORI))
								If CV3->CV3_TABORI $ "SF1|SF2"
									If CV3->CV3_TABORI == "SF1"
										SF1->(dbGoTo(nRecOri))
										If SF1->(Recno())==nRecOri
											cTipDocX:= SF1->F1_TPDOC
											If EMPTY(SF1->F1_SERIE)
												cSerieX:= SF1->F1_SERIE2
											Else
												cSerieX:= SF1->F1_SERIE
											EndIf
										Else
											cSerieX:= ""
										EndIf
									Else
										SF2->(dbGoTo(nRecOri))
										If SF2->(Recno())==nRecOri
											cTipDocX:= SF2->F2_TPDOC
											If EMPTY(SF2->F2_SERIE)
												cSerieX:= SF2->F2_SERIE2
											Else
												cSerieX:= SF2->F2_SERIE
											EndIf
										Else
											cSerieX:= ""
										EndIf
									EndIf
								Endif
							EndIf
						endif
						cLin += AllTrim(cTipDocX)
						cLin += cSep

						//11 - Número de serie del comprobante de pago o documento asociada a la operación, de corresponder

						cSerNfx := Alltrim(cSerieX)
						nTotal1:=Len(cSerNfx)+1
						cTipDocX:=Alltrim(cTipDocX)
						cSerieNfx:=cSerNfx

						If !(cTipDocX $ "50|05")
							For nTotal1:=Len(cSerNfx)+1 to 4
								cSerieNfx:="0"+cSerieNfx
							Next
						EndIf

						If cTipDocX == "00"
							cLin += ""
						Else
							cLin += AllTrim(cSerieNfx)
						EndIf
						cLin += cSep
						RestArea(aArea)

						//12 - Número del comprobante de pago o documento asociada a la operación
						cLin += AllTrim(PER->CT2_DOC)
						cLin += cSep

						//13 - Fecha contable - Não obrigatório
						cLin += ""
						cLin += cSep

						//14 - Fecha de vencimiento - Não obrigatório
						cLin += ""
						cLin += cSep

						//15  - Data da contabilizacao Fecha de la operación o emisión
						cLin += SubStr(DTOC(PER->CT2_DATA),1,6)+SubStr(DTOS(PER->CT2_DATA),1,4)
						cLin += cSep

						//16 - Glosa o descripción de la naturaleza de la operación registrada, de ser el caso.
						cHistX := ""
						cHistX := AllTrim(PER->CT2_HIST)
						cLin += StrTran(StrTran(StrTran(cHistX,"/"," "),"\"," "),"|"," ")
						cLin += cSep

						//17 - Glosa referencial, de ser el caso - Não obrigatório
						cLin += ""
						cLin += cSep

						//18  - Conta Debito - Movimientos del Debe
						cLin += ALLTRIM(STR(PER->CT2_VALOR,17,2))
						cLin += cSep

						//19 - Conta Credito - Movimientos del Haber
						cLin += "0.00"
						cLin += cSep

						//20 - Dato Estructurado: Código del libro, campo 1, campo 2 y campo 3 del Registro de Ventas e Ingresos o del Registro de Compras,
						//separados con el carácter "&", de corresponder. - Não obrigatório

						cLin += ""
						cLin += cSep

						//21 - Indica el estado de la operación
						cLin += '1'
						cLin += cSep

						cLin += chr(13)+chr(10)

						fWrite(nHdl,cLin)

						cLin:= ""
					EndIf

					If lCred

						cLetra:= "H"
						cLin:=""
						//01 - Periodo
						cLin += SubStr(DTOS(MV_PAR02),1,6)+"00"
						cLin += cSep

						//02 - Código Único de la Operación (CUO), que es la llave única o clave única o clave primaria del software contable
						cLin += AllTrim(CT2_NODIA)+ALLTRIM(PER->CT2_LINHA)+cLetra
						cLin += cSep

						//03 - Número correlativo del asiento contable identificado en el campo 2.
						cLin += "M"+ Strzero(nContX,9)
						cLin += cSep

						//04 - Código de la cuenta contable desagregado en subcuentas al nivel máximo de dígitos utilizado, según la estructura 5.3
						cLin += AllTrim(CT2_CREDITO)
						cLin += cSep

						//05 - Código de la Unidad de Operación, de la Unidad Económica Administrativa, de la Unidad de Negocio - Não obrigatório
						cLin += ""
						cLin += cSep

						//06 - Código del Centro de Costos, Centro de Utilidades o Centro de Inversión, de corresponder - Não obrigatório
						cLin += ""
						cLin += cSep

						//07 - Tipo de Moneda de origen (TABLA 4)
						If SYF->(Dbseek(xFilial("SYF")+(GetMV("MV_SIMB"+AllTrim(STR(VAL(PER->CT2_MOEDLC))))))) .And. !Empty(AllTrim(SYF->YF_ISO))
							cLin += AllTrim(SYF->YF_ISO)
						Else
							cLin += ""
						EndIf
						cLin += cSep

						//08 - tipo de documento de identidad del emisor  - Não obrigatório
						cLin += ""
						cLin += cSep

						//09 - numero de documento de identidad del emisor - Não obrigatório
						cLin += ""
						cLin += cSep

						//10 - Tipo de Comprobante de Pago o Documento asociada a la operación, de corresponder - Tabla 10

						cRecCT2 := ""
						cRecCT2 := ALLTRIM(STR(INT((PER->R_E_C_N_O_))))
						aArea:=Getarea()
						nRecOri := int(val(CV3->CV3_RECORI))
						cTipDocX:="00"
						cSerieX:= ""
						If dBOrdRecDes()
							If dbSeek(xFilial("CV3")+cRecCT2,.F.)
								dbSelectArea(CV3->CV3_TABORI)
								nRecOri := int(val(CV3->CV3_RECORI))
								If CV3->CV3_TABORI $ "SF1|SF2"
									If CV3->CV3_TABORI == "SF1"
										SF1->(dbGoTo(nRecOri))
										If SF1->(Recno())==nRecOri
											cTipDocX:= SF1->F1_TPDOC
											If EMPTY(SF1->F1_SERIE)
												cSerieX:= SF1->F1_SERIE2
											Else
												cSerieX:= SF1->F1_SERIE
											EndIf
										Else
											cSerieX:= ""
										EndIf
									Else
										SF2->(dbGoTo(nRecOri))
										If SF2->(Recno())==nRecOri
											cTipDocX:= SF2->F2_TPDOC
											If EMPTY(SF2->F2_SERIE)
												cSerieX:= SF2->F2_SERIE2
											Else
												cSerieX:= SF2->F2_SERIE
											EndIf
										Else
											cSerieX:= ""
										EndIf
									EndIf
								Endif
							EndIf
						endif
						cLin += AllTrim(cTipDocX)
						cLin += cSep

						//11 - Número de serie del comprobante de pago o documento asociada a la operación, de corresponder

						cSerNfx := Alltrim(cSerieX)
						nTotal1:=Len(cSerNfx)+1
						cTipDocX:=Alltrim(cTipDocX)
						cSerieNfx:=cSerNfx

						If !(cTipDocX $ "50|05")
							For nTotal1:=Len(cSerNfx)+1 to 4
								cSerieNfx:="0"+cSerieNfx
							Next
						EndIf

						If cTipDocX == "00"
							cLin += ""
						Else
							cLin += AllTrim(cSerieNfx)
						EndIf
						cLin += cSep
						RestArea(aArea)

						//12 - Número del comprobante de pago o documento asociada a la operación
						cLin += AllTrim(PER->CT2_DOC)
						cLin += cSep

						//13 - Fecha contable - Não obrigatório
						cLin += ""
						cLin += cSep

						//14 - Fecha de vencimiento - Não obrigatório
						cLin += ""
						cLin += cSep

						//15  - Data da contabilizacao Fecha de la operación o emisión
						cLin += SubStr(DTOC(PER->CT2_DATA),1,6)+SubStr(DTOS(PER->CT2_DATA),1,4)
						cLin += cSep

						//16 - Glosa o descripción de la naturaleza de la operación registrada, de ser el caso.
						cHistX := ""
						cHistX := AllTrim(PER->CT2_HIST)
						cLin += StrTran(StrTran(StrTran(cHistX,"/"," "),"\"," "),"|"," ")
						cLin += cSep

						//17 - Glosa referencial, de ser el caso - Não obrigatório
						cLin += ""
						cLin += cSep

						//18  - Conta Debito - Movimientos del Debe
						cLin += "0.00"
						cLin += cSep

						//19 - Conta Credito - Movimientos del Haber
						cLin += ALLTRIM(STR(PER->CT2_VALOR,17,2))
						cLin += cSep

						//20 - Dato Estructurado: Código del libro, campo 1, campo 2 y campo 3 del Registro de Ventas e Ingresos o del Registro de Compras,
						//separados con el carácter "&", de corresponder. - Não obrigatório

						cLin += ""
						cLin += cSep

						//21 - Indica el estado de la operación
						cLin += '1'
						cLin += cSep

						cLin += chr(13)+chr(10)

						fWrite(nHdl,cLin)

						cLin:= ""
					EndIf
				EndIf
			EndIf
			PER->(dbSkip())
		EndDo
		fClose(nHdl)
	EndIf

Return Nil

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArqL4   ³                           ³ Data ³ 20.07.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Diretorio de criacao do arquivo.                    ³±±
±±³            ³ cArqL1 - Nome do arquivo com extensao do arquivo.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Peru - 5.4 LIBRO DIARIO DE FORMATO SIMPLIFICADO     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/
Static Function GerArqL4(cDir)

	Local nHdl    := 0
	Local nTotal  := ""
	Local nCont   := 0
	Local cLin    := ""
	Local cSep    := "|"
	Local cArq    := ""	
	Local cFilCt1 := ""
	Local cFilCt2 := ""	
	Local cConta1 := ""
	Local cContaF :=""
	Local aSelFil := {}
	Local cPERPER1Fil
	Local cPER1CT2Fil

	cArq += "LE"                            // Fixo  'LE'
	cArq +=  AllTrim(SM0->M0_CGC)           // Ruc
	cArq +=  AllTrim(Str(Year(MV_PAR02)))   // Ano
	cArq +=  AllTrim(Strzero(Month(MV_PAR02),2))  // Mes
	cArq +=  "00"                            // Fixo '00'
	cArq += "050400"                         // Fixo '050400'
	cArq += "00"                             // Fixo '00'
	cArq += "1"
	cArq += "1"
	cArq += "1"
	cArq += "1"
	cArq += ".TXT" // Extensao

	FOR nCont:=LEN(AllTrim(cDir)) TO 1 STEP -1
		IF SUBSTR(cDir,nCont,1)=='\'
			cDir:=Substr(cDir,1,nCont)
			EXIT
		ENDIF
	NEXT

	nHdl := fCreate(cDir+cArq)
	If nHdl <= 0
		ApMsgStop("Ocorreu um erro ao criar o arquivo.")
	Else

		PER1 := GetNextAlias()

		cFilCt1  := " CT1_FILIAL " + GetRngFil( aSelFil, "CT1", .T., @cPERPER1Fil )
		cFilCt2  := " CT2_FILIAL " + GetRngFil( aSelFil, "CT2", .T., @cPER1CT2Fil )

		cQuery := " SELECT CT1_FILIAL"
		cQuery += "       , CT1_CONTA"
		cQuery += "       , CT1_DESC01"
		cQuery += "   FROM " + RetSqlName('CT1') + " CT1"
		cQuery += "  WHERE " + cFilCT1
		cQuery += "		AND CT1_CONTA  >= '" + mv_par06 + "'"
		cQuery += "     AND CT1_CONTA  <= '" + mv_par07 + "'"
		cQuery += "		AND CT1_NCUSTO = 0"
		cQuery += "		AND CT1_CLASSE = '2'"
		cQuery += "		AND CT1_BLOQ = '2'"
		cQuery += "		AND CT1.D_E_L_E_T_ = ' ' "
		cQuery += "  ORDER BY CT1_CONTA "

		ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), 'PER1', .T., .F. )
		DbSelectArea('PER1')

		dbSelectArea("PER1")
		PER1 ->(dbGoTop())
		Do While PER1->(!EOF())

			cLin:=""
			//01 - Periodo
			cLin += SubStr(DTOS(MV_PAR02),1,8)
			cLin += cSep

			//02 - Código de la Cuenta Contable desagregada hasta el nivel máximo de dígitos utilizado
			cContaF := ""
			cConta1 := AllTrim(PER1->CT1_CONTA)
			nTotal  := Len(cConta1)+1

			If Len(cConta1) <= 2
				For nTotal := Len(cConta1)+1 to 3
					cContaF += "0"
				Next
			EndIf
			cContaF += cConta1

			cLin += AllTrim(cContaF)
			cLin += cSep

			//03 - Descripción de la Cuenta Contable desagregada al nivel máximo de dígitos utilizado
			cLin += AllTrim(PER1->CT1_DESC01)
			cLin += cSep

			//04 - Código del Plan de Cuentas utilizado por el deudor tributario - TABELA 17
			cLin += SuperGetMv("MV_PLANREF",,'01')
			cLin += cSep

			//05 - Descripción del Plan de Cuentas utilizado por el deudor tributario - TABELA17
			If AllTrim(SuperGetMv("MV_PLANREF")) $ "01"
				cLin +="PLAN CONTABLE GENERAL EMPRESARIAL"
			ElseIf AllTrim(SuperGetMv("MV_PLANREF")) $ "02"
				cLin +="PLAN CONTABLE GENERAL REVISAOO"
			ElseIf AllTrim(SuperGetMv("MV_PLANREF")) $ "03"
				cLin +="PLAN DE CUENTAS PARA EMPRESAS DEL SISTEMA FINANCIERO"
			ElseIf AllTrim(SuperGetMv("MV_PLANREF")) $ "04"
				cLin +="PLAN DE CUENTAS PARA ENTIDADES PRESTADORAS DE SALUD"
			ElseIf AllTrim(SuperGetMv("MV_PLANREF")) $ "05"
				cLin +="PLAN DE CUENTAS PARA EMPRESAS DEL SISTEMA ASEGURADOR"
			ElseIf AllTrim(SuperGetMv("MV_PLANREF")) $ "06"
				cLin +="PLAN DE CUENTAS, ADMIN. PRIVADAS DE FONDOS DE PENSIONES"
			ElseIf AllTrim(SuperGetMv("MV_PLANREF")) $ "07"
				cLin +="PLAN CONTABLE GUBERNAMENTAL"
			ElseIf AllTrim(SuperGetMv("MV_PLANREF")) $ "99"
				cLin +="OTROS"
			Else
				cLin +="OTROS"
			EndIf
			cLin += cSeP

			//06 - Código de la Cuenta Contable Corporativa desagregada hasta el nivel máximo de dígitos utilizadoo
			cLin += ""
			cLin += cSep

			//07 - Descripción de la Cuenta Contable Corporativa desagregada al nivel máximo de dígitos utilizado
			cLin += ""
			cLin += cSep

			//08 - Indica el estado de la operación
			If MV_PAR01	<= MV_PAR02
				cLin += '1'
			Else
				cLin += '9'
			EndIf
			cLin += cSep

			cLin += chr(13)+chr(10)

			fWrite(nHdl,cLin)
			PER1->(dbSkip())
		EndDo
		fClose(nHdl)
	EndIf

	PER1->(DbCloseArea())

Return Nil



