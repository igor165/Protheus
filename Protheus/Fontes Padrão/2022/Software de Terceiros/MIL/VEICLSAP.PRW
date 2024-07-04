////////////////
// Versao 026 //
////////////////

#include "protheus.ch"
#include "VEICLSAP.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  18/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006132_1"

Function VEICLSAP()
Return


/*/{Protheus.doc} DMS_Peca
	@author       Vinicius Gati
	@since        30/04/2014
	@description  Acessa o banco para processar pecas(SB1)
	@version 1.0

	@type class
/*/
Class DMS_Peca

	Data cGruIte
	Data cCodIte
	Data cCodB1
	Data cLocPadrao

	Method New(cGrupo,cCodigo) CONSTRUCTOR
	Method Bloqueado()
	Method Bloquear()
	Method Desbloquear()
	Method GetGrupo()
	Method SetGrupo()
	Method GetCodigo()
	Method SetCodigo()
	Method SetCodB1()
	Method LoadB1()
	Method UpdateGroup()
	Method EstqSaldo()
	Method EstqSaldo2()
	Method TabelaPreco()
	Method ValorVenda()
	Method ValorCusto()
	Method ItensRelacionados()
	Method ItensSubstituidos()
	Method GetUltVenda()
	Method GetUltCompra()
	Method GetDemanda()
	Method PedCompraPendente()
	Method GetInfComplem()
	Method RetDiaEstqZero()
	Method SaldoLoteMovimentacao()
	Method LoteDtValid()
	Method CriaPeca()
	Method ExcluiPeca()
	Method Conv1UM()
	Method Conv2UM()
	Method LeCodBarras()
EndClass


/*/{Protheus.doc} New
	Construtor simples DMS_Peca

	@author Vinicius Gati
	@since 21/05/2014
	@version 1.0
	@param cGrupo, characters, descricao
	@param cCodigo, characters, descricao
	@type function
/*/
Method New(cGrupo,cCodigo) Class DMS_Peca
	Default cGrupo  := ""
	Default cCodigo := ""
	Self:cGruIte := cGrupo
	Self:cCodIte := cCodigo
	If !Empty(Self:cCodIte)
		Self:SetCodigo(cCodigo)
	Else
		Self:cCodB1 := ""
	EndIf
Return SELF

/*/{Protheus.doc} Bloqueado
	Verifica se a peça está bloqueado através do campo B1_MSBLQL
	e se parametrizado mostrará o help

	@return boolean, .t.|.f. se bloqueado ou não
	@author Vinicius Gati
	@since 16/02/2017
	@version 1.0
	@param cB1Cod, characters, descricao
	@param cB1CodIte, characters, descricao
	@param cGrp, characters, descricao
	@param lShowHlp, logical, descricao
	@type function
/*/
Method Bloqueado(cB1Cod, cB1CodIte, cGrp, lShowHlp) class DMS_Peca
	Local cMsg       := ""
	Local lBloq      := .F.
	Local aArea      := GetArea()
	Local aAreaB1    := SB1->(GetArea())
	Default lShowHlp := .T.
	Default cB1Cod   := ''

	if Empty(cB1Cod)
		dbSelectarea('SB1')
		dbSetOrder(7)
		msSeek(xFilial('SB1') + cGrp + cB1CodIte)
	else
		dbSelectarea('SB1')
		dbSetOrder(1)
		msSeek(xFilial('SB1') + cB1Cod)
	end

	if SB1->( Found() ) .AND. SB1->B1_MSBLQL == '1'
		lBloq := .T.
	end

	if lBloq .AND. lShowHlp
		cMsg := chr(13) + chr(10) + "SB1" + chr(13) + chr(10)
		cMsg += RetTitle("B1_COD")    + ":" + SB1->B1_COD    + chr(13) + chr(10)
		cMsg += RetTitle("B1_CODITE") + ":" + SB1->B1_CODITE + chr(13) + chr(10)
		cMsg += RetTitle("B1_GRUPO")  + ":" + SB1->B1_GRUPO  + chr(13) + chr(10)

		HELP(" ",1,"REGBLOQ",,cMsg,3,1)
	end

	RestArea( aAreaB1 )
	RestArea( aArea   )
Return lBloq

/*/{Protheus.doc} Desbloquear
	Desbloqueia um item

	@return boolean, .t.|.f. se desbloqueado ou não
	@author Vinicius Gati
	@since 20/03/2017
	@version 1.0
	@param cB1Cod, characters, descricao
	@param cB1CodIte, characters, descricao
	@param cGrp, characters, descricao
	@type function
/*/
Method Desbloquear(cB1Cod, cB1CodIte, cGrp) class DMS_Peca
	Local lBloq      := .F.
	Local aArea      := GetArea()
	Local aAreaB1    := SB1->(GetArea())
	Default cB1Cod   := ''

	if Empty(cB1Cod)
		dbSelectarea('SB1')
		dbSetOrder(7)
		msSeek(xFilial('SB1') + cGrp + cB1CodIte)
	else
		dbSelectarea('SB1')
		dbSetOrder(1)
		msSeek(xFilial('SB1') + cB1Cod)
	end

	if SB1->( Found() ) .AND. SB1->B1_MSBLQL == '1'
		reclock('SB1', .F.)
		SB1->B1_MSBLQL = '0'
		SB1->(MsUnlock())
		lBloq := .T.
	end

	RestArea( aAreaB1 )
	RestArea( aArea   )
Return lBloq

/*/{Protheus.doc} Desbloquear
	Bloqueia um item

	@return boolean, se foi bloqueado
	@author Vinicius Gati
	@since 20/03/2017
	@version 1.0
	@param cB1Cod, characters, descricao
	@param cB1CodIte, characters, descricao
	@param cGrp, characters, descricao
	@type function
/*/
Method Bloquear(cB1Cod, cB1CodIte, cGrp) class DMS_Peca
	Local lBloq      := .F.
	Local aArea      := GetArea()
	Local aAreaB1    := SB1->(GetArea())
	Default cB1Cod   := ''

	if Empty(cB1Cod)
		dbSelectarea('SB1')
		dbSetOrder(7)
		msSeek(xFilial('SB1') + cGrp + cB1CodIte)
	else
		dbSelectarea('SB1')
		dbSetOrder(1)
		msSeek(xFilial('SB1') + cB1Cod)
	end

	if SB1->( Found() ) .AND. SB1->B1_MSBLQL != '1'
		reclock('SB1', .F.)
		SB1->B1_MSBLQL = '1'
		SB1->(MsUnlock())
		lBloq := .T.
	end

	RestArea( aAreaB1 )
	RestArea( aArea   )
Return lBloq

/*/{Protheus.doc} GetGrupo
	Retorna o grupo da peça associada ao objeto


	@author Takahashi
	@since 16/02/2017
	@version 1.0

	@type function
/*/
Method GetGrupo() Class DMS_Peca
Return Self:cGruIte

/*/{Protheus.doc} SetGrupo
	Seta o grupo na peça associada ao objeto
	se o grupo existir na SBM

	@author Takahashi
	@since 16/02/2017
	@version 1.0
	@param cGrupo, characters, descricao
	@type function

/*/
Method SetGrupo(cGrupo) Class DMS_Peca
	Local lFound := .t.
	If Empty(cGrupo) .or. (lFound := ExistCpo("SBM", cGrupo))
		Self:cGruIte := cGrupo
		Self:SetCodigo("")
	EndIf
Return lFound

Method GetCodigo() Class DMS_Peca
Return Self:cCodIte

Method SetCodigo(cCodigo) Class DMS_Peca
	Local lFound := .t.
	Local aAreaB1 := sGetArea(,"SB1")

	SB1->(dbSetOrder(7))
	If Empty(cCodigo) .or. (lFound := SB1->(MsSeek(xFilial("SB1") + self:GetGrupo() + cCodigo)) )
		Self:cCodIte := cCodigo
		Self:cCodB1  := SB1->B1_COD
		Self:cLocPadrao := SB1->B1_LOCPAD
	EndIf
	sRestArea(aAreaB1)
Return lFound

Method SetCodB1(cParCodB1) Class DMS_Peca
	Local lFound := .t.
	Local aAreaB1 := sGetArea(,"SB1")

	SB1->(dbSetOrder(1))
	If ( lFound := SB1->(MsSeek(xFilial("SB1") + cParCodB1)) )
		Self:LoadB1()
	EndIf
	sRestArea(aAreaB1)
Return lFound

Method LoadB1() Class DMS_Peca
	Self:cCodB1  := SB1->B1_COD
	Self:cCodIte := SB1->B1_CODITE
	Self:cGruIte := SB1->B1_GRUPO
	Self:cLocPadrao := SB1->B1_LOCPAD
Return

Method EstqSaldo(cLocal,lAllFil,lRetDescr) Class DMS_Peca

	Local aRetorno := {}
	Local nPos
	Local nCont
	Local nCont2
	Local aAuxArea
	Local oFilHelp := DMS_FilialHelper():New()

	aSM0 := oFilHelp:GetAllFilEmpresa(lAllFil)

	aAuxArea := sGetArea(,"SB2")
	aAuxArea := sGetArea(aAuxArea,"SBE")

	Default cLocal  := ""
	Default lAllFil := .f.
	Default lRetDescr := .f.

	cBkpCFilAnt := cFilAnt
	For nCont := 1 to Len(aSM0)

		cFilAnt := aSM0[nCont]

		cAuxNomeFil := FWFilialName()

		SB2->(dbSetOrder(1))
		SB2->(dbSeek(xFilial("SB2") + Self:cCodB1 + IIf(!Empty(cLocal),cLocal,"") ))
		While !SB2->(Eof()) .and. SB2->B2_FILIAL == xFilial("SB2") .and. SB2->B2_COD == Self:cCodB1 .and. ( Empty(cLocal) .or. SB2->B2_LOCAL == cLocal )
			AADD( aRetorno , { SB2->B2_FILIAL , SB2->B2_LOCAL , SB2->(SaldoSb2()) , "" , cAuxNomeFil } )
			SB2->(DbSkip())
		End

		If lRetDescr .and. (nPos := aScan(aRetorno,{ |x| x[1] == cFilAnt }) ) <> 0
			NNR->(dbSetOrder(1))
			For nCont2 := nPos to Len(aRetorno)
				NNR->( dbSeek(xFilial("NNR") + aRetorno[nCont2,2]) )
				if NNR->(Found())
					aRetorno[nCont2,4] := NNR->NNR_DESCRI
				else
					aRetorno[nCont2,4] := ""
				end
			Next nCont2
		EndIf

	Next nCont
	cFilAnt := cBkpCFilAnt

	sRestArea(aAuxArea)

Return aRetorno

Method EstqSaldo2(cLocal,lAllFil) Class DMS_Peca

	Local nRetorno
	Local nCont
	Local aAuxRet

	Default cLocal  := ""
	Default lAllFil := .f.

	aAuxRet := Self:EstqSaldo(cLocal,lAllFil,.f.)

	nRetorno := 0
	For nCont := 1 to Len(aAuxRet)
		nRetorno += aAuxRet[nCont,3]
	Next nCont

Return nRetorno

Method TabelaPreco() Class DMS_Peca

	Local aRetorno := {}
	Local nCont
	Local nRecNoVEG
//	Local cBkpFilAnt := cFilAnt
	Local aAuxArea

	aAuxArea := sGetArea(,"SB1")
	aAuxArea := sGetArea(aAuxArea,"SB5")
	aAuxArea := sGetArea(aAuxArea,"VEG")

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + Self:cCodB1))

	SB5->(dbSetOrder(1))
	SB5->(dbSeek(xFilial("SB5")+SB1->B1_COD))

	VEG->(dbSetOrder(2))
	VEG->(dbSeek(xFilial("VEG")+"04"))
	Do While !VEG->(EOF()) .and. VEG->VEG_FILIAL == xFilial("VEG") .and. VEG->VEG_GRUFOR == "04"
		If Empty(VEG->VEG_GRUPOS)
			lRet := .t.
		Else
			lRet := .f.
			For nCont := 1 to Len(VEG->VEG_GRUPOS) Step 4
				If Empty(SubStr(VEG->VEG_GRUPOS,nCont,4))
					Exit
				EndIf
				If Self:GetGrupo() == SubStr(VEG->VEG_GRUPOS,nCont,4)
					lRet := .t.
					Exit
				EndIf
			Next nCont
		EndIf
		//
		nRecNoVEG := VEG->(RecNo())
		If lRet
			AADD( aRetorno , { AllTrim(VEG->VEG_DESCRI), FG_FORMULA(VEG->VEG_CODIGO) } )
		Endif
		//
		VEG->(dbSetOrder(2))
		VEG->(DbGoto(nRecNoVEG))
		VEG->(dbSkip())
	Enddo
	//
//	cFilAnt := cBkpFilAnt
	//

	sRestArea(aAuxArea)

Return aRetorno

Method ItensRelacionados() Class DMS_Peca
	Local aAuxArea := sGetArea(,"SB1")
	Local aRetorno := FG_ITEREL( Nil , Self:GetGrupo() , Self:GetCodigo() , GetNewPar("MV_FMLPECA") )
	sRestArea(aAuxArea)
Return aRetorno

Method ItensSubstituidos() Class DMS_Peca
	Local cSQL
	Local lWhile   := .t.
	Local TVE9     := "TALIAVE9"
	Local ni       := 0
	Local nLenTot  := 0
	Local aRetorno := {}
	Local aAuxArea := {}
	Local cNamVE9  := RetSQLName("VE9")
	Local cNamSB1  := RetSQLName("SB1")
	Local cFilVE9  := xFilial("VE9")
	Local cFilSB1  := xFilial("SB1")
	Local cFilSB2  := xFilial("SB2")
	Local cGruIte  := Self:cGruIte
	Local cCodIte  := Self:cCodIte
	aAuxArea := sGetArea(,"SB1")
	aAuxArea := sGetArea(aAuxArea,"SB2")
	// Levantar os Antigos //
	cSQL := "SELECT VE9.VE9_GRUITE , VE9.VE9_ITEANT , SB1.B1_DESC , SB1.B1_COD , VE9.R_E_C_N_O_ RECVE9 FROM " + cNamVE9 + " VE9 "
	cSQL += "JOIN "+cNamSB1+" SB1 ON ( SB1.B1_FILIAL='"+cFilSB1+"' AND SB1.B1_GRUPO=VE9.VE9_GRUITE AND SB1.B1_CODITE=VE9.VE9_ITEANT AND SB1.D_E_L_E_T_=' ' ) "
	cSQL += "WHERE VE9.VE9_FILIAL='"+cFilVE9+"' AND VE9.VE9_GRUNOV='"+cGruIte+"' AND VE9.VE9_ITENOV='"+cCodIte+"' AND VE9.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), TVE9 , .F., .T. )
	While !(TVE9)->(Eof())
		AADD( aRetorno , { (TVE9)->VE9_GRUITE, (TVE9)->VE9_ITEANT , (TVE9)->B1_DESC , (TVE9)->B1_COD , (TVE9)->RECVE9 , .f. , 0 , "A" , 0 } )
		(TVE9)->(dbSkip())
	End
	(TVE9)->(dbCloseArea())
	// Levantar os Antigos dos Antigos //
	lWhile := .t.
	While lWhile
		lWhile  := .f.
		nLenTot := len(aRetorno)
		For ni := 1 to nLenTot
			If !aRetorno[ni,6]
				If aScan( aRetorno ,{ |x| x[1] + x[2] == aRetorno[ni,1] + aRetorno[ni,2] } ) <= 0
					aRetorno[ni,6] := .t.
					cSQL := "SELECT VE9.VE9_GRUITE , VE9.VE9_ITEANT , SB1.B1_DESC , SB1.B1_COD , VE9.R_E_C_N_O_ RECVE9 FROM " + cNamVE9 + " VE9 "
					cSQL += "JOIN "+cNamSB1+" SB1 ON ( SB1.B1_FILIAL='"+cFilSB1+"' AND SB1.B1_GRUPO=VE9.VE9_GRUITE AND SB1.B1_CODITE=VE9.VE9_ITEANT AND SB1.D_E_L_E_T_=' ' ) "
					cSQL += "WHERE VE9.VE9_FILIAL='"+cFilVE9+"' AND VE9.VE9_GRUNOV='"+aRetorno[ni,1]+"' AND VE9.VE9_ITENOV='"+aRetorno[ni,2]+"' AND VE9.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), TVE9 , .F., .T. )
					While !(TVE9)->(Eof())
						AADD( aRetorno , { (TVE9)->VE9_GRUITE, (TVE9)->VE9_ITEANT , (TVE9)->B1_DESC , (TVE9)->B1_COD , (TVE9)->RECVE9 , .f. , 0 , "A" , 0  } )
						lWhile := .t.
						(TVE9)->(dbSkip())
					End
					(TVE9)->(dbCloseArea())
				EndIf
			EndIf
		Next
	End
	// Levantar os Novos //
	cSQL := "SELECT VE9.VE9_GRUNOV , VE9.VE9_ITENOV , SB1.B1_DESC , SB1.B1_COD , VE9.R_E_C_N_O_ RECVE9 FROM " + cNamVE9 + " VE9 "
	cSQL += "JOIN "+cNamSB1+" SB1 ON ( SB1.B1_FILIAL='"+cFilSB1+"' AND SB1.B1_GRUPO=VE9.VE9_GRUNOV AND SB1.B1_CODITE=VE9.VE9_ITENOV AND SB1.D_E_L_E_T_=' ' ) "
	cSQL += "WHERE VE9.VE9_FILIAL='"+cFilVE9+"' AND VE9.VE9_GRUITE='"+cGruIte+"' AND VE9.VE9_ITEANT='"+cCodIte+"' AND VE9.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), TVE9 , .F., .T. )
	While !(TVE9)->(Eof())
		AADD( aRetorno , { (TVE9)->VE9_GRUNOV, (TVE9)->VE9_ITENOV , (TVE9)->B1_DESC , (TVE9)->B1_COD , (TVE9)->RECVE9 , .f. , 0 , "N" , 0 } )
		(TVE9)->(dbSkip())
	End
	(TVE9)->(dbCloseArea())
	// Levantar os Novos dos Novos //
	lWhile := .t.
	While lWhile
		lWhile  := .f.
		nLenTot := len(aRetorno)
		For ni := 1 to nLenTot
			If !aRetorno[ni,6]
				If aScan( aRetorno ,{ |x| x[1] + x[2] == aRetorno[ni,1] + aRetorno[ni,2] } ) <= 0
					aRetorno[ni,6] := .t.
					cSQL := "SELECT VE9.VE9_GRUNOV , VE9.VE9_ITENOV , SB1.B1_DESC , SB1.B1_COD , VE9.R_E_C_N_O_ RECVE9 FROM " + cNamVE9 + " VE9 "
					cSQL += "JOIN "+cNamSB1+" SB1 ON ( SB1.B1_FILIAL='"+cFilSB1+"' AND SB1.B1_GRUPO=VE9.VE9_GRUNOV AND SB1.B1_CODITE=VE9.VE9_ITENOV AND SB1.D_E_L_E_T_=' ' ) "
					cSQL += "WHERE VE9.VE9_FILIAL='"+cFilVE9+"' AND VE9.VE9_GRUITE='"+aRetorno[ni,1]+"' AND VE9.VE9_ITEANT='"+aRetorno[ni,2]+"' AND VE9.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), TVE9 , .F., .T. )
					While !(TVE9)->(Eof())
						AADD( aRetorno , { (TVE9)->VE9_GRUNOV, (TVE9)->VE9_ITENOV , (TVE9)->B1_DESC , (TVE9)->B1_COD , (TVE9)->RECVE9 , .f. , 0 , "N" , 0 } )
						lWhile := .t.
						(TVE9)->(dbSkip())
					End
					(TVE9)->(dbCloseArea())
				EndIf
			EndIf
		Next
	End
	//
	For ni := 1 to len(aRetorno)
		SB1->(dbSetOrder(7))
		SB1->(dbSeek( cFilSB1 + aRetorno[ni,1]+aRetorno[ni,2] ))
		SB1->(dbSetOrder(1))
		SB2->(dbSetOrder(1))
		SB2->(dbSeek( cFilSB2 + SB1->B1_COD + SB1->B1_LOCPAD ))
		aRetorno[ni,7] := SaldoSB2()
		aRetorno[ni,9]  := FG_VALPEC("",GetNewPar("MV_FMLPECA",""),SB1->B1_GRUPO,SB1->B1_CODITE,,.f.,.t.)
	Next
	aSort(aRetorno,1,,{|x,y| x[5] > y[5] }) // Ordenar --> RECNO VE9
	//
	DbSelectArea("SB1")
	sRestArea(aAuxArea)
	//
