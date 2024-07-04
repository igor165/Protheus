#include 'protheus.ch'
#include 'parmtype.ch'
#include 'LOCXCOL.ch'

#Define SnTipo      1
#Define ScCliFor    2
#Define SlFormProp  3
#Define SAliasHead  4

/*/{Protheus.doc} LxVldEncC
Valida datos del encabezado al ejecutar la acción Doc Orig para Notas de Crédito para país Colombia.
@type
@author luis.enriquez
@since 12/03/2020
@version 1.0
@param aCfgNF, arreglo, Arreglo de datos del documento
@param cFunName, caracter, Nombre del programa en ejecución
@return lRetVld, falso si se detecto que no existe informado algún campo
@example
LxVldEncC(aCfgNF,cFunName) 
@see (links_or_references)
/*/
Function LxVldEncC(aCfgNF,cFunName)
	Local cDato   := ""
	Local cCpoCli := IIf(aCfgNF[SAliasHead] == "SF1","F1_FORNECE","F2_CLIENTE")
	Local cCpoLoja:= IIf(aCfgNF[SAliasHead] == "SF1","F1_LOJA","F2_LOJA")
	Local cCpoTpO := IIf(aCfgNF[SAliasHead] == "SF1","F1_TIPOPE","F2_TIPOPE")
	Local cCliFor := IIf(aCfgNF[SAliasHead] == "SF1",M->F1_FORNECE,M->F2_CLIENTE)
	Local cLoja   := IIf(aCfgNF[SAliasHead] == "SF1",M->F1_LOJA,M->F2_LOJA)
	Local cTipOpe := IIf(aCfgNF[SAliasHead] == "SF1",M->F1_TIPOPE,M->F2_TIPOPE)
	Local cCRLF   := (Chr(13) + Chr(10))
	Local lRetVld := .T.		
	
	If Empty(cCliFor) //Cliente
		cDato += "-" + FWX3Titulo(cCpoCli) + "(" + cCpoCli + ")" + cCRLF
	EndIf
	If Empty(cLoja) //Tienda
		cDato += "-" + FWX3Titulo(cCpoLoja) + "(" + cCpoLoja + ")" + cCRLF
	EndIf
	
	If cFunName == "MATA465N" .And. Empty(cTipOpe) .And. !Empty(GetMV("MV_PROVFE", .F., ""))
		cDato += "-" + FWX3Titulo(cCpoTpO) + "(" + cCpoTpO + ")" + cCRLF
	EndIf
	
	If !Empty(cDato) //Tienda
		MsgAlert(STR0001 + cCRLF + cDato) //"Es necesario informar los siguientes datos en el encabezado:"
		lRetVld := .F.
	EndIf			
Return lRetVld

/*/{Protheus.doc} LxMIVldCO
Función que realiza validación de acuerdo al valor y nombre del campo para país Colombia.
@type
@author luis.enriquez
@since 12/03/2020
@version 1.0
@param cValCpo, caracter, Valor del campo
@param cCpo, caracter, Nombre del campo
@return lRetVld, falso si se detecta que ocurrió algun detalle con la validación del campo.
@example
LxMIVldCO(cTpRel,cCpo)
@see (links_or_references)
/*/
Function LxMIVldCO(cValCpo,cCpo)
	Local lRetVld := .T.
	Local cProvFE := SuperGetMV("MV_PROVFE", .F., "")
	Local cTpDoc  := ""
	Local cAviso  := ""
	
	Default cValCpo:= ""
	Default cCpo   := ""
	
	If !Empty(cProvFE) 
		If cCpo == "F1_TIPOPE" .Or. cCpo == "F2_TIPOPE"
			If Empty(cValCpo)
				cAviso := StrTran(STR0002, '###', RTrim(FWX3Titulo(cCpo))) + " (" + cCpo + ")." //"Es necesario informar en el encabezado el campo ###"  
				lRetVld := .F.
			Else
				cTpDoc := AllTrim(ObtColSAT("S017",Alltrim(cValCpo),1,4,85,3))
				If !Empty(cTpDoc) .And. !(Alltrim(cEspecie) == Alltrim(cTpDoc))
					cAviso := StrTran(STR0003, '###', RTrim(FWX3Titulo(cCpo))) + cCpo + STR0004 //"El campo ###( //"), no contiene un tipo de operación válido para el tipo de documento."
					lRetVld := .F.
				EndIf		
			EndIf
		EndIf
	EndIf
	If !Empty(cAviso)
		Aviso(STR0005, cAviso, {STR0006}) //"Atención" //"OK"
	EndIf	
Return lRetVld

