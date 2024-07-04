#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#Include "VEICA660.CH"

/*/{Protheus.doc} VEICA660()
Cadastro de Seguros

@author Andre Luis Almeida
@since 08/04/2019
@version 1.0
@return aRotina 
/*/
Function VEICA660()
Local oWorkarea
Local oDlgVCA660
Local cCadastro := STR0001 // Cadastro de Seguros
Local aSize     := FWGetDialogSize( oMainWnd )
Local oSqlHelp := DMS_SqlHelper():New()
Local cQuery   := ""
Local cQAlias  := "SQLVQ8VQX"
Local nCntFor  := 0
Local aCombo   := {}
Local oBrwSeg
Local oBrwSin
Private oModelSeg
Private MV_PAR01 := ""      // Compatibilizacao da consulta VX3 (modelo do veiculo)
Private M->VV1_CODMAR := "" // Compatibilizacao da consulta VX0 (segmento do modelo do veiculo)
Private aCpoAltVQ8 := {}
// Campos utilizados para Historico de Alteracoes //
aAdd(aCpoAltVQ8,{"VQ8_STATUS",""      ,"@!","C"}) // C-Combo
aAdd(aCpoAltVQ8,{"VQ8_DATALT",ctod(""),"@D","G"}) // G-Get (campos do tipo Caracter/Numerico/Data)
//
// Compatibilizacao das tabelas ANTIGA (somente VQ8 - Seguro) e NOVA (VQ8+VQX - Seguro+Veiculos/Maquinas/Equipamentos) //
If oSqlHelp:ExistTable(RetSqlName("VQX"))
	cQuery := "SELECT VQ8.VQ8_CODIGO , "
	cQuery += "       VQ8.VQ8_ESTADO , "
	cQuery += "       VQ8.VQ8_CODMAR , "
	cQuery += "       VQ8.VQ8_MODVEI , "
	cQuery += "       VQ8.VQ8_STATUS , "
	cQuery += "       VQ8.VQ8_VALTOT   "
	cQuery += "  FROM "+RetSqlName("VQ8")+" VQ8 "
	cQuery += " WHERE VQ8.VQ8_FILIAL='"+xFilial("VQ8")+"'"
	cQuery += "   AND VQ8.D_E_L_E_T_=' '"
	cQuery += "   AND NOT EXISTS "
	cQuery += "       ( SELECT VQX.VQX_CODSEG FROM "+RetSqlName("VQX")+" VQX WHERE VQX.VQX_FILIAL='"+xFilial("VQX")+"' AND VQX.VQX_CODSEG=VQ8.VQ8_CODIGO AND VQX.D_E_L_E_T_=' ' ) "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F. , .T. )
	While !(cQAlias)->(Eof())
		DbSelectArea("VQX")
		RecLock("VQX",.t.)
			VQX->VQX_FILIAL := xFilial("VQX")
			VQX->VQX_CODIGO := GetSXENum("VQX","VQX_CODIGO")
			ConfirmSX8()
			VQX->VQX_CODSEG := (cQAlias)->( VQ8_CODIGO )
			VQX->VQX_ESTADO := (cQAlias)->( VQ8_ESTADO )
			VQX->VQX_CODMAR := (cQAlias)->( VQ8_CODMAR )
			VQX->VQX_MODVEI := (cQAlias)->( VQ8_MODVEI )
			VQX->VQX_STATUS := (cQAlias)->( VQ8_STATUS )
			VQX->VQX_VALOR  := (cQAlias)->( VQ8_VALTOT )
		MsUnLock()
		(cQAlias)->(dbSkip())
	EndDo
	(cQAlias)->(dbCloseArea())
EndIf

oDlgVCA660 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )
oWorkArea := FWUIWorkArea():New( oDlgVCA660 )

oWorkArea:CreateHorizontalBox( "LINE01", 60 , .f. )
oWorkArea:SetBoxCols( "LINE01", { "OBJSeguros" } )
oWorkArea:CreateHorizontalBox( "LINE02", 40 , .f. )
oWorkArea:SetBoxCols( "LINE02", { "OBJSinistros" } )

oWorkArea:Activate()

DbSelectArea("VQ8")

