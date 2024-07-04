#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "CRMM050.CH" 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMMOPPORTUNITYCONTACT

Serviço REST responsável pelo cadastro de CONTATOS na oportunidade
autenticado no appCRM.

@author		Fábio Veiga
@since		13/12/2016
@version	12.1.19
/*/
//------------------------------------------------------------------------------
WSRESTFUL CRMMOPPORTUNITYCONTACT DESCRIPTION STR0001 	//"Adiciona um Contato na Oportunidade"
	WSMETHOD POST	DESCRIPTION STR0002	WSSYNTAX "/CRMMOPPORTUNITYCONTACT/IdOpportunity" 				//"Inclui um novo contato e vincula na Oportunidade"
	WSMETHOD PUT 	DESCRIPTION STR0012	WSSYNTAX "/CRMMOPPORTUNITYCONTACT/IdOpportunity/IdContact"		//"Vincula um contato já existente na Oportunidade"
	WSMETHOD DELETE DESCRIPTION STR0003	WSSYNTAX "/CRMMOPPORTUNITYCONTACT/IdOpportunity/IdContact"		//"Exclusao de Contato na Oportunidade"
ENDWSRESTFUL
//-------------------------------------------------------------------
/*/{Protheus.doc} POST / CONTACTS
Inclui o Contato na Oportunidade
autenticado no appCRM.

//Body
@param		Nenhum

@return 	cResponse		, caracter, JSON com o Código do Contato Inserido e Mensagem de Sucesso ou Falha na inclusão

@author		Fábio Veiga
@since		13/12/2017
@version	12.1.19
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSSERVICE CRMMOPPORTUNITYCONTACT
Local cBody			:= Upper(Self:GetContent())
Local cMessage		:= ""
Local cResponse 	:= ""
Local cEntity		:= ""
Local cNewCodCont	:= ""
Local cOpportunity	:= ""
Local cKey			:= ""
Local aContact		:= {}
Local aPhone		:= {}
Local aPhones		:= {}
Local aError		:= {}
Local nX			:= 0
Local lRet			:= .T.
Local oJOppContact	:= Nil
Local oModelCXEnt	:= Nil
Local oMdlAC8Grid   := Nil
Local oModelOpor	:= Nil
Local oMdlAD9		:= Nil

Local lPapNeg 		:= .F.
Local lPriEmp 		:= .F.
Local lComent 		:= .F.

Private lMsErroAuto := .F.
Private nModulo 	:= 73
Private lAutoErrNoFile  := .T.

Self:SetContentType("application/json")

