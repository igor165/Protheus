#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "VEIA244.CH"

/*/{Protheus.doc} VEIA244
Ajuste Geral dos Custos dos Pacotes

@author Andre Luis Almeida
@since 26/07/2021
@version undefined

@type function
/*/
Function VEIA244()
	Private oModel     := FWLoadModel("VEIA244")
	Private oView      := FWLoadView("VEIA244")
	Private oModelPar
	Private oModelTik
	Private oModelPac
	Private M->VV1_CODMAR := "" // Utilizado no F3 do Modelo
	Private M->VV2_CODMAR := "" // Utilizado no F3 do Segmento

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	lRet := oModel:Activate()
	If !lRet
		Return {}
	EndIf

	oModelPar := oModel:GetModel("FILTRO")
	oModelPar:LoadValue( "PARSTATUS" , "3" ) // 3 = Todos Status
	oModelPar:LoadValue( "PARREFDATA", "1" ) // 1 = Vigorando Hoje
	
	oModelTik := oModel:GetModel("TIK")
	oModelTik:LoadValue( "PARSELECT" , .f. ) // TIK para Marcar/Desmarcar Pacotes

	oModelPac := oModel:GetModel("LISTA_PACOTES")

	CursorArrow()
	oExecView := FWViewExec():New()
	oExecView:setModel(oModel)
	oExecView:setView(oView)
	oExecView:setOK( { || VA2440091_OK_Tela() })
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

Return NIL


Static Function ModelDef()

	Local oModel 
	Local oFiltros := VA2440011_Campos_Filtro()
	Local oPacotes := VA2440021_Campos_Pacotes()
	Local oTik     := VA2440101_Campo_Tik()
	Local oFilStru := oFiltros:GetModel()
	Local oPacStru := oPacotes:GetModel()
	Local oTikStru := oTik:GetModel()
	
	oPacStru:SetProperty( 'VN0_CODIGO' , MODEL_FIELD_INIT,{|| "" })

	oModel := MPFormModel():New( 'VEIA244', /* bPre */, /* bPost */ , { || .t. } /* bCommit */ , { || .T. } /* bCancel */ )
	oModel:AddFields('FILTRO', /* cOwner */ , oFilStru, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ )
	oModel:AddFields('TIK', 'FILTRO' , oTikStru, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ )
	oModel:AddGrid('LISTA_PACOTES','FILTRO',oPacStru, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )

	oModel:SetDescription(STR0001) // Custos dos Pacotes
	
	oModel:GetModel('FILTRO'):SetDescription(STR0002) // Filtro
	oModel:GetModel('FILTRO'):SetOnlyQuery( .T. )

	oModel:GetModel('TIK'):SetDescription('Tik') // Tik
	oModel:GetModel('TIK'):SetOnlyQuery( .T. )

	oModel:GetModel('LISTA_PACOTES'):SetDescription(STR0003) // Pacotes
	oModel:GetModel("LISTA_PACOTES"):SetNoDeleteLine( .T. ) // NAO Deixa deletar linhas no Objeto
	oModel:GetModel('LISTA_PACOTES'):SetOnlyQuery( .T. )
	oModel:GetModel('LISTA_PACOTES'):SetOptional( .T. )
	
	oModel:SetPrimaryKey({})

Return oModel

