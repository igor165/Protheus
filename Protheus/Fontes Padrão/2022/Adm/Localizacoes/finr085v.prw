#include "RwMake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "FINR085V.ch"

#define PIX_DIF_COLUNA_VALORES			275		// Pixel inicial para impressao dos tracos das colunas dinamicas
#define PIX_INICIAL_VALORES				470		// Pixel para impressao do traco vertical
#define PIX_EQUIVALENTE				  	340		// Pixel inicial para impressao das colunas dinamicas

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINR085   º Autor ³ Totvs              º Data ³  06/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Certificado de Retenção do Imposto de Renda - VENEZUELA     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FINR085                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±³gSantacruz³DMINA-2452³Cambios realizados por Cesar Butista:Solo formato³±±
±±³          ³          ³ A4 para formato Legal.    Se desactiva la pre-- ³±±
±±³          ³          ³ gunta del Tipo formato, solo se dejo activado el³±±
±±³          ³          ³ formato Legal u Oficio. (Venezuela)             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINR085V()

Local olReport

Private cPerg   := "FI085V"
Private dFecIni	:=ctod("  /  /  ")
Private dFecFin	:=ctod("  /  /  ")
Private cProvIni:=''
Private cProvFin:=''

If TRepInUse()

	olReport := FINR085vA4(cPerg)
	olReport:SetParam(cPerg)
	olReport:PrintDialog()
	
EndIf
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINR085vA4  ³ Autor ³ Jose Lucas         ³ Data | 18/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressão do relatorio Comprovante de IVA no formato A4.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINR085vA4(cPerg)           				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Perguntas dos parametros.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINR085vA4(cPerg)
Local clNomProg		:= FunName()
Local clTitulo 		:= STR0001 // "COMPROBANTE DE RETENCIÓN DEL IMPUESTO SOBRE LA RENTA"
Local clDesc   		:= STR0001 // "COMPROBANTE DE RETENCIÓN DEL IMPUESTO SOBRE LA RENTA"
Local olReport
Local lLandScape    := .T.

olReport:=TReport():New(clNomProg,clTitulo,,{|olReport| FINProcxA4(olReport)},clDesc,lLandScape)
olReport:SetLandscape()					// Formato paisagem
olReport:oPage:nPaperSize	:= 5 		// Impressão em papel A4 - LandScape 9=a4,1=Carta,5=Oficio,8=A3
olReport:lHeaderVisible 	:= .F. 		// Não imprime cabeçalho do protheus
olReport:lFooterVisible 	:= .F.		// Não imprime rodapé do protheus
olReport:lParamPage			:= .F.		// Não imprime pagina de parametros
olReport:DisableOrientation()           // Não permite mudar o formato de impressão para Vertical, somente landscape
olReport:SetEdit(.F.)                   // Não permite personilizar o relatório, desabilitando o botão <Personalizar>
Return olReport

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FINProcxA4 ³ Autor ³ Totvs                 ³ Data | 06/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressão do relatorio.								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINProcxA4( ExpC1 )         				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Objeto tReport                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FINProcxA4( olReport )

Local nReg			:= 0 //Quanti0dade de registros impressos
Local nPag			:= 0 //Quantidade de paginas por pagina
Local nCol			:= 0
Local clSql			:= ""
Local aEquivale 	:= { 0, 0, 0, 0, 0}
Local nTotalCols	:= Len( aEquivale )

Local aTotais	 := Array( nTotalCols )

Local oFont8 	 := TFont():New( "Courier New",, -08 )
Local oFont10 	 := TFont():New( "Courier New",, -10 )
Local cFornece	 := ""

Local nRowStart	 := 0
Local lFirstPage := .T.
Local aDescRet   := {}
Local cNFiscalOri := ""
Local nCount 	 := 0
Local cDescricao := ""
Local cDescConcepto := ""
Local nPosIni    := 0
Local nPosFim    := 0
Local nPagina    := 0


