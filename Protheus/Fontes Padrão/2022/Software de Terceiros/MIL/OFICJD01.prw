// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 10     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH" 
#Include "OFICJD01.CH"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFICJD01   | Autor |  Takahashi            | Data | 30/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Consulta Informacoes de Garantia de um Chassi (JD)           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora John Deere                  |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFICJD01(lNoMBrowse,nOpcAux,aRetorno)

	Local bBlock
	Local cFilterDafault

	Default lNoMBrowse := .f.

	Private cCadastro := STR0001
	Private aRotina := MenuDef()

	Private cVV1Mostra := "VV1_CHASSI/VV1_CHAINT/VV1_MODVEI/VV1_DESMOD/VV1_FABMOD/VV1_DATVEN/VV1_DTUVEN/VV1_PROATU/VV1_LJPATU/VV1_NOMPRO/VV1_DATETG"

	Private lMark := lNoMBrowse

	If !AMIIn(14)
		Return
	EndIf

	dbSelectArea("VV1")
	If lNoMBrowse
		If ( nOpcAux <> 0 ) .And. !Deleted()
			bBlock := &( "{ |a,b,c,d| " + aRotina[ nOpcAux,2 ] + "(a,b,c,d) }" )
			Eval( bBlock, Alias(), (Alias())->(Recno()),nOpcAux,@aRetorno)
		EndIf
	Else
		oBrwOCJD01 := FWMBrowse():New()
		oBrwOCJD01:SetAlias("VV1")
		oBrwOCJD01:SetDescription(cCadastro)
		oBrwOCJD01:SetFilterDefault("@ VV1_CODMAR IN ('" + FMX_RETMAR("JD ") + "','" + FMX_RETMAR("GRS") + "','" + FMX_RETMAR("PLA") + "','" + FMX_RETMAR("JDC") + "','" + FMX_RETMAR("HCM") + "')")
		oBrwOCJD01:Activate()
	EndIf
	//

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFCJDCO1   | Autor |  Takahashi            | Data | 30/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Consulta Informacoes de Garantia de um Chassi                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora John Deere                  |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFCJDCO1(cAlias,nReg,nOpc,aRetorno)

Local oSizePrinc
Local oSizeInf
Local oSizeLBox
Local oSizeEquip
Local oSizeGar
Local aCpoEnchoice
Local nCont

Local aFieldRegistro := {}
Local aCpoRegistro := {}

Local aInfStatus := {}
Local oInfStatus := NIL

Local aInfUsado := {}
Local oInfUsado := NIL

Local aGarHeader := {}
Local oGarHeader := NIL

Local aGarDetails := {{"","","",""}}
Local oGarDetails := NIL

Local oWS // Instancia da Classe de WebService da John Deere

Private aAuxGarDet := {}	// contera todos detalhes de garantia
Private lProcessado := .f.

VV1->(dbGoTo(nReg))

// Consulta Informacoes de Garantia do Chassi no WebService da John Deere
oWS := WSJohnDeere_Garantia():New("RetrieveWarrantyInfo")

/*
if !lMark
	oWS:SetDebug()
End
*/

oWS:oRetrieveWarInfo_INPUT:cPin := AllTrim(VV1->VV1_CHASSI)
MsgRun(STR0005,STR0006,{|| lProcessado := oWS:RetrieveWarrantyInfo() }) // "Consultando registro de garantia"
If !lProcessado
	oWS:ExibeErro()
	Return
EndIf
//
If oWS:oOUTPUT:oSUCCESS:cTYPE $ "E/X"
	MsgInfo(STR0007 + oWS:oOUTPUT:oSUCCESS:cTYPE + " - " + oWS:oOUTPUT:oSUCCESS:cRESDESC ) // "Erro: "
	Return
EndIf

If Len(oWS:oOUTPUT:oE_MACHINESTATUS) == 0
	aInfStatus := { {"",""} }
Else
	For nCont := 1 to Len(oWS:oOUTPUT:oE_MACHINESTATUS)
		AADD(aInfStatus, { oWS:oOUTPUT:oE_MACHINESTATUS[nCont]:cMACHINESTATUS ,;
							oWS:oOUTPUT:oE_MACHINESTATUS[nCont]:cMACHINESTATUS_DESC } )
	Next nCont
EndIf

If Len(oWS:oOUTPUT:oE_AMOUNT_OF_USE) == 0
	aInfUsado := { {CtoD(" ") , "" , "" , "" } }
Else
	For nCont := 1 to Len(oWS:oOUTPUT:oE_AMOUNT_OF_USE)
		AADD(aInfUsado, { oWS:oOUTPUT:oE_AMOUNT_OF_USE[nCont]:dREADINGDATE ,;
							oWS:oOUTPUT:oE_AMOUNT_OF_USE[nCont]:cUOM ,;
							oWS:oOUTPUT:oE_AMOUNT_OF_USE[nCont]:cUOM_DESC ,;
							oWS:oOUTPUT:oE_AMOUNT_OF_USE[nCont]:cAMOUNTOFUSE } )
	Next nCont
EndIf

If Len(oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER) == 0
	AADD(aGarHeader, { "","","",CtoD(" "),CtoD(" "),CtoD(" "),0 } )
Else
	For nCont := 1 to Len(oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER)
		AADD(aGarHeader, {;
			oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nCont]:cWARRANTY_TYPE   ,;
			oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nCont]:cWARRANTY_TYPE_DESC   ,;
			oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nCont]:cWARRANTY_NUMBER ,;
			oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nCont]:dASSIGNDATE      ,;
			oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nCont]:dSTARTDATE       ,;
			oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nCont]:dEXPIREDATE      ,;
			oWS:oOUTPUT:oE_WARRANTY_DATA_HEADER[nCont]:nDEDUCTIBLE      ;
			})

	Next nCont
EndIf

If Len(oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS) == 0
	AADD(aAuxGarDet, { "","","","" } )
Else
	For nCont := 1 to Len(oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS)
		AADD(aAuxGarDet, {;
			oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS[nCont]:cWARRANTY_TYPE   ,;
			oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS[nCont]:cWARRANTY_TYPE_DESC   ,;
			oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS[nCont]:cLIMIT_TYPE_DESC ,;
			oWS:oOUTPUT:oE_WARRANTY_DATA_DETAILS[nCont]:cLIMIT_VALUE     ;
			})
	Next nCont
EndIF

// Calculo da Janela Principal
oSizePrinc := FwDefSize():New(.t.)

oSizePrinc:AddObject("GETDADOSVV1", 100 , 090 , .T. , .F. )
oSizePrinc:AddObject("INFORMACOES", 100 , 100 , .T. , .T. )

oSizePrinc:aMargins := { 3 , 0 , 3 , 3 }

oSizePrinc:Process()	// Calcula Coordenadas

// Calculo da Area de Informacoes
oSizeInf := FwDefSize():New(.f.)

oSizeInf:aWorkArea := oSizePrinc:GetNextCallArea("INFORMACOES")

oSizeInf:AddObject("REGISTRO",IIf(GetNewPar("MV_ENCHOLD","2") == "2",080,110),100,.F.,.T.)
oSizeInf:AddObject("LISTBOX",100,100,.T.,.T.)

oSizeInf:lProp := .t. 		// Mantem proporcao entre objetos redimensionaveis
oSizeInf:lLateral := .t.	// Calcula em colunas

oSizeInf:Process()	// Calcula Coordenadas

// Calculo da Area de Listbox
oSizeLBox := FwDefSize():New(.f.)

oSizeLBox:aWorkArea := oSizeInf:GetNextCallArea("LISTBOX")

oSizeLBox:AddObject("EQUIPAMENTO",100,040,.T.,.T.)
oSizeLBox:AddObject("GARANTIA"   ,100,060,.T.,.T.)

oSizeLBox:aMargins := { 3 , 3 , 0 , 0 }

oSizeLBox:lProp := .t. 		// Mantem proporcao entre objetos redimensionaveis
oSizeLBox:Process()	// Calcula Coordenadas

