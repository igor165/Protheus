#INCLUDE "CRMTERRITORY.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"

#DEFINE GROUP		1
#DEFINE LEVEL		2
#DEFINE	SMARTID		3

#DEFINE ID			1
#DEFINE SCORE		2
#DEFINE FIDELITY	3
#DEFINE TYPE		4
#DEFINE MEMBER		5
#DEFINE REACH		6

Static oMapKey

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMTerritory
Classe responsável pelo processamento e gestão dos dados do processo de 
avaliação de territórios. 

@example	
	oTerritory:SetProcess( "MATA030" )
	oTerritory:SetEntity( "SA1" )
	
	aTerritory 	:= oTerritory:GetTerritory() 
	
	cID 		:= oTerritory:GetInfo( 1, aTerritory ) 
	nScore 		:= oTerritory:GetInfo( 2, aTerritory ) 
	nFidelity 	:= oTerritory:GetInfo( 3, aTerritory )
	cMemberType	:= oTerritory:GetInfo( 4, aTerritory )
	cMember		:= oTerritory:GetInfo( 5, aTerritory )
	aReach 		:= oTerritory:GetInfo( 6, aTerritory )

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Class CRMTerritory
	Data aQueue	
	Data aMatch	
	Data aCommon
	Data aException		
	Data aTerritory
	Data aError
	Data aProperty
	Data cProcess
	Data cEntity
	Data cFilter
	Data cSequence
	Data lForced
	Data lEvaluted
	Data dDate
	
				
	Method New() CONSTRUCTOR	
	Method SetProcess( cProcess )
	Method SetEntity( cEntity )
	Method SetFilter( xType )
	Method SetSequence( cSequence )
	Method SetBaseDate( dDate )
	Method LoadMatch( aQueue ) 
	Method LoadQueue( cProcess, cEntity ) 
	Method LoadException( aMatch )
	Method LoadCommon( aMatch ) 
	Method GetProcess()
	Method GetEntity()		
	Method GetMatch()
	Method GetQueue()
	Method GetException()	
	Method GetCommon()	
	Method GetTerritory() 
	Method GetInfo( nInfo, aTerritory ) 
	Method GetInheritance( aTerritory, aAll )
	Method GetParent( cTerritory )
	Method GetFilter( )
	Method GetBaseDate()
	Method GetSequence()
	Method IsAvailable( cTerritory )
	Method ForceTerritory( cTerritory ) 
	Method EvalTerritory( aTerritory )	
	Method SetError( cID, cMessage )
	Method GetError()
	Method GetLog( lFinal )
	Method Viewer( aTerritory )
	Method SetProperty( cProperty, cValue )
	Method GetProperty( cProperty )
	Method Destroy()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} new
Método construtor da classe. 

@return Self, objeto, Instância da classe CRMTerritory. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method New() Class CRMTerritory
	Self:cProcess		:= ""
	Self:cEntity		:= ""
	Self:cFilter		:= ""
	Self:aQueue			:= {}
	Self:aMatch			:= {}
	Self:aCommon		:= {}	
	Self:aException		:= {}
	Self:aTerritory		:= {}
	Self:aError			:= {}
	Self:aProperty		:= {}
	Self:lEvaluted		:= .F.
	Self:lForced		:= .F. 
	Self:dDate			:= dDatabase
	
	If ( Empty( oMapKey ) )
		oMapKey := THashMap():New()	
	EndIf 
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} setProcess
Define a rotina para a qual o território será avaliado. 

@param cProcess, caracter, Rotina para o qual o território será avaliado. 
@return cProcess, caracter, Rotina para o qual o território será avaliado. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method SetProcess( cProcess ) Class CRMTerritory
	Default cProcess := ""

	Self:cProcess := cProcess
Return Self:cProcess

//-------------------------------------------------------------------
/*/{Protheus.doc} GetProcess
Retorna a rotina relacionada com o território. 

@return cProcess Rotina relacionada ao território. 

@author  Valdiney V GOMES 
@version P12
@since   20/06/2015  
/*/
//-------------------------------------------------------------------
Method GetProcess() Class CRMTerritory
Return Self:cProcess

//-------------------------------------------------------------------
/*/{Protheus.doc} setEntity
Define a entidade relacionada com o território. 

@param cEntity, caracter, Entidade para o qual o território será avaliado. 
@return cEntity, caracter,  Entidade para o qual o território será avaliado. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method SetEntity( cEntity ) Class CRMTerritory
	Default cEntity := ""
	
	Self:cEntity := cEntity
Return Self:cEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEntity
Retorna a entidade relacionada com o território. 

@return cEntity, caracter, Entidade relacionada ao território. 

@author  Valdiney V GOMES 
@version P12
@since   20/06/2015  
/*/
//-------------------------------------------------------------------
Method GetEntity() Class CRMTerritory
Return Self:cEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFilter
Define o tipo de território que será avaliado sendo: 1 - Território e 2 - Repositório

@param xFilter, indefinido, Tipo de território a ser considerado. 
@return cFilter, caracter,  Tipo de território a ser considerado. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method SetFilter( xFilter ) Class CRMTerritory
	Default xFilter := ""
	
	Self:cFilter := cBIStr( xFilter )
Return Self:cFilter


//-------------------------------------------------------------------
/*/{Protheus.doc} SetSequence
Define uma sequencia de avaliação dos agrupadores para avaliação da entidade.
( Por padrão a sequencia utilizada é da propria entidade avaliada, caso haja. )

@param 	 cSequence, caracter, Sequencia de avaliação dos agrupadores para entidade avaliada. 
@return cSequence, caracter, Sequencia de avaliação dos agrupadores para entidade avaliada. 

@author  Anderson Silva
@version P12
@since   27/04/2016  
/*/
//-------------------------------------------------------------------
Method SetSequence( cSequence )  Class CRMTerritory
	Default cSequence   := ""
	
	Self:cSequence := cSequence
Return Self:cSequence


//-------------------------------------------------------------------
/*/{Protheus.doc} GetSequence
Retorna a sequencia de avaliação utiliza na entidade.

@return cSequence, caracter, Sequencia de avaliação dos agrupadores para entidade avaliada. 

@author  Anderson Silva
@version P12
@since   27/04/2016  
/*/
//-------------------------------------------------------------------
Method GetSequence()  Class CRMTerritory
Return Self:cSequence
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GetFilter
Retorna o tipo de território que será avaliado.  . 

@return cEntity, caracter,  Tipo de território a ser considerado.  

@author  Valdiney V GOMES 
@version P12
@since   20/06/2015  
/*/
//-------------------------------------------------------------------
Method GetFilter() Class CRMTerritory
Return Self:cFilter

//-------------------------------------------------------------------
/*/{Protheus.doc} setBaseDate
Define a data para avaliação do território. 

@param dDate, data, Data para avaliação do território. 
@return dDate, data, Data para avaliação do território.

@author  Valdiney V GOMES 
@version P12
@since   03/11/2015  
/*/
//-------------------------------------------------------------------
Method setBaseDate( dDate ) Class CRMTerritory
	Default dDate := dDatabase
	
	Self:dDate := dDate
Return Self:dDate

//-------------------------------------------------------------------
/*/{Protheus.doc} GetBaseDate
Define a data para avaliação do território.

@return dDate, data, Data para avaliação do território.

