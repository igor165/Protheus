#include "RwMake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "FINR085X.ch"

#define PIX_DIF_COLUNA_VALORES			350		// Pixel inicial para impressao dos tracos das colunas dinamicas
#define PIX_INICIAL_VALORES				470		// Pixel para impressao do traco vertical
#define PIX_EQUIVALENTE			  		340		// Pixel inicial para impressao das colunas dinamicas

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINR085   � Autor � Totvs              � Data �  16/06/10   ���
�������������������������������������������������������������������������͹��
���Descricao �Certificado de Reten��o do IVA (Imposto do Valor Agregado). ���
���	  							- VENEZUELA	-							  ���
�������������������������������������������������������������������������͹��
���Uso       �FINR085                                                     ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   �  BOPS   �  Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���gSantacruz�DMINA-2452�Cambios realizados por Cesar Butista:Se adiciona ���
���          �          � el campo % de IVA en el detalle del reporte. Se ���
���          �          � actualiza la leyenda LEX IVA.Se cambia de forma-���
���          �          � to A4 para formato Legal. Se desactiva la pre-- ���
���          �          � gunta del Tipo formato, solo se dejo activado el���
���          �          � formato Legal u Oficio. (Venezuela)             ���
��                                                                        ���
���GSantacruz�01/06/18  �DMINA-3229� Venezuela que genere las retenciones ���
���          �          �          � Tipo "B" (Retencion Barcelona)       ���
���GSantacruz�01/06/18  �DMINA-3717�Titulo para el comporbante de BAR.    ���
������������������������������������������������� g��������������������������
�����������������������������������������������������������������������������
*/
Function FINR085X()

Local cPerg     := "FI085X"

Local olReport

If TRepInUse()


		Pergunte(cPerg,.F.)
		olReport := FINR085xA4(cPerg)
		olReport:SetParam(cPerg)
		olReport:PrintDialog()

EndIf
Return


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FINR085xA4  � Autor � Jose Lucas         � Data | 18/06/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impress�o do relatorio Comprovante de IVA no formato A3.   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINR085xA4(cPerg)           				                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Perguntas dos parametros.                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FINR085xA4(cPerg)

Local clNomProg		:= FunName()
Local clTitulo 		:= STR0001 //"COMPROBANTE DE RETENCI�N DEL IVA/BARCELONA - VENEZUELA" 
Local clDesc   		:= clTitulo
Local olReport
Local lLandScape    := .T.

olReport:=TReport():New(clNomProg,clTitulo,,{|olReport| FINProcxA4(olReport)},clDesc,lLandScape)
olReport:SetLandscape()					// Formato paisagem
olReport:oPage:nPaperSize	:= 9 		// Impress�o em papel A4 - LandScape
olReport:lHeaderVisible 	:= .F. 		// N�o imprime cabe�alho do protheus
olReport:lFooterVisible 	:= .F.		// N�o imprime rodap� do protheus
olReport:lParamPage			:= .F.		// N�o imprime pagina de parametros

olReport:DisableOrientation()           // N�o permite mudar o formato de impress�o para Vertical, somente landscape
olReport:SetEdit(.F.)                   // N�o permite personilizar o relat�rio, desabilitando o bot�o <Personalizar>
Return olReport

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FINProcxA4   � Autor � Totvs              � Data | 06/05/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impress�o do relatorio.								      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINProcxA4( ExpC1 )         				                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 = Objeto tReport                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FINProcxA4( olReport )

Local nReg		 := 0 //Quantidade de registros impressos
Local nPag		 := 0 //Quantidade de paginas por pagina
Local nCol		 := 0
Local clSql		 := ""
Local aEquivale  := { 0, 0, 0, 0, 0}
Local nTotalCols := Len( aEquivale )
Local aTotais	 := Array( nTotalCols )
Local oFont8 	 := TFont():New( "Courier New",, -08 )
Local oFont9 	 := TFont():New( "Courier New",, -09 )
Local oFont10 	 := TFont():New( "Courier New",, -10 )
Local cFornece	 := ""
Local nTrans     := 0
Local nRowStart	 := 0
Local lFirstPage := .T.
Local nNumOper   := 0
Local nPagina    := 0

