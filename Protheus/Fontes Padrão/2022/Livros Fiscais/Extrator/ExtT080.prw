#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'

Static oFisaExtSx := FisaExtX02()

/*/{Protheus.doc} ExtT080
    (Função para gerar o layout T080,T080AA, T080AB, T080AC e T080AD.)
    
    @type Function
    @author Vitor Ribeiro
    @since 22/02/2018
    
    @return Nil, nulo, não tem retorno.

    @obs A função ExtT080 foi desenvolvida conforme a documentação do TAF 'layout TAF - v12 1 18 v13'.
        T080 - Movimento SAT-CF-e
        T080AA - Cupom Fiscal Eletrônico - SAT (CF-E-SAT)
        T080AB - Cadastro dos Itens do Cupom Fiscal Eletrônico emitido pelo SAT-CF-e
        T080AC - Cadastro dos Tributos dos Itens do Cupom Fiscal Eletrônico emitido pelo SAT-CF-e
        T080AD - Processos referenciados
        T080AE - REGISTRO ANALÍTICO DO DOCUMENTO – CF-e (CÓDIGO 59)
    /*/
Function ExtT080()

    Local cTxtSys := ""
    Local cAlsQuery := ""
    Local cChaveSFT := ""
    Local cForOrCli := ""
    Local cCpoSimpN := ""
    Local cMvEstado := ""
    Local cUFRESpd := ""
    Local cSituaDoc := ""
    Local cIdentECF := ""
    Local cEspecie := ""

    Local dDataDe := oWizard:GetDataDe()
    Local dDataAte := oWizard:GetDataAte()

    Local lCadParti := .F.
    Local lHistTab := .F.
    Local lGerou := .F.

    Local aPartDoc := {}
    Local aRegT080 := {}
    Local aRegT080AA := {}
    Local aRegT080AB := {}
    Local aRegT080AC := {}
    Local aRegT080AD := {}

    Local nHdlTxt := 0
    Local nT080 := 0
    Local nT080AA := 0
    Local nT080AB := 0
    
    DbSelectArea("SL1")		// ORCAMENTO
    SL1->(DbSetOrder(2))	// L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV

    DbSelectArea("CDG")     // PROCESSOS REFER. NO DOCUMENTO
    CDG->(DbSetOrder(1))    // CDG_FILIAL+CDG_TPMOV+CDG_DOC+CDG_SERIE+CDG_CLIFOR+CDG_LOJA+CDG_PROCES+CDG_TPPROC

    cMvEstado := oFisaExtSx:_MV_ESTADO
    cUFRESpd := oFisaExtSx:_MV_UFRESPD
    
    lCadParti := ExistBlock("SPDFIS06")
    
    lHistTab := oFisaExtSx:_MV_HISTTAB .And. oFisaExtSx:_AIF

    // Realiza a query com os registros que devem ser listados
    cAlsQuery := fMakeQuery(dDataDe,dDataAte)

    If (cAlsQuery)->(!Eof())
        cTxtSys := cDirSystem + IIf(isSrvUnix(),"/","\") + " T080.TXT"   
        nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)

        While (cAlsQuery)->(!Eof())
            // Posiciona nos registros
            SFT->(DbGoTo((cAlsQuery)->RECSFT))
            SF4->(DbGoTo((cAlsQuery)->RECSF4))

            // Se encontrou o registro
            If SFT->(!Eof())
                lGerou := .T.

                // Se for uma nova nota
                If cChaveSFT <> SFT->(FT_TIPOMOV+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA)
                    // Verifica se o participante é fornecedor (SA2) ou cliente (SA1)
                    If SFT->((FT_TIPOMOV == "E" .And. !(FT_TIPO $ "B|D")) .Or. (FT_TIPOMOV == "S" .And. FT_TIPO $ "B|D"))
                        cForOrCli := "SA2"
                        cCpoSimpN := "SA2->A2_SIMPNAC"
                    Else
                        cForOrCli := "SA1"
                        cCpoSimpN := "SA1->A1_SIMPNAC"
                    EndIf

                    // Busca o Codigo da Situacao do Documento
                    // SPEDSitDoc(NaoUsar,cAliasSFT,cAliasSA,cCmpSimpN,dDataDe,dDataAte,lRegEsp,lSitDocCDT,cSitExt,cAliasSF3,cAliasSF4)
                    cSituaDoc := SPEDSitDoc(,"SFT",cForOrCli,cCpoSimpN,,,(cMVEstado $ cUFRESpd),.F.,,,"SF4")

                    // Retorna historico de alteracoes do cadastro de clientes, fornecedores, produto e transportadora
                    // MsConHist(cAliasTab,cCliFor,cLoja,dDataIni,dDataFim,cProduto,cTransp)
                    aHistSA	:=	MsConHist(cForOrCli,SFT->FT_CLIEFOR,SFT->FT_LOJA,dDataDe)

                    // Busca os dados do participante
                    // InfPartDoc(cAlsSA,dDataDe,dDataAte,cAliasSFT,lCadParti,aHistSA,lHistTab,lExtratTAF)
                    aPartDoc := InfPartDoc(cForOrCli,dDataDe,dDataAte,"",lCadParti,aHistSA,lHistTab,.T.)

				    // Buscando o Modelo da NF
				    cEspecie :=	AModNot(SFT->FT_ESPECIE)

                    //Tratamento para NFS
                    If Empty(cEspecie) .And. AllTrim(SFT->FT_ESPECIE) $ "NFS/RPS"
                        cEspecie := "01"
                    EndIf
                EndIf
                
                If cIdentECF <> (cAlsQuery)->LG_CODIGO
                    // Monta o registro T080
                    RegT080(@aRegT080,(cAlsQuery)->LG_CODIGO)

                    // Pega a linha do T080
                    nT080 := Len(aRegT080)
                EndIf

                // Monta o registro T080AA
                RegT080AA(@aRegT080AA,aPartDoc,cSituaDoc,nT080)
                
                // Pega a linha do T080AA
                nT080AA := Len(aRegT080AA)

                // Monta o registro T080AB
                RegT080AB(@aRegT080AB,(cAlsQuery)->B1_ORIGEM,nT080,nT080AA)

                // Pega a linha do T080AB
                nT080AB := Len(aRegT080AB)

                // Monta o registro T080AC
                RegT080AC(@aRegT080AC,aPartDoc,cEspecie,nT080,nT080AA,nT080AB)

                // Guarda a chave da SFT
                cChaveSFT := SFT->(FT_TIPOMOV+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA)

                // Guarda o codigo 
                cIdentECF := (cAlsQuery)->LG_CODIGO
            EndIf

            // Vai para o proximo registro
            (cAlsQuery)->(DbSkip())

            // Se for outra chave, grava os registros.
            If cChaveSFT <> (cAlsQuery)->(FT_TIPOMOV+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA)
                // Monta o registro T080AD
                RegT080AD(@aRegT080AD,cChaveSFT,nT080,nT080AA)
            EndIf

            // Se for outro codigo, grava na tabela.
            If cIdentECF <> (cAlsQuery)->LG_CODIGO
                // Função para grava os registros
                fGravaReg(@aRegT080,@aRegT080AA,@aRegT080AB,@aRegT080AC,@aRegT080AD,nHdlTxt)

                If cTpSaida == "2"
                    // Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.
                    FConcST1()
                EndIf
            EndIf
        EndDo
    EndIf

    (cAlsQuery)->(DbCloseArea())