Pergunte(cPerg,.F.)
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ mv_par01 - Data inicial? - Data inicial dos Certificados         ³
³ mv_par02 - Data Final?   - Data final dos Certificados           ³
³ mv_par03 - Fornecedor?   - Fornec inicial dos Certificados	   ³
³ mv_par04 - Fornecedor?   - Fornec final dos Certificados         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

dFecIni	:=MV_PAR01 //Fecha inicial basada en los movimientos de la tabla SFE
dFecFin	:=MV_PAR02 //Fecha final basada en los movimientos de la tabla SFE
cProvIni:=MV_PAR03 //Proveedor inicial el cual considera en los movimientos de la tabla SFE
cProvFin:=MV_PAR04 //Proveedor final considerado en los movimientos de la tabla SFE// Inicia o array totalizador com zero

aFill( aTotais, 0 )

clSql := "SELECT "
clSql += " FE_ESPECIE, "
clSql += " FE_FORNECE, "
clSql += " FE_LOJA, "
clSql += " FE_NROCERT, "
clSql += " FE_EMISSAO, "
clSql += " F1_EMISSAO, "
clSql += " FE_NFISCAL, "
clSql += " FE_SERIE, "
clSql += " F1_VALBRUT, "
clSql += " F1_VALMERC, "
clSql += " F1_VALIMP1, "
clSql += " FE_VALBASE, "
clSql += " FE_TIPO, "
clSql += " FE_ALIQ, "
clSql += " FE_RETENC, "
clSql += " FE_DEDUC, "
clSql += " A2_NOME, "
clSql += " A2_CGC, "
clSql += " A2_END, "
clSql += " A2_NR_END, "
clSql += " A2_MUN, "
clSql += " A2_TEL, "
clSql += " A2_ESTADO, "
clSql += " A2_TIPO, "
clSql += " FE_CONCEPT, "
clSql += " SFE.R_E_C_N_O_  "
clSql += " FROM " + RetSqlName("SFE") + " SFE, "
clSql += RetSqlName("SA2") + ", "
clSql += RetSqlName("SF1")
clSql += " WHERE FE_FILIAL = '" + xFilial("SFE") + "'"
clSql += " and FE_EMISSAO >= '" + Dtos(dFecIni) + "'"
If !Empty(dFecFin)
	clSql += " and FE_EMISSAO <= '" + Dtos(dFecFin) + "'"
Endif
clSql += " and FE_FORNECE 		>= '" + cProvIni + "'"
clSql += " and FE_FORNECE 		<= '" + cProvFin + "'"
clSql += " and FE_FORNECE 		= 	A2_COD 				"
clSql += " and FE_NFISCAL 		= 	F1_DOC      		"
clSql += " and FE_FORNECE 		= 	F1_FORNECE  		"
clSql += " and FE_SERIE   		= 	F1_SERIE    		"
clSql += " and FE_TIPO	  		= 	'R'         		"
clSql += " UNION "
clSql += " SELECT "
clSql += " FE_ESPECIE, "
clSql += " FE_FORNECE, "
clSql += " FE_LOJA, "
clSql += " FE_NROCERT, "
clSql += " FE_EMISSAO, "
clSql += " F2_EMISSAO, "
clSql += " FE_NFISCAL, "
clSql += " FE_SERIE, "
clSql += " F2_VALBRUT, "
clSql += " F2_VALMERC, "
clSql += " F2_VALIMP1, "
clSql += " FE_VALBASE, "
clSql += " FE_TIPO, "
clSql += " FE_ALIQ, "
clSql += " FE_RETENC, "
clSql += " FE_DEDUC, "
clSql += " A2_NOME, "
clSql += " A2_CGC, "
clSql += " A2_END, "
clSql += " A2_NR_END, "
clSql += " A2_MUN, "
clSql += " A2_TEL, "
clSql += " A2_ESTADO, "
clSql += " A2_TIPO, "
clSql += " FE_CONCEPT, "
clSql += " SFE.R_E_C_N_O_  "
clSql += " FROM " + RetSqlName("SFE") + " SFE, "
clSql += RetSqlName("SA2") + ", "
clSql += RetSqlName("SF2")
clSql += " WHERE FE_FILIAL = '" + xFilial("SFE") + "'"
clSql += " and FE_EMISSAO >= '" + Dtos(dFecIni) + "'"
If !Empty(dFecFin)
	clSql += " and FE_EMISSAO <= '" + Dtos(dFecFin) + "'"
