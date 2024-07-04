#Include "PROTHEUS.CH"
#Include "FILEIO.CH"
#Include "TOPCONN.CH"
#Include "OFIXDEF.CH"
#Include "OFIA160.CH"

#define PULALINHA chr(13) + chr(10)

Static aAccPerm := aClone(OA1600115_DealerAccPermitidos())

/*/
{Protheus.doc} OFIA160

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function OFIA160()

Local bProcess
Local cPerg := "OFIA160"

Private lSchedule := FWGetRunSchedule()

Pergunte(cPerg,.f.)

bProcess := { |oSelf| OA1600051_Processa(oSelf) }
//CriaSX1(cPerg)

If lSchedule
	MV_PAR02 := 2
	OA1600051_Processa()
Else
	oTProces := tNewProcess():New(;
	/* 01 */				"OFIA160",;
	/* 02 */				STR0001,;
	/* 03 */				bProcess,;
	/* 04 */				STR0002,;
	/* 05 */				cPerg ,;
	/* 06 */				/*aInfoCustom*/ ,;
	/* 07 */				.t. /* lPanelAux */ ,;
	/* 08 */				 /* nSizePanelAux */ ,;
	/* 09 */				/* cDescriAux */ ,;
	/* 10 */				.t. /* lViewExecute */ ,;
	/* 11 */				.t. /* lOneMeter */ )
EndIf

Return
/*/{Protheus.doc} SchedDef
	Função padrão scheduler

	@author Vinicius Gati
	@since 28/06/2017
	@type function
/*/
Static Function SchedDef()
Local aParam := {;
	"P",;
	"OFIA160",;
	"",;
	"",;
	"" ;
	}
Return aParam

/*/
{Protheus.doc} OFIA160

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA1600051_Processa()

Local dDtInicial := StoD("")
Local dDtFinal   := StoD("")
Local dData      := YearSub(dDataBase,5)
Local nAno       := 0

Private oDPM       := DMS_DPM():New()
Private aFilis     := oDPM:GetFiliais()
Private lGeraLog   := .f.
Private cDealerAcc := GetMV("MV_MIL0005")
Private cTagsXml   := ""
Private cTipoArq   := "Hist"

Private oLogger    := DMS_Logger():New()
Private cModo      := 'Normal'

If lSchedule
	cModo := 'Schedule'
EndIf

If MV_PAR02 == 2
	dDtInicial := OA1600052_LevantaDataVQL()
	dDtFinal   := dDataBase

	cTipoArq := "Delta"
	OA1600058_GeracaoTagsXML(dDtInicial,dDtFinal)
Else
    
	For nAno := 1 to 5
		dDtInicial := dData
		dDtFinal   := YearSum(dData,1)
		OA1600058_GeracaoTagsXML(dDtInicial,dDtFinal)
		dData      := DaySum(dDtFinal,1)
	Next
    
/*/ Teste de Homologação
	dDtInicial := MonthSub(dDataBase,1)
	dDtFinal   := dDataBase
	OA1600058_GeracaoTagsXML(dDtInicial,dDtFinal)
/*/
EndIf

if lGeraLog
	//Gerar log de execução no VQL
	cTblLogCod := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFIA160'         },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'     },;
		{'VQL_DADOS'      , 'MODO: ' + cModo   } ;
		})

	oLogger:CloseOpened(cTblLogCod)
Else
	MsgStop(STR0003,STR0004)
EndIf

Return

/*/
{Protheus.doc} OFIA160

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA1600052_LevantaDataVQL()

Local cQuery := ""

cQuery := "SELECT VQL.VQL_DATAI "
cQuery += " FROM " + RetSqlName("VQL") + " VQL "
cQuery += " WHERE "
cQuery +=    " VQL.VQL_FILIAL = '" + xFilial("VQL") + "' AND "
cQuery +=    " VQL.VQL_AGROUP = 'OFIA160' AND "
cQuery +=    " VQL.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VQL_DATAI DESC"

Return Stod(FM_SQL(cQuery))

/*/
{Protheus.doc} OFIA160

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA1600053_LevantaTagMachine(cCHAINT,cDOC,cSERIE,cCLIENTE,cLOJA,cKM)

Local cRetMaq := ""
Local cRetMaqB:= ""
Local cQuery  := ""
//Local cUltKil := ""

Default cCHAINT := ""
Default cDOC := ""
Default cSERIE := ""
Default cCLIENTE := ""
Default cLOJA := ""
Default cKM := ""

cQuery := "SELECT * "
cQuery += "FROM " + RetSqlName("VV1") + " VV1 "
cQuery +=   "LEFT JOIN " + RetSqlName("VV2")+ " VV2 "
cQuery +=   "ON  VV2.VV2_CODMAR = VV1.VV1_CODMAR "
cQuery +=   "AND VV2.VV2_MODVEI = VV1.VV1_MODVEI "
cQuery +=   "AND VV2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE "
cQuery +=  " VV1.VV1_FILIAL = '" + xFilial("VV1") + "' AND "
cQuery +=  " VV1.VV1_CHAINT = '" + cCHAINT + "' AND "
cQuery +=  " VV1.D_E_L_E_T_ = ' ' "

TCQuery cQuery New Alias "TMPMAQ"

If !TMPMAQ->(Eof())

	//cUltKil := cValToChar(FG_RETULT( cCHAINT , dDataBase , 2359 , 1, "VO1_KILOME" ))

	cRetMaq +=    '<Machine>' + PULALINHA 
	cRetMaq +=       '<PIN>' + Alltrim(Left(TMPMAQ->VV1_CHASSI,20)) + '</PIN>' + PULALINHA 
	cRetMaq +=       '<Model>' + Alltrim(Left(TMPMAQ->VV2_MODVEI,20)) + '</Model>' + PULALINHA 
	cRetMaq +=       '<ReportedHours>' + cValToChar(cKM) + '</ReportedHours>' + PULALINHA 
	//Somente quando for garantia envia
//	cRetMaq +=       '<UsageType>' + "C" + '</UsageType>' + PULALINHA 
	cRetMaq +=    '</Machine>' + PULALINHA 

	if !Empty(cDOC+cSERIE)
		cRetMaqB += '<MachineParts>' + PULALINHA // Abre a tag MachineParts
		cRetMaqB += cRetMaq
		cRetMaqB +=    OA1600054_LevantaTagParts(	"B",;
													cDOC,;
													cSERIE,;
													cCLIENTE,;
													cLOJA,;
													"N")
		cRetMaqB += '</MachineParts>' + PULALINHA // Fecha a tag MachineParts
		cRetMaq := cRetMaqB
	EndIf
	
EndIf

TMPMAQ->(DbCloseArea())

Return cRetMaq

/*/
{Protheus.doc} OFIA160

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA1600054_LevantaTagParts(cTIPO,cCODIGO,cSERIE,cCLIENTE,cLOJA,cDEVOLU)

Local cQuery   := ""
Local cRetPart := ""
Local aPecas   := {} // Todas Pecas
Local ni       := 0

Default cTIPO    := ""
Default cCODIGO  := ""
Default cSERIE   := ""
Default cCLIENTE := ""
Default cLOJA    := ""
Default cDEVOLU  := ""

