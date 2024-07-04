#include "RwMake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "atfr033a.ch"

#define PIX_DIF_COLUNA_VALORES		400		// Pixel inicial para impressao dos tracos das colunas dinamicas
#define PIX_INICIAL_VALORES			000		// Pixel para impressao do traco vertical
#define PIX_EQUIVALENTE				010		// Pixel inicial para impressao das colunas dinamicas
#define MASK_VALOR					"@E 99999999999.99"
#define MASK_TAXA					"@E 999999999.9999"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFR033a  º Autor ³ Totvs              º Data ³  14/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Detalhes del Saldo de la cuenta 34 Intangibles              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ATFR033a                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFR033a()
Local cPerg		:= "ATFR033A"
Local olReport

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ mv_par01 - Exercicio? - Ano do exercicio para emissao            ³
³ mv_par02 - Moeda                                                 ³
³ mv_par03 - Seleciona filiais? - Filiais para considerar no filtro³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

If FindFunction("TRepInUse") .And. TRepInUse()
	Pergunte(cPerg,.F.)
	olReport := ATFRelat(cPerg)
	olReport:SetParam(cPerg)
	olReport:PrintDialog()
EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ATFRelat  ³ Autor ³ Totvs                 ³ Data | 14/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Criação do objeto TReport para a impressão do relatorio.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ATFRelat( cPerg )           				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Perguntas dos parametros                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ATFRelat( cPerg )

Local clNomProg		:= FunName()
Local clTitulo 		:= STR0001 //"Libro de inventario y balances - Detalles del saldo de la cuenta 34 Intangibles"
Local clDesc   		:= STR0001 //"Libro de inventario y balances - Detalles del saldo de la cuenta 34 Intangibles"
Local olReport

olReport:=TReport():New(clNomProg,clTitulo,cPerg,{|olReport| ATFProc(olReport)},clDesc)
olReport:SetLandscape()					// Formato paisagem
olReport:oPage:nPaperSize	:= 8 		// Impressão em papel A3
olReport:lHeaderVisible 	:= .F. 		// Não imprime cabeçalho do protheus
olReport:lFooterVisible 	:= .F.		// Não imprime rodapé do protheus
olReport:lParamPage			:= .F.		// Não imprime pagina de parametros
olReport:DisableOrientation()           // Não permite mudar o formato de impressão para Vertical, somente landscape
olReport:SetEdit(.F.)                   // Não permite personilizar o relatório, desabilitando o botão <Personalizar>

//+----------------+
//|Define as fontes|
//+----------------+

Return olReport

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ATFProc   ³ Autor ³ Totvs                 ³ Data | 14/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressão do relatorio.								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ATFProc( ExpC1 )         				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Objeto tReport                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ATFProc( olReport )

Local nReg			:= 0 //Quantidade de registros impressos
Local nPag			:= 0 //Quantidade de paginas por pagina
Local nCol			:= 0
Local clSql			:= ""
Local aColAtv       := { STR0005, 		STR0008, 	             	STR0011, 	  STR0013, 		STR0014, 		 STR0017 } // "Fecha de" ## "Descripcion" ## "Tipo de" ##  "Valor" ## "Amortizacion" ## "Valor Neto"
Local aColAtv2      := { STR0006, 		STR0009, 	             	STR0010, 	  STR0018, 		STR0015, 		 STR0018 } // "Inicio de La" ## "Del" ## "Intangible " ##  "Contable Del" ## "Contable" ## "Contable Del"
Local aColAtv3      := { STR0007, 		STR0010, 	            	STR0012, 	  STR0010, 		STR0016, 		 STR0010 } // "Operación" ## "Intangible" ## " " ##  "Intangible" ## "Acumulada" ## "Intangible"
Local aEquivale 	:= { "N1_AQUISIC","N1_DESCRIC","TIPO","N3_VORIG1","ACUMULADO","LIQUIDO" }
Local aTotais		:= {}
Local nInc			:= 0
Local nPosEquiv		:= 0
Local nValor		:= 0
Local cStrFil		:= ""
Local oFont 		:= TFont():New( "Courier New",, -08 )
Local aVert			:= {}  //{ 5, 130, 250, PIX_INICIAL_VALORES }
Local nIniDin		:= PIX_INICIAL_VALORES					// Pixel redimencionado dinamicamente
Local nLimitrofe	:= 4850
Local aSelFil		:= {}
Local nRowStart		:= 0
Local nCpoVal       := ""
Local cMoeda        := '1'
Local nValOrig      := 0
Local cTipo         :=""
Private aFieldSM0	:= {"M0_CGC","M0_NOMECOM"}
Private aDatosEmp	:= IIf (cVersao <> "11" ,FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aFieldSM0),"")
Private cRUC		:= Trim(IIf (cVersao <> "11" ,aDatosEmp[1][2],SM0->M0_CGC))
Private cNom		:= Trim(IIf (cVersao <> "11" ,aDatosEmp[2][2],SM0->M0_NOMECOM))

