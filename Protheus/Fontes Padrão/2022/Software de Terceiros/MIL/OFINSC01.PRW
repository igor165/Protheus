// ษออออออออหออออออออป
// บ Versao บ 009    บ
// ศออออออออสออออออออผ

#Include "PROTHEUS.CH"
#Include "OFIXDEF.CH"
#Include "Topconn.CH"
#Include "Fileio.CH"
#include "tbiconn.ch"
#include "OFINSC01.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFINSC01  บAutor  ณCarla Catiane F R   บ Data ณ  22/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWHI Scania.                                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออฯอออออออออออออออออออออออออออออออออ
ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFINSC01(aParam)

// Variaveis da ParamBox
Local aSay    := {}
Local aButton := {}
Local nOpc    := 0
//
Local cTitulo := STR0001
Local cDesc1  := STR0002
Local cDesc2  := STR0003
//
lAuto := .f.
//
Private cPerg := "OFINSC01"

	
If ValType(aParam) != "U" //Chamada Automแtica

	cEmpr := aParam[1]
	cFil  := aParam[2]

	nModulo := 11
	cModulo := "OFI"
	__cInternet := 'AUTOMATICO'
		
	If Type("cArqTab")=="U"
		cArqTab:=""
	EndIf
		
	cFOPENed := ""
		
	dDataBase:= Date()
		
	FS_OPENARQ()

	lAuto := .t.

	MV_Par01 := dDataBase - 1		
	MV_Par02 := dDataBase
	
	OFSC01(.f., .t.)//Grava tabela intermediแria
	OFSC02(.f., .t.)//Gera arquivos XML.
	
Else
		
	CriaSX1()
		
	DbSelectArea("VDW")	
		
	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
		
	aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
	aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
	aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
		
	Pergunte(cPerg,.f.)
	
	FormBatch( cTitulo, aSay, aButton )
		
	If nOpc <> 1
		Return
	Endif
		
	//#############################################################################
	//# Chama a rotina de gravacao da VDW - WHI Scania                            #
	//#############################################################################
	RptStatus( {|lEnd| OFSC01(@lEnd, lAuto)}, STR0004, STR0005, .T. )//Grava tabela intermediแria
	RptStatus( {|lEnd| OFSC02(@lEnd, lAuto)}, STR0012, STR0005, .T. )//Gera arquivos XML

Endif
	


Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    | OFSC01     | Autor |Carla Catiane F R      | Data | 24/04/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri็ใo | Filtra as ordens de servi็o abertas e fechadas, faz a grava- |##
##|          | ็ใo na tabela VDW para gera็ใo dos XML que serใo enviados ao |##
##|          | WHI.                                                         |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFSC01(lEnd, lAuto, cNumOsv, cTipTem, cLibVOO )

Local cQuery  := ""
Local cQryVO1 := "SQLVO1"
Local cUsuInc := Subs(cUsuario,7,15)
Local nCont   := 0
Local lLIBVOO := VOO->(FieldPos("VOO_LIBVOO")) > 0

If !TCCanOpen(RetSqlName("VDW"))
	If !lAuto
		MsgInfo( STR0011, STR0009 )
	EndIf
	Return
EndIf

DbSelectArea("VDW")
DbSetOrder(1)

If FM_PILHA("OFIXX100") .or. FM_PILHA("OFIOM010") .or. FM_PILHA("OFIOM150")

	If !( VDW->( DbSeek( xFilial("VDW") + cNumOsv ) ) )
		
		VOI->(DbSetOrder(1))
		VOI->(DbSeek(xFilial("VOI")+cTipTem))
		If VOI->VOI_TPOKLM == "0" // Silvania (email) - 26/06/2019 - S๓ vai para WHI se Tipo de Tempo nao for de kilometragem
			DbSelectArea("VDW")
			Reclock("VDW",.t.)
			VDW->VDW_FILIAL := xFilial("VDW")
			VDW->VDW_NUMOSV := cNumOsv
			VDW->VDW_TIPTEM := cTipTem
			VDW->VDW_LIBVOO := cLibVOO
			VDW->VDW_STATUS := VO1->VO1_STATUS
			VDW->VDW_USUARI := cUsuInc
			nCont++
			MsUnlock()
		EndIf

	Else

		If FM_PILHA("OFIXX100") .or. FM_PILHA("OFIOM150")
			DbSelectArea("VDW")
			Reclock("VDW",.f.)
			VDW->VDW_DATENV := Ctod("")
			MsUnLock()
		Endif
		
	EndIf

Else //If (Funname() == "OFINSC01") .or. lAuto // Menu ou Schedule

	If Select(cQryVO1) > 0
		(cQryVO1)->(DbCloseArea())
	EndIf
	//Pesquisa todas as ordens com requisi็ใo de pecas
	cQuery := " SELECT DISTINCT VO1.VO1_FILIAL, VO1.VO1_NUMOSV, VO1.VO1_STATUS, VO3.VO3_TIPTEM "
	if lLIBVOO
		cQuery += ", VO3.VO3_LIBVOO "
	endif
	cQuery += "FROM " + RetSqlName("VO1") + " VO1 "
	cQuery += " INNER JOIN " + RetSqlName("VO3") + " VO3 "
	cQuery += " 	  ON VO3.VO3_FILIAL = '" + xFilial("VO3") + "' AND VO1.VO1_NUMOSV = VO3.VO3_NUMOSV AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("VOI") + " VOI "
	cQuery += " 	  ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO3.VO3_TIPTEM AND VOI.VOI_TPOKLM = '0' AND VOI.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND "
	cQuery += "       VO1.VO1_DATABE >= '" + Dtos( mv_par01 )+ "' AND VO1.VO1_DATABE <= '" + Dtos( mv_par02 )+ "' AND "
	cQuery += "       VO1.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VO1.VO1_NUMOSV "
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryVO1, .F., .T. )
	nTotReg := Contar( cQryVO1, "!Eof()" )
	
	If !lAuto
		SetRegua( nTotReg )
	Endif
	
	(cQryVO1)->( DBGoTop() )
	
	If (cQryVO1)->( Eof() )
		If !lAuto
			MsgStop( STR0008, STR0009 )
		Endif
		(cQryVO1)->( DbCloseArea() )
		DbSelectArea("VO1")
		Return
	Endif
	
	While !(cQryVO1)->( Eof() )
		
		If !VDW->( DbSeek( xFilial("VDW") + (cQryVO1)->( VO1_NUMOSV )  ) )

			DbSelectArea("VDW")
			RecLock("VDW",.t.)
			VDW->VDW_FILIAL := xFilial("VDW")
			VDW->VDW_NUMOSV := (cQryVO1)->( VO1_NUMOSV )
			VDW->VDW_TIPTEM := (cQryVO1)->( VO3_TIPTEM )
			If lLIBVOO
				VDW->VDW_LIBVOO := (cQryVO1)->( VO3_LIBVOO )
			EndIf
			VDW->VDW_STATUS := (cQryVO1)->( VO1_STATUS )
			VDW->VDW_USUARI := cUsuInc
			nCont++
			MsUnlock()
			
		EndIf
		
		(cQryVO1)->(DbSkip())
		
	EndDo
	
	If Select(cQryVO1) > 0
		(cQryVO1)->(DbCloseArea())
	EndIf
	//Pesquisa todas as ordens com apontamento
	cQuery := " SELECT DISTINCT VO1.VO1_FILIAL, VO1.VO1_NUMOSV, VO1.VO1_STATUS, VO4.VO4_TIPTEM "
	if lLIBVOO
		cQuery += ", VO4.VO4_LIBVOO "
	endif
	cQuery += " FROM " + RetSqlName("VO1") + " VO1 "
	cQuery += " INNER JOIN " + RetSqlName("VO4") + " VO4 "
	cQuery += " 	  ON VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO1.VO1_NUMOSV = VO4.VO4_NUMOSV AND VO4.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("VOI") + " VOI "
	cQuery += " 	  ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO4.VO4_TIPTEM AND VOI.VOI_TPOKLM = '0' AND VOI.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "' AND "
	cQuery += "       VO1.VO1_DATABE >= '" + Dtos( mv_par01 )+ "' AND VO1.VO1_DATABE <= '" + Dtos( mv_par02 )+ "' AND "
	cQuery += "       VO1.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VO1.VO1_NUMOSV "
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryVO1, .F., .T. )
	nTotReg := Contar( cQryVO1, "!Eof()" )
	
	If !lAuto
		SetRegua( nTotReg )
	Endif
	
	(cQryVO1)->( DBGoTop() )
	
	If (cQryVO1)->( Eof() )
		If !lAuto
			MsgStop( STR0008, STR0009 )
		Endif
		(cQryVO1)->( DbCloseArea() )
		DbSelectArea("VO1")
		Return
	Endif
	
	While !(cQryVO1)->( Eof() )
		
		If !VDW->( DbSeek( xFilial("VDW") + (cQryVO1)->( VO1_NUMOSV ) ) ) 
			Reclock("VDW",.t.)
			VDW->VDW_FILIAL := xFilial("VDW")
			VDW->VDW_NUMOSV := (cQryVO1)->( VO1_NUMOSV )
			VDW->VDW_TIPTEM := (cQryVO1)->( VO4_TIPTEM )
			if lLIBVOO
				VDW->VDW_LIBVOO := (cQryVO1)->( VO4_LIBVOO )
			endif
			VDW->VDW_STATUS := (cQryVO1)->( VO1_STATUS )
			VDW->VDW_USUARI := cUsuInc
			nCont++
			MsUnlock()
		EndIf
		
		(cQryVO1)->(DbSkip())
		
	EndDo
	
	If nCont > 0 .and. !lAuto
		MsgInfo(STR0010,STR0009)
	EndIf
	
	(cQryVO1)->( DbCloseArea() )
	DbSelectArea("VO1")
	