/*/{Protheus.doc} LxCpoCol
Funcion utilizada para agregar campos al encabezado de
Notas Fiscales para Colombia.
@type Function
@author luis.enriquez
@since 08/08/2019
@version 1.1
@param aCposNF, Array, Array con campos del encabezado de NF
@param cFunName, Character, Codigo de rutina
@param cTablaEnc, Character, Alias del encabezado de Notas Fiscales
@example LxCpoCol(aCposNF, cFunName, cTablaEnc)
@return aCposNF, Array, Campos para el Encabezado de Notas Fiscales.
@see (links_or_references)
/*/
Function LxCpoCol(aCposNF, cFunName, cTablaEnc)
	
	Local cProvFE := SuperGetMV("MV_PROVFE",,"")
    Local cVld    := ""
    Local aSX3    := {}
    If Type("lDocSp") == "U"
		Private lDocSp := .F.
	EndIf
    If cTablaEnc == "SF2"
		If SF2->(ColumnPos( "F2_CODMUN" )) > 0
			aSX3 := LxSX3Cache("F2_CODMUN")
			cVld := LocX3Valid("F2_CODMUN")
			AAdd(aCposNF,{FWX3Titulo("F2_CODMUN"),"F2_CODMUN",aSX3[1],aSX3[2],aSX3[3],cVld,aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
		EndIf
		If SF2->(ColumnPos( "F2_TPACTIV" )) > 0
			aSX3 := LxSX3Cache("F2_TPACTIV")
			cVld := LocX3Valid("F2_TPACTIV")
			AAdd(aCposNF,{FWX3Titulo("F2_TPACTIV"),"F2_TPACTIV",aSX3[1],aSX3[2],aSX3[3],cVld,aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,})
		EndIf
		IF SF2->(ColumnPos( "F2_TRMPAC" )) > 0 .AND. ( cFunName $ "MATA467N|MATA462N|" )
			SX3->(MsSeek("F2_TRMPAC"))
			AAdd(aCposNF,{FWX3Titulo("F2_TRMPAC"),"F2_TRMPAC",,,,,,,"SF2",,,,,,,,,,,.T.,StrTokArr(Alltrim(X3CBox()),';'),{|x| x:nAt}})
		EndIf
		IF SF2->(ColumnPos( "F2_TIPOPE" )) > 0 .AND. ( cFunName $ "MATA467N|MATA462N|MATA465N" ) .And. !Empty(cProvFE)
			aSX3 := LxSX3Cache("F2_TIPOPE")
			AAdd(aCposNF,{FWX3Titulo("F2_TIPOPE"),"F2_TIPOPE",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
		EndIf
		If cFunName $ "MATA466N"
			If  aCfgNF[1] == 22 // Nota Ajuste NCP 
				nPosCpo:= Ascan(aCposNF,{|x| x[2] == "F2_SERIE"}) 
				If nPosCpo > 0
					aCposNF[nPosCpo][16] := "01" // Consulta(SX5) 
				Endif
				nPosCpo:= Ascan(aCposNF,{|x| x[2] == "F2_CLIENTE"}) 
				If nPosCpo > 0
					aCposNF[nPosCpo][6] := aCposNF[nPosCpo][6] + ".and. LxVlCabCol()" // Validacion de Proveedor vs Cliente
				Endif
				If SF2->(ColumnPos( "F2_TIPNOTA" )) > 0 
					aSX3 := LxSX3Cache("F2_TIPNOTA")
					AAdd(aCposNF,{FWX3Titulo("F2_TIPNOTA"),"F2_TIPNOTA",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,.T.,,,aSX3[8]})
				EndIf
			EndIf
		EndIf
	Else
		IF SF1->(ColumnPos("F1_CODMUN")) > 0
			SX3->(MsSeek("F1_CODMUN"))
			cVld := LocX3Valid("F1_CODMUN")
			AAdd(aCposNF,{FWX3Titulo("F1_CODMUN"),"F1_CODMUN",	SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL, cVld, SX3->X3_USADO,SX3->X3_TIPO,"SF1",SX3->X3_CONTEXT,,,,,,SX3->X3_F3})
		EndIF
		If SF1->(ColumnPos("F1_TPACTIV")) > 0 .AND. ( cFunName$"MATA465N|MATA101N|MATA466N" )
			SX3->(MsSeek("F1_TPACTIV"))
			cVld := LocX3Valid("F1_TPACTIV")
			AAdd(aCposNF,{FWX3Titulo("F1_TPACTIV"),"F1_TPACTIV",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,cVld,SX3->X3_USADO,SX3->X3_TIPO,"SF1",SX3->X3_CONTEXT,,,,,,SX3->X3_F3})
		EndIf
		If cFunName $ "MATA101N"
			IF SF1->(ColumnPos("F1_TRMPAC")) > 0
				SX3->(MsSeek("F1_TRMPAC"))
				AAdd(aCposNF,{FWX3Titulo("F1_TRMPAC"),"F1_TRMPAC",,,,,,,"SF1",,,,,,,,,,,.T.,StrTokArr(ALLTRIM(x3cbox()),';'),{|x| x:nAt}})
			EndIf

			If lDocSp
				nPosCpo:= Ascan(aCposNF,{|x| x[2] == "F1_SERIE"}) 
				If nPosCpo > 0
					aCposNF[nPosCpo][16] := "01" // Consulta(SX5) 
				Endif
				nPosCpo:= Ascan(aCposNF,{|x| x[2] == "F1_FORNECE"}) 
				If nPosCpo > 0
					aCposNF[nPosCpo][6] := aCposNF[nPosCpo][6] + ".and. LxVlCabCol()" // Validacion de Proveedor vs Cliente
				Endif
			Endif
		EndIf
		If cFunName $ "MATA466N"
			If  aCfgNF[1] == 23  // Nota Ajuste NDP 
				nPosCpo:= Ascan(aCposNF,{|x| x[2] == "F1_SERIE"}) 
				If nPosCpo > 0
					aCposNF[nPosCpo][16] := "01" // Consulta(SX5) 
				Endif
				nPosCpo:= Ascan(aCposNF,{|x| x[2] == "F1_FORNECE"}) 
				If nPosCpo > 0
					aCposNF[nPosCpo][6] := aCposNF[nPosCpo][6] + ".and. LxVlCabCol()" // Validacion de Proveedor vs Cliente
				Endif
				If SF1->(ColumnPos( "F1_TIPNOTA" )) > 0 
					aSX3 := LxSX3Cache("F1_TIPNOTA")
					AAdd(aCposNF,{FWX3Titulo("F1_TIPNOTA"),"F1_TIPNOTA",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,.T.,,,aSX3[8]})
					
				EndIf
			EndIf
		EndIf
	EndIf
	
Return aCposNF

/*/{Protheus.doc} LxSX3Cache
Función para obtener datos del SX3 para campos usando la función GetSX3Cache
@type
@author luis.enriquez
@since 18/03/2020
@version 1.0
@param cCampo, caracter, Nombre del campo.
@return aSX3Cpos, array, Arreglo con contenido de la tabla SX3 para el campo.
@see (links_or_references)
/*/
Function LxSX3Cache(cCampo)
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

/*/{Protheus.doc} LxVldFact
Función para validar el borrado TSS de la factura para el pais Colombia
@type
@author eduardo.manriquez
@since 24/06/2020
@version 1.0
@param cAlias, caracter, Alias de la tabla.
@see (links_or_references)
/*/
Function LxVldFact(cAlias, lNotAjus)
	Local lRet := .T. 
	Default cAlias := ""
	Default lNotAjus := .F. 
	
	If cAlias == "SF2" .And. SF2->(ColumnPos("F2_FLFTEX"))>0
		If Val(SF2->F2_FLFTEX) == 6 .OR. !Empty(SF2->F2_FLFTEX)
			//"La factura Serie y No. "###"no puede ser borrada pues ya fue procesada por la Transmisión Electrónica. Utilice la opción Anular"  ###"¡TSS: Transmisión Electrónica !"
			If !lNotAjus 
				MsgAlert( STR0007 + " " + SF2->F2_SERIE + SF2->F2_DOC + STR0008 , STR0010 )
			Else
				//"La Nota de Ajuste"//" no puede ser borrada. El Documento ya fue autorizada por la DIAN.."//"¡Transmisión Electrónica!"
				MsgAlert( STR0032 + " " + SF2->F2_SERIE + SF2->F2_DOC + STR0033  , STR0034 )
			Endif
			lRet := .F.
		EndIf
	ElseIf cAlias <> "SF2" .And. SF1->(ColumnPos("F1_FLFTEX"))>0
		If Val(SF1->F1_FLFTEX) == 6 .OR. !Empty(SF1->F1_FLFTEX)
			//"La factura Serie y No. "###"no puede ser borrada pues ya fue procesada por la Transmisión Electrónica. Utilice la opción Anular"  ###"¡TSS: Transmisión Electrónica !"
			If !lNotAjus
				MsgAlert( STR0007 + " " + SF1->F1_SERIE + SF1->F1_DOC + STR0009 , STR0010 )
			Else
				//"La Nota de Ajuste"//" no puede ser borrada. El Documento ya fue autorizada por la DIAN.."//"¡Transmisión Electrónica!"
				MsgAlert( STR0032 + " " + SF1->F1_SERIE + SF1->F1_DOC + STR0033 , STR0034 )
			Endif
			lRet := .F.
		EndIf
	Endif
Return lRet

/*/{Protheus.doc} M030AltCV0
Funcion utilizada en la rutina de Clientes para actualizar
o incluir valores en tabla CV0 (MATN030).
@type Function
@author Marco Augusto Gonzalez Rivera	
@since 30/07/2020
@version 1.0
@param lIncReg, Lógico, Indica si es inclusión o modificación.
/*/
Function M030AltCV0(lIncReg)
	
	Local aArea		:= GetArea()
	Local cAliasCV0	:= GetNextAlias()
	Local nRecnoCV0	:= 0
	Local nReg      := 0
	Local cItm      := ""
	Local cEntSup := Alltrim(SuperGetMV("MV_ENTSCLI ",.T.,"13"))

	cEntSup := iif(Empty(cEntSup),"13",cEntSup)
	If lIncReg
		BeginSQL Alias cAliasCV0
				SELECT CV0.R_E_C_N_O_
				FROM %table:CV0% CV0
				WHERE CV0.CV0_FILIAL = %xfilial:CV0% AND
					CV0.CV0_CODIGO = %Exp:cEntSup% AND
					CV0.%notDel%
		EndSQL
		Count to nReg
		(cAliasCV0)->(DBCloseArea())
		If nReg == 0
			DBSelectArea("CV0")
			cItm := GetSxENum( "CV0", "CV0_ITEM" )
			RecLock("CV0",.T.)
			CV0->CV0_FILIAL	:=xFilial("CV0")
			CV0->CV0_PLANO	:="01"
			CV0->CV0_ITEM		:=cItm
			CV0->CV0_CODIGO 	:= cEntSup
			CV0->CV0_CLASSE  	:= "1"
			CV0->CV0_NORMAL 	:= "1"
			CV0->CV0_DTIEXI 	:= dDatabase
			CV0->CV0_BLOQUE 	:= "2"
			CV0->CV0_DESC   	:= STR0013 // "Clientes"
			CV0->(MsUnlock())
			ConfirmSX8()
		EndIf
		DBSelectArea("CV0")
		cItm := GetSxENum( "CV0", "CV0_ITEM" )
		Begin Transaction
			RecLock("CV0", .T.)
			CV0->CV0_FILIAL 	:= xFilial("CV0")
			CV0->CV0_CODIGO 	:= IIf(AllTrim(M->A1_TIPDOC) == "31", M->A1_CGC, M->A1_PFISICA)
			CV0->CV0_PLANO  	:=	"01"
			CV0->CV0_ITEM		:=	cItm
			CV0->CV0_CLASSE 	:= "2"
			CV0->CV0_NORMAL 	:= "1"
			CV0->CV0_ENTSUP 	:= cEntSup
			CV0->CV0_DTIEXI 	:= dDatabase
			CV0->CV0_TIPO00 	:= "01"
			CV0->CV0_TIPO01 	:= M->A1_TIPDOC
			CV0->CV0_DESC		:= M->A1_NOME
			CV0->CV0_COD		:= M->A1_COD
			CV0->CV0_LOJA		:= M->A1_LOJA
			CV0->(MsUnlock())
			ConfirmSX8()
		End Transaction
	Else
		BeginSQL Alias cAliasCV0
			SELECT CV0.R_E_C_N_O_
			FROM %table:CV0% CV0
			WHERE CV0.CV0_FILIAL = %xfilial:CV0% AND
				CV0.CV0_COD = %Exp:M->A1_COD% AND
				CV0.CV0_LOJA = %Exp:M->A1_LOJA% AND
				CV0.CV0_TIPO00 = '01' AND
				CV0.%notDel%
		EndSQL
		
		nRecnoCV0 := (cAliasCV0)->(R_E_C_N_O_)
		
		If nRecnoCV0 > 0
			DBSelectArea("CV0")
			CV0->(DBGoTo(nRecnoCV0))
			RecLock("CV0", .F.)
			CV0->CV0_DESC	:= M->A1_NOME
			CV0->CV0_COD	:= M->A1_COD
			CV0->CV0_LOJA	:= M->A1_LOJA
			CV0->CV0_CODIGO := IIf(AllTrim(M->A1_TIPDOC) == "31", M->A1_CGC, M->A1_PFISICA)
			CV0->CV0_TIPO01 := M->A1_TIPDOC
			CV0->(MsUnlock())
		EndIf
		
		(cAliasCV0)->(DBCloseArea())
		
	EndIf
	
	RestArea(aArea)
	
Return 

/*/{Protheus.doc} M030ValMov
Funcion utilizada en la rutina de Clientes para validar
si existen movimientos contables antes de actualizar CV0(MATN030).
@type Function
@author Oscar García López
@since 27/10/2020
@version 1.0
@param cCodigo, caracter, codigo cliente.
@param cLoja, caracter, tienda cliente.
@return lExist, lógico, Indica si existen o no movimientos contables para el tipo del documento del cliente.
/*/
Function M030ValMov(cCodigo, cLoja)

	Local lExist	:= .F.
	Local cBusca	:= ""
	Local lDif		:= .F.
	Local cNIT		:= ""
	Local cPFis		:= ""
	Local aArea		:= GetArea()
	
	Default cCodigo := ""
	Default cLoja := ""

	DBSelectArea("SA1")
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	If SA1->(MsSeek(xFilial("SA1") + cCodigo + cLoja))
		cNIT		:= Alltrim(SA1->A1_PFISICA)
		cPFis		:= Alltrim(SA1->A1_CGC)
		
		If AllTrim(SA1->A1_TIPDOC) == "31"
			lDif	:= !(cPFis == Alltrim(M->A1_CGC))
			cBusca	:= cPFis
		Else
			lDif	:= !(cNIT == Alltrim(M->A1_PFISICA))
			cBusca	:= cNIT
		EndIf
		
		If lDif
			cAliasMov := GetNextAlias()
			BeginSQL Alias cAliasMov
				SELECT CT2.R_E_C_N_O_
				FROM %table:CT2% CT2
				WHERE CT2.CT2_FILIAL = %xfilial:CT2% AND
					( CT2_EC05DB = %Exp:cBusca% OR 
					CT2_EC05CR = %Exp:cBusca% )
			EndSQL
			
			If (cAliasMov)->(R_E_C_N_O_) > 0
				lExist := .T.
			EndIf
			(cAliasMov)->(DBCloseArea())
			
			If !lExist
				cAliasMov := GetNextAlias()
				BeginSQL Alias cAliasMov
					SELECT CVX.R_E_C_N_O_
					FROM %table:CVX% CVX
					WHERE CVX.CVX_FILIAL = %xfilial:CVX% AND
						CVX_NIV05 = %Exp:cBusca%
				EndSQL
				
				If (cAliasMov)->(R_E_C_N_O_) > 0
					lExist := .T.
				EndIf
				(cAliasMov)->(DBCloseArea())
			EndIf
			
			If !lExist
				cAliasMov := GetNextAlias()
				BeginSQL Alias cAliasMov
					SELECT CVY.R_E_C_N_O_
					FROM %table:CVY% CVY
					WHERE CVY.CVY_FILIAL = %xfilial:CVY% AND
						CVY_NIV05 = %Exp:cBusca%
				EndSQL
				
				If (cAliasMov)->(R_E_C_N_O_) > 0
					lExist := .T.
				EndIf
				(cAliasMov)->(DBCloseArea())
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return lExist
/*/{Protheus.doc} LxVlCabCol
Funcion utilizada en el campo F1_FORNECE cuando es un Docto Soporte
y valida si el proveedor seleccionado tiene un cliente relacionado.
@type Function
@author Oscar García López
@since 27/10/2020
@version 1.0
@return lRet, lógico
/*/
Function LxVlCabCol()
	Local lAuto := IsBlind()
	Local aArea := GetArea()
	Local lRet	:= .T.
	Local cIndFor := 'M->F1_FORNECE '
	Local cIndLoj := 'M->F1_LOJA'

	If Type("lDocSp") == "U"
		Private lDocSp := .F.
	EndIf
	DBSelectArea("SA2")
	SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
	DBSelectArea("SA1")
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

	If !lAuto
		If lDocSp .or. aCfgNF[1] == 22 .or. aCfgNF[1] == 23 //Doc Soporte / NDP Ajuste / NCP Ajuste
			If aCfgNF[1] == 22 //NCP Ajuste
				 cIndFor := 'M->F2_CLIENTE '
				 cIndLoj := 'M->F2_LOJA'
			EndIf
			If SA2->(MsSeek(xFilial("SA2") + &cIndFor + &cIndLoj))
				If !(SA1->(MsSeek(xFilial("SA1") + SA2->(A2_CLIENTE + A2_LOJCLI))))
					MsgAlert(STR0011,STR0012) //"Cliente asociado al Proveedor no existe en la tabla de Clientes."//"Cliente no encontrado"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} M020AltCV0
	Función que realiza la inclusión, modificación y elimicación de los registro en la
	tabla CV0 del proveedor.
	@type  Function
	@author eduardo.manriquez
	@since 18/05/2022
	@version 1.0
	@param nOpc, Númerico, Opción del modelo que se esta ejecutando, 3 - Insersión, 4 - Edición y 5 - Eliminación.
	@param cCodigo, Caracter, Código del proveedor.
	@return 
	@example
	M020AltCV0(nOpc,cCodigo)
	/*/
Function M020AltCV0(nOpc,cCodigo)
    Local cItm := ""
    Local cEntSup := Alltrim(SuperGetMV("MV_ENTSPRO",.T.,"22"))
	Local cAliasCV0 := ""
	Local nReg      := 0
	Default cCodigo := ""

	cEntSup := iif(Empty(cEntSup),"22",cEntSup)
	If nOpc == 3
		Begin Transaction
			cAliasCV0 := GetNextAlias()
			BeginSQL Alias cAliasCV0
				SELECT CV0.R_E_C_N_O_
				FROM %table:CV0% CV0
				WHERE CV0.CV0_FILIAL = %xfilial:CV0% AND
					CV0.CV0_CODIGO = %Exp:cEntSup% AND
					CV0.%notDel%
			EndSQL
			Count to nReg
			(cAliasCV0)->(DBCloseArea())
			If nReg == 0
				DBSelectArea("CV0")
				cItm := GetSxENum( "CV0", "CV0_ITEM" )
				RecLock("CV0",.T.)
				CV0->CV0_FILIAL	:=xFilial("CV0")
				CV0->CV0_PLANO	:="01"
				CV0->CV0_ITEM		:=cItm
				CV0->CV0_CODIGO 	:= cEntSup
				CV0->CV0_CLASSE  	:= "1"
				CV0->CV0_NORMAL 	:= "2"
				CV0->CV0_DTIEXI 	:= dDatabase
				CV0->CV0_BLOQUE 	:= "2"
				CV0->CV0_DESC   	:= STR0014 // "Proveedores"
				CV0->(MsUnlock())
				ConfirmSX8()
			EndIf
			DBSelectArea("CV0")
			cItm := GetSxENum( "CV0", "CV0_ITEM" )
			RecLock("CV0",.T.)
			CV0->CV0_FILIAL	:=xFilial("CV0")
			CV0->CV0_PLANO	:="01"
			CV0->CV0_ITEM		:=cItm
			CV0->CV0_CODIGO 	:= IIF(M->A2_TIPDOC=="31",M->A2_CGC,M->A2_PFISICA)
			CV0->CV0_CLASSE  	:= "2"
			CV0->CV0_NORMAL 	:= "2"
			CV0->CV0_ENTSUP 	:= cEntSup
			CV0->CV0_DTIEXI 	:= dDatabase
			CV0->CV0_TIPO00 	:= "02"
			CV0->CV0_DESC   	:= M->A2_NOME
			CV0->CV0_TIPO01 	:= M->A2_TIPDOC  
			CV0->CV0_COD   	:= M->A2_COD
	   		CV0->CV0_LOJA  	:= M->A2_LOJA
			CV0->(MsUnlock())
			ConfirmSX8()
		End Transaction
	
	ElseIf nOpc == 4
		DbSelectArea("CV0")
		DbSetOrder(4)//CV0_FILIAL+CV0_COD+CV0_TIPO00+CV0_CODIGO
		If DbSeek(xFilial("CV0")+M->A2_COD+'02'+M->A2_CGC) .OR. DbSeek(xFilial("CV0")+M->A2_COD+'02'+M->A2_PFISICA)
			RecLock("CV0",.F.)
			CV0->CV0_DESC	:= M->A2_NOME
			CV0->CV0_COD	:= M->A2_COD
		   	CV0->CV0_LOJA	:= M->A2_LOJA
		  	CV0->(MsUnlock())
		Elseif DbSeek(xFilial("CV0")+M->A2_COD+'02')
			RecLock("CV0",.F.)
			CV0->CV0_DESC	:= M->A2_NOME
			CV0->CV0_COD	:= M->A2_COD
		   	CV0->CV0_LOJA	:= M->A2_LOJA
		   	CV0->CV0_CODIGO := IIF(M->A2_TIPDOC=="31",M->A2_CGC,M->A2_PFISICA)
		   	CV0->CV0_TIPO01 	:= M->A2_TIPDOC 
		   	CV0->(MsUnlock())
		EndIf
		
	ElseIf nOpc == 5
		DbSelectArea("CV0")
		DbSetOrder(4)//CV0_FILIAL+CV0_COD+CV0_TIPO00+CV0_CODIGO
		If DbSeek(xFilial("CV0")+cCodigo+'02'+M->A2_CGC) .OR. DbSeek(xFilial("CV0")+cCodigo+'02'+M->A2_PFISICA)
			RecLock("CV0",.F.)
			CV0->(dbDelete())
		   	CV0->(MsUnlock())
		EndIf
	EndIf

Return


/*/{Protheus.doc} xGrvCabCOL
	Actualiza campos del encabezado especificos para Colombia.
	La función es ejecutada desde LOCXNF, función GravaCabNF.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	aCabNota: Array con campos y valores valores de encabezado
			nI: Posición del campo en aCabNota
	@return Nil
	/*/
Function xGrvCabCOL(aCabNota, nI)
Default aCabNota := {}
Default nI       := 0

	If aCabNota[1][nI] $ "F1_TRMPAC|F2_TRMPAC|"
		Replace &(aCabNota[1][nI]) With CVALTOCHAR(aCabNota[2][nI])
	Else
		Replace &(aCabNota[1][nI]) With aCabNota[2][nI]
	Endif

Return

/*/{Protheus.doc} xGrvImpCol
	Graba información de impuestos para Colombia.
	La función es ejecutada desde LOCXNF, función GravaImposto.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	cAliasC: Alias tabla (SF1/SF2)
			nPosPed: Posición del campo D1_PEDIDO en aHeader
			nCodPro: Posición del campo D1_COD en aHeader
			nPosCF:  Posición del campo D1_CF en aHeader
			cFilSB1: Filial de tabla SB1
			aCols:   Array de ítems de documento fiscal
			nZ:      Número de ítem en aCols
	@return Nil
	/*/
Function xGrvImpCol(cAliasC, nPosPed, nCodPro, nPosCF, cFilSB1, aCols, nZ)
Local lPedido 	:= .F.

Default cAliasC := ""
Default nCodPro := 0
Default nPosCF  := 0
Default cFilSB1 := ""
Default aCols   := {}
Default nZ      := 0

	If nPosPed <> 0
		lPedido:= !Empty(aCols[nZ][nPosPed])
	Endif
	If cAliasC == 'SF1' .And. lPedido
		If nCodPro > 0
			SB1->(MsSeek(cFilSB1 + aCols[nZ][nCodPro]))
		EndIf
		MafisAlt('IT_CF', aCols[nZ][nPosCF], nZ)
	EndIf
Return

/*/{Protheus.doc} xCliForCol
	Actualiza información de campos de encabezado SF1/SF2.
	La función es ejecutada desde LOCXNF, función AtuCliFor.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	aCfgNf: Array de configuración para nota fiscal
			cTASARTF: Valor del campo F1_TASARFT
	@return Nil
	/*/
Function xCliForCol(aCfgNf, cTASARTF)
Local cMunic   := ""
Local cActiv   := ""
Local nPorBase := 0.0

Default aCfgNf   := {}
Default cTASARTF := ""

	If Type("aCfgNf") == "A"
		If	SF2->(FieldPos("F2_CODMUN")) > 0
			If aCfgNf[ScCliFor]=="SA2"
				cMunic := SA2->A2_COD_MUN
			Else
				cMunic := SA1->A1_COD_MUN
			Endif
			If aCfgNf[SAliasHead] == "SF2"
				M->F2_CODMUN := cMunic
			Else
				M->F1_CODMUN := cMunic
			Endif
			MaFisAlt("NF_CODMUN",cMunic)
		EndIf
		If	SF2->(FieldPos("F2_TPACTIV")) > 0
			If aCfgNf[ScCliFor]=="SA2"
				cActiv := SA2->A2_CODICA
			Else
				cActiv := SA1->A1_ATIVIDA
			Endif
			If aCfgNf[SAliasHead] == "SF2"
				M->F2_TPACTIV := cActiv
			Else
				M->F1_TPACTIV := cActiv
			Endif
			MaFisAlt("NF_TPACTIV",cActiv)
		EndIf

		If  aCfgNf[ScCliFor]=="SA2"
			nPorBase := SA2->A2_TASARFT
		Endif
		If aCfgNf[SAliasHead] == "SF1"
			M->F1_TASARFT := nPorBase
			cTASARTF      := nPorBase
		Endif
	EndIf
Return

/*/{Protheus.doc} xObtCFOCol
	Obtiene código fiscal de TES o funciones de automatización de TES.
	La función es ejecutada desde LOCXNF (función LxDocOri) y LOCXNF2 (función LxA103SD2ToaCols).
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	lAutTES: Identica si utiliza funcionalidad de automatización de TES (MV_AUTTES = .T.)
			cCliFor: Código de cliente o proveedor.
			cLoja: Código de loja de cliente o proveedor.
			cCodProd: Código de producto.
			cTES: Código de TES.
			aHeader: Array de campos SD1/SD2.
			aCols: Array de ítems de documento fiscal.
			nItem: Item de nota fiscal.
			nPosCFO: Posición de campo D1_CF en aHeader.
			nPosTes: Posición de campo D1_TES en aHeader.
	@return cCFO - Código Fiscal
	/*/
Function xObtCFOCol(lAutTES, cCliFor, cLoja, cCodProd, cTES, aHeader, aCols, nItem, nPosCFO, nPosTes, lMaFisAlt)
Local cCFO     := ""
Local aAreaSF4 := {}

Default lAutTES  := .T.
Default cCliFor  := ""
Default cLoja    := ""
Default cCodProd := ""
Default cTES     := ""
Default nPosCFO   := 0
Default lMaFisAlt := .F.

	If nPosCFO == 0
		nPosCFO := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_CF'})
	EndIf
	If Empty(cTES)
		nPosTes := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_TES'})
		cTES    := aCols[nItem][nPosTes]
	EndIf

	If lAutTES
		cCFO := LxTESAutoCOL(cCliFor, cLoja, cCodProd, "CF", "SD1")
	Else
		aAreaSF4 := SF4->(GetArea())
		cCFO := Posicione("SF4",1,xFilial("SF4")+cTES,"F4_CF")
		RestArea(aAreaSF4)
	EndIf

	// Conservar CF asignado por automatización de TES o definido por el usuario
	IIf(lMaFisAlt, MaFisAlt("IT_CF", cCFO, nItem), .T.)
	aCols[nItem][nPosCFO] := cCFO

Return cCFO

/*/{Protheus.doc} xValDupCol
	Obtiene código fiscal de TES o funciones de automatización de TES.
	La función es ejecutada desde LOCXNF2, funciones ValDuplic/LxA103Dupl.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	nValor: Valor del título financiero
			aHeader: Array de campos SD1/SD2.
			aCols: Array de ítems de documento fiscal.
			lA103Dupl: Flag para identificar origen de llamada de función.
	@return nValor: Valor de título financiero.
	/*/
Function xValDupCol(nValor, aHeader, acols, lA103Dupl)
Local nx         := 0
Local nPospd     := 0
Local cJNs       := ""
Local nValRetImp := 0
Local cFilSFC	 := xFilial("SFC")
Local cFunName   := FunName()

Default nValor    := 0
Default aHeader   := {}
Default acols     := {}
Default lA103Dupl := .F.

	dbSelectArea("SFC")
	dbSetOrder(2)

	SFB->(DbSeek(xFilial("SFB")+"RV0"))
	For nx:=1 to Len(acols)
		nPospd:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"} )
		If nPospd==0
			nPospd:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TES"} )
		EndIf

		If !acols[nx][Len(acols[1])] .And. !Empty(acols[nx][nPospd])

			If SFC->(MsSeek(cFilSFC + MaFisRet(Nx,"IT_TES")+ "RV0")) //Retenção IVA
					SFB->(DbSeek(xFilial("SFB")+"RV0"))

					If SFC->FC_INCDUPL == '2'
							nValRetImp 	+= (MaFisRet(Nx,"IT_VALIV2") )
					ElseIf SFC->FC_INCDUPL == '1'
							nValRetImp -= MaFisRet(Nx,"IT_VALIV2")
					EndIf

					cJNs:=SFB->FB_JNS
			EndIf
			If SFC->(MsSeek(cFilSFC + MaFisRet(Nx,"IT_TES")+ "RF0")) //Retenção TIMBRE
					SFB->(DbSeek(xFilial("SFB")+"RF0"))

					If SFC->FC_INCDUPL == '2'
							nValRetImp 	+= (MaFisRet(Nx,"IT_VALIV4") )
					ElseIf SFC->FC_INCDUPL == '1'
							nValRetImp -= MaFisRet(Nx,"IT_VALIV4")
					EndIf

					cJNs := SFB->FB_JNS
			EndIf
			If SFC->(MsSeek(cFilSFC + MaFisRet(Nx,"IT_TES")+ "RC0")) //Retenção ICA
				SFB->(DbSeek(xFilial("SFB")+"RC0"))

				If SFC->FC_INCDUPL == '2'
					nValRetImp 	+= (MaFisRet(Nx,"IT_VALIV7") )
				ElseIf SFC->FC_INCDUPL == '1'
					nValRetImp -=  MaFisRet(Nx,"IT_VALIV7")
				EndIf
				cJNs := SFB->FB_JNS
			EndIf
		EndIf
	Next
	If !lA103Dupl
		If cFunName == "MATA101N"
			nValor := nValor + nValRetImp
		Else
			If cJNs $ 'J|S'
				nValor := nValor + nValRetImp
			Endif
		Endif
	Else
		nValor := nValor + nValRetImp
	EndIf

Return (nValor)

/*/{Protheus.doc} VdDocItCol
	Valida documento informado en D2_NFORI/D1_NFORI con serie en D2_SERIORI/D1_SERIORI para NDC/NCC - Colombia.
	La función es ejecutada desde LOCXNF2, función LxVldDocIt.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	cNumeroDoc: Número de documento.
			cSerie: código de serie.
			cEspecie: Código de especie de documento.
			lM485PE: Flag de punto de entrada M465DORIFE. Si es .F. no realiza todas las validaciones.
	@return lRet: Identificar si cumple las condiciones.
	/*/
Function VdDocItCol(cNumeroDoc, cSerie, cEspecie, lM485PE)
Local lRet	   := .T.
Local aArea	   := GetArea()
Local cTipoFE  := SuperGetMV("MV_TIPOFE",,"")
Local cCpoSerO := IIf(cEspecie=="NDC","D2_SERIORI","D1_SERIORI")
Local cCpoDocO := IIf(cEspecie=="NDC","D2_NFORI","D1_NFORI")
Local cTipOpe  := IIf(cEspecie=="NDC",M->F2_TIPOPE,M->F1_TIPOPE)
Local cVldD    := ""
Local lValFE   := .T.
Local cCliForE := IIf(cEspecie=="NDC",M->F2_CLIENTE,M->F1_FORNECE)
Local cLojaE   := IIf(cEspecie=="NDC",M->F2_LOJA,M->F1_LOJA)

Default cNumeroDoc	:= ""
Default cSerie		:= ""
Default cEspecie	:= ""
Default lM485PE     := .T. 

	cVldD  := AllTrim(ObtColSAT("S017",cTipOpe,1,4,88,1))
	lValFE := IIf(!Empty(cTipOpe) .And. (cVldD $ "1|2" .Or. !(cVldD $ "0|1|2")),.T.,.F.)

	If lM485PE
		If !Empty(cNumeroDoc) .And. !Empty(cSerie)
			dbSelectArea("SF2")
			SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If SF2->(MsSeek(xFilial("SF2") + cNumeroDoc + cSerie + cCliForE + cLojaE))
				If lValFE
					If !(!Empty(SF2->F2_UUID) .And. (SF2->F2_FLFTEX == "1" .Or. (cTipoFE == "1" .And. SF2->F2_FLFTEX == "6")))
						MsgAlert(STR0015 + AllTrim(cSerie) + "-" + AllTrim(cNumeroDoc) + STR0017) //"El documento original informado en el detalle (" //"), no se encuentra transmitido. Realice la transmisión e intente nuevamente."
						lRet := .F.
					Else
						If cVldD == "2" .And. Len(Alltrim(SF2->F2_UUID)) <> 40
							MsgAlert(StrTran(STR0021, '###', cSerie + "-" + cNumeroDoc)) //"UUID del documento origen (###) no pertenece al modelo de Facturación Electrónica de Validación Posterior."
							lRet := .F.
						ElseIf cVldD == "1" .And. Len(Alltrim(SF2->F2_UUID)) <> 96
							MsgAlert(StrTran(STR0022, '###', cSerie + "-" + cNumeroDoc)) //"UUID del documento origen (###) no pertenece al modelo de Facturación Electrónica de Validación Previa."
							lRet := .F.
						EndIf
					EndIf
				EndIf
			Else
				MsgAlert(STR0015 + AllTrim(cSerie) + "-" + AllTrim(cNumeroDoc) + StrTran(STR0016, '###', AllTrim(cCliForE) + "-" + AllTrim(cLojaE))) //"El documento original informado en el detalle (" //"), no existe para el cliente ###. Informe otro e intente nuevamente."
				lRet := .F.
			EndIf
		Else
			If lValFE
				MsgAlert(STR0018 + RTrim(FWX3Titulo(cCpoDocO)) + "(" + cCpoDocO + ") " + STR0019 + RTrim(FWX3Titulo(cCpoSerO)) + "(" + cCpoDocO + ") " + STR0020) //"Los campos " - " y " - ", deben ser informados en el detalle."
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} x2M030COL
	Función para agregar acciones en modificación de clientes - Colombia.
	La función es ejecutada desde LOCXNF2, función Lx2M030CO.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	aButtons - Array con opciones. La variable se pasa por referencia (@aButtons)
	@return Nil.
	/*/
Function x2M030COL(aButtons)
Default aButtons := {}

	If !Empty(SuperGetMV("MV_PROVFE",,""))
		Aadd(aButtons,{"", { || FISA827( "SA1", SA1->(RecNo()), 4, 1) } ,STR0023}) //"Resp. Obligaciones DIAN"
		Aadd(aButtons,{"", { || FISA827( "SA1", SA1->(RecNo()), 4, 2) } ,STR0024}) //"Tributos DIAN"
	EndIf
Return

/*/{Protheus.doc} xVldCpoCol
	Valida campos para el país Colombia.
	La función es ejecutada desde LOCXNF2, función LxVldCol.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	cAliasSF: Alias de tabla (SF1/SF2)
	@return Nil.
	/*/
Function xVldCpoCol(cAliasSF)
Local lRetVld	:= .T.
Default cAliasSF := ""

	If cAliasSF == "SF1"
		lRetVld := ValRetSat(M->F1_TIPOPE, "F1_TIPOPE")
	ElseIf cAliasSF == "SF2"
		lRetVld := ValRetSat(M->F2_TIPOPE, "F2_TIPOPE")
	EndIf
Return lRetVld

/*/{Protheus.doc} ColExSer2
	Actualiza campo de serie 2 (F1_SERIE2/F2_SERIE2).
	La función es ejecutada desde LOCXNF2, función LxExSer2.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	N/A
	@return .T.
	/*/
Function ColExSer2()
Local aArea    := GetArea()
Local cVarAct  := readvar()
Local cOp      := "1"
Local cFunName := FunName()

	If  FunName() $ 'MATA101N|MATA466N' .and. FINDFUNCTION( 'LxSer2DsNa' )
		LxSer2DsNa(cVarAct, aCfgNF[1])
	ENDIF

	If cFunName $ 'MATA467N/MATA462N'
		cOp := IIF(cFunName $ 'MATA462N',"6","1")
		SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
		If ALLTRIM(cVaract) $ "M->F2_DOC/M->F2_SERIE" //factura de Venta
			If SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+M->F2_SERIE+cOp))
				M->F2_SERIE2:= SFP->FP_SERIE2
			Else
				M->F2_SERIE2:= ''
			EndIf
		Endif
	EndIf
	IF cFunName $ 'MATA465N'//  Nota de Debito/Credito
		SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
				If ALLTRIM(cVaract) $ "M->F1_DOC/M->F1_SERIE"  //NCC  CREDITO

				If SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+M->F1_SERIE+('2') ))
							M->F1_SERIE2:= SFP->FP_SERIE2
					Else
							M->F1_SERIE2:= ''
					EndIf
				Else
					If ALLTRIM(cVaract) $ "M->F2_DOC/M->F2_SERIE" //NDC  DEBITO

						IF SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+M->F2_SERIE+('3') ))
								M->F2_SERIE2:= SFP->FP_SERIE2
							Else
								M->F2_SERIE2:= ''
							EndIf
					Endif
				EndIf
	EndIf
	RestArea(aArea)

