#include "protheus.ch"
#include "JURA201H.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201HPreF
Rotina para totalizar o valor da Pré-Fatura

@author Daniel Magalhaes
@since 28/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201HPreF(oParams, cCodPre, cCMOEDFT, cNVVCOD, cNW2COD, cNT0COD, cCRELAT, cCodFilaImp)
	Local aRet          := {.F., "JA201HPreF"}
	Local aArea         := GetArea()
	Local cQuery        := ""
	Local cQueryRes     := GetNextAlias() 
	
	Local nVHON         := ""
	Local nVDESP        := 0
	Local nVLDESC       := 0
	Local nVDESCO       := 0
	Local cSITUAC       := ""
	Local cCESCRIT      := ""
	Local cCPART        := ""
	Local cTEMTS        := ""
	Local cTEMDP        := ""
	Local cTEMLT        := ""
	Local cTEMFX        := ""
	Local cTEMFA        := ""
	Local cCGRPVEN      := ""
	Local cCCLIENTE     := ""
	Local cCLOJA        := ""
	Local cCFTADC       := ""
	Local nVTS          := 0
	Local dDIAEMI       := ""
	Local cIDIOMA       := ""
	Local cPoNumber     := ""
	Local cServicos     := ""
	Local cServReinf    := ""
	
	Local dDINITS       :=  stod("  /  /    ")
	Local dDFIMTS       :=  stod("  /  /    ")
	Local dDINIDP       :=  stod("  /  /    ")
	Local dDFIMDP       :=  stod("  /  /    ")
	Local dDINITB       :=  stod("  /  /    ")
	Local dDFIMTB       :=  stod("  /  /    ")

	Local cREVIS        :=  "2"
	Local dDTINC        :=  oParams:GetDEmi()

	Local nDESCH        := 0
	Local nPDESCH       := 0
	Local nACRESH       := 0
	Local nPACREH       := 0

	Local cFATOLD       := " "
	Local cESCOLD       := " "
	Local cAltper       := ""
	Local cTpDesc       := ""
	Local cTpAcre       := ""
	Local vVlTab        := 0 
	Local nVlTabLim     := 0 
	Local nVlFixo       := 0 
	Local lPoNumber     := .F. 
	Local lServicos     := (NX0->( FieldPos( "NX0_SERVIC" )) > 0 )
	Local lServReinf    := (NX0->( FieldPos( "NX0_TPSERV" )) > 0 )
	Local cJurUser      := JurUsuario(oParams:GetCodUser())
	Local lDespTrib     := NX0->(ColumnPos('NX0_VLREMB')) > 0
	Local nVlDpTrib     := 0
	Local nVlDpReemb    := 0
	Local lIntegracao   := (SuperGetMV("MV_JFSINC", .F., '2') == '1')
	Local lTipoFech     := NX0->(ColumnPos("NX0_TPFECH")) > 0
	Local cTipoFech     := ""
	Local lCpoFxNc      := NX0->(ColumnPos("NX0_FXNC")) > 0 // Proteção de TSs de Contratos Fixos ou Não Cobráveis
	Local cTipoRel      := ""

	/*
	oParams:GetSituac()  (situação que será emitida a pré-fatura
	1 - Confer?ia
	2 - Pr?atura
	3 - Emitir Fatura
	4 - Emitir Minuta
	5 - Minuta Sócio
	*/
	Do Case
 		Case oParams:GetSituac() == "1"
			cSITUAC := "1" // Conferência
		Case oParams:GetSituac() == "3"
			cSITUAC := "4" // Emitir Fatura
		Case oParams:GetSituac() == "4"
			cSITUAC := "5"  // minuta
		Case oParams:GetSituac() == "5"
			cSITUAC := "9"  // minuta sócio
		Case oParams:GetSituac() == "6"
			cSITUAC := "C"  // Em Revisão
		OtherWise
			cSITUAC := "2" //Análise
	EndCase

	If oParams:GetTpExec() $ "2|6"    // Refazer
		DbSelectArea("NX0")
		NX0->(dbSetOrder(1))  //NX0_FILIAL+NX0_COD
		If NX0->(DbSeek( xFilial("NX0") + cCodPre ) )
			//Salvar os dados que deverão continuar na
			cCPART      := NX0->NX0_CPART
			dDINITS     := NX0->NX0_DINITS
			dDFIMTS     := NX0->NX0_DFIMTS
			dDINIDP     := NX0->NX0_DINIDP
			dDFIMDP     := NX0->NX0_DFIMDP
			dDINITB     := NX0->NX0_DINITB
			dDFIMTB     := NX0->NX0_DFIMTB
			cREVIS      := NX0->NX0_REVIS

			If oParams:GetTpExec() $ "2|6" 
				nDESCH      := NX0->NX0_DESCH  
				nPDESCH     := NX0->NX0_PDESCH
				nACRESH     := NX0->NX0_ACRESH
				nPACREH     := NX0->NX0_PACREH
			Else
				nDESCH      := 0
				nPDESCH     := 0
				nACRESH     := 0
				nPACREH     := 0
			EndIf
			
			nVLDESC     := NX0->NX0_DESCH

			cAltper     := NX0->NX0_ALTPER
			cTpDesc     := NX0->NX0_TPDESC
			cTpAcre     := NX0->NX0_TPACRE
			
		EndIf
	Else
		dDINITS := oParams:GetDIniH()
		dDFIMTS := oParams:GetDFinH()
		dDINIDP := oParams:GetDIniD()
		dDFIMDP := oParams:GetDFinD()
		dDINITB := oParams:GetDIniT()
		dDFIMTB := oParams:GetDFinT()
	EndIf

	//Obtém os dados da Fatura Adicional
	If !Empty(cNVVCOD)
		cCCLIENTE := JurGetDados("NVV", 1, xFilial("NVV") + cNVVCOD, "NVV_CCLIEN")
		cCLOJA    := JurGetDados("NVV", 1, xFilial("NVV") + cNVVCOD, "NVV_CLOJA")

		cCGRPVEN  := JurGetDados("NVV", 1, xFilial("NVV") + cNVVCOD, "NVV_CGRUPO")
		cCESCRIT := JurGetDados("NVV", 1, xFilial("NVV") + cNVVCOD, "NVV_CESCR")
		cIDIOMA  := JurGetDados("NVV", 1, xFilial("NVV") + cNVVCOD, "NVV_CIDIO1")
		If Empty(cCPART)
			cCPART := JurGetDados("NVV", 1, xFilial("NVV") + cNVVCOD, "NVV_CPART1")
		EndIf
	Else
		
		//Obtém os dados do Contrato/Junção de Contratos
		If !Empty(cNW2COD)
			cCESCRIT   := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, "NW2_CESCR")
			cIDIOMA    := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, "NW2_CIDIO")

			cCGRPVEN   := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, "NW2_CGRUPO")
			cCCLIENTE  := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, "NW2_CCLIEN")
			cCLOJA     := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, "NW2_CLOJA")
			If Empty(cCPART)
				cCPART := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, "NW2_CPART")
			EndIf
			If lPoNumber := (NW2->( FieldPos( "NW2_PONUMB" )) > 0 )
				cPoNumber := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, "NW2_PONUMB")
			EndIf
			If lServicos
				cServicos := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, "NW2_SERVIC")
			EndIf
			If lServReinf
				cServReinf := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, "NW2_TPSERV")
			EndIf
			If lTipoFech
				cTipoFech := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, "NW2_TPFECH")
			EndIf

			cTipoRel := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, "NW2_RELPRE")
		ElseIf !Empty(cNT0COD)
			cCESCRIT    := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_CESCR")
			cIDIOMA     := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_CIDIO")

			cCGRPVEN    := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_CGRPCL")
			cCCLIENTE   := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_CCLIEN")
			cCLOJA      := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_CLOJA")
			If Empty(cCPART)
				cCPART  := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_CPART1")
			EndIf
			If lPoNumber := (NT0->( FieldPos( "NT0_PONUMB" )) > 0 )
				cPoNumber := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_PONUMB")
			EndIf
			If lServicos
				cServicos := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_SERVIC")
			EndIf
			If lServReinf
				cServReinf := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_TPSERV")
			EndIf
			If lTipoFech
				cTipoFech := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_TPFECH")
			EndIf

			cTipoRel := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_RELPRE")
		EndIf

	EndIf

	dDIAEMI := JURA201I(cCodPre, cNW2COD, cNT0COD, cNVVCOD, oParams:GetDEmi())
	
	cQuery := " SELECT SUM(NX8.NX8_VHON) VHON, "
	cQuery +=        " SUM(NX8.NX8_VDESP) VDESP, "
	cQuery +=        " SUM(NX8.NX8_VLDESC) VLDESC, "
	cQuery +=        " SUM(NX8.NX8_VDESCO) VDESCO, "
	cQuery +=        " MIN(NX8.NX8_TS) TEMTS, "
	cQuery +=        " MIN(NX8.NX8_DESP) TEMDP, "
	cQuery +=        " MIN(NX8.NX8_LANTAB) TEMLT, "
	cQuery +=        " MIN(NX8.NX8_FIXO) TEMFX, "
	cQuery +=        " MIN(NX8.NX8_FATADC) TEMFA, "
	cQuery +=        " SUM(NX8.NX8_VTS) VTS, "
	If lDespTrib
		cQuery +=    " SUM(NX8.NX8_VLTRIB) VLDPTRIB, "
		cQuery +=    " SUM(NX8.NX8_VLREMB) VLDPREMB, "
	EndIf
	cQuery +=        " MAX(NX8.NX8_CFTADC) CFTADC, "
	cQuery +=        " SUM(NX8.NX8_VFIXO) VFIXO, "
	cQuery +=        " SUM(NX8.NX8_VTAB) VTAB, "
	cQuery +=        " SUM(NX8.NX8_VLLTLM) VLLTLM "
	cQuery +=   " FROM " + RetSqlName("NX8") + " NX8 "
	cQuery +=  " WHERE NX8.NX8_FILIAL = '" + xFilial("NX8") + "' "
	cQuery +=    " AND NX8.NX8_CPREFT = '" + cCodPre + "' "
	cQuery +=    " AND NX8.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
	DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)	
 	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQueryRes, .T., .F. )

 	If !(cQueryRes)->(EOF()) 
		nVHON       := (cQueryRes)->VHON
		nVDESP      := (cQueryRes)->VDESP
		nVLDESC     := (cQueryRes)->VLDESC
		nVDESCO     := (cQueryRes)->VDESCO
		nVTS        := (cQueryRes)->VTS
		cTEMTS      := Alltrim((cQueryRes)->TEMTS) //Tratamento para banco POSTGRES
		cTEMDP      := Alltrim((cQueryRes)->TEMDP)
		cTEMLT      := Alltrim((cQueryRes)->TEMLT)
		cTEMFX      := Alltrim((cQueryRes)->TEMFX)
		cTEMFA      := Alltrim((cQueryRes)->TEMFA)
		cCFTADC     := (cQueryRes)->CFTADC
		nVlFixo     := (cQueryRes)->VFIXO
		vVlTab      := (cQueryRes)->VTAB
		nVlTabLim   := (cQueryRes)->VLLTLM
		If lDespTrib
			nVlDpTrib  += (cQueryRes)->VLDPTRIB
			nVlDpReemb += (cQueryRes)->VLDPREMB
		EndIf
	EndIf

	(cQueryRes)->(DbCloseArea())

	If (nDESCH + nVDESCO) > (nVHON - nVlTabLim)

		nVLDESC := (nVHON - nVlTabLim) - nVDESCO
		nDESCH  := nVLDESC
	EndIf
	
	If ( oParams:GetTpExec() $ "1|2" .And. oParams:GetSituac() <> "1" )
		nDESCH := nVLDESC
		If cTpDesc == "1" // desconto por Valor (atualiza o percentual) 
			nPDESCH := nDESCH / (nVHON - vVlTab - nVDESCO) * 100
		Else // desconto por Percentual (atualiza o valor)
			nDESCH  := nPDESCH * (nVHON - vVlTab - nVDESCO) / 100
			nDESCH  := Round(nDESCH, TamSX3('NX0_DESCH')[2] ) 
		EndIf
		
		cTpAcre := Iif(nVDESP > 0 .And. nVHON == 0, "1", cTpAcre) //CH8047 Se não houver valor de Hon o tipo de acres deve ser por valor
		
		If cTpAcre == "1" // Acréscimo por Valor (atualiza o percentual) 
			nPACREH := nACRESH / (nVHON) * 100
		Else // Acréscimo por Percentual (atualiza o valor)
			nACRESH := nPACREH * (nVHON) / 100
		EndIf
	EndIf
	
	If (nVHON < 0 .Or. nVDESP < 0 )  // CH THTUVM Não permite que pré-faturas c/ valores negativos fiquem com status de gerar minutas ou faturas 
		IIf(cSITUAC != "1", cSITUAC := "2", )
	EndIf
	
	aRet := JA201HDesc(cCodPre, nDESCH)

	//Se tiver valor, Soma os Valores da NX8 e grava na NX0
	If nVHON > 0 .Or. nVDESP > 0 .Or. nDESCH > 0 .Or. cTEMTS == "1" .Or. cTEMDP == "1" .Or. cTEMLT == "1" .Or. cTEMFX == "1"
		NX0->(dbSetOrder(1))  //NX0_FILIAL+NX0_COD
		If !(NX0->(DbSeek( xFilial("NX0") + cCodPre ) ))
			RecLock("NX0", .T.)
			NX0->NX0_FILIAL := xFilial("NX0")
			NX0->NX0_COD    := cCodPre
			NX0->NX0_DTEMI  := oParams:GetDEmi()
			NX0->NX0_CMOEDA := cCMOEDFT
			NX0->NX0_VLFATD := nVDESP
			NX0->NX0_VLFATH := nVHON
			NX0->NX0_DESCON := nVDESCO
			NX0->NX0_SITUAC := cSITUAC
			NX0->NX0_CESCR  := cCESCRIT
			NX0->NX0_CCONTR := Iif(Empty(cNW2COD), cNT0COD, "")
			NX0->NX0_CJCONT := cNW2COD
			NX0->NX0_CPART  := cCPART
			NX0->NX0_DINITS := Iif(oParams:GetFltrHH() .Or. cTEMFA == "1", dDINITS, ctod("  /  /    "))
			NX0->NX0_DFIMTS := Iif(oParams:GetFltrHH() .Or. cTEMFA == "1", dDFIMTS, ctod("  /  /    "))
			NX0->NX0_DINIDP := dDINIDP
			NX0->NX0_DFIMDP := dDFIMDP
			NX0->NX0_DINITB := dDINITB
			NX0->NX0_DFIMTB := dDFIMTB
			NX0->NX0_DINIFX := Iif(cTEMFX == "1", dDINITS, ctod("  /  /    ") )
			NX0->NX0_DFIMFX := Iif(cTEMFX == "1", dDFIMTS, ctod("  /  /    ") )
			If oParams:GetTpExec() $ "2|6" //Refazer 
				NX0->NX0_USRALT := cJurUser
				NX0->NX0_DTALT  := date()
			EndIf
			NX0->NX0_TS     := cTEMTS
			NX0->NX0_DESP   := cTEMDP
			NX0->NX0_LANTAB := cTEMLT
			NX0->NX0_FIXO   := cTEMFX
			NX0->NX0_FATADC := cTEMFA
			If lCpoFxNc
				NX0->NX0_FXNC   := IIF(oParams:GetFltrFxNc(), "1", "2")
				NX0->NX0_DIFXNC := IIF(oParams:GetFltrFxNc(), oParams:GetDIniFxNc(), CtoD("  /  /    "))
				NX0->NX0_DFFXNC := IIF(oParams:GetFltrFxNc(), oParams:GetDFinFxNc(), CtoD("  /  /    "))
			EndIf
			NX0->NX0_CGRUPO := cCGRPVEN
			NX0->NX0_CCLIEN := cCCLIENTE
			NX0->NX0_CLOJA  := cCLOJA
			NX0->NX0_CFTADC := cNVVCOD
			NX0->NX0_CPAREX := " "
			NX0->NX0_DTINC  := dDTINC
			NX0->NX0_REVIS  := cREVIS
			NX0->NX0_CODUSR := oParams:GetCodUser()
			NX0->NX0_VTS    := nVTS
			NX0->NX0_ALTPER := cAltper
			NX0->NX0_DMAXEM := dDIAEMI
			NX0->NX0_PERFAT := 100
			NX0->NX0_VLRHFA := 0
			NX0->NX0_VLRDFA := 0
			NX0->NX0_FATOLD := cFATOLD
			NX0->NX0_ESCOLD := cESCOLD
			NX0->NX0_CIDIO  := cIDIOMA
			NX0->NX0_USUEMI := cJurUser
			NX0->NX0_DESCH  := nDESCH
			NX0->NX0_PDESCH := nPDESCH
			NX0->NX0_ACRESH := nACRESH
			NX0->NX0_PACREH := nPACREH
			NX0->NX0_VDESCT := nDESCH + nVDESCO
			NX0->NX0_TPDESC := cTpDesc
			NX0->NX0_TPACRE := cTpAcre
			NX0->NX0_VLFATT := vVlTab
			NX0->NX0_VLFATF := nVlFixo
			If lPoNumber
				NX0->NX0_PONUMB := cPoNumber
			EndIf
			If lServicos
				NX0->NX0_SERVIC := cServicos
			EndIf
			If lServReinf
				NX0->NX0_TPSERV := cServReinf
			EndIf
			If NX0->(FieldPos('NX0_FATURA')) > 0
				NX0->NX0_FATURA := "2"
			EndIf
			If lDespTrib
				NX0->NX0_VLTRIB := nVlDpTrib 
				NX0->NX0_VLREMB := nVlDpReemb
			EndIf
			If lTipoFech // Tipo de Fechamento
				NX0->NX0_TPFECH := cTipoFech
			EndIf
			NX0->NX0_RELPRE := cTipoRel
			NX0->(MsUnlock())
			NX0->(DbCommit())

			J202HIST('1', cCodPre, cJurUser)

			aRet := {.T., "JA201HPreF"}
		Else
			RecLock("NX0", .F.)
			NX0->NX0_CMOEDA     := cCMOEDFT
			NX0->NX0_VLFATD     := nVDESP
			NX0->NX0_VLFATH     := nVHON
			NX0->NX0_DESCON     := nVDESCO
			NX0->NX0_SITUAC     := cSITUAC
			If oParams:GetTpExec() $ "2|6" //Refazer 
				NX0->NX0_USRALT := cJurUser
				NX0->NX0_DTALT  := date()
			EndIf
			NX0->NX0_VTS    := nVTS
			NX0->NX0_DESCH  := nDESCH
			NX0->NX0_PDESCH := nPDESCH
			NX0->NX0_ACRESH := nACRESH
			NX0->NX0_PACREH := nPACREH
			NX0->NX0_VDESCT := nDESCH + nVDESCO
			NX0->NX0_CODUSR := oParams:GetCodUser()
			If NX0->(FieldPos('NX0_FATURA')) > 0
				NX0->NX0_FATURA	:= "2"
			EndIf
			NX0->NX0_VLFATT := vVlTab
			NX0->NX0_VLFATF := nVlFixo
			If lDespTrib
				NX0->NX0_VLTRIB := nVlDpTrib
				NX0->NX0_VLREMB := nVlDpReemb
			EndIf
			NX0->(MsUnlock())
			NX0->(DbCommit())  
			
			//Insere o Histórico na pré-fatura
			J202HIST('1', cCodPre, cJurUser)
			If lIntegracao .And. (oParams:GetSituac() != '1') 
				//Grava na fila de sincronização a alteração de pré-fatura
				If oParams:GetSituac() == "6" .And. !JA201TemFt(cCodPre)
					J170GRAVA("JURA202E", xFilial("NX0") + cCodPre, "3")
				EndIf
			EndIf
				
			aRet := {.T., "JA201HPreF"}
		EndIf
	Else
		aRet := {.F., "JA201HPreF - "+STR0001}
	EndIf

	RestArea(aArea)
	