// Inicia o array totalizador com zero
aFill( aTotais, 0 )

clSql := "SELECT DISTINCT "
clSql += " SFE.FE_FORNECE, "
clSql += " SFE.FE_LOJA, "
clSql += " SFE.FE_NROCERT, "
clSql += " SFE.FE_EMISSAO, "
clSql += " SFE.FE_NFISCAL, "
clSql += " SFE.FE_SERIE, "
clSql += " SFE.FE_ORDPAGO, "
clSql += " SFE.FE_CONCEPT, "
clSql += " SF1.F1_NATUREZ, "
clSql += " SF1.F1_VALMERC+ SFE.FE_VALIMP 	TOTCOM, "
clSql += " SF1.F1_VALMERC , "
clSql += " SF1.F1_FORMLIB , "
clSql += " SFE.FE_VALBASE, "
clSql += " SFE.FE_ALIQ   , "
clSql += " SFE.FE_VALIMP, "
clSql += " SFE.FE_RETENC , "
clSql += " SFE.FE_ESPECIE, "
clSql += " SEK.EK_EMISSAO, "
clSql += " SFE.FE_TIPO, "
clSql += " SFE.FE_DEDUC, "
clSql += " SA2.A2_NOME, "
clSql += " SA2.A2_CGC, "
clSql += " SA2.A2_ESTADO, "
clSql += " SA2.A2_TIPO, "
clSql += " SFE.FE_CONCEPT, "
clSql += " SFE.R_E_C_N_O_, "
clSql += " SF3.F3_ALQIMP1, "
clSql += " SF3.F3_ALQIMP3 "
clSql += " FROM " 				+ 	RetSqlName("SFE") + " SFE "
clSql += " LEFT OUTER JOIN " 	+ 	RetSqlName("SF1") + " SF1 "
clSql += " ON SFE.FE_NFISCAL	=	SF1.F1_DOC 	AND "
clSql += " SFE.FE_SERIE   		= 	SF1.F1_SERIE AND "
clSql += " SFE.FE_FORNECE 		= 	SF1.F1_FORNECE AND "
clSql += " SFE.FE_LOJA   		= 	SF1.F1_LOJA AND SF1.D_E_L_E_T_ <> '*' ""
clSql += " LEFT OUTER JOIN "	+	RetSqlName("SA2") + " SA2 "
clSql += " ON SFE.FE_FORNECE 	= 	SA2.A2_COD AND "
clSql += " SFE.FE_LOJA	 		= 	SA2.A2_LOJA AND SA2.D_E_L_E_T_ <> '*' ""
clSql += " LEFT OUTER JOIN "	+ 	RetSqlName("SEK") + " SEK "
clSql += " ON SFE.FE_ORDPAGO 	= 	SEK.EK_ORDPAGO AND "
clSql += " SFE.FE_FORNECE		=	SEK.EK_FORNECE AND SEK.D_E_L_E_T_ <> '*' "

clSql += " LEFT OUTER JOIN " + 	RetSqlName("SF3") + " SF3 " 
clSql += " ON SFE.FE_NFISCAL = SF3.F3_NFISCAL AND "
clSql += " SFE.FE_SERIE = SF3.F3_SERIE AND "
clSql += " SFE.FE_FORNECE = SF3.F3_CLIEFOR AND "
clSql += " SFE.FE_LOJA = SF3.F3_LOJA  AND SF3.F3_TIPOMOV = 'C'  AND SF3.D_E_L_E_T_ <> '*' "
If MV_PAR05==1 //IVA
	clSql += "  AND SF3.F3_BASIMP1<>0 "
ELSE //Barcelona	
	clSql += "  AND SF3.F3_BASIMP3<>0 "
ENDIF	
clSql += " WHERE SFE.FE_FILIAL  = '" + xFilial("SFE") + "'"
clSql += "  AND SFE.FE_EMISSAO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
clSql += "  AND SFE.FE_FORNECE BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
If MV_PAR05==1 //IVA
	clSql += "  AND SFE.FE_TIPO	IN('I') "
