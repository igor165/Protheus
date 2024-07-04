#include 'protheus.ch'
#include 'parmtype.ch'
#include 'locxeua.ch'

#Define ScCliFor    2
#Define SlFormProp  3
#Define SAliasHead  4
#Define ScEspecie   8
#Define ScTipoDoc  10

/*/{Protheus.doc} LxCpoCol
Funcion utilizada para agregar campos al encabezado de
Notas Fiscales para Colombia.
@type Function
@author oscar.lopez
@since 19/05/2021
@version 1.0
@param aCposNF, Array, Array con campos del encabezado de NF
@param cFunName, Character, Codigo de rutina
@param cTablaEnc, Character, Alias del encabezado de Notas Fiscales
@param cEspecie, Character, Especie del encabezado de Notas Fiscales
@example fCposNFEua(aCposNF, cFunName, cTablaEnc, cEspecie)
@return aCposNF, Array, Campos para el Encabezado de Notas Fiscales.
@see (links_or_references)
/*/
Function fCposNFEua(aCposNF, cFunName, cTablaEnc, cEspecie)
	
	Local aSX3 := {}
	
	Default aCposNF 	:= {}
	Default cFunName	:= ""
	Default cTablaEnc	:= ""
	Default cEspecie	:= ""
	
	If cTablaEnc == "SF2" .And. cEspecie $ 'NF|NDC'
		If SF2->(ColumnPos( "F2_CODMUN" )) > 0
			aSX3 := LxSX3EUA("F2_CODMUN")
			AAdd(aCposNF,{FWX3Titulo("F2_CODMUN"),"F2_CODMUN",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
		EndIf
		If SF2->(ColumnPos( "F2_EST" )) > 0
			aSX3 := LxSX3EUA("F2_EST")
			AAdd(aCposNF,{FWX3Titulo("F2_EST"),"F2_EST",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8],".F."})
		EndIf
		If SF2->(ColumnPos( "F2_PROVENT" )) > 0
			aSX3 := LxSX3EUA("F2_PROVENT")
			AAdd(aCposNF,{FWX3Titulo("F2_PROVENT"),"F2_PROVENT",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
		EndIf
		If SF2->(ColumnPos( "F2_ZONGEO" )) > 0
			aSX3 := LxSX3EUA("F2_ZONGEO")
			AAdd(aCposNF,{FWX3Titulo("F2_ZONGEO"),"F2_ZONGEO",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8],".F."})
		EndIf
	    If SF2->(ColumnPos( "F2_TPACTIV" )) > 0
			aSX3 := LxSX3EUA("F2_TPACTIV")
			AAdd(aCposNF,{FWX3Titulo("F2_TPACTIV"),"F2_TPACTIV",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,})
		EndIf
		If cEspecie $ 'NF' .And. SF2->(ColumnPos( "F2_TPFRETE" )) > 0
			aSX3 := LxSX3EUA("F2_TPFRETE")
			AAdd(aCposNF,{FWX3Titulo("F2_TPFRETE"),"F2_TPFRETE",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,})
		EndIf
	EndIf
	
Return aCposNF


/*/{Protheus.doc} LxSX3EUA
Función para obtener datos del SX3 para campos usando la función GetSX3Cache
@type
@author oscar.lopez
@since 19/05/2021
@version 1.0
@param cCampo, caracter, Nombre del campo.
@return aSX3Cpos, array, Arreglo con contenido de la tabla SX3 para el campo.
@see (links_or_references)
/*/
Static Function LxSX3EUA(cCampo)
	Local aSX3Cpos := {}
	
	Default cCampo := "" 
	
	If !Empty(cCampo)
		aSX3Cpos := {GetSX3Cache(cCampo,"X3_PICTURE"), ; //1
		GetSX3Cache(cCampo,"X3_TAMANHO"), ; //2
		GetSX3Cache(cCampo,"X3_DECIMAL"), ; //3
		GetSX3Cache(cCampo,"X3_VALID"), ;   //4
		GetSX3Cache(cCampo,"X3_USADO"), ;   //5
		GetSX3Cache(cCampo,"X3_TIPO"), ;    //6
		GetSX3Cache(cCampo,"X3_CONTEXT"), ; //7
		GetSX3Cache(cCampo,"X3_F3")}        //8
	EndIf
Return aSX3Cpos

/*/{Protheus.doc} LxCanNFEUA
	Función para Cancelación/Anulación vía execauto de NF para Estados Unidos
	Pre-Factura

	@type Function
	@author marco.rivera
	@since 23/09/2021
	@version 1.0
	@param nOpcAuto, Numérico, Opcao da Rotina: 5-Borrado / 6-Anulado
	@param cFunName, Caracter, Nombre del programa en ejecución
	@param lAnulaSF3, Lógico, Indica si se realiza borrado lógico en SF3, .T. = Si y .F. = No
	@param aAutoCab, Arreglo, Arreglo con los datos del encabezado envíados vía automática.
	@param cTablaEnc, Caracter, Alias tabla.
	@param lSeek, Lógico, Posiciona automático en base a los documentos enviados en aAutoCab.
	@example
	LxCanNFEUA(nOpcAuto, cFunName, lAnulaSF3, aAutoCab, aCfgNF, lSeek)
	@return Nil
	@see (links_or_references)
	/*/
Function LxCanNFEUA(nOpcAuto, cFunName, lAnulaSF3, aAutoCab, cTablaEnc, lSeek)
	
	Default nOpcAuto	:= 3 //6-Cancelar/Anular / 5-Exclusion
	Default cFunName	:= ""
	Default aAutoCab	:= {}
	Default cTablaEnc	:= ""
	Default lSeek		:= .T.

	If (nOpcAuto == 6 .And. (cFunName $ "MATA467N"))
		lAnulaSF3 := .T. //Determina si anula o elimina el registro en Libros Fiscales
		MBrowseAuto(5, aClone(aAutoCab), cTablaEnc, lSeek, .T.)
		lAnulaSF3 := .F.
	Else
		MBrowseAuto(nOpcAuto, aClone(aAutoCab), cTablaEnc, lSeek)
	EndIf

Return Nil

/*/{Protheus.doc} LxGenDevRe
	Función que genera título provicional en Devolución de Remito
	Pre-Factura

	@type Function
	@author marco.rivera
	@since 23/09/2021
	@version 1.0
	@param cFunName, Caracter, Nombre del programa en ejecución.
	@param cEspecie, Caracter, Especie de documento.
	@example
	LxGenDevRe(cFunName, cEspecie)
	@return Nil
	@see (links_or_references)
	/*/
Function LxGenDevRe(cFunName, cEspecie)
	Local aAreaSE1	:= SE1->(GetArea())
	Local cFilSE1	:= xFilial('SE1')
	Local cNomFun	:= ""
	Local cDocOri	:= ""
	Local cSerOri	:= ""
	Local cSeek		:= ""
	Local aTitulo	:= {}

	//Indice
	If cFunName == "MATA462DN" 
		If AllTrim(cEspecie) == 'RFN'
			cSeek := cFilSE1 + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_SERIE + SF2->F2_DOC
		ElseIf AllTrim(cEspecie) == 'RFD'
			cSeek := cFilSE1 + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_SERORIG + SF1->F1_NFORIG
		EndIf
	ElseIf cFunName == "MATA475"
		cSeek := cFilSE1 + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_SERIORI + SF2->F2_NFORI
	EndIf

	DbSelectArea('SE1')
	SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

	If MSSeek(cSeek)		
		While SE1->(!EOF()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == cSeek
			aTitulo := { { "E1_PREFIXO"  , SE1->E1_PREFIXO	, NIL },;
			{ "E1_NUM"      , SE1->E1_NUM           		, NIL },;
			{ "E1_PARCELA"  , SE1->E1_PARCELA         		, NIL },;
			{ "E1_TIPO"     , SE1->E1_TIPO 	       			, NIL },;
			{ "E1_CLIENTE"  , SE1->E1_CLIENTE          		, NIL },;
			{ "E1_LOJA" 	, SE1->E1_LOJA          		, NIL },;
			{ "E1_EMISSAO"  , SE1->E1_EMISSAO				, NIL },;
			{ "E1_ORIGEM"   , SE1->E1_ORIGEM				, NIL } }
			MsExecAuto( { |x,y| FINA040(x,y)} , aTitulo, 5 )  // 3 - Inclusión, 4 - Alteración, 5 - Exclusión					
			SE1->(DbSkip())
		EndDo			
	EndIf	

	If cFunName == "MATA462DN" 
		If AllTrim(cEspecie) == 'RFD'
			cNomFun  := 'GravaNfGeral'
			cDocOri  := SF1->F1_NFORIG
			cSerOri  := SF1->F1_SERORIG
		EndIf
		If FindFunction("MATA476FIN")
			MATA476FIN(aHeader, aCols, cNomFun, cDocOri, cSerOri)
		EndIf
	EndIf

	RestArea(aAreaSE1)

Return Nil

/*/{Protheus.doc} LxNFDevMon
	Función que corrige información en la Factura de Devolución genera por
	la rutina MATA475
	Pre-Factura

	@type Function
	@author marco.rivera
	@since 23/09/2021
	@version 1.0
	@param aCitens, Arreglo, Contiene información de los ítems del documento.
	@example
	LxNFDevMon(aCitens)
	@return Nil
	@see (links_or_references)
	/*/
Function LxNFDevMon(aCitens)
	Local aAreaSD1	:= SD1->(GetArea())
	Local cFilSD1	:= xFilial('SD1')

	Default aCitens	:= {}
	
	DbSelectArea('SD1')
	SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM	
	If MSSeek(cFilSD1 + SF1->(F1_DOC + F1_SERIE+ F1_FORNECE + F1_LOJA))
		While SD1->(!Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cFilSD1+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
			SD1->(RecLock('SD1',.F.))
			SD1->D1_NFORI 	:= aCitens[1,24]
			SD1->D1_SERIORI := aCitens[1,25]
			SD1->D1_ITEMORI := aCitens[1,26]
			SD1->(MsUnlock())
			SD1->(DbSkip())
		EndDo
	EndIf
	RestArea(aAreaSD1)
Return Nil


/*/{Protheus.doc} LxEUAAjRem()
	Ajuste do Status do Remito no momento da exclusao da NF gerada por um Remito MATA475

	@type Function
	@author marco.rivera
	@since 01/10/2021
	@version 1.0
	@example
	LxEUAAjRem()
	@return Nil
	/*/
Function LxEUAAjRem()
Local cFunName := FunName()

	//Ajuste para generar titulo provisional de remito
	Local aTitulo	 := {}
	Local aAreaSF2	 := {}
	Local aAreaSE1	 := {}
	Local aAreaSD2	 := {}
	Local cFilSE1	 := xFilial('SE1')
	
	aAreaSF2 := SF2->(GetArea())
	aAreaSD2 := SD2->(GetArea())
	aAreaSE1 := SE1->(GetArea())
	DbSelectArea('SF2')
	DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If cFunName == "MATA462DN"
		MsSeek(xFilial('SF2')+SF1->F1_NFORIG+SF1->F1_SERORIG+SF1->F1_FORNECE+SF1->F1_LOJA)
	ElseIf cFunName == "MATA467N"
		DbSelectArea('SD2')
		DbSetOrder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		MsSeek(xFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)			
		DbSelectArea('SF2')
		DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		MsSeek(xFilial('SF2')+SD2->D2_REMITO+SD2->D2_SERIREM+SD2->D2_CLIENTE+SD2->D2_LOJA)
	Else
		MsSeek(xFilial('SF2')+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
	EndIf	
	
	If Found() .And. AllTRim(SF2->F2_ESPECIE) == 'RFN'
		SF2->(RecLock('SF2'))
		SF2->F2_STATUSR := '0'
		SF2->(MsUnlock())
		
		DbSelectArea('SE1')
		DbSetOrder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		MsSeek(cFilSE1+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC)
		
		If Found()			
			While SE1->(!EOF()) .And. (cFilSE1+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC) == (SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM)				
				
				aTitulo := { { "E1_PREFIXO"  , SE1->E1_PREFIXO	, NIL },;
							{ "E1_NUM"      , SE1->E1_NUM       , NIL },;
							{ "E1_PARCELA"  , SE1->E1_PARCELA   , NIL },;
							{ "E1_TIPO"     , SE1->E1_TIPO 	    , NIL },;
							{ "E1_CLIENTE"  , SE1->E1_CLIENTE   , NIL },;
							{ "E1_LOJA" 	, SE1->E1_LOJA      , NIL },;
							{ "E1_EMISSAO"  , SE1->E1_EMISSAO	, NIL },;
							{ "E1_ORIGEM"   , SE1->E1_ORIGEM	, NIL } }

				MsExecAuto( { |x,y| FINA040(x,y)} , aTitulo,5 )  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão					
				SE1->(DbSkip())
			EndDo	
			MATA476FIN(aHeader,aCols,'LocxDelNF')							
		EndIf			

	EndIf
	RestArea(aAreaSE1)
	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
Return Nil


/*/{Protheus.doc} LxVlNDocEUA
	Valida Número de documento para NCC.
    Función utilizada en  Locxnf en la funcion Locxval y GravaNfGeral. 
	@type  Function
	@author alfredo.medrano	
	@since 03/05/2022
	@version 1.0
	@param cNumAsig, Caracter, Numero de Documento asignado por el usuario.
	@param cSerNCC, Caracter, Serie del Documento NCC.
	@param lMsg, Bolenano, indicara si se muestra mensaje de validación.
	@return nVal 
	@example
	(examples)
	@see (links_or_references)
/*/
Function LxVlNDocEUA(cNumAsig,cSerNCC,lMsg)
Local aArea := GetArea()
Local 	lVal 	:= .T.
Local lSx5V		:= .T.
Local cNumSuj   := ""

Default cNumAsig:= "" 
Default cSerNCC := ""  
Default lMsg	:= .F. 

DBSelectArea("SX5")
SX5->(dbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE 
If !SX5->(dbSeek(xFilial("SX5")+"01"+cSerNCC))
	lSx5V := .F.
EndIf

If lSx5V
	cNumSuj := Alltrim(X5DESCRI())
	If (lMsg .and. cNumAsig > cNumSuj) .OR. (!lMsg .and. cNumAsig <> cNumSuj)
		IIF(lMsg,Aviso(STR0001 ,STR0002 + cNumAsig + STR0003 ,{STR0004}),) //"Atención"###"El número de factura "### " es mayor al número sugerido por el sistema." ###"OK"
		lVal 	:= .F.
	Endif
EndIf

RestArea(aArea)
Return lVal

/*/{Protheus.doc} LxGrvNfEUA
	Graba información para notas fiscales.
	La función es llamada en GravaNfGeral (LOCXNF.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 02/10/2022
	@param 	aCfgNF: Array con la configuración para los documentos fiscales.
			aCitens: Items de NF (aCols).
			cEspecie: Especie del documento fiscal.
			cFunName: Nombre de la función.
	@return lRet: .T. Si cumple con las condiciones.
	/*/
Function LxGrvNfEUA(aCfgNf, aCitens, cEspecie, cFunName)
Local lRet := .T.
Local cPrefC := aCfgNf[SAliasHead]+"->"+PrefixoCpo(aCfgNf[SAliasHead])

Default aCfgNf   := {}
Default aCitens  := {}
Default cEspecie := ""
Default cFunName := ""

	If aCfgNf[SlFormProp]
		If AllTrim(&(cPrefC+"_ESPECIE")) == "NCC" .And. cFunName =="MATA465N" .And. FindFunction("LxVlNDocEUA")
			If LxVlNDocEUA(&(cPrefC+"_DOC"),&(cPrefC+"_SERIE"),.F.)
				lRet := AtuNumNF(&(cPrefC+"_DOC"),&(cPrefC+"_SERIE"),aCfgNf[ScTipoDoc],aCfgNf[ScCliFor])
			EndIf
		EndIf
	EndIf

	//Ajuste para generar título provisional en devolución de remito
	If lRet .And. (cFunName $ 'MATA462DN|MATA475') .And.  FindFunction("LxGenDevRe") //gerar titulo provisorio na devolucao do remito.
		LxGenDevRe(cFunName, cEspecie)
	EndIf

	//Ajuste para corregir información en NF de devolución generada por MATA475
	If lRet .And. cFunName == 'MATA475' .And. AllTrim(cEspecie) != 'NF' .And. FindFunction("LxNFDevMon")
		LxNFDevMon(aCitens)
	EndIf

Return lRet


/*/{Protheus.doc} GFinTrsEUA
	Actualiza información Financiera (SE1/SE2).
	La función es llamada en GravaNfGeral (LOCXNF.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 02/10/2022
	@param cFunName: Nombre de la función.
	@return Nil
	/*/
Function GFinTrsEUA(cFunName)
Default cFunName := ""

	If cPaisLoc == "EUA"
		If SE2->(ColumnPos("E2_SLPLAID")) > 0 .And.  SE1->(ColumnPos("E1_SLPLAID")) > 0
			If cFunName $ "MATA101N"
				RecLock("SE2",.F.)
				REPLACE SE2->E2_SLPLAID With SE2->E2_VALOR
				Replace SE2->E2_BCOPAG  With posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"A2_BANCO")
				SE2->(MsUnlock())
			ElseIf cFunName $ "MATA467N/MATA468N"
				RecLock("SE1",.F.)
				REPLACE SE1->E1_SLPLAID With SE1->E1_VALOR
				REPLACE SE1->E1_PORTADO With posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_BCO1")
				SE1->(MsUnlock())
			EndIf
		EndIf
	Endif

Return Nil


/*/{Protheus.doc} NfTudOkEUA
	Validaciones generales en la inclusión de una nota fiscal.
	La función es llamada en NfTudOk (LOCXNF.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 02/10/2022
	@param 	aCfgNf: Array con la configuración del documento.
			cFunName: Nombre de la función.
	@return lRet: .T. Si cumple con las condiciones.
	/*/
Function NfTudOkEUA(aCfgNf, cFunName)
Local lRet       := .T.

Default aCfgNf   := {}
Default cFunName := ""

	If cFunName $ "MATA101N|MATA465N" .and. Trim(aCfgNf[ScEspecie]) $ "NCC|NF"
		If !(Alltrim(SM0->M0_COD_ATV) $ "1|2") .AND. Empty(SM0->M0_DSCCNA)
			lRet := .F.
			Aviso(STR0005,STR0006 + " y " + STR0007,{STR0004}) //"ATENCION" "No se configuró el campo (M0_COD_ATV) para saber si la empresa es Revendedor o Consumidor final." "OK"
		Else
			If !(Alltrim(SM0->M0_COD_ATV) $ "1|2")
				lRet := .F.
				Aviso(STR0005,STR0006,{STR0004}) //"ATENCION" "No se configuró el campo (M0_COD_ATV) para saber si la empresa es Revendedor o Consumidor final." "OK"
			EndIf
			If Empty(SM0->M0_DSCCNA)
				lRet := .F.
				Aviso(STR0005,STR0007,{STR0004}) //"ATENCION" "No se configuró el campo (M0_DSCCNA) para saber el tipo de actividad de la empresa." "OK"
			EndIf
		EndIf
	EndIf
	If cFunName == "MATA101N" .and. Trim(aCfgNf[ScEspecie]) $ "NF"
		If !(Alltrim(SM0->M0_COD_ATV) $ "1|2") .AND. Empty(SM0->M0_DSCCNA)
			lRet := .F.
			Aviso(STR0005,STR0006 + " y " + STR0007,{STR0004}) //"ATENCION" "No se configuró el campo (M0_COD_ATV) para saber si la empresa es Revendedor o Consumidor final." "No se configuró el campo (M0_DSCCNA) para saber el tipo de actividad de la empresa." "OK"
		Else
			If !(Alltrim(SM0->M0_COD_ATV) $ "1|2")
				lRet := .F.
				Aviso(STR0005,STR0006,{STR0004}) //"ATENCION" "No se configuró el campo (M0_COD_ATV) para saber si la empresa es Revendedor o Consumidor final." "OK"
			EndIf
			If Empty(SM0->M0_DSCCNA)
				lRet := .F.
				Aviso(STR0005,STR0007,{STR0004}) //"No se configuró el campo (M0_DSCCNA) para saber el tipo de actividad de la empresa." "OK"
			EndIf
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} xCliForEUA
	Actualiza campos de encabezado de nota fiscal.
	La función es llamada en AtuCliFor (LOCXNF.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 02/10/2022
	@param aCfgNF: Array con la configuración del documento.
	@return Nil
	/*/
Function xCliForEUA(aCfgNf)
Default aCfgNf := {}

	If !Empty(aCfgNf)
		If Trim(aCfgNf[ScEspecie]) $ 'NF|NDC|NCC'
			If !EMPTY(M->F2_CLIENTE) .AND. !EMPTY(M->F2_LOJA)
				M->F2_TPACTIV  := SA1->A1_ATIVIDA
				M->F2_EST 	   := SA1->A1_EST
				M->F2_CODMUN   := SA1->A1_COD_MUN
				MaFisAlt("NF_CODMUN", SA1->A1_COD_MUN)
				MaFisAlt("NF_TPACTIV",SA1->A1_ATIVIDA)
			EndIf
			If !EMPTY(M->F1_FORNECE) .AND. !EMPTY(M->F1_LOJA)
				IF Trim(M->F1_ESPECIE) == "NCC"
					M->F1_TPACTIV := SA1->A1_ATIVIDA
					M->F1_EST 	  := SA1->A1_EST
					M->F1_CODMUN  := SA1->A1_COD_MUN
					MaFisAlt("NF_CODMUN", SA1->A1_COD_MUN)
				Else
					M->F1_EST 	  := SA2->A2_EST
					M->F1_PROVENT := SA2->A2_COD_MUN
					MaFisAlt("NF_CODMUN", SA2->A2_COD_MUN)
				EndIF
			EndIf
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} LxDelNfEUA
	Validaciones generales en la anulación/elimnado de documentos fiscales.
	La función es llamada en LocxDelNF (LOCXNF.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 02/10/2022
	@param cFunname: Nombre de la función.
	@return lRet: .T. Si cumple con las condiciones.
	/*/
Function LxDelNfEUA(cFunname)
Local lRet := ""

Default cFunname := ""

	If cFunname $ 'MATA462DN|MATA467N|MATA475'
		//Ajuste do Status do Remito no momento da exclusao da NF gerada por um Remito MATA475
		LxEUAAjRem()
	EndIf

Return lRet

/*/{Protheus.doc} GrvSE2EUA
	Graba información en SE2.
	La información es llamada en GRAVASE2 (LOCXNF.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 02/10/2022
	@param cFunname: Nombre de la función.
	@return Nil
	/*/
Function GrvSE2EUA(cFunname)
Local lCpoPlaid := SE2->(ColumnPos("E2_SLPLAID")) > 0

Default cFunname := ""

	If lCpoPlaid
		If cFunName == "MATA101N"
			SE2->E2_SLPLAID := SE2->E2_VALOR
			SE2->E2_BCOPAG  := Posicione("SA2",1,xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA,"A2_BANCO")
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} GrvSE1EUA
	Graba información en tabla SE1.
	La función es llamada en GRAVASE1 (LOCXNF.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 02/10/2022
	@param cFunName: Nombre de la función.
	@return Nil
	/*/
Function GrvSE1EUA(cFunName)
Local lCpoPlaid := SE1->(ColumnPos("E1_SLPLAID")) > 0

Default cFunName := ""

	If lCpoPlaid
		If cFunName $ "MATA467N|MATA468N"
			SE1->E1_SLPLAID := SE1->E1_VALOR
			SE1->E1_PORTADO := Posicione("SA1",1,xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA,"A1_BCO1")
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} LxDuplEUA
	Ajuste referente al calculo de impuestos en título financiero.
	La función es llamada en LxA103Dupl (LOCXNF2.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 03/10/2022
	@version version
	@param 	aCols: Items del documento.
			aPe:
			nBaseDup: Valor base del título financiero.
			cEspecie: Especie del documento fiscal. 
			cFunName: Nombre de la función.
	@return nAuxBasDup: Valor base del título financiero.
	/*/
Function LxDuplEUA(aCols, aPe, nBaseDup, cEspecie, cFunName)
Local nCount	 := 0
Local aDupl2	 := {}
Local aPeAnt	 := aPe
Local cEspAnt	 := cEspecie
Local nAuxBasDup := nBaseDup

Default aCols    := {}
Default aPe      := {}
Default nBaseDup := 0
Default cEspecie := ""
Default cFunName := ""
	
	If cFunName $ 'MATA462N/MATA462AN' .And. FindFunction("MATA476") .And. !(Type("M->F2_TRANSP")=="U")

		M->F2_TRANSP	:= ''
		M->F2_FRETE		:= 0
		M->F2_DESPESA	:= 0
		M->F2_SEGURO	:= 0
		M->F2_DESCCAB	:= 0
		M->F2_DESCONT	:= 0
		M->F2_COND		:= ''
			
		aDupl2 		:= MATA476(3,.T.,,aCols)
		aPe 		:= aPeAnt
		cEspecie 	:= cEspAnt
			
		If Len(aDupl2) > 0	
			nAuxBasDup := 0
			For nCount := 1 to Len(aDupl2)			
				nAuxBasDup += Val(StrTran(StrTran(aDupl2[nCount,2],'.',''),',',''))/100			
			Next nCount		
		EndIf
		
	EndIf

Return nAuxBasDup

/*/{Protheus.doc} LxAFinEUA
	Obtiene información para actualizar folder financiero.
	La función es llamada en LxA103Financ (LOCXNF2.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 03/10/2022
	@param 	aCfgNf: Array de configuración para nota fiscal
			aRecSE1: Array con recnos de registros en SE1.
			cFunname: Nombre de la función.
	@return aTemp: Array con información financiera {{"","","",CTOD("  /  /  "),0}}.
	/*/
Function LxAFinEUA(aCfgNF, aRecSE1, cFunname)
Local nX         := 0
Local aTemp      := {}

Default aCfgNF   := {}
Default aRecSE1  := {}
Default cFunname := ""

		If cFunname $ 'MATA462N/MATA462AN/MATA462DN'
			For nX	:= 1 To Len(aRecSE1)
				MsGoto(aRecSE1[nX])
				If AllTrim(SE1->E1_TIPO) = 'NF' .Or. (AllTrim(SE1->E1_TIPO) = 'PRE' .And. AllTrim(SF2->F2_ESPECIE) == 'RFN')
					If AllTrim(SE1->E1_TIPO) == AllTrim(aCfgNF[8]) .OR. substr( E1_ORIGEM, 1, 4 ) == "LOJA" .Or. (SE1->E1_TIPO = 'PRE' .And. AllTrim(SF2->F2_ESPECIE) == 'RFN')
						aAdd(aTemp, {E1_NUM, E1_PREFIXO, E1_PARCELA, E1_VENCTO, E1_VALOR})
					EndIf
				EndIf
			Next nX
		Else
			For nX	:= 1 To Len(aRecSE1)
				MsGoto(aRecSE1[nX])
				If AllTrim(SE1->E1_TIPO) == AllTrim(aCfgNF[8]) .OR. substr( E1_ORIGEM, 1, 4 ) == "LOJA"
					aAdd(aTemp,{E1_NUM,E1_PREFIXO,E1_PARCELA,E1_VENCTO,E1_VALOR})
				EndIf
			Next nX
		EndIf

Return aTemp

/*/{Protheus.doc} FinSEVEUA
	genera informacion de SEV (aColsSEV y aHeadSEV) y SEZ (tabla temporal SEZTMP) para posteriormente guardar valores en la funcion GRAVASEV
	La función es llamada en FinSEVAut (LOCXNF2.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 02/10/2022
	@param 	aRatEvEz: Arreglo con los valores de multi naturaleza y prorrateo de centro de costo.
			aColsSEV: Arreglo de salida. Contiene valores de multi naturaleza.
			aHeadSEV: Arreglo de salida. contiene estructura campos SEV
	@return lRet: .T. Si cumple con las condiciones.
	/*/
Function FinSEVEUA(aRatEvEz,aColsSEV,aHeadSEV)
Local aArea    := GetArea()
Local lRet 		:= .T.
Local nReg		:= 0
local nPosNat	:= Ascan(aHeadSEV,{|e|Alltrim(e[2])=="EV_NATUREZ"})
Local nPosValor	:= Ascan(aHeadSEV,{|e|Alltrim(e[2])=="EV_VALOR"})
Local nPosPerc	:= Ascan(aHeadSEV,{|e|Alltrim(e[2])=="EV_PERC"})
Local nPosRate	:= Ascan(aHeadSEV,{|e|Alltrim(e[2])=="EV_RATEICC"})
Local nPosPorc	:= Ascan(aHeadSEV,{|e|Alltrim(e[2])=="EV_PORCENT"})
Local nPosIdDc	:= Ascan(aHeadSEV,{|e|Alltrim(e[2])=="EV_IDDOC"})

Default aRatEvEz:= {}
Default aColsSEV:= {}
Default aHeadSEV:= {}

	If Len(aRatEvEz) > 0
		For nReg := 1 to Len(aRatEvEz)

			If !FinVldNat(.f., aRatEvEz[nReg][nPosNat][2]) // valida Naturaleza
				lRet:= .F.
				Exit
			EndIf
			If Empty(aRatEvEz[nReg][nPosValor][2]) .OR. aRatEvEz[nReg][nPosValor][2] <= 0 // valida Valor
				Help(" ",1,"SEVVAZIO",,STR0008 +  aRatEvEz[nReg][nPosNat][2] + STR0009,3,1) //"El valor de la modalidad " //"debe ser mayor a 0"
				lRet:= .F.
				Exit
			EndIf
			If Empty(aRatEvEz[nReg][nPosPerc][2]) .OR. aRatEvEz[nReg][nPosPerc][2] <= 0 // valida percentual
				Help(" ",1,"SEVVAZIO",,STR0010 +  aRatEvEz[nReg][nPosNat][2] + STR0009,3,1) //"El valor del porcentaje de la modalidad "//"debe ser mayor a 0"
				lRet:= .F.
				Exit
			EndIf
			If Empty(aRatEvEz[nReg][nPosRate][2]) .OR. !(aRatEvEz[nReg][nPosRate][2] $ '1|2')// valida Milti CC
				Help(" ",1,"SEVVAZIO",,STR0011 +  aRatEvEz[nReg][nPosNat][2] + STR0012 ,3,1) //"La opcion para prorrateo de Centro de Costo en modalidad "//" debe ser 1 = Con prorrateo o 2 = Sin Prorrateo"
				lRet:= .F.
				Exit
			EndIf

			If nReg == 1
				aColsSEV[1][1] := aRatEvEz[nReg][nPosNat][2]//natureza
				aColsSEV[1][2] := aRatEvEz[nReg][nPosValor][2] // valor
				aColsSEV[1][3] := aRatEvEz[nReg][nPosPerc][2] // percentual
				aColsSEV[1][4] := aRatEvEz[nReg][nPosRate][2] // 1 - prorrateo C.C. 2 - no prorrateo de C.C.
				aColsSEV[1][5] := aRatEvEz[nReg][nPosPorc][2] // porcentual
				aColsSEV[1][6] := aRatEvEz[nReg][nPosIdDc][2] // id doc
				aColsSEV[1][7] := .F.
			Else
				aadd(aColsSEV, {;
				aRatEvEz[nReg][nPosNat][2],;//natureza
				aRatEvEz[nReg][nPosValor][2],; // valor
				aRatEvEz[nReg][nPosPerc][2],; // percentual
				aRatEvEz[nReg][nPosRate][2],; // 2 - não rateia centro de custo
				aRatEvEz[nReg][nPosPorc][2],; // porcentual
				aRatEvEz[nReg][nPosIdDc][2],; // id doc
				.F.})
			Endif

			If  !Empty(aColsSEV[nReg][1]) .and. !Empty(aColsSEV[nReg][2]) .and. aRatEvEz[nReg][nPosRate][2] == "1"
				aCols[n][1] := aColsSEV[nReg][1] // Natureza
				aCols[n][2] := aColsSEV[nReg][2] // valor
				If Select("SEZTMP")<= 0 .or. (Select("SEZTMP") > 0 .and. SEZTMP->(!DbSeek(acols[n][1])))
					If !(MulNatCC())
						lRet:= .F.
						Exit
					Endif
				EndIf
			EndIf
		Next nReg

	Endif
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} LxGrvLFEUA
	Graba información en la tabla SF3 - Libros Fiscales.
	La función es llamada en SF3ZONFIS (LOCXNF2.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 03/10/2022
	@param 	aCfgNF: Array con la configuración del documento.
			cFunName: Nombre de la función.
	@return Nil
	/*/
Function LxGrvLFEUA(aCfgNf, cFunname)
Local aArea 	:= GetArea()
Local cImp		:= 'STX' //impuesto realcionado a M460Stx
Local cZonFis	:= 	""
Local cCodMun	:= 	""
Local cEst 	    := 	""
Local cProvent  :=	""
Local cTpactiv  :=	""
Local nCodTab   := 	TamSx3("FF_COD_TAB")[1]
Local cAliasH	:= 	""
Local cClient	:= 	""

Default aCfgNf   := {}
Default cFunname :=  ""

	If Trim(aCfgNf[ScEspecie]) $ 'NF|NDC|NCC'//Graba la clave de la zona fiscal que fue utilizada para determinar la tasa
		If IsMemVar("aCfgNf")
			cAliasH 	:= aCfgNf[SAliasHead]
			If cAliasH == "SF2"
				cProvent	:=	M->F2_PROVENT
				cTpactiv	:=	M->F2_TPACTIV
				cCodMun	    := 	M->F2_CODMUN
			EndIf
		ElseIf cFunname == "MATA468N"
			cAliasH 	:= "SF2"
			cCodMun	    := SF2->F2_CODMUN
			cProvent 	:= SF2->F2_PROVENT
			cTpactiv 	:= SF2->F2_TPACTIV
		EndIf
		If cFunname == "MATA101N"// Factura de Entrada
			cClient	 := Alltrim(SM0->M0_COD_ATV)
			cTpactiv := SubStr(SM0->M0_DSCCNA,1,nCodTab)
		EndIf
		If cAliasH == "SF1"
			If cFunname == "MATA465N" //Nota de Crédito
				cClient := Alltrim(SA1->A1_CONTRBE)
				cTpactiv:= M->F1_TPACTIV
			EndIf

			If cClient == '2' //REVENDEDOR
				RecLock("SF3",.F.)
				SF3->F3_ESTADO := cZonFis
				SF3->(MsUnlock())
			ElseIf cClient == '1' //Consumidor Final
				CC2->(dbSetOrder(3)) //CC2_FILIAL + CC2_CODMUN
				If CC2->(MsSeek(xFilial("CC2") + M->F1_CODMUN))
					If CC2->CC2_PRESEN == '2' //No presencia fisica
						cCodMun := M->F1_PROVENT
						cEst    := M->F1_ZONGEO
					ElseIf CC2->CC2_PRESEN == '1' //Si presencia fisica
						cCodMun := M->F1_CODMUN
						cEst    := M->F1_EST
					EndIf
				EndIf
				SFF->(dbSelectArea("SFF"))
				SFF->(dbSetOrder(18)) //FF_FILIAL + FF_IMPOSTO + FF_CODMUN + FF_CFO_V
				If SFF->(MsSeek(xFilial("SFF") + cImp + cCodMun))
					While !SFF->(EOF())
						If SFF->FF_IMPOSTO == cImp .And. SFF->FF_ZONFIS == cEst ;
							.And. SFF->FF_CODMUN == cCodMun ;
							.And. SFF->FF_COD_TAB == cTpactiv
							cZonFis := SFF->FF_ZONFIS
						EndIf
						SFF->(DbSkip())
					EndDo
				EndIf
				//graba con la zona fiscal correpondiente
				RecLock("SF3",.F.)
				SF3->F3_ESTADO := cZonFis
				SF3->(MsUnlock())
			EndIf
		ElseIf cAliasH == "SF2"
			If SA1->A1_CONTRBE == '2' //REVENDEDOR
				RecLock("SF3",.F.)
				SF3->F3_ESTADO := cZonFis
				SF3->(MsUnlock())
			Else
				CC2->(dbSetOrder(3)) //CC2_FILIAL + CC2_CODMUN
				If CC2->(MsSeek(xFilial("CC2")+cCodMun))
					If CC2->CC2_PRESEN == '2' // PRESENCIA FISICA  =  NO
						cCodMun := cProvent
					EndIf
				EndIf
				SFF->(dbSelectArea("SFF"))
				SFF->(dbSetOrder(18))//FF_FILIAL + FF_IMPOSTO + FF_CODMUN + FF_CFO_V
				If SFF->(MsSeek(xFilial("SFF") + cImp + cCodMun))
					While !SFF->(Eof())
						If SFF->FF_COD_TAB == cTpactiv .And.;
							SFF->(FF_IMPOSTO+FF_CODMUN) == cImp+cCodMun
							cZonFis := SFF->FF_ZONFIS
							Exit
						EndIf
						SFF->(DbSkip())
					EndDo
				Endif
				//Graba con la zona fiscal
				RecLock("SF3",.F.)
				SF3->F3_ESTADO := cZonFis
				SF3->(MsUnlock())
			EndIf
		EndIf
	EndIf
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} LxlnValEUA
	Función informada en X3_VALID de los campos F1_PROVENT/F2_PROVENT y F1_CODMUN/F2_CODMUN.
	La función es llamada en LlnVal (LOCXNF2.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 03/10/2022
	@param Nil
	@return .T.
	/*/
Function LxlnValEUA()
Local cRedVar := ReadVar()
Local cEstado := ''

	If cRedVar != NIL
		CC2->(dbSelectArea("CC2"))
		CC2->(dbSetOrder(3)) //CC2_FILIAL + CC2_CODMUN
		If CC2->(MsSeek(xFilial("CC2") + &cRedVar))
 			cEstado := CC2->CC2_EST
		EndIf
		Do Case
			Case cRedVar == "M->F2_CODMUN"
				If !Empty(&cRedVar)
					M->F2_EST := cEstado
				EndIf
			Case cRedVar == "M->F2_PROVENT"
				If !Empty(&cRedVar)
					M->F2_ZONGEO := cEstado
				EndIf
			Case cRedVar == "M->F1_CODMUN"
				If !Empty(&cRedVar)
					M->F1_EST := cEstado
				EndIf
			Case cRedVar == "M->F1_PROVENT"
				If !Empty(&cRedVar)
					M->F1_ZONGEO := cEstado
				EndIf
		EndCase
	EndIf

Return .T.
