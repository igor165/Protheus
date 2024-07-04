#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSCTB06.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "topconn.ch"

#DEFINE VAR_CHAVE	1
#DEFINE VAR_COUNT	2
#DEFINE VAR_REG		3

#DEFINE LP_FDESP    10
#DEFINE LP_FLTAV    20

#DEFINE LP_P9CN    1
#DEFINE LP_P9CT    2
#DEFINE LP_P9AG    3
#DEFINE LP_P9BD9BL 4 
#DEFINE LP_P9NB9NC 5 
#DEFINE LP_P9LA    6
#DEFINE LP_P9LB    7

#DEFINE LP_PROVISAO		    "9CN"
#DEFINE LP_CUSTO		    "9CT"

#DEFINE LP_INCLUSAO		    "9AG"
#DEFINE LP_BAIXA		    "9BD"
#DEFINE LP_CANCELA_BAIXA    "9BL"
#DEFINE LP_BAIXA_NB		    "9NB"
#DEFINE LP_CANCELA_BAIXA_NB "9NC"

#DEFINE LP_PROVISAO_LA	    "9LA"
#DEFINE LP_CUSTO_LA		    "9LB"

#DEFINE CTBPLSROT   "PLSCTB06"

#DEFINE PRONTA 		"3"
#DEFINE FATURADA 	"4"
#DEFINE REEMBOLSO   "04"

static __cParCodInt	:= ''
static __cParMes	:= space(2)
static __cParAno	:= space(4)
static __dParDtIni	:= ctod('')
static __dParDtFim	:= ctod('')
static __cParRdaDe	:= ''
static __cParRdaAte	:= ''
static __cParClaRda	:= ''
static __cLPINFO	:= ''
static __nParTipCtb := 0
static __lParChkALC	:= .f.
static __lParChkFC	:= .f.
static __nParChkMTGR:= 1
static __lLoteAviso := .f.
static __lParDtDisp	:= .f.
static __lOracle 	:= nil
static __lCtbIniLan	:= findFunction("CtbIniLan")
static __lCtbFinLan	:= findFunction("CtbFinLan")

static aPadrao 	 := { { LP_PROVISAO, .f. },;		//01
					  { LP_CUSTO, .f. },;			//02
					  { LP_INCLUSAO, .f. },;		//03
					  { LP_BAIXA, .f. },;			//04
					  { LP_CANCELA_BAIXA, .f. },;	//05
					  { LP_PROVISAO_LA, .f. },;		//06
					  { LP_BAIXA_NB, .f. },;		//07
					  { LP_CANCELA_BAIXA_NB, .f. },;//08
					  { LP_CUSTO_LA, .f. } }		//09

static lAutoStt := .f.
static aParamAUTO := {}

/*/{Protheus.doc} PLSCTB06
Contabilizacao de Despesas - Provisão , Inclusao, Baixa e Cancelamento de Baixa

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
function PLSCTB06(lauto)
local lUnimed := getNewPar('MV_PLSUNI','0') == '1'

Default lauto := .F.

lAutoStt := lAuto

if empty(loteCont("PLSDES"))
	aviso(STR0008,STR0061,{"Ok"}) //"Atenção" ##'Lote não encontrado - chave [PLSDES]'
	return
endIf

plShoPer(lUnimed)
	
return 

/*/{Protheus.doc} PLINFDAD 
Contabilizacao de Guias

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
static function PLINFDAD()
local aArea 		:= getArea()
local nX			:= 0
local nTotReg		:= 0
local nH			:= 0
local nHorInI 		:= seconds()
local nNumProc 		:= iIf(__nParChkMTGR == 2, getNewPar("MV_CBD7THR", 1), 1 )
local cTabMult		:= ""
local cSqlMThread	:= ""
local cInicio		:= ""
local cFim			:= ""
local cErro			:= ""
local cDesLP		:= retDLP()
local cSemaApp		:= CTBPLSROT + '_' + cDesLP
local cTpLog		:= CTBPLSROT + "_PMOV"
local cTPDtTime 	:= 'LP - ' + cDesLP + ' - Inicio - [' + dtoc(date()) + ' - ' + time() + ']'
local lRet			:= .t.
local lProc			:= .t.
local lGrid			:= (__nParChkMTGR == 3 .and. TCIsVLock())
local aProcs 		:= {}
local aMatStat		:= {}
local aCallPar		:= {}
local aAmb			:= { cEmpAnt, cFilAnt, CTBPLSROT }
local oProCtb		:= nil

aEval(aPadrao, {|x| x[2] := verPadrao(x[1])})

__cLPINFO := retMLP(aPadrao, @lRet)

if ! lRet
	
	If ! lAutoStt
		aviso(STR0008,STR0014 + __cLPINFO, {"OK"} ) //"Atenção" ##"Para contabilizar as guias é necessário criar seguintes Lançamentos Padronizados: "
	endif

	return(lRet)

endIf

lRet := .f.

if ( nH := plsAbreSem(cSemaApp, .f.) ) == 0
	
	If ! lAutoStt
		aviso(STR0008,STR0062,{"Ok"}) //"Atenção" ##'Existe outro processo sendo executado, por favor, aguarde!'
	endIf

	return(lRet)

endIf

If (__lLoteAviso .AND. __nParTipCtb == 8) .OR. (__nParTipCtb == 6 .AND. !__lLoteAviso)
	If lAutoStt .OR. msgYesNo("Processar o ajuste de Rateios?")
		PLCTB06ART()
		If !lAutoStt
			msgAlert(STR0096) //"Processo concluido!"
		endif
	endIf
else
	//Monta o arquivo de trabalho
	cTabMult := PLRETDAD(@cSqlMThread)

	if ! empty(cTabMult) .and. (cTabMult)->( ! eof() )

		lRet := .t.

		// MultiThread/Grid
		if ( __nParChkMTGR == 2 .and. nNumProc >= 1 ) .or. lGrid
			
			aadd(aMatStat, __cParCodInt)
			aadd(aMatStat, __cParMes)
			aadd(aMatStat, __cParAno)
			aadd(aMatStat, __cParRdaDe)
			aadd(aMatStat, __cParRdaAte)
			aadd(aMatStat, __cParClaRda)
			aadd(aMatStat, __nParTipCtb)
			aadd(aMatStat, __lParChkALC)
			aadd(aMatStat, __lParChkFC)
			aadd(aMatStat, __nParChkMTGR)
			aadd(aMatStat, __lLoteAviso)
			aadd(aMatStat, __lParDtDisp)
			aadd(aMatStat, __cLPINFO)
			aadd(aMatStat, cSqlMThread)
			aadd(aMatStat, __dParDtIni)
			aadd(aMatStat, __dParDtFim)
			
			If lAutoStt

				aMatStat := aClone(getPar06())

				aadd(aMatStat, __cLPINFO)
				aadd(aMatStat, cSqlMThread)
				aadd(aMatStat, __dParDtIni)
				aadd(aMatStat, __dParDtFim)
				
			endIf

			aProcs := PROMThread(cTabMult, 'DES', __nParTipCtb, cDesLP)

			if select(cTabMult) > 0
				(cTabMult)->(dbCloseArea())
			endIf
			
			If ! lAutoStt
				procRegua(len(aProcs))
			endIf
			
			cInicio := strZero(1,10)
			cFim	:= strZero(len(aProcs),10)

			if ! lAutoStt .and. lGrid

				oProCtb 			 := gridClient():new()
				oProCtb:nWAIT4AGENTS := 90
				lProc	 			 := oProCtb:prepare('sGrid', aAmb, 'JOBRPCTB06', 'fGrid')
				
				if ! lProc

					cErro := oProCtb:getError()
					plsErr( "Erro GRID: Falha ao preparar ambiente:" + cErro, .t.)

					oProCtb:terminate()
					oProCtb := nil

				endIf

			else

				oProCtb := FWIPCWait():new(cSemaApp)
				oProCtb:setThreads(nNumProc)
				oProCtb:stopProcessOnError(.t.)
				oProCtb:setEnvironment(cEmpAnt, cFilAnt)
				oProCtb:start("JOBRPCTB06")

			endIf

			if lProc

				//Inicializa as Threads Transação controlada
				for nX := 1 to len(aProcs)

					incProc(__cLPINFO + '-' + STR0064 + cInicio + '] até [' + cFim + '] - ' + strZero(aProcs[nX,VAR_COUNT],10)) //'Movim. de ['

					aCallPar := nil
					aCallPar := { aProcs[nX], aMatStat }
					
					if ! lAutoStt .and. lGrid

						lProc := oProCtb:execute(aCallPar)

						if ! lProc
							exit
						endIf

					else
						
						lProc := oProCtb:go(aCallPar)				

						if ! lProc
							exit
						endIf	

					endIf

				next
				
				If ! lAutoStt
					incProc(STR0095)//'Finalizando...'
					processMessage()
				endIf
				
				if ! lAutoStt .and. lGrid

					if ! lProc
						
						if ! empty(oProCtb:aErrorProc)          
							varinfo('ERR', oProCtb:aErrorProc)   
						endIf

						if ! empty(oProCtb:aSendProc)          
							varinfo('PND', oProCtb:aSendProc)   
						endIf   

						cErro := oProCtb:getError()

						plsErr( "Erro GRID: Falha de Execucao:" + cErro, .t.)

					endIf

					oProCtb:terminate()
					oProCtb := nil

				else

					oProCtb:stop()

					cErro := oProCtb:getError()
					
					If ! lAutoStt
						plsErr(cErro)
					endIf
					
					oProCtb:removeThread(.t.)
					freeObj(oProCtb)
					oProCtb := nil

				endIf

			endIf

		else
			
			if __lCtbIniLan
				ctbIniLan()
			endIf
			dbSelectArea(cTabMult)

			count to nTotReg

			If ! lAutoStt
				procRegua(nTotReg)
			endIf
			
			(cTabMult)->(dbGoTop())

			if __nParTipCtb == LP_P9CN .or. __nParTipCtb == LP_P9CT .or. __nParTipCtb == LP_P9LA .or. __nParTipCtb == LP_P9LB
				PLPRODADGUI(cTabMult, nTotReg, nil)
			else
				PLPRODADTIT(cTabMult, nTotReg, nil)
			endIf

			if select(cTabMult) > 0
				(cTabMult)->(dbCloseArea())
			endIf

			if __lCtbFinLan
				CtbFinLan()
			endIf
		endIf

		PlGrvlog( cTPDtTime + ' - Fim - [' + dtoc(date()) + ' - ' + time() + '] - Duração Minut. - [' + allTrim(cValToChar((seconds() - nHorInI) / 60)) + ']', cTpLog, 2)

	endIf

	restArea(aArea)

	PLSFechaSem(nH, cSemaApp)

	if ! lAutoStt .and. empty(cErro)

		if lRet
			msgAlert(STR0096) //"Processo concluido!"
		else
			msgAlert(STR0013) //"Atenção" ## "Nenhum registro encontrado ou lançamento contábil inconsistente!"
		endIf

	endIf	
endIf

return