Return aRetorno

Method GetUltVenda() Class DMS_Peca
	Local cSQL
	cSQL := "SELECT MAX(SD2.D2_EMISSAO) "
	cSQL +=  " FROM " + RetSQLName("SD2") + " SD2 JOIN " + RetSQLName("SF4") + " SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV = '05' AND SF4.D_E_L_E_T_ = ' '"
	cSQL += " WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
	cSQL +=   " AND SD2.D2_COD = '" + Self:cCodB1 + "'"
	cSQL +=   " AND SD2.D_E_L_E_T_ = ' '"
Return StoD(FM_SQL(cSQL))

Method GetUltCompra() Class DMS_Peca
	Local cSQL
	cSQL := "SELECT MAX(SD1.D1_DTDIGIT) "
	cSQL +=  " FROM " + RetSQLName("SD1") + " SD1 JOIN " + RetSQLName("SF4") + " SF4 ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.F4_OPEMOV = '01' AND SF4.D_E_L_E_T_ = ' '"
	cSQL += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "'"
	cSQL +=   " AND SD1.D1_COD = '" + Self:cCodB1 + "'"
	cSQL +=   " AND SD1.D_E_L_E_T_ = ' '"
Return StoD(FM_SQL(cSQL))

Method PedCompraPendente(oFiltro) Class DMS_Peca
	Local cSQL
	Local dDtIni
	Local dDtFin
	Local cTpPedN
	Local lC7_TIPPED := SC7->(FieldPos("C7_TIPPED")) > 0
	Default oFiltro := DMS_DataContainer():New({})
	dDtIni  := oFiltro:GetValue('DATA_INICIAL',ctod("")) // Data Inicial
	dDtFin  := oFiltro:GetValue('DATA_FINAL',dDataBase)   // Data Final
	cTpPedN := Alltrim(oFiltro:GetValue('TIPO_PEDIDO_DESCONSIDERAR',"")) // Tp.Pedido Desconsiderar
	cSQL := "SELECT SUM(C7.C7_QUANT - C7.C7_QUJE) QTD"
	cSQL += "  FROM " + RetSQLName("SC7") + " C7 "
	cSQL += " WHERE C7.C7_FILIAL = '" + xFilial("SC7") + "'"
	cSQL += "   AND C7.C7_PRODUTO = '" + Self:cCodB1 + "'"
	If !Empty(dDtIni)
		cSQL += "   AND C7.C7_EMISSAO BETWEEN '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFin) + "'"
	EndIf
	If !Empty(cTpPedN) .And. lC7_TIPPED
		If len(cTpPedN) > 1 .and. right(cTpPedN,1) == "/"
			cTpPedN := left(cTpPedN,len(cTpPedN)-1)
		EndIf
	 	cSQL += " AND C7.C7_TIPPED NOT IN " + FormatIN(cTpPedN,"/")
	EndIf
	cSQL += "   AND C7.C7_RESIDUO <> 'S'"
	cSQL += "   AND C7.C7_QUANT > C7.C7_QUJE"
	cSQL += "   AND D_E_L_E_T_=' '"
Return FM_SQL(cSQL)

Method GetDemanda(lAllFil,cAno,cMes, nQtdAnos) Class DMS_Peca
	Local cSQL
	Local nCont, nContaRet, nPosaRet, nContaAno
	Local aRetorno := {}
	Local cFilSD1  := ""
	Local cBkpCFilAnt := cFilAnt
	Local TSB2 := "TALIASB2"
	Local TSD1 := "TALIASD1"
	Local oFilHelp := Mil_FilialHelper():New()
	Local oSqlHelp := DMS_SqlHelper():New()
	Local lNewGrpDPM := (SBM->(FieldPos('BM_VAIDPM')) > 0)
	Local oDpm := DMS_DPM():New()
	local oUtil := DMS_Util():New()
	Local lVB8 := .F.
	local nMeses
	local dData
	local dDataF
	local nIdx
	aSM0 := oFilHelp:GetAllFilEmpresa(lAllFil)
	Default cMes := ""
	Default nQtdAnos := 5

	if lNewGrpDPM
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( xFilial('SB1')+self:cCodB1 ))
		SBM->(dbSetOrder(1) )
		SBM->(dbSeek( xFilial('SBM') + SB1->B1_GRUPO ))
		lVB8 := (SBM->BM_VAIDPM == '1')
	else
		if oSqlHelp:ExistTable(retsqlname('VB8')) .AND. FM_SQL(' SELECT COUNT(*) FROM ' + RetSqlName('VB8') + " WHERE VB8_FILIAL = '"+xFilial('VB8')+"' AND D_E_L_E_T_ = ' ' ") > 0
			if FM_SQL(' SELECT COUNT(*) FROM ' + RetSqlName('VB8') + " WHERE VB8_FILIAL = '"+xFilial('VB8')+"' AND  VB8_PRODUT = '" + Self:cCodB1 + "' AND (VB8_VDAB + VB8_VDAO) > 0  AND D_E_L_E_T_ = ' ' ") > 0
				lVB8 := .t.
			EndIf
		EndIf
	EndIf

	cBkpCFilAnt := cFilAnt
	aRetorno := {}
	For nCont := 1 to Len(aSM0)
		cFilAnt := aSM0[nCont]
		cFilSD1 += "'"+xFilial("SD1")+"',"
		// Inicializa o array com todos os meses do ano
		If Empty(cMes)
			if Empty(cAno)
				For nContaAno := 0 to nQtdAnos-1
					cAno := strzero(year(date())-nContaAno,4)
					For nContaRet := 1 to 12
						aadd(aRetorno,{cFilAnt,Self:cCodB1,cAno,strzero(nContaRet,2),0,0,0,0})
					Next
				Next
				cAno := ""
			Else// !Empty(cAno)
				For nContaRet := 1 to 12
					aadd(aRetorno,{cFilAnt,Self:cCodB1,cAno,strzero(nContaRet,2),0,0,0,0})
				Next
			Endif
		Endif
		if ! lVB8
			oDev  := DMS_DevPecas():New()
			aDevs := oDev:GetDevData( cFilAnt, Self:cCodB1, nQtdAnos )
			cSQL := " SELECT BL_FILIAL, BL_PRODUTO, BL_ANO, BL_MES, BL_DEMANDA, BL_VENDPER"
			cSQL += "   FROM " + RetSQLName("SBL") + " SBL "
			cSQL += "  WHERE SBL.BL_FILIAL = '" + xFilial("SBL") + "'"
			cSQL += "    AND SBL.BL_PRODUTO = '" + Self:cCodB1 + "'"
			if Empty(cAno) .AND. Empty(cMes)
				nMeses := nQtdAnos * 12
				dDataF  := date()
				dData := dDataF
				for nIdx := 1 to nMeses
					dData := oUtil:RemoveMeses(dData, 1) // remove um mes pra fazer demanda do prox
				next
				cDia := ALLTRIM(STR(DAY(dDataF)))
				cConc := oSqlHelp:Concat({'BL_ANO', 'BL_MES', "'"+cDia+"'"})
				cSQL += " AND ("+cConc+") <= '"+DTOS(dDataF)+"' "
				cSQL += " AND ("+cConc+") >= '"+DTOS(dData )+"' "
			else
				cSQL += "    AND SBL.BL_ANO = '" + cAno + "'"
				cSQL += IIf( !Empty(cMes), " AND SBL.BL_MES = '" + cMes + "'" , "")
			endif
			cSQL += "    AND SBL.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), TSB2 , .F., .T. )
			While !(TSB2)->(Eof())
				nIdxDev := aScan(aDevs, {|el| VAL(LEFT(el:GetValue('D1_DTDIGIT'), 4)) == VAL((TSB2)->BL_ANO) .AND. VAL( LEFT(RIGHT(el:GetValue('D1_DTDIGIT'), 4),2) ) == VAL((TSB2)->BL_MES) })
				if nIdxDev == 0
					nDevs := 0
				else
					nDevs := aDevs[nIdxDev]:GetValue('QTD_ITENS')
				EndIf
				nPosaRet :=aScan(aRetorno,{|x| x[1]+x[2]+x[3]+x[4] == (TSB2)->BL_FILIAL+(TSB2)->BL_PRODUTO+(TSB2)->BL_ANO+(TSB2)->BL_MES })
				If nPosaRet > 0
					aRetorno[nPosaRet,5] := (TSB2)->BL_DEMANDA
					aRetorno[nPosaRet,6] := nDevs
					aRetorno[nPosaRet,8] := (TSB2)->BL_VENDPER 
				Endif
				//AADD( aRetorno , { (TSB2)->BL_FILIAL, (TSB2)->BL_PRODUTO , (TSB2)->BL_ANO, (TSB2)->BL_MES, (TSB2)->BL_DEMANDA, nDevs, 0 /*compras*/, (TSB2)->BL_VENDPER } )
				(TSB2)->(dbSkip())
			End
			(TSB2)->(dbCloseArea())
		Else
			aDevs := oDpm:GetDevData( cFilAnt, , Self:cCodB1, nQtdAnos,, "('"+SB1->B1_GRUPO+"')" )
			cSQL := " SELECT VB8_FILIAL, VB8_ANO, VB8_MES, SUM(VB8_VDAB + VB8_VDAO + VB8_VDAI) as DEMANDA, SUM(VB8_VDPERB +VB8_VDPERO) as VDAPER "
			cSQL += "  FROM " + oSqlHelp:NoLock('VB8')
			cSQL += " WHERE VB8.VB8_PRODUT = '" + Self:cCodB1 + "' "
			cSQL += " AND VB8.VB8_FILIAL = '"+xFilial('VB8')+"' "
			if Empty(cAno) .AND. Empty(cMes)
				nMeses := nQtdAnos * 12
				dDataF  := date()
				dData   := dDataF
				for nIdx := 1 to nMeses
					dData := oUtil:RemoveMeses(dData, 1) // remove um mes pra fazer demanda do prox
				next
				cConc := oSqlHelp:Concat({'VB8_ANO', 'VB8_MES', 'VB8_DIA'})
				cSQL += " AND ("+cConc+") <= '"+DTOS(dDataF)+"' "
				cSQL += " AND ("+cConc+") >= '"+DTOS(dData )+"' "
			Else
				cSQL += " AND VB8.VB8_ANO = '" + cAno + "' "
				cSQL += IIf( !Empty(cMes), " AND VB8.VB8_MES = '" + cMes + "'" , "")
			endif
			cSQL += "   AND VB8.D_E_L_E_T_ = ' ' "
			cSQL += " GROUP BY VB8_FILIAL, VB8_ANO, VB8_MES "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), TSB2 , .F., .T. )
			While !(TSB2)->(Eof())

				nIdxDev := aScan(aDevs, {|el| VAL(LEFT(el:GetValue('D2_EMISSAO'), 4)) == VAL(cAno) .AND. VAL( LEFT(RIGHT(el:GetValue('D2_EMISSAO'), 4),2) ) == VAL((TSB2)->VB8_MES) })
				if nIdxDev == 0
					nDevs := 0
				else
					nDevs := aDevs[nIdxDev]:GetValue('QTD_ITENS')
				EndIf
				nPosaRet :=aScan(aRetorno,{|x| x[1]+x[2]+x[3]+x[4] == (TSB2)->VB8_FILIAL+Self:cCodB1+(TSB2)->VB8_ANO+(TSB2)->VB8_MES })
				If nPosaRet > 0
					aRetorno[nPosaRet,5] := (TSB2)->DEMANDA
					aRetorno[nPosaRet,6] := nDevs
					aRetorno[nPosaRet,8] := (TSB2)->VDAPER 
				Endif
//				AADD( aRetorno , { (TSB2)->VB8_FILIAL, Self:cCodB1 , (TSB2)->VB8_ANO, (TSB2)->VB8_MES, (TSB2)->DEMANDA, nDevs, 0 /*compras*/, (TSB2)->VDAPER } )
				(TSB2)->(dbSkip())
			End
			(TSB2)->(dbCloseArea())
		EndIf
	Next nCont

	If !Empty(cAno)
		If !Empty(cFilSD1)
			cFilSD1 := left(cFilSD1,len(cFilSD1)-1)
		EndIf
		cQuery := ""
		cQuery += " SELECT D1_FILIAL , "+FG_CONVSQL("SUBS")+"(D1_DTDIGIT,1,6) AS ANOMES , COALESCE( SUM(D1_QUANT), 0) AS QUANT "
		cQuery += "   FROM " + oSqlHelp:NoLock('SD1')
		cQuery += "   JOIN " + oSqlHelp:NoLock('SF4') + " ON F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = D1_TES AND SF4.D_E_L_E_T_ = ' ' " // OPEMOV 01 = compra
		cQuery += "  WHERE D1_FILIAL IN ("+cFilSD1+") "
		cQuery += "    AND D1_COD = '"+Self:cCodB1+"' "
		cQuery += "    AND D1_DTDIGIT BETWEEN '"+cAno+"0101' AND '"+cAno+"1231' "
		cQuery += "    AND F4_OPEMOV  = '01' "
		cQuery += "    AND F4_ESTOQUE = 'S'  "
		cQuery += "    AND SD1.D_E_L_E_T_ = ' ' "
		cQuery += "  GROUP BY D1_FILIAL, "+FG_CONVSQL("SUBS")+"(D1_DTDIGIT,1,6)"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), TSD1 , .F., .T. )
		While !(TSD1)->(Eof())
			nPosaRet :=aScan(aRetorno,{|x| x[1]+x[2]+x[3]+x[4] == (TSD1)->D1_FILIAL+Self:cCodB1+(TSD1)->ANOMES })
			If nPosaRet > 0
				aDados := aRetorno[nPosaRet]
				aDados[7] := (TSD1)->( QUANT ) // 7 => quantidade comprada no mês
			Endif
			(TSD1)->(dbSkip())
		EndDo
		(TSD1)->(dbCloseArea())
	Else
		//#################
		//###  Compras  ###
		//#################
		for nCont := 1 to LEN(aRetorno)
			aDados := aRetorno[nCont]
			cFilAnt := aDados[1]
			cB1Cod  := aDados[2]
			cAno    := aDados[3]
			cMes    := aDados[4]
			dDataInicial := STOD(cAno+cMes+"01")
			dDataFinal   := oUtil:UltimoDia(VAL(cAno), VAL(cMes))
			cQuery := ""
			cQuery += " SELECT COALESCE( SUM(D1_QUANT), 0) "
			cQuery += "   FROM " + oSqlHelp:NoLock('SD1')
			cQuery += "   JOIN " + oSqlHelp:NoLock('SF4') + " ON F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = D1_TES AND SF4.D_E_L_E_T_ = ' ' " // OPEMOV 01 = compra
			cQuery += "  WHERE D1_FILIAL = '"+xFilial('SD1')+"' "
			cQuery += "    AND D1_COD = '"+cB1Cod+"' "
			cQuery += "    AND D1_DTDIGIT BETWEEN '"+DTOS(dDataInicial)+"' AND '"+DTOS(dDataFinal)+"' "
			cQuery += "    AND F4_OPEMOV  = '01' "
			cQuery += "    AND F4_ESTOQUE = 'S'  "
			cQuery += "    AND SD1.D_E_L_E_T_ = ' ' "
			aDados[7] := FM_SQL(cQuery) // 7 => quantidade comprada no mês
		next
	EndIf
	DbSelectArea("SD1")

	if LEN(aRetorno) = 0
		aAdd(aRetorno, {xFilial('SB1'), self:cCodB1, cAno, cMes, 0, 0, 0, 0})
	EndIf
	cFilAnt := cBkpCFilAnt
