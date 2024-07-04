// …ÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕª
// ∫ Versao ∫ 012    ∫
// »ÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕº

#include "fileio.ch"
#include "protheus.ch"
#include "OFINJD21.ch"  

/*
<?xml version="1.0" encoding="UTF-8"?> <-- A trailing Line Feed (Hex 0d)is required on this line
<SOAP:Envelope xmlns:SOAP="urn:schemas-xmlsoap-org:soap.v1">
	<SOAP:Body>
		<m:RetrieveEquipment xmlns:m="DBS-INPUT">
			<INPUT> 1 <INPUT> per dealer account 
				<REQUP> 1 <REQUP> per piece of equipment 
					<RDETL> 1 <RDETL> per line item detail for the equipment 
					</RDETL> 
					<RAGGR> 0 or 1 <RAGGR> per piece of aggregated equipment 
					</RAGGR> 
				</REQUP> 
			</INPUT>
			<INPUT> 1 <INPUT> per dealer account 
				<REQUP> 1 <REQUP> per piece of equipment 
					<RDETL> 1 <RDETL> per line item detail for the equipment 
					</RDETL>
					<RAGGR> 0 or 1 <RAGGR> per piece of aggregated equipment 
					</RAGGR> 
				</REQUP> 
			</INPUT>
		</m:RetrieveEquipment>
	</SOAP:Body>
</SOAP:Envelope>


aXMLInput := ;
{ ;
  { "1" } , ;
  { "2" } ;
}
aXMLRequp := ;
{ ;
  { ;
    { "1.1.1","1.1.2","1.1.3","1.1.4","1.1.5","1.1.6","1.1.7","1.1.8","1.1.9","1.1.10","1.1.11","1.1.12","1.1.13","1.1.14","1.1.15","1.1.16","1.1.17","1.1.18","1.1.19","1.1.20","1.1.21","1.1.22","1.1.23","1.1.24","1.1.25","1.1.26","1.1.27","1.1.28","1.1.29","1.1.30","1.1.31","1.1.32","1.1.33","1.1.34","1.1.35","1.1.36","1.1.37"},;
    { "1.2.1","1.2.2","1.2.3","1.2.4","1.2.5","1.2.6","1.2.7","1.2.8","1.2.9","1.2.10","1.2.11","1.2.12","1.2.13","1.2.14","1.2.15","1.2.16","1.2.17","1.2.18","1.2.19","1.2.20","1.2.21","1.2.22","1.2.23","1.2.24","1.2.25","1.2.26","1.2.27","1.2.28","1.2.29","1.2.30","1.2.31","1.2.32","1.2.33","1.2.34","1.2.35","1.2.36","1.2.37"} ; 
  } ,; 
  { ;
    { "2.1.1","2.1.2","2.1.3","2.1.4","2.1.5","2.1.6","2.1.7","2.1.8","2.1.9","2.1.10","2.1.11","2.1.12","2.1.13","2.1.14","2.1.15","2.1.16","2.1.17","2.1.18","2.1.19","2.1.20","2.1.21","2.1.22","2.1.23","2.1.24","2.1.25","2.1.26","2.1.27","2.1.28","2.1.29","2.1.30","2.1.31","2.1.32","2.1.33","2.1.34","2.1.35","2.1.36","2.1.37"},;
    { "2.2.1","2.2.2","2.2.3","2.2.4","2.2.5","2.2.6","2.2.7","2.2.8","2.2.9","2.2.10","2.2.11","2.2.12","2.2.13","2.2.14","2.2.15","2.2.16","2.2.17","2.2.18","2.2.19","2.2.20","2.2.21","2.2.22","2.2.23","2.2.24","2.2.25","2.2.26","2.2.27","2.2.28","2.2.29","2.2.30","2.2.31","2.2.32","2.2.33","2.2.34","2.2.35","2.2.36","2.2.37"} ; 
  } ;
}
aXMLRdetl := ;
{ ;
  { ;
    { ;
      {"1.1.1.1.1","1.1.1.1.2","1.1.1.1.3","1.1.1.1.4","1.1.1.1.5","1.1.1.1.6"}, ;
  	  {"1.1.1.2.1","1.1.1.2.2","1.1.1.2.3","1.1.1.2.4","1.1.1.2.5","1.1.1.2.6"} ;
    }, ;
    {  ;
      {"1.2.1.1.1","1.2.1.1.2","1.2.1.1.3","1.2.1.1.4","1.2.1.1.5","1.2.1.1.6"}, ;
  	  {"1.2.1.2.1","1.2.1.2.2","1.2.1.2.3","1.2.1.2.4","1.2.1.2.5","1.2.1.2.6"} ;
    };
  } ,;
  { ;
    { ;
      {"2.1.1.1.1","2.1.1.1.2","2.1.1.1.3","2.1.1.1.4","2.1.1.1.5","2.1.1.1.6"}, ;
  	  {"2.1.1.2.1","2.1.1.2.2","2.1.1.2.3","2.1.1.2.4","2.1.1.2.5","2.1.1.2.6"} ;
    }, ;
    { ;
      {"2.2.1.1.1","2.2.1.1.2","2.2.1.1.3","2.2.1.1.4","2.2.1.1.5","2.2.1.1.6"}, ;
  	  {"2.2.1.2.1","2.2.1.2.2","2.2.1.2.3","2.2.1.2.4","2.2.1.2.5","2.2.1.2.6"} ;
    } ;
  } ;
}
aXMLRaggr := ;
{ ;
  { ;
    { ;
      {"1.1.1.1.1"}, ;
  	  {"1.1.1.2.1"} ;
    }, ;
    {  ;
      {"1.2.1.1.1"}, ;
  	  {"1.2.1.2.1"} ;
    };
  } ,;
  { ;
    { ;
      {"2.1.1.1.1"}, ;
  	  {"2.1.1.2.1"} ;
    }, ;
    { ;
      {"2.2.1.1.1"}, ;
  	  {"2.2.1.2.1"} ;
    } ;
  } ;
}
*/


