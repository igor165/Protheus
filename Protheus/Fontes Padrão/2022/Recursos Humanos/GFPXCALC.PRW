#INCLUDE  "PROTHEUS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} fDPagMes()
Função que retorna os dias a serem pagos pela empresa, dentro do AnoMes passado
no parametro
@return		nDias
@author	    Fabricio Amaro
@since		07/11/2013
@version	P11.8
/*/
//Sempre deve ser passado a data de/ate completa, e a função se encarrega de analisar os
//dias a pagar do AnoMes
//dDataDe  := Data inicial para analise
//dDataAte := Data final para analise
//nDPagar  := Dias a pagar pela empresa
//cAnosMes := AnoMes para analise, onde será retornado os dias a pagar dentro desse MesAno
//------------------------------------------------------------------------------
Function fDPagMes(dDataDe, dDataAte, nDPagar, cAnoMes, nDiasMes)
	Local nDias 	 := 0
	Local nDiasSobra := 0

	Default nDiasMes := 30

	If MesAno(dDataAte) < cAnoMes  //SE A DATAATE FOR MENOR QUE O MESANO, RETORNA ZERO
		Return 0
	EndIf

	If MesAno(dDataDe) == cAnoMes

		dIniMes		:= dDataDe
		nDiasSobra	:= nDPagar

		If nDiasSobra <= 0
			If MesAno(dDataAte) > cAnoMes
				dDtFim := LastDay(dIniMes)  //SE FOR, PEGA O ULTIMO DIA DO ANOMES
			Else
				dDtFim := dDataAte  //SE NAO FOR, PEGA O PROPRIO DDATAATE
			EndIf
			If Day(dDtFim) > nDiasMes
				dDtFim := STOD(SubStr(DTOS(dDtFim),1,6)+StrZero(nDiasMes,2))
			EndIf

			nDiasSobra := (dDtFim - dIniMes) + 1
	    EndIf

	ElseIf MesAno(dDataDe) < cAnoMes

		dIniMes := STOD(cAnoMes+"01")  //Armazena o 1o dia do mes

		//PRIMEIRO VERIFICO QUANTOS DIAS JÁ FORAM PAGOS
		UltDMesAnt	:= dIniMes - 1 ////PEGO O ULTIMO DIA DO MES ANTERIOR
		nDiasAnt 	:= (UltDMesAnt - dDataDe)+1  //verifica quantos dias foram trabalhados no mes anterior
		nDiasSobra 	:= nDPagar - nDiasAnt  //retira os dias a pagar

		If nDiasSobra <= 0  //SE NÃO SOBROU DIAS, RETORNA ZERO POIS NÃO TEM NADA A PAGAR
			Return 0
		EndIf
	EndIf

	//AGORA VERIFICO SE O MES DO DDATAATE É MAIOR QUE O ANOMES
	If MesAno(dDataAte) > cAnoMes
		dDtFim := LastDay(dIniMes)  //SE FOR, PEGA O ULTIMO DIA DO ANOMES
	Else
		dDtFim := dDataAte  //SE NAO FOR, PEGA O PROPRIO DDATAATE
	EndIf
	If Day(dDtFim) > nDiasMes
		dDtFim := STOD(SubStr(DTOS(dDtFim),1,6)+StrZero(nDiasMes,2))
	EndIf

	//SE A SOMA DO 1o DIA + DIASSOBRA FOR MENOR OU IGUAL AO DATAFIM
	If ( dIniMes + (nDiasSobra-1) ) <= dDtFim
		Return nDiasSobra  //RETORNA OS DIASSOBRA MESMO
	Else
		Return( (dDtFim - dIniMes) + 1 ) //RETORNA OS DIAS DO MES TODO
	EndIf
Return nDias


//------------------------------------------------------------------------------
/*/{Protheus.doc} PerComis()
Função que retorna o periodo em comissionamento do servidor/membro
@return		aRet
@author	    Fabricio Amaro
@since		17/02/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function PerComis(cFil,cMat,dIni,dFim,dAnt,cTRB,cTPs)
	Local aArea	:= GetArea()
	Local aRet	:= {}
	Local nD004 := nD005 := nVl004 := nVl005 := nCont := 0
	Local lSai	:= .F.
	Local cTabela	:= ""
	Local cNvlTab	:= ""
	Local cFaixa 	:= ""
	Local cTabCom	:= ""
	Local cNivelCom	:= ""
	Local cFaixaCom := ""

	Default dAnt := ""
	Default cTRB := "TRB"
	Default cTPs := "'NOM','EXO'"

	cQuery := " SELECT * FROM " + RETSQLNAME("SR3") + " SR3 "
	cQuery += " INNER JOIN " + RETSQLNAME("SR7") + " SR7 ON R7_FILIAL = R3_FILIAL AND R7_MAT = R3_MAT AND SR7.D_E_L_E_T_ = ' ' AND R7_TIPO = R3_TIPO AND R7_DATA = R3_DATA "
	cQuery += " WHERE 	  R3_FILIAL = '"+ cFil +"' "
	cQuery += " 	AND   R3_MAT	= '"+ cMat +"' "
	If Empty(dAnt)
		cQuery += " AND   R3_DATA  >= '"+ DTOS(dIni) +"' "
		cQuery += " AND   R3_DATA  <= '"+ DTOS(dFim) +"' "
		cQuery += " AND   R3_TIPO IN ("+cTPs+") " //NOM-EM COMISSIONAMENTO | EXO-VOLTA PARA CARGO NORMAL
	Else
		cQuery += " AND   R3_DATA  < '"+ DTOS(dAnt) +"' "
		cQuery += " AND   R3_TIPO IN ("+cTPs+") "
	EndIf
	cQuery += " AND   SR3.D_E_L_E_T_  =  ' ' "
	cQuery += " ORDER BY R3_DATA , R3_SEQ " + If( Empty(dAnt) , "" , " DESC ")

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),cTRB, .F., .T.)
	dbSelectArea(cTRB)
	If !Eof()
		If (R3_TIPO == "EXO" .OR. SRA->RA_CATFUNC == "6" ) .AND. Empty(dAnt)//SE O 1o REGISTRO FOR UM RETORNO, PRECISA SABER O REGISTRO ANTERIOR
			aRet := PerComis(cFil,cMat,dIni,dFim,dIni,"CTRB1",If( SRA->RA_CATFUNC=="6","'001','NOM'","'EXO'"))
		EndIf
		While !Eof() .AND. !lSai
			nCont++

			//Busca o salario de efetivo e comissionado para a data da folha em calculo
			//O aRet retorna os periodos em que houve comissionamento que abrangem o periodo em calculo da Folha, porem
			//as informacoes de salarios e tabelas tem que refletir o que esta vigente no periodo em calculo.
			//Exemplo:
			//  - comissionamento pode ter iniciado em Fev/2014
			//  - em Jun/2014 houve uma acao salarial mudando o Nivel do cargo Efetivo
			//  - ao calcular a folha de Out/2014, o aRet terá informacao de que o comissionamento inicio eem Fev/2014, porém o salario
			//    salario a ser passado devera ser o vigente em Out/2014 para que gera a Diferenca de CNE corretamente.
			dData := dIni
			cTabela := cNvlTab := cFaixa := cTabCom := cNivelCom := cFaixaCom := ""
			lDataRef := .t.
			nSalEfe := R3_VALOR
			nSalCom := R3_CSALAR
			fBuscaTab(@dData,@cTabela, @cNvlTab,@cFaixa,@cTabCom ,@cNivelCom ,@cFaixaCom ,@lDataRef, @nSalEfe, @nSalCom )


			Aadd(aRet,{	StoD(R3_DATA),;	//-01
						R3_TIPO,;		//-02
						nSalEfe,;		//-03
						cTabela,;		//-04*
						cNvlTab,;		//-05*
						cFaixa,;		//-06
						R7_CATFUNC,;	//-07
						R7_ECAFUNC,;	//-08
						0,;				//-09
						nSalCom,;		//-10
						R3_TPSBCOM,;	//-11
						R3_PERCCOM,;	//-12
						0,;				//-13
						cTabCom,;		//-14*
						cNivelCom,;		//-15*
						cFaixaCom;		//-16*
						})
			If !(Empty(dAnt))
				lSai := .T.
			EndIf

			If Len(aRet) > 1
				aRet[Len(aRet)-1][9] := STOD(R3_DATA) - If( aRet[Len(aRet)-1][1] < dDataDe , dDataDe , aRet[Len(aRet)-1][1] )
			EndIf
			IF aRet[Len(aRet)][9] == 0 .AND. nCont == 1//CASO NÃO TENHA ENCONTRADO A DATA ANTERIOR, FAZ O CALCULO DOS DIAS
				aRet[Len(aRet)][9] := STOD(R3_DATA) - dDataDe
			EndIf

			dbSkip()
		EndDo
	EndIf
	&(cTRB)->( dbCloseArea() )

	//SE NO PERIODO NÃO TEM NADA, PEGA O ULTIMO - CASO NÃO RETORNE NADA, INDICA QUE NUNCA ESTEVE EM COMISSIONAMENTO
	If Len(aRet) == 0 .AND. Empty(dAnt)
		aRet := PerComis(cFil,cMat,dIni,dFim,dIni,"CTRB1","'NOM','EXO'")
	EndIf

	//SE TEM APENAS 1 REGISTRO, CONSIDERA O MES INTEIRO 30 DIAS
	If Len(aRet) == 1
		aRet[1][9] := 30
	//SE TEM MAIS DE 1, CONTA OS DIAS ATÉ O FINAL DO PERIODO
	ElseIf Len(aRet) > 1
		aRet[Len(aRet)][9] := (dDataAte - aRet[Len(aRet)][1]) + 1
	EndIf

	RestArea( aArea )

