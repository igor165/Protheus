#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "VEIA142.CH"

#DEFINE BR Chr(10)

Static aFilAtu     := FWArrFilAtu()
Static aSM0        := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Static cNCpoVQ0    := "VQ0_CODVJQ/VQ0_DATFDD/VQ0_DATORS/VQ0_EVENTO/VQ0_QTDVEI"
Static cNCpoVJR    := "VJR_CODVQ0/VJR_STAIMP"
Static cNCpoVJN    := "VJN_CODIGO/VJN_CODVQ0/VJN_CODVJV"

Function VEIA142()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VQ0')
	oBrowse:SetDescription(STR0001) //"Pedido de compra de máquina"
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina 	:= {}
	Local lVA142MNU := ExistBlock('VA142MNU')
	Local lVA142REP := ExistBlock('VA142REP')

	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.VEIA142' OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.VEIA142' OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.VEIA142' OPERATION 5 ACCESS 0 //"Excluir"
	
	ADD OPTION aRotina Title STR0005 Action 'FS_RELCHA("R")' OPERATION 4 ACCESS 0 // "Relacionar Chassi"
	ADD OPTION aRotina Title STR0006 Action 'FS_RELCHA("D")' OPERATION 4 ACCESS 0 //'Desfazer Relacionamento'
	ADD OPTION aRotina Title STR0007 Action 'VA1420045_ConfiguracaoMaquina()' OPERATION 4 ACCESS 0 //'Configuração'
	ADD OPTION aRotina Title STR0008 Action 'VEIVM060(VQ0->VQ0_CHAINT)' OPERATION 4 ACCESS 0 //'Bloqueio'
	ADD OPTION aRotina Title STR0009 Action 'VA1420035_VisualizaAtendimento()' OPERATION 4 ACCESS 0 //'Visualizar Atendimento'
	ADD OPTION aRotina Title STR0010 Action 'VA1420025_ObeservacaoChassi(VQ0->VQ0_CHAINT)' OPERATION 4 ACCESS 0 //'Obs.Máq/Equip.'
	ADD OPTION aRotina Title STR0011 Action 'VA1420095_AtualizaPedidoImportado()' OPERATION 4 ACCESS 0 //'Atualiz Modelo Importacao'
	ADD OPTION aRotina Title STR0012 Action 'VA1600065_Historico()' OPERATION 4 ACCESS 0 //'Hist Import CGPoll'
	ADD OPTION aRotina Title STR0049 Action 'VEIA161(VQ0->VQ0_CODIGO)' OPERATION 4 ACCESS 0 //'Hist Atualiz Ped CGPoll'
	ADD OPTION aRotina Title STR0014 Action 'VA1420055_BonusDefault(VQ0->VQ0_NUMPED)' OPERATION 4 ACCESS 0 //'Informar Bônus Default'
	ADD OPTION aRotina Title STR0015 Action 'VA1420085_GeraNFBonus()' OPERATION 4 ACCESS 0 //'Gerar NF Bônus'
	ADD OPTION aRotina Title STR0016 Action 'VA1420105_AtualizaPedidosAntigos()' OPERATION 4 ACCESS 0 //'Ajustar Ped. Antigos'

	If lVA142REP
		ADD OPTION aRotina Title STR0042 Action 'VA1420115_ReplicarPedido()' OPERATION 4 ACCESS 0 //'Replicar'
	EndIf

	If lVA142MNU
		aRotina := ExecBlock("VA142MNU",.F.,.F.,{aRotina})
	Endif

Return aRotina

Static Function ModelDef()
	Local oModel
	Local oStrVQ0 := FWFormStruct(1, "VQ0")
	Local oStrVJR := FWFormStruct(1, "VJR")
	Local oStrVJN := FWFormStruct(1, "VJN")
	Local oStrVJS := FWFormStruct(1, "VJS")

	oStrVQ0:SetProperty('VQ0_CODIGO', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSXENum("VQ0","VQ0_CODIGO",,1)'))		//Ini Padrão

	oModel := MPFormModel():New('VEIA142',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)

	// A rotina VEIA140 cria um veiculo com o minimo de informacao 
	If IsInCallStack("VEIA140")
		oStrVQ0:SetProperty( 'VQ0_NUMPED' , MODEL_FIELD_WHEN, { || .t. })
		oStrVQ0:SetProperty( 'VQ0_CORVEI' , MODEL_FIELD_WHEN, { || .t. })
		oStrVQ0:SetProperty( 'VQ0_DESCOR' , MODEL_FIELD_WHEN, { || .t. })
	EndIf

	oModel:AddFields('VQ0MASTER',/*cOwner*/ , oStrVQ0)
	oModel:SetPrimaryKey( { "VQ0_FILIAL", "VQ0_CODIGO" , "VQ0_CHAINT" } )

	oModel:AddFields('VJRMASTER', 'VQ0MASTER' , oStrVJR)
	oModel:SetRelation( 'VJRMASTER', { { 'VJR_FILIAL', 'xFilial( "VJR" )' }, { 'VJR_CODVQ0', 'VQ0_CODIGO' } }, VJR->( IndexKey( 1 ) ) )

	oModel:AddGrid("VJNMASTER","VQ0MASTER",oStrVJN)
	oModel:SetRelation( 'VJNMASTER', { { 'VJN_FILIAL', 'xFilial( "VJN" )' }, { 'VJN_CODVQ0', 'VQ0_CODIGO' } }, VJN->( IndexKey( 2 ) ) )
	oModel:GetModel( 'VJNMASTER' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'VJNMASTER' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'VJNMASTER' ):SetNoInsertLine( .T. )
	oModel:GetModel("VJNMASTER"):SetOptional(.T.)

	oModel:AddGrid("VJSMASTER","VQ0MASTER",oStrVJS)
	oModel:SetRelation( 'VJSMASTER', { { 'VJS_FILIAL', 'xFilial( "VJS" )' }, { 'VJS_CODVQ0', 'VQ0_CODIGO' } }, VJS->( IndexKey( 1 ) ) )
	oModel:GetModel( 'VJSMASTER' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'VJSMASTER' ):SetNoUpdateLine( .T. )
	oModel:GetModel( 'VJSMASTER' ):SetNoInsertLine( .T. )
	oModel:GetModel("VJSMASTER"):SetOptional(.T.)

	oModel:SetDescription(STR0001)
	oModel:GetModel('VQ0MASTER'):SetDescription(STR0017) // Dados do pedido de compra de máquina
	oModel:GetModel('VJRMASTER'):SetDescription(STR0018) //'Dados complementares do pedido de compra de máquina'
	oModel:GetModel('VJNMASTER'):SetDescription(STR0019) //'Dados dos opcionais do pedido de compra de máquina'
	oModel:GetModel('VJSMASTER'):SetDescription(STR0048) //'Histórico'

	oModel:InstallEvent("VEIA142EVDF", /*cOwner*/, VEIA142EVDF():New("VEIA142"))

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVQ0:= FWFormStruct(2, "VQ0", { |cCampo| !ALLTRIM(cCampo) $ cNCpoVQ0 } )
	Local oStrVJR:= FWFormStruct(2, "VJR", { |cCampo| !ALLTRIM(cCampo) $ cNCpoVJR })
	Local oStrVJN:= FWFormStruct(2, "VJN", { |cCampo| !ALLTRIM(cCampo) $ cNCpoVJN } )

	// A rotina VEIA140 cria um veiculo com o minimo de informacao 
	If IsInCallStack("VEIA140")
		oStrVQ0:SetProperty( 'VQ0_CHAINT' , MVC_VIEW_CANCHANGE, .t.)
	EndIf

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'VQ0', 70)
	oView:AddField('VIEW_VQ0', oStrVQ0, 'VQ0MASTER')
	oView:EnableTitleView('VIEW_VQ0', STR0001)
	oView:SetOwnerView('VIEW_VQ0','VQ0')

	oView:CreateHorizontalBox( 'VJRVJN', 30)

	oView:CreateFolder( 'ABAS', 'VJRVJN' )
	
	oView:AddSheet( 'ABAS', 'ABA_VJR', STR0020 ) //'Complemento do Pedido'
	oView:CreateHorizontalBox( 'BOX_VJR' , 100,,, 'ABAS', 'ABA_VJR' )
	oView:AddField('VIEW_VJR', oStrVJR, 'VJRMASTER')
	oView:SetOwnerView('VIEW_VJR','BOX_VJR')

	oView:AddSheet( 'ABAS', 'ABA_VJN', STR0021 ) //'Opcionais do Pedido'
	oView:CreateHorizontalBox( 'BOX_VJN' , 100,,, 'ABAS', 'ABA_VJN' )
	oView:AddGrid("VIEW_VJN",oStrVJN, 'VJNMASTER')
	oView:SetOwnerView('VIEW_VJN','BOX_VJN')