#DEFINE INPUT_EQPOWNER 1

#DEFINE REQUP_STKNUM 1
#DEFINE REQUP_BAIND 2
#DEFINE REQUP_NUIND 3
#DEFINE REQUP_STORDLR 4
#DEFINE REQUP_STORCITY 5
#DEFINE REQUP_STORSTATE 6
#DEFINE REQUP_INVST 7
#DEFINE REQUP_YRMF 8
#DEFINE REQUP_MAKE 9
#DEFINE REQUP_MAKEDESC 10
#DEFINE REQUP_MODEL 11
#DEFINE REQUP_CAT 12
#DEFINE REQUP_CATDESC 13
#DEFINE REQUP_MACHDESC 14
#DEFINE REQUP_PIN 15
#DEFINE REQUP_METER 16
#DEFINE REQUP_METERUOM 17
#DEFINE REQUP_ATTQTY 18
#DEFINE REQUP_TCOST 19
#DEFINE REQUP_LIST 20
#DEFINE REQUP_DLC 21
#DEFINE REQUP_SALEPRC 22
#DEFINE REQUP_SALEDT 23
#DEFINE REQUP_EQPCOND 24
#DEFINE REQUP_SCOST 25
#DEFINE REQUP_EQPNOTE 26
#DEFINE REQUP_OVERALLOWANCE 27
#DEFINE REQUP_NETSALEPRICE 28
#DEFINE REQUP_MDP 29
#DEFINE REQUP_EQUIPCOST 30
#DEFINE REQUP_ADDLCOST 31
#DEFINE REQUP_ORDNUM 32
#DEFINE REQUP_SURCHG 33
#DEFINE REQUP_INVAMT 34
#DEFINE REQUP_SURCHGAMT 35
#DEFINE REQUP_SALESBOOKVAL 36
#DEFINE REQUP_BESTSELLPRICE 37

