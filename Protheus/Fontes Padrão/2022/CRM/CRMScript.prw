#INCLUDE "CRMSCRIPT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"

#DEFINE ITEM		1
#DEFINE DESC		2
#DEFINE ACTION		3
#DEFINE TYPE		4
#DEFINE STATUS		5

#DEFINE WAITING		1
#DEFINE FINISHED	2
#DEFINE ERROR		3

#DEFINE LOG_ID		1
#DEFINE LOG_MESSAGE	2
#DEFINE LOG_ERROR	3

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMScript
Classe responsável pela avaliação de scripts. 

@example	
	oScript:SetScript( "MATA030" )

	If ( oScript:EvalScript( 1 ) )
		...
	EndIf 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Class CRMScript
	Data cScript
	Data aScript
	Data aError
			
	Method New() CONSTRUCTOR	
	Method SetScript( cScript )
	Method GetScript()
	Method LoadScript() 
	Method GetItems()
	Method EvalScript( nType, xInjection )
	Method SetError( cID, cMessage, cError  )
	Method GetError()
	Method Destroy()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} new
Método construtor da classe. 

@return Self, objeto, Instância da classe CRMScript. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method New() Class CRMScript
	Self:cScript	:= ""
	Self:aScript	:= {}
	Self:aError		:= {}
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetScript
Define a rotina para a qual o script será avaliado. 

@param cScript, caracter, Rotina para o qual o script será avaliado. 
@return cScript, caracter, Rotina para o qual o script será avaliado. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method SetScript( cScript ) Class CRMScript
	Default cScript := ""

	Self:cScript := cScript
Return Self:cScript

//-------------------------------------------------------------------
/*/{Protheus.doc} GetScript
Retorna a rotina relacionada com o script. 

@return cScript Rotina relacionada ao script. 

@author  Valdiney V GOMES 
@version P12
@since   20/06/2015  
/*/
//-------------------------------------------------------------------
Method GetScript() Class CRMScript
Return Self:cScript

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadScript
Retorna o script cadastrado para uma rotina.

@return aScript, array, Itens do script no formato {{CODIGO, DESCRICAO, ACAO, TIPO, STATUS}, ...}.  

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method LoadScript() Class CRMScript	
	Local nLengh 	:= TamSX3("A05_ROTINA")[1]
	Local cFilA06	:= xFilial("A06") 

	Self:aScript := {}
	
	//-------------------------------------------------------------------
	// Localiza o script da rotina.  
	//-------------------------------------------------------------------
	A05->( DBSetOrder( 2 ) )
	
	If ( A05->( DBSeek( xFilial("A05") + PadR( Self:cScript, nLengh ) ) ) )
		//-------------------------------------------------------------------
		// Verifica se o script está bloqueado.  
		//-------------------------------------------------------------------
		If ! ( A05->A05_MSBLQL == "1" )
			//-------------------------------------------------------------------
			// Localiza os itens do script.  
			//-------------------------------------------------------------------
			A06->( DBSetOrder( 1 ) )
			
			If ( A06->( DBSeek( cFilA06 + A05->A05_CODSCR ) ) )
				While ( A06->( ! Eof() ) .And. cFilA06 == A06->A06_FILIAL .And. A06->A06_CODSCR == A05->A05_CODSCR )	
					//-------------------------------------------------------------------
					// Verifica se o item do script está bloqueado.  
					//-------------------------------------------------------------------	
					If ! ( A06->A06_MSBLQL == "1" ) 
						//-------------------------------------------------------------------
						// Verifica se foi informada uma ação para o item.  
						//-------------------------------------------------------------------	
						If ! ( Empty( A06->A06_ACAOUS ) )
							//-------------------------------------------------------------------
							// Insere um novo item no script.  
							//-------------------------------------------------------------------
							If ( aScan( Self:aScript, {|x| x[ITEM] == A06->A06_ORDEM } ) == 0 )		
								aAdd( Self:aScript, { A06->A06_ORDEM, A06->A06_DESC, AllTrim( A06->A06_ACAOUS ), A06->A06_TPPROC, WAITING } )
							EndIf 
						EndIf 
					EndIf 
		
					A06->( DBSkip() )
				EndDo
			EndIf
		EndIf 
	EndIf
