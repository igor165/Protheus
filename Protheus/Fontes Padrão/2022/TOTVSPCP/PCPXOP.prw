#INCLUDE "PCPXOP.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"

//Estáticas de MV, prefixo: mvx sendo x caracter correspondente ao conteúdo
Static mvlPCPATOR  := NIL  //Indica que as operações serão geradas invividualmente na Ordem Produção.
Static mvcAPS      := NIL  //Define integracao com pacote APS externo para integracao do Carga Maquina
Static mvlPCPOS    := NIL  //Indica se utiliza/gera Ordem de Substituição

/*/{Protheus.doc} GeraSHY
Se for inclusao de ordem, alimenta a tabela de operacoes X ordens.
Se for alteracao e o roteiro foi alterado, exclui operacoes antigas e gera as novas.

@author lucas.franca
@since 13/07/2018
@version 1.0

@param 01 - cOP			- Número da ordem de produção.
@param 02 - cProduto	- Código do produto da ordem de produção.
@param 03 - cRoteiro	- Roteiro da ordem de produção.
@param 04 - nQuant		- Quantidade da ordem de produção.
@param 05 - lGeraSHY	- Identifica se é exclusão da ordem.
@param 06 - oModSG2		- Modelo com os dados da tabela SG2. Se não informado, será carregado com os dados da tabela SG2.
@param 07 - oTempTable	- Objeto da tabela temporária para atualização dos dados (Opcional)

@return oTempTable	- Objeto da tabela temporária com os dados gerados.
/*/
Function GeraSHY(cOP,cProduto,cRoteiro,nQuant,lGeraSHY,oModSG2,oTempTable)
	Local aArea      := GetArea()
	Local aAreaSH1   := {}
	Local aAreaSC2   := {}
	Local aAreaSG2   := {}
	Local cAliasTmp  := ""
	Local nLote      := 0
	Local nTemp      := 0
	Local nMObra     := 0
	Local nAux	     := 0
	Local nI         := 0
	Local lProces    := .F.
	Local lBkpInclui := Nil
	Local oModDet    := Nil

	Default lGeraSHY   := .T.
	Default oModSG2    := Nil
	Default oTempTable := Nil

	PRIVATE cTipoTemp := SuperGetMV("MV_TPHR",.F.,"C") //Usada na A690HoraCt

	mvcAPS		:= Iif(mvcAPS 		== NIL	, SuperGetMV("MV_APS",.F.,"")		, mvcAPS)
	mvlPCPATOR	:= Iif(mvlPCPATOR 	== NIL	, SuperGetMV("MV_PCPATOR",.F.,.F.)	, mvlPCPATOR)

	If mvcAPS == "TOTVS" .Or. ;
	   (ExisteSFC("SC2") .And. !IsInCallStack("AUTO650")) .OR. ;
	   mvlPCPATOR == .T.
		lProces := .T.
	EndIf

	If lProces
		If oTempTable == Nil
			oTempTable := criaTmpSHY()
		EndIf

		cAliasTmp := oTempTable:GetAlias()

		//Limpa os dados da tabela temporária para regerar os dados.
		(cAliasTmp)->(dbSetOrder(1))
		If (cAliasTmp)->(dbSeek(xFilial("SHY")+cOP))
			While (cAliasTmp)->(!Eof()) .And. (cAliasTmp)->(HY_FILIAL+HY_OP) == xFilial("SHY")+cOP
				RecLock(cAliasTmp,.F.)
				(cAliasTmp)->(dbDelete())
				(cAliasTmp)->(MsUnLock())
				(cAliasTmp)->(dbSkip())
			End
		EndIf

		If lGeraSHY
			aAreaSG2 := SG2->(GetArea())
			aAreaSC2 := SC2->(GetArea())
			aAreaSH1 := SH1->(GetArea())

			If oModSG2 == Nil
				//Carrega os dados no modelo.
				SG2->(dbSetOrder(1))
				SG2->(dbSeek(xFilial("SG2")+cProduto+cRoteiro))

				//Inicializa variável private INCLUI, se for necessário. Utilizada no ModelDef do PCPA124.
				lBkpInclui := Iif(Type('INCLUI') == "U",Nil,INCLUI)
				INCLUI := .F.

				oModSG2 := FwLoadModel("PCPA124")
				oModSG2:SetOperation(MODEL_OPERATION_VIEW)
				oModSG2:Activate()

				INCLUI := lBkpInclui
			EndIf

			oModDet := oModSG2:GetModel("PCPA124_SG2")

			If SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) != cOp
				SC2->(dbSetOrder(1))
				SC2->(dbSeek(xFilial("SC2")+cOP))
			EndIf

			SH1->(dbSetOrder(1))

			For nI := 1 To oModDet:Length()
				oModDet:GoLine(nI)
				If oModDet:IsDeleted() 
					Loop
				EndIf
				
				If !Empty(oModDet:GetValue("G2_DTINI"))
					If oModDet:GetValue("G2_DTINI") > SC2->C2_DATPRI
						Loop
					EndIf
				EndIf

				If !Empty(oModDet:GetValue("G2_DTFIM"))
					If oModDet:GetValue("G2_DTFIM") < SC2->C2_DATPRI
						Loop
					EndIf
				EndIf

				RecLock(cAliasTmp,.T.)
				(cAliasTmp)->HY_FILIAL  := xFilial("SHY")
				(cAliasTmp)->HY_OP 	    := cOP
				(cAliasTmp)->HY_ROTEIRO := oModSG2:GetValue("PCPA124_CAB","G2_CODIGO")
				(cAliasTmp)->HY_OPERAC  := oModDet:GetValue("G2_OPERAC")
				(cAliasTmp)->HY_CTRAB   := oModDet:GetValue("G2_CTRAB")
				(cAliasTmp)->HY_RECURSO := oModDet:GetValue("G2_RECURSO")
				(cAliasTmp)->HY_FERRAM  := oModDet:GetValue("G2_FERRAM")
				(cAliasTmp)->HY_QUANT   := nQuant
				(cAliasTmp)->HY_SITUAC  := '1'
				(cAliasTmp)->HY_MAOOBRA := oModDet:GetValue("G2_MAOOBRA")
				(cAliasTmp)->HY_DESCRI  := oModDet:GetValue("G2_DESCRI")

				nLote := If(Empty(oModDet:GetValue("G2_LOTEPAD")),1,oModDet:GetValue("G2_LOTEPAD"))
				nTemp := If(Empty(oModDet:GetValue("G2_TEMPAD")),1,oModDet:GetValue("G2_TEMPAD"))
				nTemp := A690HoraCt(nTemp)
				nAux  := nQuant

				//Se tempo mínimo, arredonda a sobra para completar o tempo do lote
				If oModDet:GetValue("G2_TPOPER") == "4"
					nAux := nAux % nLote
					nAux := Int(nQuant) + If(Empty(nAux),0,nLote - nAux)
				EndIf

				//Proporcionaliza conforme tempo padra / lote padrao
				If !(oModDet:GetValue("G2_TPOPER") $ "23")
					nTemp := nAux * (nTemp / nLote)
					If SH1->(dbSeek(xFilial("SH1")+oModDet:GetValue("G2_RECURSO")))
						nMObra := SH1->H1_MAOOBRA
						If !Empty(nMObra)
							nTemp := nTemp / nMObra
						EndIf
					EndIf
				EndIf

				(cAliasTmp)->HY_TEMPOM := nTemp

				If Empty(oModDet:GetValue("G2_FORMSTP"))
					nTemp := oModDet:GetValue("G2_SETUP")
				Else
					nTemp := Formula(oModDet:GetValue("G2_FORMSTP"))
				EndIf

				(cAliasTmp)->HY_TEMPOS := A690HoraCt(nTemp)
				(cAliasTmp)->(MsUnLock())
			Next nI

			SG2->(RestArea(aAreaSG2))
			SC2->(RestArea(aAreaSC2))
			SH1->(RestArea(aAreaSH1))
		EndIf
	EndIf

	RestArea(aArea)