Return .T.

/*/{Protheus.doc} fSerDocCol
	Validación de serie y núemro de documento, asignación de SERIE2.
	La función es ejecutada desde LOCXNF2, función fValSerDoc.
	La función fValSerDoc es ejecutada por diccionario de datos, motivo por el cuál no se paso en los parámetros la variable lDocSp.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	N/A
	@return lRet: .T. si cumple las condiciones.
	/*/
Function fSerDocCol()
Local lRet := .T.

Local cFunName := IIf(Type("cFunName")=="U",Upper(Alltrim(FunName())),IIF(Empty(cFunName),Upper(Alltrim(FunName())),cFunName))
	If Type("lDocSp") == "U"
		Private lDocSp := .F.
	EndIf

If cFunName == "MATA465N" .OR. (cPaisloc =="COL" .AND. (lDocSp .OR. aCfgNF[1]== 23) .AND. cFunName $ "MATA101N|MATA466N" )
		lRet := ( CtrFolios(xFilial("SF1"),M->F1_SERIE,M->F1_ESPECIE,M->F1_DOC) .AND. LXEXSER2())
	Endif

Return lRet

/*/{Protheus.doc} LxSer2Col
	Valida campos para el país Colombia.
	La función es ejecutada desde LOCXNF, función NfTudOk.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	cAliasC: Alias tabla SF1/SF2.
			aCabNota: Campos del encabezado (SF1/SF2)
			cSerie: Serie del documento
			lSerie2: .T. Si utiliza serie 2.
	@return cSerie: Serie del documento fiscal.
	/*/
