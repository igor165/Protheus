#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA001.CH"
#INCLUDE "FWCOMMAND.CH"

Static cSelecFil := Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA001
@description	Produtos de Locação Semelhantes
@sample	 	TECA001()
@param		Nenhum
@return		NIL
@author		Filipe Gonçalves (filipe.goncalves)
@since		06/07/2016
@version	P12   
/*/
//------------------------------------------------------------------------------
Function TECA001()
Local oMBrowse	:= FWmBrowse():New()
Local aRet		:= FWLoadSM0()

If Len(aRet) == 1
	Help("",1, 'AT001FIL',,STR0008,4,1)//O Grupo de Empresas possui somente uma filial, por este motivo não há necessidade de preencher este cadastro.
ElseIf At001VldAct()
	oMBrowse:SetAlias("TWS")				
	oMBrowse:SetDescription(STR0001) // "Produtos de Locação Semelhantes"
	oMBrowse:Activate()
Else
	Help("",1,'AT001NO',,STR0009,4,1)//O cadastro de produtos está completamente compartilhado, não há necessidade de preencher este cadastro.
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@description	Define o menu funcional.
@sample	 		MenuDef()
@param			Nenhum
@return			ExpA: Opções da Rotina.
@author			Filipe Goncalves
@since			06/07/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local	aRotina	:= {}

ADD OPTION aRotina TITLE STR0003 ACTION "PesqBrw"         OPERATION 1                      ACCESS 0	// "Pesquisar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TECA001" OPERATION MODEL_OPERATION_VIEW   ACCESS 0	// "Visualizar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TECA001" OPERATION MODEL_OPERATION_INSERT ACCESS 0	// "Incluir"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TECA001" OPERATION MODEL_OPERATION_UPDATE ACCESS 0	// "Alterar"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.TECA001" OPERATION MODEL_OPERATION_DELETE ACCESS 0	// "Excluir"

Return(aRotina)


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@description	Definição do Model
@sample	 		ModelDef()
@param			Nenhum
@return			ExpO: Objeto FwFormModel
@author			Filipe Gonçalves
@since			06/07/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel		:= Nil
Local oStrCAB	:= FWFormStruct(1, "TWS" )	// Cabeçalho 
Local oStrGRI 	:= FWFormStruct(1, "TWS" )	

// remove os campos do cabeçalho
oStrCAB:RemoveField("TWS_FILIAL")
oStrCAB:RemoveField("TWS_FILPRD")
oStrCAB:RemoveField("TWS_PRDCOD")
oStrCAB:RemoveField("TWS_PRDDES")

// remove a obrigatoriedade do código e descrição do grid para receber o contéudo conforme o pai
oStrGRI:SetProperty("TWS_CODIGO",MODEL_FIELD_OBRIGAT, .F.)
oStrGRI:SetProperty("TWS_DESCRI",MODEL_FIELD_OBRIGAT, .F.)

// Cria o objeto do modelo de dados principal
oModel := MPFormModel():New("TECA001", /*bPreValid*/, {|oModel| At001TudoOk( oModel )}/*bPósValid*/, /*bCommit*/, /*bCancel*/) 

// Cria a antiga Enchoice do grupo de comunicação
oModel:AddFields("CABMASTER", /*cOwner*/ , oStrCAB) 

// Cria a grid das etapas do grupo de comunicação
oModel:AddGrid("GRIDDETAIL","CABMASTER",oStrGRI,/*bPreValidacao*/, {|oMdl,nLin| At001VlPrd(oMdl,nLin)},,, /*bCarga*/) 

//Chave primária
oModel:SetPrimaryKey({'TWS_FILIAL','TWS_CODIGO','TWS_FILPRD','TWS_PRDCOD'})

//Criação dos relacionamentos
oModel:SetRelation("GRIDDETAIL", {{"TWS_FILIAL","xFilial('TWS')"},{"TWS_CODIGO","TWS_CODIGO"},{"TWS_DESCRI","TWS_DESCRI"}}, TWS->(IndexKey(1)))