Return oTempTable

/*/{Protheus.doc} GravaSHY
Efetiva as informações da SHY, com base nos dados gerados pela função GeraSHY.

@author lucas.franca
@since 13/07/2018
@version 1.0
@param 01 - oTempTable	- Objeto da tabela temporária com as informações da SHY
/*/
Function GravaSHY(oTempTable)
	Local lProces   := .F.
	Local cAliasTmp := ""
	Local cFilSHY   := xFilial("SHY")
	Local cQuery    := ""
	Local cAliasHY  := ""
	Default lAutoMacao := .F.

	IF !lAutoMacao
		cAliasTmp := oTempTable:GetAlias()
	ENDIF

	mvcAPS		:= Iif(mvcAPS 		== NIL	, SuperGetMV("MV_APS",.F.,"")		, mvcAPS)
	mvlPCPATOR	:= Iif(mvlPCPATOR 	== NIL	, SuperGetMV("MV_PCPATOR",.F.,.F.)	, mvlPCPATOR)

	If mvcAPS == "TOTVS" .Or. ;
	  (ExisteSFC("SC2") .And. !IsInCallStack("AUTO650")) .OR. ;
	   mvlPCPATOR == .T.
		lProces := .T.
	EndIf

	If lProces
		//Primeiro busca as ordens com registro na SHY para apagar os dados existentes.
		cQuery := " SELECT DISTINCT TMP.HY_OP "
		cQuery +=   " FROM " + oTempTable:GetRealName() + " TMP "
		cQuery +=  " WHERE TMP.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND TMP.HY_FILIAL  = '"+cFilSHY+"' "
		cQuery +=    " AND EXISTS ( SELECT 1 "
		cQuery +=                   " FROM " + RetSqlName("SHY") + " SHY "
		cQuery +=                  " WHERE SHY.HY_FILIAL  = '"+cFilSHY+"' "
		cQuery +=                    " AND SHY.D_E_L_E_T_ = ' ' "
		cQuery +=                    " AND SHY.HY_OP      = TMP.HY_OP ) "
		cQuery := ChangeQuery(cQuery)

		cAliasHY := GetNextAlias()

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasHY,.T.,.T.)

		SHY->(dbSetOrder(1))

		While (cAliasHY)->(!Eof())
			If SHY->(dbSeek(cFilSHY+(cAliasHY)->(HY_OP)))
				While SHY->(!Eof()) .And. SHY->(HY_FILIAL+HY_OP) == cFilSHY + (cAliasHY)->(HY_OP)
					RecLock("SHY",.F.)
					SHY->(dbDelete())
					SHY->(MsUnLock())
					SHY->(dbSkip())
				End
			EndIf
			(cAliasHY)->(dbSkip())
		End
		(cAliasHY)->(dbCloseArea())

		(cAliasTmp)->(dbSetOrder(1))
		If (cAliasTmp)->(dbSeek(cFilSHY))
			While (cAliasTmp)->(!Eof()) .And. (cAliasTmp)->(HY_FILIAL) == cFilSHY

				RecLock("SHY",.T.)
				SHY->HY_FILIAL  := cFilSHY
				SHY->HY_OP 	    := (cAliasTmp)->HY_OP
				SHY->HY_ROTEIRO := (cAliasTmp)->HY_ROTEIRO
				SHY->HY_OPERAC  := (cAliasTmp)->HY_OPERAC
				SHY->HY_CTRAB   := (cAliasTmp)->HY_CTRAB
				SHY->HY_RECURSO := (cAliasTmp)->HY_RECURSO
				SHY->HY_FERRAM  := (cAliasTmp)->HY_FERRAM
				SHY->HY_QUANT   := (cAliasTmp)->HY_QUANT
				SHY->HY_SITUAC  := (cAliasTmp)->HY_SITUAC
				SHY->HY_MAOOBRA := (cAliasTmp)->HY_MAOOBRA
				SHY->HY_DESCRI  := (cAliasTmp)->HY_DESCRI
				SHY->HY_TEMPOM  := (cAliasTmp)->HY_TEMPOM
				SHY->HY_TEMPOS  := (cAliasTmp)->HY_TEMPOS
				SHY->(MsUnLock())

				(cAliasTmp)->(dbSkip())
			End
		EndIf
	EndIf

	IF !lAutoMacao
		oTempTable:Delete()
	ENDIF
	oTempTable := Nil

