// ÉÍÍÍÍÍÍÍÍËÍÍÍÍ»
// º Versao º 05 º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍ¼

#include "PROTHEUS.CH"
#include "OFIXDEF.CH"
#include "OFINJD23.CH"

#DEFINE A_JOBS             1
#DEFINE A_JOBS_SPEC        2
#DEFINE A_JOBS_GENE        3
#DEFINE A_JOBS_SPEC_TEMPAD 4
#DEFINE A_JOBS_SPEC_TEMINF 5
#DEFINE A_JOBS_GENE_TEMPAD 6
#DEFINE A_JOBS_GENE_TEMINF 7

#DEFINE B_HOURS_AVAILABLE 1
#DEFINE B_HOURS_WORKED    2	
#DEFINE B_HOURS_DELAY     3
#DEFINE B_HOURS_REWORK    4
#DEFINE B_HOURS_OVER      5
#DEFINE B_HOURS_OTHER     6

#DEFINE C_HOURS_SOLD   1
#DEFINE C_HOURS_WORKED 2

#DEFINE D_TOTAL 1
#DEFINE D_TOTALWIP 2
#DEFINE D_LABOR12 3
#DEFINE D_SERVICE12 4
#DEFINE D_AVG 5
#DEFINE D_AGED_LABOR 6
#DEFINE D_AGED_TOTAL 7

#define lDEBUG .T.

STATIC cSGBD := TcGetDb()

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  22/01/2018
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007273_1"


/*/{Protheus.doc} OFINJD23

Função responsável por criar o arquivo com informações do SMMANAGE

@author Rubens
@since 15/04/2015
@version 1.0

/*/
Function OFINJD23(xCodGar)

Local bProcess := { |oSelf| OFNJD23PROC(oSelf) }
Local oTProces
Private cPerg           := "OFINJD23"   // Pergunte 

Private lSchedule := FWGetRunSchedule()

If !lSchedule
	oTProces := tNewProcess():New(;
		"OFINJD23",;               // 01
		STR0001,;                  // 02
		bProcess,;                 // 03
		STR0002,;                  // 04
		cPerg ,;                   // 05
		/* aInfoCustom */ ,;       // 06
		.t. /* lPanelAux */ ,;     // 07
		/* nSizePanelAux */ ,;     // 08
		/* cDescriAux */ ,;        // 09
		.t. /* lViewExecute */ ,;  // 10
		.t. /* lOneMeter */ )      // 11
Else
	cData := DtoS(MonthSub(Date(),1))
	MV_PAR01 := Subs(cData,5,2) + "/" + Subs(cData,1,4)
	OFNJD23PROC()
EndIf
Return

Static Function OFNJD23PROC( oTProces )

Local cSQL := ""
Local cAliasPer := "TOFN23"
Local cDealer := AllTrim(GetMV("MV_MIL0005"))
Local cLinha := ""
Local cFiltro := Right(MV_PAR01,4) + Left(MV_PAR01,2)
Local aRec_A := { 0,0,0,0,0,0,0 }
Local aRec_B := { 0,0,0,0,0,0 }
Local aRec_C := { 0,0 }
Local aRec_D := { 0,0,0,0,0,0,0 }
Local aSrvc
Local nCont
Local nPosApont
Local oOficina
Local dDatIni := CtoD("01/" + Transform(MV_PAR01,"@R 99/9999"))
Local dDatFim := LastDate(dDatIni)
Local oSqlHlp := DMS_SqlHelper():New()

Local cDtAgedWIP := DtoS(dDatFim - 14)

Local aVOI := {}
Local nPosVOI

Local aSB2 := {}
Local nPosSB2

Local cDtIni12 := DtoS(FirstDate(CtoD("28/" + Left(MV_PAR01,2) + "/" + Str(Val(Right(MV_PAR01,4)) - 1,4)) + 6))
Local cDtFim12 := DtoS(dDatFim)

Local oServico := DMS_Servico():New()

Local cFiltroSQL
Local cFiltroVOK

//Local cSQLSrvcGar
Local aParametro

Local nTentativas := 0

Private aAuxOS := {}

Private cHeader := ""
Private cSrcAccount := ""
Private oFWriter

Private oExcel := IIF( lDEBUG ,  FWMSExcel():New() , .f. )

For nTentativas := 1 To 10
	Sleep(Randomize(1000, 5000))

	cNomeArq := "DLR2JD_" + StrZero(DAY(dDataBase),2) + UPPER(Left(cMonth(dDataBase),3)) + STR(Year(dDataBase),4) + "_" + SubStr(Time(),1,2) + SubStr(Time(),4,2) + SubStr(Time(),7,2) + ".DAT"
	cNomeArq := lower(AllTrim(MV_PAR02)) + IIf( !Right(AllTrim(MV_PAR02),1) $ "\/" , "\" , "" ) + UPPER(cNomeArq)
	oFWriter := FWFileWriter():New(cNomeArq , .t.)

	If !oFWriter:Create()
		If nTentativas == 10
			If !lSchedule
				MsgInfo(oFWriter:Error():Message)
			Else
				Conout("OFINJD23 - ERRO: "+oFWriter:Error():Message)
			EndIf
			Return
		EndIf
	Else
		Exit
	EndIf
Next

aParametro := { DtoC(dDatIni) + " - " + DtoC(dDatFim),;
				cNomeArq,;
				cEmpAnt,;
				cFilAnt,;
				Iif(lSchedule,"Sim","Não")}

OFNJD23DEBUG( "PARAMETRO" , { aParametro } )

oOficina := DMS_Oficina():New()
aRec_B[B_HOURS_AVAILABLE] := oOficina:GetHoras( dDatIni , dDatFim )
OFNJD23DEBUG( "ESCALA" , { oOficina } )

// Monta Filtro SQL para desconsiderar servicos de garantia especial 
//cSQLSrvcGar := OFNJD23SQL()
//

cFiltroVOK := " VOK_INCMOB IN ('" + TSER_MOBRAGRATUITA + "','" + TSER_MOBRA + "','" + TSER_VLLIVRE + "','" + TSER_RETORNO + "') "

cFiltroSQL := " VO4_DATFEC BETWEEN '" + cFiltro + "01' AND '" + cFiltro + "31' " + ;
				  " AND " + cFiltroVOK + ;
				  OFNJD23SQL("VO4")
/* 
Documentacao da Matriz a aRec_A
 -> [ 1 ] - Total invoiced jobs - The total number of jobs invoiced
 -> [ 2 ] - Total invoiced jobs with specific job codes - The total number of jobs invoiced that were assigned specific job codes
 -> [ 3 ] - Total invoiced jobs with general  job codes - The total number of jobs invoiced that were assigned general job codes
 -> [ 4 ] - Total invoiced jobs with specific job codes where the estimated hours were invoiced - The total number of jobs invoiced that were assigned specific job codes and where the hours invoiced equal the estimated hours
 -> [ 5 ] - Total invoiced jobs with specific job codes where the actual    hours were invoiced - The total number of jobs invoiced that had specific job codes and where the hours invoiced did not equal the estimated hours
 -> [ 6 ] - Total invoiced jobs with general  job codes where the estimated hours were invoiced - The total number of jobs invoiced that had general job codes and where the hours invoiced equal the estimated hours
 -> [ 7 ] - Total invoiced jobs with general  job codes where the actual    hours were invoiced - The total number of jobs invoiced that had general job codes and where the hours invoiced were not equal to the estimated hours
*/ 

OFNJD23DEBUG( "CABECSRVC" )

cSQL += "SELECT VO4.VO4_NUMOSV NUMOSV, VO1.VO1_CHAINT CHAINT "
cSQL +=  " FROM " + RetSQLName("VO4") + " VO4 "
cSQL +=  " JOIN " + RetSQLName("VO1") + " VO1 ON VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_NUMOSV = VO4.VO4_NUMOSV AND VO1.D_E_L_E_T_ = ' '"
cSQL += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
cSQL +=   " AND VO4.VO4_DATFEC BETWEEN '" + cFiltro + "01' AND '" + cFiltro + "31' "
cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"
cSQL += " GROUP BY VO4.VO4_NUMOSV, VO1.VO1_CHAINT"
If !lSchedule
	oTProces:SetRegua1( FM_SQL( "SELECT COUNT(*) FROM ( " + cSQL + " ) TEMP" ) )
EndIf
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasPer , .F., .T. )
While !(cAliasPer)->(Eof())

	ADDOS( (cAliasPer)->NUMOSV )
	
	aRowLog := Array(15)
	aFill(aRowLog,0)
	aRowLog[1] := (cAliasPer)->NUMOSV
	
	VOI->(dbSetOrder(1))

	If !lSchedule
		oTProces:IncRegua1( (cAliasPer)->NUMOSV )
	EndIf
	aSrvc := FMX_CALSER((cAliasPer)->NUMOSV,,,,.T.,.F.,.T.,.T.,.T.,.F.,, cFiltroSQL )
	For nCont := 1 to Len(aSrvc)
	
		aRec_A[A_JOBS]++
		
		VOI->(MsSeek( xFilial("VOI") + aSrvc[nCont,SRVC_TIPTEM] ) )
		
		If aSrvc[nCont,SRVC_INCTEM] == TSER_TPO_INFORMADO .or. aSrvc[nCont,SRVC_INCMOB] == TSER_MOBRAGRATUITA
			If oServico:cChaInt <> (cAliasPer)->CHAINT
				oServico:SetChassiInterno( (cAliasPer)->CHAINT )
			EndIf
			nTempoPadrao := oServico:GetTemPad( aSrvc[nCont,SRVC_CODSER] , aSrvc[nCont,SRVC_INCMOB] , aSrvc[nCont,SRVC_INCTEM] )
		Else
			nTempoPadrao := aSrvc[nCont,SRVC_TEMPAD]
		EndIf
		
		aRowLog[02] := aSrvc[nCont,SRVC_TIPTEM]
		aRowLog[03] := VOI->VOI_SITTPO
		aRowLog[04] := aSrvc[nCont,SRVC_CODSER]
		aRowLog[05] := aSrvc[nCont,SRVC_TIPSER]
		aRowLog[06] := aSrvc[nCont,SRVC_INCMOB]
		aRowLog[07] := aSrvc[nCont,SRVC_TEMPAD]
		aRowLog[08] := aSrvc[nCont,SRVC_TEMTRA]
		aRowLog[09] := aSrvc[nCont,SRVC_TEMCOB]
		aRowLog[10] := aSrvc[nCont,SRVC_TEMVEN]
		aRowLog[11] := aSrvc[nCont,SRVC_GENERICO]
		aRowLog[12] := nTempoPadrao
		aRowLog[15] := aSrvc[nCont,SRVC_INCTEM]

		
		If aSrvc[nCont,SRVC_GENERICO]
		
