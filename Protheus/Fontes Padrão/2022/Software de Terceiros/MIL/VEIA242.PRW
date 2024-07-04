#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "VEIA242.CH"

/*/{Protheus.doc} VEIA242
Consulta/Simulacao de Valores do Pacotes - Maquinas
Retorna Vetor com: Codigo do Pacote, Base Code, Valor Desejado e vetor com VQDs

@author Andre Luis Almeida
@since 14/07/2021
@version undefined

@type function
/*/
Function VEIA242( cCodMar , cModVei , cSegMod , cChaInt , lPARVlr )

	Local nOpcAviso    := 0
	Local cCodPac      := ""
	Local cDesPac      := ""
	Local aRetConsulta := { "" , "" , 0 , {""} } // ( Codigo Pacote , Base Code , Valor Desejado , Vetor com VQDs )
	
	Default lPARVlr    := .t.

	Private lTemVlr    := lPARVlr // Tela Trabalha com Valores ?
	Private oModel     := FWLoadModel("VEIA242")
	Private oView      := FWLoadView("VEIA242")
	Private oModelPar
	Private oModelPac
	Private oModelOpc

	If !Empty(cChaInt) // Se passar o CHAINT, validar se existe Pacote amarrado para o mesmo
		cCodPac := VA2400161_QualPacote( cChaInt )
		If !Empty(cCodPac)
			cDesPac := Alltrim(FM_SQL("SELECT VN0_DESPAC FROM "+RetSqlName("VN0")+" WHERE VN0_FILIAL='"+xFilial("VN0")+"' AND VN0_CODIGO='"+cCodPac+"' AND D_E_L_E_T_=' '"))
			nOpcAviso := AVISO(STR0001,; // Pacote de Configuração
						STR0002+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Existe um Pacote de Configuração relacionado a este Veículo/Máquina.
						Alltrim(RetTitle("VQE_CODPAC"))+": "+cCodPac+" - "+cDesPac+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
						STR0003,; // Deseja Visualizar ou Alterar o Pacote?
						{STR0004,STR0005,STR0006}, 3) // Alterar / Visualizar / Fechar
			If nOpcAviso == 2 // Visualizar
				VEIC140( cCodPac ) // Visualizar Pacote
				Return {}
			ElseIf nOpcAviso == 3 // Fechar
				Return {}
			EndIf
		EndIf
	EndIf

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	lRet := oModel:Activate()
	If !lRet
		Return {}
	EndIf
	
	// Carrega dados dos Parametros
	oModelPar := oModel:GetModel("PARMASTER")
	oModelPar:LoadValue("PARCODMAR" , cCodMar )
	oModelPar:LoadValue("PARMODVEI" , cModVei )
	oModelPar:LoadValue("PARSEGMOD" , cSegMod )
	oModelPar:LoadValue("PARDESMOD" , FM_SQL("SELECT VV2_DESMOD FROM "+RetSqlName("VV2")+" WHERE VV2_FILIAL='"+xFilial("VV2")+"' AND VV2_CODMAR='"+cCodMar+"' AND VV2_MODVEI='"+cModVei+"' AND VV2_SEGMOD='"+cSegMod+"' AND D_E_L_E_T_=' '") )
	oModelPar:LoadValue("PARDESMAX" , VA2500021_Retorna_Indice_VN3( cCodMar , cModVei , cSegMod , "3" , dDataBase ) ) // 3 - Desconto Maximo da Marca/Modelo/Segmento
	If VA2500021_Retorna_Indice_VN3( cCodMar , cModVei , cSegMod , "2" , dDataBase ) > 0
		oModelPar:LoadValue("PARFORPAG" , "2" ) // Default: 2 - A PRAZO
	Else
		oModelPar:LoadValue("PARFORPAG" , "1" ) // 1 - A VISTA
	EndIf
	oModelPar:LoadValue("PARDESDES" , 0 )

	// Carrega dados da GRID PACOTES e OPCIONAIS
	oModelPac := oModel:GetModel("LISTA_PACOTES")
	oModelOpc := oModel:GetModel("LISTA_OPCIONAIS")
	If !VA2420041_LevantaPacotes( cCodMar , cModVei , cSegMod )
		MsgStop(STR0008,STR0007) // Não existe(m) Pacote(s) relacionado(s) a Marca/Modelo/Segmento informado. / Atenção
		Return aClone(aRetConsulta)
	EndIf
	VA2420061_FormaPagamento(.f.)

	CursorArrow()
	oExecView := FWViewExec():New()
	oExecView:setModel(oModel)
	oExecView:setView(oView)
	oExecView:setOK( { || VA2420081_OK_Tela(@aRetConsulta) })
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

