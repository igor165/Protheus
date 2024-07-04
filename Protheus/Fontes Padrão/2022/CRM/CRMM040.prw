#INCLUDE "TOTVS.CH" 
#INCLUDE "RESTFUL.CH"
#INCLUDE "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "CRMM040.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMMENTITYXCONTACTS

Serviço REST responsável pelo modificação dos registros Entidade x Contato - tabela AC8
autenticado no appCRM.

@author		Ermerson Rafael
@since		12/12/2017
@version	12.1.19
/*/
//------------------------------------------------------------------------------


WSRESTFUL CRMMENTITYXCONTACTS DESCRIPTION STR0001		//Serviço Entidade X Contato
	WSMETHOD GET	DESCRIPTION STR0002 WSSYNTAX "/CRMMENTITYXCONTACTS/Entity/Key"			//Retorna uma lista de contatos de uma entidade solicitada
	WSMETHOD POST	DESCRIPTION STR0003 WSSYNTAX "/CRMMENTITYXCONTACTS/Entity/Key/IdEntity"	//Realiza uma inclusão de um contato para uma entidade informada
	WSMETHOD DELETE	DESCRIPTION STR0004 WSSYNTAX "/CRMMENTITYXCONTACTS/Entity/Key/IdEntity"	//Deleta uma relação entre um contato e entidade
ENDWSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET / ENTIDADExCONTATO
Retorna uma lista de contatos da entidade solicitada.
Autenticacao  no appCRM.

//Headers
@param	Entity	,caracter, Descricao da entidade que sera chave de consulta dos contatos relacionados EX:SA1
  		Key		,caracter, Código da entidade que sera chave de consulta dos contatos relacionados 	 EX: 0002  02

@return lRet	, logico, JSON com a descricao de entidade, codigo da entidade e codigo do cntato

@author		Ermerson Silva
@since		12/12/2017
@version	12.1.18
/*/
//-------------------------------------------------------------------

WSMETHOD GET WSSERVICE CRMMENTITYXCONTACTS		
	Local cResponse	:= ""
	Local aEntities	:= {}
	Local cEntity	:= ""
	Local cKey		:= ""	
	Local cTemp		:= ""
	Local cQuery	:= ""
	Local cMessage	:= ''
	Local lRet 		:= .T.
	
	Private nModulo 	:= 73	
	
	Self:SetContentType("application/json")	 	
		
	If ( Len(Self:aURLParms) == 2 .And. !Empty( Self:aURLParms[1] )	 .And. !Empty( Self:aURLParms[2] ) )		
		
		cEntity := AllTrim( Upper(Self:aURLParms[1]) )
		cKey	:= AllTrim( Upper(Self:aURLParms[2]) )
		
		If(FWAliasInDic(cEntity))
			cTemp := GetNextAlias()		
			
			cQuery := " SELECT AC8_ENTIDA, AC8_CODENT, AC8_CODCON  "
			cQuery += " FROM " + RetSqlName("AC8") 		
			cQuery += " WHERE AC8_ENTIDA = '" + cEntity + "' AND AC8_CODENT  = '" + cKey + "' AND "
			cQuery += " D_E_L_E_T_ = ' ' "
			
			cQuery := ChangeQuery( cQuery )
		
			DBUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cTemp, .T., .T.) 
					
			While (cTemp)->(!Eof())						
				AAdd(aEntities, JsonObject():new())     
				nMaxElemnt := Len(aEntities)
				aEntities[nMaxElemnt]["ENTITY"]       	:= AllTrim((cTemp)-> AC8_ENTIDA)
				aEntities[nMaxElemnt]["ENTITY_KEY"]  	:= AllTrim((cTemp)-> AC8_CODENT)
				aEntities[nMaxElemnt]["CONTACT_ID"]   	:= AllTrim((cTemp)-> AC8_CODCON)
				aEntities[nMaxElemnt]["CONTACT_NAME"]	:= CRMMText( Posicione("SU5",1,xFilial("AC8")+(cTemp)-> AC8_CODCON,"U5_CONTAT"), .F., .T. )
				
				(cTemp)->(DBSkip())
			EndDo	

			If Empty(aEntities)
				lRet := .F.
				cMessage := STR0013 + CHR(10) + cEntity + CHR(10) + STR0014 + CHR(10) + cKey //'Não existem Contatos atrelados a Entidade:' #### 'Com a Chave Código/Filial:'
			Else
				cResponse := FwJsonSerialize(aEntities)
			EndIf
		Else
			lRet := .F.
			cMessage := STR0012  //O Alias informado não existe nos arquivos de dados...
		EndIf
	Else
		lRet := .F.
		cMessage := STR0005		//"Os parâmetros Entity e Key não foram preeenchidos corretamente..."
	EndIf

	If lRet
		Self:SetResponse(cResponse)
		Asize(aEntities,0)
	Else
		SetRestFault( 400, EncodeUTF8(cMessage) )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST / ENTIDADExCONTATO
