#INCLUDE 'PROTHEUS.CH'

Static __aPrepared :={}

//-------------------------------------------------------------------
/*/{Protheus.doc} RBE_TMK
Funcoes de compatibilizacao e/ou conversaoo de dados para as tabelas do sistema.

@sample RBE_TMK("12", "2", "027", "033", "BRA")

@param cVersion - Versao do Protheus
@param cMode - Modo de execucao - "1" = Por grupo de empresas / "2" = Por grupo de empresas + filial (filial completa)
@param cRelStart - Release de partida - (Este seria o Release no qual o cliente estao)
@param cRelFinish - Release de chegada - (Este seria o Release ao final da atualizacao)
@param cLocaliz - Localizacao (pais) - Ex. "BRA"

@return lRet

@author CRM/FAT
@since 12/08/2021
@version P12
/*/
//-------------------------------------------------------------------
Function RBE_TMK( cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
Local lRet := .F.

Default cVersion := ''
Default cMode := ''
Default cRelStart := ''
Default cRelFinish := ''
Default cLocaliz := ''

aArqUpd := {}

If cMode == "1"
	//Ajuste do sequencial nas numeracoes duplicadas (Tabela AGB) - DSERFAT-21890
	lRet := RBE_21890()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RBE_21890
DSERFAT-21890
Funcoes de eliminacao de chaves duplicadas que podem ocorrer a partir 
da release 12.1.33. na tabela AGB, após atualização do X2_UNICO desta
tabela.

@sample RBE_21890()

@return lRet - Resultado do processamento

@author CRM/FAT
@since 13/08/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function RBE_21890()

	Local lRet              := .T.
	Local cQuery            := ""
    Local cAlias            := "AGB"
    Local cAliasAGB	        := GetNextAlias()
    Local cChvUnq           := ""
    Local cChvUnqAnt        := ""
    Local nX                := 0

    Local cQueryAGB         := ""
	Local aInsert 	        := {}
	Local nLenPrepStat      := 0 
	Local nPosPrepared      := 0 
	Local cMD5 		        := ""
	Local cAliasPSQry       := GetNextAlias()
	
    // Busca dos registros duplicados em relação a chave
    // AGB_FILIAL+AGB_CODIGO+AGB_ENTIDA+AGB_CODENT
    cQuery := "SELECT " + CRLF
    cQuery += "	AGB.AGB_FILIAL, " + CRLF
    cQuery += "	AGB.AGB_ENTIDA, " + CRLF
    cQuery += "	AGB.AGB_CODENT, " + CRLF
    cQuery += "	AGB.AGB_CODIGO, " + CRLF
    cQuery += "	AGB.R_E_C_N_O_ " + CRLF
    cQuery += "FROM " + CRLF
    cQuery += " " + RetSQLName("AGB") + " AGB INNER JOIN " + CRLF
    cQuery += "	( " + CRLF
    cQuery += "		SELECT " + CRLF
    cQuery += "			AGB_FILIAL, " + CRLF
    cQuery += "			AGB_ENTIDA, " + CRLF
    cQuery += "			AGB_CODENT, " + CRLF
    cQuery += "			AGB_CODIGO,	 " + CRLF
    cQuery += "			COUNT(1) REPETICAO " + CRLF
    cQuery += "		FROM " + CRLF
    cQuery += "			" + RetSQLName("AGB") + " AGB		 " + CRLF	
    cQuery += "		WHERE " + CRLF
    cQuery += "			AGB.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "		GROUP BY " + CRLF
    cQuery += "			AGB_FILIAL, " + CRLF
    cQuery += "			AGB_ENTIDA, " + CRLF
    cQuery += "			AGB_CODENT, " + CRLF
    cQuery += "			AGB_CODIGO " + CRLF
    cQuery += "		HAVING  " + CRLF
    cQuery += "			COUNT(1) > 1 " + CRLF
    cQuery += "	) REPETICOES " + CRLF
    cQuery += "		ON " + CRLF
    cQuery += "			AGB.AGB_FILIAL = REPETICOES.AGB_FILIAL " + CRLF
    cQuery += "				AND " + CRLF
    cQuery += "			AGB.AGB_ENTIDA = REPETICOES.AGB_ENTIDA " + CRLF
    cQuery += "				AND " + CRLF
    cQuery += "			AGB.AGB_CODENT = REPETICOES.AGB_CODENT " + CRLF
    cQuery += "				AND " + CRLF
    cQuery += "			AGB.AGB_CODIGO = REPETICOES.AGB_CODIGO " + CRLF
    cQuery += "				AND " + CRLF
    cQuery += "			AGB.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "				 " + CRLF
    cQuery += "ORDER BY " + CRLF
    cQuery += "	AGB.AGB_FILIAL, " + CRLF
    cQuery += "	AGB.AGB_ENTIDA, " + CRLF
    cQuery += "	AGB.AGB_CODENT, " + CRLF
    cQuery += "	AGB.AGB_CODIGO, " + CRLF
    cQuery += "	AGB.R_E_C_N_O_ "

    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAGB,.F.,.T.)

    // Tratar os registros duplicados se houver
    DbSelectArea("AGB")
    While (cAliasAGB)->(!Eof())
        
        nLenSX8 := GetSX8Len()

        cChvUnq := (cAliasAGB)->(AGB_FILIAL+AGB_CODIGO+AGB_ENTIDA+AGB_CODENT)
        If !(cChvUnq == cChvUnqAnt)
            // Início de nova chave duplicada
            cChvUnqAnt := cChvUnq
            (cAliasAGB)->(DbSkip())
            Loop
        EndIf
        //Posicionar no registro a ser alterado
        AGB->(DbGoTo((cAliasAGB)->(R_E_C_N_O_)))
        cTempCodigo := GetSx8Num(cAlias,cAlias + "_CODIGO")
        While (cChvUnq == (cAlias)->(AGB_FILIAL+AGB_CODIGO+AGB_ENTIDA+AGB_CODENT))
            // Query para buscar chave duplicada
            cQueryAGB := "SELECT " + CRLF
            cQueryAGB += "	AGB.AGB_CODIGO " + CRLF
            cQueryAGB += "FROM " + CRLF
            cQueryAGB += "	? AGB " + CRLF
            cQueryAGB += "WHERE " + CRLF
            cQueryAGB += "	AGB.AGB_FILIAL = ? " + CRLF
            cQueryAGB += "		AND " + CRLF
            cQueryAGB += "	AGB.AGB_CODIGO = ? " + CRLF
            cQueryAGB += "		AND " + CRLF
            cQueryAGB += "	AGB.AGB_ENTIDA = ? " + CRLF
            cQueryAGB += "		AND " + CRLF
            cQueryAGB += "	AGB.AGB_CODENT = ? " + CRLF
            cQueryAGB += "		AND " + CRLF
            cQueryAGB += "	AGB.D_E_L_E_T_ = ' ' " + CRLF

            Aadd(aInsert, RetSqlName( "AGB" ))
            Aadd(aInsert, (cAliasAGB)->AGB_FILIAL)
            Aadd(aInsert, cTempCodigo)
            Aadd(aInsert, (cAliasAGB)->AGB_ENTIDA)
            Aadd(aInsert, (cAliasAGB)->AGB_CODENT)
            
            nLenPrepStat := Len(aInsert)
            cMD5         := MD5(cQueryAGB) 
            If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0 
                Aadd(__aPrepared,{FWPreparedStatement():New(),cMD5})
                nPosPrepared := Len(__aPrepared)
                __aPrepared[nPosPrepared][1]:SetQuery(ChangeQuery(cQueryAGB))
            Endif 

            __aPrepared[nPosPrepared][1]:SetUnsafe(1, aInsert[1])
            For nX := 2 to nLenPrepStat
                __aPrepared[nPosPrepared][1]:SetString(nX, aInsert[nX])
            Next 

            cQueryAGB := __aPrepared[nPosPrepared][1]:getFixQuery()
            dbUseArea( .T., "TOPCONN", TcGenQry( , , cQueryAGB ), cAliasPSQry, .F., .T. )

            aInsert := aSize(aInsert,0)

            If (cAliasPSQry)->(!EoF())
                cTempCodigo := GetSx8Num(cAlias,cAlias + "_CODIGO")
            Else
                RecLock("AGB", .F.)
                AGB->AGB_CODIGO := cTempCodigo
                AGB->(MsUnlock())
            EndIf

            (cAliasPSQry)->(DbCloseArea())
        EndDo

        While ( GetSX8Len() > nLenSX8 )
            ConfirmSx8()
        EndDo

        (cAliasAGB)->(DbSkip())
    EndDo
    (cAliasAGB)->(DbCloseArea())

Return lRet

