#include 'protheus.ch'
#include 'parmtype.ch'
#include 'LOCXBOL.ch'

#Define SAliasHead  4
#Define ScOpFin     9

/*Rutina Funciones Genérica Factura Electrónica Bolivia*/
/*/{Protheus.doc} M486XVldBO
//Valida campos obligatorios para Fac. Electrónica. 
@author Alfredo Medrano
@since 21/04/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function M486XVldBO(cValCpo,cCpo)
	Local lRetVld := .T.
	Local cAviso  := ""
	Default cValCpo:= ""
	Default cCpo   := ""
	If cCpo == "F1_TIPNOTA" .Or. cCpo == "F2_TPDOC"  .OR. cCpo == "F1_MODCONS" .OR. cCpo == "F2_MODCONS"  .OR. cCpo == "C5_CODMPAG" .OR. cCpo == "C5_TPDOCSE"
		If Empty(cValCpo)
			cAviso := StrTran(STR0001, '###', RTrim(FWX3Titulo(cCpo))) + " (" + cCpo + ")." //"Es necesario informar en el encabezado el campo ###"  
			lRetVld := .F.
		Else
			If cCpo == "F1_TIPNOTA" .Or. cCpo == "F2_TPDOC" .OR. cCpo == "C5_TPDOCSE" //Tip. Doc. Sector.
				lRetVld := ValidF3I("S008", cValCpo ,1,2)  
			ElseIf  cCpo == "F1_MODCONS" .OR. cCpo == "F2_MODCONS" .OR. cCpo == "C5_CODMPAG" //Cód. Met. Pago.
				lRetVld := ValidF3I("S004", cValCpo,1,2)                                                                                  
			EndIf
			If !lRetVld                                                                               
				cAviso := StrTran(STR0002, '###', RTrim(FWX3Titulo(cCpo))) + cCpo + STR0002 //"El campo ###( //"), no contiene información válida para el tipo de documento."
			EndIf
		EndIf
	EndIF
	If !Empty(cAviso)
		Aviso(STR0004, cAviso, {STR0005}) //"Atención" //"Ok"
	EndIf	
Return lRetVld

/*/{Protheus.doc} VldFacE
//Valida campos que son necesarios para la trasnmision de la Fac. Electrónica
//utiliza en el valid de los campos F1/F2_LOJA, F1/F2_SERIE y D1/D2_COD
@author Alfredo Medrano
@since 21/04/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function  VldFacE()
	Local aArea	:= getArea()
	Local cOrd		:= ""
	Local lRet		:= .T.
	Local nCount  := 0
	Local aError  := {}
	Local cAviso	:= ""
	Local cSerieF  := ""
	Local cProdF  := ""
	Local cCampR := ReadVar() // obtiene nombre campo 
	Local cNumDto  	:=""
	Local cCpo   	:= ""
	Local lCFDUso   := IIf(Alltrim(GetMv("MV_CFDUSO", .T., "1"))<>"0",.T.,.F.)
	Local cProvFE 	:= 	SuperGetMV("MV_PROVFE",,"")
	
	If Type("cEspecie") == "C"
		cNumDto := iif(AllTrim(cEspecie) =="NF", '1',iif(AllTrim(cEspecie) =="NCC", '4', iif(AllTrim(cEspecie) =="NDC", '5', '0')) )
	EndIf
	
	If lCFDUso .and. !(Type("cEspecie") == "C" .and. (cEspecie $ "NDI|NCI|NDP|NCP" .or. Funname() $ "MATA101N|MATA143") )
		cCpo := substr(Alltrim(cCampR),4)
		If cCpo == "F2_LOJA" .OR.  cCpo == "F1_LOJA" .OR.  cCpo == "C5_LOJACLI" .OR.  cCpo == "C5_CLIENTE" 
			cAviso	:= STR0006 +  CHR(10) //"Información faltante en registro del Cliente."
			cOrd := IIf(cCpo == "F2_LOJA", M->F2_CLIENTE + M->F2_LOJA, IIf(cCpo == "F1_LOJA", M->F1_FORNECE + M->F1_LOJA, IIf(cCpo $  "C5_LOJACLI|C5_CLIENTE", M->C5_CLIENTE + M->C5_LOJACLI, ) ))
		 	dbSelectArea("SA1")
		 	SA1->(DBSETORDER(1)) //A1_FILIAL+A1_COD+A1_LOJA
			If SA1->(dbSeek(xFilial("SA1")+cOrd)) 
		 		If Empty(SA1->A1_TIPDOC) 
		 			aAdd(aError ,{"A1_TIPDOC",RTrim(FWX3Titulo("A1_TIPDOC"))})
		 		EndIf
		 		If Empty(SA1->A1_CGC) 
		 			aAdd(aError ,{"A1_CGC",RTrim(FWX3Titulo("A1_CGC"))}) 
		 		EndIf
			EndIf
		EndIF
		
		If (cCpo == "F1_SERIE" .OR. cCpo == "F2_SERIE") .and. !("VULCAN" $ cProvFE)
			cAviso	:= STR0007 +  CHR(10) //"Información faltante en registro del Control de Folios."
			cSerieF := IIf(cCpo == "F1_SERIE", M->F1_SERIE, IIf(cCpo == "F2_SERIE", M->F2_SERIE, ))
		 	dbSelectArea("SFP")
			SFP->(dbSetOrder(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE+FP_PV
			If SFP->(MsSeek(xFilial("SFP") + cFilAnt + cSerieF + cNumDto))
				If Empty(SFP->FP_DOCFIS) 
		 			aAdd(aError ,{"FP_DOCFIS",RTrim(FWX3Titulo("FP_DOCFIS"))}) 
		 		EndIf
		 		If Empty(SFP->FP_PV) 
		 			aAdd(aError ,{"FP_PV",RTrim(FWX3Titulo("FP_FP_PV"))}) 
		 		EndIf
			EndIf
		EndIF
		
		If cCpo == "D1_COD" .OR. cCpo == "D2_COD" .OR. cCpo == "C6_PRODUTO"
			cAviso	:= STR0008 +  CHR(10) //"Información faltante en registro del Producto."
			cProdF := IIf(cCpo == "D1_COD", M->D1_COD, IIf(cCpo == "D2_COD", M->D2_COD, IIf(cCpo == "C6_PRODUTO", M->C6_PRODUTO, ) ))
		 	dbSelectArea("SB1")
			SB1->(dbSetOrder(1))//B1_FILIAL+B1_COD
			If SB1->(MsSeek(xFilial("SB1") + cProdF))
				If Empty(SB1->B1_PRODSAT) 
		 			aAdd(aError ,{"B1_PRODSAT",RTrim(FWX3Titulo("B1_PRODSAT"))}) // "Información faltante registro del Producto""
		 		EndIf
			EndIf
		EndIF
		
		If Len(aError) > 0
			For nCount:= 1 to Len(aError)
				cAviso += StrTran(STR0002, '###', RTrim(aError[nCount,2])) + " (" + aError[nCount,1] + ")" + STR0009 +  CHR(10) //El campo ###, no contiene información.
			Next
			cAviso += STR0010 //"La ausencia de ésta información impedirá la transición del documento."
			Aviso(STR0004, cAviso, {STR0005}) //"Atención" //"Ok"
		EndIf
	EndIf
	RestArea(aArea)	
Return lRet 

/*/{Protheus.doc} LxCposBol
//Función para agregar campos para Bolivia.
@author Alfredo Medrano
@since 21/04/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function LxCpoBol(aCposNF, cTabla)
Local nPosF := 0
Local cValOrigen := ""
Local lCFDUso   := IIf(Alltrim(GetMv("MV_CFDUSO", .T., "1"))<>"0",.T.,.F.)
Local cEspec 	:= Iif(Type("cEspecie") == "C", AllTrim(cEspecie), "")
If cTabla == "SF2"
	If lCFDUso 
		/*asigna validacion a F2_CLIENTE/F2_LOJA */
		nPosF := ASCAN(aCposNF,{|x| AllTrim(x[2]) == "F2_LOJA"})
		If nPosF > 0
			cValOrigen := ""
			cValOrigen := aCposNF[nPosF, 6]
			If !Empty(cValOrigen)
				cValOrigen += " .AND. " 
			EndIf
			aCposNF[nPosF, 6]:= cValOrigen + "VldFacE()"
		EndIf	
		/*asigna validacion a F2_SERIE*/
		nPosF := ASCAN(aCposNF,{|x| AllTrim(x[2]) == "F2_SERIE"})
		If nPosF > 0
			cValOrigen := ""
			cValOrigen := aCposNF[nPosF, 6]
			If !Empty(cValOrigen)
				cValOrigen += " .AND. " 
			EndIf
			aCposNF[nPosF, 6]:= cValOrigen + "VldFacE()"
		EndIf
	EndIf

	If SF2->(ColumnPos( "F2_MODCONS" )) > 0
		SX3->(MsSeek("F2_MODCONS"))
		cVld := LocX3Valid("F2_MODCONS")
		AAdd(aCposNF,{X3Titulo(),"F2_MODCONS",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,cVld,SX3->X3_USADO,SX3->X3_TIPO,"SF2",SX3->X3_CONTEXT,,,,,,SX3->X3_F3})
	EndIf
	If SF2->(ColumnPos( "F2_IDRGS" )) > 0
		SX3->(MsSeek("F2_IDRGS"))
		cVld := LocX3Valid("F2_IDRGS")
		AAdd(aCposNF,{X3Titulo(),"F2_IDRGS",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,cVld,SX3->X3_USADO,SX3->X3_TIPO,"SF2",SX3->X3_CONTEXT,,,,,,})
	EndIf
	If SF2->(ColumnPos( "F2_TPDOC" )) > 0
		SX3->(MsSeek("F2_TPDOC"))
		cVld := LocX3Valid("F2_TPDOC")
		AAdd(aCposNF,{X3Titulo(),"F2_TPDOC",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,cVld,SX3->X3_USADO,SX3->X3_TIPO,"SF2",SX3->X3_CONTEXT,,,,,,SX3->X3_F3})
	EndIf

	If cEspec $ "NCP"
		If SF2->(ColumnPos( "F2_FLFTEX" )) > 0
			SX3->(MsSeek("F2_FLFTEX"))
			AAdd(aCposNF,{,"F2_FLFTEX",,,,,,,,,,,,,,,,,,.T.,{"",STR0014}})
		EndIf
	EndIf
ElseIf cTabla == "SF1"
	If lCFDUso
		/*asigna validacion a F1_FORNECE/F1_LOJA*/
		nPosF := ASCAN(aCposNF,{|x| AllTrim(x[2]) == "F1_LOJA"})
		If nPosF > 0
			cValOrigen := ""
			cValOrigen := aCposNF[nPosF, 6]
			If !Empty(cValOrigen)
				cValOrigen += " .AND."
			EndIf
			aCposNF[nPosF, 6]:= cValOrigen + " VldFacE()"
		EndIf
		/*asigna validacion a F1_SERIE*/
		nPosF := ASCAN(aCposNF,{|x| AllTrim(x[2]) == "F1_SERIE"})
		If nPosF > 0
			cValOrigen := ""
			cValOrigen := aCposNF[nPosF, 6]
			If !Empty(cValOrigen)
				cValOrigen += " .AND. " 
			EndIf
			aCposNF[nPosF, 6]:= cValOrigen +" VldFacE()"
		EndIf	
	EndIf	
	If SF1->(ColumnPos( "F1_TIPNOTA" )) > 0
		SX3->(MsSeek("F1_TIPNOTA"))
		cVld := LocX3Valid("F1_TIPNOTA")
		AAdd(aCposNF,{X3Titulo(),"F1_TIPNOTA",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,cVld,SX3->X3_USADO,SX3->X3_TIPO,"SF1",SX3->X3_CONTEXT,,,,,,SX3->X3_F3})
	EndIf
		If SF1->(ColumnPos( "F1_MODCONS" )) > 0
		SX3->(MsSeek("F1_MODCONS"))
		cVld := LocX3Valid("F1_MODCONS")
		AAdd(aCposNF,{X3Titulo(),"F1_MODCONS",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,cVld,SX3->X3_USADO,SX3->X3_TIPO,"SF1",SX3->X3_CONTEXT,,,,,,SX3->X3_F3})
	EndIf
	If SF1->(ColumnPos( "F1_IDRGS" )) > 0
		SX3->(MsSeek("F1_IDRGS"))
		cVld := LocX3Valid("F1_IDRGS")
		AAdd(aCposNF,{X3Titulo(),"F1_IDRGS",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,cVld,SX3->X3_USADO,SX3->X3_TIPO,"SF1",SX3->X3_CONTEXT,,,,,,})
	EndIf

	If cEspec $ "NF|NDP"
		If SF1->(ColumnPos( "F1_FLFTEX" )) > 0
			SX3->(MsSeek("F1_FLFTEX"))
			AAdd(aCposNF,{,"F1_FLFTEX",,,,,,,,,,,,,,,,,,.T.,{"",STR0014}})
		EndIf
	EndIf
EndIf
Return aCposNF

/*/{Protheus.doc} LxVldBol
//Valida campos para el país Bolivia..
@author Alfredo Medrano
@since 21/04/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function LxVldBol(cAliasSF)
Local lRetVld	:= .T.
Local lCFDUso   := IIf(Alltrim(GetMv("MV_CFDUSO", .T., "1"))<>"0",.T.,.F.)
	If lCFDUso
		If cAliasSF == "SF1"
			IIF(!ValRetSat(M->F1_TIPNOTA, "F1_TIPNOTA") .OR. !ValRetSat(M->F1_MODCONS, "F1_MODCONS"), lRetVld:= .F.,)
		ElseIf cAliasSF == "SF2"
			IIF(!ValRetSat(M->F2_TPDOC, "F2_TPDOC")  .OR. !ValRetSat(M->F2_MODCONS, "F2_MODCONS"), lRetVld:= .F.,)
		EndIf
	EndIf
Return lRetVld
/*/{Protheus.doc} LxBoVldDel
//Valida Borrado/ anulación de documentos fiscales
@author Alfredo Medrano
@since 21/04/2020
@version 1.0
@example
(examples)
@see (links_or_references)

/*/
Function LxBoVldDel(cAlias, cAliCampo)
Local lRet := .T.
Local lCFDUso   := IIf(Alltrim(GetMv("MV_CFDUSO", .T., "1"))<>"0",.T.,.F.)
DEFAULT cAliCampo := ""
If lCFDUso
	If !Empty(cAlias) .AND. !Empty(cAliCampo)
		If IIf (cAlias $ "SF2|SF1" , !Empty((cAlias)->(ColumnPos(cAliCampo+"_FLFTEX"))), .F.)
			If (cAlias)->&(cAliCampo+"_FLFTEX") $ "1|4|6"
				MsgAlert( STR0011 + (cAlias)->&(cAliCampo+"_SERIE") + (cAlias)->&(cAliCampo+"_DOC") + STR0012 )//"El documento " ## " no puede ser borrado/anulado pues ya fue transmitido. Utilice funcionalidad de Anulación de Factura Electrónica de la rutina Transmisión Electrónica (MATA486)."
				Return .F.
			ElseIf (cAlias)->&(cAliCampo+"_FLFTEX") $ "7"
				MsgAlert( STR0011 + (cAlias)->&(cAliCampo+"_SERIE") + (cAlias)->&(cAliCampo+"_DOC") + STR0013 )//"El documento " ## " se encuentra en proceso de validación de anulación. Utilice funcionalidad de Monitor de la rutina Transmisión Electrónica."
				Return .F.
			EndIf
		EndIf
	EndIf
EndIf
return lRet

/*/{Protheus.doc} LVlSerBol
//Valida serie para Bolivia.
@author Alfredo Medrano
@since 12/05/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function LVlSerBol(cSerieF)
Local aArea	:= getArea()
Local lRet := .T.
Local cAviso := ""
Local cNumDto := '1'
Local lCFDUso   := IIf(Alltrim(GetMv("MV_CFDUSO", .T., "1"))<>"0",.T.,.F.)
Local cProvFE 	:= 	SuperGetMV("MV_PROVFE",,"")

	If !Empty(cSerieF) .And. !Empty(cNumDto) .and. lCFDUso .and. !("VULCAN" $ cProvFE)
			cAviso	:= STR0007 +  CHR(10) //"Información faltante en registro del Control de Folios."
		 	dbSelectArea("SFP")
			SFP->(dbSetOrder(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE+FP_PV
			If SFP->(MsSeek(xFilial("SFP") + cFilAnt + cSerieF + cNumDto))
				If Empty(SFP->FP_DOCFIS) 
		 			cAviso +=   StrTran(STR0002, '###', RTrim(FWX3Titulo("FP_DOCFIS"))) + " (FP_DOCFIS)" + STR0009 +  CHR(10) //El campo ###, no contiene información.
		 			lRet := .F.
		 		EndIf
		 		If Empty(SFP->FP_PV) 
		 			cAviso +=   StrTran(STR0002, '###', RTrim(FWX3Titulo("FP_PV"))) + " (FP_PV)" + STR0009 +  CHR(10) //El campo ###, no contiene información.
		 			lRet := .F.
		 		EndIf
			EndIf
		EndIF
		If !lRet
			cAviso += STR0010 //"La ausencia de ésta información impedirá la transición del documento."
			Aviso(STR0004, cAviso, {STR0005}) //"Atención" //"Ok"
		EndIf
	RestArea(aArea)	
return lRet


/*/{Protheus.doc} CtrFolBol
//Valida vencimiento de control de formulario para Bolivia.
@author Eli Salatiel Gómez Rodríguez
@since 02/05/2022
@version 1.0
@param cFilAnt, Caracter, Filial.
@param cSerie, Caracter, Serie del documento. 
@param cEspecie, Caracter, Tipo de documento. 
@param cnFiscal, Caracter, Número de documento. 
/*/

Function CtrFolBol(cFilAnt,cSerie,cEspecie,cnFiscal)

	Local lRet		:= .T.
	Local alAreaX	:= {}
	
	cEspecie := Alltrim(cEspecie)

	If !Empty(cEspecie) .And. !Empty(cnFiscal)

		If Upper(Alltrim(FunName())) $ "MATA465N/MATA466N/MATA467N"

			If cEspecie $ "NF/NCC/NDC/NDI/NCI"

				Do Case
				Case cEspecie == "NF"
					cEspecie := "1"
				Case cEspecie == "NCI"
					cEspecie := "2"
				Case cEspecie == "NDI"
					cEspecie := "3"
				Case cEspecie == "NCC"
					cEspecie := "4"
				Case cEspecie == "NDC"
					cEspecie := "5"
				EndCase

				alAreaX := GetArea()

				dbSelectArea("SFP")
				SFP->(dbGoTop())
				dbSetOrder(5)
				If DbSeek(xFilial("SFP")+cFilAnt+SubStr(cSerie,1,3)+cEspecie)
					lRet := .F.
					While AllTrim(SFP->FP_FILIAL+SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_ESPECIE) == AllTrim(xFilial("SFP")+cFilAnt+SubStr(cSerie,1,3)+cEspecie)
						If (!Empty(FP_NUMINI) .and. SFP->FP_NUMINI <= cnFiscal) .and.  (!Empty(FP_NUMFIM) .and. cnFiscal > SFP->FP_NUMFIM)
							lRet := .F.
						Else
							lRet := .T.
							Exit
						EndIf
						SFP->(dbSkip())
					EndDo
					If lRet
						If dDataBase <= SFP->FP_DTAVAL
							lRet := .T.
						Else
							Help("", 1, STR0015,STR0016,{STR0005}) //"¡Atencion!"###"La fecha de emisión de este documento está fuera del límite registrado en el control de formularios. Por lo tanto, no podrá utilizarse para la emisión del documento fiscal."###"OK"
							lRet := .F.
						EndIf
					Else
						Help("", 1,STR0015,STR0017,{STR0005})//"¡Atencion!"###"No existe este número registrado en ningún rango con esta serie o clase."###"OK"
						lRet := .F.
					EndIf
				Else
					Help("", 1, STR0015,STR0018,{STR0005})//"¡Atencion!"###"Esta serie o especie no está registrada en el control de formularios. Por lo tanto, no podrá utilizarse para la emisión del documento fiscal."###"OK"
					lRet := .F.
				EndIf
				SFP->(dbCloseArea())
				RestArea(alAreaX)
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} UNLOCSB2BO
    Desbloqueo de la tabla Saldo Físico y Financiero(SB2)
    @type  Function
    @author adrian.perez
    @since 17/08/2022
    @param aRegSD2, arreglo, registros de la factura para localizar saldos de los productos, param_descr
    @return nil
    /*/

Function UNLOCSB2BO(aRegSD2)
	Local aArea 
	Local nI:=0
	DEFAULT aRegSD2:={}
	IF !IsInCallStack("MATA486") .AND. LEN(aRegSD2)>0
		aArea := GetArea()
		DbSelectArea('SD2')
		For nI := 1 to Len(aRegSD2)
			SD2->(MsGoTo(aRegSD2[nI]))
			DbSelectArea('SB2')
			SB2->(DbSetOrder(1))
			If SB2->(MsSeek(xFilial("SD2")+SD2->D2_COD+SD2->D2_LOCAL))
				SB2->(MsRUnlock())
			Endif
			Next
		RestArea(aArea)
	ENDIF
Return Nil


/*/{Protheus.doc} loadCamBol
	(Carga los campos localizados-BOL a la tabla temporal - presupuestos)
	@type  Function
	@author alejandro.parrales
	@since 25/08/2022
	@version 1.0
	@param Ninguno
	@return Nil
	@example (M->C5_TPDOCSE  := SCJ->CJ_TPDOCSE )
	/*/
Function loadCamBol()
	If SCJ->(ColumnPos("CJ_TPDOCSE")) > 0 .and. SC5->(ColumnPos("C5_TPDOCSE")) > 0
		M->C5_TPDOCSE  := SCJ->CJ_TPDOCSE 
	EndIf
Return


/*/{Protheus.doc} LxGrvLFBol
	Graba información en la tabla SF3 - Libros Fiscales.
	La función es llamada en GravaNfGeral (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 26/09/2022
	@param 	aCfgNF: Array con la configuración para los documentos fiscales.
			aRetCF: Información de control de formularios.
			lContrFol: Indica si está activo el control de formulario (.T.).
			cKey: Llave para identificar los registros en SF3.
			cFunname: Nombre de rutina.
	@return Nil
	/*/
Function LxGrvLFBol(aCfgNF, aRetCF, lContrFol, cKey, cFunname)
Local aAreaAnt   := {}
Local aSF3       := {}
Local lDBBNumAut := DBB->(ColumnPos("DBB_NUMAUT")) > 0
Local cAlias     := ""
Local lPassag 	 := GetNewPar("MV_PASSBOL",.F.) // Passagens aereas - Bolivia

Default aCfgNF    := {}
Default aRetCF    := {}
Default lContrFol := .F.
Default cKey      := ""
Default cFunname  := Funname()

	cAlias := aCfgNf[SAliasHead]

	aAreaAnt := GetArea()
	aSF3	 := SF3->(GetArea())
	dbSelectArea("SF3")
	dbSetOrder(1)
	If MsSeek(cKey)
		While !SF3->(EOF()) .AND. SF3->(F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA) == cKey
			RecLock("SF3",.F.)
				If lContrFol
					SF3->F3_NUMAUT := aRetCF[1]		//Numero de Autorizacao
					SF3->F3_CODCTR := aRetCF[2]		//Codigo de Controle
					If cAlias == "SF1"
						If cFunname $ "MATA143"
							SF3->F3_CODCTR := DBB->DBB_CODCTR
							If lDBBNumAut
								SF3->F3_NUMAUT := DBB->DBB_NUMAUT
							EndIf
						Else
							If Empty(aRetCF[2]).AND. !Empty(M->F1_CODCTR)
								SF3->F3_CODCTR := M->F1_CODCTR
							EndIf
							If !Empty(M->F1_NUMAUT)
								SF3->F3_NUMAUT := M->F1_NUMAUT
							EndIf
						EndIf
					EndIf
				EndIf
				If cAlias == "SF1"
					If lPassag
						Replace F3_COMPANH With SF1->F1_COMPANH
						Replace F3_LOJCOMP With SF1->F1_LOJCOMP
						Replace F3_PASSAGE With SF1->F1_PASSAGE
						Replace F3_DTPASSA With SF1->F1_DTPASSA
					EndIf
					Replace F3_TIPCOMP With SF1->F1_TIPCOMP
					Replace F3_RECIBO With SF1->F1_RECIBO
				ElseIf cAlias == "SF2"
					Replace F3_TIPCOMP With SF2->F2_TIPCOMP
				EndIf
			MsUnlock()
			SF3->(dbSkip())
		Enddo
	Endif
	RestArea(aSF3)
	RestArea(aAreaAnt)

Return Nil


/*/{Protheus.doc} GrvSF1Bol
	Graba información SF1 en la generación de documentos (MATA143)
	La función es llamada en GravaNfGeral (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 26/09/2022
	@param Nil
	@return Nil
	/*/
Function GrvSF1Bol()
Local lDBBNumAut := DBB->(ColumnPos("DBB_NUMAUT")) > 0

	SF1->F1_CODCTR := DBB->DBB_CODCTR
	If lDBBNumAut
		SF1->F1_NUMAUT := DBB->DBB_NUMAUT
	EndIf
Return Nil


/*/{Protheus.doc} NfTudOkBol
	Validaciones generales en la inclusión de documentos.
	La función es llamada en NfTudOk (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 26/09/2022
	@param 	aCfgNf: Array con la configuración del documento.
			aDupli: Array con valores financieros.
			nBaseDup: Valor del título financiero de la nota fiscal.
			nMoedaNF: Moneda del documento.
			nMoedaCor: Moneda a convertir el valor.
			nTaxa: Valor de la tasa de cambio.
			l103Class: Indica si existe integración.
			cFunName: Nombre de la función.
	@return lRet: .T. si cumple con las condiciones.
	/*/
Function NfTudOkBol(aCfgNf, aDupli, nBaseDup, nMoedaNF, nMoedaCor, nTaxa, l103Class, cFunName)
Local lRet     := .T.
Local nI       := 0
Local nTotDup  := 0

Default aCfgNf    := {}
Default aDupli    := {}
Default nBaseDup  := 0
Default nMoedaNF  := 1
Default nMoedaCor := 1
Default nTaxa     := 0
Default l103Class := .F.
Default cFunName  := Funname()

	// Valida que exista informacion de los titulos cuando la condicion de pago es informada
	If lRet .AND. !l103Class .AND. !Empty(aCfgNf[ScOpFin]) .AND. Len(aDupli) > 0 .AND. nBaseDup > 0 .AND. Val(Alltrim(Extrae(aDupli[1],5)))==0
		Aviso(STR0019,STR0020,{STR0021}) //"ATENCAO"### "Inconsistencias nos valores financeiros"###"OK"
		lRet	:= .F.
	EndIf

	//Controla se o valor total das duplicatas bate com o total
	If lRet .AND. !l103Class .AND. !Empty(aCfgNf[ScOpFin]) .AND. Len(aDupli) > 0 .and. Val(Substr(aDupli[1],rat("³",aDupli[1])+1,len(aDupli[1]))) > 0  // O sistema gera uma estrutura vazia para duplicata.
		For nI := 1 To Len(aDupli)
			nTotDup += DesTrans(Extrae(aDupli[nI],5,))
		Next nI
		If lRet
			If Abs(xMoeda(nBaseDup,nMoedaNF,nMoedaCor,dDataBase,,nTaxa) - nTotDup) > SuperGetMV("MV_LIMPAG")
				Aviso(STR0019,STR0020,{STR0021}) //"ATENCAO"### "Inconsistencias nos valores financeiros"###"OK"
				lRet	:= .F.
			EndIf
		EndIf
	Endif

	If lRet .And. cFunName $ "MATA467N|MATA462N|MATA465N"
		lRet := LxVldBol(aCfgNf[SAliasHead])
	EndIf

Return lRet


/*/{Protheus.doc} LxLOkBol
	Validaciones de linea del documento fiscal.
	La función es llamada en NfLinOk (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 26/09/2022
	@param 	aHeader: Campos de ítems.
			aCols: Items de documento fiscal.
			nLinha: Número de ítem del documento fiscal.
			lFactElec: Indica si la factura electronica está activa.
			lFormP: Indica si es formulario propio (.T.)
			cCFDUso: Indica el uso del CFD.
			cEspecie: Código de especie del documento.
			cFunname: Nombre de función.
			nPosRemito: Posición del campo REMITO en aCols/aHeader.
			nPosNFOri: Posición del campo NFORI en aCols/aHeader.
			nPosSerOri: Posición del campo SERIORI en aCols/aHeader.
	@return lRet: .T. si cumple las condiciones.
	/*/
Function LxLOkBol(aHeader, aCols, nLinha, lFactElec, lFormP, cCFDUso, cEspecie, cFunname, nPosRemito, nPosNFOri, nPosSerOri)
Local lRet := .T.

Default aHeader    := {}
Default aCols      := {}
Default nLinha     := 0
Default lFactElec  := !Empty(SuperGetMV("MV_PROVFE", .F., "")) //Facturacion Electronica Activa
Default lFormP     := .F.
Default cCFDUso    := Alltrim(GetMv("MV_CFDUSO", .T., "1"))
Default cEspecie   := ""
Default cFunname   := Funname()
Default nPosRemito := 0
Default nPosNFOri  := 0
Default nPosSerOri := 0

	If lRet .And. nLinha > 0 .And.  cFunname == "MATA465N" .And. cEspecie $ "NDC|NCC" .And. lFormP .And. (aCols[nLinha][Len(aHeader)+1] == .F.) .And. ( cCFDUso <> "0" .OR. lFactElec) .And. (nPosRemito*nPosNFOri*nPosSerOri > 0) .And. Empty(aCols[nLinha][nPosRemito])
		lRet := LxVldDocIt(aCols[nLinha][nPosNFOri], aCols[nLinha][nPosSerOri], cEspecie)
	EndIf

Return lRet

/*/{Protheus.doc} LxDelNfBol
	Validaciones generales en el borrado/anulación del documento fiscal.
	La función es llamada en LocxDelNF (LOCXNF.PRW).
	@type  Function
	@author Arturo Samaniego
	@since 26/09/2022
	@param 	cAlias: Alias de la tabla.
			lLocxAuto: Indica si es rutina automatica.
			cFunname: Nombre de la rutina.
	@return lRet: .T. si cumple con las condiciones.
	/*/
Function LxDelNfBol(cAlias, lLocxAuto, cFunname)
Local lRet := .T.
Local cAliCampo	 := Right(cAlias, 2)

Default cAlias := ""
Default lLocxAuto := .F.
Default cFunname := Funname()

	If lRet .and. cFunname $ "MATA467N|MATA465N|" .And. !lLocxAuto
		lRet := LxBoVldDel(cAlias, cAliCampo)
	EndIf

Return lRet

/*/{Protheus.doc} LxNfCxaBol
	Validación de datos de integración con caja chica.
	La función es llamada en NFVldCxa (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 26/09/2022
	@param 	cAdia: Código de anticipo.
			cCxRendic: Número de rendición.
			cCaixa: Código de caja chica.
			nRecAdia: Número de recno del anticipo.
			nValor: Valor del movimiento.
			lAdia: Indica si es anticipo (.T.).
	@return lRet: .T. Si cumple con las condiciones.
	/*/
Function LxNfCxaBol(cAdia, cCxRendic, cCaixa, nRecAdia, nValor, lAdia)
Local lRet := .T.

Default cAdia     := ""
Default cCxRendic := ""
Default cCaixa    := ""
Default nRecAdia  := 0
Default nValor    := 0
Default lAdia     := .F.

	If !Empty(cAdia) .And. !Empty(cCxRendic)
		dbSelectArea("SEU")
		SEU->(DbSetOrder(8))
		If DbSeek(xFilial("SEU")+cCaixa+cCxRendic)
			While (SEU->(!Eof()))
				IF SEU->EU_NROADIA == cAdia .And. SEU->EU_TIPO == "01"
					If nValor <= SEU->EU_VALOR
						RecLock("SEU",.F.)
						Replace EU_SLDADIA With EU_SLDADIA - nValor

						//³ Se sobrou saldo no registro de adiantamento,                ³
						//³ pergunta-se se deseja REPASSAR O REMANESCENTE para o saldo  ³
						//³ do caixinha e com isso o adiantamento ficara com saldo zero,³
						//³ o que permitira que o mesmo seja baixado/rendido.           ³

						If EU_SLDADIA > 0
							lAdia		:=	.T.
							nRecAdia	:=	RECNO()
						Else
							Replace EU_BAIXA With dDataBase
						Endif
						MsUnlock()
					Else
						Help(" ",1,"FA560SALDO")
						lRet	:=	.F.
					Endif
					dbSkip()
				Else
					dbSkip()
				EndIf
			Enddo
		Else
			Help(" ",1,"FA560NE") // Adiantamento informado nao encontrado
			lRet	:=	.F.
		Endif
	Else
		dbSelectArea("SEU")
		SEU->(dbSetOrder(6))
		If SEU->(dbSeek(xFilial("SEU") + cCaixa + "01" + Space(Len(EU_NROADIA)) + cAdia))
			If (nValor <= SEU->EU_SLDADIA)
				RecLock("SEU",.F.)
				Replace EU_SLDADIA	With EU_SLDADIA - nValor

				//³ Se sobrou saldo no registro de adiantamento,                ³
				//³ pergunta-se se deseja REPASSAR O REMANESCENTE para o saldo  ³
				//³ do caixinha e com isso o adiantamento ficara com saldo zero,³
				//³ o que permitira que o mesmo seja baixado/rendido.           ³

				If EU_SLDADIA > 0
					lAdia		:=	.T.
					nRecAdia	:=	RECNO()
				Else
					Replace EU_BAIXA With dDataBase
				Endif
				MsUnlock()
			Else
				Help(" ",1,"FA560SALDO")
				lRet	:=	.F.
			Endif
		Else
			Help(" ",1,"FA560NE") // Adiantamento informado nao encontrado
			lRet	:=	.F.
		Endif
	EndIf

Return lRet


/*/{Protheus.doc} TamFilBol
	Obtiene el tamaño de la filial de la tabla SF4.
	La función es llamada en GetFilOri (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 26/09/2022
	@param Nil
	@return cTamFil: Tamaño de la filial de SF4
	/*/
Function TamFilBol()
Local cTamFil := ""
Local cLayout := ""
Local lEmp	  := .F.
Local lUnid   := .F.
Local lFil	  := .F.
Local nAchou  := 0

	cLayout := ALLTRIM(FWSM0Layout())
	Do Case
		Case FWModeAccess("SF4",1) == "C"
			lEmp := .T.
		Case FWModeAccess("SF4",2) == "C"
			lUnid := .T.
		Case FWModeAccess("SF4",3) == "C"
			lFil := .T.
	EndCase
	IF !lEmp
		IF !lUnid
			IF lFil
				nAchou := at("F",cLayout)
			EndIf
		Else
			nAchou := at("U",cLayout)
		EndIf
	Else
		nAchou := at("E",cLayout)
	EndIf
	IF nAchou <= 1
		cTamFil := Space(FwSizeFilial())
	Else
		cTamFil := SUBSTR(cNumFil,1,nAchou-1)
		cTamFil := cTamFil+SPACE(LEN(cNumFil)-len(cTamFil))
	EndIf

Return cTamFil

/*/{Protheus.doc} LxDelCCBol
	Actualización de movimientos de caja chica en anulación de documentos fiscales.
	La función es llamada en LocXDelCC (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 26/09/2022
	@param 	cFilSEU: Filial de la tabla SEU.
			cNroAdia: Valor del campo EU_NROADIA.
			cNumAnt: Valor del campo EU_NUM.
			nVlrDel: Valor del campo EU_VALOR.
	@return Nil
	/*/
Function LxDelCCBol(cFilSEU, cNroAdia, cNumAnt, nVlrDel)
Default cFilSEU  := ""
Default cNroAdia := ""
Default cNumAnt  := ""
Default nVlrDel  := 0

	dbSelectArea("SEU")
	SEU->(dbSetOrder(3))
	If SEU->(DbSeek(cFilSEU+cNroAdia+cNumAnt))
		RecLock("SEU",.F.)
		REPLACE EU_SLDADIA WITH EU_SLDADIA + nVlrDel
		If !Empty(EU_BAIXA)
			REPLACE EU_BAIXA WITH CTOD("//")
		Endif
		MsUnlock()
	EndIf

Return Nil

/*/{Protheus.doc} VdDocItBol
	Valida documento informado en D2_NFORI/D1_NFORI con serie en D2_SERIORI/D1_SERIORI para NDC/NCC.
	La función es llamada en LxVldDocIt (LOCXNF2.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 26/09/2022
	@param 	cNumeroDoc: Número de documento.
			cSerie: Serie del documento.
			cEspecie: Especie del documento.
			lM485PE: Valor del Punto de Entrada M465DORIFE. Default .T.
	@return lRet: .T. si cumple con las condiciones.
	/*/
Function VdDocItBol(cNumeroDoc, cSerie, cEspecie, lM485PE)
Local lRet     := .T.
Local aArea	   := {}
Local cCpoSerO := ""
Local cCpoDocO := ""
Local cCliForE := ""
Local cLojaE   := ""

Default cNumeroDoc	:= ""
Default cSerie		:= ""
Default cEspecie	:= ""
Default lM485PE     := .T. 

	cCpoSerO := IIf(cEspecie=="NDC","D2_SERIORI","D1_SERIORI")
	cCpoDocO := IIf(cEspecie=="NDC","D2_NFORI","D1_NFORI")
	cCliForE := IIf(cEspecie=="NDC",M->F2_CLIENTE,M->F1_FORNECE)
	cLojaE   := IIf(cEspecie=="NDC",M->F2_LOJA,M->F1_LOJA)

	aArea := GetArea()

	If lM485PE
		If !Empty(cNumeroDoc) .And. !Empty(cSerie)
			dbSelectArea("SF2")
			SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If !(SF2->(MsSeek(xFilial("SF2") + cNumeroDoc + cSerie + cCliForE + cLojaE)))
				MsgAlert(STR0022 + AllTrim(cSerie) + "-" + AllTrim(cNumeroDoc) + StrTran(STR0023, '###', AllTrim(cCliForE) + "-" + AllTrim(cLojaE))) //"El documento original informado en el detalle (" //"), no existe para el cliente ###. Informe otro e intente nuevamente."
				lRet := .F.
			EndIf
		Else
			MsgAlert(STR0024 + RTrim(FWX3Titulo(cCpoDocO)) + "(" + cCpoDocO + ") " + STR0025 + RTrim(FWX3Titulo(cCpoSerO)) + "(" + cCpoDocO + ") " + STR0026) //"Los campos " - " y " - ", deben ser informados en el detalle."
			lRet := .F.
		EndIf
	EndIf
	
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} BaixaCxBol
	Actualiza registro de tabla SEU - Caja chica.
	La función es llamada en NFVldCxa (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 29/09/2022
	@version version
	@param cAdia: Número de anticipo utilizado en el movimiento de caja chica. 
	@return Nil
	/*/
Function BaixaCxBol(cAdia)
Local aTmpSEU := {}

	If !Empty(cAdia)
		aTmpSEU := SEU->(GetArea())
		SEU->(DbSetOrder(6))
		If SEU->(DbSeek(xFilial("SEU")+SET->ET_CODIGO+"00"+cAdia))
			While (SEU->(!Eof())) .And. (xFilial("SEU")+SET->ET_CODIGO+"00"+cAdia)== SEU->EU_FILIAL+SEU->EU_CAIXA+"00"+SEU->EU_NROADIA
				RecLock("SEU",.F.)
				Replace	EU_BAIXA With dDataBase
				MsUnlock()
				SEU->(DbSkip())
			Enddo
		Endif
		Restarea(aTmpSEU)
	Endif
Return Nil
