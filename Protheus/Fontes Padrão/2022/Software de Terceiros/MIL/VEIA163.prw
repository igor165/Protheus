#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "VEIA163.CH"

Static cCpoCabVQ1 := "VQ1_CODIGO"
Static cMVMIL0006 := GetNewPar("MV_MIL0006","")

Function VEIA163()

	Local oBrowse

	Private nMaxSeq := 0
	Private M->VQ1_CODIGO := ""

	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VQ1')
	oBrowse:SetDescription( STR0001 ) // "Bônus de Máquina"
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.VEIA163' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.VEIA163' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina Title STR0004 Action 'VA1630085_ExcluiBonus()' OPERATION 5 ACCESS 0 //Excluir
	ADD OPTION aRotina Title STR0005 Action 'VA1630015_LevantaBonus()' OPERATION 3 ACCESS 0 // Levantar
	ADD OPTION aRotina Title STR0006 Action 'VA1630045_LiberaBonus()' OPERATION 4 ACCESS 0 // Libera p/ Gerar NF
	ADD OPTION aRotina Title STR0007 Action 'VA1630065_CancelaBonus()' OPERATION 4 ACCESS 0 // Cancelar
	ADD OPTION aRotina Title STR0008 Action 'VA1630075_AtualizaAtendimento()' OPERATION 4 ACCESS 0 // Atualiza Atendimento

Return aRotina

