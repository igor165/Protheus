#INCLUDE "BCAPP.CH"
#INCLUDE "BCDEFINITION.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BCLoadApps
Carrega todos os  Apps dispon�veis no  RPO
@author  Andreia Lima

@since   22/04/2019
/*/
//-------------------------------------------------------------------
Function BCLoadApps()
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

	bError := ErrorBlock( { | e | conout(I18n( "BCLoadApps: (#1) (#2)", {STR0001, e:ErrorStack } )) } ) // "Erro ao ler modelo..."

	//----------------------------------------------
	// Recebe todos os Apps cadastrados de BA
	//----------------------------------------------
	GetFuncArray( "BC_*",, aSource )

	//----------------------------------------------
	// Recebe todos os Apps cadastrados pelos m�dulos
	//----------------------------------------------
	GetFuncArray( "BCY*",, aNewSource )
	
	BEGIN SEQUENCE
	  	//-------------------------------------------------------------------
		// For�a a valida��o dos Apps dispon�veis para os fontes do padr�o (BA)
		// e poss�veis Apps adicionados\alterados pelos m�dulos
		//-------------------------------------------------------------------
		For nExecution := 1 to 2
			aFont := Iif(nExecution == 1, aSource, aNewSource) 
			
		  	//-------------------------------------------------------------------
			// Itera pelos Apps dispon�veis 
			//-------------------------------------------------------------------
			For nSource := 1 To Len( aFont )
				//---------------------------------------------------------------
			 	// Instancia a classe informada.
			 	//---------------------------------------------------------------
				oObject := &( SubStr( aFont[nSource], 1, At(".", aFont[nSource] ) - 1 ) + "():Init()" )
				cAppDesc := Upper( Alltrim( oObject:cApp ) )
	
				//---------------------------------------------------------------
			 	// Avalia se o App possui outra vers�o
			 	//---------------------------------------------------------------
				If ( nApp := Ascan( aAppControl, {|x| x == cAppDesc }) ) == 0
				  	//-------------------------------------------------------------------
					// Verifica se retornou um objeto v�lido. 
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
					// Verifica se retornou um objeto v�lido. 
					//-------------------------------------------------------------------
				  	If ( ValType( oObject ) == "O" )
				  	  	//-------------------------------------------------------------------
						// Atribui a vers�o do m�dulo ao App 
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
/*/{Protheus.doc} BCSelectApp
Permite que o usu�rio selecione as �reas que deseja instalar.

@author  Andreia Lima
@since   22/04/2019
/*/
//-------------------------------------------------------------------
Function BCSelectApp( aCompany )
	Local aApp         := {}
	Local oLayer       := FWLayer():New()
	Local oDialog      := Nil
	Local oTop         := Nil
	Local oList        := Nil

	//-------------------------------------------------------------------
	// Lista Apps dispon�veis.
	//-------------------------------------------------------------------
	aEval( BCLoadApps(), {|oApp| AAdd(aApp, { .F., oApp }) } )

	//-------------------------------------------------------------------
	// Monta tela de sele��o de apps.
	//-------------------------------------------------------------------
	DEFINE DIALOG oDialog TITLE "TOTVS CAROL" FROM 050, 051 TO 350,400 PIXEL
		//-------------------------------------------------------------------
		// Monta as sess�es da tela. 
		//-------------------------------------------------------------------  
		oLayer:Init( oDialog )
		oLayer:addLine( "TOP", 80, .F.)
		oLayer:addCollumn( "TOP_ALL",100, .T. , "TOP")
		oLayer:addWindow( "TOP_ALL", "TOP_WINDOW", STR0002, 100, .F., .T.,, "TOP"    ) // "Selecione as �reas desejadas" 

		oTop := oLayer:getWinPanel( "TOP_ALL", "TOP_WINDOW", "TOP" ) 

		//-------------------------------------------------------------------
		// Monta a lista de apps. 
		//-------------------------------------------------------------------  	
      	@ 000, 000 LISTBOX oList;
		 	FIELDS HEADER "", STR0003 ; // "�rea"
		 	SIZE 160, 95 OF oTop PIXEL; 
		 	ON DBLCLICK (aApp[oList:nAt, 1] := !aApp[oList:nAt, 1], oList:Refresh(.f.)) 
			
			oList:SetArray( aApp )
			oList:bLine := {|| { If(aApp[oList:nAt, 1], LoadBitmap( GetResources(), "LBTIK" ), LoadBitmap( GetResources(), "LBNO" )), aApp[oList:nAt, 2]:cApp }}
		    oList:bHeaderClick := { |a, b| iif(b == 1 , BCMarkAll(aApp, b),), oList:Refresh() }

	ACTIVATE DIALOG oDialog CENTERED ON INIT EnchoiceBar( oDialog, { || iif( BCValidApps( aApp ), { BCCallInstall( aApp, aCompany ), oDialog:End() } , MsgInfo( STR0004, STR0005 ) )  }, { || oDialog:End() }, .F., {},,,.F.,.F.,.F.,.T., .F. ) // #"Favor selecionar ao menos uma �rea para continuar." #"Aten��o"
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BCMarkAll
Marca todos os apps (chamada no Header Click).

@author  Andreia Lima
@since   22/04/2019
/*/
//-------------------------------------------------------------------
Static Function BCMarkAll(aLista, nPos)
	Local lMark := .F.
	
	aEval(aLista, {|x| iif(!x[nPos], lMark := .T.,)  })
	aEval(aLista, {|x, i| aLista[i, nPos] := lMark })
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} BCValidApps
Valida se alguma �rea foi selecionada.

@author  Andreia Lima
@since   22/04/2019
/*/
//-------------------------------------------------------------------
Static Function BCValidApps( aApp )
Return ( ! aScan( aApp, {|x| x[1] == .T. } ) == 0 )

//-------------------------------------------------------------------
/*/{Protheus.doc} BCCallInstall
Retira a primeira posi��o do Array e chama a instala��o da Carol.
S� passa para o array os apps que estiverem selecionados.

@author  Andreia Lima
@since   22/04/2019
/*/
//-------------------------------------------------------------------
Static Function BCCallInstall( aApp, aCompany )
	Local oInstaller := Nil
	Local aObjectApp := {}

	AEval( aApp, {|uApp| if(uApp[1], AAdd( aObjectApp, uApp[2] ), ) } )

	oInstaller := BCEmpInstaller():New()

	oInstaller:Install( aObjectApp, aCompany )
	oInstaller:Destroy()
	oInstaller := Nil
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BCAppEntity
Carrega todos os fontes encontrados por app

@param, aApp, array, Apps selecionados.

@author  Andreia Lima
@since   22/04/2019
/*/
//-------------------------------------------------------------------
Function BCAppEntity( aApp )
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
			// Recebe todas as entidades cadastradas de BA
			//------------------------------------------------------------------------
			GetFuncArray("BCX" + aListEntity[1][nEntity],, aSource)
			
			//------------------------------------------------------------------------
			// Recebe todas as entidades cadastradas pelos m�dulos
			//------------------------------------------------------------------------
			GetFuncArray("BCZ" + aListEntity[1][nEntity],, aNewSource)
			
			//------------------------------------------------------------------------
			// Valida se a entidade possui mais de uma vers�o, se isto ocorrer, a 
			// entidade que permanece � a do m�dulo, pois pode ter sido atualizada
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
