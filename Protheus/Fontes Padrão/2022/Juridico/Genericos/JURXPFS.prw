#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURXPFS
Funções utilizadas na integração entre os módulos SIGAJURI e SIGAPFS

@author Jorge Luis Branco Martins Junior
@since 12/07/17
@version 1.0
/*/
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} JurQtdProc
Retorna a quantidade de processos em andamento, abertos, encerrados
em um determinado período e também processos que foram abertos e já
encerrados neste período.

@param cDataIni   , caracter, Data inicial de extração. 
@param cDataFim   , caracter, Data final de extração. 
@param lAndamento , Lógico  , Indica se os processos em andamento no 
                              período serão considerados
@param lAbertos   , Lógico  , Indica se os processos abertos no 
                              período serão considerados
@param lEncerrados, Lógico  , Indica se os processos encerrados no 
                              período serão considerados
@param cContrato  , caracter, Código do Contrato para contagem de 
                              processos dos seus casos

@return nQtd      , numérico, Quantidade de processos vinculados 
                              aos casos do contrato indicado

@author  Jorge Luis Branco Martins Junior
@version P12 
@since   12/07/17
/*/
//-------------------------------------------------------------------
Function JurQtdProc( cDataIni, cDataFim, lAndamento, lAbertos, lEncerrados, cContrato )
Local nQtd := 0

    If lAndamento // Processos em andamento no período
        nQtd += JQtdAndam( cDataIni, cDataFim, cContrato )
    EndIf
    If lAbertos // Processos abertos no período
        nQtd += JQtdAberto( cDataIni, cDataFim, cContrato )
    EndIf
    If lEncerrados // Processos encerrados no período
        nQtd += JQtdEncer( cDataIni, cDataFim, cContrato )
    EndIf
    If lAbertos .OR. lEncerrados // Processos que abertos e já encerrados no período        
        nQtd += JQtdAbeEnc( cDataIni, cDataFim, cContrato )
    EndIf

Return nQtd

//-------------------------------------------------------------------
/*/{Protheus.doc} JQtdAndam
Retorna a quantidade de processos em andamento em um determinado 
período

@param cDataIni   , caracter, Data inicial de extração. 
@param cDataFim   , caracter, Data final de extração. 
@param cContrato  , caracter, Código do Contrato para contagem de 
                              processos dos seus casos

@return nQtd      , numérico, Quantidade de processos vinculados 
                              aos casos do contrato indicado

@author  Jorge Luis Branco Martins Junior
@version P12 
@since   13/07/17
/*/
//-------------------------------------------------------------------
Function JQtdAndam( cDataIni, cDataFim, cContrato )
Local nQtd     := 0
Local cQuery   := ""
Local cDtVazia := Space( TamSx3( 'NSZ_DTENCE')[1] )
Local cTemp    := GetNextAlias()

	cDataIni := JDate2Str(cDataIni)
	cDataFim := JDate2Str(cDataFim)

    cQuery := " SELECT COUNT(NSZ_COD) TOTAL "
    cQuery +=   " FROM " + RetSQLName("NSZ") + " NSZ "
  	cQuery +=     " INNER JOIN " + RetSQLName("NUT") + " NUT "
 	cQuery +=        " ON NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
 	cQuery +=       " AND NUT.NUT_CCONTR = '" + cContrato + "'"
    cQuery +=       " AND NSZ.NSZ_CCLIEN = NUT.NUT_CCLIEN "
    cQuery +=       " AND NSZ.NSZ_LCLIEN = NUT.NUT_CLOJA "
    cQuery +=       " AND NSZ.NSZ_NUMCAS = NUT.NUT_CCASO "
    cQuery +=       " AND NUT.D_E_L_E_T_ = ' ' "
    cQuery +=  " WHERE NSZ.NSZ_DTINCL < '" + cDataIni + "'"
 	cQuery +=    " AND (NSZ.NSZ_DTENCE = '" + cDtVazia + "' OR NSZ.NSZ_DTENCE > '" + cDataFim + "') "
 	cQuery +=    " AND NSZ.NSZ_FILIAL = '" + xFilial("NSZ") + "' "
 	cQuery +=    " AND NSZ.D_E_L_E_T_ = ' ' "
 
	cQuery := ChangeQuery( cQuery, .F. )  
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), cTemp, .T., .F. )  

    If !(cTemp)->(EOF())
        nQtd += (cTemp)->TOTAL
	EndIf
	
	(cTemp)->(DbCloseArea())

