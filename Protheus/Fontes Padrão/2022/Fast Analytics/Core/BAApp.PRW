#INCLUDE "BAAPP.CH"
#INCLUDE "BADEFINITION.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BALoadApps
Carrega todos os Apps disponiveis no RPO.

@author  Helio Leal
@since   28/02/2018
/*/
//-------------------------------------------------------------------
Function BALoadApps()
	Local aApp    	  := { }
	Local aSource 	  := { }
	Local aNewSource  := { }
	Local aAppControl := {}
	Local aFont		  := {}
	Local nSource 	  := 0
	Local nApp		  := 0
	Local nExecution  := 0
	Local cAppDesc	  := ""
	Local oObject 	  := Nil
	Local bError  	  := Nil

	bError := ErrorBlock( { | e | conout(I18n( "BALoadApps: (#1) (#2)", {STR0001, e:ErrorStack } )) } ) // "Erro ao ler modelo..."

	//----------------------------------------------
	// Recebe todos os Apps cadastrados do BA
	//----------------------------------------------
	GetFuncArray( "BA_*",, aSource )

	//----------------------------------------------
	// Recebe todos os Apps cadastrados pelos modulos
	//----------------------------------------------
	GetFuncArray( "BAY*",, aNewSource )
	
	BEGIN SEQUENCE
	  	//-------------------------------------------------------------------
		// Força a validacao dos Apps disponiveis para os fontes do padrao (BA)
		// e possiveis Apps adicionados\alterados pelos modulos
		//-------------------------------------------------------------------
		For nExecution := 1 to 2
			aFont := Iif(nExecution == 1, aSource, aNewSource) 
			
		  	//-------------------------------------------------------------------
			// Itera pelos Apps disponiveis 
			//-------------------------------------------------------------------
			For nSource := 1 To Len( aFont )
				//---------------------------------------------------------------
			 	// Instancia a classe informada.
			 	//---------------------------------------------------------------
				oObject := &( SubStr( aFont[nSource], 1, At(".", aFont[nSource] ) - 1 ) + "():Init()" )
				cAppDesc := Upper( Alltrim( oObject:cApp ) )
	
				//---------------------------------------------------------------
			 	// Avalia se o App possui outra versao
			 	//---------------------------------------------------------------
				If ( nApp := Ascan( aAppControl, {|x| x == cAppDesc }) ) == 0
				  	//-------------------------------------------------------------------
					// Verifica se retornou um objeto valido. 
					//-------------------------------------------------------------------
				  	If ( ValType( oObject ) == "O" )
						AAdd( aApp, oObject )

					  	//-------------------------------------------------------------------
						// Adiciona o App ao vetor de controle 
						//-------------------------------------------------------------------
						Aadd( aAppControl, Upper( Alltrim( cAppDesc ) ) )
				  		oObject := Nil
					EndIf
				Else
					//-------------------------------------------------------------------
					// Verifica se retornou um objeto valido. 
					//-------------------------------------------------------------------
				  	If ( ValType( oObject ) == "O" )
				  	  	//-------------------------------------------------------------------
						// Atribui a versao do modulo ao App 
						//-------------------------------------------------------------------
				  		aApp[nApp] := oObject
						oObject := Nil
					EndIf
				EndIf
			Next nSource
		Next
  	END SEQUENCE
  	ErrorBlock( bError )
Return aApp

//-------------------------------------------------------------------
/*/{Protheus.doc} BASelectApp
Permite que o usuario selecione as areas que deseja instalar.

