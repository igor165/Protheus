#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA456.CH"

Static cIDobrg := ""
Static lCallExt       as logical
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA456
Cadastro MVC de Complementos Fiscais

@author Rafael Völtz
@since 10/08/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA456(cParCdObrg as char)

Local oColumn          as object
Local oDlg             as object
Local aIndex           as array
Local aSeek            as array
Local aMenu            as array
Local nI               as numeric
Local lRet             as logical
Local cAliasT56        as char
Private oBrowse        as object
Private aCoors         as array     
Private cQuery         as char
Private cDescObrg      as char 

	lCallExt := .F.
	nI       := 0
	aIndex   := {}
	aSeek    := {}
	aMenu    := {}	
	aCoors   := FWGetDialogSize( oMainWnd )	 
	
	If Empty(cParCdObrg)
		lRet := TAFASelObr()
	Else
		cCdObrg   := cParCdObrg
		lRet 	  := ValCodObrg(cCdObrg)
		lCallExt  := .T.
	EndIf
	
	If lRet
		cAliasT56 := GetNextAlias()
		oSize     := FWDefSize():New(.T.)
		            oSize:AddObject('DLG',100,100,.T.,.T.)
		            oSize:SetWindowSize(aCoors)
		            oSize:lProp     := .T.
		            oSize:Process()
		
		//-------------------------------------------------------------------
		// Abertura da tabela
		//-------------------------------------------------------------------

		Connect(,.T.,"01","01",,.T.)

		cQuery := "SELECT DISTINCT T56.T56_FILIAL T56_FILIAL, " 
		cQuery +=      " T56.T56_ID     T56_ID, " 
		cQuery +=      " T56.T56_DTINI  T56_DTINI, " 
		cQuery +=      " T56.T56_DTFIN  T56_DTFIN, " 
		cQuery +=      " ISNULL(C09.C09_DESCRI,' ') C09_DESCRI "
		cQuery += " FROM "+ RetSqlName("T56") + " T56 " 
		cQuery += " LEFT JOIN  " + RetSqlName("C09") + " C09 ON C09.C09_FILIAL  = '" + xFilial("C09") + "' AND C09.C09_ID = T56.T56_IDUF  AND C09.D_E_L_E_T_ = ' ' "
		cQuery += " INNER JOIN " + RetSqlName("T57") + " T57 ON T57.T57_FILIAL = T56.T56_FILIAL AND T57.T57_ID = T56.T56_ID  AND T57.D_E_L_E_T_ = ' '  "
		cQuery += " INNER JOIN " + RetSqlName("T55") + " T55 ON T55.T55_FILIAL = '" + xFilial("T55") + "' AND T55.T55_IDCHAV = T57.T57_IDCHAV     AND T55.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE T56.T56_FILIAL = '" + xFilial("T56") + "'"
		cQuery += "   AND T55.T55_IDOBRG = '" + cIDobrg + "'"
		cQuery += "   AND T56.D_E_L_E_T_ = ' '  "
		
		cQuery := ChangeQuery(cQuery)
 		
		//-------------------------------------------------------------------
		// Indica os índices da tabela temporária
		//-------------------------------------------------------------------
		Aadd( aIndex, "T56_FILIAL+T56_ID"  )
		
		//-------------------------------------------------------------------
		// Indica as chaves de Pesquisa
		//-------------------------------------------------------------------
		Aadd( aSeek, { STR0004   , {{"","D",10,0,STR0001   ,,}} } ) //Data Inicial
		Aadd( aSeek, { STR0005, {{"","D",10,0,STR0005,,}} } )       //Data Final
		Aadd( aSeek, { STR0006, {{"","C",10,0,STR0006,,}} } )       //UF
		
		//-------------------------------------------------------------------
		// Define a janela do Browse
		//-------------------------------------------------------------------
		DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL
		
			oBrowse := FWFormBrowse():New()
			oBrowse:SetOwner(oDlg)
			oBrowse:SetDescription( STR0001 + ": "+cDescObrg) //"Complementos fiscais			                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
			oBrowse:SetAlias( cAliasT56 )
			oBrowse:SetMenuDef("TAFA456")
			oBrowse:SetDataQuery(.T.)	
			oBrowse:SetQuery(cQuery)
			oBrowse:DisableDetails()
			oBrowse:DisableReports()			
			oBrowse:SetQueryIndex(aIndex)					
			oBrowse:SetSeek({||.T.},aSeek)
			oBrowse:SetBeforeExec({|| TAFA456BEFORE() })			
			
			aMenu := MenuDef()				 
		        
			For nI := 1 To Len( aMenu )
				oBrowse:AddButton( aMenu[nI][1], aMenu[nI][2], Nil, aMenu[nI][4], aMenu[nI][5], (aMenu[nI][4] > 1) )
			Next nI
			
			ADD COLUMN oColumn DATA { || T56_FILIAL  }     TITLE STR0007     SIZE 15 OF oBrowse  //Filial
			ADD COLUMN oColumn DATA { || STOD(T56_DTINI) } TITLE STR0004     SIZE 15 OF oBrowse  //Data Inicial
			ADD COLUMN oColumn DATA { || STOD(T56_DTFIN) } TITLE STR0005 	 SIZE 15 OF oBrowse  //Data Final
			ADD COLUMN oColumn DATA { || C09_DESCRI  }     TITLE STR0006 	 SIZE 15 OF oBrowse	 //UF		
			
			oBrowse:Activate()
		//-------------------------------------------------------------------
		// Ativação do janela
		//-------------------------------------------------------------------
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFASelObr
Tela para seleção da obrigação fiscal