EndIf

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    | OFSC02     | Autor |Carla Catiane F R      | Data | 25/04/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri็ใo | Filtra os registros da VDW que nao foram enviados ao whi e   |##
##|          | gera os arquivos XML para envio.                             |##
##|          | Projeto WHI.                                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFSC02(lEnd, lAuto)

Local i		
Local nOs   	:= 0
Local cQuery   := " "
Local nQtdReg  := GetNewPar( "MV_MIL0030", 1 )
Local cDirXML  := GetNewPar( "MV_MIL0031", __RelDir+ ALLTRIM(" \ ") )
Local cSendDMS := GetNewPar( "MV_MIL0033", "TotvsProtheus_BR_ESC")
Local cArquivo := ""
Local aVetNome := {}
Local aVetTam  := {}
Local aVetData := {}
Local aVetHora := {}
Local lErro    := .f.
Local aStatus  := {}
Local cStatus  := ""
Local nStatus  := 0
Local dDtDisp  := Stod( "  /  /    " )
Local nHrDisp  := 0
Local nCont    := 0
Local cNroOS   := ""
Local nContP   := 0
Local nContS   := 0 
Local lAchou   := .t.

Private aTTP     := {}
Private aTTS     := {}
Private aSer     := {}
Private aPec     := {}
Private cQryVDW  := "SQLVDW"
Private lLIBVOO := VOO->(FieldPos("VOO_LIBVOO")) > 0

If !TCCanOpen(RetSqlName("VDW"))
	If !lAuto
		MsgInfo( STR0011, STR0009 )
	EndIf
	Return
EndIf

DbSelectArea("VO1")
DbSetOrder(1)

DbSelectArea("VO4")
DbSetOrder(10)

DbSelectArea("VO3")
DbSetOrder(8)

DbSelectArea("VOI")
DbSetOrder(1)

//Tabela 18.3 MaintenanceOrderStatuses
aAdd(aStatus,{"A","Open"})   //Aberta
aAdd(aStatus,{"D","Open"})   //Aberta
aAdd(aStatus,{"F","Closed"}) //Fechada
aAdd(aStatus,{"C","Cancelled"}) //Cancelada

//If !lAuto //Chamado por menu
	
	If Select(cQryVDW) > 0
		(cQryVDW)->(DbCloseArea())
	EndIf
	
	cQuery := " SELECT * FROM " + RetSqlName("VDW") + " VDW "
	cQuery += " WHERE VDW_FILIAL = '" + xFilial("VDW") + "' AND "
	cQuery += "       VDW_DATENV = '        ' AND VDW.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY VDW_NUMOSV "
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryVDW, .F., .T. )
	nTotReg := Contar( cQryVDW, "!Eof()" )
	
	(cQryVDW)->( DBGoTop() )
	
	If nTotReg <= 0
		If !lAuto
			MsgInfo( STR0014, STR0009 )
		Endif
		(cQryVDW)->( DbCloseArea() )
		DbSelectArea("VO1")
		Return
	EndIf
	
	If !lAuto
		SetRegua( nTotReg )
	EndIf
	
	While !(cQryVDW)->( Eof() )
	
		If cNroOS == (cQryVDW)->(VDW_NUMOSV)
		
			DbSelectArea("VDW")
			DbGoto( (cQryVDW)->( R_E_C_N_O_ ))
			Reclock("VDW",.f.)
			VDW->VDW_DATENV := dDataBase 
			MsUnlock()
			lAchou := .t.
		
			(cQryVDW)->( DbSkip() )
			Loop
		Else
			cNroOS := (cQryVDW)->(VDW_NUMOSV)
			lAchou := .f.
		Endif
		
		//#############################################################################
		//# Tenta abrir o arquivo texto                                               #
		//#############################################################################
		cArquivo := cSendDMS + Alltrim( SM0->M0_CODFIL ) + "_" +;
		StrZero(Year(dDataBase),4) + StrZero(Month(dDataBase),2) + StrZero(Day(dDataBase),2) +;
		StrZero(Val((Substr(Time(),1,2))),2) + StrZero(Val((Substr(Time(),4,2))),2) + StrZero(Val((Substr(Time(),7,2))),2) +;
		StrZero((Seconds() - int(Seconds()))*1000,3)+".XML"
		//
		if aDir( Alltrim( cDirXML ) + cArquivo, aVetNome, aVetTam, aVetData, aVetHora ) > 0 .and. !lAuto
			if !MsgYesNo( STR0013, STR0009 )
				lErro := .t.
				( cQryVDW)->( DbCloseArea() )
				DbSelectArea("VO1")
				Return
			endif
		endif
		//
		nHnd := FCREATE(Alltrim(cDirXML)+Alltrim(cArquivo),0)
		
		//Cabe็alho arquivo
		FS_GRVLIN("<?xml version='1.0' encoding='UTF-8' ?>"+CHR(13)+CHR(10))
		FS_GRVLIN("<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:v2='http://xmlns.scania.com/WHIService/v2'>"+CHR(13)+CHR(10))
		FS_GRVLIN("<soapenv:Header />"+CHR(13)+CHR(10))
		FS_GRVLIN("<soapenv:Body>"+CHR(13)+CHR(10))
		
		//Adiciona novas ordens de servi็o no arquivo
		FS_GRVLIN("<AddMaintenanceOrderRequest xmlns='http://xmlns.scania.com/WHIService/v2'>"+CHR(13)+CHR(10))
		FS_GRVLIN("<MaintenanceOrders xmlns:i='http://www.w3.org/2001/XMLSchema-instance'>"+CHR(13)+CHR(10))

		nOs:= 1		
		i:= 1
		While nOs <= nQtdReg .and. !(cQryVDW)->( Eof() )
			
			If cNroOS == (cQryVDW)->(VDW_NUMOSV)  .and. lAchou
			
				DbSelectArea("VDW")
				DbGoto( (cQryVDW)->( R_E_C_N_O_ ))
				Reclock("VDW",.f.)
				VDW->VDW_DATENV := dDataBase
				MsUnlock()
				lAchou := .t.
		
				(cQryVDW)->( DbSkip() )
				Loop
			Else
				cNroOS := (cQryVDW)->(VDW_NUMOSV)
				lAchou := .f.
			Endif

			VO1->( DbSeek( xFilial("VO1") + (cQryVDW)->VDW_NUMOSV ) )
			//
			aTTP := {}
			aTTS := {}	
			//
//			nStatus := aScan( aStatus,{ |x| x[1] == (cQryVDW)->VDW_STATUS })
			nStatus := aScan( aStatus,{ |x| x[1] == VO1->VO1_STATUS })
			If nStatus > 0
				cstatus  := aStatus[ nStatus, 2 ]
			Endif
			
			aSer := FMX_CALSER(;
						(cQryVDW)->VDW_NUMOSV,; // cNumOS
						,;                      // cTipTem
						"",;                    // cGruSer
						"",;                    // cCodSer
						.t.,;                   // lApont
						.f.,;                   // lNegoc
						.f.,;                   // lRetAbe
						.t.,;                   // lRetLib
						.t.,;                   // lRetFec
						.f.,;                   // lRetCan
						)                       // cLibVOO

			aPec := FMX_CALPEC(;
						(cQryVDW)->VDW_NUMOSV,; // cNumOS
						,;                      // cTipTem
						"",;                    // cGruIte
						"",;                    // cCodIte
						.t.,;                   // lMov
						.f.,;                   // lNegoc
						.t.,;                   // lReqZerada
						.f.,;                   // lRetAbe
						.t.,;                   // lRetLib
						.t.,;                   // lRetFec
						.f.,;                   // lRetCan
						,;                      // cLibVOO
						"",;                    // cFiltroSQL
						.f.,;                   // lRetRem
						.f.)                    // lAgrInc

			//Pecas
			For nContP := 1 to Len(aPec)
				If aPec[nContP,PECA_DATLIB] == Ctod("")
					dDtDisp := aPec[1,PECA_DATLIB]
					nHrDisp := 0