aCombo := X3CBOXAVET("VQ8_STATUS","0")
oBrwSeg:= FWMBrowse():New()
oBrwSeg:SetOwner(oWorkarea:GetPanel("OBJSeguros"))
oBrwSeg:SetAlias("VQ8")
oBrwSeg:DisableLocate()
oBrwSeg:DisableDetails()
oBrwSeg:SetAmbiente(.F.)
oBrwSeg:SetWalkthru(.F.)
oBrwSeg:SetDescription(STR0001) // Cadastro de Seguros
oBrwSeg:AddLegend( "dtos(VQ8_DATVIG)>='"+dtos(dDataBase)+"'" , "BR_VERDE" , STR0062 ) // Seguros dentro da Data de Vigencia
oBrwSeg:AddLegend( "dtos(VQ8_DATVIG)<'"+dtos(dDataBase)+"'" , "BR_BRANCO" , STR0063 ) // Seguros fora da Data de Vigencia
For nCntFor := 1 to len(aCombo)
	oBrwSeg:AddFilter(STR0022+": "+Substr(aCombo[nCntFor],3),"VQ8_STATUS='"+left(aCombo[nCntFor],1)+"'",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar - Indicador:
Next
oBrwSeg:Activate()

aCombo := X3CBOXAVET("VQW_STATUS","0")
oBrwSin:= FWMBrowse():New() 
oBrwSin:SetOwner(oWorkarea:GetPanel("OBJSinistros"))
oBrwSin:SetAlias("VQW")
oBrwSin:DisableLocate()
oBrwSin:DisableDetails()
oBrwSin:SetAmbiente(.F.)
oBrwSin:SetWalkthru(.F.)
oBrwSin:SetMenuDef("VEIA150")
oBrwSin:SetDescription(STR0066) // Sinistros
oBrwSin:SetUseFilter()
For nCntFor := 1 to len(aCombo)
	oBrwSin:AddFilter(STR0023+": "+Substr(aCombo[nCntFor],3),"VQW_STATUS='"+left(aCombo[nCntFor],1)+"'",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar - Status:
Next
oBrwSin:lOptionReport := .f.
oBrwSin:Activate()

oRelac:= FWBrwRelation():New() 
oRelac:AddRelation( oBrwSeg , oBrwSin , { { "VQW_FILIAL" , "VQ8_FILIAL" }, { "VQW_CODSEG" , "VQ8_CODIGO" } })
oRelac:Activate()

oDlgVCA660:Activate( , , , , , , ) //ativa a janela

Return .T.

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 08/04/2019
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0031 ACTION 'VIEWDEF.VEICA660' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0032 ACTION 'VIEWDEF.VEICA660' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0033 ACTION 'VIEWDEF.VEICA660' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0034 ACTION 'VIEWDEF.VEICA660' OPERATION 5 ACCESS 0 // Excluir
ADD OPTION aRotina TITLE STR0035 ACTION 'VCA660051_RenovarSeguro()' OPERATION 4 ACCESS 0 // Renovar
ADD OPTION aRotina TITLE STR0036 ACTION 'VCA660061_BancoDeConhecimento("1")' OPERATION 4 ACCESS 0 // Banco de Conhecimento do Seguro
ADD OPTION aRotina TITLE STR0037 ACTION 'VCA660041_ImpressaoSeguro()' OPERATION 8 ACCESS 0 // Imprimir

If (ExistBlock("VCA660ABT")) // Ponto de Entrada para adicionar opções no Menu
	aRotina := ExecBlock("VCA660ABT", .f., .f., {aRotina})
EndIf
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 08/04/2019
@version 1.0
@Return oModelSeg
/*/
Static Function ModelDef()
Local oStrVQ8 := FWFormStruct(1,"VQ8")
Local oStrVQX := FWFormStruct(1,"VQX")
Local oStrVQN := FWFormStruct(1,"VQN")

oModelSeg := MPFormModel():New("VEICA660", /* bPre */, {|oModelSeg| VCA660021_TudoOk(oModelSeg) } /* bPost */ , /* bCommit */ , /* bCancel */ )

oModelSeg:AddFields("VQ8MASTER",/*cOwner*/ , oStrVQ8)
oModelSeg:GetModel("VQ8MASTER"):SetDescription(STR0001) // Cadastro de Seguros

FWMemoVirtual( oStrVQ8,{ { 'VQ8_OBSMEM' , 'VQ8_OBSERV' } } )

oModelSeg:AddGrid( "VQNFILHO" , "VQ8MASTER", oStrVQN , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModelSeg:SetRelation("VQNFILHO", {{'VQN_FILIAL','VQ8_FILIAL'}, {'VQN_CODSEG','VQ8_CODIGO'}}, VQN->(IndexKey(2)) )
oModelSeg:GetModel("VQNFILHO"):SetDescription(STR0038) // Pagamentos Corretora
oModelSeg:GetModel("VQNFILHO"):SetOptional(.T.) // Permite deixar o em branco a grid filho

oModelSeg:AddGrid( "VQXFILHO" , "VQ8MASTER", oStrVQX , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModelSeg:SetRelation("VQXFILHO", {{'VQX_FILIAL','VQ8_FILIAL'}, {'VQX_CODSEG','VQ8_CODIGO'}}, VQX->(IndexKey(2)) )
oModelSeg:GetModel("VQXFILHO"):SetDescription(STR0039) // Veiculos/Maquinas/Equipamentos
oModelSeg:GetModel("VQXFILHO"):SetOptional(.T.) // Permite deixar o em branco a grid filho

oModelSeg:SetDescription(STR0001) // Cadastro de Seguros
//oModelSeg:InstallEvent("VEICA660LOG", /*cOwner*/, MVCLOGEV():New("VEICA660") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModelSeg:InstallEvent("VEICA660EVDEF", /*cOwner*/, VEICA660EVDEF():New() )

oModelSeg:AddRules( 'VQ8MASTER', 'VQ8_LOJCLI', 'VQ8MASTER', 'VQ8_CODCLI', 3)

Return oModelSeg

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 08/04/2019
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel  := ModelDef()
Local oStrVQ8 := FWFormStruct(2,"VQ8", { |x| !ALLTRIM(x) $ 'VQ8_OBSMEM,' } )
Local oStrVQX := FWFormStruct(2,"VQX", { |x| !ALLTRIM(x) $ 'VQX_CODIGO,VQX_CODSEG' } )
Local oStrVQN := FWFormStruct(2,"VQN", { |x| !ALLTRIM(x) $ 'VQN_CODIGO,VQN_CODSEG' } )

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_VQ8' , oStrVQ8 , 'VQ8MASTER' )
oView:AddGrid(  'VIEW_VQX' , oStrVQX , 'VQXFILHO'  )
oView:AddGrid(  'VIEW_VQN' , oStrVQN , 'VQNFILHO'  )

// definição de como será a tela
oView:CreateHorizontalBox('TOPO'   , 60)
oView:CreateHorizontalBox('RODAPE' , 40)

oView:CreateVerticalBox('SEGURO'   , 70 , 'TOPO')
oView:CreateVerticalBox('PARCELAS' , 30 , 'TOPO')

oView:SetOwnerView('VIEW_VQ8', 'SEGURO'   )
oView:SetOwnerView('VIEW_VQN', 'PARCELAS' )
oView:SetOwnerView('VIEW_VQX', 'RODAPE'   ) // Veiculos/Maquinas/Equipamentos

oView:SetCloseOnOk({||.T.})

// Criar novo botao na barra de botoes
oView:AddUserButton(STR0040,'BUDGET',{ |oView| VCA660091_ParcelasClientesCorretora() })
oView:AddUserButton(STR0036,'CLIPS' ,{ |oView| VCA660061_BancoDeConhecimento("2") })

Return oView

/*/{Protheus.doc} VCA660011_ValidacaoCampos
Validação Campos VQ8/VQX

@author Andre Luis Almeida
@since 09/04/2019
@version 1.0
@Return oView
/*/
Function VCA660011_ValidacaoCampos(cAlias,oSubModel,cId,xValue)
Local lRet   := .t.
Local nRecNo := 0

If xValue == Nil
	Return .t. // Retornar .t. para nao dar erro
EndIf

If cAlias == "VQ8" // Campos do Cabeçalho - Seguro

	Do Case

		Case cId $ "VQ8_CODCLI/VQ8_LOJCLI"
			If cId == "VQ8_CODCLI"
				M->VQ8_CODCLI := xValue
			Else
				M->VQ8_LOJCLI := xValue
			EndIf
			If !Empty(M->VQ8_CODCLI+M->VQ8_LOJCLI)
				nRecNo := FM_SQL("SELECT R_E_C_N_O_ AS RECSA1 FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+M->VQ8_CODCLI+"'"+IIf(!Empty(M->VQ8_LOJCLI)," AND A1_LOJA='"+M->VQ8_LOJCLI+"' ","")+" AND D_E_L_E_T_=' '")
				If nRecNo > 0 // Existe Cliente
					DbSelectArea("SA1")
					DbGoTo(nRecNo)
					oSubModel:LoadValue("VQ8_LOJCLI",SA1->A1_LOJA)
					oSubModel:LoadValue("VQ8_NOMCLI",left(SA1->A1_NOME,TamSX3("VQ8_NOMCLI")[1]))
				EndIf
			EndIf

		Case cId $ "VQ8_VALTOT/VQ8_QTDPAR"
			If cId == "VQ8_VALTOT"
				M->VQ8_VALTOT := xValue
			Else
				M->VQ8_QTDPAR := xValue
			EndIf
			oSubModel:LoadValue("VQ8_VALPAR",( M->VQ8_VALTOT / M->VQ8_QTDPAR ))
			oSubModel:LoadValue("VQ8_COMTOT",( ( M->VQ8_PERCOM / 100 ) * M->VQ8_VALTOT ))
			oSubModel:LoadValue("VQ8_VALPCM",( M->VQ8_COMTOT / M->VQ8_QTDPCM ))
			oSubModel:LoadValue("VQ8_SALDO ",M->VQ8_COMTOT)

		Case cId $ "VQ8_COMTOT/VQ8_PERCOM/VQ8_QTDPCM"
			If cId == "VQ8_COMTOT"
				M->VQ8_VALTOT := xValue
			ElseIf cId == "VQ8_PERCOM"
				M->VQ8_PERCOM := xValue
			Else
				M->VQ8_QTDPCM := xValue
			EndIf
			If cId == "VQ8_COMTOT"
				oSubModel:LoadValue("VQ8_PERCOM",( ( M->VQ8_COMTOT / M->VQ8_VALTOT ) * 100 ))
			ElseIf cId == "VQ8_PERCOM"
				oSubModel:LoadValue("VQ8_COMTOT",( ( M->VQ8_PERCOM / 100 ) * M->VQ8_VALTOT ))
			EndIf
			oSubModel:LoadValue("VQ8_VALPCM",( M->VQ8_COMTOT / M->VQ8_QTDPCM ))
			oSubModel:LoadValue("VQ8_SALDO ",M->VQ8_COMTOT)

	EndCase

ElseIf cAlias == "VQX" // Campos do Filho - Veiculos/Maquinas/Equipamentos

	Do Case

		Case cId == "VQX_CODMAR"
			MV_PAR01      := ""
			M->VV1_CODMAR := ""
			M->VQX_CODMAR := xValue
			If !Empty(M->VQX_CODMAR)
				nRecNo := FM_SQL("SELECT R_E_C_N_O_ AS RECVE1 FROM "+RetSQLName("VE1")+" WHERE VE1_FILIAL='"+xFilial("VE1")+"' AND VE1_CODMAR='"+M->VQX_CODMAR+"' AND D_E_L_E_T_=' '")
				If nRecNo <= 0 // NAO Existe a Marca
					lRet := .f.
					Help(NIL, NIL, "VCA660011_ValidacaoCampos", NIL, STR0041, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0042}) // Código da Marca inválido! / Informe um Código de Marca válido.
				Else
					MV_PAR01      := M->VQX_CODMAR // Compatibilizacao da consulta VX3 (modelo do veiculo)
					M->VV1_CODMAR := M->VQX_CODMAR // Compatibilizacao da consulta VX0 (segmento do modelo do veiculo)
				EndIf
			EndIf
			oSubModel:LoadValue("VQX_MODVEI","")
			oSubModel:LoadValue("VQX_SEGMOD","")

		Case cId == "VQX_MODVEI"
			M->VQX_CODMAR := oSubModel:GetValue("VQX_CODMAR")
			MV_PAR01      := M->VQX_CODMAR // Compatibilizacao da consulta VX3 (modelo do veiculo)
			M->VV1_CODMAR := M->VQX_CODMAR // Compatibilizacao da consulta VX0 (segmento do modelo do veiculo)
			M->VQX_MODVEI := xValue
			M->VQX_SEGMOD := oSubModel:GetValue("VQX_SEGMOD")
			If !Empty(M->VQX_MODVEI)
				nRecNo := FM_SQL("SELECT R_E_C_N_O_ AS RECVV2 FROM "+RetSQLName("VV2")+" WHERE VV2_FILIAL='"+xFilial("VV2")+"' AND VV2_CODMAR='"+M->VQX_CODMAR+"' AND VV2_MODVEI='"+M->VQX_MODVEI+"' "+IIf(!Empty(M->VQX_SEGMOD),"AND VV2_SEGMOD='"+M->VQX_SEGMOD+"'","")+" AND D_E_L_E_T_=' '")
				If nRecNo <= 0 // NAO Existe a Marca/Modelo
					lRet  := .f.
					Help(NIL, NIL, "VCA660011_ValidacaoCampos", NIL, STR0043, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0044}) // Código do Modelo inválido! / Informe um Código de Modelo válido para a Marca.
					oSubModel:LoadValue("VQX_SEGMOD","")
				Else
					VV2->(DbGoTo(nRecNo))
					oSubModel:LoadValue("VQX_SEGMOD",VV2->VV2_SEGMOD)
				EndIf
			EndIf

		Case cId == "VQX_SEGMOD"
			M->VQX_CODMAR := oSubModel:GetValue("VQX_CODMAR")
			M->VQX_MODVEI := oSubModel:GetValue("VQX_MODVEI")
			M->VQX_SEGMOD := xValue
			If !Empty(M->VQX_SEGMOD)
				nRecNo := FM_SQL("SELECT R_E_C_N_O_ AS RECVVX FROM "+RetSQLName("VVX")+" WHERE VVX_FILIAL='"+xFilial("VVX")+"' AND VVX_CODMAR='"+M->VQX_CODMAR+"' AND VVX_SEGMOD='"+M->VQX_SEGMOD+"' AND D_E_L_E_T_=' '")
				If nRecNo <= 0 // NAO Existe o Segmento para Marca
					lRet  := .f.
					Help(NIL, NIL, "VCA660011_ValidacaoCampos", NIL, STR0069, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0070}) // Código do Segmento do Modelo inválido! / Informe um Código de Segmento do Modelo válido para a Marca.
				Else
					nRecNo := FM_SQL("SELECT R_E_C_N_O_ AS RECVV2 FROM "+RetSQLName("VV2")+" WHERE VV2_FILIAL='"+xFilial("VV2")+"' AND VV2_CODMAR='"+M->VQX_CODMAR+"' AND VV2_MODVEI='"+M->VQX_MODVEI+"' AND VV2_SEGMOD='"+M->VQX_SEGMOD+"' AND D_E_L_E_T_=' '")
					If nRecNo <= 0 // NAO Existe a Marca/Modelo
						lRet  := .f.
						Help(NIL, NIL, "VCA660011_ValidacaoCampos", NIL, STR0043, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0044}) // Código do Modelo inválido! / Informe um Código de Modelo válido para a Marca.
					EndIf
				EndIf
			EndIf

	EndCase