@author Rafael Völtz
@since 10/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFASelObr()

Local oSay        as object
Local oDlg        as object
Local oGroup      as object
Local oCodObrg    as object
Local oDescObrg   as object
Local oSize       as object
Local lRet        as logical
Local cCdObrg     as char

	cCdObrg   := Space(6)
	cDescObrg := Space(30)
	
	oSize := FWDefSize():New(.T.)
			oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
			oSize:SetWindowSize({000, 000, 180, 490})
			oSize:lLateral     := .F.  // Calculo vertical	
			oSize:Process() 		  //executa os calculos	
	        
	DEFINE MSDIALOG oDlg TITLE STR0001 ;   //Cadastro de complementos fiscais
								FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
								TO oSize:aWindSize[3],oSize:aWindSize[4] ;
								COLORS 0, 16777215 PIXEL  
		    
		    @ 040, 004 GROUP oGroup    TO 067, 240       PROMPT STR0008 OF oDlg COLOR 0, 16777215 PIXEL  //Obrigação Fiscal
		    @ 054, 012 SAY   oSay      PROMPT STR0009  SIZE 023, 007 OF oDlg COLORS 0, 16777215 PIXEL    //Código:
		    @ 050, 034 MSGET oCodObrg  VAR cCdObrg       SIZE 050, 010 OF oDlg PICTURE "@!"  VALID ValCodObrg(cCdObrg)    COLORS 0, 16777215 F3 "CHW" HASBUTTON PIXEL
		    @ 050, 88 MSGET  oDescObrg VAR cDescObrg     SIZE 150, 010 OF oDlg PICTURE "@!"  WHEN .F.   COLORS 0, 16777215 HASBUTTON PIXEL
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lRet := .T., oDlg:End()}, {||lRet := .F. , oDlg:End() }) CENTERED

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValCodObrg
Válida código da obrigação

@author Rafael Völtz
@since 10/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function ValCodObrg(cCdObrg as char)

	If Empty(cCdObrg)
		MSGAlert(STR0010)  //Nenhuma obrigação fiscal foi selecionada
		cDescObrg := space(30)
		Return .F.
	Else 
		cDescObrg := POSICIONE("CHW",2,xFilial("CHW")+cCdObrg,"CHW_DESCRI")
		cIDobrg   := POSICIONE("CHW",2,xFilial("CHW")+cCdObrg,"CHW_ID")
	EndIf
	
	DbSelectArea("T55")
	T55->(DbSetOrder(3))
	If !T55->( DBSeek( xFilial( "T55" ) + cIDobrg ) )
		Help("",1,"TAFA456001")				
		Return .F.
	EndIf	
	
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Cadastro de Grupo de acesso/perfil

