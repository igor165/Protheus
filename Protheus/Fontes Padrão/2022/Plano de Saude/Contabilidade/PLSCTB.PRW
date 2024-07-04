#include "PLSMGER.CH"
#include "PROTHEUS.CH"

/*/{Protheus.doc} PLRETVLRTOT
@description Retorna valor total da negociação e valor total recebido da negociação
@author Fábio Siqueira dos Santos
@since 01/11/2016
@version P12
@return Retorna valor total da negociação e valor total recebido da negociação
/*/
Function PLRETVLRTOT(cChave,dData)
Local nVlrRec	:= 0
Local nVlrTot	:= 0
Default dData	:= dDataBase

//está posicionado no BM1, buscar o título principal 
//caso encontre o título, verificar todos os filhos e somar os valores dos títulos em aberto                                                                                
FI7->(DbSetOrder(1))//FI7_FILIAL+FI7_PRFORI+FI7_NUMORI+FI7_PARORI+FI7_TIPORI+FI7_CLIORI+FI7_LOJORI

If FI7->(DbSeek(xFilial("FI7")+cChave))
	
	SE1->(DbSetOrder(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                              
	
	While !FI7->(Eof()) .And. FI7->(FI7_FILIAL+FI7_PRFORI+FI7_NUMORI+FI7_PARORI+FI7_TIPORI) == xFilial("FI7")+cChave
		SE1->(DbSeek(xFilial("SE1")+FI7->(FI7_CLIDES+FI7_LOJDES+FI7_PRFDES+FI7_NUMDES+FI7_PARDES+FI7_TIPDES)))
		nVlrRec += ( SE1->E1_VALOR - SaldoTit( FI7->FI7_PRFDES, FI7->FI7_NUMDES, FI7->FI7_PARDES, FI7->FI7_TIPDES, , 'R', FI7->FI7_CLIDES, 1, dDataBase, dData, FI7->FI7_LOJDES, xFilial('SE1') ) )
		nVlrTot += SE1->E1_VALOR
		FI7->(DbSkip())
	EndDo
	
Else
	
	SE1->(DbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                              
	SE1->(DbSeek(xFilial("SE1")+cChave))
	nVlrRec	+= ( SE1->E1_VALOR - SaldoTit( FI7->FI7_PRFDES, FI7->FI7_NUMDES, FI7->FI7_PARDES, FI7->FI7_TIPDES, , 'R', FI7->FI7_CLIDES, 1, dDataBase, dData, FI7->FI7_LOJDES, xFilial('SE1') ) )
	nVlrTot += SE1->E1_VALOR
	
EndIf

Return ({nVlrRec, nVlrTot})

/*/{Protheus.doc} PLRETVLREC

@description Retorna valor a receber do título negociado
@author Fábio Siqueira dos Santos
@since 01/11/2016
@version P12
@return Retorna valor a receber do título negociado

/*/
Function PLRETVLREC(cChave)
Local nVlrRec	:= 0

//está posicionado no BM1, buscar o título principal 
//caso encontre o título, verificar todos os filhos e somar os valores dos títulos em aberto
SE1->(DbSetOrder(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO  	                                                                                                                                                                               
FI7->(DbSetOrder(1))//FI7_FILIAL+FI7_PRFORI+FI7_NUMORI+FI7_PARORI+FI7_TIPORI+FI7_CLIORI+FI7_LOJORI

If FI7->(DbSeek(xFilial("FI7")+cChave))

	While !FI7->(Eof()) .And. FI7->(FI7_FILIAL+FI7_PRFORI+FI7_NUMORI+FI7_PARORI+FI7_TIPORI) == xFilial("FI7")+cChave

		SE1->(DbSeek(xFilial("SE1")+FI7->(FI7_CLIDES+FI7_LOJDES+FI7_PRFDES+FI7_NUMDES+FI7_PARDES+FI7_TIPDES)))
		If SE1->E1_SALDO > 0
			nVlrRec += SE1->E1_SALDO
		EndIf

		FI7->(DbSkip())
	EndDo

Else
	SE1->(DbSeek(xFilial("SE1")+cChave))
	nVlrRec := SE1->E1_SALDO	
EndIf

Return nVlrRec

/*/{Protheus.doc} PLVLDBLQCO
@description Valida bloqueio contábil
@author PLSTEAM
@since 09/09/2016
@version P12
@return Retorna .f. se estiver bloqueado e .t. se não
/*/
function PLVLDBLQCO(dData, aProcesso, lHelp, cHelp)
local lRet  := .t.
local nI    := 0
local cProc := ''

for nI := 1 to len(aProcesso)
    cProc += '/' + aProcesso[nI]
next

//A função CTBVALIDT retorna F se a data estiver bloqueada e T se não estiver
lRet := ctbValiDt(nil, dData ,lHelp, nil, nil, { "PLS000" + cProc }, cHelp)

return lRet  

/*
Voltamos com a função para não dar erro de NOFunc nas rotinas do backoffice para clientes que não usam o PLS
*/
Function PlsLp(cModo)
Return .F.

Function PlsCtbSe2
Return 0

/*/{Protheus.doc} PLRtDtCTB
Esta função retorna a data a ser utilizada como base para a função que verifica bloqueio contábil
Regra:
alteração com base na espeficicação abaixo:
http://tdn.totvs.com/display/PROT/ER_SAUPLS05-320_Bloqueio_Calendario_Contabil_Despesas
No RETORNO DE FASE:
O bloqueio do calendário contábil deve ter por base a data do BD7_DTDIGI, independente de ter havido contabilização da despesa bruta
Nas operações de MUDANÇA DE FASE/REVALORAÇÃO:
O bloqueio do calendário contábil deve ter por base a data do BD7_DTCTBF, independente de ter havido contabilização do custo
O funcionamento é desse jeito devido o bloqueio de calendário contábil ser um congelamento prévio da base, para que a contabilização do
período seja efetuada.
@author Oscar Zanin
@since 23/11/2018
@version P12
/*/
function PLRtDtCTB(cCodOpe, cCodLdp, cCodPeg, cNumero, lretFas)
local csql := ""
local dRet := stod("")

default cCodOpe := PLSINTPAD()
default cCodLdp := ""
default cCodPeg := ""
default cNumero := ""
default lretFas := .F.

If cCodLdp <> PLSRETLDP(4) .AND.  cCodLdp <> PLSRETLDP(9)

	cSql += " SELECT "
	
	If lretFas
		cSql += " BD7_DTDIGI DATACT " 
	else
		cSql += " BD7_DTCTBF DATACT "
	EndIf
	
	cSql += "  FROM " + RetSqlName("BD7") + " BD7 "
	cSql += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
	csql += "   AND BD7_CODOPE = '" + cCodOpe + "'  "
	
	If !(empty(cCodLdp))
		cSql += " AND BD7_CODLDP = '" + cCodLdp + "' "
	EndIf
	
	If !(empty(cCodPeg))
		cSql += " AND BD7_CODPEG = '" + cCodPeg + "' "
	EndIf
	
	If !(empty(cNumero))
		cSql += " AND BD7_NUMERO = '" + cNumero + "' "
	EndIf
	
	cSql += " AND D_E_L_E_T_ = ' ' "
	
	If lretFas
		cSql += " Order By BD7_DTDIGI DESC "
	else
		cSql += " Order By BD7_DTCTBF DESC "
	EndIf
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSQL),"DATPLCTB",.F.,.T.)
	
	If !(DATPLCTB->(EoF()))
		dRet := StoD(DATPLCTB->DATACT)
	EndIf
	
	DATPLCTB->(DbCloseArea())

EndIf

return dRet