Endif
clSql += " and FE_FORNECE 		>= '" + cProvIni + "'"
clSql += " and FE_FORNECE 		<= '" + cProvFin + "'"
clSql += " and FE_FORNECE 		= 	A2_COD 				"
clSql += " and FE_NFISCAL 		= 	F2_DOC      		"
clSql += " and FE_FORNECE 		= 	F2_CLIENTE  		"
clSql += " and FE_SERIE   		= 	F2_SERIE    		"
clSql += " and FE_TIPO	  		= 	'R'         		"

If TcSrvType() == "AS/400"
	clSql += "and @SFE.DELETED@ <> '*' "
Else
	clSql += "and SFE.D_E_L_E_T_ <> '*' "
Endif

clSql += " ORDER BY 2,3,4  "

clSql := ChangeQuery( clSql  )
dbUseArea( .T., "TOPCONN", TcGenQry( ,, clSql ), "PER",.T.,.T.)

TCSetField("PER", "FE_EMISSAO","D", 08, 0 )
TCSetField("PER", "F1_EMISSAO","D", 08, 0 )
TCSetField("PER", "F1_VALBRUT","N", TamSX3("F1_VALBRUT")[1], TamSX3("F1_VALBRUT")[2])
TCSetField("PER", "F1_VALMERC","N", TamSX3("F1_VALMERC")[1], TamSX3("F1_VALMERC")[2])
TCSetField("PER", "FE_VALBASE","N", TamSX3("FE_VALBASE")[1], TamSX3("FE_VALBASE")[2])
TCSetField("PER", "FE_ALIQ"	  ,"N", TamSX3("FE_ALIQ")[1]   , TamSX3("FE_ALIQ")[2])
TCSetField("PER", "FE_RETENC" ,"N", TamSX3("FE_RETENC")[1] , TamSX3("FE_RETENC")[2])
TCSetField("PER", "FE_DEDUC"  ,"N", TamSX3("FE_DEDUC")[1]  , TamSX3("FE_DEDUC")[2])