@author  Valdiney V GOMES 
@version P12
@since   03/11/2015    
/*/
//-------------------------------------------------------------------
Method GetBaseDate() Class CRMTerritory
Return Self:dDate

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadQueue
Executa o sequenciador e retorna a relação de agrupadores que devem 
ser executados para avaliação do território. 

@return aQueue, array, Lista no formato {AGRUPADOR, ...}. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015    
/*/
//-------------------------------------------------------------------
Method LoadQueue() Class CRMTerritory	

	Local cKey		:= ""
	Local nIndex	:= 0
	Local cFilA04 	:= xFilial("A04")
	Local cFilA08 	:= xFilial("A08")
	Local cFilAOL	:= xFilial("AOL")
	
	Self:aQueue := {} 

	If Empty( Self:cSequence )
		//-------------------------------------------------------------------
		// Localiza o sequenciador por A03_FILIAL+A03_ROTINA
		//-------------------------------------------------------------------
		nIndex	:= 2
		cKey	:= 	Self:cProcess 
	Else
		//-------------------------------------------------------------------
		// Localiza o sequenciador por A03_FILIAL+A03_CODSEQ 
		//------------------------------------------------------------------- 
		nIndex	:= 1
		cKey	:= 	Self:cSequence
	EndIf
	
	A03->( DBSetOrder( nIndex ) ) 

	If ( A03->( MSSeek( xFilial("A03") + cKey ) ) )	
		//-------------------------------------------------------------------
		// Localiza os agrupadores do sequenciador.  
		//-------------------------------------------------------------------
		A04->( DBSetOrder( 1 ) ) 
	
		If ( A04->( MSSeek( cFilA04 + A03->A03_CODSEQ ) ) )
			While ( A04->( ! Eof() ) .And. cFilA04 == A04->A04_FILIAL .And. A04->A04_CODSEQ == A03->A03_CODSEQ )	
				//-------------------------------------------------------------------
				// Verifica se o agrupador foi bloqueado.  
				//-------------------------------------------------------------------		
				If ! ( A04->A04_MSBLQL == "1" )		
					//-------------------------------------------------------------------
					// Insere um novo agrupador na fila de avaliação.  
					//-------------------------------------------------------------------
					If ( aScan( Self:aQueue, {|x| x == A04->A04_CODAGR } ) == 0 )		
						aAdd( Self:aQueue, A04->A04_CODAGR )
					EndIf 		
				EndIf 
				
				A04->( DBSkip() )	
			EndDo
		EndIf 
	Else
		//-------------------------------------------------------------------
		// Localiza as regras de pesquisa do agrupador.  
		//-------------------------------------------------------------------
		A08->( DBSetOrder( 2 ) )
		
		If ( A08->( MSSeek( cFilA08 + Self:cEntity ) ) )	
			While ( A08->( ! Eof() ) .And. cFilA08 == A08->A08_FILIAL .And. A08->A08_ENTDOM == Self:cEntity )
				//-------------------------------------------------------------------
				// Localiza o agrupador.  
				//-------------------------------------------------------------------
				AOL->( DBSetOrder( 1 ) )
				
				If ( AOL->( MSSeek( cFilAOL + A08->A08_CODAGR ) ) )	
					//-------------------------------------------------------------------
					// Verifica se é um agrupador para território.  
					//-------------------------------------------------------------------			
					If ( AOL->AOL_TERRIT == "1" )
						//-------------------------------------------------------------------
						// Insere um novo agrupador na fila de avaliação.  
						//-------------------------------------------------------------------
						If ( aScan( Self:aQueue, {|x| x == A08->A08_CODAGR } ) == 0 )		
							aAdd( Self:aQueue, A08->A08_CODAGR )
						EndIf 	
					EndIf 
				EndIf 	

				A08->( DBSkip() )
			EndDo
		EndIf
	EndIf 
	
	//-------------------------------------------------------------------
	// Identifica erros no processo.  
	//-------------------------------------------------------------------	
	If ( Empty( Self:aQueue ) )
		Self:SetError( "LOADSEQUENCE", STR0042 + Self:cProcess + STR0043 + Self:cEntity ) //"Nenhum agrupador encontrado para o processo "###" e entidade " 
	EndIf 	
Return Self:aQueue

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQueue
Retorna a lista com os agrupadores do sequenciador. 

@return aQueue, array, Lista no formato {AGRUPADOR, ...}. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015    
/*/
//-------------------------------------------------------------------
Method GetQueue() Class CRMTerritory	
Return Self:aQueue

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadMatch
Executa o sequenciador e retorna o agrupador e o nível que foi encontrado
na avaliação de cada agrupador.  

@param aQueue, array, Fila de avaliação de agrupadores no formato {AGRUPADOR, ...}. 
@return aMatch, array, Lista no formato {{AGRUPADOR, NÍVEL}, ...}. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method LoadMatch( aQueue ) Class CRMTerritory
	Local aPool 	:= {}
	Local aGroup	:= {}
	Local aKey		:= {}
	Local cPool		:= ""
	Local nQueue	:= 0

	Default aQueue	:= {}

	Self:aMatch 	:= {}

	//-------------------------------------------------------------------
	// Percorre toda a fila de agrupadores.  
	//-------------------------------------------------------------------
	For nQueue := 1 To Len( aQueue )	
		//-------------------------------------------------------------------
		// Recupera o agrupador.  
		//-------------------------------------------------------------------
		cPool	:= aQueue[nQueue]
		
		//-------------------------------------------------------------------
		// Procura o melhor nível. 
		//-------------------------------------------------------------------	
		aKey	:= CRMA580Key( cPool, Self:cEntity, Self:cProcess )
		aGroup 	:= CRMA580Group( cPool, aKey, .F., .F., oMapKey ) 

		//-------------------------------------------------------------------
		// Lista todos os agrupadores e níveis encontrados.  
		//-------------------------------------------------------------------
		If ( ! Empty( aGroup ) .And. ! Empty( aGroup[GROUP] ) ) 
			aAdd( Self:aMatch, aGroup )
		Else
			//-------------------------------------------------------------------
			// Identifica erros no processo.  	
			//-------------------------------------------------------------------						
			If ( Empty( aGroup ) )
				Self:SetError( "LOADMATCH", STR0018 + aQueue[nQueue] + STR0035 )	//"Agrupador "###" não encontrado."		
			Else		
				Self:SetError( "LOADMATCH", STR0036 + cBIStr( aKey, .T. ) + STR0037 + aQueue[nQueue] ) //"Nenhum nível encontrado para a regra de pesquisa "###" no agrupador " 			
			EndIf 
		EndIf
	Next nQueue
Return Self:aMatch

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMatch
Retorna o agrupador e o nível que foi encontrado na avaliação de cada agrupador
de um sequenciador.   

@return aMatch, array, Lista no formato {{AGRUPADOR, NÍVEL}, ...}. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method GetMatch() Class CRMTerritory
Return Self:aMatch

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTerritory
Executa a avaliação do melhor território. 

@param [lInterface], lógico, Identifica se o território avaliado será exibido ao usuário. 
@param [lForce], lógico, Identifica se deve exibir interface mesmo quando não há empate. 
@return aTerritory, array, Relação de territórios mais aderentes no formato	{{TERRITÓRIO, PONTOS, FIDELIDADE, TIPO_MEMBRO, MEMBRO {{AGRUPADOR, NÍVEL, PONTOS, FIDELIDADE, TERRITÓRIO }}}, ...}.

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method GetTerritory( lInterface, lForce ) Class CRMTerritory
	Local aArea			:= GetArea() 
	Local aQueue		:= {}
	Local aMatch		:= {}
	Local aTerritory	:= {}
	Local cTerritory	:= ""
	Local nTerritory	:= 0
	Local nGarbage		:= 0
	Local nLenTerritory	:= 0

	Default lInterface	:= ! ( IsBlind() ) 
	Default lForce		:= .F. 

	Self:aTerritory 	:= {}
	Self:lForced		:= .F. 
	Self:lEvaluted		:= .T. 

	//-------------------------------------------------------------------
	// Recupera o sequênciador.  
	//-------------------------------------------------------------------
	aQueue 		:= Self:LoadQueue() 
	
	//-------------------------------------------------------------------
	// Recupera o resultado da avaliação dos agrupadores.  
	//-------------------------------------------------------------------	
	aMatch 		:= Self:LoadMatch( aQueue )

	//-------------------------------------------------------------------
	// Recupera as exceção.  
	//-------------------------------------------------------------------
	aTerritory 	:= Self:LoadException( aMatch ) 
	
	//-------------------------------------------------------------------
	// Recupera os territórios.  
	//-------------------------------------------------------------------
	If ( Empty( aTerritory ) )
		aTerritory := Self:LoadCommon( aMatch ) 
	EndIf 

	//-------------------------------------------------------------------
	// Acumula a pontuação dos territórios ascendentes.  
	//-------------------------------------------------------------------
	If ( ! Empty( aTerritory ) )
		For nTerritory := 1 To Len( aTerritory )
			aTerritory[nTerritory] := Self:GetInheritance( aTerritory[nTerritory], aTerritory ) 
		Next nTerritory	
		
		//-------------------------------------------------------------------
		// Reordena os territórios por pontuação.  
		//-------------------------------------------------------------------
		aSort( aTerritory,,,{ |x,y| x[SCORE] > y[SCORE] } )
	EndIf 

	//-------------------------------------------------------------------
	// Filtra os territórios com maior pontuação e fidelidade.  
	//-------------------------------------------------------------------	
	For nTerritory := 1 To Len( aTerritory )
		If ! ( Empty( Self:aTerritory ) )
			If ( aTerritory[nTerritory][SCORE] >= Self:aTerritory[ Len( Self:aTerritory ) ][SCORE] )	
				If ( aTerritory[nTerritory][FIDELITY] >= Self:aTerritory[ Len( Self:aTerritory ) ][FIDELITY] )	
					nGarbage := aScan( 	Self:aTerritory,;
										{|x| x[SCORE] < aTerritory[nTerritory][SCORE] .Or. x[FIDELITY] < aTerritory[nTerritory][FIDELITY] } )	 
										
					If ! ( nGarbage == 0 )     
				 		aDel( Self:aTerritory, nGarbage ) 
				  		aSize( Self:aTerritory, Len( Self:aTerritory ) - 1 )
				  	EndIf 

					aAdd( Self:aTerritory, aTerritory[nTerritory] ) 
				EndIf 
			EndIf
		Else
			aAdd( Self:aTerritory, aTerritory[nTerritory] ) 
		EndIf 	
	Next nTerritory	

	//-------------------------------------------------------------------
	// Verifica se deve exibir interface de seleção de território.  
	//-------------------------------------------------------------------		
	If ! ( Empty( Self:aTerritory ) )
	
		nLenTerritory := Len( Self:aTerritory ) 
		
		If ( lInterface .And. ( lForce .Or. nLenTerritory > 1  ) )
			//-------------------------------------------------------------------
			// Força o território selecionado pelo usuário. 
			//-------------------------------------------------------------------  
			Self:ForceTerritory( Self:Viewer( Self:aTerritory ) )
		ElseIf nLenTerritory > 1
			//-------------------------------------------------------------------
			// Força um território aleatório. 
			//------------------------------------------------------------------- 
			Self:ForceTerritory( Self:aTerritory[ Randomize( 1, nLenTerritory ) ][ID] )	
		EndIf 
			
	EndIf 	

	//-------------------------------------------------------------------
	// Identifica erros no processo.  
	//-------------------------------------------------------------------		
	If ( Empty( Self:aTerritory ) )
		Self:SetError( "GETTERRITORY", STR0044 ) //"Nenhum território ou exceção foi encontrada."
	EndIf 		

	RestArea( aArea ) 
Return Self:aTerritory

//-------------------------------------------------------------------
/*/{Protheus.doc} GetParent
Retorna os territórios ascendentes de um território.

