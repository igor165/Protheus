#include "TECA012.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

PUBLISH MODEL REST NAME TECA012 source TECA012

Function TECA012()

Local oMBrowse

oMBrowse:= FWmBrowse():New() 
oMBrowse:SetAlias("AA1")
oMBrowse:SetDescription(STR0001)   // "Cadastro de Restrições"
oMBrowse:Activate()
	
Return

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Relacionamentos - restrição de cadastro operacional 

@Return 	model
@author 	Serviços
@since 		28/09/2015
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local oStrAA1 	:= FWFormStruct(1,"AA1")
Local oStrTW2Cli 	:= FWFormStruct(1,"TW2")
Local oStrTW2Loc 	:= FWFormStruct(1,"TW2")
Local lResRH		:= TableInDic("TXB")
Local oStrTXBRH		:= NIL

oModel := MPFormModel():New("TECA012", /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )
oModel:AddFields("AA1MASTER",/*cOwner*/,oStrAA1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//restricoes cliente
oModel:AddGrid( "TW2DETCLI", "AA1MASTER", oStrTW2Cli,/*bLinePre*/,{|oModel, nLine,cAcao| At012VlAge(oModel, nLine, cAcao)},/*bPreVal*/ ,/*bPosVal*/ , /*bLoad */ )
oModel:SetRelation( "TW2DETCLI", { { "TW2_FILIAL", "xFilial('TW2')" }, { "TW2_CODTEC", "AA1_CODTEC"},{ "TW2_TIPO", "'1'"} }, TW2->(IndexKey(1)) )
oModel:SetDescription(STR0004) //"Cliente"

//restricoes local
oModel:AddGrid( "TW2DETLOC", "AA1MASTER", oStrTW2Loc,/*bLinePre*/,{|oModel, nLine,cAcao| At012VlAge(oModel, nLine, cAcao)},/*bPreVal*/ ,/*bPosVal*/ , /*bLoad */ )
oModel:SetRelation( "TW2DETLOC", { { "TW2_FILIAL", "xFilial('TW2')" }, { "TW2_CODTEC", "AA1_CODTEC" } , { "TW2_TIPO", "'2'"} }, TW2->(IndexKey(1)) )
oModel:SetDescription(STR0005) //"Local de Atendimento"



//inicializador padrao 
oStrTW2Cli:SetProperty("TW2_NOMCLI",MODEL_FIELD_INIT,{||Posicione("SA1",1,xFilial("SA1")+TW2->TW2_CLIENT,"A1_NOME")})
oStrTW2Loc:SetProperty("TW2_DESLOC",MODEL_FIELD_INIT,{||Posicione("ABS",1,xFilial("ABS")+TW2->TW2_LOCAL,"ABS_DESCRI")})

oStrAA1:SetProperty('*', MODEL_FIELD_OBRIGAT , .F. )
oStrTW2Cli:SetProperty('TW2_CODTEC', MODEL_FIELD_OBRIGAT , .F. )
oStrTW2Loc:SetProperty('TW2_CODTEC', MODEL_FIELD_OBRIGAT , .F. )

oStrTW2Cli:SetProperty('TW2_TIPO', MODEL_FIELD_INIT , {|| "1" } )
oStrTW2Loc:SetProperty('TW2_TIPO', MODEL_FIELD_INIT , {|| "2" } )
oStrTW2Cli:SetProperty('TW2_DTFIM',MODEL_FIELD_WHEN ,{|| at012VlCpo(1) } )
oStrTW2Loc:SetProperty('TW2_DTFIM',MODEL_FIELD_WHEN ,{|| at012VlCpo(2) } )

//validacao data
oStrAA1:SetProperty('AA1_CODTEC',MODEL_FIELD_VALID ,{|| .T. } )
oStrTW2Cli:SetProperty("TW2_DTINI", MODEL_FIELD_VALID, {|oModel| At012VlDt("TW2DETCLI","TW2_DTFIM","TW2_DTINI","TW2_DTFIM") } )
oStrTW2Loc:SetProperty("TW2_DTINI", MODEL_FIELD_VALID, {|oModel| At012VlDt("TW2DETLOC","TW2_DTFIM","TW2_DTINI","TW2_DTFIM") } )
oStrTW2Cli:SetProperty("TW2_DTFIM", MODEL_FIELD_VALID, {|oModel| At012VlDt("TW2DETCLI","TW2_DTFIM","TW2_DTINI","TW2_DTFIM") } )
oStrTW2Loc:SetProperty("TW2_DTFIM", MODEL_FIELD_VALID, {|oModel| At012VlDt("TW2DETLOC","TW2_DTFIM","TW2_DTINI","TW2_DTFIM") } )

oModel:GetModel('AA1MASTER'):SetOnlyView(.T.)
oModel:GetModel('AA1MASTER'):SetOnlyQuery(.T.)
oModel:GetModel('TW2DETCLI'):SetOptional(.T.)
oModel:GetModel('TW2DETLOC'):SetOptional(.T.)

//Restrições RH
If lResRH
	oStrTXBRH		:= FWFormStruct(1,"TXB")
	oModel:AddGrid( "TXBDETRH", "AA1MASTER", oStrTXBRH,/*bLinePre*/,{|oModel, nLine,cAcao| At012VlAge(oModel, nLine, cAcao)},/*bPreVal*/ ,/*bPosVal*/ , /*bLoad */ )
	oModel:SetRelation( "TXBDETRH", { { "TXB_FILIAL", "xFilial('TXB')" }, { "TXB_CODTEC", "AA1_CODTEC" } }, TXB->(IndexKey(1)) )
	oModel:SetDescription(STR0026) //"Recursos Humanos"
	oStrTXBRH:SetProperty('TXB_CODTEC', MODEL_FIELD_OBRIGAT , .F. )
	oStrTXBRH:SetProperty("TXB_DTINI", MODEL_FIELD_VALID, {|oModel| At012VlDt("TXBDETRH","TXB_DTFIM","TXB_DTINI","TXB_DTFIM") } )
	oStrTXBRH:SetProperty("TXB_DTFIM", MODEL_FIELD_VALID, {|oModel| At012VlDt("TXBDETRH","TXB_DTFIM","TXB_DTINI","TXB_DTFIM") } )
	oStrTXBRH:SetProperty('TXB_DTFIM',MODEL_FIELD_WHEN ,{|| at012VlCpo(3) } )	
	oStrTXBRH:SetProperty("TXB_DMOTIV",MODEL_FIELD_INIT,{|| AllTrim(TABELA("0J", TXB->TXB_MOTIVO, .F.))})
	oModel:GetModel('TXBDETRH'):SetOptional(.T.)

EndIf

Return(oModel)

//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Relacionamentos - Restrição de cadastro operacional 

@Return 	view
@author 	Serviços
@since 		28/09/2015
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local cIntegra	:= IIF(SuperGetMV("MV_GSXINT",,"2") == "3", "RM", "")
Local oView
Local oModel  := FWLoadModel("TECA012")  
Local oStrAA1 := FWFormStruct( 2, "AA1" , {|cCpo| AllTrim(cCpo)$'AA1_CODTEC+AA1_NOMTEC' }  )
Local oStrTW2Cli := FWFormStruct( 2, "TW2" ,{|cCpo| !AllTrim(cCpo)$'TW2_TIPO+TW2_CODTEC+TW2_NOME+TW2_LOCAL+TW2_DESLOC' } )
Local oStrTW2Loc := FWFormStruct( 2, "TW2" ,{|cCpo| !AllTrim(cCpo)$'TW2_TIPO+TW2_CODTEC+TW2_NOME+TW2_CLIENT+TW2_LOJA+TW2_NOMCLI' } )
Local lResRH		:= TableInDic("TXB")
Local oStrTXBRH		:= NIL


oStrAA1:SetNoFolder()

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField( 'VIEW_AA1' , oStrAA1, 'AA1MASTER' )
oView:AddGrid ( 'VIEW_TW2CLI' , oStrTW2Cli, 'TW2DETCLI' )
oView:AddGrid ( 'VIEW_TW2LOC' , oStrTW2Loc, 'TW2DETLOC' )

oView:CreateHorizontalBox('SUPERIOR', 10 ) //atendente
oView:CreateHorizontalBox('INFERIOR', 90 ) //restrições

// Criação da pasta para conter as abas da parte inferior
oView:CreateFolder( "ABAS", "INFERIOR" )

// Criação das Abas
oView:AddSheet( "ABAS", "ABA01", STR0004 )	// "Cliente"
oView:AddSheet( "ABAS", "ABA02", STR0005 )	// "Local de Atendimento"

// Criação das áreas de exibição dos dados nas abas
oView:CreateHorizontalBox( "ID_ABA01", 100,,, "ABAS", "ABA01" )
oView:CreateHorizontalBox( "ID_ABA02", 100,,, "ABAS", "ABA02" )

oView:SetOwnerView( 'VIEW_AA1' , 'SUPERIOR' ) 
oView:SetOwnerView( 'VIEW_TW2CLI' , 'ID_ABA01' )	// Grid Cliente
oView:SetOwnerView( 'VIEW_TW2LOC' , 'ID_ABA02' )	// Grid Local de Atendimento

//Restrições RH
If lResRH
	oStrTXBRH		:= FWFormStruct(2,"TXB",{|cCpo| AllTrim(cCpo) <> "TXB_COD" .and.  !AllTrim(cCpo)$ 'TXB_CODTEC|TXB_NOME|TXB_RESTRI' } )
	oView:AddGrid ( 'VIEW_TXBRH' , oStrTXBRH, 'TXBDETRH' )
	oView:AddSheet( "ABAS", "ABA03", STR0026 )	// "Recursos Humanos"
	oView:CreateHorizontalBox( "ID_ABA03", 100,,, "ABAS", "ABA03" )
	oView:SetOwnerView( 'VIEW_TXBRH' , 'ID_ABA03' )	//"Recursos Humanos"	
	If	cIntegra == "RM"
		oView:AddUserButton(STR0077,"",{|| At012GFun()},,,) // "Importa Funcionario"
	EndIf	
	
EndIf

Return oView
//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Cadastro de Restrições 

@Return 	MenuDef
@author 	Serviços
@since 		03/08/2015
/*/
//----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Local cIntegra	:= IIF(SuperGetMV("MV_GSXINT",,"2") == "3", "RM", "")
Local lResRH		:= TableInDic("TXB")

ADD OPTION aRotina TITLE STR0002 ACTION 'At012Manut(AA1_CODTEC)' OPERATION 2 ACCESS 0 //"Manutenção"
ADD OPTION aRotina TITLE STR0003 ACTION 'At012Vis(AA1_CODTEC)'   OPERATION 4 ACCESS 0 //"Visualização"
If cIntegra == "RM" .AND. lResRH
	ADD OPTION aRotina TITLE STR0030 ACTION 'At012ImpRes()' OPERATION 2 ACCESS 0 //"Importação de Restrições"
EndIf
Return(aRotina)

//----------------------------------------------------------
/*/{Protheus.doc} At012Manut(cCodTec)

Manutenção Restição operacional	 

@sample     At012Manut(cCodTec)

@return      

@author     serviços
@since      28/09/2015
@version    P12
/*/

//----------------------------------------------------------
Function At012Manut(cCodTec)

Local aArea 	:= {}
Local oModel 	:= Nil
Local aArea := GetArea()
Local lRet := .F.

lRet := At680Perm( Nil, __cUserId, "021" ) // Define regras de restrição

If !lRet
	Help( ,, 'TECA012',, STR0008, 1, 0) // "Usuário sem permissão para regras de restrição operacional"		
Else
	DbSelectArea("AA1")
	AA1->(DbSetOrder(1))//
	If AA1->(DbSeek(xFilial("AA1")+cCodTec))
			lRet := .T.
			FWExecView( STR0006, "VIEWDEF.TECA012", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/,	{||.T.}/*bOk*/,/*nReducao*/, /*aButtons*/, {||.T.}/*bCancel*/ )	//"Restrição"							
	Else
		MsgStop(STR0007) //"Registro não encontrado"
	Endif	
