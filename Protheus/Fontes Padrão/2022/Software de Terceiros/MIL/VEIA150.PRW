#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA150.CH"

/*/{Protheus.doc} VEIA150()
Cadastro de Sinistros dos Seguros

@author Andre Luis Almeida
@since 16/04/2019
@version 1.0
@return NIL
/*/
Function VEIA150()
Local aCombo  := {}
Local nCntFor := 0
Local oBrowse
Private oModel
//
DbSelectArea("VQ8")
aCombo := X3CBOXAVET("VQ8_STATUS","0")
//
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("VQ8")
oBrowse:SetDescription(STR0001) // Sinistros dos Seguros
oBrowse:AddLegend( "dtos(VQ8_DATVIG)>='"+dtos(dDataBase)+"'" , "BR_VERDE" , STR0019 ) // Seguros dentro da Data de Vigencia
oBrowse:AddLegend( "dtos(VQ8_DATVIG)<'"+dtos(dDataBase)+"'" , "BR_BRANCO" , STR0020 ) // Seguros fora da Data de Vigencia
For nCntFor := 1 to len(aCombo)
	oBrowse:AddFilter(STR0018+": "+Substr(aCombo[nCntFor],3),"VQ8_STATUS='"+left(aCombo[nCntFor],1)+"'",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar - Indicador:
Next
oBrowse:DisableDetails()
oBrowse:Activate()
//
Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 16/04/2019
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.VEIA150' OPERATION 2 ACCESS 0 // Visualizar
If IsInCallStack('VEICA660') // Cadastro de Seguros
	ADD OPTION aRotina TITLE STR0003 ACTION 'VA1500011_Executar(3)' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VA1500011_Executar(4)' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VA1500061_BancoDeConhecimento("1")' OPERATION 4 ACCESS 0 // Banco de Conhecimento do Sinistro
Else
	ADD OPTION aRotina TITLE STR0004 ACTION 'VA1500011_Executar(4)' OPERATION 4 ACCESS 0 // Alterar
EndIf
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.VEIA150' OPERATION 8 ACCESS 0 // Imprimir
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 16/04/2019
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVQ8 := FWFormStruct(1,"VQ8")
Local oStrVQW := FWFormStruct(1,"VQW")

oModel := MPFormModel():New("VEIA150", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VQ8MASTER",/*cOwner*/ , oStrVQ8)
oModel:AddGrid( "VQWFILHO" , "VQ8MASTER", oStrVQW , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VQWFILHO", {{'VQW_FILIAL','VQ8_FILIAL'}, {'VQW_CODSEG','VQ8_CODIGO'}}, VQW->(IndexKey(2)) )

oModel:GetModel("VQ8MASTER"):SetDescription(STR0007) // Seguro
oModel:GetModel("VQWFILHO"):SetDescription(STR0008) // Sinistros

oModel:GetModel("VQWFILHO"):SetOptional(.T.)

oModel:SetDescription(STR0008) // Sinistros
//oModel:InstallEvent("VEIA150LOG", /*cOwner*/, MVCLOGEV():New("VEIA150") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("VEIA150EVDEF", /*cOwner*/, VEIA150EVDEF():New() )

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 16/04/2019
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVQ8:= FWFormStruct(2,"VQ8")
Local oStrVQW:= FWFormStruct(2,"VQW", { |x| !ALLTRIM(x) $ 'VQW_CODIGO,VQW_CODSEG' } )

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_VQ8', oStrVQ8, 'VQ8MASTER' )
oView:AddGrid( 'VIEW_VQW' , oStrVQW, 'VQWFILHO' )

oStrVQ8:SetProperty( "*" ,MVC_VIEW_CANCHANGE, .f. )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' , 60)
oView:CreateHorizontalBox('FILHO' , 40)

oView:SetOwnerView('VIEW_VQ8', 'CABEC' )
oView:SetOwnerView('VIEW_VQW', 'FILHO')

oView:SetCloseOnOk({||.T.})

// Criar novo botao na barra de botoes
oView:AddUserButton(STR0005,'CLIPS' ,{ |oView| VA1500061_BancoDeConhecimento("2") })

Return oView

/*/{Protheus.doc} VA1500011_Executar
	Opções quando acionadas pelo OFIA120 ( Oportunidades Agrupadas )

	@author Andre Luis Almeida
	@since 16/04/2019
/*/
Function VA1500011_Executar(nTp)
Local oView := FWViewExec():New()
Local oAuxView
//
If nTp == 3
	oView:setTitle(UPPER(STR0003)) // Incluir
ElseIf nTp == 4
	oView:setTitle(UPPER(STR0004)) // Alterar
Else
	oView:setTitle(UPPER(STR0008)) // Sinistros
EndIf
DbSelectArea("VQ8")
oAuxView  := FWLoadView("VEIA150")
oView:SetView(oAuxView)
oView:setModal(.F.)
If nTp == 3 .or. nTp == 4 // Incluir ou Alterar
	oView:setOperation(MODEL_OPERATION_UPDATE)
Else
	oView:setOperation(MODEL_OPERATION_VIEW)
EndIf
oView:openView(.F.)
//
Return

/*/{Protheus.doc} VA1500021_DescricaoVQX
	Retorna String com a Marca, Modelo, Chassi e Ano Fab/Mod

	@author Andre Luis Almeida
	@since 16/04/2019
/*/
Function VA1500021_DescricaoVQX(cFilVQX,cCodVQX,cCodSeg)
Local cDescVQX  := ""
Local cQuery    := ""
Local cQAlias   := "SQLVQX"
Default cFilVQX := xFilial("VQX")
Default cCodVQX := VQW->VQW_CODVQX
Default cCodSeg := VQW->VQW_CODSEG
cQuery := "SELECT VQX_CODMAR, VQX_MODVEI, VQX_CHASSI, VQX_FABMOD "
cQuery += "  FROM "+RetSQLName("VQX")
cQuery += " WHERE VQX_FILIAL='"+cFilVQX+"'"
cQuery += "   AND VQX_CODIGO='"+cCodVQX+"'"
cQuery += "   AND VQX_CODSEG='"+cCodSeg+"'"
cQuery += "   AND D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F. , .T. )
If !(cQAlias)->(Eof())
	cDescVQX := Alltrim((cQAlias)->( VQX_CODMAR ))+" "
	cDescVQX += Alltrim((cQAlias)->( VQX_MODVEI ))+" - "
	cDescVQX += Alltrim((cQAlias)->( VQX_CHASSI ))
	If !Empty((cQAlias)->( VQX_FABMOD ))
		cDescVQX += " - "+Transform((cQAlias)->( VQX_FABMOD ),"@R 9999/9999")
	EndIf
	cDescVQX := Padr(cDescVQX,TamSX3("VQW_DESVQX")[1])
EndIf
(cQAlias)->(dbCloseArea())
DbSelectArea("VQW")
Return cDescVQX

/*/{Protheus.doc} VA1500031_Valid
	Validacao do Sinistro

	@author Andre Luis Almeida
	@since 16/04/2019
/*/
Function VA1500031_Valid(oSubModel,cId,xValue,xCurrentValue)
Local lRet   := .t.
Local cDescr := ""
Do Case 

	Case cId == "VQW_CODVQX"
		cDescr := VA1500021_DescricaoVQX(xFilial("VQX"),xValue,VQ8->VQ8_CODIGO)
		If Empty(cDescr)
			lRet := .f.
			Help(NIL, NIL, "VA1500031_Valid", NIL, STR0014, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0015}) // Código inválido! / Informe um Código válido.
		Else
			oSubModel:LoadValue("VQW_DESVQX",cDescr)	// Atualizar campo na tela
		EndIf

	Case cId == "VQW_TIPSIN"
		If !Empty(xValue)
			cDescr := OFIOA560DS("053",xValue) // Retorna a Descricao do VX5
			If Empty(cDescr)
				lRet := .f.
				Help(NIL, NIL, "VA1500031_Valid", NIL, STR0016, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0017}) // Tipo de Sinistro inválido! / Informe um Tipo de Sinistro válido.
			Else
				cDescr := Padr(cDescr,TamSX3("VQW_DESTPS")[1])
				oSubModel:LoadValue("VQW_DESTPS",cDescr)	// Atualizar campo na tela
			EndIf
		EndIf

EndCase
Return lRet

/*/{Protheus.doc} VA1500041_PossuiSinistros
Verifica se a Apolice/Veiculo possui Sinistro

@author Andre Luis Almeida
@since 16/04/2019
/*/
Function VA1500041_PossuiSinistros()
Local cQuery  := ""
Local cQAlias := "SQLVQW"
Local cRet    := ""
Local nQtdSin := 0
If !Inclui .and. !Empty(VQX->VQX_CODIGO)
	// Verificar a Quantidade de Sinistros
	cQuery := "SELECT COUNT(VQW_CODIGO) "
	cQuery += "  FROM "+RetSQLName("VQW")
	cQuery += " WHERE VQW_FILIAL='"+xFilial("VQW")+"'"
	cQuery += "   AND VQW_CODSEG='"+VQX->VQX_CODSEG+"'"
	cQuery += "   AND VQW_CODVQX='"+VQX->VQX_CODIGO+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	nQtdSin := FM_SQL(cQuery)
	If nQtdSin > 0
		// Buscar o Ultimo Sinistro
		cQuery := "SELECT VQW_TIPSIN, VQW_DATSIN, VQW_HORSIN, VQW_STATUS "
		cQuery += "  FROM "+RetSQLName("VQW")
		cQuery += " WHERE VQW_FILIAL='"+xFilial("VQW")+"'"
		cQuery += "   AND VQW_CODSEG='"+VQX->VQX_CODSEG+"'"
		cQuery += "   AND VQW_CODVQX='"+VQX->VQX_CODIGO+"'"
		cQuery += "   AND D_E_L_E_T_=' '"
		cQuery += " ORDER BY VQW_CODIGO DESC"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F. , .T. )
		If !(cQAlias)->(Eof())
			If nQtdSin == 1 // Apenas 1 Sinistro
				cRet := "(1) "+STR0009+" " // Sinistro
			Else
				cRet := "("+Alltrim(str(nQtdSin))+") "+STR0010+" " // Ultimo Sinistro
			EndIf
			cRet += Alltrim(OFIOA560DS("053",(cQAlias)->( VQW_TIPSIN )))+ " - " // Retorna a Descricao do VX5
			If !Empty((cQAlias)->( VQW_DATSIN ))
				cRet += Transform(stod((cQAlias)->( VQW_DATSIN )),"@D")+" "
			EndIf
			If !Empty((cQAlias)->( VQW_HORSIN ))
				cRet += Transform((cQAlias)->( VQW_HORSIN ),"@R 99:99")+" - "
			EndIf
			cRet += STR0011+": "+X3CBOXDESC("VQW_STATUS",(cQAlias)->( VQW_STATUS )) // Status
		EndIf
		(cQAlias)->(dbCloseArea())
		DbSelectArea("VQX")
	EndIf