DbSelectArea( "PER" )
PER->( dbGoTop() )
While !PER->(Eof())

	cFornece := PER->FE_FORNECE

	While !PER->(Eof()) .and. PER->FE_FORNECE == cFornece

		cNroCert := PER->FE_NROCERT
		nPagina ++

		//Quebra por Numero de Certificado
		While !PER->(Eof()) .and. PER->FE_FORNECE == cFornece .and. PER->FE_NROCERT == cNroCert

			If olReport:Cancel()
				Exit
			EndIf

    		If lFirstPage
				FCabR085A4( olReport,nPagina ) //Impressão do cabeçalho
				lFirstPage := .F.
			EndIf

        	//Obter numero da Nota Fiscal Original quando NCP o NDC
            cNFiscalOri := R085PgNC()

			//Buscar descrição do conceito de retenção do array aDescRet
			cDescricao := R085PgDesc(PER->FE_CONCEPT,aDescRet)

			//Buscar o codigo ou sigla do impostos na tabela CCR.
			cIDImposto := R085IDImpos(PER->FE_CONCEPT)

			//Imprimir linha detalhe
			olReport:Say( olReport:Row(), olReport:Col()+0010, " ",	oFont8 )
			olReport:Say( olReport:Row(), olReport:Col()+0120, Iif(Empty(PER->FE_EMISSAO)," ",DtoC(PER->FE_EMISSAO)), 						oFont8 )//FECHA CONTAB
			olReport:Say( olReport:Row(), olReport:Col()+0330, Iif(Empty(PER->FE_NFISCAL)," ", Transform(PER->FE_NFISCAL,	"@!")),			oFont8 )//NRO FACTURA

			olReport:Say( olReport:Row(), olReport:Col()+0580, Iif(Empty(PER->FE_NROCERT)," ", Transform(PER->FE_NROCERT,"@R 9999-99-99999999")),oFont8 )//COMP.INTERNO

			If !Empty(cNFiscalOri)
				olReport:Say( olReport:Row(), olReport:Col()+0770, Iif(Empty(cNFiscalOri)," ", Transform(AllTrim(cNFiscalOri),"@!")),	oFont8 )//FATCURA AFECTADA
   			EndIf


			For nCount := 1 To MlCount(RTrim(cDescricao),45)
				nPosIni := If(nCount==1,1,If(nCount==2,46,If(nCount==6,211,256)))
				nPosFim := If(nCount==1,45,nCount*45)
                cDescConcepto := Subs(cDescricao,nPosIni,nPosFim)
 				If Empty(cDescConcepto)
			 		Exit
				Endif

 				If nCount > 1
					olReport:SkipLine( 1 )
				EndIf

				olReport:Say( olReport:Row(), olReport:Col()+1180, Iif(Empty(cDescConcepto)	 ," ", PadR(LTrim(cDescConcepto), 85 ))	,oFont8 )//DESCRIPCION

            	If nCount == 1	//Imprimir demais colunas
					olReport:Say( olReport:Row(), olReport:Col()+1830, Transform(PER->F1_VALBRUT	 ,	"@E 999,999,999.99")		,oFont8 )
					olReport:Say( olReport:Row(), olReport:Col()+2060, Transform(Round(PER->F1_VALMERC + PER->F1_VALIMP1,2) ,	"@E 999,999,999.99")		,oFont8 )
					olReport:Say( olReport:Row(), olReport:Col()+2320, Transform(PER->FE_VALBASE ,	"@E 999,999,999.99")		,oFont8 )
					olReport:Say( olReport:Row(), olReport:Col()+2550, Transform(PER->FE_ALIQ	 ,	"@E 999.99")		,oFont8 )//%
					olReport:Say( olReport:Row(), olReport:Col()+2720, Transform(PER->FE_RETENC	 ,	"@E 999,999,999.99")		,oFont8 )//MONTO RETENIDO
		
					// Ajusta os totalizadores
					If PER->FE_ESPECIE $ "NF |NDP"
						aTotais[1] += Round(PER->F1_VALMERC + PER->F1_VALIMP1,2) 
						aTotais[2] += PER->FE_VALBASE
						aTotais[3] += PER->FE_RETENC
					ElseIf AllTrim(PER->FE_ESPECIE) $ "NCP"
						If aTotais[1] > 0.00
							aTotais[1] -= PER->F1_VALBRUT
							aTotais[2] -= PER->FE_VALBASE
							aTotais[3] -= PER->FE_RETENC
						Else
							aTotais[1] += PER->F1_VALBRUT
							aTotais[2] += PER->FE_VALBASE
							aTotais[3] += PER->FE_RETENC
						EndIf
					EndIf
		        EndIF
		    Next
 			olReport:SkipLine( 1 )

			olReport:OnPageBreak( { || FCabR085A4( olReport, nPagina ) } )
			If nPag	> 55
				nPag  := 0
				olReport:EndPage()
				olReport:SetRow( nRowStart )
			EndIf
			nReg++
  			PER->( dbSkip() )
	    End
	    If nReg > 0
			FTotR085A4( olReport, nCol, aTotais )

				olReport:SkipLine( 30 )

				olReport:Say( olReport:Row()+ 50, olReport:Col()+1310, "______________________________________",	oFont10 )
				olReport:Say( olReport:Row()+100, olReport:Col()+1350, "Firma y Sello Agente De Retención",	oFont10 )
				olReport:Say( olReport:Row()+150, olReport:Col()+1440, "R.I.F. N° "+ Iif(Empty(SM0->M0_CGC)," ", PadR(SM0->M0_CGC, 14)),	oFont10 )


			olReport:EndPage()
			olReport:setRow( nRowStart )
			nPag++				// Quantidade de registros por pagina
			nReg := 0
			
			
		EndIf
	End
	olReport:IncMeter()