Return aRetorno

/*/{Protheus.doc} UpdateGroup
	Atualiza o grupo do produto e propaga a atualização por todos os modulos de concessionária

	@author Vinicius Gati
	@since 21/05/2014
	@param aEmpresas, character, Empresas para retornar filiais no formato xFilial
	@param cTabela, character, Tabela para retorno das filiais
	@return boolean, -2 = Sistema deve ser acessado em modo exclusvivo para rodar este processo, 0 = Operação concluida sem erros, -1 = Um erro ocorreu
/*/
Method UpdateGroup( cB1COD , cOldCodIte , cOldGruIte , cNewGruIte , nRecVR2 ) Class DMS_Peca
Local oAccControl     := DMS_AccessControl():New()
Local oFilHelp        := DMS_FilialHelper():New()
Local oSqlHelp        := DMS_SqlHelper():New()
Local nFilSize        := 0
Local aUpdates        := {}
Local bolConfirmation := -1
//
// Lista os campos que serão usados no update
//{ 'VB1_GRUPO'  , 'VB1_CODITE' }, ; // campos Virtuais por isso foi removido
Local aFieldsList  := { ;
	{ 'B1_GRUPO'   , 'B1_COD'     }, ;
	{ 'VF7_GRUITE' , 'VF7_CODCOM' }, ;
	{ 'VAJ_GRUPEC' , 'VAJ_CODPEC' }, ;
	{ 'VDD_GRUPO'  , 'VDD_CODITE' }, ;
	{ 'VA8_CODGRU' , 'VA8_CODITE' }, ;
	{ 'VAB_CODGRU' , 'VAB_CODPEC' }, ;
	{ 'VEA_GRUITE' , 'VEA_ITEANT' }, ;
	{ 'VEA_GRUITE' , 'VEA_ITENOV' }, ;
	{ 'VE9_GRUITE' , 'VE9_ITEANT' }, ;
	{ 'VE9_GRUITE' , 'VE9_ITENOV' }, ;
	{ 'B4_GRUPO'   , 'B4_COD'     }, ;
	{ 'BI_GRUPO'   , 'BI_COD'     }, ;
	{ 'C9_GRUPO'   , 'C9_PRODUTO' }, ;
	{ 'CW_GRUPO'   , 'CW_PRODUTO' }, ;
	{ 'D1_GRUPO'   , 'D1_COD'     }, ;
	{ 'D2_GRUPO'   , 'D2_COD'     }, ;
	{ 'D3_GRUPO'   , 'D3_COD'     }, ;
	{ 'LN_GRUPO'   , 'LN_COD'     }, ;
	{ 'VAN' }, { 'VAW' }, { 'VDR' }, { 'VE3' }, ; // Para tabelas no padrão CODITE e GRUITE é só passar o nome da tabela
	{ 'VE6' }, { 'VE8' }, { 'VEC' }, { 'VEN' }, ;
	{ 'VEO' }, { 'VES' }, { 'VF8' }, { 'VFB' }, ;
	{ 'VG5' }, { 'VG6' }, { 'VGF' }, { 'VIA' }, ;
	{ 'VIC' }, { 'VIE' }, { 'VIW' }, { 'VJI' }, ;
	{ 'VMC' }, { 'VO3' }, { 'VO8' }, { 'VOK' }, ;
	{ 'VPF' }, { 'VPG' }, { 'VPJ' }, { 'VS3' }, ;
	{ 'VS7' }, { 'VSD' }, { 'VSJ' }, { 'VSS' }, ;
	{ 'VSY' }, { 'VV6' }, { 'VVT' }, { 'VVW' }, ;
	{ 'VZ1' }, { 'VZ6' }, { 'VZ7' }, { 'VZZ' }, ;
	{ 'VEN' }}
Local nIdxField       := 1
Local nIdxQueries     := 1
// Usadas nos updates
Local cTableName      := ''
Local cFieldPrefix    := ''
Local cQuery          := ''
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local nTpExec  := GetNewPar("MV_MIL0077",1)            //            Tipo de Execucao na alteracao do GRUPO do Produto               //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Tipo de Execucao:                                                                                                                 //
//   1 - Executa agora em modo Exclusivo (default)                                                                                   //
//   2 - Executa depois via SCHEDULE                                                                                                 //
//   3 - Executa agora e refaz depois via SCHEDULE (opcao nao deve ser utilizada pq pode ocorrer inconsistencia nos relacionamentos) //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
If ExistBlock("PEALTGR1") // Temporario PEALTGR1
	lAux := ExecBlock("PEALTGR1",.f.,.f.) // checagem de ponto de entrada onde o cliente pode invalidar a validacao de exclusividade ao alterar grupo caso deseje
	If lAux
		nTpExec := 3 // Agora e refazer depois via SCHEDULE
	EndIf
EndIf
//
Default nRecVR2       := 0

if FieldPos("VE9_GRUNOV") > 0
	aAdd(aFieldsList, { 'VE9_GRUNOV' , 'VE9_ITENOV' } )
endif

// Faz o update Geral nos campos
For nIdxField := 1 To Len(aFieldsList)
	aEl := aFieldsList[nIdxField]
	If Len(aEl) == 2 // Se o nro de campos for 2 faz o update com os campos passados
		aFields      := aEl
		cTableName   := LEFT(aFields[1], 3) // Nome da tabela do campo 3 primeiro caracteres
		cFieldPrefix := cTableName
		If '_' $ cTableName
			cFieldPrefix := LEFT(cTableName, 2)
			cTableName   := 'S' + LEFT(cTableName, 2)
		EndIf
	Else // Caso contrario faz update com nome padrao CODITE E GRUITE
		cTableName := aEl[1] // So tem o nome da tabela
		aFields    := { cTableName + "_GRUITE", cTableName + "_CODITE" }
		cFieldPrefix := cTableName
	EndIf
	// correcao se a tabela nao existe no sx2
	dbSelectArea('SX2')
	dbSetOrder(1)
	If ! SX2->(dbSeek(cTableName))
		LOOP
	Else
		DbSelectArea(cTableName) // Cria tabela se não existir ainda
		dbCloseArea()
	EndIf
	// Neste campo da filial 2 digitos no campo filial sera usada entao foi usado nome da tabela 'VEC'_FILIAL
	cQuery := " UPDATE " + RetSqlName(cTableName) +                 ;
						"    SET " + aFields[1] + " = '" + cNewGruIte + "'" + ; // Seta o grupo novo
						"  WHERE " + aFields[1] + " = '" + cOldGruIte + "'" + ; // Quando o item e o grupo for = antigo
						"    AND " + aFields[2] + " = '" + IIF( LEN(cFieldPrefix) == 2, cB1COD, cOldCodIte ) + "'"
	If oFilHelp:CompareAccess( xFilial('SB1'), xFilial(cTableName) ) == 'CORTAR' // significa que o b1 é mais livre então para o update precisamos deixar o filial da tabela igual a do b1
		nFilSize := LEN(ALLTRIM(xFilial('SB1')))
		cQuery   += " AND " + oSqlHelp:CompatFunc('SUBSTR') + "(" + cFieldPrefix + "_FILIAL, 1, " + STR(nFilSize) + ") = '" + ALLTRIM(xFilial('SB1')) + "'"
	ElseIf oFilHelp:CompareAccess( xFilial('SB1'), xFilial(cTableName) ) == 'FECHADO' // significa que o b1 é mais restritivo(fechado) e com isso precisamos corta-lo para o update
		nFilSize := LEN(ALLTRIM(xFilial(cTableName)))
		cQuery   += " AND " +cFieldPrefix+ "_FILIAL = '" + LEFT(xFilial('SB1'), nFilSize) + "'"
	EndIF
	AADD( aUpdates, cQuery )
Next

BEGIN TRANSACTION
	BEGIN SEQUENCE
		For nIdxQueries := 1 To Len(aUpdates)
			If oAccControl:ExclusiveAccess() .or. nTpExec == 2 .or. nTpExec == 3 // Exclusivo ou Schedule
				cQuery  := aUpdates[nIdxQueries]
				nStatus := TCSqlExec( cQuery )
				If nStatus < 0
					Break // < zero significa um erro para função TCSqlExec
				EndIf
			Else
				DisarmTransaction()
				Return -2
			EndIf
		Next
		bolConfirmation := 0 // Executou tudo beleza!
	RECOVER
		DisarmTransaction()
		UserException( TCSQLError() ) //bolConfirmation := -1 // nem retorna, porque foi um erro de sql, só da roolback e volta, na realidade não é para acontecer.
	END SEQUENCE
	If bolConfirmation == 0 .and. nRecVR2 > 0 // Executou OK --> Alterar STATUS
		DbSelectArea("VR2")
		DbGoTo(nRecVR2)
		RecLock("VR2",.F.) // Define que será realizada uma alteração no registro posicionado
			VR2->VR2_STATUS := "1" // OK - Grupo Alterado com sucesso!
			VR2->VR2_DATALT := dDataBase
			VR2->VR2_HORALT := val(substr(time(),1,2)+substr(time(),4,2))
		MsUnLock() // Confirma e finaliza a operação
	EndIf
END TRANSACTION
Return bolConfirmation

Method GetInfComplem(cCampo) Class DMS_Peca
	Local cSQL
	cSQL := ;
		"SELECT COALESCE(BZ.BZ_" + cCampo + ", B1.B1_" + cCampo + ") INFCOM " +;
		 " FROM " + RetSQLName("SB1") + " B1" +;
		 " LEFT JOIN " + RetSQLName("SBZ") + " BZ ON BZ.BZ_FILIAL = '" + xFilial("SBZ") + "' AND BZ.BZ_COD = B1.B1_COD AND BZ.D_E_L_E_T_ = ' ' " +;
		" WHERE B1.B1_FILIAL = '" + xFilial("SB1") + "'" +;
		  " AND B1.B1_COD = '" + Self:cCodB1 + "'" +;
		  " AND B1.D_E_L_E_T_ = ' '"
Return FM_SQL(cSQL)

Method RetDiaEstqZero( dDataInicial, dDataFinal ) Class DMS_Peca

	Local nEstqAtual := 0
	Local cQuery := ""
	Local cAliasMov := "TMOVESTQ"
	Local aEstqZero := {}

	DbSelectArea("SB2")
	nEstqAtual := CalcEst( self:cCodB1 , self:cLocPadrao , dDataInicial )[1]

	cQuery := ;
		"SELECT DATA, SUM(QUANT) QUANT " +;
		 " FROM ( " +;
			"SELECT D1_DTDIGIT DATA , SUM(D1_QUANT) QUANT " +;
			 " FROM " + RetSQLName("SD1") + " D1 " +;
				" JOIN " + RetSQLName("SF4") + " F4 ON F4.F4_FILIAL = '" + xFilial("SF4") + "'	AND F4.F4_CODIGO = D1.D1_TES AND F4.D_E_L_E_T_ = ' ' AND F4.F4_ESTOQUE = 'S' " +;
			" WHERE D1.D1_FILIAL = '" + xFilial("SD1") + "'" +;
			  " AND D1.D1_DTDIGIT BETWEEN '" + DtoS(dDataInicial) + "' AND '" + Dtos(dDataFinal) + "'" +;
			  " AND D1.D1_COD = '" + self:cCodB1 + "'" +;
			  " AND D1.D1_LOCAL = '" + self:cLocPadrao + "'" +;
			  " AND D1.D1_ORIGLAN <> 'LF'" +;
			  " AND D1.D_E_L_E_T_ = ' '" +;
			" GROUP BY D1.D1_DTDIGIT " +;
			" UNION ALL " +;
			"SELECT D2_EMISSAO DATA , SUM(D2_QUANT * -1) QUANT " +;
			" FROM " + RetSQLName("SD2") + " D2 " +;
				" JOIN " + RetSQLName("SF4") + " F4 ON F4.F4_FILIAL = '" + xFilial("SF4") + "'	AND F4.F4_CODIGO = D2.D2_TES AND F4.D_E_L_E_T_ = ' ' AND F4.F4_ESTOQUE = 'S' " +;
			" WHERE D2.D2_FILIAL = '" + xFilial("SD2") + "'" +;
			  " AND D2.D2_EMISSAO BETWEEN '" + DtoS(dDataInicial) + "' AND '" + Dtos(dDataFinal) + "'" +;
			  " AND D2.D2_COD = '" + self:cCodB1 + "'" +;
			  " AND D2.D2_LOCAL = '" + self:cLocPadrao + "'" +;
			  " AND D2.D_E_L_E_T_ = ' '" +;
			" GROUP BY D2.D2_EMISSAO " +;
			" UNION ALL " +;
			"SELECT D3.D3_EMISSAO DATA , SUM(D3.D3_QUANT * -1) QUANT " +;
			 " FROM " + RetSQLName("SD3") + " D3 " +;
			" WHERE D3.D3_FILIAL = '" + xFilial("SD3") + "'" +;
			  " AND D3.D3_EMISSAO BETWEEN '" + DtoS(dDataInicial) + "' AND '" + Dtos(dDataFinal) + "'" +;
			  " AND D3.D3_COD = '" + self:cCodB1 + "'" +;
			  " AND D3.D3_LOCAL = '" + self:cLocPadrao + "'" +;
			  " AND D3.D3_TM > '500'" +;
			  " AND D3.D3_ESTORNO <> 'S'" +;
			  " AND D3.D_E_L_E_T_ = ' '" +;
			" GROUP BY D3.D3_EMISSAO " +;
			" UNION ALL " +;
			"SELECT D3.D3_EMISSAO DATA , SUM(D3.D3_QUANT) QUANT " +;
			 " FROM " + RetSQLName("SD3") + " D3 " +;
			" WHERE D3.D3_FILIAL = '" + xFilial("SD3") + "'" +;
			  " AND D3.D3_EMISSAO BETWEEN '" + DtoS(dDataInicial) + "' AND '" + Dtos(dDataFinal) + "'" +;
			  " AND D3.D3_COD = '" + self:cCodB1 + "'" +;
			  " AND D3.D3_LOCAL = '" + self:cLocPadrao + "'" +;
			  " AND D3.D3_TM <= '500'" +;
			  " AND D3.D3_ESTORNO <> 'S'" +;
			  " AND D3.D_E_L_E_T_ = ' '" +;
			" GROUP BY D3.D3_EMISSAO " +;
		" ) MOV " +;
		" GROUP BY DATA"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasMov , .F., .T. )
	While !(cAliasMov)->(Eof())
		nEstqAtual += (cAliasMov)->QUANT
		If nEstqAtual <= 0
			AADD( aEstqZero , (cAliasMov)->DATA )
		EndIf
		(cAliasMov)->(dbSkip())
	End
	(cAliasMov)->(dbCloseArea())
	dbSelectArea("SD2")
	aSort( aEstqZero )

Return aEstqZero

