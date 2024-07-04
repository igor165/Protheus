#Include "Protheus.ch" 
#Include "Topconn.ch"

Static oTmpRet1	
Static oTmpRet2
Static oTmpQry1
Static oTmpQry2	

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma   ณ FFRetenc ณ Autor ณ Tiago Bizan          ณ Fecha ณ 20/08/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescripcionณ Rotina que faz a Query para os furmularios 01-146, 01-246, ณฑฑ
ฑฑณ           ณ 02-181 e 02-183(Reten็๕es)                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso        ณ FISCAL                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณData    ณ BOPS     ณ Motivo da Alteracao                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ  Marco A.  ณ02/01/17ณSERINN001 ณSe aplica CTREE para evitar la creacionณฑฑ
ฑฑณ            ณ        ณ-546      ณde tablas temporales de manera fisica  ณฑฑ
ฑฑณ            ณ        ณ          ณen system.                             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function FFRetenc(aInf)

	Local cQry1		:= ""
	Local aStruRETC	:= {} 
	Local aStruRETN	:= {}	
	Local llErro	:= .T.
	Local cArqTrabN	:= ""
	Local cArqTrabC	:= ""
	Local aTRBRet1	:= {}
	Local aTRBRet2	:= {}
	Local clCGC		:= ""
	Local clLinha	:= ""
	Local clData	:= "" 
	Local nI		:= 0
	Local nlLin		:= 0
	Local aOrdem1	:= {}
	Local aOrdem2	:= {}
	Local aArqTrab	:= {}

	If SubStr(DTOS(MV_PAR01), 1, 6) <> SubStr(DTOS(MV_PAR02), 1, 6) .OR. (MV_PAR02 < MV_PAR01)
		llErro := .F.			
	EndIf

	//Formularios 01-146 e 01-246
	aAdd(aStruRETN, {"TIPDOCFIS"	, "N", 02, 0}) //Tipo Documento Responsavel FIscal
	aAdd(aStruRETN, {"PAISRESP"		, "C", 02, 0}) //Pais do Responsavel
	aAdd(aStruRETN, {"DOCRESP"		, "C", 12, 0}) //Documento do Responsavel
	aAdd(aStruRETN, {"FORMULARIO"	, "C", 05, 0}) //Formulario
	aAdd(aStruRETN, {"PERDECLA"		, "N", 06, 0}) //Periodo da Declaracao
	aAdd(aStruRETN, {"TIPDOCINF"	, "C", 02, 0}) //Tipo Documento Informado
	aAdd(aStruRETN, {"PAISINF"		, "C", 02, 0}) //Pais Informado
	aAdd(aStruRETN, {"DOCINF"		, "C", 12, 0}) //Documento de Informado
	aAdd(aStruRETN, {"DATAINF"		, "N", 06, 0}) //Data da Informa็ใo
	aAdd(aStruRETN, {"LINHA"		, "N", 03, 0}) //Linha
	aAdd(aStruRETN, {"IMPORTE"		, "C", 12, 2}) //Importe
	
	aOrdem1 := {"TIPDOCFIS", "PAISRESP", "DOCRESP"}
		
	oTmpRet1 := FWTemporaryTable():New("TRBRet1")
	oTmpRet1:SetFields(aStruRETN)
	oTmpRet1:AddIndex("IN1", aOrdem1)
	
	oTmpRet1:Create()
		
	aAdd(aArqTrab, {'oTmpRet1', 'TRBRet1'})

	//Formularios  02-183
	aAdd(aStruRETC, {"RUTINFANTE"	, "C", 12, 0}) //RUT do Informante
	aAdd(aStruRETC, {"FORMULARIO"	, "C", 05, 0}) //Formulario
	aAdd(aStruRETC, {"PERIODO"		, "N", 06, 0}) //Periodo
	aAdd(aStruRETC, {"RUTINFADO"	, "C", 12, 2}) //RUT Informado
	aAdd(aStruRETC, {"FATURA"		, "N", 06, 0}) //Factura
	aAdd(aStruRETC, {"LINHA"		, "N", 03, 0}) //Linha
	aAdd(aStruRETC, {"IMPORTE"		, "C", 12, 2}) //Importe
	
	aOrdem2 := {"RUTINFANTE", "FORMULARIO", "PERIODO"}
		
	oTmpRet2 := FWTemporaryTable():New("TRBRet2")
	oTmpRet2:SetFields(aStruRETC)
	oTmpRet2:AddIndex("IN1", aOrdem2)
	
	oTmpRet2:Create()
		
	aAdd(aArqTrab, {'oTmpRet2', 'TRBRet2'})

	If !llErro
		Alert("Verifique perํodo informado.")
	Else
		cQry1 := " SELECT A2_TP, A2_PAIS, A2_CGC, FE_RETENC, FE_TIPIMP, FE_CONCEPT, FE_EMISSAO "
		cQry1 += " FROM " +RetSqlName("SFE")+" SFE "
		cQry1 += " INNER JOIN " + RetSqlName("SA2") + " SA2 "
		cQry1 += " ON SFE.FE_FORNECE = SA2.A2_COD "
		cQry1 += " AND SA2.D_E_L_E_T_ = '' " 
		cQry1 += " AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
		cQry1 += " WHERE SFE.D_E_L_E_T_ = ''
		cQry1 += " AND SFE.FE_FILIAL = '" + xFilial("SFE") + "' "
		cQry1 += " AND SFE.FE_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
		IF aInf[1,1] == "02-183"
			cQry1 += " AND SFE.FE_TIPIMP IN ('IRA', 'RIV', 'RI2', 'PFI') "
		ElseIf aInf[1,1] == "01-146"
			cQry1 += " AND SFE.FE_TIPIMP IN ('IRP') "		
		ElseIf aInf[1,1] == "01-246"		
			cQry1 += " AND SFE.FE_TIPIMP IN ('IRN') "
		EndIf
		cQry1 += " ORDER BY A2_CGC, FE_CONCEPT, FE_EMISSAO "

		cQry1 := ChangeQuery(cQry1)

		TcQuery cQry1 New Alias "QRY1"	

		If aInf[1,1] == "01-146" .OR. aInf[1,1] == "01-246"
			Qry1->(dbGotop())
			While Qry1->(!EOF())        
				If clCGC <> Qry1->A2_CGC .OR. clLinha <> Qry1->FE_CONCEPT .OR. SubStr(clData,1,6) <> SubStr(Qry1->FE_EMISSAO,1,6)   
					aAdd(aTRBRet1, {aInf[1,2], aInf[1,3],aInf[1,4],SubStr(aInf[1,1],1,2) + ;
					SubStr(aInf[1,1],4,3),SubStr(DTOS(MV_PAR01),1,6),IIf(Qry1->A2_TP == "1","02","03"),;
					AllTrim(Posicione("SYA",1,xFilial("SYA")+Qry1->A2_PAIS,"YA_SIGLA")),;
					Qry1->A2_CGC,SubStr(DTOS(MV_PAR01),1,6),Qry1->FE_CONCEPT,;
					Qry1->FE_RETENC})
					nlLin +=1
				Else
					aTRBRet1[nlLin,11] += Qry1->FE_RETENC
				EndIf
				clCGC	:= Qry1->A2_CGC 
				clLinha := Qry1->FE_CONCEPT
				clData	:= Qry1->FE_EMISSAO 
				Qry1->(DBSkip())
			EndDO
		ElseIf aInf[1,1] == "02-183" 
			Qry1->(dbGotop())
			While Qry1->(!EOF())
				If clCGC <> Qry1->A2_CGC .OR. clLinha <> Qry1->FE_CONCEPT .OR. SubStr(clData,1,6) <> SubStr(Qry1->FE_EMISSAO,1,6)   
					aAdd(aTRBRet2,{aInf[1,4],SubStr(aInf[1,1],1,2) + SubStr(aInf[1,1],4,3),SubStr(DTOS(MV_PAR01),1,6),;
					Qry1->A2_CGC,SubStr(DTOS(MV_PAR01),1,6),Qry1->FE_CONCEPT,Qry1->FE_RETENC})
					nlLin +=1
				Else
					aTRBRet2[nlLin,7] += Qry1->FE_RETENC
				EndIf
				clCGC	:= Qry1->A2_CGC 
				clLinha := Qry1->FE_CONCEPT
				clData	:= Qry1->FE_EMISSAO 
				Qry1->(DBSkip())
			EndDO
		EndIf					
		If aInf[1,1] == "02-183" 
			For nI := 1 To Len (aTRBRet2)
				If aTRBRet2[nI,7]>0
					dbSelectArea("TRBRet2")
					If RecLock("TRBRet2",.T.) 
						TRBRet2->RUTINFANTE := PadL(aTRBRet2[nI,1],12,"0")
						TRBRet2->FORMULARIO := aTRBRet2[nI,2]
						TRBRet2->PERIODO 	:= Val(aTRBRet2[nI,3])
						TRBRet2->RUTINFADO	:= aTRBRet2[nI,4]
						TRBRet2->FATURA   	:= Val(aTRBRet2[nI,5])
						TRBRet2->LINHA		:= Val(aTRBRet2[nI,6])
						TRBRet2->IMPORTE	:= Padl(aTRBRet2[nI,7],12,"0")
					EndIf
				EndIf
			Next nI				
		ElseIf aInf[1,1] == "01-146" .OR. aInf[1,1] == "01-246"
			For nI := 1 To Len (aTRBRet1)
				If aTRBRet1[nI,11]>0
					dbSelectArea("TRBRet1")
					If RecLock("TRBRet1",.T.)
						TRBRet1->TIPDOCFIS 	:= Val(aTRBRet1[nI,1])
						TRBRet1->PAISRESP  	:= aTRBRet1[nI,2]
						TRBRet1->DOCRESP 	:= PadL(aTRBRet1[nI,3], 12, "0")
						TRBRet1->FORMULARIO	:= aTRBRet1[nI,4]
						TRBRet1->PERDECLA   := Val(aTRBRet1[nI,5])
						TRBRet1->TIPDOCINF	:= aTRBRet1[nI,6]							
						TRBRet1->PAISINF	:= aTRBRet1[nI,7]			
						TRBRet1->DOCINF		:= Padl(aTRBRet1[nI,8], 12, "0")
						TRBRet1->DATAINF 	:= Val(aTRBRet1[nI,9])
						TRBRet1->LINHA		:= Val(aTRBRet1[nI,10])
						TRBRet1->IMPORTE	:= Padl(aTRBRet1[nI,11], 12, "0") 
					EndIf
				EndIf
				MsUnlock() 
			Next nI
		EndIf				
	EndIf
	