Return

/*/{Protheus.doc} criaTmpSHY
Cria a tabela temporária conforme a estrutura da tabela SHY
@author lucas.franca
@since 13/07/2018
@version 1.0
@return oTempTable	- Objeto da tabela temporária.
/*/
Static Function criaTmpSHY()
	Local oTempTable := FwTemporaryTable():New()

	oTempTable:SetFields(SHY->(dbStruct()))
	oTempTable:AddIndex("01",{"HY_FILIAL","HY_OP","HY_ROTEIRO","HY_OPERAC","HY_CTRAB"})
	oTempTable:AddIndex("02",{"HY_FILIAL","HY_IDAPS","HY_ROTEIRO","HY_OPERAC","HY_CTRAB"})
	oTempTable:Create()

Return oTempTable

/*/{Protheus.doc} OPCabSFC
Carrega o cabeçalho do modelo de dados de ordem de produção do SIGASFC (SFCA100) de acordo com os parâmetros recebidos.

@author lucas.franca
@since 13/07/2018
@version 1.0

@param 01 - oModSFC	- Modelo de dados do SFC. Passar variável por referência para recuperar o modelo e complementar as informações posteriormente.
@param 02 - oModelG2	- Modelo de dados das operações da ordem. Pode ser passado um modelo com os dados já carregados.
Passar variável por referência para recuperar o modelo e utilizar as informações deste modelo.
@param 03 - cOP		- Ordem de produção que está sendo alterada.
@param 04 - cProduto	- Produto que está sendo alterado.
@param 05 - cRoteiro	- Roteiro que está sendo alterado.

@return lRet	- Indica se o modelo foi carregado corretamente, e seus dados validados.
/*/
Function OPCabSFC(oModSFC,oModelG2,cOp,cProduto,cRoteiro)
	Local lRet    := .T.
	Local lBkpInc := Nil
	Local nX      := 0
	Local aAux    := {}
	Local aCpoCYQ := {}
	Local aArea   := GetArea()
	Local aAreaC2 := SC2->(GetArea())
	Local aAreaB1 := SB1->(GetArea())
	Local aAreaG2 := SG2->(GetArea())

	If Type('INCLUI') == "L"
		lBkpInc := INCLUI
	EndIf

	If SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) != cOp
		SC2->(dbSetOrder(1))
		SC2->(dbSeek(xFilial("SC2")+cOP))
	EndIf

	If Empty(cProduto)
		cProduto := SC2->C2_PRODUTO
	EndIf

	If Empty(cRoteiro) .And.  Empty(cRoteiro:= SC2->C2_ROTEIRO)
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
			If Empty(cRoteiro := SB1->B1_OPERPAD)
				cRoteiro := StrZero(1,TamSX3("G2_CODIGO")[1])
			EndIf
		EndIf
	EndIf

	If oModelG2 == Nil
		SG2->(dbSetOrder(1))
		If SG2->(dbSeek(xFilial("SG2")+cProduto+cRoteiro))
			INCLUI := .F. //Variável utilizada no ModelDef do PCPA124.

			oModelG2 := FwLoadModel("PCPA124")
			oModelG2:SetOperation(MODEL_OPERATION_VIEW)
			oModelG2:Activate()
		EndIf
	EndIf

	If SC2->C2_TPOP == "F" .And. oModelG2 != Nil
		If SB1->B1_COD <> SC2->C2_PRODUTO
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
		EndIf

		If oModSFC == Nil
			oModSFC := FWLoadModel("SFCA100")

			CYQ->(dbSetOrder(1))
			If CYQ->(!dbSeek(xFilial("CYQ")+cOp))
				aAdd(aCpoCYQ,{"CYQ_NRORPO", SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)})
				aAdd(aCpoCYQ,{"CYQ_CDAC"  , SC2->C2_PRODUTO})
				aAdd(aCpoCYQ,{"CYQ_DSAC"  , SB1->B1_DESC})
				aAdd(aCpoCYQ,{"CYQ_CDDP"  , SC2->C2_LOCAL})
				aAdd(aCpoCYQ,{"CYQ_QTOR"  , SC2->C2_QUANT})
				aAdd(aCpoCYQ,{"CYQ_TPORPO", "1"})
				aAdd(aCpoCYQ,{"CYQ_CDUN"  , SC2->C2_UM})
				aAdd(aCpoCYQ,{"CYQ_CDPDOR", SC2->(C2_PEDIDO+C2_ITEMPV)})
				aAdd(aCpoCYQ,{"CYQ_TPST"  , "1"})
				aAdd(aCpoCYQ,{"CYQ_TPSTOR", "2"})

				CZ3->(dbSetOrder(1))
				CZ3->(dbSeek(xFilial("CZ3")+SB1->B1_COD))
				aAdd(aCpoCYQ,{"CYQ_TPRPOR", CZ3->CZ3_TPRPOR})

				aAdd(aCpoCYQ,{"CYQ_CDES"  , xFilial("SC2")})
				aAdd(aCpoCYQ,{"CYQ_CDGE"  , SB1->B1_GRUPO})

				SBM->(dbSetOrder(1))
				SBM->(dbSeek(xFilial("SBM")+SB1->B1_GRUPO))
				aAdd(aCpoCYQ,{"CYQ_DSGE"  , SBM->BM_DESC})

				aAdd(aCpoCYQ,{"CYQ_VLPSLQ", SB1->B1_PESO})
				aAdd(aCpoCYQ,{"CYQ_VLPSBR", SB1->B1_PESBRU})
				aAdd(aCpoCYQ,{"CYQ_TPMOD" ,"1"})

				SF5->(dbSeek(xFilial("SF5")+SuperGetMV("MV_TMPAD",.F.,"")))
				aAdd(aCpoCYQ,{"CYQ_TPGGF" ,If(SF5->F5_TRANMOD = "S","2","1")})

				oModSFC:SetOperation(MODEL_OPERATION_INSERT)
			Else
				oModSFC:SetOperation(MODEL_OPERATION_UPDATE)
			EndIf

			//Ativa o modelo de dados
			lRet := oModSFC:Activate()
			If lRet
				aAux := oModSFC:GetModel("CYQMASTER"):GetStruct():GetFields()

				For nX := 1 To Len(aCpoCYQ)
					If aScan(aAux,{|x| AllTrim(x[3]) ==  AllTrim(aCpoCYQ[nX,1])}) > 0
						If !(oModSFC:SetValue("CYQMASTER",aCpoCYQ[nX,1],aCpoCYQ[nX,2]))
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next nX
			EndIf
		EndIf
	Else
		oModSFC := Nil
	EndIf

	INCLUI := lBkpInc

	SC2->(RestArea(aAreaC2))
	SB1->(RestArea(aAreaB1))
	SG2->(RestArea(aAreaG2))
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} OPSFCOper
Carrega o modelo de dados para integracao das operações da ordem com o módulo SIGASFC.