If MV_PAR03 == 1
	aSelFil := AdmGetFil()

	If Len( aSelFil ) <= 0
		Return
	EndIf
EndIf

// Inicia o array totalizador com zero
aFill( aTotais, 0 )

clSql := " SELECT DISTINCT SN1.N1_FILIAL,SN1.N1_CBASE,SN1.N1_ITEM,SN1.N1_AQUISIC,SN1.N1_DESCRIC,SN3.N3_NODIA,SN3.N3_VORIG1,SN3.N3_VORIG2,SN3.N3_VORIG3,SN3.N3_VORIG4,SN3.N3_VORIG5, SN1.N1_STATUS,SN3.N3_CCONTAB,SN3.N3_VRCBAL1 "
clSql += " FROM " + RetSqlName( "SN1" ) + " AS SN1, "
clSql += RetSqlName( "SF1" ) + " AS SF1, "
clSql += RetSqlName( "CV3" ) + " AS CV3, "
clSql += RetSqlName( "SN3" ) + " AS SN3 "
clSql += " WHERE N1_FILIAL = F1_FILIAL "
// Filtro de filiais
If MV_PAR03 == 1
	For nInc := 1 To Len( aSelFil )
		cStrFil += "'" + aSelFil[nInc] + "'"

		If nInc < Len( aSelFil )
			cStrFil += ", "
		EndIf
	Next
	clSql += " AND N1_FILIAL IN ( " + cStrFil + " )  "
Else
	clSql += " AND N1_FILIAL = '" + xFilial( "SN1" ) + "' "
EndIf
clSql += " AND N1_NSERIE = F1_SERIE "
clSql += " AND N1_NFISCAL = F1_DOC  "
clSql += " AND N1_FORNEC = F1_FORNECE "
clSql += " AND N1_LOJA = F1_LOJA "
clSql += " AND N1_FILIAL = N3_FILIAL "
clSql += " AND N1_CBASE = N3_CBASE "
clSql += " AND N1_ITEM = N3_ITEM "
clSql += " AND SN1.N1_BAIXA = '        ' "
clSql += " AND SN1.N1_AQUISIC <= '" + STRZERO(MV_PAR01,4) + "1231' "
clSql += " AND CV3_FILIAL = F1_FILIAL "
clSql += " AND CV3_TABORI = 'SF1'  "
clSql += " AND CV3_RECORI = SF1.R_E_C_N_O_ "

If "MSSQL" $ Alltrim(Upper(TCGetDB()))
	clSql += " AND SUBSTRING(CV3_DEBITO,1,2) = '34' "
Else
	clSql += " AND SUBSTR(CV3_DEBITO,1,2) = '34' "
EndIf

If TcSrvType() == "AS/400"
	clSql += " AND SN1.@DELETED@ <> '*' "
	clSql += " AND SN3.@DELETED@ <> '*' "
	clSql += " AND CV3.@DELETED@ <> '*' "
	clSql += " AND SF1.@DELETED@ <> '*' "