/*/{Protheus.doc} PLRETDAD
Seleciona registro para processar a contabilidade

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
static function PLRETDAD(cSqlMThread)
local nX		:= 0
local nSeconds 	:= seconds()
local cTab		:= criaTrab(nil, .f.)
local cSql		:= ""
local cTPMOVBAN	:= ""
local dData		:= stod( __cParAno + __cParMes + '01' )
local dDataIni	:= iIf( ! empty(__cParMes + __cParAno), firstDate(dData), __dParDtIni)
local dDataFim	:= iIf( ! empty(__cParMes + __cParAno), lastDate(dData) , __dParDtFim)
local aStruSQL	:= {}

default cSqlMThread	:= ''

//verifica qual banco de dados
getTpDB(@__lOracle)

if empty(cSqlMThread)
	
	incProc(STR0015) //"Aguarde, preparando dados..."

	//provisao ou custo
	if __nParTipCtb == LP_P9CN .or. __nParTipCtb == LP_P9CT

		cSql := " SELECT BD7.R_E_C_N_O_ BD7Recno, BD7_FILIAL, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_PROTOC"
		
		if __nParTipCtb == LP_P9CT
			cSql += ", BD7_DTCTBF "
		else
			cSql += ", BD7_DTDIGI "
		endif

		cSql += " FROM " + retSQLName("BD7") + " BD7 "

		//inclui busca na BAU
		cSql += sqlInBAU('BD7')
	
		cSql += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
		cSql += "   AND BD7_CODOPE = '" + __cParCodInt + "' "
		cSql += "   AND BD7_CODLDP NOT IN( '" + PLSRETLDP(9) + "', '" + PLSRETLDP(4) + "') "
		cSql += "   AND BD7_SITUAC <> '2' " // 1 - Ativo / 2 - Cancelado / 3 - Bloqueado
		
		if __nParTipCtb == LP_P9CN
	
			cSql += " AND BD7_DTDIGI BETWEEN '" + dtos(dDataIni) + "' AND '" +  dtos(dDataFim) + "' "
			cSql += " AND BD7_LAPRO = '" + space( tamSX3("BD7_LAPRO")[1] ) + "' "

		elseIf __nParTipCtb == LP_P9CT

			cSql += " AND BD7_DTCTBF BETWEEN '" + dtos(dDataIni) + "' AND '" +  dtos(dDataFim) + "' "
			cSql += " AND BD7_FASE IN ('3','4') "
			cSql += " AND BD7_LA = '" + space( tamSX3("BD7_LA")[1] ) + "' "

		endIf

		if ! empty(__cParRdaDe) .and. ! empty(__cParRdaAte)
			cSql += " AND BD7_CODRDA BETWEEN '" + __cParRdaDe + "' AND '" + __cParRdaAte + "' "
		endIf

		cSql += "   AND BD7.D_E_L_E_T_ = ' ' "
		
		//nao considera registro do lote de aviso cobranco do a500 
		if __lLoteAviso

			cSql += "   AND NOT EXISTS ( SELECT 1 FROM " + retSQLName("B5T") + " B5T "
			cSql += "                     WHERE B5T_FILIAL = '" + xFilial("B5T") + "' "
			cSql += "                       AND B5T_OPEORI = BD7_CODOPE "
			cSql += "                       AND B5T_CODLDP = BD7_CODLDP "
			cSql += "                       AND B5T_CODPEG = BD7_CODPEG "
			cSql += "                       AND B5T_NUMGUI = BD7_NUMERO "
			cSql += "   					AND B5T.D_E_L_E_T_ = ' ' ) "

		endIf
			
		if __nParTipCtb == LP_P9CT
			cSql += " ORDER BY BD7_FILIAL, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN, BD7_PROTOC, BD7_DTCTBF "
		else
			cSql += " ORDER BY BD7_FILIAL, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN, BD7_PROTOC, BD7_DTDIGI "
		endIf
	
	//inclusao
	elseIf __nParTipCtb == LP_P9AG

		cSql := " SELECT SE2.R_E_C_N_O_ SE2Recno "
		cSql += " FROM " + retSQLName("SE2") + " SE2 "

		//inclui busca na BAU
		cSql += sqlInBAU('SE2')

		cSql += " WHERE E2_FILIAL  = '" + xFilial("SE2") + "' "
		cSql += "   AND E2_EMIS1 BETWEEN '" + dtos(dDataIni) + "' AND '" +  dtos(dDataFim) + "' "
		cSql += "   AND E2_TIPO NOT IN " + formatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT,"|")
		cSql += "   AND E2_LA = '" + space( tamSX3("E2_LA")[1] ) + "' "

		//desconsidera titulos liquidados
		cSql += "   AND E2_NUMLIQ = ' ' " 

		if ! empty(__cParRdaDe) .or. ! empty(__cParRdaAte)
			cSql += " AND E2_CODRDA BETWEEN '" + __cParRdaDe + "' AND '" + __cParRdaAte + "' "
		endIf

		if __lOracle
			cSql += " AND SUBSTR(E2_ORIGEM,1,3) = 'PLS' " 
			cSql += " AND TRIM(E2_TITPAI) IS NULL "
		else
			cSql += " AND SUBSTRING(E2_ORIGEM,1,3) = 'PLS' " 
			cSql += " AND E2_TITPAI = ' ' "
		endIf
		
		cSql += "   AND SE2.D_E_L_E_T_ = ' ' "

		cSql += " ORDER BY E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, SE2Recno "
	
	//baixa cancelamento da baixa (movimenta banco ou nao)
	elseIf __nParTipCtb == LP_P9BD9BL .or. __nParTipCtb == LP_P9NB9NC
		
		cTPMOVBAN := plRetMTBX('DES', __nParTipCtb)

		cSql := " SELECT SE2.R_E_C_N_O_ SE2Recno, "
		cSql += "        FK2.R_E_C_N_O_ FK2Recno "

		cSql += " FROM " + retSQLName("FK2") + " FK2 "

		//inclui busca na FK7
		cSql += sqlInFK7()

		//inclui busca na SE2
		cSql += sqlInSE2()

		//inclui busca na BAU
		cSql += sqlInBAU('SE2')

		cSql += " WHERE FK2_FILIAL = '" + xFilial("FK2") + "' "
		
		if __lParDtDisp
			cSql += "   AND FK2_DTDISP BETWEEN '" + dtos(dDataIni) + "' AND '" +  dtos(dDataFim) + "' "
		else	
			cSql += "   AND FK2_DATA BETWEEN '" + dtos(dDataIni) + "' AND '" +  dtos(dDataFim) + "' "
		endIf

		cSql += "   AND FK2_LA <> 'S' "

		//lista motivo de baixa que gera movimentacao bancaria ou baixa de PA
		cSql += "   AND FK2_MOTBX IN " + formatIn(cTPMOVBAN,"|")
		cSql += "   AND FK2.D_E_L_E_T_ = ' ' "

		cSql += " ORDER BY E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, FK2Recno "


	//provisao de lote de aviso
	elseIf __nParTipCtb == LP_P9LA

		cSql := " SELECT B6T.R_E_C_N_O_ B6TRecno, B6T_FILIAL, B6T_SEQLOT, B6T_NMGPRE, "
		cSql += "        B5T.R_E_C_N_O_ B5TRecno, "
		cSql += "        B2T.R_E_C_N_O_ B2TRecno  "

		cSql += " FROM " + retSQLName("B2T") + " B2T "

		//inclui busca na B5T
		cSql += sqlInB5T()

		//inclui busca na B6T
		cSql += sqlInB6T()

		cSql += " WHERE B2T_FILIAL = '" + xFilial("B2T") + "' "
		cSql += "   AND B2T_STATUS = '1' "

		if ! empty(__cParRdaDe) .and. ! empty(__cParRdaAte)
			cSql += " AND B2T_CODRDA BETWEEN '" + __cParRdaDe + "' AND '" + __cParRdaAte + "' "
		endIf

		cSql += "   AND B2T_DATIMP BETWEEN '" + dtos(dDataIni) + "' AND '" +  dtos(dDataFim) + "' "
		cSql += "   AND B2T.D_E_L_E_T_ = ' ' "

		cSql += " ORDER BY B6T_FILIAL, B6T_OPEHAB, B6T_NUMLOT, B6T_NMGPRE "

	
	//cobrado - lote de aviso
	elseIf __nParTipCtb == LP_P9LB

		cSql := " SELECT B6T.R_E_C_N_O_ B6TRecno, B6T_FILIAL, B6T_SEQLOT, B6T_NMGPRE, "
		cSql += "        B5T.R_E_C_N_O_ B5TRecno, "
		cSql += "        B2T.R_E_C_N_O_ B2TRecno, "
		cSql += "        BD7.R_E_C_N_O_ BD7Recno  "

		cSql += " FROM " + retSQLName("B2T") + " B2T "

		//inclui busca na B5T
		cSql += sqlInB5T(.t.)

		//inclui busca na B6T
		cSql += sqlInB6T(.t.)
		
		//inclui busca na BD7/B5T
		cSql += sqlIn7B5T(dDataIni, dDataFim)

		cSql += " WHERE B2T_FILIAL = '" + xFilial("B2T") + "' "
		cSql += "   AND B2T_STATUS = '1' "

		if ! empty(__cParRdaDe) .and. ! empty(__cParRdaAte)
			cSql += " AND B2T_CODRDA BETWEEN '" + __cParRdaDe + "' AND '" + __cParRdaAte + "' "
		endIf

		cSql += "   AND B2T.D_E_L_E_T_ = ' ' "

		cSql += " ORDER BY B6T_FILIAL, B6T_OPEHAB, B6T_NUMLOT, B6T_NMGPRE "

	endIf

	//ponto de entrada para alteracao de query
	if existBlock("PLSCT06PRC")
		cSql := execBlock("PLSCT06PRC", .f. , .f. ,{ cSql, __nParTipCtb })
	endIf

	cSqlMThread := cSql

	plsLogFil(cSql, plsLogCTB( __cLPINFO + '_QUERY_PRINCIPAL_' + CTBPLSROT, .f. ) )

//retorna query para multThread
else
	cSql := cSqlMThread 
endIf

FWLogMsg("INFO",, "SIGAPLS", funName(), "", "01", "INICIO|"  + dtoc(dDatabase) + "|" + time(), 0, 0, {})

MPSysOpenQuery(cSql, cTab)

FWLogMsg("INFO",, "SIGAPLS", funName(), "", "01", "TERMINO|" + dtoc(dDatabase) + "|" + time() + " | Tempo Gasto: " + allTrim(str(seconds() - nSeconds)), 0, 0, {})

aStruSQL := (cTab)->( dbStruct() )

for nX := 1 to len(aStruSQL)

	if aStruSQL[nX,2] <> "C"
		tcSetField(cTab, aStruSQL[nX,1], aStruSQL[nX,2], aStruSQL[nX,3], aStruSQL[nX,4])
	endIf
	
next

(cTab)->(dbGotop())

return(cTab)

/*/{Protheus.doc} sqlInBAU
retorna string query para implementar busca na BAU

@author  PLS TEAM
@version P12
@since   06.06.19
/*/
static function sqlInBAU(cAlias)
local cSql 	  := ''
local cVarRda := ''

if ! empty(__cParClaRda)

	cVarRda := strTran(allTrim(__cParClaRda), ",", "','")

	cSql += " INNER JOIN " + retSQLName("BAU") + " BAU "
	cSql += "    ON BAU_FILIAL = '" + xFilial('BAU') + "' "
	
	if cAlias == 'SE2'	
		cSql += "   AND BAU_CODIGO = E2_CODRDA "
	elseIf cAlias == 'BD7'	
		cSql += "   AND BAU_CODIGO = BD7_CODRDA "
	endIf	
	
	cSql += "   AND BAU_TIPPRE IN ('" + allTrim(cVarRda) + "') "
	cSql += "   AND BAU.D_E_L_E_T_ = ' ' "

endIf

return(cSql)

/*/{Protheus.doc} sqlInB5T
retorna string query para implementar busca na B5T

@author  PLS TEAM
@version P12
@since   06.06.19
/*/
static function sqlInB5T(lPeg)
local cSql := ''

default lPeg := .f.

cSql += " INNER JOIN " + retSQLName("B5T") + " B5T "
cSql += "    ON B5T_FILIAL = '" + xFilial("B5T") + "' "
cSql += "   AND B5T_OPEHAB = B2T_OPEHAB "
cSql += "   AND B5T_NUMLOT = B2T_NUMLOT "

if lPeg
	cSql += "   AND B5T_CODPEG <> '" + space( tamSX3("B5T_CODPEG")[1] ) + "' "
else	
	cSql += "   AND B5T_CODPEG = '" + space( tamSX3("B5T_CODPEG")[1] ) + "' "
endIf	

cSql += "   AND B5T.D_E_L_E_T_ = ' ' "

return(cSql)

/*/{Protheus.doc} sqlInFK7
retorna string query para implementar busca

@author  PLS TEAM
@version P12
@since   06.06.19
/*/
static function sqlInFK7()
local cSql := ''

cSql += " INNER JOIN " + retSQLName("FK7") + " FK7 "
cSql += "    ON FK7_FILIAL = '" + xFilial("FK7") + "' "
cSql += "   AND FK7_IDDOC  = FK2_IDDOC "
cSql += "   AND FK7_ALIAS  = 'SE2' "
cSql += "   AND FK7.D_E_L_E_T_ = ' ' "

return(cSql)

/*/{Protheus.doc} sqlInSE2
retorna string query para implementar busca

@author  PLS TEAM
@version P12
@since   06.06.19
/*/
static function sqlInSE2()
local cSql := ''

//verifica qual banco de dados
getTpDB(@__lOracle)

cSql += " INNER JOIN " + retSQLName("SE2") + " SE2 "
cSql += "    ON " + plFiePar("E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_FORNECE|E2_LOJA", "FK7_CHAVE")
cSql += "   AND E2_TIPO NOT IN " + formatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT,"|")

if ! empty(__cParRdaDe) .or. ! empty(__cParRdaAte)
	cSql += " AND E2_CODRDA BETWEEN '" + __cParRdaDe + "' AND '" + __cParRdaAte + "' "
endIf

if __lOracle
	cSql += " AND SUBSTR(E2_ORIGEM,1,3) = 'PLS' " 
	cSql += " AND TRIM(E2_TITPAI) IS NULL"
else
	cSql += " AND SUBSTRING(E2_ORIGEM,1,3) = 'PLS' " 
	cSql += " AND E2_TITPAI = ' ' "
endIf

cSql += "   AND SE2.D_E_L_E_T_ = ' ' "

return(cSql)

/*/{Protheus.doc} sqlInB6T
retorna string query para implementar busca na B6T

@author  PLS TEAM
@version P12
@since   06.06.19
/*/
static function sqlInB6T(lLA)
local cSql := ''		

default lLA := .f.

cSql += " INNER JOIN " + retSQLName("B6T") + " B6T "
cSql += "    ON B6T_FILIAL = '" + xFilial("B6T") + "' "
cSql += "   AND B6T_OPEHAB = B5T_OPEHAB "
cSql += "   AND B6T_NUMLOT = B5T_NUMLOT "
cSql += "   AND B6T_NMGPRE = B5T_NMGPRE "

if lLA
	cSql += " AND B6T_LA    = '" + space( tamSX3("B6T_LA")[1] )    + "' "
else	
	cSql += " AND B6T_LAPRO = '" + space( tamSX3("B6T_LAPRO")[1] ) + "' "
endIf

cSql += "   AND B6T.D_E_L_E_T_ = ' ' "

return(cSql)

/*/{Protheus.doc} sqlIn7B5T
retorna string query para implementar busca na BD7/B5T