Static Function ViewDef()
	Local oModel   := FWLoadModel( 'VEIA244' )
	Local oView    := Nil
	Local oFiltros := VA2440011_Campos_Filtro()
	Local oPacotes := VA2440021_Campos_Pacotes()
	Local oTik     := VA2440101_Campo_Tik()
	Local oFilStru := oFiltros:GetView()
	Local oPacStru := oPacotes:GetView()
	Local oTikStru := oTik:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FORM_FILTRO', oFilStru , 'FILTRO')
	oView:AddField('FORM_TIK', oTikStru , 'TIK')
	oView:AddGrid('GRID_LISTA_PACOTES', oPacStru , 'LISTA_PACOTES')

	oView:EnableTitleView('FORM_FILTRO',STR0002) // Filtro

	oView:SetNoInsertLine('GRID_LISTA_PACOTES')
	oView:SetNoDeleteLine('GRID_LISTA_PACOTES')
	oView:EnableTitleView('GRID_LISTA_PACOTES',STR0003) // Pacotes
	
	oView:CreateHorizontalBox('TELA_FILTRO',40)
	oView:CreateHorizontalBox('TELA_TIK',80,,.t.)
	oView:CreateHorizontalBox('TELA_LISTA_PACOTES',60)

	oView:SetOwnerView('FORM_FILTRO','TELA_FILTRO')
	oView:SetOwnerView('FORM_TIK','TELA_TIK')
	oView:SetOwnerView('GRID_LISTA_PACOTES','TELA_LISTA_PACOTES')

	oView:SetCloseOnOk({||.T.})

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o questionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 

	oView:SetViewProperty("GRID_LISTA_PACOTES"  , "GRIDSEEK", {.T.})

	// Criar novo botao na barra de botoes
	oView:AddUserButton(STR0004,'CLIPS',{ |oView| VEIC140( oModelPac:GetValue("VN0_CODIGO") ) }) // Visualizar Pacote posicionado
	oView:AddUserButton(STR0005,'CLIPS',{ |oView| VA2440061_PreencheCustoFrete(1) }) // Preencher Custo
	oView:AddUserButton(STR0006,'CLIPS',{ |oView| VA2440061_PreencheCustoFrete(2) }) // Preencher Frete
	oView:AddUserButton(STR0007,'CLIPS' ,{ |oView| VA2440071_PreencheData() }) // Preencher Data

	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

Return oView

/*/
{Protheus.doc} VA2440011_Campos_Filtro
Monta Campos da Grid de FILTRO/Simulação

@author Andre Luis Almeida
@since 26/07/2021
/*/
Static Function VA2440011_Campos_Filtro()
Local oRetorno := OFDMSStruct():New()