If cTIPO == "B"
	cQuery := " SELECT "

	If cDEVOLU == "S"
		cQuery += " 	D1_COD CODPEC, "
		cQuery += " 	D1_QUANT * (-1) QUANT, "
		cQuery += " 	B1_DESC DESCR, "
		cQuery += " 	B1_CODFAB CODFAB, "
		cQuery += " 	CASE WHEN VE1_MARFAB = 'JD ' THEN 'true' "
		cQuery += " 	ELSE 'false' "  
		cQuery += " 	END TIPO "
		cQuery += "FROM "
		cQuery += " 	" + RetSqlName("SD1") + " SD1 "
		cQuery += " JOIN "
		cQuery += " 	" +RetSqlName('SF4')+ " SF4 ON "
		cQuery += " 	SF4.F4_CODIGO = SD1.D1_TES AND SF4.F4_OPEMOV='09' AND SF4.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN "
		cQuery += " 	" +RetSqlName('SB1')+ " SB1 ON "
		cQuery += " 	SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SD1.D1_COD AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN  "
		cQuery += " 	" +RetSqlName('SBM')+ " SBM ON "
		cQuery += " 	SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_FILIAL = '"+xFilial("SBM")+"' AND SBM.BM_TIPGRU NOT IN ('4 ','7 ') AND SBM.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN  "
		cQuery += " 	" +RetSqlName('VE1') +" VE1 ON "
		cQuery += " 	VE1.VE1_CODMAR = SBM.BM_CODMAR AND VE1.VE1_FILIAL = SBM.BM_FILIAL AND VE1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE "
		cQuery +=  " SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND "
		cQuery +=  " SD1.D1_DOC = '"     + cCODIGO +     "' AND "
		cQuery +=  " SD1.D1_SERIE = '"   + cSERIE +   "' AND "
		cQuery +=  " SD1.D1_FORNECE = '" + cCLIENTE + "' AND "
		cQuery +=  " SD1.D1_LOJA = '"    + cLOJA +    "' AND "
		cQuery +=  " SD1.D_E_L_E_T_ = ' '"
	Else
		cQuery += " 	D2_COD CODPEC, "
		cQuery += " 	D2_QUANT QUANT, "
		cQuery += " 	B1_DESC DESCR, "
		cQuery += " 	B1_CODFAB CODFAB, "
		cQuery += " 	CASE WHEN VE1_MARFAB = 'JD ' THEN 'true' "
		cQuery += " 	ELSE 'false' "  
		cQuery += " 	END TIPO "
		cQuery += "FROM "
		cQuery += " 	" + RetSqlName("SD2") + " SD2 "
		cQuery += " JOIN "
		cQuery += " 	" +RetSqlName('SF4')+ " SF4 ON "
		cQuery += " 	SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN "
		cQuery += " 	" +RetSqlName('SB1')+ " SB1 ON "
		cQuery += " 	SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SD2.D2_COD AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN  "
		cQuery += " 	" +RetSqlName('SBM')+ " SBM ON "
		cQuery += " 	SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_FILIAL = '"+xFilial("SBM")+"' AND SBM.BM_TIPGRU NOT IN ('4 ','7 ') AND SBM.D_E_L_E_T_ = ' ' "
//		cQuery += "LEFT JOIN  "
//		cQuery += " 	" +RetSqlName('SD1')+ " SD1 ON "
//		cQuery += " 	SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_DOC = SD1.D1_NFORI AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_COD = SD1.D1_COD AND SD2.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN  "
		cQuery += " 	" +RetSqlName('VE1') +" VE1 ON "
		cQuery += " 	VE1.VE1_CODMAR = SBM.BM_CODMAR AND VE1.VE1_FILIAL = SBM.BM_FILIAL AND VE1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE "
		cQuery +=  " SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND "
		cQuery +=  " SD2.D2_DOC = '"     + cCODIGO +     "' AND "
		cQuery +=  " SD2.D2_SERIE = '"   + cSERIE +   "' AND "
		cQuery +=  " SD2.D2_CLIENTE = '" + cCLIENTE + "' AND "
		cQuery +=  " SD2.D2_LOJA = '"    + cLOJA +    "' AND "
		cQuery +=  " SD2.D_E_L_E_T_ = ' '"
	EndIf

	TCQuery cQuery New Alias "TMPITE"

	While !TMPITE->(Eof())

		cRetPart += OA1600055_MontaTagParts(Left(TMPITE->CODPEC,22),;			//PartNumber
											Left(TMPITE->CODFAB,26),;		//PartSerialNumber
											Transform(TMPITE->QUANT,"@E 9999999.9999"),;	//Quantity
											Left(TMPITE->DESCR,20),;			//Description
											TMPITE->TIPO,;						//DeerePart
											"false",;							//MiscellaneousPart
											Transform(1,"@E 999999"),;			//PartsPerPackage
											"true")								//FirstPassFillSuccess
//											"Stocking",;		//StockingLogicCode
		TMPITE->(DbSkip())

	EndDo

	TMPITE->(DbCloseArea())
Elseif cTIPO == "O"

	aPecas := FMX_CALPEC(cCODIGO,,,,.t.,.t.,.f.,.t.,.t.,.t.,.t.,,) // Matriz TOTAL de Peças/Requisiçoes da OS

	For ni := 1 to Len(aPecas)

		If aPecas[ni,PECA_QTDREQ] > 0
			cQuery := "SELECT "
			cQuery += " 	B1_COD, "
			cQuery += " 	B1_CODFAB, "
			cQuery += " 	B1_DESC, "
			cQuery += " 	CASE WHEN VE1_MARFAB = 'JD ' THEN 'true' "
			cQuery += " 	ELSE 'false' "  
			cQuery += " 	END TIPO "
			cQuery += "FROM "
			cQuery += " 	" + RetSqlName('SB1') + " SB1 "
			cQuery += " JOIN  "
			cQuery += " 	" + RetSqlName('SBM') + " SBM ON "
			cQuery += " 	SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_FILIAL = '"+xFilial("SBM")+"' AND SBM.BM_TIPGRU NOT IN ('4 ','7 ') AND SBM.D_E_L_E_T_ = ' ' "
			cQuery += "LEFT JOIN  "
			cQuery += " 	" + RetSqlName('VE1') + " VE1 ON "
			cQuery += " 	VE1.VE1_CODMAR = SBM.BM_CODMAR AND VE1.VE1_FILIAL = SBM.BM_FILIAL AND VE1.D_E_L_E_T_ = ' ' "
			cQuery += "WHERE "
			cQuery += " 	SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_GRUPO = '"+aPecas[ni,PECA_GRUITE]+"' AND SB1.B1_CODITE = '" +aPecas[ni,PECA_CODITE]+ "' AND SB1.D_E_L_E_T_ = ' ' "

			TCQuery cQuery New Alias "TMPITE"

			If !TMPITE->(Eof())

				cRetPart += OA1600055_MontaTagParts(Left(TMPITE->B1_COD,22),;				//PartNumber
													Left(TMPITE->B1_CODFAB,26),;			//PartSerialNumber
													Transform(aPecas[ni,PECA_QTDREQ],"@E 9999999.9999"),;	//Quantity
													Left(TMPITE->B1_DESC,20),;				//Description
													TMPITE->TIPO,;							//DeerePart
													"false",;								//MiscellaneousPart
													Transform(1,"@E 999999"),;				//PartsPerPackage
													"true")									//FirstPassFillSuccess

