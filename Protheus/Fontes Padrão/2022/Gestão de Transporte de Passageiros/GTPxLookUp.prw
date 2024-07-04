#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"

Static oTmpTable 
Static aStruTmp	:= {}

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPxLookUp
Classe para montagem de consultas 
@type Class
@author jacomo.fernandes
@since 03/07/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
CLASS GTPxLookUp FROM LongNameClass              
	DATA aInd           AS ARRAY
	DATA aIndices       AS ARRAY
	DATA aSeek          AS ARRAY   
	DATA aSize          AS ARRAY
	DATA aButtons       AS ARRAY
   	DATA aFieldRet      AS ARRAY 
   	DATA aReturn        AS ARRAY

	DATA bOk            AS CODEBLOCK
	DATA bCancel        AS CODEBLOCK
	
	DATA cAlias         AS CHARACTER
	DATA cQry           AS CHARACTER

	DATA lOk            AS LOGICAL
	DATA lPesq          AS LOGICAL

	DATA nX             AS NUMERIC
	
	DATA oDlg 			AS OBJECT
	DATA oButtonBar 	AS OBJECT
	DATA oPnlBrw		AS OBJECT
	DATA oBrowse		AS OBJECT
   	// DATA oTmpTable      AS OBJECT     
        
	METHOD New() 		CONSTRUCTOR  
	METHOD Execute()                     
	METHOD AddIndice( cName, cFields )
	METHOD AddButton( cName, cDesc, bAction )	         
	METHOD SetReturn()
	METHOD GetReturn()           
	METHOD GetPosLine()    
	METHOD Destroy()
ENDCLASS            

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor da classe
@type method
@author jacomo.fernades
@since 03/07/2019
@version 1.0
@param cQry, character, (Descri��o do par�metro)
@param aFieldRet	, Array		, Vetor com o nome dos campos que ir�o compor o retorno da linha selecionada, ex.: ("A1_COD", "A1_LOJA"}
@param [aIndices]	, Array		, Vetor multidimensional com indices a serem utilizados no F3 customizado, sendo:
                       	        	[1] - Descri��o do �ndice
                        	       	[2] - Campos do �ndice
									ex.: { { "C�digo+Loja","A1_COD+A1_LOJA"}, {"Nome", "A1_NOME"} }