Endif

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} At012Vis(cCodTec)

Manutenção Restição operacional	 

@sample     At012Vis(cCodTec) 

@return      

@author     serviços
@since      28/09/2015
@version    P12
/*/

//----------------------------------------------------------
Function At012Vis(cCodTec)

Local aArea 	:= {}
Local oModel 	:= Nil
Local aArea := GetArea()
Local lRet := .F.

DbSelectArea("AA1")
AA1->(DbSetOrder(1))//
If !IsInCallStack("At012ImpRes") .OR. AA1->(DbSeek(xFilial("AA1")+cCodTec))
		lRet := .T.
		FWExecView( STR0006, "VIEWDEF.TECA012", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/,	{||.T.}/*bOk*/,/*nReducao*/, /*aButtons*/, {||.T.}/*bCancel*/ )	//"Restrição"							
Else
	MsgStop(STR0007) //"Registro não encontrado"
Endif	

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At012VlDt
Função para validação dos períodos iniciais e finais das restrições.

@sample 	At012VlDt(cModelo,cCpoSelec,cCpoDtIn,cCpoDtFm)

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
Function At012VlDt(cModelo,cCpoSelec,cCpoDtIni,cCpoDtFim)

Local oModel  := FwModelActive()
Local oMdl		:= oModel:GetModel(cModelo)
Local lRet		:= .T.
Local cCpoAlias := IIF( Left(cModelo,3) <> "TW2", "TXB", "TW2" )

If Empty(oMdl:GetValue(cCpoAlias+'_DTINI'))
	lRet := .F.
	Help(,,"AT012VLDDT",,STR0029,1,0) // "Data inicial deve ser informada"
Else

	If  oMdl:GetValue(cCpoAlias+'_TEMPO') == '2' //contrato determinado
		If !Empty(oMdl:GetValue(cCpoAlias+'_DTFIM')) .AND. !Empty(oMdl:GetValue(cCpoAlias+'_DTINI'))
			If DtoS(oMdl:GetValue(cCpoDtIni)) > DtoS(oMdl:GetValue(cCpoDtFim))  		
				lRet := .F.
				Help(,,"AT012VLDDT",,STR0009,1,0) // "Data final deve ser maior ou igual a data inicial da restrição para contratos determinados!"
			EndIf
		Endif
	Elseif oMdl:GetValue(cCpoAlias+'_TEMPO') == '1' //contrato determinado
		If !Empty(oMdl:GetValue(cCpoAlias+'_DTFIM'))
			Help(,,"AT012AVLDDT",,STR0002,1,0) //"Para contratos indeterminados, deixar a data final em branco"
			lRet := .F.
		Endif	
	EndIf
