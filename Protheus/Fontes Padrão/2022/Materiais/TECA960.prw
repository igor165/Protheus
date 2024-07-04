#INCLUDE 'PROTHEUS.CH'
#Include 'FWMVCDEF.CH'
#Include 'TECA960.CH' 

Static nEnv := 0
Static nNEnv	:= 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA960
	Programação de Rateio

@sample 	TECA960() 

@since		24/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Function TECA960(lJob, aParams, aAtendentes)

Local cPerg 	 := "TECA960"
Local cCliDe	 := ""
Local cCliAt	 := ""
Local cCompt	 := ""
Local lOk		 := .F.
Local lCont		 := .F.
Local dDtIni	
Local dDtFim
Local nSobrR	 := 0
Local nProc		 := 0
Local nGerLg	 := 0
Local oProcess 	 := Nil	
Local cTpExp 	 := SuperGetMV("MV_GSOUT", .F., "1") //1 - Integração RH protheus(Default) - 2 Ponto de Entrada - 3 Arquivo CSV
Local cDirArq 	 := At960RHD()
Local nHandle 	 := 0
Local cPE 		 := "At960PrRt"
Local aRet 		 := { .T., {}}
Local cMsg 		 := ""
Local lRhRM 	 := SuperGetMv("MV_GSXINT",,"2") == "3"
Local lPergRtCt  := TecHasPerg("MV_PAR09", cPerg)  // Verifique se existe o pergunte (SX1) "Rateia Contrato?"
Local lRateiaCtr := .F.

Default lJob 	 	:= IsBlind()
Default aParams  	:= {}
Default aAtendentes := {}

nEnv 	:= 0
nNEnv	:= 0

While Pergunte(cPerg, !lJob)

	If lJob
		MV_PAR01 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR01"})][2]
		MV_PAR02 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR02"})][2]
		MV_PAR03 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR03"})][2]
		MV_PAR04 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR04"})][2]
		MV_PAR05 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR05"})][2]
		MV_PAR06 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR06"})][2]
		MV_PAR07 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR07"})][2]
		MV_PAR08 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR08"})][2]
		If lPergRtCt 
			MV_PAR09 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR09"})][2]
		EndIf	
	EndIf

	If lPergRtCt 
		IF VALTYPE(MV_PAR09) == 'N' .AND. MV_PAR09 == 1
			lRateiaCtr := .T.
		ELSE
			lRateiaCtr := .F.
		ENDIF
	EndIf
	cCliDe := MV_PAR01
	cCliAt	:= MV_PAR02
	dDtIni	:= MV_PAR03
	dDtFim	:= MV_PAR04
	cCompt	:= MV_PAR05 //month_Year
	nSobrR	:= MV_PAR06 //overwrite
	nProc	:= MV_PAR07 //Operation
	nGerLg	:= MV_PAR08 ///
	
	If At960VlPrg(dDtIni,dDtFim,cCompt, @aRet[2])	//Valida os campos do pergunte
		lCont := .T.
		If !lRhRM
			cCompt	:= At960Cfol(MV_PAR05)
		EndIf
		If nProc == 2
			cPE := "At960EsRt
		Else
			If "3" $ cTpExp
				nHandle := At960RHF("at960", cDirArq, .T., 3)
			
				If nHandle == -1
					lCont := .F.
					cMsg := STR0039 //"Problemas na criação do arquivo CSV."
					Help(,, "TECA960", cMsg,, 1, 0)				
					Exit
				EndIf
			EndIf		
		EndIf
		

		If  "2" $ cTpExp .and. !ExistBlock(cPE)
			cMsg := STR0040+cPE+STR0041 //"Ponto de Entrada "##" não compilado."
			Help(,,"TECA960",cMsg , ,1, 0)
			cTpExp := StrTran(cTpExp, "2", )
		EndIf		

		Exit
	ElseIf lJob
		lCont := .F.
		Exit
	EndIf

End	
lCont := lCont .AND. ( "2" $ cTpExp .OR. "1" $ cTpExp .or. "3" $ cTpExp)

If !Empty(cMsg)
	aAdd(aRet[2], cMsg)
EndIf

If lCont .AND. nProc == 2 //Estorno
	If !lRhRM
		lCont := lJob .OR. MsgNoYes(STR0001+;			//"A realização do estorno excluirá as programações de rateio existentes no módulo de Gestão de Pessoal"
					 STR0002+CHR(13)+CHR(10)+STR0003)	//" para os atendentes na competência informada."+##+##+"Deseja continuar com a operação?"
	Else
		lCont := lJob .OR. MsgNoYes(STR0043+; 			//"A realização do estorno excluirá as programações de rateio existentes no módulo de Gestão de Pessoal do sistema RM"
							CHR(13)+CHR(10)+STR0003)	//"Deseja continuar com a operação?"
	EndIf
EndIf

aRet[1] := lCont

If lCont		
	BEGIN TRANSACTION
		If !lJob
			oProcess := MSNewProcess():New( { | lEnd | lOk := A960ProgRt( @lEnd,cCliDe,cCliAt,dDtIni,dDtFim,cCompt,nSobrR,nProc,nGerLg,oProcess, cTpExp, nHandle, aAtendentes,lRateiaCtr) }, STR0036, IIf(nProc==1,STR0037,STR0038), .F. )	//"Aguarde, gerando programação de rateio...",("Enviando","Excluindo") 
			oProcess:Activate()
		Else
			lOk := A960ProgRt( .f.,cCliDe,cCliAt,dDtIni,dDtFim,cCompt,nSobrR,nProc,nGerLg,NIL, cTpExp, nHandle, aAtendentes,lRateiaCtr)
		EndIf
	END TRANSACTION()
EndIf

If lOk
	If nProc == 1  //Processamento Envio
		At960GrLg(,,,,,,,.T.)
		
		If nEnv == 0 .And. nNEnv == 0
			cMsg := STR0005
			Aviso(STR0004,cMsg,{STR0006},2)		//"Atenção","Não há registros para envio da programação de rateio.",{"OK"}
		Else
			cMsg := STR0008+cValToChar(nEnv)+CRLF;		//"Envio da Programação de Rateio","Programações enviadas: " 
					+STR0009+cValToChar(nNEnv)+CRLF;									//"Programações não enviadas: "
					+STR0010+TxLogPath("ProgRateio")
			Aviso(STR0007,cMsg,{STR0006},2)						//"Foi gerado o log no arquivo "{"OK"}
		EndIf
		
		aAdd(aRet[2], cMsg)
	Else	////Processamento Estorno
		If nNEnv > 0
			cMsg := STR0011+CRLF;										//"Atenção","Programações excluídas com sucesso"
					+STR0010+TxLogPath("ProgRateio")
			Aviso(STR0004,cMsg,{STR0006},2)						//"Foi gerado o log no arquivo "{"OK"}
			nNEnv := 0
			aAdd(aRet[2], cMsg)
		Else
			cMsg := STR0005
			Aviso(STR0004,cMsg,{STR0006},2)		//"Atenção","Não há registros para envio da programação de rateio.",{"OK"}
		EndIf	
	EndIf