Return aRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} fMedServi()
Função que retorna o valor da MÉDIA ou o Array com as verbas conforme a data inicial e final passada no parametro
@return		nValor e aRet
@author	    Fabricio Amaro
@since		17/01/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function fMedServi(dInicio,dFinal,aVerbasAcu,cRoteiros,cTpMed,nMesesMedia)
	Local aArea      := GetArea()
	Local nVlMedia	 := 0
	Local nVlMedTot  := 0
	Local nValor	 := 0
	Local i			 := 0
	Local aRet 		 := {}

	Default nMesesMedia := (DateDiffMonth(dInicio,dFinal)+1 ) //numero de meses entre a data inicio e fim, caso não seja informado na passagem de parametro
	Default cRoteiros  	:= fcRoteiros()
	Default cTpMed	   	:= "RV_MEDFER == 'S '"
	Default aVerbasAcu 	:= fBuscaAcmPer(NIL,cTpMed,"V",,,MesAno(DINICIO),MesAno(DFINAL),,,cRoteiros,.T.)

	nMesesMedia := Min(nMesesMedia,12)

	For i := 1 To Len(aVerbasAcu)
		cTipoVerba := Posicione("SRV",1,XFILIAL("SRV") + aVerbasAcu[i][1],"RV_TIPO")
		cDescVerba := SRV->RV_DESC
		If cTipoVerba $ "D"
			nValor := aVerbasAcu[i][2] * (SRA->RA_SALARIO / 30)
		ElseIf cTipoVerba $ "H"
			nValor := aVerbasAcu[i][2] * (SRA->RA_SALARIO / SRA->RA_HRSMES)
		Else
			nValor := aVerbasAcu[i][3]
		EndIf

		nVlMedia  := (nValor / nMesesMedia) //Efetua a média
		nVlMedTot += nVlMedia
		Aadd(aRet,{aVerbasAcu[i][1],cDescVerba,cTipoVerba,aVerbasAcu[i][2],aVerbasAcu[i][3],aVerbasAcu[i][4],nValor, nVlMedia ,nMesesMedia })
	Next
	RestArea( aArea )
Return {nVlMedTot,aRet}


//------------------------------------------------------------------------------
/*/{Protheus.doc} CALCREDJOR()
Funcao que carrega a tabela SPF - Trocas de Turno e calcula o valor da reducao de jornada de trabalho
Essa funcao foi criada para ser usado em Formulas para o Roteiro de Calculo
@return		Array com 2 posicoes, sendo nReduz com o valor total, e aRet com os dias e jornadas
@author	    Fabricio Amaro
@since		07/01/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function CALCREDJOR()
	Local aArea     := GetArea()
	Local aRet 		:= {}
	Local dIni 		:= dDataDe  // DA INICIAL DO PERIODO, CARREGADO PELA FORMULA CARGARCH
	Local dFim  	:= dDataAte // DA FINAL   DO PERIODO, CARREGADO PELA FORMULA CARGARCH
	Local nCont 	:= 0
	Local nReduz := nDias35H := nDias30H := nVl35H := nVl30H := 0
	Local nDtIni := 0
	Local nDtFim := 0

	If cTipoRot $ "5*6"	//1a. e 2a. Parc. 13o.Salario
		dIni := CTOD("01/01/" +ALLTRIM(STR(YEAR(DDATAREF))))
	EndIf

	cQuery := " SELECT * FROM " + RETSQLNAME("SPF")
	cQuery += " WHERE PF_FILIAL  = '"+ SRA->RA_FILIAL +"' "
	cQuery += " AND   PF_MAT     = '"+ SRA->RA_MAT    +"' "
	cQuery += " AND   PF_DATA   <= '"+ DTOS(dFim)  +"' "
	cQuery += " AND   PF_JORNADE <> PF_JORNAPA "
	cQuery += " AND   D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY PF_DATA "

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
	dbSelectArea("TRB")
	dbGoTop()
	//-Se nao encontrar registro no SPF, verifica direto no SRA
	If EOF()
		If SRA->RA_JORNRED > 0 .And. !(SRA->RA_HRSEMAN = SRA->RA_JORNRED)
			//			 DATA  JORNADA DE    DIAS DE     JORNADA PARA DIAS PARA  VALOR REDUCAO
			Aadd(aRet, {dIni, SRA->RA_HRSEMAN,   0, SRA->RA_JORNRED,       0,      0        })
		EndIf
	EndIf
	
	While TRB->(!EOF())
		//			    DATA		        JORNADA DE	  DIAS DE     JORNADA PARA	  DIAS PARA   VALOR REDUCAO
		Aadd(aRet, {stod(TRB->PF_DATA), TRB->PF_JORNADE,    0   , TRB->PF_JORNAPA,     0     ,       0       })
		dbSkip()
	EndDo
	TRB->( dbCloseArea() )
	
	For nCont := 1 to Len(aRet)
		
		If nCont < Len(aRet) .And. (ANOMES(aRet[nCont][1]) < cANOMES) .And. (ANOMES(aRet[nCont+1][1]) <= cANOMES)
			Loop
		EndIf
		
		//PRIMEIRO CONTA OS 'DIAS DE'
		If nCont == 1
			aRet[nCont][3] := ( aRet[nCont][1] - dIni )
		Else
			aRet[nCont][3] := ( aRet[nCont][1] - IIF((aRet[nCont-1][1]<dIni), dIni,aRet[nCont-1][1]) )
		EndIf
		
		//AGORA CONTA OS 'DIAS ATE'
		If nCont < Len(aRet)
			If P_DIASMES == "S"
				If (ANOMES(aRet[nCont][1]) == cANOMES)
					nDtIni := DAY(aRet[nCont][1])	//-DAY(dIni)
				Else
					nDtIni := DAY(dIni)
				EndIf
				nDtFim := DAY(aRet[nCont + 1, 1])
				
				If !(ANOMES(aRet[nCont][1]) == ANOMES(aRet[nCont+1,1]))
					aRet[nCont][5] := ( dFim - aRet[nCont][1] ) + 1
					If aRet[nCont][5] > 30
						aRet[nCont][5] := 30
					EndIf
				Else
					IF (( SUBSTR(CANOMES,5,2) == "02" .AND. ;
						((VAL(SUBSTR(CANOMES,1,4)) % 4 > 0 .AND. nDtFim = 28) .OR. (VAL(SUBSTR(CANOMES,1,4)) % 4 = 0 .AND. nDtFim = 29) )))
						nDtFim := 30
					EndIF
					IF ( !(SUBSTR(CANOMES,5,2) == "02") .AND. nDtFim > 30 )
						nDtFim := 30
					EndIF
					aRet[nCont][5] := ( nDtFim - Day(aRet[nCont][1]) )
				EndIf
				If cTipoRot $ "5*6"	//1a. e 2a. Parc. 13o.Salario
					aRet[nCont][5] := 30
				EndIf
			Else
				aRet[nCont][5] := ( aRet[nCont+1,1] - aRet[nCont][1])
			EndIf
		Else
			If P_DIASMES == "S"
				If (ANOMES(aRet[nCont][1]) == cANOMES)
					nDtIni := DAY(aRet[nCont][1])
				Else
					nDtIni := DAY(dIni)
				EndIf
				nDtFim := DAY(dFim)
				
				If !(ANOMES(dIni) == ANOMES(dFim))
					aRet[nCont][5] := ( dFim - aRet[nCont][1] )
					If aRet[nCont][5] > 30
						aRet[nCont][5] := 30
					EndIf
				Else
					IF (( SUBSTR(CANOMES,5,2) == "02" .AND. ;
						((VAL(SUBSTR(CANOMES,1,4)) % 4 > 0 .AND. nDtFim = 28) .OR. (VAL(SUBSTR(CANOMES,1,4)) % 4 = 0 .AND. nDtFim = 29) )))
						nDtFim := 30
					EndIF
					IF ( !(SUBSTR(CANOMES,5,2) == "02") .AND. nDtFim > 30 )
						nDtFim := 30
					EndIF
					aRet[nCont][5] := ( nDtFim - nDtIni ) + 1
				EndIf
				If cTipoRot $ "5*6"	//1a. e 2a. Parc. 13o.Salario
					aRet[nCont][5] := 30
				EndIf
			Else
				aRet[nCont][5] := ( dFim - aRet[nCont][1] )
			EndIf
		EndIf
		
		//CASO A JORNADA "PARA" SEJA NOVAMENTE A MESMA DO PADRAO, EM CASO DE MAIS DE 1 LINHA, TEM QUE ZERAR PARA NAO CALCULAR NOVAMENTE
		If ( aRet[nCont][4] == NHORSEM) .AND. nCont > 1
			aRet[nCont][3] := 0
			aRet[nCont][5] := 0
		EndIf
		
		//AGORA CALCULA O VALOR DA REDUCAO
		//PRIMEIRO VERIFICA QUAL A HORA E O DIA PARA A BASE DO CALCULO
		If aRet[nCont][4] == NHORSEM
			nHoras  := aRet[nCont][2]
			nDias	:= aRet[nCont][3]
		Else
			nHoras  := aRet[nCont][4]
			nDias	:= aRet[nCont][5]
			If nHoras == 35
				nDias35H += nDias
			ElseIf nHoras == 30
				nDias30H += nDias
			EndIf
		EndIf
		
		NRJORN1SAL 		:= Round(( ( SALMES - 	 ( ( SALMES    * nHoras ) / NHORSEM )) / 30 ) * nDias, 2)
		NRJORN2SAL 		:= Round(( ( NSALCOMIS - ( ( NSALCOMIS * nHoras ) / NHORSEM )) / 30 ) * nDias, 2)
		aRet[nCont][6] 	:= Round(( ( NSALCOMIS - ( ( NSALCOMIS * nHoras ) / NHORSEM )) / 30 ) * nDias, 2)
		If nHoras == 35
			nVl35H += aRet[nCont][6]
		ElseIf nHoras == 30
			nVl30H += aRet[nCont][6]
		EndIf
		
		nReduz += aRet[nCont][6]
	Next nCont

	RestArea( aArea )
Return {nReduz,aRet,nDias35H,nVl35H,nDias30H,nVl30H}


//------------------------------------------------------------------------------
/*/{Protheus.doc} FABOPERMA()
Função que verifica se existe o direito ao pagamento do Abono Permanencia
Essa função foi criada para ser usado em Fórmulas para o Roteiro de Cálculo
@return		nVlINSS
@author	    Fabricio Amaro
@since		13/01/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function FABOPERMA()
	Local aRet		:= {}
	Local cQuery	:= ""
	Local aArea     := GetArea()
	Local nVlRet	:= 0
	Local nDiasRet 	:= 0
	Local dIni 		:= dDataDe  // DA INICIAL DO PERIODO, CARREGADO PELA FORMULA CARGARCH
	Local dFim  	:= dDataAte // DA FINAL   DO PERIODO, CARREGADO PELA FORMULA CARGARCH

	Local cDtFolMes := fGetFolmes()

	Local nPos 		:= 0

	cDtFolMes := cDtFolMes+"31"

	cQuery := " SELECT * FROM " + RETSQLNAME("RIJ")
	cQuery += " WHERE RIJ_FILIAL = '"+ SRA->RA_FILIAL +"' "
	cQuery += " AND RIJ_MAT =  '"+ SRA->RA_MAT +"' "
	cQuery += " AND RIJ_DINDIR <= '"+ cDtFolMes +"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY RIJ_DINDIR "

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
	dbSelectArea("TRB")

	If !Eof()
		//-INSS
		npos := ASCAN(APD, {|X| X[1] == FGETCODFOL("0064")})
		if npos > 0
			nVlRet 	 += APD[NPOS][5]
		endif

		//-INSS Ferias
		npos := ASCAN(APD, {|X| X[1] == FGETCODFOL("0065")})
		if npos > 0
			nVlRet 	 += APD[NPOS][5]
		endif

		//-INSS 13.Salario
		npos := ASCAN(APD, {|X| X[1] == FGETCODFOL("0070")})
		if npos > 0
			nVlRet 	 += APD[NPOS][5]
		endif

		//-Previdencia Propria Desconto - RPPS
		npos := ASCAN(APD, {|X| X[1] == FGETCODFOL("1374")})
		if npos > 0
			nVlRet 	 += APD[NPOS][5]
		endif

		//-Prev. Propria Desconto 13o. - RPPS
		npos := ASCAN(APD, {|X| X[1] == FGETCODFOL("1382")})
		if npos > 0
			nVlRet 	 += APD[NPOS][5]
		endif

		//-Previdência Própria Desconto - Ferias - RPPS
		npos := ASCAN(APD, {|X| X[1] == FGETCODFOL("1665")})
		if npos > 0
			nVlRet 	 += APD[NPOS][5]
		endif

		If nVlRet == 0
			npos := ASCAN(APD, {|X| X[1] == FGETCODFOL("1372")})
			if npos > 0
				nVlRet 	 := APD[NPOS][5]
			endif
		EndIf
		nDiasRet := (dFim - ( If( TRB->RIJ_DINDIR > DTOS(dIni) .AND. TRB->RIJ_DINDIR <= DTOS(dFim) ,TRB->RIJ_DINDIR , dIni) )) + 1
	EndIf

	If nVlRet > 0 .OR. TRB->RIJ_VALRET > 0
		aRet := {nVlRet,;				//01-Valor total de INSS do mes a devolver
				 nDiasRet,;				//02-Dias a serem pagos
				 STOD(TRB->RIJ_PAGTO),;	//03-Data Inicio de Pagto do Retroativo
				 TRB->RIJ_VALRET,;		//04-Valor total do INSS Retroativo
				 TRB->RIJ_PARCEL}		//05-Nr.Parcelas a pagar
	EndIf

	TRB->( dbCloseArea() )
	RestArea( aArea )