@Return     MenuDef
@author     Serviços
@since         07/04/2014
/*/
//----------------------------------------------------------
Static Function MenuDef()

Local aRotina as array

aRotina := {}

ADD OPTION aRotina TITLE STR0011  ACTION "TAFA456EXEC(1)"    OPERATION 2    ACCESS 0     // "Visualizar"
ADD OPTION aRotina TITLE STR0012  ACTION "TAFA456EXEC(3)"    OPERATION 3    ACCESS 0     // "Incluir"
ADD OPTION aRotina TITLE STR0013  ACTION "TAFA456EXEC(4)"    OPERATION 4    ACCESS 0     // "Alterar"
ADD OPTION aRotina TITLE STR0014  ACTION "TAFA456EXEC(5)"    OPERATION 5    ACCESS 0     // "Excluir"


Return(aRotina)

//----------------------------------------------------------
/*/{Protheus.doc} TAFA456EXEC()
Executa a View
@Param      lOper := Operação do formulário (inclusão, exclusão, alteração e visualização)
@Return     .T.
@author     Rafael Völtz
@since      20/12/2016
/*/
//----------------------------------------------------------
Function TAFA456EXEC(lOper)	
	
Local cTitulo := ""
	
	If lOper == 1
		cTitulo := "VISUALIZAR"
	Elseif lOper == 3
		cTitulo := "INCLUIR"
	Elseif lOper == 4
		cTitulo := "ALTERAR"		
	Elseif lOper == 5
		cTitulo := "EXCLUIR"
	Endif

	If ( oBrowse:Alias() )->( !Eof() ) .Or. lOper == 3
		FWExecView(cTitulo,'TAFA456', lOper, , {|| .T. },{|| .T.},,,{|| .T.})
	Else
		Help(" ",1,"ARQVAZIO")
	Endif
		
	CursorWait()		
	oBrowse:GoBottom()	
	oBrowse:Refresh(.T.)
	CursorArrow()
	
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} TAFA456BEFORE()
Posiciona registro na tabela T56 do MVC

@Return     .T.
@author     Rafael Völtz
@since      20/12/2016
/*/
//----------------------------------------------------------
Function TAFA456BEFORE()
		
	dbSelectArea("T56")
	dbSetOrder(2)
	dbSeek((oBrowse:cAlias)->T56_FILIAL + (oBrowse:cAlias)->T56_ID)
	