// Calculo da Area de Informacoes de Equipamento
oSizeEquip := FwDefSize():New(.f.)

oSizeEquip:aWorkArea := oSizeLBox:GetNextCallArea("EQUIPAMENTO")

oSizeEquip:aMargins := { 3 , 0 , 0 , 0 }

oSizeEquip:AddObject("STATUS",60,100,.T.,.T.)
oSizeEquip:AddObject("USADO" ,40,100,.T.,.T.)

oSizeEquip:lProp := .t. 		// Mantem proporcao entre objetos redimensionaveis
oSizeEquip:lLateral := .t.	// Calcula em colunas

oSizeEquip:Process()	// Calcula Coordenadas

// Calculo da Area de Garantia
oSizeGar := FwDefSize():New(.f.)

oSizeGar:aWorkArea := oSizeLBox:GetNextCallArea("GARANTIA")

oSizeGar:aMargins := { 3 , 0 , 0 , 0 }

oSizeGar:AddObject("HEADER" ,70,100,.T.,.T.)
oSizeGar:AddObject("DETAIL" ,30,100,.T.,.T.)

oSizeGar:lProp := .t. 		// Mantem proporcao entre objetos redimensionaveis
oSizeGar:lLateral := .t.		// Calcula em colunas

oSizeGar:Process()	// Calcula Coordenadas
//

// Cria matriz aFieldRegistro para ser utilizada na getdados de Registro (Sem SX3)
/* Estrutura do vetor aFieldRegistro
	[01] - Titulo           [11] - F3
	[02] - campo            [12] - when
	[03] - Tipo	            [13] - visual
	[04] - Tamanh           [14] - chave
	[05] - Decima           [15] - box
	[06] - Pictur           [16] - folder
	[07] - Valid            [17] - nao alteravel
	[08] - Obriga           [18] - pictvar
	[09] - Nivel            [19] - gatilho
	[10] - Inicial. Padrão
*/
//oWS:oOUTPUT:oWARINFO:cDEALERACCOUNT
M->DEALLERACCOUNT	:= oWS:oOUTPUT:oWARINFO:cDEALERACCOUNT
M->MODEL				:= oWS:oOUTPUT:oWARINFO:cMODEL
M->DELIVERYDATE	:= oWS:oOUTPUT:oWARINFO:dDELIVERYDATE
M->RECEIVEDATE		:= oWS:oOUTPUT:oWARINFO:dRECEIVEDATE
Aadd(aFieldRegistro, {STR0008 , "DEALLERACCOUNT", "C", 6, 0, "@!", "", .F., 1, "", "", "", .T., .F., "", /* Folder */, .T., "", "N"}) // "Concessionário"
Aadd(aFieldRegistro, {STR0009 , "MODEL"			, "C", 6, 0, "@!", "", .F., 1, "", "", "", .T., .F., "", /* Folder */, .T., "", "N"}) // "Modelo"
Aadd(aFieldRegistro, {STR0010 , "DELIVERYDATE"	, "D", 8, 0, "@!", "", .F., 1, "", "", "", .T., .F., "", /* Folder */, .T., "", "N"}) // "Dt. Entrega"
Aadd(aFieldRegistro, {STR0011 , "RECEIVEDATE" 	, "D", 8, 0, "@!", "", .F., 1, "", "", "", .T., .F., "", /* Folder */, .T., "", "N"}) // "Dt. Recebimento"
aEval(aFieldRegistro,{ |x| AADD( aCpoRegistro , x[2] ) })

OCJD01015_GravaDataEntrega(M->DELIVERYDATE)

aCpoEnchoice := {}
SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == cAlias
	If X3USO(SX3->X3_USADO).and.cNivel>=SX3->X3_NIVEL .and. (Alltrim(SX3->X3_CAMPO) $ cVV1Mostra)
		AADD(aCpoEnchoice,SX3->X3_CAMPO)
	EndIf
	If SX3->X3_CONTEXT == "V"
		&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
	Else
		&("M->"+SX3->X3_CAMPO):= &("VV1->"+SX3->X3_CAMPO)
	EndIf
	SX3->(DbSkip())
Enddo


DEFINE MSDIALOG oDlgConGar TITLE STR0001 OF oMainWnd PIXEL;
	FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

oEnchVV1 := MSMGet():New("VV1",nReg, 2 /* Visualizar */ ,;
	/* aCRA */, /* cLetra*/, /* cTexto */, aCpoEnchoice, ;
	oSizePrinc:GetObjectArea("GETDADOSVV1"), ;
	aCpoEnchoice, 3 /* nModelo */ ,;
	/* nColMens */, /* cMensagem */, "AllwaysTrue()", oDlgConGar , .f. /* lF3 */ , .t. /* lMemoria */ , .F. /* lColumn */ ,;
	/* caTela */ , .t. /* lNoFolder */, .f. /* lProperty */ )

TGroup():New( oSizeInf:GetDimension("REGISTRO","LININI") , oSizeInf:GetDimension("REGISTRO","COLINI") , oSizeInf:GetDimension("REGISTRO","LINEND") , oSizeInf:GetDimension("REGISTRO","COLEND") , STR0012 , oDlgConGar ,,,.t., ) // "Registro"

oEnchRegistro := MsmGet():New(,,2 /* Visualizar */,;
	/*aCRA*/,/*cLetras*/,/*cTexto*/,aCpoRegistro,;
	{ oSizeInf:GetDimension("REGISTRO","LININI") + 8, oSizeInf:GetDimension("REGISTRO","COLINI") + 2, oSizeInf:GetDimension("REGISTRO","LINEND") - 2, oSizeInf:GetDimension("REGISTRO","COLEND") - 2 },;
	aCpoRegistro, 3 /*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlgConGar , .f. /*lF3*/, .t. /* lMemoria */ , .t. /*lColumn*/,;
	/*caTela*/, .t. /*lNoFolder*/, .f. /*lProperty*/,;
	aFieldRegistro, /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)

