#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA987.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA987
Tela de revisão da mensagem de exclusão enviada ao TAF

@author Karen Honda
@since 14/09/2016
@version P11
/*/
//-------------------------------------------------------------------
Function FINA987()
Local oBrowse

If AliasInDic("FKH")
	DbSelectArea("FKH")
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('FKH')
	oBrowse:SetDescription(STR0001)//'Revisão de exclusão TAF'

	oBrowse:Activate()
Else
	MsgStop(STR0010)	//"Tabela FKH não existe. Necessário atualizar o ambiente"
EndIf
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION 'F987Rev' OPERATION 9 ACCESS 0 //'Criar nova Revisão'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FINA987' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FINA987' OPERATION 5 ACCESS 0 //'Excluir'

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruFKH := FWFormStruct( 1, 'FKH', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

oStruFKH:SetProperty("FKH_REVISA",MODEL_FIELD_INIT, {|| MaxSeq() })
oStruFKH:SetProperty("FKH_LAYOUT",MODEL_FIELD_INIT, {|| FKH->FKH_LAYOUT })
oStruFKH:SetProperty("FKH_ID",MODEL_FIELD_INIT, {|| FKH->FKH_ID })

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('FINA987', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FKHMASTER', /*cOwner*/, oStruFKH, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:SetPrimaryKey({'FKH_FILIAL','FKH_LAYOUT','FKH_REVISA'})

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0006 )//'Revisão da mensagem de exclusão ao TAF'


Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'FINA987' )
// Cria a estrutura a ser usada na View
Local oStruFKH := FWFormStruct( 2, 'FKH' )
Local oView

oStruFKH:SetProperty("FKH_ID",MVC_VIEW_CANCHANGE, .F.)
oStruFKH:SetProperty("FKH_REVISA",MVC_VIEW_CANCHANGE, .F.)
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FKH', oStruFKH, 'FKHMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FKH', 'TELA' )

oView:EnableControlBar(.F.)


//oView:SetViewAction( 'BUTTONOK'    , { |o| Help(,,'HELP',,'Ação de Confirmar ' + o:ClassName(),1,0) } )
//oView:SetViewAction( 'BUTTONCANCEL', { |o| Help(,,'HELP',,'Ação de Cancelar '  + o:ClassName(),1,0) } )
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} F987Rev 
Opção Criar nova Revisão, para altera a mensagem a ser enviada ao TAF

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function F987Rev()
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

FWExecView( STR0007,"FINA987", 9,/**/,{||.T.}/*bCloseOnOk*/,{||EnviaMsgTAF()},,aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/ )//'Gerar nova revisão'

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MaxSeq 
Função para pegar a ultima revisão para incrementar a proxima

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function MaxSeq()
Local cQuery := ""
Local cAliasQry := GetNextAlias()
Local cSeq := "000001"

DbSelectarea("FKH")

cQuery := " SELECT MAX(FKH_REVISA) REVISA FROM " + RetSqlName("FKH")
cQuery += " WHERE FKH_FILIAL = '" + xFilial("FKH") + "' " 
cQuery += " AND FKH_LAYOUT = '" + FKH->FKH_LAYOUT + "' "
cQuery += " AND FKH_ID = '" + FKH->FKH_ID + "' "
cQuery += " AND D_E_L_E_T_ = ' '"
  
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
	
If !(cAliasQry)->(Eof())
	cSeq := Soma1((cAliasQry)->REVISA)
EndIf

(cAliasQry)->(DBCloseArea())

Return cSeq

//-------------------------------------------------------------------
/*/{Protheus.doc} F987Incl 
Função para incluir a primeira revisao. Utilizada nas rotinas de contas a pagar/receber
ao excluir o titulo.

@param cLayout Codigo do layout do TAF. Ex T999
@param cChave Chave do registro a ser exluido
@return lRet  retorna .T. se gravou corretamente 

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function F987Incl(cLayout, cChave)
Local oModel
Local lRet	 := .T.
Local cLog := ""
oModel := FwLoadModel("FINA987")
oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()

oModel:SetValue("FKHMASTER","FKH_ID",FWUUIDV4())
oModel:SetValue("FKHMASTER","FKH_LAYOUT",cLayout)
oModel:SetValue("FKHMASTER","FKH_REVISA","000001")
oModel:SetValue("FKHMASTER","FKH_MSGTAF",cChave)
	
If oModel:VldData()
	lRet	 := .T.
	FwFormCommit(oModel)
Else
	lRet := .F.
	cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
	cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
	cLog += cValToChar(oModel:GetErrorMessage()[6])        	
	Help( ,,"FINA987",,cLog, 1, 0 )
Endif
	
oModel:Deactivate()
oModel:Destroy()
oModel:= Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EnviaMsgTAF 
Ao confirmar a tela, será gravado a nova revisão e gerado a mensagem para a TAFST1

@return retorna .t. se enviou a mensagem para o TAF

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function EnviaMsgTAF()
Local oModel := FwModelActive()
Local cChave	:= ""
Local cReg 	:= ""
Local aRegs	:= {}
Local lOpenST1 := .T.
Local lRet    :=  .T.

Private cTpSaida := "2" // utilizado na FConcTxt para definir se integração será banco a banco ou txt
Private lGeraST2TAF := .F.
Private aDadosST1 := {} //utilizado pelas funcoes do TAF na gravacao dos dados na ST1
Private cInc := "000001" // utilizado pela funcao do taf

If MsgYesNo(STR0008)//"Será enviado uma nova mensagem ao TAF. Deseja continuar?"
	
	If Select("TAFST1") == 0
		dbUseArea( .T.,"TOPCONN","TAFST1","TAFST1",.T.,.F.) //Abre Exclusivo
		
		lOpenST1 := Select("TAFST1") > 0
		
		If !lOpenST1
			MsgAlert(STR0009)//" Não foi encontrada e/ou não foi possivel a abertura Exclusiva da tabela TAFST1 no mesmo Ambiente de ERP!" 
			lRet := .F.
		Endif
	EndIf
	If lRet
		cReg := Alltrim(oModel:GetValue("FKHMASTER","FKH_LAYOUT"))
		cChave:= Alltrim(oModel:GetValue("FKHMASTER","FKH_MSGTAF"))
		Aadd( aRegs, {  ;
				cReg,; 				// TIPO REGISTRO
				cChave})				// Chave
									
		FConcTxt( aRegs)
		
		FConcST1()
		
		If lOpenST1
			TAFST1->(DbCloseArea())
		EndIf	
	Endif
Else
	lRet := .F.	
EndIf
Return lRet