Else
	clSql += " AND SN1.D_E_L_E_T_ <> '*' "
	clSql += " AND SN3.D_E_L_E_T_ <> '*' "
	clSql += " AND CV3.D_E_L_E_T_ <> '*' "
	clSql += " AND SF1.D_E_L_E_T_ <> '*' "
Endif

clSql := ChangeQuery( clSql  )
dbUseArea( .T., "TOPCONN", TcGenQry( ,, clSql ), "PER",.T.,.T.)

TCSetField( "PER", "N1_AQUISIC",	"D", 08, 0 )
TCSetField( "PER", "N3_VORIG1",		"N", GetSX3Cache("N3_VORIG1","X3_TAMANHO"), GetSX3Cache("N3_VORIG1","X3_DECIMAL") )

DbSelectArea( "PER" )
PER->( DbGoTop() )
If PER->( !Eof() )
	FCabR161( olReport, nCol, aColAtv, aColAtv2, aColAtv3) //Impressão do cabeçalho
	aTotais	:= FR460Array( aEquivale )
EndIf

// Determina o pixel vertical inicial
nRowStart		:= olReport:Row()

PER->(dbGoTop())
olReport:SetMeter( RecCount() )
cMoeda:=IIF(SUBSTR(MV_PAR02,2,1) $ '1/2/3/4/5',SUBSTR(MV_PAR02,2,2),'1')

While PER->(!Eof())
	If olReport:Cancel()
		Exit
	EndIf

	nPosEquiv := PIX_EQUIVALENTE
	aVert := {}
	nValOrig := 0

	For nInc := 1 To Len( aEquivale )
		If nInc > 1
			IF nInc==3
    			nPosEquiv 	+= PIX_DIF_COLUNA_VALORES+200
			ELSE
    			nPosEquiv 	+= PIX_DIF_COLUNA_VALORES
			ENDIF
		EndIf

		If PER->( FieldPos( aEquivale[nInc] ) ) > 0
			If ValType( PER->&( aEquivale[nInc] ) ) == "C"
				If Upper( aEquivale[nInc] ) == "TIPO"
    				olReport:Say( olReport:Row(), nPosEquiv+70, PER->&( aEquivale[nInc] ), oFont )
                ELSE
    				olReport:Say( olReport:Row(), nPosEquiv, PER->&( aEquivale[nInc] ), oFont )
    			ENDIF
			ElseIf ValType( PER->&( aEquivale[nInc] ) ) == "D"
				olReport:Say( olReport:Row(), nPosEquiv, DtoC( PER->&( aEquivale[nInc] ) ),  oFont )

			ElseIf ValType( PER->&( aEquivale[nInc] ) ) == "N"
				IF aEquivale[nInc]=='N3_VORIG1'
				   nCpoVal := 'N3_VORIG' + cMoeda
				   olReport:Say( olReport:Row(), nPosEquiv+100, Transform( PER->&( nCpoVal ), MASK_VALOR), oFont )
				   aTotais[nInc] += PER->&( nCpoVal )
				   nValOrig := PER->&( nCpoVal )
				Endif
			EndIf

		Else
			If Upper( aEquivale[nInc] ) == "TIPO"
				cTipo:=""
				IF PER->N1_STATUS=='0'
					cTipo:='03'
				ELSE
					cTipo:='01'
				Endif

				olReport:Say( olReport:Row(), nPosEquiv+200, cTipo, oFont )

			ElseIf Upper( aEquivale[nInc] ) == "ACUMULADO"

				nTotDepre:=BuscaDepre(PER->N1_FILIAL,PER->N1_CBASE,PER->N1_ITEM,cMoeda)
				olReport:Say( olReport:Row(), nPosEquiv+100, Transform( nTotDepre, MASK_VALOR), oFont )
				aTotais[nInc] += nTotDepre

			ElseIf Upper( aEquivale[nInc] ) == "LIQUIDO"

				nValor := nValOrig-nTotDepre
				olReport:Say( olReport:Row(), nPosEquiv+100, Transform( nValor, MASK_VALOR), oFont )
				aTotais[nInc] += nValor

			EndIf
		EndIf
	Next

	nIniDin	:= 0
	For nInc := 1 To Len( aTotais )
		IF nInc==2
		   nIniDin += 300
		   nIniDin += PIX_DIF_COLUNA_VALORES
		ELSE
    	   nIniDin += PIX_DIF_COLUNA_VALORES
		Endif
		aAdd( aVert, nIniDin )
	Next

	nLimitrofe := nIniDin
	olReport:Box(olReport:Row()+2,olReport:Col()-004, olReport:Row()+2, nLimitrofe )

	// Imprime a linhas verticais e passa para proxima linha
	FR161Prnt( olReport, aVert )
	olReport:SkipLine( 1 )

	olReport:OnPageBreak( { || FCabR161( olReport, nCol, aColAtv, aColAtv2, aColAtv3 ) } )
	If nPag > 80
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
	FTotR161( olReport, nCol, aTotais )
