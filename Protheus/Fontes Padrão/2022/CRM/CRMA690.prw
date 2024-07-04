#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA690.CH"

Static oTerritory	:= Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA690EvalTerritory
Faz a avalia��o do(s) melhor(es) territorio(s) para atender uma conta.

@param cProcess, caracter, Codigo do processo (MATA030,TMKA260,TMKA341).
@param cEntity, caracter, Entidade (SA1,SUS,ACH). 
@param lInterface	, l�gico, Identifica se o territ�rio avaliado ser� exibido ao usu�rio. 
@param lForce		, l�gico, Identifica se deve exibir interface mesmo quando n�o h� empate. 
@param cScript, caracter, Script que ser� executado durante a avalia��o do territ�riod. 
@param cFilter, caracter, Define o tipo de territ�rio que ser� avaliado sendo: 1 - Territ�rio e 2 - Reposit�rio
@param dDate, data, Data para avalia��o do territ�rio.
@param cSequence, caracter, Define uma sequencia de avalia��o dos agrupadores para avalia��o da entidade.
( Por padr�o a sequencia utilizada � da propria entidade avaliada, caso haja. )

@return aInfo, array, Retorno da avalia��o no formato { STATUS, TERRITORIO, LOG }.

@author		Anderson Silva
@version	12
@since		30/06/2015 
/*/
//-------------------------------------------------------------------
Function CRMA690EvalTerritory( cProcess, cEntity, lInterface, lForce, cScript, cFilter, dDate, cSequence )
	
	Local aInfo				:= {.T.,"", ""}
	Local lIsBlind			:= IsBlind()
	Local lCRMTerr			:= SuperGetMV("MV_CRMTERR",.F.,.F.)
	Local bRunTerritory		:= {|| }
	Local aParams				:= {}
	Local uParams				:= Nil
	Local lPERunTerr			:= ExistBlock("CRMRUNTERRITORY")
	Local lRet					:= .T.
	
	
	Default cProcess   		:= ""
	Default cEntity    		:= ""
	Default cFilter 			:= ""
	Default lInterface 		:= .T.
	Default lForce			:= .F.	
	Default cScript 	  		:= cProcess
	Default dDate				:= dDatabase
	Default cSequence			:= ""
		
	If lCRMTerr
		
		//Caso a rotina seja chamada de execauto ou job n�o apresenta a interface.
		If lIsBlind
			lInterface	:= .F.
			lForce		:= .F.
		EndIf
		
		If lPERunTerr
			
			//Usuario poder� alterar os parametros antes da execu��o da avalia��o do territorio.
			aParams	:= { cProcess, cEntity, lInterface, lForce, cScript, cFilter, dDate, cSequence }
			uParams 	:= ExecBlock("CRMRUNTERRITORY",.F.,.F.,aParams)

			If ValType( uParams ) == "A" .And. Len( uParams ) > 0  
				If Len( uParams ) == 8
					lInterface	:= uParams[3]
					lForce		:= uParams[4]
					cScript 	:= uParams[5]
					cFilter 	:= uParams[6]
					dDate 		:= uParams[7]
					cSequence	:= uParams[8]	
				Else
					Help(,,"CRMA690EvalTerritory",,STR0005,1,0,,,,,,{STR0006}) //"N�o foi poss�vel avaliar o territ�rio devido o retorno do ponto de entrada CRMRUNTERRITORY est� inv�lido..."
					lRet := .F.
				EndIf
			EndIf
			
		EndIf
		
		If lRet
			bRunTerritory := {|| aInfo := RunTerritory( cProcess, cEntity, lInterface, lForce, cScript, cFilter, dDate, cSequence ) }
					
			If lInterface 
				FWMsgRun(/*oComponent*/,{|| Eval( bRunTerritory )   },,STR0001) //"Avaliando os territ�rios..."
			Else
				Eval( bRunTerritory )	
			EndIf
		EndIf
		
	EndIf
	
Return(aInfo)