//			ADDOS( (cAliasPer)->NUMOSV + " " + aSrvc[nCont,SRVC_CODSER] + " " + " GENERICO ")
			
			aRec_A[A_JOBS_GENE]++
			
			If aSrvc[nCont,SRVC_TEMVEN] == nTempoPadrao
				ADDOS( (cAliasPer)->NUMOSV + " " + aSrvc[nCont,SRVC_CODSER] + " " + " GENERICO - TEMPAD " + Transform(aSrvc[nCont,SRVC_TEMVEN] , "@E 9999.99") + " - " + Transform(nTempoPadrao,"@E 9999.99") )
				aRec_A[A_JOBS_GENE_TEMPAD]++
			Else
				ADDOS( (cAliasPer)->NUMOSV + " " + aSrvc[nCont,SRVC_CODSER] + " " + " GENERICO - TEMINF " + Transform(aSrvc[nCont,SRVC_TEMVEN] , "@E 9999.99") + " - " + Transform(nTempoPadrao,"@E 9999.99") )
				aRec_A[A_JOBS_GENE_TEMINF]++
			EndIf
			
		Else
		
//			ADDOS( (cAliasPer)->NUMOSV + " " + aSrvc[nCont,SRVC_CODSER] + " " + " ESPECIFICO ")
			
			aRec_A[A_JOBS_SPEC]++
			
			If aSrvc[nCont,SRVC_TEMVEN] == nTempoPadrao
				ADDOS( (cAliasPer)->NUMOSV + " " + aSrvc[nCont,SRVC_CODSER] + " " + " ESPECIFICO - TEMPAD " + Transform(aSrvc[nCont,SRVC_TEMVEN] , "@E 9999.99") + " - " + Transform(nTempoPadrao,"@E 9999.99") )
				aRec_A[A_JOBS_SPEC_TEMPAD]++
			Else
				ADDOS( (cAliasPer)->NUMOSV + " " + aSrvc[nCont,SRVC_CODSER] + " " + " ESPECIFICO - TEMINF " + Transform(aSrvc[nCont,SRVC_TEMVEN] , "@E 9999.99") + " - " + Transform(nTempoPadrao,"@E 9999.99") )
				aRec_A[A_JOBS_SPEC_TEMINF]++
			EndIf

		EndIf

		aRec_B[ B_HOURS_OVER ] += IIf( aSrvc[nCont,SRVC_TEMTRA] > nTempoPadrao , aSrvc[nCont,SRVC_TEMTRA] - nTempoPadrao , 0 )
		If aSrvc[nCont,SRVC_TEMTRA] > nTempoPadrao
			ADDOS( (cAliasPer)->NUMOSV + " " + aSrvc[nCont,SRVC_CODSER] + " " + " HOURS OVER - TEMTRA " + Transform(aSrvc[nCont,SRVC_TEMTRA] , "@E 9999.99") + " - " + Transform(nTempoPadrao,"@E 9999.99") )
		EndIf
		
		aRec_B[ B_HOURS_WORKED ] += aSrvc[nCont,SRVC_TEMTRA]
		aRec_B[ B_HOURS_REWORK ] += IIf( aSrvc[nCont,SRVC_INCMOB] == TSER_RETORNO , aSrvc[nCont,SRVC_TEMTRA] , 0 )
		
		If VOI->VOI_SITTPO == TT_TPO_INTERNO .or. aSrvc[nCont,SRVC_INCMOB] == TSER_MOBRAGRATUITA
//			aRec_B[ B_HOURS_OTHER ] += aSrvc[nCont,SRVC_TEMCOB]
			aRec_B[ B_HOURS_OTHER ] += aSrvc[nCont,SRVC_TEMVEN]
		EndIf
		
//		If /* VOI->VOI_SITTPO == TT_TPO_PUBLICO .and. */ ( aSrvc[nCont,SRVC_INCMOB] <> TSER_MOBRAGRATUITA .and. aSrvc[nCont,SRVC_INCMOB] <> TSER_RETORNO )
		If VOI->VOI_SITTPO <> TT_TPO_INTERNO .and. ( aSrvc[nCont,SRVC_INCMOB] <> TSER_MOBRAGRATUITA .and. aSrvc[nCont,SRVC_INCMOB] <> TSER_RETORNO )
			//somente o que gera receita financeira
			//nao considera retrabalho
//			aRec_C[ C_HOURS_SOLD   ] += aSrvc[ nCont , SRVC_TEMCOB ]
			aRec_C[ C_HOURS_SOLD   ] += aSrvc[ nCont , SRVC_TEMVEN ]
			
			aRowLog[13] := aSrvc[ nCont , SRVC_TEMVEN ]
			
			
		EndIf
		
//		If /* VOI->VOI_SITTPO == TT_TPO_PUBLICO .and. */ aSrvc[nCont,SRVC_INCMOB] <> TSER_MOBRAGRATUITA 
//		If VOI->VOI_SITTPO == TT_TPO_PUBLICO .and. aSrvc[nCont,SRVC_INCMOB] <> TSER_MOBRAGRATUITA
		If VOI->VOI_SITTPO <> TT_TPO_INTERNO .and. aSrvc[nCont,SRVC_INCMOB] <> TSER_MOBRAGRATUITA 
			//Total hours worked on invoiced retail job types, excluding delay hours and other (non-revenue) hours
			//considera retrabalho
			aRec_C[ C_HOURS_WORKED ] += aSrvc[ nCont , SRVC_TEMTRA ]
			
			ADDOS( (cAliasPer)->NUMOSV + " " + aSrvc[nCont,SRVC_CODSER] + " - " + Str(aSrvc[ nCont , SRVC_TEMTRA ],10) )
			
			aRowLog[14] := aSrvc[ nCont , SRVC_TEMTRA ]
			
		EndIf
		
		If aScan( aSrvc[nCont, SRVC_APONT],{ |X| !Empty(x[SRVC_APONT_MPAUSA]) }) <> 0
			
			cProdutivo := aSrvc[ nCont, SRVC_APONT , 1 , SRVC_APONT_CODIGO ]
			lPausa := .f.
			For nPosApont := 1 to Len( aSrvc[ nCont, SRVC_APONT ] )
				
				If cProdutivo <> aSrvc[ nCont, SRVC_APONT , nPosApont , SRVC_APONT_CODIGO ]
					lPausa := .f.
				Else
					If lPausa
						aRec_B[ B_HOURS_DELAY ] += oOficina:FindProdutivo( aSrvc[ nCont, SRVC_APONT , nPosApont , SRVC_APONT_CODIGO ] ):TempoTrab(;
																							dDataInicio, ;
																							nHoraInicio, ;
																							aSrvc[ nCont, SRVC_APONT , nPosApont , SRVC_APONT_DATINI ], ;
																							aSrvc[ nCont, SRVC_APONT , nPosApont , SRVC_APONT_HORINI ])
						lPausa := .f.
					EndIf
				EndIf
					
				If !Empty( aSrvc[ nCont , SRVC_APONT , nPosApont , SRVC_APONT_MPAUSA ] )
					lPausa := .t.
					dDataInicio := aSrvc[ nCont,  SRVC_APONT , nPosApont , SRVC_APONT_DATFIN ]
					nHoraInicio := aSrvc[ nCont,  SRVC_APONT , nPosApont , SRVC_APONT_HORFIN ]
				EndIf
			Next nPosApont
		EndIf
		
		
		OFNJD23DEBUG( "SRVC" , { aRowLog } )
		
	Next nCont
	(cAliasPer)->(dbSkip())
End
(cAliasPer)->(dbCloseArea())

//cFilINCMOB := (TSER_MOBRAGRATUITA + TSER_MOBRA + TSER_VLLIVRE + TSER_RETORNO)