#DEFINE RDETL_LINECODE 1
#DEFINE RDETL_LINETYPE 2
#DEFINE RDETL_LINEDESC 3
#DEFINE RDETL_LINEQTY 4
#DEFINE RDETL_LINELIST 5
#DEFINE RDETL_LINECOST 6

#DEFINE RAGGR_STKNUM 1

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    | OFINJD21   | Autor |  Luis Delorme         | Data | 23/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | ExportaÁ„o do arquivo JDQUOTE                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD21(_nMes, _nAno)

Private aINPUT 
Private aREQUP 
Private aRAGGR 
Private aRDETL 
Private cInvStatus := "I"
Private cPerg := "ONJD21"
Private aSay := {}
Private aButton := {}
Private cTitulo := "OFINJD21"

aINPUT := array(1)
aREQUP := array(37)
aRAGGR := array(1)
aRDETL := array(6)

aINPUT[INPUT_EQPOWNER] := "EQPOWNER" 

aREQUP[REQUP_STKNUM] := "STKNUM"
aREQUP[REQUP_BAIND] := "BAIND"
aREQUP[REQUP_NUIND] := "NUIND"
aREQUP[REQUP_STORDLR] := "STORDLR"
aREQUP[REQUP_STORCITY] := "STORCITY"
aREQUP[REQUP_STORSTATE] := "STORSTATE"
aREQUP[REQUP_INVST] := "INVST"
aREQUP[REQUP_YRMF] := "YRMF"
aREQUP[REQUP_MAKE] := "MAKE"
aREQUP[REQUP_MAKEDESC] := "MAKEDESC"
aREQUP[REQUP_MODEL] := "MODEL"
aREQUP[REQUP_CAT] := "CAT"
aREQUP[REQUP_CATDESC] := "CATDESC"
aREQUP[REQUP_MACHDESC] := "MACHDESC"
aREQUP[REQUP_PIN] := "PIN"
aREQUP[REQUP_METER] := "METER"
aREQUP[REQUP_METERUOM] := "METERUOM"
aREQUP[REQUP_ATTQTY] := "ATTQTY"
aREQUP[REQUP_TCOST] := "TCOST"
aREQUP[REQUP_LIST] := "LIST"
aREQUP[REQUP_DLC] := "DLC"
aREQUP[REQUP_SALEPRC] := "SALEPRC"
aREQUP[REQUP_SALEDT] := "SALEDT"
aREQUP[REQUP_EQPCOND] := "EQPCOND"
aREQUP[REQUP_SCOST] := "SCOST"
aREQUP[REQUP_EQPNOTE] := "EQPNOTE"
aREQUP[REQUP_OVERALLOWANCE] := "OVERALLOWANCE"
aREQUP[REQUP_NETSALEPRICE] := "NETSALEPRICE"
aREQUP[REQUP_MDP] := "MDP"
aREQUP[REQUP_EQUIPCOST] := "EQUIPCOST"
aREQUP[REQUP_ADDLCOST] := "ADDLCOST"
aREQUP[REQUP_ORDNUM] := "ORDNUM"
aREQUP[REQUP_SURCHG] := "SURCHG"
aREQUP[REQUP_INVAMT] := "INVAMT"
aREQUP[REQUP_SURCHGAMT] := "SURCHGAMT"
aREQUP[REQUP_SALESBOOKVAL] := "SALESBOOKVAL"
aREQUP[REQUP_BESTSELLPRICE] := "BESTSELLPRICE"

aRDETL[RDETL_LINECODE] := "LINECODE"
aRDETL[RDETL_LINETYPE] := "LINETYPE"
aRDETL[RDETL_LINEDESC] := "LINEDESC"
aRDETL[RDETL_LINEQTY] := "LINEQTY"
aRDETL[RDETL_LINELIST] := "LINELIST"
aRDETL[RDETL_LINECOST] := "LINECOST"

aRAGGR[RAGGR_STKNUM] := "STKNUM"

aAdd( aSay, STR0001 )
aAdd( aSay, STR0002 )
aAdd( aSay, STR0003 )
//
nOpc := 0
aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
//
FormBatch( cTitulo, aSay, aButton )
//
If nOpc <> 1
	Return
