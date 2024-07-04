#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSCTB11.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "topconn.ch"

#DEFINE VAR_CHAVE	1
#DEFINE VAR_COUNT	2
#DEFINE VAR_REG		3

#DEFINE LP_FRECE    30
#DEFINE LP_DLTAV    40
#DEFINE LP_DLTAC    50
#DEFINE LP_DLRAT    60

#DEFINE LP_P9A1    1
#DEFINE LP_P9A2	   4
#DEFINE LP_P9AX9B6 2
#DEFINE LP_P9NX9N6 3 
#DEFINE LP_P9LC    5
#DEFINE LP_P9LD    6
#DEFINE LP_P9LC    7

#DEFINE LP_PROVISAO		 	"9A1" 
#DEFINE LP_PROVISAO_FA	 	"9A2" 
#DEFINE LP_PROVISAO_LA	    "9LC"
#DEFINE LP_PROVISAO_LAC	    "9LD"
#DEFINE LP_BAIXA		 	"9AX"
#DEFINE LP_CANCELA_BAIXA 	"9B6"  
#DEFINE LP_BAIXA_NB		    "9NX"
#DEFINE LP_CANCELA_BAIXA_NB "9N6"
#DEFINE LP_RATEIO			"9A3"
#DEFINE LP_RATEIO_BAIXA_NB	"9NA"
#DEFINE LP_RATEIO_BAIXA		"9AA"	
#DEFINE LP_RATEIO_CANCBX_NB "9N7" 
#DEFINE LP_RATEIO_CANCBX 	"9B7"  
#DEFINE LP_REC_ANTECIPADA   "9A4"
#DEFINE LP_REC_PRORATA	    "9A5"

#DEFINE CTBPLSROT "PLSCTB11"

static __cParMes	:= space(2)
static __cParAno	:= space(4)
static __dParDtIni	:= ctod('')
static __dParDtFim	:= ctod('')
static __cParCliDe	:= ''
static __cParCliAte	:= ''
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

static aPadrao 	 := { { LP_PROVISAO, .f. },; 		//01
                      { LP_BAIXA, .f. },;			//02
		      		  { LP_CANCELA_BAIXA, .f. },;	//03
			          { LP_BAIXA_NB, .f. },;		//04
			          { LP_CANCELA_BAIXA_NB, .f. },;//05
			          { LP_PROVISAO_FA, .f. },;		//06
			          { LP_PROVISAO_LA, .f. },;		//07
					  { LP_PROVISAO_LAC, .f.} ,;	//08
			          { LP_RATEIO, .f. } ,;			//09
					  { LP_RATEIO_BAIXA_NB, .f. },; //10
					  { LP_RATEIO_BAIXA, .f. },;    //11
					  { LP_RATEIO_CANCBX_NB, .f. },;//12
					  { LP_RATEIO_CANCBX, .f. }}	//13

static lAutoStt 	:= .f.
static aParamAUTO 	:= {}

/*/{Protheus.doc} PLSCTB11 
Contabilizacao de Receita - Provisão , Inclusao, Baixa e Cancelamento de Baixa

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
function PLSCTB11(lAuto)
local lUnimed := getNewPar('MV_PLSUNI','0') == '1'

Default lAuto := .F.

lAutoStt := lAuto

if empty(loteCont("PLSREC"))

	if ! lAutoStt
		aviso(STR0008,STR0048,{"Ok"}) //"Atenção" 'Lote não encontrado - chave [PLSREC]'
	endIf	

	return

endIf

plShoPer(lUnimed)
	
return 

/*/{Protheus.doc} PLINFDAD 
Contabilizacao de Titulos

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

aEval(aPadrao,{|x| x[2] := verPadrao(x[1])})

__cLPINFO := retMLP(aPadrao, @lRet)
    
if ! lRet

    If ! lAutoStt
    	aviso( STR0007,STR0012 + __cLPINFO, {"OK"} ) //"Atenção" ##"Para contabilizar é necessário criar os seguintes Lançamentos Padronizados: "
    endif

    return(lRet)
endIf

lRet := .f.

if ( nH := plsAbreSem(cSemaApp, .f.) ) == 0
	
	If ! lAutoStt
		aviso(STR0008,STR0049,{"Ok"}) //"Atenção" ##'Existe outro processo sendo executado, por favor, aguarde!'
	endIf

	return(lRet)
endIf

If (__lLoteAviso .And. __nParTipCtb == 7) .Or. (__nParTipCtb == 5 .And. !__lLoteAviso)
	If MsgYesNo(STR0082) // "Processar o Reconhecimento de Receita sob Recebimentos Antecipados ou a Apropriação Pro-Rata da competência anterior?"

		If PLSCTBRecF()
			MsgAlert(STR0069) //"Processo concluido!"
		Else
			MsgAlert(STR0011) //"Nenhum registro encontrado ou lançamento contábil inconsistente!"
		EndIf

	EndIf

	lRet := .T.
	Return lRet
Endif

//Monta o arquivo de trabalho
cTabMult := PLRETDAD(@cSqlMThread)

if ! empty(cTabMult) .and. (cTabMult)->( ! eof() )

	lRet := .t.

	// MultiThread/Grid
	if ( __nParChkMTGR == 2 .and. nNumProc >= 1 ) .or. lGrid
	 	
		aadd(aMatStat, __cParMes)
		aadd(aMatStat, __cParAno)
		aadd(aMatStat, __cParCliDe)
		aadd(aMatStat, __cParCliAte)
		aadd(aMatStat, __nParTipCtb)
		aadd(aMatStat, __lParChkALC)
		aadd(aMatStat, __lParChkFC)
		aadd(aMatStat, __nParChkMTGR)
		aadd(aMatStat, __lParDtDisp)
		aadd(aMatStat, __cLPINFO)
		aadd(aMatStat, cSqlMThread)
		aadd(aMatStat, __dParDtIni)
		aadd(aMatStat, __dParDtFim)
		aadd(aMatStat, __lLoteAviso)

		If lAutoStt

			aMatStat := aClone(getPar11())

			aadd(aMatStat, __cLPINFO)
			aadd(aMatStat, cSqlMThread)

		endIf

		aProcs := PROMThread(cTabMult, 'REC', __nParTipCtb, cDesLP)

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
			lProc	 			 := oProCtb:prepare('sGrid', aAmb, 'JOBRPCTB11', 'fGrid')
			
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
			oProCtb:start("JOBRPCTB11")

		endIf

		if lProc
	
			//Inicializa as Threads Transação controlada
			for nX := 1 to len(aProcs)

				incProc(__cLPINFO + '-' + STR0051 + cInicio + '] até [' + cFim + '] - ' + strZero(aProcs[nX,VAR_COUNT],10)) //'Movim. de ['
				
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
				incProc(STR0068)//'Finalizando...'
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

		PLPRODADTIT(cTabMult, nTotReg, nil)

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
		msgAlert(STR0069) //"Processo concluido!"	
	else
		msgAlert(STR0011) //"Nenhum registro encontrado ou lançamento contábil inconsistente!"
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
local cOperadorQuery := ""

local dData		:= stod( __cParAno + __cParMes + '01' )
local dDataIni	:= iIf( ! empty(__cParMes + __cParAno), firstDate(dData), __dParDtIni)
local dDataFim	:= iIf( ! empty(__cParMes + __cParAno), lastDate(dData) , __dParDtFim)
local aStruSQL	:= {}


default cSqlMThread	:= ''

//verifica qual banco de dados
getTpDB(@__lOracle)