Return aClone(aRetConsulta)


Static Function ModelDef()

	Local oModel 
	Local oParametro := VA2420011_Campos_Parametros()
	Local oPacoteSel := VA2420021_Campos_Pacotes()
	Local oOpcionais := VA2420031_Campos_Opcionais()
	Local oParamStru := oParametro:GetModel()
	Local oPacotStru := oPacoteSel:GetModel()
	Local oOpcioStru := oOpcionais:GetModel()

	oModel := MPFormModel():New( 'VEIA242', /* bPre */, /* bPost */ , { || .t. } /* bCommit */ , { || .T. } /* bCancel */ )
	oModel:AddFields('PARMASTER', /* cOwner */ , oParamStru, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ )
	oModel:AddGrid('LISTA_PACOTES','PARMASTER',oPacotStru, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )
	oModel:AddGrid('LISTA_OPCIONAIS','LISTA_PACOTES',oOpcioStru, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )

	oModel:SetDescription(STR0009) // Consulta Pacotes por Modelo
	
	oModel:GetModel('PARMASTER'):SetDescription(STR0010) // Simulação
	oModel:GetModel('PARMASTER'):SetOnlyQuery( .T. )
	
	oModel:GetModel('LISTA_PACOTES'):SetDescription(STR0011) // Pacotes disponiveis para o Modelo
	oModel:GetModel("LISTA_PACOTES"):SetNoDeleteLine( .T. ) // NAO Deixa deletar linhas no Objeto
	oModel:GetModel('LISTA_PACOTES'):SetOnlyQuery( .T. )
	oModel:GetModel('LISTA_PACOTES'):SetOptional( .T. )
	
	oModel:GetModel('LISTA_OPCIONAIS'):SetDescription(STR0012) // Itens da Configuração do Pacote
	oModel:GetModel("LISTA_OPCIONAIS"):SetNoDeleteLine( .T. ) // NAO Deixa deletar linhas no Objeto
	oModel:GetModel('LISTA_OPCIONAIS'):SetOnlyQuery( .T. )
	oModel:GetModel('LISTA_OPCIONAIS'):SetOptional( .T. )

	oModel:SetRelation('LISTA_OPCIONAIS', { { 'VN1_FILIAL', 'VN0_FILIAL' }, { 'VN1_CODVN0', 'VN0_CODIGO' } })

	oModel:InstallEvent("VEIA242EVDEF", /*cOwner*/, VEIA242EVDEF():New("VEIA242") )

	oModel:SetPrimaryKey({})

Return oModel