//													"Stocking",;							//StockingLogicCode
			EndIf
			
			TMPITE->(DbCloseArea())

		EndIf
	Next

EndIf

Return cRetPart

/*/
{Protheus.doc} OFIA160

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA1600055_MontaTagParts(cPartNu,cPartSe,cQuanti,cDescri,cDeereP,cMiscel,cPartsP,cFirstP)

Local cTagPart := ""

Default cPartNu := ""
Default cPartSe := ""
Default cQuanti := ""
Default cDescri := ""
Default cDeereP := ""
Default cMiscel := ""
Default cPartsP := ""
//Default cStocki := ""
Default cFirstP := ""

cQuanti := StrTran(cQuanti,",",".")

cPartNu := Alltrim(OA1600016_RemoveCaracteresEspeciaisXML(cPartNu))
cPartSe := OA1600016_RemoveCaracteresEspeciaisXML(cPartSe)
cDescri := Upper(FWNoAccent(Alltrim(cDescri)))
cDescri := OA1600016_RemoveCaracteresEspeciaisXML(cDescri)

cTagPart := '<Part>' + PULALINHA 
cTagPart +=   '<PartNumber>' + cPartNu + '</PartNumber>' + PULALINHA 
cTagPart +=   '<PartSerialNumber>' + Alltrim(cPartSe) + '</PartSerialNumber>' + PULALINHA 
cTagPart +=   '<Quantity>' + Alltrim(cQuanti) + '</Quantity>' + PULALINHA 
cTagPart +=   '<Description>' + cDescri + '</Description>' + PULALINHA 
cTagPart +=   '<DeerePart>' + cDeereP + '</DeerePart>' + PULALINHA 
cTagPart +=   '<MiscellaneousPart>' + cMiscel + '</MiscellaneousPart>' + PULALINHA 
cTagPart +=   '<PartsPerPackage>' + Alltrim(cPartsP) + '</PartsPerPackage>' + PULALINHA 
//cTagPart +=   '<StockingLogicCode>' + cStocki + '</StockingLogicCode>' + PULALINHA 
cTagPart +=   '<FirstPassFillSuccess>' + cFirstP + '</FirstPassFillSuccess>' + PULALINHA 
cTagPart += '</Part>' + PULALINHA

Return cTagPart

/*/
{Protheus.doc} OFIA160

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA1600056_LevantaTagJob(cNUMOSV,cDATABE,cHORABE,cTPATEN)

Local cQuery    := ""
Local cRetJob   := ""
Local aInfoGar  := {}
Local ni,nj     := 0
Local nTemTra   := 0
Local cRepTime  := ""
Local dDatFin   := ""
Local cHorFin   := ""
Local cSequen   := ""

Default cNUMOSV := ""
Default cDATABE := ""
Default cHORABE := ""
Default cTPATEN := ""

Private aServs  := {} // Todos Servicos
Private lTagPart:= .t.

aServs := FMX_CALSER(cNUMOSV,,,,.t.,.t.,.t.,.t.,.t.,.t.,,) 

For ni := 1 to len(aServs)

	/* aInfoGar[]
	[1] - Há garantia? .t. / .f.
	[2] - VMB_CLAIM
	[3] - VMB_MAQPAR
	[4] - VMB_KEYPAR
	[5] - VMB_FALHA
	[6] - VMB_QUEOBS
	[7] - VMB_CAUOBS
	[8] - VMB_COROBS
	[9] - VMB_DTACCS
	*/
	aInfoGar := OA1600059_LevantaGarantia(cNUMOSV)
	
	cNumNfis := aServs[ni,SRVC_NUMNFI]
	cSerNfis := aServs[ni,SRVC_SERNFI]
	cCliNfis := aServs[ni,SRVC_CLIENTE]
	cLojNfis := aServs[ni,SRVC_LOJA]

	If SF2->(DbSeek(xFilial("SF2")+cNumNfis+cSerNfis+cCliNfis+cLojNfis))
		//
	Else
		If SF2->(DbSeek(xFilial("SF2")+cNumNfis+cSerNfis))
			//
		Else
			If !Empty(cNumNfis)
				Loop
			EndIf
		EndIf
	EndIf
	
	nTemTra := 0
	dDatFin := ""
	cHorFin := ""
	cSequen := ""
	cRepTime:= ""

	For nj := 1 to len(aServs[ni,SRVC_APONT]) // Apontamentos
		nTemTra += aServs[ni,SRVC_APONT,nj,SRVC_APONT_TEMTRA]  // Tempo Trabalhado
		dDatFin := aServs[ni,SRVC_APONT,nj,SRVC_APONT_DATFIN]  // Data Final
		cHorFin := Transform(Strzero(aServs[ni,SRVC_APONT,nj,SRVC_APONT_HOTFIN],4),"@R 99:99")+":00"
		cSequen := aServs[ni,SRVC_APONT,nj,SRVC_APONT_SEQUEN]  // Sequencial
	Next
	
	If !Empty(dDatFin)
		cRepTime := FWTimeStamp(3,dDatFin,cHorFin)
	EndIf

	cRetJob += OA1600057_MontaTagJob(	cNUMOSV,;								//Numero OS
										Alltrim(aServs[ni,SRVC_CODSER]),;		//JobName
										Left(cSequen,8),;						//SegmentID
										aInfoGar[1,2],;							//ClaimSequenceNumber
										Left(cTPATEN,5),;						//FieldRepair
										If(aInfoGar[1,1],"true","false"),;		//Warranty
										FWTimeStamp(3,StoD(cDATABE),cHORABE),;	//EventTimestamp
										FWTimeStamp(3,StoD(cDATABE),cHORABE),;	//CreatedTimestamp
										cRepTime,;								//RepairTimestamp
										FWTimeStamp(3,SF2->F2_EMISSAO,Transform(SF2->F2_HORA,"@R 99:99")+":00"),;	//InvoiceTimestamp
										If(Empty(cNumNfis),"true","false"),;	//WIP
										aInfoGar[1,3],;							//MachineDown
										cNumNfis+cSerNfis,;						//InvoiceNumber
										Transform(nTemTra/100,"@R 99999999.99"),;//LaborHours
										Left(aInfoGar[1,4],22),;				//PrimaryFailedPart
										Left(aInfoGar[1,5],40),;				//FailureMode
										aInfoGar[1,6],;							//Complaint
										aInfoGar[1,7],;							//Cause
										aInfoGar[1,8],;							//Correction
										Left(aInfoGar[1,9],20))					//DTACCase

Next

Return cRetJob