oRetorno:AddFieldDictionary( "VV2" , "VV2_CODMAR" , { { 'cIdField' , 'PARCODMAR' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } , { 'bValid', FWBuildFeature(STRUCT_FEATURE_VALID,'(vazio().or.FG_Seek("VE1","M->PARCODMAR",1,.f.)).and.VA2440111_Carrega_Variaveis_para_F3(M->PARCODMAR)') } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_GRUMOD" , { { 'cIdField' , 'PARGRUMOD' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } , { 'bValid', FWBuildFeature(STRUCT_FEATURE_VALID,'vazio().or.FG_Seek("VVR","M->PARCODMAR+M->PARGRUMOD",2,.f.)') } } )
oRetorno:AddFieldDictionary( "VV1" , "VV1_MODVEI" , { { 'cIdField' , 'PARMODVEI' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } , { 'bValid', FWBuildFeature(STRUCT_FEATURE_VALID,'vazio().or.FG_Seek("VV2","M->PARCODMAR+M->PARMODVEI",1,.f.)') } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_SEGMOD" , { { 'cIdField' , 'PARSEGMOD' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } , { 'bValid', FWBuildFeature(STRUCT_FEATURE_VALID,'vazio().or.FG_Seek("VV2","M->PARCODMAR+M->PARMODVEI+M->PARSEGMOD",1,.f.)') } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_TIPVEI" , { { 'cIdField' , 'PARTIPVEI' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } , { 'bValid', FWBuildFeature(STRUCT_FEATURE_VALID,'vazio().or.FG_Seek("VV8","M->PARTIPVEI",1,.f.)') } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_CATVEI" , { { 'cIdField' , 'PARCATVEI' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } , { 'bValid', FWBuildFeature(STRUCT_FEATURE_VALID,'vazio().or.FG_Seek("VVB","M->PARCATVEI",1,.f.)') } } )
oRetorno:AddFieldDictionary( "VN0" , "VN0_BASCOD" , { { 'cIdField' , 'PARBASCOD' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } , { 'bValid', FWBuildFeature(STRUCT_FEATURE_VALID,'vazio().or.FG_Seek("VX5","'+"'082'"+'+M->PARBASCOD",1)') } } )

oRetorno:AddField({	{ 'cIdField'     , 'PARSTATUS' } ,;
					{ 'cTitulo'      , STR0008 } ,; // Status do Pacote
					{ 'cTooltip'     , STR0008 } ,; // Status de Pacote
					{ 'cTipo'        , 'C' } ,;
					{ 'nTamanho'     , 1 } ,;
					{ 'aComboValues' , { '0='+STR0009 , '1='+STR0010 , '2='+STR0011 , '3='+STR0012 } } ,; // Pendente / Ativado / Desativado / Todos
					{ 'bValid'       , FWBuildFeature(STRUCT_FEATURE_VALID,'Pertence("0123")') } ,;
					{ 'lVirtual'     , .t. } ,;
					{ 'lCanChange'   , .t. } })

oRetorno:AddField({	{ 'cIdField'     , 'PARREFDATA' } ,;
					{ 'cTitulo'      , STR0013 } ,; // Referencia para a Data
					{ 'cTooltip'     , STR0013 } ,; // Referencia para a Data
					{ 'cTipo'        , 'C' } ,;
					{ 'nTamanho'     , 1 } ,;
					{ 'aComboValues' , { '1='+STR0014 , '2='+STR0015 } } ,; // Vigorando Hoje / Ultima Data
					{ 'bValid'       , FWBuildFeature(STRUCT_FEATURE_VALID,'Pertence("12")') } ,;
					{ 'lVirtual'     , .t. } ,;
					{ 'lCanChange'   , .t. } })

Return oRetorno

/*/
{Protheus.doc} VA2440021_Campos_Pacotes
Monta Campos da Grid dos Pacotes

@author Andre Luis Almeida
@since 26/07/2021
/*/
Static Function VA2440021_Campos_Pacotes()
Local oRetorno := OFDMSStruct():New()

oRetorno:AddSelect('','SELECT', , .t.)
oRetorno:AddFieldDictionary( "VN0" , "VN0_CODIGO" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VN0" , "VN0_DESPAC" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VN0" , "VN0_STATUS" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )

oRetorno:AddField({	{ 'cIdField'   , 'DATATU' },;
					{ 'cTitulo'    , STR0016 },; // Data de Referencia
					{ 'cTipo'      , 'D' },;
					{ 'nTamanho'   , 8 },;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .f. } } )

oRetorno:AddField({	{ 'cIdField'   , 'CUSATU' },;
					{ 'cTitulo'    , STR0017 },; // Custo
					{ 'cTipo'      , 'N' },;
					{ 'nTamanho'   , 12 },;
					{ 'nDecimal'   , 2 },;
					{ 'cPicture'   , '@E 999,999,999.99' } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .f. } } )

oRetorno:AddField({	{ 'cIdField'   , 'FREATU' },;
					{ 'cTitulo'    , STR0018 },; // Frete
					{ 'cTipo'      , 'N' },;
					{ 'nTamanho'   , 12 },;
					{ 'nDecimal'   , 2 },;
					{ 'cPicture'   , '@E 999,999,999.99' } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .f. } } )

oRetorno:AddField({	{ 'cIdField'   , 'DATNEW' },;
					{ 'cTitulo'    , STR0019 },; // Nova Data - Apartir de
					{ 'cTipo'      , 'D' },;
					{ 'nTamanho'   , 8 },;
					{ 'bValid'     , FWBuildFeature(STRUCT_FEATURE_VALID,'VA2440081_ValidaDataDigitada()') } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .t. } } )

oRetorno:AddField({	{ 'cIdField'   , 'CUSNEW' },;
					{ 'cTitulo'    , STR0020 },; // Novo Custo
					{ 'cTipo'      , 'N' },;
					{ 'nTamanho'   , 12 },;
					{ 'nDecimal'   , 2 },;
					{ 'cPicture'   , '@E 999,999,999.99' } ,;
					{ 'bValid'     , FWBuildFeature(STRUCT_FEATURE_VALID,'Positivo()') } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .t. } } )