Return Self:aScript

//-------------------------------------------------------------------
/*/{Protheus.doc} GetItems
Retorna os itens do script cadastrado para uma rotina com status de avaliação.

@return aScript, array, Itens do script no formato {{CODIGO, DESCRICAO, ACAO, TIPO, STATUS}, ...}.  

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method GetItems() Class CRMScript	
Return Self:aScript

//-------------------------------------------------------------------
/*/{Protheus.doc} EvalScript
Executa o script definido para um rotina.
 
@param nType, numérico, Indica o tipo de script a ser executado. 
@param xInjection, indefinido, Conteúdo que será injetado no script.
@param lInterface, lógico, Identifica se o resultado da avaliação do script será exibido ao usuário.  
@return lOk, lógico, Indica se o script foi executado com sucesso. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method EvalScript( nType, xInjection, lInterface ) Class CRMScript	
	Local oDialog		:= Nil 
	Local oBrowse		:= Nil 
	Local oColumn		:= Nil 
	Local oPnlDialog	:= Nil
	Local bEnd	  		:= Nil
	Local aScript		:= {}
	Local aItem 		:= {}
	Local nItem		:= 0
	Local lOk			:= .T.
	

	Default nType			:= 1
	Default xInjection	:= Nil
	Default lInterface	:= ! ( IsBlind() )  

	//-------------------------------------------------------------------
	// Recupera o script.  
	//-------------------------------------------------------------------
	aScript := Self:LoadScript()

	//-------------------------------------------------------------------
	// Recupera os itens do script. 
	//------------------------------------------------------------------- 
	For nItem := 1 To Len( aScript )
		If ( aScript[nItem][TYPE] == cBIStr( nType ) )
			aAdd( aItem, aScript[nItem] ) 
		EndIf 
	Next nItem

	If ! ( Empty( aItem ) )
		//-------------------------------------------------------------------
		// Executa os itens do script. 
		//-------------------------------------------------------------------  	 
		Processa( {|| lOk := CRMScript( Self, aItem, xInjection ) }, STR0001, STR0002 ) //"Aguarde..."###"Executando script de validação..."
	 
		If ( lInterface .And. nType == 1 ) 
			bEnd  := {|| oDialog:DeActivate() } 	
		
			//-------------------------------------------------------------------
			// Monta o janela de resultado.  
			//-------------------------------------------------------------------	
			oDialog := FWDialogModal():New()
			oDialog:SetBackground( .T. )
			oDialog:SetTitle( STR0003 ) //"Resultado da avaliação dos scripts..."
			oDialog:SetEscClose( .F. )
			oDialog:SetSize( 150, 300 ) 
			oDialog:EnableFormBar( .T. ) 
			oDialog:SetCloseButton( .F. )
			oDialog:CreateDialog() 			
			oDialog:CreateFormBar()
			oDialog:AddButton( STR0004, bEnd, STR0004, , .T., .F., .T., ) 		//"Fechar"
					  	  
			//-------------------------------------------------------------------
			// Recupera o container para o browse.  
			//-------------------------------------------------------------------		
			oPanel := oDialog:GetPanelMain()
				
			//-------------------------------------------------------------------
			// Monta o browse.  
			//-------------------------------------------------------------------					  	    	  
			DEFINE FWBROWSE oBrowse DATA ARRAY ARRAY aItem NO REPORT NO LOCATE NO CONFIG DOUBLECLICK {|| CRMLog( Self, aItem, oBrowse:At() ) } OF oPanel
				//-------------------------------------------------------------------
				// Monta a legenda no browse.  
				//-------------------------------------------------------------------	
				ADD LEGEND DATA {|| aItem[oBrowse:nAt][STATUS] == WAITING } 	COLOR "GRAY" 	TITLE STR0005 OF oBrowse //"Não executado"
				ADD LEGEND DATA {|| aItem[oBrowse:nAt][STATUS] == FINISHED } 	COLOR "GREEN" TITLE STR0006 OF oBrowse //"Executado"
				ADD LEGEND DATA {|| aItem[oBrowse:nAt][STATUS] == ERROR } 		COLOR "RED"  	TITLE STR0007 OF oBrowse //"Falhou"		
		
				//-------------------------------------------------------------------
				// Monta as colunas do browse.  
				//-------------------------------------------------------------------
				ADD COLUMN oColumn DATA {|| aItem[oBrowse:nAt][DESC] } TITLE STR0008 OF oBrowse //"Descrição"
			ACTIVATE FWBROWSE oBrowse   
			
			oDialog:Activate()
	    EndIf 
     EndIf 
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} SetError
Inclui uma mensagem de erro no processo de avaliação do script. 

