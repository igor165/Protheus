#INCLUDE "PROTHEUS.CH"
#INCLUDE "PDTIGV621.ch"

Static nCount := 0

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PDTIGV621 ³ Autor ³		Luis Enríquez  	³ Data ³ 13/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa permite  la importación de detalles  retenciones  ³±±
±±³          ³ que le hubieran realizado los Agentes de Retención.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PDT0621.INI - PERU                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³   BOPS   ³  Motivo da Alteracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³LuisEnríquez ³13/09/18³DMINA-3969³Se modifica query para que se tomen  ³±±
±±³             ³        ³          ³en cuenta notas de crédito (PERU)    ³±±
±±³ARodriguez   ³01/04/19³DMINA-6184³Fitrar x fecha de registro EL_DTDIGIT³±±
±±³             ³        ³          ³y no por emisión EL_EMISSAO (PERU)   ³±±
±±³Oscar G.     ³27/03/20³DMINA-8480³Ordenar por Serie y numero de recibo ³±±
±±³             ³        ³          ³(FE_SERIE2 y FE_NROCERT). (PER)      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PDTIGV621(cRuta)
	Local aArea   := GetArea()
	Local cQuery  := ""
	Local nInd    := 0
	Local aSelFil := {}
	      
	If Select("TMPRET") > 0
		TMPRET->(DbClosearea())
	EndIf 
	
	For nInd:=1 TO Len(aFilsCalc)
		If aFilsCalc[nInd][1] 
			aAdd(aSelFil,aFilsCalc[nInd][2])
		EndIf		
	Next	
	
	cQuery += "SELECT SA1.A1_CGC, SF1.D_E_L_E_T_, SF2.D_E_L_E_T_, SEL.EL_PREFIXO, SEL.EL_EMISSAO, SEL.EL_VALOR, SFE.FE_NROCERT, SFE.FE_EMISSAO, SFE.FE_RETENC, "
	cQuery += "SF2.F2_ESPECIE, SF1.F1_ESPECIE, SF1.F1_SERIE2, SF2.F2_SERIE2, SF1.F1_EMISSAO, SF2.F2_VALBRUT, SF1.F1_VALBRUT, SF2.F2_EMISSAO, SFE.FE_SERIE, SFE.FE_NFISCAL, SFE.FE_SERIE2 "
	cQuery += " FROM "
	cQuery += RetSqlName("SEL") + " SEL "	// Recibos de cobranza
	cQuery += " INNER JOIN " 
	cQuery += RetSqlName("SFE") + " SFE "  	// Retenciones de impuesto
	cQuery += " ON FE_FILIAL " + GetRngFil(aSelFil,"SFE") + " AND SEL.EL_RECIBO = SFE.FE_RECIBO"
	cQuery += " LEFT JOIN " 
	cQuery += RetSqlName("SF1") + " SF1 "  	// Encabezado de documentos de entrada	
	cQuery += " ON FE_FILIAL " + GetRngFil(aSelFil,"SFE") + " AND SFE.FE_NFISCAL = SF1.F1_DOC AND SFE.FE_SERIE = SF1.F1_SERIE"
	cQuery += " LEFT JOIN " 
	cQuery += RetSqlName("SF2") + " SF2 "  	// Encabezado de documentos de salida	
	cQuery += " ON FE_FILIAL "+GetRngFil(aSelFil,"SFE")+" AND SFE.FE_NFISCAL = SF2.F2_DOC AND SFE.FE_SERIE = SF2.F2_SERIE"
	cQuery += " INNER JOIN " 
	cQuery += RetSqlName("SA1") + " SA1 "  // Clientes	
	cQuery += " ON SEL.EL_CLIORIG = SA1.A1_COD  AND SEL.EL_LOJORIG = SA1.A1_LOJA "	
	cQuery += " WHERE "
	cQuery += " SEL.EL_FILIAL " + GetRngFil(aSelFil,"SEL")
	cQuery += " AND SFE.FE_FILIAL " + GetRngFil(aSelFil,"SFE")
	cQuery += " AND SEL.EL_TIPODOC='RI'"
	cQuery += "	AND SEL.EL_DTDIGIT BETWEEN '" + Dtos(MV_PAR01) + "' AND '" + Dtos(MV_PAR02) + "'"
	cQuery += " AND SEL.D_E_L_E_T_='' "
	cQuery += " AND SFE.D_E_L_E_T_='' " 
	cQuery += " AND SA1.D_E_L_E_T_='' " 
	cQuery += " AND (SF2.D_E_L_E_T_ = '' OR SF2.D_E_L_E_T_ is null) "
	cQuery += " AND (SF1.D_E_L_E_T_ = '' OR SF1.D_E_L_E_T_ is null) "
	cQuery += " ORDER BY SFE.FE_SERIE2, SFE.FE_NROCERT, SF1.F1_SERIE2 "
	cQuery := ChangeQuery( cQuery )
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPRET",.T.,.T.)  
	count to nCount 
	If nCount == 0
		MsgAlert(STR0001 + Alltrim(cRuta),STR0002) //"No se encontraron registros para generación de archivo plano de Retención de IGV " "Aviso"
	EndIf     
	
	RestArea(aArea) 
Return Nil

Function PDT621Cie(cRuta)
	If Select("TMPRET") > 0
		TMPRET->(DbClosearea())
	EndIf 
	If nCount > 0
		MsgAlert(STR0003 + Alltrim(cRuta) + STR0004,STR0002) //"Archivo plano de Retención de IGV en ruta " " generado con éxito." "Aviso"
	EndIf
Return Nil