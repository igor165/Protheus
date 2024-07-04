#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMCASTER.CH"

#DEFINE GROUP		1
#DEFINE LEVEL		2
#DEFINE SMARTID		3

#DEFINE QUEUE 		1
#DEFINE SEQUENCE	2
#DEFINE RULE 		3
#DEFINE SCORE		3
#DEFINE FIDELITY	4
#DEFINE REACH		5

#DEFINE TYPE		1
#DEFINE MEMBER		2
#DEFINE ACCOUNT		3
#DEFINE LIMIT		4

#DEFINE UNIT		"1"
#DEFINE CRM			"2"
#DEFINE TEAM		"3"

Static oMapKey

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMCaster
Classe respons�vel efetuar a distribui��o da conta, gerar os logs do 
processo, atualizar contadores e informa��es sobre membros que est�o recebendo contas. 

@example	
	oCaster:SetTerritory( cTerritory ) 
	oCaster:SetProcess( cProcess ) 
	oCaster:SetEntity( cEntity ) 
	
	aMember		:= oCaster:GetAllMembers() 
	
	ou
	
	aMember		:= oCaster:GetMember() 

	cUser		:= oCaster:GetInfo( 1, aMember ) 	
	cType 		:= oCaster:GetInfo( 2, aMember ) 
	cMember		:= oCaster:GetInfo( 3, aMember ) 
	cQueue		:= oCaster:GetInfo( 4, aMember )
	cSequence	:= oCaster:GetInfo( 5, aMember )
	
	oCaster:Rate( aMember )
			
@author  Valdiney V GOMES 
@version P12
@since   19/06/2015 
/*/
//-------------------------------------------------------------------
Class CRMCaster
	Data oTerritory
	Data aFavorite 		
	Data aAllQueues 	
	Data aRule			
	Data aMatch			
	Data aEvaluted		
	Data aQueue			
	Data aAllMembers	
	Data aMember		
	Data aError			
	Data cTerritory		
	Data cProcess		
	Data cEntity			
		
	Method New() CONSTRUCTOR
	Method SetTerritory( xTerritory ) 
	Method SetEntity( cEntity ) 
	Method SetProcess( cProcess )
	Method SetFavorite( cType, cMember ) 	
	Method SetError( cID, cMessage )	
	Method GetTerritory()
	Method GetProcess()
	Method GetEntity()
	Method GetFavorite()
	Method GetAllQueues()	
	Method GetRule()
	Method GetMatch()
	Method GetEvaluted() 
	Method GetQueue() 
	Method GetError()
	Method GetInfo( nInfo, aMember ) 
	Method GetLog() 
	Method GetCache()
	Method GetAllMembers()
	Method GetMember()
	Method LoadAllQueues()
	Method LoadRule( aAllQueues )
	Method LoadMatch( aRule ) 
	Method LoadAllMembers( aQueue )
	Method EvalQueue( aMatch )
	Method ChooseQueue()
	Method CheckSequence( cQueue )
	Method Rate( aMember )
	Method Destroy() 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} new
M�todo construtor da classe. 

@return Self, objeto, Inst�ncia da classe CRMCaster. 

@author  Valdiney V GOMES 
@version P12
@since   19/06/2015 
/*/
//-------------------------------------------------------------------
Method New() Class CRMCaster
	Self:oTerritory		:= Nil
	Self:aFavorite 		:= {}
	Self:aAllQueues 	:= {}
	Self:aRule			:= {}
	Self:aMatch			:= {}
	Self:aEvaluted		:= {}
	Self:aQueue			:= {}
	Self:aAllMembers	:= {}
	Self:aMember		:= {}
	Self:aError			:= {}
	Self:cTerritory		:= ""
	Self:cProcess		:= ""
	Self:cEntity		:= ""
	
	If( Empty( oMapKey ) )
		oMapKey := THashMap():New()	
	EndIf
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTerritory
Define para qual territ�rio o rod�zio ser� avaliado. 

@param xTerritory, indefinido, C�digo do territ�rio ou objeto do territ�rio.
@return cTerritory, caracter, C�digo do territ�rio.  

@author  Valdiney V GOMES 
@version P12
@since   23/09/2015 
/*/
//-------------------------------------------------------------------
Method SetTerritory( xTerritory ) Class CRMCaster
	Default xTerritory := "" 
	
	//-------------------------------------------------------------------
	// Verifica se o objeto do territ�rio foi informado.  
	//-------------------------------------------------------------------
	If ( Valtype( xTerritory ) == "O" )
		Self:oTerritory := xTerritory
		
		//-------------------------------------------------------------------
		// Recuperar os atributos do territ�rio.  
		//-------------------------------------------------------------------
		Self:SetTerritory( xTerritory:GetInfo(1) )
		Self:SetProcess( xTerritory:GetProcess() )	
		Self:SetEntity( xTerritory:GetEntity() )
		Self:SetFavorite( xTerritory:GetInfo(4), xTerritory:GetInfo(5) ) 
	Else
		Self:cTerritory := xTerritory
	EndIf
Return Self:cTerritory

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTerritory
Retorna o c�digo do territ�rio para qual o rod�zio ser� avaliado. 
 
@return cTerritory, caracter, C�digo do territ�rio.  

@author  Valdiney V GOMES 
@version P12
@since   23/09/2015
/*/
//-------------------------------------------------------------------
Method GetTerritory() Class CRMCaster
Return Self:cTerritory

//-------------------------------------------------------------------
/*/{Protheus.doc} setProcess
Define a rotina para a qual o rod�zio ser� avaliado. 

@param cProcess, caracter, Rotina para o qual o rod�zio ser� avaliado. 
@return cProcess, caracter, Rotina para o qual o rod�zio ser� avaliado. 

@author  Valdiney V GOMES 
@version P12
@since   23/09/2015
/*/
//-------------------------------------------------------------------
Method SetProcess( cProcess ) Class CRMCaster
	Default cProcess := ""

	Self:cProcess := cProcess
Return Self:cProcess

//-------------------------------------------------------------------
/*/{Protheus.doc} GetProcess
Retorna a rotina relacionada com o rod�zio. 

@return cProcess Rotina relacionada ao rod�zio. 

@author  Valdiney V GOMES 
@version P12
@since   20/06/2015  
/*/
//-------------------------------------------------------------------
Method GetProcess() Class CRMCaster
Return Self:cProcess

//-------------------------------------------------------------------
/*/{Protheus.doc} setEntity

@param cEntity, caracter, Entidade para o qual o rod�zio ser� avaliado. 
@return cEntity, caracter,  Entidade para o qual o rod�zio ser� avaliado. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method SetEntity( cEntity ) Class CRMCaster
	Default cEntity := ""
	
	Self:cEntity := cEntity
Return Self:cEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEntity
Retorna a entidade relacionada com o rod�zio. 

@return cEntity, caracter, Entidade relacionada ao rod�zio. 

@author  Valdiney V GOMES 
@version P12
@since   20/06/2015  
/*/
//-------------------------------------------------------------------
Method GetEntity() Class CRMCaster
Return Self:cEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} setFavorite
Define o membro favorito para o rod�zio.

@param cType, caracter, Tipo do membro favorito. 
@param cMember, caracter, Membro favorivo. 
@return aFavorite, array, Array no formato {TIPO, MEMBRO} contendo o membro favorito.

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method SetFavorite( cType, cMember ) Class CRMCaster
	Default cType := ""
	Default cMember := ""
	
	If ( ! Empty( cType ) .And. ! Empty( cMember) )
		Self:aFavorite := { cType, cMember } 
	EndIf 
Return Self:aFavorite

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFavorite
Retorna o membro favorito para o rod�zio.

@return aFavorite, array, Array no formato {TIPO, MEMBRO} contendo o membro favorito. 

