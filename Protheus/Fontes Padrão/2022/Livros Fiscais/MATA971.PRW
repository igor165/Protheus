#INCLUDE "MATA971.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATA971   ºAutor  ³Mary C. Hergert     º Data ³  11/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cadastro das classes de consumo de energia eletrica, gas,   º±±
±±º          ³e agua.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaFis                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA971()

Local oBrowse

ChkFile("CC5")

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CC5')
oBrowse:SetDescription(STR0001)
oBrowse:DisableDetails()
oBrowse:Activate()


Return .T.

//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}
ADD OPTION aRotina Title "Pesquisar" Action 'PesqBrw'          OPERATION 1 ACCESS 0 //Pesquisar
ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.MATA971'  OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina Title "Incluir" Action 'VIEWDEF.MATA971'  OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina Title "Alterar" Action 'VIEWDEF.MATA971'  OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina Title "Excluir" Action 'VIEWDEF.MATA971'  OPERATION 5 ACCESS 0 //Excluir

Return aRotina

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ModelDef  ³ Autor ³Erich Buttner   ³ Data ³ 18/06/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modelod de dados                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oModel
Local oStruCC5

AjuCMP()

oStruCC5 := FWFormStruct( 1, "CC5")

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('MATA971', /*bPreValidacao*/, {|oModel| MT971VlMd(oModel)},  /*bCommit*/, /*bCancel*/ )

oStruCC5:SetProperty('CC5_DTINIC', MODEL_FIELD_WHEN, {|| oModel:GetOperation() == MODEL_OPERATION_INSERT })
oStruCC5:SetProperty('CC5_DTFINA', MODEL_FIELD_WHEN, {|| oModel:GetOperation() == MODEL_OPERATION_INSERT })

// Adiciona ao modelo uma estrutura de formul?rio de edi??o por campo
oModel:AddFields( 'CC5MASTER', /* cOwner */, oStruCC5)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:SetDescription(STR0001)
oModel:GetModel( 'CC5MASTER' ):SetDescription( STR0001 )

Return oModel

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ModelDef  ³ Autor ³Autor ³Erich Buttner   ³ Data ³ 18/06/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modelod de Tela                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'MATA971' )
Local oStruCC5 := FWFormStruct( 2, 'CC5')

Local oView

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_CC5",oStruCC5,"CC5MASTER")

Return oView

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF005VlMd  ³ Autor ³Erich Buttner   ³ Data ³ 18/06/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validação do Modelo de dados                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MT971VlMd(oModel)

Local lRet   := .T.
Local cCod   := oModel:GetValue('CC5MASTER',"CC5_CODIGO")
Local cTp    := oModel:GetValue('CC5MASTER',"CC5_TIPO")
Local dDtIni := oModel:GetValue('CC5MASTER',"CC5_DTINIC")
Local dDtFim := oModel:GetValue('CC5MASTER',"CC5_DTFINA")
Local nOper  := oModel:GetOperation()

If nOper == MODEL_OPERATION_INSERT   

	If ((Empty(dDtIni) .and. !Empty(dDtFim)) .or. (Empty(dDtFim) .and. !Empty(dDtIni)))
		Help(" ", 1, "DTOBRIG")
		Return .F.
	EndIf

	If dDtIni > dDtFim
		Help(" ", 1, "DTVALID")
		Return .F. 
	EndIf

	If CC5->(dbSeek(xFilial("CC5")+cTp+cCod+DTOS(dDtIni)+DTOS(dDtFim)))	
		Help(" ", 1, "JAGRAVADO")
		Return .F.
	EndIf
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg
 
Função que irá criar O SX1 complementar do Relatorio
 
@author Erich Buttner
@since 12/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

Static Function AjuCMP()
Local aDados := {}

If FindFunction("EngSX3117")

	aAdd( aDados, { { 'CC5_DTINIC' 	}, { { 'X3_USADO'	, '€€€€€€€€€€€€€€ ' } } } )
	aAdd( aDados, { { 'CC5_DTFINA' 	}, { { 'X3_USADO'	, '€€€€€€€€€€€€€€ ' } } } )

	EngSX3117( aDados )

EndIf

Return