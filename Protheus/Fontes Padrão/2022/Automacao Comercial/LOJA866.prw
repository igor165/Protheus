#INCLUDE "Protheus.ch"
#INCLUDE "LOJA866.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 

Static lR5 := GetRpoRelease("R5")  //Verifica se é release 11.5

//-------------------------------------------------------------------
/*{Protheus.doc} LOJA866
Cadastro de Tipo de Filtros e-Commerce

@author Antonio C Ferreira
@since 19/04/2013
@version 11.5
*/
//-------------------------------------------------------------------

Function LOJA866()

Private aRotina	:= MenuDef()  //Variavel do protheus a rotina tem que ser private.

If lR5
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('MF9')
	oBrowse:SetDescription(STR0001)  //"Cadastro de Tipo de Filtros e-Commerce"
	oBrowse:Activate()
Else
	Help('',1,'INVLDVER',,STR0002,1,0)    //"Essa função está disponível apenas para a versão 11.5 ou superior."
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu Funcional

@author Antonio C Ferreira
@since 19/04/2013
@version 11.5
*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRotina        := {}   //definicao de arotina do MVC

ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"             OPERATION 0                       ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.LOJA866"     OPERATION MODEL_OPERATION_VIEW    ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.LOJA866"     OPERATION MODEL_OPERATION_INSERT  ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.LOJA866"     OPERATION MODEL_OPERATION_UPDATE  ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.LOJA866"     OPERATION MODEL_OPERATION_DELETE  ACCESS 0 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo

@author Antonio C Ferreira
@since 19/04/2013
@version 11.5
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructMF9 	:= FWFormStruct(1,"MF9")    //Estrutura da MF9
Local oStructMFA 	:= FWFormStruct(1,"MFA")    //Estrutura da MFA
Local oModel 		:= Nil                      //Objeto oModel do ModelDef

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA866",/*Pre-Validacao*/,/*{|oModel| LJ866TOk(oModel)}Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("MF9MASTER", Nil/*cOwner*/, oStructMF9 ,/*Pre-Validacao*/,{ |oMdl| LJ866Final( oMdl ) }/*Pos-Validacao*/,/*Carga*/)
oModel:GetModel("MF9MASTER"):SetDescription(STR0001)  //"Cadastro de Tipo de Filtros e-Commerce"

oModel:SetPrimaryKey({"MF9_FILIAL+MF9_ECCODI"})

oModel:AddGrid("MFADETAIL", "MF9MASTER"/*cOwner*/, oStructMFA,/*{|oModelGrid,nLinha,cAction| LJ866LnPos(oModelGrid,nLinha,cAction)}LinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/) 
oModel:SetRelation("MFADETAIL",{{"MFA_FILIAL",'xFilial("MFA")'},{"MFA_ECFILT","MF9_ECCODI"}},MFA->(IndexKey()))

oModel:GetModel('MFADETAIL'):SetUniqueLine({'MFA_ECDESC'})

Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da Visao

@author Antonio C Ferreira
@since 19/04/2013
@version 11.5
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView  		:= Nil                     //Objeto view do form
Local oModel  		:= FWLoadModel("LOJA866")  //Objeto oModel do MVC
Local oStructMF9 	:= FWFormStruct(2,"MF9")   //Estrutura da MF9
Local oStructMFA 	:= FWFormStruct(2,"MFA")   //Estrutura da MFA

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)   
oView:EnableControlBar(.T.)  
oView:AddField( "VIEW_CABMF9" , oStructMF9, "MF9MASTER" )
oView:CreateHorizontalBox( "HEADER" , 30 )
oView:SetOwnerView( "VIEW_CABMF9" , "HEADER" )

oView:AddGrid("VIEW_ITMFA" , oStructMFA,"MFADETAIL")
oView:CreateHorizontalBox( "ITENS" , 60 )
oView:SetOwnerView( "VIEW_ITMFA" , "ITENS" )

// Define campos que terao Auto Incremento
oView:AddIncrementField( "VIEW_ITMFA", 'MFA_ECITEM' )

Return oView

//-------------------------------------------------------------------
/*{Protheus.doc} LJ866Final
Validacao final antes da gravacao dos dados. Limpa o campo de exportacao.

@author Antonio C Ferreira
@since 22/04/2013
@param - oModel: Model do MVC
@version 11.5
*/
//-------------------------------------------------------------------
Function LJ866Final(oModel)             

Default oModel := nil
                     
If  !( Empty(oModel) )
	oModel := oModel:GetModel( "MF9MASTER" )
	
	oModel:SetValue("MF9MASTER", "MF9_ECDTEX", Space(8))
EndIf

Return .T.