EndIf

If MV_PAR04 == 1
	IF MSGYESNO(STR0020,"")//"Generar archivo"
	   Processa({|| GerArq(AllTrim(MV_PAR05),"PER")},,STR0021) //"Generacion de archivo..."
	Endif
EndIf

PER->( DbCLoseArea() )

Return olReport

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FCabR161  ³ Autor ³ Totvs                 ³ Data | 06/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cabeçalho do relatorio.								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FCabR161(Expo1,ExpN1,ExpA1)  				                  ³±±
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
Static Function FCabR161( olReport, nCol, aColAtv, aColAtv2, aColAtv3 )
Local nInc			:= 0
Local nColPix		:= olReport:Col() + 10
Local aVert			:= {} //{ olReport:Col() + 5, PIX_INICIAL_VALORES }
Local nIniDin		:= PIX_INICIAL_VALORES					// Pixel redimencionado dinamicamente
Local oFont 		:= TFont():New( "Courier New",, -08 )
Local nLimitrofe	:= 4850
Local nTamPad		:= 0
Local nCharPCol		:= 16							// Quantidade de caracteres por coluna

nCol := olReport:Col() + 10

olReport:PrintText( STR0001,olReport:Row(),nColPix) // "Libro de inventario y balances - Detalles del saldo de la cuenta 34 Intangibles "
olReport:PrintText( STR0002 + STRZERO(MV_PAR01,4)	,olReport:Row()+35,nColPix) //"EJERCICIO: "
olReport:PrintText( STR0003 + AllTrim( cRUC)											,olReport:Row()+40,nColPix) //"RUC"
olReport:PrintText( STR0004 + AllTrim( Capital( cNom ) )						,olReport:Row()+45,nColPix) //"Apellidos y nombres, denominacion o razon social:  "
olReport:SkipLine( 2 )

// Primeira linha
nTamPad	:= Len( aColAtv ) * nCharPCol
nIniDin += ( PIX_DIF_COLUNA_VALORES * Len( aColAtv ) )
nIniDin += 300

aAdd( aVert, nIniDin )
nLimitrofe := nIniDin
olReport:Box(olReport:Row()-004,olReport:Col()-004, olReport:Row()+032, nLimitrofe )
FR161Prnt( olReport, aVert )													// Imprime a linhas verticais e passa para proxima linha
olReport:SkipLine( 1 )

// Segunda linha
// Imprime as contas
aVert := {}
nIniDin	:= PIX_INICIAL_VALORES

For nInc := 1 To Len( aColAtv )
	olReport:Say( olReport:Row(), nIniDin, PadC( aColAtv[nInc], 16 ), oFont )
	IF nInc == 2
       nIniDin +=300
    ENDIF
	nIniDin += PIX_DIF_COLUNA_VALORES
	aAdd( aVert, nIniDin )