EndIf

Return lRet

/*/{Protheus.doc} VCA660021_TudoOk
	Tudo Ok da VQ8

	@author Andre Luis Almeida
	@since 09/04/2019
/*/
Function VCA660021_TudoOk(oModel)
Local lRet   := .t.
Local cCod   := ""
Local cLoj   := ""
Local cQuery := ""
If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	lRet := .f.
	cCod := oModel:GetValue("VQ8MASTER","VQ8_CODCLI")
	cLoj := oModel:GetValue("VQ8MASTER","VQ8_LOJCLI")
	If !Empty( cCod + cLoj )
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek( xFilial("SA1") + cCod + cLoj ))
			lRet := .t.
		Else
			Help(NIL, NIL, "VCA660021_TudoOk", NIL, STR0045+" "+cCod+"-"+cLoj , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0046}) // Código/Loja do Cliente inválido! / Informe um Código/Loja de Cliente válido.
		EndIf
	Else
		Help(NIL, NIL, "VCA660021_TudoOk", NIL, STR0045 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0046}) // Código/Loja do Cliente inválido! / Informe um Código/Loja de Cliente válido.
	EndIf
ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
	If oModel:GetValue("VQ8MASTER","VQ8_GEROUP") <> "0"
		Help(NIL, NIL, "VCA660021_TudoOk", NIL, STR0047 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0029}) // Excluir Seguro / Impossivel EXCLUIR o Seguro, ja existe NF gerada para uma ou mais parcelas.
		lRet := .f.
	Else
		// Verificar a Quantidade de Sinistros
		cQuery := "SELECT COUNT(VQW_CODIGO) "
		cQuery += "  FROM "+RetSQLName("VQW")
		cQuery += " WHERE VQW_FILIAL='"+xFilial("VQW")+"'"
		cQuery += "   AND VQW_CODSEG='"+oModel:GetValue("VQ8MASTER","VQ8_CODIGO")+"'"
		cQuery += "   AND D_E_L_E_T_=' '"
		If FM_SQL(cQuery) > 0
			Help(NIL, NIL, "VCA660021_TudoOk", NIL, STR0048 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0049}) // Existe(m) Sinistro(s) relacionado(s). / Excluir o(s) Sinistro(s) relacionado(s) a este Seguro.
			lRet := .f.
		EndIf
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} VCA660031_Numeracao
	Batiza a Filial/Numeracao do VQX/VQN

	@author Andre Luis Almeida
	@since 09/04/2019
