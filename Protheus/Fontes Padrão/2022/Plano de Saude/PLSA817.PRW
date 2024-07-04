#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "PLSMGER.CH"
#include "PLSMCCR.CH"
#Include 'PLSA817.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA817
Funcao para abrir cadastro de tipo de classificação
@author TOTVS
@since 30/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA817()
Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('B7K')
	oBrowse:SetDescription(STR0001)//"Solicitações de Visita Institucional"
	
	//Adiciona Legenda
	oBrowse:AddLegend( "PLS817LEGE()=='0'"	, "YELLOW"	, STR0007)
	oBrowse:AddLegend( "PLS817LEGE()=='1'"	, "RED"	, STR0008)
	oBrowse:AddLegend( "PLS817LEGE()=='2'"	, "GREEN"	, STR0009)
	
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author TOTVS	
@since 29/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	Add Option aRotina Title 'Visualizar' Action 'VIEWDEF.PLSA817' Operation 2 Access 0
	Add Option aRotina Title 'Alterar'    Action 'VIEWDEF.PLSA817' Operation 4 Access 0
	Add Option aRotina Title 'Imprimir'   Action 'VIEWDEF.PLSA817' Operation 8 Access 0
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author TOTVS	
@since 29/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB7K:= FWFormStruct(1,'B7K')

	oModel := MPFormModel():New( 'PLSA817', , {|| PLSA817OK(oModel) } )
	oModel:addFields('MasterB7K',/*cOwner*/,oStrB7K)
	oModel:getModel('MasterB7K')
	oModel:SetDescription(Fundesc())
	oModel:SetPrimaryKey({"B7K_FILIAL","B7K_CODINT", "B7K_CODRDA"})

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author TOTVS
@since 29/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrB7K:= FWFormStruct(2, 'B7K', { |cCampo| PLSA817VI(cCampo) })

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FrmB7K' , oStrB7K,'MasterB7K' ) 
	oView:CreateHorizontalBox( 'BxB7K', 100)
	oView:SetOwnerView('FrmB7K','BxB7K')
	
Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc} PLS817LEGE
Definição da Legenda a ser apresentada
@author TOTVS
@since 29/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Function PLS817LEGE()
Local cRet
cRet := B7K_DEFERE
Return cRet




//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA817VI
Tratamento para definir os campos da B7K que não serão usados na View
@author TOTVS
@since 19/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA817VI (cCampo)
Local lRet	:= .T.
cCampo := Alltrim(cCampo)

If cCampo == "B7K_CODINT" 
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA817OK
Validar botão confirmar
@author TOTVS
@since 12/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA817OK(oModel)
LOCAL lRet     		:= .T.
LOCAL oModelMaster	:= oModel:GetModel( 'MasterB7K' )
LOCAL nOpc				:= oModel:GetOperation()
Local cConfirma      := oModelMaster:GetValue('B7K_DEFERE')
Local cDtAgenda 	    := oModelMaster:GetValue('B7K_DATAGE')
Local cHrAgenda		:= oModelMaster:GetValue('B7K_HORAGE')

If !Empty(cConfirma) .And. !Empty(cDtAgenda) .And. !Empty(cHrAgenda)
	//Verifica se o agendamento foi confirmado para enviar o email
	If (MsgYesNo(STR0002))//"Deseja enviar e-mail para o solicitante agora ?"
		If nOpc == 4// Alteração
			If cConfirma == "1"//Não confirmado 
				PL817Email("1")
			Else
			  If cConfirma == "2"//Confirma
		      	 PL817Email("2")
		      Endif	
			Endif
		Endif		
	Endif
Endif

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Carregar a descricao do motivo porque via SX3 nao cabe o tamanho
do Posicione por causa do alltrim
@author TOTVS
@since 12/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL817Motivo()
Local cDescricao := ""

B9L->(DBSelectARea("B9L"))
B9L->(DBSetOrder(2))
If B9L->(MsSeek(xFilial("B9L")+alltrim(B7K->B7K_MOTVIS)+B7K->B7K_CODINT))	
	cDescricao := B9L->B9L_DESVIS
Endif

Return cDescricao		 


//-------------------------------------------------------------------------------
/*/{Protheus.doc} PL817Envia Email 
Função para enviar email de confirmação de solicitação da visita institucional 
@author TOTVS
@since 20/08/2015
@version P12
/*/
//-------------------------------------------------------------------------------
Function PL817Email(cTipo)
Local cMsgPad	    := ""
Local cEmail      := ""
Local cAlert      := "" 
Local lRet        := .T.
//PLSA817 é o codigo do Layout Generico e usado no campo Rotina do cadastrado de Sinalizador. 
Local cFuncao     := Left( "PLSA817" + Space( TamSX3("BOJ_ROTINA")[1] ), TamSX3("BOJ_ROTINA")[1] )
Local cDestino    := AllTrim(GetNewPar("MV_817EMAI"," "))//e-mail dos analistas que receberão a solicitacao
Local cMsg        := "" 

If cTipo == "1"//Reprovado
	cMsgPad := STR0003// "Reprovação de Solicitação de Agendamento de Visita Institucional"
	cAlert += cMsgPad + chr(13) + chr(10)
	cEmail += cMsgPad + "<br />"
		
	BOJ->(DbSetOrder(3))
	If BOJ->(MsSeek(xFilial("BOJ") + cFuncao + "03"))
		If !(Empty(Alltrim(B7K->B7K_MAILSL)))
			PLSinaliza(BOJ->BOJ_CODSIN,,,cDestino, STR0004,,,,,,,B7K->B7K_MAILSL,,"000002",)//"Visita institucional"
			lRet := .T.
		Else
			cMsg := STR0005//"Não será possivel enviar o email para o solicitante, pois o campo e-mail está vazio! Acesse a rotina de Rede de Atendimento, dados cadastrais para preencher!"
			Help( ,, 'HELP',, cMsg, 1, 0)
			lRet := .F.
		EndIf		
	EndIf
else
	If cTipo == "2" //Aprovado
		cMsgPad := STR0006//"Confirmação de Agendamento de Visita Institucional"
		cAlert += cMsgPad + chr(13) + chr(10)
		cEmail += cMsgPad + "<br />"
		
		BOJ->(DbSetOrder(3))
		If BOJ->(MsSeek(xFilial("BOJ") + cFuncao + "01"))
			If !(Empty(Alltrim(B7K->B7K_MAILSL)))
				PLSinaliza(BOJ->BOJ_CODSIN,,,cDestino, STR0004,,,,,,,B7K->B7K_MAILSL,,"000002",)//"Visita institucional"
				lRet := .T.
			Else
		   		cMsg := STR0005//"Não será possivel enviar o email para o solicitante, pois o campo e-mail está vazio! Acesse a rotina de Rede de Atendimento, dados cadastrais para preencher!"
				Help( ,, 'HELP',, cMsg, 1, 0)
				lRet := .F.
			EndIf		
		EndIf
	Endif	
Endif
		
Return lRet
                                                                 
                                                                 
                                                                 