Return lGerou

/*/{Protheus.doc} fMakeQuery
    (Função para executar a query principal)

    @type Static Function
    @author Vito Ribeiro
    @since 22/02/2018
    
    @param dDataDe, data, data de informada no wizard
    @param dDataAte, data, data ate informada no wizard

    @return cAlsQuery, caracter, retorna o alias da query.
    /*/
Static Function fMakeQuery(dDataDe,dDataAte)

    Local cAlsQuery := ""
    Local cJoinSLG := ""
    Local cWhereSFT := ""

    Default dDataDe := CToD("")
    Default dDataAte := CToD("")

    If oFisaExtSx:_LG_SERSAT
        cJoinSLG := " AND SLG.LG_SERSAT = SFT.FT_SERSAT "
    EndIf

    cWhereSFT := " AND SFT.FT_NFISCAL BETWEEN '" + oWizard:GetNotaDe() + "' AND '" + oWizard:GetNotaAte() + "' "
    cWhereSFT := " AND SFT.FT_SERIE BETWEEN '" + oWizard:GetSerieDe() + "' AND '" + oWizard:GetSerieAte() + "' " 

    If !Empty(oWizard:GetTipoMovimento())
        cWhereSFT += " AND SFT.FT_TIPO = '" + oWizard:GetTipoMovimento() + "' "
    EndIf

    If !Empty(oWizard:GetEspecie())
        cWhereSFT := " AND SFT.FT_ESPECIE IN (" + oWizard:GetEspecie(.T.) + ") "
    EndIf

    If oWizard:GetTipoMovimento() == '2'      // 2-Entradas (Notas de Entrada)
        cWhereSFT := "AND SFT.FT_TIPOMOV = 'E' "
    ElseIf oWizard:GetTipoMovimento() == '3'  // 3-Saídas (Notas de Saída)
        cWhereSFT := "AND SFT.FT_TIPOMOV = 'S' "
    EndIf

    cJoinSLG := "%" + cJoinSLG + "%"
    cWhereSFT := "%" + cWhereSFT + "%"

    cAlsQuery := GetNextAlias()

    BeginSql Alias cAlsQuery
        SELECT
            SLG.LG_CODIGO
            ,SB1.B1_ORIGEM 
            ,SFT.FT_TIPOMOV
            ,SFT.FT_SERIE
            ,SFT.FT_NFISCAL
            ,SFT.FT_CLIEFOR
            ,SFT.FT_LOJA
            ,SFT.R_E_C_N_O_ RECSFT
            ,SF4.R_E_C_N_O_ RECSF4
        FROM %Table:SFT% SFT

        INNER JOIN %Table:SLG% SLG ON
            SLG.%NotDel%
            AND SLG.LG_FILIAL = %xFilial:SLG% 
            AND SLG.LG_PDV = SFT.FT_PDV
            %Exp:cJoinSLG%
        
        INNER JOIN %Table:SB1% SB1 ON
            SB1.%NotDel%
            AND SB1.B1_FILIAL = %xFilial:SB1%
            AND SB1.B1_COD = SFT.FT_PRODUTO

        INNER JOIN %Table:SD2% SD2 ON
            SD2.%NotDel%
            AND SD2.D2_FILIAL = %xFilial:SD2%
            AND SD2.D2_DOC = SFT.FT_NFISCAL
            AND SD2.D2_SERIE = SFT.FT_SERIE
            AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR
            AND SD2.D2_LOJA = SFT.FT_LOJA
            AND SD2.D2_ITEM = SFT.FT_ITEM
            AND SD2.D2_COD = SFT.FT_PRODUTO

        INNER JOIN %Table:SF4% SF4 ON
            SF4.%NotDel%
            AND SF4.F4_FILIAL = %xFilial:SF4%
            AND SF4.F4_CODIGO = SD2.D2_TES

        WHERE
            SFT.%NotDel%
            AND SFT.FT_FILIAL = %xFilial:SFT%
            AND SFT.FT_TIPOMOV = 'S'
            AND SFT.FT_ENTRADA >= %Exp:DToS(dDataDe)%
            AND SFT.FT_ENTRADA <= %Exp:DToS(dDataAte)%
            AND SFT.FT_ESPECIE = 'SATCE'
            %Exp:cWhereSFT%
            AND (
                    (SFT.FT_CFOP NOT LIKE '000%' AND SFT.FT_CFOP NOT LIKE '999%') 
                    OR SFT.FT_TIPO='S'
                )

        ORDER BY
            SLG.LG_CODIGO
            ,SFT.FT_TIPOMOV
            ,SFT.FT_SERIE
            ,SFT.FT_NFISCAL
            ,SFT.FT_CLIEFOR
            ,SFT.FT_LOJA
    EndSql