oRetorno:AddField({	{ 'cIdField'   , 'FRENEW' },;
					{ 'cTitulo'    , STR0021 },; // Novo Frete
					{ 'cTipo'      , 'N' },;
					{ 'nTamanho'   , 12 },;
					{ 'nDecimal'   , 2 },;
					{ 'cPicture'   , '@E 999,999,999.99' } ,;
					{ 'bValid'     , FWBuildFeature(STRUCT_FEATURE_VALID,'Positivo()') } ,;
					{ 'lVirtual'   , .t. } ,;
					{ 'lCanChange' , .t. } } )

oRetorno:AddFieldDictionary( "VN0" , "VN0_BASCOD" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VN0" , "VN0_CODMAR" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_GRUMOD" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VN0" , "VN0_MODVEI" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VN0" , "VN0_SEGMOD" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_TIPVEI" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "VV2" , "VV2_CATVEI" , { { 'lVirtual', .t. } , { 'lCanChange' , .f. } } )

Return oRetorno

/*/
{Protheus.doc} VA2440031_ProcessaLevantamentoPacotes
Chamada do Levantamento dos Pacotes

@author Andre Luis Almeida
@since 26/07/2021
/*/
Function VA2440031_ProcessaLevantamentoPacotes()

Processa({|| VA2440041_LevantaPacotes() })

Return .t.

/*/
{Protheus.doc} VA2440041_LevantaPacotes
Levanta os Pacotes

@author Andre Luis Almeida
@since 26/07/2021
/*/
Static Function VA2440041_LevantaPacotes()
Local oSqlHlp := DMS_SqlHelper():New()
Local cQuery  := ""
Local cQAlias := "SQLVN0"
Local nCust   := 0
Local nFret   := 0
Local dData   := cTod("")
Local nQtd    := 0
Local aAux    := {}
Local dDatRef := IIf(oModelPar:GetValue("PARREFDATA")=="1",dDataBase,dDataBase+9999)
Local lSelect := oModelTik:GetValue("PARSELECT")
Local cNamVN2 := RetSqlName("VN2")
Local cFilVN2 := xFilial("VN2")
Local aCpoSQL := { "VN0_CODIGO" , "VN0_DESPAC" , "VN0_STATUS" , "VN0_BASCOD" , "VN0_CODMAR" , "VN0_MODVEI" , "VN0_SEGMOD" , "VV2_GRUMOD" , "VV2_TIPVEI" , "VV2_CATVEI" }
Local nCntFor := 0
//
oModelPac:ClearData(.t.) // Limpa TOTAL a Grid de Pacotes
oModelPac:SetNoInsertLine( .f. ) // Deixa inserir linhas no Objeto
//
cQuery := "SELECT "
For nCntFor := 1 to len(aCpoSQL)
	cQuery += "TAGR."+aCpoSQL[nCntFor]+" , "
Next
cQuery += "MAX(TAGR.DATINI) AS DATINI "
cQuery += "FROM ( "
cQuery += "SELECT "
For nCntFor := 1 to len(aCpoSQL)
	cQuery += "TORD."+aCpoSQL[nCntFor]+" , "
Next
cQuery += "TORD.DATINI "
cQuery += "FROM ("
cQuery += " SELECT "
For nCntFor := 1 to len(aCpoSQL)
	cQuery += left(aCpoSQL[nCntFor],3)+"."+aCpoSQL[nCntFor]+" , "
Next
cQuery += "       VN2.VN2_DATINI AS DATINI "
cQuery += "  FROM " + RetSqlName("VN0")+" VN0 "
cQuery += "  JOIN " + RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VN0.VN0_CODMAR AND VV2.VV2_MODVEI=VN0.VN0_MODVEI AND VV2.VV2_SEGMOD=VN0.VN0_SEGMOD AND VV2.D_E_L_E_T_ = ' ' ) "
cQuery += "  LEFT JOIN " + RetSqlName("VN2")+" VN2 ON ( VN2.VN2_FILIAL='"+xFilial("VN2")+"' AND VN2.VN2_CODVN0=VN0.VN0_CODIGO AND VN2.VN2_STATUS='1' AND VN2.VN2_DATINI <= '"+dtos(dDatRef)+"' AND VN2.D_E_L_E_T_ = ' ' ) "
cQuery += " WHERE VN0.VN0_FILIAL = '"+xFilial("VN0")+"' "
If !Empty(oModelPar:GetValue("PARCODMAR"))
	cQuery += " AND VN0.VN0_CODMAR = '"+oModelPar:GetValue("PARCODMAR")+"' "
