#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"


User Function MT150OK()
    //Local lRet          := .T.
    //Local cChave        := FWxFilial("SC8") + SC8->C8_NUM + SC8->C8_FORNECE+SC8->C8_LOJA + SC8->C8_NUMPRO
    Local aDados        := fGetDados()
    Private cTimeIni    := Time()
    
    //if Type("oMainWnd") == 'U' .or. Aviso("Email","Deseja Enviar email de cotação para o Fornecedor? ",{"Sim","Não"}) == 1
    U_VACOMR10(aDados)
    //endif
Return

Static Function fGetDados()
    Local aArea     := GetArea()
    Local aDados    := {}
    Local _cQry     := ''

    _cQry := " select C8_FILENT,C8_ITEM, " + CRLF 
    _cQry += " 		C8_FORNECE, " + CRLF 
    _cQry += " 		C8_LOJA, " + CRLF 
    _cQry += " 		C8_UM, " + CRLF 
    _cQry += " 		C8_PRODUTO, " + CRLF 
    _cQry += " 		C8_QUANT,  " + CRLF 
    _cQry += " 		C8_EMISSAO, " + CRLF 
    _cQry += " 		C8_NUM, " + CRLF 
    _cQry += " 		C8_NUMSC, " + CRLF 
    _cQry += " 		C8_DATPRF, " + CRLF 
    _cQry += " 		ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), C8_MSGMAIL)),'') AS MSGMAIL , " + CRLF 
    _cQry += " 		C8_WFEMAIL " + CRLF 
    _cQry += " 		C8_NUM, " + CRLF 
    _cQry += " 		A2_NOME, " + CRLF 
    _cQry += " 		A2_END, " + CRLF
    _cQry += " 		A2_EST, " + CRLF 
    _cQry += " 		A2_TEL, " + CRLF
    _cQry += " 		A2_FAX, " + CRLF
    _cQry += " 		A2_EMAIL, " + CRLF 
    _cQry += " 		A2_MUN, " + CRLF 
    _cQry += " 		A2_CGC, " + CRLF 
    _cQry += " 		A2_COD_MUN, " + CRLF 
    _cQry += " 		A2_CONTATO, " + CRLF 
    _cQry += " 		B1_DESC, " + CRLF 
    _cQry += " 		C1_CODCOMP, " + CRLF 
    _cQry += " 		Y1_EMAIL " + CRLF 
    _cQry += " from "+RetSqlName("SC8")+" C8 " + CRLF 
    _cQry += " LEFT JOIN "+RetSqlName("SB1")+" B1 ON C8_PRODUTO = B1_COD " + CRLF 
    _cQry += " AND B1.D_E_L_E_T_ = '' " + CRLF 
    _cQry += " LEFT JOIN "+RetSqlName("SA2")+" A2 ON C8_FORNECE = A2_COD " + CRLF
    _cQry += " AND C8_LOJA = A2_LOJA" + CRLF 
    _cQry += " AND A2.D_E_L_E_T_ = ''" + CRLF 
    _cQry += " LEFT JOIN "+RetSqlName("SC1")+" C1 ON C8_FILIAL = C1_FILIAL  " + CRLF 
    _cQry += " AND C8_NUMSC = C1_NUM  " + CRLF 
    _cQry += " AND C8_ITEMSC = C1_ITEM " + CRLF 
    _cQry += " AND C8_PRODUTO = C1_PRODUTO " + CRLF 
    _cQry += " AND C1.D_E_L_E_T_ = ''" + CRLF 
    _cQry += " LEFT join "+RetSqlName("SY1")+" Y1 ON Y1_COD = C1_CODCOMP " + CRLF 
    _cQry += " AND Y1.D_E_L_E_T_ = ''" + CRLF 
    _cQry += " WHERE C8_FILIAL = '"+FWxFilial("SC8")+"' " + CRLF 
    _cQry += " AND C8_NUM = '"+SC8->C8_NUM+"' " + CRLF 
    _cQry += " AND C8_FORNECE+C8_LOJA = '"+(SC8->C8_FORNECE+SC8->C8_LOJA)+"' " + CRLF 
    _cQry += " AND C8_NUMPRO = '"+SC8->C8_NUMPRO+"' " + CRLF 
    _cQry += " AND C8.D_E_L_E_T_ = '' "   + CRLF
    
    MemoWrite("C:\totvs_relatorios\" +"MT150WF" + ".sql" , _cQry)
    
    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)

    While !TEMPSQL->(Eof())
        aAdd(aDados,{TEMPSQL->C8_ITEM,;     //01    
                    TEMPSQL->B1_DESC,;      //02
                    TEMPSQL->C8_FILENT,;    //03
                    TEMPSQL->C8_FORNECE,;   //04
                    TEMPSQL->A2_NOME,;      //05
                    TEMPSQL->C8_PRODUTO,;   //06
                    TEMPSQL->C8_UM,;        //07
                    TEMPSQL->C8_QUANT,;     //08
                    TEMPSQL->C8_EMISSAO,;   //09
                    TEMPSQL->C8_NUM,;       //10
                    TEMPSQL->C8_NUMSC,;     //11
                    TEMPSQL->A2_END,;       //12
                    TEMPSQL->A2_MUN,;       //13
                    TEMPSQL->A2_EST,;       //14
                    TEMPSQL->A2_TEL,;       //15
                    TEMPSQL->A2_FAX,;       //16
                    TEMPSQL->A2_CONTATO,;   //17
                    TEMPSQL->A2_CGC,;       //18
                    TEMPSQL->C8_DATPRF,;    //19
                    TEMPSQL->A2_EMAIL,;     //20
                    TEMPSQL->C8_LOJA,;      //21
                    TEMPSQL->MSGMAIL,;      //22
                    cTimeIni,;              //23
                    })
        TEMPSQL->(dbSkip())
    enddo
    TEMPSQL->(dbCloseArea())
    RestArea(aArea)
Return aDados 