Return(aRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCalcPenMPº Autor ³ Equipe IP-RH GSP   º Data ³ 01/07/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao utilizada via Formula de Calculo - S_FCALCPEN       º±±
±±º          ³ -> Realiza o Calculo da Pensao Alimenticia                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus Versao 11.90                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fCalcPenMP()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local DDATAPGTO := GetValType('D')
Local CPENSOUT	:= GetValType('C')
Local APENSOUT	:= GetValType('A')
Local NVALBASE	:= GetValType('N')
Local NVALINSS	:= GetValType('N')
Local NNRSLMIN	:= GetValType('N')
Local NVALFIXO	:= GetValType('N')
Local NVLPENS131 := GetValType('N')
Local NPOSROT	:= GetValType('N')
Local NPOSIR	:= GetValType('N')
Local NPOSX		:= GetValType('N')
Local N_PERCPENSAO := GetValType('N')
Local N_VALFIXO := GetValType('N')
Local N_NRSLMIN := GetValType('N')
Local CROTVERBA := GetValType('C')
Local CVBBASEP	:= GetValType('C')
Local CVB131	:= GetValType('C')
Local CVBPLR	:= GetValType('C')
Local CVBADT	:= GetValType('C')
Local CCODPENADT := GetValType('C')
Local C_VBBASEP	:= GetValType('C')
Local DDTINIPG	:= GetValType('D')
Local DDTFIMPG	:= GetValType('D')
Local LCADPENSAO := GetValType('L')
Local LUSARIR	:= GetValType('L')
Local L_CALSLLIQ := GetValType('L')
Local LCALSLBRU := GetValType('L')
Local LDTPEN	:= GetValType('L')
Local APDIR		:= GetValType('A')
Local NINDPROP	:= GetValType('N')
Local NINDPROPANT := GetValType('N')
Local C_PENSAO	:= GetValType('C')
Local CMVPROPENS := GetValType('C')
Local CMVPENSOUT := GetValType('C')
Local N2PENSAO	:= GetValType('N')
Local NVLPRIPAR := GetValType('N')
Local LOK		:= GetValType('L')
Local NY		:= 0
Local nQ		:= 0

Begin Sequence

	VERIFICAID({"66","9","71","67","172","22","173"})

	NPERCPENSAO	:= 0
	DDATACALC	:= DDATAATE
	CTIPO		:= IF(CTIPO == NIL, SPACE(3), CTIPO)
	CTIPOPENS	:= C__ROTEIRO
	CPENSAO		:= ""
	DDATAPGTO	:= DDATA_PGTO
	LCALSLBRU	:= LDTPEN := .F.
	ACODBENEF	:= APDIR :={}
	NINDPROP	:= NINDPROPANT := 1
	C_PENSAO	:= " "
	cMVPROPENS	:= GETMV( "MV_PROPENS",, "N" )
	cPensOUT	:= GETMV( "MV_PENSOUT",, "N" )
	aPensOUT	:= {}
	NVALBASE	:= NLIQTEMP := NVALINSS := NVALIR := NNRSLMIN := NVALFIXO := NVALPENSAO := NVLPENS131 := NPOSROT := NPOSIR := NX := NVAL_PEAL := NPOSX := N_PERCPENSAO := N_VALFIXO:= N_NRSLMIN := 0
	CROTVERBA	:= CVBBASEP := CVB131 := CVBPLR := CVBADT := CCODPENADT := C_VBBASEP := DDTINIPG := DDTFIMPG:= ""
	LCALSLLIQ	:= LCADPENSAO := LUSARIR := L_CALSLLIQ := .T.
	LCARRBENEF	:= IF(LCARRBENEF == NIL, .T., LCARRBENEF )
	CSITFOLHA	:= IF( EMPTY(CSITFOLHA), SRA->RA_SITFOLH, CSITFOLHA)
	CFILIALCOR	:= IF(CFILIALCOR == NIL, SRA->RA_FILIAL, CFILIALCOR )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as verbas da Pensao                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF ( CTIPOROT=="1" )
		CIR:=FGETCODFOL("0066")
	EndIF

	IF ( CTIPOROT=="2" )
		CIR:=FGETCODFOL("0009")
	EndIF

	IF ( CTIPOROT=="6" )
		CIR:=FGETCODFOL("0071")
	EndIF

	IF ( CTIPOROT=="4" )
		DDATAPGTO:=GETMEMVAR("RG_DATAHOM")
		CTIPOPENS:=IF( EMPTY(CTIPO), "FOL", CTIPO )

		IF ( CTIPOPENS=="FOL" )
			CIR:=FGETCODFOL("0066")
		EndIF

		IF ( CTIPOPENS=="FER" )
			CIR:=FGETCODFOL("0067")
		EndIF

		IF ( CTIPOPENS=="132" )
			CIR:=FGETCODFOL("0071")
		EndIF
	EndIF

	IF ( CTIPOROT=="3" )
		DDATAPGTO:=GETMEMVAR("RH_DTRECIB")
		CIR:=FGETCODFOL("0067")
	EndIF

	IF ( CTIPOROT ==  "9" )
		CIR:=FGETCODFOL("0066")
		CTIPOPENS:="FOL"
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define os dias proporcionais                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF ( CTIPOROT$"1|4|9" )
		NINDPROP := ( MIN( DIASTRAB, 30 ) / 30 )
	EndIF

	IF ( CTIPOROT=="3" )
		NINDPROP := ( IIF (GETMEMVAR("RH_DFERIAS") > 0,MIN(GETMEMVAR("RH_DFERIAS"),30),30) / 30 )
	EndIF

	IF ( CTIPOROT=="2" )
		NINDPROP := ( MIN( DIASTB, 30 ) / 30 )
	EndIF

	IF ( CTIPOROT$"5|6" )
		NINDPROP := ( MIN( NAVOS, 12 ) / 12 )
	EndIF

	NINDPROPANT := NINDPROP

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega os Beneficiarios a serem calculados                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF ( LCARRBENEF==.T. )
		FBUSCADBENEF( @ACODBENEF, CTIPOPENS , , , , , DDATAATE)
	EndIF

	IF ( LEN(ACODBENEF)==0 )
		IF ( LEN(APENSAO)>0 )
			NX:=1

			While ( NX <= LEN(APENSAO) )
				IF ( LEN(APENSAO[NX]) == 6 )

					C_PENSAO	:=IF(VALTYPE(APENSAO[NX,1]) == VALTYPE(CPENSAO),APENSAO[NX,1],CPENSAO)
					N_PERCPENSAO:=IF(VALTYPE(APENSAO[NX,2]) == VALTYPE(NPERCPENSAO),APENSAO[NX,2],NPERCPENSAO)
					N_VALFIXO	:=IF(VALTYPE(APENSAO[NX,3]) == VALTYPE(NVALFIXO),APENSAO[NX,3],NVALFIXO)
					N_NRSLMIN	:=IF(VALTYPE(APENSAO[NX,4]) == VALTYPE(NNRSLMIN),APENSAO[NX,4],NNRSLMIN)
					C_VBBASEP	:=IF(VALTYPE(APENSAO[NX,5]) == VALTYPE(CVBBASEP),APENSAO[NX,5],CVBBASEP)
					L_CALSLLIQ	:=IF(VALTYPE(APENSAO[NX,6]) == VALTYPE(LCALSLLIQ),APENSAO[NX,6],LCALSLLIQ)

					AADD(ACODBENEF, { C_PENSAO, N_PERCPENSAO, N_VALFIXO, N_NRSLMIN, C_VBBASEP, L_CALSLLIQ, FGETCODFOL("0172") , CVBPLR, "", "", "", "", "", "", "", "", "", "" })
				EndIF

				NX:=NX+1
			EndDo
		EndIF

		IF ( LEN(APENSAO) == 0 )
			AADD(ACODBENEF, { CPENSAO, NPERCPENSAO, NVALFIXO, NNRSLMIN, CVBBASEP, LCALSLLIQ, FGETCODFOL("0172") , CVBPLR, "", "", "", "", "", "", "", "", "", "" })
		EndIF

		LCADPENSAO:=.F.
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Roda o Looping nos Beneficiarios                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NCNT1:=1
	While ( NCNT1 <=  LEN(ACODBENEF) )

		lGravou := .F.

		IF ( LEN (ACODBENEF[NCNT1]) > 16 )
			DDTFIMPG := ACODBENEF[NCNT1,18]
			DDTINIPG := ACODBENEF[NCNT1,17]
			LDTPEN:=.T.
		EndIF

		IF ( (EMPTY(DDTFIMPG) .OR. DDTFIMPG > DDATADE ) .AND. (!EMPTY(DDTINIPG) .AND. DDTINIPG < DDATAATE) .OR. !LDTPEN )

			NINDPROP	:= NINDPROPANT
			CPENSAO		:= IF( CTIPO == "DFE", ACODBENEF[NCNT1,13], ACODBENEF[NCNT1,1] )
			NPERCPENSAO := ACODBENEF[NCNT1,2]
			NVALFIXO    := ACODBENEF[NCNT1,3]
			NNRSLMIN    := ACODBENEF[NCNT1,4]
			CVBBASEP    := ACODBENEF[NCNT1,5]
			LCALSLLIQ   := ACODBENEF[NCNT1,6]
			CVB131      := ACODBENEF[NCNT1,7]
			CVBPLR      := ACODBENEF[NCNT1,8]
			CVBADT      := ACODBENEF[NCNT1,14]
			CROTVERBA   := ACODBENEF[NCNT1,16]

			IF ( CMVPROPENS=="N" )

				IF ( NVALFIXO > 0 .OR. NNRSLMIN > 0 )

					IF ( CTIPOROT=="1" )

						NINDPROP := 1

						IF (( CSITFOLHA == "F" ).AND.( ( NPOSROT := AT( "FER", CROTVERBA ) ) > 0 ))

							IF (( !EMPTY( SUBSTR( CROTVERBA, NPOSROT + 3, 3 ) ) ).AND.( FO_SEEK(@&COBJETO, CCPOPD, SUBSTR( CROTVERBA, NPOSROT + 3, 3 ) ) ))
								NINDPROP := 0
							EndIF
						EndIF
					EndIF

					IF ( CTIPOROT$"3|4|5|6" )
						NINDPROP := 1
					EndIF
				EndIF
			EndIF
			/*
			IF (( CTIPOROT=="5" ).AND.( ( NVALFIXO > 0 .OR. NNRSLMIN > 0 ) ))

				IF ( !EMPTY(CPENSAO) .AND. !EMPTY(CVB131) )
					NINDPROP:=NINDPROP * NPERCENTUA
				EndIF
			EndIF
			*/
			IF ( NNRSLMIN > 0 .AND. CTIPO == "DFE" )
				NINDPROP := FDIFPENSAOSM( NNRSLMIN, .F., .T.)
			EndIF

			IF (( EMPTY(CPENSAO) ).OR.( (NPERCPENSAO == 0 .AND. NVALFIXO == 0 .AND. NNRSLMIN == 0) ).OR.( ( ( NVALFIXO > 0 .OR. NNRSLMIN > 0 ) .AND. NINDPROP == 0 ) ))
				NCNT1:=NCNT1+1
				Loop
			EndIF

			IF ( FO_SEEK(@&COBJETO, {CCPOPD, CCPONPAGTO}, {CPENSAO, CNUMPAG} ) )
				NCNT1:=NCNT1+1
				Loop
			EndIF

			LUSARIR:=( EMPTY(CVBBASEP) .OR. CIR $ CVBBASEP )

			IF ( ( SRA->RA_TIPOPGT = "S" ) )

				IF ( !( ( POSSRV( FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_PENSAO" ) == "S" .AND. FO_GETVAL(@&COBJETO,CCPONPAGTO) == CNUMPAG .AND. !FO_DELETED(@&COBJETO) ) ) )
					Break
				EndIF
			EndIF

			NVALIR := 0.00

			IF ( LUSARIR==.T. )
				IF ( FO_SEEK(@&COBJETO, {CCPOPD, CCPONPAGTO} , {CIR, CNUMPAG} ) )
					NVALIR:=FO_GETVAL(@&COBJETO, CCPOVALOR )
				EndIF
			EndIF

			NVALBASE   := 0.00

			NVALPENSAO := 0.00

			NLIQTEMP   := 0.00

			IF ( NVALFIXO>0 )

				NVALPENSAO := (NVALFIXO * NINDPROP)

			NVLPENS131 := NVALPENSAO

			IF ( (NVLPENS131 > 0) .And. !Empty(CVB131) .And. !FO_SEEK(@&COBJETO, {CCPOPD, CCPOTIPO2}, {CVB131, "I"}) )
			FO_ADD(@&COBJETO, {CCPOPD, CCPOVALOR, CCPOHORAS, CCPONPAGTO, CCPOTIPO1, CCPODATA} , { CVB131, NVLPENS131, NPERCPENSAO, CNUMPAG, "V", DDATAPGTO} )
				lGravou := .T.
			EndIF

			EndIF

			IF ( NNRSLMIN>0 )

				NVALPENSAO:=NOROUND(VAL_SALMIN * NNRSLMIN, 2) * NINDPROP

				NVLPENS131 := NOROUND( ((VAL_SALMIN * NNRSLMIN) * GETMEMVAR("RH_PERC13S" ) ) / 100 , 2 )

				NVLPENS131:= NOROUND( (NVLPENS131 * NPERCPENSAO / 100),2)

				IF ( (NVLPENS131 > 0) .And. !Empty(CVB131) .And. !FO_SEEK(@&COBJETO, {CCPOPD, CCPOTIPO2}, {CVB131, "I"}) )
					FO_ADD(@&COBJETO, {CCPOPD, CCPOVALOR, CCPOHORAS, CCPONPAGTO, CCPOTIPO1, CCPODATA} , { CVB131, NVLPENS131, NPERCPENSAO, CNUMPAG, "V", DDATAPGTO} )
					lGravou := .T.
				EndIF

			EndIF

			IF ( NVALFIXO <= 0 .AND. NNRSLMIN <= 0 )


				IF ( CTIPOROT=="5" )

					IF ( LCADPENSAO==.T. )

						FO_GOTOP(@&COBJETO)

						While ( ! FO_EOF(@&COBJETO ) )
							IF (( !FO_DELETED(@&COBJETO) ).AND.( ( FO_GETVAL(@&COBJETO, CCPOPD ) $  CVBBASEP  .OR. EMPTY(CVBBASEP) ) ))

								IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_PENSAO" ) == "S"  .AND. FO_GETVAL(@&COBJETO,CCPONPAGTO) $ "  *"+CNUMPAG )

									IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "1|3" )
										NVALBASE+=FO_GETVAL(@&COBJETO, CCPOVALOR)
									EndIF

									IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "2|4" )
										NVALBASE-=FO_GETVAL(@&COBJETO, CCPOVALOR)
									EndIF
								EndIF
							EndIF

							FO_SKIP(@&COBJETO)
						EndDo
					EndIF

					IF ( LCADPENSAO==.F. )
						IF ( FO_SEEK(@&COBJETO, {CCPOPD, CCPONPAGTO} , { FGETCODFOL("0022") , CNUMPAG } ) )
							NVALBASE:=FO_GETVAL(@&COBJETO , CCPOVALOR )
						EndIF
					EndIF

					NVALBASE += SALARIO
				EndIF

				IF ( CTIPOROT$"1|9" )

					IF ( CTIPO=="DFE" )

						FO_GOTOP(@&COBJETO)

						While ( !FO_EOF(@&COBJETO ) )
							IF ( !FO_DELETED(@&COBJETO) )

								IF (( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_PENSAO" ) == "S" ).AND.( FO_GETVAL(@&COBJETO,CCPONPAGTO) $ "  *"+CNUMPAG ))

									IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "1|3" )
										NVALBASE+=FO_GETVAL(@&COBJETO, CCPOVALOR)
									EndIF

									IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "2|4" )
										NVALBASE-=FO_GETVAL(@&COBJETO, CCPOVALOR)
									EndIF
								EndIF
							EndIF

							FO_SKIP(@&COBJETO)
						EndDo
					EndIF

					IF ( CTIPO<>"DFE" )

						FO_GOTOP(@&COBJETO)

						While ( !FO_EOF(@&COBJETO ) )
							IF ( !FO_DELETED(@&COBJETO) .AND. ( FO_GETVAL(@&COBJETO, CCPOPD )  $ CVBBASEP  .OR. EMPTY(CVBBASEP) ) )

								IF ( CPAISLOC<>"URU" )

									IF (( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_PENSAO" ) == "S" ).AND.( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD) , SRA->RA_FILIAL, "RV_REFFER" )  $ " *N" ).AND.( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_REF13" ) $ " *N" .AND. FO_GETVAL(@&COBJETO,CCPONPAGTO) $ "  *"+CNUMPAG ))

										IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "1|3" )
											NVALBASE+=FO_GETVAL(@&COBJETO, CCPOVALOR)
										EndIF

										IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "2|4" )
											NVALBASE-=FO_GETVAL(@&COBJETO, CCPOVALOR)
										EndIF
									EndIF
								EndIF
							EndIF

							FO_SKIP(@&COBJETO)
						EndDo
					EndIF
				EndIF

				IF ( CTIPOROT=="4" )

					FO_GOTOP(@&COBJETO)

					While ( !FO_EOF(@&COBJETO) )
						IF ( !FO_DELETED(@&COBJETO) .AND. (FO_GETVAL(@&COBJETO, CCPOPD )  $ CVBBASEP  .OR. EMPTY(CVBBASEP) ) )

							IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_PENSAO" ) == "S" )

								IF ( CTIPOPENS == "FER" )

									IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_REFFER" )  == "S"  .AND.  POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_REF13" ) $ " *N" .AND. FO_GETVAL(@&COBJETO,CCPONPAGTO) $ "  *"+CNUMPAG )

										IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "1|3" )
											NVALBASE+=FO_GETVAL(@&COBJETO, CCPOVALOR)
										EndIF

										IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "2|4" )
											NVALBASE-=FO_GETVAL(@&COBJETO, CCPOVALOR)
										EndIF
									EndIF
								EndIF

								IF ( CTIPOPENS == "132" )

									IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_REFFER" )  $ " *N"  .AND.  POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_REF13" ) == "S"    .AND. FO_GETVAL(@&COBJETO,CCPONPAGTO)$ "  *"+CNUMPAG )

										IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "1|3" )
											NVALBASE+=FO_GETVAL(@&COBJETO, CCPOVALOR)
										EndIF

										IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "2|4" )
											NVALBASE-=FO_GETVAL(@&COBJETO, CCPOVALOR)
										EndIF
									EndIF
								EndIF

								IF ( !(CTIPOPENS $  "FER|132") )

									IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_REFFER" )  $ " *N" .AND.  POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_REF13" ) $ " *N"    .AND. FO_GETVAL(@&COBJETO,CCPONPAGTO) $ "  *"+CNUMPAG )

										IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "1|3" )
											NVALBASE+=FO_GETVAL(@&COBJETO, CCPOVALOR)
										EndIF

										IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "2|4" )
											NVALBASE-=FO_GETVAL(@&COBJETO, CCPOVALOR)
										EndIF
									EndIF
								EndIF
							EndIF
						EndIF

						FO_SKIP(@&COBJETO)
					EndDo
				EndIF

				IF ( !( CTIPOROT $ "1|2|4|5|9" ) )

					FO_GOTOP(@&COBJETO)

					While ( ! FO_EOF(@&COBJETO ) )
						IF ( !FO_DELETED(@&COBJETO) .AND. (FO_GETVAL(@&COBJETO, CCPOPD ) $  CVBBASEP  .OR.  EMPTY(CVBBASEP) ) )

							IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_PENSAO" ) == "S"  .AND. FO_GETVAL(@&COBJETO,CCPONPAGTO) $ "  *"+CNUMPAG )

								IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "1|3" )
									NVALBASE+=FO_GETVAL(@&COBJETO, CCPOVALOR)
								EndIF

								IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "2|4" )
									NVALBASE-=FO_GETVAL(@&COBJETO, CCPOVALOR)
								EndIF
							EndIF
						EndIF

						FO_SKIP(@&COBJETO)
					EndDo

					IF ( CTIPOROT=="3" )

						IF (( FO_SEEK(@&COBJETO, {CCPOPD, CCPONPAGTO}, {FGETCODFOL("0022") , CNUMPAG } ) ).AND.( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD) , SRA->RA_FILIAL , "RV_PENSAO" ) ==  "S" ))

							NVALBASE-=FO_GETVAL(@&COBJETO , CCPOVALOR)

							NVLPENS131:=NOROUND((( FO_GETVAL(@&COBJETO, CCPOVALOR) * NPERCPENSAO) / 100 ) , 2 )

							IF ( (NVLPENS131 > 0) .AND. !FO_SEEK(@&COBJETO, {CCPOPD, CCPOTIPO2}, {CVB131, "I"}) )
								FO_ADD(@&COBJETO, {CCPOPD, CCPOVALOR, CCPOHORAS, CCPONPAGTO, CCPOTIPO1, CCPODATA} , { CVB131, NVLPENS131, NPERCPENSAO, CNUMPAG , "V", DDATAPGTO} )
							EndIF
						EndIF
					EndIF
				EndIF

				NVALBASE := IF(NVALBASE < 0 ,0, NVALBASE )
				NLIQTEMP := NOROUND(NVALBASE,2)
			EndIF

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calculo sobre o Liquido                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF ( NVALFIXO == 0 .AND. NNRSLMIN == 0 )

				NVALPENSAO := NOROUND( ( ( ( NLIQTEMP - NVALIR )  * NPERCPENSAO ) / 100 ) , 2 )

				IF ( (NVALPENSAO > 0) .AND. !FO_SEEK(@&COBJETO, {CCPOPD, CCPOTIPO2}, {CPENSAO, "I"}) )
					FO_ADD(@&COBJETO, {CCPOPD, CCPOVALOR, CCPOHORAS, CCPONPAGTO, CCPOTIPO1, CCPODATA} , {CPENSAO, NVALPENSAO, NPERCPENSAO, CNUMPAG, "V", DDATAPGTO} )
				EndIF

				NY := 1

				While ( NY = 1 )

					S_FCIR()
					S_GRAVAIR()
					IF ( LUSARIR==.T. )

						NVALIR := 0

						IF ( FO_SEEK(@&COBJETO, {CCPOPD, CCPONPAGTO} , {CIR, CNUMPAG} ) )
							NVALIR:=FO_GETVAL(@&COBJETO, CCPOVALOR )
						EndIF
					EndIF

					N2PENSAO := NOROUND( ( ( ( NLIQTEMP - NVALIR )  * NPERCPENSAO ) / 100 ) , 2 )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica a diferenca entre o valor da Pensao e do IRRF              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					IF ( LOK := ((NVALPENSAO - N2PENSAO) < 0.01) )
						NY += 1

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Salva a pensao pra regravar no final                                ³
						//³ cPensOUT := SUPERGETMV("MV_DIASPER",,"N")                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cPensOUT == "N"	//-Uma pensao nao incide pra outra
							IF ( FO_SEEK(@&COBJETO,{ CCPOPD, CCPONPAGTO } , { CPENSAO, CNUMPAG} ) )
								FO_DELETE(@&COBJETO)
							EndIF
							aAdd(aPensOUT, {CPENSAO, NVALPENSAO, NPERCPENSAO, CNUMPAG, "V", DDATAPGTO})
						EndIF
					EndIF

					IF ( !LOK .AND. (N2PENSAO > 0) .AND. !FO_SEEK(@&COBJETO, {CCPOPD, CCPOTIPO2}, {CPENSAO, "I"}) )

						NVALPENSAO := N2PENSAO

						IF ( FO_SEEK(@&COBJETO,{ CCPOPD, CCPONPAGTO } , { CPENSAO, CNUMPAG} ) )
							FO_DELETE(@&COBJETO)
						EndIF

						FO_ADD(@&COBJETO, {CCPOPD, CCPOVALOR, CCPOHORAS, CCPONPAGTO, CCPOTIPO1, CCPODATA}, {CPENSAO, NVALPENSAO, NPERCPENSAO, CNUMPAG, "V", DDATAPGTO} )
					EndIF

					IF ( FO_SEEK(@&COBJETO,{ CCPOPD, CCPONPAGTO } , { FGETCODFOL("0015"), CNUMPAG} ) )	//-Base de IRRF
						FO_DELETE(@&COBJETO)
					EndIF

					IF ( FO_SEEK(@&COBJETO,{ CCPOPD, CCPONPAGTO } , { FGETCODFOL("0066"), CNUMPAG} ) )	//-Descto IRRF Folha
						FO_DELETE(@&COBJETO)
					EndIF

				EndDo
			EndIF

			IF ( NNRSLMIN > 0 )
				NVALPENSAO := NOROUND((NVALPENSAO * NPERCPENSAO / 100),2)
			EndIF

			IF ( !lGravou .AND. !LCALSLLIQ .AND. (NVALPENSAO > 0) .AND. !FO_SEEK(@&COBJETO, {CCPOPD, CCPOTIPO2}, {CPENSAO, "I"}) )
				IF ( CTIPO == "DFE" )
					NVALPENSAO := FDIFPENSAOSM( NNRSLMIN, .T., .T. )
				EndIF
				IF NVALPENSAO > 0 .AND. !FO_SEEK(@&COBJETO, {CCPOPD, CCPOTIPO2}, {CPENSAO, "I"})
					FO_ADD(@&COBJETO, {CCPOPD, CCPOVALOR, CCPOHORAS, CCPONPAGTO, CCPOTIPO1, CCPODATA}, {CPENSAO, NVALPENSAO, NPERCPENSAO, CNUMPAG, "V", DDATAPGTO} )
				EndIF
			EndIF

			IF ( (CTIPOROT == "5" .AND. CPAISLOC <> "URU" ) .OR.  (CTIPOROT == "2" .AND. !LCADPENSAO) .OR. NVALFIXO > 0 .OR. NNRSLMIN > 0 )
				NCNT1:=NCNT1+1
				Loop
			EndIF

			IF ( LUSARIR==.F. )
				NCNT1:=NCNT1+1
				Loop
			EndIF

			LCALSLBRU  := .F.

			IF ( !LCALSLLIQ )
				NVALPENSAO := 0
				S_CALC_PEN()
			EndIF
		EndIF

		NCNT1:=NCNT1+1
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava as Pensoes calculadas pelo Liquido.                           ³
	//³ cPensOUT := SUPERGETMV("MV_DIASPER",,"N")                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LEN(aPensOUT) > 0
		For nQ := 1 TO LEN(aPensOUT)

			If aPensOUT[nQ,2] > 0
				FO_ADD( @&COBJETO, {CCPOPD, CCPOVALOR, CCPOHORAS, CCPONPAGTO, CCPOTIPO1, CCPODATA},;
						{aPensOUT[nQ,1], aPensOUT[nQ,2], aPensOUT[nQ,3], aPensOUT[nQ,4], aPensOUT[nQ,5], aPensOUT[nQ,6]} )
			EndIf
		Next nQ
	EndIf

	IF (( CTIPOROT=="6" ).OR.( (CTIPOROT == "4" .AND. CTIPO == "132") ))

		NCNT1:=1

		While ( NCNT1<=LEN(ACODBENEF) )
			CPENSAO:=ACODBENEF[NCNT1,1]
			CVB131:=ACODBENEF[NCNT1,7]

			IF ( LEN (ACODBENEF[NCNT1]) > 16 )
				DDTFIMPG := ACODBENEF[NCNT1,18]
				DDTINIPG := ACODBENEF[NCNT1,17]
				LDTPEN:=.T.
			EndIF

			IF ( (EMPTY(DDTFIMPG) .OR. DDTFIMPG > DDATADE ) .AND. (!EMPTY(DDTINIPG) .AND. DDTINIPG < DDATAATE) .OR. !LDTPEN )

				IF ( FO_SEEK(@&COBJETO, {CCPOPD, CCPONPAGTO}, {CVB131, CNUMPAG} ) )

					NVLPRIPAR:=FO_GETVAL(@&COBJETO, CCPOVALOR)

					IF ( FO_SEEK(@&COBJETO, {CCPOPD, CCPONPAGTO} , {CPENSAO, CNUMPAG } ) )
						FO_SETVAL(@&COBJETO, CCPOVALOR, NOROUND(FO_GETVAL(@&COBJETO, CCPOVALOR) - NVLPRIPAR, 2 )  )
					EndIF
				EndIF

				IF ( FO_SEEK(@&COBJETO, {CCPOPD, CCPONPAGTO} , {CPENSAO , CNUMPAG} ) )
					IF ( FO_GETVAL(@&COBJETO, CCPOVALOR)<0 )
						FO_SETVAL(@&COBJETO, CCPOVALOR, 0 )
					EndIF
				EndIF

				IF ( FO_SEEK(@&COBJETO, {CCPOPD, CCPONPAGTO} , {CVB131, CNUMPAG} ) )
					FO_SETVAL(@&COBJETO, CCPOVALOR, 0)
				EndIF
			EndIF

			NCNT1:=NCNT1 + 1

			IF ( POSSRV(FO_GETVAL(@&COBJETO, CCPOPD), SRA->RA_FILIAL, "RV_TIPOCOD" ) $ "2|4" )
				NVALBASE-=FO_GETVAL(@&COBJETO, CCPOVALOR)
			EndIF
		EndDo

		IF ( (NVLPRIPAR > 0) .AND. !FO_SEEK(@&COBJETO, {CCPOPD, CCPOTIPO2}, {FGETCODFOL("0173"), "I"}) )
			FO_ADD(@&COBJETO, {CCPOPD, CCPOVALOR} , { FGETCODFOL("0173"), NVLPRIPAR} )
		EndIF
	EndIF

