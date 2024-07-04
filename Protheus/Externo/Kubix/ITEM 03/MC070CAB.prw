#INCLUDE 'PROTHEUS.CH'

User Function MC070CPO()
    Local aAux      := ParamIXB[1]
    Local nI
    Local cQry      := ''

    if ALLTRIM(SB1->B1_ZZTIPO) == 'INGRED'
        //verifica se há medição
        cQry := " SELECT QE7_ENSAIO, QE1_DESCPO FROM "+RetSqlName("QE7")+" QE7 "  + CRLF  
        cQry += " JOIN "+RetSqlName("QE1")+" QE1 " + CRLF 
        cQry += " ON QE1.QE1_FILIAL = QE7.QE7_FILIAL  " + CRLF 
        cQry += " AND QE1.QE1_ENSAIO = QE7.QE7_ENSAIO  " + CRLF 
        cQry += " AND QE1.D_E_L_E_T_ = '' " + CRLF 
        cQry += " WHERE QE7.QE7_FILIAL = '"+FwxFilial("QE7")+"'" + CRLF 
        cQry += " AND QE7.QE7_PRODUT = '"+AllTrim(SB1->B1_COD)+"' " + CRLF 
        cQry += " AND QE7.QE7_SEQLAB = '01' " + CRLF
        cQry += " AND QE7.D_E_L_E_T_ = ' ' " + CRLF

        MemoWrite("C:\totvs_relatorios\"+"MC070ITEMS" + StrTran(SubS(Time(),1,5),":","") + ".sql" , cQry)
        
        mpSysOpenQuery(cQry,'_SPEC')

        if !_SPEC->(Eof()) 

            for nI := 1 to len (aAux)
                cQry := " SELECT QPS.QPS_MEDICA as Resultado FROM "+RetSqlName("QPR")+" QPR " + CRLF 
                cQry += " JOIN "+RetSqlName("QPS")+" QPS ON QPS_FILIAL = QPR.QPR_FILIAL " + CRLF 
                cQry += " AND QPS.QPS_CODMED = QPR.QPR_CHAVE " + CRLF 
                cQry += " AND QPS.D_E_L_E_T_ = '' " + CRLF 
                cQry += " WHERE QPR.QPR_FILIAL = '"+FwxFilial("QPR")+"' " + CRLF
                cQry += " AND QPR.QPR_LOTE = '"+ALLTRIM(aAux[nI][2])+"' " + CRLF
                cQry += " AND QPR.QPR_PRODUT = '"+ALLTRIM(SB1->B1_COD)+"' " + CRLF
                cQry += " AND QPR.QPR_ENSAIO = '"+ALLTRIM(_SPEC->QE7_ENSAIO)+"' " + CRLF
                
                MemoWrite("C:\totvs_relatorios\"+"MC070RESUL" + StrTran(SubS(Time(),1,5),":","") + ".sql" , cQry)

                mpSysOpenQuery(cQry,'_RES')
                
                aAdd( aAux[nI], ALLTRIM(_SPEC->QE1_DESCPO))
                aAdd( aAux[nI], ALLTRIM(_RES->Resultado))
                
                _RES->(DbCloseArea())
            next nI
        endif

        _SPEC->(DbCloseArea())
    Endif
Return aAux

User Function MC070CAB()
    Local aCabec := { }

    if ALLTRIM(SB1->B1_ZZTIPO) == 'INGRED'
        //verifica se há medição
        cQry := " SELECT QE7_ENSAIO, QE1_DESCPO FROM "+RetSqlName("QE7")+" QE7 "  + CRLF  
        cQry += " JOIN "+RetSqlName("QE1")+" QE1 " + CRLF 
        cQry += " ON QE1.QE1_FILIAL = QE7.QE7_FILIAL  " + CRLF 
        cQry += " AND QE1.QE1_ENSAIO = QE7.QE7_ENSAIO  " + CRLF 
        cQry += " AND QE1.D_E_L_E_T_ = '' " + CRLF 
        cQry += " WHERE QE7.QE7_FILIAL = '"+FwxFilial("QE7")+"'" + CRLF 
        cQry += " AND QE7.QE7_PRODUT = '"+AllTrim(SB1->B1_COD)+"' " + CRLF 
        cQry += " AND QE7.QE7_SEQLAB = '01' " + CRLF
        cQry += " AND QE7.D_E_L_E_T_ = ' ' " + CRLF

        MemoWrite("C:\totvs_relatorios\"+"MC070ITEMS" + StrTran(SubS(Time(),1,5),":","") + ".sql" , cQry)

        mpSysOpenQuery(cQry,'_SPEC')

        if !_SPEC->(Eof())

            aAdd(aCabec,'Ensaio')
            aAdd(aCabec,'Resultado')

        endif

        _SPEC->(DbCloseArea())
    Endif
Return aCabec

