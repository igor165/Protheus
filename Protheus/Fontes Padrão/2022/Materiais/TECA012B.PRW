#include "TECA012B.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Function TECA012B()

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Relacionamentos - restrição de cadastro operacional por local de atendimento 

@Return 	model
@author 	Serviços
@since 		30/09/2015
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local oStrABS 	:= FWFormStruct(1,"ABS")
Local oStrTW2 	:= FWFormStruct(1,"TW2")

oModel := MPFormModel():New("TECA012B", /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )
oModel:AddFields("ABSMASTER",/*cOwner*/,oStrABS, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//restricoes cliente
oModel:AddGrid( "TW2DETAIL", "ABSMASTER", oStrTW2,/*bLinePre*/,{|oModel| At012BVlAg(oModel)},/*bPreVal*/ ,/*bPosVal*/ , /*bLoad */ )
oModel:SetRelation( "TW2DETAIL", { { "TW2_FILIAL", "xFilial('TW2')" }, { "TW2_LOCAL", "ABS_LOCAL"} }, TW2->(IndexKey(1)) )
oModel:SetDescription(STR0001) //"Loal de atendimento"

oStrABS:SetProperty('*', MODEL_FIELD_OBRIGAT , .F. )
oStrTW2:SetProperty('TW2_CODTEC', MODEL_FIELD_OBRIGAT , .F. )
oStrTW2:SetProperty('TW2_TIPO', MODEL_FIELD_INIT , {|| "2" } )
oStrTW2:SetProperty('TW2_NOME', MODEL_FIELD_INIT , {|| Posicione("AA1",1,xFilial("AA1")+TW2->TW2_CODTEC,"AA1_NOMTEC") } )

//validacao data
oStrTW2:SetProperty("TW2_DTINI", MODEL_FIELD_VALID, {|oModel| At012BVlDt("TW2DETAIL","TW2_DTFIM","TW2_DTINI","TW2_DTFIM") } )
oStrTW2:SetProperty("TW2_DTFIM", MODEL_FIELD_VALID, {|oModel| At012BVlDt("TW2DETAIL","TW2_DTFIM","TW2_DTINI","TW2_DTFIM") } )

oModel:GetModel('TW2DETAIL'):SetOptional(.T.)

Return(oModel)

//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Relacionamentos - Restrição de cadastro operacional por cliente 

@Return 	view
@author 	Serviços
@since 		30/09/2015
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel  := FWLoadModel("TECA012B")  
Local oStrABS := FWFormStruct( 2, "ABS" , {|cCpo|  AllTrim(cCpo)$'ABS_LOCAL+ABS_DESCRI' }  )
Local oStrTW2 := FWFormStruct( 2, "TW2" , {|cCpo| !AllTrim(cCpo)$'TW2_COD+TW2_TIPO+TW2_LOCAL+TW2_DESLOC+TW2_CLIENT+TW2_LOJA+TW2_NOMCLI' } )

oStrABS:SetNoFolder()

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField( 'VIEW_ABS' , oStrABS, 'ABSMASTER' )
oView:AddGrid ( 'VIEW_TW2' , oStrTW2, 'TW2DETAIL' )

oView:CreateHorizontalBox('SUPERIOR', 10 ) //local de atendimento
oView:CreateHorizontalBox('INFERIOR', 90 ) //atendente

oView:SetOwnerView( 'VIEW_ABS' , 'SUPERIOR' ) 
oView:SetOwnerView( 'VIEW_TW2' , 'INFERIOR' )	// Grid atendente

oStrABS:SetProperty( "*"	, MVC_VIEW_CANCHANGE	, .F.  )

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} At012BVlDt
Função para validação dos períodos iniciais e finais das restrições.

@sample 	At012AVlDt(cModelo,cCpoSelec,cCpoDtIn,cCpoDtFm)

@since		30/09/2015      
@version	P12

@return 	lRet, Lógico, retorna .T. se data for válida.