/*/
Function VCA660031_Numeracao(cAlias)
RecLock(cAlias,.f.)
	&(cAlias+"->"+cAlias+"_FILIAL") := xFilial(cAlias)
	&(cAlias+"->"+cAlias+"_CODIGO") := GetSXENum(cAlias,cAlias+"_CODIGO") // Numeracao (auto-incremento)
	ConfirmSX8()
MsUnLock()
Return

/*/{Protheus.doc} VCA660041_ImpressaoSeguro
	Impressao Seguros VQ8

	@author Andre Luis Almeida
	@since 09/04/2019
/*/
Function VCA660041_ImpressaoSeguro()
Local aParamBox := {}
Local aRet      := {}
Local cQuery    := ""
Local cSQLAlias := "SQLVQ8"
Local cSQLAlAux := "SQLVQ9"
Local cImp      := ""
Local nTot      := 0
Local nCom      := 0
Local nSal      := 0
Local aIndica   := X3CBOXAVET("VQ8_STATUS","0")
Local aStatus   := {"0="+STR0008,"1="+STR0009,"2="+STR0010,"3="+STR0011,"4="+STR0012}
Local aSinAna   := {"1="+STR0013,"2="+STR0014,"3="+STR0015}
Private cDesc1  := ""
Private cDesc2  := ""
Private cDesc3  := ""
Private tamanho := "G"
Private limite  := 220
Private cString := "VQ8"
Private titulo  := STR0001 // Cadastro de Seguros
Private cabec1  := ""
Private cabec2  := ""
Private aReturn := {"",1,"",1,2,1,"",1}  
Private nomeprog:= "VEICA660"
Private nLastKey:= 0
DbSelectArea("VQ8") 
AADD(aParamBox,{1,STR0016,(dDataBase-day(dDataBase)+1)  ,"@D","","","",50,.t.}) // Dt.Inicial Venda
AADD(aParamBox,{1,STR0017,dDataBase                     ,"@D","","","",50,.t.}) // Dt.Final Venda
AADD(aParamBox,{1,STR0018,space(TamSx3("VCG_CORRET")[1]),"@!","Empty(MV_PAR03).or.FG_Seek('VCG','MV_PAR03',1,.f.)"                  ,"VCG","",50,.f.}) // Seguradora
AADD(aParamBox,{1,STR0019,space(TamSx3("A3_COD")[1])    ,"@!","Empty(MV_PAR04).or.FG_Seek('SA3','MV_PAR04',1,.f.)"                  ,"SA3","",60,.f.}) // Vendedor
AADD(aParamBox,{1,STR0020,space(TamSx3("A1_COD")[1])    ,"@!","Empty(MV_PAR05).or.FG_Seek('SA1','MV_PAR05+Alltrim(MV_PAR06)',1,.f.)","SA1","",60,.f.}) // Cliente
AADD(aParamBox,{1,STR0021,space(TamSx3("A1_LOJA")[1])   ,"@!","Empty(MV_PAR06).or.FG_Seek('SA1','MV_PAR05+MV_PAR06',1,.f.)"         ,""   ,"",20,.f.}) // Loja
AADD(aParamBox,{2,STR0022,"1",aIndica, 80,"",.t.}) // Indicador
AADD(aParamBox,{2,STR0023,"0",aStatus,100,"",.t.}) // Status
AADD(aParamBox,{2,STR0024,"2",aSinAna, 60,"",.t.}) // Tipo
If ParamBox(aParamBox,STR0025,@aRet,,,,,,,,.f.) // Parametros
	nomeprog := SetPrint(cString,nomeprog,nil,titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
	If nLastKey == 27
		Return
	EndIf     
	SetDefault(aReturn,cString)
	nLin  := 60
	m_pag := 1
	Set Printer to &nomeprog
	Set Printer On
	Set Device  to Printer
	//
	cabec1 := STR0026 // Cliente                          Seguradora/Apolice     Data Venda   Indicador       Vendedor                  Total Venda  %Comis   Vlr.Comissão          Saldo
	//
	cQuery := "SELECT VQ8.VQ8_CODIGO , VQ8.VQ8_CODCLI , VQ8.VQ8_LOJCLI , VQ8.VQ8_APOLIC , VQ8.VQ8_SEGURA , VQ8.VQ8_DATVIG , VQ8.VQ8_STATUS , VQ8.VQ8_CODVEN , VQ8.VQ8_VALTOT , VQ8.VQ8_PERCOM , VQ8.VQ8_COMTOT , VQ8.VQ8_SALDO , SA1.A1_NOME , SA3.A3_NOME "
	cQuery += "FROM "+RetSQLName("VQ8")+" VQ8 "
	cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VQ8.VQ8_CODCLI AND SA1.A1_LOJA=VQ8.VQ8_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VQ8.VQ8_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VQ8.VQ8_FILIAL='"+xFilial("VQ8")+"' AND "
	cQuery += "VQ8.VQ8_DATVIG>='"+dtos(aRet[1])+"' AND VQ8.VQ8_DATVIG<='"+dtos(aRet[2])+"' AND "
	cQuery += "VQ8.VQ8_STATUS='"+aRet[7]+"' AND "
	If !Empty(aRet[3])
		cQuery += "VQ8.VQ8_SEGURA='"+aRet[3]+"' AND "
	EndIf
	If !Empty(aRet[4])
		cQuery += "VQ8.VQ8_CODVEN='"+aRet[4]+"' AND "
	EndIf
	If !Empty(aRet[5])
		cQuery += "VQ8.VQ8_CODCLI='"+aRet[5]+"' AND VQ8.VQ8_LOJCLI='"+aRet[6]+"' AND "
	EndIf
	If aRet[8] <> "0"
		If aRet[8] == "1" // 1=Recebido (Integral + Parcial)
			cQuery += "( VQ8.VQ8_SALDO=0 OR VQ8.VQ8_COMTOT<>VQ8.VQ8_SALDO ) AND "
		ElseIf aRet[8] == "2" // 2=Recebido Integral
			cQuery += "VQ8.VQ8_SALDO=0 AND "
		ElseIf aRet[8] == "1" // 3=Recebido Parcial
			cQuery += "VQ8.VQ8_SALDO<>0 AND VQ8.VQ8_COMTOT<>VQ8.VQ8_SALDO AND "
		ElseIf aRet[8] == "4" // 4=A Receber
			cQuery += "VQ8.VQ8_SALDO<>0 AND "
		EndIf
	EndIf
	cQuery += "VQ8.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
	While !(cSQLAlias)->(Eof())
		If nLin >= 55
			nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
		EndIf
		//
		nTot += (cSQLAlias)->( VQ8_VALTOT )
		nCom += (cSQLAlias)->( VQ8_COMTOT )
		nSal += (cSQLAlias)->( VQ8_SALDO )
		//
		If aRet[9] <> "1" // 2=Sintetico ou 3=Analitico
			cImp := left((cSQLAlias)->( VQ8_CODCLI )+"-"+(cSQLAlias)->( VQ8_LOJCLI )+" "+(cSQLAlias)->( A1_NOME )+space(32),32)+" "
			cImp += left((cSQLAlias)->( VQ8_SEGURA )+" "+(cSQLAlias)->( VQ8_APOLIC )+space(22),22)+" "
			cImp += left(Transform(stod((cSQLAlias)->( VQ8_DATVIG )),"@D")+space(12),12)+" "
			cImp += left(X3CBOXDESC("VQ8_STATUS",(cSQLAlias)->( VQ8_STATUS ))+space(15),15)+" "
			cImp += left((cSQLAlias)->( VQ8_CODVEN )+"-"+(cSQLAlias)->( A3_NOME )+space(22),22)+" "
			cImp += Transform((cSQLAlias)->( VQ8_VALTOT ),"@E 999,999,999.99")+" "
			cImp += Transform((cSQLAlias)->( VQ8_PERCOM ),"@E 99.9999")+" "
			cImp += Transform((cSQLAlias)->( VQ8_COMTOT ),"@E 999,999,999.99")+" "
			cImp += Transform((cSQLAlias)->( VQ8_SALDO ),"@E 999,999,999.99")
			@ nLin++, 00 PSAY left(cImp+space(220),220)
			If aRet[9] == "3" // 3=Analitico
				cImp := right(space(95)+STR0027+" ",95) // Parcelas: 
				cQuery := "SELECT VQ9.VQ9_NUMPAR , VQ9.VQ9_DATVEN , VQ9.VQ9_VALCOM , VQ9.VQ9_NUMNFI , VQ9.VQ9_SERNFI "
				cQuery += "FROM "+RetSQLName("VQ9")+" VQ9 WHERE VQ9.VQ9_FILIAL='"+xFilial("VQ9")+"' AND "
				cQuery += "VQ9.VQ9_TIPO='3' AND VQ9.VQ9_CODIGO='"+(cSQLAlias)->( VQ8_CODIGO )+"' AND VQ9.D_E_L_E_T_=' ' ORDER BY VQ9.VQ9_NUMPAR"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlAux, .F., .T. )
				While !(cSQLAlAux)->(Eof())
					If nLin >= 55
						nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
					EndIf
					cImp += Transform((cSQLAlAux)->( VQ9_NUMPAR ),"@R 999/999")+" "+left(Transform(stod((cSQLAlAux)->( VQ9_DATVEN )),"@D")+space(12),12)+space(16)+Transform((cSQLAlAux)->( VQ9_VALCOM ),"@E 999,999,999.99")+" "+IIf(!Empty((cSQLAlAux)->( VQ9_NUMNFI )),STR0030+" "+(cSQLAlAux)->( VQ9_NUMNFI )+"-"+(cSQLAlAux)->( VQ9_SERNFI ),"")
					@ nLin++, 00 PSAY left(cImp+space(220),220)
					cImp := right(space(95),95)
					(cSQLAlAux)->(dbSkip())
				EndDo
				(cSQLAlAux)->(dbCloseArea())
				nLin++
			EndIf
		EndIf
		//
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	If nTot > 0
		nLin++
		@ nLin++, 00 PSAY left(STR0028+space(108),108)+Transform(nTot,"@E 999,999,999.99")+"         "+Transform(nCom,"@E 999,999,999.99")+" "+Transform(nSal,"@E 999,999,999.99")
	EndIf
	DbSelectArea("VQ8") 
	Set Printer to
	Set Device to Screen
	If aReturn[5] == 1
		OurSpool( nomeprog )
	EndIf
	MS_Flush()
EndIf
Return

/*/{Protheus.doc} VCA660051_RenovarSeguro
	Duplicar Seguros VQ8/VQX

	@author Andre Luis Almeida
	@since 10/04/2019