/*/
{Protheus.doc} OFIA160

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA1600057_MontaTagJob(cNumOsv,cJobNam,cSegmen,cClaimS,cFieldR,cWarran,cEventT,cCreate,cRepair,cInvoic,cWIP,cMachin,cInvNum,cLaborH,cPrimar,cFailuR,cCompla,cCause,cCorrec,cDTACCa)

Local cTagJob   := ""

Default cNumOsv := ""
Default cJobNam := ""
Default cSegmen := ""
Default cClaimS := ""
Default cFieldR := ""
Default cWarran := ""
Default cEventT := ""
Default cCreate := ""
Default cRepair := ""
Default cInvoic := ""
Default cWIP    := ""
Default cMachin := ""
Default cInvNum := ""
Default cLaborH := ""
Default cPrimar := ""
Default cFailur := ""
Default cCompla := ""
Default cCause  := ""
Default cCorrec := ""
Default cDTACCa := ""

cTagJob := '<Job>' + PULALINHA 
cTagJob +=   '<JobName>' 			+ cJobNam + '</JobName>' + PULALINHA 
cTagJob +=   '<SegmentID>' 			+ cSegmen + '</SegmentID>' + PULALINHA 

if cWarran == "true"
	cTagJob +=   '<ClaimSequenceNumber>'+ cClaimS + '</ClaimSequenceNumber>' + PULALINHA 
EndIf

cTagJob +=   '<FieldRepair>' 		+ cFieldR + '</FieldRepair>' + PULALINHA 
cTagJob +=   '<Warranty>' 			+ cWarran + '</Warranty>' + PULALINHA 
cTagJob +=   '<EventTimestamp>' 	+ cEventT + '</EventTimestamp>' + PULALINHA 
cTagJob +=   '<CreatedTimestamp>' 	+ cCreate + '</CreatedTimestamp>' + PULALINHA 
cTagJob +=   '<RepairTimestamp>' 	+ cRepair + '</RepairTimestamp>' + PULALINHA 

if cWIP == "false"
	cTagJob +=   '<InvoiceTimestamp>' 	+ cInvoic + '</InvoiceTimestamp>' + PULALINHA 
Else
	cTagJob +=   '<InvoiceTimestamp></InvoiceTimestamp>' + PULALINHA  // Deve ser enviada sempre, mesmo que conteúdo em branco quando WIP for True (Makovec Ben)
EndIf

cTagJob +=   '<WIP>' 				+ cWIP    + '</WIP>' + PULALINHA 

if cWarran == "true"
	cTagJob +=   '<MachineDown>' 		+ cMachin + '</MachineDown>' + PULALINHA 
EndIf

if cWIP == "false"
	cTagJob +=   '<InvoiceNumber>' 		+ Alltrim(cInvNum) + '</InvoiceNumber>' + PULALINHA 
EndIf

cTagJob +=   '<LaborHours>' 		+ Alltrim(cLaborH) + '</LaborHours>' + PULALINHA 

//if cWarran == "true"
	cTagJob +=   '<PrimaryFailedPart>' 		+ Alltrim(cPrimar) + '</PrimaryFailedPart>' + PULALINHA 
	cTagJob +=   '<FailureMode>' 		+ cFailur + '</FailureMode>' + PULALINHA 
//EndIf

cTagJob +=   '<Complaint>' 			+ FWNoaccent(cCompla) + '</Complaint>' + PULALINHA 
cTagJob +=   '<Cause>' 				+ FWNoaccent(cCause)  + '</Cause>' + PULALINHA 
cTagJob +=   '<Correction>' 		+ FWNoaccent(cCorrec) + '</Correction>' + PULALINHA 

if cWarran == "true"
	cTagJob +=   '<DTACCase>' 		+ Alltrim(cDTACCa) + '</DTACCase>' + PULALINHA 
EndIf


if lTagPart
	lTagPart := .f.
	cTagJob +=   OA1600054_LevantaTagParts(	"O",;
											cNumOsv)
EndIf

cTagJob += '</Job>' + PULALINHA

Return cTagJob

/*/
{Protheus.doc} OFIA160

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA1600058_GeracaoTagsXML(dDtaIni,dDtaFin)

Local cQuery     := ""
Local cTagsOrc   := ""
Local cTagsOS    := ""
Local nIdx       := 0
Local cArq       := ""

Default dDtaIni  := Stod("")
Default dDtaFin  := Stod("")