EndIf

aRet[1] := aRet[1] .AND. lOK

If nHandle > 0
	fClose(nHandle)
EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} A960ProgRt
	Consulta as alocações

@sample 	A960ProgRt() 

@since		24/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Function A960ProgRt(lEnd,cCliDe,cCliAt,dDtIni,dDtFim,cCompt,nSobrR,nProc,nGerLg,oProcess, cTpExp, nHandle, aAtendentes, lRateiaCtr)

Local cAtend	:= ""
Local aAtend	:= {}
Local aTot		:= {}
Local cAtendOld := ""
Local nQtdProc	:= 0
Local cWhereAtt	:= ""
Local cFunc		:= ""
Local nTotLc	:= 0
Local cLoc		:= ""
Local cCC		:= ""
Local lCab 		:= .T.
Local cAliasA	:= GetNextAlias()
Local lIntRH 	:= SuperGetMv("MV_GSXINT",,"2") == "2"
Local lMVGerOS  := SuperGetMV("MV_GSGEROS",.F.,"1") == "1"
Local lMultiFil	:= TecMultRat()
Local nAux      := 0
Local nHoraAux  := 0
Local aTotal	:= {}
Local nX        := 0
Local lContabil	:= TecEntCtb("ABS")

Default oProcess := Nil
Default cTpExp := "1"
Default nHandle := 0
Default aAtendentes:= {}
Default lRateiaCtr := .F.

If !IsBlind()
	aEval(aAtendentes, { |a| cWhereAtt += " '" + a + "',"})
EndIf

cQuery := At960qry(lRateiaCtr,lMVGerOS,lContabil,lMultiFil,lIntRH, cWhereAtt,cCliDe,cCliAt,dDtIni,dDtFim)
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasA, .F., .T.)

(cAliasA)->(dbGoTop())
While !(cAliasA)->(EOF())
	If !lMVGerOS
		nHoraAux := Round(HoraToInt(SubStr((cAliasA)->TOTAL,6,10)),2)
	Else
		nHoraAux := (cAliasA)->TOTAL
	EndIf
	If (nAux := ASCAN(aTotal, {|a| a[1] == (cAliasA)->ABB_CODTEC .AND.;
												a[2] == IIF(lRateiaCtr,(cAliasA)->CNB_CC,(cAliasA)->ABS_CCUSTO) .AND.;
												a[3] == (cAliasA)->AA1_CDFUNC .AND.;
												a[4] == (cAliasA)->ABB_LOCAL .AND.;
												a[5] == (cAliasA)->AA1_FUNFIL})) == 0
		AADD(aTotal, {(cAliasA)->ABB_CODTEC,;
					IIf(lRateiaCtr,(cAliasA)->CNB_CC,(cAliasA)->ABS_CCUSTO),;
					(cAliasA)->AA1_CDFUNC,;
					(cAliasA)->ABB_LOCAL,;
					(cAliasA)->AA1_FUNFIL,;
					nHoraAux,;
					IIF(lContabil, IIF(lRateiaCtr,(cAliasA)->CNB_ITEMCT,(cAliasA)->ABS_ITEM), ""),;
					IIF(lContabil, IIF(lRateiaCtr,(cAliasA)->CNB_CLVL,(cAliasA)->ABS_CLVL), "")})
	ElseIf nAux > 0
		aTotal[nAux][6] += nHoraAux
	EndIf
	
	(cAliasA)->(DBSkip())
End
(cAliasA)->(dbCloseArea())

If !EMPTY(aTotal)
	nQtdProc := LEN(aTotal)
	If oProcess <> Nil
		oProcess:SetRegua1(nQtdProc)
	EndIf
	
	cAtendOld := aTotal[1][1]
	
	For nX := 1 To LEN(aTotal)
		cAtend  := aTotal[nX][1]
		nTotLc	:= aTotal[nx][6] 
		cLoc 	:= aTotal[nX][4]
		cCC		:= aTotal[nX][2]
		cFunc	:= aTotal[nX][3]
		
		If cAtendOld !=  aTotal[nX][1] .AND. cAtendOld != ""
			A960VldPrR(@aAtend,aTot,cCompt,nSobrR,nProc,nGerLg,oProcess, cTpExp, nHandle,  lCab )
			
			 lCab  := .F.
			aAtend := {}
		EndIF
		
		cAtendOld :=  aTotal[nX][1]	
		
		If oProcess <> Nil
			oProcess:IncRegua2(STR0012 +  aTotal[nX][1] + STR0013 )			//"Aguarde... Processando o rateio do "#'...'
		EndIf
		
		nPos := aScan(aAtend,{|x| x[1] ==  aTotal[nX][1].AND. x[4] ==  aTotal[nX][2] })
		If nPos > 0 //Se encontrar o mesmo atendente com o mesmo centro de custo, soma os valores
			aAtend[nPos][2] += nTotLc			
		Else		
			aAdd(aAtend,{cAtend,nTotLc,cLoc,cCC,cFunc, aTotal[nX][5], aTotal[nX][7], aTotal[nX][8]})
		EndIf
		
		nPos := aScan(aTot,{|x| x[1] ==  aTotal[nX][1] })
		If nPos > 0
			aTot[nPos][2] += nTotLc
		Else
			aAdd(aTot,{cAtend,nTotLc})//controle do total do atendente
		EndIf
								
	Next nX
	
	//Processa o ultimo atendente
	A960VldPrR(@aAtend,aTot,cCompt,nSobrR,nProc,nGerLg,oProcess, cTpExp, nHandle,  lCab )
	lCab := .f.
	aAtend := {}
		
EndIf

Return .T.