VOI->(dbSetOrder(1))
SB2->(dbSetOrder(1))

//Valores não faturadoes, devem considerar todas as OSs abertas, independente da data de requisicao/liberacao ...
//os nao faturadas = os liberadas e em aberto 
cSQL := "SELECT NUMOSV, MAX(DATFIN) DATFIN, MAX(SRVC) SRVC, MAX(PECA) PECA "
cSQL += " FROM ( "
cSQL += "SELECT VO4.VO4_NUMOSV NUMOSV, MAX(VO4.VO4_DATDIS) DATFIN, 1 SRVC, 0 PECA "
cSQL +=  " FROM " + RetSQLName("VO4") + " VO4 "
cSQL +=  " JOIN " + RetSQLName("VO1") + " VO1 ON VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_NUMOSV = VO4.VO4_NUMOSV AND VO1.D_E_L_E_T_ = ' ' AND VO1.VO1_STATUS <> 'C'"
cSQL +=  " JOIN " + RetSQLName("VOK") + " VOK ON VOK.VOK_FILIAL = '" + xFilial("VOK") + "' AND VOK.VOK_TIPSER = VO4.VO4_TIPSER AND VOK." + cFiltroVOK + " AND VOK.D_E_L_E_T_ = ' ' "
cSQL += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
cSQL +=   " AND (VO4.VO4_DATFEC = '        ' OR VO4.VO4_DATFEC > '" + DtoS(dDatFim) + "')"
cSQL +=   " AND VO4.VO4_DATDIS <= '" + DtoS(dDatFim) + "'"
cSQL +=   " AND VO4.VO4_DATCAN = '        '"
cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"
cSQL +=    OFNJD23SQL("VO4")
cSQL += " GROUP BY VO4.VO4_NUMOSV "
cSQL += " UNION "
cSQL += "SELECT VO3.VO3_NUMOSV NUMOSV, MAX(VO3.VO3_DATDIS) DATFIN, 0 SRVC, 1 PECA "
cSQL +=  " FROM " + RetSQLName("VO3") + " VO3 "
cSQL +=  " JOIN " + RetSQLName("VO1") + " VO1 ON VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1.VO1_NUMOSV = VO3.VO3_NUMOSV AND VO1.D_E_L_E_T_ = ' ' AND VO1.VO1_STATUS <> 'C'"
cSQL += " WHERE VO3.VO3_FILIAL = '" + xFilial("VO3") + "'"
cSQL +=   " AND (VO3.VO3_DATFEC = '        ' OR VO3.VO3_DATFEC > '" + DtoS(dDatFim) + "')"
cSQL +=   " AND VO3.VO3_DATDIS <= '" + DtoS(dDatFim) + "'"
cSQL +=   " AND VO3.VO3_DATCAN = '        '"
cSQL +=   " AND VO3.D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY VO3.VO3_NUMOSV ) " + IIf( "ORACLE" $ cSGBD , "" , " AS TEMP " )
cSQL += "GROUP BY NUMOSV "
cSQL += "ORDER BY 2,1"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasPer , .F., .T. )
While !(cAliasPer)->(Eof())

	nCustSrvc := 0
	nCustPeca := 0

	If (cAliasPer)->SRVC == 1
		aSrvc := FMX_CALSER(;
			(cAliasPer)->NUMOSV,;
			,;
			,;
			,;
			.t.,; // lApont
			.f.,; // lNegoc
			.t.,; // lRetAbe
			.t.,; // lRetLib
			.t.,; // lRetFec
			.f.,; // lRetCan
			,;
			" ( ( VO4.VO4_DATFEC = '        ' OR VO4.VO4_DATFEC > '" + DtoS(dDatFim) + "') " + ;
			" AND VO4.VO4_DATDIS <= '" + DtoS(dDatFim) + "'" + ;
			" AND VOK." + cFiltroVOK + " )" + ;
			OFNJD23SQL("VO4") )
		For nCont := 1 to Len(aSrvc)
			cProdutivo := ""
			For nPosApont := 1 to Len(aSrvc[nCont,SRVC_APONT])
				If !aSrvc[nCont,SRVC_APONT,nPosApont,SRVC_APONT_CODIGO] $ cProdutivo // O produtivo so deve ser considerado uma vez ...
					nCustSrvc += ( aSrvc[nCont,SRVC_TEMVEN] / 100 ) * aSrvc[nCont,SRVC_APONT,nPosApont,SRVC_APONT_CUSHOR]
					cProdutivo += aSrvc[nCont,SRVC_APONT,nPosApont,SRVC_APONT_CODIGO]
				EndIf
			Next nPosApont
		Next nCont

		aRec_D[D_TOTAL] += nCustSrvc
		aRec_D[D_TOTALWIP] += nCustSrvc
		If (cAliasPer)->DATFIN < cDtAgedWIP .and. !Empty((cAliasPer)->DATFIN)
			ADDOS( "AD - " + (cAliasPer)->NUMOSV + " WIP")
			aRec_D[D_AGED_LABOR] += nCustSrvc
			aRec_D[D_AGED_TOTAL] += nCustSrvc
		EndIf
		
	EndIf
	
	If (cAliasPer)->PECA == 1
		aPeca := FMX_CALPEC(;
			(cAliasPer)->NUMOSV,;
			,;
			,;
			,;
			.f.,; // lMov
			.f.,; // lNegoc
			.f.,; // lReqZerada
			.t.,; // lRetAbe
			.t.,; // lRetLib
			.t.,; // lRetFec
			.f.,; // lRetCan
			,;
			" ( ( VO3.VO3_DATFEC = '        ' OR VO3.VO3_DATFEC > '" + DtoS(dDatFim) + "') " + ;
			" AND VO3.VO3_DATDIS <= '" + DtoS(dDatFim) + "' )" ,;
			.f.,;
			.f.)
		For nCont := 1 to Len(aPeca)
			If (nPosVOI := aScan(aVOI,{ |x| x[1] == aPeca[nCont,PECA_TIPTEM] })) == 0
				VOI->(DBSeek(xFilial("VOI") + aPeca[nCont,PECA_TIPTEM] ))
				AADD( aVOI , { VOI->VOI_TIPTEM , VOI->VOI_CODALM } )
				nPosVOI := Len(aVOI)
			EndIf
			If (nPosSB2 := aScan(aSB2,{ |x| x[1] == aPeca[nCont,PECA_GRUITE] + aPeca[nCont,PECA_CODITE] + aVOI[nPosVOI,2] }) ) == 0
				
				cSQL := "SELECT B2_CM1"
				cSQL +=  " FROM " + RetSQLName("SB1") + " SB1 "
				cSQL +=  " JOIN " + RetSQLName("SB2") + " SB2 ON SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB2.B2_COD = SB1.B1_COD AND SB2.B2_LOCAL = '" + aVOI[nPosVOI,2] + "' AND SB2.D_E_L_E_T_ = ' '"
				cSQL += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
				cSQL +=   " AND SB1.B1_GRUPO = '" + aPeca[nCont,PECA_GRUITE] + "'"
				cSQL +=   " AND SB1.B1_CODITE = '" + aPeca[nCont,PECA_CODITE] + "'"
				cSQL +=   " AND SB1.D_E_L_E_T_ = ' '"
				
				AADD( aSB2 , { aPeca[nCont,PECA_GRUITE] + aPeca[nCont,PECA_CODITE] + aVOI[nPosVOI,2] , FM_SQL(cSQL) } )
				nPosSB2 := Len(aSB2)
			EndIf
			
			nCustPeca += aPeca[nCont, PECA_QTDREQ ] * aSB2[ nPosSB2 , 2 ]
		Next nCont
		
		aRec_D[D_TOTALWIP] += nCustPeca
		If (cAliasPer)->DATFIN < cDtAgedWIP .and. !Empty((cAliasPer)->DATFIN)
			ADDOS( "AD - " + (cAliasPer)->NUMOSV + " WIP")
			aRec_D[D_AGED_TOTAL] += nCustPeca
		EndIf

	EndIf
	
	If nCustSrvc <> 0 .or. nCustPeca <> 0
		ADDOS( "AD - " + (cAliasPer)->NUMOSV )
	EndIf
	
	(cAliasPer)->(dbSkip())
	
End
(cAliasPer)->(dbCloseArea())