For nIdx := 1 to LEN(aFilis)

	cFilAnt  := aFilis[nIdx][1]

	cDealerAcc := GetMV("MV_MIL0005")

	If !OA1600105_Permissao(cDealerAcc)
		HELP(' ',;
				1,;
				'EMPPERMIS',;
				,;
				"Essa empresa não tem permissão para executar essa operação." + CHR(13) + CHR(10) + " Deeler Account: " + cDealerAcc,;
				2,;
				0,;
				,;
				,;
				,;
				,;
				,;
				{"Entre em contato com a John Deere e solicite a liberação do ELIPS"})
		Loop
	EndIf

	cArq := lower(ALLTRIM(MV_PAR01))
	cArq += "DLR2JD_ELIPS_" 
	cArq += cTipoArq + "_"
	cArq += cDealerAcc + "_"
	cArq += DtoS(Date()) + "_"
	cArq += SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2)
	cArq += ".temp"

	cArqNovo := cArq
	cArqNovo := lower(cArqNovo)

	nHdl := Fcreate( cArqNovo ,,,.f.)

	If nHdl < 0
		FMX_HELP("INIHANDLE", "Erro na geração do arquivo." + CHR(13) + CHR(10) + cArq + CHR(13) + CHR(10) + "FError() " + Str(FERROR(),4) , "Verifique o diretório informado e tente novamente.")
		Loop
	EndIf

	cTagsXml := '<?xml version="1.0" encoding="UTF-8" ?>' + PULALINHA
	cTagsXml += '<tns:DealerOrg xmlns:tns="http://elips.johndeere.com/v1.0/"'
	cTagsXml +=                ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
	cTagsXml +=                ' xsi:schemaLocation="http://elips.johndeere.com/v1.0/ Elips_Types.xsd ">' + PULALINHA // Abre a tag tns

	cTagsXml +=                '<Location>' + PULALINHA // Abre a tag Location
	cTagsXml +=                   '<LocationID>' + cDealerAcc + '</LocationID>' + PULALINHA
	cTagsXml +=                   '<DBSIdentifier>TOTVS</DBSIdentifier>' + PULALINHA
	cTagsXml +=                   '<DBSVersion>PROTHEUS</DBSVersion>' + PULALINHA
	cTagsXml +=                   '<InterfaceVersion>' + 'V1' + '</InterfaceVersion>' + PULALINHA
	cTagsXml +=                   '<LanguageCode>PT</LanguageCode>' + PULALINHA

	cQuery := "SELECT VO1.VO1_NUMOSV, VO1.VO1_DATABE, VO1.VO1_HORABE, VO1.VO1_TPATEN, VO1.VO1_CHAINT,VO1.VO1_KILOME "
	cQuery += "FROM " + RetSqlName( "VO1" ) + " VO1 "
	cQuery += " JOIN " + RetSqlName( "VO2" ) + " VO2 "
	cQuery +=   " ON VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
	cQuery +=  " AND VO2.VO2_NUMOSV = VO1.VO1_NUMOSV "
	cQuery +=  " AND VO2.D_E_L_E_T_ = ' ' "

	if MV_PAR02 == 2
		cQuery +=  " AND ( VO2.VO2_DATALT BETWEEN '" + DtoS(dDtaIni) + "' AND '" + DtoS(dDtaFin) + "' "
		cQuery +=  			" OR EXISTS( SELECT NULL FROM " + RetSQLName("VO4") + " VO4 "
		cQuery +=  						" WHERE VO4.VO4_FILIAL = VO1.VO1_FILIAL "
		cQuery +=  							" AND VO4.VO4_NUMOSV = VO1.VO1_NUMOSV "
		cQuery +=  							" AND VO4.VO4_DATFEC BETWEEN '" + DtoS(dDtaIni) + "' AND '" + DtoS(dDtaFin) + "' "
		cQuery +=  							" AND VO4.D_E_L_E_T_ = ' ' )"
		cQuery +=  		" )"
	Else
		cQuery +=  " AND VO2.VO2_DATREQ BETWEEN '" + DtoS(dDtaIni) + "' AND '" + DtoS(dDtaFin) + "' "
	EndIf

	cQuery += "WHERE "
	cQuery +=  " VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND "
	cQuery +=  " VO1.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY VO1.VO1_NUMOSV, VO1.VO1_DATABE, VO1.VO1_HORABE, VO1.VO1_TPATEN, VO1.VO1_CHAINT,VO1.VO1_KILOME "

	TCQuery cQuery New Alias "TMPORD"

	While !TMPORD->(Eof())

		cTagsOS :=     '<WorkOrderNumber>'+ TMPORD->VO1_NUMOSV +'</WorkOrderNumber>' + PULALINHA

		If !Empty(TMPORD->VO1_CHAINT)
			cTagsOS += OA1600053_LevantaTagMachine(TMPORD->VO1_CHAINT,,,,,TMPORD->VO1_KILOME)
		EndIf
		
		cHora := Transform(Strzero(TMPORD->VO1_HORABE,4),"@R 99:99")+":00"

		cTagsOS += OA1600056_LevantaTagJob(	TMPORD->VO1_NUMOSV,;
											TMPORD->VO1_DATABE,;
											cHora,;
											if(TMPORD->VO1_TPATEN == "1","true","false"))

		If !Empty(cTagsOS) .and. At("<Job>",cTagsOS) > 0
			cTagsXml += '<WorkOrder>' + PULALINHA // Abre a tag WorkOrder
			cTagsXml += cTagsOS
			cTagsXml += '</WorkOrder>' + PULALINHA // Abre a tag WorkOrder
		EndIf

		lGeraLog := .t.

		FWRITE(nHdl,EncodeUtf8(cTagsXml))
		cTagsXml := ""

		TMPORD->(DbSkip())
	End

	TMPORD->(DbCloseArea())

	cQuery := "SELECT VS1_NUMNFI, VS1_SERNFI, VS1_CHAINT, F2_EMISSAO, F2_HORA, "
	cQuery += 		" F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA "
	cQuery += "FROM " + RetSqlName( "VS1" ) + " VS1 "
	cQuery += " JOIN " + RetSqlName( "SF2" ) + " SF2 "
	cQuery +=   " ON SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
	cQuery +=  " AND SF2.F2_DOC = VS1.VS1_NUMNFI "
	cQuery +=  " AND SF2.F2_SERIE = VS1.VS1_SERNFI "
	cQuery +=  " AND SF2.F2_CLIENTE = VS1.VS1_CLIFAT "
	cQuery +=  " AND SF2.F2_LOJA = VS1.VS1_LOJA "
	cQuery +=  " AND SF2.F2_EMISSAO BETWEEN '" + DtoS(dDtaIni) + "' AND '" + DtoS(dDtaFin) + "' "
	cQuery +=  " AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE "
	cQuery +=  " VS1.VS1_FILIAL = '" + xFilial("VS1") + "' AND "
	cQuery +=  " VS1.VS1_STATUS = 'X' AND "
	cQuery +=  " VS1.VS1_NUMNFI <> ' ' AND "
	cQuery +=  " VS1.D_E_L_E_T_ = ' ' "

	TCQuery cQuery New Alias "TMPORC"

	While !TMPORC->(Eof())

		cTagsOrc :=     '<InvoiceNumber>'+ Alltrim(TMPORC->VS1_NUMNFI+TMPORC->VS1_SERNFI) +'</InvoiceNumber>' + PULALINHA
		cTagsOrc +=     '<CreationTimestamp>'+ FWTimeStamp(3,StoD(TMPORC->F2_EMISSAO),Transform(TMPORC->F2_HORA,"@R 99:99")+":00") +'</CreationTimestamp>' + PULALINHA
		cTagsOrc +=     '<InvoiceTimestamp>' + FWTimeStamp(3,StoD(TMPORC->F2_EMISSAO),Transform(TMPORC->F2_HORA,"@R 99:99")+":00") +'</InvoiceTimestamp>' + PULALINHA
		
		If !Empty(TMPORC->VS1_CHAINT)
			cTagsOrc += OA1600053_LevantaTagMachine(TMPORC->VS1_CHAINT,;
													TMPORC->F2_DOC,;
													TMPORC->F2_SERIE,;
													TMPORC->F2_CLIENTE,;
													TMPORC->F2_LOJA )
		Else
			cTagsOrc += OA1600054_LevantaTagParts(	"B",;
													TMPORC->F2_DOC,;
													TMPORC->F2_SERIE,;
													TMPORC->F2_CLIENTE,;
													TMPORC->F2_LOJA,;
													"N")
		EndIf
		
		If !Empty(cTagsOrc) .and. At("<Part>",cTagsOrc) > 0
			cTagsXml += '<CounterSale>' + PULALINHA // Abre a tag CounterSale
			cTagsXml += cTagsOrc
			cTagsXml += '</CounterSale>' + PULALINHA // Abre a tag CounterSale
		EndIf

		lGeraLog := .t.

		FWRITE(nHdl,EncodeUtf8(cTagsXml))
		cTagsXml := ""

		TMPORC->(DbSkip())
	End

	TMPORC->(DbCloseArea())

	cQuery := "SELECT SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_DTDIGIT, SD1.D1_FORNECE , SD1.D1_LOJA "
	cQuery += " FROM " + RetSqlName("SD1") + " SD1 "
	cQuery += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
	cQuery +=  "AND SD1.D1_DTDIGIT BETWEEN '" + DtoS(dDtaIni) + "' AND '" + DtoS(dDtaFin) + "' "
	cQuery +=  "AND SD1.D_E_L_E_T_ = ' ' "

	if tcGetDb() == "ORACLE"
		cQuery +=  "AND SD1.D1_NFORI || SD1.D1_SERIORI IN ( "
		cQuery += "SELECT VS1_NUMNFI || VS1_SERNFI "
	Else
		cQuery +=  "AND SD1.D1_NFORI + SD1.D1_SERIORI IN ( "
		cQuery += "SELECT VS1_NUMNFI + VS1_SERNFI "
	EndIf

	cQuery += "FROM " + RetSqlName( "VS1" ) + " VS1 "
	cQuery += " JOIN " + RetSqlName( "SF2" ) + " SF2 "
	cQuery +=   " ON SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
	cQuery +=  " AND SF2.F2_DOC = VS1.VS1_NUMNFI "
	cQuery +=  " AND SF2.F2_SERIE = VS1.VS1_SERNFI "
	cQuery +=  " AND SF2.F2_CLIENTE = VS1.VS1_CLIFAT "
	cQuery +=  " AND SF2.F2_LOJA = VS1.VS1_LOJA "
	cQuery +=  " AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE "
	cQuery +=  " VS1.VS1_FILIAL = '" + xFilial("VS1") + "' AND "
	cQuery +=  " VS1.VS1_STATUS = 'X' AND "
	cQuery +=  " VS1.VS1_NUMNFI <> ' ' AND "
	cQuery +=  " VS1.D_E_L_E_T_ = ' ' "

	cQuery +=  " ) "
	cQuery +=  " GROUP BY SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_DTDIGIT, SD1.D1_FORNECE , SD1.D1_LOJA "

	TCQuery cQuery New Alias "TMPORC"

	While !TMPORC->(Eof())

		cTagsOrc :=     '<InvoiceNumber>'+ Alltrim(TMPORC->D1_DOC+TMPORC->D1_SERIE) +'</InvoiceNumber>' + PULALINHA
		cTagsOrc +=     '<CreationTimestamp>'+ FWTimeStamp(3,StoD(TMPORC->D1_DTDIGIT),Transform("00:00","@R 99:99")+":00") +'</CreationTimestamp>' + PULALINHA
		cTagsOrc +=     '<InvoiceTimestamp>' + FWTimeStamp(3,StoD(TMPORC->D1_DTDIGIT),Transform("00:00","@R 99:99")+":00") +'</InvoiceTimestamp>' + PULALINHA
		
		cTagsOrc += OA1600054_LevantaTagParts(	"B",;
												TMPORC->D1_DOC,;
												TMPORC->D1_SERIE,;
												TMPORC->D1_FORNECE,;
												TMPORC->D1_LOJA,;
												"S")
		
		If !Empty(cTagsOrc) .and. At("<Part>",cTagsOrc) > 0
			cTagsXml += '<CounterSale>' + PULALINHA // Abre a tag CounterSale
			cTagsXml += cTagsOrc
			cTagsXml += '</CounterSale>' + PULALINHA // Abre a tag CounterSale
		EndIf

		lGeraLog := .t.
		
		FWRITE(nHdl,EncodeUtf8(cTagsXml))
		cTagsXml := ""

		TMPORC->(DbSkip())
	End

	cTagsXml +=   '</Location>' + PULALINHA // Fecha a tag Location

	cTagsXml += '</tns:DealerOrg>' + PULALINHA // Fecha a tag tns

	FWRITE(nHdl,EncodeUtf8(cTagsXml))

	FClose(nHdl)
	Sleep(1) // Necessario sleep pois quando nao ha informacao o sistema estava tentando sobrescrever o arquivo

	TMPORC->(DbCloseArea())
	if FILE(cArqNovo)
		if Right(cArqNovo,5) == ".temp"
			Copy File &(cArqNovo) to &(cArq)
			iif (IsSrvUnix(),CHMOD( cArq , 7677,,.f. ),CHMOD( cArq , 2,,.f. ))
			iif (IsSrvUnix(),CHMOD( cArqNovo , 7677,,.f. ),CHMOD( cArqNovo , 2,,.f. ))
			FRenameEx(cArq , Left(cArq,Len(cArq)-5) + ".xml")
			Dele File &(cArqNovo)
		EndiF
	Endif