//					cStatus := "Open"
					Exit        
				Else
					If aPec[nContP,PECA_DATLIB] > dDtDisp
						dDtDisp := aPec[nContP,PECA_DATLIB]
						nHrDisp := 1700
					Endif
				Endif
/*				If aPec[nContP,PECA_DATFEC] <> Ctod("")
					cStatus := "Closed"
				ElseIf aPec[nContP,PECA_DATFEC] <> Ctod("")
					cStatus := "Closed"
				Endif
*/			Next
            // Servicos
			For nContS := 1 to Len(aSer)
				If aSer[nContS,SRVC_DATLIB] == Ctod("")
					dDtDisp := aSer[1,SRVC_DATLIB]
					nHrDisp := 0
//					cStatus := "Open"
					Exit        
				Else
					If aSer[nContS,SRVC_DATLIB] > dDtDisp
						dDtDisp := aSer[nContS,SRVC_DATLIB]
						nHrDisp := 1700
					Endif
				Endif
/*				If aSer[nContS,SRVC_DATFEC] <> Ctod("")
					cStatus := "Closed"
				Endif
*/			Next

			FS_GRVLIN("<MaintenanceOrder>"       +CHR(13)+CHR(10))
			FS_GRVLIN("<MaintenanceOrderHeader>" +CHR(13)+CHR(10))
			
			FS_GRVLIN("<ArrivalDate>" +;
			StrZero(Year(VO1->VO1_DATABE),4) + "-" + StrZero(Month(VO1->VO1_DATABE),2) + "-" + StrZero(Day(VO1->VO1_DATABE),2) +;
			"T" + StrZero(Val(Left(Transform(VO1->VO1_HORABE,"@R 99:99"),2)),2)+":"+StrZero(Val(Substr(Transform(VO1->VO1_HORABE,"@R 99:99"),4,2)),2)+":00"+;
			"</ArrivalDate>"+CHR(13)+CHR(10))
			
			If !Empty( dDtDisp ) .and. nHrDisp > 0
				FS_GRVLIN("<CompletionDate>" +;
				StrZero(Year(dDtDisp),4) + "-" + StrZero(Month(dDtDisp),2) + "-" + StrZero(Day(dDtDisp),2) +;
				"T" + StrZero(Val(Left(Transform(nHrDisp,"@R 99:99"),2)),2)+":"+StrZero(Val(Substr(Transform(nHrDisp,"@R 99:99"),4,2)),2)+":00"+;
				"</CompletionDate>" + CHR(13) + CHR(10))
			EndIf
			
			FS_GRVLIN("<CreationDate>" + ;
			StrZero(Year(VO1->VO1_DATABE),4) + "-" + StrZero(Month(VO1->VO1_DATABE),2) + "-" + StrZero(Day(VO1->VO1_DATABE),2) +;
			"T" + StrZero(Val(Left(Transform(VO1->VO1_HORABE,"@R 99:99"),2)),2)+":"+StrZero(Val(Substr(Transform(VO1->VO1_HORABE,"@R 99:99"),4,2)),2)+":00"+;
			"</CreationDate>"+CHR(13)+CHR(10))
			
			
//			FS_GRVLIN("<DMSMaintenanceOrderID>"   + Alltrim( SM0->M0_CODIGO ) + Alltrim( SM0->M0_CODFIL ) + Alltrim( (cQryVDW)->VDW_TIPTEM ) + (cQryVDW)->VDW_NUMOSV + "</DMSMaintenanceOrderID>"+CHR(13)+CHR(10))
			FS_GRVLIN("<DMSMaintenanceOrderID>"   + Alltrim( SM0->M0_CODIGO ) + Alltrim( SM0->M0_CODFIL ) + (cQryVDW)->VDW_NUMOSV + "</DMSMaintenanceOrderID>"+CHR(13)+CHR(10))
			FS_GRVLIN("<DMSUniqueExtensionField>" + StrZero(Year(VO1->VO1_DATABE),4) + "</DMSUniqueExtensionField>"+CHR(13)+CHR(10))
			FS_GRVLIN("<DocumentID>"              + Alltrim( VO1->VO1_NUMOSV ) 	    + "</DocumentID>"+CHR(13)+CHR(10))
			
			//Dados Concessionaria
			FS_GRVLIN(FS_DDCONC())

			VOI->(dbSetOrder(1))
			// Pecas
			For nContP := 1 to Len(aPec)
				If aScan( aTTP,{|x| x[1] == aPec[nContP,PECA_TIPTEM]}) == 0
					VOI->(MSSeek(xFilial("VOI")+aPec[nContP,PECA_TIPTEM]) )
					If VOI->VOI_TPOKLM == "0" // Silvania (email) - 26/06/2019 - S๓ vai para WHI se Tipo de Tempo nao for de kilometragem
						aadd(aTTP,{aPec[nContP,PECA_TIPTEM],aPec[nContP,PECA_NUMOSV],aPec[nContP,PECA_LIBVOO]})
					Endif
				Endif                                   
			Next
            // Servicos
			For nContS := 1 to Len(aSer)
				If aScan( aTTS,{|x| x[1] == aSer[nContS,SRVC_TIPTEM]}) == 0
					VOI->(MSSeek(xFilial("VOI")+aSer[nContS,SRVC_TIPTEM]) )
					If VOI->VOI_TPOKLM == "0" // Silvania (email) - 26/06/2019 - S๓ vai para WHI se Tipo de Tempo nao for de kilometragem
						aadd(aTTS,{aSer[nContS,SRVC_TIPTEM],aSer[nContS,SRVC_NUMOSV],aSer[nContS,SRVC_LIBVOO]})
					Endif
				Endif                                   
			Next
			
			//Invoice - dados da NF
			FS_GRVLIN("<Invoices>")
			// Pecas
			For nContP := 1 to Len(aTTP)
				FS_GRVLIN(FS_DDNF("P",aTTP[nContP,1],aTTP[nContP,2],aTTP[nContP,3],nContP))
			Next
			// Servi็os
			For nContS := 1 to Len(aTTS)
				FS_GRVLIN(FS_DDNF("S",aTTS[nContS,1],aTTS[nContS,2],aTTS[nContS,3],nContS))
			Next
			FS_GRVLIN("</Invoices>")
			
			//ItemMaster - Dados do Veํculo
			FS_GRVLIN(FS_DDVEIC())
			
			FS_GRVLIN("<MaintenanceOrderStatus>" + cStatus  + "</MaintenanceOrderStatus>"+CHR(13)+CHR(10))
			FS_GRVLIN("<MeterRecording>"		  	 + Alltrim(Transform( VO1->VO1_KILOME, "99999999")) + "</MeterRecording>"+CHR(13)+CHR(10))
			FS_GRVLIN("<MeterRecordingUnit>" 	 + "Kilometers" + "</MeterRecordingUnit>"+CHR(13)+CHR(10))
			
			//Dados Prop. Veํculo.
			FS_GRVLIN(FS_DDCLI())
			//          FS_GRVLIN("<ScaniaAssistanceCase>" +"x" + "</ScaniaAssistanceCase>"+CHR(13)+CHR(10))
			FS_GRVLIN("<SendingSystem>" + cSendDMS + "</SendingSystem>"+CHR(13)+CHR(10))
			
			FS_GRVLIN("</MaintenanceOrderHeader>"+CHR(13)+CHR(10))

			//Corpo do XML.
			If VO1->VO1_STATUS != "C" .and. ( len(aTTP) > 0 .or. len(aTTS) > 0 )//!Empty( (cQryVDW)->VDW_TIPTEM ) //Cancelada

				FS_GRVLIN("<MaintenanceOrderJobs>"+CHR(13)+CHR(10))
				// Pecas
				For nContP := 1 to Len(aTTP)
					VOI->( DbSeek( xFilial("VOI") + aTTP[nContP,1] ))
	
					FS_GRVLIN("<MaintenanceOrderJob>"+CHR(13)+CHR(10))
					FS_GRVLIN("<DMSMaintenanceOrderJobID>" + Alltrim( (cQryVDW)->VDW_FILIAL ) + Alltrim( aTTP[nContP,1] ) + (cQryVDW)->VDW_NUMOSV + "</DMSMaintenanceOrderJobID>"+CHR(13)+CHR(10))
					FS_GRVLIN("<Description>" + Alltrim( VOI->VOI_DESTTE ) + "</Description>"+CHR(13)+CHR(10))
					
					//Dados Garantia
					FS_GRVLIN(FS_DDGAR( aTTP[nContP,1] ))
					FS_GRVLIN("<JobNo>" + Alltrim( Transform( i, "9999" ) ) + "</JobNo>"+CHR(13)+CHR(10))
					i++
					//Dados Itens
					FS_GRVLIN(FS_DDITEM( "P", nContP, aTTP[nContP,1] ))
					
					FS_GRVLIN("</MaintenanceOrderJob>"+CHR(13)+CHR(10))
				Next
				
				//Servicos
				For nContS := 1 to Len(aTTS)
					
					VOI->( DbSeek( xFilial("VOI") + aTTS[nContS,1] ) ) 
					
					FS_GRVLIN("<MaintenanceOrderJob>"+CHR(13)+CHR(10))
					FS_GRVLIN("<DMSMaintenanceOrderJobID>" + Alltrim( (cQryVDW)->VDW_FILIAL ) + Alltrim( aTTS[nContS,1] ) + (cQryVDW)->VDW_NUMOSV + "</DMSMaintenanceOrderJobID>"+CHR(13)+CHR(10))
					FS_GRVLIN("<Description>" + Alltrim( VOI->VOI_DESTTE ) + "</Description>"+CHR(13)+CHR(10))
					
					//Dados Garantia
					FS_GRVLIN(FS_DDGAR( aTTS[nContS,1] ))
					FS_GRVLIN("<JobNo>" + Alltrim( Transform( i, "9999" ) ) + "</JobNo>"+CHR(13)+CHR(10))
					i++
					//Dados Itens
					FS_GRVLIN(FS_DDITEM( "S", nContS, aTTS[nContS,1]  ))
					
					FS_GRVLIN("</MaintenanceOrderJob>"+CHR(13)+CHR(10))

				Next
	
				FS_GRVLIN("</MaintenanceOrderJobs>"+CHR(13)+CHR(10)						)
			EndIf

			FS_GRVLIN("</MaintenanceOrder>"+CHR(13)+CHR(10))
			
			nOs++
			i:= 1
			
			DbSelectArea("VDW")
			DbGoto( (cQryVDW)->( R_E_C_N_O_ ))
			Reclock("VDW",.f.)
			VDW->VDW_DATENV := dDataBase
			MsUnlock()
			
			(cQryVDW)->(DbSkip())
			
		EndDo
		
		FS_GRVLIN("</MaintenanceOrders>"+CHR(13)+CHR(10))
		
		//		FS_GRVLIN("<PayerTypeCode>" +"x" + "</PayerTypeCode>"+CHR(13)+CHR(10))
		//		FS_GRVLIN("<PayerTypeDescription>" +"x" + "</PayerTypeDescription>"+CHR(13)+CHR(10))
		FS_GRVLIN("<Username>" + cSendDMS + "</Username>"+CHR(13)+CHR(10))
		
		FS_GRVLIN("</AddMaintenanceOrderRequest>"+CHR(13)+CHR(10))
		
		//Fim arquivo XML.
		FS_GRVLIN("</soapenv:Body>"+CHR(13)+CHR(10))
		FS_GRVLIN("</soapenv:Envelope>"+CHR(13)+CHR(10))