End
PER->( dbCloseArea() )
Return olReport






/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R085PgDesc ³ Autor ³ Jose Lucas           ³ Data | 24/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retornar a descricao do conceito de retencao.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpC1 := R085PgDesc( ExpC2 )				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC2 = Codigo do Conceito.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R085PgDesc(cConceito)
Local aSavArea := GetArea()
Local cDescricao := STR0039	//"Atenção: Conceito não cadastrado na tabela CCR-Conceitos."

CCR->(dbSetOrder(1))
If CCR->(dbSeek(xFilial("CCR")+cConceito))
	cDescricao := CCR->CCR_DESCR
EndIf
RestArea(aSavArea)
Return cDescricao

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R085IDImpos ³ Autor ³ Jose Lucas          ³ Data | 24/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retornar a descricao do ID do Imposto.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpC1 := R085IDImpos( ExpC2 )			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC2 = Codigo do Conceito.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R085IDImpos(cConceito)
Local aSavArea   := GetArea()
Local cIDImposto := "CPJD11"

CCR->(dbSetOrder(1))
If CCR->(dbSeek(xFilial("CCR")+cConceito))
	If CCR->(FieldPos("FE_IDIMPOS")) > 0
		cIDImposto := CCR->CCR_IDIMPOS
	EndIf
EndIf
RestArea(aSavArea)
Return cIDImposto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ R085PgNC  ºAutor  ³Jose Lucas         º Data ³  10/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retornar o numero da NF Original quando documento for NCP  º±±
±±º          ³ ou NDP (Nota de Credito oU Debito de Proveedor).           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINR085V                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R085PgNC()
LOCAL aSavArea := GetArea()
LOCAL cNFOrig  := ""

//Obter numero da Nota Fiscal Original quando NCP o NDC
If  AllTriM(PER->FE_ESPECIE) $ "NCP"
	SD2->(dbSetOrder(3))
	If SD2->(dbSeek(xFilial("SD2")+PER->FE_NFISCAL+PER->FE_SERIE+PER->FE_FORNECE+PER->FE_LOJA))
	 	While SD2->(!Eof()) .and. SD2->D2_FILIAL == xFilial("SD2") .and.;
	 		  SD2->D2_DOC == PER->FE_NFISCAL .and. SD2->D2_SERIE == PER->FE_SERIE .and.;
	 	  	  SD2->D2_CLIENTE == PER->FE_FORNECE .and. SD2->D2_LOJA == PER->FE_LOJA

	  		If !Empty(SD2->D2_NFORI) .and. Empty(cNFOrig)
	  			cNFOrig := SD2->D2_NFORI	
			EndIf
			SD2->(dbSkip())
		End
	EndIf
ElseIf  AllTriM(PER->FE_ESPECIE) $ "NDP"
	SD1->(dbSetOrder(1))
	If SD1->(dbSeek(xFilial("SD1")+PER->FE_NFISCAL+PER->FE_SERIE+PER->FE_FORNECE+PER->FE_LOJA))
	 	While SD1->(!Eof()) .and. SD2->D2_FILIAL == xFilial("SD2") .and.;
		 	  SD1->D1_DOC == PER->FE_NFISCAL .and. SD1->D1_SERIE == PER->FE_SERIE .and.;
	 	  	  SD1->D1_FORNECE == PER->FE_FORNECE .and. SD1->D1_LOJA == PER->FE_LOJA

	  		If !Empty(SD1->D1_NFORI) .and. Empty(cNFOrig)
	  			cNFOrig := SD1->D1_NFORI	
			EndIf
			SD1->(dbSkip())
		End
    EndIf