Next

Return

/*/
{Protheus.doc} OFIA160

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA1600059_LevantaGarantia(cNUMOSV)

Local cQuery    := ""
Local aRetGar   := {}

Default cNUMOSV := ""

INCLUI := .f.

cQuery := "SELECT * FROM " + RetSqlName("VMB") + " VMB "
cQuery += "WHERE "
cQuery += 	"VMB.VMB_FILIAL = '"+xFilial("VMB")+"' AND "
cQuery += 	"VMB.VMB_NUMOSV = '" + cNUMOSV + "' AND "
cQuery += 	"VMB.VMB_STATUS NOT IN ('  ','04','05') AND "
cQuery += 	"VMB.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY "
cQuery += 	"VMB.R_E_C_N_O_ DESC "

TCQuery cQuery New Alias "TMPVMB"

if !TMPVMB->(Eof())
	aAdd(aRetGar,{	.t.,;
					TMPVMB->VMB_CLAIM,;
					TMPVMB->VMB_MAQPAR,;
					TMPVMB->VMB_KEYPAR,;
					TMPVMB->VMB_FALHA,;
					AllTrim(OA1600016_RemoveCaracteresEspeciaisXML(E_MSMM(TMPVMB->VMB_QUEMEM,100000))),;
					AllTrim(OA1600016_RemoveCaracteresEspeciaisXML(E_MSMM(TMPVMB->VMB_CAUMEM,100000))),;
					AllTrim(OA1600016_RemoveCaracteresEspeciaisXML(E_MSMM(TMPVMB->VMB_CORMEM,100000))),;
					TMPVMB->VMB_DTACCS})
Else
	aAdd(aRetGar,{	.f.,;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					"",;
					""})
EndIf

TMPVMB->(DbCloseArea())

Return aRetGar

/*/
{Protheus.doc} OFIA160

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA1600105_Permissao(cAccount)

	Local lRetorno := .t.

	lRetorno := aScan( aAccPerm, { |x| x == cAccount } ) > 0

Return lRetorno