@return nil, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
METHOD New( cQry, aFieldRet, aIndices ) CLASS GTPxLookUp  
	PARAMTYPE 0 VAR cQry		AS CHARACTER
	PARAMTYPE 1 VAR aFieldRet 	AS ARRAY
	PARAMTYPE 2 VAR aIndices 	AS ARRAY OPTIONAL DEFAULT {}

	::aInd			:= {}
	::aIndices		:= aIndices    
	::aSize 		:= {0,0,390,781}          
	::aFieldRet	:= aFieldRet       
	::aButtons		:= {}    
	::aReturn		:= {}
	::aSeek		:= {}

	::bOk 			:= {|| ::lOk := .T., ::oDlg:End()}
	::bCancel 		:= {|| ::oDlg:End() }

	::cAlias		:= GetNextAlias()
	::cQry			:= cQry

	::lOk			:= .F.

	::nX			:= 0
	
	::oDlg 			:= nil
	::oButtonBar 	:= nil
	::oPnlBrw		:= nil
	::oBrowse		:= nil         
	// ::oTmpTable	:= nil
	
Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} Execute
Classe para executar a consulta espec�fica ap�s a configura��o e apresentar tela ao usu�rio
@type method
@author jacomo.fernandes
@since 03/07/2019
@version 1.0
@return l�gico, Informa se a consulta foi confirmada (.T.) ou cancelada (.F.)
/*/
//------------------------------------------------------------------------------

METHOD Execute() CLASS GTPxLookUp    
	Local aDescInd	:= {}                 
	Local nX		                 
	CreateTable(::cQry, @oTmpTable, @::cAlias, ::aInd, ::aIndices, ::aSeek)
	    
	aEval(::aIndices,{|x| aAdd(aDescInd,x[1])})
	
	If Empty(aDescInd)
		::lPesq := .F.
		aAdd(aDescInd,"")
	EndIf

	DEFINE MSDIALOG ::oDlg TITLE "Consulta Espec�fica" FROM ::aSize[1],::aSize[2] TO ::aSize[3],::aSize[4] PIXEL

		::oButtonBar := FWButtonBar():new()
		::oButtonBar:Init( ::oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T. )

		::oButtonBar:addBtnText( "Confirmar"		, "Confirma a consulta"		, ::bOk	  	,,,CONTROL_ALIGN_RIGHT, .T.)
     	::oButtonBar:addBtnText( "Cancelar" 		, "Cancela a consulta"	 	, ::bCancel	,,,CONTROL_ALIGN_RIGHT, .T.)
		                
    	For nX := 1 to len(::aButtons)
    		::oButtonBar:addBtnText( ::aButtons[nX,1], ::aButtons[nX,2], ::aButtons[nX,3],,,CONTROL_ALIGN_LEFT, .T.)
  		Next                    
 	                                           
		::oPnlBrw 			:= TPanel():New(0,0,"",::oDlg,,,,,,0,0)
		::oPnlBrw:Align 	:= 5
		
		::oBrowse := FWBrowse():New( ::oPnlBrw ) 
		AddColumns( ::oBrowse, ::cAlias, ::bOk )
		
		::oBrowse:SetDataTable(  )
		::oBrowse:SetAlias( ::cAlias )
		
		::aSeek := GetSeekOrder( ::aIndices, ::cAlias ) 
		If len( ::aSeek ) > 0
			::oBrowse:SetSeek( , ::aSeek )
		Else
			::oBrowse:SetSeek()
		EndIf	
		
		::oBrowse:Activate()

	ACTIVATE MSDIALOG ::oDlg CENTERED

	If ::lOk                  
		::SetReturn()
	EndIf

   	// CloseTbl( @::oTmpTable )
   	
Return ::lOk          

//------------------------------------------------------------------------------
/*/{Protheus.doc} AddIndice
Met�do para adicionar �ndices a consulta espec�fica
@type method
@author jacomo.fernades
@since 03/07/2019
@version 1.0
@param cName, character, Descri��o do �ndice
@param cFields	, character		, String contendo os campos do �ndice "A1_COD+A1_LOJA"
@return nil, return_description
/*/
//------------------------------------------------------------------------------
METHOD AddIndice( cName, cFields ) CLASS GTPxLookUp
	PARAMTYPE 0 VAR cName	AS CHARACTER
	PARAMTYPE 1 VAR cFields 	AS CHARACTER
                                        
	aAdd( ::aIndices,{cName, StrTokArr2( cFields, '+' ), cFields } )
Return                 

//------------------------------------------------------------------------------  
/*/{Protheus.doc} AddButton
M�todo para adiciona bot�es na tela de consulta espec�cica
@type method
@author jacomo.fernades
@since 03/07/2019
@version 1.0
@param cName, cDesc, Nome que ir� aparecer bot�o
@param cDesc, character	, string contendo o Hint (dica) da funcionabilidade do bot�o
@param bAction	, codeblock	, CodeBlock com a a��o do bot�o
@return nil, return_description
/*/
//------------------------------------------------------------------------------
METHOD AddButton( cName, cDesc, bAction ) CLASS GTPxLookUp
	PARAMTYPE 0 VAR cName	AS CHARACTER
	PARAMTYPE 1 VAR cDesc 	AS CHARACTER
	PARAMTYPE 2 VAR bAction	AS BLOCK
                                        
	aAdd( ::aButtons,{cName, cDesc, bAction} )
Return

//------------------------------------------------------------------------------  
/*/{Protheus.doc} SetReturn
M�todo para alimentar o vetor de retorno com os valores da linha selecionada
@type method
@author jacomo.fernades
@since 03/07/2019
@version 1.0
@return nil, return_description
/*/
//------------------------------------------------------------------------------
METHOD SetReturn() CLASS GTPxLookUp
	Local nX := 0
	
	For nX := 1 to len( ::aFieldRet )   
		If FieldPos( ::aFieldRet[nX] ) > 0
			aAdd(::aReturn, (::cAlias)->( FieldGet( FieldPos( ::aFieldRet[nX] ) ) ) )	
		EndIf	
	Next

Return
    
//------------------------------------------------------------------------------  
/*/{Protheus.doc} GetReturn
M�todo get para o vetor de Retorno
@type method
@author jacomo.fernades
@since 03/07/2019
@version 1.0
@return Array, Vetor com os valores selecionados no Browse (somente os campos informados para retorno na instancia��o do objeto)
/*/
//------------------------------------------------------------------------------
METHOD GetReturn() CLASS GTPxLookUp
Return ::aReturn            

//------------------------------------------------------------------------------  
/*/{Protheus.doc} GetPosLine
M�todo para obter os valores de todos os campos da linha posicionada
@type method
@author jacomo.fernades
@since 03/07/2019
@version 1.0
@return Array, Vetor Multidimensional com os todos os valores da linha selecionada, sendo:
					[1] - Nome do campo
					[2] - Valor do campo