Static Function ModelDef()
	Local oModel
	Local bAuxInit
	Local oStruVQ1Cab := FWFormStruct( 1, 'VQ1', { |cCampo| ALLTRIM(cCampo) $ cCpoCabVQ1 } )
	Local oStruVQ1    := FWFormStruct( 1, 'VQ1' )

	oStruVQ1:SetProperty( 'VQ1_SEQUEN' , MODEL_FIELD_INIT , { || VA1630035_SequenciaVZP() } )

	oStruVQ1:AddTrigger( "VQ1_VLRINI", "VQ1_VLRBAS", {|| .T.}, { |oModel| VA1630105_CalculosBonus(oModel,1) } )
	
	oStruVQ1:AddTrigger( "VQ1_DESCON", "VQ1_VLRBAS", {|| .T.}, { |oModel| VA1630105_CalculosBonus(oModel,2) } )

	oStruVQ1:AddTrigger( "VQ1_DESCDC", "VQ1_VLRBAS", {|| .T.}, { |oModel| VA1630105_CalculosBonus(oModel,3) } )

	oStruVQ1:AddTrigger( "VQ1_VLRINI", "VQ1_VLRTOT", {|| .T.}, { |oModel| VA1630105_CalculosBonus(oModel,4) } )

	oStruVQ1:AddTrigger( "VQ1_PERVLR", "VQ1_VLRTOT", {|| .T.}, { |oModel| VA1630105_CalculosBonus(oModel,5) } )

	oStruVQ1:AddTrigger( "VQ1_VLRTOT", "VQ1_PERVLR", {|| .T.}, { |oModel| VA1630105_CalculosBonus(oModel,6) } )

	oStruVQ1:AddTrigger( "VQ1_PERIMP", "VQ1_VLRLIQ", {|| .T.}, { |oModel| VA1630105_CalculosBonus(oModel,7) } )

	oStruVQ1:AddTrigger( "VQ1_VLRLIQ", "VQ1_PERIMP", {|| .T.}, { |oModel| VA1630105_CalculosBonus(oModel,8) } )

	oStruVQ1:SetProperty('VQ1_STATUS', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'1'"))		//Ini Padrão

	oModel := MPFormModel():New('VEIA163',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)

	oModel:AddFields( 'VQ1MASTER', /*cOwner*/, oStruVQ1Cab, /* <bPre> */ , /* <bPost> */ , /* <bLoad>  { |oModel| loadCab(oModel) }*/ )
	oModel:GetModel( 'VQ1MASTER' ):SetDescription( STR0009 ) // Dados do Bonus Cabeçalho

	oModel:AddGrid( 'VQ1DETAIL', 'VQ1MASTER', oStruVQ1)
	oModel:SetDescription( STR0010 ) // Modelo de dados do Modelo
	oModel:GetModel( 'VQ1DETAIL' ):SetDescription( STR0011 ) // Dados do Bonus Detalhes
	oModel:GetModel( 'VQ1DETAIL' ):SetOptional( .F. )

	oModel:SetRelation('VQ1DETAIL', { { 'VQ1_FILIAL' , 'xFilial("VQ1")' } , { 'VQ1_CODIGO' , 'VQ1_CODIGO' } }, VQ1->( IndexKey(1) ) )
	oModel:SetPrimaryKey( { "VQ1_FILIAL", "VQ1_CODIGO" , "VQ1_SEQUEN" } ) 

Return oModel

Static Function ViewDef()

	Local oModel := FWLoadModel( 'VEIA163' )
	
	Local oStruVQ1Cab := FWFormStruct( 2, 'VQ1' , { |cCampo| ALLTRIM(cCampo) $ cCpoCabVQ1 } )
	Local oStruVQ1    := FWFormStruct( 2, 'VQ1' , { |cCampo| ! ALLTRIM(cCampo) $ cCpoCabVQ1 } )
	Local oView

	If IsInCallStack("VEIA162")
		oStruVQ1Cab:SetProperty( '*' , MVC_VIEW_CANCHANGE, .f.)

		oStruVQ1:SetProperty( 'VQ1_VLRBAS' , MVC_VIEW_CANCHANGE, .f.)
		oStruVQ1:SetProperty( 'VQ1_VLRTOT' , MVC_VIEW_CANCHANGE, .t.)
		oStruVQ1:SetProperty( 'VQ1_VLRLIQ' , MVC_VIEW_CANCHANGE, .t.)
	EndIf

	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:CreateHorizontalBox( 'TELAVQ1CAB' , 20 )
	oView:AddField( 'VIEW_VQ1CAB', oStruVQ1Cab, 'VQ1MASTER' )
	oView:EnableTitleView('VIEW_VQ1CAB', STR0012 ) //Pedido de compra de máquinas

	oView:CreateHorizontalBox( 'TELAVQ1' , 80 )
	oView:AddGrid( 'VIEW_VQ1', oStruVQ1, 'VQ1DETAIL' )
	oView:EnableTitleView('VIEW_VQ1', STR0013 ) //Bônus de Máquina

	oView:SetOwnerView( 'VIEW_VQ1CAB', 'TELAVQ1CAB' )
	oView:SetOwnerView( 'VIEW_VQ1', 'TELAVQ1' )

	oView:SetAfterViewActivate( {|oView| afterViewActivate(oView)} )

Return oView

Static Function afterViewActivate(oView)

	if oView:GetOperation() == 3
		oView:GetModel("VQ1MASTER"):SetValue("VQ1_CODIGO",VQ0->VQ0_CODIGO)
		oView:Refresh()
	EndIf

Return

Function VA1630035_SequenciaVZP()

	Local oModel := FWModelActive()
	
	Local oMVQ1
	Local nQtdLinha
	Local cTipo

	Local nTamSeq := GetSX3Cache("VQ1_SEQUEN","X3_TAMANHO")
	Local cSequen
	Local nLinha

	If oModel == NIL .or. oModel:cID <> "VEIA163"
		cQuery := "SELECT MAX(VQ1_SEQUEN) "
		cQuery += "FROM " + RetSqlName("VQ1") + " VQ1 "
		cQuery += "WHERE VQ1.VQ1_FILIAL = '" + xFilial("VQ1") + "' "
		cQuery +=  " AND VQ1.VQ1_CODIGO = '" + VQ0->VQ0_CODIGO + "' "

		cSequen := FM_SQL(cQuery)

		If Empty(cSequen)
			cSequen := StrZero(0,nTamSeq)
		EndIf

		cSequen := Soma1(cSequen)

	Else
		oMVQ1  := oModel:GetModel("VQ1DETAIL")
		nQtdLinha  := oMVQ1:Length()
		cTipo := FWFldGet("VQ1_CODIGO")

		cSequen := oMVQ1:GetValue('VQ1_SEQUEN')

		For nLinha := 1 to nQtdLinha

			If oMVQ1:GetValue('VQ1_SEQUEN',nLinha) >= cSequen
				cSequen := Soma1(oMVQ1:GetValue('VQ1_SEQUEN',nLinha))
			EndIf

		Next nLinha
	EndIf

Return cSequen

Static Function loadCab(oModel)

	Local aLoad := {}
	Local aAuxFields := oModel:GetStruct():GetFields()
	Local nPosField

	RegToMemory("VQ1",INCLUI)

	For nPosField := 1 to Len(aAuxFields)
		AADD( aLoad, &("M->" + aAuxFields[nPosField, 3] ) )
	Next nPosField

	M->VQ1_CODIGO := VQ0->VQ0_CODIGO

Return aLoad


/*/{Protheus.doc} VA1630015_LevantaBonus
Levantamento dos Bonus

@author Renato
@since 01/04/2019
@param cTpLev, caracter - Levantamento: 0=Faz Pergunta para o Usuario decidir / 1=Nao Pergunta e levanta o Bonus apagando os Existentes / 2=Nao Pergunta e levanta o Bonus NAO apagando os Existentes
@param lCriaVQ1, logico - Cria VQ1 automaticamente
@param lRetVQ1, logico - Retorna Vetor com os VQ1 do Pedido ?
@param dDtRefV, data - Data do Levantamento Bonus Venda
@param dDtRefC, data - Data do Levantamento Bonus Compra
@param cDatVer, caracter - Data de Verificacao 0-Venda / 1-Compra / 2-Ambas
@param lDtPreenc, logico - Utiliza a Data de Venda enviada para função caso não exista a Data marcado como Vendido e Data de Entrega
/*/
Function VA1630015_LevantaBonus( cTpLev , lCriaVQ1 , lRetVQ1 , dDtRefV , dDtRefC , cDatVer , lDtPreenc )

	Local nVlrIni   := 0
	Local lOk       := .t.
	Local lDel      := .f.
	Local ni        := 0
	Local aExiste   := DMS_SqlHelper():New()
	Local aRecVQ1 := {}
	Local aCpoVQ1 := {}
	Local aRetVQ1 := {}
	Local nRecVQ1 := 0
	Local lVQ0_SEGMOD := ( VQ0->(ColumnPos("VQ0_SEGMOD")) > 0 )
	Local lVQ1_EVENTO := ( VQ1->(ColumnPos("VQ1_EVENTO")) > 0 )

	Local aBonuDef := {}

//% Default
	Private nPDcCon := 0 // Desc.Concessao
	Private nPDcTri := 0 // Desc.Tributacao
	Private nPDcCdc := 0 // Desc.Condicao
	Private nPDcTat := 0 // Desc.Tatico
	Private nPBonus := 0 // Bonus
	Private nPImpos := 0 // Prev.Impostos
	Private nVlrIni := 0

	Default cTpLev   := "0" // 0=Faz Pergunta para o Usuario decidir / 1=Nao Pergunta e levanta o Bonus apagando os Existentes / 2=Nao Pergunta e levanta o Bonus NAO apagando os Existentes
	Default lCriaVQ1 := .t. // Cria VQ1 automaticamente
	Default lRetVQ1  := .f. // Retorna Vetor com os VQ1 do Pedido ?
	Default dDtRefV  := VQ0->VQ0_DATVEN // Data do Levantamento Bonus Venda
	Default dDtRefC  := VQ0->VQ0_DATPED // Data do Levantamento Bonus Compra
	Default cDatVer  := "012" // 0-Venda / 1-Compra / 2-Ambas
	Default lDtPreenc := .f. // Utiliza a Data de Venda enviada para função caso não exista a Data marcado como Vendido e Data de Entrega

	aBonuDef := VA1420075_LevantaValoresBonusDefault(VQ0->VQ0_NUMPED)

	nPDcCon := aBonuDef[1]
	nPDcTri := aBonuDef[2]
	nPDcCdc := aBonuDef[3]
	nPDcTat := aBonuDef[4]
	nPBonus := aBonuDef[5]
	nPImpos := aBonuDef[6]

	cQuery := "SELECT VQ1.R_E_C_N_O_ VQ1RECNO "
	cQuery += " FROM " + RetSqlName("VQ1") + " VQ1 "
	cQuery += " WHERE VQ1.VQ1_FILIAL = '" + VQ0->VQ0_FILIAL +"' "
	cQuery += 	" AND VQ1.VQ1_CODIGO = '" + VQ0->VQ0_CODIGO +"' "
	cQuery += 	" AND VQ1.D_E_L_E_T_=' '"

	If FM_SQL(cQuery) > 0 // Verificar se ja existe NF para o Bonus

		lOk := .f.
		Do Case
			Case cTpLev == "0" // Faz Pergunta para o Usuario decidir
				nOpcAviso := Aviso( STR0014 ,; // "Atenção"
							STR0015 + CHR(13)+CHR(10) + CHR(13)+CHR(10) + ; // "Já existem Bônus cadastrados para este Pedido! Ações Possíveis:"
							"["+ STR0016 +"]   - " + STR0017 + CHR(13)+CHR(10) + CHR(13)+CHR(10)+;  // "Apagar" / "Levantar os Bônus e apagar os já existentes que ainda não Geraram NF ou que não foram Cancelados."
							"["+ STR0018 +"] - " + STR0019 ,; // "Não Apagar" / "Levantar os Bônus e não apagar os já existentes."
							{ STR0016 ,; // "Apagar"
							  STR0018 ,; // "Não Apagar"
							  STR0007},2) // "Cancelar"
			Case cTpLev == "1" // Nao Pergunta e levanta o Bonus apagando os Existentes
				nOpcAviso := 1
			Case cTpLev == "2" // Nao Pergunta e levanta o Bonus NAO apagando os Existentes
				nOpcAviso := 2
		EndCase

		If nOpcAviso == 1 // Levantar Bônus e APAGAR os Bônus existentes
			lOk  := .t.
			lDel := .t.
		ElseIf nOpcAviso == 2 // Levantar Bônus e NÂO APAGAR os Bônus existentes
			lOk  := .t.
			lDel := .f.
		Else // Cancelar a operação
			Return
		Endif

	EndIf

	If lOk
		If lDel // Deletar todos os bonus ja gravados, serao levantados os bonus novamente

			TcQuery cQuery New Alias "TMPVQ1"

			fLimpaVetor(aRecVQ1)
			aRecVQ1 := {}

			While !TMPVQ1->(Eof()) // Apaga bonus que nao gerou NF e nem foi cancelado

				VQ1->(DbGoTo(TMPVQ1->VQ1RECNO))

				If VQ1->VQ1_STATUS <> "3" .and. VQ1->VQ1_STATUS <> "4"

					aAdd(aRecVQ1,{VQ1->(RecNo()),aClone(aCpoVQ1)})

				EndIf

				TMPVQ1->(DbSkip())

			EndDo

			TMPVQ1->(DbCloseArea())

			If Len(aRecVQ1) > 0
				VA1630055_AtualizaBonus( aRecVQ1 , MODEL_OPERATION_DELETE )
			EndIf

			nVlrIni := FS_VLRVEI()

		Endif

		If VQ0->VQ0_VALINI > 0
			nVlrIni := VQ0->VQ0_VALINI
		EndIf

		VV1->(DbSetOrder(1))
		VV1->(DbSeek(xFilial("VV1")+VQ0->VQ0_CHAINT))
		VV2->(DbSetOrder(1))
		VV2->(DbSeek(xFilial("VV2")+VQ0->VQ0_CODMAR+VQ0->VQ0_MODVEI+IIf(lVQ0_SEGMOD,VQ0->VQ0_SEGMOD,"")))

		aBonVei := FS_VM190BON( dDtRefV , dDtRefC , cDatVer , lDtPreenc ) // Levanta Bonus passando as Datas e qual data verificar. Tambem se utiliza a Data de Venda enviada para função caso não exista a Data marcado como Vendido e Data de Entrega

		If len(aBonVei) > 0

			nVlrDef := nVlrIni // Valor Defult da variavel nVlrIni

			fLimpaVetor(aRecVQ1)
			aRecVQ1 := {}

			cQuery := "SELECT MAX(VQ1_SEQUEN)"
			cQuery += " FROM " + RetSQLName("VQ1") + " "
			cQuery += " WHERE VQ1_FILIAL = '" + xFilial("VQ1") + "' "
			cQuery += 	" AND VQ1_CODIGO = '" + VQ0->VQ0_CODIGO + "'"

			cProxSeq := FM_SQL(cQuery)

			If Empty(cProxSeq)
				cProxSeq := "000"
			EndIf

			For ni := 1 to len(aBonVei)

				fLimpaVetor(aCpoVQ1)
				aCpoVQ1 := {}

				cQuery := "SELECT VQ1.R_E_C_N_O_ "
				cQuery += " FROM " + RetSQLName("VQ1") + " VQ1 "
				cQuery += " WHERE VQ1.VQ1_FILIAL = '" + xFilial("VQ1") + "' "
				cQuery += 	" AND VQ1.VQ1_CODIGO = '" + VQ0->VQ0_CODIGO + "' "
				cQuery += 	" AND VQ1.VQ1_CODBON = '" + aBonVei[ni,1] + "'"
				cQuery += 	" AND VQ1.D_E_L_E_T_ = ' ' "
				nRecVQ1 := FM_SQL(cQuery)

				If nRecVQ1 > 0 // Existe VQ1
					If lRetVQ1
						VQ1->(DbGoto(nRecVQ1))
						aAdd( aCpoVQ1, {"VQ1_SEQUEN", VQ1->VQ1_SEQUEN } )
						aAdd( aCpoVQ1, {"VQ1_CODBON", VQ1->VQ1_CODBON } )
						aAdd( aCpoVQ1, {"VQ1_VLRINI", VQ1->VQ1_VLRINI } )
						aAdd( aCpoVQ1, {"VQ1_STATUS", VQ1->VQ1_STATUS } )
						aAdd( aCpoVQ1, {"VQ1_DESCON", VQ1->VQ1_DESCON } )
						aAdd( aCpoVQ1, {"VQ1_DESTRI", VQ1->VQ1_DESTRI } )
						aAdd( aCpoVQ1, {"VQ1_DESCDC", VQ1->VQ1_DESCDC } )
						aAdd( aCpoVQ1, {"VQ1_DESTAT", VQ1->VQ1_DESTAT } )
						aAdd( aCpoVQ1, {"VQ1_VLRBAS", VQ1->VQ1_VLRBAS } )
						aAdd( aCpoVQ1, {"VQ1_VLRTOT", VQ1->VQ1_VLRTOT } )
						aAdd( aCpoVQ1, {"VQ1_PERIMP", VQ1->VQ1_PERIMP } )
						aAdd( aCpoVQ1, {"VQ1_VLRLIQ", VQ1->VQ1_VLRLIQ } )
						If lVQ1_EVENTO
							aAdd( aCpoVQ1, {"VQ1_EVENTO", VQ1->VQ1_EVENTO } )
						EndIf
						aAdd(aRetVQ1,{nRecVQ1,aClone(aCpoVQ1)})
					EndIf
					//
					Loop // Pula registro ja existente
					//
				EndIf

				nVlrIni := nVlrDef // Volta conteudo padrao da variavel nVlrIni

				If aExiste:ExistTable(RetSqlName("VR3"))

					cQuery := "SELECT VR3_DESCON, "
					cQuery += 		" VR3_DESCDC, "
					cQuery += 		" VR3_DESTRI, "
					cQuery += 		" VR3_DESTAT, "
					cQuery += 		" VR3_PERIMP, "
					cQuery += 		" VR3_PERBON "
					cQuery += " FROM " + RetSqlName("VR3") + " VR3 "
					cQuery += " WHERE VR3.VR3_FILIAL = '" + xFilial("VR3") + "' "
					cQuery += 	" AND VR3.VR3_CODMAR = '" + VQ0->VQ0_CODMAR + "' "
					cQuery += 	" AND VR3.VR3_MODVEI = '" + VQ0->VQ0_MODVEI + "' "
					cQuery += 	" AND VR3.D_E_L_E_T_ = ' '"

					TcQuery cQuery New Alias "TMPVR3"

					If !TMPVR3->(Eof())
						nPerDCc := TMPVR3->(VR3_DESCON)
						nPerDCd := TMPVR3->(VR3_DESCDC)
						nPerDTr := TMPVR3->(VR3_DESTRI)
						nPerDTa := TMPVR3->(VR3_DESTAT)
						nPerImp := TMPVR3->(VR3_PERIMP)
						nPerBon := TMPVR3->(VR3_PERBON)
					Else
						nPerDCc := nPDcCon
						nPerDCd := nPDcCdc
						nPerDTr := nPDcTri
						nPerDTa := nPDcTat
						nPerImp := nPImpos
						nPerBon := nPBonus
					EndIf

					TMPVR3->(DbCloseArea())

				Else

					nPerDCc := nPDcCon
					nPerDCd := nPDcCdc
					nPerDTr := nPDcTri
					nPerDTa := nPDcTat
					nPerImp := nPImpos
					nPerBon := nPBonus

				EndIf

				nVlrBas := nVlrIni
				nVlrBas := ( nVlrBas - ( ( nPerDCc * nVlrIni ) / 100 ) )
				nVlrBas := ( nVlrBas - ( ( nPerDCd * nVlrIni ) / 100 ) )

				If aBonVei[ni,4] > 0 // Valor Fixo do Bonus
					nVlrBon := aBonVei[ni,4]
					nVlrLiq := aBonVei[ni,4]
					nVlrIni := aBonVei[ni,4]
					nPerBon := 100
					nPerDCc := 0
					nPerDCd := 0
					nPerDTr := 0
					nPerDTa := 0
					nPerImp := 0
				Else // Calcular o Valor do Bonus pelo Percentual
					If aBonVei[ni,3] > 0
						nPerBon := aBonVei[ni,3]
					EndIf
					nVlrBon := round(( ( nVlrBas * nPerBon ) / 100 ),2)
					nVlrLiq := round( nVlrBon - ( ( nVlrBon * nPerImp ) / 100 ),2)
				EndIf

				cProxSeq := Soma1(cProxSeq)

				aAdd( aCpoVQ1, {"VQ1_SEQUEN", cProxSeq } )
				aAdd( aCpoVQ1, {"VQ1_CODBON", aBonVei[ni,1] } )
				aAdd( aCpoVQ1, {"VQ1_VLRINI", nVlrIni } )
				aAdd( aCpoVQ1, {"VQ1_STATUS", "1" } ) // Gravado
				aAdd( aCpoVQ1, {"VQ1_DESCON", nPerDCc } )
				aAdd( aCpoVQ1, {"VQ1_DESTRI", nPerDTr } )
				aAdd( aCpoVQ1, {"VQ1_DESCDC", nPerDCd } )
				aAdd( aCpoVQ1, {"VQ1_DESTAT", nPerDTa } )
				aAdd( aCpoVQ1, {"VQ1_VLRBAS", nVlrBas } )
				aAdd( aCpoVQ1, {"VQ1_PERVLR", nPerBon } )
				aAdd( aCpoVQ1, {"VQ1_VLRTOT", nVlrBon } )
				aAdd( aCpoVQ1, {"VQ1_PERIMP", nPerImp } )
				aAdd( aCpoVQ1, {"VQ1_VLRLIQ", nVlrLiq } )
				If lVQ1_EVENTO
					aAdd( aCpoVQ1, {"VQ1_EVENTO", aBonVei[ni,6] } )
				EndIf

				aAdd(aRecVQ1,{0,aClone(aCpoVQ1)})
				If lRetVQ1
					aAdd(aRetVQ1,{0,aClone(aCpoVQ1)})
				EndIf

			Next

			If lCriaVQ1 .and. Len(aRecVQ1) > 0
				VA1630055_AtualizaBonus( aRecVQ1 , MODEL_OPERATION_INSERT )
			EndIf

		EndIf
	EndIf

Return aClone(aRetVQ1)

Static Function VA1630025_CommitData(oModel)

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

Static Function FS_VLRVEI(nLinha)
	Local lVQ0_SEGMOD := ( VQ0->(ColumnPos("VQ0_SEGMOD")) > 0 )
	VV1->(DbSetOrder(2))
	If !Empty(VQ0->VQ0_CHASSI) .and. VV1->(DbSeek(xFilial("VV1")+VQ0->VQ0_CHASSI))
		VV1->(DbSetOrder(1))
		nVlrIni := FGX_VLRSUGV( VV1->VV1_CHAINT , VV1->VV1_CODMAR , VV1->VV1_MODVEI , VV1->VV1_SEGMOD , VV1->VV1_CORVEI , .t. )
	Else
		VV1->(DbSetOrder(1))
		nVlrIni := FGX_VLRSUGV( "" , VQ0->VQ0_CODMAR , VQ0->VQ0_MODVEI , IIf(lVQ0_SEGMOD,VQ0->VQ0_SEGMOD,"") , VQ0->VQ0_CORVEI , .t. )
	EndIf

Return(nVlrIni)

/*/{Protheus.doc} FS_VM190BON
Faz o SQL do VZQ/VZT para levantar os Bonus - chamada da funcao VA1630015_LevantaBonus

@author Renato
@since 01/04/2019
@param dDtRefV, data - Data do Levantamento Bonus Venda
@param dDtRefC, data - Data do Levantamento Bonus Compra
@param cDatVer, caracter - Data de Verificacao 0-Venda / 1-Compra / 2-Ambas
@param lDtPreenc, logico - Utiliza a Data enviada para função caso a Data de Venda nao exista
/*/
Static Function FS_VM190BON( dDtRefV , dDtRefC , cDatVer , lDtPreenc )

	Local cQuery      := ""
	Local cQAlSQL     := "SQLVZQVZT"
	Local ni          := 0
	Local cOpcSel     := ""
	Local cOpcFab     := ""
	Local aVetBon     := {}
	Local nPerBon     := 0
	Local nVlrBon     := 0
	Local lVZQ_CHASSI := ( VZQ->(ColumnPos("VZQ_CHASSI")) > 0 )
	Local lVZQ_BONPOR := ( VZQ->(ColumnPos("VZQ_BONPOR")) > 0 )
	Local lVZQ_DINMVD := ( VZQ->(ColumnPos("VZQ_DINMVD")) > 0 ) .and. ( cMVMIL0006 == "JD" )
	Local lVZQ_CDCAMP := ( VZQ->(ColumnPos("VZQ_CDCAMP")) > 0 )
	Local lVZQ_EVENTO := ( VZQ->(ColumnPos("VZQ_EVENTO")) > 0 )

	Local cUF         := ""
	Local aUF         := {"AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG","PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO"}
	Local aFilAtu     := {}
	Local nRecSM0     := SM0->(RecNo())
	Local cSlvFilAnt  := cFilAnt
	Default dDtRefV   := VQ0->VQ0_DATVEN
	Default dDtRefC   := VQ0->VQ0_DATPED
	Default cDatVer   := "012" // 0-Venda / 1-Compra / 2-Ambas
	Default lDtPreenc  := .f. // Utiliza a Data enviada para função caso a Data de Venda nao exista

	If lVZQ_BONPOR // Bonus por ( 1= Geral(Normal) / 2=Por UF )

		If Empty(VV1->VV1_FILENT)
			Return (aVetBon)
		EndIf

		cFilAnt := VV1->VV1_FILENT
		aFilAtu := FWArrFilAtu()

		If SM0_RECNO > 0 .and. aFilAtu[SM0_RECNO] > 0
			DbSelectArea("SM0")
			DbGoTo(aFilAtu[SM0_RECNO])
		EndIf

		cUF := IIf(!Empty(SM0->M0_ESTCOB),SM0->M0_ESTCOB,SM0->M0_ESTENT) // Pegar UF da Filial de Entrada do Veiculo ( VV1_FILENT )

		DbGoTo(nRecSM0)

		cFilAnt := cSlvFilAnt

		If !Empty(cUF) .and. aScan(aUF,cUF) <= 0
			MsgStop( STR0019 + " " + VV1->VV1_FILENT , STR0014 ) // UF não encontrada da Filial / Atencao
			Return(aVetBon)
		EndIf

	EndIf

	If Empty(dDtRefV)
		dDtRefV := dDataBase
	EndIf

	If Empty(dDtRefC)
		dDtRefC := dDataBase
	EndIf

	cQuery := "SELECT VZQ.VZQ_CODBON , VZQ.VZQ_PERBON , VZQ.VZQ_VALBON , VZT.VZT_PERBON , VZT.VZT_VALBON , VZT.VZT_OPCION, VZQ.VZQ_DESCRI , VZT.VZT_OPCFAB "

	If lVZQ_BONPOR
		cQuery += ", VZQ.VZQ_BONPOR , VZQ.VZQ_VALBUF , VZQ.VZQ_PERBUF , VZT.VZT_VALBUF , VZT.VZT_PERBUF "
	EndIf

	If lVZQ_CDCAMP
		cQuery += ", VZQ.VZQ_CDCAMP "
	EndIf

	If lVZQ_EVENTO
		cQuery += ", VZQ.VZQ_EVENTO "
	EndIf

	cQuery += "FROM "+RetSqlName("VZQ")+" VZQ "
	cQuery += "INNER JOIN "+RetSqlName("VZT")+" VZT ON (VZT.VZT_FILIAL='"+xFilial("VZT")+"' AND VZT.VZT_CODBON=VZQ.VZQ_CODBON AND VZT.D_E_L_E_T_=' ') "
	cQuery += "WHERE VZQ.VZQ_FILIAL='"+xFilial("VZQ")+	"' AND ("
	cQuery += "(VZT.VZT_CODMAR='"+VV1->VV1_CODMAR+"' AND VZT.VZT_GRUMOD='"+VV2->VV2_GRUMOD+"' AND VZT.VZT_MODVEI='"+VV1->VV1_MODVEI+"' ) OR "
	cQuery += "(VZT.VZT_CODMAR='"+VV1->VV1_CODMAR+"' AND VZT.VZT_GRUMOD='"+VV2->VV2_GRUMOD+"' AND VZT.VZT_MODVEI=' ' ) OR "
	cQuery += "(VZT.VZT_CODMAR='"+VV1->VV1_CODMAR+"' AND VZT.VZT_GRUMOD=' ' AND VZT.VZT_MODVEI=' ' ) ) AND "

	If !Empty(VV1->VV1_FABMOD)
		cQuery += "( VZT.VZT_FABMOD='"+VV1->VV1_FABMOD+"' OR VZT.VZT_FABMOD=' ') AND "
	EndIf

	cQuery += "VZQ.VZQ_COMVEN IN ('1',' ') AND " // Bonus de Venda

	If lVZQ_CHASSI

		If !Empty(VV1->VV1_CHASSI) // Bonus por Chassi
			cQuery += "( VZQ.VZQ_CHASSI=' ' OR VZQ.VZQ_CHASSI='"+VV1->VV1_CHASSI+"' ) AND "
		Else
			cQuery += "VZQ.VZQ_CHASSI=' ' AND "
		EndIf

	EndIf

	cQuery += "( "
	If "0" $ cDatVer // Verifica Data Venda
		cQuery += "( VZQ.VZQ_DATVER='0' AND VZQ.VZQ_DATINI<='"+dtos(dDtRefV) +"' AND VZQ.VZQ_DATFIN>='"+dtos(dDtRefV) +"' ) " // Filtra Venda
		If "1" $ cDatVer .or. "2" $ cDatVer
			cQuery += " OR "
		EndIf
	EndIf
	If "1" $ cDatVer // Verifica Data Compra
		cQuery += "( VZQ.VZQ_DATVER='1' AND VZQ.VZQ_DINCPA<='"+dtos(dDtRefC) +"' AND VZQ.VZQ_DFICPA>='"+dtos(dDtRefC) +"' ) " // Filtra Compra
		If "2" $ cDatVer
			cQuery += " OR "
		EndIf
	EndIf
	If "2" $ cDatVer // Verifica Ambas as Datas
		cQuery += "( VZQ.VZQ_DATVER='2' AND VZQ.VZQ_DATINI<='"+dtos(dDtRefV) +"' AND VZQ.VZQ_DATFIN>='"+dtos(dDtRefV) +"' AND VZQ.VZQ_DINCPA<='"+dtos(dDtRefC) +"' AND VZQ.VZQ_DFICPA>='"+dtos(dDtRefC) +"' ) " // Filtra Venda e Compra
	EndIf
	cQuery += ") "

	If lVZQ_DINMVD
		If lDtPreenc .and. Empty(VQ0->VQ0_DATVEN) // Utiliza a Data enviada para função caso a Data de Venda nao exista
			cQuery += "AND ( VZQ.VZQ_DINMVD = '  ' OR '" + dtos(dDtRefV) + "' BETWEEN VZQ.VZQ_DINMVD AND VZQ.VZQ_DFIMVD) "
		Else
			cQuery += "AND ( VZQ.VZQ_DINMVD = '  ' OR '" + dtos(VQ0->VQ0_DATVEN) + "' BETWEEN VZQ.VZQ_DINMVD AND VZQ.VZQ_DFIMVD) "
		EndIf
		If lDtPreenc .and. Empty(VQ0->VQ0_DATENT) // Utiliza a Data enviada para função caso a Data de Entrega nao exista
			cQuery += "AND ( VZQ.VZQ_DINENT = '  ' OR '" + dtos(dDtRefV) + "' BETWEEN VZQ.VZQ_DINENT AND VZQ.VZQ_DFIENT) "
		Else
			cQuery += "AND ( VZQ.VZQ_DINENT = '  ' OR '" + dtos(VQ0->VQ0_DATENT) + "' BETWEEN VZQ.VZQ_DINENT AND VZQ.VZQ_DFIENT) "
		EndIf
	EndIf

	VJR->( DbSeek( xFilial("VJR") + VQ0->VQ0_CODIGO ) )

	If lVZQ_CDCAMP
		cQuery += "AND ( VZQ.VZQ_DINFDD = '  ' OR '" + dtos(VJR->VJR_DATFDD) + "' BETWEEN VZQ.VZQ_DINFDD AND VZQ.VZQ_DFIFDD) "
		cQuery += "AND ( VZQ.VZQ_DINORS = '  ' OR '" + dtos(VJR->VJR_DATORS) + "' BETWEEN VZQ.VZQ_DINORS AND VZQ.VZQ_DFIORS) "
	EndIf

	If lVZQ_EVENTO
		cQuery += "AND ( VZQ.VZQ_EVENTO='"+VJR->VJR_EVENTO+"' " // Evento igual
		If !Empty(VJR->VJR_EVENTO)
			cQuery += "OR VZQ.VZQ_EVENTO=' ' " // Evento em branco
		EndIf
		cQuery += ") "
	EndIf

	cQuery += "AND ( VZT.VZT_ESTVEI='0' OR VZT.VZT_ESTVEI=' ' ) AND VZQ.D_E_L_E_T_=' ' ORDER BY VZQ.VZQ_CODBON" // Veiculo Novo

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )

	While !( cQAlSQL )->( Eof() )

		If !Empty(VV1->VV1_OPCFAB)
			For ni := 1 to 5
				cOpcSel := ""
				If !Empty(Substr(( cQAlSQL )->( VZT_OPCION ),(ni*3+1)-3,3))
					cOpcSel := Substr(( cQAlSQL )->( VZT_OPCION ),(ni*3+1)-3,3)
					If !( cOpcSel $ VV1->VV1_OPCFAB )
						( cQAlSQL )->( DbSkip() )//desconsidera o veiculo
						Loop
					EndIf
				EndIf
			Next
		EndIf

		//verificar se o veiculo eh uma excessao do bonus se for nao adicionar no array.
		If !Empty(VV1->VV1_CHASSI)
			VZR->(DbSetOrder(1))
			If VZR->(DbSeek(xFilial("VZR") + ( cQAlSQL )->( VZQ_CODBON ) + VV1->VV1_CHASSI ))
				( cQAlSQL )->( DbSkip() )
				Loop
			EndIf
		EndIf

		If !Empty( ( cQAlSQL )->( VZT_OPCFAB) )

			lRetorno := .f.
			For ni := 1 to 7
				cOpcFab := ""
				If !Empty(Substr(( cQAlSQL )->( VZT_OPCFAB ),(ni*5+1)-5,5))
					cOpcFab := Substr(( cQAlSQL )->( VZT_OPCFAB ),(ni*5+1)-5,5)
					If VA1630095_OpcionaisBonusPedido(cOpcFab)
						lRetorno := .t.
					EndIf
				EndIf
			Next

			if !lRetorno
				( cQAlSQL )->( DbSkip() )
				Loop
			Endif

		EndIf

		If !lVZQ_BONPOR .or. ( cQAlSQL )->( VZQ_BONPOR ) <> "2" // Nao tem Bonus por UF ou se trata de Bonus Normal

			nPerBon := 0

			nVlrBon := ( cQAlSQL )->( VZT_VALBON ) // 1o. Valor VZT

			If nVlrBon == 0

				nPerBon := ( cQAlSQL )->( VZT_PERBON ) // 2o. % VZT

				If nPerBon == 0

					nVlrBon := ( cQAlSQL )->( VZQ_VALBON ) // 3o. Valor VZQ

					If nVlrBon == 0
						nPerBon := ( cQAlSQL )->( VZQ_PERBON ) // 4o. % VZQ
					EndIf

				EndIf

			EndIf

		Else // Bonus por UF

			nPerBon := 0

			nVlrBon := FS_BUSCAUF("1",cUF,( cQAlSQL )->( VZT_VALBUF )) // 1o. Valor VZT

			If nVlrBon == 0

				nPerBon := FS_BUSCAUF("2",cUF,( cQAlSQL )->( VZT_PERBUF )) // 2o. % VZT

				If nPerBon == 0

					nVlrBon := FS_BUSCAUF("1",cUF,( cQAlSQL )->( VZQ_VALBUF )) // 3o. Valor VZQ

					If nVlrBon == 0
						nPerBon := FS_BUSCAUF("2",cUF,( cQAlSQL )->( VZQ_PERBUF )) // 4o. % VZQ
					EndIf

				EndIf

			EndIf

		EndIf

		aAdd(aVetBon,{	( cQAlSQL )->( VZQ_CODBON ),;
						( cQAlSQL )->( VZQ_DESCRI ),;
						nPerBon,;
						nVlrBon,;
						IIf(lVZQ_CDCAMP,( cQAlSQL )->( VZQ_CDCAMP ),""),;
						IIf(lVZQ_EVENTO,( cQAlSQL )->( VZQ_EVENTO ),"")})

		( cQAlSQL )->( DbSkip() )
	EndDo

	( cQAlSQL )->( dbCloseArea() )

	DbSelectArea("VZQ")