Method SaldoLoteMovimentacao(cLocal, nQtd, cLoteCtl, cNumLote, aLotesInf) Class DMS_Peca

	Local aSaldos
	Local nBFLOTECTL, nBFNUMLOTE, nBFLOCALIZ, nBFNUMSERI

	Default aLotesInf := {}

	/*
	[1] Lote
	[2] Sub-Lote
	[3] Endereco
	[4] Num. de Serie
	[5] Qtd 1a UM a ser considerada como indisponivel (deve ser subtraida do saldo a ser retornado)
	[6] Qtd 2a UM a ser considerada como indisponivel (deve ser subtraida do saldo a ser retornado)
	*/

	If Len(aLotesInf) > 0
		nBFLOTECTL := TamSX3("BF_LOTECTL")[1]
		nBFNUMLOTE := TamSX3("BF_NUMLOTE")[1]
		nBFLOCALIZ := TamSX3("BF_LOCALIZ")[1]
		nBFNUMSERI := TamSX3("BF_NUMSERI")[1]
		aEval(aLotesInf, { |x| ;
			x[1] := PadR(x[1],nBFLOTECTL) ,;
			x[2] := PadR(x[2],nBFNUMLOTE) ,;
			x[3] := PadR(x[3],nBFLOCALIZ) ,;
			x[4] := PadR(x[4],nBFNUMSERI) ,;
			AADD( x , ConvUM(Self:cCodB1, x[5] , 0 , 2 ) ) })
	EndIf

	aSaldos := SldPorLote(;
		Self:cCodB1 ,; // cCodPro      -> ExpC1: Codigo do Produto         - Obrigatorio
		cLocal,;	// cLocal       -> ExpC2: Local                     - Obrigatorio
		nQtd,;		// nQtd         -> ExpN1: Quantidade                - Obrigatorio
		,; 			// nQtd2UM      -> ExpN2: Quantidade 2aUM           - Obrigatorio
		cLoteCtl,;	// cLoteCtl     -> ExpC3: Lote de Controle          - Obrig. se Inf. Sub-Lote
		cNumLote,;	// cNumLote     -> ExpC4: Sub-Lote
		,; // cLocaliza    -> ExpC5: Localizacao
		,; // cNumSer      -> ExpC6: Numero de Serie
		,; // aTravas      -> ExpA1: Array para o travamento dos saldos, caso nao seja informado nao havera travamento.
		.f.,; // lBaixaEmp    -> ExpL1: Flag que indica se esta baixando material empenhado ou nao
		,; // cLocalAte    -> ExpC7: Local Ate (utilizado para selecao de almoxarifados)
		,; // lConsVenc    -> ExpL2: Flag que indica se considera lotes vencidos
		aLotesInf,; // aLotesFil    -> ExpA1: Array com lotes a serem desconsiderados [1] Lote [2] Sub-Lote [3] Endereco [4] Num. de Serie [5] Qtd 1a UM a ser considerada como indisponivel (deve ser subtraida do saldo a ser retornado) [6] Qtd 2a UM a ser considerada como indisponivel (deve ser subtraida do saldo a ser retornado)
		,; // lEmpPrevisto -> ExpL3: Flag que indica se considera empenhos previstos
		dDataBase,; // dDataRef     -> ExpD1: Data de referencia para verificar o saldo
		,; // lInfoWms     -> ExpL4: .T. = Quando integrado ao WMS considera os saldos reservados para execucao da radio frequencia
		,; // cOP
		,; // lSaldo       -> ExpL5: .T. = Quando utilizado retorna o saldo fisico sem descontar o saldo empenhado/reservado
		,; // nPercPrM
		)
//	aSaldos := SldPorLote(
//		SB1->B1_COD,
//		VS3->VS3_LOCAL,
//		VS3->VS3_QTDITE,
//		NIL,
//		SD1->D1_LOTECTL,
//		SD1->D1_NUMLOTE,
//		NIL,
//		NIL,
//		NIL,
//		NIL,
//		NIL,
//		lUsaVenc,
//		nil,
//		nil,
//		dDataBase)

Return aSaldos

Method LoteDtValid(cLoteCtl) Class DMS_Peca
	Local cQuery
	If Empty(cLoteCtl)
		Return CtoD(" ")
	EndIf

	cQuery := ;
		"SELECT B8_DTVALID " +;
		 " FROM " + RetSQLName("SB8") + " SB8 " +;
		" WHERE SB8.B8_FILIAL = '" + xFilial("SB8") + "' " +;
		  " AND SB8.B8_PRODUTO = '" + Self:cCodB1 + "' " +;
		  " AND SB8.B8_LOTECTL = '" + cLoteCtl + "' " +;
		  " AND SB8.D_E_L_E_T_ = ' '"
Return StoD( FM_SQL(cQuery) )

Method ValorVenda(cFormula, cForPag, cCodTec) Class DMS_Peca
	SBM->(dbSetOrder(1))
	SBM->(dbSeek(xFilial('SBM') + self:GetGrupo()))
	if Empty(cFormula)
		if !Empty(cForPag)
			dbSelectArea("VAI")
			DBSetOrder(6)
			dbSeek(xFilial("VAI")+M->VS1_CODVEN)

			dbSelectArea("SE4")
			dbSetOrder(1)
			dbSeek(xFilial("SE4")+M->cForPag)

			if VAI->VAI_TIPVEN $ "1" // Varejo
				if !Empty(SE4->E4_FORMVR)
					cFormu2 := '"'+SE4->E4_FORMVR+'"'
				Endif
			Elseif VAI->VAI_TIPVEN == "2" // Atacado
				if !Empty(SE4->E4_FORMAT)
					cFormu2 := '"'+SE4->E4_FORMAT+'"'
				Endif
			Elseif VAI->VAI_TIPVEN == "3" // Todos
				if M->VS1_TIPVEN == "1"
					if !Empty(SE4->E4_FORMVR)
						cFormu2 := '"'+SE4->E4_FORMVR+'"'
					Endif
				Elseif M->VS1_TIPVEN == "2"
					if !Empty(SE4->E4_FORMAT)
						cFormu2 := '"'+SE4->E4_FORMAT+'"'
					Endif
				Endif
			Endif
		Endif
	else
		cFormu2 := cFormula
	endif

	if Empty(cFormu2)
		if !Empty(SBM->BM_FORMUL)
			return FG_FORMULA(SBM->BM_FORMUL)
		else
			return FG_FORMULA( &(GETMV("MV_FMLPECA")) )
		endif
	Endif
Return FG_FORMULA(cFormu2)

Method ValorCusto() Class DMS_Peca
	Local cQuery := ""
	SB1->(dbSelectArea('SB1'))
	SB1->(dbSetOrder(1))
	SB1->(msSeek( xFilial('SB1') + Self:cCodB1 ))
	cQuery += '  SELECT B2_CM1 FROM ' + retsqlname('SB2')
	cQuery += "   WHERE B2_FILIAL = '"+xFilial(SB2)+"' "
	cQuery += "     AND B2_COD = '"+self:GetCodigo()+"' "
	cQuery += "     AND B2_LOCAL = '"+SB1->B1_LOCPAD+"' "
	cQuery += "     AND D_E_L_E_T_ = ' ' "
Return FM_SQL(cQuery)

/*/{Protheus.doc} CriaPeca
	Cria Peca SB1

	@author Andre Luis Almeida / Vinicius Gati
	@since 19/06/2017
/*/
Method CriaPeca(cCodSB1,nOpcSB1,aData,cPE) Class DMS_Peca
	Local lAntInc   := Inclui
	Local lAntAlt   := Altera
	Local lRet      := .t.
	Local aAux      := {}
	Private aIncSB1 := {}
	Default cCodSB1 := ""
	Default nOpcSB1 := 3
	Default aData   := {}
	Default cPE     := ""
	//
	If nOpcSB1 == 3 // Incluir
		Inclui := .t.
		Altera := .f.
		If Empty(cCodSB1)
			AADD(aIncSB1, { "B1_FILIAL" , xFilial("SB1")            , Nil })
			AADD(aIncSB1, { "B1_COD"    , GetSXENum("SB1","B1_COD") , Nil })
			ConfirmSX8()
		EndIf
	Else // nOpcSB1 <> 3 // Alterar
		If Empty(cCodSB1)
			Return .f.
		EndIf
		DbSelectArea("SB1")
		DbSetOrder(1)
		If !DbSeek(xFilial("SB1")+Padr(cCodSB1,TamSX3("B1_COD")[1])) // SB1->B1_COD
			HELP(" ",1,"REGNOIS",,"CriaPeca" + CHR(13) + CHR(10) + AllTrim(RetTitle("B1_COD")) + ": " + cCodSB1,4,1)
			Return .f.
		EndIf
		Inclui := .f.
		Altera := .t.
		AADD(aAux, { "B1_FILIAL" , xFilial("SB1") , Nil })
		AADD(aAux, { "B1_COD"    , cCodSB1        , Nil })
		aEVAL(aIncSB1, { |x| AADD(aAux, { x[1] , x[2] , Nil }) })
		aIncSB1 := aClone(aAux)
	EndIf
	//
	aEVAL(aData, { |x| AADD(aIncSB1, { x[1] , x[2] , Nil }) })
	//
	If !Empty(cPE)
		If ExistBlock(cPE)
			aIncSB1 := ExecBlock(cPE,.f.,.f.,{aIncSB1})
		EndIf
	EndIf
	lMSHelpAuto := .t.
	lMSErroAuto := .f.
	MSExecAuto({|x,y| MATA010(x,y)},aIncSB1,nOpcSB1)
	if lMsErroAuto
		lRet := .f.
	Endif
	Inclui := lAntInc // Volta Inclui
	Altera := lAntAlt // Volta Altera
Return lRet

/*/{Protheus.doc} ExcluiPeca
	Excluir Peca SB1

	@author Andre Luis Almeida
	@since 29/06/2022
/*/
Method ExcluiPeca(cCodSB1) Class DMS_Peca
	Local lRet      := .t.
	Private aExcSB1 := {}
	Default cCodSB1 := ""
	If !Empty(cCodSB1)
		DbSelectArea("SB1")
		DbSetOrder(1)
		If DbSeek(xFilial("SB1")+Padr(cCodSB1,TamSX3("B1_COD")[1])) // SB1->B1_COD
			AADD(aExcSB1, { "B1_FILIAL" , xFilial("SB1") , Nil })
			AADD(aExcSB1, { "B1_COD"    , cCodSB1        , Nil })
			lMSHelpAuto := .t.
			lMSErroAuto := .f.
			MSExecAuto({|x,y| MATA010(x,y)},aExcSB1,5)
			lRet := !lMsErroAuto
		EndIf
	EndIf
Return lRet


/*/{Protheus.doc} CONV1UM

Conversão da quantidade da 2a de Medida para a quantidade da 1a Unidatde de Medida

@author Manoel Filho
@since  22/09/2017
@param  Quantidade da 2a Unidade de Medida

/*/
Method CONV1UM(nQtd2a) Class DMS_Peca

Local nQtd1a     := 0

Default nQtd2a   := 0

SB1->(dbSetOrder(1))

nQtd1a := ConvUm(self:cCodB1, 0, nQtd2a,1)

Return (nQtd1a)


/*/{Protheus.doc} CONV2UM

Conversão da quantidade da 1a de Medida para a quantidade da 2a Unidatde de Medida

@author Manoel Filho
@since  22/09/2017
@param  Quantidade da 1a Unidade de Medida

/*/
Method CONV2UM(nQtd1a) Class DMS_Peca

Local nQtd2a     := 0

Default nQtd1a   := 0

SB1->(dbSetOrder(1))

nQtd2a := ConvUm(self:cCodB1, nQtd1a, 0,2)

Return (nQtd2a)



/*/{Protheus.doc} DMS_PMV
	Classe utilizada no calculo de prazo médio de venda de notas fiscais, inclusive pode ser usada para calcular
	o prazo médio ponderado, em caso de várias notas.

	@author Vinicius Gati
	@since 07/08/2014
/*/
Class DMS_Pmv
	Data aEntradas
	Data aSaidas

	Method New() CONSTRUCTOR
	Method Calcular()
	Method NfDadosEnt()
	Method NfDadosSai()
	Method Ponderar()
	Method GetDataToPond()
EndClass

/*/{Protheus.doc} New
	Salva os dados das notas(saídas/entradas) que serão avaliadas

	@author Vinicius Gati
	@since  07/08/2014
/*/
Method New(aEntradas, aSaidas) Class DMS_PMV
	Self:aEntradas  := aEntradas
	Self:aSaidas    := aSaidas
Return Self

/*/{Protheus.doc} Calcular
	Calcula o PMV das notas

	Dados necessários das notas de entradas e saidas

			Saidas:
				'Quebra'
				'D2_LOJA'         Obrigatórios
				'D2_CLIENTE'      Obrigatórios
				'D2_DOC'          Obrigatórios
				'D2_SERIE'        Obrigatórios
				'E1_FILIAL'       Obrigatórios
				'F2_PREFORI'      Obrigatórios

			Entradas:
				'Quebra'
				'D1_LOJA'         Obrigatórios
				'D1_FORNECE'      Obrigatórios
				'D1_DOC'          Obrigatórios
				'D1_SERIE'        Obrigatórios
				'E2_FILIAL'       Obrigatórios
				'D1_PREFORI'      Obrigatórios

	@author Vinicius Gati
	@since  07/08/2014
/*/
Method Calcular(oFiltro)  Class DMS_PMV
	Local aDtToPond := {}
	aDtToPond := Self:GetDataToPond(oFiltro, .T.) // Primeiro array igualo
	AEVAL(Self:GetDataToPond(oFiltro, .F.), {|el| AADD(aDtToPond, el) }) // segundo eu faço merge dos registros para ponderar
Return Self:Ponderar(aDtToPond)

/*/{Protheus.doc} GetDataToPond
	Retorna array com dados do PMV de cada nota para futuro ponderamento

	@author Vinicius Gati
	@since  07/08/2014
/*/
Method GetDataToPond(oFiltro, lEntrada) Class DMS_PMV
	Local nIdx    := 1
	Local nIdx2   := 1
	Local aWork   := {}
	Local nTotal  := 0.0
	Local nTotInd := 0.0 // total do indice para PMV
	Local aNfs    := IIF(lEntrada, Self:aEntradas, Self:aSaidas)
	Local aRet    := {}

	If Len(aNfs) > 0 .AND. !Empty( oFiltro:GetValue('Quebra') )
		For nIdx := 1 to Len(aNfs)
			If aNfs[nIdx]:GetValue('F2_PREFORI') == oFiltro:GetValue('F2_PREFORI') .OR. oFiltro:GetValue('F2_PREFORI') == 'Todos' // Balcao, Oficina ou todos
				If aNfs[nIdx]:GetValue('Quebra') == oFiltro:GetValue('Quebra') .OR. oFiltro:GetValue('Quebra') == 'Todos'

					// Quebra em branco significa que o grid esta vazio na tela
					aWork := IIF(lEntrada, Self:NfDadosEnt(aNfs[nIdx]), Self:NfDadosSai(aNfs[nIdx]))

					// a estrutura retornada é de um array contendo arrays com dados de cada parcela de cada nota
					// neste momento não importa a nota mais, só as parcelas de cada nota para calculo do PMV e futuramente o PMV ponderado
					nTotal  := 0.0
					nTotInd := 0.0
					For nIdx2 := 1 to Len(aWork)
						nTotal  += aWork[nIdx2]:GetValue('VALOR')
						nTotInd += aWork[nIdx2]:GetValue('DateDiff') * aWork[nIdx2]:GetValue('VALOR')
					Next
					AADD( aRet, { nTotal, (nTotInd/nTotal) } ) // Valor total da nota + PMV, dados utilizados no PMV ponderado
				EndIf
			EndIf
		Next
	EndIf
Return aRet

/*/{Protheus.doc} NfDadosEnt
	Retorna array com dados do PMV de cada nota para futuro ponderamento

	@author Vinicius Gati
	@since  07/08/2014
/*/
Method NfDadosSai(oNfData, oFiltro)  Class DMS_PMV
	Local cQEnt := ""
	Local cAl   := 'Saidas'
	Local aRet  := {}

	cQEnt += "      SELECT SE1.E1_VALOR, SE1.E1_VENCTO, SE1.E1_EMISSAO                                                              "
	cQEnt += "        FROM " + RetSqlName('SD2') + " SD2                                                                            "
	cQEnt += "   LEFT JOIN " + RetSqlName('SE1') + " SE1 ON SE1.E1_LOJA   = SD2.D2_LOJA   AND  SE1.E1_CLIENTE = SD2.D2_CLIENTE  AND "
	cQEnt += "                                              SE1.E1_NUM    = SD2.D2_DOC    AND  SE1.E1_PREFIXO = SD2.D2_SERIE    AND "
	cQEnt += "                                              SE1.D_E_L_E_T_ = ' '                                                    "
	cQEnt += "       WHERE SD2.D_E_L_E_T_ = ' '                                      "
	cQEnt += "         AND SE1.E1_FILIAL  = '" + oNfData:GetValue('E1_FILIAL')  + "' "
	cQEnt += "         AND SE1.E1_LOJA    = '" + oNfData:GetValue('D2_LOJA')    + "' "
	cQEnt += "         AND SE1.E1_CLIENTE = '" + oNfData:GetValue('D2_CLIENTE') + "' "
	cQEnt += "         AND SE1.E1_NUM     = '" + oNfData:GetValue('D2_DOC')     + "' "
	cQEnt += "         AND SE1.E1_PREFIXO = '" + oNfData:GetValue('D2_SERIE')   + "' "

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQEnt), cAl, .F., .T. )
	(cAl)->(DbGoTop())     // Posiciona o cursor no início da área de trabalho ativa
	While !(cAl)->(EOF())  // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
		AADD(aRet, DMS_DataContainer():New({ ;
			{'VALOR'      , (cAl)->E1_VALOR                      },;
			{'E1_VENCTO'  , (cAl)->E1_VENCTO                     },;
			{'E1_EMISSAO' , (cAl)->E1_EMISSAO                    },;
			{'DateDiff'   , STOD((cAl)->E1_VENCTO) - STOD((cAl)->E1_EMISSAO)+1 } ;
		}))

		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())