Static Function ViewDef()
	Local oModel	:= FWLoadModel( 'VEIA242' )
	Local oView 	:= Nil
	Local oParametro := VA2420011_Campos_Parametros()
	Local oPacoteSel := VA2420021_Campos_Pacotes()
	Local oOpcionais := VA2420031_Campos_Opcionais()
	Local oParamStru := oParametro:GetView()
	Local oPacotStru := oPacoteSel:GetView()
	Local oOpcioStru := oOpcionais:GetView()

	If !lTemVlr // Tela NAO trabalha com Valores
		oParamStru:RemoveField('PARDESMAX')
		oParamStru:RemoveField('PARFORPAG')
		oParamStru:RemoveField('PARDESDES')
		oPacotStru:RemoveField('VLRINICIAL')
		oPacotStru:RemoveField('VLRTOTAL')
	EndIf

	oPacotStru:RemoveField('VN0_FILIAL')
	oPacotStru:RemoveField('VLRBASEAV')
	oPacotStru:RemoveField('VLRBASEAP')

	oOpcioStru:RemoveField('VN1_FILIAL')
	oOpcioStru:RemoveField('VN1_CODVN0')
	oOpcioStru:RemoveField('VQD_CODIGO')
	oOpcioStru:RemoveField('VQD_VALCON')

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FORM_PARAM', oParamStru , 'PARMASTER')
	oView:AddGrid('GRID_LISTA_PACOTES'  , oPacotStru , 'LISTA_PACOTES')
	oView:AddGrid('GRID_LISTA_OPCIONAIS', oOpcioStru , 'LISTA_OPCIONAIS')

	If lTemVlr
		oView:EnableTitleView('FORM_PARAM',STR0013) // Marca / Modelo / Forma de Pagamento / Desconto
	Else
		oView:EnableTitleView('FORM_PARAM',STR0014) // Marca / Modelo
	EndIf

	oView:SetNoInsertLine('GRID_LISTA_PACOTES')
	oView:SetNoDeleteLine('GRID_LISTA_PACOTES')
	oView:EnableTitleView('GRID_LISTA_PACOTES',STR0011) // Pacotes disponiveis para o Modelo
	
	oView:SetNoInsertLine('GRID_LISTA_OPCIONAIS')
	oView:SetNoDeleteLine('GRID_LISTA_OPCIONAIS')
	oView:EnableTitleView('GRID_LISTA_OPCIONAIS',STR0012) // Itens da Configuração do Pacote

	oView:CreateHorizontalBox('TELA_PARAM',220,,.t.)
	oView:CreateHorizontalBox('TELA_LISTA_PACOTES'  ,60)
	oView:CreateHorizontalBox('TELA_LISTA_OPCIONAIS',40)

	oView:SetOwnerView('FORM_PARAM','TELA_PARAM')
	oView:SetOwnerView('GRID_LISTA_PACOTES'  ,'TELA_LISTA_PACOTES')
	oView:SetOwnerView('GRID_LISTA_OPCIONAIS','TELA_LISTA_OPCIONAIS')

	oView:SetViewProperty( "GRID_LISTA_PACOTES", "SETCSS", { "QTableView { selection-background-color: #1C9DBD; }" } ) // Muda a cor da Linha para mostrar seleção

	oView:SetCloseOnOk({||.T.})

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o questionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 

	oView:SetViewProperty("GRID_LISTA_PACOTES"  , "GRIDSEEK", {.T.})
	oView:SetViewProperty("GRID_LISTA_OPCIONAIS", "GRIDSEEK", {.T.})
	
	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

Return oView

/*/
{Protheus.doc} VA2420011_Campos_Parametros
Monta Campos da Grid de Parametros/Simulação

@author Andre Luis Almeida
@since 14/07/2021
/*/
Static Function VA2420011_Campos_Parametros()
Local oRetorno := OFDMSStruct():New()