Function LxSer2Col(cAliasC, aCabNota, cSerie, lSerie2)
Local nPos := 0

Default cAliasC  := ""
Default aCabNota := {}
Default cSerie   := ""
Default lSerie2  := .F.

	If lSerie2
		nPos := Ascan(aCabNota[1], PrefixoCpo(cAliasC)+"_SERIE2")
		If nPos > 0 .And. Empty(cSerie)
			cSerie := aCabNota[2][nPos]
		EndIf
		If Empty(cSerie)
			nPos := Ascan(aCabNota[1],PrefixoCpo(cAliasC)+"_SERIE",++nPos)
			If ( nPos>0 )
				cSerie := aCabNota[2][nPos]
			EndIf
		EndIf
	Else
		nPos := Ascan(aCabNota[1],{ |x| UPPER(x) == AllTrim(PrefixoCpo(cAliasC)+"_SERIE") } )
		IIf( nPos > 0, cSerie := aCabNota[2][nPos], "")
	EndIf

Return cSerie

/*/{Protheus.doc} NfTudOkCol
	Validaciones generales previo al grabado del documento fiscal.
	La función es ejecutada desde LOCXNF, función NfTudOk.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	cAliasI: Alias de tabla SF1/SF2.
			cSerie: Serie del documento.
			aCfgNF: Array con la configuración del documento.
			aCitens: Items de NF (aCols).
			aCpItens: Campos de ítems (aHeader).
			cFilAnt: Filial del documento.
			cEspecie: Especie del documento fiscal.
			cnFiscal: Número de nota fiscal.
			cFunName: Nombre de la función del menú.
	@return lRet: .T. Si cumple con las condiciones.
	/*/
