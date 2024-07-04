#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' //Necessita desse include quando usar MVC.
#include "dbtree.ch"
#include "plsa443.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ PLSA443  บ Autor ณEverton M. Fernandesบ Data ณ  03/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Fun็ใo De x Para das Terminologias TISS					    ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ PLSA443                                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLSA443(CCODTAB)
Local oDlgPrinc
Local oBrwPrinc		// variaveis para os browsers da BTP
Local oPanelPrin		// variaveis para os paineis da BTP 
Local oLayerPrin		// variaveis para os relacionamentos da BTP

Local oLayerBTU, oRelBtpBtu		// variaveis para os relacionamentos da BTU
Local oPnlUpBTU, oPnlADBTU		// variaveis para os paineis da BTU
Local oBrwUpBTU				// variaveis para os browsers da BTU

Local oLayerBVL, oRelBtpBvl, oRelBvlBtu	// variaveis para os relacionamentos da BVL
Local oPnlUpBVL, oPnlBVLBTU				// variaveis para os paineis da BVL
Local oBrwUpBVL, oBrwBVLBTU				// variaveis para os browsers da BVL

Local aCoors	:= FWGetDialogSize( oMainWnd )
Local aSize		:= {}
Local aObjects	:= {}
Local aInfo		:= {}
Local aPosObj		:= {}
Local aCpoBTU		:= {}
Local cAliasBTU	:= getNextAlias()

aCpoBTU := getCPOs( @aCpoBTU,"BTU" )

If Select( cAliasBTU ) <= 0 
	chkFile( "BTU",.F.,cAliasBTU )
EndIf	

DEFINE MSDIALOG oDlgPrinc TITLE ".:: Rela็ใo TISS x Protheus (De/Para) ::." FROM aCoors[ 1 ], aCoors[ 2 ] TO aCoors[ 3 ], aCoors[ 4 ] PIXEL


//--< *** Terminologias TISS *** >--
dbSelectArea( "BTP" )
BTP->( dbSetOrder( 1 ) )

//--< Montagem da tela principal >---
oLayerPrin := FWLayer():New()
oLayerPrin:Init( oDlgPrinc,.F.,.T. )
oLayerPrin:AddLine( 'LIN_MAIN',30,.F. )
oLayerPrin:AddCollumn( 'COL_MAIN',100,.T.,'LIN_MAIN' )
oPanelPrin := oLayerPrin:GetColPanel( 'COL_MAIN','LIN_MAIN' )

//--< Browse Principal >---
oBrwPrinc := FWMBrowse():New()
oBrwPrinc:SetFilterDefault("BTP_FILIAL = '"+xFilial("BTP")+"' .AND. BTP_CODTAB = '"+CCODTAB+"'" )
oBrwPrinc:SetOwner( oPanelPrin )
oBrwPrinc:SetDescription( "Terminologias TISS" )
oBrwPrinc:SetAlias( "BTP" )
oBrwPrinc:SetMenuDef( "" )
oBrwPrinc:DisableDetails()
oBrwPrinc:ForceQuitButton()
oBrwPrinc:SetProfileID( '0' )
oBrwPrinc:SetWalkthru( .F. )
oBrwPrinc:SetAmbiente( .F. )

oBrwPrinc:Activate()