ELSE //Barcelona	
	clSql += "  AND SFE.FE_TIPO	IN('B') "
ENDIF	


If TcSrvType() == "AS/400"
	clSql += " AND @SFE.DELETED@ <> '*' "
Else
	clSql += " AND SFE.D_E_L_E_T_ <> '*' "
EndIf
clSql += " ORDER BY 1,2,3 "

clSql := ChangeQuery( clSql  )

dbUseArea( .T., "TOPCONN", TcGenQry( ,, clSql ), "PER",.T.,.T.)

TCSetField( "PER", "FE_EMISSAO",  "D", 08, 0 )
TCSetField( "PER", "EK_EMISSAO",  "D", 08, 0 )
TCSetField( "PER", "FE_VALBASE",  "N", TamSX3( "FE_VALBASE" )[1], TamSX3( "FE_VALBASE" )[2] )

dbSelectArea( "PER" )
PER->( dbGoTop() )
While !PER->(Eof())

	cFornece := PER->FE_FORNECE
	nNumOper := 0	//Quebrar por Comprovante.

	While !PER->(Eof()) .and. PER->FE_FORNECE == cFornece

		cNroCert := PER->FE_NROCERT
		nNumOper := 0
		nPagina ++

		//Quebra por Numero de Certificado
		While !PER->(Eof()) .and. PER->FE_FORNECE == cFornece .and. PER->FE_NROCERT == cNroCert

			If olReport:Cancel()
				Exit
			EndIf

    		If lFirstPage
				FCabR085A4( olReport, nPagina ) //Impress�o do cabe�alho
				lFirstPage := .F.
			EndIf

			// Determina o pixel vertical inicial
			nRowStart := olReport:Row()

			nNumOper ++
			cNumOper := Str(nNumOper,4)

         	//Obter numero da Nota Fiscal Original quando NCP o NDC
            cNFiscalOri := R085PgNC()

			olReport:SetMeter( RecCount() )

			nTrans += 1
			olReport:Say( olReport:Row(), olReport:Col()+0120, IIf(Empty(cNumOper)			," ", Transform(cNumOper,"@!"))							,	oFont8 )//-- '1. Oper. Nro'
			olReport:Say( olReport:Row(), olReport:Col()+0235, Iif(Empty(PER->FE_EMISSAO) 	," ", DtoC(PER->FE_EMISSAO)), 				 				oFont8 )//-- '2. Fecha de Factura'
			
			If AllTrim(PER->FE_ESPECIE) == "NF"
				olReport:Say( olReport:Row(), olReport:Col()+0430, Iif(Empty(PER->FE_NFISCAL) 	," ", Transform(AllTrim(PER->FE_NFISCAL),"@!"))	 		,	oFont8 )//-- '3. N�mero de Factura'
			Endif

			olReport:Say( olReport:Row(), olReport:Col()+0615, PER->F1_FORMLIB	 		,	oFont8 )//-- '4. Control Factura'

			If AllTrim(PER->FE_ESPECIE) == "NCP"
				olReport:Say( olReport:Row(), olReport:Col()+0840, Iif(Empty(PER->FE_NFISCAL) 	," ", Transform(AllTrim(PER->FE_NFISCAL),"@!"))	 		,	oFont8 )//-- '6. N�mero Nota D�bito'
			ElseIf AllTrim(PER->FE_ESPECIE) == "NDP"
				olReport:Say( olReport:Row(), olReport:Col()+1080, Iif(Empty(PER->FE_NFISCAL) 	," ", Transform(AllTrim(PER->FE_NFISCAL),"@!"))			,	oFont8 )//-- '7. N�mero Nota Cr�dito',
   			EndIf

			olReport:Say( olReport:Row(), olReport:Col()+1310, Iif(Empty(PER->F1_NATUREZ) 		," ", PadR(PER->F1_NATUREZ, 10))					 	,	oFont8 )//-- '8. Tipo de Transacc'
			If !Empty(cNFiscalOri)
				olReport:Say( olReport:Row(), olReport:Col()+1470, Iif(Empty(cNFiscalOri) 	," ", Transform(AllTrim(cNFiscalOri),"@!"))					,	oFont8 )//-- '9. N�mero da Factura Afetada'
   			EndIf

			olReport:Say( olReport:Row(), olReport:Col()+1660, Iif(Empty(PER->TOTCOM) 			," ", Transform(PER->TOTCOM,			"@E 999,999,999.99")),	oFont8 )//-- '10. Total de Compras incluyendo el IVA'
			olReport:Say( olReport:Row(), olReport:Col()+1940, Iif(Empty(PER->F1_VALMERC)		," ", Transform(PER->F1_VALMERC,		"@E 999,999,999.99")),	oFont8 )//-- '11. Compras sin derecho a credito de IVA'
			olReport:Say( olReport:Row(), olReport:Col()+2170, Iif(Empty(PER->FE_VALBASE)		," ", Transform(PER->FE_VALBASE,		"@E 999,999,999.99")),	oFont8 )//-- '12. Base Imponible'
			IF MV_PAR05==1 //IVA
				olReport:Say( olReport:Row(), olReport:Col()+2410, Iif(Empty(PER->F3_ALQIMP1)		," ", Transform(PER->F3_ALQIMP1,		"@E 999")),	oFont8 )//-- '16. % Alicuota Tasa '
			//ELSE //BAR
				//olReport:Say( olReport:Row(), olReport:Col()+2410, Iif(Empty(PER->F3_ALQIMP3)		," ", Transform(PER->F3_ALQIMP3,		"@E 999")),	oFont8 )//-- '16. % Alicuota Tasa '
				
			
			olReport:Say( olReport:Row(), olReport:Col()+2530, Iif(Empty(PER->FE_VALIMP)		," ", Transform(PER->FE_VALIMP,	  		"@E 999,999,999.99")),	oFont8 )//-- '14. Impuesto IVA'
			ENDIF
			olReport:Say( olReport:Row(), olReport:Col()+2730, Iif(Empty(PER->FE_RETENC)		," ", Transform(PER->FE_RETENC,			"@E 999,999,999.99")),	oFont8 )//-- '15. IVA Retenido'
			olReport:Say( olReport:Row(), olReport:Col()+2970, Iif(Empty(PER->FE_ALIQ)			," ", Transform(PER->FE_ALIQ,			"@E 999")),	oFont8 )//-- '13. %: Alicuota'
			// Ajusta os totalizadores
			If PER->FE_ESPECIE $ "NF |NDP"
				aTotais[1] += PER->TOTCOM
				aTotais[2] += PER->F1_VALMERC
				aTotais[3] += PER->FE_VALBASE
				aTotais[4] += PER->FE_VALIMP
				aTotais[5] += PER->FE_RETENC
    		ElseIf AllTriM(PER->FE_ESPECIE) $ "NCP"
    			If aTotais[1] > 0.00
 					aTotais[1] -= PER->TOTCOM
					aTotais[2] -= PER->F1_VALMERC
					aTotais[3] -= PER->FE_VALBASE
					aTotais[4] -= PER->FE_VALIMP
					aTotais[5] -= PER->FE_RETENC
				Else
 					aTotais[1] += PER->TOTCOM
					aTotais[2] += PER->F1_VALMERC
					aTotais[3] += PER->FE_VALBASE
					aTotais[4] += PER->FE_VALIMP
					aTotais[5] += PER->FE_RETENC
				EndIf
    		EndIf
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
				olReport:SkipLine( 20 )
			
				olReport:Say( olReport:Row()+ 50, olReport:Col()+1310, "______________________________________",	oFont10 )
				olReport:Say( olReport:Row()+100, olReport:Col()+1350, "Firma y Sello Agente De Retenci�n",	oFont10 )
				olReport:Say( olReport:Row()+150, olReport:Col()+1440, "R.I.F. N� "+ Iif(Empty(SM0->M0_CGC)," ", PadR(SM0->M0_CGC, 14)),	oFont10 )
				olReport:Say( olReport:Row()+300, olReport:Col()+0110, "Fecha de Entrega:___/___/______",	oFont10 )
				
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







