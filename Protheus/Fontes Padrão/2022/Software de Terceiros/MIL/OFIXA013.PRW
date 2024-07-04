#include "OFIXA013.CH"
#include "PROTHEUS.CH"

/*/{Protheus.doc} OFIXA013
Conferencia de Orcamentos

@author Andre Luis Almeida
@since 26/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OFIXA013()

	Local cFiltro     := ""
	Local aSize       := FWGetDialogSize( oMainWnd )
	Local oSqlHlp     := DMS_SqlHelper():New()
	Local lAprovador  := OX0020151_UsuarioAprovador()
	Local cFaseConf   := Alltrim(GetNewPar("MV_MIL0095","4"))
	Local cQuery      := ""
	Local cQAlias     := "SQLVX5"
	Local nCntFor     := 0
	Local cFNome      := ""
	Local cFStatus    := ""
	Private cCadastro := STR0009 // Conferência de Peças Orçamentos

	// PONTO DE ENTRADA NO INICIO DA ROTINA
	If ExistBlock("OA013ROT")
		ExecBlock("OA013ROT",.f.,.f.)
	EndIf

	cFiltro := "@ VS1_STATUS = '"+cFaseConf+"'"
	cFiltro += "  AND ("
	cFiltro += "        ( VS1_STARES IN ('1','2') )"
	cFiltro += "        OR "
	cFiltro += "        ( VS1_STARES NOT IN ('1','2') AND VS1_DATVAL >= '"+dtos(ddatabase)+"' )"
	cFiltro += "        OR "
	cFiltro += "        ( VS1_TIPORC = '3' )"
	cFiltro += "      )"
	If !lAprovador
		cFiltro += " AND NOT EXISTS ( "
		cFiltro += 				" SELECT VM5_NUMORC "
		cFiltro += 				" FROM " + RetSqlName("VM5") + " VM5 "
		cFiltro += 				" WHERE VM5.VM5_FILIAL = VS1_FILIAL "
		cFiltro += 				" AND VM5.VM5_STATUS IN ('3','4') "
		cFiltro += 				" AND VM5.VM5_NUMORC = VS1_NUMORC "
		cFiltro += 				" AND VM5.D_E_L_E_T_ = ' '"
		cFiltro += ")"
	EndIf

	oDlgOX013 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0009, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Conferência de Peças Orçamentos

	oWorkArea := FWUIWorkArea():New( oDlgOX013 )
		
	oWorkArea:CreateHorizontalBox( "LINE01", 49 ) // -1 para nao estourar 100% da tela ( criando scroll lateral )
	oWorkArea:SetBoxCols( "LINE01", { "OBJ1" } )
	oWorkArea:CreateHorizontalBox( "LINE02", 49 )
	oWorkArea:SetBoxCols( "LINE02", { "OBJ2" } )

	oWorkArea:Activate()

	oBrwVS1 := FwMBrowse():New()
	oBrwVS1:SetOwner(oWorkarea:GetPanel("OBJ1"))
	oBrwVS1:SetDescription(STR0009) // Conferência de Peças Orçamentos
	oBrwVS1:SetAlias('VS1')
	oBrwVS1:SetMenuDef( 'OFIXA013' )
	oBrwVS1:AddStatusColumns({|| OXA130011_ColunaStatusOrcamento() }, {|| OXA130021_LegendaStatusOrcamento() })

	oBrwVS1:SetChgAll(.T.) //nao apresentar a tela para informar a filial
	oBrwVS1:SetFilterDefault( cFiltro )

	If VS1->(FieldPos("VS1_PRISEP")) > 0
		cQuery := "SELECT VX5_CODIGO , VX5_DESCRI "
		cQuery += "  FROM " + RetSQLName("VX5")
		cQuery += " WHERE VX5_FILIAL = '" + xFilial("VX5") + "'"
		cQuery += "   AND VX5_CHAVE  = '077'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY VX5_CODIGO"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
		Do While !( cQAlias )->( Eof())
			oBrwVS1:AddFilter(STR0007+": "+Alltrim(( cQAlias )->( VX5_CODIGO ))+" - "+( cQAlias )->( VX5_DESCRI ),"@ VS1_PRISEP = '"+( cQAlias )->( VX5_CODIGO )+"'",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar / Prioridade
			( cQAlias )->( DbSkip() )
		EndDo
		( cQAlias )->( dbCloseArea() )
		oBrwVS1:AddFilter(STR0008,"@ VS1_PRISEP = '  '",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar / Sem Prioridade
		DbSelectArea("VS1")
	EndIf

	If lAprovador
		For nCntFor := 2 to 3 // Criar Filtros por STATUS
			If nCntFor == 2
				cFNome := STR0011 // Conferencias Parciais
			Else // nCntFor == 3
				cFNome := STR0012 // Conferencias Finalizadas
			EndIf
			cFStatus := "@ EXISTS ( "
			cFStatus += 		" SELECT VM5_NUMORC "
			cFStatus += 		" FROM " + RetSqlName("VM5") + " VM5 "
			cFStatus += 		" WHERE VM5.VM5_FILIAL = VS1_FILIAL "
			cFStatus += 		" AND VM5.VM5_STATUS = '"+strzero(nCntFor,1)+"' "
			cFStatus += 		" AND VM5.VM5_NUMORC = VS1_NUMORC "
			cFStatus += 		" AND VM5.D_E_L_E_T_ = ' '"
			cFStatus += ")"
			oBrwVS1:AddFilter(cFNome,cFStatus,.f.,.f.,,,,"status"+strzero(nCntFor,1))
		Next
	EndIf

	oBrwVS1:DisableDetails()
	oBrwVS1:ForceQuitButton(.T.)
	oBrwVS1:Activate()

	oBrwVS3 := FwMBrowse():New()
	oBrwVS3:SetOwner(oWorkarea:GetPanel("OBJ2"))
	oBrwVS3:SetDescription(STR0010) // Itens do Orçamento
	oBrwVS3:SetMenuDef( '' )
	oBrwVS3:SetAlias('VS3')
	oBrwVS3:AddStatusColumns({|| OXA130031_ColunaStatusItens() }, {|| OXA130041_LegendaStatusItens() })
	oBrwVS3:DisableLocate()
	oBrwVS3:DisableDetails()
	oBrwVS3:SetAmbiente(.F.)
	oBrwVS3:SetWalkthru(.F.)
	oBrwVS3:SetInsert(.f.)
	oBrwVS3:SetUseFilter()
	oBrwVS3:lOptionReport := .f.
	oBrwVS3:Activate()

	oRelacOrc:= FWBrwRelation():New()
	oRelacOrc:AddRelation( oBrwVS1 , oBrwVS3 , {{ "VS3_FILIAL", "VS1_FILIAL" }, { "VS3_NUMORC", "VS1_NUMORC" } })
	oRelacOrc:Activate()

	oDlgOX013:Activate( , , , , , , ) //ativa a janela

Return NIL

/*/{Protheus.doc} OXA0EXEC
Executa a Conferencia do Orcamento selecionado no Browse