If !Empty( cBody )
	
	FWJsonDeserialize(cBody,@oJOppContact)
	
	SU5->( DbSetOrder(1) )

	//-------------------------------------------------------------------
	// Validação dos Campos U5_PAPNEG, U5_PRIEMP, U5_COMENT
	//-------------------------------------------------------------------	
	lPapNeg := IIF( SU5->(ColumnPos("U5_PAPNEG") > 0), .T., .F.)
	lPriEmp := IIF( SU5->(ColumnPos("U5_PRIEMP") > 0), .T., .F.)
	lComent := IIF( SU5->(ColumnPos("U5_COMENT") > 0), .T., .F.)
	
	If ( Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[1] ) )
	
		cOpportunity := AllTrim( Self:aURLParms[1] )
		
		AD1->( DbSetOrder(1) )
		
		If AD1->( MSSeek( xFilial("AD1") + cOpportunity ) )
		
			If !Empty( oJOppContact )
							
				If AttIsMemberOf(oJOppContact,"contact_name") 
					aAdd(aContact,{"U5_CONTAT",CRMMText( oJOppContact:contact_name,.T., .T. ),Nil}) 
				EndIf
				
				If AttIsMemberOf(oJOppContact,"email") 
					aAdd(aContact,{"U5_EMAIL",oJOppContact:email,Nil})
				EndIf 
				
				If lPapNeg .And. AttIsMemberOf(oJOppContact,"negotiation_role")
					aAdd(aContact,{"U5_PAPNEG",oJOppContact:negotiation_role,Nil})
				EndIf
				
				If lPriEmp .And. AttIsMemberOf(oJOppContact,"main_contact")
					aAdd(aContact,{"U5_PRIEMP",oJOppContact:main_contact,Nil})
				EndIf 
				
				If AttIsMemberOf(oJOppContact,"position_code")
					aAdd(aContact,{"U5_FUNCAO",Alltrim( oJOppContact:position_code ),Nil})
				EndIf	

				If lComent .And. AttIsMemberOf(oJOppContact,"comments")
					aAdd(aContact,{"U5_COMENT",CRMMText( oJOppContact:comments, .F.,.T. ),Nil})
				EndIf				
				
				If AttIsMemberOf(oJOppContact,"phones")
					For nX := 1 To Len( oJOppContact:phones )
						aAdd(aPhone,{"AGB_TIPO"		,IIf( AttIsMemberOf(oJOppContact:phones[nX],"type"),oJOppContact:phones[nX]:type, "")	,Nil})
						aAdd(aPhone,{"AGB_DDI"		,IIf( AttIsMemberOf(oJOppContact:phones[nX],"ddi_code"),oJOppContact:phones[nX]:ddi_code, "")	,Nil})
						aAdd(aPhone,{"AGB_DDD"		,IIf( AttIsMemberOf(oJOppContact:phones[nX],"ddd"),oJOppContact:phones[nX]:ddd, "")	,Nil})
						aAdd(aPhone,{"AGB_TELEFO"	,IIf( AttIsMemberOf(oJOppContact:phones[nX],"number"),oJOppContact:phones[nX]:number, "")	,Nil})
						aAdd(aPhone,{"AGB_PADRAO"	,IIf( AttIsMemberOf(oJOppContact:phones[nX],"default"),oJOppContact:phones[nX]:default, "")	,Nil})
						AAdd(aPhones, aPhone)
						aPhone := {}
					Next nX			
				EndIf
	
				Begin Transaction
				
					MSExecAuto({|x,y,z,b|TMKA070(x,y,z,b)},aContact,3,Nil,aPhones)
					
					If lMsErroAuto
						lRet		:= .F.
						cMessage	:= FwNoAccent( FwCutOff( GetAutoGrLog()[1] ) )
					Else
						
						cNewCodCont := SU5->U5_CODCONT
						
						If !Empty( AD1->AD1_CODCLI ) .And. !Empty( AD1->AD1_LOJCLI )
							cEntity := "SA1"
							cKey 	:= AD1->AD1_CODCLI + AD1->AD1_LOJCLI
						Else
							cEntity := "SUS"
							cKey 	:= AD1->AD1_PROSPE + AD1->AD1_LOJPRO
						EndIf
						
						If ExistCpo(cEntity, cKey, 1)
						
							DBSelectArea("AC8")
							//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
							AC8->(DBSetOrder(2))
							
							AC8->( MSSeek( xFilial("AC8") + cEntity + cKey ) )
							
							oModelCXEnt := FwLoadModel("CRMA060")
							oModelCXEnt:SetOperation( MODEL_OPERATION_UPDATE )
							oModelCXEnt:GetModel("AC8MASTER"):bLoad := {|| {xFilial("AC8"),xFilial( cEntity ),cEntity,cKey,""}}
							oModelCXEnt:Activate()
							
							If oModelCXEnt:IsActive()
											
								oMdlAC8Grid	:= oModelCXEnt:GetModel("AC8CONTDET")
								
								If !oMdlAC8Grid:SeekLine({{"AC8_CODCON",cNewCodCont}})
									nLength := oMdlAC8Grid:Length()
									If oMdlAC8Grid:AddLine() > nLength
										oMdlAC8Grid:SetValue("AC8_CODCON",cNewCodCont)
									Else
										aError := oModelCXEnt:GetErrorMessage()
									EndIf
								EndIf
								
								If oModelCXEnt:VldData()
									If oModelCXEnt:CommitData()
										
										oModelOpor := FwLoadModel("FATA300")
										oModelOpor:SetOperation( MODEL_OPERATION_UPDATE )
										oModelOpor:Activate()
										
										If oModelOpor:IsActive()
											
											oMdlAD9	:= oModelOpor:GetModel("AD9DETAIL")
											If !oMdlAD9:SeekLine({{"AD9_CODCON",cNewCodCont}})
												nLength := oMdlAD9:Length()
												If oMdlAD9:AddLine() > nLength
													oMdlAD9:SetValue("AD9_CODCON",cNewCodCont)
												Else
													aError := oModelOpor:GetErrorMessage()
												EndIf
											EndIf
											
											If oModelOpor:VldData()
												oModelOpor:CommitData()
											Else
												aError := oModelOpor:GetErrorMessage()
											EndIf
										Else
											aError := oModelOpor:GetErrorMessage()
										EndIf
									EndIf
								Else
									aError := oModelCXEnt:GetErrorMessage()
								EndIf
							Else
								aError := oModelCXEnt:GetErrorMessage()
							EndIf
							
							If !Empty ( aError )
								lRet 		:= .F.
								cMessage	:= FwNoAccent( aError[6] )
								DisarmTransaction()
							Else
								cResponse	:= '{"sucessCode":200,"code_contact":"'+ cNewCodCont +'","sucessMessage": "' + EncodeUTF8(STR0004) + '"}' //"Contato incluido com sucesso..." 
							EndIf
							
						Else
							lRet 	 := .F.
							cMessage := STR0005 //"Entidade não encontrada..."
						EndIf
						
					EndIf
				
				End Transaction
													
			Else
				lRet 	 := .F.
				cMessage := STR0006	//"Falha na conversão do objeto..."
			EndIf
		Else
			lRet 	 := .F.
			cMessage := STR0007	//"Oportunidade não localizada..."
		EndIf
	Else
		lRet 	 := .F.
		cMessage := STR0008 //"Falha na leitura do parametro..."
	EndIf