@param cID, caracter, Identificador do processo.
@param cMessage, caracter,  Mensagem de erro.
@param cError, caracter,  Pilha de erro.
@return aError, array, Lista de erros no formato {{ID, MENSAGEM, ERRO}, ...}

@author  Valdiney V GOMES 
@version P12
@since   11/00/2015  
/*/
//-------------------------------------------------------------------
Method SetError( cID, cMessage, cError ) Class CRMScript	
	Default cID				:= ""
	Default cMessage		:= ""
	Default cError			:= ""
			
	aAdd( Self:aError, { cID, cMessage, cError } )
Return Self:aError

//-------------------------------------------------------------------
/*/{Protheus.doc} GetError
Retorna as mensagem de erro no processo de avaliação do script. 

@return aError, array, Lista de erros no formato {{ID, MENSAGEM}, ...}

@author  Valdiney V GOMES 
@version P12
@since   11/09/2015   
/*/
//-------------------------------------------------------------------
Method GetError() Class CRMScript		
Return Self:aError

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Libera a memória alocada para o objeto. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Method Destroy() Class CRMScript	
	Self:cScript	:= ""
	Self:aScript	:= aSize( Self:aScript, 0 )
	Self:aError		:= aSize( Self:aError, 0 )
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} Script
@protect
Executa o script definido para um rotina.

@param oScript, objeto, Objeto do script.  
@param oInjection, indefinido, Conteúdo a ser injetado no script.  
@return lOk, lógico, Indica se o script foi executado com sucesso. 

@author  Valdiney V GOMES 
@version P12
@since   15/05/2015  
/*/
//-------------------------------------------------------------------
Function CRMScript( oScript, aItem, xInjection )
	Local bError 		:= ErrorBlock( { | oError | lOk := CRMCatcher( oScript, oError, aItem, nItem ) } )
	Local bAction		:= Nil
	Local nItem			:= 0
	Local nStatus		:= WAITING
	Local lOk			:= .T.
	
	Default oScript		:= Nil
	Default xInjection	:= Nil
	Default aItem		:= {}
	
	//-------------------------------------------------------------------
	// Determina o tamanho da régua de processamento.
	//-------------------------------------------------------------------
	ProcRegua( Len( aItem ) )
	
	//-------------------------------------------------------------------
	// Percorre todos os itens do script.
	//-------------------------------------------------------------------
	For nItem := 1 To Len( aItem )
		//-------------------------------------------------------------------
		// Incrementa a régua de processamento.
		//-------------------------------------------------------------------
		IncProc( aItem[nItem][DESC] )
		
		BEGIN SEQUENCE
			//-------------------------------------------------------------------
			// Verifica se a ação do item é uma função.
			//-------------------------------------------------------------------
			lOk := ( FindFunction( aItem[nItem][ACTION] ) )
				
			//-------------------------------------------------------------------
			// Executa a ação do item.
			//-------------------------------------------------------------------
			If ( lOk )
				bAction := &( "{|x| " + aItem[nItem][ACTION] + "(x)}" )
				lOk 	:= Eval( bAction, { xInjection, oScript } )
			Else
				oScript:SetError( aItem[nItem][DESC], STR0013 ) //"A ação do item não é uma função!"
			EndIf
			
			//-------------------------------------------------------------------
			// Verifica o retorno da ação.
			//-------------------------------------------------------------------
			lOk		:= If ( ValType( lOk ) == "L", lOk, .F. )
			nStatus := If( lOk, FINISHED, ERROR )
			
			//-------------------------------------------------------------------
			// Atualiza o item com resultado da ação.
			//-------------------------------------------------------------------
			aItem[nItem][STATUS] := nStatus
		END SEQUENCE
		
		//-------------------------------------------------------------------
		// Finaliza a execução um item for finalizado sem sucesso.
		//-------------------------------------------------------------------
		If ! ( lOk )
			Help( ,, 'CRMScript',, STR0012, 1, 0 ) //"O processo não será finalizado."
			Exit
		EndIf
	Next nItem
	
	ErrorBlock( bError )
