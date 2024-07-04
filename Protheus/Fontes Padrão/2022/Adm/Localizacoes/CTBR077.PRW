#include "RwMake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "CTBR077.ch"

#define PIX_DIF_COLUNA_VALORES		300		// Pixel inicial para impressao dos tracos das colunas dinamicas
#define PIX_INICIAL_VALORES			001		// Pixel para impressao do traco vertical
#define PIX_EQUIVALENTE				010		// Pixel inicial para impressao das colunas dinamicas

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBR077   º Autor ³ Francisco Jr.      º Data ³  31/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Demonstrativo de Contabilizacao por Documento               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Contabilidade Gerencial                                     º±±
±±ºPais      ³Equador                                                     º±±
±±ºAnalisra  ³Francisco Junior                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³25/06/15³PCREQ-4256³Se elimina las funciones CTR077SX1() y³±±
±±³            ³        ³          ³CTVL077SX1()que modifican la tabla SX1³±±
±±³            ³        ³          ³por motivo de adecuacion a fuentes a  ³±±
±±³            ³        ³          ³nuevas estructuras SX para Version 12.³±±
±±³            ³        ³          ³                                      ³±±
±±³Jonathan Glz³09/10/15³PCREQ-4261³Merge v12.1.8                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBR077()

Local cPerg		:= "CTB077"
Local olReport

/*
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ mv_par01 - Data de?                                              ³
³ mv_par02 - Data ate?                                             ³
³ mv_par03 - Livro diario de?      								   ³
³ mv_par04 - Livro diario ate?     								   ³
³ mv_par05 - Numero diario de?    								   ³
³ mv_par06 - Numero diario ate?    								   ³
³ mv_par07 - Documento de?         								   ³
³ mv_par08 - Documento ate?        								   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*/
If FindFunction("TRepInUse") .And. TRepInUse()
	Pergunte(cPerg,.F.)
	olReport := CTBRel077(cPerg)
	olReport:SetParam(cPerg)
	olReport:PrintDialog()
EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBRel077 ³ Autor ³ Totvs                 ³ Data | 14/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio Treport a impressão do relatorio.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBR077( cPerg )           				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Perguntas dos parametros                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBRel077( cPerg )

Local clNomProg		:= FunName()
Local clTitulo 		:= STR0001 //"Resumo de Valores por Conta Contabil"
Local clDesc   		:= STR0001 //"Resumo de Valores por Conta Contabil"
Local olReport

olReport:=TReport():New(clNomProg,clTitulo,cPerg,{|olReport| CTBPrc077(olReport)},clDesc)
olReport:SetLandscape()					// Formato paisagem
olReport:lHeaderVisible 	:= .F. 		// Não imprime cabeçalho do protheus
olReport:lFooterVisible 	:= .F.		// Não imprime rodapé do protheus
olReport:lParamPage			:= .F.		// Não imprime pagina de parametros

Return olReport

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinpRC077 ³ Autor ³ Totvs                 ³ Data | 14/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressão do relatorio.								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FinProc( ExpC1 )         				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Objeto tReport                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBPrc077( olReport )

Local nReg			:= 0 //Quantidade de registros impressos
Local nCol			:= 0
Local cQuery		:= ""
Local aCnts			:= {}
    
//Local aColFin       := {"NR.DIARIO", " C.COSTO DB ", " C.COSTO CR ","CUENTA", "TD", "DOCUMENTO","DETALLE","DEBER","HABER"}
Local aColFin       := { STR0006, STR0003, STR0017, STR0004, STR0005, STR0002, STR0007, STR0008, STR0009}
Local aEquivale 	:= {"CT2_NODIA", "CT2_CCD", "CT2_CCC", "CT1_DESC01" , "CT2_DC" , "CT2_DOC" , "CT2_HIST" , "CT2_VALOR", "CT2_VALOR" }
                                            
Local nInc			:= 0
Local nPos			:= 0
Local nPosEquiv		:= 0
Local cStrFil		:= ""
Local oFont 		:= TFont():New( "Courier New",, -08 )
Local oFont12 		:= TFont():New( "Courier New",, -12 )
Local aVert			:= { 5, 130, 250, PIX_INICIAL_VALORES }
Local nIniDin		:= PIX_INICIAL_VALORES					// Pixel redimencionado dinamicamente
Local nLimitrofe	:= 4850
Local nLinHist 		:= 1
Local aHistorico	:= {}
Local aSelFil		:= {}
Local cCCusto       := ""
Local cTipPer       := ""
Local cDescPrt 		:= ""
Local cNomCon 		:= ""
Local nTotDeb 		:= 0
Local nTotCre		:= 0
Local nPag 			:= 0
Local cConhis		:= ""
Local nPosHis 		:= 0
Local cPictVal 		:= PesqPict("CT2","CT2_VALOR")
Local cAliasQry		:= "cAliasQry"

