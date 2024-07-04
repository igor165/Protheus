#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//Variáveis Estáticas
Static cTitulo := "Tabela de Desconto do Esterco"

User Function VACOMM14()
	Local aArea   := GetArea()
	Local oBrowse
	Local cFunBkp := FunName()

	SetFunName("VACOMM14")

	//Cria um browse para a ZDE, filtrando somente a tabela 00 (cabeçalho das tabelas
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZDE")
	oBrowse:SetDescription(cTitulo)
	// oBrowse:SetFilterDefault("ZDE->ZDE_CODIGO == '00'")
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)
Return Nil

Static Function MenuDef()
	Local aRot := {}

	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.VACOMM14' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.VACOMM14' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.VACOMM14' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.VACOMM14' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot

Static Function ModelDef()
	Local oModel   := Nil
	Local oStPai   := FWFormStruct(1, 'ZDE') // FWFormModelStruct():New()
	Local oStFilho := FWFormStruct(1, 'ZDE')
	Local bVldPos  := {|| u_zVldZDETab()}
	Local bVldCom  := {|| u_zSaveZDEMd2()  }
	Local aZDERel  := {}

	//Criando o FormModel, adicionando o Cabeçalho e Grid
	oModel := MPFormModel():New("COMM14M",/*Pre-Validacao*/, bVldPos /*Pos-Validacao*/, bVldCom /*Commit*/,/*Cancel*/)

	oModel:AddFields("ZDEMASTER",/*cOwner*/ ,oStPai  )
	oModel:AddGrid  ('ZDEDETAIL','ZDEMASTER',oStFilho)

	//Adiciona o relacionamento de Filho, Pai
	aAdd(aZDERel, {'ZDE_FILIAL', 'Iif(!INCLUI, ZDE->ZDE_FILIAL, FWxFilial("ZDE"))'} )
	aAdd(aZDERel, {'ZDE_CODIGO', 'Iif(!INCLUI, ZDE->ZDE_CODIGO,  "")'             } )
	aAdd(aZDERel, {'ZDE_DATA'  , 'Iif(!INCLUI, ZDE->ZDE_DATA  ,  sToD(""))'		  } )
	// aAdd(aZDERel, {'ZDE_UMIDAD', 'Iif(!INCLUI, ZDE->ZDE_UMIDAD,  0)'			  } )

	//Criando o relacionamento
	oModel:SetRelation('ZDEDETAIL', aZDERel, ZDE->(IndexKey(1)))

	oModel:SetPrimaryKey({"ZDE_FILIAL","ZDE_CODIGO","ZDE_DATA","ZDE_ITEM"})
	//oModel:SetPrimaryKey({})

	//Setando o campo único da grid para não ter repetição
	oModel:GetModel('ZDEDETAIL'):SetUniqueLine({ "ZDE_FILIAL","ZDE_CODIGO","ZDE_DATA","ZDE_ITEM" })

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZDEMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