Return aRet

/*/{Protheus.doc} NfDadosSai
	Salva os dados das notas saidas que serão avaliadas

	@author Vinicius Gati
	@since  07/08/2014
/*/
Method NfDadosEnt(oNfData, oFiltro) Class DMS_PMV
	Local cQSai := ""
	Local cAl   := 'Entradas'
	Local aRet  := {}


	cQSai += "      SELECT SE2.E2_VALOR, SE2.E2_VENCTO, SE2.E2_EMISSAO                                                               "
	cQSai += "        FROM " + RetSqlName('SD1') + " SD1                                                                             "
	cQSai += "   LEFT JOIN " + RetSqlName('SE2') + " SE2 ON SE2.E2_LOJA   = SD1.D1_LOJA   AND  SE2.E2_FORNECE = SD1.D1_FORNECE  AND  "
	cQSai += "                                              SE2.E2_NUM    = SD1.D1_DOC    AND  SE2.E2_PREFIXO = SD1.D1_SERIE    AND  "
	cQSai += "                                              SE2.D_E_L_E_T_ = ' '                                                     "
	cQSai += "       WHERE SD1.D_E_L_E_T_ = ' ' "
	cQSai += "         AND SE2.E2_FILIAL  = '" + oNfData:GetValue('E2_FILIAL')  + "' "
	cQSai += "         AND SE2.E2_LOJA    = '" + oNfData:GetValue('D1_LOJA')    + "' "
	cQSai += "         AND SE2.E2_FORNECE = '" + oNfData:GetValue('D1_FORNECE') + "' "
	cQSai += "         AND SE2.E2_NUM     = '" + oNfData:GetValue('D1_DOC')     + "' "
	cQSai += "         AND SE2.E2_PREFIXO = '" + oNfData:GetValue('D1_SERIE')   + "' "


	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQSai), cAl, .F., .T. )
	(cAl)->(DbGoTop())     // Posiciona o cursor no início da área de trabalho ativa
	While !(cAl)->(EOF())  // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
		AADD(aRet, DMS_DataContainer():New({ ;
			{'VALOR'      , (cAl)->E2_VALOR                      },;
			{'E2_VENCTO'  , (cAl)->E2_VENCTO                     },;
			{'E2_EMISSAO' , (cAl)->E2_EMISSAO                    },;
			{'DateDiff'   , STOD((cAl)->E2_VENCTO) - STOD((cAl)->E2_EMISSAO)+1 } ;
		}))

		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())
Return aRet

/*/{Protheus.doc} New
	Calcula o PMV ponderado de todas as notas passadas no parametro.
	o PMV ponderado é calculado da seguinte forma:

	Prazo médio ponderado entre o prazo e o valor de cada ativo considerado, a partir de determinada data (01/11/04) de dois títulos:
	valor R$100.000,00 com vencimento em 24/12/2004 - 53 dias;
	valor R$ 50.000,00 com vencimento em 25/01/2005 - 85 dias.
	Valor total = R$ 150.000,00
	O cálculo da média ponderada dos prazos é feito:

	a) multiplicando o número de dias pelo valor de cada um dos títulos
		53 x 100.000 = 5.300.000
		85 x 50.000 = 4.250.000

	b) somando os valores encontrados;
		5.300.000 + 4.250.000 = 9.550.000

	c) dividindo pelo valor total dos títulos envolvidos
		9.550.000 / 150.000

	d) chegando ao resultado que corresponde ao prazo médio de 63,67 dias

	!!!Sempre pondera os dados, já que caso queira o PMV de 1 só nota basta passar só os dados de 1 nota, o resultado será o mesmo.

	@author Vinicius Gati
	@since  07/08/2014
/*/
Method Ponderar(aDados) Class DMS_PMV
	Local nSumTot := 0
	Local nSumInd := 0.0
	Local nIdx    := 0

	For nIdx := 1 to LEN(aDados)
		// 1 = Valor total, 2 = PMV
		nSumTot += aDados[nIdx, 1]
		nSumInd += aDados[nIdx, 1] * aDados[nIdx, 2]
	Next
	If nSumTot == 0
		Return 0
	EndIf
Return nSumInd/nSumTot // PMV ponderado dos titulos


/*/{Protheus.doc} DMS_Pedido
	@author       Vinicius Gati
	@since        02/10/2015
	@description  Tudo novo relacionado a pedido sera feito aqui
/*/
Class DMS_Pedido /* usado no Backorder(lembrete para vinicius)! */
	Data cOrigem
	Data cArmDes
	Data aItens


	Method New() CONSTRUCTOR
	Method GtTpPedBO()
	Method isBo()
	Method DelBoItem()
	Method DelBoPed()
	Method DelBoItePed()
	Method Efetivar() // cria C7
EndClass

/*/{Protheus.doc} New
	Calcula o PMV ponderado de todas as notas passadas no parametro.
	o PMV ponderado é calculado da seguinte forma:

	@author Vinicius Gati
	@since  07/08/2014
/*/
Method New(cFil, cArmDes, aItens) Class DMS_Pedido
	::cOrigem := cFil
	::cArmDes := cArmDes
	::aItens  := aItens
Return SELF

/*/{Protheus.doc} GtTpPedBO
	Pega tipo do pedido usado em backorder, existe um parametro e um valor padrão

	@returns String/Boolean , se retornar boolean é porque não existe o parametro nem o valor padrão no banco
	@author Vinicius Gati
	@since  07/08/2014
/*/
Method GtTpPedBO() Class DMS_Pedido
	cCodTpBO := GetNewPar("MV_MIL0064", "BO")
	If EMPTY( cCodTpBO )
		cCodTpBO := "BO"
	EndIf
	// verifica se o tipo configurado ou padrão existe no banco
	IF FM_SQL(" SELECT COALESCE( COUNT(*), 0 ) FROM " + RetSQLName('VEJ') + " WHERE VEJ_FILIAL = '" + xFilial('VEJ') + "' AND VEJ_TIPPED = '"+cCodTpBO+"' ") > 0
		Return cCodTpBO
	EndIf
Return cCodTpBO

/*/{Protheus.doc} isBo
	.T.|.F. caso tenha/seja ou não uma sugestão de compras do tipo backorder, pode ser usado também para verificar se é de outro tipo, só passar os campos com default

	@returns String/Boolean , se retornar boolean é porque não existe o parametro nem o valor padrão no banco
	@params "VS3_CODITE" => Obrigatório
			"VS3_GRUITE" => Obrigatório
			"VS3_SEQUEN" => Obrigatório
			"VS3_NUMORC" => Obrigatório
			"VE6_INDREG" <> 4                   => padrão, porém recebera também pra filtro pois futuramente pode mudar o padrão
			"VE6_ORIREQ" <> 3                   => padrão, porém recebera também pra filtro pois futuramente pode mudar o padrão
			"VE6_FORPED" <> oPedido:GtTpPedBO() => padrão, porém recebera também pra filtro pois futuramente pode mudar o padrão
	@author Vinicius Gati
	@since  07/08/2014
/*/
Method isBo(aData) Class DMS_Pedido
	Local cQuery := ""
	Local oSqlHlp

	if FieldPos('VE6_ITEORC') <= 0
		return .F.
	EndIf

	oSqlHlp := DMS_SqlHelper():New()
	oData    := DMS_DataContainer():New( aData )
	cQuery   += " SELECT COALESCE(COUNT(*), 0) "
	cQuery   += "   FROM " + oSqlHlp:NoLock('VE6')
	cQuery   += "  WHERE VE6_FILIAL = '"+xFilial('VE6')+"' "
	cQuery   += "    AND VE6_NUMORC = '"+oData:GetValue('VS3_NUMORC')+"' "
	cQuery   += "    AND VE6_CODITE = '"+oData:GetValue('VS3_CODITE')+"' "
	cQuery   += "    AND VE6_GRUITE = '"+oData:GetValue('VS3_GRUITE')+"' "
	if ! Empty( oData:GetValue('VS3_SEQUEN', "") )
		cQuery   += "    AND VE6_ITEORC = '"+oData:GetValue('VS3_SEQUEN')+"' "
	EndIf
	cQuery   += "    AND VE6_FORPED = '"+oData:GetValue('VE6_FORPED', self:GtTpPedBO())+"' "
	cQuery   += "    AND VE6_INDREG = '"+oData:GetValue('VE6_INDREG', "4")+"' "
	cQuery   += "    AND VE6_ORIREQ = '"+oData:GetValue('VE6_ORIREQ', "3")+"' "
	cQuery   += "    AND D_E_L_E_T_ = ' ' "
Return FM_SQL(cQuery) > 0 //  se tem registros é porque é backorder ou tipo que quiser passando os padroes

/*/{Protheus.doc} DelBoItem
	Remove SDF/VE6 relacionado e deixa o item do orçamento orfão de pedido

	@returns String/Boolean , se retornar boolean é porque não existe o parametro nem o valor padrão no banco
	@params "VS3_CODITE" => Obrigatório
			"VS3_GRUITE" => Obrigatório
			"VS3_SEQUEN" => Obrigatório
			"VS3_NUMORC" => Obrigatório
			"MOTIVO"     => Obrigatório
			"VE6_INDREG" <> 4                   => padrão, porém recebera também pra filtro pois futuramente pode mudar o padrão
			"VE6_ORIREQ" <> 3                   => padrão, porém recebera também pra filtro pois futuramente pode mudar o padrão
			"VE6_FORPED" <> oPedido:GtTpPedBO() => padrão, porém recebera também pra filtro pois futuramente pode mudar o padrão
	@author Vinicius Gati
	@since  07/08/2014
/*/
Method DelBoItem(aData) Class DMS_Pedido
	Local oSqlHlp := DMS_SQLHelper():New()
	Local oData := DMS_DataContainer():New( aData )
	Local oLogger := DMS_Logger():New()
	Local nIdx := 1
	Local aDados := {}
	Local cQuery := ""
	Local cVE6_QTDATE
	Local cVE6_SUGCOM
	Local nVE6_QTDITE := 0
	Local cLogCod := ""

	BEGIN TRANSACTION
	//
	// FJ_TIPGER = '2' equivale a pedido
	//
	cQuery += "    SELECT R_E_C_N_O_ COD, VE6_ITEORC, VE6_QTDATE, VE6_SUGCOM, VE6_QTDITE, VE6_NUMORC, VE6_CODITE, VE6_GRUITE FROM " + oSqlHlp:NoLock('VE6')
	cQuery += "     WHERE VE6.VE6_FILIAL = '"+ xFilial('VE6') +"' "
	cQuery += "       AND VE6_INDREG     = '"+oData:GetValue('VE6_INDREG', "4")+"' "
	If ! EMPTY(oData:GetValue('VS3_NUMORC', ""))
		cQuery += "   AND VE6_NUMORC     = '"+oData:GetValue('VS3_NUMORC', "")+"' "
	EndIf
	If ! EMPTY(oData:GetValue('VS3_CODITE', ""))
		cQuery += "   AND VE6_CODITE     = '"+oData:GetValue('VS3_CODITE', "")+"' "
		cQuery += "   AND VE6_GRUITE     = '"+oData:GetValue('VS3_GRUITE', "")+"' "
	EndIf
	If ! EMPTY( oData:GetValue('VS3_SEQUEN', "") )
		cQuery += "   AND VE6_ITEORC     = '"+oData:GetValue('VS3_SEQUEN')+"' "
	EndIf
	if ! Empty(oData:GetValue('VE6_SUGCOM', ""))
		cQuery += "   AND VE6.VE6_SUGCOM = '"+oData:GetValue('VE6_SUGCOM')+"' "
	EndIf
	cQuery += "       AND VE6.D_E_L_E_T_ = ' ' "
	//
	aDados := oSqlHlp:GetSelect({;
		{'campos', {'COD', 'VE6_ITEORC','VE6_QTDATE', 'VE6_SUGCOM', 'VE6_QTDITE', 'VE6_NUMORC', 'VE6_GRUITE', 'VE6_CODITE'} },;
		{'query' , cQuery} ;
	})

	if LEN(aDados) == 0
		DisarmTransaction()
	Else
		for nIdx := 1 to LEN(aDados)
			oSug := aDados[nIdx]
			cVE6_QTDATE := oSug:GetValue('VE6_QTDATE')
			cVE6_SUGCOM := oSug:GetValue('VE6_SUGCOM')
			nVE6_QTDITE := oSug:GetValue('VE6_QTDITE')
			//
			VE6->(DbGoto( oSug:GetValue('COD') ))
			reclock("VE6",.F.)
			VE6->(dbDelete())
			VE6->(MsUnlock())
			//
			SB1->(dbSelectarea('SB1'))
			SB1->(dbSetOrder(7))
			SB1->(dbSeek( xFilial('SB1') + oSug:GetValue('VE6_GRUITE') + oSug:GetValue('VE6_CODITE') ))
			//
			SDF->(dbSelectArea('SDF'))
			SDF->(dbSetOrder(1)) // DF_FILIAL+DF_CODIGO+DF_PRODUTO
			If SDF->(dbSeek( xFilial('SDF') + cVE6_SUGCOM + SB1->B1_COD ))
				reclock('SDF', .F.)
				SDF->DF_QTDSUG -= nVE6_QTDITE
				If !Empty(oSug:GetValue('VE6_NUMORC', ''))
					If Empty( cLogCod )
						cLogCod := oLogger:LogToTable({;
							{'VQL_AGROUP'     , 'BO_DELETED'   },;
							{'VQL_TIPO'       , oSug:GetValue('VE6_NUMORC') },;
							{'VQL_FILORI'     , xFilial('VS1') },; // filial deve ser do vs1 pra depois procurar os orcamentos corretamente
							{'VQL_DADOS'      , '{"user": "' + __cUserId + '", "orc": "'+oSug:GetValue('VE6_NUMORC')+'", "item": "'+SB1->B1_COD+'", "seq": "'+oSug:GetValue('VE6_ITEORC')+'", "motivo": "'+oData:GetValue('MOTIVO')+'"}'} ;
						})
					EndIf
					// desreserva...
					nQtdDesRes := FM_SQL("SELECT VS3_QTDITE-VS3_QTDAGU FROM " + oSqlHlp:NoLock('VS3') + " WHERE VS3_FILIAL = '"+xFILIAL('VS3')+"' AND VS3_NUMORC = '"+oSug:GetValue('VE6_NUMORC', "")+"' AND VS3_GRUITE = '"+oSug:GetValue('VE6_GRUITE')+ "' AND VS3_CODITE = '"+oSug:GetValue('VE6_CODITE')+"' AND VS3_SEQUEN = '"+oSug:GetValue('VE6_ITEORC')+"' AND D_E_L_E_T_ = ' ' " )
					cArmRes := GetMv("MV_RESITE")
					If nQtdDesRes > 0 .AND. FM_SQL(" SELECT SUM(VS3_QTDRES) FROM " + RetSqlName('VS3') + " WHERE VS3_FILIAL = '"+xFILIAL('VS3')+"' AND VS3_NUMORC = '"+oSug:GetValue('VE6_NUMORC', "")+"' AND VS3_GRUITE = '"+oSug:GetValue('VE6_GRUITE')+ "' AND VS3_CODITE = '"+oSug:GetValue('VE6_CODITE')+"' AND VS3_SEQUEN = '"+oSug:GetValue('VE6_ITEORC')+"' AND D_E_L_E_T_ = ' ' ") >= nQtdDesRes
						FM_TRF261(SB1->B1_COD, cArmRes, SB1->B1_LOCPAD, nQtdDesRes)
						TcSqlExec("UPDATE " + RetSqlName('VS3') + " SET VS3_QTDRES -= "+alltrim(str(nQtdDesRes))+ " WHERE VS3_FILIAL = '"+xFILIAL('VS3')+"' AND VS3_NUMORC = '"+oSug:GetValue('VE6_NUMORC', "")+"' AND VS3_GRUITE = '"+oSug:GetValue('VE6_GRUITE')+ "' AND VS3_CODITE = '"+oSug:GetValue('VE6_CODITE')+"' AND VS3_SEQUEN = '"+oSug:GetValue('VE6_ITEORC')+"' AND D_E_L_E_T_ = ' ' ")
					EndiF
					TcSqlExec("UPDATE " + RetSqlName('VS3') + " SET VS3_RESERV = '0' WHERE VS3_FILIAL = '"+xFILIAL('VS3')+"' AND VS3_NUMORC = '"+oSug:GetValue('VE6_NUMORC', "")+"' AND VS3_GRUITE = '"+oSug:GetValue('VE6_GRUITE')+ "' AND VS3_CODITE = '"+oSug:GetValue('VE6_CODITE')+"' AND VS3_SEQUEN = '"+oSug:GetValue('VE6_ITEORC')+"' AND VS3_QTDRES = 0 AND D_E_L_E_T_ = ' ' ")
				EndIf
				//
				cFJCOD := SDF->DF_CODIGO
				if SDF->DF_QTDSUG <= 0
					dbDelete()
				EndIf
				TcSqlExec("UPDATE " + RetSqlName('VS3') + " SET VS3_QTDAGU = '0' WHERE VS3_FILIAL = '"+xFILIAL('VS3')+"' AND VS3_NUMORC = '"+oSug:GetValue('VE6_NUMORC', "")+"' AND VS3_GRUITE = '"+oSug:GetValue('VE6_GRUITE')+ "' AND VS3_CODITE = '"+oSug:GetValue('VE6_CODITE')+"' AND VS3_SEQUEN = '"+oSug:GetValue('VE6_ITEORC')+"' AND D_E_L_E_T_ = ' ' ")
				MsUnlock()
			EndIf
		next
		//
		If FM_SQL(" SELECT COALESCE(SUM(DF_QTDSUG),0) FROM " + RetSQLName('SDF') + "  WHERE DF_FILIAL = '"+xFilial('SDF')+"' AND DF_CODIGO = '"+cFJCOD+"'  AND D_E_L_E_T_ = ' ' ") <= 0
			dbSelectarea('SFJ')
			dbSetOrder(1)
			dbSeek(xFilial('SFJ')+cFJCOD)
			if !SFJ->(EOF())
				reclock('SFJ', .F.)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf
		//
	EndIf

	END TRANSACTION