/*/
Function VCA660051_RenovarSeguro()
Local oView      := FWViewExec():New()
Local oAuxView
Local aVQ8       := {}
Local aVQX       := {}
Local cQuery     := ""
Local cQAlias    := "SQLVQX"
Local cVQ8NAODup := 'VQ8_FILIAL,VQ8_CODIGO,VQ8_STATUS,VQ8_NUMPRO,VQ8_APOLIC,VQ8_DATVIG,VQ8_TIPSEG,VQ8_CLABON,VQ8_CODVEN,VQ8_VALTOT,VQ8_QTDPAR,VQ8_VALPAR,VQ8_PERCOM,VQ8_COMTOT,VQ8_QTDPCM,VQ8_VALPCM,VQ8_SALDO,VQ8_ESTADO,VQ8_CODMAR,VQ8_MODVEI,VQ8_OBSERV,VQ8_OBSMEM,VQ8_GEROUP,VQ8_DATALT,VQ8_OBSERA,VQ8_OBSMEA,VQ8_SEGANT,VQ8_SEGPOS,'
Local cVQXNAODup := 'VQX_FILIAL,VQX_CODIGO,VQX_CODSEG,VQX_ESTADO,VQX_STATUS,VQX_VALOR,'
Local oVQ8       := FWFormStruct(2,"VQ8", { |x| !ALLTRIM(x) $ cVQ8NAODup })
Local oVQX       := FWFormStruct(2,"VQX", { |x| !ALLTRIM(x) $ cVQXNAODup } )
Local aCposVQ8   := oVQ8:aFields
Local aCposVQX   := oVQX:aFields
Local nCntFor    := 0
Local nCntVQX    := 0
Local cFilVQ8    := xFilial("VQ8")
Local cFilVQX    := xFilial("VQX")
//
If MsgYesNo(STR0050,STR0002) // Deseja RENOVAR o Seguro? / Atenção
	//
	Begin Transaction
	//
	DbSelectArea("VQ8")
	aAdd(aVQ8,{ cFilVQ8 , VQ8->VQ8_CODIGO , GetSXENum("VQ8","VQ8_CODIGO") , {} })
	ConfirmSX8()
	RecLock("VQ8",.f.)
		VQ8->VQ8_STATUS := "4" // Renovado
		VQ8->VQ8_SEGPOS := aVQ8[1,3] // Codigo Seguro Posterior
	MsUnLock()
	For nCntFor := 1 to len(aCposVQ8)
		If aCposVQ8[nCntFor,10]
			aAdd(aVQ8[1,4],{ aCposVQ8[nCntFor,1] , &("VQ8->"+aCposVQ8[nCntFor,1]) })
		EndIf
	Next
	//
	cQuery := "SELECT R_E_C_N_O_ AS RECVQX "
	cQuery += "  FROM "+RetSqlName("VQX")
	cQuery += " WHERE VQX_FILIAL='"+cFilVQX+"'"
	cQuery += "   AND VQX_CODSEG='"+aVQ8[1,2]+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F. , .T. )
	While !(cQAlias)->(Eof())
		DbSelectArea("VQX")
		DbGoTo((cQAlias)->( RECVQX ))
		aAdd(aVQX,{ cFilVQX , VQX->VQX_CODIGO , GetSXENum("VQX","VQX_CODIGO") , {} })
		ConfirmSX8()
		For nCntFor := 1 to len(aCposVQX)
			If aCposVQX[nCntFor,10]
				aAdd(aVQX[len(aVQX),4],{ aCposVQX[nCntFor,1] , &("VQX->"+aCposVQX[nCntFor,1]) })
			EndIf
		Next
		(cQAlias)->(dbSkip())
	EndDo
	(cQAlias)->(dbCloseArea())
	//
	DbSelectArea("VQ8")
	RecLock("VQ8",.t.)
		VQ8->VQ8_FILIAL := cFilVQ8 // xFilial("VQ8")
		VQ8->VQ8_CODIGO := aVQ8[1,3] // Codigo do Seguro NOVO (Renovacao - Codigo Posterior)
		VQ8->VQ8_SEGANT := aVQ8[1,2] // Codigo do Seguro ANTERIOR
		VQ8->VQ8_STATUS := "0" // Em Negociacao
		VQ8->VQ8_TIPSEG := "2" // Renovacao
		VQ8->VQ8_GEROUP := "0" // Nao
		For nCntFor := 1 to len(aVQ8[1,4])
			&("VQ8->"+aVQ8[1,4,nCntFor,1]) := aVQ8[1,4,nCntFor,2]
		Next
	MsUnLock()
	//
	For nCntVQX := 1 to len(aVQX)
		DbSelectArea("VQX")
		RecLock("VQX",.t.)
			VQX->VQX_FILIAL := cFilVQX // xFilial("VQX")
			VQX->VQX_CODIGO := aVQX[nCntVQX,3] // Novos Codigos dos Veiculos/Maquinas/Equipamentos
			VQX->VQX_CODSEG := aVQ8[1,3] // Codigo do Seguro NOVO (Renovacao - Codigo Posterior)
			VQX->VQX_STATUS := "0" // Em Negociacao
			VQX->VQX_ESTADO := "1" // Usado
			For nCntFor := 1 to len(aVQX[nCntVQX,4])
				&("VQX->"+aVQX[nCntVQX,4,nCntFor,1]) := aVQX[nCntVQX,4,nCntFor,2]
			Next
		MsUnLock()
	Next
	//
	End Transaction
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PE executado apos criar arquivos de RENOVACAO de Seguro          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("VCA660RV")
		ExecBlock("VCA660RV",.f.,.f.,{aVQ8,aVQX})
	EndIf
	//
	DbSelectArea("VQ8")
	If DbSeek(cFilVQ8+aVQ8[1,3])
		oView:setTitle(STR0035) // Renovar
		oAuxView := FWLoadView("VEICA660")
		oView:SetView(oAuxView)
		oView:setModal(.F.)
		oView:setOperation(MODEL_OPERATION_UPDATE)
		oView:openView(.F.)
	EndIf
EndIf
//
Return

/*/{Protheus.doc} VCA660061_BancoDeConhecimento
Chamada do Banco de Conhecimento para Cadastro do Seguro