EndIf
Return cRet


/*/{Protheus.doc} VA1500051_BatizaNumeracaoVQW
	Batiza a Filial/Numeracao do VQW

	@author Andre Luis Almeida
	@since 16/04/2019
/*/
Function VA1500051_BatizaNumeracaoVQW()
RecLock("VQW",.f.)
	VQW->VQW_FILIAL := xFilial("VQW")
	VQW->VQW_CODIGO := GetSXENum("VQW","VQW_CODIGO") // Numeracao (auto-incremento)
	ConfirmSX8()
MsUnLock()
Return

/*/{Protheus.doc} VA1500061_BancoDeConhecimento
Chamada do Banco de Conhecimento para o Sinistro

@author Andre Luis Almeida
@since 16/04/2019
/*/
Function VA1500061_BancoDeConhecimento(cTp)
Local oModel
Local oView
Local oMod_VQW
Local nRecNo    := 0
// Necessario devido a a funcao PADRAO TOTVS do Banco de Conhecimento
Private aRotina := {{ " " ," " , 0, 1},;	// Pesquisar
					{ " " ," " , 0, 2},;	// Visualizar
					{ " " ," " , 0, 3},;	// Incluir
					{ " " ," " , 0, 4},;	// Alterar
					{ " " ," " , 0, 5} }	// Excluir
If cTp == "1" // 1=Chamada diretamente pelo MENU
	nRecNo := VQW->(RecNo())
ElseIf cTp == "2" // Chamado dentro do Sinistro mas nao pode estar Incluindo
	oModel   := FWModelActive()
	oView    := FWViewActive()
	oMod_VQW := oModel:GetModel("VQWFILHO")
	If !oMod_VQW:IsInserted(oMod_VQW:GetLine()) .and. !Empty(oMod_VQW:GetValue("VQW_CODIGO"))
		VQW->(DbSetOrder(1))
		If VQW->(DbSeek(xFilial("VQW")+oMod_VQW:GetValue("VQW_CODIGO")))
			nRecNo := VQW->(RecNo())
		EndIf
	EndIf
EndIf
If nRecNo > 0
	MsDocument("VQW",nRecNo,4)
Else
	Help(NIL, NIL, "VA1500061_BancoDeConhecimento", NIL, STR0012 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0013}) // Banco de Conhecimento não disponivel antes de Salvar este registro de Sinistro / Após Salvar o Sinistro, acesse novamente a opção de Banco de Conhecimento.
EndIf
Return