@author Andre Luis Almeida
@since 26/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OXA0EXEC()
DBSelectArea("VS1")
//
If !Softlock("VS1") // Travar Registro do VS1
	Return
EndIf
//
OFIXX002(VS1->VS1_NUMORC)
//
VS1->(MsUnlock()) // Retirar SoftLock do VS1
//
Return

/*/{Protheus.doc} MenuDef
Menudef - aRotina

@author Andre Luis Almeida
@since 26/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()
Local aRotina := {	{ STR0002 ,"AxPesqui" 	, 0 , 1},;			// Pesquisar
					{ STR0003 ,"OXA0EXEC"	, 0 , 2} }			// Conferir
Return aRotina

/*/{Protheus.doc} OXA130011_ColunaStatusOrcamento

@author Andre Luis Almeida
@since 26/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OXA130011_ColunaStatusOrcamento()
	
	// Variável do Retorno
	Local cImgRPO := "BR_BRANCO"

	cAlVM5 := 'TABVM5'
	BeginSql alias cAlVM5
		SELECT
			VM5.VM5_CODIGO,
			VM5.VM5_STATUS
		FROM
			%table:VM5% VM5
		WHERE
			VM5.VM5_FILIAL = %xfilial:VM5% AND
			VM5.VM5_NUMORC = %exp:VS1->VS1_NUMORC% AND
			VM5.%notDel%
		ORDER BY 1 DESC
	EndSql

	//-- Define Status do registro
	If (cAlVM5)->VM5_STATUS == "2" //Conf Parcial
		cImgRpo := "BR_AMARELO"
	ElseIf (cAlVM5)->VM5_STATUS == "3" //Conferido
		cImgRpo := "BR_VERDE"
	ElseIf (cAlVM5)->VM5_STATUS == "4" //Aprovado
		cImgRpo := "BR_PRETO"
	ElseIf (cAlVM5)->VM5_STATUS == "5" //Reprovado
		cImgRpo := "BR_VERMELHO"
	EndIf

	(cAlVM5)->(dbCloseArea())
	