Return .T.

/*/{Protheus.doc} DelBoPed
	Remove SDF/VE6 relacionado e deixa o item do orçamento orfão de pedido

	@returns String/Boolean , se retornar boolean é porque não existe o parametro nem o valor padrão no banco
	@params cFil, filial
	@params cNumPed, numero do pedido que será cancelado
	@author Vinicius Gati
	@since  20/11/2014
/*/
Method DelBoPed(cFil, cNumPed, cB1COD, cSequen) Class DMS_Pedido
	Local oSqlHlp := DMS_SQLHelper():New()
//	Local cAl     := GetnextAlias()
	Local cQuery  := ""
	Local nIdx    := 1
	Local cFilBck := cFilAnt
	Default cSequen := ""
	Default cB1COD  := ""
	cFilAnt := cFil
	//
	// FJ_TIPGER = '2' equivale a pedido
	//
	cQuery += "    SELECT SDF.R_E_C_N_O_ ID_SDF, VE6.R_E_C_N_O_ ID_VE6, VE6_SUGCOM, VE6_FORPED, VE6_QTDITE,VE6_NUMORC, VE6_GRUITE, VE6_CODITE, B1_COD, VE6_ITEORC ,DF_QTDSUG "
	cQuery += "      FROM "+oSqlHlp:NoLock('SFJ')+" "
	cQuery += "      JOIN "+oSqlHlp:NoLock('SDF')+" ON SDF.DF_FILIAL  = '"+xFilial('SDF')+"' AND SDF.DF_CODIGO  = FJ_CODIGO  AND SDF.D_E_L_E_T_ = ' ' "
	cQuery += "      JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL  = '"+xFilial('SB1')+"' AND SB1.B1_COD     = DF_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+oSqlHlp:NoLock('SC7')+" ON SC7.C7_FILIAL  = '"+xFilial('SC7')+"' AND SC7.C7_NUM     = FJ_SOLICIT AND SC7.C7_PRODUTO = SDF.DF_PRODUTO AND SC7.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+oSqlHlp:NoLock('VE6')+" ON VE6.VE6_FILIAL = '"+xFilial('VE6')+"' AND VE6.VE6_SUGCOM = FJ_CODIGO  AND VE6.VE6_GRUITE = SB1.B1_GRUPO   AND VE6.VE6_CODITE = SB1.B1_CODITE AND VE6.D_E_L_E_T_ = ' ' "
	cQuery += "     WHERE FJ_TIPGER = '2' AND SFJ.FJ_FILIAL =  '"+xFilial('SFJ')+"' AND SFJ.D_E_L_E_T_ = ' ' "
	If !Empty(cB1COD)
		cQuery += " AND B1_COD = '"+cB1COD+"' AND C7_ITEM = '"+ STRZERO( VAL(cSequen) ,tamsx3('C7_ITEM')[1] ) + "' "
	EndIf
	If !Empty(cNumPed)
		cQuery += " AND C7_NUM = '"+cNumPed+"' "
	EndIf
	//
	aResults := oSqlHlp:GetSelect({;
		{'campos', {'ID_SDF', 'ID_VE6', 'VE6_SUGCOM', 'VE6_FORPED', 'VE6_QTDITE', 'VE6_NUMORC', 'VE6_GRUITE', 'VE6_CODITE', 'B1_COD', 'VE6_ITEORC','DF_QTDSUG'}},;
		{'query' , cQuery } ;
	})
	// Motivo
	cMotCan := OFA210MOT('000015',,,,.F.,)[1] // 15 => MOTIVO DO CANCELAMENTO DE BACKORDER
	//
	BEGIN TRANSACTION
		for nIdx := 1 to LEN(aResults)
			oData := aResults[nIdx]
			If !Empty(oData:GetValue('VE6_NUMORC'))
				aParams := {;
					{"VS3_CODITE", oData:GetVAlue('VE6_CODITE')},;
					{"VS3_GRUITE", oData:GetValue('VE6_GRUITE')},;
					{"VS3_SEQUEN", oData:GetValue('VE6_ITEORC')},;
					{"VE6_FORPED", oData:GetValue('VE6_FORPED')},;
					{"VS3_NUMORC", oData:GetValue('VE6_NUMORC')},;
					{"VE6_SUGCOM", oData:GetValue('VE6_SUGCOM')},;
					{"MOTIVO"    , cMotCan                     } ;
				}
				self:DelBoItem(aParams)
			EndIf
		Next
	END TRANSACTION
	cFilAnt := cFilBck
Return .T.

/*/{Protheus.doc} Efetivar
	Metodo que cria o pedido conforme dados dno construtor (usado no DPM)

	@type method
	@author Vinicius Gati
	@since 23/12/2015
	@version 1.0

/*/
Method Efetivar(cFileName) class DMS_Pedido
	Local nIdx       := 1
	Local nIdxC      := 1
	Local oFilHlp    := DMS_FilialHelper():New()
	Local oLogger    := DMS_Logger():New("DPMORD.LOG")
	Local oDpm       := DMS_DPM():New()
	Local oPeca      := DMS_Peca():New()
	Local oEmail     := DMS_EmailHelper():New()
	Local cFilBck    := cFilAnt
	Local cFornedor  := GetNewPar("MV_MIL0066", "")
	Local c7iteped   := ""
	Local aItens     := {}
	Local aForn      := {}
	Local cChaveForn := ""
	Local aBloquear  := {} // peças que serão bloqueadas após geração do pedido pois estavam bloqueadas antes
	Local aDadEmail  := {{'Item', 'Quantidade'}}
	Local aDetEmail  := {{'Item', 'Detalhe'}}
	Local nInd       := 0
	Local uVal
	Local aCabCus
	Local aItCus
	Local aItem
	Local cCodMarca  := FMX_RETMAR(GetNewPar("MV_MIL0006","")) // 28 da VX5
	Local cSQLTIPPED := ""
	Local cSQLC7NUM := ""
	Local cNC7Ped := ""	
	aForn := STRTOKARR(cFornedor, ';')
	cChaveForn := aForn[1] + SPACE( (TamSx3('A2_COD' )[1])-LEN(aForn[1]) )
	cChaveForn += aForn[2] + SPACE( (TamSx3('A2_LOJA')[1])-LEN(aForn[2]) )

	If EMPTY(cFornedor)
		oLogger:Log({"TIMESTAMP", STR0002 /*"Fornecedor não configurado no parâmetro MV_MIL0066. Erro ao criar Pedido de compra."*/})
		oLogger:LogToTable({;
			{'VQL_AGROUP'     , 'JDPRISM_DPMORD' },;
			{'VQL_TIPO'       , 'DPMORD_ERROR'   },;
			{'VQL_DADOS'      , STR0002 /*"Fornecedor não configurado no parâmetro MV_MIL0066. Erro ao criar Pedido de compra."*/ } ;
		})
		return .F.
	EndIf

	cFilAnt := self:cOrigem
	Pergunte("VIA040B",.F.)
	cCond = MV_PAR01
	//
	SA2->(DbSetOrder(1))
	SA2->(DbSeek( xFilial('SA2')+cChaveForn ))
	aCab := {;
		{"C7_FILIAL"  , xFilial('SC7')                 , Nil},;
		{"C7_EMISSAO" , dDataBase                      , Nil},; // Data de Emissao
		{"C7_FORNECE" , SA2->A2_COD                    , Nil},; // Fornecedor
		{"C7_LOJA"    , SA2->A2_LOJA                   , Nil},; // Loja do Fornecedor
		{"C7_CONTATO" , "               "              , Nil},; // Contato
		{"C7_COND"    , GetNewPar("MV_MIL0086", cCond) , Nil},; //
		{"C7_FILENT"  , self:cOrigem                   , Nil} ; // Filial Entrega
	}
	//
	// Campos customizáveis entram aqui
	//
	aCabCus := IIF(ExistBlock('VCLSAP1'), ExecBlock("VCLSAP1",.f.,.f.),  {})
	for nIdxC := 1 to LEN(aCabCus)
		AADD(aCab, {aCabCus[nIdxC][1], aCabCus[nIdxC][2], Nil} ) // campos customizados e obrigatórios
	next
	//
	for nIdx := 1 to LEN(self:aItens)
		oDadosItem := self:aItens[nIdx]
		If Empty(c7iteped)
			c7iteped := repl("0",TamSx3("C7_ITEM")[1])
		EndIf
		Soma1( c7iteped , TamSx3("C7_ITEM")[1] )
		//
		SB1->(DbSetOrder(1))
		if ! SB1->(DbSeek( xFilial("SB1")+oDadosItem:GetValue('B1_COD') )) // caso não encontre, tenta criar B1 generico
			nOpcA   := 3   // Usado na integração 3 cria novo registro, 4 faria update o que não convém nesse cadastro

			aB1Data := {;
				{ "B1_FILIAL"  , xFilial("SB1")                                 , Nil },;
				{ "B1_COD"     , oDadosItem:GetValue('B1_COD')                  , Nil },;
				{ "B1_CODITE"  , oDadosItem:GetValue('B1_COD')                  , Nil },;
				{ "B1_GRUPO"   , oDpm:GetPecGroups()[1]                         , Nil },; // joga peça criada em um grupo JD mas o 1o que encontrar, esse registro vai precisar de manutenção
				{ "B1_DESC"    , oDadosItem:GetValue('B1_COD') +" GERAUTOSUG"   , Nil },;
				{ "B1_TIPO"    , "ME"                                           , Nil },;
				{ "B1_UM"      , "UN"                                           , Nil },;
				{ "B1_PRV1"    , 1.0                                            , Nil },;
				{ "B1_LOCPAD"  , "01"                                           , Nil } ;
			}

			lMsErroAuto := .F. // controle de erros usado na integracao

			//Ponto de Entrada p/ Atualizar o Cadastro de Produto
			If ExistBlock("VCLSAP3") // Usado para alterar/adicionar os dados do B1 em caso de customização do B1
				aB1Data := ExecBlock( "VCLSAP3", .F., .F., { aB1Data } )
			EndIf

			lMsErroAuto := .F.
			MSExecAuto({|x,y| mata010(x,y)},aB1Data,nOpcA)
			SB1->(DbSetOrder(1))
			if ! SB1->(DbSeek( xFilial("SB1")+oDadosItem:GetValue('B1_COD') )) .OR. lMsErroAuto
				if lMsErroAuto
					cTitulo := "[JDPRISM ORDER] Produto "+ oDadosItem:GetValue('B1_COD') + " falha de integração com backoffice"
					conout(cTitulo)
					oLogger:LogSysErr("jdprism_order_erro_peca.log", .T., cTitulo)
				else
					conout(STR0001 /*'ITEM NAO ENCONTRADO - COD: '*/ + oDadosItem:GetVAlue('B1_COD'))
					oLogger:LogToTable({;
						{'VQL_AGROUP' , 'JDPRISM_DPMORD' },;
						{'VQL_TIPO'   , 'DPMORD_ERROR'   },;
						{'VQL_DADOS'  , STR0001 /*'ITEM NAO ENCONTRADO - COD: '*/ + oDadosItem:GetVAlue('B1_COD') } ;
					})
				endif
				return .F.
			EndIf
			AADD(aDetEmail, {oDadosItem:GetValue('B1_COD'), STR0003 /*"Item criado para o pedido."*/})
		EndIf
		//
		SB5->(DbSetOrder(1))
		if ! SB5->(DbSeek( xFilial("SB5")+oDadosItem:GetValue('B1_COD') ))
				RecLock("SB5", .T.)
				SB5->B5_FILIAL := xFilial('SB5')
				SB5->B5_COD    := oDadosItem:GetValue('B1_COD')
				SB5->B5_PRV2   := 1
				//Ponto de Entrada p/ Atualizar o Cadastro de Produto (dados adicionais)
				If ExistBlock("VCLSAP4") // Usado para alterar/adicionar os dados do B5 em caso de customização do B5
					ExecBlock( "VCLSAP4", .F., .F., {} )
				EndIf
				SB5->(MsUnLock())
				AADD(aDetEmail, {oDadosItem:GetValue('B1_COD'), STR0004 /*"Item com valor de venda zero, setado valor R$ 1,00."*/})
		end

		if SB5->B5_PRV2 <= 0
			RecLock("SB5", .F.)
			SB5->B5_PRV2 := 1
			SB5->(MsUnlock())
		end

		if oPeca:Bloqueado(SB1->B1_COD,,,.F.)
			if oPeca:Desbloquear(SB1->B1_COD)
				AADD(aBloquear, SB1->B1_COD) // grava para desbloquear depois do pedido gerado
				AADD(aDetEmail, {oDadosItem:GetValue('B1_COD'), STR0005 /*"Item bloqueado adicionado ao pedido com sucesso."*/})
			end
		end

		SBZ->(DbSetOrder(1))
		SBZ->(DbSeek( xFilial("SBZ")+oDadosItem:GetValue('B1_COD') ))

		SB1->(DbSetOrder(1))
		SB1->(DbSeek( xFilial("SB1")+oDadosItem:GetValue('B1_COD') ))

		If SB1->B1_COD != oDadosItem:GetValue('B1_COD')
			cVqlOrders := oLogger:LogToTable({;
				{'VQL_AGROUP' , 'JDPRISM_DPMORD' },;
				{'VQL_TIPO'   , 'DPMORD_ERROR'   },;
				{'VQL_DADOS'  , STR0001 /*'ITEM NAO ENCONTRADO - COD: '*/ + oDadosItem:GetVAlue('B1_COD') } ;
			})
			conout(STR0001 /*'ITEM NAO ENCONTRADO - COD: '*/ + oDadosItem:GetVAlue('B1_COD'))
			loop
		EndIf

		c7iteped := Soma1( c7iteped , TamSx3("C7_ITEM")[1] )

		Pergunte("OFM430",.F.)
		cPVS3_FORMU := MV_PAR08

		conout("Fórmula configurada para preço de compra: " + cPVS3_FORMU)

		cSQLTIPPED := "SELECT VEJ_TIPPED "
		cSQLTIPPED +=  " FROM " + RetSQLName("VEJ")
		cSQLTIPPED += " WHERE VEJ_FILIAL = '" + xFilial("VEJ") + "'"
		cSQLTIPPED +=   " AND VEJ_CODMAR = '" + cCodMarca + "'"
		cSQLTIPPED +=   " AND VEJ_PEDEDI = '" + AllTrim(oDadosItem:GetValue("TIPO")) + "'"
		cSQLTIPPED +=   " AND D_E_L_E_T_ = ' '"

		aItem := {;
			{"C7_ITEM"   , c7iteped                                    , Nil},;  // Numero do Item
			{"C7_PRODUTO", SB1->B1_COD                                 , Nil},;  // Codigo do Produto
			{"C7_QUANT"  , VAL(oDadosItem:GetValue("QUANTIDADE"))      , Nil},;  // Quantidade
			{"C7_DATPRF" , dDataBase                                   , Nil},;  // Data De Entrega
			{"C7_LOCAL"  , self:cArmDes                                , Nil},;  // Localizacao
			{"C7_DDATCRI", dDataBase                                   , Nil},;
			{"C7_PEDFAB" , 'JDPRISM'                                   , Nil},;
			{"C7_PRECO"  , FG_FORMULA( cPVS3_FORMU )                   , Nil},;
			{"C7_DLINORI", oDadosItem:GetValue("C7_DLINORI")           , Nil},;
			{"C7_SLITPED", "01"                                        , Nil},;
			{"C7_TIPPED" , FM_SQL(cSQLTIPPED)                          , Nil} ;
		}
		//
		// Campos customizáveis entram aqui
		//
		aCust := IIF(ExistBlock('VCLSAP2'), ExecBlock("VCLSAP2",.f.,.f., { VAL(oDadosItem:GetValue("QUANTIDADE")), oDadosItem:GetValue("TIPO") }), {})

		for nIdxC := 1 to LEN(aCust)
			conout("Pe detectado")
			nInd := aScan(aItem, {|aCampos| aCampos[1] == aCust[nIdxC, 1]})
			If aCust[nIdxC, 1] == "FORMULA"
				uVal := FG_FORMULA( aCust[nIdxC, 2] )
				conout("Formula alterada")
			Else
				uVal := aCust[nIdxC, 2]
				conout("Valor customizado")
			EndIf

			if nInd > 0
				aItem[nInd, 2] := uVal
			else
				AADD(aItem, {aCust[nIdxC, 1], aCust[nIdxC, 2], Nil})
			endif
		next

		if SC7->(FieldPos("C7_OREFID")) > 0
			AADD(aItem, {"C7_OREFID", oDadosItem:GetValue("C7_PEDFAB"), Nil})
		End

		aadd(aItens, aItem)
		AADD(aDadEmail, {oDadosItem:GetValue('B1_COD'), oDadosItem:GetValue('QUANTIDADE')})
	Next

	for nIdx := 1 to LEN(aItens)
		for nIdxC := 1 to LEN(aItens[nIdx])
			if aItens[nIdx, nIdxC, 1] == "C7_PRECO" .AND. aItens[nIdx, nIdxC, 2] <= 0
				conout("Preço de compra zerado para item: " + aItens[nIdx][2,2] + " tentando alterar valor 1 para evitar erro.")
				aItens[nIdx, nIdxC, 2 ] := 1
			endif
		next
	next

	if Empty(__cUserId)
		__cUserId := replicate('0', tamsx3('Y1_COD')[1])
		cUserName := "Administrador"
		cCodUser  := __cUserId
		conout("Alterando usuarios pre integracao cUserName = " + cUserName + " cUserId = " + __cUserId)
	endif

	lMsErroAuto := .f.
	nModBck := nModulo
	nModulo := 2
	MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItens,3)
	nModulo := nModBck

	for nIdx := 1 to LEN(aBloquear)
		oPeca:Bloquear(aBloquear[nIdx])
	next
	if lMsErroAuto
		conout("Um erro ocorreu na integração, checar pasta logsmil")
	Else

		for nIdx := 1 to LEN(self:aItens)

			cSQLC7NUM := "SELECT C7_NUM "
			cSQLC7NUM += " FROM " + RetSQLName("SC7") 
			cSQLC7NUM += " WHERE C7_FILIAL = '" + xFilial("SC7") + "'"
			cSQLC7NUM +=   " AND C7_TIPPED  = '" + FM_SQL(cSQLTIPPED) + "'"
			cSQLC7NUM +=   " AND C7_PRODUTO = '" + self:aItens[nIdx]:ODATA:ADATA[9][2] + "'"
			cSQLC7NUM +=   " AND C7_PEDFAB = 'JDPRISM' "
			cSQLC7NUM +=   " AND C7_DLINORI = '" + self:aItens[nIdx]:ODATA:ADATA[8][2] + "'" 
			cSQLC7NUM +=   " AND D_E_L_E_T_ = ' '"
			
			self:aItens[nIdx]:SetValue("NUMERO_PEDIDO", FM_SQL(cSQLC7NUM))
			cNC7Ped := self:aItens[nIdx]:GetValue("NUMERO_PEDIDO" )
		next

		cTitulo := "[JDPRISM ORDER]" + STR0006/*" Pedido de compra "*/+cNC7Ped + STR0007/*" importado via JDPRISM na filial: "*/ + cFilAnt
		AADD(aDetEmail, {"Nome arquivo", cFileName})
		oEmail:SendTemplate({;
			{'template'          , "jd_order"                   },;
			{'assunto'           , cTitulo                      },;
			{':titulo'           , cTitulo                      },;
			{':cabecalho1'       , STR0008/*'Dados:'*/          },;
			{':dados_cabecalho1' , aDadEmail                    },;
			{':cabecalho2'       , STR0009/*'Detalhes:'*/       },;
			{':dados_cabecalho2' , aDetEmail                    },;
			{'origem'            , GetNewPar("MV_MIL0088", "")  },;
			{'destino'           , GetNewPar("MV_MIL0089", "")  } ;
		})
	end
