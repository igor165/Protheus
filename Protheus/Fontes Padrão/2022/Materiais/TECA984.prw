#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA984.CH"

Static lUniform := At984Uni()
Static lOrcPrc := SuperGetMv("MV_ORCPRC",, .F.)	//	Usa a tabela de precificação

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA984
@description	Facilitador
@sample	 	TECA984()
@param		Nenhum
@return		NIL
@author		Filipe Gonçalves (filipe.goncalves)
@since		31/05/2016
@version	P12
@history  27/11/2020: Mário A. Cavenaghi - EthosX: Tirar a obrigatoriedade da Pasta Recursos Humanos
          02/12/2020: Mário A. Cavenaghi - EthosX: Orçamento não carrega todos as Pastas do Facilitador
/*/
//------------------------------------------------------------------------------
Function TECA984()
Local	oMBrowse	:= Nil

If SuperGetMv("MV_GSITORC",,"2") == "1"
	If FindFunction("TecGsPrecf") .And. TecGsPrecf()
		TECA984A()
	Else
		Help( "", 1, "TECA984A", , "Não é possível iniciar o facilitador.", 1, 0,,,,,,{"Realize a inclusão das tabelas TXR."}) // "Não é possível iniciar o facilitador." ## "Realize a inclusão das tabelas TXR."
	Endif
Else
	oMBrowse := FWmBrowse():New()
	oMBrowse:SetAlias("TWM")
	oMBrowse:SetDescription(STR0001)	// "Facilitador"
	//Legendas
	oMBrowse:AddLegend( "TWM_DTVALI >= dDataBase", "GREEN"	, STR0011 	)//"Aberto"
	oMBrowse:AddLegend( "TWM_DTVALI <= dDataBase", "RED"	, STR0012 	)//"Encerrado"
	// filtra a filial corrente no browse para não ter problema na carga do modelo de dados e leitura do parâmetro de precificação
	// quando distribuído por filial
	oMBrowse:SetFIlterDefault("TWM->TWM_FILIAL == xFilial('TWM')")
	oMBrowse:Activate()
Endif

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@description	Define o menu funcional.
@sample	 		MenuDef()
@param			Nenhum
@return			ExpA: Opções da Rotina.
@author			Filipe Goncalves
@since			31/05/2016
@version		P12
/*/

//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}

If IsInCallStack("TECA984A")
	MenuDefA(@aRotina)
Else
	ADD OPTION aRotina TITLE STR0002  ACTION "PesqBrw"         OPERATION 1                      ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TECA984" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TECA984" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TECA984" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TECA984" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE STR0013  ACTION "VIEWDEF.TECA984" OPERATION 9                      ACCESS 0 // "Copiar"
Endif

