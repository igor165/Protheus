#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "CRMM030.CH"

Static _aDDICache	:= { ''/*Code*/,	''/*ACJ_PAIS*/	,''/*ACJ_PAIS_I*/	,''/*ACJ_PAIS_E*/ }
Static _aPosCache	:= { ''/*Code*/,	''/*UM_DESC*/	,''/*UM_DESC_I*/	,''/*UM_DESC_E*/  }
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMMCONTACTS

Serviço REST responsável pelo CRUD com o cadastro de CONTATOS 
autenticado no appCRM.

@author		Fábio Veiga
@since		13/12/2016
@version	12.1.19
/*/
//------------------------------------------------------------------------------
WSRESTFUL CRMMCONTACTS DESCRIPTION STR0001 //"Contatos do CRM"
	WSDATA IdContacts	AS STRING 	OPTIONAL
	WSDATA SearchKey 	AS STRING	OPTIONAL
	WSDATA Page			AS INTEGER	OPTIONAL
	WSDATA PageSize		AS INTEGER	OPTIONAL 
	WSDATA Language     AS STRING   OPTIONAL

	WSMETHOD GET 	DESCRIPTION STR0002	WSSYNTAX "/CRMMCONTACTS/{IdContacts, SearchKey, Page, PageSize}" //"Retorna os contatos do usuário do CRM"
	WSMETHOD POST 	DESCRIPTION STR0003	WSSYNTAX "/CRMMCONTACTS"										 //"Inclui Contato" 
	WSMETHOD PUT 	DESCRIPTION STR0004	WSSYNTAX "/CRMMCONTACTS/IdContact" 								 //"Altera Contato"
	WSMETHOD DELETE	DESCRIPTION STR0005	WSSYNTAX "/CRMMCONTACTS/IdContact" 								 //"Exclui Contato" 
ENDWSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET / CONTACTS
 Retorna os Contatos de um ou mais usuários (lista) 
autenticado no appCRM.

@param	IdContacts		, caracter, usuario do CRM. Ex: 000012 ou 000012,000013
		SearchKey		, caracter, Chave de pesquisa para ser considerado na consulta. 
		Page			, numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 40.
		PageSize		, numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 40 até 60.

@return lRet			, caracter, JSON com os contatos.

@author		Fábio Veiga
@since		13/12/2017
@version	12.1.19 
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE IdContacts, SearchKey, Page, PageSize, Language WSSERVICE CRMMCONTACTS

Local cTemp	     	:= GetNextAlias()
Local cResponse  	:= ""
Local cQuery	 	:= ""
Local cSearch		:= ""
Local cConcat		:= ""
Local cFilterSU5	:= ""
Local cDescription	:= ""
Local oJsonContacts := Nil
Local aContacts		:= {}
Local aJContacts  	:= {}
Local lRet 			:= .T.
Local aPhones		:= {}
Local nRecord		:= 0
Local nCount		:= 0
Local nContJson 	:= 0
Local nX			:= 0
Local nStart		:= 0

Local lPapNeg		:= .F.
Local lPriEmp		:= .F.
Local lComent		:= .F.

Default Self:IdContacts := ""
Default Self:SearchKey	:= ""
Default Self:Language	:= ""
Default Self:Page		:= 1
Default Self:PageSize	:= 20 


Private nModulo 		:= 73

Self:SetContentType("application/json")

//-------------------------------------------------------------------
// Nao aceita paginacao negativa.
//-------------------------------------------------------------------
If ( Positivo( Self:Page ) .And. Positivo( Self:PageSize ) )	

	If !Empty ( Self:Language )
		Self:Language := Lower( AllTrim( Self:Language ) )
 	EndIf

	If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[1] )
		Self:IdContacts := Self:aURLParms[1]
	EndIf
	
	cQuery := BuildQry(Self:SearchKey, Self:IdContacts)
	
	oJsonContacts := JsonObject():New()

	DBUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cTemp, .T., .T. )

	//-------------------------------------------------------------------
	// Validação dos Campos U5_PAPNEG, U5_PRIEMP, U5_COMENT
	//-------------------------------------------------------------------	
	lPapNeg := IIF( SU5->(ColumnPos("U5_PAPNEG") > 0), .T., .F.)
	lPriEmp := IIF( SU5->(ColumnPos("U5_PRIEMP") > 0), .T., .F.)
	lComent := IIF( SU5->(ColumnPos("U5_COMENT") > 0), .T., .F.)

	If (cTemp)->( !Eof() )
		//-------------------------------------------------------------------
		// Limita a pagina.
		//-------------------------------------------------------------------
		If Self:PageSize > 30 
			Self:PageSize := 20
		EndIf
		
		If Self:Page > 1
            nStart := ( (Self:Page-1) * Self:PageSize) +1 
        EndIf

		COUNT TO nRecord
		( cTemp )->( DBGoTop() )

		AGB->( DBSetOrder(1) )
		SU5->( DBSetOrder(1) )
		
		While (cTemp)->( !Eof() )
			
			If SU5->( MSSeek( (cTemp)->U5_FILIAL + (cTemp)->U5_CODCONT ) )
			
				nCount ++
				
				If ( nCount >= nStart )
					nContJson ++
					If nContJson <= Self:PageSize
					
						//Povoa o objeto Json
						aAdd( aJContacts,  JsonObject():New() )
						nLenCont := Len(aJContacts)
						
						aJContacts[nLenCont]["contact_id"		]	:= SU5->U5_CODCONT
						aJContacts[nLenCont]["contact_name"		]	:= CRMMText( SU5->U5_CONTAT, .T., .T. ) 
						aJContacts[nLenCont]["email"			]	:= SU5->U5_EMAIL

						If lPapNeg
							aJContacts[nLenCont]["negotiation_role"	]	:= SU5->U5_PAPNEG
						EndIf

						aJContacts[nLenCont]["position_code"	]	:= Alltrim(SU5->U5_FUNCAO)

						If Self:Language == "en"
							cDescription :=  Alltrim(GtPosCache( SU5->U5_FUNCAO)[3])
						ElseIf Self:Language == "es"
							cDescription :=  Alltrim(GtPosCache( SU5->U5_FUNCAO)[4])
						Else
							cDescription :=  Alltrim(GtPosCache( SU5->U5_FUNCAO)[2])
						EndIf

						aJContacts[nLenCont]["position_desc"	]	:= cDescription

						If lPriEmp
							aJContacts[nLenCont]["main_contact"		]	:= SU5->U5_PRIEMP
						EndIf

						If lComent
							aJContacts[nLenCont]["comments"			]	:= CRMMText( SU5->U5_COMENT, .F., .T. )
						EndIf

						aJContacts[nLenCont]["phones"			]	:= {}
						
						If AGB->( MSSeek( SU5->U5_FILIAL + "SU5" + SU5->U5_CODCONT ) )
							While ( AGB->( !Eof() ) .And. AGB->AGB_FILIAL = SU5->U5_FILIAL .And. AGB->AGB_ENTIDA == "SU5" .And. AllTrim( AGB->AGB_CODENT ) == SU5->U5_CODCONT)
								
								aAdd( aPhones, JsonObject():New() )
								nLenPhones := Len( aPhones )
								
								aPhones[nLenPhones]["phone_id"		]	:= AGB->AGB_CODIGO
								aPhones[nLenPhones]["type"			]	:= AGB->AGB_TIPO
								aPhones[nLenPhones]["ddi_code"		] 	:= AllTrim( AGB->AGB_DDI )

								If Self:Language == "en"
									cDescription :=  AllTrim( GtDDICache(AGB->AGB_DDI)[3] )
								ElseIf Self:Language == "es"
									cDescription :=  AllTrim( GtDDICache(AGB->AGB_DDI)[4] )
								Else
									cDescription :=  AllTrim( GtDDICache(AGB->AGB_DDI)[2] )
								EndIf

								aPhones[nLenPhones]["ddi_country"	] 	:= cDescription
								aPhones[nLenPhones]["ddd"			] 	:= AllTrim( AGB->AGB_DDD )
								aPhones[nLenPhones]["number"		]	:= AllTrim( AGB->AGB_TELEFO )
								aPhones[nLenPhones]["default"		]	:= StrTran( AGB->AGB_PADRAO," ", "2" )
								AGB->( DBSkip() )
							EndDo
							aJContacts[nLenCont]["phones"] := aPhones
							aPhones := {} 
						EndIf
					Else
						Exit
					EndIf
				EndIf
			
			EndIf
		
			(cTemp)->( DBSkip() )
		
		EndDo
		
		(cTemp)->( DBCloseArea() )
		
	EndIf
	oJsonContacts["contacts"]	:= aJContacts 
	oJsonContacts["count"] 		:= nRecord
	cResponse := FwJsonSerialize( oJsonContacts )
	Self:SetResponse( cResponse )
	FreeObj(oJsonContacts)
	oJsonContacts := Nil
Else
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( STR0006 ) ) //"Verifique se os parâmetros de paginacao estão negativos..."
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} POST / CONTACTS
 Inclui o Contato 
autenticado no appCRM.

@param	Nenhum
		 
@return lRet		, caracter, JSON com o Código do Contato Inserido e Mensagem de Sucesso ou Falha na inclusão

@author		Fábio Veiga
@since		13/12/2017
@version	12.1.19 
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSSERVICE CRMMCONTACTS
Local oJContact	:= Nil
Local cMessage	:= ""
Local cResponse := ""
Local cBody		:= Self:GetContent()
Local aContact	:= {}
Local aPhone	:= {}
Local aPhones	:= {}
Local nX		:= 0
Local lRet		:= .T.

Local lPapNeg		:= .F.
Local lPriEmp		:= .F.
Local lComent		:= .F.

Private lMsErroAuto 	:= .F.
Private lAutoErrNoFile	:= .T.
Private nModulo 		:= 73 

::SetContentType("application/json")
	
If !Empty( cBody )

	FWJsonDeserialize(cBody,@oJContact)
	
	DbSelectArea("SU5")

	//-------------------------------------------------------------------
	// Validação dos Campos U5_PAPNEG, U5_PRIEMP, U5_COMENT
	//-------------------------------------------------------------------	
	lPapNeg := IIF( SU5->(ColumnPos("U5_PAPNEG") > 0), .T., .F.)
	lPriEmp := IIF( SU5->(ColumnPos("U5_PRIEMP") > 0), .T., .F.)
	lComent := IIF( SU5->(ColumnPos("U5_COMENT") > 0), .T., .F.)

	SU5->( DbSetOrder(1) )
	
	If !Empty( oJContact )
		
		aAdd(aContact,{"U5_CONTAT"	, CRMMText( oJContact:contact_name, .T.)			,Nil}) 
		aAdd(aContact,{"U5_EMAIL" 	, oJContact:email 				 					,Nil})

		If lPapNeg
			aAdd(aContact,{"U5_PAPNEG" 	, FwNoAccent( Upper(oJContact:negotiation_role) )	,Nil})
		EndIf

		aAdd(aContact,{"U5_FUNCAO" 	, oJContact:position_code							,Nil})
		
		If lPriEmp
			aAdd(aContact,{"U5_PRIEMP" 	, FwNoAccent( Upper(oJContact:main_contact) )		,Nil})
		EndIf

		If lComent
			aAdd(aContact,{"U5_COMENT" 	, CRMMText( oJContact:comments, .F.,.T.	 )  		,Nil})
		EndIf

		For nX := 1 To Len( oJContact:phones )
			aAdd(aPhone,{"AGB_TIPO"		,oJContact:phones[nX]:type		,Nil})
			aAdd(aPhone,{"AGB_DDI"		,oJContact:phones[nX]:ddi_code	,Nil})
			aAdd(aPhone,{"AGB_DDD"		,oJContact:phones[nX]:ddd		,Nil})
			aAdd(aPhone,{"AGB_TELEFO"	,oJContact:phones[nX]:number	,Nil})
			aAdd(aPhone,{"AGB_PADRAO"	,oJContact:phones[nX]:default	,Nil})
			AAdd(aPhones, aPhone)
			aPhone := {}
		Next nX
		
		MSExecAuto({|x,y,z,b|TMKA070(x,y,z,b)},aContact,3,Nil,aPhones)
		
		If lMsErroAuto
			lRet		:= .F.
			cMessage	:= FwNoAccent( FwCutOff( GetAutoGrLog()[1] ) )
		Else
			cResponse	:= '{"sucessCode":200,"code_contact":"'+ SU5->U5_CODCONT +'","sucessMessage": "' + STR0007 + '"}'
		EndIf
		
	EndIf
	
EndIf

If lRet
	Self:SetResponse( cResponse )
Else
	SetRestFault( 400, cMessage )
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT / CONTACTS
 Altera o Contato 
autenticado no appCRM.

@param	Nenhum

@return lRet	, caracter, JSON com o Código do Contato Alterado e Mensagem de Sucesso ou Falha na alteração

@author		Fábio Veiga
@since		13/12/2017
@version	12.1.19 
/*/
//-------------------------------------------------------------------
WSMETHOD PUT WSSERVICE CRMMCONTACTS
	Local oJContact	:= Nil
	Local cMessage	:= ""
	Local cResponse := ""
	Local cContact	:= ""
	Local cBody		:= ""
	Local aContact	:= {}
	Local aPhone	:= {}
	Local aPhones	:= {}
	Local nX		:= 0
	Local lRet		:= .T.

	Local lPapNeg	:= .F.
	Local lPriEmp	:= .F.
	Local lComent	:= .F.

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.
	Private nModulo 		:= 73
	
	Self:SetContentType("application/json")
			
	If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[1] )
		
		cContact	:= Self:aURLParms[1]
		cBody 	 	:= Self:GetContent()
	
		If !Empty( cBody )
			
			FWJsonDeserialize(Upper(cBody),@oJContact)
			
			DbSelectArea("SU5")

			//-------------------------------------------------------------------
			// Validação dos Campos U5_PAPNEG, U5_PRIEMP, U5_COMENT
			//-------------------------------------------------------------------	
			lPapNeg := IIF( SU5->(ColumnPos("U5_PAPNEG") > 0), .T., .F.)
			lPriEmp := IIF( SU5->(ColumnPos("U5_PRIEMP") > 0), .T., .F.)
			lComent := IIF( SU5->(ColumnPos("U5_COMENT") > 0), .T., .F.)

			SU5->( DbSetOrder(1) )
			
			If !Empty( oJContact )
				
				If SU5->( MSSeek( xFilial("SU5") + cContact ) ) .And. oJContact:CONTACT_ID == cContact
					
					aAdd(aContact,{"U5_CODCONT", cContact,Nil})
					
					If AttIsMemberOf(oJContact,"contact_name") 
						aAdd(aContact,{"U5_CONTAT",CRMMText( oJContact:contact_name, .T., .T. ),Nil})
					EndIf
					
					If AttIsMemberOf(oJContact,"email") 
						aAdd(aContact,{"U5_EMAIL",oJContact:email,Nil})
					EndIf 

					If lPapNeg .And. AttIsMemberOf(oJContact,"negotiation_role")
						aAdd(aContact,{"U5_PAPNEG",oJContact:negotiation_role,Nil})
					EndIf
					
					If lPriEmp .And. AttIsMemberOf(oJContact,"main_contact") 
						aAdd(aContact,{"U5_PRIEMP",oJContact:main_contact,Nil})
					EndIf

					If AttIsMemberOf(oJContact,"position_code") 
						aAdd(aContact,{"U5_FUNCAO",oJContact:position_code,Nil})
					EndIf
					
					If lComent .And. AttIsMemberOf(oJContact,"comments") 
						aAdd(aContact,{"U5_COMENT",CRMMText( oJContact:comments, .F., .T. ),Nil})
					EndIf
					
					If AttIsMemberOf(oJContact,"phones")
						For nX := 1 To Len( oJContact:phones ) 
							
							If AttIsMemberOf(oJContact:phones[nX],"phone_id") 
								aAdd(aPhone,{"AGB_CODIGO"	,oJContact:phones[nX]:phone_id	,Nil})
							EndIf
							aAdd(aPhone,{"AGB_ENTIDA"	,"SU5"							,Nil})
							aAdd(aPhone,{"AGB_CODENT"	,cContact						,Nil})
							aAdd(aPhone,{"AGB_TIPO"		,oJContact:phones[nX]:type		,Nil})
							aAdd(aPhone,{"AGB_DDI"		,oJContact:phones[nX]:ddi_code	,Nil})
							aAdd(aPhone,{"AGB_DDD"		,oJContact:phones[nX]:ddd		,Nil})								
							aAdd(aPhone,{"AGB_TELEFO"	,oJContact:phones[nX]:number	,Nil})
							aAdd(aPhone,{"AGB_PADRAO"	,oJContact:phones[nX]:default	,Nil})
							AAdd(aPhones, aPhone)

							aPhone := {}
							
						Next nX
					Endif
				
					MSExecAuto({|x,y,z,b|TMKA070(x,y,z,b)},aContact,4,Nil,aPhones)
					
					If lMsErroAuto
						lRet		:= .F.
						cMessage	:= FwNoAccent( FwCutOff( GetAutoGrLog()[1] ) )
					Else
						cResponse	:= '{"sucessCode":200,"code_contact":"'+ SU5->U5_CODCONT +'","sucessMessage": "' + STR0008 + '"}' //"Contato alterado com sucesso..."
					EndIf						
				
				Else
					lRet := .F.
					cMessage := STR0009 //"Código do contato inválido para alteração ou dados do contato não é o mesmo utilizado no parâmetro..."
				Endif
			Else
				lRet := .F.
				cMessage := STR0010 //"Dados para atualização não foi informado..."			
			EndIf
		Else
			lRet := .F.
			cMessage := STR0010 //"Dados para atualização não foi informado..."
		EndIf
	Else
		lRet := .F.
		cMessage := STR0013 //"Id do contato não foi informado como parâmetro na URL..."
	EndIf

	If lRet
		Self:SetResponse( cResponse )
	Else
		SetRestFault( 400, cMessage )		
		Self:SetResponse( cMessage )
	EndIf
	
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE / CONTACTS
 Deleta o Contato 