endif
//
Pergunte(cPerg,.f.) 
//
RptStatus( {|lEnd| ExportArq()}, STR0004,STR0005)
//
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunÁ„o    | ExportArq  | Autor | Luis Delorme          | Data | 17/07/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriÁ„o | Exporta arquivo                                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ExportArq()

Local nCntFor1, nCntFor2, nCntFor3, nCntTag
Local cQryAlCus := "SQLSB1"
Local lVV1_DESVEI := ( VV1->(FieldPos("VV1_DESVEI")) > 0 )
Local lVV1_OBSVEI := ( VV1->(FieldPos("VV1_OBSVEI")) > 0 ) // Campo MEMO

Local cHoraVld    := SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)
Local nIdx        := 0

Private cGruVei := PadR(AllTrim(GetMv("MV_GRUVEI")),GetSx3Cache("B1_GRUPO","X3_TAMANHO")," ") // Grupo do Veiculo

Private oFiliais  := DMS_DPM():New()
Private aFilis     := oFiliais:GetFiliais()

aXMLInput := {}
aXMLRequp := {}
aXMLRdetl := {}
aXMLRaggr := {}


for nIdx := 1 to Len(aFilis)

	aAdd(aXMLInput, { aFilis[nIdx][2] })
	aAdd(aXMLRequp, {})
	aAdd(aXMLRdetl, {})
	aAdd(aXMLRaggr, {})

next

// LEVANTAMENTO DAS INFORMA«’ES
cQryAl001 := GetNextAlias()

cQuery := "SELECT VV1.R_E_C_N_O_ VV1RECNO, VV1_CHAINT, VV1_CODMAR, VV1_MODVEI,"
cQuery +=		" VV1_SEGMOD, VV1_CORVEI, VV1_FILENT, VV1_CHASSI, VV1_LOCPAD,"
cQuery +=		" VV1_SITVEI, VV1_FABMOD, "

cQuery +=		" CASE WHEN VV1_ESTVEI = '0' THEN 'N' ELSE 'U' END AS VV1ESTVEI, "

cQuery +=		" VE1_MAREDI, VE1_DESMAR, "

cQuery +=		" VV2_MODFAB, VV2_DESMOD, VV2_MODEDI, "

If MV_PAR05 == 1 // Utiliza Categoria do Veiculos
	cQuery +=		" VV2_CATVEI AS VV2CATTIP,"
	cQuery +=		" VVB_CATVEI AS CODCTV, VVB_DESCRI AS DESCTV, "
Else
	cQuery +=		" VV2_CATVEI AS VV2CATTIP,"
	cQuery +=		" VV8_TIPVEI AS CODCTV, VV8_DESCRI AS DESCTV, "
EndIf

cQuery +=		" VQ0_NUMPED "

If lVV1_DESVEI
	cQuery += ", VV1_DESVEI"
EndIf

cQuery += " FROM " + RetSqlName("VV1") + " VV1 "
cQuery += " JOIN " + RetSqlName("VV2") + " VV2 ON (VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.D_E_L_E_T_=' ' ) "

If MV_PAR05 == 1 // Utiliza Categoria do Veiculos
	cQuery += " JOIN " + RetSqlName("VVB") + " VVB ON (VVB.VVB_FILIAL='"+xFilial("VVB")+"' AND VV2.VV2_CATVEI=VVB.VVB_CATVEI AND VVB.D_E_L_E_T_=' ') "
Else
	cQuery += " JOIN " + RetSqlName("VV8") + " VV8 ON (VV8.VV8_FILIAL='"+xFilial("VV8")+"' AND VV2.VV2_TIPVEI=VV8.VV8_TIPVEI AND VV8.D_E_L_E_T_=' ') "
EndIf

