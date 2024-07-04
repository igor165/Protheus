#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FISR953.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} FISR953
Livro Registro de Apuração do ICMS
@param	Mês ?
Ano ?
Dias mes seguinte ?
Data cancelamento ?
@author Paulo Krüger
@since 31/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Function FISR953()
	Local oReport	:= Nil
	Local cPerg		:= Padr(STR0001,10) //FISR953
	Local lUsaF2R	:= .F.
	Local lFR2ANOMES:= .F.
	Local cAlert	:= ''
	Local lApura	:= .T.
	Local lParam	:= .T.
	Local nMesAnt	:= 0
	Local nAnoAnt	:= 0
	Local cAnoPer	:= ''
	Local nI		:= 0

	Private cPerAnt := ''
	Private cPerAtu := ''
	Private cNrLivro:= '*'
	Private cDtIni	:= ''
	Private cDtFim	:= ''
	Private dDtIni	:= Ctod('  /  /  ')
	Private dDtFim	:= Ctod('  /  /  ')
	Private cCE6_ANT:= ''
	Private cF2R_PER:= ''
	Private cCE5_PER:= ''
	Private cCE6_PER:= ''

	Pergunte(cPerg,.T.)
	/*===============================|
	|Mês ?				|	mv_par01 |
	|Ano ?				|	mv_par02 |
	|===============================*/

	//Verifica parametrização

	MV_PAR01 := StrZero(Val(MV_PAR01),2)

	If Empty(MV_PAR01) .OR. Empty(MV_PAR02)
		lParam := .F.
		cAlert := STR0038	//Parametros obrigatorios.
	ElseIf Val(MV_PAR01) < 1 .or. Val(MV_PAR01) > 12
		lParam := .F.
		cAlert := STR0039	//Mes invalido.
	ElseIf Len(MV_PAR02) < 4
		lParam := .F.
		cAlert := STR0040	//Ano invalido.
	EndIf

	If lParam

		For nI := 01 To 02
			If ASC(SubStr(MV_PAR01,nI,01)) < 48 .or. ASC(SubStr(MV_PAR01,nI,01)) > 57
				lParam := .F.
				cAlert := STR0039	//Ano invalido.
			EndIf
		Next nI
		For nI := 01 To 04
			If ASC(SubStr(MV_PAR02,nI,01)) < 48 .or. ASC(SubStr(MV_PAR02,nI,01)) > 57
				lParam := .F.
				cAlert := STR0040	//Ano invalido.
			EndIf
		Next nI

	EndIf
	If !lParam
		Alert(cAlert)
		cAlert := ''
		Return
	EndIf

	//Verifica se há apuração
	lUsaF2R := AliasIndic('F2R')
	If lUsaF2R
		lFR2ANOMES := (F2R->(FieldPos('F2R_ANOMES')) > 0)
		If !lFR2ANOMES
			cAlert := STR0019 + CRLF //Campo Ano/Mes de apuração (F2R_ANOMES) inexistente na base de dados.
			cAlert += STR0018 //Atualize o ambiente.
			Alert(cAlert)
			cAlert := ''
			lApura := .F.
		Else
			F2R->(DbSetOrder(01))
			If !F2R->(DbSeek(xFilial('F2R') + (mv_par02 + mv_par01)))
				cAlert := STR0020 + CRLF //Nao foram acumulados creditos nesse periodo.
				cAlert += STR0021 //Verifique a parametrizacao ou execute a apuracao.
				Alert(cAlert)
				cAlert := ''
				lApura := .F.
			EndIf
		EndIf
	Else
		cAlert := STR0017 + CRLF //Tabela Apuração de Crédito Acumulado (F2R) inexistente na base de dados.
		cAlert += STR0018 //Atualize o ambiente.
		Alert(cAlert)
		cAlert := ''
		lApura := .F.
	EndIf

	If lApura .and. lParam

		//Calcula datas finais
		If !Empty(MV_PAR01) .and. !Empty(MV_PAR02)
			cDtIni	:=	MV_PAR02 + MV_PAR01 + '01'
			dDtIni	:=	STOD(cDtIni)
			dDtFim	:=	LastDay(dDtIni)
		EndIf

		//Calcula período anterior
		If Val(MV_PAR01) > 1
			nMesAnt := Val(MV_PAR01) - 1
		Else
			nMesAnt := 12
		EndIf

		If nMesAnt == 12
			nAnoAnt := Val(MV_PAR02) - 1
		EndIf

		If nAnoAnt > 0
			cPerAnt	:= STR(nAnoAnt) + STR(nMesAnt)
		Else
			cAnoPer	:= MV_PAR02
			cPerAnt	:= cAnoPer + StrZero(nMesAnt,2)

		EndIf

		//Calcula período atual
		cPerAtu	:= AllTrim(MV_PAR02) + AllTrim(MV_PAR01)

		//Cria novas areas
		cCE6_ANT 	:=	GetNextAlias()
		cF2R_PER	:=	GetNextAlias()
		cCE5_PER 	:=	GetNextAlias()
		cCE6_PER 	:=	GetNextAlias()

		//Executa o relatorio
		oReport := RptDef(cPerg)
		oReport :PrintDialog()

	EndIf