@param cTerritory, caracter, Código do território. 
@param aParent, array, Territórios ascendentes no formato { TERRITORIO, ...}. 
@return aParent, array, Territórios ascendentes no formato { TERRITORIO, ...}. 

@author  Valdiney V GOMES 
@version P12
@since   23/07/2015  
/*/
//-------------------------------------------------------------------
Method GetParent( cTerritory, aParent ) Class CRMTerritory 
	Local cFather		:= ""
	
	Default cTerritory	:= ""
	Default aParent		:= {}
	
	//-------------------------------------------------------------------
	// Localiza o território.  
	//-------------------------------------------------------------------
	AOY->( DBSetOrder( 1 ) )

	If ( AOY->( MSSeek( xFilial("AOY") + cTerritory ) ) )		
		cFather := AOY->AOY_SUBTER

		//-------------------------------------------------------------------
		// Verifica se o território tem um pai.  
		//-------------------------------------------------------------------
		If ! ( Empty( cFather ) )
			//-------------------------------------------------------------------
			// Lista o território pai.  
			//-------------------------------------------------------------------
			aAdd( aParent, cFather ) 		
			
			//-------------------------------------------------------------------
			// Verifica se o território pai encontrado tem ascendentes.  
			//-------------------------------------------------------------------		
			Self:GetParent( cFather, @aParent )
		EndIf 
	EndIf 
Return aParent

//-------------------------------------------------------------------
/*/{Protheus.doc} GetInheritance
Adiciona a um território a herança dos seus ascendentes.

@param aTerritory, caracter, Território que será beneficiado no formato {TERRITÓRIO, PONTOS, FIDELIDADE, TIPO_MEMBRO, MEMBRO {{AGRUPADOR, NÍVEL, PONTOS, FIDELIDADE, TERRITÓRIO}}}. 
@param aAll, array, Conjunto de todos os territórios no formato no formato {{TERRITÓRIO, PONTOS, FIDELIDADE, TIPO_MEMBRO, MEMBRO {{AGRUPADOR, NÍVEL, PONTOS, FIDELIDADE, TERRITÓRIO}}}, ...}.
@return aTerritory, caracter, Território beneficiado atualizado.

@author  Valdiney V GOMES 
@version P12
@since   23/07/2015  
/*/
//-------------------------------------------------------------------
Method GetInheritance( aTerritory, aAll ) Class CRMTerritory 
	Local aParent 		:= {}
	Local nParent		:= 0
	Local nTerritory	:= 0
	Local nReach		:= 0
	
	Default aTerritory	:= ""
	Default aAll		:= {}

	//-------------------------------------------------------------------
	// Recupera os territórios ascendentes.  
	//-------------------------------------------------------------------
	aParent := Self:GetParent( aTerritory[ID] )

	If ( ! Empty( aParent ) )
		For nParent := 1 To Len( aParent )
			nTerritory := aScan( aAll, { |x| x[ID] == aParent[nParent] } )
			
			If ( ! Empty( nTerritory ) )
				//-------------------------------------------------------------------
				// Acumula a pontuação e fidelidade herdadas.  
				//-------------------------------------------------------------------
				aTerritory[SCORE]	 	+= aAll[nTerritory][SCORE]
				aTerritory[FIDELITY] 	+= aAll[nTerritory][FIDELITY]
				
				//-------------------------------------------------------------------
				// Relaciona os agrupadores herdados.  
				//-------------------------------------------------------------------		
				For nReach := 1 To Len( aAll[nTerritory][REACH] )
					aAdd( aTerritory[REACH], aClone( aAll[nTerritory][REACH][nReach] ) )
				Next nReach
			EndIf 	
		Next nParent
	EndIf 
Return aTerritory

//-------------------------------------------------------------------
/*/{Protheus.doc} GetInfo
Retorna uma informação solicitada do território avaliado.  

@param nInfo, numérico, Informação que será recuperada.
@param [aTerritory], array, Território.
@return xInfo, indefinido, Informação recuperada. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method GetInfo( nInfo, aTerritory ) Class CRMTerritory
	Local xInfo 		:= Nil 
	
	Default nInfo 		:= 1
	Default aTerritory	:= Self:aTerritory 
	
	If ! ( Empty( aTerritory ) )
		If ( nInfo <= Len( aTerritory[1] ) )
			xInfo := aTerritory[1][nInfo]
		EndIf 
	EndIf 