Return oView

Function FS_RELCHA(cTpRelac)

	Local cGruVei     := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
	Local lRet        := .f.
	Local cChaInt     := ""
	Local cSQL        := ""
	Local cQAlVV1     := "SQLVV1"
	Local aVV1        := {}
	Local cBkpFilAnt  := cFilAnt
	Local nCont       := 0
	Local cFilVVA     := "("
	Local cFilVVG     := "("
	Local lVV1Comp    := .t.
	Local cFilVV1     := xFilial("VV1")
	Local nRecNo      := 0
	Local lVerVV1Mov  := ( GetNewPar("MV_MIL0061","N") $ "S/1" ) // Pedido deixar relacionamento com Veiculos que ja possuem Movimentacoes Entrada/Saida
	Local cFilRel     := ""
	Local lVQ0_FILREL := ( VQ0->(ColumnPos("VQ0_FILREL")) > 0 ) // Filial Entrada Relacionada - controle interno para possibilitar desfazer o relacionamento do Chassi
	Local lVQ0_SEGMOD := ( VQ0->(ColumnPos("VQ0_SEGMOD")) > 0 )
	Local oModelVV1 := FWLoadModel( 'VEIA070' )
	Local oModelVQ0 := FWLoadModel( 'VEIA142' )
	Local cChaAnt	:= ""

	Default cTpRelac  := "" // R-elaciona Chassi / D-esfazer Relacionamento de Chass

	If Empty(VQ0->VQ0_NUMPED) // Caso esteja vazio o listbox
		Return(lRet)
	EndIf

	If cTpRelac == "R" .and. !Empty(VQ0->VQ0_CHASSI)
		MsgInfo( STR0022 ) //"Há um chassi relacionado a esse pedido!"
		Return(lRet)
	EndIf

	If cTpRelac == "D"
		If lVQ0_FILREL .and. !Empty(VQ0->VQ0_FILREL) // Filial Entrada Relacionada - controle interno para possibilitar desfazer o relacionamento do Chassi
			If !MsgYesNo( STR0023 , STR0024 ) // Deseja desfazer o relacionamento entre o CHASSI e este Pedido? / Atencao
				Return(lRet)
			EndIf
		Else
			MsgStop( STR0025 , STR0024 ) // Impossivel desfazer relacionamento entre o CHASSI e este Pedido. / Atencao
			Return(lRet)
		EndIf
	EndIf

	If !Empty(cTpRelac)
		For nCont := 1 to Len(aSM0)
			cFilAnt := aSM0[nCont]
			If lVV1Comp .and. cFilVV1 <> xFilial("VV1") // Verifica se o VV1 nao eh compartilhado
				lVV1Comp := .f.
			EndIf
			cFilVVA += "'"+xFilial("VVA")+"',"
			cFilVVG += "'"+xFilial("VVG")+"',"
		Next
		cFilAnt := cBkpFilAnt
		cFilVVA := left(cFilVVA,len(cFilVVA)-1)+")"
		cFilVVG := left(cFilVVG,len(cFilVVG)-1)+")"
		
		//
		cSQL := "SELECT VVA.R_E_C_N_O_ FROM "+RetSqlName("VVA")+" VVA "
		cSQL += "JOIN "+RetSqlName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VVA.VVA_FILIAL AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND VV9.VV9_STATUS<>'C' AND VV9.D_E_L_E_T_=' ' ) "
		cSQL += "WHERE "
		If lVV1Comp // VV1 Compartilhado
			cSQL += "VVA.VVA_FILIAL IN "+cFilVVA+" AND "
		Else // VV1 Exclusivo
			cSQL += "VVA.VVA_FILIAL='"+xFilial("VVA")+"' AND "
		EndIf
		cSQL += "VVA.VVA_CHAINT='"+VQ0->VQ0_CHAINT+"' AND VVA.D_E_L_E_T_=' '"
		nRecNo := FM_SQL(cSQL)
		If nRecNo > 0
			DbSelectArea("VVA")
			DbGoTo(nRecNo)
			MsgInfo( STR0026 +CHR(13)+CHR(10)+CHR(13)+CHR(10)+ STR0027 +": "+VVA->VVA_FILIAL+CHR(13)+CHR(10)+RetTitle("VQ0_NUMATE")+": "+VVA->VVA_NUMTRA, STR0024 ) // Ja existe Atendimento para esse Pedido! / Filial Atend. / Atendimento / Atencao
			Return(lRet)
		EndIf
		//
		If cTpRelac == "R" // Relaciona Chassi
			If !Empty(VQ0->VQ0_CHASSI)
				MsgInfo( STR0028 , STR0024 ) // Chassi ja relacionado para esse Pedido! / Atencao
				Return(lRet)
			EndIf
			DbSelectArea("VV1")
			DbSetOrder(1)
			DbSeek(xFilial("VV1")+VQ0->VQ0_CHAINT)
			cSQL := "SELECT DISTINCT VV1.VV1_CHASSI , VV1.VV1_CHAINT , VV1.VV1_PLAVEI , VV1.VV1_FABMOD , VV1.VV1_CODFRO , VV1.VV1_SERMOT , VV1.VV1_SITVEI , "
			cSQL += "VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV2.VV2_DESMOD , VV1.VV1_CORVEI , VVC.VVC_DESCRI , VV1.VV1_PROATU , VV1.VV1_LJPATU , SA1.A1_NOME "
			cSQL += "FROM "+RetSqlName("VV1")+" VV1 "
			cSQL += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.VV2_SEGMOD=VV1.VV1_SEGMOD AND VV2.D_E_L_E_T_=' ' ) "
			cSQL += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VV1.VV1_PROATU AND SA1.A1_LOJA=VV1.VV1_LJPATU AND SA1.D_E_L_E_T_=' ' ) "
			cSQL += "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
			cSQL += "LEFT JOIN "+RetSqlName("VQ0")+" VQ0 ON ( VQ0.VQ0_FILIAL='"+xFilial("VQ0")+"' AND VQ0.VQ0_CHAINT=VV1.VV1_CHAINT AND VQ0.D_E_L_E_T_=' ' ) "
			cSQL += "WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CODMAR='"+VV1->VV1_CODMAR+"' AND VV1.VV1_MODVEI='"+VV1->VV1_MODVEI+"' AND VV1.VV1_SEGMOD='"+VV1->VV1_SEGMOD+"' AND VV1.VV1_CORVEI='"+VV1->VV1_CORVEI+"' AND VV1.VV1_CHASSI<>' ' AND VQ0.VQ0_CHAINT IS NULL AND VV1.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cQAlVV1, .F., .T. )
			Do While !( cQAlVV1 )->( Eof())
				nRecNo := 0
				// Verificar Movimentacao de Entrada/Saida //
				If !lVerVV1Mov // Nao Mostra Veiculos com Movimentacoes
					If lVV1Comp // VV1 Compartilhado
						cSQL := "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("VVG")+" WHERE VVG_FILIAL IN "+cFilVVG+" AND VVG_CHAINT='"+( cQAlVV1 )->( VV1_CHAINT )+"' AND D_E_L_E_T_=' '"
						cSQL += " UNION ALL "
						cSQL += "SELECT R_E_C_N_O_ RECNO FROM "+RetSqlName("VVA")+" WHERE VVA_FILIAL IN "+cFilVVA+" AND VVA_CHAINT='"+( cQAlVV1 )->( VV1_CHAINT )+"' AND D_E_L_E_T_=' '"
					Else // VV1 Exclusivo
						cSQL := "SELECT R_E_C_N_O_ FROM "+RetSqlName("VVG")+" WHERE VVG_FILIAL='"+xFilial("VVG")+"' AND VVG_CHAINT='"+( cQAlVV1 )->( VV1_CHAINT )+"' AND D_E_L_E_T_=' '"
						cSQL += " UNION ALL "
						cSQL += "SELECT R_E_C_N_O_ FROM "+RetSqlName("VVA")+" WHERE VVA_FILIAL='"+xFilial("VVA")+"' AND VVA_CHAINT='"+( cQAlVV1 )->( VV1_CHAINT )+"' AND D_E_L_E_T_=' '"
					EndIf
					nRecNo := FM_SQL(cSQL)
				EndIf
				If nRecNo <= 0
					Aadd(aVV1,{	( cQAlVV1 )->( VV1_CHAINT ),;
								( cQAlVV1 )->( VV1_PLAVEI ),;
								( cQAlVV1 )->( VV1_CHASSI ),;
								( cQAlVV1 )->( VV1_CODMAR )+" "+IIf(!Empty(( cQAlVV1 )->( VV2_DESMOD )),( cQAlVV1 )->( VV2_DESMOD ),( cQAlVV1 )->( VV1_MODVEI )),;
								left(IIf(!Empty(( cQAlVV1 )->( VVC_DESCRI )),( cQAlVV1 )->( VVC_DESCRI ),( cQAlVV1 )->( VV1_CORVEI )),12),;
								( cQAlVV1 )->( VV1_FABMOD ),;
								X3CBOXDESC("VV1_SITVEI",( cQAlVV1 )->( VV1_SITVEI )),;
								( cQAlVV1 )->( VV1_CODFRO ),;
								( cQAlVV1 )->( VV1_SERMOT ),;
								( cQAlVV1 )->( VV1_PROATU )+"-"+( cQAlVV1 )->( VV1_LJPATU )+" "+left(( cQAlVV1 )->( A1_NOME ),25)})
				EndIf
				( cQAlVV1 )->( DbSkip() )
			EndDo
			( cQAlVV1 )->( dbCloseArea() )
			If len(aVV1) > 0
				If FG_POSVV1(aVV1) // Selecionar o Veiculo

					oModelVQ0:SetOperation( MODEL_OPERATION_UPDATE )

					If VQ0->VQ0_CHAINT <> VV1->VV1_CHAINT

						cChaAnt := VQ0->VQ0_CHAINT

						lRet := oModelVQ0:Activate()

						If lRet

							If lVQ0_FILREL
								cFilRel := FM_SQL("SELECT VV1_FILENT FROM "+RetSqlName("VV1")+" WHERE VV1_FILIAL='"+xFilial("VV1")+"' AND VV1_CHASSI='"+VQ0->VQ0_CHAINT+"' AND D_E_L_E_T_=' '")
								If Empty(cFilRel)
									cFilRel := xFilial("SD2")
								EndIf
							EndIf

							oModelVQ0:SetValue( "VQ0MASTER", "VQ0_CHAINT", VV1->VV1_CHAINT )
							oModelVQ0:LoadValue( "VQ0MASTER", "VQ0_CHASSI", VV1->VV1_CHASSI )
							oModelVQ0:SetValue( "VQ0MASTER", "VQ0_FILREL", cFilRel )

							lRet := VA1420015_CommitData(oModelVQ0)

							oModelVQ0:DeActivate()

						Else
							Help("",1,"ACTIVEVQ0",, STR0029 ,1,0) // "Não foi possivel ativar o modelo de inclusão da tabela"
						EndIf

						If lRet

							DbSelectArea("VV1")
							DbSetOrder(1)

							If DbSeek( xFilial("VV1") + cChaAnt ) .and. Empty(VV1->VV1_CHASSI)

								oModelVV1:SetOperation( MODEL_OPERATION_DELETE )

								lRet := oModelVV1:Activate()

								If lRet
									lRet := VA1420015_CommitData(oModelVV1)
									oModelVV1:DeActivate()
								Else
									Help("",1,"ACTIVEVV1",, STR0029 ,1,0) // "Não foi possivel ativar o modelo de inclusão da tabela"
								EndIf

								If lRet

									DbSelectArea("SB1")
									DbSetOrder(7)
									If DbSeek(xFilial("SB1")+cGruVei+cChaAnt)
										RecLock("SB1",.F.,.T.)
										DbDelete()
										MsUnLock()
									EndIf
									DbSetOrder(1)

								EndIf

							EndIf

						EndIf
					Else
						lRet := oModelVQ0:Activate()

						If lRet
							oModelVQ0:SetValue( "VQ0MASTER", "VQ0_CHASSI", VV1->VV1_CHASSI )
							lRet := VA1420015_CommitData(oModelVQ0)
							oModelVQ0:DeActivate()
						Else
							Help("",1,"ACTIVEVQ0",, STR0029 ,1,0) // "Não foi possivel ativar o modelo de inclusão da tabela"
						EndIf

					EndIf
					
					If lRet
						MsgAlert( STR0030 , STR0024 ) // Pedido alterado com sucesso! / Atencao
					EndIf

				EndIf
			Else
				MsgInfo( STR0031 , STR0024 ) // Nenhum Chassi pode ser relacionado para este Pedido! / Atencao
				Return(lRet)
			EndIf

		ElseIf cTpRelac == "D" // Desfazer Relacionamento de Chassi

			oModelVV1:SetOperation( MODEL_OPERATION_INSERT )

			lRet := oModelVV1:Activate()

			If lRet