oRetorno:AddFieldDictionary( "VV2" , "VV2_CODMAR" , { { 'cIdField' , 'PARCODMAR' } , { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_MODVEI" , { { 'cIdField' , 'PARMODVEI' } , { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_SEGMOD" , { { 'cIdField' , 'PARSEGMOD' } , { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_DESMOD" , { { 'cIdField' , 'PARDESMOD' } , { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )

oRetorno:AddField({	{ 'cIdField'     , 'PARDESMAX' } ,;
					{ 'cTitulo'      , STR0015 } ,; // % Máximo Desconto
					{ 'cTooltip'     , STR0015 } ,; // % Máximo Desconto
					{ 'cTipo'        , 'N' } ,;
					{ 'nTamanho'     , 12 } ,;
					{ 'nDecimal'     , 8 },;
					{ 'cPicture'     , '@E 999.99999999'} ,;
					{ 'lVirtual'     , .t. } ,;
					{ 'lCanChange'   , .f. } } )

oRetorno:AddField({	{ 'cIdField'     , 'PARFORPAG' } ,;
					{ 'cTitulo'      , STR0016 } ,; // Forma de Pagamento
					{ 'cTooltip'     , STR0016 } ,; // Forma de Pagamento
					{ 'cTipo'        , 'C' } ,;
					{ 'nTamanho'     , 1 } ,;
					{ 'aComboValues' , { '1='+STR0017 , '2='+STR0018 } } ,; // A VISTA / A PRAZO
					{ 'bValid'       , FWBuildFeature(STRUCT_FEATURE_VALID,'VA2420061_FormaPagamento(.t.)') } ,;
					{ 'lVirtual'     , .t. } ,;
					{ 'lCanChange'   , .t. } })

oRetorno:AddField({	{ 'cIdField'     , 'PARDESDES' } ,;
					{ 'cTitulo'      , STR0019 } ,; // % Desconto Desejado
					{ 'cTooltip'     , STR0019 } ,; // % Desconto Desejado
					{ 'cTipo'        , 'N' } ,;
					{ 'nTamanho'     , 12 } ,;
					{ 'nDecimal'     , 8 },;
					{ 'cPicture'     , '@E 999.99999999'} ,;
					{ 'bValid'       , FWBuildFeature(STRUCT_FEATURE_VALID,'VA2420071_Calcular_Valor_Desejado(.t.,.f.)') } ,;
					{ 'lVirtual'     , .t. } ,;
					{ 'lCanChange'   , .t. } } )

Return oRetorno

/*/
{Protheus.doc} VA2420021_Campos_Pacotes
Monta Campos da Grid Pacotes do Modelo

@author Andre Luis Almeida
@since 14/07/2021
/*/
Static Function VA2420021_Campos_Pacotes()
Local oRetorno := OFDMSStruct():New()

oRetorno:AddFieldDictionary( "VN0", "VN0_FILIAL" , { { 'lVirtual'   , .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VN0", "VN0_CODIGO" , { { 'lVirtual'   , .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VN0", "VN0_DESPAC" , { { 'lVirtual'   , .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VN0", "VN0_BASCOD" , { { 'lVirtual'   , .t. } , { 'lCanChange' , .f. } } )

oRetorno:AddField({	{ 'cIdField'   , 'VLRINICIAL' },;
					{ 'cTitulo'    , STR0020 },; // Vlr Inicial
					{ 'cTipo'      , 'N' },;
					{ 'nTamanho'   , 12 },;
					{ 'nDecimal'   , 2 },;
					{ 'cPicture'   , '@E 999,999,999.99' } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .f. } } )

oRetorno:AddField({	{ 'cIdField'   , 'VLRTOTAL' },;
					{ 'cTitulo'    , STR0021 },; // Vlr Total com Desconto
					{ 'cTipo'      , 'N' },;
					{ 'nTamanho'   , 12 },;
					{ 'nDecimal'   , 2 },;
					{ 'cPicture'   , '@E 999,999,999.99' } ,;
					{ 'bValid'     , FWBuildFeature(STRUCT_FEATURE_VALID,'VA2420071_Calcular_Valor_Desejado(.t.,.t.)') } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .t. } } )

oRetorno:AddFieldDictionary( "VN0", "VN0_CFGBAS" , { { 'lVirtual'   , .t. } , { 'lCanChange' , .f. } } )

oRetorno:AddField({	{ 'cIdField'   , 'VLRBASEAV' },;
					{ 'cTitulo'    , STR0022 },; // Vlr Base A VISTA
					{ 'cTipo'      , 'N' },;
					{ 'nTamanho'   , 12 },;
					{ 'nDecimal'   , 2 },;
					{ 'cPicture'   , '@E 999,999,999.99' } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .f. } } )

oRetorno:AddField({	{ 'cIdField'   , 'VLRBASEAP' },;
					{ 'cTitulo'    , STR0023 },; // Vlr Base A PRAZO
					{ 'cTipo'      , 'N' },;
					{ 'nTamanho'   , 12 },;
					{ 'nDecimal'   , 2 },;
					{ 'cPicture'   , '@E 999,999,999.99' } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .f. } } )

Return oRetorno

/*/
{Protheus.doc} VA2420031_Campos_Opcionais
Monta Campos da Grid Opcionais do Pacote

@author Andre Luis Almeida
@since 14/07/2021
/*/
Static Function VA2420031_Campos_Opcionais()
Local oRetorno := OFDMSStruct():New()

oRetorno:AddFieldDictionary( "VN1", "VN1_FILIAL" , { { 'lVirtual' , .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VN1", "VN1_CODVN0" , { { 'lVirtual' , .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VJV", "VJV_CODOPC" , { { 'lVirtual' , .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VQD", "VQD_DESCRI" , { { 'lVirtual' , .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VQD", "VQD_DESUSR" , { { 'lVirtual' , .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VQD", "VQD_CODIGO" , { { 'lVirtual' , .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VQD", "VQD_VALCON" , { { 'lVirtual' , .t. } , { 'lCanChange' , .f. } } )

Return oRetorno

/*/
{Protheus.doc} VA2420041_LevantaPacotes
Levanta os Pacotes da Marca/Modelo/Segmento

@author Andre Luis Almeida
@since 07/07/2021
/*/
Static Function VA2420041_LevantaPacotes( cCodMar , cModVei , cSegMod )
Local oSqlHlp := DMS_SqlHelper():New()
Local cQVN2I  := ""
Local cQVN2F  := ""
Local cQuery  := ""
Local cQAlias := "SQLVN0"
Local nArred  := GetNewPar("MV_MIL0170",2) // Preços Pacotes - utilizar arredondamento (round). Exemplo: 2 = 2 casas decimais, 1 = 1 casa decimal, 0 = valor sem decimal
Local nMarkAV := VA2500021_Retorna_Indice_VN3(cCodMar,cModVei,cSegMod,"1",dDataBase) // 1 - Markup A VISTA
Local nMarkAP := VA2500021_Retorna_Indice_VN3(cCodMar,cModVei,cSegMod,"2",dDataBase) // 2 - Markup A PRAZO
Local nCusPct := 0
Local nQtdPct := 0
//
oModelPac:SetNoInsertLine( .f. ) // Deixa inserir linhas no Objeto
oModelOpc:SetNoInsertLine( .f. ) // Deixa inserir linhas no Objeto
// Inicio Query para pegar o Custo + Frete atual do Pacote
cQVN2I := "SELECT VN2_VALPAC + VN2_FREPAC "
cQVN2I += "  FROM " + RetSqlName("VN2")
cQVN2I += " WHERE VN2_FILIAL = '"+xFilial("VN2")+"' "
cQVN2I += "   AND VN2_CODVN0 = '"
// Final Query para pegar o Preço atual do Pacote
cQVN2F := "'  AND VN2_STATUS = '1' "
cQVN2F += "   AND VN2_DATINI <= '"+dtos(dDataBase)+"' "
cQVN2F += "   AND D_E_L_E_T_ = ' ' "
cQVN2F += " ORDER BY VN2_DATINI DESC "
//
cQuery := "SELECT VN0_FILIAL , VN0_CODIGO , VN0_DESPAC , VN0_CFGBAS , VN0_BASCOD "
cQuery += "  FROM " + RetSqlName("VN0")
cQuery += " WHERE VN0_FILIAL = '"+xFilial("VN0")+"' "
cQuery += "   AND VN0_CODMAR = '"+cCodMar+"' "
cQuery += "   AND VN0_MODVEI = '"+cModVei+"' "
cQuery += "   AND VN0_SEGMOD = '"+cSegMod+"' "
cQuery += "   AND VN0_STATUS = '1' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F. , .T. )
While !(cQAlias)->(Eof())
	nCusPct := FM_SQL(oSqlHlp:TOPFunc( cQVN2I + (cQAlias)->( VN0_CODIGO ) + cQVN2F ,1))
	If nQtdPct > 0
		oModelPac:AddLine()
	EndIf
	nQtdPct++
	oModelPac:LoadValue("VN0_FILIAL" , (cQAlias)->( VN0_FILIAL ) )
	oModelPac:LoadValue("VN0_CODIGO" , (cQAlias)->( VN0_CODIGO ) )
	oModelPac:LoadValue("VN0_DESPAC" , (cQAlias)->( VN0_DESPAC ) )
	oModelPac:LoadValue("VN0_CFGBAS" , (cQAlias)->( VN0_CFGBAS ) )
	oModelPac:LoadValue("VN0_BASCOD" , (cQAlias)->( VN0_BASCOD ) )
	oModelPac:LoadValue("VLRINICIAL" , 0 )
	oModelPac:LoadValue("VLRTOTAL"   , 0 )
	oModelPac:LoadValue("VLRBASEAV"  , IIf(nCusPct>0.and.nMarkAV>0,round(( nCusPct / nMarkAV ),nArred),0) )
	oModelPac:LoadValue("VLRBASEAP"  , IIf(nCusPct>0.and.nMarkAP>0,round(( nCusPct / nMarkAP ),nArred),0) )
	//
	VA2420051_LevantaOpcionais( (cQAlias)->( VN0_CODIGO ) )
	//
	(cQAlias)->(dbSkip())
EndDo
(cQAlias)->(dbCloseArea())
oModelPac:SetNoInsertLine( .T. ) // NAO Deixa inserir linhas no Objeto
oModelOpc:SetNoInsertLine( .T. ) // NAO Deixa inserir linhas no Objeto
oModelPac:GoLine(1)
Return (nQtdPct>0)

/*/
{Protheus.doc} VA2420051_LevantaOpcionais
Levanta Opcionais do Pacote para serem mostrados no relacionamento

@author Andre Luis Almeida
@since 07/07/2021
/*/
Static Function VA2420051_LevantaOpcionais(cVN0_CODIGO)
Local cQuery  := ""
Local cQAlias := "SQLVN1"
Local nQtdOpc := 0
//
cQuery := "SELECT VN1.VN1_FILIAL , VJV.VJV_CODOPC , VQD.VQD_DESCRI , VQD.VQD_DESUSR , VQD.VQD_CODIGO , VQD.VQD_VALCON "
cQuery += "  FROM " + RetSqlName("VN1")+" VN1"
cQuery += "  JOIN " + RetSqlName("VQD")+" VQD"
cQuery += "    ON VQD.VQD_FILIAL='"+xFilial("VQD")+"'"
cQuery += "   AND VQD.VQD_CODIGO=VN1.VN1_CODVQD"
cQuery += "   AND VQD.VQD_CODVQC=VN1.VN1_CODVQC"
cQuery += "   AND VQD.D_E_L_E_T_=' '"
cQuery += "  JOIN " + RetSqlName("VJV")+" VJV"
cQuery += "    ON VJV.VJV_FILIAL='"+xFilial("VJV")+"'"
cQuery += "   AND VJV.VJV_CODIGO=VQD.VQD_CODVJV"
cQuery += "   AND VJV.D_E_L_E_T_=' '"
cQuery += " WHERE VN1.VN1_FILIAL='"+xFilial("VN1")+"'"
cQuery += "   AND VN1.VN1_CODVN0='"+cVN0_CODIGO+"'"
cQuery += "   AND VN1.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F. , .T. )
While !(cQAlias)->(Eof())
	If nQtdOpc > 0
		oModelOpc:AddLine()
	EndIf
	nQtdOpc++
	oModelOpc:LoadValue("VN1_FILIAL" , (cQAlias)->( VN1_FILIAL ) )
	oModelOpc:LoadValue("VN1_CODVN0" , cVN0_CODIGO )
	oModelOpc:LoadValue("VJV_CODOPC" , (cQAlias)->( VJV_CODOPC ) )
	oModelOpc:LoadValue("VQD_DESCRI" , (cQAlias)->( VQD_DESCRI ) )
	oModelOpc:LoadValue("VQD_DESUSR" , (cQAlias)->( VQD_DESUSR ) )
	oModelOpc:LoadValue("VQD_CODIGO" , (cQAlias)->( VQD_CODIGO ) )
	oModelOpc:LoadValue("VQD_VALCON" , (cQAlias)->( VQD_VALCON ) )
	(cQAlias)->(dbSkip())
EndDo
(cQAlias)->(dbCloseArea())
oModelOpc:GoLine(1)
//
Return

/*/
{Protheus.doc} VA2420061_FormaPagamento
Troca Forma de Pagamento, muda o valor inicial relacionado ao Markup A VISTA / A PRAZO

@author Andre Luis Almeida
@since 07/07/2021
/*/
Function VA2420061_FormaPagamento(lRefresh)
Local nCntFor   := 0
Local aSaveLine := FwSaveRows()
Local cForPag   := oModelPar:GetValue("PARFORPAG") // Forma de Pagamento
Local cNomCpo   := IIf(cForPag=="1","VLRBASEAV","VLRBASEAP") // nome do campo que será Valor Base: A VISTA / A PRAZO
For nCntFor := 1 to oModelPac:Length()
	oModelPac:GoLine(nCntFor)
	oModelPac:LoadValue("VLRINICIAL",oModelPac:GetValue(cNomCpo))
Next
FWRestRows( aSaveLine )
VA2420071_Calcular_Valor_Desejado(lRefresh,.f.)
Return .t.

/*/
{Protheus.doc} VA2420071_Calcular_Valor_Desejado
Calcula o Valor Liquido com o Desconto Desejado

@author Andre Luis Almeida
@since 06/07/2021
/*/
Function VA2420071_Calcular_Valor_Desejado(lRefresh,lDigVlr)
Local nCntFor   := 0
Local aSaveLine := FwSaveRows()
Local nDesMax   := oModelPar:GetValue("PARDESMAX") // Desconto Maximo
Local nDesDes   := oModelPar:GetValue("PARDESDES") // Desconto Desejado
If lDigVlr // Digitado Valor na linha do Pacote - Faz calculo inverso para chegar no % de Desconto pelo valor Informado
	nDesDes := 100 - ( ( oModelPac:GetValue("VLRTOTAL") / oModelPac:GetValue("VLRINICIAL") ) * 100 )
	oModelPar:LoadValue("PARDESDES",nDesDes)
EndIf
If nDesDes > nDesMax
	MsgAlert(STR0024,STR0007) // Desconto informado maior que o permitido! Será utilizado o desconto máximo. / Atenção
	nDesDes := nDesMax
	oModelPar:LoadValue("PARDESDES",nDesDes)
EndIf
For nCntFor := 1 to oModelPac:Length()
	oModelPac:GoLine(nCntFor)
	oModelPac:LoadValue("VLRTOTAL",( oModelPac:GetValue("VLRINICIAL") - ( oModelPac:GetValue("VLRINICIAL") * ( nDesDes / 100 ) ) ) )
Next
FWRestRows( aSaveLine )
If lRefresh
	oView:Refresh()
EndIf
Return .t.

/*/
{Protheus.doc} VA2420081_OK_Tela
Ok da Tela - carrega Vetor de retorno da Consulta com: Codigo do Pacote, Base Code, Valor Desejado e VQDs

@author Andre Luis Almeida
@since 07/07/2021
/*/
Static Function VA2420081_OK_Tela(aRetConsulta)
Local nCntFor  := 0
Local aRetVQDs := {}
If oModelOpc:Length() > 0
	For nCntFor := 1 to oModelOpc:Length()
		oModelOpc:GoLine(nCntFor)
		If !Empty(oModelOpc:GetValue("VQD_CODIGO"))
			aAdd(aRetVQDs,{  oModelOpc:GetValue("VQD_CODIGO") , oModelOpc:GetValue("VQD_VALCON") } )
		EndIf
	Next
EndIf
aRetConsulta := { oModelPac:GetValue("VN0_CODIGO") , oModelPac:GetValue("VN0_BASCOD") , oModelPac:GetValue("VLRTOTAL") , aClone(aRetVQDs) } // Pacote selecionado -> ( Codigo Pacote , Base Code , Valor Desejado , Vetor com VQDs )
Return .t.