Return xInfo 

//-------------------------------------------------------------------
/*/{Protheus.doc} Viewer
Exibe interface com os melhores territórios. 

@param aTerritory, array, Lista contendo os melhores territórios.  
@return cTerritory, caracter, Código do território selecionado. 

@author  Valdiney V GOMES 
@version P12
@since   10/07/2015  
/*/
//-------------------------------------------------------------------
Method Viewer( aTerritory ) Class CRMTerritory 
	Local oDialog		:= Nil 
	Local oBrowse		:= Nil 
	Local oColumn		:= Nil 
	Local oPanel		:= Nil
	Local bOK  	   		:= {|| oDialog:DeActivate() } 	
	Local bCode			:= {|| aTerritory[oBrowse:nAt][1] }
	Local bTimer		:= {|| oDialog:DeActivate() }
	Local bDescription	:= {|| Posicione( "AOY", 1, xFilial( "AOY" ) + aTerritory[oBrowse:nAt][1], "AOY_NMTER" ) }
	Local bLog 	   		:= {|| CRMA950Viewer( Self:GetLog( .F. ) ) } 
	Local cTerritory	:= ""
	Local nTimer		:= 30
	
	Default aTerritory	:= {}
	
	//-------------------------------------------------------------------
	// Monta o janela de seleção de território. 
	//-------------------------------------------------------------------  
	oDialog := FWDialogModal():New()
	oDialog:SetBackground( .T. )
	oDialog:SetTitle( STR0009 ) 
	oDialog:SetEscClose( .F. )
	oDialog:SetSize( 150, 300 ) 
	oDialog:EnableFormBar( .T. ) 
	oDialog:SetCloseButton( .F. )
	oDialog:CreateDialog() 
	oDialog:SetTimer( nTimer, bTimer )
	oDialog:CreateFormBar()
	oDialog:AddButton( STR0010, bOK, STR0010, , .T., .F., .T., ) //"Confirmar"
	oDialog:AddButton( "Log", bLog, "Log", , .T., .F., .T., ) //"Log"
	
	//-------------------------------------------------------------------
	// Recupera o container para o browse.  
	//-------------------------------------------------------------------		
	oPanel := oDialog:GetPanelMain()
		
	//-------------------------------------------------------------------
	// Monta o browse.  
	//-------------------------------------------------------------------			  
	DEFINE FWBROWSE oBrowse DATA ARRAY ARRAY aTerritory NO REPORT NO LOCATE NO CONFIG DOUBLECLICK bOK OF oPanel				
		//-------------------------------------------------------------------
		// Monta as colunas do browse.  
		//-------------------------------------------------------------------
		ADD COLUMN oColumn DATA bCode		 TITLE STR0008 	OF oBrowse //"Código"
		ADD COLUMN oColumn DATA bDescription TITLE STR0007 	OF oBrowse //"Descrição"
	ACTIVATE FWBROWSE oBrowse   

	oDialog:Activate()
	
	//-------------------------------------------------------------------
	// Recupera o código do território selecionado.  
	//-------------------------------------------------------------------	
	cTerritory := aTerritory[oBrowse:nAt][ID]
Return cTerritory

//-------------------------------------------------------------------
/*/{Protheus.doc} ForceTerritory
Insere um novo território.  

@param cTerritory, caracter, Código do território.
@param cType, caracter, Tipo de membro do rodízio. 
@param cMember, caracter, Membro do rodízio.
@return lForced, lógico, Indica se o território foi forçado. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method ForceTerritory( cTerritory, cType, cMember ) Class CRMTerritory
	Local cGroup 		:= ""
	Local cLevel		:= ""
	Local nScore		:= 0
	Local nFidelity		:= 0	
	
	Default cTerritory 	:= ""
	Default cType 		:= ""
	Default cMember 	:= ""
	
	//-------------------------------------------------------------------
	// Identifica se o território está disponível.  
	//-------------------------------------------------------------------
	If ( Self:IsAvailable( cTerritory ) )
		Self:lForced		:= .T. 
		Self:lEvaluted		:= .T. 
		
		//-------------------------------------------------------------------
		// Verifica se o território forçado é um dos avaliados.  
		//-------------------------------------------------------------------
		nTerritory := aScan( Self:aTerritory, {|x| x[ID] == cTerritory} )	

		//-------------------------------------------------------------------
		// Força o melhor território.  
		//-------------------------------------------------------------------
		If ( Empty( nTerritory ) )
			Self:aTerritory := { { cTerritory, nScore, nFidelity, cType, cMember, { { cGroup, cLevel, nScore, nFidelity, cTerritory } } } }
		Else
			aTerritory := aClone( Self:aTerritory[nTerritory] )
			
			If ( !Empty( cType ) .And. !Empty( cMember ) )
				aTerritory[TYPE] 		:= cType
				aTerritory[MEMBER]	:= cMember					
			EndIf
			
			Self:aTerritory := { aTerritory }
		EndIf 
	EndIf 
Return Self:lForced

//-------------------------------------------------------------------
/*/{Protheus.doc} IsAvailable
Identifica se um território pode ser utilizado.  

@param cTerritory, caracter, Código do território.
@return lAvailable, lógico, Indica se o território está disponível. 