@author  PLS TEAM
@version P12
@since   06.06.19
/*/
static function sqlIn7B5T(dDataIni, dDataFim)
local cSql := ''		

cSql += " INNER JOIN " + retSQLName("BD7") + " BD7 "
cSql += "    ON BD7_FILIAL = '" + xFilial("BD7") + "' "
cSql += "   AND BD7_CODOPE = B5T_OPEORI "
cSql += "   AND BD7_CODLDP = B5T_CODLDP "
cSql += "   AND BD7_CODPEG = B5T_CODPEG "
cSql += "   AND BD7_NUMERO = B5T_NUMGUI "
cSql += "   AND BD7_SEQUEN = B6T_SEQUEN "
cSql += "   AND BD7_DTDIGI BETWEEN '" + dtos(dDataIni) + "' AND '" +  dtos(dDataFim) + "' "
cSql += "   AND BD7.D_E_L_E_T_ = ' ' "

return(cSql)

/*/{Protheus.doc} PLPRODADGUI

@author  PLS TEAM
@version P12
@since   15.11.05
/*/
static function PLPRODADGUI(cTabMult, nTotReg, cThReadID)
local nHdlPrv 		:= 0
local nTotLanc		:= 0
local nValAux		:= 0
local cArquivo 		:= ""
local cAliasCAB		:= ""
local cChaveCAB 	:= ""
local cChaveBD6 	:= ""
local cChaveBD7 	:= ""
local cMatricUsr	:= ""
local cCodRda		:= ""
local cCodLoc		:= ""
local cIncPro		:= ""
local cLote			:= "" 
local dDatPro		:= ctod("")
local aFlagPLS 		:= {}
local aCT5			:= {}
local lCabecalho	:= .f.
local lMostraLC 	:= .f.
local lRet			:= .f.
local lReembolso	:= .f.
local dDtLote		:= ctod('')
local nTamDec		:= PLGetDec('BD7_VLRMAN')

private __PLSModLOT 	:= "PLSDES"
private lanceiCTB 		:= .f.
private lMsErroAuto 	:= .f.
private lMsHelpAuto		:= .t.
private lAutoErrNofile	:= .t.

default cThReadID := allTrim(str(thReadID()))

cLote := loteCont(__PLSModLOT)
BA1->(dbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
BA3->(dbSetOrder(1)) //BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
if FWAliasInDic("B5F")
	B5F->(dbSetOrder(3)) //B5F_FILIAL+B5F_CODINT+B5F_CODEMP+B5F_MATRIC+B5F_TIPREG+B5F_DIGITO     
endIf	
BAG->(dbSetOrder(1)) //BAG_FILIAL+BAG_CODIGO
BAU->(dbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
BCI->(dbSetOrder(1)) //BCI_FILIAL+BCI_CODOPE+BCI_CODLDP+BCI_CODPEG+BCI_FASE+BCI_SITUAC
BE4->(dbSetOrder(1)) //BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_SITUAC+BE4_FASE
BD5->(dbSetOrder(1)) //BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_SITUAC+BD5_FASE+dtos(BD5_DATPRO)+BD5_OPERDA+BD5_CODRDA
BD6->(dbSetOrder(1)) //BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
BD7->(dbSetOrder(1)) //BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC                                                               
BG9->(dbSetOrder(1)) //BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO
BI3->(dbSetOrder(5)) //BI3_FILIAL+BI3_CODINT+BI3_CODIGO
BQC->(dbSetOrder(1)) //BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB
BT5->(dbSetOrder(1)) //BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO
BT6->(dbSetOrder(1)) //BT6_FILIAL+BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO
B44->(dbSetOrder(1)) //B44_FILIAL+B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT
BOW->(dbSetOrder(1)) //BOW_FILIAL+BOW_PROTOC

if __lLoteAviso
	B5T->(dbsetorder(1)) //B5T_FILIAL+B5T_SEQLOT+B5T_SEQGUI
endIf	

//guias - LP 9CN/9CT
if __nParTipCtb == LP_P9CN .or.  __nParTipCtb == LP_P9CT
	
	while ! (cTabMult)->(eof())
		
		BD7->( msGoTo( (cTabMult)->BD7Recno ) )

		if __nParTipCtb == LP_P9CN
			
			if ! empty(BD7->BD7_LAPRO)
				(cTabMult)->(dbSkip())
				loop
			endIf

		else
			
			if ! empty(BD7->BD7_LA) .or. ! ( BD7->BD7_FASE $ (PRONTA + '|' + FATURADA) )
				(cTabMult)->(dbSkip())
				loop
			endIf

		endIf

		//quebra o movimento por peg, protocolo e data dtctbf
		//esta chave nao tem relacao com a chave da query principal nem com a quebra da thread
		if __nParTipCtb == LP_P9CN
			cChaveBD7 := (cTabMult)->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_PROTOC + BD7_DTDIGI )
			cCondic   := cTabMult + "->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_PROTOC + BD7_DTDIGI)"
		else
			cChaveBD7 := (cTabMult)->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_PROTOC + BD7_DTCTBF)
			cCondic   := cTabMult + "->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_PROTOC + BD7_DTCTBF)"
		endIf

		lRet := .f.
		
		if ! lAutoStt .and. cIncPro <> BD7->( BD7_CODRDA + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO )

			cIncPro := BD7->( BD7_CODRDA + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO )
			incProc( __cLPINFO + '-' + STR0016 + BD7->BD7_CODRDA + STR0017 + BD7->BD7_CODOPE + "." + BD7->BD7_CODLDP + "." + BD7->BD7_CODPEG + "." + BD7->BD7_NUMERO + "]" ) //"Rda [" ## "] Guia ["

		endIf

		//posiciona no cabacalho da guia
		if cChaveCAB <> BD7->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO)
	
			cAliasCAB := PLSRALCTM(BD7->BD7_TIPGUI)
			cChaveCAB := BD7->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO)

			(cAliasCAB)->( msSeek( cChaveCAB ) )

			BCI->( msSeek( xFilial("BCI") + BD7->(BD7_CODOPE + BD7_CODLDP + BD7_CODPEG)))
			//guia de reembolso
			lReembolso := BD7->BD7_TIPGUI == REEMBOLSO
			if lReembolso
				B44->( msSeek( xFilial("B44") + (cAliasCAB)->(BD5_OPEMOV+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT) ) )
				BOW->( msSeek( xFilial("BOW") + B44->B44_PROTOC ) )
			endIf

		endIf

		cMatricUsr 	:= (cAliasCab)->&(cAliasCab+"_OPEUSR") + (cAliasCab)->&(cAliasCab+"_CODEMP") + (cAliasCab)->&(cAliasCab+"_MATRIC") + (cAliasCab)->&(cAliasCab+"_TIPREG") + (cAliasCab)->&(cAliasCab+"_DIGITO")
		cCodRda 	:= (cAliasCab)->&(cAliasCab+"_CODRDA")
		dDatPro		:= (cAliasCab)->&(cAliasCab+"_DATPRO")
		cCodLoc		:= (cAliasCab)->&(cAliasCab+"_CODLOC")

		//posiciona no item da guia
		if cChaveBD6 <> BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

			cChaveBD6 := xFilial("BD6") + BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

			if ! BD6->( msSeek( cChaveBD6 ) )

				PlGrvlog(STR0018 + ' - [ ' + cChaveBD6 + ' ]', __cLPINFO , 1, .t., funName())//'Erro de integridade entre BD6 e BD7'
				disarmTransaction()

				return(.f.)

			endIf

			//Posiciona nas tabelas auxliares
			fPosTabCab(lReembolso)

		endIf

		//distribui valor apresentado do bd6 na bd7
		if BD6->BD6_VLRAPR > 0 .and. BD7->BD7_VLRAPR == 0 .and. empty(BD7->BD7_SEQIMP)
			
			PlGrvlog('Inconsistencia entre valor apresentado na BD6 e BD7 - [ ' + cChaveCAB + ' ]', __cLPINFO , 1, .t., funName())

		endIf

		//para garantir que a area aberta sera o BD7
		if alias() <> 'BD7'
			dbSelectArea('BD7')
		endIf

		if ! lCabecalho
			PLSCTBCABEC(@nHdlPrv, @cArquivo, .f., @lCabecalho, CTBPLSROT, cLote)
		endIf

		//data do lote
		if BD7->( Recno()) <>  (cTabMult)->BD7Recno
			BD7->( msGoTo( (cTabMult)->BD7Recno ) )
		endif

		if __nParTipCtb == LP_P9CN
			dDtLote := BD7->BD7_DTDIGI
		else	
			dDtLote := BD7->BD7_DTCTBF
		endIf

		nValAux := detProva( nHdlPrv, __cLPINFO, CTBPLSROT, cLote,,,,,, aCT5,,, PLSRACTL(__cLPINFO) )
		nTotLanc += nValAux

		if empty(cArquivo)
			cArquivo := getHFile()
		endIf

		if round(nTotLanc, nTamDec) > 0
			lRet := .t.
		endIf

		PLSMONFLAG( @aFlagPLS, LP_FDESP, __cLPINFO, (nValAux > 0) )

		(cTabMult)->(dbSkip())
		
 		if (cTabMult)->(eof()) .or. &(cCondic) != cChaveBD7
			
			//mudou a chave finaliza os lancamentos
			if lCabecalho .and. lRet

				lanceiCTB := ( len(aFlagPLS) > 0 )
				PLSCA100(@cArquivo, @nHdlPrv, cLote, @nTotLanc, @lCabecalho, @aFlagPLS, dDtLote, lMostraLC, __lParChkALC, __cLPINFO, LP_FDESP, cThReadID, CTBPLSROT, nil)

			endIf

		endIf

	endDo
	
endIf

//lote de aviso - LP 9LA/9LB
if __nParTipCtb == LP_P9LA .or. __nParTipCtb == LP_P9LB

	while ! (cTabMult)->(eof())

		B6T->( msGoTo( (cTabMult)->B6TRecno ) )
		B5T->( msGoTo( (cTabMult)->B5TRecno ) )
		B2T->( msGoTo( (cTabMult)->B2TRecno ) )
		
		if __nParTipCtb == LP_P9LA
			
			if ! empty(B6T->B6T_LAPRO)
				(cTabMult)->(dbSkip())
				loop
			endIf

		else

			if ! empty(B6T->B6T_LA)
				(cTabMult)->(dbSkip())
				loop
			endIf

			BD7->( msGoTo( (cTabMult)->BD7Recno ) )

		endIf

		//quebra o movimento por sequencia e lote
		//esta chave nao tem relacao com a chave da query principal nem com a quebra da thread
		cChaveB6T := (cTabMult)->(B6T_FILIAL + B6T_SEQLOT + B6T_NMGPRE)
		cCondic   := cTabMult + "->(B6T_FILIAL + B6T_SEQLOT + B6T_NMGPRE)"

		lRet := .f.
		
		if ! lAutoStt .and. cIncPro <> B2T->B2T_CODRDA + B6T->B6T_NMGPRE
		
			cIncPro := B2T->B2T_CODRDA + B6T->B6T_NMGPRE
			incProc( __cLPINFO + '-' + STR0016 + B2T->B2T_CODRDA + STR0017 + Transform( allTrim(B6T->B6T_NMGPRE), '@R XXXX.XXXX.XX.XXXXXXXX') + "]" ) //"Rda [" ## "] Guia ["

		endIf

		// Posiciona no cabacalho da guia
		// Chave correta B5T_FILIAL+B5T_OPEHAB+B5T_TIPGUI+B5T_SEQLOT+B5T_NMGPRE
		if cChaveCAB <> B6T->(B6T_FILIAL + B6T_OPEHAB) + B5T->B5T_TIPGUI + B6T->(B6T_SEQLOT + B6T_NMGPRE)
	
			cChaveCAB := B6T->(B6T_FILIAL + B6T_OPEHAB) + B5T->B5T_TIPGUI + B6T->(B6T_SEQLOT + B6T_NMGPRE)

			//Posiciona nas tabelas auxliares
			fPosTabCab(lReembolso)

		endIf

		//para garantir que será salvo o alias no CTBXCTB(RETRECNOLP)
		if alias() <> 'B6T'
			dbSelectArea('B6T')
		endIf

		if ! lCabecalho
			PLSCTBCABEC(@nHdlPrv, @cArquivo, .f., @lCabecalho, CTBPLSROT, cLote)
		endIf

		//data do lote
		if __nParTipCtb == LP_P9LA
			dDtLote := B2T->B2T_DATTRA
		else	
			dDtLote := BD7->BD7_DTDIGI
		endIf

		nValAux := detProva( nHdlPrv, __cLPINFO, CTBPLSROT, cLote,,,,,, aCT5,,, PLSRACTL(__cLPINFO) )
		nTotLanc += nValAux

		if empty(cArquivo)
			cArquivo := getHFile()
		endIf

		if round(nTotLanc, nTamDec) > 0
			lRet := .t.
		endIf

		PLSMONFLAG( @aFlagPLS, LP_FLTAV, __cLPINFO, (nValAux > 0) )

		(cTabMult)->(dbSkip())
		
		if (cTabMult)->(eof()) .or. &(cCondic) != cChaveB6T

			if lCabecalho .and. lRet

				lanceiCTB := ( len(aFlagPLS) > 0 )
				PLSCA100(@cArquivo, @nHdlPrv, cLote, @nTotLanc, @lCabecalho, @aFlagPLS, dDtLote, lMostraLC, __lParChkALC, __cLPINFO, LP_FLTAV, cThReadID, CTBPLSROT, nil)
			
			endIf

		endIf

	endDo
	
endIf

return(lRet)

/*/{Protheus.doc} PLPRODADTIT
Despesas TITULOS SE2 e FK2
@author  PLS TEAM
@version P12
@since   21.03.17
/*/
static function PLPRODADTIT(cTabMult, nTotReg, cThReadID)
local nHdlPrv 		:= 0
local nTotLanc		:= 0
local nValAux		:= 0
local nChaveTIT 	:= 0
local nI			:= 0
local cArquivo 		:= ""
local cCondic		:= ""
local cChaveBD6		:= ""
local cAliasRec		:= ""
local cAliasCAB		:= ""
local cChaveCAB 	:= ""
local cChvMAT		:= ""
local cIncPro		:= ""
local cLote			:= ""
local nTamFIL		:= SE2->(tamSX3("E2_FILIAL")[1]) + 1
local nTamBGQ		:= BGQ->(tamSX3("BGQ_PREFIX")[1] + tamSX3("BGQ_NUMTIT")[1] + tamSX3("BGQ_PARCEL")[1] + tamSX3("BGQ_TIPTIT")[1])
local aFlagCTB		:= {}
local aRegBLR 		:= {}
local aCT5			:= {}
local lCabecalho	:= .f.
local lMostraLC 	:= .f.
local lRet			:= .f.
local lReembolso	:= .f.
local lPlsAtiv		:= getNewPar("MV_PLATCT", .f.)
local dDtLote		:= ctod('')
local nTamDec		:= PLGetDec('E2_VALOR')
Local aareaBAU		:= BAU->(getArea())
Local cRDACheck		:= ""

private __PLSModLOT 	:= "PLSDES"
private lanceiCTB 		:= .f.
private lMsErroAuto 	:= .f.
private lMsHelpAuto		:= .t.
private lAutoErrNofile	:= .t.

default cThReadID 	:= allTrim(str(thReadID()))

cLote := loteCont(__PLSModLOT)
BA1->(dbSetOrder(2))  //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
BA3->(dbSetOrder(1))  //BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
BAG->(dbSetOrder(1))  //BAG_FILIAL+BAG_CODIGO
if FWAliasInDic("B5F")
	B5F->(dbSetOrder(3)) //B5F_FILIAL+B5F_CODINT+B5F_CODEMP+B5F_MATRIC+B5F_TIPREG+B5F_DIGITO     
endIf	
BAU->(dbSetOrder(1))  //BAU_FILIAL+BAU_CODIGO
BCI->(dbSetOrder(1))  //BCI_FILIAL+BCI_CODOPE+BCI_CODLDP+BCI_CODPEG+BCI_FASE+BCI_SITUAC
BE4->(dbSetOrder(1))  //BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_SITUAC+BE4_FASE
BD5->(dbSetOrder(1))  //BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_SITUAC+BD5_FASE+dtos(BD5_DATPRO)+BD5_OPERDA+BD5_CODRDA
BD6->(dbSetOrder(1))  //BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
BG9->(dbSetOrder(1))  //BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO
BI3->(dbSetOrder(5))  //BI3_FILIAL+BI3_CODINT+BI3_CODIGO
BQC->(dbSetOrder(1))  //BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB
BT5->(dbSetOrder(1))  //BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO
BT6->(dbSetOrder(1))  //BT6_FILIAL+BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO
B44->(dbSetOrder(1))  //B44_FILIAL+B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT
BOW->(dbSetOrder(1))  //BOW_FILIAL+BOW_PROTOC
SED->(dbSetOrder(1))  //ED_FILIAL+ED_CODIGO
SA6->(dbSetOrder(1))  //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
BMS->(dbSetOrder(1))  //BMS_FILIAL+BMS_OPERDA+BMS_CODRDA+BMS_OPELOT+BMS_ANOLOT+BMS_MESLOT+BMS_NUMLOT+BMS_CODLAN+BMS_CODPLA+BMS_CC 
BLR->(dbSetOrder(1))  //BLR_FILIAL+BLR_CODINT+BLR_PROPRI+BLR_CODLAN 
BBB->(dbSetOrder(1))  //BBB_FILIAL+BBB_CODSER
SE2->(dbSetOrder(1))  //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
BD7->(dbSetOrder(18)) //BD7_FILIAL+BD7_CHKSE2+DTOS(BD7_DTDIGI)+BD7_SITUAC+BD7_BLOPAG
BGQ->(dbSetOrder(7))  //BGQ_FILIAL+BGQ_PREFIX+BGQ_NUMTIT+BGQ_PARCEL+BGQ_TIPTIT
SE5->(dbSetOrder(7))  //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ

//carrega lancamento de pagamento
if lPlsAtiv

	BLR->(dbGoTop())

	do while ! BLR->(eof())

		aadd( aRegBLR, { BLR->BLR_FILIAL, BLR->BLR_CODINT, BLR->BLR_PROPRI, BLR->BLR_CODLAN, BLR->BLR_CONTAB } )

		BLR->(dbSkip())
	endDo

endIf

while ! (cTabMult)->(eof())
	
	SE2->( msGoTo( (cTabMult)->SE2Recno ) )

	//retorna titulo vinculado a tabela do PLS com liquidacao/reliquidacao ou nao.
	aMatTIT := PLSTITMOV('SE2')

	if len(aMatTIT) == 0
		(cTabMult)->(dbSkip())
		loop
	endIf

	cAliasRec := ''

	//LP - 9AG
	if __nParTipCtb == LP_P9AG
		
		if aScan(aFlagCTB,{ |x| x[4] == (cTabMult)->(SE2Recno) } ) == 0
			aAdd(aFlagCTB,{"E2_LA", "S", "SE2", (cTabMult)->(SE2Recno), 0, 0, 1})
		endIf

	//Baixa ou cancelamento da baixa - LP 9BD/9BL
	elseIf __nParTipCtb == LP_P9BD9BL .or. __nParTipCtb == LP_P9NB9NC
		
		FK2->( msGoTo( (cTabMult)->FK2Recno ) )

		//movimenta banco
		if __nParTipCtb == LP_P9BD9BL
			
			__cLPINFO := LP_BAIXA

			//cancelamento da baixa
			if FK2->FK2_TPDOC == 'ES'
				__cLPINFO := LP_CANCELA_BAIXA
			endIf
		
		//nao movimenta banco
		else
			
			__cLPINFO := LP_BAIXA_NB

			if FK2->FK2_TPDOC == 'ES'
				__cLPINFO := LP_CANCELA_BAIXA_NB
			endIf

		endIf

		if aScan(aFlagCTB,{ |x| x[4] == (cTabMult)->(FK2Recno) } ) == 0
			aAdd(aFlagCTB,{"FK2_LA", "S", "FK2", (cTabMult)->(FK2Recno), 0, 0, 1})
		endIf

	endIf

	//limpa variavies publicas
	ratGLBPub('SE2')

	//quebra o movimento por titulo e sequencia
	//esta chave nao tem relacao com a chave da query principal nem com a quebra da thread
	if __nParTipCtb == LP_P9AG

		nChaveTIT := (cTabMult)->SE2Recno
		cCondic   := cTabMult + "->SE2Recno"

	elseIf __nParTipCtb == LP_P9BD9BL .or. __nParTipCtb == LP_P9NB9NC

		nChaveTIT := (cTabMult)->FK2Recno
		cCondic   := cTabMult + "->FK2Recno"

	endIf

	if __nParTipCtb == LP_P9AG
		dDtLote := SE2->E2_EMIS1
	else

		//data do lote
		if __lParDtDisp
			dDtLote := FK2->FK2_DTDISP
		else
			dDtLote := FK2->FK2_DATA
		endIf

	endIf

	lRet := .f.

	for nI := 1 to len(aMatTIT)
		
		cChvMAT := aMatTIT[nI]
		nRecBD7 := 0
		nRecBGQ	:= 0

		BGQ->(msGoTo(0))

		if BD7->( msSeek( xFilial('BD7') + cChvMAT ) ) 

			//roda todos BD7 do titulo PLS
			while ! BD7->(eof()) .and. xFilial('BD7') + cChvMAT == BD7->(BD7_FILIAL + BD7_CHKSE2)

				if ! lAutoStt .and. cIncPro <> BD7->( BD7_CODRDA + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO )

					cIncPro := BD7->( BD7_CODRDA + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO )
					incProc( __cLPINFO + '-' + STR0016 + BD7->BD7_CODRDA + STR0017 + BD7->BD7_CODOPE + "." + BD7->BD7_CODLDP + "." + BD7->BD7_CODPEG + "." + BD7->BD7_NUMERO + "]" ) //"Rda [" ## "] Guia ["

				endIf

				//posiciona no cabacalho da guia
				if cChaveCAB <> BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)

					cAliasCAB := PLSRALCTM(BD7->BD7_TIPGUI)
					cChaveCAB := BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)

					(cAliasCAB)->( msSeek( cChaveCAB ) )
					BCI->( msSeek( xFilial("BCI") + BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG)))

					//guia de reembolso
					lReembolso := BD7->BD7_TIPGUI == REEMBOLSO
					if lReembolso
						B44->( msSeek( xFilial("B44") + (cAliasCAB)->(BD5_OPEMOV+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT) ) )
						BOW->( msSeek( xFilial("BOW") + B44->B44_PROTOC ) )
					endIf

				endIf
				//posiciona no item da guia
				if cChaveBD6 <> BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

					cChaveBD6 := xFilial("BD6") + BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

					if ! BD6->( msSeek( cChaveBD6 ) )

						PlGrvlog(STR0018 + ' - [ ' + cChaveBD6 + ' ]', __cLPINFO , 1, .t., funName())//'Erro de integridade entre BD6 e BD7'
						disarmTransaction()

						return(.f.)

					endIf

					//posicionamento de tabelas auxiliares
					fPosTabCab(lReembolso)

				endIf

				if lPlsAtiv

					if ( aScan( aRegBLR, { |x| x[1] + x[2] + x[3] + x[4] == xFilial("BLR") + BMS->( BMS_OPERDA + BMS_CODLAN ) .and. x[5] == '1' } ) ) == 0

						PlGrvlog(STR0093 + BMS->(BMS_OPERDA + BMS_CODLAN), __cLPINFO , 1, .t., funName())//'BLR Desativado'

						(cTabMult)->(dbSkip())
						loop
					endIf

				endIf

				if ! lCabecalho
					PLSCTBCABEC(@nHdlPrv, @cArquivo, .f., @lCabecalho, CTBPLSROT, cLote)
				endIf

				//inclusao ou inclusao sem rateio
				if __nParTipCtb == LP_P9AG

					if alias() <> 'SE2'
						dbSelectArea('SE2')
					endIf

				//baixa cancelamento da baixa
				elseIf  __nParTipCtb == LP_P9BD9BL .or. __nParTipCtb == LP_P9NB9NC

					if alias() <> 'FK2'
						dbSelectArea('FK2')
					endIf

				endIf

				nValAux  := detProva( nHdlPrv, __cLPINFO, CTBPLSROT, cLote,,,,,, aCT5,,, PLSRACTL(__cLPINFO) )
				nTotLanc += nValAux

				if empty(cArquivo)
					cArquivo := getHFile()
				endIf

				if round(nTotLanc, nTamDec) > 0
					lRet := .t.
				endIf
				
				nRecBD7 := BD7->(recno())

			BD7->(dbSkip())
			endDo

		endIf

		cChvMAT := subStr(strTran(cChvMAT,'|', ''), nTamFil, nTamBGQ)
		
		BD7->(msGoTo(0))

		if BGQ->( msSeek( xFilial('BGQ') + cChvMAT ) )  
			
			cRDACheck := ""//cRDACheck := BGQ->BGQ_CODIGO//BAU->BAU_CODIGO

			FI8->(dbsetOrder(1))
			If !FI8->(MsSeek(xfilial("FI8")+cChvmat)) //confere se não é aglutinado primeiro
				aAreaBAU := BAU->(getArea())
				BAU->(dbsetOrder(1))
				if BAU->(MsSeek(xfilial("BAU")+BGQ->BGQ_CODIGO)) //SE2->E2_FORNECE))
					cRDACheck := AllTrim(BAU->BAU_CODSA2)//BAU->BAU_CODIGO
				endIf
				RestArea(aAreaBAU)
			endIf
			
			//roda todos BD7 do titulo PLS
			while ! BGQ->(eof()) .and. xFilial('BGQ') + cChvMAT == BGQ->(BGQ_FILIAL+BGQ_PREFIX+BGQ_NUMTIT+BGQ_PARCEL+BGQ_TIPTIT)
				If BGQ->BGQ_TIPO == "3"
					BGQ->(dbskip())
					loop
				endIf
				If !(empty(cRDACheck))
					If alltrim(SE2->E2_FORNECE) <> cRDACheck//cRDACheck <> BGQ->BGQ_CODIGO
						BGQ->(dbskip())
						loop
					endIf
				endIf
				if ! lAutoStt .and. cIncPro <> BGQ->( BGQ_CODIGO + BGQ_OPELOT + BGQ_NUMLOT )

					cIncPro := BGQ->( BGQ_CODIGO + BGQ_OPELOT + BGQ_NUMLOT )
					incProc( __cLPINFO + '-' + STR0016 + BGQ->BGQ_CODIGO + STR0094 + transform(allTrim( BGQ->( BGQ_OPELOT + BGQ_NUMLOT ) ), '@R XXXX.XXXX.XX.XXXX') + "]" ) //Rda [" ## "] Lote ["

				endIf

				//posicionamento de tabelas auxiliares
				fPosTabCab(lReembolso)

				if ! lCabecalho
					PLSCTBCABEC(@nHdlPrv, @cArquivo, .f., @lCabecalho, CTBPLSROT, cLote)
				endIf
				
				//inclusao ou inclusao sem rateio
				if __nParTipCtb == LP_P9AG

					if alias() <> 'SE2'
						dbSelectArea('SE2')
					endIf

				//baixa cancelamento da baixa
				elseIf  __nParTipCtb == LP_P9BD9BL .or. __nParTipCtb == LP_P9NB9NC

					if alias() <> 'FK2'
						dbSelectArea('FK2')
					endIf

				endIf

				nValAux  := detProva( nHdlPrv, __cLPINFO, CTBPLSROT, cLote,,,,,, aCT5,,, PLSRACTL(__cLPINFO) )
				nTotLanc += nValAux

				if empty(cArquivo)
					cArquivo := getHFile()
				endIf

				if round(nTotLanc, nTamDec) > 0
					lRet := .t.
				endIf
				
				nRecBGQ := BGQ->(recno())

			BGQ->(dbSkip())
			endDo

		endIf

	next	

	(cTabMult)->(dbSkip())

	if (cTabMult)->(eof()) .or. &(cCondic) != nChaveTIT
		
		//mudou a chave finaliza os lancamentos
		if lCabecalho .and. lRet
		
			BD7->(msGoTo(nRecBD7))
			BGQ->(msGoTo(nRecBGQ))

			lanceiCTB := ( len(aFlagCTB) > 0 )
			PLSCA100(@cArquivo, @nHdlPrv, cLote, @nTotLanc, @lCabecalho, {}, dDtLote, lMostraLC, __lParChkALC, __cLPINFO, 0, cThReadID, CTBPLSROT, @aFlagCTB)
		endIf
	endIf

endDo

return(lRet)

/*/{Protheus.doc} JOBRPCTB06
JOB
@author  PLS TEAM
@version P12
@since   15.11.05
/*/
function JOBRPCTB06(aCallPar)
local nPos		 := 0
local nPosUnion	 := 0
local nTotReg	 := 0
local nSeconds 	 := seconds()
local cOrderBy	 := ""
local cTabMult	 := ""
local cCompWhere := ""
local cSqlMThread:= ""
local aProcs	 := aClone(aCallPar[1])
local aMatStat	 := aClone(aCallPar[2])

local cChave	 := aProcs[VAR_CHAVE]
local nCount	 := aProcs[VAR_COUNT]
local cReg		 := aProcs[VAR_REG]

local nThRead	 := thReadID()
local cThReadID  := allTrim(str(nThRead))
local lRet		 := .f.

__cParCodInt 	:= aMatStat[1]
__cParMes		:= aMatStat[2]
__cParAno		:= aMatStat[3]
__cParRdaDe		:= aMatStat[4]
__cParRdaAte	:= aMatStat[5]
__cParClaRda	:= aMatStat[6]
__nParTipCtb	:= aMatStat[7]
__lParChkALC	:= aMatStat[8]
__lParChkFC		:= aMatStat[9]
__nParChkMTGR	:= aMatStat[10]
__lLoteAviso 	:= aMatStat[11]
__lParDtDisp	:= aMatStat[12]
__cLPINFO		:= aMatStat[13]
cSqlMThread		:= aMatStat[14]
__dParDtIni		:= aMatStat[15]
__dParDtFim		:= aMatStat[16]

FWLogMsg('INFO',, 'SIGAPLS', funName(), '', '01', 'Inicio - thID [' + cThReadID + '] - ' + dtos(date()) + ' - ' + time() + STR0047 + __cLPINFO + ' - [ ' + strZero(nCount,10) + ' ] - ' + cReg + allTrim(cChave) , 0, 0, {})//"Registro: '

//monta a query quebrando por peg
nPosUnion 	:= at('union all', lower(cSqlMThread))
nPos 	 	:= at('order by', lower(cSqlMThread))
cOrderBy 	:= right(cSqlMThread, len(cSqlMThread) - (nPos-1))

//quebra por peg e protocolo - chave vem da funcao PROMThread
if __nParTipCtb == LP_P9CN .or. __nParTipCtb == LP_P9CT

	cCompWhere  := " AND (BD7_FILIAL = '" + xFilial("BD7") + "' "
	if __nParTipCtb == LP_P9CN
		cCompWhere  += " AND  " + plFiePar("BD7_CODOPE|BD7_CODLDP|BD7_CODPEG|BD7_PROTOC|BD7_DTDIGI", cChave, .f., nil, .t.) + ") "
	else
		cCompWhere  += " AND  " + plFiePar("BD7_CODOPE|BD7_CODLDP|BD7_CODPEG|BD7_PROTOC|BD7_DTCTBF", cChave, .f., nil, .t.) + ") "
	endif

	cSqlMThread	:= left(cSqlMThread, nPos - 1) + cCompWhere + cOrderBy

	if nPosUnion > 0
		cBeForUnion := left(cSqlMThread, nPosUnion - 1) + cCompWhere
		cSqlMThread	:= cBeForUnion + right(cSqlMThread, len(cSqlMThread) - (nPosUnion-1))
	endIf

//provisao/cobranca lote aviso - chave vem da funcao PROMThread
elseIf __nParTipCtb == LP_P9LA .or. __nParTipCtb == LP_P9LB

	cCompWhere  := " AND (B6T_FILIAL = '" + xFilial("B6T") + "' "
	cCompWhere  += " AND  " + plFiePar("B6T_SEQLOT|B6T_NMGPRE", cChave, .f., nil, .t.) + ") "

	cSqlMThread	:= left(cSqlMThread, nPos - 1) + cCompWhere + cOrderBy

	if nPosUnion > 0
		cBeForUnion := left(cSqlMThread, nPosUnion - 1) + cCompWhere
		cSqlMThread	:= cBeForUnion + right(cSqlMThread, len(cSqlMThread) - (nPosUnion-1))
	endIf

//quebra por titulo - chave vem da funcao PROMThread
elseIf __nParTipCtb == LP_P9AG

	cCompWhere  := " AND SE2.R_E_C_N_O_ = '" + cChave + "' "
	cSqlMThread	:= left(cSqlMThread, nPos - 1) + cCompWhere + cOrderBy

	if nPosUnion > 0
		cBeForUnion := left(cSqlMThread, nPosUnion - 1) + cCompWhere
		cSqlMThread	:= cBeForUnion + right(cSqlMThread, len(cSqlMThread) - (nPosUnion-1))
	endIf

//quebra por titulo e sequencia - chave vem da funcao PROMThread
elseIf __nParTipCtb == LP_P9BD9BL .or. __nParTipCtb == LP_P9NB9NC

	cCompWhere  := " AND FK2.R_E_C_N_O_ = '" + cChave + "' "
	cSqlMThread	:= left(cSqlMThread, nPos - 1) + cCompWhere + cOrderBy

	if nPosUnion > 0
		cBeForUnion := left(cSqlMThread, nPosUnion - 1) + cCompWhere
		cSqlMThread	:= cBeForUnion + right(cSqlMThread, len(cSqlMThread) - (nPosUnion-1))
	endIf

endIf

cTabMult := PLRETDAD(cSqlMThread)

if (cTabMult)->(eof())
	FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', 'thID [' + cThReadID + '] - Erro sub-query nao retornou resultado [' + cChave + '] ' , 0, 0, {})
endIf
//Realiza o processamento
if __nParTipCtb == LP_P9CN .or. __nParTipCtb == LP_P9CT .or. __nParTipCtb == LP_P9LA .or. __nParTipCtb == LP_P9LB
	lRet := PLPRODADGUI(cTabMult, nTotReg, cThReadID)
else
	lRet := PLPRODADTIT(cTabMult, nTotReg, cThReadID)
endIf

if select(cTabMult) > 0
	(cTabMult)->(dbCloseArea())
endIf

FWLogMsg('INFO',, 'SIGAPLS', funName(), '', '01', 'Fim - thID [' + cThReadID + '] - ' + dtos(date()) + ' - ' + time() + STR0047 + __cLPINFO + ' - [ ' + strZero(nCount,10) + ' ] - ' + cReg + allTrim(cChave) + " | Tempo Gasto: " + allTrim(str(seconds() - nSeconds)) + '|' + iIf(lRet, 'Processado', 'Não Processado'), 0, 0, {})//'Registro: '

return(lRet)

/*/{Protheus.doc} fPosTabCab

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
static function fPosTabCab(lReembolso)
local aArea   := getArea()
local cCodPla := ""