autenticado no appCRM.

//Headers
@param	IdContacts	, caracter, usuario do CRM. Ex: 000012

@return lRet		, caracter, JSON com o Código do Contato Excluído e Mensagem de Sucesso ou Falha na exclusão

@author		Fábio Veiga
@since		13/12/2017
@version	12.1.19 
/*/
//-------------------------------------------------------------------

WSMETHOD DELETE WSSERVICE CRMMCONTACTS
Local oJContact	:= Nil
Local cMessage	:= ""
Local cResponse := ""
Local cContact	:= ""
Local aContact	:= {}
Local aPhone	:= {}
Local aPhones	:= {}
Local aError	:= {}
Local nX		:= 0
Local lRet		:= .T.

Private lMsErroAuto := .F.
Private lAutoErrNoFile	:= .T.
Private nModulo 	:= 73

::SetContentType("application/json")

SU5->( DbSetOrder(1) )

If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[1] )

	cContact := Self:aURLParms[1]
	
	If SU5->( MSSeek( xFilial("SU5") + cContact ) ) 
		
		aAdd(aContact,{"U5_CODCONT"	, SU5->U5_CODCONT ,Nil})
		aAdd(aContact,{"U5_CONTAT"	, SU5->U5_CONTAT  ,Nil})
		
		MSExecAuto({|x,y|TMKA070(x,y)},aContact,5) 
		
		If lMsErroAuto
			lRet		:= .F.
			aError 		:= GetAutoGrLog()
			If !Empty(aError)
				cMessage	:= FwNoAccent( FwCutOff( aError[1] ) )
			Else
				cMessage	:= STR0014 //"Este contato não poderá ser excluído..."
			EndIf
		Else
			cResponse	:= '{"sucessCode":200,"code_contact":"'+ SU5->U5_CODCONT +'","sucessMessage": "' + STR0011 + '"}' //"Contato excluído com sucesso..."
		EndIf
	Else
		cMessage	:= STR0012 //"Contato não localizado..."
	Endif
EndIf

If lRet
	Self:SetResponse( cResponse )
Else
	SetRestFault( 400, cMessage )
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GtPosCache()
Função para retornar o conteúdo do array de cache da tabela SUM Cargos

@param	cPosition	, caracter, Código do Cargo

@return _aPosCache	, Array, {UM_CARGO,	UM_DESC,UM_DESC_I,UM_DESC}

@author		Renato da Cunha
@since		19/01/2018
@version	12.1.20
/*/
//-------------------------------------------------------------------
Static Function GtPosCache(cPosition)
	Default cPosition	:= ''
	If  cPosition <> _aPosCache[1]
		If !Empty(cPosition)
			FindSUM(cPosition)
		Else
			ClPosCache()
		EndIf
	EndIf