Return(aVetBon)


Static Function FS_BUSCAUF(cTp,cUF,cString)

	Local nX   := ( AT(cUF,cString) + 2 )
	Local nRet := 0
	Local nDiv := 0

	If nX > 2

		If cTp == "1" // Valor
			nDiv := 100
		ElseIf cTp == "2" // %
			nDiv := 10000
		EndIf

		nRet := (val(substr(cString,nX,7))/nDiv)

	EndIf

Return(nRet)


Function VA1630045_LiberaBonus()

	Local ni := 0
	Local aRecVQ1 := {}
	Local aCpoVQ1 := {}

	If Len(aRegSel) == 0

		MsgInfo( STR0020 , STR0014) // Necessario selecionar os registros! / Atencao

	ElseIf MsgYesNo( STR0021 , STR0014 ) // Deseja liberar para geracao de NF os registros selecionados? / Atencao

		Begin Transaction

			For ni := 1 to len(aRegSel)

				aAdd( aCpoVQ1, {"VQ1_STATUS", "2"})

				aAdd(aRecVQ1,{aRegSel[ni],aClone(aCpoVQ1)})

			Next

			If Len(aRecVQ1) > 0
				VA1630055_AtualizaBonus( aRecVQ1 , MODEL_OPERATION_UPDATE )
			EndIf

		End Transaction

	EndIf