Return nQtd

//-------------------------------------------------------------------
/*/{Protheus.doc} JQtdAberto
Retorna a quantidade de processos abertos em um determinado período

@param cDataIni   , caracter, Data inicial de extração. 
@param cDataFim   , caracter, Data final de extração. 
@param cContrato  , caracter, Código do Contrato para contagem de 
                              processos dos seus casos

@return nQtd      , numérico, Quantidade de processos vinculados 
                              aos casos do contrato indicado

@author  Jorge Luis Branco Martins Junior
@version P12 
@since   13/07/17
/*/
//-------------------------------------------------------------------
Function JQtdAberto( cDataIni, cDataFim, cContrato )
	Local nQtd     := 0
    Local cQuery   := ""
    Local cDtVazia := Space( TamSx3( 'NSZ_DTENCE')[1] )
    Local cTemp    := GetNextAlias()

	cDataIni := JDate2Str(cDataIni)
	cDataFim := JDate2Str(cDataFim)

    cQuery := " SELECT COUNT(NSZ_COD) TOTAL "
    cQuery +=   " FROM " + RetSQLName("NSZ") + " NSZ "
  	cQuery +=     " INNER JOIN " + RetSQLName("NUT") + " NUT "
 	cQuery +=        " ON NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
 	cQuery +=       " AND NUT.NUT_CCONTR = '" + cContrato + "'"
    cQuery +=       " AND NSZ.NSZ_CCLIEN = NUT.NUT_CCLIEN "
    cQuery +=       " AND NSZ.NSZ_LCLIEN = NUT.NUT_CLOJA "
    cQuery +=       " AND NSZ.NSZ_NUMCAS = NUT.NUT_CCASO "
    cQuery +=       " AND NUT.D_E_L_E_T_ = ' ' "
    cQuery +=  " WHERE NSZ.NSZ_DTINCL >= '" + cDataIni + "'"
    cQuery +=    " AND NSZ.NSZ_DTINCL <= '" + cDataFim + "'"
    cQuery +=    " AND (NSZ.NSZ_DTENCE = '" + cDtVazia + "' OR NSZ.NSZ_DTENCE > '" + cDataFim + "') "
    cQuery +=    " AND NSZ.NSZ_FILIAL = '" + xFilial("NSZ") + "' "
    cQuery +=    " AND NSZ.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery, .F. )  
    DBUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), cTemp, .T., .F. )  

    If !(cTemp)->(EOF())
        nQtd += (cTemp)->TOTAL
	EndIf
	
	(cTemp)->(DbCloseArea())

Return nQtd

//-------------------------------------------------------------------
/*/{Protheus.doc} JQtdEncer
Retorna a quantidade de processos encerrados em um determinado período

@param cDataIni   , caracter, Data inicial de extração. 
@param cDataFim   , caracter, Data final de extração. 
@param cContrato  , caracter, Código do Contrato para contagem de 
                              processos dos seus casos

@return nQtd      , numérico, Quantidade de processos vinculados 
                              aos casos do contrato indicado

@author  Jorge Luis Branco Martins Junior
@version P12 
@since   13/07/17
/*/
//-------------------------------------------------------------------
Function JQtdEncer( cDataIni, cDataFim, cContrato )
	Local nQtd     := 0
    Local cQuery   := ""
    Local cTemp    := GetNextAlias()

	cDataIni := JDate2Str(cDataIni)
	cDataFim := JDate2Str(cDataFim)

    cQuery := " SELECT COUNT(NSZ_COD) TOTAL "
    cQuery +=   " FROM " + RetSQLName("NSZ") + " NSZ "
  	cQuery +=     " INNER JOIN " + RetSQLName("NUT") + " NUT "
 	cQuery +=        " ON NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
 	cQuery +=       " AND NUT.NUT_CCONTR = '" + cContrato + "'"
    cQuery +=       " AND NSZ.NSZ_CCLIEN = NUT.NUT_CCLIEN "
    cQuery +=       " AND NSZ.NSZ_LCLIEN = NUT.NUT_CLOJA "
    cQuery +=       " AND NSZ.NSZ_NUMCAS = NUT.NUT_CCASO "
    cQuery +=       " AND NUT.D_E_L_E_T_ = ' ' "
    cQuery +=  " WHERE NSZ.NSZ_DTENCE >= '" + cDataIni + "'"
    cQuery +=    " AND NSZ.NSZ_DTENCE <= '" + cDataFim + "'"
    cQuery +=    " AND NSZ.NSZ_DTINCL <= '" + cDataIni + "'"
    cQuery +=    " AND NSZ.NSZ_FILIAL = '" + xFilial("NSZ") + "' "
    cQuery +=    " AND NSZ.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery, .F. )  
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), cTemp, .T., .F. )  

    If !(cTemp)->(EOF())
        nQtd += (cTemp)->TOTAL
	EndIf
	
	(cTemp)->(DbCloseArea())