Return cAlsQuery

/*/{Protheus.doc} RegT080
    (Função para gerar o registro T080 - Movimento SAT-CF-e)

    @type Static Function
    @author Vitor Ribeiro
    @since 22/02/2018
    
    @param a_RgT080, array, contém os dados da T080
    @param c_IdentECF, caracter, contém o codigo da ident ECF

    @return Nil, nulo, não tem retorno.
    /*/
Static Function RegT080(a_RgT080,c_IdentECF)

    Local nLinha := 0

    Default a_RgT080 := {}

    Default c_IdentECF := ""

    Aadd(a_RgT080,{{}})
    nLinha := Len(a_RgT080)

    Aadd(a_RgT080[nLinha][1],"T080")       // 01 - REGISTRO
    Aadd(a_RgT080[nLinha][1],c_IdentECF)   // 02 - IDENT_ECF

Return Nil

/*/{Protheus.doc} RegT080AA
    (Função para gerar o registro T080AA - Cupom Fiscal Eletrônico - SAT (CF-E-SAT))

    @type Static Function
    @author Vitor Ribeiro
    @since 22/02/2018
    
    @param a_RgT080AA, array, contém as informações do registros T080AA
    @param a_PartDoc, array, contém as informações do participante.
    @param c_SituaDoc, caracter, contém a situação do documento.
    @param n_T080, numerico, contém a linha do array T080

    @return Nil, nulo, não tem retorno.
    /*/