//--< Define tamanho das abas superiores >---
aSize := msAdvSize()
aadd( aObjects,{ 100,100,.T.,.T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := msObjSize( aInfo,aObjects,.T. )

//--< Cria as abas superiores >---
aTFolder := { 'Termos Alias Prin.','Termos Alias Secund.' }
oTFolder := TFolder():New( 150,0,aTFolder,,oPnlUpBTU,,,,.T.,,aPosObj[ 1 ][ 4 ],aPosObj[ 1 ][ 3 ] )


//--< *** Termos Alias Prin. *** >--
//--< Divisao dos Flayers para os Termos BTU >---
oLayerBTU := FWLayer():New()
oLayerBTU:Init( oTFolder:aDialogs[ 1 ],.F.,.T. )

oLayerBTU:AddLine( 'UP',60,.F. )
oLayerBTU:AddCollumn( 'ALLUP',100,.T.,'UP' )
oPnlUpBTU := oLayerBTU:GetColPanel( 'ALLUP','UP' )

oLayerBTU:AddLine( 'DOWN',60,.F. )
oLayerBTU:AddCollumn( 'ALLDOWN' ,100,.T.,'DOWN' )


//--< Painel Superior >---
oBrwUpBTU := FWMBrowse():New()
oBrwUpBTU:SetOwner( oPnlUpBTU )
oBrwUpBTU:SetDescription( "Rela็ใo TISS x Protheus" )
oBrwUpBTU:SetAlias( "BTU" )
oBrwUpBTU:SetMenuDef( 'PLSA443' )
oBrwUpBTU:DisableDetails()
oBrwUpBTU:SetFilterDefault( "BTU_FILIAL = '"+xFilial("BTU")+"' .AND. BTU_CODTAB = '"+CCODTAB+"' " )
oBrwUpBTU:SetProfileID( '2' )
oBrwUpBTU:SetWalkthru( .F. )
oBrwUpBTU:SetAmbiente( .F. )

oBrwUpBTU:setMainProc("PLSA443")

oBrwUpBTU:Activate()


//--< *** Termos Alias Secund. *** >--
//--< Divisao dos Flayers para os Vinculos BVL >---
oLayerBVL := FWLayer():New()
oLayerBVL:Init( oTFolder:aDialogs[ 2 ],.F.,.T. )

oLayerBVL:AddLine( 'UP',30,.F. )
oLayerBVL:AddCollumn( 'ALLUP',100,.T.,'UP' )

oPnlUpBVL := oLayerBVL:GetColPanel( 'ALLUP','UP' )

oLayerBVL:AddLine( 'DOWN',30,.F. )
oLayerBVL:AddCollumn( 'LEFTDOWN',100,.T.,'DOWN' )
oLayerBVL:AddCollumn( 'RIGHTDOWN',50,.T.,'DOWN' )

oPnlBVLBTU	:= oLayerBVL:getColPanel( 'LEFTDOWN','DOWN' )	

//--< Painel Superior : Vinculo >---
oBrwUpBVL := FWMBrowse():New()
oBrwUpBVL:SetOwner( oPnlUpBVL )
oBrwUpBVL:SetDescription( "Vํnculo Tas TISS x Tab Protheus" )
oBrwUpBVL:SetAlias( "BVL" )
oBrwUpBVL:SetMenuDef( "" )
oBrwUpBVL:DisableDetails()
oBrwUpBVL:SetProfileID( '3' )

oBrwUpBVL:Activate()

//--< Painel Inferior : TISS x Protheus >---
oBrwBVLBTU := FWMBrowse():New()
oBrwBVLBTU:SetOwner( oPnlBVLBTU )
oBrwBVLBTU:SetDescription( "Rela็ใo TISS x Protheus" )
oBrwBVLBTU:SetAlias( cAliasBTU )
oBrwBVLBTU:SetMenuDef( "PLSA443" )
oBrwBVLBTU:DisableDetails()
oBrwBVLBTU:SetProfileID( '4' )
oBrwBVLBTU:SetColumns( aCpoBTU )
oBrwBVLBTU:setMainProc("PLSA443")

oBrwBVLBTU:Activate()


//--< Relacionamento : BTP x BVL >---
oRelBtpBvl := FWBrwRelation():New()
oRelBtpBvl:AddRelation( oBrwPrinc,oBrwUpBVL, {;
	{ "BVL_FILIAL" , "BTP_FILIAL"	},;
	{ "BVL_CODTAB" , "BTP_CODTAB"    } } )
oRelBtpBvl:Activate()

//--< Relacionamento : BTP x BTU >---
oRelBtpBtu := FWBrwRelation():New()
oRelBtpBtu:AddRelation( oBrwPrinc,oBrwUpBTU, {;
	{ "BTU_FILIAL" , "BTP_FILIAL"	},;
	{ "BTU_CODTAB" , "BTP_CODTAB"    },;
	{ "BTU_ALIAS"  , "BTP_ALIAS"     } } )
oRelBtpBtu:Activate()	

//--< Relacionamento : BVL x BTU >---
oRelBvlBtu := FWBrwRelation():New()
oRelBvlBtu:AddRelation( oBrwUpBVL,oBrwBVLBTU, {;
	{ "BTU_FILIAL" , "BVL_FILIAL"	},;
	{ "BTU_CODTAB" , "BVL_CODTAB"    },;
	{ "BTU_ALIAS"  , "BVL_ALIAS"     } } )
oRelBvlBtu:Activate()


activate MsDialog oDlgPrinc Center
	
return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ MenuDef  บ Autor ณEverton M. Fernandesบ Data ณ  03/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Define o menu da aplica็ใo                                 ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ PLSA443                                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Visualizar'	Action 'VIEWDEF.PLSA443' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir' 	Action 'VIEWDEF.PLSA443' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar' 	Action 'VIEWDEF.PLSA443' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir' 	Action 'VIEWDEF.PLSA443' OPERATION 5 ACCESS 0

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ ModelDef บ Autor ณEverton M. Fernandesบ Data ณ  03/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Define o modelo de dados da aplica็ใo                      ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ PLSA443                                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()
	local oStruBTU := FWFormStruct( 1,'BTU',/*bAvalCampo*/,/*lViewUsado*/ )
	
	local oModel
	
	//--< RELACAO TISSxPROTHEUS >---
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PLSA443', /*bPreValidacao*/, {|| PL443VALID(oModel,BTP->BTP_CODTAB,BTP->BTP_ALIAS )}/*bPosValidacao*/,{|oModel|PL443COMM(oModel,BTP->BTP_CODTAB,BTP->BTP_ALIAS)}/*bCommit*/, /*bCancel*/ )
	
	// Adiciona ao modelo um componente de formulario
	oModel:AddFields( 'MODEL_BTU',,oStruBTU )
	
	// Adiciona a descricao do Modelo de Dados	
	oModel:SetDescription( "Rela็ใo TISS x Protheus" )
	
	// Adiciona a descricao dos Componentes do Modelo de Dados
	oModel:GetModel( 'MODEL_BTU' ):SetDescription( ".:: Rela็ใo TISSxProtheus(De/Para)  ::." )
	
	/*oModel:SetPrimaryKey( { "BTU_FILIAL","BTU_CODTAB","BTU_VLRSIS","BTU_VLRBUS","BTU_CDTERM","BTU_ALIAS" } )*/

return oModel


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PL443VALID
Realiza a valida็ใo do BTQ_HASVIN

@author    PLS TEAM
@version   1.xx
@since     01/01/2018
/*/
//------------------------------------------------------------------------------------------
Function PL443VALID(oModel,cCodTab,cAlias)
LOCAL lRet		:= .T.
LOCAL cMsg		:= ""
LOCAL oModelMaster	:= oModel:GetModel('MODEL_BTU' )
LOCAL cCodTab
LOCAL cCodVlSis
LOCAL cCodVlBus
LOCAL cCodTerm
LOCAL cCodAlias
LOCAL nOpc		:= oModel:GetOperation()
LOCAL nTab		:= oTFolder:nOption	//verifica a aba selecionada
LOCAL cAlias 		:= iif(nTab <> 2, cAlias, BVL->BVL_ALIAS) 


	// X2_UNICO: BTU_FILIAL+BTU_CODTAB+BTU_VLRSIS+BTU_VLRBUS+BTU_CDTERM+BTU_ALIAS                                                                                                                                                                                          
	cCodTab   := cCodTab
	cCodVlSis := oModelMaster:GetValue('BTU_VLRSIS')
	cCodVlBus := oModelMaster:GetValue('BTU_VLRBUS')
	cCodTerm  := oModelMaster:GetValue('BTU_CDTERM')
	cCodAlias := cAlias 

	If (nOpc <> 5)
		BTU->(DbSelectArea("BTU"))
		BTU->(DbSetOrder(1)) // BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRBUS
		If BTU->(dbSeek(xFilial("BTU")+cCodTab+cCodAlias+cCodVlBus))
	
			   While (BTU->(!Eof()) .AND. BTU->BTU_FILIAL == xFilial("BTU") .AND. BTU->BTU_CODTAB == cCodTab .AND. BTU->BTU_VLRSIS == cCodVlSis .AND. BTU->BTU_VLRBUS == cCodVlBus .AND. BTU->BTU_CDTERM == cCodTerm .AND. BTU->BTU_ALIAS  == cCodAlias .AND. lRet)
		                        
			      //MsgAlert("Item Duplicado","Atencao")
		      	Help( ,, 'HELP',, "Item duplicado.", 1, 0)
		      	lRet := .F.
		      	BTU->(dbSkip())
		   	EndDo
		EndIf
		BTU->(DbCloseArea())	
	EndIf

	// Funcao que atualiza o banco indicando se o termo tem vinculo com algum item do protheus na BTU.
	PLSAHASVIN(cCodTab,cCodTerm,cCodAlias)

Return (lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ ViewDef  บ Autor ณEverton M. Fernandesบ Data ณ  03/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Define o modelo de dados da aplica็ใo                      ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ PLSA443                                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()
	// Interface de visualizacao construํda
	Local oView     := nil
	
	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
	Local oModel	:= FWLoadModel( 'PLSA443' )
	
    // Cria as estruturas a serem usadas na View
	Local oStruBTU := FWFormStruct( 2, 'BTU' )	
	
	Local aArea      := GetArea()
	
	//Retira o campo codigo da tela
	oStruBTU:RemoveField('BTU_CODTAB')
	oStruBTU:RemoveField('BTU_ALIAS')	
	
	oView := FWFormView():New()
	
	// Define qual Modelo de dados serแ utilizado
	oView:SetModel( oModel )
	
	// Adiciona no nosso View um controle do tipo formulแrio (antiga Enchoice)
	oView:AddField( 'VIEW_BTU', oStruBTU, 'MODEL_BTU' )	
	
	RestArea( aArea )
	
// Retorna o objeto de View criado	
return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณPLSTISSVERบ Autor ณ Everton M. Fernandes  บ Data ณ 07/08/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Retorna a versใo da TISS utilizada pela operadora           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSTISSVER(cCodRda)
local aAreaBAU	:= {} 
local cRet		:= ""
local lRpc		:= funName() == "RPC"

default cCodRda := space(6)

If ( lRpc .or. ( valType(nModulo) <> "U" .and. (nModulo == 33 .or. nModulo == 13 ) ) ) .and. FwAliasInDic("BAU") // Se existir tabela no dicionario

    aAreaBAU := BAU->(getArea())                   
	
 	BAU->(DbSetOrder(1))//BAU_FILIAL + BAU_CODIGO
	If BAU->(MsSeek(xFilial("BAU")+cCodRda,.T.))
 		cRet := BAU->BAU_TISVER
   	EndIf

	BAU->(restArea(aAreaBAU))

	If empty(cRet)
	 
		BA0->(dbSetOrder(1))
		if BA0->(msSeek(xFilial("BA0")+PLSIntPad())) 
			cRet := allTrim(BA0->BA0_TISVER)
		endIf
			
	endIf
	
//GH	
elseIf nModulo == 51 
	
	cRet := GetNewPar("MV_TISSVER", "2.02.03")
	
EndIf

Return cRet
                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณPL443COMM บ Autor ณ                    บ Data ณ  23/09/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Realiza a valida็ใo do BTQ_HASVIN                          ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ PLSA443                                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PL443COMM(oMdlDetail,cCodTab,cAlias)
Local nI      := 1
Local nOpc	:= oMdlDetail:GetOperation()
local nTab	:= oTFolder:nOption
LOCAL cAlias  := iif(nTab <> 2,cAlias, BVL->BVL_ALIAS)
	
FWFORMCOMMIT(oMdlDetail)
	
If nOpc <> 5
	BTU->(Reclock("BTU",.F.))
	BTU->BTU_CODTAB	:= cCodTab 
	BTU->BTU_ALIAS	:= cAlias 	
	BTU->(MsUnlock())
EndIf	
		
Return .T.


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getCPOs
Retorna campos

@author    PLS TEAM
@version   1.xx
@since     11/01/2018
/*/
//------------------------------------------------------------------------------------------
static function getCPOs( aCampos,cAlias )	
	Local nI 		:= 1
	Local nJ 		:= 1
	Local aArea		:= getArea()
	Local aAreaSX3	:= SX3->( getArea() )
	Local aColumns	:= { }	
	Local aOptions	:= { }
	Local aCombo	:= { }
	Local cCombo	:= ""
	Local cCampos := ""
	
	/*	Uso do SX3 necessแrio pois na tela de termos alias secundario criamos duas abas com o mesmo Alias mudando apenas o filtro,
		sem criar o alias temporario os registros nใo ficam filtrados.
	*/ 
	dbSelectArea( 'SX3' )
	SX3->( dbSetOrder( 1 ) ) //X3_ARQUIVO
	
	if( SX3->( msSeek( cAlias ) ) )
		while( SX3->X3_ARQUIVO == cAlias )
		 	if( X3USO( SX3->X3_USADO ) .AND. cNivel >= SX3->X3_NIVEL .and. SX3->X3_BROWSE == "S" )
		 		aadd( aCampos,SX3->X3_CAMPO)
		 	endIf
			SX3->( dbSkip() )
		endDo

		SX3->( DbSetOrder( 2 ) ) // X3_CAMPO
		For	nI:=1 To Len( aCampos )
			If ( SX3->( msSeek( aCampos[nI] ) ) )
			
				aadd( aColumns, FWBrwColumn():New() )
				
				aColumns[ nJ ]:setTitle( X3Titulo() )
				aColumns[ nJ ]:setSize( SX3->X3_TAMANHO )
				aColumns[ nJ ]:setDecimal( SX3->X3_DECIMAL )
				aColumns[ nJ ]:setPicture( SX3->X3_PICTURE )
				aColumns[ nJ ]:setData( &( "{||" + aCampos[ nI ] + "}" ) )
				
				cCombo := X3CBox()
				if( ! empty( cCombo ) )
					aCombo := strToKarr( cCombo,";" )
					aColumns[ nJ ]:setOptions( aCombo )
				endIf
						
				nJ++
			endIf
		next nI
	endIf

	restArea( aAreaSX3 )
	restArea( aArea )
return aColumns
