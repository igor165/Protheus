#INCLUDE "TOTVS.CH"

#DEFINE BUFFER_INTEGRACAO 1000

/*/{Protheus.doc} PCPA141PRD
Executa o processamento dos registros de Produtos

@type  Function
@author marcelo.neumann
@since 23/10/2019
@version P12.1.28
@param  cUUID , Caracter, Identificador do processo para buscar os dados na tabela T4R.
@return oErros, Objeto  , Json com os erros que ocorreram no processamento
/*/
Function PCPA141PRD(cUUID)
	Local aDados     := {}
	Local aDadosDel  := {}
	Local aDadosDet  := {}
	Local aDadosInc  := {}
	Local cAliasT4R  := PCPAliasQr()
	Local cAliasSB1  := PCPAliasQr()
	Local cFilialSB1 := ""
	Local cGlbErros  := "ERROS_141" + cUUID
	Local cProduto   := ""
	Local cQryFields := ""
	Local cQryCoBase := ""
	Local cQryCondic := ""
	Local lLock      := .F.
	Local nPos       := 0
	Local nPosDel    := 0
	Local nPosInc    := 0
	Local nTamFil    := FwSizeFilial()
	Local oErros     := JsonObject():New()
	Local oPCPLock   := PCPLockControl():New()

	//Campos que serão usados
	cQryFields := "%SB1.B1_FILIAL,"  + ;
				  " SB1.B1_COD,"     + ;
				  " SB1.B1_LOCPAD,"  + ;
				  " SB1.B1_TIPO,"    + ;
				  " SB1.B1_GRUPO,"   + ;
				  " SB1.B1_QE,"      + ;
				  " SB1.B1_EMIN,"    + ;
				  " SB1.B1_ESTSEG,"  + ;
				  " SB1.B1_PE,"      + ;
				  " SB1.B1_TIPE,"    + ;
				  " SB1.B1_LE,"      + ;
				  " SB1.B1_LM,"      + ;
				  " SB1.B1_TOLER,"   + ;
				  " SB1.B1_TIPODEC," + ;
				  " SB1.B1_RASTRO,"  + ;
				  " SB1.B1_MRP,"     + ;
				  " SB1.B1_CPOTENC," + ;
				  " SB1.B1_REVATU,"  + ;
				  " SB1.B1_EMAX,"    + ;
				  " SB1.B1_PRODSBP," + ;
				  " SB1.B1_LOTESBP," + ;
				  " SB1.B1_ESTRORI," + ;
				  " SB1.B1_APROPRI," + ;
				  " SB1.B1_MSBLQL,"  + ;
				  " SB1.B1_CONTRAT," + ;
				  " SB1.B1_OPERPAD," + ;
				  " SB1.B1_CCCUSTO," + ;
				  " SB1.B1_DESC,"    + ;
				  " SB1.B1_UM,"      + ;
				  " SB1.B1_GRUPCOM," + ;
				  " SVK.VK_HORFIX,"  + ;
				  " SVK.VK_TPHOFIX," + ;
				  " SB5.B5_FILIAL,"  + ;
				  " SB5.B5_LEADTR,"  + ;
				  " SB5.B5_COD, "    + ;
				  " CASE WHEN SB5.B5_AGLUMRP IN ('1', '6', '7') THEN NULL ELSE SB5.B5_AGLUMRP END B5_AGLUMRP, " +;
				  " SB1.B1_OPC,"     + ;
				  " SB1.B1_MOPC%"

	cQryCoBase := RetSqlName("SB1") + " SB1"                      + ;
			    " LEFT OUTER JOIN " + RetSqlName("SVK") + " SVK"  + ;
			      " ON SVK.VK_FILIAL  = '" + xFilial("SVK") + "'" + ;
			     " AND SVK.VK_COD     = SB1.B1_COD"               + ;
			     " AND SVK.D_E_L_E_T_ = ' '"                      + ;
				 " LEFT OUTER JOIN " + RetSqlName("SB5") + " SB5" + ;
			     " ON SB5.B5_COD     = SB1.B1_COD"               + ;
			     " AND SB5.D_E_L_E_T_ = ' '"                      + ;
			   " WHERE SB1.D_E_L_E_T_ = ' '"

	//Busca os registros a serem processados pelo Job
	BeginSql Alias cAliasT4R
		SELECT T4R.T4R_TIPO,
		       T4R.T4R_IDREG
		  FROM %Table:T4R% T4R
		 WHERE T4R.T4R_FILIAL = %xfilial:T4R%
		   AND T4R.T4R_API    = 'MRPPRODUCT'
		   AND T4R.T4R_STATUS = '3'
		   AND T4R.T4R_IDPRC  = %Exp:cUUID%
		   AND T4R.%NotDel%
	EndSql

	If (cAliasT4R)->(!Eof())
		lLock := oPCPLock:lock("MRP_MEMORIA", "PCPA141", "MRPPRODUCT", .F., {"PCPA712", "PCPA145", "PCPA151"}, 2)
	EndIf

	PutGlbValue(cGlbErros, "0")

	nPosDel := 0
	nPosInc := 0
	While (cAliasT4R)->(!Eof())
		//Extrai a chave (Filial + Produto) gravada na T4R
		cFilialSB1 := SubStr((cAliasT4R)->T4R_IDREG, 1 , nTamFil)
		cProduto   := AllTrim(SubStr((cAliasT4R)->T4R_IDREG, 1 + nTamFil))

		If (cAliasT4R)->(T4R_TIPO) != "2"
			//Se não for exclusão, busca as informações na SB1 e SVK
			cQryCondic := "%" + cQryCoBase + " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'" + ;
			                                 " AND SB1.B1_COD    = '" + cProduto   + "'%"

			BeginSql Alias cAliasSB1
				SELECT %Exp:cQryFields%
				  FROM %Exp:cQryCondic%
			EndSql
		EndIf

		//Se for Exclusão ou não acho o registro, basta enviar a chave gravada no T4R_IDREG para exclusão
		If (cAliasT4R)->(T4R_TIPO) == "2" .Or. (cAliasSB1)->(EoF())
			aSize(aDados, 0)
			aDados := Array(A010APICnt("ARRAY_PROD_SIZE"))

			aDados[A010APICnt("ARRAY_PROD_POS_FILIAL")] := xFilial("SB1", cFilialSB1)
			aDados[A010APICnt("ARRAY_PROD_POS_PROD"  )] := cProduto
			aDados[A010APICnt("ARRAY_PROD_POS_IDREG" )] := cFilialSB1 + cProduto

			aAdd(aDadosDel, aClone(aDados))
			nPosDel++
		Else
			aSize(aDados, 0)
			aDados := Array(A010APICnt("ARRAY_PROD_SIZE"))

			//Adiciona as informações no array de inclusão/atualização
			aDados[A010APICnt("ARRAY_PROD_POS_FILIAL"   )] := xFilial("SB1", cFilialSB1)
			aDados[A010APICnt("ARRAY_PROD_POS_PROD"     )] := cProduto
			aDados[A010APICnt("ARRAY_PROD_POS_LOCPAD"   )] := (cAliasSB1)->B1_LOCPAD
			aDados[A010APICnt("ARRAY_PROD_POS_TIPO"     )] := (cAliasSB1)->B1_TIPO
			aDados[A010APICnt("ARRAY_PROD_POS_GRUPO"    )] := (cAliasSB1)->B1_GRUPO
			aDados[A010APICnt("ARRAY_PROD_POS_QE"       )] := (cAliasSB1)->B1_QE
			aDados[A010APICnt("ARRAY_PROD_POS_EMIN"     )] := (cAliasSB1)->B1_EMIN
			aDados[A010APICnt("ARRAY_PROD_POS_ESTSEG"   )] := (cAliasSB1)->B1_ESTSEG
			aDados[A010APICnt("ARRAY_PROD_POS_PE"       )] := (cAliasSB1)->B1_PE
			aDados[A010APICnt("ARRAY_PROD_POS_TIPE"     )] := M010CnvFld("B1_TIPE"   , (cAliasSB1)->B1_TIPE)
			aDados[A010APICnt("ARRAY_PROD_POS_LE"       )] := (cAliasSB1)->B1_LE
			aDados[A010APICnt("ARRAY_PROD_POS_LM"       )] := (cAliasSB1)->B1_LM
			aDados[A010APICnt("ARRAY_PROD_POS_TOLER"    )] := (cAliasSB1)->B1_TOLER
			aDados[A010APICnt("ARRAY_PROD_POS_TIPDEC"   )] := M010CnvFld("B1_TIPODEC", (cAliasSB1)->B1_TIPODEC)
			aDados[A010APICnt("ARRAY_PROD_POS_RASTRO"   )] := M010CnvFld("B1_RASTRO" , (cAliasSB1)->B1_RASTRO)
			aDados[A010APICnt("ARRAY_PROD_POS_MRP"      )] := M010CnvFld("B1_MRP"    , (cAliasSB1)->B1_MRP)
			aDados[A010APICnt("ARRAY_PROD_POS_REVATU"   )] := (cAliasSB1)->B1_REVATU
			aDados[A010APICnt("ARRAY_PROD_POS_EMAX"     )] := (cAliasSB1)->B1_EMAX
			aDados[A010APICnt("ARRAY_PROD_POS_PROSBP"   )] := M010CnvFld("B1_PRODSBP", (cAliasSB1)->B1_PRODSBP)
			aDados[A010APICnt("ARRAY_PROD_POS_LOTSBP"   )] := (cAliasSB1)->B1_LOTESBP
			aDados[A010APICnt("ARRAY_PROD_POS_ESTORI"   )] := (cAliasSB1)->B1_ESTRORI
			aDados[A010APICnt("ARRAY_PROD_POS_APROPR"   )] := M010CnvFld("B1_APROPRI", (cAliasSB1)->B1_APROPRI)
			aDados[A010APICnt("ARRAY_PROD_POS_HORFIX"   )] := (cAliasSB1)->VK_HORFIX
			aDados[A010APICnt("ARRAY_PROD_POS_TPHFIX"   )] := (cAliasSB1)->VK_TPHOFIX
			aDados[A010APICnt("ARRAY_PROD_POS_NUMDEC"   )] := "0" //Protheus não utiliza esse campo, passar 0 fixo
			aDados[A010APICnt("ARRAY_PROD_POS_IDREG"    )] := cFilialSB1 + cProduto
			aDados[A010APICnt("ARRAY_PROD_POS_CPOTEN"   )] := (cAliasSB1)->B1_CPOTENC
			aDados[A010APICnt("ARRAY_PROD_POS_BLOQUEADO")] := (cAliasSB1)->B1_MSBLQL
			aDados[A010APICnt("ARRAY_PROD_POS_CONTRATO" )] := M010CnvFld("B1_CONTRAT", (cAliasSB1)->B1_CONTRAT)
			aDados[A010APICnt("ARRAY_PROD_POS_ROTEIRO"  )] := (cAliasSB1)->B1_OPERPAD
			aDados[A010APICnt("ARRAY_PROD_POS_CCUSTO"   )] := (cAliasSB1)->B1_CCCUSTO
			aDados[A010APICnt("ARRAY_PROD_POS_DESC"     )] := (cAliasSB1)->B1_DESC
			aDados[A010APICnt("ARRAY_PROD_POS_DESCTP"   )] := M010CnvFld("B1_DESCTP", (cAliasSB1)->B1_TIPO)
			aDados[A010APICnt("ARRAY_PROD_POS_GRPCOM"   )] := (cAliasSB1)->B1_GRUPCOM
			aDados[A010APICnt("ARRAY_PROD_POS_GCDESC"   )] := M010CnvFld("B1_GCDESC", (cAliasSB1)->B1_GRUPCOM)
			aDados[A010APICnt("ARRAY_PROD_POS_UM"       )] := (cAliasSB1)->B1_UM
			aDados[A010APICnt("ARRAY_PROD_POS_LDTRANSF" )] := {}
			aDados[A010APICnt("ARRAY_PROD_POS_OPC"      )] := (cAliasSB1)->B1_MOPC
			aDados[A010APICnt("ARRAY_PROD_POS_STR_OPC"  )] := (cAliasSB1)->B1_OPC

			While (cAliasSB1)->(!Eof())
				If !Empty((cAliasSB1)->B5_COD)
					aAdd(aDados[A010APICnt("ARRAY_PROD_POS_LDTRANSF" )], Array(A010APICnt("ARRAY_TRANSF_POS_SIZE")))
					nPos := Len(aDados[A010APICnt("ARRAY_PROD_POS_LDTRANSF" )])

					aDados[A010APICnt("ARRAY_PROD_POS_LDTRANSF" )][nPos][A010APICnt("ARRAY_TRANSF_POS_FILIAL"  )] := (cAliasSB1)->B5_FILIAL
					aDados[A010APICnt("ARRAY_PROD_POS_LDTRANSF" )][nPos][A010APICnt("ARRAY_TRANSF_POS_LEADTIME")] := (cAliasSB1)->B5_LEADTR
					aDados[A010APICnt("ARRAY_PROD_POS_LDTRANSF" )][nPos][A010APICnt("ARRAY_TRANSF_POS_AGLUTMRP")] := (cAliasSB1)->B5_AGLUMRP
				EndIf
				(cAliasSB1)->(dbSkip())
			EndDo

			aAdd(aDadosInc, aClone(aDados))
			nPosInc++
		EndIf

		If (cAliasT4R)->(T4R_TIPO) != "2"
			(cAliasSB1)->(dbCloseArea())
		EndIf
		(cAliasT4R)->(dbSkip())

		//Executa a integração para exclusão
		If nPosDel > BUFFER_INTEGRACAO .Or. ((cAliasT4R)->(Eof()) .And. Len(aDadosDel) > 0)
			P141Intgra("MRPPRODUCT", nPosDel, "MATA010INT", cGlbErros, "DELETE", aDadosDel, Nil, Nil, .F., cUUID)

			aSize(aDadosDel, 0)
			nPosDel := 0
		EndIf

		//Executa a integração para inclusão/atualização
		If nPosInc > BUFFER_INTEGRACAO .Or. ((cAliasT4R)->(Eof()) .And. Len(aDadosInc) > 0)
			P141Intgra("MRPPRODUCT", nPosInc, "MATA010INT", cGlbErros, "INSERT", aDadosInc, Nil, Nil, .F., cUUID)

			aSize(aDadosInc, 0)
			nPosInc := 0
		EndIf
	End
	(cAliasT4R)->(dbCloseArea())

	If lLock
		oPCPLock:unlock("MRP_MEMORIA", "PCPA141", "MRPPRODUCT")
	EndIf

	oErros["ERROR_LOG"] := Val(GetGlbValue(cGlbErros))
	ClearGlbValue(cGlbErros)

	aSize(aDadosDel, 0)
	aSize(aDadosDet, 0)
	aSize(aDadosInc, 0)
	aSize(aDados   , 0)

	PCPA141IPR(cUUID)