Return

Static Function RptDef(cNome)
	Local oBreak01
	Local oBreak02
	Local oBreak03
	Local oBreak04
	Local oBreak05
	Local oFunction
	Local oReport	:= Nil
	Local oSectionCR:= Nil
	Local oSection1	:= Nil
	Local oSection2	:= Nil
	Local oSection3	:= Nil
	Local oSection4	:= Nil
	Local oSection5	:= Nil
	Local oSection1c:= Nil
	Local oSection2c:= Nil
	Local oSection3c:= Nil
	Local oSection4c:= Nil
	Local oSection5c:= Nil
	Local cCabecRel	:= ''
	Local cNomeEmp	:= ''
	Local cInscEst	:= ''
	Local cCNPJ		:= ''
	Local cTitulo	:= STR0002 //Livro Registro de Apuração do ICMS - RAICMS
	Local cSubTit01 := STR0003 //Resumo da Apuração do Imposto
	Local aSM0		:= {}
	Local aDocs		:= {}
	Local nLinSM0	:= 0
	Local nDescr	:= 0

	cNomeEmp	:=	FWCompanyName()
	aSM0		:=	FWLoadSM0()
	nLinSM0		:=	ASCAN(aSM0, {|aVal| aVal[2] == cFilAnt})

	aDocs		:=	Separa(aSM0[nLinSM0][22],'_')
	cCNPJ		:=  If(ASC(SubStr(aDocs[01],01,01)) < 48 .or. ASC(SubStr(aDocs[01],01,01)) > 57,'', aDocs[01])
	If Len(aDocs) >= 2
		cInscEst	:=	If(ASC(SubStr(aDocs[02],01,01)) < 48 .or. ASC(SubStr(aDocs[02],01,01)) > 57,'', aDocs[02])
	Else
		cInscEst	:=	''
	EndIf

	cCabecRel	:=	cSubTit01 + CRLF
	cCabecRel	+=	STR0004 + ' ' + AllTrim(cNomeEmp) //Firma:
	cCabecRel	+=	STR0005 + ' ' + DToC(dDtIni) + ' a ' + DToC(dDtFim) + CRLF //Mês ou Período/Ano:
	cCabecRel	+=	STR0006 + ' ' + cCNPJ //CNPJ:

	oReport := TReport():New(cNome,cTitulo,cNome,{|oReport| ReportPrint(oReport)},cCabecRel)
	oReport:SetLandscape()
	oReport:bTotalPrint := {||.F.} //Desabilita Total Geral do relatório

	//Secão CR - Cabeçalho da Relatorio
	oSectionCR:= TRSection():New(oReport, '', {}, , .F., .T.)
	TRCell():New(oSectionCR,'CABECREL'	,	,cCabecRel	,'@!'	,50)

	//Secão 01c - Cabeçalho da Secão 01
	oSection1c:= TRSection():New(oReport, STR0023, {}, , .F., .T.) //SALDO CREDOR DO PERIODO ANTERIOR
	TRCell():New(oSection1c,'CABEC01'	,	,STR0023	,'@!'	,50)//SALDO CREDOR DO PERIODO ANTERIOR

	//Secão 01 - SALDO CREDOR DO PERIODO ANTERIOR
	oSection1:= TRSection():New(oReport, STR0023, {cCE6_ANT}, , .F., .T.) //SALDO CREDOR DO PERIODO ANTERIOR
	TRCell():New(oSection1,'CODAJUCE6'	,cCE6_ANT	,STR0024	,PesqPict('CE6','CE6_CODLAN')	,TamSx3('CE6_CODLAN')[01])	//Cod Ajuste
	TRCell():New(oSection1,'DESAJUCDO'	,cCE6_ANT	,STR0025	,PesqPict('CDO','CDO_DESCR')	,TamSx3('CDO_DESCR')[01])	//Descricao
	TRCell():New(oSection1,'SLDAJUCE6'	,cCE6_ANT	,STR0026	,PesqPict('CE6','CE6_SALDO')	,TamSx3('CE6_SALDO')[01])	//Saldo
	TRCell():New(oSection1,'FILIALIMP'	,cCE6_ANT	,''			,PesqPict('CE6','CE6_FILIAL')	,TamSx3('CE6_FILIAL')[01])	//Filial
	oBreak01 := TRBreak():New ( oSection1 , oSection1:Cell('FILIALIMP'), STR0037) //TOTAL
	TRFunction():New(oSection1:Cell('SLDAJUCE6'),NIL,'SUM',oBreak01,,,,.F.,.T.)

	//Secão 02c - Cabeçalho da Secão 02
	oSection2c:= TRSection():New(oReport, STR0027, {cF2R_PER}, , .F., .T.) //OUTROS CREDITOS
	TRCell():New(oSection2c,'CABEC02'	,cF2R_PER	,STR0027	,'@!'	,50)//OUTROS CREDITOS

	//Secão 02 - OUTROS CREDITOS
	oSection2:= TRSection():New(oReport, STR0027, {cF2R_PER}, NIL, .F., .T.) //OUTROS CREDITOS
	TRCell():New(oSection2,'OPCERDACU'	,cF2R_PER	,STR0028	,PesqPict('F2R','F2R_CREDAC')	,TamSx3('F2R_CREDAC')[01])	//Op Cred Acum
	TRCell():New(oSection2,'DESCOPCRD'	,cF2R_PER	,STR0029	,PesqPict('F2R','F2R_DESCRI')	,TamSx3('F2R_DESCRI')[01])	//Desc Op Cred
	TRCell():New(oSection2,'VLRCRDMES'	,cF2R_PER	,STR0030	,PesqPict('F2R','F2R_VALOR')	,TamSx3('F2R_VALOR')[01])	//Vlr Crd Mes
	TRCell():New(oSection2,'FILIALIMP'	,cF2R_PER	,''			,PesqPict('F2R','F2R_FILIAL')	,TamSx3('F2R_FILIAL')[01])	//Filial
	oBreak02 := TRBreak():New ( oSection2 , oSection2:Cell('FILIALIMP'), STR0037) //TOTAL
	TRFunction():New(oSection2:Cell('VLRCRDMES'),NIL,'SUM',oBreak02,,,,.F.,.T.)

	//Secão 03c - Cabeçalho da Secão 03
	oSection3c:= TRSection():New(oReport, STR0031, {cCE5_PER}, , .F., .T.) //UTILIZACAO DO CREDITO
	TRCell():New(oSection3c,'CABEC03'	,cCE5_PER	,STR0031	,'@!'	,50)//UTILIZACAO DO CREDITO

	//Secão 03 - UTILIZACAO DO CREDITO
	oSection3:= TRSection():New(oReport, STR0031, {cCE5_PER}, NIL, .F., .T.) //UTILIZACAO DO CREDITO
	TRCell():New(oSection3,'OPCERDACU'	,cCE5_PER	,STR0024	,PesqPict('CE5','CE5_CODLAN')	,TamSx3('CE5_CODLAN')[01])	//Cod Ajuste
	TRCell():New(oSection3,'CODIGUTIL'	,cCE5_PER	,STR0032	,PesqPict('CE5','CE5_CODUTI')	,TamSx3('CE5_CODUTI')[01])	//Cod Util
	TRCell():New(oSection3,'DESCCDUTI'	,cCE5_PER	,STR0033	,PesqPict('CE7','CE7_DESCR')	,TamSx3('CE7_DESCR')[01])	//Desc Cod Uti
	TRCell():New(oSection3,'VLRDOCRED'	,cCE5_PER	,STR0034	,PesqPict('CE5','CE5_VALOR')	,TamSx3('CE5_VALOR')[01])	//Vlr do Cred
	TRCell():New(oSection3,'FILIALIMP'	,cCE5_PER	,''			,PesqPict('CE5','CE5_FILIAL')	,TamSx3('CE5_FILIAL')[01])	//Filial
	oBreak03 := TRBreak():New ( oSection3 , oSection3:Cell('FILIALIMP'), STR0037) //TOTAL
	TRFunction():New(oSection3:Cell('VLRDOCRED'),NIL,'SUM',oBreak03,,,,.F.,.T.)

	//Secão 04c - Cabeçalho da Secão 04
	oSection4c:= TRSection():New(oReport, STR0035, {cCE6_PER}, , .F., .T.) //SALDO CREDOR A TRANSPORTAR PARA PROXIMO PERIODO
	TRCell():New(oSection4c,'CABEC04'	,cCE5_PER	,STR0035	,'@!'	,50)//SALDO CREDOR A TRANSPORTAR PARA PROXIMO PERIODO
	
	//Secão 04 - SALDO CREDOR A TRANSPORTAR PARA PROXIMO PERIODO
	oSection4:= TRSection():New(oReport, STR0035, {cCE6_PER}, NIL, .F., .T.) //SALDO CREDOR A TRANSPORTAR PARA PROXIMO PERIODO
	nDescr	 := TamSx3('CDO_DESCR')[01] 
	TRCell():New(oSection4,'CDIAJUCE6'	,cCE6_PER	,STR0024	,PesqPict('CE6','CE6_CODLAN')	,TamSx3('CE6_CODLAN')[01])	//Cod Ajuste
	TRCell():New(oSection4,'DESCLACE6'	,cCE6_PER	,STR0025	,PesqPict('CDO','CDO_DESCR')	,nDescr)					//Descricao
	TRCell():New(oSection4,'SALAJUCE6'	,cCE6_PER	,STR0026	,PesqPict('CE6','CE6_SALDO')	,TamSx3('CE6_SALDO')[01])	//Saldo
	TRCell():New(oSection4,'FILIALIMP'	,cCE6_PER	,''			,PesqPict('CE6','CE6_FILIAL')	,TamSx3('CE6_FILIAL')[01])	//Filial
	oBreak04 := TRBreak():New ( oSection4 , oSection4:Cell('FILIALIMP'), STR0037) //TOTAL
	TRFunction():New(oSection4:Cell('SALAJUCE6'),NIL,'SUM',oBreak04,,,,.F.,.T.)

	//Secão 05c - Cabeçalho da Secão 05
	oSection5c:= TRSection():New(oReport, STR0036, {cCE6_PER}, , .F., .T.) //SAIDAS INCENTIVADAS
	TRCell():New(oSection5c,'CABEC05'	,cCE5_PER	,STR0036	,'@!'	,50)//SAIDAS INCENTIVADAS

	//Secão 05 - SAIDAS INCENTIVADAS
	oSection5:= TRSection():New(oReport, STR0036, {'cAliasTMP'}, NIL, .F., .T.) //SAIDAS INCENTIVADAS
	TRCell():New(oSection5,'EMISSAO'   	,'cAliasTMP'	,STR0011	,PesqPict('SF3','F3_EMISSAO')	,10)						//Emissão
	TRCell():New(oSection5,'NFISCAL'   	,'cAliasTMP'	,STR0012	,PesqPict('SF3','F3_NFISCAL')	,TamSx3('F3_NFISCAL')[01])	//Num Nota
	TRCell():New(oSection5,'SERIE'   	,'cAliasTMP'	,STR0013	,PesqPict('SF3','F3_SERIE')		,TamSx3('F3_SERIE')[01])	//Série
	TRCell():New(oSection5,'CLIFOR'   	,'cAliasTMP'	,STR0014	,PesqPict('SF3','F3_CLIEFOR')	,TamSx3('F3_CLIEFOR')[01])	//Cliente/Fornecedor
	TRCell():New(oSection5,'LOJA'   	,'cAliasTMP'	,STR0015	,PesqPict('SF3','F3_LOJA')		,TamSx3('F3_LOJA')[01])		//Loja
	TRCell():New(oSection5,'CFO'   		,'cAliasTMP'	,STR0016	,PesqPict('SF3','F3_CFO')		,TamSx3('F3_CFO')[01])		//CFOP
	TRCell():New(oSection5,'ICMSISENTO'	,'cAliasTMP'	,STR0041	,PesqPict('SF3','F3_ISENICM')	,TamSx3('F3_ISENICM')[01]) 	//ICMS Isento
	TRCell():New(oSection5,'ICMSOUTROS'	,'cAliasTMP'	,STR0042	,PesqPict('SF3','F3_OUTRICM')	,TamSx3('F3_OUTRICM')[01]) 	//ICMS Outros
	TRCell():New(oSection5,'CREDACU' 	,'cAliasTMP'	,STR0008	,PesqPict('SF3','F3_CREDACU')	,TamSx3('F3_CREDACU')[01]) 	//Código do Crédito Acumulado
	TRCell():New(oSection5,'FILIALIMP'	,'cAliasTMP'	,''			,PesqPict('SF3','F3_FILIAL')	,TamSx3('F3_FILIAL')[01])	//Filial
	oBreak05 := TRBreak():New ( oSection5 , oSection5:Cell('FILIALIMP'), STR0037) //TOTAL
	TRFunction():New(oSection5:Cell('ICMSISENTO'),NIL,'SUM',oBreak05,,,,.F.,.T.)
	TRFunction():New(oSection5:Cell('ICMSOUTROS'),NIL,'SUM',oBreak05,,,,.F.,.T.)