Next

FR161Prnt( olReport, aVert )														// Imprime a linhas verticais e passa para proxima linha
olReport:SkipLine( 1 )

// Terceira linha
// Imprime as contas
aVert := {}
nIniDin	:= PIX_INICIAL_VALORES

For nInc := 1 To Len( aColAtv2 )
	olReport:Say( olReport:Row(), nIniDin, PadC( aColAtv2[nInc], 16 ), oFont )
	IF nInc == 2
       nIniDin +=300
    ENDIF
	nIniDin += PIX_DIF_COLUNA_VALORES
	aAdd( aVert, nIniDin )
Next

FR161Prnt( olReport, aVert )														// Imprime a linhas verticais e passa para proxima linha
olReport:SkipLine( 1 )

// Quarta linha
// Imprime as contas
aVert := {}
nIniDin	:= PIX_INICIAL_VALORES

For nInc := 1 To Len( aColAtv3 )
	olReport:Say( olReport:Row(), nIniDin, PadC( aColAtv3[nInc], 16 ), oFont )
	IF nInc == 2
       nIniDin +=300
    ENDIF
	nIniDin += PIX_DIF_COLUNA_VALORES
	aAdd( aVert, nIniDin )
Next

FR161Prnt( olReport, aVert )														// Imprime a linhas verticais e passa para proxima linha
olReport:SkipLine( 1 )

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FTotR161  ³ Autor ³ Totvs                 ³ Data | 06/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cabeçalho do relatorio.								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FTotR161(Expo1,ExpN1,ExpA1)  				                  ³±±
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
Static Function FTotR161( olReport, nCol, aTotais )
Local nInc			:= 0
Local nColPix		:= 10
Local aVert			:= { PIX_INICIAL_VALORES }
Local nIniDin		:= 0
Local nValPrnt		:= PIX_EQUIVALENTE
Local oFont 		:= TFont():New( "Courier New",, -08 )
Local nLimitrofe	:= 4850

// Segunda linha
olReport:Say( olReport:Row(), nColPix, STR0019, 			oFont )		// Totales

For nInc := 1 To Len( aTotais )
	If nInc > 1
		nValPrnt += PIX_INICIAL_VALORES
	EndIf

	If ValType( aTotais[nInc] ) == "N"
		olReport:Say( olReport:Row(), nIniDin+10 , Transform(aTotais[nInc], MASK_VALOR ), oFont )
	EndIf
    IF nInc == 2
       nIniDin += 300
    Endif
	nIniDin += PIX_DIF_COLUNA_VALORES
	aAdd( aVert, nIniDin )
Next

nLimitrofe := nIniDin

olReport:Box(olReport:Row()-004,olReport:Col()-004, olReport:Row()+031, nLimitrofe )

FR161Prnt( olReport, aVert )												// Imprime a linhas verticais e passa para proxima linha
olReport:SkipLine( 1 )
Return()


/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FR161Prnt ³ Autor ³ Totvs                 ³ Data | 07/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime as linhas verticais e horizontais do relatorio      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FR161Prnt( ExpA1 )         				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 = Array com as colunas                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR161Prnt( olReport, aCol )
Local nInc 		:= 1
Local nLinPix	:= 34

For nInc := 1 To Len( aCol )
   olReport:Box( olReport:Row(), aCol[nInc], olReport:Row()+nLinPix, aCol[nInc] ) 			// traco vertical
Next

Return


/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FR460Array³ Autor ³ Totvs                 ³ Data | 07/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica quais colunas tem totalizadores e retorna array    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FR460Array( ExpA1 )         				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 = Array com os campos                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR460Array( aEquivale )
Local aRet	:= {}
Local nInc	:= 0