/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � R085PgNC  �Autor  �Jose Lucas         � Data �  10/05/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retornar o numero da nota fiscal original.                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � R085PgNC                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	  			cNFOrig := SD2->D2_NFORI	//+"-"+SD2->D2_SERIORI
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
	  			cNFOrig := SD1->D1_NFORI	//+"-"+SD1->D1_SERIORI
			EndIf
			SD1->(dbSkip())
		End
    EndIf
EndIf
RestArea(aSavArea)
Return cNFOrig
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FCabR085A4  � Autor � Jose Lucas          � Data | 19/06/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cabe�alho do relatorio no formato A4.					      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FCabR085A4(Expo1,ExpN1,ExpA1)				                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1 = Objeto tReport                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FCabR085A4( olReport, nPagina )
//                            1    2    3    4     5     6     7     8     9     10    11    12    13    14
Local oFont8B 		:= TFont():New( "Courier New",, -08,,.T. )
Local oFont9 		:= TFont():New( "Courier New",, -09 )
Local oFont10 		:= TFont():New( "Courier New",, -10 )
Local oFont10B 		:= TFont():New( "Courier New",, -10,,.T. )
Local oFont11B 		:= TFont():New( "Courier New",, -11,,.T. )
if MV_PAR05==1 //IVA
	olReport:Say( olReport:Row()+080, olReport:Col()+0300,'(Ley IVA - Art. 11: "Ser�n responsables del pago del impuesto en calidad de agentes de retenci�n, los compradores de determinados bienes', oFont9 )
	olReport:Say( olReport:Row()+110, olReport:Col()+0300,'muebles y los receptores de ciertos sera quienes la Administraci�n Tributaria com tal")',	oFont9 )