EndIf
If !Empty(oModelPar:GetValue("PARMODVEI"))
	cQuery += " AND VN0.VN0_MODVEI = '"+oModelPar:GetValue("PARMODVEI")+"' "
EndIf
If !Empty(oModelPar:GetValue("PARSEGMOD"))
	cQuery += " AND VN0.VN0_SEGMOD = '"+oModelPar:GetValue("PARSEGMOD")+"' "
EndIf
If !Empty(oModelPar:GetValue("PARBASCOD"))
	cQuery += " AND VN0.VN0_BASCOD = '"+oModelPar:GetValue("PARBASCOD")+"' "
EndIf
If oModelPar:GetValue("PARSTATUS") <> "3"
	cQuery += " AND VN0.VN0_STATUS = '"+oModelPar:GetValue("PARSTATUS")+"' "
EndIf
If !Empty(oModelPar:GetValue("PARGRUMOD"))
	cQuery += " AND VV2.VV2_GRUMOD = '"+oModelPar:GetValue("PARGRUMOD")+"' "
EndIf
If !Empty(oModelPar:GetValue("PARTIPVEI"))
	cQuery += " AND VV2.VV2_TIPVEI = '"+oModelPar:GetValue("PARTIPVEI")+"' "
EndIf
If !Empty(oModelPar:GetValue("PARCATVEI"))
	cQuery += " AND VV2.VV2_CATVEI = '"+oModelPar:GetValue("PARCATVEI")+"' "
EndIf
cQuery += " AND VN0.D_E_L_E_T_ = ' ' "
cQuery += " ) TORD "
cQuery += " ) TAGR "
cQuery += "GROUP BY "
For nCntFor := 1 to len(aCpoSQL)
	cQuery += "TAGR."+aCpoSQL[nCntFor]
	If nCntFor < len(aCpoSQL)
		cQuery += " , "
	EndIf
Next
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F. , .T. )
ProcRegua( (cQAlias)->(RecCount()) )
While !(cQAlias)->(Eof())
	//
	IncProc(STR0022) // Levantando Pacotes
	//
	nCust := 0
	nFret := 0
	dData := stod( (cQAlias)->( DATINI ) )
	If !Empty( (cQAlias)->( DATINI ) )
		cQuery := "SELECT VN2_VALPAC , VN2_FREPAC"
		cQuery += "  FROM " + cNamVN2
		cQuery += " WHERE VN2_FILIAL = '"+cFilVN2+"'"
		cQuery += "   AND VN2_CODVN0 = '"+(cQAlias)->( VN0_CODIGO )+"'"
		cQuery += "   AND VN2_STATUS = '1'" // Ativado
		cQuery += "   AND VN2_DATINI = '"+(cQAlias)->( DATINI )+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		aAux  := oSqlHlp:GetSelectArray(cQuery,2)
		nCust := aAux[1,1]
		nFret := aAux[1,2]
	EndIf
	//
	If nQtd++ > 0
		oModelPac:AddLine()
	EndIf
	oModelPac:LoadValue( "SELECT"     , lSelect )
	oModelPac:LoadValue( "VN0_CODIGO" , (cQAlias)->( VN0_CODIGO ) )
	oModelPac:LoadValue( "VN0_DESPAC" , (cQAlias)->( VN0_DESPAC ) )
	oModelPac:LoadValue( "VN0_STATUS" , (cQAlias)->( VN0_STATUS ) )
	oModelPac:LoadValue( "CUSATU"     , nCust )
	oModelPac:LoadValue( "FREATU"     , nFret )
	oModelPac:LoadValue( "DATATU"     , dData )
	oModelPac:LoadValue( "CUSNEW"     , nCust )
	oModelPac:LoadValue( "FRENEW"     , nFret )
	oModelPac:LoadValue( "DATNEW"     , IIf(dData<dDataBase,dDataBase,dData) )
	oModelPac:LoadValue( "VN0_BASCOD" , (cQAlias)->( VN0_BASCOD ) )
	oModelPac:LoadValue( "VN0_CODMAR" , (cQAlias)->( VN0_CODMAR ) )
	oModelPac:LoadValue( "VV2_GRUMOD" , (cQAlias)->( VV2_GRUMOD ) )
	oModelPac:LoadValue( "VN0_MODVEI" , (cQAlias)->( VN0_MODVEI ) )
	oModelPac:LoadValue( "VN0_SEGMOD" , (cQAlias)->( VN0_SEGMOD ) )
	oModelPac:LoadValue( "VV2_TIPVEI" , (cQAlias)->( VV2_TIPVEI ) )
	oModelPac:LoadValue( "VV2_CATVEI" , (cQAlias)->( VV2_CATVEI ) )
	//
	(cQAlias)->(dbSkip())