End Sequence
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fSeek0126 º Autor ³ Equipe IP-RH GSP   º Data ³ 09/09/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Busca as verbas de Liquido de Rescisao no Mesmo Mes        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus Versao 11.90                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fSeek0126(dDem, cPer, cSem)
	Local aArea     := GetArea()
	Local cQuery	:= ""
	Local nRet 		:= 0

	Default dDem	:= SRA->RA_DEMISSA
	Default cPer  	:= GETPERIODCALC()
	Default cSem  	:= GETNUMPGCALC()

	cQuery := " SELECT SRR.* FROM " + RETSQLNAME("SRG") + " SRG "
	cQuery += " INNER JOIN " + RETSQLNAME("SRR") + " SRR ON SRR.D_E_L_E_T_ = ' ' "
	cQuery += " AND RR_FILIAL = RG_FILIAL AND RR_MAT = RG_MAT "
	cQuery += " WHERE SRG.D_E_L_E_T_ = ' ' "
	cQuery += " AND RG_FILIAL = '"+ SRA->RA_FILIAL +"' "
	cQuery += " AND RG_MAT = '"+ SRA->RA_MAT +"' "
	cQuery += " AND RG_DATADEM = '"+ DTOS(dDem) +"' "
	cQuery += " AND RG_PERIODO = '"+ cPer +"' "
	cQuery += " AND RG_SEMANA < '"+ cSem +"' "
	cQuery += " AND RR_PD = '"+ fGetCodFol("0126") +"' "

	If Select("TRB0126") > 0
		TRB0126->(DbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB0126", .F., .T.)
	dbSelectArea("TRB0126")
	While !Eof()
		nRet += TRB0126->RR_VALOR
		dbSkip()
	EndDo
	TRB0126->( dbCloseArea() )
	RestArea( aArea )
Return(nRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} fMed13Gfp()
Função para cálculo das médias de 13 Folha Pública
@return
@author	    Esther de Viveiro
@since		18/06/1989
@version	P12.1.17
/*/
//------------------------------------------------------------------------------
Function fMed13Gfp()
Local lParam := IF(cTipoRot = "6", IF (cCompl13 = 'S',.T.,.F.), .F.)
Local nPerc13 := IIF(cTipoRot = "6", 1, (aPergunte[01,3]/100))

Private cMedDir        	:= SuperGetmv("MV_MEDDIRE", , 	 ,SRA->RA_FILIAL)

	nMedia := 0
	If ( GpexMed(CtoD("//"), CtoD("//")  ,dDataRef,CtoD("//")  ,dDataRef ,SalHora,Val_SalMin,aCodFol, lParam, lParam) )
		If ( fPosReg(cTBLXMED,1,SRA->RA_FILIAL+SRA->RA_MAT+"3"+"998"+"9998") )
			nAvosFal13 := (cTBLXMED)->RP_HORAS
		EndIf

		nMedPer := nMedIns := 0.00
		fMedPerIns(@nMedPer,@nMedIns,'3',SalHora,Val_SalMin,aCodFol)

		If ( (nMedPer > 0.00 .AND. aCodFol[0181,1] # SPACE(3)) .AND. aScan(aPD, {|X| X[1] == aCodFol[0181,1] .AND. X[7] == "I"}) == 0 )
		//o valor nMedPer só volta positivo quando o cálculo é sobre verbas.
			fGeraVerba(aCodFol[0181,1],nMedPer)
			nMedia += nMedPer
		EndIf

		If ( (nMedIns > 0.00 .AND. aCodFol[0182,1] # SPACE(3)) .AND. aScan(aPD, {|X| X[1] == aCodFol[0182,1] .AND. X[7] == "I"}) == 0 )
		//o valor nMedIns só volta positivo quando o cálculo é sobre verbas.
			fGeraVerba(aCodFol[0182,1],nMedIns )
			nMedia += nMedIns
		EndIf

		If !Empty(aCodFol[0123,1]) .AND. If(cTipoRot = "6", !Empty(aCodFol[0124,1]), .T.)
			If ( CMEDDIR = "N" )
				If ( (fPosReg(cTBLXMED,1,SRA->RA_FILIAL+SRA->RA_MAT+"3"+"999"+ If(cTipoRot = "5", "9999", "9799")) ) .AND. aScan(aPD, {|X| X[1] == aCodFol[0123,1] .AND. X[7] == "I"}) == 0 )
					fGeraVerba(aCodFol[0123,1],Round((((cTBLXMED)->RP_VALATU * NAVOS/12) * NPERC13),2) )
					nMedia += Round((((cTBLXMED)->RP_VALATU * NAVOS/12) * NPERC13),2)
				EndIf
				If ( cTipoRot = "6" )
					If ( (fPosReg(cTBLXMED,1,SRA->RA_FILIAL+SRA->RA_MAT+"3"+"999"+"9899")) .AND. aScan(aPD, {|X| X[1] == aCodFol[0124,1] .AND. X[7] == "I"}) == 0 )
						fGeraVerba(aCodFol[0124,1],Round((((cTBLXMED)->RP_VALATU * NAVOS/12) * NPERC13),2) )
						nMedia += Round((((cTBLXMED)->RP_VALATU * NAVOS/12) * NPERC13),2)
					EndIf
				EndIf
			Else
				If ( fPosReg(cTBLXMED,1,SRA->RA_FILIAL+SRA->RA_MAT+"3"+"999"+If(cTipoRot= "5", "99MD", "97MD")) )
					fGeraVerba(aCodFol[0123,1], Round((cTBLXMED)->RP_VALATU * NPERC13 ,2) )
					nMedia += Round((cTBLXMED)->RP_VALATU * NPERC13 ,2)
				EndIf

				If ( cTipoRot = "6" )
					If ( (fPosReg(cTBLXMED,1,SRA->RA_FILIAL+SRA->RA_MAT+"3"+"999"+"98MD")) .AND.  aScan(aPD, {|X| X[1] == aCodFol[0124,1] .AND. X[7] == "I"}) == 0 )
						fGeraVerba(aCodFol[0124,1], Round((cTBLXMED)->RP_VALATU * NPERC13 ,2))
						nMedia += Round((cTBLXMED)->RP_VALATU * NPERC13 ,2)
					EndIf
				EndIf
			EndIf
		Else
			If ( fPosReg(cTBLXMED,1,SRA->RA_FILIAL+SRA->RA_MAT+"3") )
				While ( ! (cTBLXMED)->(EOF()) .AND. SRA->RA_FILIAL+SRA->RA_MAT = (cTBLXMED)->RP_FILIAL+(cTBLXMED)->RP_MAT )
					If ( !((cTBLXMED)->RP_PD = "999" .OR. (cTBLXMED)->RP_TIPO # "3" .OR. !(cTBLXMED)->RP_DATARQ $ "9999  ") ) .AND. (aScan(aPD, {|X| X[1] == (cTBLXMED)->RP_PD .AND. X[7] == "I"}) == 0)
						If ( CMEDDIR = "N" )
							fGeraVerba((cTBLXMED)->RP_PD, Round(((cTBLXMED)->RP_VALATU * NAVOS/12) * NPERC13 ,2), ((cTBLXMED)->RP_HORAS * NAVOS /12))
							nMedia += Round(((cTBLXMED)->RP_VALATU * NAVOS/12) * NPERC13 ,2)
						Else
							fGeraVerba((cTBLXMED)->RP_PD, Round((cTBLXMED)->RP_VALATU * NPERC13 ,2), (cTBLXMED)->RP_HORAS)
							nMedia += Round((cTBLXMED)->RP_VALATU * NPERC13 ,2)
						EndIf
					EndIf
					(cTBLXMED)->(DBSKIP())
				End
			EndIf
		EndIf
	EndIf

	If ( fPosReg(cTBLXMED,1,SRA->RA_FILIAL+SRA->RA_MAT+"3"+"997"+"9598") )

		NANTEC13:= (cTBLXMED)->RP_VALATU
		If ( cTipoRot == "6" .AND. aScan(aPD, {|X| X[1] == aCodFol[0183,1] .AND. X[7] == "I"}) == 0 )
			fGeraVerba(aCodFol[0183,1], NANTEC13)
		EndIf
	EndIf

Return (.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} fSRHGFP()
Função que retorna os dias a serem pagos pela empresa, dentro do AnoMes passado
no parametro
@author	    Silvia Taguti
@since		08/10/2018
@version	P12
/*/

Function fSRHGFP(dBasIni,dDataIni,nDGoz )

Local aArea     := GetArea()
Local lRet      := .F.


Default dBasIni :=  CtoD("//")
Default dDataIni:=  CtoD("//")
Default NDGOZ	:= 0


dbSelectArea("SRH")
dbSetOrder(1)  //RH_FILIAL+RH_MAT+DTOS(RH_DATABAS)+DTOS(RH_DATAINI)
DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + DTOS(dBasIni) + Dtos(dDataIni))

