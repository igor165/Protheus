#INCLUDE  "PROTHEUS.CH"
#INCLUDE  "GFPXFUN.CH"


//------------------------------------------------------------------------------
/*/{Protheus.doc} fcRoteiros()
Função que retorna os Roteiros conforme os tipos passados como parametros
@return		cRoteiros
@author	    Fabricio Amaro
@since		17/01/2014
@version	P11.8

Wesley Alves  |27/02/19|DRHGCH-8415|Correção da impressão do Holerite quando  |
              |        |           |ocorre variação salarial dentro do período|


/*/
//cTipos = Tipos de Roteiros que deseja filtrar
//cNot   = Códigos dos tipos que deseja desconsiderar
//------------------------------------------------------------------------------

Function fcRoteiros(cTipos,cNot,cRot)
	Local aArea     := GetArea()
	Local cRoteiros := ""
	Local nCont     := 0
	Default cTipos  := "1*2*7"  //FOLHA - ADIANTAMENTO - OUTROS
	Default cNot    := ""
	dbSelectArea("SRY")
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		If SRY->RY_TIPO $ cTipos .AND. !(SRY->RY_CALCULO $ cNot) .AND. If( Empty(cRot), .T. , (SRY->RY_CALCULO $ cRot) )
			cRoteiros += If(nCont>0,"/","") + SRY->RY_CALCULO
			nCont++
		EndIf
		dbSkip()
	EndDo
	RestArea( aArea )
Return cRoteiros


//------------------------------------------------------------------------------
/*/{Protheus.doc} fDeleteSRC()
Apaga fisicamente os registros do SRC (Arq.Movimento Mes)
@return		Nil
@author	    Ademar Fernandes
@since		13/06/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function fDeleteSRC(cFil, cMat, cProc, cPer, cSem, cRot)

	Local cAliasSRC := InitSqlName("SRC")
	Local cQuery := ""

	cQuery += "DELETE FROM " + cAliasSRC + " "
	cQuery += "WHERE RC_FILIAL  = '" + cFil + "'"
	cQuery += "  AND RC_MAT     = '" + cMat + "'"
	cQuery += "  AND RC_PROCES  = '" + cProc + "'"
	cQuery += "  AND RC_PERIODO = '" + cPer  + "'"
	cQuery += "  AND RC_SEMANA  = '" + cSem  + "'"
	cQuery += "  AND RC_ROTEIR  = '" + cRot  + "'"

	TcSqlExec(cQuery)
	TcRefresh(cAliasSRC)
	dbCommit()
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} FRILRET()
Funcao que retorna os Servidores com direito a Designacoes, Exercicio Cumulativo, etc
@return
@author	    Ademar Fernandes
@since		26/06/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function FRILRET( dIni, dFim )
	Local aArea     := GetArea()
	Local cQuery	:= ""
	Local aRet 		:= {}

	Default dIni	:= dDataDe  // DA INICIAL DO PERIODO, CARREGADO PELA FORMULA CARGARCH
	Default dFim  	:= dDataAte // DA FINAL   DO PERIODO, CARREGADO PELA FORMULA CARGARCH

	cQuery := " SELECT * FROM " + RETSQLNAME("RIL") + " RIL "
	cQuery += " WHERE RIL_FILIAL = '"+ SRA->RA_FILIAL +"' "
	cQuery += "		AND RIL_MAT  = '"+ SRA->RA_MAT    +"' "
	cQuery += " 	AND ( RIL_INICIO <= '"+ DTOS(dFim) 	+"' AND "
	cQuery += " 		( RIL_FINAL = '"+ Space(08)  	+"' OR "
	cQuery += " 		  RIL_FINAL >= '"+ DTOS(dIni)  	+"') ) "
	cQuery += " 	AND RIL.D_E_L_E_T_ = ' ' "

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
	dbSelectArea("TRB")
	While !Eof()
		Aadd(aRet,{ TRB->RIL_DESIGN, STOD(TRB->RIL_INICIO), STOD(TRB->RIL_FINAL) })
		dbSkip()
	EndDo
	TRB->( dbCloseArea() )
	RestArea( aArea )
Return(aRet)


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} fGetFalDev
Busca as Faltas e Devoluções ocorridas num período específico
Função utilizada na rotina de Fechamento, Certidão Funcional e Relatório de Progressão Funcional
@protected
@sample		fGetFalDev(cRaFilial,cRaMat,dInicio,dFinal,aAPdFaltas,aAPdDevols,lSintetico,aTmpBru,lAnoCiv)
@param		cRaFilial	- Filial a ser pesquisada
			cRaMat		- Matrícula do Servidor a ser pesquisado
			dInicio		- Data de Início do periodo a ser pesquisado
			dFinal		- Data final do período a ser pesquisado
			aAPdFaltas	- Array das Faltas verba a verba apuradas para retornar por referência
			aAPdDevols	- Array das Devoluções verba a verba apuradas para retornar por referência
			lSintetico	- .T. = Sintético / .F. = Analítico
						  Se .T., então retorna o líquido de faltas menos devoluções.
						  Se .F., então retorna os arrays de Faltas e Devoluções.
			aTmpBru		- Array com os anos a serem pesquisados
			lAnoCiv		- .T. = Pesquisa ano civil, de 01/01 a 31/12 / .F. = Pesquisa pela data solicitada.
						  Este parâmetro respeita o dia limite, conforme parâmetro MV_VDDFADE
			dDtFim		- Data Final do Período RCH em curso
			dDtaIni		= Data Início do Período RCH em curso
@return		nLiqFal		- Se lSintetico = .T.
			{aFaltas, aDevols} - Se lSintetico = .F.
@author        Tania Bronzeri
@since         09/01/2014
@version       P11
/*/
//---------------------------------------------------------------------------------------
Function fGetFalDev(cRaFilial, cRaMat, dInicio, dFinal, aAPdFaltas, aAPdDevols, lSintetico, aTmpBru, lAnoCiv, dDtFim, dDtaIni)

	Local aFaltas		:= {}
	Local aDevols		:= {}
	Local nLiqFal		:= 0

	Local cPD0054	  	:= AllTrim(fGetCodFol("0054"))	//Faltas I//
	Local cPD0242	  	:= AllTrim(fGetCodFol("0242"))	//Faltas II
	Local cPD1364	  	:= AllTrim(fGetCodFol("1364"))	//Faltas III
	Local cPD1365	  	:= AllTrim(fGetCodFol("1365"))	//Faltas IV
	Local cPD0244	  	:= AllTrim(fGetCodFol("0244"))	//Dev.Faltas I
	Local cPD1363	  	:= AllTrim(fGetCodFol("1363"))	//Dev.Faltas II
	Local cPD1366	  	:= AllTrim(fGetCodFol("1366"))	//Dev.Faltas III
	Local cPD1367	  	:= AllTrim(fGetCodFol("1367"))	//Dev.Faltas IV
	Local aPdFaltas		:= {cPD0054, cPD0242, cPD1364, cPD1365}
	Local aPdDevols		:= {cPD0244, cPD1363, cPD1366, cPD1367}
	Local cFalPds		:= cPD0054 + "/" + cPD0242 + "/" + cPD1364 + "/" + cPD1365
	Local cDevPds		:= cPD0244 + "/" + cPD1363 + "/" + cPD1366 + "/" + cPD1367
	Local uRetorno
	Local nX, nY, nValor, nQtd	:= 0

	Default aAPdFaltas	:= {}
	Default aAPdDevols	:= {}
	Default aTmpBru     := {}
	Default lSintetico	:= .F.
	Default lAnoCiv		:= .T.
	Default dDtFim		:= dDatabase
	Default dDtaIni		:= SRA->RA_ADMISSA

	If lAnoCiv
		For nX:= 1 to Len(aTmpBru)
			For nY:= 1 to Len(aPdFaltas)
				fBuscaAcmPer(aPdFaltas[nY], , "H", @nValor, @nQtd, AnoMes(cTod("01/01/" + aTmpBru[nX][1])), AnoMes(cTod("31/12/" + aTmpBru[nX][1])), , , , .F., .F., DtoS(cTod("01/01/" + aTmpBru[nX][1])), DtoS(cTod("31/12/" + aTmpBru[nX][1])))
				aAdd(aFaltas, {aTmpBru[nX][1], aPdFaltas[nY], ABS(nQtd)})	//Ano, verba, quantidade de faltas
				nLiqFal += ABS(nQtd)
			Next
			For nY:= 1 to Len(aPdDevols)
				fBuscaAcmPer(aPdDevols[nY], , "H", @nValor, @nQtd, AnoMes(cTod("01/01/" + aTmpBru[nX][1])), AnoMes(cTod("31/12/" + aTmpBru[nX][1])), , , , .F., .F., DtoS(cTod("01/01/" + aTmpBru[nX][1])), DtoS(cTod("31/12/" + aTmpBru[nX][1])))
				aAdd(aDevols, {aTmpBru[nX][1], aPdDevols[nY], ABS(nQtd)})	//Ano, verba, quantidade de devoluções
				nLiqFal -= ABS(nQtd)
			Next
		Next
		uRetorno	:= Iif(lSintetico, nLiqFal, {aFaltas, aDevols})
	Else
		aFaltas		:= fBuscaAcmPer(cFalPds, , "H", @nValor, @nQtd, AnoMes(dInicio), AnoMes(dFinal), , , , .T., .F., DtoS(dInicio), DtoS(dFinal) )
		aDevols		:= fBuscaAcmPer(cDevPds, , "H", @nValor, @nQtd, AnoMes(dInicio), AnoMes(dDtFim), , , , .T., .F., DtoS(dInicio), DtoS(dDtFim) )
		If dInicio <= dDtaFim .And. dFinal >= dDtaIni
			fTemFalMes(@aFaltas, aPdFaltas, dInicio, dFinal)
		EndIf
		If dInicio <= dDtaFim .And. dDtFim >= dDtaIni
			fTemDevMes(@aDevols, aPdDevols, dInicio, dFinal)
		EndIf
		uRetorno	:= {aFaltas, aDevols}
	EndIf