// Custos dos servicos dos ultimos 12 meses 
cSQL := " SELECT SUM(( ROUND(( FILTRO.PRO_TEMPRA / FILTRO.TOT_TEMTRA ) * FILTRO.VSC_TEMVEN, 0 ) / 100 ) * FILTRO.VAI_CUSTHR ) CUSTO " 
cSQL +=  " FROM ("
cSQL +=          " SELECT DISTINCT VSC_NUMOSV, VSC_GRUSER, VSC_CODSER, VSC_CODPRO, VAI_CUSTHR, VSC_TEMVEN, "
cSQL +=              " ( SELECT SUM( VSC_TEMTRA ) SUMTEMTRA "
cSQL +=                  " FROM " + RetSQLName("VSC") + " TEMP "
cSQL +=                 " WHERE TEMP.VSC_FILIAL = '" + xFilial("VSC") + "'"
cSQL +=                   " AND TEMP.VSC_NUMOSV = VSC.VSC_NUMOSV "
cSQL +=                   " AND TEMP.VSC_GRUSER = VSC.VSC_GRUSER "
cSQL +=                   " AND TEMP.VSC_CODSER = VSC.VSC_CODSER "
cSQL +=                   " AND TEMP.VSC_LIBVOO = VSC.VSC_LIBVOO "
cSQL +=                   " AND TEMP.VSC_CODPRO = VSC.VSC_CODPRO "
cSQL +=                   " AND TEMP.D_E_L_E_T_ = ' ' "
cSQL +=              " ) PRO_TEMPRA,"
cSQL +=              "( SELECT SUM( VSC_TEMTRA ) SUMTEMTRA "
cSQL +=                  " FROM " + RetSQLName("VSC") + " TEMP "
cSQL +=                 " WHERE TEMP.VSC_FILIAL = '" + xFilial("VSC") + "'"
cSQL +=                   " AND TEMP.VSC_NUMOSV = VSC.VSC_NUMOSV "
cSQL +=                   " AND TEMP.VSC_GRUSER = VSC.VSC_GRUSER "
cSQL +=                   " AND TEMP.VSC_CODSER = VSC.VSC_CODSER "
cSQL +=                   " AND TEMP.VSC_LIBVOO = VSC.VSC_LIBVOO "
cSQL +=                   " AND TEMP.D_E_L_E_T_ = ' ' "
cSQL +=              " ) TOT_TEMTRA "
cSQL +=              " FROM " + RetSQLName("VSC") + " VSC "
cSQL +=                     " JOIN " + RetSQLName("VOK") + " VOK ON VOK.VOK_FILIAL = '" + xFilial("VOK") + "' AND VOK.VOK_TIPSER = VSC.VSC_TIPSER AND VOK." + cFiltroVOK + " AND VOK.D_E_L_E_T_ = ' ' "
cSQL +=                     " JOIN " + RetSQLName("VAI") + " VAI ON VAI.VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI.VAI_CODTEC = VSC.VSC_CODPRO AND VAI.D_E_L_E_T_ = ' ' "
cSQL +=             " WHERE VSC.VSC_FILIAL = '" + xFilial("VSC") + "'"
cSQL +=               " AND VSC.VSC_DATVEN BETWEEN '" + cDtIni12 + "' AND '" + cDtFim12 + "' "
cSQL +=               " AND VSC.D_E_L_E_T_ = ' '"
cSQL +=               OFNJD23SQL("VSC")
cSQL +=             " ) FILTRO WHERE FILTRO.TOT_TEMTRA > 0 "
aRec_D[D_LABOR12] := FM_SQL(cSQL)
aRec_D[D_SERVICE12] := aRec_D[D_LABOR12]
// 
cSQL := "SELECT SUM( D2_CUSTO1 ) "
cSQL +=  " FROM ("
cSQL +=        " SELECT DISTINCT VEC_SERNFI SERIE, VEC_NUMNFI DOC "
cSQL +=         " FROM " + RetSQLName("VEC") + " VEC "
cSQL +=        " WHERE VEC.VEC_FILIAL = '" + xFilial("VEC") + "'"
cSQL +=          " AND VEC.VEC_DATVEN BETWEEN '" + cDtIni12 + "' AND '" + cDtFim12 + "' "
cSQL +=          " AND VEC.VEC_NUMORC = ' '"
cSQL +=          " AND VEC.VEC_NUMOSV <> ' '"
cSQL +=          " AND VEC.D_E_L_E_T_ = ' ') FILTRO "
cSQL += " JOIN " + RetSQLName("SD2") + " SD2 ON SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SD2.D2_SERIE = FILTRO.SERIE AND SD2.D2_DOC = FILTRO.DOC AND SD2.D_E_L_E_T_ = ' ' "
aRec_D[D_SERVICE12] += FM_SQL(cSQL)

// Media de dias entre o ultimo apontamento e a data de fechamento da OS
cSQL := "SELECT AVG(" + oSqlHlp:DateDiff("VO4_DATFIN","VO4_DATFEC") + " ) MEDIA"
cSQL += " FROM ( "
//cSQL += " SELECT VO4_NUMOSV, VO4_TIPTEM, VO4_LIBVOO, TO_DATE(MAX( VO4_DATFIN ), 'YYYYMMDD') VO4_DATFIN, TO_DATE(VO4_DATFEC,'YYYYMMDD') VO4_DATFEC "
cSQL += " SELECT VO4_NUMOSV, VO4_TIPTEM, VO4_LIBVOO, "
cSQL += oSqlHlp:ConvToDate("MAX( VO4_DATFIN )", "VO4_DATFIN", "YYYYMMDD" ) + ", "
cSQL += oSqlHlp:ConvToDate("MAX( VO4_DATFEC )", "VO4_DATFEC", "YYYYMMDD" ) + "  "
cSQL +=   " FROM " + RetSQLName("VO4") + " VO4 "
cSQL +=  " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
cSQL +=    " AND VO4.VO4_DATFEC BETWEEN '" + cFiltro + "01' AND '" + cFiltro + "31' "
cSQL +=    " AND VO4.VO4_DATFIN <> '        '"
cSQL +=    " AND D_E_L_E_T_ = ' '"
cSQL +=    OFNJD23SQL("VO4")
cSQL += " GROUP BY VO4_NUMOSV, VO4_TIPTEM, VO4_LIBVOO, VO4_DATFEC )" + IIf( "ORACLE" $ cSGBD , "" , " AS TEMP " )
aRec_D[D_AVG] := FM_SQL(cSQL)
//


/*/
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111111111111111111111111
000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999000000000011111111112222222222333
         1         2         3         4         5         6         7         8         9        10        11        12        13
123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

AA
                            29    35    41    47    53    59    65    71
x  xx    x  xxxx   xx xxxx  xxxxxx      xxxxxx      xxxxxx      xxxxxx        xx]
A20001171A062015   20P11710100000300000300000000000300000000000000000020150630  ]
A20001171A062015   20P11710100000600000600000000000400000200000000000020150630  
A20001171A062015   20P11710100000600000300000300000300000000000100000220150630  
A20001171A062015   20P11710100000700000400000300000300000100000100000220150630

AB
          11              27    33    39    45    21
x  xx    x      xxx  x    xxxxxx      xxxxxx      xxxxx                         ]
A20001171B002392   20P117100002800000200000100001400002                         

x  xx    x      xxx  x    xxxxxx                                                ]
A20001171C000550   20P1171001100                                                ]
A20001171C000000   20P1171002360                                                

          11              27      35       44       53  57      65
x  xx    x        x  x    xxxxxxxx         xxxxxxxxx    xxxxxxxx        xxxxxxxx]
A20001171D00029700 20P11710000010800258520000265848500000000000000000000        
A20001171D00029700 20P11710000010800002585200009913700000000000000000000        

000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111111111111111111111111
000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999000000000011111111112222222222333
123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
*/
cHeader += "A"							// 1     | 1 | Fixo “A”
cHeader += Left(cDealer,2)			// 2-3   | 2 | Main account 1-2      - First two bytes of the main DTF/poll account
cHeader += "00"						// 4-5   | 2 | Fixo “00”
cHeader += Right(cDealer,4)		// 6-9   | 4 | Main account 3-6 Last four bytes of the main DTF/poll account

cSrcAccount += Left(cDealer,2)			// 20-21 | 2 | Source account 1-2 First two bytes of the source account
cSrcAccount += "P"							// 22    | 1 | Fixo “P”
cSrcAccount += Right(cDealer,4)			// 23-26 | 4 | Source account 3-6 - Last four bytes of the source account

// Registro AA - Standard Job Pricing Performance
cLinha += "A"							// 10    | 1 | Record ID - Static value "A"
cLinha += Left(MV_PAR01,2)			// 11-12 | 2 | Numeric Reported Month The calendar month being reported
cLinha += Right(MV_PAR01,4)		// 13-16 | 4 | Numeric Reported Year The calendar year being reported
cLinha += Space(3)					// 17-19 | 3 | Filler Static value M N Spaces
cLinha += cSrcAccount
cLinha += "01"							// 27-28 | 2 | Version - Static value - "01"
cLinha += StrZero(aRec_A[A_JOBS],6)						// 29-34 | 6 | Total invoiced jobs - Quantidade de linhas de serviços lançadas nas OS 
cLinha += StrZero(aRec_A[A_JOBS_SPEC],6)				// 35-40 | 6 | Total invoiced jobs with specific job codes - Quantidade de linhas de serviços lançadas nas OS, serviços que estão na tabela de tempo padrão de reparo.
cLinha += StrZero(aRec_A[A_JOBS_GENE],6)				// 41-46 | 6 | Total invoiced jobs with general job codes  - Quantidade de linhas de serviços lançadas nas OS, serviços fora da tabela de tempo padrão de reparo.
cLinha += StrZero(aRec_A[A_JOBS_SPEC_TEMPAD],6)		// 47-52 | 6 | Total invoiced jobs with specific job codes where the estimated hours were invoiced - Quantidade de linhas de serviços lançadas nas OS, serviços que estão na tabela de tempo padrão de reparo, cujo tempo padrão é igual ao tempo vendido ao cliente.
cLinha += StrZero(aRec_A[A_JOBS_SPEC_TEMINF],6)		// 53-58 | 6 | Total invoiced jobs with specific job codes where the actual hours were invoiced    - Quantidade de linhas de serviços lançadas nas OS, serviços que estão na tabela de tempo padrão de reparo, cujo tempo padrão é diferente do tempo vendido ao cliente.
cLinha += StrZero(aRec_A[A_JOBS_GENE_TEMPAD],6)		// 59-64 | 6 | Total invoiced jobs with general job codes where the estimated hours were invoiced  - Quantidade de linhas de serviços lançadas nas OS, serviços fora da tabela de tempo padrão de reparo, cujo tempo padrão é igual ao tempo vendido ao cliente.
cLinha += StrZero(aRec_A[A_JOBS_GENE_TEMINF],6)		// 65-70 | 6 | Total invoiced jobs with general job codes where the actual hours were invoiced     - Quantidade de linhas de serviços lançadas nas OS, serviços fora da tabela de tempo padrão de reparo, cujo tempo padrão é diferente do tempo vendido ao cliente (Daniele Martinatti -  Melhorar a definição do tipo de serviço para determiner se o serviço é Generico ou Especifico. Focar no cadastro do tipo de serviço.).
cLinha += DtoS(dDatFim)				// 71-78 | 8 | The date of this data snapshot - Último dia útil do mês para o revendedor YYYYMMDD
cLinha += "  "							// 79-80 | 2 | Filler
OFNJD23ESCREVE(@cLinha,.t.)
OFNJD23DEBUG("RECA", {aRec_A})