Return ( lRet )


//------------------------------------------------------------------------------
/*/{Protheus.doc} fdFerResFP()
Função para calcular os dias de Férias Vencidas e Proporcionais para preencher o cabeçalho da rescisão.
@author	    Esther Viveiro
@since		25/03/2019
@version	P12
@param		lGpexmed, dtAviso
/*/
Function fdFerResFP( lGpexmed, dtAviso )

Local nDifMes	:= 0
Local aPerAtual	:= {}
Local aPerFerAux:= {}
Local aTabS106	:= {}
Local nPos		:= 0
Local nX		:= 0
Local nFerA		:= 0
Local nFerV		:= 0
Local nRecAux	:= 0
Local cCodFer	:= ""
Local dNPa		:= CtoD("")
Local dDatFimPA	:= CtoD("")
Local nDiasFer  := 0

	dDataDem := dtAviso

	If SRA->RA_CATFUNC $ "E*G"   // Estagiario Mensalista/Horista
		cCodFer	:= FGETCODFOL( "0891" )
	Else
		cCodFer	:= FGETCODFOL( "0072" )
	EndIf

	If Type("aTabFer") <> "U" .And. Type("aTabFer2") <> "U"
		fTab_Fer(@aTabFer,,@aTabFer2)
	EndIf

	//Ferias Vencias, Ferias a Vencer, Ferias Indenizadas, Ferias Antecipadas
	nDFerV 	 := 0
	nDFerA 	 := 0
	nDFerInd := 0
	nDFerAnt := 0

	FCARRTAB(@aTABS106,"S106", dDataDem , .T. )
	If Len(aTabS106[1]) > 15
		nPos106  := ASCAN(ATABS106, {|X| X[10] == cCodFer .AND. X[16] == SRA->RA_SINDICA .AND. SRA->RA_CATFUNC $ X[11] .AND. SRA->RA_REGIME $ X[12]} )
		If nPos106 > 0
			nDiasFer := ATABS106[nPos106,15] / ATABS106[nPos106,14]
			nDiasAux := ATABS106[nPos106,15]
		EndIf
	EndIf
	If nPos106 == 0
		nPos106  := ASCAN(ATABS106, {|X| X[10] == cCodFer .AND. EMPTY(X[16]) .AND. SRA->RA_CATFUNC $ X[11] .AND. SRA->RA_REGIME $ X[12]} )
		If nPos106 > 0
			nDiasFer := ATABS106[nPos106,15] / ATABS106[nPos106,14]
			nDiasAux := ATABS106[nPos106,15]
		EndIf
	EndIf

	DbSelectArea("SRF")
	DbSetOrder(2)

	cSeekSRF := SRA->RA_FILIAL + SRA->RA_MAT + cCodFer
	dDtSRFAux := CtoD("")

	dDatFimPA := CtoD("//")
	If DbSeek(cSeekSRF)
		If SRF->RF_STATUS $ " *1*0"
			nRecAux := SRF->(Recno()) //Grava o primeiro registro aberto da SRF
		EndIf
		nX := 0
		While SRF->(!Eof() .and. RF_FILIAL + RF_MAT + RF_PD == cSeekSRF )
			If !(cCompl == "S") .AND. (SRF->RF_STATUS $ " *1*0" .and. ( SRF->RF_DFERVAT > 0 .or. SRF->RF_DFERAAT > 0  .or. SRF->RF_DVENPEN > 0 ) )  //Carrega o primeiro periodo aquisitivo com dias vencidos ou a vencer
	
					aAdd(aPerFerAux,{	SRF->RF_DATABAS	,;															//aPerFerAux[01] - Inicio Database de Ferias
										If(Empty(SRF->RF_DATAFIM),fFimAqFP(SRF->RF_DATABAS),SRF->RF_DATAFIM)	,;	//aPerFerAux[02] - Final Database de Ferias
										SRF->RF_DFERVAT	,;															//aPerFerAux[03] - Dias de ferias vencidas
										SRF->RF_DFERAAT	,;															//aPerFerAux[04] - Dias de ferias a vencer
										0.00			,;															//aPerFerAux[05] - Dias totais de afastamento por periodo
										SRF->RF_OBSERVA	,;															//aPerFerAux[06] - Descricao do tipo de afastamento do periodo
										CtoD("")		,;															//aPerFerAux[07] - Data de original de termino do p.aquisitivo quando houver prorrogacao do mesmo RWX
										If(Empty(SRF->RF_STATUS),"1",SRF->RF_STATUS)	,;							//aPerFerAux[08] - Status do periodo de ferias:  0-Em Aquisição / 1-Ativo (Vencidos/A vencer) / 2-Prescrito (Perdido)/ 3-Pago
										CtoD("")		,;															//aPerFerAux[09] - Data de Inicio do Proximo periodo caso seja um periodo perdido.
										0				,;															//aPerFerAux[10] - Quantidade dias de deducao para o direito apurado no periodo
										SRF->RF_DVENPEN ,;															//aPerFerAux[11] - Dias Vencidos Pendentes
										SRF->RF_IVENPEN ,;															//aPerFerAux[12] - Data Inicia Vencido Pendente
										SRF->RF_FVENPEN ,;															//aPerFerAux[13] - Data Inicia Vencido Pendente
										SRF->RF_DFERANT ,;															//aPerFerAux[14] - Dias de Ferias Antecipadas
										SRF->RF_DFALVAT ,;															//aPerFerAux[15] - Dias de Faltas Vencidas
										SRF->RF_DFALAAT ,;															//aPerFerAux[16] - Dias de Faltas a Vencer
										NIL				,;															//aPerFerAux[17] - Dias de bono vencido
										NIL				,;															//aPerFerAux[18] - Dias de bono a Vencer
										0				,;															//aPerFerAux[19] - Total de dias de ferias
										0				,;															//aPerFerAux[20] - Total de dias de bonificacao
										0				,;															//aPerFerAux[21] - Dias de Faltas vencidas bonificacao
										0				,;															//aPerFerAux[22] - Dias de faltas a Vencer bonificacao
										0				,;															//aPerFerAux[23] - Dias de ausencia convertidos em ferias
										0				,;															//aPerFerAux[24] - Total de Dias de Ferias do Periodo
										SRF->RF_DIASANT ,;															//aPerFerAux[25] - Dias Gozados Vencidos
										SRF->RF_DIASANT	,;															//aPerFerAux[26] - Dias Gozados a Vencer
										0               ,;															//aPerFerAux[27] - Dias Subsid. Vencidos
										0               ,;															//aPerFerAux[28] - Dias Subsid. a Vencer
										0				,;															//aPerFerAux[29] - Dias de Pagto. Minimo na Adm/Dem (cpo. RF_PAGOFER desabilitado 08/2012)
										SRF->( RECNO() ),;															//aPerFerAux[30] - Recno do aquivo
										Iif(Type("SRF->RF_FERPAGA")<>"U",  SRF->RF_FERPAGA, 0) ,;					//aPerFerAux[31] - Dias pagos em R$ na folha
										SRF->RF_DATAATU	,;															//aPerFerAux[32] - Data de atualizacao
										0				;															//aPerFerAux[33] - Dias de suspensao do periodo
										})
					If Empty(nRecAux)
						nRecAux := SRF->(Recno()) //Grava o primeiro registro aberto da SRF
					EndIf
					nX++
					dDatFimPA := aPerFerAux[nX][2]
					If aPerFerAux[nX][2] >= dDataDem  //periodo aquisitivo em aquisicao
						
						nDifMes:=  DateDiffMonth(aPerFerAux[nx][1],dDataDem+1)
						If nDifMes > 0 .and. day(dDataDem+1) < 15
							nDifMes	-=	1		
						EndIf
						
						aPerFerAux[nX][4] := nDiasFer * nDifMes
						If  nDifMes > 0
							If  (DateDiffDay(aPerFerAux[nx][1],dDataDem) - (nDifMes * 30))  >= 15
								aPerFerAux[nX][4] += nDiasFer
							EndIf
						Else
							If DateDiffDay(aPerFerAux[nx][1],dDataDem) >= 15
								aPerFerAux[nX][4] += nDiasFer
							EndIf
						EndIf
					EndIf
				EndIf
				SRF->(DbSkip())
		EndDo
	EndIf
	nX := Len(aPerFerAux)
	While dDatFimPA < dDataDem .AND. nPos106 > 0
		dNPa := DaySum(dDatFimPA,1)
		dDatFimPA	:= Iif(ATABS106[nPos106][13]=="1",DaySum(dNPa-1, ATABS106[nPos106][14]), MonthSum(dNPa-1, ATABS106[nPos106][14]))
		aAdd(aPerFerAux,{	dNPa		,;										  				// 01 - Inicio Database de Ferias
							dDatFimPA	,;  													// 02 - Final Database de Ferias
							If(dDatFimPA <= dDataDem, ATABS106[nPos106][15],0)	,;				// 03 - Dias de ferias vencidas
							If(dDatFimPA <= dDataDem,0,(ATABS106[nPos106][15] / aTabS106[nPos106][14]) * Max(DateDiffMonth(dNPa,dDataDem+1),1))	,;	// 04 - Dias de ferias a vencer
							0.00		,;												// 05 - Dias totais de afastamento por periodo
							"	"		,;												// 06 - Descricao do tipo de afastamento do periodo
							CtoD("")	,;												// 07 - Data de original de termino do p.aquisitivo quando houver prorrogacao do mesmo RWX
							If(Empty(SRF->RF_STATUS),"1",SRF->RF_STATUS)	,;			// 08 - Status do periodo de ferias:  1-Ativo (Vencidos/A vencer)/2-Prescrito (Perdido)/3-Pago
							CtoD("")	,;						// 09 - Data de Inicio do Proximo periodo caso seja um periodo perdido.
							0	,0		,0		,0	,0			,0	,;	//aPerFerAux[10],aPerFerAux[11]aPerFerAux[12],aPerFerAux[13],aPerFerAux[14],aPerFerAux[15]
							0	,NIL	,NIL	,0	,0			,0	,;	//aPerFerAux[16],aPerFerAux[17]aPerFerAux[18],aPerFerAux[19],aPerFerAux[20],aPerFerAux[21]
							0	,0		,0		,0	,0			,0	,;	//aPerFerAux[22],aPerFerAux[23]aPerFerAux[24],aPerFerAux[25],aPerFerAux[26],aPerFerAux[27]
							0	,0		,0		,0 	,CtoD("")	,0	;	//aPerFerAux[28],aPerFerAux[29]aPerFerAux[30],aPerFerAux[31],aPerFerAux[32],aPerFerAux[33]
							})
		nX++
		If aPerFerAux[nX][2] > dDataDem //periodo aquisitivo em aquisicao
			nDifMes:= DateDiffMonth(aPerFerAux[nx][1],dDataDem+1)
			If nDifMes > 0 .and. day(dDataDem+1) < 15
				nDifMes	-=	1		
			EndIf
			aPerFerAux[nX][4] := (ATABS106[nPos106][15] / aTabS106[nPos106][14]) * nDifMes 

			If  nDifMes > 0
				If  DateDiffDay(aPerFerAux[nx][1],dDataDem) - (nDifMes * ATABS106[nPos106,15])  >= 15
					aPerFerAux[nX][4] += nDiasFer
				EndIf
			Else
				If DateDiffDay(aPerFerAux[nx][1],dDataDem) >= 15
					aPerFerAux[nX][4] += nDiasFer
				EndIf
			EndIf
		EndIf
	EndDo

	For nPos := 1 to Len(aPerFerAux)
		nFerV += aPerFerAux[nPos,3]
		nFerA += aPerFerAux[nPos,4]
	Next nPos

	If nPos106 > 0
		If nFerA >= ATABS106[nPos106,15]
			nFerV += (ATABS106[nPos106,15]* Int(ATABS106[nPos106,15]/nFerA))
			nFerA := Mod(nFerA, ATABS106[nPos106,15])
		Endif
	EndIf

	nDFerV += nFerV
	nDFerA += nFerA

	nDferven := nDferv	// Dias Ferias Indenizados sem aviso
	nDferave := nDfera	// Dias Ferias Proporcionais sem aviso