Realiza a inclusao de um contato caso nao exista e inclui o mesmo a uma entidade
Autenticacao  no appCRM.

//Headers 
@param	Entity		,caracter, Descricao da entidade que sera chave de consulta dos contatos relacionados 	EX:SA1
  		Key			,caracter, Codigo da entidade que sera chave de consulta dos contatos relacionados 		EX:0002  02
  		IdContato	,caracter, Identificador do contato que sera relacionado com a entidade  	 			EX:000001

@return lRet		,logico, Retorna se a inclusao foi realizada com sucesso, true or false

@author		Ermerson Silva
@since		12/12/2017
@version	12.1.18
/*/
//-------------------------------------------------------------------			
						
WSMETHOD POST WSSERVICE CRMMENTITYXCONTACTS
	
	Local cResponse	:= ""
	Local oModel	:= Nil	
	Local oMdlGrid	:= Nil
	Local cMessage	:= ""
	Local cEntity	:= ""
	Local cKey		:= ""	
	Local cContact	:= ""
	Local aError	:= {}
	Local nLength	:= 0
	Local lRet		:= .T.
	
	Private nModulo := 73	
	
	Self:SetContentType("application/json")	
	
	If ( Len(Self:aURLParms) == 3 .And. !Empty( Self:aURLParms[1] )	 .And. !Empty( Self:aURLParms[2] ) .And. !Empty( Self:aURLParms[3] ) )
	
		cEntity		:= AllTrim( Self:aURLParms[1] )
		cKey		:= AllTrim( Self:aURLParms[2] )	
		cContact	:= AllTrim( Self:aURLParms[3] )
		
		If(FWAliasInDic(cEntity))
		
			If ExistCpo(cEntity, cKey, 1 )
			
				DBSelectArea("AC8")
				//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
				AC8->(DBSetOrder(2))
								
				AC8->( MSSeek( xFilial("AC8") + cEntity + cKey ) )
								
				oModel := FwLoadModel("CRMA060")
				oModel:SetOperation( MODEL_OPERATION_UPDATE )
				oModel:GetModel("AC8MASTER"):bLoad := {|| {xFilial("AC8"),xFilial( cEntity ),cEntity,cKey,""}}
				oModel:Activate()
				
				If oModel:IsActive()				
					oMdlGrid := oModel:GetModel("AC8CONTDET")
					nLength := oMdlGrid:Length()
									 
					If oMdlGrid:AddLine() > nLength				
						oMdlGrid:SetValue("AC8_CODCON",cContact)				
					Else
						lRet	:= .F.
						aError	:= oModel:GetErrorMessage()
					EndIf
		
					If oModel:VldData()
						oModel:CommitData()
						cResponse	:= '{"sucessCode":200, "sucessMessage": "' + STR0006 + '"}' //Contato incluido com sucesso                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
					Else
						lRet	:= .F.
						aError	:= oModel:GetErrorMessage()
					EndIf
									
				Else
					lRet	:= .F.
					aError	:= oModel:GetErrorMessage()
				EndIf
				
				If !Empty ( aError )
					lRet 		:= .F.
					cMessage	:= FwNoAccent( aError[6] )
				EndIf
			
			Else
				lRet := .F.
				cMessage := STR0007 //"Entidade não foi encontrada"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
			EndIf
		Else
			lRet := .F.
			cMessage := STR0012  //O Alias informado não existe nos arquivos de dados...
		EndIf
	Else
		lRet := .F.
		cMessage := STR0008 //"Os parâmetros Entity, Key e IdContact não foram preenchidos..."                                                                                                                                                                                                                                                                                                                                                                                                                                                     
	EndIf
	
	If lRet  
		Self:SetResponse( cResponse )
	Else
		SetRestFault(400, EncodeUTF8(cMessage) )
	EndIf
	
Return lRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE / ENTIDADExCONTATO
Deleta um contato de um determinada entidade conforme solicitada
Autenticacao  no appCRM.

//Headers 
@param	Entity		,character, Descricao da entidade que sera chave de consulta dos contatos relacionados 	EX:SA1
  		Key			,character, Codigo da entidade que sera chave de consulta dos contatos relacionados 	EX:0002  02
  		IdContato	,character, Identificador do contato que sera deletado da relacao com a entidade		EX:000001

@return lRet		,logico, 	Retorna se foi deletado, true or false

@author		Ermerson Silva
@since		12/12/2017
@version	12.1.18
/*/
//-------------------------------------------------------------------	