Return cImgRPO

/*/{Protheus.doc} OXA130021_LegendaStatusOrcamento

@author Andre Luis Almeida
@since 26/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OXA130021_LegendaStatusOrcamento()
	Local aLegenda := {	{"BR_BRANCO"	, STR0015 }, ; // Pendente
						{"BR_AMARELO"	, STR0016 }, ; // Conf Parcial
						{"BR_VERDE"		, STR0017 }, ; // Conferido
						{"BR_PRETO"		, STR0018 }, ; // Aprovado
						{"BR_VERMELHO"	, STR0019 } } // Reprovado
	BrwLegenda(STR0014,STR0013,aLegenda ) // Status das Conferencias / Legenda
Return .T.

/*/{Protheus.doc} OXA130031_ColunaStatusItens

@author Andre Luis Almeida
@since 26/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OXA130031_ColunaStatusItens()
	
	// Variável do Retorno
	Local cImgRPO := "BR_BRANCO"

	cAlVM5 := 'TABVM5'
	BeginSql alias cAlVM5
		SELECT
			VM5.VM5_CODIGO,
			VM5.VM5_STATUS,
			VM6.VM6_QTCONF,
			VM6.VM6_QTORIG
		FROM
			%table:VM5% VM5
			JOIN %table:VM6% VM6 ON
				VM6.VM6_FILIAL = %xfilial:VM6% AND
				VM6.VM6_CODVM5 = VM5.VM5_CODIGO AND
				VM6.VM6_SEQUEN = %exp:VS3->VS3_SQCONF% AND
				VM6.%notDel%
		WHERE
			VM5.VM5_FILIAL = %xfilial:VM5% AND
			VM5.VM5_NUMORC = %exp:VS3->VS3_NUMORC% AND
			VM5.%notDel%
		ORDER BY 1 DESC
	EndSql

	If !(cAlVM5)->(Eof())
		//-- Define Status do registro
		If (cAlVM5)->VM6_QTCONF == 0 //Item nao conferido
			cImgRpo := "BR_AMARELO"
		ElseIf (cAlVM5)->VM6_QTCONF == (cAlVM5)->VM6_QTORIG .and. (cAlVM5)->VM5_STATUS <> "1" //Quantidade conferida 
			cImgRpo := "BR_VERDE"
		ElseIf (cAlVM5)->VM6_QTCONF <> (cAlVM5)->VM6_QTORIG .and. (cAlVM5)->VM5_STATUS <> "1" //Divergencia na conferencia
			cImgRpo := "BR_VERMELHO"
		EndIf
	EndIf

	(cAlVM5)->(dbCloseArea())

Return cImgRPO

/*/{Protheus.doc} OXA130041_LegendaStatusItens

@author Andre Luis Almeida
@since 26/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OXA130041_LegendaStatusItens()
	Local aLegenda := {	{"BR_BRANCO"	, STR0021 }, ; // Pendente
						{"BR_AMARELO"	, STR0022 }, ; // Item nao conferido
						{"BR_VERDE"		, STR0023 }, ; // Quantidade conferida
						{"BR_VERMELHO"	, STR0024 } } // Divergencia na conferencia
	BrwLegenda(STR0020,STR0013,aLegenda ) // Status das Conferencias dos Itens do Orçamento / Legenda
Return .T.