@author  Valdiney V GOMES 
@version P12
@since   07/07/2015  
/*/
//-------------------------------------------------------------------
Method IsAvailable( cTerritory ) Class CRMTerritory
	Local lAvailable := .F. 
	
	Default cTerritory := ""
	
	//-------------------------------------------------------------------
	// Localiza o território.  
	//-------------------------------------------------------------------
	AOY->( DBSetOrder( 1 ) )

	If ( AOY->( DBSeek( xFilial("AOY") + cTerritory ) ) )				
		//-------------------------------------------------------------------
		// Verifica se o território está bloqueado.  
		//-------------------------------------------------------------------
		lAvailable :=  ! ( AOY->AOY_MSBLQL == "1" ) 

		//-------------------------------------------------------------------
		// Verifica se o território está expirado.  
		//-------------------------------------------------------------------		
		If ( lAvailable )
			lAvailable := ( AOY->AOY_DTINIC <= Self:GetBaseDate() ) .And. ( AOY->AOY_DTFIM >= Self:GetBaseDate() .Or. Empty( AOY->AOY_DTFIM ) )
		EndIf
		
		//-------------------------------------------------------------------
		// Verifica se há restrição por tipo de território.  
		//-------------------------------------------------------------------		
		If ( lAvailable )
			If ! ( Empty( Self:cFilter ) )
				lAvailable := ( AOY->AOY_TIPO == Self:cFilter ) .Or. (  Self:cFilter == "1" .And. Empty( AOY->AOY_TIPO ) )
			EndIf 
		EndIf
	EndIf 
Return lAvailable

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadException
Retorna os territórios e exceção avaliadas para um processo. 

@param aMatch, array, Relação de agrupadares avaliados e níveis encontrados	no formato {{AGRUPADOR, NÍVEL}, ...}. 
@return aException, array, Relação de exceção no formato {{TERRITÓRIO, PONTOS, FIDELIDADE, TIPO_MEMBRO, MEMBRO {{AGRUPADOR, NÍVEL, PONTOS, FIDELIDADE, TERRITÓRIO}}}, ...}.

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method LoadException( aMatch ) Class CRMTerritory
	Local aArea			:= GetArea()
	Local nMatch 		:= 0
	Local nScore		:= 0
	Local nException	:= 0
	Local nFidelity		:= 0
	Local lFound		:= .F. 
	Local cQuery 		:= ""
	Local cGroup		:= ""
	Local cAliasTmp		:= GetNextAlias()
	Local cFilA02		:= xFilial("A02")
	Local cFilA01		:= xFilial("A01")
	
	Default aMatch		:= {}

	Self:aException := {}
	
	//-------------------------------------------------------------------
	// Percorre todos os níveis avaliados dos agrupadores.  
	//-------------------------------------------------------------------
	For nMatch := 1 To Len( aMatch )
	
		cGroup := aMatch[nMatch][GROUP]
		
		//--------------------------------------------------------
		// Localiza os níveis dos agrupadores dos territórios.  
		//--------------------------------------------------------
		cQuery := " SELECT A01_PONTOS, A01_MSBLQL, A02_CODAGR, A02_CODTER, A02_NIVAGR, A02_IDINT, A02_TPMBRO, A02_CODMBR, A02_MSBLQL "
		cQuery += " FROM " + RetSqlName( "A01" ) + " A01 "
		cQuery += " INNER JOIN "
		cQuery += " ( SELECT A02_CODAGR, A02_CODTER, A02_NIVAGR, A02_IDINT, A02_TPMBRO, A02_CODMBR, A02_MSBLQL 
		cQuery += " FROM " + RetSqlName( "A02" )
		cQuery += " WHERE A02_FILIAL = '" + cFilA02 + "' "
		cQuery += " AND A02_IDINT LIKE '" + Left( aMatch[nMatch][SMARTID], Len( AllTrim( aMatch[nMatch][SMARTID]) ) - 2 ) + "%'" 
		cQuery += " AND A02_CODAGR = '" + cGroup + "' "
		cQuery += " AND ( A02_MSBLQL = ' ' OR A02_MSBLQL = '2' ) "
		cQuery += " AND D_E_L_E_T_ = ' ' ) "
		cQuery += " A02 ON "
		cQuery += " A01.A01_CODAGR = A02.A02_CODAGR "
		cQuery += " WHERE A01.A01_FILIAL = '" + cFilA01 + "' "
		cQuery += " AND ( A01.A01_MSBLQL = ' ' OR A01.A01_MSBLQL = '2' ) "
		cQuery += " AND A01.D_E_L_E_T_ = ' ' "
		
		//-------------------------------------------------------------------
		// Executa a instrução. 
		//-------------------------------------------------------------------		
		DBUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .T. )
		
		While ( (cAliasTmp)->( ! Eof() ) )
			
			//-------------------------------------------------------------------
			// Verifica se o nível é igual ao nível avaliado.  
			//-------------------------------------------------------------------
			nFidelity	:= 0
			lFound 	:= ( (cAliasTmp)->A02_NIVAGR == aMatch[nMatch][LEVEL] )	
									
			If ! ( lFound )
				//-------------------------------------------------------------------
				// Verifica se o nível avaliado é um filho do nível do agrupador.  
				//-------------------------------------------------------------------
				lFound := CRMA580IsChild( (cAliasTmp)->A02_IDINT, aMatch[nMatch][SMARTID], @nFidelity )
			EndIf 						
																
			If ( lFound )
				//-------------------------------------------------------------------
				// Localiza a pontuação da exceção.  
				//-------------------------------------------------------------------	
				If ! ( Empty( (cAliasTmp)->A01_PONTOS ) )
					nScore := (cAliasTmp)->A01_PONTOS
				Else
					nScore := 1
				EndIf 	
	
				//-------------------------------------------------------------------
				// Localiza a exceção.  
				//-------------------------------------------------------------------
				nException 	:= aScan( Self:aException, {|x| x[ID] == (cAliasTmp)->A02_CODTER } )		
			
				If ( Empty( nException ) )
					//-------------------------------------------------------------------
					// Verifica se o território está disponível.  
					//-------------------------------------------------------------------
					If ( Self:IsAvailable( (cAliasTmp)->A02_CODTER ) )
						//-------------------------------------------------------------------
						// Insere um novo território como exceção.  
						//-------------------------------------------------------------------		
						aAdd( Self:aException, { (cAliasTmp)->A02_CODTER, nScore, nFidelity, (cAliasTmp)->A02_TPMBRO, (cAliasTmp)->A02_CODMBR, { { aMatch[nMatch][GROUP], aMatch[nMatch][LEVEL], nScore, nFidelity, (cAliasTmp)->A02_CODTER } } } )
					EndIf 
				Else
					//-------------------------------------------------------------------
					// Atualiza uma exceção.  
					//-------------------------------------------------------------------	
					Self:aException[nException][SCORE]		+= nScore
					Self:aException[nException][FIDELITY]	+= nFidelity		
			
					aAdd( Self:aException[nException][REACH], { aMatch[nMatch][GROUP], aMatch[nMatch][LEVEL], nScore, nFidelity, (cAliasTmp)->A02_CODTER } ) 
				EndIf 							
								
			EndIf
			
			(cAliasTmp)->( DBSkip() )
			
		EndDo
		
		(cAliasTmp)->( DBCloseArea() )
			
	Next nMatch
	
	//-------------------------------------------------------------------
	// Ordena as exceção por pontuação e especificidade.  
	//-------------------------------------------------------------------
	If ! ( Empty( Self:aException ) )
		aSort( Self:aException,,,{ |x,y| x[SCORE] > y[SCORE] } )
	EndIf 
	RestArea(aArea)	
Return Self:aException

//-------------------------------------------------------------------
/*/{Protheus.doc} GetException
Retorna os territórios e exceção avaliadas para um processo. 

@return aException, array, Relação de exceção no formato {{TERRITÓRIO, PONTOS, FIDELIDADE, TIPO_MEMBRO, MEMBRO {{AGRUPADOR, NÍVEL, PONTOS, FIDELIDADE, TERRITÓRIO}}}, ...}.

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method GetException( aMatch ) Class CRMTerritory
Return Self:aException

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCommon
Retorna os territórios e exceções avaliadas para um processo. 