Return _aPosCache

//-------------------------------------------------------------------
/*/{Protheus.doc} FindSUM()
Função para localizar um cargo na tabela SUM

@param	cPosition	, caracter, Código do Cargo

@return Nil

@author		Renato da Cunha
@since		19/01/2018
@version	12.1.20
/*/
//-------------------------------------------------------------------
Static Function FindSUM(cPosition)
	Local aAreaSUM	 	:= SUM->(GetArea())	
	Default cPosition	:= ''
	DbSelectArea('SUM')
	SUM->(DbSetOrder(1))
	If SUM->(MSSeek(xFilial('SUM') + cPosition ) )
		_aPosCache := { SUM->UM_CARGO, SUM->UM_DESC, SUM->UM_DESC_I, SUM->UM_DESC_E}
	Else
		ClPosCache()
	EndIf
	RestArea(aAreaSUM)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ClPosCache()
Função para limpar o cache de Cargos

@author		Renato da Cunha
@since		19/01/2018
@version	12.1.20
/*/
//-------------------------------------------------------------------
Static Function ClPosCache()
	_aPosCache	:= { '','','','' }
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GtDDICache()
Função para retornar o conteúdo do array de cache da tabela ACJ DDI

@param	cDDICode	, caracter, Código do DDI

@return _aDDICache	, Array, {ACJ_DDI, ACJ_PAIS, ACJ_PAIS_I, ACJ_PAIS_E}

@author		Renato da Cunha
@since		19/01/2018
@version	12.1.20
/*/
//-------------------------------------------------------------------
Static Function GtDDICache(cDDICode)
	Default cDDICode 	:= ''

	If  cDDICode <> _aDDICache[1]
		If !Empty(cDDICode)
			FindACJ(cDDICode)
		Else
			ClDDICache()
		EndIf
	EndIf

