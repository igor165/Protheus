#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' //Necessita desse include quando usar MVC.
#include "PLSA444.CH"
#include "PLSA449.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA449
Rotina de manutenção de itens da terminologia

@author Francisco Edcarlo
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA449(cCodTab)

Local oBrwBTQ
Local aArea   := GetArea()

oBrwBTQ := FWMBrowse():New()
oBrwBTQ:SetFilterDefault("@BTQ_FILIAL = '"+xFilial("BTQ")+"' AND BTQ_CODTAB = '"+cCodTab+"'" )
oBrwBTQ:SetAlias('BTQ')	
oBrwBTQ:SetMenuDef('PLSA449')
oBrwBTQ:SetMainProc('PLSA449')
oBrwBTQ:SetDescription(STR0046) //"ITENS DA TERMINOLOGIA"
oBrwBTQ:Activate()

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA449
Definição de Menu da aplicação

@author Francisco Edcarlo
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002		Action 'VIEWDEF.PLSA449' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 		Action 'VIEWDEF.PLSA449' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 		Action 'VIEWDEF.PLSA449' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0007 		Action 'VIEWDEF.PLSA449' OPERATION 5 ACCESS 0 //'Excluir'

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA449
Define o modelo de dados da aplicação

@author Francisco Edcarlo
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruBTQ := FWFormStruct( 1, 'BTQ' )
Local aAux := {}
Local oModel		:= Nil // Modelo de dados construído

oStruBTQ:SetProperty( 'BTQ_CODTAB', MODEL_FIELD_INIT, { || BTP->BTP_CODTAB } )
oStruBTQ:SetProperty( 'BTQ_CDTERM', MODEL_FIELD_NOUPD, .T. )

oModel := MPFormModel():New( 'PLSA449', /*bPreValidacao*/, {|oModel| P449VLD(oModel) } , , /*bCancel*/ )
oModel:AddFields( 'BTQMASTER', /*cOwner*/, oStruBTQ )
oModel:SetDescription( STR0046 ) //"Itens da Terminologia"
oModel:GetModel( 'BTQMASTER' ):SetDescription( STR0011 ) //'Cabeçalho do Termo'

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA449
Define o modelo de dados da aplicação

@author Francisco Edcarlo
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= FWLoadModel( 'PLSA449' )
Local oStruBTQ 	:= FWFormStruct( 2, 'BTQ' )
Local oView
Local aArea      := GetArea()

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_BTQ', oStruBTQ, 'BTQMASTER' )

RestArea( aArea )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} P449VLD
Validação do model