@author  Valdiney V GOMES 
@version P12
@since   20/06/2015  
/*/
//-------------------------------------------------------------------
Method GetFavorite() Class CRMCaster
Return Self:aFavorite

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadAllQueues
Retorna todas as filas de um rod�zio no formato {{FILA, SEQUENCIA, REGRA},...}. 

@param aAllQueues, array, Rela��o de filas de um rod�zio no formato {{FILA, SEQUENCIA, REGRA},...}. 

@author  Valdiney V GOMES 
@version P12
@since   20/06/2015  
/*/
//-------------------------------------------------------------------
Method LoadAllQueues() Class CRMCaster
	Local cFilAZ6 		:= xFilial("AZ6")

	Self:aAllQueues 	:= {}

	//-------------------------------------------------------------------
	// Localiza as filas do rod�zio.  
	//-------------------------------------------------------------------
	AZ6->( DBSetOrder( 1 ) ) 

	If ( AZ6->( MSSeek( cFilAZ6 + Self:cTerritory ) ) )	
		While ( AZ6->( ! Eof() ) .And. cFilAZ6 == AZ6->AZ6_FILIAL .And. AZ6->AZ6_CODROD == Self:cTerritory )
			//-------------------------------------------------------------------
			// Verifica se a fila est� bloqueada.  
			//-------------------------------------------------------------------
			If ! ( AZ6->AZ6_MSBLQL == "1" )	
				//-------------------------------------------------------------------
				// Insere uma nova fila.  
				//-------------------------------------------------------------------
				If ( aScan( Self:aAllQueues, {|x| x[1] == AZ6->AZ6_CODFLA } ) == 0 )		
					aAdd( Self:aAllQueues, { AZ6->AZ6_CODFLA, AZ6->AZ6_SEQFLA, AZ6->AZ6_CODRGR } )
				EndIf 
			EndIf 
		
			AZ6->( DBSkip() )
		EndDo
	EndIf 
	
	//-------------------------------------------------------------------
	// Identifica erro na carga das filas.  
	//-------------------------------------------------------------------	
	If ( Empty( Self:aAllQueues ) ) 
		Self:SetError( "LOADALLQUEUES", STR0023 + Self:cTerritory ) //"Nenhuma fila encontada para o rod�zio "
	EndIf	
Return Self:aAllQueues

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAllQueues
Retorna as filas do rod�zio. 

@return aAllQueues, array, Rela��o de filas de um rod�zio no formato  {{FILA, SEQUENCIA, REGRA},...}. 

@author  Valdiney V GOMES 
@version P12
@since   25/06/2015 
/*/
//-------------------------------------------------------------------
Method GetAllQueues() Class CRMCaster
Return Self:aAllQueues

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadRule
Retorna a rela��o de agrupadores agrupadores das regras de cada fila informada

@param aRule, array, Rela��o de filas de um rod�zio no formato  {{FILA, SEQUENCIA, REGRA},...}. 
@return aRule, array, Rela��o de agrupadores das regras de cada fila {{AGRUPADOR},...}. 

@author  Valdiney V GOMES 
@version P12
@since   19/06/2015 
/*/
//-------------------------------------------------------------------
Method LoadRule( aAllQueues ) Class CRMCaster
	Local nQueue	:= 0
	Local cFilAZ8 	:= xFilial("AZ8")
	Local cFilAZ9 	:= xFilial("AZ9")
	
	Self:aRule 		:= {}

	//-------------------------------------------------------------------
	// Percorre todas as filas.  
	//-------------------------------------------------------------------
	For nQueue := 1 To Len( aAllQueues )	
		//-------------------------------------------------------------------
		// Verifica se a fila tem regra associada.
		//-------------------------------------------------------------------			
		If ! ( Empty( aAllQueues[nQueue][RULE] ) )
			//-------------------------------------------------------------------
			// Localiza a regra.
			//-------------------------------------------------------------------
			AZ8->( DBSetOrder( 1 ) )
		
			If ( AZ8->( MSSeek( cFilAZ8 + aAllQueues[nQueue][RULE] ) ) )	
				//-------------------------------------------------------------------
				// Localiza os agrupadores da regra.
				//-------------------------------------------------------------------
				AZ9->( DBSetOrder( 1 ) ) 
			
				If ( AZ9->( MSSeek( cFilAZ9 + AZ8->AZ8_CODCON ) ) )						
					While ( AZ9->( ! Eof() ) .And. cFilAZ9 == AZ9->AZ9_FILIAL .And. AZ9->AZ9_CODCON == AZ8->AZ8_CODCON )
						//-------------------------------------------------------------------
						// Insere um novo agrupador na fila de avalia��o.  
						//-------------------------------------------------------------------
						If ( aScan( Self:aRule, {|x| x == AZ9->AZ9_CODAGR } ) == 0 )		
							aAdd( Self:aRule, AZ9->AZ9_CODAGR )
						EndIf 						

						AZ9->( DBSkip() )
					EndDo							
				EndIf 	
			EndIf 
		EndIf 
	Next nQueue
Return Self:aRule

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQueue
Retorna as filas do rod�zio. 

@return aRule, array,  Rela��o de agrupadores do rod�zio no formato {{AGRUPADOR},...}.  

@author  Valdiney V GOMES 
@version P12
@since   25/06/2015 
/*/
//-------------------------------------------------------------------
Method GetRule() Class CRMCaster
Return Self:aRule

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadMatch
Executa as regras e retorna o agrupador e o n�vel que foi encontrado
na avalia��o de cada agrupador.  

@param aRule, array, Rela��o de agrupadores das regras de cada fila {{AGRUPADOR},...}. 
@return aMatch, array, Lista no formato {{AGRUPADOR, N�VEL}, ...}. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method LoadMatch( aRule ) Class CRMCaster
	Local aPool 	:= {}
	Local aGroup	:= {}
	Local aKey		:= {}
	Local cPool		:= ""
	Local nRule		:= 0

	Default aRule	:= {}

	Self:aMatch 	:= {}

	//-------------------------------------------------------------------
	// Percorre os agrupadores das regras.  
	//-------------------------------------------------------------------
	For nRule := 1 To Len( aRule )	
		//-------------------------------------------------------------------
		// Recupera o agrupador.  
		//-------------------------------------------------------------------
		cPool	:= aRule[nRule]

		//-------------------------------------------------------------------
		// Recupera o agrupador.  
		//-------------------------------------------------------------------	
		aKey	:= CRMA580Key( cPool, Self:cEntity, Self:cProcess )
		aGroup 	:= CRMA580Group( cPool, aKey, .F., .F., oMapKey ) 
		
		//-------------------------------------------------------------------
		// Lista todos os agrupadores e n�veis encontrados.  
		//-------------------------------------------------------------------
		If ( aScan( Self:aMatch, {|x| x[1] == aGroup[GROUP] } ) == 0 )		
			If ( ! Empty( aGroup ) .And. ! Empty( aGroup[GROUP] ) ) 
				aAdd( Self:aMatch, aGroup )
			Else
				//-------------------------------------------------------------------
				// Identifica erros no processo.  	
				//-------------------------------------------------------------------						
				If ( Empty( aGroup ) )
					Self:SetError( "LOADMATCH", STR0005 + aRule[nRule] + STR0020 ) //"Agrupador "###" n�o encontrado."			
				Else		
					Self:SetError( "LOADMATCH", STR0021 + cBIStr( aKey, .T. ) + STR0022 + aRule[nRule] ) //"Nenhum n�vel encontrado para a chave "###" no agrupador "			
				EndIf 
			EndIf 
		EndIf		
	Next nRule	
Return Self:aMatch

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMatch
Retorna os agrupadores e o n�vel que foi encontrado na avalia��o de cada agrupador.

@return aMatch, array, Lista no formato {{AGRUPADOR, N�VEL}, ...}. 

@author  Valdiney V GOMES 
@version P12
@since   19/06/2015 
/*/
//-------------------------------------------------------------------
Method GetMatch() Class CRMCaster
Return Self:aMatch