// Registro AB - Service Sales Performance
cLinha += "B"																			// 10    |  1 | Record ID - Static value - "B" 
cLinha += StrZero( Round( aRec_B[ B_HOURS_AVAILABLE] / 100 , 0 ) ,6)	// 11-16 |  6 | Total de horas disponíveis para trabalho, já descontadas as horas improdutivas. (Vacation, sick time, holidays, etc should be excluded from this)
cLinha += Space(3)																	// 17-19 |  3 | Filler - Static value - Spaces
cLinha += cSrcAccount
cLinha += StrZero( Round( aRec_B[ B_HOURS_WORKED   ] / 100 , 0 ) ,6)	// 27-32 |  6 | Total de horas trabalhadas e apontadas em trabalhos faturados.
cLinha += StrZero( Round( aRec_B[ B_HOURS_DELAY    ] / 100 , 0 ) ,6)	// 33-38 |  6 | Soma de todos os tempos de parada de serviços por falta de peças, e outros motivos técnicos a serem informados pela JD.. Verificar outros tipos de parada de serviços e enviar para seleção. enviar para JD para seleção listar
cLinha += StrZero( Round( aRec_B[ B_HOURS_REWORK   ] / 100 , 0 ) ,6)	// 39-44 |  6 | Total de horas trabalhadas e apontadas em OS de retrabalho.
cLinha += StrZero( Round( aRec_B[ B_HOURS_OVER     ] / 100 , 0 ) ,6)	// 45-50 |  6 | Total de horas trabalhadas e apontadas em trabalhos faturados, que excederam o tempo padrão.
cLinha += StrZero( Round( aRec_B[ B_HOURS_OTHER    ] / 100 , 0 ) ,5)	// 51-55 |  5 | Total de horas trabalhadas em OS internas
cLinha += Space(25)										// 56-80 | 25 | Filler
OFNJD23ESCREVE(@cLinha,.t.)
OFNJD23DEBUG("RECB", {aRec_B})

// Registro AC - Operating Performance
cLinha += "C"																	// 10    |  1  | Record ID - Static value - "C"
cLinha += StrZero( Round( aRec_C[C_HOURS_SOLD] / 100 , 0 ) ,6)	// 11-16 |  6  | Total de horas faturadas a cliente ( Total hours invoiced on retail job types, excluding rework )
cLinha += Space(3)															// 17-19 |  3  | Filler
cLinha += cSrcAccount
cLinha += StrZero( Round( aRec_C[C_HOURS_WORKED]  / 100 , 0 ) ,6)	// 27-32 |  6  | Total de horas trabalhadas em serviços faturados ao cliente ( Total hours worked on invoiced retail job types, excluding delay hours and other (non-revenue) hours )
cLinha += Space(48)															// 33-80 | 48  | Filler
OFNJD23ESCREVE(@cLinha,.t.)
OFNJD23DEBUG("RECC", {aRec_C})

// Registro AD - WIP Performance
// x  xx    x        x  x    xxxxxxxx         xxxxxxxxx    xxxxxxxx        xxxxxxxx]
// A20001171D00088300 20P11710000002900000000000001826200030000000000000000        
cLinha += "D"																// 10    | 1 | Record ID - Static value - "D"
//cLinha += StrTran(StrZero(aRec_D[D_TOTAL],9,2),".","")		// 11-18 | 8 | Valor Total R$ dos serviços vendidos ao cliente sem faturamento realizado. ( Total WIP labor $ at cost - Total value of the labor, at cost, posted to WIP jobs at month end )
cLinha += StrZero( Round(aRec_D[D_TOTAL] , 0 ) , 8 )			// 11-18 | 8 | Valor Total R$ dos serviços vendidos ao cliente sem faturamento realizado. ( Total WIP labor $ at cost - Total value of the labor, at cost, posted to WIP jobs at month end )
cLinha += " "																// 19    | 1 | Filler
cLinha += cSrcAccount
//cLinha += StrTran(StrZero(aRec_D[D_TOTALWIP  ],09,2),".","") // 27-34 | 8 | Valor a preço de custo (gerencial) dos serviços da OS (tempo vendido * preço de custo MO) + Peças concluídas e ainda não Faturadas. ( Total WIP $ at cost - Total value of WIP retail jobs, at cost, at month end )
//cLinha += StrTran(StrZero(aRec_D[D_LABOR12   ],10,2),".","") // 35-43 | 9 | Total do custo das vendas (gerencial) dos serviços da OS faturadas (tempo vendido * preço de custo MO). Soma dos últimos 12 meses. ( Last-12 months labor COS - Total COS for labor on invoiced jobs for the last-12 months )
//cLinha += StrTran(StrZero(aRec_D[D_SERVICE12 ],10,2),".","") // 44-52 | 9 | Total do custo das vendas (gerencial) dos serviços + Peças da OS faturadas (tempo vendido * preço de custo MO). Soma dos últimos 12 meses. Somente faturados a clientes. ( Last-12 months service COS - Total COS for service on invoiced retail jobs for the last 12 months )
//cLinha += StrTran(StrZero(aRec_D[D_AVG],4),".","")           // 53-56 | 4 | Número médio de dias entre a conclusão do último serviço da OS e o faturamento da OS (fechados no mês). ( Average Billing cycle Days - The average number of days between the Date of Last Labor Posting and the Invoice Date for jobs closed this month. )
//cLinha += StrTran(StrZero(aRec_D[D_AGED_LABOR],9,2),".","")  // 57-64 | 8 | Valor a preço de custo (gerencial) dos serviços da OS (tempo vendido * preço de custo MO) concluídas a mais de 14 dias e ainda não encerradas/faturadas no mês de referência. Somente OS de clientes. Excluídos serviços de terceiros. ( Aged WIP Labor $ at cost - Labor value, at cost, posted to aged WIP retail jobs at month-end - See definition of ‘Aged WIP’ in Special Considerations )
//cLinha += StrTran(StrZero(aRec_D[D_AGED_TOTAL],9,2),".","")  // 65-72 | 8 | Valor a preço de custo (gerencial) dos serviços da OS (tempo vendido * preço de custo MO) + Peças concluídas a mais de 14 dias e ainda não encerradas/faturadas. Somente OS de clientes. ( Aged WIP Total $ at cost - Total value, at cost, of aged WIP retail jobs at month-end - See definition of ‘Aged WIP’ in Special Considerations )
cLinha += StrZero( Round(aRec_D[D_TOTALWIP  ] ,0 ) , 8 ) // 27-34 | 8 | Valor a preço de custo (gerencial) dos serviços da OS (tempo vendido * preço de custo MO) + Peças concluídas e ainda não Faturadas. ( Total WIP $ at cost - Total value of WIP retail jobs, at cost, at month end )
cLinha += StrZero( Round(aRec_D[D_LABOR12   ] ,0 ) , 9 ) // 35-43 | 9 | Total do custo das vendas (gerencial) dos serviços da OS faturadas (tempo vendido * preço de custo MO). Soma dos últimos 12 meses. ( Last-12 months labor COS - Total COS for labor on invoiced jobs for the last-12 months )
cLinha += StrZero( Round(aRec_D[D_SERVICE12 ] ,0 ) , 9 ) // 44-52 | 9 | Total do custo das vendas (gerencial) dos serviços + Peças da OS faturadas (tempo vendido * preço de custo MO). Soma dos últimos 12 meses. Somente faturados a clientes. ( Last-12 months service COS - Total COS for service on invoiced retail jobs for the last 12 months )
cLinha += StrZero( Round(aRec_D[D_AVG]        ,0 ) , 4 ) // 53-56 | 4 | Número médio de dias entre a conclusão do último serviço da OS e o faturamento da OS (fechados no mês). ( Average Billing cycle Days - The average number of days between the Date of Last Labor Posting and the Invoice Date for jobs closed this month. )
cLinha += StrZero( Round(aRec_D[D_AGED_LABOR] ,0 ) , 8 ) // 57-64 | 8 | Valor a preço de custo (gerencial) dos serviços da OS (tempo vendido * preço de custo MO) concluídas a mais de 14 dias e ainda não encerradas/faturadas no mês de referência. Somente OS de clientes. Excluídos serviços de terceiros. ( Aged WIP Labor $ at cost - Labor value, at cost, posted to aged WIP retail jobs at month-end - See definition of ‘Aged WIP’ in Special Considerations )
cLinha += StrZero( Round(aRec_D[D_AGED_TOTAL] ,0 ) , 8 ) // 65-72 | 8 | Valor a preço de custo (gerencial) dos serviços da OS (tempo vendido * preço de custo MO) + Peças concluídas a mais de 14 dias e ainda não encerradas/faturadas. Somente OS de clientes. ( Aged WIP Total $ at cost - Total value, at cost, of aged WIP retail jobs at month-end - See definition of ‘Aged WIP’ in Special Considerations )
cLinha += Space(8)                                           // 73-80 | 8 | Filler
OFNJD23ESCREVE(@cLinha,.t.)
OFNJD23DEBUG("RECD", {aRec_D})