Return

Function VA1630065_CancelaBonus()

	Local ni 		:= 0
	Local aVQ4RecNo := {}
	Local aRecVQ1 	:= {}
	Local aCpoVQ1 	:= {}
	Local cAliasVDT := "SQLVDT"
	Local nCntExc := 0
	Local cCodOri2 := ""

	Begin Transaction

		If Alltrim(VQ1->VQ1_STATUS) $ "12" // Levantados / Gravados / Liberados para faturar

			If MsgYesNo( STR0022 , STR0014 ) // Deseja Cancelar o bonus selecionado? / Atencao

				aMotCancel := OFA210MOT("000014","8",VQ1->VQ1_FILIAL,VQ1->VQ1_CODIGO+VQ1->VQ1_SEQUEN,.T.) // Filtro da consulta do motivo

				If Len(aMotCancel) > 0

					aAdd( aCpoVQ1, {"VQ1_STATUS", "4"})
					aAdd( aCpoVQ1, {"VQ1_MOTIVO", aMotCancel[1]})

					aAdd(aRecVQ1,{VQ1->(RecNo()),aClone(aCpoVQ1)})

					VA1630055_AtualizaBonus( aRecVQ1 , MODEL_OPERATION_UPDATE )

				Endif

			EndIf

		ElseIf Alltrim(VQ1->VQ1_STATUS) == "3" // NF gerada

			cQuery := "SELECT VQ4.R_E_C_N_O_ RECVQ4 "
			cQuery += " FROM " + RetSQLName("VQ4") + " VQ4 "
			cQuery += " WHERE VQ4.VQ4_FILIAL = '" + xFilial("VQ4") + "' "
			cQuery += 	" AND VQ4.VQ4_FILNFI = '" + VQ1->VQ1_FILNFI + "' "
			cQuery += 	" AND VQ4.VQ4_NUMNFI = '" + VQ1->VQ1_NUMNFI + "' "
			cQuery += 	" AND VQ4.VQ4_SERNFI = '" + VQ1->VQ1_SERNFI + "' "
			cQuery += 	" AND VQ4.D_E_L_E_T_=' ' "

			TcQuery cQuery New Alias "TMPVQ4"

			Do While !TMPVQ4->( Eof() )

				aAdd(aVQ4RecNo,TMPVQ4->(RECVQ4)) // Levantar os VQ4 da NF a ser cancelada

				TMPVQ4->(dbSkip())

			Enddo

			TMPVQ4->( dbCloseArea() )

			DbSelectArea("VQ4")
			// Se a NF ja foi transmitida e nao tem os campos com os NOMES do XML ( nome atual / nome anterior ) nao deixa continuar
			If len(aVQ4RecNo) > 0 .and. VQ4->(ColumnPos("VQ4_NXMLAT")) <= 0
				MsgStop( STR0023 , STR0014 ) // NF de Bonus ja esta transmitida! / Atencao
				Return()
			EndIf

			DbSelectArea("VQ1")
			If MsgYesNo(;
						IIf( len( aVQ4RecNo ) > 0 , STR0023 ,"" ) +" "+;
						STR0024 +;
						CHR(13) + CHR(10) +;
						CHR(13) + CHR(10) +;
						STR0025 +;
						VQ1->VQ1_NUMNFI + "-" +;
						VQ1->VQ1_SERNFI ,;
						STR0014) // NF de Bonus ja esta transmitida! Deseja Cancelar a NF ? / NF/Serie: / Atencao

				aMotCancel := OFA210MOT("000014","8",VQ1->VQ1_FILIAL,VQ1->VQ1_CODIGO+VQ1->VQ1_SEQUEN,.T.) // Filtro da consulta do motivo

				If Len(aMotCancel) > 0

					If FMX_EXCNFS( VQ1->VQ1_NUMNFI , VQ1->VQ1_SERNFI , .t.)

						cQuery := "SELECT R_E_C_N_O_ RECVQ1 "
						cQuery += " FROM " + RetSQLName("VQ1") + " "
						cQuery += " WHERE VQ1_FILIAL = '" + xFilial("VQ1") + "' "
						cQuery += 	" AND VQ1_NUMNFI = '" + VQ1->VQ1_NUMNFI + "' "
						cQuery += 	" AND VQ1_SERNFI = '" + VQ1->VQ1_SERNFI + "' "
						cQuery += 	" AND D_E_L_E_T_=' '"

						TcQuery cQuery New Alias "TMPVQ1"

						While !TMPVQ1->( Eof() )

							fLimpaVetor(aCpoVQ1)
							aCpoVQ1 := {}
							aRecVQ1 := {}

							DbSelectArea("VQ1")
							DbGoTo(TMPVQ1->( RECVQ1 ))

							aAdd( aCpoVQ1, {"VQ1_STATUS", "4"})
							aAdd( aCpoVQ1, {"VQ1_MOTIVO", aMotCancel[1]})
							aAdd( aCpoVQ1, {"VQ1_RETUID", ""})

							aAdd(aRecVQ1,{VQ1->(RecNo()),aClone(aCpoVQ1)})

							VA1630055_AtualizaBonus( aRecVQ1 , MODEL_OPERATION_UPDATE )

							TMPVQ1->( DbSkip() )

						EndDo

						TMPVQ1->( DbCloseArea() )

						If len(aVQ4RecNo) > 0
							DbSelectArea("VQ4")

							For ni := 1 to len(aVQ4RecNo)
								DbSelectArea("VQ4")
								DbGoTo(aVQ4RecNo[ni])
								RecLock("VQ4",.F.,.T.)
								dbdelete() // Apagar VQ4 correspondente
								MsUnlock()
							Next

						EndIf

					EndIf

					dbSelectArea("VQ1")

				Endif

			EndIf

		ElseIf Alltrim(VQ1->VQ1_STATUS) == "4" // Cancelado

			If MsgYesNo( STR0026 , STR0014 ) // Deseja recuperar o registro selecionado? / Atencao

				If !Empty( VQ1->VQ1_NUMNFI + VQ1->VQ1_SERNFI )

					aAdd( aCpoVQ1, {"VQ1_FILNFI", ""})
					aAdd( aCpoVQ1, {"VQ1_NUMNFI", ""})
					aAdd( aCpoVQ1, {"VQ1_SERNFI", ""})
					aAdd( aCpoVQ1, {"VQ1_OBSNFC", ""})
					aAdd( aCpoVQ1, {"VQ1_DATNFI", ctod("")})

				EndIf

				aAdd( aCpoVQ1, {"VQ1_STATUS", "1"})
				aAdd( aCpoVQ1, {"VQ1_MOTIVO", ""})

				aAdd(aRecVQ1,{VQ1->(RecNo()),aClone(aCpoVQ1)})

				cCodOri2 := VQ1->VQ1_CODIGO + VQ1->VQ1_SEQUEN //alex - consulta antes da alteracao da chave de pesquisa

				For nCntExc := 1 to 2
					If Select(cAliasVDT) > 0
						cAliasVDT->(DbCloseArea())
					Endif
					// Exclui registro do questionario
					cQuery := "SELECT VDT.R_E_C_N_O_ RECVDT "
					cQuery += " FROM " + RetSqlName( "VDT" ) + " VDT "
					cQuery += " WHERE VDT.VDT_FILIAL = '" + xFilial("VDT") + "' "
					cQuery += 	" AND VDT.VDT_TIPASS = '000014' "
					cQuery += 	" AND VDT.VDT_CODMOT = '" + VQ1->VQ1_MOTIVO + "'"
					cQuery += 	" AND VDT.VDT_CODORI = '" + cCodOri2 + "'"
					cQuery += 	" AND VDT.D_E_L_E_T_ = ' '"

					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVDT, .T., .T. )

					If !cAliasVDT->(EOF())
						Exit
					Else
						cCodOri2 := VQ1->VQ1_CODIGO
					Endif
				Next

				cAlias->(DbGoTop())

				Do While !( cAliasVDT )->( Eof() )

					VDT->(dbGoTo(( cAliasVDT )->(RECVDT)))
					RecLock("VDT",.F.,.T.)
						dbdelete()
					MsUnlock()
					dbSelectArea(cAliasVDT)

					( cAliasVDT )->(dbSkip())

				Enddo

				( cAliasVDT )->( dbCloseArea() )

				DbSelectArea("VQ1")

				VA1630055_AtualizaBonus( aRecVQ1 , MODEL_OPERATION_UPDATE )

			EndIf

		EndIf

	End Transaction