Else
	lRet 	 := .F.
	cMessage := STR0009 //"O Id da Oportunidade não foi informado..."
EndIf

If lRet
	Self:SetResponse( cResponse )
Else
	SetRestFault( 400, EncodeUTF8(cMessage) )
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT / CONTACTS
Altera o Contato
autenticado no appCRM.

//Headers
@param		Nenhum

@return 	cResponse	, caracter, JSON com o Código do Contato Excluído e Mensagem de Sucesso ou Falha na exclusão

@author		Fábio Veiga
@since		13/12/2017
@version	12.1.19
/*/
//-------------------------------------------------------------------
WSMETHOD PUT WSSERVICE CRMMOPPORTUNITYCONTACT
Local cMessage		:= ""
Local cResponse 	:= ""
Local cOpportunity	:= ""
Local cContact		:= ""
Local aError		:= {}
Local lRet			:= .T.
Local oModelOpor	:= Nil
Local oMdlAD9		:= Nil
Local nLength		:= 0

Private nModulo 	:= 73
Private lAutoErrNoFile  := .T.

::SetContentType("application/json")	

If ( Len(Self:aURLParms) > 1 .And. !Empty( Self:aURLParms[1] ) .And. !Empty( Self:aURLParms[2] ) )

	cOpportunity := AllTrim( Self:aURLParms[1] )
	cContact	 := AllTrim( Self:aURLParms[2] )
	
	AD1->( DbSetOrder(1) )
		
	If AD1->( MSSeek( xFilial("AD1") + cOpportunity ) )
		
		oModelOpor := FwLoadModel("FATA300")
		oModelOpor:SetOperation( MODEL_OPERATION_UPDATE )
		oModelOpor:Activate()
		
		If oModelOpor:IsActive()
			oMdlAD9	:= oModelOpor:GetModel("AD9DETAIL")
			
			If !oMdlAD9:SeekLine({{"AD9_CODCON",cContact}})

				nLength := oMdlAD9:Length()
				If oMdlAD9:AddLine() > nLength
					oMdlAD9:SetValue("AD9_CODCON",cContact)
					If oModelOpor:VldData()
						oModelOpor:CommitData()
						cResponse	:= '{"sucessCode":200,"sucessMessage": "' + EncodeUTF8(STR0004) + '"}' //"Contato incluido com sucesso..." 
					Else
						aError := oModelOpor:GetErrorMessage()
					EndIf
				Else
					aError := oModelOpor:GetErrorMessage()
				EndIf
			Else
				lRet 	 := .F.
				cMessage := STR0013 //"Contato já existe na Oportunidade"
			EndIf
			
		Else
			aError := oModelOpor:GetErrorMessage()
		EndIf

		If !Empty ( aError )
			lRet 		:= .F.
			cMessage	:= FwNoAccent( aError[6] )
		EndIf

	Else
		lRet 	 := .F.
		cMessage := STR0007 //"Oportunidade não localizada...."
	EndIf
Else
	lRet 	 := .F.
	cMessage := STR0008 //"Falha na leitura do parametro..."
EndIf

If lRet
	Self:SetResponse( cResponse )
Else
	SetRestFault( 400, EncodeUTF8(cMessage) )
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE / CONTACTS
Deleta o Contato
autenticado no appCRM.

@param		Nenhum

@return 	cResponse		, caracter, JSON com o Código do Contato Excluído e Mensagem de Sucesso ou Falha na exclusão

@author		Fábio Veiga
@since		13/12/2017
@version	12.1.19
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE WSSERVICE CRMMOPPORTUNITYCONTACT
Local cMessage		:= ""
Local cResponse 	:= ""
Local cOpportunity 	:= ""
Local cContact	 	:= ""
Local aError		:= {}
Local lRet			:= .T.
Local oModelOpor	:= Nil
Local oMdlAD9		:= Nil

Private lAutoErrNoFile  := .T.

Self:SetContentType("application/json")	

If ( Len(Self:aURLParms) > 1 .And. !Empty( Self:aURLParms[1] ) .And. !Empty( Self:aURLParms[2] ) )
	
	cOpportunity := AllTrim( Self:aURLParms[1] )
	cContact	 := AllTrim( Self:aURLParms[2] )
	
	AD1->( DbSetOrder(1) )
		
	If AD1->( MSSeek( xFilial("AD1") + cOpportunity ) )
		
		oModelOpor := FwLoadModel("FATA300")
		oModelOpor:SetOperation( MODEL_OPERATION_UPDATE )
		oModelOpor:Activate()
		
		If oModelOpor:IsActive()
			oMdlAD9	:= oModelOpor:GetModel("AD9DETAIL")
			
			If oMdlAD9:SeekLine({{"AD9_CODCON",cContact}})
				oMdlAD9:DeleteLine()
				If oModelOpor:VldData()
					oModelOpor:CommitData()
					cResponse	:= '{"sucessCode":200,"sucessMessage": "' + EncodeUTF8(STR0011) + '"}' //Contato excluido com sucesso...
				Else
					aError := oModelOpor:GetErrorMessage()
				EndIf
			Else
				lRet 	 := .F.
				cMessage := STR0010 //"Contato não localizado..."
			EndIf
			
			
		Else
			aError := oModelOpor:GetErrorMessage()
		EndIf

		If !Empty ( aError )
			lRet 		:= .F.
			cMessage	:= FwNoAccent( aError[6] )
		EndIf
		
	Else
		lRet 	 := .F.
		cMessage := STR0007 //"Oportunidade não localizada...."
	EndIf
Else
	lRet 	 := .F.
	cMessage := STR0008 //"Falha na leitura do parametro..."
EndIf


If lRet
	Self:SetResponse( cResponse )
Else
	SetRestFault( 400, EncodeUTF8(cMessage) )
EndIf

Return( lRet )