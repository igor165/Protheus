#INCLUDE "PROTHEUS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "CTBA112.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBA112  ³ Autor ³ Wilson Possani        ³ Data ³ 18-04-2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Grupo de Lotes                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba112()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ P120                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBA112()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("CWP") 
	oBrowse:SetDescription(STR0005) // "Grupo de Lote"
	oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MENUDEF
Menu de opções definido na Browse

@author Wilson.Possani
@since 18/04/2014
@version P120
@Return Retorna as Opções de Menu para Manutenção da Base de Dados no Formulario
/*/

Static Function Menudef()
Local aRotina:= {}

ADD OPTION aRotina TITLE STR0006 		ACTION 'VIEWDEF.CTBA112'	 OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE STR0007		ACTION 'VIEWDEF.CTBA112'	 OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE STR0001		ACTION 'CTB112AE("CWP",,4)' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE STR0003		ACTION 'CTB112AE("CWP",,5)' OPERATION 5 ACCESS 0

Return aRotina


/*/{Protheus.doc} MODELDEF
Model da Estrutura

@author Wilson.Possani
@since 18/04/2014
@version P120
@Return Retorna a estrutura do Model
/*/

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCWP := FWFormStruct( 1, 'CWP', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruCWR := FWFormStruct( 1, 'CWR', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel


// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'CTBA112M', /*bPreValidacao*/, {|oModel| CTB112VldMod(oModel)}, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CWPGRUPO', /*cOwner*/, oStruCWP )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'CWRITENS', 'CWPGRUPO', oStruCWR,/*bLinePre*/,{|oModel| ValLote(oModel)},,,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetPrimaryKey(  { "CWP_FILIAL"+"CWP_GRUPO"+"CWP_LOTEIN" })

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CWRITENS', { { 'CWR_FILIAL', 'xFilial( "CWR" )' }, { 'CWR_CODIGO', 'CWP_GRUPO' } }, CWR->( IndexKey( 1 ) ) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'CWRITENS' ):SetUniqueLine( { 'CWR_ITEM' } )


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0005 ) //"Grupo de Lotes"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CWPGRUPO' ):SetDescription( STR0005 ) //"Grupo de Lote"
oModel:GetModel( 'CWRITENS' ):SetDescription( STR0008 ) //"Itens de Lotes"

oStruCWP:SetProperty('CWP_GRUPO',MODEL_FIELD_WHEN,{|| INCLUI})
Return oModel



/*/{Protheus.doc} VIEWDEF

View da Estrutura

@author Wilson.Possani
@since 18/04/2014
@version P120
@Return Retorna a estrutura do Model
/*/

//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCWP := FWFormStruct( 2, 'CWP' )
Local oStruCWR := FWFormStruct( 2, 'CWR' )
Local oModel   := FWLoadModel( 'CTBA112' )
Local oView

