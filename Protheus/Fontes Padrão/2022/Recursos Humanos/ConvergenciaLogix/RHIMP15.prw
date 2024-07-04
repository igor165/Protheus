#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RHIMP15.CH"

/*##*************#*****************************************************************
***********************************************************************************
***********************************************************************************
***Funcão..: RHIMP15.prw Autor:Leandro Drumond Data: 08/12/2012                 ***
***********************************************************************************
***Descrição..:Responsável pela importação de Férias.						    #**
***********************************************************************************
***Uso........:        			 									            ***
***********************************************************************************
***Parâmetros.:		cFileName, caractere, nome do arquivo       	      	    ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***********************************************************************************
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
***Paulo  O. I.|26/07/17|      |Tratamento para alterar status dos periodos     ***
***............|........|......|aquisitivos invalidos                           ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP15
Responsável pela importação de Férias.
@author Leandro Drumond
@since 08/12/2012
@version P11
@param cFileName, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
User Function RHIMP15(cFileName,aRelac,oSelf)	
	Local aAreas		:= {SRA->(GetArea()),SRV->(GetArea()),SRH->(GetArea()),SRR->(GetArea()),SRF->(GetArea())}
	Local aFuncImp		:= {}
	Local aPeriodo		:= {}
	Local aPDImp		:= {}
	Local aIndAux		:= {}
	Local cBuffer       := ""
	Local cEmpAux   	:= ""
	Local cFilAux    	:= ""
	Local cMatImp		:= ""
	Local cTipo			:= ""
	Local cEmpOri    	:= "##"
	Local lChangeEnv 	:= .F.
	Local cRoteiro		:= ""
	Local aCodFol		:= {}
	Local dData	
	Local aTabelas 		:= {"SRA","SRV","SRH","SRF","SRR","SRF"}
	Local lExiste		:= .F.
	Local lApag 		:= .T.
	Local lApagMov		:= .F.
	Local lPergApag		:= .T.
	Local aErro 		:= {}
	Local nTamMat		:= TAMSX3('RA_MAT')[1]
	Local nTamRvCod		:= TAMSX3('RV_COD')[1]
	Local aEmpresas		:= {}
	Local aTemp			:= {} 
	Local nI			:= 0
	Local nY			:= 0
	Local nX			:= 0
	Local nJ			:= 0
	Local nPos			:= 0
	Local aLinha		:= {}
	Local aCodFolAux	:= {}
	Local aFilAux		:= {}
	Local aFiltro		:= {}
	Local cChave := ''
	Private cFiltro		:= ""
	Private lPar05		:= .T.//GPECONV
	Private cAnoMes 	:= "" //GPECONV
	Private cPeriodo	:= ""
	Private cSemana		:= "01"	
	DEFAULT aRelac		:= {}
		
	/*Ordem dos campos no array que sera montado com base na linha do TXT ferias_logix.unl
	01 - IDENTIFICADOR = 1 (Cabecalho)
	02 - * - Empresa Protheus
	03 - RH_FILIAL 	- Filial Protheus
	04 - RH_MAT 	- Matrícula
	05 - RH_DATABAS	- Inicio do Periodo Aquisitivo
	06 - RH_DBASEAT	- Fim do Periodo Aquisitivo
	07 - RH_DFALTAS	- Dias de Falta
	08 - RH_DFERIAS	- Dias de Gozo
	09 - RH_DABONPE	- Dias de Abono
	10 - RH_DATAINI	- Data Inicio de Gozo
	11 - RH_DATAFIM - Data Final de Gozo
	12 - RH_TIPCAL 	- Tipo do cálculo de ferias
	13 - RH_PERC13S - Percentual Adiantamento de 13o Salario
	14 - RH_DIALREM	- Dias de Licenca Remunerada - 1o Mes
	15 - RH_DIALRE1	- Dias de Licenca Remunerada - 2o Mes
	16 - RH_SALMES	- Salario Mes
	17 - RH_SALDIA	- Salario Dia
	18 - RH_SALHRS	- Salario Hora
	19 - RH_DTRECIB - Data do Recibo de Ferias
	20 - RH_DTAVISO - Data do Aviso de Ferias
	
	// Excluido - Essas mesmas informacoes vem na folha e estavam
	//            sendo lancadas em duplicidade
	01 - IDENTIFICADOR = 2 (Itens)
	02 - * - Empresa Protheus
	03 - RD_FILIAL 	- Filial Protheus
	04 - RD_MAT 	- Matrícula
	05 - RD_PD		- Verba
	06 - RD_DATARQ	- Data de Referencia
	07 - RD_CC		- Centro de Custos
	08 - RD_TIPO1	- Tipo de Verba
	09 - RD_HORAS 	- Quantidade Calculada
	10 - RD_VALOR 	- Valor da Verba
	11 - RD_DATPGT  - Data de Processamento
	12 - RR_DATAPAG	- Data de Pagamento
	13 - RD_DEPTO   - Departamento
	14 - RD_ITEM    - ITEM
	15 - RD_INSS 	- Incidencia INSS
	16 - RD_IR   	- Incidencia IR
	17 - RD_FGTS	- Incidencia FGTS
	
	01 - IDENTIFICADOR = 3 (Periodo aquisitivo)
	02 - * - Empresa Protheus
	03 - RF_FILIAL 	- Filial Protheus
	04 - RF_MAT 	- Matricula
	05 - RF_ADMISSA - Data de Admissão
	06 - RF_DATABAS - Data do Período Aquisitivo em aberto
	07 - RF_DFERANT - Dias de Férias já antecipadas
	08 - RF_PERC13S - Percentual de 13º Salário
	09 - RF_TEMABPE - Possui abono na Programação
	10 - RF_DATAINI - Data de Início da 1ª Programação
	11 - RF_DFEPRO1 - Quantidade de Dias de Gozo da 1ª Programação
	12 - RF_DABPRO1 - Quantidade de Dias de Abono da 1ª Programação
	*/
	
	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	
	While !FT_FEOF() .And. !lStopOnErr
		cBuffer := FT_FREADLN()
		
		/*Checa se deve parar o processamento.*/				
		U_StopProc(aErro)
		U_StopProc(aFuncImp)
		U_StopProc(aPDImp)
		
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		
		cTipo	  := aLinha[1]
		cEmpAux   := aLinha[2]
		cFilAux   := aLinha[3]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpAux := u_GetCodDP(aRelac,"FILIAL",aLinha[3],"FILIAL",aLinha[2],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilAux	:= u_GetCodDP(aRelac,"FILIAL",aLinha[3],"FILIAL",aLinha[2],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf		
		
		U_RHPREARE(cEmpAux,cFilAux,'','',@lChangeEnv,@lExiste,"GPEA250",aTabelas,"GPE",@aErro,OemToAnsi(STR0001))
		If lChangeEnv
			SRV->(DbSetOrder(1))
			SRH->(DbSetOrder(1))			
			fp_CodFol( @aCodFol , xFilial("SRV"), .T., .F. )
			If(cEmpOri != cEmpAux)
				lApag := .T.
				cEmpOri := cEmpAux
				aAdd(aEmpresas,cEmpOri)
				aAdd(aCodFolAux,aCodFol)
			EndIf			
			cRoteiro := fGetCalcRot("3")//FER			
		EndIf
		
		If lApag .and. ExistReg(cRoteiro)
			If lApagMov .or. ( lPergApag .and. MsgYesNo(OemToAnsi(STR0002))) // Apaga Movimentação Anterior?
				fDelMov('SRR',cRoteiro)	//Exclui todos os registros tipo K (RR_TIPO2) da SRR
				fDelMov('SRH',cRoteiro)	//Exclui todos os registros da SRH
				fDelMov('SRF',cRoteiro)	//Exclui todos os registros da SRF
				lApagMov := .T.
			Else
				lPergApag := .F.
			EndIf
		EndIf
		
		lApag := .F.
		
		If lExiste
				
			If aScan(aFilAux,  { |x|  X[1] + X[2] == cEmpOri + cFilAux }) == 0
				aAdd(aFilAux, {cEmpOri , cFilAux})
			EndIf

			//Verifica existencia de DE-PARA
			If !Empty(aRelac)
				If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
					aCamposAux := U_fGetCpoMod("RHIMP15")
					aIndAux2   := {}
					For nY := 1 to 2
						aCampos := aClone(aCamposAux[nY])
						aIndAux := {}
						For nX := 1 to Len(aCampos)
							For nJ := 1 to Len(aRelac)
								If (nPos := (aScan(aRelac[nJ],{|x| AllTrim(x) == AllTrim(aCampos[nX,1])}))) > 0
									aAdd(aIndAux,{nX,aRelac[nJ,1]})
								EndIf 
							Next nJ
						Next nX
						aAdd(aIndAux2,aClone(aIndAux))
					Next nY
				EndIf
				If cTipo == "1"
					aIndAux := aClone(aIndAux2[1])
					aCampos := aClone(aCamposAux[1])
				Else
					aIndAux := aClone(aIndAux2[2])
					aCampos := aClone(aCamposAux[2])
				EndIf
				For nX := 1 to Len(aIndAux)
					aLinha[aIndAux[nX,1]] := u_GetCodDP(aRelac,aCampos[aIndAux[nX,1],1],aLinha[aIndAux[nX,1]],aIndAux[nX,2]) //Busca DE-PARA
				Next nX
			EndIf
			

			cMatImp	 := PadR(aLinha[4],nTamMat)
			
			U_IncRuler(OemToAnsi(STR0001),cMatImp + '-' + aLinha[IIF(aLinha[1] == '1',5,11)],cStart,.F.,,oSelf)
			
			If !(SRA->(DbSeek(xFilial("SRA")+cMatImp)))
				If !Empty(aFuncImp)
					If aScan(aFuncImp,  { |x|  X[1]+X[2]+X[3] == cEmpAux + cFilAux + cMatImp }) == 0
						aAdd(aFuncImp, {cEmpAux,cFilAux,cMatImp})
					EndIf
				Else
					aAdd(aFuncImp,{cEmpAux,cFilAux,cMatImp})
				EndIf
				FT_FSKIP()
				Loop
			else			
				
				nPos := aScan(aFiltro,{|x| x[1] == cEmpAux + xFilial("SRA")})
				if(nPos == 0)
					aAdd(aFiltro,Array(3))
					nPos := Len(aFiltro)
					aFill(aFiltro[nPos],"")
					aFiltro[nPos,1] := cEmpAux + xFilial("SRA")
				endIf
			
				if(cMatImp < aFiltro[nPos,2] .Or. Empty(aFiltro[nPos,2]))
					aFiltro[nPos,2] := cMatImp
				endIf
				if(cMatImp > aFiltro[nPos,3])
					aFiltro[nPos,3] := cMatImp
				endIf
			EndIf
			
			If cTipo == "2"
							
				cVerbImp := PadR(aLinha[5],nTamRvCod)
				
				If !SRV->(DbSeek(xFilial("SRV")+cVerbImp))
					If !Empty(aPDImp)
						If aScan(aPDImp,  { |x|  X[1]+X[2]+X[3] == cEmpAux + cFilAux + aLinha[5] }) == 0
							aAdd(aPDImp, {cEmpAux,cFilAux,aLinha[5]})
						EndIf
					Else
						aAdd(aPDImp,{cEmpAux,cFilAux,aLinha[5]})
					EndIf
					FT_FSKIP()
					Loop
				EndIf
				
			EndIf
			
			If cTipo == "1"
				
				dData := aLinha[10]
				
				//RH_FILIAL+RH_MAT+DTOS(RH_DATABAS)+DTOS(RH_DATAINI) 
				cChave := xFilial('SRH') + cMatImp
				cChave += DtoS(CtoD(aLinha[5]))
				cChave += DtoS(CtoD(aLinha[10]))			
				
				RecLock("SRH",!(SRH->(DbSeek(cChave))))			
				
				SRH->RH_FILIAL  := xFilial('SRH')
				SRH->RH_MAT     := cMatImp
				SRH->RH_DATABAS := CtoD(aLinha[5])
				SRH->RH_DBASEAT := CtoD(aLinha[6])
				SRH->RH_DFALTAS := U_VldValue(aLinha[7])
				SRH->RH_DFERIAS := U_VldValue(aLinha[8])
				SRH->RH_DABONPE := U_VldValue(aLinha[9])
				SRH->RH_DATAINI := CtoD(aLinha[10])
				SRH->RH_DATAFIM := CtoD(aLinha[11])
				SRH->RH_TIPCAL  := aLinha[12]
				SRH->RH_PERC13S := U_VldValue(aLinha[13])
				SRH->RH_DIALREM := U_VldValue(aLinha[14])
				SRH->RH_DIALRE1 := U_VldValue(aLinha[15])
				SRH->RH_SALMES  := U_VldValue(aLinha[16])
				SRH->RH_SALDIA  := U_VldValue(aLinha[17])
				SRH->RH_SALHRS  := U_VldValue(aLinha[18])
				SRH->RH_DFERVEN := 0
				SRH->RH_DTRECIB := CtoD(aLinha[19])
				SRH->RH_DTAVISO := CtoD(aLinha[20])
				SRH->RH_MEDATU  := 'S'
				SRH->RH_PERIODO := Anomes(CtoD(aLinha[10]))
				SRH->RH_PROCES := SRA->RA_PROCES
				SRH->RH_ROTEIR := cRoteiro
				SRH->RH_NPAGTO := cSemana				
				
				SRH->(MsUnLock())
				SRH->(DbSeek(xFilial("SRH")+ cMatImp))
				cPeriodo := SRH->RH_PERIODO 
				fGFerSR8( CtoD(aLinha[10]), CtoD(aLinha[11]) )			
				
			ElseIf cTipo == "2"
				
				nSeqSRR := fFindSeqSRR(cFilAux,cVerbImp,cMatImp,dtos(ctod(dData)))
				If !(cVerbImp == "M09")
					
					RecLock("SRR",SRRIsNew('F',Anomes(CtoD(dData)),cRoteiro,cSemana, cVerbImp, AllTrim(STR(nSeqSRR)), dtos(ctod(dData))))	
					
					SRR->RR_FILIAL  := xFilial('SRR')
					SRR->RR_MAT     := cMatImp
					SRR->RR_PD      := cVerbImp
					SRR->RR_CC      := aLinha[7]
					SRR->RR_TIPO1   := aLinha[8]
					SRR->RR_HORAS   := U_VldValue(aLinha[9])
					SRR->RR_VALOR   := U_VldValue(aLinha[10])
					SRR->RR_DATA    := CtoD(dData)
					SRR->RR_PERIODO := Anomes(CtoD(dData))
					SRR->RR_DATAPAG := CtoD(aLinha[12])
					SRR->RR_ITEM    := aLinha[14]
					SRR->RR_TIPO2   := 'K'
					SRR->RR_TIPO3   := 'F'
					SRR->RR_SEQ     := AllTrim(STR(nSeqSRR))
					SRR->RR_PROCES := SRA->RA_PROCES
					SRR->RR_ROTEIR := cRoteiro
					SRR->RR_SEMANA := cSemana
					
					SRR->(MsUnLock())
				EndIf
			EndIf
		Else			
			U_IncRuler(OemToAnsi(STR0001),aLinha[4] + '-' + aLinha[IIF(aLinha[1] == '1',5,11)],cStart,.T.,,oSelf)			
		EndIf
				
		FT_FSKIP()		
	EndDo
	FT_FUSE()	
	
	If !(Empty(aFuncImp))
		aSort(aFuncImp ,,, { |x,y| x[1]+x[2]+X[3] < y[1]+Y[2]+Y[3] } )
		aEval(aFuncImp,{|x|aAdd(aErro,'[' + x[1]+'/'+ x[2] + '/' + x[3] +']' + OemToAnsi(STR0003))})		
	EndIf
	
	if(Len(aPDImp) > 0)		
		aSort( aPDImp ,,, { |x,y| x[1]+x[2]+X[3] < y[1]+Y[2]+Y[3] } )
		aEval(aPDImp,{|x|aAdd(aErro,'['+ x[1] + '/' + x[2] + '/' + x[3] + ']' + OemToAnsi(STR0004))})		
	endIf
	
	cEmpOri := cEmpAnt	
	For nI:= 1 to Len(aEmpresas)
		cEmpAux := aEmpresas[nI]
		aCodFol	:= aCodFolAux[nI]		
		aTemp := u_PerInval()		
		aEval(aTemp,{|x|aAdd(aPeriodo,{cEmpAnt,x[1],x[2]})})
		aTemp := {}
		cAnoMes := SuperGetMv("MV_FOLMES",,AnoMes(dDataBase))
		//Remonta ambiente para geração dos dias de direito
		For nY := 1 to Len(aFilAux)
			cEmpAux := aFilAux[nY][1]
			cFilAux := aFilAux[nY][2]
			If aFilAux[nY][1] <> cEmpAnt
				U_RHPREARE(cEmpAux,cFilAux,'','',@lChangeEnv,@lExiste,"GPEA250",aTabelas,"GPE",{},OemToAnsi(STR0001))
				cEmpAnt := cEmpAux
				cFilAnt := cFilAux
			EndIf
			
			cFiltro := ""			
			nPos := aScan(aFiltro,{|x|x[1] == cEmpAux + xFilial("SRA")})
			
			if(nPos > 0)
				cFiltro := "AND SRA.RA_MAT BETWEEN '" + aFiltro[nPos,2] + "' AND '" + aFiltro[nPos,3] + "'"
			endIf
			 
			MsAguarde( {||GpeConvSRF(aCodFol,cFiltro)} , "Gerando Dias de Direito ["+ AllTrim(cEmpAnt + " -" + cFilAnt)+"]")
		Next nY
		
		if(MsgYesNo("Deseja encerrar períodos aquisitivos inválidos?", "Opção" ))					
			/*Atualiza Períodos Aquisitivos*/
			MsAguarde({|lAbort|UpdPerAqui(lAbort)},"Processando...","Fechando Períodos Aquisitivos Inválidos["+ AllTrim(cEmpAnt) + "]",.T.)
		endIf		
		
	Next nI	
	cEmpAnt := cEmpOri
	
	if(Len(aPeriodo) > 0)		
		aEval(aPeriodo,{|x|aAdd(aErro,'['+x[1]+'/'+x[2]+'/'+x[3]+']'+ OemToAnsi(STR0005))})
	endIf
	
	U_RIM01ERR(aErro)
	
	aSize(aErro,0)
	aErro:= Nil
	aSize(aTemp,0)
	aTemp := Nil
	aSize(aPDImp,0)
	aPDImp := Nil
	aSize(aEmpresas,0)
	aEmpresas := Nil
	aSize(aFuncImp,0)
	aFuncImp := Nil
	aSize(aPeriodo,0)
	aPeriodo := Nil	
	
	aEval(aAreas,{|x|RestArea(x)})
	aSize(aAreas,0)
	aAreas := Nil
	
	aSize(aCodFol,0)
	aCodFol := Nil
Return (.T.)

/*/{Protheus.doc} fDelMov
	Apaga os dados da SRG, SRR e SRF
@author Leandro Drumond
@since 21/11/12
@version P11
@param cAlias, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function fDelMov(cAlias,cRoteiro)
	Local cQuery := ''
	
	cQuery := " DELETE FROM " + InitSqlName(cAlias) + " "
	If cAlias == "SRR"
		cQuery += " WHERE RR_ROTEIR = '" + cRoteiro + "' AND RR_FILIAL = '" + xFilial("SRR") + "' "
	EndIf
	If cAlias == "SRH"
		cQuery += " WHERE RH_FILIAL = '" + xFilial("SRH") + "' "
	EndIf
	If cAlias == "SRF"
		cQuery += " WHERE RF_FILIAL = '" + xFilial("SRF") + "' "
	EndIf
	
	TcSqlExec( cQuery )
	
	TcRefresh( InitSqlName(cAlias) )
	
Return Nil

/*/{Protheus.doc} fFindSeqSRR
	Incrementa a sequencia da tabela SRD.
@author Edna Dalfovo
@since 08/05/13
@version P11
@param cFilAux, character, (Descrição do parâmetro)
@param cPdAux, character, (Descrição do parâmetro)
@param cMatAux, character, (Descrição do parâmetro)
@param cDtArqAx, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function fFindSeqSRR(cFilAux,cPdAux,cMatAux, cDtArqAx)
	Local cAliasAux := "QTABAUX"
	Local cWhere	:= ''
	Local nRet 		:= 0
	
	cWhere += "%"
	cWhere += " SRR.RR_FILIAL     = 	'" + cFilAux    + "' "
	cWhere += " AND SRR.RR_PD     = 	'" + cPdAux     + "' "
	cWhere += " AND SRR.RR_MAT    = 	'" + cMatAux    + "' "
	cWhere += " AND SRR.RR_DATA  = 	'" + cDtArqAx   + "' "
	cWhere += "%"
	
	BeginSql alias cAliasAux
		SELECT MAX(RR_SEQ) SEQMAX
		FROM %table:SRR% SRR
		WHERE 		%exp:cWhere% AND
		SRR.%NotDel%
	EndSql
	
	If Val((cAliasAux)->SEQMAX) > 0
		nRet := Val((cAliasAux)->SEQMAX) + 1
	Else
		nRet := 1
	EndIf
	
	(cAliasAux)->(DbCloseArea())
	
Return nRet

/*/{Protheus.doc} UpdPerAqui
	ATUALIZA OS PERÍODOS AQUISITIVOS QUE DEVERIAM ESTAR ENCERRADOS MAS QUE NÃO CONSTAM NAS FÉRIAS(SRH)
@author PHILIPE.POMPEU
@since 04/04/2016
@version P12
@return ${return}, ${return_description}
/*/
Static Function UpdPerAqui(lAbort)
	Local aArea	:= GetArea()
	Local cMyAlias := GetNextAlias()
	Local cQuery := ""
	Local cUpdCmd:= ""
	Local cTotal	:= ""
	Local nAtual	:= 0
	Default lAbort := .F.
				
	cQuery := "SELECT RH_FILIAL,RH_MAT,MAX(RH_DATABAS) AS OLDEST FROM "+ RetSqlName("SRH")
	cQuery += " WHERE RH_DFERIAS + RH_DABONPE = 30 AND D_E_L_E_T_ = ''"
	cQuery += " GROUP BY RH_FILIAL,RH_MAT "		
	cQuery	:= ChangeQuery(cQuery)				
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cMyAlias, .F., .T.)
	
	if((cMyAlias)->(! Eof()))
		nAtual := 0
		DbSelectArea(cMyAlias)
		Count To nAtual
							
		cTotal := cValToChar(nAtual)
		nAtual := 1
		(cMyAlias)->(dbGoTop())
		
		while ( (cMyAlias)->(!Eof()) .And. !lAbort)			
			
			MsProcTxt("Processando["+ cTotal + "/"+ cValToChar(nAtual)+"]")
			
			cUpdCmd:= "UPDATE " + RetSqlName("SRF") + " SET RF_STATUS = '3'"
			cUpdCmd+= " WHERE RF_DATABAS <= '"	+(cMyAlias)->OLDEST 	+ "'"
			cUpdCmd+= " AND RF_FILIAL = '"		+(cMyAlias)->RH_FILIAL 	+ "'"
			cUpdCmd+= " AND RF_MAT = '"			+(cMyAlias)->RH_MAT 		+ "'"
			cUpdCmd+= " AND RF_STATUS = '1'"
			cUpdCmd+= " AND D_E_L_E_T_ = ''" 
			TcSqlExec(cUpdCmd)
			nAtual++
			(cMyAlias)->(dbSkip())
		End
		
	EndIf		
	(cMyAlias)->(dbCloseArea())		
	
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} ExistReg
	Função que verifica se existe registros antes de perguntar se deseja limpar a tabela!