aSort( aAuxOS ,,,{|x,y| x < y })
For nCont := 1 to Len(aAuxOS)
	oFWriter:Write( aAuxOS[nCont] + CRLF )
Next nCont
//If lDEBUG
//	oFWriter:Write( "-------------------------" + CRLF )
//
//	oFWriter:Write( "C_HOURS_SOLD  : " + Str ( Round(aRec_C[ C_HOURS_SOLD   ] , 0 ) ,6 ) + CRLF )
//	oFWriter:Write( "C_HOURS_WORKED: " + Str ( Round(aRec_C[ C_HOURS_WORKED ] , 0 ) ,6 ) + CRLF )
//	
//	oFWriter:Write( "-------------------------" + CRLF )
//		
//	oFWriter:Write( Str ( Round(aRec_D[D_TOTALWIP  ] ,0 ) , 10 ) + CRLF )
//	oFWriter:Write( Str ( Round(aRec_D[D_LABOR12   ] ,0 ) , 10 ) + CRLF )
//	oFWriter:Write( Str ( Round(aRec_D[D_SERVICE12 ] ,0 ) , 10 ) + CRLF )
//	oFWriter:Write( Str ( Round(aRec_D[D_AVG]        ,0 ) , 10 ) + CRLF )
//	oFWriter:Write( Str ( Round(aRec_D[D_AGED_LABOR] ,0 ) , 10 ) + CRLF )
//	oFWriter:Write( Str ( Round(aRec_D[D_AGED_TOTAL] ,0 ) , 10 ) + CRLF )
//EndIf

//OFNJD23DEBUG( "FIM" , { AllTrim(MV_PAR02) + IIf( !Right(AllTrim(MV_PAR02),1) $ "\/" , "\" , "" ) + "smmanage_debug.xls" } )
OFNJD23DEBUG( "FIM" , { cNomeArq } )

oFWriter:Close()
iif (IsSrvUnix(),CHMOD( cNomeArq , 7677,,.f. ),CHMOD( cNomeArq , 2,,.f. ))

//FRenameEX(cNomeArq,UPPER(cNomeArq))

If !lSchedule
	MsgInfo(STR0006) // Arquivo gerado
Else
	Conout(STR0006) // Arquivo gerado
EndIf

Return .t.

Static Function OFNJD23ESCREVE(cLinha,lPulaLinha)
oFWriter:Write(cHeader + cLinha + IIF( lPulaLinha , CRLF  , "" ) )
cLinha := ""
Return

Static Function OFNJD23SQL(cAuxAlias)
Local cSQLSrvcGar
cSQLSrvcGar := " AND NOT EXISTS " +;
  "( SELECT VMC_CODSER " +;
     " FROM " + RetSQLName("VMB") + " VMB " +;
     " JOIN " + RetSQLName("VMC") + " VMC ON VMC.VMC_FILIAL = VMB.VMB_FILIAL AND VMC.VMC_CODGAR = VMB.VMB_CODGAR AND (VMC.VMC_TIPOPS = 'S' OR (VMC.VMC_TIPOPS = 'O'AND VMC.VMC_CODSER <> ' ')) AND VMC.D_E_L_E_T_ = ' '" +;
     " JOIN " + RetSQLName("VOI") + " VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VMC.VMC_TIPTEM AND VOI.VOI_SITTPO <> '2' " +;
    " WHERE VMB.VMB_FILIAL = " + cAuxAlias + "." + cAuxAlias + "_FILIAL " +;
      " AND VMB.VMB_NUMOSV = " + cAuxAlias + "." + cAuxAlias + "_NUMOSV " +;
      " AND VMB.VMB_STATUS IN ('03','09','12') " +;
      " AND VMB.VMB_TIPGAR = 'ZSPA' " +;
      " AND VMB.D_E_L_E_T_ = ' ' " +;
		" AND VMC.VMC_TIPTEM = " + cAuxAlias + "." + cAuxAlias + "_TIPTEM "+;
  ") "
Return cSQLSrvcGar


//Static Function CriaSX1()
//
//Local aRegs   := {}
//Local nOpcGetFil := GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE 
//
//Local aHelp1Por := {}
//Local aHelp1Eng := {}
//Local aHelp1Spa := {}
//
//Local aHelp2Por := {}
//Local aHelp2Eng := {}
//Local aHelp2Spa := {}
//
//Aadd(aHelp1Por,"Informe Mês e Ano a serem considerados ")
//Aadd(aHelp1Por,"na geração do arquivos SMManage. Para ")
//Aadd(aHelp1Por,"execução via schedule o periodo ")
//Aadd(aHelp1Por,"considerado será o mês anterior a ")
//Aadd(aHelp1Por,"database do sistema")
//
//aHelp1Spa := aHelp1Eng := aHelp1Por
//
//Aadd(aHelp2Por,"Informe o diretório a serem gerados os ")
//Aadd(aHelp2Por,"arquivos SMManage e a planilha de ")
//Aadd(aHelp2Por,"conferência do arquivo SMManage.")
//Aadd(aHelp2Por,"Para execuções feitas diretamente pelo ")
//Aadd(aHelp2Por,"menu do módulo, qualquer diretório pode ")
//Aadd(aHelp2Por,"ser selecionado. Para execuções feitas ")
//Aadd(aHelp2Por,"pelo Schedule, apenas diretórios ")
//Aadd(aHelp2Por,"existentes a partir do rootpath do ")
//Aadd(aHelp2Por,"Protheus serão considerados.")
//
//aHelp2Spa := aHelp2Eng := aHelp2Por
//
////
//// Pergunte
//AADD(aRegs,{STR0005,STR0005,STR0005,'MV_CH1','C',6,0,,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','@R 99/9999',aHelp1Por,aHelp1Eng,aHelp1Spa}) //Mês / Ano
//AADD(aRegs,{STR0003,STR0003,STR0003,"MV_CH2","C",99,0,0,"G","!Vazio().or.(MV_PAR02:=cGetFile('Diretorio','',,,,"+AllTrim(Str(nOpcGetFil))+"))","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",aHelp2Por,aHelp2Eng,aHelp2Spa}) // Diretório
////
//
//Return


Static Function ADDOS( cNumOsv )
If lDEBUG .and. aScan(aAuxOS, cNumOsv) == 0
	AADD( aAuxOS , cNumOsv )
EndIf
Return


Static Function OFNJD23DEBUG( cTipo , aParam )

Local nCont  := 0
Local nCont2 := 0
Local oAuxObj

If !lDEBUG
	return .t.
EndIf

Do Case
Case cTipo == "PARAMETRO"

	oExcel:AddWorkSheet("PARAMETRO")
	oExcel:AddTable("PARAMETRO",STR0007) // Parametro
	
	oExcel:AddColumn( "PARAMETRO" , STR0007 , STR0008       , 1 , 1 ) // 01 Periodo
	oExcel:AddColumn( "PARAMETRO" , STR0007 , STR0009       , 1 , 1 ) // 02 Arquivo
	oExcel:AddColumn( "PARAMETRO" , STR0007 , STR0010       , 1 , 1 ) // 03 Empresa
	oExcel:AddColumn( "PARAMETRO" , STR0007 , STR0011        , 1 , 1 ) // 04 Filial
	oExcel:AddColumn( "PARAMETRO" , STR0007 , STR0012      , 1 , 1 ) // 05 Schedule
	
	oExcel:AddRow( "PARAMETRO" , STR0007 , { aParam[1,1] ,;
											 aParam[1,2] ,;
											 aParam[1,3] ,;
											 aParam[1,4] ,;
											 aParam[1,5] } )