Return (aArqTrab)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFF218X      บ Autor ณTiago Bizan		          ณ  20/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que faz a Query para os furmularios 02-181 e 02-183   บฑฑ
ฑฑบ          ณ (IVA's Percep็๕es)                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FISCAL                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
User Function FF218X(aInf, alErro)

	Local cQry2		:= ""
	Local aStruRETC	:= {} 
	Local aStruRETN	:= {}		
	Local clLivro	:= ""
	Local cArqTrabC	:= ""		
	Local cArqTrabN	:= ""
	Local aTRBqry2	:= {}
	Local aTRBqry1	:= {}
	Local aImposto	:= {}	
	Local clImposto	:= ""
	Local nlLin		:= 0
	Local nI		:= 0
	Local clCGC		:= ""
	Local clCGC2	:= ""
	Local aOrdem1	:= {}
	Local aOrdem2	:= {}
	
	Default alErro	:= {}

	//Formularios 02-181 e 02-183
	aAdd(aStruRETC,	{"RUTINFANTE"	, "C", 12, 0}) //RUT do Informante
	aAdd(aStruRETC,	{"FORMULARIO"	, "C", 05, 0}) //Formulario
	aAdd(aStruRETC,	{"PERIODO"		, "N", 06, 0}) //Periodo
	aAdd(aStruRETC,	{"RUTINFADO"	, "C", 12, 2}) //RUT Informado
	aAdd(aStruRETC,	{"FATURA"		, "N", 06, 0}) //Factura
	aAdd(aStruRETC,	{"LINHA"		, "N", 03, 0}) //Linha
	aAdd(aStruRETC,	{"IMPORTE"		, "C", 12, 2}) //Importe
	
	aOrdem1 := {"RUTINFANTE", "FORMULARIO", "PERIODO"}
		
	oTmpQry1 := FWTemporaryTable():New("TRBqry2")
	oTmpQry1:SetFields(aStruRETC)
	oTmpQry1:AddIndex("IN1", aOrdem1)
	
	oTmpQry1:Create()
	
	aAdd(alErro,{'oTmpQry1', 'TRBqry2'})

	//Formulario 02-176
	aAdd(aStruRETN, {"RUTCONTRIB"	, "C", 12, 0}) //RUT Contribuinte
	aAdd(aStruRETN, {"FORMULARIO"	, "C", 04, 0}) //Formulario
	aAdd(aStruRETN, {"PERIODO"		, "N", 06, 0}) //Periodo
	aAdd(aStruRETN, {"LINHA"		, "C", 12, 0}) //Linha
	aAdd(aStruRETN, {"COMPLEMENT"	, "C", 14, 0}) //Complemento
	aAdd(aStruRETN, {"IMPORTE"		, "C", 22, 5}) //Importe
	
	aOrdem2 := {"RUTCONTRIB", "FORMULARIO", "PERIODO"}
		
	oTmpQry2 := FWTemporaryTable():New("TRBqry1")
	oTmpQry2:SetFields(aStruRETN)
	oTmpQry2:AddIndex("IN1", aOrdem2)
	
	oTmpQry2:Create()
	
	aAdd(alErro, {'oTmpQry2', 'TRBqry1'})

	If !Empty(alErro[1]) .AND. (aInf[1,1] == "02-181" .OR. aInf[1,1] == "02-176")

		cQry2 := " SELECT SF3.*, F4_ATUATF, FC_IMPOSTO, A2_CGC, A2_TP, A2_PAIS, A2_TIPO, A1_TIPO, A1_TP, A1_CGC "
		cQry2 += " FROM " + RetSqlName("SF3") + " SF3 "
		cQry2 += " INNER JOIN " + RetSqlName("SF4") + " SF4 "
		cQry2 += " ON F4_CODIGO = F3_TES "
		cQry2 += " AND F4_FILIAL = '" + xFilial("SF4") + "' "
		cQry2 += " AND SF4.D_E_L_E_T_= '' "
		cQry2 += " INNER JOIN " + RetSqlName("SFC") + " SFC "
		cQry2 += " ON  FC_TES=F3_TES "
		cQry2 += " AND FC_FILIAL = '" + xFilial("SFC") + "' "
		If aInf[1,1] == "02-181"
			cQry2 += " AND (SubString(FC_IMPOSTO,1,2) = 'IV' OR FC_IMPOSTO = 'PFR') "
			cQry2 += " AND FC_IMPOSTO <> 'IV6' "			
			cQry2 += " AND FC_IMPOSTO <> 'IV7' "			
			cQry2 += " AND FC_IMPOSTO <> 'IV8' "									
		ElseIf aInf[1,1] == "02-176"
			cQry2 += " AND FC_IMPOSTO = 'IV8' "	
		EndIf		
		cQry2 += " AND SFC.D_E_L_E_T_ = '' " 
		cQry2 += " Left JOIN " +RetSqlName("SA2")+" SA2 "
		cQry2 += " ON  A2_COD = F3_CLIEFOR "		
		cQry2 += " AND F3_TIPOMOV = 'C' "
		cQry2 += " AND A2_FILIAL = '" + xFilial("SA2") + "' "
		cQry2 += " AND SA2.D_E_L_E_T_='' "
		cQry2 += " Left JOIN " + RetSqlName("SA1") + " SA1 "
		cQry2 += " ON  A1_COD = F3_CLIEFOR "
		cQry2 += " AND F3_TIPOMOV = 'V' "
		cQry2 += " AND A1_FILIAL = '" + xFilial("SA1") + "' "
		cQry2 += " AND SA1.D_E_L_E_T_ = '' "
		cQry2 += " WHERE SF3.D_E_L_E_T_ = '' "
		If aInf[1,1] == "02-181"
			cQry2 += " AND (A2_TIPO = '1' "
			cQry2 += " OR A1_TIPO = '1') "	
		EndIf 	
		cQry2 += " AND F3_FILIAL = '" +xFilial("SF3")+"' "
		cQry2 += " AND F3_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
		cQry2 += " ORDER BY F3_TIPOMOV, A2_CGC, A1_CGC, F3_CONCEP1, F3_CONCEP2, "
		cQry2 += " F3_CONCEP3, F3_CONCEP4, F3_CONCEP5, F3_CONCEP6, F3_CONCEP7, F3_CONCEP8, "
		cQry2 += " F3_CONCEPA, F3_CONCEPB, F3_CONCEPC, F3_CONCEPD, F3_CONCEPE, F3_CONCEPH, "
		cQry2 += " F3_CONCEPI, F3_CONCEPJ, F3_CONCEPK, F3_CONCEPL, F3_CONCEPM, F3_EMISSAO " 

		cQry2 := ChangeQuery(cQry2)

		TcQuery cQry2 New Alias "QRY2"

		QRY2->(dbGotop())		
		If aInf[1,1] == "02-181" .OR. aInf[1,1] == "02-176"  
			While QRY2->(!Eof())					   
				If QRY2->F3_TIPOMOV == "C" 
					clCGC2 := QRY2->A2_CGC 
				ElseIf QRY2->F3_TIPOMOV == "V"
					clCGC2 := QRY2->A1_CGC 
				EndIf

				clLivro := ""
				clLivro := Posicione("SFB",1,xFilial("SFB")+QRY2->FC_IMPOSTO,"FB_CPOLVRO")				

				If aInf[1,1] == "02-181" 
					If clCGC <> clCGC2 .OR. clLinha <> &("QRY2->F3_CONCEP"+clLivro) .OR. SubStr(clData,1,6) <> SubStr(QRY2->F3_EMISSAO,1,6)   
						aAdd(aTRBqry2,{aInf[1,4],SubStr(aInf[1,1],1,2) + SubStr(aInf[1,1],4,3),;
						SubStr(DTOS(MV_PAR01),1,6),IIf(QRY2->F3_TIPOMOV="C",Padl(QRY2->A2_CGC,12,"0"),Padl(QRY2->A1_CGC,12,"0")),;
						SubStr(DTOS(MV_PAR01),1,6),&("QRY2->F3_CONCEP"+clLivro),&("QRY2->F3_VALIMP"+clLivro)})
						nlLin +=1
					Else
						aTRBqry2[nlLin,7] += IIf("NC"$QRY2->F3_ESPECIE,&("QRY2->F3_VALIMP"+clLivro)*(-1),&("QRY2->F3_VALIMP"+clLivro))
					EndIf				

				ElseIf aInf[1,1] == "02-176"
					If clCGC <> clCGC2 .OR. Ascan(aImposto,{|x| x == Alltrim(QRY2->FC_IMPOSTO)}) == 0 .OR. SubStr(clData,1,6) <> SubStr(QRY2->F3_EMISSAO,1,6)   
						aAdd(aTRBqry1,{aInf[1,4],SubStr(aInf[1,1],2,1) + SubStr(aInf[1,1],4,3),SubStr(DTOS(MV_PAR01),1,6),;
						IIf(QRY2->FC_IMPOSTO$"IV6/IV7/IV8","45","44"),"",&("QRY2->F3_VALIMP"+clLivro)})
						nlLin +=1
					Else
						aTRBqry1[nlLin,6] += IIf("NC" $ QRY2->F3_ESPECIE, &("QRY2->F3_VALIMP" + clLivro) * (-1), &("QRY2->F3_VALIMP" + clLivro))
					EndIf 
				EndIf
				If QRY2->F3_TIPOMOV == "C"
					clCGC	:= QRY2->A2_CGC	
				ElseIf QRY2->F3_TIPOMOV == "V"
					clCGC	:= QRY2->A1_CGC
				EndIf

				aImposto := {}
				If QRY2->FC_IMPOSTO $ "IV8" 					
					aAdd(aImposto, "IV8")
				Else					
					aAdd(aImposto, "IRP")
					aAdd(aImposto, "IRN")
					aAdd(aImposto, "IR2")
					aAdd(aImposto, "RI2")
					aAdd(aImposto, "IRA")
					aAdd(aImposto, "PFI")
					aAdd(aImposto, "PFR")
				EndIf

				clLinha := &("QRY2->F3_CONCEP" + clLivro)
				clData	:= QRY2->F3_EMISSAO 
				Qry2->(DBSkip())
			EndDO		
		EndIf	    

		If aInf[1, 1] == "02-181" 
			For nI := 1 To Len(aTRBqry2)
				dbSelectArea("TRBqry2")			
				If RecLock("TRBqry2",.T.) 
					TRBqry2->RUTINFANTE	:= PadL(aTRBqry2[nI,1],12,"0")
					TRBqry2->FORMULARIO := aTRBqry2[nI,2]
					TRBqry2->PERIODO 	:= Val(aTRBqry2[nI,3])
					TRBqry2->RUTINFADO	:= aTRBqry2[nI,4]
					TRBqry2->FATURA   	:= Val(aTRBqry2[nI,5])
					TRBqry2->LINHA		:= Val(aTRBqry2[nI,6])
					TRBqry2->IMPORTE	:= Padl(AllTrim(Str(aTRBqry2[nI,7])),12,"0")
				EndIf
				MsUnlock()		
			Next nI
		ElseIf aInf[1, 1] == "02-176"
			For nI := 1 To Len(aTRBqry1)
				dbSelectArea("TRBqry1")			
				If RecLock("TRBqry1",.T.) 
					TRBqry1->RUTCONTRIB	:= PadL(aTRBqry1[nI, 1], 12, "0")
					TRBqry1->FORMULARIO	:= aTRBqry1[nI, 2]
					TRBqry1->PERIODO	:= Val(aTRBqry1[nI, 3])
					TRBqry1->LINHA		:= Padl(aTRBqry1[nI, 4], 12, "0")
					TRBqry1->COMPLEMENT	:= aTRBqry1[nI, 5]
					TRBqry1->IMPORTE	:= (Str(aTRBqry1[nI, 6])) + Replicate(" ", 19 - Len(AllTrim(Str(aTRBqry1[nI, 6]))))
				EndIf
				MsUnlock()		
			Next nI
		EndIf	
	EndIf
	
Return (alErro)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDelDGI      บ Autor ณTiago Bizan		   บ Data ณ  25/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclui  o arquivo temporario da system .DBF                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ		                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/         
User Function DelDGI(aArqTrab)

	Local nArq := 0

	For nArq := 1 To Len(aArqTrab)
		
		dbSelectArea(aArqTrab[nArq, 2])
		dbCloseArea()
		
		&(aArqTrab[nArq, 1]):Delete()
		&(aArqTrab[nArq, 1]) := Nil
	Next

Return