//				oModelVV1:SetValue( "MODEL_VV1", "VV1_FILIAL", xFilial("VV1") )
				oModelVV1:SetValue( "MODEL_VV1", "VV1_CHASSI", "" )
				oModelVV1:SetValue( "MODEL_VV1", "VV1_CODMAR", VQ0->VQ0_CODMAR )
				oModelVV1:SetValue( "MODEL_VV1", "VV1_MODVEI", VQ0->VQ0_MODVEI )
				If lVQ0_SEGMOD
					oModelVV1:SetValue( "MODEL_VV1", "VV1_SEGMOD", VQ0->VQ0_SEGMOD )
				EndIf
				oModelVV1:SetValue( "MODEL_VV1", "VV1_CORVEI", VQ0->VQ0_CORVEI )
				oModelVV1:SetValue( "MODEL_VV1", "VV1_SITVEI", "8" )
				oModelVV1:SetValue( "MODEL_VV1", "VV1_ESTVEI", "0" )
				oModelVV1:SetValue( "MODEL_VV1", "VV1_FILENT", VQ0->VQ0_FILREL )

				lRet := VA1420015_CommitData(oModelVV1)

				If lRet
					cChaInt := oModelVV1:GetValue("MODEL_VV1","VV1_CHAINT")
				EndIf

				oModelVV1:DeActivate()
			Else
				Help("",1,"ACTIVEVV1",, STR0029 ,1,0) // "Não foi possivel ativar o modelo de inclusão da tabela"
			EndIf
			
			if lRet
				oModelVQ0:SetOperation( MODEL_OPERATION_UPDATE )

				lRet := oModelVQ0:Activate()

				If lRet
					oModelVQ0:SetValue( "VQ0MASTER", "VQ0_CHAINT", VV1->VV1_CHAINT )
					oModelVQ0:SetValue( "VQ0MASTER", "VQ0_CHASSI", "" )
					oModelVQ0:SetValue( "VQ0MASTER", "VQ0_FILREL", "" )
					lRet := VA1420015_CommitData(oModelVQ0)
					oModelVQ0:DeActivate()
					If lRet
						MsgAlert( STR0030 , STR0024 ) // Pedido alterado com sucesso! / Atencao
					EndIf
				Else
					Help("",1,"ACTIVEVQ0",, STR0029 ,1,0) // "Não foi possivel ativar o modelo de inclusão da tabela"
				EndIf

			EndIf

		EndIf

	EndIf

	FreeObj( oModelVV1 )
	FreeObj( oModelVQ0 )

