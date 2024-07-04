#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "VEIA252.CH"

/*/{Protheus.doc} VEIA252
Ajuste Geral de % de Markups e Descontos

@author Andre Luis Almeida
@since 21/07/2021
@version undefined

@type function
/*/
Function VEIA252()
	Private oModel     := FWLoadModel("VEIA252")
	Private oView      := FWLoadView("VEIA252")
	Private oModelPar
	Private oModelTik
	Private oModelMod
	Private M->VV1_CODMAR := "" // Utilizado no F3 do Modelo
	Private M->VV2_CODMAR := "" // Utilizado no F3 do Segmento

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	lRet := oModel:Activate()
	If !lRet
		Return {}
	EndIf

	oModelPar := oModel:GetModel("FILTRO")
	oModelPar:LoadValue( "PARCADVN0" , "5" ) // 5 = Com ou Sem Cadastro de Pacote
	oModelPar:LoadValue( "PARTIPO"   , "1" ) // 1 = MARKUP A VISTA
	oModelPar:LoadValue( "PARREFDATA", "1" ) // 1 = Vigorando Hoje
	oModelPar:LoadValue( "PARCADVN3" , "0" ) // 0 = Com ou Sem Cadastro Ativo

	oModelTik := oModel:GetModel("TIK")
	oModelTik:LoadValue( "PARSELECT" , .f. ) // TIK para Marcar/Desmarcar Modelos

	oModelMod := oModel:GetModel("LISTA_MODELOS")

	CursorArrow()
	oExecView := FWViewExec():New()
	oExecView:setModel(oModel)
	oExecView:setView(oView)
	oExecView:setOK( { || VA2520091_OK_Tela() })
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

Return NIL


Static Function ModelDef()

	Local oModel 
	Local oFiltros := VA2520011_Campos_Filtro()
	Local oModelos := VA2520021_Campos_Modelos()
	Local oTik     := VA2520101_Campo_Tik()
	Local oFilStru := oFiltros:GetModel()
	Local oModStru := oModelos:GetModel()
	Local oTikStru := oTik:GetModel()

	oModel := MPFormModel():New( 'VEIA252', /* bPre */, /* bPost */ , { || .t. } /* bCommit */ , { || .T. } /* bCancel */ )
	oModel:AddFields('FILTRO', /* cOwner */ , oFilStru, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ )
	oModel:AddFields('TIK', 'FILTRO' , oTikStru, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ )
	oModel:AddGrid('LISTA_MODELOS','FILTRO',oModStru, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )

	oModel:SetDescription(STR0001) // Markups e Descontos
	
	oModel:GetModel('FILTRO'):SetDescription(STR0002) // Filtro
	oModel:GetModel('FILTRO'):SetOnlyQuery( .T. )

	oModel:GetModel('TIK'):SetDescription(STR0003) // Tik
	oModel:GetModel('TIK'):SetOnlyQuery( .T. )

	oModel:GetModel('LISTA_MODELOS'):SetDescription(STR0004) // Modelos
	oModel:GetModel("LISTA_MODELOS"):SetNoDeleteLine( .T. ) // NAO Deixa deletar linhas no Objeto
	oModel:GetModel('LISTA_MODELOS'):SetOnlyQuery( .T. )
	oModel:GetModel('LISTA_MODELOS'):SetOptional( .T. )
	
	oModel:SetPrimaryKey({})

Return oModel