@author lucas.franca
@since 13/07/2018
@version 1.0

@param 01 - oModSFC	- Modelo de dados do SFC. Passar variável por referência para recuperar o modelo e fazer o commit posteriormente.
@param 02 - cOP		- Ordem de produção que está sendo alterada.
@param 03 - oTempHY	- Objeto com os dados atualizados da tabela SHY. Se não for passado, será utilizado os dados existentes da tabela SHY.
@param 04 - cProduto	- Produto que está sendo alterado.
@param 05 - cRoteiro	- Roteiro que está sendo alterado.
@param 06 - oModelG2	- Modelo de dados do roteiro, com as informações atualizadas.
Se não for passado, será utilizado os parâmetros cProduto/cRoteiro para buscar o roteiro do produto na tabela SG2.

@return lRet	- Indica se o modelo foi carregado corretamente, e seus dados validados.
/*/
Function OPSFCOper(oModSFC,cOP,oTempHY,cProduto,cRoteiro,oModelG2)
	Local aArea     := GetArea()
	Local aCpoCY9   := {}
	Local aCpoCYD   := {}
	Local aAux      := {}
	Local aBackup   := Array(2)
	Local lRet      := .T.
	Local nX        := 0
	Local nY	    := 0
	Local nItErro   := 0
	Local nLine     := 0
	Local cAliasHY  := ""
	Local oModDet   := Nil

	Default oModSFC  := Nil
	Default oTempHY  := Nil
	Default cProduto := ""
	Default cRoteiro := ""
	Default oModelG2 := Nil

	If Type("Inclui") == "L"
		aBackup[1] := INCLUI
	EndIf

	If Type("Altera") == "L"
		aBackup[2] := ALTERA
	EndIf

	If oTempHY == Nil
		cAliasHY := "SHY"
	Else
		cAliasHY := oTempHY:GetAlias()
	EndIf

	lRet := OPCabSFC(@oModSFC,@oModelG2,cOp,cProduto,cRoteiro)

	If lRet .And. oModSFC != Nil
		oModDet := oModelG2:GetModel("PCPA124_SG2")

		CYI->(dbSetOrder(1))

		(cAliasHY)->(dbSetOrder(1))
		(cAliasHY)->(dbSeek(xFilial("SHY")+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)))
		While !(cAliasHY)->(EOF()) .And. (cAliasHY)->(HY_FILIAL+HY_OP) == xFilial("SHY")+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
			oModDet:SeekLine({{"G2_OPERAC",(cAliasHY)->HY_OPERAC}})

			//Define campos da folder 'Operacoes da Ordem' a serem atualizados no cadastro de OP
			aAdd(aCpoCY9,{})

			aAdd(aTail(aCpoCY9),{"CY9_NRORPO", (cAliasHY)->HY_OP})
			aAdd(aTail(aCpoCY9),{"CY9_CDAT"  , (cAliasHY)->HY_OPERAC})
			aAdd(aTail(aCpoCY9),{"CY9_DSAT"  , (cAliasHY)->HY_DESCRI})
			aAdd(aTail(aCpoCY9),{"CY9_CDAC"  , SC2->C2_PRODUTO})
			aAdd(aTail(aCpoCY9),{"CY9_TPAT"  , "1"})
			aAdd(aTail(aCpoCY9),{"CY9_CDCETR", (cAliasHY)->HY_CTRAB})
			aAdd(aTail(aCpoCY9),{"CY9_TPUNTE", "1"})
			aAdd(aTail(aCpoCY9),{"CY9_QTTEMQ", (cAliasHY)->HY_TEMPOM})
			aAdd(aTail(aCpoCY9),{"CY9_QTTESU", (cAliasHY)->HY_TEMPOS})
			aAdd(aTail(aCpoCY9),{"CY9_CDRT"  , (cAliasHY)->HY_ROTEIRO})
			aAdd(aTail(aCpoCY9),{"CY9_CDFE"  , (cAliasHY)->HY_FERRAM})
			aAdd(aTail(aCpoCY9),{"CY9_QTAT"  , (cAliasHY)->HY_QUANT})

			If oModDet:GetValue("G2_TPOPER") == "3"
				aAdd(aTail(aCpoCY9),{"CY9_TPTE", "1"})
			ElseIf oModDet:GetValue("G2_TPOPER") == "4"
				aAdd(aTail(aCpoCY9),{"CY9_TPTE", "3"})
			Else
				aAdd(aTail(aCpoCY9),{"CY9_TPTE", oModDet:GetValue("G2_TPOPER")})
			EndIf

			aAdd(aTail(aCpoCY9),{"CY9_QTLOPA", oModDet:GetValue("G2_LOTEPAD")})

			CYI->(dbSeek(xFilial("CYI")+(cAliasHY)->HY_CTRAB))
			aAdd(aTail(aCpoCY9),{"CY9_LGCERP", CYI->CYI_LGCERP})

			//Define campos da folder 'Rede Pert' a serem atualizados no cadastro de OP
			(cAliasHY)->(dbSkip())

			If !(cAliasHY)->(EOF()) .And. (cAliasHY)->(HY_FILIAL+HY_OP) == xFilial("SHY")+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
				aAdd(aCpoCYD,{})

				aAdd(aTail(aCpoCYD),{"CYD_NRORPO", (cAliasHY)->HY_OP})
				aAdd(aTail(aCpoCYD),{"CYD_CDAC"  , SC2->C2_PRODUTO})
				aAdd(aTail(aCpoCYD),{"CYD_CDACPV", SC2->C2_PRODUTO})
				aAdd(aTail(aCpoCYD),{"CYD_CDRT"  , (cAliasHY)->HY_ROTEIRO})
				aAdd(aTail(aCpoCYD),{"CYD_CDRTPV", (cAliasHY)->HY_ROTEIRO})
				aAdd(aTail(aCpoCYD),{"CYD_CDAT"  , (cAliasHY)->HY_OPERAC})
				aAdd(aTail(aCpoCYD),{"CYD_CDATPV", oModDet:GetValue("G2_OPERAC")})

				nLine := oModDet:GetLine()

				oModDet:SeekLine({{"G2_OPERAC",(cAliasHY)->HY_OPERAC}})

				If oModDet:GetValue("G2_TPSOBRE") == "2"
					aAdd(aTail(aCpoCYD),{"CYD_VLPNOV",oModDet:GetValue("G2_TEMPSOB")})
				ElseIf oModDet:GetValue("G2_TPSOBRE") == "1"
					aAdd(aTail(aCpoCYD),{"CYD_VLPNOV",100})
				ElseIf oModDet:GetValue("G2_TPSOBRE") == "3"
					nVlpnov := Round((oModDet:GetValue("G2_TEMPSOB") * 100) / oModDet:GetValue("G2_TEMPAD"),2)
					If nVlpnov > 100
						nVlpnov := 100
					EndIf
					aAdd(aTail(aCpoCYD),{"CYD_VLPNOV",nVlpnov})
				EndIf

				oModDet:GoLine(nLine)

				aAdd(aTail(aCpoCYD),{"CYD_QTTETS",oModDet:GetValue("G2_TEMPEND")})
			EndIf
		End

		//Quando alteracao deleta linhas das grids 'Operacoes' e 'Rede' para nova inclusao
		For nX := 1 To oModSFC:GetModel("CY9DETAIL"):Length()
			oModSFC:GetModel("CY9DETAIL"):GoLine(nX)
			oModSFC:GetModel("CY9DETAIL"):SetValue("CY9_IDAT","0")
			oModSFC:GetModel("CY9DETAIL"):DeleteLine()
		Next nX

		For nX := 1 To oModSFC:GetModel("CYDDETAIL"):Length()
			oModSFC:GetModel("CYDDETAIL"):GoLine(nX)
			oModSFC:GetModel("CYDDETAIL"):DeleteLine()
		Next nX

		aAux := oModSFC:GetModel("CY9DETAIL"):GetStruct():GetFields()

		For nY := 1 To Len(aCpoCY9)
			oModSFC:GetModel("CY9DETAIL"):AddLine()

			For nX := 1 To Len(aCpoCY9[nY])
				If aScan(aAux,{|x| AllTrim(x[3]) ==  AllTrim(aCpoCY9[nY,nX,1])}) > 0
					If !(oModSFC:SetValue("CY9DETAIL",aCpoCY9[nY,nX,1],aCpoCY9[nY,nX,2]))
						lRet := .F.
						nItErro := Len(oModSFC:GetModel("CY9DETAIL"):aCols)
						Exit
					EndIf
				EndIf
			Next nX

			If !lRet
				Exit
			EndIf
		Next nY

		If Empty(nItErro)
			aAux := oModSFC:GetModel("CYDDETAIL"):GetStruct():GetFields()

			For nY := 1 To Len(aCpoCYD)
				oModSFC:GetModel("CYDDETAIL"):AddLine()

				For nX := 1 To Len(aCpoCYD[nY])
					If aScan(aAux,{|x| AllTrim(x[3]) ==  AllTrim(aCpoCYD[nY,nX,1])}) > 0
						If !(oModSFC:SetValue("CYDDETAIL",aCpoCYD[nY,nX,1],aCpoCYD[nY,nX,2]))
							lRet := .F.
							nItErro := Len(oModSFC:GetModel("CYDDETAIL"):aCols)
							Exit
						EndIf
					EndIf
				Next nX

				If !lRet
					Exit
				EndIf
			Next nY
		EndIf

		If lRet
			lRet := oModSFC:VldData()
		EndIf
		If !lRet
			A010SFCErr(oModSFC,,nItErro,,SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD))
		EndIf
	EndIf

	INCLUI := aBackup[1]
	ALTERA := aBackup[2]

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} OPSFCNece
Carrega o modelo de dados para integracao das necessidades da ordem com o módulo SIGASFC.

@author lucas.franca
@since 13/07/2018
@version 1.0

@param 01 - oModSFC	- Modelo de dados do SFC. Passar variável por referência para recuperar o modelo e fazer o commit posteriormente.
@param 02 - cOP		- Ordem de produção que está sendo alterada.
@param 03 - oTempHY	- Objeto com os dados atualizados da tabela SHY. Se não for passado, será utilizado os dados existentes da tabela SHY.
@param 04 - cProduto	- Produto que está sendo alterado.
@param 05 - cRoteiro	- Roteiro que está sendo alterado.
@param 06 - oModelG2	- Modelo de dados do roteiro, com as informações atualizadas.
Se não for passado, será utilizado os parâmetros cProduto/cRoteiro para buscar o roteiro do produto na tabela SG2.

@return lRet	- Indica se o modelo foi carregado corretamente, e seus dados validados.
/*/
Function OPSFCNece(oModSFC,cOP,oTempHY,cProduto,cRoteiro,oModelG2)
	Local aArea     := GetArea()
	Local aAreaB1   := {}
	Local aAreaD4   := {}
	Local aAreaGF   := {}
	Local aAreaG2   := {}
	Local aCpoCYP   := {}
	Local aAux      := {}
	Local aBackup   := Array(2)
	Local lRet      := .T.
	Local nX        := 0
	Local nY	    := 0
	Local nItErro   := 0
	Local nRecG2    := 0
	Local cAliasHY  := ""
	Local oModDet   := Nil

	Default oModSFC  := Nil
	Default oTempHY  := Nil
	Default cProduto := ""
	Default cRoteiro := ""
	Default oModelG2 := Nil

	If Type("Inclui") == "L"
		aBackup[1] := INCLUI
	EndIf

	If Type("Altera") == "L"
		aBackup[2] := ALTERA
	EndIf

	If oTempHY == Nil
		cAliasHY := "SHY"
	Else
		cAliasHY := oTempHY:GetAlias()
	EndIf

	lRet := OPCabSFC(@oModSFC,@oModelG2,cOp,cProduto,cRoteiro)

	If lRet .And. oModSFC != Nil
		oModDet := oModelG2:GetModel("PCPA124_SG2")

		(cAliasHY)->(dbSetOrder(1))
		(cAliasHY)->(dbSeek(xFilial("SHY")+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)))
		If !(cAliasHY)->(dbSeek(xFilial("SHY")+(cAliasHY)->(HY_OP+HY_ROTEIRO)+Replicate("z",TamSX3("G2_OPERAC")[1]),.T.))
			(cAliasHY)->(dbSkip(-1))
		EndIf

		aAreaB1 := SB1->(GetArea())
		aAreaD4 := SD4->(GetArea())
		aAreaGF := SGF->(GetArea())
		aAreaG2 := SG2->(GetArea())

		SGF->(dbSetOrder(2))
		SG2->(dbSetOrder(1))
		SD4->(dbSetOrder(2))
		SD4->(dbSeek(xFilial("SD4")+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)))
		While !SD4->(EOF()) .And. SD4->(D4_FILIAL+D4_OP) == xFilial("SD4")+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
			aAdd(aCpoCYP,{})

			aAdd(aTail(aCpoCYP),{"CYP_NRORPO",SD4->D4_OP})
			aAdd(aTail(aCpoCYP),{"CYP_CDMT",SD4->D4_COD})
			aAdd(aTail(aCpoCYP),{"CYP_NRSQMT",SD4->D4_TRT})
			aAdd(aTail(aCpoCYP),{"CYP_CDACPI",SC2->C2_PRODUTO})
			aAdd(aTail(aCpoCYP),{"CYP_CDRT",(cAliasHY)->HY_ROTEIRO})

			If SGF->(dbSeek(xFilial("SGF")+SC2->C2_PRODUTO+(cAliasHY)->HY_ROTEIRO+SD4->D4_COD))
				//O código da operação pode ter sido alterado no modelo. Faz a busca para pegar o código da operação corretamente.
				SG2->(dbSeek(xFilial("SG2")+SGF->(GF_PRODUTO+GF_ROTEIRO+GF_OPERAC)))
				nRecG2 := SG2->(Recno())
				cOperac := SGF->GF_OPERAC
				For nX := 1 To oModDet:Length()
					oModDet:GoLine(nX)
					If oModDet:GetDataID() == nRecG2
						cOperac := oModDet:GetValue("G2_OPERAC")
						Exit
					EndIf
				Next nX
				aAdd(aTail(aCpoCYP),{"CYP_CDAT",cOperac})
			Else
				aAdd(aTail(aCpoCYP),{"CYP_CDAT",(cAliasHY)->HY_OPERAC})
			EndIf

			aAdd(aTail(aCpoCYP),{"CYP_CDDP",SD4->D4_LOCAL})
			aAdd(aTail(aCpoCYP),{"CYP_CDLO",SD4->D4_LOTECTL})
			aAdd(aTail(aCpoCYP),{"CYP_QTMT",SD4->D4_QUANT})

			SB1->(MsSeek(xFilial("SB1")+SD4->D4_COD))
			aAdd(aTail(aCpoCYP),{"CYP_CDUN",SB1->B1_UM})

			aAdd(aTail(aCpoCYP),{"CYP_DTMT",SD4->D4_DATA})
			aAdd(aTail(aCpoCYP),{"CYP_TPST","1"})

			SD4->(dbSkip())
		End

		SB1->(RestArea(aAreaB1))
		SD4->(RestArea(aAreaD4))
		SGF->(RestArea(aAreaGF))
		SG2->(RestArea(aAreaG2))

		aAux := oModSFC:GetModel("CYPDETAIL"):GetStruct():GetFields()

		//Deleta os componentes já cadastrados para atualizar com os novos.
		For nX := 1 To oModSFC:GetModel("CYPDETAIL"):GetQtdLine()
			oModSFC:GetModel("CYPDETAIL"):GoLine(nX)
			oModSFC:GetModel("CYPDETAIL"):DeleteLine()
		Next nX

		For nY := 1 To Len(aCpoCYP)
			oModSFC:GetModel("CYPDETAIL"):AddLine()

			For nX := 1 To Len(aCpoCYP[nY])
				If aScan(aAux,{|x| AllTrim(x[3]) ==  AllTrim(aCpoCYP[nY,nX,1])}) > 0
					If !(oModSFC:SetValue("CYPDETAIL",aCpoCYP[nY,nX,1],aCpoCYP[nY,nX,2]))
						lRet := .F.
						nItErro := nX
						Exit
					EndIf
				EndIf
			Next nX

			If !lRet
				Exit
			EndIf
		Next nY

		If lRet
			lRet := oModSFC:VldData()
		EndIf

		If !lRet
			A010SFCErr(oModSFC,,nItErro,,SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD))
		EndIf
	EndIf

	INCLUI := aBackup[1]
	ALTERA := aBackup[2]

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} OPSFCCmmMd
Faz o commit do modelo de dados do SFC. Função deve ser utilizada em conjunto com as funções OPSFCNece e OPSFCOper.
@author lucas.franca
@since 17/07/2018
@version 1.0
@return Nil
@param 01 - oModel	 - Modelo de dados criado pelas funções OPSFCNece ou OPSFCOper
/*/
Function OPSFCCmmMd(oModel)

	oModel:CommitData()
	oModel:DeActivate()
	oModel:Destroy()

Return Nil

/*{Protheus.doc} geraOrdSub
Função para criação da ordem de substituição e seus itens.
@author lucas.franca| brunno.costa
@since 	20/07/2018 	| 12/11/2018
@version 1.0
@return Nil

@param 01 - aSVF - Array com as informacoes do Empenho ANTERIOR - SUBSTITUIDO:
- 01-01: VF_FILIAL	- Filial do empenho anterior;
- 01-02: VF_OP		- OP do empenho anterior;
- 01-03: VF_COMP	- Componente do empenho anterior;
- 01-04: VF_LOCAL	- Local do empenho anterior;
- 01-05: VF_TRT		- TRT do empenho anterior;
- 01-06: VF_SEQ		- Sequencia do empenho anterior;
- 01-07: VF_OPORIG	- OP Origem do empenho anterior;
- 01-08: VF_LOTE	- Lote do empenho anterior;
- 01-09: VF_SUBLOTE	- SubLote do empenho anterior;
- 01-10: VF_ORDEM	- Ordem do empenho anterior;
- 01-11: VF_QTDEORI	- Quantidade do empenho anterior;

@param 02 - aT4I	- Array com quantidade e enderecos anteriores - REFERENTE PRODUTO SUBSTITUIDO;
- 02-nX-01: Filial          - Filial da T4I;
- 02-nX-02: nQuantidade		- Quantidade anterior;
- 02-nX-03: nLocalizacao	- Localizacao anterior;
- 02-nX-04: cNumSerie		- Numero de serie anterior;

@param 03 - aSVJ - Array com as informacoes do empenho NOVO - SUBSTITUTO:
- 03-nX-01: VJ_FILIAL	- Filial do empenho novo;
- 03-nX-02: VJ_ALTERN	- Componente do empenho novo - ALTERNATIVO;
- 03-nX-03: VJ_LOCAL	- Local do empenho novo;
- 03-nX-04: VJ_TRT		- TRT do empenho novo;
- 03-nX-05: VJ_SEQ		- Sequencia do empenho novo;
- 03-nX-06: VJ_OPORIG	- OP Origem do empenho novo;
- 03-nX-07: VJ_LOTE		- Lote do empenho novo;
- 03-nX-08: VJ_SUBLOTE	- SubLote do empenho novo;
- 03-nX-09: VJ_ORDEM	- Ordem do empenho novo;
- 03-nX-10: VJ_QUANT	- Quantidade do empenho novo
- 03-nX-11: VJ_LOCALIZ 	- Localizacao do empenho novo;
- 03-nX-12: VJ_NUMSERI 	- Numero de serie do empenho novo

@param 04 - lNovaOrdS - Indica se deverá ser gerada uma nova numeração de Ordem de Substituição
*/
Function geraOrdSub(aSVF, aT4I, aSVJ, lNovaOrdS, lLockSVF)

	Local cNumVF	:= ""
	Local aArea		:= GetArea()
	Local nX		:= 0

	Default lLockSVF  := .F.
	Default lNovaOrdS := .F.

	mvlPCPOS := IIf(mvlPCPOS == NIL, SuperGetMV("MV_PCPOS",.F.,.F.), mvlPCPOS)
	If !mvlPCPOS
		Return
	EndIf

	//Se cria nova ordem de substituição, não é necessário realizar o lock
	If lNovaOrdS .And. lLockSVF
		lLockSVF := .F.
	EndIf

	If lLockSVF
		If !LockSVF(aSVF[2], aSVF[3])
			//Se não conseguiu realizar o lock, seta variável para false
			lLockSVF := .F.
		EndIf
	EndIf
	
	If !lNovaOrdS
		//Verifica se já existe uma ordem de substituição para esse produto
		SVF->(dbSetOrder(3))
		If SVF->(dbSeek(aSVF[1] + ; //VF_FILIAL
						aSVF[2] + ; //VF_OP
						aSVF[3] + ; //VF_COMP
						aSVF[4] + ; //VF_LOCAL
						aSVF[5] + ; //VF_TRT
						aSVF[6] + ; //VF_SEQ
						aSVF[7] + ; //VF_OPORIG
						aSVF[8] + ; //VF_LOTE
						aSVF[9] + ; //VF_SUBLOTE
						aSVF[10])) //VF_ORDEM

			lNovaOrdS := .F.
			cNumVF    := SVF->VF_NUM
		Else
			lNovaOrdS := .T.
		EndIf
	EndIf

	//SVF -> Grava o produto que foi substituído
	If lNovaOrdS
		cNumVF := GetSxeNum("SVF","VF_NUM")

		RecLock("SVF",.T.)
		SVF->VF_FILIAL	:= aSVF[1]
		SVF->VF_NUM		:= cNumVF
		SVF->VF_OP		:= aSVF[2]
		SVF->VF_COMP	:= aSVF[3]
		SVF->VF_LOCAL	:= aSVF[4]
		SVF->VF_TRT		:= aSVF[5]
		SVF->VF_SEQ		:= aSVF[6]
		SVF->VF_OPORIG	:= aSVF[7]
		SVF->VF_LOTE	:= aSVF[8]
		SVF->VF_SUBLOTE	:= aSVF[9]
		SVF->VF_ORDEM	:= aSVF[10]
		SVF->VF_QTDEORI	:= aSVF[11]
		SVF->VF_PRGR   	:= FunName()
		SVF->VF_DATA   	:= Date()
		SVF->VF_USUARIO	:= RetCodUsr()
		SVF->(MsUnLock())

		//Confirma o número sequencial da SVF.
		ConfirmSX8()
	Else
		//Se já existe um ordem de substituição, apenas incrementa a quantidade
		RecLock("SVF",.F.)
		SVF->VF_QTDEORI	:= SVF->VF_QTDEORI + aSVF[11]
		SVF->(MsUnLock())
	EndIf

	If lLockSVF
		UnLockSVF(aSVF[2], aSVF[3])
	EndIf

	//T4I -> Grava o Endereço e Num. Série do produto que foi substituído (o MATA650 não gravará essa informação)
	For nX := 1 to Len(aT4I)
		//Só gera se o produto principal possuir informações de Endereços ou Números de série
		If aT4I[nX][2] > 0 .And. (!Empty(aT4I[nX][3]) .Or. !Empty(aT4I[nX][4]))
			//Verifica se já existe essa mesma chave
			T4I->(dbSetOrder(1))
			If T4I->(dbSeek(aT4I[nX][1] + ; //T4I_FILIAL
							cNumVF      + ; //T4I_NUM
							aT4I[nX][3] + ; //T4I_LOCALI
							aT4I[nX][4]))   //T4I_NUMSER

				//Se existir, somente incrementa a quantidade
				RecLock("T4I",.F.)
				T4I->T4I_QUANT := T4I->T4I_QUANT + aT4I[nX][2]
				T4I->(MsUnLock())
			Else
				RecLock("T4I",.T.)
				T4I->T4I_FILIAL := aT4I[nX][1]
				T4I->T4I_NUM    := cNumVF
				T4I->T4I_QUANT  := aT4I[nX][2]
				T4I->T4I_LOCALI := aT4I[nX][3]
				T4I->T4I_NUMSER := aT4I[nX][4]
				T4I->(MsUnLock())
			EndIf
		EndIf
	Next nX

	//SVJ -> Grava as informações dos produtos alternativos que substituíram o original
	For nX := 1 to Len(aSVJ)
		RecLock("SVJ",.T.)
		SVJ->VJ_FILIAL  := aSVJ[nX][1]
		SVJ->VJ_NUM     := cNumVF
		SVJ->VJ_ALTERN  := aSVJ[nX][2]
		SVJ->VJ_LOCAL	:= aSVJ[nX][3]
		SVJ->VJ_TRT		:= aSVJ[nX][4]
		SVJ->VJ_SEQ		:= aSVJ[nX][5]
		SVJ->VJ_OPORIG	:= aSVJ[nX][6]
		SVJ->VJ_LOTE	:= aSVJ[nX][7]
		SVJ->VJ_SUBLOTE	:= aSVJ[nX][8]
		SVJ->VJ_ORDEM	:= aSVJ[nX][9]
		SVJ->VJ_QUANT	:= aSVJ[nX][10]
		SVJ->VJ_LOCALIZ := aSVJ[nX][11]
		SVJ->VJ_NUMSERI := aSVJ[nX][12]
		SVJ->(MsUnLock())
	Next nX

	RestArea(aArea)