Function NfTudOkCol(cAliasI, cSerie, aCfgNF, aCitens, aCpItens, cFilAnt, cEspecie, cnFiscal, cFunName)
Local nI     := 0
Local lRet   := .T.
Local nSerie := 0
Local nNF    := 0

Default cAliasI  := ""
Default cSerie   := ""
Default aCfgNF   := {}
Default aCitens  := {}
Default aCpItens := {}
Default cFilAnt  := ""
Default cEspecie := ""
Default cnFiscal := ""

	If ( Len(cSerie) <= TamSX3(PrefixoCpo(cAliasI)+"_SERIE")[1])
		//³Verificando numeracao da NF em todos os itens
		nSerie	:= Ascan(aCpItens, {|x| Trim(x) == PrefixoCpo(cAliasI)+"_SERIE"})
		nNF		:= Ascan(aCpItens, {|x| Trim(x) == PrefixoCpo(cAliasI)+"_DOC"})
		For nI := 1 to Len(aCitens)
			If !aCitens[nI][Len(aCitens[nI])] .AND. aCitens[nI][nNF] != cNFiscal .OR. aCitens[nI][nSerie] != cSerie
				Aviso(STR0005,STR0025+"("+cnFiscal+"-"+cSerie+"/"+aCitens[nI][nNF]+"-"+aCitens[nI][nSerie]+")",{STR0006})					    			 //"ATENCAO"###"Inconsistencias com a numeracao da NF em relacao a seus itens"###"OK"
				lRet := .F.
				Loop
			EndIf
		Next nI
	EndIf

	If lRet .and. Valtype(aCfgNF[SlFormProp]) == "L" .And. aCfgNF[SlFormProp] .And. (!Str(aCfgNF[SnTipo],2)$"54|64|50|60") .And. GetNewPar("MV_CTRLFOL",.F.)
		lRet := CtrFolios(cFilAnt, cSerie, cEspecie, cnFiscal)
	EndIf
	
	lRet := IIf(lRet .And. cFunName $ "MATA467N|MATA462N|MATA465N", LxVldCol(aCfgNf[SAliasHead]), lRet)

Return lRet

/*/{Protheus.doc} xTesAutCol
	Función para obtener TES y Código Fiscal por tipo de documento.
	La función es ejecutada desde LOCXNF2, función TESAutoCol.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	cTabla: Alias de tabla: SC6, SC7, SD1 o SD2.
	@return .T..
	/*/
Function xTesAutCol(cTabla)
Local nPosCod		:= 0
Local nPosTes		:= 0
Local nPosCF		:= 0
Local cCod			:= ""
Local cTES			:= Space(TamSX3("D2_TES")[1])
Local cCF			:= Space(TamSX3("D2_CF")[1])
Local lAutTES		:= SuperGetMV("MV_AUTTES", .F., .T.) //Parametro que indica activacion de TES automatizada
Local cFilSB1		:= xFilial("SB1")
Local cFilSF4		:= xFilial("SF4")
Local cFilSA2		:= xFilial("SA2")
local cFilSA1		:= xFilial("SA1")
Local cOriCliPro	:= ""
Local lDocsSalida	:= IIf(FunName() $ 'MATA467N|MATA462N|MATA465N', .T., .F.)
Local cPrefTabla	:= IIf(lDocsSalida, "SA1", "SA2")
Local cCampoEst		:= IIf(lDocsSalida, "A1_EST", "A2_EST")
Local cFilCliPro	:= IIf(lDocsSalida, cFilSA1, cFilSA2)