/*/{Protheus.doc} At960qry
Realiza a chamada da funcionade de r?plica para data na aba de multiplas aloca??es

@author		Diego Bezerra
@since		17/08/2021
@param lRateiaCtr, lógico, indica se irá ou não (.T. ou .F.) realizar rateio POR POSTO DE TRABALHO. Valor obtido do pergunte (SX1) MV_PAR09 do TECA960
@param lMVGerOS, lógico, indica se o atendimento das agendas se deu com a geração de ordens de serviço  ou não (.T. ou .F). Valor obtido do parâmetro MV_GSGEROS
@param lContabil, lógico
@param lMultiFil, lógico, .T. = Modo multifilial ativo - .F. = Modo multifilial desativado
@param lIntRH, lógico, .T. = 
@param cWhereAtt, caractere
@param cCliDe, caractere, opção do pergunte (SX1) cliente de?. Obtido do parâmetro MV_PAR01
@param cCliAt, caractere, opção do pergunte (SX1) cliente até?. Obtido do parâmetro MV_PAR02
@param dDtIni, data, opção obtida do pergunte (SX1) data de?. Obtido do parâmetro MV_PAR03
@param dDtFim, data, opção obtida do pergunte (SX1) data até?. Obtido do parâmetro MV_PAR04

/*/
//------------------------------------------------------------------------------
Function At960qry(lRateiaCtr,lMVGerOS,lContabil,lMultiFil,lIntRH,cWhereAtt,cCliDe,cCliAt,dDtIni,dDtFim)

Local cQuery := ""

If lRateiaCtr
	cQuery += " SELECT ABB.ABB_CODTEC, CNB.CNB_CC, AA1.AA1_CDFUNC, AA1.AA1_FUNFIL, ABB.ABB_LOCAL, "
	If lMVGerOS
		cQuery += " ABA_QUANT AS TOTAL " 
	Else
		cQuery += " ABB_HRTOT AS TOTAL " 
	EndIF
	If lContabil
		cQuery += ", CNB.CNB_ITEMCT, CNB.CNB_CLVL "	
	EndIf
	cQuery += " FROM " + RetSqlName("ABB") + " ABB "
	cQuery += " INNER JOIN " + RetSqlName("AA1") + " AA1 "
	cQuery += " ON AA1.AA1_CODTEC = ABB.ABB_CODTEC "
	If lMultiFil
		cQuery += " AND " + FWJoinFilial("ABB" , "AA1" , "ABB", "AA1", .T.) + " "
	EndIf
	cQuery += " AND AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
	cQuery += " AND AA1.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("ABQ") + " ABQ "
	cQuery += " ON ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM "
	If lMultiFil
		cQuery += " AND " + FWJoinFilial("ABB" , "ABQ" , "ABB", "ABQ", .T.) + " "
	Else
		cQuery += " AND ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "' "	
	EndIf
	cQuery += " AND ABQ.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("CNB") + " CNB "
	cQuery += " ON CNB.CNB_CONTRA = ABQ.ABQ_CONTRT "
	cQuery += " AND CNB.CNB_FILIAL = '" + xFilial('CNB') + "' "
	If lIntRH
		cQuery += " INNER JOIN " + RetSqlName("SRA") + " SRA "
		cQuery += " ON (SRA.RA_FILIAL = AA1.AA1_FUNFIL AND SRA.RA_MAT = AA1.AA1_CDFUNC AND SRA.D_E_L_E_T_ = ' ' ) "
	EndIf
	IF lMVGerOS
		cQuery += " INNER JOIN " + RetSqlName("AB9") + " AB9 "
		cQuery += " ON AB9.AB9_NUMOS = ABB.ABB_CHAVE "
		If lMultiFil
			cQuery += " AND " + FWJoinFilial("ABB" , "AB9" , "ABB", "AB9", .T.) + " "
		Else
			cQuery += " AND AB9.AB9_FILIAL = '" + xFilial("AB9") + "' "
		EndIf
		cQuery += " AND AB9.AB9_CODTEC = ABB.ABB_CODTEC "
		cQuery += " AND AB9.AB9_ATAUT = ABB.ABB_CODIGO "
		cQuery += " AND AB9.D_E_L_E_T_ = ' ' "
		cQuery += " INNER JOIN " + RetSqlName("ABA") + " ABA "
		cQuery += " ON ABA.ABA_NUMOS = AB9.AB9_NUMOS "
		If lMultiFil
			cQuery += " AND " + FWJoinFilial("AB9" , "ABA" , "AB9", "ABA", .T.) + " "
		Else
			cQuery += " AND ABA.ABA_FILIAL = '" + xFilial("ABA") + "' "
		EndIf
		cQuery += " AND ABA.ABA_CODTEC = AB9.AB9_CODTEC "
		cQuery += " AND ABA.ABA_SEQ = AB9.AB9_SEQ "
		cQuery += " AND ABA.ABA_NUMOS = AB9.AB9_NUMOS "
		cQuery += " AND ABA.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += " WHERE "
	cQuery += " ABB.ABB_CODTEC BETWEEN '" + AllTrim(cCliDe) + "' AND '" + AllTrim(cCliAt) + "' "
	If !lMultiFil
		cQuery += " AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
	EndIf
	If Len(cWhereAtt) > 0
		cQuery += " AND AA1.AA1_CODTEC IN ('"+ Substr(cWhereAtt, 1, Len(cWhereAtt)-1) + "') "
	EndIf
	cQuery += " AND ABB.ABB_DTINI >= '" + DToS(dDtIni) + "'AND ABB.ABB_DTFIM <= '" + DToS(dDtFim) + "' "
	If !lMVGerOS
		cQuery += " AND ABB.ABB_CHEGOU = 'S' "
	EndIf
	cQuery += " AND ABB.ABB_ATENDE = '1' "
	cQuery += " AND ABB.ABB_ATIVO = '1' "
	cQuery += " AND ABB.ABB_LOCAL <> ' ' "
	cQuery += " AND ABB.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY AA1.AA1_CDFUNC,ABB.ABB_LOCAL "