//-------------------------------------------------------------------
/*/{Protheus.doc} EvalQueue
Retorna as filas avaliadas para um processo. 

@param aMatch, array, Lista no formato {{AGRUPADOR, N�VEL}, ...}. 	
@return aEvaluted, array, Lista contendo as filas do rod�zio que pontuaram no formato { { FILA, SEQUENCIA, PONTOS, FIDELIDADE, { { AGRUPADOR, N�VEL, PONTOS, FIDELIDADE } } }, ...}. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method EvalQueue( aMatch ) Class CRMCaster
	Local nMatch		:= 0
	Local nQueue		:= 0
	Local nFidelity		:= 0
	Local nScore		:= 1
	Local cSequence		:= ""
	Local lFound		:= .F.
	Local cFilAZ6		:= xFilial("AZ6") 
	Local cFilAZ8		:= xFilial("AZ8") 
	Local cFilAZ9		:= xFilial("AZ9")  

	Default aMatch	:= {}
	
	Self:aEvaluted 	:= {}

	//-------------------------------------------------------------------
	// Localiza as filas do rod�zio.  
	//-------------------------------------------------------------------
	AZ6->( DBSetOrder( 1 ) ) 

	If ( AZ6->( MSSeek( cFilAZ6 + Self:cTerritory ) ) )	
		While ( AZ6->( ! Eof() ) .And. cFilAZ6 == AZ6->AZ6_FILIAL .And. AZ6->AZ6_CODROD == Self:cTerritory )
			//-------------------------------------------------------------------
			// Verifica se a fila est� bloqueada.  
			//-------------------------------------------------------------------
			If ! ( AZ6->AZ6_MSBLQL == "1" )	
				//-------------------------------------------------------------------
				// Verifica se existe regra associada a fila.  
				//-------------------------------------------------------------------
				If ! ( Empty( AZ6->AZ6_CODRGR ) )
					//-------------------------------------------------------------------
					// Localiza a regra.
					//-------------------------------------------------------------------
					AZ8->( DBSetOrder( 1 ) ) 
				
					If ( AZ8->( MSSeek( cFilAZ8 + AZ6->AZ6_CODRGR ) ) )	
						//-------------------------------------------------------------------
						// Percorre todos os n�veis dos agrupadores avaliados.
						//-------------------------------------------------------------------
						For nMatch := 1 To Len( aMatch )						
							//-------------------------------------------------------------------
							// Localiza os agrupadores da regra.
							//-------------------------------------------------------------------
							AZ9->( DBSetOrder( 1 ) ) 
	
							If ( AZ9->( MSSeek( cFilAZ9 + AZ8->AZ8_CODCON + aMatch[nMatch][GROUP] ) ) )	
								While ( AZ9->( ! Eof() ) .And. cFilAZ9 == AZ9->AZ9_FILIAL .And. AZ9->AZ9_CODCON == AZ8->AZ8_CODCON .And. AZ9->AZ9_CODAGR == aMatch[nMatch][GROUP] )
									//-------------------------------------------------------------------
									// Verifica se o n�vel do agrupador � igual ao n�vel avaliado.   
									//-------------------------------------------------------------------
									nFidelity	:= 0
									lFound 		:= ( AZ9->AZ9_CODNIV == aMatch[nMatch][LEVEL] )
									
									If ! ( lFound )
										//-------------------------------------------------------------------
										// Verifica se o n�vel avaliado � um filho do n�vel do agrupador.
										//-------------------------------------------------------------------
										lFound := CRMA580IsChild( AZ9->AZ9_IDINT, aMatch[nMatch][SMARTID], @nFidelity )
									EndIf 
					
									If ( lFound )
										//-------------------------------------------------------------------
										// Localiza a fila.  
										//-------------------------------------------------------------------
										nCaster := aScan( Self:aEvaluted, {|x| x[QUEUE] == AZ6->AZ6_CODFLA } )	
										
										If ( Empty( nCaster ) )	
											//-------------------------------------------------------------------
											// Recupera a sequ�ncia.  
											//-------------------------------------------------------------------				
											cSequence := Self:CheckSequence( AZ6->AZ6_CODFLA )
						
											//-------------------------------------------------------------------
											// Insere uma fila.  
											//-------------------------------------------------------------------
											aAdd( Self:aEvaluted, { AZ6->AZ6_CODFLA, cSequence, nScore, nFidelity, { { AZ9->AZ9_CODAGR, AZ9->AZ9_CODNIV, nScore, nFidelity } } } )
										Else
											//-------------------------------------------------------------------
											// Atualiza a fila.  
											//-------------------------------------------------------------------
											Self:aEvaluted[nCaster][SCORE] 		+= nScore
											Self:aEvaluted[nCaster][FIDELITY]	+= nFidelity
											
											aAdd( Self:aEvaluted[nCaster][REACH], { AZ9->AZ9_CODAGR, AZ9->AZ9_CODNIV, nScore, nFidelity } ) 
										EndIf 
									EndIf 							
					
									AZ9->( DBSkip() )
								EndDo							
							EndIf 
						Next nMatch	
					EndIf 			
				Else
					//-------------------------------------------------------------------
					// Recupera a sequ�ncia.  
					//-------------------------------------------------------------------				
					cSequence := Self:CheckSequence( AZ6->AZ6_CODFLA )
				
					//-------------------------------------------------------------------
					// Insere uma fila padr�o.  
					//-------------------------------------------------------------------
					aAdd( Self:aEvaluted, { AZ6->AZ6_CODFLA, cSequence, nScore, nFidelity, { { "", "", nScore, nFidelity } } } )				
				EndIf 
			EndIf 
		
			AZ6->( DBSkip() )
		EndDo
	EndIf 	
	
	//-------------------------------------------------------------------
	// Ordena as filas por pontua��o.  
	//-------------------------------------------------------------------
	If ! ( Empty( Self:aEvaluted ) )  
		aSort( Self:aEvaluted,,,{ |x,y| x[SCORE] > y[SCORE] .And. x[FIDELITY] > y[FIDELITY] } ) 
	EndIf	
	
Return Self:aEvaluted

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEvaluted
Retorna as filas do rod�zio que pontuaram no formato { { FILA, SEQUENCIA, PONTOS, FIDELIDADE, { { AGRUPADOR, N�VEL, PONTOS, FIDELIDADE } } }, ...}.  

@return aTerritory, array, Lista contendo as filas do rod�zio que pontuaram no formato { { FILA, SEQUENCIA, PONTOS, FIDELIDADE, { { AGRUPADOR, N�VEL, PONTOS, FIDELIDADE } } }, ...}.
@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method GetEvaluted() Class CRMCaster
Return Self:aEvaluted

//-------------------------------------------------------------------
/*/{Protheus.doc} ChooseQueue
Retorna a melhor fila para o rod�zio no formato { { FILA, SEQUENCIA, PONTOS, FIDELIDADE, { { AGRUPADOR, N�VEL, PONTOS, FIDELIDADE } } }, ...}. 

@param lForce, l�gico, Indica se deve for�ar a sele��o de um �nico membro em caso de empate.  
@return aQueue, array, Melhor fila para o rod�zio no formato { { FILA, SEQUENCIA, PONTOS, FIDELIDADE, { { AGRUPADOR, N�VEL, PONTOS, FIDELIDADE } } }, ...}. 

