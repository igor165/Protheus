#INCLUDE "PLSCTPDOC.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//Variavel static que alimentará o botao help na solicitação de reembolso
STATIC cBBSImgHelp := "" 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSCTPDOC   ºAutor  ³Microsiga           º Data ³  09/18/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de tipo de documentos no portal do beneficiario   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SEGMENTO SAUDE VERSAO 11.5                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSCTPDOC()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BBS' )
oBrowse:SetDescription(STR0001) //'Cadastro Tipo Documento'
oBrowse:Activate()

Return( NIL )

//-------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := {}

aAdd( aRotina, { 'Pesquisar' , 				'PesqBrw'        , 0, 1, 0, .T. } )
aAdd( aRotina, { 'Visualizar', 				'VIEWDEF.PLSCTPDOC', 0, 2, 0, NIL } )
aAdd( aRotina, { 'Incluir'   , 				'VIEWDEF.PLSCTPDOC', 0, 3, 0, NIL } ) 
aAdd( aRotina, { 'Alterar'   , 				'VIEWDEF.PLSCTPDOC', 0, 4, 0, NIL } ) 
aAdd( aRotina, { 'Excluir'   , 				'VIEWDEF.PLSCTPDOC', 0, 5, 0, NIL } )
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

LOCAL oModelNOT

// Cria o objeto do Modelo de Dados

Local oStrBBS:= FWFormStruct(1,'BBS')

oModelNOT := MPFormModel():New( STR0001, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModelNOT:AddFields( 'BBSMASTER', NIL, oStrBBS )
oModelNOT:SetPrimaryKey( { "BBS_FILIAL", "BBS_COD, BBS_DESCRI" } ) 

// Adiciona a descricao do Modelo de Dados
oModelNOT:SetDescription( STR0001 )

// Adiciona a descricao do Componente do Modelo de Dados
oModelNOT:GetModel( 'BBSMASTER' ):SetDescription( STR0001 )

Return oModelNOT

//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSCTPDOC' )
Local oStruBBS := FWFormStruct(2, 'BBS')
Local oView    := FWFormView():New()

// Define qual o Modelo de dados será utilizado

oView:SetModel( oModel )
oView:AddField('BBS' , oStruBBS,'BBSMASTER' )

oView:SetViewAction( 'BUTTONOK', { |oView| } )

oView:CreateHorizontalBox( 'BOX1', 50)
oView:CreateVerticalBox( 'FORMBBS', 100, 'BOX1')

oView:SetOwnerView('BBS','FORMBBS')

Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBBSImg
Função que permite buscar na pasta imagens-pls determinada imagem para ser atrelada ao documento.
Essa imagem será exibida na solicitação de reembolso do portal em forma de "help" ao lado do campo "Nº do comprovante fiscal"

@author Rodrigo Morgon
@since 09/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSBBSImg()
LOCAL cWebDir  	:= getWebDir()
LOCAL cSkinPls 	:= getSkinPls()
LOCAL cFile    	:= ""
LOCAL nAt
	cBBSImgHelp := Space(Len(BBS->BBS_IMG))
 	cFile := cGetFile("*.JPG|*.jpg|*.bmp|*.BMP|*.png|*.PNG","Selecione a imagem",1,'SERVIDOR' + cWebDir + cSkinPls,.F.,GETF_NETWORKDRIVE)   //"Selecione o Arquivo"
 	nAt := At(cSkinPls, cFile)
 	
	cBBSImgHelp := Substr(cFile, nAt+Len(cSkinPls)+1, Len(cFile))
	
Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} BBSImg
Retorna o conteudo da variavel static cBBSImgHelp

@author Rodrigo Morgon
@since 09/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Function BBSImg()
Return (cBBSImgHelp)