//-------------------------------------------------------------------
/*/{Protheus.doc} RunTerritory
Executa a avalia��o do(s) melhor(es) territorio(s) para atender uma conta.

@param cProcess, caracter, Codigo do processo (MATA030,TMKA260,TMKA341).
@param cEntity, caracter, Entidade (SA1,SUS,ACH). 
@param lInterface	, l�gico, Identifica se o territ�rio avaliado ser� exibido ao usu�rio. 
@param lForce		, l�gico, Identifica se deve exibir interface mesmo quando n�o h� empate. 
@param cScript, caracter, Script que ser� executado durante a avalia��o do territ�riod. 
@param cFilter, caracter, Define o tipo de territ�rio que ser� avaliado sendo: 1 - Territ�rio e 2 - Reposit�rio
@param dDate, data, Data para avalia��o do territ�rio.
@param cSequence, caracter, Define uma sequencia de avalia��o dos agrupadores para avalia��o da entidade.
( Por padr�o a sequencia utilizada � da propria entidade avaliada, caso haja. ) 

@return aTerritory, array, Retorno da avalia��o no formato { STATUS, TERRITORIO, LOG }.

@author		Anderson Silva
@version	12
@since		30/06/2015 
/*/
//-------------------------------------------------------------------
Static Function RunTerritory(cProcess, cEntity, lInterface, lForce, cScript, cFilter, dDate, cSequence )
	Local oScript		:= Nil 
	Local lRetorno		:= .T.
	Local cIdTerritory	:= ""
	Local cLog			:= ""
	Local aError		:= {}
	Local nX			:= 0

	If ( !Empty( cProcess ) .And. cProcess $ "MATA030|TMKA260|TMKA341" .And.;
		  !Empty( cEntity ) .And. cEntity $ "SA1|SUS|ACH" )
		
		// Classe respons�vel pelo processamento e gest�o dos dados do processo de avalia��o de territ�rio
		oTerritory := CRMTerritory( ):New( )
		oTerritory:SetProcess( cProcess )
		oTerritory:SetEntity( cEntity )
		oTerritory:SetFilter( cFilter ) 
		
		If !Empty( cSequence )
			oTerritory:SetSequence( cSequence )
		EndIf
		
		oTerritory:SetBaseDate( dDate ) 
		oTerritory:GetTerritory( lInterface, lForce )
		
		cIdTerritory 	:= oTerritory:GetInfo(1)
		cLog			:= oTerritory:GetLog()
		
		//Se encontrar algum territorio executar o script.
		If ( ! Empty( cIdTerritory ) )
			
			oScript := CRMScript():New()
			oScript:SetScript( cScript )
			lRetorno := oScript:EvalScript( 1, oTerritory, lInterface )
			
			If !lRetorno
				aError := oScript:GetError()
			EndIf
			
		Else 
			lRetorno	:= .F. 
			aAdd(aError,{"CRMA690",STR0004}) //"N�o encontramos territ�rios que atendam esta entidade!"
			aAdd(aError,{"", cLog } )
		EndIf		
	Else
		lRetorno	:= .F.
		aAdd(aError,{"CRMA690",STR0002}) //"N�o foi possivel avaliar o territ�rio!"
	EndIf
	
	If ! ( Empty( aError ) )
	
		For nX := 1 To Len(aError)
			AutoGrLog(aError[ nX ][ 1 ]	 + ' [' + AllToChar( aError[ nX ][ 2 ]) + ']' ) //"Id"
		Next nX
		
		If lInterface
			MostraErro()
		EndIf
		
		//-------------------------------------------------------------------
		//N�o considerar como erro nas rotinas automaticas, caso a classe
		//CRMTerritory n�o retorne nenhum territorio.
		//( MostraErro ser� apresentado somente como notifica��o... )
		//-------------------------------------------------------------------
		If ( Type("lMSErroAuto") == "L" .And. Empty( cIdTerritory ) )
			lMSErroAuto := .F.  
		EndIf
		
	EndIf
	
	If !Empty( oScript )
		oScript:Destroy()
	EndIf
			
Return({ lRetorno, cIdTerritory, cLog })

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA690CasterTerritory

Faz a distribuicao da conta + rodizio para o territorio vencedor.

@sample		CRM690CasterTerritory(cProcess, cEntity, cIdTerritory, cScript, lSimulation))