Static Function ViewDef()
	Local oModel   := FWLoadModel( 'VEIA252' )
	Local oView    := Nil
	Local oFiltros := VA2520011_Campos_Filtro()
	Local oModelos := VA2520021_Campos_Modelos()
	Local oTik     := VA2520101_Campo_Tik()
	Local oFilStru := oFiltros:GetView()
	Local oModStru := oModelos:GetView()
	Local oTikStru := oTik:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FORM_FILTRO', oFilStru , 'FILTRO')
	oView:AddField('FORM_TIK', oTikStru , 'TIK')
	oView:AddGrid('GRID_LISTA_MODELOS', oModStru , 'LISTA_MODELOS')

	oView:EnableTitleView('FORM_FILTRO',STR0002) // Filtro

	oView:SetNoInsertLine('GRID_LISTA_MODELOS')
	oView:SetNoDeleteLine('GRID_LISTA_MODELOS')
	oView:EnableTitleView('GRID_LISTA_MODELOS',STR0004) // Modelos
	
	oView:CreateHorizontalBox('TELA_FILTRO',40)
	oView:CreateHorizontalBox('TELA_TIK',80,,.t.)
	oView:CreateHorizontalBox('TELA_LISTA_PACOTES',60)

	oView:SetOwnerView('FORM_FILTRO','TELA_FILTRO')
	oView:SetOwnerView('FORM_TIK','TELA_TIK')
	oView:SetOwnerView('GRID_LISTA_MODELOS','TELA_LISTA_PACOTES')

	oView:SetCloseOnOk({||.T.})

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o questionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 

	oView:SetViewProperty("GRID_LISTA_MODELOS"  , "GRIDSEEK", {.T.})

	// Criar novo botao na barra de botoes
	oView:AddUserButton(STR0005,'CLIPS',{ |oView| VA2520061_PreenchePerc() }) // Preencher %
	oView:AddUserButton(STR0006,'CLIPS',{ |oView| VA2520071_PreencheData() }) // Preencher Data

	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

Return oView

/*/
{Protheus.doc} VA2520011_Campos_Filtro
Monta Campos da Grid de FILTRO/Simulação

@author Andre Luis Almeida
@since 14/07/2021
/*/
Static Function VA2520011_Campos_Filtro()
Local oRetorno := OFDMSStruct():New()

