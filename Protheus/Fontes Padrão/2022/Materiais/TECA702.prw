#Include "TECA702.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "RPTDEF.CH"


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA702

Cadastro de Atividades - TX3, TX4
@author Mateus Boiani
@since 13/11/2018
@version 12.1.23

/*/
//----------------------------------------------------------------------------------------------------------------------
Function TECA702()
Local oBrw := FwMBrowse():New()
Private aRotina	:= MenuDef() 
oBrw:SetAlias( 'TX3' )
oBrw:SetDescription( OEmToAnsi( STR0001) ) //STR0001 //'Cadastro de Atividades'
oBrw:Activate()

Return


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef

Menu do cadastro de Atividades
@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
@param
@return aMenu  - Array de Menu
/*/
//----------------------------------------------------------------------------------------------------------------------
Static Function Menudef()

Local aMenu := {}

ADD OPTION aMenu Title STR0002 Action 'VIEWDEF.TECA702' OPERATION 2 ACCESS 0 	//"Visualizar" //'Visualizar'
ADD OPTION aMenu Title STR0003 Action 'VIEWDEF.TECA702' OPERATION 3 ACCESS 0 	//"Incluir" //'Incluir'
ADD OPTION aMenu Title STR0004 Action 'VIEWDEF.TECA702' OPERATION 4 ACCESS 0 	//"Alterar" //'Alterar'
ADD OPTION aMenu Title STR0005 Action 'VIEWDEF.TECA702' OPERATION 5 ACCESS 0 	//"Excluir" //'Excluir'
ADD OPTION aMenu Title STR0006 Action 'VIEWDEF.TECA702' OPERATION 9 ACCESS 0 	//"Copiar" //'Copiar'
//ADD OPTION aMenu Title 'QrCode' Action 'Tec702QRCD(TX3->TX3_FILIAL,TX3->TX3_CODIGO, TX3->TX3_DESCR)' OPERATION 9 ACCESS 0 	//"QrCode"

Return aMenu

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo TECA702 - Cadastro de Atividades
@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
@param
@return oModel  - Objeto Model
/*/
//----------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStrTX3 := FWFormStruct(1,'TX3')
Local oStrTX4 := FWFormStruct(1,'TX4')
Local bPosValidacao	:= { |oMdl| Tc702Pos( oMdl ) } //Bloco de PosValid do Modelo

oStrTX4:SetProperty( "TX4_CODPAI", MODEL_FIELD_OBRIGAT, .F. )

oModel := MPFormModel():New('TECA702',  ,bPosValidacao )
oModel:SetDescription( STR0007 ) // STR0007 //'Roteiro de Tarefas'
oModel:addFields('TX3MASTER',,oStrTX3)
oModel:SetPrimaryKey({"TX3_FILIAL","TX3_CODIGO"})

oModel:addGrid('TX4DETAIL','TX3MASTER',oStrTX4, {|oModel, nLine,cAction| Tc702TX4Pre(cAction,nLine, oModel)}, { |oModel, nLine| Tc702TX4Pos(oModel, nLine)})
oModel:SetRelation('TX4DETAIL', { { 'TX4_FILIAL', 'xFilial("TX4")' }, { 'TX4_CODPAI', 'TX3_CODIGO' } }, TX4->(IndexKey(1)) )

oModel:getModel('TX3MASTER'):SetDescription(STR0008)	// Roteiro de Tarefas //"Cabeçalho de Tarefas"
oModel:getModel('TX4DETAIL'):SetDescription(STR0009)		// Atividades //"Itens de Tarefas"

Return oModel

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

ViewDef TECA702 - Cadastro de Atividades
@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
@param
@return oView  - Objeto View
/*/
//----------------------------------------------------------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrTX3   := FWFormStruct( 2, "TX3" )  
Local oStrTX4   := FWFormStruct( 2, "TX4" )

oStrTX4:SetProperty( "TX4_ORDEM", MVC_VIEW_ORDEM, "01" )

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_TX3', oStrTX3, 'TX3MASTER' )
oView:AddGrid('VIEW_TX4'  , oStrTX4, 'TX4DETAIL')

oStrTX4:RemoveField('TX4_CODPAI')

oView:CreateHorizontalBox( 'TOP'   , 30 )
oView:CreateHorizontalBox( 'BOTTOM', 70 )

oView:SetOwnerView( "VIEW_TX3", "TOP" )
oView:SetOwnerView( "VIEW_TX4", "BOTTOM" )

//oView:AddUserButton("Imprimir Atividades","",{|oModel| At702Imprt()},,,) // "Imprimir Atividades"

Return oView

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At702Imprt