Return

/*/{Protheus.doc} delOrdSub
Exclui as ordens de substituição de uma ordem de produção.
@author lucas.franca
@since 23/07/2018
@version 1.0
@return Nil
@param 01 - cOp	- Número da ordem de produção para fazer a busca das ordens de substituição que devem ser excluídas.
/*/
Function delOrdSub(cOp)
	Local aArea   := GetArea()
	Local cFilSVF := xFilial("SVF")
	Local cFilSVJ := xFilial("SVJ")
	Local cFilT4I := xFilial("T4I")

	mvlPCPOS := IIf(mvlPCPOS == NIL, SuperGetMV("MV_PCPOS",.F.,.F.), mvlPCPOS)
	If !mvlPCPOS
		Return
	EndIf

	SVF->(dbSetOrder(2))
	SVJ->(dbSetOrder(1))
	T4I->(dbSetOrder(1))
	If SVF->(dbSeek(cFilSVF+cOp))
		//Busca todas as ordens de substituição da OP para fazer a exclusão.
		While SVF->(!Eof()) .And. SVF->(VF_FILIAL+VF_OP) == cFilSVF+cOp
			//Busca os itens da ordem de substituição para excluir (SVJ)
			If SVJ->(dbSeek(cFilSVJ+SVF->VF_NUM))
				While SVJ->(!Eof()) .And. SVJ->(VJ_FILIAL+VJ_NUM) == cFilSVJ+SVF->VF_NUM
					//Exclui a tabela filho da ordem de substituição (SVJ)
					RecLock("SVJ",.F.)
					SVJ->(dbDelete())
					SVJ->(MsUnLock())

					SVJ->(dbSkip())
				End
			EndIf

			//Busca os endereços anteriores da ordem de substituição para exclusão.
			If T4I->(dbSeek(cFilT4I+SVF->VF_NUM))
				While T4I->(!Eof()) .And. T4I->(T4I_FILIAL+T4I_NUM) == cFilT4I+SVF->VF_NUM
					//Exclui a tabela filho da ordem de substituição (SVJ)
					RecLock("T4I",.F.)
					T4I->(dbDelete())
					T4I->(MsUnLock())

					T4I->(dbSkip())
				End
			EndIf

			//Exclui a tabela pai da ordem de substituição (SVF)
			RecLock("SVF",.F.)
			SVF->(dbDelete())
			SVF->(MsUnLock())

			SVF->(dbSkip())
		End
	EndIf

	RestArea(aArea)