Return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rafael Völtz
@since 10/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef() 
Local oStruT57 as object
Local oModel   as object
Local oStruT56 := FWFormStruct( 1, 'T56')
Local aCombo   := {}
Local cIdPer   := T56->T56_ID
Local bInit := ""
	
	If(FunName() == "TAFA456" .OR. lCallExt) //Se for por meio de integração, não pode criar os campos virtuais e nem realizar validações
		oModel   := MPFormModel():New( 'TAFA456',,{|oModel| TAFPosValid(oModel)},{ |oModel| SaveModel( oModel ) } )
		
		DbSelectArea("T54")
		DbSelectArea("T55")
		T55->(DbSetOrder(3))
		T54->(DbSetOrder(1))
		If T55->( DBSeek( xFilial( "T55" ) + cIDobrg ) )
			
			While T55->( !Eof() ) .and. T55->T55_IDOBRG == cIDobrg	
				
				If T54->( DBSeek( xFilial( "T54" ) + T55->T55_IDCHAV  ) )
					aCombo := StrTokArr(Alltrim(T54->T54_COMBO),";")				
					 										
					oStruT56:AddField( ; // Ord. Tipo Desc.
										FWI18NLang("TAFA454",AllTrim( T54->T54_TITULO ),val(substr(T54->T54_TITULO,4,4))), ; 	// [01] C Titulo do campo
										FWI18NLang("TAFA454",AllTrim( T54->T54_DESCRI ),val(substr(T54->T54_DESCRI,4,4))), ;   // [02] C Descrição do campo									
										Alltrim(T54->T54_CHAVE), ; 			// [03] C identificador (ID) do								
										Alltrim(T54->T54_TPDADO)  , ;		// [04] C Tipo do campo
										T54->T54_TAMANH , ; 				// [05] N Tamanho do campo
										T54->T54_DECIMA , ;					// [06] N Decimal do campo
										nil, ; 								// [07] B Code-block de validação do campo
										NIL , ; 							// [08] B Code-block de								
										aCombo, ;				 			// [09] A Lista de valores permitido do campo combo
										.F. , ; 							// [10] L Indica se o campo tem preenchimento obrigatório
										nil , ; 							// [11] B Code-block de inicializacao do campo
										NIL    , ; 							// [12] L Indica se trata de um campo chave
										NIL , ; 							// [13] L Indica se o campo pode receber valor em uma operação de update.
										.T. ) 								// [14] L Indica se o campo é virtual	
						
						bInit := "{|| TAFGETT57('" + cIdPer + "', '" + T54->T54_ID + "')}"
						
						oStruT56:SetProperty(Alltrim(T54->T54_CHAVE),MODEL_FIELD_INIT, &(bInit))
					
				EndIf		
				
				T55->( DBSkip() )
			EndDo	
		EndIf		
			
		oModel:AddFields( 'MODEL_T56' , /*cOwner*/ , oStruT56 )
	
		oModel:GetModel( 'MODEL_T56' ):SetPrimaryKey( { 'T56_DTINI', 'T56_DTFIN','T56_IDUF'} )

		oStruT57 	:= 	FWFormStruct( 1, 'T57' )

		oModel:AddGrid('MODEL_T57', 'MODEL_T56', oStruT57)
		oModel:SetRelation( 'MODEL_T57' , { { 'T57_FILIAL' , 'xFilial( "T57" )' } , { 'T57_ID' , 'T56_ID' }} , T57->( IndexKey( 1 ) ) )
		oModel:GetModel( 'MODEL_T57' ):SetOptional(.T.)
		oModel:SetActivate({|oModel| TAFInitCpl(oModel)})		
	Else
		oModel   := MPFormModel():New( 'TAFA456',,,)
		oStruT57 	:= 	FWFormStruct( 1, 'T57' )
		oModel:AddFields( 'MODEL_T56' , /*cOwner*/ , oStruT56 )
		oModel:AddGrid('MODEL_T57', 'MODEL_T56', oStruT57)  		
		
		oModel:SetRelation( 'MODEL_T57' , { { 'T57_FILIAL' , 'xFilial( "T57" )' } , { 'T57_ID' , 'T56_ID' }} , T57->( IndexKey( 1 ) ) )
		oModel:GetModel( 'MODEL_T56' ):SetPrimaryKey( { 'T56_DTINI', 'T56_DTFIN','T56_IDUF'} )
	EndIf
	
Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rafael Völtz
@since 10/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	as object
Local oStruT56 	as object
Local oView 	as object
Local aHelpCp   := {}
Local aCampos   := {}
Local nX        := 0
Local cHelp     := ""
Local aCombo    := {}
Local aHelp     := {}
Local aHelp2    := {}
Local lInDark   := .T.

	
oModel 	  := FWLoadModel( 'TAFA456' )
oStruT56  := FWFormStruct( 2, 'T56' )
oView 	  := FWFormView():New()

oStruT56:RemoveField( 'T56_ID' )
oStruT56:RemoveField( 'T56_IDUF' )
oView:SetModel( oModel )

