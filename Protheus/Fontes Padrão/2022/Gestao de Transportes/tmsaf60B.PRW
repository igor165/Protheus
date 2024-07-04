
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF60.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} TMSF60Qry
	(long_description)
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function TMSF60Qry( nOpcx, cRota, lOrderBy, cFiltroDUD , cSerTms , cTipTra , cSerAdi , lVgeMod2 , lVgeExpr, lCdrOri, nTipVia , lColeta, cGrpProd, nCarreg , cRotGen, nRotGen , lTmsCFec , lVgeColet , cZona, cSetor )

Local cStatus   := StrZero(1,Len(DUD->DUD_STATUS))
Local cVgeAux   := Space(Len(DUD->DUD_VIAGEM))
Local cQuery    := ""
Local cFilDT5   := xFilial("DT5")
Local lAlianca  := TmsAlianca() //-- Verifica se utiliza Alianca
Local lPesqCCli := SuperGetMv("MV_TMSPCLI",,.F.)	//-- Atraves deste parametro é possivel fazer com que o
													//-- Pontos por setor sejam pesquisados por codigo de Cliente.

Local cQueryTp  := If("POSTGRES"$TCGetDb(),"Char(1)","") //-- Usado em query BD POSTGRES
Local lDTP 	  	:= .F.
Local lTMSDCol 	:= SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.
Local cQryDTP	:= ""
Local cAliasDTP	:= ""
Local cCdrOri	:= PadR(GetMv('MV_CDRORI'),Len(DA8->DA8_CDRORI))
Local lVgeMod3	:= TmsVgeMod3()
Local oModel    := FWModelActive()
Local cFilOri   := Space(Len(DTQ->DTQ_FILORI))
Local cViagem   := Space(Len(DTQ->DTQ_VIAGEM))
Local cRotaVge  := ""
Local cStatusVge:= ""

Default nOpcX		:= 3 
Default cRota       := ""
Default lOrderBy    := .T.
Default cFiltroDUD  := ""
Default cSerTms		:= ""
Default cTipTra		:= ""
Default cSerAdi		:= ""
Default lVgeMod2	:= ("TMSA144" $ AllTrim(FunName())) 
Default lVgeExpr	:= Iif( !lVgeMod2 .Or. lVgeMod3, .F. , .T. ) 
Default lCdrOri		:= .F. 
Default cSerAdi		:= ""
Default nTipVia		:=  Iif( !Empty(M->DTQ_TIPVIA),Val( M->DTQ_TIPVIA ), 1 )
Default lColeta 	:= ( cSerTms == StrZero( 1, Len( DC5->DC5_SERTMS ) ) )
Default cGrpProd	:= ""
Default nCarreg		:= 0 
Default cRotGen 	:= Iif(lColeta,GetMv('MV_ROTGCOL',,''),GetMv('MV_ROTGENT',,''))
Default nRotGen		:= 0 
Default lTmsCFec	:= TmsCFec()
Default lVgeColet	:= .F. 
Default cZona		:= ""
Default cSetor		:= ""

If ValType(oModel) == "O" .And. oModel:cID $ "TMSAF90"   //Carrega Variaveis do Carregamento
	TMSF60Var(oModel,@cFilOri,@cViagem,@cRotaVge,@cStatusVge,@nTipVia,@cVgeAux)
Else
	cFilOri   := M->DTQ_FILORI
	cViagem   := M->DTQ_VIAGEM
	cRotaVge  := M->DTQ_ROTA
	cStatusVge:= M->DTQ_STATUS
EndIf

If cSerTms == '2'
	If !lVgeExpr
		cQuery := " SELECT DUD.DUD_FILDOC, DUD.DUD_DOC, DUD.DUD_SERIE, DUD.R_E_C_N_O_ DUDRECNO "
		cQuery += "   FROM " + RetSQLTab("DUD")
		cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "     AND DUD_SERTMS = '" + cSerTms + "' "
		cQuery += "     AND DUD_TIPTRA = '" + cTipTra + "' "
		If TmsCarMod3()
			cQuery += "     AND DUD_VIAGEM = '" + cViagem + "' "
		Else
			cQuery += "     AND DUD_VIAGEM = ' ' "
		EndIf
		cQuery += "     AND DUD_STATUS = '" + StrZero(1,Len(DUD->DUD_STATUS)) + "' "
		If !lTMSDCol
			cQuery += "     AND DUD_FILORI = '" + cFilAnt + "'"
		EndIf
		cQuery += "     AND D_E_L_E_T_ = ' ' "
	Else
		cQuery := " SELECT DUD.DUD_FILDOC, DUD.DUD_DOC, DUD.DUD_SERIE, DUD.R_E_C_N_O_ DUDRECNO "
		cQuery += "   FROM " + RetSQLTab("DUD")
		cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "     AND DUD_SERTMS = '" + cSerTms + "' "
		cQuery += "     AND DUD_TIPTRA = '" + cTipTra + "' "
		If !lTMSDCol
			cQuery += "     AND DUD_FILORI = '" + cFilAnt + "'"
		EndIf
		cQuery += "     AND DUD_VIAGEM = '" + cViagem + "' "
		cQuery += "     AND D_E_L_E_T_ = ' ' "
	EndIf
	If !Empty(cFiltroDUD)
		cQuery += cFiltroDUD
	EndIf
ElseIf nTipVia == 2 //-- Viagem Vazia
	cQuery := TM141QryVz(nOpcx,cRota)