EndDo
(cQAlias)->(dbCloseArea())
oModelPac:SetNoInsertLine( .T. ) // NAO Deixa inserir linhas no Objeto
oModelPac:GoLine(1)
oView:Refresh()
Return .t.

/*/
{Protheus.doc} VA2440051_MarcarDesmarcar
Marcar/Desmarcar Grid dos Pacotes

@author Andre Luis Almeida
@since 26/07/2021
/*/
Function VA2440051_MarcarDesmarcar()
Local nCntFor := 0
Local lSelect := oModelTik:GetValue("PARSELECT")
For nCntFor:= 1 to oModelPac:Length()
	oModelPac:GoLine(nCntFor)
	oModelPac:LoadValue( "SELECT" , lSelect )
Next
oModelPac:GoLine(1)
oView:Refresh()
Return .t.

/*/
{Protheus.doc} VA2440061_PreencheCustoFrete
Tela para informar o Percentual de Custo ou Frete e altera a Grid de Pacotes

@author Andre Luis Almeida
@since 26/07/2021
/*/
Function VA2440061_PreencheCustoFrete(nTp)
Local nCntFor := 0
Local nAuxAnt := 0
Local nAuxRet := 0
Local aParams := {}
Local aRetPar := {}
Local aExec   := { "1="+STR0023 , "2="+STR0024 } // Todos registros do Filtro / Selecionados (ticados)
Local aOperac := { "1="+STR0025 , "2="+STR0026 , "3="+STR0027 , "4="+STR0028 , "5="+STR0029 } // Fixar Valor / Somar Valor / Somar com % / Subtrair Valor / Subtrair com %
Local cTit    := IIf(nTp==1,STR0030,STR0031) // Preencher Custo / Preencher Frete
Local cNom    := IIf(nTp==1,"CUS","FRE")
AADD(aParams,{2,STR0032,"1",aExec,100,"",.f.,}) // Quais Pacotes
AADD(aParams,{2,STR0033,"1",aOperac,100,"",.f.,}) // Operação
AADD(aParams,{1,STR0034,0,"@E 999,999,999.99","Positivo()","","(MV_PAR02$'124')",80,.f.}) // Valor
AADD(aParams,{1,"%",0,"@E 999.999","Positivo()","","(MV_PAR02$'35')",50,.f.}) // %
If ParamBox(aParams,cTit,@aRetPar,,,,,,,,.f.)
	For nCntFor:= 1 to oModelPac:Length()
		oModelPac:GoLine(nCntFor)
		If aRetPar[1] == "1" .or. ( aRetPar[1] == "2" .and. oModelPac:GetValue("SELECT") )
			nAuxAnt := oModelPac:GetValue(cNom+"ATU")
			Do Case
				Case aRetPar[2] == "1" // Fixar Valor
					nAuxRet := aRetPar[3]
				Case aRetPar[2] == "2" // Somar Valor
					nAuxRet := nAuxAnt + aRetPar[3]
				Case aRetPar[2] == "3" // Somar com %
					nAuxRet := nAuxAnt + ( (aRetPar[4]/100) * nAuxAnt )
				Case aRetPar[2] == "4" // Subtrair Valor
					nAuxRet := nAuxAnt - aRetPar[3]
				Case aRetPar[2] == "5" // Subtrair com %
					nAuxRet := nAuxAnt - ( (aRetPar[4]/100) * nAuxAnt )
			EndCase
			If nAuxRet < 0
				nAuxRet := 0
			EndIf
			oModelPac:LoadValue(cNom+"NEW",nAuxRet)
		EndIf
	Next
	oModelPac:GoLine(1)
	oView:Refresh()