Return ! lMsErroAuto // negacao do erro

/*/{Protheus.doc} DMS_Produtivo
	Classe utilizada para manipulação de informações de produtivos de oficina

	@author Rubens Takahashi
	@since 18/11/2015
/*/
Class DMS_Produtivo FROM DMS_Tecnico

	Data aEscala AS ARRAY INIT ARRAY(0)
	Data aPeriodo AS ARRAY INIT ARRAY(0)
	Data nHorasDispo
	Data nMinDispo
	Data oSQLHelper AS Object
	Data oUtil AS Object

	Method New() CONSTRUCTOR
	Method SetProdutivo()
	Method LoadEscala()
	Method GetAusencia()
	Method GetEscala()
	Method TempoTrab()
	Method PesqEscala()

	// Metodos que não poderiam ser executados diretamente ...
	Method AddEscala()
	Method AddIniFimEscala()
	Method AddPeriodo()
	Method AddAuxPeriodo()
	Method GetSQLEscala()
	Method Escala()
	Method EscalaProdutivoDeOutraFilial()
	Method EscalaFilial()
	Method PreencheLacunas()
	//

EndClass

/*/{Protheus.doc} New
	Metodo Construtor de Classe

	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param cCodigo, character, Código do Produtivo
/*/
Method New(cCodigo)  Class DMS_Produtivo
	Default cCodigo := ""
	_Super:New(cCodigo)
Return Self

/*/{Protheus.doc} SetProdutivo
	Define o produtivo a ser considerado no objeto

	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param cCodigo, character, Código do Produtivo
/*/
Method SetProdutivo(cCodigo) Class DMS_Produtivo
	_Super:SetTecnico(cCodigo)
Return

/*/{Protheus.doc} LoadEscala
	Metodo utilizado para buscar a escala do produtivo em um determinado periodo

	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param pdDataIni, data, Data Inicial a ser considerada
	@param pdDataFim, data, Data Final a ser considerada
/*/
Method LoadEscala(pdDataIni,pdDataFim) Class DMS_Produtivo

	Local aArea := GetArea()
	Local lProdFilial := (Self:GetConfig("VAI_FILPRO") == cFilAnt)

	Local lVOEFILPRO := (VOE->(FieldPos("VOE_FILPRO")) > 0)

	If Self:aEscala == NIL
		Self:aEscala := {}
	EndIf
	If Self:aPeriodo == NIL
		Self:aPeriodo := {}
	EndIf

	// Se o produtivo trabalha em outra filial e o sistema possui o campo para controlar a filial
	// em que o produto esta alocado, devemos verificar a ultima escala anterior a data de inicio da analise
	// para verificar se o produtivo foi alocado para a filial que esta sendo processada
	If lProdFilial == .f.
		If lVOEFILPRO
			//Self:AddIniVOEFILPRO(DtoS(pdDataIni))
			Self:EscalaProdutivoDeOutraFilial(pdDataIni,pdDataFim)
		EndIf
	Else
		Self:EscalaFilial(pdDataIni,pdDataFim)
	EndIf

//	Conout(" ")
//	Conout("---------------------------------------------------------------------------------------")
//	Conout("____ ____ ____ ____ _    ____    ___  ____    ___  ____ ____ ___  _  _ ___ _ _  _ ____ ")
//	Conout("|___ [__  |    |__| |    |__|    |  \ |  |    |__] |__/ |  | |  \ |  |  |  | |  | |  | ")
//	Conout("|___ ___] |___ |  | |___ |  |    |__/ |__|    |    |  \ |__| |__/ |__|  |  |  \/  |__| ")
//	Conout("                                                                                       ")
//	Conout(" ")
//	Conout("Produtivo: " + Self:GetCodigo())
//	Conout(" ")
//	aEval(Self:aEscala,{ |x| Conout( x[1] + " - " + X[2]) })
//	Conout("---------------------------------------------------------------------------------------")

	Self:nHorasDispo := 0
	Self:nMinDispo := 0
	aEval( Self:aEscala ,{ |x| Self:nHorasDispo += x[4] })

	Self:GetAusencia(pdDataIni,pdDataFim)

	RestArea( aArea )
Return


/*/{Protheus.doc} EscalaFilial
Carrega escala do produtivo quando ele trabalha na filial que esta sendo processada 
@author Rubens
@since 06/06/2018
@version 1.0
@param pdDataIni, data , Data inicial de processamento
@param pdDataFim, data , Data final de processamento
@type function
/*/
Method EscalaFilial( pdDataIni, pdDataFim) Class DMS_Produtivo

	Local cAliasEsc := "TESCALA"
	Local cEscalaAtual
	Local lTrabFil := .f.
	Local lPossuiEscala := .f.

	Local lVOEFILPRO := (VOE->(FieldPos("VOE_FILPRO")) > 0)
	Local cVOEDATESC

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, self:GetSQLEscala( pdDataIni, pdDataFim ) ), cAliasEsc , .F., .T. )
	While !(cAliasEsc)->(Eof())
		If !lVOEFILPRO .or. ( lVOEFILPRO .and. ((cAliasEsc)->VOE_FILPRO == cFilAnt .or. Empty((cAliasEsc)->VOE_FILPRO)) )

			Self:AddEscala((cAliasEsc)->VOE_CODPER, (cAliasEsc)->VOE_DATESC)

			If lPossuiEscala .and. lTrabFil
				Self:PreencheLacunas( StoD(cVOEDATESCO) + 1, )
			EndIf
			lPossuiEscala := .t.
			lTrabFil := .t.
		Else

			If lTrabFil
				Self:PreencheLacunas( , StoD((cAliasEsc)->VOE_DATESC) )
			EndIf
			lTrabFil := .f.
		EndIf

		cVOEDATESC := (cAliasEsc)->VOE_DATESC
		(cAliasEsc)->(dbSkip())
	End
	(cAliasEsc)->(dbCloseArea())

Return

/*/{Protheus.doc} EscalaProdutivoDeOutraFilial
Carrega escala do produtivo quando ele nao trabalha na filial que esta sendo processada
@author Rubens
@since 06/06/2018
@version 1.0
@param pdDataIni, data , Data inicial de processamento
@param pdDataFim, data , Data final de processamento
@type function
/*/
Method EscalaProdutivoDeOutraFilial(pdDataIni,pdDataFim) Class DMS_Produtivo

	Local cAliasEsc := "TESCALA"
	Local cEscalaAtual
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, self:GetSQLEscala(pdDataIni, pdDataFim) ), cAliasEsc , .F., .T. )
	lTrabFil := .f.
	While !(cAliasEsc)->(Eof())
		If (cAliasEsc)->VOE_FILPRO == cFilAnt
			lTrabFil := .t.
			cEscalaAtual := (cAliasEsc)->VOE_CODPER
			Self:AddEscala((cAliasEsc)->VOE_CODPER,(cAliasEsc)->VOE_DATESC)
		Else
			If lTrabFil
				dDataAdd := StoD((cAliasEsc)->VOE_DATESC) - 1
				Self:AddEscala( cEscalaAtual , DtoS( dDataAdd ) )
				lTrabFil := .f.
				Self:PreencheLacunas()
			EndIf
		EndIf

		(cAliasEsc)->(dbSkip())
	End
	(cAliasEsc)->(dbCloseArea())

Return

/*/{Protheus.doc} GetSQLEscala
Gera a query que sera utilizada para carregar as escala do produtivo 
@author Rubens
@since 06/06/2018
@version 1.0
@return cSQL , Query para carregar registros de Escala para processamento
@param pdDataIni, data , Data inicial de processamento
@param pdDataFim, data , Data final de processamento
@type function
/*/
Method GetSQLEscala(pdDataIni, pdDataFim) Class DMS_Produtivo

	Local cSQL := ""
	Local lVOEFILPRO := (VOE->(FieldPos("VOE_FILPRO")) > 0)
	
	// Cria o registro inicial da escala, se nao possuir um VOE igual a data inicial de processalmento, sera retornado o ultimo periodo cadastrado
	cSQL += ;
	" SELECT '" + DtoS(pdDataIni) + "' VOE_DATESC , VOE.VOE_CODPER" +;
		IIf( lVOEFILPRO , ", VOE.VOE_FILPRO " , "" ) + ;
	  " FROM " + RetSQLName("VOE") + " VOE JOIN ( " +;
				" SELECT VOE.VOE_CODPRO, MAX(VOE.VOE_DATESC) ESCALA " +;
				  " FROM " + RetSQLName("VOE") + " VOE " +;
				 " WHERE VOE.VOE_FILIAL = '" + xFilial("VOE") + "' " +;
				   " AND VOE.VOE_DATESC < '" + DtoS(pdDataIni) + "' " +;
				   " AND NOT EXISTS( SELECT VOE_DATESC " +;
										   " FROM " + RetSQLName("VOE") + " TEMPVOE " +;
										  " WHERE TEMPVOE.VOE_FILIAL = '" + xFilial("VOE") + "' " +;
										    " AND TEMPVOE.VOE_CODPRO = '" + Self:GetCodigo() + "' " +;
											 " AND TEMPVOE.VOE_DATESC = '" + DtoS(pdDataIni) + "' " +;
											 " AND TEMPVOE.D_E_L_E_T_ = ' ' ) " +;
				   " AND VOE.VOE_CODPRO = '" + Self:GetCodigo() + "' " +;
				   " AND VOE.D_E_L_E_T_ = ' ' " +;
				" GROUP BY VOE.VOE_CODPRO ) TEMP " +;
				"    ON VOE.VOE_FILIAL = '" + xFilial("VOE") + "' " +;
				  " AND VOE.VOE_CODPRO = TEMP.VOE_CODPRO " +;
				  " AND VOE.VOE_DATESC = TEMP.ESCALA " +;
				  " AND VOE.D_E_L_E_T_ = ' ' "
	
	cSQL += "  UNION ALL "
	
	// Carrega os registro de escala do periodo a ser processado
	cSQL += ;
	" SELECT VOE2.VOE_DATESC , VOE2.VOE_CODPER " +;
		 IIf( lVOEFILPRO , ", VOE2.VOE_FILPRO " , "" ) + ;
 	  " FROM " + RetSQLName("VOE") + " VOE2 " +;
	 " WHERE VOE2.VOE_FILIAL = '" + xFilial("VOE") + "' " +;
	   " AND VOE2.VOE_DATESC BETWEEN '" + DtoS(pdDataIni) + "' AND '" + DtoS(pdDataFim) + "' " +;
	   " AND VOE2.VOE_CODPRO = '" + Self:GetCodigo() + "' " +;
	   " AND VOE2.D_E_L_E_T_ = ' ' "
	
	cSQL += " UNION ALL "
	
	// Cria o registro final da escala, se nao possuir um VOE igual a data final de processalmento, sera retornado o ultimo periodo cadastrado
	cSQL += ;
	" SELECT '" + DtoS(pdDataFim) + "' VOE_DATESC , VOE.VOE_CODPER" +;
		 IIf( lVOEFILPRO , ", VOE.VOE_FILPRO " , "" ) + ;
	  " FROM " + RetSQLName("VOE") + " VOE JOIN ( " +;
				" SELECT VOE.VOE_CODPRO, MAX(VOE.VOE_DATESC) ESCALA " +;
				  " FROM " + RetSQLName("VOE") + " VOE " +;
				 " WHERE VOE.VOE_FILIAL = '" + xFilial("VOE") + "' " +;
				   " AND VOE.VOE_DATESC < '" + DtoS(pdDataIni) + "' " +;
				   " AND NOT EXISTS( SELECT VOE_DATESC " +;
										 " FROM " + RetSQLName("VOE") + " TEMPVOE " +;
										" WHERE TEMPVOE.VOE_FILIAL = '" + xFilial("VOE") + "' " +;
										  " AND TEMPVOE.VOE_CODPRO = '" + Self:GetCodigo() + "' " +;
										  " AND TEMPVOE.VOE_DATESC = '" + DtoS(pdDataFim) + "' " +;
										  " AND TEMPVOE.D_E_L_E_T_ = ' ' ) " +;
				   " AND VOE.VOE_CODPRO = '" + Self:GetCodigo() + "' " +;
				   " AND VOE.D_E_L_E_T_ = ' ' " +;
				" GROUP BY VOE.VOE_CODPRO ) TEMP " +;
				"    ON VOE.VOE_FILIAL = '" + xFilial("VOE") + "' " +;
				  " AND VOE.VOE_CODPRO = TEMP.VOE_CODPRO " +;
				  " AND VOE.VOE_DATESC = TEMP.ESCALA " +;
				  " AND VOE.D_E_L_E_T_ = ' ' " +;
	" ORDER BY 1 "

Return cSQL