Return oErros

/*/{Protheus.doc} PCPA141IPR
Executa o processamento dos registros de Indicadores de Produtos

@type  Function
@author renan.roeder
@since 19/11/2019
@version P12.1.27
@param cUUID, Character, Identificador do processo para buscar os dados na tabela T4R.
/*/
Function PCPA141IPR(cUUID)

	Local aDados     := {}
	Local aDadosDel  := {}
	Local aDadosDet  := {}
	Local aDadosInc  := {}
	Local cAliasT4R  := PCPAliasQr()
	Local cAliasSBZ  := PCPAliasQr()
	Local cQryFields := ""
	Local cQryCoBase := ""
	Local cQryCondic := ""

	//Variáveis para extração da Chave
	Local cFilialSBZ := ""
	Local cProduto   := ""
	Local nTamFil    := FwSizeFilial()

	Local oPCPLock  := PCPLockControl():New()
	Local lLock     := .F.

	//Campos que serão usados
	cQryFields := "%SBZ.BZ_FILIAL,"  + ;
				  " SBZ.BZ_COD,"     + ;
				  " SBZ.BZ_LOCPAD,"  + ;
				  " SBZ.BZ_QE,"      + ;
				  " SBZ.BZ_EMIN,"    + ;
				  " SBZ.BZ_ESTSEG,"  + ;
				  " SBZ.BZ_PE,"      + ;
				  " SBZ.BZ_TIPE,"    + ;
				  " SBZ.BZ_LE,"      + ;
				  " SBZ.BZ_LM,"      + ;
				  " SBZ.BZ_TOLER,"   + ;
				  " SBZ.BZ_MRP,"     + ;
				  " SBZ.BZ_REVATU,"  + ;
				  " SBZ.BZ_EMAX,"    + ;
				  " SBZ.BZ_HORFIX,"  + ;
				  " SBZ.BZ_TPHOFIX," + ;
				  " SBZ.BZ_OPC,"     + ;
				  " SBZ.BZ_MOPC%"

	cQryCoBase := RetSqlName("SBZ") + " SBZ"                      + ;
			   " WHERE SBZ.D_E_L_E_T_ = ' '"

	//Busca os registros a serem processados pelo Job
	BeginSql Alias cAliasT4R
		SELECT T4R.T4R_TIPO,
		       T4R.T4R_IDREG
		  FROM %Table:T4R% T4R
		 WHERE T4R.T4R_FILIAL = %xfilial:T4R%
		   AND T4R.T4R_API    = 'MRPPRODUCTINDICATOR'
		   AND T4R.T4R_STATUS = '3'
		   AND T4R.T4R_IDPRC  = %Exp:cUUID%
		   AND T4R.%NotDel%
	EndSql

	If (cAliasT4R)->(!Eof())
		lLock := oPCPLock:lock("MRP_MEMORIA", "PCPA141", "MRPPRODUCTINDICATOR", .F., {"PCPA712", "PCPA145", "PCPA151"}, 2)
	EndIf

	While (cAliasT4R)->(!Eof())
		//Extrai a chave (Filial + Produto) gravada na T4R
		cFilialSBZ := SubStr((cAliasT4R)->T4R_IDREG, 1 , nTamFil)
		cProduto   := AllTrim(SubStr((cAliasT4R)->T4R_IDREG, 1 + nTamFil))

		//Se for Exclusão, basta enviar a chave gravada no T4R_IDREG
		If (cAliasT4R)->(T4R_TIPO) == "2"
			aSize(aDados, 0)
			aDados := Array(A019APICnt("ARRAY_IND_PROD_SIZE"))

			aDados[A019APICnt("ARRAY_IND_PROD_POS_FILIAL")] := cFilialSBZ
			aDados[A019APICnt("ARRAY_IND_PROD_POS_PROD"  )] := cProduto
			aDados[A019APICnt("ARRAY_IND_PROD_POS_IDREG" )] := cFilialSBZ + cProduto

			aAdd(aDadosDel, aClone(aDados))
		Else
			//Se for Inclusão, busca as informações na SBZ
			cQryCondic := "%" + cQryCoBase + " AND SBZ.BZ_FILIAL = '" + cFilialSBZ + "'" + ;
			                                 " AND SBZ.BZ_COD    = '" + cProduto   + "'%"

			BeginSql Alias cAliasSBZ
				SELECT %Exp:cQryFields%
				  FROM %Exp:cQryCondic%
			EndSql

			//Se encontrou o registro, grava no array de inclusão
			If (cAliasSBZ)->(!Eof())
				aSize(aDados, 0)
				aDados := Array(A019APICnt("ARRAY_IND_PROD_SIZE"))

				//Adiciona as informações no array de inclusão/atualização
				aDados[A019APICnt("ARRAY_IND_PROD_POS_FILIAL"  )] := cFilialSBZ
				aDados[A019APICnt("ARRAY_IND_PROD_POS_PROD"    )] := cProduto
				aDados[A019APICnt("ARRAY_IND_PROD_POS_LOCPAD"  )] := (cAliasSBZ)->BZ_LOCPAD
				aDados[A019APICnt("ARRAY_IND_PROD_POS_QE"      )] := (cAliasSBZ)->BZ_QE
				aDados[A019APICnt("ARRAY_IND_PROD_POS_EMIN"    )] := (cAliasSBZ)->BZ_EMIN
				aDados[A019APICnt("ARRAY_IND_PROD_POS_ESTSEG"  )] := (cAliasSBZ)->BZ_ESTSEG
				aDados[A019APICnt("ARRAY_IND_PROD_POS_PE"      )] := (cAliasSBZ)->BZ_PE
				aDados[A019APICnt("ARRAY_IND_PROD_POS_TIPE"    )] := M019CnvFld("BZ_TIPE"   , (cAliasSBZ)->BZ_TIPE)
				aDados[A019APICnt("ARRAY_IND_PROD_POS_LE"      )] := (cAliasSBZ)->BZ_LE
				aDados[A019APICnt("ARRAY_IND_PROD_POS_LM"      )] := (cAliasSBZ)->BZ_LM
				aDados[A019APICnt("ARRAY_IND_PROD_POS_TOLER"   )] := (cAliasSBZ)->BZ_TOLER
				aDados[A019APICnt("ARRAY_IND_PROD_POS_MRP"     )] := M019CnvFld("BZ_MRP"    , (cAliasSBZ)->BZ_MRP)
				aDados[A019APICnt("ARRAY_IND_PROD_POS_REVATU"  )] := (cAliasSBZ)->BZ_REVATU
				aDados[A019APICnt("ARRAY_IND_PROD_POS_EMAX"    )] := (cAliasSBZ)->BZ_EMAX
				aDados[A019APICnt("ARRAY_IND_PROD_POS_HORFIX"  )] := (cAliasSBZ)->BZ_HORFIX
				aDados[A019APICnt("ARRAY_IND_PROD_POS_TPHFIX"  )] := (cAliasSBZ)->BZ_TPHOFIX
				aDados[A019APICnt("ARRAY_IND_PROD_POS_IDREG"   )] := cFilialSBZ + cProduto
				aDados[A019APICnt("ARRAY_IND_PROD_POS_OPC"     )] := (cAliasSBZ)->BZ_MOPC
				aDados[A019APICnt("ARRAY_IND_PROD_POS_STR_OPC" )] := (cAliasSBZ)->BZ_OPC

				aAdd(aDadosInc, aClone(aDados))

			EndIf
			(cAliasSBZ)->(dbCloseArea())
		EndIf

		(cAliasT4R)->(dbSkip())
	End
	(cAliasT4R)->(dbCloseArea())

	//Executa a integração para exclusão
	If Len(aDadosDel) > 0
		MATA019INT("DELETE", aDadosDel, Nil, Nil, .F., cUUID)
	EndIf

	//Executa a integração para inclusão/atualização
	If Len(aDadosInc) > 0
		MATA019INT("INSERT", aDadosInc, Nil, Nil, .F., cUUID)
	EndIf

	If lLock
		oPCPLock:unlock("MRP_MEMORIA", "PCPA141", "MRPPRODUCTINDICATOR")
	EndIf

	aSize(aDadosDel, 0)
	aSize(aDadosDet, 0)
	aSize(aDadosInc, 0)
	aSize(aDados   , 0)

Return