Private nPagina		:= 0

// Se aFil nao foi enviada, exibe tela para selecao das filiais
// Inicia o array totalizador com zero
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
cQuery	:= 	"SELECT CT2.CT2_FILIAL, CT2.CT2_DOC, CT2.CT2_CCD, CT2.CT2_CCC, CT2.CT2_DC, CT1.CT1_DESC01, CT2.CT2_LP, CT2.CT2_DIACTB, CT2.CT2_NODIA, CT2.CT2_DATA, "
cQuery	+= 	"CT2.CT2_HIST, CT2.CT2_DEBITO, CT2.CT2_CREDIT, CT2.CT2_VALOR, CTC.CTC_FILIAL, CTC.CTC_LOTE, CTC.CTC_DOC, CTC.CTC_DOCHIS"
      

cQuery += "FROM "
cQuery	+= RetSQLNAme("CT2")+" CT2 INNER JOIN "+RetSQLName("CTC")+" CTC ON "
cQuery += "      CT2.CT2_FILIAL  = CTC.CTC_FILIAL AND "
cQuery += "      CT2.CT2_DOC     = CTC.CTC_DOC  AND "
cQuery += "      CT2.CT2_LOTE    = CTC.CTC_LOTE AND "
cQuery += "      CT2.CT2_DATA    = CTC.CTC_DATA AND "
cQuery += "      CT2.D_E_L_E_T_ = ' '  LEFT JOIN " +RetSQLName("CT1")+ " CT1 ON "
cQuery += "      CT2.CT2_CREDIT = CT1.CT1_CONTA "
                    

cQuery +=	" WHERE "

cQuery +=" CT2.CT2_DATA >= '" + dTos(MV_PAR01) + "' AND"
cQuery +=" CT2.CT2_DATA <= '" + dTos(MV_PAR02) + "' AND"
cQuery +=" CT2.CT2_DIACTB >= '" + MV_PAR03 + "' AND"
cQuery +=" CT2.CT2_DIACTB <= '" + MV_PAR04 + "' AND"
cQuery +=" CT2.CT2_NODIA >= '" + MV_PAR05 + "' AND"
cQuery +=" CT2.CT2_NODIA <= '" + MV_PAR06 + "' AND"
cQuery +=" CT2.CT2_DOC >= '" + MV_PAR07 + "' AND"
cQuery +=" CT2.CT2_DOC <= '" + MV_PAR08 + "' "
cQuery +=" ORDER BY CT2.CT2_FILIAL, CT2.CT2_NODIA"

cQuery := ChangeQuery(cQuery)

If Select("cAliasQry") > 1
	cAliasQry->( DbCLoseArea() )
Endif

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry,.T.,.T.)

TCSetField( "cAliasQry", "CT2_DATA"	,	"D", 08)
TCSetField( "cAliasQry", "CT2_VALOR"	,	"N", TamSX3( "CT2_VALOR" )[1], TamSX3( "CT2_VALOR" )[2] )

DbSelectArea( "cAliasQry" )
cAliasQry->( DbGoTop() )

If cAliasQry->( !Eof() )

	olReport:OnPageBreak( { || FCabr077( olReport, nCol, aColFin) } )
	
EndIf

cAliasQry->(dbGoTop())
olReport:SetMeter( RecCount() )