if __nParTipCtb == LP_P9LB .or. __nParTipCtb == LP_P9LA

	if ! B2T->(eof()) .and. ! empty(B2T->B2T_CODRDA) .and. BAU->(BAU_FILIAL+BAU_CODIGO) <> xFilial("BAU") + B2T->B2T_CODRDA
		BAU->( msSeek( xFilial("BAU") + B2T->B2T_CODRDA ) )
	endIf
	
endIf

if ! BGQ->(eof()) .and. ! empty(BGQ->BGQ_CODIGO) .and. BAU->(BAU_FILIAL+BAU_CODIGO) <> xFilial("BAU") + BGQ->BGQ_CODIGO
	BAU->( msSeek( xFilial("BAU") + BGQ->BGQ_CODIGO ) )
endIf

if ! BD7->(eof()) .and. ! empty(BD7->BD7_CODRDA) .and. BAU->(BAU_FILIAL+BAU_CODIGO) <> xFilial("BAU") + BD7->BD7_CODRDA
	BAU->( msSeek( xFilial("BAU") + BD7->BD7_CODRDA ) )
endIf

//provisao/cobranca lote aviso
if __nParTipCtb == LP_P9LA .or. __nParTipCtb == LP_P9LB

	//Posiciona BA1 - Usuarios
	if BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) <> xFilial("BA1") + B6T->B6T_MATRIC
		BA1->( msSeek( xFilial("BA1") + B6T->B6T_MATRIC ) )
		PLSVLDB5F(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), , .t.)
	endIf

	cCodPla := BA1->BA1_CODPLA