@author  Helio Leal
@since   01/03/2018
/*/
//-------------------------------------------------------------------
Function BASelectApp( aCompany )
	Local aApp         := {}
	Local oLayer       := FWLayer():New()
	Local oDialog      := Nil
	Local oTop         := Nil
	Local oList        := Nil

	//-------------------------------------------------------------------
	// Lista Apps disponiveis.
	//-------------------------------------------------------------------
	aEval( BALoadApps(), {|oApp| AAdd(aApp, { .F., oApp }) } )

	//-------------------------------------------------------------------
	// Monta tela de selecao de apps.
	//-------------------------------------------------------------------
	DEFINE DIALOG oDialog TITLE "TOTVS Fast Analytics" FROM 050, 051 TO 400,400 PIXEL
		//-------------------------------------------------------------------
		// Monta as sessoes da tela. 
		//-------------------------------------------------------------------  
		oLayer:Init( oDialog )
		oLayer:addLine( "TOP", 80, .F.)
		oLayer:addCollumn( "TOP_ALL",100, .T. , "TOP")
		oLayer:addWindow( "TOP_ALL", "TOP_WINDOW", STR0002, 100, .F., .T.,, "TOP"    ) // "Selecione as areas desejadas" 

		oTop := oLayer:getWinPanel( "TOP_ALL", "TOP_WINDOW", "TOP" ) 

		//-------------------------------------------------------------------
		// Monta a lista de apps. 
		//-------------------------------------------------------------------  	
      	@ 000, 000 LISTBOX oList;
		 	FIELDS HEADER "", STR0003 ; // "Area"
		 	SIZE 160, 115 OF oTop PIXEL; 
		 	ON DBLCLICK (aApp[oList:nAt, 1] := !aApp[oList:nAt, 1], oList:Refresh(.f.)) 
			
			oList:SetArray( aApp )
			oList:bLine := {|| { If(aApp[oList:nAt, 1], LoadBitmap( GetResources(), "LBTIK" ), LoadBitmap( GetResources(), "LBNO" )), aApp[oList:nAt, 2]:cApp }}
		    oList:bHeaderClick := { |a, b| iif(b == 1 , BAMarkAll(aApp, b),), oList:Refresh() }

	ACTIVATE DIALOG oDialog CENTERED ON INIT EnchoiceBar( oDialog, { || iif( BAValidApps( aApp ), { BACallInstall( aApp, aCompany ), oDialog:End() } , MsgInfo( STR0004, STR0005 ) )  }, { || oDialog:End() }, .F., {},,,.F.,.F.,.F.,.T., .F. ) // #"Favor selecionar ao menos uma área para continuar." #"Atenção"
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BAMarkAll
Marca todos os apps (chamada no Header Click).

@author  Helio Leal
@since   01/03/2018
/*/
//-------------------------------------------------------------------
Static Function BAMarkAll(aLista, nPos)
	Local lMark := .F.
	
	aEval(aLista, {|x| iif(!x[nPos], lMark := .T.,)  })
	aEval(aLista, {|x, i| aLista[i, nPos] := lMark })
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} BAValidApps
Valida se alguma area foi selecionada.

@author  Helio Leal
@since   01/03/2018
/*/
//-------------------------------------------------------------------
Static Function BAValidApps( aApp )
Return ( ! aScan( aApp, {|x| x[1] == .T. } ) == 0 )

//-------------------------------------------------------------------
/*/{Protheus.doc} BACallInstall
Retira a primeira posicao do Array e chama a instalacao do Fast Analytics.
So passa para o array os apps que estiverem selecionados.

@author  Helio Leal
@since   01/03/2018
/*/
//-------------------------------------------------------------------
Static Function BACallInstall( aApp, aCompany )
	Local oInstaller := Nil
	Local aObjectApp := {}

	AEval( aApp, {|uApp| if(uApp[1], AAdd( aObjectApp, uApp[2] ), ) } )

	If BAGetFilialExec()
		oInstaller := BAFilInstaller():New()
	Else
		oInstaller := BAEmpInstaller():New()
	EndIf

	oInstaller:Install( aObjectApp, aCompany )
	oInstaller:Destroy()
	oInstaller := Nil
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppEntity
Carrega todos os fontes encontrados por app

@param, aApp, array, Apps selecionados.

@author  Andréia Lima
@since   01/03/2018
/*/
//-------------------------------------------------------------------
Function BAAppEntity( aApp )
	Local nApp        := 0
	Local nEntity     := 0	
	Local aListEntity := {}
	Local aEntity     := {}
	Local aAppEntity  := {}
	Local aSource     := {}
	Local aNewSource  := {}
    
    Default aApp := {}

	For nApp := 1 To Len( aApp )
	
		aSize( aListEntity, 0 )
		aSize( aEntity, 0 )
		
		AAdd( aListEntity, aApp[nApp]:ListEntities() )
		
		//-------------------------------------------------------------------
		// Pesquisa todas as entidades cadastradas para o App.
		//-------------------------------------------------------------------
		For nEntity := 1 To Len( aListEntity[1] ) 
			
			aSize( aSource, 0 )
			aSize( aNewSource, 0 )
				
			//------------------------------------------------------------------------
			// Recebe todas as entidades cadastradas do BA
			//------------------------------------------------------------------------
			GetFuncArray("BAX" + aListEntity[1][nEntity],, aSource)
			
			//------------------------------------------------------------------------
			// Recebe todas as entidades cadastradas pelos modulos
			//------------------------------------------------------------------------
			GetFuncArray("BAZ" + aListEntity[1][nEntity],, aNewSource)
			
			//------------------------------------------------------------------------
			// Valida se a entidade possui mais de uma versao, se isto ocorrer, a 
			// entidade que permanece é a do modulo, pois pode ter sido atualizada
			//------------------------------------------------------------------------
			If ! Empty( aSource )
				If !Empty( aNewSource )
					AAdd( aEntity, aNewSource[1] )
				Else
					AAdd( aEntity, aSource[1] )
				EndIf
			EndIf
		Next nEntity
		
		AAdd( aAppEntity, { aApp[nApp]:cApp, ACLONE( aEntity ) } )

	Next nApp	
    
Return aAppEntity


