#Include 'Protheus.ch'
#Include "topconn.ch"  
#Include "FWBROWSE.CH"


/*/{Protheus.doc} PLJBATUTISS
@description Schedule da rotina de atualização de status
@author PLSTEAM
@since 11/2018
@version P12
/*/
Function PLJBATUTISS(aJob)
local cCodEmp	:= aJob[1]
local cCodFil	:= aJob[2]

RpcSetEnv( cCodEmp, cCodFil , , ,'PLS', , )

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Execução da Tarefa de atualização de status TISS na BCI." , 0, 0, {})

PLJATUTISS()

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Execução Finalizada do JOB PLJBATUTISS!" , 0, 0, {})
 
Return()



/*/{Protheus.doc} PLJATUTISS
@description Rotina para atualizar o campo BCI_STTISS via query e schedule, já que temos várias formas de baixar um título no back-office, que não comunica tal baixa ao PLS. 
@author PLSTEAM
@since 11/2018
@Obs: aAtuDel - Como a query busca os pagamentos efetuados, precisamos checar na BCI as PEG Faturadas (4) e com Status TISS como Liberado para pagamento (3), além de verificar se já foi pago
algum valor do título (E2_VALOR <> E2_SALDO). 
Contudo, existe a opção de cancelar a baixa. Assim, caso o sistema já tenha atualizado como Pago, mas depois ocorra o cancelamento da baixa, precisamos verificar se existe PEG Faturada (4) e com
status TISS como Pagamento efetuado(6), mas que na SE2 o saldo seja igual ao valor total do título (E2_VALOR = E2_SALDO). 
Dessa forma, a query executa as duas etapas, ajustando o que é necessário.
@version P12
/*/
Function PLJATUTISS()
local aAtuDel	:= {{" <> ", "3", "6"}, {" = ", "6", "3"}}

local cSql		:= ""
local cAliBCI	:= RetSqlName("BCI")
local cAliBD7	:= RetSqlName("BD7")
local cAliSE2	:= RetSqlName("SE2")
local cFilBD7	:= xFilial("BD7")
local cFilBCI	:= xFilial("BCI")
local cCodOpe	:= PlsIntPad()
local cSql2	:= ""

local lAtuSt	:= getNewPar("MV_STATISS",.f.)
local lIntHat   := GetNewPar("MV_PLSHAT","0") == "1"

local nTamPre	:= TamSX3("E2_PREFIXO")[1]
local nTamNum	:= TamSX3("E2_NUM")[1]
local nTamPar	:= TamSX3("E2_PARCELA")[1]
local nTamTip	:= TamSX3("E2_TIPO")[1]
local nTamFor	:= TamSX3("E2_FORNECE")[1]
local nTamLoj	:= TamSX3("E2_LOJA")[1]
local nTamFil	:= TamSX3("BD7_FILIAL")[1]
local nCalTam	:= 0
local nJ		:= 0
local nRet		:= 0

Local aRec	:= {}