Return(aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@description	Definição do Model
@sample	 		ModelDef()
@param			Nenhum
@return			ExpO: Objeto FwFormModel
@author			Filipe Gonçalves
@since			31/05/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= Nil
Local oStrTWM	:= FWFormStruct(1, "TWM")	// Cabeçalho Facilitador
Local oStruRH 	:= FWFormStruct(1, "TWN")
Local oStruMC 	:= FWFormStruct(1, "TWN")
Local oStruMI 	:= FWFormStruct(1, "TWN")
Local oStruLE 	:= FWFormStruct(1, "TWN")
Local oStruUN 	:= Iif(lUniform,FWFormStruct(1, "TXK"),NIL) //Uniforme
Local bCommit 	:= {|oModel| At984Grv( oModel ) }
Local aOnlyRh 	:= { "TWN_FUNCAO", "TWN_DESFUN", "TWN_TURNO", "TWN_DTURNO", "TWN_CARGO", "TWN_DCARGO" }
Local nZ 		:= 1

For nZ := 1 To Len( aOnlyRh )
	oStruMC:RemoveField( aOnlyRh[nZ] )
	oStruMI:RemoveField( aOnlyRh[nZ] )
	oStruLE:RemoveField( aOnlyRh[nZ] )
Next

oStruRH:SetProperty('TWN_DESCRI',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA984","RHDETAIL","B1_DESC","SB1",1, "XFILIAL('SB1')+TWN->TWN_CODPRO") } )
oStruMC:SetProperty('TWN_DESCRI',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA984","MCDETAIL","B1_DESC","SB1",1, "XFILIAL('SB1')+TWN->TWN_CODPRO") } )
oStruMI:SetProperty('TWN_DESCRI',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA984","MIDETAIL","B1_DESC","SB1",1, "XFILIAL('SB1')+TWN->TWN_CODPRO") } )
oStruLE:SetProperty('TWN_DESCRI',MODEL_FIELD_INIT,{|| ATINIPADMVC("TECA984","LEDETAIL","B1_DESC","SB1",1, "XFILIAL('SB1')+TWN->TWN_CODPRO") } )

If lUniform
	oStruUN:SetProperty('TXK_DESCR',MODEL_FIELD_INIT,{||GetAdvFVal('SB1',"B1_DESC", xFilial("SB1")+TXK->TXK_CODPRO, 1, "") } )
EndIf

// Cria o objeto do modelo de dados principal
oModel := MPFormModel():New("TECA984", /*bPreValid*/, /*bPósValid*/, bCommit, /*bCancel*/)

// Cria a antiga Enchoice do grupo de comunicação
oModel:AddFields("TWMMASTER", /*cOwner*/, oStrTWM,,, {|x,y|LoadEnch(x,y)} )

// Cria a grid das etapas do grupo de comunicação
oModel:AddGrid("RHDETAIL","TWMMASTER",oStruRH,/*bPreValidacao*/,/*bPosValidacao*/,,, /*bCarga*/)
oModel:AddGrid("MCDETAIL","TWMMASTER",oStruMC,/*bPreValidacao*/,/*bPosValidacao*/,,,/*bCarga*/)
oModel:AddGrid("MIDETAIL","TWMMASTER",oStruMI,/*bPreValidacao*/,/*bPosValidacao*/,,,/*bCarga*/)
oModel:AddGrid("LEDETAIL","TWMMASTER",oStruLE,/*bPreValidacao*/,/*bPosValidacao*/,,, /*bCarga*/)

If lUniform	//Modelo de dados do uniforme
	oModel:AddGrid("UNIDETAIL","TWMMASTER",oStruUN,/*bPreValidacao*/,/*bPosValidacao*/,,, /*bCarga*/)
EndIf 

//Criação dos relacionamentos
oModel:SetRelation("RHDETAIL", {{"TWN_FILIAL","xFilial('TWN')"}, {"TWN_CODTWM","TWM_CODIGO"}, {"TWN_TPITEM","'1'"}}, TWN->(IndexKey(1)))
oModel:SetRelation("MCDETAIL", {{"TWN_FILIAL","xFilial('TWN')"}, {"TWN_CODTWM","TWM_CODIGO"}, {"TWN_TPITEM","'2'"}}, TWN->(IndexKey(1)))
oModel:SetRelation("MIDETAIL", {{"TWN_FILIAL","xFilial('TWN')"}, {"TWN_CODTWM","TWM_CODIGO"}, {"TWN_TPITEM","'3'"}}, TWN->(IndexKey(1)))
oModel:SetRelation("LEDETAIL", {{"TWN_FILIAL","xFilial('TWN')"}, {"TWN_CODTWM","TWM_CODIGO"}, {"TWN_TPITEM","'4'"}}, TWN->(IndexKey(1)))

If lUniform	//Uniforme
	oModel:SetRelation("UNIDETAIL", {{"TXK_FILIAL","xFilial('TXK')"}, {"TXK_CODTWM","TWM_CODIGO"}}, TXK->(IndexKey(1)))
EndIf 

//Definição das descrições
oModel:GetModel("RHDETAIL"):SetDescription(STR0007)	// "Recursos Humanos"
oModel:GetModel("MCDETAIL"):SetDescription(STR0008)	// "Material de Consumo"
oModel:GetModel("MIDETAIL"):SetDescription(STR0009)	// "Material de Implantação"
oModel:GetModel("LEDETAIL"):SetDescription(STR0010)	// "Locação de Equipamento"

If lUniform
	oModel:GetModel("UNIDETAIL"):SetDescription(STR0019)	// "Uniformes"
	oModel:GetModel("UNIDETAIL"):SetOptional(.T.)
EndIf 

//Define se modelos são obrigatórios
oModel:GetModel("RHDETAIL"):SetOptional(.T.)
oModel:GetModel("MCDETAIL"):SetOptional(.T.)
oModel:GetModel("MIDETAIL"):SetOptional(.T.)
oModel:GetModel("LEDETAIL"):SetOptional(.T.)

If ExistBlock("T984MCPO")	//PE T740MCPO para manipular campos no Modelo
	ExecBlock("T984MCPO",.F.,.F.,@oModel)
EndIf
oModel:SetActivate( {|oModel| At984Activ( oModel ) } )

Return(oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description	Definição da View
@sample	 		ViewDef()
@param			Nenhum
@return			ExpO	Objeto FwFormView
@author			Filipe Gonçalves
@since			31/05/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil						// Interface de visualização construída
Local oModel	:= ModelDef()				// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStrTWM   := FWFormStruct(2, "TWM")   // Cria a estrutura a ser usada na View
Local oStrRH 	:= FWFormStruct(2, "TWN", {|cCampo| !AllTrim(cCampo)$ "TWN_CODTWM|TWN_TPITEM|TWN_TES"})
Local oStrMC 	:= FWFormStruct(2, "TWN", {|cCampo| !AllTrim(cCampo)$ "TWN_CODTWM|TWN_TPITEM|TWN_FUNCAO|TWN_DESFUN|TWN_TURNO|TWN_DTURNO|TWN_CARGO|TWN_DCARGO"})
Local oStrMI 	:= FWFormStruct(2, "TWN", {|cCampo| !AllTrim(cCampo)$ "TWN_CODTWM|TWN_TPITEM|TWN_FUNCAO|TWN_DESFUN|TWN_TURNO|TWN_DTURNO|TWN_CARGO|TWN_DCARGO"})
Local oStrLE 	:= FWFormStruct(2, "TWN", {|cCampo| !AllTrim(cCampo)$ "TWN_CODTWM|TWN_TPITEM|TWN_FUNCAO|TWN_DESFUN|TWN_TURNO|TWN_DTURNO|TWN_CARGO|TWN_DCARGO"})
Local oStrUN 	:= Iif(lUniform,FWFormStruct(2, "TXK", {|cCampo| !AllTrim(cCampo)$ "TXK_CODTWM"}),NIL)

oStrRh:RemoveField("TWN_ITEMRH")
oStrMC:RemoveField("TWN_ITEMRH")
oStrMI:RemoveField("TWN_ITEMRH")
oStrLE:RemoveField("TWN_ITEMRH")

If lOrcPrc
	oStrRH:RemoveField('TWN_VLUNIT')
EndIf
oStrLE:RemoveField('TWN_VLUNIT')

// Cria o objeto de View
oView	:= FWFormView():New()

// Define qual modelo de dados será utilizado
oView:SetModel(oModel)

// Adiciona as visões na tela
oView:CreateHorizontalBox("TOP",  30)
oView:CreateHorizontalBox("DOWN", 70)
oView:AddField("VIEW_TWM", oStrTWM, "TWMMASTER")		// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:SetOwnerView("VIEW_TWM", "TOP")					// Relaciona o identificador (ID) da View com o "box" para sua exibição
oView:CreateFolder("ABAS", "DOWN")						// Cria Folders na view

// Cria as grids para o modelo
//RH
oView:AddGrid("VIEW_RH", oStrRH, "RHDETAIL")
oView:AddSheet("ABAS", "DOWN_RHDETAIL", STR0007)//Recursos Humanos
oView:CreateHorizontalBox("ID_DOWN_RHDETAIL", 100,,, "ABAS", "DOWN_RHDETAIL")
oView:SetOwnerView("VIEW_RH", "ID_DOWN_RHDETAIL")
oView:AddIncrementField('VIEW_RH' , 'TWN_ITEM' )
//Fim RH

//MC
oView:AddGrid("VIEW_MC", oStrMC, "MCDETAIL")
oView:AddSheet("ABAS", "DOWN_MCDETAIL", STR0008)//Material de Consumo
oView:CreateHorizontalBox("ID_DOWN_MCDETAIL", 100,,, "ABAS", "DOWN_MCDETAIL")
oView:SetOwnerView("VIEW_MC", "ID_DOWN_MCDETAIL")
oView:AddIncrementField('VIEW_MC' , 'TWN_ITEM' )
//Fim MC

//MI
oView:AddGrid("VIEW_MI", oStrMI, "MIDETAIL")
oView:AddSheet("ABAS", "DOWN_MIDETAIL", STR0009)//Material de Implantação
oView:CreateHorizontalBox("ID_DOWN_MIDETAIL", 100,,, "ABAS", "DOWN_MIDETAIL")
oView:SetOwnerView("VIEW_MI", "ID_DOWN_MIDETAIL")
oView:AddIncrementField('VIEW_MI' , 'TWN_ITEM' )
//Fim MI

//LE
oView:AddGrid("VIEW_LE", oStrLE, "LEDETAIL")
oView:AddSheet("ABAS", "DOWN_LEDETAIL", STR0010)//Locação de Equipamento
oView:CreateHorizontalBox("ID_DOWN_LEDETAIL", 100,,, "ABAS", "DOWN_LEDETAIL")
oView:SetOwnerView("VIEW_LE", "ID_DOWN_LEDETAIL")
oView:AddIncrementField('VIEW_LE' , 'TWN_ITEM' )
//Fim LE

If lUniform
	//Uniforme
	oView:AddGrid("VIEW_UN", oStrUN, "UNIDETAIL")
	oView:AddSheet("ABAS", "DOWN_UNIDETAIL", STR0019)//Uniformes
	oView:CreateHorizontalBox("ID_DOWN_UNIDETAIL", 100,,, "ABAS", "DOWN_UNIDETAIL")
	oView:SetOwnerView("VIEW_UN", "ID_DOWN_UNIDETAIL")
	oView:AddIncrementField('VIEW_UN' , 'TXK_ITEM' )
	//Fim Uniforme
EndIf	

If !GSGetIns('RH')
	oView:HideFolder("ABAS", STR0007, 2)
EndIf

If !GSGetIns('MI')  //MI/MC
	oView:HideFolder( "ABAS",  STR0008, 2)
	oView:HideFolder( "ABAS",  STR0009, 2)
EndIf

If !GSGetIns('LE')
	oView:HideFolder( "ABAS",  STR0010, 2)
EndIf

If !lUniform 
	oView:HideFolder( "ABAS",  STR0019, 2) //"Uniformes"
EndIf

// Identificação (Nomeação) da VIEW
oView:SetDescription(STR0001) // "Facilitador"
//PE T740VCPO para manipular campos na View
If ExistBlock("T984VCPO")
	ExecBlock("T984VCPO",.F.,.F.,{@oStrRH, @oStrMC, @oStrMI, @oStrLE})
EndIf


Return(oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT984ValTp
@description	Validação do Tipo de Produto conforme a aba atual
@sample	 		AT984ValTp()
@param			Nenhum
@return			lRet	Logico
@author			Joni Lima do Carmo
@since			03/08/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function AT984ValTp()

Local aArea	 	:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSB5	:= SB5->(GetArea())
Local lRet			:= .T.
Local oView		:= FWViewActive()
Local oModel		:= FwModelActive()
Local cNMdl		:= ''
Local oMdDet		:= nil

If ValType(oView) == 'O' .and. FunName() == 'TECA984'

		//Case para Pegar o Modelo
	DO CASE
		CASE oView:GetFolderActive("ABAS", 2)[1] == 1 // Aba RH
			cNMdl := 'RHDETAIL'
		CASE oView:GetFolderActive("ABAS", 2)[1] == 2 // Aba MC
			cNMdl := 'MCDETAIL'
		CASE oView:GetFolderActive("ABAS", 2)[1] == 3 // Aba MI
			cNMdl := 'MIDETAIL'
		CASE oView:GetFolderActive("ABAS", 2)[1] == 4 // Aba LE
			cNMdl := 'LEDETAIL'
	ENDCASE

	oMdDet := oModel:GetModel(cNMdl)

	dbSelectArea('SB5')
	SB5->(dbSetOrder(1))//B5_FILIAL+B5_COD

	If SB5->(dbSeek(xFilial('SB5') + oMdDet:GetValue('TWN_CODPRO')))

		//Case para fazer a validação Baseado na SB5
		DO CASE
			CASE oView:GetFolderActive("ABAS", 2)[1] == 1 // Aba RH
				lRet := SB5->B5_TPISERV = '4'
				If !lRet
					Help( ' ', 1, 'TECA984', , STR0014, 1, 0 )
				EndIf
			CASE oView:GetFolderActive("ABAS", 2)[1] == 2 // Aba MC
				lRet := SB5->B5_TPISERV = '5' .and. SB5->B5_GSMC= '1'
				If !lRet
					Help( ' ', 1, 'TECA984', , STR0015, 1, 0 )
				EndIf
			CASE oView:GetFolderActive("ABAS", 2)[1] == 3 // Aba MI
				lRet := SB5->B5_TPISERV = '5' .and. SB5->B5_GSMI= '1'
				If !lRet
					Help( ' ', 1, 'TECA984', , STR0016, 1, 0 )
				EndIf
			CASE oView:GetFolderActive("ABAS", 2)[1] == 4 // Aba LE
				lRet := SB5->B5_TPISERV = '5' .and. SB5->B5_GSLE= '1'
				If !lRet
					Help( ' ', 1, 'TECA984', , STR0017, 1, 0 )
				EndIf
			OTHERWISE
				lRet:= .F.
		ENDCASE

	Else
		lRet := .F.
		Help( ' ', 1, 'TECA984', ,STR0018, 1, 0 )
	EndIf
EndIf

RestArea(aAreaSB5)
RestArea(aAreaSB1)
RestArea(aArea)

Return lRet

/*/{Protheus.doc} At984Grv
@description	Grava os dados manualmente para conseguir registrar um modelo 2 entre grids
@param			oModel, Objeto FwFormModel/MpFormModel, modelo de dados completo da rotina
@return			Logico, determina se conseguiu realizar a gravação dos dados ou não
@author			Inovação Gestão de Serviços
@since			28/10/2016
@version		P12
/*/
Static Function At984Grv( oModel )
Local lRet := .T.
Local nI := 1
Local aCampos := {}
Local nPos := 0
Local nTotCampos := 0
Local oMdlCab := oModel:GetModel("TWMMASTER")
Local oMdlRH  := oModel:GetModel("RHDETAIL")
Local oMdlMC  := oModel:GetModel("MCDETAIL")
Local oMdlMI  := oModel:GetModel("MIDETAIL")
Local oMdlLE  := oModel:GetModel("LEDETAIL")
Local oMdlUN  := Iif(lUniform,oModel:GetModel("UNIDETAIL"),Nil)
Local lNew := .F.
Local cItemRH := ""
Local lRecHum := .F.
Local cQryDel := ""

If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. ;
	oModel:GetOperation() == MODEL_OPERATION_UPDATE

	// grava o cabeçalho
	aCampos := oMdlCab:GetStruct():GetFields()
	nTotCampos := Len(aCampos)
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		lNew := .T.
	Else
		lNew := ! TWM->( DbSeek( xFilial("TWM")+oMdlCab:GetValue("TWM_CODIGO") ) )
	EndIf

	Begin Transaction

		Reclock("TWM", lNew )
			For nPos := 1 To nTotCampos
				TWM->( FieldPut( FieldPos( aCampos[nPos,MODEL_FIELD_IDFIELD] ), oMdlCab:GetValue(aCampos[nPos,MODEL_FIELD_IDFIELD]) ) )
			Next nPos
			TWM->TWM_FILIAL := xFilial("TWM")
		TWM->(MsUnlock())
		lOrcPrc := oMdlCab:GetValue("TWM_PRECIF")	//	Na Alteração usa a Precificação Original

		// grava os produtos de recursos humanos
		aCampos := oMdlRH:GetStruct():GetFields()
		nTotCampos := Len(aCampos)
		For nI := 1 To oMdlRH:Length()
			oMdlRH:GoLine(nI)
			If !Empty( oMdlRH:GetValue("TWN_CODPRO") )
				If oMdlRH:IsDeleted()
					If !oMdlRH:IsInserted() .And. oModel:GetOperation() != MODEL_OPERATION_INSERT

						TWN->( DbGoTo( oMdlRH:GetDataId(nI) ) )
						Reclock("TWN",.F.)
						TWN->(DbDelete())
						TWN->(MsUnlock())

						oMdlMC:GoLine(1)
						oMdlMI:GoLine(1)

						//  grava os materiais de consumo vinculados ao recurso humano
						If !lOrcPrc .And. !Empty( oMdlMC:GetValue("TWN_CODPRO") )
							lRet := At984GrvMt(oMdlMC, "2", .T.)
						EndIf

						//  grava os materiais de implantação vinculados ao recurso humano
						If !lOrcPrc .And. !Empty( oMdlMI:GetValue("TWN_CODPRO") )
							lRet := At984GrvMt(oMdlMI, "3", .T.)
						EndIf

					EndIf
				Else
					oMdlMC:GoLine(1)
					oMdlMI:GoLine(1)
					If oMdlRH:IsInserted() .Or. oMdlRH:GetDataId(nI) == 0
						lNew := .T.
					Else
						TWN->( DbGoTo( oMdlRH:GetDataId(nI) ) )
						lNew := TWN->(Eof())
					EndIf

					Reclock("TWN", lNew )
						For nPos := 1 To nTotCampos
							TWN->( FieldPut( FieldPos( aCampos[nPos,MODEL_FIELD_IDFIELD] ), oMdlRH:GetValue(aCampos[nPos,MODEL_FIELD_IDFIELD]) ) )
						Next nPos
						TWN->TWN_FILIAL := xFilial("TWN")
						TWN->TWN_TPITEM := "1"
						TWN->TWN_CODTWM := TWM->TWM_CODIGO
					TWN->(MsUnlock())
					cItemRH := TWN->TWN_ITEM
					lRecHum := .T.

					//  grava os materiais de consumo vinculados ao recurso humano
					If !lOrcPrc .And. !Empty( oMdlMC:GetValue("TWN_CODPRO") )
						lRet := At984GrvMt(oMdlMC, "2", .F., cItemRH)
					EndIf

					//  grava os materiais de implantação vinculados ao recurso humano
					If !lOrcPrc .And. !Empty( oMdlMI:GetValue("TWN_CODPRO") )
						lRet := At984GrvMt(oMdlMI, "3", .F., cItemRH)
					EndIf

				EndIf
			EndIf
		Next nI

		If lOrcPrc .Or. ! lRecHum
			// chama a gravação dos materiais quando é orçamento com precificação
			// e não fica vinculado aos itens de Rh
			lRet := At984GrvMt( oMdlMC, "2" )
			lRet := At984GrvMt( oMdlMI, "3" )
		EndIf

		// grava os produtos de locação de equipamentos
		aCampos := oMdlLE:GetStruct():GetFields()
		nTotCampos := Len(aCampos)
		For nI := 1 To oMdlLE:Length()
			oMdlLE:GoLine(nI)
			If !Empty( oMdlLE:GetValue("TWN_CODPRO") )
				If oMdlLE:IsDeleted()
					If !oMdlLE:IsInserted()
						TWN->( DbGoTo( oMdlLE:GetDataId(nI) ) )
						Reclock("TWN",.F.)
						TWN->(DbDelete())
						TWN->(MsUnlock())
					EndIf

				Else
					oMdlMC:GoLine(1)
					oMdlMI:GoLine(1)
					If oMdlLE:IsInserted() .Or.  oMdlLE:GetDataId(nI) == 0
						lNew := .T.
					Else
						TWN->( DbGoTo( oMdlLE:GetDataId(nI) ) )
						lNew := TWN->(Eof())
					EndIf
					Reclock("TWN", lNew )
						For nPos := 1 To nTotCampos
							TWN->( FieldPut( FieldPos( aCampos[nPos,MODEL_FIELD_IDFIELD] ), oMdlLE:GetValue(aCampos[nPos,MODEL_FIELD_IDFIELD]) ) )
						Next nPos
						TWN->TWN_FILIAL := xFilial("TWN")
						TWN->TWN_TPITEM := "4"
						TWN->TWN_CODTWM := TWM->TWM_CODIGO
					TWN->(MsUnlock())
				EndIf
			EndIf
		Next nI

		If lUniform
			// grava o Conteúdo do Uniforme
			aCampos := oMdlUN:GetStruct():GetFields()
			nTotCampos := Len(aCampos)
			For nI := 1 To oMdlUN:Length()
				oMdlUN:GoLine(nI)
				If !Empty( oMdlUN:GetValue("TXK_CODPRO") )
					If oMdlUN:IsDeleted()
						If !oMdlUN:IsInserted()
							TXK->( DbGoTo( oMdlUN:GetDataId(nI) ) )
							Reclock("TXK",.F.)
							TXK->(DbDelete())
							TXK->(MsUnlock())
						EndIf
					Else
						If oMdlUN:IsInserted() .Or.  oMdlUN:GetDataId(nI) == 0
							lNew := .T.
						  ElseIf oMdlUN:IsUpdated() .And. oMdlUN:GetDataId(nI) > 0
                            TXK->( DbGoTo( oMdlUN:GetDataId(nI) ) )
                            lNew := .F.
                        Else
                            TXK->( DbGoTo( oMdlUN:GetDataId(nI) ) )
                            If TXK->TXK_FILIAL == xFilial("TXK") .And.;
                               TXK->TXK_CODTWM == TWM->TWM_CODIGO .And.;
                               TXK->TXK_CODPRO == oMdlUN:GetValue("TXK_CODPRO") .And.;
                               TXK->TXK_ITEM ==  oMdlUN:GetValue("TXK_ITEM")
                                lNew := .F.
                            EndIf    
                        EndIf
						Reclock("TXK", lNew )
							For nPos := 1 To nTotCampos
								TXK->( FieldPut( FieldPos( aCampos[nPos,MODEL_FIELD_IDFIELD] ), oMdlUN:GetValue(aCampos[nPos,MODEL_FIELD_IDFIELD]) ) )
							Next nPos
							TXK->TXK_FILIAL := xFilial("TXK")
							TXK->TXK_CODTWM := TWM->TWM_CODIGO
						TXK->(MsUnlock())
					EndIf
				EndIf
			Next nI
		EndIf 	

		If lRet
			ConfirmSX8()
		Else
			RollBackSX8()
		EndIf

		If !lRet
			DisarmTransaction()
		EndIf

	End Transaction
	lOrcPrc := SuperGetMv("MV_ORCPRC",, .F.)	//	Restaura a Precificação do Parâmetro

ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE

	// exclusão dos registros
	If TWM->( DbSeek( xFilial("TWM")+oMdlCab:GetValue("TWM_CODIGO") ) )

		cQryDel := GetNextAlias()

		BeginSQL Alias cQryDel

			SELECT TWN.R_E_C_N_O_ TWNRECNO
			FROM   %Table:TWN% TWN
			WHERE  TWN_FILIAL = %xFilial:TWN%
			AND    TWN_CODTWM = %Exp:TWM->TWM_CODIGO%
			AND    TWN.%NotDel%
		EndSQL

		Begin Transaction

			// percorre todos os registros da TWN que estão relacionados com o facilitador
			While (cQryDel)->(!EOF())

				TWN->( DbGoTo( (cQryDel)->TWNRECNO ) )

				Reclock("TWN", .F.)
					TWN->( DbDelete() )
				TWN->( MsUnlock() )

				(cQryDel)->(DbSkip())
			Enddo

			(cQryDel)->( DbCloseArea() )

			Reclock("TWM",.F.)
				TWM->( DbDelete() )
			TWM->( MsUnlock() )

		End Transaction
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At984GrvMt
@description	Grava os dados na tabela TWN dos itens que são materiais para o orçamento
@author			Inovação Gestão de Serviços
@since			28/10/2016
@version		P12
@param			oModel, Objeto FwFormGridModel, modelo de dados com a lista de materiais a ser gravada
@param			cTipo, Caracter, Tipo "2" ou "3" indicando se é material de consumo ou implantação respectivamente
@param			lExclui, Lógico, Determina se todos os registros devem ser excluídos ou se deverá avaliar linha a linha do grid
@param 			cItemRh, Caracter, Determina se a lista de materiais está vinculada ao RH ou não
@return			Logico, determina se conseguiu gravar os dados ou não
//------------------------------------------------------------------------------
/*/
Static Function At984GrvMt( oMdlGridMat, cTipo, lExclui, cItemRh )
Local lRet := .T.
Local nX := 1
Local aCampos := {}
Local nTotCampos := 0
Local lNew := .F.
Local nPos := 0

Default lExclui := .F.
Default cItemRh := ""

If lExclui
	For nX := 1 To oMdlGridMat:Length()
	oMdlGridMat:GoLine(nX)
		If !Empty( oMdlGridMat:GetValue("TWN_CODPRO") )
			If oMdlGridMat:IsDeleted()
				TWN->( DbGoTo( oMdlGridMat:GetDataId(nX) ) )
				Reclock("TWN",.F.)
				TWN->(DbDelete())
				TWN->(MsUnlock())
			EndIf		
		EndIf
	Next nX

Else
	// grava os produtos de locação de equipamentos
	aCampos := oMdlGridMat:GetStruct():GetFields()
	nTotCampos := Len(aCampos)

	For nX := 1 To oMdlGridMat:Length()
		oMdlGridMat:GoLine(nX)
		If !Empty( oMdlGridMat:GetValue("TWN_CODPRO") )
			If oMdlGridMat:IsDeleted()
				If !oMdlGridMat:IsInserted()
					TWN->( DbGoTo( oMdlGridMat:GetDataId(nX) ) )
					Reclock("TWN",.F.)
					TWN->(DbDelete())
					TWN->(MsUnlock())
				EndIf

			Else
				If oMdlGridMat:IsInserted() .Or. oMdlGridMat:GetDataId(nX) == 0
					lNew := .T.
				Else
					TWN->( DbGoTo( oMdlGridMat:GetDataId(nX) ) )
					lNew := TWN->(Eof())
				EndIf

				Reclock("TWN", lNew )
					For nPos := 1 To nTotCampos
						TWN->( FieldPut( FieldPos( aCampos[nPos,MODEL_FIELD_IDFIELD] ), oMdlGridMat:GetValue(aCampos[nPos,MODEL_FIELD_IDFIELD]) ) )
					Next nPos
					TWN->TWN_FILIAL := xFilial("TWN")
					TWN->TWN_TPITEM := cTipo
					TWN->TWN_CODTWM := TWM->TWM_CODIGO
					TWN->TWN_ITEMRH := cItemRh
				TWN->(MsUnlock())
			EndIf
		EndIf
	Next nX
EndIf

Return lRet

/*/{Protheus.doc} At984IsFac
@description 	Avalia se determinado item pertence a um facilitador
@author 		josimar.assuncao
@return 		Lógico, determina se o item pertence ao facilitador posicionado
@since			23.03.2017
@version		P12
/*/
Function At984IsFac(cIdMdlGrd, cCodTWM, cCodRHPai)
Local lRet 			:= .F.
Local lQry 			:= .F.
Local cQryTmp 		:= ""
Local cItemEval 	:= ""
Local cTpItem 		:= ""
Local aArea 		:= GetArea()
Local aAreaTWM 		:= TWM->(GetArea())
Local aAreaTWN 		:= TWN->(GetArea())

If cIdMdlGrd == "RHDETAIL" .And. TWN->TWN_TPITEM $ "1,2,3,4"
	lQry := .T.

	cCodRHPai := Space( Len( TWN->TWN_ITEMRH ) )
	cItemEval := TWN->TWN_ITEM
	cTpItem := TWN->TWN_TPITEM
EndIf

If lQry
	cQryTmp := GetNextAlias()
	BeginSql Alias cQryTmp
		SELECT TWN_ITEM
		FROM %Table:TWN% TWN
			INNER JOIN %Table:TWM% TWM ON TWM_FILIAL = %xFilial:TWM%
									AND TWM_CODIGO = TWN_CODTWM
									AND TWM.%NotDel%
		WHERE TWN_FILIAL = %xFilial:TWN%
			AND TWN_CODTWM = %Exp:cCodTWM%
			AND TWN_ITEM = %Exp:cItemEval%
			AND TWN_TPITEM = %Exp:cTpItem%
			AND TWN_ITEMRH = %Exp:cCodRHPai%
			AND TWN.%NotDel%
	EndSQL
	lRet := (cQryTmp)->(!EOF())
	(cQryTmp)->(DbCloseArea())
EndIf

RestArea(aAreaTWN)
RestArea(aAreaTWM)
RestArea(aArea)

Return lRet

/*/{Protheus.doc} At984Activ
@description 	Bloco para atualização do modelo de dados após a ativação dele
@author 		josimar.assuncao
@since			24.03.2017
@version		P12
/*/
Static Function At984Activ( oModel )
Local nI 			:= 1
Local nLinhas 		:= 1
Local oMdlGrd 		:= Nil
Local aGrds 		:= { "RHDETAIL", "MIDETAIL", "MCDETAIL", "LEDETAIL" }
Local cAux 			:= ""
Local cTempContent 	:= ""

If oModel:GetOperation() <> MODEL_OPERATION_DELETE
	// passa pelos grids para verificar se existe descrição de produto que não foi carregada
	For nI := 1 To Len( aGrds )
		oMdlGrd := oModel:GetModel( aGrds[nI] )
		For nLinhas := 1 To oMdlGrd:Length()
			oMdlGrd:GoLine( nLinhas )
			cAux := oMdlGrd:GetValue("TWN_CODPRO")
			If Empty(oMdlGrd:GetValue("TWN_DESCRI")) .And. !Empty(cAux)
				cTempContent := Posicione("SB1", 1, xFilial("SB1")+cAux, "B1_DESC")
				oMdlGrd:LoadValue( "TWN_DESCRI", cTempContent )
			EndIf
		Next nLinhas
		oMdlGrd:GoLine(1)
	Next nI
EndIf

Return

/*/{Protheus.doc} LoadEnch
@description 	Carga dos dados do cabeçalho pela função padrão de load
@author 		josimar.assuncao
@since			24.07.2017
@version		P12
/*/
Static Function LoadEnch(x,y)
Local aDados :=  FormLoadField(x,y)
Return aDados

/*/{Protheus.doc} At984Uni
@description 	Verifica se as tabelas de Uniforme estão criadas
@author 		Luiz Gabriel
@since			12.06.2020
@version		P12
/*/
Function At984Uni()
Local lRet	:= .F.

lRet := TableInDic("TXC") .And. TableInDic("TXD") .And. ;
		TableInDic("TXE") .And. TableInDic("TXF") .And. ;
		TableInDic("TXK") .And. TableInDic("TXL")

Return lRet

/*/{Protheus.doc} Tec984Val
@description 	Query conforme tipo de material
@param cCodFac  Código do facilitador
@param cTipo 	Tipo do Item (RH,MI,MC.LE)
@return aRet    Array com os campos do facilitador 
@author 		matheus.goncalves
@since			20/01/2021
@version		1.0
/*/
Function Tec984Val(cCodFac, cTipo)
Local aRet := {}
Local cQry := ""
Local cAliasTWN := getNextAlias()
Local cFiltro := ""

If cTipo == 'RH'
	cFiltro := "1"
ElseIf cTipo == 'MC'
	cFiltro := "2"
ElseIf cTipo == 'MI'
	cFiltro := "3"
ElseIf cTipo == 'LE'
	cFiltro := "4"
EndIf

cQry := "SELECT TWN_FILIAL,TWN_ITEM,TWN_CODPRO,TWN_QUANTS,TWN_VLUNIT, "
cQry += " TWN_TPITEM,TWN_CODTWM,TWN_ITEMRH,TWN_FUNCAO,TWN_TURNO,TWN_CARGO,TWN_TES,TWN_TESPED "
cQry += "FROM "+retSqlName("TWN")
cQry += "WHERE TWN_FILIAL = '"+xFilial("TWN")+"' AND D_E_L_E_T_ = ' ' AND TWN_CODTWM = '"+cCodFac+"' "
cQry += " AND TWN_TPITEM = '"+cFiltro+"' "

cQry := ChangeQuery(cQry)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasTWN, .F., .T.)

While (cAliasTWN)->(!EOF())
	aAdd(aRet, {(cAliasTWN)->TWN_FILIAL,;
				(cAliasTWN)->TWN_ITEM,;
				(cAliasTWN)->TWN_CODPRO,;
				(cAliasTWN)->TWN_QUANTS,;
				(cAliasTWN)->TWN_VLUNIT,;
				(cAliasTWN)->TWN_TPITEM,;
				(cAliasTWN)->TWN_CODTWM,;
				(cAliasTWN)->TWN_ITEMRH,;
				(cAliasTWN)->TWN_FUNCAO,;
				(cAliasTWN)->TWN_TURNO,;
				(cAliasTWN)->TWN_CARGO,;
				(cAliasTWN)->TWN_TES,;
				(cAliasTWN)->TWN_TESPED})
	(cAliasTWN)->(dbSkip())
End

(cAliasTWN)->(dbCloseArea())

Return aRet