DbSelectArea("T54")
DbSelectArea("T55")
T55->(DbSetOrder(3))
T54->(DbSetOrder(1))
If T55->( DBSeek( xFilial( "T55" ) + cIDobrg ) )
	
	HelpInDark( .T. )                       //Desabilita a apresentação do Help
		
	While T55->( !Eof() ) .and. T55->T55_IDOBRG == cIDobrg		
		nX++
		If T54->( DBSeek( xFilial( "T54" ) + T55->T55_IDCHAV  ) )			
			
			aAdd(aCampos, T54->T54_CHAVE)
			
			aCombo := StrTokArr(Alltrim(T54->T54_COMBO),";")			
			
			Help("",1,AllTrim( T54->T54_STRHLP ))
			aHelp := FwGetUltHlp()
			
			If Len(aHelp) >= 2
				aHelpCp   := {}
				If !Empty(aHelp[2,1])
					aAdd(aHelpCp, aHelp[2,1])
				EndIf 
			EndIf
			
			oStruT56:AddField( ; 							 	// Ord. Tipo Desc.
							Alltrim(T54->T54_CHAVE) , ;   			// [01] C Nome do Campo
							cValToChar(nX) , ;  			 			// [02] C Ordem
							FWI18NLang("TAFA454",AllTrim( T54->T54_TITULO ),val(substr(T54->T54_TITULO,4,4))), ; 	// [03] C Titulo do campo
							FWI18NLang("TAFA454",AllTrim( T54->T54_DESCRI ),val(substr(T54->T54_DESCRI,4,4))), ;   // [04] C Descrição do campo
							aHelpCp, ; 		// [05] A Array com Help
							T54->T54_TPDADO    , ; 			// [06] C Tipo do campo
							T54->T54_PICTUR , ; 			// [07] C Picture
							NIL , ; 						// [08] B Bloco de Picture Var
							Alltrim(T54->T54_CPADR) , ; 	// [09] C Consulta F3
							.T.    , ; 						// [10] L Indica se o campo é editável
							Nil , ; 						// [11] C Pasta do campo
							NIL , ; 						// [12] C Agrupamento do campo
							aCombo      , ; 				// [13]   A Lista de valores permitido  do campo combo
							NIL   , ; 						// [14] N Tamanho Máximo da maior						
							NIL , ; 						// [15] C Inicializador de Browse
							.T. , ; 						// [16] L Indica se o campo é virtual
							NIL ) 							// [17] C Picture Variável
		EndIf		
		
		T55->( DBSkip() )
	EndDo
	
	HelpInDark( .F. )                       //Habilita a apresentação do Help

EndIf

oStruT56:AddGroup( 'GRUPO01', STR0015, '', 2 )
oStruT56:AddGroup( 'GRUPO02', STR0016, '', 2 )