EndIf
Return .t.

/*/
{Protheus.doc} VA2440071_PreencheData
Tela para informar a Data e altera grids

@author Andre Luis Almeida
@since 26/07/2021
/*/
Function VA2440071_PreencheData()
Local nCntFor := 0
Local aParams := {}
Local aRetPar := {}
Local lOk     := .t.
Local aExec   := { "1="+STR0023 , "2="+STR0024 } // Todos registros do Filtro / Selecionados (ticados)
AADD(aParams,{2,STR0032,"1",aExec,100,"",.f.,}) // Quais Pacotes
AADD(aParams,{1,STR0019,dDataBase,"@D","MV_PAR02 >= dDataBase","",".T.",50,.f.}) // Nova Data - Apartir de
If ParamBox(aParams,STR0035,@aRetPar,,,,,,,,.f.) // Preencher Data
	For nCntFor:= 1 to oModelPac:Length()
		oModelPac:GoLine(nCntFor)
		If aRetPar[1] == "1" .or. ( aRetPar[1] == "2" .and. oModelPac:GetValue("SELECT") )
			If aRetPar[2] <= oModelPac:GetValue("DATATU")
				lOk := .f.
				If MsgYesNo(STR0037,STR0036) // A Data informada é menor ou igual a Data de um ou mais registros de Referencia, dessa forma os registros de Referencia com data igual ou posterior serão desativados. Deseja Continuar? / Atenção
					lOk := .t.
				EndIf
				Exit
			EndIf
		EndIf
	Next
	If lOk
		For nCntFor:= 1 to oModelPac:Length()
			oModelPac:GoLine(nCntFor)
			If aRetPar[1] == "1" .or. ( aRetPar[1] == "2" .and. oModelPac:GetValue("SELECT") )
				oModelPac:LoadValue( "DATNEW" , aRetPar[2] )
			EndIf
		Next
	EndIf
	oModelPac:GoLine(1)
	oView:Refresh()
EndIf
Return .t.

/*/
{Protheus.doc} VA2440081_ValidaDataDigitada
Validacao da Data Informada na grid

@author Andre Luis Almeida
@since 22/07/2021
/*/
Function VA2440081_ValidaDataDigitada()
Local lRet := .t.
If oModelPac:GetValue("DATNEW") < dDataBase
	lRet := .f.
	MsgAlert(STR0038,STR0036) // Data Informada deve ser maior ou igual a data de hoje. / Atenção
Else
	If oModelPac:GetValue("DATNEW") <= oModelPac:GetValue("DATATU")
		If !MsgYesNo(STR0039,STR0036) // A Data Informada é menor ou igual a Data do registro de Referencia, dessa forma o registro de Referencia será desativado. Deseja Continuar? / Atenção
			lRet := .f.
		EndIf
	EndIf
EndIf
Return lRet