@author Andre Luis Almeida
@since 10/04/2019
/*/
Function VCA660061_BancoDeConhecimento(cTp)
Local nRecNo    := 0
// Necessario devido a a funcao PADRAO TOTVS do Banco de Conhecimento
Private aRotina := {{ " " ," " , 0, 1},;	// Pesquisar
					{ " " ," " , 0, 2},;	// Visualizar
					{ " " ," " , 0, 3},;	// Incluir
					{ " " ," " , 0, 4},;	// Alterar
					{ " " ," " , 0, 5} }	// Excluir
If cTp == "1" // 1=Chamada diretamente pelo MENU
	nRecNo := VQ8->(RecNo())
ElseIf cTp == "2"
	If oModel:GetOperation() <> MODEL_OPERATION_INSERT // 1=Chamada diretamente pelo MENU   ou   Chamado dentro do Seguro mas nao pode ser na Inclusao
		nRecNo := VQ8->(RecNo())
	EndIf
EndIf
If nRecNo > 0
	MsDocument("VQ8",nRecNo,4)
Else
	Help(NIL, NIL, "VCA660061_BancoDeConhecimento", NIL, STR0051 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0052}) // Banco de Conhecimento não disponivel dentro da opção 'Incluir' da rotina de Seguros / Após concluir o Cadastro do Seguro, acesse a opção de Banco de Conhecimento via menu no Browse ou de dentro da opção 'Alterar' deste Seguro.
EndIf
Return

/*/{Protheus.doc} VCA660071_GravacaoAposPadrao
Gravacoes Apos Gravacoes padrão