EndIf

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At012VlAge(oModel)
Função para validação da linha digitada para verificar se existe agenda para o atendente

@sample 	At012VlAge(oModel)

@since		01/10/2015      
@version	P12

@return 	lRet, Lógico, retorna .T. se nao existir agenda futura.
/*/
//------------------------------------------------------------------------------
Function At012VlAge(oModel, nLine, cAcao)

Local lRet		:= .F.
Local cCodTec	:=""
Local dDtIni	:=""
Local dDtFim	:=""
Local lOk		:= .F. 
Local cTempo 	:= ""
Local cCpoAlias := IIF( Left(oModel:getId(),3) <> "TW2", "TXB", "TW2" )
Local aSaveLines:= ""
Local nC 		:= 0
Local cCodTec 	:= ""
Local tmpAgenda := ""

Default nLine 	:= 0
Default cAcao 	:= ""

cCodTec := FwFldGet("AA1_CODTEC")
dDtIni	:= oModel:getValue(cCpoAlias+"_DTINI")
dDtFim 	:= oModel:getValue(cCpoAlias+"_DTFIM")

If (oModel:getId() == "TW2DETCLI" .OR. oModel:getId() == "TW2DETLOC")
	cCodLoc	:= oModel:getValue("TW2_LOCAL")
	cCodCli := oModel:getValue("TW2_CLIENT")
	cCodLoj := oModel:getValue("TW2_LOJA")	
Endif

tmpAgenda:=GetNextAlias()

If oModel:getId() == "TW2DETCLI"
	If Empty(oModel:GetValue("TW2_CLIENT"))
		Help(,,"AT012VLCLI",,STR0012,1,0) // "Favor informar codigo do cliente."
	ElseIf oModel:GetValue("TW2_TEMPO") == '2' //contrato determinado
		If Empty(dDtFIm)
			Help(,,"AT012DTFIM",,STR0014,1,0) // "Para contratos determinados, preencher a data final."
			lOk:= .F.
		Else
			lOk:= .T.	
		Endif
	Else
		lOk:= .T.
	Endif
Elseif oModel:getId() == "TW2DETLOC"
	If Empty(oModel:GetValue("TW2_LOCAL"))
		Help(,,"AT012VLLOC",,STR0013,1,0) // "Favor informar local de atendimento."	
	ElseIf oModel:GetValue("TW2_TEMPO") == '2' //contrato determinado
		If Empty(dDtFim)
			Help(,,"AT012DTFIM",,STR0014,1,0) // "Para contratos determinados, preencher a data final."
			lOk:= .F.
		Else
			lOk:= .T.	
		Endif
	Else
		lOk:= .T.
	Endif
Elseif oModel:getId() == "TXBDETRH"
	If Empty(oModel:GetValue("TXB_MOTIVO"))
		Help(,,"AT012VLMOT",,STR0028	,1,0) // "Favor informar motivo."
	ElseIf oModel:GetValue("TXB_TEMPO") == '2' //contrato determinado
		If Empty(dDtFim)
			Help(,,"AT012DTFIM",,STR0014,1,0) // "Para contratos determinados, preencher a data final."
			lOk:= .F.
		Else
			lOk:= .T.	
		Endif
	Else
		lOk:= .T.
	Endif
Endif

If lOk .AND. oModel:getId() <> "TXBDETRH"
	If !empty(dDtFim)
		cTempo := "%AND ABB_DTFIM <='"+ DtoS(dDtFim) + "'%"
	Else
		cTempo := '%%'
	Endif
	If oModel:getId() == "TW2DETCLI"
		//verificar a agenda da atendente do registro na tabela ABB por cliente
		BeginSql Alias tmpAgenda
		SELECT count(1) as regABB
		FROM %table:ABB% ABB
		WHERE	ABB_FILIAL = %xFilial:ABB%
			AND ABB_LOCAL IN (Select ABS_LOCAL
							From %table:ABS% ABS
							Where ABS_CODIGO = %Exp:oModel:GetValue("TW2_CLIENT")% 
								AND ABS_LOJA = %Exp:oModel:GetValue("TW2_LOJA")%
								AND ABS.%NotDel%
								Group By ABS_LOCAL )
			AND ABB_ATIVO ='1' AND ABB_ATENDE ='2'
			AND ABB_CODTEC = %Exp:cCodTec%
			AND ABB_DTINI >=  %Exp:dDtIni%
			AND ABB.%NotDel%
			%Exp:cTempo%
		EndSql
	Elseif oModel:getId() == "TW2DETLOC"
		BeginSql Alias tmpAgenda
		SELECT count(1) as regABB
		FROM %table:ABB% ABB
		WHERE	ABB_FILIAL = %xFilial:ABB%
			AND ABB_LOCAL  = %Exp:oModel:GetValue("TW2_LOCAL")%
			AND ABB_ATIVO ='1' AND ABB_ATENDE ='2'
			AND ABB_CODTEC = %Exp:cCodTec%
			AND ABB_DTINI >=  %Exp:dDtIni%
			AND ABB.%NotDel%
			%Exp:cTempo%
		EndSql
	Endif
	DbSelectArea(tmpAgenda)
	If (tmpAgenda)->regABB > 0 //existe agenda posterior atendida ou com manutenção 
		Help(,,"AT012VLDAGE",,STR0011,1,0) // "Atendente com alocação no período de restrição."
	Else
		lRet:= .T.	
	Endif
	(tmpAgenda)->(DbCloseArea())
Else
	lRet := .T.
Endif

//Realiza a validação para não deixar duplicar ou entrelaçar os período de aviso ou bloqueio.
If lRet .AND. nLine <> 0 .AND. cAcao != "DELETE"
	aSaveLines := FwSaveRows()
	For nC := 1 to oModel:length()
		oModel:GoLine(nc)

		If !oModel:IsDeleted() .AND. nC <> nLine .AND. ( ( oModel:getId() == "TW2DETCLI" .AND. cCodCli == oModel:getValue("TW2_CLIENT") .AND. cCodLoj == oModel:getValue("TW2_LOJA") ) .OR.;
		 												 ( oModel:getId() == "TW2DETLOC" .AND. cCodLoc == oModel:getValue("TW2_LOCAL") ) )
			
			If Empty(oModel:getValue("TW2_DTFIM")) .AND. ( Empty(dDtFim) .OR. oModel:getValue("TW2_DTINI") <= dDtFim)
				Help(,,"AT012VLDAGE",,STR0027 + str(nC),1,0) // "Ja existe restrição de horário cadastrada para este período. Vide linha "
				lRet := .F.
			ElseIf oModel:getValue("TW2_DTFIM") >= dDtIni .AND. (oModel:getValue("TW2_DTFIM") <= dDtFim  .OR. Empty(dDtFim))
				Help(,,"AT012VLDAGE",,STR0027+ str(nC),1,0) //"Ja existe restrição de horário cadastrada para este período. Vide linha "
				lRet := .f.
			EndIf
		EndIf
	Next nC

	FWRestRows( aSaveLines )
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At012VlCpo(oModel)
Função para validação do campo para edição

@sample 	At012VlCpo(oModel)

@since		01/10/2015      
@version	P12

@return 	lRet, Lógico, retorna .T. se nao existir agenda futura.
/*/
//------------------------------------------------------------------------------
Function At012VlCpo(nTipo)