@author Lucas Nonato
@since 06/2019
@version P12
/*/
function P449VLD(oModel)
local lRet := .t.
Local cQuery  := ""
Local nRecno  := BTQ->(Recno())
local oMaster	:= oModel:getModel("BTQMASTER")

cQuery  := " SELECT  BTQ_CODTAB, BTQ_CDTERM, BTQ_VIGDE, BTQ_VIGATE, BTQ.R_E_C_N_O_ AS REC "
cQuery  += " FROM "
cQuery  +=  RetSqlName("BTQ")+ " BTQ "
cQuery  += " WHERE "
cQuery  += "     BTQ.BTQ_FILIAL = '" + xFilial("BTQ") + "' "
cQuery  += " AND BTQ.BTQ_CODTAB = '" + oMaster:getvalue("BTQ_CODTAB") + "' "
cQuery  += " AND BTQ.BTQ_CDTERM = '" + oMaster:getvalue("BTQ_CDTERM") + "' "
cQuery += "  AND BTQ.D_E_L_E_T_ =' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBBTQ",.T.,.T.)

if oModel:GetOperation() == MODEL_OPERATION_INSERT
	
	//Validação - Vigência Inicial maior que Final.
	If !oMaster:getvalue("BTQ_VIGDE") == STOD(" / / ") .And. !oMaster:getvalue("BTQ_VIGATE") == STOD(" / / ") .And. oMaster:getvalue("BTQ_VIGDE") > oMaster:getvalue("BTQ_VIGATE")
		Aviso(STR0049,STR0050,{STR0019},2) //"Vigência Inicial"###"A vigência inicial deve ser menor ou igual a vigência final."###"Ok"
		lRet := .F.
		TRBBTQ->(dbCloseArea())
		Return .F.
	EndIf
	
	TRBBTQ->(dbGoTop())

	While TRBBTQ->(!EOF())
		
		//Validação - Vigência Inicial entre um período de outro registro.
		If !oMaster:getvalue("BTQ_VIGDE") == STOD(" / / ")
			If oMaster:getvalue("BTQ_VIGDE") >= STOD(TRBBTQ->BTQ_VIGDE) .And. ( oMaster:getvalue("BTQ_VIGDE") <= STOD(TRBBTQ->BTQ_VIGATE) .Or. Empty(TRBBTQ->BTQ_VIGATE) )
				Aviso(STR0049,STR0051,{STR0019},2) //"Vigência Inicial"###"A Data Incial da Nova Vigência Precisa ser Maior que a Data Final da Ultima Vigência!"###"Ok"
				lRet := .F.
				TRBBTQ->(dbCloseArea())
				Return .F.
			EndIf
		EndIf
		
		//Validação - Vigência Final entre um período de outro registro.
		If !(oMaster:getvalue("BTQ_VIGATE") == STOD(" / / "))
			If oMaster:getvalue("BTQ_VIGATE") >= StoD(TRBBTQ->BTQ_VIGDE) .And. ( oMaster:getvalue("BTQ_VIGATE") <= StoD(TRBBTQ->BTQ_VIGATE) .Or. Empty(TRBBTQ->BTQ_VIGATE) )
				Aviso(STR0052,STR0053,{STR0019},2) //"Vigência Informada"###"Já existe um intervalo de data que compreende a data selecionada!"###"Ok"
				lRet := .F.
				TRBBTQ->(dbCloseArea())
				Return .F.
			EndIf
		EndIf

		//Validação - Vigência Inicial menor que a vigência inicial de outro registro e a Vigência Final maior que a vigência Final de outro registro.
		If !(oMaster:getvalue("BTQ_VIGDE") == STOD(" / / ") .And. oMaster:getvalue("BTQ_VIGATE") == STOD(" / / "))
			If !Empty(TRBBTQ->BTQ_VIGATE) .And. oMaster:getvalue("BTQ_VIGDE") < StoD(TRBBTQ->BTQ_VIGDE) .And. oMaster:getvalue("BTQ_VIGATE") > StoD(TRBBTQ->BTQ_VIGATE)
				Aviso(STR0052,STR0053,{STR0019},2) //"Vigência Informada"###"Já existe um intervalo de data que compreende a data selecionada!"###"Ok"
				lRet := .F.
				TRBBTQ->(dbCloseArea())
				Return .F.
			EndIf
		EndIf
		
		If !oMaster:getvalue("BTQ_VIGDE") == STOD(" / / ")
			If !Empty(TRBBTQ->BTQ_VIGDE) .And. Empty(TRBBTQ->BTQ_VIGATE) .And.;
				( oMaster:getvalue("BTQ_VIGATE") == STOD(" / / ") .Or. oMaster:getvalue("BTQ_VIGATE") >= StoD(TRBBTQ->BTQ_VIGDE) )  
				Aviso(STR0054,STR0055,{STR0019},2) //"Vigência em Aberto"###"Já existe uma Vigência em Aberto!"###"Ok"
				lRet := .F.
				TRBBTQ->(dbCloseArea())
				Return .F.
			Endif
		EndIf
		
		TRBBTQ->(dbSkip())
	EndDo

	BTQ->(DbSetOrder(2)) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM+DTOS(BTQ_VIGDE)                                                                                                                
	if !BTQ->(msseek(xFilial("BTQ")+oMaster:getvalue("BTQ_CODTAB")+oMaster:getvalue("BTQ_CDTERM")+DToS(oMaster:getvalue("BTQ_VIGDE")) ))		
		lRet := .t.
	else
		Help( ,, 'HELP',,  "Item ["+alltrim(oMaster:getvalue("BTQ_CDTERM"))+"] já cadastrado, informe outro código.", 1, 0) 
		lRet := .f.
	endif

ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
	
	//Validação - Vigência Inicial maior que Final.
	If !oMaster:getvalue("BTQ_VIGDE") == STOD(" / / ") .And. !oMaster:getvalue("BTQ_VIGATE") == STOD(" / / ") .And. oMaster:getvalue("BTQ_VIGDE") > oMaster:getvalue("BTQ_VIGATE")
		Aviso(STR0049,STR0050,{STR0019},2) //"Vigência Inicial"###"A vigência inicial deve ser menor ou igual a vigência final."###"Ok"
		lRet := .F.
		TRBBTQ->(dbCloseArea())
		Return .F.
	EndIf
	
	TRBBTQ->(dbGoTop())
	While TRBBTQ->(!EOF())
		
		//Validação - Vigência Inicial entre um período de outro registro.
		If !oMaster:getvalue("BTQ_VIGDE") == STOD(" / / ") .And. REC <> nRecno
			If oMaster:getvalue("BTQ_VIGDE") >= STOD(TRBBTQ->BTQ_VIGDE) .And. ( oMaster:getvalue("BTQ_VIGDE") <= STOD(TRBBTQ->BTQ_VIGATE) .Or. Empty(TRBBTQ->BTQ_VIGATE) )
				Aviso(STR0049,STR0051,{STR0019},2) //"Vigência Inicial"###"A Data Incial da Nova Vigência Precisa ser Maior que a Data Final da Ultima Vigência!"###"Ok"
				lRet := .F.
				TRBBTQ->(dbCloseArea())
				Return .F.
			EndIf
		EndIf
		
		//Validação - Vigência Final entre um período de outro registro.
		If !(oMaster:getvalue("BTQ_VIGATE") == STOD(" / / ")) .And. REC <> nRecno
			If oMaster:getvalue("BTQ_VIGATE") >= StoD(TRBBTQ->BTQ_VIGDE) .And. ( oMaster:getvalue("BTQ_VIGATE") <= StoD(TRBBTQ->BTQ_VIGATE) .Or. Empty(TRBBTQ->BTQ_VIGATE) )
				Aviso(STR0052,STR0053,{STR0019},2) //"Vigência Informada"###"Já existe um intervalo de data que compreende a data selecionada!"###"Ok"
				lRet := .F.
				TRBBTQ->(dbCloseArea())
				Return .F.
			EndIf
		EndIf
		
		//Validação - Vigência Inicial menor que a vigência inicial de outro registro e a Vigência Final maior que a vigência Final de outro registro.
		If !(oMaster:getvalue("BTQ_VIGDE") == STOD(" / / ") .And. oMaster:getvalue("BTQ_VIGATE") == STOD(" / / ")) .And. REC <> nRecno
			If !Empty(TRBBTQ->BTQ_VIGATE) .And. oMaster:getvalue("BTQ_VIGDE") < StoD(TRBBTQ->BTQ_VIGDE) .And. oMaster:getvalue("BTQ_VIGATE") > StoD(TRBBTQ->BTQ_VIGATE)
				Aviso(STR0052,STR0053,{STR0019},2) //"Vigência Informada"###"Já existe um intervalo de data que compreende a data selecionada!"###"Ok"
				lRet := .F.
				TRBBTQ->(dbCloseArea())
				Return .F.
			EndIf
		EndIf
		
		If !oMaster:getvalue("BTQ_VIGDE") == STOD(" / / ") .And. REC <> nRecno 
			If !Empty(TRBBTQ->BTQ_VIGDE) .And. Empty(TRBBTQ->BTQ_VIGATE) .And.;
				( oMaster:getvalue("BTQ_VIGATE") == STOD(" / / ") .Or. oMaster:getvalue("BTQ_VIGATE") >= StoD(TRBBTQ->BTQ_VIGDE) )  
				Aviso(STR0054,STR0055,{STR0019},2) //"Vigência em Aberto"###"Já existe uma Vigência em Aberto!"###"Ok"
				lRet := .F.
				TRBBTQ->(dbCloseArea())
				Return .F.
			Endif
		EndIf
		
		TRBBTQ->(dbSkip())
	EndDo

endif

If Select("TRBBTQ") > 0
	TRBBTQ->( DbcloseArea())
EndIf

return lRet