ENDIF
//Box 0. Nro do Comprovante
olReport:Box(olReport:Row()+120, olReport:Col()+1950, olReport:Row()+250, olReport:Col()+2400 )
olReport:Say(olReport:Row()+140, olReport:Col()+1960, "0. Nro Comprobante",	oFont10 )
olReport:Say(olReport:Row()+190, olReport:Col()+2020, Transform(PER->FE_NROCERT,"@R 9999-99-99999999"),	oFont10 )

//Box 1. Fecha
olReport:Box(olReport:Row()+120, olReport:Col()+2500, olReport:Row()+250, olReport:Col()+2950 )
olReport:Say(olReport:Row()+140, olReport:Col()+2510, "1. Fecha",	oFont10 )
olReport:Say(olReport:Row()+190, olReport:Col()+2620, Transform(DTOC(PER->FE_EMISSAO),"@D"), oFont10 )
if MV_PAR05==1 //IVA
	olReport:Say( olReport:Row()+200, olReport:Col()+0500,"COMPROBANTE DE RETENCI�N DEL IMPUESTO AL VALOR AGREGADO",oFont11B )
Else
	olReport:Say( olReport:Row()+200, olReport:Col()+0500,"COMPROBANTE DE RETENCION MUNICIPAL - SIMON BOLIVAR EDO. ANZOATEGUI",oFont11B )
endif	
olReport:Line(olReport:Row()+240, olReport:Col()+0500, olReport:Row()+240, olReport:Col()+1600)  //Tra�o

//Box 2. Nombre o Razon Social
olReport:Box(olReport:Row()+280, olReport:Col()+0100, olReport:Row()+410, olReport:Col()+1300 )
olReport:Say(olReport:Row()+300, olReport:Col()+0110, "2. Nombre o Raz�n Social del Agente de Retenci�n", oFont10 )
olReport:Say(olReport:Row()+350, olReport:Col()+0110, Transform(Subs(SM0->M0_NOMECOM,1,40),"@!"), oFont10B )

