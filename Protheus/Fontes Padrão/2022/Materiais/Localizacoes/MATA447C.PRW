#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA447C.CH"
#INCLUDE "FWLIBVERSION.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA447C ³ Autor ³ Guadalupe Santacruz       ³ Data ³ 30/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera Facturas en Compras y Movtos a Almacen  de pedimento    ³±±
±±³          ³ de Rectificaciones.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATA447C()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³   BOPS   ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Marco A    ³29/09/17³TSSERMI01-³Se realiza replica para V12.1.17, de la   ³±±
±±³            ³        ³151       ³funcionalidad de Pedimentos de Importacion³±±
±±³            ³        ³          ³para el Pais Mexico.                      ³±±
±±³ Oscar G.   ³24/04/20³DMINA-8824³Se corrigen parametros Fun. CRIASB2() en  ³±±
±±³            ³        ³          ³Func. M447CTraspa(). (MEX)                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MATA447C()

	Local 	nBase		:= 0
	Local 	cFilRSJ	:= xfilial("RSJ")

	Local 	lRet		:= .T.

	Local 	aDifImp	:= {} //Diferencias entra las facturas de impuestos
	Local	aDifIncr	:= {} //Diferencia de costos de incrementables
	Local	aDifImps	:= {} //Diferencia de costos de impuestos

	Private lMSHelpAuto		:= .F. //Variable para las rutina automatica
	Private lAutoErrNoFile	:= .T.//Variable para las rutina automatica
	Private cIdMetRet		:= "compras-protheus_cantidad-de-documentos-generados-por-pedimentos-de-rectificacion_total"
	Private cSubRutina	    := ""

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Extrae diferencias entre el pedimento origen³
	//³y la rectificacion.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	RSJ->(DBSetOrder(1))
	If RSJ->(DBSeek(cFilRSJ+RSC->RSC_NUMPED))
		nBase := CalcBseIva(RSC->RSC_NUMPED, RSJ->RSJ_VALADU) // RSJ->RSJ_VALADU
	EndIf
	If RSJ->(DBSeek(cFilRSJ+RSC->RSC_PEDORI))
		nBase -= CalcBseIva(RSC->RSC_PEDORI, RSJ->RSJ_VALADU) //RSJ->RSJ_VALADU
	EndIf

	If nBase <> 0 //Si hubo diferencia en los impuestos, analiza que productos cambiaron en las facturas

		aDifImp := M447CDIF1()//Extrae diferencia entre los items de factura de impuestos
		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Contenido de aDifImp³
		//³1 - Cod Impuesto    ³
		//³2 - Importe         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		aDifIncr	:= M447CDIF3(1) //Diferencia de costos de incrementables
		aDifImps	:= M447CDIF3(2) //Diferencia de costos de impuestos
		aDifFac	:= M447CDIF2() //DIFERENCIA EN LOS ITEMS DE FACTURA

		/*
		//Contenido de aDifFac
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
		//³1 - Factura           ³
		//³2 - Serie             ³
		//³3 - Proveedor         ³
		//³4 - Tienda            ³
		//³5 - Item              ³
		//³6 - Producto          ³
		//³7 - Cant Ori- Cant Rec³
		//³8 - RSE_EXTFAC        ³
		//³9 - Alamcen entrada   ³
		//³10- Cant. Seg UM      ³
		//³11- Num registro RSE  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
		*/

		MT447CABORRA() //Borra los documentos existentes primero

		If nBase < 0  //Genera nota de credito
			lRet := M447CNCR(aDifImp,NBASE)
		Else  //genera nota de cargo
			lRet := M447CNCA(aDifImp,NBASE)
		EndIf

		If Len(aDifIncr) > 0
			M447CMOVINT("IN",.F.,aDifIncr)
		EndIf

		If Len(aDifImps) > 0
			M447CMOVINT("FP",.F.,aDifImps)
		EndIf

		If lRet
			lRet := M447CTraspa(aDifFac)
		EndIf

		If lRet
			If (ExistBlock("M447CR1IN"))
				ExecBlock("M447CR1IN",.F.,.F.)
			EndIF
		EndIf
	EndIf

Return  lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M447CDIF1       ºAutor  ³Gpe Santacruz       ºFecha ³  05/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Extrae diferencia de factura de impuestos                       º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  M447CDIF1   ()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³                                      Importaciones - Mexico      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M447CDIF1()

	Local aRSLRec	:= {}
	Local aRSLOri	:= {}
	Local aDif		:= {}

	Local cFilRSL	:= xFilial("RSL")
	Local cFilRSA	:= xFilial("RSA")

	Local nPos		:= 0
	Local nx		:= 0
	Local cCodImp := ''

	DBSelectArea("RSA")
	RSA->(DBSetOrder(1))

	DBSelectArea("RSL")
	RSL->(DBSetOrder(1))
	If RSL->(DBSeek(CFILRSL+RSC->RSC_NUMPED))
		Do While !RSL->(Eof()) .AND. RSL->RSL_NUMPED == RSC->RSC_NUMPED
			If EMPTY(RSL->RSL_CODIMP)
			   cCodImp:="IVA"
			  
			ELSE
			   cCodImp:= RSL->RSL_CODIMP 
			  
			   IF RSA->(DBSEEK(CFILRSA+RSL->RSL_CODIMP))
			   		cCodImp:= RSA->RSA_CODPRD
			   ENDIF
			endif
				aAdd(aRSLRec,{RSL->RSL_NUMPED,cCodImp,RSL->RSL_IMPORT})
			
			RSL->(DBSkip())
		EndDo
	EndIf


	If RSL->(DBSeek(CFILRSL+RSC->RSC_PEDORI))
		Do While !RSL->(Eof()) .AND. RSL->RSL_NUMPED == RSC->RSC_PEDORI
			If EMPTY(RSL->RSL_CODIMP)
			   cCodImp:="IVA"
			   
			ELSE
			   cCodImp:= RSL->RSL_CODIMP
			   
			   IF RSA->(DBSEEK(CFILRSA+RSL->RSL_CODIMP))
			   		cCodImp:= RSA->RSA_CODPRD
			   ENDIF  
			endif
			aAdd(aRSLOri,{RSL->RSL_NUMPED,cCodImp,RSL->RSL_IMPORT})
		
			RSL->(DBSkip())
		EndDo
	EndIf

	for nx:=1 To Len(aRSLOri)
		nPos := aScan(aRSLRec,{|x| AllTrim(x[2]) == AllTrim(aRSLOri[nx,2])})
		If nPos > 0
			If aRSLOri[nx,3]-aRSLRec[nPos,3]<> 0
				aAdd(aDif,{aRSLOri[nx,2],aRSLrec[nx,3]-aRSLori[nPos,3]})
			EndIf
		Else    //Si en el pedimento origen hay un impuesto que ya no aparecio en la rectificacion
			aAdd(aDif,{aRSLOri[nx,2],aRSLOri[nx,3]*(-1)})
		EndIf
	Next

	for nx := 1 To Len(aRSLRec)
		nPos := aScan(aRSLOri,{|x| AllTrim(x[2]) == AllTrim(aRSLRec[nx,2])})
		If nPos == 0 //Si en el pedimento de rectificacion hay un impuesto que no estaba en el origen
			aAdd(aDif,{aRSLRec[nx,2],aRSLRec[nx,3]})
		EndIf
	Next