cQuery += " JOIN " + RetSqlName("VE1") + " VE1 ON (VE1.VE1_FILIAL='"+xFilial("VE1")+"' AND VV2.VV2_CODMAR=VE1.VE1_CODMAR AND VE1.D_E_L_E_T_=' ') "
cQuery += " LEFT JOIN " + RetSqlName("VQ0") + " VQ0 ON (VQ0.VQ0_FILIAL='"+xFilial("VQ0")+"' AND VQ0.VQ0_CHAINT=VV1.VV1_CHAINT AND VQ0.D_E_L_E_T_=' ') "

cQuery += " WHERE VV1.VV1_FILIAL ='" + xFilial("VV1") + "'"
cQuery += 	" AND VV1.VV1_CHASSI <> ' '"
cQuery += " AND VV1.D_E_L_E_T_=' '"

if VV1->(FieldPos("VV1_TRANSM")) > 0 
	cQuery += " AND VV1.VV1_TRANSM <> '1' "
endif

//N„o Reservados
cQuery += 	" AND ( VV1.VV1_RESERV NOT IN ('1','3') OR ( VV1.VV1_RESERV IN ('1','3') AND VV1.VV1_DTHVAL >= '" + DtoC(ddatabase) + "/"+ cHoraVld +"' ) )"

//N„o em Remessa
cQuery += 	" AND VV1.VV1_SITVEI <> '3'"

//N„o est· em atendimento com pedido de venda vinculado
cQuery += " AND NOT EXISTS ( SELECT VV9.VV9_NUMATE "
cQuery += 					" FROM " + RetSqlName("VV9") + " VV9 "
cQuery += 					" INNER JOIN " + RetSqlName("VVA") + " VVA "
cQuery += 						"  ON VVA.VVA_FILIAL = VV9.VV9_FILIAL "
cQuery += 						" AND VVA.VVA_NUMTRA = VV9.VV9_NUMATE "
cQuery += 						" AND VVA.VVA_CHAINT = VV1.VV1_CHAINT "
cQuery += 						" AND VVA.D_E_L_E_T_ = ' ' "
cQuery += 					" INNER JOIN " + RetSqlName("VJK") + " VJK "
cQuery += 						"  ON VJK.VJK_FILTRA = VVA.VVA_FILIAL "
cQuery += 						" AND VJK.VJK_NUMTRA = VVA.VVA_NUMTRA "
cQuery += 						" AND VJK.VJK_ITETRA = VVA.VVA_ITETRA "
cQuery += 						" AND VJK.VJK_DELETE = '0' "
cQuery += 						" AND VJK.D_E_L_E_T_ = ' ' "
cQuery += 					" INNER JOIN " + RetSqlName("VJM") + " VJM "
cQuery += 						"  ON VJM.VJM_FILIAL = VJK.VJK_FILIAL "
cQuery += 						" AND VJM.VJM_CODVJJ = VJK.VJK_CODVJJ "
cQuery += 						" AND VJM.VJM_STATUS IN ('Ativo','Assinado') "
cQuery += 						" AND VJM.VJM_DELETE = '0' "
cQuery += 						" AND VJM.D_E_L_E_T_ = ' ' "
cQuery += 					" WHERE VV9.VV9_FILIAL = '" + xFilial("VV9") + "' "
cQuery += 					"   AND VV9.VV9_STATUS IN ('A','P','R')
cQuery += 					"   AND VV9.D_E_L_E_T_ = ' ' "
cQuery += 					" ) "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )

aVV1RecNo := {}