Else
	If nOpcx <> 3
		If lOrderBy
			If Empty(cRota)
				cQuery += " SELECT "
				cQuery += " DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(TIPROT) TIPROT, "
				cQuery += " DA5_COD, MIN(DA5_DESC) DA5_DESC, DA6_ROTA, MIN(DA6_REF) DA6_REF , "
				cQuery += " MIN(DUD_STATUS) DUD_STATUS, SUM(DT6_QTDVOL) DT6_QTDVOL, SUM(DT6_PESO) DT6_PESO    , SUM(DT6_VOLORI) DT6_VOLORI, "
				cQuery += " SUM(DT6_PESOM3) DT6_PESOM3, SUM(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS," + cQueryTp + " 'X' CVISUAL "
				cQuery += "  FROM ( "
				cQuery += " SELECT "
				cQuery += " DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(DA8_TIPROT) TIPROT, "
				cQuery += " DA5_COD, MIN(DA5_DESC) DA5_DESC, DA6_ROTA, MIN(DA6_REF) DA6_REF , "
				cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_VOLORI) DT6_VOLORI, "
				cQuery += " MIN(DT6_PESOM3) DT6_PESOM3, MIN(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS, DUD_FILDOC, DUD_DOC, DUD_SERIE," + cQueryTp + " 'X' CVISUAL "
			Else
				If lColeta
					cQuery += " SELECT "
					cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
					cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM)  DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
					cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI)  DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
					cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)    DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
					cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT5_SEQEND)  DT5_SEQEND, MIN(DT5_DATSOL) DT5_DATSOL, "
					cQuery += " MIN(DT5_HORSOL) DT5_HORSOL, MIN(DT5_DATPRV)  DT5_DATPRV, MIN(DT5_HORPRV) DT5_HORPRV, "
					cQuery += " MIN(DT5_CODSOL) DT5_CODSOL, "
					cQuery += " MIN(DT5_DDD)    DT5_DDD   , MIN(DT5_TEL)     DT5_TEL   , MIN(DT6_VOLORI) DT6_VOLORI, "
					If nOpcx == 2
						cQuery += " MIN(DUD_ZONA) DA7_PERCUR, "
					Else
						cQuery += " MIN(DA6_PERCUR) DA7_PERCUR, "
					EndIf
					cQuery += cQueryTp + " ' ' DA7_SEQUEN, MIN(DA6_ROTA)   DA7_ROTA "
					If !lVgeMod2 .And. lTmsCFec
						//-- Retorna os campos referente ao Agendamento.
						cQuery += ", MIN(DF1_ITEAGE) DF1_ITEAGE "
						cQuery += ", MIN(DF1_NUMAGE) DF1_NUMAGE "
						cQuery += ", MIN(DT5_CLIDES) DT5_CLIDES "
						cQuery += ", MIN(DT5_LOJDES) DT5_LOJDES "
						cQuery += ", MIN(DT5_DATENT) DT5_DATENT "
						cQuery += ", MIN(DT5_HORENT) DT5_HORENT "
						cQuery += ", MIN(DUD_SEQENT) DUD_SEQENT "
					EndIf
				Else
					cQuery += " SELECT "
					cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
					cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
					cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI) DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
					cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
					cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT6_CLIREM) DT6_CLIREM, MIN(DT6_LOJREM) DT6_LOJREM, "
					cQuery += " MIN(DT6_CLIDES) DT6_CLIDES, MIN(DT6_LOJDES) DT6_LOJDES, "
					If nOpcx == 2
						cQuery += " MIN(DUD_ZONA) DA7_PERCUR, "
					Else
						cQuery += " MIN(DA6_PERCUR) DA7_PERCUR, "
					EndIf

					cQuery += cQueryTp //-- Usado em query BD POSTGRES
					cQuery += " ''              DA7_SEQUEN, MIN(DA6_ROTA)  DA7_ROTA   , MIN(DT6_VOLORI) DT6_VOLORI  "
				EndIf
			EndIf
		Else
			cQuery += " SELECT "
			cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, DUD.R_E_C_N_O_ DUDRECNO "
		EndIf
		cQuery += " FROM "
		If lColeta .And. !lVgeMod2 .And. lTmsCFec
			//-- Verifica se existe Agendamento associado a Solicitacao de Coleta.
			cQuery +=   RetSqlName('DUD') + " DUD "//Movimento de Viagem
			cQuery += "LEFT JOIN " + RetSqlName('DF1') + " DF1 "
			cQuery += "  ON DF1_FILIAL     = '" + xFilial("DF1") + "'"
			cQuery += " AND DF1_FILDOC     = DUD_FILDOC"
			cQuery += " AND DF1_DOC        = DUD_DOC"
			cQuery += " AND DF1_SERIE      = DUD_SERIE"
			cQuery += " AND DF1.D_E_L_E_T_ = ' ', "
		Else
			cQuery +=   RetSqlName('DUD') + " DUD, "//Movimento de Viagem
		EndIf
		cQuery +=  RetSqlName('DA6') + " DA6, " //Cadastro de setor x Zona
		cQuery +=  RetSqlName('DA5') + " DA5, " //Cadastro de Zonas
		cQuery +=  RetSqlName('DA8') + " DA8, "//Documentos de transporte
		cQuery +=  RetSqlName('DA9') + " DA9, "// Zonas x Rotas
		cQuery +=  RetSqlName('DT6') + " DT6 "//Documentos de transporte
		If lColeta
			cQuery +=   "," + RetSqlName('DT5') + " DT5 "//Solicitacao de coleta
		EndIf
		cQuery += " WHERE DUD_FILIAL     = '" + xFilial("DUD") + "' "
		cQuery += "   AND DUD_FILORI     = '" + cFilOri  + "' "
		cQuery += "   AND DUD_VIAGEM     = '" + cViagem  + "' "
		If !Empty(cSerAdi)
			cQuery += "AND DUD_SERTMS IN  ( '" + cSerTms + "', '" + cSerAdi + "' )"
		Else
			cQuery += "AND DUD_SERTMS     = '" + cSerTms + "'"
		EndIf
		cQuery += "   AND DUD_TIPTRA     = '" + cTipTra + "'"
		cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
		If !Empty(cFiltroDUD)
			cQuery += cFiltroDUD
		EndIf
		cQuery += "   AND DT6_FILIAL     = '" + xFilial("DT6") + "'"
		cQuery += "   AND DT6_FILDOC     = DUD_FILDOC "
		cQuery += "   AND DT6_DOC        = DUD_DOC "
		cQuery += "   AND DT6_SERIE      = DUD_SERIE "
		cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
		If lColeta
			If Empty(cFilDT5)
				cQuery += "AND DT5_FILIAL = '" + xFilial("DT5") + "'"
			Else
				cQuery += "AND DT5_FILIAL = DUD_FILDOC "
			EndIf
			cQuery += "   AND DT5_FILDOC     = DUD_FILDOC "
			cQuery += "   AND DT5_DOC        = DUD_DOC "
			cQuery += "   AND DT5_SERIE      = DUD_SERIE "
			cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery += "   AND DA8_FILIAL     = '" + xFilial("DA8") + "'"
		cQuery += "   AND DA8_COD        = '" + cRotaVge + "'"
		cQuery += "   AND DA8.D_E_L_E_T_ = ' ' "
		cQuery += "   AND DA5_FILIAL     = '" + xFilial("DA5") + "'"
		If lVgeColet
			cQuery += "   AND DA5_COD        ='" + cZona + "'"
		Else
			cQuery += "   AND DA5_COD        =  DUD_ZONA "
		EndIf
		cQuery += "   AND DA5.D_E_L_E_T_ = ' ' "
		cQuery += "   AND DA6_FILIAL     = '" + xFilial("DA6") + "'"
		cQuery += "   AND DA6_PERCUR     =  DUD_ZONA "

		If lVgeColet
			cQuery += "   AND DA6_ROTA       ='" + cSetor + "'"
		Else
			cQuery += "   AND DA6_ROTA       =  DUD_SETOR "
		EndIf
		cQuery += "   AND DA6.D_E_L_E_T_ = ' ' "

		If Empty(cRota)
			cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE, DA8_COD, DA5_COD, DA6_ROTA ) QUERY "
			cQuery += " GROUP BY DA8_COD, DA5_COD, DA6_ROTA"
		Else
			cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE"
		EndIf
	EndIf

	If nOpcx == 3 .Or. nOpcx == 4
		If nOpcx == 4 //Se for alteracao traz os dados que estao gravados, junto com os dados novos pra incluir
			cQuery +=" UNION ALL "

            // Viagem de entrega e status em transito.
            If cSerTms == StrZero(3,Len(DT6->DT6_SERTMS)) .AND. cStatusVge == "2"
                lDTP := .T.
            Else
                //Verificar se há Lote com Viagem Preenchdida
                cAliasDTP := GetNextAlias()
                cQryDTP := " SELECT COUNT(DTP_LOTNFC) as TOT_LOTE FROM "
                cQryDTP += RetSqlName('DTP') + " DTP WHERE "
                cQryDTP += "  DTP.DTP_FILIAL = '" + xFilial("DTP") + "'"
                cQryDTP += "  AND DTP.DTP_VIAGEM = '" + cViagem + "'"
                cQryDTP += "  AND DTP.D_E_L_E_T_ = ' ' "
                cQryDTP := ChangeQuery(cQryDTP)
                dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryDTP ), cAliasDTP, .F., .T. )

                If (cAliasDTP)->TOT_LOTE > 0 .And. lVgeMod2
                    lDTP := .T.
                EndIf
                (cAliasDTP)->(dbCloseArea())
            EndIf
		EndIf
		If lOrderBy
			If Empty(cRota)
				cQuery += " SELECT "
				cQuery += " DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(TIPROT) TIPROT, "
				cQuery += " DA5_COD, MIN(DA5_DESC) DA5_DESC, DA6_ROTA, MIN(DA6_REF) DA6_REF , "
				cQuery += " MIN(DUD_STATUS) DUD_STATUS, SUM(DT6_QTDVOL) DT6_QTDVOL, SUM(DT6_PESO)   DT6_PESO  , SUM(DT6_VOLORI) DT6_VOLORI, "
				cQuery += " SUM(DT6_PESOM3) DT6_PESOM3, SUM(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS," + cQueryTp + " 'O' CVISUAL "
				cQuery += "  FROM ( "
				cQuery += " SELECT "
				cQuery += " DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(DA8_TIPROT) TIPROT, "
				cQuery += " DA5_COD, MIN(DA5_DESC) DA5_DESC, DA6_ROTA, MIN(DA6_REF) DA6_REF , "
				cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_VOLORI) DT6_VOLORI, "
				cQuery += " MIN(DT6_PESOM3) DT6_PESOM3, MIN(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS, DUD_FILDOC, DUD_DOC, DUD_SERIE," + cQueryTp + " 'O' CVISUAL "
			Else
				If lColeta
					cQuery += " SELECT "
					cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
					cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
					cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI) DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
					cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
					cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT5_SEQEND) DT5_SEQEND, MIN(DT5_DATSOL) DT5_DATSOL, "
					cQuery += " MIN(DT5_HORSOL) DT5_HORSOL, MIN(DT5_DATPRV) DT5_DATPRV, MIN(DT5_HORPRV) DT5_HORPRV, "
					cQuery += " MIN(DT5_CODSOL) DT5_CODSOL, "
					cQuery += " MIN(DT5_DDD)    DT5_DDD   , MIN(DT5_TEL)    DT5_TEL   , MIN(DT6_VOLORI) DT6_VOLORI, "
					If nOpcx == 2
						cQuery += " MIN(DUD_ZONA) DA7_PERCUR, "
					Else
						cQuery += " MIN(DA6_PERCUR) DA7_PERCUR, "
					EndIf
					cQuery += " MIN(DA7_SEQUEN) DA7_SEQUEN, MIN(DA7_ROTA)   DA7_ROTA    "
					If !lVgeMod2 .And. lTmsCFec
						//-- Retorna os campos referente ao Agendamento.
						cQuery += ", MIN(DF1_ITEAGE) DF1_ITEAGE "
						cQuery += ", MIN(DF1_NUMAGE) DF1_NUMAGE "
						cQuery += ", MIN(DT5_CLIDES) DT5_CLIDES "
						cQuery += ", MIN(DT5_LOJDES) DT5_LOJDES "
						cQuery += ", MIN(DT5_DATENT) DT5_DATENT "
						cQuery += ", MIN(DT5_HORENT) DT5_HORENT "
						cQuery += ", MIN(DUD_SEQENT) DUD_SEQENT "
					EndIf
				Else
					cQuery += " SELECT "
					cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
					cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
					cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI) DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
					cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
					cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT6_CLIREM) DT6_CLIREM, MIN(DT6_LOJREM) DT6_LOJREM, "
					cQuery += " MIN(DT6_CLIDES) DT6_CLIDES, MIN(DT6_LOJDES) DT6_LOJDES, MIN(DA7_PERCUR) DA7_PERCUR, "
					cQuery += " MIN(DA7_SEQUEN) DA7_SEQUEN, MIN(DA7_ROTA)   DA7_ROTA  , MIN(DT6_VOLORI) DT6_VOLORI  "
				EndIf
			EndIf
		Else
			cQuery += " SELECT "
			cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, DUD.R_E_C_N_O_ DUDRECNO "
		EndIf
		cQuery += " FROM "
		If lColeta .And. !lVgeMod2 .And. lTmsCFec .And. !Empty(cRota)
			//-- Verifica se existe Agendamento associado a Solicitacao de Coleta.
			cQuery +=   RetSqlName('DUD') + " DUD "//Movimento de Viagem
			cQuery += "LEFT JOIN " + RetSqlName('DF1') + " DF1 ON"
			cQuery += " DF1_FILIAL = '" + xFilial("DF1") + "'"
			cQuery += " AND DF1_FILDOC = DUD_FILDOC"
			cQuery += " AND DF1_DOC = DUD_DOC"
			cQuery += " AND DF1_SERIE = DUD_SERIE"
			cQuery += " AND DF1.D_E_L_E_T_ = ' ', "
		Else
			cQuery +=   RetSqlName('DUD') + " DUD, "//Movimento de Viagem
			If lDTP
				cQuery += RetSqlName('DTP') + " DTP, "
			EndIf
		EndIf
		cQuery +=  RetSqlName('DA8') + " DA8, "//Documentos de transporte
		cQuery +=  RetSqlName('DA7') + " DA7, " // Clientes por setor
		cQuery +=  RetSqlName('DA9') + " DA9, "// Zonas x Rotas
		cQuery +=  RetSqlName('DT6') + " DT6, "//Documentos de transporte
		cQuery +=  RetSqlName('DA5') + " DA5, "//Zonas
		cQuery +=  RetSqlName('DA6') + " DA6  " //Setor x Zonas
		If lColeta
			cQuery +=   ", " + RetSqlName('DT5') + " DT5 "//Solicitacao de coleta
		EndIf
		If !Empty(cGrpProd) //-- Filtra por Grupo de Produtos
			If lColeta
				cQuery += ", " + RetSqlName('SB1') + " SB1  "//Produtos
				cQuery += ", " + RetSqlName('DUM') + " DUM "//Itens da Solicitacao de Coleta
			Else
				cQuery +=  ", " + RetSqlName('DTC') + " DTC "//Notas Fiscais
				cQuery +=  ", " + RetSqlName('SB1') + " SB1 "//Produtos
			EndIf
		EndIf
		cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
		If !lTMSDCol
			cQuery += " AND DUD_FILORI = '" + cFilAnt + "'"
		EndIf
		If !Empty(cSerAdi)
			cQuery += "AND DUD_SERTMS IN  ( '" + cSerTms + "', '" + cSerAdi + "' )"
		Else
			cQuery += "AND DUD_SERTMS     = '" + cSerTms + "'"
		EndIf
		cQuery += " AND DUD_TIPTRA = '" + cTipTra + "'"
		//-- Faz com que caso seja utilizado uma viagem TMSEXPRESS
		//-- os documentos que serão utilizados serão os que já foram
		//-- calculados para aquela viagem.
		If lVgeMod2 .And. lVgeExpr
			If(nCarreg == 1)//-- Caso seja uma viagem com carregamento manual.
				cQuery += " AND DUD_STATUS = '" + StrZero(1,Len(DUD->DUD_STATUS)) + "' "
			ElseIf(nCarreg == 2)//-- Caso seja uma viagem com carregamento automático.
				cQuery += " AND DUD_STATUS IN ('" + StrZero(1,Len(DUD->DUD_STATUS)) + "', '" + StrZero(3,Len(DUD->DUD_STATUS)) + "' )"
			EndIf
			cQuery += " AND DUD_VIAGEM = '" + cViagem + "'"
		Else
			cQuery += " AND DUD_STATUS = '" + cStatus + "' "
			cQuery += " AND DUD_VIAGEM = '" + cVgeAux + "'"
		EndIf
		//-- Pesquisa rota por codigo de cliente
		If ( cSerTms == StrZero( 1, Len( DC5->DC5_SERTMS ) )  .Or. cSerTms == StrZero( 3, Len( DC5->DC5_SERTMS ) ) ).And. ;
			lPesqCCli // Se Coleta ou Entrega e Parametro MV_TMSPCLI esta ativo pesquisa codigo e cep de destino
			cQuery += " AND ( DUD_CEPENT BETWEEN DA7_CEPDE AND DA7_CEPATE "
			cQuery += " OR  DT6_CLIDES = DA7_CLIENT "
			cQuery += " AND DT6_LOJDES = DA7_LOJA  )"
		Else
			cQuery += " AND DUD_CEPENT BETWEEN DA7_CEPDE AND DA7_CEPATE "
		EndIf
		cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
		If !Empty(cFiltroDUD)
			cQuery += cFiltroDUD
		EndIf

		If nCarreg == 2
			cQuery += " AND DUD.DUD_NUMRED = ' ' "
		EndIf

		cQuery += " AND DT6_FILIAL = '" + xFilial("DT6") + "'"
		cQuery += " AND DT6_FILDOC = DUD_FILDOC "
		cQuery += " AND DT6_DOC    = DUD_DOC "
		cQuery += " AND DT6_SERIE  = DUD_SERIE "
		cQuery += " AND DT6_STATUS <> '7'" //-- Entregue
		cQuery += " AND DT6.D_E_L_E_T_ = ' ' "

		If lDTP
			cQuery += " AND ( DTP_LOTNFC = DT6_LOTNFC AND DTP_VIAGEM = '" +  cViagem + "'"
			cQuery += " OR DUD_SERTMS = '1' ) "
		EndIf

		If lColeta
			If Empty(cFilDT5)
				cQuery += "   AND DT5_FILIAL = '" + xFilial("DT5") + "'"
			Else
				cQuery += "   AND DT5_FILIAL = DUD_FILDOC "
			EndIf
			cQuery += "   AND DT5_FILDOC     = DUD_FILDOC "
			cQuery += "   AND DT5_DOC        = DUD_DOC "
			cQuery += "   AND DT5_SERIE      = DUD_SERIE "
			cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
		EndIf
		If !Empty(cGrpProd) //-- Filtra Grupo de Produtos
			If lColeta
				cQuery += " AND DUM_FILIAL     = '" + xFilial("DUM") + "'"
				cQuery += " AND DUM_FILORI     = DT5_FILORI "
				cQuery += " AND DUM_NUMSOL     = DT5_NUMSOL"
				cQuery += " AND DUM.D_E_L_E_T_ = ' ' "
				cQuery += " AND B1_FILIAL  = '" + xFilial("SB1") + "'"
				cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
				cQuery += " AND B1_COD     = DUM_CODPRO "
				cQuery += " AND SB1.D_E_L_E_T_    = ' '"
			ElseIf !Empty(cSerAdi)
				cQuery += " AND B1_FILIAL   = '"+xFilial("SB1")+"'"
				cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
				cQuery += " AND B1_COD  = DTC_CODPRO"
				cQuery += " AND SB1.D_E_L_E_T_    = ' '"
			Else
				cQuery += " AND DTC_FILIAL    = '"+xFilial("DTC")+"'"
				cQuery += " AND DTC_FILDOC    = DT6.DT6_FILDOC"
				cQuery += " AND DTC_DOC       = DT6.DT6_DOC"
				cQuery += " AND DTC_SERIE     = DT6.DT6_SERIE"
				cQuery += " AND DTC_QTDVOL    > 0"
				cQuery += " AND DTC.D_E_L_E_T_    = ' '"
				cQuery += " AND B1_FILIAL   = '"+xFilial("SB1")+"'"
				cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
				cQuery += " AND B1_COD  = DTC_CODPRO"
				cQuery += " AND SB1.D_E_L_E_T_    = ' '"
			EndIf
		EndIf
		cQuery += " AND DA7_FILIAL = '" + xFilial("DA7") + "'"
		cQuery += " AND DA7.D_E_L_E_T_ = ' ' "
		cQuery += " AND DA6_FILIAL = '" + xFilial("DA6") + "'"
		cQuery += " AND DA6_PERCUR = DA7_PERCUR "
		cQuery += " AND DA6_ROTA   = DA7_ROTA "
		cQuery += " AND DA6.D_E_L_E_T_ = ' ' "
		If lAlianca
			cQuery += " AND DA6_ALIANC = ' ' "
		EndiF
		cQuery += " AND DA5_FILIAL = '" + xFilial("DA5") + "'"
		cQuery += " AND DA5_COD    = DA6_PERCUR "
		cQuery += " AND DA5.D_E_L_E_T_ = ' ' "
		cQuery += " AND DA9_FILIAL = '" + xFilial("DA9") + "'"
		cQuery += " AND DA9_PERCUR = DA7_PERCUR "
		cQuery += " AND DA9_ROTA   = DA7_ROTA   "
		If !Empty(cRotGen) .And. cRota <> cRotGen //Se tiver rota generica cadastrada precisa filtrar para mostrar apenas no botao de documentos com rota generica
			cQuery += " AND DA9_ROTEIR <> '" + cRotGen + "'"
		EndIf
		If !Empty(cRota)
			cQuery += " AND DA9_ROTEIR = '" + cRota + "'"
		EndIf
		cQuery += " AND DA9.D_E_L_E_T_ = ' ' "
		cQuery += " AND DA8_FILIAL = '" + xFilial("DA8") + "'"
		cQuery += " AND DA8_COD    = DA9_ROTEIR "
		cQuery += " AND DA8_SERTMS = '" + cSerTms + "'"
		cQuery += " AND DA8_TIPTRA = '" + cTipTra + "'"
		If lCdrOri
			cQuery += " AND DA8_CDRORI = '" + cCdrOri + "'"
		EndIf
		cQuery += " AND DA8_ATIVO      = '1' "
		cQuery += " AND DA8.D_E_L_E_T_ = ' ' "
		If Empty(cRota)
			cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE, DA8_COD, DA5_COD, DA6_ROTA, DA7_PERCUR, DA7_ROTA, DA9_PERCUR, DA9_ROTA ) QUERY "
			cQuery += " GROUP BY DA8_COD, DA5_COD, DA6_ROTA "
		Else
			cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE"
		EndIf

		If lAlianca
			cQuery += " UNION ALL " //Alianca
			If lOrderBy
				If Empty(cRota)
					cQuery += " SELECT "
					cQuery += " DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(TIPROT) TIPROT, "
					cQuery += " DA5_COD, MIN(DA5_DESC) DA5_DESC, DA6_ROTA, MIN(DA6_REF) DA6_REF , "
					cQuery += " MIN(DUD_STATUS) DUD_STATUS, SUM(DT6_QTDVOL) DT6_QTDVOL, SUM(DT6_PESO)   DT6_PESO  , SUM(DT6_VOLORI) DT6_VOLORI, "
					cQuery += " SUM(DT6_PESOM3) DT6_PESOM3, SUM(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS," + cQueryTp + " 'O' CVISUAL "
					cQuery += "  FROM ( "
					cQuery += " SELECT "
					cQuery += "	DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(DA8_TIPROT) TIPROT, DA5_COD, "
					cQuery += "	MIN(DA5_DESC) DA5_DESC , DA6_ROTA, MIN(DA6_REF) DA6_REF , MIN(DUD_STATUS) DUD_STATUS, "
					cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3)  DT6_PESOM3   , MIN(DT6_VOLORI)  DT6_VOLORI, "
					cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS, DUD_FILDOC, DUD_DOC, DUD_SERIE, " + cQueryTp + " 'O' CVISUAL "
				Else
					If lColeta
						cQuery += " SELECT "
						cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
						cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
						cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI) DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
						cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
						cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT5_SEQEND) DT5_SEQEND, MIN(DT5_DATSOL) DT5_DATSOL, "
						cQuery += " MIN(DT5_HORSOL) DT5_HORSOL, MIN(DT5_DATPRV) DT5_DATPRV, MIN(DT5_HORPRV) DT5_HORPRV, "
						cQuery += " MIN(DT5_CODSOL) DT5_CODSOL, "
						cQuery += " MIN(DT5_DDD)    DT5_DDD   , MIN(DT5_TEL)    DT5_TEL   , MIN(DT6_VOLORI) DT6_VOLORI, "
						If nOpcx == 2
							cQuery += " MIN(DUD_ZONA) DA7_PERCUR, "
						Else
							cQuery += " MIN(DA6_PERCUR) DA7_PERCUR, "
						EndIf
						cQuery += cQueryTp + " '' DA7_SEQUEN, MIN(DA6_ROTA)   DA7_ROTA    "
						If !lVgeMod2 .And. lTmsCFec
							//-- Retorna os campos referente ao Agendamento.
							cQuery += ", MIN(DF1_ITEAGE) DF1_ITEAGE "
							cQuery += ", MIN(DF1_NUMAGE) DF1_NUMAGE "
							cQuery += ", MIN(DT5_CLIDES) DT5_CLIDES "
							cQuery += ", MIN(DT5_LOJDES) DT5_LOJDES "
							cQuery += ", MIN(DT5_DATENT) DT5_DATENT "
							cQuery += ", MIN(DT5_HORENT) DT5_HORENT "
							cQuery += ", MIN(DUD_SEQENT) DUD_SEQENT "
						EndIf
					Else
						cQuery += " SELECT "
						cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
						cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
						cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI) DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
						cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
						cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT6_CLIREM) DT6_CLIREM, MIN(DT6_LOJREM) DT6_LOJREM, "
						cQuery += " MIN(DT6_CLIDES) DT6_CLIDES, MIN(DT6_LOJDES) DT6_LOJDES, "
						If nOpcx == 2
							cQuery += " MIN(DUD_ZONA) DA7_PERCUR, "
						Else
							cQuery += " MIN(DA6_PERCUR) DA7_PERCUR, "
						EndIf
						cQuery += cQueryTp //-- Usado em query BD POSTGRES
						cQuery += " ''              DA7_SEQUEN, MIN(DA6_ROTA)   DA7_ROTA  , MIN(DT6_VOLORI) DT6_VOLORI  "
					EndIf
				EndIf
			Else
				cQuery += " SELECT "
				cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, DUD.R_E_C_N_O_ DUDRECNO "
			EndIf
			cQuery += " FROM "
			If lColeta .And. !lVgeMod2 .And. lTmsCFec .And. !Empty(cRota)
				//-- Verifica se existe Agendamento associado a Solicitacao de Coleta.
				cQuery +=   RetSqlName('DUD') + " DUD "//Movimento de Viagem
				cQuery += "LEFT JOIN " + RetSqlName('DF1') + " DF1 "
				cQuery += "  ON DF1_FILIAL = '" + xFilial("DF1") + "'"
				cQuery += " AND DF1_FILDOC = DUD_FILDOC"
				cQuery += " AND DF1_DOC = DUD_DOC"
				cQuery += " AND DF1_SERIE = DUD_SERIE"
				cQuery += " AND DF1.D_E_L_E_T_ = ' ', "
			Else
				cQuery +=   RetSqlName('DUD') + " DUD, "//Movimento de Viagem
			EndIf
			cQuery +=  RetSqlName('DA8') + " DA8, " // Rotas
			cQuery +=  RetSqlName('DA9') + " DA9, "//Documentos de transporte
			cQuery +=  RetSqlName('DT6') + " DT6, "//Documentos de transporte
			cQuery +=  RetSqlName('DA5') + " DA5, "//Zonas
			cQuery +=  RetSqlName('DA6') + " DA6  " //Setor x Zonas
			If lColeta
				cQuery +=   ", " + RetSqlName('DT5') + " DT5 "//Solicitacao de coleta
			EndIf
			If !Empty(cGrpProd) //-- Filtra por Grupo de Produtos
				If lColeta
					cQuery += ", " + RetSqlName('SB1') + " SB1  "//Produtos
					cQuery += ", " + RetSqlName('DUM') + " DUM "//Itens da Solicitacao de Coleta
				Else
					cQuery +=  ", " + RetSqlName('DTC') + " DTC "//Notas Fiscais
					cQuery +=  ", " + RetSqlName('SB1') + " SB1 "//Produtos
				EndIf
			EndIf
			cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
			If !lTMSDCol
				cQuery += " AND DUD_FILORI = '" + cFilAnt + "'"
			EndIf
			cQuery += " AND DUD_SERTMS = '" + cSerTms + "'"
			cQuery += " AND DUD_TIPTRA = '" + cTipTra + "'"
			cQuery += " AND DUD_STATUS = '" + cStatus + "' "
			cQuery += " AND DUD_VIAGEM = '" + cVgeAux + "'"
			cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
			If !Empty(cFiltroDUD)
				cQuery += cFiltroDUD
			EndIf
			cQuery += " AND DT6_FILIAL = '" + xFilial("DT6") + "'"
			cQuery += " AND DT6_FILDOC = DUD_FILDOC "
			cQuery += " AND DT6_DOC    = DUD_DOC "
			cQuery += " AND DT6_SERIE  = DUD_SERIE "
			cQuery += " AND DT6_ALIANC = DA6_ALIANC "
			cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
			If lColeta
				If Empty(cFilDT5)
					cQuery += " AND DT5_FILIAL = '" + xFilial("DT5") + "'"
				Else
					cQuery += " AND DT5_FILIAL = DUD_FILDOC "
				EndIf
				cQuery += "   AND DT5_FILDOC     = DUD_FILDOC "
				cQuery += "   AND DT5_DOC        = DUD_DOC "
				cQuery += "   AND DT5_SERIE      = DUD_SERIE "
				cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
			EndIf
			If !Empty(cGrpProd) //-- Filtra Grupo de Produtos
				If lColeta
					cQuery += " AND DUM_FILIAL     = '" + xFilial("DUM") + "'"
					cQuery += " AND DUM_FILORI     = DT5_FILORI "
					cQuery += " AND DUM_NUMSOL     = DT5_NUMSOL"
					cQuery += " AND DUM.D_E_L_E_T_ = ' ' "
					cQuery += " AND B1_FILIAL  = '" + xFilial("SB1") + "'"
					cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
					cQuery += " AND B1_COD     = DUM_CODPRO "
					cQuery += " AND SB1.D_E_L_E_T_    = ' '"
				Else
					cQuery += " AND DTC_FILIAL     = '"+xFilial("DTC")+"'"
					cQuery += " AND DTC_FILDOC    = DT6.DT6_FILDOC"
					cQuery += " AND DTC_DOC       = DT6.DT6_DOC"
					cQuery += " AND DTC_SERIE     = DT6.DT6_SERIE"
					cQuery += " AND DTC_QTDVOL    > 0"
					cQuery += " AND DTC.D_E_L_E_T_    = ' '"
					cQuery += " AND B1_FILIAL   = '"+xFilial("SB1")+"'"
					cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
					cQuery += " AND B1_COD  = DTC_CODPRO"
					cQuery += " AND SB1.D_E_L_E_T_    = ' '"
				EndIf
			EndIf
			cQuery += " AND DA6_FILIAL = '" + xFilial("DA6") + "'"
			cQuery += " AND DA6_ALIANC <> '  ' "
			cQuery += " AND DA6.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA5_FILIAL = '" + xFilial("DA5") + "'"
			cQuery += " AND DA5_COD    = DA6_PERCUR "
			cQuery += " AND DA5.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA8_FILIAL = '" + xFilial("DA8") + "'"
			If !Empty(cRotGen)//Se tiver rota generica cadastrada precisa filtrar para mostrar apenas no botao de rota generica
				cQuery += " AND DA8_COD <> '" + cRotGen + "'"
			EndIf
			If !Empty(cRota)
				cQuery += " AND DA8_COD = '" + cRota + "'"
			EndIf
			cQuery += " AND DA8_SERTMS = '" + cSerTms + "'"
			cQuery += " AND DA8_TIPTRA = '" + cTipTra + "'"
			If lCdrOri
				cQuery += " AND DA8_CDRORI = '" + cCdrOri + "'"
			EndIf
			cQuery += " AND DA8_ATIVO      = '1' "
			cQuery += " AND DA8.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA9_FILIAL     = '" + xFilial("DA9") + "'"
			cQuery += " AND DA9_ROTEIR     = DA8_COD "
			cQuery += " AND DA9_PERCUR     = DA5_COD "
			cQuery += " AND DA9_ROTA       = DA6_PERCUR "
			cQuery += " AND DA9.D_E_L_E_T_ = ' ' "
			If Empty(cRota)
				cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE, DA8_COD, DA5_COD, DA6_ROTA ) QUERY "
				cQuery += " GROUP BY DA8_COD, DA5_COD, DA6_ROTA"
			Else
				cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE"
			EndIf
		EndIf

		//-- Rota generica de entrega
		If	!lVgeExpr .And. nRotGen == 1 .And. !Empty(cRotGen) .And. ( Empty(cRota) .Or. ( !Empty(cRota) .And. cRotGen == cRota ))
			cQuery += " UNION ALL"
			If lOrderBy
				If Empty(cRota)
					cQuery += " SELECT "
					cQuery += " DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(TIPROT) TIPROT, "
					cQuery += " DA5_COD, MIN(DA5_DESC) DA5_DESC, DA6_ROTA, MIN(DA6_REF) DA6_REF , "
					cQuery += " MIN(DUD_STATUS) DUD_STATUS, SUM(DT6_QTDVOL) DT6_QTDVOL, SUM(DT6_PESO)   DT6_PESO  , SUM(DT6_VOLORI) DT6_VOLORI, "
					cQuery += " SUM(DT6_PESOM3) DT6_PESOM3, SUM(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS," + cQueryTp + " 'O' CVISUAL "
					cQuery += "  FROM ( "
					cQuery += " SELECT "
					cQuery += " DA8_COD, MIN(DA8_DESC) DA8_DESC, MIN(DA8_TIPROT) TIPROT, DA5_COD, "
					cQuery += " MIN(DA5_DESC) DA5_DESC, DA6_ROTA, MIN(DA6_REF) DA6_REF, "
					cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , SUM(DT6_VOLORI)  DT6_VOLORI   , "
					cQuery += " MIN(DT6_PESOM3) DT6_PESOM3, MIN(DT6_VALMER) DT6_VALMER, MIN(DUD_SERTMS) DUD_SERTMS, DUD_FILDOC, DUD_DOC, DUD_SERIE, "
					cQuery += cQueryTp + " 'O' CVISUAL"
				Else
					If lColeta
						cQuery += " SELECT "
						cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
						cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
						cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI) DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
						cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
						cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT5_SEQEND) DT5_SEQEND, MIN(DT5_DATSOL) DT5_DATSOL, "
						cQuery += " MIN(DT5_HORSOL) DT5_HORSOL, MIN(DT5_DATPRV) DT5_DATPRV, MIN(DT5_HORPRV) DT5_HORPRV, "
						cQuery += " MIN(DT5_CODSOL) DT5_CODSOL, "
						cQuery += " MIN(DT5_DDD)    DT5_DDD   , MIN(DT5_TEL)    DT5_TEL   , MIN(DT6_VOLORI) DT6_VOLORI, "
						If nOpcx == 2
							cQuery += " MIN(DUD_ZONA) DA7_PERCUR, "
						Else
							cQuery += " MIN(DA6_PERCUR) DA7_PERCUR, "
						EndIf

						cQuery += cQueryTp+" '' DA7_SEQUEN, MIN(DA6_ROTA)   DA7_ROTA   "
						If !lVgeMod2 .And. lTmsCFec
							//-- Retorna os campos referente ao Agendamento.
							cQuery += ", MIN(DF1_ITEAGE) DF1_ITEAGE "
							cQuery += ", MIN(DF1_NUMAGE) DF1_NUMAGE "
							cQuery += ", MIN(DT5_CLIDES) DT5_CLIDES "
							cQuery += ", MIN(DT5_LOJDES) DT5_LOJDES "
							cQuery += ", MIN(DT5_DATENT) DT5_DATENT "
							cQuery += ", MIN(DT5_HORENT) DT5_HORENT "
							cQuery += ", MIN(DUD_SEQENT) DUD_SEQENT "
						EndIf
					Else
						cQuery += " SELECT "
						cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, MIN(DUD_SERTMS) DUD_SERTMS, "
						cQuery += " MIN(DUD_STATUS) DUD_STATUS, MIN(DUD_VIAGEM) DUD_VIAGEM, MIN(DUD_SEQUEN) DUD_SEQUEN, "
						cQuery += " MIN(DT6_BLQDOC) DT6_BLQDOC, MIN(DT6_DATEMI) DT6_DATEMI, MIN(DT6_PRZENT) DT6_PRZENT, "
						cQuery += " MIN(DT6_QTDVOL) DT6_QTDVOL, MIN(DT6_PESO)   DT6_PESO  , MIN(DT6_PESOM3) DT6_PESOM3, "
						cQuery += " MIN(DT6_VALMER) DT6_VALMER, MIN(DT6_CLIREM) DT6_CLIREM, MIN(DT6_LOJREM) DT6_LOJREM, "
						cQuery += " MIN(DT6_CLIDES) DT6_CLIDES, MIN(DT6_LOJDES) DT6_LOJDES, "
						If nOpcx == 2
							cQuery += " MIN(DUD_ZONA) DA7_PERCUR, "
						Else
							cQuery += " MIN(DA6_PERCUR) DA7_PERCUR, "
						EndIf
						cQuery += cQueryTp //-- Usado em query BD POSTGRES
						cQuery += " ''              DA7_SEQUEN, MIN(DA6_ROTA)  DA7_ROTA   , MIN(DT6_VOLORI) DT6_VOLORI  "
					EndIf
				EndIf
			Else
				cQuery += " SELECT "
				cQuery += " DUD_FILDOC, DUD_DOC, DUD_SERIE, DUD.R_E_C_N_O_ DUDRECNO "
			EndIf
			cQuery += " FROM "
			If lColeta .And. !lVgeMod2 .And. lTmsCFec .And. !Empty(cRota)
				//-- Verifica se existe Agendamento associado a Solicitacao de Coleta.
				cQuery +=   RetSqlName('DUD') + " DUD "//Movimento de Viagem
				cQuery += "LEFT JOIN " + RetSqlName('DF1') + " DF1 ON"
				cQuery += " DF1_FILIAL = '" + xFilial("DF1") + "'"
				cQuery += " AND DF1_FILDOC = DUD_FILDOC"
				cQuery += " AND DF1_DOC = DUD_DOC"
				cQuery += " AND DF1_SERIE = DUD_SERIE"
				cQuery += " AND DF1.D_E_L_E_T_ = ' ', "
			Else
				cQuery +=   RetSqlName('DUD') + " DUD, "//Movimento de Viagem
			EndIf
			cQuery += RetSqlName('DT6') + " DT6, "
			cQuery += RetSqlName('DA8') + " DA8, "
			cQuery += RetSqlName('DA9') + " DA9, "
			cQuery += RetSqlName('DA5') + " DA5, "
			cQuery += RetSqlName('DA6') + " DA6 "
			If lColeta
				cQuery +=   ", " + RetSqlName('DT5') + " DT5 "//Solicitacao de coleta
			EndIf
			If !Empty(cGrpProd) //-- Filtra por Grupo de Produtos
				If lColeta
					cQuery += ", " + RetSqlName('SB1') + " SB1  "//Produtos
					cQuery += ", " + RetSqlName('DUM') + " DUM "//Itens da Solicitacao de Coleta
				Else
					cQuery +=  ", " + RetSqlName('DTC') + " DTC "//Notas Fiscais
					cQuery +=  ", " + RetSqlName('SB1') + " SB1 "//Produtos
				EndIf
			EndIf
			cQuery += " WHERE DUD_FILIAL   = '" + xFilial("DUD") + "'"
			If !lTMSDCol
				cQuery += " AND DUD_FILORI     = '" + cFilAnt + "'"
			EndIf
			cQuery += " AND DUD_SERTMS     = '" + cSerTms + "'"
			cQuery += " AND DUD_TIPTRA     = '" + cTipTra + "'"
			cQuery += " AND DUD_STATUS     = '" + cStatus + "'"
			cQuery += " AND DUD_VIAGEM     = '" + cVgeAux + "'"
			cQuery += " AND DUD.D_E_L_E_T_ = ' ' "
			If !Empty(cFiltroDUD)
				cQuery += cFiltroDUD
			EndIf
			cQuery += " AND DT6_FILIAL     = '" + xFilial("DT6") + "'"
			cQuery += " AND DT6_FILDOC     = DUD_FILDOC "
			cQuery += " AND DT6_DOC        = DUD_DOC "
			cQuery += " AND DT6_SERIE      = DUD_SERIE "
			cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
			If lColeta
				If Empty(cFilDT5)
					cQuery += "   AND DT5_FILIAL = '" + xFilial("DT5") + "'"
				Else
					cQuery += "   AND DT5_FILIAL = DUD_FILDOC "
				EndIf
				cQuery += "   AND DT5_FILDOC     = DUD_FILDOC "
				cQuery += "   AND DT5_DOC        = DUD_DOC "
				cQuery += "   AND DT5_SERIE      = DUD_SERIE "
				cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
			EndIf
			If !Empty(cGrpProd) //-- Filtra Grupo de Produtos
				If lColeta
					cQuery += " AND DUM_FILIAL     = '" + xFilial("DUM") + "'"
					cQuery += " AND DUM_FILORI     = DT5_FILORI "
					cQuery += " AND DUM_NUMSOL     = DT5_NUMSOL"
					cQuery += " AND DUM.D_E_L_E_T_ = ' ' "
					cQuery += " AND B1_FILIAL  = '" + xFilial("SB1") + "'"
					cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
					cQuery += " AND B1_COD     = DUM_CODPRO "
					cQuery += " AND SB1.D_E_L_E_T_    = ' '"
				Else
					cQuery += " AND DTC_FILIAL     = '"+xFilial("DTC")+"'"
					cQuery += " AND DTC_FILDOC    = DT6.DT6_FILDOC"
					cQuery += " AND DTC_DOC       = DT6.DT6_DOC"
					cQuery += " AND DTC_SERIE     = DT6.DT6_SERIE"
					cQuery += " AND DTC_QTDVOL    > 0"
					cQuery += " AND DTC.D_E_L_E_T_    = ' '"
					cQuery += " AND B1_FILIAL   = '"+xFilial("SB1")+"'"
					cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
					cQuery += " AND B1_COD  = DTC_CODPRO"
					cQuery += " AND SB1.D_E_L_E_T_    = ' '"
				EndIf
			EndIf
			cQuery += " AND DA8_FILIAL     = '" + xFilial("DA8") + "'"
			cQuery += " AND DA8_SERTMS     = '" + cSerTms + "'"
			cQuery += " AND DA8_TIPTRA     = '" + cTipTra + "'"
			cQuery += " AND DA8_COD        = '" + cRotGen + "'"
			If lCdrOri
				cQuery += " AND DA8_CDRORI     = '" + cCdrOri + "'"
			EndIf
			cQuery += " AND DA8_ATIVO      = '1' "
			cQuery += " AND DA8.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA9_FILIAL     = '" + xFilial("DA9") + "'"
			cQuery += " AND DA9_ROTEIR     = DA8_COD "
			cQuery += " AND DA9.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA5_FILIAL     = '" + xFilial("DA5") + "'"
			cQuery += " AND DA5_COD        = DA9_PERCUR "
			cQuery += " AND DA5.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA6_FILIAL     = '" + xFilial("DA6") + "'"
			cQuery += " AND DA6_PERCUR     = DA9_PERCUR "
			cQuery += " AND DA6_ROTA       = DA9_ROTA "
			If lAlianca
				cQuery += " AND DA6_ALIANC = ' ' "
			EndIf
			cQuery += " AND DA6.D_E_L_E_T_ = ' ' "
			cQuery += " AND NOT EXISTS ( "
			cQuery += " SELECT 1 "
			cQuery += " FROM "
			cQuery += RetSqlName('DUD') + " DUD, "
			cQuery += RetSqlName('DT6') + " DT61, "
			cQuery += RetSqlName('DA8') + " DA8, "
			cQuery += RetSqlName('DA9') + " DA9, "
			cQuery += RetSqlName('DA6') + " DA6, "
			cQuery += RetSqlName('DA7') + " DA7 "
			If lColeta
				cQuery +=   ", " + RetSqlName('DT5') + " DT5 "//Solicitacao de coleta
			EndIf
			If !Empty(cGrpProd) //-- Filtra por Grupo de Produtos
				If lColeta
					cQuery += ", " + RetSqlName('SB1') + " SB1  "//Produtos
					cQuery += ", " + RetSqlName('DUM') + " DUM "//Itens da Solicitacao de Coleta
				Else
					cQuery +=  ", " + RetSqlName('DTC') + " DTC "//Notas Fiscais
					cQuery +=  ", " + RetSqlName('SB1') + " SB1 "//Produtos
				EndIf
			EndIf
			cQuery += " WHERE "
			cQuery += " DUD_FILIAL         = '" + xFilial("DUD") + "'"
			cQuery += " AND DUD_FILDOC     = DT6.DT6_FILDOC "
			cQuery += " AND DUD_DOC        = DT6.DT6_DOC    "
			cQuery += " AND DUD_SERIE      = DT6.DT6_SERIE  "
			If !lTMSDCol
				cQuery += " AND DUD_FILORI     = '" + cFilAnt + "'"
			EndIf
			cQuery += " AND DUD_SERTMS     = '" + cSerTms + "'"
			cQuery += " AND DUD_TIPTRA     = '" + cTipTra + "'"
			cQuery += " AND DUD_STATUS     = '" + cStatus + "'"
			cQuery += " AND DUD_VIAGEM     = '" + cVgeAux + "'"
			cQuery += " AND DUD_CEPENT BETWEEN DA7_CEPDE AND DA7_CEPATE "
			cQuery += " AND DUD.D_E_L_E_T_  = ' ' "
			cQuery += " AND DT61.DT6_FILIAL = '" + xFilial("DT6") + "'"
			cQuery += " AND DT61.DT6_FILDOC = DUD_FILDOC "
			cQuery += " AND DT61.DT6_DOC    = DUD_DOC "
			cQuery += " AND DT61.DT6_SERIE  = DUD_SERIE "
			cQuery += " AND DT61.D_E_L_E_T_ = ' ' "
			If lColeta
				If Empty(cFilDT5)
					cQuery += "   AND DT5_FILIAL = '" + xFilial("DT5") + "'"
				Else
					cQuery += "   AND DT5_FILIAL = DUD_FILDOC "
				EndIf
				cQuery += "   AND DT5_FILDOC     = DUD_FILDOC "
				cQuery += "   AND DT5_DOC        = DUD_DOC "
				cQuery += "   AND DT5_SERIE      = DUD_SERIE "
				cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
			EndIf
			If !Empty(cGrpProd) //-- Filtra Grupo de Produtos
				If lColeta
					cQuery += " AND DUM_FILIAL     = '" + xFilial("DUM") + "'"
					cQuery += " AND DUM_FILORI     = DT5_FILORI "
					cQuery += " AND DUM_NUMSOL     = DT5_NUMSOL"
					cQuery += " AND DUM.D_E_L_E_T_ = ' ' "
					cQuery += " AND B1_FILIAL  = '" + xFilial("SB1") + "'"
					cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
					cQuery += " AND B1_COD     = DUM_CODPRO "
					cQuery += " AND SB1.D_E_L_E_T_    = ' '"
				Else
					cQuery += " AND DTC_FILIAL     = '"+xFilial("DTC")+"'"
					cQuery += " AND DTC_FILDOC    = DT61.DT6_FILDOC"
					cQuery += " AND DTC_DOC       = DT61.DT6_DOC"
					cQuery += " AND DTC_SERIE     = DT61.DT6_SERIE"
					cQuery += " AND DTC_QTDVOL    > 0"
					cQuery += " AND DTC.D_E_L_E_T_    = ' '"
					cQuery += " AND B1_FILIAL   = '"+xFilial("SB1")+"'"
					cQuery += " AND B1_GRUPO IN ("+cGrpProd+")"
					cQuery += " AND B1_COD  = DTC_CODPRO"
					cQuery += " AND SB1.D_E_L_E_T_    = ' '"
				EndIf
			EndIf
			cQuery += " AND DA8_FILIAL     = '" + xFilial("DA8") + "'"
			cQuery += " AND DA8_SERTMS     = '" + cSerTms + "'"
			cQuery += " AND DA8_TIPTRA     = '" + cTipTra + "'"
			cQuery += " AND DA8_COD       <> '" + cRotGen + "'"
			If lCdrOri
				cQuery += " AND DA8_CDRORI     = '" + cCdrOri + "'"
			EndIf
			cQuery += " AND DA8_ATIVO      = '1' "
			cQuery += " AND DA8.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA9_FILIAL     = '" + xFilial("DA9") + "'"
			cQuery += " AND DA9_ROTEIR     = DA8_COD "
			cQuery += " AND DA9.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA6_FILIAL     = '" + xFilial("DA6") + "'"
			cQuery += " AND DA6_PERCUR     = DA9_PERCUR "
			cQuery += " AND DA6_ROTA       = DA9_ROTA "
			If lAlianca
				cQuery += " AND DA6_ALIANC = ' ' "
			EndIf
			cQuery += " AND DA6.D_E_L_E_T_ = ' ' "
			cQuery += " AND DA7_FILIAL     = '" + xFilial("DA7") + "'"
			cQuery += " AND DA7_PERCUR     = DA9_PERCUR "
			cQuery += " AND DA7_ROTA       = DA9_ROTA "
			cQuery += " AND DA7.D_E_L_E_T_ = ' ' )"
			If Empty(cRota)
				cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE, DA8_COD, DA5_COD, DA6_ROTA ) QUERY "
				cQuery += " GROUP BY DA8_COD, DA5_COD, DA6_ROTA "
			Else
				cQuery += " GROUP BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE"
			EndIf
		EndIf
	EndIf
	If !Empty(cRota) .And. lOrderBy
		cQuery += " ORDER BY "+Iif(lOrderBy,""," DUD.R_E_C_N_O_, ")+"DUD_FILDOC, DUD_DOC, DUD_SERIE "
	EndIf
	cQuery := ChangeQuery(cQuery)