@author  Valdiney V GOMES 
@version P12
@since   23/06/2015 
/*/
//-------------------------------------------------------------------
Method ChooseQueue( lForce ) Class CRMCaster
	Local aArea			:= GetArea()
	Local aAllQueues	:= {}	
	Local aRule			:= {}
	Local aMatch		:= {}
	Local aQueue		:= {}
	Local nQueue		:= 0
	Local nGarbage		:= 0
	
	Default lForce		:= .T. 
	
	Self:aQueue 		:= {}

	//-------------------------------------------------------------------
	// Recupera a fila.   
	//-------------------------------------------------------------------				
	aAllQueues 	:= Self:LoadAllQueues()			
			
	//-------------------------------------------------------------------
	// Recupera as regras das filas
	//-------------------------------------------------------------------	
	aRule 		:= Self:LoadRule( aAllQueues )

	//-------------------------------------------------------------------
	// Recupera o resultado da avalia��o dos agrupadores.  
	//-------------------------------------------------------------------					
	aMatch		:= Self:LoadMatch( aRule ) 
	
	//-------------------------------------------------------------------
	// Recupera as filas que atendem as regras.  
	//-------------------------------------------------------------------
	aQueue 		:= Self:EvalQueue( aMatch ) 

	//-------------------------------------------------------------------
	// Filtra as filas com maior pontua��o e fidelidade.  
	//-------------------------------------------------------------------	
	For nQueue := 1 To Len( aQueue )
		If ! ( Empty( Self:aQueue ) )
			If ( aQueue[nQueue][SCORE] >= Self:aQueue[ Len( Self:aQueue ) ][SCORE] )	
				If ( aQueue[nQueue][FIDELITY] >= Self:aQueue[ Len( Self:aQueue ) ][FIDELITY] )	
					nGarbage := aScan( 	Self:aQueue,;
										{|x| x[SCORE] < aQueue[nQueue][SCORE] .Or. x[FIDELITY] < aQueue[nQueue][FIDELITY] } )	 
										
					If ! ( nGarbage == 0 )     
				 		aDel( Self:aQueue, nGarbage ) 
				  		aSize( Self:aQueue, Len( Self:aQueue ) - 1 )
				  	EndIf 

					aAdd( Self:aQueue, aQueue[nQueue] ) 
				EndIf 
			EndIf
		Else
			aAdd( Self:aQueue, aQueue[nQueue] ) 
		EndIf 	
	Next nQueue	

	//-------------------------------------------------------------------
	// Verifica se ocorreu empate entre filas.  
	//-------------------------------------------------------------------		
	If ! ( Empty( Self:aQueue ) )  .And. ! ( Len( Self:aQueue ) == 1 )
		//-------------------------------------------------------------------
		// For�a uma fila aleat�ria.  
		//-------------------------------------------------------------------		
		If ( lForce )
			Self:aQueue 	:= { Self:aQueue[ Randomize( 1, Len( Self:aQueue ) ) ] }
		EndIf 
	EndIf
	
	RestArea( aArea )
Return Self:aQueue

//-------------------------------------------------------------------
/*/{Protheus.doc} ChooseQueue
Retoa a melhor fila para o rod�zio no formato { { FILA, SEQUENCIA, PONTOS, FIDELIDADE, { { AGRUPADOR, N�VEL, PONTOS, FIDELIDADE } } }, ...}. 
r
@return aQueue, array, Melhor fila para o rod�zio no formato { { FILA, SEQUENCIA, PONTOS, FIDELIDADE, { { AGRUPADOR, N�VEL, PONTOS, FIDELIDADE } } }, ...}. 

@author  Valdiney V GOMES 
@version P12
@since   23/06/2015 
/*/
//-------------------------------------------------------------------
Method GetQueue() Class CRMCaster
Return Self:aQueue

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadAllMembers
Retorna todos os membros dispon�veis para receber contas. 

@param aQueue, aQueue, Fila para o rod�zio no formato { { FILA, SEQUENCIA, PONTOS, FIDELIDADE, { { AGRUPADOR, N�VEL, PONTOS, FIDELIDADE } } }, ...}.
@param lForce, l�gico, Indica se deve for�ar a sele��o de um �nico membro em caso de empate.  
@return aAllMembers, array, Lista de membros no formato {{TIPO, CODIGO, CONTAS, CAPACIDADE}}. 

@author  Valdiney V GOMES 
@version P12
@since   19/06/2015 
/*/
//-------------------------------------------------------------------
Method GetAllMembers( aQueue, lForce ) Class CRMCaster
	Local nQueue		:= 0
	Local lAvailable	:= .F. 
	Local cFilAZ7		:= xFilial("AZ7")
	Local cFilA09		:= xFilial("A09")

	Default aQueue 		:= {}
	Default lForce		:= .T. 

	Self:aAllMembers 	:= {}
	
	//-------------------------------------------------------------------
	// Retorna a melhor fila para o rod�zio.
	//-------------------------------------------------------------------
	If ( Empty( aQueue ) )
		aQueue 	:= Self:ChooseQueue( lForce )	
	EndIf
	
	//-------------------------------------------------------------------
	// Percorre todos as filas avaliadas.
	//-------------------------------------------------------------------
	For nQueue := 1 To Len( aQueue )
		//-------------------------------------------------------------------
		// Localiza os membros da fila.   
		//-------------------------------------------------------------------
		AZ7->( DBSetOrder( 1 ) ) 
	
		If ( AZ7->( MSSeek( cFilAZ7 + Self:cTerritory + aQueue[nQueue][QUEUE] ) ) )	
			While ( AZ7->( ! Eof() ) .And. cFilAZ7 == AZ7->AZ7_FILIAL .And. AZ7->AZ7_CODROD == Self:cTerritory .And. AZ7->AZ7_CODFLA == aQueue[nQueue][QUEUE] )
				//-------------------------------------------------------------------
				// Localiza os membros do territ�rio.   
				//-------------------------------------------------------------------
				A09->( DBSetOrder( 1 ) ) 		
				
				If ( A09->( MSSeek( cFilA09 + AZ7->AZ7_CODROD + AZ7->AZ7_TPMEM + AZ7->AZ7_CODMEM ) ) )	
					//-------------------------------------------------------------------
					// Verifica se o membro do territ�rio est� bloqueado.  
					//-------------------------------------------------------------------
					lAvailable :=  ! ( A09->A09_MSBLQL == "1" ) 
					
					//-------------------------------------------------------------------
					// Verifica se o membro do territ�rio est� expirado.  
					//-------------------------------------------------------------------
					If ( lAvailable )
						lAvailable := ( A09->A09_DTINIC <= dDatabase ) .And. ( A09->A09_DTFIM >= dDatabase .Or. Empty( A09->A09_DTFIM ) )
					EndIf
					
					//-------------------------------------------------------------------
					// Lista todos os membros da fila.  
					//-------------------------------------------------------------------
					If ( lAvailable )
						If ( aScan( Self:aAllMembers, {|x| x[1] == AZ7->AZ7_TPMEM .And. x[2] == AZ7->AZ7_CODMEM } ) == 0 )	
							aAdd( Self:aAllMembers, { AZ7->AZ7_TPMEM, AZ7->AZ7_CODMEM, AZ7->AZ7_CTCNT, AZ7->AZ7_PESOM } )
						EndIf 
					EndIf	
				EndIf 
				
				AZ7->( DBSkip() )
			EndDo 
		EndIf 	
	Next nMatch	
	
	//-------------------------------------------------------------------
	// Identifica erros no processo.  
	//-------------------------------------------------------------------		
	If ( Empty( Self:aAllMembers ) ) 
		Self:SetError( "LOADALLMEMBERS", STR0024 + STR0025 + Self:cTerritory  ) //"Nenhum membro encontado na fila "###" do rod�zio "
	EndIf	
Return Self:aAllMembers

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMember
Retorna o membro para o qual a conta deve ser alocada. 

@return aMember, array, Membro que ser� alocado no formato {RESPONSAVEL, TIPO, MEMBRO, FILA, SEQUENCIA}. 

