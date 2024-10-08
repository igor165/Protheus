#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA300E.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300PROC
 
Fun��o que far� o processamento da apura��o de ISS

@author Erick G. Dias
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FSA300PROC() 

Local aSM0		:= {}
Local lProc		:= .F.
Local oSay		:= nil
Local cIdF1P	:= ""
Local cSucesso 	:= ""
Local dDtIni	:= CTOD("  /  /    ")
Local dDtFim	:= CTOD("  /  /    ")

Private lAutomato := Iif(IsBlind(),.T.,.F.)

//Executa pergunta se nao for o ADVPR
IF lAutomato .Or. (lProc := Pergunte("FISA300"))
	
	dDtIni	:= mv_par01
	dDtFim	:= mv_par02

	//Verifica se j� existe apura��o gravada para a filial e per�odo selecionado
	cIdF1P	:= FSA300EApu(dDtIni,dDtFim)	
	IF !Empty(cIdF1P)
		//Dever� perguntar se deseja reprocessar apura��o
		lProc := ApMsgYesNo(STR0001 + CHR(13)+CHR(10)  + STR0002) //"J� existe apura��o gravada para a filial no per�odo especificado!" //"Deseja prosseguir com reprocessamento?"
		If lProc
			//Excluir apura��o com ID retornado 
			lProc	:= FSA300EXL(cIdF1P, .T.)			
		EndIF
	EndIF

EndIF

//Chama pergunta com op��es iniciais da rotina.
IF lAutomato .Or. lProc
	
	//Define quais as filiais dever�o ser processadas
	aSM0    := GetFilial(lAutomato)	

	//Executa fun��o principal para processamento da apura��o
	If GetVersao(.F.) <> "12"
		//Para vers�o 11 n�o utilizare transa��es, pois ocorre erro no componente do financeiro, que utiliza MSCREATE, j� que a vers�o 11 n�o possui FWTEMPORARYTABLE
		If Len(aSM0) > 0
			FwMsgRun(,{|oSay| cSucesso := ProcApur(aSM0,oSay,dDtIni,dDtFim) },STR0003,"")	 //"Processamento da apura��o"
		EndIf			
	Else
		BEGIN TRANSACTION

		If Len(aSM0) > 0
			FwMsgRun(,{|oSay| cSucesso := ProcApur(aSM0,oSay,dDtIni,dDtFim) },STR0003,"")	 //"Processamento da apura��o"
		EndIf
		
		END TRANSACTION
	EndiF
	
	If !lAutomato
		If cSucesso == '1'
			MsgInfo(STR0004) //"Processamento conclu�do com Sucesso!"
			//Chama visualiza��o da apura��o.			
			FISA300A("EDT")	
		ElseIF cSucesso == '2'
			MsgAlert(STR0005) //"N�o h� movimenta��o para as filiais e per�odo selecionados!"
		ElseIF cSucesso == '-1'
			MsgAlert(STR0006) //"Erro ao processar apura��o!"
		EndIf
		dbSelectArea("F1P")
		F1P->(dbSetOrder(2))
	EndIf

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFilial
 
Esta fun��o retorna um array com as filiais selecionadas pelo
usu�rio atrav�s da MatFilCacl. 

@return array com informa��es da pergunta MV_PARXX
@author Erick G. Dias
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function GetFilial(lAutomato)

Local aFil	:= {}
Local aSM0	:= {}
Local aAreaSM0	:= {}
Local nFil	:= 0

DEFAULT lAutomato := .F.

If !lAutomato .And. MV_PAR03 == 1	
    //chama fun��o para usu�rio escolher filial
    aFil:= MatFilCalc( .T. )
    If len(aFil) ==0
        MsgAlert(STR0007) //'Nenhuma filial foi selecionada, o processamento n�o ser� realizado.'
    EndiF	
Else
	//Adiciona filial logada para realizar o processamento
	AADD(aFil,{.T.,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_CGC})
EndIF