Static Function ViewDef()
	Local oModel     := FWLoadModel("VACOMM14")
	Local oStPai     := FWFormStruct(2, 'ZDE') // FWFormViewStruct():New()
	Local oStFilho   := FWFormStruct(2, 'ZDE')
	//Criando a view que será o retorno da função e setando o modelo da rotina
	Local oView      := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB" , oStPai  , "ZDEMASTER")
	oView:AddGrid('VIEW_ITENS', oStFilho, 'ZDEDETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 30)
	oView:CreateHorizontalBox('GRID' , 70)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB'  ,'CABEC')
	oView:SetOwnerView('VIEW_ITENS','GRID' )

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB','Cabeçalho - Desconto Esterco')
	oView:EnableTitleView('VIEW_ITENS','Itens - Desconto Esterco')

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk( { |oView| .T. } )
	
	//Remove os campos de Filial e Tabela da Grid
	oStPai:RemoveField('ZDE_ITEM')
	oStPai:RemoveField('ZDE_TIPO')
	oStPai:RemoveField('ZDE_DATAF')
	oStPai:RemoveField('ZDE_TOLDE')
	oStPai:RemoveField('ZDE_TOLATE')
	oStPai:RemoveField('ZDE_PERCE')

	oStFilho:RemoveField('ZDE_FILIAL')
	oStFilho:RemoveField('ZDE_CODIGO')
	oStFilho:RemoveField('ZDE_DATA')
Return oView

User Function zVldZDETab()
	Local aArea  := GetArea()
	Local oModel := FWModelActive()
	Local nOpc   := oModel:GetOperation()
	Local lRet   := .T.

	//Se for Inclusão
	If nOpc == MODEL_OPERATION_INSERT
		DbSelectArea('ZDE')
		ZDE->(DbSetOrder(1)) //ZDM_FILIAL + ZDM_CODIGO + ZDM_CODIGO

		//Se conseguir posicionar, tabela já existe
		If ZDE->(DbSeek( xFilial("ZDE") +;
				oModel:GetValue('ZDEMASTER', 'ZDE_CODIGO') +;
				dToS(oModel:GetValue('ZDEMASTER', 'ZDE_DATA'))))
			Aviso('Atenção', 'Esse código de tabela já existe!', {'OK'}, 02)
			lRet := .F.
		EndIf
	EndIf
	//
	RestArea(aArea)
Return lRet

User Function zSaveZDEMd2()
	Local aArea      := GetArea()
	Local lRet       := .T.
	Local oModelDad  := FWModelActive()
	Local nOpc       := oModelDad:GetOperation()
	Local oModelGrid := oModelDad:GetModel('ZDEDETAIL')/* :SetUniqueLine({'ZDE_CODIGO'}) */
 //   Local aHeadAux   := oModelGrid:aHeader
	Local nI         := 0//, nJ := 0
	Local lRecLock   := .T.
	Local lDel		 := .F.
	Local nItem		 := 0
 //ZDM_FILIAL + ZDM_CODIGO + ZDM_CODIGO
	DbSelectArea('ZDE')
	ZDE->(DbSetOrder(1))
	//Se for Inclusão
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
		//Cria o registro na tabela 00 (Cabeçalho de tabelas)
		
		//Percorre as linhas da grid
		For nI := 1 To oModelGrid:GetQtdLine()
			
			oModelGrid:GoLine(nI)
			If !oModelGrid:isDeleted()
				RecLock('ZDE', lRecLock := !DbSeek( xFilial("ZDE") +;
											oModelDad:GetValue('ZDEMASTER', 'ZDE_CODIGO') +;
											dToS(oModelDad:GetValue('ZDEMASTER', 'ZDE_DATA') ) +;
											oModelGrid:GetValue('ZDE_ITEM')))

					ZDE->ZDE_FILIAL     := oModelDad:GetValue('ZDEMASTER', 'ZDE_FILIAL')
					ZDE->ZDE_CODIGO 	:= oModelDad:GetValue('ZDEMASTER', 'ZDE_CODIGO') 
					ZDE->ZDE_DATA   	:= oModelDad:GetValue('ZDEMASTER', 'ZDE_DATA')	
					if lDel
						ZDE->ZDE_ITEM   	:= oModelGrid:GetValue('ZDE_ITEM')
					else 
						ZDE->ZDE_ITEM 		:= StrZero( nItem, TamSX3("ZDE_ITEM")[1])
						lDel := .F.
					ENDIF
					ZDE->ZDE_TIPO   	:= oModelGrid:GetValue('ZDE_TIPO')
					ZDE->ZDE_DATAF   	:= oModelGrid:GetValue('ZDE_DATAF') 
					ZDE->ZDE_TOLDE   	:= oModelGrid:GetValue('ZDE_TOLDE')
					ZDE->ZDE_TOLATE   	:= oModelGrid:GetValue('ZDE_TOLATE')
					ZDE->ZDE_PERCE   	:= oModelGrid:GetValue('ZDE_PERCE')
				ZDE->(MsUnlock())
			Else		
 				If ZDE->(DbSeek( xFilial("ZDE") +;
						oModelDad:GetValue('ZDEMASTER', 'ZDE_CODIGO') +;
						dToS(oModelDad:GetValue('ZDEMASTER', 'ZDE_DATA') )+;
						oModelGrid:GetValue('ZDE_ITEM')))

					lDel := .T.
					
					nItem := vAL(oModelGrid:GetValue('ZDE_ITEM')) -1
					//ZDE->ZDE_ITEM := StrZero( oModelGrid:GetLine()-1, TamSX3("ZDE_ITEM")[1])

					RecLock('ZDE', .F.)
						ZDE->(DbDelete())
					ZDE->(MsUnlock())
				EndIf 
			EndIf
		Next nI

	//Se for Exclusão
	ElseIf nOpc == MODEL_OPERATION_DELETE
		For nI := 1 To oModelGrid:GetQtdLine()
			oModelGrid:GoLine(nI)
			//Se conseguir posicionar, exclui o registro
			If ZDE->(DbSeek( xFilial("ZDE") +;
					oModelDad:GetValue('ZDEMASTER', 'ZDE_CODIGO') +;
					dToS(oModelDad:GetValue('ZDEMASTER', 'ZDE_DATA') +;
					oModelGrid:GetValue('ZDE_ITEM') ) ) )

				RecLock('ZDE', .F.)
				ZDE->(DbDelete())
				ZDE->(MsUnlock())
			
			EndIf
		Next nI
	EndIf

	//Se não for inclusão, volta o INCLUI para .T. (bug ao utilizar a Exclusão, antes da Inclusão)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

	RestArea(aArea)
Return lRet

/* 
	Igor Oliveira - 18/04/22 - Contador de campo.
 */
 User Function IniCampo(_cAlias,_cCampo)

	Local oModelDad  := FWModelActive()
	Local oModelGrid := oModelDad:GetModel(_cAlias)
	Local cRetorno   := StrZero( 1, TamSX3("ZDE_ITEM")[1] )

	If (oModelGrid:GetLine() >= 1)
		cRetorno := StrZero( Val( oModelGrid:GetValue('ZDE_ITEM')) + 1 , TamSX3("ZDE_ITEM")[1] )
	EndIf 

RETURN cRetorno