Return uRetorno

//------------------------------------------------------------------------------
/*/{Protheus.doc} fBuscaSal1()
Função que retorna o valor do Salario com base na SR3 da data passada no parametro
@return		nSalario
@author	    Fabricio Amaro
@since		31/10/2013
@version	P11.8
/*/
// dData = Data de Referencia para a pesquisa
// cFil = Filial e cMat = Matricula <== Passar somente se a SRA não estiver posicionada na função que a chamou
// Existe no padrão a função fBuscaFunc, porém, ela retorna o valor do ultimo dia do período,
// e não da data passada no parametro.
//------------------------------------------------------------------------------
Function fBuscaSal1(dData, cFil, cMat, lSalComis, nSubstituto, lPortal)

	Local aArea		:= GetArea()
	Local nSalario

	Default dData		:= dDataBase
	Default cFil		:= ""
	Default cMat		:= ""
	Default lSalComis	:= .F.
	Default nSubstituto	:= 0	//-Salario do Substituto
	Default lPortal		:= .F.

	If Empty(cFil)
		cFil  := SRA->RA_FILIAL
		cMat  := SRA->RA_MAT
	EndIf

	cQryTmp := " SELECT R3_VALOR, R3_CSALAR, R3_DATA, R3_SEQ, R3_TPSBCOM, R3_PERCCOM, R3_DTCDISS "
	cQryTmp += " FROM " + RETSQLNAME("SR3")
	cQryTmp += " WHERE R3_FILIAL = '" + cFil + "' "
	cQryTmp += " AND R3_MAT = '" + cMat + "' "
	cQryTmp += " AND R3_DATA <= '" + dtos(dData) + "' "
	cQryTmp += " AND R3_VALOR > 0 "

	If lPortal
		cQryTmp += " AND R3_PD = '000'"
		cQryTmp += " AND R3_DTCDISS <= '" + dtos(dData) + "' "
	EndIf

	cQryTmp += " AND D_E_L_E_T_ = ' ' "
	cQryTmp += " ORDER BY R3_DATA DESC, R3_SEQ DESC "

	//EXECUTA A SELECAO DE DADOS
	cQryTmp := ChangeQuery(cQryTmp)

	If Select("XSR3") > 0
		XSR3->(DbCloseArea())
	EndIf

	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'XSR3', .F., .T. )

	If !XSR3->(Eof())
		If lSalComis .And. XSR3->R3_CSALAR > 0
			/*
			R3_TPSBCOM = 1 ( Diferenca dos Subsidios )
			R3_TPSBCOM = 2 ( Percentual sobre Subsidio do Comissionado )
			*/
			If nSubstituto > 0 .And. XSR3->R3_TPSBCOM == "2"
				nSalario := Round((XSR3->R3_CSALAR * XSR3->R3_PERCCOM / 100), MSDECIMAIS(1))
			Else
				nSalario := XSR3->R3_CSALAR
			EndIf
		Else
			nSalario := XSR3->R3_VALOR
		EndIf
	Else
		If !Empty(cFil) //Caso o Funcionáro não esteja posicionado, o parametro deve ser passado
			dbSelectArea("SRA")
			dbSetOrder(1)
			dbSeek(cFil+cMat)
		EndIf
		nSalario := SRA->RA_SALARIO
	EndIf

	XSR3->(DbCloseArea())
	RestArea( aArea )

Return nSalario