TGroup():New( oSizeEquip:GetDimension("STATUS","LININI") , oSizeEquip:GetDimension("STATUS","COLINI") , oSizeEquip:GetDimension("STATUS","LINEND") , oSizeEquip:GetDimension("STATUS","COLEND") , STR0013 , oDlgConGar ,,,.t., ) // "Status do Equipamento"
oInfStatus := TWBrowse():New( oSizeEquip:GetDimension("STATUS","LININI") + 8, ;
								oSizeEquip:GetDimension("STATUS","COLINI") + 2,;
								oSizeEquip:GetDimension("STATUS","XSIZE") -4 ,;
								oSizeEquip:GetDimension("STATUS","YSIZE") -10,,,,oDlgConGar,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oInfStatus:AddColumn( TCColumn():New( STR0014 , { || aInfStatus[oInfStatus:nAT,1] } ,,,,"LEFT"  ,30,.F.,.F.,,,,.F.,) ) // "CÓDIGO"
oInfStatus:AddColumn( TCColumn():New( STR0015 , { || aInfStatus[oInfStatus:nAT,2] } ,,,,"LEFT"  ,30,.F.,.F.,,,,.F.,) ) // "DESCRIÇÃO"
oInfStatus:nAt := 1
oInfStatus:SetArray(aInfStatus)
oInfStatus:Refresh()

TGroup():New( oSizeEquip:GetDimension("USADO","LININI") , oSizeEquip:GetDimension("USADO","COLINI") , oSizeEquip:GetDimension("USADO","LINEND") , oSizeEquip:GetDimension("USADO","COLEND") , "Montante Usado do Equipamento" , oDlgConGar ,,,.t., )
oInfUsado := TWBrowse():New( oSizeEquip:GetDimension("USADO","LININI") + 8, ;
							oSizeEquip:GetDimension("USADO","COLINI") + 2,;
							oSizeEquip:GetDimension("USADO","XSIZE") - 4 ,;
							oSizeEquip:GetDimension("USADO","YSIZE") - 10,,,,oDlgConGar,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oInfUsado:AddColumn( TCColumn():New( STR0016 , { || aInfUsado[oInfUsado:nAT,1] } ,,,,"LEFT" ,35,.F.,.F.,,,,.F.,) ) // "DATA"
oInfUsado:AddColumn( TCColumn():New( STR0017 , { || aInfUsado[oInfUsado:nAT,3] } ,,,,"LEFT" ,50,.F.,.F.,,,,.F.,) ) // "UN. MEDIDA"
oInfUsado:AddColumn( TCColumn():New( STR0018 , { || aInfUsado[oInfUsado:nAT,4] } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // "VALOR"
oInfUsado:nAt := 1
oInfUsado:SetArray(aInfUsado)
oInfUsado:Refresh()

TGroup():New( oSizeGar:GetDimension("DETAIL","LININI") , oSizeGar:GetDimension("DETAIL","COLINI") , oSizeGar:GetDimension("DETAIL","LINEND") , oSizeGar:GetDimension("DETAIL","COLEND") , "Limite da Garantia" , oDlgConGar ,,,.t., )
oGarDetails := TWBrowse():New( oSizeGar:GetDimension("DETAIL","LININI")  + 08,;
								oSizeGar:GetDimension("DETAIL","COLINI") + 02,;
								oSizeGar:GetDimension("DETAIL","XSIZE")  - 04,;
								oSizeGar:GetDimension("DETAIL","YSIZE")  - 10,,,,oDlgConGar,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oGarDetails:AddColumn( TCColumn():New( STR0019 , { || aGarDetails[oGarDetails:nAT,1] } ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) // "TIPO"
oGarDetails:AddColumn( TCColumn():New( STR0017 , { || aGarDetails[oGarDetails:nAT,3] } ,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) ) // "UN. MEDIDA"
oGarDetails:AddColumn( TCColumn():New( STR0018 , { || aGarDetails[oGarDetails:nAT,4] } ,,,,"LEFT" ,50,.F.,.F.,,,,.F.,) ) // "VALOR"
oGarDetails:nAt := 1
oGarDetails:SetArray(aGarDetails)
//oGarDetails:Refresh()


TGroup():New( oSizeGar:GetDimension("HEADER","LININI") , oSizeGar:GetDimension("HEADER","COLINI") , oSizeGar:GetDimension("HEADER","LINEND") , oSizeGar:GetDimension("HEADER","COLEND") , "Garantia" , oDlgConGar ,,,.t., )
oGarHeader := TWBrowse():New( oSizeGar:GetDimension("HEADER","LININI")   + 08 ,;
								oSizeGar:GetDimension("HEADER","COLINI") + 02 ,;
								oSizeGar:GetDimension("HEADER","XSIZE")  - 04 ,;
								oSizeGar:GetDimension("HEADER","YSIZE")  - 10 ,,,,oDlgConGar,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oGarHeader:AddColumn( TCColumn():New( STR0019 , { || aGarHeader[oGarHeader:nAT,1] } ,,,,"LEFT"  ,20,.F.,.F.,,,,.F.,) ) // "TIPO"
oGarHeader:AddColumn( TCColumn():New( STR0015 , { || aGarHeader[oGarHeader:nAT,2] } ,,,,"LEFT"  ,80,.F.,.F.,,,,.F.,) ) // "DESCRIÇÃO"
oGarHeader:AddColumn( TCColumn():New( STR0021 , { || aGarHeader[oGarHeader:nAT,4] } ,,,,"LEFT"  ,35,.F.,.F.,,,,.F.,) ) // "ATRIBUIÇÃO"
oGarHeader:AddColumn( TCColumn():New( STR0022 , { || aGarHeader[oGarHeader:nAT,5] } ,,,,"LEFT"  ,35,.F.,.F.,,,,.F.,) ) // "INICIO"
oGarHeader:AddColumn( TCColumn():New( STR0023 , { || aGarHeader[oGarHeader:nAT,6] } ,,,,"LEFT"  ,35,.F.,.F.,,,,.F.,) ) // "FIM"
oGarHeader:AddColumn( TCColumn():New( STR0024 , { || Transform(aGarHeader[oGarHeader:nAT,7],"@E 9,999,999.99") } ,,,,"RIGHT" ,50,.F.,.F.,,,,.F.,) ) // "VL. DEDUTIVEL"
oGarHeader:nAt := 1
oGarHeader:SetArray(aGarHeader)
oGarHeader:bChange := { || OFCJDDET1 ( aGarHeader[oGarHeader:nAT,1] , @aGarDetails ) , oGarDetails:nAt := 1 , oGarDetails:SetArray(aGarDetails), oGarDetails:Refresh() }
oGarHeader:Refresh()

oWS := NIL

ACTIVATE MSDIALOG oDlgConGar ON INIT EnchoiceBar(oDlgConGar,{||oDlgConGar:End()},{||oDlgConGar:End()})

Return


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFCJDDET1  | Autor | Takahashi             | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Atualiza Listbox de Detalhe de Garantia                      |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OFCJDDET1( cTipo , aGarDetails )

Local nCont

aGarDetails := {}

For nCont := 1 to Len(aAuxGarDet)
	If aAuxGarDet[nCont,1] == cTipo
		AADD( aGarDetails , aClone(aAuxGarDet[nCont]) )
	EndIf
Next nCont

Return



/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFCJDCO2   | Autor |  Takahashi            | Data | 30/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Consulta Plano de Revisão / Campanha de um Chassi            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina integração com Montadora John Deere                  |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFCJDCO2(cAlias,nReg,nOpc,aRetorno)

Local nCont
Local lOk := .f.

Local oSizePrinc
Local oSizeLBox
Local oSizeDet1
Local oSizeDet2
Local oSizeContr

Local oWS // Instancia da Classe de WebService da John Deere

Local aCpoEnchoice

Local aRevisao := {}
Local aPecas := {}
Local aSrvc := {}
Local aOutros := {}

Local aPMPKit := {}
Local aPMPSrvc := {}

Local aTpMaq := {}

Private oPecas
Private oSrvc
Private oOutros
Private oKit

Private aAuxRevisao := {}
Private aAuxPecas := {}
Private aAuxSrvc := {}
Private aAuxOutros := {}

Private aPMP := {}
Private aAuxPMPItem := {}

Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

Private lProcessado := .f.

VV1->(dbGoTo(nReg))

// Consulta Informacoes de Garantia do Chassi no WebService da John Deere
oWS := WSJohnDeere_Garantia():New("RetrieveOpenPIPsMCD")

/*
If !lMark
	oWS:SetDebug()
End
*/

oWS:oRetrieveOpenPIPsMCD_INPUT:cPin := AllTrim(VV1->VV1_CHASSI)
MsgRun(STR0025,STR0006 ,{|| lProcessado := oWS:RetrieveOpenPIPsMCD() }) // "Consultando revisões"
If !lProcessado
	oWS:ExibeErro()
	oWS := NIL
	Return
EndIf
//

If oWS:oOUTPUT:oSUCCESS:cType <> "S"
	MsgInfo(STR0055 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
				STR0014 + ": " + AllTrim(Str(oWS:oOUTPUT:oSUCCESS:nRESCODE)) + chr(13) + chr(10) + ;
				STR0015 + ": " + AllTrim(oWS:oOUTPUT:oSUCCESS:cRESDESC),STR0056) // "Problema ao processar consulta"
	If oWS:oOUTPUT:oSUCCESS:cType == "X"
		oWS := NIL
		Return
	EndIf
EndIf


// Verifica se o PIN é Válido
If oWS:oOUTPUT:oPINNO:nVALID == 0
	MsgStop( STR0026 ) // "PIN inválido"
	oWS := NIL
	Return
EndIf
//

If Len(oWS:oOUTPUT:oPIP) == 0 .and. Len(oWS:oOUTPUT:oCONTRACT) == 0
	MsgStop(STR0027) // "PIN não possui revisão /campanha pendente"
	oWS := NIL
	Return
EndIf

// PMP
If Len(oWS:oOUTPUT:oPIP) == 0
Else
	For nCont := 1 to Len(oWS:oOUTPUT:oPIP)
		AADD( aPMP ,{;
			oWS:oOUTPUT:oPIP[nCont]:cPIPNO,;
			oWS:oOUTPUT:oPIP[nCont]:dEXPIRDT,;
			oWS:oOUTPUT:oPIP[nCont]:cTYPE,;
			oWS:oOUTPUT:oPIP[nCont]:cTYPE_DESC,;
			oWS:oOUTPUT:oPIP[nCont]:cTITLE ,;
			.f. })
	Next nCont

	For nCont := 1 to Len(oWS:oOUTPUT:oBUNDLE)
		AADD( aAuxPMPItem , {;
			oWS:oOUTPUT:oBUNDLE[nCont]:cPIPNO,;
			oWS:oOUTPUT:oBUNDLE[nCont]:cNO,;
			oWS:oOUTPUT:oBUNDLE[nCont]:cKEY,;
			oWS:oOUTPUT:oBUNDLE[nCont]:cLABOR,;
			oWS:oOUTPUT:oBUNDLE[nCont]:cSUBTYPE,;
			oWS:oOUTPUT:oBUNDLE[nCont]:cSUBTYPE_DESC,;
			oWS:oOUTPUT:oBUNDLE[nCont]:nQTY,;
			oWS:oOUTPUT:oBUNDLE[nCont]:cTIPO_REGISTRO ,;
			oWS:oOUTPUT:oBUNDLE[nCont]:cLABOR_DESC })
	Next nCont
EndIf

//
If Len(oWS:oOUTPUT:oCONTRACT) == 0
//	OFCJDDET3 ( "" , "" , @aPecas , @aSrvc , @aOutros )
//	aAuxRevisao := { Array(15) }
//	aFill(aAuxRevisao[1] , "" )
//	aAuxRevisao[1,15] := .f.
Else
	For nCont := 1 to Len(oWS:oOUTPUT:oCONTRACT)

		If aScan( aTpMaq , oWS:oOUTPUT:oCONTRACT[nCont]:cMACHINECD ) == 0
			AADD( aTpMaq , oWS:oOUTPUT:oCONTRACT[nCont]:cMACHINECD )
		EndIf

		AADD( aAuxRevisao ,{;
			oWS:oOUTPUT:oCONTRACT[nCont]:cPLANNAME,;
			oWS:oOUTPUT:oCONTRACT[nCont]:cMACHINECD,;
			oWS:oOUTPUT:oCONTRACT[nCont]:cMATERIAL_MASTER,;
			oWS:oOUTPUT:oCONTRACT[nCont]:dCONTRACT_STARTDATE,;
			oWS:oOUTPUT:oCONTRACT[nCont]:dCONTRACT_ENDDATE,;
			oWS:oOUTPUT:oCONTRACT[nCont]:cCONTRACT_STATUS,;
			oWS:oOUTPUT:oCONTRACT[nCont]:nSERVICENO,;
			oWS:oOUTPUT:oCONTRACT[nCont]:cSERVINTTYPE,;
			oWS:oOUTPUT:oCONTRACT[nCont]:cSERVINTTYPE_DESC,;
			oWS:oOUTPUT:oCONTRACT[nCont]:dINTERVAL_STARTDATE,;
			oWS:oOUTPUT:oCONTRACT[nCont]:dINTERVAL_ENDDATE,;
			oWS:oOUTPUT:oCONTRACT[nCont]:cINTERVAL_STATUS,;
			oWS:oOUTPUT:oCONTRACT[nCont]:cINTERVAL_LIMIT,;
			"",;
			.f. })
	Next nCont

	For nCont := 1 to Len(oWS:oOUTPUT:oREPLACEPART)
		AADD( aAuxPecas, { ;
			oWS:oOUTPUT:oREPLACEPART[nCont]:cPLANNAME,;
			oWS:oOUTPUT:oREPLACEPART[nCont]:cMATERIAL_MASTER,;
			oWS:oOUTPUT:oREPLACEPART[nCont]:nQTY,;
			oWS:oOUTPUT:oREPLACEPART[nCont]:cPARTNO,;
			oWS:oOUTPUT:oREPLACEPART[nCont]:cMACHINECD,;
			oWS:oOUTPUT:oREPLACEPART[nCont]:cSERVINTTYPE})
	Next nCont

	For nCont := 1 to Len(oWS:oOUTPUT:oLABOR)
		AADD( aAuxSrvc , { ;
			oWS:oOUTPUT:oLABOR[nCont]:cPLANNAME,;
			oWS:oOUTPUT:oLABOR[nCont]:cMATERIAL_MASTER,;
			oWS:oOUTPUT:oLABOR[nCont]:cTYPE,;
			oWS:oOUTPUT:oLABOR[nCont]:cTYPE_DESC,;
			oWS:oOUTPUT:oLABOR[nCont]:cSUBTYPE,;
			oWS:oOUTPUT:oLABOR[nCont]:cSUBTYPE_DESC,;
			oWS:oOUTPUT:oLABOR[nCont]:nAMT,;
			oWS:oOUTPUT:oLABOR[nCont]:cMACHINECD,;
			oWS:oOUTPUT:oLABOR[nCont]:cSERVINTTYPE} )
	Next nCont

	For nCont := 1 to Len(oWS:oOUTPUT:oOTHERCREDIT)
		AADD( aAuxOutros , { ;
			oWS:oOUTPUT:oOTHERCREDIT[nCont]:cPLANNAME,;
			oWS:oOUTPUT:oOTHERCREDIT[nCont]:cMATERIAL_MASTER,;
			oWS:oOUTPUT:oOTHERCREDIT[nCont]:nLABOR_MATCOST,;
			oWS:oOUTPUT:oOTHERCREDIT[nCont]:cDESC,;
			oWS:oOUTPUT:oOTHERCREDIT[nCont]:cDESC_DESC,;
			oWS:oOUTPUT:oOTHERCREDIT[nCont]:cMACHINECD,;
			oWS:oOUTPUT:oOTHERCREDIT[nCont]:cSERVINTTYPE,;
			oWS:oOUTPUT:oOTHERCREDIT[nCont]:cSERVINTTYPE_DESC } )
	Next nCont
EndIf
//

aCpoEnchoice := {}
SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == cAlias
	If X3USO(SX3->X3_USADO).and.cNivel>=SX3->X3_NIVEL .and. (Alltrim(SX3->X3_CAMPO) $ cVV1Mostra)
		AADD(aCpoEnchoice,SX3->X3_CAMPO)
	EndIf
	If SX3->X3_CONTEXT == "V"
		&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
	Else
		&("M->"+SX3->X3_CAMPO):= &("VV1->"+SX3->X3_CAMPO)
	EndIf
	SX3->(DbSkip())
Enddo


// Calculo da Janela Principal
oSizePrinc := FwDefSize():New(.t.)

oSizePrinc:AddObject("GETDADOSVV1", 100 , 070 , .T. , .F. )
oSizePrinc:AddObject("INFORMACOES", 100 , 100 , .T. , .T. )

oSizePrinc:aMargins := { 3 , 0 , 3 , 3 }

oSizePrinc:Process()	// Calcula Coordenadas
//

// Calculo da Area de Listbox
oSizeLBox := FwDefSize():New(.f.)

oSizeLBox:aWorkArea := oSizePrinc:GetNextCallArea("INFORMACOES")
oSizeLBox:aWorkArea[3] -= oSizeLBox:aWorkArea[1] + 04	// Coluna Final
oSizeLBox:aWorkArea[4] -= oSizeLBox:aWorkArea[2] + 15	// Linha Final
oSizeLBox:aWorkArea[1] := 0 // Coluna Inicial
oSizeLBox:aWorkArea[2] := 0 // Linha Inicial

oSizeLBox:AddObject("CONTRATO"  ,100,060,.T.,.F.)
oSizeLBox:AddObject("DETALHES"  ,100,040,.T.,.T.)
oSizeLBox:aMargins := { 3 , 3 , 0 , 0 }

oSizeLBox:lProp := .t. 		// Mantem proporcao entre objetos redimensionaveis
oSizeLBox:Process()	// Calcula Coordenadas

// Calculo da Area de Listbox de Detalhes
oSizeContr := FwDefSize():New(.f.)
oSizeContr:aWorkArea := oSizeLBox:GetNextCallArea("CONTRATO")
oSizeContr:AddObject("FILTRO"  ,070,020,.F.,.T.)
oSizeContr:AddObject("CONTRATO",100,020,.T.,.T.)
oSizeContr:aMargins := { 3 , 0 , 0 , 0 }
oSizeContr:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
oSizeContr:lLateral := .t.	// Calculo de Colunas
oSizeContr:Process()	// Calcula Coordenadas

// Calculo da Area de Listbox de Detalhes
oSizeDet1 := FwDefSize():New(.f.)
oSizeDet1:aWorkArea := oSizeLBox:GetNextCallArea("DETALHES")
oSizeDet1:AddObject("PECAS"   ,100,020,.T.,.T.)
oSizeDet1:AddObject("SERVICOS",100,020,.T.,.T.)
oSizeDet1:AddObject("OUTROS"  ,100,020,.T.,.T.)
oSizeDet1:aMargins := { 3 , 0 , 0 , 0 }
oSizeDet1:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
oSizeDet1:lLateral := .t.	// Calculo de Colunas
oSizeDet1:Process()	// Calcula Coordenadas

oSizeDet2 := FwDefSize():New(.f.)
oSizeDet2:aWorkArea := oSizeLBox:GetNextCallArea("DETALHES")
oSizeDet2:AddObject("KIT"   ,100,020,.T.,.T.)
oSizeDet2:AddObject("SERVICOS",100,020,.T.,.T.)
oSizeDet2:aMargins := { 3 , 0 , 0 , 0 }
oSizeDet2:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
oSizeDet2:lLateral := .t.	// Calculo de Colunas
oSizeDet2:Process()	// Calcula Coordenadas
//



DEFINE MSDIALOG oDlgOpenPIP TITLE STR0001 OF oMainWnd PIXEL;
	FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

oEnchVV1 := MSMGet():New("VV1",nReg, 2 /* Visualizar */ ,;
	/* aCRA */, /* cLetra*/, /* cTexto */, aCpoEnchoice, ;
	oSizePrinc:GetObjectArea("GETDADOSVV1"), ;
	aCpoEnchoice, 3 /* nModelo */ ,;
	/* nColMens */, /* cMensagem */, "AllwaysTrue()", oDlgOpenPIP , .f. /* lF3 */ , .t. /* lMemoria */ , .F. /* lColumn */ ,;
	"" /* caTela */ , .t. /* lNoFolder */, .f. /* lProperty */ )

oFOpenPIP := TFolder():New( oSizePrinc:GetDimension("INFORMACOES","LININI" ) , ;
							oSizePrinc:GetDimension("INFORMACOES","COLINI" ) ,;
							/* { "Plano de Revisão" , "PIP" } */ , , oDlgOpenPIP , , , , .t. , ,;
							oSizePrinc:GetDimension("INFORMACOES","XSIZE" ),;
							oSizePrinc:GetDimension("INFORMACOES","YSIZE" ) )

If Len(aAuxRevisao) > 0

	oFOpenPIP:AddItem( STR0028 , .t. ) // "Revisão"
	nFldRevisao := Len(oFOpenPIP:aDialogs)

	TGroup():New( oSizeDet1:GetDimension("PECAS","LININI") , oSizeDet1:GetDimension("PECAS","COLINI") , oSizeDet1:GetDimension("PECAS","LINEND") , oSizeDet1:GetDimension("PECAS","COLEND") , STR0029 , oFOpenPIP:aDialogs[nFldRevisao],,,.t., ) // "Peças"
	oPecas := TWBrowse():New( oSizeDet1:GetDimension("PECAS","LININI") + 8, ;
									oSizeDet1:GetDimension("PECAS","COLINI") + 2,;
									oSizeDet1:GetDimension("PECAS","XSIZE") -4 ,;
									oSizeDet1:GetDimension("PECAS","YSIZE") -10,,,,oFOpenPIP:aDialogs[nFldRevisao],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oPecas:AddColumn( TCColumn():New( STR0014 , { || aPecas[oPecas:nAT,1] } ,,,,"LEFT"  ,50,.F.,.F.,,,,.F.,) ) // "Código"
	oPecas:AddColumn( TCColumn():New( STR0015 , { || aPecas[oPecas:nAT,2] } ,,,,"LEFT" 	,60,.F.,.F.,,,,.F.,) ) // "Descrição"
	oPecas:AddColumn( TCColumn():New( STR0020 , { || aPecas[oPecas:nAT,3] } ,,,,"RIGHT" ,20,.F.,.F.,,,,.F.,) ) // "Qtde"
	oPecas:nAt := 1
	oPecas:SetArray(aPecas)

	TGroup():New( oSizeDet1:GetDimension("SERVICOS","LININI") , oSizeDet1:GetDimension("SERVICOS","COLINI") , oSizeDet1:GetDimension("SERVICOS","LINEND") , oSizeDet1:GetDimension("SERVICOS","COLEND") , STR0030 , oFOpenPIP:aDialogs[nFldRevisao],,,.t., ) // "Serviços"
	oSrvc := TWBrowse():New( oSizeDet1:GetDimension("SERVICOS","LININI") + 8, ;
									oSizeDet1:GetDimension("SERVICOS","COLINI") + 2,;
									oSizeDet1:GetDimension("SERVICOS","XSIZE") -4 ,;
									oSizeDet1:GetDimension("SERVICOS","YSIZE") -10,,,,oFOpenPIP:aDialogs[nFldRevisao],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oSrvc:AddColumn( TCColumn():New( STR0019 , { || aSrvc[oSrvc:nAT,3] + " - " + aSrvc[oSrvc:nAT,4] } ,,,,"LEFT" ,90,.F.,.F.,,,,.F.,) ) // "Tipo"
	oSrvc:AddColumn( TCColumn():New( STR0032 , { || aSrvc[oSrvc:nAT,5] + " - " + aSrvc[oSrvc:nAT,6] } ,,,,"LEFT" ,50,.F.,.F.,,,,.F.,) ) // "Localidade"
	oSrvc:AddColumn( TCColumn():New( STR0033 , { || aSrvc[oSrvc:nAT,7] } ,,,,"RIGHT" ,20,.F.,.F.,,,,.F.,) ) // "Horas"
	oSrvc:nAt := 1
	oSrvc:SetArray(aSrvc)


	TGroup():New( oSizeDet1:GetDimension("OUTROS","LININI") , oSizeDet1:GetDimension("OUTROS","COLINI") , oSizeDet1:GetDimension("OUTROS","LINEND") , oSizeDet1:GetDimension("OUTROS","COLEND") , STR0031 , oFOpenPIP:aDialogs[nFldRevisao],,,.t., ) // "Outros"
	oOutros := TWBrowse():New( oSizeDet1:GetDimension("OUTROS","LININI") + 8, ;
									oSizeDet1:GetDimension("OUTROS","COLINI") + 2,;
									oSizeDet1:GetDimension("OUTROS","XSIZE") -4 ,;
									oSizeDet1:GetDimension("OUTROS","YSIZE") -10,,,,oFOpenPIP:aDialogs[nFldRevisao],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oOutros:AddColumn( TCColumn():New( STR0019 , { || aOutros[oOutros:nAT,7] + " - " + aOutros[oOutros:nAT,8] } ,,,,"LEFT"  ,70,.F.,.F.,,,,.F.,) ) // "Tipo"
	oOutros:AddColumn( TCColumn():New( STR0034 , { || aOutros[oOutros:nAT,4] + " - " + aOutros[oOutros:nAT,5] } ,,,,"LEFT" 	,50,.F.,.F.,,,,.F.,) ) // "Produto"
	oOutros:AddColumn( TCColumn():New( STR0035 , { || aOutros[oOutros:nAT,3] } ,,,,"RIGHT" ,20,.F.,.F.,,,,.F.,) ) // "Qtde/Horas"
	oOutros:nAt := 1
	oOutros:SetArray(aOutros)


	TGroup():New( oSizeLBox:GetDimension("CONTRATO","LININI") , oSizeLBox:GetDimension("CONTRATO","COLINI") , oSizeLBox:GetDimension("CONTRATO","LINEND") , oSizeLBox:GetDimension("CONTRATO","COLEND") , STR0028 , oFOpenPIP:aDialogs[nFldRevisao] ,,,.t., ) // "Revisão"

	aSort(aTpMaq,,,{|x,y| x > y })
	oTpMaq := TWBrowse():New( oSizeContr:GetDimension("FILTRO","LININI") + 8 , oSizeContr:GetDimension("FILTRO","COLINI") + 2 , oSizeContr:GetDimension("FILTRO","XSIZE") -0 , oSizeContr:GetDimension("FILTRO","YSIZE") -10,,,,oFOpenPIP:aDialogs[nFldRevisao],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oTpMaq:AddColumn( TCColumn():New( STR0035 , { || aTpMaq[oTpMaq:nAT] } ,,,,"LEFT"  ,20,.F.,.F.,,,,.F.,) ) // "Tp. Máquina"
	oTpMaq:nAt := 1
	oTpMaq:SetArray(aTpMaq)
	oTpMaq:bChange := { || OFCJDDET2( aTpMaq[oTpMaq:nAt] , @aRevisao ) , oRevisao:SetArray(aRevisao) , oRevisao:goTop() }


	oRevisao := TWBrowse():New( oSizeContr:GetDimension("CONTRATO","LININI") + 8, ;
									oSizeContr:GetDimension("CONTRATO","COLINI") + 2,;
									oSizeContr:GetDimension("CONTRATO","XSIZE") -4 ,;
									oSizeContr:GetDimension("CONTRATO","YSIZE") -10,,,,oFOpenPIP:aDialogs[nFldRevisao],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	If lMark
		oRevisao:AddColumn( TCColumn():New( " "						, { || IIf(aRevisao[oRevisao:nAT,15],oOk,oNo) }	,,,,"LEFT" ,10,.T.,.F.,,,,.F.,) )
	EndIf
	oRevisao:AddColumn( TCColumn():New( STR0036	, { || aRevisao[oRevisao:nAT,01] } ,,,,"LEFT"  ,40,.F.,.F.,,,,.F.,) )         // "Plano"
	oRevisao:AddColumn( TCColumn():New( STR0037	, { || AllTrim(aRevisao[oRevisao:nAT,09])} ,,,,"LEFT"  ,90,.F.,.F.,,,,.F.,) ) // "Tp. Srvc. Interno"
	oRevisao:AddColumn( TCColumn():New( STR0038	, { || aRevisao[oRevisao:nAT,04] } ,,,,"LEFT"  ,45,.F.,.F.,,,,.F.,) )         // "Dt. Inical (Rev.)"
	oRevisao:AddColumn( TCColumn():New( STR0039	, { || aRevisao[oRevisao:nAT,05] } ,,,,"LEFT"  ,45,.F.,.F.,,,,.F.,) )         // "Dt. Final (Rev.)"
	oRevisao:AddColumn( TCColumn():New( STR0040	, { || aRevisao[oRevisao:nAT,06] } ,,,,"LEFT"  ,40,.F.,.F.,,,,.F.,) )         // "Status (Rev.)"
	oRevisao:AddColumn( TCColumn():New( STR0042	, { || aRevisao[oRevisao:nAT,10] } ,,,,"LEFT"  ,40,.F.,.F.,,,,.F.,) )         // "Dt. Inicial"
	oRevisao:AddColumn( TCColumn():New( STR0043	, { || aRevisao[oRevisao:nAT,11] } ,,,,"LEFT"  ,40,.F.,.F.,,,,.F.,) )         // "Dt. Final"
	oRevisao:AddColumn( TCColumn():New( STR0044	, { || aRevisao[oRevisao:nAT,13] } ,,,,"RIGHT" ,30,.F.,.F.,,,,.F.,) )         // "Limite"
	oRevisao:AddColumn( TCColumn():New( STR0045	, { || aRevisao[oRevisao:nAT,12] } ,,,,"LEFT"  ,30,.F.,.F.,,,,.F.,) )         // "Status"
	oRevisao:AddColumn( TCColumn():New( STR0057	, { || aRevisao[oRevisao:nAT,03] } ,,,,"LEFT"  ,40,.F.,.F.,,,,.F.,) )         // "Mat. Master"
	oRevisao:AddColumn( TCColumn():New( STR0041	, { || aRevisao[oRevisao:nAT,07] } ,,,,"LEFT"  ,30,.F.,.F.,,,,.F.,) )         // "Intervalo de Srvc."
	oRevisao:bLDblClick := { || OFCJDTIK(1,oRevisao:nAt,@aRevisao,@aPMP) , oRevisao:Refresh() }
	oRevisao:nAt := 1
	oRevisao:SetArray(aRevisao)
	oRevisao:bChange := { || OFCJDDET3 ( aRevisao[oRevisao:nAT,08] , aRevisao[oRevisao:nAT,02] , @aPecas , @aSrvc , @aOutros , aRevisao[oRevisao:nAT,03] ) ,;
							oPecas:nAt := 1 ,;
							oPecas:SetArray(aPecas),;
							oPecas:Refresh(),;
							oSrvc:nAt := 1 ,;
							oSrvc:SetArray(aSrvc),;
							oSrvc:Refresh(),;
							oOutros:nAt := 1 ,;
							oOutros:SetArray(aOutros),;
							oOutros:Refresh()}

	oPecas:Refresh()
	oSrvc:Refresh()
	oOutros:Refresh()
	oTpMaq:Refresh()
	oRevisao:Refresh()
EndIf

If Len(aPMP) > 0

	oFOpenPIP:AddItem( "PMP" , .t. )
	nFldPMP := Len(oFOpenPIP:aDialogs)


	TGroup():New( oSizeDet2:GetDimension("SERVICOS","LININI") , oSizeDet2:GetDimension("SERVICOS","COLINI") , oSizeDet2:GetDimension("SERVICOS","LINEND") , oSizeDet2:GetDimension("SERVICOS","COLEND") , "Serviços" , oFOpenPIP:aDialogs[nFldPMP],,,.t., )
	oPMPSrvc := TWBrowse():New( oSizeDet2:GetDimension("SERVICOS","LININI") + 8, ;
							oSizeDet2:GetDimension("SERVICOS","COLINI") + 2,;
							oSizeDet2:GetDimension("SERVICOS","XSIZE") -4 ,;
							oSizeDet2:GetDimension("SERVICOS","YSIZE") -10,,,,oFOpenPIP:aDialogs[nFldPMP],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oPMPSrvc:AddColumn( TCColumn():New( STR0046	, { || aPMPSrvc[oPMPSrvc:nAT,4] + " - " + AllTrim(aPMPSrvc[oPMPSrvc:nAT,9]) } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // "Serviço"
	oPMPSrvc:AddColumn( TCColumn():New( STR0047	, { || aPMPSrvc[oPMPSrvc:nAT,5] + " - " + AllTrim(aPMPSrvc[oPMPSrvc:nAT,6]) } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // "Localidade"
	oPMPSrvc:AddColumn( TCColumn():New( STR0048	, { || aPMPSrvc[oPMPSrvc:nAT,7] } ,,,,"RIGHT" ,20,.F.,.F.,,,,.F.,) )                                            // "Horas"
	oPMPSrvc:nAt := 1
	oPMPSrvc:SetArray(aPMPSrvc)


	TGroup():New( oSizeDet2:GetDimension("KIT","LININI") , oSizeDet2:GetDimension("KIT","COLINI") , oSizeDet2:GetDimension("KIT","LINEND") , oSizeDet2:GetDimension("KIT","COLEND") , "Kit" , oFOpenPIP:aDialogs[nFldPMP],,,.t., )
	oPMPKit := TWBrowse():New( oSizeDet2:GetDimension("KIT","LININI") + 8, ;
									oSizeDet2:GetDimension("KIT","COLINI") + 2,;
									oSizeDet2:GetDimension("KIT","XSIZE") -4 ,;
									oSizeDet2:GetDimension("KIT","YSIZE") -10,,,,oFOpenPIP:aDialogs[nFldPMP],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oPMPKit:AddColumn( TCColumn():New( STR0049 , { || aPMPKit[oPMPKit:nAT,04] } ,,,,"LEFT"  ,40,.F.,.F.,,,,.F.,) ) // "Produto"
	oPMPKit:AddColumn( TCColumn():New( STR0015 , { || aPMPKit[oPMPKit:nAT,09] } ,,,,"LEFT"  ,70,.F.,.F.,,,,.F.,) ) // "Descrição"
	oPMPKit:AddColumn( TCColumn():New( STR0020 , { || aPMPKit[oPMPKit:nAT,07] } ,,,,"RIGHT" ,20,.F.,.F.,,,,.F.,) ) // "Qtde"
	oPMPKit:nAt := 1
	oPMPKit:SetArray(aPMPKit)

	TGroup():New( oSizeLBox:GetDimension("CONTRATO","LININI") , oSizeLBox:GetDimension("CONTRATO","COLINI") , oSizeLBox:GetDimension("CONTRATO","LINEND") , oSizeLBox:GetDimension("CONTRATO","COLEND") , "PMP" , oFOpenPIP:aDialogs[nFldPMP] ,,,.t., )
	oPMP := TWBrowse():New( oSizeLBox:GetDimension("CONTRATO","LININI") + 8, ;
							oSizeLBox:GetDimension("CONTRATO","COLINI") + 2,;
							oSizeLBox:GetDimension("CONTRATO","XSIZE") -4 ,;
							oSizeLBox:GetDimension("CONTRATO","YSIZE") -10,,,,oFOpenPIP:aDialogs[nFldPMP],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	If lMark
		oPMP:AddColumn( TCColumn():New( " "						, { || IIf(aPMP[oPMP:nAT,6],oOk,oNo) }	,,,,"LEFT" ,10,.T.,.F.,,,,.F.,) )
	EndIf
	oPMP:AddColumn( TCColumn():New( STR0050 , { || aPMP[oPMP:nAT,01] } ,,,,"LEFT"  ,40,.F.,.F.,,,,.F.,) ) // "Número"
	oPMP:AddColumn( TCColumn():New( STR0051 , { || aPMP[oPMP:nAT,02] } ,,,,"LEFT"  ,50,.F.,.F.,,,,.F.,) ) // "Data Exp."
	oPMP:AddColumn( TCColumn():New( STR0052 , { || aPMP[oPMP:nAT,05] } ,,,,"LEFT"  ,70,.F.,.F.,,,,.F.,) ) // "Nome"
	oPMP:AddColumn( TCColumn():New( STR0019 , { || aPMP[oPMP:nAT,03] + " - " + AllTrim(aPMP[oPMP:nAT,04])} ,,,,"LEFT"  ,60,.F.,.F.,,,,.F.,) ) // "Tipo"
	oPMP:bLDblClick := { || OFCJDTIK(2,oPMP:nAt,@aRevisao,@aPMP) , oPMP:Refresh() }
	oPMP:nAt := 1
	oPMP:SetArray(aPMP)
	oPMP:bChange := { || OFCJDDET4 ( aPMP[oPMP:nAT,1] , @aPMPSrvc , @aPMPKit ) ,;
							oPMPSrvc:nAt := 1 ,;
							oPMPSrvc:SetArray(aPMPSrvc),;
							oPMPSrvc:Refresh(),;
							oPMPKit:nAt := 1 ,;
							oPMPKit:SetArray(aPMPKit),;
							oPMPKit:Refresh() }

	oPMPSrvc:Refresh()
	oPMPKit:Refresh()
	oPMP:Refresh()

EndIf

oWS := NIL
oFOpenPIP:SetOption(1)

ACTIVATE MSDIALOG oDlgOpenPIP ON INIT EnchoiceBar(oDlgOpenPIP,{ || lOk := .t. , oDlgOpenPIP:End()},{||oDlgOpenPIP:End()})

If lOk .and. lMark

	aRetorno := {}

	// Verifica se foi selecionado uma revisao
	nPos := aScan ( aRevisao , { |x| x[15] } )
	If nPos > 0
		aRetorno := Array(5)
		aRetorno[1] := 1 // Indica que é uma Revisao
		aRetorno[2] := aClone( aRevisao[nPos])
		aRetorno[3] := IIf( !Empty(aPecas[1,1])  , aClone( aPecas )  , {} )
		aRetorno[4] := IIf( !Empty(aSrvc[1,1])   , aClone( aSrvc )   , {} )
		aRetorno[5] := IIf( !Empty(aOutros[1,1]) , aClone( aOutros ) , {} )
	EndIf

	// Verifica se foi selecionado um PMP
	nPos := aScan ( aPMP , { |x| x[06] } )
	If nPos > 0
		aRetorno := Array(4)
		aRetorno[1] := 2 // Indica que é um PMP
		aRetorno[2] := aClone( aPMP[nPos])
		aRetorno[3] := IIf( !Empty(aPMPSrvc[1,1]) , aClone( aPMPSrvc ) , {} )
		If Len(aPMPKit) <> 0
			aRetorno[4] := IIf( !Empty(aPMPKit[1,1])  , aClone( aPMPKit )  , {} )
		Else
			aRetorno[4] := {}
		EndIf
	EndIf

EndIf

Return



/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFCJDTIK  | Autor | Takahashi             | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Marca item da Listbox                                        |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OFCJDTIK(nOrigem,nAuxPos,aRevisao,aPMP)

Local cVMBAlias := "TVMB"
Local cSQL

Do Case
Case nOrigem == 1 // Listbox de Revisao

	If aRevisao[nAuxPos,15]
		aRevisao[nAuxPos,15] := .f.
	Else

		// Verifica se já existe uma SG da Revisão selecionada
		cSQL := "SELECT VMB_CODGAR, VMB_NUMOSV "
		cSQL +=  " FROM " + RetSQLName("VMB")
		cSQL += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "'"
		cSQL +=   " AND VMB_CHASSI = '" + AllTrim(VV1->VV1_CHASSI) + "'"
		cSQL +=   " AND VMB_TIPGAR = 'ZZMK'"
		cSQL +=   " AND VMB_SUBGAR = 'MTC'"
		cSQL +=   " AND VMB_INTSRV = '" + aRevisao[nAuxPos,08] + "'"
		cSQL +=   " AND VMB_STATUS NOT IN ('04','05','15')" // 04=REJEITADO ou 05=DELETADO ou 15=DEBITADO
		cSQL +=   " AND D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cVMBAlias , .F., .T. )
		If !(cVMBAlias)->(Eof())
			MsgStop("Já existe uma solicitação de garantia para a revisão selecionada."+chr(13)+chr(10)+chr(13)+chr(10)+;
					"Solicitação de Garantia: " + (cVMBAlias)->(VMB_CODGAR)+chr(13)+chr(10)+;
					"Ordem de Serviço: " + (cVMBAlias)->(VMB_NUMOSV))
			(cVMBAlias)->(dbCloseArea())
			Return
		EndIf
		(cVMBAlias)->(dbCloseArea())
		//

		// Define a ordem de execução das revisões
		// 1ª PDI - INSPEÇÃO DE PRÉ ENTREGA
		// 2ª ADI - INSPEÇÃO APÓS A ENTREGA
		// 3ª-... MTN's
		Do Case
		Case aScan(aRevisao , { |x| AllTrim(x[1]) == "PDI" } ) <> 0
			If aRevisao[nAuxPos,1] <> "PDI"
				// Verifica se já foi criada uma SG de PDI
				cSQL := "SELECT VMB_CODGAR "
				cSQL +=  " FROM " + RetSQLName("VMB")
				cSQL += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "'"
				cSQL +=   " AND VMB_CHASSI = '" + AllTrim(VV1->VV1_CHASSI) + "'"
				cSQL +=   " AND VMB_TIPGAR = 'ZZMK'"
				cSQL +=   " AND VMB_SUBGAR = 'MTC'"
				cSQL +=   " AND VMB_PLAMAN = 'PDI'"
				cSQL +=   " AND VMB_INTSRV = '" + aRevisao[nAuxPos,08] + "'"
				cSQL +=   " AND VMB_STATUS NOT IN ('04','05','15')" // 04=REJEITADO ou 05=DELETADO ou 15=DEBITADO
				cSQL +=   " AND D_E_L_E_T_ = ' '"
				If Empty(FM_SQL(cSQL))
					MsgInfo(STR0053) // "É necessária a execução da revisão do tipo PDI."
					Return
				EndIf
			EndIf
		Case aScan(aRevisao , { |x| AllTrim(x[1]) == "ADI" } ) <> 0
			If aRevisao[nAuxPos,1] <> "ADI"
				MsgInfo(STR0054) // "É necessária a execução da revisão do tipo ADI."
				Return
			EndIf
		EndCase
		aEval( aRevisao , { |x| x[15] := .f. } )
		aRevisao[nAuxPos,15] := .t.
	EndIf
	
	// Desmarca os PMP's 
	If Len(aPMP) > 0
		aEval( aPMP , { |x| x[06] := .f. } )
		oPMP:Refresh()		
	EndIf

Case nOrigem == 2 // Listbox de PMP
	If aPMP[nAuxPos,06]
		aPMP[nAuxPos,06] := .f.
	Else
	
		// Verifica se já existe uma SG do PMP selecionado
		// So valida se o registro nao foi enviado ou esta com status de NOVO
		
		cSQL := "SELECT VMB_CODGAR, VMB_NUMOSV "
		cSQL +=  " FROM " + RetSQLName("VMB")
		cSQL += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "'"
		cSQL +=   " AND VMB_CHASSI = '" + AllTrim(VV1->VV1_CHASSI) + "'"
		cSQL +=   " AND VMB_TIPGAR = 'ZPIP'"
		cSQL +=   " AND VMB_NROPIP = '" + aPMP[nAuxPos,01] + "'"
//		cSQL +=   " AND VMB_STATUS NOT IN ('04','05')" // 04=REJEITADO ou 05=DELETADO
		cSQL +=   " AND VMB_STATUS IN ('  ','01')" //   =AINDA NAO ENVIADO OU 01=NOVO
		cSQL +=   " AND D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cVMBAlias , .F., .T. )
		If !(cVMBAlias)->(Eof())
			MsgStop("Já existe uma solicitação de garantia para o PMP selecionado."+chr(13)+chr(10)+chr(13)+chr(10)+;
					"Solicitação de Garantia: " + (cVMBAlias)->(VMB_CODGAR)+chr(13)+chr(10)+;
					"Ordem de Serviço: " + (cVMBAlias)->(VMB_NUMOSV))
			(cVMBAlias)->(dbCloseArea())
			Return
		EndIf
		(cVMBAlias)->(dbCloseArea())
		//
	
		aEval( aPMP , { |x| x[06] := .f. } )
		aPMP[nAuxPos,06] := .t.
	EndIf
	If Len(aRevisao) > 0
		aEval( aRevisao , { |x| x[15] := .f. } )
		oRevisao:Refresh()		
	EndIf
End Case

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFCJDDET2  | Autor | Takahashi             | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Atualiza Listbox de Revisão                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OFCJDDET2( cMachineCode , aRevisao )

Local nCont

aRevisao := {}

For nCont := 1 to Len(aAuxRevisao)
	If aAuxRevisao[nCont,2] == cMachineCode
		AADD( aRevisao , aClone(aAuxRevisao[nCont]) )
	EndIf
Next nCont

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFCJDDET3  | Autor | Takahashi             | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Atualiza Listbox de Detalhe de Revisao                       |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OFCJDDET3( cPlano , cMachineCode , aPecas , aSrvc , aOutros , cMatMaster )

Local nCont

aPecas  := {}
aSrvc   := {}
aOutros := {}

For nCont := 1 to Len(aAuxPecas)
	If aAuxPecas[nCont,6] == cPlano .and. aAuxPecas[nCont,5] == cMachineCode .and. aAuxPeca[nCont,2] == cMatMaster
		AADD( aPecas , aClone(aAuxPecas[nCont]) )
	EndIf
Next nCont

For nCont := 1 to Len(aAuxSrvc)
	If aAuxSrvc[nCont,9] == cPlano .and. aAuxSrvc[nCont,8] == cMachineCode .and. aAuxSrvc[nCont,2] == cMatMaster
		AADD( aSrvc , aClone(aAuxSrvc[nCont]) )
	EndIf
Next nCont

For nCont := 1 to Len(aAuxOutros)
	If aAuxOutros[nCont,7] == cPlano .and. aAuxOutros[nCont,6] == cMachineCode .and. aAuxOutros[nCont,2] == cMatMaster
		AADD( aOutros , aClone(aAuxOutros[nCont]) )
	EndIf
Next nCont


If Len(aPecas) == 0
	aPecas := { Array(4) }
	AFill( aPecas[1] , "" )
EndIf

If Len(aSrvc) == 0
	aSrvc := { Array(7) }
	AFill( aSrvc[1] , "" )
EndIf

If Len(aOutros) == 0
	aOutros := { Array(8) }
	AFill( aOutros[1] , "" )
EndIf

Return


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFCJDDET4  | Autor | Takahashi             | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Atualiza Listbox de Detalhe de PMP                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OFCJDDET4( cPMP , aSrvc , aKit )

Local nCont

aSrvc   := {}
aKit    := {}

For nCont := 1 to Len(aAuxPMPItem)
	If aAuxPMPItem[nCont,1] == cPMP
		If aAuxPMPItem[nCont,08] == "S"
			AADD( aSrvc , aClone(aAuxPMPItem[nCont]) )
		Else
			AADD( aKit  , aClone(aAuxPMPItem[nCont]) )
		EndIf
	EndIf
Next nCont

If Len(aSrvc) == 0
	aSrvc := { Array(9) }
	AFill( aSrvc[1] , "" )
EndIf

If Len(aKit) == 0
	aOutros := { Array(9) }
	AFill( aOutros[1] , "" )
EndIf

Return

/*/
{Protheus.doc} OCJD01015_GravaDataEntrega

@author Renato Vinicius
@since 01/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OCJD01015_GravaDataEntrega(dDtaEntr)

	Default dDtaEntr := StoD("")

	If !Empty(dDtaEntr)
		If Empty(VV1->VV1_DATETG)
			dbSelectArea("VV1")
			RecLock("VV1",.f.)
				VV1->VV1_DATETG := dDtaEntr
			MsUnlock()
		EndIf

	EndIf

Return


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | MenuDef    | Autor | Takahashi             | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Definicao de Menu                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MenuDef()

Local aRotina:= {{ STR0002 , "PesqBrw"   , 0 , 1},; // Pesquisar
				 { STR0003 , "OFCJDCO1"  , 0 , 2},; // Cons. Inf. Garantia
				 { STR0004 , "OFCJDCO2"  , 0 , 2} } // Cons. Revisão Abertas
Return aRotina