/*/
{Protheus.doc} OFIA160

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA1600115_DealerAccPermitidos()

	Local aRetorno := {}

	//AGRO BAGGIO MAQUINAS AGRICOLAS LTDA
	aAdd(aRetorno,'201030')
	aAdd(aRetorno,'201098')
	aAdd(aRetorno,'201245')
	aAdd(aRetorno,'201246')
	aAdd(aRetorno,'201293')
	aAdd(aRetorno,'201292')
	aAdd(aRetorno,'201352')
	aAdd(aRetorno,'201368')
	aAdd(aRetorno,'201454')
	aAdd(aRetorno,'201477')
	aAdd(aRetorno,'201503')

	//ALVORADA SISTEMAS AGRICOLAS LTDA
	aAdd(aRetorno,'201058')
	aAdd(aRetorno,'201079')
	aAdd(aRetorno,'201143')
	aAdd(aRetorno,'201209')
	aAdd(aRetorno,'201411')
	aAdd(aRetorno,'201457')
	aAdd(aRetorno,'201458')
	aAdd(aRetorno,'201324')
	aAdd(aRetorno,'201412')
	aAdd(aRetorno,'201459')

	//ASTER MAQUINAS E SOLUCOES INTEGRADAS LTDA
	aAdd(aRetorno,'201097')
	aAdd(aRetorno,'201038')
	aAdd(aRetorno,'201096')
	aAdd(aRetorno,'201095')
	aAdd(aRetorno,'201339')
	aAdd(aRetorno,'201210')
	aAdd(aRetorno,'201211')
	aAdd(aRetorno,'201239')
	aAdd(aRetorno,'201295')
	aAdd(aRetorno,'201323')
	aAdd(aRetorno,'201338')

	//CIARAMA MAQUINAS LTDA
	aAdd(aRetorno,'201104')
	aAdd(aRetorno,'201298')
	aAdd(aRetorno,'201374')
	aAdd(aRetorno,'201413')
	aAdd(aRetorno,'201421')
	aAdd(aRetorno,'201422')
	aAdd(aRetorno,'201464')

	//TERRAVERDE MÁQUINAS AGRICOLAS LTDA
	aAdd(aRetorno,'201212')
	aAdd(aRetorno,'201213')
	aAdd(aRetorno,'201290')
	aAdd(aRetorno,'201363')
	aAdd(aRetorno,'201418')
	aAdd(aRetorno,'201419')
	aAdd(aRetorno,'201426')
	aAdd(aRetorno,'201461')
	aAdd(aRetorno,'201462')

	//IGUAÇU MAQUINAS AGRICOLAS LTDA
	aAdd(aRetorno,'201010')
	aAdd(aRetorno,'201044')
	aAdd(aRetorno,'201099')
	aAdd(aRetorno,'201219')
	aAdd(aRetorno,'201294')
	aAdd(aRetorno,'201423')
	aAdd(aRetorno,'201424')
	aAdd(aRetorno,'201425')
	aAdd(aRetorno,'201452')
	aAdd(aRetorno,'201463')
	aAdd(aRetorno,'201486')
	aAdd(aRetorno,'201487')
	aAdd(aRetorno,'201488')

	aAdd(aRetorno,'201021')
	aAdd(aRetorno,'201094')
	aAdd(aRetorno,'201260')

	//UNIMAQ MAQUINAS AGRICOLAS LTDA
	aAdd(aRetorno,'201168')
	aAdd(aRetorno,'201169')
	aAdd(aRetorno,'201181')
	aAdd(aRetorno,'201354')
	aAdd(aRetorno,'201433')
	aAdd(aRetorno,'201558')
	aAdd(aRetorno,'201559')
	aAdd(aRetorno,'201561')
	aAdd(aRetorno,'201562')

	//GLOBAL TRATORES LTDA
	aAdd(aRetorno,'201056')
	aAdd(aRetorno,'201182')
	aAdd(aRetorno,'201299')
	
	// M FRIES & CIA LTDA
	aAdd(aRetorno,'201053')
	aAdd(aRetorno,'201274')
	aAdd(aRetorno,'201305')
	
	// SLC COMERCIAL DE MAQUINAS AGRICOLAS LTDA
	aAdd(aRetorno,'201007')
	aAdd(aRetorno,'201265')
	aAdd(aRetorno,'201266')
	aAdd(aRetorno,'201267')
	aAdd(aRetorno,'201268')
	aAdd(aRetorno,'201269')
	aAdd(aRetorno,'201270')
	aAdd(aRetorno,'201431')
	aAdd(aRetorno,'201429')
	aAdd(aRetorno,'201430')
	aAdd(aRetorno,'201484')
	aAdd(aRetorno,'201481')
	aAdd(aRetorno,'201483')
	aAdd(aRetorno,'201480')
	aAdd(aRetorno,'201479')
	aAdd(aRetorno,'201478')
	aAdd(aRetorno,'201485')
	aAdd(aRetorno,'201482')

	//HOHL MAQUINAS AGRICOLAS LTDA
	aAdd(aRetorno,'201037')
	aAdd(aRetorno,'201149')
	aAdd(aRetorno,'201222')
	aAdd(aRetorno,'201385')
	aAdd(aRetorno,'201318')

	//TREVISO MAQUINAS E IMPLEMENTOS AGRICOLAS LTDA
	aAdd(aRetorno,'201229')
	aAdd(aRetorno,'201193')
	aAdd(aRetorno,'201331')
	aAdd(aRetorno,'201206')
	aAdd(aRetorno,'201204')
	aAdd(aRetorno,'201276')
	aAdd(aRetorno,'201328')

	//COMID MAQUINAS LTDA
	aAdd(aRetorno,'201028')
	aAdd(aRetorno,'201400')

	//LAVORO MÁQUINAS AGRICOLAS LTDA
	aAdd(aRetorno,'201310')
	aAdd(aRetorno,'201311')
	aAdd(aRetorno,'201312')
	aAdd(aRetorno,'201327')
	aAdd(aRetorno,'201334')
	aAdd(aRetorno,'201335')
	aAdd(aRetorno,'201350')
	aAdd(aRetorno,'201466')

	//PRIMAVERA MAQ E IMPLEM AGRIC LTDA
	aAdd(aRetorno,'201221')
	aAdd(aRetorno,'201167')
	aAdd(aRetorno,'201264')
	aAdd(aRetorno,'201445')
	aAdd(aRetorno,'201341')
	aAdd(aRetorno,'201342')
	aAdd(aRetorno,'201467')
	aAdd(aRetorno,'201495')

	//TRANORTE SISTEMAS MECANIZADOS LTDA
	aAdd(aRetorno,'201125')
	aAdd(aRetorno,'201126')
	aAdd(aRetorno,'201127')

	//MINAS VERDE MAQUINAS LTDA
	aAdd(aRetorno,'201185')
	aAdd(aRetorno,'201186')
	aAdd(aRetorno,'201191')
	aAdd(aRetorno,'201203')
	aAdd(aRetorno,'201349')
	aAdd(aRetorno,'201233')
	aAdd(aRetorno,'201369')
	aAdd(aRetorno,'201456')

	//VERDESUL MAQUINAS AGRICOLAS LTDA
	aAdd(aRetorno,'201088')
	aAdd(aRetorno,'201336')
	aAdd(aRetorno,'201351')
	aAdd(aRetorno,'201280')

	//MAQNELSON AGRICOLA LTDA
	aAdd(aRetorno,'201171')
	aAdd(aRetorno,'201172')
	aAdd(aRetorno,'201173')
	aAdd(aRetorno,'201174')
	aAdd(aRetorno,'201175')
	aAdd(aRetorno,'201176')
	aAdd(aRetorno,'201177')
	aAdd(aRetorno,'201178')
	aAdd(aRetorno,'201179')
	aAdd(aRetorno,'201223')
	aAdd(aRetorno,'201224')
	aAdd(aRetorno,'201302')

	//D'CARVALHO
	aAdd(aRetorno,'201068')
	aAdd(aRetorno,'201124')
	aAdd(aRetorno,'201362')
	aAdd(aRetorno,'201301')
	aAdd(aRetorno,'201319')
	aAdd(aRetorno,'201390')

	//AGROSUL MAQUINAS
	aAdd(aRetorno,'201117')
	aAdd(aRetorno,'201114')
	aAdd(aRetorno,'201023')
	aAdd(aRetorno,'201201')
	aAdd(aRetorno,'201202')
	aAdd(aRetorno,'201417')
	aAdd(aRetorno,'201434')

	//PEMAGRI
	aAdd(aRetorno,'201065')
	aAdd(aRetorno,'201139')

	//LIPETRAL
	aAdd(aRetorno,'201101')
	aAdd(aRetorno,'201190')
	aAdd(aRetorno,'201261')
	aAdd(aRetorno,'201321')

	//MACPONTA
	aAdd(aRetorno,'201027')
	aAdd(aRetorno,'201116')
	aAdd(aRetorno,'201170')
	aAdd(aRetorno,'201343')
	aAdd(aRetorno,'201414')
	aAdd(aRetorno,'201415')
	aAdd(aRetorno,'201416')
	
	//AGRINORTE
	aAdd(aRetorno,'201112')
	aAdd(aRetorno,'201200')
	aAdd(aRetorno,'201230')
	aAdd(aRetorno,'201410')
	aAdd(aRetorno,'201555')
	aAdd(aRetorno,'201460')

	//COLORADO
	aAdd(aRetorno,'201077')
	aAdd(aRetorno,'201091')
	aAdd(aRetorno,'201110')
	aAdd(aRetorno,'201109')
	aAdd(aRetorno,'201051')
	aAdd(aRetorno,'201285')
	aAdd(aRetorno,'201287')
	aAdd(aRetorno,'201286')
	aAdd(aRetorno,'201284')
	aAdd(aRetorno,'201333')

	//MAQCAMPO
	aAdd(aRetorno,'201040')
	aAdd(aRetorno,'201119')
	aAdd(aRetorno,'201145')
	aAdd(aRetorno,'201232')
	aAdd(aRetorno,'201248')
	aAdd(aRetorno,'201353')
	aAdd(aRetorno,'201361')
	aAdd(aRetorno,'201439')
	aAdd(aRetorno,'201438')
	aAdd(aRetorno,'201437')
	aAdd(aRetorno,'201441')
	aAdd(aRetorno,'201435')
	aAdd(aRetorno,'201440')
	aAdd(aRetorno,'201436')
	aAdd(aRetorno,'201492')
	aAdd(aRetorno,'201494')
	
	//NORTH GREEN
	aAdd(aRetorno,'201189')

	//VENEZA MAQUINAS COMERCIO LTDA
	aAdd(aRetorno,'201237')
	aAdd(aRetorno,'201238')
	aAdd(aRetorno,'201275')
	aAdd(aRetorno,'201283')
	aAdd(aRetorno,'201375')
	aAdd(aRetorno,'201337')
	aAdd(aRetorno,'201373')
	aAdd(aRetorno,'201356')
	aAdd(aRetorno,'201359')
	aAdd(aRetorno,'201372')
	aAdd(aRetorno,'201404')
	aAdd(aRetorno,'201553')
	aAdd(aRetorno,'201489')
	aAdd(aRetorno,'201552')
	aAdd(aRetorno,'201556')
	aAdd(aRetorno,'201557')

	//SOLUCOES INTEGRADAS VERDES VALES LTDA
	aAdd(aRetorno, '201115')
	aAdd(aRetorno, '201140')
	aAdd(aRetorno, '201199')
	aAdd(aRetorno, '201253')
	aAdd(aRetorno, '201281')
	aAdd(aRetorno, '201282')
	aAdd(aRetorno, '201370')
	aAdd(aRetorno, '201407')
	aAdd(aRetorno, '201408')
	aAdd(aRetorno, '201446')
	aAdd(aRetorno, '201447')
	aAdd(aRetorno, '201448')
	aAdd(aRetorno, '201450')
	aAdd(aRetorno, '201443')
	aAdd(aRetorno, '201449')
	aAdd(aRetorno, '201469')
	aAdd(aRetorno, '201501')

	// TECNOSAFRA SISTEMAS MECANIZADOS LTDA
	aAdd(aRetorno, '201194')
	aAdd(aRetorno, '201197')
	aAdd(aRetorno, '201218')
	aAdd(aRetorno, '201215')
	aAdd(aRetorno, '201300')

	// NAPALHA COMERCIO E REPRESENTACOES LTDA
	aAdd(aRetorno, '201148')
	aAdd(aRetorno, '201251')
	aAdd(aRetorno, '201187')
	aAdd(aRetorno, '201304')

	//NISSEY MAQUINAS AGRICULAS LTDA
	aAdd(aRetorno, '201451')
	aAdd(aRetorno, '201165')
	aAdd(aRetorno, '201309')
	aAdd(aRetorno, '201403')
	aAdd(aRetorno, '201308')
	aAdd(aRetorno, '201402')
	aAdd(aRetorno, '201236')

	//MA MAQUINAS AGRICOLA LTDA
	aAdd(aRetorno, '201024')
	aAdd(aRetorno, '201025')
	aAdd(aRetorno, '201026')
	aAdd(aRetorno, '201087')
	aAdd(aRetorno, '201151')
	aAdd(aRetorno, '201241')
	aAdd(aRetorno, '201242')
	aAdd(aRetorno, '201243')
	aAdd(aRetorno, '201249')
	aAdd(aRetorno, '201252')
	aAdd(aRetorno, '201316')

	// COCAMAR MAQUINAS AGRICOLAS LTDA
	aadd(aRetorno, '201069')
	aadd(aRetorno, '201472')
	aadd(aRetorno, '201473')
	aadd(aRetorno, '201491')
	aadd(aRetorno, '201474')
	aadd(aRetorno, '201475')
	aadd(aRetorno, '201291')
	aadd(aRetorno, '201465')
	aadd(aRetorno, '201164')
	aadd(aRetorno, '201455')

	// ITAETE COMERCIO DE MAQ AGRICOLAS LTDA
	aadd(aRetorno, '201216')
	aadd(aRetorno, '201393')
	aadd(aRetorno, '201240')
	aadd(aRetorno, '201322')
	aadd(aRetorno, '201371')
	aadd(aRetorno, '201259')

	// MENEGARO COMERCIAL AGRICOLA LTDA
	aadd(aRetorno, '201120')
	aadd(aRetorno, '201162')

	// LAVRONORTE MAQUINAS LTDA
	aadd(aRetorno, '201012')
	aadd(aRetorno, '201195')
	aadd(aRetorno, '201257')
	aadd(aRetorno, '201258')
	aadd(aRetorno, '201453')
	aadd(aRetorno, '201496')

	// INOVA MAQUINAS LTDA
	aAdd(aRetorno, '201330')
	aAdd(aRetorno, '201364')
	aAdd(aRetorno, '201387')
	aAdd(aRetorno, '201497')

Return aRetorno

/*/
{Protheus.doc} OFIA160