//------------------------------------------------------------------------------
/*/{Protheus.doc} CategSR7()
Função que retorna um Array com base no Histórico de Funções - SR7 e Alterações de Departamentos - SRE
	1 - Categoria
	2 - Data inicial
	3 - Data Final
	4 - Numero de dias
	5 - Função
	6 - Cargo
	7 - Departamento (com base na SRE)
	8 - Salario (com base na SR3)
	9 - Faltas <== Quando executado pela função fPropFal()
	10 - Dev. Faltas <== Quando executado pela função fPropFal()
Parametros recebidos:
		 	[1]- cFil 		= Filial
		  	[2]- cMat 		= Matricula
		  	[3]- dIni	 	= Periodo Inicial de Pesquisa
		  	[4]- dFim	 	= Periodo Final de Pesquisa
		  	[5]- lIniMes 	= .T. Indica se deve considerar o 1o dia do mes do dIni 	| .F. Considera a mesma data
		  	[6]- lFimMes	= .T. Indica se deve considerar o ultimo dia do mes do dFim | .F. Considera a mesma data
@return		A
@author	    Fabricio Amaro
@since		30/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function CategSR7(cFil,cMat,dIni,dFim,lIniMes,lFimMes)
	Local aArea     := GetArea()
	Local aPerCat	:= {}
	Local cCat  	:= ""
	Local dData 	:= Stod("")
	Local lAdmMes 	:= .F.
	Local cFuncao	:= ""
	Local cCargo	:= ""
	Local aDepto 	:= {}

	Default cFil 	 := ""
	Default cMat 	 := ""
	Default dIni     := FirstDay(dDataBase)
	Default dFim     := LastDay(dDataBase)
	Default lIniMes  := .T.
	Default lFimMes  := .T.

	//Posiciona no funcionario
	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek(cFil+cMat)

	//SE A COMPETENCIA NAO FOR O MESMO DA ADMISSÃO
	If !(MesAno(SRA->RA_ADMISSA) == MesAno(dIni))

		//PRIMEIRO PESQUISO QUAL A CATEGORIA ANTES DA DATA PARAMETRIZADA
		cQryTmp := " SELECT R7_CATFUNC,R7_FUNCAO,R7_CARGO FROM " + RETSQLNAME("SR7")
		cQryTmp += " WHERE R7_FILIAL = '" + cFil + "' "
		cQryTmp += " AND R7_MAT 	 = '" + cMat + "' "
		cQryTmp += " AND R7_DATA 	 < '" + dtos(dIni) + "' "
		cQryTmp += " AND D_E_L_E_T_ = ' ' "
		cQryTmp += " ORDER BY R7_DATA DESC, R7_SEQ DESC "

		//EXECUTA A SELEÇÃO DE DADOS
		cQryTmp := ChangeQuery(cQryTmp)
		If Select("XSR7") > 0
			XSR7->(DbCloseArea())
		EndIf
		dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'XSR7', .F., .T. )

		If !XSR7->(Eof())
			cCat  	:= XSR7->R7_CATFUNC
			cFuncao	:= XSR7->R7_FUNCAO
			cCargo	:= XSR7->R7_CARGO
			dData 	:= If(lIniMes,firstday(dIni),dIni)
		Else  //SE NÃO ENCONTROU NADA, PEGA A CATEGORIA ATUAL DA SRA
			cCat  	:= SRA->RA_CATFUNC
			cFuncao	:= SRA->RA_CODFUNC
			cCargo	:= SRA->RA_CARGO
			dData 	:= If(lIniMes,FirstDay(dIni),dIni) //SRA->RA_ADMISSA
		EndIf
		XSR7->(DbCloseArea())

	Else //SE FOR O MESMO DA ADMISSÃO, PEGA A PROPRIA ADMISSÃO
		cCat  	:= SRA->RA_CATFUNC
		dData 	:= SRA->RA_ADMISSA
		cFuncao	:= SRA->RA_CODFUNC
		cCargo	:= SRA->RA_CARGO
		lAdmMes := .T.
	EndIf

	cQryTmp := " SELECT DISTINCT R7_CATFUNC,R7_DATA,R7_FUNCAO,R7_CARGO,R7_SEQ "
	cQryTmp += " FROM " + RETSQLNAME("SR7") + " SR7 "
	cQryTmp += " WHERE R7_FILIAL = '" + cFil + "' "
	cQryTmp += " AND R7_MAT 	 = '" + cMat + "' "
	cQryTmp += " AND R7_DATA 	>= '" + dtos(dIni)  + "' "
	cQryTmp += " AND R7_DATA 	<= '" + dtos(dFim) + "' "
	cQryTmp += " AND D_E_L_E_T_ = ' ' "
	cQryTmp += " ORDER BY R7_DATA,R7_SEQ "

	//EXECUTA A SELEÇÃO DE DADOS
	cQryTmp := ChangeQuery(cQryTmp)
	If Select("XSR7") > 0
		XSR7->(DbCloseArea())
	EndIf
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'XSR7', .F., .T. )
	If !XSR7->(Eof())

		If !(cCat == XSR7->R7_CATFUNC)  //SE NÃO FOR DA MESMA CATEGORIA, ARMAZENA
			aDepto   := PesqSRE(dData)
			nSalario := fBuscaSal1(dData,cFil,cMat)  //NÃO FOI POSSIVEL USAR A FUNÇÃO FBUSCASAL POIS ELE RETORNA O SALARIO DO ULTIMO DIA DO PERIODO PASSADO NA DATA
			AADD(aPerCat,{cCat,dData,stod(XSR7->R7_DATA)-1,stod(XSR7->R7_DATA) - dData,cFuncao,cCargo,aDepto[1][2],nSalario,0,0})
			cCat  	:= XSR7->R7_CATFUNC
			cFuncao	:= XSR7->R7_FUNCAO
			cCargo	:= XSR7->R7_CARGO
			dData 	:= stod(XSR7->R7_DATA)
		EndIf
		If !XSR7->(Eof())
			While !XSR7->(Eof())
				dbSkip()

				If !(cCat == XSR7->R7_CATFUNC)
					If Empty(XSR7->R7_DATA)
						dDataFim := If(lFimMes,LastDay(dFim),dFim)
					Else
						dDataFim := STOD(XSR7->R7_DATA) - 1
					EndIf

					aDepto := PesqSRE(dData)
					nSalario := fBuscaSal1(dData,cFil,cMat)
					AADD(aPerCat,{cCat,dData,dDataFim,dDataFim - dData+1,cFuncao,cCargo,aDepto[1][2],nSalario,0,0})
					dData := dDataFim+1
				EndIf
				cCat  	:= XSR7->R7_CATFUNC
				cFuncao	:= XSR7->R7_FUNCAO
				cCargo	:= XSR7->R7_CARGO
			EndDo
		Else
			aDepto 	 := PesqSRE(dData)
			nSalario := fBuscaSal1(dData,cFil,cMat)
			dDataFim := If(lFimMes,LastDay(dFim),dFim)
			AADD(aPerCat,{cCat,dData,dDataFim,dDataFim - dData+1,cFuncao,cCargo,aDepto[1][2],nSalario,0,0})
		EndIf
	Else
		dDataFim := If(lFimMes,LastDay(dFim),dFim)
		dData	 := If( lAdmMes , dData , If(lIniMes,FirstDay(dIni),dIni) )
		aDepto 	 := PesqSRE(dData)
		nSalario := fBuscaSal1(dData,cFil,cMat)
		AADD(aPerCat,{cCat,dData,dDataFim,dDataFim - dData+1,cFuncao,cCargo,aDepto[1][2],nSalario,0,0})
	EndIf
	XSR7->(DbCloseArea())

	RestArea( aArea )
Return aPerCat


//------------------------------------------------------------------------------
/*/{Protheus.doc} fPropFal()
Função que adiciona no Array aPerCat, originado da função CategSR7, os dias de Faltas
e Devolução de Faltas, proporcionalizando conforme os dias da categoria
@return		aPerCat
@author	    Fabricio Amaro
@since		07/11/2013
@version	P11.8
/*/
//aPerCat    := Array originado na função CategSR7
//nFaltas    := Total de dias de FALTAS
//nDevFaltas := Total de dias de Devolução de Faltas
//------------------------------------------------------------------------------
Function fPropFal(aPerCat,nFaltas,nDevFaltas)
	Local i 		:= 0
	Local nDiasTot 	:= 0
	Local nFalProp	:= 0
	Local nDFalProp	:= 0

	Local nFalTot	:= 0
	Local nDFalTot	:= 0

	//Primeiro verifico o total de dias
	For i := 1 to Len(aPerCat)
		nDiasTot += aPerCat[i][4]
	Next

	//Agora com o total de dias, efetua a proporcionalização
	For i := 1 to Len(aPerCat)
		nPerc 	 := Round( (aPerCat[i][4] / nDiasTot) * 100 , 2)

		//SEMPRE CALCULA A FALTA INTEIRA
		nFalProp  := Int(nFaltas    * (nPerc/100))
		nDFalProp := Int(nDevFaltas * (nPerc/100))

		nFalTot		+= nFalProp
		nDFalTot	+= nDFalProp

		If i == Len(aPerCat)  //SE FOR O ULTIMO REGISTRO, SOMA O RESTANTE DA FALTA (DECIMAIS)
			nFalProp  += nFaltas 	- nFalTot
			nDFalProp += nDevFaltas - nDFalTot
		EndIf

		//ALTERA O ARRAY COM AS FALTAS E DEVOLUÇÕES
		aPerCat[i][9]  := nFalProp
		aPerCat[i][10] := nDFalProp

	Next

Return aPerCat


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} fTemFalMes
Busca as Faltas ocorridas no período corrente
@sample		fTemFalMes(aFaltas)
@param		aFaltas	- carregada com as faltas da SRC
@return		aFaltas - devolve por referência
@author		Tania Bronzeri
@since      03/04/2014
@version    P11.9
/*/
//---------------------------------------------------------------------------------------
Function fTemFalMes(aFaltas, aPdFaltas, dInicio, dFinal)

	Local aAreaSRC	:= GetArea()
	Local nF		:= 0
	Local nIdx		:= 0
	Local cKey		:= ""
	Local lRotei	:= Iif(Empty(cRoteiro),.F.,.T.)

	If lRotei
		nIdx	:= RetOrder("SRC","RC_FILIAL+RC_PD+RC_PROCES+RC_PERIODO+RC_ROTEIR+RC_MAT")
	Else
		nIdx	:= RetOrder("SRC","RC_FILIAL+RC_MAT+RC_PD+RC_ROTEIR+DTOS(RC_DATA)")
	EndIf

	DbSelectArea("SRC")
	DbSetOrder(nIdx)
	For nF := 1 to Len(aPdFaltas)
		If lRotei
			cKey	:= SRA->RA_FILIAL + aPdFaltas[nF] + cProcesso + cPeriodo + cRoteiro + SRA->RA_MAT
		Else
			cKey	:= SRA->RA_FILIAL + SRA->RA_MAT + aPdFaltas[nF]
		EndIf
		If DbSeek(cKey)
			If lRotei
				While !Eof() .And. (SRC->RC_FILIAL + SRC->RC_PD + SRC->RC_PROCES + SRC->RC_PERIODO + SRC->RC_ROTEIR + SRC->RC_MAT) = cKey
					If SRC->RC_DTREF >= dInicio .And. SRC->RC_DTREF <= dFinal
						aAdd(aFaltas, {aPdFaltas[nF], SRC->RC_HORAS, 0, SRC->RC_PERIODO})
					EndIf
					SRC->(DbSkip())
				EndDo
			Else
				While !Eof() .And. (SRC->RC_FILIAL + SRC->RC_MAT + SRC->RC_PD) = cKey
					If SRC->RC_DTREF >= dInicio .And. SRC->RC_DTREF <= dFinal
						aAdd(aFaltas, {aPdFaltas[nF],SRC->RC_HORAS,0,SRC->RC_PERIODO})
					EndIf
					SRC->(DbSkip())
				EndDo
			EndIf
		EndIf
	Next nF

	RestArea(aAreaSRC)

