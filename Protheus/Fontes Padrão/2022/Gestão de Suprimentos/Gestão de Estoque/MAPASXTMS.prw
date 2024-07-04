/*/{Protheus.doc} MAPASXTMS
    Função responsável por preencher a Seção TN (Transporte Nacional) do Mapa de Controle de Produtos Químicos da Polícia Federal.
    Essa é função é chamada à partir do método ProcessMov da classe MAPASPF, quando trata-se de ambiente com integração TMS.
    @type  Function
    @author SQUAD Entradas + TMS
    @since 06/08/2019
    @version P12.1.25
    @see (http://www.pf.gov.br/servicos-pf/produtos-quimicos/arquivos-siproquim2/documentos/manual-tecnico.pdf)
/*/
Function MAPASXTMS(oMapasPF,cMapCfop)

    Local cAlias := GetNextAlias()
    Local cQuery := ""
    Local cChave := ""
    Local cChAnt := ""
    Local cNumCC := ""
    Local cCodNcm := ""
    Local cCnpjContr := ""
    Local cNomeContr := ""
    Local cCnpjOrig := ""
    Local cNomeOrig := ""
    Local cFilSA1 := FWxFilial("SA1")
    Local aRecTN := {}
    Local aRecCC := {}
    Local aRecTM := {}
    Local nConcent := 0

    Local cDatCC := ""
    Local cDatReceb := ""
    Local cModal := ""

    cQuery := "SELECT DT6.DT6_CLIDEV,DT6.DT6_LOJDEV,DTC.DTC_NUMNFC,DTC.DTC_SERNFC,DTC.DTC_EMINFC,"
    cQuery += "DTC.DTC_SELORI,DT6.DT6_CLIREM,DT6.DT6_LOJREM,DT6.DT6_CLIEXP,DT6.DT6_LOJEXP,"
    cQuery += "DT6.DT6_DOC,DT6.DT6_SERIE,DT6.DT6_DATEMI,DT6.DT6_DATENT,DTC.DTC_CODPRO,DTC_PESO,DTC_CF,DT6.DT6_TIPTRA,"
    If oMapasPF:lPFCompo
        cQuery += "SB5." + oMapasPF:cPFCompo + ","
    EndIf
    cQuery += "SB5." + oMapasPF:cCodMapas + " AS CODMAPAS,"
    cQuery += "SB1.B1_GRUPO,SB1.B1_POSIPI,SB5.B5_CONCENT,SB5.B5_DENSID "
    cQuery += "FROM " + RetSqlName("DT6") + " DT6 "
    cQuery += "INNER JOIN " + RetSqlName("DTC") + " DTC "
    cQuery += "ON DT6.DT6_FILDOC = DTC.DTC_FILDOC "
    cQuery += "AND DT6.DT6_DOC = DTC.DTC_DOC "
    cQuery += "AND DT6.DT6_SERIE = DTC.DTC_SERIE "
    cQuery += "INNER JOIN " + oMapasPF:cSqlNameB1 + " SB1 "
    cQuery += "ON SB1.B1_COD = DTC.DTC_CODPRO "
    cQuery += "INNER JOIN " + oMapasPF:cSqlNameB5 + " SB5 "
    cQuery += "ON SB5.B5_COD = DTC.DTC_CODPRO "
    cQuery += "WHERE DT6.DT6_FILIAL = '" + FWxFilial("DT6") + "' "
    cQuery += "AND DTC.DTC_FILIAL = '" + FWxFilial("DTC") + "' "
    cQuery += "AND SB1.B1_FILIAL = '" + oMapasPF:cFilSB1 + "' "
    cQuery += "AND SB5.B5_FILIAL = '" + oMapasPF:cFilSB5 + "' "
    cQuery += "AND SB1.B1_GRUPO BETWEEN '" + oMapasPF:cGrupoDe + "' AND '" + oMapasPF:cGrupoAte + "' "
    cQuery += "AND SB1.B1_COD BETWEEN '" + oMapasPF:cProdDe + "' AND '" + oMapasPF:cProdAte + "' "
    cQuery += "AND DTC.DTC_EMINFC BETWEEN '" + DtoS(oMapasPF:dDataDe) + "' AND '" + DtoS(oMapasPF:dDataAte) + "' "
    cQuery += "AND SB5." + oMapasPF:cProdPF + " IN ('S', 's') "
    If oMapasPF:lMapVII
        cQuery += "AND SB5." + oMapasPF:cMapVII + " IN ('2', ' ') "
    EndIf
    cQuery += "AND DT6.D_E_L_E_T_ = ' ' "
    cQuery += "AND DTC.D_E_L_E_T_ = ' ' "
    cQuery += "AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += "AND SB5.D_E_L_E_T_ = ' ' "
    cQuery += "ORDER BY DTC.DTC_EMINFC, DTC.DTC_NUMNFC, DTC.DTC_SERNFC, DT6.DT6_CLIDEV, DT6.DT6_LOJDEV, DT6.DT6_DOC, DT6.DT6_SERIE"

    cQuery := ChangeQuery(cQuery)

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias)

    While !(cAlias)->(EoF())

        If !Empty((cAlias)->DTC_CF) .And. Alltrim((cAlias)->DTC_CF) $ cMapCfop
			(cAlias)->(DbSkip())
			Loop
		Endif

        If Left((cAlias)->DTC_CF,1) $ "3/7"
            (cAlias)->(DbSkip())
			Loop
        EndIf

        cChave := (cAlias)->DTC_NUMNFC + (cAlias)->DTC_SERNFC + (cAlias)->DT6_CLIDEV + (cAlias)->DT6_LOJDEV + " " // A string vazia de tamanho 1 é para manter a integridade do índice das tabelas temporárias do MAPAS
        
        If cChave != cChAnt // O processamento a seguir somente é necessário 1 vez por Nota

            cCnpjContr := ""
            cNomeContr := ""
            cCnpjOrig := ""
            cNomeOrig := ""
            cNumCC := ""
            cDatCC := ""
            cDatReceb := ""
            cModal := ""

            cSFAnt := cChave

            SA1->(dbSetOrder(1))
            
            If !SA1->(dbSeek(cFilSA1 + (cAlias)->DT6_CLIDEV + (cAlias)->DT6_LOJDEV))
                (cAlias)->(dbSkip())
                Loop
            EndIf

            cCnpjContr := Iif(!Empty(SA1->A1_CGC),aRetDig(SA1->A1_CGC,.F.),Space(14))
            cNomeContr := SA1->A1_NOME

            If (cAlias)->DTC_SELORI == '3'

                If !SA1->(dbSeek(cFilSA1 + (cAlias)->DT6_CLIEXP + (cAlias)->DT6_LOJEXP))
                    (cAlias)->(dbSkip())
                    Loop
                Endif

                cCnpjOrig := Iif(!Empty(SA1->A1_CGC),aRetDig(SA1->A1_CGC,.F.),Space(14))
                cNomeOrig := SA1->A1_NOME

            Else

                If !SA1->(dbSeek(cFilSA1 + (cAlias)->DT6_CLIREM + (cAlias)->DT6_LOJREM))
                    (cAlias)->(dbSkip())
                    Loop
                Endif

                cCnpjOrig := Iif(!Empty(SA1->A1_CGC),aRetDig(SA1->A1_CGC,.F.),Space(14))
                cNomeOrig := SA1->A1_NOME

            EndIf

            cNumCC := (cAlias)->DT6_DOC
            cDatCC := (cAlias)->DT6_DATEMI
            cDatReceb := (cAlias)->DT6_DATENT
            cModal := GetModalCod((cAlias)->DT6_TIPTRA)

        EndIf

        // Definições do código NCM e Concentração
        If oMapasPF:lPFCompo .And. (cAlias)->&(oMapasPF:cPFCompo) $ "S/s"   
            
            If !Empty(oMapasPF:cGrupRes) .And. (cAlias)->B1_GRUPO == oMapasPF:cGrupRes
            
                cCodNcm := "RS"
        
            Else
            
                cCodNcm := "PC"
            
            EndIf
            
            cCodNcm += Transform((cAlias)->B1_POSIPI, oMapasPF:cNcmPic)
            nConcent := 0
    
        Else

            If !Empty(oMapasPF:cGrupRes) .And. (cAlias)->B1_GRUPO == oMapasPF:cGrupRes
            
                cCodNcm := "RC"
        
            Else
            
                cCodNcm := "PR"
            
            EndIf
        
            cCodNcm += (cAlias)->CODMAPAS
            nConcent := Iif((cAlias)->B5_CONCENT > 100, 100, ROUND((cAlias)->B5_CONCENT, 0))
    
        EndIf

        aRecTN := Array(14)

        aRecTN[01] := (cAlias)->DTC_NUMNFC
        aRecTN[02] := (cAlias)->DTC_SERNFC
        aRecTN[03] := (cAlias)->DT6_CLIDEV
        aRecTN[04] := (cAlias)->DT6_LOJDEV
        aRecTN[05] := " "
        aRecTN[06] := "TN"
        aRecTN[07] := cCnpjContr
        aRecTN[08] := cNomeContr
        aRecTN[09] := aRecTN[01]
        aRecTN[10] := StoD((cAlias)->DTC_EMINFC)
        aRecTN[11] := cCnpjOrig
        aRecTN[12] := cNomeOrig
        aRecTN[13] := "P" // No momento, o cenário de Armazenagem Terceirizada não será coberto
        aRecTN[14] := "P" // No momento, o cenário de Armazenagem Terceirizada não será coberto

        aRecCC := Array(6)

        aRecCC[01] := "CC"
        aRecCC[02] := cNumCC
        aRecCC[03] := StoD(cDatCC)
        aRecCC[04] := StoD(cDatReceb)
        aRecCC[05] := "SEM INFORMAÇÃO"
        aRecCC[06] := cModal

        aRecTM := Array(7)

        aRecTM[01] := (cAlias)->DTC_CODPRO
        aRecTM[02] := "TM" // Gravado apenas para identificação. Não será impresso no arquivo magnético. 
        aRecTM[03] := cCodNcm
        aRecTM[04] := nConcent
        aRecTM[05] := Iif((cAlias)->B5_DENSID > 99.99, 99.99, (cAlias)->B5_DENSID)
        aRecTM[06] := Iif((cAlias)->DTC_PESO > 999999999.999, 999999999.999, DTC_PESO)
        aRecTM[07] := "K"

        oMapasPF:GravaTN(aRecTN, aRecCC, aRecTM)

        (cAlias)->(dbSkip())

    End
    
Return

/*/{Protheus.doc} GetModalCod
    Função responsável por retornar o código MAPAS de Modal de Trabsporte conforme valor preenchido em DT6_TIPTRA
    @type  Function
    @author SQUAD Entradas + TMS
    @since 06/08/2019
    @version P12.1.25
    @see (http://www.pf.gov.br/servicos-pf/produtos-quimicos/arquivos-siproquim2/documentos/manual-tecnico.pdf)
/*/
Static Function GetModalCod(cTipTra)

    Local cReturn := ""
    Local nPos := 0
    Local aModais := {}

    AAdd( aModais, { '1', 'RO'	}) //"Rodoviario"
    AAdd( aModais, { '2', 'AE'	}) //"Aereo"
    AAdd( aModais, { '3', 'AQ'	}) //"Fluvial"

    nPos := Ascan(aModais, {|x| x[1] == cTipTra })

    If nPos > 0

        cReturn := aModais[nPos][2]

    EndIf

Return cReturn