//Remover da Tela o Campo Código
oStruCWR:RemoveField('CWR_CODIGO')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CWP',oStruCWP,'CWPGRUPO' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CWR', oStruCWR ,'CWRITENS' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GRUPO', 30 )
oView:CreateHorizontalBox( 'ITEM', 70 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CWP', 'GRUPO' )
oView:SetOwnerView( 'VIEW_CWR', 'ITEM' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_CWR', 'CWR_ITEM' )

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_CWP',STR0005) //"Grupo de Lotes"
oView:EnableTitleView('VIEW_CWR',STR0008) //"Itens de Lotes"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValLote(oModel)
Valida se Não está repetindo o Lote em algumas das Linhas da Grid

@author Wilson.Possani
@since 18/04/2014
@version P120
@Return Retorna a estrutura do Model
/*/
//-------------------------------------------------------------------
Static Function ValLote(oModel)
 
Local oModel	:= FwModelActive()
Local oAux		:= oModel:GetModel('CWRITENS')
Local lRet		:= .T.
Local nX		:= 0
Local nLine		:= oAux:GetLine()

cLotIn_a := oAux:GetValue("CWR_LOTEIN")
cLotFi_a := oAux:GetValue("CWR_LOTEFI")

If Val(cLotIn_a) > Val(cLotFi_a)
	Help(" ",1,"EXISLOTE",,STR0009,1,0)  //"Lote Final não pode ser Menor que o Inicial !"
	lRet:= .F.
Else
	For nX := 1 To oaux:length()
		If nX <> nLine // Não compara com a linha que está posicinado.
			oAux:GoLine( nX )
			If !oAux:IsDeleted()
				//Verifica na Grid se a linha digitada contem nas outras linhas
				If Val(cLotIn_a) >= Val(oAux:GetValue('CWR_LOTEIN')) .And. Val(cLotIn_a) <= Val(oAux:GetValue('CWR_LOTEFI'))
					lRet := .F.
				EndIf
				If Val(cLotIn_a) >= Val(oAux:GetValue('CWR_LOTEIN')) .And. Val(cLotIn_a) <= Val(oAux:GetValue('CWR_LOTEFI'))
					lRet := .F.
				EndIf
				//Verifica se a Grid Lida está contido na Linha Digitada
				If Val(oAux:GetValue('CWR_LOTEIN')) >= Val(cLotIn_a) .And. Val(oAux:GetValue('CWR_LOTEIN')) <= Val(cLotFi_a)
					lRet := .F.
				EndIf
				If Val(oAux:GetValue('CWR_LOTEFI')) >= Val(cLotIn_a) .And. Val(oAux:GetValue('CWR_LOTEFI')) <= Val(cLotFi_a)
					lRet := .F.
				EndIf
			EndIf
		EndIf
		If !lRet
			Help(" ",1,"EXISLOTE",,STR0010,1,0)  //"O Lote digitado já consta em outra linha !"
		EndIf
	Next nX	
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTB112AE(cAlias,nRec,nOpcx)
Valida se poderá Alterar ou Excluir somente quando não existir o Grupo na CWS

@author Wilson.Possani
@since 18/04/2014
@version P120
@Return Retorna a estrutura do Model
/*/
//-------------------------------------------------------------------
Function CTB112AE(cAlias,nRec,nOpcx)
Local cTabCWS := ''
Local cQry1   := ''
Local lAchou  := .T.

	cTabCWS := GetNextAlias()
	cQry1 := " SELECT * "+CRLF
	cQry1 += " FROM "+RetSqlName("CWS")+CRLF
	cQry1 += " WHERE CWS_FILIAL = '"+xFilial("CWS")+"' "+CRLF
	cQry1 += " AND CWS_GRUPO = '"+(cAlias)->CWP_GRUPO+"' "+CRLF	
	cQry1 += " AND D_E_L_E_T_ = ' ' "+CRLF
	cQry1 += " ORDER BY CWS_GRUPO"

	If Select(cTabCWS)<>0
		DbSelectArea(cTabCWS)
		DbCloseArea()
	EndIf

	cQry1 := ChangeQuery(cQry1)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),cTabCWS,.T.,.T.)
	lAchou:=IIf((cTabCWS)->(Eof()),.F.,.T.) 
		
	If nOpcx == 4
		If !lAchou
			FWExecView(STR0001,'CTBA112',MODEL_OPERATION_UPDATE,,{ || .T.},,) //"Alteração"
		Else
			Help(" ",1,"ALTLOTE",,STR0002,1,0)  //"EXISLANC",,"Este Lote Não pode ser Alterado porque já tem Movimentações !"
		EndIf
	ElseIf nOpcx == 5
		If !lAchou
			FWExecView(STR0003,'CTBA112',MODEL_OPERATION_DELETE,,{ || .T.},,) //"Excluir"
		Else
			Help(" ",1,"EXCLOTE",,STR0004,1,0)  //"Este Lote Não pode ser Excluido, porque já tem Movimentações !"
		Endif
	Endif
	
	DbSelectArea(cTabCWS)
	DbCloseArea()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CTB112VldMod(oModel)
Valida os dados informados para gravação do grupo de lotes

@since 10/06/2014
@version P120
@Return se a gravação será permitida ou não.
/*/
//-------------------------------------------------------------------
Function CTB112VldMod(oModel)
Local lRet	:= .T.
Local nOp	:= 0
Local cGrp	:= "" 

nOp := oModel:GetOperation()
If nOp == MODEL_OPERATION_INSERT
	cGrp := oModel:GetValue("CWPGRUPO","CWP_GRUPO")
	If CWP->(DBSeek(xFilial("CWP") + cGrp))
		lRet := .F.
		Help(" ",1,"GRUPOEXISTE",,STR0011 + ": " + Alltrim(cGrp) + "." + CRLF + STR0012 + ".",1,0)		// "Já existe um grupo cadastrado com este código" ### "Informe outro código para o novo grupo"
	Endif	
Endif
Return(lRet)