Return Nil


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} fTemDevMes
Busca as devoluções de faltas ocorridas no período corrente
@sample		fTemDevMes(aDevols)
@param		aDevols	- carregada com as devoluções da SRC
@return		aDevols - devolve por referência
@author		Tania Bronzeri
@since      03/04/2014
@version    P11.9
/*/
//---------------------------------------------------------------------------------------
Function fTemDevMes(aDevols, aPdDevols, dInicio, dFinal)
Local aAreaSRC	:= GetArea()
Local nD		:= 0
Local nIdx		:= 0
Local cKey		:= ""
Local lRotei	:= Iif(Empty(cRoteiro),.F.,.T.)

If lRotei
	nIdx	:= RetOrder("SRC","RC_FILIAL+RC_PD+RC_PROCES+RC_PERIODO+RC_ROTEIR+RC_MAT")
Else
	nIdx	:= RetOrder("SRC","RC_FILIAL+RC_MAT+RC_PD+RC_ROTEIR+DTOS(RC_DATA)")
EndIf

DbSelectArea("SRC")
DbSetOrder(nIdx)
For nD := 1 to Len(aPdDevols)
	If lRotei
		cKey	:= SRA->RA_FILIAL + aPdDevols[nD] + cProcesso + cPeriodo + cRoteiro + SRA->RA_MAT
	Else
		cKey	:= SRA->RA_FILIAL + SRA->RA_MAT + aPdDevols[nD]
	EndIf
	If DbSeek(cKey)
		If lRotei
			While !Eof() .And. (SRC->RC_FILIAL + SRC->RC_PD + SRC->RC_PROCES + SRC->RC_PERIODO + SRC->RC_ROTEIR + SRC->RC_MAT) = cKey
				If SRC->RC_DTREF >= dInicio .And. SRC->RC_DTREF <= dFinal
					aAdd(aDevols, {aPdDevols[nD],SRC->RC_HORAS,0,AnoMes(SRC->RC_DTREF)})
				EndIf
				SRC->(DbSkip())
			EndDo
		Else
			While !Eof() .And. (SRC->RC_FILIAL + SRC->RC_MAT + SRC->RC_PD) = cKey
				If SRC->RC_DTREF >= dInicio .And. SRC->RC_DTREF <= dFinal
					aAdd(aDevols, {aPdDevols[nD],SRC->RC_HORAS,0,AnoMes(SRC->RC_DTREF)})
				EndIf
				SRC->(DbSkip())
			EndDo
		EndIf
	EndIf
Next nD

RestArea(aAreaSRC)
Return Nil


//------------------------------------------------------------------------------
/*/{Protheus.doc} PesqSRE()
Função que retorna um Array com o conteúdo da Transferencia - SRE com base na data informada
Entende-se que o funcionário - SRA esteja posicionado
	1 - Centro de Custo
	2 - Departamento
	3 - Posto
	4 - Processo
	5 - Data da Transferencia
