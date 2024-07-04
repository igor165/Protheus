#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA743.ch'
 
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA743  
Funcao para abrir a tela  de Redimensionamento de Rede 
@author Totvs
@since 23/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA743()
Local oBrowse
Local cFilter := ""
Local cOperadora := ""
Local cRDA := ""
Local cAno := ""
	
	If ! Pergunte("PLS743",.T.)
	   Return
	Endif
	
	cOperadora := MV_PAR01
	cRDA := MV_PAR02
	cAno:= MV_PAR03


cFilter:= "B9S_CODINT=='" + Alltrim(cOperadora) + "' .AND. B9S_CODREG=='" + Alltrim(cRDA) + "' .AND. B9S_ANO=='" + alltrim(cAno) + "'"
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B9S')
oBrowse:SetDescription(FunDesc())
oBrowse:SetFilterDefault(cFilter)
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Totvs
@since 23/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Totvs
@since 23/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB9S:= FWFormStruct(1,'B9S')

oModel := MPFormModel():New('PLSA743')  //Cria a estrutura do Modelo de dados e Define e a função que irá Validar no "OK"
oModel:addFields('MasterB9S',/*cOwner*/,oStrB9S) 			//Adiciona ao modelo um componente de formulário
oModel:getModel('MasterB9S')
oModel:SetDescription(FunDesc())								// Adiciona a descrição do Modelo de Dados

oModel:SetPrimaryKey( {} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Totvs
@since 23/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrB9S:= FWFormStruct(2, 'B9S')

oView := FWFormView():New() 				// Cria o objeto de View
oView:SetModel(oModel)						// Define qual Modelo de dados será utilizado
oView:AddField('FrmB9S' , oStrB9S,'MasterB9S' ) 		// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:CreateHorizontalBox( 'BxB9S', 100)	// Cria o Box que irá conter a View
oView:SetOwnerView('FrmB9S','BxB9S')		// Associa a View ao Box

Return oView