Return(oReport)

Static Function ReportPrint(oReport)
	Local oSectionCR	:= oReport:Section(1)
	Local oSection1c 	:= oReport:Section(2)
	Local oSection1 	:= oReport:Section(3)
	Local oSection2c 	:= oReport:Section(4)
	Local oSection2 	:= oReport:Section(5)
	Local oSection3c 	:= oReport:Section(6)
	Local oSection3 	:= oReport:Section(7)
	Local oSection4c 	:= oReport:Section(8)
	Local oSection4 	:= oReport:Section(09)
	Local oSection5c 	:= oReport:Section(10)
	Local oSection5 	:= oReport:Section(11)

	Local cQuery    	:= ''
	Local cNcm      	:= ''
	Local lPrim 		:= .T.
	Local nDiasAcreDt	:= 0
	Local cMvEstado		:= ''
	Local lF3Cnae		:= .F.
	Local lF3CODRSEF	:= .F.
	Local lF4PRZESP		:= .F.
	Local lF4MKPCMP		:= .F.
	Local lF4FTATUSC	:= .F.
	Local lF4IPI		:= .F.
	Local lF4ESCRDPR	:= .F.
	Local lF4VARATAC	:= .F.
	Local lF4CRLEIT		:= .F.
	Local lF4IPIPECR	:= .F.
	Local lF4TXAPIPI	:= .F.
	Local cCposQry		:= ''
	Local cECmpD1D2		:= ''
	Local cECmpF1F2		:= ''
	Local cSCmpD1D2		:= ''
	Local cSCmpF1F2		:= ''
	Local cDtCanc		:= ''
	Local aStruSF3		:= {}
	Local cMvCODRSEF	:= ''
	Local cCredAcu		:= ''
	Local aNWCredAcu	:= {}
	Local nPoscred		:= 0
	Local oAliasTMP
	Local cAliasTMP		:= ''
	Local aFieldTMP		:= {}
	Local cCdCrdICMS	:= ''
	Local cDsCrdICMS	:= ''
	Local nI			:= 0
	Local aBoxCrdAcu	:= {}
	Local nPosCredIC	:= 0
	Local cCmpSF4		:= ''
	Local lNWCredAcu	:= .F.
	Local cFilCE6		:= ''
	Local cFilCDO		:= ''
	Local cFilF2R		:= ''
	Local cFilCE5		:= ''
	Local cFilCE7		:= ''
	Local nSldComp		:= 0
	Local cTpMov		:= ''

	//Usada para atender a Legislacao de SP/PR
	cMvEstado	:= SuperGetMv('MV_ESTADO')
	nDiasAcreDt	:= 0
	If	cMvEstado == 'SP'
		nDiasAcreDt	:= 9
	ElseIf	cMvEstado == 'PR'
		nDiasAcreDt := 5
	EndIf

	lF3Cnae		:= SF3->(FieldPos('F3_CNAE'))	 > 0
	lF3CODRSEF	:= SF3->(FieldPos('F3_CODRSEF')) > 0

	//Campos Entrada
	cECmpD1D2 := "SD1.D1_VALICM, 0 D2_VALICM, '' D2_PEDIDO, '' D2_CODISS, '' D2_COD, "
	cECmpF1F2 := "SF1.F1_TIPO, '' F2_TIPOCLI, '' F2_PREFIXO, '' F2_DUPL, '' F2_TIPO "

	//Campos Saida
	cSCmpD1D2 := "0 D1_VALICM, SD2.D2_VALICM, SD2.D2_PEDIDO, SD2.D2_CODISS, SD2.D2_COD, "
	cSCmpF1F2 := "'' F1_TIPO, SF2.F2_TIPOCLI, SF2.F2_PREFIXO, SF2.F2_DUPL, SF2.F2_TIPO "

	//Campos TES
	lF4PRZESP	:=	SF4->(FieldPos('F4_PRZESP'))	> 0
	lF4MKPCMP	:=	SF4->(FieldPos('F4_MKPCMP'))	> 0
	lF4FTATUSC	:= 	SF4->(FieldPos('F4_FTATUSC'))	> 0
	lF4IPI		:= 	SF4->(FieldPos('F4_IPI'))		> 0
	lF4ESCRDPR	:=	SF4->(FieldPos('F4_ESCRDPR'))	> 0
	lF4VARATAC	:=	SF4->(FieldPos('F4_VARATAC'))	> 0
	lF4CRLEIT	:=	SF4->(FieldPos('F4_CRLEIT'))	> 0
	lF4IPIPECR	:=	SF4->(FieldPos('F4_IPIPECR'))	> 0
	lF4TXAPIPI	:=	SF4->(FieldPos('F4_TXAPIPI'))	> 0

	If lF4PRZESP
		cCmpSF4	+=	'SF4.F4_PRZESP, '
	EndIf
	If lF4MKPCMP
		cCmpSF4	+=	'F4_MKPCMP, '
	EndIf
	If lF4FTATUSC
		cCmpSF4	+=	'F4_FTATUSC, '
	EndIf
	If lF4IPI
		cCmpSF4	+=	'F4_IPI, '
	EndIf
	If lF4ESCRDPR
		cCmpSF4	+=	'F4_ESCRDPR, '
	EndIf
	If lF4CRLEIT
		cCmpSF4	+=	'F4_CRLEIT, '
	EndIf
	If lF4IPIPECR
		cCmpSF4	+=	'F4_IPIPECR, '
	EndIf
	If lF4TXAPIPI
		cCmpSF4	+=	'F4_TXAPIPI, '
	EndIf
	cCmpSF4	+=	'F4_INCSOL, '

	cDtCanc	:= Space(TamSx3('F3_DTCANC')[1])

	aStruSF3:= SF3->(DbStruct())

	cMvCODRSEF	:= SuperGetMv('MV_CODRSEF', .F., "'','100'")
	cMvCODRSEF	:= If(Empty(cMvCODRSEF), "'','100'", cMvCODRSEF)

	cCredAcu := "'1','2','4','5','6','7'"

	cQuery := XApGetQry('IC'		,	;
	dDtIni		,	;
	dDtFim		,	;
	nDiasAcreDt ,	;
	cNrLivro	,	;
	lF3Cnae		,	;
	lF3CODRSEF	,	;
	cCposQry	,	;
	cECmpF1F2	,	;
	cSCmpF1F2	,	;
	cECmpD1D2	,	;
	cSCmpD1D2	,	;
	cCmpSF4		,	;
	cDtCanc		,	;
	aStruSF3	,	;
	cMvCODRSEF	,	;
	cCredAcu )

	If Select('TRBSF3') > 0
		DbSelectArea('TRBSF3')
		DbCloseArea()
	EndIf

	TCQUERY cQuery NEW ALIAS 'TRBSF3'

	dbSelectArea('TRBSF3')

	oReport:SetMeter(TRBSF3->(LastRec()))

	//Criação de tabela temporária para impressão da segunda seção (relação de notas fiscais)
	AADD(aFieldTMP,{'EMISSAO'	,'D',TamSx3('F3_EMISSAO')[01]	,0})
	AADD(aFieldTMP,{'NFISCAL'	,'C',TamSx3('F3_NFISCAL')[01]	,0})
	AADD(aFieldTMP,{'SERIE'		,'C',TamSx3('F3_SERIE')[01]		,0})
	AADD(aFieldTMP,{'CLIEFOR'	,'C',TamSx3('F3_CLIEFOR')[01]	,0})
	AADD(aFieldTMP,{'LOJA'		,'C',TamSx3('F3_LOJA')[01]		,0})
	AADD(aFieldTMP,{'CFO'		,'C',TamSx3('F3_CFO')[01]		,0})
	AADD(aFieldTMP,{'ICMSISENTO','N',TamSx3('F3_ISENICM')[01]	,TamSx3('F3_ISENICM')[02]})
	AADD(aFieldTMP,{'ICMSOUTROS','N',TamSx3('F3_OUTRICM')[01]	,TamSx3('F3_OUTRICM')[02]})
	AADD(aFieldTMP,{'CREDACU'	,'C',TamSx3('F3_CREDACU')[01]	,0})
	AADD(aFieldTMP,{'FILIALIMP'	,'C',TamSx3('F3_FILIAL')[01]	,0})

	cAliasTMP:= GetNextAlias()
	oAliasTMP:=	FWTemporaryTable():New(cAliasTMP)
	oAliasTMP:SetFields(aFieldTMP)
	oAliasTMP:Create()

	TRBSF3->(DbGoTop())

	While TRBSF3->(!Eof())

		If oReport:Cancel()
			Exit
		EndIf
		//Alimenta tabela temporária para impressão da segunda seção

		If Alltrim(TRBSF3->F3_TIPO) <> 'D' .And. Alltrim(TRBSF3->F3_CFO) >= '5' 
			RecLock(cAliasTMP,.T.)
			(cAliasTMP)->EMISSAO	:= STOD(TRBSF3->F3_EMISSAO)
			(cAliasTMP)->NFISCAL	:= TRBSF3->F3_NFISCAL
			(cAliasTMP)->SERIE		:= TRBSF3->F3_SERIE
			(cAliasTMP)->CLIEFOR	:= TRBSF3->F3_CLIEFOR
			(cAliasTMP)->LOJA		:= TRBSF3->F3_LOJA
			(cAliasTMP)->CFO		:= TRBSF3->F3_CFO
			(cAliasTMP)->ICMSISENTO	:= TRBSF3->F3_ISENICM
			(cAliasTMP)->ICMSOUTROS	:= TRBSF3->F3_OUTRICM
			(cAliasTMP)->CREDACU	:= TRBSF3->F3_CREDACU
			(cAliasTMP)->FILIALIMP	:= TRBSF3->F3_FILIAL
			(cAliasTMP)->(MsUnLock())
		EndIf
		TRBSF3->(DbSkip())
	EndDo

	//Impressão do cabecalho do relatório
	oSectionCR:Init()
	oSectionCR:Printline()
	oReport:IncMeter()
	oSectionCR:Finish()
	oReport:ThinLine()

	//Impressão do cabecalho da primeira seção
	oSection1c:Init()
	oSection1c:Printline()
	oReport:IncMeter()
	oSection1c:Finish()

	//Impressão da primeira seção - SALDO CREDOR DO PERIODO ANTERIOR
	oSection1:Init()
	cFilCE6	:=	xFilial('CE6')
	cFilCDO	:=	xFilial('CDO')
	BeginSql alias cCE6_ANT

		SELECT	CE6.CE6_CODLAN		CODAJUCE6	,
				CDO.CDO_DESCR		DESAJUCDO	,
				SUM(CE6.CE6_SALDO)	SLDAJUCE6
		FROM	%table:CE6% CE6 INNER JOIN %table:CDO% CDO ON	CDO.CDO_CODAJU	=	CE6.CE6_CODLAN
		WHERE		CE6.%notDel%
				AND	CDO.%notDel%
				AND CE6.CE6_PERIOD	=	%exp:cPerAnt%
				AND	CE6.CE6_FILIAL	=	%exp:cFilCE6%
				AND	CDO.CDO_FILIAL	=	%exp:cFilCDO%
				AND CE6.CE6_SALDO	>	%exp:nSldComp%
		GROUP BY CE6.CE6_CODLAN, CDO.CDO_DESCR
		ORDER BY 1
	EndSql

	(cCE6_ANT)->(DbGoTop())

	While (cCE6_ANT)->(!Eof())
		oSection1:Printline()
		oReport:IncMeter()
		(cCE6_ANT)->(DbSkip())
	EndDo

	(cCE6_ANT)->(DbCloseArea())
	oSection1:Finish()
	oReport:ThinLine()

	//Impressão do cabecalho da segunda seção
	oSection2c:Init()
	oSection2c:Printline()
	oReport:IncMeter()
	oSection2c:Finish()

	//Impressão da segunda seção - OUTROS CREDITOS
	oSection2:Init()
	cFilF2R	:=	xFilial('F2R')
	BeginSql alias cF2R_PER

		SELECT	F2R.F2R_CREDAC		OPCERDACU	,
				F2R.F2R_DESCRI		DESCOPCRD	,
				SUM(F2R.F2R_VALOR)	VLRCRDMES
		FROM	%table:F2R% F2R
		WHERE		F2R.%notDel%
				AND	F2R.F2R_FILIAL	=	%exp:cFilF2R%
				AND	F2R.F2R_ANOMES	=	%exp:cPerAtu%
				AND F2R.F2R_LIVRO	=	%exp:cNrLivro%
				AND	F2R.F2R_VALOR	>	%exp:nSldComp%
		GROUP BY F2R.F2R_CREDAC, F2R.F2R_DESCRI
		ORDER BY 1
	EndSql

	(cF2R_PER)->(DbGoTop())

	While (cF2R_PER)->(!Eof())
		oSection2:Printline()
		oReport:IncMeter()
		(cF2R_PER)->(DbSkip())
	EndDo

	(cF2R_PER)->(DbCloseArea())
	oSection2:Finish()
	oReport:ThinLine()

	//Impressão do cabecalho da terceira seção
	oSection3c:Init()
	oSection3c:Printline()
	oReport:IncMeter()
	oSection3c:Finish()

	//Impressão da terceira seção - UTILIZAÇÃO DO CRÉDITO
	oSection3:Init()
	cFilCE5	:=	xFilial('CE5')
	cFilCE7	:=	xFilial('CE7')
	cTpMov	:=	'U'

	BeginSql alias cCE5_PER

		SELECT	CE5.CE5_CODLAN	OPCERDACU			,
				CE5.CE5_CODUTI	CODIGUTIL			,
				CE7.CE7_DESCR	DESCCDUTI			,
				SUM(CE5.CE5_VALOR)	VLRDOCRED
		FROM	%table:CE5% CE5 LEFT JOIN %table:CE7% CE7 ON	CE7.%notDel%
			AND	CE7.CE7_FILIAL	=	%exp:cFilCE7%
			AND	CE7.CE7_CODUTI	=	CE5.CE5_CODUTI
		WHERE		CE5.%notDel%
			AND	CE5.CE5_FILIAL	=	%exp:cFilCE5%
			AND	CE5.CE5_PERIOD	=	%exp:cPerAtu%
			AND	CE5.CE5_TPMOV	=	%exp:cTpMov%
		GROUP BY CE5.CE5_CODLAN, CE5.CE5_CODUTI, CE7.CE7_DESCR
		ORDER BY 1

	EndSql

	(cCE5_PER)->(DbGoTop())

	While (cCE5_PER)->(!Eof())
		oSection3:Printline()
		oReport:IncMeter()
		(cCE5_PER)->(DbSkip())
	EndDo

	(cCE5_PER)->(DbCloseArea())
	oSection3:Finish()
	oReport:ThinLine()

	//Impressão do cabecalho da quarta seção
	oSection4c:Init()
	oSection4c:Printline()
	oReport:IncMeter()
	oSection4c:Finish()

	//Impressão da quarta seção - SALDO CREDOR A TRANSPORTAR PARA PROXIMO PERIODO
	oSection4:Init()
	cFilCE6	:=	xFilial('CE6')
	cFilCDO	:=	xFilial('CDO')
	BeginSql alias cCE6_PER

		SELECT	CE6.CE6_CODLAN		 CDIAJUCE6	,
				RTRIM(CDO.CDO_DESCR) DESCLACE6	,
				SUM(CE6.CE6_SALDO)	 SALAJUCE6
		FROM	%table:CE6% CE6 INNER JOIN %table:CDO% CDO ON	CDO.CDO_CODAJU	=	CE6.CE6_CODLAN
		WHERE		CE6.%notDel%
		AND	CDO.%notDel%
		AND CE6.CE6_PERIOD	=	%exp:cPerAtu%
		AND	CE6.CE6_FILIAL	=	%exp:cFilCE6%
		AND	CDO.CDO_FILIAL	=	%exp:cFilCDO%
		AND CE6.CE6_SALDO	>	%exp:nSldComp%
		GROUP BY CE6.CE6_CODLAN, RTRIM(CDO.CDO_DESCR)
		ORDER BY 1

	EndSql

	(cCE6_PER)->(DbGoTop())

	While (cCE6_PER)->(!Eof())
		oSection4:Printline()
		oReport:IncMeter()
		(cCE6_PER)->(DbSkip())
	EndDo

	(cCE6_PER)->(DbCloseArea())
	oSection4:Finish()
	oReport:ThinLine()

	//Impressão do cabecalho da quinta seção
	oSection5c:Init()
	oSection5c:Printline()
	oReport:IncMeter()
	oSection5c:Finish()

	//Impressão da quinta seção - SAIDAS INCENTIVADAS
	oSection5:Init()
	(cAliasTMP)->(DbGoTop())
	While (cAliasTMP)->(!Eof())

		oReport:IncMeter()
		IncProc(STR0022) //Relacao de Notas

		oSection5:Cell('EMISSAO'):SetValue((cAliasTMP)->EMISSAO)
		oSection5:Cell('NFISCAL'):SetValue((cAliasTMP)->NFISCAL)
		oSection5:Cell('SERIE'):SetValue((cAliasTMP)->SERIE)
		oSection5:Cell('CLIFOR'):SetValue((cAliasTMP)->CLIEFOR)
		oSection5:Cell('LOJA'):SetValue((cAliasTMP)->LOJA)
		oSection5:Cell('CFO'):SetValue((cAliasTMP)->CFO)
		oSection5:Cell('ICMSISENTO'):SetValue((cAliasTMP)->ICMSISENTO)
		oSection5:Cell('ICMSOUTROS'):SetValue((cAliasTMP)->ICMSOUTROS)
		oSection5:Cell('CREDACU'):SetValue((cAliasTMP)->CREDACU)

		oSection5:Printline()

		(cAliasTMP)->(DbSkip())

	EndDo

	oSection5:Finish()
	oReport:ThinLine()

	(cAliasTMP)->(DbCloseArea())
	TRBSF3->(DbCloseArea())
Return