@return		C
@author	    Fabricio Amaro
@since		30/10/2013
@version	P11.8
@param		dData, data    , Data de Referencia para a pesquisa
@param		cFil, caractere, Filial da matricula a buscar <== Passar somente se a SRA não estiver posicionada na matricula referência
@param		cMat, caractere, matricula a buscar <== Passar somente se a SRA não estiver posicionada na matricula referência
/*/
//------------------------------------------------------------------------------
Function PesqSRE(dData,cFil,cMat)
	Local aArea      := GetArea()
	Local aTransf    := {}
	Local cSelectOra := IIf( "ORACLE" $ AllTrim(Upper(TcGetDb())) , " SELECT * FROM ( " , "" )

	Default dData := dDataBase
	Default cFil  := ""
	Default cMat  := ""

	cSelect := If( "MSSQL" $ AllTrim(Upper(TcGetDb())) .Or. AllTrim(Upper(TcGetDb())) == 'SYBASE' , " SELECT TOP 1 ", " SELECT " )
	cDB2 	:= If( "DB2" $ AllTrim(Upper(TcGetDb())) , " FETCH FIRST 1 ROWS ONLY " , " "  )

	cQryTmp := cSelectOra
	cQryTmp += " " + cSelect + " RE_DATA,RE_DEPTOP,RE_CCP,RE_POSTOP,RE_PROCESP FROM " + RETSQLNAME("SRE")
	cQryTmp += " WHERE RE_FILIALP 	= '"+SRA->RA_FILIAL+"' "
	cQryTmp += " AND RE_MATP 		= '"+SRA->RA_MAT+"' "
	cQryTmp += " AND RE_DATA 	   <= '"+ dtos(dData) +"' "
	cQryTmp += " AND D_E_L_E_T_ = ' ' "
	cQryTmp += " ORDER BY RE_DATA DESC " + cDB2

	If !Empty(cSelectOra)
		cQryTmp += " ) WHERE ROWNUM <= 1 "
	EndIf

	//EXECUTA A SELEÇÃO DE DADOS
	cQryTmp := ChangeQuery(cQryTmp)
	If Select("XSRE") > 0
		XSRE->(DbCloseArea())
	EndIf
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'XSRE', .F., .T. )
	If !XSRE->(Eof())
		AADD(aTransf,{XSRE->RE_CCP,XSRE->RE_DEPTOP,XSRE->RE_POSTOP,XSRE->RE_PROCESP,XSRE->RE_DATA})
	Else
		If !Empty(cFil) //Caso o Funcionáro não esteja posicionado, o parametro deve ser passado
			dbSelectArea("SRA")
			dbSetOrder(1)
			dbSeek(cFil+cMat)
		EndIf
		AADD(aTransf,{SRA->RA_CC,SRA->RA_DEPTO,SRA->RA_POSTO,SRA->RA_PROCES,SRA->RA_ADMISSA})
	EndIf
	XSRE->(DbCloseArea())
	RestArea( aArea )
Return aTransf


//------------------------------------------------------------------------------
/*/{Protheus.doc}fGetFolmes
Retornar .Ano/Mes do periodo aberto
@author IP RH GSP
@since 18/03/2014
@version P12
@param cFilRCH  , caractere, filial para busca na RCH
@param cProcesso, caractere, código do processo referência
@param cRoteiro , caractere, código do roteiro referência
@return caractere, período atual em aberto - AAAAMM
/*/
//------------------------------------------------------------------------------
Function fGetFolmes(cFilRCH,cProcesso,cRoteiro)
	Local cRet := ""
	Local aPerAtual := {}

	DEFAULT cFilRCH 	:= xFilial( "RCH" )
	DEFAULT cProcesso	:= SRA->RA_PROCES
	DEFAULT cRoteiro	:= fGetCalcRot('1')

	fGetPerAtual( @aPerAtual,cFilRCH,cProcesso,cRoteiro )

	If Len(aPerAtual) > 0
		cRet := aPerAtual[1,5]+aPerAtual[1,4] 	//RCH_ANO+RCH_MES
	EndIf
Return(cRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc}fUsaGFP
Verifica se utiliza o modulo de Gestao de Folha Publica (SIGAGFP)
@author IP RH GSP
@since 07/07/2015
@version P12
@return lógico, indica se Folha Pública está ativa.
/*/
//------------------------------------------------------------------------------
Function fUsaGFP()
Local lRet := .F.
	If cPaisLoc == 'BRA' .and. SuperGetMv("MV_SIGAGFP", NIL, "1") $ "2|3" // Modulo Gestao de Folha Publica 1=Nao; 2=Sim
		lRet := .T.
	EndIf
Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc}fBoxGFP
Monta o X3_CBOX do campo passado como parametro
@author IP RH GSP
@since 07/07/2015
@version P12
@param cCampo, caractere, campo referência para montagem do box.
@return caractere, Opções do comboBox do campo
/*/
//------------------------------------------------------------------------------
Function fBoxGFP(cCampo)
Local cOpcBox	:= ''
Default cCampo 	:= ''

	If alltrim(cCampo) == 'RF_STATUS'
		cOpcBox += if( fUsaGFP(), STR0001, STR0002 ) //'0=Em aquisicao;1=Ativo;2=Prescrito;3=Pago;4=Cancelado;5=Retificado' ###	'1=Ativo;2=Prescrito;3=Pago'
	Endif

Return(cOpcBox)


//------------------------------------------------------------------------------
/*/{Protheus.doc}VerDissSRD
Verifica na SRD se o funcionario possui registro no periodo.
Funcao executada pela formula S_VERIFDIS)
@author Marcos Pereira
@since 08/09/2014
@version P12
@return lógico, indica se há ou não cálculo nos Acumulados (SRD)
/*/
//------------------------------------------------------------------------------
Function VerDissSRD()
Local aArea		:= getArea()
Local aSRD 		:= SRD->(getArea())
Local lRet 		:= .t.
Local cPerCalc 	:= GETPERIODCALC()
Local cNumPgCal := GETNUMPGCALC()
Local cProcCalc := GetProcesCalc()

	SRD->(dbsetorder(5))
	If !(SRD->(dbseek( SRA->(RA_FILIAL+RA_MAT) + cProcCalc + cRot + cPerCalc + cNumPgCal )))
		lRet := .f.
	EndIf

	RestArea(aSRD)
	RestArea(aArea)

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} VldSubst()
valida a situação do substituto.
@return		C
@author	    Everson S P Junior
@since		24/12/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VldSubst(cFilSub,cMatSub)
Local cFilFunc	:= ""
Local cMat 		:= ""
Local cSitFol	:= ""
Local lRet		:= .T.

Default cFilSub := FWFldGet("R8_FILSUB")
Default cMatSub := FWFldGet("R8_MATSUB")

cFilFunc	:= FWFldGet("RA_FILIAL")
cMat 		:= FWFldGet("RA_MAT")

cSitFol		:= fDesc("SRA",cMatSub,"RA_SITFOLH",NIL,cFilSub,1)

If cMat == cMatSub .OR. cSitFol == 'D'
	Help(NIL, NIL, STR0003, NIL, STR0006, 1, 0, NIL, NIL, NIL, NIL, NIL, {""}) // Atenção - Substituto inválido. Selecione um novo substituto.
	lRet := .F.
EndIf

SRA->(DBSEEK(cFilFunc+cMat))

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc}gp240GrvRi8
Grava os Registro na Tabela RI8 Substitutos
@author Equipe RH
@since 24/04/2015
@version P12
@param oModel, obejto,modelo MVC da rotina de Ausências
/*/
//------------------------------------------------------------------------------
Function gp240GrvRi8(oModel)
Local oGrid 	:= oModel:GetModel("GPEA240_SR8")
Local dDtIni	:= oGrid:GetValue("R8_DATAINI")
Local cTipoAfa	:= oGrid:GetValue("R8_TIPOAFA")
Local cPeriodo	:= oGrid:GetValue("R8_PER")
Local cFilSub  	:= oGrid:GetValue("R8_FILSUB")
Local cMatSub  	:= oGrid:GetValue("R8_MATSUB")
Local dDtAte	:= oGrid:GetValue("R8_DATAFIM")
Local lGrvNew	:= oGrid:IsInserted()