Return(lRet)


Function VA1420045_ConfiguracaoMaquina()
	Local aCfgs := {}

	VV1->(DbSetOrder(1))
	VV1->(DbSeek( xFilial('VV1') + VQ0->VQ0_CHAINT ))
	
	If GetNewPar("MV_MIL0168","0") == "1" // Trabalha com Pacote de Configuração ? 
		aAuxC := VEIA242( VV1->VV1_CODMAR , VV1->VV1_MODVEI , VV1->VV1_SEGMOD , VV1->VV1_CHAINT , ( GetNewPar("MV_MIL0167","1") == "1" ) ) // MV_MIL0167 - Gravação do Valor Sugerido: 1=Sim (default) / 0=Não
		If len(aAuxC) > 0
			aCfgs := aAuxC[4]
			VA380GRVCFG( VV1->VV1_CHAINT, aCfgs, aAuxC[3] , aAuxC[1] )
		EndIf
	Else
		VV2->(DbSeek( xFilial('VV2') + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD ))
		aAuxC := VA380CONFIG(VV1->VV1_CHAINT, VV1->VV1_CODMAR,  VV2->VV2_GRUMOD, @aCfgs, VV1->VV1_MODVEI , VV1->VV1_SEGMOD )
		if aAuxC == nil
			return
		else
			aCfgs := aAuxC[1]
			VA380GRVCFG( VV1->VV1_CHAINT , aCfgs , aAuxC[2] , "" )
		EndIf
	EndIf

Return