else

	//Posiciona BA1 - Usuarios
	if BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) <> xFilial("BA1") + BD6->( BD6_OPEUSR + BD6_CODEMP + BD6_MATRIC + BD6_TIPREG + BD6_DIGITO )
		BA1->( msSeek( xFilial("BA1") + BD6->( BD6_OPEUSR + BD6_CODEMP + BD6_MATRIC + BD6_TIPREG + BD6_DIGITO ) ) )
		PLSVLDB5F(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), , .t.)
	endIf

	cCodPla := BD6->BD6_CODPLA

endIf

//Posiciona BAG-Cadastro Classes da RDA
if BAG->(BAG_FILIAL+BAG_CODIGO) <> xFilial("BAG") + BAU->BAU_TIPPRE
	BAG->(msSeek(xFilial("BAG") + BAU->BAU_TIPPRE))
endIf

//Posiciona SA2-Cadastro de Fornecedores
if ! lReembolso

	if SA2->(A2_FILIAL+A2_COD+A2_LOJA) <> xFilial("SA2") + BAU->(BAU_CODSA2+BAU_LOJSA2)
		SA2->( dbSetOrder(1) ) //A2_FILIAL+A2_COD+A2_LOJA
		SA2->( msSeek( xFilial("SA2") + BAU->(BAU_CODSA2+BAU_LOJSA2) ) )
	endIf

else

	if SA2->(A2_FILIAL+A2_CGC) <> xFilial("SA2") + BA1->BA1_CPFUSR
		SA2->( dbSetOrder(3) ) //A2_FILIAL+A2_CGC
		SA2->( msSeek( xFilial("SA2") + BA1->BA1_CPFUSR ))
	endIf

endIf

	
//Posiciona BA3 - Familias
if BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB) <> xFilial("BA3") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)

	if BA3->( msSeek( xFilial("BA3") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
		
		if empty(cCodPla) .and. ( __nParTipCtb == LP_P9LA .or. __nParTipCtb == LP_P9LB )
			cCodPla := BA3->BA3_CODPLA
		endIf
		
		//Posiciona BG9 - Grupo/Empresa
		if BG9->(BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO) <> xFilial("BG9") + BA3->(BA3_CODINT+BA3_CODEMP+BA3_TIPOUS)
			BG9->(msSeek(xFilial("BG9") + BA3->(BA3_CODINT+BA3_CODEMP+BA3_TIPOUS)))
		endIf

		//Posiciona BT5 - Contrato
		if BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO) <> xFilial("BT5") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)
			BT5->(msSeek(xFilial("BT5") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)))
		endIf

		//Posiciona BQC - Sub-Contrato
		//BQC_CODIGO eh composto por COD OPER + COD EMPR
		if BQC->(BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) <> xFilial("BQC") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)
			BQC->(msSeek(xFilial("BQC") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
		endIf

	endIf

endIf

// Posiciona BI3-Produto Saude
if BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO) <> xFilial("BI3") + BA1->BA1_CODINT + cCodPla
	BI3->( msSeek( xFilial("BI3") + BA1->BA1_CODINT +  cCodPla) )
endIf

// Posiciona BT6-Contrato x Produto
if BA3->BA3_TIPOUS == "2" // Contrato Pessoa Juridica
	
	if BT6->(BT6_FILIAL+BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB+BT6_CODPRO) <> xFilial("BT6")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB) + cCodPla
		BT6->(msSeek(xFilial("BT6")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB) + cCodPla))
	endIf