//		fwrite(nHnd,cLinha)
		fClose(nHnd)
		
	EndDo

	If nOs > 0 .and. !lAuto
		MsgInfo( STR0015 + cDirXML, STR0009 )
	EndIf
	
	(cQryVDW)->( DbCloseArea() )

//Endif

DbSelectArea("VO1")

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    | FS_DDCONC  | Autor |Carla Catiane F R      | Data | 25/04/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri็ใo | Levanda dados da concessionaria para criacao do XML.         |##
##|          | Projeto WHI Scania.                                          |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_DDCONC()

Local cString := ""
Local cCodCon := GetNewPar( "MV_MIL0005", "" )

cString := "<Facility>"       + CHR(13)+CHR(10)
cString += 	 "<Address>"    + Alltrim( SM0->M0_ENDENT ) + "</Address>"    + CHR(13)+CHR(10)
cString += 	 "<CityName>"   + Alltrim( SM0->M0_CIDENT ) + "</CityName>"   + CHR(13)+CHR(10)
cString +=     "<ID>"		  + Alltrim( SM0->M0_CGC    ) + "</ID>"         + CHR(13)+CHR(10)
cString +=     "<Name>" 	 	  + Alltrim( SM0->M0_NOME   ) + "</Name>"       + CHR(13)+CHR(10)
cString +=     "<PostalCode>" + Alltrim( SM0->M0_CEPENT ) + "</PostalCode>" + CHR(13)+CHR(10)
cString += 	 "<SISID>" 	  + Alltrim( cCodCon        ) + "</SISID>"      + CHR(13)+CHR(10)
cString += "</Facility>"      + CHR(13)+CHR(10)

Return cString

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    | FS_DDNF    | Autor |Carla Catiane F R      | Data | 25/04/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri็ใo | Levanta dados das Notas Fiscais relacionadas a OS, para cri- |##
##|          | a็ใo do XML.                                                 |##
##|          | Projeto WHI.                                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_DDNF(cPecSer,_cTipTem,_cNumOsv,_cLIBVOO,_nCont)

Local cString := ""

DbSelectArea("SF2")
DbSetOrder(1)//NF + Serie

DbSelectArea("VOO")
DbSetOrder(1)//Numosv + tiptem + libvoo

//Nใo hแ libera็ใo ou NF
If cPecSer == "P"
	If !VOO->(DbSeek( xFilial("VOO")+aTTP[_nCont,2]+aTTP[_nCont,1]+aTTP[_nCont,3])) .or. Empty(VOO->VOO_NUMNFI)
//	If !VOO->(DbSeek( xFilial("VOO")+_cNumOsv+_cTipTem+_cLibVOO)) .or. Empty(VOO->VOO_NUMNFI)
		Return cString
	EndIf
	
//	cString += "<Invoices>"
	
	While !VOO->(Eof()) .and. xFilial("VOO") == VOO->VOO_FILIAL .and.;
		aTTP[_nCont,2]+aTTP[_nCont,1] == VOO->VOO_NUMOSV + VOO->VOO_TIPTEM
		//_cNumOsv+_cTipTem == VOO->VOO_NUMOSV + VOO->VOO_TIPTEM		
		if lLIBVOO
			If aTTP[_nCont,3] != VOO->VOO_LIBVOO
			//If cLibVOO != VOO->VOO_LIBVOO
				VOO->(DbSkip())
				Loop
			EndIf
		endif
		
		If SF2->( DbSeek(xFilial("SF2") + VOO->VOO_NUMNFI + VOO->VOO_SERNFI ) )
		
			cString += "<Invoice>" +CHR(13)+CHR(10)
			cString += 		"<InvoiceDate>"
			cString += 				StrZero(Year(SF2->F2_EMISSAO),4) + "-" + StrZero(Month(SF2->F2_EMISSAO),2) + "-" + StrZero(Day(SF2->F2_EMISSAO),2) +;
			"T" + StrZero(Val(Left(Transform(SF2->F2_HORA,"@R 99:99"),2)),2)+":"+StrZero(Val(Substr(Transform(SF2->F2_HORA,"@R 99:99"),4,2)),2)+":00"
			cString += 		"</InvoiceDate>"+CHR(13)+CHR(10)
			cString += 		"<InvoiceNo>" + Alltrim(SF2->F2_DOC) + "_" + Alltrim( FGX_MILSNF("SF2", 2, "F2_SERIE") ) + "</InvoiceNo>"+CHR(13)+CHR(10)
			cString += 		"<IsCreditOrder>false</IsCreditOrder>"+CHR(13)+CHR(10)
			cString += "</Invoice>"+CHR(13)+CHR(10)
			
		Endif
		
		DbSelectArea("VOO")
		DbSkip()
		
	EndDo               
Else
	If !VOO->(DbSeek( xFilial("VOO")+aTTS[_nCont,2]+aTTS[_nCont,1]+aTTS[_nCont,3])) .or. Empty(VOO->VOO_NUMNFI)