Impressão de Atividades
@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
@param
@return .T.
/*/
//----------------------------------------------------------------------------------------------------------------------
Function At702Imprt

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tec702QRCD

Impressão de QRCode de Atividades

@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
@param cFilialTX3 - Filial da Tabela TX3
@param cCodigo - Codigo da Tarefa
@param cDescr - Descrição da Tarefa
@return

/*/
//----------------------------------------------------------------------------------------------------------------------
Function Tec702QRCD(cFilialTX3,cCodigo,cDescr)
Local oPrinter 
Local cFileName := DTOS(DATE())+"-"+STRTRAN(TIME(),":")

Default cFilialTX3 := xFilial("TX3")
Default cCodigo := ""
Default cDescr := ""

oPrinter := FWMSPrinter():New(cFileName,6,.F.,,.T.,,,,,.F.)
oPrinter:setDevice(IMP_PDF)
oPrinter:cPathPDF := "C:\teste\"
oPrinter:StartPage()
oPrinter:Say(40,0,cDescr)
oPrinter:QRCode(100,150,cFilialTX3 + "|x|" + cCodigo, 100)       
oPrinter:EndPage()
oPrinter:SetViewPDF(.T.)
oPrinter:Print()

FreeObj(oPrinter)
oPrinter := Nil

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tc702Pos

Validação do Modelo

@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
@param 
@return lRet - Formulário válido

/*/
//------------------------------------------------------------------------------------------------------
Function Tc702Pos(oModel)
Local lRet 			:= .T.

If oModel:GetOperation() != MODEL_OPERATION_DELETE .AND. oModel:GetValue( "TX3MASTER", "TX3_TOTAL"  ) <= 0
		
	Help( ,, STR0010,, STR0011, 1, 0 ) //STR0010##"Já existe a configuração de planilha" //"Atenção" //"Tempo Total da Atividade deve ser informado"
	lRet := .F. 
			
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Tc702TX4Pre
Rotina para tratamento no pre valid do Modelo TX4

@param cAction - Acção
@param nLine - Linha
@param oMdlTX4 - Model Grid
@return .t.

@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function Tc702TX4Pre(cAction,nLine, oMdlTX4)
Local lRet		:= .T.
Local oModel  := oMdlTX4:GetModel()
Local oMdlTX3		:= oModel:GetModel("TX3MASTER")//Modelo Cabeçalho

If cAction == 'UNDELETE' .Or. cAction == 'DELETE'
	Tc702Grd(oMdlTX4, oMdlTX3, cAction, nLine, .F.)
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Tc702TX4Pos
Rotina para tratamento no Pos valid do Modelo TX4

@param oMdlTX4 - Model Grid
@param nLine - Linha
@return lRet - Linha valida

@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function Tc702TX4Pos(oMdlTX4, nLine)
Local lRet		:= .T.
Local nY := 0
Local cCodCar := ""
Local nTotal := 0
Local oModel  := oMdlTX4:GetModel()
Local oMdlTX3		:= oModel:GetModel("TX3MASTER")//Modelo Cabeçalho

lRet := Tc702Grd(oMdlTX4, oMdlTX3, "", nLine, .T.)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Tc702Grd
Rotina para realizar a soma do tempo das tarefas e valida se não existe tarefa duplicada

@param oMdlTX4 - Itens da Atividade (lista de tarefas)
@param oMdlTX3 - Cabeçalho da Atividade (header)
@param cAction - Ação
@param nLinha - Linha a ser validade
@param lVld - Validar tarefa duplicada ?
@return lRet - Linha valida

@author Mateus Boiani
@since 13/11/2018
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function Tc702Grd(oMdlTX4, oMdlTX3, cAction, nLine, lVld)

Local nY 			:= 0 //Contador de Linhas do Model
Local aSaveRows 	:= {}
Local nTotal 		:= 0
Local cCodTar		:= ""
Local lRet			:= .T.

aSaveRows := FwSaveRows()

If lVld
	cCodTar := oMdlTX4:GetValue('TX4_CODTAR') 
EndIf

For nY := 1 To oMdlTX4:Length()
	
	oMdlTX4:GoLine(nY)
	
	If  cAction ==  'UNDELETE' .AND.  nY == nLine
		nTotal += oMdlTX4:GetValue('TX4_TEMPO')  
	ElseIf !(cAction ==  'DELETE' .AND.  nY == nLine)
			If !oMdlTX4:IsDeleted()
				nTotal += oMdlTX4:GetValue('TX4_TEMPO') 
				If lVld .AND. nY <> nLine .AND. cCodTar ==  oMdlTX4:GetValue('TX4_CODTAR') 
					Help( ,, STR0010,, STR0012, 1, 0 ) //"Não pode haver tarefa duplicada" //"Atenção"
					lRet := .F.
					Exit
				EndIf
			EndIf
	EndIf
Next nY

If lRet .AND.  nTotal > 0
	oMdlTX3:SetValue("TX3_TOTAL",nTotal)
EndIf

FwRestRows(aSaveRows)

Return lRet