endIf

//natureza
if xFilial("SED") + SE2->E2_NATUREZ <> SED->( ED_FILIAL + ED_CODIGO )
	SED->( msSeek( xFilial("SED") + SE2->E2_NATUREZ ) )
endIf

//baixa e cancelamento da baixa
if __nParTipCtb == LP_P9BD9BL .or. __nParTipCtb == LP_P9NB9NC

	if xFilial("SED") + FK2->FK2_NATURE <> SED->( ED_FILIAL + ED_CODIGO )
		SED->( msSeek( xFilial("SED") + FK2->FK2_NATURE) )
	endIf

	if SE5->( E5_FILIAL + E5_BANCO + E5_AGENCIA + E5_CONTA ) <> xFilial('SA6') + SA6->( A6_COD + A6_AGENCIA + A6_NUMCON )
		
		if SE5->( msSeek( xFilial('SE5') + SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA) ) )

			while ! SE5->(eof()) .and. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == xFilial('SE5') + SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA)

				if ! empty( allTrim( SE5->( E5_BANCO + E5_AGENCIA + E5_CONTA ) ) )
					
					SA6->( msSeek( xFilial("SA6") + SE5->( E5_BANCO + E5_AGENCIA + E5_CONTA ) ) )
					SEF->( msSeek( xFilial("SEF") + SA6->( A6_COD + A6_AGENCIA + A6_NUMCON ) ) )

					exit

				endIf

			SE5->(dbSkip())	
			endDo

		endIf

	endIf

endIf

//considerando deb/cred
if ! BGQ->(eof())

	BBB->( msSeek( xFilial("BBB") + BGQ->BGQ_CODLAN ) )

	if xFilial("BMS") + BMS->( BMS_OPERDA + BMS_CODRDA + BMS_OPELOT + BMS_ANOLOT + BMS_MESLOT + BMS_NUMLOT ) <> BGQ->( BGQ_FILIAL + BGQ_CODOPE + BGQ_CODIGO + BGQ_OPELOT + BGQ_NUMLOT )
		
		if BMS->( msSeek( xFilial("BMS") + BGQ->( BGQ_CODOPE + BGQ_CODIGO + BGQ_OPELOT + BGQ_NUMLOT ) ) )
		
			BLR->( msSeek( xFilial("BLR") + BMS->( BMS_OPERDA + BMS_CODLAN ) ) )

		endIf 

	endIf

endIf

if existBlock("PLSCTBP2")
	execBlock("PLSCTBP2",.F.,.F.)
endIf

restarea(aArea)

return

/*/{Protheus.doc} retDLP
Retorna descricao da LP
@author TOTVS
@since 22/02/2019
/*/
static function retDLP()
local cDesc := ''

do case

	case __nParTipCtb == LP_P9CN

		cDesc := LP_PROVISAO

	case __nParTipCtb == LP_P9CT

		cDesc := LP_CUSTO

	case __nParTipCtb == LP_P9AG

		cDesc := LP_INCLUSAO

	case __nParTipCtb == LP_P9BD9BL

		cDesc := LP_BAIXA+LP_CANCELA_BAIXA

	case __nParTipCtb == LP_P9NB9NC

		cDesc := LP_BAIXA_NB+LP_CANCELA_BAIXA_NB

	case __nParTipCtb == LP_P9LA

		cDesc := LP_PROVISAO_LA

	case __nParTipCtb == LP_P9LB

		cDesc := LP_CUSTO_LA

endCase

return cDesc

/*/{Protheus.doc} retMLP
Retorna msg da LP

@author TOTVS
@since 22/02/2019
/*/
static function retMLP(aPadrao, lRet)
local cMsg := ''

if __nParTipCtb == LP_P9CN

	cMsg := aPadrao[1,1]
	lRet := aPadrao[1,2]

elseIf __nParTipCtb == LP_P9CT

	cMsg := aPadrao[2,1]
	lRet := aPadrao[2,2]

elseIf __nParTipCtb == LP_P9AG

	cMsg := aPadrao[3,1]
	lRet := aPadrao[3,2]

elseIf __nParTipCtb == LP_P9BD9BL

	cMsg := aPadrao[4,1] + '/' + aPadrao[5,1]
	lRet := ( aPadrao[4,2] .and. aPadrao[5,2] )

elseIf __nParTipCtb == LP_P9LA

	cMsg := aPadrao[6,1]
	lRet := aPadrao[6,2]

elseIf __nParTipCtb == LP_P9NB9NC

	cMsg := aPadrao[7,1] + '/' + aPadrao[8,1]
	lRet := ( aPadrao[7,2] .and. aPadrao[8,2] )

elseIf __nParTipCtb == LP_P9LB

	cMsg := aPadrao[9,1]
	lRet := aPadrao[9,2]

endIf

return(cMsg)

/*/{Protheus.doc} plShoPer
Tela de pergunte

@author PLSTEAM
@since 25/02/2019
@version P11
/*/
static function plShoPer(lUnimed)
local nOpca     := 0
local bOK       := {|| iIf( vldConf(__cParCodInt, __cParMes, __cParAno, __dParDtIni, __dParDtFim), processa( {|lEnd| PLINFDAD() }, STR0006, STR0007 ), nOpca := 0 ) } //"Aguarde" ##"Gerando Contabilizacao Guias"
local bCancel   := {|| oDlg:end() }
local oDlg		:= nil
local oGroup1	:= nil
local oGroup2	:= nil
local oGroup3	:= nil
local oRadio1	:= nil
local oRadio2	:= nil
local oCheck1	:= nil
local oCheck2	:= nil
local lDtDisP	:= FK2->( fieldPos("FK2_DTDISP") ) > 0
local lPeriod	:= .f.
local lAnoMes	:= .t.

local ndLinIni	:= 180
local ndColIni 	:= 180
local ndLinFin	:= 550
local ndColFin	:= 842

local nLinS		:= 22
local nLinG		:= 22
local nColS		:= 01
local nColG		:= 01
local aItems 	:= {}
local aProDis	:= {}

__cParCodInt	:= plsIntPad()
__cParMes		:= iIf( len(aParamAUTO) > 0 , aParamAUTO[2], strZero(month(date()),2) )
__cParAno		:= iIf( len(aParamAUTO) > 0 , aParamAUTO[3], cValToChar(year(date())) )
__dParDtIni		:= ctod('')
__dParDtFim		:= ctod('')
__cParRdaDe		:= iIf( len(aParamAUTO) > 0 , aParamAUTO[4], space(6) )
__cParRdaAte	:= iIf( len(aParamAUTO) > 0 , aParamAUTO[5], space(6) )
__cParClaRda	:= space(60)
__nParTipCtb 	:= iIf( len(aParamAUTO) > 0 , aParamAUTO[7],  1 )
__lParChkALC	:= .f.
__nParChkMTGR	:= iIf( len(aParamAUTO) > 0 , aParamAUTO[10], 1 ) // no check-in da issue DSAUCONT-1068 o tamanho da array foi alterada..
__lLoteAviso	:= FWAliasInDic("B6T") .and. lUnimed

If lAutoStt
	PLINFDAD()
	return .t.
endIf

//nao deve alterar esta ordem sem alterar os DEFINES 
//LP_P9CN, LP_P9CT, LP_P9AG, LP_P9BD9BL, LP_P9NB9NC, LP_P9LA, LP_P9LB
aadd(aItems, LP_PROVISAO    + STR0065 ) //' - Provisão de Guias.'
aadd(aItems, LP_CUSTO       + STR0066)  //' - Custo de Guias.'
aadd(aItems, LP_INCLUSAO    + STR0067)  //' - Título gerados, pagamento médico.'

aadd(aItems, LP_BAIXA       + '/' + LP_CANCELA_BAIXA    + STR0068) //' - Baixa e Cancelamento. (Mov. Banco)'
aadd(aItems, LP_BAIXA_NB    + '/' + LP_CANCELA_BAIXA_NB + STR0069) //' - Baixa e Cancelamento. (Não Mov. Banco)'

if __lLoteAviso
	aadd(aItems, LP_PROVISAO_LA + STR0071) //' - Lote de Aviso.'
	aadd(aItems, LP_CUSTO_LA + STR0089)    //' - Lote de Aviso - Cobrado.'
endIf	

aadd(aItems, "Verificação de diferenças de rateio")

aadd(aProDis, STR0098)//'Normal.'
aadd(aProDis, STR0099)//'Multi Thread.'

//verifica se tem a configuracao de grid no ini
if upper( getPvProfString( "gridserver", "main", "NIL", getADV97() ) ) == 'GRIDSERVER'
	aadd(aProDis, STR0100)//'Grid.'
endIf	

//Definicao de tela
DEFINE MSDIALOG oDlg FROM ndLinIni,ndColIni TO ndLinFin,ndColFin PIXEL TITLE STR0001 //"Contabilização Off-line de Despesa"

	@ (nLinS += 10), (nColS += 00) SAY OEMTOANSI(STR0072) PIXEL of oDlg //'Operadora.'
	@ (nLinG += 17), (nColG += 00) MSGet __cParCodInt SIZE 30,10 OF oDlg PIXEL PICTURE "9999" F3 "B89PLS" 

	@ (nLinS += 00), (nColS += 40) SAY OEMTOANSI(STR0073) PIXEL of oDlg//'Mês.'
	@ (nLinG += 00), (nColG += 40) MSGet __cParMes SIZE 30,10 OF oDlg PIXEL PICTURE "99" VALID ( fVldDt(1, @lAnoMes, @lPeriod) ) WHEN lAnoMes

	@ (nLinS += 00), (nColS += 40) SAY OEMTOANSI(STR0074) PIXEL of oDlg//'Ano Competência.'
	@ (nLinG += 00), (nColG += 40) MSGet __cParAno SIZE 40,10 OF oDlg PIXEL PICTURE "9999" VALID ( fVldDt(1, @lAnoMes, @lPeriod) ) WHEN lAnoMes

	@ (nLinS += 00), (nColS += 50) SAY OEMTOANSI(STR0103) PIXEL of oDlg //'Data Inicio'
	@ (nLinG += 00), (nColG += 50) MSGet __dParDtIni SIZE 40,10 OF oDlg PIXEL PICTURE "99/99/9999" VALID ( fVldDt(2, @lAnoMes, @lPeriod) ) WHEN lPeriod

	@ (nLinS += 00), (nColS += 50) SAY OEMTOANSI(STR0104) PIXEL of oDlg //'Data Fim'
	@ (nLinG += 00), (nColG += 50) MSGet __dParDtFim SIZE 40,10 OF oDlg PIXEL PICTURE "99/99/9999" VALID ( fVldDt(2, @lAnoMes, @lPeriod) ) WHEN lPeriod
	
	@ (nLinS += 00), (nColS += 50) SAY OEMTOANSI(STR0075) PIXEL of oDlg//'Prestador De.'
	@ (nLinG += 00), (nColG += 50) MSGet __cParRdaDe SIZE 40,10 OF oDlg PIXEL PICTURE "!!!!!!"  F3 "BAUPLS" 

	@ (nLinS += 00), (nColS += 50) SAY OEMTOANSI(STR0076) PIXEL of oDlg //'Prestador Até.'
	@ (nLinG += 00), (nColG += 50) MSGet __cParRdaAte SIZE 40,10 OF oDlg PIXEL PICTURE "!!!!!!"  F3 "BAUPLS" 

	nColS := 01
	nColG := 01

	@ (nLinS += 22), (nColS += 00) SAY OEMTOANSI(STR0077) PIXEL of oDlg //'Classe do Prestador'
	@ (nLinG += 22), (nColG += 00) MSGet __cParClaRda SIZE 330,10 OF oDlg PIXEL F3 "BZ9PLS" 

	nColS := 01
	nColG := 01

	oGroup1	:= TGroup():new( (nLinS += 22), (nColS += 00), 130, 170, STR0078, oDlg,,,.T.) //'Opções'
   	oCheck1 := TCheckBox():new( (nLinG += 25), (nColG += 04), STR0079, { |u| iIf( PCount() == 0, __lParChkALC, __lParChkALC := u ) }, oGroup1, 150, 210,,,,,,,,.T.,,,) //'Aglutina Lançamento Contabíl?'
	if lDtDisP
		oCheck2 := TCheckBox():new( (nLinG += 10), (nColG += 00), STR0092, { |u| iIf( PCount() == 0, __lParDtDisp, __lParDtDisp := u ) }, oGroup1, 150, 210,,,,,,,,.T.,,,) //'Baixa - Pela data da Disponibilizade?'
	endIf

	oGroup2	:= TGroup():new( (nLinS += 00), (nColS += 175), 180, 330, STR0083, oDlg,,,.T.)//'Contabilizar?'
  	oRadio1 := TRadMenu():new( (nLinS += 07), (nColS += 04), aItems,,oGroup2,,,,,,,,160,12,,,,.t.)
  	oRadio1:bSetGet := { |u| iIf( PCount() == 0, __nParTipCtb, __nParTipCtb := u ) }
	oRadio1:bChange := {|| fVldBX(@__lParDtDisp, __nParTipCtb, oCheck2) }
	
	nColS := 01
	nColG := 01

	oGroup3	:= TGroup():new( (nLinS += 50), (nColS += 00), 180, 170, STR0097, oDlg,,,.T.)//'Processamento'
  	oRadio2 := TRadMenu():new( (nLinS += 07), (nColS += 04), aProDis,,oGroup3,,,,,,,,160,12,,,,.t.)
  	oRadio2:bSetGet := { |u| iIf( PCount() == 0, __nParChkMTGR, __nParChkMTGR := u ) }