//	If !VOO->(DbSeek( xFilial("VOO")+_cNumOsv+_cTipTem+_cLibVOO)) .or. Empty(VOO->VOO_NUMNFI)
		Return cString
	EndIf
	
//	cString += "<Invoices>"
	
	While !VOO->(Eof()) .and. xFilial("VOO") == VOO->VOO_FILIAL .and.;
		aTTS[_nCont,2]+aTTS[_nCont,1] == VOO->VOO_NUMOSV + VOO->VOO_TIPTEM
		//_cNumOsv+_cTipTem == VOO->VOO_NUMOSV + VOO->VOO_TIPTEM
		
		if lLIBVOO
			If aTTS[_nCont,3] != VOO->VOO_LIBVOO
			//If _cLibVOO != VOO->VOO_LIBVOO
				VOO->(DbSkip())
				Loop
			EndIf
		endif
		
		If SF2->( DbSeek(xFilial("SF2") + VOO->VOO_NUMNFI + VOO->VOO_SERNFI ) )
		
			cString += "<Invoice>" +CHR(13)+CHR(10)
			cString += 		"<InvoiceDate>"
			cString += 				StrZero(Year(SF2->F2_EMISSAO),4) + "-" + StrZero(Month(SF2->F2_EMISSAO),2) + "-" + StrZero(Day(SF2->F2_EMISSAO),2) +;
			"T" + StrZero(Val(Left(Transform(SF2->F2_HORA,"@R 99:99"),2)),2)+":"+StrZero(Val(Substr(Transform(SF2->F2_HORA,"@R 99:99"),4,2)),2)+":00"
			cString += 		"</InvoiceDate>"+CHR(13)+CHR(10)
			cString += 		"<InvoiceNo>" + Alltrim(SF2->F2_DOC) + "_" + Alltrim( FGX_MILSNF("SF2", 2, "F2_SERIE") ) + "</InvoiceNo>"+CHR(13)+CHR(10)
			cString += 		"<IsCreditOrder>false</IsCreditOrder>"+CHR(13)+CHR(10)
			cString += "</Invoice>"+CHR(13)+CHR(10)
			
		Endif
				
		DbSelectArea("VOO")
		DbSkip()
		
	EndDo               
Endif
//cString += "</Invoices>"

Return cString

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    | FS_DDVEIC  | Autor |Carla Catiane F R      | Data | 25/04/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri็ใo | Levanta dados do veํculo da OS para cria็ใo do XML.          |##
##|          | Projeto WHI.                                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_DDVEIC()

Local cString  := ""
Local aTipVei  := {}
Local nTipVei  := 0
Local cTipVei  := ""
Local cMarca   := ""
Local aMarcas  := {}
Local nMarca   := 0

//Tabela 18.1
//aAdd( aMarcas, { "DAF", "DAF" } )
//aAdd( aMarcas, { "PAC", "Pacton" } )
//aAdd( aMarcas, { "SCH", "Schmitz" } )
//aAdd( aMarcas, { "Van Hool", "Van Hool" } )
//aAdd( aMarcas, { "Burg", "Burg" } )
//aAdd( aMarcas, { "Groenewegen", "Groenewegen" } )
//aAdd( aMarcas, { "Floor", "Floor" } )
//aAdd( aMarcas, { "LAG", "LAG" } )
//aAdd( aMarcas, { "Krone", "Krone" } )
//aAdd( aMarcas, { "Renders", "Renders" } )
//aAdd( aMarcas, { "GS", "GS" } )
//aAdd( aMarcas, { "Chereau", "Chereau" } )
//aAdd( aMarcas, { "Nooteboom", "Nooteboom" } )
//aAdd( aMarcas, { "Opel", "Opel" } )
aAdd( aMarcas, { "SCA", "Scania" } )
aAdd( aMarcas, { "MB ", "Mercedes Benz" } )
aAdd( aMarcas, { "MAN", "MAN" } )
aAdd( aMarcas, { "IVE", "Iveco" } )
aAdd( aMarcas, { "REN", "Renault" } )
aAdd( aMarcas, { "CIT", "Citroen" } )
aAdd( aMarcas, { "FOR", "Ford" } )
aAdd( aMarcas, { "MIT", "Mitsubishi" } )
aAdd( aMarcas, { "PEU", "Peugeot" } )

//Tabela 18.2 - C๓digo de Tipos de Produtos
aAdd( aTipVei, {"01","Truck"} )   //Caminhใo
aAdd( aTipVei, {"02","Bus"} )     //Onibus
aAdd( aTipVei, {"03","Engine"} )  //Motor
aAdd( aTipVei, {"04","Trailer"} ) //Reboque
aAdd( aTipVei, {"05","Follower"} )//Implemento
aAdd( aTipVei, {"06","Car"} )     //Carro
aAdd( aTipVei, {"07","Other"} )   //Outros

/////////////////////////////////////////////
//PE para manipula็ใo dos tipos de veํculos//
/////////////////////////////////////////////
If ExistBlock("PEOFTPVE")
	aTipVei := ExecBlock("PEOFTPVE",.f.,.f.)
Endif

DbSelectArea("VV1")
DbSetOrder(1)
DbSeek( xFilial("VV1") + VO1->VO1_CHAINT )

DbSelectArea("VE1")
DbSetOrder(1)
DbSeek( xFilial("VE1") + VV1->VV1_CODMAR )

nMarca := aScan( aMarcas,{ |x| x[1] == VE1->VE1_MARFAB })
If nMarca > 0
	cMarca := aMarcas[ nMarca, 2 ]
Else
	cMarca := VV1->VV1_CODMAR
Endif

DbSelectArea("VV2")
DbSetOrder(1)
DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )

nTipVei := aScan( aTipVei,{ |x| x[1] == VV2->VV2_TIPVEI })
If nTipVei > 0
	cTipVei  := aTipvei[ nTipVei, 2 ]
Endif

cString += "<ItemMaster>"         +CHR(13)+CHR(10)
cString += 	  "<ItemMasterHeader>"+CHR(13)+CHR(10)

If !Empty( VO1->VO1_DATENT ) .and. !Empty( VO1->VO1_HORENT )
	cString +=       "<DeliveryDate>"
	cString += 		StrZero(Year(VO1->VO1_DATENT),4) + "-" + StrZero(Month(VO1->VO1_DATENT),2) + "-" + StrZero(Day(VO1->VO1_DATENT),2)
	cString += 		"T" + StrZero(Val(Left(Transform(VO1->VO1_HORENT,"@R 99:99"),2)),2)+":"+StrZero(Val(Substr(Transform(VO1->VO1_HORENT,"@R 99:99"),4,2)),2)+":00"
	cString += 		"</DeliveryDate>"+CHR(13)+CHR(10)
EndIf

If Alltrim( VV1->VV1_CHASSI ) == Alltrim( VV1->VV1_CHARED )//Motores.
	cString +=       "<EngineNo>"     + Alltrim( VV1->VV1_CHARED ) + "</EngineNo>"    +CHR(13)+CHR(10)
EndIf
cString +=       "<GovernmentalRegistration>"+CHR(13)+CHR(10)
cString += 		     "<LicenceNo>"           +Alltrim( VV1->VV1_PLAVEI ) + "</LicenceNo>"+CHR(13)+CHR(10)

cString +=       "</GovernmentalRegistration>"+CHR(13)+CHR(10)

cString +=       "<ManufacturerItemID>" + Alltrim( VV1->VV1_CHARED ) + "</ManufacturerItemID>"+CHR(13)+CHR(10)
cString +=       "<ModelSpecification>" + CHR(13)+CHR(10)
cString +=           "<ChassisModel>"   + Alltrim( VV1->VV1_MODVEI ) + "</ChassisModel>"  +CHR(13)+CHR(10)
cString +=           "<Make>"           + Alltrim( cMarca ) 		   + "</Make>"          +CHR(13)+CHR(10)
cString +=           "<ProductType>"    + Alltrim( cTipVei         ) + "</ProductType>"   +CHR(13)+CHR(10)
cString +=       "</ModelSpecification>"+ CHR(13)+CHR(10)
cString +=       "<SupplierItemID>" 	+ Alltrim( VV1->VV1_CHARED )  + "</SupplierItemID>"+CHR(13)+CHR(10)

cString +=       "<TechnicalSpecification>"+CHR(13)+CHR(10)
cString +=           "<EngineType>"	+ Alltrim( VV1->VV1_MODVEI ) + "</EngineType>"+CHR(13)+CHR(10)
cString +=       "</TechnicalSpecification>"+CHR(13)+CHR(10)