While cAliasQry->(!Eof())

	If olReport:Cancel()
		Exit
	EndIf

	nPosEquiv 	:= PIX_EQUIVALENTE
	cConHis		:= " "
	cNumDoc		:= cAliasQry->CT2_NODIA

	For nInc := 1 To Len( aEquivale )
	
		aVert		:= { 5, PIX_INICIAL_VALORES }
		If nInc > 1
			nPosEquiv 	+= PIX_DIF_COLUNA_VALORES
		EndIf
		If cAliasQry->( FieldPos( aEquivale[nInc] ) ) > 0

			If ValType( cAliasQry->&( aEquivale[nInc] ) ) = "C"
		   		
		   		If aEquivale[nInc] == "CT1_DESC01"
		   		
		   				CT1->(dBSetOrder(1))
						If CT1->(dBSeek(xFilial("CT1") + Iif(cAliasQry->CT2_DC = "2",cAliasQry->CT2_CREDIT, cAliasQry->CT2_DEBITO)))
							cNomCon := CT1->CT1_DESC01
						Endif
						olReport:Say( olReport:Row(), nPosEquiv, Substr(cNomCon,1,21), oFont )
				 
						
				ElseIf aEquivale[nInc] == "CT2_DC"
						If Alltrim(cAliasQry->CT2_DC) = "1"
							olReport:Say( olReport:Row(), nPosEquiv, Padc(STR0021,22), oFont )	 //Debito
						Elseif Alltrim(cAliasQry->CT2_DC) = "2"
							olReport:Say( olReport:Row(), nPosEquiv, Padc(STR0022,22), oFont )	 //Credito
						Elseif Alltrim(cAliasQry->CT2_DC) = "3"
							olReport:Say( olReport:Row(), nPosEquiv, Padc(STR0023,22), oFont )	 //Partida dobrada
						Endif
				Else
						olReport:Say( Iif(olReport:Row() = 0, 415, olReport:Row()) , nPosEquiv, Padc(Substr( cAliasQry->&( aEquivale[nInc] ),1,21),22), oFont )
						if Len(cAliasQry->&( aEquivale[nInc] )) > 20
							nPosHis := nPosEquiv
		   					cConHis := Substr(cAliasQry->&( aEquivale[nInc] ), 21, 20)
		   				Endif
				Endif
				 
			Endif
			                              			
			If ValType( cAliasQry->&( aEquivale[nInc] ) ) = "D"
					olReport:Say( olReport:Row(), nPosEquiv, PADC(DtoC( cAliasQry->&( aEquivale[nInc] ) ),21),  oFont )
			Endif
			
			If ValType( cAliasQry->&( aEquivale[nInc] ) ) = "N"
			
					If aEquivale[nInc] == "CT2_VALOR" .and. nInc = 8
						If cAliasQry->CT2_DC = "1"
							olReport:Say( olReport:Row(), nPosEquiv, Transform( cAliasQry->&( aEquivale[nInc] ), cPictVal), oFont )
							nTotDeb 	+= cAliasQry->CT2_VALOR
						Elseif cAliasQry->CT2_DC = "2"
							olReport:Say( olReport:Row(), nPosEquiv + PIX_DIF_COLUNA_VALORES, Transform( cAliasQry->&( aEquivale[nInc] ), cPictVal), oFont )
							nTotCre		+= cAliasQry->CT2_VALOR
						Elseif cAliasQry->CT2_DC = "3"
							olReport:Say( olReport:Row(), nPosEquiv, Transform( cAliasQry->&( aEquivale[nInc] ), cPictVal), oFont )
							olReport:Say( olReport:Row(), nPosEquiv + PIX_DIF_COLUNA_VALORES, Transform( cAliasQry->&( aEquivale[nInc] ), cPictVal), oFont )
							nTotCre		+= cAliasQry->CT2_VALOR
							nTotDeb 	+= cAliasQry->CT2_VALOR
						Endif
					Endif
			 
				                             
			Endif
		EndIf
	Next

	If nPosHis > 0
	    olReport:SkipLine( 1 )
		olReport:Say( Iif(olReport:Row() = 0, 415, olReport:Row()) , nPosHis, cConHis, oFont )
	Endif
	
	olReport:SkipLine( 1 )

	DbSelectArea("cAliasQry")
	cAliasQry->( DbSkip() )
	
	If cAliasQry->CT2_NODIA <> cNumdoc
	   	fTotR077(olReport, STR0024, nTotDeb, nTotCre, nPag)
		cPag := 80
		nTotDeb := 0
		nTotCre := 0
	Endif
		
    nPag++					// Quantidade de registros por pagina
	nReg++				// Quantidade de registros impressos

	olReport:OnPageBreak( { || FCabr077( olReport, nCol, aColFin) } )
	If nPag > 55
		olReport:Line( olReport:Row(), PIX_EQUIVALENTE , olReport:Row(), 2700 )
		olReport:EndPage()
		nPag := 0
	EndIf
End

olReport:IncMeter()
cAliasQry->( DbCLoseArea() )

Return olReport

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FCabr077  ³ Autor ³ Totvs                 ³ Data | 06/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cabeçalho do relatorio.								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FCabr077(Expo1,ExpN1,ExpA1)  				                  ³±±
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
Static Function FCabr077( olReport, nCol, aColFin )

Local nInc			:= 0
Local nColPix		:= olReport:Col()+10
Local aVert			:= { olReport:Col()+ 5 , PIX_INICIAL_VALORES }
Local nIniDin		:= PIX_INICIAL_VALORES					// Pixel redimencionado dinamicamente
Local oFont 		:= TFont():New( "Courier New",, -08 )
Local oFont12 		:= TFont():New( "Courier New",, -12 )

//Local nLimitrofe	:= 4850
Local nTamPad		:= 0
Local nCharPCol		:= 30

nPagina := nPagina + 1							       											    						// Quantidade de caracteres por coluna
 
nCol := olReport:Col() + 10
                          