Return

Function VA1630055_AtualizaBonus( aRecVQ1 , nOpercao )

	Local oModel := FWLoadModel( 'VEIA163' )
	Local lSeek  := .f.
	Local nRecVQ1:= 0
	Local nAtuCpo:= 0
	Local lRet   := .f.
	Local oModelDet

	Default aRecVQ1 := {}
	Default nOpercao:= 1

	VQ1->(DbSeek(xFilial("VQ1")+VQ1->VQ1_CODIGO))

	oModel:SetOperation( nOpercao )

	lRet := oModel:Activate()

	If lRet

		If oModel:GetOperation() == MODEL_OPERATION_INSERT
			oModel:SetValue( "VQ1MASTER", "VQ1_CODIGO", VQ0->VQ0_CODIGO )
		EndIf

		For nRecVQ1 := 1 to Len(aRecVQ1)

			VQ1->(DbGoTo(aRecVQ1[nRecVQ1,1]))

			oModelDet := oModel:GetModel("VQ1DETAIL")

			lSeek := oModelDet:SeekLine({;
										{ "VQ1_FILIAL" , VQ1->VQ1_FILIAL },;
										{ "VQ1_CODIGO" , VQ1->VQ1_CODIGO },;
										{ "VQ1_SEQUEN" , VQ1->VQ1_SEQUEN };
									})

			lContinua := lSeek

			If	!(lContinua) .and. oModel:GetOperation() == MODEL_OPERATION_INSERT
				lContinua := .t.
				oModelDet:AddLine()
			EndIf

			If lContinua

				For nAtuCpo := 1 to Len(aRecVQ1[nRecVQ1,2])
					oModel:SetValue( "VQ1DETAIL", aRecVQ1[nRecVQ1,2,nAtuCpo,1], aRecVQ1[nRecVQ1,2,nAtuCpo,2] )
				Next

			EndIf

		Next

		lRet := VA1630025_CommitData(oModel)
		oModel:DeActivate()

	Else

		Help("",1,"ACTIVEVQ1",, STR0027 ,1,0) // "Não foi possivel ativar o modelo de inclusão da tabela"

	EndIf

	FreeObj(oModel)