//Box 3. Regsitro de Informaci�n
olReport:Box(olReport:Row()+280, olReport:Col()+1350, olReport:Row()+410, olReport:Col()+2400 )
olReport:Say(olReport:Row()+300, olReport:Col()+1360, "3. Registro de Informaci�n Fiscal del Agente de Retenci�n", oFont10 )
olReport:Say(olReport:Row()+350, olReport:Col()+1360, Padr(SM0->M0_CGC,14), oFont10 )

//Box 4. Periodo Fiscal
olReport:Box(olReport:Row()+280, olReport:Col()+2500, olReport:Row()+410, olReport:Col()+2950 )
olReport:Say(olReport:Row()+300, olReport:Col()+2510, "4. Per�odo Fiscal", oFont10 )
olReport:Say(olReport:Row()+350, olReport:Col()+2550, "A�o: "+StrZero(Year(PER->FE_EMISSAO),4)+"   Mes: "+StrZero(Month(PER->FE_EMISSAO),2), oFont10 )

//Box 5. Direcci�n Fiscal del Agente de Retenci�n
olReport:Box(olReport:Row()+440, olReport:Col()+0100, olReport:Row()+570, olReport:Col()+2400 )
olReport:Say(olReport:Row()+460, olReport:Col()+0110, "5. Direcci�n Fiscal del Agente de Retenci�n", oFont10 )
olReport:Say(olReport:Row()+510, olReport:Col()+0110, SM0->M0_ENDCOB+" "+SM0->M0_CIDCOB+" "+SM0->M0_ESTCOB, oFont10 )

//Box 6. Nombre o Razon Social del Sujeto Retenido
olReport:Box(olReport:Row()+600, olReport:Col()+0100, olReport:Row()+730, olReport:Col()+1300 )
olReport:Say(olReport:Row()+620, olReport:Col()+0110, "6. Nombre o Raz�n Social del Sujeto Retenido", oFont10 )
olReport:Say(olReport:Row()+670, olReport:Col()+0110, Transform(PER->A2_NOME,"@!"), oFont10B )

//Box 7. Registro de Informaci�n Fiscal del Sujeto Retenido
olReport:Box(olReport:Row()+600, olReport:Col()+1350, olReport:Row()+730, olReport:Col()+2400 )
olReport:Say(olReport:Row()+620, olReport:Col()+1360, "7. Registro de Informaci�n Fiscal del Sujeto Retenido", oFont10 )
olReport:Say(olReport:Row()+670, olReport:Col()+1360, Iif(Empty(PER->A2_CGC), " ", PadR( PER->A2_CGC, 14 ))			,	oFont10 )

//Box 8. Compras Intrenas ou Importacoes
olReport:Box(olReport:Row()+800, olReport:Col()+2100, olReport:Row()+860, olReport:Col()+2650 )
olReport:Say(olReport:Row()+820, olReport:Col()+2150, "Compras Internas o Importaciones", oFont8B )