/*/
//------------------------------------------------------------------------------
METHOD GetPosLine() CLASS GTPxLookUp
	Local aAux 	:= {}
	Local nX	:= 0 
	
	For nX := 1 to (::cAlias)->( FCount() )	            
		aAdd(aAux,{ (::cAlias)->( FieldName(nX) ), (::cAlias)->( FieldGet(nX) ) } )                                         
	Next	      

Return aClone(aAux)
  
//------------------------------------------------------------------------------  
/*/{Protheus.doc} Destroy
M�todo destrutor da classe, deve obrigat�riamente ser chamado no final do uso do objeto
@type method
@author jacomo.fernades
@since 03/07/2019
@version 1.0
@return nil, retorno nulo
/*/
//------------------------------------------------------------------------------
METHOD Destroy(lSimulaCover) CLASS GTPxLookUp
	Default lSimulaCover := .f.
	If ValType( oTmpTable ) == 'O' //n�o esquecer de fazer o usdo de lSimulaCover
		FreeObj( oTmpTable )
	EndIf

	If ValType( ::oBrowse ) == 'O' .Or. lSimulaCover
		FreeObj( ::oBrowse )
	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CreateTable
Static Function de uso interno da classe para alimentar a tabela tempor�ria
@type Static Function
@author jacomo.fernandes
@since 03/07/2019
@version 1.0
@param cQry, character, String com consulta padr�o SQL que servir� para busca dos dados 
@param oTmpTable, object, Vari�vel passada por refer�ncia que ir� armazenar o objeto FwTemporaryTable
@param cAlias, character, Vari�vel passada por refer�ncia que ir� armazenar o Alias da tabela tempor�ria
@param aInd, array, Vetor que ir� armazenar os arquivos criados para gera��o de �ndices da tabela tempor�ria
@param aSearch, array, Vetor multimensional com os �ndices que ser�o criados na tabela tempor�ria
@return nil, returna nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function CreateTable(cQry,oTmpTable,cAlias,aInd,aSearch)
	Local nX := 0

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRYF3CUST",.T.,.T.)

	CreateTRB(@oTmpTable,cAlias,aInd,aSearch)

	cAlias := oTmpTable:GetAlias()

	While QRYF3CUST->(!EOF())
		RecLock(cAlias,.T.)
		For nX := 1 to QRYF3CUST->(FCount())
			(cAlias)->( FieldPut( nX, QRYF3CUST->( FieldGet(nX) ) ) )
		Next
		(cAlias)->(MsUnlock())
		QRYF3CUST->(dbSkip())
	EndDo

	(cAlias)->( dbGoTop() )
	QRYF3CUST->( dbCloseArea() )
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CreateTRB
Static Function de uso interno da classe para cria��o da tabela tempor�ria
@type Static Function
@author jacomo.fernandes
@since 03/07/2019
@version 1.0
@param oTmpTable, object, Vari�vel passada por refer�ncia que ir� armazenar o objeto FwTemporaryTable
@param cAlias, character, Vari�vel passada por refer�ncia que ir� armazenar o Alias da tabela tempor�ria
@param aInd, array, Vetor que ir� armazenar os arquivos criados para gera��o de �ndices da tabela tempor�ria
@param aSearch, array, Vetor multimensional com os �ndices que ser�o criados na tabela tempor�ria
@return nil, returna nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function CreateTRB(oTmpTable,cAlias,aInd,aSearch)
	Local aStruQry	:= QRYF3CUST->(dbStruct())
	Local aStru 		:= {}
	
	Local nX			:= 0
    Local aTamSx3       := {}

	Local lRemake		:= .F.

	lRemake := ValType(oTmpTable) <> "O" 

	If ( !lRemake .And. AdmDiffArray(aStruTmp,QRYF3CUST->(dbStruct())) )
		lRemake := .T.
		oTmpTable:Delete()
	EndIf

	If ( lRemake )

		SX3->(dbSetOrder(2))

		For nX := 1 to QRYF3CUST->( FCount() )
			If SX3->(dbSeek( QRYF3CUST->( FieldName(nX) ) ) )
				aTamSx3 := TamSx3(FieldName(nX))
				aAdd(aStru,{FieldName(nX),	aTamSx3[3], aTamSx3[1],	aTamSx3[2]})
			Else
				aAdd(aStru, aClone( aStruQry[nX] ) )
			EndIf
		Next

		oTmpTable := FWTemporaryTable():New( GetNextAlias() )
		
		oTmpTable:SetFields( aStru )
		
		aStruTmp := aClone(aStru)

		For nX := 1 to len(aSearch)
			oTmpTable:AddIndex("indice"+cValToChar(nX), aSearch[nX,2] )
		Next
		
		oTmpTable:Create()
	
	Else
		TcSqlExec('TRUNCATE TABLE '+ oTmpTable:GetRealName())
	EndIf

    GtpDestroy(aTamSx3)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AddColumns
Static Function de uso interno da classe para cria��o das colunas do Browse
@type Static Function
@author jacomo.fernandes
@since 03/07/2019
@version 1.0
@param oBrowse, object, Objeto TcBrowse utilizado na tela da consulta espec�fica
@param cAlias, character, Vari�vel passada por refer�ncia que ir� armazenar o Alias da tabela tempor�ria
@param bOK, codeblock, Codeblock a ser executado no duplo-clique
@return nil, returna nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------ 
Static Function AddColumns( oBrowse, cAlias, bOK )
	Local aColumn		:= {}
	Local aStruct := ( cAlias )->( dbStruct() )
	Local nX	 		:= 0
	Local nPos			:= 0
	Local aTamSx3       := {}

	SX3->(dbSetOrder(2))
    For nX := 1 to (cAlias)->(FCount())
        
    	If SX3->(dbSeek( (cAlias)->(FieldName(nX)) ))
            aTamSx3 := TamSx3(FieldName(nX))
    		aColumn := {	AllTrim( x3Titulo() )					,;	//T�tulo da coluna
    						&( '{|| ' + FieldName(nX) + ' } ' )  	,;	//Code-Block de carga dos dados	
    						aTamSx3[3]								,;	//Tipo de dados
    						AllTrim(GetSX3Cache(FieldName(nX), "X3_PICTURE"))					,;	//M�scara
    						Iif(aTamSx3[3]=="N",2,1)				,; //Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
    						aTamSx3[1]							,; //Tamanho
							aTamSx3[2]							,; //Decimal
    						.F.											,; //Indica se permite a edi��o
    						{|| .T.}									,; //Code-Block de valida��o da coluna ap�s a edi��o					
    						.F.											,; //Indica se exibe imagem
    						bOk											,; //Code-Block de execu��o do duplo clique
    						nil											,; //Vari�vel a ser utilizada na edi��o (ReadVar)
							{|| .T.}									,; //Code-Block de execu��o do clique no header
							.F.											,; //Indica se a coluna est� deletada
							.F.											,; //Indica se a coluna ser� exibida nos detalhes do Browse
																		,; //Op��es de carga dos dados (Ex: 1=Sim, 2=N�o)
							cValToChar(nX)							,; //Id da coluna
							.F.											;  //Indica se a coluna � virtual
    						}
    						
 	   
	 	Else
	    
	    	nPos := aScan( aStruct, {|x| x[1] == (cAlias)->( FieldName(nX) )  } )
	    
	    	aColumn := {	Capital( aStruct[nPos][1] )		,;	//T�tulo da coluna	    
    						&( '{|| ' + aStruct[nPos][1] + ' } ' )  	,;	//Code-Block de carga dos dados	
    						aStruct[nPos][2]								,;	//Tipo de dados
    																	,;	//M�scara
    						Iif(aStruct[nPos][2]=="N",2,1)			,; //Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
    						aStruct[nPos][3]							,; //Tamanho
							aStruct[nPos][4]							,; //Decimal
    						.F.											,; //Indica se permite a edi��o
    						{|| .T.}									,; //Code-Block de valida��o da coluna ap�s a edi��o					
    						.F.											,; //Indica se exibe imagem
    						bOk											,; //Code-Block de execu��o do duplo clique
    						nil											,; //Vari�vel a ser utilizada na edi��o (ReadVar)
							{|| .T.}									,; //Code-Block de execu��o do clique no header
							.F.											,; //Indica se a coluna est� deletada
							.F.											,; //Indica se a coluna ser� exibida nos detalhes do Browse
																		,; //Op��es de carga dos dados (Ex: 1=Sim, 2=N�o)
							cValToChar(nX)							,; //Id da coluna
							.F.											;  //Indica se a coluna � virtual
    						}	     	
    	
    	
   		EndIf
 
 		oBrowse:AddColumn( aColumn )
 		   	
    Next
    
    GtpDestroy(aTamSx3)

Return
                                 
//------------------------------------------------------------------------------
/*/{Protheus.doc} CloseTbl
Static Function de uso interno da classe para excluir tabelas e indices criados
@type Static Function
@author jacomo.fernandes
@since 03/07/2019
@version 1.0
@param oTmpTable, object, Vari�vel com o objeto FwTemporaryTable
@return nil, returna nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------ 
// Static Function CloseTbl( oTmpTable )
	