cString +=       "<VINNo>" + Alltrim( VV1->VV1_CHASSI ) + "</VINNo>"+CHR(13)+CHR(10)

cString +=    "</ItemMasterHeader>"+CHR(13)+CHR(10)
cString += "</ItemMaster>"+CHR(13)+CHR(10)


Return cString

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    | FS_DDCLI   | Autor |Carla Catiane F R      | Data | 25/04/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri็ใo | Levanta dados do cliente para gera็ใo do XML.                |##
##|          | Projeto WHI.                                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_DDCLI()

Local cString := ""

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + VO1->VO1_PROVEI + VO1->VO1_LOJPRO )

cString += "<PartyMaster>"+CHR(13)+CHR(10)

cString +=    "<Location>" 		+CHR(13)+CHR(10)
cString += 	    "<Address>"     + Alltrim( (SA1->A1_END) ) + "</Address>"     +CHR(13)+CHR(10)
cString +=  	"<CityName>"    + Alltrim( (SA1->A1_MUN) ) + "</CityName>"    +CHR(13)+CHR(10)
cString += 	    "<CountryCode>"	+ "BR" 			   	     + "</CountryCode>" +CHR(13)+CHR(10)
cString += 		"<PostalCode>" 	+ Alltrim( SA1->A1_CEP ) + "</PostalCode>"     +CHR(13)+CHR(10)
cString +=    "</Location>" 	+CHR(13)+CHR(10)

cString +=    "<Name>"    + Alltrim( (SA1->A1_NOME) ) + "</Name>" +CHR(13)+CHR(10)
cString += 	  "<PartyID>" + CHR(13)+CHR(10)
cString += 		"<ID>"    + Alltrim( SA1->A1_CGC  ) + "</ID>"+CHR(13)+CHR(10)
cString += 	  "</PartyID>"+ CHR(13)+CHR(10)
cString += 	  "<PartyMasterType>" + "0" + "</PartyMasterType>"+CHR(13)+CHR(10)

cString += "</PartyMaster>"+CHR(13)+CHR(10)

Return cString

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    | FS_DDGAR   | Autor |Carla Catiane F R      | Data | 25/04/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri็ใo | Levanta dados da garantia para gera็ใo do XML.               |##
##|          | Projeto WHI.                                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_DDGAR(cTipTem)

Local cString := ""
Local cQuery  := ""
Local cMarca  := FMX_RETMAR("SCA")
Local cQryVG8 := "SQLVG8"

DbSelectArea("VE4")
DbSetOrder(1)
DbSeek(xFilial("VE4") + cMarca )

DbSelectArea("SA1")
DbSetOrder(3)
DbSeek( xFilial("SA1") + VE4->VE4_CGCFAB )

If Select(cQryVG8) > 0
	(cQryVG8)->(DbCloseArea())
EndIf


cQuery := " SELECT DISTINCT VG8_NFALHA, VG8_LOCFAL, VG8_GRUSER, VG8_METREP, VG8_FONTE, VG8_SINTOM, "
cQuery += " 	   VG8_ITECAU, VG8_RECONS, VG8_NUMRRC, VG8_ANORRC, VG8_SITRRC, VG8_RRCFAB,"
cQuery += "		   B1_DESC, BM_PROORI "
cQuery += " FROM " + RetSqlName("VG8") + " VG8, " + RetSqlName("VG6") + " VG6, "
cQuery += "		 " + RetSqlName("SB1") + " SB1, " + RetSqlName("SBM") + " SBM "

cQuery += " WHERE VG8_FILIAL = '" + xFilial("VG8") + "' AND VG6_FILIAL = '" + xFilial("VG6") + "' AND "
cQuery += "		   B1_FILIAL = '" + xFilial("SB1") + "' AND  BM_FILIAL = '" + xFilial("SBM") + "' AND "
cQuery += "		  VG8_NUMOSV = '" + VO1->VO1_NUMOSV + "' AND VG8_NUMRRC != '" + Space(07) + "' AND "
cQuery += "		  VG8_NUMOSV = VG6_NUMOSV AND VG8_NUMRRC = VG6_NUMRRC AND "
cQuery += "		  VG8_ANORRC = VG6_ANORRC AND VG6_TIPTEM = '" + cTipTem + "' AND "
cQuery += " 	  VG8_GRUITE = B1_GRUPO AND VG8_ITECAU = B1_CODITE AND "
cQuery += "		  BM_GRUPO = B1_GRUPO AND "
cQuery += "		  VG8.D_E_L_E_T_ = ' ' AND VG6.D_E_L_E_T_ = ' ' AND "
cQuery += "		  SB1.D_E_L_E_T_ = ' ' AND SBM.D_E_L_E_T_ = ' ' "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryVG8, .F., .T. )

(cQryVG8)->( DBGoTop() )

If (cQryVG8)->( Eof() )
	(cQryVG8)->( DbCloseArea() )
	DbSelectArea("VO1")
	Return cString
Endif

cString += "<FailureContainers>"+CHR(13)+CHR(10)

While !(cQryVG8)->( Eof() )
	
	cString += "<FailureContainer>"+CHR(13)+CHR(10)
	
	If !Empty((cQryVG8)->VG8_NFALHA ) .or. !Empty((cQryVG8)->VG8_LOCFAL ) .or. !Empty((cQryVG8)->VG8_GRUSER ) .or.;
		!Empty((cQryVG8)->VG8_METREP ) .or. !Empty((cQryVG8)->VG8_FONTE  ) .or. !Empty((cQryVG8)->VG8_SINTOM)
		
		cString += "<Failure>"+CHR(13)+CHR(10)

		Iif( !Empty((cQryVG8)->VG8_NFALHA ), cString += "<FailureCode>"  + Alltrim( (cQryVG8)->VG8_NFALHA ) + "</FailureCode>"  +CHR(13)+CHR(10), cString += "" )
		Iif( !Empty((cQryVG8)->VG8_LOCFAL ), cString += "<LocationCode>" + Alltrim( (cQryVG8)->VG8_LOCFAL ) + "</LocationCode>" +CHR(13)+CHR(10), cString += "" )
		Iif( !Empty((cQryVG8)->VG8_GRUSER ), cString += "<MaingroupBTI>" + Alltrim( (cQryVG8)->VG8_GRUSER ) + "</MaingroupBTI>" +CHR(13)+CHR(10), cString += "" )
		Iif( !Empty((cQryVG8)->VG8_METREP ), cString += "<RepairCode>"   + Alltrim( (cQryVG8)->VG8_METREP ) + "</RepairCode>"   +CHR(13)+CHR(10), cString += "" )
		Iif( !Empty((cQryVG8)->VG8_FONTE  ), cString += "<Sourcecode>"   + Alltrim( (cQryVG8)->VG8_FONTE  ) + "</Sourcecode>"   +CHR(13)+CHR(10), cString += "" )
		Iif( !Empty((cQryVG8)->VG8_SINTOM ), cString += "<SymptomCode>"  + Alltrim( (cQryVG8)->VG8_SINTOM ) + "</SymptomCode>"  +CHR(13)+CHR(10), cString += "" )
	
		cString += "</Failure>"
	EndIf
	
	cString += "<FaultCausingPart>" +CHR(13)+CHR(10)
	
	cString += 	  "<FaultCausingPartDescription>"	+ Alltrim( ((cQryVG8)->B1_DESC)    ) + "</FaultCausingPartDescription>"  +CHR(13)+CHR(10)
	cString += 	  "<FaultCausingPartNo>"				+ Alltrim( (cQryVG8)->VG8_ITECAU ) + "</FaultCausingPartNo>"           +CHR(13)+CHR(10)
	
	cString += 	  "<FaultCausingPartSupplierID>"		+ Alltrim( VE4->VE4_CGCFAB )  + "</FaultCausingPartSupplierID>"   +CHR(13)+CHR(10)
	cString += 	  "<FaultCausingPartSupplierName>" 	+ Alltrim((SA1->A1_NOME)) 		+ "</FaultCausingPartSupplierName>" +CHR(13)+CHR(10)
	cString +=    "<FaultCausingPartType>"+Iif( (cQryVG8)->BM_PROORI == "1", "SC", "LC" ) + "</FaultCausingPartType>" +CHR(13)+CHR(10)
	
	cString += "</FaultCausingPart>" +CHR(13)+CHR(10)

	If !Empty( (cQryVG8)->VG8_RRCFAB ) 
		cString += "<WarrantyInfo>" +CHR(13)+CHR(10)
		cString += "<ClaimFactoryNumber>" + Alltrim( (cQryVG8)->VG8_RRCFAB ) + "</ClaimFactoryNumber>"+CHR(13)+CHR(10)
		If (cQryVG8)->VG8_RECONS == "1"
			cString += "<ClaimFactoryReconsiderationNumber>" + LEFT((cQryVG8)->VG8_NUMRRC,2) + "</ClaimFactoryReconsiderationNumber>"+CHR(13)+CHR(10)
		Endif
	
		If (cQryVG8)->VG8_SITRRC $ "03.04.05.61.62."
			cString += "<WarrantyIsApproved>"+Iif( (cQryVG8)->VG8_SITRRC $ "03.61.62","true","false")+"</WarrantyIsApproved>"+CHR(13)+CHR(10)
		EndIf
		cString += "</WarrantyInfo>"+CHR(13)+CHR(10)
	EndIf
	
	cString += "</FailureContainer>"+CHR(13)+CHR(10)
	
	(cQryVG8)->( DbSkip() )
	