EndIf


Return cQuery

/*{Protheus.doc} TMSF60Var
Carrega Variaveis para consulta pelo Carregamento
@author Katia
@since 09/10/2020
@param oModel,cFilOri,cViagem,cRotaVge,cStatusVge,nTipVia,cVgeAux
@version 12.1.31
*/
Static Function TMSF60Var(oModel,cFilOri,cViagem,cRotaVge,cStatusVge,nTipVia,cVgeAux)
Local oMdFldDM6 := oModel:GetModel("MdFieldDM6")
Local aAreaDTQ  := DTQ->(GetArea())

If !Empty(oMdFldDM6:GetValue("DM6_FILORI")) .And. !Empty(oMdFldDM6:GetValue("DM6_VIAGEM"))
	DTQ->(DbSetOrder(2))
	If DTQ->(DbSeek(xFilial("DTQ") + oMdFldDM6:GetValue("DM6_FILORI") + oMdFldDM6:GetValue("DM6_VIAGEM")))
		cFilOri   := DTQ->DTQ_FILORI
		cViagem   := DTQ->DTQ_VIAGEM
		cRotaVge  := DTQ->DTQ_ROTA
		cStatusVge:= DTQ->DTQ_STATUS
		nTipVia   := Val(DTQ->DTQ_TIPVIA)
		cVgeAux   := DTQ->DTQ_VIAGEM
	EndIf
EndIf

RestArea(aAreaDTQ)
FwFreeArray(aAreaDTQ)
Return Nil