If lGrvNew .AND. (Empty(cFilSub) .Or. Empty(cMatSub)) // Inclusão sem substituto
	Return
EndIf

RI8->(dbSetOrder(1))

If !oGrid:IsDeleted()
	If RI8->(DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + dtos(SR8->R8_DATAINI))) .Or. lGrvNew
		RecLock("RI8",lGrvNew)
		RI8_FILIAL		:= SRA->RA_FILIAL
		RI8_MAT			:= SRA->RA_MAT
		RI8_DATADE		:= dDtIni
		RI8_DATATE		:= dDtAte
		RI8_PERIOD		:= cPeriodo
		RI8_DIASDIR		:= POSICIONE("RCM",3, FwxFilial("RCM") + cTipoAfa,"RCM_DSUBST")
		RI8_FILSUB		:= cFilSub
		RI8_MATSUB		:= cMatSub
		RI8_DEPTO		:= SRA->RA_DEPTO
		RI8_FATGER		:= "2"
		RI8_ORIGEM      := "2"
		RI8_DIAS		:= oGrid:GetValue("R8_DURACAO")
		RI8->(MsUnlock())
	EndIf
Else
	If RI8->(DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + DToS(SR8->R8_DATAINI)))
		RecLock("RI8",.F.)
		RI8->(dbDelete())
		RI8->(MsUnlock())
	EndIf
EndIf

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc}QueryRI6
Verifica se ja existe registro na RI6
@author Everson SP Junior
@since 10/11/2013
@version P12
@param mChave, caractere, chave do registro.
@param cFil  , caractere, filial da matricula pesquisada
@param cMat  , caractere, matricula para pesquisa
@param cTab  , caractere, tabela de origem da publicação
@return caractere, status da publicação: NP - não publicado; P - publicado
/*/
//------------------------------------------------------------------------------
Function QueryRI6(mChave,cFil,cMat,cTab)
	Local cQuery := ''
	Local cRet   := 'NE' //Nao Existe

	Default cFil := SR8->R8_FILIAL
	Default cMat := SR8->R8_MAT
	Default cTab := "SR8"

	If Select("TRBRI6") > 0
		TRBRI6->( dbCloseArea())
	EndIf

	cQuery  := "SELECT * "
	cQuery  += " FROM " + RetSqlName( 'RI6' )
	cQuery  += " WHERE D_E_L_E_T_ = ' '
	cQuery  += " AND RI6_FILMAT   = '" + cFil + "'"
	cQuery  += " AND RI6_TABORI   = '" + cTab + "'"
	cQuery  += " AND RI6_MAT      = '" + cMat + "'"
	cQuery  += " AND RI6_CHAVE    = '" + mChave + "'"

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBRI6", .F., .T.)

	If !( TRBRI6->( EOF() ) )
		If Empty(TRBRI6->RI6_NUMDOC)
			cRet := 'NP' //Nao Publicado
		Else
			cRet := 'P' //Publicado'
		EndIf
	EndIf
Return cRet


//------------------------------------------------------------------------------
/*/{Protheus.doc}ExcluiRI6
Realzia a exclusão de registro na RI6
@author equipe RH
@since 01/06/2018
@version P12
/*/
//------------------------------------------------------------------------------
Function ExcluiRI6()
	MsgAlert(STR0004)//"O Item gerado anteriormente ainda não foi publicado e será alterado neste momento"
	RI6->(dbGoTo(TRBRI6->R_E_C_N_O_))
	RecLock("RI6",.F.,.T.)
	RI6->(dbDelete())
	RI6->(MsUnLock())
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc}DelAfasGFP
Deleta afastamento GFP. Realiza limpeza nas tabelas de publicações dos registros do afastamento apagado.
@author equipe RH
@since 01/06/2018
@version P12
@param aParTela, array, informações do afastamento a ser apagado.
@param mChavePesq, caractere, chave de pesquisa para a tabela RI6
@return lógico, resultado da validação.
/*/
//------------------------------------------------------------------------------
Function DelAfasGFP(aParTela, mChavePesq )
	Local lRet := .T.

	cRet := QueryRI6(mChavePesq,SR8->R8_FILIAL, SR8->R8_MAT,"SR8")

	If cRet == "NP"
		ExcluiRI6()
	ElseIf cRet == "P"
		MsgAlert(STR0005)//'O Item gerado anteriormente foi publicado. Deve ser feito um novo item para o cancelamento '
		lRet := VDFA060(aParTela)
	EndIf

	cRet := QueryRI6(mChavePesq,SR8->R8_FILIAL,SR8->R8_MAT,"SR8")

	If !Empty(SR8->R8_FILSUB) .And. !Empty(SR8->R8_MATSUB)
		If cRet == "NP"
			ExcluiRI6()
		ElseIf cRet == 'P'
			MsgAlert(STR0005)//'O Item gerado anteriormente foi publicado. Deve ser feito um novo item para o cancelamento '
			lRet := VDFA060(aParTela)// Se for Exclusão e tiver publicação na RI6_NUMDOC e RI6_ANO deve Gerar o Ato de Publicação.
		EndIf
	EndIf

	TRBRI6->( DbCloseArea() )
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} CARGA130()
CARREGA VALORES DO 13 - DEZEMBRO
@return		A
@author	    Gisele Nuncherino
@since		21/06/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function CARGA130()
Local aRet			:= {}
Local aArea			:= GetArea()
Local cQuery		:= ''