Return Nil

/*/{Protheus.doc} RodaNewPCP
Função para identificar se será permitido executar os programas do NewPCP.
@type  Function
@author lucas.franca
@since 22/01/2019
@version P12
@return lRet, logical, Identifica se é permitido executar as rotinas do NewPCP
/*/
Function RodaNewPCP()
	Local lRet := .F.

	If AliasInDic("T4R")
		lRet := .T.
	EndIf
Return lRet

/*/{Protheus.doc} LockSVF

Cria uma trava para inserção na tabela SVF, ao criar a ordem de substituição.
Utilizar esse lock se estiver trabalhando com multiplas threads

@type  Static Function
@author ricardo.prandi
@since 04/12/2019
@version P12.1.27
@param cOp  , Character, Numeração da OP onde está sendo gerada a OS
@param cComp, Character, Código do componente que gerou a OS.
@return lRet, Lógico, Retorna se conseguiu realizar o lock
/*/
Static Function LockSVF(cOp, cComp)
	Local lRet       := .T.
	Local nTentativa := 0

	While !LockByName("SVFUSO" + cEmpAnt + cFilAnt + cOp + cComp, .T., .T., .T.)
		nTentativa ++
		If nTentativa > 5000
			lRet := .F.
			Exit
		EndIf
		Sleep(50)
	End
Return lRet

/*/{Protheus.doc} UnLockSVF
	
Retira o Lock na tabela SVF criada para inserção da ordem de substituição

@type  Static Function
@author ricardo.prandi
@since 04/12/2019
@version P12.1.27
@param cOp  , Character, Numeração da OP onde está sendo gerada a OS
@param cComp, Character, Código do componente que gerou a OS.
/*/
Static Function UnLockSVF(cOp, cComp)

	UnLockByName("SVFUSO" + cEmpAnt + cFilAnt + cOp + cComp, .T., .T., .T.)

Return .T.