// 	oTmpTable:Delete()

// Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetSeekOrder

@type Static Function
@author jacomo.fernandes
@since 03/07/2019
@version 1.0
@param aIndices, array, Vari�vel com o objeto FwTemporaryTable
@param cAlias, character, Vari�vel com o objeto FwTemporaryTable
@return nil, returna nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------ 
Static Function GetSeekOrder( aIndices, cAlias )
	Local aAux			:= {}
	Local aAuxDetail	:= {}
	Local aDetail	:= {}
	Local aRet		:= {}
	Local aStruct	:= ( cAlias )->( dbStruct() )
	Local nX 		:= 0 
	Local nY		:= 0
	Local nPos		:= 0
    Local aTamSx3   := {}
    
	SX3->( dbSetOrder(2) )
	For nX := 1 to len( aIndices )
		aDetail := {}
			//[n,2,n,1] LookUp
			//[n,2,n,2] Tipo de dados
			//[n,2,n,3] Tamanho
			//[n,2,n,4] Decimal
			//[n,2,n,5] T�tulo do campo
			//[n,2,n,6] M�scara
		For nY := 1 to len( aIndices[nX][2] )
			If SX3->(dbSeek( aIndices[nX][2][nY] ) )	
                aTamSx3 := TamSx3(aIndices[nX][2][nY])
				aAuxDetail := 	{ 	""								                        ,; // LookUp
                                    aTamSx3[3]				                                ,; // Tipo de dados
                                    aTamSx3[1]				                                ,; 	// Tamanho
                                    aTamSx3[2]				                                ,; 	// Decimal
                                    AllTrim( FwX3Titulo(aIndices[nX][2][nY]) )		        ,; 	// T�tulo do campo
                                    AllTrim(GetSX3Cache(aIndices[nX][2][nY], "X3_PICTURE")) ;	// M�scara
                                }
								
				
				aAdd( aDetail, aAuxDetail )
				
			Else
				nPos := aScan( aStruct, {|x| x[1] == aIndices[nX][2][nY] } )
	
				aAuxDetail := 	{ 	""											,; // LookUp
                                    aStruct[nPos][2]							,; // Tipo de dados
                                    aStruct[nPos][3]							,; 	// Tamanho
                                    aStruct[nPos][4]							,; 	// Decimal
                                    AllTrim( Capital( aStruct[nPos][1] ) )	    ,; 	// T�tulo do campo
                                    ""											;	// M�scara
                                }
									
				aAdd( aDetail, aAuxDetail )					
				
			EndIf
		Next
	 
		aAux := { aIndices[nX][1], aDetail, nX, .T. }
		
		aAdd( aRet, aClone(aAux) )
	Next	

    GtpDestroy(aTamSx3)

Return aRet 