Local lRet:= .F.
Local oModel:=FWModelActive()

If nTipo == 1
	lRet:= oModel:GetModel("TW2DETCLI"):GetValue("TW2_TEMPO") == '2' //contrato determinado
Elseif nTipo == 2
	lRet:=  oModel:GetModel("TW2DETLOC"):GetValue("TW2_TEMPO") == '2' //contrato determinado
Elseif nTipo == 3
	lRet:= oModel:GetModel("TXBDETRH"):GetValue("TXB_TEMPO") == '2' //contrato determinado

Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At012Blq(cAtend,dDataDe,dDataAte,cLocal)
Função para validação de restrição operacional

@sample 	At012Blq(cAtend,dDataDe,dDataAte,cLocal)

@since		01/10/2015      
@version	P12

@return 	lRet, Lógico, retorna .T. se nao existir restrições operacionais.
/*/
//------------------------------------------------------------------------------
Function At012Blq(cAtend,dDataDe,dDataAte,cLocal)

Local lRet:= .F.
Local aRestri:={}
Local cTpResLoc:= "0"
Local cTpResCli:= "0"

cTpResLoc:=at012ResLoc(cAtend,dDataDe,dDataAte,cLocal)
If cTpResLoc == "0"
	cTpResCli:=at012ResCli(cAtend,dDataDe,dDataAte,cLocal)
	If cTpResCli == '1'
		If msgYesNo(STR0015,STR0017) //"Atendente com restrição operacional de aviso."##"Deseja Continuar?" 
			lRet := .T.
		Else
			lRet := .F.
		Endif
	Elseif cTpResCli == '2'
	 	lRet:= .F.
	 	Help(,,"AT012REST",,STR0016,1,0) // "Atendente com restrição operacional para o local/cliente"		
	Endif	
Else
	If cTpResLoc == '1'
		If msgYesNo(STR0015,STR0017) //"Atendente com restrição operacional de aviso."##"Deseja Continuar?" 
			lRet := .T.
		Else
			lRet := .F.
		Endif
	Elseif cTpResLoc == '2'
	 	lRet:= .F.
	 	Help(,,"AT012REST",,STR0016,1,0) // "Atendente com restrição operacional para o local/cliente"		
	Endif
Endif

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} At012ResLoc(cAtend,dDataDe,dDataAte,cLocal)
Função para validação de restrição operacional

@sample 	At012ResLoc(cAtend,dDataDe,dDataAte,cLocal)

@since		06/11/2015      
@version	P12

@return 	lRet, 0,1,2
/*/
//------------------------------------------------------------------------------
Function at012ResLoc(cAtend,dDataDe,dDataAte,cLocal)

Local cResLoc:="0"
Local lAchou:=.F.
Local tmpRestri:=""

//query com as restricoes do local de atendimento
If  !Empty(cLocal)
	tmpRestri:= GetNextAlias()
	BeginSql Alias tmpRestri
		Select TW2_CODTEC, TW2_CLIENT, TW2_LOJA, TW2_LOCAL, TW2_TEMPO, TW2_DTINI, TW2_DTFIM, TW2_RESTRI
		From %table:TW2% TW2
		left join %table:ABS% ABS on ABS_FILIAL = %xFilial:ABS% 
			AND ABS_LOCAL = TW2_LOCAL
		WHERE	TW2_FILIAL = %xFilial:TW2%
		AND TW2_CODTEC = %Exp:cAtend%
		AND TW2_LOCAL = %Exp:cLocal% 
		AND TW2.%NotDel%
	EndSql
	
	DbSelectArea(tmpRestri)
	(tmpRestri)->(DbGoTop())
	While (tmpRestri)->(! Eof())
		If !lAchou
			//verificar tipo restricao
			If  (tmpRestri)->TW2_TEMPO == '1' // periodo indeterminado
				If ( dtos(dDataDe) > (tmpRestri)->TW2_DTINI ) .OR. ( dtos(dDataAte) > (tmpRestri)->TW2_DTINI ) 
					cResLoc:= (tmpRestri)->TW2_RESTRI
					lAchou:= .T.
				Endif
			Elseif (tmpRestri)->TW2_TEMPO == '2' //periodo determinado
				If  (dtos(dDataDe) > (tmpRestri)->TW2_DTINI) .AND. (dtos(dDataDe) < (tmpRestri)->TW2_DTFIM ) 
					cResLoc:= (tmpRestri)->TW2_RESTRI
					lAchou:= .T.
				Endif
			Endif
		Endif
	(tmpRestri)->(DbSkip())
	Enddo
	(tmpRestri)->(DbCloseArea())
Endif

Return cResloc 

//-----------------------------------------------------------------------------
/*/{Protheus.doc} At012ResCli(cAtend,dDataDe,dDataAte,cLocal)
Função para validação de restrição operacional

@sample 	At012ResLoc(cAtend,dDataDe,dDataAte,cLocal)

@since		06/11/2015      
@version	P12

@return 	lRet, 0,1,2
/*/
//-----------------------------------------------------------------------------
Function at012ResCli(cAtend,dDataDe,dDataAte,cLocal)

Local cResCli:= "0"
Local cCliente:=""
Local cLojaCli:=""
Local lAchou:=.F.
Local tmpResCli:=""

//cliente do local de atendimento
cCliente:= Posicione("ABS",1,xFilial("ABS")+cLocal,"ABS_CODIGO")
cLojaCli:= Posicione("ABS",1,xFilial("ABS")+cLocal,"ABS_LOJA")
	
tmpResCli:= GetNextAlias()
BeginSql Alias tmpResCli
	Select TW2_CODTEC, TW2_CLIENT, TW2_LOJA, TW2_LOCAL, TW2_TEMPO, TW2_DTINI, TW2_DTFIM, TW2_RESTRI
	From %table:TW2% TW2
	left join %table:ABS% ABS on ABS_FILIAL = %xFilial:ABS% 
		AND ABS_LOCAL = TW2_LOCAL
	WHERE	TW2_FILIAL = %xFilial:TW2%
	AND TW2_CODTEC = %Exp:cAtend%
	AND TW2_CLIENT = %Exp:cCliente%
	AND TW2_LOJA = %Exp:cLojaCli%
	AND TW2.%NotDel%
EndSql
	
DbSelectArea(tmpResCli)
(tmpResCli)->(DbGoTop())
While (tmpResCli)->(! Eof())
	If !lAchou
		//verificar tipo restricao
		If  (tmpResCli)->TW2_TEMPO == '1' // periodo indeterminado
			If ( dtos(dDataDe) > (tmpResCli)->TW2_DTINI ) .OR. ( dtos(dDataAte) > (tmpResCli)->TW2_DTINI ) 
				cResCli:= (tmpResCli)->TW2_RESTRI
				lAchou:= .T.
			Endif
		Elseif (tmpResCli)->TW2_TEMPO == '2' //periodo determinado
			If  (dtos(dDataDe) > (tmpResCli)->TW2_DTINI) .AND. (dtos(dDataDe) < (tmpResCli)->TW2_DTFIM ) 
				cResCli:= (tmpResCli)->TW2_RESTRI
				lAchou:= .T.
			Endif
		Endif
	Endif