Function VA1420035_VisualizaAtendimento()
	Local cSlvFilAnt := cFilAnt
	Local cNumAte    := space(GetSX3Cache("VQ0_NUMATE","X3_TAMANHO"))
	Local cNamVVA    := RetSQLName("VVA")
	Local cNamVV9    := RetSQLName("VV9")
	Local cFilVVA    := ""
	Local ni         := 0

	cFAte := VQ0->VQ0_FILATE
	cNAte := VQ0->VQ0_NUMATE

	For ni := 1 to Len(aSM0)
		cFilAnt := aSM0[ni]
		cFilVVA += "'"+xFilial("VVA")+"',"
	Next
	cFilVVA := left(cFilVVA,len(cFilVVA)-1)
	cFilAnt := cSlvFilAnt

	If Empty(cFAte+cNAte) .and. !Empty(VQ0->VQ0_CHAINT)
		nRecVVA := 0
		If !Empty(cNumAte)
			cQuery  := "SELECT VVA.R_E_C_N_O_ FROM "+cNamVVA+" VVA "
			cQuery  += "JOIN "+cNamVV9+" VV9 ON ( VV9.VV9_FILIAL=VVA.VVA_FILIAL AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND VV9.VV9_STATUS<>'C' AND VV9.D_E_L_E_T_=' ' ) "
			cQuery  += "WHERE VVA.VVA_FILIAL IN ("+cFilVVA+") AND VVA.VVA_NUMTRA='"+cNumAte+"' AND VVA.VVA_CHAINT='"+ VQ0->VQ0_CHAINT+"' AND VVA.D_E_L_E_T_=' ' "
			cQuery  += "ORDER BY VVA.R_E_C_N_O_ DESC"
			nRecVVA := FM_SQL(cQuery)
		EndIf
		If nRecVVA == 0
			cQuery  := "SELECT VVA.R_E_C_N_O_ FROM "+cNamVVA+" VVA "
			cQuery  += "JOIN "+cNamVV9+" VV9 ON ( VV9.VV9_FILIAL=VVA.VVA_FILIAL AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND VV9.VV9_STATUS<>'C' AND VV9.D_E_L_E_T_=' ' ) "
			cQuery  += "WHERE VVA.VVA_FILIAL IN ("+cFilVVA+") AND VVA.VVA_CHAINT='"+VQ0->VQ0_CHAINT+"' AND VVA.D_E_L_E_T_=' ' "
			cQuery  += "ORDER BY VVA.R_E_C_N_O_ DESC"
			nRecVVA := FM_SQL(cQuery)
		EndIf
		If nRecVVA > 0
			DbSelectArea("VVA")
			DbGoTo(nRecVVA)
			cFAte := VVA->VVA_FILIAL
			cNAte := VVA->VVA_NUMTRA
		EndIf
	EndIf

	DbSelectArea("VV9")
	DbSetOrder(1)
	If DbSeek( cFAte + left(cNAte,TamSx3("VV9_NUMATE")[1]) )
		cFilAnt := cFAte
		VEIXX002(NIL,NIL,NIL,2,)
		cFilAnt := cSlvFilAnt
	Else
		MsgStop( STR0032 ) //"Não foi encontrado o atendimento deste pedido!"
	EndIf
Return(.t.)