Return lOk


//-------------------------------------------------------------------
/*/{Protheus.doc} CRMCatcher
Captura as exceções ocorridas na execução de um script.

@param oScript, objeto, Objeto do script.
@param oError, objeto, Objeto da exceção. 
@param nItem, numérico, Item do script avaliado. 
@return .F., Sempre retorna falso quando um erro for capturado.

@author  Valdiney V GOMES 
@version P12
@since   15/09/2015  
/*/
//-------------------------------------------------------------------
Static Function CRMCatcher( oScript, oError, aItem, nItem ) 
	Local aScript 	:= {}

	Default oScript := Nil	
	Default oError	:= Nil
	Default aItem	:= {}
	Default nItem	:= 1

	If ! ( Empty( aItem ) )
		//-------------------------------------------------------------------
		// Altera o status do item para erro.   
		//-------------------------------------------------------------------
		aItem[nItem][STATUS] := ERROR 
	
		//-------------------------------------------------------------------
		// Identifica o erro no processo.  
		//-------------------------------------------------------------------
		oScript:SetError( aItem[nItem][DESC], oError:Description, oError:ErrorStack ) 
	EndIf  
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMLog
Exibe as mensagens de erro de um item do script.

@param oScript, objeto, Objeto do script. 
@param nItem, numérico, Item do script avaliado. 

@author  Valdiney V GOMES 
@version P12
@since   18/09/2015  
/*/
//-------------------------------------------------------------------
Static Function CRMLog( oScript, aItem, nItem ) 
	Local aScript 	:= {}
	Local aError	:= {}
	Local cError	:= ""
	Local nError	:= 0

	Default oScript := Nil	
	Default aItem	:= {}
	Default nItem	:= 1
	
	//-------------------------------------------------------------------
	// Verifica se o item está com o status de erro.   
	//-------------------------------------------------------------------
	If( aItem[nItem][STATUS] == ERROR )
		//-------------------------------------------------------------------
		// Recupera as mensagens de erro.   
		//-------------------------------------------------------------------
		aError := oScript:GetError()
	
		//-------------------------------------------------------------------
		// Formata as mensagens de erro.   
		//-------------------------------------------------------------------	
		If ( Empty( aError ) )
			cError += "[" + STR0009 + "] " + STR0011 //"Regra"###"O item do script não foi validado!"
		Else
			For nError := 1 To Len( aError )
				If ( Empty( aError[nError][LOG_ERROR] ) )
					cError += "[" + STR0009 + "] " + aError[nError][LOG_MESSAGE] + CRLF //"Regra"
				Else
					cError += "[" + STR0010 + "] " + aError[nError][LOG_ERROR] + CRLF //"Erro"
				EndIf
			Next nerror			
		EndIf 
		
		//-------------------------------------------------------------------
		// Exibe as mensagens de erro.   
		//-------------------------------------------------------------------
		CRMA950Viewer( cError )		
	EndIf 
Return