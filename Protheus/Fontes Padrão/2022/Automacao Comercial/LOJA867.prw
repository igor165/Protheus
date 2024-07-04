#INCLUDE "Protheus.ch"
#INCLUDE "LOJA867.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 

Static lR5 := GetRpoRelease("R5")  //Verifica se é release 11.5 

//-------------------------------------------------------------------
/*{Protheus.doc} LOJA867
Cadastro de Amarração Categoria X Filtro

@author Antonio C Ferreira
@since 19/04/2013
@version 11.5
*/
//-------------------------------------------------------------------

Function LOJA867()

Private aRotina	:= MenuDef()  //Variavel do protheus a rotina tem que ser private.

If lR5
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('MFB')
	oBrowse:SetDescription(STR0001)  //"Amarração Categoria X Filtro"
	oBrowse:Activate()
Else
	Help('',1,'INVLDVER',,STR0002,1,0)  //"Essa função está disponível apenas para a versão 11.5 ou superior."
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu Funcional

@author Antonio C Ferreira
@since 22/04/2013
@version 11.5
*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRotina        := {}   //definicao de arotina do MVC

ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"             OPERATION 0                       ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.LOJA867"     OPERATION MODEL_OPERATION_VIEW    ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.LOJA867"     OPERATION MODEL_OPERATION_INSERT  ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.LOJA867"     OPERATION MODEL_OPERATION_DELETE  ACCESS 0 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo

@author Antonio C Ferreira
@since 22/04/2013
@version 11.5
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructMFB 	:= FWFormStruct(1,"MFB")   //Estrutura da MF
Local oModel 		:= Nil                     //Objeto oModel do ModelDef

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA867",/*Pre-Validacao*/,{|oModel| LJ867TOk(oModel)}/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("MFBMASTER", Nil/*cOwner*/, oStructMFB ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:GetModel("MFBMASTER"):SetDescription("Amarração Categoria X Filtro")

oModel:SetPrimaryKey({"MFB_FILIAL+MFB_ECCATE+MFB_ECFILT"})

//Campos editaveis somente na inclusao
oStructMFB:SetProperty( 'MFB_ECCATE' , MODEL_FIELD_WHEN, {|| INCLUI })
oStructMFB:SetProperty( 'MFB_ECFILT' , MODEL_FIELD_WHEN, {|| INCLUI })

Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da Visao

@author Antonio C Ferreira
@since 22/04/2013
@version 11.5
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView  		:= Nil                       //Objeto view do form
Local oModel  		:= FWLoadModel("LOJA867")   //Objeto oModel do MVC
Local oStructMFB 	:= FWFormStruct(2,"MFB")    //Estrutura da MFB

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)   
oView:EnableControlBar(.T.)  
oView:AddField( "VIEW_CABMFB" , oStructMFB, "MFBMASTER" )
oView:CreateHorizontalBox( "HEADER" , 30 )
oView:SetOwnerView( "VIEW_CABMFB" , "HEADER" )

Return oView

//-------------------------------------------------------------------
/*{Protheus.doc} LJ867Valid
Realiza o valid do campo MEV_PRODUT

@author Antonio C Ferreira
@since 22/04/2013
@param - nCampo: Indica qual é o campo que está chamando a função
		  nCampo = 1: Chamado pelo campo MFB_ECCATE
		  nCampo = 2: Chamado pelo campo MFB_ECFILT
@version 11.5
*/
//-------------------------------------------------------------------
Function LJ867Valid(nCampo)
Local oModel	 := FwModelActive()                             //Objeto oModel do MVC
Local lRet  	 := .T.                                         //Retorna verdadeiro se validou sem erro
Local cCategoria := oModel:GetValue("MFBMASTER","MFB_ECCATE")   //Codigo da categoria
Local cFiltro 	 := oModel:GetValue("MFBMASTER","MFB_ECFILT")   //Codigo do tipo de filtro

Default nCampo := 0

If nCampo == 1 //campo MFB_ECCATE
                               
    ACU->(DbSetOrder(1))
    If  !( DbSeek(xFilial('ACU')+cCategoria) )
		Help('',1,'TPINVALID',,STR0003,1,0)  //"Categoria não encontrada no cadastro!"
		lRet := .F.
	Else	
		lRet := Empty(ACU->ACU_CODPAI)
		If  !( lRet )
			Help('',1,'TPINVALID',,STR0004,1,0)    //"A Categoria utilizada deve ser Categoria Pai e não Categoria Filho!"
		EndIf
	EndIf	
			
ElseIf nCampo == 2 //campo MFB_ECFILT

	lRet := ExistCpo("MF9",cFiltro)
	
	If  !( lRet )
		Help('',1,'TPINVALID',,STR0005,1,0)  //"Tipo de Filtro não cadastrado!"
	EndIf

	If  lRet
		lRet := ExistChav("MFB",cCategoria+cFiltro)
		
		If  !( lRet )
			Help('',1,'TPINVALID',,STR0006,1,0)   //"Amarração Categoria X Tipo já cadastrado!"
		EndIf
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} LJ867TOK
Validacao final antes da gravacao dos dados. Limpa o campo de exportacao.

@author Antonio C Ferreira
@since 22/04/2013
@param - oModel: Model do MVC
@version 11.5
*/
//-------------------------------------------------------------------
Function LJ867TOK(oModel)

Local cFiltro    := oModel:GetValue("MFBMASTER","MFB_ECFILT") //Codigo do tipo de filtro
Local aArea      := GetArea()                                 //Salva a area atual

Default oModel := nil

DbSelectArea("MF9")
DbSetOrder(1)  //MF9_FILIAL+MF9_ECCODI

If  DbSeek(xFilial("MF9")+cFiltro) .And. SoftLock("MF9")
    MF9->MF9_ECDTEX := Space(8)  //Limpa para exportacao do Filtro
	MsUnLock()
EndIf

RestArea(aArea)

Return .T.