(tmpResCli)->(DbSkip())
Enddo
(tmpResCli)->(DbCloseArea())


Return cResCli 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At012ImpRes()
Função para selecionar o tipo e ou atendentes para importação de suas restrições

@return	lOk
@author	Augusto Albuquerque
@since 	14/08/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At012ImpRes()
Local aStruct		:= {}
Local aIdx			:= {}
Local aSeek			:= {}
Local aInsertTmp	:= {}
Local aColumns		:= {}
Local aFuncionar	:= {}
local aFunc			:= {}
Local lOk			:= .T.
Local lAuto			:= .F.
Local nStepCmmIns	:= 900
Local nOpc
Local nX	
Local nY
Local oMrkBrowse	:= FWMarkBrowse():New()
Local oGSTmpTb		:= Nil

nOpc := Aviso( STR0030, STR0031,{ STR0032, STR0033, STR0034 }, 2 ) //"Importação de Restrições" ## "Como deseja realizar a importação ?" ## "Selecionar Atendentes" ## "Importa Todos" ## "Cancelar" 

If nOpc <> 3
	aFuncionar := AT012FunRM()
	If len(aFuncionar) > 0
		If nOpc == 1
			//Cria estrutura e tabela tmp com os campos necessarios
			Aadd(aStruct, {"OK"        	, "C", 1 						, 0						 })
			Aadd(aStruct, {"AA1_FILIAL"	, "C", TamSX3("AA1_FILIAL")[1]	, TamSX3("AA1_FILIAL")[2]})
			Aadd(aStruct, {"AA1_CDFUNC"	, "C", TamSX3("AA1_CDFUNC")[1]	, TamSX3("AA1_CDFUNC")[2]})
			Aadd(aStruct, {"AA1_NOMTEC"	, "C", TamSX3("AA1_NOMTEC")[1]	, TamSX3("AA1_NOMTEC")[2]})
			Aadd(aStruct, {"AA1_CODTEC"	, "C", TamSX3("AA1_CODTEC")[1]	, TamSX3("AA1_CODTEC")[2]})
			
			//Cria indices para a tabela temporária 
			Aadd(aIdx, {"I1",{ 'AA1_CDFUNC' }})
			Aadd(aIdx, {"I2",{ 'AA1_CODTEC'}})
			Aadd(aIdx, {"I5",{ 'AA1_NOMTEC'}})
			
			//Cria array da busca de acordo com os indices da tabela temporária
			aAdd(aSeek, {TxDadosCpo('AA1_CDFUNC')[1]	,{{'','C',TamSX3('AA1_CDFUNC')[1],TamSX3('AA1_CDFUNC')[2],TxDadosCpo('AA1_CDFUNC')[1],PesqPict('AA1','AA1_CDFUNC'),NIL}},1})
			aAdd(aSeek, {TxDadosCpo('AA1_CODTEC')[1]	,{{'','C',TamSX3('AA1_CODTEC')[1],TamSX3('AA1_CODTEC')[2],TxDadosCpo('AA1_CODTEC')[1],PesqPict('AA1','AA1_CODTEC'),NIL}},2})
			aAdd(aSeek, {TxDadosCpo('AA1_NOMTEC')[1]	,{{'','C',TamSX3('AA1_NOMTEC')[1],TamSX3('AA1_NOMTEC')[2],TxDadosCpo('AA1_NOMTEC')[1],PesqPict('AA1','AA1_NOMTEC'),NIL}},5})
			
			//Instancia o método NEW para criação da tabela temporária
			oGSTmpTb := GSTmpTable():New('RESAA1',aStruct, aIdx, {}, nStepCmmIns )
			cRetTab  := 'RESAA1'
			
			//Validação para a criação da tabela temporária
			If oGSTmpTb:CreateTMPTable()
				//Preenche Tabela temporária com as informações filtradas
				For nX := 1 To Len(aFuncionar)
					aInsertTmp :={}
					Aadd(aInsertTmp, {'AA1_FILIAL'		,aFuncionar[nX][1]})
					Aadd(aInsertTmp, {'AA1_CODTEC'		,aFuncionar[nX][2]})
					Aadd(aInsertTmp, {'AA1_NOMTEC'		,aFuncionar[nX][3]})
					Aadd(aInsertTmp, {'AA1_CDFUNC'		,aFuncionar[nX][4]})
						
					If oGSTmpTb:Insert(aInsertTmp)
						lOk := oGSTmpTb:Commit()
					Else
						lOk := .F.
						Exit
					EndIf
				Next nX
			Else
				oGSTmpTb:ShowErro()
			EndIf
			
			//MarkBrowse
			For nY := 1 To Len(aStruct)
				If aStruct[nY][1] <> "OK"
					AAdd(aColumns,FWBrwColumn():New())
					aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nY][1]+"}") )
					aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nY][1]))
					aColumns[Len(aColumns)]:SetSize(aStruct[nY][3])
					aColumns[Len(aColumns)]:SetDecimal(aStruct[nY][4])
					aColumns[Len(aColumns)]:SetPicture(PesqPict(cRetTab,aStruct[nY][1]))
				EndIf
			Next nY
		
			DEFINE MSDIALOG oDlg TITLE STR0035 From 300,0 To 700,1000 PIXEL //"Funcionarios disponiveis para importação de restrições"
			oMrkBrowse:SetOwner(oDlg)
			oMrkBrowse:DisableFilter()
			
			oMrkBrowse:SetDescription(STR0036) //"Importa Restrições do Funcionario"
			oMrkBrowse:SetTemporary(.T.)     	
			oMrkBrowse:AddButton(STR0037,{|| At012GFun(aFunc),oDlg:End(), oMrkBrowse:Refresh(.T.) },,3,)		//"Importa"
			oMrkBrowse:AddButton(STR0033, {|| At012GFun(aFuncionar ),oDlg:End(), oMrkBrowse:Refresh(.T.)},,3,) // "Importa Todos"
			oMrkBrowse:SetFieldMark("OK")
			oMrkBrowse:SetAlias(cRetTab) //Seta o arquivo temporario para exibir a seleção dos dados
			oMrkBrowse:SetSeek(.T., aSeek) 
			oMrkBrowse:SetAllMark( { || oMrkBrowse:AllMark() } )
			oMrkBrowse:bMark := {||At012Mark(oMrkBrowse,cRetTab, @aFunc)}	        
			oMrkBrowse:SetColumns(aColumns)
			oMrkBrowse:DisableReport()
			oMrkBrowse:SetMenuDef("")
			oMrkBrowse:DisableDetails()
			oMrkBrowse:Activate(oDlg)
			ACTIVATE MSDIALOG oDlg CENTERED	
			
			oGSTmpTb:Close()
			TecDestroy(oGSTmpTb)			 
		ElseIf nOpc == 2
			At012GFun(aFuncionar)   
		EndIf
	Else
		Help( ,, 'At012ImpRes',, STR0076, 1, 0) // "Nenhum Atentende Retornado!"
	EndIf