EndIf
RestArea(aSavArea)
Return cNFOrig


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FCabR085A4³ Autor ³ Jose Lucas            ³ Data | 19/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cabeçalho do relatorio no formato A4.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FCabR085A4(Expo1,ExpN1,ExpA1).			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 = Objeto tReport                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FCabR085A4( olReport, nPagina )
Local oFont9 		:= TFont():New( "Courier New",, -09 )
Local oFont10 		:= TFont():New( "Courier New",, -10 )
Local oFont10B 		:= TFont():New( "Courier New",, -10,,.T. )
Local oFont14B 		:= TFont():New( "Courier New",, -14,,.T. )

olReport:Say( olReport:Row()+ 40, olReport:Col()+1050, SM0->M0_NOMECOM, oFont14B )

olReport:Say( olReport:Row()+ 40, olReport:Col()+2330, "Impreso:", oFont9 )
olReport:Say( olReport:Row()+ 40, olReport:Col()+2600, Transform(dDatabase,"@D"), oFont9 )
olReport:SkipLine( 1 )

olReport:Say( olReport:Row()+ 40, olReport:Col()+1050, "R.I.F. N° " + SM0->M0_CGC, oFont14B )

olReport:Say( olReport:Row()+ 40, olReport:Col()+2330, "N° DE COMPROBANTE:" , oFont9 )
olReport:Say( olReport:Row()+ 40, olReport:Col()+2680, Iif(Empty(PER->FE_NROCERT), " ", Padr(Transform(PER->FE_NROCERT,"@R 9999-99-99999999"),16)), oFont9 )
olReport:SkipLine( 2 )

olReport:Say( olReport:Row()+ 40, olReport:Col()+1050, "COMPROBANTE DE RETENCIÓN I.S.L.R.", oFont10B )
olReport:Say( olReport:Row()+ 40, olReport:Col()+2400, "Pg.#", oFont9 )
olReport:Say( olReport:Row()+ 40, olReport:Col()+2600, Transform(nPagina,"@E 9999"), oFont9 )
olReport:Line(olReport:Row()+ 80, olReport:Col()+1050, olReport:Row()+80, olReport:Col()+1585)  //Traço
olReport:SkipLine( 1 )

//Primeiro Box (Esquerda)
olReport:Box(olReport:Row()+070, olReport:Col()+100, olReport:Row()+570, olReport:Col()+1520 )

//Segundo Box (Direita)
olReport:Box(olReport:Row()+070, olReport:Col()+1550, olReport:Row()+570, olReport:Col()+2950 )

//Impressão dos dados do cabecalho do 1o. box à esquerda e 2o. box a direita.
olReport:Say( olReport:Row()+120, olReport:Col()+0130, "DATOS DEL AGENTE DE RETENCION",	oFont10B )
olReport:Line(olReport:Row()+160, olReport:Col()+0130, olReport:Row()+160, olReport:Col()+0650)  	//Traço

olReport:Say( olReport:Row()+120, olReport:Col()+1580, "DATOS DEL BENEFICIARIO", oFont10B )
olReport:Line(olReport:Row()+160, olReport:Col()+1580, olReport:Row()+160, olReport:Col()+1980)  	//Traço

olReport:Say( olReport:Row()+210, olReport:Col()+0130, "Nombre o Razón Social",	oFont10B )

olReport:Say( olReport:Row()+210, olReport:Col()+0620, Iif(Empty(SM0->M0_NOMECOM)," ", PadR(SM0->M0_NOMECOM, 40)), oFont10 )
olReport:Say( olReport:Row()+210, olReport:Col()+1580, "Nombre o Razón Social",	oFont10B )

