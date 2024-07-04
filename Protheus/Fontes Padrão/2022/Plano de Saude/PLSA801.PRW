#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA801.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA801
Funcao para abrir cadastro de Motivo da Visita
@author Oscar Zanin
@since 08/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA801()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B9L')
oBrowse:SetDescription(FunDesc())
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 08/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title STR0006 /*'Visualizar'*/ Action 'VIEWDEF.PLSA801' Operation 2 Access 0
Add Option aRotina Title STR0007 /*'Incluir'   */ Action 'VIEWDEF.PLSA801' Operation 3 Access 0
Add Option aRotina Title STR0008 /*'Alterar'   */ Action 'VIEWDEF.PLSA801' Operation 4 Access 0
Add Option aRotina Title STR0009 /*'Excluir'   */ Action 'VIEWDEF.PLSA801' Operation 5 Access 0
Add Option aRotina Title STR0010 /*'Imprimir'  */ Action 'VIEWDEF.PLSA801' Operation 8 Access 0
Add Option aRotina Title STR0011 /*'Copiar'    */ Action 'VIEWDEF.PLSA801' Operation 9 Access 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since 08/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB9L:= FWFormStruct(1,'B9L')

oModel := MPFormModel():New( 'PLSA801', , {|| PLSA801OK(oModel) } ) //Cria a estrutura do Modelo de dados e Define e a função que irá Validar no "OK"
oModel:addFields('MasterB9L',/*cOwner*/,oStrB9L) 			//Adiciona ao modelo um componente de formulário
oModel:getModel('MasterB9L')
oModel:SetDescription(FunDesc())								// Adiciona a descrição do Modelo de Dados

oModel:SetPrimaryKey( { "B9L_CODINT", "B9L_CODVIS", "B9L_TIPVIS" } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 08/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrB9L:= FWFormStruct(2, 'B9L', { |cCampo| PLSA801CMP(cCampo) })

oView := FWFormView():New() 				// Cria o objeto de View
oView:SetModel(oModel)						// Define qual Modelo de dados será utilizado
oView:AddField('FrmB9L' , oStrB9L,'MasterB9L' ) 		// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:CreateHorizontalBox( 'BxB9L', 100)	// Cria o Box que irá conter a View
oView:SetOwnerView('FrmB9L','BxB9L')		// Associa a View ao Box

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA801OK
Validar botão confirmar
@author Oscar Zanin
@since 08/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA801OK(oModel)
LOCAL lRet     		:= .T.
LOCAL cMsg     		:= ""
LOCAL oModelDetail	:= oModel:GetModel( 'MasterB9L' )
LOCAL cDescri  		:= ""
LOCAL cTipo			:= ""
LOCAL cCodInt			:= ""
LOCAL nOpc				:= oModel:GetOperation()

If ((nOpc <> 5) .AND. (nOpc <> 4))  //Não para "Alterar" e "Excluir"

	cDescri := oModelDetail:GetValue('B9L_DESVIS')
	cTipo   := oModelDetail:GetValue('B9L_TIPVIS')
	cCodInt := PLSINTPAD()
	
	B9L->(DbSelectArea("B9L"))
	B9L->(DbSetOrder(5)) // B9L_FILIAL + B9L_DESVIS + B9L_TIPVIS
	
	//Busca se Descrição e tipo informados já foram cadastrados
	If (B9L->(MsSeek(XFilial("B9L") + cCodInt + cDescri + cTipo))) 
   		cMsg := STR0001 //"Motivo de Visita já cadastrado para o Tipo de Visita Selecionado!"
   		Help( ,, 'HELP',, cMsg, 1, 0)
   		lRet := .F.
   		
	ElseIf (cTipo <> "2")  //Verifica se o Tipo informado não é "Ambos"
		//Busca se a Descrição informada foi cadastrada para o tipo "Ambos"
		IF (B9L->(MsSeek(XFilial("B9L") + cCodInt + cDescri + "2"))) 
			cMsg := STR0002 //"Motivo de Visita já cadastrado para Ambos os Tipos!"
   			Help( ,, 'HELP',, cMsg, 1, 0)
   			lRet := .F.
   		EndIf
   		
   	ElseIf (cTipo =="2") //Verifica se o Tipo informado é "Ambos"
   		//Busca se a Descrição foi cadastrada para "Captação" E "Relacionamento"
 		IF ((B9L->(MsSeek(XFilial("B9L") + cCodInt + cDescri + "0"))) .AND. (B9L->(MsSeek(XFilial("B9L") + cCodInt + cDescri + "1"))))
			cMsg := STR0003 //"Motivo de Visita já cadastrado para Captação e Relacionamento!"
   			Help( ,, 'HELP',, cMsg, 1, 0)
   			lRet := .F.
   			
   		//Busca se a Descrição foi cadastrada para "Captação"
 		ElseIf (B9L->(MsSeek(XFilial("B9L") + cCodInt + cDescri + "0")))
			cMsg := STR0004 //"Motivo de Visita já cadastrado para Captação!"
   			Help( ,, 'HELP',, cMsg, 1, 0)
   			lRet := .F.
   			
   		//Busca se a Descrição foi cadastrada para "Relacionamento"
   		ElseIf (B9L->(MsSeek(XFilial("B9L") + cCodInt + cDescri + "1")))
			cMsg := STR0005 //"Motivo de Visita já cadastrado para Relacionamento!"
   			Help( ,, 'HELP',, cMsg, 1, 0)
   			lRet := .F.
   			
   		EndIf
   	EndIf
   	
   	B9L->(DbCloseArea())
   	
EndIf

If (nOpc == 4) //Só para "Alterar"

	cDescri := oModelDetail:GetValue('B9L_DESVIS')
	cTipo   := oModelDetail:GetValue('B9L_TIPVIS')
	cCodInt := PLSINTPAD()
	
	B9L->(DbSelectArea("B9L"))
	B9L->(DbSetOrder(5)) // B9L_FILIAL + B9L_DESVIS + B9L_TIPVIS
	
	//Busca se Descrição e tipo informados já foram cadastrados
	If (B9L->(MsSeek(XFilial("B9L") + cCodInt + cDescri + cTipo)))
   		cMsg := STR0001 //"Motivo de Visita já cadastrado para o Tipo de Visita Selecionado!"
   		Help( ,, 'HELP',, cMsg, 1, 0)
   		lRet := .F.
   	ElseIf (cTipo =="2") //Verifica se o Tipo informado é "Ambos"
   	
   		//Busca se a Descrição foi cadastrada para "Captação" E "Relacionamento"
 		IF ((B9L->(MsSeek(XFilial("B9L") + cCodInt + cDescri + "0"))) .AND. (B9L->(MsSeek(XFilial("B9L") + cCodInt + cDescri + "1"))))
			cMsg := STR0003 //"Motivo de Visita já cadastrado para Captação e Relacionamento!"
   			Help( ,, 'HELP',, cMsg, 1, 0)
   			lRet := .F.
   		EndIf
   	EndIf
   	B9L->(DbCloseArea())
   	
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA801CMP
Tratamento para campos que não devem ir na View
@author Oscar Zanin
@since 19/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA801CMP(cCampo)

Local lRet	:= .T.

If cCampo == "B9L_CODINT"
	lRet := .F.
EndIf

If cCampo == "B9L_DESINT"
	lRet := .F.
EndIf

Return lRet