Else
	MSGInfo(STR0039, STR0040) //"A operação foi cancelada!" ## "Operação Cancelada" 
EndIf
Return lOk 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT012FunRM()
Função para retorno dos funcionarios disponiveis na base

@return	aFunc funcionarios disponiveis
@author	Augusto Albuquerque
@since 	14/08/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT012FunRM()
Local aArea		:= GetArea()
Local aFunc		:= {}
Local cQuery	:= ""
Local cAliasSRA	:= GetNextAlias()

cQuery	:= 	"SELECT AA1.AA1_FILIAL, AA1.AA1_CODTEC, AA1.AA1_NOMTEC, AA1.AA1_CDFUNC "
cQuery	+= 	"FROM " + RetSqlName("AA1") + " AA1 "
cQuery	+=	"WHERE AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
cQuery	+=	"AND AA1.D_E_L_E_T_  = ' ' " 
cQuery	+=	"AND AA1.AA1_CDFUNC <> '" + Space(TamSX3('TFI_CONTRT')[1]) + "' "

If !IsInCallStack("At012ImpRes")
	cQuery	+=	"AND AA1.AA1_CODTEC  = '" + FwFldGet("AA1_CODTEC") + "'" 
EndIf 
 
cQuery := ChangeQuery(cQuery)	
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasSRA, .T., .T. )
//	Preenche o array com as informações de funcionários que não são atendentes.

While (cAliasSRA)->(! Eof())
	aAdd(aFunc,{ (cAliasSRA)->AA1_FILIAL,;
	             (cAliasSRA)->AA1_CODTEC,;
	             (cAliasSRA)->AA1_NOMTEC,;
	             (cAliasSRA)->AA1_CDFUNC})
	(cAliasSRA)->(DbSkip())
EndDo
(cAliasSRA)->(DbCloseArea())

If Len(aFunc)==0
	aFunc :={{"","","",""}}
EndIf
RestArea(aArea)
Return (aFunc)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At012Mark(oMrkBrowse,cRetTab,aFunc)
Função para selecionar os funcionarios

@return	
@author	Augusto Albuquerque
@since 	14/08/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At012Mark(oMrkBrowse,cRetTab,aFunc)
Local aArea		:= GetArea()
Local aAux		:= {}
Local cMarca	:= ""
Local cCodigo	:= (cRetTab)->AA1_CODTEC
Local nX

DbSelectArea(cRetTab)
  
cMarca := oMrkBrowse:Mark() 
	RecLock(cRetTab, .F.)
		
If (cRetTab)->OK <> cMarca
	(cRetTab)->OK := ' '
	For nX := 1 To Len(aFunc)
		If aFunc[nX][2] <> cCodigo
			AADD(aAux, aFunc[nX])
		EndIF
	Next nX
	aFunc	:= ACLONE(aAux)
Else
	(cRetTab)->OK := cMarca
	AADD(aFunc, {(cRetTab)->AA1_FILIAL, (cRetTab)->AA1_CODTEC, (cRetTab)->AA1_NOMTEC, (cRetTab)->AA1_CDFUNC}  )
EndIf
MsUnlock()
(cRetTab)->(DbSkip())

RestArea(aArea)

Return 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At012GFun(aFunc)
Função cria regua para mostrar o andamento do processo

@return	
@author	Augusto Albuquerque
@since 	14/08/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At012GFun(aFunc)
Local nTotal	:= 0
Local nMeter
Local nOperation
Local lImpRes	:= IsInCallStack("At012ImpRes")
Local lUpdate	:= .T.
Local oModel	
Local oDlg
Local oMeter
Local oSayMsg
Local oFont
Local oSayMtr

Default aFunc := {}

If !lImpRes
	oModel := FWModelActive()
	nOperation := oModel:GetOperation()
	If nOperation == MODEL_OPERATION_VIEW
		lUpdate := .F.
	EndIf
EndIf

If lUpdate
	If Len(aFunc) == 0 .AND. !lImpRes
		aFunc := AT012FunRM()
	EndIf
	
	nTotal := Len(aFunc)
	DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0030 //"Importação de Restrições"
		nMeter := 0
		oSayMtr := tSay():New(10,10,{||STR0041},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
		oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},Len(aFunc),oDlg,220,10,,.T.) // cria a régua
		
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (At012ResWS(aFunc, oDlg, oMeter, oSayMtr ))
Else
	Help( ,, 'At012GFun',, STR0078, 1, 0) // "Não é possivel utilizar a função, pois esta em modo de visualização!"
EndIf
Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At012ResWS(aFunc, oDlg, oMeter, oSayMsg, oSayMtr)
Função de chama do webservice e da gravação na TXB

@return	
@author	Augusto Albuquerque
@since 	14/08/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At012ResWS(aFunc, oDlg, oMeter, oSayMtr)
Local aErrors 	:= {}
Local aGeral	:= {}
Local aRet 		:= {}
Local cMsg		:= ""
Local cMsgErro	:= ""
Local cMotivo	:= ""
Local cCodTec
Local cCdFunc
Local lOk		:= .T.
Local lFalha	:= .F.
Local lImpRes	:= IsInCallStack("At012ImpRes")
Local nFunc		:= Len(aFunc)
Local nFalhaA 	:= 0
Local nFalhaR	:= 0
Local nReg		:= 0
Local nInclu	:= 0
Local nLoop		:= 0
Local nTotLoop	:= 0
Local nTotalF	:= 0
Local nTotalI	:= 0
Local nX
Local nY
Local oView
Local oModel	:= Nil 