Default cTabla	  := ""

	Do Case
		Case cTabla == "SC6"//Pedidos de Venta
			If ReadVar() == "M->C6_PRODUTO"
				cCod := M->C6_PRODUTO
			Else
				nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
				cCod := aCols[n][nPosCod]
			EndIf
			nPosTes	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"})
			nPosCF	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CF"})
			If !lAutTES
				cOriCliPro := Posicione("SA1", 1, cFilSA1 + M->C5_CLIENTE + M->C5_LOJACLI, "A1_EST")
				If AllTrim(cOriCliPro) <> "EX" //Si no es extranjero
					aCols[n][nPosTes] := Posicione("SB1", 1, cFilSB1 + cCod, 'B1_TS')
					aCols[n][nPosCF] := Posicione("SF4", 1, cFilSF4 + aCols[n][nPosTes], 'F4_CF')
				Else
					aCols[n][nPosTes] := cTES
					aCols[n][nPosCF] := cCF
				EndIf
			Else
				aCols[n][nPosTes] := LxTESAutoCOL(M->C5_CLIENTE, M->C5_LOJACLI, cCod, "TES", "")
				aCols[n][nPosCF]  := LxTESAutoCOL(M->C5_CLIENTE, M->C5_LOJACLI, cCod, "CF", "")
			EndIf

		Case cTabla == "SC7" //Pedidos de Compra
			If ReadVar() == "M->C7_PRODUTO"
				cCod := M->C7_PRODUTO
			Else
				nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})
				cCod := aCols[n][nPosCod]
			EndIf
			If !lAutTES //Sin Automatizacion de TES
				cOriCliPro := Posicione("SA2", 1, cFilSA2 + cA120Forn + cA120loj, "A2_EST")
				If AllTrim(cOriCliPro) <> "EX" //Si no es extranjero
					cTES := Posicione("SB1", 1, cFilSB1 + cCod, 'B1_TE')
				EndIf
			Else
				cTES := LxTESAutoCOL(cA120Forn, cA120loj, cCod, "TES", "")
			EndIf
			MaFisRef("IT_TES", "MT120", cTES)

		Case cTabla == "SD1"
			If ReadVar() == "M->D1_COD"
				cCod := M->D1_COD
			Else
				nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
				cCod := aCols[n][nPosCod]
			EndIf
			If !lAutTES
				cOriCliPro := Posicione(cPrefTabla, 1, cFilCliPro + M->F1_FORNECE + M->F1_LOJA, cCampoEst)
				If AllTrim(cOriCliPro) <> "EX" //Si no es extranjero
					cTES := Posicione("SB1", 1, cFilSB1 + cCod, 'B1_TE')
					cCF := Posicione("SF4", 1, cFilSF4 + cTES, 'F4_CF')
				EndIf
			Else
				cTES := LxTESAutoCOL(M->F1_FORNECE, M->F1_LOJA, cCod, "TES", "SD1")
				cCF := LxTESAutoCOL(M->F1_FORNECE, M->F1_LOJA, cCod, "CF", "SD1")
			EndIf
			If !Empty(cTES) .And. Type("n") == "N" .And. !(cTES == MaFisRet(n,"IT_TES"))
				MaFisRef("IT_TES", "MT100", cTES)
			EndIf
			MaFisRef("IT_CF", "MT100", cCF)

		Case (cTabla == "SD2" .Or. cTabla == "D2")
			If ReadVar() == "M->D2_COD"
				cCod := M->D2_COD
			Else
				nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_COD"})
				cCod := aCols[n][nPosCod]
			EndIf
			If !lAutTES
				cOriCliPro := Posicione(cPrefTabla, 1, cFilCliPro + M->F2_CLIENTE + M->F2_LOJA, cCampoEst)
				If AllTrim(cOriCliPro) <> "EX" //Si no es extranjero
					cTES := Posicione("SB1", 1, cFilSB1 + cCod, 'B1_TS')
					cCF := Posicione("SF4", 1, cFilSF4 + cTES, 'F4_CF')
				EndIf
			Else
				cTES := LxTESAutoCOL(M->F2_CLIENTE, M->F2_LOJA, cCod, "TES", "SD2")
				cCF := LxTESAutoCOL(M->F2_CLIENTE, M->F2_LOJA, cCod, "CF", "SD2")
			EndIf
			MaFisRef("IT_TES", "MT100", cTES)
			MaFisRef("IT_CF", "MT100", cCF)
			
	EndCase

Return .T.

/*/{Protheus.doc} xAutTesCOL
	Función para obtener TES o Código Fiscal por tipo de documento.
	La función es ejecutada desde LOCXNF2, función LxTESAutoCOL.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	cClieProve: Código cliente/proveedor.
			cTienda: Código loja cliente/proveedor.
			cProducto: Código de producto.
			cTipo: Tipo de dato a obtener (TES o CF).
			cMovimiento: Alias de tabla SD1 o SD2.
			aHeader: Array de campos.
			aCols: Items del documento.
	@return Si cTipo = 'TES', regresa cTES. Si cTipo = 'CF', regresa código fiscal.
	/*/
Function xAutTesCOL(cClieProve, cTienda, cProducto, cTipo, cMovimiento)
Local cOrigClien	:= ""
Local cOrigProve	:= ""
Local cRegiClien	:= ""
Local cRegiProve	:= ""
Local cFunName		:= FunName()

Local cFilSA1	:= ""
Local cFilSA2	:= ""
Local cFilAI0	:= ""
Local cFilSB1	:= xFilial("SB1")
Local cFilSF4	:= xFilial("SF4")

Local cTesItem	:= Space(TamSX3("D1_TES")[1])
Local cTES		:= Space(TamSX3("D2_TES")[1])
Local cCodFisc	:= Space(TamSX3("D2_CF")[1])

Local nPosDocOri	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_NFORI"})
Local nPosTES		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})