Static Function RegT080AA(a_RgT080AA,a_PartDoc,c_SituaDoc,n_T080)

    Local nLinha := 0

    Local cCumpoFis := ""
    Local cCnpjPart := ""
    Local cCpfPart := ""

    Default a_RgT080AA := {}
    Default a_PartDoc := {}

    Default c_SituaDoc := ""

    Default n_T080 := 0

    cCumpoFis := Right(AllTrim(SFT->FT_NFISCAL),6)

    nLinha := Ascan(a_RgT080AA, {|x| x[1] == n_T080 .And. x[2][1][2] == SFT->FT_EMISSAO .And. x[2][1][3] == c_SituaDoc .And. x[2][1][4] == cCumpoFis })

    If Empty(nLinha)
        cCnpjPart := a_PartDoc[04]
        cCpfPart := a_PartDoc[05]

        If SL1->(MsSeek(xFilial("SL1")+SFT->FT_SERIE+SFT->FT_NFISCAL)) 
            If AllTrim(SL1->L1_CGCCLI) > 11
                cCnpjPart := AllTrim(SL1->L1_CGCCLI)
            Else
                cCpfPart := AllTrim(SL1->L1_CGCCLI)
            EndIf
        EndIf

        Aadd(a_RgT080AA,{n_T080,{{}}})
        nLinha := Len(a_RgT080AA)

        Aadd(a_RgT080AA[nLinha][2][1],"T080AA")           // 01 - REGISTRO
        Aadd(a_RgT080AA[nLinha][2][1],SFT->FT_EMISSAO)    // 02 - DT_DOC
        Aadd(a_RgT080AA[nLinha][2][1],c_SituaDoc)         // 03 - COD_SIT
        Aadd(a_RgT080AA[nLinha][2][1],cCumpoFis)          // 04 - NUM_CFE
        Aadd(a_RgT080AA[nLinha][2][1],SFT->FT_VALCONT)    // 05 - VL_CFE
        Aadd(a_RgT080AA[nLinha][2][1],cCnpjPart)          // 06 - CNPJ
        Aadd(a_RgT080AA[nLinha][2][1],cCpfPart)           // 07 - CPF
        Aadd(a_RgT080AA[nLinha][2][1],SFT->FT_CHVNFE)     // 08 - CHV_CFE
        Aadd(a_RgT080AA[nLinha][2][1],SFT->FT_DESCONT)    // 09 - VL_DESC
        Aadd(a_RgT080AA[nLinha][2][1],SFT->FT_TOTAL)      // 10 - VL_MERC
        Aadd(a_RgT080AA[nLinha][2][1],SFT->FT_DESPESA)    // 11 - VL_OUT_DA
    Else
        a_RgT080AA[nLinha][2][1][05] += SFT->FT_VALCONT
        a_RgT080AA[nLinha][2][1][09] += SFT->FT_DESCONT
        a_RgT080AA[nLinha][2][1][10] += SFT->FT_TOTAL
        a_RgT080AA[nLinha][2][1][11] += SFT->FT_DESPESA
    EndIf

Return Nil

/*/{Protheus.doc} RegT080AB
    (Função para gerar o registro T080AB - Cadastro dos Itens do Cupom Fiscal Eletrônico emitido pelo SAT-CF-e)

    @type Static Function
    @author Vitor Ribeiro
    @since 22/02/2018
    
    @param a_RgT080AB, array, contém as informações do registro T080AB
    @param c_Origem, caracter, contém a origem do produto.
    @param n_T080, numerico, contém a linha do array T080
    @param n_T080AA, numerico, contém a linha do array T080AA

    @return Nil, nulo, não tem retorno.
    /*/