Return _aDDICache

//-------------------------------------------------------------------
/*/{Protheus.doc} FindACJ()
Função para localizar um DDI na tabela ACJ

@param	cDDICode	, caracter, Código do DDI

@return Nil

@author		Renato da Cunha
@since		19/01/2018
@version	12.1.20
/*/
//-------------------------------------------------------------------
Static Function FindACJ(cDDICode)
	Local aAreaACJ	 := ACJ->(GetArea())	
	Default cDDICode := ''
	DbSelectArea('ACJ')
	ACJ->(DbSetOrder(1))
	If ACJ->(MSSeek(xFilial('ACJ') + cDDICode ) )
		_aDDICache := { ACJ->ACJ_DDI, ACJ->ACJ_PAIS, ACJ->ACJ_PAIS_I, ACJ->ACJ_PAIS_E}
	Else
		ClDDICache()
	EndIf
	RestArea(aAreaACJ)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ClDDICache()
Função para limpar o cache de DDI

@author		Renato da Cunha
@since		19/01/2018
@version	12.1.20
/*/
//-------------------------------------------------------------------
Static Function ClDDICache()
	_aDDICache	:= { '','','','' }
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQry()
Constroi um Query para ser utilizada no DBUseAerea

@param      cSearchKey , caracter, Chave de Pesquisa 
           cContacts	, Caracter, Lista de Contatos

@return cQuery  	, caracter, Retorna Query

@author		Renato da Cunha
@since		27/03/2018
@version	12.1.17
/*/
//------------------------------------------------------------------- 
Static Function BuildQry(cSearchKey, cContacts)
	Local cQuery 		:= ''
	Local cFilterSU5	:= ''
	Local cConcat		:= IIF( ! "MSSQL" $ TCGetDB(), "||", "+" )
	Local nLenCont		:= 0
	Local nX			:= 0
	Local lIsDigit		:= .F.
	Local aContacts		:= {}

	If !Empty( cContacts )
		aContacts := StrTokArr( Upper( cContacts  ), "," )
	EndIf	
	
	cQuery := " SELECT SU5.U5_FILIAL, SU5.U5_CODCONT "
	cQuery += " FROM " + RetSqlName("SU5") + " SU5 "
	
	//-------------------------------------------------------------------
	// Monta o filtro para query de Oportunidades
	//-------------------------------------------------------------------
	cFilterSU5	:= CRMXFilEnt( "SU5", .T. )
	
	If	!Empty( cFilterSU5 )
		cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " " + "AO4 "
		cQuery += "ON AO4.AO4_CHVREG = SU5.U5_FILIAL " + cConcat + " SU5.U5_CODCONT AND AO4.D_E_L_E_T_ = ' ' "
	EndIf
	
	If IsDigit(cSearchKey)
		lIsDigit := .T. 
		cQuery  += " INNER JOIN AGBT10 AGB ON (AGB.AGB_CODENT = SU5.U5_CODCONT)"			
	Endif	
	
	cQuery += " WHERE "
	cQuery += " SU5.U5_FILIAL = '" + xFilial("SU5") + "' AND "
	
	If !Empty( aContacts ) 
		nLenCont := Len(aContacts)
		
		If nLenCont > 1
			cQuery += " SU5.U5_CODCONT IN ( " 
			For	nX := 1 To nLenCont 
				cQuery +=	"'" + aContacts[nX] + "'"
				If nX < nLenCont 
					cQuery +=	", "
				EndIf
			Next nX
		    cQuery += " ) AND "
		Else
			cQuery += " SU5.U5_CODCONT = '" + cContacts + "' AND "	
		EndIf
	
	ElseIf !Empty( cSearchKey )
		If !lIsDigit
			cSearch := AllTrim( Upper( FwNoAccent( cSearchKey ) ) )
			cQuery  += "( SU5.U5_CODCONT LIKE '%"	+ cSearch + "%' OR "
			cQuery  += "  SU5.U5_CONTAT  LIKE '%"	+ cSearch + "%' OR "
			cQuery  += "  SU5.U5_EMAIL   LIKE '%"	+ cSearch + "%' ) AND "
		Else
			cQuery += " SU5.U5_CPF  LIKE '%"   + cSearchKey + "%' OR "
			cQuery  += " AGB.AGB_TELEFO LIKE ('%"	+ cSearchKey + "%' ) AND "
		Endif
	EndIf
	
	If !Empty( cFilterSU5 ) 
		cQuery += cFilterSU5 + " AND "
	EndIf
	
	cQuery += " SU5.D_E_L_E_T_ = ' ' "

Return ChangeQuery(cQuery)