@param		cProcess 	 - Codigo do processo (MATA030,TMKA260,TMKA341)
			cEntity 	 - Entidade (SA1,SUS,ACH)
			cIdTerritory - C�digo do territorio que ser� executado o processo de rodizio.
			cScript 	 - Script que ser� executado durante a avalia��o do territ�rio.
			lSimulation	 - Define que o processo de rodizio ser� apenas uma simulacao.

@return		aInfo - Array com as seguintes informacoes:
			{lRetorno, cIdTerritory, cTypeMember, cMember}

@author		Anderson Silva
@since		30/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA690CasterTerritory(cProcess, cEntity, cIdTerritory, cScript, lSimulation)
	Local lIsBlind			:= IsBlind()
	Local aInfo				:= {.F.,"","",""}
	Local lCRMTerr			:= SuperGetMV("MV_CRMTERR",.F.,.F.)
	Local bRunCaster			:= {|| }
	
	Default cProcess   		:= ""
	Default cEntity    		:= ""
	Default cIdTerritory	:= ""
	Default cScript			:= cProcess
	Default lSimulation		:= .F.
	
	If lCRMTerr 
		
		bRunCaster := {|| aInfo := RunCasterTerritory(cProcess, cEntity, cIdTerritory, cScript, lSimulation) }
		
		//Caso a rotina seja chamada de execauto ou job n�o apresenta a interface.
		If !lIsBlind
			FWMsgRun(/*oComponent*/,bRunCaster,,STR0003)	//"Aplicado as regras de rodizio para o territ�rio..."
		Else
			Eval( bRunCaster )
		EndIf
	
	EndIf 
	
Return(aInfo)