Static Function RegT080AB(a_RgT080AB,c_Origem,n_T080,n_T080AA)

    Local nLinha := 0

    Default a_RgT080AB := {}
    
    Default c_Origem := ""

    Default n_T080 := 0
    Default n_T080AA := 0

    Aadd(a_RgT080AB,{n_T080,n_T080AA,{{}}})
    nLinha := Len(a_RgT080AB)

    Aadd(a_RgT080AB[nLinha][3][1],"T080AB")           // 01 - REGISTRO
    Aadd(a_RgT080AB[nLinha][3][1],SFT->FT_PRODUTO)    // 02 - COD_ITEM
    Aadd(a_RgT080AB[nLinha][3][1],SFT->FT_VALCONT)    // 03 - VL_OPR
    Aadd(a_RgT080AB[nLinha][3][1],SFT->FT_CFOP)       // 04 - CFOP
    Aadd(a_RgT080AB[nLinha][3][1],"")                 // 05 - COD_OBS
    Aadd(a_RgT080AB[nLinha][3][1],SFT->FT_CONTA)      // 06 - COD_CTA
    Aadd(a_RgT080AB[nLinha][3][1],c_Origem)           // 07 - ORIGEM

Return Nil

/*/{Protheus.doc} RegT080AC
    (Função para gerar o registro T080AC - Cadastro dos Tributos dos Itens do Cupom Fiscal Eletrônico emitido pelo SAT-CF-e)

    @type Static Function
    @author Vitor Ribeiro
    @since 22/02/2018
    
    @param a_RgT080AC, array, contém as informações do registro T080AC
    @param a_PartDoc, array, contém as informações do participante.
    @param c_Especie, caracter, contém a especie do documento.
    @param n_T080, numerico, contém a linha do array T080
    @param n_T080AA, numerico, contém a linha do array T080AA
    @param n_T080AB, numerico, contém a linha do array T080AB

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT080AC(a_RgT080AC,a_PartDoc,c_Especie,n_T080,n_T080AA,n_T080AB)
    
    Local nLinha := 0

    Default a_RgT080AC := {}
    Default a_PartDoc := {}

    Default c_Especie := ""

    Default n_T080 := 0
    Default n_T080AA := 0
    Default n_T080AB := 0

    /*
        Função para buscar os tributos do item do movimento ECF
        FBusTribNf(c_Especie,a_PartDoc,a_RgT013AP,a_RgT015AE,n_ItT015,a_RgT078AF,n_ItT078AE,a_RgT080AC,n_ItT080,n_ItT080AA,n_ItT080AB,a_ClasFis,n_RecnoCDG)
    */
    FBusTribNf(c_Especie,a_PartDoc,,,,,,@a_RgT080AC,n_T080,n_T080AA,n_T080AB,,)

Return Nil

/*/{Protheus.doc} RegT080AD
    (Função para gerar o registro T080AD - Processos referenciados)

    @type Static Function
    @author Vitor Ribeiro
    @since 22/02/2018
    
    @param a_RgT080AD, array, contém as informações do registro T080AD.
    @param c_ChaveSFT, caracter, chave da SFT.
    @param n_T080, numerico, contém a linha do array T080
    @param n_T080AA, numerico, contém a linha do array T080AA

    @return Nil, nulo, não tem retorno
    /*/
Static Function RegT080AD(a_RgT080AD,c_ChaveSFT,n_T080,n_T080AA)

    Local nLinha := 0

    Default a_RgT080AD := {}

    Default c_ChaveSFT := ""

    Default n_T080 := 0
    Default n_T080AA := 0

    If CDG->(DbSeek(xFilial("CDG")+c_ChaveSFT))

        While CDG->(!Eof()) .And. CDG->(CDG_FILIAL+CDG_TPMOV+CDG_DOC+CDG_SERIE+CDG_CLIFOR+CDG_LOJA) == xFilial("CDG")+c_ChaveSFT
            Aadd(a_RgT080AD,{n_T080,n_T080AA,{{}}})
            nLinha := Len(a_RgT080AD)

            Aadd(a_RgT080AD[nLinha][3][1],"T080AD")           // 01 - REGISTRO
            Aadd(a_RgT080AD[nLinha][3][1],CDG->CDG_PROCES)    // 02 - NUM_PROC
            Aadd(a_RgT080AD[nLinha][3][1],CDG->CDG_TPPROC)    // 03 - IND_PROC

            CDG->(DbSkip())
        EndDo

    EndIf