//Campos que não serão repetidos 
oModel:GetModel('GRIDDETAIL'):SetUniqueLine({'TWS_FILPRD'})

//Definição das descrições
oModel:GetModel("GRIDDETAIL"):SetDescription(STR0002)	//'Produtos Semelhantes'

// Verifica se há necessidade
oModel:SetVldActivate({|oModel| At001VldAct( oModel ) })

Return(oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description	Definição da View
@sample	 		ViewDef()
@param			Nenhum
@return			ExpO	Objeto FwFormView 
@author			Filipe Gonçalves 
@since			06/07/2016       
@version		P12   
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil			// Interface de visualização construída	
Local oModel	:= ModelDef()	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStrCAB	:= FWFormStruct(2, "TWS" )	// Cria a estrutura a ser usada na View
Local oStrGRI 	:= FWFormStruct(2, "TWS" )	

// remove os campos para serem exibidos na interface
oStrCAB:RemoveField("TWS_FILIAL")
oStrCAB:RemoveField("TWS_FILPRD")
oStrCAB:RemoveField("TWS_PRDCOD")
oStrCAB:RemoveField("TWS_PRDDES")

oStrGRI:RemoveField("TWS_CODIGO")
oStrGRI:RemoveField("TWS_DESCRI")

// Cria o objeto de View
oView	:= FWFormView():New()					

// Define qual modelo de dados será utilizado
oView:SetModel(oModel)							

oView:AddField("VIEW_CAB", oStrCAB, "CABMASTER") // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddGrid("VIEW_GRID", oStrGRI, "GRIDDETAIL") // Cria as grids para o modelo 											

//Define divisão da tela para o cabeçalho e itens
oView:CreateHorizontalBox("CABEC", 20) 
oView:CreateHorizontalBox("GRID", 80)

// Relaciona o identificador (ID) da View com o "box" para sua exibição
oView:SetOwnerView("VIEW_CAB", "CABEC")
oView:SetOwnerView("VIEW_GRID", "GRID") 										
				
// Identificação (Nomeação) da VIEW
oView:SetDescription(STR0001) //"Produtos de Locação Semelhantes"

Return(oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} TC001CPROD()
@description	Valid do campo TWS_PRDCOD
@param			Nenhum
@return			lRet 	Lógico (T/F)
@author 		filipe.goncalves
@since 			23/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function TC001CPROD(oModTWS,cCampo,xValor,nLine)
Local aArea			:= GetArea() 
Local aSaveLines	:= FWSaveRows()
Local oModel		:= oModTWS:GetModel()
Local lRet 			:= .T.

TWS->(dbSetOrder(2)) //TWS_FILIAL+TWS_FILPRD+TWS_PRDCOD
If TWS->(DbSeek(xFilial("TWS")+oModel:GetValue("GRIDDETAIL","TWS_FILPRD")+xValor))
	lRet := .F.
	Help("",1,'TC805APROD',,STR0010,4,1,,,,,,{STR0011})	//"Este produto já foi associado a outro cadastro de Produtos Semelhantes." ## "Escolha outro produto."
EndIf
FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} TC001FIPRD()
@description	Valid da filial informada
@param			Nenhum
@return			lRet 	Lógico (T/F)
@author 		filipe.goncalves
@since 			23/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function TC001FIPRD(xValor)
Local aArea			:= GetArea() 
Local aSaveLines	:= FWSaveRows()
Local lRet 			:= .F.
Local nTamFilSB1 	:= AtTamFilTab( "SB1" )

DbSelectArea("SM0")
 If SM0->(DbSeek(cEmpAnt))
	While SM0->(!Eof()) .AND. SM0->M0_CODIGO == cEmpAnt
        If SubStr(SM0->M0_CODFIL, 1, nTamFilSB1) == SubStr(xValor, 1, nTamFilSB1)
        	lRet := .T.
        EndIf
        SM0->(DbSkip())
    End 
	
	If !lRet
		Help("",1,'TC001FIPRD',,STR0012,4,1,,,,,,{STR0013})	//"Filial não encontrada." ## "Informe uma filial válida do sistema"
	EndIf