@param  	oModel, Objeto, Model utilizado para a consistencia das informações.
@param  	cModelo, Caracter, nome do modelo de dados principal.
@param  	cCpoSelec, Caracter, nome do campo da data selecionada para validação.
@param  	cCpoDtIn, Caracter, nome do campo da data inicial.
@param  	cCpoDtFm, Caracter, nome do campo da data final.
/*/
//------------------------------------------------------------------------------
Function At012BVlDt(cModelo,cCpoSelec,cCpoDtIni,cCpoDtFim)

Local oModel  := FwModelActive()
Local oMdl		:= oModel:GetModel(cModelo)
Local lRet		:= .F.

If  oMdl:GetValue('TW2_TEMPO') == '2' //contrato determinado
	If !Empty(oMdl:GetValue('TW2_DTFIM'))
		If DtoS(oMdl:GetValue(cCpoDtIni)) <= DtoS(oMdl:GetValue(cCpoDtFim))  		
			lRet := .T.
		EndIf
	Else
		lRet:= .F.				
	Endif
Elseif oMdl:GetValue('TW2_TEMPO') == '1' //contrato indeterminado
	If !Empty(oMdl:GetValue('TW2_DTFIM'))
		Help(,,"AT012BVLDDT",,STR0002,1,0) //"Para contratos indeterminados, deixar a data final em branco"
		lRet := .F.
	Else
		lRet := .T.
	Endif	
EndIf

If !lRet
	Help(,,"AT012BVLDDT",,STR0003,1,0) // "Data final deve ser maior ou igual a data inicail da restrição para contratos determinados!"
Endif

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At012BVlAg(oModel)
Função para validação da linha digitada para verificar se existe agenda para o atendente

@sample 	At012AVlAg(oModel)

@since		01/10/2015      
@version	P12

@return 	lRet, Lógico, retorna .T. se nao existir agenda futura.
/*/
//------------------------------------------------------------------------------
Function At012BVlAg(oModel)

Local lRet:= .F.
Local oMdlABS:= oModel:GetModel("ABSMASTER")
Local cCodTec:=""
Local dDtIni:=""
Local dDtFim:=""
Local lOk:= .F.  
Local cTempo:=""

cCodTec:=FWFLDGET("TW2_CODTEC")
dDtIni:=FWFLDGET("TW2_DTINI")
dDtFim:=FWFLDGET("TW2_DTFIM")
tmpAgenda:=GetNextAlias()

If Empty(cCodTec)
		Help(,,"AT012BVLATE",,STR0004,1,0) // "Favor informar o codigo de atendente."	
		lOk:= .F.
Else
	lOk:= .T.
Endif
If FWFLDGET("TW2_TEMPO") == '2' //contrato determinado
	If Empty(FWFLDGET("TW2_DTFIM"))
		Help(,,"AT012BDTFIM",,STR0006,1,0) // "Para contratos determinados, preencher a data final."
		lOk:= .F.
	Endif
Else
	lOk:= .T.
Endif
If lOk
	//verificar a agenda da atendente do registro na tabela ABB por cliente
	If !empty(dDtFim)
		cTempo := "%AND ABB_DTFIM <='"+ DtoS(dDtFim) + "'%"
	Else
		cTempo := '%%'
	Endif
	BeginSql Alias tmpAgenda
	SELECT count(*) as regABB
	FROM %table:ABB% ABB
	WHERE	ABB_FILIAL = %xFilial:ABB%
		AND ABB_LOCAL = %Exp:FWFLDGET("ABS_LOCAL")%
		AND ABB_ATIVO ='1' AND ABB_ATENDE ='2'
		AND ABB_CODTEC = %Exp:cCodTec%
		AND ABB_DTINI >=  %Exp:dDtIni%
		AND ABB.%NotDel%
	EndSql
	DbSelectArea(tmpAgenda)
	If (tmpAgenda)->regABB > 0 //existe agenda posterior atendida ou com manutenção 
		Help(,,"AT012BVLDAGE",,STR0005,1,0) // "Atendente com alocação no período de restrição."
	Else
		lRet:= .T.	
	Endif
Endif

Return lRet