Return Nil

/*/{Protheus.doc} fGravaReg
    (Função para gravar os registros)

    @type Static Function
    @author Vitor Ribeiro
    @since 22/02/2018

    @param a_RgT080, array, contém os dados da T080
    @param a_RgT080AA, array, contém os dados da T080AA
    @param a_RgT080AB, array, contém os dados da T080AB
    @param a_RgT080AC, array, contém os dados da T080AC
    @param a_RgT080AD, array, contém os dados da T080AD
    @param n_HdlTxt, numerico, handle do arquivo gerado

    @return Nil, nulo, não tem retorno
    /*/
Static Function fGravaReg(a_RgT080,a_RgT080AA,a_RgT080AB,a_RgT080AC,a_RgT080AD,n_HdlTxt)

    Local nT080 := 0
    Local nT080AA := 0
    Local nT080AB := 0
    Local nT080AC := 0
    Local nT080AD := 0

    Default a_RgT080 := {}
    Default a_RgT080AA := {}
    Default a_RgT080AB := {}
    Default a_RgT080AC := {}
    Default a_RgT080AD := {}

    Default n_HdlTxt := 0

    For nT080 := 1 To Len(a_RgT080)
        // Grava o registro T080
        If !Empty(a_RgT080[nT080])
            FConcTxt(a_RgT080[nT080],n_HdlTxt)
        EndIf

        // Acha a linha no registro T080AA
        nT080AA := AScan(a_RgT080AA,{|x| x[1] == nT080 })

        While !Empty(nT080AA) .And. nT080AA <= Len(a_RgT080AA) .And. nT080 == a_RgT080AA[nT080AA][1]
            // Grava o registro T080AA
            If !Empty(a_RgT080AA[nT080AA][2])
                FConcTxt(a_RgT080AA[nT080AA][2],n_HdlTxt)
            EndIf
            
            // Acha a linha no registro T080AB
            nT080AB := AScan(a_RgT080AB,{|x| x[1] == nT080 .And. x[2] == nT080AA })

            While !Empty(nT080AB) .And. nT080AB <= Len(a_RgT080AB) .And. nT080 == a_RgT080AB[nT080AB][1] .And. nT080AA == a_RgT080AB[nT080AB][2]
                // Grava o registro T080AB
                If !Empty(a_RgT080AB[nT080AB][3])
                    FConcTxt(a_RgT080AB[nT080AB][3],n_HdlTxt)
                EndIf
                
                // Acha a linha no registro T080AC
                nT080AC := AScan(a_RgT080AC,{|x| x[1] == nT080 .And. x[2] == nT080AA .And. x[3] == nT080AB })

                While !Empty(nT080AC) .And. nT080AC <= Len(a_RgT080AC) .And. nT080 == a_RgT080AC[nT080AC][1] .And. nT080AA == a_RgT080AC[nT080AC][2] .And. nT080AB == a_RgT080AC[nT080AC][3]
                    // Grava o registro T080AC
                    If !Empty(a_RgT080AC[nT080AC][4])
                        FConcTxt(a_RgT080AC[nT080AC][4],n_HdlTxt)
                    EndIf

                    nT080AC++
                EndDo

                nT080AB++
            EndDo

            // Acha a linha no registro T080AB
            nT080AD := AScan(a_RgT080AD,{|x| x[1] == nT080 .And. x[2] == nT080AA })

            While !Empty(nT080AD) .And. nT080AD <= Len(a_RgT080AD) .And. nT080 == a_RgT080AD[nT080AD][1] .And. nT080AA == a_RgT080AD[nT080AD][2]
                // Grava o registro T080AD
                If !Empty(a_RgT080AD[nT080AD][3])
                    FConcTxt(a_RgT080AD[nT080AD][3],n_HdlTxt)
                EndIf

                nT080AD++
            EndDo

            nT080AA++
        EndDo
    Next

    // Zera os arrays
    ASize(a_RgT080,0)
    ASize(a_RgT080AA,0)
    ASize(a_RgT080AB,0)
    ASize(a_RgT080AC,0)
    ASize(a_RgT080AD,0)

Return Nil