Return ( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201HNomUsr
Rotina para retornar o nome do usuário

@author Jorge Luis Branco Martins Junior
@since 13/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201HNomUsr()
Local cUsuEmi   := NX0->NX0_USUEMI
Local cQuery    := ""
Local aArea     := GetArea()
Local cResQRY   := GetNextAlias()
Local cRet      := ""

cQuery := "SELECT RD0.RD0_NOME "
cQuery +=      " FROM " + RetSqlName("RD0") +" RD0 "
cQuery +=      " WHERE RD0.RD0_FILIAL = '" + xFilial("RD0") +"' "
cQuery +=      " AND RD0.RD0_USER = '" + cUsuEmi + "'"
cQuery +=      " AND RD0.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cResQRY, .T., .T.)

cRet := (cResQRY)->RD0_NOME

(cResQRY)->( dbcloseArea() )

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201HDesc
Rotina para ajustar o desconto especial entre os casos

@author TOTVS
@since 13/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201HDesc(cPreFt, nDESCH)
Local aRet      := {.T., "JA201HDesc"}
Local aArea     := GetArea()
Local aAreaNX1  := NX1->(GetArea())
Local aAreaNX8  := NX8->(GetArea())
Local nPercent  := 0
Local nTotDesc  := 0
Local nDescEsp  := 0

NX1->(DbSetOrder(3)) //NX1_FILIAL+NX1_CPREFT+NX1_CCONTR
If NX1->(DbSeek( xFilial('NX1') + cPreFt))
	While NX1->(NX1_FILIAL + NX1_CPREFT) == xFilial('NX1') + cPreFt
		nTotDesc := nTotDesc + NX1->NX1_VLDESC
		NX1->( dbSkip())
	EndDo
EndIf

If (nPercent := nDESCH / nTotDesc) != 1

	NX8->(DbSetOrder(1)) //NX8_FILIAL+NX8_CPREFT+NX8_CCONTR
	If NX8->(DbSeek( xFilial('NX8') + cPreFt))
		While NX8->(NX8_FILIAL + NX8_CPREFT) == xFilial('NX8') + cPreFt
			nDescEsp := 0
			If NX1->(DbSeek( xFilial('NX1') + NX8->(NX8_CPREFT + NX8_CCONTR)))
				While NX1->(NX1_FILIAL + NX1_CPREFT + NX1_CCONTR) == xFilial('NX1') + NX8->(NX8_CPREFT + NX8_CCONTR)
					RecLock( 'NX1', .F. , .F., .F., .T.)
					NX1->NX1_VLDESC := Round(NX1->NX1_VLDESC * nPercent, TamSX3('NX1_VLDESC')[2])
					NX1->NX1_VDESCT := NX1->NX1_VDESCO + NX1->NX1_VLDESC
					NX1->NX1_PCDESC := NX1->NX1_VLDESC / (NX1->NX1_VTS + NX1->NX1_VFIXO - NX1->NX1_VDESCO) * 100.00
					NX1->(MsUnLock())
					NX1->(DbCommit())
					nDescEsp  := nDescEsp + NX1->NX1_VLDESC
					NX1->(DbSkip())
				EndDo
			EndIf

			RecLock('NX8', .F., .F., .F., .T.)
			NX8->NX8_VLDESC := Round(nDescEsp, TamSX3('NX8_VLDESC')[2])
			NX8->NX8_VDESCT := NX8->NX8_VDESCO + NX8->NX8_VLDESC
			NX8->(DbCommit())

			NX8->(DbSkip())

		EndDo

	EndIf

EndIf

RestArea( aAreaNX1 )
RestArea( aAreaNX8 )
RestArea( aArea )

Return aRet