IF ( MONTH(DDATADEM) = 12 )

	cQuery := " SELECT * FROM " + RETSQLNAME("SRC") + " SRC "
	cQuery += " WHERE RC_FILIAL   = '" + SRA->RA_FILIAL + "' "
	cQuery += "		AND RC_MAT    = '" + SRA->RA_MAT    + "' "
	cQuery += " 	AND RC_ROTEIR = '213'                 "
	cQuery += " 	AND SRC.D_E_L_E_T_ = ' '               "
	cQuery += " ORDER BY RC_FILIAL, RC_MAT, RC_PD, RC_CC, RC_SEMANA, RC_SEQ"

	If Select("CARGA130") > 0
		CARGA130->(DbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"CARGA130", .F., .T.)
	dbSelectArea("CARGA130")

	While !Eof()
		IF MESANO(STOD(CARGA130->RC_DTREF)) == MESANO(DDATADEM)
			Aadd(aRet,{ CARGA130->RC_PD			,;
						CARGA130->RC_CC			,;
						CARGA130->RC_SEMANA		,;
						CARGA130->RC_SEQ		,;
						CARGA130->RC_VALOR		})
		ENDIF

		dbSkip()
	EndDo

	CARGA130->( dbCloseArea() )
EndIF

RestArea( aArea )

Return aRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} Gp40GItePu
Gera Itens de Publicação de Rescisão
Utilização na Rotina de Rescisão Contratual do Ministério Público, para publicação
antecipada de Rescisão Contratual futura.
@sample 	Gp40GItePu()
@return		lógico, não permite abrir novamente a tela.
@author		Tânia Bronzeri
@since		25/04/2014
@version	P. 11.90
/*/
//------------------------------------------------------------------------------
Function Gp40GItePu()
Local aArea	:= GetArea()

	VDFA060({"GPEM040",SRA->RA_MAT,SRA->RA_CATFUNC,dDataBase,SRA->RA_FILIAL,SRA->RA_CIC,dDataBase,'1','SRA'})
	RestArea(aArea)

Return MbrChgLoop( .F. ) //não abrir a tela novamente


//------------------------------------------------------------------------------
/*/{Protheus.doc} fDtRescAnt
Busca maior registro de publicação de rescisão.
Utilização na Rotina de Rescisão Contratual do Ministério Público, para publicação
	antecipada de Rescisão Contratual futura.
@sample 	fDtRescAnt(cRFil, cRMat)
@param		cRFil		- Filial do Membro/Servidor que está sendo desligado
			cRMat		- Matrícula do Membro/Servidor que está sendo desligado
@return		dRDemis		- Devolve a Data de Rescisão publicada (RI6_DTEFEI)
			aPublicacao	- [1] = dRDemis
						  [2] = cRNrDoc (Nro. Documento de Publicação)
						  [3] = dRDtDoc	(Data Documento de Publicação)
						  [4] = cChave 	(RI6->RI6_FILIAL + RI6->RI6_CODITE)
						  [5] = nOrdem	(Nro. do índice da RI6)
