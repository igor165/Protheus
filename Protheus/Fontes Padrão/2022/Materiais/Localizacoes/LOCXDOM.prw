#include 'protheus.ch'
#include 'parmtype.ch'
#include 'LOCXDOM.ch'

#Define SAliasHead  4
#Define ScEspecie   8

/*/{Protheus.doc} LxTpComFis
Valores para combo de Tipo de Comprobante Fiscale para los campos FP_TPDOC y F2_TPDOC.
@type
@author luis.enriquez
@since 04/02/2021
@version 1.0
@return cCombo, Tipos de Comprobantes Fiscales
@example
LxTpComFis() 
@see (links_or_references)
/*/
Function LxTpComFis()
	Local cCombo	:= ""
	Local cFunName	:= FunName()
	Local nI        := 0
	Local nTam      := 0
	Local aCbxTpo   := {STR0002,; //"01=Factura de Crédito Fiscal"
	                    STR0003,; //"02=Factura de Consumo"
						STR0004,; //"03=Notas de Débito"
						STR0005,; //"04=Notas de Crédito"
						STR0006,; //"11=Comprobante de Compras"
						STR0007,; //"12=Registro Único de Ingresos"
						STR0008,; //"13=Registro de Gastos Menores"
						STR0009,; //"14=Regímenes Especiales de Tributación"
						STR0010,; //"15=Comprobantes Gubernamentales"
						STR0011,; //"16=Comprobante para Exportaciones"
						STR0012}  //"17=Comprobante para Pagos al Exterior"
	nTam := Len(aCbxTpo)					
	For nI := 1 to nTam
		If cFunName == "MATA467N" .And. (nI == 3 .Or. nI == 4)
			Loop
		EndIf
		cCombo += aCbxTpo[nI] + IIf(nI <>nTam,";","")
	Next nI
Return cCombo

/*/{Protheus.doc} fCposF2Dom
Permite agregar campos a notas fiscales para el país República Dominicana.
@type
@author luis.enriquez
@since 09/02/2021
@version 1.0
@param cF2Especie, caracter, Especie del Documento
@param/return aCposNF, array, FArreglo con propiedades de los campos a mostrar en la nota fiscal
@return cFunName, Rutina que ejecuta el llamado a la función.
@example
LxTpComFis() 
@see (links_or_references)
/*/
Function fCposF2Dom(aCposNF, cFunName)
	Local aSX3 := {}
	Local cVld := ""
	If SF2->(ColumnPos( "F2_TPDOC" )) > 0
		If aCfgNf[SAliasHead] == "SF2" .And. cFunName $ "MATA467N|MATA465N" .And. (nNFTipo == 1 .Or. nNFTipo == 2)
			aSX3 := LxDOMSX3("F2_TPDOC")
			AAdd(aCposNF,{FWX3Titulo("F2_TPDOC"),"F2_TPDOC",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
		EndIf
	EndIf
	If SF2->(ColumnPos( "F2_NCF" )) > 0 .And. Trim(aCfgNf[ScEspecie]) $ "NF|NCI|NDI|NDC|NCE"
		aSX3 := LxDOMSX3("F2_NCF")
		AAdd(aCposNF,{FWX3Titulo("F2_NCF"),"F2_NCF",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
	EndIf
Return Nil

/*/{Protheus.doc} LxGetTpCom
Obtiene el Tipo de Comprobante Fiscal, a partir del campo Serie (F2_SERIE), Especie (F2_ESPECIE) 
y Num. de Documento (F2_DOC).
@type
@author luis.enriquez
@since 04/02/2021
@version 1.0
@param cSerie, caracter, Serie del Documento
@param cF2Especie, caracter, Especie del Documento
@param cNumDoc, caracter, Folio del Documento
@return cTpComFis, Codigo de Tipo de Comprobante Fiscal
@example
LxGetTpCom(cSerie, cF2Especie, cNumDoc) 
@see (links_or_references)
/*/
Function LxGetTpCom(cSerie, cF2Especie, cNumDoc)
	Local cTpComFis		:= ""
	Local cFPEspecie	:= ""
	Local cFilSFP		:= xFilial("SFP")
	Local cNumIni		:= ""
	Local cNumFim		:= ""
	
	Default cSerie		:= ""
	Default cF2Especie	:= "NF"
	Default cNumDoc		:= ""
	
	cF2Especie := AllTrim(cF2Especie)

	If cF2Especie $ "NF|NDI|NDC|NCI|NCC"
		Do Case
			Case cF2Especie == "NF"
				cFPEspecie := "01|02|12|14"
			Case cF2Especie == "NDI" .OR. cF2Especie == "NDC"
				cFPEspecie := "03"
			Case cF2Especie == "NCI" .OR. cF2Especie == "NCC"
				cFPEspecie := "04"
		EndCase
		
		dbSelectArea("SFP")
		SFP->(dbSetOrder(1)) //FP_FILIAL + FP_FILUSO + FP_SERIE + FP_CAI + FP_ESPECIE
		If SFP->(MsSeek(cFilSFP + cFilAnt + cSerie))
			While SFP->(FP_FILIAL + FP_FILUSO + FP_SERIE) == cFilSFP + cFilAnt + cSerie
				If SFP->FP_ATIVO == "1" .AND. dDataBase <= SFP->FP_DTAVAL
					cNumIni := SFP->FP_NUMINI
					cNumFim := SFP->FP_NUMFIM
					If AllTrim(SFP->FP_ESPECIE) $ cFPEspecie
						If Val(SFP->FP_NUMINI) <= Val(cNumDoc) .And. Val(cNumDoc) <= Val(SFP->FP_NUMFIM)
							cTpComFis := SFP->FP_TPDOC
							Exit
						EndIf
					EndIf
				EndIf
				SFP->(DbSkip())
			EndDo
		Else
			MsgInfo(StrTran(STR0001, '###', Alltrim(cSerie))) //"La Serie ### no se encuentra registrada en el Control de Planillas."
		EndIf
	EndIf
Return cTpComFis

/*/{Protheus.doc} LxDOMSX3
Función para obtener datos del SX3 para campos usando la función GetSX3Cache
@type
@author luis.enriquez
@since 09/02/2021
@version 1.0
@param cCampo, caracter, Nombre del campo.
@return aSX3Cpos, array, Arreglo con contenido de la tabla SX3 para el campo.
@see (links_or_references)
/*/
Function LxDOMSX3(cCampo)
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