Return( Nil )


//------------------------------------------------------------------------------
/*/{Protheus.doc} fFimAqFP()
Função para calcular a data do Fim do Período Aquisitivo
@author	    Esther Viveiro
@since		25/03/2019
@version	P12
@param		dDtIni,
@param		cTipoRet
/*/
Function fFimAqFP(dDtIni,cTipoRet)
Local cDtFim, dDtFim
Local aGetArea    := GetArea()
Local aGetAreaRCA := RCA->( GetArea() )

STATIC cFerAnoCivil

cTipoRet := If(cTipoRet == Nil, "DATA", cTipoRet)

If cFerAnoCivil == "S"
	If cTipoRet == "DATA"
		dDtFim := CtoD("31/12/" + StrZero(Year(dDtIni),4),"DDMMYY")
	ElseIf cTipoRet == "ANOMES"
		dDtFim := StrZero(Year(dDtIni),4)+"12"
	EndIf
Else

//	If lGestPubl .AND. cPaisLoc == "BRA" .AND. SRA->RA_REGIME == "2" .AND. Type("aTabS106") # "A"
		aTabS106 := {}
		FCARRTAB(@aTabS106,"S106", dDataDem , .T. )
		If Len(aTabS106[1]) > 15
			nPosFerSind := ASCAN(ATABS106, {|X| X[10] == FGETCODFOL( "0072" ) .AND. !EMPTY(X[16]) .AND. X[16] == SRA->RA_SINDICA .AND. SRA->RA_CATFUNC $ X[11] .AND. SRA->RA_REGIME $ X[12]} )
			dDtFim := MonthSum(dDtIni,ATABS106[nPosFerSind,14]) - 1
		EndIf
		If nPosFerSind == 0
			nPosFerReg  := ASCAN(ATABS106, {|X| X[10] == FGETCODFOL( "0072" ) .AND. EMPTY(X[16]) .AND. SRA->RA_CATFUNC $ X[11] .AND. SRA->RA_REGIME $ X[12]} )
			dDtFim := MonthSum(dDtIni,ATABS106[nPosFerReg,14]) - 1
		EndIf

//	Else //FOLHA PADRAO

		If cTipoRet == "ANOMES"
			dDtFim := AnoMes(dDtFim)
		EndIf
	EndIf
//EndIf

//--Retorno para funcoes que nao inicializam cFerAnoCivil - Calc_Fer()
lPerFeAc := ( cFerAnoCivil == "S" )

RestArea( aGetAreaRCA )
RestArea( aGetArea )

Return dDtFim