Return lRet

Function VA1630075_AtualizaAtendimento()

	Local lRet    := .f.
	Local cQuery  := ""
	Local cNamVV9 := RetSQLName("VV9")
	Local cNamVVA := RetSQLName("VVA")
	Local nRecVVA := 0
	Local lVVA_SEGMOD := ( VVA->(ColumnPos("VVA_SEGMOD")) > 0 )

	If !Empty(VQ0->VQ0_FILATE+VQ0->VQ0_NUMATE)

		// Atualizacao do Atendimento ( execucao do botao )
		VV9->(DbSetOrder(1))
		If VV9->(DbSeek(VQ0->VQ0_FILATE+VQ0->VQ0_NUMATE))

			If !Softlock("VV9")
				Return .f.
			EndIf

			VV0->(DbSetOrder(1))
			If VV0->(DbSeek(VQ0->VQ0_FILATE+VQ0->VQ0_NUMATE))

				cQuery := "SELECT VVA.R_E_C_N_O_ "
				cQuery += " FROM " + cNamVVA +" VVA "
				cQuery += " JOIN " + cNamVV9 +" VV9 "
				cQuery += 		" ON ( VV9.VV9_FILIAL = VVA.VVA_FILIAL "
				cQuery += 		" AND VV9.VV9_NUMATE = VVA.VVA_NUMTRA "
				cQuery += 		" AND VV9.VV9_STATUS <> 'C' "
				cQuery += 		" AND VV9.D_E_L_E_T_=' ' ) "
				cQuery += " WHERE VVA.VVA_FILIAL = '" + VQ0->VQ0_FILATE + "' "
				cQuery += 	" AND VVA.VVA_NUMTRA = '" + VQ0->VQ0_NUMATE + "' "
				cQuery += 	" AND VVA.VVA_CHAINT = '" + VQ0->VQ0_CHAINT + "' "
				cQuery += 	" AND VVA.D_E_L_E_T_=' '"

				nRecVVA := FM_SQL(cQuery)

				VVA->(DbGoTo(nRecVVA))
				VV2->(DbSetOrder(1))
				VV2->(DbSeek(xFilial("VV2")+VVA->VVA_CODMAR+VVA->VVA_MODVEI+IIf(lVVA_SEGMOD,VVA->VVA_SEGMOD,"")))

				VEIXX014(VQ0->VQ0_NUMATE,VVA->VVA_CODMAR,VV2->VV2_GRUMOD,VVA->VVA_MODVEI,4,.t.,"0",nRecVVA,.t.)

			EndIf

			MsUnlockAll()

		EndIf

	EndIf