Return aDif

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M447CDIF2       ºAutor  ³Gpe Santacruz       ºFecha ³  05/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Extrae diferencia de unidades entre el pedimento origen y        º±±
±±º          ³ y el rectificado.                                                º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  M447CDIF2()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³                                      Importaciones - Mexico      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M447CDIF2()

	Local cQry		:= ''
	Local cFilRSF	:= xFilial("RSF")
	Local cFilRSE	:= xFILIAL("RSE")
	Local cAliRSF	:= CriaTrab(Nil,.F.)
	Local aFacRec	:= {}
	Local aFacOri	:= {}
	Local nx		:= 0
	Local aDif		:= {}
	Local nPos		:= 0

	cQry := "SELECT RSE_NUMPED,RSE_EXTFAC,RSE_FACT,RSE_SERIE,RSE_PROV,RSE_TDA,RSF_ITEM,RSF_PRODUC,RSF_CANT,RSF_ALMACE,RSF_canum2,RSE.R_E_C_N_O_ NREG from "+RetSqlName("RSE") +" RSE, "+RetSqlName("RSF") +" RSF  WHERE RSE.D_E_L_E_T_  = ' ' AND RSF.D_E_L_E_T_  = ' ' "
	cQry += " AND (RSE_NUMPED='"+RSC->RSC_NUMPED+"' OR RSE_NUMPED='"+RSC->RSC_PEDORI+"' ) "
	cQry += " AND RSE_NUMPED=RSF_NUMPED AND RSE_ITEM=RSF_ITEDOC AND RSE_FILIAL='"+CFILRSE+"' AND RSF_FILIAL='"+CFILRSF+"' "
	cQry := ChangeQuery(cQry)

	DbUseArea( .T., 'TOPCONN', TCGenQry(,, cQry), cAliRSF, .T., .T. )
	DO While !(cAliRSF)->(Eof())
		If (cAliRSF)->RSE_NUMPED == RSC->RSC_NUMPED
			aAdd(aFacRec,{(cAliRSF)->RSE_FACT,(cAliRSF)->RSE_SERIE,(cAliRSF)->RSE_PROV,(cAliRSF)->RSE_TDA,(cAliRSF)->RSF_ITEM,(cAliRSF)->RSF_PRODUC,(cAliRSF)->RSF_CANT,(cAliRSF)->RSE_EXTFAC,(cAliRSF)->RSF_ALMACE,(cAliRSF)->RSF_CANUM2,(cAliRSF)->NREG})
		Else
			aAdd(aFacOri,{(cAliRSF)->RSE_FACT,(cAliRSF)->RSE_SERIE,(cAliRSF)->RSE_PROV,(cAliRSF)->RSE_TDA,(cAliRSF)->RSF_ITEM,(cAliRSF)->RSF_PRODUC,(cAliRSF)->RSF_CANT,(cAliRSF)->RSE_EXTFAC,(cAliRSF)->RSF_ALMACE,(cAliRSF)->RSF_CANUM2,(cAliRSF)->NREG})
		EndIf
		(cAliRSF)->(DBSkip())
	EndDo
	(CALIRSF)->(DBCloseArea())
	For nx := 1 To Len(aFacOri)
		nPos := aScan(aFacRec,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == aFacOri[nx,1]+aFacOri[nx,2]+aFacOri[nx,3]+aFacOri[nx,4]+aFacOri[nx,5]+aFacOri[nx,6]})
		If nPos > 0
			If aFacOri[nx,7]<>aFacRec[nx,7]
				aAdd(aDif,{aFacOri[nx,1],aFacOri[nx,2],aFacOri[nx,3],aFacOri[nx,4],aFacOri[nx,5],aFacOri[nx,6], aFacRec[nx,7]-aFacOri[nx,7],aFacRec[nx,8],aFacRec[nx,9],aFacRec[nx,10],aFacRec[nx,11]})
			EndIf
		Else //Si en el pedimento origen hay un producto que ya no aparecio en la rectificacion
			aAdd(aDif,{aFacOri[nx,1],aFacOri[nx,2],aFacOri[nx,3],aFacOri[nx,4],aFacOri[nx,5],aFacOri[nx,6], aFacOri[nx,7]*-1,aFacOri[nx,8],aFacOri[nx,9],aFacOri[nx,10],aFacOri[nx,11]})
		EndIf
	Next

	For nx := 1 To Len(aFacRec)
		nPos := aScan(aFacOri,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == aFacRec[nx,1]+aFacRec[nx,2]+aFacRec[nx,3]+aFacRec[nx,4]+aFacRec[nx,5]+aFacRec[nx,6]})
		If nPos == 0//Si en el pedimento de rectificacion hay un producto que no estaba en el origen
			aAdd(aDif,{aFacRec[nx,1],aFacRec[nx,2],aFacRec[nx,3],aFacRec[nx,4],aFacRec[nx,5],aFacRec[nx,6], aFacRec[nx,7], aFacRec[nx,8], aFacRec[nx,9], aFacRec[nx,10], aFacRec[nx,11]})
		EndIf
	Next

Return aDif

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M447CDIF3       ºAutor  ³Gpe Santacruz       ºFecha ³  07/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Extrae diferencia de incrementables entre pedimento origen y    ³±±
±±ºDesc.     ³  el Rectificado.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  M447CDIF3   ()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp1.- 1 Trabaja sobre los valores de incrementables            ³±±
±±³          ³         2 Trabaja sobre los valores de impuestos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºRetorno   ³ aExp1 .- Arreglo con las diferencias                             º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³                                      Importaciones - Mexico      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M447CDIF3(nTipo)

	Local aRSLRec	:= {}
	Local aRSLOri	:= {}
	Local cFilRSI	:= xFilial("RSI")
	Local cFilRSE	:= xFilial("RSE")
	Local cFilRSF	:= xFilial("RSF")
	Local aDif		:= {}
	Local nPos		:= 0
	Local nx		:= 0
	Local cAliRSI	:= CriaTrab(Nil,.F.)

	cQry := "SELECT RSI_NUMPED,RSI_FACT,RSI_SERIE,RSI_PROV,RSI_TDA,RSI_PROD,RSI_INCREM,RSI_IMPUES,RSF_ALMACE  FROM "+RetSqlName("RSI")+" RSI,"+RetSqlName("RSE")+" RSE,"+RetSqlName("RSF")+" RSF WHERE  "
	cQry += " RSI.D_E_L_E_T_  = ' ' AND RSE.D_E_L_E_T_  = ' '  AND RSF.D_E_L_E_T_  = ' ' "
	cQry += " AND  RSI_FILIAL='"+CFILRSI+"' AND RSE_FILIAL='"+CFILRSE+"' AND RSF_FILIAL='"+CFILRSF+"' "
	cQry += " AND  (RSI_NUMPED ='"+RSC->RSC_NUMPED+"' OR  RSI_NUMPED='"+RSC->RSC_PEDORI+"') "
	cQry += " AND  RSI_NUMPED =RSE_NUMPED AND RSE_NUMPED=RSF_NUMPED AND RSI_NUMPED=RSF_NUMPED AND RSE_ITEM=RSF_ITeDOC"
	cQry += " AND  RSI_FACT =RSE_FACT AND RSI_SERIE=RSE_SERIE AND RSI_PROV=RSE_PROV AND RSI_TDA=RSE_TDA AND RSI_ITEM=RSF_ITEM "
	cQry := ChangeQuery(cQry)
	DbUseArea( .T., 'TOPCONN', TCGenQry(,, cQry), cAliRSI, .T., .T. )

	DO While !(cAliRSI)->(Eof())
		If (cAliRSI)->RSI_NUMPED == RSC->RSC_NUMPED
			If nTipo = 1 //incrementables
				aAdd(aRSLRec,{(cAliRSI)->RSI_NUMPED,(cAliRSI)->RSI_PROD,(cAliRSI)->RSI_INCREM,(cAliRSI)->RSF_ALMACE,(cAliRSI)->RSI_FACT+(cAliRSI)->RSI_SERIE+(cAliRSI)->RSI_PROV+(cAliRSI)->RSI_TDA})
			Else  //impuestos
				aAdd(aRSLRec,{(cAliRSI)->RSI_NUMPED,(cAliRSI)->RSI_PROD,(cAliRSI)->RSI_IMPUES,(cAliRSI)->RSF_ALMACE,(cAliRSI)->RSI_FACT+(cAliRSI)->RSI_SERIE+(cAliRSI)->RSI_PROV+(cAliRSI)->RSI_TDA})
			EndIf
		Else
			If nTipo == 1
				aAdd(aRSLOri,{(cAliRSI)->RSI_NUMPED,(cAliRSI)->RSI_PROD,(cAliRSI)->RSI_INCREM,(cAliRSI)->RSF_ALMACE,(cAliRSI)->RSI_FACT+(cAliRSI)->RSI_SERIE+(cAliRSI)->RSI_PROV+(cAliRSI)->RSI_TDA})
			Else
				aAdd(aRSLOri,{(cAliRSI)->RSI_NUMPED,(cAliRSI)->RSI_PROD,(cAliRSI)->RSI_IMPUES,(cAliRSI)->RSF_ALMACE,(cAliRSI)->RSI_FACT+(cAliRSI)->RSI_SERIE+(cAliRSI)->RSI_PROV+(cAliRSI)->RSI_TDA})
			EndIf

		EndIf
		(cAliRSI)->(DBSkip())
	EndDo

	(cAliRSI)->(DBCloseArea())

	for nx := 1 To Len(aRSLOri)
		nPos := aScan(aRSLRec,{|x| AllTrim(x[2])+AllTrim(x[5]) == AllTrim(aRSLOri[nx,2])+AllTrim(aRSLOri[nx,5])})
		If nPos > 0
			If aRSLOri[nx,3]-aRSLRec[nPos,3]<> 0
				aAdd(aDif,{aRSLOri[nx,2],aRSLrec[nx,3]-aRSLori[nPos,3],aRSLOri[nx,4]})
			EndIf
		Else    //Si en el pedimento origen hay un impuesto que ya no aparecio en la rectificacion
			aAdd(aDif,{aRSLOri[nx,2],aRSLOri[nx,3]*(-1),aRSLOri[nx,4]})
		EndIf
	Next

	for nx := 1 To Len(aRSLRec)
		nPos := aScan(aRSLOri,{|x| AllTrim(x[2])+AllTrim(x[5]) == AllTrim(aRSLRec[nx,2])+AllTrim(aRSLRec[nx,5])})
		If nPos == 0 //Si en el pedimento de rectificacion hay un impuesto que no estaba en el origen
			aAdd(aDif,{aRSLRec[nx,2],aRSLRec[nx,3],aRSLrec[nx,4]})
		EndIf
	Next