while !((cQryAl001)->(eof()))

	cIndicador := ""

	if Empty( (cQryAl001)->(VV2CATTIP) ) .or.;
		!( (cQryAl001)->(VV2CATTIP) $ MV_PAR03 .or. (cQryAl001)->(VV2CATTIP) $ MV_PAR04 )
		(cQryAl001)->(dbSkip())
		loop
	Else
		cIndicador := (cQryAl001)->(VV2CATTIP)
	endif

	nPosFilis := aScan(aFilis,{|x| Alltrim(x[1]) == Alltrim( (cQryAl001)->(VV1_FILENT) ) } )
	if nPosFilis > 0

		aInfoMov := {}
		aInfoMov := FM_VEIUMOV((cQryAl001)->(VV1_CHASSI))

		If ( cQryAl001 )->( VV1_SITVEI ) <> "8" // Pedido
			if Len(aInfoMov) == 0
				( cQryAl001 )->( DBSkip())
				loop
			endif
		EndIf

		aAdd(aVV1RecNo, (cQryAl001)->(VV1RECNO))
		VV1->(DbGoTo((cQryAl001)->(VV1RECNO))) // Posicionar no VV1 devido ao campo MEMO

		cInvStatus := OF210025_ConteudoTagINVST( ( cQryAl001 )->( VV1_SITVEI ) )

		nValVda := 0
		if cInvStatus == "V" //Vendido
			VVA->(DBSetOrder(1))
			if VVA->(DBSeek(aInfoMov[2]+aInfoMov[3]+(cQryAl001)->(VV1_CHASSI)))
				nValVda := VVA->VVA_VALMOV
			endif
		endif

		nValorVda := FGX_VLRSUGV(	(cQryAl001)->(VV1_CHAINT) ,;
									(cQryAl001)->(VV1_CODMAR) ,;
									(cQryAl001)->(VV1_MODVEI) ,;
									(cQryAl001)->(VV1_SEGMOD) ,;
									(cQryAl001)->(VV1_CORVEI) ,;
									.t. ;
								)

		nValorCus := 0
		If len(aInfoMov) > 0

			cQuery := "SELECT SB2.B2_CM1 "
			cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
			cQuery += 	" INNER JOIN " + RetSqlName("SB2") + " SB2 "
			cQuery += 		"  ON SB2.B2_FILIAL = '" + aInfoMov[2] + "' "
			cQuery += 		" AND SB2.B2_COD = SB1.B1_COD "
			cQuery += 		" AND SB2.B2_LOCAL = '" + (cQryAl001)->(VV1_LOCPAD) + "' "
			cQuery += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
			cQuery += 	" AND SB1.B1_GRUPO = '" + cGruVei + "' "
			cQuery += 	" AND SB1.B1_CODITE = '" + (cQryAl001)->(VV1_CHAINT) + "' "
			cQuery += 	" AND SB1.D_E_L_E_T_=' ' "
			cQuery += 	" AND SB2.D_E_L_E_T_=' '"
			
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlCus , .F., .T. )
			
			if !((cQryAlCus)->(eof()))
				nValorCus := (cQryAlCus)->(B2_CM1)
			endif
			
			(cQryAlCus)->(DBCloseArea())

		EndIf

		nPosFilEnt := aScan(aFilis,{|x| Alltrim(x[1]) == Alltrim( (cQryAl001)->(VV1_FILENT) ) } )

		aAdd(aXMLRequp[nPosFilis], {;
										(cQryAl001)->(VV1_CHAINT),; //STKNUM
										OF210015_ConteudoTagBAIND(cIndicador) ,; //BAIND
										(cQryAl001)->(VV1ESTVEI),; // NUIND
										aFilis[nPosFilEnt,2],; // STORDLR
										"",; // STORCITY
										"",; // STORSTATE
										cInvStatus,; // INVST
										Left((cQryAl001)->(VV1_FABMOD),4),; // YRMF
										Alltrim((cQryAl001)->(VE1_MAREDI)),; // MAKE
										Alltrim((cQryAl001)->(VE1_DESMAR)),; // MAKEDESC
										Left( (cQryAl001)->(VV2_MODFAB) , 10) ,; // MODEL
										Alltrim((cQryAl001)->(CODCTV)),; // CAT ou TIP
										Alltrim((cQryAl001)->(DESCTV)),; // CATDESC ou TIPDESC
										Alltrim( IIf( lVV1_DESVEI .and. !Empty((cQryAl001)->(VV1_DESVEI)), (cQryAl001)->(VV1_DESVEI), (cQryAl001)->(VV2_DESMOD) ) ),; // MACHDESC
										Alltrim((cQryAl001)->(VV1_CHASSI)),; // PIN
										"",; // METER
										"",; // METERUOM
										"",; // ATTQTY
										Alltrim(STR(nValorCus)),; // TCOST
										Alltrim(STR(nValorVda)),; // LIST
										IIf(len(aInfoMov)>0,dtos(aInfoMov[5]),""),; // DLC
										IIF(cInvStatus == "V", Alltrim(STR(nValVda)), ""),; // SALEPRC
										IIF(cInvStatus == "V", dtos(aInfoMov[5]),""),; //SALEDT
										"",; // EQPCOND
										"",; // SCOST
										IIf(lVV1_OBSVEI,VV1->VV1_OBSVEI,""),; // EQPNOTE
										"",; // OverAllowance
										"",; // NetSalePrice
										"",; // MDP
										"",; // EquipCost
										"",; // AddlCost
										(cQryAl001)->(VQ0_NUMPED),; // ORDNUM
										"",; // SURCHG
										"",; // INVAMT
										"",; // SURCHGAMT
										"",; // SALESBOOKVAL
										""; // BESTSELLPRICE
									} )
		//
		aAdd(aXMLRdetl[nPosFilis], {})
		aAdd(aXMLRaggr[nPosFilis], {})
		//
	ENDIF
	(cQryAl001)->(dbSkip())