//Box 9. Titulos das colunas
//1a. linha do titulo
olReport:Box(olReport:Row()+860, olReport:Col()+0100, olReport:Row()+0990, olReport:Col()+3150 )
olReport:Say(olReport:Row()+880, olReport:Col()+0130, "Oper." 	 		, oFont8B )
olReport:Say(olReport:Row()+880, olReport:Col()+0260, " Fecha"	 		, oFont8B )
olReport:Say(olReport:Row()+880, olReport:Col()+0440, "  Nro."	 		, oFont8B )
olReport:Say(olReport:Row()+880, olReport:Col()+0640, "No. Control."	, oFont8B )
olReport:Say(olReport:Row()+880, olReport:Col()+0840, " Nota"			, oFont8B )
olReport:Say(olReport:Row()+880, olReport:Col()+1080, "  Nota"			, oFont8B )
olReport:Say(olReport:Row()+880, olReport:Col()+1310, "Tipo de"			, oFont8B )
olReport:Say(olReport:Row()+880, olReport:Col()+1450, "Nro. Factura"	, oFont8B )
olReport:Say(olReport:Row()+880, olReport:Col()+1660, "Total de Compras", oFont8B )
olReport:Say(olReport:Row()+880, olReport:Col()+1960, "Compras sin"		, oFont8B )
olReport:Say(olReport:Row()+880, olReport:Col()+2410, "Alicuota"			, oFont8B )
olReport:Say(olReport:Row()+880, olReport:Col()+2960, "      %"			, oFont8B )
//2a. linha do t�tulo
olReport:Say(olReport:Row()+905, olReport:Col()+0130, "Nro."	 		, oFont8B )
olReport:Say(olReport:Row()+905, olReport:Col()+0260, "Factura" 	 	, oFont8B )
olReport:Say(olReport:Row()+905, olReport:Col()+0440, "Factura"	 		, oFont8B )
olReport:Say(olReport:Row()+905, olReport:Col()+0640, "  Factura" 		, oFont8B )
olReport:Say(olReport:Row()+905, olReport:Col()+0840, "Cr�dito"		 	, oFont8B )
olReport:Say(olReport:Row()+905, olReport:Col()+1080, "D�bito"			, oFont8B )
olReport:Say(olReport:Row()+905, olReport:Col()+1310, "Transac."	 	, oFont8B )
olReport:Say(olReport:Row()+905, olReport:Col()+1470, "Afectada"	 	, oFont8B )
olReport:Say(olReport:Row()+905, olReport:Col()+1660, "Incluyendo IVA"	, oFont8B )
olReport:Say(olReport:Row()+905, olReport:Col()+1940, "Derecho Credito"	, oFont8B )
olReport:Say(olReport:Row()+905, olReport:Col()+2170, "Base Imponible"	, oFont8B )
olReport:Say(olReport:Row()+905, olReport:Col()+2410, "IVA"		, oFont8B )
olReport:Say(olReport:Row()+905, olReport:Col()+2550, " IVA"	, oFont8B )
olReport:Say(olReport:Row()+905, olReport:Col()+2750, "Imp. Mun. Ret."	, oFont8B )
olReport:Say(olReport:Row()+905, olReport:Col()+3000, "Retencion"	, oFont8B )
//3a. linha do t�tulo
olReport:Say(olReport:Row()+930, olReport:Col()+1940, "     IVA    "	, oFont8B )

olReport:SkipLine( 34 )

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FTotR085  � Autor � Totvs                 � Data | 06/05/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Totais do relatorio.												      ���
���������������������������������������������ADMIN	�����������������������Ĵ��
���Sintaxe   �FTotR085(Expo1,ExpN1,ExpA1)  				                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1 = Objeto tReport                                      ���
���          �ExpN1 = Posi��o da coluna de impress�o                      ���
���          �ExpA1 = Array TOTAIS DAS COLUNAS                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FTotR085A4( olReport, nCol, aTotais )

Local oFont8		:= TFont():New( "Courier New",, -08 )
Local oFont9B		:= TFont():New( "Courier New",, -09,,.T. )

nCol := olReport:Col() + 10
olReport:SkipLine( 1 )

olReport:Line(olReport:Row(), olReport:Col()+1400, olReport:Row(), olReport:Col()+3150)  	//Tra�o
olReport:Say( olReport:Row()+10,olReport:Col()+1400, "Totales --->", oFont9B ) // "Totais"
olReport:Say( olReport:Row()+20, olReport:Col()+1660, Transform(aTotais[1],"@E 999,999,999.99"),	oFont8 ) //
olReport:Say( olReport:Row()+20, olReport:Col()+1940, Transform(aTotais[2],"@E 999,999,999.99"),	oFont8 )
olReport:Say( olReport:Row()+20, olReport:Col()+2170, Transform(aTotais[3],"@E 999,999,999.99"),	oFont8 )
olReport:Say( olReport:Row()+20, olReport:Col()+2530, Transform(aTotais[4],"@E 999,999,999.99"),	oFont8 )
olReport:Say( olReport:Row()+20, olReport:Col()+2730, Transform(aTotais[5],"@E 999,999,999.99"),	oFont8 )

olReport:SkipLine( 1 )

// Inicia os totalizadores
aTotais[1] := 0
aTotais[2] := 0
aTotais[3] := 0
aTotais[4] := 0
aTotais[5] := 0

Return