@author Renato Vinicius
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

//Static Function CriaSX1(cPerg)
//
//	Local aRegs := {}
//	Local nOpcGetFil := GETF_RETDIRECTORY
//
//	AADD(aRegs,{"Local do Arquivo","Local do Arquivo","Local do Arquivo","MV_CH1","C",99,0,0,"G","!Vazio().or.(MV_PAR01:=cGetFile('Diretorio','',,,,128))","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",{"Informe o local que será gerado arquivo"},{},{}}) // Diretório
//	AADD(aRegs,{"Tipo de Geração" ,"Tipo de Geração" ,"Tipo de Geração" ,"MV_CH2","N",1 ,0,0,"C","","MV_PAR02","Init","","","","","Delta","","","","","","","","","","","","","","","","","","","","","","","",{"Informe o tipo de gerção"},{},{}}) // Tipo de geração do arquivo
//
//	FMX_AJSX1(cPerg,aRegs)
//
//Return

/*/{Protheus.doc} OA1600016_RemoveCaracteresEspeciaisXML
Remove caracteres especiais para geração do XML
@author Fernando Vitor Cavani
@since 14/08/2020
@version 1.0
@param  cValue - caracter - String a tratar
@return cValue - caracter - String tratada
/*/
Static Function OA1600016_RemoveCaracteresEspeciaisXML(cValue)
	Default cValue := ""

	cValue := StrTran(cValue, "&", "&amp;")
	cValue := StrTran(cValue, '"', "&quot;")
	cValue := StrTran(cValue, "<", "&lt;")
	cValue := StrTran(cValue, ">", "&gt;")
Return cValue