//------------------------------------------------------------------------------
/*/{Protheus.doc} RunCasterTerritory

Executa a distribuicao da conta + rodizio para o territorio vencedor.

@sample		RunCasterTerritory(oTerritory)

@param		cProcess 	 - Codigo do processo (MATA030,TMKA260,TMKA341)
			cEntity 	 - Entidade (SA1,SUS,ACH)
			cIdTerritory - C�digo do territorio que ser� executado o processo de rodizio.
			cScript 	 - Script que ser� executado durante a avalia��o do territ�rio.
			lSimulation	 - Define que o processo de rodizio ser� apenas uma simulacao.


@return		aInfo - Array com as seguintes informacoes:
			{lRetorno, cIdTerritory, cTypeMember, cMember}

@author		Anderson Silva
@since		30/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function RunCasterTerritory(cProcess, cEntity, cIdTerritory, cScript, lSimulation)
	Local oScript		:= Nil
	Local aArea			:= GetArea()
	Local aMember		:= {}
	Local aAutoAZ4		:= {}
	Local aAutoAO4 		:= {}
	Local aError		:= {}
	Local oCaster		:= Nil
	Local cUserPaper	:= ""
	Local cTypeMember 	:= ""
	Local cMember		:= ""
	Local cQueue		:= ""
	Local cSequence		:= ""
	Local cChave		:= ""
	Local cCodUnd		:= ""
	Local cCodEqp		:= ""
	Local lRetorno		:= .T.
	Local lIsBlind		:= IsBlind()
	Local nOperation	:= MODEL_OPERATION_INSERT
	Local nX			:= 0
	Local lCaster		:= .T.
	Local lIsObjTer		:= !Empty( oTerritory )
	Local cVendResp		:= ""
	Local cSeqPaper		:= ""
	Local cUserResp		:= ""
	Local cCodUser		:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr()) 
		
	//Execucao do CRMScript.
	If lIsObjTer 
		If Empty( cScript )
			cScript := oTerritory:GetProcess()
		EndIf		
		lCaster	:= oTerritory:GetProperty( "CASTER", "L" ) 
	EndIf
	
	oScript 	:= CRMScript():New()
	oScript:SetScript( cScript )
		
	lRetorno 	:= oScript:EvalScript( 2, oTerritory )
			
	If lRetorno 
			
		If lCaster
			
			//Classe respons�vel efetuar a distribui��o da conta
			oCaster := CRMCaster( ):New( )
			
			If lIsObjTer			
				oCaster:SetTerritory( oTerritory )
				cIdTerritory	:= oTerritory:GetInfo(1)
				cTypeMember		:= oTerritory:GetInfo(4)
				cMember			:= oTerritory:GetInfo(5)
				cEntity 		:= oTerritory:GetEntity()
				
				If ( ! Empty( cTypeMember ) .And. ! Empty( cMember) )
					oCaster:SetFavorite(cTypeMember, cMember )
				EndIf 				
			Else
				oCaster:SetTerritory( cIdTerritory )
				oCaster:SetProcess( cProcess )
				oCaster:SetEntity( cEntity )
			EndIf 
       
			aMember := oCaster:GetMember()
				
			If !Empty(aMember)
				
				cUserPaper		:= oCaster:GetInfo( 1, aMember )
				cTypeMember	:= oCaster:GetInfo( 2, aMember )
				cMember		:= oCaster:GetInfo( 3, aMember ) 
				cQueue     	:= oCaster:GetInfo( 4, aMember )
				cSequence   	:= oCaster:GetInfo( 5, aMember )
				cVendResp 		:= CRMA690RtVendResp(cTypeMember,cMember,oTerritory)	//Vendedor responsavel pela conta 
				  
				 
				//Se for simulacao nao faz a grava��o do rodizio.
				If !lSimulation
					
					lRetorno := oCaster:Rate( aMember )
						 
					//Atualiza o contador de contas do membro da fila 
					If lRetorno
							
						cChave := ( (cEntity)->&(CRMXGetSX2(cEntity)[1]) )
							
						aAdd( aAutoAZ4, { "AZ4_CODROD"    , cIdTerritory		, Nil } )
						aAdd( aAutoAZ4, { "AZ4_CODFLA"    , cQueue				, Nil } )
						aAdd( aAutoAZ4, { "AZ4_SEQFLA"    , cSequence			, Nil } )
						aAdd( aAutoAZ4, { "AZ4_CODMEM"    , cMember				, Nil } )
						aAdd( aAutoAZ4, { "AZ4_TPMEM"     , cTypeMember			, Nil } )
						aAdd( aAutoAZ4, { "AZ4_CNTENT"    , cEntity				, Nil } )
						aAdd( aAutoAZ4, { "AZ4_CODENT"    , cChave				, Nil } )
						aAdd( aAutoAZ4, { "AZ4_DTRCB"     , MsDate()			, Nil } )
						aAdd( aAutoAZ4, { "AZ4_LGPROC"    , oCaster:GetLog()	, Nil } ) 
										
						lRetorno := CRMA950(aAutoAZ4,MODEL_OPERATION_INSERT)
							
						
						//Adiciona no privilegio do registro o membro que recebeu a conta.
						If lRetorno
							
							//��������������������������������������������Ŀ
							//�Monta a chave do privilegios do registro.  �
							//���������������������������������������������
							cChave := PadR(xFilial(cEntity)+cChave,TAMSX3("AO4_CHVREG")[1])
								
							DbSelectArea("AO4")
								
							//Usuarios do CRM ou Usuarios do CRM responsavel pela Unidade de Negocio ou Equipe;
							If !Empty(cUserPaper) 
								
								cUserResp	:= SubStr( cUserPaper ,1 ,6 ) //Codigo do Usuario
								cSeqPaper	:= SubStr( cUserPaper ,7 , Len( cUserPaper ) ) //Sequencia + Papel do Usuario
				
								AO4->(DbSetOrder(1))		// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR+AO4_USRPAP
									
								If AO4->(DbSeek(xFilial("AO4")+cEntity+cChave+cUserPaper))
									nOperation	:= MODEL_OPERATION_UPDATE
								EndIf
									
								aAutoAO4 := CRMA200PAut(nOperation,cEntity,cChave,cUserResp,/*aPermissoes*/,/*aNvlEstrut*/,cCodUser,;
															/*dDataVld*/,/*cCodEqp*/,/*cCodUnd*/,/*lPropri*/,cSeqPaper	)
								
							ElseIf Empty(cUserResp) .And. cTypeMember $ "1|3"	
								
								// Unidade de Negocio
								If cTypeMember == "1"
									AO4->(DbSetOrder(3)) //AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODEQP
									cCodUnd := cMember
								//Equipe	
								Else
									AO4->(DbSetOrder(4)) //AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUND 
									cCodEqp := cMember
								EndIf
			
								If AO4->(DbSeek(xFilial("AO4")+cEntity+cChave))
									nOperation	:= MODEL_OPERATION_UPDATE
								EndIf
												
								aAutoAO4 := CRMA200PAut(nOperation,cEntity,cChave,/*cCodUser*/,/*aPermissoes*/,/*aNvlEstrut*/,cCodUser,/*dDataVld*/,cCodEqp,cCodUnd)
								
							EndIf
							
							If Len(aAutoAO4) > 0
								lRetorno := CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOperation)
							EndIf
											
						EndIf
							
					Else
						//Tratamento de erro para o Rate.
						aError 	 := oCaster:GetError()
						lRetorno := .F.
					EndIf
					
				EndIf
			Else
				//Tratamento de erro para GetMember.
				aError	 := oCaster:GetError()
				lRetorno := .F.
			EndIf
								
		EndIf	
		
	Else
		aError := oScript:GetError()
	EndIf
	

	If !Empty(aError)
		For nX := 1 To Len(aError)
			AutoGrLog(aError[nX][1]	 + ' [' + AllToChar(aError[nX][2]) + ']') //"Id"
		Next nX
		If !lIsBlind
			MostraErro()
		EndIf
	EndIf
	
	//Destroi os objetos.
	If !Empty( oScript )
		oScript:Destroy()
	EndIf
	
	If !Empty( oCaster )
		oCaster:Destroy()
	EndIf	

	If lIsObjTer
		oTerritory:Destroy()
	EndIf

	RestArea(aArea)
	