if empty(cSqlMThread)
	
	incProc(STR0013) //"Aguarde, preparando dados..."

	//provisao
	if __nParTipCtb == LP_P9A1 .or. __nParTipCtb == LP_P9A2

		cSql := " SELECT SE1.R_E_C_N_O_ SE1Recno "
		
		cSql += " FROM " + retSQLName("SE1") + " SE1 " 

		cSql += " WHERE E1_FILIAL = '" + xFilial("SE1") + "' "
		cSql += "   AND E1_EMISSAO BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFim) + "' "
		cSql += "   AND E1_TIPO NOT IN " + formatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVPAGANT+"|"+MVRECANT,"|") 

		if __nParTipCtb == LP_P9A2	
			cSql += " AND E1_LA = 'S' "
		else
			cSql += " AND E1_LA <> 'S' "
		endIf
		
		if __lOracle
			cSql += " AND SUBSTR(E1_ORIGEM,1,3) = 'PLS' " 
			cSql += " AND TRIM(E1_NUMLIQ) IS NULL "
			cSql += " AND TRIM(E1_TITPAI) IS NULL "
		else
			cSql += " AND SUBSTRING(E1_ORIGEM,1,3) = 'PLS' " 
			cSql += " AND E1_NUMLIQ = ' ' " 
			cSql += " AND E1_TITPAI = ' ' "
		endIf

		//considera competencia
		if __nParTipCtb == LP_P9A2

			cOperadorQuery := IIf(__lOracle, "||", "+")

			cSql += " AND E1_ANOBASE "+cOperadorQuery+" E1_MESBASE > '" + __cParAno + __cParMes + "' "

		endIf
		
		if ! empty(__cParCliDe) .and. ! empty(__cParCliAte)
			cSql += " AND E1_CLIENTE BETWEEN '" + __cParCliDe + "' AND '" + __cParCliAte + "' "
		endIf

		cSql += " AND SE1.D_E_L_E_T_ = ' ' "

		cSql += " ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "
	
	//baixa cancelamento da baixa - (Movimenta banco ou nao)
	elseIf __nParTipCtb == LP_P9AX9B6 .or. __nParTipCtb == LP_P9NX9N6

		cTPMOVBAN := plRetMTBX('REC', __nParTipCtb)

		cSql := " SELECT SE1.R_E_C_N_O_ SE1Recno, "
		cSql += "        FK1.R_E_C_N_O_ FK1Recno  "
		
		cSql += " FROM " + retSQLName("FK1") + " FK1 "

		//inclui busca na FK7
		cSql += sqlInFK7()

		//inclui busca na SE1
		cSql += sqlInSE1()

		cSql += " WHERE FK1_FILIAL = '" + xFilial("FK1") + "' "
		
		if __lParDtDisp
			cSql += "   AND FK1_DTDISP BETWEEN '" + dtos(dDataIni) + "' AND '" +  dtos(dDataFim) + "' "
		else
			cSql += "   AND FK1_DATA BETWEEN '" + dtos(dDataIni) + "' AND '" +  dtos(dDataFim) + "' "
		endIf	

		cSql += "   AND FK1_LA <> 'S' "

		//lista motivo de baixa que gera movimentacao bancaria ou baixa de PA
		cSql += "   AND FK1_MOTBX IN " + formatIn(cTPMOVBAN,"|")
		cSql += "   AND FK1.D_E_L_E_T_ = ' ' "

		cSql += " ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, FK1Recno "

	//provisao de lote de aviso provisao e cobranca
	elseIf ( __nParTipCtb == LP_P9LC .or. __nParTipCtb == LP_P9LD ) .and. __lLoteAviso

		cSql := " SELECT B6S.R_E_C_N_O_ B6SRecno, B6S_FILIAL, B6S_NUMLOT, B6S_CODOPE, B6S_CODLDP, B6S_CODPEG, B6S_NUMERO "
		cSql += " FROM " + retSQLName("B6S") + " B6S "

		//inclui busca na B2S
		cSql += sqlInB2S()

		cSql += " WHERE B6S_FILIAL = '" + xFilial("B6S") + "' "

		if __nParTipCtb == LP_P9LC
			cSql += "   AND B6S_DATPRO BETWEEN '" + dtos(dDataIni) + "' AND '" +  dtos(dDataFim) + "' "
			cSql += "   AND B6S_LAPRO  = '" + space( tamSX3("B6S_LAPRO")[1] ) + "' "
		else
			cSql += "   AND B6S_DTEMIS BETWEEN '" + dtos(dDataIni) + "' AND '" +  dtos(dDataFim) + "' "
			cSql += "   AND B6S_LA  = '" + space( tamSX3("B6S_LA")[1] ) + "' "
		endIf	

		cSql += "   AND B6S.D_E_L_E_T_ = ' ' "

		cSql += " ORDER BY B6S_FILIAL, B6S_NUMLOT, B6S_CODOPE, B6S_CODLDP, B6S_CODPEG, B6S_NUMERO "

	endIf

	//ponto de entrada para alteracao de query
	if existBlock("PLSCT11PRC")
	    cSql := execBlock("PLSCT11PRC", .f., .f., { cSql, __nParTipCtb } )
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
cSql += "   AND FK7_IDDOC  = FK1_IDDOC "
cSql += "   AND FK7_ALIAS  = 'SE1' "
cSql += "   AND FK7.D_E_L_E_T_ = ' ' "

return(cSql)

/*/{Protheus.doc} sqlInB2S
retorna string query para implementar busca na B6S

@author  PLS TEAM
@version P12
@since   06.06.19
/*/
static function sqlInB2S()
local cSql := ''

cSql += " INNER JOIN " + retSQLName("B2S") + " B2S "
cSql += "    ON B2S_FILIAL = '" + xFilial("B2S") + "' "
cSql += "   AND B2S_NUMLOT = B6S_NUMLOT "
cSql += "   AND B2S_STATUS = '2' "
cSql += "   AND B2S.D_E_L_E_T_ = ' ' "

return(cSql)

/*/{Protheus.doc} sqlInSE1
retorna string query para implementar busca

@author  PLS TEAM
@version P12
@since   06.06.19
/*/
static function sqlInSE1()
local cSql := ''

//verifica qual banco de dados
getTpDB(@__lOracle)

cSql += " INNER JOIN " + retSQLName("SE1") + " SE1 "
cSql += "    ON " + plFiePar("E1_FILIAL|E1_PREFIXO|E1_NUM|E1_PARCELA|E1_TIPO|E1_CLIENTE|E1_LOJA", "FK7_CHAVE")
cSql += "   AND E1_TIPO NOT IN " + formatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVPAGANT+"|"+MVRECANT,"|")

if ! empty(__cParCliDe) .and. ! empty(__cParCliAte)
	cSql += " AND E1_CLIENTE BETWEEN '" + __cParCliDe + "' AND '" + __cParCliAte + "' "
endIf

if __lOracle
	cSql += " AND SUBSTR(E1_ORIGEM,1,3) = 'PLS' " 
	cSql += " AND TRIM(E1_TITPAI) IS NULL "
else
	cSql += " AND SUBSTRING(E1_ORIGEM,1,3) = 'PLS' " 
	cSql += " AND E1_TITPAI = ' ' "
endIf

cSql += "   AND SE1.D_E_L_E_T_ = ' ' " 

return(cSql)

/*/{Protheus.doc} PLPRODADTIT 
Receita - Contas a Receber SE1 - BM1
@author  PLS TEAM
@version P12
@since   21.03.17
/*/
static function PLPRODADTIT(cTabMult, nTotReg, cThReadID)
local nHdlPrv 		:= 0
local nTotLanc		:= 0
local nValAux		:= 0
local nChaveTIT		:= 0
local nI			:= 0
local nRecBM1		:= 0
local cArquivo 		:= ""
local cChaveUSU 	:= ""
local cChaveB6S		:= ""
local cCondic		:= ""
local cAliasRec		:= ""
local cChvMAT		:= ""
local cIncPro		:= ""
local cLote			:= ""
local aFlagPLS 		:= {}
local aFlagCTB		:= {}
local aRegBFQ 		:= {}
local aCT5			:= {}
local lCabecalho	:= .f.
local lMostraLC 	:= .f.
local lRet			:= .f.
local lPlsAtiv		:= getNewPar("MV_PLATCT", .f.)
local dDtLote		:= ctod('')
local nTamDec		:= PLGetDec('E1_VALOR')
local cAliasTrb		:= ''
local lExisteB6U	:= PLSALIASEXI("B6U")
local cLPRateio		:= ""
local cSeqBaixa 	:= ""
local dDtMovimento	:= CToD(" / / ")

private __PLSModLOT 	:= "PLSREC"
private lanceiCTB 		:= .f.
private lMsErroAuto 	:= .f.
private lMsHelpAuto		:= .t.
private lAutoErrNofile	:= .t.

default cThReadID 	:= allTrim(str(thReadID()))

cLote := loteCont(__PLSModLOT)