olReport:Say( olReport:Row()+210, olReport:Col()+2050, Iif(Empty(PER->A2_NOME)," ", PadR(PER->A2_NOME, 40)), oFont10 )

olReport:Say( olReport:Row()+270, olReport:Col()+0130, "Número de R.I.F./N.I.T.:", oFont10B )
olReport:Say( olReport:Row()+270, olReport:Col()+0620, Iif(Empty(SM0->M0_CGC)," ", PadR(SM0->M0_CGC, 14)), oFont10 )
olReport:Say( olReport:Row()+270, olReport:Col()+1580, "Número de R.I.F./N.I.T.:",	oFont10B )
olReport:Say( olReport:Row()+270, olReport:Col()+2050, Iif(Empty(PER->A2_CGC)," ", PadR(PER->A2_CGC, 14)), oFont10 )

olReport:Say( olReport:Row()+330, olReport:Col()+0130, "Dirección:", oFont10B )
olReport:Say( olReport:Row()+330, olReport:Col()+0620, Iif(Empty(Subs(SM0->M0_ENDCOB,1,40))," ", PadR(Subs(SM0->M0_ENDCOB,1,40), 40)), oFont10 )
olReport:Say( olReport:Row()+330, olReport:Col()+1580, "Dirección:", oFont10B )
olReport:Say( olReport:Row()+330, olReport:Col()+2050, Iif(Empty(Subs(PER->A2_END+" "+PER->A2_NR_END,1,40))," ", PadR(Subs(PER->A2_END+" "+PER->A2_NR_END,1,40), 40)), oFont10 )

olReport:Say( olReport:Row()+370, olReport:Col()+0620, Iif(Empty(Subs(SM0->M0_ENDCOB,41,40))," ", PadR(Subs(SM0->M0_ENDCOB,41,40), 20)), oFont10 )
olReport:Say( olReport:Row()+370, olReport:Col()+2050, Iif(Empty(Subs(PER->A2_END+" "+PER->A2_NR_END,41,40))," ", PadR(Subs(PER->A2_END+" "+PER->A2_NR_END,41,40), 40)), oFont10 )

olReport:Say( olReport:Row()+420, olReport:Col()+0620, Iif(Empty(Subs(SM0->M0_CIDCOB+" "+SM0->M0_ESTCOB,01,40))," ", PadR(Subs(SM0->M0_CIDCOB+" "+SM0->M0_ESTCOB,01,40), 40)), oFont10 )
olReport:Say( olReport:Row()+420, olReport:Col()+2050, Iif(Empty(Subs(PER->A2_MUN+" "+PER->A2_ESTADO,01,40))," ", PadR(Subs(PER->A2_MUN+" "+PER->A2_ESTADO,01,40), 40)), oFont10 )

olReport:Say( olReport:Row()+460, olReport:Col()+0130, "Teléfono:",	oFont10B )
olReport:Say( olReport:Row()+460, olReport:Col()+0620, Iif(Empty(SM0->M0_TEL) 	," ", Transform(SM0->M0_TEL,"@R (999) 999-9999")), oFont10 )

olReport:Say( olReport:Row()+510, olReport:Col()+0130, "Ejercicio Físcal del:",	oFont10B )
olReport:Say( olReport:Row()+510, olReport:Col()+0620, DTOC(dFecIni) + " al " + DTOC(dFecFin), oFont10 )
olReport:Say( olReport:Row()+510, olReport:Col()+1580, "Teléfono:",	oFont10B )
olReport:Say( olReport:Row()+510, olReport:Col()+2050, Iif(Empty(PER->A2_TEL) 	," ", Transform(PER->A2_TEL,"@R (999) 999-9999")), oFont10 )