EndIf
FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet 

/*/{Protheus.doc} At001VlPrd()
@description	Valida se o produto já foi associado a outro agrupamento de produtos semelhantes
@param			oMdlGrid, objeto [Modelo do grid], objeto da linha a ser validada
@param			nLinha, numérico, número da linha posicionada para validação
@return			lRet 	Lógico (T/F), permite ou não a troca de linha
@author 		Inovação Gestão de Serviços
@since 			27/07/2016
@version		P12
/*/
Static Function At001VlPrd( oMdlGrid, nLinha )
Local lRet := .T.
Local aArea := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local aAreaTWS := TWS->(GetArea())
Local cTmpQry := ""

DbSelectArea("SB1")
SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
// valida se o produto de fato existe para a filial conforme a linha inserida
If lRet .And. !SB1->(DbSeek(oMdlGrid:GetValue("TWS_FILPRD")+oMdlGrid:GetValue("TWS_PRDCOD")))
	lRet := .F.
	Help("",1,'ATVLDLIN1',,STR0014,4,1,,,,,,{STR0015})	//"Código do produto não encontrado na filial." ## "Informe um código de produto válido."
EndIf

If lRet
// valida a inexistência do produto em outro cadastro
	cTmpQry := GetNextAlias()
	BeginSql Alias cTmpQry
		
		SELECT 1 
		FROM %Table:TWS% TWS
		WHERE TWS.%NotDel% 
			AND TWS_FILIAL = %xFilial:TWS%
			AND TWS_FILPRD = %exp:(oMdlGrid:GetValue("TWS_FILPRD"))%
			AND TWS_PRDCOD = %exp:(oMdlGrid:GetValue("TWS_PRDCOD"))%
			AND TWS_CODIGO <> %exp:(oMdlGrid:GetValue("TWS_CODIGO"))%
	EndSql
	
	If (cTmpQry)->(!EOF())
		lRet := .F.
		Help("",1,'ATVLDLIN2',,STR0016,4,1,;	//"O produto já está associado a outro cadastro de Produtos Semelhantes"
			,,,,,{STR0017})	//"Informe um código de produto que ainda não esteja vinculado."
	EndIf
	
	(cTmpQry)->(DbCloseArea())
EndIf