Else
	cQuery += " SELECT ABB.ABB_CODTEC, ABS.ABS_CCUSTO, AA1.AA1_CDFUNC, AA1.AA1_FUNFIL, ABB.ABB_LOCAL, "
	If lMVGerOS
		cQuery += " ABA_QUANT AS TOTAL " 
	Else
		cQuery += " ABB_HRTOT AS TOTAL " 
	EndIF
	If lContabil
		cQuery += ", ABS.ABS_ITEM, ABS.ABS_CLVL "	
	EndIf
	cQuery += " FROM " + RetSqlName("ABB") + " ABB "
	cQuery += " INNER JOIN " + RetSqlName("AA1") + " AA1 "
	cQuery += " ON AA1.AA1_CODTEC = ABB.ABB_CODTEC "
	If lMultiFil
		cQuery += " AND " + FWJoinFilial("ABB" , "AA1" , "ABB", "AA1", .T.) + " "
	EndIf
	cQuery += " AND AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
	cQuery += " AND AA1.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("ABS") + " ABS "
	cQuery += " ON ABS.ABS_LOCAL = ABB.ABB_LOCAL "
	If lMultiFil
		cQuery += " AND " + FWJoinFilial("ABB" , "ABS" , "ABB", "ABS", .T.) + " "
	Else
		cQuery += " AND ABS.ABS_FILIAL = '" + xFilial("ABS") + "' "	
	EndIf
	cQuery += " AND ABS.D_E_L_E_T_ = ' ' "
	If lIntRH
		cQuery += " INNER JOIN " + RetSqlName("SRA") + " SRA "
		cQuery += " ON (SRA.RA_FILIAL = AA1.AA1_FUNFIL AND SRA.RA_MAT = AA1.AA1_CDFUNC AND SRA.D_E_L_E_T_ = ' ' ) "
	EndIf
	IF lMVGerOS
		cQuery += " INNER JOIN " + RetSqlName("AB9") + " AB9 "
		cQuery += " ON AB9.AB9_NUMOS = ABB.ABB_CHAVE "
		If lMultiFil
			cQuery += " AND " + FWJoinFilial("ABB" , "AB9" , "ABB", "AB9", .T.) + " "
		Else
			cQuery += " AND AB9.AB9_FILIAL = '" + xFilial("AB9") + "' "
		EndIf
		cQuery += " AND AB9.AB9_CODTEC = ABB.ABB_CODTEC "
		cQuery += " AND AB9.AB9_ATAUT = ABB.ABB_CODIGO "
		cQuery += " AND AB9.D_E_L_E_T_ = ' ' "
		cQuery += " INNER JOIN " + RetSqlName("ABA") + " ABA "
		cQuery += " ON ABA.ABA_NUMOS = AB9.AB9_NUMOS "
		If lMultiFil
			cQuery += " AND " + FWJoinFilial("AB9" , "ABA" , "AB9", "ABA", .T.) + " "
		Else
			cQuery += " AND ABA.ABA_FILIAL = '" + xFilial("ABA") + "' "
		EndIf
		cQuery += " AND ABA.ABA_CODTEC = AB9.AB9_CODTEC "
		cQuery += " AND ABA.ABA_SEQ = AB9.AB9_SEQ "
		cQuery += " AND ABA.ABA_NUMOS = AB9.AB9_NUMOS "
		cQuery += " AND ABA.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += " WHERE "
	cQuery += " ABB.ABB_CODTEC BETWEEN '" + AllTrim(cCliDe) + "' AND '" + AllTrim(cCliAt) + "' "
	If !lMultiFil
		cQuery += " AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
	EndIf
	If Len(cWhereAtt) > 0
		cQuery += " AND AA1.AA1_CODTEC IN ('"+ Substr(cWhereAtt, 1, Len(cWhereAtt)-1) + "') "
	EndIf
	cQuery += " AND ABB.ABB_DTINI >= '" + DToS(dDtIni) + "'AND ABB.ABB_DTFIM <= '" + DToS(dDtFim) + "' "
	If !lMVGerOS
		cQuery += " AND ABB.ABB_CHEGOU = 'S' "
	EndIf
	cQuery += " AND ABB.ABB_ATENDE = '1' "
	cQuery += " AND ABB.ABB_ATIVO = '1' "
	cQuery += " AND ABB.ABB_LOCAL <> ' ' "
	cQuery += " AND ABB.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY AA1.AA1_CDFUNC,ABB.ABB_LOCAL "
EndIf

Return cQuery


