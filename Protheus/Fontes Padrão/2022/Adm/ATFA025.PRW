#INCLUDE "PROTHEUS.CH"
#INCLUDE "ATFA025.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA025   ºAutor  ³Marcos R. Pires     º Data ³  12/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de Locais                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Atfa025()

Private oBrowse := BrowseDef()

oBrowse:Activate()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  BrowseDef   ºAutor  ³Marcos R. Pires     º Data ³  12/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de Locais                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias('SNL')
	oBrowse:SetDescripton(STR0001)  // "Cadastro de PIB Estadual pata metas anuais"

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 22/03/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruSNL := FWFormStruct(1,'SNL')
Local oModel

oModel := MPFormModel():New("ATFA025", /*bPreValid*/, { |oModel|PosVldATF025(oModel) } , /*bCommitPos*/, /*bCancel*/)

oStruSNL:SetProperty('NL_CODIGO',MODEL_FIELD_WHEN,{|oModel|INCLUI})
oStruSNL:SetProperty('NL_TIPOLOC',MODEL_FIELD_WHEN,{|oModel|INCLUI})

// Adiciona a descrição do modelo de dados.
oModel:SetDescription(STR0001)  //

//Adiciona ao modelo um componente de formulário
oModel:AddFields('SNLMASTER', /*cOwner*/, oStruSNL, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)

//Adiciona a descrição do Componente do Modelo de Dados
oModel:GetModel('SNLMASTER'):SetDescription(STR0001)

// Configura chave primaria.
oModel:SetPrimaryKey({"NL_FILIAL", "NL_CODIGO"})


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela da Rotina
Cadastro de PIB Estadual pata metas anuais
@author TOTVS
@since 22/03/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel    := FWLoadModel('ATFA025')

Local oStructSNL   := FWFormStruct(2, 'SNL')

Local oView := FWFormView():New()

oView:SetModel(oModel)

oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulario (antiga enchoice).
oView:AddField('VIEW_SNL', oStructSNL, 'SNLMASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibicao.
oView:SetOwnerView('VIEW_SNL', 'SUPERIOR')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PosVldATF025
Pós-validação ATFA025
@author TOTVS
@since 22/03/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function PosVldATF025(oModel)

Local lRet := .T.
Local nOper := oModel:GetOperation()

Do Case 
	Case nOper == MODEL_OPERATION_INSERT 
		lRet := AF025Inc(oModel)		
 	Case nOper == MODEL_OPERATION_UPDATE
		lRet := AF025Alt()
 	Case nOper == MODEL_OPERATION_DELETE
		lRet := AF025VldEx()

EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF025Inc
Pós-validação ATFA025
@author TOTVS
@since 22/03/2021
@version P12
/*/
//-------------------------------------------------------------------

Static Function AF025Inc(oModel)
Local lRet := .T.

If ExistCPO("SNL", oModel:GetValue("SNLMASTER", "NL_CODIGO"))
		HELP(' ',1,"JAEXST" ,,STR0011,1,0)//"Já existe uma dedução de receita neste ano com esta conta "
		lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF025VldEx ºAutor  ³Marcos R. Pires    º Data ³  12/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao na exclusao do cadastro de locais.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF025VldEx()

Local lRet			:= .T.
Local aSaveArea		:= GetArea()
Local aSaveSN1		:= SN1->(GetArea())
Local nRegDel		:= SNL->(RECNO())

dbSelectArea("SN1")
dbSetOrder(1) //N1_FILIAL+N1_CBASE+N1_ITEM
dbSeek(xFilial("SN1"))

While ( SN1->(!Eof()) ) .And. ( SN1->N1_FILIAL == xFilial( "SN1" ) )
	If ( Alltrim(SN1->N1_LOCAL) == Alltrim(SNL->NL_CODIGO) )
		lRet := .F.
		Help( " ", 1, "AF025VldEx", , STR0002, 1, 0 ) 	//"Nao e possivel excluir Local associado a um Bem."
		Exit
	EndIf
	SN1->(dbSkip())
EndDo

RestArea(aSaveSN1)
RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF025Alt ºAutor  ³André Brito       º Data ³  08/10/13      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao na alteração do cadastro de locais.              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAATF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Function AF025Alt()

Local lRet      := .T.
Local cQuery 	 := ""
Local cCod      := SNL->NL_CODIGO
Local aSaveArea := GetArea() 
Local aCpos		:= {"NL_DESCRIC", "NL_BLOQ"}
Local nReg		:= SNL->(RECNO())

If M->NL_BLOQ == "1"
	cQuery += " UPDATE " +RetSQLName( "SN1" )+ " SET N1_STATUS = 3"                                             
	cQuery += " WHERE  N1_FILIAL = '" + xFilial("SN1") + "'"
	cQuery += " AND N1_LOCAL ='"+ cCod +"'"
	cQuery += " AND D_E_L_E_T_ = ' ' "  
ElseIf M->NL_BLOQ == "2"
	cQuery += " UPDATE " +RetSQLName( "SN1" )+ " SET N1_STATUS = 1"                                             
	cQuery += " WHERE  N1_FILIAL = '" + xFilial("SN1") +"'"
	cQuery += " AND N1_LOCAL ='"+ cCod +"'"
	cQuery += " AND D_E_L_E_T_ = ' ' "  
EndIf 

If (TCSQLExec(cQuery) < 0)
	MsgAlert(STR0004 + TCSQLError())
EndIf

RestArea(aSaveArea)	
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author TOTVS
@since 22/03/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0005 	Action 'VIEWDEF.ATFA025' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0006 	Action 'VIEWDEF.ATFA025' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0007 	Action 'VIEWDEF.ATFA025' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0008	Action 'VIEWDEF.ATFA025' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina Title STR0009	Action 'VIEWDEF.ATFA025' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0010	Action 'VIEWDEF.ATFA025' OPERATION 9 ACCESS 0 //"Copiar"

Return aRotina