ACTIVATE MSDIALOG oDlg CENTERED ON INIT enChoiceBar(oDlg, bOK, bCancel, .f., {} )

return

/*/{Protheus.doc} fVldBX
Valida Baixa

@author PLSTEAM
@since 25/02/2019
@version P11
/*/
static function fVldBX(__lParDtDisp, __nParTipCtb, oCheck2)

local lRet := (__nParTipCtb == 4 .or. __nParTipCtb == 5)

if __lParDtDisp .and. ! lRet
	__lParDtDisp := .f.
endIf

if oCheck2 <> nil
	oCheck2:lActive := lRet
	oCheck2:CtrlRefresh()
	oCheck2:Refresh()
endIf

return(lRet) 
/*/{Protheus.doc} fVldDt
Valida Data

@author PLSTEAM
@since 25/02/2019
@version P11
/*/
static function fVldDt(nTp, lAnoMes, lPeriod)

if ( empty(__cParMes) .and. empty(__cParAno) .and. empty(__dParDtIni) .and. empty(__dParDtFim) )
	
	lAnoMes	:= .t.
	lPeriod	:= .t.

else
	
	if nTp == 1

		__dParDtIni := ctod('')
		__dParDtFim := ctod('')
		lAnoMes		:= ! (empty(__cParMes) .and. empty(__cParAno))
		lPeriod		:= empty(__cParMes) .and. empty(__cParAno)

	else
		
		__cParMes	:= space(2)
		__cParAno	:= space(4)
		lAnoMes		:= empty(__dParDtIni) .and. empty(__dParDtFim)
		lPeriod		:= ! (empty(__dParDtIni) .and. empty(__dParDtFim))

	endIf

endIf	

return(.t.)

/*/{Protheus.doc} vldConf
validacao confirma

@author PLSTEAM
@since 25/02/2019
@version P11
/*/
static function vldConf(__cParCodInt, __cParMes, __cParAno, __dParDtIni, __dParDtFim)
local lRet := .f.

do case

	case empty(__cParCodInt)

		aviso(STR0008,STR0084,{"Ok"}) //"Atenção" ## 'Informe a Operadora!'

	case empty(__cParMes) .and. ( empty(__dParDtIni) .and. empty(__dParDtFim) )
		
		aviso(STR0008,STR0085,{"Ok"}) //"Atenção" ## 'Informe o Mês!'

	case empty(__cParAno) .and. ( empty(__dParDtIni) .and. empty(__dParDtFim) )
		
		aviso(STR0008,STR0086,{"Ok"}) //"Atenção" ## 'Informe o Ano!'

	case empty(__dParDtIni) .and. ( empty(__cParMes) .and. empty(__cParAno) )
		
		aviso(STR0008,STR0101,{"Ok"}) //"Atenção" ## 'Informe a Data Inicio!'

	case empty(__dParDtFim) .and. ( empty(__cParMes) .and. empty(__cParAno) )
		
		aviso(STR0008,STR0102,{"Ok"}) //"Atenção" ## 'Informe a Data Fim!'

	case  ( __nParTipCtb == LP_P9LA .or. __nParTipCtb == LP_P9LB ) .and. ! "OPE" $ __cParClaRda 

		aviso(STR0008,STR0087,{"Ok"}) //"Atenção" ## 'Para Lote de Aviso é necessário selecionar a Classe da Rda (OPE)'

	otherWise
	
		lRet := .t.

endCase

return(lRet)

//função apra pasagem de parâmetros na automação
function PLCT06Par(aPar)
	setPar06(aPar)
return

Static function getPar06()
return aParamAUTO

static function setPar06(aPar)
aParamAUTO := aclone(aPar)
return

function PLCTB06ART()

Local cSql := ""
Local cLP := "9BD"
Local cChvE2 := ""
Local aCtaVal := {{"zero",0,0}} //{{/*conta*/,/*valor provisionado*/,/*valor baixado*/},{/*conta*/,/*valor provisionado*/,/*valor baixado*/},{/*conta*/,/*valor provisionado*/,/*valor baixado*/}}
Local cSql2 := ""
Local cChvCmp := ""
Local cconta := ""
Local nPos := 0
Local cLP2 := "9CT"
Local aretAce := {}
Local aCab	:= {}
Local aItens := {}
Local nOperacao := 4 //3 
local dData		:= stod( __cParAno + __cParMes + '01' )
local datade	:= DtoS(firstDate(dData))
local dataate	:= Dtos(lastDate(dData))
Local cChvI8Ori := ""
Local aAcertoOld := {} 
Local cObsIte	:= ""

cSql += " Select DISTINCT "
cSql += " CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2.R_E_C_N_O_ RECCT2 "
cSql += " ,CV3_RECORI, FK2_IDDOC, FK7_CHAVE "
cSql += " from " + retSqlName("CT2") + " CT2 "
cSql += " Inner Join " + retSqlName("CV3") + " CV3 "
cSql += " On "
cSql += " CV3_FILIAL = '" + xFilial("CV3") + "' AND "
cSql += " CV3_RECDES = CT2.R_E_C_N_O_ AND "
cSql += " CV3_TABORI = 'FK2' AND "
cSql += " CV3.D_E_L_E_T_ = ' ' "
cSql += " Inner Join " + retSqlName("FK2") + " FK2 "
cSql += " On "
cSql += " FK2_FILIAL = '" + xfilial("FK2") + "' AND "
cSql += " FK2.R_E_C_N_O_ = CV3.CV3_RECORI AND "
cSql += " FK2.D_E_L_E_T_ = ' ' "
cSql += " Inner Join " + retsqlName("FK7") + " FK7 "
cSql += " On "
cSql += " FK7_FILIAL = '" + xfilial('FK7') + "' AND "
cSql += " FK7_IDDOC = FK2.FK2_IDDOC AND "
cSql += " FK7.D_E_L_E_T_ = ' ' "
csql += " Where "
Csql += " CT2_FILIAL = '" + xfilial("CT2") + "' AND "
cSql += " CT2_DATA >= '" + datade + "' AND "
cSql += " CT2_DATA <= '" + dataate + "' AND "
//cSql += " CT2_LP = '" + cLP + "' AND "
cSql += " CT2_LP IN ('9BD', '9NB', '9BL', '9NC') AND "
cSql += " CT2.D_E_L_E_T_ = ' ' "
cSql += " Order By FK7_CHAVE "

//Nesse ponto temos do Ct2 até o FK7
//Com um loop de busca no SE2 e FI8 (pra chegar no original de coisas aglutinadas)
dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLCT06Z",.f.,.t.)
SE2->(dbsetOrder(1))
FI8->(dbsetOrder(2))
While !(PLCT06Z->(EoF()))
	
	cChvE2 := StrTran(alltrim(PLCT06Z->FK7_CHAVE), "|", "")

	If cChvCmp <> cChvE2
		If Len(aCtaVal) > 1 //Se só tiver 1, não adicionou nada
			//Aqui ajusta
			aretAce := Acerto(aCtaVal, cObsIte)
			If !aretAce[1] .AND. ARTVerDup2(aCab)
				MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aretAce[2], nOperacao/*4 - alterar*//*3 - incluir*/)
			endIf
		endIf
		aCtaVal := {{"zero",0,0}}
		aAcertoOld := {}
	endIf
	
	CT2->(dbgoTo(PLCT06Z->(RECCT2)))

	//monta o aCab aqui, nesse ponto podemos usar ele no passado. você vai entender. ou já entendeu.
    aCab := { {'DDATALANC' 	,StoD(PLCT06Z->CT2_DATA) /*dDatabase*/ ,NIL},;
              {'CLOTE' 		,PLCT06Z->CT2_LOTE ,NIL},;
              {'CSUBLOTE' 	,PLCT06Z->CT2_SBLOTE,NIL},;
              {'CDOC' 		,PLCT06Z->CT2_DOC/*Soma1(PLCT06Z->CT2_DOC)*/ ,NIL},;
              {'CPADRAO' 	,'' ,NIL} ,;
              {'NTOTINF' 	,0  ,NIL},;
              {'NTOTINFLOT' ,0  ,NIL} }	

	cconta := allTrim(PLCT06Z->CT2_CREDIT)
	cObsIte := CT2->CT2_HIST

	If !(empty(cconta)) .AND. VerCtaART(cconta)
		nPos := aScan(aCtaVal, {|x| x[1] == cconta})
		If nPos == 0
			aadd(aCtaVal, {cConta, PLCT06Z->CT2_VALOR, 0})
		else
			aCtaVal[nPos][2] += PLCT06Z->CT2_VALOR
		endIf
	endIf

	cconta := allTrim(PLCT06Z->CT2_DEBITO)
	If !(empty(cconta)) .AND. VerCtaART(cconta)
		nPos := aScan(aCtaVal, {|x| x[1] == cconta})
		If nPos == 0
			aadd(aCtaVal, {cConta, 0, PLCT06Z->CT2_VALOR})
		else
			aCtaVal[nPos][3] += PLCT06Z->CT2_VALOR
		endIf
	endIf

	If cChvCmp <> cChvE2
		cChvCmp := cChvE2
		aAcertoOld := NoARTdup(PLCT06Z->(CT2_DATA), PLCT06Z->(CT2_LOTE), PLCT06Z->(CT2_SBLOTE), PLCT06Z->(CT2_DOC))
		NoDupAdd(aAcertoOld, @aCtaVal)
	else
		PLCT06Z->(dbskip())
		Loop
	endIf

	If FI8->(MsSeek(cChvE2))
		While !(FI8->(EoF())) .AND. cChvE2 == FI8->(FI8_FILIAL+FI8_PRFDES+FI8_NUMDES+FI8_PARDES+FI8_TIPDES+FI8_FORDES+FI8_LOJDES)

			cChvI8Ori := FI8->(FI8_FILIAL+FI8_PRFORI+FI8_NUMORI+FI8_PARORI+FI8_TIPORI+FI8_FORORI+FI8_LOJORI)
			ArtTitVer(cChvI8Ori,@aCtaVal,datade,dataate)

			FI8->(dbskip())
		endDo
	else //talvez vai ter que ser dois Ifs e não if/else, dependendo da criatividade do cliente

		ArtTitVer(cChvE2,@aCtaVal,datade,dataate)

	endIf

	PLCT06Z->(dbskip())
endDo
If Len(aCtaVal) > 1
	//sempre vai fazer um ajuste uando sai do loop
	aretAce := Acerto(aCtaVal, cObsIte)
	If !aretAce[1] .AND. ARTVerDup2(aCab)
		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aretAce[2], nOperacao)
	endIf
endIf
PLCT06Z->(dbclosearea())

return


static function VerCtaART(cConta)

Local lRet := .F.

lRet := substr(cConta, 1, 6) $ "211111/211112" .OR. substr(cConta, 1, 3) == "214" .OR. substr(cConta, 1, 3) == "219"

return lRet

/*
A.C.E.R.T.O.
Autômato Compensador de Erros no Rateio Tratáveis Observados
*/
static function Acerto(aCtbVal, cObsIte)

Local lRet := .T.
Local nI := 1
Local aPosDif := {}
Local nsomadif := 0
Local aLctcmp := {} //{conta, crédito, débito}
Local cdc := ""
Local cCtaDeb := ""
Local cCtaCred := ""
Local cLin	:= "A00"
Local nValor := 0
Local aItens := {}

Default cObsIte := "Ajuste Rateio Auto" //"A.C.E.R.T.O. "

//esse começa do 2, o 1 não usa. nunca. nunca. nunquinha.
for nI := 2 to Len(aCtbVal)
	If aCtbVal[nI][2] <> aCtbVal[nI][3]
		aadd(aPosDif, {nI, aCtbVal[nI][2] - aCtbVal[nI][3]})
		lRet := .F.
	endIf
next

If !lRet
	for nI := 1 To Len(aPosDif)
		nsomadif += aPosDif[nI][2]
	next

	If nsomadif == 0
		for nI := 1 To Len(aPosDif)
			aadd(aLctcmp, {aCtbVal[aPosDif[nI][1]][1], 0, 0})
			If aPosDif[nI][2] > 0
				aLctcmp[Len(aLctcmp)][3] := aPosDif[nI][2]
			else
				aLctcmp[Len(aLctcmp)][2] := aPosDif[nI][2] * -1
			endIf
		next
	else //Se as diferenças não se anulam, não é um erro a ser tratado aqui. Let it go.
		lRet := .T.
	endIf
endIf