Case cTipo == "ESCALA"

	oAuxObj := aParam[1]

	oExcel:AddWorkSheet("PERIODO")
	oExcel:AddTable("PERIODO",STR0008) // Periodo
	
	oExcel:AddColumn( "PERIODO" , STR0008 , STR0013 , 1 , 1 ) // 01 "Codigo"
	oExcel:AddColumn( "PERIODO" , STR0008 , STR0014 , 1 , 1 ) // 02 "P1 Inicio"
	oExcel:AddColumn( "PERIODO" , STR0008 , STR0015 , 1 , 1 ) // 03 "I1 Inicio"
	oExcel:AddColumn( "PERIODO" , STR0008 , STR0016 , 1 , 1 ) // 04 "I1 Fim"
	oExcel:AddColumn( "PERIODO" , STR0008 , STR0017 , 1 , 1 ) // 05 "P1 Fim"
	oExcel:AddColumn( "PERIODO" , STR0008 , STR0018 , 1 , 1 ) // 06 "P2 Inicio"
	oExcel:AddColumn( "PERIODO" , STR0008 , STR0019 , 1 , 1 ) // 07 "I2 Inicio"
	oExcel:AddColumn( "PERIODO" , STR0008 , STR0020 , 1 , 1 ) // 08 "I2 Fim"
	oExcel:AddColumn( "PERIODO" , STR0008 , STR0021 , 1 , 1 ) // 09 "P2 Fim"
	oExcel:AddColumn( "PERIODO" , STR0008 , STR0022 , 1 , 1 ) // 10 "Disp. Periodo"
	oExcel:AddColumn( "PERIODO" , STR0008 , STR0023 , 1 , 1 ) // 11 "Disp. Periodo 1"
	oExcel:AddColumn( "PERIODO" , STR0008 , STR0024 , 1 , 1 ) // 12 "Disp. Periodo 2"
	oExcel:AddColumn( "PERIODO" , STR0008 , STR0025 , 1 , 1 ) // 13 "Disp. Interv. 1"
	oExcel:AddColumn( "PERIODO" , STR0008 , STR0026 , 1 , 1 ) // 14 "Disp. Interv. 2"
	
	If Len(oAuxObj:aProdutivos) > 0
	
		For nCont := 1 to Len(oAuxObj:aPeriodo)
			oExcel:AddRow( "PERIODO" , STR0008 , ;
				{ ;
					oAuxObj:aPeriodo[ nCont , 01 ] ,; // 01 - Codigo do Periodo
					Transform( oAuxObj:aPeriodo[ nCont , 02 ] , "@R 99:99" ) ,; // 02 - Inicio do Periodo
					Transform( oAuxObj:aPeriodo[ nCont , 03 ] , "@R 99:99" ) ,; // 03 - Inicio do Intervalo 1
					Transform( oAuxObj:aPeriodo[ nCont , 04 ] , "@R 99:99" ) ,; // 04 - Fim    do Intervalo 2
					Transform( oAuxObj:aPeriodo[ nCont , 05 ] , "@R 99:99" ) ,; // 05 - Inicio do Almoco
					Transform( oAuxObj:aPeriodo[ nCont , 06 ] , "@R 99:99" ) ,; // 06 - Fim    do Almoco
					Transform( oAuxObj:aPeriodo[ nCont , 07 ] , "@R 99:99" ) ,; // 07 - Inicio do Intervalor 2
					Transform( oAuxObj:aPeriodo[ nCont , 08 ] , "@R 99:99" ) ,; // 08 - Fim    do Intervalo 2
					Transform( oAuxObj:aPeriodo[ nCont , 09 ] , "@R 99:99" ) ,; // 09 - Fim    do Periodo
					oAuxObj:aPeriodo[ nCont , 10 ] / 100 ,; // 10 - Tempo Disponivel do Periodo 
					oAuxObj:aPeriodo[ nCont , 11 ] / 100 ,; // 11 - Tempo do Intervalo 1 ( Inicio          -> Inicio Intervalo 1 )
					oAuxObj:aPeriodo[ nCont , 12 ] / 100 ,; // 12 - Tempo do Intervalo 2 ( Fim Intervalo 1 -> Inicio Refeicao    )
					oAuxObj:aPeriodo[ nCont , 13 ] / 100 ,; // 13 - Tempo do Intervalo 3 ( Fim Refeicao    -> Inicio Intervalo 2 )
					oAuxObj:aPeriodo[ nCont , 14 ] / 100  ; // 14 - Tempo do Intervalo 4 ( Fim Intervalo 2 -> Fim Periodo        )
				} )
		Next nCont
	EndIf
	
	oExcel:AddWorkSheet("ESCALA")
	oExcel:AddTable("ESCALA",STR0027) // Escalas
	
	oExcel:AddColumn( "ESCALA" , STR0027 , STR0028 , 1 , 1 ) // 01 "Produtivo"
	oExcel:AddColumn( "ESCALA" , STR0027 , STR0029 , 1 , 1 ) // 02 "Nome Produtivo"
	oExcel:AddColumn( "ESCALA" , STR0027 , STR0030 , 1 , 1 ) // 03 "Data"
	oExcel:AddColumn( "ESCALA" , STR0027 , STR0031 , 1 , 1 ) // 04 "Dia"
	oExcel:AddColumn( "ESCALA" , STR0027 , STR0008 , 1 , 1 ) // 05 "Periodo"
	oExcel:AddColumn( "ESCALA" , STR0027 , STR0032 , 1 , 1 , .t. ) // 06 "Tempo"
	
	For nCont := 1 to Len(oAuxObj:aProdutivos)
		For nCont2 := 1 to Len(oAuxObj:aProdutivos[nCont]:aEscala)
			dData := StoD(oAuxObj:aProdutivos[nCont]:aEscala[nCont2,1])
			
			oExcel:AddRow( "ESCALA" , STR0027 , ;
				{ ;
					oAuxObj:aProdutivos[nCont]:cCodigo ,;
					oAuxObj:aProdutivos[nCont]:cNome ,;
					DtoC(dData) ,;
					DiaSemana(dData) ,;
					oAuxObj:aProdutivos[nCont]:aEscala[nCont2,2] ,;
					oAuxObj:aProdutivos[nCont]:aEscala[nCont2,4] / 100 ;
				} )
		Next nCont2
	Next nCont
	
Case cTipo == "CABECSRVC"

	oExcel:AddWorkSheet("SRVC")
	oExcel:AddTable("SRVC",STR0033) //Serviços
	
	oExcel:AddColumn( "SRVC" , STR0033 , STR0034 , 1 , 1 ) // 01 "OS"         
	oExcel:AddColumn( "SRVC" , STR0033 , STR0035 , 1 , 1 ) // 02 "TT"         
	oExcel:AddColumn( "SRVC" , STR0033 , STR0036 , 1 , 1 ) // 03 "SITTPO"     
	oExcel:AddColumn( "SRVC" , STR0033 , STR0033 , 1 , 1 ) // 04 "Servico"    
	oExcel:AddColumn( "SRVC" , STR0033 , STR0037 , 1 , 1 ) // 05 "Tipo Ser."  
	oExcel:AddColumn( "SRVC" , STR0033 , STR0038 , 1 , 1 ) // 06 "Tipo Cob."  
	oExcel:AddColumn( "SRVC" , STR0033 , STR0039 , 1 , 1 ) // 07 "Tempo Calc."
	oExcel:AddColumn( "SRVC" , STR0033 , STR0040 , 1 , 2 ) // 08 "Tem. Pad."  
	oExcel:AddColumn( "SRVC" , STR0033 , STR0041 , 1 , 2 ) // 09 "Tem. Tra."  
	oExcel:AddColumn( "SRVC" , STR0033 , STR0042 , 1 , 2 ) // 10 "Tem. Cob."  
	oExcel:AddColumn( "SRVC" , STR0033 , STR0043 , 1 , 2 ) // 11 "Tem. Ven."  
	oExcel:AddColumn( "SRVC" , STR0033 , STR0044 , 1 , 1 ) // 12 "Generico"   
	oExcel:AddColumn( "SRVC" , STR0033 , STR0045 , 1 , 1 ) // 13 "Tem. Consid."  
	oExcel:AddColumn( "SRVC" , STR0033 , STR0046 , 1 , 1 ) // 14 "Hr. Vend."  
	oExcel:AddColumn( "SRVC" , STR0033 , STR0047 , 1 , 1 ) // 15 "Hr. Trab."  
	
Case cTipo == "SRVC"
	oExcel:AddRow( "SRVC" , STR0033 , ;
		{ ;
			aRowLog[01],;                         // 01 "OS"         
			aRowLog[02],;                         // 02 "TT"         
			AuxDesc( "SITTPO" , aRowLog[03] ),;   // 03 "SITTPO"     
			aRowLog[04],;                         // 04 "Servico"    
			aRowLog[05],;                         // 05 "Tipo Ser."  
			AuxDesc( "INCMOB" , aRowLog[06] ),;   // 06 "Tipo Cob."  
			AuxDesc( "INCTEM" , aRowLog[15] ),;   // 07 "Tempo Calc."
			aRowLog[07] / 100 ,;                  // 08 "Tem. Pad."  
			aRowLog[08] / 100 ,;                  // 09 "Tem. Tra."  
			aRowLog[09] / 100 ,;                  // 10 "Tem. Cob."  
			aRowLog[10] / 100 ,;                  // 11 "Tem. Ven."  
			IIf( aRowLog[11] , "Sim" , "Nao" ) ,; // 12 "Generico"   
			aRowLog[12] / 100 ,;                  // 13 "Tem. Consid."   
			aRowLog[13] / 100 ,;                  // 14 "Hr. Vend."
			aRowLog[14] / 100  ;                  // 15 "Hr. Trab."  
		} )
		