Default cClieProve	:= ""
Default cTienda		:= ""
Default cProducto	:= ""
Default cTipo		:= ""
Default cMovimiento	:= ""
Default aHeader     := {}
Default aCols       := {}

	/* Descripcion de Rutinas:
	 *
	 * MATA410	-> Pedido de Venta/Salida
	 * MATA467N	-> Factura de Venta/Salida
	 * MATA462N	-> Remision de Venta/Salida
	 * MATA465N	-> Nota de Debito/Credito Clientes (Ventas)
	 * MATA121	-> Pedido de Compra/Entrada
	 * MATA101N	-> Factura de Compra/Entrada
	 * MATA102N	-> Remision de Compra/Entrada
	 * MATA466N	-> Nota de Debito/Credito Proveedores (Compras)
	 *
	 */
	If cFunName == 'MATA410' // Si se accede desde la rutina Pedido de Venta/Salida
		cFilSA1 := xFilial("SA1")
		If cTipo == "TES"
			cOrigClien	:= Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_EST") // Obtiene el Origen del cliente
			If AllTrim(cOrigClien) == 'EX' // Si el cliente es Extranjero
				cTES := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_TS") //TES para venta a Clientes del Extranjero
			Else
				cRegiClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_TPESSOA") // Obtiene el Regimen del Cliente
				If cRegiClien == '1' // Si es Regimen Comun
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS") // TES para Regimen Comun
				ElseIf cRegiClien == '2' // Si es Regimen Simplificado
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS2") //TES para Regimen Simplificado
				EndIf
			EndIf
			Return cTES // Retorna TES de Pedido de Venta/Salida
		EndIf
		If cTipo == "CF"
			cRegiClien := IIF(Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_DECLAR") == "D", "D", "N") // Se valida el Regimen del Cliente
			If cRegiClien == 'D' // Si es Declarante
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO3") //Codigo Fiscal para Declarantes
			Else
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO4") //Codigo Fiscal para No Declarantes
			EndIf
			Return cCodFisc // Retorna CF de Pedido de Venta/Salida
		EndIf
	EndIf

	If cFunName == "MATA467N" // Si se accede desde la rutina Factura de Venta/Salida
		cFilSA1 := xFilial("SA1")
		If cTipo == "TES"
			cOrigClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_EST") // Obtiene el Origen del Cliente
			If AllTrim(cOrigClien) == 'EX' // Si el cliente es Extranjero
				cTES := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda,"A1_TS") //TES para venta a Clientes del Extranjero
			Else
				cRegiClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_TPESSOA") // Obtiene el Regimen del Cliente
				If cRegiClien == '1' // Si es Regimen Comun
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS") // TES para Regimen Comun
				ElseIf cRegiClien == '2' // Si es Regimen Simplificado
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS2") //TES para Regimen Simplificado
				EndIf
			EndIf
			Return cTES // Retorna TES de Factura de Compra/Entrada
		EndIf
		If cTipo == "CF"
			cRegiClien := IIF(Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_DECLAR") == "D", "D", "N") // Se valida el Regimen del Cliente
			If cRegiClien == 'D' // Si es Declarante
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO3") //Codigo Fiscal para Declarantes
			Else
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO4") //Codigo Fiscal para No Declarantes
			EndIf
			Return cCodFisc // Retorna CF de Factura de Compra/Entrada
		EndIf
	EndIf

	If cFunName == 'MATA462N' // Si se accede desde la rutina Remision de Venta/Salida
		cFilSA1 := xFilial("SA1")
		If cTipo == 'TES'
			cOrigClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_EST") // Obtiene el Origen del Cliente
			If AllTrim(cOrigClien) == 'EX' // Si el cliente es Extranjero
				cTES := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda,"A1_TS") //TES para venta a Clientes del Extranjero
			Else
				cRegiClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_TPESSOA") // Obtiene el Regimen del Cliente
				If cRegiClien == '1' // Si es Regimen Comun
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS") // TES para Regimen Comun
				ElseIf cRegiClien == '2' // Si es Regimen Simplificado
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS2") //TES para Regimen Simplificado
				EndIf
			EndIf
			Return cTES // Retorna TES
		EndIf
		If cTipo == 'CF'
			cRegiClien := IIF(Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_DECLAR") == "D", "D", "N") // Se valida el Regimen del Cliente
		    If cRegiClien == 'D' // Si es Declarante
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO3") //Codigo Fiscal para Declarantes
			Else
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO4") //Codigo Fiscal para No Declarantes
			EndIf
			Return cCodFisc // Retorna CF
		EndIf
	EndIf

	If cFunName == 'MATA465N' // Si se accede desde la rutina Nota de Debito/Credito Clientes (Ventas)
		cFilSA1 := xFilial("SA1")
		If cMovimiento == 'SD1' // Credito
			If cTipo == 'TES'
				cOrigClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_EST") // Obtiene el Origen del Cliente
				cTesItem := Posicione("SF4", 1, cFilSF4 + SD1->D1_TES, "F4_TESDV")
				If AllTrim(cOrigClien) == 'EX' // Si el cliente es Extranjero
					cFilAI0 := xFilial("AI0")
					cTES := Posicione("AI0", 1, cFilAI0 + cClieProve + cTienda,"AI0_TE") //TES para venta a Clientes del Extranjero
				ElseIf AllTrim(cTesItem) <> ""
					cTES := cTesItem
				Else
					If !Empty(aCols[N,nPosDocOri]) //Si existe un documento origen, deja la misma CF
						cTES := aCols[N,nPosTES]
					Else
						cRegiClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_TPESSOA") // Obtiene el Regimen del Cliente
						If cRegiClien == '1' // Si es Regimen Comun
							cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE") // TES para Regimen Comun
						ElseIf cRegiClien == '2' // Si es Regimen Simplificado
							cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE2") //TES para Regimen Simplificado
						EndIf
					EndIf
				EndIf
				Return cTES
			EndIf
			If cTipo == 'CF'
				cRegiClien := IIF(Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_DECLAR") == "D", "D", "N") // Se valida el Regimen del Cliente
				If cRegiClien == 'D' // Si es Declarante
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO") //Codigo Fiscal para Declarantes
				Else
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO2") //Codigo Fiscal para No Declarantes
				EndIf
				Return cCodFisc // Retorna CF
			EndIf
		EndIf
		If cMovimiento == 'SD2' // Debito
			If cTipo == 'TES'
				cOrigClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_EST") // Obtiene el Origen del Cliente
				If AllTrim(cOrigClien) == 'EX' // Si el cliente es Extranjero
					cTES := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda,"A1_TS") //TES para venta a Clientes del Extranjero
				Else
					cRegiClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_TPESSOA") // Obtiene el Regimen del Cliente
					If cRegiClien == '1' // Si es Regimen Comun
						cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS") // TES para Regimen Comun
					ElseIf cRegiClien == '2' // Si es Regimen Simplificado
						cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS2") //TES para Regimen Simplificado
					EndIf
				EndIf
				Return cTES
			EndIf
			If cTipo == 'CF'
				cRegiClien := IIF(Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_DECLAR") == "D", "D", "N") // Se valida el Regimen del Cliente
			    If cRegiClien == 'D' // Si es Declarante
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO3") //Codigo Fiscal para Declarantes
				Else
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO4") //Codigo Fiscal para No Declarantes
				EndIf
				Return cCodFisc // Retorna CF
			EndIf
		EndIf
	EndIf

	If cFunName == "MATA121" // Si se accede desde la rutina Pedido de Compra/Entrada
		cFilSA2 := xFilial("SA2")
		If cTipo == "TES"
			cOrigProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_EST") // Se obtiene el Origen del Proveedor
			If AllTrim(cOrigProve) == 'EX' // Si el Proveedor es Extranjero
				cTES := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda,"A2_TE") //TES para venta a Proveedores del Extranjero
			Else
				cRegiProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_TPESSOA") // Se obtiene el Regimen del Proveedor
				If cRegiProve == '1' // Si es Regimen Comun
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE") // TES para Regimen Comun
				ElseIf cRegiProve == '2' // Si es Regimen Simplificado
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE2") // TES para Regimen Simplificado
				EndIf
			EndIf
			Return cTES // Retorna TES de Pedido de Compra/Entrada
		EndIf
	EndIf

	If cFunName == "MATA101N" // Si se accede desde la rutina Factura de Compra/Entrada
		cFilSA2 := xFilial("SA2")
		If cTipo == "TES"
			cOrigProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_EST") // Se obtiene el Origen del Proveedor
			If AllTrim(cOrigProve) == 'EX' // Si el Proveedor es Extranjero
				cTES := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_TE") //TES para venta a Proveedores del Extranjero
			Else
				cRegiProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_TPESSOA") // Se obtiene el Regimen del Proveedor
				If cRegiProve == '1' // Si es Regimen Comun
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE") // TES para Regimen Comun
				ElseIf cRegiProve == '2' // Si es Regimen Simplificado
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE2") // TES para Regimen Simplificado
				EndIf
			EndIf
			Return cTES // Retorna TES de Factura de Compra/Entrada
		EndIf
		If cTipo == "CF"
			cRegiProve := IIF(Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_DECLAR") == "D", "D", "N") // Se valida el Regimen del Proveedor
			If cRegiProve == 'D' // Si es Declarante
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO") //Codigo Fiscal para Declarantes
			Else
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO2") //Codigo Fiscal para No Declarantes
			EndIf
			Return cCodFisc // Retorna CF
		EndIf
	EndIf

	If cFunName == 'MATA102N' // Si se accede a la rutina Remision de Compra/Entrada
		cFilSA2 := xFilial("SA2")
		If cTipo == 'TES'
			cOrigProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_EST") // Se obtiene el Origen del Proveedor
			If AllTrim(cOrigProve) == 'EX' // Si el Proveedor es Extranjero
				cTES := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda,"A2_TE") //TES para venta a Proveedores del Extranjero
			Else
				cRegiProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_TPESSOA") // Se obtiene el Regimen del Proveedor
				If cRegiProve == '1' // Si es Regimen Comun
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE") // TES para Regimen Comun
				ElseIf cRegiProve == '2' // Si es Regimen Simplificado
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE2") // TES para Regimen Simplificado
				EndIf
			EndIf
			Return cTES // Retorna TES
		EndIf
		If cTipo == 'CF'
			cRegiProve := IIF(Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_DECLAR") == "D", "D", "N") // Se valida el Regimen del Proveedor
			If cRegiProve == 'D' // Si es Declarante
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO") //Codigo Fiscal para Declarantes
			Else
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO2") //Codigo Fiscal para No Declarantes
			EndIf
			Return cCodFisc // Retorna CF
		EndIf
	EndIf

	If cFunName == 'MATA466N' // Si se accede desde la rutina Nota de Credito/Debito Proveedor (Compras)
		cFilSA2 := xFilial("SA2")
		If cMovimiento == 'SD1' // Debito
			If cTipo == 'TES'
				cOrigProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_EST") // Se obtiene el Origen del Proveedor
				If AllTrim(cOrigProve) == 'EX' // Si el Proveedor es Extranjero
					cTES := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda,"A2_TE") //TES para venta a Proveedores del Extranjero
				Else
					cRegiProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_TPESSOA") // Se obtiene el Regimen del Proveedor
					If cRegiProve == '1' // Si es Regimen Comun
						cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE") // TES para Regimen Comun
					ElseIf cRegiProve == '2' // Si es Regimen Simplificado
						cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE2") // TES para Regimen Simplificado
					EndIf
				EndIf
				Return cTES // Retorna TES
			EndIf
			If cTipo == 'CF'
				cRegiProve := IIF(Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_DECLAR") == "D", "D", "N") // Se valida el Regimen del Proveedor
				If cRegiProve == 'D' // Si es Declarante
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO") //Codigo Fiscal para Declarantes
				Else
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO2") //Codigo Fiscal para No Declarantes
				EndIf
				Return cCodFisc // Retorna CF
			EndIf
		EndIf
		If cMovimiento == 'SD2' // Credito
			If cTipo == 'TES'
				cOrigProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_EST") // Se obtiene el Origen del Proveedor
				If AllTrim(cOrigProve) == 'EX' // Si el Proveedor es Extranjero
					cTES := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda,"A2_TS") //TES para venta a Proveedores del Extranjero
				Else
					cRegiProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_TPESSOA") // Se obtiene el Regimen del Proveedor
			 		If cRegiProve == '1' // Si es Regimen Comun
						cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS") // TES para Regimen Comun
					ElseIf cRegiProve == '2' // Si es Regimen Simplificado
						cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS2") // TES para Regimen Simplificado
					EndIf
				EndIf
				Return cTES // Retorna TES de Nota de Credito de Proveedor
			EndIf
			If cTipo == 'CF'
				cRegiProve := IIF(Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_DECLAR") == "D", "D", "N") // Se valida el Regimen del Proveedor
				If cRegiProve == 'D' // Si es Declarante
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO3") //Codigo Fiscal para Declarantes
				Else
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO4") //Codigo Fiscal para No Declarantes
				EndIf
				Return cCodFisc // Retorna CF
			EndIf
		EndIf
	EndIf

Return

/*/{Protheus.doc} LxVldCFCol
	Conservar CF asignado por automatización de TES o definido por el usuario.
	La función es llamada en SCMToREM, SCMToREM2, SCMToNF2 y LxDocOri (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 21/09/2022
	@param 	aCols: Array de ítems de nota fiscal.
			cCFO: Código fiscal.
			nLenAcols: Tamaño de array aCols (Len(aCols))
			nCpoCFO: Posición del campo D1_CFO/D2_CFO en aCols.
	@return Nil
	/*/
Function LxVldCFCol(aCols, cCFO, nLenAcols, nCpoCFO)
Default aCols     := {}
Default cCFO      := ""
Default nLenAcols := Len(aCols)
Default nCpoCFO   := 0

	If nCpoCFO > 0 .And. !(cCFO == aCols[nLenAcols][nCpoCFO])
		MaFisAlt("IT_CF", cCFO, nLenAcols)
		aCols[nLenAcols][nCpoCFO] := cCFO
	EndIf
Return
/*/{Protheus.doc} LxObtTpCol
Funcion utilizada en la rutina LOCXNF, función Mata466n().
Asigna el tipo de documento para las notas de ajuste.
@type Function
@author Alfredo Medrano
@since 24/08/2022
@version 1.0
@param nFrmProp, Númerico, ByRef, Opción para el Formulario propio 1= Si y  2 = No 
@param nTipoFac, Númerico, ByRef, Tipo de Factura. 3 = Nota de Ajuste Débito y 4 = Nota de Ajuste Crédito.
@return nTipoDoc, Númerico, 7 para Nota Ajuste Crédito y 9 para Nota Ajuste Débito
/*/
Function LxObtTpCol( nFrmProp,  nTipoFac)
	Local nTipoDoc := 0
	DEFAULT nFrmProp := 0
	DEFAULT nTipoFac := 0

	If nFrmProp == 1 .AND. nTipoFac == 3//³Nota Ajuste NDP³
		nTipoDoc := 23
	ElseIf nFrmProp == 1 .AND. nTipoFac == 4//³Nota Ajuste NCP³
		nTipoDoc := 22
	Endif
Return nTipoDoc

/*/{Protheus.doc} LxSer2DsNa
Función utilizada en la rutina LOCXNF2, función LxExSer2().
Asigna la serie 2 para Docto soporte y Notas de Ajuste NCP/NDP
@type Function
@author Alfredo Medrano
@since 24/08/2022
@version 1.0
@param cVarAct,  Carácter, ByRef, Nombre Campo en Memoria
@param nNotAjus, Númerico, ByRef, Tipo de Factura.23 = Nota de Ajuste Débito y 22 = Nota de Ajuste Crédito.
@return .T.
/*/
Function LxSer2DsNa(cVarAct,nNotAjus)

	Local cSerDcT := ""
	Local cCampoDoc := ""
	Local cFunNamDc := FunName()
	Default cVarAct := ""
	If Type("lDocSp") == "U"
		Private lDocSp := .F.
	EndIf

	If lDocSp .AND. cFunNamDc $ 'MATA101N' // documento soporte
		cSerDcT := M->F1_SERIE+'1'
		cCampoDoc := 'F1_SERIE2'
	ElseIf nNotAjus == 22 .AND. cFunNamDc $ 'MATA466N' //Nota de Ajuste
		cSerDcT :=  M->F2_SERIE+'8' //NCP
		cCampoDoc := 'F2_SERIE2'
	ElseIf nNotAjus == 23 .AND. cFunNamDc $ 'MATA466N' //Nota de Ajuste
		cSerDcT :=  M->F1_SERIE+'9' //NDP	
		cCampoDoc := 'F1_SERIE2'
	EndIf
	SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
	If ALLTRIM(cVaract) $ "M->F1_DOC/M->F1_SERIE/M->F2_DOC/M->F2_SERIE" 
		If SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+cSerDcT))
			M->&cCampoDoc:= SFP->FP_SERIE2
		Else
			M->&cCampoDoc:= ''
		EndIf
	EndIf