olReport:Say ( olReport:Row(), 1180, SUBSTR(SM0->M0_NOMECOM,1,30)   ,oFont12 )
olReport:SkipLine(2)
olReport:Say ( olReport:Row(), 1190, STR0010   ,oFont12 )
olReport:SkipLine(2) 																						//Documento de Contabilizacao
olReport:PrintText( STR0011 + " : " + Posicione("CW0", 1, xFilial("CW0") + cAliasQry->CT2_DIACTB, "CW0_DESC01"),olReport:Row()   ,1200)
olReport:SkipLine(1)
olReport:PrintText( STR0012 + "       : " + Strzero(nPagina,4,0), olReport:Row() + 35   , 2360)
olReport:SkipLine(1) 								//Numero da Pagina.
olReport:PrintText( STR0004 + " : " + dToC( MV_PAR01 ) + " - " + dToC( MV_PAR02 )  ,olReport:Row()   ,nColPix )						//Fecha Asiento
olReport:PrintText( STR0014 + " : " +dToC( dDatabase ), olReport:Row()  , 2360)
olReport:PrintText( STR0015 + " : " +cAliasQry->CTC_DOCHIS ,olReport:Row() + 35 , nColPix) 											//CONCEPTO
olReport:PrintText( STR0016 + "  : " +cAliasQry->CT2_LP ,olReport:Row(),  2360)//Num. Asiento
                                                                          
olReport:SkipLine( 2 )

// Primeira linha
nTamPad	:= Len( aColFin ) * nCharPCol

// Segunda linha
// Imprime as contas

nIniDin	:= PIX_INICIAL_VALORES

For nInc := 1 To Len( aColFin )
	olReport:Say( olReport:Row(), nIniDin, PadC( aColFin[nInc], 30 ), oFont )
	nIniDin += PIX_DIF_COLUNA_VALORES
	aAdd( aVert, nIniDin )
Next

olReport:Line( olReport:Row(), PIX_EQUIVALENTE , olReport:Row(), 2700 )
FR077Prnt( olReport, aVert )
olReport:SkipLine( 1 )
olReport:Line( olReport:Row(), PIX_EQUIVALENTE , olReport:Row(), 2700 )														// Imprime a linhas verticais e passa para proxima linha
olReport:SkipLine( 2 )

Return(olReport)

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FR077Prnt ³ Autor ³ Totvs                 ³ Data | 07/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime as linhas verticais e horizontais do relatorio      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FR077Prnt( ExpA1 )         				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 = Array com as colunas                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR077Prnt( olReport, aCol )
Local nInc 		:= 1
Local nLinPix   := 34

For nInc := 1 To Len( aCol )
	olReport:Box( olReport:Row(), aCol[nInc], olReport:Row()+nLinPix, aCol[nInc] ) 			// traco vertical
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fTotR077  ºAutor  ³Microsiga           º Data ³  05/25/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do total                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FTotR077(olReport, cDescPrt, nTotDeb_P, nTotCre_P, nPag)
  
	olReport:Line( olReport:Row(), PIX_EQUIVALENTE , olReport:Row(), 1800 )
  	olReport:Box( olReport:Row(), 1800 , olReport:Row() + 034, 2100 )
	olReport:Say( olReport:Row(), 1810	, cDescPrt, TFont():New( "Courier New",, -10 ) )
	olReport:Box( olReport:Row(), 2100 , olReport:Row() + 034, 2400 )
	olReport:Say( olReport:Row(), 2135	, Transform( nTotDeb_P, "@E 99,999,999,999.99"), TFont():New( "Courier New",, -08 ) )
	olReport:Box( olReport:Row(), 2400 , olReport:Row() + 034, 2700 )
	olReport:Say( olReport:Row(), 2434 , Transform( nTotCre_P, "@E 99,999,999,999.99"), TFont():New( "Courier New",, -08 ) )
	
	If nPag > 48
		olReport:Line( olReport:Row(), PIX_EQUIVALENTE , olReport:Row(), 2700 )
		olReport:EndPage()
		nPag := 0
	EndIf
         
	olReport:Line( olReport:Row(), PIX_EQUIVALENTE , olReport:Row(), 2700 )


	olReport:skipline( 6 )

	olReport:Line( olReport:Row(), 900  , olReport:Row(), 1200 )
	olReport:Line( olReport:Row(), 1500 , olReport:Row(), 1800 )
	olReport:Line( olReport:Row(), 2100 , olReport:Row(), 2400 )

	olReport:skipline( 3 )

	olReport:PrintText( STR0018, olReport:Row() + 10  , 900)
	olReport:PrintText( STR0019, olReport:Row(), 1500)
	olReport:PrintText( STR0020, olReport:Row(), 2100)
                                                        
	olReport:endpage()

Return()