//------------------------------------------------------------------------------
/*/{Protheus.doc} A960VldPrR
	Valida a Programação de Rateio

@sample 	A960VldPrR() 

@since		25/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Function A960VldPrR(aAtend,aTot,cCompt,nSobrR,nProc,nGerLg,oProcess,cTpExp, nHandle, lCab)

Local aRat		:= {}
Local nX		:= 0
Local nZ		:= 0
Local cPerc	:= "99."
Local lAdd		:= .T.

Default cTpExp := "1"
Default nHandle := 0
Default lCab := .F.

For nZ := 1 to (TamSx3("RHQ_PERC")[2])
 cPerc += '9'
Next

If nProc == 1 //Envio

	For nX := 1 to Len(aAtend)
		
		If oProcess <> Nil
			oProcess:SetRegua1(nX)
		EndIf
		
		nPos := aScan(aTot,{|x| x[1] == aAtend[nX][1]})
		If nPos > 0
			nTotal := ((aAtend[nX][2]*100)/aTot[nPos][2])
			If nTotal <> 100
				nPos := aScan(aRat,{|x| x[1] == aAtend[nX][5] .AND. x[2] == aAtend[nX][6] })
				If nPos > 0
					aAdd(aRat[nPos][3],{cCompt,aAtend[nX][4],nTotal,;
			                            aAtend[nX][7],;
										aAtend[nX][8]})
				Else
					aAdd(aRat,{aAtend[nX][5], aAtend[nX][6],{{cCompt,aAtend[nX][4],nTotal,;
					                                          aAtend[nX][7],;
															  aAtend[nX][8]}}})
				EndIf
			Else
				lAdd := .T.
				If ("1" $ cTpExp)
					lAdd := .F.
					DbSelectArea("SRA")
					DbSetOrder(1)//RA_FILIAL + RA_MAT
					If SRA->(DbSeek(aAtend[nX][6]+aAtend[nX][5]))
						lAdd :=  aAtend[nX][4] <> SRA->RA_CC
					EndIf
				Else
					lAdd := .T.
				EndIf
				If lAdd
					aAdd(aRat,{aAtend[nX][5], aAtend[nX][6],{{cCompt,aAtend[nX][4],Val(cPerc),;
															 aAtend[nX][7],;
															 aAtend[nX][8]}}})
				EndIf
			EndIf
		EndIf
	
	Next nX

	A960ProRat(aRat,nSobrR,cCompt,nGerLg,nProc,oProcess,cTpExp, nHandle, lCab)
			
	
ElseIf nProc == 2 //Estorno

	If "1" $ cTpExp
		At960EstRt(aAtend,cCompt,nProc,nGerLg)
	EndIf
	
	If "2" $ cTpExp
		ExecBlock("At960EsRt", .F., .F., {MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05,MV_PAR06, MV_PAR07, MV_PAR08, aAtend, lCab })
	EndIf
EndIf

aAtend := {}

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} A960ProRat
	Envio da Programação de Rateio

@sample 	A960ProRat() 

@since		26/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Function A960ProRat(aRat,nSobrR,cCompt,nGerLg,nProc,oProcess,cTpExp, nHandle, lCab)

Local oModel	:= FwLoadModel("GPEA056")
Local lRet		:= .T.
Local lSobrEs	:= .F.
Local lExist	:= .F.
Local cProgRt	:= ""
Local aErro	:= {}
Local nW		:= 0
Local nY		:= 0
Local cFilBkp := cFilAnt
Local aErroPe	:= {}
Local aCab := {}
Local aItens := {}
Local aItensT:= {}
Local nT := 0
Local lRetVl := .T.
Local aRetPE := {}
Local lRhRM := SuperGetMv("MV_GSXINT",,"2") == "3"
Local oWS := nil
Local aRMnoProc := {}
Local cXML := ""
Local cError := ""
Local aEmpFil := {}
Local cAuxCC
Local nAuxCC := 0
Local nDiff
Local nAux
Local lErrorRM := .F.
Local lContabil	:= TecEntCtb("ABS")
Local lPergRtCtB  := TecHasPerg("MV_PAR09", "TECA960")  // Verifique se existe o pergunte (SX1) "Rateia Contrato?"

Default cTpExp := "1"
Default nHandle := 0
Default lCab := .F.

For nY := 1 To Len(aRat)

	lRet	:= .T.
	lErrorRM := .F.
	
	If oProcess <> Nil
		oProcess:IncRegua2(STR0012 + aRat[nY][1] + STR0013 )			////"Aguarde... Processando o rateio do "#'...'
	EndIf
		
		
	If "1" $ cTpExp	
		If !lRhRM
			DbSelectArea("RHQ")
			DbSetOrder(1) //RHQ_FILIAL+RHQ_MAT+RHQ_DEMES
			If RHQ->(DbSeek(aRat[nY][2]+aRat[nY][1]+cCompt))
				cProgRt := aRat[nY][2]+aRat[nY][1]+cCompt
				lExist := .T.
				If nSobrR == 1 //Sim
					lSobrEs := .T.
				ElseIf nSobrR == 2 //Não
					lSobrEs := .F.	
				EndIf
			EndIf
		
			If lSobrEs //Se Sobreescreve sim
				While RHQ->(!EOF()) .AND. cProgRt == RHQ_FILIAL+RHQ_MAT+RHQ_DEMES
					RecLock("RHQ",.F.)
					RHQ->(DbDelete())			//deleta item
					RHQ->(MsUnLock())
					RHQ->(DbSkip())
				End
			Else
				If lExist //Se Existe
					lRet := .F.
					lExist := .F.
				EndIf
			EndIf
		Else
			cError := ""
			aEmpFil := GSItEmpFil(, ,  'RM', .T., .F., @cError)
			If !EMPTY(aEmpFil)
				lExist := .F.
				If oWS == nil
					oWS :=  GSItRMWS('RM', .F., @cError)
					oWS:cDataServerName := "FopRateioFixoData"
				EndIf
				oWS:cFiltro := "PFRATEIOFIXO.Chapa='" + Alltrim(aRat[nY][1]) + "'"
				If oWS:ReadView()
					cXML:= oWS:cReadViewResult
					If !EMPTY(cXML)
						If Empty(cError)
							If AT("PFRATEIOFIXO", UPPER(cXML)) > 0
								lExist := .T.
								If nSobrR == 1
									oWS:cFiltro := ""
									oWS:cXML := oWS:cReadViewResult
									If !(oWS:DeleteRecord())
										AADD(aRMnoProc, aRat[nY][1])
										lRet := .F.
										lErrorRM := .T.
									EndIf
								EndIf
							Else
								lExist := .F.
							EndIf
						Else
							AADD(aRMnoProc, aRat[nY][1])
							lRet := .F.
							lErrorRM := .T.
						EndIf
					Else
						AADD(aRMnoProc, aRat[nY][1])
						lRet := .F.
						lErrorRM := .T.
					EndIf
					cXML := ""
				Else
					AADD(aRMnoProc, aRat[nY][1])
					lRet := .F.
					lErrorRM := .T.
				EndIf
				FreeObj(oWS)
				oWS := NIL
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	If lRet
		
		aCab := {}
		aItens := {}
		aErroPE := {}
		If !Empty(aRat[nY][2])
			cFilBkp := cFilAnt
			cFilAnt := aRat[nY][2]
			iF lPergRtCtB 
			    If MV_PAR09 == 1
			        cFilAnt := cFilBkp
				Endif 
			Endif
		EndIf
		lRetVl := .T.
		
		aAdd(aCab,{ "RA_MAT", aRat[nY][1] })
		aAdd(aCab, { "RA_FILIAL", aRat[nY][2]})
	
		For nW := 1 To Len(aRat[nY][3])	
			aItensT := {}		
		    aAdd( aItensT, {"RHQ_DEMES",aRat[nY][3][nW][1]})//cCompt)
			aAdd( aItensT, {"RHQ_AMES" ,aRat[nY][3][nW][1]})//cCompt)
			aAdd( aItensT, {"RHQ_CC"   ,aRat[nY][3][nW][2]})//cCentCust)
			aAdd( aItensT, {"RHQ_PERC" ,aRat[nY][3][nW][3]})//nTotal)	
			If lContabil
				aAdd( aItensT, {"RHQ_ITEM" ,aRat[nY][3][nW][4]})//nTotal)	
				aAdd( aItensT, {"RHQ_CLVL" ,aRat[nY][3][nW][5]})//nTotal)	
			EndIf
			
			aAdd(aItens, aClone(aItensT))
		Next nW
		
		If lRhRM
			For nW := 1 To LEN(aItens)
				aItens[nW][4][2] := ROUND(aItens[nW][4][2],2)
				nAuxCC += aItens[nW][4][2]
			Next nW
			If nAuxCC != 100
				nDiff := ABS(nAuxCC - 100)
				nAux := 1
				While nDiff != 0
					If nAuxCC < 100
						aItens[nAux][4][2] += 0.01
					Else
						aItens[nAux][4][2] -= 0.01
					EndIf
					nAux++
					If nAux > LEN(aItens)
						nAux := 1
					EndIf
					nDiff -= 0.01
				End
			EndIf
		EndIf
		
		If "1" $ cTpExp	
			If !lRhRM
				DbSelectArea("SRA")
				SRA->(DbSetOrder(1)) //RA_FILIAL + RA_MAT
				SRA->(DbSeek(aRat[nY][2]+aRat[nY][1]))
	
				Inclui := .F.
				Altera := .T.
		
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				oModel:Activate()
			
				If oModel:GetModel( "RHQDETAIL" ):Length() > 1 .OR. !Empty(oModel:GetValue("RHQDETAIL", "RHQ_DEMES"))
					oModel:GetModel("RHQDETAIL"):AddLine()
				EndIf
			
				For nW := 1 To Len(aItens)
					If nW > 1
						If oModel:GetModel("RHQDETAIL"):AddLine() <> nW
							lRetVl := .F.
							Exit
						EndIf
					EndIf			
					For nT := 1 to Len(aItens[nT])
						oModel:SetValue("RHQDETAIL", aItens[nW][nT][01], aItens[nW][nT][02])//cCompt)
					Next nT	
				Next nW
				
				If ( lRetVl := oModel:VldData() ) //Validação dos dados
					
					// Se o dados foram validados faz-se a gravação efetiva dos
					// dados (commit)
					oModel:CommitData()
					
					aErro := {}
				EndIf
			
				If !lRetVl
					aErro := oModel:GetErrorMessage()
				EndIf
			
				oModel:DeActivate()
				
				lRet := lRetVl
			Else
				If ((lExist .AND. nSobrR == 1) .OR. !lExist) .AND. !EMPTY(aItens)
					If !lErrorRM
						cXml := "<FopRateioFixo>"
						For nW := 1 to LEN(aItens)
							cXml += "<PFRATEIOFIXO>"
								cXml += "<CODCOLIGADA>" + aEmpFil[1] + "</CODCOLIGADA>"
								cXml += "<CHAPA>" + ALLTRIM(aCab[ASCAN(aCab, {|a| a[1] == "RA_MAT"})][2]) + "</CHAPA>"
								cXml += "<CODCCUSTO>"
								cAuxCC := Alltrim(GSItCC(,,'RM', aItens[nW][ASCAN(aItens[nW], {|a| a[1] == "RHQ_CC"})][2], .F., @cError))
								If rAT("|", cAuxCC) > 0
									cAuxCC := SUBSTR(cAuxCC, RAT("|",cAuxCC)+1 )
								EndIf
								cXml += (cAuxCC+"</CODCCUSTO>")
								cXml += "<VALOR>" + STRTRAN(cValToChar(aItens[nW][ASCAN(aItens[nW], {|a| a[1] == "RHQ_PERC"})][2]),".",",") + "</VALOR>"
								cXml += "<Descricao>" + Alltrim(POSICIONE("CTT",1,xFilial("CTT") + aItens[nW][ASCAN(aItens[nW], {|a| a[1] == "RHQ_CC"})][2], "CTT_DESC01")) + "</Descricao>"
							cXml += "</PFRATEIOFIXO>"
						Next nW
						cXml += "</FopRateioFixo>"
						oWS :=  GSItRMWS('RM', .F., @cError)
						If EMPTY(cError) .AND. VALTYPE(oWS) == 'O' 
							oWS:cDataServerName := "FopRateioFixoData"
							oWS:cXML := cXml
							If !(oWS:SaveRecord())
								AADD(aRMnoProc, ALLTRIM(aCab[ASCAN(aCab, {|a| a[1] == "RA_MAT"})][2]))
								lErrorRM := .T.
							ElseIf AT(REPLICATE("=",4), oWS:cSaveRecordResult ) > 0
								AADD(aRMnoProc, ALLTRIM(aCab[ASCAN(aCab, {|a| a[1] == "RA_MAT"})][2]))
								cError := STRTRAN(LEFT(oWS:cSaveRecordResult, AT(REPLICATE("=",4), oWS:cSaveRecordResult )-1), CRLF)
								lErrorRM := .T.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		
		If "2" $ cTpExp
			aRetPE := ExecBlock("At960PrRt", .F., .f., {aCab,aItens,3,lCab , @aErroPE}) 
			If ValType(aRetPE) = "A" .AND. Len(aRetPE) >= 1 .AND. !aRetPE[1] 
				lRet := .F.
				If Len(aErro) = 0
					aErro := Array(9)
					aFill(aErro, "")
					aErro[1] := "GPEA056"
				EndIf
				If ValType(aRetPE[2])== "C"
					aErro[6] += IIF( !Empty(aErro[6]),  CRLF, "") + aRetPE[2]
				EndIf
			EndIf
		EndIf
	
		If "3" $ cTpExp
			lRet := At960MCSV(aCab, aItens, nHandle, lCab) .AND. lRet
		EndIf
	
		If cFilBkp <> cFilAnt
			cFilAnt := cFilBkp
		EndIf
	
	Else
		If EMPTY(cError)
			cError := STR0042//"Erro ao processar Integração RH Protheus."
		EndIf
		aErro := Array(9)
		aFill(aErro, "")
		aErro[1] := "GPEA056"
		aErro[6] := {cError}
	EndIf
	
	If lRet .AND. lErrorRM
		If EMPTY(cError)
			cError := STR0042//"Erro ao processar Integração RH Protheus."
		EndIf
		aErro := Array(9)
		aFill(aErro, "")
		aErro[1] := "GPEA056"
		aErro[6] := {cError}
	EndIf
	
	At960GrLg(aErro,aRat[nY][2], aRat[nY][1],IIF(lRet,STR0014 ,STR0015),nGerLg,cCompt,nProc,.F.,aRMnoProc,aItens) //"Programação de Rateio Enviada com sucesso"##"Erro no envio da programação de Rateio"
		
Next nY


Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At960EstRt
	Estorno da Programação de Rateio

@sample 	At960EstRt() 

@since		26/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At960EstRt(aAtend,cCompt,nProc,nGerLg,oProcess)

Local nX := 0
Local aErro := {}
Local oModel	:= FwLoadModel("GPEA056")
Local lOk 	:= .T.
Local lRhRM := SuperGetMv("MV_GSXINT",,"2") == "3"
Local oWS := nil
Local cError := ""
Local aProcs := {}
Local cFilBkp := ""
Local lPergRtCtC  := TecHasPerg("MV_PAR09", "TECA960")  // Verifique se existe o pergunte (SX1) "Rateia Contrato?"

DbSelectArea("RHQ")
DbSelectArea("SRA")

For nX := 1 To Len(aAtend)
	
	cError := ""
	
	If oProcess <> Nil
		oProcess:IncRegua2(STR0016 + aAtend[nX][5] + STR0013 )		//"Aguarde... Excluindo a programação de rateio do "#'...'
	EndIf

	RHQ->( DbSetOrder(1) ) //RHQ_FILIAL+RHQ_MAT+RHQ_DEMES
	SRA->( DbSetOrder(1) ) // RA_FILIAL + RA_MAT
	
	Inclui := .F.
	Altera := .F.
	If !lRhRM

        cFilBkp := aAtend[nX][6]

		iF lPergRtCtC .And. (cFilBkp != cFilAnt)
		   if MV_PAR09 == 1 
	          cFilBkp := cFilAnt 
		   Endif
		Endif   

		If SRA->(DbSeek(aAtend[nX][6]+aAtend[nX][5]))  .And. ;
			RHQ->(DbSeek(cFilBkp+aAtend[nX][5]+cCompt))
			
			cAtend := aAtend[nX][6]+aAtend[nX][5]+cCompt
			nNEnv++
			aErro := {}
			
			oModel:SetOperation(MODEL_OPERATION_DELETE)
			lOk := oModel:Activate()
			
			If lOk 
				lOk := oModel:VldData() .And. oModel:CommitData()
				
				If !lOk 
					aErro := oModel:GetErrorMessage()
				EndIf
				
				At960GrLg(aErro,aAtend[nX][6],aAtend[nX][5],STR0017,nGerLg,cCompt,nProc,.F.)		//"Programação de Rateio Excluída com sucesso"
				
				oModel:DeActivate()	
			EndIf
		EndIf
	Else
		aErro := {}
		
		If ASCAN(aProcs, Alltrim(aAtend[nX][5])) == 0
			If oWS == nil
				oWS :=  GSItRMWS('RM', .F., @cError)
				oWS:cDataServerName := "FopRateioFixoData"
			EndIf
			oWS:cFiltro := "PFRATEIOFIXO.Chapa='" + Alltrim(aAtend[nX][5]) + "'"
			If oWS:ReadView()
				oWS:cFiltro := ""
				If AT("PFRATEIOFIXO", UPPER(oWS:cReadViewResult)) > 0
					oWS:cXML := oWS:cReadViewResult
					If oWS:DeleteRecord()
						nNEnv++
					Else
						cError := STR0045 + Alltrim(aAtend[nX][5]) //"Erro ao executar o método 'DeleteRecord' para o atendente de matrícula " 
					EndIf
				EndIf
				FreeObj(oWS)
				oWS := NIL
			Else
				cError := STR0044 + Alltrim(aAtend[nX][5]) //"Erro ao executar o método 'ReadView' para o atendente de matrícula " 
			EndIf
			AADD(aProcs, Alltrim(aAtend[nX][5]))
			If !EMPTY(cError)
				aErro := Array(9)
				aFill(aErro, "")
				aErro[1] := "GPEA056"
				aErro[6] := {cError}
			EndIf
			At960GrLg(aErro,aAtend[nX][6],aAtend[nX][5],STR0017,nGerLg,cCompt,nProc,.F.)		//"Programação de Rateio Excluída com sucesso"
		EndIf
	EndIf

Next nX

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At960Cfol
	Realiza a conversão da competencia na folha

@sample 	At960Cfol() 

@since		24/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At960Cfol(cCompFolh)

Local cAno		:= ""
Local cMes		:= ""
Local cRet		:= ""

cAno := SubStr(cCompFolh,4,7)
cMes := SubStr(cCompFolh,1,2)

cRet := cMes+cAno

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At960VlPrg
	Validação dos perguntes

@sample 	At960VlPrg() 

@since		24/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At960VlPrg(dDtIni,dDtFim,cCompt, aErro)

Local lRet := .T.
Local cMsg := ""

If Empty(dDtIni)
	cMsg += (CRLF + STR0019)		//"Preencha a data inicial"
	lRet := .F.
EndIf

If Empty(dDtFim)
	cMsg += (CRLF + STR0020)			//"Preencha a data final"
	lRet := .F.
EndIf

If Alltrim(cCompt) == "/" 
	cMsg += (CRLF + STR0021)		//"Preencha o campo competência"
	lRet := .F.
EndIf

If !lRet
	cMsg := Substr(cMsg, Len(CRLF))
	Help("", 1, "At960VlPrg", cMsg,  1, 0)
	aAdd(aErro, cMsg)
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At960GrLg
	Geração dos Logs

@sample 	At960GrLg() 

@since		24/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At960GrLg(aErro,cFilFun, cCodFunc,cMsg,nGerLg,cCompt,nProc,lFim, aRMnoProc,aItens)

Local cTexto	:= ""		
Local cNome		:= ""
Local nX		:= 0
Local nT		:= 0

Default aErro 		:= {}
Default cCodFunc	:= ""
Default aRMnoProc 	:= {}
Default aItens		:= {}

If !Empty(cCodFunc)
	cNome	:= Alltrim(Posicione("SRA",1,cFilFun+cCodFunc,"SRA->RA_NOME"))
EndIf

If !lFim
	
	cTexto := STR0022+cFilFun+"/"+cCodFunc+STR0023+cNome+" "+STR0035+cCompt+CRLF		//"Funcionário: "##" - "##"Competência: "##
	
	If nProc == 1		////Processamento Envio
	
		If Len(aErro) > 0
			nNEnv++
			cTexto +=	" "+CRLF+cMsg+CRLF;
						+" "+CRLF+STR0024+'['+ AllToChar( aErro[1] )+']'+CRLF;	//"Id do formulário de origem:"
						+" "+STR0025+'['+ AllToChar( aErro[2] ) +']'+CRLF;		//"Id do campo de origem: "
						+" "+STR0026+'['+ AllToChar( aErro[3] ) +']'+CRLF;		//"Id do formulário de erro: "
						+" "+STR0027+'['+ AllToChar( aErro[4] ) +']'+CRLF;		//"Id do campo de erro: "
						+" "+STR0028+'['+ AllToChar( aErro[5] ) +']'+CRLF;		//"Id do erro: "
						+" "+STR0029+'['+ AllToChar( aErro[6] ) +']'+CRLF;		//"Mensagem do erro: "
						+" "+STR0030+'['+ AllToChar( aErro[7] ) +']'+CRLF;		//"Mensagem da solução: "
						+" "+STR0031+'['+ AllToChar( aErro[8] ) +']'+CRLF;		//"Valor atribuído: "
						+" "+STR0032+'['+ AllToChar( aErro[9] ) +']'+CRLF;		//"Valor anterior: "
	    				+CRLF+"---------------------------------------------------"+CRLF+CRLF
			For nX := 1 To Len(aItens)	
				cTexto += "---------------------------------------------------"+CRLF+CRLF		
				For nT := 1 to Len(aItens[nX])
					If Alltrim(aItens[nX][nT][01]) == "RHQ_CC" .And. Empty(AllToChar( aItens[nX][nT][02] ))
						cTexto += aItens[nX][nT][01] +'['+ AllToChar( aItens[nX][nT][02] )+']' +" - "+ STR0047 + CRLF //"Verifique o centro de custo no local de atendimento"
					Else
						cTexto += aItens[nX][nT][01] +'['+ AllToChar( aItens[nX][nT][02] )+']'+CRLF
					EndIf	
				Next nT	
				cTexto += +CRLF+"---------------------------------------------------"+CRLF+CRLF
			Next nX 				
		Else
		
			nEnv++
			If nGerLg == 1
				cTexto +=	" "+CRLF+cMsg+CRLF;
							+CRLF+"---------------------------------------------------"+CRLF+CRLF
			EndIf
			
		EndIf
		
	Else	//Processamento Estorno
		
		cTexto +=	" "+CRLF+cMsg+CRLF;
		+CRLF+"---------------------------------------------------"+CRLF+CRLF
	
	EndIf

Else
	cTexto :=	STR0033+cValToChar(nEnv)+CRLF;			//"Enviadas: "
				+STR0034+cValToChar(nNEnv)+CRLF;		//"Não Enviadas: "
				+CRLF+"---------------------------------------------------"+CRLF+CRLF	
EndIf	
	
	If !EMPTY(aRMnoProc)
		cTexto += CRLF+"---------------------------------------------------"
		cTexto += STR0046 + CRLF + CRLF //"As seguintes matrículas não foram processadas: " 
		For nX := 1 TO LEN(aRMnoProc)
			cTexto += aRMnoProc[nX] + CRLF
		Next nX
	EndIf
	
	TxLogFile("ProgRateio",cTexto)

Return


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At960MCSV
@description Gera o Arquivo CSV das Marcações
@param aCabec: Array Contendo a filial e matricula do atendente
@param aItens:Array de Marcaçoes do atendende do Atendimento que será atualizado
@param nHandle:Handle do Arquivo
@param lCab:Gera o cabeçalho da marcação
@return aRetInc: Array de Retorno da Inclusao onde 
		aRetInc[1]  - .t. //sUCESSO
		aRetInc[2]  - Array contendo a mensagem de sucesso/ erro
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At960MCSV(aCabec, aItens, nHandle, lCab)
Local cCab 		:= ""
Local cDetCab 	:= ""
Local cLinha 	:= ""
Local cDetLinha := ""
Local nC 		:= 0
Local nY 		:= 0

For nC := 1 to len(aCabec)
	cCab += AllTrim(aCabec[nC, 01]) +";"
	cDetCab += Alltrim(IIF( ValType(aCabec[nC, 02])<> "D",cValToChar(aCabec[nC, 02])  , DtoS(aCabec[nC, 02])))+";"
Next nC 

For nC := 1 to Len(aItens)

	cLinha := cCab
	cDetLinha := cDetCab 
	For nY := 1 to Len(aItens[nC])
		cLinha += AllTrim(aItens[nC, nY, 01])+";"
		cDetLinha +=  Alltrim(IIF( ValType(aItens[nC, nY, 02])<> "D",cValToChar(aItens[nC, nY, 02])  , DtoS(aItens[nC, nY, 02])))+";"	
	Next nY
	If lCab	
		cLinha := Substr(cLinha, 1, Len(cLinha)-1) + CRLF		
		fWrite(nHandle, cLinha)
		lCab := .f.
	EndIf
	
	cDetLinha := Substr(cDetLinha, 1, Len(cDetLinha)-1) + CRLF
	fWrite(nHandle, cDetLinha)
Next nC

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At960RHD
@description  Retorna o Diretório de Exportação do Arquivo CSV da Integração RH
@author 		fabiana.silva
@since 			03.05.2019
@version 		12.1.25
@return cDirArq - Diretório do server a ser gerado o arquivo
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At960RHD()
Local cDirArq := SuperGetMV("MV_GSRHDIR", .F., "")

If !Empty(cDirArq) .AND. Right(cDirArq, 1) <> "\"
	cDirArq += "\"
EndIf

If !Empty(cDirArq) .AND. Left(cDirArq, 1) <> "\"
	cDirArq := "\" +cDirArq
EndIf

Return cDirArq
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At960RHF
@description Gera o Arquivo CSV das Marcações
@author 		fabiana.silva
@since 			03.05.2019
@version 		12.1.25
@param cRotina: Prefixo da rotina/aquivo
@param cDirArq:Diretóirio de gravação do arquivo
@param lDelete: Exclui arquivo caso ele exista?
@param nOpc: Opção da Rotina Automática 
@return nHandle - Handle do Arquivo Gerado
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At960RHF(cRotina, cDirArq, lDelete, nOpc)
Local nHandle 	:= 0
Local aDir 		:= {}
Local nC 		:= 0
Local cDirTmp 	:= ""


If !ExistDir(cDirArq)
	aDir := StrTokArr(cDirArq, "\")
	For nC := 1 to Len(aDir)
		cDirTmp += "\" +aDir[nC] +"\"
		MakeDir(cDirTmp)
	Next nC 
EndIf
	
cNomeArq := cDirArq+cRotina+"_"+LTrim(Str(nOpc))+"_"+Dtos(Date())+"_"+StrTran(Time(), ":")+".csv" 

If File(cNomeArq)
	If lDelete
		fErase(cNomeArq)
	Else
		nHandle := FOpen(cNomeArq, FO_READWRITE)
		FSeek(nHandle, 0, 2)
	EndIf
EndIf
If nHandle = 0
	nHandle := fCreate(cNomeArq)
EndIf

Return nHandle