Return({lRetorno, cIdTerritory, cTypeMember, cMember, cVendResp})

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA690RtVendResp
Retorna vendedor responsavel pela conta  

@param cTypeMember, character, Tipo de membro (1=Unidade de venda/2=Usuario do CRM/3=Equipe de venda)
@param cMember, character, Codigo do membro
@param oTerritory, objeto, Objeto do Territorio
@return cVendResp, character, Codigo do vendedor responsavel pela conta 
@author  Eduardo Gomes Junior 
@version P12
@since   09/09/2015  
/*/
//-------------------------------------------------------------------
Function CRMA690RtVendResp(cTypeMember,cMember,oTerritory)
										
Local aArea 	:= GetArea()
Local aAreaAZS	:= AZS->( GetArea() )
Local lCRM690Vd	:= ExistBlock("CRM690VD")
Local cUsrsResp	:= ""
Local cVendResp	:= ""

If lCRM690Vd	
	cVendResp := ExecBlock("CRM690VD",.F.,.F.,{cTypeMember,cMember,oTerritory})
Else
	If cTypeMember == "1"		//Unidade de venda 
		cUsrsResp := Posicione("ADK",1,xFilial("ADK")+cMember,"ADK_USRESP")
	ElseIf cTypeMember == "2"	//Usuario do CRM
		cUsrsResp := cMember
	ElseIf cTypeMember == "3"	//Equipe de venda
		cUsrsResp := Posicione("ACA",1,xFilial("ACA")+cMember,"ACA_USRESP")
	EndIf
	cUsrsResp := AllTrim(cUsrsResp)
EndIf
	
If Empty( cVendResp ) .And. !Empty( cUsrsResp )
	If SuperGetMv("MV_CRMUAZS",, .F.)
		AZS->( DBSetOrder( 1 ) )
		If AZS->( DBSeek( xFilial( "AZS" ) + cUsrsResp ) ) 
			cVendResp := AZS->AZS_VEND
		EndIf
	Else
		SA3->( DBSetOrder( 7 ) )
		If SA3->( DBSeek( xFilial( "SA3" ) + cUsrsResp ) ) 
			cVendResp := SA3->A3_COD
		EndIf
		SA3->( DBSetOrder( 1 ) )
	EndIf
Endif

RestArea( aAreaAZS )
RestArea( aArea )

Return(cVendResp)