If !lRet
	For nI := 1 To Len(aLctcmp)
		
		If aLctcmp[nI][2] > 0
			cdc := "2"
			cCtaDeb := ""
			cCtaCred := aLctcmp[nI][1]
			nValor := aLctcmp[nI][2]
		else
			cdc := "1"
			cCtaDeb := aLctcmp[nI][1]
			cCtaCred := ""
			nValor := aLctcmp[nI][3]
		endIf

		If nI > 1
			cLin := soma1(cLin)
		endIf
		
		aAdd(aItens,{   {'CT2_FILIAL'   ,xFilial("CT2") , NIL},;
						{'CT2_LINHA'    , cLin          , NIL},;
						{'CT2_MOEDLC'   , "01" , NIL},;
						{'CT2_DC'       ,cdc   , NIL},;
						{'CT2_DEBITO'   ,cCtaDeb , NIL},;
						{'CT2_CREDIT'   ,cCtaCred, NIL},;
						{'CT2_VALOR'    , nValor  , NIL},;
						{'CT2_ORIGEM'   ,'PLSCTB06', NIL},;
						{'CT2_HP'       ,''   , NIL},;
						{'CT2_HIST'     ,cObsIte, NIL},; 
						{'CT2_TPSALD'   ,"1", NIL}} )  
	next
endIf

return {lRet, aItens}

static function ARTdebito(cconta, nValor,aCtaVal)

Local nPos := 0

If !(empty(cconta)) .AND. VerCtaART(cconta)
	nPos := aScan(aCtaVal, {|x| x[1] == cconta})
	If nPos == 0
		aadd(aCtaVal, {cConta, 0, nValor})
	else
		aCtaVal[nPos][3] += nValor
	endIf
endIf

return

static function ARTcredito(cconta, nValor,aCtaVal)

Local nPos := 0

If !(empty(cconta)) .AND. VerCtaART(cconta)
	nPos := aScan(aCtaVal, {|x| x[1] == cconta})
	If nPos == 0
		aadd(aCtaVal, {cConta, nValor, 0})
	else
		aCtaVal[nPos][2] += nValor
	endIf
endIf

return


static function ArtTitVer(cChvE2,aCtaVal,datade,dataate)

Local csql2 := ""
Local cLP2 := "9CT"

If SE2->(MsSeek(cChvE2)) //nunca poderia dar .F., mas vamos manter o if pra casos de problema de base
	//Aqui vamos ter o total do título e impostos
	cSql2 := " Select DISTINCT "
	cSql2 += " CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2.R_E_C_N_O_ RECCT2 "
	cSql2 += " from " + retSqlName("CT2") + " CT2 "
	cSql2 += " Inner Join " + RetSqlName("CV3") + " CV3 "
	cSql2 += " On "
	cSql2 += " CV3_FILIAL = '" + xfilial("CV3") + "' AND "
	cSql2 += " CV3_TABORI = 'SE2' AND "
	cSql2 += " CV3_RECORI = " + allTrim(str(SE2->(recno()))) + " AND "
	cSql2 += " CV3_RECDES = CT2.R_E_C_N_O_ AND "
	cSql2 += " CV3.D_E_L_E_T_ = ' ' "
	cSql2 += " Where "
	cSql2 += " CT2_FILIAL = '" + xfilial('CT2') + "' AND "
	cSql2 += " CT2_LP = '9AG' AND "
	cSql2 += " CT2.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql2),"PLCT9AG",.f.,.t.)

	While !(PLCT9AG->(EoF()))

		ARTcredito(allTrim(PLCT9AG->CT2_CREDIT), PLCT9AG->CT2_VALOR,@aCtaVal)

		ARTdebito(allTrim(PLCT9AG->CT2_DEBITO), PLCT9AG->CT2_VALOR,@aCtaVal)

		PLCT9AG->(dbskip())
	endDo

	PLCT9AG->(dbcloseArea())

	//Aqui vemos a contabiilização de custo das guias
	cSql2 := " Select DISTINCT "
	cSql2 += " CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2.R_E_C_N_O_ RECCT2 "
	cSql2 += " from " + retSqlName("CT2") + " CT2 "
	cSql2 += " Inner Join " + RetSqlName("BD7") + " BD7 "
	cSql2 += " On "
	cSql2 += " BD7_FILIAL = '" + xfilial("BD7") + "' AND "
	cSql2 += " BD7_CHKSE2 = '" + SE2->E2_FILIAL + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA + "' AND "
	cSql2 += " BD7.D_E_L_E_T_ = ' ' "        
	cSql2 += " Inner Join " + RetSqlName("CV3") + " CV3 "
	cSql2 += " On "
	cSql2 += " CV3_FILIAL = '" + xfilial("CV3") + "' AND "
	cSql2 += " CV3_TABORI = 'BD7' AND "
	cSql2 += " CV3_RECORI = BD7.R_E_C_N_O_ AND "
	cSql2 += " CV3_RECDES = CT2.R_E_C_N_O_ AND "
	cSql2 += " CV3.D_E_L_E_T_ = ' ' "
	cSql2 += " Where "
	cSql2 += " CT2_FILIAL = '" + xfilial('CT2') + "' AND "
	cSql2 += " CT2_LP = '" + cLP2 + "' AND "
	cSql2 += " CT2.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql2),"PLCT9CT",.f.,.t.)

	while !(PLCT9CT->(eOf()))

		ARTcredito(allTrim(PLCT9CT->CT2_CREDIT), PLCT9CT->CT2_VALOR,@aCtaVal)

		ARTdebito(allTrim(PLCT9CT->CT2_DEBITO), PLCT9CT->CT2_VALOR,@aCtaVal)

		PLCT9CT->(dbskip())
	endDo
	
	PLCT9CT->(dbclosearea())

	//Aqui vemos baixas anteriores ao mês atual
	cSql2 := " Select DISTINCT "
	cSql2 += " CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2.R_E_C_N_O_ RECCT2 "
	cSql2 += " from " + retSqlName("CT2") + " CT2 "
	cSql2 += " Inner Join " + RetSqlName("FK7") + " FK7 "
	cSql2 += " On "
	cSql2 += " FK7_FILIAL = '" + xfilial("FK7") + "' AND "
	csql2 += " FK7_ALIAS = 'SE2' AND "
	cSql2 += " FK7_CHAVE = '" + SE2->E2_FILIAL + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA + "' AND "
	cSql2 += " FK7.D_E_L_E_T_ = ' ' "        
	cSql2 += " Inner Join " + retSqlName("FK2") + " FK2 "
	cSql2 += " On "
	cSql2 += " FK2_FILIAL = '" + xfilial("FK2") + "' AND "
	cSql2 += " FK2_IDDOC = FK7.FK7_IDDOC AND "
	cSql2 += " FK2.D_E_L_E_T_ = ' ' "
	cSql2 += " Inner Join " + RetSqlName("CV3") + " CV3 "
	cSql2 += " On "
	cSql2 += " CV3_FILIAL = '" + xfilial("CV3") + "' AND "
	cSql2 += " CV3_TABORI = 'FK2' AND "
	cSql2 += " CV3_RECORI = FK2.R_E_C_N_O_ AND "
	cSql2 += " CV3_RECDES = CT2.R_E_C_N_O_ AND "
	cSql2 += " CV3.D_E_L_E_T_ = ' ' "
	cSql2 += " Where "
	cSql2 += " CT2_FILIAL = '" + xfilial('CT2') + "' AND "
	cSql2 += " CT2_LP IN ('9BD', '9NB', '9BL', '9NC') AND "
	cSql2 += " CT2_DATA < '" + datade + "' AND "
	cSql2 += " CT2.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql2),"PLCT9BD",.f.,.t.)

	while !(PLCT9BD->(eOf()))

		ARTcredito(allTrim(PLCT9BD->CT2_CREDIT), PLCT9BD->CT2_VALOR,@aCtaVal)

		ARTdebito(allTrim(PLCT9BD->CT2_DEBITO), PLCT9BD->CT2_VALOR,@aCtaVal)

		PLCT9BD->(dbskip())
	endDo
	
	PLCT9BD->(dbclosearea())

	//Aqui vamos buscar as compensações (pq é um título diferente)
	cSql2 := " Select DISTINCT "
	cSql2 += " CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2.R_E_C_N_O_ RECCT2 "
	cSql2 += " from " + retSqlName("CT2") + " CT2 "
	cSql2 += " Inner Join " + RetSqlName("FK7") + " FK7 "
	cSql2 += " On "
	cSql2 += " FK7_FILIAL = '" + xfilial("FK7") + "' AND "
	csql2 += " FK7_ALIAS = 'SE2' AND "
	cSql2 += " FK7_CHAVE = '" + SE2->E2_FILIAL + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA + "' AND "
	cSql2 += " FK7.D_E_L_E_T_ = ' ' "        
	cSql2 += " Inner Join " + retSqlName("FK2") + " FK2 "
	cSql2 += " On "
	cSql2 += " FK2.FK2_FILIAL = '" + xfilial("FK2") + "' AND "
	cSql2 += " FK2.FK2_IDDOC = FK7.FK7_IDDOC AND "
	cSql2 += " FK2.D_E_L_E_T_ = ' ' "
	cSql2 += " Inner Join " + retSqlName("FK2") + " FK2CMP "
	cSql2 += " On "
	cSql2 += " FK2CMP.FK2_FILIAL = '" + xfilial("FK2") + "' AND "
	cSql2 += " FK2CMP.FK2_IDDOC = FK2.FK2_IDCOMP AND "
	cSql2 += " FK2.D_E_L_E_T_ = ' ' "
	cSql2 += " Inner Join " + RetSqlName("CV3") + " CV3 "
	cSql2 += " On "
	cSql2 += " CV3_FILIAL = '" + xfilial("CV3") + "' AND "
	cSql2 += " CV3_TABORI = 'FK2' AND "
	cSql2 += " CV3_RECORI = FK2CMP.R_E_C_N_O_ AND "
	cSql2 += " CV3_RECDES = CT2.R_E_C_N_O_ AND "
	cSql2 += " CV3.D_E_L_E_T_ = ' ' "
	cSql2 += " Where "
	cSql2 += " CT2_FILIAL = '" + xfilial('CT2') + "' AND "
	cSql2 += " CT2_LP IN ('9BD', '9NB', '9BL', '9NC') AND "
	cSql2 += " CT2_DATA <= '" + dataate + "' AND "
	cSql2 += " CT2.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql2),"PLCT9BD",.f.,.t.)

	while !(PLCT9BD->(eOf()))

		ARTcredito(allTrim(PLCT9BD->CT2_CREDIT), PLCT9BD->CT2_VALOR,@aCtaVal)

		ARTdebito(allTrim(PLCT9BD->CT2_DEBITO), PLCT9BD->CT2_VALOR,@aCtaVal)

		PLCT9BD->(dbskip())
	endDo
	
	PLCT9BD->(dbclosearea())

endIf

return

static function NoARTdup(cData, cLote, cSubLote, cDoc)

Local aret := {}
Local csql := ""

csql += " Select CT2_DEBITO, CT2_CREDIT, CT2_VALOR from " + retsqlName("CT2") + " CT2 "
cSql += " Where "
cSql += " CT2_FILIAL = '" + xFilial("CT2") + "' AND "
cSql += " CT2_DATA = '" + cData + "' AND "
cSql += " CT2_LOTE = '" + cLote + "' AND "
cSql += " CT2_SBLOTE = '" + cSubLote + "' AND "
cSql += " CT2_DOC = '" + cDoc + "' AND "
cSql += " CT2_LP = ' ' AND "
cSql += " CT2_ORIGEM = 'PLSCTB06' AND "
cSql += " CT2.D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLNICR",.f.,.t.)

while !(PLNICR->(EoF()))
	aadd(aRet, { Alltrim(PLNICR->(CT2_CREDIT)), AllTrim(PLNICR->(CT2_DEBITO)), PLNICR->(CT2_VALOR) })
	PLNICR->(dbskip())
endDo
PLNICR->(dbclosearea())

return aRet

static function NoDupAdd(aAcertoOld, aCtaVal)

Local nI := 1

for Ni := 1 to Len(aAcertoOld)
	ARTcredito(aAcertoOld[nI][1], aAcertoOld[nI][3],@aCtaVal)
	ARTdebito(aAcertoOld[nI][2], aAcertoOld[nI][3],@aCtaVal)
Next

return

//Verifica antes da gravação se houve acertos já realizados
static function ARTVerDup2(aCab)
Local aArea := CT2->(getarea())
Local lRet := .F.
Local cSql := ""

if !empty(aCab)
	csql += " Select CT2_DEBITO, CT2_CREDIT, CT2_VALOR from " + retsqlName("CT2") + " CT2 "
	cSql += " Where "
	cSql += " CT2_FILIAL = '" + xFilial("CT2") + "' AND "
	cSql += " CT2_DATA = '" + DtoS(aCab[1][2]) + "' AND "
	cSql += " CT2_LOTE = '" + aCab[2][2] + "' AND "
	cSql += " CT2_SBLOTE = '" + aCab[3][2] + "' AND "
	cSql += " CT2_DOC = '" + aCab[4][2] + "' AND "
	cSql += " CT2_LP = ' ' AND "
	cSql += " CT2_ORIGEM = 'PLSCTB06' AND "
	cSql += " CT2.D_E_L_E_T_ = ' ' "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLDUP2",.f.,.t.)
	lRet := PLDUP2->(EoF())
	PLDUP2->(dbclosearea())
endif

restArea(aArea)

return lRet