Return .T.


/*/{Protheus.doc} lxEstrcCol
	Cargar la configuración de los documentos 22 y 23  (NCP y NDP de Ajuste) 
	en el array aCfg.
	Se utilizan en la función MontaCfgNf() del fuente LOCXNF
	@type  Function
	@author Alfredo Medrano
	@since 26/08/2022
	@version version
	@param nTipo, Númerico, indica el tipo de documento (NCP y NDP de Ajuste).
	@param aAtualiza, Array, Contiene los permisos para realizar acciones en el Formulario.
	@param aLpC, Array, Asientos Estandar Encabezado.
	@param aLpI, Array, Asientos Estandar Item.
	@param aBotoes, Array, Botones de pantalla.
	@param aTeclas, Array,Funciones llamadas por atajos (Tecla ejemplo: F6)
	@param aPergs, Array, Preguntas.
	@param aPE, Array, Puntos de entrada.
	@param bF12, Bloque de código, Funciones llamadas por atajos (Tecla ejemplo: F12)
	@param aCposGD, Nil , Nil
	@param aPcoLanc, Array, Funciones PCO
	@return aEstrcCol, Array, Array con estructura del documento.
	@example
	(examples)
	@see (links_or_references)
	/*/
Function lxEstrcCol(nTipo,aAtualiza, aLpC,aLpI,aBotoes,aTeclas,aPergs, aPE,bF12,aCposGD,aPcoLanc)
Local aEstrcCol := {}

If nTipo == 22 // Nota Ajuste NCP
	aEstrcCol := {22,"SA2",.F.,"SF2","SD2","-","SE2",GetSESNew("NCP")	,"-","D",aAtualiza	,aLpC	,aLpI,aBotoes,aTeclas,AClone(aPergs)	,aClone(aPE),.F.,STR0028,STR0028 + ' - ' + STR0030 ,.F.,bF12,aCposGD,{.F.,.F.},"22", NIL, aPcoLanc} //"Nota de Crédito"//"Nota Ajuste"
ElseIf nTipo == 23 // Nota Ajuste NDP	
	aEstrcCol := {23,"SA2",.F.,"SF1","SD1","+","SE2",GetSESNew("NDP")  	,"+","C",aAtualiza	,aLpC	,aLpI,aBotoes,aTeclas,AClone(aPergs)	,aClone(aPE),.F.,STR0029,STR0029 + ' - ' + STR0030 ,.F.,bF12,aCposGD,{.F.,.F.},"23", NIL, aPcoLanc}//"Nota de Débito"//"Nota Ajuste"
EndIf
Return aEstrcCol


/*/{Protheus.doc} lxModDocSp
	Actualiza el tipo de Operación para Docto Soporte y Nota Ajuste (NCP y NDP)
	Se utiliza en la funcíon GravaCabNF() del fuente LOCXNF. 
	@type  Function
	@author user
	@since 31/08/2022
	@version version
	@param cAlsDc, Caracter, Contiene el Alias de la tabla.
	@param lDocSp, Lógico, indica si es un Docto. Soporte.
	@param nTipoDoc, Númerico, indica el tipo de documento (NCP y NDP de Ajuste).
	@return .T.
	@example
	(examples)
	@see (links_or_references)
	/*/
Function lxModDocSp(cAlsDc, lDocSp,nTipoDoc)
	Local cTpEst := ""
	
	If cAlsDc == 'SF1'
		If (SF1->(ColumnPos("F1_SOPORT")) > 0 .AND. lDocSp) .OR. (SF1->(ColumnPos("F1_MARK")) > 0 .AND. nTipoDoc == 23) // Documento Soporte //Nota ajuste NDP
			If lDocSp
				SF1->F1_SOPORT  := "S"
			ElseIf nTipoDoc == 23
				SF1->F1_MARK  := "S"
			Endif
			cTpEst := Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_EST")
			SF1->F1_TIPOPE := IIF(AllTrim(cTpEst) != "EX", "10","11") //Customization ID 	
		EndIf
	ElseIf cAlsDc == 'SF2'
		If SF2->(ColumnPos("F2_MARK")) > 0 .AND. nTipoDoc == 22
			SF2->F2_MARK  := "S"
			cTpEst := Posicione("SA2",1,xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A2_EST")
			SF2->F2_TIPOPE := IIF(AllTrim(cTpEst) != "EX", "10","11") //Customization ID 
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} lxVlDcTrns
	Para NCP de ajuste, cuando es seleccionada la opción "Doc Orig" 
	valida que el Docto Soporte(SF1) seleccionado se encuentre transmitido. 
	Se utiliza en la funcíon F4NfOri() del fuente SIGACUS
	@type  Function
	@author Alfredo Medrano
	@since 02/09/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function lxVlDcTrns(cDoc, cSerie, cFornece, cLoja)
	Local aArea := GetArea()
	Local lRet := .T.

	DbSelectArea('SF1')
	SF1->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF1->(MSSEEK(xFilial("SF1") + cDoc + cSerie + cFornece +cLoja ))
		If (Empty(SF1->F1_FLFTEX) .Or. SF1->F1_FLFTEX == "0") .Or. Empty(SF1->F1_UUID)
			MsgAlert(StrTran(STR0031, '###', AllTrim(SF1->F1_SERIE) + " " +  AllTrim(SF1->F1_DOC))) //"El documento seleccionado (###), no ha sido transmitido. Realice la transmisión e intente nuevamente."
			lRet := .F.
		EndIf
	EndIf
	RestArea(aArea)
Return lRet
/*/{Protheus.doc} lxVlTitulo
	Obtiene el “Título” de Docto Soporte, Nota de Ajuste de Crédito o Débito 
	que será mostrado en el encabezado del Formulario.
	Se utiliza en la funcíon LocxDlgNF() del fuente LOCXNF
	@type  Function
	@author Alfredo Medrano
	@since 05/09/2022
	@version version
	@param lDcSopr, Lógico, Indica si es un Documento Soporte.
	@param nTipDcS, Número, tipo de documento. 22 =NCP, 23= NDP
	@param cTxTCadas, Carácter, Contiene el título del Formulario.
	@return cTitForm, Carácter, Título del Formulario
	@example
	(examples)
	@see (links_or_references)
	/*/
Function lxVlTitulo(lDcSopr, nTipDcS, cTxTCadas )
Local cTitForm := ""
Default nTipDcS := 0
Default lDocSp:= .F.
Default cTxTCadas := ""
	cTitForm := cTxTCadas
	If lDcSopr
		 cTitForm := cTxTCadas +" - " + STR0027 // Documento Soporte
	ElseIf nTipDcS == 22  
	 	 cTitForm := STR0028 +" - " + STR0030 //"Nota de Crédito" +" - Nota Ajuste"
	ElseIf nTipDcS == 23
		 cTitForm := STR0029 + " - " + STR0030 //"Nota de Débito" +" - Nota Ajuste"
	EndIf 
Return cTitForm


/*/{Protheus.doc} lxObtnFltr
	Agrega Filtro para NCP y NDP de ajuste cuando es seleccionada
	la opción "Factura". 
	Se utiliza en la función LxN466ForF6 del fuente Locxnf2
	Se utiliza en la funcíon F4NfOri() del fuente SIGACUS
	@type  Function
	@author user
	@since 05/09/2022
	@version version
	@param nTpDocS, Número, tipo de documento. 22 =NCP, 23= NDP
	@param lEsQry, Lógico, Indica si el filtro es una instrucción ADVPL o SQL
	@return cFiltro, Carácter, instrucción ADVPL o SQL
	@example
	(examples)
	@see (links_or_references)
	/*/
Function lxObtnFltr(nTpDocS, lEsQry)
	Local lCpsExs   :=  SF1->(ColumnPos("F1_SOPORT ")) > 0 .AND. SF1->(ColumnPos("F1_MARK")) > 0
	Local cQry		:= ""
	Local cCond		:= ""
	Local cFiltro   := ""
	Default lEsQry := .T. 
	Default nTpDocS := 0 

	If lCpsExs 
		If nTpDocS == 22 .or. nTpDocS == 23 // Nota Ajuste 22 =NCP, 23= NDP 
			cQry := "	AND SF1.F1_SOPORT = 'S'"
			cCond := "  .AND. F1_SOPORT == 'S'"
		Else 
			cQry := "	AND SF1.F1_SOPORT <> 'S' AND SF1.F1_MARK <> 'S'" 
			cCond := "  .AND. F1_SOPORT <> 'S' .AND. F1_MARK <> 'S'"
		EndIf	
	EndIf
	cFiltro :=  IIf(lEsQry,cQry, cCond)


Return cFiltro


/*/{Protheus.doc} lxChckLock
	Para NCP y NDP de ajuste cuando es seleccionada la opción "Factura" 
	valida que el Docto Soporte(SF1) seleccionado se encuentre transmitido. 
	Se Utiliza en la funcion LockClick() del fuente LOCXGEN.
	@type  Function
	@author Alfredo Medrano
	@since 06/09/2022
	@version version
	@param cAlias, Carácter, Alias de la tabla.
	@param nReg, Número, Número de registro seleccionado 
	@param aLinha, Array, Array con las lineas del grid
	@param oLbCli, Objeto, Objeto del grid
	@param cTipoFE, Carácter, Tipo de Validación Electronica  1 = Val. Previa 
	@param nMarca, Número, indica si la casilla esta marcada > 0 o desmarcada = -1
	@return nMarca, Número,  Marcado > 0  Desmarcado = -1
	@example
	(examples)
	@see (links_or_references)
	/*/
Function lxChckLock(cAlias,nReg,aLinha,oLbCli,cTipoFE,nMarca)

If !Empty(SF1->F1_UUID) .And. (SF1->F1_FLFTEX == "1" .Or. (cTipoFE == "1" .And. SF1->F1_FLFTEX == "6"))
		If aLinha[oLBCli:nAT,1] == 1 //Retira Lock
			MsRUnlock(&(cAlias)->(nReg))
		Else
			If MsRLock(&(cAlias)->(nReg))
				nMarca := 1
			Else
				Help(" ", 1, "USUNAUTO")
			EndIf
		EndIf
	Else		
		If aLinha[oLBCli:nAT,1] == 1 //Retira lock
			MsRUnlock(&(cAlias)->(nReg))
		EndIf
		MsgAlert(STR0026) //"El documento seleccionado no ha sido transmitido. Realice la transmisión e intente nuevamente."
	EndIf

	
Return nMarca