Case cTipo == "RECA"

	oExcel:AddWorkSheet("SMMANAGE")
	oExcel:AddTable("SMMANAGE",STR0048) //"Layout SMManage"
	
	oExcel:AddColumn( "SMMANAGE" , STR0048 , STR0049 , 1 , 1 ) // 01 "Tipo Reg."
	oExcel:AddColumn( "SMMANAGE" , STR0048 , STR0050 , 1 , 1 ) // 02 "Posicao"
	oExcel:AddColumn( "SMMANAGE" , STR0048 , STR0051 , 1 , 1 ) // 03 "Valor"
	oExcel:AddColumn( "SMMANAGE" , STR0048 , STR0052 , 1 , 1 ) // 04 "Descrição"
	
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AA", "29-34" , aParam[ 1 , A_JOBS             ] , STR0053 } ) //"Quantidade de linhas de serviços lançadas nas OS "
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AA", "35-40" , aParam[ 1 , A_JOBS_SPEC        ] , STR0054 } ) //"Quantidade de linhas de serviços lançadas nas OS, serviços que estão na tabela de tempo padrão de reparo."
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AA", "41-46" , aParam[ 1 , A_JOBS_GENE        ] , STR0055 } ) //"Quantidade de linhas de serviços lançadas nas OS, serviços fora da tabela de tempo padrão de reparo."
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AA", "47-52" , aParam[ 1 , A_JOBS_SPEC_TEMPAD ] , STR0056 } ) //"Quantidade de linhas de serviços lançadas nas OS, serviços que estão na tabela de tempo padrão de reparo, cujo tempo padrão é igual ao tempo vendido ao cliente."
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AA", "53-58" , aParam[ 1 , A_JOBS_SPEC_TEMINF ] , STR0057 } ) //"Quantidade de linhas de serviços lançadas nas OS, serviços que estão na tabela de tempo padrão de reparo, cujo tempo padrão é diferente do tempo vendido ao cliente."
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AA", "59-64" , aParam[ 1 , A_JOBS_GENE_TEMPAD ] , STR0058 } ) //"Quantidade de linhas de serviços lançadas nas OS, serviços fora da tabela de tempo padrão de reparo, cujo tempo padrão é igual ao tempo vendido ao cliente."
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AA", "65-70" , aParam[ 1 , A_JOBS_GENE_TEMINF ] , STR0059 } ) //"Quantidade de linhas de serviços lançadas nas OS, serviços fora da tabela de tempo padrão de reparo, cujo tempo padrão é diferente do tempo vendido ao cliente."
	
Case cTipo == "RECB"
	
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AB" , "11-16" , Round( aParam[ 1 , B_HOURS_AVAILABLE ] / 100 , 0 ) , STR0060 } ) // "Total de horas disponíveis para trabalho, já descontadas as horas improdutivas."
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AB" , "27-32" , Round( aParam[ 1 , B_HOURS_WORKED    ] / 100 , 0 ) , STR0061 } ) // "Total de horas trabalhadas e apontadas em trabalhos faturados."
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AB" , "33-38" , Round( aParam[ 1 , B_HOURS_DELAY     ] / 100 , 0 ) , STR0062 } ) // "Soma de todos os tempos de parada de serviços por falta de peças, e outros motivos técnicos a serem informados pela JD.. Verificar outros tipos de parada de serviços e enviar para seleção. enviar para JD para seleção listar" 
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AB" , "39-44" , Round( aParam[ 1 , B_HOURS_REWORK    ] / 100 , 0 ) , STR0063 } ) // "Total de horas trabalhadas e apontadas em OS de retrabalho."
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AB" , "45-50" , Round( aParam[ 1 , B_HOURS_OVER      ] / 100 , 0 ) , STR0064 } ) // "Total de horas trabalhadas e apontadas em trabalhos faturados, que excederam o tempo padrão. "
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AB" , "51-55" , Round( aParam[ 1 , B_HOURS_OTHER     ] / 100 , 0 ) , STR0065 } ) // "Total de horas trabalhadas em OS internas / Cortesia"

Case cTipo == "RECC"
	
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AC" , "11-16" , Round( aParam[ 1 , C_HOURS_SOLD   ] / 100 , 0 ) , STR0066 } ) // "Total de horas faturadas a cliente"
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AC" , "27-32" , Round( aParam[ 1 , C_HOURS_WORKED ] / 100 , 0 ) , STR0067 } ) // "Total de horas trabalhadas em serviços faturados ao cliente"

Case cTipo == "RECD"

	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AD" , "11-18" , Round( aParam[ 1 , D_TOTAL     ] , 0 ) , STR0068 } ) // "Valor Total R$ custo dos serviços vendidos ao cliente sem faturamento realizado."
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AD" , "27-34" , Round( aParam[ 1 , D_TOTALWIP  ] , 0 ) , STR0069 } ) // "Valor a preço de custo (gerencial) dos serviços da OS (tempo vendido * preço de custo MO) + Peças concluídas e ainda não Faturadas."
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AD" , "35-43" , Round( aParam[ 1 , D_LABOR12   ] , 0 ) , STR0070 } ) // "Total do custo das vendas (gerencial) dos serviços da OS faturadas (tempo vendido * preço de custo MO). Soma dos últimos 12 meses."
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AD" , "44-52" , Round( aParam[ 1 , D_SERVICE12 ] , 0 ) , STR0071 } ) // "Total do custo das vendas (gerencial) dos serviços + Peças da OS faturadas (tempo vendido * preço de custo MO). Soma dos últimos 12 meses. Somente faturados a clientes."
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AD" , "53-56" , Round( aParam[ 1 , D_AVG       ] , 0 ) , STR0072 } ) // "Número médio de dias entre a conclusão do último serviço da OS e o faturamento da OS (fechados no mês)."
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AD" , "57-64" , Round( aParam[ 1 , D_AGED_LABOR] , 0 ) , STR0073 } ) // "Valor a preço de custo (gerencial) dos serviços da OS (tempo vendido * preço de custo MO) concluídas a mais de 14 dias e ainda não encerradas/faturadas no mês de referência. Somente OS de clientes. Excluídos serviços de terceiros."
	oExcel:AddRow( "SMMANAGE" , STR0048 , { "AD" , "65-72" , Round( aParam[ 1 , D_AGED_TOTAL] , 0 ) , STR0074 } ) // "Valor a preço de custo (gerencial) dos serviços da OS (tempo vendido * preço de custo MO) + Peças concluídas a mais de 14 dias e ainda não encerradas/faturadas. Somente OS de clientes."

Case cTipo == "FIM"
	oExcel:Activate()
	cNomeArq := AllTrim(StrTran( aParam[1] , ".DAT" , ".XLS" ))

	oExcel:GetXMLFile(cNomeArq)
	oExcel:DeActivate()

EndCase

Return

Static Function DiaSemana(dData)
Local nDiaSemana := Dow(dData)
Do Case
Case nDiaSemana == 1 ; Return STR0075 //"Domingo"
Case nDiaSemana == 2 ; Return STR0076 //"Segunda"
Case nDiaSemana == 3 ; Return STR0077 //"Terca  "
Case nDiaSemana == 4 ; Return STR0078 //"Quarta "
Case nDiaSemana == 5 ; Return STR0079 //"Quinta "
Case nDiaSemana == 6 ; Return STR0080 //"Sexta  "
Case nDiaSemana == 7 ; Return STR0081 //"Sabado "
EndCase
Return ""

Static Function AuxDesc(cTipo, cValor)
Do Case
	Case cTipo == "SITTPO"
		Do Case
			Case cValor == "1" ; Return STR0082 //"Publico"
			Case cValor == "2" ; Return STR0083 //"Garantia"
			Case cValor == "3" ; Return STR0084 //"Interno"
			Case cValor == "4" ; Return STR0085 //"Revisao"
		EndCase
	Case cTipo == "INCMOB"
		Do Case
			Case cValor == "0" ; Return STR0086 //"Por Mao-de-Obra Gratuita"
			Case cValor == "1" ; Return STR0087 //"Por Mao-de-Obra"
			Case cValor == "2" ; Return STR0088 //"Srv de Terceiro"
			Case cValor == "3" ; Return STR0089 //"Valor Livre c/Base na Tabela"
			Case cValor == "4" ; Return STR0090 //"Retorno de Servico"
			Case cValor == "5" ; Return STR0091 //"Km Socorro"
		EndCase
	Case cTipo == "INCTEM"
		Do Case
			Case cValor == "1" ; Return STR0092 //"Fabrica"
			Case cValor == "2" ; Return STR0093 //"Concessionaria"
			Case cValor == "3" ; Return STR0094 //"Trabalhado"
			Case cValor == "4" ; Return STR0095 //"Informado"
		EndCase
EndCase
Return ""

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | SchedDef   | Autor | Andre Luis Almeida    | Data | 13/04/17 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Funcao utilizada no cadastro de Schedule                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function SchedDef()
Local aParam := {;
	"P",;
	"OFINJD23",;
	"",;
	"",;
	"" ;
	}
Return aParam