If nFunc > 0
	cCodTec	:= aFunc[1][2]
	cCdFunc	:= aFunc[1][4]
	cNomTec	:= aFunc[1][3]
	
	If lImpRes
		oModel	:= FwLoadModel("TECA012")
	Else
		oModel	:= FWModelActive()
	EndIf
	For nX := 1 To nFunc
		aRet := At012InRes("FopFuFeriasPerData", "PFUFeriasPer.CHAPA=" + aFunc[nX][4], "RM", @cMsgErro, aFunc[nX][4] )
		If Len(aRet) > 0
			aAdd(aGeral, aClone(aRet))
		EndIf
		aRet :=  At012InRes("FopHstAftData", "PFHstAft.CHAPA=" + aFUNC[nX][4], "RM", @cMsgErro, aFunc[nX][4] )
		If Len(aRet) > 0
			aAdd(aGeral, aClone(aRet))
		EndIf
		aRet := At012InRes("FopRescisaoData", "PFunc.DataDemissao>'' and pfunc.chapa=" + aFUNC[nX][4], "RM", @cMsgErro, aFunc[nX][4] )
		If Len(aRet) > 0
			aAdd(aGeral, aClone(aRet))
		EndIf
	Next nX
	Begin Transaction
		For nX := 1 To Len(aGeral)
			If 	aGeral[nX][1][1] <> cCdFunc
				For nY := 1	To nFunc
					If aGeral[nX][1][1] == aFunc[nY][4]
						If lFalha
							nFalhaA++
							lFalha := .F.
						EndIf
						cCodtec := aFunc[nY][2]
						cCdFunc	:= aFunc[ny][4]
						cNomTec	:= aFunc[nY][3]
						Exit
					EndIf
				Next nY
			EndIf	
			lOk	:= At012ResAll(aGeral[nX], cCodTec, @nInclu, @nFalhaR, @nLoop, oModel, @cMotivo)
			
			If !lOk .OR. !Empty(cMotivo)
				AAdd(aErrors, { STR0069	+ cNomTec					 	,;	// "Nome: "
								STR0070	+ aGeral[nX][1][1]			 	,;	// "Codigo do Funcionario: "
								STR0071	+ aGeral[nX][1][6]			 	,;	// "Ao tentar cadastrar: "
								STR0072	+ cValtoChar(Len(aGeral[nX]))	,;	// "Total de Restrições: "
								STR0073	+ cValToChar(nInclu)		 	,;	// "Restrições inseridas: "
								STR0074	+ cValToChar(nFalhaR)		 	,;	// "Restrições com falhas: "
								cMotivo })
				lFalha := .T.
				cMotivo := ""
			EndIf
			
			If nReg <> nFunc
				nReg++
			EndIf
			oMeter:Set(nReg)
			oSayMtr:SetText(STR0042 + cValToChar(nReg) + STR0043 + cValToChar(oMeter:nTotal) + STR0044) //"Importando... "  ## " de " ## " funcionarios com restrições"
			oMeter:Refresh()
			oSayMtr:CtrlRefresh()
			SysRefresh()
			
			nTotalF	+= nFalhaR
			nTotalI += nInclu
			nTotLoop += nLoop
			nInclu 	:= 0
			nFalhaR := 0
			nLoop	:= 0
		Next nX
	End Transaction
	
	IF lFalha
		nFalhaA++
	EndIf
	cMsg += STR0045 + cValToChar(( nFunc )) + CRLF // "Total de Atendente(s) com suas Restrições: " 
	If nTotLoop + nTotalF + nTotalI > 0
	cMsg += STR0046 + cValToChar(nFunc - nFalhaA) + CRLF // "Restrições de atendente(s) adicionados: " 
	cMsg += STR0047 + cValToChar(nFalhaA) + CRLF + CRLF // ""Atendente(s) com falha(s) na inclusão de restrições: "
	Else
		cMsg += CRLF + CRLF
	EndIf
	If LEN(aErrors) > 0
		cMsg += STR0048 + CRLF + CRLF // "Os atendentes abaixo tiveram algum erros na inclusão das restrições: "
		cMsg += REPLICATE("-",50) + CRLF
		
		For nX := 1 To LEN(aErrors)
			For nY := 1 To LEN(aErrors[nX])
				cMsg += aErrors[nX][nY] + CRLF
			Next nY
			cMsg += CRLF + REPLICATE("-",50) + CRLF
		Next nX
		cMsg += CRLF
	EndIf
	cMsg += STR0049 + cValtoChar(nTotLoop + nTotalF + nTotalI) // "Quantidade de Registro processados: "
	cMsg += CRLF + STR0050 + cValToChar(nTotalI ) // "Registro(s) incluido(s): "
	cMsg += CRLF + STR0051 + cValToChar(nTotalF) // "Registro(s) com falha(s): "
	cMsg += CRLF + STR0052 + cValToChar(nTotLoop) + CRLF // "Registro(s) duplicado(s) não inserido(s): "
	cMsg += CRLF + cMsgErro
	AtShowLog(cMsg,STR0030,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.) // "Importa Restrições"
Else
	Help(,,"At012ResWS",,STR0054,1,0) // "Nenhum atendente selecionado" 
EndIf
 
If !lImpRes
	oModel:Activate()
	oView := FwViewActive()
	oView:Refresh()
Else
	oModel:DeActivate()
EndIf

oDlg:End()
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At012InRes(cName, cFiltro, cMarca, cMsgErro)
Função de gravação do webservice para ser usada na TXB

@return	aRet - retorno dos dados do webservice
@author	Augusto Albuquerque
@since 	14/08/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At012InRes(cName, cFiltro, cMarca, cMsgErro, cChapa)
Local aRet		:= {}
Local aRestri	:= {}
Local aAux		:= {}
Local cRet		:= ""
Local cWarning 	:= ""
Local cError 	:= ""
Local cCodFilRM	:= ""
Local cMotivo	:= ""
Local cTipo		:= "1"
Local dDataF	:= ""
Local lRet		:= .T.
Local nX
Local oRet		:= Nil
Local oWS 		:= NIL

oWS := GSItRMWS(cMarca, .F., @cMsgErro, @cCodFilRM)