Return nQtd

//-------------------------------------------------------------------
/*/{Protheus.doc} JQtdAbeEnc
Retorna a quantidade de processos abertos e encerrados em um 
determinado período

@param cDataIni   , caracter, Data inicial de extração. 
@param cDataFim   , caracter, Data final de extração. 
@param cContrato  , caracter, Código do Contrato para contagem de 
                              processos dos seus casos

@return nQtd      , numérico, Quantidade de processos vinculados 
                              aos casos do contrato indicado

@author  Jorge Luis Branco Martins Junior
@version P12 
@since   13/07/17
/*/
//-------------------------------------------------------------------
Function JQtdAbeEnc( cDataIni, cDataFim, cContrato )
	Local nQtd     := 0
    Local cQuery   := ""
    Local cTemp    := GetNextAlias()

	cDataIni := JDate2Str(cDataIni)
	cDataFim := JDate2Str(cDataFim)

    cQuery := " SELECT COUNT(NSZ_COD) TOTAL "
    cQuery +=   " FROM " + RetSQLName("NSZ") + " NSZ "
  	cQuery +=     " INNER JOIN " + RetSQLName("NUT") + " NUT "
 	cQuery +=        " ON NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
 	cQuery +=       " AND NUT.NUT_CCONTR = '" + cContrato + "'"
    cQuery +=       " AND NSZ.NSZ_CCLIEN = NUT.NUT_CCLIEN "
    cQuery +=       " AND NSZ.NSZ_LCLIEN = NUT.NUT_CLOJA "
    cQuery +=       " AND NSZ.NSZ_NUMCAS = NUT.NUT_CCASO "
    cQuery +=       " AND NUT.D_E_L_E_T_ = ' ' "
    cQuery +=  " WHERE NSZ.NSZ_DTENCE >= '" + cDataIni + "'"
    cQuery +=    " AND NSZ.NSZ_DTENCE <= '" + cDataFim + "'"
    cQuery +=    " AND NSZ.NSZ_DTINCL >= '" + cDataIni + "'"
    cQuery +=    " AND NSZ.NSZ_DTINCL <= '" + cDataFim + "'"
    cQuery +=    " AND NSZ.NSZ_FILIAL = '" + xFilial("NSZ") + "' "
    cQuery +=    " AND NSZ.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery, .F. )  
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), cTemp, .T., .F. )  

    If !(cTemp)->(EOF())
        nQtd += (cTemp)->TOTAL
	EndIf
	
	(cTemp)->(DbCloseArea())

Return nQtd

//-------------------------------------------------------------------
/*/{Protheus.doc} JDate2Str
Verifica o tipo da variável e transforma em string, se necessário. 

@param xData   Variável recebida que, se necessário, será transormada em string. 

@return cRet   Retorno da variável transformada em string.

@author  Cristina Cintra
@since   18/07/17
/*/
//-------------------------------------------------------------------
Static Function JDate2Str(xData)
Local cRet    := ""
Default xData := "" 

If Valtype(xData) == "C"
	cRet := xData
ElseIf Valtype(xData) == "D"
	cRet := DToS(xData)
Else
	cRet := Str(xData)
EndIf

Return cRet