WSMETHOD DELETE WSSERVICE CRMMENTITYXCONTACTS
	
	Local cResponse	:= ""
	Local oModel	:= Nil	
	Local oMdlGrid	:= Nil
	Local cMessage	:= ""
	Local cEntity	:= ""
	Local cKey		:= ""	
	Local cContact	:= ""
	Local aError	:= {}
	Local nLength	:= 0
	Local lRet		:= .T.
	
	Self:SetContentType("application/json")	

	If ( Len(Self:aURLParms) == 3 .And. !Empty( Self:aURLParms[1] )	 .And. !Empty( Self:aURLParms[2] ) .And. !Empty( Self:aURLParms[3] ) )
		
		cEntity 	:= AllTrim( Self:aURLParms[1] )
		cKey		:= AllTrim( Self:aURLParms[2] )
		cContact	:= AllTrim( Self:aURLParms[3] )
		
		If (FWAliasInDic(cEntity))
			If ExistCpo(cEntity, cKey, 1 )
			
				DBSelectArea("AC8")
				//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
				AC8->(DBSetOrder(2))
								
				AC8->( MSSeek( xFilial("AC8") + cEntity + cKey ) )
								
				oModel := FwLoadModel("CRMA060")
				oModel:SetOperation( MODEL_OPERATION_UPDATE )
				oModel:GetModel("AC8MASTER"):bLoad := {|| {xFilial("AC8"),xFilial( cEntity ),cEntity,cKey,""}}
				oModel:Activate()
				
				If oModel:IsActive()				
					oMdlGrid := oModel:GetModel("AC8CONTDET")
					nLength := oMdlGrid:Length()
									 
					If oMdlGrid:SeekLine({{"AC8_CODCON",cContact}})
						oMdlGrid:DeleteLine()
						
						If oModel:VldData()
							oModel:CommitData()
							cResponse	:= '{"sucessCode":200, "sucessMessage": "' + STR0009 + '"}'	//"Contato excluido com sucesso...
						Else
							lRet	:= .F.
							aError	:= oModel:GetErrorMessage()
						EndIf
						
					Else
						lRet 	 := .F.
						cMessage := STR0010 //"Contato não localizado..."
					EndIf
				
				Else
					lRet	:= .F.
					aError	:= oModel:GetErrorMessage()
				EndIf
				
				If !Empty ( aError )
					lRet 		:= .F.
					cMessage	:= FwNoAccent( aError[6] )
				EndIf
			
			Else
				lRet := .F.
				cMessage := STR0007 //"Entidade não encontrada..."
			EndIf
		Else
			lRet := .F.
			cMessage := STR0012 //O Alias informado não existe nos arquivos de dados...
		EndIf		
	Else
		lRet := .F.
		cMessage := STR0011//"Os parâmetros Entity, Key, IdContact não foram informados na URL..."
	EndIf
	
	If lRet  
		Self:SetResponse( cResponse )
	Else
		SetRestFault(400, EncodeUTF8(cMessage) )
	EndIf
	
Return lRet 	