/*/{Protheus.doc} PreencheLacunas
Funcao responsavel por gerar linhas na Array de escala entre uma data de escala e outra
@author Rubens
@since 06/06/2018
@version 1.0
@param dDataInicial, date, Data inicial de Processamento (Se nao for passada, sera considerada a data da escala da penultima linha da Array de Escala)
@param dDataFinal, date, Data final de Processamento (Se nao for passada, sera considerada a data da escala da ultima linha da Array de Escala)
@param cCodPer, characters, Codigo do periodo para ser incluido (Se nao for passado, sera considerada o periodo da penultima linha da Array de Escala)
@type function
/*/
Method PreencheLacunas(dDataInicial , dDataFinal, cCodPer) Class DMS_Produtivo

	Local dDataAux := CtoD(" ")
	Local nEscAnterior
	Local nEscAtual    := Len(Self:aEscala)

	Default dDataInicial := CtoD(" ")
	Default dDataFinal := CtoD(" ")
	Default cCodPer := ""

	If nEscAtual < 1 .or. (nEscAtual == 1 .and. Empty(dDataInicial))
		Return
	EndIf

	If Empty(dDataFinal)
		nEscAnterior := IIf( nEscAtual == 1 , nEscAtual , nEscAtual - 1 )
		If Empty(dDataInicial)
			dDataInicial := StoD(Self:aEscala[ nEscAnterior , 1])
		EndIf
		dDataFinal   := StoD(Self:aEscala[ nEscAtual , 1])
		If Empty(cCodPer)
			cCodPer      := Self:aEscala[ nEscAnterior , 2]
		EndIf
	Else
		If Empty(dDataInicial)
			dDataInicial := StoD(Self:aEscala[ nEscAtual , 1])
		EndIf
		If Empty(cCodPer)
			cCodPer      := Self:aEscala[ nEscAtual , 2]
		EndIf
	EndIf

	// Adiciona escala para os "buracos" ..
	dDataAux := dDataInicial
	While dDataAux < dDataFinal
		Self:AddEscala( cCodPer , DtoS(dDataAux++) )
	End
	//
	aSort( Self:aEscala ,,,{|x,y| x[1] < y[1] })

Return


/*/{Protheus.doc} GetAusencia
	Metodo utilizado para carregar as ausencias dos produtivos

	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param pdDataIni, data, Data Inicial a ser considerada
	@param pdDataFim, data, Data Final a ser considerada
/*/
Method GetAusencia(pdDataIni,pdDataFim) Class DMS_Produtivo
	Local cSQL

	cSQL := "SELECT SUM(VO4_TEMAUS)"
	cSQL +=  " FROM " + RetSQLName("VO4") + " VO4 "
	cSQL += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
	cSQL +=   " AND VO4.VO4_NOSNUM = '99999999'"
	cSQL +=   " AND VO4.VO4_SEQUEN = '99999999'"
	cSQL +=   " AND VO4.VO4_DATINI >= '" + DtoS(pdDataIni) + "'"
	cSQL +=   " AND VO4.VO4_DATFIN <= '" + DtoS(pdDataFim) + "'"
	cSQL +=   " AND VO4.VO4_CODPRO = '" + Self:GetCodigo() + "'"
	cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"

	Self:nHorasDispo -= FM_SQL(cSQL)

Return

/*/{Protheus.doc} AddIniFimEscala
	Metodo utilizado para adicionar uma escala na matriz auxiliar de escala do objeto

	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param pdData, data, Data da Escala
/*/
Method AddIniFimEscala(pdData) Class DMS_Produtivo
	Local cSQL
	Local cAliasIF := "TIF"
	If Self:oSQLHelper == NIL
		Self:oSQLHelper := DMS_SQLHelper():New()
	EndIf
	cSQL := "SELECT VOE_DATESC, VOE_CODPER "
	cSQL +=  " FROM " + RetSQLName("VOE") + " VOE "
	cSQL += " WHERE VOE.VOE_FILIAL = '" + xFilial("VOE") + "'"
	cSQL +=   " AND VOE.VOE_CODPRO = '" + Self:GetCodigo() + "'"
	cSQL +=   " AND VOE.VOE_DATESC <= '" + DtoS(pdData) + "'"
	cSQL +=   " AND VOE.D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY VOE_DATESC DESC"
	cSQL := Self:oSQLHelper:TOPFunc(cSQL,1)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasIF , .F., .T. )
	If !(cAliasIF)->(Eof())
		Self:AddEscala((cAliasIF)->VOE_CODPER,DtoS(pdData))
	End
	(cAliasIF)->(dbCloseArea())
Return

/*/{Protheus.doc} GetEscala
	Retorna as escalas carregadas no objeto

	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
/*/
Method GetEscala() Class DMS_Produtivo
Return(Self:aEscala)

/*/{Protheus.doc} PesqEscala
	Pesquisa uma escala na matriz de escalas carregadas

	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param pData, data, Data para pesquisar na matriz de escalas carregadas
/*/
Method PesqEscala(pData) Class DMS_Produtivo
Return (aScan(Self:aEscala,{ |x| x[1] == DtoS(pData) }))

/*/{Protheus.doc} AddEscala
	Adiciona uma escala na matriz auxiliar de escalas do objeto

	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param pcCodPeriodo, character, Codigo do Periodo da Data da Escala
	@param pcDataEsc, character, Data da Escala (Formato YYYYMMDD)
/*/
Method AddEscala(pcCodPeriodo,pcDataEsc) Class DMS_Produtivo
	Local nPosPeriodo

	If self:PesqEscala( StoD(pcDataEsc) ) <> 0
		Return
	EndIf

	nPosPeriodo := Self:AddPeriodo(pcCodPeriodo)
	AADD( Self:aEscala , { ;
		pcDataEsc ,;    // 01 - Data da Escala
		pcCodPeriodo ,; // 02 - Codigo do Periodo
		nPosPeriodo,;   // 03 - Posicao do Periodo na Array de Periodos ...
		Self:aPeriodo[nPosPeriodo,10] } ) // Total de Horas disponiveis para ao Periodo
Return

/*/{Protheus.doc} AddPeriodo
	Adiciona um periodo na matriz auxiliar, para calculo de horas

	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param pcCodPeriodo, character, Codigo do Periodo
/*/
Method AddPeriodo(pcCodPeriodo) Class DMS_Produtivo
	Local cSQL
	Local nPosPeriodo
	Local cAliasPer := "TPER"
	Local nInicio
	If ( nPosPeriodo := aScan(Self:aPeriodo,{ |x| x[1] == pcCodPeriodo } ) ) == 0

		If Self:oUtil == NIL
			Self:oUtil := DMS_Util():New()
		EndIf

		cSQL := "SELECT VOH_CODPER, VOH_INIPER, VOH_INICF1, VOH_FINCF1, VOH_INIREF, VOH_FINREF, VOH_INICF2, VOH_FINCF2, VOH_FINPER"
		cSQL += " FROM " + RetSQLName("VOH") + " VOH "
		cSQL += " WHERE VOH.VOH_FILIAL = '" + xFilial("VOH") + "'"
		cSQL +=   " AND VOH.VOH_CODPER = '" + pcCodPeriodo + "'"
		cSQL +=   " AND VOH.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasPer , .F., .T. )
		AADD( Self:aPeriodo , { ;
				(cAliasPer)->VOH_CODPER,; // 01 - Codigo do Periodo
				(cAliasPer)->VOH_INIPER,; // 02 - Inicio do Periodo
				(cAliasPer)->VOH_INICF1,; // 03 - Inicio do Intervalo 1
				(cAliasPer)->VOH_FINCF1,; // 04 - Fim    do Intervalo 2
				(cAliasPer)->VOH_INIREF,; // 05 - Inicio do Almoco
				(cAliasPer)->VOH_FINREF,; // 06 - Fim    do Almoco
				(cAliasPer)->VOH_INICF2,; // 07 - Inicio do Intervalor 2
				(cAliasPer)->VOH_FINCF2,; // 08 - Fim    do Intervalo 2
				(cAliasPer)->VOH_FINPER,; // 09 - Fim    do Periodo
				0,;   // 10 - Tempo Disponivel do Periodo
				0,;   // 11 - Tempo do Intervalo 1 ( Inicio          -> Inicio Intervalo 1 )
				0,;   // 12 - Tempo do Intervalo 2 ( Fim Intervalo 1 -> Inicio Refeicao    )
				0,;   // 13 - Tempo do Intervalo 3 ( Fim Refeicao    -> Inicio Intervalo 2 )
				0,;   // 14 - Tempo do Intervalo 4 ( Fim Intervalo 2 -> Fim Periodo        )
				{} } )

		nPosPeriodo := Len(Self:aPeriodo)
		If (cAliasPer)->VOH_INIPER <> 0
			nInicio := (cAliasPer)->VOH_INIPER
			If (cAliasPer)->VOH_INICF1 <> 0
				Self:AddAuxPeriodo( nPosPeriodo , nInicio , (cAliasPer)->VOH_INICF1 , "D" )
				Self:AddAuxPeriodo( nPosPeriodo , (cAliasPer)->VOH_INICF1 , (cAliasPer)->VOH_FINCF1 , "F" )
				nInicio := (cAliasPer)->VOH_FINCF1
			EndIf
			If (cAliasPer)->VOH_INIREF <> 0
				Self:AddAuxPeriodo( nPosPeriodo , nInicio , (cAliasPer)->VOH_INIREF , "D" )
				Self:AddAuxPeriodo( nPosPeriodo , (cAliasPer)->VOH_INIREF , (cAliasPer)->VOH_FINREF , "F" )
				nInicio := (cAliasPer)->VOH_FINREF
			EndIf
			If (cAliasPer)->VOH_INICF2 <> 0
				Self:AddAuxPeriodo( nPosPeriodo , nInicio , (cAliasPer)->VOH_INICF2 , "D" )
				Self:AddAuxPeriodo( nPosPeriodo , (cAliasPer)->VOH_INICF2 , (cAliasPer)->VOH_FINCF2 , "F" )
				nInicio := (cAliasPer)->VOH_FINCF2
			EndIf
			If (cAliasPer)->VOH_FINPER <> 0
				Self:AddAuxPeriodo( nPosPeriodo , nInicio , (cAliasPer)->VOH_FINPER , "D" )
			EndIf
			aEval( Self:aPeriodo[nPosPeriodo,15] ,{ |x| Self:aPeriodo[nPosPeriodo,10] += IIf( x[3] == "D" , x[4] , 0 ) })
		EndIf
		(cAliasPer)->(dbCloseArea())
	EndIf
Return nPosPeriodo

/*/{Protheus.doc} AddAuxPeriodo
	Metodo auxiliar para adicionar a hora inicial e final de um periodo

	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param nPosPeriodo , number, Posicao na matriz aPeriodo para adicionar a hora inial e final
	@param pHrIni, number, Hora Inicial
	@param pHrFim, number, Hora Final
	@param cTpHora, tipo da hora sendo, D - Disponivel, F - Fora do turno, A - Ausente, O - Ocupado, E - Hora Extra
/*/
Method AddAuxPeriodo( nPosPeriodo , pHrIni, pHrFim , cTpHora ) Class DMS_Produtivo
	pHrIni := Self:oUtil:Hora2Centes( pHrIni )
	pHrFim := Self:oUtil:Hora2Centes( pHrFim )
	AADD( Self:aPeriodo[ nPosPeriodo , 15 ] , { pHrIni , pHrFim , cTpHora , pHrFim - pHrIni } )
Return

/*/{Protheus.doc} TempoTrab
	Metodo utilizado para calcular o tempo trabalhado, considerando a escala do produtivo

	@type method
	@author Rubens
	@since 18/11/2015
	@version 1.0
	@param pDtIni, data, Data Inicio para calculo do tempo trabalhado
	@param pHrIni, number, Hora Inicio para calculo do tempo trabalhado
	@param pDtFim, data, Data Fim para calculo do tempo trabalhado
	@param pHrFim, number, Hora Fim para calculo do tempo trabalhado
/*/
Method TempoTrab(pDtIni, pHrIni, pDtFim, pHrFim) Class DMS_Produtivo

	Local nPosEscala := Self:PesqEscala( pDtIni )
	Local nPosEscFIM := Self:PesqEscala( pDtFim )
	Local nTempo     := 0
	Local dProc      := pDtIni
	Local nPosApon

	If nPosEscala == 0 .or. nPosEscFIM == 0
		Self:LoadEscala( pDtIni , pDtFim )
		nPosEscala := Self:PesqEscala( pDtIni )
		nPosEscFIM := Self:PesqEscala( pDtFim )
	EndIf

	If Self:oUtil == NIL
		Self:oUtil := DMS_Util():New()
	EndIf

 	pHrIni := Self:oUtil:Hora2Centes( pHrIni )
	pHrFim := Self:oUtil:Hora2Centes( pHrFim )

	While dProc <= pDtFim
		nPosPeriodo := Self:aEscala[ nPosEscala , 3 ]
		If dProc <> pDtIni .and. dProc <> pDtFim
			nTempo += Self:aPeriodo[nPosPeriodo,10]
		ElseIf Self:aPeriodo[nPosPeriodo,10] <> 0

			nHoraIni := IIF( dProc == pDtIni , pHrIni , Self:aPeriodo[ nPosPeriodo , 15 ,1 , 1 ] )
			nHoraFim := IIF( dProc == pDtFim , pHrFim , Self:aPeriodo[ nPosPeriodo , 15 ,Len( Self:aPeriodo[ nPosPeriodo,15 ] ) ,2] )

			If (nPosIni := aScan( Self:aPeriodo[nPosPeriodo,15] ,{ |x| nHoraIni < x[2] })) > 0
				If nHoraFim < Self:aPeriodo[nPosPeriodo,15,nPosIni,2]
					nTempo += nHoraFim - nHoraIni
					Exit
				Else
					nTempo += Self:aPeriodo[nPosPeriodo,15,nPosIni,2] - nHoraIni
				EndIf

				For nPosApon := nPosIni+1 to Len( Self:aPeriodo[ nPosPeriodo , 15 ] )
					If Self:aPeriodo[nPosPeriodo,15,nPosApon,03] == "D"
						If nHoraFim < Self:aPeriodo[nPosPeriodo,15,nPosApon,2]
							nTempo += nHoraFim - Self:aPeriodo[nPosPeriodo,15,nPosApon,1]
							Exit
						Else
							nTempo += Self:aPeriodo[nPosPeriodo,15,nPosApon,4]
						EndIf
					EndIf
				Next nPosApon
			EndIf
		EndIf
		nPosEscala++
		dProc++
	End

Return nTempo


Class DMS_PecaDia From DMS_Peca
	Method New() CONSTRUCTOR
	Method CalcPedFirm()
	Method GetIndice()
EndClass

Method New() Class DMS_PecaDia
Return

Method CalcPedFirm(cClassif, nPrevVenda) Class DMS_PecaDia
	Local nEstoque
	Local nRetorno := 0
	If cClassif == "A"
		nIndice := Self:GetIndice()
		nEstoque := Self:EstqSaldo2(Self:cLocPadrao,.f.)
		nPedPend := Self:PedCompraPendente()
		nRetorno := ( nIndice * nPrevVenda ) - ( nEstoque + nPedPend )
	ElseIf cClassif == "B"
		nEstqMax := Self:GetInfComplem("EMAX")
		nRetorno := nEstqMax - nPrevVenda
	EndIf
Return nRetorno

Method GetIndice() Class DMS_PecaDia
	Local cQuery
	cQuery := ;
		"SELECT (COALESCE(BZ.BZ_EMIN, B1.B1_EMIN) + COALESCE(BZ.BZ_PRZPED, B1.B1_PRZPED) + BZ.BZ_PE) " +;
			" FROM " + RetSQLName("SB1") + " B1" +;
			" LEFT JOIN " + RetSQLName("SBZ") + " BZ ON BZ.BZ_FILIAL = '" + xFilial("SBZ") + "' AND BZ.BZ_COD = B1.B1_COD AND BZ.D_E_L_E_T_ = ' ' " +;
		" WHERE B1.B1_FILIAL = '" + xFilial("SB1") + "'" +;
			" AND B1.B1_COD = '" + Self:cCodB1 + "'" +;
			" AND B1.D_E_L_E_T_ = ' '"
Return FM_SQL(cQuery)

/*/{Protheus.doc} LeCodBarras

Le o Codigo de Barras e retorna o SB1 correspondente com a qtde por Embalagem (Igual tratamento dos fontes do SIGAACD)

@author Andre Luis Almeida
@since  10/01/2018
@param  Codigo de Barras
@return array, { B1_COD , QTD. DE ITENS REFERENCIADO NO COD.BARRAS }

/*/
Method LeCodBarras(cCodBarras) Class DMS_Peca
Local cTipId       := ""
Local aProduto     := {}
Default cCodBarras := ""
//
If !Empty(cCodBarras)
	cTipId := CBRetTipo(cCodBarras) // Verifica o Tipo de Codigo de Barras
	If cTipId $ "EAN8OU13-EAN14-EAN128"
		aProduto := CBRetEtiEAN(cCodBarras)
	Else
		aProduto := CBRetEti(cCodBarras,'01')
	EndIf
EndIf
//
Return aClone(aProduto)