@param aMatch, array, Relação de agrupadares avaliados e níveis encontrados	no formato {{AGRUPADOR, NÍVEL}, ...}. 	
@return aTerritory, array, Lista contendo os território que pontuaram no formato {{TERRITÓRIO, PONTOS, FIDELIDADE, TIPO_MEMBRO, MEMBRO {{AGRUPADOR, NÍVEL, PONTOS, FIDELIDADE, TERRITÓRIO}}}, ...}. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method LoadCommon( aMatch ) Class CRMTerritory
	Local aArea			:= GetArea()
	Local nMatch		:= 0
	Local nCommon		:= 0
	Local nScore		:= 0
	Local nFidelity		:= 0
	Local nX			:= 0 
	Local lFound		:= .F.
	Local cAliasTmp		:= GetNextAlias()
	Local cGroup		:= "" 
	Local cQuery		:= ""
	Local cBaseDate		:= DTos( Self:GetBaseDate() )
	Local cFilA00		:= xFilial("A00")
	Local cFilAOZ		:= xFilial("AOZ")	

	Default aMatch		:= {}
	
	Self:aCommon := {}
	
	//-------------------------------------------------------------------
	// Percorre todos os níveis dos agrupadores avaliados.
	//-------------------------------------------------------------------
	For nMatch := 1 To Len( aMatch )
		
		cGroup := aMatch[nMatch][GROUP]
	
		//--------------------------------------------------------
		// Localiza os níveis dos agrupadores dos territórios.  
		//--------------------------------------------------------
		cQuery := " SELECT A00_FILIAL, A00_CODTER, A00_CODAGR, A00_NIVAGR, A00_OPER, A00_PONTOS, A00_IDINT "  
		cQuery += " FROM " + RetSqlName( "AOZ" ) + " AOZ "
		cQuery += " INNER JOIN "
		cQuery += " ( SELECT A00_FILIAL, A00_CODTER, A00_CODAGR, A00_NIVAGR, A00_OPER, A00_PONTOS, A00_IDINT "
		cQuery += " FROM " + RetSqlName( "A00" )
		cQuery += " WHERE A00_FILIAL = '" + cFilA00 + "' "	
		cQuery += " AND A00_CODAGR = '" + cGroup + "' "
		cQuery += " AND ( A00_MSBLQL = ' ' OR A00_MSBLQL = '2' ) "
		cQuery += " AND ( ( A00_DTINIC <= '" + cBaseDate + "' AND A00_DTFIM >= '" + cBaseDate + "' ) OR A00_DTFIM = ' ' ) "
		cQuery += " AND A00_IDINT LIKE '" + Left( aMatch[nMatch][SMARTID], Len( AllTrim( aMatch[nMatch][SMARTID]) ) - 2 ) + "%'" 
		cQuery += " AND D_E_L_E_T_ = ' ' ) "
		cQuery += " A00 ON "
		cQuery += " A00.A00_CODTER = AOZ.AOZ_CODTER "
		cQuery += " AND A00.A00_CODAGR = AOZ.AOZ_CODAGR "
		cQuery += " WHERE	AOZ.AOZ_FILIAL = '" + cFilAOZ + "' "
		cQuery += " AND ( AOZ.AOZ_MSBLQL = ' ' OR AOZ.AOZ_MSBLQL = '2' )
		cQuery += " AND ( ( AOZ.AOZ_DTINIC <= '" + cBaseDate + "' AND AOZ.AOZ_DTFIM >= '" + cBaseDate + "' ) OR AOZ.AOZ_DTFIM = ' ' ) "
		cQuery += " AND AOZ.D_E_L_E_T_ = ' ' " 
	
		//-------------------------------------------------------------------
		// Executa a instrução. 
		//-------------------------------------------------------------------		
		DBUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .T. )
							
		While ( (cAliasTmp)->( ! Eof() ) )
			
			nFidelity	:= 0
			lFound 	:= ( (cAliasTmp)->A00_NIVAGR == aMatch[nMatch][LEVEL] )	
									
			If ! ( lFound )
				//-------------------------------------------------------------------
				// Verifica se o nível avaliado é um filho do nível do agrupador.  
				//-------------------------------------------------------------------
				lFound := CRMA580IsChild( (cAliasTmp)->A00_IDINT, aMatch[nMatch][SMARTID], @nFidelity )
			EndIf 
			
			If ( lFound )
				//-------------------------------------------------------------------
				// Localiza a pontuação do território.  
				//-------------------------------------------------------------------	
				If ( (cAliasTmp)->A00_OPER == "2" )
					nScore := ( (cAliasTmp)->A00_PONTOS * -1 )
				Else
					nScore := (cAliasTmp)->A00_PONTOS
				EndIf 

				//-------------------------------------------------------------------
				// Localiza o território.  
				//-------------------------------------------------------------------
				nCommon := aScan( Self:aCommon, {|x| x[ID] == (cAliasTmp)->A00_CODTER } )	
				
				If ( Empty( nCommon ) )	
					//-------------------------------------------------------------------
					// Verifica se o território está disponível.  
					//-------------------------------------------------------------------
					If ( Self:IsAvailable( (cAliasTmp)->A00_CODTER ) )
						//-------------------------------------------------------------------
						// Insere um território.  
						//-------------------------------------------------------------------
						aAdd( Self:aCommon, { (cAliasTmp)->A00_CODTER, nScore, nFidelity, "", "", { { (cAliasTmp)->A00_CODAGR, (cAliasTmp)->A00_NIVAGR, nScore, nFidelity, (cAliasTmp)->A00_CODTER } } } )
					EndIf 
				Else
					//-------------------------------------------------------------------
					// Atualiza o território.  
					//-------------------------------------------------------------------
					Self:aCommon[nCommon][SCORE]	+= nScore
					Self:aCommon[nCommon][FIDELITY]	+= nFidelity
					
					aAdd( Self:aCommon[nCommon][REACH], { (cAliasTmp)->A00_CODAGR, (cAliasTmp)->A00_NIVAGR, nScore, nFidelity, (cAliasTmp)->A00_CODTER } ) 
				EndIf 
			EndIf 			
			
			(cAliasTmp)->( DBSkip() )
			
		EndDo
		
		(cAliasTmp)->( DBCloseArea() )
	
	Next nMatch
	
	//-------------------------------------------------------------------
	// Ordena os territórios por pontuação e fidelidade.  
	//-------------------------------------------------------------------
	If ! ( Empty( Self:aCommon ) ) 
		aSort( Self:aCommon,,,{ |x,y| x[SCORE] > y[SCORE] } )
	EndIf
	RestArea(aArea)	
Return Self:aCommon

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCommon
Retorna os territórios e exceção avaliadas para um processo. 

@return aTerritory, array, Lista contendo os território que pontuaram no formato {{TERRITÓRIO, PONTOS, FIDELIDADE, TIPO_MEMBRO, MEMBRO {{AGRUPADOR, NÍVEL, PONTOS, FIDELIDADE, TERRITÓRIO}}}, ...}.

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method GetCommon() Class CRMTerritory
Return Self:aCommon

//-------------------------------------------------------------------
/*/{Protheus.doc} SetError
Inclui uma mensagem de erro no processo de avaliação de território. 

@param cID, caracter, Identificador do processo.
@param cMessage, caracter,  Mensagem de erro. 
@return aError, array, Lista de erros no formato {{ID, MENSAGEM}, ...}

@author  Valdiney V GOMES 
@version P12
@since   02/07/2015  
/*/
//-------------------------------------------------------------------
Method SetError( cID, cMessage ) Class CRMTerritory	
	Default cID			:= ""
	Default cMessage	:= ""
	
	aAdd( Self:aError, { cID, cMessage } )
Return Self:aError

//-------------------------------------------------------------------
/*/{Protheus.doc} GetError
Retorna as mensagem de erro no processo de avaliação de território. 

@return aError, array, Lista de erros no formato {{ID, MENSAGEM}, ...}

@author  Valdiney V GOMES 
@version P12
@since   02/07/2015   
/*/
//-------------------------------------------------------------------
Method GetError() Class CRMTerritory		
Return Self:aError

//-------------------------------------------------------------------
/*/{Protheus.doc} SetProperty
Retorna a propriedade definida ao processo/rotina. 

@param cProperty, caracter, Processo/Rotina avaliada
@param cValue, caracter, Valor que define se haverá execução.
@return aProperty, Rotina avaliada e valor de execução.

@author  Thamara Villa
@version P12
@since   28/08/2015 
/*/
//-------------------------------------------------------------------
Method SetProperty( cProperty, cValue ) Class CRMTerritory
	Default cProperty	:= ""
	Default cValue 		:= ""
	
	aAdd( Self:aProperty, { AllTrim( cProperty ), AllTrim( cValue ) } )
Return Self:aProperty 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetProperty
Retorna a propriedade definida ao processo/rotina. 

@param cProperty, caracter, Processo/Rotina avaliada
@param cType, caracter, Tipo do dado informado
@param cValue, caracter, Valor default da propriedade caso set não foi passado.
@return xBIConvTo, Função que converte o dado a partir do tipo informado. 