@author		Tânia Bronzeri
@since		07/05/2014
@version	P. 11.90
/*/
//------------------------------------------------------------------------------
Function fDtRescAnt(cRFil, cRMat)
Local aRi6Area	:= RI6->(GetArea())
Local aRi5Area	:= RI5->(GetArea())
Local cRi6Alias	:= GetNextAlias()
Local lSubsTp 	:= "MSSQL" $ AllTrim(Upper(TcGetDb())) .Or. AllTrim(Upper(TcGetDb())) == 'SYBASE'
Local cSubstr	:= Iif(lSubsTp,"%Substring%","%Substr%")
Local cGpem040	:= "%'%GPEM040%'%"
Local cS100		:= "%'S100'%"
Local cS101		:= "%'S101'%"
Local cQRFil	:= "%'" + cRFil + "'%"
Local cQRMat	:= "%'" + cRMat + "'%"
Local dRDemis	:= CtoD("  /  /  ")
Local dRDtDoc	:= CtoD("  /  /  ")
Local cRNrDoc	:= ""
Local cChave	:= ""
Local nOrdem	:= 0

BeginSql alias cRi6Alias
	Select Max(RI6_CODITE) MRegRi6
	From  %table:RI6% RI6
		Inner Join (
			Select distinct %exp:cSubstr%(RCC1.RCC_CONTEU,1,2) CLASSIF
			From %table:RCC% RCC
				Left Join %table:RCC% RCC1
					On RCC1.%notDel% And RCC.%notDel% And RCC1.RCC_CONTEU Like %exp:cGpem040% And RCC1.RCC_CODIGO = %exp:cS101%
			Where RCC.RCC_CODIGO = %exp:cS100%
			) PUBL
			On RI6.%notDel% And RI6.RI6_CLASTP = PUBL.CLASSIF
		Inner Join %table:SRA% SRA
			On SRA.%notDel% And RI6.RI6_FILMAT = SRA.RA_FILIAL And RI6.RI6_MAT = SRA.RA_MAT
	Where RI6.RI6_FILMAT = %exp:cQRFil% And RI6.RI6_MAT = %exp:cQRMat% And RI6.RI6_STATUS <> '4'

EndSql

(cRi6Alias)->(DbGoTop())
If (cRi6Alias)->(!Eof())
	DbSelectArea("RI6")
	nOrdem	:= RetOrder("RI6","RI6_FILIAL+RI6_CODITE")
	DbSetOrder(nOrdem)
	RI6->(DbSeek(FWxFilial("RI6")+(cRi6Alias)->MRegRi6))
	dRDemis	:= RI6->RI6_DTEFEI
	cRNrDoc	:= RI6->RI6_NUMDOC
	cChave	:= RI6->RI6_FILIAL + RI6->RI6_CODITE
	If !Empty(cRNrDoc)
		DbSelectArea("RI5")
		DbSetOrder(1)
		If RI5->(DbSeek(FWxFilial("RI5")+RI6->RI6_ANO+RI6->RI6_NUMDOC+RI6->RI6_TIPDOC))
			dRDtDoc	:= RI5->RI5_DTAPUB
		EndIf
		DbSelectArea("RI6")
	EndIf

	aPublicacao	:= aClone({dRDemis,cRNrDoc,dRDtDoc,cChave,nOrdem})
EndIf

(cRi6Alias)->(DbCloseArea())
RestArea(aRi5Area)
RestArea(aRi6Area)
Return dRDemis


//------------------------------------------------------------------------------
/*/{Protheus.doc}fRetSitGFP
Função para restaurar as informações do funcionário caso o calculo da rescisão seja excluido.
@author Paulo.Inzonha
@since 04/07/2018
@version P12
@param cAfasfgts, caractere, código do afastamento FGTS
/*/
//------------------------------------------------------------------------------
Function fRetSitGFP(cAfasfgts)
Local aSalario 	:= {}
Local dDataDe 	:= STOD(" / / ")
Local cTabela	:= ""
Local cNvlTab	:= ""
Local cFaixa 	:= ""
Local cTabCom	:= ""
Local cNivelCom	:= ""
Local cFaixaCom := ""
Local lDataRef 	:= .F.
Local cCodFunc	:= ""
Local cDescFunc := ""
Local cCatFunc  := ""

If cAfasfgts $ 'U1*U3' //Aposentadoria
	If SR7->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+DTOS(SRG->RG_DATADEM)))
		If SR3->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+DTOS(SRG->RG_DATADEM)))
			RecLock("SR3",.F.)
			SR3->(dbDelete())
			SR3->(MsUnlock())
		EndIf
		RecLock("SR7",.F.)
		SR7->(dbDelete())
		SR7->(MsUnlock())
	EndIf

	fBuscaSal(SRA->RA_ADMISSA,SRG->RG_DATADEM-1,@aSalario,.F.)
	nSalAnt := aSalario[Len(aSalario),2]

	dDataDe := SRA->RA_APOSENT
	fBuscaFunc(@dDataDe,@cCodFunc,@cDescFunc,@cCatFunc )
	fBuscaTab(@dDataDe,@cTabela, @cNvlTab,@cFaixa,@cTabCom ,@cNivelCom ,@cFaixaCom ,@lDataRef )//SR3
	cDataRef	:= Dtos(SRA->RA_APOSENT)
	RecLock("SRA",.F.,.T.)
	SRA->RA_SITFOLH	:= ""
	SRA->RA_DEMISSA	:= Ctod("  /  /  ")
	SRA->RA_APOSENT	:= Ctod("  /  /  ")
	SRA->RA_TABELA	:= cTabela//SR3->R3_TABELA
	SRA->RA_TABNIVE	:= cNvlTab//SR3->R3_TABNIVE
	SRA->RA_TABFAIX	:= cFaixa//SR3->R3_TABFAIX
	SRA->RA_CATFUNC	:= cCatFunc//SR7->R7_CATFUNC
	SRA->RA_SALARIO	:= nSalAnt
	SRA->RA_MSBLQL	:= '2'
	SRA->( MsUnLock() )
EndIf

//Limpa a data final de adido/cedido
If SRA->RA_CATFUNC $ '4,5' // Exclui(4)/Confirma(9)
	If 	RID->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT))
		While RID->(!eof()) .and. RID->(RID_FILIAL+RID_MAT) == SRA->(RA_FILIAL+RA_MAT)
			If RID->RID_DATFIM == SRG->RG_DATADEM
				RecLock("RID",.F.,.T.)
				RID->RID_DATFIM	:= 	Ctod("//")
				RID->( MsUnLock() )
			Endif
			RID->(dbskip())
		EndDo
	EndIF
Endif

//Retorna RI6_TABORI para SRA
DbSelectArea("RI6")
DbSetOrder(RetOrder("RI6", "RI6_FILIAL+RI6_FILMAT+RI6_MAT+RI6_TABORI+RI6_CHAVE"))
If RI6->(DbSeek(xFilial("RI6")+SRA->RA_FILIAL+SRA->RA_MAT+"SRG"+AllTrim(DtoS(dDataDem))))
	RecLock("RI6",.F.)
	RI6->RI6_TABORI	:= "SRA"
	MsUnLock()
EndIf

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc}fTpAltSal
Função para filtro no valid X5_041
@author Paulo.Inzonha
@since 04/07/2018
@version P12
@return lógico, permite filtro dos dados
/*/
//------------------------------------------------------------------------------
Function fTpAltSal()
Local lRet := .F.

	lRet := (fUsaGFP() .OR. (!fUsaGFP() .AND. SX5->X5_CHAVE <> 'APO'))

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc}fTbJoinSQL
Join de tabelas
@author esther.viveiro
@since 01/08/2018
@version P12
@param cTabela1, caractere, Primeira tabela do relacionamento
@param cTabela2, caractere, Segunda tabela do relacionamento
@param [cEmbedded], caractere, Simbolo para abertura/fechamento do Embedded
@return caractere, Comando SUBTRING tratado
/*/
//------------------------------------------------------------------------------
Function fTbJoinSQL(cTabela1, cTabela2,cEmbedded)

	Local cFiltJoin		:= ""
	Local cNameDB		:= ""
	Default cEmbedded	:= ""

	cFiltJoin := cEmbedded + FWJoinFilial(cTabela1, cTabela2) + cEmbedded

	//Quando a tabela for totalmente compartilhada, retorna filtro com Tabela_Filial = ''
	If cFiltJoin == ("' ' =' ' ")
		If Empty(xFilial(cTabela1))
			cFiltJoin := cTabela1 + "." + If(SubString(cTabela1,1,1) == "S",SubString(cTabela1,2,2),cTabela1) + "_FILIAL = ' '"
		Else
			cFiltJoin := cTabela2 + "." + If(SubString(cTabela2,1,1) == "S",SubString(cTabela2,2,2),cTabela1) + "_FILIAL = ' '"
		EndIf
	ElseIf ( cNameDB $ 'DB2|ORACLE|POSTGRES|INFORMIX' )
		cFiltJoin := STRTRAN(cFiltJoin, "SUBSTRING", "SUBSTR")
	EndIf

Return (cFiltJoin)