BDC->(dbSetOrder(1))//BDC_FILIAL+BDC_CODOPE+BDC_NUMERO
BBT->(dbSetOrder(7))//BBT_FILIAL+BBT_PREFIX+BBT_NUMTIT+BBT_PARCEL+BBT_TIPTIT+BBT_RECPAG
BFQ->(dbSetOrder(1))//BFQ_FILIAL+BFQ_CODINT+BFQ_PROPRI+BFQ_CODLAN
BED->(dbSetOrder(3))//BED_FILIAL+BED_PREFIX+BED_NUMTIT+BED_PARCEL+BED_TIPTIT
BA3->(dbSetOrder(1))//BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
BA1->(dbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
if FWAliasInDic("B5F")
	B5F->(dbSetOrder(3)) //B5F_FILIAL+B5F_CODINT+B5F_CODEMP+B5F_MATRIC+B5F_TIPREG+B5F_DIGITO     
endIf
BI3->(dbSetOrder(1))//BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO
BT6->(dbSetOrder(1))//BT6_FILIAL+BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO
BQC->(dbSetOrder(1))//BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB
BHT->(dbSetOrder(3))//BHT_FILIAL+BHT_CODIGO+BHT_CODOCO
BSQ->(dbSetOrder(1))//BSQ_FILIAL+BSQ_CODSEQ+BSQ_USUARI+BSQ_ANO+BSQ_MES
BSP->(dbSetOrder(1))//BSP_FILIAL+BSP_CODSER
BTO->(dbSetOrder(3))//BTO_FILIAL+BTO_CODOPE+BTO_NUMERO+BTO_OPEORI
BF4->(dbSetOrder(1))//BF4_FILIAL+BF4_CODINT+BF4_CODEMP+BF4_MATRIC+BF4_TIPREG+BF4_CODPRO
SA1->(dbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
SED->(dbSetOrder(1))//ED_FILIAL+ED_CODIGO
SA6->(dbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
SE1->(dbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
BM1->(dbSetOrder(4))//BM1_FILIAL+BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL+BM1_TIPTIT+BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG+BM1_CODTIP
SE5->(dbSetOrder(7))//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ

if __lLoteAviso
	B6S->(dbSetOrder(4))//B6S_FILIAL+B6S_PREFIX+B6S_NUMTIT+B6S_PARCEL+B6S_TIPTIT+B6S_MATRIC
endIf	

//lote de aviso - LP 9LC ou 9LD
if ( __nParTipCtb == LP_P9LC .or. __nParTipCtb == LP_P9LD ) .and. __lLoteAviso

	while ! (cTabMult)->(eof())
	
		B6S->( msGoTo( (cTabMult)->B6SRecno ) )
		
		if  __nParTipCtb == LP_P9LC
			
			if ! empty(B6S->B6S_LAPRO)
				(cTabMult)->(dbSkip())
				loop
			endIf

		else
			
			if ! empty(B6S->B6S_LA)
				(cTabMult)->(dbSkip())
				loop
			endIf

		endIf	

		//quebra o movimento por local e peg
		//esta chave nao tem relacao com a chave da query principal nem com a quebra da thread
		cChaveB6S := (cTabMult)->(B6S_FILIAL + B6S_NUMLOT + B6S_CODOPE + B6S_CODLDP + B6S_CODPEG)
		cCondic   := cTabMult + "->(B6S_FILIAL + B6S_NUMLOT + B6S_CODOPE + B6S_CODLDP + B6S_CODPEG)"
		lRet      := .f.
		
		if  cIncPro <> B6S->( B6S_FILIAL + B6S_CODOPE + B6S_CODLDP + B6S_CODPEG + B6S_NUMERO )

			cIncPro := B6S->( B6S_FILIAL + B6S_CODOPE + B6S_CODLDP + B6S_CODPEG + B6S_NUMERO )
			
			if ! lAutoStt
				incProc( __cLPINFO + '-' + STR0080 +  B6S->B6S_CODOPE + "." + B6S->B6S_CODLDP + "." + B6S->B6S_CODPEG + "." + B6S->B6S_NUMERO + "]" + STR0081 + allTrim(B6S->B6S_NUMLOT) + "]" ) //Guia [] # Lote ['
			endIf	

			//Posiciona nas tabelas auxliares
			fPosTabCab(B6S->B6S_MATRIC)

		endIf

		if alias() <> 'B6S'
			dbSelectArea('B6S')
		endIf

		if ! lCabecalho
			PLSCTBCABEC(@nHdlPrv, @cArquivo, .f., @lCabecalho, CTBPLSROT, cLote)
		endIf

		//data do lote
		if __nParTipCtb == LP_P9LC
			dDtLote := B6S->B6S_DATPRO
		else
			dDtLote := B6S->B6S_DTEMIS
		endif	

		nValAux := detProva( nHdlPrv, __cLPINFO, CTBPLSROT, cLote,,,,,, aCT5,,, PLSRACTL(__cLPINFO) )
		nTotLanc += nValAux

		if empty(cArquivo)
			cArquivo := getHFile()
		endIf

		if round(nTotLanc, nTamDec) > 0
			lRet := .t.
		endIf
		
		PLSMONFLAG( @aFlagPLS, iIf(__nParTipCtb == LP_P9LC, LP_DLTAV, LP_DLTAC), __cLPINFO, (nValAux > 0) )

		(cTabMult)->(dbSkip())
		
		if (cTabMult)->(eof()) .or. &(cCondic) != cChaveB6S

			if lCabecalho .and. lRet

				lanceiCTB := ( len(aFlagPLS) > 0 )
				PLSCA100(@cArquivo, @nHdlPrv, cLote, @nTotLanc, @lCabecalho, @aFlagPLS, dDtLote, lMostraLC, __lParChkALC, __cLPINFO, iIf(__nParTipCtb == LP_P9LC, LP_DLTAV, LP_DLTAC), cThReadID, CTBPLSROT, nil)
				
			endIf

		endIf

	endDo

else

	//carrega lancamento de faturamento
	if lPlsAtiv

		BFQ->(dbGoTop())
		
		do while ! BFQ->(eof())
		
			aadd( aRegBFQ, { BFQ->BFQ_FILIAL, BFQ->BFQ_CODINT, BFQ->BFQ_PROPRI, BFQ->BFQ_CODLAN, BFQ->BFQ_CONTAB } )
		
		BFQ->(dbSkip())
		endDo
		
	endIf

	while ! (cTabMult)->(eof())

		SE1->( msGoTo( (cTabMult)->SE1Recno ) )

		//retorna titulo vinculado a tabela do PLS com liquidacao/reliquidacao ou nao.
		aMatTIT := PLSTITMOV('SE1')

		if len(aMatTIT) == 0
			(cTabMult)->(dbSkip())
			loop
		endIf

		cAliasRec := ''

		//provisao 9A1
		if __nParTipCtb == LP_P9A1
			
			if aScan(aFlagCTB,{ |x| x[4] == (cTabMult)->(SE1Recno) } ) == 0
				aAdd(aFlagCTB,{"E1_LA","S","SE1", (cTabMult)->(SE1Recno), 0, 0, 1})
			endIf

		//Baixa ou Cancelamento da Baixa
		elseIf __nParTipCtb == LP_P9AX9B6 .or. __nParTipCtb == LP_P9NX9N6
			
			FK1->( msGoTo( (cTabMult)->FK1Recno ) )	

			//movimenta banco
			if __nParTipCtb == LP_P9AX9B6

				__cLPINFO := LP_BAIXA			

				//cancelamento da baixa
				if FK1->FK1_TPDOC == 'ES'
					__cLPINFO := LP_CANCELA_BAIXA			
				endIf

			//nao movimenta banco
			else

				__cLPINFO := LP_BAIXA_NB			

				//cancelamento da baixa
				if FK1->FK1_TPDOC == 'ES'
					__cLPINFO := LP_CANCELA_BAIXA_NB			
				endIf

			endIf

			if aScan(aFlagCTB,{ |x| x[4] == (cTabMult)->FK1Recno } ) == 0
				aAdd(aFlagCTB,{"FK1_LA", "S", "FK1", (cTabMult)->FK1Recno, 0, 0, 1})
			endIf

		endIf
		
		//limpa publicas para controle do rateio
		ratGLBPub('SE1')	
			
		//quebra o movimento por titulo 
		//esta chave nao tem relacao com a chave da query principal nem com a quebra da thread
		if __nParTipCtb == LP_P9A1 .or. __nParTipCtb == LP_P9A2      
			
			nChaveTIT := (cTabMult)->SE1Recno
			cCondic   := cTabMult + "->SE1Recno"

		elseIf __nParTipCtb == LP_P9AX9B6  .or. __nParTipCtb == LP_P9NX9N6

			nChaveTIT := (cTabMult)->FK1Recno
			cCondic   := cTabMult + "->FK1Recno"

		endIf	
		
		//data do lote
		If ExistBlock("PLSCT11DTL")
            dDtLote := ExecBlock("PLSCT11DTL", .F., .F., {__nParTipCtb, SE1->(Recno())})
        Else
			if __lParDtDisp
				dDtLote := FK1->FK1_DTDISP
			else
				
				if __nParTipCtb == LP_P9A1 .or. __nParTipCtb == LP_P9A2

					if __nParTipCtb == LP_P9A2
						dDtLote := lastDate( stod( SE1->( E1_ANOBASE + E1_MESBASE ) + '01' ) )
					else
						dDtLote := SE1->E1_EMISSAO
					endIf	

				else
					dDtLote := FK1->FK1_DATA
				endIf	

			endIf
		EndIf

		lRet := .f.

		for nI := 1 to len(aMatTIT)
			
			cChvMAT := aMatTIT[nI]
			nRecBM1	:= 0
			
			if BM1->( msSeek( xFilial('BM1') + cChvMAT ) )

				if ! lAutoStt .and. cIncPro <> BM1->(BM1_FILIAL + BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT)
			
					cIncPro := BM1->(BM1_FILIAL + BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT)

					incProc( __cLPINFO + ' - ' + STR0014  + allTrim(cIncPro) + STR0015 + BM1->(BM1_CODINT + BM1_CODEMP + BM1_MATRIC + BM1_TIPREG) + "]" ) //"Lote [" ## "] Familia ["

				endIf

				//roda todas as BM1 do titulo PLS
				while ! BM1->(eof()) .and. xFilial('BM1') + cChvMAT == BM1->(BM1_FILIAL + BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT)
					
					if __nParTipCtb == LP_P9A1 .and. BM1->BM1_LAPRO == 'S' 
						BM1->(dbSkip())
						loop
					endIf

					//reversao e nova provisao somente para LAFAT igual a 'P' ja provisionados
					if __nParTipCtb == LP_P9A2 .and. BM1->BM1_LAFAT != 'P'
						BM1->(dbSkip())
						loop
					endIf

					if lPlsAtiv
						
						if ( aScan( aRegBFQ, { |x| x[1] + x[2] + x[3] + x[4] == xFilial("BFQ") + BM1->(BM1_CODINT + BM1_CODTIP) .and. x[5] == '1' } ) ) == 0 
							
							PlGrvlog(STR0046 + BM1->(BM1_CODINT + BM1_CODTIP), __cLPINFO , 1, .t., funName())//'BFQ Desativado - '

							BM1->(dbSkip())
							loop
						endIf
								
					endIf

					//posiciona no cabacalho da guia
					if cChaveUSU <> BM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG+BM1_CODTIP)
						
						cChaveUSU := BM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG+BM1_CODTIP)
				
						//Posiciona tabelas auxiliares  
						fPosTabCab()
						
					endIf
									
					if ! lCabecalho
						PLSCTBCABEC(@nHdlPrv, @cArquivo, .f., @lCabecalho, CTBPLSROT, cLote)
					endIf	
					
					//para garantir que a area aberta sera o BM1 
					if __nParTipCtb == LP_P9A1 .or. __nParTipCtb == LP_P9A2 

						if alias() <> 'BM1'
							dbSelectArea('BM1')
						endIf

					elseIf __nParTipCtb == LP_P9AX9B6 .or. __nParTipCtb == LP_P9NX9N6
						
						if alias() <> 'FK1'
							dbSelectArea('FK1')
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

					if __nParTipCtb == LP_P9A1 .or. __nParTipCtb == LP_P9A2
						PLSMONFLAG( @aFlagPLS, LP_FRECE, __cLPINFO, (nValAux > 0) )
					endIf
					
					nRecBM1 := BM1->(recno())

					BM1->(dbSkip())
				endDo

			endIf

		next
				
		(cTabMult)->(dbSkip())

		if (cTabMult)->(eof()) .or. &(cCondic) != nChaveTIT

			//mudou a chave finaliza os lancamentos
			if lCabecalho .and. lRet 

				BM1->(msGoTo(nRecBM1))

				lanceiCTB := ( len(aFlagCTB) > 0 )
				PLSCA100(@cArquivo, @nHdlPrv, cLote, @nTotLanc, @lCabecalho, @aFlagPLS, dDtLote, lMostraLC, __lParChkALC, __cLPINFO, LP_FRECE, cThReadID, CTBPLSROT, @aFlagCTB)

			endIf

		endIf

		cLPRateio := ""
		cSeqBaixa := FK1->FK1_SEQ
		dDtMovimento := FK1->FK1_DATA
		Do Case
			Case __nParTipCtb == LP_P9A1
				cLPRateio := LP_RATEIO	

			Case __nParTipCtb == LP_P9AX9B6	
				cLPRateio := LP_RATEIO_BAIXA

				If FK1->FK1_TPDOC == 'ES'
					cLPRateio := LP_RATEIO_CANCBX
				EndIf

			Case __nParTipCtb == LP_P9NX9N6
				cLPRateio := LP_RATEIO_BAIXA_NB

				If FK1->FK1_TPDOC == 'ES'
					cLPRateio := LP_RATEIO_CANCBX_NB
				EndIf
		EndCase

		// Contabilização do Rateio
		If lExisteB6U .and. !Empty(cLPRateio)
			PlsContRat(cLote, cThReadID, cLPRateio, cSeqBaixa, dDtMovimento)
		Endif
	EndDo

endIf

return(lRet)

/*/{Protheus.doc} JOBRPCTB11 
JOB
@author  PLS TEAM
@version P12
@since   15.11.05
/*/
function JOBRPCTB11(aCallPar)
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

local nThRead	:= thReadID()
local cThReadID := allTrim(str(nThRead))
local lRet		:= .f.

__cParMes		:= aMatStat[1]
__cParAno		:= aMatStat[2]
__cParCliDe		:= aMatStat[3]
__cParCliAte	:= aMatStat[4]
__nParTipCtb	:= aMatStat[5]
__lParChkALC	:= aMatStat[6]
__lParChkFC		:= aMatStat[7]
__nParChkMTGR	:= aMatStat[8]
__lParDtDisp	:= aMatStat[9]
__cLPINFO		:= aMatStat[10]
cSqlMThread		:= aMatStat[11]
__dParDtIni		:= aMatStat[12]
__dParDtFim		:= aMatStat[13]
__lLoteAviso	:= aMatStat[14]

FWLogMsg('INFO',, 'SIGAPLS', funName(), '', '01', 'Inicio - thID [' + cThReadID + '] - ' + dtos(date()) + ' - ' + time() + STR0033 + __cLPINFO + ' - [ ' + strZero(nCount,10) + ' ] - ' + cReg + allTrim(cChave) , 0, 0, {})//"Registro: '

//monta a query quebrando por peg
nPosUnion 	:= at('union all', lower(cSqlMThread))
nPos 	 	:= at('order by', lower(cSqlMThread))
cOrderBy 	:= right(cSqlMThread, len(cSqlMThread) - (nPos-1))

//quebra por titulo - chave vem da funcao PROMThread
if __nParTipCtb == LP_P9A1 .or. __nParTipCtb == LP_P9A2
	
	cCompWhere  := " AND SE1.R_E_C_N_O_ = '" + cChave + "' " 
	cSqlMThread	:= left(cSqlMThread, nPos - 1) + cCompWhere + cOrderBy

	if nPosUnion > 0
		cBeForUnion := left(cSqlMThread, nPosUnion - 1) + cCompWhere
		cSqlMThread	:= cBeForUnion + right(cSqlMThread, len(cSqlMThread) - (nPosUnion-1))
	endIf

elseIf __nParTipCtb == LP_P9AX9B6  .or. __nParTipCtb == LP_P9NX9N6			

	cCompWhere  := " AND FK1.R_E_C_N_O_ = '" + cChave + "' "
	cSqlMThread	:= left(cSqlMThread, nPos - 1) + cCompWhere + cOrderBy
			
	if nPosUnion > 0
		cBeForUnion := left(cSqlMThread, nPosUnion - 1) + cCompWhere
		cSqlMThread	:= cBeForUnion + right(cSqlMThread, len(cSqlMThread) - (nPosUnion-1))
	endIf

//provisao/cobranca lote aviso - chave vem da funcao PROMThread
elseIf ( __nParTipCtb == LP_P9LC .or. __nParTipCtb == LP_P9LD ) .and. __lLoteAviso

	cCompWhere  := " AND (B6S_FILIAL = '" + xFilial("B6S") + "' "
	cCompWhere  += " AND  " + plFiePar("B6S_NUMLOT|B6S_CODOPE|B6S_CODLDP|B6S_CODPEG", cChave, .f., nil, .t.) + " ) "

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
lRet := PLPRODADTIT(cTabMult, nTotReg, cThReadID)

if select(cTabMult) > 0
	(cTabMult)->(dbCloseArea())
endIf

FWLogMsg('INFO',, 'SIGAPLS', funName(), '', '01', 'Fim - thID [' + cThReadID + '] - ' + dtos(date()) + ' - ' + time() + STR0033 + __cLPINFO + ' - [ ' + strZero(nCount,10) + ' ] - ' + cReg + allTrim(cChave) + " | Tempo Gasto: " + allTrim(str(seconds() - nSeconds) + '|' + iIf(lRet, 'Processado', 'Não Processado') ), 0, 0, {})//'Registro: '

return(lRet)

/*/{Protheus.doc} fPosTabCab 

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
static function fPosTabCab(cMatric)
local aArea 		:= getArea()
local cCodPro		:= ''
local cVerPro		:= ''
local nTam1			:= tamSX3("BSQ_CODSEQ")[1]
default cMatric		:= ""

if ( __nParTipCtb == LP_P9LC .or. __nParTipCtb == LP_P9LD ) .and. __lLoteAviso

	if ! B2S->(eof()) .and. ! empty(B2S->B2S_CODRDA) .and. BAU->(BAU_FILIAL+BAU_CODIGO) <> xFilial("BAU") + B2S->B2S_CODRDA
		BAU->( msSeek( xFilial("BAU") + B2S->B2S_CODRDA ) )
	endIf
	
endIf

if xFilial("SA1") + SE1->( E1_CLIENTE + E1_LOJA ) <> SA1->( A1_FILIAL + A1_COD + A1_LOJA )
	SA1->( msSeek( xFilial("SA1") + SE1->( E1_CLIENTE + E1_LOJA ) ) )
endIf

if xFilial("SED") + SE1->( E1_NATUREZ ) <> SED->( ED_FILIAL + ED_CODIGO )	
	SED->( msSeek( xFilial("SED") + SE1->( E1_NATUREZ ) ) )
endIf	

//baixa e cancelamento da baixa	
if __nParTipCtb == LP_P9AX9B6 .or. __nParTipCtb == LP_P9NX9N6	

	if xFilial("SED") + FK1->FK1_NATURE <> SED->( ED_FILIAL + ED_CODIGO )
		SED->( msSeek( xFilial("SED") + FK1->FK1_NATURE) )
	endIf

	if SE5->( E5_FILIAL + E5_BANCO + E5_AGENCIA + E5_CONTA ) <> xFilial('SA6') + SA6->( A6_COD + A6_AGENCIA + A6_NUMCON )
		
		if SE5->( msSeek( xFilial('SE5') + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA) ) )

			while ! SE5->(eof()) .and. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == xFilial('SE5') + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)

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

//Posiciona no cabecalho do lote
if xFilial("BDC") + BM1->BM1_PLNUCO <> BDC->(BDC_FILIAL+BDC_CODOPE+BDC_NUMERO)
	BDC->( msSeek( xFilial("BDC") + BM1->BM1_PLNUCO ) )
endIf	

if xFilial("BBT") + BM1->(BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT) <> BBT->(BBT_FILIAL + BBT_PREFIX + BBT_NUMTIT + BBT_PARCEL + BBT_TIPTIT) 
	
	if BBT->( msSeek( xFilial("BBT") + BM1->(BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT) ) ) .and. ! empty(BBT->BBT_CODTIP)

		// Posiciona BFQ - Lancamentos do Faturamento                          
		if BFQ->( msSeek( xFilial("BFQ") + BBT->(BBT_CODOPE + BBT_CODTIP) ) )
		
			// Cobranca de carteirinha
			if  BBT->BBT_CODTIP == "107" 
		
				// localiza a cobranca de identificacao que originou o titulo
				BED->( msSeek( xFilial("BED") + BM1->(BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT) ) )
				
			endIf
			
		endIf
		
	endIf
			
endIf

//posiciona no lancamento de faturamento
if xFilial("BFQ") + BM1->(BM1_CODINT + BM1_CODTIP) <> BFQ->(BFQ_FILIAL + BFQ_CODINT + (BFQ_PROPRI + BFQ_CODLAN) )
	BFQ->( msSeek( xFilial("BFQ") + BM1->(BM1_CODINT + BM1_CODTIP) ) )
endIf	

// Posiciona BA3-Familia                                           
if xFilial("BA3") + BM1->(BM1_CODINT + BM1_CODEMP + BM1_MATRIC) <> BA3->(BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_MATRIC)
	BA3->( msSeek( xFilial("BA3") + BM1->(BM1_CODINT + BM1_CODEMP + BM1_MATRIC) ) )
endIf

//provisao
if ( __nParTipCtb == LP_P9LC .or. __nParTipCtb == LP_P9LD ) 

	//Posiciona BA1 - Usuarios
	if BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) <> xFilial("BA1") + cMatric
		
		BA1->( msSeek( xFilial("BA1") + cMatric ) )
		
		PLSVLDB5F(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), , .t.)

	endIf

else

	// Posiciona BA1-Usuario                                               
	if xFilial("BA1") + BM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG) <> BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
		
		BA1->( msSeek( xFilial("BA1") + BM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG) ) )
		
		PLSVLDB5F(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), , .t.)

	endIf

endIf

// Identifica codigo do produto a ser posicionado                      
if ! empty(BA1->BA1_CODPLA)
	cCodPro := BA1->BA1_CODPLA
	cVerPro := BA1->BA1_VERSAO
else
	cCodPro := BA3->BA3_CODPLA
	cVerPro := BA3->BA3_VERSAO
endIf

// Posiciona BI3-Produto Saude                                     
if xFilial("BI3") + BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO) <> BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO)
	BI3->( msSeek( xFilial("BI3") + BA3->BA3_CODINT + cCodPro + cVerPro ) )
endIf

// Posiciona BT6-Subcontrato - Contrato Pessoa Juridica                                       
if BA3->BA3_TIPOUS == "2" 
	BT6->( msSeek( xFilial("BT6") + BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO) ) )
endIf

// Verifica se tem o subcontrato informado no SE1                      
if ! empty( BM1->(BM1_CODINT+BM1_CODEMP+BM1_CONEMP+BM1_VERCON+BM1_SUBCON+BM1_VERSUB) )
	
	// Posiciona BQC-Subcontrato                                       
	if  xFilial("BQC") + BM1->(BM1_CODINT+BM1_CODEMP+BM1_CONEMP+BM1_VERCON+BM1_SUBCON+BM1_VERSUB) <> BQC->(BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)
		BQC->( msSeek( xFilial("BQC") + BM1->(BM1_CODINT+BM1_CODEMP+BM1_CONEMP+BM1_VERCON+BM1_SUBCON+BM1_VERSUB) ) )
	endIf
	
endIf

// Posiciona BHT-Cadastro Parametros Produto x Contabilidade (Produto Saude / Alterar / Parametros Contabilizacao)     
//   Obs: o campo CODIGO na chave do BHT = Operadora+Produto           
if xFilial("BHT") + BM1->(BM1_CODINT) + cCodPro + BM1->(BM1_CODTIP) <> BHT->(BHT_FILIAL+BHT_CODIGO+BHT_CODOCO)
	BHT->( msSeek( xFilial("BHT") + BM1->(BM1_CODINT) + cCodPro + BM1->(BM1_CODTIP) ) )
endIf

// Posiciona BSQ-Debito/Credito Cobranca  (Faturamento / Debitos/Creditos)                          
// Posiciona BSP-Cadastro Debitos/Creditos Cobranca (Faturamento / Tp Lanc Deb/Cred)                          
if BM1->BM1_ALIAS == "BSQ"

	if xFilial("BSQ") + substr( BM1->(BM1_ORIGEM), 1, nTam1) <> BSQ->(BSQ_FILIAL+BSQ_CODSEQ)
		BSQ->( msSeek( xFilial("BSQ") + substr( BM1->BM1_ORIGEM, 1, nTam1) ) )
	endIf
	
	if xFilial("BSP") + BSQ->BSQ_CODLAN <> BSP->(BSP_FILIAL+BSP_CODSER)
		BSP->( msSeek( xFilial("BSP") + BSQ->BSQ_CODLAN ) )
	endIf
	
else

	BSQ->(dbGoBottom())
	BSQ->(dbSkip())
	BSP->(dbGoBottom())
	BSP->(dbSkip())
	
endIf

// Verifica se eh opcional Opcionais/Termos Aditivos                           
if BM1->BM1_CODTIP == "102" 
	
	if  xFilial("BF4") + BM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG) + alltrim( BM1->(BM1_CODEVE) ) <> BF4->(BF4_FILIAL+BF4_CODINT+BF4_CODEMP+BF4_MATRIC+BF4_TIPREG+BF4_CODPRO)
		BF4->( msSeek( xFilial("BF4") + BM1->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG) + alltrim( BM1->(BM1_CODEVE) ) ) )
	endIf
	
else
	
	BF4->(dbGoBottom())
	BF4->(dbSkip())
	
endIf

//Posiciona na BTO
if xFilial('BTO') + BM1->(BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT) <> BTO->(BTO_FILIAL + BTO_PREFIX + BTO_NUMTIT + BTO_PARCEL + BTO_TIPTIT)
	BTO->( msSeek( xFilial('BTO') + BM1->(BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT) ) )
endIf

if existBlock("PLSCTBP1")
	execBlock("PLSCTBP1",.F.,.F.)
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

	case __nParTipCtb == LP_P9A1

		cDesc := LP_PROVISAO

	case __nParTipCtb == LP_P9A2

		cDesc := LP_PROVISAO_FA

	case __nParTipCtb == LP_P9AX9B6

		cDesc := LP_BAIXA+LP_CANCELA_BAIXA

	case __nParTipCtb == LP_P9NX9N6

		cDesc := LP_BAIXA_NB+LP_CANCELA_BAIXA_NB

	case __nParTipCtb == LP_P9LC

		cDesc := LP_PROVISAO_LA

	case __nParTipCtb == LP_P9LD

		cDesc := LP_PROVISAO_LAC

endCase

return cDesc

/*/{Protheus.doc} retMLP
Retorna msg da LP
@author TOTVS
@since 22/02/2019
/*/
static function retMLP(aPadrao, lRet)
local cMsg := ''

if __nParTipCtb == LP_P9A1

	cMsg := aPadrao[1,1]
	lRet := aPadrao[1,2]

elseIf __nParTipCtb == LP_P9A2

	cMsg := aPadrao[6,1]
	lRet := aPadrao[6,2]

elseIf __nParTipCtb == LP_P9AX9B6

	cMsg := aPadrao[2,1] + '/' + aPadrao[3,1]
	lRet := ( aPadrao[2,2] .and. aPadrao[3,2] )

elseIf __nParTipCtb == LP_P9NX9N6

	cMsg := aPadrao[4,1] + '/' + aPadrao[5,1]
	lRet := ( aPadrao[4,2] .and. aPadrao[5,2] )

elseIf __nParTipCtb == LP_P9LC

	cMsg := aPadrao[7,1]
	lRet := aPadrao[7,2]

elseIf __nParTipCtb == LP_P9LD

	cMsg := aPadrao[8,1]
	lRet := aPadrao[8,2]

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
local bOK       := {|| iIf( vldConf(__cParMes,__cParAno, __dParDtIni, __dParDtFim), processa( {|lEnd| PLINFDAD() }, STR0004, STR0006), nOpca := 0 ) } //"Aguarde" ##"Gerando Contabilização de Receitas"
local bCancel   := {|| oDlg:end() }
local oDlg		:= nil
local oGroup1	:= nil
local oGroup2	:= nil
local oGroup3	:= nil
local oRadio1	:= nil
local oRadio2	:= nil
local oCheck1	:= nil
local oCheck2	:= nil
local oGetMes	:= nil
local oGetAno	:= nil
local oGetIni	:= nil
local oGetFim	:= nil
local lDtDisP	:= FK1->( fieldPos("FK1_DTDISP") ) > 0
local lPeriod	:= .f.
local lAnoMes	:= .t.

local ndLinIni	:= 180
local ndColIni 	:= 180
local ndLinFin	:= 510
local ndColFin	:= 825

local nLinS		:= 22
local nLinG		:= 22
local nColS		:= 01
local nColG		:= 01
local aItems 	:= {}
local aProDis	:= {}

__cParMes	  := iIf( len(aParamAUTO) > 0, aParamAUTO[1], strZero(month(date()),2) )
__cParAno	  := iIf( len(aParamAUTO) > 0, aParamAUTO[2], cValToChar(year(date())) )
__dParDtIni	  := iIf( len(aParamAUTO) > 0, aParamAUTO[3], cTod('') )
__dParDtFim	  := iIf( len(aParamAUTO) > 0, aParamAUTO[4], cTod('') )
__cParCliDe	  := iIf( len(aParamAUTO) > 0, aParamAUTO[5], space(6) )
__cParCliAte  := iIf( len(aParamAUTO) > 0, aParamAUTO[6], space(6) )

__nParTipCtb  := iIf( len(aParamAUTO) > 0, aParamAUTO[7], 1 )

__lParChkALC  := iIf( len(aParamAUTO) > 0, aParamAUTO[8], .f. )
__nParChkMTGR := iIf( len(aParamAUTO) > 0, aParamAUTO[9], 1 )
__lParDtDisp  := iIf( len(aParamAUTO) > 0, aParamAUTO[10], .f. )
__lLoteAviso  := FWAliasInDic("B6S") .and. lUnimed .and. B6S->( fieldPos("B6S_DTEMIS") ) > 0 

if lAutoStt
	
	PLINFDAD()
	
	return(.t.)

endIf

//nao deve alterar esta ordem sem alterar os DEFINES 
//LP_P9A1, LP_P9A2, LP_P9AX9B6, LP_P9NX9N6, LP_P9LC, LP_P9LD
aadd(aItems, LP_PROVISAO +'/'+LP_RATEIO + STR0052 + 'e Rateio de Imp.' ) //' - Composição da Cobrança.'
aadd(aItems, LP_BAIXA    + '/' + LP_CANCELA_BAIXA + "/" + LP_RATEIO_BAIXA + "/" + LP_RATEIO_CANCBX + STR0053) //' - Baixa e Cancelamento. (Mov. Banco)'
aadd(aItems, LP_BAIXA_NB + '/' + LP_CANCELA_BAIXA_NB + "/" + LP_RATEIO_BAIXA_NB + "/" + LP_RATEIO_CANCBX_NB + STR0054) //' - Baixa e Cancelamento. (Não Mov. Banco)'
aadd(aItems, LP_PROVISAO_FA + STR0065 ) //' - Faturamento Antecipado (Rev/Prov).'

if __lLoteAviso
	aadd(aItems, LP_PROVISAO_LA + STR0078)//' - Lote de Aviso.'
	aadd(aItems, LP_PROVISAO_LAC + STR0079)//' - Lote de Aviso Cobrado.'
endIf

aadd(aItems, LP_REC_ANTECIPADA+"/"+LP_REC_PRORATA+STR0083) // " - Receita sob Receb. Antecipado ou Pro-Rata"

aadd(aProDis, STR0071)//'Normal.'
aadd(aProDis, STR0072)//'Multi Thread.'

//verifica se tem a configuracao de grid no ini
if upper( getPvProfString( "gridserver", "main", "NIL", getADV97() ) ) == 'GRIDSERVER'
	aadd(aProDis, STR0073) //'Grid.'
endIf	

//Definicao de tela
DEFINE MSDIALOG oDlg FROM ndLinIni,ndColIni TO ndLinFin,ndColFin PIXEL TITLE STR0001 //"Contabilização Off-line de Receita"

	@ (nLinS += 10), (nColS += 00) SAY OEMTOANSI(STR0055) PIXEL of oDlg //'Mês.'
	@ (nLinG += 17), (nColG += 00) MSGet oGetMes VAR __cParMes SIZE 30,10 OF oDlg PIXEL PICTURE "99" VALID ( fVldDt(1, @lAnoMes, @lPeriod) ) WHEN lAnoMes

	@ (nLinS += 00), (nColS += 40) SAY OEMTOANSI(STR0056) PIXEL of oDlg //'Ano Competência.'
	@ (nLinG += 00), (nColG += 40) MSGet oGetAno VAR __cParAno SIZE 40,10 OF oDlg PIXEL PICTURE "9999"  VALID ( fVldDt(1, @lAnoMes, @lPeriod) ) WHEN lAnoMes

	@ (nLinS += 00), (nColS += 50) SAY OEMTOANSI(STR0076) PIXEL of oDlg //'Data Inicio'
	@ (nLinG += 00), (nColG += 50) MSGet oGetIni VAR __dParDtIni SIZE 40,10 OF oDlg PIXEL PICTURE "99/99/9999" VALID ( fVldDt(2, @lAnoMes, @lPeriod) ) WHEN ( lPeriod .and. (__nParTipCtb != LP_P9A2) )

	@ (nLinS += 00), (nColS += 50) SAY OEMTOANSI(STR0077) PIXEL of oDlg //'Data Fim'
	@ (nLinG += 00), (nColG += 50) MSGet oGetFim VAR __dParDtFim SIZE 40,10 OF oDlg PIXEL PICTURE "99/99/9999" VALID ( fVldDt(2, @lAnoMes, @lPeriod) ) WHEN ( lPeriod .and. (__nParTipCtb != LP_P9A2) )

	@ (nLinS += 00), (nColS += 50) SAY OEMTOANSI(STR0066) PIXEL of oDlg //'Cliente De.'
	@ (nLinG += 00), (nColG += 50) MSGet __cParCliDe SIZE 40,10 OF oDlg PIXEL PICTURE "!!!!!!"  F3 "SA1CLI" WHEN (__nParTipCtb != LP_P9LC .and. __nParTipCtb != LP_P9LD)

	@ (nLinS += 00), (nColS += 50) SAY OEMTOANSI(STR0067) PIXEL of oDlg //'Cliente Até.'
	@ (nLinG += 00), (nColG += 50) MSGet __cParCliAte SIZE 40,10 OF oDlg PIXEL PICTURE "!!!!!!"  F3 "SA1CLI" WHEN (__nParTipCtb != LP_P9LC .and. __nParTipCtb != LP_P9LD)

	nColS := 01
	nColG := 01

	oGroup1	:= TGroup():new( (nLinS += 22), (nColS += 00), 110, 150, STR0057, oDlg,,,.T.) //'Opções'
   	oCheck1 := TCheckBox():new( (nLinG += 25), (nColG += 04), STR0058, { |u| iIf( PCount() == 0, __lParChkALC, __lParChkALC := u ) }, oGroup1,150,210,,,,,,,,.T.,,,) //'Aglutina Lançamento Contabíl?'
	
	if lDtDisP
   		oCheck2 := TCheckBox():new( (nLinG += 10), (nColG += 00), STR0061, { |u| iIf( PCount() == 0, __lParDtDisp, __lParDtDisp := u ) }, oGroup1,150,210,,,,,,,,.T.,,,) //'Baixa pela data da Disponibilizade?'
	endIf	   

	oGroup2	:= TGroup():new( (nLinS += 00), (nColS += 155), 160, 323, STR0062, oDlg,,,.T.) //'Contabilizar?'
  	oRadio1 := TRadMenu():new( (nLinS += 07), (nColS += 04), aItems,,oGroup2,,,,,,,,160,12,,,,.t.)
	  
  	oRadio1:bSetGet := { |u| iIf( PCount() == 0, __nParTipCtb, __nParTipCtb := u ) }
	oRadio1:bChange := { || fVldDt( iIf(__nParTipCtb == LP_P9A2, 3, 4), @lAnoMes, @lPeriod, oGetIni, oGetFim, oGetMes, oGetAno), fVldBX(@__lParDtDisp, __nParTipCtb, oCheck2) }

	nColS := 01
	nColG := 01

	oGroup3	:= TGroup():new( (nLinS += 50), (nColS += 00), 160, 150, STR0070, oDlg,,,.T.)//'Processamento'
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

local lRet := (__nParTipCtb == 2 .or. __nParTipCtb == 3)

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
static function fVldDt(nTp, lAnoMes, lPeriod, oGetIni, oGetFim, oGetMes, oGetAno)

if ( empty(__cParMes) .and. empty(__cParAno) .and. empty(__dParDtIni) .and. empty(__dParDtFim) )
	
	lAnoMes	:= .t.
	lPeriod	:= .t.

else

	if nTp == 1

		__dParDtIni := ctod('')
		__dParDtFim := ctod('')

		lAnoMes		:= ! (empty(__cParMes) .and. empty(__cParAno))
		lPeriod		:= empty(__cParMes) .and. empty(__cParAno)
		
	elseIf nTp == 2
		
		__cParMes	:= space(2)
		__cParAno	:= space(4)
		lAnoMes		:= empty(__dParDtIni) .and. empty(__dParDtFim)
		lPeriod		:= ! (empty(__dParDtIni) .and. empty(__dParDtFim))

	elseIf nTp == 3

		lAnoMes		:= .t.
		lPeriod		:= .f.
		__dParDtIni := ctod('')
		__dParDtFim := ctod('')

	endIf

	if nTp == 3 .or. nTp == 4

		if oGetIni <> nil
			oGetIni:refresh()
		endIf

		if oGetFim <> nil	
			oGetFim:refresh()
		endIf	

		if oGetMes <> nil	
			oGetMes:refresh()
		endIf
		
		if oGetAno <> nil	
			oGetAno:refresh()
		endIf
		
	endIf

endIf

return(.t.)

/*/{Protheus.doc} vldConf
validacao confirma

@author PLSTEAM
@since 25/02/2019
@version P11
/*/
static function vldConf(__cParMes, __cParAno, __dParDtIni, __dParDtFim)
local lRet := .f.

do case

	case empty(__cParMes) .and. ( empty(__dParDtIni) .and. empty(__dParDtFim) )
		
		aviso(STR0007, STR0063, {"Ok"}) //"Atenção" ## 'Informe o Mês!'

	case empty(__cParAno) .and. ( empty(__dParDtIni) .and. empty(__dParDtFim) )
		
		aviso(STR0007, STR0064, {"Ok"}) //"Atenção" ## 'Informe o Ano!'

	case empty(__dParDtIni) .and. ( empty(__cParMes) .and. empty(__cParAno) )
		
		aviso(STR0008,STR0074,{"Ok"}) //"Atenção" ## 'Informe a Data Inicio!'

	case empty(__dParDtFim) .and. ( empty(__cParMes) .and. empty(__cParAno) )
		
		aviso(STR0008,STR0075,{"Ok"}) //"Atenção" ## 'Informe a Data Fim!'

	otherWise
	
		lRet := .t.

endCase


return(lRet)

//função apra pasagem de parâmetros na automação
function PLCT11Par(aPar)
	setPar11(aPar)
return

Static function getPar11()
return aParamAUTO

static function setPar11(aPar)
aParamAUTO := aclone(aPar)
return

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsContRat
Contabilização do Rateio - Lançamento Padrão 9A3/9NA/9AA/9N7/9B7

@author Robson Nayland/Vinicius Queiros Teixeira
@since 04/02/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function PlsContRat(cLote, cThReadID, cLPRateio, cSeqBaixa, dDtMovimento)

	Local cAliasTrb	:= GetNextAlias()
	Local cQuery := ""
	Local cArquivo := ""	
	Local lCabecalho := .F.	
	Local lMostraLC := .F.
	Local nHdlPrv := 0
	Local nTotLanc := 0
	Local aCT5 := {}
	Local aFlagCTB := {}
	Local aFlagPLS := {}
	Local lCancelamento := .F.
	Local lNovosCampos := B6U->(FieldPos("B6U_SEQBAI")) > 0 .And. B6U->(FieldPos("B6U_LA_CAN")) > 0

	Default cLote := ""
	Default dDtMovimento := dDataBase

	//Procura os Lançametos do rateio na tabela B6U
	cQuery := " SELECT B6U.R_E_C_N_O_ RECNOB6U FROM " + RetSQLName("B6U") + " B6U "
	cQuery += " WHERE B6U.B6U_FILIAL = '" + xFilial("B6U") + "'"
	cQuery += "	  AND B6U.B6U_PREFIX = '" + SE1->E1_PREFIXO + "'"
	cQuery += "	  AND B6U.B6U_NUMTIT = '" + SE1->E1_NUM + "'"
	cQuery += "	  AND B6U.B6U_PARCEL = '" + SE1->E1_PARCELA + "'"
	cQuery += "	  AND B6U.B6U_TIPTIT = '" + SE1->E1_TIPO + "'"

	Do Case
		Case cLPRateio == LP_RATEIO
			cQuery += "	AND B6U.B6U_IMPOST IN ('IRF','PIS','COFINS','CSLL')"
		Case cLPRateio $ LP_RATEIO_BAIXA+"/"+LP_RATEIO_CANCBX  // Movimenta Banco
			cQuery += "	AND B6U.B6U_IMPOST = 'BAIXA-TIT' "
		Case cLPRateio $ LP_RATEIO_BAIXA_NB+"/"+LP_RATEIO_CANCBX_NB  // Não movimenta Banco
			cQuery += "	AND (B6U.B6U_IMPOST = 'BAIXA-NCC' OR B6U.B6U_IMPOST = 'BAIXA-TIT') "
	EndCase	
	
	Do Case
		Case cLPRateio == LP_RATEIO
			cQuery += "	AND B6U.B6U_LA = ' ' "

		Case cLPRateio $ LP_RATEIO_BAIXA+"/"+LP_RATEIO_BAIXA_NB // Baixas 
			If lNovosCampos
				cQuery += " AND B6U_SEQBAI = '"+cSeqBaixa+"' "
			EndIf
			cQuery += "	AND B6U.B6U_LA = ' ' "

		Case cLPRateio $ LP_RATEIO_CANCBX+"/"+LP_RATEIO_CANCBX_NB // Cancelamentos
			If lNovosCampos
				cQuery += " AND B6U_SEQBAI = '"+cSeqBaixa+"' " 
				cQuery += "	AND B6U.B6U_LA_CAN = ' ' "
			EndIf
			lCancelamento := .T.
	EndCase

	cQuery += " AND B6U.D_E_L_E_T_= ' ' "

	DbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAliasTrb,.F.,.T.)
	
  	While (cAliasTrb)->(!Eof())
		B6U->(MsGoTo((cAliasTrb)->RECNOB6U))

		If SE1->(DbSeek(xFilial("SE1")+B6U->(B6U_PREFIX+B6U_NUMTIT+B6U_PARCELA+B6U_TIPTIT)))

			nChaveTIT := (cAliasTrb)->RECNOB6U
			cCondic := cAliasTrb + "->RECNOB6U"
			If !lCabecalho
				PLSCTBCABEC(@nHdlPrv, @cArquivo, .f., @lCabecalho, CTBPLSROT, cLote)
			EndIf	

			If Alias() <> "B6U"
				DbSelectArea("B6U")
			EndIf

			nValAux := detProva( nHdlPrv, cLPRateio, CTBPLSROT, cLote,,,,,, aCT5,,, PLSRACTL(cLPRateio) )
			nTotLanc += nValAux
			If Empty(cArquivo)
				cArquivo := getHFile()
			EndIf
			If cLPRateio == LP_RATEIO_CANCBX .Or. cLPRateio == LP_RATEIO_CANCBX_NB
				dDtLote := dDtMovimento
			Else 
				dDtLote := B6U->B6U_DTEMIS
			EndIf
			
			PLSMONFLAG( @aFlagPLS, LP_DLRAT,  cLPRateio, (nValAux > 0))
			//mudou a chave finaliza os lancamentos
			If lCabecalho 
				lanceiCTB := ( len(aFlagCTB) > 0 )
				PLSCA100(@cArquivo, @nHdlPrv, cLote, @nTotLanc, @lCabecalho, @aFlagPLS, dDtLote, lMostraLC, __lParChkALC, cLPRateio, LP_DLRAT, cThReadID, CTBPLSROT, @aFlagCTB)
			EndIf
		Endif	
		(cAliasTrb)->(DbSkip())
  	Enddo

	(cAliasTrb)->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCTBRecF
Verificação de Reconhecimento de Receita sobre recebimento adiantado
é a Apropriação de Pro-Rata

@author Vinicius Queiros Teixeira
@since 24/06/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function PLSCTBRecF()

	Local lRetorno := .F.
	Local cAliasTrb	:= ""
	Local cQuery := ""
	Local cArquivo := ""	
	Local lCabecalho := .F.	
	Local lMostraLC := .F.
	Local nHdlPrv := 0
	Local nTotLanc := 0
	Local nValLanc := 0
	Local aCT5 := {}
	Local aFlagCTB := {}
	Local aFlagPLS := {}
	Local cLote := ""
	Local cContaCredit := ""
	Local cLPRecReceita := ""
	Local cChvCTDoc := ""
	Local dDataProc := Stod(__cParAno + __cParMes + '01')
	Local dDataDe := DtoS(FirstDate(dDataProc))
	Local cCtaReceitas := RetCtaReferencial("3111")
	Local cCtaAntecipada := RetCtaReferencial("2132")
	Local cCtaProvisao := RetCtaReferencial("2111")
	Local cBancoAmbiente := Alltrim(Upper(TcGetDb()))

	cQuery += "SELECT DISTINCT CT2.CT2_DATA, CT2.CT2_LOTE, CT2.CT2_SBLOTE, CT2.CT2_DOC, CT2.CT2_LINHA, CT2.CT2_DEBITO, CT2.CT2_CREDIT, CT2.CT2_VALOR, "
	cQuery += "                CT2.R_E_C_N_O_ RECNOCT2, CV3LCT.R_E_C_N_O_ RECNOCV3, CV3LCT.CV3_RECDES "
	cQuery += "FROM " + RetSqlName("CT2") + " CT2 "

	cQuery += "INNER JOIN " + RetSqlName("CV3") + " CV3 "
	cQuery += "     ON CV3.CV3_FILIAL = '"+xFilial("CV3")+"' "

	If cBancoAmbiente $ "ORACLE/DB2/INFORMIX"
		cQuery += " AND NVL(TO_NUMBER(TRIM(CV3.CV3_RECDES)),0) = CT2.R_E_C_N_O_ "
	ElseIf cBancoAmbiente == "POSTGRES"
		cQuery += " AND COALESCE(CAST(TRIM(CV3.CV3_RECDES) AS INT),0) = CT2.R_E_C_N_O_ "
	Else
		cQuery += " AND CONVERT(Int,CV3.CV3_RECDES) = CT2.R_E_C_N_O_ "
	Endif
	cQuery += "    AND CV3.D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + RetSqlName("CV3") + " CV3LCT "
	cQuery += "     ON CV3LCT.CV3_FILIAL = '"+xFilial("CV3")+"' "
	cQuery += "    AND CV3LCT.CV3_DTSEQ = CV3.CV3_DTSEQ " 
	cQuery += "    AND CV3LCT.CV3_SEQUEN = CV3.CV3_SEQUEN "

	If !Empty(cCtaReceitas)
		cQuery += " AND (CV3LCT.CV3_CREDIT LIKE '3111%' OR CV3LCT.CV3_CREDIT IN ("+cCtaReceitas+")) "
	Else
		cQuery += " AND CV3LCT.CV3_CREDIT LIKE '3111%' "
	EndIf
	cQuery += "    AND CV3LCT.D_E_L_E_T_ = ' ' "

	cQuery += "WHERE CT2_FILIAL = '" + xFilial("CT2") + "'"
	cQuery += "  AND CT2_DATA <= '" + dDataDe + "'"
	cQuery += "  AND CT2_DATA >= '" + RetDateAnt(__cParAno, __cParMes) + "'"
	cQuery += "  AND ("

	If !Empty(cCtaAntecipada)
		cQuery += " (CT2_CREDIT LIKE '2132%' OR CT2_CREDIT IN ("+cCtaAntecipada+")) "
	Else
		cQuery += " CT2_CREDIT LIKE '2132%'"
	EndIf
	cQuery += " OR "

	If !Empty(cCtaProvisao)
		cQuery += " (CT2_CREDIT LIKE '2111%' OR CT2_CREDIT IN ("+cCtaProvisao+")) "
	Else
		cQuery += " CT2_CREDIT LIKE '2111%'"
	EndIf
	cQuery += ")"
	cQuery += "  AND CT2.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC"

	cAliasTrb := GetNextAlias()
	DbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasTrb, .F., .T.)

	While !((cAliasTrb)->(EoF()))

		CT2->(MsGoTo((cAliasTrb)->RECNOCT2)) 
		CV3->(MsGoTo((cAliasTrb)->RECNOCV3))
		
		cChvCTDoc := Alltrim(CT2->(DToS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC))
		cLote := CT2->CT2_LOTE
		cContaCredit := CT2->CT2_CREDIT

		If ChkRegProcessado(cChvCTDoc)
			(cAliasTrb)->(DbSkip())
			Loop
		EndIf

		Do Case
			Case VldCtaReferencial(cContaCredit, "2111") // Provisão de Prêmio (Pro-Rata)
				If CT2->CT2_VALOR == CV3->CV3_VLR01
					(cAliasTrb)->(DbSkip())
					Loop
				Else
					cLPRecReceita := LP_REC_PRORATA
				EndIf 
			
			Case VldCtaReferencial(cContaCredit, "2132") // Receita Antecipada
				cLPRecReceita := LP_REC_ANTECIPADA
			
			OtherWise
				(cAliasTrb)->(DbSkip())
				Loop
		EndCase

		If !lCabecalho
			PLSCTBCABEC(@nHdlPrv, @cArquivo, .F., @lCabecalho, CTBPLSROT, cLote)
		EndIf	

		nValLanc := detProva(nHdlPrv, cLPRecReceita, CTBPLSROT, cLote,,,,,, aCT5,,, PLSRACTL(cLPRecReceita) )
		nTotLanc += nValLanc
		If Empty(cArquivo)
			cArquivo := getHFile()
		EndIf

		dDtLote := (CT2->CT2_DATA) + 30		

		If lCabecalho 
			lanceiCTB := (Len(aFlagCTB) > 0)
			PLSCA100(@cArquivo, @nHdlPrv, cLote, @nTotLanc, @lCabecalho, @aFlagPLS, dDtLote, lMostraLC, __lParChkALC, cLPRecReceita, 0, "", CTBPLSROT, @aFlagCTB)
		EndIf

		lRetorno := .T.
		(cAliasTrb)->(DbSkip())
	EndDo

	(cAliasTrb)->(DbCloseArea())

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} ChkRegProcessado
Verifica se a regra já foi processada para esse registro

@author Vinicius Queiros Teixeira
@since 24/06/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function ChkRegProcessado(cChvCTDoc)

	Local lExiste := .F.
	Local cQuery := ""
	Local nQuant := 0

	cQuery += " SELECT COUNT(CT2.CT2_DOC) CONTADOR FROM " + RetSqlName("CT2") + " CT2 "
	cQuery += " WHERE CT2.CT2_FILIAL = '" + xFilial("CT2") + "'"
	cQuery += "   AND (CT2.CT2_LP = '"+LP_REC_ANTECIPADA+"' OR CT2.CT2_LP = '"+LP_REC_PRORATA+"')"
	cQuery += "   AND CT2.CT2_ORIGEM = '"+cChvCTDoc+Space(TamSX3("CT2_ORIGEM")[1] - Len(cChvCTDoc))+"'"
	cQuery += "   AND CT2.D_E_L_E_T_ = ' ' "

	nQuant := MPSysExecScalar(cQuery, "CONTADOR")

	If nQuant > 0
		lExiste := .T.
	Else
		lExiste := .F.
	EndIf

Return lExiste


//-------------------------------------------------------------------
/*/{Protheus.doc} RetDateAnt
Retorna a data referente ao mês anterior do processamento

@author Vinicius Queiros teixeira
@since 24/06/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function RetDateAnt(cAnoPar, cMesPar)

	Local cMesAnt := ""
	Local cAnoAnt := ""
	Local cRet := ""

	If cMesPar == "01"
		cMesAnt := "12"
		cAnoAnt := StrZero(Val(cAnoPar) - 1, 4)
	Else
		cMesAnt := StrZero(Val(cMesPar) - 1, 2)
		cAnoAnt := cAnoPar
	EndIf

	cRet := cAnoAnt + cMesAnt + '01'

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} RetCtaReferencial
Retorna as contas referente ao plano de contas referencial

@author Vinicius Queiros Teixeira
@since 23/06/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function RetCtaReferencial(cCtaBusca)

	Local cContas := ""
	Local cQuery := ""
	Local cAliasTmp := ""

	Default cCtaBusca := ""

	cQuery := "SELECT CT1.CT1_CONTA FROM "+RetSqlName("CVD")+" CVD"
	cQuery += "  INNER JOIN "+RetSqlName("CT1")+" CT1"
	cQuery += "		ON CT1.CT1_FILIAL = '"+xFilial("CT1")+"'"
	cQuery += "    AND CT1.CT1_CONTA = CVD.CVD_CONTA"
	cQuery += "    AND CT1.D_E_L_E_T_ = ' '"
	cQuery += "  WHERE CVD.CVD_FILIAL = '"+xFilial("CVD")+"'" 
	cQuery += "    AND CVD.CVD_CTAREF LIKE '"+cCtaBusca+"%'"
	cQuery += "    AND CVD.D_E_L_E_T_ = ' '"

	cAliasTmp := GetNextAlias()
	dbUseArea(.t.,"TOPCONN", tcGenQry(,,cQuery), cAliasTmp, .F., .T.)

	While !((cAliasTmp)->(EoF()))
		If Empty(cContas)
			cContas += "'"+Alltrim((cAliasTmp)->CT1_CONTA)+"'"
		Else
			cContas += ",'"+Alltrim((cAliasTmp)->CT1_CONTA)+"'"
		EndIf

		(cAliasTmp)->(DbSkip())
	EndDo

	(cAliasTmp)->(DbCloseArea())

Return cContas


//-------------------------------------------------------------------
/*/{Protheus.doc} VldCtaReferencial
Valida Conta informado de acordo com o plano de contas referencial

@author Vinicius Queiros Teixeira
@since 24/06/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function VldCtaReferencial(cContaBusca, cTipoConta)

	Local lExiste := .F.
	Local cQuery := ""
	Local nQuant := 0

	If Substr(cContaBusca, 1, 4) == cTipoConta
		lExiste := .T.
		Return lExiste
	EndIf

	cQuery := "SELECT COUNT(CVD.CVD_CTAREF) CONTADOR FROM "+RetSqlName("CVD")+" CVD"
	cQuery += "  INNER JOIN "+RetSqlName("CT1")+" CT1"
	cQuery += "		ON CT1.CT1_FILIAL = '"+xFilial("CT1")+"'"
	cQuery += "    AND CT1.CT1_CONTA = '"+cContaBusca+"'"
	cQuery += "    AND CT1.D_E_L_E_T_ = ' '"
	cQuery += "  WHERE CVD.CVD_FILIAL = '"+xFilial("CVD")+"'" 
	cQuery += "    AND CVD.CVD_CTAREF LIKE '"+cTipoConta+"%'"
	cQuery += "    AND CVD.D_E_L_E_T_ = ' '"

	nQuant := MPSysExecScalar(cQuery, "CONTADOR")

	If nQuant > 0
		lExiste := .T.
	Else
		lExiste := .F.
	EndIf

Return lExiste


//-------------------------------------------------------------------
/*/{Protheus.doc} PLPerRecPR
Retorno valor referente as dias utilizados com base na data de inclusão
e data de cobrança 

@author Vinicius Queiros Teixeira
@since 25/06/2021
@version Protheus 12
@Obs Utilizado no calculo do valor da LP 9A5.
/*/
//-------------------------------------------------------------------
Function PLPerRecPR(dDtInclusao, dDtCobranca, nValor, lConsidDia)

	Local nVlrUtilizado := 0
    Local nPercDias := 0
    Local nDiasMes := 0
    Local nDiaInclusao := 0

    Default dDtInclusao := CToD(" / / ")
    Default dDtCobranca := CToD(" / / ")
    Default nValor := 0
    Default lConsidDia := .F.

    If !Empty(dDtInclusao) .And. !Empty(dDtCobranca) 
        
        nDiaInclusao := Day(dDtInclusao)

        If lConsidDia
            nDiaInclusao := nDiaInclusao - 1    
        EndIf

        nDiasMes := Day(LastDay(dDtCobranca))   

        if nDiasMes > nDiaInclusao
            nPercDias := (nDiaInclusao * 100) / nDiasMes
            nVlrUtilizado := (nValor * (100 - nPercDias)) / 100 
        else
            nVlrUtilizado := nValor / nDiasMes
        endif
        
    EndIf


Return nVlrUtilizado


//-------------------------------------------------------------------
/*/{Protheus.doc} PLPRSaldo
Calculo o saldo do Pro-rata no Lançamento Padrão 9A5 de acordo com o 
valor da provisão menos o valor da receita da compentencia anterior

@author Vinicius Queiros Teixeira
@since 29/06/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLPRSaldo(nVlrProvisao, cRecnoReceita)

	Local nSaldo := 0
	Local aAreaCT2 := CT2->(GetArea())

	Default nVlrProvisao := 0
	Default cRecnoDest := ""

	If !Empty(cRecnoReceita)
		CT2->(MsGoTo(Val(cRecnoReceita)))
		nSaldo := nVlrProvisao - CT2->CT2_VALOR  
	EndIf

	RestArea(aAreaCT2)

Return nSaldo