EndDo
cString += "</FailureContainers>"+CHR(13)+CHR(10)

(cQryVG8)->( DbCloseArea() )
DbSelectArea("VO1")

Return cString

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    | FS_DDITEM  | Autor |Carla Catiane F R      | Data | 25/04/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri็ใo | Levanta dados dos itens/servicos requisitados e apontados na |##
##|          | OS, para gera็ใo do XML.                                     |##
##|          | Projeto WHI.                                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_DDITEM(cPecSer,nContador,cTT)

Local i       := nContador
Local nCont   := 0
Local cString := ""
Local cMarca  := FMX_RETMAR("SCA")
Local cPeca   := ""
Local nQtdReq := 0
Local cDesSer := ""
Local cTXTAux := ""

DbSelectArea("SB1")
DbSetOrder(7)

DbSelectArea("SBM")
DbSetOrder(1)

DbSelectArea("VOO")
DbSetOrder(1)

DbSelectArea("VOK")
DbSetOrder(1)

DbSelectArea("SA2")
DbSetOrder(1)

DbSelectArea("VO4")
DbSetOrder(10)

DbSelectArea("VE4")
DbSetOrder(1)
DbSeek(xFilial("VE4") + cMarca )

DbSelectArea("SA1")
DbSetOrder(3)
DbSeek( xFilial("SA1") + VE4->VE4_CGCFAB )

cString := "<MaintenanceOrderLines>"+CHR(13)+CHR(10)

If cPecSer == "P"
	//Pecas
	If Len( aPec ) > 0
		For i := 1 to Len( aPec )
			If aPec[i,PECA_TIPTEM] <> cTT
				Loop
			Endif
			nCont++
			SB1->(DbSeek( xFilial("SB1") + aPec[i,PECA_GRUITE] + aPec[i,PECA_CODITE] ) )
			SBM->(DbSeek( xFilial("SBM") + aPec[i,PECA_GRUITE] ) )
			
			cString += "<MaintenanceOrderLine>"+CHR(13)+CHR(10)
			cString += "<ActualRecources>"+CHR(13)+CHR(10)
			cString += "<InventoryActual>"+CHR(13)+CHR(10)
			cString +=    "<Description>" + Alltrim( (SB1->B1_DESC) ) + "</Description>"+CHR(13)+CHR(10)
			cString +=    "<ID>"			+ Alltrim(aPec[i,PECA_CODITE])     + "</ID>"+CHR(13)+CHR(10)
			cString +=    "<IsUsedPart>"+Iif( SBM->BM_STATUS == "1","false","true") + "</IsUsedPart>"+CHR(13)+CHR(10)
			cString +=    "<PartType>"+Iif(SBM->BM_PROORI == "1","SC","LC")+"</PartType>"+CHR(13)+CHR(10)
			
			cPeca   := aPec[i,PECA_GRUITE] + aPec[i,PECA_CODITE]
			nQtdReq := 0
			
			While aPec[i,PECA_GRUITE] + aPec[i,PECA_CODITE] == cPeca .and. i <= len(aPec)
				nQtdReq += aPec[i,PECA_QTDREQ]
				If i == len(aPec) .or. aPec[i+1,PECA_GRUITE] + aPec[i+1,PECA_CODITE] != cPeca
					Exit
				Else
					i++
				EndIf
			EndDo
			
			cTXTAux := Alltrim(Transform(nQtdReq,"@E 9999999999.99"))
			cString +=    "<Quantity>"     + STUFF( cTXTAux , AT(",",cTXTAux) , 1 , "." ) + "</Quantity>" +CHR(13)+CHR(10)
			cString +=    "<Role>"         + "0" 		       		 + "</Role>"+CHR(13)+CHR(10)
			cString +=    "<SupplierID>"   + Alltrim( VE4->VE4_CGCFAB ) + "</SupplierID>"+CHR(13)+CHR(10)
			cString +=    "<SupplierName>" + Alltrim((SA1->A1_NOME))	  + "</SupplierName>"+CHR(13)+CHR(10)
			cString += "</InventoryActual>"+ CHR(13)+CHR(10)
			cString += "</ActualRecources>"+ CHR(13)+CHR(10)
			If VOO->(DbSeek( xFilial("VOO") + aPec[i,PECA_NUMOSV] + aPec[i,PECA_TIPTEM] + aPec[i,PECA_LIBVOO] )) .and. !Empty(VOO->VOO_NUMNFI)
				cString += "<InvoiceReferences>"+CHR(13)+CHR(10)
				cString += 	"<InvoiceSplitter>"+CHR(13)+CHR(10)
				cString += 	"<InvoiceNo>" + VOO->VOO_NUMNFI + "_" + Alltrim( FGX_MILSNF("VOO", 2, "VOO_SERNFI") ) + "</InvoiceNo>"+CHR(13)+CHR(10)
				cString += 	"<InvoiceSplitPercentage>" + "100" + "</InvoiceSplitPercentage>"+CHR(13)+CHR(10)
				cString += 	"</InvoiceSplitter>"+CHR(13)+CHR(10)
				cString += "</InvoiceReferences>"+CHR(13)+CHR(10)
			EndIf                                                
			cString += "<IsWarranty>"+IIf ( VOI->VOI_SITTPO == "2","true","false" )+"</IsWarranty>"+CHR(13)+CHR(10)
			cString += "<LineNo>" + Alltrim( Transform(nCont,"9999")) + "</LineNo>"+CHR(13)+CHR(10)

			cString += "</MaintenanceOrderLine>"+CHR(13)+CHR(10)
		Next
	EndIf
	