If Select( "PER" ) > 0
	For nInc := 1 To Len( aEquivale )
		If PER->( FieldPos( aEquivale[nInc] ) ) > 0
			If ValType( PER->&( aEquivale[nInc] ) ) == "N"
				aAdd( aRet, 0 )
			Else
				aAdd( aRet, NIL )
			EndIf
		Else
			// Se foi atribuido variavel numerica, define 0
			If Upper( Left( aEquivale[nInc], 1 ) ) == "N"  .OR. aEquivale[nInc]=='ACUMULADO' .OR. aEquivale[nInc] =='LIQUIDO'
				aAdd( aRet, 0 )
			Else
				aAdd( aRet, NIL )
			EndIf
		EndIf
	Next
EndIf

Return aRet

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BuscaCorre³ Autor ³ Totvs                 ³ Data | Jan/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca Correlativo Caso em Branco                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³BuscaCorre(ExpA1,ExpA2,ExpA3,ExpA4,ExpA5 )                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 = Filial                                              ³±±
±±³          ³ExpA2 = Data                                                ³±±
±±³          ³ExpA3 = Valor                                               ³±±
±±³          ³ExpA4 = Numero                                              ³±±
±±³          ³ExpA5 = Ordem Recebimento                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BuscaDepre(cFilial1,cCbase,cItem,cMoeda)

Local nTotDepr:=0

cSql003 := ""
cSql003 += " SELECT SUM(N4_VLROC"+cMoeda+") TOTAL "
cSql003 += " FROM "+ RetSqlName("SN4") + " SN4, "+ RetSqlName("CV3") + " CV3 "
cSql003 += " WHERE SN4.N4_FILIAL = '" + cFilial1 + "' "
cSql003 += "   AND SN4.N4_CBASE  = '" + cCbase + "' "
cSql003 += "   AND SN4.N4_ITEM   = '" + cItem + "' "
cSql003 += "   AND SN4.N4_DATA <= '" + STRZERO(MV_PAR01,4) + "1231' "
cSql003 += "   AND SN4.D_E_L_E_T_ = ' ' "
cSql003 += "   AND SN4.N4_OCORR IN ('06') "
cSql003 += "   AND CV3_FILIAL = SN4.N4_FILIAL "
cSql003 += "   AND CV3_TABORI = 'SN4'  "
cSql003 += "   AND CV3_RECORI = SN4.R_E_C_N_O_ "
cSql003 += "   AND CV3.D_E_L_E_T_ = ' '  "
cSql003 += "   AND SUBSTRING(CV3.CV3_DEBITO,1,2)='34'  "
cAliasCor := GetNextAlias()
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql003 ), cAliasCor,.T.,.T.)
(cAliasCor)->(dBGotop())

IF ! EOF()
	nTotDepr := (cAliasCor)->TOTAL

ELSE
	(cAliasCor)->(DbCLoseArea())
	cSql003 := ""
	cSql003 += " SELECT SUM(N4_VLROC"+cMoeda+") TOTAL "
	cSql003 += " FROM "+ RetSqlName("SN4") + " SN4, "+ RetSqlName("CV3") + " CV3, "+ RetSqlName("SN3") + " SN3 "
	cSql003 += " WHERE SN4.N4_FILIAL = '" + cFilial1 + "' "
	cSql003 += "   AND SN4.N4_CBASE  = '" + cCbase + "' "
	cSql003 += "   AND SN4.N4_ITEM   = '" + cItem + "' "
	cSql003 += "   AND SN4.N4_DATA <= '" + STRZERO(MV_PAR01,4) + "1231' "
	cSql003 += "   AND SN4.D_E_L_E_T_ = ' ' "
	cSql003 += "   AND SN4.N4_OCORR IN ('06') "
	cSql003 += "   AND SN4.N4_FILIAL = SN3.N3_FILIAL "
	cSql003 += "   AND SN4.N4_CBASE  = SN3.N3_CBASE "
	cSql003 += "   AND SN4.N4_ITEM   = SN3.N3_ITEM "
	cSql003 += "   AND CV3_FILIAL = SN3.N3_FILIAL "
	cSql003 += "   AND CV3_TABORI = 'SN3'  "
	cSql003 += "   AND CV3_RECORI = SN3.R_E_C_N_O_ "
	cSql003 += "   AND CV3.D_E_L_E_T_ = ' '  "
	cSql003 += "   AND SUBSTRING(CV3.CV3_DEBITO,1,2) = '34'  "
	cAliasCor := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql003 ), cAliasCor,.T.,.T.)
	(cAliasCor)->(dBGotop())

	IF ! EOF()
		nTotDepr := (cAliasCor)->TOTAL
	ENDIF