@author  Valdiney V GOMES 
@version P12
@since   23/06/2015 
/*/
//-------------------------------------------------------------------
Method GetMember() Class CRMCaster
	Local aArea			:= GetArea()
	Local aAllMembers	:= {}	
	Local aQueue		:= {}	
	Local nMember		:= 0	
	Local cMember		:= ""	

	Self:aMember 		:= {}

	//-------------------------------------------------------------------
	// Retorna a melhor fila para o rod�zio.
	//-------------------------------------------------------------------
	aQueue 		:= Self:ChooseQueue()	

	//-------------------------------------------------------------------
	// Recupera os membros da fila.   
	//-------------------------------------------------------------------
	aAllMembers := Self:GetAllMembers( aQueue )

	//-------------------------------------------------------------------
	// Verifica se algum candidato foi encontado.   
	//-------------------------------------------------------------------
	If ! ( Empty( aAllMembers ) )
		//-------------------------------------------------------------------
		// Localiza o rod�zio.   
		//-------------------------------------------------------------------	
		AZ3->( DBSetOrder( 1 ) ) 
		
		If ( AZ3->( MSSeek( xFilial("AZ3") + Self:cTerritory ) ) )	
			//-------------------------------------------------------------------
			// Verifica se o rod�zio est� bloqueado.  
			//-------------------------------------------------------------------
			If ! ( AZ3->AZ3_MSBLQL == "1" )	
				//-------------------------------------------------------------------
				// Identifica se o membro favorito � um candidato.  
				//-------------------------------------------------------------------	
				If ( ! Empty( Self:aFavorite ) ) 
					nMember := aScan( aAllMembers, {|x| x[TYPE] == Self:aFavorite[1] .And. x[MEMBER] == Self:aFavorite[2] } ) 
				Else
					//-------------------------------------------------------------------
					// Localiza a fila do rod�zio.  
					//-------------------------------------------------------------------
					AZ6->( DBSetOrder( 1 ) ) 
				
					If ( AZ6->( MSSeek( xFilial("AZ6") + AZ3->AZ3_CODROD + aQueue[Len(aQueue)][QUEUE] ) ) )	
						//-------------------------------------------------------------------
						// Identifica o �ltimo membro favorecido.  
						//-------------------------------------------------------------------		
						nMember	:= aScan( aAllMembers, {|x| x[TYPE] + x[MEMBER] == AZ6->AZ6_ULTMEM } ) 
						
						//-------------------------------------------------------------------
						// Define o candidato que ser� avaliado.  
						//-------------------------------------------------------------------	
						nMember := nMember + 1
					EndIf	
				EndIf 

				//-------------------------------------------------------------------
				// Identifica o membro a ser favorecido.  
				//-------------------------------------------------------------------
				While ( .T. ) 
					If ( nMember > Len( aAllMembers ) .Or. Empty( nMember ) ) 
						nMember := 1
					Else
						//-------------------------------------------------------------------
						// Verifica se o membro pode receber novas contas.  
						//-------------------------------------------------------------------
						If ( aAllMembers[nMember][LIMIT] > aAllMembers[nMember][ACCOUNT] )
							Exit 
						Else
							nMember ++	
						EndIf 						
					EndIf
				Enddo

				If ( aAllMembers[nMember][TYPE] == UNIT )
					//-------------------------------------------------------------------
					// Localiza a unidade de neg�cio.  
					//-------------------------------------------------------------------
					ADK->( DBSetOrder( 1 ) ) 
				
					//-------------------------------------------------------------------
					// Recupera o usu�rio respons�vel.  
					//-------------------------------------------------------------------
					If ( ADK->( MSSeek( xFilial("ADK") +  aAllMembers[nMember][MEMBER] ) ) )	
						cMember := ADK->ADK_USRESP
					EndIf  							
				ElseIf ( aAllMembers[nMember][TYPE] == TEAM )
					//-------------------------------------------------------------------
					// Localiza a equipe de vendas.  
					//-------------------------------------------------------------------
					ACA->( DBSetOrder( 1 ) ) 
				
					//-------------------------------------------------------------------
					// Recupera o usu�rio respons�vel.  
					//-------------------------------------------------------------------
					If ( ACA->( MSSeek( xFilial("ACA") + aAllMembers[nMember][MEMBER] ) ) )	
						cMember := ACA->ACA_USRESP
					EndIf 
				ElseIf ( aAllMembers[nMember][TYPE] == CRM )
					//-------------------------------------------------------------------
					// Retorna o usu�rio do CRM.
					//-------------------------------------------------------------------
					cMember := aAllMembers[nMember][MEMBER]
				EndIf  		

				aAdd( Self:aMember, { cMember, aAllMembers[nMember][TYPE], aAllMembers[nMember][MEMBER], aQueue[Len(aQueue)][QUEUE], aQueue[Len(aQueue)][SEQUENCE] } )
			EndIf 
		EndIf 
	EndIf 
	
	//-------------------------------------------------------------------
	// Identifica se algum membro foi selecionado.  
	//-------------------------------------------------------------------
	If ( Empty(Self:aMember) )
		Self:SetError( "GETMEMBER", STR0026 ) //"Nenhum membro selecionado para o rod�zio"
	EndIf 
	
	RestArea( aArea	)
Return Self:aMember

//-------------------------------------------------------------------
/*/{Protheus.doc} Rate
Atualiza o contador de contas do membro da fila 

@param aMember, array, Membro da fila no formato {RESPONSAVEL, TIPO, MEMBRO, FILA, SEQUENCIA}.. 
@return lRate, l�gico, Indica se o membro foi taxado. 