Else	

	//Servi็os
	If Len( aSer ) > 0
		For i := 1 to Len( aSer )
			If aSer[i,SRVC_TIPTEM] <> cTT
				Loop
			Endif
			nCont++
			cString += "<MaintenanceOrderLine>"+CHR(13)+CHR(10)
			cString += "<ActualRecources>"+CHR(13)+CHR(10)
			
			cString += 	"<LabourActual>"+CHR(13)+CHR(10)
			//	  cString += 		"<FreeTextDescription>" +"x"+ "</FreeTextDescription>"+CHR(13)+CHR(10)
			cString += 		"<ID>" + Alltrim( aSer[i,SRVC_CODSER] ) + "</ID>"+CHR(13)+CHR(10)
	       cDesSer := Alltrim( (aSer[i,SRVC_DESCRICAO]) )
			cDesSer := strtran (cDesSer, "<", " ")
			cDesSer := strtran (cDesSer, ">", " ")
			cString += 		"<IDDescription>" + cDesSer + "</IDDescription>"+CHR(13)+CHR(10)
			cString += 		"<LabourType>"+Iif( SUBS(aSer[i,SRVC_CODSER],3,1) == " ","LOCAL", "MULTI")+ "</LabourType>" +CHR(13)+CHR(10)
			cString += 		"<QuantityActual>"	 + Alltrim(Transform( aSer[i,SRVC_TEMTRA]/100, "@R 999.99" )) + "</QuantityActual>"+CHR(13)+CHR(10)
			cString += 		"<QuantityInvoiced>" + Alltrim(Transform( aSer[i,SRVC_TEMCOB]/100, "@R 999.99" )) + "</QuantityInvoiced>"+CHR(13)+CHR(10)
			cString += 		"<QuantityStandard>" + Alltrim(Transform( aSer[i,SRVC_TEMPAD]/100, "@R 999.99" )) + "</QuantityStandard>"+CHR(13)+CHR(10)
			cString += 		"<QuantityUnit>"     + "Hours" + "</QuantityUnit>"+CHR(13)+CHR(10)
			cString += 	"</LabourActual>"	  +CHR(13)+CHR(10)
			cString += "</ActualRecources>"+CHR(13)+CHR(10)
	
			If !Empty( aSer[i,SRVC_DATLIB] )
				cString += "<CompletionDateTime>"
				VO4->(DbSeek( xFilial("VO4") + aSer[i, SRVC_NUMOSV] + aSer[i, SRVC_TIPTEM] + aSer[i, SRVC_APONT,1,SRVC_APONT_NOSNUM]) )
				cString += StrZero(Year( aSer[i,SRVC_DATLIB]),4) + "-" + StrZero(Month( aSer[i,SRVC_DATLIB]),2) + "-" + StrZero(Day( aSer[i,SRVC_DATLIB]),2) +;
				"T" + StrZero(Val(Left(Transform(VO4->VO4_HORDIS,"@R 99:99"),2)),2)+":"+StrZero(Val(Substr(Transform(VO4->VO4_HORDIS,"@R 99:99"),4,2)),2)+":00"
				cString += "</CompletionDateTime>"+CHR(13)+CHR(10)
			EndIf
			If VOO->(DbSeek( xFilial("VOO") + aSer[i,SRVC_NUMOSV] + aSer[i,SRVC_TIPTEM] + aSer[i,SRVC_LIBVOO] )) .and. !Empty(VOO->VOO_NUMNFI)
				cString += "<InvoiceReferences>"+CHR(13)+CHR(10)
				cString += 	"<InvoiceSplitter>"+CHR(13)+CHR(10)
				cString += 	"<InvoiceNo>" + VOO->VOO_NUMNFI + "_" + Alltrim( FGX_MILSNF("VOO", 2, "VOO_SERNFI") ) + "</InvoiceNo>"+CHR(13)+CHR(10)
				cString += 	"<InvoiceSplitPercentage>" + "100" + "</InvoiceSplitPercentage>"+CHR(13)+CHR(10)
				cString += 	"</InvoiceSplitter>"+CHR(13)+CHR(10)
				cString += "</InvoiceReferences>"+CHR(13)+CHR(10)
			EndIf
			cString += "<IsWarranty>"+IIf ( VOI->VOI_SITTPO == "2","true","false" )+"</IsWarranty>"+CHR(13)+CHR(10)
			cString += "<LineNo>" + Alltrim(Transform(nCont,"9999")) + "</LineNo>"+CHR(13)+CHR(10)
			
			cString += "</MaintenanceOrderLine>" +CHR(13)+CHR(10)
		
			VOK->(DbSeek( xFilial("VOK") + aSer[i,SRVC_TIPSER] ))
			If VOK->VOK_INCMOB == "2"  //Servi็os de terceiro.
				nCont++
				cString += "<MaintenanceOrderLine>" +CHR(13)+CHR(10)
				cString += "<ActualRecources>"	+CHR(13)+CHR(10)
				cString += 	"<SubcontractingActual>"	+CHR(13)+CHR(10)
				cString += 		"<Description1>"	+ Alltrim( aSer[i, SRVC_CODSER] ) + Alltrim( aSer[i, SRVC_DESCRICAO] ) + "</Description1>"+CHR(13)+CHR(10)
				cString += 		"<Quantity>" 	 	+ "1.00" + "</Quantity>"+CHR(13)+CHR(10)
				cString += 		"<Supplier>" 	 	+ aSer[i,SRVC_CODFOR] + aSer[i, SRVC_FOLOJA] + "</Supplier>"+CHR(13)+CHR(10)
				
				SA2->( DbSeek( xFilial("SA2")   + aSer[i,SRVC_CODFOR] + aSer[i, SRVC_FOLOJA] ) )
				cString += 		"<SupplierName>" + Alltrim( SA2->A2_NOME ) + "</SupplierName>"+CHR(13)+CHR(10)
				cString += 	"</SubcontractingActual>" +CHR(13)+CHR(10) 
				cString += "</ActualRecources>" +CHR(13)+CHR(10)
	
				If !Empty( aSer[i,SRVC_DATLIB] )
					cString += "<CompletionDateTime>"
					VO4->(DbSeek( xFilial("VO4") + aSer[i, SRVC_NUMOSV] + aSer[i, SRVC_TIPTEM] + aSer[i, SRVC_APONT,1,SRVC_APONT_NOSNUM]) )
					cString += StrZero(Year( aSer[i,SRVC_DATLIB]),4) + "-" + StrZero(Month( aSer[i,SRVC_DATLIB]),2) + "-" + StrZero(Day( aSer[i,SRVC_DATLIB]),2) +;
					"T" + StrZero(Val(Left(Transform(VO4->VO4_HORDIS,"@R 99:99"),2)),2)+":"+StrZero(Val(Substr(Transform(VO4->VO4_HORDIS,"@R 99:99"),4,2)),2)+":00"
					cString += "</CompletionDateTime>"+CHR(13)+CHR(10)
				EndIf
	
				// VERIFICAR
				// TIRAR MESMO
				/*If VOO->(DbSeek( xFilial("VOO") + (cQryVDW)->VDW_NUMOSV + (cQryVDW)->VDW_TIPTEM + (cQryVDW)->VDW_LIBVOO )) .and. !Empty(VOO->VOO_NUMNFI)
					cString += "<InvoiceReferences>"+CHR(13)+CHR(10)
					cString += 	"<InvoiceSplitter>"+CHR(13)+CHR(10)
					cString += 	"<InvoiceNo>" + VOO->VOO_NUMNFI + "_" + Alltrim( VOO->VOO_SERNFI ) + "</InvoiceNo>"+CHR(13)+CHR(10)
					cString += 	"<InvoiceSplitPercentage>" + "100" + "</InvoiceSplitPercentage>"+CHR(13)+CHR(10)
					cString += 	"</InvoiceSplitter>"+CHR(13)+CHR(10)
					cString += "</InvoiceReferences>"+CHR(13)+CHR(10)
				EndIf
				*/
				cString += "<IsWarranty>"+IIf ( VOI->VOI_SITTPO == "2","true","false" )+"</IsWarranty>"+CHR(13)+CHR(10)
				cString += "<LineNo>" + Alltrim( Transform(nCont,"9999")) + "</LineNo>"+CHR(13)+CHR(10)
				cString += "</MaintenanceOrderLine>" +CHR(13)+CHR(10)
	
			EndIf
		
		Next
	EndIf
EndIf
	
cString += "</MaintenanceOrderLines>"+CHR(13)+CHR(10)

Return cString


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    | CriaSX1    | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ aAdd a Pergunta                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aAdd(aSX1,{cPerg,"01",STR0006,"","","mv_ch1","D", 08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""}) //"Data Inicial      ?"
aAdd(aSX1,{cPerg,"02",STR0007,"","","mv_ch2","D", 08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""}) //"Data Final        ?"

ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			lSX1 := .T.
			RecLock("SX1",.T.)
			
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			
			dbCommit()
			MsUnLock()
		EndIf
	EndIf
Next i

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    | FS_GRVLIN  | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function FS_GRVLIN(cString)
Local nPos 		:= 1
Local cRetString:= ""

While nPos > 0
	nPos := at("&",cString) 
	If nPos > 0
		cString     := stuff(cString,nPos,1,"&amp;")
		cRetString  += Subs(cString,1,nPos+4)
		cString     := Subs(cString,nPos+5)
	Else
		cRetString  += cString
	Endif
Enddo
fwrite(nHnd,FwNoAccent(cRetString))

return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_OPENARQบAutor  ณFabio               บ Data ณ  02/15/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAbre arquivos do parametro                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_OPENARQ()

Local cOpenArq:= "'VH0'," , nOpem:=0
Local cStr:=""

DbCloseAll()
Prepare Environment Empresa cEmpr Filial cFil Tables 'VH0' Modulo "OFI"

if (nHandle:= FT_FUse( "SIGAOFI.MNU" )) == -1
	Return
endif

FT_FGotop()
While ! FT_FEof()
	
	cStr := FT_FReadLN()
	
	If Substr(cStr,31,1) == "T"
		For nOpem := 32 to 90 step 3
			If !Empty(Substr(cStr,nOpem,3)) .And. !( "." $ Substr(cStr,nOpem,3) );
				.And. At(Substr(cStr,nOpem,3),cOpenArq)==0 .And. At(Substr(cStr,nOpem,3),cFOPENed)==0;
				.And. SX2->(DbSeek(Substr(cStr,nOpem,3)))
				
				cOpenArq += "'"+Substr(cStr,nOpem,3)+"',"
				DbSelectArea(Substr(cStr,nOpem,3))
				
			EndIf
		Next
	EndIf
	
	FT_FSkip()
End
FT_FUse()

Return