RestArea(aAreaTWS)
RestArea(aAreaSB1)
RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At001F3Fil() / At001FilRet()
@description	Consulta específica para retornar as filiais conforme o compartilhamento do cadastro do SB1
@author 		Inovação Gestão de Serviços
@since 			17/08/2016
@version		P12
@return			Lógico, indica se foi selecionado ou não algum item da lista.
/*/
//------------------------------------------------------------------------------
Function At001F3Fil()

Local oDlgCmp := Nil
Local cTitulo := STR0022	//"Filiais"
Local aInfSM0 := FwLoadSM0(.F.,.T.)
Local aDados  := {}
Local oListBox := Nil
Local oMiddle := Nil
Local nTamFilSB1 := AtTamFilTab("SB1")
Local lSelected := .F.
Local nI := 0
Local bConfirm := { || cSelecFil := aDados[oListBox:nAT,1], lSelected := .T., oDlgCmp:End() }

cSelecFil := ""

For nI := 1 To Len(aInfSM0)
	If aInfSM0[nI,SM0_GRPEMP] == cEmpAnt 
		aAdd( aDados, { SubStr( aInfSM0[nI,SM0_CODFIL], 1, nTamFilSB1 ), aInfSM0[nI,SM0_NOMRED] } )
	EndIf
Next nI

//	Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela 
Define MsDialog oDlgCmp TITLE cTitulo FROM 000, 000 To 350, 500 Pixel

	// Cria o panel o browse dos itens dos materiais
	@ 000, 000 MsPanel oMiddle Of oDlgCmp Size 000, 100 // Coordenada para o panel
	oMiddle:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)	
		
	// Criação do grid para o panel	
	oListBox := TWBrowse():New(000,000,000,000,,{	STR0020,;	//"Código"
														STR0021},,oMiddle,,,,,bConfirm,,,,,,,.F.,,.T.,,.F.,,,)	//"Descrição"
												       	  
	oListBox:SetArray(aDados) // Atrela os dados do grid com a matriz

	oListBox:bLine := { ||{aDados[oListBox:nAT][1],;
							  aDados[oListBox:nAT][2]}} // Indica as linhas do grid	

	oListBox:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse
	
	// Cria o panel para o botao OK	
	@ 000, 000 MsPanel oBottom Of oDlgCmp Size 000, 012 // Corrdenada para o panel dos botoes (size)
	oBottom:Align := CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
	
	// Botao de acao OK	
	@ 000, 000 Button oOk Prompt "Ok"  Of oBottom Size 030, 000 Pixel //Ok
	oOk:bAction := bConfirm
	oOk:Align   := CONTROL_ALIGN_RIGHT	
		
// Ativa a tela exibindo conforme a coordenada
Activate MsDialog oDlgCmp Centered

Return lSelected

//------------------------------------------------------------------------------
/*/ 
	função de retorno da consulta específica
/*/
//------------------------------------------------------------------------------
Function At001FilRet()
Return cSelecFil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At001VldAct()
@description	Valida no bloco "VldActivate" e antes da construção do browse se existe algum nível de exclusividade na tabela de produtos.
@author 		Inovação Gestão de Serviços
@since 			17/08/2016
@version		P12
@return			Lógico, indica se foi selecionado ou não algum item da lista.
/*/
//------------------------------------------------------------------------------
Function At001VldAct()

Local lPermite := .T.
Local nTamFilSB1 := AtTamFilTab( "SB1" )

lPermite := ( nTamFilSB1 <> 0 )

Return lPermite

/*/{Protheus.doc} At001TudoOk
@description	Verifica o dados preenchidos no grid
@author 		Inovação Gestão de Serviços
@since 			11/10/2016
@version		P12
@return			Objeto FwFormModel/MpFormModel, objeto principal do cadastro
/*/
Function At001TudoOk( oModel )
Local lRet 		:= .T.
Local cIsIdUni 	:= ""
Local oMdlGrid 	:= oModel:GetModel("GRIDDETAIL")
Local nI 		:= 1

DbSelectArea("SB5")
SB5->( DbSetOrder( 1 ) )  //B5_FILIAL+B5_COD

oMdlGrid:GoLine( 1 )
SB5->( DbSeek( oMdlGrid:GetValue("TWS_FILPRD")+oMdlGrid:GetValue("TWS_PRDCOD") ) )

cIsIdUni := SB5->B5_ISIDUNI

For nI := 2 To oMdlGrid:Length()
	oMdlGrid:GoLine( nI )
	
	If !oMdlGrid:IsDeleted()
		If SB5->( DbSeek( oMdlGrid:GetValue("TWS_FILPRD")+oMdlGrid:GetValue("TWS_PRDCOD") ) ) .And. ;
				SB5->B5_ISIDUNI <> cIsIdUni
			
			lRet := .F.
			Exit
		EndIf
	EndIf
	
Next nI

If !lRet
	Help("",1,'AT001TUDOOK',,i18N(STR0018,;	//"O item da filial #1 e código de produto #2 possui configuração de ID Único diferente dos demais."
								{oMdlGrid:GetValue("TWS_FILPRD"),oMdlGrid:GetValue("TWS_PRDCOD")}),4,1,;
			,,,,,{STR0019})	//"Altere o cadastro de complemento de produtos para que todos os itens tenham a mesma configuração."
EndIf

Return lRet