olReport:Say( olReport:Row()+570, olReport:Col()+0130, "DATOS DEL MONTO RETENIDO Y CONCEPTO",	oFont10B )

//Terceiro Box (Abaixo)
olReport:Box(olReport:Row()+650, olReport:Col()+100, olReport:Row()+730, olReport:Col()+2950 )
olReport :SkipLine( 1 )

//Impressão da 2a. linha do título
olReport:Say( olReport:Row()+620, olReport:Col()+0160, "Fecha"		, oFont9 )   //"Data de"
olReport:Say( olReport:Row()+620, olReport:Col()+1850, "Valor a ser"	, oFont9 )   //" Quantidade objeto"
olReport:Say( olReport:Row()+620, olReport:Col()+2100, "Monto"	, oFont9 )   //"Quantidade"
olReport:Say( olReport:Row()+620, olReport:Col()+2350, "Base"	, oFont9 )   //" Quantidade objeto"

//Impressão da 3a. linha do título
olReport:Say( olReport:Row()+650, olReport:Col()+0120, "Documento"    , oFont9 )   //"Documento"
olReport:Say( olReport:Row()+650, olReport:Col()+0330, "Nro. Docto.", oFont9 )   //"Nro Documento"
olReport:Say( olReport:Row()+650, olReport:Col()+0580, "Comp.Interno" , oFont9 )   //"Comp. Interno"
olReport:Say( olReport:Row()+650, olReport:Col()+0850, "Docto Afectado"	  , oFont9 )   //"Documento Afetado"
olReport:Say( olReport:Row()+650, olReport:Col()+1230, "Concepto"		  , oFont9 )   //"Compra"
olReport:Say( olReport:Row()+650, olReport:Col()+1850, "Abonado" , oFont9 )   //"de Retencion"
olReport:Say( olReport:Row()+650, olReport:Col()+2100, "Original"	  , oFont9 )   //"Sustraido"
olReport:Say( olReport:Row()+650, olReport:Col()+2350, "Imponible"  , oFont9 )   //"ID Imposto"
olReport:Say( olReport:Row()+650, olReport:Col()+2570, "Porc."			  , oFont9 )   //"%"
olReport:Say( olReport:Row()+650, olReport:Col()+2700, "Monto Retenido"	  , oFont9 )   //"Monto Retido"
olReport:SkipLine( 25 )
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FTotR085A4  ³ Autor ³ Jose Lucas         ³ Data | 19/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprimir linhas de totais do relatorio no formato A4.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FTotR085A4(Expo1,ExpN1,ExpA1)			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto tReport                                     ³±±
±±³          ³ ExpN1 = Posição da coluna de impressão                     ³±±
±±³          ³ ExpA1 = Array TOTAIS DAS COLUNAS                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FTotR085A4( olReport, nCol, aTotais )
//Local nColPix		:= olReport:Col() + 10
Local oFont8 		:= TFont():New( "Courier New",, -08 )
Local oFont10B 		:= TFont():New( "Courier New",, -10,,.T. )

nCol := olReport:Col() + 10
olReport:SkipLine( 1 )

// Segunda linha
olReport:Line(olReport:Row(), olReport:Col()+0850, olReport:Row(), olReport:Col()+2950)  	//Traço
olReport:Say( olReport:Row()+10, olReport:Col()+0850, "Totales:", oFont10B ) // "Totais"
olReport:Say( olReport:Row()+10, olReport:Col()+2060, Transform(aTotais[1],"@E 999,999,999.99"),	oFont8 )
olReport:Say( olReport:Row()+10, olReport:Col()+2320, Transform(aTotais[2],"@E 999,999,999.99"),	oFont8 )
olReport:Say( olReport:Row()+10, olReport:Col()+2720, Transform(aTotais[3],"@E 999,999,999.99"),	oFont8 )
olReport:SkipLine( 1 )

// Inicia os totalizadores
aTotais[1] := 0
aTotais[2] := 0
aTotais[3] := 0

Return