@author philipe.pompeu
@since 16/09/2015
@version P12
@return lResult,lógico,verdadeiro se existe registros nas tabelas
/*/
Static Function ExistReg(cRoteiro)
	Local aArea	:= GetArea()
	Local cAliasAux := GetNextAlias()
	Local lResult := .F.
	
	BeginSql alias cAliasAux
		SELECT COUNT(*) AS TOTAL
		FROM %table:SRR% SRR 
		WHERE
		RR_ROTEIR = %exp:cRoteiro% AND RR_FILIAL = %xFilial:SRR% AND SRR.%NotDel%
	EndSql
	
	lResult := (cAliasAux)->TOTAL > 0  
		
	(cAliasAux)->(DbCloseArea())
	
	RestArea(aArea)
	
Return (lResult)

/*/{Protheus.doc} SRRIsNew
(long_description)
@author philipe.pompeu
@since 12/01/2017
@version P11
@param cTp3, character, (Descrição do parâmetro)
@param cPer, character, (Descrição do parâmetro)
@param cRot, character, (Descrição do parâmetro)
@param cWeek, character, (Descrição do parâmetro)
@param cPd, character, (Descrição do parâmetro)
@param cSeq, character, (Descrição do parâmetro)
@param cData, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function SRRIsNew(cTp3,cPer,cRot,cWeek, cPd, cSeq, cData)
	Local lIsNew := .T.
	Local cChave := ''
	Local xOrder := ''
	
	cChave := xFilial('SRR') + SRA->RA_MAT
	
	SRR->(dbSetOrder(1))
	if(SRR->(dbSeek(cChave)))	
		//RR_FILIAL+RR_MAT+RR_TIPO3+RR_PERIODO+RR_ROTEIR+RR_SEMANA+RR_PD+RR_CC+RR_ITEM+RR_CLVL+RR_SEQ+DTOS(RR_DATA)
		xOrder := RetOrder('SRR','RR_FILIAL+RR_MAT+RR_TIPO3+RR_PERIODO+RR_ROTEIR+RR_SEMANA+RR_PD+RR_CC+RR_ITEM+RR_CLVL+RR_SEQ+DTOS(RR_DATA)')	
		SRR->(dbSetOrder(xOrder))
		
		cChave += cTp3 + cPer + cRot + cWeek + cPd
		cChave += SRA->(RA_CC + RA_ITEM + RA_CLVL)
		cChave += cSeq + cData
		
		lIsNew := !(SRR->(dbSeek(cChave)))		
	endIf
	
Return lIsNew