ENDIF

(cAliasCor)->(DbCLoseArea())

Return(nTotDepr)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq   ³ Autor ³  Verónica Flores    ³ Data ³ 19.03.2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ 3.9 LIBRO DE INVENTARIOS Y BALANCES CUENTA 34 - INTANGIBLES³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir      - Directorio donde se guardará el archivo.       ³±±
±±³            ³ cAliasqry - Nombre del tabla temporal.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Peru                  - Arquivo Magnetico           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArq(cDir,cAliasqry)

Local nHdl		:= 0
Local cLin		:= ""
Local cSep		:= "|"
Local nCont		:= 0
Local cArq		:= ""
Local cDateFmt	:= SET(_SET_DATEFORMAT)

FOR nCont := LEN(ALLTRIM(cDir)) TO 1 STEP -1
	IF SUBSTR(cDir,nCont,1) == '\'
		cDir := Substr(cDir,1,nCont)
		EXIT
	ENDIF
NEXT

DBSelectArea(cAliasqry)
DBGOTOP()

cArq += "LE"                                  // Fijo  'LE'
cArq +=  AllTrim(cRUC)                        // RUC
cArq += ALLTRIM(STR(MV_PAR01))			      // Ano
cArq +=  "12"								  // Mes
cArq +=  "31"							      // Dia
cArq += "030900" 						      // Fijo '030900'
cArq += "01"                                  //Código de Oportunidad
cArq += "1"
cArq += "1"
cArq += "1"
cArq += "1"
cArq += ".TXT"                                // Extension

nHdl := fCreate(cDir+cArq)

If nHdl <= 0
	ApMsgStop(STR0022) //"Ocurrió un error al crear el archivo Txt."

Else
	SET(_SET_DATEFORMAT, "DD/MM/YYYY")
	DO WHILE (cAliasqry)->(!Eof())
		cLin := ""
		//01 - Periodo
		cLin += StrZero(MV_PAR01,4) +"1231"
		cLin += cSep

		//02 - Código Único de la Operación (CUO)
		cLin += AllTrim((cAliasqry)->N3_NODIA)
		cLin += cSep

		//03 - Número correlativo del asiento contable
		cLin += "M" + Right(AllTrim((cAliasqry)->N3_NODIA),9)
		cLin += cSep

		//04 - Fecha de inicio de la operación
		cLin += DTOC((cAliasqry)->N1_AQUISIC)
		cLin += cSep

		//05 - Código de la cuenta contable
		cLin += AllTrim((cAliasqry)->N3_CCONTAB)
		cLin += cSep

		//06 - Descripción del intangible
		cLin += ALLTrim((cAliasqry)->N1_DESCRIC)
		cLin += cSep

		//07 - Valor contable del intangible
		cLin += ALLTrim(STR((cAliasqry)->N3_VORIG1,15,2))
		cLin += cSep

		//08 - Amortización contable acumulada
		cLin += ALLTrim(STR((cAliasqry)->N3_VRCBAL1,15,2))
		cLin += cSep

		//09 - Indica el estado de la operación
		cLin += "1"
		cLin += cSep

		cLin += chr(13)+chr(10)
		fWrite(nHdl,cLin)
		dbSelectArea(cAliasqry)
		dbSkip()
	EndDo

	SET(_SET_DATEFORMAT,cDateFmt)
	fClose(nHdl)
	MsgAlert(STR0023,"") //"Archivo Txt generado con éxito."

EndIf

Return Nil