If oWS <> NIL
	oWS:cFiltro := cFiltro
	oWS:cDataServerName := cName
	oWS:ReadView()
	
	cRet	:= oWS:cReadViewResult  // pega o retorno se deu certo		
	
	If !Empty(cRet) .AND. cRet <> "<NewDataSet />"
		oRet := XMLParser( cRet, "_", @cError, @cWarning)
		
		If Empty(cError)
			If cName == "FopFuFeriasPerData"
				aAux := XmlChildEx ( oRet:_NEWDATASET, "_PFUFERIASPER") //If XmlGetChild(oRet:_NEWDATASET, 2) <> Nil
				If ValType(aAux) <> Nil
					If ValType(aAux) == "O" 
						aAdd(aRestri, aAux)
					ElseIf ValType(aAux) == "A"
						aRestri := aClone(aAux)
					Else 
						cMsgErro += STR0075 + cChapa + CRLF + CRLF  // "Problemas no xml de retorno mensagem ReadView de ferias, possivelmente esta pendente aprovação. Atendente de Codigo de funcionario(CHAPA): "
						lRet := .F.
					EndIf
					If lRet
						For nX := 1 To Len(aRestri)
							If XmlChildEx ( aRestri[nX], "_NRODIASABONO" ) <>  Nil
								cMotivo	:= STR0057 + ALLTRIM(aRestri[nx]:_NRODIASABONO:TEXT) //"Numero de dias abonados: "
							EndIf
							AADD(aRet, {PADR(aRestri[nx]:_CHAPA:TEXT, TamSX3("AA1_CDFUNC")[1]),;
										"2",;
										StoD(Strtran(Left(aRestri[nx]:_DATAINICIO:TEXT, 10), "-")),;														
										"02",;																												
										"2",;																												
										STR0056,; 																											// "Ferias"
										StoD(Strtran(Left(aRestri[nx]:_DATAFIM:TEXT, 10), "-")),;															
										STR0058 + ALLTRIM(aRestri[nx]:_SITUACAOFERIAS:TEXT) + CRLF + STR0059 + ALLTRIM(aRestri[nx]:_NRODIASFERIAS:TEXT) +;	// "Situação: " ## "Numero de dia de ferias: "
										CRLF + STR0058 + ALLTRIM(aRestri[nx]:_IMAGEMSITUACAO:TEXT) + CRLF +;												// "Situação: "
										STR0060 + cValToChar(Stod(Strtran(Left(aRestri[nx]:_DATAPAGTO:TEXT, 10), "-"))) + CRLF + cMotivo }) 				//"Data do pagamento: "						
						Next nX
					EndIf
				EndIf
			ElseIf cName == "FopHstAftData"
				aAux := XmlChildEx ( oRet:_NEWDATASET, "_PFHSTAFT") //If XmlGetChild(oRet:_NEWDATASET, 2) <> Nil
				If ValType(aAux) <> Nil
					If ValType(aAux) == "O" 
						aAdd(aRestri, aAux)
					ElseIf ValType(aAux) == "A"
						aRestri := aClone(aAux)
					Else 
						cMsgErro += STR0055 + cChapa + CRLF + CRLF // "Problemas no xml de retorno mensagem ReadView. no Atendente:  "
						lRet := .F.
					EndIf
					If lRet
						For nX := 1 To Len(aRestri)
							If XmlChildEx ( aRestri[nX], "_OBSERVACAO" ) <>  Nil
								cMotivo	:= STR0061 + ALLTRIM(aRestri[nx]:_OBSERVACAO:TEXT) + CRLF // "Observação: " 
							EndIf
							If XmlChildEx ( aRestri[nX], "_DTFINAL" ) <>  Nil
								dDataF	:= aRestri[nx]:_DTFINAL:TEXT
								cTipo	:= "2"
							EndIf
							
							AADD(aRet, {PADR(aRestri[nx]:_CHAPA:TEXT, TamSX3("AA1_CDFUNC")[1]),;
										cTipo,;
										StoD(Strtran(Left(aRestri[nx]:_DTINICIO:TEXT, 10), "-")),;
										"04",;
										"2",;
										STR0062,; 
										StoD(Strtran(Left(dDataF, 10), "-")),;
										cMotivo + STR0063 + ALLTRIM(aRestri[nx]:_DESCAFAST:TEXT) + CRLF +;
										STR0064 + ALLTRIM(aRestri[nx]:_DESCMOTIVO:TEXT)}) /*"Afastamento"*/ // "Descrição do Afastamento: " ## "Descrição do motivo: "						
							dDataF := ""
							cTipo 	:= "1"
						Next nX
					EndIf
				EndIf
			ElseIF cName == "FopRescisaoData"
				aAux := XmlChildEx ( oRet:_NEWDATASET, "_PFUNC") //If XmlGetChild(oRet:_NEWDATASET, 2) <> Nil
				If ValType(aAux) <> Nil
					If ValType(aAux) == "O" 
						aAdd(aRestri, aAux)
					ElseIf ValType(aAux) == "A"
						aRestri := aClone(aAux)
					Else 
						cMsgErro += STR0055 + cChapa + CRLF + CRLF // "Problemas no xml de retorno mensagem ReadView. no Atendente:  "
						lRet := .F.
					EndIf
					If lRet
						For nX := 1 To Len(aRestri)
							dDataF := ""
							AADD(aRet, {	PADR(aRestri[nx]:_CHAPA:TEXT, TamSX3("AA1_CDFUNC")[1]),;
											"1",;
											StoD(Strtran(Left(aRestri[nx]:_DATADEMISSAO:TEXT, 10), "-")),;
											"03",;
											"2",;
											STR0065,;
											StoD(Strtran(Left(dDataF, 10), "-")),; 
											STR0066 + cValToChar(Stod(Strtran(Left(aRestri[nx]:_DATADEMISSAO:TEXT, 10), "-")))+ CRLF + STR0067 + ALLTRIM(aRestri[nx]:_MOTIVODEMISSAO:TEXT) + CRLF +;
											STR0068 + cValToChar(Stod(Strtran(Left(aRestri[nx]:_DTDESLIGAMENTO:TEXT, 10), "-")))}) /*"Demissão"*/ // "Tipo de demissão: " ## "Motivo da demissão: " ## "Data do desligamento: " 
						Next nX
					EndIf
				EndIf
			EndIf
		Else
			cMsgError	+= cError
		EndIF
	EndIf
	FreeObj(oWS)
	oWS := NIL
EndIf

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At012ResAll(aGeral, cCodTec, nInclu, nFalhaR, nLoop)
Função de gravação na TXB

@return	lOk - (.T.) gravou, (.F.) falha
@author	Augusto Albuquerque
@since 	14/08/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At012ResAll(aGeral, cCodTec, nInclu, nFalhaR, nLoop, oModel, cMotivo)
Local aRotAuto	:= {}
Local aBusca 	:= {}
Local lOk		:= .T.
Local lLoop		:= .F.
Local lImpRes	:= IsInCallStack("At012ImpRes")
Local nRegistro	:= Len(aGeral)
Local nX
Local nY
Local oModelTXB	:= Nil

AA1->(DbSetOrder(1))

If !lImpRes .OR. AA1->(DbSeek(xFilial("AA1")+cCodTec))
	
	If lImpRes
		oModel:SetOperation( MODEL_OPERATION_UPDATE )	
	EndIf
	oModel:Activate()
	oModelTXB := oModel:GetModel("TXBDETRH")
	For nY := 1 To Len(aGeral)	

		aBusca :=  { {"TXB_DTINI", aGeral[nY][3]}}
		If oModelTXB:SeekLine(aBusca,,.T. )
			If oModelTXB:GetValue("TXB_TEMPO") == "1"
				If !Empty(aGeral[nY][7])
					oModelTXB:SetValue("TXB_TEMPO", "2")
					oModelTXB:SetValue("TXB_DTFIM", aGeral[nY][7])
					nInclu++
					Loop
				EndIf
			EndIF
			lLoop := .T.
		Endif
		If lLoop
			lLoop := .F.
			nLoop++
			Loop
		Else
			oModelTXB:AddLine()
			nInclu++
		EndIf

		aAdd(aRotAuto,{"TXB_TEMPO"	,	aGeral[nY][2]})
		aAdd(aRotAuto,{"TXB_DTINI"	,	aGeral[nY][3]})
		aAdd(aRotAuto,{"TXB_MOTIVO"	,	aGeral[nY][4]})
		aAdd(aRotAuto,{"TXB_RESTRI"	,	aGeral[nY][5]})
		If aGeral[nY][2] == "2"
			aAdd(aRotAuto,{"TXB_DTFIM",	aGeral[nY][7]})
			If aGeral[nY][3] > aGeral[nY][7]
				nFalhaR++
				nInclu--
				cMotivo := STR0079 + aGeral[nY][6] + ": " + CRLF // "Erro ao cadastrar " 
				cMotivo += STR0080 + DToC(aGeral[nY][7]) + STR0081 + DToC(aGeral[nY][3]) + " )." // "Data final ( " ## " ) deve ser maior que a data inicial ( "
				nLoop++
				Loop  
			EndIf
		EndIf
		AaDd(aRotAuto, {"TXB_OBS",	aGeral[nY][8]})
		If lOk	
			For nX := 1 to LEN(aRotAuto)
				If !(oModelTXB:SetValue(aRotAuto[nX][1],aRotAuto[nX][2]))
					nFalhaR++
					nInclu--
				EndIf
			Next nX
		EndIf		
		aRotAuto := {}
	Next nY
	If nRegistro == nLoop 
		lOk := .T.
	Else 
		If oModel:VldData() .AND. oModel:CommitData()
			lOk := .T.
		Else
			lOk := .F.
		EndIf
	EndIf
EndIf
oModel:deActivate()
Return lOk