/*/
{Protheus.doc} VA2440091_OK_Tela
Ok da Tela - Grava VN2

@author Andre Luis Almeida
@since 26/07/2021
/*/
Static Function VA2440091_OK_Tela()
Local nCntFor := 0
Local lOk     := .f.
Local cQuery  := ""
Local cQAlias := "SQLVN2"
Local cNamVN2 := ""
Local cFilVN2 := ""
Local dDatVN2 := ctod("")
Local nCusVN2 := 0
Local nFreVN2 := 0
If oModelPac:Length() > 0
	For nCntFor := 1 to oModelPac:Length()
		oModelPac:GoLine(nCntFor)
		If oModelPac:GetValue("SELECT") .and. !Empty(oModelPac:GetValue("VN0_CODIGO"))
			lOk := .t.
			Exit
		EndIf
	Next
	If lOk
		If !MsgYesNo(STR0040,STR0036) // Somente os Pacotes ticados serão gravados e todos os registros com a mesma data ou posterior a data informada serão desativados. Deseja Continuar? / Atencao
			lOk := .f.
		EndIf
	Else
		MsgStop(STR0041,STR0036) // Nenhum Pacote válido ticado. Impossivel continuar! / Atenção
	EndIf
	If lOk
		cNamVN2 := RetSqlName("VN2")
		cFilVN2 := xFilial("VN2")
		For nCntFor := 1 to oModelPac:Length()
			oModelPac:GoLine(nCntFor)
			If oModelPac:GetValue("SELECT")
				cCodVN0 := oModelPac:GetValue("VN0_CODIGO")
				If !Empty(cCodVN0)
					dDatVN2 := oModelPac:GetValue("DATNEW")
					nCusVN2 := oModelPac:GetValue("CUSNEW")
					nFreVN2 := oModelPac:GetValue("FRENEW")
					// Necessário desativar registros com data posterior ou igual a data informada
					cQuery := "SELECT R_E_C_N_O_ AS RECVN2 "
					cQuery += "  FROM " + cNamVN2
					cQuery += " WHERE VN2_FILIAL = '"+cFilVN2+"' "
					cQuery += "   AND VN2_CODVN0 = '"+cCodVN0+"' "
					cQuery += "   AND VN2_STATUS = '1' " // Ativado
					cQuery += "   AND VN2_DATINI >= '"+dtos(dDatVN2)+"' "
					cQuery += "   AND D_E_L_E_T_ = ' ' "
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F. , .T. )
					While !(cQAlias)->(Eof())
						VA2450011_Desativar( (cQAlias)->( RECVN2 ) , .f. )
						(cQAlias)->(dbSkip())
					EndDo
					(cQAlias)->(dbCloseArea())
					DbSelectArea("VN2")
					// Criar VN2 com o Novo Registro
					VA2450021_Incluir( cCodVN0 , dDatVN2 , nCusVN2 , nFreVN2 )
				EndIf
			EndIf
		Next
		// Enviar E-mail de mudança na Lista de Preços dos Pacotes no final do processo
		VA2400171_EnviarEmail(.t.,.f.)
	EndIf
EndIf
Return lOk

/*/
{Protheus.doc} VA2440101_Campo_Tik
Cria Linha do Tik na Tela

@author Andre Luis Almeida
@since 27/07/2021
/*/
Static Function VA2440101_Campo_Tik()
Local oRetorno := OFDMSStruct():New()

oRetorno:AddButton(STR0042,'BTNPESQUISA',{ |oMdl| VA2440031_ProcessaLevantamentoPacotes(oMdl) }) // FILTRAR PACOTES
oRetorno:AddSelect(STR0043,'PARSELECT', FWBuildFeature(STRUCT_FEATURE_VALID,"VA2440051_MarcarDesmarcar()") , .t.) // Marcar/Desmarcar Todos

Return oRetorno

/*/
{Protheus.doc} VA2440111_Carrega_Variaveis_para_F3
Carrega M->VV1_CODMAR/M->VV2_CODMAR para ser utilizado no F3 da Consulta de Modelos / Segmentos

@author Andre Luis Almeida
@since 28/07/2021
/*/
Function VA2440111_Carrega_Variaveis_para_F3(cCodMar)

M->VV1_CODMAR := M->VV2_CODMAR := cCodMar

Return .t.