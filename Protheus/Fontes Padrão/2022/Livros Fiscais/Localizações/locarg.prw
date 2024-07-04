#INCLUDE "PROTHEUS.CH"  
#INCLUDE "RWMAKE.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "LOCARG.CH"
#INCLUDE 'FWLIBVERSION.CH' 

Static _lMetric	:= Nil
 /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³LocArg    º Autor ³ Marcos Kato             º Data ³  16/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Montagem das informacoes arquivo magnetico                      º±±s
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³ Data   ³ BOPS    ³  Motivo da  Alteracao                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºLuisEnríquez³10-01-17³SERINN001³-Se realiza merge para agregar cambio en    º±±
±±º            ³        ³-425     ³creacion de tablas temporales.              º±±
±±ºLuisEnriquez³09-02-17³MMI-249  ³Merge de 12.1.14 MI. Se modificaron las fun-º±±
±±º            ³        ³         ³ciones LOCARG y LocTrbs para crear y llenar º±±
±±º            ³        ³         ³tabla temporal DGR19310 con la cual se crea º±±
±±º            ³        ³         ³archivo .txt [DGR 193/10 – Chubut (“CB”) -  º±±
±±º            ³        ³         ³Régimen de Retenciones y Percepciones –     º±±
±±º            ³        ³         ³Aplicativo Web: WAPIB].(Argentina)          º±±
±±ºLuisEnriquez³20-02-17³MMI-248  ³Merge de 12.1.14 MI. Se modifica la funcion º±±
±±º            ³        ³         ³CredFisSer para hacer INNER JOIN con tablas º±±
±±º            ³        ³         ³SEK y SA6, para obtener CUIT de banco y paraº±±
±±º            ³        ³         ³contar registros generados para el regimen  º±±
±±º            ³        ³         ³REGINFO_CV_CREDITO_FISCAL_IMP_SERVICIOS(ARG)º±±
±±ºLuisEnriquez³28-02-17³MMI-199  ³Merge 12.1.14 MI Se elimina condicion para  º±±
±±º            ³        ³         ³CCT_VDESTI al momento de buscar en la tabla º±±
±±º            ³        ³         ³de equivalencia y se agregan las funciones  º±±
±±º            ³        ³         ³BuscaSFH y VigSFH para obtener el código de º±±
±±º            ³        ³         ³clasificación. (Argentina).                 º±±
±±ºLuisEnriquez³11-04-17³MMI-257  ³Merge 12.1.14 MI para agregar replicas aten-º±±
±±º            ³        ³         ³didas de llamados TUDWON,TUFUY6,TUFKM0,     º±±
±±º            ³        ³         ³,TUNKBX,TUSWXF y TUX801. (ARG)              º±±
±±ºLuisEnriquez³26-04-17³MMI-196  ³Merge 12.1.14 MI para agregar replicas aten-º±±
±±º            ³        ³         ³didas de llamados TVDMIB,TVZXF3,MMI-4519,   º±±
±±º            ³        ³         ³TVNO78,TVWDXA,MMI-36,MMI-4746,MMI-4748,     º±±
±±º            ³        ³         ³TVKSHX, MMI-4581,TVKVJZ, TVHNEG,TUWGH8,     º±±
±±º            ³        ³         ³TUTTPM y TUITD1  (ARG)                      º±±
±±ºLuisEnriquez³02-05-17³MMI-202  ³Merge 12.1.14 MI para agregar replicas aten-º±±
±±º            ³        ³         ³didas de llamados TVSIVF,TVFLJK,TVUEA4,     º±±
±±º            ³        ³         ³TWIYHI,TWFTW6,TVJMDY,TVTHCN,MMI-4594,TVPXBS,º±± 
±±º            ³        ³         ³y TVLYZG (ARG)                              º±±
±±ºLuisEnriquez³22-05-17³MMI-4937 ³Merge 12.1.14 MI Se realiza modificación pa-º±±
±±º(Argentina) ³        ³         ³ra obtener valor de concepto de tabla de    º±±
±±º            ³        ³         ³conceptos (contribuyentes) si el contribu-  º±±
±±º            ³        ³         ³yente es de tipo Conv. Multilateral IBXCH.  º±±
±±ºJose Glez   ³15-06-17³MMI-5959 ³MERGE Cambio en el llenado de datos de la   º±±
±±º(Argentina) ³        ³         ³RG3685 en arch de venta para conf. de Loja. º±±
±±ºDanilo S.   ³12-03-18³DMICNS-1253³Correção da geração do arquivo RG2849     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LOCARG(cArquivo,cDtIni,cDtFim,aCodTab,lConfirm,aArTmp,lEsCons)

	Local cQryNLvro :="", cQryPer  :="", cQryRet  :="", cQryCliFor:="", cTRBS01:=""
	Local cTRBLVRO  :="", cTRBPER  :="", cTRBRET  :=""
	Local cCodTab1  :="", cCodTab2 :="", cCodTab3 :="", cCodTab4 :="",nPorSFH:= 0
	Local cCondIB1  :="", cCondIB2 :="", cSitIva  :=""
	Local cConcepto :="", cCodCfo  :="", cCodCon  :=""
	Local cTipCom   :="", cLetCom  :="", cNumCom  :=""
	Local cCodEst   :="", cCodTip  :="", cCUITFor :="", cRazSoc  :=""
	Local nLvr :=0
	Local cDomic    :="", cCiudad  :="", cCP      :=""
	Local cDomc  	:="", cMun     :="", cCep     :="",	cNroAge:="",	cNome:="",	cCateg:="",	cNigb:="" //SIAPE
	Local cSDoc		:= ""
	Local cQrRentax	:= ""
	Local nProcFil	:= 0
	Local nProsFil := 0
	Local cBkpFil		:= ""
	Local ctransCGC	:= ""
	Local nImporte  :=0 , nlI      :=0
	Local nImpNF    :=0 , nImp     :=0 , nAnulac :=0 , nCont   :=0
	Local nVlrIBr   :=0 , nBasIBr  :=0 , nRetIBr :=0
	Local nVlrIva   :=0 , nBasIva  :=0 , nRetIva :=0
	Local nCliFor   :=0
	Local nCodOpeNP := 40000001
	Local nCodOpeAP := 50000001
	Local nCodOpeNR := 10000001
	Local nCodOpeAR := 30000001
	Local lOk       :=.T.
	Local lPer	    :=.T.
	Local lRet	    :=.T.
	Local lImp	    :=.T.
	Local lSipRib   :=.T.
	Local aNrLvrIB  :={}
	Local aNrLvrIV  :={}
	Local aNrLvrGI  :={}
	Local aLogReg   :={}
	Local aChave    :={}
	Local aCNPJ     :={}
	Local aCliFor   :={}
	Local nValRG2849:= 0
	Local lRG2849:= .F.
	Local DGREsp := ""
	Local cFchPri := ""
	Local cCliFor   := "" // SICORE
	Local cLojaCF   := "" // SICORE
	Local aNrLvrPIG :={}  // SICORE    
	Local cDGRNome := ""  // DGR3027
	Local cDGRCGC  := ""  // DGR3027 
	Local cDGREnd  := ""  // DGR3027
	Local cDGRNIGB := ""  // DGR3027
	Local nRetAdc  := 0   // DGR3027
	Local aNrLvrGN:= {},	aNrLvrIn := {},	aNrLvrIm := {}, aNrLvrIip :={}, aNrLvrMn := {}, aNrLvIVA := {} // CV3865
	Local cNDocto := '', cNFiscal := '',cPedido := '', cTipDoc := '', cLlave := ""// CV3865
	Local cAliasSF:= "",aAreaSF1 := {} ,aAreaSF2 := {} // CV3865
	Local cPerini := Substr(cDtIni,1,4) + Substr(cDtIni,5,2) + "01" // Inicio de periodo 
	Local cPerfin := Substr(cDtIni,1,4) + Substr(cDtIni,5,2) + UltDiaMes(0,0,cDtIni)  // Fin de periodo 
	Local cQrySf3	:= ""
	Local nTpAliq  := 0
	Local nSinal := 1
	Local nAliq     := ""    
	Local cTpRecaud := "" 
	Local aSIRE := {}
	Local cCodAct := ""
	Local aActPRov := {}
	Local nPosAct := 0
	Local nPosProv := 0
	Local nRegs := 0
	Local lGetDB   := AllTrim(Upper(TCGetDB())) $ "ORACLE|POSTGRES"  //.T. - Oracle, .F. - Otros manejadores
	Local aCodFP 	:= {}
	Local nCodPf	:= 0
	Local cPTPAG	:= ""
	Local cAliasAux := ""
	Local cQueryAuxi := ""
	Local cTipoCom	:= ""
	Local cCodJur	:= ""
	Local aSA6		:= {}
	Local _aArea	:= ""
	Local cClaveSA6	:= ""
	Local cDesp		:= "" 
	Local nValorRet := 0
	Local cCertRet := ""
	Local nPosTEM := 0
	Local nPosPYP := 0
	Local nSoma2	:= 0
	Local cNUCONS := ""
	Local aProvSircar := {}
   	Local nPos := 0 
   	Local nInd
   	Local nBaseIva := 0
   	Local nVlNCP	:= 0
	Local nBaseSIRCAR :=0
	Local nValSIRCAR  :=0
	Local aAreaAt:=GetArea()
	Local nQtdFil:= 0
	Local nAliSIRCAR := 0
	Local cCoe := "" 
	Local aAreaAnt	:={}
	Local nbusca 	:= 0
	Local cCodReg	:=""
	Local nNumFil := 0
	Local cIdMetric		:= ""
	Local cSubRutina	:= ""

	
	Private oTmpTable 
	Private oTmpTable2 
	Private oTmpTable3 
	Private oTmpTable4 
	Private oTmpTable5 
	Private oTmpTable6 
	Private oTmpTable7 
	Private aOrdem := {}
	Private aCond	:={} // Execpciones de condiciones Sicore 9.1 
	Default aCodTab := {}
	Default lConfirm:= .T.
	Default aArTmp  := {}
	Default lEsCons := .F.
	

	If !(UPPER(cArquivo) $ "CV3865|RENTAX")	.AND. !IsInCallStack("LOCIVAPER") .AND. !IsInCallStack("LOCARQ")
		LocTrbs(cArquivo,@aArTmp,lEsCons)
	EndIf

	If (UPPER(cArquivo)$"SICORE"  .And. Len(aCodTab[1])>=7 )  // Sicore 9.1
		aAreaAnt:=GetArea()
		DbSelectArea("CCP")
		CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
		CCP->(DbGoTop())
		If MsSeek(xFilial("CCP")+AvKey(Alltrim(aCodTab[1][7]),"CCP_COD"))// TABELA DE EQUIVALENCIA
			Do While CCP->(!Eof()) .And. Alltrim(aCodTab[1][7])==Alltrim(CCP->CCP_COD)
				If Ascan(aCond,{|x| Alltrim(x[1])==Alltrim(CCP_VORIGE)}) == 0 
					Aadd(aCond,{Alltrim(CCP_VORIGE),Alltrim(CCP->CCP_VDESTI)})
				EndIf
			CCP->(DbSkip())
			EndDo
		EndIf
		RestArea(aAreaAnt)
	EndIf 
	
	If Len(aCodTab)>0 .and. lConfirm
		If  IIf(UPPER(cArquivo)$"SICORE",Iif(!lEsCons,.T.,.F.),.T.)
			Aadd(aLogreg,Replicate("-",80))
			Aadd(aLogreg,STR0001)//"Parametros"
			Aadd(aLogreg,Replicate("=",80))
		EndIf
		If UPPER(cArquivo) == "CV3865"
			Aadd(aLogreg,STR0073 + " " + Substr(cDtIni,1,4))	// "Ano para generar"
			Aadd(aLogreg,STR0074 + " " + Substr(cDtIni,5,2))	// "Mes para generar"
			Aadd(aLogreg,"")
		Else
			If  IIf(UPPER(cArquivo)$"SICORE",Iif(!lEsCons,.T.,.F.),.T.)
				Aadd(aLogreg,STR0002+Substr(cDtIni,7,4)+"/"+Substr(cDtIni,5,2)+"/"+Substr(cDtIni,1,4))//"Data Inicial          :"
				Aadd(aLogreg,STR0003+Substr(cDtFim,7,4)+"/"+Substr(cDtFim,5,2)+"/"+Substr(cDtFim,1,4))//"Data Final            :"
			EndIf
		EndIf 

		//Metrica para informar el archivo magnetico a ser utilizado
		If LocArgLibM()
			cIdMetric   := "fiscal-protheus_exec-locarg_total"
			cSubRutina  := "locarg-" + cArquivo + "-total"
			If isBlind()
				cSubRutina  += "-auto"
			EndIf
			FWCustomMetrics():setSumMetric(cSubRutina, cIdMetric, 1, /*dDateSend*/, /*nLapTime*/,"LOCARG")
		EndIf
		
		If UPPER(cArquivo)$"IVAPER|IVARET|SIPRIB|SICORE|SIRCAR|SILARPIB|RG2849|SIAPE|DGR3027|CV3865|DGR19310|SIAPRE|DGR55-11|SIARE|RES53-14|IVAIMP|STAC-AR|PERCMUN|RES28-97|RES98-97"
			If  Iif(UPPER(cArquivo)$"SICORE",Iif(!lEsCons,.T.,.F.),.T.)
				Aadd(aLogreg,Replicate("*",80))
				If  cArquivo<>"RG2849" .And.  cArquivo<>"DGR3027" .And. cArquivo<>"RES53-14" .And. cArquivo<>"RES98-97" .And. cArquivo<>"RES28-97
					Aadd(aLogreg,STR0005)//"Inconsistencia"  ***
					Aadd(aLogreg,Replicate("*",80))
				EndIf
			EndIf
			If UPPER(cArquivo)$"IVAPER|IVARET|SIPRIB|SILARPIB|RG2849|SIARE"
				//PRIMEIRA TABELA DE ESQUIVALENCIA
				DbSelectArea("CCP")
				CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
				CCP->(DbGoTop())
				If DbSeek(xFilial("CCP")+AvKey(aCodTab[1][1],"CCP_COD"))//PRIMEIRA TABELA DE EQUIVALENCIA
					Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][1])+SPACE(1)+Alltrim(CCP->CCP_DESCR)+Space(1)+STR0007)//"Arquivo Sicore"#" informado"
				Else
					Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][1])+SPACE(1)+STR0007+Space(1)+STR0008)//"Tabela de Equivalencia "#" nao cadastrado"
				EndIf
			ElseIf UPPER(cArquivo)=="SICORE" .And. !lEsCons
				If Empty(aCodTab[1][1])
					Aadd(aLogreg,STR0029+STR0030+":"+Alltrim(aCodTab[1][1])+Space(1)+STR0032)//"Nome do Arquivo"#"Deduções"#"não informado"
					lOk:=.F.
				EndIf
			ElseIf UPPER(cArquivo)=="SIRCAR"
				If Empty(aCodTab[1][4])
					Aadd(aLogreg, STR0079) //"Provincia não informada"
					lOk:=.F.
				EndIf
			ElseIf UPPER(cArquivo)=="SIAPE"			
				If Empty(aCodTab[1][1])
					Aadd(aLogreg,STR0029+STR0049+":"+Alltrim(aCodTab[1][1])+Space(1)+STR0032)//"Nome do Arquivo"#"Deduções"#"não informado"
					lOk:=.F.
				EndIf  
			ElseIf UPPER(cArquivo) == "DGR3027" .OR. UPPER(cArquivo) == "RES53-14"
				If Empty(aCodTab[1][1])
					Aadd(aLogreg,STR0079) //"Provincia não informada"
					lOk:=.F.
				EndIf
				If UPPER(cArquivo)=="RES53-14" .and. Substr(aCodTab[1][2],1,1)=="P" .and. ;
				   (SF1->(FieldPos("F1_5314CO")) = 0 .or. SF2->(FieldPos("F2_5314CO")) = 0 )
					If SF1->(FieldPos("F1_5314CO")) = 0
						Aadd(aLogreg,STR0080) //"Campo [F1_5314CO], Número de Comprobante no existe"
					EndIf 
					If SF2->(FieldPos("F2_5314CO")) = 0
						Aadd(aLogreg,STR0081) //"Campo [F2_5314CO], Número de Comprobante no existe"
					EndIf 
					lOk:=.F.
				EndIf 				
			ElseIf UPPER(cArquivo)=="CV3865" 
				If Empty(aCodTab[1][1])
					Aadd(aLogreg,STR0082) //"Secuencia no informada"
					lOk:=.F.
				EndIf
				If Empty(cDtIni)
					Aadd(aLogreg,STR0083) //"Fecha Inicial no informada"
					lOk:=.F.
				EndIf
				If SA1->(FieldPos("A1_AFIP")) = 0 
					Aadd(aLogreg,STR0084) //"Campo [A1_AFIP], Tipo doc no existe"
					lOk:=.F.
				EndIf
				If SA2->(FieldPos("A2_AFIP")) = 0 
					Aadd(aLogreg,STR0085) //"Campo [A2_AFIP], Tipo doc no existe"
					lOk:=.F.
				EndIf
				If SA2->(FieldPos("A2_NIF")) = 0
					Aadd(aLogreg,STR0086) //"Campo [A2_NIF], NIF no existe"
					lOk:=.F.
				EndIf
				If SA2->(FieldPos("A2_TIPROV")) = 0
					Aadd(aLogreg,STR0087) //"Campo [A2_TIPROV], Tipo Prov. no existe"
					lOk:=.F.			
				EndIf 
				If SF1->(FieldPos("F1_TCOMP")) = 0
					Aadd(aLogreg,STR0088) //"Campo [F1_TCOMP], Tipo de comprobante no existe"
					lOk:=.F.
				EndIf
				If SF2->(FieldPos("F2_TCOMP")) = 0
					Aadd(aLogreg,STR0089) //"Campo [F2_TCOMP], Tipo de comprobante no existe"
					lOk:=.F.
				EndIf 
			EndIf
			//SEGUNDA TABELA DE ESQUIVALENCIA
			If UPPER(cArquivo)$"SIPRIB|SILARPIB|SICORE"
				If  IIf(UPPER(cArquivo)$"SICORE",Iif(!lEsCons,.T.,.F.),.T.)
					DbSelectArea("CCP")
					CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
					CCP->(DbGoTop())
					If DbSeek(xFilial("CCP")+AvKey(aCodTab[1][2],"CCP_COD"))//SEGUNDA TABELA DE EQUIVALENCIA
						Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][2])+SPACE(1)+Alltrim(CCP->CCP_DESCR)+Space(1)+STR0007)//"Tabela de Equivalencia "#" informado "
					Else
						Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][2])+SPACE(1)+STR0007+Space(1)+STR0008)//"Tabela de Equivalencia "#" informado nao cadastrado"
						lOk:=.F.
					EndIf
				EndIf
			EndIf
			//TERCEIRA TABELA DE ESQUIVALENCIA
			If UPPER(cArquivo)$"SILARPIB"
				DbSelectArea("CCP")
				CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
				CCP->(DbGoTop())
				If DbSeek(xFilial("CCP")+AvKey(aCodTab[1][3],"CCP_COD"))//TERCEIRA TABELA DE EQUIVALENCIA
					Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][3])+SPACE(1)+Alltrim(CCP->CCP_DESCR)+Space(1)+STR0007)//"Tabela de Equivalencia "#" informado nao cadastrado"
				Else
					Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][3])+SPACE(1)+STR0007+Space(1)+STR0008)//"Tabela de Equivalencia "#" nao cadastrado"
					lOk:=.F.
				EndIf
			ElseIf UPPER(cArquivo)=="SICORE" .And. !lEsCons
				If Empty(aCodTab[1][3])
					Aadd(aLogreg,STR0029+STR0031+":"+Alltrim(aCodTab[1][3])+Space(1)+STR0032)//"Nome do Arquivo"#"Assuntos Retidos"#"não informado"
					lOk:=.F.
				EndIf
			EndIf
			//QUARTA TABELA DE ESQUIVALENCIA
			If UPPER(cArquivo)$"SILARPIB" .Or. UPPER(cArquivo)=="SICORE" .And. !lEsCons
				DbSelectArea("CCP")
				CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
				CCP->(DbGoTop())
				If DbSeek(xFilial("CCP")+AvKey(aCodTab[1][4],"CCP_COD"))//TERCEIRA TABELA DE EQUIVALENCIA
					Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][4])+SPACE(1)+Alltrim(CCP->CCP_DESCR)+Space(1)+STR0007)//"Tabela de Equivalencia "#" informado nao cadastrado"
				Else
					Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][4])+SPACE(1)+STR0007+Space(1)+STR0008)//"Tabela de Equivalencia "#" informado nao cadastrado"
					lOk:=.F.
				EndIf
			EndIf
			//TABELA DE ESQUIVALENCIA (GANANCIA)
			If UPPER(cArquivo)$"SICORE" .And. !lEsCons
				DbSelectArea("CCP")
				CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
				CCP->(DbGoTop())
				If DbSeek(xFilial("CCP")+AvKey(aCodTab[1][5],"CCP_COD"))//TERCEIRA TABELA DE EQUIVALENCIA
					Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][5])+SPACE(1)+Alltrim(CCP->CCP_DESCR)+Space(1)+STR0007)//"Tabela de Equivalencia "#" informado nao cadastrado"
				Else
					Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][5])+SPACE(1)+STR0007+Space(1)+STR0008)//"Tabela de Equivalencia "#" informado nao cadastrado"
					lOk:=.F.
				EndIf
			EndIf
		
			//TABELA DE ESQUIVALENCIA (IVA)
			If UPPER(cArquivo)$"SICORE" .And. !lEsCons
				DbSelectArea("CCP")
				CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
				CCP->(DbGoTop())
				If DbSeek(xFilial("CCP")+AvKey(aCodTab[1][6],"CCP_COD"))//TERCEIRA TABELA DE EQUIVALENCIA
					Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][6])+SPACE(1)+Alltrim(CCP->CCP_DESCR)+Space(1)+STR0007)//"Tabela de Equivalencia "#" informado nao cadastrado"
				Else
					Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][6])+SPACE(1)+STR0007+Space(1)+STR0008)//"Tabela de Equivalencia "#" informado nao cadastrado"
					lOk:=.F.
				EndIf
			EndIf
		
		//TABELA DE ESQUIVALENCIA (CPRN)
			If UPPER(cArquivo)$"DGR55-11"
				DbSelectArea("CCP")
				CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
				CCP->(DbGoTop())
				If DbSeek(xFilial("CCP")+"CPRN")//TERCEIRA TABELA DE EQUIVALENCIA
					Aadd(aLogreg,STR0004+SPACE(1)+"CPRN"+SPACE(1)+Alltrim(CCP->CCP_DESCR)+Space(1)+STR0007)//"Tabela de Equivalencia "#" informado nao cadastrado"
				Else
					Aadd(aLogreg,STR0004+SPACE(1)+"CPRN"+SPACE(1)+STR0007+Space(1)+STR0008)//"Tabela de Equivalencia "#" informado nao cadastrado"
					lOk:=.F.
				EndIf
			EndIf	
			//TABELA DE ESQUIVALENCIA (CPSC)
			If UPPER(cArquivo) $ "STAC-AR" .and. SubStr(aCodTab[1][1],1,1)=="R" 
				DbSelectArea("CCP")
				CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
				CCP->(DbGoTop())
				If DbSeek(xFilial("CCP") + AvKey(aCodTab[1][4],"CCP_COD"))
					Aadd( aLogreg,STR0004 + SPACE(1) + AvKey(aCodTab[1][4],"CCP_COD") + SPACE(1) + Alltrim(CCP->CCP_DESCR) + Space(1) + STR0007)//"Tabela de Equivalencia "#" informado nao cadastrado"
				Else
					Aadd( aLogreg,STR0004 + SPACE(1) + AvKey(aCodTab[1][4],"CCP_COD") + SPACE(1) + STR0007 + Space(1) + STR0008)//"Tabela de Equivalencia "#" informado nao cadastrado"
					lOk:=.F.
				EndIf
				cCodJur	:=	POSICIONE("CCO",1,xFilial("CCO")+"SC","CCO_CODJUR")
			Endif			
			
			If UPPER(cArquivo)$"SIAPRE|DGR55-11"     
				cCodJur	:=	POSICIONE("CCO",1,xFilial("CCO")+"TU","CCO_CODJUR")
			EndIf
			//=============================================================================================
			//SFB - IMPOSTOS VARIAVEIS
			//=============================================================================================
			//FB_CLASSIF - 1=Ingressos Brutos;2=Internos;3=IVA;4=Ganancias;5=Municipais;6=Suss;7=Importacao
			//FB_CLASSE  - I=IMPOSTO;P=PERCEPCAO;R=RETENCAO
			//=============================================================================================
			cQryNLvro:=" SELECT DISTINCT FB_CLASSIF CODIMP1 ,FB_CLASSE CODIMP2 ,FB_CODIGO CODIGO,FB_DESCR DESCR, FB_CPOLVRO NLIVRO,FB_TIPO TIPO, FB_ESTADO ESTADO "
			If cArquivo =="CV3865"
				cQryNLvro+=",FB_ALIQ ALIQ "
			EndIf   
			cQryNLvro+=" FROM "+RetsqlName("SFB")+" SFB "
			cQryNLvro+=" WHERE D_E_L_E_T_='' "
			cQryNLvro+=" AND FB_FILIAL= '" + xFilial("SFB") + "' "
			If cArquivo=="IVAPER"
				cQryNLvro+=" AND ((FB_CLASSIF = '3' "
				cQryNLvro+=" AND FB_CLASSE = 'P') "
				cQryNLvro+=" OR (FB_CLASSIF = '9' "
				cQryNLvro+=" AND FB_CLASSE = 'I' "
				cQryNLvro+=" AND FB_TIPO = 'N')) "
			ElseIf cArquivo=="SIPRIB"
				cQryNLvro+=" AND FB_CLASSIF IN ('1','3','3') "
				cQryNLvro+=" AND FB_CLASSE IN ('P','P','I') "
				cQryNLvro+=" AND FB_ESTADO = 'SF' "
			ElseIf 	UPPER(cArquivo)$"SIRCAR|SIAPE"
				cQryNLvro+=" AND FB_CLASSIF = '1'
				cQryNLvro+=" AND FB_CLASSE = 'P'
				IF UPPER(cArquivo)$"SIAPE" 
					cQryNLvro+=" AND FB_ESTADO = '" + aCodTab[1,2]+ "' "
				Else
				
					IF aCodTab[1,4] <> "CO"
						cQryNLvro+=" AND FB_ESTADO = '" + aCodTab[1,4]+ "' "
					Else
	                    
						cQryNLvro+=" OR ( FB_CLASSIF = '3' "
						cQryNLvro+=" AND FB_CLASSE = 'I' "
						cQryNLvro+=" AND FB_TIPO = 'N' ) " 
		
					EndIf
				EndIf
			ElseIf cArquivo=="SILARPIB"
				cQryNLvro+=" AND FB_CLASSE 	= 'P' "
				cQryNLvro+=" AND FB_CLASSIF 	= '1' "
				cQryNLvro+=" AND FB_FILIAL= '" + xFilial("SFB") + "' "
			ElseIf cArquivo=="RG2849"    // 3-IVA
				cQryNLvro+=" AND FB_CLASSE 	= 'I' "
				cQryNLvro+=" AND FB_CLASSIF = '3' "
			ElseIf cArquivo =="SIAPRE"
				cQryNLvro+=" AND FB_CLASSIF = '1' "
				cQryNLvro+=" AND FB_CLASSE = 'P' "
				cQryNLvro+=" AND FB_ESTADO = 'TU' "	
			ElseIf UPPER(cArquivo) == "DGR55-11|STAC-AR" .And. Substr(aCodTab[1][1],1,1)=="P"
				cQryNLvro+=" AND FB_CLASSIF = '1' "
				cQryNLvro+=" AND FB_CLASSE = 'P' "
				cQryNLvro+=" AND FB_ESTADO = '" + aCodTab[1,3] + "' " 
			ElseIf cArquivo =="RES98-97"     // FB_CLASSIF = Ing. Brutos y FB_CLASSE = Percepcion
				cQryNLvro+=" AND FB_CLASSIF = '1' "
				cQryNLvro+=" AND FB_CLASSE = 'P' "
				cQryNLvro+=" AND FB_ESTADO = '" + "FO" + "' "							
			ElseIf cArquivo =="CV3865" 
				If !Empty(Alltrim(xFilial("SFB")))
					cQryNLvro += " AND FB_FILIAL= '" + xFilial("SFB") + "' "
				EndIf 
				cQryNLvro += " AND FB_TIPO	IN ('N','P','M') "
				cQryNLvro += " AND FB_CLASSE	IN ('P','I') "
				cQryNLvro += " AND FB_CLASSIF	IN ('1','2','3','4','5','7','9') "
			ElseIf cArquivo == "DGR19310"
				cQryNLvro+=" AND FB_CLASSIF = '1' "
				cQryNLvro+=" AND FB_CLASSE = 'P' "
				cQryNLvro+=" AND FB_ESTADO = '" + aCodTab[2][1] + "'"
			ElseIf (UPPER(cArquivo)$"RES53-14" .And. Substr(aCodTab[1][2],1,1)=="P")
				cQryNLvro+=" AND FB_CLASSIF = '5' "
				cQryNLvro+=" AND FB_CLASSE = 'P' "
				cQryNLvro+=" AND FB_ESTADO = '" + "CO" + "' " 				
			ElseIf cArquivo =="SICORE" 
				cQryNLvro += " AND FB_FILIAL= '" + xFilial("SFB") + "' "				
			ElseIf cArquivo=="IVAIMP"
				cQryNLvro+=" AND FB_CLASSIF = '3' "
				cQryNLvro+=" AND FB_CLASSE = 'I' "
				cQryNLvro+=" AND FB_TIPO = 'N' "
			ElseIf cArquivo == "PERCMUN"
				cQryNLvro+=" AND FB_CLASSIF = '5' "
				cQryNLvro+=" AND FB_CLASSE = 'P' "
				cQryNLvro+=" AND FB_TIPO = 'M' "
				cQryNLvro+=" AND FB_ESTADO = 'TU'"												
			EndIf
			
			If Select("TRBLVRO")>0
				DbSelectArea("TRBLVRO")
				TRBLVRO->(DbCloseArea())
			EndIf
		
			cTRBLVRO := ChangeQuery(cQryNLvro)
			dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBLVRO ) ,"TRBLVRO", .T., .F.)
			aNrLvrIB:={}
			aNrLvrIV:={}
			aNrLvrGI:={}
			aNrLvrPIG :={}
			aNrLvrGN:= {}	
			aNrLvrIn := {}
			aNrLvrMn := {}
			aNrLvrIm := {}
			aNrLvrIip := {}
			
			DbSelectArea("TRBLVRO")
			TRBLVRO->(dbGoTop())
			If TRBLVRO->(!Eof())
				Do While TRBLVRO->(!Eof())
					DbSelectArea("SX3")
					SX3->(DbSetOrder(2))
					If !DbSeek("F3_VALIMP"+Alltrim(TRBLVRO->NLIVRO))
						Aadd(aLogreg,STR0033+Space(1)+Alltrim("F3_VALIMP"+Alltrim(TRBLVRO->NLIVRO))+Space(1)+STR0034)//"Campo"#"não existe na base de dados."
					ElseIf !DbSeek("F3_BASIMP"+Alltrim(TRBLVRO->NLIVRO))
						Aadd(aLogreg,STR0033+Space(1)+Alltrim("F3_BASIMP"+Alltrim(TRBLVRO->NLIVRO))+Space(1)+STR0034)//"Campo"#"não existe na base de dados."
					ElseIf UPPER(cArquivo) == "CV3865"
						If     TRBLVRO->TIPO == "N" .and. TRBLVRO->CODIMP2=="P" .and. TRBLVRO->CODIMP1=="4" // Imp Nacionales - Ganancias
							aAdd(aNrLvrGN,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO})
						ElseIf TRBLVRO->CODIMP2=="I" .and. TRBLVRO->CODIMP1=="3" 	// Impuesto - IVA
							aAdd(aNrLvIVA,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO,TRBLVRO->ALIQ})
						ElseIf TRBLVRO->TIPO == "N" .and. TRBLVRO->CODIMP2=="P" .and. TRBLVRO->CODIMP1=="3" // Percepcion IVA
							aAdd(aNrLvrIV,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO})
						ElseIf TRBLVRO->TIPO == "N" .and. TRBLVRO->CODIMP2=="P" .and. TRBLVRO->CODIMP1=="9" // Percepcion IVA importaciones
							aAdd(aNrLvrIV,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO})	
						ElseIf TRBLVRO->TIPO == "N" .and. TRBLVRO->CODIMP2=="I" .and. TRBLVRO->CODIMP1=="2" // Imp. Internos	
							aAdd(aNrLvrIn,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO})
						ElseIf TRBLVRO->TIPO == "P" .and. TRBLVRO->CODIMP2=="P" .and. TRBLVRO->CODIMP1=="1" // Ingresos Brutos
							aAdd(aNrLvrIB,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO})
						ElseIf TRBLVRO->TIPO == "M" .and. TRBLVRO->CODIMP2=="P" .and. TRBLVRO->CODIMP1=="5" // Imp. Muncipales
							aAdd(aNrLvrMn,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO})
						ElseIf TRBLVRO->TIPO == "N" .and. TRBLVRO->CODIMP2=="I" .and. TRBLVRO->CODIMP1=="7" // Imp. Importaciones	
							aAdd(aNrLvrIm,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO})
						ElseIf TRBLVRO->TIPO == "N" .and. TRBLVRO->CODIMP2=="I" .and. TRBLVRO->CODIMP1=="9" // IVA Importaciones	
							aAdd(aNrLvrIip,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO})
						EndIf 
					ElseIf (UPPER(cArquivo)$"RES53-14" .And. Substr(aCodTab[1][2],1,1)=="P")
						If TRBLVRO->TIPO == "M" .and. TRBLVRO->CODIMP2=="P" .and. TRBLVRO->CODIMP1=="5" // Imp. Muncipales
							aAdd(aNrLvrMn,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO})
						EndIf
					Else
						If TRBLVRO->CODIMP1=="1" .And. TRBLVRO->CODIMP2=="P" //Ingressos Brutos Percepcao
							aAdd(aNrLvrIB,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO,TRBLVRO->ESTADO})
						ElseIf TRBLVRO->CODIMP1=="3" .And. TRBLVRO->CODIMP2 $ "P|I"//Iva Percepcao/imposto   FB_CLASSE = ‘I’ y FB_CLASSIF = 3.
							If cArquivo=="RG2849" .And. TRBLVRO->CODIMP2 == "I"
								aAdd(aNrLvrGI,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO,TRBLVRO->ESTADO })
							ElseIf TRBLVRO->CODIMP1=="3" .And. TRBLVRO->TIPO == "N" .And. TRBLVRO->CODIMP2=="I" .And. ( cArquivo$"IVAIMP" .or. (UPPER(cArquivo)=="SIRCAR" .and. UPPER(ACODTAB[1][4]) == "CO"))
								aAdd(aNrLvrIV,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO})								
							Else
								aAdd(aNrLvrIV,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO}) //RG2849- Retencion IVA/Ganancia
							EndIf
						ElseIf (TRBLVRO->CODIMP1=="9" .And. TRBLVRO->TIPO == "N"  .AND. TRBLVRO->CODIMP2=="I") .And. cArquivo=="IVAPER"
							aAdd(aNrLvrIV,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO}) //RG2849- Retencion IVA/Ganancia							
						ElseIf TRBLVRO->TIPO == "M" .and. TRBLVRO->CODIMP2=="P" .and. TRBLVRO->CODIMP1=="5" // Imp. Muncipales
							aAdd(aNrLvrMn,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO})
						EndIf
					EndIf
					TRBLVRO->(DbSkip())
				End
			EndIf
		
			If (UPPER(cArquivo)$"IVAPER|SIPRIB|SILARPIB|RG2849|SIAPE|SIAPRE|CV3865|IVAIMP|PERCMUN" .Or. (UPPER(cArquivo)$"SIRCAR" .And. SubStr(aCodTab[1][3],1,1)=="2") .Or. (UPPER(cArquivo) $ "DGR55-11|STAC-AR" .And. SubStr(aCodTab[1][1],1,1)=="P") .Or. UPPER(cArquivo)$"SICORE" .Or. UPPER(cArquivo)$"RES98-97") .or. (UPPER(cArquivo) $ "DGR19310" .And. SubStr(aCodTab[1][1],1,1)=="2") .or. (UPPER(cArquivo)$"RES53-14" .And. Substr(aCodTab[1][2],1,1)=="P").And. lOk				
				//========================================================================================================================
				//PERCEPCAO
				//========================================================================================================================
			
				If  UPPER(cArquivo)$"SICORE|SIAPE"  //Filtro solo aplica si es Percepción
					DbSelectArea("TRBLVRO")
					TRBLVRO->(dbGoTop())
					If TRBLVRO->(!Eof())
						Do While TRBLVRO->(!Eof())
							DbSelectArea("SX3")
							SX3->(DbSetOrder(2))
							If  TRBLVRO->TIPO=="N" .And. (TRBLVRO->CODIMP1=="3" .Or. TRBLVRO->CODIMP1=="4")  .And. TRBLVRO->CODIMP2 $ "P" //Iva Percepcao/imposto   FB_CLASSE = ‘I’ y FB_CLASSIF = 3.
								aAdd(aNrLvrPIG,{TRBLVRO->CODIGO,TRBLVRO->NLIVRO,TRBLVRO->CODIMP1})
							EndIf
							TRBLVRO->(DbSkip())
						End
					EndIf
				EndIf
			
				nAnulac:=0
			
				If UPPER(cArquivo)=="RG2849"
					cQryPer:=" SELECT SF3.*  "
				Else
					cQryPer:=" SELECT SF3.* , "
					If (UPPER(cArquivo)=="SILARPIB") .Or. (UPPER(cArquivo)=="SIRCAR")
						cQryPer+="			A1_CGC CUIT, A1_NIGB INSCRIB, A1_TIPO TIPO "
					ElseIf UPPER(cArquivo)$"SICORE|SIAPE"
						If  lGetDB //Oracle
							cQryPer += " A1_LOJA LOJENT,Case When LENGTH(RTRIM(LTRIM(a2_cgc))) <> 0 then a2_cgc else A1_CGC End CUIT, A2_NROIB INSCRIB, A2_TIPO TIPO, A2_CODCOND "		
						Else 
							cQryPer += " A1_LOJA LOJENT,Case When LEN(RTRIM(LTRIM(a2_cgc))) <> '' then a2_cgc else A1_CGC End CUIT, A2_NROIB INSCRIB, A2_TIPO TIPO, A2_CODCOND "								
						EndIf								
					ElseIf UPPER(cArquivo)=="IVAPER"//
						cQryPer+="			A2_CGC CUITSA2, A2_NROIB, A2_TIPO, A1_CGC CUIT, A1_NIGB , A1_TIPO, A2_TIPROV  "
					ElseIf UPPER(cArquivo)=="SIPRIB"
						cQryPer+="			A2_CGC CUITSA2, A2_NROIB, A2_TIPO, A1_CGC CUIT, A1_NIGB , A1_TIPO TIPO, A1_NIGB INSCRIB"
					ElseIf UPPER(cArquivo)=="SIAPRE"
						cQryPer+=" 			A2_CGC, A2_NOME, A2_TIPROV, A2_BANCO, A2_AGENCIA, A2_NUMCON, A1_CGC, A1_NOME"																		
					ElseIf UPPER(cArquivo) $ "DGR55-11|CV3865|RES53-14|STAC-AR|RES98-97"  
						cQryPer+="			A2_COD, A2_CGC, A2_NOME, A1_COD, A1_CGC, A1_NOME"
						
						If UPPER(cArquivo)=="CV3865" 
							cQryPer += " ,A1_PAIS,A1_TIPO,A2_PAIS,A2_TIPO "
							If SA1->(FieldPos("A1_AFIP")) > 0 .and. SA2->(FieldPos("A2_AFIP")) > 0 
								cQryPer += " ,A1_AFIP,A2_AFIP "
							EndIf 
							If SA2->(FieldPos("A2_TIPROV")) > 0
								cQryPer += " ,A2_TIPROV "
							Else 
								cQryPer += " ,' ' A2_TIPROV "
							EndIf 	
						EndIf 
					ElseIf UPPER(cArquivo)=="IVAIMP"
						cQryPer+="			A2_CGC CUIT, A2_TIPROV TIPROV, F1_NUMDES NUMDESF1 "
					ElseIf UPPER(cArquivo)=="PERCMUN"
						cQryPer+="			A2_COD, A2_LOJA, A2_CGC, A2_NOME, A2_END, A1_COD, A1_LOJA, A1_CGC, A1_NOME, A1_END "												
					ElseIf UPPER(cArquivo)=="DGR19310"
						cQryPer+="			A1_COD, A1_LOJA, A1_CGC, A1_NROIB, A1_NOME, A1_END, A1_MUN, A1_CEP "						
					Else
						cQryPer+="			A2_CGC CUIT, A2_NROIB INSCRIB, A2_TIPO TIPO "
					EndIf
				EndIf

				cQryPer+=" FROM "+RetsqlName("SF3")+" SF3 "

				If UPPER(cArquivo)=="SILARPIB" .Or. UPPER(cArquivo)=="SIRCAR" .Or. UPPER(cArquivo)=="DGR19310"
					cQryPer+=" INNER JOIN "+RetsqlName("SA1")+" SA1 ON "
					cQryPer+=" A1_FILIAL = '" + xFilial("SA1") + "' "
					cQryPer+=" AND F3_CLIEFOR=A1_COD "
					cQryPer+=" AND F3_LOJA=A1_LOJA "
					cQryPer+=" AND SA1.D_E_L_E_T_='' "						
				Elseif  UPPER(cArquivo)$"IVAPER|SICORE|SIPRIB|SIAPE|SIAPRE|DGR55-11|RES98-97|CV3865|RES53-14|STAC-AR"
					cQryPer+=" LEFT JOIN "+RetsqlName("SA1")+" SA1 ON "
					cQryPer+=" A1_FILIAL = '" + xFilial("SA1") + "' "
					cQryPer+=" AND F3_CLIEFOR=A1_COD "
					cQryPer+=" AND F3_LOJA=A1_LOJA "
					cQryPer+=" AND SA1.D_E_L_E_T_='' "
					cQryPer+=" AND F3_FILIAL = '" + xFilial("SF3") + "' "					

					If UPPER(cArquivo)$"IVAPER|SIPRIB|SIAPE|SIAPRE|DGR55-11|RES98-97|RES98-97|STAC-AR|CV3865|RES53-14"
						cQryPer+=" AND F3_TIPOMOV = 'V' "
					Else
						cQryPer+=" AND F3_TIPOMOV = 'C' "
					EndIf
					cQryPer+=" LEFT JOIN "+RetsqlName("SA2")+" SA2 ON "
					cQryPer+=" A2_FILIAL = '" + xFilial("SA2") + "' "
					cQryPer+=" AND F3_CLIEFOR=A2_COD "
					cQryPer+=" AND F3_LOJA=A2_LOJA "
					cQryPer+=" AND SA2.D_E_L_E_T_='' "

					If UPPER(cArquivo)$"IVAPER|SIPRIB|SIAPE|SIAPRE|DGR55-11|RES98-97|STAC-AR|CV3865|RES53-14"
						cQryPer+=" AND F3_TIPOMOV = 'C' "
					Else
						cQryPer+=" AND F3_TIPOMOV = 'V' "
					EndIf

				Elseif UPPER(cArquivo)=="RG2849"
					cQryPer+="			 "
				ElseIf UPPER(cArquivo)=="PERCMUN"
					cQryPer+=" LEFT JOIN "+RetsqlName("SA1")+" SA1 ON "
					cQryPer+=" A1_FILIAL = '" + xFilial("SA1") + "' "
					cQryPer+=" AND F3_CLIEFOR=A1_COD "
					cQryPer+=" AND F3_LOJA=A1_LOJA "
					cQryPer+=" AND SA1.D_E_L_E_T_='' "
					cQryPer+=" LEFT JOIN "+RetsqlName("SA2")+" SA2 ON "
					cQryPer+=" A2_FILIAL = '" + xFilial("SA2") + "' "
					cQryPer+=" AND F3_CLIEFOR=A2_COD "
					cQryPer+=" AND F3_LOJA=A2_LOJA "
					cQryPer+=" AND SA2.D_E_L_E_T_='' "					
				Else
					cQryPer+=" INNER JOIN "+RetsqlName("SA2")+" SA2 ON "
					cQryPer+=" A2_FILIAL = '" + xFilial("SA2") + "' "
					cQryPer+=" AND F3_CLIEFOR=A2_COD "
					cQryPer+=" AND F3_LOJA=A2_LOJA "
					cQryPer+=" AND SA2.D_E_L_E_T_='' "
					If UPPER(cArquivo)== "IVAIMP"
						cQryPer+=" INNER JOIN "+RetsqlName("SF1")+" SF1 ON "
						cQryPer+=" F3_CLIEFOR=F1_FORNECE "
						cQryPer+=" AND F3_LOJA=F1_LOJA "
						cQryPer+=" AND F3_NFISCAL=F1_DOC "
						cQryPer+=" AND F3_SERIE=F1_SERIE "
						cQryPer+=" AND SF1.D_E_L_E_T_='' "
					EndIf					
				EndIf
				cQryPer+=" WHERE SF3.D_E_L_E_T_='' "
				If UPPER(cArquivo)=="IVAPER"
					cQryPer+=" AND ((F3_ESPECIE  IN ('NF','NDP','NCP','NCC','NDC','NDI') "
					cQryPer+=" AND  F3_TIPOMOV IN('C')) "
					cQryPer+=" OR (A2_TIPROV = 'A'"
					cQryPer+=" AND 	F3_ESPECIE   IN ('NF','NDP','NCI') "
					cQryPer+=" AND  F3_TIPOMOV = 'C' ))"
				ElseIf UPPER(cArquivo)=="SILARPIB"
					cQryPer+=" AND    F3_TIPOMOV = 'V' "
				ElseIf UPPER(cArquivo)=="SIRCAR"
					cQryPer+=" AND 	F3_ESPECIE   IN ('NF','NDP','NCP','NDC','NCC','NDE','NCE','NDI','NCI','CF') "
					cQryPer+=" AND  F3_TIPOMOV = 'V' "
					If MV_PAR06 == 1 .and. MV_PAR07 == 1  
						For nProsFil:=1 to len(aFilsCalc)		 
							If aFilsCalc[nProsFil,1] == .T.								
								IF nQtdFil==0				
									cQryPer+=" AND( F3_FILIAL = '"+aFilsCalc[nProsFil][2]+"' "
									nQtdFil:= nQtdFil+1									
								Else
		     						cQryPer+=" OR F3_FILIAL = '"+aFilsCalc[nProsFil][2]+"' "
								EndIf							
							EndIf
						Next nProsFil	
							 cQryPer+=")										
					Elseif MV_PAR06 == 1 .and. MV_PAR07 == 2 							
							cQryPer+=" AND F3_FILIAL = '"+cfilant+"' "				
					Else		
							cQryPer+=" AND F3_FILIAL = '"+FWCODFIL("SFE")+"' "
					EndIf
				ElseIf UPPER(cArquivo)=="SIPRIB"
					cQryPer+=" AND F3_TIPOMOV  ='V'"
					cQryPer+=" AND F3_TES  > '500'"   //sem notas de devolução
				ElseIf UPPER(cArquivo)=="SICORE"
					cQryPer+=" AND ((F3_ESPECIE IN ( 'NF', 'NCC', 'NDC' ) AND f3_tipomov = 'V') OR "
					cQryPer+=" (F3_ESPECIE IN ( 'NDI', 'NCI' ) AND F3_TIPOMOV = 'C')) "
					cQryPer+=" AND F3_DTCANC = '' "
				Elseif UPPER(cArquivo)=="RG2849"
					cQryPer+=" AND 	F3_ESPECIE   IN ('NF','NDP','NCI','NCP','NDI') "
					cQryPer+=" AND  F3_TIPOMOV = 'C' "
				ElseIf UPPER(cArquivo)=="SIAPE"
					cQryPer+=" AND ((F3_ESPECIE IN ('NDC','NCC','NDI', 'NCI' )) OR (F3_TIPOMOV = 'V' AND F3_ESPECIE='NF'))"		
				ElseIf UPPER(cArquivo)=="SIAPRE"
					cQryPer+=" AND ((F3_ESPECIE IN ('NF','NCP','NDP') AND F3_TIPOMOV='C') OR" 
					cQryPer+=" (F3_ESPECIE IN ('NDE','NCE') AND F3_TIPOMOV='V'))" 
				ElseIf (cArquivo == "DGR55-11" .And. Substr(aCodTab[1][1],1,1)=="P" )
					cQryPer+=" AND ((F3_TIPOMOV='V' AND F3_ESPECIE IN ('NF', 'NDC','NCC')) OR"
					cQryPer+="(F3_TIPOMOV='C' AND F3_ESPECIE IN ('NF', 'NDI','NCP')))"
				ElseIf UPPER(cArquivo)$"RES53-14"
					IF Substr(aCodTab[1][3],1,1)=="S" 
						cQryPer+=" AND (F3_TIPOMOV='C' AND F3_ESPECIE IN ('NF', 'NDI','NCP'))"
					ElseIf Substr(aCodTab[1][3],1,1)=="P" 
						cQryPer+=" AND (F3_TIPOMOV='V' AND F3_ESPECIE IN ('NF', 'NDC','NCC'))"						
					Else
						cQryPer+=" AND ((F3_TIPOMOV='V' AND F3_ESPECIE IN ('NF', 'NDC','NCC')) OR"
						cQryPer+="(F3_TIPOMOV='C' AND F3_ESPECIE IN ('NF', 'NDI','NCP')))"
					EndIf	
				ElseIf  cArquivo =="RES98-97"
					cQryPer+=" AND ((F3_TIPOMOV='V' AND F3_ESPECIE IN ('NF','NDC','NCC')) OR"
					cQryPer+="(F3_TIPOMOV='C' AND F3_ESPECIE IN ('NDI','NCI')))"
					cQryPer+=" AND F3_FILIAL = '"+xFilial("SF3")+"' "
				ElseIf (cArquivo == "STAC-AR" .And. Substr(aCodTab[1][1],1,1)=="P" )
					cQryPer+=" AND F3_ESTADO = '" + aCodTab[1,3] + "' "
					cQryPer+=" AND ((F3_TIPOMOV='V' AND F3_ESPECIE IN ('NF', 'NDC','NCC','NCE','NDE')) OR"
					cQryPer+="(F3_TIPOMOV='C' AND F3_ESPECIE IN ('NF', 'NDP','NCP','NCI','NDI')))" 
					cQryPer+=" AND F3_FILIAL = '" + xFilial("SF3") + "' "																											
				ElseIf cArquivo == "CV3865"
					If Substr(aCodTab[1][2],1,1) = "V"
						cQryPer+=" AND ((F3_TIPOMOV='V' AND F3_ESPECIE IN ('NF', 'NDC','NCC','NCE','NDE','CF') AND F3_EMISSAO BETWEEN '" + cPerini + "' AND '" + cPerfin + "' ))"
					ElseIf Substr(aCodTab[1][2],1,1) = "C"
						cQryPer+=" AND ((F3_TIPOMOV='C' AND F3_ESPECIE IN ('NF', 'NDP','NCP','NCI','NDI') AND F3_ENTRADA BETWEEN '" + cPerini + "' AND '" + cPerfin + "' ))" 
					ElseIf Substr(aCodTab[1][2],1,1) = "T"
						cQryPer+=" AND ((F3_TIPOMOV='V' AND F3_ESPECIE IN ('NF', 'NDC','NCC','NCE','NDE','CF') and F3_EMISSAO BETWEEN '" + cPerini + "' AND '" + cPerfin + "' ) OR"
						cQryPer+=" (F3_TIPOMOV='C' AND F3_ESPECIE IN ('NF', 'NDP','NCP','NCI','NDI') and F3_ENTRADA BETWEEN '" + cPerini + "' AND '" + cPerfin + "' ))" 
					EndIf 
				ElseIf UPPER(cArquivo) == "PERCMUN" .Or. (UPPER(cArquivo) $ "DGR19310" .And. SubStr(aCodTab[1][1],1,1)=="2")
					cQryPer+="AND F3_TIPOMOV='V' AND F3_ESPECIE IN ('NF','NDC','NCC','NDI','NCI')"    
				ElseIf UPPER(cArquivo)=="IVAIMP"
					cQryPer+=" AND A2_TIPROV = 'A'"
					cQryPer+=" AND 	F3_ESPECIE   IN ('NF','NDP','NCI') "
					cQryPer+=" AND  F3_TIPOMOV = 'C' "
					cQryPer+=" AND F3_FILIAL = '"+xFilial("SF3")+"' "					    
				EndIf
				
				If Len(aNrLvrIB) > 0  .And.  IIF(UPPER(cArquivo) $ "SICORE|CV3865",.F.,.T.)
					cQryPer += " AND ("
					For nlI:=1 To Len(aNrLvrIB)
						If nlI <> 1
							cQryPer += " OR "
						EndIf
						cQryPer += " F3_VALIMP"+aNrLvrIB[nlI][2]+" > 0 "
					Next nlI
					cQryPer += ")"
				EndIf
				If Len(aNrLvrIV) > 0 .And.  IIF(UPPER(cArquivo) $ "SICORE|CV3865|SIRCAR",.F.,.T.) 
					cQryPer += " AND ("
					For nlI:=1 To Len(aNrLvrIV)
						If nlI <> 1
							cQryPer += " OR "
						EndIf
						cQryPer += " F3_VALIMP"+aNrLvrIV[nlI][2]+" > 0 "
					Next nlI
					cQryPer += ")"
				EndIf
				If Len(aNrLvrPIG)>0   .And.  UPPER(cArquivo)$"SICORE|SIAPE"
					cQryPer += " AND ("
					For nlI:=1 To Len(aNrLvrPIG)
						If nlI <> 1
							cQryPer += " OR "
						EndIf
						cQryPer += " F3_VALIMP"+aNrLvrPIG[nlI][2]+" > 0 "
					Next nlI
					cQryPer += ")"
				ElseIf Len(aNrLvrGI) > 0 .And. UPPER(cArquivo)<> "SICORE"
					cQryPer += " AND ("
					For nlI:=1 To Len(aNrLvrGI)
						If nlI <> 1
							cQryPer += " OR "
						EndIf
						cQryPer += " F3_VALIMP"+aNrLvrGI[nlI][2]+" > 0 "
					Next nlI
					cQryPer += ")"
				EndIf
				If Len(aNrLvrMn) > 0 .and. (UPPER(cArquivo)$"RES53-14" .And. Substr(aCodTab[1][2],1,1)=="P")
					cQryPer += " AND ("
					For nlI:=1 To Len(aNrLvrMn)
						If nlI <> 1
							cQryPer += " OR "
						EndIf
						cQryPer += " F3_VALIMP"+aNrLvrMn[nlI][2]+" > 0 "
					Next nlI
					cQryPer += ")"
				EndIf				
				If  UPPER(cArquivo) <> "SIRCAR"
					If UPPER(cArquivo) == "SICORE"
						If MV_PAR06 == 1 .and. MV_PAR07 == 1
							nQtdFil := 0  
							For nProsFil:=1 to len(aFilsCalc)		 
								If aFilsCalc[nProsFil,1] == .T.								
									IF nQtdFil==0				
										cQryPer+=" AND (F3_FILIAL = '"+aFilsCalc[nProsFil][2]+"' "
										nQtdFil:= nQtdFil+1									
									Else
										cQryPer+=" OR F3_FILIAL = '"+aFilsCalc[nProsFil][2]+"' "
									EndIf							
								EndIf
							Next nProsFil	
							cQryPer+=")
							nQtdFil := 0										
						Elseif MV_PAR06 == 1 .and. MV_PAR07 == 2 							
							cQryPer+=" AND F3_FILIAL = '"+cfilant+"' "				
						Else		
							cQryPer+=" AND F3_FILIAL = '"+FWCODFIL("SFE")+"' "
						EndIf
					Else
						cQryPer+=" AND F3_FILIAL = '" + xFilial("SF3") + "' "
					EndIf
				EndIf	
				If (UPPER(cArquivo) $ "DGR19310" .And. SubStr(aCodTab[1][1],1,1)=="2")
					cQryPer+=" AND F3_EMISSAO BETWEEN '"+ Substr(aCodTab[2][2],3,4) + Substr(aCodTab[2][2],1,2) + "01" +"' AND '"+ Substr(aCodTab[2][2],3,4) + Substr(aCodTab[2][2],1,2) + FLastDay(aCodTab[2][2]) +"' "		     		
				ElseIf UPPER(cArquivo) <> "CV3865" .AND. UPPER(cArquivo) <> "IVAPER"
					cQryPer+=" AND F3_EMISSAO BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "
				EndIf 
				If  UPPER(cArquivo) == "IVAPER"
					cQryPer+=" AND F3_ENTRADA BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "
				EndIf
				cQryPer+=" AND F3_CFO <>'' "

				IF UPPER(cArquivo) == "CV3865" .And.  Len(aCodTab[1]) >= 4 
					IF Substr(aCodTab[1][4],1,1)=="1"
						cQryPer+= "	AND F3_RG1415 = '066' AND F3_TPVENT IN ('B','A','1','4') AND SF3.D_E_L_E_T_='' "
					ElseIF Substr(aCodTab[1][4],1,1)=="2"
						cQryPer+= " AND ((F3_RG1415='066' AND  F3_TPVENT ='S' ) OR (F3_RG1415='066' AND  F3_TPVENT ='2' )  OR (F3_RG1415='032')) AND SF3.D_E_L_E_T_='' "
					Else 
						cQryPer+= " AND  F3_RG1415 <> '066' AND F3_RG1415<>'032' AND SF3.D_E_L_E_T_='' "
					EndIF
				EndIF
				IF  UPPER(cArquivo) <> "SIRCAR"
					cQryPer+=" ORDER BY F3_EMISSAO, F3_NFISCAL , F3_SERIE , F3_CLIEFOR ,F3_LOJA, F3_TIPOMOV "
				ELSE
					cQryPer+=" ORDER BY F3_EMISSAO,F3_NFISCAL, F3_SERIE , F3_CLIEFOR ,F3_LOJA,F3_TIPOMOV, F3_CFO,F3_ESTADO,F3_FILIAL,F3_ESPECIE"
				ENDIF
				
				If EXISTBLOCK("LCARGQSF")
					cQrySf3 := EXECBLOCK("LCARGQSF",.F.,.F.,{cQryPer,UPPER(cArquivo)})
					If  ValType(cQrySf3) == "C" .and. !Empty(cQrySf3)
						cQryPer := cQrySf3 
					EndIf 
				EndIf
			
				If Select("TRBPER")>0
					DbSelectArea("TRBPER")
					TRBPER->(DbCloseArea())
				EndIf
			
				IF  UPPER(cArquivo) <> "SIRCAR"
					cTRBPER := ChangeQuery(cQryPer)
					dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBPER ) ,"TRBPER", .T., .F.)
				ELSE
					
					cQryPer:=CFOSIRCAR(cQryPer,aNrLvrIB,aNrLvrIV)
					cTRBPER := ChangeQuery(cQryPer)
					dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBPER ) ,"TRBPER", .T., .F.)
				ENDIF
				DbSelectArea("TRBPER")
				TRBPER->(dbGoTop())
				If TRBPER->(!Eof()) .and. UPPER(cArquivo) <> "CV3865"
					Aadd(aLogreg,Replicate("=",80))
					Aadd(aLogreg,Iif(UPPER(cArquivo)=="RG2849",STR0016,STR0010)+" "+cArquivo)//"PERCEPCAO"
					Aadd(aLogreg,Replicate("=",80))
					Do While TRBPER->(!Eof()) .And. lOk
						cCodTab1:=""
						cCodTab2:=""
						cSitIva :=""
						nSinal	:=	1
						If	UPPER(cArquivo)=="SILARPIB"
							nSinal	:=	IIf(TRBPER->F3_TES <= '500',-1, 1)
						EndIf
						DbSelectArea("SF3")
						SF3->(DbSetOrder(4))//F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
						SF3->(DbGoTop())						
						If DbSeek(AvKey(TRBPER->F3_FILIAL,"F3_FILIAL")+AvKey(TRBPER->F3_CLIEFOR,"F3_CLIEFOR")+AvKey(TRBPER->F3_LOJA,"F3_LOJA")+AvKey(TRBPER->F3_NFISCAL,"F3_NFISCAL"+AvKey(TRBPER->F3_SERIE,"F3_SERIE")))	
							nVlrIBr:=0
							nBasIBr:=0
							nRetIBr:=0
							aProvSircar :={}   
							nBaseIva := 0
							If Len(aNrLvrIB)>0
								If UPPER(cArquivo)=="SIRCAR" .and. UPPER(ACODTAB[1][4]) $ "CO"
									
									For nInd:=1 To Len(aNrLvrIV)								
										If nBaseIva == 0
											nBaseIva := &("TRBPER->F3_BASIMP"+aNrLvrIV[nInd][2])  
										Else
											Exit
										EndIf
									Next	
								EndIf
									
								For nImpNF:=1 To Len(aNrLvrIB)
									If UPPER(cArquivo)=="SIRCAR" 

										If UPPER(ACODTAB[1][4]) $ "CO"
											If aNrLvrIB[nImpNF][3] $ "CO" .and. &("TRBPER->F3_BASIMP"+aNrLvrIB[nImpNF][2])>0 
												aProvSircar :={}
												Aadd(aProvSircar,{aNrLvrIB[nImpNF][3],Round(xMoeda(&("TRBPER->F3_BASIMP"+aNrLvrIB[nImpNF][2]),&("TRBPER->MONEDA"),1,dDataBase,MsDecimais(1)+1,&("TRBPER->TASA"),1),MsDecimais(1)),Round(xMoeda(&("TRBPER->F3_VALIMP"+aNrLvrIB[nImpNF][2]),&("TRBPER->MONEDA"),1,dDataBase,MsDecimais(1)+1,&("TRBPER->TASA"),1),MsDecimais(1))})
												Exit
											ElseIf !Empty(nBaseIva) .and. !Empty(&("TRBPER->F3_BASIMP"+aNrLvrIB[nImpNF][2]))
												aProvSircar :={}
												Aadd(aProvSircar,{aNrLvrIB[nImpNF][3],nBaseIva,0}) 
											EndIf
										Else
										   
											If Empty(aProvSircar)
												Aadd(aProvSircar,{aNrLvrIB[nImpNF][3],Round(xMoeda(&("TRBPER->F3_BASIMP"+aNrLvrIB[nImpNF][2]),&("TRBPER->MONEDA"),1,dDataBase,MsDecimais(1)+1,&("TRBPER->TASA"),1),MsDecimais(1)),Round(xMoeda(&("TRBPER->F3_VALIMP"+aNrLvrIB[nImpNF][2]),&("TRBPER->MONEDA"),1,dDataBase,MsDecimais(1)+1,&("TRBPER->TASA"),1),MsDecimais(1))}) 
											Else
												aProvSircar[1][2]+=Round(xMoeda(&("TRBPER->F3_BASIMP"+aNrLvrIB[nImpNF][2]),&("TRBPER->MONEDA"),1,dDataBase,MsDecimais(1)+1,&("TRBPER->TASA"),1),MsDecimais(1)) //&("TRBPER->F3_BASIMP"+aNrLvrIB[nImpNF][2]) 
												aProvSircar[1][3]+=Round(xMoeda(&("TRBPER->F3_VALIMP"+aNrLvrIB[nImpNF][2]),&("TRBPER->MONEDA"),1,dDataBase,MsDecimais(1)+1,&("TRBPER->TASA"),1),MsDecimais(1)) //&("TRBPER->F3_VALIMP"+aNrLvrIB[nImpNF][2])
											EndIf
												
										EndIf
									Else
										nVlrIBr+=&("TRBPER->F3_VALIMP"+aNrLvrIB[nImpNF][2]) * nSinal
										nBasIBr+=&("TRBPER->F3_BASIMP"+aNrLvrIB[nImpNF][2]) * nSinal
									EndIf 									
								Next
							EndIf
							nVlrIva:=0
							nBasIva:=0
							nRetIva:=0
							If Len(aNrLvrIV)>0 .and. UPPER(cArquivo)<>"SICORE"
								For nImpNF:=1 To Len(aNrLvrIV)
									nVlrIva+=&("TRBPER->F3_VALIMP"+aNrLvrIV[nImpNF][2])
									nBasIva+=&("TRBPER->F3_BASIMP"+aNrLvrIV[nImpNF][2])								
								Next
							EndIf
							If Len(aNrLvrPIG)>0
								For nImpNF:=1 To Len(aNrLvrPIG)
									nVlrIva+=&("TRBPER->F3_VALIMP"+aNrLvrPIG[nImpNF][2])
									nBasIva+=&("TRBPER->F3_BASIMP"+aNrLvrPIG[nImpNF][2])
								Next
							EndIf
						EndIf
						//TABELA DE ESQUIVALENCIA 001
						If UPPER(cArquivo)$"IVAPER|SIPRIB"
							cCodTab1:=""
							DbSelectArea("CCP")
							CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
							CCP->(DbGoTop())
							If DbSeek(xFilial("CCP")+Avkey(aCodTab[1][1],"CCP_COD")+AvKey(TRBPER->F3_CFO,"CCP_VORIGE"))//PRIMEIRA TABELA DE EQUIVALENCIA
								If UPPER(cArquivo)=="SIPRIB"
									Do While CCP->(!Eof()) .And. Alltrim(aCodTab[1][1])==Alltrim(CCP->CCP_COD)
										If Alltrim(TRBPER->F3_CFO) == Alltrim(CCP->CCP_VORIGE)
											cCodTab1:=Alltrim(CCP->CCP_VDESTI)
										EndIf
										CCP->(DbSkip())
									Enddo
								ELse
									cCodTab1:=Alltrim(CCP->CCP_VDESTI)
								EndIf
							EndIf
							If Empty(cCodTab1)
								Aadd(aLogreg,STR0011+SPACE(1)+TRBPER->F3_NFISCAL+SPACE(1)+STR0012+SPACE(1)+TRBPER->F3_SERIE+SPACE(1)+STR0013+SPACE(1)+TRBPER->F3_ESPECIE)//"Nota:"#" Serie:"#" Especie:"
								Aadd(aLogreg,STR0014+SPACE(1)+TRBPER->F3_CFO+SPACE(1)+STR0015+SPACE(1)+aCodTab[1][1]+"-"+ALLTRIM(CCP->CCP_DESCR))//"Codigo CFO:"#" nao possui codigo equivalente na Tabela de Equivalencia"
								TRBPER->(DbSkip())
								Loop
							EndIf
						EndIf
						//TABELA DE ESQUIVALENCIA 002
						If UPPER(cArquivo)$"SIPRIB|SIRCAR"
							cCodTab2:=""
							DbSelectArea("CCP")//TABELA DE EQUIVALENCIA
							CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
							CCP->(DbGoTop())
							If DbSeek(xFilial("CCP")+Avkey(aCodTab[1][2],"CCP_COD")+AvKey(TRBPER->F3_CFO,"CCP_VORIGE"))//SEGUNDA TABELA DE EQUIVALENCIA
								cCodTab2:=CCP->CCP_VDESTI
							Else
								Aadd(aLogreg,STR0011+SPACE(1)+TRBPER->F3_NFISCAL+SPACE(1)+STR0012+SPACE(1)+TRBPER->F3_SERIE+SPACE(1)+STR0013+SPACE(1)+TRBPER->F3_ESPECIE)//"Nota:"#" Serie:"#" Especie:"
								Aadd(aLogreg,STR0014+SPACE(1)+TRBPER->F3_CFO+SPACE(1)+STR0015+SPACE(1)+aCodTab[1][2]+"-"+ALLTRIM(CCP->CCP_DESCR))//"Codigo CFO:"#" nao possui codigo equivalente na Tabela de Equivalencia"
							EndIf
						EndIf
						//TABELA DE ESQUIVALENCIA 004
						If UPPER(cArquivo)$"SILARPIB"
							cCodTab4:=""
							DbSelectArea("CCP")
							CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
							CCP->(DbGoTop())
							If DbSeek(xFilial("CCP")+AvKey(aCodTab[1][4],"CCP_COD"))//TERCEIRA TABELA DE EQUIVALENCIA
								cCodTab4:=CCP->CCP_VDESTI
							Else
								Aadd(aLogreg,STR0004+SPACE(1)+aCodTab[1][4]+SPACE(1)+STR0007+Space(1)+STR0008)//"Tabela de Equivalencia "#" informado nao cadastrado"
							EndIf
						EndIf
					
						//TABELA DE ESQUIVALENCIA SIPEGAN/SIPEIVA
						If UPPER(cArquivo)$"SICORE"
							cCodTab3:=""
							DbSelectArea("CCP")
							CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
							CCP->(DbGoTop())    //SIPEIVA
							If DbSeek(xFilial("CCP")+Avkey(aCodTab[1][5],"CCP_COD")+AvKey(TRBPER->F3_CFO,"CCP_VORIGE"))//PRIMEIRA TABELA DE EQUIVALENCIA
								Do While CCP->(!Eof()) .And. Alltrim(aCodTab[1][5])==Alltrim(CCP->CCP_COD)
									If Alltrim(TRBPER->F3_CFO)==Alltrim(CCP->CCP_VORIGE)
										cCodTab3:=Alltrim(CCP->CCP_VDESTI)
									EndIf
									CCP->(DbSkip())
								End
							EndIf
							cCodTab4:=""
							DbSelectArea("CCP")
							CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
							CCP->(DbGoTop())    //SIPEGAN
							If DbSeek(xFilial("CCP")+Avkey(aCodTab[1][6],"CCP_COD")+AvKey(TRBPER->F3_CFO,"CCP_VORIGE"))//PRIMEIRA TABELA DE EQUIVALENCIA
								Do While CCP->(!Eof()) .And. Alltrim(aCodTab[1][6])==Alltrim(CCP->CCP_COD)
									If Alltrim(TRBPER->F3_CFO)==Alltrim(CCP->CCP_VORIGE)
										cCodTab4:=Alltrim(CCP->CCP_VDESTI)
									EndIf
									CCP->(DbSkip())
								End
							EndIf
							If  Empty(cCodTab3) .And. Empty(cCodTab4)
								Aadd(aLogreg,STR0011+SPACE(1)+TRBPER->F3_NFISCAL+SPACE(1)+STR0012+SPACE(1)+TRBPER->F3_SERIE+SPACE(1)+STR0013+SPACE(1)+TRBPER->F3_ESPECIE)//"Nota:"#" Serie:"#" Especie:"
								Aadd(aLogreg,STR0014+SPACE(1)+TRBPER->F3_CFO+SPACE(1)+STR0015+SPACE(1)+Iif(Empty(cCodTab3),aCodTab[1][5],aCodTab[1][6])+"-"+ALLTRIM(CCP->CCP_DESCR))//"Codigo CFO:"#" nao possui codigo equivalente na Tabela de Equivalencia"
								TRBPER->(DbSkip())
								Loop
							EndIf
						EndIf
						
						IF ALLTRIM(TRBPER->F3_ESPECIE) $ "NCP|NDI" .AND. UPPER(cArquivo)$"IVAPER"
							nVlNCP += nVlrIva
						EndIf
					
						IF UPPER(cArquivo)$"IVAPER"
							IF !ALLTRIM(TRBPER->F3_ESPECIE) $ "NCP|NDI"
								If nVlrIva>0
									nImp++
									DbSelectArea("IVAPER")
									IVAPER->(dbSetOrder(1))//RET_CODRET+RET_NUMCER
									IVAPER->(dbGoTop())
									RecLock("IVAPER",.T.)
									IVAPER->PER_CODPER := SUBSTR(cCodTab1,1,3)
								
									If TRBPER->F3_TIPOMOV == "C"
										IVAPER->PER_CUIT  := TRBPER->CUITSA2
									Else
										IVAPER->PER_CUIT  := TRBPER->CUIT
									EndIf
							    			
									IVAPER->PER_CUIT   := Transform(IVAPER->PER_CUIT,"@R XX-XXXXXXXX-X")												  //Formato Valido **99999999999, 99*99999999*9 ou 99-99999999-9
									IVAPER->PER_EMISS  := Substr(TRBPER->F3_EMISSAO,7,2)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4)//Formato Valido DD/MM/AAAA ou DD-MM-AAAA
									IVAPER->PER_NUMNF1 := SUBSTR(Alltrim(TRBPER->F3_NFISCAL),1,4)
									IVAPER->PER_NUMNF2 := SUBSTR(Alltrim(TRBPER->F3_NFISCAL),5,8)
									IVAPER->PER_VLRPER := Transform(nVlrIva,"@E 9999999999999.99")
									IVAPER->(MsUnlock())
								EndIf
							ENDIF
						ElseIf UPPER(cArquivo)$"SIPRIB"
							If Substr(aCodTab[1][3],1,1)=="2" .Or. Substr(aCodTab[1][3],1,1)=="3"//Percepcao ou Ambos
								//=============================================================================================
								//CCO - TABELA DE CADASTRO ESTADO X INGRESSOS BRUTOS
								//=============================================================================================
								//CCO_TIPO   - I=Resp. Inscrito;N=Resp. Nao Inscrito;X=Isento;E=Exportacao ;F=Cons. Final;
								//             M=Monotributarista;V=Convenio Multilateral;*=Indeterm
								//=============================================================================================
								cCondIB2 := BuscaSFH(IIF(TRBPER->F3_TIPOMOV == "C",AvKey(TRBPER->F3_CLIEFOR,"FH_FORNECE"),AvKey(TRBPER->F3_CLIEFOR,"FH_CLIENTE")), AvKey(TRBPER->F3_LOJA,"FH_LOJA"),"IBK",IIf(TRBPER->F3_TIPOMOV == "C",1,3),@lImp) //"FH_FILIAL+FH_CLIENTE+FH_LOJA+FH_IMPOSTO+FH_ZONFIS"
								//SITUACAO frente a IVA(0-No Corresponde,1-Responsable inscripto,2-Responsable no Inscripto,3-exento,4-Monotributo)
								//A2_TIPO->I=Resp.Insc.;N=Resp.nao Insc.;X=Isento;E=Fornecedor do Exterior;S=Nao Sujeito;M=Monotributarista
								If TRBPER->TIPO=="I"
									cSitIva:="1"
								ElseIf TRBPER->TIPO=="N"
									cSitIva:="2"
								ElseIf TRBPER->TIPO=="X"
									cSitIva:="3"
								ElseIf TRBPER->TIPO=="M"
									cSitIva:="4"
								Else
									cSitIva:="0"
								EndIf
								cTipCom:=""
								//cLetCom:=""
								cLetCom:="A"
								If !Empty(Alltrim(TRBPER->F3_SERIE))										
									cSDoc := SerieNFID("TRBPER", 2, "F3_SERIE")
									cLetCom:=UPPER(Alltrim(cSDoc))
								EndIf
								If SUBSTR(TRBPER->F3_ESPECIE,1,2)=="ND"
									cTipCom:="02"
								ElseIf SUBSTR(TRBPER->F3_ESPECIE,1,2)=="NC"
									cTipCom:="09"
								Else
									cTipCom:="01"
								EndIf
								nImp++
								DbSelectArea("SIPRIB")
								IF !DbSeek("2"+SUBSTR(cCodTab1,1,3)+SUBSTR(cTipCom,1,3)+Substr(TRBPER->F3_EMISSAO,7,2)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4);
								+TRBPER->F3_NFISCAl+TRBPER->F3_SERIE+TRBPER->F3_CLIEFOR+TRBPER->F3_LOJA)
									RecLock("SIPRIB",.T.)
									SIPRIB->SIP_TIPOPE:="2"    //Tipo Operacion - Percepcion
									SIPRIB->SIP_EMISS :=Substr(TRBPER->F3_EMISSAO,7,2)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4)//Fecha de Retencion-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
									SIPRIB->SIP_CODART:=SUBSTR(cCodTab1,1,3)//Codigo Articulo inciso por el que retiene
									SIPRIB->SIP_TIPCOM:=SUBSTR(cTipCom,1,3)//Tipo de Comprobante
									SIPRIB->SIP_LETCOM:=cLetCom            //Letra de Comprobante
									SIPRIB->SIP_NUMCOM:=PADL(Alltrim(TRBPER->F3_NFISCAL),Len(SIPRIB->SIP_NUMCOM)," ")  //Numero de Comprobante
									SIPRIB->SIP_DATCOM:=Substr(TRBPER->F3_ENTRADA,7,2)+"/"+Substr(TRBPER->F3_ENTRADA,5,2)+"/"+Substr(TRBPER->F3_ENTRADA,1,4)//Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
									SIPRIB->SIP_TIPDOC:="3"//Tipo de Documento(1-C.D.I->CHAVE DE INDENTIFICACAO|2-C.U.I.L->CODIGO UNICO DE IDENTIFICACAO LABORAL|3-C.U.I.T.->CHAVE UNICA DE IDENTIFICACAO TRIBUTARIA)
									SIPRIB->SIP_NUMDOC:=IIF(TRBPER->F3_TIPOMOV == "C", TRBPER->CUITSA2 , TRBPER->CUIT)	//CUIT
									SIPRIB->SIP_CONFIB:=cCondIB2//Condicion frente a Ingressos brutos
									SIPRIB->SIP_NUMIIB:=Iif(cCondIB2=="1",Substr(Alltrim(TRBPER->INSCRIB),1,10),Replicate("0",10))//Numero de inscripcion en Ingressos Brutos
									SIPRIB->SIP_SITIVA:=cSitIva//Situacion frente a Iva
									SIPRIB->SIP_INSOGR:="0"//Marca Inscripcion Otros Gravamenes
									SIPRIB->SIP_INSDRE:="0"//Marca Inscripcion DRel
									SIPRIB->SIP_ARTCAL:=SUBSTR(cCodTab2,1,3)//Articulo/Inciso para el calculo
									SIPRIB->SIP_IMPOGR:=PADL(Alltrim(Transform(0,"@E 999999999.99")),Len(SIPRIB->SIP_IMPOGR),"0")//Importe Otros Gravamenes

									SIPRIB->NUM_VLRCOM:=TRBPER->F3_VALCONT //Monto de Comprobante
									SIPRIB->NUM_IMPIVA:=nVlrIva//Iif(cSitIva=="1",Transform(nVlrIva,"@E 999999999.99"),Transform(0,"@E 999999999.99"))//Importe IVA- percepcao
									SIPRIB->NUM_BSCALC:=nBasIbr//Base imponible para el calculo
									SIPRIB->NUM_IMDET :=nVlrIbr//Impuesto Determinado
									SIPRIB->NUM_VLRRET:=nVlrIbr//Monto Retenido

									SIPRIB->SIP_VLRCOM:=PADL(Alltrim(Transform(SIPRIB->NUM_VLRCOM,"@E 999999999.99")),Len(SIPRIB->SIP_VLRCOM),"0")//Monto de Comprobante
									SIPRIB->SIP_IMPIVA:=PADL(Alltrim(Transform(SIPRIB->NUM_IMPIVA,"@E 999999999.99")),Len(SIPRIB->SIP_IMPIVA),"0")//Iif(cSitIva=="1",Transform(nVlrIva,"@E 999999999.99"),Transform(0,"@E 999999999.99"))//Importe IVA- percepcao
									SIPRIB->SIP_BSCALC:=PADL(Alltrim(Transform(SIPRIB->NUM_BSCALC,"@E 999999999.99")),Len(SIPRIB->SIP_BSCALC),"0")//Base imponible para el calculo
									SIPRIB->SIP_IMDET :=PADL(Alltrim(Transform(SIPRIB->NUM_IMDET,"@E 999999999.99")),Len(SIPRIB->SIP_IMDET),"0")//Impuesto Determinado
									SIPRIB->SIP_VLRRET:=PADL(Alltrim(Transform(SIPRIB->NUM_VLRRET,"@E 999999999.99")),Len(SIPRIB->SIP_VLRRET),"0")//Monto Retenido
									cTipExc := "0"
									cQueryAuxi := "Select FH_ISENTO, FH_PERCENT, FH_IMPOSTO, FH_ZONFIS, FH_INIVIGE, FH_DECRETO from " + RetSqlName("SFH") + " SFH Where FH_CLIENTE = '" + TRBPER->F3_CLIEFOR + "' AND FH_TIPO = '" + TRBPER->TIPO + "' AND FH_LOJA = '" + TRBPER->F3_LOJA + "' AND  (FH_INIVIGE = '' OR FH_INIVIGE <= '" + cDtIni + "') AND  (FH_FIMVIGE = '' OR FH_FIMVIGE >= '" + cDtFim + "')"
									cAliasAux := CriaTrab(nil, .f.)
									cQueryAuxi 	:= 	ChangeQuery(cQueryAuxi)
									dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryAuxi),cAliasAux,.F.,.T.)
										If (cAliasAux)->FH_ISENTO == "N" .AND. (cAliasAux)->FH_PERCENT == 0 .AND. ( (cAliasAux)->FH_IMPOSTO == "IBR" .OR. (cAliasAux)->FH_IMPOSTO == "IBK") .AND. (cAliasAux)->FH_ZONFIS == "SF"
											cTipExc := "0"// Tipo de Excención
										ElseIf (cAliasAux)->FH_ISENTO == "N" .AND. (cAliasAux)->FH_PERCENT <> 0 .AND.  (cAliasAux)->FH_IMPOSTO == "IBR" .AND. (cAliasAux)->FH_ZONFIS == "SF"
											cTipExc := "1"// Tipo de Excención
										ElseIf (cAliasAux)->FH_ISENTO == "S" .AND. (cAliasAux)->FH_IMPOSTO == "IBR" .AND. (cAliasAux)->FH_ZONFIS == "SF"
											cTipExc := "2"// Tipo de Excención
										ElseIf (cAliasAux)->FH_ISENTO == "N" .AND. (cAliasAux)->FH_PERCENT <> 0 .AND.  (cAliasAux)->FH_IMPOSTO == "IBK" .AND. (cAliasAux)->FH_ZONFIS == "SF"
											cTipExc := "3"// Tipo de Excención
										ElseIf (cAliasAux)->FH_ISENTO == "S" .AND.  (cAliasAux)->FH_IMPOSTO == "IBK" .AND. (cAliasAux)->FH_ZONFIS == "SF"
											cTipExc := "4"// Tipo de Excención
										EndIf
										
										SIPRIB->SIP_TIPEXE := cTipExc
										If cTipExc == "1" .OR. cTipExc == "2" .OR. cTipExc == "3"
											SIPRIB->SIP_EMISSE := SUBSTR((cAliasAux)->FH_INIVIGE ,1,4) //Año de Excención
										Else
											SIPRIB->SIP_EMISSE := "0000" //Año de Excención
										EndIf
										If cTipExc == "1" .OR. cTipExc == "2" .OR. cTipExc == "3"
											SIPRIB->SIP_NUMCEE := Trim((cAliasAux)->FH_DECRETO) //Número de Certificado de Excención
										Else
											SIPRIB->SIP_NUMCEE := space(6) //Número de Certificado de Excención
										EndIf
									(cAliasAux)->(dbCloseArea())
									SIPRIB->SIP_NUMCEP := space(12) //Número de Certificado Propio

									If cSitIva=="1"
										If nBasIbr==nVlrIbr
											SIPRIB->SIP_ALIQUO:=PADL(Alltrim(Transform(99.99,"@E 99.99")),Len(SIPRIB->SIP_ALIQUO),"0")//Alicuota
										Else
											SIPRIB->SIP_ALIQUO:=PADL(Alltrim(Transform((nVlrIbr*100)/(nBasIbr),"@E 99.99")),Len(SIPRIB->SIP_ALIQUO),"0")    //Alicuota
										EndIf
									Else
										SIPRIB->SIP_ALIQUO:=Alltrim(Transform(0,"@E 99.99"))//Alicuota
									EndIf
									SIPRIB->SIP_REGINS:=PADL(Alltrim(Transform(0,"@E 999999999.99")),Len(SIPRIB->SIP_REGINS),"0")//Derecho Registro e Inspeccion									
									SIPRIB->F3_SERIE 	:= cSDoc
									SIPRIB->F3_CLIEFOR	:= TRBPER->F3_CLIEFOR
									SIPRIB->F3_LOJA		:= TRBPER->F3_LOJA
									SIPRIB->F3_NFISCAL	:= TRBPER->F3_NFISCAL
									SIPRIB->(MsUnlock())
								Else
									RecLock("SIPRIB",.F.)
									SIPRIB->NUM_VLRCOM+=TRBPER->F3_VALCONT //Monto de Comprobante
									SIPRIB->NUM_IMPIVA+=nVlrIva//Iif(cSitIva=="1",Transform(nVlrIva,"@E 999999999.99"),Transform(0,"@E 999999999.99"))//Importe IVA- percepcao
									SIPRIB->NUM_BSCALC+=nBasIbr//Base imponible para el calculo
									SIPRIB->NUM_IMDET +=nVlrIbr//Impuesto Determinado
									SIPRIB->NUM_VLRRET+=nVlrIbr//Monto Retenido

									SIPRIB->SIP_VLRCOM:= PADL(Alltrim(Transform(SIPRIB->NUM_VLRCOM,"@E 999999999.99")),Len(SIPRIB->SIP_VLRCOM),"0")//Monto de Comprobante
									SIPRIB->SIP_IMPIVA:= PADL(Alltrim(Transform(SIPRIB->NUM_IMPIVA,"@E 999999999.99")),Len(SIPRIB->SIP_IMPIVA),"0")//Iif(cSitIva=="1",Transform(nVlrIva,"@E 999999999.99"),Transform(0,"@E 999999999.99"))//Importe IVA- percepcao
									SIPRIB->SIP_BSCALC:= PADL(Alltrim(Transform(SIPRIB->NUM_BSCALC,"@E 999999999.99")),Len(SIPRIB->SIP_BSCALC),"0")//Base imponible para el calculo
									SIPRIB->SIP_IMDET := PADL(Alltrim(Transform(SIPRIB->NUM_IMDET,"@E 999999999.99")),Len(SIPRIB->SIP_IMDET),"0")//Impuesto Determinado
									SIPRIB->SIP_VLRRET:= PADL(Alltrim(Transform(SIPRIB->NUM_VLRRET,"@E 999999999.99")),Len(SIPRIB->SIP_VLRRET),"0")//Monto Retenido

									If cSitIva=="1"
										If SIPRIB->NUM_BSCALC==SIPRIB->NUM_IMDET
											SIPRIB->SIP_ALIQUO:=Alltrim(Transform(99.99,"@E 99.99"))//Alicuota
										Else
											SIPRIB->SIP_ALIQUO:=Transform((SIPRIB->NUM_IMDET*100)/SIPRIB->NUM_BSCALC,"@E 99.99")//Alicuota
										EndIf
									Else
										SIPRIB->SIP_ALIQUO:=Alltrim(Transform(0,"@E 99.99"))//Alicuota
									EndIf
									SIPRIB->(MsUnlock())
								EndIf
							EndIf
						
						ElseIf UPPER(cArquivo)$"SIRCAR" //Percepcao
							cTipCom := ""
							nSinal:=1
							If UPPER(ACODTAB[1][4]) $ "CO"
								If !TRBPER->F3_ESTADO $ "CO"
									nBasIbr	:= 0
									nConIB		:= 0
									For nlI := 1 To Len(aNrLvrIB)
										DbSelectArea("SF1")
										SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
										If  DbSeek(xFilial("SF1")+AvKey(TRBPER->F3_NFISCAL,"F1_DOC")+AvKey(TRBPER->F3_SERIE,"F1_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"F1_FORNECE")+AvKey(TRBPER->F3_LOJA,"F1_LOJA"))
											DbSelectArea("SD1")
											SD1->(DbSetOrder(1))//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD
											If  DbSeek(xFilial("SD1")+AvKey(TRBPER->F3_NFISCAL,"D1_DOC")+AvKey(TRBPER->F3_SERIE,"D1_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"D1_FORNECE")+AvKey(TRBPER->F3_LOJA,"D1_LOJA"))
												Do While SD1->(!Eof()) .AND. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == xFilial("SD1")+AvKey(TRBPER->F3_NFISCAL,"D1_DOC")+AvKey(TRBPER->F3_SERIE,"D1_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"D1_FORNECE")+AvKey(TRBPER->F3_LOJA,"D1_LOJA")
													nBasIbr += &("SD1->D1_BASIMP"+aNrLvrIB[nlI][2])
													SD1->(DbSkip())
												EndDo //SD1
											Endif //SD1
										Else
											DbSelectArea("SF2")
											If DbSeek(xFilial("SF2")+AvKey(TRBPER->F3_NFISCAL,"F2_DOC")+AvKey(TRBPER->F3_SERIE,"F2_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"F2_CLIENTE")+AvKey(TRBPER->F3_LOJA,"F2_LOJA"))

													SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_FORNECE+F2_LOJA+F2_TIPO
													If  DbSeek(xFilial("SF2")+AvKey(TRBPER->F3_NFISCAL,"F2_DOC")+AvKey(TRBPER->F3_SERIE,"F2_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"F3_CLIEFOR")+AvKey(TRBPER->F3_LOJA,"F2_LOJA"))
														DbSelectArea("SD2")
														SD2->(DbSetOrder(3))//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD
														If  DbSeek(xFilial("SD2")+AvKey(TRBPER->F3_NFISCAL,"D2_DOC")+AvKey(TRBPER->F3_SERIE,"D2_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"F3_CLIEFOR")+AvKey(TRBPER->F3_LOJA,"D2_LOJA"))
															Do While SD2->(!Eof()) .AND. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == xFilial("SD2")+AvKey(TRBPER->F3_NFISCAL,"D2_DOC")+AvKey(TRBPER->F3_SERIE,"D2_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"F3_CLIEFOR")+AvKey(TRBPER->F3_LOJA,"D2_LOJA")
																If AvKey(TRBPER->F3_TES,"D2_TES") == SD2->D2_TES
																	nBasIbr += &("SD2->D2_BASIMP"+aNrLvrIB[nlI][2])
																EndIf	
																SD2->(DbSkip())
															EndDo //SD2
														Endif //SD2
													Endif //sF2
												EndIf
										Endif //sf1
									Next nlI								
								Endif
								cTpRecaud := "1"
								If Alltrim(TRBPER->F3_ESPECIE)$ "NCC|NDE"
									nSinal:=-1
									cTpRecaud:="2"
								Endif	
							Else
								cTpRecaud := "4"									
							EndIf
							If Alltrim(TRBPER->F3_ESPECIE)=="NF"
								cTipCom:="001"
							ElseIf Alltrim(TRBPER->F3_ESPECIE)$"NDC|NDP"
								If Alltrim(TRBPER->F3_ESTADO)=='EX'
									cTipCom:="006" //Nota de debito exterior
								Else
									cTipCom:="002" //Nota de debito
								EndIf
							ElseIf Alltrim(TRBPER->F3_ESPECIE)$"NCC|NCP"
							    cNUCONS:= space(14)
								DbSelectArea("SEL")
								SEL->(DbSetOrder(2))//EL_FILIAL+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO+EL_CLIORIG+EL_LOJORIG
								If DbSeek(xFilial("SEL")+ TRBPER->F3_SERIE + TRBPER->F3_NFISCAL  + SEL->EL_PARCELA + SUBSTR(TRBPER->F3_ESPECIE,1,3) )
									cSerie:= SEL->EL_SERIE
									cNRec:= SEL->EL_RECIBO
									DbSelectArea("SEL")
									SEL->(DbSetOrder(8))
									SEL->(DbGotop())									
									If DbSeek(xFilial("SEL")+ cSerie+ cNRec)  
										lAchou:=.f.
										While !EOF() .AND.  cNRec == SEL->EL_RECIBO .AND. cSerie == SEL->EL_SERIE .AND.  !lAchou
											If Alltrim(SEL->EL_TIPO) $ "NF|NDC|NDE"
												If Alltrim(SEL->EL_TIPO) $ "NF
													cNUCONS:= "1"  
												Else 
													cNUCONS:= "2"
												Endif
												cNUCONS:=cNUCONS + Subs(SEL->EL_PREFIXO,1,1) + SEL->EL_NUMERO 
												lAchou:=.T.
											EndIf
										SEL->(DbSkip())	
										EndDo
									Endif				
								Endif
								If Alltrim(TRBPER->F3_ESTADO)=='EX'
									cTipCom:="106" //Nota de credito exterior
								Else
									cTipCom:="102" //Nota de credito
								EndIf
							ElseIf Alltrim(TRBPER->F3_ESPECIE)$"NCE|NCI"
								cTipCom:="120" //Outros creditos
							ElseIf Alltrim(TRBPER->F3_ESPECIE)$"NDE|NDI"
								cTipCom:="020" //Outros debitos
							EndIf
							dbSelectArea("SIRPER")
							SIRPER->(dbSetOrder(1))//PER_TIPCOM+PER_LETCOM+PER_NUMCOM+PER_CUIT+PER_TIPPER+PER_JURISD+PER_ALIPER
							SIRPER->(dbGoTop())
							For nInd:= 1 To Len(aProvSircar)
								
								If !SIRPER->(MsSeek(cTipCom+SubStr(TRBPER->F3_SERIE,1,1)+TRBPER->F3_NFISCAL+AllTrim(TRBPER->CUIT)+AllTrim(cCodTab2)+"9"+AllTrim(Posicione("CCO",1,xFilial("CCO")+aCodTab[1][4],"CCO_CODJUR"))+Iif(TRBPER->F3_ESTADO == "SF" .and. UPPER(ACodTab[1][4]) == "SF",PadL(AllTrim(Transform(&("TRBPER->F3_ALQIMP"+aNrLvrIB[1][2]), "@R 999.99")), 6, "0"),""))) .or. ( Len(aProvSircar) > 1)	
									If RecLock("SIRPER",.T.)
										SIRPER->PER_NUMREG := StrZero(Recno(),5)
										SIRPER->PER_TIPCOM := cTipCom
										SIRPER->PER_LETCOM := SUBSTR(TRBPER->F3_SERIE,1,1)
										SIRPER->PER_NUMCOM := RIGHT(TRBPER->F3_NFISCAL, 12) 
										SIRPER->PER_CUIT   := TRBPER->CUIT
										SIRPER->PER_DATPER := Substr(TRBPER->F3_EMISSAO,7,2)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4)//Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										SIRPER->PER_TIPPER := cCodTab2
										SIRPER->PER_JURISD := "9"+Posicione("CCO",1,xFilial("CCO")+aCodTab[1][4],"CCO_CODJUR")
										If  (UPPER(ACODTAB[1][4]) == "CO" .And. TRBPER->F3_ESTADO == "CO") //UPPER(ACODTAB[1][4]) $ "CO|MI" .And. TRBPER->F3_ESTADO $ "CO|MI"
											SIRPER->PER_AUX1 := aProvSircar[nInd][3] //Monto de IIBB
											SIRPER->PER_AUX2 := aProvSircar[nInd][2] //Base imponible
											If cTipCom $ "102|106|120" //DMIMIX-114
												nSinal := -1
											EndIf
											If nSinal <0                  
												SIRPER->PER_VLRPER := "-"+PadL(AllTrim(Transform((SIRPER->PER_AUX1), "@R 999999999.99")), 11, "0") //Monto de Comprobante
												SIRPER->PER_VLRTOT :=  "-"+PadL(AllTrim(Transform((SIRPER->PER_AUX2), "@R 999999999.99")), 11, "0") //Monto de Comprobante
											Else
												SIRPER->PER_VLRPER := PadL(AllTrim(Transform((SIRPER->PER_AUX1), "@R 999999999.99")), 12, "0") //Monto de Comprobante
												SIRPER->PER_VLRTOT := PadL(AllTrim(Transform((SIRPER->PER_AUX2), "@R 999999999.99")), 12, "0") //Monto de Comprobante
											EndIf
											SIRPER->PER_ALIPER := PadL(AllTrim(IIF(TRBPER->F3_ESTADO == "CO", Transform(Round((SIRPER->PER_AUX1 * 100) / SIRPER->PER_AUX2, 2), "@R 999.99"), Transform(0, "@R 999.99"))), 6, "0") //Alicuota
										Else
											SIRPER->PER_AUX1 := aProvSircar[nInd][3] //Monto de IIBB
											SIRPER->PER_AUX2 := aProvSircar[nInd][2] //Base imponible
											If cTipCom $ "102|106|120" //DMIMIX-114
												nSinal := -1
											EndIf
											SIRPER->PER_ALIPER := PadL(AllTrim(Transform(Round((SIRPER->PER_AUX1 * 100) / SIRPER->PER_AUX2, 2), "@R 999.99")), 6, "0") //Alicuota
											If nSinal <0                  
												SIRPER->PER_VLRPER := "-"+PadL(AllTrim(Transform((SIRPER->PER_AUX1), "@R 999999999.99")), 11, "0") //Monto de Comprobante
												SIRPER->PER_VLRTOT := "-"+PadL(AllTrim(Transform((SIRPER->PER_AUX2), "@R 999999999.99")), 11, "0") //Monto de Comprobante
											Else 
												SIRPER->PER_VLRPER := PadL(AllTrim(Transform((SIRPER->PER_AUX1), "@R 999999999.99")), 12, "0") //Monto de Comprobante
												SIRPER->PER_VLRTOT := PadL(AllTrim(Transform((SIRPER->PER_AUX2), "@R 999999999.99")), 12, "0") //Monto de Comprobante      
											EndIf
										EndIf
										If Val(SIRPER->PER_ALIPER) == 0 .And. UPPER(ACODTAB[1][4]) $ "CO" 
											If (Alltrim(TRBPER->F3_ESPECIE)$ "NCC|NDE")
												cTpRecaud:="2"
											Else
												cTpRecaud:="4"
											Endif
										EndIf
										If UPPER(ACODTAB[1][4]) $ "CO"
											SIRPER->PER_TIPOPE := cTpRecaud
										EndIf
										If 	cTpRecaud == "2"
											SIRPER->PER_NUCONS := cNUCONS
										EndIf
										SIRPER->(MsUnlock())
										nImp++
									EndIf
								Else
									If RecLock("SIRPER",.F.)

										SIRPER->PER_AUX1 += (aProvSircar[nInd][3]*nSinal) //Monto de IIBB
										SIRPER->PER_AUX2 += (aProvSircar[nInd][2]*nSinal) //Base imponible
										If cTipCom $ "102|106|120" //DMIMIX-114
											nSinal := -1
										EndIf	
										If nSinal<0
											SIRPER->PER_VLRPER :="-"+ PadL(AllTrim(Transform((Abs(SIRPER->PER_AUX1)),"@R 999999999.99")), 11, "0")//Monto de IIBB
											SIRPER->PER_VLRTOT :="-"+PadL(AllTrim(Transform((Abs(SIRPER->PER_AUX2)),"@R 999999999.99")), 11, "0")//Base imponible
										Else
											SIRPER->PER_VLRPER := PadL(AllTrim(Transform((SIRPER->PER_AUX1),"@R 999999999.99")), 12, "0")//Monto de IIBB
											SIRPER->PER_VLRTOT := PadL(AllTrim(Transform((SIRPER->PER_AUX2),"@R 999999999.99")), 12, "0")//Base imponible
										EndIf
										SIRPER->PER_ALIPER := PadL(AllTrim(Transform(Round((SIRPER->PER_AUX1*100)/SIRPER->PER_AUX2,2),"@R 999.99")), 6, "0")//Alicuota
										SIRPER->(MsUnlock())

									EndIf
									
								EndIf								
							Next
							
						ElseIf UPPER(cArquivo)=="SILARPIB"
							cCodTab1 := ""
							cTpRecaud := "1"   
							cQueryAuxi:= ""  
							cAliasAux := ""
	        				nRegs     := 0							
						
							If Empty(TRBPER->CUIT)
								Aadd(aLogreg,"CUIT/CUIL no informado. Codigo:"+SPACE(1)+TRBPER->F3_CLIEFOR+"-"+TRBPER->F3_LOJA)
							Else
								cTipo:="3"
								DbSelectArea("SA1")
								SA1->(DbSetOrder(1))
								SA1->(DbGoTop())
								If SA1->(DbSeek(xFilial("SA1")+AvKey(TRBPER->F3_CLIEFOR,"A1_COD")+AvKey(TRBPER->F3_LOJA,"A1_LOJA")))
									CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
									CCP->(DbGoTop())
									If CCP->(DbSeek(xFilial("CCP")+Avkey(aCodTab[1][1],"CCP_COD")+AvKey(SA1->A1_EST,"CCP_VORIGE")))
										cCodTab1:=Substr(Alltrim(CCP->CCP_VDESTI),1,2)
									EndIf
									If Ascan(aCNPJ,{|x| Alltrim(x[1])==Alltrim(TRBPER->CUIT)})==0
										Aadd(aCNPJ,{Alltrim(TRBPER->CUIT),cTipo,SA1->A1_NOME,SA1->A1_NIGB,SA1->A1_END,SA1->A1_BAIRRO,SA1->A1_MUN,SA1->A1_CEP,cCodTab1})
									EndIf
									If  Len(aNrLvrIB) > 0 
										cQueryAuxi := "SELECT * FROM " + RetSqlName("SFH") + " SFH Where FH_CLIENTE = '" + TRBPER->F3_CLIEFOR + "' AND FH_LOJA = '" + TRBPER->F3_LOJA + "' AND FH_TIPO = 'V' AND SFH.D_E_L_E_T_=''  " 
										cQueryAuxi += " AND ("
										For nlI:=1 To Len(aNrLvrIB)
											If nlI <> 1
												cQueryAuxi += " OR "
											EndIf
											cQueryAuxi += " FH_IMPOSTO = '" + aNrLvrIB[nlI][1] + "' "
										Next nlI
										cQueryAuxi += ")"
										cQueryAuxi += " AND  (FH_INIVIGE = '' OR FH_INIVIGE >= '" + cDtIni + "') AND  (FH_FIMVIGE = '' OR FH_FIMVIGE <= '" + cDtFim + "')  AND FH_ZONFIS <> 'CO' "  
										cAliasAux  := CriaTrab(nil, .f.)
										cQueryAuxi := ChangeQuery(cQueryAuxi)
										dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryAuxi),cAliasAux,.F.,.T.) 
										COUNT TO nRegs
										(cAliasAux)->(dbCloseArea())   
									EndIf								
									If  SA1->A1_EST <> "CO" .OR. nRegs > 0
										cTpRecaud := "4"
									EndIf									
								EndIf
							EndIf
							If nVlrIbr>0
								nImp++
								DbSelectArea("S05")
								If !DbSeek("02"+TRBPER->F3_EMISSAO + Substr(TRBPER->F3_SERIE,1,1)+TRBPER->F3_NFISCAL+Alltrim(TRBPER->CUIT))
									If RecLock("S05",.T.)
										S05->S05_IDENT	 :="04"
										S05->S05_TIPPER	 := cTpRecaud
										S05->S05_CODOPE  := StrZero(nCodOpeNP,8)
										S05->S05_CONPER  := cCodTab4
										S05->S05_FECPER  :=	Substr(TRBPER->F3_ENTRADA,7,2)+"/"+Substr(TRBPER->F3_ENTRADA,5,2)+"/"+Substr(TRBPER->F3_ENTRADA,1,4)//Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										S05->S05_FECEMI  :=	Substr(TRBPER->F3_EMISSAO,7,2)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4)//Fecha de Retencion-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										S05->S05_NUMCON  :=	Substr(TRBPER->F3_SERIE,1,1)+TRBPER->F3_NFISCAL
										S05->S05_CUIT    :=	Transform(TRBPER->CUIT,"@R XX-XXXXXXXX-X")
										S05->S05_AUX01   := nBasIbr //Base da percepção
										S05->S05_AUX02   :=	nVlrIbr //Valor da percepção
										S05->S05_ALIQ	 :=	Transform(Round(S05->S05_AUX02/S05->S05_AUX01*100,2),"@E 999.9999")//Alicuota
										S05->S05_BASPER  :=	Transform(S05->S05_AUX01,"@E 9999999999.99")//Base da percepção
										S05->S05_IMPPER  :=	Transform(S05->S05_AUX02,"@E 99999999.99")//Valor da percepção
										S05->S05_EMIDAT  :=	TRBPER->F3_EMISSAO
										S05->(MsUnlock())
									EndIf
									If RecLock("S05",.T.)
										S05->S03_IDENT   :="02"
										S05->S03_TIPRET  :="1"
										S05->S05_CODOPE  := StrZero(nCodOpeNP,8)
										S05->S03_LETFAT  :=Substr(TRBPER->F3_SERIE,1,1)
										S05->S03_NUMCOM  :=TRBPER->F3_NFISCAL
										S05->S03_FECCOM  :=Substr(TRBPER->F3_EMISSAO,7,2)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4)//Fecha de Retencion-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										S05->S03_RETENC  :="1"
										S05->S03_ANULAC  :="0"
										S05->(MsUnlock())
									EndIf
									nCodOpeNP++
								Else
									RecLock("S05",.F.)
									S05->S05_AUX01    += nBasIbr //Base da percepção
									S05->S05_AUX02   	+=	Abs(nVlrIbr)//Valor da percepção
									S05->S05_ALIQ	   :=	Transform(Round(S05->S05_AUX02/S05->S05_AUX01*100,2),"@E 999.9999")//Alicuota
									S05->S05_BASPER   :=	Transform(S05->S05_AUX01,"@E 9999999999.99")//Base da percepção
									S05->S05_IMPPER   :=	Transform(S05->S05_AUX02,"@E 99999999.99")//Valor da percepção
									S05->(MsUnlock())
								EndIf
							EndIf
							If (Len(Trim(TRBPER->F3_DTCANC)) > 0 .And. AllTrim(SF3->F3_ESPECIE) $ "NF|NCI|NDC");
								.Or. ( nVlrIbr < 0 .And. AllTrim(SF3->F3_ESPECIE) $ "NCC|NDI" .And. Empty(TRBPER->F3_DTCANC))
								nImp++
								nAnulac++
								DbSelectArea("S06")
								If !DbSeek("02"+TRBPER->F3_EMISSAO+Substr(TRBPER->F3_SERIE,1,1)+TRBPER->F3_NFISCAL+Alltrim(TRBPER->CUIT))
									If RecLock("S06",.T.)
										S06->S06_CODOPE := StrZero(nCodOpeAP,8)
										S06->S06_IDENT  :="05"
										S06->S06_NUMCON :=Substr(TRBPER->F3_SERIE,1,1)+TRBPER->F3_NFISCAL						
										If AllTrim(SF3->F3_ESPECIE) $ "NF|NCI|NDC"
											S06->S06_FECANU :=Substr(TRBPER->F3_DTCANC,7,2)+"/"+Substr(TRBPER->F3_DTCANC,5,2)+"/"+Substr(TRBPER->F3_DTCANC,1,4)//Fecha de Retencion-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										Else
											S06->S06_FECANU :=Substr(TRBPER->F3_EMISSAO,7,2)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4)//Fecha de Retencion-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										EndIf										
										S06->S06_CONANU :="0"
										S06->S06_AUX01  :=	Abs(nVlrIbr)//Valor da percepção
										S06->S06_IMPANU :=	Transform(Abs(S06->S06_AUX01),"@E 99999999.99")//Valor da percepção
										S06->S06_CUIT   :=	Transform(TRBPER->CUIT,"@R XX-XXXXXXXX-X")
										S06->S06_ANUDAT :=	TRBPER->F3_EMISSAO
										S06->(MsUnlock())
									EndIf
									If RecLock("S06",.T.)
										S06->S06_CODOPE := StrZero(nCodOpeAP,8)
										S06->S03_IDENT  :="02"
										S06->S03_TIPRET :="1"
										S06->S03_LETFAT :=Substr(TRBPER->F3_SERIE,1,1)
										S06->S03_NUMCOM :=TRBPER->F3_NFISCAL
										If AllTrim(SF3->F3_ESPECIE) $ "NF|NCI|NDC"
											S06->S03_FECCOM :=Substr(TRBPER->F3_DTCANC,7,2)+"/"+Substr(TRBPER->F3_DTCANC,5,2)+"/"+Substr(TRBPER->F3_DTCANC,1,4)//Fecha de Retencion-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										Else
											S06->S03_FECCOM :=Substr(TRBPER->F3_EMISSAO,7,2)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4)//Fecha de Retencion-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										EndIf										
										S06->S03_PERORI := Transform(Abs(nBasIbr),"@E 99999999.99")
										S06->S06_IMPANU := Transform(Abs(nVlrIbr),"@E 99999999.99")
										S06->(MsUnlock())
									EndIf
								Else
									RecLock("S06",.F.)
									S06->S06_AUX01   	+=	Abs(nVlrIbr)//Valor da percepção
									S06->S06_IMPANU   :=	Transform(Abs(S06->S06_AUX01),"@E 99999999.99")//Valor da percepção
									S06->(MsUnlock())
								EndIf
								nCodOpeAP++
							EndIf
					
						ElseIf UPPER(cArquivo)$"RG2849" //RETENCIONES IVA|GANANCIAS - MATERIALES A RECICLAR
							For nlI:=1 to len(aNrLvrGI)
								DbSelectArea("SA2")
								SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
								If  DbSeek(xFilial("SA2")+AvKey(TRBPER->F3_CLIEFOR,"F1_FORNECE")+AvKey(TRBPER->F3_LOJA,"F1_LOJA"))
									lRG2849 := .T.
								Else
									lRG2849 := .F.
								EndIf

								IF  &("TRBPER->F3_VALIMP" + aNrLvrGI[nlI][2]) > 0 //Significa que se va a generar un registro de IVA o GANACIAS
									nValRG2849 := 0
									If  Alltrim(TRBPER->F3_ESPECIE) $ "NF|NDP|NCI"   //SF1/SD1 - SA2
										If lRG2849 == .T.
											DbSelectArea("SF1")
											SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
											If  DbSeek(xFilial("SF1")+AvKey(TRBPER->F3_NFISCAL,"F1_DOC")+AvKey(TRBPER->F3_SERIE,"F1_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"F1_FORNECE")+AvKey(TRBPER->F3_LOJA,"F1_LOJA"))
												DbSelectArea("SD1")
												SD1->(DbSetOrder(1))//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD
												If  DbSeek(xFilial("SD1")+AvKey(TRBPER->F3_NFISCAL,"D1_DOC")+AvKey(TRBPER->F3_SERIE,"D1_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"D1_FORNECE")+AvKey(TRBPER->F3_LOJA,"D1_LOJA"))
													Do While SD1->(!Eof()) .AND. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == xFilial("SD1")+AvKey(TRBPER->F3_NFISCAL,"D1_DOC")+AvKey(TRBPER->F3_SERIE,"D1_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"D1_FORNECE")+AvKey(TRBPER->F3_LOJA,"D1_LOJA")
														DbSelectArea("SFC")
														SFC->(DbSetOrder(2)) //FC_FILIAL+ FC_TES + FC_IMPOSTO
														If !DbSeek(xFilial("SFC")+ SD1->D1_TES + aNrLvrGI[nlI][1])  // Verifico que exista el impuesto en la Test que  el documento
															SD1->(DbSkip())
															loop
														EndIf
														nValRG2849 := POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_RG2849")
														nTpAliq := 0
														If &("SD1->D1_ALQIMP"+aNrLvrGI[nlI][2])== 0 
															nTpAliq := 1
														Elseif &("SD1->D1_ALQIMP"+aNrLvrGI[nlI][2]) > 8 .And. &("SD1->D1_ALQIMP"+aNrLvrGI[nlI][2])<13      
															nTpAliq := 2
														Elseif &("SD1->D1_ALQIMP"+aNrLvrGI[nlI][2]) > 19  .And. &("SD1->D1_ALQIMP"+aNrLvrGI[nlI][2]) < 23   
															nTpAliq := 3   
														Elseif &("SD1->D1_ALQIMP"+aNrLvrGI[nlI][2])> 25 .And.   &("SD1->D1_ALQIMP"+aNrLvrGI[nlI][2])< 29  
															nTpAliq := 4
														EndIf
														
														If  nValRG2849 > 0   //Solo s+i contiene codigo RG2849															
															cSDoc := SerieNFID("SF3", 3, "F3_SERIE")
															If  GravaRG2849(TpDocRET(TRBPER->&cSDoc, TRBPER->F3_ESPECIE),;
															TRBPER->F3_NFISCAL,;
															TRBPER->F3_EMISSAO,;
															Substr(Posicione("SX5", 1, xFilial("SX5")+"OC" + SA2->A2_AFIP,"X5_DESCSPA"),1,2),;
															SA2->A2_CGC,;
															SA2->A2_NOME,;
															&("TRBPER->F3_BASIMP"+aNrLvrGI[nlI][2]),;
															&("TRBPER->F3_VALIMP"+aNrLvrGI[nlI][2]),;
															TRBPER->F3_VALCONT,;
															nValRG2849,;
															SD1->D1_QUANT,;
															Substr(Alltrim(posicione("CCP",1,xfilial("CCP")+aCodTab[1][1]+SD1->D1_UM,"CCP_VDESTI")),1,2),;
															SD1->D1_VUNIT,;
															SD1->D1_TOTAL,;
															nTpAliq,;
															&("SD1->D1_VALIMP"+aNrLvrGI[nlI][2]), SD1->D1_COD )
																nImp++
															EndIf
														EndIf
														SD1->(DbSkip())
													EndDo //SD1
												EndIf //SD1
											EndIf //sf1
										EndIf //SA2
									ElseIf Alltrim(TRBPER->F3_ESPECIE)$"NCP|NDI"    //SF2/SD2 - SA1
										If lRG2849 == .T.
											DbSelectArea("SF2")
											SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_FORNECE+F2_LOJA+F2_TIPO
											If  DbSeek(xFilial("SF2")+AvKey(TRBPER->F3_NFISCAL,"F2_DOC")+AvKey(TRBPER->F3_SERIE,"F2_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"F3_CLIEFOR")+AvKey(TRBPER->F3_LOJA,"F2_LOJA"))
												DbSelectArea("SD2")
												SD2->(DbSetOrder(3))//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD
												If  DbSeek(xFilial("SD2")+AvKey(TRBPER->F3_NFISCAL,"D2_DOC")+AvKey(TRBPER->F3_SERIE,"D2_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"F3_CLIEFOR")+AvKey(TRBPER->F3_LOJA,"D2_LOJA"))
													Do While SD2->(!Eof()) .AND. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == xFilial("SD2")+AvKey(TRBPER->F3_NFISCAL,"D2_DOC")+AvKey(TRBPER->F3_SERIE,"D2_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"F3_CLIEFOR")+AvKey(TRBPER->F3_LOJA,"D2_LOJA")
														DbSelectArea("SFC")
														SFC->(DbSetOrder(2)) //FC_FILIAL+ FC_TES + FC_IMPOSTO
														If !DbSeek(xFilial("SFC")+ SD2->D2_TES + aNrLvrGI[nlI][1])  // Verifico que exista el impuesto en la Test que  el documento
															SD1->(DbSkip())
														EndIf
														nValRG2849 := POSICIONE("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_RG2849")  
														nTpAliq := 0
														If &("SD2->D2_ALQIMP"+aNrLvrGI[nlI][2])== 0 
															nTpAliq := 1
														Elseif &("SD2->D2_ALQIMP"+aNrLvrGI[nlI][2]) >8 .And. &("SD2->D2_ALQIMP"+aNrLvrGI[nlI][2]) < 13    
															nTpAliq := 2
														Elseif &("SD2->D2_ALQIMP"+aNrLvrGI[nlI][2])> 19 .And. &("SD2->D2_ALQIMP"+aNrLvrGI[nlI][2])< 23      
															nTpAliq := 3   
														Elseif &("SD2->D2_ALQIMP"+aNrLvrGI[nlI][2])== 25  .And. &("SD2->D2_ALQIMP"+aNrLvrGI[nlI][2])< 29     
															nTpAliq := 4
														EndIf
														If  nValRG2849>0   //Solo s+i contiene codigo RG2849
															If  GravaRG2849(TpDocRET(TRBPER->F3_SERIE,	TRBPER->F3_ESPECIE),;
															TRBPER->F3_NFISCAL,;
															TRBPER->F3_EMISSAO,;
															Substr(Posicione("SX5", 1, xFilial("SX5")+"OC" + SA2->A2_AFIP,"X5_DESCSPA"),1,2),;
															SA2->A2_CGC,;
															SA2->A2_NOME,;
															&("TRBPER->F3_BASIMP"+aNrLvrGI[nlI][2]),;
															&("TRBPER->F3_VALIMP"+aNrLvrGI[nlI][2]),;
															TRBPER->F3_VALCONT,;
															nValRG2849,;
															SD2->D2_QUANT,;
															Substr(Alltrim(posicione("CCP",1,xfilial("CCP")+aCodTab[1][1]+SD2->D2_UM,"CCP_VDESTI")),1,2),;
															SD2->D2_PRCVEN,;
															SD2->D2_TOTAL,;
															nTpAliq,;
															&("SD2->D2_VALIMP"+aNrLvrGI[nlI][2]), SD2->D2_COD )
																nImp++
															EndIf
														EndIf
														SD2->(DbSkip())
													EndDo //SD2
												EndIf //SD2
											EndIf //sF2
										EndIf //SA2

									EndIf
								EndIf //IVA o GANACIAS
							Next nlI
						ElseIf UPPER(cArquivo)$"SICORE"  //sicore
							//=============================================================================================
							//CCO - TABELA DE CADASTRO ESTADO X INGRESSOS BRUTOS
							//=============================================================================================
							//CCO_TIPO   - I=Resp. Inscrito;N=Resp. Nao Inscrito;X=Isento;E=Exportacao ;F=Cons. Final;
							//             M=Monotributarista;V=Convenio Multilateral;*=Indeterm
							//=============================================================================================
							If SUBSTR(TRBPER->F3_ESPECIE,1,2)=="NF"
								cTipCom:="01"
							ElseIf SUBSTR(TRBPER->F3_ESPECIE,1,2)=="NC"
								cTipCom :="03"

							ElseIf SUBSTR(TRBPER->F3_ESPECIE,1,2)=="ND"
								cTipCom :="04"
							EndIf
											
							cCliFor :=""
							cLojaCF := ""
							
							If !Empty(TRBPER->F3_CLIEFOR)                                                                
								
								DbSelectArea("SA2")
								SA2->(DbSetOrder(1))
								SA2->(DbSeek(xFilial("SA2")+AvKey(TRBPER->F3_CLIEFOR,"A2_COD")+AvKey(TRBPER->F3_LOJA,"A2_LOJA")))
								
								DbSelectArea("SA1")
								SA1->(DbSetOrder(1))  
								SA1->(DbSeek(xFilial("SA1")+AvKey(TRBPER->F3_CLIEFOR,"A1_COD")+AvKey(TRBPER->F3_LOJA,"A1_LOJA")))									     													
								cCodEst := Iif(TRBPER->F3_tipomov = 'C', SubStr(SA2->A2_EST, 1, 11), SubStr(SA1->A1_EST, 1, 11)) 
								cCodTip := Iif(TRBPER->F3_tipomov = 'C', SubStr(SA2->A2_TIPO,1, 11), SubStr(SA1->A1_TIPO,1, 11)) 
								cCliFor := Iif(TRBPER->F3_tipomov = 'C', SubStr(SA2->A2_COD, 1, 11), SubStr(SA1->A1_COD, 1, 11))
								cLojaCF := Iif(TRBPER->F3_tipomov = 'C', SubStr(SA2->A2_LOJA,1, 11), SubStr(SA1->A1_LOJA,1, 11))								            	
								cCUITFor:= Iif(TRBPER->F3_tipomov = 'C', SubStr(SA2->A2_CGC, 1, 11), SubStr(SA1->A1_CGC, 1, 11))								            	
								cRazSoc := Iif(TRBPER->F3_tipomov = 'C', SubStr(SA2->A2_NOME,1, 20), SubStr(SA1->A1_NOME,1, 20))
								cDomic  := Iif(TRBPER->F3_tipomov = 'C', SubStr(SA2->A2_END, 1, 20), SubStr(SA1->A1_END, 1, 20))
								cCiudad := Iif(TRBPER->F3_tipomov = 'C', SubStr(SA2->A2_MUN, 1, 20), SubStr(SA1->A1_MUN, 1, 20)) 								
								cCP     := Iif(TRBPER->F3_tipomov = 'C', SubStr(SA2->A2_CEP, 1, 8),  SubStr(SA1->A1_CEP, 1, 8 ))	
								If  cCodTip == 'I'
									cCodCon := '01'
								Elseif cCodTip == 'N'
									cCodCon := '02'
								Else
									cCodCon := '03'
								EndIf							
							EndIf	
							If Empty(cRazSoc)
								DbSelectArea("SA1")
								SA1->(DbSetOrder(1))
								If SA1->(DbSeek(xFilial("SA1")+AvKey(TRBPER->F3_CLIEFOR,"A1_COD")+AvKey(TRBPER->LOJENT,"A1_LOJA")))									
									cCodEst := SA1->A1_EST
									cCodTip := SA1->A1_TIPO
									cCliFor := SA1->A1_COD
									cLojaCF := SA1->A1_LOJA
									cCUITFor:= SubStr( SA1->A1_CGC, 1, 11 )
									cRazSoc := SubStr( SA1->A1_NOME,1, 20)
									cDomic  := SubStr( SA1->A1_END, 1, 20 )
									cCiudad := SubStr( SA1->A1_MUN, 1, 20 )
									cCP     := SubStr(SA1->A1_CEP,1,8)
									If  cCodTip == 'I'
										cCodCon := '01'
									Elseif cCodTip == 'N'
										cCodCon := '02'
									Else
										cCodCon := '03'
									EndIf
								EndIf
							EndIf
                      	
							If  Empty(cCodTab1) .Or. Empty(cCodTab2)
								If !Empty(TRBPER->F3_CLIEFOR)
									Aadd(aLogreg,STR0019+SPACE(1)+cCliFor+SPACE(1)+STR0020+cLojaCF+":")//"Fornecedor:"#"Loja:"
								Else
									Aadd(aLogreg,STR0038+SPACE(1)+cCliFor+SPACE(1)+STR0020+cLojaCF+":")//"Fornecedor:"#"Loja:"
								EndIf
							EndIf
                      			
							For nlI:=1 to len(aNrLvrPIG)
								If Iif(aNrLvrPIG[nlI][3] == "3",(Len(aCodTab[1]) < 8) .Or. (Len(aCodTab[1]) >= 8 .and. SubStr(aCodTab[1][8],1,1)=="1"),.T.) 
									IF &("TRBPER->F3_VALIMP"+aNrLvrPIG[nlI][2]) > 0 //Significa que se va a generar un registro de IVA o GANACIAS
										nImp++
										//Obtener porcentaje de exclusion
										DbSelectArea("SFH")//TABELA INGRESSOS BRUTOS
										SFH->(DbSetOrder(1))//FH_FILIAL+FH_FORNECE+FH_LOJA+FH_IMPOSTO+FH_ZONFIS
										SFH->(DbGoTop())
										If SFH->(DbSeek(xFilial("SFH")+AvKey(cCliFor,"FH_FORNECE")+AvKey(cLojaCF,"FH_LOJA")))
											Do While SFH->(!Eof()) .And. SFH->FH_FORNECE==cCliFor .And. SFH->FH_LOJA==cLojaCF
												If SFH->FH_IMPOSTO==aNrLvrPIG[nlI][1] //.And. SFH->FH_ZONFIS==cCodTab2
													nPorSFH := SFH->FH_PERCENT
												EndIf
												SFH->(DbSkip())
											End
										EndIf
										SICORE->(dbSetOrder(1)) //SIC_TIPCOM+SIC_NUMCOM+SIC_EMISS
										SICORE->(dbGoTop())
										If SICORE->(!DbSeek(cTipCom+StrZero(Val(TRBPER->F3_NFISCAL),16)+Substr(TRBPER->F3_EMISSAO,7,2)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4))) 
											RecLock("SICORE",.T.)
											SICORE->SIC_TIPCOM:= cTipCom                                             //Codigo del comprobante
											SICORE->SIC_EMISS :=Substr(TRBPER->F3_EMISSAO,7,2)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4) //Fecha de emision del comprobante //Fecha de Retencion-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
											SICORE->SIC_NUMCOM:=StrZero(Val(TRBPER->F3_NFISCAL),16)                 //Numero del comprobante
											SICORE->SIC_VLRNET:=StrTran(StrZero(TRBPER->F3_VALCONT,16,2), ".", "," )//Importe del comprante (ceros)
											SICORE->SIC_CODIMP:=Iif(aNrLvrPIG[nlI][3]== "3", "0767", "0217" )          //Codigo de impuesto
											SICORE->SIC_CODREG:=Iif(aNrLvrPIG[nlI][3]== "3", cCodTab3, cCodTab4 )    //Codigo de regimen
											SICORE->SIC_CODOPE:="2"                                                   //Codigo de operacion
											SICORE->SIC_VLRBAS:=Iif(cTipCom=="03",StrTran(StrZero(&("TRBPER->F3_VALIMP"+aNrLvrPIG[nlI][2]),14,2), ".", "," ),StrTran(StrZero(&("TRBPER->F3_BASIMP"+aNrLvrPIG[nlI][2]),14,2), ".", "," ))   //Base de Calculo
											SICORE->SIC_DATRET:=Substr(TRBPER->F3_EMISSAO,7,2)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4)   //Fecha de emisión de la retencion (DD/MM/YYYY) //Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
											cCodReg:=Iif(aNrLvrPIG[nlI][3]== "3", cCodTab3, cCodTab4 )                //Codigo de regimen
											SICORE->SIC_CODREG:=cCodReg
											nbusca := aScan(aCond,{|x| x[1] == Alltrim(cCodReg)})
											If nbusca > 0
												cCodCon :=aCond[nbusca][2]
											EndIf
											SICORE->SIC_CODCON:=cCodCon                                               //Codigo de condicion
											SICORE->SIC_RETSUS:="0"                                                   //Retencion practicada a sujetos suspendidos segun:
											SICORE->SIC_IMPRET:=Iif(cTipCom=="03",StrTran(StrZero(0,14,2), ".", "," ),StrTran(StrZero(&("TRBPER->F3_VALIMP"+aNrLvrPIG[nlI][2]),14,2), ".", "," ))  //Importe de la retención
											SICORE->SIC_PORCEX:=StrTran(StrZero(nPorSFH), ".", "," ) //Porcentaje de exclusion ("000,00")
											SICORE->SIC_DATBOL:="01/12/1998"                                          //Fecha de emisión del boletín
											SICORE->SIC_TIPDOC:="80"                                                 //Tipo de documentos del retenido
											SICORE->SIC_NUMCUI:=PadR(Alltrim(cCuitFor), 20)                          //Numero de documento del retenido
											SICORE->SIC_NUMCOR:=StrZero(Val(POSICIONE("SD1",1,xFilial("SD1")+AvKey(TRBPER->F3_NFISCAL,"D1_DOC")+AvKey(TRBPER->F3_SERIE,"D1_SERIE")+AvKey(cCliFor,"D1_FORNECE")+AvKey(cLojaCF,"D1_LOJA"),"D1_NFORI")),14)                           //Numero de certificado original  (pendiente)
											SICORE->SIC_RAZSOC:=cRazSoc
											SICORE->SIC_ENDER :=cDomic
											SICORE->SIC_CIDADE:=cCiudad
											SICORE->SIC_PROVIN:=cCodTab2
											SICORE->SIC_CEP   :=cCp
											SICORE->(MsUnlock())
										Else
											nValorRet := Val(StrTran(StrTran(SICORE->SIC_IMPRET,".",""),",","."))
											nValorRet += &("TRBPER->F3_VALIMP"+aNrLvrPIG[nlI][2])
											RecLock("SICORE",.F.)									   
											SICORE->SIC_IMPRET := Iif(cTipCom=="03",StrTran(StrZero(0,14,2), ".", "," ),StrTran(StrZero(nValorRet,14,2), ".", ",")) //Importe de la retención
											SICORE->SIC_VLRBAS := StrTran(StrZero(val(StrTran(StrZero(&("TRBPER->F3_VALIMP"+aNrLvrPIG[nlI][2]),14,2), ".", "," ))+ val(SICORE->SIC_VLRBAS),14,2), ".", "," )    //Base de Calculo							
											SICORE->SIC_VLRNET := StrTran(StrZero(val(StrTran(StrZero(TRBPER->F3_VALCONT,16,2), ".", "," ))+ val(SIC_VLRNET),16,2), ".", "," ) //Importe del comprante (ceros)
											SICORE->(MsUnlock())
										EndIf
										dbSelectArea("SUJRET")
										SUJRET->(dbSetOrder(1))
										SUJRET->(dbGoTop())   
										If SUJRET->(!DbSeek(Iif(!Empty(TRBPER->F3_CLIEFOR),"F","C")+SubStr(cCliFor,1,6)+SubStr(cLojaCF,1,2)))									
											If !empty(cLojaCF)
												If RecLock("SUJRET",.T.)
													SUJRET->SJR_TIPO   := Iif(!Empty(TRBPER->F3_CLIEFOR),"F","C")
													SUJRET->SJR_CLIENT := cCliFor
													SUJRET->SJR_LOJA   := cLojaCF
													SUJRET->SJR_TIPDOC := "80"                   
													SUJRET->SJR_NUMCUI := PadR(Alltrim(cCuitFor),20)
													SUJRET->SJR_RAZSOC := cRazSoc
													SUJRET->SJR_ENDER  := cDomic
													SUJRET->SJR_CIDADE := cCiudad
													SUJRET->SJR_PROVIN := cCodTab2
													SUJRET->SJR_CEP    := cCp
													SUJRET->(MsUnlock())            
												EndIf
											EndIf
										EndIf
									EndIf
								EndIf
							Next nlI							
						ElseIf UPPER(cArquivo)$"SIAPE"  //SIAPE
							If SUBSTR(TRBPER->F3_ESPECIE,1,2)=="NF"
								cTipCom:="FA"
							ElseIf SUBSTR(TRBPER->F3_ESPECIE,1,3)$"NCC|NDI"
								cTipCom :="NC"        
							ElseIf SUBSTR(TRBPER->F3_ESPECIE,1,3)$"NDC|NCI"
								cTipCom :="ND"
							EndIf 	

							cCuitFor	:=""
							cDomc	:=""
							cMun	:=""
							cCep	:=""
											
							If !Empty(TRBPER->F3_CLIEFOR)
								DbSelectArea("SA1") // Clientes
								SA1->(DbSetOrder(1))
								If SA1->(DbSeek(xFilial("SA1")+AvKey(TRBPER->F3_CLIEFOR,"A1_COD")+AvKey(TRBPER->LOJENT,"A1_LOJA")))
									cCuitFor:= PadR(SubStr(SA1->A1_CGC,1,11),11)
									cNigb	:=PadR(SubStr(SA1->A1_INSCR,1,12),12) //N. de incripcion provincial
									cNome	:=PadR(SubStr(SA1->A1_NOME,1,40),40)
									cDomc	:=PadR(SubStr(SA1->A1_END,1,40),40)
									cMun	:=PadR(SubStr(SA1->A1_MUN,1,20),20)
									cCep	:=PadR(SubStr(SA1->A1_CEP,1,10),10)
									cCateg :=Iif(SA1->A1_TIPO$"N|S","0","1")
								Else 
									DbSelectArea("SA2") // Proveedores
									SA2->(DbSetOrder(1))
									If SA2->(DbSeek(xFilial("SA2")+AvKey(TRBPER->F3_CLIEFOR,"A2_COD")+AvKey(TRBPER->F3_LOJA,"A2_LOJA")))
										cCuitFor:= PadR(SubStr(SA2->A2_CGC,1,11 ),11)
										cNigb	:=PadR(SubStr(SA2->A2_NIGB,1,12),12) //N.Ing.Brutos
										cNome	:=PadR(SubStr(SA2->A2_NOME,1,40),40)
										cDomc	:=PadR(SubStr(SA2->A2_END,1,40),40)
										cMun	:=PadR(SubStr(SA2->A2_MUN,1,20),20)
										cCep	:=PadR(SubStr(SA2->A2_CEP,1,10),10)
										cCateg :=Iif(SA2->A2_TIPO$"N|S","0","1")
									EndIf
								EndIf      
							EndIf
                      	
							If  Empty(cCodTab1) .Or. Empty(cCodTab2)
								If !Empty(TRBPER->F3_CLIEFOR)
									Aadd(aLogreg,STR0019+SPACE(1)+cCliFor+SPACE(1)+STR0020+cLojaCF+":")//"Fornecedor:"#"Loja:"
								Else
									Aadd(aLogreg,STR0038+SPACE(1)+cCliFor+SPACE(1)+STR0020+cLojaCF+":")//"Fornecedor:"#"Loja:"							
								EndIf
							EndIf         
                      			
							For nlI:=1 to len(aNrLvrIB)    
								IF &("TRBPER->F3_VALIMP"+aNrLvrIB[nlI][2]) > 0 //Significa que se va a generar un registro 
									nImp++

									DbSelectArea("CCO")//TABLA DE ESTADO X INGRESSOS BRUTOS
									CCO->(DbSetOrder(1))//CCO_FILIAL+CCO_CODPRO
									CCO->(DbGoTop())
									If DbSeek(xFilial("CCO")+Avkey("JU","CCO_CODPRO"))//JU-JUJUY
										cNroAge := CCO->CCO_NROAGE
									EndIf 
									SIAPE->(dbSetOrder(1)) //PER_TIPDOC+PER_NUMCOM+PER_EMISS
									SIAPE->(dbGoTop())
									If SIAPE->(!DbSeek(cTipCom+" "+StrZero(Val(TRBPER->F3_NFISCAL),15)+","+Substr(TRBPER->F3_EMISSAO,7,2)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,3,2) +",")) 
										RecLock("SIAPE",.T.)
										SIAPE->PER_CUIT		:= PadR(Alltrim(SM0->M0_CGC), 11) +","
										SIAPE->PER_AGE		:= Substr(cNroAge,1,10) +","
										SIAPE->PER_SEMANA		:= Substr(aCodTab[1,6],1,1) +","
										SIAPE->PER_PERIOD		:= SUBSTR(cDtFim,5,2) + SUBSTR(cDtFim,1,4) +","
										SIAPE->PER_EMISS		:= Substr(TRBPER->F3_EMISSAO,7,2)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,3,2) +","
										SIAPE->PER_CUITC		:= cCuitFor +","
										SIAPE->PER_NROAGE		:= cNigb +","
										SIAPE->PER_NOM		:= cNome +","
										SIAPE->PER_DIR		:= cDomc +","
										SIAPE->PER_LOC		:= cMun +","
										SIAPE->PER_CP			:= cCep +","
										SIAPE->PER_CONSTA		:= PadR("", 6) +","
										SIAPE->PER_ANIO		:= PadR("", 4) +","
										SIAPE->PER_NUMCOM		:= StrZero(Val(TRBPER->F3_NFISCAL),15) +","
										SIAPE->PER_BASE		:= StrZero(&("TRBPER->F3_BASIMP"+aNrLvrIB[nlI][2]),10,2) +","
										SIAPE->PER_ALIC		:= StrZero(&("TRBPER->F3_ALQIMP"+aNrLvrIB[nlI][2]),5,2) +","
										SIAPE->PER_VALIMP		:= StrZero(IIF(cTipCom="NC",&("TRBPER->F3_VALIMP"+aNrLvrIB[nlI][2])*-1,&("TRBPER->F3_VALIMP"+aNrLvrIB[nlI][2])),10,2) +","
										SIAPE->PER_TARIFA		:= PadR("", 4) +","
										SIAPE->PER_CATEG		:= cCateg +","
										SIAPE->PER_CODIMP		:= " ,"
										SIAPE->PER_TIPDOC		:= cTipCom 
										SIAPE->(MsUnlock())
									EndIf	
								EndIf
							Next nlI
						ElseIf UPPER(cArquivo)$"SIAPRE"						
							If Substr(aCodTab[1][1],1,1)=="1"								
								If alltrim(TRBPER->F3_TIPOMOV) == "C" .And. alltrim(TRBPER->F3_ESPECIE)$ "NF|NDP|NCP" .and. alltrim(TRBPER->A2_TIPROV) == "B"
								//Contribuyentes Locales - Recaudaciones Bancarias						
								
									cClaveSA6	:= TRBPER->A2_BANCO+TRBPER->A2_AGENCIA+TRBPER->A2_NUMCON
				
									_aArea:=GetArea()				
									aSA6:= GetAdvFVal("SA6", { "A6_CBU", "A6_MOEDA"},xFilial("SA6")+ cClaveSA6, 1)
									RestArea(_aArea)
									
									DbSelectArea("SIAPRERB")
									SIAPRERB->(dbSetOrder(1))
									SIAPRERB->(dbGoTop())
									If SIAPRERB->(!DbSeek(TRBPER->A2_CGC+Substr(TRBPER->F3_EMISSAO,1,4)+Substr(TRBPER->F3_EMISSAO,5,2)+Replicate("0",22-LEN(AllTrim(aSA6[1]))) + AllTrim(aSA6[1])+ StrTran(StrZero(&("TRBPER->F3_VALIMP" +  aNrLvrIB[1][2]),18,2),",",".")))
										RecLock("SIAPRERB",.T.)
											 SIAPRERB->SIA_CUIT		:= TRBPER->A2_CGC //Cuit
											 SIAPRERB->SIA_PERIOD  	:= Substr(TRBPER->F3_EMISSAO,1,4)+Substr(TRBPER->F3_EMISSAO,5,2) //Periodo
											 SIAPRERB->SIA_CBUCTA		:= Replicate("0",22-LEN(AllTrim(aSA6[1]))) + AllTrim(aSA6[1]) //CBU o Nro de cuenta
											 SIAPRERB->SIA_IMPORT		:= StrTran(StrZero(&("TRBPER->F3_VALIMP" +  aNrLvrIB[1][2]),18,2),",",".") //Importe
										
										SIAPRERB->(MsUnlock())
										nImp++
									EndIf
								ElseIf ((alltrim(TRBPER->F3_TIPOMOV) == "V" .And. alltrim(TRBPER->F3_ESPECIE)$ "NDE|NCE") .Or. (alltrim(TRBPER->F3_TIPOMOV) == "C" .And. alltrim(TRBPER->F3_ESPECIE)$ "NF|NDP|NCP".And. alltrim(TRBPER->A2_TIPROV) <> "B"))
									//Contribuyentes Locales - Percepciones
									DbSelectArea("SIAPRERP")
									SIAPRERP->(dbSetOrder(1))
									SIAPRERP->(dbGoTop())
									If SIAPRERP->(!DbSeek(Iif(alltrim(TRBPER->F3_ESPECIE)$ "NF|NDP|NCP",TRBPER->A2_CGC,TRBPER->A1_CGC ) + Substr(TRBPER->F3_EMISSAO,7)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4) + " " + Substr(TRBPER->F3_SERIE,1,1) + SUBSTR(AllTrim(TRBPER->F3_NFISCAL),1,4) + "P"))
										RecLock("SIAPRERP",.T.)
											SIAPRERP->SIA_CUIT		:= Iif(alltrim(TRBPER->F3_ESPECIE)$ "NF|NDP|NCP",TRBPER->A2_CGC,TRBPER->A1_CGC ) //Cuit
											SIAPRERP->SIA_RAZSOC		:= Iif(alltrim(TRBPER->F3_ESPECIE)$ "NF|NDP|NCP",TRBPER->A2_NOME,TRBPER->A1_NOME ) //Razon Social
											SIAPRERP->SIA_FCHCOM		:= Substr(TRBPER->F3_EMISSAO,7)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4) //Fecha de percepcion f3_emissao
											SIAPRERP->SIA_TPOCBT		:= " " //Tipo de comprobate
											SIAPRERP->SIA_LETRA		:= Substr(TRBPER->F3_SERIE,1,1) //Letra de comprobante
											SIAPRERP->SIA_TRMINL		:= SUBSTR(AllTrim(TRBPER->F3_NFISCAL),1,4) //Terminal
											SIAPRERP->SIA_NUMERO		:= SUBSTR(AllTrim(TRBPER->F3_NFISCAL),Len(AllTrim(TRBPER->F3_NFISCAL))-7) //Constancia
											SIAPRERP->SIA_IMPCOM		:= StrTran(StrZero(&("TRBPER->F3_VALIMP" +  aNrLvrIB[1][2]),18,2),",",".") //Valor del importe retenido/percibido
											SIAPRERP->SIA_CODRP		:= "P" //Codigo de retencion/percepcion
											SIAPRERP->SIA_IMPSTO		:= "11" //Impuesto
											
										SIAPRERP->(MsUnlock())
										nImp++
									EndIf
								EndIf
							Else
								If ((alltrim(TRBPER->F3_TIPOMOV) == "V" .and. alltrim(TRBPER->F3_ESPECIE)$ "NDE|NCE") .Or. (alltrim(TRBPER->F3_TIPOMOV) == "C" .and. alltrim(TRBPER->F3_ESPECIE)$ "NF|NDP|NCP" .and. alltrim(TRBPER->A2_TIPROV) == "P")) 
									//Contribuyentes del Convenio Multilateral - Percepciones
									Do case
									Case alltrim(TRBPER->F3_ESPECIE) $ "NF"
										cTipoCom:= "F"			
									Case alltrim(TRBPER->F3_ESPECIE) $ "NDE|NDP" //
										cTipoCom:= "C"
									Case alltrim(TRBPER->F3_ESPECIE) $ "NCP|NCE" //
										cTipoCom:= "D"
									End Do
									
									DbSelectArea("SIAPRECMP")
									SIAPRECMP->(dbSetOrder(1))
									SIAPRECMP->(dbGoTop())
									If SIAPRECMP->(!DbSeek("9" + cCodJur + TRANSFORM(Iif(alltrim(TRBPER->F3_ESPECIE)$ "NF|NDP|NCP",TRBPER->A2_CGC,TRBPER->A1_CGC ),"@R 99-99999999-9") + Substr(TRBPER->F3_EMISSAO,7)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4) + SUBSTR(AllTrim(TRBPER->F3_NFISCAL),1,4) + SUBSTR(AllTrim(TRBPER->F3_NFISCAL),Len(AllTrim(TRBPER->F3_NFISCAL))-7)))
										RecLock("SIAPRECMP",.T.)
											SIAPRECMP->SIA_CODJUR  	:= "9" + cCodJur //Codigo de jurisdiccion
											SIAPRECMP->SIA_CUITAG 		:= TRANSFORM(Iif(alltrim(TRBPER->F3_ESPECIE)$ "NF|NDP|NCP",TRBPER->A2_CGC,TRBPER->A1_CGC ),"@R 99-99999999-9") //Cuit de Agente
											SIAPRECMP->SIA_FCHPER 		:= Substr(TRBPER->F3_EMISSAO,7)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4) //Fecha de Percepcion
											SIAPRECMP->SIA_NUMSUC 		:= SUBSTR(AllTrim(TRBPER->F3_NFISCAL),1,4) //Numero de sucursal
											SIAPRECMP->SIA_NUMCON 		:= SUBSTR(AllTrim(TRBPER->F3_NFISCAL),Len(AllTrim(TRBPER->F3_NFISCAL))-7) //Numero de constancia
											SIAPRECMP->SIA_TPOCOM 		:= cTipoCom //Tipo de comprobante
											SIAPRECMP->SIA_LTACOM 		:= Substr(TRBPER->F3_SERIE,1,1) //Letra de comprobante
											SIAPRECMP->SIA_IMPRET 		:= StrTran(StrZero(&("TRBPER->F3_VALIMP" +  aNrLvrIB[1][2]),11,2),".",",") //Importe recibido
										
										SIAPRECMP->(MsUnlock())
										nImp++
									EndIf
								ElseIf alltrim(TRBPER->F3_TIPOMOV) == "C" .and. alltrim(TRBPER->F3_ESPECIE)$ "NF|NDP|NCP" .and. alltrim(TRBPER->A2_TIPROV) == "A"
									//Contribuyentes del Convenio Multilateral - Percepcion Aduanera
									cDesp := POSICIONE(	"SF1",2,; //"F1_FILIAL + F1_FORNECE + F1_LOJA + F1_DOC"
														xFilial("SF1")+TRBPER->F3_CLIEFOR+TRBPER->F3_LOJA+TRBPER->F3_NFISCAL,;
														"F1_NUMDES")
									
									DbSelectArea("SIAPRECMPA")
									SIAPRECMPA->(dbSetOrder(1))
									SIAPRECMPA->(dbGoTop())
									If SIAPRECMPA->(!DbSeek("9" + cCodJur + TRANSFORM(TRBPER->A2_CGC,"@R 99-99999999-9") + Substr(TRBPER->F3_EMISSAO,7)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4) + Replicate("0",20-LEN(AllTrim(cDesp))) + AllTrim(cDesp) + StrTran(StrZero(&("TRBPER->F3_VALIMP" +  aNrLvrIB[1][2]),10,2),".",",")))
										RecLock("SIAPRECMPA",.T.)								
											SIAPRECMPA->SIA_CODJUR		:= "9" + cCodJur //Codigo de jurisdiccion
											SIAPRECMPA->SIA_CUITAG		:= TRANSFORM(TRBPER->A2_CGC,"@R 99-99999999-9") //Cuit de Agente
											SIAPRECMPA->SIA_FCHPER		:= Substr(TRBPER->F3_EMISSAO,7)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4) //Fecha de percepcion
											SIAPRECMPA->SIA_NUMDSA		:= Replicate("0",20-LEN(AllTrim(cDesp))) + AllTrim(cDesp) //Numero de despacho
											SIAPRECMPA->SIA_IMPPER		:= StrTran(StrZero(&("TRBPER->F3_VALIMP" +  aNrLvrIB[1][2]),10,2),".",",") //Importe percibido
											
										SIAPRECMPA->(MsUnlock())
										nImp++
									EndIf
								ElseIf alltrim(TRBPER->F3_TIPOMOV) == "C" .and. alltrim(TRBPER->F3_ESPECIE)$ "NF|NDP|NCP" .and. alltrim(TRBPER->A2_TIPROV) == "B"
									//Contribuyentes del Convenio Multilateral - Recaudaciones Bancarias
									cClaveSA6	:= TRBPER->A2_BANCO+TRBPER->A2_AGENCIA+TRBPER->A2_NUMCON
				
									_aArea:=getArea()				
									aSA6:= GetAdvFVal("SA6", { "A6_CBU", "A6_MOEDA"},xFilial("SA6")+ cClaveSA6, 1)
									RestArea(_aArea)
				
									DbSelectArea("SIAPRECMRB")
									SIAPRECMRB->(dbSetOrder(1))
									SIAPRECMRB->(dbGoTop())
									If SIAPRECMRB->(!DbSeek("9" + cCodJur + TRANSFORM(TRBPER->A2_CGC,"@R 99-99999999-9") + Substr(TRBPER->F3_EMISSAO,1,4)+ "/" + Substr(TRBPER->F3_EMISSAO,5,2) + Replicate("0",22-LEN(AllTrim(aSA6[1]))) + AllTrim(aSA6[1]) + StrTran(StrZero(&("TRBPER->F3_VALIMP" +  aNrLvrIB[1][2]),10,2),".",",")))
										RecLock("SIAPRECMRB",.T.)
											SIAPRECMRB->SIA_CODJUR		:= "9" + cCodJur 
											SIAPRECMRB->SIA_CUIAG		:= TRANSFORM(TRBPER->A2_CGC,"@R 99-99999999-9") 
											SIAPRECMRB->SIA_PERRET		:= Substr(TRBPER->F3_EMISSAO,1,4)+ "/" + Substr(TRBPER->F3_EMISSAO,5,2) //Periodo de la retencion
											SIAPRECMRB->SIA_CBU			:= Replicate("0",22-LEN(AllTrim(aSA6[1]))) + AllTrim(aSA6[1])
											SIAPRECMRB->SIA_TPOCTA		:= "OO" 
											SIAPRECMRB->SIA_TPOMON		:= IIF(aSA6[2]==1,'P','E') 
											SIAPRECMRB->SIA_IMPRET		:= StrTran(StrZero(&("TRBPER->F3_VALIMP" +  aNrLvrIB[1][2]),10,2),".",",")
										
										SIAPRECMPA->(MsUnlock())
										nImp++
									EndIf
								EndIf	
							EndIf	
						ElseIf UPPER(cArquivo) == "DGR55-11|STAC-AR" .And. Substr(aCodTab[1][1],1,1) == "P" // Percepciones de IIBB de la Provincia de Rio Negro / Santa Cruz							
							cTipoCom:= "07"	

							If UPPER(cArquivo) == "DGR55-11"
								Do Case
								Case alltrim(TRBPER->F3_ESPECIE) $ "NF"
									cTipoCom:= "01"			
								Case alltrim(TRBPER->F3_ESPECIE) $ "NDC|NDI" 
									cTipoCom:= "05"
								Case alltrim(TRBPER->F3_ESPECIE) $ "NCP|NCC" 
									cTipoCom:= "06"
								End Do
							ElseIf UPPER(cArquivo) == "STAC-AR"
								Do Case
								Case alltrim(TRBPER->F3_ESPECIE) $ "NF"
									cTipoCom:= "01"			
								Case alltrim(TRBPER->F3_ESPECIE) $ "NDC|NDI|NDE|NDP" 
									cTipoCom:= "05"
								Case alltrim(TRBPER->F3_ESPECIE) $ "NCP|NCC|NCE|NCI" 
									cTipoCom:= "06"
								End Do
							EndIf 
							
							If (alltrim(TRBPER->F3_TIPOMOV) == "C" .and. alltrim(TRBPER->F3_ESPECIE)$ "NF|NDI|NDP") .or. ; 
							   (alltrim(TRBPER->F3_TIPOMOV) == "V" .and. alltrim(TRBPER->F3_ESPECIE)$ "NF|NDC|NDE")
							   
								If DGPERE->(!DbSeek(cTipoCom+Substr(TRBPER->F3_SERIE,1,1)+TRBPER->F3_NFISCAL+Iif(alltrim(TRBPER->F3_TIPOMOV) == "C",TRBPER->A2_CGC,TRBPER->A1_CGC )))
									
									//Percepciones Efectuadas
									DbSelectArea("DGPERE")
									DGPERE->(dbSetOrder(1))
									DGPERE->(dbGoTop())
									RecLock("DGPERE",.T.)
										DGPERE->DGP_CONCEP	:= IIF(UPPER(cArquivo) == "DGR55-11","20","01")
										DGPERE->DGP_FCHPER	:= Substr(TRBPER->F3_EMISSAO,7)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4)
										DGPERE->DGP_TIPCOM	:= cTipoCom
										DGPERE->DGP_LETRA		:= Substr(TRBPER->F3_SERIE,1,1)
										DGPERE->DGP_NROCOM	:= TRBPER->F3_NFISCAL
										DGPERE->DGP_CUIT		:= Iif(alltrim(TRBPER->F3_TIPOMOV) == "C",TRBPER->A2_CGC,TRBPER->A1_CGC )
										DGPERE->DGP_BASEPE	:= StrTran(StrZero(&("TRBPER->F3_BASIMP" +  aNrLvrIB[1][2]),15,2),".",",")
										DGPERE->DGP_ALICUO	:= StrTran(StrZero(&("TRBPER->F3_ALQIMP" +  aNrLvrIB[1][2]),5,2),".",",")
										DGPERE->DGP_IMPPER	:= StrTran(StrZero(&("TRBPER->F3_VALIMP" +  aNrLvrIB[1][2]),15,2),".",",")
										
									DGPERE->(MsUnlock()) 
									nImp++
									If TRBPER->F3_TIPOMOV == "V"
										PadCP(TRBPER->A1_CGC,aCodTab[1][3],1,TRBPER->F3_CLIEFOR,TRBPER->F3_LOJA,cDtFim,aCodTab[1][2],cArquivo)
									ElseIf TRBPER->F3_TIPOMOV == "C" .and. UPPER(cArquivo) == "STAC-AR"
										PadCP(TRBPER->A2_CGC,aCodTab[1][3],2,TRBPER->F3_CLIEFOR,TRBPER->F3_LOJA,cDtFim,aCodTab[1][2],cArquivo)
									EndIf
								ElseIf DGPERE->(DbSeek(cTipoCom+Substr(TRBPER->F3_SERIE,1,1)+TRBPER->F3_NFISCAL+Iif(alltrim(TRBPER->F3_TIPOMOV) == "C",TRBPER->A2_CGC,TRBPER->A1_CGC ))) .and. UPPER(cArquivo) $ "DGR55-11"
									RecLock("DGPERE",.F.)
										DGPERE->DGP_BASEPE	:= StrTran(StrZero( Val(StrTran(DGPERE->DGP_BASEPE,",",".")) + &("TRBPER->F3_BASIMP" +  aNrLvrIB[1][2]),15,2),".",",")
										DGPERE->DGP_IMPPER	:= StrTran(StrZero( Val(StrTran(DGPERE->DGP_IMPPER,",",".")) + &("TRBPER->F3_VALIMP" +  aNrLvrIB[1][2]),15,2),".",",")
									DGPERE->(MsUnlock())	
								EndIf
							ElseIf (alltrim(TRBPER->F3_TIPOMOV) == "C" .and. alltrim(TRBPER->F3_ESPECIE)$ "NCP|NCI") .or. ;
									(alltrim(TRBPER->F3_TIPOMOV) == "V" .and. alltrim(TRBPER->F3_ESPECIE)$ "NCC|NCE")	 
								
								If DGPERE->(!DbSeek(cTipoCom+Substr(TRBPER->F3_SERIE,1,1)+TRBPER->F3_NFISCAL+Iif(alltrim(TRBPER->F3_TIPOMOV) == "C",TRBPER->A2_CGC,TRBPER->A1_CGC )))
									//Percepciones Anuladas
									DbSelectArea("DGPERA")
									DGPERA->(dbSetOrder(1))
									DGPERA->(dbGoTop())
									RecLock("DGPERA",.T.)
										DGPERA->DGP_FCHANU	:= Substr(TRBPER->F3_EMISSAO,7)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4)
										DGPERA->DGP_TIPCOM	:= cTipoCom
										DGPERA->DGP_LETRA		:= Substr(TRBPER->F3_SERIE,1,1)
										DGPERA->DGP_NROCOM	:= TRBPER->F3_NFISCAL
										DGPERA->DGP_FCHPEA	:= Substr(TRBPER->F3_EMISSAO,7)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4)
										DGPERA->DGP_MONPEA	:= StrTran(StrZero(&("TRBPER->F3_VALIMP" +  aNrLvrIB[1][2]),15,2),".",",")
										DGPERA->DGP_CUIT		:= Iif(alltrim(TRBPER->F3_TIPOMOV) == "C",TRBPER->A2_CGC,TRBPER->A1_CGC )
									
									DGPERA->(MsUnlock())
									nImp++
									If TRBPER->F3_TIPOMOV == "V"
										PadCP(TRBPER->A1_CGC,aCodTab[1][3],1,TRBPER->F3_CLIEFOR,TRBPER->F3_LOJA,cDtFim,aCodTab[1][2],cArquivo)
									ElseIf TRBPER->F3_TIPOMOV == "C" .and. UPPER(cArquivo) == "STAC-AR"
										PadCP(TRBPER->A2_CGC,aCodTab[1][3],2,TRBPER->F3_CLIEFOR,TRBPER->F3_LOJA,cDtFim,aCodTab[1][2],cArquivo)
									EndIf
								ElseIf DGPERE->(DbSeek(cTipoCom+Substr(TRBPER->F3_SERIE,1,1)+TRBPER->F3_NFISCAL+Iif(alltrim(TRBPER->F3_TIPOMOV) == "C",TRBPER->A2_CGC,TRBPER->A1_CGC ))) .and. UPPER(cArquivo) $ "DGR55-11"
									RecLock("DGPERE",.F.)
										DGPERA->DGP_MONPEA	:= StrTran(StrZero( Val(StrTran(DGPERA->DGP_MONPEA,",",".")) + &("TRBPER->F3_VALIMP" +  aNrLvrIB[1][2]),15,2),".",",")
									DGPERE->(MsUnlock())	
								EndIf
							EndIf		

						ElseIf UPPER(cArquivo)$"RES98-97" //Percepciones de IIBB de la Provincia de Formosa

							DbSelectArea("FORMOS")
							FORMOS->(dbSetOrder(1))
							FORMOS->(dbGoTop())
							If  FORMOS->(!DbSeek(TRBPER->F3_NFISCAL+Iif(alltrim(TRBPER->F3_TIPOMOV) == "C",TRBPER->A2_CGC,TRBPER->A1_CGC )))    //"FOR_NROCOM+FOR_CUIT+FOR_CATEGO"
								//Percepciones Efectuadas
								RecLock("FORMOS",.T.)
									FORMOS->FOR_NROCOM	:= TRBPER->F3_NFISCAL  //Nro de Comprobante
									FORMOS->FOR_FECHA	:= Substr(TRBPER->F3_EMISSAO,7)+"/"+Substr(TRBPER->F3_EMISSAO,5,2)+"/"+Substr(TRBPER->F3_EMISSAO,1,4) //Fecha de Percepcion
									FORMOS->FOR_CUIT	:= Iif(alltrim(TRBPER->F3_TIPOMOV) == "C",TRBPER->A2_CGC,TRBPER->A1_CGC )   //CUIT
									FORMOS->FOR_DNOMIN	:= Alltrim(Iif(alltrim(TRBPER->F3_TIPOMOV) == "C",TRBPER->A2_NOME,TRBPER->A1_NOME ))  //Denominación
									FORMOS->FOR_CATEGO	:= ""  //Categoria
									If len(aNrLvrIB) > 0 .And. Len(aNrLvrIB[1]) > 0      	
										FORMOS->FOR_MONTO	:= StrTran(Alltrim(str(&("TRBPER->F3_BASIMP" +  aNrLvrIB[1][2]))),",",".")   //Monto
										FORMOS->FOR_ALIQUO	:= StrTran(Alltrim(str(&("TRBPER->F3_ALQIMP" +  aNrLvrIB[1][2]))),",",".")   //Alícuota
										FORMOS->FOR_RETENC	:= StrTran(Alltrim(str(&("TRBPER->F3_VALIMP" +  aNrLvrIB[1][2]))),",",".")   //Percepcion 
									Else
										FORMOS->FOR_MONTO	:= "0"
										FORMOS->FOR_ALIQUO	:= "0"
										FORMOS->FOR_RETENC	:= "0"
									EndIf
									FORMOS->FOR_OBSERV	:= ""  //Observación (En blanco)
								FORMOS->(MsUnlock())
								nImp++
							EndIf
							
						ElseIf UPPER(cArquivo)$"RES53-14" //Percepciones y Retenciones de la Municipalidad de Cordoba			    						    
						    cDomc := ""
						    cMun  := ""
						    cCep  := ""
						    cNome := ""	  
							cCUITFor:= ""
							dFchUlt := CTOD("//") 	 
							cFchPri := ""  	   
										    
						    If !Empty(TRBPER->F3_CLIEFOR) .and. alltrim(TRBPER->F3_TIPOMOV) == "C"   
								DbSelectArea("SA2")
								SA2->(DbSetOrder(1)) //"A2_FILIAL+A2_COD+A2_LOJA"								
								If  SA2->(DbSeek(xFilial("SA2")+AvKey(TRBPER->F3_CLIEFOR,"A2_COD")+AvKey(TRBPER->F3_LOJA,"A2_LOJA")))															    
								    cDomc 	:= SA2->A2_END
								    cMun  	:= Iif(!EMPTY(Alltrim(SA2->A2_BAIRRO)),Alltrim(SA2->A2_BAIRRO) +" ","") + Alltrim(SA2->A2_MUN)
								    cCep  	:= SA2->A2_CEP
								    cNome 	:= SA2->A2_NOME	  
								    cCUITFor:= SA2->A2_CGC 
								    dFchUlt := SA2->A2_ULTCOM 
								EndIf  								
								cFchPri := ObtPFchIni(AvKey(TRBPER->F3_CLIEFOR,"A2_COD"),AvKey(TRBPER->F3_LOJA,"A2_LOJA"),aNrLvrMn)  //Obtener fecha de Primera Retencion para el Impuesto y Municipalidad
								cNumComp := GetComp(Iif(AllTrim(TRBPER->F3_ESPECIE) $ "NF|NDP|NCI","SF1","SF2"), TRBPER->F3_NFISCAL + TRBPER->F3_SERIE+TRBPER->F3_CLIEFOR+TRBPER->F3_LOJA)
							ElseIf !Empty(TRBPER->F3_CLIEFOR) .and. alltrim(TRBPER->F3_TIPOMOV) == "V"
								DbSelectArea("SA1")
								SA1->(DbSetOrder(1)) //"A1_FILIAL+A1_COD+A1_LOJA"							
								If  SA1->(DbSeek(xFilial("SA1")+AvKey(TRBPER->F3_CLIEFOR,"A1_COD")+AvKey(TRBPER->F3_LOJA,"A1_LOJA")))															    
								    cDomc 	:= SA1->A1_END
								    cMun  	:= Iif(!EMPTY(Alltrim(SA1->A1_BAIRRO)),Alltrim(SA1->A1_BAIRRO) +" ","") + Alltrim(SA1->A1_MUN)
								    cCep  	:= SA1->A1_CEP
								    cNome 	:= SA1->A1_NOME	  
								    cCUITFor:= SA1->A1_CGC 
								    dFchUlt := SA1->A1_ULTCOM 
								EndIf  								
								cFchPri := ObtPFchIni(AvKey(TRBPER->F3_CLIEFOR,"A1_COD"),AvKey(TRBPER->F3_LOJA,"A1_LOJA"),aNrLvrMn)  //Obtener fecha de Primera Retencion para el Impuesto y Municipalidad
								cNumComp := GetComp(Iif(AllTrim(TRBPER->F3_ESPECIE) $ "NF|NCE|NDC","SF2","SF1"), TRBPER->F3_NFISCAL + TRBPER->F3_SERIE+TRBPER->F3_CLIEFOR+TRBPER->F3_LOJA)														
							EndIf
							
							For nLvr:=1 to len(aNrLvrMn)							
								DbSelectArea("RES5314")
								RES5314->(dbSetOrder(1))
								RES5314->(dbGoTop())
								If  RES5314->(!DbSeek(StrZero(Year(STOD(TRBPER->F3_EMISSAO)),4)+"-"+RIGHT(cNumComp,6)+Substr(cCUITFor,1,2)+Substr(cCUITFor,3,8)+Substr(cCUITFor,11,1)+StrZero(TRBPER->&("F3_ALQIMP"+aNrLvrMn[nLvr][2]) *100,5)))  //"MUN_NoCOMP+MUN_TCUITR+MUN_NCUITR+MUN_VCUITR+MUN_COMORI+MUN_ALICUO"
									//Percepciones Efectuadas
									dbSelectArea("SX5")
									dbSetOrder(1)
									SX5->(dbGoTop())
									dbSeek(xFilial("SX5") + GetMv("MV_CODPF"))
									While SX5->X5_TABELA == GetMv("MV_CODPF")
											aAdd(aCodFP,{ALLTRIM(X5_CHAVE),alltrim(X5_DESCSPA)})
										DBSKIP()
									End
									nCodPf := 0
									For nCodPf := 1 To Len(aCodFP)	
										IF (Substr(TRBPER->F3_NFISCAL,1,4)) $ aCodFP[nCodPf][2]	 
											cPTPAG := aCodFP[nCodPf][1]
											nCodPf := Len(aCodFP)
										EndIf			
									Next nCodPf
									RecLock("RES5314",.T.)
									RES5314->MUN_TPOREG := "1"    
									RES5314->MUN_TCUITA	:= Substr(SM0->M0_CGC,1,2) //1
									RES5314->MUN_NCUITA	:= Substr(SM0->M0_CGC,3,8) //2
									RES5314->MUN_VCUITA	:= Substr(SM0->M0_CGC,11,1) //3
									RES5314->MUN_PERIOD	:= StrZero(Year(STOD(TRBPER->F3_EMISSAO)),4)+StrZero(Month(STOD(TRBPER->F3_EMISSAO)),2) //4
									RES5314->MUN_NOCOMP	:= StrZero(Year(STOD(TRBPER->F3_EMISSAO)),4)+"-"+RIGHT(cNumComp,6) //5
									RES5314->MUN_PTPAGO	:= cPTPAG //6
									RES5314->MUN_COMORI	:= Substr(TRBPER->F3_SERIE,1,1)+TRBPER->F3_NFISCAL //7
									RES5314->MUN_TCUITR := Substr(cCUITFor,1,2) //8
									RES5314->MUN_NCUITR := Substr(cCUITFor,3,8) //9
									RES5314->MUN_VCUITR := Substr(cCUITFor,11,1) //10
									RES5314->MUN_VALBAS := StrZero(TRBPER->&("F3_BASIMP"+aNrLvrMn[nLvr][2]) *100,15) //11
									RES5314->MUN_ALICUO := StrZero(TRBPER->&("F3_ALQIMP"+aNrLvrMn[nLvr][2]) *100,5) //12
									RES5314->MUN_VALRET := StrZero(TRBPER->&("F3_VALIMP"+aNrLvrMn[nLvr][2]) *100,15) //13
									RES5314->MUN_EDOCOM := Iif((AllTrim(TRBPER->F3_DTCANC)=="" .And. AllTrim(TRBPER->F3_ESPECIE)$("NCC|NDE|NDI|NCP")),"N",Iif((AllTrim(TRBPER->F3_DTCANC)<>""),"B","A") )      //A=Activo; B=Anulado; N=Nota de Credito //14
									RES5314->MUN_FCHRET	:= StrZero(Year(STOD(TRBPER->F3_EMISSAO)),4)+StrZero(Month(STOD(TRBPER->F3_EMISSAO)),2)+StrZero(Day(STOD(TRBPER->F3_EMISSAO)),2) //15
									RES5314->MUN_FCHANU	:= StrZero(Year(STOD(TRBPER->F3_DTCANC)),4)+StrZero(Month(STOD(TRBPER->F3_DTCANC)),2)+StrZero(Day(STOD(TRBPER->F3_DTCANC)),2) //16
									RES5314->MUN_NOME	:= cNome //17
									RES5314->MUN_END	:= cDomc //18
									RES5314->MUN_NUM	:= "" //19
									RES5314->MUN_PISO	:= "" //20
									RES5314->MUN_DEPTO	:= "" //21
									RES5314->MUN_BAIRRO	:= cMun //22
									RES5314->MUN_CEP	:= cCep //23
									If !Empty(cFchPri)
										RES5314->MUN_FCHINI	:= StrZero(Year(STOD(cFchPri)),4)+StrZero(Month(STOD(cFchPri)),2)+StrZero(Day(STOD(cFchPri)),2) //24
									EndIf
									If !Empty(dFchUlt)
										RES5314->MUN_FCHFIN	:= StrZero(Year(dFchUlt),4)+StrZero(Month(dFchUlt),2)+StrZero(Day(dFchUlt),2) //25
									EndIf 
	 								RES5314->(MsUnlock()) 
									nImp++  
								Else 
									RecLock("RES5314",.F.)
									RES5314->MUN_VALBAS := StrZero(TRBPER->&("F3_BASIMP"+aNrLvrMn[nLvr][2]) *100 + VAL(RES5314->MUN_VALBAS),15) //11StrZero((ABS(TRBRET->VLRBAS) *100)+val(RES5314->MUN_VALBAS),15)
									RES5314->MUN_VALRET := StrZero(TRBPER->&("F3_VALIMP"+aNrLvrMn[nLvr][2]) *100 + VAL(RES5314->MUN_VALRET),15) //13
	 								RES5314->(MsUnlock()) 		
								EndIf
							
							Next nLvr																				
						ElseIf UPPER(cArquivo)$"IVAIMP"
							If nVlrIva > 0
								DbSelectArea("IVAIMP")
								IVAIMP->(dbSetOrder(1)) //IMP_PROV + IMP_LOJA + IMP_NFIS
								IVAIMP->(dbGoTop())
								If IVAIMP->(!DbSeek(TRBPER->F3_CLIEFOR + TRBPER->F3_LOJA + TRBPER->F3_NFISCAL))
									nImp++
									RecLock("IVAIMP",.T.)
										IVAIMP->IMP_PROV := TRBPER->F3_CLIEFOR
										IVAIMP->IMP_LOJA := TRBPER->F3_LOJA
										IVAIMP->IMP_NFIS := TRBPER->F3_NFISCAL
										IVAIMP->IMP_TPODEC := "0" 
										IVAIMP->IMP_NUMDES := TRBPER->NUMDESF1
										IVAIMP->IMP_CREDF := AllTrim(StrTran(STR(nVlrIva),".",","))
										IVAIMP->IMP_CREDFC := AllTrim(StrTran(STR(nVlrIva),".",","))
									IVAIMP->(MsUnlock())
								Else									
									RecLock("IVAIMP",.F.)
										IVAIMP->IMP_CREDF := StrTran(StrZero(val(StrZero(nVlrIva,14,2)) + val(IVAIMP->IMP_CREDF),14,2), ".", "," )
										IVAIMP->IMP_CREDFC := StrTran(StrZero(val(StrZero(nVlrIva,14,2)) + val(IMP_CREDFC),14,2), ".", "," )																		   						
									IVAIMP->(MsUnlock())								
								EndIf
							EndIf		
						ElseIf UPPER(cArquivo) $ "PERCMUN"
							nPosTEM := ASCAN(aNrLvrMn,{|x|x[1] == "TEM"})
							nPosPYP := ASCAN(aNrLvrMn,{|x|x[1] == "PYP"})
							If nPosTEM <> 0
								If TRBPER->&("F3_BASIMP" + aNrLvrMn[nPosTEM][2] ) > 0
									nImp++
									DbSelectArea("PERCMUN")
									PERCMUN->(dbSetOrder(1)) //MUN_CUIT
									PERCMUN->(dbGoTop())
									RecLock("PERCMUN",.T.)
										PERCMUN->MUN_CUIT   := TRBPER->A1_CGC
										PERCMUN->MUN_RASOC  := TRBPER->A1_NOME
										PERCMUN->MUN_DOMCOM := TRBPER->A1_END
										PERCMUN->MUN_COMPRO := TRBPER->F3_NFISCAL
										PERCMUN->MUN_CONRET := ""
										PERCMUN->MUN_FECOMP := SUBSTR(TRBPER->F3_EMISSAO,7,2) + "/" + SUBSTR(TRBPER->F3_EMISSAO,5,2) + "/" + SUBSTR(TRBPER->F3_EMISSAO,1,4)
										PERCMUN->MUN_MONIMP := IIF(AllTrim(TRBPER->F3_ESPECIE) $  "NCC|NDI", "-","") + AllTrim(StrTran( STR( IIF (nPosTEM>0, TRBPER->&("F3_BASIMP" + aNrLvrMn[nPosTEM][2] ), "0") ), ",", "."))
										PERCMUN->MUN_MONTEM := IIF(AllTrim(TRBPER->F3_ESPECIE) $  "NCC|NDI", "-","") + AllTrim(StrTran( STR( IIF (nPosTEM>0, TRBPER->&("F3_VALIMP" + aNrLvrMn[nPosTEM][2] ), "0") ), ",", "."))
										PERCMUN->MUN_MONPYP := IIF(AllTrim(TRBPER->F3_ESPECIE) $  "NCC|NDI", "-","") + AllTrim(StrTran( STR( IIF (nPosPYP>0, TRBPER->&("F3_VALIMP" + aNrLvrMn[nPosPYP][2] ), "0") ), ",", "."))
									PERCMUN->(MsUnlock())
								EndIf	
							EndIf																																				
						ElseIf (UPPER(cArquivo) $ "DGR19310" .And. SubStr(aCodTab[1][1],1,1)=="2")
							nImp++
							DbSelectArea("DGR19310")
							DGR19310->(dbSetOrder(1))//RET_CODRET+RET_NUMCER
							DGR19310->(dbGoTop())
							RecLock("DGR19310",.T.)
							DGR19310->DGR_CPO1 := SUBSTR(TRBPER->F3_EMISSAO,7,2) + "/" + SUBSTR(TRBPER->F3_EMISSAO,5,2) + "/" + SUBSTR(TRBPER->F3_EMISSAO,1,4)
							DGR19310->DGR_CPO2 := TRBPER->F3_NFISCAL
							DGR19310->DGR_CPO3 := PADL(AllTrim(str(Round(TRBPER->F3_VALCONT,2) * 100)),12,"0")
							DGR19310->DGR_CPO4 := PADL(Alltrim(str(Round(&("TRBPER->F3_BASIMP" +  aNrLvrIB[1][2]),2) * 100)),12,"0")   //Monto
							DGR19310->DGR_CPO5 := PADL(Alltrim(str(Round(&("TRBPER->F3_ALQIMP" +  aNrLvrIB[1][2]),2) * 100)),5,"0")  //Alícuota
							DGR19310->DGR_CPO6 := PADL(Alltrim(str(Round(&("TRBPER->F3_VALIMP" +  aNrLvrIB[1][2]),2) * 100)),12,"0")   //Percepcion
							If AllTrim(TRBPER->F3_ESPECIE) $ "NCC|NDI"
								DGR19310->DGR_CPO6 := "-" + Substr(DGR19310->DGR_CPO6,2)
							EndIf
							DGR19310->DGR_CPO7 := Transform(TRBPER->A1_NROIB, "@E 999-999999-9" )
							DGR19310->DGR_CPO8 := Transform(TRBPER->A1_CGC, "@E 99-99999999-9" )
							DGR19310->DGR_CPO9 := TRBPER->A1_NOME
							DGR19310->DGR_CPO10 := TRBPER->A1_END
							DGR19310->DGR_CPO11 := TRBPER->A1_MUN
							DGR19310->DGR_CPO12 := TRBPER->A1_CEP
							DGR19310->DGR_CPO13 := CodProv(aCodTab[2][1])
							Enc19310(aCodTab,1,Round(TRBPER->F3_VALCONT,2),TRBPER->F3_ESPECIE)
							DGR19310->(MsUnlock())
						EndIf //Archivos
						TRBPER->(DbSkip())
					Enddo //					
				ElseIf UPPER(cArquivo) == "CV3865"
				
					Aadd(aLogreg,Replicate("=",80))

					AAdd(aLogreg,STR0067 + If(Substr(aCodTab[1][2],1,1) $ "V|T"," - " + STR0068,'') + If(Substr(aCodTab[1][2],1,1) $ "C|T"," - " + STR0069,''))
					If Substr(aCodTab[1][2],1,1) $ "V|T"
						AAdd(aLogreg,STR0070 + " " + STR0068)		// Detalle Ventas 
						AAdd(aLogreg,STR0057 + "s " + STR0068)		// Alicuotas Ventas
					EndIf 
					If Substr(aCodTab[1][2],1,1) $ "C|T"
						AAdd(aLogreg,STR0070 + " " + STR0069)		// Detalle Compras
						AAdd(aLogreg,STR0057 + "s " + STR0069)		// Alicuotas Compras
						AAdd(aLogreg,STR0069 + " " + STR0071)		// Compras Importaciones
						AAdd(aLogreg,STR0072)						// "Credito Fiscal Imp Servicios"
					EndIf 
					
					Aadd(aLogreg,Replicate("=",80))
					
					aAreaSF1   := SF1->(GetArea())
					aAreaSF2   := SF2->(GetArea())
					// Encabezado
					GravaRG3865(PadR(Alltrim(SM0->M0_CGC), 11),Substr(cDtIni,1,4) + Substr(cDtIni,5,2),aCodTab[1][1],IIf(TRBPER->(Eof()),"S","N"))
					cNDocto := ''
					Do While TRBPER->(!Eof()) .And. lOk
						cAliasSF	:= Iif(TRBPER->F3_TES > "500","SF2","SF1")
						dbSelectArea(cAliasSF)
						If cAliasSF = "SF1"
							dbSetOrder(1)//"F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO"
						Else
							dbSetOrder(1)//"F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO"
						EndIf 

						If !dbSeek(xFilial(cAliasSF) + TRBPER->F3_NFISCAL + TRBPER->F3_SERIE + TRBPER->F3_CLIEFOR + TRBPER->F3_LOJA)
							TRBPER->(DbSkip())
							loop
						EndIf
						
						If cAliasSF = "SF1" .and. SF1->(FieldPos("F1_NUMDES")) > 0 .and. TRBPER->F3_TIPOMOV = "C" .and. ;
						!Empty(Alltrim((cAliasSF)->F1_NUMDES)) .and. ;
						Substr(Alltrim((cAliasSF)->F1_NUMDES),6,2) $ "|CO|IT|LA|LN|RE|RZ|TB|TG|TL|TR|TZ|" // Excluirse Importaciones no definitivas 
						
							TRBPER->(DbSkip())
							loop
						EndIf 
						//DMICNS-12668 excluir de la selección los comprobantes de Importación de Bienes (F1/F2_SERIE="E" donde F1/F2_TPVENT="B")
						If TRBPER->F3_TIPOMOV == "C" .AND. TRBPER->F3_TPVENT $ "B|1" .AND. SubStr(TRBPER->F3_SERIE,1,1) == "E"
							TRBPER->(DbSkip())
							loop
						EndIf

						// Detalle Ventas
						DbSelectArea("DETVTA")
						DETVTA->(dbSetOrder(1)) // DET_FCHCOM + DET_PUNVEN + DET_TIPCOM + DET_NUMCOM
						DETVTA->(dbGoTop())

						cTipDoc	:= M991TpComp(If(TRBPER->F3_TES > "500","SD2","SD1"),TRBPER->F3_SERIE,TRBPER->F3_ESPECIE,UPPER(cArquivo))
						cTipDoc	:= Iif(len(cTipDoc) = 2, "0" + cTipDoc,cTipDoc)

						If SF1->(FieldPos('F1_TCOMP')) >0 .and. SF2->(FieldPos('F2_TCOMP')) >0
							If cAliasSF = "SF1" .and. !Empty(Alltrim(SF1->F1_TCOMP))
								cTipDoc := Alltrim(SF1->F1_TCOMP)
								cTipDoc	:= Iif(len(cTipDoc) = 2, "0" + cTipDoc,cTipDoc)
							ElseIf cAliasSF = "SF2" .and. !Empty(Alltrim(SF2->F2_TCOMP))
								cTipDoc := Alltrim(SF2->F2_TCOMP)
								cTipDoc	:= Iif(len(cTipDoc) = 2, "0" + cTipDoc,cTipDoc)
							EndIf 
						EndIf 

						If SF1->(FieldPos("F1_RG1415")) >0 .and. SF2->(FieldPos("F2_RG1415")) >0 
							If cAliasSF = "SF1" .and. !Empty(Alltrim(SF1->F1_RG1415))
								cTipDoc := Alltrim(SF1->F1_RG1415)
								cTipDoc	:= Iif(len(cTipDoc) = 2, "0" + cTipDoc,cTipDoc)
							ElseIf cAliasSF = "SF2" .and. !Empty(Alltrim(SF2->F2_RG1415))
								cTipDoc := Alltrim(SF2->F2_RG1415)
								cTipDoc	:= Iif(len(cTipDoc) = 2, "0" + cTipDoc,cTipDoc)
							EndIf 
						EndIf 

						If SD2->(FieldPos('D2_COELQ')) >0 .and. SD1->(FieldPos('D1_COELQ')) >0
							
							If cAliasSF == "SF2" 
								cCoe := ALLTRIM(Posicione("SD2", 3, xFilial("SD2")+AvKey(TRBPER->F3_NFISCAL,"D2_DOC")+AvKey(TRBPER->F3_SERIE,"D2_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"F3_CLIEFOR")+AvKey(TRBPER->F3_LOJA,"D2_LOJA"),"D2_COELQ"))
							Else
								cCoe := ALLTRIM(Posicione("SD1", 1, xFilial("SD1")+AvKey(TRBPER->F3_NFISCAL,"D1_DOC")+AvKey(TRBPER->F3_SERIE,"D1_SERIE")+AvKey(TRBPER->F3_CLIEFOR,"D1_FORNECE")+AvKey(TRBPER->F3_LOJA,"D1_LOJA"),"D1_COELQ"))
							EndIf
						EndIF

						IF TRBPER->F3_RG1415 $ "033|331" .and. !Empty(cCoe) 
							IF LEN(cCoe) >= 8
								cNFiscal := Replicate("0" , 20 - LEN(SUBSTR(cCoe ,-8)) ) + SUBSTR(cCoe ,-8)
							Else
								cNFiscal := Replicate("0" , 20 - LEN(SUBSTR(cCoe ,-LEN(cCoe))) ) + cCoe
							EndIF
							cPedido  := Replicate("0",5)
						Else
							If Len(TRBPER->F3_NFISCAL)>12
								cNFiscal := Replicate("0",20-LEN(ALLTRIM(SUBSTR(TRBPER->F3_NFISCAL,6)))) + ALLTRIM(SUBSTR(TRBPER->F3_NFISCAL,6))
								cPedido := SUBSTR(TRBPER->F3_NFISCAL,1,5)
							Else
								cNFiscal := Replicate("0",20-LEN(ALLTRIM(SUBSTR(TRBPER->F3_NFISCAL,5)))) + ALLTRIM(SUBSTR(TRBPER->F3_NFISCAL,5))
								cPedido := "0" + SUBSTR(TRBPER->F3_NFISCAL,1,4)
							EndIf
						EndIF

						cLlave := TRBPER->F3_EMISSAO + cPedido
						cLlave += cTipDoc
						cLlave += cNFiscal
						cLlave += TRBPER->F3_CLIEFOR + TRBPER->F3_LOJA + TRBPER->F3_FILIAL	 
						
						If TRBPER->F3_TIPOMOV = "V" .and. DETVTA->(!DbSeek( cLlave )) 
							If  RecLock("DETVTA",.T.)
								DETVTA->DET_FCHCOM	:= TRBPER->F3_EMISSAO 
								DETVTA->DET_TIPCOM	:= STRZERO(VAL(cTipDoc),3)
								DETVTA->DET_PUNVEN	:= cPedido
								DETVTA->DET_NUMCOM	:= cNFiscal 
								DETVTA->DET_NCHAST	:= cNFiscal
								DETVTA->DET_COD		:= TRBPER->F3_CLIEFOR
								DETVTA->DET_LOJA		:= TRBPER->F3_LOJA
								DETVTA->DET_FILIAL	:= TRBPER->F3_FILIAL

								DbSelectArea("SLS")
								SLS->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
								SLS->(DbGoTop())
								If DbSeek(xFilial("SLS")+TRBPER->F3_SERIE+TRBPER->F3_NFISCAL)
									if SLS->LS_TPDOCCF <> "6"
										DETVTA->DET_CODCOM	:= Substr(Posicione("SX5", 1, xFilial("SX5")+"OC" + TRBPER->A1_AFIP,"X5_DESCSPA"),1,2)
									else 
										DETVTA->DET_CODCOM	:= SLS->LS_TIPOCI
									Endif
									DETVTA->DET_CUIT		:= Replicate("0",20-LEN(ALLTRIM(SLS->LS_DOCCF))) + ALLTRIM(SLS->LS_DOCCF)
									DETVTA->DET_NOMBRE	:= SubStr(SLS->LS_CLIECF,1,30)
								Else										
									If SA1->(FieldPos("A1_AFIP")) > 0 .AND. Alltrim(TRBPER->A1_AFIP) $ "80|99"
										DETVTA->DET_CODCOM	:= TRBPER->A1_AFIP
									ElseIf  SA1->(FieldPos("A1_AFIP")) > 0
										DETVTA->DET_CODCOM	:= Substr(Posicione("SX5", 1, xFilial("SX5")+"OC" + TRBPER->A1_AFIP,"X5_DESCSPA"),1,2)
									Endif
									DETVTA->DET_CUIT		:= Iif(DETVTA->DET_CODCOM == "99",STRZERO(0,20),Replicate("0",20-LEN(ALLTRIM(TRBPER->A1_CGC))) + ALLTRIM(TRBPER->A1_CGC))
									DETVTA->DET_NOMBRE	:= SubStr(TRBPER->A1_NOME,1,30)
								Endif
								
								If cNDocto <> cLlave
									Act3865(IIF(TRBPER->F3_EXENTAS <> 0,.T.,.F.),TRBPER->F3_TES,"DETVTA",;
									TRBPER->F3_NFISCAL,TRBPER->F3_SERIE,TRBPER->F3_CLIEFOR,TRBPER->F3_LOJA,TRBPER->F3_TIPOMOV,;
									aNrLvrIV,aNrLvIVA,aNrLvrGN,aNrLvrIB,aNrLvrMn,aNrLvrIn,aNrLvrIm,aNrLvrIip,aCodTab)
									cNDocto := cLlave
								EndIf 
								
								DETVTA->DET_OTRTRI	:= STRZERO(0,15)
								DETVTA->(MsUnlock())
								nImp++
							EndIf 
						ElseIf TRBPER->F3_TIPOMOV = "C" .and. DETCOM->(!DbSeek( cLlave )) 
							If  RecLock("DETCOM",.T.)
								DETCOM->DET_FCHCOM	:= TRBPER->F3_EMISSAO 		
								DETCOM->DET_TIPCOM	:= STRZERO(VAL(cTipDoc),3)
								DETCOM->DET_PUNVEN	:= cPedido 
								DETCOM->DET_NUMCOM	:= cNFiscal 
								DETCOM->DET_COD		:= TRBPER->F3_CLIEFOR
								DETCOM->DET_LOJA		:= TRBPER->F3_LOJA
								DETCOM->DET_FILIAL	:= TRBPER->F3_FILIAL
								DETCOM->DET_TIPROV	:= TRBPER->A2_TIPROV

								If SA2->(FieldPos("A2_AFIP")) > 0  .AND. Alltrim(TRBPER->A2_AFIP) $ "80|99"
									DETCOM->DET_CODVEN	:= TRBPER->A2_AFIP
								ElseIf SA2->(FieldPos("A2_AFIP")) > 0 
									DETCOM->DET_CODVEN	:= Substr(Posicione("SX5", 1, xFilial("SX5")+"OC" + TRBPER->A2_AFIP,"X5_DESCSPA"),1,2) 
								EndIf

								DETCOM->DET_NIDVEN	:= Iif(DETCOM->DET_CODVEN == "99",STRZERO(0,20),Replicate("0",20-LEN(ALLTRIM(TRBPER->A2_CGC))) + ALLTRIM(TRBPER->A2_CGC))
								DETCOM->DET_NOMBRE	:= SubStr(TRBPER->A2_NOME,1,30)
								
								If cNDocto <> cLlave
									Act3865(IIF(TRBPER->F3_EXENTAS <> 0,.T.,.F.),TRBPER->F3_TES,"DETCOM",;
									TRBPER->F3_NFISCAL,TRBPER->F3_SERIE,TRBPER->F3_CLIEFOR,TRBPER->F3_LOJA,TRBPER->F3_TIPOMOV,;
									aNrLvrIV,aNrLvIVA,aNrLvrGN,aNrLvrIB,aNrLvrMn,aNrLvrIn,aNrLvrIm,aNrLvrIip,aCodTab)
									cNDocto := cLlave
								EndIf 
								
								DETCOM->(MsUnlock())
								nImp++
							EndIf 
						EndIf 
						
						// Compras
						TRBPER->(DbSkip())
					Enddo
					
					If Substr(aCodTab[1][2],1,1) $ "C|T"
						nImp += CredFisSer(cPerini,cPerfin,aCodTab)
					EndIf
					RestArea(aAreaSF1)
					RestArea(aAreaSF2)
				EndIf
			EndIf

			//========================================================================================================================
			//RETENCAO
			//========================================================================================================================
			If (UPPER(cArquivo)$"IVARET|SIPRIB|SICORE|SILARPIB|DGR3027|SIAPRE|SIARE|RES28-97" .Or. (UPPER(cArquivo)$"SIRCAR".And. SubStr(aCodTab[1][3],1,1)=="1") .Or. (UPPER(cArquivo) $ "DGR19310" .And. SubStr(aCodTab[1][1],1,1)=="1")) .Or. ;
			   (UPPER(cArquivo)$"RES53-14" .And. Substr(aCodTab[1][2],1,1)=="R") .Or. (UPPER(cArquivo) $ "DGR55-11|STAC-AR" .And. SubStr(aCodTab[1][1],1,1) == "R" ) .And. lOk
				
				cSDoc := SerieNFID("SFE", 3, "FE_SERIE")				
				cQryRet:=" SELECT FE_NROCERT NUMCER, FE_NFISCAL DOC, FE_SERIE SERIE, FE_EMISSAO EMISSAO, FE_ORDPAGO ORDPAGO, FE_RECIBO RECIBO, FE_TIPO TP, "
			 
				cQryRet+=" FE_VALBASE VLRBAS, FE_VALIMP VLRIMP,FE_CFO CFO, FE_RETENC RETENCAO, FE_CONCEPT CONCEPT, FE_DTRETOR DTRETOR, FE_NRETORI NRETORI, "
			 
				cQryRet+=" FE_ALIQ ALIQ, FE_DTESTOR DTESTOR, FE_PARCELA PARCELA, FE_SIRECER SIRECER, "
				
				If TCGetDB() $ "ORACLE|POSTGRES"				
					cQryRet+=" CASE WHEN LENGTH(RTRIM(LTRIM(fe_forcond))) > 0 THEN fe_forcond ELSE fe_fornece END FORNECE, "             
					cQryRet+=" CASE WHEN LENGTH(RTRIM(LTRIM(fe_forcond))) > 0 THEN FE_LOJCOND ELSE fe_loja END LOJA, "				
				Else
					cQryRet+=" CASE WHEN LEN(RTRIM(LTRIM(fe_forcond))) > 0 THEN fe_forcond ELSE fe_fornece END FORNECE, "             
					cQryRet+=" CASE WHEN LEN(RTRIM(LTRIM(fe_forcond))) > 0 THEN FE_LOJCOND ELSE fe_loja END 'LOJA', "
				EndIf  
               
				cQryRet+=" FE_CLIENTE CLIENTE, FE_LOJCLI LOJCLI, FE_EST EST, FE_FORCOND, FE_PARCELA PARCELA "
				If !(cSDoc == "FE_SERIE")
					cQryRet+=" , " + cSDoc + "  "
				Else
					cSDoc := "SERIE"
				EndIf 
				If  UPPER(cArquivo)== "DGR3027" 
					cQryRet+=" ,COALESCE(A2_CGC,'') CUITF, COALESCE(A2_NROIB,'') INSCRIBF,COALESCE(A2_TIPO,'') TIPOF " 
				ElseIf (UPPER(cArquivo) $ "DGR19310" .And. SubStr(aCodTab[1][1],1,1)=="1")
					cQryRet+=" ,COALESCE(A2_COD,'') CODF,COALESCE(A2_CGC,'') CUITF, COALESCE(A2_NOME,'') NOMEA2, COALESCE(A2_NROIB,'') INSCRIBF, COALESCE(A2_END,'') DOMICIL, COALESCE(A2_MUN,'') LOCALI, COALESCE(A2_CEP,'') CODPOS "					
				Else
					cQryRet+=" ,COALESCE(A1_CGC,'') CUITC, COALESCE(A1_NOME,'') NOMEA1, COALESCE(A1_TIPO,'') TIPOC "
					cQryRet+=" ,COALESCE(A2_COD,'') CODF,COALESCE(A2_CGC,'') CUITF, COALESCE(A2_NOME,'') NOMEA2, COALESCE(A2_NROIB,'') INSCRIBF,COALESCE(A2_TIPO,'') TIPOF,COALESCE(A2_NATUREZ,'') NATUREZ " 
				EndIf
				cQryRet+=" FROM "+RetsqlName("SFE")+" SFE "    
				If  UPPER(cArquivo)== "DGR3027" .Or. (UPPER(cArquivo) $ "DGR19310" .And. SubStr(aCodTab[1][1],1,1)=="1")
					cQryRet+=" LEFT JOIN "+RetsqlName("SA2")+" SA2 ON "
					cQryRet+=" A2_FILIAL = '"+xFilial("SA2")+"' "
					cQryRet+=" AND FE_FORNECE=A2_COD "
					cQryRet+=" AND FE_LOJA=A2_LOJA "
					cQryRet+=" AND SA2.D_E_L_E_T_=''      
				Else
					cQryRet+=" LEFT JOIN "+RetsqlName("SA1")+" SA1 ON "
					cQryRet+=" A1_FILIAL = '"+xFilial("SA1")+"' "
					cQryRet+=" AND FE_CLIENTE=A1_COD "
					cQryRet+=" AND FE_LOJCLI=A1_LOJA "
					cQryRet+=" AND SA1.D_E_L_E_T_=''
					cQryRet+=" LEFT JOIN "+RetsqlName("SA2")+" SA2 ON "
					cQryRet+=" A2_FILIAL = '"+xFilial("SA2")+"' "
					cQryRet+=" AND FE_FORNECE=A2_COD "
					cQryRet+=" AND FE_LOJA=A2_LOJA "
					cQryRet+=" AND SA2.D_E_L_E_T_=''    
				EndIf
				cQryRet+=" WHERE SFE.D_E_L_E_T_='' "      
				
				If  UPPER(cArquivo)$"SIRCAR|IVARET|SICORE"
				   aAreaAt:=GetArea()
				   DbSelectArea("SFE")
					If MV_PAR06 == 1 .And. MV_PAR07 == 1  .And.  SFE->(ColumnPos('FE_MSFIL'))>0 .And.  !Empty(SFE->FE_MSFIL)
						For nProsFil:=1 to len(aFilsCalc)		 
							If  aFilsCalc[nProsFil,1] == .T.								
								IF nQtdFil==0				
									cQryRet+=" AND( FE_MSFIL = '"+aFilsCalc[nProsFil][2]+"' "
									nQtdFil:= nQtdFil+1									
								Else
									cQryRet+=" OR FE_MSFIL = '"+aFilsCalc[nProsFil][2]+"' "
								EndIf							
							EndIf
						Next nProsFil	
						cQryRet+=")"
					Elseif MV_PAR06 == 1 .And. MV_PAR07 == 1  .And. !SFE->(ColumnPos('FE_MSFIL'))>0
							For nProsFil:=1 to len(aFilsCalc)		 
							If aFilsCalc[nProsFil,1] == .T.								
								IF nQtdFil==0				
									cQryRet+=" AND( FE_FILIAL = '"+aFilsCalc[nProsFil][2]+"' "
									nQtdFil:= nQtdFil+1									
								Else
									cQryRet+=" OR FE_FILIAL = '"+aFilsCalc[nProsFil][2]+"' "
								EndIf							
							EndIf
						Next nProsFil	
						cQryRet+=")"						
					Elseif MV_PAR06 == 1 .and. MV_PAR07 == 2 .And.  SFE->(ColumnPos('FE_MSFIL'))>0 .And.  !Empty(SFE->FE_MSFIL)
							
							cQryRet+=" AND FE_MSFIL = '"+cfilant+"' "
						
					Elseif  SFE->(ColumnPos('FE_MSFIL'))>0 .And.  !Empty(SFE->FE_MSFIL) 
						cQryRet+=" AND FE_MSFIL = '"+FWCODFIL()+"' "
					Else		
						cQryRet+=" AND FE_FILIAL = '"+xFilial("SFE")+"' "
					EndIf	
					RestArea(aAreaAt)
				Else
					cQryRet+=" AND FE_FILIAL = '"+xFilial("SFE")+"' "
				EndIf
				
			
				If UPPER(cArquivo)=="IVARET"
					cQryRet+=" AND FE_NROCERT <> 'NORET' "
					cQryRet+=" AND FE_TIPO='I' "//I=I.V.A;B=Ingresos Brutos;G=Ganancias,Z-ISI
					cQryRet+=" AND FE_CLIENTE<>'' "
					cQryRet+=" AND FE_RETENC <> 0 "
				ElseIf UPPER(cArquivo)=="SIPRIB"
					cQryRet+=" AND FE_TIPO = 'B' "//I=I.V.A;B=Ingresos Brutos;G=Ganancias,Z-ISI
					cQryRet+=" AND FE_EST ='SF' "
					cQryRet+=" AND FE_VALIMP<>0 "
					cQryRet+=" AND FE_FORNECE <>'' "
				ElseIf UPPER(cArquivo)=="SICORE"
					cQryRet+=" AND FE_TIPO IN('G'"
					If (Len(aCodTab[1]) < 8) .Or. (Len(aCodTab[1]) >= 8 .and. SubStr(aCodTab[1][8],1,1)=="1")
						cQryRet+=",'I'"
					EndIf
					cQryRet+=") "
					cQryRet+=" AND FE_NROCERT <> 'NORET' "
					cQryRet+=" AND FE_RETENC <> 0 "
					cQryRet+=" AND FE_FORNECE <>'' "
					cQryRet+=" AND A2_TIPO <> 'E' "      
					cQryPer+=" AND F3_DTCANC = '' "				
				ElseIf UPPER(cArquivo)=="SIRCAR"
					cQryRet+=" AND FE_NROCERT <> 'NORET' "
					cQryRet+=" AND FE_TIPO = 'B' "//I=I.V.A;B=Ingresos Brutos;G=Ganancias,Z-ISI
					cQryRet+=" AND FE_EST = '"+aCodTab[1][4]+"' "
					cQryRet+=" AND FE_FORNECE <> ' ' "				
				ElseIf UPPER(cArquivo)=="SILARPIB"
					cQryRet+=" AND FE_TIPO = 'B' "//I=I.V.A;B=Ingresos Brutos;G=Ganancias,Z-ISI
					cQryRet+=" AND FE_FORNECE <>'' "
					cQryRet+=" AND FE_NROCERT <> 'NORET' "
					cQryRet+=" AND FE_RETENC <> 0 "  
					cQryRet+=" AND FE_EST = 'CO' "
				ElseIf UPPER(cArquivo)=="DGR3027"
					cQryRet+=" AND FE_TIPO = 'B' "//I=I.V.A;B=Ingresos Brutos;G=Ganancias,Z-ISI
					cQryRet+=" AND FE_EST = '"+aCodTab[1][1]+"' "
					cQryRet+=" AND FE_VALIMP<>0 "
					cQryRet+=" AND FE_FORNECE <>'' "
				ElseIf UPPER(cArquivo)=="SIAPRE"
					cQryRet+=" AND FE_CLIENTE<>''"
					cQryRet+=" AND FE_EST='TU'"
					cQryRet+=" AND FE_TIPO='B'" 
				ElseIf UPPER(cArquivo) == "DGR55-11"
					cQryRet+=" AND FE_TIPO = 'B' " //I=I.V.A;B=Ingresos Brutos;G=Ganancias,Z-ISI
					cQryRet+=" AND FE_EST = '" + aCodTab[1][3] + "' "
				ElseIf UPPER(cArquivo) == "STAC-AR"
					cQryRet+=" AND FE_TIPO = 'B' " //I=I.V.A;B=Ingresos Brutos;G=Ganancias,Z-ISI
					cQryRet+=" AND FE_EST = '" + aCodTab[1][3] + "' "
					cQryRet+=" AND FE_FORNECE <>'' "
					cQryRet+=" AND FE_NROCERT <> 'NORET' "
					cQryRet+=" AND FE_RETENC <> 0 "					
				ElseIf UPPER(cArquivo)=="RES53-14"
					cQryRet+=" AND FE_TIPO = 'M' " //M=Municipal 
					cQryRet+=" AND FE_EST  = 'CO' AND FE_EST = '"+ aCodTab[1][1] + "' "
					cQryRet+=" AND FE_FORNECE <> ' ' " 
					cQryRet+=" AND FE_RETENC <> 0 "						
				ElseIf UPPER(cArquivo)=="SIARE"
					cQryRet+=" AND FE_TIPO = 'B' "
					cQryRet+=" AND FE_EST = 'JU' "
				ElseIf UPPER(cArquivo)=="RES28-97"
					cQryRet+=" AND FE_TIPO = 'B' "
					cQryRet+=" AND FE_EST = 'FO' "														
				ElseIf (UPPER(cArquivo) $ "DGR19310" .And. SubStr(aCodTab[1][1],1,1)=="1")
					cQryRet+=" AND FE_TIPO = 'B' "
					cQryRet+=" AND FE_EST = '" + aCodTab[2][1] + "' "
					cDtIni := Iif(aCodTab[2][3] == "1", Substr(aCodTab[2][2],3,4) + Substr(aCodTab[2][2],1,2) + "01",Substr(aCodTab[2][2],3,4) + Substr(aCodTab[2][2],1,2) + "16")
					cDtFim := Iif(aCodTab[2][3] == "1", Substr(aCodTab[2][2],3,4) + Substr(aCodTab[2][2],1,2) + "15",Substr(aCodTab[2][2],3,4) + Substr(aCodTab[2][2],1,2) + FLastDay(aCodTab[2][2]))					
				EndIf
				If UPPER(cArquivo)=="SIAPRE" .or. UPPER(cArquivo)=="RES28-97" .Or. (UPPER(cArquivo) $ "DGR19310" .Or. UPPER(cArquivo)=="SIARE" .And. SubStr(aCodTab[1][1],1,1)=="1") .Or. UPPER(cArquivo)=="RES53-14"
					cQryRet	+= 		" AND (FE_DTESTOR <'" + cDtIni+ "' OR "
					cQryRet	+=		" FE_DTESTOR >'" + cDtFim+ "' OR "
					cQryRet	+=		" FE_DTESTOR = ' ' OR "
					cQryRet	+=		" FE_NRETORI <> ' ' "        //Significa que es Ret. Anulada
					cQryRet	+=		") AND "
					cQryRet	+=		"( "
					cQryRet	+=		"FE_DTRETOR <'" + cDtIni+ "' OR "
					cQryRet	+=		"FE_DTRETOR >'" + cDtFim+ "' OR "
					cQryRet	+=		"FE_DTRETOR = ' ' OR "
					cQryRet	+=		"FE_NRETORI = ' ' "
					cQryRet	+=		") "
				EndIf				
				cQryRet+=" AND FE_EMISSAO BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "
				If UPPER(cArquivo)=="SIRCAR"
					cQryRet+=" ORDER BY FE_TIPO,FE_CLIENTE,FE_RECIBO,FE_NROCERT,FE_EMISSAO,FE_DTRETOR"
				EndIf  
				If UPPER(cArquivo) == "DGR3027" .Or. UPPER(cArquivo) == "RES53-14" .Or. UPPER(cArquivo) == "STAC-AR"
					cQryRet+=" ORDER BY FE_NROCERT "
				EndIf
				If Select("TRBRET")>0
					DbSelectArea("TRBRET")
					TRBRET->(DbCloseArea())
				EndIf
			
				cTRBRET := ChangeQuery(cQryRet)
				dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBRET ) ,"TRBRET", .T., .F.)
			
				DbSelectArea("TRBRET")
				TRBRET->(dbGoTop())	
				If TRBRET->(!Eof())
					nAnulac:=0
					Aadd(aLogreg,Replicate("=",80))
					Aadd(aLogreg,STR0016+" "+cArquivo)//RETENCAO
					Aadd(aLogreg,Replicate("=",80))
					Do While TRBRET->(!Eof()) .And. lOk
					
						If TRBRET->RETENCAO >= 0 .And. (TRBRET->DTESTOR >= cDtIni .And. TRBRET->DTESTOR <= cDtFim)
							TRBRET->(DbSkip())
							Loop
						ElseIf TRBRET->RETENCAO < 0 .And. (TRBRET->DTRETOR >= cDtIni .And. TRBRET->DTRETOR <= cDtFim)
							TRBRET->(DbSkip())
							Loop
						EndIf
					
						If UPPER(cArquivo)$"IVARET|SIPRIB|SIRCAR"
							DbSelectArea("CCP")
							CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
							CCP->(DbGoTop())
							If DbSeek(xFilial("CCP")+AvKey(aCodTab[1][1],"CCP_COD")+AvKey(TRBRET->CFO,"CCP_VORIGE"))
								If UPPER(cArquivo)=="SIPRIB"
									cCodTab1:=""
									Do While CCP->(!Eof()) .And. Alltrim(aCodTab[1][1])==Alltrim(CCP->CCP_COD)
										If Alltrim(TRBRET->CFO) == Alltrim(CCP->CCP_VORIGE) 
											cCodTab1:=Alltrim(CCP->CCP_VDESTI)
										EndIf
										CCP->(DbSkip())
									End
								ELse
									cCodTab1:=Alltrim(CCP->CCP_VDESTI)
								EndIf
							EndIf
							If Empty(cCodTab1)
								DbSeek(xFilial("CCP")+AvKey(aCodTab[1][1],"CCP_COD"))
								Aadd(aLogreg,STR0017+SPACE(1)+Iif(cArquivo == "IVARET",TRBRET->SIRECER,TRBRET->NUMCER))//"Numero Certificado:"
								Aadd(aLogreg,STR0014+SPACE(1)+TRBRET->CFO+SPACE(1)+STR0015+SPACE(1)+aCodTab[1][1]+" "+CCP->CCP_DESCR)//"Codigo CFO:"#" nao possui codigo equivalente na Tabela de Equivalencia"
							EndIf
						EndIf
						If UPPER(cArquivo)$"SIPRIB"
							cCodTab2:=""
							DbSelectArea("CCP")//TABELA DE EQUIVALENCIA
							CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
							CCP->(DbGoTop())
							If DbSeek(xFilial("CCP")+Avkey(aCodTab[1][2],"CCP_COD")+AvKey(TRBRET->CFO,"CCP_VORIGE"))//SEGUNDA TABELA DE EQUIVALENCIA
								cCodTab2 := AllTrim(CCP->CCP_VDESTI)
							Else
								If Ascan(aChave,{|x| Alltrim(x[1])==Alltrim(aCodTab[1][2])+Alltrim(TRBRET->CFO)})==0
									Aadd(aChave,{Alltrim(aCodTab[1][2])+Alltrim(TRBRET->CFO)})
									DbSeek(xFilial("CCP")+Avkey(aCodTab[1][2],"CCP_COD"))
									Aadd(aLogreg,STR0017+SPACE(1)+TRBRET->NUMCER)//"Numero Certificado:"
									Aadd(aLogreg,STR0014+SPACE(1)+TRBRET->CFO+SPACE(1)+STR0015+Space(1)+aCodTab[1][2]+"-"+CCP->CCP_DESCR)//"Codigo CFO:"#" nao possui codigo equivalente na Tabela de Equivalencia"
								EndIf
							EndIf
						ElseIf UPPER(cArquivo)$"SILARPIB"
							DbSelectArea("CCP")//TABELA DE EQUIVALENCIA
							CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
							CCP->(DbGoTop())
							cCodTab2:=""
							If DbSeek(xFilial("CCP")+Avkey(aCodTab[1][2],"CCP_COD")+AvKey(TRBRET->CFO,"CCP_VORIGE"))
								cCodTab2  := Substr(Alltrim(CCP->CCP_VDESTI),1,2)
							EndIf
						EndIf
					
						If UPPER(cArquivo)$"SILARPIB"
							DbSelectArea("CCP")//TABELA DE EQUIVALENCIA
							CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
							CCP->(DbGoTop())
							cCodTab3  := ""
							If DbSeek(xFilial("CCP")+Avkey(aCodTab[1][3],"CCP_COD")+AvKey(TRBRET->CFO,"CCP_VORIGE"))
								cCodTab3 := Substr(Alltrim(CCP->CCP_VDESTI),1,2)
							EndIf
						EndIf
		
						nVlrIVa:=0
						nBasIVa:=0
						nRetIVa:=0
						cCondIB1:=""
					
						If UPPER(cArquivo)=="IVARET"
							DbSelectArea("IVARET")
							IVARET->(dbSetOrder(1))//RET_DOC+RET_SERIE+RET_FORN+RET_LOJA+RET_TIPO
							IVARET->(dbGoTop())
							If !Empty(TRBRET->CUITF) .And. DbSeek(TRBRET->DOC+TRBRET->SERIE+TRBRET->FORNECE+TRBRET->LOJA+"F")
								RecLock("IVARET",.F.)
								IVARET->RET_VLRRET := Transform(Val(IVARET->RET_VLRRET)+TRBRET->RETENCAO,"@E 9999999999999.99")
							ElseIf !Empty(TRBRET->CUITC) .And. DbSeek(TRBRET->DOC+TRBRET->SERIE+TRBRET->CLIENTE+TRBRET->LOJCLI+"C")
								RecLock("IVARET",.F.)
								IVARET->RET_VLRRET := Transform(Val(IVARET->RET_VLRRET)+TRBRET->RETENCAO,"@E 9999999999999.99")
							Else
								nImp++
								RecLock("IVARET",.T.)
								IVARET->RET_CODRET := SubStr(cCodTab1,1,3)
								IVARET->RET_CUIT   := Transform(Iif(!Empty(TRBRET->CUITC),TRBRET->CUITC,TRBRET->CUITF),"@R XX-XXXXXXXX-X")												  //Formato Valido **99999999999, 99*99999999*9 ou 99-99999999-9
								IVARET->RET_EMISS  := Substr(TRBRET->EMISSAO,7,2)+"/"+Substr(TRBRET->EMISSAO,5,2)+"/"+Substr(TRBRET->EMISSAO,1,4)//Formato Valido DD/MM/AAAA ou DD-MM-AAAA
								IVARET->RET_NUMCER := TRBRET->SIRECER
								IVARET->RET_DOC    := TRBRET->RECIBO								
								IVARET->RET_SERIE  := TRBRET->&cSDoc
								IVARET->RET_FORN   := Iif(!Empty(TRBRET->CUITC),TRBRET->CLIENTE,TRBRET->FORNECE)
								IVARET->RET_LOJA   := Iif(!Empty(TRBRET->CUITC),TRBRET->LOJCLI,TRBRET->LOJA)
								IVARET->RET_VLRRET := Transform(TRBRET->RETENCAO,"@E 9999999999999.99")
								IVARET->RET_TIPO   := Iif(!Empty(TRBRET->CUITC),"C","F")
							EndIf
							IVARET->(MsUnlock())
						ElseIf UPPER(cArquivo)=="SIPRIB"
							If Substr(aCodTab[1][3],1,1)=="1" .Or. Substr(aCodTab[1][3],1,1)=="3"//Retencao ou Ambos
								//SITUACAO frente a IVA(0-No Corresponde,1-Responsable inscripto,2-Responsable no Inscripto,3-exento,4-Monotributo)
								//A2_TIPO->I=Resp.Insc.;N=Resp.nao Insc.;X=Isento;E=Fornecedor do Exterior;S=Nao Sujeito;M=Monotributarista
								cCondIB1 := BuscaSFH(AvKey(TRBRET->FORNECE,"FH_FORNECE"), AvKey(TRBRET->LOJA,"FH_LOJA"),"IBR",1,@lImp)
								If TRBRET->TIPOF=="I"
									cSitIva:="1"
								ElseIf TRBRET->TIPOF=="N"
									cSitIva:="2"
								ElseIf TRBRET->TIPOF=="X"
									cSitIva:="3"
								ElseIf TRBRET->TIPOF=="M"
									cSitIva:="4"
								Else
									cSitIva:="0"
								EndIf
								//TIPO COMPROVANTE
								//01	Factura
								//02	Nota de Débito
								//03	Orden de Pago
								//04	Boleta de depósito
								//05	Liquidación de pago	
								//06	Certificado de Obra
								//07	Recibo FE_RECIBO
								//08	Constancia de Retención
								//09	Otro comprobante
								cTipCom:=""
								cLetCom:=""
								If TRBRET->RETENCAO>0
									cTipCom:="03"
								ElseIf !Empty(TRBRET->ORDPAGO)
									cTipCom:="03"
								ElseIf !Empty(TRBRET->RECIBO)
									cTipCom:="03"
								ElseIf !Empty(TRBRET->DOC) .And. TRBRET->VLRIMP>=0
									cTipCom:="01"
									cLetCom:="A"
									If !Empty(Alltrim(TRBPER->SERIE))										
										cLetCom:=UPPER(Alltrim(TRBPER->&cSDoc))
									EndIf
								ElseIf !Empty(TRBRET->DOC) .And. TRBRET->VLRIMP<0
									cTipCom:="02"
								Else
									cTipCom:="09"
								EndIf

								nVlrIva:=0
								DbSelectArea("SF1")
								SF1->(DbSetOrder(1))//F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
								If DbSeek(xFilial("SF1")+AvKey(TRBRET->DOC,"F1_DOC")+AvKey(TRBRET->SERIE,"F1_SERIE")+AvKey(TRBRET->FORNECE,"F1_FORNECE")+AvKey(TRBRET->LOJA,"F1_LOJA"))
									If Len(aNrLvrIV)>0
										For nImpNF:=1 To Len(aNrLvrIV)
											nVlrIva+=&("SF1->F1_VALIMP"+aNrLvrIV[nImpNF][2])
										Next
									EndIf
								EndIf
															 
								nImp++
								DbSelectArea("SIPRIB")
								RecLock("SIPRIB",.T.)
								SIPRIB->SIP_TIPOPE:="1"                 //Tipo Operacion - Retencion
								SIPRIB->SIP_EMISS :=Substr(TRBRET->EMISSAO,7,2)+"/"+Substr(TRBRET->EMISSAO,5,2)+"/"+Substr(TRBRET->EMISSAO,1,4)//Fecha de Retencion-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
								SIPRIB->SIP_CODART:=SUBSTR(cCodTab1,1,3)//Codigo Articulo inciso por el que retiene
								SIPRIB->SIP_TIPCOM:=cTipCom            //Tipo de Comprobante
								SIPRIB->SIP_LETCOM:=cLetCom             //Letra de Comprobante
								If cTipCom=="03"
									SIPRIB->SIP_NUMCOM:=TRBRET->ORDPAGO
								Else
									SIPRIB->SIP_NUMCOM:=Substr(TRBRET->NUMCER,1,4)+Substr(TRBRET->EMISSAO,1,4)+Substr(TRBRET->NUMCER,(TamSx3("FE_NROCERT")[1]-7),TamSx3("FE_NROCERT")[1])   //Numero de Comprobante
								EndIf
								SIPRIB->SIP_NUMCOM:=PADL(Alltrim(SIPRIB->SIP_NUMCOM),Len(SIPRIB->SIP_NUMCOM)," ")
								SIPRIB->SIP_DATCOM:=Substr(TRBRET->EMISSAO,7,2)+"/"+Substr(TRBRET->EMISSAO,5,2)+"/"+Substr(TRBRET->EMISSAO,1,4)//Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
								If cTipCom=="03"
									DbSelectArea("SEK")
									SEK->(DbSetOrder(1)) //EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ+R_E_C_N_O_+D_E_L_E_T_ 
									If SEK->(DbSeek(xFilial("SEK") + TRBRET->ORDPAGO))
										While SEK->(!Eof()) 
											If  TRBRET->ORDPAGO == SEK->EK_ORDPAGO .AND. TRBRET->FORNECE == SEK->EK_FORNECE  .and. TRBRET->LOJA == SEK->EK_LOJA .and. SEK->EK_TIPO $ ("IB-")
												SIPRIB->SIP_VLRCOM :=  PADL(Alltrim(Transform(SEK->EK_VALOR,"@E 999999999.99")),Len(SIPRIB->SIP_VLRCOM),"0")
												Exit
											EndIf
											SEK->(DbSkip())
										Enddo
									EndIf
									SEK->(dbCloseArea())
								Else
									SIPRIB->SIP_VLRCOM:=PADL(Alltrim(Transform(TRBRET->VLRBAS,"@E 999999999.99")),Len(SIPRIB->SIP_VLRCOM),"0")//Monto de Comprobante
								EndIf
								SIPRIB->SIP_TIPDOC:="3"                 //Tipo de Documento(1-C.D.I->CHAVE DE INDENTIFICACAO|2-C.U.I.L->CODIGO UNICO DE IDENTIFICACAO LABORAL|3-C.U.I.T.->CHAVE UNICA DE IDENTIFICACAO TRIBUTARIA)
								SIPRIB->SIP_NUMDOC:=TRBRET->CUITF       //Numero del documento
								SIPRIB->SIP_CONFIB:=cCondIB1            //Condicion frente a Ingressos brutos
								SIPRIB->SIP_NUMIIB:=Iif(cCondIB1=="1",Substr(Alltrim(TRBRET->INSCRIBF),1,10),Replicate("0",10))//Numero de inscripcion en Ingressos Brutos
								SIPRIB->SIP_SITIVA:=cSitIva//Situacion frente a Iva
								SIPRIB->SIP_INSOGR:="0"//Marca Inscripcion Otros Gravamenes
								SIPRIB->SIP_INSDRE:="0"//Marca Inscripcion DRel
								SIPRIB->SIP_IMPOGR:= PADL(Alltrim(Transform(0,"@E 999999999.99")),Len(SIPRIB->SIP_IMPOGR),"0")//Importe Otros Gravamenes
								SIPRIB->SIP_IMPIVA:= PADL(Alltrim(Transform(nVlrIva,"@E 999999999.99")),Len(SIPRIB->SIP_IMPIVA),"0")//Iif(cSitIva=="1",Transform(nVlrIva,"@E 999999999.99"),Transform(0,"@E 999999999.99"))//Importe IVA- percepcao
								SIPRIB->SIP_BSCALC:= PADL(Alltrim(Transform(TRBRET->VLRBAS,"@E 999999999.99")),Len(SIPRIB->SIP_BSCALC),"0")//Base imponible para el calculo
								SIPRIB->SIP_ALIQUO:= PADL(Alltrim(Transform(TRBRET->ALIQ,"@E 99.99")),Len(SIPRIB->SIP_ALIQUO),"0")//Alicuota
								SIPRIB->SIP_IMDET:= PADL(Alltrim(Transform(TRBRET->RETENCAO,"@E 999999999.99")),Len(SIPRIB->SIP_IMDET),"0")//Impuesto Determinado
								SIPRIB->SIP_REGINS:= PADL(Alltrim(Transform(0,"@E 999999999.99")),Len(SIPRIB->SIP_REGINS),"0")//Derecho Registro e Inspeccion
								SIPRIB->SIP_VLRRET:=PADL(Alltrim(Transform(TRBRET->RETENCAO,"@E 999999999.99")),Len(SIPRIB->SIP_VLRRET),"0")//Monto Retenido
								SIPRIB->SIP_ARTCAL:=SUBSTR(cCodTab2,1,3)//Articulo/Inciso para el calculo
								cTipExc := "0"
								cQueryAuxi := "Select FH_ISENTO, FH_PERCENT, FH_IMPOSTO, FH_ZONFIS, FH_INIVIGE, FH_DECRETO from " + RetSqlName("SFH") + " SFH Where FH_FORNECE = '" + TRBRET->FORNECE + "' AND FH_TIPO = '" + TRBRET->TIPOF + "' AND FH_LOJA = '" + TRBRET->LOJA + "' AND  (FH_INIVIGE = '' OR FH_INIVIGE <= '" + cDtIni + "') AND  (FH_FIMVIGE = '' OR FH_FIMVIGE >= '" + cDtFim + "')"
								cAliasAux := CriaTrab(nil, .f.)
								cQueryAuxi 	:= 	ChangeQuery(cQueryAuxi)
								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryAuxi),cAliasAux,.F.,.T.)
								If (cAliasAux)->FH_ISENTO == "N" .AND. (cAliasAux)->FH_PERCENT == 0 .AND. ( (cAliasAux)->FH_IMPOSTO == "IBR" .OR. (cAliasAux)->FH_IMPOSTO == "IBK") .AND. (cAliasAux)->FH_ZONFIS == "SF"
									cTipExc := "0"// Tipo de Excención
								ElseIf (cAliasAux)->FH_ISENTO == "N" .AND. (cAliasAux)->FH_PERCENT <> 0 .AND.  (cAliasAux)->FH_IMPOSTO == "IBR" .AND. (cAliasAux)->FH_ZONFIS == "SF"
									cTipExc := "1"// Tipo de Excención
								ElseIf (cAliasAux)->FH_ISENTO == "S" .AND. (cAliasAux)->FH_IMPOSTO == "IBR" .AND. (cAliasAux)->FH_ZONFIS == "SF"
									cTipExc := "2"// Tipo de Excención
								ElseIf (cAliasAux)->FH_ISENTO == "N" .AND. (cAliasAux)->FH_PERCENT <> 0 .AND.  (cAliasAux)->FH_IMPOSTO == "IBK" .AND. (cAliasAux)->FH_ZONFIS == "SF"
									cTipExc := "3"// Tipo de Excención
								ElseIf (cAliasAux)->FH_ISENTO == "S" .AND.  (cAliasAux)->FH_IMPOSTO == "IBK" .AND. (cAliasAux)->FH_ZONFIS == "SF"
									cTipExc := "4"// Tipo de Excención
								EndIf
								
								SIPRIB->SIP_TIPEXE := cTipExc
								If cTipExc == "1" .OR. cTipExc == "2" .OR. cTipExc == "3"
									SIPRIB->SIP_EMISSE := SUBSTR((cAliasAux)->FH_INIVIGE ,1,4) //Año de Excención
								Else
									SIPRIB->SIP_EMISSE := "0000" //Año de Excención
								EndIf
								If cTipExc == "1" .OR. cTipExc == "2" .OR. cTipExc == "3"
									SIPRIB->SIP_NUMCEE := Trim((cAliasAux)->FH_DECRETO) //Número de Certificado de Excención
								Else
									SIPRIB->SIP_NUMCEE := space(6) //TRBRET->NUMCER  Número de Certificado de Excención 
								EndIf
							(cAliasAux)->(dbCloseArea())
							SIPRIB->SIP_NUMCEP:= Iif(Len(Alltrim(TRBRET-> NUMCER)) > 12, SUBSTR(TRBRET-> NUMCER ,(Len(Alltrim(TRBRET-> NUMCER)) - 12)+1,12),TRBRET-> NUMCER)
								SIPRIB->(MsUnlock())
							EndIf
						ElseIf UPPER(cArquivo)=="SICORE"
							nImporte	:=0
							cCodCFO		:=""
							cCodCon		:=""
							cCodEst		:=""
							cCodTip		:=""
							cConcepto	:=""
							//Codigo Regime
							cCodTab1:=""
							DbSelectArea("CCP")
							CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
							CCP->(DbGoTop())
							If DbSeek(xFilial("CCP")+AvKey(aCodTab[1][2],"CCP_COD")+AvKey(Iif(TRBRET->TP=="G",TRBRET->CONCEPT,TRBRET->CFO),"CCP_VORIGE"))
								cCodTab1:=Alltrim(CCP->CCP_VDESTI)
							EndIf
							If !Empty(TRBRET->FORNECE)
								DbSelectArea("SA2")
								SA2->(DbSetOrder(1))								
								If (!Empty(TRBRET->FE_FORCOND) .And. (SA2->(DbSeek(xFilial("SA2")+AvKey(TRBRET->FE_FORCOND,"A2_COD")+AvKey(TRBRET->LOJA,"A2_LOJA")))));
								.Or.;
								(Empty(TRBRET->FE_FORCOND) .And. (SA2->(DbSeek(xFilial("SA2")+AvKey(TRBRET->FORNECE,"A2_COD")+AvKey(TRBRET->LOJA,"A2_LOJA")))))							
									cCodEst :=SA2->A2_EST
									cCodTip := SA2->A2_TIPO
									cCUITFor:= SubStr( SA2->A2_CGC, 1, 11 )
									cRazSoc := SubStr( SA2->A2_NOME,1, 20)
									cDomic  := SubStr( SA2->A2_END, 1, 20 )
									cCiudad := SubStr( SA2->A2_MUN, 1, 20 )
									cCP     := SubStr(SA2->A2_CEP,1,8)
									If cCodTip == 'I'
										cCodCon := '01'
									Else
										cCodCon := '02'
									EndIf
								EndIf
							EndIf
							If Empty(cRazSoc)
								DbSelectArea("SA1")
								SA1->(DbSetOrder(1))
								If SA1->(DbSeek(xFilial("SA1")+AvKey(TRBRET->CLIENTE,"A1_COD")+AvKey(TRBRET->LOJCLI,"A1_LOJA")))
									cCodEst :=SA1->A1_EST
									cCodTip :=SA1->A1_TIPO
									cCUITFor:= SubStr( SA1->A1_CGC, 1, 11 )
									cRazSoc := SubStr( SA1->A1_NOME,1, 20)
									cDomic  := SubStr( SA1->A1_END, 1, 20 )
									cCiudad := SubStr( SA1->A1_MUN, 1, 20 )
									cCP     := SubStr(SA1->A1_CEP,1,8)
									If cCodTip == 'I'
										cCodCon := '01'
									Else
										cCodCon := '02'
									EndIf
								EndIf
							EndIf
							//Provincia
							cCodTab2:=""
							DbSelectArea("CCP")
							CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
							CCP->(DbGoTop())
							If DbSeek(xFilial("CCP")+AvKey(aCodTab[1][4],"CCP_COD")+AvKey(cCodEst,"CCP_VORIGE"))
								cCodTab2:=Alltrim(CCP->CCP_VDESTI)
							EndIf

							If Empty(cCodTab1) .Or. Empty(cCodTab2)
								If !Empty(TRBRET->FORNECE)
									Aadd(aLogreg,STR0019+SPACE(1)+TRBRET->FORNECE+SPACE(1)+STR0020+TRBRET->LOJA+":")//"Fornecedor:"#"Loja:"
								Else
									Aadd(aLogreg,STR0038+SPACE(1)+TRBRET->CLIENTE+SPACE(1)+STR0020+TRBRET->LOJCLI+":")//"Fornecedor:"#"Loja:"
								EndIf
								If Empty(cCodTab1)
									Aadd(aLogreg,TRBRET->CONCEPT+"-"+STR0035)//"Codigo Concepto nao cadastrado na Tabela Codigo Regime"
								EndIf
								If Empty(cCodTab2)
									Aadd(aLogreg,cCodEst+"-"+STR0036)//"Provincia nao cadastrado na Tabela Codigo Provincia"
								EndIf
							EndIf
	    				
							If !Empty(TRBRET->ORDPAGO)
								cTipCom:="06"
								If Empty(cCodTab1)
									Aadd(aLogreg,STR0022+TRBRET->NUMCER+Space(1)+STR0037+TRBRET->ORDPAGO)//"Ordem Pago:"
								EndIf
							Else
								cTipCom:="01"
								If Empty(cCodTab1)
									Aadd(aLogreg,STR0022+TRBRET->NUMCER+Space(1)+STR0023+TRBRET->DOC)
								EndIf
							EndIf
	
							nImp++
							SICORE->(dbSetOrder(1)) //SIC_TIPCOM+SIC_NUMCOM+SIC_EMISS -
							SICORE->(dbGoTop())
						
							RecLock("SICORE",.T.)
								SICORE->SIC_TIPCOM:=Iif(TRBRET->RETENCAO>=0,cTipCom,"03") //Codigo del comprobante
								SICORE->SIC_EMISS :=Substr(TRBRET->EMISSAO,7,2)+"/"+Substr(TRBRET->EMISSAO,5,2)+"/"+Substr(TRBRET->EMISSAO,1,4) //Fecha de emision del comprobante //Fecha de Retencion-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
								SICORE->SIC_NUMCOM:=StrZero(Val(TRBRET->ORDPAGO),16)  //Numero del comprobante
								SICORE->SIC_VLRNET:=StrTran(StrZero(nImporte,16,2), ".", "," )//Importe del comprante (ceros)
								SICORE->SIC_CODIMP:=Iif(TRBRET->TP == "G", "0217", "0767" )   //Codigo de impuesto
								SICORE->SIC_CODREG:=cCodTab1//Codigo de regimen
								SICORE->SIC_CODOPE:="1"   //Codigo de operacion
								SICORE->SIC_VLRBAS:=Iif(SICORE->SIC_TIPCOM=="03",StrTran(StrZero(Iif(TRBRET->RETENCAO<0,(TRBRET->RETENCAO*-1),TRBRET->RETENCAO),14,2), ".", "," ),StrTran(StrZero(Iif(TRBRET->VLRBAS<0,(TRBRET->VLRBAS*-1),TRBRET->VLRBAS),14,2), ".", "," ))   //Base de Calculo
								SICORE->SIC_DATRET:=Substr(TRBRET->EMISSAO,7,2)+"/"+Substr(TRBRET->EMISSAO,5,2)+"/"+Substr(TRBRET->EMISSAO,1,4)   //Fecha de emisión de la retencion (DD/MM/YYYY) //Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
								SICORE->SIC_CODREG:=cCodTab1//Codigo de regimen
								nbusca := aScan(aCond,{|x| x[1] == Alltrim(cCodTab1)})
								If nbusca > 0
									cCodCon :=aCond[nbusca][2]
								EndIf
								SICORE->SIC_CODCON:=cCodCon   //Codigo de condicion
								SICORE->SIC_RETSUS:="0"      //Retencion practicada a sujetos suspendidos segun:
								SICORE->SIC_IMPRET:=Iif(SICORE->SIC_TIPCOM=="03",StrTran(StrZero(0,14,2), ".", "," ),StrTran(StrZero(Iif(TRBRET->RETENCAO<0,(TRBRET->RETENCAO*-1),TRBRET->RETENCAO), 14, 2 ), ".", "," ))  //Importe de la retención
								SICORE->SIC_PORCEX:="000,00"  //Porcentaje de exclusion
								SICORE->SIC_DATBOL:="01/12/1998"  //Fecha de emisión del boletín
								SICORE->SIC_TIPDOC:="80"      //Tipo de documentos del retenido
								SICORE->SIC_NUMCUI:=PadR(Alltrim(cCuitFor), 20) //Numero de documento del retenido
								SICORE->SIC_NUMCOR:=StrZero(Val(TRBRET->NRETORI),14)  //Numero de certificado original
								SICORE->SIC_RAZSOC:=cRazSoc
								SICORE->SIC_ENDER :=cDomic
								SICORE->SIC_CIDADE:=cCiudad
								SICORE->SIC_PROVIN:=cCodTab2
								SICORE->SIC_CEP   :=cCp
							SICORE->(MsUnlock())						
							dbSelectArea("SUJRET")
							SUJRET->(dbSetOrder(1))
							SUJRET->(dbGoTop())
							If !SUJRET->(dbSeek(Iif(!Empty(TRBRET->FORNECE),"F","C")+Iif(!Empty(TRBRET->FORNECE),SubStr(TRBRET->FORNECE,1,6),SubStr(TRBRET->CLIENTE,1,6))+Iif(!Empty(TRBRET->FORNECE),SubStr(TRBRET->LOJA,1,6),SubStr(TRBRET->LOJCLI,1,6))))
								//If !empty(cLojaCF)								
									If RecLock("SUJRET",.T.)
										DbSelectArea("SA2")
										SA2->(DbSetOrder(1))									
										SUJRET->SJR_TIPO   := Iif(!Empty(TRBRET->FORNECE),"F","C")  
										If (!Empty(TRBRET->FE_FORCOND) .And. (SA2->(DbSeek(xFilial("SA2")+AvKey(TRBRET->FE_FORCOND,"A2_COD")+AvKey(TRBRET->LOJA,"A2_LOJA")))));
										.Or.;
										(Empty(TRBRET->FE_FORCOND) .And. (SA2->(DbSeek(xFilial("SA2")+AvKey(TRBRET->FORNECE,"A2_COD")+AvKey(TRBRET->LOJA,"A2_LOJA")))))										
											SUJRET->SJR_CLIENT := SA2->(A2_COD) //Iif(!Empty(TRBRET->FORNECE),TRBRET->FORNECE,TRBRET->CLIENTE)  
										EndIf   
										SUJRET->SJR_LOJA   := Iif(!Empty(TRBRET->FORNECE),TRBRET->LOJA,TRBRET->LOJCLI)
										SUJRET->SJR_TIPDOC := "80"
										SUJRET->SJR_NUMCUI := PadR(Alltrim(cCuitFor),20)
										SUJRET->SJR_RAZSOC := cRazSoc
										SUJRET->SJR_ENDER  := cDomic
										SUJRET->SJR_CIDADE := cCiudad
										SUJRET->SJR_PROVIN := cCodTab2
										SUJRET->SJR_CEP    := cCp
										SUJRET->(MsUnlock())
									EndIf
								//EndIf
							EndIf
						ElseIf Upper(cArquivo) == "SIRCAR" .And. SubStr(aCodTab[1][3],1,1) == "1"  //Retencao
							cTipCom := "1"
							
							dbSelectArea("SIRRET")
							If TRBRET->RETENCAO < 0 .And. !Empty(TRBRET->DTRETOR)
								cTipCom := "2"
							EndIf
							If UPPER(ACODTAB[1][4]) == "CO"							 
								
								cNumCon:= "01"+ Substr(TRBRET->EMISSAO,3,2) + Substr(TRBRET->NUMCER,5,10)	     // SIRRET->RET_NUCONS
		 						cCuit:=  TRBRET->CUITF       //  SIRRET->RET_CUIT 
								
								If AllTrim(SIRRET->RET_NUCONS)+AllTrim(SIRRET->RET_CUIT)+AllTrim(SIRRET->RET_TIPCOM) != AllTrim(cNumCon)  + AllTrim(cCuit) + AllTrim(cTipCom)
									nBaseSIRCAR := TRBRET->VLRBAS
									nValSIRCAR  := TRBRET->RETENCAO
									nAliSIRCAR  := TRBRET->ALIQ
									If RecLock("SIRRET",.T.)
										SIRRET->RET_NUMREG := StrZero(Recno(),5)
										SIRRET->RET_ORICOM := "1"
										SIRRET->RET_TIPCOM := cTipCom
										SIRRET->RET_NUMCOM := PadL(AllTrim(Transform(0, "@R 9999999999999")), 13, "0") //Monto de Comprobante
										SIRRET->RET_CUIT   := cCuit           //TRBRET->CUITF
										SIRRET->RET_DATRET := Substr(TRBRET->EMISSAO,7,2)+"/"+Substr(TRBRET->EMISSAO,5,2)+"/"+Substr(TRBRET->EMISSAO,1,4)//Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA										
										SIRRET->RET_ALIRET := PadL(AllTrim(Transform(TRBRET->ALIQ,"@R 999.99")), 6, "0")
										If nValSIRCAR >= 0
										SIRRET->RET_VLRTOT := PadL(AllTrim(Transform(nValSIRCAR * Iif(nValSIRCAR < 0,-1,1),"@R 999999999.99")), 12, "0")
										SIRRET->RET_VLRRET := PadL(AllTrim(Transform(nBaseSIRCAR * Iif(nBaseSIRCAR < 0,-1,1),"@R 999999999.99")), 12, "0")//Monto de Comprobante
										Else
										SIRRET->RET_VLRTOT := "-" + PadL(AllTrim(Transform(nValSIRCAR * Iif(nValSIRCAR < 0,-1,1),"@R 999999999.99")), 11, "0")
										SIRRET->RET_VLRRET := "-" + PadL(AllTrim(Transform(nBaseSIRCAR * Iif(nBaseSIRCAR < 0,-1,1),"@R 999999999.99")), 11, "0")//Monto de Comprobante0")
										Endif
										SIRRET->RET_TIPRET := cCodTab1
										SIRRET->RET_JURISD := "9"+Posicione("CCO",1,xFilial("CCO")+aCodTab[1][4],"CCO_CODJUR")
										SIRRET->RET_TIPOPE := "1"
										SIRRET->RET_FECHEC := Substr(TRBRET->EMISSAO,7,2)+"/"+Substr(TRBRET->EMISSAO,5,2)+"/"+Substr(TRBRET->EMISSAO,1,4)//Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										SIRRET->RET_NUCONS := cNumCon     //  "01"+ Substr(TRBRET->EMISSAO,3,2) + Substr(TRBRET->NUMCER,5,10)	 
										SIRRET->RET_NUCONO := "0"
										SIRRET->(MsUnlock())
										nImp++
									EndIf
								Else
									nBaseSIRCAR += TRBRET->VLRBAS
									nValSIRCAR  += TRBRET->RETENCAO
									nAliSIRCAR  := TRBRET->ALIQ
									If RecLock("SIRRET",.F.)
										SIRRET->RET_VLRRET := PadL(AllTrim(Transform(nBaseSIRCAR * Iif(nBaseSIRCAR < 0,-1,1),"@R 999999999.99")), 12, "0")//Monto de Comprobante
										SIRRET->RET_VLRTOT := PadL(AllTrim(Transform(nValSIRCAR * Iif(nValSIRCAR < 0,-1,1),"@R 999999999.99")), 12, "0")
										SIRRET->(MsUnlock())
									EndIf
								EndIf
							Else
							
							
								cNumCer:=  SubStr(TRBRET->NUMCER,1,4)+SubStr(TRBRET->NUMCER,7,8)						     // SIRRET->RET_NUMCOM  
								cCuit:= TRBRET->CUITF
								If AllTrim(SIRRET->RET_NUMCOM)+AllTrim(SIRRET->RET_CUIT)+AllTrim(SIRRET->RET_TIPCOM)   <>      AllTrim(cNumCer)+    AllTrim(cCuit)+AllTrim(cTipCom)
									nBaseSIRCAR := TRBRET->VLRBAS
									nValSIRCAR  := TRBRET->RETENCAO
									nAliSIRCAR  := TRBRET->ALIQ
									If RecLock("SIRRET",.T.)
										SIRRET->RET_NUMREG := StrZero(Recno(),5)
										SIRRET->RET_ORICOM := "1"
										SIRRET->RET_TIPCOM := cTipCom
										SIRRET->RET_NUMCOM :=   cNumCer    //  SubStr(TRBRET->NUMCER,1,4)+SubStr(TRBRET->NUMCER,7,8)//Numero de Comprobante
										SIRRET->RET_CUIT   := cCuit    //TRBRET->CUITF
										SIRRET->RET_DATRET := Substr(TRBRET->EMISSAO,7,2)+"/"+Substr(TRBRET->EMISSAO,5,2)+"/"+Substr(TRBRET->EMISSAO,1,4)//Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										SIRRET->RET_VLRRET := PadL(AllTrim(Transform(nBaseSIRCAR,"@R 999999999.99")), 12, "0")//Monto de Comprobante
										SIRRET->RET_ALIRET := PadL(AllTrim(Transform(TRBRET->ALIQ,"@R 999.99")), 6, "0")
										SIRRET->RET_VLRTOT := PadL(AllTrim(Transform(nValSIRCAR,"@R 999999999.99")), 12, "0")
										SIRRET->RET_TIPRET := cCodTab1
										SIRRET->RET_JURISD := "9"+Posicione("CCO",1,xFilial("CCO")+aCodTab[1][4],"CCO_CODJUR")									
										SIRRET->(MsUnlock())
										nImp++
									EndIf
								Else
									nBaseSIRCAR += TRBRET->VLRBAS
									nValSIRCAR  += TRBRET->RETENCAO
									nAliSIRCAR  := TRBRET->ALIQ
									If RecLock("SIRRET",.F.)
										SIRRET->RET_VLRRET := PadL(AllTrim(Transform(nBaseSIRCAR * Iif(nBaseSIRCAR < 0,-1,1),"@R 999999999.99")), 12, "0")//Monto de Comprobante
										SIRRET->RET_VLRTOT := PadL(AllTrim(Transform(nValSIRCAR * Iif(nValSIRCAR < 0,-1,1),"@R 999999999.99")), 12, "0")
										SIRRET->(MsUnlock())
									EndIf
								EndIf
							EndIf
						
						ElseIf UPPER(cArquivo)=="SILARPIB"
							cTipo:="3"
							cCodTab1:=""
							cTpRecaud := "1" 
							cQueryAuxi:= ""  
							cAliasAux := ""
	        				nRegs     := 0							
	        
							DbSelectArea("SA2")
							SA2->(DbSetOrder(1))
							SA2->(DbGoTop())
							If SA2->(DbSeek(xFilial("SA2")+AvKey(TRBRET->FORNECE,"A2_COD")+AvKey(TRBRET->LOJA,"A2_LOJA")))
								CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
								CCP->(DbGoTop())
								If CCP->(DbSeek(xFilial("CCP")+Avkey(aCodTab[1][1],"CCP_COD")+AvKey(SA2->A2_EST,"CCP_VORIGE")))
									cCodTab1:=Substr(Alltrim(CCP->CCP_VDESTI),1,2)
								EndIf
								If Ascan(aCNPJ,{|x| Alltrim(x[1])==Alltrim(TRBRET->CUITF)})==0
									Aadd(aCNPJ,{Alltrim(TRBRET->CUITF),cTipo,SA2->A2_NOME,SA2->A2_NROIB,SA2->A2_END,SA2->A2_BAIRRO,SA2->A2_MUN,SA2->A2_CEP,cCodTab1})
								EndIf
								
								cQueryAuxi := "SELECT * FROM " + RetSqlName("SFH") + " SFH Where FH_FORNECE = '" + TRBRET->FORNECE + "' AND FH_LOJA = '" + TRBRET->LOJA + "' AND FH_TIPO = 'V' AND SFH.D_E_L_E_T_=''  "
								cQueryAuxi += " AND  (FH_INIVIGE = '' OR FH_INIVIGE >= '" + cDtIni + "') AND  (FH_FIMVIGE = '' OR FH_FIMVIGE <= '" + cDtFim + "') AND FH_IMPOSTO = 'IBR' AND FH_ZONFIS <> 'CO' "  
								cAliasAux  := CriaTrab(nil, .f.)
								cQueryAuxi := ChangeQuery(cQueryAuxi)
								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryAuxi),cAliasAux,.F.,.T.) 
								COUNT TO nRegs
								(cAliasAux)->(dbCloseArea()) 								
								
								If  SA2->A2_EST <> "CO" .OR. nRegs>0
									cTpRecaud := "4"
								EndIf
							EndIf
							cTipComp := ""
							cNumComp := ""
	
							If !Empty(TRBRET->ORDPAGO)
								cTipComp:="2"
								cNumComp:=TRBRET->ORDPAGO
							ElseIf !Empty(TRBRET->RECIBO)
								cTipComp:="4"
								cNumComp:=TRBRET->RECIBO
							ElseIf !Empty(TRBRET->DOC)
								cTipComp:="1"
								cNumComp:=TRBRET->DOC
							EndIf
	
							//total de la retencion					
							If TRBRET->RETENCAO <> 0 .and. Empty(TRBRET->DTESTOR)
								DbSelectArea("S02")
								If !DbSeek("  "+("01"+SUBSTR(ALLTRIM(STR(YEAR(DDATABASE))),3,2)+StrZero(Val(TRBRET->NUMCER),10))+Transform(TRBRET->CUITF,"@R XX-XXXXXXXX-X"))
									nImp++
									If RecLock("S02",.T.)
										S02->S02_CODOPE := StrZero(nCodOpeNR,8)
										S02->S02_IDENT  :="01"
										S02->S02_TIPRET := cTpRecaud
										S02->S02_CONRET :=Iif(Empty(cCodTab2),TRBRET->CFO,cCodTab2)
										S02->S02_FECRET :=Substr(TRBRET->EMISSAO,7,2)+"/"+Substr(TRBRET->EMISSAO,5,2)+"/"+Substr(TRBRET->EMISSAO,1,4)//Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										S02->S02_FECEMI :=Substr(TRBRET->EMISSAO,7,2)+"/"+Substr(TRBRET->EMISSAO,5,2)+"/"+Substr(TRBRET->EMISSAO,1,4)//Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										S02->S02_NUMCON :="01"+SUBSTR(ALLTRIM(STR(YEAR(DDATABASE))),3,2)+SubStr((TRBRET->NUMCER),5,10)
										S02->S02_CUIT   :=Transform(TRBRET->CUITF,"@R XX-XXXXXXXX-X")
										S02->S02_BAS2   := TRBRET->VLRBAS
										S02->S02_BASRET :=Transform(S02->S02_BAS2,"@E 9999999999.99")
										S02->S02_ALIQ   :=Transform(TRBRET->ALIQ,"@E 999.9999")
										S02->S02_IMP2  := TRBRET->VLRIMP
										S02->S02_IMPRET :=Transform(Abs(S02_IMP2),"@E 99999999.99")
									EndIf
									If RecLock("S02",.T.)
										S02->S02_CODOPE := StrZero(nCodOpeNR,8)
										S02->S03_IDENT  :="02"
										S02->S03_TIPRET :=cTipComp
										S02->S03_LETFAT :="O"
										S02->S03_NUMCOM :=cNumComp
										S02->S03_FECCOM :=Substr(TRBRET->EMISSAO,7,2)+"/"+Substr(TRBRET->EMISSAO,5,2)+"/"+Substr(TRBRET->EMISSAO,1,4)//Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										S02->S03_RETENC :="1"
										S02->S03_ANULAC :="0"
										S02->(MsUnlock())
									EndIf
									nCodOpeNR++
								Else
									RecLock("S02",.F.)
									S02->S02_BAS2    := S02->S02_BAS2 + TRBRET->VLRBAS
									S02->S02_IMP2    := S02->S02_IMP2 + TRBRET->VLRIMP
									S02->S02_BASRET  :=Transform(Abs(S02->S02_BAS2),"@E 9999999999.99")
									S02->S02_IMPRET  := Transform(Abs(S02->S02_IMP2),"@E 99999999.99")
									S02->(MsUnlock())
								EndIf
							EndIf
							If TRBRET->RETENCAO < 0 .and. (!Empty(TRBRET->DTESTOR))
								nImp++
								nAnulac++
								DbSelectArea("S04")
								If !DbSeek("  "+("01"+SUBSTR(ALLTRIM(STR(YEAR(DDATABASE))),3,2)+StrZero(Val(TRBRET->NUMCER),10))+Transform(TRBRET->CUITF,"@R XX-XXXXXXXX-X"))
									If RecLock("S04",.T.)
										S04->S04_CODOPE := StrZero(nCodOpeAR,8)
										S04->S04_IDENT  :="03"
										S04->S04_NUMANU :="01"+SUBSTR(ALLTRIM(STR(YEAR(DDATABASE))),3,2)+StrZero(Val(TRBRET->NUMCER),10)
										S04->S04_FECANU :=Substr(TRBRET->EMISSAO,7,2)+"/"+Substr(TRBRET->EMISSAO,5,2)+"/"+Substr(TRBRET->EMISSAO,1,4)//Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										S04->S04_CONANU :="1" //cCodTab3
										S04->S04_NUMCON :=TRBRET->NRETORI
										S04->S04_IMP2   := TRBRET->RETENCAO
										S04->S04_IMPRET :=Transform(Abs(S04->S04_IMP2),"@E 99999999.99")
										S04->S04_FECRET :=Substr(TRBRET->DTRETOR,7,2)+"/"+Substr(TRBRET->DTRETOR,5,2)+"/"+Substr(TRBRET->DTRETOR,1,4)//Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										S04->S04_IMPN2  := TRBRET->RETENCAO
										S04->S04_IMPANU :=Transform(Abs(S04->S04_IMPN2),"@E 99999999.99")
										S04->S04_CUIT   :=Transform(TRBRET->CUITF,"@R XX-XXXXXXXX-X")
										S04->(MsUnlock())
									EndIf
									DbSelectArea("S04")
									If RecLock("S04",.T.)
										S04->S04_CODOPE := StrZero(nCodOpeAR,8)
										S04->S03_IDENT  :="02"
										S04->S03_TIPRET :=cTipComp
										S04->S03_LETFAT :="O"
										S04->S03_NUMCOM :=cNumComp
										S04->S03_FECCOM :=Substr(TRBRET->EMISSAO,7,2)+"/"+Substr(TRBRET->EMISSAO,5,2)+"/"+Substr(TRBRET->EMISSAO,1,4)//Fecha de Comprobante-Formato Valido DD/MM/AAAA ou DD-MM-AAAA
										S04->S03_RETENC :="0"
										S04->S03_ANULAC :="1"
										S04->(MsUnlock())
									EndIf
									nCodOpeAR++
								Else
									RecLock("S04",.F.)
									S04->S04_IMP2    := S04->S04_IMP2 + TRBRET->RETENCAO
									S04->S04_IMPN2   := S04->S04_IMPN2 + TRBRET->RETENCAO
									S04->S04_IMPRET  := Transform(Abs(S04->S04_IMP2),"@E 99999999.99")
									S04->S04_IMPANU  := Transform(Abs(S04->S04_IMPN2),"@E 99999999.99")
									S04->(MsUnlock())
								EndIf
							EndIf
						ElseIf Upper(cArquivo) == "DGR3027" 
							DbSelectArea("SA2")
							SA2->(DbSetOrder(1))
							SA2->(DbGoTop())
							If  SA2->(DbSeek(xFilial("SA2")+AvKey(TRBRET->FORNECE,"A2_COD")+AvKey(TRBRET->LOJA,"A2_LOJA")))
								cDGRNome := SA2->A2_NOME 
								cDGRCGC  := SA2->A2_CGC 
								cDGREnd  := SA2->A2_END		
								cDGRNIGB := SA2->A2_NIGB
							EndIf

							nRetAdc := EsImpAdc(TRBRET->CFO,TRBRET->EST)                            
                                                        
							DGR3027->(dbSetOrder(1)) //RET_NROCER
							DGR3027->(dbGoTop())
							If  DGR3027->(!DbSeek(TRBRET->NUMCER)) 
								RecLock("DGR3027",.T.)
								DGR3027->RET_RAZSOC:=cDGRNome //Razon social/Nombre del sujeto retenido
								DGR3027->RET_CUIT  :=cDGRCGC  //Numero de CUIT del sujeto retenido 
								DGR3027->RET_ENDERE:=cDGREnd  //Domicilio Fiscal del sujeto retenido
								DGR3027->RET_NIGB  :=cDGRNIGB //Numero de inscripci´'on en el impuesto sobre los IIBB
								DGR3027->RET_NROCER:=TRBRET->NUMCER //Numero de certificado
								DGR3027->RET_EMISSA:=Substr(TRBRET->EMISSAO,7,2)+"/"+Substr(TRBRET->EMISSAO,5,2)+"/"+Substr(TRBRET->EMISSAO,1,4) //Fecha de Retencion-Formato Valido DD/MM/AAAA 
								DGR3027->RET_VALBAS:=Transform(TRBRET->VLRBAS,"@E 999999999.99") //Base imponible
								DGR3027->RET_ALIQ  :=Transform(TRBRET->ALIQ,"@E 999.99")         //Aliquota
								DGR3027->RET_RETEN :=Transform(Iif(nRetAdc==1,TRBRET->RETENCAO,0),"@E 999999999.99") //Importe sobre ingresos brutos
								DGR3027->RET_RETENA:=Transform(Iif(nRetAdc==2,TRBRET->RETENCAO,0),"@E 999999999.99") //Importe sobre ingresos brutos -Lote Hogar-
								DGR3027->(MsUnlock())       
								nImp++
							Else
								RecLock("DGR3027",.F.)
								DGR3027->RET_ALIQ  :=Transform(VAL(DGR3027->RET_ALIQ) + TRBRET->ALIQ,"@E 999.99")    //Aliquota
								DGR3027->RET_RETEN :=Transform(VAL(DGR3027->RET_RETEN)+Iif(nRetAdc==1,TRBRET->RETENCAO,0),"@E 999999999.99")  //Importe sobre ingresos brutos
								DGR3027->RET_RETENA:=Transform(VAL(DGR3027->RET_RETENA)+Iif(nRetAdc==2,TRBRET->RETENCAO,0),"@E 999999999.99")  //Importe sobre ingresos brutos -Lote Hogar-
								DGR3027->(MsUnlock())
							EndIf	
						ElseIf UPPER(cArquivo)$"SIAPRE"
						
							If Substr(aCodTab[1][1],1,1)=="1"
							
								//Contribuyentes Locales - Percepciones
								DbSelectArea("SIAPRERP")
								SIAPRERP->(dbSetOrder(1))
								SIAPRERP->(dbGoTop())
								If SIAPRERP->(!DbSeek(TRBRET->CUITC + Substr(TRBRET->EMISSAO,7) + "/" + Substr(TRBRET->EMISSAO,5,2) + "/" + Substr(TRBRET->EMISSAO,1,4) + " " + " " + SUBSTR(AllTrim(TRBRET->NUMCER),1,4) + SUBSTR(AllTrim(TRBRET->NUMCER),Len(AllTrim(TRBRET->NUMCER))-7)))
									RecLock("SIAPRERP",.T.)
										SIAPRERP->SIA_CUIT		:= TRBRET->CUITC //Cuit
										SIAPRERP->SIA_RAZSOC		:= TRBRET->NOMEA1 //Razon Social
										SIAPRERP->SIA_FCHCOM		:= Substr(TRBRET->EMISSAO,7) + "/" + Substr(TRBRET->EMISSAO,5,2) + "/" + Substr(TRBRET->EMISSAO,1,4) //Fecha de percepcion
										SIAPRERP->SIA_TPOCBT		:= " " //Tipo de comprobate
										SIAPRERP->SIA_LETRA		:= " " //Letra de comprobante
										SIAPRERP->SIA_TRMINL		:= "0000" //Terminal
										SIAPRERP->SIA_NUMERO		:= Right(AllTrim(TRBRET->RECIBO),8)//Constancia
										SIAPRERP->SIA_IMPCOM		:= StrTran(StrZero(TRBRET->RETENCAO,18,2),".",",") //Valor del importe retenido/percibido
										SIAPRERP->SIA_CODRP		:= "R" //Codigo de retencion/percepcion
										SIAPRERP->SIA_IMPSTO		:= "11" //Impuesto
								
									SIAPRERP->(MsUnlock())
									nImp++
								EndIf
							Else
								//Contribuyentes del Convenio Multilateral - Archivo de Retenciones 
								DbSelectArea("SIAPRECMR")
								SIAPRECMR->(dbSetOrder(1))
								SIAPRECMR->(dbGoTop())
								If SIAPRECMR->(!DbSeek("9" + cCodJur + TRANSFORM(TRBRET->CUITC,"@R 99-99999999-9") + Substr(TRBRET->EMISSAO,7) + "/" + Substr(TRBRET->EMISSAO,5,2) + "/" + Substr(TRBRET->EMISSAO,1,4) + SUBSTR(TRBRET->NUMCER,1,4) + SUBSTR(AllTrim(TRBRET->NUMCER),Len(AllTrim(TRBRET->NUMCER))-7)))
									RecLock("SIAPRECMR",.T.)
										SIAPRECMR->SIA_CODJUR	:= "9" + cCodJur //Codigo de jurisdiccion
										SIAPRECMR->SIA_CUITAG	:= TRANSFORM(TRBRET->CUITC,"@R 99-99999999-9") //Cuit de Agente
										SIAPRECMR->SIA_FCHRET	:= Substr(TRBRET->EMISSAO,7) + "/" + Substr(TRBRET->EMISSAO,5,2) + "/" + Substr(TRBRET->EMISSAO,1,4) //Fecha de Retencion
										SIAPRECMR->SIA_NUMSUC	:= SUBSTR(AllTrim(TRBRET->NUMCER),1,4) //Numero de sucursal
										SIAPRECMR->SIA_NUMCON	:= SUBSTR(AllTrim(TRBRET->NUMCER),Len(AllTrim(TRBRET->NUMCER))-7)//Numero de constancia
										SIAPRECMR->SIA_TPOCOM	:= "R" //Tipo de comprobante
										SIAPRECMR->SIA_LTACOM	:= "C" //Letra de comprobante
										SIAPRECMR->SIA_NCOMPO	:= AllTrim(TRBRET->RECIBO) //Original
										SIAPRECMR->SIA_IMPRET	:= StrTran(StrZero(TRBRET->RETENCAO,11,2),".",",") //Importe retenido
									
									SIAPRECMR->("SIAPRECMR",.T.)
									nImp++
								EndIf
							EndIf
						ElseIf UPPER(cArquivo) $ "DGR55-11|STAC-AR" .And. Substr(aCodTab[1][1],1,1)=="R" //Retenciones de IIBB de la Provincia de Rio Negro / Santa Cruz						    
						    lDG5511 := .F.
						    cTbequi := Iif(UPPER(cArquivo) == "DGR55-11","CPRN",AvKey(aCodTab[1][4],"CCP_COD")) // Tabla de equivalencia
						    cCerti  := Iif(Len(Alltrim(TRBRET-> NUMCER)) > 13, SUBSTR(TRBRET-> NUMCER ,(Len(Alltrim(TRBRET-> NUMCER)) - 13)+1,13),TRBRET-> NUMCER)
					   		If AllTrim(TRBRET->DTESTOR) == "" 
					   			lDG5511 := .T.
					   		ElseIf Substr(TRBRET->EMISSAO,5,2) <> Substr(TRBRET->DTESTOR,5,2)
					   			lDG5511 := .T.
					   		EndIf
						
							If lDG5511 
								If DGRETE->(!DbSeek(AllTrim(TRBRET->NUMCER)+AllTrim(TRBRET->RECIBO)+TRBRET->CUITF))
									nConcept := ""
									CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
									CCP->(DbGoTop())
									If CCP->(DbSeek(xFilial("CCP") + cTbequi + AvKey(TRBRET->NATUREZ,"CCP_VORIGE"))) 
										nConcept:=Substr(Alltrim(CCP->CCP_VDESTI),1,2)
									EndIf
									//Retenciones Efectuadas
									DbSelectArea("DGRETE")
									DGRETE->(dbSetOrder(1))
									DGRETE->(dbGoTop())
									If (UPPER(cArquivo) == "STAC-AR") .And. (cCertRet == cCerti)
										If DGRETE->(DbSeek(cCertRet))
											RecLock("DGRETE",.F.)
												DGRETE->DGR_BASERE	:= StrTran(StrZero(Val(StrTran(DGRETE->DGR_BASERE, ",", ".")) + TRBRET->VLRBAS,15,2),".",",")
												DGRETE->DGR_IMPRET	:= StrTran(StrZero(Val(StrTran(DGRETE->DGR_IMPRET, ",", ".")) + TRBRET->RETENCAO,15,2),".",",")
											DGRETE->(MsUnlock())
										EndIf
									Else 
										RecLock("DGRETE",.T.)
											DGRETE->DGR_CONCEP	:= nConcept
											DGRETE->DGR_FCHRET	:= Substr(TRBRET->EMISSAO,7) + "/" + Substr(TRBRET->EMISSAO,5,2) + "/" + Substr(TRBRET->EMISSAO,1,4)
											DGRETE->DGR_NROCON	:= Iif(UPPER(cArquivo) == "DGR55-11",AllTrim(TRBRET->NUMCER),cCerti)
											DGRETE->DGR_TIPCON	:= "02"
											DGRETE->DGR_LETRA		:= "O"
											DGRETE->DGR_NROCOM	:= AllTrim(TRBRET->RECIBO)
											DGRETE->DGR_CUIT		:= AllTrim(TRBRET->CUITF)
											DGRETE->DGR_BASERE	:= StrTran(StrZero(TRBRET->VLRBAS,15,2),".",",")
											DGRETE->DGR_ALICUO	:= StrTran(StrZero(TRBRET->ALIQ,5,2),".",",")
											DGRETE->DGR_IMPRET	:= StrTran(StrZero(TRBRET->RETENCAO,15,2),".",",")
										
										DGRETE->(MsUnlock())
									nImp++
									EndIf
									PadCP(TRBRET->CUITF,aCodTab[1][3],2,TRBRET->FORNECE,TRBRET->LOJA,cDtFim,aCodTab[1][2],cArquivo)
									If UPPER(cArquivo) == "STAC-AR"
										cCertRet := cCerti
									EndIf
								EndIf			
							EndIf
							
							lDG5511 := .F.
					   		If AllTrim(TRBRET->DTESTOR) <> "" .And. Substr(TRBRET->DTRETOR,5,2) <> Substr(TRBRET->DTESTOR,5,2)
					   			lDG5511 := .T.
					   		EndIf 
					   		If UPPER(cArquivo) == "STAC-AR" .and. lDG5511 == .T. .AND. SUBSTR(cDtIni,5,2) <> Substr(TRBRET->DTESTOR,5,2) 
					   			lDG5511 := .F.
					   		Endif
					   		
					   		If lDG5511 
								If DGRETA->(!DbSeek(AllTrim(TRBRET->NUMCER)+AllTrim(TRBRET->NRETORI)+AllTrim(TRBRET->CUITF)))
									//Retenciones Anuladas
									DbSelectArea("DGRETA")
									DGRETA->(dbSetOrder(1))
									DGRETA->(dbGoTop())
									RecLock("DGRETA",.T.)
										DGRETA->DGR_FCHANU	:= Substr(TRBRET->EMISSAO,7) + "/" + Substr(TRBRET->EMISSAO,5,2) + "/" + Substr(TRBRET->EMISSAO,1,4)
										DGRETA->DGR_NROCOA	:= Iif(UPPER(cArquivo) == "DGR55-11",AllTrim(TRBRET->NUMCER),cCerti)
										DGRETA->DGR_MONANU	:= StrTran(StrZero(ABS(TRBRET->VLRBAS),15,2),".",",")
										DGRETA->DGR_NROCOR	:= AllTrim(TRBRET->NRETORI)
										DGRETA->DGR_FCHREA	:= Substr(TRBRET->DTRETOR,7) + "/" + Substr(TRBRET->DTRETOR,5,2) + "/" + Substr(TRBRET->DTRETOR,1,4)
										DGRETA->DGR_MONREA	:= StrTran(StrZero(ABS(TRBRET->RETENCAO),15,2),".",",")
										DGRETA->DGR_CUIT		:= AllTrim(TRBRET->CUITF)
									
									DGRETA->(MsUnlock())
									nImp++
									PadCP(TRBRET->CUITF,aCodTab[1][3],2,TRBRET->FORNECE,TRBRET->LOJA,cDtFim,aCodTab[1][2],cArquivo)
								EndIf
							EndIf
						ElseIf UPPER(cArquivo)$"RES53-14" .And. SubStr(aCodTab[1][2],1,1)=="R" //Percepciones y Retenciones de la Municipalidad de Cordoba			    						    
						    cDomc := ""
						    cMun  := ""
						    cCep  := ""
						    cNome := ""	  
							cCUITFor:= ""
							dFchUlt := CTOD("//") 	 
							cFchPri := ""  	   
										    
						    If !Empty(TRBRET->FORNECE)   
								DbSelectArea("SA2")
								SA2->(DbSetOrder(1)) //"A2_FILIAL+A2_COD+A2_LOJA"								
								If  SA2->(DbSeek(xFilial("SA2")+AvKey(TRBRET->FORNECE,"A2_COD")+AvKey(TRBRET->LOJA,"A2_LOJA")))															    
								    cDomc 	:= SA2->A2_END
								    cMun  	:= Iif(!EMPTY(Alltrim(SA2->A2_BAIRRO)),Alltrim(SA2->A2_BAIRRO) +" ","") + Alltrim(SA2->A2_MUN)
								    cCep  	:= SA2->A2_CEP
								    cNome 	:= SA2->A2_NOME	  
								    cCUITFor:= SA2->A2_CGC 
								    dFchUlt := SA2->A2_ULTCOM 
								EndIf  								
								cFchPri := ObtRFchIni(AvKey(TRBRET->FORNECE,"A2_COD"),AvKey(TRBRET->LOJA,"A2_LOJA"))  //Obtener fecha de Primera Retencion para el Impuesto y Municipalidad													
							EndIf
						                                 
							DbSelectArea("RES5314")
							RES5314->(dbSetOrder(1))
							RES5314->(dbGoTop())
							If  RES5314->(!DbSeek(StrZero(Year(STOD(TRBRET->EMISSAO)),4)+"-"+RIGHT("000000"+TRIM(TRBRET->NUMCER),6)+Substr(cCUITFor,1,2)+Substr(cCUITFor,3,8)+Substr(cCUITFor,11,1)+ StrZero(TRBRET->ALIQ *100,5))) 	 							
								//Percepciones Efectuadas
								RecLock("RES5314",.T.)       
								RES5314->MUN_TPOREG := "2"
								RES5314->MUN_TCUITA	:= Substr(SM0->M0_CGC,1,2)
								RES5314->MUN_NCUITA	:= Substr(SM0->M0_CGC,3,8)
								RES5314->MUN_VCUITA	:= Substr(SM0->M0_CGC,11,1)
								RES5314->MUN_PERIOD	:= StrZero(Year(STOD(TRBRET->EMISSAO)),4)+StrZero(Month(STOD(TRBRET->EMISSAO)),2)
								RES5314->MUN_NOCOMP	:= StrZero(Year(STOD(TRBRET->EMISSAO)),4)+"-"+RIGHT("000000"+TRIM(TRBRET->NUMCER),6)
								RES5314->MUN_PTPAGO	:= "1"                                                       
								RES5314->MUN_COMORI	:=  TRBRET->ORDPAGO //TRIM(TRBRET->SERIE)+TRBRET->DOC
								RES5314->MUN_TCUITR := Substr(cCUITFor,1,2) 
								RES5314->MUN_NCUITR := Substr(cCUITFor,3,8)
								RES5314->MUN_VCUITR := Substr(cCUITFor,11,1)
								RES5314->MUN_VALBAS := StrZero(ABS(TRBRET->VLRBAS) *100,15)
								RES5314->MUN_ALICUO := StrZero(TRBRET->ALIQ *100,5)
								RES5314->MUN_VALRET := StrZero(ABS(TRBRET->RETENCAO) *100,15)
								RES5314->MUN_EDOCOM := Iif((AllTrim(TRBRET->DTESTOR)=="" .And. AllTrim(TRBRET->NRETORI)="".And. (TRBRET->VLRBAS)<0),"N",Iif((AllTrim(TRBRET->DTESTOR)<>"" .And. AllTrim(TRBRET->NRETORI)<>""),"B","A") )      //A=Activo; B=Anulado; N=Nota de Credito
								RES5314->MUN_FCHRET	:= StrZero(Year(STOD(TRBRET->EMISSAO)),4)+StrZero(Month(STOD(TRBRET->EMISSAO)),2)+StrZero(Day(STOD(TRBRET->EMISSAO)),2)
								RES5314->MUN_FCHANU	:= StrZero(Year(STOD(TRBRET->DTESTOR)),4)+StrZero(Month(STOD(TRBRET->DTESTOR)),2)+StrZero(Day(STOD(TRBRET->DTESTOR)),2)
								RES5314->MUN_NOME	:= cNome
								RES5314->MUN_END	:= cDomc
								RES5314->MUN_NUM	:= ""
								RES5314->MUN_PISO	:= ""
								RES5314->MUN_DEPTO	:= ""
								RES5314->MUN_BAIRRO	:= cMun
								RES5314->MUN_CEP	:= cCep
								If !Empty(cFchPri)
									RES5314->MUN_FCHINI	:= StrZero(Year(STOD(cFchPri)),4)+StrZero(Month(STOD(cFchPri)),2)+StrZero(Day(STOD(cFchPri)),2)
								EndIf
								If !Empty(dFchUlt)
									RES5314->MUN_FCHFIN	:= StrZero(Year(dFchUlt),4)+StrZero(Month(dFchUlt),2)+StrZero(Day(dFchUlt),2)
								EndIf
 								RES5314->(MsUnlock()) 
								nImp++
							Else //Existe pero las alicuotas son iguales, entonces que se acumule
								If  Alltrim(StrZero(TRBRET->ALIQ *100,5)) == Alltrim( RES5314->MUN_ALICUO)
									RecLock("RES5314",.F.)       
									RES5314->MUN_VALBAS := StrZero(((TRBRET->VLRBAS) *100)+val(RES5314->MUN_VALBAS),15)
									RES5314->MUN_ALICUO := StrZero(TRBRET->ALIQ *100,5)
									RES5314->MUN_VALRET := StrZero(((TRBRET->RETENCAO) *100)+val(RES5314->MUN_VALRET),15)
	 								RES5314->(MsUnlock()) 									       
								EndIf
							EndIf														
						ElseIf UPPER(cArquivo)$"SIARE" //Retenciones IIBB de la provincia de Jujuy
							DbSelectArea("SI1")
							SI1->(dbSetOrder(1))
							SI1->(dbGoTop())
							If SI1->(!DbSeek(RIGHT(TRBRET->NUMCER,6)+TRBRET->ORDPAGO))
							cCodAct := ""
							cCodAct := POSICIONE("CCP",1,xFilial("CCP")+ AvKey(aCodTab[1][1],"CCP_COD") + AvKey(TRBRET->CFO,"CCP_VORIGE"),"CCP_VDESTI")
								RecLock("SI1",.T.)
									SI1_NRO1 := SM0->M0_CGC
									SI1_NRO2 := TRBRET->CUITF
									SI1_NRO3 := RIGHT(TRBRET->NUMCER,6)
									SI1_NRO4 := SUBSTR(TRBRET->EMISSAO,1,4)
									SI1_FECHA := SUBSTR(TRBRET->EMISSAO,7,2)+ "/"+SUBSTR(TRBRET->EMISSAO,5,2)+ "/"+SUBSTR(TRBRET->EMISSAO,1,4)
									SI1_BASE := ALLTRIM(STR(TRBRET->VLRBAS,11,2))
									nBase:= Val(SI1_BASE)
									SI1_ALIC := ALLTRIM(STR(TRBRET->ALIQ,5,2))
									SI1_RETEN := ALLTRIM(STR(TRBRET->RETENCAO,11,2))
									nSoma := Val(SI1_RETEN)
									SI1_CODIMP := IIF(Empty(TRBRET->DTRETOR),"0","9") //
									SI1_CODACT := cCodAct 
									SI1_CANTFA := "1"
									SI1_NROFAC := TRBRET->ORDPAGO
									SI1_SUC := FWFilial() //
									SI1_NROICP := TRBRET->INSCRIBF
									SI1_IMP := Substr(ALLTRIM(STR(SuperGetMV("MV_RG99401",.T.,"0"))),1,1)
								SI1->(MsUnlock())
								
								DbSelectArea("SI2")
								SI2->(dbSetOrder(1))
								SI2->(dbGoTop())
								If SI2->(!DbSeek(RIGHT(TRBRET->NUMCER,6)+TRBRET->ORDPAGO))
									nSoma2:=0
									RecLock("SI2",.T.)
										SI2->SI2_NRO3 := RIGHT(TRBRET->NUMCER,6)
										SI2->SI2_NRO4 := SUBSTR(TRBRET->EMISSAO,1,4)
										SI2->SI2_LETFAC := "10"
										SI2->SI2_SUC := "0000"
										SI2->SI2_NFACT := RIGHT(TRBRET->ORDPAGO,8)										
										DbSelectArea("SEK")
										SEK->(DbSetOrder(6)) //"EK_FILIAL+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_FORNECE+EK_LOJA+EK_TIPODOC+EK_ORDPAGO"
										If SEK->(DbSeek(xFilial("SEK") + TRBRET->(SERIE+DOC+PARCELA)))
											While SEK->(!Eof()) .and. TRBRET->ORDPAGO == SEK->EK_ORDPAGO
												If TRBRET->FORNECE == SEK->EK_FORNECE  .and. TRBRET->LOJA == SEK->EK_LOJA .And. TRBRET->SERIE == SEK->EK_PREFIXO 
													nSoma2+= SEK->EK_VALOR
													SI2->SI2_IMPORT := ALLTRIM(STR(nSoma2,11,2))
												EndIf
												SEK->(DbSkip())
											Enddo
										EndIf
										SEK->(dbCloseArea())
										SI2->SI2_SUCA := FWFilial()//
										SI2->SI2_CRED := IIF(EMPTY(TRBRET->PARCELA),"0","1")//
									SI2->(MsUnlock())
								EndIf
								
								DbSelectArea("SI3")
								SI3->(dbSetOrder(1))
								SI3->(dbGoTop())
								If SI3->(!DbSeek(TRBRET->CUITF))
									
									DbSelectArea("SA2")
									SA2->(DbSetOrder(1))//"A2_FILIAL+A2_COD+A2_LOJA" 
									SA2->(dbGoTop())
									If  SA2->(DbSeek(xFilial("SA2")+AvKey(TRBRET->FORNECE,"A2_COD")+AvKey(TRBRET->LOJA,"A2_LOJA")))
										aSIRE := {}
										aSIRE := ValidSFH(SA2->A2_COD,SA2->A2_LOJA,"IBR","JU",1,{"FH_TIPO"})
										RecLock("SI3",.T.)
											SI3->SI3_CUIT := SA2->A2_CGC
											SI3->SI3_NROIC := IIF(Len(aSIRE) > 1,IIF(aSIRE[1],IIF(aSIRE[2] == "V",SA2->A2_CGC,SA2->A2_NROIB),SA2->A2_NROIB),SA2->A2_NROIB)
											SI3->SI3_AYP := SA2->A2_NOME
											SI3->SI3_CALLE := SA2->A2_END
											SI3->SI3_NRO :=  ""
											SI3->SI3_PISO := ""
											SI3->SI3_DPTO := "" 
											SI3->SI3_CODPOS := SA2->A2_CX_POST
											SI3->SI3_IMP := IIF(Len(aSIRE) > 1,IIF(aSIRE[1],IIF(aSIRE[2] == "V","2","1"),"1"),"1") //
											SI3->SI3_INSC := IIF(Len(aSIRE) > 1,IIF(aSIRE[1],IIF(aSIRE[2] == "I","S","N"),"N"),"N") //
											SI3->SI3_ACTIV := ""
										SI3->(MsUnlock())
									EndIf
									SA2->(DbCloseArea())
								EndIf
								
								DbSelectArea("SI4")
								SI4->(dbSetOrder(1))
								SI4->(dbGoTop())
								If SI4->(!DbSeek(LEFT(TRBRET->CUITF,11)+cCodAct))
									nPosAct := 0
									nPosProv := 0
									nPosPRov := Ascan(aActPRov,{ |aTmpPro| aTmpPro[1] == LEFT(TRBRET->CUITF,11)})
									If nPosPRov == 0
										AADD(aActPRov,{LEFT(TRBRET->CUITF,11),{cCodAct}})
										nPosAct := 1
									Else
										AADD(aActPRov[nPosPRov][2],cCodAct)
										nPosAct := Len(aActPRov[nPosPRov][2])
									EndIf
									
									RecLock("SI4",.T.)
										SI4_PROV := TRBRET->CUITF
										SI4_ACT := cCodAct
										SI4_ORDEN := IIF(Len(AllTrim(STR(nPosAct)))>1,AllTrim(STR(nPosAct)),"0"+ AllTrim(STR(nPosAct)))
									SI4->(MsUnlock())
								EndIf
								nImp++
							ElseIf SI1->(DbSeek(RIGHT(TRBRET->NUMCER,6)+TRBRET->ORDPAGO))
								RecLock("SI1",.F.)
								nBase+= Val(ALLTRIM(STR(TRBRET->VLRBAS,11,2)))
								nSoma+= Val(STR(TRBRET->RETENCAO,11,2))
								SI1_BASE := cValTochar(Alltrim(STR(nBase,11,2)))
								SI1_RETEN := cValTochar(Alltrim(STR(nsoma,11,2)))
								SI1->(MsUnlock())
							EndIf													
						ElseIf (UPPER(cArquivo) $ "DGR19310" .And. SubStr(aCodTab[1][1],1,1)=="1")
							nImp++
							DbSelectArea("DGR19310")
							DGR19310->(dbSetOrder(1))//RET_CODRET+RET_NUMCER
							DGR19310->(dbGoTop())
							RecLock("DGR19310",.T.)
							DGR19310->DGR_CPO1 := RIGHT(TRBRET->NUMCER,10)
							DGR19310->DGR_CPO2 := SUBSTR(TRBRET->EMISSAO,7,2) + "/" + SUBSTR(TRBRET->EMISSAO,5,2) + "/" + SUBSTR(TRBRET->EMISSAO,1,4)
							DGR19310->DGR_CPO3 := RIGHT(TRBRET->ORDPAGO,13)
							DbSelectArea("SEK")
							SEK->(DbSetOrder(6)) //EK_FILIAL+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_FORNECE+EK_LOJA+EK_TIPODOC+EK_ORDPAGO
							If SEK->(DbSeek(xFilial("SEK") + TRBRET->(SERIE+DOC+PARCELA)))
								While SEK->(!Eof()) .and. TRBRET->ORDPAGO == SEK->EK_ORDPAGO
									If TRBRET->FORNECE == SEK->EK_FORNECE  .and. TRBRET->LOJA == SEK->EK_LOJA
										DGR19310->DGR_CPO4 := PADL(Alltrim(Str(Round(SEK->EK_VLMOED1,2) * 100)),12,"0")
										Enc19310(aCodTab,2,Round(SEK->EK_VLMOED1,2),SEK->EK_TIPO)
										DGREsp := SEK->EK_TIPO
									EndIf
									SEK->(DbSkip())
								Enddo
							EndIf
							DGR19310->DGR_CPO5 := PADL(Alltrim(Str(Round(TRBRET->VLRBAS,2) * 100)),12,"0")
							DGR19310->DGR_CPO6 := PADL(Alltrim(Str(Round(TRBRET->RETENCAO,2) * 100)),12,"0")
							If AllTrim(DGREsp) $ "NCC|NDI"
								DGR19310->DGR_CPO6 := "-" + Substr(DGR19310->DGR_CPO6,2)
							EndIf
							DGR19310->DGR_CPO7 := Transform(TRBRET->INSCRIBF, "@E 999-999999-9" )
							DGR19310->DGR_CPO8 := Transform(Val(TRBRET->CUITF), "@E 99-99999999-9" )
							DGR19310->DGR_CPO9 := TRBRET->NOMEA2
							DGR19310->DGR_CPO10 := TRBRET->DOMICIL
							DGR19310->DGR_CPO11 := TRBRET->LOCALI
							DGR19310->DGR_CPO12 := TRBRET->CODPOS
							DGR19310->DGR_CPO13 := CodProv(aCodTab[2][1])
							DGR19310->(MsUnlock())
						ElseIf UPPER(cArquivo)$"RES28-97" //Retenciones de IIBB de la Provincia de Formosa
								
							nConcept := ""
							SFH->(DbSetOrder(1))
							SFH->(DbGoTop())
							If SFH->(DbSeek(xFilial("SFH")+AvKey(TRBRET->CODF,"FH_FORNECE")+AvKey(TRBRET->LOJA,"FH_LOJA")+"IBR"))
								nConcept:=AllTrim(SFH->FH_DECRETO)
							EndIf 
													
							DbSelectArea("FORMOS")
							FORMOS->(dbSetOrder(1))
							FORMOS->(dbGoTop())
							If FORMOS->(!DbSeek(AllTrim(TRBRET->RECIBO)+AllTrim(TRBRET->CUITF)+nConcept))
								RecLock("FORMOS",.T.)
									FORMOS->FOR_NROCOM	:= AllTrim(TRBRET->NUMCER)
									FORMOS->FOR_FECHA	:= Substr(TRBRET->EMISSAO,7) + "/" + Substr(TRBRET->EMISSAO,5,2) + "/" + Substr(TRBRET->EMISSAO,1,4)
									FORMOS->FOR_CUIT	:= AllTrim(TRBRET->CUITF)
									FORMOS->FOR_DNOMIN	:= AllTrim(TRBRET->NOMEA2)
									FORMOS->FOR_CATEGO	:= nConcept
									FORMOS->FOR_MONTO	:= StrTran(StrZero(TRBRET->VLRBAS,16,2),",",".")
									FORMOS->FOR_ALIQUO	:= StrTran(StrZero(TRBRET->ALIQ,6,2),",",".")
									FORMOS->FOR_RETENC	:= StrTran(StrZero(TRBRET->RETENCAO,16,2),",",".")
									FORMOS->FOR_OBSERV	:= ""
								
								FORMOS->(MsUnlock())
								nImp++
							EndIf												
						EndIf
						IF UPPER(cArquivo)=="SIRCAR"
							If RecLock("SIRRET",.F.)
								nValSIRCAR:= Round(nBaseSIRCAR*(nAliSIRCAR/100),2)
								SIRRET->RET_VLRTOT := PadL(AllTrim(Transform(nValSIRCAR * Iif(nValSIRCAR < 0,-1,1),"@R 999999999.99")), 12, "0")	
								SIRRET->(MsUnlock())
							EndIf
						EndIf
						TRBRET->(DbSkip())
					End
				EndIf
				If UPPER(cArquivo)=="SILARPIB"
					If Len(aCNPJ)>0
						For nCont:=1 To Len(aCNPJ)
							nImp++
							RecLock("S01",.T.)
							S01->S01_TIPO   := aCnpj[nCont][2]
							S01->S01_NOMBRE := aCnpj[nCont][3]
							S01->S01_CUIT   := Transform(aCnpj[nCont][1],"@R XX-XXXXXXXX-X")
							S01->S01_NUMINS := aCnpj[nCont][4]
							S01->S01_SEMNUM := Iif(Empty(aCnpj[nCont][4]),"1","0")//0-No|1-Si
							S01->S01_CALLE  := aCnpj[nCont][5]
							S01->S01_NUMERO	:= "00000"
							S01->S01_SECTOR	:= ""
							S01->S01_TORRE	:= ""
							S01->S01_DEPART	:= ""
							S01->S01_PISO	:= ""
							S01->S01_BARRIO := aCnpj[nCont][6]
							S01->S01_LOCALI := aCnpj[nCont][7]
							S01->S01_CP     := aCnpj[nCont][8]
							S01->S01_PROVIN := aCnpj[nCont][9]
							S01->(MsUnlock())
						Next
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf cPaisLoc == "ARG" .AND. UPPER(cArquivo)$ "RENTAX"
		cQrRentax:=" SELECT A1_CGC, * FROM "+RetsqlName("SF2")+" SF2 "
		cQrRentax+=" INNER JOIN " + RetsqlName("SA1") + " AS SA1 "
		cQrRentax+=" ON A1_COD = F2_CLIENTE  AND A1_LOJA = F2_LOJA "
		cQrRentax+=" WHERE SF2.D_E_L_E_T_=''  "
		cQrRentax+=" AND F2_FILIAL= '" + xFilial("SF2") + "' "
		cQrRentax+=" AND A1_FILIAL= '" + xFilial("SA1") + "' "
		cQrRentax+=" AND F2_PROVENT= '" + 'MI' + "' "
		cQrRentax+=" AND ((F2_ESPECIE IN ('RFN', 'RFS', 'RTS') AND F2_EMISSAO BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' ))"
		cQrRentax+=" ORDER BY F2_EMISSAO"
			
		cTRBLVRO := ChangeQuery(cQrRentax)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBLVRO ) ,"TRBRENTAX", .T., .F.)

		DbSelectArea("TRBRENTAX")
		TRBRENTAX->(dbGoTop())
	
		DbSelectArea("RENTAX")
		RENTAX->(dbSetOrder(1))//RET_CODRET+RET_NUMCER
		RENTAX->(dbGoTop())
			
		Do While TRBRENTAX->(!Eof())
			nImp++
			RecLock("RENTAX",.T.)
						
				RENTAX->CUIT_CLI := SubStr(Alltrim(TRBRENTAX->A1_CGC),1,2) + "-" + SUBSTR(TRBRENTAX->A1_CGC, 3, 8) + "-" + SUBSTR(TRBRENTAX->A1_CGC, 11, 1) // CUIT CLIENTE
				DbSelectArea("SA4")//Tabela Transportadora
				SA4->(DbSetOrder(1))// A4_FILIAL+A4_COD
				SA4->(DbGoTop())
				SA4->(MsSeek(xFilial("SA4")+TRBRENTAX->F2_TRANSP))
				ctransCGC := SubStr(SA4->A4_CGC,1,2) + "-" + SUBSTR(SA4->A4_CGC, 3, 8) + "-" + SUBSTR(SA4->A4_CGC, 11, 1)
				RENTAX->CUIT_TRANS := Iif(Len(ctransCGC) == 13,ctransCGC, "")   //CUIT TRANSPORTADORA
				RENTAX->CLASS_COMP := "2"
				RENTAX->TP_COMPR := TRBRENTAX->F2_SERIE
				RENTAX->OTROS := ""
				If TAMSX3("F2_DOC")[1] == 12
					RENTAX->SUCURSAL := SubStr(TRBRENTAX->F2_DOC,1,4)
					RENTAX->NUMERO := SubStr(TRBRENTAX->F2_DOC,5,8)
				ElseIf TAMSX3("F2_DOC")[1] == 13
					RENTAX->SUCURSAL := SubStr(TRBRENTAX->F2_DOC,2,4)
					RENTAX->NUMERO := SubStr(TRBRENTAX->F2_DOC,6,8)
				Endif
				RENTAX->FECHA :=  SubStr(TRBRENTAX->F2_EMISSAO,7,2) + "-" + SubStr(TRBRENTAX->F2_EMISSAO,5,2) + "-" + SubStr(TRBRENTAX->F2_EMISSAO,1,4)
				If TRBRENTAX->F2_MOEDA == 1
					RENTAX->MONTO_OPE := cValtochar(TRBRENTAX->F2_VALCOT)
				Else
					RENTAX->MONTO_OPE := cValtochar(xMoeda(TRBRENTAX->F2_VALCOT,TRBRENTAX->F2_MOEDA,1,ddatabase,2,TRBRENTAX->F2_TXMOEDA,,))
				Endif	
			RENTAX->(MsUnlock())
						
			TRBRENTAX->(DbSkip())
		Enddo
		TRBRENTAX->(DbClosearea()) 	
	EndIf
	
	If nVlNCP > 0 
		Aadd(aLogreg,Replicate("=",80))
		Aadd(aLogreg,"Total de Percepciones Negativas del Período : " + CVALTOCHAR(nVlNCP) + "")
	EndIF
   
    If UPPER(cArquivo)$"SICORE"
		If lAglfil 
			For nProcFil:=1 to len(aFilsCalc)		 
				If aFilsCalc[nProcFil,1] == .T.
					cFilAnt := aFilsCalc[nProcFil,2] // cFilAnt es la variable global que indica en que sucursal estamos trabajando					
					For nNumFil:=1 to len(aFilsCalc)
						aFilsCalc[nNumFil,1] := .F.
					Next nNumFil		
				Endif		
			Next nProcFil	
		Endif
	Endif	
	
	Aadd(aLogreg,Replicate("-",80))
	Aadd(aLogreg,STR0025+SPACE(1)+Alltrim(Str(nImp)))	//"Quantidade de Registros gerado: "
	Aadd(aLogreg,Replicate("-",80))
Return(aLogReg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao ³LocTrb        ºAutor  ³ Marcos Kato       º Data ³  30/03/04   º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³Montagem dos arquivos de trabalho.                             º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno³ExpA -> aTrbs - Array contendo alias abertos pela funcao       º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    ³                                                               º±±
±±ÈÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LocTrbs(cTpArq,aArTmp,lEsCons)
	Local cArqPer		:= ""//PERCEPCAO IVA|PERCEPCAO SIRCAR
	Local cArqRet		:= ""//RETENCAO IVA|RETENCAO SIRCAR
	Local cArqSip		:= ""//SIP - PERCEPCAO E RETENCAO (SANTA FE)
	Local cArqSic		:= ""//SIC - SICORE
	Local cArqSjr      := ""//SJR - SICORE
	Local cArqSia1		:= "" // SIAPRE Contribuyentes Locales - Recaudaciones Bancarias 
	Local cArqSia2		:= "" // SIAPRE Contribuyentes Locales - Retenciones 
	Local cArqSia3		:= "" // SIAPRE Contribuyentes del Convenio Multilateral - Retenciones
	Local cArqSia4		:= "" // SIAPRE Contribuyentes del Convenio Multilateral - Percepciones
	Local cArqSia5		:= "" // SIAPRE Contribuyentes del Convenio Multilateral - Percepción Aduanera
	Local cArqSia6		:= "" // SIAPRE Contribuyentes del Convenio Multilateral - Recaudaciones Bancarias
	Local cArq5314		:= "" //RES53-14 - Percepciones y Retenciones de Cordoba
	Local cArqSIARE1	:= "" //SIARE - Retenciones Revertidas
	Local cArqSIARE2 := "" //SIARE - Origen detalle
	Local cArqSIARE3 := "" //SIARE - Archivo Proveedores
	Local cArqSIARE4 := "" //SIARE - Archivo Actividades
	Local cArqSil1		:= ""//SILARPIB - ARQUIVO 1
	Local cArqSil2		:= ""//SILARPIB - ARQUIVO 2
	Local cArqSil4		:= ""//SILARPIB - ARQUIVO 4
	Local cArqSil5		:= ""//SILARPIB - ARQUIVO 5
	Local cArqSil6		:= ""//SILARPIB - ARQUIVO 6
	Local cArqRIG       := ""//RG2849 - RET IVA|GANANCIAS MAT A RECICLAR
	Local cArqSIA		:= ""//PERCEPCION IIBB - SIAPE (JUJUY)
	Local cArqDGR		:= ""//RETENCION IIBB - DGR3027 (SJ)
	Local cSDoc			:= SerieNFID("SF3", 3, "F3_SERIE")
	Local cArq19310     := ""
	Local cArqFOR       := "" //RETENCION IIBB - RES98-97(FORMOSA)
	Local aStrutPer		:= {}//PERCEPCAO IVA|PERCEPCAO SIRCAR
	Local aStrutRet		:= {}//RETENCAO IVA|RETENCAO SIRCAR
	Local aStrutSip		:= {}//SIP - PERCEPCAO E RETENCAO (SANTA FE)
	Local aStrutSic		:= {}//SIC - SICORE
	Local aStrutSjr     := {}//SJR - SICORE
	Local aStrutSil1	:= {}//SILARPIB - ARQUIVO 1
	Local aStrutSil2	:= {}//SILARPIB - ARQUIVO 2
	Local aStrutSil4	:= {}//SILARPIB - ARQUIVO 4
	Local aStrutSil5	:= {}//SILARPIB - ARQUIVO 5
	Local aStrutSil6	:= {}//SILARPIB - ARQUIVO 6
	local aStrutRIG     := {}//RG2849 - RET IVA|GANANCIAS MAT A RECICLAR
	local aStrutSIA	    := {}//PERCEPCION IIBB - SIAPE (JUJUY)
	local aStrutDGR	    := {}//RETENCION IIBB - DGR3027 (SJ)
	Local aStrutSia1	:= {} // SIAPRE Contribuyentes Locales - Recaudaciones Bancarias 
	Local aStrutSia2	:= {} // SIAPRE Contribuyentes Locales - Retenciones 
	Local aStrutSia3	:= {} // SIAPRE Contribuyentes del Convenio Multilateral - Retenciones
	Local aStrutSia4	:= {} // SIAPRE Contribuyentes del Convenio Multilateral - Percepciones
	Local aStrutSia5	:= {} // SIAPRE Contribuyentes del Convenio Multilateral - Percepción Aduanera
	Local aStrutSia6	:= {} // SIAPRE Contribuyentes del Convenio Multilateral - Recaudaciones Bancarias	
	Local aStru5314		:= {} //RES53-14 - Percepciones y Retenciones de Cordoba
	Local aStrSIARE1 := {} //SIARE - Retenciones revertidas
	Local aStrSIARE2 := {} //SIARE - Origen detalle
	Local aStrSIARE3 := {} //SIARe - Archivo Proveedores
	Local aStrSIARE4 := {} //SIARE - Archivo Actividades
	Local aStru19310	:= {} // DGR19310
	Local aOrdem        := {}
	Local aStrutDg1 := {} //STAC-ARG Padrón de Clientes / Proveedores 
	Local aStrutDg2 := {} //STAC-ARG Retenciones Efectuadas
	Local aStrutDg3 := {} //STAC-ARG Retenciones Anuladas
	Local aStrutDg4 := {} //STAC-ARG Percepciones Efectuadas
	Local aStrutDg5 := {} //STAC-ARG Percepciones Anuladas
	Local aStrutMun := {} // Percepciones Municipales de Tucuman
	Local aStrutFor     := {} // RES28-97 Retenciones Efectuadas
	Local aStrRentax    := {} // RENTAX inherente a la generación del archivo de Remitos
	Default lEsCons     := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao os arquivos de trabalho                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTpArq=="IVAPER"//IVA PERCEPCAO
		cArqPer:=""
		aStrutPer:={}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registro Regime de Perception IVA                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aStrutPer,{"PER_CODPER"	,"C",003,0})//Codigo de Regimen de Perception
		AADD(aStrutPer,{"PER_CUIT"	    ,"C",013,0})//CUIT
		AADD(aStrutPer,{"PER_EMISS"	    ,"C",010,0})//Fecha
		AADD(aStrutPer,{"PER_NUMNF1"	,"C",004,0})//Numero de Factura Parte I
		AADD(aStrutPer,{"PER_NUMNF2"	,"C",008,0})//Numero de Factura Parte II
		AADD(aStrutPer,{"PER_VLRPER"	,"C",016,0})//Monto de la Percepcion
		//
		//Creacion de Objeto IVAPER 
		oTmpTable := FWTemporaryTable():New("IVAPER") 
		oTmpTable:SetFields( aStrutPer ) 

		aOrdem	:=	{"PER_CODPER","PER_NUMNF1"} 

		oTmpTable:AddIndex("IND1", aOrdem) 

		oTmpTable:Create() 	
	ElseIf cTpArq=="IVARET"//IVA RETENCAO
		cArqRet:=""
		aStrutRet:={}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registro 051 - Regimenes de Retencion IVA                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aStrutRet,{"RET_CODRET"	,"C",003,0})//Codigo de Regimen de Retencion
		AADD(aStrutRet,{"RET_CUIT"	    ,"C",013,0})//CUIT
		AADD(aStrutRet,{"RET_EMISS"	    ,"C",010,0})//Fecha
		AADD(aStrutRet,{"RET_NUMCER"	,"C",025,0})//Numero de certificado
		AADD(aStrutRet,{"RET_DOC"	    ,"C",012,0})//Nota Fiscal
		AADD(aStrutRet,{"RET_SERIE"	    ,"C",003,0})//Serie
		AADD(aStrutRet,{"RET_FORN"      ,"C",006,0})//Fornecedor
		AADD(aStrutRet,{"RET_LOJA"	    ,"C",002,0})//Loja
		AADD(aStrutRet,{"RET_VLRRET"	,"C",016,0})//Monto de la retencion
		AADD(aStrutRet,{"RET_TIPO"   	,"C",001,0})//C-Cliente|F-Fornecedor

		//Creacion de Objeto IVARET
		oTmpTable := FWTemporaryTable():New("IVARET") 
		oTmpTable:SetFields( aStrutRet ) 

		aOrdem	:=	{"RET_DOC","RET_SERIE","RET_FORN","RET_LOJA","RET_TIPO"} 

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()
	ElseIf cTpArq=="SIPRIB"//RETSIP ou PERSIP(SIP-SANTA FE)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registro Regime de Perception e Retencion SIP                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aStrutSip) > 0 
			aStrutSip := {}
		EndIf
	   
		AADD(aStrutSip,{"SIP_TIPOPE"	,"C",001,0})//Tipo Operacion
		AADD(aStrutSip,{"SIP_EMISS"	    ,"C",010,0})//Fecha de Retencion
		AADD(aStrutSip,{"SIP_CODART"	,"C",003,0})//Codigo Articulo inciso por el que retiene
		AADD(aStrutSip,{"SIP_TIPCOM"	,"C",002,0})//Tipo de Comprobante
		AADD(aStrutSip,{"SIP_LETCOM"	,"C",001,0})//Letra de Comprobante
		AADD(aStrutSip,{"SIP_NUMCOM"	,"C",016,0})//Numero de Comprobante
		AADD(aStrutSip,{"SIP_DATCOM"	,"C",010,0})//Fecha de Comprobante
		AADD(aStrutSip,{"SIP_VLRCOM"	,"C",014,0})//Monto de Comprobante
		AADD(aStrutSip,{"SIP_TIPDOC"	,"C",001,0})//Tipo de Documento
		AADD(aStrutSip,{"SIP_NUMDOC"	,"C",011,0})//Numero del documento
		AADD(aStrutSip,{"SIP_CONFIB"	,"C",001,0})//Condicion frente a Ingressos brutos
		AADD(aStrutSip,{"SIP_NUMIIB"	,"C",010,0})//Numero de inscripcion en Ingressos Brutos
		AADD(aStrutSip,{"SIP_SITIVA"	,"C",001,0})//Situacion frente a Iva
		AADD(aStrutSip,{"SIP_INSOGR"	,"C",001,0})//Marca Inscripcion Otros Gravamenes
		AADD(aStrutSip,{"SIP_INSDRE"	,"C",001,0})//Marca Inscripcion DRel
		AADD(aStrutSip,{"SIP_IMPOGR"	,"C",012,0})//Importe Otros Gravamenes
		AADD(aStrutSip,{"SIP_IMPIVA"	,"C",012,0})//Importe IVA
		AADD(aStrutSip,{"SIP_BSCALC"	,"C",014,0})//Base imponible para el calculo
		AADD(aStrutSip,{"SIP_ALIQUO"	,"C",005,0})//Alicuota
		AADD(aStrutSip,{"SIP_IMDET"	    ,"C",014,0})//Impuesto Determinado
		AADD(aStrutSip,{"SIP_REGINS"	,"C",012,0})//Derecho Registro e Inspeccion
		AADD(aStrutSip,{"SIP_VLRRET"	,"C",014,0})//Monto Retenido
		AADD(aStrutSip,{"SIP_ARTCAL"	,"C",003,0})//Articulo/Inciso para el calculo
		AADD(aStrutSip,{"SIP_TIPEXE"	,"C",001,0})//Tipo de Excención
		AADD(aStrutSip,{"SIP_EMISSE"	,"C",004,0})//Año de Excención
		AADD(aStrutSip,{"SIP_NUMCEE"	,"C",006,0})//Número de Certificado de Excención
		AADD(aStrutSip,{"SIP_NUMCEP"	,"C",012,0})//Número de Certificado Propio

		AADD(aStrutSip,{"F3_NFISCAL"    ,"C",TAMSX3("F3_NFISCAL")[1],0})//NFISCAL		
		AADD(aStrutSip,{"F3_SERIE"    	,"C",TAMSX3(cSDoc)[1],0})//SERIE
		AADD(aStrutSip,{"F3_CLIEFOR"    ,"C",TAMSX3("F3_CLIEFOR")[1],0})//CLIENTE
		AADD(aStrutSip,{"F3_LOJA"    	,"C",TAMSX3("F3_LOJA")[1],0})//LOJA

		AADD(aStrutSip,{"NUM_VLRCOM"	,"N",016,2})//Monto de Comprobante
		AADD(aStrutSip,{"NUM_IMPIVA"	,"N",016,2})//Importe IVA
		AADD(aStrutSip,{"NUM_BSCALC"	,"N",016,2})//Base imponible para el calculo
		AADD(aStrutSip,{"NUM_IMDET"	    ,"N",016,2})//Impuesto Determinado
		AADD(aStrutSip,{"NUM_VLRRET"	,"N",016,2})//Monto Retenido
	
		//Creacion de Objeto SIPRIB 
		oTmpTable := FWTemporaryTable():New("SIPRIB") 
		oTmpTable:SetFields( aStrutSip ) 

		aOrdem	:=	{"SIP_TIPOPE","SIP_CODART","SIP_TIPCOM","SIP_EMISS","F3_NFISCAL","F3_SERIE","F3_CLIEFOR","F3_LOJA"} 

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create() 
	ElseIf cTpArq=="SICORE"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registro Regime de Perception e Retencion SIC                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  !lEsCons  //Generar solo si no es consolidado
			AADD(aStrutSic,{"SIC_TIPCOM","C",002,0})
			AADD(aStrutSic,{"SIC_EMISS" ,"C",010,0})
			AADD(aStrutSic,{"SIC_NUMCOM","C",016,0})
			AADD(aStrutSic,{"SIC_VLRNET","C",016,0})
			AADD(aStrutSic,{"SIC_CODIMP","C",004,0})
			AADD(aStrutSic,{"SIC_CODREG","C",003,0})
			AADD(aStrutSic,{"SIC_CODOPE","C",001,0})
			AADD(aStrutSic,{"SIC_VLRBAS","C",014,0})
			AADD(aStrutSic,{"SIC_DATRET","C",010,0})
			AADD(aStrutSic,{"SIC_CODCON","C",002,0})
			AADD(aStrutSic,{"SIC_RETSUS","C",001,0})
			AADD(aStrutSic,{"SIC_IMPRET","C",014,0})
			AADD(aStrutSic,{"SIC_PORCEX","C",006,0})
			AADD(aStrutSic,{"SIC_DATBOL","C",010,0})
			AADD(aStrutSic,{"SIC_TIPDOC","C",002,0})
			AADD(aStrutSic,{"SIC_NUMCUI","C",020,0})
			AADD(aStrutSic,{"SIC_NUMCOR","C",014,0})
			AADD(aStrutSic,{"SIC_RAZSOC","C",020,0})
			AADD(aStrutSic,{"SIC_ENDER" ,"C",020,0})
			AADD(aStrutSic,{"SIC_CIDADE","C",020,0})
			AADD(aStrutSic,{"SIC_PROVIN","C",002,0})
			AADD(aStrutSic,{"SIC_CEP"   ,"C",008,0})
	
			//Creacion de Objeto SICORE 
			oTmpTable := FWTemporaryTable():New("SICORE") 
			oTmpTable:SetFields( aStrutSic ) 
	
			aOrdem	:=	{"SIC_TIPCOM","SIC_NUMCOM","SIC_EMISS"} 
	
			oTmpTable:AddIndex("IN1", aOrdem) 
	
			oTmpTable:Create() 
	
			AADD(aStrutSjr,{"SJR_TIPO"  ,"C",001,0})
			AADD(aStrutSjr,{"SJR_CLIENT","C",006,0})
			AADD(aStrutSjr,{"SJR_LOJA"  ,"C",002,0})
			AADD(aStrutSjr,{"SJR_TIPDOC","C",002,0})
			AADD(aStrutSjr,{"SJR_NUMCUI","C",020,0})
			AADD(aStrutSjr,{"SJR_RAZSOC","C",020,0})
			AADD(aStrutSjr,{"SJR_ENDER" ,"C",020,0})
			AADD(aStrutSjr,{"SJR_CIDADE","C",020,0})
			AADD(aStrutSjr,{"SJR_PROVIN","C",002,0})
			AADD(aStrutSjr,{"SJR_CEP"   ,"C",008,0})
		
			//Creacion de Objeto SUJRET 
			oTmpTable2 := FWTemporaryTable():New("SUJRET") 
			oTmpTable2:SetFields( aStrutSjr ) 
	
			aOrdem	:=	{"SJR_TIPO","SJR_CLIENT","SJR_LOJA"} 
	
			oTmpTable2:AddIndex("IN2", aOrdem) 
	
			oTmpTable2:Create() 
		EndIf
	ElseIf cTpArq=="SIRCAR"//PERCEPCAO SIRCAR
		cArqPer:=""
		aStrutPer:={}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registro SIRCAR Percepcao                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aStrutPer,{"PER_NUMREG"	,"C",005,0})//Numero de Region
		AADD(aStrutPer,{"PER_TIPCOM"	,"C",003,0})//Tipo de Comprobante
		AADD(aStrutPer,{"PER_LETCOM"	,"C",001,0})//Letra del Comprobante("A","B","C" ou "Z")
		AADD(aStrutPer,{"PER_NUMCOM"	,"C",012,0})//Numero de Comprobante
		AADD(aStrutPer,{"PER_CUIT"   	,"C",011,0})//CUIT
		AADD(aStrutPer,{"PER_DATPER"	,"C",010,0})//Fecha de percepcao(dd/mm/aaaa)
		AADD(aStrutPer,{"PER_VLRPER"	,"C",012,0})//Monto sujeto a percepcion
		AADD(aStrutPer,{"PER_ALIPER"	,"C",006,0})//Aliquota
		AADD(aStrutPer,{"PER_VLRTOT"	,"C",012,0})//Monto sujeto a percepcion
		AADD(aStrutPer,{"PER_TIPPER"	,"C",003,0})//Tipo de regime de retencao
		AADD(aStrutPer,{"PER_JURISD"	,"C",003,0})//Jurisdicao
		AADD(aStrutPer,{"PER_TIPOPE"	,"C",001,0})//Tipo de Operación 
		AADD(aStrutPer,{"PER_NUCONS"	,"C",014,0})//Numero de Constancia
		AADD(aStrutPer,{"PER_AUX1"		,"N",016,2})
		AADD(aStrutPer,{"PER_AUX2"		,"N",016,2})

		//Creacion de Objeto SIRPER 
		oTmpTable := FWTemporaryTable():New("SIRPER") 
		oTmpTable:SetFields( aStrutPer ) 

		aOrdem	:=	{"PER_TIPCOM","PER_LETCOM","PER_NUMCOM","PER_CUIT","PER_TIPPER","PER_JURISD","PER_ALIPER"} 

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()

		cArqRet:=""
		aStrutRet:={}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registro SIRCAR Retencao                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aStrutRet,{"RET_NUMREG"	,"C",005,0})//Numero de Region
		AADD(aStrutRet,{"RET_ORICOM"	,"C",001,0})//1-Por Software propio del agente|2-por Sistema Sicar
		AADD(aStrutRet,{"RET_TIPCOM"	,"C",001,0})//1-retencion|2-anulacion de retencion
		AADD(aStrutRet,{"RET_NUMCOM"	,"C",012,0})//Numero de Comprobante
		AADD(aStrutRet,{"RET_CUIT"	    ,"C",011,0})//CUIT
		AADD(aStrutRet,{"RET_DATRET"	,"C",010,0})//Fecha de percepcao(dd/mm/aaaa)
		AADD(aStrutRet,{"RET_VLRRET"	,"C",012,0})//Monto sujeto a Retencion
		AADD(aStrutRet,{"RET_ALIRET"	,"C",006,0})//Aliquota
		AADD(aStrutRet,{"RET_VLRTOT"	,"C",012,0})//Monto sujeto a Retencion*Aliquota
		AADD(aStrutRet,{"RET_TIPRET"	,"C",003,0})//Tipo de regime de percepcao
		AADD(aStrutRet,{"RET_JURISD"	,"C",003,0})//Jurisdicao
		AADD(aStrutRet,{"RET_TIPOPE"	,"C",001,0})//Tipo de Operación
		AADD(aStrutRet,{"RET_FECHEC"	,"C",010,0})//Fecha Emision
		AADD(aStrutRet,{"RET_NUCONS"	,"C",014,0})//Numero de Constancia
		AADD(aStrutRet,{"RET_NUCONO"	,"C",014,0})//Numero de Constancia Original
	
		//Creacion de Objeto SIRRET 
		oTmpTable2 := FWTemporaryTable():New("SIRRET") 
		oTmpTable2:SetFields( aStrutRet ) 

		aOrdem	:=	{"RET_NUMREG","RET_ORICOM","RET_TIPCOM"} 

		oTmpTable2:AddIndex("IN2", aOrdem) 

		oTmpTable2:Create() 
	ElseIf cTpArq=="SILARPIB"//SILARPIB
		cArqSil1:=""
		aStrutSil1:={}
		AADD(aStrutSil1,{"S01_TIPO" 	,"C",001,0})
		AADD(aStrutSil1,{"S01_NOMBRE" 	,"C",100,0})
		AADD(aStrutSil1,{"S01_CUIT" 	,"C",013,0})
		AADD(aStrutSil1,{"S01_NUMINS"	,"C",010,0})
		AADD(aStrutSil1,{"S01_SEMNUM"   ,"C",001,0})
		AADD(aStrutSil1,{"S01_CALLE"	,"C",050,0})
		AADD(aStrutSil1,{"S01_NUMERO"	,"C",005,0})
		AADD(aStrutSil1,{"S01_SECTOR"	,"C",004,0})
		AADD(aStrutSil1,{"S01_TORRE"	,"C",002,0})
		AADD(aStrutSil1,{"S01_DEPART"	,"C",004,0})
		AADD(aStrutSil1,{"S01_PISO" 	,"C",003,0})
		AADD(aStrutSil1,{"S01_BARRIO"	,"C",050,0})
		AADD(aStrutSil1,{"S01_LOCALI"	,"C",050,0})
		AADD(aStrutSil1,{"S01_CP"	    ,"C",008,0})
		AADD(aStrutSil1,{"S01_PROVIN"	,"C",002,0})
		
		//Creacion de Objeto S01 
		oTmpTable := FWTemporaryTable():New("S01") 
		oTmpTable:SetFields( aStrutSil1 ) 
		
		aOrdem	:=	{"S01_CUIT"} 

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create() 

		cArqSil2:=""
		aStrutSil2:={}
		AADD(aStrutSil2,{"S02_IDENT" 	,"C",002,0})
		AADD(aStrutSil2,{"S02_CODOPE" 	,"C",008,0})
		AADD(aStrutSil2,{"S02_TIPRET" 	,"C",001,0})
		AADD(aStrutSil2,{"S02_CONRET"	,"C",002,0})
		AADD(aStrutSil2,{"S02_FECRET"   ,"C",010,0})
		AADD(aStrutSil2,{"S02_FECEMI"	,"C",010,0})
		AADD(aStrutSil2,{"S02_NUMCON"	,"C",014,0})
		AADD(aStrutSil2,{"S02_CUIT" 	,"C",013,0})
		AADD(aStrutSil2,{"S02_BASRET"	,"C",013,0})
		AADD(aStrutSil2,{"S02_BAS2"  	,"N",011,2})
		AADD(aStrutSil2,{"S02_ALIQ" 	,"C",008,0})
		AADD(aStrutSil2,{"S02_IMPRET" 	,"C",011,0})
		AADD(aStrutSil2,{"S02_IMP2" 	,"N",011,2})
		AADD(aStrutSil2,{"S03_IDENT" 	,"C",002,0})
		AADD(aStrutSil2,{"S03_TIPRET" 	,"C",001,0})
		AADD(aStrutSil2,{"S03_LETFAT"	,"C",001,0})
		AADD(aStrutSil2,{"S03_NUMCOM"   ,"C",012,0})
		AADD(aStrutSil2,{"S03_FECCOM"	,"C",010,0})
		AADD(aStrutSil2,{"S03_RETENC"	,"C",001,0})
		AADD(aStrutSil2,{"S03_ANULAC" 	,"C",001,0})
		
		//Creacion de Objeto S02 
		oTmpTable2 := FWTemporaryTable():New("S02") 
		oTmpTable2:SetFields( aStrutSil2 ) 

		aOrdem	:=	{"S03_IDENT","S02_NUMCON","S02_CUIT"} 

		oTmpTable2:AddIndex("IN2", aOrdem) 

		oTmpTable2:Create() 	

		cArqSil4:=""
		aStrutSil4:={}
		AADD(aStrutSil4,{"S04_IDENT" 	,"C",002,0})
		AADD(aStrutSil4,{"S04_CODOPE" 	,"C",008,0})
		AADD(aStrutSil4,{"S04_NUMANU" 	,"C",014,0})
		AADD(aStrutSil4,{"S04_FECANU"	,"C",010,0})
		AADD(aStrutSil4,{"S04_CONANU"   ,"C",001,0})
		AADD(aStrutSil4,{"S04_NUMCON"	,"C",014,0})
		AADD(aStrutSil4,{"S04_IMPRET"	,"C",011,0})
		AADD(aStrutSil4,{"S04_IMP2 "	,"N",011,2})//GRAZI
		AADD(aStrutSil4,{"S04_FECRET" 	,"C",010,0})
		AADD(aStrutSil4,{"S04_IMPANU"	,"C",011,0})
		AADD(aStrutSil4,{"S04_IMPN2"	,"N",011,2})//GRAZI
		AADD(aStrutSil4,{"S04_CUIT"     ,"C",013,0})
		AADD(aStrutSil4,{"S03_IDENT" 	,"C",002,0})
		AADD(aStrutSil4,{"S03_TIPRET" 	,"C",001,0})
		AADD(aStrutSil4,{"S03_LETFAT"	,"C",001,0})
		AADD(aStrutSil4,{"S03_NUMCOM"   ,"C",012,0})
		AADD(aStrutSil4,{"S03_FECCOM"	,"C",010,0})
		AADD(aStrutSil4,{"S03_RETENC"	,"C",001,0})
		AADD(aStrutSil4,{"S03_ANULAC" 	,"C",001,0})

		//Creacion de Objeto S04 
		oTmpTable3 := FWTemporaryTable():New("S04") 
		oTmpTable3:SetFields( aStrutSil4 ) 

		aOrdem	:=	{"S03_IDENT","S04_NUMANU","S04_CUIT"} 

		oTmpTable3:AddIndex("IN3", aOrdem) 

		oTmpTable3:Create() 
	
		cArqSil5:=""
		aStrutSil5:={}
		AADD(aStrutSil5,{"S05_IDENT" 		,"C",002,0})
		AADD(aStrutSil5,{"S05_TIPPER" 	,"C",001,0})
		AADD(aStrutSil5,{"S05_CODOPE"		,"C",008,0})
		AADD(aStrutSil5,{"S05_CONPER"		,"C",002,0})
		AADD(aStrutSil5,{"S05_FECPER"   	,"C",010,0})
		AADD(aStrutSil5,{"S05_FECEMI"		,"C",010,0})
		AADD(aStrutSil5,{"S05_NUMCON"		,"C",013,0})
		AADD(aStrutSil5,{"S05_CUIT" 		,"C",013,0})
		AADD(aStrutSil5,{"S05_BASPER"		,"C",013,0})
		AADD(aStrutSil5,{"S05_ALIQ"     	,"C",008,0})
		AADD(aStrutSil5,{"S05_IMPPER"   	,"C",011,0})
		AADD(aStrutSil5,{"S05_EMIDAT"  	,"C",010,0})
		AADD(aStrutSil5,{"S05_AUX01"  	,"N",016,2})
		AADD(aStrutSil5,{"S05_AUX02"  	,"N",016,2})
		AADD(aStrutSil5,{"S03_IDENT" 	,"C",002,0})
		AADD(aStrutSil5,{"S03_TIPRET" 	,"C",001,0})
		AADD(aStrutSil5,{"S03_LETFAT"	,"C",001,0})
		AADD(aStrutSil5,{"S03_NUMCOM"   ,"C",012,0})
		AADD(aStrutSil5,{"S03_FECCOM"	,"C",010,0})
		AADD(aStrutSil5,{"S03_RETENC"	,"C",001,0})
		AADD(aStrutSil5,{"S03_ANULAC" 	,"C",001,0})

		//Creacion de Objeto S05 
		oTmpTable4 := FWTemporaryTable():New("S05") 
		oTmpTable4:SetFields( aStrutSil5 ) 

		aOrdem	:=	{"S03_IDENT","S05_EMIDAT","S05_NUMCON","S05_CUIT"} 

		oTmpTable4:AddIndex("IN4", aOrdem) 

		oTmpTable4:Create() 
	
		cArqSil6:=""
		aStrutSil6:={}
		AADD(aStrutSil6,{"S06_IDENT" 	,"C",002,0})
		AADD(aStrutSil6,{"S06_NUMCON" 	,"C",013,0})
		AADD(aStrutSil6,{"S06_CODOPE" 	,"C",008,0})
		AADD(aStrutSil6,{"S06_FECANU"	,"C",010,0})
		AADD(aStrutSil6,{"S06_CONANU"   ,"C",001,0})
		AADD(aStrutSil6,{"S06_IMPANU"	,"C",011,0})
		AADD(aStrutSil6,{"S06_CUIT"	    ,"C",013,0})
		AADD(aStrutSil6,{"S06_ANUDAT"  	,"C",010,0})
		AADD(aStrutSil6,{"S06_AUX01"  	,"N",016,2})
		AADD(aStrutSil6,{"S03_IDENT" 	,"C",002,0})
		AADD(aStrutSil6,{"S03_TIPRET" 	,"C",001,0})
		AADD(aStrutSil6,{"S03_LETFAT"	,"C",001,0})
		AADD(aStrutSil6,{"S03_NUMCOM"   ,"C",012,0})
		AADD(aStrutSil6,{"S03_FECCOM"	,"C",010,0})
		AADD(aStrutSil6,{"S03_RETENC"	,"C",001,0})
		AADD(aStrutSil6,{"S03_ANULAC" 	,"C",001,0})

		//Creacion de Objeto 
		oTmpTable5 := FWTemporaryTable():New("S06") 
		oTmpTable5:SetFields( aStrutSil6 ) 

		aOrdem	:=	{"S03_IDENT","S06_ANUDAT","S06_NUMCON","S06_CUIT"} 

		oTmpTable5:AddIndex("IN5", aOrdem) 

		oTmpTable5:Create() 
   ElseIf cTpArq=="RG2849"//RG2849
		cArqRIG := ""

		AADD(aStrutRIG,{"RET_TPCOMP"	,"C",003,0})
		AADD(aStrutRIG,{"RET_PTOVTA"	,"C",004,0})
		AADD(aStrutRIG,{"RET_NROCOM"	,"C",008,0})
		AADD(aStrutRIG,{"RET_FCHCOM"	,"C",008,0})
		AADD(aStrutRIG,{"RET_TPDOCV"	,"C",002,0})
		AADD(aStrutRIG,{"RET_CUIT "		,"C",011,0})
		AADD(aStrutRIG,{"RET_APNOMV"	,"C",025,0})
		AADD(aStrutRIG,{"RET_TOTNET"	,"C",012,0})
		AADD(aStrutRIG,{"RET_TOTIVA"	,"C",012,0})
		AADD(aStrutRIG,{"RET_TOTAL"		,"C",012,0})
		AADD(aStrutRIG,{"RET_PRODUC"	,"C",002,0})
		AADD(aStrutRIG,{"RET_CANTID"	,"C",008,0})
		AADD(aStrutRIG,{"RET_UNIMED"    ,"C",002,0})
		AADD(aStrutRIG,{"RET_PRCUNI"	,"C",012,0})
		AADD(aStrutRIG,{"RET_PRCTOT"	,"C",012,0})
		AADD(aStrutRIG,{"RET_IVAALQ"	,"C",001,0})
		AADD(aStrutRIG,{"RET_IMPLIQ"	,"C",012,0})
		AADD(aStrutRIG,{"RET_COD"	    ,"C",TAMSX3("D1_COD")[1],0})
				
		//Creacion de Objeto RG2849 
		oTmpTable := FWTemporaryTable():New("RG2849") 
		oTmpTable:SetFields( aStrutRIG ) 

		aOrdem	:=	{"RET_TPCOMP","RET_PTOVTA","RET_NROCOM","RET_PRODUC","RET_CUIT","RET_COD","RET_PRCUNI"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create() 
		DbSelectArea("RG2849")		
		DbSetOrder(1)
	ElseIf cTpArq=="SIAPE"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registro Regime de Perception IIBB                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		AADD(aStrutSIA,{"PER_CUIT"		,"C",012,0}) // CUIT AGENTE
		AADD(aStrutSIA,{"PER_AGE"		,"C",011,0}) // No AGENTE
		AADD(aStrutSIA,{"PER_SEMANA"	,"C",002,0}) // TIPO DE DECLARACION MENSUAL/SEMANAL
		AADD(aStrutSIA,{"PER_PERIOD"	,"C",007,0}) // PERIODO DE DECLARACION (MMAAAA)
		AADD(aStrutSIA,{"PER_EMISS"		,"C",009,0}) // FECHA DE PAGO DE FACTURA
		AADD(aStrutSIA,{"PER_CUITC"		,"C",012,0}) // CUIT DEL PERCIBIDO
		AADD(aStrutSIA,{"PER_NROAGE"	,"C",013,0}) // PROVINCIA SELECCIONADA
		AADD(aStrutSIA,{"PER_NOM"		,"C",041,0}) // APELLIDO O RAZON SOCIAL DEL PERCIBIDO
		AADD(aStrutSIA,{"PER_DIR"		,"C",041,0}) // DIRECCCION DEL APERCIBIDO
		AADD(aStrutSIA,{"PER_LOC"		,"C",021,0}) // MUNICIPIO
		AADD(aStrutSIA,{"PER_CP"			,"C",011,0}) // CODIGO POSTAL
		AADD(aStrutSIA,{"PER_CONSTA"	,"C",007,0}) // No. CONSTANCIA DE PERCEPCIO (VACIA)
		AADD(aStrutSIA,{"PER_ANIO"		,"C",005,0}) // ANO DE CONSTANCIA (VACIO)
		AADD(aStrutSIA,{"PER_NUMCOM"	,"C",016,0}) // No de COMPROBANTE
		AADD(aStrutSIA,{"PER_BASE"		,"C",011,2}) // BASE CALCULO IMPUESTO
		AADD(aStrutSIA,{"PER_ALIC"		,"C",006,2}) // ALICUOTA DEL IMPUESTO
		AADD(aStrutSIA,{"PER_VALIMP"	,"C",011,2}) // VALOR DEL IMPUESTO
		AADD(aStrutSIA,{"PER_TARIFA"	,"C",005,0}) // CATEGORIZACION DE USUARIO (VACIO)
		AADD(aStrutSIA,{"PER_CATEG"		,"C",002,0}) // INSCRIPTO, NO INSCRIPTO
		AADD(aStrutSIA,{"PER_CODIMP"	,"C",002,0}) // (VACIO)
		AADD(aStrutSIA,{"PER_TIPDOC"	,"C",003,0}) // ESPECIE (NF), NCC/NDI, NDC/NCI

		//Creacion de Objeto SIAPE 
		oTmpTable := FWTemporaryTable():New("SIAPE") 
		oTmpTable:SetFields( aStrutSIA ) 

		aOrdem	:=	{"PER_TIPDOC","PER_NUMCOM","PER_EMISS"} 

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create() 
	ElseIf cTpArq=="DGR3027"//DGR3027
		cArqDGR := ""

		AADD(aStrutDGR,{"RET_RAZSOC"	,"C",080,0})
		AADD(aStrutDGR,{"RET_CUIT"		,"C",013,0})
		AADD(aStrutDGR,{"RET_ENDERE"	,"C",020,0})
		AADD(aStrutDGR,{"RET_NIGB"		,"C",012,0})
		AADD(aStrutDGR,{"RET_NROCER"	,"C",030,0})
		AADD(aStrutDGR,{"RET_EMISSA"	,"C",010,0})
		AADD(aStrutDGR,{"RET_VALBAS"	,"C",016,0})
		AADD(aStrutDGR,{"RET_ALIQ"		,"C",006,0})
		AADD(aStrutDGR,{"RET_RETEN"		,"C",016,0})
		AADD(aStrutDGR,{"RET_RETENA"	,"C",016,0})
		AADD(aStrutDGR,{"RET_TIPO"	    ,"C",001,0})
   						
		//Creacion de Objeto DGR3027 
		oTmpTable := FWTemporaryTable():New("DGR3027") 
		oTmpTable:SetFields( aStrutDGR ) 

		aOrdem	:=	{"RET_NROCER"} 

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()
	ElseIf cTpArq=="SIAPRE" //SIAPRE
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retenciones y Percepciones de IIBB Provincia de Tucuman                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Contribuyentes Locales - Recaudaciones Bancarias                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArqSia1 := ""
		
		AADD(aStrutSia1,{"SIA_CUIT"	,"C",011,0}) //Cuit
		AADD(aStrutSia1,{"SIA_PERIOD"	,"C",006,0}) //Periodo
		AADD(aStrutSia1,{"SIA_CBUCTA"	,"C",022,0}) //CBU o Nro de cuenta
		AADD(aStrutSia1,{"SIA_IMPORT"	,"C",018,0}) //Importe
		
		//Creacion de Objeto 
		oTmpTable := FWTemporaryTable():New("SIAPRERB") 
		oTmpTable:SetFields( aStrutSia1 ) 

		aOrdem	:=	{"SIA_CUIT","SIA_PERIOD","SIA_CBUCTA","SIA_IMPORT"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create() 
			
		DbSelectArea("SIAPRERB")
		DbSetOrder(1)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Contribuyentes Locales - Retenciones y Percepciones                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArqSia2 := ""
		
		AADD(aStrutSia2,{"SIA_CUIT"	,"C",011,0}) //Cuit
		AADD(aStrutSia2,{"SIA_RAZSOC"	,"C",050,0}) //Razon Social
		AADD(aStrutSia2,{"SIA_FCHCOM"	,"C",010,0}) //Fecha de percepcion
		AADD(aStrutSia2,{"SIA_TPOCBT"	,"C",003,0}) //Tipo de comprobate
		AADD(aStrutSia2,{"SIA_LETRA"	,"C",001,0}) //Letra de comprobante
		AADD(aStrutSia2,{"SIA_TRMINL"	,"C",004,0}) //Terminal
		AADD(aStrutSia2,{"SIA_NUMERO"	,"C",008,0}) //Constancia
		AADD(aStrutSia2,{"SIA_IMPCOM"	,"C",018,0}) //Valor del importe retenido/percibido 
		AADD(aStrutSia2,{"SIA_CODRP"	,"C",001,0}) //Codigo de retencion/percepcion
		AADD(aStrutSia2,{"SIA_IMPSTO"	,"C",002,0}) //Impuesto
		
		oTmpTable := FWTemporaryTable():New("SIAPRERP") 
		oTmpTable:SetFields( aStrutSia2 ) 

		aOrdem	:=	{"SIA_CUIT","SIA_FCHCOM","SIA_TPOCBT","SIA_LETRA","SIA_TRMINL","SIA_CODRP"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create() 		
	
		DbSelectArea("SIAPRERP")
		DbSetOrder(1)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Contribuyentes del Convenio Multilateral - Archivo de Retenciones      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArqSia3 := ""
		
		AADD(aStrutSia3,{"SIA_CODJUR"	,"C",003,0}) //Codigo de jurisdiccion
		AADD(aStrutSia3,{"SIA_CUITAG"	,"C",013,0}) //Cuit de Agente
		AADD(aStrutSia3,{"SIA_FCHRET"	,"C",010,0}) //Fecha de Retencion
		AADD(aStrutSia3,{"SIA_NUMSUC"	,"C",004,0}) //Numero de sucursal
		AADD(aStrutSia3,{"SIA_NUMCON"	,"C",016,0}) //Numero de constancia
		AADD(aStrutSia3,{"SIA_TPOCOM"	,"C",001,0}) //Tipo de comprobante
		AADD(aStrutSia3,{"SIA_LTACOM"	,"C",001,0}) //Letra de comprobante
		AADD(aStrutSia3,{"SIA_NCOMPO"	,"C",020,0}) //Original
		AADD(aStrutSia3,{"SIA_IMPRET"	,"C",011,0}) //Importe retenido
		
		oTmpTable := FWTemporaryTable():New("SIAPRECMR") 
		oTmpTable:SetFields( aStrutSia3 ) 

		aOrdem	:=	{"SIA_CODJUR","SIA_CUITAG","SIA_FCHRET","SIA_NUMSUC","SIA_NUMCON"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()		
	
		DbSelectArea("SIAPRECMR")
		DbSetOrder(1)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Contribuyentes del Convenio Multilateral - Archivo de Percepciones     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArqSia4 := ""
		
		AADD(aStrutSia4,{"SIA_CODJUR"	,"C",003,0})  //Codigo de jurisdiccion
		AADD(aStrutSia4,{"SIA_CUITAG"	,"C",013,0}) //Cuit de Agente
		AADD(aStrutSia4,{"SIA_FCHPER"	,"C",010,0}) //Fecha de Percepcion
		AADD(aStrutSia4,{"SIA_NUMSUC"	,"C",004,0}) //Numero de sucursal
		AADD(aStrutSia4,{"SIA_NUMCON"	,"C",008,0}) //Numero de constancia
		AADD(aStrutSia4,{"SIA_TPOCOM"	,"C",001,0}) //Tipo de comprobante
		AADD(aStrutSia4,{"SIA_LTACOM"	,"C",001,0}) //Letra de comprobante
		AADD(aStrutSia4,{"SIA_IMPRET"	,"C",011,0}) //Importe recibido
		
		oTmpTable := FWTemporaryTable():New("SIAPRECMP") 
		oTmpTable:SetFields( aStrutSia4 ) 

		aOrdem	:=	{"SIA_CODJUR","SIA_CUITAG","SIA_FCHPER","SIA_NUMSUC","SIA_NUMCON"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()			
	
		DbSelectArea("SIAPRECMP")		
		DbSetOrder(1)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Contribuyentes del Convenio Multilateral - Percepcion Aduanera          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArqSia5 := ""
		
		AADD(aStrutSia5,{"SIA_CODJUR"	,"C",003,0}) //Codigo de jurisdiccion
		AADD(aStrutSia5,{"SIA_CUITAG"	,"C",013,0}) //Cuit de Agente
		AADD(aStrutSia5,{"SIA_FCHPER"	,"C",010,0}) //Fecha de percepcion
		AADD(aStrutSia5,{"SIA_NUMDSA"	,"C",020,0}) //Numero de despacho aduanero
		AADD(aStrutSia5,{"SIA_IMPPER"	,"C",010,0}) //Importe percibido
		
		//Creacion de Objeto 
		oTmpTable := FWTemporaryTable():New("SIAPRECMPA") 
		oTmpTable:SetFields( aStrutSia5 ) 

		aOrdem	:=	{"SIA_CODJUR","SIA_CUITAG","SIA_FCHPER","SIA_NUMDSA","SIA_IMPPER"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()			
	
		DbSelectArea("SIAPRECMPA")
		DbSetOrder(1)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Contribuyentes del Convenio Multilateral - Recaudaciones Bancarias      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArqSia6 := ""
		
		AADD(aStrutSia6,{"SIA_CODJUR"	,"C",003,0}) //Codigo de jurisdiccion
		AADD(aStrutSia6,{"SIA_CUIAG"	,"C",013,0}) //Cuit de agente de recaudacion
		AADD(aStrutSia6,{"SIA_PERRET"	,"C",007,0}) //Periodo de la retencion
		AADD(aStrutSia6,{"SIA_CBU"	,"C",022,0})	//CBU
		AADD(aStrutSia6,{"SIA_TPOCTA"	,"C",002,0}) //Tipo de cuenta
		AADD(aStrutSia6,{"SIA_TPOMON"	,"C",001,0}) //Tipo de moneda
		AADD(aStrutSia6,{"SIA_IMPRET"	,"C",010,0}) //Importe retenido		
		
		oTmpTable := FWTemporaryTable():New("SIAPRECMRB") 
		oTmpTable:SetFields( aStrutSia6 ) 

		aOrdem	:=	{"SIA_CODJUR","SIA_CUIAG","SIA_PERRET","SIA_CBU","SIA_IMPRET"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()		
	
		DbSelectArea("SIAPRECMRB")
		DbSetOrder(1)
	ElseIf cTpArq $ "DGR55-11|STAC-AR" //Retenciones y Percepciones de IIBB de la Provincia de Rio Negro
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retenciones y Percepciones de IIBB Provincia de Santa Cruz     	         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Padrón de Clientes / Proveedores               				             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		AADD(aStrutDg1,{"DGP_RAZSOC"	,"C",070,0}) //Apellido y Nombre
		AADD(aStrutDg1,{"DGP_CUIT"		,"C",011,0}) //CUIT
		AADD(aStrutDg1,{"DGP_SITUIB"	,"C",002,0}) //Situación en IB
		AADD(aStrutDg1,{"DGP_ESCONV"	,"C",001,0}) //Es Convenio
		AADD(aStrutDg1,{"DGP_NROCON"	,"C",010,0}) //Nro de IB/Convenio
		AADD(aStrutDg1,{"DGP_CODPRO"	,"C",002,0}) //Código de Provincia
		AADD(aStrutDg1,{"DGP_LOCALI"	,"C",030,0}) //Localidad
		AADD(aStrutDg1,{"DGP_BARRIO"	,"C",030,0}) //Barrio
		AADD(aStrutDg1,{"DGP_CALLE"		,"C",030,0}) //Calle
		AADD(aStrutDg1,{"DGP_NUMERO"	,"C",005,0}) //Número
		AADD(aStrutDg1,{"DGP_SECTOR"	,"C",005,0}) //Sector
		AADD(aStrutDg1,{"DGP_TORRE"		,"C",005,0}) //Torre
		AADD(aStrutDg1,{"DGP_PISO"		,"C",005,0}) //Piso
		AADD(aStrutDg1,{"DGP_CODPOS"	,"C",008,0}) //Código Postal
		AADD(aStrutDg1,{"DGP_DEPTO"		,"C",005,0}) //Departamento u Oficina
		
		oTmpTable := FWTemporaryTable():New("DGPADCP") 
		oTmpTable:SetFields( aStrutDg1 ) 

		aOrdem	:=	{"DGP_CUIT","DGP_SITUIB","DGP_ESCONV"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()		
		
		DbSelectArea("DGPADCP")
		DbSetOrder(1)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retenciones Efectuadas							                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		AADD(aStrutDg2,{"DGR_CONCEP"	,"C",002,0}) //Concepto
		AADD(aStrutDg2,{"DGR_FCHRET"	,"C",010,0}) //Fecha de Retención
		AADD(aStrutDg2,{"DGR_NROCON"	,"C",013,0}) //Nro. de Constancia
		AADD(aStrutDg2,{"DGR_TIPCON"	,"C",002,0}) //Tipo de Comprobante
		AADD(aStrutDg2,{"DGR_LETRA"		,"C",001,0}) //Letra
		AADD(aStrutDg2,{"DGR_NROCOM"	,"C",012,0}) //Nro. de Comprobante
		AADD(aStrutDg2,{"DGR_CUIT"		,"C",011,0}) //CUIT del Contribuyente Retenido
		AADD(aStrutDg2,{"DGR_BASERE"	,"C",015,0}) //Base sujeta a Retención/Recaudación
		AADD(aStrutDg2,{"DGR_ALICUO"	,"C",005,0}) //Alícuota
		AADD(aStrutDg2,{"DGR_IMPRET"	,"C",015,0}) //Impuesto Retenido/Recaudado
		
		oTmpTable := FWTemporaryTable():New("DGRETE") 
		oTmpTable:SetFields( aStrutDg2 ) 

		aOrdem	:=	{"DGR_NROCON","DGR_NROCOM","DGR_CUIT"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()			
	
		DbSelectArea("DGRETE")
		DbSetOrder(1)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retenciones Anuladas						                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		AADD(aStrutDg3,{"DGR_FCHANU"	,"C",010,0}) //Fecha de Anulación
		AADD(aStrutDg3,{"DGR_NROCOA"	,"C",013,0}) //Nro. de Constancia de Anulación
		AADD(aStrutDg3,{"DGR_MONANU"	,"C",015,0}) //Monto Anulado
		AADD(aStrutDg3,{"DGR_NROCOR"	,"C",013,0}) //Nro. de Constancia de Retención
		AADD(aStrutDg3,{"DGR_FCHREA"	,"C",010,0}) //Fecha Retención Anulada
		AADD(aStrutDg3,{"DGR_MONREA"	,"C",015,0}) //Monto Retención Anulada
		AADD(aStrutDg3,{"DGR_CUIT"		,"C",011,0}) //Nro de Cuit de Contribuyente Retenido		
		
		oTmpTable := FWTemporaryTable():New("DGRETA") 
		oTmpTable:SetFields( aStrutDg3 ) 

		aOrdem	:=	{"DGR_NROCOA","DGR_NROCOR","DGR_CUIT"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()		
	
		DbSelectArea("DGRETA")
		DbSetOrder(1)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Percepciones Efectuadas	    						                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aStrutDg4,{"DGP_CONCEP"	,"C",002,0}) //Concepto
		AADD(aStrutDg4,{"DGP_FCHPER"	,"C",010,0}) //Fecha
		AADD(aStrutDg4,{"DGP_TIPCOM"	,"C",002,0}) //Tipo de Comprobante
		AADD(aStrutDg4,{"DGP_LETRA"	,"C",001,0}) //Letra
		AADD(aStrutDg4,{"DGP_NROCOM"	,"C",012,0}) //Nro de Comprobante
		AADD(aStrutDg4,{"DGP_CUIT"	,"C",011,0}) //Nro de CUIT del Contribuyente Percibido
		AADD(aStrutDg4,{"DGP_BASEPE"	,"C",015,0}) //Base sujeta a Percepción
		AADD(aStrutDg4,{"DGP_ALICUO"	,"C",005,0}) //Alícuota
		AADD(aStrutDg4,{"DGP_IMPPER"	,"C",015,0}) //Impuesto Percibido		
		
		oTmpTable := FWTemporaryTable():New("DGPERE") 
		oTmpTable:SetFields( aStrutDg4 ) 

		aOrdem	:=	{"DGP_TIPCOM","DGP_LETRA","DGP_NROCOM","DGP_CUIT"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()		
	
		DbSelectArea("DGPERE")		
		DbSetOrder(1)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Percepciones Anuladas							                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		AADD(aStrutDg5,{"DGP_FCHANU"	,"C",010,0}) //Fecha de Anulación
		AADD(aStrutDg5,{"DGP_TIPCOM"	,"C",002,0}) //Tipo de Comprobante
		AADD(aStrutDg5,{"DGP_LETRA"	,"C",001,0}) //Letra
		AADD(aStrutDg5,{"DGP_NROCOM"	,"C",012,0}) //Nro de Comprobante
		AADD(aStrutDg5,{"DGP_FCHPEA"	,"C",010,0}) //Fecha de la Percepción Anulada
		AADD(aStrutDg5,{"DGP_MONPEA"	,"C",015,0}) //Monto de la Percepción Anulada
		AADD(aStrutDg5,{"DGP_CUIT"	,"C",011,0}) //Nro del CUIT de Contribuyente Percibido		
		
		oTmpTable := FWTemporaryTable():New("DGPERA") 
		oTmpTable:SetFields( aStrutDg5 ) 

		aOrdem	:=	{"DGP_TIPCOM","DGP_LETRA","DGP_NROCOM","DGP_CUIT"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()		
	
		DbSelectArea("DGPERA")
		DbSetOrder(1)		
		
	ElseIf cTpArq=="RES28-97" .OR.  cTpArq=="RES98-97"  //Percepciones/Retenciones de IIBB de la Provincia Formosa
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retenciones de IIBB Provincia de Formosa ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArqFor := ""

		AADD(aStrutFor,{"FOR_NROCOM" ,"C",020,0}) //Nro de Comprobante
		AADD(aStrutFor,{"FOR_FECHA" ,"C",010,0}) //Fecha de Retención
		AADD(aStrutFor,{"FOR_CUIT" ,"C",011,0}) //CUIT
		AADD(aStrutFor,{"FOR_DNOMIN" ,"C",100,0}) //Denominación
		AADD(aStrutFor,{"FOR_CATEGO" ,"C",010,0}) //Categoria
		AADD(aStrutFor,{"FOR_MONTO" ,"C",016,0}) //Monto
		AADD(aStrutFor,{"FOR_ALIQUO" ,"C",006,0}) //Alícuota
		AADD(aStrutFor,{"FOR_RETENC" ,"C",016,0}) //Retención
		AADD(aStrutFor,{"FOR_OBSERV" ,"C",200,0}) //Observación


		oTmpTable := FWTemporaryTable():New("FORMOS") 
		oTmpTable:SetFields( aStrutFor ) 
		aOrdem	:=	{"FOR_NROCOM","FOR_CUIT","FOR_CATEGO"}
		oTmpTable:AddIndex("IND1", aOrdem) 
		oTmpTable:Create()
		

		DbSelectArea("FORMOS")
		DbSetOrder(1)	
 		
	ElseIf cTpArq=="RES53-14"  //RES53-14 - Percepciones y Retenciones de Cordoba
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retenciones y Percepciones Municipales de Cordoba                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArq5314 := ""
		AADD(aStru5314,{"MUN_TPOREG" ,"C",001,0}) //Tipo de Registro (1-Percepcion;2-Retencion)
		AADD(aStru5314,{"MUN_TCUITA" ,"C",002,0}) //Tipo de CUIT del Agente
		AADD(aStru5314,{"MUN_NCUITA" ,"C",008,0}) //Numero de CUIT del Agente
		AADD(aStru5314,{"MUN_VCUITA" ,"C",001,0}) //Digito verificador del CUIT del Agente
		AADD(aStru5314,{"MUN_PERIOD" ,"C",006,0}) //Periodo de Presentacion (AAAAMM)			
		AADD(aStru5314,{"MUN_NOCOMP" ,"C",011,0}) //Numero de Comprobante		
		AADD(aStru5314,{"MUN_PTPAGO" ,"C",001,0}) //Codigo del Punto de Pago								
		AADD(aStru5314,{"MUN_COMORI" ,"C",015,0}) //Comprobante de Origen
		AADD(aStru5314,{"MUN_TCUITR" ,"C",002,0}) //Tipo de CUIT del Retenido
		AADD(aStru5314,{"MUN_NCUITR" ,"C",008,0}) //Numero de CUIT del Retenido
		AADD(aStru5314,{"MUN_VCUITR" ,"C",001,0}) //Digito verificador del CUIT del Retenido 
		AADD(aStru5314,{"MUN_VALBAS" ,"C",015,0}) //Monto de la Base Imponible   
		AADD(aStru5314,{"MUN_ALICUO" ,"C",005,0}) //Alícuota 
		AADD(aStru5314,{"MUN_VALRET" ,"C",015,0}) //Monto de la Retencion  
		AADD(aStru5314,{"MUN_EDOCOM" ,"C",001,0}) //Estado del comprobante
		AADD(aStru5314,{"MUN_FCHRET" ,"C",008,0}) //Fecha de Carga de la Retención
		AADD(aStru5314,{"MUN_FCHANU" ,"C",008,0}) //Fecha de anulación de la Retención
		AADD(aStru5314,{"MUN_NOME"   ,"C",050,0}) //Denominación del retenido
		AADD(aStru5314,{"MUN_END"    ,"C",050,0}) //Calle del domicilio del retenido
		AADD(aStru5314,{"MUN_NUM"    ,"C",005,0}) //Numero de domicilio del retenido
		AADD(aStru5314,{"MUN_PISO"   ,"C",005,0}) //Piso del domicilio del retenido
		AADD(aStru5314,{"MUN_DEPTO"  ,"C",005,0}) //Depto del domicilio del retenido
		AADD(aStru5314,{"MUN_BAIRRO" ,"C",050,0}) //Barrio y Localidad del retenido
		AADD(aStru5314,{"MUN_CEP"    ,"C",015,0}) //COdigo Postal del retenido
		AADD(aStru5314,{"MUN_FCHINI" ,"C",008,0}) //Fecha de inicio del retenido  	   					
		AADD(aStru5314,{"MUN_FCHFIN" ,"C",008,0}) //Fecha última actualización de datos del retenido
		
		oTmpTable := FWTemporaryTable():New("RES5314")
		oTmpTable:SetFields( aStru5314 )

		aOrdem	:=	{"MUN_NOCOMP","MUN_TCUITR","MUN_NCUITR","MUN_VCUITR","MUN_ALICUO"}

		oTmpTable:AddIndex("IND1", aOrdem)

		oTmpTable:Create()		
		
		DbSelectArea("RES5314")
		DbSetOrder(1)	    
	ElseIf cTpArq=="SIARE"			
		cArqSIARE1	:= "" //SIARE - Retenciones Revertidas
		aStrSIARE1 := {} //SIARE - Retenciones revertidas
		AADD(aStrSIARE1,{"SI1_NRO1","C",11,0}) //Nro. Cuit Agente de Retención
		AADD(aStrSIARE1,{"SI1_NRO2","C",11,0}) //Nro. Cuit de retenido
		AADD(aStrSIARE1,{"SI1_NRO3","C",6,0}) //Nro. Constancia
		AADD(aStrSIARE1,{"SI1_NRO4","C",4,0}) //Año constancia
		AADD(aStrSIARE1,{"SI1_FECHA","C",10,0}) //Fecha de Emisisión "DD/MM/AAAA"
		AADD(aStrSIARE1,{"SI1_BASE","C",11,0}) //Monto Base - 11,2
		AADD(aStrSIARE1,{"SI1_ALIC","C",5,0}) //Alicuota aplicada - 5,2
		AADD(aStrSIARE1,{"SI1_RETEN","C",11,0}) //Monto retenido - 11,2
		AADD(aStrSIARE1,{"SI1_CODIMP","C",2,0}) //Código importe "9" anulada
		AADD(aStrSIARE1,{"SI1_CODACT","C",9,0}) //Cóigo actividad
		AADD(aStrSIARE1,{"SI1_CANTFA","C",7,0}) //Cantidad de facturas de la constancia
		AADD(aStrSIARE1,{"SI1_NROFAC","C",14,0}) //Nro de la Factura
		AADD(aStrSIARE1,{"SI1_SUC","C",2,0}) //Nro. Sucursal Agente de Retención
		AADD(aStrSIARE1,{"SI1_NROICP","C",15,0}) //Nro. Ing. B. o Convenio del retenido
		AADD(aStrSIARE1,{"SI1_IMP","C",1,0}) //Nro. de Presentación (Original 0 - Rectif. 1 - 9)
		
		oTmpTable := FWTemporaryTable():New("SI1") 
		oTmpTable:SetFields( aStrSIARE1 ) 

		aOrdem	:=	{"SI1_NRO3","SI1_NROFAC"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()		
	
		DbSelectArea("SI1")
		SI1->(DbSetOrder(1))
		
		cArqSIARE2 := "" //SIARE - Origen detalle
		aStrSIARE2 := {} //SIARE - Origen detalle
		AADD(aStrSIARE2,{"SI2_NRO3","C",6,0}) //Nro Constancia
		AADD(aStrSIARE2,{"SI2_NRO4","C",4,0}) //Año de la constancia
		AADD(aStrSIARE2,{"SI2_LETFAC","C",2,0}) //Letra Factura
		AADD(aStrSIARE2,{"SI2_SUC","C",4,0}) //Nro. Sucursal Factura
		AADD(aStrSIARE2,{"SI2_NFACT","C",8,0}) //
		AADD(aStrSIARE2,{"SI2_IMPORT","C",11,0}) //  11,2
		AADD(aStrSIARE2,{"SI2_SUCA","C",2,0}) //
		AADD(aStrSIARE2,{"SI2_CRED","C",1,0}) //
		
		//Creacion de Objeto 
		oTmpTable := FWTemporaryTable():New("SI2") 
		oTmpTable:SetFields( aStrSIARE2 ) 

		aOrdem	:=	{"SI2_NRO3","SI2_NFACT"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()			
	
		DbSelectArea("SI2")		
		SI2->(DbSetOrder(1))
		
		cArqSIARE3 := "" //SIARE - Archivo Proveedores
		aStrSIARE3 := {} //SIARe - Archivo Proveedores
		AADD(aStrSIARE3,{"SI3_CUIT","C",11,0})
		AADD(aStrSIARE3,{"SI3_NROIC","C",15,0})
		AADD(aStrSIARE3,{"SI3_AYP","C",50,0})
		AADD(aStrSIARE3,{"SI3_CALLE","C",30,0})
		AADD(aStrSIARE3,{"SI3_NRO","C",5,0})
		AADD(aStrSIARE3,{"SI3_PISO","C",2,0})
		AADD(aStrSIARE3,{"SI3_DPTO","C",3,0})
		AADD(aStrSIARE3,{"SI3_CODPOS","C",8,0})
		AADD(aStrSIARE3,{"SI3_IMP","C",1,0})
		AADD(aStrSIARE3,{"SI3_INSC","C",1,0})
		AADD(aStrSIARE3,{"SI3_ACTIV","C",9,0})
		
		oTmpTable := FWTemporaryTable():New("SI3") 
		oTmpTable:SetFields( aStrSIARE3 ) 

		aOrdem	:=	{"SI3_CUIT"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()		
	
		DbSelectArea("SI3")
		SI3->(DbSetOrder(1))
		
		cArqSIARE4 := "" //SIARE - Archivo Actividades
		aStrSIARE4 := {} //SIARE - Archivo Actividades
		AADD(aStrSIARE4,{"SI4_PROV","C",11,0})
		AADD(aStrSIARE4,{"SI4_ACT","C",9,0})
		AADD(aStrSIARE4,{"SI4_ORDEN","C",2,0})
		
		oTmpTable := FWTemporaryTable():New("SI4") 
		oTmpTable:SetFields( aStrSIARE4 ) 

		aOrdem	:=	{"SI4_PROV","SI4_ACT"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()		
		
		DbSelectArea("SI4")		
		SI4->(DbSetOrder(1))				
	ElseIf cTpArq=="DGR19310"
		cArq19310 := ""
		aStru19310 := {}

		AADD(aStru19310,{"DGR_CPO1"	,"C",010,0})//
		AADD(aStru19310,{"DGR_CPO2"	,"C",013,0})//
		AADD(aStru19310,{"DGR_CPO3" ,"C",013,0})//
		AADD(aStru19310,{"DGR_CPO4" ,"C",012,0})//
		AADD(aStru19310,{"DGR_CPO5" ,"C",012,0})//
		AADD(aStru19310,{"DGR_CPO6" ,"C",012,0})//
		AADD(aStru19310,{"DGR_CPO7" ,"C",012,0})//
		AADD(aStru19310,{"DGR_CPO8" ,"C",013,0})//
		AADD(aStru19310,{"DGR_CPO9" ,"C",030,0})//
		AADD(aStru19310,{"DGR_CPO10" ,"C",030,0})//
		AADD(aStru19310,{"DGR_CPO11" ,"C",020,0})//
		AADD(aStru19310,{"DGR_CPO12" ,"C",008,0})//
		AADD(aStru19310,{"DGR_CPO13" ,"C",002,0})//
		
		oTmpTable := FWTemporaryTable():New("DGR19310") 
		oTmpTable:SetFields( aStru19310 ) 

		aOrdem	:=	{"DGR_CPO8"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create() 

		DbSelectArea("DGR19310")
		DbSetOrder(1)
	ElseIf cTpArq=="IVAIMP"
		cArqImp := ""
		aStrutImp:={}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registro Regime de Perception IVA                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aStrutImp,{"IMP_PROV"	    ,"C",006,0})//
		AADD(aStrutImp,{"IMP_LOJA"	    ,"C",002,0})//
		AADD(aStrutImp,{"IMP_NFIS"	    ,"C",012,0})//
		AADD(aStrutImp,{"IMP_TPODEC"	,"C",001,0})//
		AADD(aStrutImp,{"IMP_NUMDES"	,"C",025,0})//
		AADD(aStrutImp,{"IMP_CREDF"	    ,"C",015,0})//
		AADD(aStrutImp,{"IMP_CREDFC"	,"C",015,0})//
		
		oTmpTable := FWTemporaryTable():New("IVAIMP") 
		oTmpTable:SetFields( aStrutImp ) 

		aOrdem	:=	{"IMP_PROV","IMP_LOJA","IMP_NFIS"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create() 
	
		DbSelectArea("IVAIMP")
		IVAIMP->(DbSetOrder(1)) //"IMP_PROV","IMP_LOJA","IMP_NFIS"
	ElseIf cTpArq=="PERCMUN"
		aStrutMun := {}
		
		AADD(aStrutMun,{"MUN_CUIT"	,"C",011,0})//
		AADD(aStrutMun,{"MUN_RASOC"	,"C",TAMSX3("A1_NOME")[1],0})//
		AADD(aStrutMun,{"MUN_DOMCOM" ,"C",TAMSX3("A1_END")[1],0})//
		AADD(aStrutMun,{"MUN_COMPRO" ,"C",TAMSX3("F3_NFISCAL")[1],0})//
		AADD(aStrutMun,{"MUN_CONRET" ,"C",001,0})//
		AADD(aStrutMun,{"MUN_FECOMP" ,"C",010,0})//
		AADD(aStrutMun,{"MUN_MONIMP" ,"C",015,0})//
		AADD(aStrutMun,{"MUN_MONTEM" ,"C",015,0})//
		AADD(aStrutMun,{"MUN_MONPYP" ,"C",015,0})//
		
		oTmpTable := FWTemporaryTable():New("PERCMUN") 
		oTmpTable:SetFields( aStrutMun ) 

		aOrdem	:=	{"MUN_CUIT"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()		
	
		DbSelectArea("PERCMUN") //"MUN_CUIT"
		DbSetOrder(1)
	ElseIf cTpArq=="RES28-97" .OR.  cTpArq=="RES98-97"  //Percepciones/Retenciones de IIBB de la Provincia Formosa 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retenciones de IIBB Provincia de Formosa ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArqFor := ""
		aStrutFor := {}

		AADD(aStrutFor,{"FOR_NROCOM" ,"C",020,0}) //Nro de Comprobante
		AADD(aStrutFor,{"FOR_FECHA" ,"C",010,0}) //Fecha de Retención
		AADD(aStrutFor,{"FOR_CUIT" ,"C",011,0}) //CUIT
		AADD(aStrutFor,{"FOR_DNOMIN" ,"C",100,0}) //Denominación
		AADD(aStrutFor,{"FOR_CATEGO" ,"C",010,0}) //Categoria
		AADD(aStrutFor,{"FOR_MONTO" ,"C",016,0}) //Monto
		AADD(aStrutFor,{"FOR_ALIQUO" ,"C",006,0}) //Alícuota
		AADD(aStrutFor,{"FOR_RETENC" ,"C",016,0}) //Retención
		AADD(aStrutFor,{"FOR_OBSERV" ,"C",200,0}) //Observación

		oTmpTable := FWTemporaryTable():New("FORMOS") 
		oTmpTable:SetFields( aStrutFor ) 

		aOrdem	:=	{"FOR_NROCOM","FOR_CUIT","FOR_CATEGO"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()	

		DbSelectArea("FORMOS")
		DbSetOrder(1)					
	ElseIf cTpArq == "RENTAX"
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³RENTAX inherente a la generación del archivo de Remitos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aStrRentax := {}
	
		AADD(aStrRentax,{"CUIT_CLI"   ,"C",013,0}) //CUIT Cliente
		AADD(aStrRentax,{"CUIT_TRANS" ,"C",013,0}) //CUIT Transportista 
		AADD(aStrRentax,{"CLASS_COMP" ,"C",001,0}) //Clase Comprobante
		AADD(aStrRentax,{"TP_COMPR"   ,"C",001,0}) //Tipo Comprobante 
		AADD(aStrRentax,{"OTROS"      ,"C",120,0}) //Otros 
		AADD(aStrRentax,{"SUCURSAL"   ,"C",004,0}) //Sucursal 
		AADD(aStrRentax,{"NUMERO"     ,"C",008,0}) //Número 
		AADD(aStrRentax,{"FECHA"      ,"C",010,0}) //Fecha 
		AADD(aStrRentax,{"MONTO_OPE"  ,"C",020,0}) //Monto Operación 
		
		oTmpTable := FWTemporaryTable():New("RENTAX") 
		oTmpTable:SetFields( aStrRentax ) 

		aOrdem	:=	{"CUIT_CLI"}

		oTmpTable:AddIndex("IN1", aOrdem) 

		oTmpTable:Create()		
	
		DbSelectArea("RENTAX") //"MUN_CUIT"
		DbSetOrder(1)
		
	EndIf
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³LocArgTRepº Autor ³ Marcos Kato        º Data ³  16/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Montagem do relatorio Arquivo Magnetico          		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LogArqTRep(cTitulo,aLogArq)
	Local oReport
	Local aArea			:= GetArea()
	Private cPerg  		:= ""
	Private aOrd		:= {}
 
	oReport :=LOCARGLOG(cTitulo,aLogArq)//TREPORT
	oReport:PrintDialog()
	RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocArgLog ºAutor  ³Marcos Kato         º Data ³  16/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Estrtura do Relatorio em TREPORT                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LOCARGLOG(cTitulo,aLogArq)
	Local oReport
	Local oSection
	Local cDesc	  	:=STR0026+Space(1)+cTitulo//"Impressao do Log do Arquivo Magnetico"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao dos componentes de impressao                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE REPORT oReport NAME STR0028 TITLE cTitulo PARAMETER cPerg ACTION {|oReport| LocArgImp(oReport,aLogArq)} DESCRIPTION cDesc TOTAL IN COLUMN
	oReport:SetPortrait(.T.)//Impressao Retrato
	//-------------------------------------------------------------------------------------------------------
	// oSection = usado para montar o cabeçalho do relatorio
	//-------------------------------------------------------------------------------------------------------
	DEFINE SECTION oSection OF oReport TITLE OemToAnsi(cTitulo) ORDERS aOrd TABLE "" TOTAL IN COLUMN     
	DEFINE CELL NAME "LISTA" 		OF oSection TITLE STR0027  SIZE 200//"RESULTADO DO LOG ARQUIVO MAGNETICO"
		
Return oReport
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocArgImp ºAutor  ³Marcos Kato         º Data ³  16/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do Detalhe do Relatorio em TREPORT                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LocArgImp(oReport,aLogArq)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Declaracao de variaveis                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local oSection := oReport:Section(1)
	Local nOrdem   := oSection:GetOrder()
	Local nCont    := 0
	oSection:Init()
	For nCont:=1 To Len(aLogArq)
		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf
		oSection:Cell("LISTA"	):SetBlock({||aLogArq[nCont]})
		oSection:PrintLine()
	End
	oSection:Finish()
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PERC_ARIB ºAutor  ³Marcos Kato         º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para importar o valore de imposto da tabela SFE     º±±
±±º          ³ para o modulo AGENTES de RECAUDACION do sistema S.I.Ap.    º±±
±±º          ³ da Argentina.                                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Argentina                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION RET_ARIB(cProv,lSiapIB,cTipo)
	Local aStruRET  := {}
	Local aRegRet   := {}
	Local aLogReg	:= {}
	Local cQuery 	:= ""
	Local cArqTrab 	:= ""
	Local cAlias 	:= "RET"
	Local cAliasSFE	:= "SFE"
	Local nImp		:= 0
	Local bWhile	:= {|| .T.}
	Local bIf   	:= {|| .F.}

	Local lQuery	:= .F.

	Default cProv	:= "BA"
	Default lSiapIB	:= .F.
	Default cTipo	:= "1"

	//VETOR COM A ESTRUTURA DA TABELA TEMPORARIA
	aadd(aStruRET,{"RIB_CUIT",   	'C',13,0 })   //A2_CGC
	aadd(aStruRET,{"RIB_FECHA",  	'C',10,0 })   //FE_EMISSAO
	aadd(aStruRET,{"RIB_SUC",    	'C',04,0 })   //FE_NFISCAL - SubStr(FE_NFISCAL,1,4)
	aadd(aStruRET,{"RIB_NEMISS", 	'C',08,0 })   //FE_NFISCAL - SubStr(FE_NFISCAL,5,8)
	aadd(aStruRET,{"RIB_RETENC", 	'N',10,02})   //FE_RETENC
	aadd(aStruRET,{"RIB_NRCOMP",	'C',08,00})   //FE_NROCERT
	aadd(aStruRET,{"RIB_RAZON",  	'C',36,0 })
	aadd(aStruRET,{"RIB_PERS",  	'C',02,0 })
	aadd(aStruRET,{"RIB_BASE",	 	'N',10,02})
	aadd(aStruRET,{"RIB_ALIQ", 		'N',05,02})
	aadd(aStruRET,{"RIB_DGR", 		'C',01,00})
	aadd(aStruRET,{"RIB_TIPO", 		'C',01,00})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄT¿
	//³Apenas faz a query se a chamada da funcao for para selecao              ³
	//³dos movimentos de retencao. Quando a chamada eh para arquivos           ³
	//³de percepcao, apenas cria o temporario para nao dar erro no INI.        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄTÙ
	If cTipo == "1"
		#IFDEF TOP
		If TcSrvType()<>"AS/400"
			lQuery := .T.
			cQuery := "SELECT A2_CGC , A2_NOME, A2_RETIB, FE_FILIAL, FE_EMISSAO, FE_NFISCAL, FE_SERIE, "
			cQuery += "FE_FORNECE, FE_LOJA, FE_NROCERT, FE_RETENC, FE_VALBASE, FE_ALIQ "
			cQuery += "FROM "+ RetSqlName("SA2") + " SA2, "+ RetSqlName("SFE") + " SFE "
			cQuery += "WHERE  "
			cQuery += "FE_TIPO ='B' AND "
			cQuery += "A2_FILIAL = '" + xFilial("SA2") + "' AND "
			cQuery += "FE_FILIAL = '" + xFilial("SFE") + "' AND "
			cQuery += "A2_LOJA = FE_LOJA AND "
			cQuery += "A2_COD = FE_FORNECE AND "
			If SFE->(FieldPos('FE_EST')) > 0
				cQuery += "FE_EST = '" + cProv + "' AND "
			EndIf
			cQuery += "FE_EMISSAO BETWEEN '" + DTOS(MV_PAR01)+ "' AND '" + DTOS(MV_PAR02)+ "' AND "
			cQuery += "SA2.D_E_L_E_T_ <>'*' AND "
			cQuery += "SFE.D_E_L_E_T_ <>'*' "
			cQuery += "Order By FE_EMISSAO, FE_NFISCAL, FE_RETENC  "
			cQuery:= ChangeQuery(cQuery)

			MsAguarde({ | | dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .T., .T.) },, ) //"Por favor aguarde"###"Seleccionando registros en el Servidor..."

			TCSetField('TRB', "FE_EMISSAO" , "D",8,0)
			TCSetField('TRB', "FE_RETENC"  , "N",TAMSX3("FE_RETENC")[1],TAMSX3("FE_RETENC")[2])

			cAliasSFE := "TRB"
			cAliasSA2 := "TRB"
			bWhile	:= {||.T.}
			bIf     := {||.T.}

			DbSelectArea('TRB')
		Else
			#EndIf
			cAliasSFE:= "SFE"
			cAliasSA2:= "SA2"
			DbSelectArea("SFE")
			DbSetOrder(7)
			dBSeek(xFilial()+DTOS(MV_PAR01),.T.)
			bWhile 	:= {|| xFilial("SFE") == (cAliasSFE)->FE_FILIAL .AND. (cAliasSFE)->FE_EMISSAO >= MV_PAR01 .AND. (cAliasSFE)->FE_EMISSAO <= MV_PAR02}
			If SFE->(FieldPos('FE_EST')) > 0
				bIf		:= {|| (cAliasSFE)->FE_TIPO =='B' .And. (cAliasSFE)->FE_EST == cProv}
			Else
				bIf		:= {|| (cAliasSFE)->FE_TIPO =='B'}
			EndIf
			#IFDEF TOP
		EndIf
		#EndIf
	EndIf

	//CRIA TABELA TEMPORARIA E INDICE
	//Creacion de Objeto RET 
	oTmpTable := FWTemporaryTable():New("RET") 
	oTmpTable:SetFields( aStrutDGR ) 

	aOrdem	:=	{"RIB_FECHA","RIB_SUC"} 

	oTmpTable:AddIndex("IN1", aOrdem) 

	oTmpTable:Create() 

	aLogReg:={}
	Aadd(aLogreg,Replicate("-",80))
	Aadd(aLogreg,STR0016)//"RETENCAO"
	Aadd(aLogreg,Replicate("=",80))
	nImp:=0
	While !(cAliasSFE)->(EOF()).And. Eval(bWhile)
		If Eval(bIf)
			If !lQuery
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xFilial("SA2")+(cAliasSFE)->FE_FORNECE+(cAliasSFE)->FE_LOJA)
			EndIf

			SF1->(dbSeek(xfilial("SF1")+(cAliasSFE)->FE_NFISCAL+(cAliasSFE)->FE_SERIE+(cAliasSFE)->FE_FORNECE+(cAliasSFE)->FE_LOJA))
			If Alltrim(SF1->F1_PROVENT) <> Alltrim(cProv)
				(cAliasSFE)->(DbSkip())
				Loop
			EndIf
		
			nImp++
			RecLock("RET",.T.)
			RIB_CUIT    := aRetDig((cAliasSA2)->A2_CGC,.F.)
			RIB_RAZON   := (cAliasSA2)->A2_NOME
			RIB_FECHA   := Substr(DTOS((cAliasSFE)->FE_EMISSAO),7,2)+"/"+Substr(DTOS((cAliasSFE)->FE_EMISSAO),5,2)+"/"+Substr(DTOS((cAliasSFE)->FE_EMISSAO),1,4)
			If !lSiapIB
				RIB_SUC     := (cAliasSFE)->(SubStr(FE_NFISCAL,1,4))
				RIB_NEMISS  := (cAliasSFE)->(SubStr(FE_NFISCAL,5,8))
			Else
				RIB_SUC     := (cAliasSFE)->FE_FILIAL
				RIB_NEMISS  := (cAliasSFE)->(SubStr(FE_NFISCAL,5,12))
			EndIf
			RIB_RETENC  := (cAliasSFE)->FE_RETENC
			RIB_NRCOMP	:= (cAliasSFE)->FE_NROCERT
			RIB_PERS	:= "01"
			RIB_BASE	:= (cAliasSFE)->FE_VALBASE
			RIB_ALIQ	:= (cAliasSFE)->FE_ALIQ
			RIB_DGR		:= (cAliasSA2)->A2_RETIB
			RIB_TIPO    := IIF(SF2->F2_TIPO == "D", "C", IIF(SF2->F2_TIPO == "C", "D", "F"))
		
			MsUnlock()
				                                 	
		EndIf
	
		(cAliasSFE)->(DbSkip())
    
	EndDo
	Aadd(aLogreg,STR0025+SPACE(1)+Alltrim(Str(nImp)))	//"Quantidade de Registros gerado: "
	Aadd(aLogreg,Replicate("-",80))
	If cTipo == "1"
		If RET->(RecCount()) > 0
			Aadd(aLogreg,STR0039)
			MsgAlert(OemToAnsi(STR0039))//Registros importados com sucesso
		Else
			Aadd(aLogreg,STR0040)
			MsgAlert(OemToAnsi(STR0040))//Nao ha registros
		EndIf
	EndIf
	aRegRet:={}
	aAdd(aRegRet,cArqTrab)
	aAdd(aRegRet,aLogReg)
Return aRegRet
                                    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PERC_ARIB ºAutor  ³Marcos Kato         º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para importar valores de impostos da tabela SF3     º±±
±±º          ³ para o modulo AGENTES de RECAUDACION do sistema S.I.Ap.    º±±
±±º          ³ da Argentina.                                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Argentina                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PERC_ARIB(cIB,cProv,lSiapIB,cTipo)
	Local aStruIIBB 	:= {}
	Local aArea			:= {}
	Local aRegPerc		:= {}
	Local aLogReg       := {}
	Local bWhile		:= {|| .T.}
	Local bIf   		:= {|| .F.}

	Local cQuery 		:= ""
	Local cArqTrab 		:= ""
	Local cChave    	:= ""
	Local cAlias    	:= "PER"
	Local cBase			:= "F3_BASIMP"
	Local cValor		:= "F3_VALIMP"
	Local cAliq			:= "F3_ALQIMP"
	Local cDecrProv		:= ""
	Local cAliasSF3 	:= "SF3"
	Local cEndereco		:= ""
	Local cNumero		:= ""

	Local lQuery		:= .F.
	Local lSFB			:= .F.
	Local lIIBB			:= SA1->(FieldPos("A1_NROIB")) > 0

	Local nX			:= 0
	Local nImp			:= 0
     	
	Default cIB			:= "IB2"
	Default cProv		:= "BA"
	Default	lSiapIB		:= .F.
	Default cTipo		:= "2"

	Aadd(aLogreg,Replicate("-",80))
	Aadd(aLogreg,STR0010)//"PERCEPCAO"
	Aadd(aLogreg,Replicate("=",80))

	SX5->(dbSetOrder(1))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tabela temporaria que recebera as percepciones³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aStruIIBB,{"PIB_CUIT",  	'C',13,0 })
	aadd(aStruIIBB,{"PIB_FECHA", 	'C',10,0 })
	aadd(aStruIIBB,{"PIB_TIPO",  	'C',01,0 })
	aadd(aStruIIBB,{"PIB_SERIE", 	'C',01,0 })
	aadd(aStruIIBB,{"PIB_SUC",   	'C',04,0 })
	aadd(aStruIIBB,{"PIB_FACTUR",	'C',08,0 })
	aadd(aStruIIBB,{"PIB_BASE",   	'N',12,02})
	aadd(aStruIIBB,{"PIB_VALOR",  	'N',11,02})
	// Campos para a provincia de Neuquen    
	aadd(aStruIIBB,{"PIB_ALIQ",  	'N',5,02})
	aadd(aStruIIBB,{"PIB_NIGB",  	'C',13, 0})
	aadd(aStruIIBB,{"PIB_RAZON",  	'C',35, 0})
	aadd(aStruIIBB,{"PIB_PROV",  	'C',25, 0})
	aadd(aStruIIBB,{"PIB_DOMIC",  	'C',50, 0})
	aadd(aStruIIBB,{"PIB_NUMERO", 	'C',06, 0})
	aadd(aStruIIBB,{"PIB_MONO",  	'C',06, 0})
	aadd(aStruIIBB,{"PIB_PLANTA", 	'C',02, 0})
	aadd(aStruIIBB,{"PIB_DEPTO",  	'C',04, 0})
	aadd(aStruIIBB,{"PIB_PISO",  	'C',02, 0})
	aadd(aStruIIBB,{"PIB_OFIC",  	'C',04, 0})
	aadd(aStruIIBB,{"PIB_CARAC",  	'C',08, 0})
	aadd(aStruIIBB,{"PIB_TELEF",  	'C',10, 0})
	aadd(aStruIIBB,{"PIB_POSTAL",  	'C',08, 0})
	aadd(aStruIIBB,{"PIB_LOCAL",  	'C',25, 0})
	aadd(aStruIIBB,{"PIB_AGENTE",  	'C',06, 0})
	// Campos para a provincia de corrientes
	aadd(aStruIIBB,{"PIB_CANC",  	'D',08, 0})
	aadd(aStruIIBB,{"PIB_PERS", 	'C',02, 0})
	aadd(aStruIIBB,{"PIB_DGR",    	'C',01, 0})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atraves do imposto a ser processado verifico o campo na tabela SB1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArea := GetArea()
	DbSelectArea("SFB")
	SFB->(dbSetOrder(1))
	If SFB->(dbSeek(xFilial("SFB")+cIB))
		cCpo 	:= SFB->FB_CPOLVRO
		cBase 	:= cBase + cCpo
		cValor	:= cValor + cCpo
		cAliq	:= cAliq + cCpo
		lSFB	:= .T.
	EndIf
	RestArea(aArea)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄT¿
	//³Apenas faz a query se a chamada da funcao for para selecao              ³
	//³dos movimentos de percepcao. Quando a chamada eh para                   ³
	//³arquivos de retencao, apenas cria o temporario para nao dar erro no INI.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄTÙ
	If cTipo == "2"  .And. lSFB
	
		#IFDEF TOP
		If TcSrvType()<>"AS/400"
			lQuery := .T.
			cQuery := "SELECT F3_FILIAL, F3_ENTRADA, F3_LOJA, F3_CLIEFOR, F3_TIPO , F3_SERIE , F3_NFISCAL , F3_DTCANC, "
			cQuery += cAliq + ", " + cBase + ", " + cValor + ", "
			cQuery += "A1_COD, A1_LOJA, A1_CGC, A1_NOME, A1_END, A1_TEL, A1_CXPOSTA, A1_BAIRRO, A1_AGENPER, A1_PESSOA "
			If lIIBB
				cQuery += ", A1_NROIB"
			EndIf
			cQuery += "FROM "+ RetSqlName("SF3") + " SF3, "+ RetSqlName("SA1") + " SA1 "
			cQuery += "WHERE F3_FILIAL = '" + xFilial("SF3") + "' AND "
			cQuery += "F3_ENTRADA BETWEEN '" + DTOS(MV_PAR01)+ "' AND '" + DTOS(MV_PAR02)+ "' AND "
			cQuery += "F3_TIPOMOV = 'V' AND "
			cQuery += cValor + " > 0 AND "
			cQuery += "A1_FILIAL = '" + xFilial("SA1") + "' AND "
			cQuery += "A1_LOJA = F3_LOJA AND "
			cQuery += "A1_COD = F3_CLIEFOR AND "
			cQuery += "SF3.D_E_L_E_T_ <>'*' AND "
			cQuery += "SA1.D_E_L_E_T_ <>'*' "
			cQuery += "Order By F3_ENTRADA, F3_SERIE, F3_NFISCAL "

			cQuery:= ChangeQuery(cQuery)

			MsAguarde({ | | dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .T., .T.) },, ) //"Por favor aguarde"###"Seleccionando registros en el Servidor..."

			TCSetField('TRB', "F3_ENTRADA" , "D",8,0)
			TCSetField('TRB', "F3_DTCANC" , "D",8,0)
			TCSetField('TRB', cBase , "N",TAMSX3("F3_BASIMP6")[1],TAMSX3("F3_BASIMP6")[2])
			TCSetField('TRB', cValor , "N",TAMSX3("F3_VALIMP6")[1],TAMSX3("F3_VALIMP6")[2])
			TCSetField('TRB', cAliq , "N",TAMSX3("F3_ALQIMP6")[1],TAMSX3("F3_ALQIMP6")[2])

			cAliasSF3 := "TRB"
			cAliasSA1 := "TRB"
			bWhile	:= {||.T.}
			bIf     := {||.T.}
			DbSelectArea('TRB')
		Else
			#EndIf
			DbSelectArea("SF3")
			DbSetOrder(1)
			dBSeek(xFilial()+DTOS(MV_PAR01),.T.)
			cAliasSF3:= "SF3"
			cAliasSA1:= "SA1"
			bWhile 	:= {|| xFilial("SF3") == (cAliasSF3)->F3_FILIAL .AND. (cAliasSF3)->F3_ENTRADA >= MV_PAR01 .AND. (cAliasSF3)->F3_ENTRADA <= MV_PAR02}
			bIf		:= {|| (cAliasSF3)->&cValor  > 0 .AND. (cAliasSF3)->F3_TIPOMOV = 'V' }
			#IFDEF TOP
		EndIf
		#EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criando a tabela temporaria³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Creacion de Objeto PER 
	oTmpTable := FWTemporaryTable():New("PER") 
	oTmpTable:SetFields( aStruIIBB ) 

	aOrdem	:=	{"PIB_FECHA","PIB_SERIE","PIB_SUC","PIB_FACTUR"} 

	oTmpTable:AddIndex("IN1", aOrdem) 

	oTmpTable:Create() 

	While !(cAliasSF3)->(EOF()).And. Eval(bWhile)
		If Eval(bIf)
	
			If !lQuery
				DbSelectArea("SA1")
				DbSetOrder(1)
				DbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)
			EndIf
		
			cDecrProv := ""
			If SX5->(dbSeek(xFilial("SX5")+"12"+SA1->A1_EST))
				cDecrProv := SX5->X5_DESCSPA
			EndIf
		
			SF2->(dbSeek(xfilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			If Alltrim(SF2->F2_PROVENT) <> Alltrim(cProv)
				(cAliasSF3)->(DbSkip())
				Loop
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Separa o numero do endereco³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cEndereco 	:= ""
			cNumero   	:= ""
			lAchou 		:= .F.
			For nX := 1 To Len((cAliasSA1)->A1_END)
				If IsDigit(Substr((cAliasSA1)->A1_END,nX,1))
					lAchou := .T.
					cNumero	+=	Substr((cAliasSA1)->A1_END,nX,1)
				Else
					If !lAchou
						cEndereco +=	Substr((cAliasSA1)->A1_END,nX,1)
					Else
						Exit
					EndIf
				EndIf
			Next

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Identifica caso se trate de um mesmo documento (F3 quebrado pela chave)³
			//³para armazenar as informacoes em apenas um registro.                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cChave == DTOS((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
				RecLock("PER",.F.)
				PIB_BASE    += IIF(PIB_TIPO == "C", -1*(cAliasSF3)->&cBase,(cAliasSF3)->&cBase)//CASO SEJA DEBITO
				PIB_VALOR   += IIF(PIB_TIPO == "C", -1*(cAliasSF3)->&cValor, (cAliasSF3)->&cValor)//CASO SEJA DEBITO
			Else
				nImp++
				RecLock("PER",.T.)
				PIB_ALIQ 	:= (cAliasSF3)->&cAliq
				PIB_CUIT    := aRetDig((cAliasSA1)->A1_CGC,.F.)
				PIB_FECHA   := Substr(DTOS((cAliasSF3)->F3_ENTRADA),7,2)+"/"+Substr(DTOS((cAliasSF3)->F3_ENTRADA),5,2)+"/"+Substr(DTOS((cAliasSF3)->F3_ENTRADA),1,4)
				PIB_TIPO    := IIF((cAliasSF3)->F3_TIPO == "D", "C", IIF((cAliasSF3)->F3_TIPO == "C", "D", "F"))//AJUSTE DE DIFERENCA DE TIPOS, Protheus x SIAP
				PIB_SERIE   := (cAliasSF3)->(SubStr(F3_SERIE,1,1))
				If !lSiapIB
					PIB_SUC     := (cAliasSF3)->(SubStr(F3_NFISCAL,1,4))
					PIB_FACTUR  := (cAliasSF3)->(SubStr(F3_NFISCAL,5,8))
				Else
					PIB_SUC     := (cAliasSF3)->F3_FILIAL
					PIB_FACTUR  := (cAliasSF3)->(SubStr(F3_NFISCAL,5,12))
				EndIf
				PIB_BASE    := IIF(PIB_TIPO == "C", -1*(cAliasSF3)->&cBase,(cAliasSF3)->&cBase)//CASO SEJA DEBITO
				PIB_VALOR   := IIF(PIB_TIPO == "C", -1*(cAliasSF3)->&cValor, (cAliasSF3)->&cValor)//CASO SEJA DEBITO
				PIB_NIGB	:= aRetDig(Iif(lIIBB,(cAliasSA1)->A1_NROIB,""),.F.)
				PIB_RAZON   := (cAliasSA1)->A1_NOME
				PIB_PROV	:= cDecrProv
				PIB_DOMIC	:= cEndereco
				PIB_NUMERO	:= cNumero
				PIB_MONO	:= ""
				PIB_PLANTA	:= ""
				PIB_DEPTO	:= ""
				PIB_PISO	:= ""
				PIB_OFIC	:= ""
				PIB_CARAC	:= ""
				PIB_TELEF	:= (cAliasSA1)->A1_TEL
				PIB_POSTAL	:= (cAliasSA1)->A1_CXPOSTA
				PIB_LOCAL	:= (cAliasSA1)->A1_BAIRRO
				PIB_AGENTE	:= (cAliasSA1)->A1_AGENPER
				PIB_CANC    := (cAliasSF3)->F3_DTCANC
				PIB_PERS	:= Iif((cAliasSA1)->A1_PESSOA == "F","00","01")
				PIB_DGR    	:= Iif((cAliasSA1)->A1_AGENPER == "S","S","N")
			EndIf
		                
			MsUnlock()
		
			cChave :=  DTOS((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
		EndIf
		(cAliasSF3)->(DbSkip())
	EndDo

	Aadd(aLogreg,STR0025+SPACE(1)+Alltrim(Str(nImp)))	//"Quantidade de Registros gerado: "
	Aadd(aLogreg,Replicate("-",80))

	If cTipo == "2"
		If PER->(RecCount()) > 0
			Aadd(aLogreg,STR0039)
			MsgAlert(OemToAnsi(STR0039))//Registros importados com sucesso
		Else
			Aadd(aLogreg,STR0040)
			MsgAlert(OemToAnsi(STR0040))//Nao ha registros
		EndIf
	EndIf
	aRegPerc:={}
	aAdd(aRegPerc,cArqTrab)
	aAdd(aRegPerc,aLogReg)
Return(aRegPerc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ AMArgDad ³ Autor ³ Ivan Haponczuk      ³ Data ³ 09.11.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Retorna as informacoes para gerar os arquivos magneticos.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cProv    - Provincia do arquivo gerado.                    ³±±
±±³            ³ cTipGer  - Tipo do movimento a gerar retencoes/percepoes.  ³±±
±±³            ³ cImp     - Imposto de percepcao.                           ³±±
±±³            ³ cTabE1   - Tabela de equivalencias 1.                      ³±±
±±³            ³ cClass   - Classe do arquivo S-Sufrida/E-Efetuada.         ³±±
±±³            ³ cTabE2   - Tabela de equivalencias 2.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ aTabs    - Retorna array com os arquivos temporarios       ³±±
±±³            ³            criados.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Argentina - MATA950 - Arquivos Magneticos           ³±±
±±³            ³ LA PAMPA  - IBXLP.INI                                      ³±±
±±³            ³ MISIONES  - IBXMI.INI                                      ³±±
±±³            ³ LA RIOJA  - IBXLR.INI                                      ³±±
±±³            ³ SALTA     - IBXSA.INI                                      ³±±
±±³            ³ CHACO     - IBXCH.INI                                      ³±±
±±³            ³ SAN LUIS  - IBXSL.INI                                      ³±±
±±³            ³ CATAMARCA - IBXCA.INI                                      ³±±
±±³            ³ SAN JUAN  - IBXSJ.INI                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AMArgDad(cProv,cTipGer,cImp,cTabE1,cClass,cTabE2)
	Local cSF3     := ""   //Alias SF3
	Local cSFE     := ""   //Alias SFE
	Local aTabs    := {}   //Dados das tabelas criadas
	Local lCompFis := .T.  //Base compatibilizada fiscal
	Local lCompFin := .T.  //Base compatibilizada financeiro
	Local cfilialF3:=""
	Local cfilialFE:=""
	Local cSucursales:=""
	Local nFil:=0
	Local nAux:=0
	Default cProv   := ""
	Default cTipGer := ""
	Default cImp    := ""
	Default cTabE1  := ""
	Default cTabE2  := ""
	Default cClass  := "E"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define se base de dados esta compatibilizada       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cProv == "LP"
		lCompFis := CCO->(FieldPos("CCO_REGIME"))>0 .and. SFH->(FieldPos("FH_CONCEP"))>0
	ElseIf cProv == "CH"
		lCompFis := SFH->(FieldPos("FH_CONCEP"))>0 .and. SFH->(FieldPos("FH_CLAPROD"))>0
	EndIf
	lCompFin := SFE->(FieldPos ("FE_DTRETOR"))>0 .And. SFE->(FieldPos ("FE_DTESTOR"))>0 .And.;
	SFE->(FieldPos ("FE_NRETORI"))>0
				
	If !lCompFis
		MsgInfo(STR0045+CRLF+STR0046)//"Sistema precisa de atualização."##"Execute o compatibilizador UPDPFLOC."
	EndIf
	If !lCompFin
		MsgInfo(STR0045+CRLF+STR0047)//"Sistema precisa de atualização."##"Execute o compatibilizador UPDFIN."
	EndIf

	If lCompFis .and. lCompFin
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem dos arquivos de trabalho temporarios      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aTabs := FTabTmp(cProv)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamiento para aglutinar datos de las sucursales ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If  !lAglfil

		 	cfilialF3:=xfilial("SF3")
			cfilialF3:= "% SF3.F3_FILIAL = '"+ cfilialF3+ "' %"

			cfilialFE:=xfilial("SFE")
			cfilialFE:= "% SFE.FE_FILIAL = '"+ cfilialFE+ "' %"
			 
		Else
            
        	For nFil:=1 to len(aFilsCalc) 
                If aFilsCalc[nFil,1] == .T.
                    cSucursales+="'"+aFilsCalc[nFil,2] +"',"
                    aFilsCalc[nFil,1]:= .F.
                EndIf
            Next nFil 

            nAux:=RAT("',", cSucursales)//posicion del ultimo "'," 
            cSucursales:=SUBSTR(cSucursales, 1,(nAux)) //elinando "'," que se inserta en el ultimo ciclo

			cfilialF3:= "% SF3.F3_FILIAL IN ("+ cSucursales+") %"
			cfilialFE:= "% SFE.FE_FILIAL IN ("+ cSucursales+") %"

        EndIf 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem da consulta na SF3 - Impostos/Percepcoes  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTipGer $ "P|A"
			cSF3 := AMQryF3(cProv,cImp,cClass,cTabE2,cfilialF3)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem da consulta na SFE - Retencoes            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTipGer $ "R|A"
			cSFE := AMQryFE(cProv,cImp,cClass,cfilialFE)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Preenchimento das tabelas temporarias              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AMArgFil(cProv,cImp,cSFE,cSF3,cTabE1,cTabE2)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a impressao do relatorio de conferencia     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AMArgRel(cProv,cSF3,cSFE)
	EndIf
Return aTabs

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ AMQryF3  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.11.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Montagem da consulta na SF3 - Impostos/Percepcoes          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cProv    - Provincia do arquivo gerado.                    ³±±
±±³            ³ cImp     - Indica o imposto que deve ser carregado os      ³±±
±±³            ³            valores.                                        ³±±
±±³            ³ cClass   - Classe do arquivo S-Sufrida/E-Efetuada.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ cAlias   - Alias criado.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Argentina - MATA950 - Arquivos Magneticos           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AMQryF3(cProv,cImp,cClass,cTabE2,cfilialF3)
	Local cJoin     := "%"
	Local cCampos   := "%"
	Local cFiltro   := "%"
	Local lSFH      := .F.
	Local cAlias    := GetNextAlias()
	Local aArea     := GetArea()
	Local cCpo      := ""
	Local cCpoBase 	:= "F3_BASIMP"
	Local cCpoValor	:= "F3_VALIMP"
	Local cCpoAliq	:= "F3_ALQIMP"
	Local cCpoCont  := "F3_VALCONT"
	Local lSFB      := .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Traz os campos correspondentes ao imposto ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SFB")
	SFB->(dbSetOrder(1))
	If SFB->(dbSeek(xFilial("SFB")+cImp))
		cCpo      := SFB->FB_CPOLVRO
		cCpoBase  += cCpo
		cCpoValor += cCpo
		cCpoAliq  += cCpo
		lSFB      := .T.
	EndIf
	
	If lSFB //Se encontrou o imposto
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ IBXLP - LA PAMPA                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cProv == "LP"
			lSFH := .T.
			cCampos += " ,SA1.A1_END"
			cCampos += " ,SA2.A2_END"
			cCampos += " ,SFH.FH_TIPO,SFH.FH_CONCEP"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ IBXLR - LA RIOJA                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf cProv == "LR"
			cCampos += " ,SF3.F3_VALCONT"
			cCampos += " ,SA1.A1_END"
			cCampos += " ,SA2.A2_END"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ IBXSL - SAN LUIS                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf cProv == "SL"
			lSFH := .T.
			cCampos += " ,SA1.A1_END ,SA2.A2_END"
			cCampos += " ,SA1.A1_MUN ,SA2.A2_MUN"
			cCampos += " ,SA1.A1_CEP ,SA2.A2_CEP"
			cCampos += " ,SA1.A1_EST ,SA2.A2_EST"
			cCampos += " ,SFH.FH_TIPO"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ IBXCA - CATAMARCA                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf cProv == "CA"
			cCampos += " ,SF3.F3_DTCANC"
			cCampos += " ,SA1.A1_END ,SA2.A2_END"
			cCampos += " ,SA1.A1_TEL ,SA2.A2_TEL"
			cCampos += " ,SA1.A1_CEP ,SA2.A2_CEP"
			cCampos += " ,SA1.A1_EST ,SA2.A2_EST"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ IBXCH - CHACO                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		ElseIf cProv == "CH"
			lSFH := .T.
			cCampos += ",SFH.FH_TIPO"				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ IBXSJ - SAN JUAN                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf cProv == "SJ"
			cCampos += " ,SF3.F3_CLIEFOR ,SF3.F3_LOJA ,SF3.F3_DTCANC"
			cCampos += " ,SA1.A1_END ,SA2.A2_END"
			dbSelectArea("SFB")
			SFB->(dbSetOrder(1))
			If SFB->(dbSeek(xFilial("SFB")+cTabE2))
				cCampos += " ,SF3.F3_VALIMP"+SFB->FB_CPOLVRO+" AS HOGAR"
			EndIf
		EndIf
        
		//Campos geral
		cCampos += " ,SF3."+cCpoAliq+" AS ALQIMP"
		cCampos += " ,SF3."+cCpoBase+" AS BASIMP"
		cCampos += " ,SF3."+cCpoValor+" AS VALIMP"
		cCampos += " ,SF3."+cCpoCont+" AS VALCONT"
		cCampos += "%"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtro de especies para movimentos sofridos/efetuados            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cClass == "S" //Sofridos
			cFiltro += " ("
			cFiltro += " ("
			cFiltro += " ( SF3.F3_ESPECIE = 'NF' OR SF3.F3_ESPECIE = 'CF' ) AND"
			cFiltro += "  SF3.F3_TIPOMOV = 'C'"
			cFiltro += " ) OR"
			cFiltro += "   SF3.F3_ESPECIE = 'NDE' OR"
			cFiltro += "   SF3.F3_ESPECIE = 'NCE' OR"
			cFiltro += "   SF3.F3_ESPECIE = 'NDP' OR"
			cFiltro += "   SF3.F3_ESPECIE = 'NCP' "
			cFiltro += " ) AND"
		Else //Efetuados
			cFiltro += " ("
			cFiltro += "  ("
			cFiltro += "  ( SF3.F3_ESPECIE = 'NF' OR SF3.F3_ESPECIE = 'CF' ) AND"
			cFiltro += "   SF3.F3_TIPOMOV = 'V'"
			cFiltro += "  ) OR"
			cFiltro += "   SF3.F3_ESPECIE = 'NDC' OR"
			cFiltro += "   SF3.F3_ESPECIE = 'NCC' OR"
			cFiltro += "   SF3.F3_ESPECIE = 'NDI' OR"
			cFiltro += "   SF3.F3_ESPECIE = 'NCI' "
			cFiltro += " ) AND"
		EndIf
		
		//Filtro geral
		cFiltro += " SF3."+cCpoValor+" > 0 AND"
		cFiltro += "%"
		
		If lSFH
			cJoin += " LEFT JOIN "+RetSqlName("SFH")+" SFH ON"
			cJoin += " SFH.FH_FILIAL = '"+xFilial("SFH")+"' AND"
			cJoin += " ("
			cJoin += "  (SFH.FH_CLIENTE = SA1.A1_COD AND SFH.FH_LOJA = SA1.A1_LOJA)"
			cJoin += " OR"
			cJoin += "  (SFH.FH_FORNECE = SA2.A2_COD AND SFH.FH_LOJA = SA2.A2_LOJA)"
			cJoin += " ) AND"
			cJoin += " SFH.FH_IMPOSTO = '"+cImp+"' AND"
			cJoin += " SFH.FH_ZONFIS = '"+cProv+"' AND"
			If(cProv == "CH")
				cJoin += "  ( (SF3.F3_EMISSAO>=SFH.FH_INIVIGE) AND (SF3.F3_EMISSAO<= SFH.FH_FIMVIGE)) AND"
			EndIf
			cJoin += " SFH.D_E_L_E_T_= ' '"
		EndIf
		cJoin += "%"

		BeginSQL Alias cAlias

			COLUMN F3_EMISSAO AS DATE
			
			SELECT
			SF3.F3_EMISSAO,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_ESPECIE,SF3.F3_TIPOMOV,SF3.F3_CFO,
			SA1.A1_NOME,SA1.A1_NIGB,SA1.A1_CGC,
			SA2.A2_NOME,SA2.A2_NIGB,SA2.A2_CGC
			%Exp:cCampos%
				
			FROM %Table:SF3% SF3
			
			LEFT JOIN %table:SA1% SA1 ON
			SA1.A1_FILIAL = %xFilial:SA1% AND
			SA1.A1_COD = SF3.F3_CLIEFOR AND
			SA1.A1_LOJA = SF3.F3_LOJA AND
			SF3.F3_TIPOMOV = 'V' AND
			SA1.%NotDel%
				
			LEFT JOIN %table:SA2% SA2 ON
			SA2.A2_FILIAL = %xFilial:SA2% AND
			SA2.A2_COD = SF3.F3_CLIEFOR AND
			SA2.A2_LOJA = SF3.F3_LOJA AND
			SF3.F3_TIPOMOV = 'C' AND
			SA2.%NotDel%

			%Exp:cJoin%

			WHERE
			  %Exp:cfilialF3% AND
			(
			SA1.A1_COD IS NOT NULL OR
			SA2.A2_COD IS NOT NULL
			) AND
			SF3.F3_ENTRADA>=%Exp:DtoS(MV_PAR01)% AND
			SF3.F3_ENTRADA<=%Exp:DtoS(MV_PAR02)% AND
			%Exp:cFiltro%
			SF3.%NotDel%
				
			ORDER BY
			SF3.F3_EMISSAO
				
		EndSQL

	EndIf
	
	RestArea(aArea)
Return cAlias

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ AMQryFE  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.11.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Montagem da consulta na SFE - Retencoes                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cProv    - Provincia do arquivo gerado.                    ³±±
±±³            ³ cImp     - Indica o imposto que deve ser carregado os      ³±±
±±³            ³            valores.                                        ³±±
±±³            ³ cClass   - Classe do arquivo S-Sufrida/E-Efetuada.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ cAlias   - Alias criado.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Argentina - MATA950 - Arquivos Magneticos           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AMQryFE(cProv,cImp,cClass,cfilialFE)
	Local cJoin   := "%"
	Local cCampos := "%"
	Local cFiltro := "%"
	Local lSFH    := .F.
	Local cAlias  := GetNextAlias()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ IBXLP - LA PAMPA                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cProv == "LP"
		lSFH := .T.
		cCampos += ",SFE.FE_DTESTOR,SFE.FE_DTRETOR"
		cCampos += ",SFH.FH_ZONFIS,SFH.FH_TIPO,SFH.FH_CONCEP"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ IBXLR - LA RIOJA                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cProv == "LR"
		cCampos += ",SFE.FE_ORDPAGO"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ IBXCH - CHACO                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cProv == "CH"
		lSFH := .T.
		cCampos += ",SFH.FH_CONCEP,SFH.FH_CLAPROD, SFH.FH_TIPO"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ IBXSL - SAN LUIS                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cProv == "SL"
		lSFH := .T.
		cCampos += ",SA1.A1_MUN,SA2.A2_MUN"
		cCampos += ",SA1.A1_CEP,SA2.A2_CEP"
		cCampos += ",SA1.A1_EST,SA2.A2_EST"
		cCampos += ",SFH.FH_TIPO"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ IBXCA - CATAMARCA                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cProv == "CA"
		cCampos += " ,SA1.A1_END ,SA2.A2_END"
		cCampos += " ,SA1.A1_TEL ,SA2.A2_TEL"
		cCampos += " ,SA1.A1_CEP ,SA2.A2_CEP"
		cCampos += " ,SA1.A1_EST ,SA2.A2_EST"
	EndIf
	cCampos += "%"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtro de especies para movimentos sofridos/efetuados            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cClass == "S" //Sofridos
		cFiltro += " SFE.FE_CLIENTE <> ' ' AND"
	Else //Efetuados
		cFiltro += " SFE.FE_FORNECE <> ' ' AND"
	EndIf
	cFiltro += "%"
	
	If lSFH
		cJoin += " LEFT JOIN "+RetSqlName("SFH")+" SFH ON"
		cJoin += " SFH.FH_FILIAL = '"+xFilial("SFH")+"' AND"
		cJoin += " SFH.FH_FORNECE = SA2.A2_COD AND"
		cJoin += " SFH.FH_LOJA = SA2.A2_LOJA AND"
		cJoin += " SFH.FH_IMPOSTO = '"+cImp+"' AND"
		cJoin += " SFH.FH_ZONFIS = '"+cProv+"' AND"
		If(cProv == "CH")
				cJoin += "  ( (SFE.FE_EMISSAO>=SFH.FH_INIVIGE) AND (SFE.FE_EMISSAO<= SFH.FH_FIMVIGE)) AND"
		EndIf
		cJoin += " SFH.D_E_L_E_T_= ' '"
		
	EndIf
	cJoin += "%"
	
	BeginSQL Alias cAlias
	
		COLUMN FE_EMISSAO AS DATE
		COLUMN FE_DTESTOR AS DATE
		COLUMN FE_DTRETOR AS DATE
	
		SELECT
		SFE.FE_EMISSAO,SFE.FE_NROCERT,SFE.FE_NRETORI,SFE.FE_VALBASE,SFE.FE_ALIQ,SFE.FE_RETENC,SFE.FE_CLIENTE,SFE.FE_CFO,
		SA1.A1_NOME,SA1.A1_NIGB,SA1.A1_CGC,SA1.A1_END,
		SA2.A2_NOME,SA2.A2_NIGB,SA2.A2_CGC,SA2.A2_END
		%Exp:cCampos%
	
		FROM %Table:SFE% SFE
		
		LEFT JOIN %table:SA1% SA1 ON
		SA1.A1_FILIAL = %xFilial:SA1% AND
		SA1.A1_COD = SFE.FE_CLIENTE AND
		SA1.A1_LOJA = SFE.FE_LOJCLI AND
		SA1.%NotDel%
			
		LEFT JOIN %table:SA2% SA2 ON
		SA2.A2_FILIAL = %xFilial:SA2% AND
		SA2.A2_COD = SFE.FE_FORNECE AND
		SA2.A2_LOJA = SFE.FE_LOJA AND
		SA2.%NotDel%
			
		%Exp:cJoin%
			
		WHERE
		%Exp:cfilialFE% AND
		SFE.FE_EST = %Exp:cProv% AND
		SFE.FE_EMISSAO>=%Exp:DtoS(MV_PAR01)% AND
		SFE.FE_EMISSAO<=%Exp:DtoS(MV_PAR02)% AND
		(
		SFE.FE_DTESTOR < %Exp:DtoS(MV_PAR01)% OR
		SFE.FE_DTESTOR > %Exp:DtoS(MV_PAR02)% OR
		SFE.FE_DTESTOR = ' ' OR
		SFE.FE_NRETORI <> ' '
		) AND
		(
		SFE.FE_DTRETOR < %Exp:DtoS(MV_PAR01)% OR
		SFE.FE_DTRETOR > %Exp:DtoS(MV_PAR02)% OR
		SFE.FE_DTRETOR = ' ' OR
		SFE.FE_NRETORI = ' '
		) AND
		SFE.FE_TIPO = 'B' AND
		SFE.FE_NROCERT <> 'NORET' AND
		%Exp:cFiltro%
		SFE.%NotDel%
			
		ORDER BY
		SFE.FE_EMISSAO
			
	EndSQL
Return cAlias

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ AMArgFil ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.11.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Preenche as tabelas temporarias com os conteudos           ³±±
±±³            ³ selecionados das consultas a SFE e SF3.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cProv    - Provincia do arquivo gerado.                    ³±±
±±³            ³ cImp     - Indica o imposto que deve ser carregado os      ³±±
±±³            ³            valores.                                        ³±±
±±³            ³ cSF3     - Alias da query dos livros fiscais.              ³±±
±±³            ³ cSFE     - Alias da query de certificados de retencao.     ³±±
±±³            ³ cTBE     - Tabela de equivalencias.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Argentina - MATA950 - Arquivos Magneticos           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AMArgFil(cProv,cImp,cSFE,cSF3,cTabE1,cTabE2)
	Local nAux1 := 0
	Local cAux1 := ""
	Local cAux2 := ""
	Local cConcep := ""
	Local aIT := {}
	Local nPosIT := 0
	Local nX := 0
	Local cConceper := ""
	Local cTabEqui  := ""
	Local cOrigen   := ""	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona na tabela de Estados Vs Ing. Brut ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CCO")
	CCO->(dbSetOrder(1))
	CCO->(dbSeek(xFilial("CCO")+cProv))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da consulta na SF3 - Impostos/Percepcoes  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cSF3) .And. Select(cSF3) > 0
		aIT := {}
		dbSelectArea(cSF3)
		Do While (cSF3)->(!EOF())
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona na tabela de Equivalencias        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cTabE1)
				dbSelectArea("CCP")
				CCP->(dbSetOrder(1))
				CCP->(dbGoTop())
				CCP->(dbSeek(xFilial("CCP")+cTabE1+(cSF3)->F3_CFO))
			EndIf
		    	    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SF3 - IBXLP - LA PAMPA                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cProv == "LP"
			
				If AllTrim((cSF3)->F3_ESPECIE) $ "NCC|NCI"
					nAux1 := -1
				Else
					nAux1 := 1
				EndIf
			
				If (cSF3)->F3_TIPOMOV == "V"
					If !SUJ->(dbSeek((cSF3)->A1_CGC))
						If RecLock("SUJ",.T.)
							SUJ->SUJ_CODJUR := If((cSF3)->FH_TIPO<>'V',"000","9"+CCO->CCO_CODJUR)
							SUJ->SUJ_CUIT   := (cSF3)->A1_CGC
							SUJ->SUJ_INSCRI := (cSF3)->A1_NIGB
							SUJ->SUJ_RAZSOC := (cSF3)->A1_NOME
							SUJ->SUJ_END    := (cSF3)->A1_END
							SUJ->SUJ_DECRET := "0"
							MsUnlock()
						EndIf
					EndIf
				Else
					If !SUJ->(dbSeek((cSF3)->A2_CGC))
						If RecLock("SUJ",.T.)
							SUJ->SUJ_CODJUR := If((cSF3)->FH_TIPO<>'V',"000","9"+CCO->CCO_CODJUR)
							SUJ->SUJ_CUIT   := (cSF3)->A2_CGC
							SUJ->SUJ_INSCRI := (cSF3)->A2_NIGB
							SUJ->SUJ_RAZSOC := (cSF3)->A2_NOME
							SUJ->SUJ_END    := (cSF3)->A2_END
							SUJ->SUJ_DECRET := "0"
							MsUnlock()
						EndIf
					EndIf
				EndIf
				
				If !CAB->(dbSeek(CCO->CCO_REGIMP+StrZero(Year((cSF3)->F3_EMISSAO),4)+StrZero(Month((cSF3)->F3_EMISSAO),2)))
					If RecLock("CAB",.T.)
						CAB->CAB_AGNUM  := SM0->M0_INSC
						CAB->CAB_REGIME := CCO->CCO_REGIMP
						CAB->CAB_ANO    := StrZero(Year((cSF3)->F3_EMISSAO),4)
						CAB->CAB_MES    := StrZero(Month((cSF3)->F3_EMISSAO),2)
						CAB->CAB_NUMFIL := SM0->M0_CODFIL
						MsUnlock()
					EndIf
				EndIf
				
				nPosIT := Ascan(aIT,{|x|x[13] == (cSF3)->F3_NFISCAL .And.  x[14] == CCP->CCP_VDESTI .And. x[11] == (cSF3)->ALQIMP})
				
				If nPosIT == 0
					aAdd(aIT,{"R",SM0->M0_INSC,CCO->CCO_REGIMP,StrZero(Year((cSF3)->F3_EMISSAO),4),StrZero(Month((cSF3)->F3_EMISSAO),2),StrZero(Day((cSF3)->F3_EMISSAO),2),SM0->M0_CODFIL,SUJ->SUJ_CODJUR,SUJ->SUJ_INSCRI,(cSF3)->BASIMP*nAux1,(cSF3)->ALQIMP,(cSF3)->VALIMP*nAux1,(cSF3)->F3_NFISCAL,CCP->CCP_VDESTI})
				Else
					aIT[nPosIT][10] += (cSF3)->BASIMP * nAux1
					aIT[nPosIT][12] += (cSF3)->VALIMP * nAux1
				EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SF3 - IBXMI - MISIONES                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf cProv == "MI"
			
				If cProv $ "MI|SA"
					If AllTrim((cSF3)->F3_ESPECIE) == "NF"
						cAux1 := "FA_"
					Else
						cAux1 := SubStr((cSF3)->F3_ESPECIE,1,2)+"_"
					EndIf
					
					If SubStr(AllTrim((cSF3)->F3_SERIE),1,1) $ "A|B|C"
						cAux1 += AllTrim((cSF3)->F3_SERIE)
					Else
						cAux1 := "OTRO"
					EndIf
				EndIf
		
				If RecLock("PER",.T.)
					PER->PER_EMISS  := (cSF3)->F3_EMISSAO
					PER->PER_TIPCOM := cAux1
					PER->PER_NUMCOM := (cSF3)->F3_NFISCAL
					PER->PER_NOME   := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_NOME,(cSF3)->A2_NOME)
					PER->PER_CUIT   := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_CGC,(cSF3)->A2_CGC)
					PER->PER_BASIMP := (cSF3)->BASIMP
					PER->PER_ALQIMP := (cSF3)->ALQIMP
					MsUnlock()
				EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SF3 - IBXLR - LA RIOJA                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf cProv == "LR"
			
				If AllTrim((cSF3)->F3_ESPECIE) $ "NCC|NCI"
					nAux1 := -1
				Else
					nAux1 := 1
				EndIf
			
				If RecLock("PER",.T.)
					PER->PER_CUIT   := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_CGC,(cSF3)->A2_CGC)
					PER->PER_INSCRI := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_NIGB,(cSF3)->A2_NIGB)
					PER->PER_NOME   := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_NOME,(cSF3)->A2_NOME)
					PER->PER_END    := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_END,(cSF3)->A2_END)
					PER->PER_EMISS  := (cSF3)->F3_EMISSAO
					PER->PER_IMPTOT := (cSF3)->F3_VALCONT
					PER->PER_BASIMP := (cSF3)->BASIMP
					PER->PER_ALIQ   := (cSF3)->ALQIMP
					PER->PER_VALIMP := (cSF3)->VALIMP*nAux1
					PER->PER_COMPOP := (cSF3)->F3_NFISCAL
					MsUnlock()
				EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SF3 - IBXSA - SALTA                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf cProv == "SA"
			
				If AllTrim((cSF3)->F3_ESPECIE) $ "NCC|NDE|NDI|NCI|NCP"
					nAux1 := -1
				Else
					nAux1 := 1
				EndIf
			
				If cProv $ "MI|SA"
					If AllTrim((cSF3)->F3_ESPECIE) == "NF"
						cAux1 := "FA_"
					Else
						cAux1 := SubStr((cSF3)->F3_ESPECIE,1,2)+"_"
					EndIf
		
					If AllTrim((cSF3)->F3_SERIE) $ "A|B|C"
						cAux1 += AllTrim((cSF3)->F3_SERIE)
					Else
						cAux1 := "OTRO"
					EndIf
				EndIf
			
				If RecLock("PER",.T.)
					PER->PER_EMISS  := (cSF3)->F3_EMISSAO
					PER->PER_TIPCOM := cAux1
					PER->PER_NUMCOM := (cSF3)->F3_NFISCAL
					PER->PER_RAZSOC := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_NOME,(cSF3)->A2_NOME)
					PER->PER_CUIT   := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_CGC,(cSF3)->A2_CGC)
					PER->PER_BASIMP := (cSF3)->BASIMP*If((cSF3)->F3_ESPECIE=="NCP",1,nAux1)
					PER->PER_ALIQ	:= (cSF3)->ALQIMP 
					PER->PER_VALIMP := (cSF3)->VALIMP*nAux1
					MsUnlock()
				EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SF3 - IBXCH - CHACO                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf cProv == "CH"
				//TABLA DE EQUIVALENCIA				
				If (cSF3)->FH_TIPO $ "V|N"
					If !Empty(cTabE2)
						cTabEqui := cTabE2
						cOrigen := (cSF3)->FH_TIPO
					EndIf  
				Else
					If !Empty(cTabE1)
						cTabEqui := cTabE1
						cOrigen := (cSF3)->F3_CFO
					EndIf
				EndIf
				dbSelectArea("CCP")
				CCP->(dbSetOrder(1))
				CCP->(dbGoTop())
				If CCP->(dbSeek(xFilial("CCP")+cTabEqui+cOrigen))
					cConceper := CCP->CCP_VDESTI
				Else
					cConceper := ""					
				EndIf	
							
				//Define o tipo do comprovante.
				If SubStr((cSF3)->F3_ESPECIE,1,2) == "NC"
					If AllTrim((cSF3)->F3_SERIE) == "B"
						cAux1 := "6"
					Else
						cAux1 := "5"
					EndIf
				Else
					If AllTrim((cSF3)->F3_SERIE) == "B"
						cAux1 := "2"
					Else
						cAux1 := "1"
					EndIf
				EndIf
		
				If RecLock("PER",.T.)
					PER->PER_TIPCOM := cAux1
					PER->PER_NUMCOM := (cSF3)->F3_NFISCAL
					PER->PER_CUIT   := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_CGC,(cSF3)->A2_CGC)
					PER->PER_NOME   := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_NOME,(cSF3)->A2_NOME)
					PER->PER_EMISS  := (cSF3)->F3_EMISSAO
					PER->PER_VALIMP := (cSF3)->VALIMP
					PER->PER_CONCEP := cConceper
					PER->PER_BASIMP := (cSF3)->BASIMP
					PER->PER_ALQIMP := (cSF3)->ALQIMP
					MsUnlock()
				EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ IBXSL - SAN LUIS                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf cProv == "SL"
			
				If AllTrim((cSF3)->F3_ESPECIE) $ "NCC|NCI"
					nAux1 := -1
				Else
					nAux1 := 1
				EndIf
				If !SUJ->(dbSeek(If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_CGC,(cSF3)->A2_CGC)))
					If RecLock("SUJ",.T.)
						SUJ->SUJ_CUIT   := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_CGC,(cSF3)->A2_CGC)
						SUJ->SUJ_NOME   := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_NOME,(cSF3)->A2_NOME)
						SUJ->SUJ_NINGB  := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_NIGB,(cSF3)->A2_NIGB)
						SUJ->SUJ_END    := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_END,(cSF3)->A2_END)
						SUJ->SUJ_LOCAL  := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_MUN,(cSF3)->A2_MUN)
						SUJ->SUJ_CODPST := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_CEP,(cSF3)->A2_CEP)
						SUJ->SUJ_PROV   := Posicione("SX5",1,xFilial("SX5")+"12"+If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_EST,(cSF3)->A2_EST),"X5_DESCSPA")
						MsUnlock()
					EndIf
				EndIf
			
				//Define o tipo do comprovante.
				If SubStr((cSF3)->F3_ESPECIE,1,2) == "NF"
					cAux1 := "002"
				ElseIf SubStr((cSF3)->F3_ESPECIE,1,2) == "NC"
					cAux1 := "003"
				Else
					cAux1 := "004"
				EndIf
				
				//Define o tipo do sujeito
				If (cSF3)->FH_TIPO $ "I|N"
					cAux2 := "001"
				ElseIf (cSF3)->FH_TIPO == "V"
					cAux2 := "005"
				ElseIf (cSF3)->FH_TIPO $ "X|M"
					cAux2 := "006"
				EndIf
			
				If RecLock("PER",.T.)
					PER->PER_EMISS  := (cSF3)->F3_EMISSAO
					PER->PER_TIPCOM := cAux1
					PER->PER_NUMCOM := (cSF3)->F3_NFISCAL
					PER->PER_CUIT   := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_CGC,(cSF3)->A2_CGC)
					PER->PER_TIPSUJ := cAux2
					PER->PER_INSCRI := If((cSF3)->FH_TIPO$"I|V","S","N")
					PER->PER_MONTOT := ((cSF3)->VALCONT)*nAux1
					PER->PER_MONSUJ := ((cSF3)->BASIMP)*nAux1
					PER->PER_ALIQ   := (cSF3)->ALQIMP
					PER->PER_CODALI := CCP->CCP_VDESTI
					PER->PER_VALIMP := ((cSF3)->VALIMP)*nAux1
					MsUnlock()
				EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ IBXCA - CATAMARCA                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf cProv == "CA"
			
				If !Empty(cTabE2)
					dbSelectArea("CCP")
					CCP->(dbSetOrder(1))
					CCP->(dbGoTop())
					CCP->(dbSeek(xFilial("CCP")+cTabE2+If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_EST,(cSF3)->A2_EST)))
				EndIf
			
				//Define o tipo do comprovante.
				If SubStr((cSF3)->F3_ESPECIE,1,2) == "NF"
					nAux1 := 1
				ElseIf SubStr((cSF3)->F3_ESPECIE,1,2) == "NC"
					nAux1 := 3
				ElseIf SubStr((cSF3)->F3_ESPECIE,1,2) == "ND"
					nAux1 := 5
				Else
					nAux1 := 7
				EndIf
				
				If AllTrim((cSF3)->F3_SERIE) == "B" .and. nAux1 < 7
					nAux1++
				EndIf

				If RecLock("PER",.T.)
					PER->PER_TIPCOM := AllTrim(Str(nAux1))
					PER->PER_NUMCOM := (cSF3)->F3_NFISCAL
					PER->PER_EMISS  := (cSF3)->F3_EMISSAO
					PER->PER_INSCRI := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_NIGB,(cSF3)->A2_NIGB)
					PER->PER_NOME   := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_NOME,(cSF3)->A2_NOME)
					PER->PER_CUIT   := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_CGC,(cSF3)->A2_CGC)
					PER->PER_BASIMP := (cSF3)->BASIMP
					PER->PER_ALQIMP := (cSF3)->ALQIMP
					PER->PER_VALIMP := (cSF3)->VALIMP
					PER->PER_ESTADO := If(!Empty((cSF3)->F3_DTCANC),"2","1")
					PER->PER_DOMICI := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_END,(cSF3)->A2_END)
					PER->PER_TEL    := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_TEL,(cSF3)->A2_TEL)
					PER->PER_CODPOS := If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_CEP,(cSF3)->A2_CEP)
					PER->PER_PROVIN := CCP->CCP_VDESTI
					MsUnlock()
				EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ IBXSJ - SAN JUAN                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf cProv == "SJ"
				
				cAux1 := SubStr((cSF3)->F3_ESPECIE,2,1) + SubStr((cSF3)->F3_SERIE,1,1)
					
				If RecLock("PER",.T.)
					PER->PER_RAZSOC := SubStr(If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_NOME,(cSF3)->A2_NOME),1,80)		// 1 Razón Social / Nombre del sujeto percibido
					PER->PER_CUIT   := SubStr(If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_CGC,(cSF3)->A2_CGC),1,11) 		// 2 Número de CUIL / CUIT del sujeto percibido
					PER->PER_DOMICI := SubStr(If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_END,(cSF3)->A2_END),1,120) 		// 3 Domicilio fiscal del sujeto percibido
					PER->PER_INSCRI := SubStr(If((cSF3)->F3_TIPOMOV=="V",(cSF3)->A1_NIGB,(cSF3)->A2_NIGB),1,16) 	// 4 Número de Inscripción en Ingresos . Brutos del sujeto percibido
					PER->PER_EMISS  := DTOC((cSF3)->F3_EMISSAO)														// 5 Fecha del comprobante
					PER->PER_TIPCOM := cAux1																		// 6 Tipo de Comprobante 
					PER->PER_NUMCOM := SubStr((cSF3)->F3_NFISCAL,1,12)												// 7 Número de Comprobante 
					PER->PER_BASIMP := (cSF3)->BASIMP																// 8 Base Imponible
					PER->PER_ALQIMP := (cSF3)->ALQIMP																// 9 Alícuota 
					PER->PER_VALIMP := (cSF3)->VALIMP																// 10 Importe Percibido Ingresos Brutos
					PER->PER_HOGAR  := 0.00																			// 11 Uso DGR 
					PER->PER_TIPANU := ""																			// 12 Tipo de Comprobante Anulado 
					PER->PER_NUMANU := ""																			// 13 Número de Comprobante Anulado
					MsUnlock()
				EndIf
			
			EndIf
		    
			(cSF3)->(dbSkip())
		EndDo		
		
		If cProv == "LP"
			If Len(aIT) > 0
				LlenaTab("IT", {"IT_LETRA","IT_AGNUM","IT_REGIME","IT_ANO","IT_MES","IT_DIA","IT_NUMFIL","IT_CODJUR","IT_INSCRI","IT_IMPBRT","IT_ALIQ","IT_IMPORT","IT_COMPRV","IT_CONCEP"}, aIT)
			EndIf
		EndIf
	EndIf
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da consulta na SFE - Retencoes            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cSFE) .And. Select(cSFE) > 0
		aIT := {}
		dbSelectArea(cSFE)
		Do While (cSFE)->(!EOF())
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona na tabela de Equivalencias        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cTabE2)
				dbSelectArea("CCP")
				CCP->(dbSetOrder(1))
				CCP->(dbGoTop())
				CCP->(dbSeek(xFilial("CCP")+cTabE2+(cSFE)->FE_CFO))
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SFE - IBXLP - LA PAMPA                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cProv == "LP"
			
				If !SUJ->(dbSeek((cSFE)->A2_CGC))
					If RecLock("SUJ",.T.)
						SUJ->SUJ_CODJUR := If((cSFE)->FH_TIPO<>'V',"000","9"+CCO->CCO_CODJUR)
						SUJ->SUJ_CUIT   := (cSFE)->A2_CGC
						SUJ->SUJ_INSCRI := (cSFE)->A2_NIGB
						SUJ->SUJ_RAZSOC := (cSFE)->A2_NOME
						SUJ->SUJ_END    := (cSFE)->A2_END
						SUJ->SUJ_DECRET := "3"
						MsUnlock()
					EndIf
				Else
					If SUJ->SUJ_DECRET <> "3"
						If RecLock("SUJ",.F.)
							SUJ->SUJ_DECRET := "3"
							MsUnlock()
						EndIf
					EndIf
				EndIf
				
				If !CAB->(dbSeek(CCO->CCO_REGIME+StrZero(Year((cSFE)->FE_EMISSAO),4)+StrZero(Month((cSFE)->FE_EMISSAO),2)))
					If RecLock("CAB",.T.)
						CAB->CAB_AGNUM  := SM0->M0_INSC
						CAB->CAB_REGIME := CCO->CCO_REGIME
						CAB->CAB_ANO    := StrZero(Year((cSFE)->FE_EMISSAO),4)
						CAB->CAB_MES    := StrZero(Month((cSFE)->FE_EMISSAO),2)
						CAB->CAB_NUMFIL := SM0->M0_CODFIL
						MsUnlock()
					EndIf
				EndIf
	
				nPosIT := Ascan(aIT,{|x|x[13] == SubStr((cSFE)->FE_NROCERT,Len((cSFE)->FE_NROCERT)-12,Len((cSFE)->FE_NROCERT)) .and.  x[14] == CCP->CCP_VDESTI .and. x[11] == (cSFE)->FE_ALIQ})
				
				If nPosIT == 0
					aAdd(aIT,{"R",SM0->M0_INSC,CCO->CCO_REGIME,StrZero(Year((cSFE)->FE_EMISSAO),4),StrZero(Month((cSFE)->FE_EMISSAO),2),StrZero(Day((cSFE)->FE_EMISSAO),2),SM0->M0_CODFIL,SUJ->SUJ_CODJUR,SUJ->SUJ_INSCRI,(cSFE)->FE_VALBASE,(cSFE)->FE_ALIQ,(cSFE)->FE_RETENC,SubStr((cSFE)->FE_NROCERT,Len((cSFE)->FE_NROCERT)-12,Len((cSFE)->FE_NROCERT)),CCP->CCP_VDESTI})
				Else
					aIT[nPosIT][10] += (cSFE)->FE_VALBASE
					aIT[nPosIT][12] += (cSFE)->FE_RETENC
				EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SFE - IBXMI - MISIONES                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf cProv == "MI"
			
				If RecLock("RET",.T.)
					RET->RET_EMISS  := (cSFE)->FE_EMISSAO
					RET->RET_CONST  := (cSFE)->FE_NROCERT
					RET->RET_NOME   := (cSFE)->A2_NOME
					RET->RET_END    := (cSFE)->A2_END
					RET->RET_CUIT   := (cSFE)->A2_CGC
					RET->RET_BASIMP := (cSFE)->FE_VALBASE
					RET->RET_ALQIMP := (cSFE)->FE_ALIQ
					MsUnlock()
				EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SFE - IBXLR - LA RIOJA                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf cProv == "LR"
			
				If !Empty((cSFE)->FE_NRETORI)
					nAux1 := -1
				Else
					nAux1 := 1
				EndIf
				cNumCert:=SubStr((cSFE)->FE_NROCERT,Len((cSFE)->FE_NROCERT)-11,12)
				If RET->(DbSeek(Subs((cSFE)->A2_CGC,1,Len(RET->RET_CUIT)) + cNumCert))   // Verifica se certificado já existe
					RecLock("RET",.F.)
					RET->RET_IMPTOT := RET->RET_IMPTOT + ((cSFE)->FE_VALBASE)
					RET->RET_BASIMP := RET->RET_BASIMP + ((cSFE)->FE_VALBASE)
					RET->RET_VALIMP := RET->RET_VALIMP + ((cSFE)->FE_RETENC)
					MsUnlock()
				Else
					If RecLock("RET",.T.)
						RET->RET_CUIT   := (cSFE)->A2_CGC
						RET->RET_CERTF  := cNumCert
						RET->RET_INSCRI := (cSFE)->A2_NIGB
						RET->RET_NOME   := (cSFE)->A2_NOME
						RET->RET_END    := (cSFE)->A2_END
						RET->RET_EMISS  := (cSFE)->FE_EMISSAO
						RET->RET_IMPTOT := (cSFE)->FE_VALBASE*nAux1
						RET->RET_BASIMP := (cSFE)->FE_VALBASE*nAux1
						RET->RET_ALIQ   := (cSFE)->FE_ALIQ
						RET->RET_VALIMP := (cSFE)->FE_RETENC*nAux1
						RET->RET_COMPOP := (cSFE)->FE_ORDPAGO
						MsUnlock()
					EndIf
				EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SFE - IBXSA - SALTA                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf cProv == "SA"
			
				If !Empty((cSFE)->FE_NRETORI)
					nAux1 := -1
				Else
					nAux1 := 1
				EndIf
			
				If RecLock("RET",.T.)
					RET->RET_EMISS  := (cSFE)->FE_EMISSAO
					RET->RET_CONST  := SubStr((cSFE)->FE_NROCERT,Len((cSFE)->FE_NROCERT)-14,15)
					RET->RET_RAZSOC := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_NOME,(cSFE)->A2_NOME)
					RET->RET_END    := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_END,(cSFE)->A2_END)
					RET->RET_CUIT   := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_CGC,(cSFE)->A2_CGC)
					RET->RET_BASIMP := (cSFE)->FE_VALBASE*nAux1
					RET->RET_ALIQ	:= (cSFE)->FE_ALIQ 
					RET->RET_RETENC := (cSFE)->FE_RETENC*nAux1
					MsUnlock()
				EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SFE - IBXCH - CHACO                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf cProv == "CH"
				If !Empty(cTabE1)
					dbSelectArea("CCP")
					CCP->(dbSetOrder(1))
					CCP->(dbGoTop())
					If CCP->(dbSeek(xFilial("CCP")+cTabE1+(cSFE)->FE_CFO))
						cConcep := CCP->CCP_VDESTI
					Else
						cConcep := Space(2)
					EndIf
				EndIf			
				If Empty((cSFE)->FE_NRETORI) .or. (cSFE)->FE_VALBASE > 0
					cNumCert:=SubStr((cSFE)->FE_NROCERT,Len((cSFE)->FE_NROCERT)-5,6)
					cCuit:= If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_CGC,(cSFE)->A2_CGC)
				
					If RET->(DbSeek(Subs(cCuit,1,Len(RET->RET_CUIT)) + cNumCert))   // Verifica se certificado já existe
						RecLock("RET",.F.)
						RET->RET_RETENC := RET->RET_RETENC + ((cSFE)->FE_RETENC)
						RET->RET_BASIMP := RET->RET_BASIMP + ((cSFE)->FE_VALBASE)
						MsUnlock()
					Else
						If RecLock("RET",.T.)
							RET->RET_COMP   := cNumCert
							RET->RET_CUIT   := cCuit
							RET->RET_NOME   := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_NOME,(cSFE)->A2_NOME)
							RET->RET_END    := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_END,(cSFE)->A2_END)
							RET->RET_EMISS  := (cSFE)->FE_EMISSAO
							RET->RET_RETENC := (cSFE)->FE_RETENC
							If (cSFE)->FH_TIPO $ "V|N"
								If !Empty(cTabE2)
									dbSelectArea("CCP")
									CCP->(dbSetOrder(1))
									CCP->(dbGoTop())
									If CCP->(dbSeek(xFilial("CCP")+cTabE2+(cSFE)->FH_TIPO))
										cConcep := CCP->CCP_VDESTI
									EndIf
								EndIf   
							EndIf							
							RET->RET_CONCEP := cConcep
							RET->RET_BASIMP := (cSFE)->FE_VALBASE
							RET->RET_ALQIMP := (cSFE)->FE_ALIQ
							RET->RET_CODPRO := (cSFE)->FH_CLAPROD
							MsUnlock()
						EndIf
					EndIf
				EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ IBXSL - SAN LUIS                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf cProv == "SL"
			
				//Define o tipo do sujeito
				If (cSFE)->FH_TIPO $ "I|X|M"
					cAux1 := "IIBB DIRECTO"
				ElseIf (cSFE)->FH_TIPO == "V"
					cAux1 := "CML"
				ElseIf (cSFE)->FH_TIPO == "N"
					cAux1 := "NO INSCRIPTO"
				EndIf
			
				If !SUJ->(dbSeek(If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_CGC,(cSFE)->A2_CGC)))
					If RecLock("SUJ",.T.)
						SUJ->SUJ_CUIT   := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_CGC,(cSFE)->A2_CGC)
						SUJ->SUJ_NOME   := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_NOME,(cSFE)->A2_NOME)
						SUJ->SUJ_TIPOIB := cAux1+Space(12)
						SUJ->SUJ_NINGB  := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_NIGB,(cSFE)->A2_NIGB)
						SUJ->SUJ_END    := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_END,(cSFE)->A2_END)
						SUJ->SUJ_LOCAL  := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_MUN,(cSFE)->A2_MUN)
						SUJ->SUJ_CODPST := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_CEP,(cSFE)->A2_CEP)
						SUJ->SUJ_PROV   := Posicione("SX5",1,xFilial("SX5")+"12"+If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_EST,(cSFE)->A2_EST),"X5_DESCSPA")
						MsUnlock()
					EndIf
				EndIf
				
				If RecLock("RET",.T.)
					RET->RET_NUMCOM := SubStr((cSFE)->FE_NROCERT,Len((cSFE)->FE_NROCERT)-5,6)
					RET->RET_EMISS  := (cSFE)->FE_EMISSAO
					RET->RET_CUIT   := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_CGC,(cSFE)->A2_CGC)
					RET->RET_CONCEP := CCP->CCP_VDESTI
					RET->RET_MONTO  := (cSFE)->FE_VALBASE
					RET->RET_PERCNT := ((cSFE)->FE_RETENC/(cSFE)->FE_ALIQ*100)/(cSFE)->FE_VALBASE*100
					RET->RET_ALIQ   := (cSFE)->FE_ALIQ
					RET->RET_RETENC := (cSFE)->FE_RETENC
					RET->RET_ANUL   := If(!Empty((cSFE)->FE_NRETORI),"S","N")
					MsUnlock()
				EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ IBXCA - CATAMARCA                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf cProv == "CA"
			
				If !Empty(cTabE2)
					dbSelectArea("CCP")
					CCP->(dbSetOrder(1))
					CCP->(dbGoTop())
					CCP->(dbSeek(xFilial("CCP")+cTabE2+If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_EST,(cSFE)->A2_EST)))
				EndIf
				
				cNumCert:=SubStr((cSFE)->FE_NROCERT,Len((cSFE)->FE_NROCERT)-9,10)
				cCuit:= If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_CGC,(cSFE)->A2_CGC)
			
				If RET->(dbSeek(Subs(cCuit,1,Len(RET->RET_CUIT)) + cNumCert))   // Verifica se certificado já existe
					If RecLock("RET",.F.)
						RET->RET_BASIMP += (cSFE)->FE_VALBASE
						RET->RET_VALIMP += (cSFE)->FE_RETENC
						MsUnlock()
					EndIf
				Else
					If RecLock("RET",.T.)
						RET->RET_NUMCOM := SubStr((cSFE)->FE_NROCERT,Len((cSFE)->FE_NROCERT)-9,10)
						RET->RET_EMISS  := (cSFE)->FE_EMISSAO
						RET->RET_INSCRI := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_NIGB,(cSFE)->A2_NIGB)
						RET->RET_NOME   := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_NOME,(cSFE)->A2_NOME)
						RET->RET_CUIT   := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_CGC,(cSFE)->A2_CGC)
						RET->RET_BASIMP := (cSFE)->FE_VALBASE*Iif((cSFE)->FE_VALBASE<0,-1,1)
						RET->RET_ALQIMP := (cSFE)->FE_ALIQ
						RET->RET_VALIMP := (cSFE)->FE_RETENC*Iif((cSFE)->FE_RETENC<0,-1,1)
						RET->RET_ESTADO := If(!Empty((cSFE)->FE_NRETORI),"2","1")
						RET->RET_DOMICI := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_END,(cSFE)->A2_END)
						RET->RET_TEL    := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_TEL,(cSFE)->A2_TEL)
						RET->RET_CODPOS := If(!Empty((cSFE)->FE_CLIENTE),(cSFE)->A1_CEP,(cSFE)->A2_CEP)
						RET->RET_PROVIN := CCP->CCP_VDESTI
						MsUnlock()
					EndIf
				EndIf
				
			EndIf
			
			(cSFE)->(dbSkip())
		EndDo
		
		If cProv == "LP"
			If Len(aIT) > 0
				LlenaTab("IT", {"IT_LETRA","IT_AGNUM","IT_REGIME","IT_ANO","IT_MES","IT_DIA","IT_NUMFIL","IT_CODJUR","IT_INSCRI","IT_IMPBRT","IT_ALIQ","IT_IMPORT","IT_COMPRV","IT_CONCEP"}, aIT)
			EndIf
		EndIf
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ AMArgPos ³ Autor ³ Ivan Haponczuk      ³ Data ³ 09.11.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Executa operacoes apos a geracao dos arquivos magneticos.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cProv    - Provincia do arquivo gerado.                    ³±±
±±³            ³ aTabs    - [1] Nome do alias criado.                       ³±±
±±³            ³            [2] Nome do arquivo fisico criado.              ³±±
±±³            ³            [3] Indice de ordenacao do arquivo.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Argentina - MATA950 - Arquivos Magneticos           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AMArgPos(cProv,aTabs)
	Local nI := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha e exclui os arquivos de trabalho temporarios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	For nI:=1 To Len(aTabs)
		If Select(aTabs[nI,1]) > 0
			dbSelectArea(aTabs[nI,1])
			dbCloseArea()
		EndIf
	Next nI
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ FTabTmp  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 09.11.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Montagem dos arquivos de trabalho temporarios.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cProv    - Provincia do arquivo gerado.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ aTabs    - [1] Nome do alias criado.                       ³±±
±±³            ³            [2] Nome do arquivo fisico criado.              ³±±
±±³            ³            [3] Indice de ordenacao do arquivo.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Argentina - MATA950 - Arquivos Magneticos           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FTabTmp(cProv)
	Local nI      := 0
	Local cAlias  := ""
	Local cIndice := ""
	Local cTabTmp := ""
	Local aTabs   := {}
	Local aStrut  := {}
	Local cTmp := "oTmpTable"

	Default cProv := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ IBXLP - LA PAMPA                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cProv == "LP"

		//Sujeitos
		aStrut := {}
		aAdd(aStrut,{"SUJ_CODJUR","C",003,0})//Codigo da jurisdicao CCO_CODJUR
		aAdd(aStrut,{"SUJ_INSCRI","C",007,0})//Numero de inscricao A1_NIGB e A2_NIGB
		aAdd(aStrut,{"SUJ_CUIT"  ,"C",011,0})//CUIT A1_CGC e A2_CGC
		aAdd(aStrut,{"SUJ_RAZSOC","C",040,0})//Razao social A1_NOME e A2_NOME
		aAdd(aStrut,{"SUJ_END"   ,"C",040,0})//Endereco A1_END e A2_END
		aAdd(aStrut,{"SUJ_DECRET","C",001,0})//Constancia de nao retencao
		
		cAlias  := "SUJ"
		aOrdem := {"SUJ_CUIT"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})

		//Cabecalho
		aStrut := {}
		aAdd(aStrut,{"CAB_AGNUM" ,"C",006,0})//Numero do agente de retencao
		aAdd(aStrut,{"CAB_REGIME","C",002,0})//Codigo do regime
		aAdd(aStrut,{"CAB_ANO"   ,"C",004,0})//Ano de emissao
		aAdd(aStrut,{"CAB_MES"   ,"C",002,0})//Mes de emissao
		aAdd(aStrut,{"CAB_NUMFIL","C",004,0})//Numero da filial
		
		cAlias  := "CAB"
		aOrdem := {"CAB_REGIME","CAB_ANO","CAB_MES"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
		
		//Itens
		aStrut := {}
		aAdd(aStrut,{"IT_LETRA" ,"C",001,0})//Letra (R-Registro valido,A-Anulado)
		aAdd(aStrut,{"IT_AGNUM" ,"C",006,0})//Numero do agente de retencao
		aAdd(aStrut,{"IT_REGIME","C",002,0})//Codigo do regime
		aAdd(aStrut,{"IT_ANO"   ,"C",004,0})//Ano de emissao
		aAdd(aStrut,{"IT_MES"   ,"C",002,0})//Mes de emissao
		aAdd(aStrut,{"IT_DIA"   ,"C",002,0})//Dia de emissao
		aAdd(aStrut,{"IT_NUMFIL","C",004,0})//Numero da filial
		aAdd(aStrut,{"IT_CODJUR","C",003,0})//Codigo de jurisdicao
		aAdd(aStrut,{"IT_INSCRI","C",007,0})//Numero de inscricao
		aAdd(aStrut,{"IT_IMPBRT","N",012,2})//Importe bruto
		aAdd(aStrut,{"IT_ALIQ"  ,"N",005,2})//Aliquota
		aAdd(aStrut,{"IT_IMPORT","N",012,2})//Importe ret/per
		aAdd(aStrut,{"IT_COMPRV","C",013,0})//Numero do comprovante
		aAdd(aStrut,{"IT_CONCEP","C",002,0})//Codigo do conceito
		
		cAlias  := "IT"
		aOrdem := {"IT_LETRA","IT_AGNUM","IT_REGIME","IT_DIA"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ IBXMI - MISIONES                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cProv == "MI"
	
		aStrut := {}
		aAdd(aStrut,{"PER_EMISS" ,"D",008,0})//Emissao
		aAdd(aStrut,{"PER_TIPCOM","C",004,0})//Tipo do comprovante
		aAdd(aStrut,{"PER_NUMCOM","C",015,0})//Numero do comprovante
		aAdd(aStrut,{"PER_NOME"  ,"C",040,0})//Razao social
		aAdd(aStrut,{"PER_CUIT"  ,"C",011,0})//CUIT
		aAdd(aStrut,{"PER_BASIMP","N",012,2})//Importe da operacao
		aAdd(aStrut,{"PER_ALQIMP","N",005,2})//Aliquota
		
		cAlias  := "PER"
		aOrdem := {"PER_EMISS"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})

		aStrut := {}
		aAdd(aStrut,{"RET_EMISS" ,"D",008,0})//Emissao
		aAdd(aStrut,{"RET_CONST" ,"C",015,0})//Constancia
		aAdd(aStrut,{"RET_NOME"  ,"C",040,0})//Razao social
		aAdd(aStrut,{"RET_END"   ,"C",040,0})//Endereco
		aAdd(aStrut,{"RET_CUIT"  ,"C",011,0})//CUIT
		aAdd(aStrut,{"RET_BASIMP","N",012,2})//Importe da operacao
		aAdd(aStrut,{"RET_ALQIMP","N",005,2})//Aliquota
		
		cAlias  := "RET"
		aOrdem := {"RET_EMISS"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ IBXLR - LA RIOJA                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cProv == "LR"
	
		aStrut := {}
		aAdd(aStrut,{"PER_CUIT"  ,"C",011,0})//CUIT
		aAdd(aStrut,{"PER_INSCRI","C",010,0})//Numero de incricao
		aAdd(aStrut,{"PER_NOME"  ,"C",040,0})//Razao social
		aAdd(aStrut,{"PER_END"   ,"C",040,0})//Endereco
		aAdd(aStrut,{"PER_EMISS" ,"D",008,0})//Emissao
		aAdd(aStrut,{"PER_IMPTOT","N",016,2})//Importe total
		aAdd(aStrut,{"PER_BASIMP","N",016,2})//Base
		aAdd(aStrut,{"PER_ALIQ"  ,"N",005,2})//Aliquota
		aAdd(aStrut,{"PER_VALIMP","N",016,2})//Valor
		aAdd(aStrut,{"PER_COMPOP","C",012,0})//Comprovante da operacao
		
		cAlias  := "PER"
		aOrdem := {"PER_CUIT"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
		
		aStrut := {}
		aAdd(aStrut,{"RET_CUIT"  ,"C",011,0})//CUIT
		aAdd(aStrut,{"RET_CERTF" ,"C",012,0})//Numero de certificado
		aAdd(aStrut,{"RET_INSCRI","C",010,0})//Numero de incricao
		aAdd(aStrut,{"RET_NOME"  ,"C",040,0})//Razao social
		aAdd(aStrut,{"RET_END"   ,"C",040,0})//Endereco
		aAdd(aStrut,{"RET_EMISS" ,"D",008,0})//Emissao
		aAdd(aStrut,{"RET_IMPTOT","N",016,2})//Importe total
		aAdd(aStrut,{"RET_BASIMP","N",016,2})//Base
		aAdd(aStrut,{"RET_ALIQ"  ,"N",005,2})//Aliquota
		aAdd(aStrut,{"RET_VALIMP","N",016,2})//Valor
		aAdd(aStrut,{"RET_COMPOP","C",012,0})//Comprovante da operacao
		
		cAlias  := "RET"
		aOrdem := {"RET_CUIT","RET_CERTF"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ IBXLR - SALTA                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cProv == "SA"
	
		aStrut := {}
		aAdd(aStrut,{"PER_EMISS" ,"D",008,0})//Emissao
		aAdd(aStrut,{"PER_TIPCOM","C",004,0})//Tipo comprovante
		aAdd(aStrut,{"PER_NUMCOM","C",020,0})//N Comprovante
		aAdd(aStrut,{"PER_RAZSOC","C",060,0})//Razao social
		aAdd(aStrut,{"PER_CUIT"  ,"C",011,0})//CUIT
		aAdd(aStrut,{"PER_BASIMP","N",016,2})//Monto de las operaciones
		aAdd(aStrut,{"PER_ALIQ"  ,"N",005,2})//ALIQ
		aAdd(aStrut,{"PER_VALIMP","N",016,2})//Importe percebido
		
		cAlias  := "PER"
		aOrdem := {"PER_EMISS"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
		
		aStrut := {}
		aAdd(aStrut,{"RET_EMISS" ,"D",008,0})//Emissao
		aAdd(aStrut,{"RET_CONST" ,"C",015,0})//N Constancia
		aAdd(aStrut,{"RET_RAZSOC","C",060,0})//Razao social
		aAdd(aStrut,{"RET_END"   ,"C",060,0})//Endereco
		aAdd(aStrut,{"RET_CUIT"  ,"C",011,0})//CUIT
		aAdd(aStrut,{"RET_BASIMP","N",016,2})//Monto de las operaciones
		aAdd(aStrut,{"RET_ALIQ"  ,"N",005,2})//ALIQ
		aAdd(aStrut,{"RET_RETENC","N",016,2})//Importe retenido
		
		cAlias  := "RET"
		aOrdem := {"RET_EMISS"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ IBXLR - CHACO                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cProv == "CH"

		aStrut := {}
		aAdd(aStrut,{"PER_TIPCOM","C",011,0})//Tipo do comprovante
		aAdd(aStrut,{"PER_NUMCOM","C",012,0})//Numero do comprovante
		aAdd(aStrut,{"PER_CUIT"  ,"C",011,0})//CUIT
		aAdd(aStrut,{"PER_NOME"  ,"C",030,0})//Razao social
		aAdd(aStrut,{"PER_EMISS" ,"D",008,0})//Emissao
		aAdd(aStrut,{"PER_VALIMP","N",011,2})//Monto total
		aAdd(aStrut,{"PER_CONCEP","C",001,0})//Concepto
		aAdd(aStrut,{"PER_BASIMP","N",011,2})//Monto imponible
		aAdd(aStrut,{"PER_ALQIMP","N",005,2})//Aliquota
		
		cAlias  := "PER"
		aOrdem := {"PER_EMISS"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
	
		aStrut := {}
		aAdd(aStrut,{"RET_COMP"  ,"C",006,0})//Comprovante de retencao
		aAdd(aStrut,{"RET_CUIT"  ,"C",011,0})//CUIT
		aAdd(aStrut,{"RET_NOME"  ,"C",031,0})//Razao social
		aAdd(aStrut,{"RET_END"   ,"C",050,0})//Domicilio
		aAdd(aStrut,{"RET_EMISS" ,"D",008,0})//Fecha
		aAdd(aStrut,{"RET_RETENC","N",011,2})//Monto total
		aAdd(aStrut,{"RET_CONCEP","C",002,0})//Concepto
		aAdd(aStrut,{"RET_BASIMP","N",011,2})//Monto imponible
		aAdd(aStrut,{"RET_ALQIMP","N",011,2})//Aliquota
		aAdd(aStrut,{"RET_CODPRO","C",003,0})//Codigo do produto
		
		cAlias  := "RET"
		aOrdem := {"RET_CUIT","RET_COMP"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ IBXSL - SAN LUIS                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cProv == "SL"
	
		aStrut := {}
		aAdd(aStrut,{"SUJ_CUIT"  ,"C",011,0})//CUIT
		aAdd(aStrut,{"SUJ_NOME"  ,"C",050,0})//Razon social
		aAdd(aStrut,{"SUJ_TIPOIB","C",012,0})//Tipo IIBB
		aAdd(aStrut,{"SUJ_NINGB" ,"C",013,0})//Ingresos brutos
		aAdd(aStrut,{"SUJ_END"   ,"C",050,0})//Domicilio
		aAdd(aStrut,{"SUJ_LOCAL" ,"C",030,0})//Localidad
		aAdd(aStrut,{"SUJ_CODPST","C",004,0})//Codigo Postal
		aAdd(aStrut,{"SUJ_PROV"  ,"C",030,0})//Provincia
		
		cAlias  := "SUJ"
		aOrdem := {"SUJ_CUIT"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
	
		aStrut := {}
		aAdd(aStrut,{"RET_CUIT"  ,"C",011,0})//CUIT
		aAdd(aStrut,{"RET_NUMCOM","C",010,0})//Num Comprobante
		aAdd(aStrut,{"RET_EMISS" ,"D",008,0})//Fecha Retencion
		aAdd(aStrut,{"RET_CONCEP","C",001,0})//Concepto Retencion
		aAdd(aStrut,{"RET_MONTO" ,"N",013,2})//Monto bruto pagado
		aAdd(aStrut,{"RET_PERCNT","N",006,2})//Porcentaje suj. Retencion
		aAdd(aStrut,{"RET_ALIQ"  ,"N",006,2})//Aliquota
		aAdd(aStrut,{"RET_RETENC","N",011,2})//Monto Retenido
		aAdd(aStrut,{"RET_ANUL"  ,"C",001,0})//Anulado
		
		cAlias  := "RET"
		aOrdem := {"RET_CUIT"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
		
		aStrut := {}
		aAdd(aStrut,{"PER_CUIT"  ,"C",011,0})//CUIT
		aAdd(aStrut,{"PER_EMISS" ,"D",008,0})//Fecha Retencion
		aAdd(aStrut,{"PER_TIPCOM","C",003,0})//Tipo Comprobante
		aAdd(aStrut,{"PER_NUMCOM","C",012,0})//Numero Comprobante
		aAdd(aStrut,{"PER_TIPSUJ","C",003,0})//Tipo de sujeito
		aAdd(aStrut,{"PER_INSCRI","C",001,0})//Inscripto
		aAdd(aStrut,{"PER_MONTOT","N",013,2})//Monto total
		aAdd(aStrut,{"PER_VALIMP","N",013,2})//Monto total
		aAdd(aStrut,{"PER_MONSUJ","N",013,2})//Monto sujeito
		aAdd(aStrut,{"PER_ALIQ"  ,"N",006,2})//Aliquota
		aAdd(aStrut,{"PER_CODALI","C",003,0})//Codigo da aliquota
		aAdd(aStrut,{"PER_MONPER","N",012,2})//Monto percebido
		
		cAlias  := "PER"
		aOrdem := {"PER_CUIT"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ IBXCA - CATAMARCA                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cProv == "CA"
	
		aStrut := {}
		aAdd(aStrut,{"PER_TIPCOM","C",001,0})//Tipo do comprovante
		aAdd(aStrut,{"PER_NUMCOM","C",012,0})//Numero do comprovante
		aAdd(aStrut,{"PER_EMISS" ,"D",008,0})//Emissao
		aAdd(aStrut,{"PER_INSCRI","C",010,0})//Numero de inscricao A1_NIGB e A2_NIGB
		aAdd(aStrut,{"PER_NOME"  ,"C",030,0})//Razao social
		aAdd(aStrut,{"PER_CUIT"  ,"C",011,0})//CUIT
		aAdd(aStrut,{"PER_BASIMP","N",009,2})//Monto imponible
		aAdd(aStrut,{"PER_ALQIMP","N",005,2})//Aliquota
		aAdd(aStrut,{"PER_VALIMP","N",008,2})//Monto total
		aAdd(aStrut,{"PER_ESTADO","C",001,0})//Identificador de estado
		aAdd(aStrut,{"PER_DOMICI","C",030,0})//Domicilio del cliente
		aAdd(aStrut,{"PER_TEL"   ,"C",015,0})//Telefono do cliente
		aAdd(aStrut,{"PER_LOCALI","C",005,0})//Identif. de localidad
		aAdd(aStrut,{"PER_NOMLOC","C",030,0})//Nombre de la localidad
		aAdd(aStrut,{"PER_CODPOS","C",030,0})//Codigo postal
		aAdd(aStrut,{"PER_DEPART","C",003,0})//Identif. de departamen.
		aAdd(aStrut,{"PER_NOMDEP","C",030,0})//Nombre de departamento
		aAdd(aStrut,{"PER_PROVIN","C",002,0})//Identif. de provincia

		cAlias  := "PER"
		aOrdem := {"PER_EMISS"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
		
		aStrut := {}
		aAdd(aStrut,{"RET_NUMCOM","C",010,0})//Numero do comprovante
		aAdd(aStrut,{"RET_EMISS" ,"D",008,0})//Emissao
		aAdd(aStrut,{"RET_INSCRI","C",010,0})//Numero de inscricao A1_NIGB e A2_NIGB
		aAdd(aStrut,{"RET_NOME"  ,"C",030,0})//Razao social
		aAdd(aStrut,{"RET_CUIT"  ,"C",011,0})//CUIT
		aAdd(aStrut,{"RET_BASIMP","N",009,2})//Monto imponible
		aAdd(aStrut,{"RET_ALQIMP","N",005,2})//Aliquota
		aAdd(aStrut,{"RET_VALIMP","N",008,2})//Monto total
		aAdd(aStrut,{"RET_ESTADO","C",001,0})//Identificador de estado
		aAdd(aStrut,{"RET_DOMICI","C",030,0})//Domicilio del cliente
		aAdd(aStrut,{"RET_TEL"   ,"C",015,0})//Telefono do cliente
		aAdd(aStrut,{"RET_LOCALI","C",005,0})//Identif. de localidad
		aAdd(aStrut,{"RET_NOMLOC","C",030,0})//Nombre de la localidad
		aAdd(aStrut,{"RET_CODPOS","C",030,0})//Codigo postal
		aAdd(aStrut,{"RET_DEPART","C",003,0})//Identif. de departamen.
		aAdd(aStrut,{"RET_NOMDEP","C",030,0})//Nombre de departamento
		aAdd(aStrut,{"RET_PROVIN","C",002,0})//Identif. de provincia

		cAlias  := "RET"
		aOrdem := {"RET_CUIT","RET_NUMCOM"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ IBXSJ - SAN JUAN                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cProv == "SJ"

		aStrut := {}
		aAdd(aStrut,{"PER_RAZSOC","C",080,0})//1 Razao social
		aAdd(aStrut,{"PER_CUIT"  ,"C",011,0})//2 CUIT
		aAdd(aStrut,{"PER_DOMICI","C",120,0})//3 Domicilio Fiscal
		aAdd(aStrut,{"PER_INSCRI","C",016,0})//4 Numero de Inscripcion
		aAdd(aStrut,{"PER_EMISS" ,"C",010,0})//5 Fecha de Comprobante
		aAdd(aStrut,{"PER_TIPCOM","C",002,0})//6 Tipo de comprovante 
		aAdd(aStrut,{"PER_NUMCOM","C",012,0})//7 Numero de comprovante
		aAdd(aStrut,{"PER_BASIMP","N",015,2})//8 Base imponible
		aAdd(aStrut,{"PER_ALQIMP","N",015,2})//9 Alicuota
		aAdd(aStrut,{"PER_VALIMP","N",015,2})//10 Importe percebido
		aAdd(aStrut,{"PER_HOGAR" ,"N",015,2})//11 Importe percebido adicional hogar
		aAdd(aStrut,{"PER_TIPANU","C",002,0})//12 Tipo de comprovante anulado
		aAdd(aStrut,{"PER_NUMANU","C",012,0})//13 Numero de comprovante anulado

		cAlias  := "PER"
		aOrdem := {"PER_CUIT"}
		aAdd(aTabs,{cAlias,aStrut,aOrdem})
	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria os alias e os indices ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI:=1 To Len(aTabs)
		Private &((cTmp)+alltrim(Str(nI))) := Nil
		//Creacion de Objeto 01.12.2016
		&((cTmp)+alltrim(Str(nI))) := FWTemporaryTable():New(aTabs[nI,1]) 
		&((cTmp)+alltrim(Str(nI))):SetFields(aTabs[nI,2]) 

		&((cTmp)+alltrim(Str(nI))):AddIndex("IN"+alltrim(Str(nI)), aTabs[nI,3]) 

		&((cTmp)+alltrim(Str(nI))):Create()
	Next nI
Return aTabs

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ AMArgRel ³ Autor ³ Ivan Haponczuk      ³ Data ³ 25.11.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Gera relatorio de conferencia com as notas e/ou            ³±±
±±³            ³ certificados considerados na geracao do arquivo.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cProv    - Provincia do arquivo gerado.                    ³±±
±±³            ³ cSF3     - Alias da query dos livros fiscais.              ³±±
±±³            ³ cSFE     - Alias da query de certificados de retencao.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Argentina - MATA950 - Arquivos Magneticos           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AMArgRel(cProv,cSF3,cSFE)
	Local cTitulo := ""
	Local oReport := Nil

	oReport := TReport():New("AMARG",cTitulo,,{|oReport| FSetImp(oReport,cProv,cSF3,cSFE)},cTitulo)
	oReport:SetLandscape()
	oReport:PrintDialog()
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ AMArgRel ³ Autor ³ Ivan Haponczuk      ³ Data ³ 25.11.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Seleciona campos de impressao.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ oReport  - Objeto de impressao do TReport.                 ³±±
±±³            ³ cProv    - Provincia do arquivo gerado.                    ³±±
±±³            ³ cSF3     - Alias da query dos livros fiscais.              ³±±
±±³            ³ cSFE     - Alias da query de certificados de retencao.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Argentina - MATA950 - Arquivos Magneticos           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FSetImp(oReport,cProv,cSF3,cSFE)
	Local oDados := Nil
	Local cSDoc  := ""
	If Select("TRBPER")>0
		cSDoc  := SerieNFID(TRBPER, 2, "F3_SERIE")
	Else
		cSDoc  := SerieNFID("SF3", 2, "F3_SERIE")
	EndIf

	If !Empty(cSF3)

		oDados := TRSection():New(oReport,STR0049,{cSF3})//"Percepções"
		TRCell():New(oDados,"F3_EMISSAO",cSF3,STR0050,PesqPict("SF3","F3_EMISSAO"),TamSx3("F3_EMISSAO")[1],.F.)//"Emissão"
		TRCell():New(oDados,"F3_NFISCAL",cSF3,STR0051,PesqPict("SF3","F3_NFISCAL"),TamSx3("F3_NFISCAL")[1],.F.)//"Nota fiscal"
		//Bruno Cremaschi - Projeto chave única.
		TRCell():New(oDados,"F3_SERIE"  ,cSF3,STR0052,PesqPict("SF3","F3_SERIE")  ,TamSx3("F3_SERIE")[1] ,.F.)//"Série"
		TRCell():New(oDados,"F3_ESPECIE",cSF3,STR0053,PesqPict("SF3","F3_ESPECIE"),TamSx3("F3_ESPECIE")[1],.F.)//"Especie"
		TRCell():New(oDados,"A1_NOME"   ,cSF3,STR0054,PesqPict("SA1","A1_NOME")   ,TamSx3("A1_NOME")[1]   ,.F.,{|| If(F3_TIPOMOV=='V',A1_NOME,A2_NOME)})//"Razão social"
		TRCell():New(oDados,"A1_NIGB"   ,cSF3,STR0055,PesqPict("SA1","A1_NIGB")   ,TamSx3("A1_NIGB")[1]   ,.F.,{|| If(F3_TIPOMOV=='V',A1_NIGB,A2_NIGB)})//"Nº I.Brutos"
		TRCell():New(oDados,"BASIMP"    ,cSF3,STR0056,PesqPict("SF3","F3_BASIMP1"),TamSx3("F3_BASIMP1")[1],.F.)//"Base"
		TRCell():New(oDados,"ALQIMP"    ,cSF3,STR0057,PesqPict("SF3","F3_ALQIMP1"),TamSx3("F3_ALQIMP1")[1],.F.)//"Alíquota"
		TRCell():New(oDados,"VALIMP"    ,cSF3,STR0058,PesqPict("SF3","F3_VALIMP1"),TamSx3("F3_VALIMP1")[1],.F.)//"Valor"
		oDados:Print()
	EndIf
	
	If !Empty(cSFE)
	
		oDados := TRSection():New(oReport,"Retenções",{cSFE})//"Retenções"
		TRCell():New(oDados,"FE_EMISSAO",cSFE,STR0059,PesqPict("SFE","FE_EMISSAO"),TamSx3("FE_EMISSAO")[1],.F.)//"Emissão"
		TRCell():New(oDados,"FE_NROCERT",cSFE,STR0060,PesqPict("SFE","FE_NROCERT"),TamSx3("FE_NROCERT")[1],.F.)//"Certificado"
		TRCell():New(oDados,"FE_NRETORI",cSFE,STR0061,""                          ,12                      ,.F.,{|| If(!Empty(FE_NRETORI),"Cancelamento","Inclusão") })//"Tipo"
		TRCell():New(oDados,"A2_NOME"   ,cSFE,STR0062,PesqPict("SA2","A2_NOME")   ,TamSx3("A2_NOME")[1]   ,.F.,{|| If(!Empty(FE_CLIENTE),A1_NOME,A2_NOME)})//"Razao Social"
		TRCell():New(oDados,"A2_NIGB"   ,cSFE,STR0063,PesqPict("SA2","A2_NIGB")   ,TamSx3("A2_NIGB")[1]   ,.F.,{|| If(!Empty(FE_CLIENTE),A1_NIGB,A2_NIGB)})//"Nº I.Brutos"
		TRCell():New(oDados,"FE_VALBASE",cSFE,STR0064,PesqPict("SFE","FE_VALBASE"),TamSx3("FE_VALBASE")[1],.F.)//"Base"
		TRCell():New(oDados,"FE_ALIQ"   ,cSFE,STR0065,PesqPict("SFE","FE_ALIQ")   ,TamSx3("FE_ALIQ")[1]   ,.F.)//"Alíquota"
		TRCell():New(oDados,"FE_RETENC" ,cSFE,STR0066,PesqPict("SFE","FE_RETENC") ,TamSx3("FE_RETENC")[1] ,.F.)//"Retenção"
		oDados:Print()
		
	EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GeraRetSus³ Autor ³Marco Aurelio          ³ Data ³ 31/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Gera arquivo TXT referente as Retencoes/SUSS                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GeraRetSus()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Chamada na execucao da Instrucao Normativa(XXX.ini)        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GeraRetSus()
Local aArea   := GetArea()
Local cQuery  := ""
                                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fecha o arquivo temporario caso existir ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TMPRET") > 0
	TMPRET->(DbClosearea())
EndIf

If ( TcSrvType() <> "AS/400" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca Retencoes de Imposto(SUSS) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  SFE->(ColumnPos('FE_SIRECER'))>0  
		cQuery := "SELECT FE_EMISSAO, FE_NROCERT, FE_RETENC, A1_CGC, FE_SIRECER"
		cQuery += "	FROM "
		cQuery += RetSqlName("SFE")+" SFE, "	// Retencao de impostos
		cQuery += RetSqlName("SA1")+" SA1  "	// Clientes
		cQuery += "	WHERE "
		cQuery += "   FE_FILIAL = '"+xFilial("SFE")+"' "
		cQuery += "   AND A1_FILIAL = '"+xFilial("SA1")+"'"
		cQuery += "   AND FE_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
		cQuery += "   AND ( FE_DTESTOR = ' ' OR FE_DTESTOR > '"+Dtos(MV_PAR02)+"' )"
		cQuery += "   AND FE_RETENC > 0"
		cQuery += "   AND FE_TIPO = 'S'"
		cQuery += "   AND A1_COD  = FE_CLIENTE"
		cQuery += "   AND A1_LOJA = FE_LOJCLI"
		cQuery += "   AND SA1.D_E_L_E_T_='' AND SFE.D_E_L_E_T_='' "
	Else
		MsgStop(STR0090,STR0091)
		cQuery := "SELECT FE_EMISSAO, FE_NROCERT, FE_RETENC, A1_CGC"
		cQuery += "	FROM "
		cQuery += RetSqlName("SFE")+" SFE, "	// Retencao de impostos
		cQuery += RetSqlName("SA1")+" SA1  "	// Clientes
		cQuery += "	WHERE "
		cQuery += "   FE_FILIAL = '"+xFilial("SFE")+"' "
		cQuery += "   AND A1_FILIAL = '"+xFilial("SA1")+"'"
		cQuery += "   AND FE_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
		cQuery += "   AND ( FE_DTESTOR = ' ' OR FE_DTESTOR > '"+Dtos(MV_PAR02)+"' )"
		cQuery += "   AND FE_RETENC > 0"
		cQuery += "   AND FE_TIPO = 'Z'"  // Para gerar temporario sem dados e nao dar erro no ini
		cQuery += "   AND A1_COD  = FE_CLIENTE"
		cQuery += "   AND A1_LOJA = FE_LOJCLI"
		cQuery += "   AND SA1.D_E_L_E_T_='' AND SFE.D_E_L_E_T_='' "
	EndIf

	cQuery := ChangeQuery( cQuery )
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPRET",.T.,.T.)

EndIf

RestArea(aArea)
 
Return

/*                                                                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ TpDocRET   ³Autor ³ Laura Medina        ³ Fecha ³31/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Función para obtener el tipo de documento en base al tipo y³±± 
±±³           ³ la serie.                                                  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ TpDocRET()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ BOPS ³  Motivo de alteracion                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TpDocRET(cSerie,cTipo)
	Local nTipo    := 1
	Local cTipoDoc :="032"

	If Alltrim(UPPER(cTipo))$"NF" 
		nTipo :=1   
	Elseif Alltrim(UPPER(cTipo))$"NDP|NCI"
		nTipo :=2   
	ElseIf Alltrim(UPPER(cTipo))$"NCP|NDI"
		nTipo :=3
	EndIf
	                              
	Do Case    
		Case nTipo == 1 .And. Alltrim(cSerie)$ "A"
			cTipoDoc="001"  
		Case nTipo == 1 .And. Alltrim(cSerie)$ "B"
			cTipoDoc="006"   
		Case nTipo == 1 .And. Alltrim(cSerie)$ "C"
			cTipoDoc="011" 
		Case nTipo == 1 .And. Alltrim(cSerie)$ "M"
			cTipoDoc="051" 			
		Case nTipo == 2 .And. Alltrim(cSerie)$ "A"
			cTipoDoc="002"  
		Case nTipo == 2 .And. Alltrim(cSerie)$ "B"
			cTipoDoc="007"   
		Case nTipo == 2 .And. Alltrim(cSerie)$ "C"
			cTipoDoc="037"
		Case nTipo == 2 .And. Alltrim(cSerie)$ "M"
			cTipoDoc="052"			
		Case nTipo == 3 .And. Alltrim(cSerie)$ "A"
			cTipoDoc="003"  
		Case nTipo == 3 .And. Alltrim(cSerie)$ "B"
			cTipoDoc="008"   
		Case nTipo == 3 .And. Alltrim(cSerie)$ "C"
			cTipoDoc="038"
		Case nTipo == 3 .And. Alltrim(cSerie)$ "M"
			cTipoDoc="053"					
	EndCase	
Return(cTipoDoc)
                 
/*                                                                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ GravaRG2849³Autor ³ Laura Medina        ³ Fecha ³05/11/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Función para grabar los registros en la tabla temporal     ³±± 
±±³           ³ RG2849 para la generación del archivo txt.                 ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ GravaRG2849()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ BOPS ³  Motivo de alteracion                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GravaRG2849(cRTpDoc,cRFiscal,dREmis,cRAFIP,cRGCC,cRNome,nRBasIm,nRValI,nRValCon,nValRG,nRQuant,cUMRG,nRVUnit,nRTotal,nRAlqImp,nRValImp,cProdCod)
	Local lRet  := .F.

	aArea:=GetArea()
											
	dbSelectArea("RG2849")
	RG2849->(dbSetOrder(1))//"RET_TPCOMP+RET_PTOVTA+RET_NROCOM+RET_PRODUC+RET_CUIT+RET_COD+RET_PRCUNI"
	RG2849->(dbGoTop())						
	If !RG2849->(dbSeek(cRTpDoc+Substr(Alltrim(cRFiscal),1,4)+PADR(SUBSTR(Alltrim(cRFiscal),LEN(ALLTRIM(cRFiscal))-7,LEN(ALLTRIM(cRFiscal))),8)+STRZERO(nValRG,2)+SUBSTR(cRGCC,1,11)+STRZERO(nValRG,15)+strzero(nRVUnit*100,12)))
		If  RecLock("RG2849",.T.)
			RG2849->RET_TPCOMP := cRTpDoc
			RG2849->RET_PTOVTA := Substr(Alltrim(cRFiscal),1,4)
			RG2849->RET_NROCOM := PADR(SUBSTR(Alltrim(cRFiscal),LEN(ALLTRIM(cRFiscal))-7,LEN(ALLTRIM(cRFiscal))),8)
			RG2849->RET_FCHCOM := Substr(dREmis,7,2)+Substr(dREmis,5,2)+Substr(dREmis,1,4) //Fecha de Comprobante-Formato Valido DDMMAAAA
			RG2849->RET_TPDOCV := PADR(Iif(!Empty(cRAFIP),cRAFIP,"80"),2)
			RG2849->RET_CUIT   := SUBSTR(cRGCC,1,11)
			RG2849->RET_APNOMV := PADR(cRNome,25)
			RG2849->RET_TOTNET := strzero(nRBasIm*100,12)
			RG2849->RET_TOTIVA := strzero(nRValI*100,12)
			RG2849->RET_TOTAL  := strzero(nRValCon*100,12)
			RG2849->RET_PRODUC := STRZERO(nValRG,2)
			RG2849->RET_CANTID := STRZERO(nRQuant*100,8)
			RG2849->RET_UNIMED := Iif(Empty(cUMRG),"00",cUMRG)
			RG2849->RET_PRCUNI := strzero(nRVUnit*100,12)
			RG2849->RET_PRCTOT := strzero(nRTotal*100,12)
			RG2849->RET_IVAALQ := STRZERO(nRAlqImp,1)
			RG2849->RET_IMPLIQ := strzero(nRValImp*100,12)
			RG2849->RET_COD    := STRZERO(nValRG,15)
			RG2849->(MsUnlock())
			lRet  := .T.
		EndIf
	Else
		If  RecLock("RG2849",.F.)
			RG2849->RET_PRCTOT := strzero(val(RET_PRCTOT) + (nRTotal*100),12)    
			RG2849->RET_CANTID := strzero(val(RET_CANTID) + (nRQuant*100),8)
			RG2849->RET_IMPLIQ := strzero(val(RET_IMPLIQ) + (nRValImp*100),12)
			RG2849->(MsUnlock())
		EndIf		
	EndIf
	RestArea(aArea)
Return lRet

/*                                                                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ EsImpAdc   ³Autor ³ Laura Medina        ³ Fecha ³30/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Función para validar si es un Ret. Normal o es la Ret.     ³±± 
±±³           ³ Adicional (Lote Hogar).                                    ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ EsImpAdc()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ BOPS ³  Motivo de alteracion                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function	EsImpAdc(RET_CFO,RET_EST)
	Local nOpc    := 1   
	Local cTabTemp:= criatrab(nil,.F.)     
	Local nNumRegs:= 0 
	Local lRet    := .F. 
	Local cQuery  := ""
	Local cTipo   := ""    
	Local cImposto:= "IBR"


	DbSelectArea("SFF")
	SFF->(DbSetOrder(5))//"FF_FILIAL+FF_IMPOSTO+FF_CFO_C+FF_ZONFIS"
	SFF->(DbGoTop())
	If  DbSeek(xFilial("SFF")+cImposto+RET_CFO+RET_EST)
		If !Empty(SFF->FF_CFORA) 
			nOpc:= 1 
		Else 
			nOpc:= 3 
			cTipo := SFF->FF_TIPO 
		EndIf
	EndIf

	/*
	nOpc
	1 - Ret. Normal
	2 - Ret. IB Adicional (Lote Hogar)
	3 - Validar si es Ret. IB Adicional
	*/  
 
	If  nOpc== 3   //Puede ser registro adicional
		cQuery := "SELECT * "
		cQuery += "FROM " + RetSqlName("SFF")+ " SFF "
		cQuery += "WHERE FF_TIPO ='"+ cTipo +"' AND "
		cQuery += "FF_CFORA   ='" + RET_CFO +"' AND "
		cQuery += "FF_IMPOSTO ='" + cImposto+"' AND "
		cquery += "FF_ZONFIS  ='" + RET_EST +"' AND "
		cQuery += "FF_FILIAL='" +XFILIAL("SFF") + "' AND "
		cQuery += "D_E_L_E_T_<>'*'"
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabTemp,.T.,.T.)
		
		Count to nNumRegs
		
		If  nNumRegs > 0	//Significa que es Ret. Adicional (Lote Hogar)
			nOpc:= 2 
		EndIf    
	EndIf

Return nOpc    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ TipDocTU ³ Autor ³ Paulo Augusto       ³ Data ³ 06.06.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Devolve tipo documento paar Tucuman                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cSerie -  Serie do documento                               ³±±
±±³            ³ cTipo  - Tipo do documento( Especie)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Argentina - MATA950 - Arquivos Magneticos           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TipDocTU(cSerie,ctipo)
	Local nNumAux :=0
	Local nTotImp :=0
	Local nTotPar :=0
	Local nPos	  :=1
	Local nTotal  := 0
	Local nNumVal := 0
	Local lCalcula:=.T.
	local lRet:=.T.
	Local nTipo := 1
	Local cTipoDc:="1"
	Default cTipo:="NF"
	// Verifico o numero de digitos e impar
	// Caso seja, adiciono um caracter
	/*
	ntipo:=
	1= Fatura
	2= Nota Debito
	3= Nota Credito
	*/
	
	If "NF" $ cTipo 
		nTipo :=1
	ElseIf "ND" $ cTipo 
		nTipo :=2
	ElseIf "NC" $ cTipo 	
		nTipo :=3  
	ElseIf "RC" $ cTipo 		
		nTipo :=4
	EndIf 
		                              
	Do Case
		Case nTipo=1 .And. Alltrim(cSerie)="A"
			cTipoDc="01"
		Case nTipo=2 .And. Alltrim(cSerie)="A"
			cTipoDc="02"	
		Case nTipo=3 .And. Alltrim(cSerie)="A"
			cTipoDc="03"
		Case nTipo=4 .And. Alltrim(cSerie)="A"
			cTipoDc="4"		
		Case nTipo=1 .And. Alltrim(cSerie)="B"
			cTipoDc="06"
		Case nTipo=2 .And. Alltrim(cSerie)="B"
			cTipoDc="07"	
		Case nTipo=3 .And. Alltrim(cSerie)="B"
			cTipoDc="07" 
		Case nTipo=4 .And. Alltrim(cSerie)="B"
			cTipoDc="9"		
		Case nTipo=1 .And. Alltrim(cSerie)="C"
			cTipoDc="11"
		Case nTipo=2 .And. Alltrim(cSerie)="C"
			cTipoDc="12"	
		Case nTipo=3 .And. Alltrim(cSerie)="C"
			cTipoDc="12"
		Case nTipo=4 .And. Alltrim(cSerie)="C"
			cTipoDc="15"
	EndCase
Return(cTipoDc)		

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ GravaRG3865³Autor ³ Emanuel V.V.        ³ Fecha ³13/04/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Funcion para grabar reg de encabezado en la tabla temporal ³±± 
±±³           ³ RG3865 para la generación del archivo txt.                 ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ BOPS ³  Motivo de alteracion                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GravaRG3865(cCuit,cPeriod,cSec,cMov)
	Local lRet		:= .F.
	Local aArea	:=GetArea()
	
	DbSelectArea("RGENCA")
	RGENCA->(dbSetOrder(1))
	RGENCA->(dbGoTop())
	
	If	RGENCA->(Eof()) .and. RecLock("RGENCA",.T.)
		RGENCA->ENC_CUIT	:= cCuit
		RGENCA->ENC_PERIOD	:= cPeriod
		RGENCA->ENC_SECUEN	:= cSec
		RGENCA->ENC_SINMOV	:= cMov
		RGENCA->ENC_PRORRA	:= "N"
		RGENCA->ENC_CREFIS	:= " "
		RGENCA->ENC_IMPCGF	:= STRZERO(0,15)
		RGENCA->ENC_IMPCAD	:= STRZERO(0,15)
		RGENCA->ENC_IMPCDP	:= STRZERO(0,15)
		RGENCA->ENC_IMPCNG	:= STRZERO(0,15)
		RGENCA->ENC_IMPSSO	:= STRZERO(0,15)
		RGENCA->ENC_IMPCSO	:= STRZERO(0,15)
		RGENCA->(MsUnlock())
		lRet  := .T.
	EndIf 	
	RestArea(aArea)
Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ Act3865    ³Autor ³ Emanuel V.V.        ³ Fecha ³14/04/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Actualiza tablas temporales para generacion de 3865        ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ Act3865(cTES,cTbTmp,cNota,cSerie,cCliFor,cLoja)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ BOPS ³  Motivo de alteracion                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Act3865(lExenta,cTES,cTbTmp,cNota,cSerie,cCliFor,cLoja,cTipM,aNrLvrIV,aNrLvIVA,aNrLvrGN,aNrLvrIB,aNrLvrMn,aNrLvrIn,aNrLvrIm,aNrLvrIip,aCodTab)
	Local aAreaSD		:= {}
	Local aTes			:= {}
	Local aCanTas		:= {}
	Local aCanje		:= {}
	Local aImporta	:= {}
	Local cAliasSF	:= Iif(cTES > "500","SF2","SF1")     
	Local cAliasSD	:= Iif(cTES > "500","SD2","SD1")     
	Local nIndSFF		:= Iif(cTES <= "500",5,6) // (5- FF_FILIAL+FF_IMPOSTO+FF_CFO_C) (6- FF_FILIAL+FF_IMPOSTO+FF_CFO_V)
	LocaL cAliasCF	:= Iif(cTipM == "V","SA1","SA2")  
	Local aArea		:= GetArea()
	Local nNoGra		:= 0
	Local lNoGra		:= .F.
	Local nExentas	:= 0
	Local nExenExp	:= 0
	Local nNoCat		:= 0
	Local nIppina		:= 0
	Local nIperib		:= 0
	Local nIpeimn		:= 0
	Local nImpint		:= 0
	Local nOpCanj		:= 0
	Local nbusca		:= 0
	Local nPos			:= 0
	Local nlI			:= 0
	Local lNExSFC		:= .F.
	Local lEncIva 	:= .F.
	Local cTipoDoc	:= ""
	Local nSigno		:= 1
	Local nIppiva		:= 0 
	Local nTipCam		:= 1
	Local nPerNac		:= 0
	Local cPaso		:= ""
	Local cAliq		:= 0
	Local nValimp		:= 0
	Local nMoneda		:= 0
	Local nCanAlq		:= 0 
	Local lTesSnIva	:= .T.
	Local lGravado	:= .F. 
	Local cIvaInc		:= SuperGetMV("MV_IMPIVAI",.T.,"IVC")
	
	//Campos tablas SF?
	Local nSFDoc    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_DOC"))
	Local nSFSer    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_SERIE"))
	Local nSFCliFor := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+Iif(cAliasSF == "SF2","_CLIENTE","_FORNECE")))
	Local nSFLoja   := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_LOJA"))
	Local nSFVBrut  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_VALBRUT"))
	Local nSFMoeda  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_MOEDA"))
	Local nSFTxMoeda:= (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_TXMOEDA"))
	Local nSFEsp    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_ESPECIE"))
	Local nHawb     := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_NUMDES"))
	Local nDespImp  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_HAWB"))
	Local nPosFret  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_FRETE"))
	Local nPosDesp  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_DESPESA"))
	Local nPosSeg   := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_SEGURO"))
	
	// Campos tablas SD?
	Local nSDDoc    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_DOC"))
	Local nSDSer    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_SERIE"))
	Local nSDCliFor := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+ Iif(cAliasSD == "SD2","_CLIENTE","_FORNECE")))
	Local nSDLoja   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_LOJA"))
	Local nSDTotal  := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_TOTAL"))
	Local nSDDesc   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+ Iif(cAliasSD == "SD2","_DESCON","_VALDESC")))
	Local nSDTes    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_TES"))
	Local nSDCF     := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_CF"))
	Local nSDValImp := 0
	Local nSDAliImp := 0
	Local nMtIVA0:= 0
	Local nImpGra := 0
	Local nLoopTES  := 0
	Local nPosTES  := 0
	Local nIVAPos	:= 0	
	Local nVlCamb := 1
	Local cMonEmis := Iif(Len(aCodTab[1]) > 4 ,SubStr(aCodTab[1][5], 1, 1), "1")
	Local nDetImptot := 0
	Local nDetTpcamb := 0
	Local nDetImcngr := 0
	Local nDetImpoex := 0
	Local nDetPernct := 0
	Local nDetIppina := 0
	Local nDetIperib := 0
	Local nDetIpeimn := 0
	Local nDetImpint := 0
	Local nDgrImpngr := 0
	Local nDgrImpliq := 0
	Local nCalImpngr := 0
	Local nCalImpliq := 0
	Local nDetCrfcom := 0
	Default aCodTab := {}

	dbSelectArea("SFF")
	dbSetOrder(nIndSFF)
	
	dbSelectArea(cAliasSF)
	If (cAliasSF)->(!Eof())
		cTipoDoc := Alltrim((cAliasSF)->(FieldGet(nSFEsp)))
	
		nTipCam := Iif((cAliasSF)->(FieldGet(nSFTxMoeda))>1,(cAliasSF)->(FieldGet(nSFTxMoeda)),1)
		
		nMoneda := FieldGet(nSFMoeda)
		
		If (Type((cAliasSF)->(SubStr(cAliasSF,2,2)+"_MOEDA")) = "N" .and. nMoneda == 1) .or.;
		(Type((cAliasSF)->(SubStr(cAliasSF,2,2)+"_MOEDA")) = "C" .and. Val(nMoneda) == 1)
			nTipCam := 1
		EndIf 
		
	// Tratamento de otros gastos	 
		nNoGra += (cAliasSF)->(FieldGet(nPosFret))
		nNoGra += (cAliasSF)->(FieldGet(nPosDesp))
		nNoGra += (cAliasSF)->(FieldGet(nPosSeg))
		
		nVlCamb := 1  // La cotizacion se deja fija como 1 pues los valores ya van convertidos a la moneda 1
		
		
		If cTbTmp == "DETVTA"
			If cMonEmis == "1"
				nDetImptot := ConPeso(FieldGet(nSFVBrut),nMoneda,nTipCam)				
				nDetTpcamb := nVlCamb
			Else
				nDetImptot := FieldGet(nSFVBrut)
				nDetTpcamb := nTipCam
			EndIf
			DETVTA->DET_IMPTOT := StrTran(StrZero(nDetImptot,16,2), ".", "" )
			DETVTA->DET_CODMON := SubStr(Posicione("SX5", 1, xFilial("SX5")+"OB" + (AllTrim(Str(FieldGet(nSFMoeda))) + Space(TAMSX3("X5_CHAVE")[01]-Len(AllTrim(Str(FieldGet(nSFMoeda)))))) , "X5_DESCSPA"),1,3) 
			DETVTA->DET_TPCAMB := StrTran(StrZero(nDetTpcamb,11,6), ".", "" )
		ElseIf cTbTmp == "DETCOM"
			If cMonEmis == "1"
				nDetImptot := ConPeso(FieldGet(nSFVBrut),nMoneda,nTipCam)		
				nDetTpcamb := nVlCamb
			Else
				nDetImptot := FieldGet(nSFVBrut)		
				nDetTpcamb := nTipCam
			EndIf
			DETCOM->DET_IMPTOT := StrTran(StrZero(nDetImptot,16,2), ".", "" )		
			DETCOM->DET_CODMON := SubStr(Posicione("SX5", 1, xFilial("SX5")+"OB" + (AllTrim(Str(FieldGet(nSFMoeda))) + Space(TAMSX3("X5_CHAVE")[01]-Len(AllTrim(Str(FieldGet(nSFMoeda)))))) , "X5_DESCSPA"),1,3) 
			DETCOM->DET_TPCAMB := StrTran(StrZero(nDetTpcamb,11,6), ".", "" )
			If cAliasSF == "SF1" .and. SF1->(FieldPos("F1_NUMDES")) > 0 .and. TRBPER->A2_TIPROV == "A" .And. !Empty((cAliasSF)->(FieldGet(nHawb)))
				DETCOM->DET_DESPIM	:=  (cAliasSF)->(FieldGet(nHawb))
			ElseIf cAliasSF == "SF1" .and. SF1->(FieldPos("F1_HAWB")) > 0 .and. TRBPER->A2_TIPROV == "A" .And. !Empty((cAliasSF)->(FieldGet(nDespImp)))
				DETCOM->DET_DESPIM	:=  (cAliasSF)->(FieldGet(nDespImp))
			Else
				DETCOM->DET_DESPIM	:= SPACE(16)
			EndIf 
		EndIf 
	
		aAreaSD := (cAliasSD)->(GetArea())
		(cAliasSD)->(dbSetOrder(Iif(cAliasSD == "SD2",3,1)))
		nMtIVA0:= 0
		If (cAliasSD)->(dbSeek(xFilial(cAliasSD)+(cAliasSF)->(FieldGet(nSFDoc))+(cAliasSF)->(FieldGet(nSFSer))+(cAliasSF)->(FieldGet(nSFCliFor))+(cAliasSF)->(FieldGet(nSFLoja))))
			While !(cAliasSD)->(Eof()) .And.	xFilial(cAliasSD)+(cAliasSD)->(FieldGet(nSDDoc))+(cAliasSD)->(FieldGet(nSDSer))+(cAliasSD)->(FieldGet(nSDCliFor))+(cAliasSD)->(FieldGet(nSDLoja)) == ;
			xFilial(cAliasSD)+FieldGet(nSFDoc)+FieldGet(nSFSer)+FieldGet(nSFCliFor)+FieldGet(nSFLoja)
	
				aTes := TesImpInf((cAliasSD)->(FieldGet(nSDTes)))
				lNExSFC := Iif(Len(aTes)== 0,.T.,.F.)
				lNoGra := .F.
				lExenta := .F.	
				If !lNExSFC
					
					If Ascan(aTes,{|x|x[1] == "IVA"}) > 0 
						nIVAPos := Ascan(aTes,{|x|x[1] == "IVA"})
						If Len(aTes[nIVAPos]) >= 13 .and. aTes[nIVAPos][13] == "N"
							nNoGra -= (cAliasSD)->(FieldGet(nSDDesc))
						EndIf
					ElseIf Ascan(aTes,{|x|x[1] == "IV0"}) > 0
						nIVAPos := Ascan(aTes,{|x|x[1] == "IV0"})
						If Len(aTes[nIVAPos]) >= 13 .and. aTes[nIVAPos][13] == "N"
							nNoGra -= (cAliasSD)->(FieldGet(nSDDesc))
						EndIf
						lExenta 	:= .T.
						
						If Substr(Alltrim(FieldGet(nSFSer)),1,1) == "A" 
							If cAliasSD == "SD1"  
								nExentas	+=  (cAliasSD)->(FieldGet(nSDTotal)) - (cAliasSD)->(FieldGet(nSDDesc))
							Else
								nExentas	+=  (cAliasSD)->(FieldGet(nSDTotal))									
							EndIf 	
						EndIf
						
					ElseIf Ascan(aTes,{|x|x[1] == "IV1"}) > 0
						nIVAPos := Ascan(aTes,{|x|x[1] == "IV1"})
						If Len(aTes[nIVAPos]) >= 13 .and. aTes[nIVAPos][13] == "N"
							nNoGra -= (cAliasSD)->(FieldGet(nSDDesc))
						EndIf		
					ElseIf Ascan(aTes,{|x|x[1] == "IV2"}) > 0
						nIVAPos := Ascan(aTes,{|x|x[1] == "IV2"})
						If Len(aTes[nIVAPos]) >= 13 .and. aTes[nIVAPos][13] == "N"
							nNoGra -= (cAliasSD)->(FieldGet(nSDDesc))
						EndIf
					ElseIf Ascan(aTes,{|x|x[1] == "IV3"}) > 0
						nIVAPos := Ascan(aTes,{|x|x[1] == "IV3"})
						If Len(aTes[nIVAPos]) >= 13 .and. aTes[nIVAPos][13] == "N"
							nNoGra -= (cAliasSD)->(FieldGet(nSDDesc))
						EndIf
					ElseIf Ascan(aTes,{|x|x[1] == "IV4"}) > 0
						nIVAPos := Ascan(aTes,{|x|x[1] == "IV4"})
						If Len(aTes[nIVAPos]) >= 13 .and. aTes[nIVAPos][13] == "N"
							nNoGra -= (cAliasSD)->(FieldGet(nSDDesc))
						EndIf
					ElseIf Ascan(aTes,{|x|x[1] == "IV5"}) > 0
						nIVAPos := Ascan(aTes,{|x|x[1] == "IV5"})
						If Len(aTes[nIVAPos]) >= 13 .and. aTes[nIVAPos][13] == "N"
							nNoGra -= (cAliasSD)->(FieldGet(nSDDesc))
						EndIf
					ElseIf Ascan(aTes,{|x|x[1] == "IV6"}) > 0
						nIVAPos := Ascan(aTes,{|x|x[1] == "IV6"})
						If Len(aTes[nIVAPos]) >= 13 .and. aTes[nIVAPos][13] == "N"
							nNoGra -= (cAliasSD)->(FieldGet(nSDDesc))
						EndIf						
					ElseIf Ascan(aTes,{|x|x[1] == "IV7"}) > 0
						nIVAPos := Ascan(aTes,{|x|x[1] == "IV7"})
						If Len(aTes[nIVAPos]) >= 13 .and. aTes[nIVAPos][13] == "N"
							nNoGra -= (cAliasSD)->(FieldGet(nSDDesc))
						EndIf
					ElseIf Ascan(aTes,{|x|x[1] == "IV8"}) > 0
						nIVAPos := Ascan(aTes,{|x|x[1] == "IV8"})
						If Len(aTes[nIVAPos]) >= 13 .and. aTes[nIVAPos][13] == "N"
							nNoGra -= (cAliasSD)->(FieldGet(nSDDesc))
						EndIf
					ElseIf Ascan(aTes,{|x|x[1] == "IV9"}) > 0
						nIVAPos := Ascan(aTes,{|x|x[1] == "IV9"})
						If Len(aTes[nIVAPos]) >= 13 .and. aTes[nIVAPos][13] == "N"
							nNoGra -= (cAliasSD)->(FieldGet(nSDDesc))
						EndIf			
					ElseIf Ascan(aTes,{|x|x[1] == "IVC"}) > 0
						nIVAPos := Ascan(aTes,{|x|x[1] == "IVC"})
						If Len(aTes[nIVAPos]) >= 13 .and. aTes[nIVAPos][13] == "N"
							nNoGra -= (cAliasSD)->(FieldGet(nSDDesc))
						EndIf
					Else // Cuando la TES no tiene IVA , IV0 o IV1 pero tiene otro impuestos
							If cAliasSD == "SD1"
								nNoGra  += (cAliasSD)->(FieldGet(nSDTotal)) - (cAliasSD)->(FieldGet(nSDDesc))
							Else 
								nNoGra  += (cAliasSD)->(FieldGet(nSDTotal)) 
							EndIf
							nbusca := aScan(aCanje,{|x| x[1] == LocTabAlq( 0 )})
							If nbusca == 0 .and. (cTbTmp == "DETVTA" .or. (cTbTmp == "DETCOM" .and. TRBPER->A2_TIPROV <> "A"))
								aAdd(aCanje,{LocTabAlq( 0 ),0, 0 })
							EndIf	
					EndIf
				Else
					If cAliasSD == "SD1"
						nNoGra  += (cAliasSD)->(FieldGet(nSDTotal)) - (cAliasSD)->(FieldGet(nSDDesc))
					Else 
						nNoGra  += (cAliasSD)->(FieldGet(nSDTotal)) 
					EndIf
					nbusca := aScan(aCanje,{|x| x[1] == LocTabAlq( 0 )})
					If nbusca == 0 .and. (cTbTmp == "DETVTA" .or. (cTbTmp == "DETCOM" .and. TRBPER->A2_TIPROV <> "A"))
						aAdd(aCanje,{LocTabAlq( 0 ),0, 0 })
					EndIf
				EndIf
	
				lExenta := .F.
				If Substr(Alltrim(FieldGet(nSFSer)),1,1) == "E" 
					lExenta 	:= .T.
					If cAliasSD == "SD1"  
						nExentas	+=  (cAliasSD)->(FieldGet(nSDTotal)) - (cAliasSD)->(FieldGet(nSDDesc))
					Else
						nExentas	+=  (cAliasSD)->(FieldGet(nSDTotal))									
					EndIf 		
					nbusca := aScan(aCanje,{|x| x[1] == LocTabAlq( 0 )})
					If nbusca == 0
						aAdd(aCanje,{LocTabAlq( 0 ),0, 0 })
					EndIf						
				EndIf 
	
				If lNExSFC = .F. .and. Substr(Alltrim(FieldGet(nSFSer)),1,1) <> "E"
					For nLoopTES := 1 To Len(aTES)
						nPos := aScan(aNrLvrIV,{|x| x[1] == aTES[nLoopTES][1]})
						If nPos > 0  // No categorizado
							nSDValImp := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_VALIMP" + Alltrim(aNrLvrIV[nPos][2])))
							nSDAliImp := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_ALQIMP" + Alltrim(aNrLvrIV[nPos][2])))
							If (cAliasSD)->(FieldGet(nSDValImp)) > 0
								If (cTbTmp = "DETVTA" .and. Alltrim(TRBPER->A1_TIPO) <> "S") .or.;
								   (cTbTmp = "DETCOM" .and. Alltrim(TRBPER->A2_TIPO) <> "S")
									nPerNac += (cAliasSD)->(FieldGet(nSDValImp))
								ElseIf (cTbTmp = "DETVTA" .and. Alltrim(TRBPER->A1_TIPO) == "S")
									nNoCat += (cAliasSD)->(FieldGet(nSDValImp))
								Endif
							Endif
						EndIf
					Next nLoopTES
				
					lActReg := .F.			
					lTesSnIva	:= .T.
					
					For nlI:=1 To Len(aNrLvIVA)
						nPosTES := aScan(aTes,{|x| x[1] == aNrLvIVA[nlI][1]})
						If nPosTES > 0 .and. ;
						&((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2]) > 0
							
							cAliq := LocTabAlq( &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_ALQIMP" + aNrLvIVA[nlI][2]) )
							nValimp := &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_VALIMP" + aNrLvIVA[nlI][2])
	
							lTesSnIva := .F. 
	
							If aNrLvIVA[nlI][1] $ cIvaInc .and. cAliq <> '0003' // IVA INCLUIDO
								If (cTbTmp = "DETCOM" .and. TRBPER->A2_TIPROV <> "A") ;
								.or. cTbTmp = "DETVTA"
									nbusca := aScan(aCanje,{|x| x[1] == cAliq})
									If nbusca == 0
										aAdd(aCanje,{cAliq, &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2]) ,nValimp})
										lActReg := .T.
									ElseIf nbusca > 0 .and. lActReg == .F.
										aCanje[nbusca][2] +=  &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2])	
										aCanje[nbusca][3] +=  nValimp
										lActReg := .T.
									EndIf 
								ElseIf cTbTmp = "DETCOM" .and. TRBPER->A2_TIPROV = "A"
									nbusca := aScan(aImporta,{|x| x[1] == cAliq })
									If nbusca == 0
									aAdd(aImporta,{cAliq , &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2]) ,nValimp,.T.})
										lActReg := .T.
									ElseIf nbusca > 0 .and. lActReg == .F.
										aImporta[nbusca][2] +=  &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2])
										aImporta[nbusca][3] +=  nValimp
										lActReg := .T.
									EndIf
								EndIf 
							ElseIf cAliq <> '0003'
								If lGravado = .F.
									lGravado := .T.
								EndIf 
								If (cTbTmp = "DETCOM" .and. TRBPER->A2_TIPROV <> "A") ;
								.or. cTbTmp = "DETVTA"
									
									nbusca := aScan(aCanje,{|x| x[1] == cAliq})
									If nbusca == 0
										If  &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2]) <> 0 
											aAdd(aCanje,{cAliq, &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2]) ,nValimp})
										ElseIf cAliasSD == "SD1" 
											aAdd(aCanje,{cAliq,(cAliasSD)->(FieldGet(nSDTotal)) - (cAliasSD)->(FieldGet(nSDDesc)) ,nValimp})
										Else
											aAdd(aCanje,{cAliq,(cAliasSD)->(FieldGet(nSDTotal)),nValimp})
										EndIf 
										lActReg := .T.
									ElseIf nbusca > 0 .and. lActReg == .F.
										If  &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2]) <>0 
											aCanje[nbusca][2] +=  &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2])
										ElseIf cAliasSD == "SD1"  
											aCanje[nbusca][2] +=  (cAliasSD)->(FieldGet(nSDTotal)) - (cAliasSD)->(FieldGet(nSDDesc))
										Else
											aCanje[nbusca][2] +=  (cAliasSD)->(FieldGet(nSDTotal))									
										EndIf 
										aCanje[nbusca][3] +=  nValimp
										lActReg := .T.
									EndIf
								ElseIf cTbTmp = "DETCOM" .and. TRBPER->A2_TIPROV = "A"
									nbusca := aScan(aImporta,{|x| x[1] == cAliq })
									nImpGra := ObtBASIMP(FieldGet(nSFCliFor), FieldGet(nSFLoja), FieldGet(nSFDoc), FieldGet(nSFSer), aNrLvIVA[nlI][2], &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_ALQIMP" + aNrLvIVA[nlI][2]))
									If nbusca == 0
									aAdd(aImporta,{cAliq ,nImpGra,nValimp,.F.})
										lActReg := .T.
									ElseIf nbusca > 0 .and. lActReg == .F.
										aImporta[nbusca][3] +=  nValimp
										lActReg := .T.
									EndIf
									
									nbusca := aScan(aCanje,{|x| x[1] == cAliq})
									If nbusca == 0
										If  &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2]) <> 0
											aAdd(aCanje,{cAliq, &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2]) ,nValimp})
										ElseIf cAliasSD == "SD1" 
											aAdd(aCanje,{cAliq,(cAliasSD)->(FieldGet(nSDTotal)) - (cAliasSD)->(FieldGet(nSDDesc)) ,nValimp})
										Else
											aAdd(aCanje,{cAliq,(cAliasSD)->(FieldGet(nSDTotal)),nValimp})
										EndIf 
										
									ElseIf nbusca > 0 
										If &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2]) <> 0
											aCanje[nbusca][2] +=  &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2])	
										ElseIf cAliasSD == "SD1"  
											aCanje[nbusca][2] +=  (cAliasSD)->(FieldGet(nSDTotal)) - (cAliasSD)->(FieldGet(nSDDesc))
										Else
											aCanje[nbusca][2] +=  (cAliasSD)->(FieldGet(nSDTotal))									
										EndIf 
										aCanje[nbusca][3] +=  nValimp
									EndIf
									
								EndIf
							ElseIf cAliq == '0003' .and. &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2]) > 0	.and. !lExenta
								lExenta 	:= .T.
								
								nOpCanj	:=  &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2])
								
								If Substr(Alltrim(FieldGet(nSFSer)),1,1) == "A" .and. &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_ALQIMP" + aNrLvIVA[nlI][2])==0
									nOpCanj	:= 0
								EndIf
								nMtIVA0:= nMtIVA0 + nOpCanj
								nbusca := aScan(aCanje,{|x| x[1] == LocTabAlq( 0 )})
								If nbusca == 0
									aAdd(aCanje,{LocTabAlq( 0 ), nOpCanj, 0 })
								ElseIf nbusca > 0 .and. cTbTmp $ "DETVTA|DETCOM"
									aCanje[nbusca][2] +=  nOpCanj
								EndIf						
							ElseIf cAliq == '0003' .and. &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][2]) == 0	
								lExenta 	:= .T.
								
								If cAliasSD == "SD1"  
									nOpCanj:=  (cAliasSD)->(FieldGet(nSDTotal)) - (cAliasSD)->(FieldGet(nSDDesc))
								Else
									nOpCanj:=  (cAliasSD)->(FieldGet(nSDTotal))									
								EndIf 
								nExentas:=nExentas+nOpCanj
								nbusca := aScan(aCanje,{|x| x[1] == LocTabAlq( 0 )})
	
								If nbusca == 0
									aAdd(aCanje,{LocTabAlq( 0 ), nOpCanj, 0 })
								ElseIf nbusca > 0 .and. cTbTmp $ "DETVTA|DETCOM"
									aCanje[nbusca][2] +=  nOpCanj
								EndIf		
							EndIf					 
						EndIf			
					Next nlI

					lActReg := .F.
					If cTbTmp = "DETCOM" .and. TRBPER->A2_TIPROV = "A" .and. Len(aNrLvrIip) > 0 
						For nlI:=1 To Len(aNrLvrIip)
	
							If aScan(aTes,{|x| x[1] == aNrLvrIip[nlI][1]}) > 0 .and. ;
							&((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvrIip[nlI][2]) > 0
								
								cAliq := LocTabAlq( &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_ALQIMP" + aNrLvrIip[nlI][2]) )
								nValimp := &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_VALIMP" + aNrLvrIip[nlI][2])
		
								lTesSnIva := .F. 
	
								If aNrLvrIip[nlI][1] $ cIvaInc .and. cAliq <> '0003' // IVA INCLUIDO
	
									nbusca := aScan(aImporta,{|x| x[1] == cAliq })
									If nbusca == 0
									aAdd(aImporta,{cAliq , &((cAliasSD) + "->" + SubStr(cAliasSD,2,2) + "_BASIMP" + aNrLvrIip[nlI][2]) ,nValimp,.T.})
										lActReg := .T.
									ElseIf nbusca > 0 .and. lActReg == .F.
										aImporta[nbusca][2] +=  &((cAliasSD) + "->" + SubStr(cAliasSD,2,2) + "_BASIMP" + aNrLvrIip[nlI][2])
										aImporta[nbusca][3] +=  nValimp
										lActReg := .T.
									EndIf
	
								ElseIf cAliq <> '0003'
									nbusca := aScan(aImporta,{|x| x[1] == cAliq })
									If nbusca == 0
										If cAliasSD == "SD1"
										aAdd(aImporta,{cAliq ,( (cAliasSD)->(FieldGet(nSDTotal))  - (cAliasSD)->(FieldGet(nSDDesc)) ),nValimp,.T.})
										Else
										aAdd(aImporta,{cAliq ,( (cAliasSD)->(FieldGet(nSDTotal)) ),nValimp,.T.})
										EndIf
										lActReg := .T.
									ElseIf nbusca > 0 .and. lActReg == .F.
										If cAliasSD == "SD1"
											aImporta[nbusca][2] +=  ((cAliasSD)->(FieldGet(nSDTotal)) - (cAliasSD)->(FieldGet(nSDDesc)))
										Else
											aImporta[nbusca][2] +=  (cAliasSD)->(FieldGet(nSDTotal))
										EndIf 
										aImporta[nbusca][3] +=  nValimp
										lActReg := .T.
									EndIf
								EndIf
							EndIf 
						Next nlI
					EndIf
					
					If cTbTmp = "DETCOM" .and. TRBPER->A2_TIPROV = "A" .and. Len(aNrLvrIm) > 0 .and. ;
					   lNExSFC = .F. .and. Substr(Alltrim(FieldGet(nSFSer)),1,1) <> "E"
					   
						For nlI:=1 To Len(aNrLvrIm)
							If aScan(aTes,{|x| x[1] == aNrLvrIm[nlI][1]}) > 0 .and. ;
							&((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvrIm[nlI][2]) > 0
	
								If cAliasSD == "SD1"
									nNoGra  += (cAliasSD)->(FieldGet(nSDTotal)) - (cAliasSD)->(FieldGet(nSDDesc))
								Else		
									nNoGra  += (cAliasSD)->(FieldGet(nSDTotal))
								EndIf 
					
								lNoGra := .T.
								Exit 
							EndIf
						Next nlI  
					EndIf 


				EndIf 
				
				nIppiva += ValImpD2(cAliasSD,aNrLvrIV,16,2,cTipoDoc,.F.,aTes)
				nIperib += ValImpD2(cAliasSD,aNrLvrIB,16,2,cTipoDoc,.F.,aTes)
				nIpeimn += ValImpD2(cAliasSD,aNrLvrMn,16,2,cTipoDoc,.F.,aTes)
				nImpint += ValImpD2(cAliasSD,aNrLvrIn,16,2,cTipoDoc,.F.,aTes)
	
				nIppina += ValImpD2(cAliasSD,aNrLvrGN,16,2,cTipoDoc,.F.,aTes) // Impuestos Nacionales - Ganancias
				nIppina += ValImpD2(cAliasSD,aNrLvrIm,16,2,cTipoDoc,.F.,aTes) // Impuesto Importaciones
				
				(cAliasSD)->(dbSkip())
			End

			If (Substr(Alltrim(FieldGet(nSFSer)),1,1) <> "E" .and. (nExentas <> 0 .and. lGravado == .T.)) .or. ;
			Substr(Alltrim(FieldGet(nSFSer)),1,1) == "E"
				lExenta	:= .T.
			Else  
				lExenta	:= .F.
			EndIf 

			If len(aCanje) == 0 .and. ((cTbTmp = "DETCOM" .and. TRBPER->A2_TIPROV <> "A") .or. cTbTmp = "DETVTA") 
				aAdd(aCanje,{LocTabAlq( 0 ),0, 0 })
			EndIf 
			If cTbTmp == "DETVTA"
				If nNoGra <> 0 .and. Substr(Alltrim(FieldGet(nSFSer)),1,1) <> "E" .AND. TRBPER->F3_RG1415 <> "066"
					If cMonEmis == "1"
						nDetImcngr	:= ConPeso(nNoGra,nMoneda,nTipCam) 
					Else
						nDetImcngr	:= nNoGra
					EndIf
					DETVTA->DET_IMCNGR	:= StrTran(StrZero(nDetImcngr,16,2), ".", "" ) 
				Else
					DETVTA->DET_IMCNGR	:= StrZero(0,15)
				EndIf 
				IF lExenta .Or. nExentas <> 0
					If cMonEmis == "1"
						nDetImpoex := ConPeso(nExentas,nMoneda,nTipCam)
					Else
						nDetImpoex := nExentas
					EndIf
					DETVTA->DET_IMPOEX	:= StrTran(StrZero(nDetImpoex,16,2), ".", "" )
				Else
					DETVTA->DET_IMPOEX	:= StrZero(0,15)
				EndIf 
				If cMonEmis == "1"
					nDetPernct	:= ConPeso(nNoCat,nMoneda,nTipCam)
					nDetIppina	:= ConPeso(nIppina + nPerNac,nMoneda,nTipCam)
					nDetIperib	:= ConPeso(nIperib,nMoneda,nTipCam)
					nDetIpeimn	:= ConPeso(nIpeimn,nMoneda,nTipCam)
					nDetImpint	:= ConPeso(nImpint,nMoneda,nTipCam)
				Else
					nDetPernct	:= nNoCat
					nDetIppina	:= nIppina + nPerNac
					nDetIperib	:= nIperib
					nDetIpeimn	:= nIpeimn
					nDetImpint	:= nImpint
				EndIf
				DETVTA->DET_PERNCT	:= StrTran(StrZero(nDetPernct,16,2), ".", "" )
				DETVTA->DET_IPPINA	:= StrTran(StrZero(nDetIppina,16,2), ".", "" )
				DETVTA->DET_IPERIB	:= StrTran(StrZero(nDetIperib,16,2), ".", "" )
				DETVTA->DET_IPEIMN	:= StrTran(StrZero(nDetIpeimn,16,2), ".", "" )
				DETVTA->DET_IMPINT	:= StrTran(StrZero(nDetImpint,16,2), ".", "" )
				DETVTA->DET_CODOPE := TipOper(TRBPER->F3_SERIE,TRBPER->A1_PAIS,lExenta,nExentas,nNoGra,nMtIVA0)

				For nlI:=1 To Len(aCanje) 
					
					If   ( (Subs(Alltrim(TRBPER->F3_SERIE),1,1) == "B" ) .And.      aCanje[nlI][2] ==  0) .or. ;
						 (Subs(Alltrim(TRBPER->F3_SERIE),1,1) == "C" )
						Loop
					EndIf
										
					If RecLock("DETVALQ",.T.)
						nCanAlq += 1
						DETVALQ->DGR_TIPCOM	:= DETVTA->DET_TIPCOM
						DETVALQ->DGR_PUNVEN	:= DETVTA->DET_PUNVEN
						DETVALQ->DGR_NUMCOM	:= DETVTA->DET_NUMCOM
						DETVALQ->DGR_ALQIVA	:= aCanje[nlI][1]
						If cMonEmis == "1"
							nDgrImpngr	:= ConPeso(aCanje[nlI][2],nMoneda,nTipCam)
							nDgrImpliq	:= ConPeso(aCanje[nlI][3],nMoneda,nTipCam)
						Else
							nDgrImpngr	:= aCanje[nlI][2]
							nDgrImpliq	:= aCanje[nlI][3]
						EndIf
						DETVALQ->DGR_IMPNGR	:= StrTran(StrZero(nDgrImpngr,16,2), ".", "" )
						DETVALQ->DGR_IMPLIQ	:= StrTran(StrZero(nDgrImpliq,16,2), ".", "" )
						DETVALQ->DGR_FCHCOM	:= DETVTA->DET_FCHCOM 
						DETVALQ->DGR_COD	:= DETVTA->DET_COD
						DETVALQ->DGR_LOJA	:= DETVTA->DET_LOJA
						DETVALQ->DGR_FILIAL	:= DETVTA->DET_FILIAL
					
						DETVALQ->(MsUnlock())
					
					EndIf 
					
				Next nlI
				
				IF ALLTRIM(TRBPER->F3_SERIE) == "C" 
					DETVTA->DET_CANALQ	:= "0"
				Else
					DETVTA->DET_CANALQ	:= Iif(Len(aCanje) == 0,'1',Alltrim(STR(nCanAlq))) 
				EndIF

			ElseIf cTbTmp = "DETCOM" 
				If Substr(Alltrim(FieldGet(nSFSer)),1,1) $ "B|C"
					DETCOM->DET_IMCNGR	:= StrZero(0,15)
					DETCOM->DET_IMPOEX	:= StrZero(0,15)
				Else
					If nNoGra <> 0   .and. Substr(Alltrim(FieldGet(nSFSer)),1,1) <> "E" .AND. TRBPER->F3_RG1415 <> "066"
						If cMonEmis == "1"
							nDetImcngr	:= ConPeso(nNoGra,nMoneda,nTipCam)
						Else
							nDetImcngr	:= nNoGra
						EndIf
						DETCOM->DET_IMCNGR	:= StrTran(StrZero(nDetImcngr,16,2), ".", "" )
					Else
						DETCOM->DET_IMCNGR	:= StrZero(0,15)
					EndIf 
					IF lExenta .Or. nExentas <> 0
						If cMonEmis == "1"
							nDetImpoex	:= ConPeso(nExentas,nMoneda,nTipCam)
						Else
							nDetImpoex	:= nExentas
						EndIf
						DETCOM->DET_IMPOEX	:= StrTran(StrZero(nDetImpoex,16,2), ".", "" )
					Else
						DETCOM->DET_IMPOEX	:= StrZero(0,15)
					EndIf 
				EndIf 
			 	
				//Percepciones
				If cMonEmis == "1"
					nDetImpiva	:= ConPeso(nIppiva,nMoneda,nTipCam) // Percepcion de IVA
					nDetIppina	:= ConPeso(nIppina,nMoneda,nTipCam) // percepcion de ganancias
					nDetIperib	:= ConPeso(nIperib,nMoneda,nTipCam) // Percepcion IB
					nDetIpeimn	:= ConPeso(nIpeimn,nMoneda,nTipCam)
					nDetImpint	:= ConPeso(nImpint,nMoneda,nTipCam)
				Else
					nDetImpiva	:= nIppiva // Percepcion de IVA
					nDetIppina	:= nIppina // percepcion de ganancias
					nDetIperib	:= nIperib // Percepcion IB
					nDetIpeimn	:= nIpeimn
					nDetImpint	:= nImpint
				EndIf
				DETCOM->DET_IMPIVA	:= StrTran(StrZero(nDetImpiva,16,2), ".", "" ) // Percepcion de IVA
				DETCOM->DET_IPPINA	:= StrTran(StrZero(nDetIppina,16,2), ".", "" ) // percepcion de ganancias
				DETCOM->DET_IPERIB	:= StrTran(StrZero(nDetIperib,16,2), ".", "" ) // Percepcion IB
				DETCOM->DET_IPEIMN	:= StrTran(StrZero(nDetIpeimn,16,2), ".", "" )
				DETCOM->DET_IMPINT	:= StrTran(StrZero(nDetImpint,16,2), ".", "" )
				DETCOM->DET_CODOPE	:= TipOper(TRBPER->F3_SERIE,TRBPER->A2_PAIS,lExenta,nExentas,nNoGra,nMtIVA0)
				DETCOM->DET_OTRTRI	:= STRZERO(0,15)

				If DETCOM->DET_TIPCOM $ '033|058|059|060|063'
					DETCOM->DET_CUIT	:= SM0->M0_CGC
					DETCOM->DET_DENOMI	:= SUBSTR(SM0->M0_NOME,1,30)
				Else
					DETCOM->DET_CUIT	:= STRZERO(0,11)
				EndIf 

				DETCOM->DET_IVACOM	:= STRZERO(0,15)
				nNoCat := 0
				
				For nlI:=1 To Len(aCanje)
								
					If TRBPER->A2_TIPROV == "A" .or.  ( (Subs(Alltrim(TRBPER->F3_SERIE),1,1) == "B" ) .And.      aCanje[nlI][2] ==  0) .or. ;
						 (Subs(Alltrim(TRBPER->F3_SERIE),1,1) == "C" )
						Loop
					EndIf
							
					If RecLock("DETCALQ",.T.)
						nCanAlq += 1
						DETCALQ->CAL_TIPCOM	:= DETCOM->DET_TIPCOM
						DETCALQ->CAL_PUNVEN	:= DETCOM->DET_PUNVEN
						DETCALQ->CAL_NUMCOM	:= DETCOM->DET_NUMCOM
						DETCALQ->CAL_CODVEN	:= DETCOM->DET_CODVEN
						DETCALQ->CAL_NIDVEN	:= DETCOM->DET_NIDVEN
						DETCALQ->CAL_ALQIVA	:= aCanje[nlI][1]
						If cMonEmis == "1"						
							nCalImpngr	:= ConPeso(aCanje[nlI][2],nMoneda,nTipCam)
							nCalImpliq	:= ConPeso(aCanje[nlI][3],nMoneda,nTipCam)
						Else
							nCalImpngr	:= aCanje[nlI][2]
							nCalImpliq	:= aCanje[nlI][3]
						EndIf
						DETCALQ->CAL_IMPNGR	:= StrTran(StrZero(nCalImpngr,16,2), ".", "" )
						DETCALQ->CAL_IMPLIQ	:= StrTran(StrZero(nCalImpliq,16,2), ".", "" )
						DETCALQ->CAL_FCHCOM	:= DETCOM->DET_FCHCOM 
						DETCALQ->CAL_COD	:= DETCOM->DET_COD
						DETCALQ->CAL_LOJA	:= DETCOM->DET_LOJA
						DETCALQ->CAL_FILIAL	:= DETCOM->DET_FILIAL
						
						
						nNoCat += aCanje[nlI][3]
						DETCALQ->(MsUnlock())
					EndIf 
				Next nlI 
								
				If TRBPER->A2_TIPROV == "A"
					If Len(aImporta) <= 0
				 		If RecLock("DCOMIM",.T.)
							DCOMIM->IMP_DESPIM	:= DETCOM->DET_DESPIM // Space(16)
							DCOMIM->IMP_IMPNGR	:= StrTran(StrZero(ConPeso(0,nMoneda,nTipCam),16,2), ".", "" )
							DCOMIM->IMP_ALQIVA	:= "0003"
							DCOMIM->IMP_IMPLIQ	:= StrTran(StrZero(ConPeso(0,nMoneda,nTipCam),16,2), ".", "" )
							DCOMIM->IMP_TIPCOM	:= DETCOM->DET_TIPCOM
							DCOMIM->IMP_PUNVEN	:= DETCOM->DET_PUNVEN
							DCOMIM->IMP_NUMCOM	:= DETCOM->DET_NUMCOM
						EndIf
						DCOMIM->(MsUnlock())
					Else
						
					 	For nlI:=1 To Len(aImporta)
							If Len(aImporta) > 1 .and. aImporta[nlI][1] == "0003"
								Loop
							EndIf
							nCanAlq += 1
							If RecLock("DCOMIM",.T.)
								DCOMIM->IMP_DESPIM	:= DETCOM->DET_DESPIM // Space(16)
								DCOMIM->IMP_IMPNGR	:= StrTran(StrZero(Iif(aImporta[nlI][4],Iif(cMonEmis == "1",ConPeso(aImporta[nlI][2],nMoneda,nTipCam),aImporta[nlI][2]),aImporta[nlI][2]),16,2), ".", "" )
								DCOMIM->IMP_ALQIVA	:= aImporta[nlI][1]
								nNoCat+= aImporta[nlI][3]
								If cMonEmis == "1"
									nImpImpliq	:= ConPeso(aImporta[nlI][3],nMoneda,nTipCam)
								Else
									nImpImpliq	:= aImporta[nlI][3]
								EndIf
								DCOMIM->IMP_IMPLIQ	:= StrTran(StrZero(nImpImpliq,16,2), ".", "" )
								DCOMIM->IMP_TIPCOM	:= DETCOM->DET_TIPCOM
								DCOMIM->IMP_PUNVEN	:= DETCOM->DET_PUNVEN
								DCOMIM->IMP_NUMCOM	:= DETCOM->DET_NUMCOM
							EndIf
							DCOMIM->(MsUnlock())
						Next nlI
					EndIf
				Else				
					For nlI:=1 To Len(aImporta) 
						If Len(aImporta) > 1 .and. aImporta[nlI][1] == "0003"
							Loop
						EndIf			 
						nCanAlq += 1
						If RecLock("DCOMIM",.T.)
							DCOMIM->IMP_DESPIM	:= DETCOM->DET_DESPIM // Space(16)
							DCOMIM->IMP_IMPNGR	:= StrTran(StrZero(ConPeso(aImporta[nlI][2],nMoneda,nTipCam),16,2), ".", "" )
							DCOMIM->IMP_ALQIVA	:= aImporta[nlI][1]
							DCOMIM->IMP_IMPLIQ	:= StrTran(StrZero(ConPeso(aImporta[nlI][3],nMoneda,nTipCam),16,2), ".", "" )
							DCOMIM->IMP_TIPCOM	:= DETCOM->DET_TIPCOM
							DCOMIM->IMP_PUNVEN	:= DETCOM->DET_PUNVEN
							DCOMIM->IMP_NUMCOM	:= DETCOM->DET_NUMCOM
						EndIf 
						DCOMIM->(MsUnlock())
					Next nlI 
				EndIf
				
				IF Subs(ALLTRIM(TRBPER->F3_SERIE),1,1) $ "B|C" 
					DETCOM->DET_CANALQ	:= "0"		
				Else
					If alltrim(DETCOM->DET_CODOPE) =="N"
						If Subs(Alltrim(TRBPER->F3_SERIE),1,1) $ "A|E|M" 
							DETCOM->DET_CANALQ	:=   Iif(nCanAlq == 0,'1',Alltrim(STR(nCanAlq)))  
						Else
							DETCOM->DET_CANALQ	:= 	Iif(Len(aImporta)+ Len(aCanje) == 0,'1',Iif(nCanAlq-1>0,Alltrim(STR(nCanAlq-1)),"0" ) )
						EndIf	
					Else 
					DETCOM->DET_CANALQ	:= 	Iif(Len(aImporta)+ Len(aCanje) == 0,'1',Alltrim(STR(nCanAlq)))
					EndIf
				EndIF
				If cMonEmis == "1"
					nDetCrfcom	:= ConPeso(nNoCat,nMoneda,nTipCam)
				Else
					nDetCrfcom	:= nNoCat
				EndIf
				DETCOM->DET_CRFCOM	:= StrTran(StrZero(nDetCrfcom,16,2), ".", "" )
			EndIf 
		EndIf 
	EndIf 
	
	RestArea(aArea)
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ValImpD2     ³Autor ³ Emanuel V.V.         ³Data³ 17/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Devuelve el valor formateado extraido del impuesto que     ³±± 
±±³          ³ se envie.                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValImpD2(cAlias,aImp,nAnc,nDec,cTipDoc,lCar,aTes)
	Local nlI		:= 0
	Local nValor	:= 0
	Local cValor	:= 0
	Local aPos		:= {}
	
	Default lCar := .T.
	
	If ValType(aImp) <> "A"
		Return Iif(lCar,cValor,nValor)		
	EndIf 
	
	For nlI:=1 To Len(aImp)
		If aScan(aTes,{|x| x[1] == aImp[nlI][1]}) > 0
			If aScan(aPos,aImp[nlI][2]) == 0
				nValor += &(cAlias + "->" + SubStr(cAlias,2,2)+"_VALIMP" + aImp[nlI][2])
				aAdd(aPos,aImp[nlI][2])
			EndIf 
		EndIf 
	Next nlI
	
	cValor := StrTran(StrZero(nValor,nAnc,nDec), ".", "" )
Return Iif(lCar,cValor,nValor)		

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TipOper      ³Autor ³ Emanuel V.V.         ³Data³ 21/05/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Devuelve el valor Codigo de operacion                      ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TipOper(cSerie,cPais,lExenta,nExentas,nNoGra,nMtIVA0)

	Local cRetorna 
	Default nMtIVA0 :=0
	cSerie := Substr(Alltrim(cSerie),1,1)
	
	If (lExenta .or. nExentas <> 0 .or. nNoGra <> 0 .or. nMtIVA0 <> 0 ) .or. (cSerie = "E") 
		Do case 
		Case cSerie = "E" .and. Alltrim(cPais) = "063"
			cRetorna := "Z"
		Case cSerie = "E" .and. Alltrim(cPais) <> "063"
			cRetorna := "X"
				Case cSerie <> "E" .and. (nExentas <> 0 .or. nMtIVA0<> 0)
			cRetorna := "E"
				Case cSerie <> "E" .and. nNoGra <> 0	
			cRetorna := "N"
		Otherwise 
			cRetorna := "C"
		EndCase
	Else
		cRetorna := "0"
	EndIf 
Return cRetorna

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CredFisSer   ³Autor ³ Emanuel V.V.         ³Data³ 22/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Genera inf. credito fiscal imp servicios                   ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CredFisSer(cDtIni,cDtFim,aCodTab)
	Local cQry		:= ''
	Local cProc	:= SuperGetMV("MV_TITIMPT",.T.,"")
	Local cTRBSER := ''
	Local cMes 	:= ''
	Local cAno		:= ''
	Local nRegGen := 0
	Local cMonEmis := Iif(Len(aCodTab[1]) > 4 ,SubStr(aCodTab[1][5], 1, 1), "1")
	Local nCFIMONMOR := 0
	Local nCFIMONING := 0
	Local nCFIIMPCOM := 0
	Default aCodTab := {}
	If Val(Substr(cDtIni,5,2)) = 1 
		cMes	:= "12"
		cAno	:= Alltrim(Str(Val(Substr(cDtIni,1,4))-1))
		cDtIni	:= cAno + cMes + "01"  
		cDtFim	:= cAno + cMes + UltDiaMes(0,0,cDtIni)
	Else
		cMes	:= StrZero((Val( Substr(cDtIni,5,2) )-1) ,2,0)
		cAno	:= Substr(cDtIni,1,4)
		cDtIni	:= cAno + cMes + "01"
		cDtFim	:= cAno + cMes + UltDiaMes(0,0,cDtIni)
	EndIf 
	
	cQry	:= " SELECT SE2.*, A6_CGC, A2_NOME ,A2_CGC, A2_COD"
	IF SA2->(FieldPos("A2_NIF")) > 0
		cQry	+= " ,A2_NIF "
	EndIf
	cQry	+= " FROM "+RetsqlName("SE2")+" SE2 "
	cQry	+= " INNER JOIN " + RetsqlName("SA2") + " SA2 ON "
	cQry    += " A2_FILIAL = '" + xFilial("SA2") + "' "
	cQry	+= " AND E2_FORNECE = A2_COD "
	cQry	+= " AND E2_LOJA=A2_LOJA "
	cQry	+= " AND SA2.D_E_L_E_T_='' "
	
	cQry	+= " INNER JOIN " + RetsqlName("SEK") + " SEK ON "
	cQry    += " EK_FILIAL = '" + xFilial("SEK") + "' "
	cQry	+= " AND E2_FORNECE = EK_FORNECE"
	cQry	+= " AND E2_LOJA    = EK_LOJA "
	cQry	+= " AND E2_ORDPAGO = EK_ORDPAGO "
	cQry	+= " AND SEK.D_E_L_E_T_='' "	
	cQry	+= " INNER JOIN " + RetsqlName("SA6") + " SA6 ON "
	cQry	+= " A6_FILIAL = '" + xFilial("SA6") + "' "
	cQry	+= " AND A6_COD     = EK_BANCO "
	cQry	+= " AND A6_AGENCIA = EK_AGENCIA "
	cQry	+= " AND A6_NUMCON  = EK_CONTA "
	cQry	+= " AND SA6.D_E_L_E_T_='' "
	
	cQry	+= " WHERE E2_EMISSAO BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "
	cQry   += " AND E2_FILIAL = '" + xFilial("SE2") + "' "
	cQry	+= " AND SE2.D_E_L_E_T_='' "
	cQry	+= " ORDER BY E2_EMISSAO, E2_TIPO, E2_PREFIXO, E2_NUM "
	
	If Select("TRBSER")>0
		DbSelectArea("TRBSER")
		TRBSER->(DbCloseArea())
	EndIf
	
	cTRBSER := ChangeQuery(cQry)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBSER ) ,"TRBSER", .T., .F.)
	
	DbSelectArea("TRBSER")
	TRBSER->(dbGoTop())
	If TRBSER->(!Eof())
		While TRBSER->(!Eof()) 
			If Alltrim(TRBSER->E2_TIPO) $ cProc 
				If SA2->(FieldPos("A2_NIF")) > 0 .and.  TRBSER->E2_ALIQIMP > 0 .and. TRBSER->E2_IMPTO > 0
					If DIMOFI->(!DbSeek( TRBSER->E2_EMISSAO + "1" + TRBSER->E2_NUM + Space(20-Len(ALLTRIM(TRBSER->E2_NUM))) + TRBSER->E2_FORNECE + TRBSER->E2_LOJA + TRBSER->E2_FILIAL)) // CFI_FCHOPE + CFI_TIPCOM + CFI_IDCOMP + CFI_COD + CFI_LOJA + CFI_FILIAL					
						If RecLock("DIMOFI",.T.)
							DIMOFI->CFI_TIPCOM := "1"
							DIMOFI->CFI_DESCOM := "" //"Factura"
							DIMOFI->CFI_IDCOMP := TRBSER->E2_NUM
							DIMOFI->CFI_FCHOPE := TRBSER->E2_EMISSAO
							DIMOFI->CFI_MONMOR := StrTran(StrZero(TRBSER->E2_VALOR,16,2), ".", "" )
							DIMOFI->CFI_CODMON := SubStr(Posicione("SX5", 1, xFilial("SX5")+"OB" + (AllTrim(Str(TRBSER->E2_MOEDA)) + Space(TAMSX3("X5_CHAVE")[01]-Len(AllTrim(Str(TRBSER->E2_MOEDA))))) , "X5_DESCSPA"),1,3)
	
							DIMOFI->CFI_COD		:= TRBSER->E2_FORNECE
							DIMOFI->CFI_LOJA	:= TRBSER->E2_LOJA
							DIMOFI->CFI_FILIAL	:= TRBSER->E2_FILIAL
							
							DIMOFI->CFI_TPCAMB := StrTran(StrZero(Iif(TRBSER->E2_TXMOEDA>1,TRBSER->E2_TXMOEDA,1),11,6), ".", "" )   
			
							DIMOFI->CFI_CUITPR := TRBSER->A2_CGC 
							DIMOFI->CFI_NIFPRE := TRBSER->A2_NIF
							DIMOFI->CFI_FCHING := TRBSER->E2_DTINGIM
							DIMOFI->CFI_ALIQAP := LocTabAlq( TRBSER->E2_ALIQIMP )
							If cMonEmis == "1" 
								nCFIMONING := ConPeso(TRBSER->E2_VLRIMP,TRBSER->E2_MOEDA,TRBSER->E2_TXMOEDA)
								nCFIIMPCOM := ConPeso(TRBSER->E2_IMPTO,TRBSER->E2_MOEDA,TRBSER->E2_TXMOEDA)
							Else
								nCFIMONING := TRBSER->E2_VLRIMP
								nCFIIMPCOM := TRBSER->E2_IMPTO
							EndIf
							DIMOFI->CFI_MONING := StrTran(StrZero(nCFIMONING,16,2), ".", "" )
							DIMOFI->CFI_IMPCOM := StrTran(StrZero(nCFIIMPCOM,16,2), ".", "" )
							DIMOFI->CFI_NOMBRE := TRBSER->A2_NOME
							DIMOFI->CFI_IDPLCO := TRBSER->E2_ORDPAGO // "1 - Factura" 
							DIMOFI->CFI_CUITEP := TRBSER->A6_CGC
							DIMOFI->(MsUnlock())
							nRegGen++
						EndIf
					EndIf 
				EndIf 
			EndIf 
			TRBSER->(dbSkip())
		Enddo	
	EndIf 
Return nRegGen
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³UltDiaMes   	³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o ultimo dia valido para um determinado mes.       ³±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function UltDiaMes(nMes,nAno,cFecha)
	Local cUltDia	:= ""
	Local cMes		:= ""
	Local cAno		:= ""
	
	If !Empty(cFecha)
		cMes	:= StrZero(Val(Substr(cFecha,5,2)),2)
		cAno	:= Substr(cFecha,1,4)
	ElseIf Empty(cFecha)
		cMes	:= StrZero(nMes,2)
		cAno	:= StrZero(nAno,4)
	EndIf 
	  
	Do Case
		Case cMes$("01|03|05|07|08|10|12")
			cUltDia := "31"
		Case cMes$("04|06|09|11")
			cUltDia := "30"
		OtherWise
			If (VAL(cAno)/4)-(INT(VAL(cAno)/4)) <> 0
				cUltDia := "28"
			Else
				cUltDia := "29"
			EndIf
	EndCase
Return(cUltDia)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LocTabAlq   	³Autor ³ Emanuel Villicaña    ³Data³ 12/05/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna Alicuota segun Afip                                ³±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LocTabAlq(nAliq)
	Local cAlq := ""
	
	Do case
	Case nAliq = 0
		cAlq := "0003"
	Case nAliq > 8 .And. nAliq < 13 //// nAliq = 10.5
		cAlq := "0004"
	Case nAliq > 19 .And. nAliq < 23 // nAliq = 21.0
		cAlq := "0005"
	Case nAliq > 25 .And. nAliq < 29 //  nAliq = 27.00
		cAlq := "0006"
	Case nAliq > 4 .And. nAliq < 6  // nAliq = 5
		cAlq := "0008"
	Case nAliq > 2 .And. nAliq < 3  // nAliq = 2.5
		cAlq := "0009"
	Endcase
Return (cAlq)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Loc3865       ³Autor ³ Emanuel Villicaña    ³Data³ 25/05/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³ Funcion encargada de administrar las sucursales o no       ³±±
±±º          ³ dependiendo si se selecciona consolidado o no.             ³±±
±±º          ³ Argentina.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Loc3865(cDtIni,cDtFim,aCodTab,lConfirm)
	Local nProcFil	:= 0
	Local cBkpFil		:= ""
	Local cSuc			:= Substr(aCodTab[1][3],1,1)
	Local aTabs   	:= {}
	Local aRel			:= {}
	Local nPos			:= 0
	Local nCanReg		:= 0
	
	cBkpFil:= cFilAnt
	aTabs	:= CurTmp3865() // Cursores temporales y nombres fisicos de los archivos.
	
	If  cSuc== "1" //Significa que sera consolidado y que hubo seleccion de Sucursales
		//Cambiar logico para que NO continue procesando filiales   
		For nProcFil:=1 to len(aFilsCalc)
			If aFilsCalc[nProcFil,1] == .T.
				cFilAnt := aFilsCalc[nProcFil,2] // cFilAnt es la variable global que indica en que sucursal estamos trabajando
				aRel := LocArg("CV3865",cDtIni,cDtFim,aCodTab,lConfirm)
				aFilsCalc[nProcFil,1]:=.F.

				nPos:= Ascan(aRel,STR0025)
				If nPos <> 0
					nCanReg += Val(Substr(aRel[nPos],Len(STR0025)+1))
					aRel[nPos] := STR0025 + Alltrim(Str(nCanReg))	
				EndIf 
			EndIf
		Next nProcFil 
	Else 
		aRel := LocArg("CV3865",cDtIni,cDtFim,aCodTab,lConfirm)
	EndIf 
	
	DbSelectArea("DETCOM")
	DETCOM->(dbSetOrder(1))
	DETCOM->(dbGoTop())
	Do While DETCOM->(!Eof()) 
		If Empty(Alltrim(DETCOM->DET_IMCNGR))
			RecLock("DETCOM",.F.)
			DETCOM->(dbDelete()) 
			DETCOM->(MsUnlock())
		ElseIf	DETCOM->DET_TIPROV == "A" 
			RecLock("DETCOM",.F.)
			DETCOM->DET_PUNVEN	:= DETCOM->DET_PUNVEN 
			DETCOM->DET_NUMCOM	:= DETCOM->DET_NUMCOM 
			DETCOM->DET_TIPCOM	:= DETCOM->DET_NUMCOM
			DETCOM->(MsUnlock())
		EndIf 
		DETCOM->(DbSkip())
	Enddo
	
	DbSelectArea("DETVTA")
	DETVTA->(dbSetOrder(1))
	DETVTA->(dbGoTop())
	Do While DETVTA->(!Eof()) 
		If Empty(Alltrim(DETVTA->DET_IMCNGR))
			RecLock("DETVTA",.F.)
			DETVTA->(dbDelete()) 
			DETVTA->(MsUnlock())
		EndIf 
		DETVTA->(DbSkip())
	Enddo
	
	cFilAnt := cBkpFil // Restaura Sucursal que se estaba utilizando
	
	LogArqTRep("CV3865",aRel)
Return aTabs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CurTmp3865    ³Autor ³ Emanuel Villicaña    ³Data³ 22/05/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³ Crea tablas temporales para llamado TRRKMI                 ³±±
±±º          ³ Argentina.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CurTmp3865()
	Local aTabs		:= {}
	Local aStruVc1	:= {} // RG 3865 (Ventas y compras) Cabecera
	Local cArqVc1		:= "" // RG 3865 (Ventas y compras) Cabecera
	
	// RG 3865 (Ventas y compras) Cabecera
	cArqVc1	:= ""
	aStruVc1	:= {}
			
	AADD(aStruVc1,{"ENC_CUIT"   ,"C",011,0}) //CUIT Informante
	AADD(aStruVc1,{"ENC_PERIOD" ,"C",006,0}) //Periodo 
	AADD(aStruVc1,{"ENC_SECUEN" ,"C",002,0}) //Secuencia
	AADD(aStruVc1,{"ENC_SINMOV" ,"C",001,0}) //Sin Movimiento
	AADD(aStruVc1,{"ENC_PRORRA" ,"C",001,0}) //Prorratear Credito Fiscal Computable
	AADD(aStruVc1,{"ENC_CREFIS" ,"C",001,0}) //Credito Fiscal Computable Global o por Comprobante
	AADD(aStruVc1,{"ENC_IMPCGF" ,"C",015,0}) //Importe Credito Fiscal Computable Global
	AADD(aStruVc1,{"ENC_IMPCAD" ,"C",015,0}) //Importe Credito Fiscal Computable, con asignacion directa
	AADD(aStruVc1,{"ENC_IMPCDP" ,"C",015,0}) //Importe Credito Fiscal Computable, determinado por prorrateo
	AADD(aStruVc1,{"ENC_IMPCNG" ,"C",015,0}) //Importe Credito Fiscal no Computable Global
	AADD(aStruVc1,{"ENC_IMPSSO" ,"C",015,0}) //Credito Fiscal Contrib. Seg. Soc. y Otros Conceptos
	AADD(aStruVc1,{"ENC_IMPCSO" ,"C",015,0}) //Credito Fiscal Computable Contrib. Seg. Soc. y Otros Conceptos
			
		//Creacion de Objeto RGENCA 
		oTmpTable := FWTemporaryTable():New("RGENCA") 
		oTmpTable:SetFields( aStruVc1 ) 
	
		aOrdem	:=	{"ENC_CUIT","ENC_PERIOD"} 
	
		oTmpTable:AddIndex("IN1", aOrdem) 
	
		oTmpTable:Create() 
		
	aAdd(aTabs,{"RGENCA",cArqVc1})
	
	// RG 3865 Ventas Detalle
	cArqVc1	:= ""
	aStruVc1	:= {}
			
	AADD(aStruVc1,{"DET_FCHCOM" ,"C",008,0}) //Fecha de comprobante
	AADD(aStruVc1,{"DET_TIPCOM" ,"C",003,0}) //Tipo de comprobante 
	AADD(aStruVc1,{"DET_PUNVEN" ,"C",005,0}) //Punto de venta
	AADD(aStruVc1,{"DET_NUMCOM" ,"C",020,0}) //Numero de comprobante
	AADD(aStruVc1,{"DET_NCHAST" ,"C",020,0}) //Numero de comprobante hasta
	AADD(aStruVc1,{"DET_CODCOM" ,"C",002,0}) //Codigo de documento del comprador
	AADD(aStruVc1,{"DET_CUIT"   ,"C",020,0}) //Numero de identificacion del comprador
	AADD(aStruVc1,{"DET_NOMBRE" ,"C",030,0}) //Apellido y nombre o denominacion del comprador
	AADD(aStruVc1,{"DET_IMPTOT" ,"C",015,0}) //Importe total de la operacion
	AADD(aStruVc1,{"DET_IMCNGR" ,"C",015,0}) //Importe total de conceptos que no integran el precio neto gravado
	AADD(aStruVc1,{"DET_PERNCT" ,"C",015,0}) //Percepcion a no categorizados
	AADD(aStruVc1,{"DET_IMPOEX" ,"C",015,0}) //Importe de operaciones exentas
	AADD(aStruVc1,{"DET_IPPINA" ,"C",015,0}) //Importe de percepciones o pagos a cuenta de impuestos Nacionales
	AADD(aStruVc1,{"DET_IPERIB" ,"C",015,0}) //Importe de percepciones de Ingresos Brutos
	AADD(aStruVc1,{"DET_IPEIMN" ,"C",015,0}) //Importe de percepciones impuestos Municipales
	AADD(aStruVc1,{"DET_IMPINT" ,"C",015,0}) //Importe impuestos internos
	AADD(aStruVc1,{"DET_CODMON" ,"C",003,0}) //Codigo de moneda
	AADD(aStruVc1,{"DET_TPCAMB" ,"C",010,0}) //Tipo de cambio
	AADD(aStruVc1,{"DET_CANALQ" ,"C",001,0}) //Cantidad de alicuotas de IVA
	AADD(aStruVc1,{"DET_CODOPE" ,"C",001,0}) //Codigo de operacion
	AADD(aStruVc1,{"DET_OTRTRI" ,"C",015,0}) //Otros Tributos
	AADD(aStruVc1,{"DET_COD"    ,"C",TamSx3("A1_COD")[1],0}) 	
	AADD(aStruVc1,{"DET_LOJA"   ,"C",TamSx3("A1_LOJA")[1],0})
	AADD(aStruVc1,{"DET_FILIAL" ,"C",TamSx3("F3_FILIAL")[1],0})
	
		//Creacion de Objeto DETVTA 
		oTmpTable2 := FWTemporaryTable():New("DETVTA") 
		oTmpTable2:SetFields( aStruVc1 ) 
	
		aOrdem	:=	{"DET_PUNVEN","DET_TIPCOM","DET_NUMCOM","DET_FCHCOM","DET_COD","DET_LOJA","DET_FILIAL"} 
	
		oTmpTable2:AddIndex("IN2", aOrdem) 
	
		oTmpTable2:Create() 
	aAdd(aTabs,{"DETVTA",cArqVc1})
	
	// RG 3865 Ventas Alicuota
	cArqVc1	:= ""
	aStruVc1	:= {}
			
	AADD(aStruVc1,{"DGR_TIPCOM" ,"C",003,0}) // Tipo de comprobante 
	AADD(aStruVc1,{"DGR_PUNVEN" ,"C",005,0}) // Punto de venta
	AADD(aStruVc1,{"DGR_NUMCOM" ,"C",020,0}) // Numero de comprobante
	AADD(aStruVc1,{"DGR_IMPNGR" ,"C",015,0}) // Importe neto gravado
	AADD(aStruVc1,{"DGR_ALQIVA" ,"C",004,0}) // Alicuota de IVA
	AADD(aStruVc1,{"DGR_IMPLIQ" ,"C",015,0}) // Impuesto Liquidado 

	AADD(aStruVc1,{"DGR_FCHCOM" ,"C",008,0}) //Fecha de comprobante
	AADD(aStruVc1,{"DGR_COD"    ,"C",TamSx3("A2_COD")[1],0}) 	
	AADD(aStruVc1,{"DGR_LOJA"   ,"C",TamSx3("A2_LOJA")[1],0})
	AADD(aStruVc1,{"DGR_FILIAL" ,"C",TamSx3("F3_FILIAL")[1],0})


	
		//Creacion de Objeto DETVALQ 
		oTmpTable3 := FWTemporaryTable():New("DETVALQ") 
		oTmpTable3:SetFields( aStruVc1 ) 
	
		aOrdem	:=	{"DGR_PUNVEN","DGR_TIPCOM","DGR_NUMCOM","DGR_FCHCOM","DGR_COD","DGR_LOJA","DGR_FILIAL"} 
			
		oTmpTable3:AddIndex("IN3", aOrdem) 
	
		oTmpTable3:Create() 
	aAdd(aTabs,{"DETVALQ",cArqVc1})
	
	// RG 3865 Compras Detalle
	cArqVc1	:= ""
	aStruVc1	:= {}
			
	AADD(aStruVc1,{"DET_FCHCOM" ,"C",008,0}) //Fecha de comprobante
	AADD(aStruVc1,{"DET_TIPCOM" ,"C",003,0}) //Tipo de comprobante 
	AADD(aStruVc1,{"DET_PUNVEN" ,"C",005,0}) //Punto de venta
	AADD(aStruVc1,{"DET_NUMCOM" ,"C",020,0}) //Numero de comprobante
	AADD(aStruVc1,{"DET_DESPIM" ,"C",016,0}) //Despacho de importacion
	AADD(aStruVc1,{"DET_CODVEN" ,"C",002,0}) //Codigo de documento del vendedor
	AADD(aStruVc1,{"DET_NIDVEN" ,"C",020,0}) //Numero de identificacion del vendedor
	AADD(aStruVc1,{"DET_NOMBRE" ,"C",030,0}) //Apellido y nombre o denominacion del vendedor
	AADD(aStruVc1,{"DET_IMPTOT" ,"C",015,0}) //Importe total de la operacion
	AADD(aStruVc1,{"DET_IMCNGR" ,"C",015,0}) //Importe total de conceptos que no integran el precio neto gravado
	AADD(aStruVc1,{"DET_IMPOEX" ,"C",015,0}) //Importe de operaciones exentas
	AADD(aStruVc1,{"DET_IMPIVA" ,"C",015,0}) //Importe de percepciones o pagos a cuenta del Impuesto al Valor Agregado
	AADD(aStruVc1,{"DET_IPPINA" ,"C",015,0}) //Importe de percepciones o pagos a cuenta de otros impuestos nacionales
	AADD(aStruVc1,{"DET_IPERIB" ,"C",015,0}) //Importe de percepciones de Ingresos Brutos
	AADD(aStruVc1,{"DET_IPEIMN" ,"C",015,0}) //Importe de percepciones impuestos Municipales
	AADD(aStruVc1,{"DET_IMPINT" ,"C",015,0}) //Importe impuestos internos
	AADD(aStruVc1,{"DET_CODMON" ,"C",003,0}) //Codigo de moneda
	AADD(aStruVc1,{"DET_TPCAMB" ,"C",010,0}) //Tipo de cambio
	AADD(aStruVc1,{"DET_CANALQ" ,"C",001,0}) //Cantidad de alicuotas de IVA
	AADD(aStruVc1,{"DET_CODOPE" ,"C",001,0}) //Codigo de operacion
	AADD(aStruVc1,{"DET_CRFCOM" ,"C",015,0}) //Credito Fiscal Computable		
	AADD(aStruVc1,{"DET_OTRTRI" ,"C",015,0}) //Otros Tributos
	AADD(aStruVc1,{"DET_CUIT"   ,"C",011,0}) //CUIT emisor/corredor
	AADD(aStruVc1,{"DET_DENOMI" ,"C",030,0}) //Denominacion del emisor/corredor
	AADD(aStruVc1,{"DET_IVACOM" ,"C",015,0}) //IVA comision
	AADD(aStruVc1,{"DET_COD"    ,"C",TamSx3("A2_COD")[1],0}) 	
	AADD(aStruVc1,{"DET_LOJA"   ,"C",TamSx3("A2_LOJA")[1],0})
	AADD(aStruVc1,{"DET_FILIAL" ,"C",TamSx3("F3_FILIAL")[1],0})
	
	If SA2->(FieldPos("A2_TIPROV")) > 0
		AADD(aStruVc1,{"DET_TIPROV" ,"C",TamSx3("A2_TIPROV")[1],0})
	Else 
		AADD(aStruVc1,{"DET_TIPROV" ,"C",001,0})
	EndIf 	
		
		//Creacion de Objeto DETCOM 
		oTmpTable4 := FWTemporaryTable():New("DETCOM") 
		oTmpTable4:SetFields( aStruVc1 ) 
	
		aOrdem	:=	{"DET_PUNVEN","DET_TIPCOM","DET_NUMCOM","DET_FCHCOM","DET_COD","DET_LOJA","DET_FILIAL"} 
	
		oTmpTable4:AddIndex("IN4", aOrdem) 
	
		oTmpTable4:Create() 
	aAdd(aTabs,{"DETCOM",cArqVc1})
		
	// RG 3865 Compras Alicuota
	cArqVc1	:= ""
	aStruVc1	:= {}
			
	AADD(aStruVc1,{"CAL_TIPCOM" ,"C",003,0}) // Tipo de comprobante 
	AADD(aStruVc1,{"CAL_PUNVEN" ,"C",005,0}) // Punto de venta
	AADD(aStruVc1,{"CAL_NUMCOM" ,"C",020,0}) // Numero de comprobante
	AADD(aStruVc1,{"CAL_CODVEN" ,"C",002,0}) // Codigo de documento del vendedor
	AADD(aStruVc1,{"CAL_NIDVEN" ,"C",020,0}) // Numero de identificacion del vendedor
	AADD(aStruVc1,{"CAL_IMPNGR" ,"C",015,0}) // Importe neto gravado
	AADD(aStruVc1,{"CAL_ALQIVA" ,"C",004,0}) // Alicuota de IVA
	AADD(aStruVc1,{"CAL_IMPLIQ" ,"C",015,0}) // Impuesto liquidado

	AADD(aStruVc1,{"CAL_FCHCOM" ,"C",008,0}) //Fecha de comprobante
	AADD(aStruVc1,{"CAL_COD"    ,"C",TamSx3("A2_COD")[1],0}) 	
	AADD(aStruVc1,{"CAL_LOJA"   ,"C",TamSx3("A2_LOJA")[1],0})
	AADD(aStruVc1,{"CAL_FILIAL" ,"C",TamSx3("F3_FILIAL")[1],0})

	
		//Creacion de Objeto DETCALQ 
		oTmpTable5 := FWTemporaryTable():New("DETCALQ") 
		oTmpTable5:SetFields( aStruVc1 ) 
	

		aOrdem	:=	{"CAL_PUNVEN","CAL_TIPCOM","CAL_NUMCOM","CAL_FCHCOM","CAL_COD","CAL_LOJA","CAL_FILIAL"} 

	
		oTmpTable5:AddIndex("IN5", aOrdem) 
	
		oTmpTable5:Create() 	
	aAdd(aTabs,{"DETCALQ",cArqVc1})
	
	// RG 3865 Compras Importaciones
	cArqVc1	:= ""
	aStruVc1	:= {}
			
	AADD(aStruVc1,{"IMP_DESPIM" ,"C",016,0}) // Despacho de importacion 
	AADD(aStruVc1,{"IMP_IMPNGR" ,"C",015,0}) // Importe Neto gravado
	AADD(aStruVc1,{"IMP_ALQIVA" ,"C",004,0}) // Alicuota de IVA
	AADD(aStruVc1,{"IMP_IMPLIQ" ,"C",015,0}) // Impuesto liquidado
	AADD(aStruVc1,{"IMP_TIPCOM" ,"C",003,0}) //Tipo de comprobante 
	AADD(aStruVc1,{"IMP_PUNVEN" ,"C",005,0}) //Punto de venta
	AADD(aStruVc1,{"IMP_NUMCOM" ,"C",020,0}) //Numero de comprobante
	
		//Creacion de Objeto DCOMIM 
		oTmpTable6 := FWTemporaryTable():New("DCOMIM") 
		oTmpTable6:SetFields( aStruVc1 ) 
	
		aOrdem	:=	{"IMP_PUNVEN","IMP_TIPCOM","IMP_NUMCOM"} 
	
		oTmpTable6:AddIndex("IN6", aOrdem) 
	
		oTmpTable6:Create() 
	aAdd(aTabs,{"DCOMIM",cArqVc1})
	
	// RG 3865 Credito Fiscal
	cArqVc1	:= ""
	aStruVc1	:= {}
		
	AADD(aStruVc1,{"CFI_TIPCOM" ,"C",001,0}) // Tipo de comprobante
	AADD(aStruVc1,{"CFI_DESCOM" ,"C",020,0}) // Descripcion
	AADD(aStruVc1,{"CFI_IDCOMP" ,"C",020,0}) // Identificacion del comprobante
	AADD(aStruVc1,{"CFI_FCHOPE" ,"C",008,0}) // Fecha de la operacion
	AADD(aStruVc1,{"CFI_MONMOR" ,"C",015,0}) // Monto en moneda original
	AADD(aStruVc1,{"CFI_CODMON" ,"C",003,0}) // Codigo de moneda
	AADD(aStruVc1,{"CFI_TPCAMB" ,"C",010,0}) // Tipo de cambio
	AADD(aStruVc1,{"CFI_CUITPR" ,"C",011,0}) // CUIT del Prestador  
	AADD(aStruVc1,{"CFI_NIFPRE" ,"C",020,0}) // NIF del prestador
	AADD(aStruVc1,{"CFI_NOMBRE" ,"C",030,0}) // Apellido y Nombre /Denominacion del Prestador del Servicio  
	AADD(aStruVc1,{"CFI_ALIQAP" ,"C",004,0}) // Alicuota aplicable
	AADD(aStruVc1,{"CFI_FCHING" ,"C",008,0}) // Fecha de ingreso del impuesto  
	AADD(aStruVc1,{"CFI_MONING" ,"C",015,0}) // Monto impuesto ingresado
	AADD(aStruVc1,{"CFI_IMPCOM" ,"C",015,0}) // Impuesto computable
	AADD(aStruVc1,{"CFI_IDPLCO" ,"C",020,0}) // Identificacion del pago/liquidacion/constancia  
	AADD(aStruVc1,{"CFI_CUITEP" ,"C",011,0}) // CUIT de la entidad de pago
	AADD(aStruVc1,{"CFI_COD"    ,"C",TamSx3("A2_COD")[1],0}) 	
	AADD(aStruVc1,{"CFI_LOJA"   ,"C",TamSx3("A2_LOJA")[1],0})
	AADD(aStruVc1,{"CFI_FILIAL" ,"C",TamSx3("E2_FILIAL")[1],0})
	
		//Creacion de Objeto DIMOFI 
		oTmpTable7 := FWTemporaryTable():New("DIMOFI") 
		oTmpTable7:SetFields( aStruVc1 ) 
	
		aOrdem	:=	{"CFI_FCHOPE","CFI_TIPCOM","CFI_IDCOMP","CFI_COD","CFI_LOJA","CFI_FILIAL"} 
	
		oTmpTable7:AddIndex("IN7", aOrdem) 
	
		oTmpTable7:Create() 		
	aAdd(aTabs,{"DIMOFI",cArqVc1})
Return aTabs

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ConPeso       ³Autor³Luis Enriquez        ³ Data ³ 01/02/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Convierte valor a Peso                                       ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ConPeso(nVal,Mon,nTipCam)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nVal.- Valor de importe a convertir                          ³±±
±±³          ³nMon.- Moneda de origen                                      ³±±
±±³          ³nTipCam.- Moneda destino                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nVal.- Valor de importe en pesos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Funcion LOCARG (SIGAFIS)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ConPeso(nVal,nMon,nTipCam)
	nVal := Round(xMoeda(nVal,nMon ,1,dDataBase,MsDecimais(1)+1,nTipCam),MsDecimais(1))
Return nVal

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FLastDay      ³Autor³Luis Enriquez        ³ Data ³ 01/02/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Obtiene el ultimo dia del mes a partir del periodo en for-   ³±± 
±±³          ³mato MMAAAA                                                  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³FLastDay(cPer))                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPer.- Periodo                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRet.- Valor del ultimo dia del periodo                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Funcion LOCARG (SIGAFIS)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FLastDay(cPer)
	Local cRet := ""
	Local cMes := Substr(cPer,1,2)
	Local cAnio := Substr(cPer,3,4)
	
	If cMes $ "01|03|05|07|08|10|12"
		cRet := "31"
	ElseIf cMes $ "04|06|09|11"
		cRet := "30"
	ElseIf cMes $ "02"
		cRet := "28"
		If Mod(Val(cAnio),4) == 0 .and. Mod(Val(cAnio),400) == 0 .and. Mod(Val(cAnio),100) == 0
			cRet := "29"
		EndIf
	EndIf
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CodProv       ³Autor³Luis Enriquez        ³ Data ³ 01/02/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna codigo de acuerdo a clave de provincia de archivo    ³±± 
±±³          ³generado                                                     ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³CodProv(cProv)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cProv.- Codigo de provincia                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRet.- Codigo correspondiente a provincia                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Funcion LOCARG (SIGAFIS)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CodProv(cProv)
	Local cRet := ""
	
	If cProv == "CF"
		cRet := "01"
	ElseIf cProv == "BA"
		cRet := "02"
	ElseIf cProv == "CA"
		cRet := "03"
	ElseIf cProv == "CO"
		cRet := "04"
	ElseIf cProv == "CR"
		cRet := "05"
	ElseIf cProv == "CH"
		cRet := "06"
	ElseIf cProv == "CB"
		cRet := "07"
	ElseIf cProv == "ER"
		cRet := "08"
	ElseIf cProv == "FO"
		cRet := "09"
	ElseIf cProv == "JU"
		cRet := "10"
	ElseIf cProv == "LP"
		cRet := "11"
	ElseIf cProv == "LR"
		cRet := "12"
	ElseIf cProv == "ME"
		cRet := "13"
	ElseIf cProv == "MI"
		cRet := "14"
	ElseIf cProv == ""
		cRet := "15"
	ElseIf cProv == "RN"
		cRet := "16"
	ElseIf cProv == "SA"
		cRet := "17"
	ElseIf cProv == "SJ"
		cRet := "18"
	ElseIf cProv == "SL"
		cRet := "19"
	ElseIf cProv == "SC"
		cRet := "20"
	ElseIf cProv == "SF"
		cRet := "21"
	ElseIf cProv == ""
		cRet := "22"
	ElseIf cProv == "TF"
		cRet := "23"
	ElseIf cProv == "TU"
		cRet := "24"
	EndIf
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Enc19310       ³Autor³Luis Enriquez       ³ Data ³ 01/02/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Genera encabezado para DGR 193/10 – Chubut (“CB”) - Régimen  ³±± 
±±³          ³de  Retenciones y Percepciones – Percepciones – Aplicativo   ³±±
±±³          ³Web: WAPIB                                                   ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³Enc19310(aCodTab,nOpc,nCant,cEspecie)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aCodTab.- Arreglo de configuraciones generales               ³±±
±±³          ³nOpc.- Valor de opcion 1-Percepciones 2-Retenciones          ³±±
±±³          ³nCant.- Valor contable de libro fiscal/orden de pago         ³±±
±±³          ³cEspecie.- Especie de comprbante                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³No aplica                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Funcion LOCARG (SIGAFIS)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Enc19310(aCodTab,nOpc,nCant,cEspecie)
	Local cValor := ""
	Local cValorL := ""
	Local nValT := 0
 
	If Type("_aTotal") == "A" .and. Type("_aTotal[7]" ) == "U"
		_aTotal[7] := {}
	EndIf
	
	If Len(_aTotal[7]) == 0
		
		cValor := PADL(Alltrim(Str(nCant * 100)),13,"0")
		cValorL := AllTrim(Extenso(nCant,.F.,1,"","2",.T.,.T.,.T.,"3"))
		
		If nOpc == 1
			AADD(_aTotal[7],{Substr(aCodTab[2][2],1,2) + "/" + Substr(aCodTab[2][2],3,4),cValor,cValorL,Transform(SM0->M0_INSC, "@E 999-999999-9" ),Transform(SM0->M0_CGC, "@E 99-99999999-9" ),SM0->M0_NOMECOM,SM0->M0_ENDENT,SM0->M0_CIDENT,SM0->M0_CEPENT,SM0->M0_TEL_PO,"     "})  
		Else
			AADD(_aTotal[7],{Substr(aCodTab[2][2],1,2) + "/" + Substr(aCodTab[2][2],3,4),aCodTab[2][3],cValor,cValorL,Transform(SM0->M0_INSC, "@E 999-999999-9" ),Transform(SM0->M0_CGC, "@E 99-99999999-9" ),SM0->M0_NOMECOM,SM0->M0_ENDENT,SM0->M0_CIDENT,SM0->M0_CEPENT,SM0->M0_TEL_PO,"         "})
		EndIf
	Else
		If AllTrim(cEspecie) $ "NCC|NDI"
			nValT := (Val(Iif(nOpc == 1,_aTotal[7][1][2],_aTotal[7][1][3])) / 100) - nCant
		Else
			nValT := (Val(Iif(nOpc == 1,_aTotal[7][1][2],_aTotal[7][1][3])) / 100) + nCant
		EndIf
		cValor := PADL(Alltrim(Str(nValT * 100)),13,"0")
		cValorL := AllTrim(Extenso(nValT,.F.,1,"","2",.T.,.T.,.T.,"3"))
		If nOpc == 1
			_aTotal[7][1][2] := cValor
			_aTotal[7][1][3] := cValorL
		Else
			_aTotal[7][1][3] := cValor
			_aTotal[7][1][4] := cValorL
		EndIf
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³BuscaSFH      ³Autor³Luis Enriquez        ³ Data ³ 22/02/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Obtiene código de clasificación.                             ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³BuscaSFH(cCliFor, cLoja,cImpuesto,nOrden,lImp)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCliFor.- Codigo de cliente/proveedor                        ³±±
±±³          ³cLoja.- Codigo de tienda de cliente/proveedor                ³±±
±±³          ³cImpuesto.- Codigo de impuesto variable                      ³±±
±±³          ³nOrden.- Codigo de indice para busqueda en SFH               ³±±
±±³          ³lImp.- Valor logico                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cCond.- Código de clasificacion                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Funcion LOCARG (SIGAFIS)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BuscaSFH(cCliFor, cLoja,cImpuesto,nOrden,lImp)
	Local cCond := "3"
	Local aAreaSFH := SFH->(GetArea())
	Default lImp := .T.

	DbSelectArea("SFH")//TABELA INGRESSOS BRUTOS
	SFH->(DbSetOrder(nOrden))//FH_FILIAL+FH_FORNECE+FH_LOJA+FH_IMPOSTO+FH_ZONFIS
	SFH->(DbGoTop())
	If SFH->(MsSeek(xFilial("SFH")+cCliFor+cLoja+cImpuesto+"SF"))
		lImp:=.F.
		Do While SFH->(!Eof()) .And. Iif(nOrden == 1,SFH->FH_FORNECE==cCliFor,SFH->FH_CLIENTE==cCliFor) .And. SFH->FH_LOJA==cLoja  
			If SFH->FH_IMPOSTO==cImpuesto .And. SFH->FH_ZONFIS=="SF" .and. VigSFH()
				If SFH->FH_TIPO=="I" .or. SFH->FH_TIPO=="V"
					cCond := "1"
					Exit
				EndIf
			EndIf
			SFH->(DbSkip())
		EndDo
	EndIf
	RestArea(aAreaSFH) 
Return cCond

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VigSFH        ³Autor³Luis Enriquez        ³ Data ³ 23/02/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica vigencia de impuesto en Empresa vs Zona Fical       ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³VigSFH()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³No aplica                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet.- Valor logico que indica si el impuesto se encuentra   ³±±
±±³          ³vigente en Empresa vs Zona Fiscal                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Funcion LOCARG (SIGAFIS)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VigSFH()
	Local lRet := .F.
	Local dData := dDataBase
	
	If dData >= SFH->FH_INIVIGE
		lRet := .T.
	EndIf
	
	If lRet .And. !Empty( SFH->FH_FIMVIGE )
		lRet := ( dData <= SFH->FH_FIMVIGE )
	EndIf
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LocArgCS      ³Autor³Luis Enriquez        ³ Data ³ 07/03/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Generacion de archivos consolidados o por sucursal, depen-   ³±± 
±±³          ³diendo de como se haya configurado (SICORE)                  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³LocArgCS(cArquivo,cDtIni,cDtFim,aCodTab,lConfirm,            ³±±
±±³          ³aArTmp,nCons)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cArquivo.- Instruc. Normativa de archivos magneticos         ³±±
±±³          ³cDtIni.- Fecha Inicial                                       ³±±
±±³          ³cDtFim.- Fecha Final                                         ³±±
±±³          ³aCodTab.- Arreglo de configuraciones generales               ³±±
±±³          ³lConfirm.- Valor logico para control de consolidacion        ³±±
±±³          ³aArTmp.- Arreglo de archivos temporales                      ³±±
±±³          ³nCons.- Posicion de valor para tabla de equivalencia         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aCpyRel.- Arreglo con cantidad de registros consolidados     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Funcion LOCARG (SIGAFIS)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LocArgCS(cArquivo,cDtIni,cDtFim,aCodTab,lConfirm,aArTmp,nCons)
	Local nProcFil	:= 0
	Local cBkpFil	:= ""
	Local cSuc		:= ""
	Local aTabs   	:= {}
	Local aRel		:= {}
	Local nPos		:= 0
	Local nCanReg	:= 0  
	Local lEsCons   := .F.  //(.T. - Consolidado / .F. - No Consolidado)     
	Local aCpyRel   := {}  
	Local nLoop     := 0
	
	Default aCodTab :={}
	Default lConfirm:= .T.
	Default aArTmp  := {}   
	Default nCons   := 1
	
	cSuc   := Iif(!Empty(aCodTab),Substr(aCodTab[1][nCons],1,1),"") 	
	cBkpFil:= cFilAnt
	
	If  cSuc== "1" //Significa que sera consolidado y que hubo seleccion de Sucursales 
		//Cambiar logico para que NO continue procesando filiales   
		For nProcFil:=1 to len(aFilsCalc)
			If  aFilsCalc[nProcFil,1] == .T.
				cFilAnt := aFilsCalc[nProcFil,2] // Se forza la variable cFilAnt 
				aRel  := {}
				aRel  := LocArg(cArquivo,cDtIni,cDtFim,aCodTab,lConfirm,aArTmp,lEsCons)
				aFilsCalc[nProcFil,1]:=.F.      // Marcar como procesada
				lEsCons := .T.  //Solo generar 1 vez las tablas temporales  
				If  !Empty(aRel)  
					nPos:= Ascan(aRel,STR0025)
					If  nPos <> 0
						nCanReg += Val(Substr(aRel[nPos],Len(STR0025)+1))
					EndIf 		
					For nLoop:=1 to len(aRel)    
						If  nPos != nLoop
							Aadd(aCpyRel,aRel[nLoop])  
						EndIf
					Next nLoop 
				EndIf
			EndIf
		Next nProcFil 
	Else 
		aCpyRel := LocArg(cArquivo,cDtIni,cDtFim,aCodTab,lConfirm,aArTmp,lEsCons)
	EndIf 
	
	If  lEsCons   //Fue consolidado   
		Aadd(aCpyRel,STR0025 + Alltrim(Str(nCanReg))) //Se agrega el total general-
	EndIf
	
	cFilAnt := cBkpFil // Restaura Sucursal
Return aCpyRel

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ValidSFH      ³Autor³Luis Enriquez        ³ Data ³ 09/02/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida vigencia de impuesto en Empresa vs Zona Fiscal        ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ValidSFH(cProv,cLoja,cImposto,cZona,nInd,aCampos)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cProv.- Codigo de proveedor                                  ³±±
±±³          ³cLoja.- Tienda de proveedor                                  ³±±
±±³          ³cImposto.- Clave de impuesto variable                        ³±±
±±³          ³cZona.- Clave de Zona Fiscal                                 ³±±
±±³          ³nInd.- Numero de indice para busqueda en tabla SFH           ³±±
±±³          ³aCampos.- Arreglo de campos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cFchPRet.- Fecha de emision (FE_EMISSAO) de registro de re-  ³±±
±±³          ³tenciones (SFE).                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Funcion LOCARG (SIGAFIS)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ValidSFH(cProv,cLoja,cImposto,cZona,nInd,aCampos)
	Local aArea      := GetArea()
	Local aAreaSFH   := SFH->(GetArea())
	Local lExist     := .T.
	Local aReg  		:= {}
	Local i := 0
	 	
	SFH->(DbSetOrder(nInd)) //1. FH_FILIAL+FH_FORNECE+FH_LOJA+FH_IMPOSTO+FH_ZONFIS
	If SFH->(DbSeek(xFilial()+cProv + cLoja + cImposto + cZona))
		While !SFH->(EOF()) .and. (xFilial("SFH")+cProv + cLoja + cImposto + cZona == SFH->FH_FILIAL + SFH->FH_FORNECE + SFH->FH_LOJA + SFH->FH_IMPOSTO + SFH->FH_ZONFIS)
			If VigSFH()
				aAdd(aReg,.T.)
				For i := 1 to Len(aCampos)
					aAdd(aReg,SFH->&(aCampos[i]))
				Next i
				Exit
			EndIf
			SFH->(DbSkip())
		EndDo 
	Else
		AADD(aReg,.F.)
	EndIf 
	
	RestArea(aAreaSFH)
	RestArea(aArea)
Return aReg
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ObtRFchIni    ³Autor³Luis Enriquez        ³ Data ³ 27/03/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Función para obtener la primera fecha de retención del       ³±± 
±±³          ³impuesto Municipal.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ObtRFchIni(cProv,cLojaP)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cProv.- Codigo de proveedor                                  ³±±
±±³          ³cLojaP.- Tienda de proveedor                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cFchPRet.- Fecha de emision (FE_EMISSAO) de registro de re-  ³±±
±±³          ³tenciones (SFE).                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Funcion LOCARG (SIGAFIS)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ObtRFchIni(cProv,cLojaP)    
	Local cFchPRet  := ""
	Local cQrySFE   := ""
	Local cAliasSFE := CriaTrab(nil,.F.)
								
	cQrySFE:= " SELECT FE_EMISSAO"
	cQrySFE+= " FROM "+RetsqlName("SFE")+" SFE "    
	cQrySFE+= " 	WHERE FE_FILIAL = '"+xFilial("SFE")+"' "
	cQrySFE+= " 	AND   SFE.D_E_L_E_T_ ='' "      
	cQrySFE+=" 		AND   FE_FORNECE = '"+cProv+"' "
	cQrySFE+=" 		AND   FE_LOJA    = '"+cLojaP+"' "
	cQrySFE+=" 		AND FE_TIPO = 'M' " //M=Municipal 
	cQrySFE+=" 		AND FE_EST  = 'CO' "
	cQrySFE+=" ORDER BY FE_EMISSAO "  
	
	cQrySFE := ChangeQuery(cQrySFE)
	dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQrySFE ),cAliasSFE,.F.,.T.)
				
	DbSelectArea(cAliasSFE)
	(cAliasSFE)->(dbGoTop())
	If (cAliasSFE)->(!Eof())
		Do While (cAliasSFE)->(!Eof()) 
			cFchPRet :=(cAliasSFE)->FE_EMISSAO	  
			Exit				
			(cAliasSFE)->(DbSkip())
		EndDo
	EndIf
	
	(cAliasSFE)->(dbCloseArea())
Return(cFchPRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ObtPFchIni    ³Autor³Luis Enriquez        ³ Data ³ 24/03/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Función para obtener la primera fecha de Percepcion del      ³±± 
±±³          ³impuesto Municipal.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ObtPFchIni(cCliPro,cLojaP,aNrLvrMn)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCliPro.- Codigo de cliente/proveedor                        ³±±
±±³          ³cLojaP.- Tienda de cliente/proveedor                         ³±±
±±³          ³aNrLvrMn.- Arreglo con impuestos de tipo M-Municipales,      ³±±
±±³          ³Clase P-Percepcion y Clasificacion 5-Municipales.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cFchPRet.- Fecha de emision (F3_EMISSAO) de registro de li-  ³±±
±±³          ³bros fiscales.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Funcion LOCARG (SIGAFIS)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ObtPFchIni(cCliPro,cLojaP,aNrLvrMn)    
	Local cFchPPer  := ""
	Local cQrySF3   := ""
	Local cAliasSF3 := CriaTrab(nil,.F.)
	Local nlI := 0
									
	cQrySF3:= " SELECT F3_EMISSAO"
	cQrySF3+= " FROM "+RetsqlName("SF3")+" SF3 "    
	cQrySF3+= " 	WHERE F3_FILIAL = '"+xFilial("SF3")+"' "
	cQrySF3+= " 	AND   SF3.D_E_L_E_T_ ='' "      
	cQrySF3+=" 		AND   F3_CLIEFOR = '"+cCliPro+"' "
	cQrySF3+=" 		AND   F3_LOJA    = '"+cLojaP+"' "
	cQrySF3+=" 		AND F3_ESTADO  = 'CO' "
	If Len(aNrLvrMn) > 0 
		cQrySF3 += " AND ("
		For nlI:=1 To Len(aNrLvrMn)
			If nlI <> 1
				cQrySF3 += " OR "
			EndIf
			cQrySF3 += " F3_VALIMP"+aNrLvrMn[nlI][2]+" > 0 "
		Next nlI
		cQrySF3 += ")"
	EndIf
	
	cQrySF3+=" ORDER BY F3_EMISSAO "  
	
	cQrySF3 := ChangeQuery(cQrySF3)
	dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQrySF3 ),cAliasSF3,.F.,.T.)
				
	DbSelectArea(cAliasSF3)
	(cAliasSF3)->(dbGoTop())
	If (cAliasSF3)->(!Eof())
		cFchPPer :=(cAliasSF3)->F3_EMISSAO					
	EndIf
	
	(cAliasSF3)->(dbCloseArea())
Return(cFchPPer)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetComp       ³Autor³Luis Enriquez        ³ Data ³ 24/03/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Función para obtener el numero de comprobate o si no existe  ³±± 
±±³          ³ se debe asignar.                                            ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³GetComp(cAlias,cSeek)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias.- Alias de tabla en encabezado de factura (SF1/SF2)   ³±±
±±³          ³cSeek.- Datos para busqueda en tabla de alias por:           ³±±
±±³          ³No. Fiscal, Serie, Cliente/Proveedor y Tienda.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cCompr.- Numero de comprobante.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Funcion LOCARG (SIGAFIS)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GetComp(cAlias, cSeek)
	Local cCompr:= ""
	Local cPunt := Substr(cAlias,2,2) 
	Local cParComp := ""
	
	DbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(1))
	(cAlias)->(dbGoTop())
	If  (cAlias)->(DbSeek(xFilial(cAlias)+cSeek))     
	
		If AllTrim((cAlias)->&(cPunt+"_5314CO")) <> ""
			cCompr := AllTrim((cAlias)->&(cPunt+"_5314CO"))
		Else                
			cCompr := GETMV("MV_5314CO")    
		 			
			If AllTrim(cCompr) == ""
				cCompr := "000001"
			EndIf             	
			//Actualizar F1/F1_5314CO
			RecLock(cAlias, .F.)
			(cAlias)->&(cPunt+"_5314CO") := AllTrim(cCompr)
			(cAlias)->(MsUnLock())

			cParComp := StrZero(Val(cCompr) + 1,6)
			PutMV("MV_5314CO", cParComp) 			 
		EndIf
	EndIf
	
	(cAlias)->(dbCloseArea())    
Return cCompr

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ObtBASIMP     ³Autor³Luis Enriquez        ³ Data ³ 31/03/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Obtiene valor de impuesto base acumulado.                    ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ObtBASIMP(cpCliFor, cpLoja, cpNFolFis, cpSerie, cPos,        ³±±
±±³          ³npAlqImp)                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cpCliFor.- Codigo de cliente/proveedor                       ³±±
±±³          ³cpLoja.- Tienda de cliente/proveedor                         ³±±
±±³          ³cpNFolFis.- Numero de factura                                ³±±
±±³          ³cpSerie.- Serie de factura                                   ³±±
±±³          ³cPos.- Numero de libro fiscal en impuesto variable IVA       ³±±
±±³          ³npAlqImp.- Aliquota de impuesto variable                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nValImpG.- Importa acumulado de base de impuesto             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Funcion LOCARG (SIGAFIS)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ObtBASIMP(cpCliFor, cpLoja, cpNFolFis, cpSerie, cPos, npAlqImp)
	Local nValImpG := 0
	Local aAreaTmp := getArea()
	Local cQryImpGra := ""
	Local cIMPGRA := ""
	
	cQryImpGra := "SELECT F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, SUM(F3_BASIMP" + Alltrim(cPos) + ") IMPGRAV "
	cQryImpGra += "FROM " + RetsqlName("SF3")+ " SF3 "
	cQryImpGra += "WHERE (F3_NFISCAL = '" + cpNFolFis + "') AND (F3_SERIE = '" + cpSerie + "') AND (F3_LOJA = '" + cpLoja + "') AND (F3_CLIEFOR = '" + cpCliFor + "') AND (F3_ALQIMP" + Alltrim(cPos) + " = " + Str(npAlqImp) + ") AND D_E_L_E_T_ <> '*'"
	cQryImpGra += "GROUP BY F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA"
	
	If Select("TMPIG")>0
		DbSelectArea("TMPIG")
		TMPIG->(DbCloseArea())
	EndIf

	cIMPGRA := ChangeQuery(cQryImpGra)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cIMPGRA ) ,"TMPIG", .T., .F.)
	
	DbSelectArea("TMPIG")
	TMPIG->(dbGoTop())
	
	If TMPIG->(!Eof())
		While TMPIG->(!Eof())
			nValImpG := IMPGRAV
			TMPIG->(dbSkip())
		EndDo
	EndIf 	
	RestArea(aAreaTmp)	
Return nValImpG

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LlenaTab     ³Autor³Luis Enriquez        ³ Data ³ 04/04/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Llena tabla temporal IT para archivos magneticos de La Pampa.³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³LlenaTab(cAliasF, aArrayTab, aArray)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasF.- Alias de tabla tempora (TI)                        ³±±
±±³          ³aArrayTab.- Arreglo de campos de tabla temporal (TI)         ³±±
±±³          ³aArray.- Arreglo de  valores para llenado de tabla temporal  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³No aplica                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Funcion LOCARG (SIGAFIS)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LlenaTab(cAliasF, aArrayTab, aArray)
	Local nX := 0
	Local nY := 0
	
	For nX := 1 To Len(aArray)
		If RecLock(cAliasF,.T.)
			For nY := 1 To Len(aArrayTab)
				(cAliasF)->&(aArrayTab[nY]) := aArray[nX][nY]
			Next 
			MsUnlock()
		EndIf
	Next
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PadCP         ³Autor³Luis Enriquez        ³ Data ³ 07/04/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carga tabla padrón de clientes/proveedores                   ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³PadCP(cCuit,cProv,nTipo,cCodigo,nLoja,cPeriod,cImp,cArquivo) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCuit.- CUIT de cliente/proveedor                            ³±±
±±³          ³cProv.- Código de provincia                                  ³±±
±±³          ³nTipo.- Valor de opcion 1-Cliente 2-Proveedor                ³±±
±±³          ³cCodigo.- Valor clave de cliente/proeveedor                  ³±±
±±³          ³nLoja.- Valor de tienda de cliente/proveedor                 ³±±
±±³          ³cPeriod.- Valor de fecha                                     ³±±
±±³          ³cImp.- Valor clave  de impuesto                              ³±±
±±³          ³cArquivo.- Valor de archivo que se esta generando            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³No aplica                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Funcion LOCARG (SIGAFIS)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PadCP(cCuit,cProv,nTipo,cCodigo,nLoja,cPeriod,cImp,cArquivo)
	Local cCodJur :=""
	Local lExiste := .F.
	Local cSitua := ""
	Local nEsCon := ""
	Local cConv := ""
	Default cArquivo = "DGR55-11"
	           
	DbSelectArea("CCO")
	CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
	CCP->(DbGoTop())
	If DbSeek(xFilial("CCO")+cProv) 
		cCodJur := CCO->CCO_CODJUR
	Else
		cCodJur := ""
	EndIf
	
	If nTipo == 1
		DbSelectArea("SFH")
		SFH->(DbSetOrder(3)) //FH_FILIAL + FH_CLIENTE + FH_LOJA + FH_IMPOSTO + FH_ZONFIS
		If SFH->(DbSeek(xFilial("SFH") + cCodigo + nLoja + cImp + cProv)) 
			If (STOD(cPeriod) < SFH->FH_INIVIGE .or. STOD(cPeriod) > SFH->FH_FIMVIGE ) .Or. SFH->FH_TIPO <> "I"			
				cSitua = "02"
			Else 
				cSitua := "00"
			EndIf 
			
			If AllTrim(SFH->FH_TIPO) == "V"
				nEsCon := "1"	
			Else
				nEsCon := "0"
			EndIf
		Else 
			cSitua = "02"
			nEsCon := "0"
		EndIf
		
		DbSelectArea("SA1")
		SA1->(DbSetOrder(3))
		If SA1->(DbSeek(xFilial("SA1")+cCuit))
			lExiste := .T.	
		EndIf
	ElseIf nTipo == 2
		DbSelectArea("SFH")
		SFH->(DbSetOrder(1)) //FH_FILIAL + FH_FORNECE + FH_LOJA + FH_IMPOSTO + FH_ZONFIS 
		If SFH->(DbSeek(xFilial("SFH") + cCodigo + nLoja + cImp + cProv)) 
			If (STOD(cPeriod) < SFH->FH_INIVIGE .or. STOD(cPeriod) > SFH->FH_FIMVIGE ) .Or. SFH->FH_TIPO <> "I"
				cSitua = "02"
			Else 
				cSitua := "00"
			EndIf 
			
			If AllTrim(SFH->FH_TIPO) == "V"
				nEsCon := "1"	
			Else
				nEsCon := "0"
			EndIf
		Else 
			cSitua = "02"
			nEsCon := "0"
		EndIf
		
		DbSelectArea("SA2")
		SA2->(DbSetOrder(3))
		If SA2->(DbSeek(xFilial("SA2")+cCuit))
			lExiste := .T.	
		EndIf
	EndIf
	
	If lExiste
		DbSelectArea("DGPADCP")
			DGPADCP->(dbSetOrder(1))
			DGPADCP->(dbGoTop())
		If DGPADCP->(!DbSeek(Substr(cCuit,1,11)+cSitua+nEsCon))
			cConv := Iif(nTipo==1,SA1->A1_NROIB,SA2->A2_NROIB)
			RecLock("DGPADCP",.T.) 
			DGPADCP->DGP_RAZSOC	:= Iif(nTipo==1,SA1->A1_NOME,SA2->A2_NOME)
			DGPADCP->DGP_CUIT	:= cCuit
			DGPADCP->DGP_SITUIB	:= cSitua
			DGPADCP->DGP_ESCONV	:= nEsCon                                                     
			DGPADCP->DGP_NROCON	:= cConv
			DGPADCP->DGP_CODPRO	:= cCodJur
			DGPADCP->DGP_LOCALI	:= Iif(AllTrim(cConv) <> "", "",Iif(nTipo==1,SA1->A1_MUN,SA2->A2_MUN))
			DGPADCP->DGP_BARRIO	:= Iif(AllTrim(cConv) <> "", "",Iif(nTipo==1,SA1->A1_BAIRRO,SA2->A2_BAIRRO))
			DGPADCP->DGP_CALLE	:= Iif(AllTrim(cConv) <> "", "",Iif(nTipo==1,SA1->A1_END,SA2->A2_END))
			DGPADCP->DGP_NUMERO	:= ""
			DGPADCP->DGP_SECTOR	:= ""
			DGPADCP->DGP_TORRE	:= ""
			DGPADCP->DGP_PISO	:= ""
			DGPADCP->DGP_CODPOS	:= Iif(AllTrim(cConv) <> "", "",Iif(nTipo==1,SA1->A1_CEP,SA2->A2_CEP))
			DGPADCP->DGP_DEPTO	:= ""

			If UPPER(cArquivo)$"STAC-AR"
				DGPADCP->DGP_LOCALI	:= Iif(AllTrim(cSitua) == "00", "",Iif(nTipo==1,SA1->A1_MUN,SA2->A2_MUN))
				DGPADCP->DGP_BARRIO	:= Iif(AllTrim(cSitua) == "00", "",Iif(nTipo==1,SA1->A1_BAIRRO,SA2->A2_BAIRRO))
				DGPADCP->DGP_CALLE	:= Iif(AllTrim(cSitua) == "00", "",Iif(nTipo==1,SA1->A1_END,SA2->A2_END))
				DGPADCP->DGP_CODPOS	:= Iif(AllTrim(cSitua) == "00", "",Iif(nTipo==1,SA1->A1_CEP,SA2->A2_CEP))
			EndIf 			
		EndIf
		DGPADCP->(MsUnlock())	
	EndIf	
Return



/*/{Protheus.doc} fVldRemDev
Valida si existe un remito de Devolucion y obtiene el número de remito de venta original.

@Type    Function
@Author  Luis Arturo Samaniego Guzmán
@Since   08/02/2018
@Version P11.80
@Param   cTipoDocu: Caracter, tipo de documento.
@Return  aNFOrig: Array, contiene punto de venta y número de factura. 
/*/
Function fVldRemDev(cTipoDocu)
    Local aAreaTmp := getArea()
    Local cQrySD := ""
    Local cTempSD := GetNextAlias()
    Local aNFOrig := {}
        
        If !("NCC" == Alltrim(cTipoDocu))
            Return aNFOrig
        EndIf
        
        cQrySD := " SELECT D1_FILIAL, D1_COD, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_REMITO, D1_SERIREM, D1_NFORI, D1_SERIORI"
        cQrySD += " FROM " + RetsqlName("SD1")
        cQrySD += " WHERE ( D1_FILIAL = '" + xFilial("SD1") + "') AND "
        cQrySD += " ( D1_COD = '" + SD1->D1_COD + "') AND "
        cQrySD += " ( D1_DOC = '" + SD1->D1_REMITO + "') AND "
        cQrySD += " ( D1_SERIE = '" + SD1->D1_SERIREM + "') AND "
        cQrySD += " ( D1_FORNECE = '" + SD1->D1_FORNECE + "') AND "
        cQrySD += " ( D1_LOJA = '" + SD1->D1_LOJA + "') AND "
        cQrySD += " D_E_L_E_T_ <> '*'"
        
        If Select(cTempSD)>0
            DbSelectArea(cTempSD)
            (cTempSD)->(DbCloseArea())
        Endif
    
        cQrySD := ChangeQuery(cQrySD)
        dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQrySD ) , cTempSD, .T., .F.)
        DbSelectArea(cTempSD)
        (cTempSD)->(dbGoTop())
        
        If (cTempSD)->(!Eof())
            aNFOrig := fVldFacVen((cTempSD)->D1_NFORI, (cTempSD)->D1_SERIORI, (cTempSD)->D1_FORNECE, (cTempSD)->D1_LOJA, (cTempSD)->D1_COD)
        EndIf
        
        (cTempSD)->(dbCloseArea())
        RestArea(aAreaTmp)
Return aNFOrig

/*/{Protheus.doc} fVldFacVen
Valida si existe factura de venta ligada al remito de venta original.

@Type    Function
@Author  Luis Arturo Samaniego Guzmán
@Since   08/02/2018
@Version P11.80
@Param   cSdNfori: Número de documento original.
@Param   cSdSeriOri: Serie de documento original.
@Param   cSdFornece: Código de cliente/proveedor.
@Param   cSdLoja: Sucursal del cliente/proveedor.
@Param   cSdCod: Código de producto.
@Return  aNFOrig: Array, contiene punto de venta y número de factura. 
/*/
Static Function fVldFacVen(cSdNfori, cSdSeriOri, cSdFornece, cSdLoja, cSdCod)//Si existe el Remito de venta
    Local aAreaTmp := getArea()
    Local cQrySD   := ""
    Local cTempSD  := GetNextAlias()
    Local aNFOrig := {}
            
        cQrySD := " SELECT D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, D2_NFORI, D2_SERIORI"
        cQrySD += " FROM " + RetsqlName("SD2")
        cQrySD += " WHERE ( D2_FILIAL = '" + xFilial("SD2") + "') AND "
        cQrySD += " ( D2_REMITO = '" + cSdNfori + "') AND "
        cQrySD += " ( D2_SERIREM = '" + cSdSeriOri + "') AND "
        cQrySD += " ( D2_CLIENTE = '" + cSdFornece + "') AND "
        cQrySD += " ( D2_LOJA = '" + cSdLoja + "') AND "
        cQrySD += " ( D2_COD = '" + cSdCod + "') AND "
        cQrySD += " D_E_L_E_T_ <> '*'"
        
        If Select(cTempSD)>0
            DbSelectArea(cTempSD)
            (cTempSD)->(DbCloseArea())
        Endif
    
        cQrySD := ChangeQuery(cQrySD)
        dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQrySD ) , cTempSD, .T., .F.)
        DbSelectArea(cTempSD)
        (cTempSD)->(dbGoTop())
        
        If (cTempSD)->(!Eof())
            aAdd(aNFOrig, IIf(!EMPTY((cTempSD)->D2_DOC) , Substr((cTempSD)->D2_DOC,1,4), ""))
            aAdd(aNFOrig, IIf(!EMPTY((cTempSD)->D2_DOC), Replicate("0",8-Len(AllTrim(Substr((cTempSD)->D2_DOC,5,TamSX3("D2_DOC")[1]-4)))) + Substr((cTempSD)->D2_DOC,5,TamSX3("D2_DOC")[1]-4), ""))
        EndIf
        
        (cTempSD)->(dbCloseArea())
        RestArea(aAreaTmp)
Return aNFOrig
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Loc3865       ³Autor ³ Emanuel Villicaña    ³Data³ 25/05/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³ Funcion encargada de administrar las sucursales o no       ³±±
±±º          ³ dependiendo si se selecciona consolidado o no.             ³±±
±±º          ³ Argentina.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocIVAPER(cDtIni,cDtFim,aCodTab,lEsCons)
	Local nProcFil	:= 0
	Local cBkpFil		:= ""
	Local aTabs   	:= {}
	Local aRel			:= {}
	Local nPos			:= 0
	Local nCanReg		:= 0
	
	cBkpFil:= cFilAnt
	aTabs	:= LocTrbs("IVAPER",@aTabs,lEsCons) // Cursores temporales y nombres fisicos de los archivos.
	
	If  lEsCons //Significa que sera consolidado y que hubo seleccion de Sucursales
		//Cambiar logico para que NO continue procesando filiales   
		For nProcFil:=1 to len(aFilsCalc)
			If aFilsCalc[nProcFil,1] == .T.
				cFilAnt := aFilsCalc[nProcFil,2] // cFilAnt es la variable global que indica en que sucursal estamos trabajando
				aRel := LocArg("IVAPER",cDtIni,cDtFim,aCodTab,,,lEsCons)
				aFilsCalc[nProcFil,1]:=.F.

				nPos:= Ascan(aRel,STR0025)
				If nPos <> 0
					nCanReg += Val(Substr(aRel[nPos],Len(STR0025)+1))
					aRel[nPos] := STR0025 + Alltrim(Str(nCanReg))	
				EndIf 
			EndIf
		Next nProcFil 
	Else 
		aRel := LocArg("IVAPER",cDtIni,cDtFim,aCodTab,,,lEsCons)
	EndIf 

	
	cFilAnt := cBkpFil // Restaura Sucursal que se estaba utilizando
	
	LogArqTRep("IVAPER",aRel)
Return aTabs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LocRentax       ³Autor ³ Danilo Santos      ³Data³ 31/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³ Funcion encargada de administrar las sucursales o no       ³±±
±±º          ³ dependiendo si se selecciona consolidado o no.             ³±±
±±º          ³ Argentina.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocRentax(cDtIni,cDtFim,aCodTab,lEsCons)
	
Local nProcFil	:= 0
Local cBkpFil		:= ""
Local aTabs   	:= {}
Local aRel			:= {}
Local nPos			:= 0
Local nCanReg		:= 0
	
cBkpFil:= cFilAnt
aTabs	:= LocTrbs("RENTAX",@aTabs,lEsCons) // Cursores temporales y nombres fisicos de los archivos.

If lAglfil	 //Significa que sera consolidado y que hubo seleccion de Sucursales, Cambiar logico para que NO continue procesando filiales 
	For nProcFil:=1 to len(aFilsCalc)		 
		If aFilsCalc[nProcFil,1] == .T.
			cFilAnt := aFilsCalc[nProcFil,2] // cFilAnt es la variable global que indica en que sucursal estamos trabajando
			aRel := LocArg("RENTAX",cDtIni,cDtFim,aCodTab,,,lEsCons)
			aFilsCalc[nProcFil,1]:=.F.
		Endif
	Next nProcFil			
Else 
	aRel := LocArg("RENTAX",cDtIni,cDtFim,aCodTab,,,lEsCons)
EndIf 

cFilAnt := cBkpFil // Restaura Sucursal que se estaba utilizando 
	
LogArqTRep("RENTAX",aRel)

Return aTabs
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LocArq       ³Autor ³ Alexander Leite       ³Data³ 31/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³ Funcion encargada de administrar las sucursales o no       ³±±
±±º          ³ dependiendo si se selecciona consolidado o no.             ³±±
±±º          ³ Argentina.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocArq(cDtIni,cDtFim,aCodTab,lEsCons,cArq)
Local nProcFil	:= 0
Local nPos := 0
Local nCanReg := 0
Local nPos			:= 0
Local nCanReg		:= 0
Local nX 			:= 0
Local cBkpFil		:= ""
Local cArqTrab := ""
Local aTabs   	:= {}
Local aRel			:= {}
Local nNumFil := 0


Default cDtIni := CTOD("  /  /    ")
Default cDtFim := CTOD("  /  /    ")
Default aCodTab := {}
Default lEsCons := .F.
Default cArq := ""
	

cBkpFil:= cFilAnt
If ALLTRIM(cArq) <> "PER_IBBA"
	aTabs	:= LocTrbs(cArq,@aTabs,lEsCons) // Cursores temporales y nombres fisicos de los archivos.
Endif

If  UPPER(cArq)$"SIRCAR|IVARET"
	If  !lAglfil	 //Significa que sera consolidado y que hubo seleccion de Sucursales, Cambiar logico para que NO continue procesando filiales
		aRel := LocArg(cArq,cDtIni,cDtFim,aCodTab,,,lEsCons)				
	ElseIf  lAglfil 
		For nProcFil:=1 to len(aFilsCalc)		 
			If aFilsCalc[nProcFil,1] == .T.
				cFilAnt := aFilsCalc[nProcFil,2] // cFilAnt es la variable global que indica en que sucursal estamos trabajando
				aRel := LocArg(cArq,cDtIni,cDtFim,aCodTab,,,lEsCons)
				For nNumFil:=1 to len(aFilsCalc)
					aFilsCalc[nNumFil,1] := .F.
				Next nNumFil		
			Endif		
		Next nProcFil	
	Endif
ElseIf ALLTRIM(cArq) <> "SIRCAR" .And.  lAglfil	 //Significa que sera consolidado y que hubo seleccion de Sucursales, Cambiar logico para que NO continue procesando filiales 
	For nProcFil:=1 to len(aFilsCalc)		 
		If aFilsCalc[nProcFil,1] == .T.
			cFilAnt := aFilsCalc[nProcFil,2] // cFilAnt es la variable global que indica en que sucursal estamos trabajando
			If ALLTRIM(cArq) <> "PER_IBBA"
				aRel := LocArg(cArq,cDtIni,cDtFim,aCodTab,,,lEsCons)
			Else
				cArqTrab := P_IBBA() // Llamada dela función del MatxMag() para generación del archivo de percepcibón ibba 
			Endif
			aFilsCalc[nProcFil,1]:=.F.
		Endif
	Next nProcFil				
ElseIf ALLTRIM(cArq) <> "PER_IBBA"
	aRel := LocArg(cArq,cDtIni,cDtFim,aCodTab,,,lEsCons)//llamada para archivos no aglutinados
Else
	cArqTrab := P_IBBA() // llamada para archivos no aglutinados
EndIf 

cFilAnt := cBkpFil // Restaura Sucursal que se estaba utilizando

If ALLTRIM(cArq) <> "PER_IBBA"
	LogArqTRep(cArq,aRel)
	Return aTabs
Else
	Return(cArqTrab)
Endif


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LocTpOp       ³Autor ³ Danilo Santos        ³Data³ 25/06/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³ Funcion encargada de retornar o tipo de operação           ³±±
±±º          ³ para a provincia de Missiones Argentina                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocTpOp(cForneC,cLojaFor,cEstFor,dEmissRet)

Local cTpop	  := ""
Local cQryTpOp  := ""
Local cAliasSFH := "SFH"
Local cTBTPOP := ""
Local nRecSFH := 0

Default cForneC  := ""
Default cLojaFor := ""
Default cEstFor := ""
Default dEmissRet := ""

cQryTpOp := "SELECT * FROM " + RetsqlName("SFH") + " SFH " 
cQryTpOp += " WHERE " 
cQryTpOp += " FH_FILIAL = '" +xFilial("SFH")+ "' AND "
cQryTpOp += " FH_ZONFIS = '" + cEstFor + "' AND " 
cQryTpOp += " FH_FORNECE = '" + cForneC + "' AND "
cQryTpOp += " FH_LOJA = '" + cLojaFor + "' AND "  
cQryTpOp += " FH_IMPOSTO = 'IBR' AND "
cQryTpOp += " D_E_L_E_T_ = ''"

cTBTPOP := ChangeQuery(cQryTpOp)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTBTPOP ) ,"cTBTPOP", .T., .F.)
			
DbSelectArea("cTBTPOP")

If cTBTPOP->(!Eof())
	Do While cTBTPOP->(!Eof()) 				
		If ! (Substr(cTBTPOP->FH_FIMVIGE,1,4) >= Substr(dEmissRet,1,4))
			cTBTPOP->(DbSkip())
			Loop
		EndIf
		If (Substr(cTBTPOP->FH_INIVIGE,1,4) + Substr(cTBTPOP->FH_INIVIGE,5,2) <= Substr(dEmissRet,1,4) + Substr(dEmissRet,5,2)) .And. ((Substr(cTBTPOP->FH_FIMVIGE,1,4) + Substr(cTBTPOP->FH_FIMVIGE,5,2) >= Substr(dEmissRet,1,4) + Substr(dEmissRet,5,2)) .Or. Empty(cTBTPOP->FH_FIMVIGE))
			nRecSFH := cTBTPOP->R_E_C_N_O_
			Exit
		Endif
		cTBTPOP->(DbSkip())
		Loop
	End			
Endif

If nRecSFH == 0
	cTpop := "6"
Else	
	
	If cTBTPOP->FH_TIPO == "X"
		cTpop := "1" //Sujeto exento o sujeto excluido 
	ElseIf cTBTPOP->FH_PERCENT == 100
		cTpop := "2" //Sujeto no Contribuyente y/o Operaciones no alcanzadas 
	ElseIf cTBTPOP->FH_TIPO == "N"
		cTpop := "6" //No Inscripto/ Operación alcanzada 
	ElseIf cTBTPOP->FH_TIPO == "F"	
		cTpop := "8" //Operaciones con consumidores finales 
	Else
		cTpop := "0"	
	Endif

Endif

cTBTPOP->(dbCloseArea()) 
Return cTpop

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  P_IIBB     ºAutor  ³Emanuel V.V.  º Data ³  27/02/2004       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcion encargada de administrar las sucursales o no       º±±
±±º          ³ dependiendo si se selecciona consolidado o no.		      º±±
±±º          ³ Argentina.                                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION P_IIBB(cIB,cProv,lSiapIB,cTipo,cSubcon,cSuc,nOpc)
Local nProcFil  	:= 0
Local cBkpFil		:= ""
Local cTabTrab 	:= ""  
Local cTabReg 		:= ""  
Local aRel         := {}

Default cTipo		:= "2"
Default cIB		:= "IB2"
Default cProv		:= "BA"
Default lSiapIB	:= .F.             
Default cSubcon	:= " "
Default cSuc		:= "1"

cTipo := Substr(cTipo,1,1)

cBkpFil	:= cFilAnt
cSuc 	:= Substr(cSuc,1,1)

If  cSuc== "1" //Significa que sera consolidado y que hubo seleccion de Sucursales
    //Cambiar logico para que NO continue procesando filiales    
	For nProcFil:=1 to len(aFilsCalc)
		If aFilsCalc[nProcFil,1] == .T.
			cFilAnt := aFilsCalc[nProcFil,2]
			cTabReg = P_IBBA(cIB,cProv,lSiapIB,cTipo,cSuc,cTabTrab,@aRel)			
			cTabTrab = IIF(!EMPTY(cTabReg),cTabReg,cTabTrab)
			aFilsCalc[nProcFil,1]:=.F. 			
		Endif
	Next nProcFil
Else 
	cTabTrab = P_IBBA(cIB,cProv,lSiapIB,cTipo,cSuc,cTabTrab,@aRel)	
Endif

cFilAnt := cBkpFil

If cTipo="2" 
	If PER->(RecCount()) > 0
		MsgAlert(OemToAnsi(STR0092))//"Registros exportados com sucesso"
		LogArqTRep("SIAPIB - Percepcion",aRel)//"SIAPIB - Percepcoes"
	Else
		MsgAlert(OemToAnsi(STR0093))//"Nao ha registros" 
	Endif
Endif

Return(cTabTrab)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³P_IBBA    ºAutor  ³Rafael P. Rizzatto  º Data ³  22/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para importar valores de impostos da tabela SF3     º±±
±±º          ³ para o modulo AGENTES de RECAUDACION do sistema S.I.Ap.    º±±
±±º          ³ da Argentina.                                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION P_IBBA(cIB,cProv,lSiapIB,cTipo,cSuc,cArqTrab,aRel)
Local aStruIIBB 	:= {}
Local aArea			:= {}

Local bWhile		:= {|| .T.}
Local bIf   		:= {|| .F.}                                     

Local cQuery 		:= "" 
Local cChave    	:= ""  
Local cAlias    	:= "PER"    
Local cBase		:= "F3_BASIMP"
Local cValor		:= "F3_VALIMP"  
Local cAliq			:= "F3_ALQIMP"  
Local cDecrProv		:= ""           
Local cAliasSF3 	:= "SF3"
Local cEndereco		:= ""
Local cNumero		:= ""


Local lQuery		:= .F. 
Local lSFB			:= .F.
Local cQrySf3		:= ""

Local nX			:= 0
     	
Default cIB			:= "IB2"
Default cProv		:= "BA"
Default lSiapIB		:= .F.             
Default cTipo		:= "2"
Default cSuc		:= "1"
Default cArqTrab	:= ""  
Default aRel		:= {}

cSuc := Substr(cSuc,1,1)

SX5->(dbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tabela temporaria que recebera as percepciones³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aStruIIBB,{"PIB_CUIT",  	'C',13,0 }) 
aadd(aStruIIBB,{"PIB_FECHA", 	'C',10,0 }) 
aadd(aStruIIBB,{"PIB_TIPO",  	'C',01,0 }) 
aadd(aStruIIBB,{"PIB_SERIE", 	'C',01,0 }) 
aadd(aStruIIBB,{"PIB_SUC",   	'C',04,0 }) 
aadd(aStruIIBB,{"PIB_FACTUR",	'C',08,0 }) 
aadd(aStruIIBB,{"PIB_BASE",   	'N',12,02})   
aadd(aStruIIBB,{"PIB_VALOR",  	'N',11,02})   
// Campos para a provincia de Neuquen    
aadd(aStruIIBB,{"PIB_ALIQ",  	'N',5,02})   
aadd(aStruIIBB,{"PIB_NIGB",  	'C',13, 0}) 
aadd(aStruIIBB,{"PIB_RAZON",  	'C',35, 0})  
aadd(aStruIIBB,{"PIB_PROV",  	'C',25, 0}) 
aadd(aStruIIBB,{"PIB_DOMIC",  	'C',50, 0}) 
aadd(aStruIIBB,{"PIB_NUMERO", 	'C',06, 0}) 
aadd(aStruIIBB,{"PIB_MONO",  	'C',06, 0}) 
aadd(aStruIIBB,{"PIB_PLANTA", 	'C',02, 0}) 
aadd(aStruIIBB,{"PIB_DEPTO",  	'C',04, 0}) 
aadd(aStruIIBB,{"PIB_PISO",  	'C',02, 0}) 
aadd(aStruIIBB,{"PIB_OFIC",  	'C',04, 0})  
aadd(aStruIIBB,{"PIB_CARAC",  	'C',08, 0})  
aadd(aStruIIBB,{"PIB_TELEF",  	'C',10, 0}) 
aadd(aStruIIBB,{"PIB_POSTAL",  	'C',08, 0}) 
aadd(aStruIIBB,{"PIB_LOCAL",  	'C',25, 0}) 
aadd(aStruIIBB,{"PIB_AGENTE",  	'C',06, 0})   
// Campos para a provincia de corrientes
aadd(aStruIIBB,{"PIB_CANC",  	'D',08, 0})   
aadd(aStruIIBB,{"PIB_PERS", 	'C',02, 0})   
aadd(aStruIIBB,{"PIB_DGR",    	'C',01, 0})   
aadd(aStruIIBB,{"PIB_NFISC",    'C',12, 0}) 

//Creacion de Objeto 
If Select("PER") == 0
	oTmpTable := FWTemporaryTable():New("PER") 
	oTmpTable:SetFields( aStruIIBB )
	aOrdem	:=	{"PIB_FECHA", "PIB_SERIE", "PIB_SUC", "PIB_FACTUR"}
	oTmpTable:AddIndex("IN1", aOrdem)
	oTmpTable:Create()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atraves do imposto a ser processado verifico o campo na tabela SB1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aArea := GetArea()
DbSelectArea("SFB")
SFB->(dbSetOrder(1))
If SFB->(dbSeek(xFilial("SFB")+cIB))
	cCpo 	:= SFB->FB_CPOLVRO
	cBase 	:= cBase + cCpo
	cValor	:= cValor + cCpo
	cAliq	:= cAliq + cCpo
	lSFB	:= .T.
Endif             
RestArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄT¿
//³Apenas faz a query se a chamada da funcao for para selecao              ³
//³dos movimentos de percepcao. Quando a chamada eh para                   ³
//³arquivos de retencao, apenas cria o temporario para nao dar erro no INI.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄTÙ
If cTipo == "2"  .And. lSFB
	
	#IFDEF TOP
	    If TcSrvType()<>"AS/400"  
	    
			lQuery := .T.       
			cQuery := "SELECT F3_FILIAL, F3_ENTRADA, F3_LOJA, F3_RG1415, F3_CLIEFOR, F3_TIPO , F3_SERIE , F3_NFISCAL , F3_DTCANC, F3_PV, " 
			cQuery += cAliq + ", " + cBase + ", " + cValor + ", " 
			cQuery += "A1_COD, A1_LOJA, A1_CGC, A1_NOME, A1_END, A1_TEL, A1_CXPOSTA, A1_BAIRRO, A1_AGENPER, A1_PESSOA "
			cQuery += ", A1_NROIB "
			cQuery += "FROM "+ RetSqlName("SF3") + " SF3, "+ RetSqlName("SA1") + " SA1 "
			cQuery += "WHERE F3_FILIAL = '" + xFilial("SF3") + "' AND "
			cQuery += "A1_FILIAL = '" + xFilial("SA1") + "' AND "
			cQuery += "F3_ENTRADA BETWEEN '" + DTOS(MV_PAR01)+ "' AND '" + DTOS(MV_PAR02)+ "' AND "
			cQuery += "F3_TIPOMOV = 'V' AND "
			cQuery += cValor + " > 0 AND "   
			cQuery += "A1_LOJA = F3_LOJA AND "
			cQuery += "A1_COD = F3_CLIEFOR AND "   
			cQuery += "F3_DTCANC = '' AND "
			cQuery += "SF3.D_E_L_E_T_ <>'*' AND "
			cQuery += "SA1.D_E_L_E_T_ <>'*' "

			If lSiapIB .and. EXISTBLOCK ("LCARGSIAP")
				cQrySf3 := EXECBLOCK ("LCARGSIAP",.F.,.F.,{"PERC",cProv})
				If ValType(cQrySf3) == "C" .and. !Empty(cQrySf3)
					cQuery := cQuery + cQrySf3
				EndIf
			EndIf
			
			cQuery += "Order By F3_ENTRADA, F3_SERIE, F3_NFISCAL "

		  	cQuery:= ChangeQuery(cQuery)
			
			MsAguarde({ | | dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .T., .T.) },, ) //"Por favor aguarde"###"Seleccionando registros en el Servidor..."
		                               
			TCSetField('TRB', "F3_ENTRADA" , "D",8,0)
			TCSetField('TRB', "F3_DTCANC" , "D",8,0)
			TCSetField('TRB', cBase , "N",TAMSX3("F3_BASIMP6")[1],TAMSX3("F3_BASIMP6")[2])
			TCSetField('TRB', cValor , "N",TAMSX3("F3_VALIMP6")[1],TAMSX3("F3_VALIMP6")[2])
			TCSetField('TRB', cAliq , "N",TAMSX3("F3_ALQIMP6")[1],TAMSX3("F3_ALQIMP6")[2])
		
			cAliasSF3 := "TRB"
			cAliasSA1 := "TRB"
			bWhile	:= {||.T.}   
			bIf     := {||.T.}  
			DbSelectArea('TRB')
		Else
	#ENDIF
			DbSelectArea("SF3")
			DbSetOrder(1)
			dBSeek(xFilial()+DTOS(MV_PAR01),.T.)	
			cAliasSF3:= "SF3"                  
			cAliasSA1:= "SA1"                  
			bWhile 	:= {|| xFilial("SF3") == (cAliasSF3)->F3_FILIAL .AND. (cAliasSF3)->F3_ENTRADA >= MV_PAR01 .AND. (cAliasSF3)->F3_ENTRADA <= MV_PAR02}
			bIf		:= {|| (cAliasSF3)->&cValor  > 0 .AND. (cAliasSF3)->F3_TIPOMOV = 'V' }
	#IFDEF TOP
		Endif    
	#ENDIF                    
Endif
If cTipo == "1"	 .AND. cProv == "BA"
	bWhile	:= {||.F.} 
EndIf
While !(cAliasSF3)->(EOF()).And. Eval(bWhile)
	If Eval(bIf)                
	
		If !lQuery
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)					
		Endif      
		
		cDecrProv := ""
		If SX5->(dbSeek(xFilial("SX5")+"12"+SA1->A1_EST))
			cDecrProv := SX5->X5_DESCSPA
		Endif       
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Separa o numero do endereco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cEndereco 	:= ""
		cNumero   	:= ""
		lAchou 		:= .F.
		For nX := 1 To Len((cAliasSA1)->A1_END)
			If IsDigit(Substr((cAliasSA1)->A1_END,nX,1))
				lAchou := .T.
				cNumero	+=	Substr((cAliasSA1)->A1_END,nX,1)
			Else 
				If !lAchou
					cEndereco +=	Substr((cAliasSA1)->A1_END,nX,1)
				Else
					Exit
				Endif
			Endif
		Next  
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Identifica caso se trate de um mesmo documento (F3 quebrado pela chave)³
		//³para armazenar as informacoes em apenas um registro.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      	If cChave == DTOS((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
			RecLock("PER",.F.)		
	      	PIB_BASE    += IIF(PIB_TIPO == "C", -1*(cAliasSF3)->&cBase,(cAliasSF3)->&cBase)//CASO SEJA DEBITO
			PIB_VALOR   += IIF(PIB_TIPO == "C", -1*(cAliasSF3)->&cValor, (cAliasSF3)->&cValor)//CASO SEJA DEBITO

			aDel(aRel,Len(aRel))
			aAdd(aRel,cFilAnt +" "+TransForm(PIB_CUIT,"@R 99-99999999-9")+" - "+PIB_FECHA+" - "+PIB_TIPO+" - "+PIB_SERIE+" - "+PIB_NFISC+" - "+TransForm(PIB_BASE,"@E 999,999,999.99")+" - "+TransForm(PIB_VALOR,"@E 999,999,999.99"))
		Else	
			RecLock("PER",.T.)
			PIB_ALIQ 	:= (cAliasSF3)->&cAliq
			PIB_CUIT    := aRetDig((cAliasSA1)->A1_CGC,.F.)
			PIB_FECHA   := Substr(DTOS((cAliasSF3)->F3_ENTRADA),7,2)+"/"+Substr(DTOS((cAliasSF3)->F3_ENTRADA),5,2)+"/"+Substr(DTOS((cAliasSF3)->F3_ENTRADA),1,4)
			PIB_TIPO    := IIF((cAliasSF3)->F3_TIPO == "D" .AND. (cAliasSF3)->F3_RG1415 >= "200" , "H", IIF((cAliasSF3)->F3_TIPO == "C" .AND. (cAliasSF3)->F3_RG1415 >= "200", "I", ;
			               IIF((cAliasSF3)->F3_TIPO == "N" .AND. (cAliasSF3)->F3_RG1415 >= "200", "E",IIF((cAliasSF3)->F3_TIPO == "D", "C", IIF((cAliasSF3)->F3_TIPO == "C", "D", "F")))))//AJUSTE DE DIFERENCA DE TIPOS, Protheus x SIAP
			PIB_SERIE   := (cAliasSF3)->(SubStr(F3_SERIE,1,1))  
			If !lSiapIB
				PIB_SUC     := (cAliasSF3)->(SubStr(F3_NFISCAL,1,4))
				PIB_FACTUR  := (cAliasSF3)->(SubStr(F3_NFISCAL,5,8))
			Else
				PIB_SUC     := (cAliasSF3)->F3_FILIAL
				PIB_FACTUR  := (cAliasSF3)->(SubStr(F3_NFISCAL,5,12))
			Endif
	     	PIB_BASE    := IIF(PIB_TIPO $ "C|H", -1*(cAliasSF3)->&cBase,(cAliasSF3)->&cBase)//CASO SEJA DEBITO
			PIB_VALOR   := IIF(PIB_TIPO $ "C|H", -1*(cAliasSF3)->&cValor, (cAliasSF3)->&cValor)//CASO SEJA DEBITO
			PIB_NIGB	:= aRetDig((cAliasSA1)->A1_NROIB,.F.)
			PIB_RAZON   := (cAliasSA1)->A1_NOME
			PIB_PROV	:= cDecrProv
			PIB_DOMIC	:= cEndereco
			PIB_NUMERO	:= cNumero
			PIB_MONO	:= ""
			PIB_PLANTA	:= ""
			PIB_DEPTO	:= ""
			PIB_PISO	:= ""        	
			PIB_OFIC	:= ""
			PIB_CARAC	:= ""
			PIB_TELEF	:= (cAliasSA1)->A1_TEL
			PIB_POSTAL	:= (cAliasSA1)->A1_CXPOSTA
			PIB_LOCAL	:= (cAliasSA1)->A1_BAIRRO
			PIB_AGENTE	:= (cAliasSA1)->A1_AGENPER
			PIB_CANC    := (cAliasSF3)->F3_DTCANC
			PIB_PERS	:= Iif((cAliasSA1)->A1_PESSOA == "F","00","01")
			PIB_DGR    	:= Iif((cAliasSA1)->A1_AGENPER == "S","S","N")
			If Len((cAliasSF3)->F3_PV) > 4
				PIB_NFISC	:= StrZero(Val((cAliasSF3)->(SubStr(F3_NFISCAL,2,4))),4)+StrZero(Val((cAliasSF3)->(SubStr(F3_NFISCAL,6,9))),8)
			Else 
				PIB_NFISC	:= StrZero(Val((cAliasSF3)->(SubStr(F3_NFISCAL,1,4))),4)+StrZero(Val((cAliasSF3)->(SubStr(F3_NFISCAL,5,8))),8)
			EndiF
			aAdd(aRel,cFilAnt +" "+TransForm(PIB_CUIT,"@R 99-99999999-9")+" - "+PIB_FECHA+" - "+PIB_TIPO+" - "+PIB_SERIE+" - "+PIB_NFISC+" - "+TransForm(PIB_BASE,"@E 999,999,999.99")+" - "+TransForm(PIB_VALOR,"@E 999,999,999.99"))
		EndIf               
		                
		MsUnlock()    		
		
	    cChave :=  DTOS((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
	EndIf
   (cAliasSF3)->(DbSkip()) 
EndDo

If Select("TRB")>0
	dbSelectArea("TRB")
	dbCloseArea()
Endif

Return(cArqTrab)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³D_IBBA     ºAutor  ³ Mary C. Hergert    º Data ³  14/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Apaga arquivos temporarios criados para gerar o arquivo     º±±
±±º         ³ Magnetico de ingresos brutos - Argentina                    º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ MATA950                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function D_IBBA(aDelArqs)

Local aAreaDel := GetArea()
Local nI := 0

For nI:= 1 To Len(aDelArqs)
	If File(aDelArqs[ni,2]+GetDBExtension())
		dbSelectArea(aDelArqs[ni,2])
		dbCloseArea()
		Ferase(aDelArqs[ni,2]+GetDBExtension())
		Ferase(aDelArqs[ni,2]+OrdBagExt())
	Endif	
Next

RestArea(aAreaDel)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  R_IIBB     ºAutor  ³Emanuel V.V.  º Data ³  27/02/2004       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcion encargada de administrar las sucursales o no       º±±
±±º          ³ dependiendo si se selecciona consolidado o no.		      º±±
±±º          ³ Argentina.                                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION R_IIBB(cIB,cProv,lSiapIB,cTipo,cSubcon,cSuc,nOpc)
Local nProcFil  	:= 0
Local cBkpFil		:= ""
Local cTabTrab 	:= ""  
Local cTabReg 		:= ""  
Local aRel         := {}

Default cTipo		:= "1"
Default cIB		:= "B"
Default cProv		:= "BA"
Default lSiapIB	:= .F.             
Default cSubcon	:= " "
Default cSuc		:= "1"

cTipo := Substr(cTipo,1,1)

cBkpFil	:= cFilAnt
cSuc 	:= Substr(cSuc,1,1)

If  cSuc== "1" //Significa que sera consolidado y que hubo seleccion de Sucursales
    //Cambiar logico para que NO continue procesando filiales    
	For nProcFil:=1 to len(aFilsCalc)

		If aFilsCalc[nProcFil,1] == .T.
			cFilAnt := aFilsCalc[nProcFil,2]
			cTabReg = R_IBBA(cIB,cProv,lSiapIB,cTipo,cSubcon,cSuc,cTabTrab,@aRel)
			cTabTrab = IIF(!EMPTY(cTabReg),cTabReg,cTabTrab)
			//aFilsCalc[nProcFil,1]:=.F. 			
		Endif
	Next nProcFil
Else 
	cTabReg = R_IBBA(cIB,cProv,lSiapIB,cTipo,cSubcon,cSuc,cTabTrab,@aRel)
Endif

cFilAnt := cBkpFil

If cTipo="1" 
	If RET->(RecCount()) > 0 
		If !lAutomato
			MsgAlert(OemToAnsi(STR0092))//"Registros exportados com sucesso"
			LogArqTRep("SIAPIB - Retencion",aRel)//"SIAPIB - Retencoes"
		EndIf
	Else
		MsgAlert(OemToAnsi(STR0093))//"Nao ha registros"
	Endif
Endif 
	
Return(cTabTrab)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R_IBBA    ºAutor  ³Rafael P. Rizzatto  º Data ³  22/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para importar o valore de imposto da tabela SFE     º±±
±±º          ³ para o modulo AGENTES de RECAUDACION do sistema S.I.Ap.    º±±
±±º          ³ da Argentina.                                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION R_IBBA(cImp,cProv,lSiapIB,cTipo,cSubcon,cSuc,cArqTrab,aRel)

Local aStruRET := {}
Local aSuc := {}

Local cQuery 	:= ""
Local cAlias 	:= "RET"
Local cAliasSFE	:= "SFE"

Local cNumCert  := ""
Local lAcumula:=.T. 
Local dDataEmis := CTOD("  /  /  ")

Local cCertSFE  := ""
Local dEmisSFE  := CTOD("  /  /  ")

Local bWhile	:= {|| .T.}
Local bIf   	:= {|| .F.}

Local lQuery	:= .F.
Local cCGC     := ""
Local cNroCert := ""
Local cEmissao := CTOD("  /  /  ")
Local cProvent := ""
Local nProcFil  := 0
Local nX := 0
Local cDecrProv := ""
Local cEndereco := ""
Local cNumero := ""
Local cAliasSA2 := "SA2"
Local nValImp := 0
Local nBase	:= 0
Local cFilGer := ""
Local nTamFil := 0
Local nSinal := 1   
Local nTotAcu := 0
Local aAreaAt := {}
Local lCompSFE := (FwModeAccess("SFE",1) + FwModeAccess("SFE",2) + FwModeAccess("SFE",3)) == "CCC"
Local cQrySf3		:= ""

Default cProv	:= "BA"
Default lSiapIB	:= .F.
Default cTipo	:= "1"
Default cImp	:= "B"
Default cSubcon	:= " "
Default cSuc	:= "1"
Default cArqTrab := ""
Default aRel     := {}

cSuc := Substr(cSuc,1,1)

//VETOR COM A ESTRUTURA DA TABELA TEMPORARIA
aadd(aStruRET,{"RIB_CUIT",   	'C',13,0 })   //A2_CGC
aadd(aStruRET,{"RIB_FECHA",  	'C',10,0 })   //FE_EMISSAO
aadd(aStruRET,{"RIB_SUC",    	'C',04,0 })   //FE_NFISCAL - SubStr(FE_NFISCAL,1,4)
aadd(aStruRET,{"RIB_NEMISS", 	'C',08,0 })   //FE_NFISCAL - SubStr(FE_NFISCAL,5,8)
aadd(aStruRET,{"RIB_RETENC", 	'N',10,02})   //FE_RETENC
aadd(aStruRET,{"RIB_NRCOMP",	'C',TAMSX3("FE_NROCERT")[1],00})   //FE_NROCERT
aadd(aStruRET,{"RIB_RAZON",  	'C',36,0 })  
aadd(aStruRET,{"RIB_PERS",  	'C',02,0 })              
aadd(aStruRET,{"RIB_BASE",		'N',TAMSX3("FE_VALBASE")[1],02})
aadd(aStruRET,{"RIB_ALIQ", 		'N',05,02})
aadd(aStruRET,{"RIB_DGR", 		'C',01,00})
aadd(aStruRET,{"RIB_TIPO", 		'C',01,00})
aadd(aStruRET,{"RIB_NFISC",    	'C',12,0 })   //FE_NFISCAL - SubStr(FE_NFISCAL,1,4)+SubStr(FE_NFISCAL,5,8)
aadd(aStruRET,{"RIB_TIPOP",     'C',01,00})
// Campos para a provincia de Neuquen    
aadd(aStruRET,{"RIB_LUGAR",		'C',50,0})   
aadd(aStruRET,{"RIB_LFECH",		'C',10, 0})   
aadd(aStruRET,{"RIB_FECHRT",	'C',10, 0}) 
aadd(aStruRET,{"RIB_IBBRT",		'C',13,0 }) 
aadd(aStruRET,{"RIB_CONTRB",	'C',35, 0}) 
aadd(aStruRET,{"RIB_PROVC",		'C',35, 0}) 
aadd(aStruRET,{"RIB_DOMICL",	'C',50, 0}) 
aadd(aStruRET,{"RIB_DOMNUM",	'C',06, 0})  
aadd(aStruRET,{"RIB_MONO",		'C',06, 0})  
aadd(aStruRET,{"RIB_PLANTA",	'C',02, 0}) 
aadd(aStruRET,{"RIB_DEPTO",		'C',04, 0}) 
aadd(aStruRET,{"RIB_PISO",		'C',02, 0}) 
aadd(aStruRET,{"RIB_OFCNA",		'C',04, 0})
aadd(aStruRET,{"RIB_CARACT",	'C',08, 0})   
aadd(aStruRET,{"RIB_TELNUM",	'C',10, 0})   
aadd(aStruRET,{"RIB_CODPTL",	'C',08, 0})
aadd(aStruRET,{"RIB_LOCAL",		'C',25, 0})
aadd(aStruRET,{"RIB_AGRET",		'C',06, 0})
aadd(aStruRET,{"RIB_NCERT",		'C',07, 0})

//Creacion de Objeto 
If Select("RET")==0
	oTmpTable := FWTemporaryTable():New("RET") 
	oTmpTable:SetFields( aStruRET )
	aOrdem	:=	{"RIB_FECHA", "RIB_SUC"}
	oTmpTable:AddIndex("IN1", aOrdem)
	oTmpTable:Create()
Endif

dbSelectArea("RET")	

cSubcon := Substr(cSubcon,1,1)
nTamFil := Len( alltrim(FWSM0Layout()))
If cSuc $ "1|2" .And. (Len(aFilsCalc) > 0)
	cFilGer := FWxFilial("SFE") 
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄT¿
//³Apenas faz a query se a chamada da funcao for para selecao              ³
//³dos movimentos de retencao. Quando a chamada eh para arquivos           ³
//³de percepcao, apenas cria o temporario para nao dar erro no INI.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄTÙ
If cTipo == "1"
	#IFDEF TOP         
		If TcSrvType()<>"AS/400"   
			lQuery := .T.
			If SFE->(ColumnPos ("FE_DTRETOR"))>0  .And. SFE->(ColumnPos ("FE_DTESTOR"))>0
				cQuery := "SELECT A2_CGC , A2_NOME ,A2_EST , A2_END , A2_RETIB , A2_NROIB , A2_TEL , A2_BAIRRO , A2_CX_POST , FE_FILIAL , FE_EMISSAO , FE_DTRETOR , FE_DTESTOR , FE_NFISCAL , FE_SERIE , FE_EST , "   
			Else
				cQuery := "SELECT A2_CGC , A2_NOME, A2_RETIB, FE_FILIAL, FE_EMISSAO, FE_NFISCAL, FE_SERIE, "   	
			EndIf
			If SFE->(ColumnPos ("FE_NRETORI"))>0
				cQuery += "FE_NRETORI, "
			EndIf
			If SA2->(ColumnPos ("A2_SUBCON"))>0
				cQuery += "A2_SUBCON, "
			EndIf
			
			cQuery += "FE_FORNECE, FE_LOJA, FE_NROCERT, FE_RETENC, FE_VALBASE, FE_ALIQ " 
			cQuery += "FROM "+ RetSqlName("SA2") + " SA2, "+ RetSqlName("SFE") + " SFE "
			cQuery += "WHERE  "              
			cQuery += "FE_TIPO ='"+Substr(cImp,1,1)+"' AND "
			cQuery += "A2_FILIAL = '" + xFilial("SA2") + "' AND "
			aAreaAt:=GetArea()
			DbSelectArea("SFE")
			If !Empty(cFilAnt) .And. SFE->(ColumnPos('FE_MSFIL'))>0 .And. (Empty(xFilial("SFE")) .Or. lCompSFE)
				cQuery+=" FE_MSFIL = '"+cFilAnt+"' AND "
			Else
				cQuery += " FE_FILIAL = '" + IIf(Len(aFilsCalc) > 0,cFilGer,xFilial("SFE") ) + "' AND " //cFilGer -- xFilial("SFE",cFilGer)
			EndIf	
			RestArea(aAreaAt)
			cQuery += "A2_LOJA = FE_LOJA AND "
			cQuery += "A2_COD = FE_FORNECE AND "
			If SFE->(ColumnPos('FE_EST')) > 0
				cQuery += "FE_EST = '" + cProv + "' AND "
			Endif                                                                                   
			If SA2->(ColumnPos('A2_SUBCON')) > 0 .And. cSubcon$"12"
				cQuery += "A2_SUBCON = '" + cSubcon + "' AND "
			Endif

			cQuery += "FE_EMISSAO BETWEEN '" + DTOS(MV_PAR01)+ "' AND '" + DTOS(MV_PAR02)+ "' AND "
			cQuery += "SA2.D_E_L_E_T_ <>'*' AND "
			cQuery += "SFE.D_E_L_E_T_ <>'*' AND "
			cQuery += "SFE.FE_NROCERT <>'NORET'" 

			If lSiapIB .and. EXISTBLOCK ("LCARGSIAP")
				cQrySf3 := EXECBLOCK ("LCARGSIAP",.F.,.F.,{"RET",cProv})
				If ValType(cQrySf3) == "C" .and. !Empty(cQrySf3)
					cQuery := cQuery + cQrySf3
				EndIf
			EndIf

			cQuery += "Order By FE_EMISSAO, FE_NROCERT, FE_NFISCAL, FE_RETENC  "
		   	cQuery:= ChangeQuery(cQuery)
			
			MsAguarde({ | | dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .T., .T.) },, ) //"Por favor aguarde"###"Seleccionando registros en el Servidor..."
		
			TCSetField('TRB', "FE_EMISSAO" , "D",8,0)                               
			
			If SFE->(ColumnPos ("FE_DTRETOR"))>0  .And. SFE->(ColumnPos ("FE_DTESTOR"))>0
				TCSetField('TRB', "FE_DTRETOR" , "D",8,0)
				TCSetField('TRB', "FE_DTESTOR" , "D",8,0) 
			EndiF
			
			TCSetField('TRB', "FE_RETENC"  , "N",TAMSX3("FE_RETENC")[1],TAMSX3("FE_RETENC")[2])
		
			cAliasSFE := "TRB"
			cAliasSA2 := "TRB"
			bWhile	:= {||.T.}   
			bIf     := {||.T.}                           
			
			DbSelectArea('TRB')
		Else
	#ENDIF
			cAliasSFE:= "SFE"                  
			cAliasSA2:= "SA2"                  
			DbSelectArea("SFE")
			DbSetOrder(7)
			MsSeek(xFilial()+DTOS(MV_PAR01),.T.)	
			bWhile 	:= {|| xFilial("SFE") == (cAliasSFE)->FE_FILIAL .AND. (cAliasSFE)->FE_EMISSAO >= MV_PAR01 .AND. (cAliasSFE)->FE_EMISSAO <= MV_PAR02}
			If SFE->(ColumnPos('FE_EST')) > 0
				bIf		:= {|| (cAliasSFE)->FE_TIPO =='B' .And. (cAliasSFE)->FE_EST == cProv}
			Else
				bIf		:= {|| (cAliasSFE)->FE_TIPO =='B'}
			Endif  
	#IFDEF TOP
		Endif    
	#ENDIF

While !(cAliasSFE)->(EOF()).And. Eval(bWhile)
	If Eval(bIf)
		If !lQuery
			DbSelectArea("SA2")
			DbSetOrder(1)
			MsSeek(xFilial("SA2")+(cAliasSFE)->FE_FORNECE+(cAliasSFE)->FE_LOJA)					
		Endif           
		cDecrProv := ""
		If SX5->(MsSeek(xFilial("SX5")+"12"+(cAliasSFE)->A2_EST))
			cDecrProv := SX5->X5_DESCSPA
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Separa o numero do endereco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cEndereco 	:= ""
		cNumero   	:= ""
		lAchou 		:= .F.
		For nX := 1 To Len((cAliasSFE)->A2_END)
			If IsDigit(Substr((cAliasSFE)->A2_END,nX,1))
				lAchou := .T.
				cNumero	+=	Substr((cAliasSFE)->A2_END,nX,1)
			Else 
				If !lAchou
					cEndereco +=	Substr((cAliasSFE)->A2_END,nX,1)
				Else
					Exit
				Endif
			Endif
		Next
		
		If SFE->(ColumnPos ("FE_DTRETOR"))>0  .And. SFE->(ColumnPos ("FE_DTESTOR"))>0
			If Empty((cAliasSFE)->FE_DTRETOR) .and. Empty((cAliasSFE)->FE_DTESTOR) .And. (cAliasSFE)->FE_VALBASE>=0
				cTipoDc:="D"
			ElseIf Empty((cAliasSFE)->FE_DTRETOR) .and. Empty((cAliasSFE)->FE_DTESTOR) .And. (cAliasSFE)->FE_VALBASE<0
				cTipoDc:="C"		
			ElseIf Empty((cAliasSFE)->FE_DTRETOR) .and. !Empty((cAliasSFE)->FE_DTESTOR) .And. (cAliasSFE)->FE_VALBASE>=0
				cTipoDc:="D"
			ElseIf Empty((cAliasSFE)->FE_DTRETOR) .and. !Empty((cAliasSFE)->FE_DTESTOR) .And. (cAliasSFE)->FE_VALBASE<0
				cTipoDc:="C"
			ElseIf !Empty((cAliasSFE)->FE_DTRETOR) .and. !Empty((cAliasSFE)->FE_DTESTOR) .And. (cAliasSFE)->FE_VALBASE>=0
				cTipoDc:="C"
			ElseIf !Empty((cAliasSFE)->FE_DTRETOR) .and. !Empty((cAliasSFE)->FE_DTESTOR) .And. (cAliasSFE)->FE_VALBASE<0
				cTipoDc:="D"
			EndIf	
			
			If  (((cAliasSFE)->FE_VALBASE>=0 .and. cTipoDc=="D" ) .Or. ((cAliasSFE)->FE_VALBASE<0 .and. cTipoDc=="C" ) ).And. (DTOS((cAliasSFE)->FE_DTESTOR) >= DTOS(MV_PAR01) .And. DTOS((cAliasSFE)->FE_DTESTOR) <= DTOS(MV_PAR02)) 
	       		 (cAliasSFE)->(DbSkip())
	       	 	Loop
	  	  	ElseIf (((cAliasSFE)->FE_VALBASE<0 .and. cTipoDc=="D"  ) .or. ((cAliasSFE)->FE_VALBASE>=0 .and. cTipoDc=="C"  )).And. (DTOS((cAliasSFE)->FE_DTRETOR) >= DTOS(MV_PAR01) .And. DTOS((cAliasSFE)->FE_DTRETOR) <= DTOS(MV_PAR02)) 
	   	     	(cAliasSFE)->(DbSkip())
	   	     	Loop
			Endif	
        EndIf
		 		
	 	IF SF1->(MsSeek(xfilial("SF1")+(cAliasSFE)->FE_NFISCAL+(cAliasSFE)->FE_SERIE+(cAliasSFE)->FE_FORNECE+(cAliasSFE)->FE_LOJA)) 
		     cProvent := Alltrim(SF1->F1_PROVENT)   
		Elseif 	SF2->(MsSeek(xfilial("SF2")+(cAliasSFE)->FE_NFISCAL+(cAliasSFE)->FE_SERIE+(cAliasSFE)->FE_FORNECE+(cAliasSFE)->FE_LOJA))
		     IF Alltrim(SF2->F2_ESPECIE)$"NCE,NCP,NDI,NDC"   
		        cProvent := Alltrim(SF2->F2_PROVENT)
		     EndIf     
		Endif
		
		If SFE->(ColumnPos ("FE_DTRETOR"))>0 .And. !Empty((cAliasSFE)->FE_NRETORI) .And. (((cAliasSFE)->FE_RETENC < 0 .AND.  cTipoDc=="D") .OR. ((cAliasSFE)->FE_RETENC >= 0 .AND.  cTipoDc=="C")  )
			cCertSFE := (cAliasSFE)->FE_NRETORI
			dEmisSFE := (cAliasSFE)->FE_DTRETOR
		Else
			cCertSFE := (cAliasSFE)->FE_NROCERT
			dEmisSFE := (cAliasSFE)->FE_EMISSAO
		EndIf
		If cProv == "BA" .and. Upper(alltrim(MV_PAR03)) <> "SIAPIB" .and. (cAliasSA2)->A2_CGC == cCGC .and. dEmisSFE == cEmissao .and. cCertSFE == cNroCert
		
			If RecLock("RET",.F.)
				RIB_RETENC += (cAliasSFE)->FE_RETENC
				
				If RIB_RETENC == 0
					RET ->(dbDelete() )
					RET->( MsUnlock() )
				Endif
			EndIf
			
			aDel(aRel,Len(aRel))
			aSize(aRel,Len(aRel)-1)
			If RIB_RETENC <> 0
				aAdd(aRel,cFilAnt +" "+TransForm(RIB_CUIT,"@R 99-99999999-9")+" - "+RIB_FECHA+" - "+RIB_NRCOMP+" - "+TransForm(RIB_RETENC,"@E 999,999,999.99")+" - "+RIB_TIPOP)
			Endif
		Else
			If (Substr(DTOS((cAliasSFE)->FE_EMISSAO),5,2) <> Substr(DTOS((cAliasSFE)->FE_DTESTOR),5,2)) .OR. (Substr(DTOS((cAliasSFE)->FE_EMISSAO),5,2) <> Substr(DTOS((cAliasSFE)->FE_DTRETOR),5,2)) 
				
				lAcumula:=.F.
				
				If cNumCert == (cAliasSFE)->FE_NROCERT .And. (cAliasSA2)->A2_CGC == cCGC
					lAcumula:=.T. 
				EndIf                  
				If   !lAcumula
					nTotAcu := 0
					RecLock("RET",.T.)
					RIB_CUIT    := IIf((cAliasSFE)->FE_EST == "NE",aRetDig(SM0->M0_CGC,.F.),aRetDig((cAliasSA2)->A2_CGC,.F.))
					RIB_RAZON   := (cAliasSA2)->A2_NOME
					If SFE->(ColumnPos ("FE_DTRETOR"))>0 .And. !Empty((cAliasSFE)->FE_NRETORI) .And. (((cAliasSFE)->FE_RETENC < 0 .AND. cTipoDc=="D" ) .OR. ((cAliasSFE)->FE_RETENC >= 0 .AND. cTipoDc=="C" ) )
						dDataEmis := (cAliasSFE)->FE_DTRETOR
					Else
						dDataEmis := (cAliasSFE)->FE_EMISSAO
					EndIf
					RIB_FECHA   := Substr(DTOS(dDataEmis),7,2)+"/"+Substr(DTOS(dDataEmis),5,2)+"/"+Substr(DTOS(dDataEmis),1,4)
					If !lSiapIB
						RIB_SUC     := (cAliasSFE)->(SubStr(FE_NFISCAL,1,4))
						RIB_NEMISS  := (cAliasSFE)->(SubStr(FE_NFISCAL,5,8))
					Else
						RIB_SUC     := (cAliasSFE)->FE_FILIAL
						RIB_NEMISS  := (cAliasSFE)->(SubStr(FE_NFISCAL,5,12))
					Endif
					RIB_RETENC  := (cAliasSFE)->FE_RETENC
					nValImp := (cAliasSFE)->FE_RETENC
					If SFE->(ColumnPos ("FE_NRETORI"))>0 .And. !Empty((cAliasSFE)->FE_NRETORI) .And. (((cAliasSFE)->FE_RETENC < 0 .AND. cTipoDc=="D" ).OR. ((cAliasSFE)->FE_RETENC >= 0 .AND. cTipoDc=="C" )   )
						cNumCert := (cAliasSFE)->FE_NRETORI
					Else
						cNumCert := (cAliasSFE)->FE_NROCERT
					EndIf
					RIB_NRCOMP	:= SubStr(cNumCert,(Len(cNumCert)-11),Len(cNumCert))
					RIB_PERS	:= "01" 
					RIB_BASE	:= (cAliasSFE)->FE_VALBASE
					nBase := (cAliasSFE)->FE_VALBASE
					RIB_ALIQ	:= (cAliasSFE)->FE_ALIQ
					RIB_DGR		:= (cAliasSA2)->A2_RETIB
					RIB_TIPO    := IIF(SF2->F2_TIPO == "D", "C", IIF(SF2->F2_TIPO == "C", "D", "F"))
					RIB_NFISC	:= StrZero(Val((cAliasSFE)->(SubStr(FE_NFISCAL,1,4))),4)+StrZero(Val((cAliasSFE)->(SubStr(FE_NFISCAL,5,8))),8)
					If SFE->(ColumnPos ("FE_DTRETOR"))>0 .And. !Empty((cAliasSFE)->FE_NRETORI) .And. (((cAliasSFE)->FE_RETENC < 0 .AND. cTipoDc=="D") .OR. ((cAliasSFE)->FE_RETENC >= 0 .AND. cTipoDc=="C") )
						RIB_TIPOP   := "B"
					Else
						RIB_TIPOP   := "A"
					EndIf
					
					If (cAliasSFE)->FE_EST $ "BA" .And. RIB_TIPOP  = "B"
						RIB_FECHA := Substr(DTOS((cAliasSFE)->FE_DTESTOR),7,2)+"/"+Substr(DTOS((cAliasSFE)->FE_DTESTOR),5,2)+"/"+Substr(DTOS((cAliasSFE)->FE_DTESTOR),1,4)	
						RIB_RETENC := (- nsinal) *  (RIB_RETENC)
					Elseif (cAliasSFE)->FE_EST $ "CR" .And. RIB_TIPOP  = "B"	
						RIB_FECHA := Substr(DTOS((cAliasSFE)->FE_DTESTOR),7,2)+"/"+Substr(DTOS((cAliasSFE)->FE_DTESTOR),5,2)+"/"+Substr(DTOS((cAliasSFE)->FE_DTESTOR),1,4)	
					Endif 
					
					If (cAliasSFE)->FE_EST == "NE"
						RIB_LUGAR := AllTrim(SM0->M0_CIDCOB)
						RIB_LFECH := Substr(DTOS((cAliasSFE)->FE_EMISSAO),7,2)+"/"+Substr(DTOS((cAliasSFE)->FE_EMISSAO),5,2)+"/"+Substr(DTOS((cAliasSFE)->FE_EMISSAO),1,4)
						RIB_FECHRT:= Substr(DTOS((cAliasSFE)->FE_EMISSAO),7,2)+"/"+Substr(DTOS((cAliasSFE)->FE_EMISSAO),5,2)+"/"+Substr(DTOS((cAliasSFE)->FE_EMISSAO),1,4)
						RIB_IBBRT := (cAliasSFE)->A2_NROIB
						RIB_CONTRB := (cAliasSFE)->A2_NOME
						RIB_PROVC := cDecrProv
						RIB_DOMICL := cEndereco
						RIB_DOMNUM := cNumero
						RIB_MONO := ""
						RIB_PLANTA := ""
						RIB_DEPTO := ""
						RIB_PISO := ""
						RIB_OFCNA := ""
						RIB_CARACT := ""	
						RIB_TELNUM := (cAliasSFE)->A2_TEL
						RIB_CODPTL := (cAliasSFE)->A2_CX_POST
						RIB_LOCAL := (cAliasSFE)->A2_BAIRRO
						RIB_AGRET :=  ""//(cAliasSA2)->A2_AGENPER - Falta informar de onde vira a informação		
					Endif
				Else
					RecLock("RET",.F.)
					nValImp:= (cAliasSFE)->FE_RETENC
					RIB_RETENC += (cAliasSFE)->FE_RETENC
					nBase := (cAliasSFE)->FE_VALBASE
					RIB_BASE	+= (cAliasSFE)->FE_VALBASE
					If cProv == "BA" .and. Upper(alltrim(MV_PAR03)) == "SIAPIB" .and. Len(aRel) > 0 
						aDel(aRel,Len(aRel))
						aSize(aRel,Len(aRel)-1)
					EndIf
				Endif
				MsUnlock()
				nTotAcu += (cAliasSFE)->FE_RETENC
				cCGC := (cAliasSA2)->A2_CGC
				cEmissao := dDataEmis
				cNroCert := cNumCert
			
				If (cAliasSFE)->FE_EST == "NE"
					aAdd(aRel,cFilAnt +" "+TransForm(RIB_CUIT,"@R 99-99999999-9")+" - "+RIB_FECHA+" - "+RIB_NRCOMP+" - "+TransForm(nValImp,"@E 999,999,999.99")+" - "+RIB_TIPOP)
				ElseIf (cAliasSFE)->FE_EST $ "BA" .And. RIB_TIPOP  = "B"
					aAdd(aRel,cFilAnt +" "+TransForm(RIB_CUIT,"@R 99-99999999-9")+" - "+RIB_FECHA+" - "+RIB_NRCOMP+" - "+TransForm( ((-nSinal)*(cAliasSFE)->FE_RETENC),"@E 999,999,999.99")+" - "+RIB_TIPOP)
				Else
					aAdd(aRel,cFilAnt +" "+TransForm(RIB_CUIT,"@R 99-99999999-9")+" - "+RIB_FECHA+" - "+RIB_NRCOMP+" - "+TransForm(Iif(cProv == "BA" .AND. Upper(alltrim(MV_PAR03)) == "SIAPIB",Iif(lAcumula,nTotAcu,(cAliasSFE)->FE_RETENC),(cAliasSFE)->FE_RETENC),"@E 999,999,999.99")+" - "+RIB_TIPOP)
				Endif	
			Endif
		EndIf

	EndIf
	
    (cAliasSFE)->(DbSkip())
    
EndDo

dbSelectArea("TRB")
dbCloseArea()
Endif

Return cArqTrab 


/*/{Protheus.doc} LocArgLibM
Función utilizada para validar la fecha de la LIB para ser utilizada en Telemetria
@type       Function
@author     Faturación
@since      2021
@version    12.1.27
@return     _lMetric, lógico, si la LIB puede ser utilizada para Telemetria
/*/
Static Function LocArgLibM()

If _lMetric == Nil 
	_lMetric := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')
EndIf

Return _lMetric

/*/{Protheus.doc} CFOSIRCAR
Función utilizada para extraer valores correspondientes al CFO de las tablas SD1 Y SD2
@type       Function
@author     adrian.perez	
@since      Noviembre/2021
@version    12.1.27
@param      cQuery,caracter, consulta modificar de las SF3
@param      aNrLvrIB,array,  arreglo que contiene los campos de los impuestos del libro fiscal.
@return     cQuery, string, devuelve la query a ser utilizada para la obtencion de datos entre las tablas SF3 SD1 Y SD2
/*/
Static Function CFOSIRCAR(cQuery,aNrLvrIB,aNrLvrIV)
Local nI:=0
Local cQry:=""
Local aAux:={}

For nI:=1 To Len(aNrLvrIB)
	IF ASCAN(aAux,aNrLvrIB[nI][2] )<=0
		cQry+= " CASE WHEN SD2.D2_VALIMP"+aNrLvrIB[nI][2]+" IS NOT NULL THEN SD2.D2_VALIMP"+aNrLvrIB[nI][2]
		cQry+= "      WHEN SD1.D1_VALIMP"+aNrLvrIB[nI][2]+" IS NOT NULL THEN SD1.D1_VALIMP"+aNrLvrIB[nI][2]  
		cQry+= " ELSE 0 END AS F3_VALIMP"+aNrLvrIB[nI][2]+","
		
		cQry+= " CASE WHEN SD2.D2_BASIMP"+aNrLvrIB[nI][2]+" IS NOT NULL THEN SD2.D2_BASIMP"+aNrLvrIB[nI][2]
		cQry+= "      WHEN SD1.D1_BASIMP"+aNrLvrIB[nI][2]+" IS NOT NULL THEN SD1.D1_BASIMP"+aNrLvrIB[nI][2]  
		cQry+= " ELSE 0 END AS F3_BASIMP"+aNrLvrIB[nI][2]+","

		cQry+= " CASE WHEN SD2.D2_ALQIMP"+aNrLvrIB[nI][2]+" IS NOT NULL THEN SD2.D2_ALQIMP"+aNrLvrIB[nI][2]
		cQry+= "      WHEN SD1.D1_ALQIMP"+aNrLvrIB[nI][2]+" IS NOT NULL THEN SD1.D1_ALQIMP"+aNrLvrIB[nI][2]  
		cQry+= " ELSE 0 END AS F3_ALQIMP"+aNrLvrIB[nI][2]+","
		aadd(aAux,aNrLvrIB[nI][2])
	END
	
																
Next
nI:=0
For nI:=1 To Len(aNrLvrIV)
	IF ASCAN(aAux,aNrLvrIV[nI][2] )<=0
		cQry+= " CASE WHEN SD2.D2_VALIMP"+aNrLvrIV[nI][2]+" IS NOT NULL THEN SD2.D2_VALIMP"+aNrLvrIV[nI][2]
		cQry+= "      WHEN SD1.D1_VALIMP"+aNrLvrIV[nI][2]+" IS NOT NULL THEN SD1.D1_VALIMP"+aNrLvrIV[nI][2]  
		cQry+= " ELSE 0 END AS F3_VALIMP"+aNrLvrIV[nI][2]+","
		
		cQry+= " CASE WHEN SD2.D2_BASIMP"+aNrLvrIV[nI][2]+" IS NOT NULL THEN SD2.D2_BASIMP"+aNrLvrIV[nI][2]
		cQry+= "      WHEN SD1.D1_BASIMP"+aNrLvrIV[nI][2]+" IS NOT NULL THEN SD1.D1_BASIMP"+aNrLvrIV[nI][2]  
		cQry+= " ELSE 0 END AS F3_BASIMP"+aNrLvrIV[nI][2]+","

		cQry+= " CASE WHEN SD2.D2_ALQIMP"+aNrLvrIV[nI][2]+" IS NOT NULL THEN SD2.D2_ALQIMP"+aNrLvrIV[nI][2]
		cQry+= "      WHEN SD1.D1_ALQIMP"+aNrLvrIV[nI][2]+" IS NOT NULL THEN SD1.D1_ALQIMP"+aNrLvrIV[nI][2]  
		cQry+= " ELSE 0  END AS F3_ALQIMP"+aNrLvrIV[nI][2]+","
		aadd(aAux,aNrLvrIV[nI][2])
	END
	
																
Next


cQry+=" CASE WHEN D2_TES IS NOT NULL THEN D2_TES WHEN D1_TES IS NOT NULL THEN D1_TES END AS F3_TES,"
cQry+=" CASE WHEN D2_CF IS NOT NULL THEN D2_CF WHEN D1_CF IS NOT NULL THEN D1_CF END AS F3_CFO,"
cQry+=" CASE WHEN SF2.F2_MOEDA IS NOT NULL THEN F2_MOEDA WHEN SF1.F1_MOEDA IS NOT NULL THEN F1_MOEDA   END AS MONEDA, "
cQry+=" CASE WHEN SF2.F2_TXMOEDA IS NOT NULL THEN F2_TXMOEDA WHEN SF1.F1_TXMOEDA IS NOT NULL THEN F1_TXMOEDA    END AS TASA "

cQuery:= STRTRAN(cQuery, "SF3.*", " DISTINCT SF3.F3_NFISCAL,SF3.F3_FILIAL,SF3.F3_CLIEFOR,SF3.F3_LOJA,SF3.F3_SERIE,SF3.F3_ESTADO,SF3.F3_ESPECIE,SF3.F3_EMISSAO,SF3.F3_TIPOMOV,"+cQry)

cQuery:= STRTRAN(cQuery,"WHERE"," LEFT JOIN "+RetsqlName("SD2")+" SD2 ON "+ " SD2.D2_DOC = SF3.F3_NFISCAL AND SD2.D2_SERIE=SF3.F3_SERIE AND SD2.D2_CLIENTE= SF3.F3_CLIEFOR "+; 
				"  LEFT JOIN "+RetsqlName("SD1")+" SD1 ON "+ " SD1.D1_DOC = SF3.F3_NFISCAL AND SD1.D1_SERIE=SF3.F3_SERIE  AND SD1.D1_FORNECE = SF3.F3_CLIEFOR "+;
				 " LEFT JOIN "+RetsqlName("SF2")+" SF2 ON "+" SF2.F2_DOC = SF3.F3_NFISCAL AND SF2.F2_SERIE=SF3.F3_SERIE  AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR "+;
				 " LEFT JOIN "+RetsqlName("SF1")+" SF1 ON "+" SF1.F1_DOC = SF3.F3_NFISCAL AND SF1.F1_SERIE=SF3.F3_SERIE  AND SF1.F1_FORNECE = SF3.F3_CLIEFOR WHERE ")

Return cQuery