Function VA1420025_ObeservacaoChassi(cChaInt)
	
	Local cFilCpoVV1 := "VV1_CHASSI|VV1_CHAINT|VV1_DESVEI|VV1_OBSVEI"

	Local oModelVV1 := FWLoadModel("VEIA070")
	Local oView
	Local oStruVV1 := FWFormStruct( 2, 'VV1' , { |x| AllTrim(x) $ cFilCpoVV1 } )

	VV1->(DbSetOrder(1))
	VV1->(DbSeek(xFilial("VV1")+cChaInt))

	oStruVV1:SetNoFolder()

	oView := FWFormView():New()
	oView:SetModel( oModelVV1 )
	oView:AddField( 'VIEW_VV1', oStruVV1, 'MODEL_VV1' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_VV1', 'TELA' )

	oExecView := FWViewExec():New()
	oExecView:setTitle( STR0033 ) // "Informaçoes do Veiculo"
	oExecView:setModel(oModelVV1)
	oExecView:setView(oView)
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:setReduction(30)
	oExecView:openView(.t.)

Return

Static Function VA1420015_CommitData(oModel)

Local lRet     := .t.

Default oModel := NIL

if oModel <> NIL
	If ( lRet := oModel:VldData() )
		if ( lRet := oModel:CommitData())
		Else
			Help("",1,"COMMIT",,oModel:GetErrorMessage()[6],1,0)
		EndIf
	Else
		Help("",1,"VALID",,oModel:GetErrorMessage()[6],1,0)
	EndIf
EndIf

Return lRet

Function VA1420055_BonusDefault(cNumPed)

	Local lRet
	Local aBonuDef := {}

/*
	Local cFilCpoVJR := "VQ0_NUMPED|VJR_CHASSI|VJR_CHAINT|VJR_DESVEI|VJR_OBSVEI"

	Local oView
	Local oStruVJR := FWFormStruct( 2, 'VJR' , { |x| AllTrim(x) $ cFilCpoVJR } )

	Default cNumPed := ""

	VV1->(DbSetOrder(1))
	VV1->(DbSeek(xFilial("VV1")+cChaInt))

	oStruVV1:SetNoFolder()

	oView := FWFormView():New()
	oView:SetModel( oModelVV1 )
	oView:AddField( 'VIEW_VV1', oStruVV1, 'MODEL_VV1' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_VV1', 'TELA' )

	oExecView := FWViewExec():New()
	oExecView:setTitle("Informaçoes do Veiculo")
	oExecView:setModel(oModelVV1)
	oExecView:setView(oView)
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:setReduction(30)
	oExecView:openView(.t.)
*/

	aBonuDef := VA1420075_LevantaValoresBonusDefault(cNumPed)

	nTDescCon := aBonuDef[1]
	nSDescTri := aBonuDef[2]
	nSDescCnd := aBonuDef[3]
	nSDescTat := aBonuDef[4]
	nSBonus   := aBonuDef[5]
	nSPrevImp := aBonuDef[6]

	If !Empty(cNumPed)

		oDlgBonus := MSDialog():New( 180, 180, 520, 500, STR0047, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )    // Configurar

			oPanelFull := TPanelCss():New(0,0,"",oDlgBonus,,.F.,.F.,,,80,80,.T.,.F.)
			oPanelFull:SetCSS("TPanelCss { background-color : #FFFFFF; border-radius: 4px; border: 4px solid #DCDCDC; } ")
			oPanelFull:Align := CONTROL_ALIGN_ALLCLIENT

			oTPanelTOP := TPanelCss():New(0,0,"",oPanelFull,,.F.,.F.,,,00,30,.T.,.F.)
			oTPanelTOP:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
			oTPanelTOP:Align := CONTROL_ALIGN_TOP

			oTPanelMIDLE := TPanelCss():New(0,0,"",oPanelFull,,.F.,.F.,,,00,15,.T.,.F.)
			oTPanelMIDLE:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
			oTPanelMIDLE:Align := CONTROL_ALIGN_ALLCLIENT

			/*oGroupPed:= TGroup():New(02,02,130,130,'Pedido',oTPanelTOP,,,.T.)
			oGroupPed:SetCSS("QGroupBox { border: 0px; margin-top: 5px; } QGroupBox::title { subcontrol-origin: margin; subcontrol-position: top center; } ")
			oGroupPed:Align := CONTROL_ALIGN_ALLCLIENT*/
 
			cTGet1 := cNumPed
			oTGet2 := TSay():New( 011,006,{ || STR0034 },oTPanelTOP,,,,,,.T.,CLR_RED,CLR_WHITE,200,20) // 'Pedido: '
			oTGet2:SetCSS("QLabel{ font-size: 12px; } ")
			oTGet2 := TGet():New( 008,055,{ || cTGet1 },oTPanelTOP,100,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet1,,,,)
			oTGet2:cF3 := "VQ0"
			//oTGet2:Align := CONTROL_ALIGN_CENTER
			
			oGroupBon:= TGroup():New(02,02,130,130, STR0035 ,oTPanelMIDLE,,,.T.) //'% Bonus Default'
			oGroupBon:SetCSS("QGroupBox { border: 0px; } QGroupBox::title { font-size: 12px; subcontrol-position: top center; } ")
			oGroupBon:Align := CONTROL_ALIGN_ALLCLIENT

			oSDescCon := TSay():New( 015,006,{ || GetSX3Cache("VJR_DESCON","X3_TITULO") },oGroupBon,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
			oTDescCon := TGet():New( 014,055,{|u| If(Pcount( )>0, nTDescCon := u, nTDescCon ) },oGroupBon,100,010,Alltrim(GetSX3Cache("VJR_DESCON","X3_PICTURE")),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"nTDescCon",,,,.t.)
			
			oSDescTri := TSay():New( 030,006,{ || GetSX3Cache("VJR_DESTRI","X3_TITULO") },oGroupBon,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
			oTDescTri := TGet():New( 029,055,{|u| If(Pcount( )>0, nSDescTri := u, nSDescTri ) },oGroupBon,100,010,GetSX3Cache("VJR_DESTRI","X3_PICTURE"),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"nSDescTri",,,,.t.)
			
			oSDescCnd := TSay():New( 045,006,{ || GetSX3Cache("VJR_DESCDC","X3_TITULO") },oGroupBon,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
			oTDescCnd := TGet():New( 044,055,{|u| If(Pcount( )>0, nSDescCnd := u, nSDescCnd ) },oGroupBon,100,010,GetSX3Cache("VJR_DESCDC","X3_PICTURE"),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"nSDescCnd",,,,.t.)
			
			oSDescTat := TSay():New( 060,006,{ || GetSX3Cache("VJR_DESTAT","X3_TITULO") },oGroupBon,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
			oTDescTat := TGet():New( 059,055,{|u| If(Pcount( )>0, nSDescTat := u, nSDescTat ) },oGroupBon,100,010,GetSX3Cache("VJR_DESTAT","X3_PICTURE"),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"nSDescTat",,,,.t.)
			
			oSBonus   := TSay():New( 075,006,{ || GetSX3Cache("VJR_PERVLR","X3_TITULO") },oGroupBon,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
			oTBonus   := TGet():New( 074,055,{|u| If(Pcount( )>0, nSBonus := u, nSBonus ) },oGroupBon,100,010,GetSX3Cache("VJR_PERVLR","X3_PICTURE"),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"nSBonus",,,,.t.)
			
			oSPrevImp := TSay():New( 090,006,{ || GetSX3Cache("VJR_PERIMP","X3_TITULO") },oGroupBon,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
			oTPrevImp := TGet():New( 089,055,{|u| If(Pcount( )>0, nSPrevImp := u, nSPrevImp ) },oGroupBon,100,010,GetSX3Cache("VJR_PERIMP","X3_PICTURE"),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"nSPrevImp",,,,.t.)

		oDlgBonus:Activate( , , , .t. , , , EnchoiceBar( oDlgBonus, {|| VA1420065_GravaValoresBonusDefault(), oDlgBonus:End() }, { || oDlgBonus:End() }, ,, , , , , .F., .T. ) )

	EndIf

Return

Function VA1420065_GravaValoresBonusDefault()

	Local aCpoVQ1 := {}
	Local aRecVQ1 := {}
	Local lRetVJR := .f.

	cQuery := "SELECT VJR.R_E_C_N_O_ VJRRECNO"
	cQuery += " FROM " + RetSQLName("VJR") + " VJR "
	cQuery += " WHERE VJR.VJR_FILIAL = '" + xFilial("VJR") + "' "
	cQuery += 	" AND EXISTS ( "
	cQuery += 					" SELECT VQ0.VQ0_CODIGO "
	cQuery += 					" FROM " + RetSQLName( "VQ0" ) + " VQ0 "
	cQuery += 					" WHERE   VQ0.VQ0_FILIAL = VJR.VJR_FILIAL "
	cQuery += 						" AND VQ0.VQ0_CODIGO = VJR.VJR_CODVQ0 "
	cQuery += 						" AND VQ0.VQ0_NUMPED = '" + cTGet1 + "' "
	cQuery += 						" AND VQ0.D_E_L_E_T_ = ' ' "
	cQuery += 	" ) AND VJR.D_E_L_E_T_ = ' ' "

	TcQuery cQuery New Alias "TMPVJR"

	While !TMPVJR->(Eof())

		VJR->(DbGoTo(TMPVJR->VJRRECNO))

		DbSelectArea("VJR")
		RecLock("VJR",.f.)
			VJR->VJR_DESCON := nTDescCon
			VJR->VJR_DESTRI := nSDescTri
			VJR->VJR_DESCDC := nSDescCnd
			VJR->VJR_DESTAT := nSDescTat
			VJR->VJR_PERVLR := nSBonus  
			VJR->VJR_PERIMP := nSPrevImp
		MsUnLock()

		aCpoVQ1 := {}
		aRecVQ1 := {}

		cQuery := "SELECT VQ1.R_E_C_N_O_ VQ1RECNO"
		cQuery += " FROM " + RetSQLName("VQ1") + " VQ1 "
		cQuery += " WHERE VQ1.VQ1_FILIAL = '" + xFilial("VQ1") + "' "
		cQuery += 	" AND VQ1.VQ1_CODIGO = '" + VJR->VJR_CODVQ0 + "' "
		cQuery += 	" AND VQ1.D_E_L_E_T_ = ' '"

		TcQuery cQuery New Alias "TMPVQ1"

		While !TMPVQ1->(Eof())

			VQ1->(DbGoTo(TMPVQ1->VQ1RECNO))
			
			DbSelectArea("VQ1")
			RecLock("VQ1",.f.)
				VQ1->VQ1_DESCON := nTDescCon
				VQ1->VQ1_DESTRI := nSDescTri
				VQ1->VQ1_DESCDC := nSDescCnd
				VQ1->VQ1_DESTAT := nSDescTat
				VQ1->VQ1_PERVLR := nSBonus  
				VQ1->VQ1_PERIMP := nSPrevImp
			MsUnLock()

			TMPVQ1->(DbSkip())
		
			lRetVJR := .t.

		EndDo

		TMPVQ1->(dbCloseArea())

		TMPVJR->(DbSkip())

	EndDo

	TMPVJR->(dbCloseArea())

	If lRetVJR
		MsgAlert( STR0030 , STR0024 ) // Pedido alterado com sucesso! / Atencao
	EndIf

Return



Function VA1420075_LevantaValoresBonusDefault(cPedido)

	Local cQuery   := ""
	Local aRetBnDf := Array(6)

	aRetBnDf[1] := 0
	aRetBnDf[2] := 0
	aRetBnDf[3] := 0
	aRetBnDf[4] := 0
	aRetBnDf[5] := 0
	aRetBnDf[6] := 0

	VQ0->(DbSetOrder(2))
	If VQ0->(DbSeek( xFilial("VQ0") + cPedido ) )

		cQuery := "SELECT SUM(VJR_DESCON) AS VJR_DESCON , "
		cQuery += "       SUM(VJR_DESTRI) AS VJR_DESTRI , "
		cQuery += "       SUM(VJR_DESCDC) AS VJR_DESCDC , "
		cQuery += "       SUM(VJR_DESTAT) AS VJR_DESTAT , "
		cQuery += "       SUM(VJR_PERVLR) AS VJR_PERVLR , "
		cQuery += "       SUM(VJR_PERIMP) AS VJR_PERIMP   "
		cQuery += "  FROM " + RetSQLName("VJR")
		cQuery += " WHERE VJR_FILIAL = '" + xFilial("VJR") + "'"
		cQuery += "   AND VJR_CODVQ0 = '" + VQ0->VQ0_CODIGO + "'"
		cQuery += "   AND D_E_L_E_T_ = ' ' "
	
		TcQuery cQuery New Alias "TMPVJR"
			
		If !TMPVJR->(Eof())

			aRetBnDf[1] := TMPVJR->VJR_DESCON
			aRetBnDf[2] := TMPVJR->VJR_DESTRI
			aRetBnDf[3] := TMPVJR->VJR_DESCDC
			aRetBnDf[4] := TMPVJR->VJR_DESTAT
			aRetBnDf[5] := TMPVJR->VJR_PERVLR
			aRetBnDf[6] := TMPVJR->VJR_PERIMP

		EndIf

		TMPVJR->(dbCloseArea())

	EndIf

Return aRetBnDf


Function VA1420085_GeraNFBonus()

	VEIA144()

Return


Function VA1420095_AtualizaPedidoImportado()

	Local oModVQ0    := FWLoadModel("VEIA142")
	Local oModelVJQ  := FWLoadModel("VEIA141")
	Local oModelVV1  := FWLoadModel( 'VEIA070' )
	Local cCodImp    := ""
	Local cGrpOrd    := ""
	Local cOrdNum    := ""
	Local oSqlHelper := Dms_SqlHelper():New()
	Local cCodMar    := FMX_RETMAR(GetNewPar("MV_MIL0006",""))
	Local lVQ0_SEGMOD := ( VQ0->(ColumnPos("VQ0_SEGMOD")) > 0 )
	Local cModeloVei := ""

	If MsgNoYes( STR0036 ) //"O pedido será atualizado de acordo com a ultima importação. Deseja continuar?"

		oModVQ0:SetOperation( MODEL_OPERATION_UPDATE )

		lRet := oModVQ0:Activate()

		If lRet

			cCodImp := oModVQ0:GetValue( "VQ0MASTER", "VQ0_CODVJQ")
			cGrpOrd := Left( Alltrim(oModVQ0:GetValue( "VJRMASTER", "VJR_ORDNUM")),GetSX3Cache("VJQ_ORDGRP","X3_TAMANHO"))
			cOrdNum := Right(Alltrim(oModVQ0:GetValue( "VJRMASTER", "VJR_ORDNUM")),GetSX3Cache("VJQ_ORDNUM","X3_TAMANHO"))

			cQuery := "SELECT " + oSqlHelper:Concat({"VJQ.VJQ_MODNUM","VJQ.VJQ_MODSUF"}) + " VJQMODELO, VJQ.VJQ_ORDCOD "
			cQuery += " FROM " + RetSQLName("VJQ") + " VJQ "
			cQuery += " WHERE VJQ.VJQ_FILIAL = '" + xFilial("VJQ") + "' "
			cQuery += 	" AND VJQ.VJQ_CODIGO = '" + cCodImp + "' "
			cQuery += 	" AND VJQ.VJQ_ORDGRP = '" + cGrpOrd + "' "
			cQuery += 	" AND VJQ.VJQ_ORDNUM = '" + cOrdNum + "' "
			cQuery += 	" AND VJQ.VJQ_RCRDTP = '2' "
			cQuery += 	" AND VJQ.VJQ_ORDTP  = 'B' "
			cQuery += 	" AND VJQ.D_E_L_E_T_ = ' ' "

			TcQuery cQuery New Alias "TMPVJQ"
			
			If !TMPVJQ->(Eof())

				cModeloVei := VA140005K_BuscaModelo( cCodMar, TMPVJQ->VJQMODELO, TMPVJQ->VJQ_ORDCOD , "1" ) // Retorna o Modelo

			EndIf

			If !Empty(cModeloVei)
				oModVQ0:SetValue( "VQ0MASTER", "VQ0_MODVEI", cModeloVei )

				If Empty(oModVQ0:GetValue( "VQ0MASTER", "VQ0_CHAINT"))
					cCriaMaq := VA140005G_GravaMaquina(,;
														oModVQ0:GetValue( "VQ0MASTER", "VQ0_MODVEI"),;
														oModVQ0:GetValue( "VQ0MASTER", "VQ0_CHASSI"),;
														oModVQ0:GetValue( "VQ0MASTER", "VQ0_FILENT"),;
														oModelVV1,;
														oModVQ0:GetValue( "VQ0MASTER", "VQ0_CORVEI"),;
														IIf(lVQ0_SEGMOD,oModVQ0:GetValue( "VQ0MASTER", "VQ0_SEGMOD"),""),;
														cCodMar )

					If !Empty(cCriaMaq)
						oModVQ0:SetValue( "VQ0MASTER", "VQ0_CHAINT", cCriaMaq )
					EndIf
				EndIf

			EndIf

			lRet := VA1420015_CommitData(oModVQ0)

			oModVQ0:DeActivate()

			TMPVJQ->(dbCloseArea())

		Else
			Help("",1,"ACTIVEVQ0",, STR0029 ,1,0)
		EndIf

	EndIf
	
	FreeObj(oModVQ0)

Return

Function VA1420105_AtualizaPedidosAntigos()

	Local oModVQ0 := FWLoadModel("VEIA142")
	Local cQuery  := ""
	Local nPos

	nPos := AVISO(	STR0024 ,; //"Atenção"
					STR0037 + chr(13) + chr(10) + chr(13) + chr(10) + ; //"Todos os pedidos existentes antes da data informada na importação do CGPoll terão suas informações transferidas para a nova tabela."
					STR0038 ,; // "Deseja continuar a operação?"
					{ STR0039 , STR0040 } ,; // "Sim" / "Não"
					3)

	If nPos == 1

		cQuery := "SELECT VQ0.R_E_C_N_O_ VQ0RECNO "
		cQuery += " FROM " + RetSQLName( "VQ0" ) + " VQ0 "
		cQuery += " WHERE VQ0.VQ0_FILIAL = '" + xFilial("VQ0") + "' "
		cQuery += 	" AND VQ0.VQ0_CODVJQ = ' ' "
		cQuery += 	" AND NOT EXISTS( "
		cQuery += 					" SELECT VJR.VJR_CODVQ0 "
		cQuery += 					" FROM " + RetSQLName("VJR") + " VJR "
		cQuery += 					" WHERE VJR.VJR_FILIAL = '" + xFilial("VJR") + "' "
		cQuery += 					  " AND VJR.VJR_CODVQ0 = VQ0.VQ0_CODIGO "
		cQuery += 					  " AND VJR.D_E_L_E_T_ = ' ' "
		cQuery += 					" ) "
		cQuery += 	" AND VQ0.D_E_L_E_T_ = ' ' "

		TcQuery cQuery New Alias "TMPVQ0"

		While !TMPVQ0->(Eof())
			
			VQ0->(DbGoTo(TMPVQ0->VQ0RECNO))

			oModVQ0:SetOperation( MODEL_OPERATION_UPDATE )

			lRet := oModVQ0:Activate()

			If lRet

				oModVQ0:SetValue( "VJRMASTER", "VJR_CODVQ0", oModVQ0:GetValue( "VQ0MASTER", "VQ0_CODIGO") )
				oModVQ0:SetValue( "VJRMASTER", "VJR_STAIMP", "1" )
				oModVQ0:SetValue( "VJRMASTER", "VJR_DATATU", dDataBase )
				oModVQ0:SetValue( "VJRMASTER", "VJR_DATFDD", oModVQ0:GetValue( "VQ0MASTER", "VQ0_DATFDD") )
				oModVQ0:SetValue( "VJRMASTER", "VJR_DATORS", oModVQ0:GetValue( "VQ0MASTER", "VQ0_DATORS") )
				oModVQ0:SetValue( "VJRMASTER", "VJR_EVENTO", oModVQ0:GetValue( "VQ0MASTER", "VQ0_EVENTO") )

				lRet := VA1420015_CommitData(oModVQ0)

				oModVQ0:DeActivate()

			Else

				Help("",1,"ACTIVEVQ0",, STR0029 ,1,0)

			EndIf

			TMPVQ0->(DbSkip())

		EndDo

		TMPVQ0->(DbCloseArea())

	EndIf

	FreeObj(oModVQ0)

Return


Function VA1420115_ReplicarPedido()

	Local aNMCpo     := {}
	Local oVQ0Repl := FWLoadModel( 'VEIA142' )
	Local oVQ0Orig := FWLoadModel( 'VEIA142' )
	Local nJ := 0

	// Campos que não são permitidos replicar
	aNMCpo := { 	"VQ0_CHAINT",;
					"VQ0_CHASSI",;
					"VQ0_FILATE",;
					"VQ0_NUMATE",;
					"VQ0_OBSMEM",;
					"VQ0_ITETRA",;
					"VQ0_CHAINT",;
					"VQ0_STATUS" }

	aCposRep := ExecBlock("VA142REP",.f.,.f.)

	oVQ0Orig:SetOperation( MODEL_OPERATION_VIEW )
	lRetVQ0 := oVQ0Orig:Activate()

	oVQ0Repl:SetOperation( MODEL_OPERATION_INSERT )
	lVQ0 := oVQ0Repl:Activate()

	if lRetVQ0 .and. lVQ0

		For nJ := 1 to Len(aCposRep)
			nPosVet := aScan(aNMCpo,aCposRep[nJ])
			If nPosVet == 0
				cValor := oVQ0Orig:GetValue( "VQ0MASTER", aCposRep[nJ])
				oVQ0Repl:SetValue( "VQ0MASTER", aCposRep[nJ], cValor )
			EndIf
		Next

		oView := FWLoadView("VEIA142")
		oView:SetModel(oVQ0Repl)

		oExecView := FWViewExec():New()
		oExecView:setTitle( STR0043 ) // "Replica de Pedido"
		oExecView:setModel(oVQ0Repl)
		oExecView:setView(oView)
		oExecView:setOperation(MODEL_OPERATION_INSERT)
		oExecView:openView(.t.)

	Else
		Help("",1,"ACTIVEVQ0",,STR0029,1,0)
	EndIf

	oVQ0Orig:DeActivate()
	oVQ0Repl:DeActivate()

Return
