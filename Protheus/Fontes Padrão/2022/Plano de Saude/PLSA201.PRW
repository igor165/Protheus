#include "PLSA201.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWMBROWSE.CH'
#include "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA201
Tela de Cadastro de Procedimentos Incompatíveis

@author Victor Ferreira
@since 30/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA201()

Local aSize		:= {}			//Array com o tamnho da tela
Local oFWLayer   					//Layer
Local oPLUp						//Painel Superior da Esquerda

Static oBrwBR8					//Browse da Tabela Padrão
Static oBrwBJ4					//Browse dos Procedimentos Incompatíveis

Local oDlg

Private cCadastro	:= STR0001		//"Procedimentos Incompatíveis"
Private cChvBR8	:= ""

//Carrega Helps da Rotina
LoadHelp()

//Define dimensionamento da Tela
aSize := FWGetDialogSize(oMainWnd)

DEFINE MSDIALOG oDlg TITLE STR0001	FROM aSize[1], aSize[2] TO aSize[3], aSize[4] PIXEL //"Procedimentos Incompatíveis"

//Janela maximizada
oDlg:lMaximized := .T. 

//Inicializa o FWLayer
oFwLayer := FwLayer():New()
oFwLayer:Init(oDlg,.F.)

//Cria o Layer Superior
oFWLayer:addLine("UP_BR8", 50, .F.)

//Cria o Layer Inferior
oFWLayer:addLine("DOWN_BJ4", 50, .F.) 

//Definição dos Painéis
oPLUp	:= oFWLayer:GetLinePanel( "UP_BR8" )	// Painel da Tabela Padrão
oPDown	:= oFWLayer:GetLinePanel( "DOWN_BJ4" )	// Painel dos Procedimentos Incompatíveis 

//MBrowse BR8
cAlias	:= "BR8"
oBrwBR8:= FWMBrowse():New()
oBrwBR8:SetOwner(oPLUp)
oBrwBR8:SetDescription(STR0002)//"Tabela Padrão"
oBrwBR8:SetAlias(cAlias)
oBrwBR8:DisableDetails()
oBrwBR8:DisableLocate()
oBrwBR8:SetAmbiente(.F.)
oBrwBR8:SetWalkThru(.F.)
oBrwBR8:SetMenuDef("")
oBrwBR8:ForceQuitButton() 
oBrwBR8:Activate()

//MBrowse BJ4
DbSelectArea("BJ4")
cAlias := "BJ4"
oBrwBJ4:= FWMBrowse():New()
oBrwBJ4:SetOwner(oPDown)
oBrwBJ4:SetAlias(cAlias)
oBrwBJ4:SetDescription(STR0001)//"Procedimentos Incompatíveis"
oBrwBJ4:DisableDetails()
oBrwBJ4:SetWalkThru(.F.) 
oBrwBJ4:SetAmbiente(.F.)
oBrwBJ4:SetMenuDef("PLSA201")
oBrwBJ4:Activate()

//Estabelecendo Relacionamento
oRelacBR8:= FWBrwRelation():New() 
oRelacBR8:AddRelation(oBrwBR8, oBrwBJ4,{	{ 'BJ4_FILIAL' , 'xFilial( "BJ4" )' 		},;
											  	{ 'BJ4_CODIGO' , 'BR8_CODPAD+BR8_CODPSA' 	}})													 
oRelacBR8:Activate() 

Activate MsDialog oDlg Centered

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL201PSA
Verifica se o BR8_CODPSA é igual ao do BJ4_CODPSA

@author Victor Ferreira
@since 30/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLM201PSA()
Local oModel	:= FwModelActive()
Local lRet 	:= .T.
Local lVldPrIn:= .T.
Local cCodPad	:= AllTrim(oModel:GetValue("BJ4MASTER","BJ4_CODPAD"))
Local cCodPro	:= AllTrim(oModel:GetValue("BJ4MASTER","BJ4_CODPSA"))
Local aAreaBJ4:= BJ4->(GetArea())
Local cChave	:= "" 

//Recupera o Registro apos acionar a Consulta Padrão da BR8
Restore()

BJ4->(DbSetOrder(1))//BJ4_FILIAL+BJ4_CODIGO+BJ4_CODPAD+BJ4_CODPSA

cChave:= BR8->(BR8_CODPAD+BR8_CODPSA)+cCodPad+cCodPro

If ExistBlock("PLAUTPRI")
	lVldPrIn := ExecBlock("PLAUTPRI",.F.,.F.,{"",cCodPad,cCodPro})
EndIf

If cCodPad == Subs(BR8->(BR8_CODPAD+BR8_CODPSA),1,2) .And. cCodPro == AllTrim(Subs(BR8->(BR8_CODPAD+BR8_CODPSA),3,16))
	lRet := .F.
	Help("",1,"PLSA201BJ4")//O codigo do procedimento principal e o mesmo do procedimento que esta sendo digitado
ElseIf BJ4->(MsSeek(xFilial("BJ4")+cChave))
	lRet := .F.
	Help("",1,"PLMVBJ4001")//Procedimento incompatível já cadastrado //Informe outro código
ElseIf !BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))
	lRet := .F.
	Help("",1,"PLMVBJ4002")//Procedimento não encontrado na tabela padrão //Informe outro código	
EndIf

If lVldPrIn
   PLSGATNIV(cCodPad,cCodPro,"BJ4")
Endif

RestArea(aAreaBJ4)

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PL201INBR
Inicializa a descrição do procedimento no Brw da BJ4

@author Victor Ferreira
@since 04/02/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PL201INBR()
Local nDesPsa := TamSx3("BJ4_DESPSA")[1]
Local cRet		:= Posicione("BR8",1,xFilial("BR8")+AllTrim(BJ4->(BJ4_CODPAD+BJ4_CODPSA)),"BR8_DESCRI")