Return(lRet)

Function VA1630085_ExcluiBonus()

	Local oView
	Local oStruVQ1 := FWFormStruct( 2, 'VQ1' )
	Local oModelVQ1

	Local oStruVQ1Cab := FWFormStruct( 1, 'VQ1' )

	oModelVQ1 := MPFormModel():New('VEIA163',;
		/*Pré-Validacao*/,;
		/*Pós-Validacao*/,;
		/*Confirmacao da Gravação*/,;
		/*Cancelamento da Operação*/)

	oModelVQ1:AddFields( 'VQ1MASTER', /*cOwner*/, oStruVQ1Cab, /* <bPre> */ , /* <bPost> */ , /* <bLoad>  { |oModel| loadCab(oModel) }*/ )
	oModelVQ1:GetModel( 'VQ1MASTER' ):SetDescription( STR0028 ) //Dados de Modelo Cabeçalho

	oStruVQ1:SetNoFolder()

	oView := FWFormView():New()
	oView:SetModel( oModelVQ1 )
	oView:AddField( 'VIEW_VQ1', oStruVQ1, 'VQ1MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_VQ1', 'TELA' )

	oExecView := FWViewExec():New()
	oExecView:setTitle( STR0029 ) //"Informações do Bônus"
	oExecView:setModel(oModelVQ1)
	oExecView:setView(oView)
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_DELETE)
	oExecView:setReduction(30)
	oExecView:openView(.t.)