@author Andre Luis Almeida
@since 11/04/2019
/*/
Function VCA660071_GravacaoAposPadrao(oModel)
Local nCntFor := 0
Local lAlt    := .f.
Local cAnt    := ""
Local cDep    := ""
Local cQuery  := ""
Local cObsAlt := ""
Local nObsTam := 0
Local lInclui := .t.
If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	//
	cQuery := "SELECT SUM(VQ9_VALCOM)"
	cQuery += "  FROM "+RetSQLName("VQ9")
	cQuery += " WHERE VQ9_FILIAL='"+xFilial("VQ9")+"'"
	cQuery += "   AND VQ9_TIPO='3'"
	cQuery += "   AND VQ9_CODIGO='"+VQ8->VQ8_CODIGO+"'"
	cQuery += "   AND VQ9_NUMNFI<>' '"
	cQuery += "   AND D_E_L_E_T_=' '"
	//
	DbSelectArea("VQ8")
	RecLock("VQ8",.f.)
	VQ8->VQ8_SALDO := VQ8->VQ8_COMTOT - FM_SQL(cQuery)
	MsUnLock()
	//
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		////////////////////////////////////////
		// MEMO com o Historico de Alteracoes //
		////////////////////////////////////////
		lInclui := .f.
		nObsTam := TamSx3("VQ8_OBSERA")[1]
		cObsAlt := E_MSMM(VQ8->VQ8_OBSMEA,nObsTam) // Buscar MEMO
		cObsAlt += left(UPPER(UsrRetName(__CUSERID)),15)+" - "+STR0004+" "+Transform(dDataBase,"@D")+" "+STR0005+" "+left(Time(),5)+"h"+CHR(13)+CHR(10) // Alteracoes: / as
		For nCntFor := 1 to len(aCpoAltVQ8)
			If aCpoAltVQ8[nCntFor,2] <> &("VQ8->"+aCpoAltVQ8[nCntFor,1])
				If aCpoAltVQ8[nCntFor,4] == "G" // Get 
					cAnt := Transform(aCpoAltVQ8[nCntFor,2],aCpoAltVQ8[nCntFor,3])
					cDep := Transform(&("VQ8->"+aCpoAltVQ8[nCntFor,1]),aCpoAltVQ8[nCntFor,3])
				ElseIf aCpoAltVQ8[nCntFor,4] == "C" // Combo
					cAnt := X3CBOXDESC(aCpoAltVQ8[nCntFor,1],aCpoAltVQ8[nCntFor,2])
					cDep := X3CBOXDESC(aCpoAltVQ8[nCntFor,1],&("VQ8->"+aCpoAltVQ8[nCntFor,1]))
				EndIf
				lAlt := .t.
				cObsAlt += AllTrim(RetTitle(aCpoAltVQ8[nCntFor,1]))+" - "+STR0006+" "+cAnt+" - "+STR0007+" "+cDep+CHR(13)+CHR(10) // De: / Para:
			EndIf
		Next
		If lAlt
			cObsAlt += repl("_",47)+CHR(13)+CHR(10)
			MSMM(VQ8->VQ8_OBSMEA,nObsTam,,cObsAlt,1,,,"VQ8","VQ8_OBSMEA") // Gravar MEMO
		EndIf
	EndIf
	//
	// Ponto de Entrada para verificações customizadas após Gravação realizada com sucesso
	If ExistBlock("VCA660DGR")
		ExecBlock("VCA660DGR", .f., .f., {lInclui, VQ8->(RecNo())})
	EndIf
EndIf
Return()

/*/{Protheus.doc} VCA660081_AntesAberturaTela
Funcao executada Antes da Abertura da Tela Cadastro de Seguros

@author Andre Luis Almeida
@since 11/04/2019
/*/
Function VCA660081_AntesAberturaTela(oModel)
Local nCntFor := 1
If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	// Campos utilizados para Historico de Alteracoes //
	For nCntFor := 1 to len(aCpoAltVQ8)
		aCpoAltVQ8[nCntFor,2] := &("VQ8->"+aCpoAltVQ8[nCntFor,1])
	Next
EndIf
Return

/*/{Protheus.doc} VCA660091_ParcelasClientesCorretora
Criar Parcelas de Pagamentos do Seguro em relacao do Cliente com a Corretora