@author  Thamara Villa
@version P12
@since   28/08/2015 
/*/
//-------------------------------------------------------------------
Method GetProperty( cProperty, cType, uDefVal ) Class CRMTerritory
	Local nPos 		:= 0
	Local uValue	:= Nil
	
	Default cProperty 	:= ""
	Default cType		:= "L"
	Default uDefVal		:= .T. 
		
	If !Empty( cProperty ) 
		nPos := aScan( Self:aProperty, {|x| x[1] == AllTrim( cProperty ) } )
		If nPos > 0
			uValue := Self:aProperty[nPos][2]
		Else
			uValue := uDefVal 
		EndIf
	EndIf
Return xBIConvTo( cType, uValue )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLog
Retorna o log completo da avaliação do território. 

@param [lFinal], lógico, Identifica se é o log final do processo. 
@return cLog, caracter, log do processo de avaliação do território. 

@author  Valdiney V GOMES 
@version P12
@since   23/06/2015  
/*/
//-------------------------------------------------------------------
Method GetLog( lFinal ) Class CRMTerritory	
	Local aQueue 		:= {}
	Local aMatch		:= {}
	Local aException 	:= {}
	Local aCommon 		:= {}
	Local aTerritory	:= {}
	Local aError		:= {}	
	Local cLog			:= ""
	Local cLine			:= Replicate( "-", 80 )
	Local nQueue		:= 0
	Local nMatch		:= 0
	Local nException	:= 0
	Local nCommon		:= 0
	Local nReach		:= 0
	Local nError		:= 0
	Local nStatus		:= ""	
	
	Default lFinal 		:= .T. 

	//-------------------------------------------------------------------
	// Recupera os erros encontrados na avaliação.  
	//-------------------------------------------------------------------
	aError	:= Self:GetError()

	//-------------------------------------------------------------------
	// Recupera o sequenciador do território.  
	//-------------------------------------------------------------------	
	aQueue 	:= Self:GetQueue()

	//-------------------------------------------------------------------
	// Monta o cabeçalho para o território.  
	//-------------------------------------------------------------------
	cLog += cLine + CRLF
	cLog += STR0013 + CRLF //Território
	cLog += cLine + CRLF
	cLog +=	Padr( STR0014, 10 ) //Processo
	cLog += "|" 
	cLog +=	Padr( STR0015, 10 ) //Entidade
	cLog += "|" 
	cLog +=	Padr( STR0016, 30 ) //Avaliação	
	cLog += CRLF
	cLog += cLine + CRLF
	
	//-------------------------------------------------------------------
	// Loga as informações do território.  
	//-------------------------------------------------------------------	
	cLog +=	Padr( Self:GetProcess(), 10 )
	cLog += "|" 
	cLog +=	Padr( Self:GetEntity(), 10 )
	cLog += "|" 
	cLog +=	Padr( DToC( Date() ) + " " + Time() , 30 )
	cLog += CRLF

	If ! ( Empty( aQueue ) )
		//-------------------------------------------------------------------
		// Monta o cabeçalho para o sequenciador. 
		//-------------------------------------------------------------------
		cLog += cLine + CRLF
		cLog += STR0017 + CRLF //"Agrupadores"
		cLog += cLine + CRLF
		cLog += Padr( STR0018, 10 ) //"Agrupador"
		cLog += "|" 
		cLog += Padr( STR0007, 30 ) //"Descrição"
		cLog += CRLF
		cLog += cLine + CRLF
		
		//-------------------------------------------------------------------
		// Loga cada agrupador do sequenciador.  
		//-------------------------------------------------------------------
		For nQueue := 1 To Len ( aQueue )
			cLog += Padr( aQueue[nQueue], 10 )
			cLog += "|" 
			cLog += Padr( AllTrim( Posicione( "AOL", 1, xFilial( "AOL" ) + aQueue[nQueue], "AOL_RESUMO" ) ), 30 )
			cLog += CRLF	
		Next nQueue 	

		//-------------------------------------------------------------------
		// Recupera os agrupadores que foram foram atendidos.  
		//-------------------------------------------------------------------			
		aMatch 	:= Self:GetMatch()	

		If ! ( Empty( aMatch ) )	
			//-------------------------------------------------------------------
			// Monta o cabeçalho para os níveis encontrados.  
			//-------------------------------------------------------------------	
			cLog += cLine + CRLF
			cLog += STR0019 + CRLF //"Níveis"
			cLog += cLine + CRLF
			cLog += Padr( STR0018, 10 ) //"Agrupador" 
			cLog += "|" 
			cLog += Padr( STR0007, 30 ) //"Descrição"
			cLog += "|" 
			cLog += Padr( STR0020, 10 ) //"Nível"
			cLog += "|" 
			cLog += Padr( STR0007, 30 ) //"Descrição"
			cLog += CRLF
			cLog += cLine + CRLF			

			//-------------------------------------------------------------------
			// Loga cada nível que foi encontrado.  
			//-------------------------------------------------------------------	
			For nMatch := 1 To Len ( aMatch )
				cLog += Padr( aMatch[nMatch][1], 10 )
				cLog += "|" 
				
				If ! Empty( aMatch[nMatch][1] )
					cLog += Padr( AllTrim( Posicione( "AOL", 1, xFilial( "AOL" ) + aMatch[nMatch][1], "AOL_RESUMO" ) ), 30 )
				Else
					cLog += Padr( STR0021, 30 ) //"Indefinido"
				EndIf 
				
				cLog += "|" 
				cLog += Padr( aMatch[nMatch][2], 10 )
				cLog += "|" 
				cLog += Padr( aMatch[nMatch][4], 30 )
				cLog += CRLF
			Next nMatch 	
		
			//-------------------------------------------------------------------
			// Recupera as exceção.  
			//-------------------------------------------------------------------		
			aException 	:= Self:GetException()	

			If ! ( Empty( aException ) )	
				//-------------------------------------------------------------------
				// Monta o cabeçalho para as exceção.  
				//-------------------------------------------------------------------
				cLog += cLine + CRLF
				cLog += STR0022 + CRLF //"Exceção"
				cLog += cLine + CRLF	
				cLog += Padr( STR0013, 10 ) //"Território"
				cLog += "|" 
				cLog += Padr( STR0007, 30 ) //"Descrição" 
				cLog += "|" 
				cLog += Padr( STR0023, 10 ) //"Pontos"
				cLog += "|" 
				cLog += Padr( STR0024, 10 ) //"Fidelidade"
				cLog += "|" 
				cLog += Padr( STR0031, 5 ) //"Tipo"
				cLog += "|" 
				cLog += Padr( STR0034, 10 ) //"Membro"
				cLog += CRLF
				cLog += cLine + CRLF		

				//-------------------------------------------------------------------
				// Loga cada exceção encontrada encontrado.  
				//-------------------------------------------------------------------	
				For nException := 1 To Len( aException )			
					cLog += Padr( aException[nException][ID], 10 )
					cLog += "|" 
					cLog += Padr( Posicione( "AOY", 1, xFilial( "AOY" ) + aException[nException][1], "AOY_NMTER" ), 30 )
					cLog += "|" 
					cLog += Padr( cBIStr( aException[nException][SCORE] ), 10 )
					cLog += "|" 
					cLog += Padr( cBIStr( aException[nException][FIDELITY] ), 10 )
					cLog += "|" 
					cLog += Padr( cBIStr( aException[nException][TYPE] ), 5 )
					cLog += "|" 
					cLog += Padr( cBIStr( aException[nException][MEMBER] ), 10 )
					cLog += CRLF

					If ! ( Empty( aException[nException][REACH] ) )
						For nReach := 1 To Len( aException[nException][REACH] )
							cLog += cLine + CRLF
							
							If ( aException[nException][ID] == aException[nException][REACH][nReach][5] )
								cLog += Padr( "*", 20 ) 
							Else
								cLog += Padr( "* (" + aException[nException][REACH][nReach][5] + ")", 20 ) 
							EndIf 

							cLog += Padr( aException[nException][REACH][nReach][1], 10 )
							cLog += "|" 
							cLog += Padr( aException[nException][REACH][nReach][2], 10 )
							cLog += "|" 
							cLog += Padr( aException[nException][REACH][nReach][3], 10 )	
							cLog += "|" 
							cLog += Padr( aException[nException][REACH][nReach][4], 10 )			
							cLog += CRLF + CRLF
						Next nReach
					EndIf 
				Next nException 	
			Else
				//-------------------------------------------------------------------
				// Recupera as comuns.  
				//-------------------------------------------------------------------		
				aCommon := Self:GetCommon()		
	
				If ! ( Empty( aCommon ) )
					//-------------------------------------------------------------------
					// Monta o cabeçalho para os comuns.  
					//-------------------------------------------------------------------
					cLog += cLine + CRLF
					cLog += STR0013 + CRLF //"Território"
					cLog += cLine + CRLF			
					cLog += Padr( STR0013, 10 ) //"Território"
					cLog += "|" 
					cLog += Padr( STR0007, 30 ) //"Descrição"
					cLog += "|" 
					cLog += Padr( STR0023, 10 ) //"Pontos"
					cLog += "|" 
					cLog += Padr( STR0024, 10 ) //"Fidelidade"
					cLog += "|" 
					cLog += Padr( STR0031, 5 ) //"Tipo"
					cLog += "|" 
					cLog += Padr( STR0034, 10 ) //"Membro"
					cLog += CRLF
					cLog += cLine + CRLF
						
					//-------------------------------------------------------------------
					// Loga cada comum encontrado.  
					//-------------------------------------------------------------------	
					For nCommon := 1 To Len( aCommon )
						cLog += Padr( aCommon[nCommon][ID], 10 )
						cLog += "|" 
						cLog += Padr( Posicione( "AOY", 1, xFilial( "AOY" ) + aCommon[nCommon][1], "AOY_NMTER" ), 30 )
						cLog += "|" 
						cLog += Padr( cBIStr( aCommon[nCommon][SCORE] ), 10 )
						cLog += "|" 
						cLog += Padr( cBIStr( aCommon[nCommon][FIDELITY] ), 10 )
						cLog += "|" 
						cLog += Padr( cBIStr( aCommon[nCommon][TYPE] ), 5 )
						cLog += "|" 
						cLog += Padr( cBIStr( aCommon[nCommon][MEMBER] ), 10 )
						cLog += CRLF
	
						If ! ( Empty( aCommon[nCommon][REACH] ) )
							For nReach := 1 To Len( aCommon[nCommon][REACH] )
								cLog += cLine + CRLF

								If ( aCommon[nCommon][ID] == aCommon[nCommon][REACH][nReach][5] )
									cLog += Padr( "*", 20 ) 
								Else
									cLog += Padr( "* (" + aCommon[nCommon][REACH][nReach][5] + ")", 20 ) 
								EndIf 

								cLog += Padr( aCommon[nCommon][REACH][nReach][1], 10 )
								cLog += "|" 
								cLog += Padr( aCommon[nCommon][REACH][nReach][2], 10 )
								cLog += "|" 
								cLog += Padr( aCommon[nCommon][REACH][nReach][3], 10 )	
								cLog += "|" 
								cLog += Padr( aCommon[nCommon][REACH][nReach][4], 10 )			
								cLog += CRLF + CRLF
							Next nReach
						EndIf 
					Next nCommon
				EndIf 
			EndIf
			
			If ( lFinal ) 
				If ( Empty( Self:GetInfo( ID ) ) )
					//-------------------------------------------------------------------
					// Loga os erros encontrados na avaliação.  
					//-------------------------------------------------------------------
					For nError := 1 To Len( aError )
						cLog += cLine 	+ CRLF
						cLog += aError[nError][2] + CRLF
					Next 	
					
					cLog += cLine 	+ CRLF
				Else
					//-------------------------------------------------------------------
					// Monta o cabeçalho para o território.  
					//-------------------------------------------------------------------	
					cLog += cLine + CRLF
					cLog += STR0025 + CRLF //"Melhor território"
					cLog += cLine + CRLF			
					cLog += Padr( STR0013, 10 ) //"Território"
					cLog += "|" 
					cLog += Padr( STR0007, 30 ) //"Descrição"
					cLog += "|" 
					cLog += Padr( STR0023, 10 ) //"Pontos"
					cLog += "|" 
					cLog += Padr( STR0024, 10 ) //"Fidelidade"
					cLog += "|" 
					cLog += Padr( STR0031, 5 ) //"Tipo"
					cLog += "|" 
					cLog += Padr( STR0034, 10 ) //"Membro"
					cLog += CRLF
					cLog += cLine + CRLF
					
					//-------------------------------------------------------------------
					// Loga o território.  
					//-------------------------------------------------------------------		
					cLog += Padr( Self:GetInfo( ID ), 10 )
					cLog += "|"
					cLog += Padr( Posicione( "AOY", 1, xFilial( "AOY" ) + Self:GetInfo( ID ), "AOY_NMTER" ), 30 )
					cLog += "|" 
					cLog += Padr( Self:GetInfo( SCORE ), 10 )
					cLog += "|"
					cLog += Padr( Self:GetInfo( FIDELITY ), 10 )
					cLog += "|" 
					cLog += Padr( Self:GetInfo( TYPE ), 5 ) 
					cLog += "|" 
					cLog += Padr( Self:GetInfo( MEMBER ), 10 ) 
					cLog += CRLF
					
					If ! ( Empty( Self:GetInfo( REACH ) ) )
						For nReach := 1 To Len( Self:GetInfo( REACH ) )
							cLog += cLine + CRLF
	
							If ( Self:GetInfo( ID ) == Self:GetInfo( REACH )[nReach][5] )
								cLog += Padr( "*", 20 ) 
							Else
								cLog += Padr( "* (" + Self:GetInfo( REACH )[nReach][5] + ")", 20 ) 
							EndIf 	
	
							cLog += Padr( Self:GetInfo( REACH )[nReach][1], 10 )
							cLog += "|" 
							cLog += Padr( Self:GetInfo( REACH )[nReach][2], 10 )
							cLog += "|" 
							cLog += Padr( Self:GetInfo( REACH )[nReach][3], 10 )	
							cLog += "|" 
							cLog += Padr( Self:GetInfo( REACH )[nReach][4], 10 )					
							cLog += CRLF + CRLF
						Next nReach
					EndIf 			
				
					//-------------------------------------------------------------------
					// Verifica se a seleção do território foi forçada.  
					//-------------------------------------------------------------------	
					If ( Self:lForced )
						cLog += cLine + CRLF
						cLog += STR0026 + STR0027 //"Modo de seleção:"###"Forçado"
		
						If ! ( Empty( cUserName ) )
							cLog += " [" + cUserName + "]" 
						EndIf 
		
						cLog += CRLF
						cLog += cLine + CRLF
						cLog += CRLF
					EndIf
				EndIf
			EndIf 
		Else
			//-------------------------------------------------------------------
			// Loga os erros encontrados na avaliação.  
			//-------------------------------------------------------------------
			For nError := 1 To Len( aError )
				cLog += cLine 	+ CRLF
				cLog += aError[nError][2] + CRLF
			Next 	
			
			cLog += cLine 	
		EndIf 
	Else
		cLog += cLine + CRLF
		cLog += STR0033 + CRLF //"Nenhum sequenciador ou agrupador configurado"   
		cLog += cLine + CRLF	
	EndIf
	
	 cLog := Upper( cLog )  
Return cLog

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Libera a memória alocada para o objeto. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method Destroy( ) Class CRMTerritory	
	Self:cProcess		:= ""
	Self:cEntity		:= ""
	Self:cFilter		:= ""
	Self:aQueue			:= aSize( Self:aQueue, 0 )
	Self:aMatch			:= aSize( Self:aMatch, 0 )
	Self:aCommon		:= aSize( Self:aCommon, 0 )	
	Self:aException		:= aSize( Self:aException, 0 )
	Self:aTerritory		:= aSize( Self:aTerritory, 0 )
	Self:aError			:= aSize( Self:aError, 0 )
	Self:lForced		:= .F. 
	Self:lEvaluted		:= .F.

	oMapKey:Clean()		
Return 