enddo
//
(cQryAl001)->(dbCloseArea())
// ==========================================================================
// GERACAO DO ARQUIVO
// ==========================================================================
cMes := "JAN"
cMes := IIF(Month(ddatabase)==2,"FEB",cMes)
cMes := IIF(Month(ddatabase)==3,"MAR",cMes)
cMes := IIF(Month(ddatabase)==4,"APR",cMes)
cMes := IIF(Month(ddatabase)==5,"MAY",cMes)
cMes := IIF(Month(ddatabase)==6,"JUN",cMes)
cMes := IIF(Month(ddatabase)==7,"JUL",cMes)
cMes := IIF(Month(ddatabase)==8,"AUG",cMes)
cMes := IIF(Month(ddatabase)==9,"SEP",cMes)
cMes := IIF(Month(ddatabase)==10,"OCT",cMes)
cMes := IIF(Month(ddatabase)==11,"NOV",cMes)
cMes := IIF(Month(ddatabase)==12,"DEC",cMes)
//
cArquivo := "DLR2JD_" + ;
strzero(DAY(ddatabase),2) + ;
cMes + ;
STR(Year(ddatabase),4) + "_" + ;
SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + "_" + ;
Left(ALLTRIM(MV_PAR02) + SPACE(6),6) +  ".JDQuote"

nHnd := FCREATE(lower(Alltrim(MV_PAR01))+Alltrim(cArquivo),0)