oRetorno:AddFieldDictionary( "VV2" , "VV2_CODMAR" , { { 'cIdField' , 'PARCODMAR' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } , { 'bValid', FWBuildFeature(STRUCT_FEATURE_VALID,'(vazio().or.FG_Seek("VE1","M->PARCODMAR",1,.f.)).and.VA2520111_Carrega_Variaveis_para_F3(M->PARCODMAR)') } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_GRUMOD" , { { 'cIdField' , 'PARGRUMOD' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } , { 'bValid', FWBuildFeature(STRUCT_FEATURE_VALID,'vazio().or.FG_Seek("VVR","M->PARCODMAR+M->PARGRUMOD",2,.f.)') } } )
oRetorno:AddFieldDictionary( "VV1" , "VV1_MODVEI" , { { 'cIdField' , 'PARMODVEI' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } , { 'bValid', FWBuildFeature(STRUCT_FEATURE_VALID,'vazio().or.FG_Seek("VV2","M->PARCODMAR+M->PARMODVEI",1,.f.)') } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_SEGMOD" , { { 'cIdField' , 'PARSEGMOD' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } , { 'bValid', FWBuildFeature(STRUCT_FEATURE_VALID,'vazio().or.FG_Seek("VV2","M->PARCODMAR+M->PARMODVEI+M->PARSEGMOD",1,.f.)') } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_TIPVEI" , { { 'cIdField' , 'PARTIPVEI' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } , { 'bValid', FWBuildFeature(STRUCT_FEATURE_VALID,'vazio().or.FG_Seek("VV8","M->PARTIPVEI",1,.f.)') } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_CATVEI" , { { 'cIdField' , 'PARCATVEI' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } , { 'bValid', FWBuildFeature(STRUCT_FEATURE_VALID,'vazio().or.FG_Seek("VVB","M->PARCATVEI",1,.f.)') } } )

oRetorno:AddField({	{ 'cIdField'     , 'PARCADVN0' } ,;
					{ 'cTitulo'      , STR0007 } ,; // Cadastro de Pacote
					{ 'cTooltip'     , STR0007 } ,; // Cadastro de Pacote
					{ 'cTipo'        , 'C' } ,;
					{ 'nTamanho'     , 1 } ,;
					{ 'aComboValues' , { '0='+STR0013 , '1='+STR0014 , '2='+STR0015 , '3='+STR0016 , '4='+STR0017 , '5='+STR0018 } } ,; // Cadastro Pendente / Cadastro Ativado / Cadastro Desativado / Qualquer Cadastro / Sem Cadastro / Com ou Sem Cadastro
					{ 'bValid'       , FWBuildFeature(STRUCT_FEATURE_VALID,'Pertence("012345")') } ,;
					{ 'lVirtual'     , .t. } ,;
					{ 'lCanChange'   , .t. } })

oRetorno:AddField({	{ 'cIdField'     , 'PARCADVN3' } ,;
					{ 'cTitulo'      , STR0019 } ,; // Cadastro Markup e/ou Desconto
					{ 'cTooltip'     , STR0019 } ,; // Cadastro Markup e/ou Desconto
					{ 'cTipo'        , 'C' } ,;
					{ 'nTamanho'     , 1 } ,;
					{ 'aComboValues' , { '0='+STR0020 , '1='+STR0021 , '2='+STR0022 } } ,; // Com ou Sem Cadastro Ativo / Com Cadastro Ativo / Sem Cadastro Ativo
					{ 'bValid'       , FWBuildFeature(STRUCT_FEATURE_VALID,'Pertence("012")') } ,;
					{ 'lVirtual'     , .t. } ,;
					{ 'lCanChange'   , .t. } })

oRetorno:AddField({	{ 'cIdField'     , 'PARREFDATA' } ,;
					{ 'cTitulo'      , STR0023 } ,; // Referencia para a Data
					{ 'cTooltip'     , STR0023 } ,; // Referencia para a Data
					{ 'cTipo'        , 'C' } ,;
					{ 'nTamanho'     , 1 } ,;
					{ 'aComboValues' , { '1='+STR0024 , '2='+STR0025 } } ,; // Vigorando Hoje / Ultima Data
					{ 'bValid'       , FWBuildFeature(STRUCT_FEATURE_VALID,'Pertence("12")') } ,;
					{ 'lVirtual'     , .t. } ,;
					{ 'lCanChange'   , .t. } })

oRetorno:AddField({	{ 'cIdField'     , 'PARTIPO' } ,;
					{ 'cTitulo'      , STR0026 } ,; // Qual % alterar?
					{ 'cTooltip'     , STR0026 } ,; // Qual % alterar?
					{ 'cTipo'        , 'C' } ,;
					{ 'nTamanho'     , 1 } ,;
					{ 'aComboValues' , { '1='+STR0027 , '2='+STR0028 , '3='+STR0029 } } ,; // MARKUP A VISTA / MARKUP A PRAZO / DESCONTO
					{ 'bValid'       , FWBuildFeature(STRUCT_FEATURE_VALID,'Pertence("123")') } ,;
					{ 'lVirtual'     , .t. } ,;
					{ 'lCanChange'   , .t. } })

Return oRetorno

/*/
{Protheus.doc} VA2520021_Campos_Modelos
Monta Campos da Grid Pacotes do Modelo

@author Andre Luis Almeida
@since 14/07/2021
/*/
Static Function VA2520021_Campos_Modelos()
Local oRetorno := OFDMSStruct():New()

oRetorno:AddSelect('','SELECT', , .t.)
oRetorno:AddFieldDictionary( "VV2" , "VV2_CODMAR" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_GRUMOD" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_MODVEI" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_SEGMOD" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_TIPVEI" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_CATVEI" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )

oRetorno:AddField({	{ 'cIdField'   , 'DATATU' },;
					{ 'cTitulo'    , STR0030 },; // Data de Referencia
					{ 'cTipo'      , 'D' },;
					{ 'nTamanho'   , 8 },;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .f. } } )

oRetorno:AddField({	{ 'cIdField'   , 'PERATU' },;
					{ 'cTitulo'    , STR0031 },; // % da Data de Referencia
					{ 'cTipo'      , 'N' },;
					{ 'nTamanho'   , 7 },;
					{ 'nDecimal'   , 3 },;
					{ 'cPicture'   , '@E 999.999' } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .f. } } )

oRetorno:AddField({	{ 'cIdField'   , 'DATNEW' },;
					{ 'cTitulo'    , STR0012 },; // Nova Data - Apartir de
					{ 'cTipo'      , 'D' },;
					{ 'nTamanho'   , 8 },;
					{ 'bValid'     , FWBuildFeature(STRUCT_FEATURE_VALID,'VA2520081_ValidaDataDigitada()') } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .t. } } )

oRetorno:AddField({	{ 'cIdField'   , 'PERNEW' },;
					{ 'cTitulo'    , STR0032 },; // Novo %
					{ 'cTipo'      , 'N' },;
					{ 'nTamanho'   , 7 },;
					{ 'nDecimal'   , 3 },;
					{ 'cPicture'   , '@E 999.999' } ,;
					{ 'bValid'     , FWBuildFeature(STRUCT_FEATURE_VALID,'Positivo()') } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .t. } } )

Return oRetorno

/*/
{Protheus.doc} VA2520031_ProcessaLevantamentoModelos
Chamada do Levantamento dos Modelos

@author Andre Luis Almeida
@since 22/07/2021
/*/
Function VA2520031_ProcessaLevantamentoModelos()

Processa({|| VA2520041_LevantaModelos() })

Return .t.

/*/
{Protheus.doc} VA2520041_LevantaModelos
Levanta os Modelos

@author Andre Luis Almeida
@since 20/07/2021
/*/
Static Function VA2520041_LevantaModelos()
Local cQuery  := ""
Local cQAlias := "SQLVV2"
Local nPerc   := 0
Local dData   := cTod("")
Local nQtd    := 0
Local cCadVN0 := oModelPar:GetValue("PARCADVN0")
Local cCadVN3 := oModelPar:GetValue("PARCADVN3")
Local cTipRef := oModelPar:GetValue("PARTIPO")
Local dDatRef := IIf(oModelPar:GetValue("PARREFDATA")=="1",dDataBase,dDataBase+9999)
Local lSelect := oModelTik:GetValue("PARSELECT")
Local cNamVN3 := RetSqlName("VN3")
Local cFilVN3 := xFilial("VN3")
Local aCpoSQL := { "VV2_CODMAR" , "VV2_GRUMOD" , "VV2_MODVEI" , "VV2_SEGMOD" , "VV2_TIPVEI" , "VV2_CATVEI" }
Local nCntFor := 0
//
oModelMod:ClearData(.t.) // Limpa TOTAL a Grid de Modelos
oModelMod:SetNoInsertLine( .f. ) // Deixa inserir linhas no Objeto
//
cQuery := "SELECT "
For nCntFor := 1 to len(aCpoSQL)
	cQuery += "TAGR."+aCpoSQL[nCntFor]+" , "
Next
cQuery += "MAX(TAGR.DATINI) AS DATINI "
cQuery += "FROM ("
cQuery += " SELECT "
For nCntFor := 1 to len(aCpoSQL)
	cQuery += "TORD."+aCpoSQL[nCntFor]+" , "
Next
cQuery += "TORD.DATINI "
cQuery += "FROM ("
cQuery += " SELECT "
For nCntFor := 1 to len(aCpoSQL)
	cQuery += "VV2."+aCpoSQL[nCntFor]+" , "
Next
If cCadVN3 <> "2" // Diferente de SEM Cadastro Ativo no VN3
	cQuery += " VN3.VN3_DATINI AS DATINI "
Else
	cQuery += " ' ' AS DATINI "
EndIf
cQuery += " FROM " + RetSqlName("VV2") + " VV2 "
If cCadVN3 $ "01" // 0 = COM ou SEM Cadastro Ativo no VN3 ou 1 = Com Cadastro Ativo no VN3
	If cCadVN3 == "0" // COM ou SEM Cadastro Ativo no VN3
		cQuery += " LEFT"
	EndIf
	cQuery += " JOIN " + cNamVN3 +" VN3 ON ( "
	cQuery += "      VN3.VN3_FILIAL = '"+cFilVN3+"'"
	cQuery += "  AND VN3.VN3_CODMAR = VV2.VV2_CODMAR"
	cQuery += "  AND VN3.VN3_MODVEI = VV2.VV2_MODVEI"
	cQuery += "  AND VN3.VN3_SEGMOD = VV2.VV2_SEGMOD"
	cQuery += "  AND VN3.VN3_TIPO   = '"+cTipRef+"' "
	cQuery += "  AND VN3.VN3_USRDES = ' '"
	cQuery += "  AND VN3.VN3_DATINI <= '"+dtos(dDatRef)+"'"
	cQuery += "  AND VN3.D_E_L_E_T_ = ' ' )"
EndIf
cQuery += " WHERE VV2.VV2_FILIAL = '"+xFilial("VV2")+"' "
If !Empty(oModelPar:GetValue("PARCODMAR"))
	cQuery += " AND VV2.VV2_CODMAR = '"+oModelPar:GetValue("PARCODMAR")+"' "
EndIf
If !Empty(oModelPar:GetValue("PARGRUMOD"))
	cQuery += " AND VV2.VV2_GRUMOD = '"+oModelPar:GetValue("PARGRUMOD")+"' "
EndIf
If !Empty(oModelPar:GetValue("PARMODVEI"))
	cQuery += " AND VV2.VV2_MODVEI = '"+oModelPar:GetValue("PARMODVEI")+"' "
EndIf
If !Empty(oModelPar:GetValue("PARSEGMOD"))
	cQuery += " AND VV2.VV2_SEGMOD = '"+oModelPar:GetValue("PARSEGMOD")+"' "
EndIf
If !Empty(oModelPar:GetValue("PARTIPVEI"))
	cQuery += " AND VV2.VV2_TIPVEI = '"+oModelPar:GetValue("PARTIPVEI")+"' "
EndIf
If !Empty(oModelPar:GetValue("PARCATVEI"))
	cQuery += " AND VV2.VV2_CATVEI = '"+oModelPar:GetValue("PARCATVEI")+"' "
EndIf
cQuery += "   AND VV2.D_E_L_E_T_ = ' ' "
If cCadVN0 <= "4" // 0=Cadastro Pendente / 1=Cadastro Ativado / 2=Cadastro Desativado / 3=Qualquer Cadastro / 4=Sem Cadastro
	If cCadVN0 == "4" // 4 = Sem Cadastro VN0
		cQuery += " AND NOT EXISTS ("
	Else // Existe Cadastro no VN0 -> 0=Cadastro Pendente / 1=Cadastro Ativado / 2=Cadastro Desativado / 3=Qualquer Cadastro
		cQuery += " AND EXISTS ("
	EndIf
	cQuery += "SELECT VN0.VN0_CODIGO "
	cQuery += "  FROM " + RetSqlName("VN0") + " VN0 "
	cQuery += " WHERE VN0.VN0_FILIAL = '"+xFilial("VN0")+"'"
	cQuery += "   AND VN0.VN0_CODMAR = VV2.VV2_CODMAR"
	cQuery += "   AND VN0.VN0_MODVEI = VV2.VV2_MODVEI"
	cQuery += "   AND VN0.VN0_SEGMOD = VV2.VV2_SEGMOD"
	If cCadVN0 <= "2" // 0=Cadastro Pendente / 1=Cadastro Ativado / 2=Cadastro Desativado
		cQuery += " AND VN0.VN0_STATUS = '"+cCadVN0+"'"
	EndIf
	cQuery += "   AND VN0.D_E_L_E_T_ = ' ' ) "
EndIf
If cCadVN3 == "2" // SEM Cadastro Ativo no VN3
	cQuery += " AND NOT EXISTS ("
	cQuery += " SELECT VN3.VN3_CODIGO "
	cQuery += "   FROM " + cNamVN3 +" VN3 "
	cQuery += "  WHERE VN3.VN3_FILIAL = '"+cFilVN3+"'"
	cQuery += "    AND VN3.VN3_CODMAR = VV2.VV2_CODMAR"
	cQuery += "    AND VN3.VN3_MODVEI = VV2.VV2_MODVEI"
	cQuery += "    AND VN3.VN3_SEGMOD = VV2.VV2_SEGMOD"
	cQuery += "    AND VN3.VN3_TIPO   = '"+cTipRef+"' "
	cQuery += "    AND VN3.VN3_USRDES = ' '"
	cQuery += "    AND VN3.VN3_DATINI <= '"+dtos(dDatRef)+"'"
	cQuery += "    AND VN3.D_E_L_E_T_ = ' ' )"
EndIf
cQuery += " ) TORD "
cQuery += " ) TAGR "
cQuery += "GROUP BY "
For nCntFor := 1 to len(aCpoSQL)
	cQuery += "TAGR."+aCpoSQL[nCntFor]
	If nCntFor < len(aCpoSQL)
		cQuery += " , "
	EndIf	
Next
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F. , .T. )
ProcRegua( (cQAlias)->(RecCount()) )
While !(cQAlias)->(Eof())
	//
	IncProc(STR0033) // Levantando Modelos
	//
	nPerc := 0
	dData := stod((cQAlias)->( DATINI ))
	If !Empty( (cQAlias)->( DATINI ) )
		cQuery := "SELECT VN3_INDVLR"
		cQuery += "  FROM " + cNamVN3
		cQuery += " WHERE VN3_FILIAL = '"+cFilVN3+"'"
		cQuery += "   AND VN3_CODMAR = '"+(cQAlias)->( VV2_CODMAR )+"'"
		cQuery += "   AND VN3_MODVEI = '"+(cQAlias)->( VV2_MODVEI )+"'"
		cQuery += "   AND VN3_SEGMOD = '"+(cQAlias)->( VV2_SEGMOD )+"'"
		cQuery += "   AND VN3_TIPO   = '"+cTipRef+"'"
		cQuery += "   AND VN3_USRDES = ' '" // Ativado
		cQuery += "   AND VN3_DATINI = '"+(cQAlias)->( DATINI )+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		nPerc := FM_SQL(cQuery)
	EndIf
	//
	If nQtd++ > 0
		oModelMod:AddLine()
	EndIf
	oModelMod:LoadValue( "SELECT"     , lSelect )
	oModelMod:LoadValue( "VV2_CODMAR" , (cQAlias)->( VV2_CODMAR ) )
	oModelMod:LoadValue( "VV2_GRUMOD" , (cQAlias)->( VV2_GRUMOD ) )
	oModelMod:LoadValue( "VV2_MODVEI" , (cQAlias)->( VV2_MODVEI ) )
	oModelMod:LoadValue( "VV2_SEGMOD" , (cQAlias)->( VV2_SEGMOD ) )
	oModelMod:LoadValue( "VV2_TIPVEI" , (cQAlias)->( VV2_TIPVEI ) )
	oModelMod:LoadValue( "VV2_CATVEI" , (cQAlias)->( VV2_CATVEI ) )
	oModelMod:LoadValue( "PERATU"     , nPerc )
	oModelMod:LoadValue( "DATATU"     , dData )
	oModelMod:LoadValue( "PERNEW"     , nPerc )
	oModelMod:LoadValue( "DATNEW"     , IIf( dData < dDataBase , dDataBase , dData ) )
	//
	(cQAlias)->(dbSkip())
EndDo
(cQAlias)->(dbCloseArea())
oModelMod:SetNoInsertLine( .T. ) // NAO Deixa inserir linhas no Objeto
oModelMod:GoLine(1)
oView:Refresh()
Return .t.

/*/
{Protheus.doc} VA2520051_MarcarDesmarcar
Marcar/Desmarcar Grid dos Modelos

@author Andre Luis Almeida
@since 22/07/2021
/*/
Function VA2520051_MarcarDesmarcar()
Local nCntFor := 0
Local lSelect := oModelTik:GetValue("PARSELECT")
For nCntFor:= 1 to oModelMod:Length()
	oModelMod:GoLine(nCntFor)
	oModelMod:LoadValue( "SELECT" , lSelect )
Next
oModelMod:GoLine(1)
oView:Refresh()
Return .t.

/*/
{Protheus.doc} VA2520061_PreenchePerc
Tela para informar o Percentual e altera a Grid de Modelos

@author Andre Luis Almeida
@since 22/07/2021
/*/
Function VA2520061_PreenchePerc()
Local nCntFor  := 0
Local nPercAnt := 0
Local nPercRet := 0
Local aParams  := {}
Local aRetPar  := {}
Local aExec    := { "1="+STR0008 , "2="+STR0009 } // Todos registros do Filtro / Selecionados (ticados)
Local aOperac  := { "1="+STR0034 , "2="+STR0035 , "3="+STR0036 , "4="+STR0037 , "5="+STR0038 } // Fixar % / Somar % fixo / Somar com % / Subtrair % fixo / Subtrair com %
AADD(aParams,{2,STR0010,"1",aExec,100,"",.f.,}) // Quais Modelos
AADD(aParams,{2,STR0011,"1",aOperac,100,"",.f.,}) // Operação
AADD(aParams,{1,"%",0,"@E 999.999","Positivo()","",".T.",50,.f.}) // %
If ParamBox(aParams,STR0005,@aRetPar,,,,,,,,.f.)
	For nCntFor:= 1 to oModelMod:Length()
		oModelMod:GoLine(nCntFor)
		If aRetPar[1] == "1" .or. ( aRetPar[1] == "2" .and. oModelMod:GetValue("SELECT") )
			nPercAnt := oModelMod:GetValue("PERATU")
			Do Case
				Case aRetPar[2] == "1" // Fixar %
					nPercRet := aRetPar[3]
				Case aRetPar[2] == "2" // Somar % fixo
					nPercRet := nPercAnt + aRetPar[3]
				Case aRetPar[2] == "3" // Somar com %
					nPercRet := nPercAnt + ( (aRetPar[3]/100) * nPercAnt )
				Case aRetPar[2] == "4" // Subtrair % fixo
					nPercRet := nPercAnt - aRetPar[3]
				Case aRetPar[2] == "5" // Subtrair com %
					nPercRet := nPercAnt - ( (aRetPar[3]/100) * nPercAnt )
			EndCase
			If nPercRet < 0
				nPercRet := 0
			EndIf
			oModelMod:LoadValue( "PERNEW" , nPercRet )
		EndIf
	Next
	oModelMod:GoLine(1)
	oView:Refresh()
EndIf
Return .t.

/*/
{Protheus.doc} VA2520071_PreencheData
Tela para informar a Data e altera grids

@author Andre Luis Almeida
@since 22/07/2021
/*/
Function VA2520071_PreencheData()
Local nCntFor := 0
Local aParams := {}
Local aRetPar := {}
Local lOk     := .t.
Local aExec   := { "1="+STR0008 , "2="+STR0009 } // Todos registros do Filtro / Selecionados (ticados)
AADD(aParams,{2,STR0010,"1",aExec,100,"",.f.,}) // Quais Modelos
AADD(aParams,{1,STR0012,dDataBase,"@D","MV_PAR02 >= dDataBase","",".T.",50,.f.}) // Nova Data - Apartir de
If ParamBox(aParams,STR0006,@aRetPar,,,,,,,,.f.) // Preencher Data
	For nCntFor:= 1 to oModelMod:Length()
		oModelMod:GoLine(nCntFor)
		If aRetPar[1] == "1" .or. ( aRetPar[1] == "2" .and. oModelMod:GetValue("SELECT") )
			If aRetPar[2] <= oModelMod:GetValue("DATATU")
				lOk := .f.
				If MsgYesNo(STR0040,STR0039) // A Data informada é menor ou igual a Data de um ou mais registros de Referencia, dessa forma os registros de Referencia com data igual ou posterior serão desativados. Deseja Continuar? / Atenção
					lOk := .t.
				EndIf
				Exit
			EndIf
		EndIf
	Next
	If lOk
		For nCntFor:= 1 to oModelMod:Length()
			oModelMod:GoLine(nCntFor)
			If aRetPar[1] == "1" .or. ( aRetPar[1] == "2" .and. oModelMod:GetValue("SELECT") )
				oModelMod:LoadValue( "DATNEW" , aRetPar[2] )
			EndIf
		Next
	EndIf
	oModelMod:GoLine(1)
	oView:Refresh()
EndIf
Return .t.

/*/
{Protheus.doc} VA2520081_ValidaDataDigitada
Validacao da Data Informada na grid

@author Andre Luis Almeida
@since 22/07/2021
/*/
Function VA2520081_ValidaDataDigitada()
Local lRet := .t.
If oModelMod:GetValue("DATNEW") < dDataBase
	lRet := .f.
	MsgAlert(STR0041,STR0039) // Data Informada deve ser maior ou igual a data de hoje. / Atenção
Else
	If oModelMod:GetValue("DATNEW") <= oModelMod:GetValue("DATATU")
		If !MsgYesNo(STR0042,STR0039) // A Data Informada é menor ou igual a Data do registro de Referencia, dessa forma o registro de Referencia será desativado. Deseja Continuar? / Atenção
			lRet := .f.
		EndIf
	EndIf
EndIf
Return lRet

/*/
{Protheus.doc} VA2520091_OK_Tela
Ok da Tela - Grava VN3

@author Andre Luis Almeida
@since 23/07/2021
/*/
Static Function VA2520091_OK_Tela()
Local nCntFor := 0
Local lOk     := .f.
Local cQuery  := ""
Local cQAlias := "SQLVN3"
Local cNamVN3 := ""
Local cFilVN3 := ""
Local cTipVN3 := ""
Local cMarVN3 := ""
Local cModVN3 := ""
Local cSegVN3 := ""
Local dDatVN3 := ctod("")
Local nPerVN3 := 0
If oModelMod:Length() > 0
	For nCntFor := 1 to oModelMod:Length()
		oModelMod:GoLine(nCntFor)
		If oModelMod:GetValue("SELECT") .and. !Empty(oModelMod:GetValue("VV2_CODMAR"))
			lOk := .t.
			Exit
		EndIf
	Next
	If lOk
		If !MsgYesNo(STR0043,STR0039) // Somente os Modelos ticados serão gravados e todos os registros com a mesma data ou posterior a data informada da Marca/Modelo/Segmento serão desativados. Deseja Continuar? / Atencao
			lOk := .f.
		EndIf
	Else
		MsgStop(STR0044,STR0039) // Nenhum Modelo válido ticado. Impossivel continuar! / Atenção
	EndIf
	If lOk
		cNamVN3 := RetSqlName("VN3")
		cFilVN3 := xFilial("VN3")
		cTipVN3 := oModelPar:GetValue("PARTIPO")
		For nCntFor := 1 to oModelMod:Length()
			oModelMod:GoLine(nCntFor)
			If oModelMod:GetValue("SELECT")
				cMarVN3 := oModelMod:GetValue("VV2_CODMAR")
				If !Empty(cMarVN3)					
					cModVN3 := oModelMod:GetValue("VV2_MODVEI")
					cSegVN3 := oModelMod:GetValue("VV2_SEGMOD")
					dDatVN3 := oModelMod:GetValue("DATNEW")
					nPerVN3 := oModelMod:GetValue("PERNEW")
					// Necessário desativar registros com data posterior ou igual a data informada
					cQuery := "SELECT R_E_C_N_O_ AS RECVN3 "
					cQuery += "  FROM " + cNamVN3
					cQuery += " WHERE VN3_FILIAL = '"+cFilVN3+"' "
					cQuery += "   AND VN3_CODMAR = '"+cMarVN3+"' "
					cQuery += "   AND VN3_MODVEI = '"+cModVN3+"' "
					cQuery += "   AND VN3_SEGMOD = '"+cSegVN3+"' "
					cQuery += "   AND VN3_TIPO   = '"+cTipVN3+"' "
					cQuery += "   AND VN3_USRDES = ' ' " // ativo
					cQuery += "   AND VN3_DATINI >= '"+dtos(dDatVN3)+"' "
					cQuery += "   AND D_E_L_E_T_ = ' ' "
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F. , .T. )
					While !(cQAlias)->(Eof())
						VA2510011_Desativar( (cQAlias)->( RECVN3 ) , .f. )
						(cQAlias)->(dbSkip())
					EndDo
					(cQAlias)->(dbCloseArea())
					DbSelectArea("VN3")
					// Criar VN3 com o Novo Registro
					VA2510021_Incluir( cMarVN3 , cModVN3 , cSegVN3 , cTipVN3 , dDatVN3 , nPerVN3 )
				EndIf
			EndIf
		Next
		// Enviar E-mail de mudança na Lista de Preços dos Pacotes no final do processo
		VA2400171_EnviarEmail(.t.,.f.)
	EndIf
EndIf
Return lOk

/*/
{Protheus.doc} VA2520101_Campo_Tik
Cria Linha do Tik na Tela

@author Andre Luis Almeida
@since 27/07/2021
/*/
Static Function VA2520101_Campo_Tik()
Local oRetorno := OFDMSStruct():New()

oRetorno:AddButton(STR0045,'BTNPESQUISA',{ |oMdl| VA2520031_ProcessaLevantamentoModelos(oMdl) }) // FILTRAR MODELOS
oRetorno:AddSelect(STR0046,'PARSELECT', FWBuildFeature(STRUCT_FEATURE_VALID,"VA2520051_MarcarDesmarcar()") , .t.) // Marcar/Desmarcar Todos

Return oRetorno

/*/
{Protheus.doc} VA2520111_Carrega_Variaveis_para_F3
Carrega M->VV1_CODMAR/M->VV2_CODMAR para ser utilizado no F3 da Consulta de Modelos / Segmentos

@author Andre Luis Almeida
@since 28/07/2021
/*/
Function VA2520111_Carrega_Variaveis_para_F3(cCodMar)

M->VV1_CODMAR := M->VV2_CODMAR := cCodMar

Return .t.