Return

Static function fLimpaVetor(aArray)
	aArray := aSize(aArray,0)
Return


Static Function VA1630095_OpcionaisBonusPedido(cOpcional)

	Local cQuery := ""
	Local lVJN_CODOPC := ( VJN->(ColumnPos("VJN_CODOPC")) > 0 )

	cQuery := "SELECT * "
	cQuery += "FROM " + RetSQLName("VJN") + " VJN "
	cQuery += "WHERE VJN.VJN_FILIAL = '" + xFilial("VJN") + "' "
	cQuery +=  " AND VJN.VJN_CODVQ0 = '" + VQ0->VQ0_CODIGO + "' "
	If lVJN_CODOPC
		cQuery +=  " AND ( VJN.VJN_CODOPC = '" + cOpcional + "' "
		cQuery +=  "  OR ( VJN.VJN_CODOPC = ' ' AND VJN.VJN_CODVJV = '" + cOpcional + "' ) ) " // Registro Antigo - TEMPORARIO
	Else
		cQuery +=  " AND VJN.VJN_CODVJV = '" + cOpcional + "' "
	EndIf
	cQuery +=  " AND VJN.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVJN"

	If !TMPVJN->(Eof())
		TMPVJN->(DbCloseArea())
		Return .t.
	EndIf

	TMPVJN->(DbCloseArea())

Return .f.

Static Function VA1630105_CalculosBonus( oModel, nTp )
	Local nRetorno := 0

	If nTp == 8 // Valor Liquido
		nRetorno := VA1630115_ValorPerLiquido(oModel)
	ElseIf nTp == 7
		nRetorno := VA1630125_ValorLiquido(oModel)
	ElseIf nTp == 6
		nRetorno := VA1630135_PercentualBonus(oModel)

		oModel:LoadValue( "VQ1_VLRLIQ", VA1630125_ValorLiquido(oModel) )
	ElseIf nTp == 5
		nRetorno := VA1630155_ValorTotal(oModel)

		oModel:LoadValue( "VQ1_VLRLIQ", VA1630125_ValorLiquido(oModel, nRetorno) )
	Else
		nRetorno := VA1630145_ValorBase(oModel)

		oModel:LoadValue( "VQ1_VLRTOT", VA1630155_ValorTotal(oModel, nRetorno) )
	EndIf

Return nRetorno


Static Function VA1630115_ValorPerLiquido(oModDet)
	Local nRetorno := 0

	nRetorno := round( ( ( ( oModDet:GetValue("VQ1_VLRTOT") - oModDet:GetValue("VQ1_VLRLIQ") ) / oModDet:GetValue("VQ1_VLRTOT") ) * 100 ) , 2 )

Return nRetorno

Static Function VA1630125_ValorLiquido(oModDet, nValTot)
	Local nRetorno := 0

	Default nValTot := oModDet:GetValue("VQ1_VLRTOT")

	nRetorno := round( nValTot - ( ( nValTot * oModDet:GetValue("VQ1_PERIMP") ) / 100 ) , 2 )

Return nRetorno

Static Function VA1630135_PercentualBonus(oModDet, nValBase)
	Local nRetorno := 0

	Default nValBase := nValBase := oModDet:GetValue("VQ1_VLRBAS")

	nRetorno := round( ( ( oModDet:GetValue("VQ1_VLRTOT") / nValBase ) * 100 ) , 2 )

Return nRetorno

Static Function VA1630145_ValorBase(oModDet)
	Local nRetorno := 0

	nRetorno := round(( oModDet:GetValue("VQ1_VLRINI") - ( ( ( oModDet:GetValue("VQ1_DESCON") + oModDet:GetValue("VQ1_DESCDC") ) * oModDet:GetValue("VQ1_VLRINI") ) / 100 ) ) , 2 )

Return nRetorno

Static Function VA1630155_ValorTotal(oModDet, nValBase)
	Local nRetorno := 0

	Default nValBase := nValBase := oModDet:GetValue("VQ1_VLRBAS")

	nRetorno := round( ( ( nValBase * oModDet:GetValue("VQ1_PERVLR") ) / 100 ) , 2 )

Return nRetorno