//A função só ira ser executada caso a Operadora opte em utilizar o status TISS.
if lAtuSt //Colocar o MV do HAT aqui pra ele executar a query independente do MV do STTISS
	for nJ := 1 to Len(aAtuDel) 
	
		cSql := " SELECT DISTINCT BCI.R_E_C_N_O_ REC FROM " + cAliBCI + " BCI "
		
		cSql += " INNER JOIN " + cAliBD7 + " BD7 "
		cSql += " ON BD7_FILIAL = '" + cFilBD7 + "' "
		cSql += " AND BD7_CODOPE = BCI_CODOPE "
		cSql += " AND BD7_CODLDP = BCI_CODLDP "
		cSql += " AND BD7_CODPEG = BCI_CODPEG "
		cSql += " AND BD7_NUMERO = ( SELECT MIN(BD7_NUMERO) FROM " + cAliBD7 + " BD72 "
		cSql += "							WHERE BD7_FILIAL = '" + cFilBD7 + "' "
		cSql += " 					  		AND BD7_CODOPE = BCI_CODOPE "
		cSql += " 					  		AND BD7_CODLDP = BCI_CODLDP "
		cSql += " 					  		AND BD7_CODPEG = BCI_CODPEG "
		cSql += " 					  		AND BD7_SITUAC = BCI_SITUAC "
		cSql += " 					  		AND BD7_FASE   = BCI_FASE   "
		cSql += " 					  		AND BD72.D_E_L_E_T_ = ' ')  "
		cSql += " AND BD7.D_E_L_E_T_ = ' ' "
		cSql += " AND BD7_CHKSE2 <> ' '    "
		
		cSql += " INNER JOIN " + cAliSE2 + " SE2 "
			cSql += " ON E2_FILIAL   = SUBSTRING( BD7_CHKSE2, 1               , " + STR(nTamFil) + ") " 
			
			nCalTam := 2 + nTamFil
			cSql += " AND E2_PREFIXO = SUBSTRING( BD7_CHKSE2, " + STR(nCalTam) + " , " + STR(nTamPre) + ") "
			
			nCalTam += 1 + nTamPre
			cSql += " AND E2_NUM     = SUBSTRING( BD7_CHKSE2, " + STR(nCalTam) + " , " + STR(nTamNum) + ") "
			
			nCalTam += 1 + nTamNum
			cSql += " AND E2_PARCELA = SUBSTRING( BD7_CHKSE2, " + STR(nCalTam) + " , " + STR(nTamPar) + ") "
			
			nCalTam += 1 + nTamPar
			cSql += " AND E2_TIPO    = SUBSTRING( BD7_CHKSE2, " + STR(nCalTam) + " , " + STR(nTamTip) + ") "
			
			nCalTam += 1 + nTamTip
			cSql += " AND E2_FORNECE = SUBSTRING( BD7_CHKSE2, " + STR(nCalTam) + " , " + STR(nTamFor) + ") "
			
			nCalTam += 1 + nTamFor
			cSql += " AND E2_LOJA    = SUBSTRING( BD7_CHKSE2, " + STR(nCalTam) + " , " + STR(nTamLoj) + ") "
		cSql += " AND SE2.D_E_L_E_T_ = ' ' "
		cSql += " AND E2_VALOR " + aAtuDel[nJ,1] + " E2_SALDO "
		
		cSql += " WHERE BCI_FILIAL = '" + cFilBCI + "' "
		cSql += "   AND BCI_CODOPE = '" + cCodOpe + "' "
		cSql += "   AND BCI_FASE   = '4' "
		cSql += "   AND BCI_STTISS = '" + aAtuDel[nJ,2] + "' "
		
		if nJ == 2  //limitar período para a query não retornar dados muito antigos de baixas. O padrão é 120 dias.
			cSql += "   AND BCI_DATREC >= '" + dtos(dDatabase-120) + "' "
		endif 
			
		cSql += "   AND BCI.D_E_L_E_T_ = ' ' "
		
		cSql := ChangeQuery(cSql)
	
		nCalTam := 0
		
		If lIntHat
			dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSQL),"HATxPLS",.F.,.T.)
			
			while !(HATxPLS->(EoF()))
				aadd(aRec, HATxPLS->(REC) )
				HATxPLS->(DbSkip())
			endDo
			
			HATxPLS->(dbcloseArea())
		endIf
		
		cSql2 += " UPDATE " + cAliBCI 
		cSql2 += " SET BCI_STTISS = '" + aAtuDel[nJ,3] + "' "
		cSql2 += " WHERE " 
		cSql2 += " BCI_FILIAL = '" + cFilBCI + "' AND "
		cSql2 += " R_E_C_N_O_ IN ( " + cSql + ") "
		
		nRet := TCSqlExec(cSql2)

		if nRet < 0
			FWLogMsg('WARN',, 'SIGAPLS', 'PLJATUTISS', '', '01','Erro na query de atualização:' + TCSQLError() , 0, 0, {})
		endif
		cSql	:= ""
		cSql2 	:= ""
		
	next
	
	For nJ := 1 to Len(aRec)

		BCI->(dbgoTo(aRec[nJ]))

		If lIntHat
			PLHATINTFAT(BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG)
		EndIf
		
	Next
endif

aRec	:= {}

Return