@author  Valdiney V GOMES 
@version P12
@since   19/06/2015 
/*/
//-------------------------------------------------------------------
Method Rate( aMember ) Class CRMCaster
	Local cType 	:= "" 
	Local cMember 	:= ""
	Local cQueue	:= ""
	Local lRate 	:= .F. 
	
	Default aMember	:= {}

	If !( Empty( aMember ) )
		//-------------------------------------------------------------------
		// Recupera o membro avaliado.  
		//-------------------------------------------------------------------
		cType 		:= Self:GetInfo( 2, aMember )
		cMember 	:= Self:GetInfo( 3, aMember )
		cQueue		:= Self:GetInfo( 4, aMember )
	
		//-------------------------------------------------------------------
		// Localiza os membros da fila.  
		//-------------------------------------------------------------------
		AZ7->( DBSetOrder( 1 ) ) 
	
		If ( AZ7->( MSSeek( xFilial("AZ7") + Self:cTerritory + cQueue + cType + cMember ) ) )	
			lRate := .T. 
			
			BEGIN TRANSACTION
				//-------------------------------------------------------------------
				// Atualiza o contador de contas do membro.  
				//-------------------------------------------------------------------				
				AZ7->( RecLock( "AZ7", .F. ) )
				AZ7->AZ7_CTCNT := AZ7->AZ7_CTCNT + 1
				AZ7->( MsUnlock() )	
				
				//-------------------------------------------------------------------
				// Localiza a fila do rod�zio.  
				//-------------------------------------------------------------------
				AZ6->( DBSetOrder( 1 ) ) 
			
				If ( AZ6->( MSSeek( xFilial("AZ6") + Self:cTerritory + cQueue ) ) )	
					//-------------------------------------------------------------------
					// Inicia uma nova sequ�ncia para a fila.  
					//-------------------------------------------------------------------	
					AZ6->( RecLock( "AZ6", .F. ) )
					AZ6->AZ6_ULTMEM	:= ( cType + cMember )
					AZ6->( MsUnlock() )
				EndIf 			
			END TRANSACTION 
		EndIf 
	EndIf 
Return lRate 

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckSequence
Verifica fila do rod�zio. Quando uma fila est� cheia inicia uma nova 
sequ�ncia e reinicia os contadores da fila atual. 

@param cQueue, caracter, fila do rod�zio. 
@return cSequence, caracter, Sequ�ncia da fila. 

@author  Valdiney V GOMES 
@version P12
@since   30/06/2015 
/*/
//-------------------------------------------------------------------
Method CheckSequence( cQueue ) Class CRMCaster
	Local cSequence		:= ""
	Local lFull			:= .T. 
	Local lAvailable	:= .F. 
	Local cFilAZ7		:= xFilial("AZ7")
	Local cFilA09		:= xFilial("A09")

	
	Default cQueue 		:= ""

	//-------------------------------------------------------------------
	// Localiza a fila do rod�zio.  
	//-------------------------------------------------------------------
	AZ6->( DBSetOrder( 1 ) ) 
		
	If ( AZ6->( MSSeek( xFilial("AZ6") + Self:cTerritory + cQueue ) ) )
		//-------------------------------------------------------------------
		// Recupera a sequ�ncia da fila.   
		//-------------------------------------------------------------------
		cSequence := AZ6->AZ6_SEQFLA
		
		//-------------------------------------------------------------------
		// Localiza os membros da fila.   
		//-------------------------------------------------------------------
		AZ7->( DBSetOrder( 1 ) ) 
	
		If ( AZ7->( MSSeek( cFilAZ7 + AZ6->AZ6_CODROD + AZ6->AZ6_CODFLA ) ) )	
			While ( AZ7->( ! Eof() ) .And. cFilAZ7 == AZ7->AZ7_FILIAL .And. AZ7->AZ7_CODROD == AZ6->AZ6_CODROD .And. AZ7->AZ7_CODFLA == AZ6->AZ6_CODFLA )
				//-------------------------------------------------------------------
				// Localiza os membros do territ�rio.   
				//-------------------------------------------------------------------
				A09->( DBSetOrder( 1 ) ) 		
				
				If ( A09->( MSSeek( cFilA09 + AZ7->AZ7_CODROD + AZ7->AZ7_TPMEM + AZ7->AZ7_CODMEM ) ) )	
					//-------------------------------------------------------------------
					// Verifica se o membro do territ�rio est� bloqueado.  
					//-------------------------------------------------------------------
					lAvailable :=  ! ( A09->A09_MSBLQL == "1" ) 
					
					//-------------------------------------------------------------------
					// Verifica se o membro do territ�rio est� expirado.  
					//-------------------------------------------------------------------
					If ( lAvailable )
						lAvailable := ( A09->A09_DTINIC <= dDatabase ) .And. ( A09->A09_DTFIM >= dDatabase .Or. Empty( A09->A09_DTFIM ) )
					EndIf

					//-------------------------------------------------------------------
					// Verifica se a fila pode receber novas contas.    
					//-------------------------------------------------------------------
					If ( lAvailable )
						If ( AZ7->AZ7_CTCNT < AZ7->AZ7_PESOM  ) 
							lFull := .F. 
							Exit
						EndIf 
					EndIf 
				EndIf 			
	
				AZ7->( DBSkip() )
			EndDo 
		EndIf 

		If ( lFull  )
			//-------------------------------------------------------------------
			// Atualiza a sequ�ncia da fila.  
			//-------------------------------------------------------------------	
			cSequence := Soma1( cSequence )
			
			BEGIN TRANSACTION
				//-------------------------------------------------------------------
				// Inicia a nova sequ�ncia para a fila.  
				//-------------------------------------------------------------------	
				AZ6->( RecLock( "AZ6", .F. ) )
				AZ6->AZ6_SEQFLA	:= cSequence
				AZ6->( MsUnlock() )
				
				//-------------------------------------------------------------------
				// Localiza os membros da fila.  
				//-------------------------------------------------------------------
				AZ7->( DBSetOrder( 1 ) ) 
			
				If ( AZ7->( MSSeek( cFilAZ7 + AZ6->AZ6_CODROD + AZ6->AZ6_CODFLA ) ) )	
					While ( AZ7->( ! Eof() ) .And. cFilAZ7 == AZ7->AZ7_FILIAL .And. AZ7->AZ7_CODROD == AZ6->AZ6_CODROD .And. AZ7->AZ7_CODFLA == AZ6->AZ6_CODFLA )
						//-------------------------------------------------------------------
						// Reinicia o contador dos membros da fila.  
						//-------------------------------------------------------------------		
						AZ7->( RecLock( "AZ7", .F. ) )
						AZ7->AZ7_CTCNT	:= 0
						AZ7->( MsUnlock() )	
			
						AZ7->( DBSkip() )
					EndDo 
				EndIf 
			END TRANSACTION 
		EndIf 
	EndIf 
Return cSequence 

//-------------------------------------------------------------------
/*/{Protheus.doc} SetError
Inclui uma mensagem de erro no processo de avalia��o do rod�zio. 

@param cID, caracter, Identificador do processo.
@param cMessage, caracter,  Mensagem de erro. 
@return aError, array, Lista de erros no formato {{ID, MENSAGEM}, ...}

@author  Valdiney V GOMES 
@version P12
@since   02/07/2015  
/*/
//-------------------------------------------------------------------
Method SetError( cID, cMessage ) Class CRMCaster	
	Default cID			:= ""
	Default cMessage	:= ""
	
	aAdd( Self:aError, { cID, cMessage } )		
Return Self:aError

//-------------------------------------------------------------------
/*/{Protheus.doc} GetError
Retorna as mensagem de erro no processo de avalia��o do rod�zio.

@return aError, array, Lista de erros no formato {{ID, MENSAGEM}, ...}

@author  Valdiney V GOMES 
@version P12
@since   02/07/2015   
/*/
//-------------------------------------------------------------------
Method GetError() Class CRMCaster		
Return Self:aError