fwrite(nHnd,NoAcento(( '<?xml version="1.0" encoding="UTF-8"?> ' + CRLF)))
fwrite(nHnd,NoAcento(( '<SOAP:Envelope xmlns:SOAP="urn:schemas-xmlsoap-org:soap.v1"> ' + CRLF)))
fwrite(nHnd,NoAcento(( '  <SOAP:Body> ' + CRLF)))
fwrite(nHnd,NoAcento(( '    <m:RetrieveEquipment xmlns:m="DBS-INPUT"> ' + CRLF)))
//
for nCntFor1 := 1 to Len(aXMLInput)
	//
	fwrite(nHnd,NoAcento(('     <INPUT> ' + CRLF)))
	fwrite(nHnd,NoAcento(('       <' + aINPUT[INPUT_EQPOWNER]+ '>' + Alltrim(aXMLInput[nCntFor1,INPUT_EQPOWNER]) +'</' + aINPUT[INPUT_EQPOWNER]+ '> ' + CRLF)))
	//
	for nCntFor2 := 1 to Len(aXMLRequp[nCntFor1])
		fwrite(nHnd,NoAcento(('       <REQUP> ' + CRLF)))
		for nCntTag := 1 to Len(aREQUP)
			fwrite(nHnd,NoAcento(('         <' + aREQUP[nCntTag]+ '>' + Alltrim(aXMLRequp[nCntFor1,nCntFor2,nCntTag]) +'</' + aREQUP[nCntTag]+ '> ' + CRLF)))
		next
		for nCntFor3 := 1 to Len(aXMLRdetl[nCntFor1,nCntFor2])
			fwrite(nHnd,NoAcento(('         <RDETL> ' + CRLF)))
			for nCntTag := 1 to Len(aRDETL)
				fwrite(nHnd,NoAcento(('           <' + aRDETL[nCntTag]+ '>' + Alltrim(aXMLRdetl[nCntFor1,nCntFor2,nCntFor3,nCntTag]) +'</' + aRDETL[nCntTag]+ '> ' + CRLF)))
			next
			fwrite(nHnd,NoAcento(('         </RDETL> ' + CRLF)))
		next
		for nCntFor3 := 1 to Len(aXMLRaggr[nCntFor1,nCntFor2])
			fwrite(nHnd,NoAcento(('         <RAGGR> ' + CRLF)))
			for nCntTag := 1 to Len(aRAGGR)
				fwrite(nHnd,NoAcento(('           <' + aRAGGR[nCntTag]+ '>' + Alltrim(aXMLRAggr[nCntFor1,nCntFor2,nCntFor3,nCntTag]) +'</' + aRAGGR[nCntTag]+ '> ' + CRLF))) 
			next
			fwrite(nHnd,NoAcento(('         </RAGGR> ' + CRLF)))
		next
		fwrite(nHnd,NoAcento(('       </REQUP> ' + CRLF)))
	next
	//
	fwrite(nHnd,NoAcento(('     </INPUT> ' + CRLF)))
next
//
fwrite(nHnd,NoAcento(( '    </m:RetrieveEquipment> ' + CRLF)))
fwrite(nHnd,NoAcento(( '  </SOAP:Body> ' + CRLF)))
fwrite(nHnd,NoAcento(( '</SOAP:Envelope> '  + CRLF)))
//
fClose(nHnd)
iif (IsSrvUnix(),CHMOD( lower(Alltrim(MV_PAR01))+Alltrim(cArquivo) , 666,,.f. ),CHMOD( lower(Alltrim(MV_PAR01))+Alltrim(cArquivo) , 2,,.f. ))
FRenameEx(lower(Alltrim(MV_PAR01))+Alltrim(cArquivo),lower(Alltrim(MV_PAR01))+UPPER(left(cArquivo,len(Alltrim(cArquivo))-8))+".JDQuote")

if VV1->(FieldPos("VV1_TRANSM")) > 0 
	DBSelectArea("VV1")
	for nCntFor1 := 1 to Len(aVV1RecNo)
		DBGoto(aVV1RecNo[nCntFor1])
		reclock("VV1", .f.)
		VV1->VV1_TRANSM := "1"
		msunlock()
	next
endif

MsgInfo(STR0014+chr(13)+chr(10)+STR0015+Alltrim(MV_PAR01)+Alltrim(cArquivo),UPPER(Alltrim(MV_PAR01)+left(cArquivo,len(Alltrim(cArquivo))-8))+".JDQuote")
	
return



Static Function OF210015_ConteudoTagBAIND( cIndicador )

	Local cTagBaind := "A"

	If !Empty(cIndicador) .and. (cIndicador $ MV_PAR03)
		cTagBaind := "B"
	EndIf

Return cTagBaind



Static Function OF210025_ConteudoTagINVST( cSitVei )

	Local cRetorno := "I"

	if cSitVei == "0" // Estoque
		cRetorno := "I"
	elseif cSitVei == "1" // Vendido
		cRetorno := "V"
	elseif cSitVei == "2" .or.; // Transito
			cSitVei == "5" .or.; // Transferido
			cSitVei == "7" .or.; // Progresso
			cSitVei == "8" // Pedido
		cRetorno := "H"
	elseif cSitVei == "3" .or.; // Remessa
			cSitVei == "4" // Consignado
		cRetorno := "L"
	elseif cSitVei == "6" // Reservado
		cRetorno := "O"
	endif

Return cRetorno