oStruT56:SetProperty( "T56_DTINI" , MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
oStruT56:SetProperty( "T56_DTFIN"  , MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
oStruT56:SetProperty( "T56_UF"  , MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
oStruT56:SetProperty( "T56_DESCUF"  , MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )

For nX := 1 to Len(aCampos)
	oStruT56:SetProperty( Alltrim(aCampos[nX]) , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
Next nX

oView:AddField( 'VIEW_T56', oStruT56, 'MODEL_T56' )
oView:EnableTitleView( 'VIEW_T56',STR0001 ) //"Complementos fiscais"

Return ( oView )




//-------------------------------------------------------------------
/*/{Protheus.doc} TAF456Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Rafael Völtz
@since 10/08/2016
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF456Vld( cAlias, nRecno, nOpc, lJob )

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""

//Garanto que o Recno seja da tabela referente ao cadastro principal
//nRecno := CWY->( Recno() )

Default lJob := .F. 

If T56->T56_STATUS $ ( " |1" )

	
	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(T56->T56_DTINI)
		AADD(aLogErro,{"T56_DTINI","000298", "T56",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(T56->T56_DTFIN)
		AADD(aLogErro,{"T56_DTFIN","000004", "T56",nRecno }) //STR0004 - "Verifique a data Final do Registro"
	EndIf	
		
	//Valida o Codigo Id. UF
	If !Empty(T56->T56_IDUF)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := T56->T56_IDUF
		xValRegTab("C09",cChave,3,,@aLogErro,, { "T56", "T56_IUF", nRecno } )
	EndIf
	
	If !Empty(T56->T56_DTINI)
		IF T56->T56_DTINI > T56->T56_DTFIN
			AADD(aLogErro,{"T56_DTINI","000578", "T56",nRecno }) // STR0578 - "Data inicial deve ser menor que a data final"
		EndIF
	EndIf			
	
	dbSelectArea("T57")
  	T57->(dbSetOrder(1))
  	If MsSeek(xFilial("T57") + T56->T56_ID)  		
  		While(!T57->(Eof()) .And. T57->T57_ID == T56->T56_ID)
	  		If Empty(T57->T57_IDCHAV)
				aAdd(aLogErro,{"T57_IDCHAVE","000010","T56",nRecno}) //"Campo Inconsistente ou Vazio" 
			Else
				cChave := T57->T57_IDCHAV 
  				xValRegTab("T54",cChave,1,,@aLogErro, { "T56", "T57_IDCHAV", nRecno } )     
   			EndIf	   		
	   		T57->(dbSkip())
	   	EndDo   		
  	EndIf

	//Atualizo o Status do Registro
	cStatus := Iif(Len(aLogErro) > 0, "1", "0" )
	TAFAltStat( "T56", cStatus )

Else
	AADD(aLogErro,{"T56_ID","000305","T56",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados	
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr( aLogErro )
EndIf	


Return( aLogErro )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGETT57

Busca o valor do campo específico cadastrado para o período

oModel - Modelo

@return .T.

@author Rafael Völtz
@since 10/10/2016
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAFGETT57(cIdPer as char, cIDChave as char)
 Local cValor  as char 
 
 	DbSelectArea("T54")
	DbSelectArea("T55")
	DbSelectArea("T57")
	
	T54->(DbSetOrder(1))
	T55->(DbSetOrder(2))
	T57->(DbSetOrder(1))
	
	If T55->( DBSeek( xFilial( "T55" ) + cIDChave + cIDobrg ) )
		
		While T55->( !Eof() ) .and. T55->T55_IDCHAV == cIDChave .And.  T55->T55_IDOBRG == cIDobrg		
			
			If T54->( DBSeek( xFilial( "T54" ) + T55->T55_IDCHAV  ) )
				If T57->( DBSeek( xFilial( "T57" ) + Alltrim(cIdPer) +  Alltrim(T54->T54_ID)) )    
					cValor := Alltrim(T57->T57_VLCHAV)
					
					If (T54->T54_TPDADO == "N")						
						cValor := STRTRAN(cValor, ",", ".") 
						Return Val(cValor)												
						 
					ElseIf (T54->T54_TPDADO == "D")
						Return Ctod(cValor)									 
					
					ElseIf (T54->T54_TPDADO == "L")						
						If (cValor == ".T.")
							Return .T.
						Else
							Return .F.
						EndIf
						
					ElseIf (T54->T54_TPDADO == "C")						
						Return cValor						
					EndIf     
				Else
					If (T54->T54_TPDADO == "N")
						Return 0												
						 
					ElseIf (T54->T54_TPDADO == "D")
						Return CTOD("")									 
					
					ElseIf (T54->T54_TPDADO == "L")				
						Return .F.
																	
					ElseIf (T54->T54_TPDADO == 'C')
						Return ""
					EndIf
				EndIF
			EndIf		
			
			T55->( DBSkip() )
		EndDo	
	EndIf
	
 
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFInitCpl

Função para inicializar os campos quando a operação é de Inclusão.

oModel - Modelo

@return .T.

@author Rafael Völtz
@since 10/10/2016
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAFInitCpl(oModel as object)
	
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		DbSelectArea("T54")
		DbSelectArea("T55")
		T55->(DbSetOrder(3))
		T54->(DbSetOrder(1))
		If T55->( DBSeek( xFilial( "T55" ) + cIDobrg ) )
			While T55->( !Eof() ) .and. T55->T55_IDOBRG == cIDobrg	
				If T54->( DBSeek( xFilial( "T54" ) + T55->T55_IDCHAV  ) )
					If T54->T54_TPDADO == "N"			
						oModel:SetValue("MODEL_T56",Alltrim(T54->T54_CHAVE),0)
					ElseIf T54->T54_TPDADO == "L"
						oModel:SetValue("MODEL_T56",Alltrim(T54->T54_CHAVE),.F.)
					Else
						oModel:SetValue("MODEL_T56",Alltrim(T54->T54_CHAVE),"")
					EndIf
				EndIf
				T55->( DBSkip() )
			EndDo
		EndIf
	EndIf
 
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel

Função para realizar a manutenção das informações no banco

oModel - Modelo

@return .T.

@author Rafael Völtz
@since 10/10/2016
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function SaveModel(oModel as object)

Local cId    := oModel:GetValue("MODEL_T56","T56_ID")
Local dDtIni := oModel:GetValue("MODEL_T56","T56_DTINI")
Local dDtFin := oModel:GetValue("MODEL_T56","T56_DTFIN")
Local cIDUF  := oModel:GetValue("MODEL_T56","T56_IDUF")
Local oObjBrow as object
Local aCamposOld  := {}
Local nX          := 0
Local aIdOld      := {}
Local lRet        := .T.	
	
	
		Begin Transaction
		
		DbSelectArea("T54")
		DbSelectArea("T55")
		DbSelectArea("T57")
		T55->(DbSetOrder(3))
		T54->(DbSetOrder(1))
		T57->(DbSetOrder(1))
		
		// Tratamento necessário, pois pode haver um período cadastrado para outra obrigação. Portanto, é necessário agrupar em um único ID da T56
		// O registro antigo da T57 é excluído e os campos da T57 são transportados para o ID atual que está sendo incluído
		If(oModel:GetOperation() == MODEL_OPERATION_INSERT)
			DbSelectArea("T56")
			T56->(DbSetOrder(1))
			IF T56->(DbSeek( xFilial("T56") + DTOS(dDtIni) + DTOS(dDtFin) + cIDUF))
				While T56->(!Eof()) .And. (xFilial("T56") + DTOS(dDtIni) + DTOS(dDtFin) + cIDUF) == (T56->T56_FILIAL + DTOS(T56->T56_DTINI) + DTOS(T56->T56_DTFIN) + T56_IDUF)
					If T57->(DbSeek(xFilial("T57") + T56->T56_ID))
						While T57->( !Eof() ) .and. T57->T57_FILIAL + T57->T57_ID == xFilial("T56") + T56->T56_ID
							aAdd(aCamposOld, {T57->T57_IDCHAV, T57->T57_VLCHAV})
							
							RecLock("T57",.F.)
							dbDelete()
							MsUnLock()
							T57->(DbSkip())
						EndDo
					EndIf
					//ID PRINCIPAL DA T56 E APAGADO DEPOIS DO COMMIT
					aAdd(aIdOld,T56->T56_ID)
					T56->(DbSkip())
				EndDo
			EndIf
		EndIf
	    
		If T55->( DBSeek( xFilial( "T55" ) + cIDobrg ) )
			
			While T55->( !Eof() ) .and. T55->T55_IDOBRG == cIDobrg		
				
				If T54->( DBSeek( xFilial( "T54" ) + T55->T55_IDCHAV  ) )
					
					cValor := cValToChar(oModel:GetValue("MODEL_T56", Alltrim(T54->T54_CHAVE)))			
								
					If T57->( DBSeek( xFilial( "T57" ) + cId + T54->T54_ID) )
						If(oModel:GetOperation() != MODEL_OPERATION_DELETE)
							RecLock("T57",.F.)
							T57->T57_VLCHAV := cValor
							MsUnLock()   
						Else
							RecLock("T57",.F.)
							dbDelete()
							MsUnLock()						
						EndIf
					Else
						If(oModel:GetOperation() != MODEL_OPERATION_DELETE)
							RecLock("T57",.T.)				
							T57->T57_FILIAL := xFilial("T57")
							T57->T57_ID 	:= cId
							T57->T57_IDCHAV := T54->T54_ID
							T57->T57_VLCHAV := cValor
							MsUnLock()			
						EndIf
					EndIf						
		                    							
				EndIf		
				
				T55->( DBSkip() )
			EndDo
			
			//FwFormCommit( oModel, , , {|| TAFrefresh()} )		
			FwFormCommit(oModel)
			
			// Tratamento necessário, pois pode haver um período cadastrado para outra obrigação. Portanto, é necessário agrupar em um único ID da T56
			// O registro antigo é excluído e os campos da T57 são transportados para o ID atual que está sendo incluído
			If(oModel:GetOperation() == MODEL_OPERATION_INSERT)
				For nX := 1 To Len(aCamposOld)
					RecLock("T57",.T.)
					T57->T57_FILIAL := xFilial("T57")
					T57->T57_ID 	:= cId
					T57->T57_IDCHAV := aCamposOld[nX,1]
				    T57->T57_VLCHAV := aCamposOld[nX,2]
				    MsUnLock()
				Next nX
				
				//Apaga os ID Antigos da T56 depois do commit
				For nX := 1 To Len(aIdOld)
					DbSelectArea("T56")
					T56->(DBSetOrder(2))
					If(DbSeek(xFilial("T56") + aIdOld[nX] ))
						RecLock("T56",.F.)
						dbDelete()
						MsUnLock()
					EndIf
				Next nX
			EndIf
			
			If(oModel:GetOperation() == MODEL_OPERATION_DELETE)
				DbSelectArea("T57")
				T57->(DbSetOrder(1))
				
				IF T57->(DbSeek( xFilial("T57") + cId ))				
					RecLock("T56",.F.)
					T56->(DBRecall())
					MsUnLock()				
				EndIf
			EndIf
		
		EndIf
		End Transaction	
 	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFPosValid

Função para realizar a posvalidação do modelo.

oModel - Modelo

@return .T.

@author Rafael Völtz
@since 10/10/2016
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAFPosValid(oModel as object)
	
	If oModel:GetOperation() != MODEL_OPERATION_DELETE
		If (M->T56_DTINI > M->T56_DTFIN)
			Help(,,'HELP',,STR0003,1,0)
			Return .F.
		EndIf
		
		If !TAFPreValid(oModel)
			Help(,,'HELP',,STR0017 + " (" + Alltrim(cDescObrg) + ")",1,0)
			Return .F.
		EndIf
	EndIf
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFPreValid

Função para realizar a pre-validação do modelo.

oModel - Modelo

@return .T.

@author Rafael Völtz
@since 10/10/2016
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAFPreValid(oModel as object)

 Local cAliasPre    as char
 Local lRet         as numeric
 
 lRet := .T.
 
	If (oModel:GetOperation() == MODEL_OPERATION_INSERT) .OR.          ;	    
	    (oModel:GetOperation() == MODEL_OPERATION_UPDATE .AND.         ;
	     (T56_DTINI != 	oModel:GetValue("MODEL_T56","T56_DTINI") .OR.  ;
	      T56_DTFIN !=  oModel:GetValue("MODEL_T56","T56_DTFIN") .OR.  ;
	      T56_IDUF  !=  oModel:GetValue("MODEL_T56","T56_IDUF")))
		
		cAliasPre := GetNextAlias()
		
		BeginSql Alias cAliasPre
			SELECT count(*) QTD
			  FROM %table:T56% T56
			  INNER JOIN %table:T57% T57 ON T57.T57_FILIAL = T56.T56_FILIAL AND T57.T57_ID = T56.T56_ID  
			  INNER JOIN %table:T55% T55 ON T55.T55_FILIAL = %xFilial:T55%  AND T55.T55_IDCHAV = T57.T57_IDCHAV			  
			 WHERE T56.T56_FILIAL = %xFilial:T56%
			   AND T56.T56_DTINI  = %Exp:DTOS(oModel:GetValue("MODEL_T56","T56_DTINI"))%
			   AND T56.T56_DTFIN  = %Exp:DTOS(oModel:GetValue("MODEL_T56","T56_DTFIN"))%
			   AND T56.T56_IDUF   = %Exp:Alltrim(oModel:GetValue("MODEL_T56","T56_IDUF"))%
			   AND T55.T55_IDOBRG = %Exp:cIDobrg%
			   AND T56.%NotDel%
			   AND T57.%NotDel%
			   AND T55.%NotDel%			
		EndSql		
		
		If (cAliasPre)->QTD > 0			
			lRet := .F.
		EndIf
		
		(cAliasPre)->(DbCloseArea())
		
	EndIf
Return lRet
 