//-------------------------------------------------------------------
/*/{Protheus.doc} GetInfo
Retorna uma informa��o solicitada do membro avaliado.  

@param nInfo, num�rico, Informa��o que ser� recuperada.
@param aMember, num�rico, Membro.
@return xInfo, indefinido, Informa��o recuperada. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method GetInfo( nInfo, aMember ) Class CRMCaster
	Local xInfo 		:= Nil 
	
	Default nInfo 		:= 1
	Default aMember		:= Self:aMember

	If ! ( Empty( aMember ) )
		If ( nInfo <= Len( aMember[1] )  )
			xInfo := aMember[1][nInfo]
		EndIf 	
	EndIf 
Return xInfo 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLog
Retorna o log completo da avalia��o do rod�zio. 

@return cLog, caracter, log do processo de avalia��o do rod�zio. 

@author  Valdiney V GOMES 
@version P12
@since   23/06/2015  
/*/
//-------------------------------------------------------------------
Method GetLog() Class CRMCaster	
	Local aAllQueues 	:= {}
	Local aRule			:= {}
	Local aMatch		:= {}
	Local aEvaluted		:= {}
	Local aQueue		:= {}
	Local aAllMembers	:= {}
	Local aMember		:= {} 
	Local cLine			:= Replicate( "-", 80 )
	Local cLog			:= ""	
	Local cType			:= ""
	Local cMember		:= ""
	Local nQueue		:= 0
	Local nRule			:= 0
	Local nMatch		:= 0
	Local nMember		:= 0
	Local nReach		:= 0
	Local cFilAZ6		:= xFilial( "AZ6" )
	Local cFilAOL 		:= xFilial( "AOL" )

	//-------------------------------------------------------------------
	// Recupera o log do territ�rio.  
	//-------------------------------------------------------------------	
	If ! Empty( Self:oTerritory )
		cLog := Self:oTerritory:GetLog()
	EndIf 

	//-------------------------------------------------------------------
	// Monta o cabe�alho para o rod�zio.  
	//-------------------------------------------------------------------
	cLog += cLine + CRLF
	cLog += STR0001 + CRLF //Rod�zio
	cLog += cLine + CRLF
	cLog +=	Padr( STR0028, 10 ) //Processo
	cLog += "|" 
	cLog +=	Padr( STR0029, 10 ) //Entidade
	cLog += "|" 
	cLog +=	Padr( STR0030, 30 ) //Hora	
	cLog += CRLF
	cLog += cLine + CRLF
	
	//-------------------------------------------------------------------
	// Loga as informa��es do rod�zio.  
	//-------------------------------------------------------------------	
	cLog +=	Padr( Self:GetProcess(), 10 )
	cLog += "|" 
	cLog +=	Padr( Self:GetEntity(), 10 )
	cLog += "|" 
	cLog +=	Padr( DToC( Date() ) + " " + Time() , 30 )
	cLog += CRLF
	
	//-------------------------------------------------------------------
	// Recupera as filas do rod�zio.  
	//-------------------------------------------------------------------
	aAllQueues := Self:GetAllQueues()
	
	If ! ( Empty( aAllQueues ) )
		//-------------------------------------------------------------------
		// Monta o cabe�alho para a fila. 
		//-------------------------------------------------------------------
		cLog += cLine + CRLF
		cLog += STR0003 + CRLF //"Filas"
		cLog += cLine + CRLF
		cLog += Padr( STR0003, 10 ) //"Fila"	
		cLog += "|" 
		cLog += Padr( STR0027, 30 ) //STR0027
		cLog += CRLF
		cLog += cLine + CRLF

		//-------------------------------------------------------------------
		// Loga as filas do rod�zio   
		//-------------------------------------------------------------------		
		For nQueue := 1 To Len( aAllQueues )
			cLog += Padr( aAllQueues[nQueue][1], 10 )  
			cLog += "|" 
			cLog += Padr( Posicione( "AZ6", 1, cFilAZ6 + Self:cTerritory + aAllQueues[nQueue][1], "AZ6_DESCRI" ) , 30 ) 
			cLog += CRLF
		Next nQueue
		
		//-------------------------------------------------------------------
		// Recupera os agrupadores das filas. 
		//-------------------------------------------------------------------		
		aRule := Self:GetRule() 	
		
		If ! Empty( aRule )
			//-------------------------------------------------------------------
			// Monta o cabe�alho para os n�veis encontrados.  
			//-------------------------------------------------------------------
			cLog += cLine + CRLF
			cLog += STR0031 + CRLF //"Regra"
			cLog += cLine + CRLF
			cLog += Padr( STR0005, 10 ) //"Agrupador"
			cLog += "|" 
			cLog += Padr( STR0027, 30 ) //STR0027
			cLog += CRLF
			cLog += cLine + CRLF	
		
			//-------------------------------------------------------------------
			// Loga cada n�vel que foi encontrado.  
			//-------------------------------------------------------------------	
			For nRule := 1 To Len ( aRule )
				cLog += Padr( aRule[nRule], 10 )
				cLog += "|" 
				
				If ! Empty( aRule[nRule] )
					cLog += Padr( AllTrim( Posicione( "AOL", 1, cFilAOL + aRule[nRule], "AOL_RESUMO" ) ), 30 )
				Else
					cLog += Padr( STR0007, 30 ) //"Indefinido"	
				EndIf 

				cLog += CRLF
			Next nMatch 
			
			//-------------------------------------------------------------------
			// Recupera os agrupadores que foram foram atendidos.  
			//-------------------------------------------------------------------			
			aMatch 	:= Self:GetMatch()	
	
			If ! ( Empty( aMatch ) )	
				//-------------------------------------------------------------------
				// Monta o cabe�alho para os n�veis encontrados.  
				//-------------------------------------------------------------------	
				cLog += cLine + CRLF
				cLog += STR0032 + CRLF //"N�veis"
				cLog += cLine + CRLF
				cLog += Padr( STR0005, 10 ) //"Agrupador" 
				cLog += "|" 
				cLog += Padr( STR0027, 30 ) //STR0027
				cLog += "|" 
				cLog += Padr( STR0006, 10 ) //"N�vel"
				cLog += "|" 
				cLog += Padr( STR0027, 30 ) //STR0027
				cLog += CRLF
				cLog += cLine + CRLF			
	
				//-------------------------------------------------------------------
				// Loga cada n�vel que foi encontrado.  
				//-------------------------------------------------------------------	
				For nMatch := 1 To Len ( aMatch )
					cLog += Padr( aMatch[nMatch][1], 10 )
					cLog += "|" 
					
					If ! Empty( aMatch[nMatch][1] )
						cLog += Padr( AllTrim( Posicione( "AOL", 1, cFilAOL + aMatch[nMatch][1], "AOL_RESUMO" ) ), 30 )
					Else
						cLog += Padr( STR0021, 30 ) //"Indefinido"
					EndIf 
					
					cLog += "|" 
					cLog += Padr( aMatch[nMatch][2], 10 )
					cLog += "|" 
					cLog += Padr( aMatch[nMatch][4], 30 )
					cLog += CRLF
				Next nMatch 			
			EndIf 
			
			//-------------------------------------------------------------------
			// Recupera as filas avaliadas.  
			//-------------------------------------------------------------------		
			aEvaluted 	:= Self:GetEvaluted()	

			If ! ( Empty( aEvaluted ) )	
				//-------------------------------------------------------------------
				// Monta o cabe�alho para as exce��o.  
				//-------------------------------------------------------------------
				cLog += cLine + CRLF
				cLog += STR0035 + CRLF //"Fila aderente"
				cLog += cLine + CRLF	
				cLog += Padr( STR0003, 10 ) //"Fila"
				cLog += "|" 
				cLog += Padr( STR0027, 30 ) //"Descri��o"
				cLog += "|" 
				cLog += Padr( STR0033, 10 ) //"Pontos"
				cLog += "|" 
				cLog += Padr( STR0034, 10 ) //"Fidelidade"
				cLog += CRLF
				cLog += cLine + CRLF		

				//-------------------------------------------------------------------
				// Loga cada exce��o encontrada encontrado.  
				//-------------------------------------------------------------------	
				For nQueue := 1 To Len( aEvaluted )			
					cLog += Padr( aEvaluted[nQueue][QUEUE], 10 )
					cLog += "|" 
					cLog += Padr( Posicione( "AZ6", 1, cFilAZ6 + Self:cTerritory + aEvaluted[nQueue][QUEUE], "AZ6_DESCRI" ) , 30 ) 
					cLog += "|" 
					cLog += Padr( cBIStr( aEvaluted[nQueue][SCORE] ), 10 )
					cLog += "|" 
					cLog += Padr( cBIStr( aEvaluted[nQueue][FIDELITY] ), 10 )

					cLog += CRLF

					If ! ( Empty( aEvaluted[nQueue][REACH] ) )
						For nReach := 1 To Len( aEvaluted[nQueue][REACH] )
							cLog += cLine + CRLF
							cLog += Space( 20 )
							cLog += Padr( aEvaluted[nQueue][REACH][nReach][1], 10 )
							cLog += "|" 
							cLog += Padr( aEvaluted[nQueue][REACH][nReach][2], 10 )
							cLog += "|" 
							cLog += Padr( aEvaluted[nQueue][REACH][nReach][3], 10 )	
							cLog += "|" 
							cLog += Padr( aEvaluted[nQueue][REACH][nReach][4], 10 )			
							cLog += CRLF + CRLF
						Next nReach
					EndIf 
				Next nQueue 	
			EndIf						
		EndIf 
		
		//-------------------------------------------------------------------
		// Recupera a melhor fila.  
		//-------------------------------------------------------------------		
		aQueue := Self:GetQueue()
		
		If ! ( Empty( aQueue ) )	
			//-------------------------------------------------------------------
			// Monta o cabe�alho para as fila.  
			//-------------------------------------------------------------------
			cLog += cLine + CRLF
			cLog += STR0036 + CRLF //"Fila Escolhida"
			cLog += cLine + CRLF	
			cLog += Padr( STR0003, 10 ) //"Fila"
			cLog += "|" 
			cLog += Padr( STR0027, 30 ) //"Descri��o"
			cLog += "|" 
			cLog += Padr( STR0033, 10 ) //"Pontos"
			cLog += "|" 
			cLog += Padr( STR0034, 10 ) //"Fidelidade"
			cLog += CRLF
			cLog += cLine + CRLF		

			//-------------------------------------------------------------------
			// Loga cada fila encontrada encontrada.  
			//-------------------------------------------------------------------	
			For nQueue := 1 To Len( aQueue )			
				cLog += Padr( aQueue[nQueue][QUEUE], 10 )
				cLog += "|" 
				cLog += Padr( Posicione( "AZ6", 1, cFilAZ6 + Self:cTerritory + aQueue[nQueue][QUEUE], "AZ6_DESCRI" ) , 30 ) 
				cLog += "|" 
				cLog += Padr( cBIStr( aQueue[nQueue][SCORE] ), 10 )
				cLog += "|" 
				cLog += Padr( cBIStr( aQueue[nQueue][FIDELITY] ), 10 )

				cLog += CRLF

				If ! ( Empty( aQueue[nQueue][REACH] ) )
					For nReach := 1 To Len( aQueue[nQueue][REACH] )
						cLog += cLine + CRLF
						cLog += Space( 20 )
						cLog += Padr( aQueue[nQueue][REACH][nReach][1], 10 )
						cLog += "|" 
						cLog += Padr( aQueue[nQueue][REACH][nReach][2], 10 )
						cLog += "|" 
						cLog += Padr( aQueue[nQueue][REACH][nReach][3], 10 )	
						cLog += "|" 
						cLog += Padr( aQueue[nQueue][REACH][nReach][4], 10 )			
						cLog += CRLF + CRLF
					Next nReach
				EndIf 
			Next nQueue 	

			//-------------------------------------------------------------------
			// Recupera todos os membros da fila.  
			//-------------------------------------------------------------------			
			aAllMembers := Self:GetAllMembers( aQueue )
			
			If ! Empty( aAllMembers )
				//-------------------------------------------------------------------
				// Monta o cabe�alho para os membros da fila.  
				//-------------------------------------------------------------------
				cLog += cLine + CRLF
				cLog += STR0037 + CRLF //"Membro da Fila"
				cLog += cLine + CRLF
				cLog += Padr( STR0009, 20 ) //"Tipo"
				cLog += "|" 
				cLog += Padr( STR0010, 10 ) //"Membro"
				cLog += "|" 
				cLog += Padr( STR0027, 20 ) //"Descri��o"
				cLog += "|" 
				cLog += Padr( STR0011, 10 ) //"Contas"
				cLog += "|" 
				cLog += Padr( STR0012, 10 ) //"Limite"
				cLog += CRLF
				cLog += cLine + CRLF	
			
				//-------------------------------------------------------------------
				// Loga cada membro que foi encontrado.  
				//-------------------------------------------------------------------	
				For nMember := 1 To Len ( aAllMembers )
					If ( aAllMembers[nMember][TYPE] == UNIT )
						cLog += Padr( STR0013, 20 ) //"Unidade de neg�cio"
					ElseIf ( aAllMembers[nMember][TYPE] == CRM )
						cLog += Padr( STR0014, 20 ) //"Usu�rio CRM"
					ElseIf ( aAllMembers[nMember][TYPE] == TEAM )
						cLog += Padr( STR0015, 20 ) //"Time de vendas"
					EndIf 
	
					cLog += "|" 
					cLog += Padr( cMember, 10 )
					cLog += "|"
					cLog += Padr( CRMA640Gat( aAllMembers[nMember][TYPE], aAllMembers[nMember][MEMBER] ) , 20 ) 
					cLog += "|" 
					cLog += Padr( cBIStr( aAllMembers[nMember][ACCOUNT] ), 10 )
					cLog += "|" 
					cLog += Padr( cBIStr( aAllMembers[nMember][LIMIT] ), 10 )
					cLog += CRLF
				Next nMember 	
			EndIf			

			//-------------------------------------------------------------------
			// Recupera o membro sugerido.  
			//-------------------------------------------------------------------
			aFavorite := Self:GetFavorite()
	
			//-------------------------------------------------------------------
			// Verifica se algum membro foi sugerido.  
			//-------------------------------------------------------------------
			If ! Empty( aFavorite ) 
				//-------------------------------------------------------------------
				// Monta o cabe�alho para o membro sugerido.  
				//-------------------------------------------------------------------	
				cLog += cLine + CRLF
				cLog += STR0019 + CRLF //"Membro sugerido"
				cLog += cLine + CRLF			
				cLog += Padr( STR0009, 20 ) //"Tipo"
				cLog += "|" 
				cLog += Padr( STR0010, 10 ) //"Membro"
				cLog += "|" 
				cLog += Padr( STR0027, 30 ) //STR0027
				cLog += CRLF
				cLog += cLine + CRLF
				
				//-------------------------------------------------------------------
				// Loga o membro sugerido. 
				//-------------------------------------------------------------------			
				If ( aFavorite[TYPE] == UNIT )
					cLog += Padr( STR0013, 20 ) //"Unidade de neg�cio"
				ElseIf ( aFavorite[TYPE] == CRM )
					cLog += Padr( STR0014, 20 ) //"Usu�rio CRM"
				ElseIf ( aFavorite[TYPE] == TEAM )
					cLog += Padr( STR0015, 20 ) //"Time de vendas"
				EndIf 
				
				cLog += "|"	
				cLog += Padr( aFavorite[MEMBER], 10 ) 
				cLog += "|"
				cLog += Padr( CRMA640Gat( aFavorite[TYPE], aFavorite[MEMBER] ) , 30 )
				cLog += CRLF		
			EndIf
			
			//-------------------------------------------------------------------
			// Recupera o membro escolhido.  
			//-------------------------------------------------------------------		
			cType 	:= Self:GetInfo( 2 )
			cMember := Self:GetInfo( 3 )	
	
			//-------------------------------------------------------------------
			// Monta o cabe�alho para o membro.  
			//-------------------------------------------------------------------	
			cLog += cLine + CRLF
			cLog += STR0017 + CRLF //"Membro escolhido"
			cLog += cLine + CRLF			
			cLog += Padr( STR0009, 20 ) //"Tipo"
			cLog += "|" 
			cLog += Padr( STR0010, 10 ) //"Membro"
			cLog += "|" 
			cLog += Padr( STR0027, 30 ) //"Descri��o"
			cLog += "|" 
			cLog += Padr( STR0016, 15 ) //"Respons�vel"
			cLog += CRLF
			cLog += cLine + CRLF
	
			//-------------------------------------------------------------------
			// Loga o membro.  
			//-------------------------------------------------------------------	
			If ( cType == UNIT )
				cLog += Padr( STR0013, 20 ) //"Unidade de neg�cio"
			ElseIf ( cType == CRM )
				cLog += Padr( STR0014, 20 ) //"Usu�rio CRM"
			ElseIf ( cType == TEAM )
				cLog += Padr( STR0015, 20 ) //"Time de vendas"
			EndIf 
			
			cLog += "|"	
			cLog += Padr( cMember, 10 ) 
			cLog += "|"
			cLog += Padr( CRMA640Gat( cType, cMember ) , 30 )
			cLog += "|"				
			cLog += Padr( Self:GetInfo( 1 ), 10 )
			cLog += CRLF					
		EndIf		
	Else
		cLog += cLine + CRLF
		cLog += STR0018 + CRLF //"Nenhuma fila configurada"
		cLog += cLine + CRLF 
	EndIf 
	
	//-------------------------------------------------------------------
	// Formata o log.  
	//-------------------------------------------------------------------	
	cLog := Upper( cLog )
Return cLog 

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Libera a mem�ria alocada para o objeto. 

@author  Valdiney V GOMES 
@version P12
@since   23/06/2015  
/*/
//-------------------------------------------------------------------
Method Destroy() Class CRMCaster	
	Self:oTerritory		:= Nil
	Self:aFavorite 		:= aSize( Self:aFavorite, 0 )
	Self:aAllQueues 	:= aSize( Self:aAllQueues, 0 )
	Self:aRule			:= aSize( Self:aRule, 0 )
	Self:aMatch			:= aSize( Self:aMatch, 0 )
	Self:aEvaluted		:= aSize( Self:aEvaluted, 0 )
	Self:aQueue			:= aSize( Self:aQueue, 0 )
	Self:aAllMembers	:= aSize( Self:aAllMembers, 0 )
	Self:aMember		:= aSize( Self:aMember, 0 )
	Self:aError			:= aSize( Self:aError, 0 )
	Self:cTerritory		:= ""
	Self:cProcess		:= ""
	Self:cEntity		:= ""	

	oMapKey:Clean()	
Return