@author Andre Luis Almeida
@since 11/04/2019
/*/
Function VCA660091_ParcelasClientesCorretora()
Local oModel    := FWModelActive()
Local oView     := FWViewActive()
Local oMod_VQN  := oModel:GetModel("VQNFILHO")
Local oMod_VQ8  := oModel:GetModel("VQ8MASTER")
Local aRet      := {}
Local aParamBox := {}
Local aParcelas := {}
Local nDias     := 0
Local nCntFor   := 0
Local nDiaFor   := 0
Local nValParc  := 0
Local dDatParc  := dDataBase
Local nTotParc  := oMod_VQ8:GetValue("VQ8_VALTOT")
Local nQtdParc  := oMod_VQ8:GetValue("VQ8_QTDPAR")
//
AADD(aParamBox,{1,STR0053,nTotParc      ,"@E 999,999,999.99","MV_PAR01 >= 0"                      ,"",".T.",50,.t.}) // Valor Total
AADD(aParamBox,{1,STR0054,dDataBase     ,"@D"               ,"MV_PAR02 >= dDataBase"              ,"",".T.",50,.t.}) // Data Inicial Parcelas
AADD(aParamBox,{1,STR0055,nQtdParc      ,"@E 999"           ,"MV_PAR03 >= 1"                      ,"",".T.",50,.t.}) // Quantidade de Parcelas
AADD(aParamBox,{2,STR0056,"0"           ,{"0="+STR0064,"1="+STR0065}                              ,100,"",.f.,".t."}) // Vencimentos das Parcelas / Com Intervalo de Dias / Em Dia Fixo
AADD(aParamBox,{1,STR0057,30            ,"@E 999"           ,"MV_PAR05 >= 1"                      ,"","IIf(MV_PAR04=='0',.T.,.F.)",50,.f.}) // Qual o Intervalo de Dias
AADD(aParamBox,{1,STR0058,day(dDataBase),"@E 99"            ,"MV_PAR06 >= 1 .and. MV_PAR06 <= 31" ,"","IIf(MV_PAR04=='1',.T.,.F.)",50,.f.}) // Qual o Dia para Fixar
AADD(aParamBox,{2,STR0059,"0"           ,{"1="+STR0060,"0="+STR0061}                              ,50,"",.f.,".t."}) // Apaga Parcelas já Digitadas / Sim / Nao
If ParamBox(aParamBox,STR0040,@aRet,,,,,,,,.f.) // Preencher Parcelas Cliente x Corretora
	nValParc := round( ( aRet[1] / aRet[3] ) , 2 )
	If aRet[4] == "1" // Dia Fixo SIM
		dDatParc := aRet[2]
		cDia     := strzero(aRet[6],2)
		cMesAno  := strzero(Month(dDatParc),2)+"/"+right(strzero(Year(dDatParc),4),2)
		If dDatParc > cTod(cDia+"/"+cMesAno)
			If Month(dDatParc)+1 > 12
				cMesAno := "01/"+right(strzero(Year(dDatParc)+1,4),2)
			Else
				cMesAno := strzero(Month(dDatParc)+1,2)+"/"+right(strzero(Year(dDatParc),4),2)
			EndIf
		EndIf
		dDatParc := cTod(cDia+"/"+cMesAno)
	EndIf
	For nCntFor := 1 to aRet[3]
		If aRet[4] == "0" // Dia Fixo NAO
			dDatParc := aRet[2]+nDias
			nDias += aRet[5]
		Else // aRet[4] == "1" // Dia Fixo SIM
			If nCntFor > 1
				If Month(dDatParc)+1 > 12
					cMesAno := "01/"+right(strzero(Year(dDatParc)+1,4),2)
				Else
					cMesAno := strzero(Month(dDatParc)+1,2)+"/"+right(strzero(Year(dDatParc),4),2)
				EndIf	
				dDatParc := cTod(cDia+"/"+cMesAno)
			EndIf
		EndIf
		If dDatParc < dDataBase // Correcao caso nao exista o dia no final do mes ( exemplo: 31 de fevereiro )
			For nDiaFor := 1 to 3 // Volta no maximo 3 dias (30 29 28)
				dDatParc := cTod(strzero(val(cDia)-nDiaFor,2)+"/"+cMesAno)
				If dDatParc >= dDataBase
					Exit
				EndIf
			Next
		EndIf
		aAdd(aParcelas,{dDatParc,nValParc})
	Next
	If aRet[1] > ( nValParc * aRet[3] )
		aParcelas[1,2] += ( aRet[1] - ( nValParc * aRet[3] ) )
	EndIf
	If aRet[7] == "1" // Apagar as Parcelas Existentes
		For nCntFor := 1 to oMod_VQN:Length()
			oMod_VQN:GoLine(nCntFor)
			oMod_VQN:DeleteLine()
		Next
	EndIf
	For nCntFor := 1 to len(aParcelas) // Criar as Parcelas Calculadas
		oMod_VQN:GoLine(oMod_VQN:Length())
		If oMod_VQN:IsDeleted() .or. !Empty(oMod_VQN:GetValue("VQN_VENCTO")) .or. oMod_VQN:GetValue("VQN_VALOR") > 0
			oMod_VQN:AddLine()
		EndIf
		oMod_VQN:LoadValue("VQN_VENCTO", aParcelas[nCntFor,1] )
		oMod_VQN:LoadValue("VQN_VALOR" , aParcelas[nCntFor,2] )
	Next
	oMod_VQN:GoLine(1)
EndIf
Return

/*/{Protheus.doc} VCA660101_PodeExcluir
Verifica se pode Excluir linhas da grid

@author Andre Luis Almeida
@since 23/04/2019
/*/
Function VCA660101_PodeExcluir(cAliasTab,oSubModel)
Local lRet := .t.
If cAliasTab == "VQX" // Veiculos/Maquinas/Equipamentos
	If !Empty(oSubModel:GetValue("VQX_SINIST"))
		Help(NIL, NIL, "VCA660101_PodeExcluir", NIL, STR0067 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0068}) // Existe(m) Sinistro(s) relacionado(s). / Excluir o(s) Sinistro(s) relacionado(s) a este Veiculo/Máquina/Equipamento.
		lRet := .f. // Nao deixar excluir Veiculo/Maquina/Equipamento se houver Sinistro
	EndIf
EndIf
Return lRet