Return aDif

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M447CNCA        ºAutor  ³Gpe Santacruz       ºFecha ³  05/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Genera NOTA CARGO  la diferencia de impuestos                    º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  M447CFacImp   ()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  aExp1.- Arreglo con las partidas que tienen dif.en cantidad     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  lExp1.- .T. si no hay errores                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³                                      Importaciones - Mexico      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M447CNCA(aDifImp,NBASE)

	Local nRegTmp	:= RSC->(Recno())
	Local nx		:= 0

	Local cPedOri	:= RSC->RSC_PEDORI
	Local cPedRec	:= RSC->RSC_NUMPED
	Local cNumFac	:= GetMV("MV_MXSECNC") //Consecutivo de nota de cargo
	Local cFilSF1	:= xFilial("SF1")
	Local cFilDB9	:= xFilial("DB9")
	Local cFilRSC	:= xFilial("RSC")
	Local cFilSB1	:= xFilial("SB1")
	Local cFilRSL	:= xFilial("RSL")
	Local cFilRSA	:= xFilial("RSA")
	Local cItem	:= StrZero(0,TamSX3('D1_ITEM')[1]) //Inicia numero de item de la factura

	Local 	aItens	:={}
	Local 	aCabs	:={}

	Local 	cSerFac		:= ''
	Local 	cTES			:= GetMV("MV_MXTESIM") //Codigo de TES para la factura de impuestos de importacion "208"
	Local 	lRet			:= .T.
	Local 	cCF				:= ''
	Local 	cCodPrd		:= ''
	Local 	cUm				:= ''
	Local 	cAlm			:= ''
	Local 	cF1_FORNECE	:= ''
	Local 	cF1_LOJA		:= ''
	Local	cF1_COND		:= ''
	Local 	nDecim			:= TamSX3("D1_VUNIT")[2] //NUMERO DECIMALES
	Local 	nValCer		:= 0
	Local 	cValCer		:= ''
	Local 	lPasa			:= .T.
	Local 	aAutoErro		:= {}
	Local 	_aCalcIva		:= {}

	_PaCalcIva	:= Nil

	cValcer	:= '.' + STRZERO(1,nDecim)

	nValcer:=val(cValCer)

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida que exista la TES para la factura de impuestos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/

	DBSelectArea("SF4")
	SF4->(DBSetOrder(1))
	If !SF4->(DBSeek(xFilial("SF4")+CTES))
		aAdd(aLogErro, {STR0004}) //"No existe TES para factura de impuestos verifique el parametro MV_MXTESIM"
		lRet := .F.
		Return lret
	Else
		cCF := SF4->F4_CF
	EndIf

	SB1->(DBSetOrder(1))
	RSA->(DBSetOrder(1))
	RSL->(DBSetOrder(1))
	SF1->(DBSetOrder(1))
	SF2->(DBSetOrder(1))
	DB9->(DBSetOrder(1))
	RSC->(DBSetOrder(1))

	If !RSC->(DBSeek(CFILRSC+cPedOri))
		aAdd(aLogErro, {STR0005+cPedOri}) //"No existe el pedimento origen "
		lRet:= .F.
	Else
		If !DB9->(DBSeek(CFILDB9+RSC->RSC_AGENTE))
			aAdd(aLogErro, {STR0006+RSC->RSC_AGENTE}) //"No existe el Cod. de proveedor para el agente "
			lRet := .F.
		Else
			lPasa := .T.
			If RSC->RSC_TIPDOC == 'NCP'
				If !SF2->(DBSeek(xFilial("SF2")+RSC->RSC_FACIMP+RSC->RSC_SERIMP+DB9->DB9_PROV+DB9->DB9_TDA))
					aAdd(aLogErro, {STR0007+RSC->RSC_FACIMP+RSC->RSC_SERIMP +STR0008})  //"No existe la Nota de crédito "," en compras!"
					lRet	:= .F.
					lPasa	:= .F.
				Else
					cF1_FORNECE	:= SF2->F2_CLIENTE
					cF1_LOJA		:= SF2->F1_LOJA
					cF1_COND		:= SF2->F2_COND
				EndIf
			Else
				If !SF1->(DBSeek(xFilial("SF1")+RSC->RSC_FACIMP+RSC->RSC_SERIMP+DB9->DB9_PROV+DB9->DB9_TDA))
					aAdd(aLogErro, {STR0009+RSC->RSC_FACIMP+RSC->RSC_SERIMP +STR0010}) //"No existe el documento "," en compras!"
					lRet	:= .F.
					lPasa	:= .F.
				Else
					cF1_FORNECE	:= SF1->F1_FORNECE
					cF1_LOJA		:= SF1->F1_LOJA
					cF1_COND		:= SF1->F1_COND
				EndIf
			EndIf
			RSC->(DBGoTo(nRegTmp      ))
			If lPasa
				aAdd(aCabs, {"F1_FILIAL " , xFilial("SF1")	, Nil})
				aAdd(aCabs, {"F1_TIPO"    , "C"					, Nil})
				aAdd(aCabs, {"F1_FORMUL"  , "N"					, Nil})
				aAdd(aCabs, {"F1_DOC"     , cnumfac			, Nil})
				aAdd(aCabs, {"F1_SERIE"   , cSerFac			, Nil})
				aAdd(aCabs, {"F1_EMISSAO" , RSC->RSC_FCHPGO	, Nil})
				aAdd(aCabs, {"F1_FORNECE" , cF1_FORNECE		, Nil})
				aAdd(aCabs, {"F1_LOJA"    , cF1_LOJA			, Nil})
				aAdd(aCabs, {"F1_ESPECIE" , "NDP"				, Nil})
				aAdd(aCabs, {"F1_COND"    , cF1_COND			, Nil})
				aAdd(aCabs, {"F1_TIPODOC" , "09"				, Nil})
				aAdd(aCabs, {"F1_MOEDA"   , 1					, Nil})
				aAdd(aCabs, {"F1_TXMOEDA" , 1.00				, Nil})
				aAdd(aCabs, {"F1_DTDIGIT" , dDataBase			, Nil})

				For NX := 1 To Len(aDifImp)
					If aDifImp[NX,2]<>0
		            	/*
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
						//³Extrae como producto, el codigo del impuesto³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù
						*/
						cCodPrd	:= ''
						cUm		:= ''
						cAlm	:= ''
						
						 
							
							cCodPrd := aDifImp[NX,1]
							
							If SB1->(DBSeek(CFILSB1+cCodPrd))
							    If alltrim(cCodprd)=='IVA'
							    	aDifImp[nx,2]:=.01
							    endif
								cUm		:= SB1->B1_UM
								cAlm	:= SB1->B1_LOCPAD
								aAdd(_aCalcIva,{cCodPrd,0,0})
								aAdd(aItens, {})
								cItem	:= soma1(cItem)
								aAdd(aItens[Len(aItens)], {"D1_FILIAL"  , xFilial("SD1")		, Nil})
								aAdd(aItens[Len(aItens)], {"D1_DOC"     , cnumfac				, Nil})
								aAdd(aItens[Len(aItens)], {"D1_SERIE"   , cSerFac				, Nil})
								aAdd(aItens[Len(aItens)], {"D1_FORNECE" , cF1_FORNECE			, Nil})
								aAdd(aItens[Len(aItens)], {"D1_LOJA"    , cF1_LOJA				, Nil})
								aAdd(aItens[Len(aItens)], {"D1_EMISSAO" , RSC->RSC_FCHPGO		, Nil})
								AAdd(aItens[Len(aItens)], {"D1_DTDIGIT" , dDataBase				, Nil})
								aAdd(aItens[Len(aItens)], {"D1_ESPECIE" , "NDP"					, Nil})
								aAdd(aItens[Len(aItens)], {"D1_TIPODOC" , "09"					, Nil})
								aAdd(aItens[Len(aItens)], {"D1_TIPO"    , "C"						, Nil})
								aAdd(aItens[Len(aItens)], {"D1_FORMUL"  , "N"						, Nil})
								aAdd(aItens[Len(aItens)], {"D1_ITEM"    , cItem					, Nil})
								aAdd(aItens[Len(aItens)], {"D1_COD"     , cCodPrd				, Nil})
								aAdd(aItens[Len(aItens)], {"D1_UM"      , cUm						, Nil})
								aAdd(aItens[Len(aItens)], {"D1_QUANT"   , 1						, Nil})
								aAdd(aItens[Len(aItens)], {"D1_VUNIT"   , ABS(aDifImp[nx,2])	, Nil})
								aAdd(aItens[Len(aItens)], {"D1_TOTAL"   , ABS(aDifImp[nx,2])	, Nil})
								aAdd(aItens[Len(aItens)], {"D1_LOCAL"   , cAlm					, Nil})
								aAdd(aItens[Len(aItens)], {"D1_TES"     , cTes					, Nil})
								aAdd(aItens[Len(aItens)], {"D1_PEDIM"   , CPEDREC				, Nil})
								aAdd(aItens[Len(aItens)], {"D1_CF"      , cCF					, Nil})
								aAdd(aItens[Len(aItens)], {"D1_CIFPROR" , 0						, Nil})
							Else
								aAdd(aLogErro, {STR0011+cCodPrd}) //"No existe el codigo de producto "
							EndIf
						
					EndIf

				Next

				If  (Len(aCabs) > 0 .And. Len(aItens) > 0)
              	//Calculo del iva para la factura
					for nx := 1 To Len(_aCalcIva)
						_aCalcIva[nx,3] := nBase / (Len(_aCalcIva)) //BASIMP
						_aCalcIva[nx,2] := _aCalcIva[nx,3] * (RSC->RSC_IVA / 100	) //VALIMP

					Next
					_PaCalcIva := _aCalcIva

					BeginTran()

					lMSErroAuto	:= .F.

					MaFisEnd()

					cDocTipo		:= 'CA' //NOTA DE CARGO

					MSExecAuto({|x,y,z,a| MATA466N(x,y,z,a)},aCabs,aItens,nTipoAcc)

					If lMSErroAuto
						aAdd(aLogErro, {STR0013+AllTrim(cnumfac)+" "+cSerFac+STR0014}) //"Rutina automatica, al generar la NOTA DE CARGO "," encontro los errores : "
						aAutoErro := GETAUTOGRLOG()
						for nx := 1 To Len(aAutoErro)
							aAdd(aLogErro, {aAutoErro[nx]})
						Next
						DisarmTransaction()
						lRet := .F.
					Else
						//asigna la factura de impuestos al pedimento
						RSC->(DBGoTo(nRegTmp))
						reclock("RSC",.F.)
						RSC->RSC_FACIMP	:= cnumfac
						RSC->RSC_SERIMP	:= cSerfAC
						RSC->RSC_TIPDOC	:= "NDP"
						RSC->(MSUNLOCK())

						EndTran()

						M447CSX6("MV_MXSECNC","F1_DOC",cnumfac) //Actualiza parametro con consecutivo

						If VldLibMet()
							cSubRutina := "Generacion_documentos_pedimento_rectificacion" + IIf(lAutoTeste, "_auto", "")
							FwCustomMetrics():setSumMetric(cSubRutina, cIdMetRet, 1,/*dDateSend*/, /*nLapTime*/, "MATA447C")
						EndIf
					EndIf
					MsUnlockAll()
				EndIf
			EndIf
		EndIf
	EndIf
	RSC->(DBGoTo(nRegTmp))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M447CTraspa     ºAutor  ³Gpe Santacruz       ºFecha ³  05/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Genera traspaso entre almacenes                                  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  M447CTraspa   ()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  aExp1.- Arreglo con las partidas que tienen dif.en cantidad     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  lExp1.- .T. si no hay errores                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³                                      Importaciones - Mexico      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M447CTraspa(aDifFac)

	Local lRet		:= .T.
	Local cfilSD1	:= xFilial("SD1")

	Local cFilSB2	:= xFilial("SB2")
	Local nx		:= 0
	Local cNumSeq	:= ""
	Local aCm		:= {}

	Local nCan		:= 0
	Local cPrd		:= ''

	Local cDocSt	:= GetMV("MV_MXSECMI") //Consecutivo de documentos de movtos internos
	If Len(aDifFac) == 0
		Return .T.
	EndIf
	SD1->(DBSetOrder(1))

	If empty(cDocSt)
		MsgAlert(STR0015) //"El parametro MV_MXSECMI esta vacio, debe contener el consecutivo de Dcocumentos de movimientos internos!"
		lRet := .F.
		Return lRet
	EndIf

	/*
	//Contenido de aDifFac
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
	//³1 - Factura           ³
	//³2 - Serie             ³
	//³3 - Proveedor         ³
	//³4 - Tienda            ³
	//³5 - Item              ³
	//³6 - Producto          ³
	//³7 - Cant Ori- Cant Rec³
	//³8 - RSE_EXTFAC        ³
	//³9 - Alamcen entrada   ³
	//³10- Cant. Seg UM      ³
	//³11- Num registro RSE  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
	*/
	For nx := 1 To Len(aDifFac)
		cNumSeq	:= ProxNum()
		cAlmext	:= ''
		If SD1->(DBSeek(CFILSD1+aDifFac[nx,1]+aDifFac[nx,2]+aDifFac[nx,3]+aDifFac[nx,4]+aDifFac[nx,6]+aDifFac[nx,5]))
			cAlmext := SD1->D1_LOCAL
		EndIf
		cAlmPed := aDifFac[nx,9]
		If aDifFac[nx,7]>0
			cAlmSal := cAlmext
			cAlmEnt := cAlmPed
		Else
			cAlmSal := cAlmPed
			cAlmEnt := cAlmext
		EndIf
		cPrd := aDifFac[nx,6]
		nCan := aDifFac[nx,7]

       /*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Movimimiento de Salida     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		If NCAN < 0
			SB2->(DbSetOrder(1))
			If !SB2->(DbSeek(cFilSB2+cPrd+cAlmSal))
				CriaSB2(cPrd,cAlmSal)
			EndIf
			aCM := PegaCMAtu(cPrd,cAlmSal)

			RecLock("SD3",.T.)
			SD3->D3_FILIAL	:= xFilial("SD3")
			SD3->D3_COD		:= cPrd
			SD3->D3_QUANT		:= nCan * (-1)
			SD3->D3_CF			:= "RE4"
			SD3->D3_CHAVE		:= "E0"
			SD3->D3_LOCAL		:= cAlmSal
			SD3->D3_DOC		:= cDocSt
			SD3->D3_EMISSAO	:= dDatabase
			SD3->D3_UM			:= SB1->B1_UM
			SD3->D3_GRUPO		:= SB1->B1_GRUPO
			SD3->D3_TIPO		:= SB1->B1_TIPO
			SD3->D3_NUMSEQ	:= cNumSeq
			SD3->D3_QTSEGUM	:= ConvUm(SB1->B1_COD,nCan,0,2)
			SD3->D3_SEGUM		:= SB1->B1_SEGUM
			SD3->D3_TM			:= "999"
			SD3->D3_NUMPED	:= RSC->RSC_NUMPED
			SD3->D3_TIPODOC	:= "TR"

			aCusto := GravaCusD3(aCM)
			B2AtuComD3(aCusto)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Genera movimiento ENTRADA    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If NCAN > 0
			DBSelectArea("SB2")
			DBSetOrder(1)
			If ( !MsSeek(xFilial("SB2")+cprd+cAlmEnt) )
				CriaSB2(cprd,cAlmEnt)
			EndIf
			aCM := PegaCMAtu(cPrd,cAlmEnt)
			RecLock("SD3",.T.)
			SD3->D3_FILIAL	:= xFilial("SD3")
			SD3->D3_COD		:= cprd
			SD3->D3_QUANT		:= nCan
			SD3->D3_CF			:= "DE4"
			SD3->D3_CHAVE		:= "E9"
			SD3->D3_LOCAL		:= cAlmEnt
			SD3->D3_DOC		:= cDocSt
			SD3->D3_EMISSAO	:= dDatabase
			SD3->D3_UM			:= SB1->B1_UM
			SD3->D3_GRUPO		:= SB1->B1_GRUPO
			SD3->D3_TIPO		:= SB1->B1_TIPO
			SD3->D3_NUMSEQ	:= cNumSeq
			SD3->D3_QTSEGUM	:= ConvUm(cPrd,nCan,0,2)
			SD3->D3_SEGUM		:= SB1->B1_SEGUM
			SD3->D3_TM			:= "499"
			SD3->D3_NUMPED	:= RSC->RSC_NUMPED
			SD3->D3_TIPODOC	:= "TR"

			aCusto := GravaCusD3(aCM)
			B2AtuComD3(aCusto)
		EndIf
	Next
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Marca que se realizo traspaso³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	for nx := 1 To Len(aDifFac)
		RSE->(DBGoTo(aDifFac[nx,11]))
		If !RSE->(Eof())
			Reclock("RSE",.F.)
			RSE->RSE_OKT := 'S'
			RSE->(MSUNLOCK())
		EndIf
	Next
	//Graba el numero de traspaso que corresponde al pedimento
	DBSelectArea("SD3")
	SD3->(DBSetOrder(RETORDEM("SD3","D3_FILIAL+D3_NUMPED+D3_TIPODOC+D3_ESTORNO")))
	If SD3->(DBSeek(xFilial("SD3")+RSC->RSC_NUMPED+"TR"+" "))
		reclock("RSC",.F.)
		RSC->RSC_DOCTRA := SD3->D3_DOC
		RSC->(MSUNLOCK())
	EndIf
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Extrae consecutivo de doctos internos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	M447CSX6("MV_MXSECMI",'D3_DOC',cdOCsT) //Actualiza parametro con consecutivo

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M447CNCR        ºAutor  ³Gpe Santacruz       ºFecha ³  06/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Genera NOTA CREDITO por la diferencia de impuestos               º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  M447CNCR    ()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  aExp1.- Arreglo con las partidas que tienen dif.en cantidad     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  lExp1.- .T. si no hay errores                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³                                      Importaciones - Mexico      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M447CNCR(aDifImp,nbase)

	Local nRegTmp	:= RSC->(Recno())
	Local cPedOri	:= RSC->RSC_PEDORI
	Local cPedRec	:= RSC->RSC_NUMPED
	Local cNumFac	:= GetMV("MV_MXSENCR") //Consecutivo de nota de credito
	Local cFilSF2	:= xFilial("SF2")
	Local cFilDB9	:= xFilial("DB9")
	Local cFilRSC	:= xFilial("RSC")
	Local cFilSB1	:= xFilial("SB1")
	Local cFilRSL	:= xFilial("RSL")
	Local cFilRSA := xFilial("RSA")

	Local cItem	:= StrZero(0,TamSX3('D2_ITEM')[1]) //Inicia numero de item de la factura

	Local aItens		:= {}
	Local aCabs		:= {}
	Local nx			:= 0
	Local cSerFac		:= ''
	Local cTES			:= GetMV("MV_MXTESNC") //Codigo de TES para NOTAS DE CREDITO de importacion "511"
	Local lRet			:= .T.
	Local cCF			:= ''
	Local cCodPrd		:= ''
	Local cUm			:= ''
	Local cAlm			:= ''
	Local cF1_FORNECE	:= ''
	Local cF1_LOJA	:= ''
	Local cF1_COND	:= ''
	Local nDecim		:= TamSX3("D2_PRCVEN")[2] //NUMERO DECIMALES
	Local nValCer		:= 0
	Local cValCer		:= ''
	Local lPasa		:= .T.
	Local aAutoErro	:= {}
	Local _aCalcIva	:=	{}
	_PaCalcIva			:= Nil

	cValcer	:= '.' + STRZERO(1,nDecim)
	nValcer	:= val(cValCer)

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida que exista la TES para la factura de impuestos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	DBSelectArea("SF4")
	SF4->(DBSetOrder(1))
	If !SF4->(DBSeek(xFilial("SF4")+CTES))
		aAdd(aLogErro, {STR0004}) //"No existe TES para factura de impuestos verifique el parametro MV_MXTESIM"
		lRet := .F.
		Return lret
	Else
		cCF := SF4->F4_CF
	EndIf

	SB1->(DBSetOrder(1))
	RSA->(DBSetOrder(1))
	RSL->(DBSetOrder(1))
	SF1->(DBSetOrder(1))
	SF2->(DBSetOrder(1))
	DB9->(DBSetOrder(1))
	RSC->(DBSetOrder(1))

	If !RSC->(DBSeek(CFILRSC+cPedOri))
		aAdd(aLogErro, {STR0005+cPedOri}) //"No existe el pedimento origen "
		lRet := .F.
	Else
		If !DB9->(DBSeek(CFILDB9+RSC->RSC_AGENTE))
			aAdd(aLogErro, {STR0006+RSC->RSC_AGENTE}) //"No existe el Cod. de proveedor para el agente "
			lRet := .F.
		Else
			lPasa := .T.
			If RSC->RSC_TIPDOC == 'NCP'
				If !SF2->(DBSeek(xFilial("SF2")+RSC->RSC_FACIMP+RSC->RSC_SERIMP+DB9->DB9_PROV+DB9->DB9_TDA))
					aAdd(aLogErro, {STR0007+RSC->RSC_FACIMP+RSC->RSC_SERIMP +STR0008}) //"No existe la Nota de crédito "," en compras!"
					lRet	:= .F.
					lPasa	:= .F.
				Else
					cF1_FORNECE	:= SF2->F2_CLIENTE
					cF1_LOJA		:= SF2->F2_LOJA
					cF1_COND		:= SF2->F2_COND
				EndIf
			Else
				If !SF1->(DBSeek(xFilial("SF1")+RSC->RSC_FACIMP+RSC->RSC_SERIMP+DB9->DB9_PROV+DB9->DB9_TDA))
					aAdd(aLogErro, {STR0009+RSC->RSC_FACIMP+RSC->RSC_SERIMP +STR0008}) //"No existe el documento " ," en compras!"
					lRet	:= .F.
					lPasa	:= .F.
				Else
					cF1_FORNECE	:= SF1->F1_FORNECE
					cF1_LOJA		:= SF1->F1_LOJA
					cF1_COND		:= SF1->F1_COND
				EndIf
			EndIf
			RSC->(DBGoTo(nRegTmp))
			If lPasa

			   	/*
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica, si ya hay nota de credito generadas de impuestos, la busca y elimina³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				*/
				aAdd(aCabs, {"F2_FILIAL " , xFilial("SF2")	, Nil})
				aAdd(aCabs, {"F2_TIPO"    , "D"					, Nil})
				aAdd(aCabs, {"F2_FORMUL"  , "N"					, Nil})
				aAdd(aCabs, {"F2_DOC"     , cnumfac			, Nil})
				aAdd(aCabs, {"F2_SERIE"   , cSerFac			, Nil})
				aAdd(aCabs, {"F2_EMISSAO" , RSC->RSC_FCHPGO	, Nil})
				aAdd(aCabs, {"F2_CLIENTE" , cF1_FORNECE		, Nil})
				aAdd(aCabs, {"F2_LOJA"    , cF1_LOJA			, Nil})
				aAdd(aCabs, {"F2_ESPECIE" , "NCP"				, Nil})
				aAdd(aCabs, {"F2_COND"    , cF1_COND			, Nil})
				aAdd(aCabs, {"F2_TIPODOC" , "07"				, Nil})
				aAdd(aCabs, {"F2_MOEDA"   , 1					, Nil})
				aAdd(aCabs, {"F2_TXMOEDA" , 1.00				, Nil})
				aAdd(aCabs, {"F2_DTDIGIT" , dDataBase			, Nil})

				For NX := 1 To Len(aDifImp)
					If aDifImp[NX,2] <> 0
		            	/*
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Extrae como producto, el codigo del impuesto³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						*/
						cCodPrd := ''
						cUm		:= ''
						cAlm	:= ''
						
						
							
							cCodPrd := aDifImp[NX,1]
									
							If SB1->(DBSeek(CFILSB1+cCodPrd))
								If alltrim(cCodprd)=='IVA'
							    	aDifImp[nx,2]:=.01
							    endif
								cUm		:= SB1->B1_UM
								cAlm	:= SB1->B1_LOCPAD
								aAdd(_aCalcIva,{cCodPrd,0,0})
								aAdd(aItens, {})
								cItem := soma1(cItem)
								aAdd(aItens[Len(aItens)] , {"D2_FILIAL"  , xFilial("SD2"), Nil})
								aAdd(aItens[Len(aItens)] , {"D2_DOC"     , cnumfac       , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_SERIE"   , cSerFac   , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_FORNECE" , cF1_FORNECE  , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_LOJA"    , cF1_LOJA   , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_EMISSAO" , RSC->RSC_FCHPGO , Nil})
								AAdd(aItens[Len(aItens)] , {"D2_DTDIGIT" , dDataBase       , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_ESPECIE" , "NCP"            , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_TIPODOC" , "07"            , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_TIPO"    , "D"             , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_FORMUL"  , "N"             , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_ITEM"    , cItem   , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_COD"     , cCodPrd , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_UM"      , cUm     , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_QUANT"   , 1       , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_PRCVEN"   , ABS(aDifImp[nx,2]), Nil})
								aAdd(aItens[Len(aItens)] , {"D2_TOTAL"   , ABS(aDifImp[nx,2]), Nil}) //
								aAdd(aItens[Len(aItens)] , {"D2_LOCAL"   , cAlm   , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_TES"     ,cTes    , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_NUMPED"  ,CPEDREC    , Nil})
								aAdd(aItens[Len(aItens)] , {"D2_CF"      , cCF    , Nil})
							Else
								aAdd(aLogErro, {STR0011+cCodPrd}) //"No existe el codigo de producto "
							EndIf
											EndIf

				Next
				If  (Len(aCabs) > 0 .And. Len(aItens) > 0)
					//Calculo del iva para la factura
					nBase := abs(nbase)
					for nx := 1 To Len(_aCalcIva)
						_aCalcIva[nx,3] := nBase / (Len(_aCalcIva)) //BASIMP
						_aCalcIva[nx,2] := _aCalcIva[nx,3] * (RSC->RSC_IVA / 100) //VALIMP
					Next
					_PaCalcIva := _aCalcIva

					BeginTran()
					lMSErroAuto := .F.
					MaFisEnd()
					cDocTipo := 'CR' //NOTA DE CREDITO
					MSExecAuto({|x,y,z,a| MATA466N(x,y,z,a)},aCabs,aItens,nTipoAcc)
					If lMSErroAuto
						aAutoErro := GETAUTOGRLOG()
						aAdd(aLogErro, {STR0013+AllTrim(cnumfac)+" "+cSerFac+STR0014}) //"Rutina automatica, al generar la NOTA DE CREDITO "," encontro los errores : "
						for nx := 1 To Len(aAutoErro)
							aAdd(aLogErro, {aAutoErro[nx]})
						Next
						DisarmTransaction()
						lRet := .F.
					Else
						//asigna la factura de impuestos al pedimento
						RSC->(DBGoTo(nRegTmp      ))
						reclock("RSC",.F.)
						RSC->RSC_FACIMP	:= cnumfac
						RSC->RSC_SERIMP	:= cSerfAC
						RSC->RSC_TIPDOC	:= "NCP"
						RSC->(MSUNLOCK())
						EndTran()
						M447CSX6("MV_MXSENCR","F2_DOC",cnumfac) //Actualiza parametro con consecutivo
						If VldLibMet()
							cSubRutina := "Generacion_documentos_pedimento_rectificacion" + cPaisLoc + IIf(lAutoTeste, "_auto", "")
							FwCustomMetrics():setSumMetric(cSubRutina, cIdMetRet, 1, /*dDateSend*/, /*nLapTime*/, "MATA447C")
						EndIf
					EndIf
					MsUnlockAll()
				EndIf
			EndIf
		EndIf
	EndIf
	RSC->(DBGoTo(nRegTmp))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT447CABORRA   º Autor ³  Gpe Santacruz     ºFecha ³  06/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Desc.     ³ Borra documentos existentes primero                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MT447CABORRA()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Importaciones - Mexico                                           ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MT447CABORRA()

	Local lM447C5R1AN := ExistBlock("M447C5R1AN")

	If lM447C5R1AN
		ExecBlock("M447C5R1AN",.F.,.F.)
	EndIF

	If RSC->RSC_TIPDOC == 'NCP' //Nota de credito
		M447CElimR("D")
	Else //Nota de cargo
		M447CElimA("C")
	EndIf

	M447CMOVINT("IN",.T.)
	M447CMOVINT("FP",.T.)
	MT447BTRASPASO(.t.)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M447CElimR  	  ºAutor  ³Gpe Santacruz       ºFecha ³  06/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Elimina nota de credito                                          º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  M447CElimR()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³                                    - Importaciones - Mexico      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M447CElimR(ctipo)

	Local lRet		:= .T.

	Local aCabs	:= {}
	Local aItens	:= {}

	Local cnumfac	:= ''
	Local cSer		:= ''
	Local cPrv		:= ''
	Local cTda		:= ''


	Local cFilSF2	:= xFilial("SF2")
	Local cFilSD2	:= xFilial("SD2")
	Local cFilRSE	:= xFilial("RSE")

	Local cAliasSF1	:= ''
	Local aAutoErro	:= {}
	Local nx		:= 0
	Local cPrd1		:=""
	Local cAlm1		:=""

	DBSelectArea("SF2")
	DBSelectArea("SD2")
	DBSelectArea("RSE")

	cnumfac	:= RSC->RSC_FACIMP+RSC->RSC_SERIMP
	cPrv		:= ''
	cTda		:= ''

	DB9->(DBSetOrder(1))
	If DB9->(DBSeek(xFilial("DB9")+RSC->RSC_AGENTE))
		cPrv	:= DB9->DB9_PROV
		cTda	:= DB9->DB9_TDA
	EndIf

	ProcRegua (1)
	SF2->(DBSetOrder(1))
	If SF2->(DBSeek(cFilSF2+RSC->RSC_FACIMP+RSC->RSC_SERIMP+cPrv+cTda))
		IncProc(STR0017+RSC->RSC_FACIMP+RSC->RSC_SERIMP) //"Eliminando NCR "
		SX3->(DBSetOrder(1))
		If SX3->(DBSeek("SF2"))
			Do While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SF2"
				If SX3->X3_CONTEXT<>'V'
					aAdd(aCabs, {SX3->X3_CAMPO , &("SF2->"+SX3->X3_CAMPO), Nil})
				EndIf
				SX3->(DBSkip())
			EndDo
		EndIf
		SD2->(DBSetOrder(3))
		SD2->(DBSeek(CFILSD2+RSC->RSC_FACIMP+RSC->RSC_SERIMP+cPrv+cTda))
		Do While !SD2->(Eof()) .and. cFilSD2+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA==SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
			aAdd(aItens, {})
			SX3->(DBSetOrder(1))
			If SX3->(DBSeek("SD2"))
				Do While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO=="SD2"
					If SX3->X3_CONTEXT<>'V'
						aAdd(aItens[Len(aItens)] , {SX3->X3_CAMPO  ,&("SD2->"+SX3->X3_CAMPO), Nil})
					EndIf
					SX3->(DBSkip())
				EndDo
			EndIf
			SD2->(dbSkip())
		EndDo
		If  (Len(aCabs)>0 .And. Len(aItens)>0)

			BeginTran()

			lMSErroAuto := .F.

			MaFisEnd()

			cDocTipo := 'CR'

			MSExecAuto({|x,y,z,a| MATA466N(x,y,z,a)},aCabs,aItens,5)

			If lMSErroAuto

				DisarmTransaction()
				aAdd(aLogErro, {STR0018+AllTrim(cnumfac)+STR0014}) //"Rutina Automatica, al Eliminar la NOTA DE CREDITO "," encontro los errores : "
				aAutoErro := GETAUTOGRLOG()
				for nx := 1 To Len(aAutoErro)
					aAdd(aLogErro, {aAutoErro[nx]})
				Next
				lRet:= .F.
			Else
				reclock("RSC",.F.)
				RSC->RSC_FACIMP	:= ""
				RSC->RSC_SERIMP	:= ""
				RSC->RSC_TIPDOC	:= ""
				RSC->(MSUNLOCK())
				lRet := .T.

				EndTran()

			EndIf
			MsUnlockAll()
		EndIf
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M447CElimA	  ºAutor  ³Gpe Santacruz       ºFecha ³  06/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Elimina nota de cargo                                            º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºSintaxe   ³ M447CElimA()                                                     º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³                                                                  º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºUso       ³ Importaciones - Mexico                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M447CElimA(ctipo)

	Local lRet		:= .T.

	Local aCabs	:= {}
	Local aItens	:= {}

	Local cnumfac	:= ''
	Local cSer		:= ''
	Local cPrv		:= ''
	Local cTda		:= ''


	Local cFilSF2	:= xFilial("SF1")
	Local cFilSD2	:= xFilial("SD1")
	Local cFilRSE	:= xFilial("RSE")

	Local cAliasSF1	:= ''
	Local aAutoErro	:= {}
	Local nx			:= 0

	DBSelectArea("SF1")
	DBSelectArea("SD1")
	DBSelectArea("RSE")

	cnumfac	:= RSC->RSC_FACIMP+RSC->RSC_SERIMP
	cPrv		:= ''
	cTda		:= ''
	DB9->(DBSetOrder(1))
	If DB9->(DBSeek(xFilial("DB9")+RSC->RSC_AGENTE))
		cPrv	:= DB9->DB9_PROV
		cTda	:= DB9->DB9_TDA
	EndIf

	ProcRegua (1)
	SF1->(DBSetOrder(1))
	If SF1->(DBSeek(cFilSF2+RSC->RSC_FACIMP+RSC->RSC_SERIMP+cPrv+cTda+ctipo))
		IncProc(STR0019+RSC->RSC_FACIMP+RSC->RSC_SERIMP) //"Eliminando NCA "
		SX3->(DBSetOrder(1))
		If SX3->(DBSeek("SF1"))
			Do While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SF1"
				If SX3->X3_CONTEXT<>'V'
					aAdd(aCabs, {SX3->X3_CAMPO , &("SF1->"+SX3->X3_CAMPO), Nil})
				EndIf
				SX3->(DBSkip())
			EndDo
		EndIf
		SD1->(DBSetOrder(1))
		SD1->(DBSeek(CFILSD2+RSC->RSC_FACIMP+RSC->RSC_SERIMP))
		Do While !SD1->(Eof()) .and. cFilSF2+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA==SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			aAdd(aItens, {})
			SX3->(DBSetOrder(1))
			If SX3->(DBSeek("SD1"))
				Do While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SD1"
					If SX3->X3_CONTEXT<>'V'
						aAdd(aItens[Len(aItens)] , {SX3->X3_CAMPO  ,&("SD1->"+SX3->X3_CAMPO), Nil})
					EndIf
					SX3->(DBSkip())
				EndDo
			EndIf
			SD1->(dbSkip())
		EndDo
		If  (Len(aCabs) > 0 .And. Len(aItens) > 0)

			BeginTran()

			lMSErroAuto := .F.

			MaFisEnd()

			cDocTipo:='CA'

			MSExecAuto({|x,y,z,a| MATA466N(x,y,z,a)},aCabs,aItens,5)

			If lMSErroAuto
				DisarmTransaction()
				aAdd(aLogErro, {STR0013+AllTrim(cnumfac)+STR0014})	//"Rutina automatica, al generar la NOTA DE CARGO "," encontro los errores : "
				aAutoErro := GETAUTOGRLOG()
				for nx := 1 To Len(aAutoErro)
					aAdd(aLogErro, {aAutoErro[nx]})
				Next
				lRet := .F.
			Else
				reclock("RSC",.F.)
				RSC->RSC_FACIMP:=""
				RSC->RSC_SERIMP :=""
				RSC->RSC_TIPDOC :=""
				RSC->(MSUNLOCK())
				lRet:= .T.

				EndTran()

			EndIf
			MsUnlockAll()
		EndIf
	EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M447CSX6   	  ºAutor  ³Gpe Santacruz       ºFecha ³  06/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Actualiza parametros con consecutivo                             º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºSintaxe   ³ M447CSX6()                                                       º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³                                                                  º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºUso       ³ Importaciones - Mexico                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M447CSX6(cParam,cCampo,cDoc)

	Local nTamDoc	:= TamSX3(cCampo)[1]
	Local cDocNew	:= SOMA1(ALLTRIM(cDoc),nTamDoc)

	SX6->(DBSetOrder(1))
	If SX6->(DBSeek(xFilial("SX6")+cParam))
		reclock("SX6",.F.)
		SX6->X6_CONTEUD	:= ALLTRIM(cDocNew)
		SX6->X6_CONTSPA	:= ALLTRIM(cDocNew)
		SX6->X6_CONTENG	:= ALLTRIM(cDocNew)
		SX6->(MSUNLOCK())
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M447CMovInt    º Autor ³    Gpe Santacruz   ºFecha ³  07/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Genera movimientos internos x dif. en Impuestos o Incrementables º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M447CMovInt()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ Importaciones - Mexico                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M447CMOVINT(cTipoDoc,lBorra,aDifVal)

	//FP=Movimiento interno de factura de impuestos  IN=Movimiento interno de incrementables

	Local lRet			:= .T.
	Local aCab			:= {}
	Local aItem		:= {}
	Local cfilSD3		:= xfilial("SD3")
	Local cFilSB2		:= xFilial("SB2")
	Local nTotCif		:= 0
	Local nValDesp	:= 0
	Local cAlmacen	:= ''
	Local cNumSeq		:= ""
	Local aCm			:= {}
	Local aSd3			:= {}
	Local nCntFor		:= 0
	Local nCntFor2	:= 0

	Local cDocSt		:= GetMV("MV_MXSECMI") //Consecutivo de documentos de movtos internos
	Local cDocNew		:= ''
	Local nTamDoc		:= 0
	Local nj			:= 0
	Local aMasCabs	:= {}
	Local aMasItems	:= {}
	Local nx			:= 0
	Local aAutoErro	:= {}

	SB2->(DBSetOrder(1))

	If !lBorra
		If Empty(cDocSt)
			MsgAlert(STR0015) //"El parametro MV_MXSECMI esta vacio, debe contener el consecutivo de Documentos de movimientos internos!"
			lRet:= .F.
		EndIf
		IncProc(STR0020+cDocSt) //"Generando movimiento interno ... "
		SD3->(DBSetOrder(RETORDEM("SD3","D3_FILIAL+D3_NUMPED+D3_TIPODOC+D3_ESTORNO")))
		If sd3->(DBSeek(xfilial("SD3")+RSC->RSC_NUMPED+CTIPODOC+" "))

			Do While !sd3->(Eof()) .and. cfilsd3 == sd3->d3_filial .and. sd3->d3_NUMPED+SD3->D3_TIPODOC+SD3->D3_ESTORNO == RSC->RSC_NUMPED+CTIPODOC+' '
				If Empty(sd3->d3_estorno)
					MsgAlert(STR0021+SD3->D3_DOC+STR0022) //"Existe un movimiento de traspaso con el numero de documento :".", eliminelo y vuelva a intentar.."
					Return .F.
				EndIf
				sd3->(DBSkip())
			EndDo
		EndIf
		aCab := {	{"D3_DOC"		, cDocSt		, Nil},;
					{"D3_TM"    	, cTESmovI		, Nil},;
					{"D3_CC"		, ""			, Nil},;
					{"D3_EMISSAO"	, dDataBase	, Nil}}

		For NX := 1 To Len(aDifVal)
			If aDifVal[nx,2]<>0
				aAdd(aItem, {})
				aAdd(aItem[Len(aItem)],{"D3_FILIAL", CFILSD3, Nil})
				aAdd(aItem[Len(aItem)],{"D3_COD"	, aDifVal[nx, 1] ,Nil})

				cUm	:= ''

				SB1->(DBSetOrder(1))
				If SB1->(DBSeek(xFilial("SB1")+aDifVal[nx,1]))
					cUm	:= SB1->B1_UM
				EndIf
				aAdd(aItem[Len(aItem)], {"D3_UM"		, cUm				, Nil})
				aAdd(aItem[Len(aItem)], {"D3_QUANT"	, 0					, Nil})
				aAdd(aItem[Len(aItem)], {"D3_CUSTO1"	, aDifVal[nx,2]	, Nil} )
				aAdd(aItem[Len(aItem)], {"D3_NUMPED"	, RSC->RSC_NUMPED	, Nil} )
				aAdd(aItem[Len(aItem)], {"D3_TIPODOC"	, cTipoDoc			, Nil} )
				aAdd(aItem[Len(aItem)], {"D3_LOCAL"	, aDifVal[nx,3]	, Nil} )

				//Permite agregar mas campos al SD3
				If (ExistBlock("M447CSD3I"))
					aMasItem := ExecBlock("M447CSD3I",.F.,.F.)
					For nj := 1 To Len(aMasItem)

						aAdd(aItem[Len(aItem)],aMasItem[nj] )
					Next
				EndIf
				If !empty(	aDifVal[nx,3])
					If !SB2->(DbSeek(CFILSB2+aDifVal[nx,1] + aDifVal[nx,3]))
						CriaSB2(aDifVal[nx,1], aDifVal[nx,3])
					EndIf
				EndIf
			EndIf
		Next

		If Len(aItem) > 0
			BeginTran()

				lMSErroAuto := .F.

				MSExecAuto({|x,y| MATA241(x,y)},aCab,aItem,3)

				If  lMsErroAuto
					DisarmTransaction()
					aAdd(aLogErro, {STR0023}) //"Rutina Automatica, Al Generar el Traspaso encontro los errores : "
					aAutoErro := GETAUTOGRLOG()
					for nx := 1 To Len(aAutoErro)
						aAdd(aLogErro, {aAutoErro[nx]})
					Next
					lRet := .F.
				Else
					If CTIPODOC == 'IN'
						DBSelectArea("SD3")
						SD3->(DBSetOrder(RETORDEM("SD3","D3_FILIAL+D3_NUMPED+D3_TIPODOC+D3_ESTORNO")))
						If SD3->(DBSeek(xFilial("SD3")+RSC->RSC_NUMPED+CTIPODOC+" "))
							reclock("RSC",.F.)
							RSC->RSC_DOCINC := SD3->D3_DOC
							RSC->(MSUNLOCK())
						EndIf
					EndIf
				EndTran()
			EndIf
			MsUnlockAll()
			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Extrae consecutivo de doctos internos     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			*/
			M447CSX6("MV_MXSECMI",'D3_DOC',cDocSt)
		EndIf
	Else
		DBSelectArea("SD3")
		SD3->(DBSetOrder(RETORDEM("SD3","D3_FILIAL+D3_NUMPED+D3_TIPODOC+D3_ESTORNO")))
		IncProc(STR0024) //"Eliminando movimiento internos ... "
		Do While .T.
			If SD3->(DBSeek(CFILSD3+RSC->RSC_NUMPED+CTIPODOC+" "))
				Aadd(aSd3,{})
				For nCntFor := 1 To SD3->(FCount())
					Aadd(aSD3[Len(aSD3)],SD3->(FieldGet(nCntFor)))
				Next nCntFor
				RecLock("SD3",.F.)
				SD3->D3_ESTORNO := "S"
				SD3->(MSUNLOCK())
			Else
				EXIT
			EndIf

		EndDo
		For nCntFor := 1 To Len(aSd3)
			RecLock("SD3",.T.)
			For nCntFor2 := 1 To Len(aSd3[nCntFor])
				SD3->(FieldPut(nCntFor2,aSd3[nCntFor][nCntFor2]))
			Next nCntFor2

			SD3->D3_CF     := "RE6"
			SD3->D3_TM     := "999"
			SD3->D3_ESTORNO:= "S"
			SD3->D3_EMISSAO:= dDataBase
			SD3->D3_DTLANC := CtoD("")
			aCusto := PegaCusD3()
			B2AtuComD3(aCusto)

		Next nCntFor

		If cTipoDOC == 'IN'
			reclock("RSC",.F.)
			RSC->RSC_DOCINC := ''
			RSC->(MSUNLOCK())
		EndIf
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CalcBseIva      ºAutor  ³Gpe Santacruz       ºFecha ³  04/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Incluye los impuestos de importacion que participaran de la     º±±
±±º          ³  base de iva                                                     º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  CalcBseIva  (cExpr1,nExp1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  cExpr1 - Numero del pedimento                                   ³±±
±±³          ³  nExpr1 - Valor aduana en pesos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³                                      Importaciones - Mexico      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CalcBseIva(cNPedi,nValAdu)

	Local cFilRSL	:= xFilial("RSL")
	Local cFilRSA	:= xFilial("RSA")
	Local nTotImp	:= nValAdu
	
	DBSelectArea ("RSA")
	RSA->(DBSetOrder(1))
	DBSelectArea ("RSL")
	RSL->(DBSetOrder(1))
	RSL->(DBSeek(xFilial("RSL")+cNPedi))

	//Recorre todos los impuestos que estan ya calculados en el pedimento
	Do While !RSL->(Eof()) .AND. cFilRSL == RSL->RSL_FILIAL .AND. RSL->RSL_numped == cNPedi
		If RSA->(DBSeek(cFilRSA+RSL->RSL_CODIMP))  //Verifica en catalogo de impuestos de importacion
			If AllTrim(RSA->RSA_APLIVA) == '1' //Solo para impuestos que apliquen IVA
				nTotImp += RSL->RSL_import
			EndIf
		ENDIF
		RSL->(DBSkip())
	EndDo

Return nTotImp

/*/{Protheus.doc} VldLibMet
Función utilizada para validar si el ambiente tiene la libreria para
utilización de Metrícas Protheus.

@type  Static Function
@author eduardo.manriquez
@since 13/09/2021
/*/
Static Function VldLibMet()
	Local lRet	:= .F.

	lRet := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')

Return lRet