cRet:= SubStr(cRet,1,nDesPsa)

Restore()

Return(cRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} PLM201DES
Gatilha os campos do Brw

@author Victor Ferreira
@since 30/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLM201GAT(cCtnDom)
Local oModel		:= FwModelActive()
Local cRet    	:= Space(TamSx3(cCtnDom)[1])
Local cCodPad		:= AllTrim(oModel:GetValue("BJ4MASTER","BJ4_CODPAD"))
Local cCodPro		:= AllTrim(oModel:GetValue("BJ4MASTER","BJ4_CODPSA")) 

BR8->(DbSetOrder(1))
If BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))
	Do Case
	Case cCtnDom == "BJ4_NIVEL"
		cRet	:= BR8->BR8_NIVEL
	Case cCtnDom == "BJ4_DESPSA"
		cRet 	:= SubStr(BR8->BR8_DESCRI,1,TamSx3(cCtnDom)[1])
	EndCase
EndIf
      
Restore()

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSABJ4201
Tratamento para definir os campos da BJ4 que não serão usados na Model
@author Victor Ferreira e Silva
@since 30/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSABJ4201 (cCampo)

Local lRet	:= .T.
cCampo := Alltrim(cCampo)

If cCampo == "BJ4_CODIGO" 
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSABJ4INI
Definição do inicializador padrão dos campos da BJ4
@author Victor Ferreira e Silva
@since 30/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSABJ4INI(cCampo)
Local oModel		:= FwModelActive()
Local cRet    	:= Space(TamSx3(cCampo)[1])
Local cCodPad		:= ""
Local cCodPro		:= "" 

If oModel:GetOperation() <> MODEL_OPERATION_INSERT
	
	cCodPad:= AllTrim(oModel:GetValue("BJ4MASTER","BJ4_CODPAD"))
	cCodPro:= AllTrim(oModel:GetValue("BJ4MASTER","BJ4_CODPSA"))
	 
	BR8->(DbSetOrder(1))
	If BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))
		Do Case
		Case cCampo == "BJ4_DESPSA"
			cRet 	:= SubStr(BR8->BR8_DESCRI,1,TamSx3(cCampo)[1])
		EndCase
	EndIf
EndIf
      
Restore()

Return(cRet)


//-------------------------------------------------------------------
Static Function MenuDef()
PRIVATE aRotina := {}      

//Opcoes de menu
aAdd( aRotina, { STR0003, 'PesqBrw'         , 0, 1, 0, .T. } )//"Pesquisar"
aAdd( aRotina, { STR0004, 'VIEWDEF.PLSA201', 0, 2, 0, NIL } )//"Visualizar"
aAdd( aRotina, { STR0005, 'VIEWDEF.PLSA201', 0, 3, 0, NIL } )//"Incluir"
aAdd( aRotina, { STR0006, 'VIEWDEF.PLSA201', 0, 4, 0, NIL } )//"Alterar"
aAdd( aRotina, { STR0007, 'VIEWDEF.PLSA201', 0, 5, 0, NIL } )//"Excluir"

Return aRotina
//-------------------------------------------------------------------

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oModel // Modelo de dados construído
Local oStruBJ4 := FWFormStruct( 1, 'BJ4')//Estrutura da Tabela

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( STR0001,/*bPreValidacao*/,{||Restore()})//"Procedimentos Incompatíveis"

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'BJ4MASTER', /*cOwner*/, oStruBJ4)
// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 )//"Procedimentos Incompatíveis"
// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'BJ4MASTER' ):SetDescription( STR0001 )//"Procedimentos Incompatíveis"
// Adiciona a Chave Primária no Modelo
oModel:SetPrimaryKey( { "BJ4_FILIAL" , "BJ4_CODIGO" , "BJ4_CODPAD" , "BJ4_CODPSA" } )

Return oModel
//-------------------------------------------------------------------

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oViewModel	:= FWLoadModel( 'PLSA201' )
Local oView		:= FWFormView():New()
Local oStruBJ4	:= FWFormStruct( 2, 'BJ4', {|cCampo| PLSABJ4201(cCampo)} )

//Salva a Chave da BR8
oView:SetViewCanActivate({||Restore('1')})

// Define qual o Modelo de dados será utilizado
oView:SetModel( oViewModel )

//Adiciona controle do tipo FormFields no View
oView:AddField( 'VIEW_BJ4', oStruBJ4, 'BJ4MASTER' )

// Criar um box horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_BJ4', 'TELA' )

oView:SetAfterOkButton({|| Restore()})

Return oView
//-------------------------------------------------------------------

//-------------------------------------------------------------------
Static Function LoadHelp()

PutHelp("PPLMVBJ4001",{STR0008,"",""},{},{},.F.)//"Procedimento incompatível já cadastrado"
PutHelp("SPLMVBJ4001",{STR0009,"",""},{},{},.F.)//"Informe outro código"

PutHelp("PPLMVBJ4002",{STR0010,"",""},{},{},.F.)//"Procedimento não encontrado na Tabela Padrão"
PutHelp("SPLMVBJ4002",{STR0011,"",""},{},{},.F.)//"Informe outro código"

Return
//-------------------------------------------------------------------

//-------------------------------------------------------------------
Static Function Restore(cSave)
Default cSave:= '0'

if ( type("cChvBR8") == "C")
	If cSave = '1'
		cChvBR8 := BR8->(BR8_CODPAD+BR8_CODPSA)
	Else
		//Recupera o Registro apos acionar a Consulta Padrão da BR8
		BR8->(DbSetOrder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
		BR8->(MsSeek(xFilial("BR8")+cChvBR8))
	EndIf
endif

Return .T.
//-------------------------------------------------------------------