IF Len(aFil) > 0

	aAreaSM0 := SM0->(GetArea())
	DbSelectArea("SM0")
	
	//--------------------------------------------------------
	//Ir� preencher aSM0 somente com as filiais selecionadas
	//pelo cliente  
	//--------------------------------------------------------	
	SM0->(DbGoTop())
	If SM0->(MsSeek(cEmpAnt))
		Do While !SM0->(Eof()) 
			nFil := Ascan(aFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
			If nFil > 0 .And. aFil[nFil][1] .AND. cEmpAnt == SM0->M0_CODIGO
				Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
			EndIf
			SM0->(dbSkip())
		Enddo
	EndIf
	
	SM0->(RestArea(aAreaSM0))
EndIF

Return  aSM0

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300EApu
 
Fun��o que verifica se j� existe apura��o gravada para a filial 
e per�odo informado pelo usu�rio.


@author Erick G. Dias
@since 19/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FSA300EApu(dDtIni,dDtFim)

Local cIdRet	:= ""
Local cSelect	:= ""
Local cFrom	    := ""
Local cWhere	:= ""
Local cAliasQry	:= ""

dbSelectArea("F1P")
F1P->(dbSetOrder(1))

//Busca apura��o da filial e datas iniciais e finais

cSelect := "F1P.F1P_ID"
cFrom   += RetSQLName("F1P") + " F1P "
cWhere  += "F1P.F1P_FILIAL = " + ValToSQL(xFilial("F1P")) + " AND "

//Verifica se a data inicial est� compreenchida em alguma apura��o j� processada
cWhere  += " F1P.F1P_DTINI >= " + valToSql(dDtIni) + " AND F1P.F1P_DTFIM <= " + ValToSQL(dDtFim) + " AND "

cWhere  += "F1P.D_E_L_E_T_ = ' '"
cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"

cAliasQry := GetNextAlias()

BeginSQL Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

EndSQL

IF !(cAliasQry)->(Eof())
    //J� existe apura��o para esta filial e esta data inicial est� contida em alguma apura��o j� realizada
    cIdRet	:= (cAliasQry)->F1P_ID
	
	//Posiciono a F1P encontrada
	F1P->(DbSeek(xFilial("F1P") + (cAliasQry)->F1P_ID))	
	
EndIF

dbSelectArea(cAliasQry)
dbCloseArea()

Return cIdRet

//------------------------------------------------------------------
/*/{Protheus.doc} AtualizaMsg

Fun��o que ser� chamada para atualizar descri��o da barra de status

@author Erick G. Dias
@since 19/06/2019
@version 12.1.23
/*/
//------------------------------------------------------------------
Static Function AtualizaMsg( oSay, cMsg, lAutomato )

If !lAutomato
	oSay:cCaption := (cMsg)
	ProcessMessages()
EndIF

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcApur
 
Fun��o que far� processamento da apura��o, buscando as notas fiscais
e enviando os dados para a classe de apura��o.

@author Erick G. Dias
@since 19/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function ProcApur(aFil, oSay, dDtIni, dDtFim)

Local aAreaSM0  := SM0->(GetArea())
Local nX		:= 0
Local cAlsSai := ""
Local cAlsFin := ""
Local cAlsEnt := ""
Local cAlsUni := ""
Local cAlsInsFin := ""
Local cAlsValMes := ""
Local aParams := {}
Local oApuracao := NIL
Local oMovimento := NIL
Local cCodMun := ""
Local cRet := "0"
Local cMunSM0 := ""
Local nValMensal := 0
Local cUFSM0 := 0
Local cIBGESM0 := ""
Local nPercBaixa := 0
Local lEmissEX 	 :=	.F. //Se os servi�os tomados do EX, devem ser pela Emiss�o
Local nIssReti     := ""


AtualizaMsg( oSay, STR0008 + cFilAnt, lAutomato ) //"Iniciando processamento"

// Processamento das filiais selecionadas.
For nX := 1 to Len(aFil)

	SM0->(DbGoTop ())
	SM0->(MsSeek (aFil[nX][1]+aFil[nX][2], .T.))
	cFilAnt := FWGETCODFILIAL

	cIBGESM0 := Iif(Len(Alltrim(SM0->M0_CODMUN)) < 7, RetUfIBGE(SM0->M0_ESTENT) + SM0->M0_CODMUN, SM0->M0_CODMUN)
	cUFSM0 := RetUfIBGE(Left(cIBGESM0, 2))
	cMunSM0 := Right(cIBGESM0, 5)

	AtualizaMsg( oSay, STR0009 + cFilAnt, lAutomato ) //"Processando Filial : "

	lEmissEX := GetNewPar("MV_SPDBIFE","")=="2" //2 - Pela Emiss�o

	oApuracao := APURISS():New()
	oApuracao:setDtIni(dDtIni)
	oApuracao:setDtFim(dDtFim)

	// ********************************************************************
	// PROCESSAMENTO DAS SA�DAS - PRESTA��ES
	// ********************************************************************

	aParams := {'S', oApuracao:getDtIni(), oApuracao:getDtFim()}
	cAlsSai := FSA300EQRY("SAIDAS", aParams)[1]

	While (cAlsSai)->(!Eof())

		cCodMun := RetUfIBGE(AllTrim((cAlsSai)->ESTADO)) + (cAlsSai)->MUNICIPIO

		oMovimento := APURISSMOV():New()

		oMovimento:setCodISS((cAlsSai)->FT_CODISS)
		oMovimento:setValCont((cAlsSai)->FT_VALCONT)
		oMovimento:setMatTerc((cAlsSai)->FT_ISSMAT)
		oMovimento:setMatProp(0)
		oMovimento:setSubEmp((cAlsSai)->FT_ISSSUB)
		oMovimento:setIsent((cAlsSai)->FT_ISENICM)
		oMovimento:setBsCalc((cAlsSai)->FT_BASEICM)
		oMovimento:setISSDest((cAlsSai)->FT_VALICM)

		// ISS Retido
		If ((cAlsSai)->FT_RECISS == '1')
			oMovimento:setBsRetPr((cAlsSai)->FT_BASEICM)
			oMovimento:setISSRetP((cAlsSai)->FT_VALICM)
		EndIf	

		// Adiciona movimento na apura��o
		oApuracao:addMov(cCodMun, oMovimento)

		(cAlsSai)->(dbSkip())

	EndDo

	(cAlsSai)->(dbCloseArea())

	// ********************************************************************
	// PROCESSAMENTO DAS ENTRADAS - AQUISI��ES - SOMENTE COM RETEN��O
	// ********************************************************************

	cAlsFin := ISSFiscal(oApuracao:getDtIni(), oApuracao:getDtFim(),,,,"P")

	dbSelectArea(cAlsFin)
	(cAlsFin)->(DbGoTop())

	
	// Para cada nota retornada pelo componente do financeiro farei a busca na SFT
	// para obter as informa��es necess�rias para a apura��o.

	While (cAlsFin)->(!Eof())

		// Considera somente contas a pagar - Entradas (IDEAL SERIA PARAMETRIZAR O COMPONENTE)
		If (cAlsFin)->TIPOPR == "P"	
			nIssReti 		:=	Iif((cAlsFin)->(FieldPos("ISS"))>0, (cAlsFin)->ISS, ((cAlsFin)->BASEISS*(cAlsFin)->ALIQUOTA))
			aParams := {(cAlsFin)->NUMERO, (cAlsFin)->PREFIXO, (cAlsFin)->CLIFOR, (cAlsFin)->LOJA, oApuracao:getDtFim()}
			cAlsEnt := FSA300EQRY("ENTRADAS", aParams,,lEmissEX)[1]
			
			(cAlsEnt)->(DbGoTop())

			nPercBaixa:= nIssReti / (cAlsEnt)->F1_ISS
			AddMovBlcB(cAlsEnt,oMovimento,oApuracao,nPercBaixa,cIBGESM0)

			(cAlsEnt)->(dbCloseArea())

		EndIf

		(cAlsFin)->(dbSkip())

	EndDo

	(cAlsFin)->(dbCloseArea())

	//Busco os servi�os tomados do exterior, pela data de emiss�o 
	if lEmissEX
		aParams	  := {oApuracao:getDtIni(), oApuracao:getDtFim()}
		cAlsEntEX := FSA300EQRY("ENTRADASEX", aParams,,lEmissEX)[1]
		
		(cAlsEntEX)->(DbGoTop())
		nPercBaixa:= 1 //Percentual de baixa, neste caso � pela emiss�o. 1 Significa contemplar o valor cheio

		While (cAlsEntEX)->(!Eof())
			
			AddMovBlcB(cAlsEntEX,oMovimento,oApuracao,nPercBaixa,cIBGESM0)

			(cAlsEntEX)->(dbSkip())
		EndDo

		(cAlsEntEX)->(dbCloseArea())
	endif

	// ********************************************************************
	// PROCESSAMENTO DAS SOCIEDADES UNIPROFISSIONAIS...
	// ********************************************************************

	aParams := {oApuracao:getDtFim()}
	cAlsUni := FSA300EQRY("UNIPROF", aParams)[1]

	// Sempre retornar� somente 1 linha c/ a quantidade de prossifionais habilitados no per�odo.
	//Somente adicionar� movimenta��o se a quantidade for maior que zero
	If (cAlsUni)->(!Eof()) .And. (cAlsUni)->PROFHAB > 0	 
	
		// Obtenho o valor mensal da tabela F1U para a UF e Munic�pio do SIGAMAT
		aParams := {cUFSM0, cMunSM0, oApuracao:getDtFim()}
		cAlsValMes := FSA300EQRY("VALMENSAL", aParams)[1]

		If (cAlsValMes)->(!Eof())
			nValMensal := (cAlsValMes)->F1U_VALOR
		Else
			nValMensal := 0
		EndIf

		oApuracao:addUniProf(cIBGESM0, (cAlsUni)->PROFHAB, nValMensal)

		(cAlsValMes)->(dbCloseArea())
	
	EndIf

	(cAlsUni)->(dbCloseArea())

	// ********************************************************************
	// ISS DAS INSTITUI��ES FINANCEIRAS...
	// ********************************************************************

	aParams := {cValToChar(Year(oApuracao:getDtFim())) + StrZero(Month(oApuracao:getDtFim()), 2)}
	cAlsInsFin := FSA300EQRY("INSTFIN", aParams)[1]

	While (cAlsInsFin)->(!Eof())		
		
		oMovimento := APURISSMOV():New()

		oMovimento:setCodISS(AllTrim((cAlsInsFin)->CLL_CODLST))
		oMovimento:setValCont((cAlsInsFin)->CLL_VALCON)
		oMovimento:setMatTerc(0)
		oMovimento:setMatProp(0)
		oMovimento:setSubEmp(0)
		oMovimento:setIsent(0)
		oMovimento:setBsCalc((cAlsInsFin)->CLL_BASISS)
		oMovimento:setISSDest((cAlsInsFin)->CLL_VALISS)
		oMovimento:setISSRetA(0)
		
		// Adiciona movimento na apura��o - Sempre para o municipio da filial - CONFIRMAR!
		oApuracao:addMov(cIBGESM0, oMovimento)

		(cAlsInsFin)->(dbSkip())

	EndDo

	(cAlsInsFin)->(dbCloseArea())

Next nX

// Restauro a �rea da SM0 e o cFilAnt pois daqui para baixo o processamento eh na matriz (filial logada)
RestArea(aAreaSM0)
cFilAnt := FWGETCODFILIAL

// Se algum munic�pio foi apurado chama os m�todos de finaliza��o e grava��o...
If Len(oApuracao:GetApurMun()) > 0
	oApuracao:apurar()
	IF oApuracao:saveApur()
		//Apurou pelo menos uma filial e concluiu com sucesso
		cRet := "1"
	Else
		//Ocorreu erro no processamento da apura��o
		cRet := "-1"
	EndIF
Else
	//N�o existe movimenta��o para filial e per�odo selecionado
	cRet := "2"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QueryApur
 
Fun��o respons�vel por executar a query principal de apura��o.

@author joao.pellegrini
@since 24/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FSA300EQRY(cTpQuery, aParams, lExecQry,lEmissEX)

Local cSelect := ""
Local cFrom := ""
Local cWhere := ""
Local cOrder := ""
Local cAlsQry := ""
Local cMunSM0 := Iif(Len(Alltrim(SM0->M0_CODMUN)) < 7,RetUfIBGE(SM0->M0_ESTENT)+SM0->M0_CODMUN,SM0->M0_CODMUN)
Local aRet := Array(4)
Local cDtEmpty := Space(8)
Local lF2_ESTPRES := SF2->(FieldPos("F2_ESTPRES")) > 0
Local lF2_MUNPRES := SF2->(FieldPos("F2_MUNPRES")) > 0

DEFAULT lExecQry := .T.
DEFAULT lEmissEX := .F.

Do Case

	Case cTpQuery == "SAIDAS"

		cSelect := "SFT.FT_CODISS, "
		cSelect += "CASE "
		cSelect += "	WHEN SB1.B1_MEPLES = '1' OR SB1.B1_MEPLES = ' 1' THEN " + ValToSQL(cMunSM0) // BRANCO OU EP CONSIDERA EP
		cSelect += "	WHEN SB1.B1_MEPLES = '2' THEN "

		// Caso n�o tenha o campo F2_ESTPRES o estado ser� sempre o da SA1.
		If lF2_ESTPRES
			cSelect += " CASE "
			cSelect += " 	WHEN SF2.F2_ESTPRES <> " + ValToSql(Space(TamSX3("F2_ESTPRES")[1])) + " THEN "
			cSelect += " 		SF2.F2_ESTPRES"
			cSelect += " 	ELSE "
			cSelect += " 		SA1.A1_EST "
			cSelect += " END "
		Else
			cSelect += " SA1.A1_EST "	
		EndIf
	
		cSelect += "END ESTADO, "
		cSelect += "CASE "
		cSelect += "	WHEN SB1.B1_MEPLES = '1' OR SB1.B1_MEPLES = ' ' THEN " + ValToSQL(cMunSM0) // BRANCO OU EP CONSIDERA EP
		cSelect += "	WHEN SB1.B1_MEPLES = '2' THEN  "

		// Caso n�o tenha o campo F2_MUNPRES o munic�pio ser� sempre o da SA1.
		If lF2_MUNPRES
			cSelect += " CASE "
			cSelect += " 	WHEN SF2.F2_MUNPRES <> " + ValToSql(Space(TamSX3("F2_MUNPRES")[1])) + " THEN "
			cSelect += " 		SF2.F2_MUNPRES "
			cSelect += " 	ELSE "
			cSelect += " 		SA1.A1_COD_MUN "
			cSelect += " END "
		Else
			cSelect += " SA1.A1_COD_MUN "
		EndIf
	
		cSelect += "END MUNICIPIO, "
		cSelect += "SFT.FT_RECISS, SFT.FT_VALCONT, SFT.FT_ISSMAT, SFT.FT_ISSSUB, SFT.FT_ISENICM, SFT.FT_BASEICM, SFT.FT_VALICM "

		cFrom := RetSQLName("SFT") + " SFT "
		cFrom += "JOIN " + RetSQLName("SB1") + " SB1 ON (SB1.B1_FILIAL = " + ValToSQL(xFilial("SB1")) + " AND SB1.B1_COD = SFT.FT_PRODUTO AND SB1.D_E_L_E_T_ = ' ') "
		cFrom += "LEFT JOIN " + RetSQLName("SF2") + " SF2 ON (SF2.F2_FILIAL = " + ValToSQL(xFilial("SF2")) + " AND SF2.F2_DOC = SFT.FT_NFISCAL AND SF2.F2_SERIE = SFT.FT_SERIE AND SF2.F2_CLIENTE = SFT.FT_CLIEFOR AND SF2.F2_LOJA = SFT.FT_LOJA AND SF2.D_E_L_E_T_ = ' ') "
		cFrom += "LEFT JOIN " + RetSQLName("SA1") + " SA1 ON (SA1.A1_FILIAL = " + ValToSQL(xFilial("SA1")) + " AND SA1.A1_COD = SFT.FT_CLIEFOR AND SA1.A1_LOJA = SFT.FT_LOJA AND SA1.D_E_L_E_T_ = ' ') "
		cFrom += "LEFT JOIN " + RetSQLName("SD2") + " SD2 ON (SD2.D2_FILIAL = " + ValToSQL(xFilial("SD2")) + " AND SD2.D2_DOC = SFT.FT_NFISCAL AND SD2.D2_SERIE = SFT.FT_SERIE AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND SD2.D2_LOJA = SFT.FT_LOJA AND SD2.D2_ITEM = SFT.FT_ITEM AND SD2.D2_COD = SFT.FT_PRODUTO AND SD2.D_E_L_E_T_ = ' ') "

		cWhere := "SFT.FT_FILIAL = " + ValToSQL(xFilial("SFT")) + " AND "
		cWhere += "SFT.FT_TIPOMOV = " + ValToSQL(aParams[1]) + " AND "
		cWhere += "SFT.FT_ENTRADA >= " + ValToSql(aParams[2]) + " AND SFT.FT_ENTRADA <= " + ValToSQL(aParams[3]) + " AND "
		cWhere += "SFT.FT_CODISS <> " + ValToSql(Space(TamSX3("FT_CODISS")[1])) + " AND "
		cWhere += "SFT.FT_DTCANC = ' ' AND "
		cWhere += "SFT.D_E_L_E_T_ = ' ' "
 
	Case cTpQuery == "ENTRADAS"

		cSelect := "SD1.D1_CODISS, SD1.D1_BASEISS, SD1.D1_VALISS, SD1.D1_ALIQISS, "
		cSelect += "SFT.FT_TIPOMOV, SFT.FT_TIPO, SFT.FT_ESPECIE, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_CLIENT, SFT.FT_LOJENT, SFT.FT_FORMUL, SFT.FT_CHVNFE, SFT.FT_EMISSAO, FT_DTCANC, SFT.FT_VALCONT, SFT.FT_ISSMAT, SFT.FT_ISSSUB, SFT.FT_OUTRICM, SFT.FT_ISENICM, SFT.FT_BASEICM, SFT.FT_ALIQICM, SFT.FT_VALICM, SFT.FT_RECISS, SFT.FT_PRODUTO, SFT.FT_ESTADO, "
		cSelect += "SF1.F1_ESTPRES, SF1.F1_INCISS, SF1.F1_VALBRUT, SF1.F1_ISS,"
		cSelect += "SB1.B1_MEPLES"

		cFrom := RetSQLName("SF1") + " SF1 "
		cFrom += "JOIN " + RetSQLName("SD1") + " SD1 ON (SD1.D1_FILIAL = " + ValToSQL(xFilial("SD1")) + " AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SD1.D_E_L_E_T_ = ' ') "
		cFrom += "JOIN " + RetSQLName("SFT") + " SFT ON (SFT.FT_FILIAL = " + ValToSql(xFilial("SFT")) + " AND SFT.FT_TIPOMOV = 'E' AND SFT.FT_SERIE = SD1.D1_SERIE AND SFT.FT_NFISCAL = SD1.D1_DOC AND SFT.FT_CLIEFOR = SD1.D1_FORNECE AND SFT.FT_LOJA = SD1.D1_LOJA AND SFT.FT_ITEM = SD1.D1_ITEM AND SFT.FT_PRODUTO = SD1.D1_COD AND "		
		cFrom += "SFT.FT_CODISS <> " + ValToSql(Space(TamSX3("FT_CODISS")[1])) + " AND SFT.D_E_L_E_T_ = ' ') "
		cFrom += "JOIN " + RetSQLName("SB1") + " SB1 ON (SB1.B1_FILIAL = " + ValToSQL(xFilial("SB1")) + " AND SB1.B1_COD = SFT.FT_PRODUTO AND SB1.D_E_L_E_T_ = ' ') "

		cWhere := "SF1.F1_FILIAL = " + ValToSQL(xFilial("SF1")) + " AND "
		cWhere += "SF1.F1_DOC = " + ValToSQL(aParams[1]) + " AND "
		// Usei o prefixo pois a SE2 n�o tem a s�rie do documento (deveria ter, j� que a SE1 tem). 
		// Esta compara��o (E2_PREFIXO == F1_SERIE) nunca deveria ser feita, pois o prefixo pode ser
		// alterado no par�metro MV_2DUPREF e n�o necessariamente ser� igual ao F1_SERIE.
		cWhere += "SF1.F1_PREFIXO = " + ValToSQL(aParams[2]) + " AND "
		cWhere += "SF1.F1_FORNECE = " + ValToSQL(aParams[3]) + " AND "
		cWhere += "SF1.F1_LOJA = " + ValToSQL(aParams[4]) + " AND "
		cWhere += "SF1.F1_DTDIGIT <= " + ValToSql(aParams[5]) + " AND "
		cWhere += "SF1.D_E_L_E_T_ = ' ' "
		//Se for tratado na emiss�o, ser� utilizado o resultado da query ENTRADASEX
		if lEmissEX
			cWhere += " AND NOT (SF1.F1_EST = 'EX' AND "
			cWhere += "SF1.F1_FORMUL = 'S' AND SF1.F1_RECISS = '2') "			
		endif

	Case cTpQuery == "ENTRADASEX"

		cSelect := "SD1.D1_CODISS, SD1.D1_BASEISS, SD1.D1_VALISS, SD1.D1_ALIQISS, "
		cSelect += "SFT.FT_TIPOMOV, SFT.FT_TIPO, SFT.FT_ESPECIE, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_CLIENT, SFT.FT_LOJENT, SFT.FT_FORMUL, SFT.FT_CHVNFE, SFT.FT_EMISSAO, FT_DTCANC, SFT.FT_VALCONT, SFT.FT_ISSMAT, SFT.FT_ISSSUB, SFT.FT_OUTRICM, SFT.FT_ISENICM, SFT.FT_BASEICM, SFT.FT_ALIQICM, SFT.FT_VALICM, SFT.FT_RECISS, SFT.FT_PRODUTO, SFT.FT_ESTADO, "
		cSelect += "SF1.F1_ESTPRES, SF1.F1_INCISS, SF1.F1_VALBRUT,F1_PREFIXO,F1_DUPL,F1_FORNECE,F1_LOJA, SF1.F1_ISS,"
		cSelect += "SB1.B1_MEPLES"

		cFrom := RetSQLName("SF1") + " SF1 "
		cFrom += "JOIN " + RetSQLName("SD1") + " SD1 ON (SD1.D1_FILIAL = " + ValToSQL(xFilial("SD1")) + " AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SD1.D_E_L_E_T_ = ' ') "
		cFrom += "JOIN " + RetSQLName("SFT") + " SFT ON (SFT.FT_FILIAL = " + ValToSql(xFilial("SFT")) + " AND SFT.FT_TIPOMOV = 'E' AND SFT.FT_SERIE = SD1.D1_SERIE AND SFT.FT_NFISCAL = SD1.D1_DOC AND SFT.FT_CLIEFOR = SD1.D1_FORNECE AND SFT.FT_LOJA = SD1.D1_LOJA AND SFT.FT_ITEM = SD1.D1_ITEM AND SFT.FT_PRODUTO = SD1.D1_COD AND "		
		cFrom += "SFT.FT_CODISS <> " + ValToSql(Space(TamSX3("FT_CODISS")[1])) + " AND SFT.D_E_L_E_T_ = ' ') "
		cFrom += "JOIN " + RetSQLName("SB1") + " SB1 ON (SB1.B1_FILIAL = " + ValToSQL(xFilial("SB1")) + " AND SB1.B1_COD = SFT.FT_PRODUTO AND SB1.D_E_L_E_T_ = ' ') "

		cWhere := "SF1.F1_FILIAL = " + ValToSQL(xFilial("SF1")) + " AND "
		cWhere += "SF1.F1_EST = 'EX' AND "
		cWhere += "SF1.F1_FORMUL = 'S' AND "
		cWhere += "SF1.F1_EMISSAO >= " + ValToSql(aParams[1]) + " AND "
		cWhere += "SF1.F1_EMISSAO <= " + ValToSql(aParams[2]) + " AND "
		cWhere += "SF1.F1_RECISS = '2' AND " //ISS RETIDO
		cWhere += "SF1.D_E_L_E_T_ = ' ' "

	Case cTpQuery == "UNIPROF"

		cSelect := "COUNT(F1S.F1S_ID) PROFHAB "

		cFrom := RetSQLName("F1S") + " F1S "

		cWhere := "(F1S.F1S_FILIAL = " + ValToSQL(xFilial("F1S")) + " AND "
		cWhere += "(F1S.F1S_INIHAB <= " + ValToSql(aParams[1]) + " AND (F1S.F1S_FIMHAB >= " + ValToSQL(aParams[1]) + " OR F1S.F1S_FIMHAB = " + ValToSQL(cDtEmpty) + " )) AND "
		cWhere += "F1S.D_E_L_E_T_ = ' ')"

	Case cTpQuery == "EMPREGADOS_SOCIOS"

		cSelect := "F1S.F1S_ESCOL, F1S.F1S_PARSOC, F1S.F1S_CPF, F1S.F1S_NOME, F1S.F1S_INIHAB, F1S.F1S_FIMHAB "

		cFrom := RetSQLName("F1S") + " F1S "

		cWhere := "(F1S.F1S_FILIAL = " + ValToSQL(xFilial("F1S")) + " AND "
		cWhere += "(F1S.F1S_INIHAB <= " + ValToSql(aParams[1]) + " AND (F1S.F1S_FIMHAB >= " + ValToSQL(aParams[1]) + " OR F1S.F1S_FIMHAB = " + ValToSQL(cDtEmpty) + " )) AND "
		cWhere += "F1S.D_E_L_E_T_ = ' ')"
	
	Case cTpQuery == "INSTFIN"

		cSelect := "CLL.CLL_CODCTA, CLL.CLL_COSIF, CLL.CLL_QUANT, CLL.CLL_CODLST, CLL.CLL_VALCON, CLL.CLL_BASISS, CLL.CLL_ALQISS, CLL.CLL_VALISS, CLL.CLL_OBS "

		cFrom := RetSQLName("CLL") + " CLL "

		cWhere := "CLL.CLL_FILIAL = " + ValToSQL(xFilial("CLL")) + " AND "
		cWhere += "CLL.CLL_PERIOD = " + ValToSQL(aParams[1]) + " AND "
		cWhere += "CLL.D_E_L_E_T_ = ' '"

	Case cTpQuery == "VALMENSAL"

		cSelect := "F1U.F1U_VALOR "

		cFrom := RetSQLName("F1U") + " F1U "

		cWhere := "(F1U.F1U_FILIAL = " + ValToSQL(xFilial("F1U")) + " AND "
		cWhere += "F1U.F1U_UF = " + ValToSQL(aParams[1]) + " AND "
		cWhere += "F1U.F1U_CODMUN = " + ValToSQL(aParams[2]) + " AND "
		cWhere += "(F1U.F1U_DTINI <= " + ValToSql(aParams[3]) + " AND (F1U.F1U_DTFIM >= " + ValToSQL(aParams[3]) + " OR F1U.F1U_DTFIM = " + ValToSQL(cDtEmpty) + " )) AND "
		cWhere += "F1U.D_E_L_E_T_ = ' ')"

EndCase

If lExecQry

	cAlsQry := GetNextAlias()

	// Prepara��o da query para execu��o.

	cSelect := '%' + cSelect + '%'
	cFrom := '%' + cFrom + '%'
	cWhere := '%' + cWhere + cOrder + '%'

	BeginSQL Alias cAlsQry

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%

	EndSQL

	dbSelectArea(cAlsQry)
	(cAlsQry)->(DbGoTop())

EndIf

aRet[1] := cAlsQry
aRet[2] := cSelect
aRet[3] := cFrom
aRet[4] := cWhere

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QueryApur
 
Fun��o respons�vel por adicionar movimento na apura��o do bloco b

Vari�veis:
cAlias - Alias das NF's
oMovimento - Objeto do movimento
oApuracao - Objeto da apura��o
nValor - Valor de refer�ncia do movimento
cIBGESM0 - municipio do movimento

@author matheus.massarotto
@since 12/05/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function AddMovBlcB(cAlias,oMovimento,oApuracao,nValor,cIBGESM0)
Local nPercBaixa := 0
Local lRet		 := .F.

nPercBaixa := nValor

While (cAlias)->(!Eof())

	oMovimento := APURISSMOV():New()

	oMovimento:setCodISS((cAlias)->D1_CODISS)
	oMovimento:setValCont(0)
	oMovimento:setMatTerc(0)
	oMovimento:setMatProp(0)
	oMovimento:setSubEmp(0)
	oMovimento:setIsent(0)
	oMovimento:setBsCalc(0)
	oMovimento:setISSDest(0)
	oMovimento:setISSRetA(Round((cAlias)->D1_VALISS * nPercBaixa, 2))

	// Adiciona movimento na apura��o - Sempre para o municipio da filial
	oApuracao:addMov(cIBGESM0, oMovimento)

	(cAlias)->(dbSkip())

	lRet:=.T.

EndDo

Return(lRet)


