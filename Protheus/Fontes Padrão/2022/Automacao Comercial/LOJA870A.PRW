#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA870A.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA870A 
Cadastro de blocos para configuracao de arquivos texto ( txt ).

@author Varejo
@since 20/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Function LOJA870A()
Local oBrowse


oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'MFF' )
oBrowse:SetDescription(STR0001)//"Cadastro de Blocos"
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu Funcional

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRotina        := {}

ADD OPTION aRotina TITLE STR0004 ACTION "PesqBrw"  		       OPERATION 0                         ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOJA870A"     OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.LOJA870A"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.LOJA870A"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.LOJA870A"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructMFF := FWFormStruct(1,"MFF")  // carrega estrutura da tabela
Local oModel := Nil

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA870A",/*Pre-Validacao*/,{|oModel| PoVldModel(oModel) }/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)

oModel:AddFields("MFFMASTER", Nil/*cOwner*/, oStructMFF ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)

oModel:SetPrimaryKey( { "MFF_FILIAL","MFF_CODIGO" } )
                                                                        
oModel:GetModel("MFFMASTER"):SetDescription(STR0001)


Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da Visao

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView        := Nil
Local oModel       := FWLoadModel("LOJA870A")
Local oStructMFF := FWFormStruct(2,"MFF") 
//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
            

oView:AddField( "VIEWMFF" , oStructMFF, "MFFMASTER" )
 
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWMFF' , 'SUPERIOR' )
                               
oView:EnableTitleView( 'VIEWMFF' )
                                                       	
Return oView

//-------------------------------------------------------------------
/*{Protheus.doc} PoVldModel
Valida o cadastro de blocos para que não exista blocos iguais.

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function PoVldModel(oModel)

Local aArea       := MFF->(GetArea()) 	// Posicionamento atual da tabela
Local oView	  	
Local oModel    
Local cCabec	  := ""              		// Armazena o campo cabecalho 
Local cResgistro  := ""              	// Armazena o campo registro
Local cRodape     := ""              	// Armazena o campo rodape
Local lRet   	  := .T.
Local lAutomato   := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX) 

If !lAutomato
	oView	  	:= FwViewActive()   // Pega view ativa
	oModel      := oView:GetModel()  // Pega o modelo
Else
	oModel := FWModelActive()
EndIf 
             
oModel 	  := oModel:GetModel('MFFMASTER')    

cCabec	  := oModel:GetValue('MFF_CABECA')
cResgistro:= oModel:GetValue('MFF_REGIST')
cRodape   := oModel:GetValue('MFF_RODAPE')

DbSelectArea("MFF")
If INCLUI .OR. ALTERA
	DbSetOrder(2)
	If DbSeek( xFilial("MFF")+ cCabec + cResgistro + cRodape )
		Alert(STR0002+CRLF+STR0003+ MFF_CODIGO)//"Cadastro de bloco repetido."#//"Cod. Bloco: "
		lRet:= .F.
	EndIf
EndIf
RestArea(aArea)
Return lRet