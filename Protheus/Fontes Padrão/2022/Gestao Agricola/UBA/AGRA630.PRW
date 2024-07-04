#INCLUDE "AGRA630.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"

Static lAutMala	  := SuperGetMv("MV_AGRMALA", ,.T.)
Static nQtdMl 	  := SuperGetMV("MV_AGRQTML", ,50)
Static lTemCodBar := .F.
Static __lnewComerc	:= SuperGetMv('MV_AGRA001', , .F.) // Parametro novo modelo de comercialização

/** -------------------------------------------------------------------------------------
{Protheus.doc} AGRA630
Cadastro de Romaneio classificação

@author Aécio Ferreira Gomes
@since 02/11/2012
@version 1.0
-------------------------------------------------------------------------------------- **/
Function AGRA630()
	Local cFilDef 	  := ""
	Local aCampos   := {'DXJ_CODIGO', 'DXJ_TIPO'  ,'DXJ_DATA', 'DXJ_CODCLA', 'DXJ_NOMCLA','DXJ_CODCNJ' ,'DXJ_SAFRA'  , 'DXJ_PRDTOR',; 
	'DXJ_LJPRO' , 'DXJ_NMPDTR', 'DXJ_FAZ', 'DXJ_NMFAZ' , 'DXJ_CODVAT', 'DXJ_DESVAR','DXJ_FRDINI', 'DXJ_FRDFIM' }
    Local aDados    := {}
	Private oBrowse   := Nil
	Private cClasVis  := SPACE(TAMSX3("DXK_CLAVIS")[1])
	Private oSizeClss
	Private oClas
	Private cUserBenf := A655GETUNB( )
	Private cValClass := ""

	//Totalizadores
	Private nTotFardos := 0
	Private nTotClsVis := 0
	Private nTotBruto  := 0
	Private nTotLiquid := 0

	Static oOK	   		:= LoadBitmap(GetResources(),'LBOK')
	Static oNo     		:= LoadBitmap(GetResources(),'LBNO')
	Static lMarcAllE	:= .T.
	Static lMarcAllD	:= .T.
	
	If !DXK->(ColumnPos('DXK_TIPO')) > 0	
		lAutMala := .F.
	endIf		

	If DXJ->(ColumnPos('DXJ_CODBAR')) > 0
		lTemCodBar := .T.
	endIf
	cFilDef := " DXJ_CODUNB = '" + cUserBenf + "' "	
	If ExistBlock('AGRA630CPO')
		aRet :=  ExecBlock('AGRA630CPO',.F.,.F.,aCampos) 
		If ValType(aRet) == 'A'
			aCampos	:= aClone(aRet)
		EndIf
	EndIf

	//--------------------------
	//Instancia o objeto Browse 
	//--------------------------
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DXJ')
	oBrowse:SetDescription( STR0001 ) //"Cadastro de Mala"
	oBrowse:SetOnlyFields(aCampos)

	If !Empty(cUserBenf)
		oBrowse:SetFilterDefault( cFilDef )
	Endif
	//-------------------
	// Adiciona legendas
	//-------------------



	If __lnewComerc
		oBrowse:AddLegend( "DXJ_STATUS = '7'"	, "ORANGE"		, STR0067 ) //"Aberta"
		oBrowse:AddLegend( "DXJ_STATUS = '1'"	, "GREEN"		, STR0002 ) //"Visual Pendente"
		oBrowse:AddLegend( "DXJ_STATUS = '2'"	, "YELLOW"		, STR0003 ) //"Visual Parcial"
		oBrowse:AddLegend( "DXJ_STATUS = '3'"	, "RED"			, STR0004 ) //"Visual Classificado"
		oBrowse:AddLegend( "DXJ_STATUS = '4'"	, "WHITE"		, STR0047 ) //"HVI Pendente"
		oBrowse:AddLegend( "DXJ_STATUS = '5'"	, "BLUE"		, STR0048 ) //"HVI Parcial"
		oBrowse:AddLegend( "DXJ_STATUS = '6'"	, "BLACK"		, STR0049 ) //"HVI Importado"
		oBrowse:AddLegend( "DXJ_STATUS = '8'"	, "PINK"		, STR0089 ) //"Bloqueada"
		//Acerta código único nos registros que estiverem vazios
		If DXJ->(ColumnPos('DXJ_CODBAR')) > 0
			AGRA630CDU()
		EndIf	
	Else
		oBrowse:AddLegend( "DXJ->DXJ_STATUS == '1'"	, "GREEN"		, STR0002 ) //"Visual Pendente"
		oBrowse:AddLegend( "DXJ->DXJ_STATUS == '2'"	, "YELLOW"		, STR0003 ) //"Visual Parcial"
		oBrowse:AddLegend( "DXJ->DXJ_STATUS == '3'"	, "RED"			, STR0004 ) //"Visual Classificado"
		oBrowse:AddLegend( "DXJ->DXJ_STATUS == '4'"	, "WHITE"		, STR0047 ) //"HVI Pendente"
		oBrowse:AddLegend( "DXJ->DXJ_STATUS == '5'"	, "BLUE"		, STR0048 ) //"HVI Parcial"
		oBrowse:AddLegend( "DXJ->DXJ_STATUS == '6'"	, "BLACK"		, STR0049 ) //"HVI Importado"
	EndIf


	//----------------
	// Ativa o Browse
	//----------------
	oBrowse:Activate()

Return NIL

/** -------------------------------------------------------------------------------------
{Protheus.doc} MenuDef
Menu Padrao da Rotina

@author Aécio Gomes
@since 02/11/2012
@version 1.0
-------------------------------------------------------------------------------------- **/
Static Function MenuDef()
	Local aRotina := {}

	If __lnewComerc
		ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.AGRA630' OPERATION 2  ACCESS 0  //"Visualizar"
		ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.AGRA630' OPERATION 3  ACCESS 0  //"Incluir"
		ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.AGRA630' OPERATION 4  ACCESS 0  //"Alterar"
		ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.AGRA630' OPERATION 5  ACCESS 0  //"Excluir"
		ADD OPTION aRotina Title STR0010 Action "A630UPDATE" 	  OPERATION 6  ACCESS 0  //"Classificar"
		ADD OPTION aRotina Title STR0095 Action "A630CONFER" 	  OPERATION 6  ACCESS 0  //"Conferência"
		ADD OPTION aRotina Title STR0011 Action 'AGRAR630'        OPERATION 7  ACCESS 0	 //"Imprimir mala"

		If lTemCodBar
			ADD OPTION aRotina Title STR0094 Action 'AGRA630BLR()'    OPERATION 12 ACCESS 0	 //"Imprimir etiqueta"
		endIf

		ADD OPTION aRotina Title STR0086 Action 'AGRAR630A'       OPERATION 8  ACCESS 0	 //"Imprimir com codigo de barras"
		ADD OPTION aRotina Title STR0090 Action 'A630LibMl'       OPERATION 9  ACCESS 0	 //"Liberar Mala"

		If(lAutMala)
			ADD OPTION aRotina Title STR0064 Action 'A630FchMl'   OPERATION 10 ACCESS 0	//"Fechar Mala"
			ADD OPTION aRotina Title STR0065 Action 'A630HistMl'  OPERATION 11 ACCESS 0	//"Histórico Mala"
		EndIf
	Else
		ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.AGRA630' OPERATION 2 ACCESS 0   //"Visualizar"
		ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.AGRA630' OPERATION 3 ACCESS 0   //"Incluir"
		ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.AGRA630' OPERATION 4 ACCESS 0   //"Alterar"
		ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.AGRA630' OPERATION 5 ACCESS 0   //"Excluir"
		ADD OPTION aRotina Title STR0010 Action "A630UPDATE" 	  OPERATION 4 ACCESS 0 	//"Classificar"
		ADD OPTION aRotina Title STR0011 Action 'AGRAR630'        OPERATION 8 ACCESS 0	//"Imprimir"
	EndIf
Return aRotina

/** -------------------------------------------------------------------------------------
{Protheus.doc} ModelDef
Modelo de dados da rotina

@author Aécio Gomes
@since 02/11/2012
@version 1.0
-------------------------------------------------------------------------------------- **/
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruDXJ 	:= FwFormStruct( 1, "DXJ" )//Malas
	Local oStruDXK 	:= FwFormStruct( 1, "DXK" )//Itens da Mala

	//----------------------------
	// Intancia o Modelo de dados
	//----------------------------
	oModel := MPFormModel():New( 'AGRA630',{ |oModel| AGRA630PRE( oModel ) }, /*bPos*/,{ |oModel| AGRA630GRV( oModel ) } , /*bCancel*/ )
	oModel:SetDescription( STR0012 ) //"Modelo de dados da Mala"
	oStruDXJ:SetProperty( 'DXJ_STATUS' , MODEL_FIELD_WHEN  	, {||.F.})	
	//----------------------------
	// Adiciona estrutura do Field
	//----------------------------
	oModel:AddFields( 'MdFieldDXJ', /*cOwner*/, oStruDXJ )
	oModel:GetModel('MdFieldDXJ'):SetDescription( STR0013 ) //"Dados da Mala"

	//----------------------------
	// Adiciona estrutura da grid
	//----------------------------
	oModel:AddGrid( 'MdGridDXK', 'MdFieldDXJ', oStruDXK, {|oMdGrid,nLinha,cAction| PreLinha(oMdGrid,nLinha,cAction)},{|oModel| PosLinha(oModel)})
	oModel:GetModel('MdGridDXK'):SetDescription( STR0014 ) //"Dados dos Itens da Mala"

	//---------------------------------
	// Aumenta Limite de Linhas no grid 
	//---------------------------------
	oModel:getModel('MdGridDXK'):SetMaxLine(5000)

	//------------------
	// adiciona calculo 
	//------------------
	oModel:AddCalc( 'AGRA630CALC', 'MdFieldDXJ', 'MdGridDXK', 'DXK_ETIQ'  , 'TOTFDI'  	,'COUNT',{||.t.},,STR0015 ) //'Total Fardos'
	oModel:AddCalc( 'AGRA630CALC', 'MdFieldDXJ', 'MdGridDXK', 'DXK_ETIQ'  , 'TOTCLA'	,'COUNT',{ |oCalc| !Empty(FwFldGet("DXK_CLAVIS") ) },,STR0016 ) //'Total Clas. Visual'
	oModel:AddCalc( 'AGRA630CALC', 'MdFieldDXJ', 'MdGridDXK', 'DXK_PSLIQU', 'TOTLIQU'	,'SUM'  ,{||.t.},,STR0017 ) //'Total Líquido'
	oModel:AddCalc( 'AGRA630CALC', 'MdFieldDXJ', 'MdGridDXK', 'DXK_PSBRUT', 'TOTBRUTO' 	,'SUM'  ,{||.t.},,STR0068 )


	//---------------------
	// Seta Relacionamento 
	//---------------------
	If DXK->(ColumnPos('DXK_TIPO')) > 0
		oModel:SetRelation( 'MdGridDXK', { { 'DXK_FILIAL', 'xFilial("DXK")' }, { 'DXK_CODROM', 'DXJ_CODIGO' }, { 'DXK_TIPO', 'DXJ_TIPO' } }, DXK->( IndexKey(1)))
	else
		oModel:SetRelation( 'MdGridDXK', { { 'DXK_FILIAL', 'xFilial("DXK")' }, { 'DXK_CODROM', 'DXJ_CODIGO' } }, DXK->( IndexKey(1)))
	endIf

	// Ativa o Grid como Opcional
	oModel:GetModel('MdGridDXK'):SetOptional( .T. )
	//-------------------------------------
	// Valida a ativação do model
	//-------------------------------------
	
	oModel:SetVldActivate( { |oModel| A630VLDACT( oModel ) } )
	
Return oModel

/** -------------------------------------------------------------------------------------
{Protheus.doc} ViewDef
View (tela) da rotina Cadastro de Mala

@author Aécio Gomes
@since 02/11/2012
@version 1.0
-------------------------------------------------------------------------------------- **/
Static Function ViewDef()
	Local oView    := Nil
	Local oCalc    := Nil
	Local oModel   := FwLoadModel( "AGRA630" )
	Local oStruDXJ := FwFormStruct( 2, "DXJ")	// Mala
	Local oStruDXK := FWFormStruct( 2, "DXK")	// Itens da Mala

	//-------------------------------------------
	// Remove campos da estrurura da view
	//-------------------------------------------
	If !Empty(cUserBenf)
		oStruDXJ:RemoveField( "DXJ_CODUNB" )
	Endif
	If __lnewComerc
		oStruDXJ:RemoveField('DXJ_DATATU')
		oStruDXJ:RemoveField('DXJ_HORATU')
	EndIf

	oStruDXK:RemoveField( 'DXK_CODVAR' )
	oStruDXK:RemoveField( 'DXK_DESTAL' )

	//-----------------
	// Instacia a View
	//-----------------
	oView := FwFormView():New()
	oView:SetModel( oModel )

	//-----------------------
	// Instacia FwCalEstruct
	//-----------------------
	oCalc := FWCalcStruct( oModel:GetModel( 'AGRA630CALC') )

	//-------------------------------------------
	// Adiciona estrutura do Field, Grid e rodape
	//-------------------------------------------
	oView:AddField( 'VIEW_DXJ', oStruDXJ , 'MdFieldDXJ' )
	oView:AddGrid( 'VIEW_DXK', oStruDXK , 'MdGridDXK' )
	oView:AddField( 'VIEW_CALC', oCalc , 'AGRA630CALC' )

	//----------
	// Cria Box 
	//----------
	oView:CreateHorizontalBox( 'HEADER', 30 )
	oView:CreateHorizontalBox( 'GRID', 60)
	oView:CreateHorizontalBox( 'RODAPE', 100 ,,.T.)

	// Quebra em 2 "box" vertical para receber algum elemento da view
	oView:CreateVerticalBox( 'RODAPEESQ', 25, 'RODAPE' )
	oView:CreateVerticalBox( 'RODAPEDIR', 75, 'RODAPE' )

	// Adciciona outros objetos
	oView:AddOtherObject("VIEW_ETIQ", {|oPanel| A630CLASS(oPanel)})

	//-----------
	// Seta Owner
	//-----------
	oView:SetOwnerView( 'VIEW_DXJ' ,'HEADER' )
	oView:SetOwnerView( 'VIEW_DXK' ,'GRID' )
	oView:SetOwnerView( 'VIEW_CALC','RODAPEDIR' )

	// Associa ao box que ira exibir os outros objetos
	oView:SetOwnerView("VIEW_ETIQ",'RODAPEESQ')

	// Adiciona Botoes
	oView:AddUserButton( STR0018 , '', {|oView| AGRA630I(oView)} ) //"Incluir Fardos"

	//--------------------------------------------------
	// Desabilita edição para todos os campos do modelo
	//--------------------------------------------------
	oStruDXK:SetProperty( '*', MVC_VIEW_CANCHANGE, .F.)
	If __lnewComerc
		//---------------------------------------------------------------------
		// Caso seja classificação permite alterar o tipo da classificação
		//---------------------------------------------------------------------
		If FwIsInCallStack("A630CONFER") 
			oStruDXK:SetProperty( 'DXK_TIPCON'	, MVC_VIEW_CANCHANGE, .T.)
			oStruDXK:SetProperty( 'DXK_CLACON'	, MVC_VIEW_CANCHANGE, .T.)	
		Else 
			oStruDXJ:SetProperty( 'DXJ_CODCLA'	, MVC_VIEW_CANCHANGE, .F.)
			oStruDXK:SetProperty( 'DXK_TIPCON'	, MVC_VIEW_CANCHANGE, .F.)
			oStruDXK:SetProperty( 'DXK_CLACON'	, MVC_VIEW_CANCHANGE, .F.)
		EndIf
	EndIf
	If FwIsInCallStack("A630UPDATE")
		oStruDXK:SetProperty( 'DXK_CLAVIS'	, MVC_VIEW_CANCHANGE, .T.)
		oStruDXJ:SetProperty( 'DXJ_CODCLA'	, MVC_VIEW_CANCHANGE, .T.)
	EndIf	
Return oView

/*/{Protheus.doc} AGRA630CDU
//Função faz acerto do código único nos registros que estiverem vazios
@author marina.muller
@since 12/12/2017
@return ${return}, ${return_description}

@type function
/*/
Static Function AGRA630CDU()
	Local lRet		  := .T.
	Local aSaveArea   := GetArea()
	Local cAliasDXJ   := GetNextAlias()	
	Local cCodUni     := ""

	BeginSql Alias cAliasDXJ
	SELECT DXJ_FILIAL, DXJ_SAFRA, DXJ_CODIGO, DXJ_TIPO
	FROM %Table:DXJ% DXJ
	WHERE DXJ.%NotDel%
	  AND (DXJ.DXJ_CODBAR IS NULL
	   OR  DXJ.DXJ_CODBAR = '')
	EndSQL
    
    (cAliasDXJ)->(dbGoTop())
    While (cAliasDXJ)->(!Eof())
    	// gera código único para registro
    	cCodUni := AGRSmartCode("DXJ", (cAliasDXJ)->DXJ_SAFRA, (cAliasDXJ)->DXJ_CODIGO, (cAliasDXJ)->DXJ_TIPO, "ML") 
        
        dbSelectArea('DXJ')
        dbSetOrder(3)    	
    	If MsSeek((cAliasDXJ)->DXJ_FILIAL+(cAliasDXJ)->DXJ_SAFRA+(cAliasDXJ)->DXJ_CODIGO+(cAliasDXJ)->DXJ_TIPO)
	    	RecLock("DXJ",.F.)
	    	DXJ->DXJ_CODBAR := cCodUni 
	    	MsUnLock()
	    EndIf	
    	
    	(cAliasDXJ)->(dbSkip())
    EndDo
    (cAliasDXJ)->( dbCloseArea() )
    RestArea( aSaveArea )
	
Return lRet

/** -------------------------------------------------------------------------------------
{Protheus.doc} PreLinha
Pré-Validação da linha

@Param	oMdGridDXK 	- Modelo de dados FormGrid
nLinha 		- Linha Corrente
cAction 	- Ação da linha

@author Aécio Gomes
@since 09/04/2013
@version 1.0
-------------------------------------------------------------------------------------- **/
Static Function PreLinha(oMdGridDXK,nLinha,cAction)
	Local lRet 	:= .T.
	Local aArea := GetArea()

	//----------------------------------
	// Valida se o fardo ja foi blocado
	//----------------------------------
	If cAction == "DELETE"
		dbSelectArea("DXI")
		DXI->(dbSetOrder(1))
		If FwFldGet('DXJ_TIPO') == "1"
			If DXI->(dbSeek(FWxFilial("DXI")+oMdGridDXK:GetValue("DXK_SAFRA",nLinha)+oMdGridDXK:GetValue("DXK_ETIQ",nLinha)))
				If !Empty(DXI_BLOCO)
					lRet := .F.
					Help("",1,STR0019,, STR0020,1,0) //"Atenção"###"Não será permitido excluir a linha, pois este fardo já foi blocado."
				EndIf
			EndIf
		EndIf
		DXI->(dbCloseArea())
	EndIf
	If __lnewComerc
		If !FwIsInCallStack("A630CONFER") 
			If !Empty(cClasVis)
				lRet := oMdGridDXK:LoadValue("DXK_CLAVIS",cClasVis)
			EndIf
		EndIf
	Else
		If !Empty(cClasVis)
			lRet := oMdGridDXK:LoadValue("DXK_CLAVIS",cClasVis)
		EndIf
	EndIf

	RestArea(aArea)
Return(lRet)

/** -------------------------------------------------------------------------------------
{Protheus.doc} PosLinha
Pós-Validação da linha

@Param	oMdGridDXK 	- Modelo de dados FormGrid
nLinha 		- Linha Corrente
cAction 	- Ação da linha

@author Tiago Filipe
@since 22/05/2014
@version 1.0
-------------------------------------------------------------------------------------- **/

Function PosLinha(oModel)
	If oModel:GetValue("DXK_CLAVIS") != cClasVis
		cClasVis := oModel:GetValue("DXK_CLAVIS")
		oClas:Refresh()
	EndIf

Return .T.


/** {Protheus.doc} A630UPDATE

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Maicol Lange
@since: 	20/07/2015
@Uso: 		AGRA630 
Abre a tela em modo de edição para efetuar classificação
*/
Function A630UPDATE( )
	if DXJ->DXJ_TIPO == "1" //Somente Classificação VIsual 
		FWExecView('', 'VIEWDEF.AGRA630', MODEL_OPERATION_UPDATE	, , {|| .T. })
	else
		Help("",1,STR0019,, STR0093 ,1,0) //"ATENÇÃO"###"Somente é possível realizar a classificação de Malas do tipo Visual."
	endif		
Return .T.


/** {Protheus.doc} A630CONFER

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Ana Laura Olegini
@since: 	02/08/2018
@Uso: 		AGRA630 
Abre a tela em modo de edição para efetuar a conferência
*/
Function A630CONFER( )
	If DXJ->DXJ_TIPO == "1" //Somente Classificação VIsual 
		FWExecView('', 'VIEWDEF.AGRA630', MODEL_OPERATION_UPDATE	, , {|| .T. })
	Else
		Help("",1,STR0019,, STR0096 ,1,0) //"ATENÇÃO"###"Somente é possível realizar a conferência de Malas do tipo Visual."
	EndIf		
Return .T.


/** -------------------------------------------------------------------------------------
{Protheus.doc} A630VLDACT
Validação a inicialização do modelo de dados

@param:  Nil
@author: Aecio Ferreira Gomes
@since:  08/11/2012
@Uso:    AGRA630
-------------------------------------------------------------------------------------- **/
Static Function A630VLDACT(oModel)
	Local lRet 		:= .T.
	If __lnewComerc
	If !FWIsInCallStack("AGRA680")
		If !FWIsInCallStack("A630UPDATE") .AND. !FWIsInCallStack("A630CONFER") 
			If DXJ->DXJ_STATUS = '8' /* Bloqueada */ .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE 
			   oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0088, "", "", "") // "Alterar a mala somente é possível em status Aberta ou Visual Pendente"
			Endif
		
			If !Empty(cUserBenf)
				//Valida permisão de usuario por unidade de beneficiamento
				if(lRet) .AND. oModel:GetOperation() !=  MODEL_OPERATION_VIEW 
					lRet:= A665VALID()
				endif
			Endif
			
			if lRet .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE
				If DXJ->DXJ_STATUS != '1' .And. DXJ->DXJ_STATUS != '4' .And. DXJ->DXJ_STATUS != '7' // '1' = Visual Pendente ; '4' = 'HVI Pendente ; Status '7' = Aberta ; 
					oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0088, "", "", "") // "Alterar a mala somente é possível em status Aberta ou Visual Pendente"
					lRet := .F.
				EndIf
			endif
		Else
			If DXJ->DXJ_STATUS = '8' /* Bloqueada */  
			   oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0088, "", "", "") // "Alterar a mala somente é possível em status Aberta ou Visual Pendente"
			Endif
			
			If AliasIndic('N73')
			 	dbSelectArea('N73')
			 	N73->(dbSetOrder(2))
			 	If N73->(MsSeek(FwXFilial('N73')+DXJ->DXJ_SAFRA+DXJ->DXJ_CODIGO+DXJ->DXJ_TIPO) .And. Empty(DXJ->DXJ_USRREC))
			 		lRet := .F.
			 		Help('', 1, STR0080, , STR0081, 1 )
				Endif 
			Endif
		Endif
	endIf
	Else
		If !Empty(cUserBenf)

			If !isInCallStack("A630UPDATE")
				//Valida permisão de usuario por unidade de beneficiamento
				if(lRet) .AND. oModel:GetOperation() !=  MODEL_OPERATION_VIEW 
					lRet:= A665VALID()
				endif
			Endif
		Endif	
	EndIf

Return(lRet)

/** -------------------------------------------------------------------------------------
{Protheus.doc} AGRA630PRE
Validação da confirmação dos dados da janela, impede o fechamento 
da janela.

@author Bruna Rocio
@since 25/07/2015
@version 1.0
-------------------------------------------------------------------------------------- **/
Static Function AGRA630PRE()
	Local lRet    := .t.
	Local oModel  := FwModelActive()
	Local nOperac := oModel:GetOperation()

	//Campo Unidade de Beneficiamento
	If nOperac == MODEL_OPERATION_INSERT .And. !Empty(cUserBenf)
		oModel:LoadValue( "MdFieldDXJ", "DXJ_CODUNB", cUserBenf )
	Endif

Return (lRet)


/*/{Protheus.doc} InvertStatus
//Inverte o status para o correspondente da mala do tipo contrário
@author bruna.rocio
@since 28/02/2017
@version undefined
@param cStatus, characters, descricao
@type function
/*/
Static Function InvertStatus(cStatus)
	Local cRetorno := ""
	
	Do Case
		Case cStatus = '1' //Pendente Visual
			cRetorno := '4'
		Case cStatus = '2' //Parcial Visual
			cRetorno := '5'
		Case cStatus = '3' //Classificado Visual
			cRetorno := '6'
		Case cStatus = '4' //Pendente HVI
			cRetorno := '1'
		Case cStatus = '5' //Parcial HVI
			cRetorno := '2'
		Case cStatus = '6' //Importado HVI
			cRetorno := '3'
		Case cStatus = '7' //Aberto
			cRetorno := '7'
		Case cStatus = '8' //Bloqueada
			cRetorno = '8'	
	EndCase	
	
Return cRetorno

/*/{Protheus.doc} DelMala
//Função para exclusão da mala par
@author bruna.rocio
@since 27/02/2017
@version undefined
@param cCodigo, characters, descricao
@param cTipo, characters, descricao
@type function
/*/
Static Function DelMala(cCodigo, cTipo)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	//Deleta os fardos/amostras relacionadas
	dbSelectArea('DXK')
	DXK->(dbSetOrder(1))
	If DXK->(dbSeek(FwXFilial('DXK')+cCodigo+cTipo))
		If DXK->(ColumnPos('DXK_TIPO')) > 0		
			While DXK->(!Eof())           .And. ;
				DXK->DXK_CODROM = cCodigo .And. ;
				DXK->DXK_TIPO   = cTipo
				
				A630RetSta(DXK->DXK_SAFRA,DXK->DXK_ETIQ)
				
				If RecLock('DXK',.F.)
					dbDelete()
					MsUnlock()
				Endif
				
				DXK->(dbSkip())
			EndDo
		else
			While DXK->(!Eof())           .And. ;
				DXK->DXK_CODROM = cCodigo 
				
				If RecLock('DXK',.F.)
					dbDelete()
					MsUnlock()
				Endif
				
				DXK->(dbSkip())
			EndDo
		endIf
	Endif
	
	DXK->(dbCloseArea())
	
	//Deleta a mala
	dbSelectArea('DXJ')
	DXJ->(dbSetOrder(1))
	If DXJ->(MsSeek(FwXFilial('DXJ')+cCodigo+cTipo))
			
		If RecLock('DXJ',.F.)
			dbDelete()
			MsUnlock()
		Endif
	Endif
	
	DXJ->(dbCloseArea())

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} EspelhaMala
//Função utilizada para espelhar as informações da mala no seu par no caso de alterações
@author bruna.rocio
@since 27/02/2017
@version undefined
@param oModel, object, modelo da mala
@param cTipo, characters, tipo da mala espelho
@type function
/*/
Static Function EspelhaMala(oModel, cTipo)
	Local aArea := GetArea()
	Local lRet  := .T.
	Local oDXJ  := oModel:GetModel('MdFieldDXJ')
	Local oDXK  := oModel:GetModel('MdGridDXK')
	Local nX
		
	//Atualiza Cabeçalho
	dbSelectArea('DXJ')
	DXJ->(dbSetOrder(1))
	If DXJ->(MsSeek(FwXFilial('DXJ')+oDXJ:GetValue('DXJ_CODIGO')+cTipo))
		
		If RecLock('DXJ',.F.)
			
			// Informa a data e hora de atualização para realizar a alteração/inclusão/deleção da mala
			// no aplicativo do Beneficiamento			
			If DXJ->DXJ_STATUS != InvertStatus(oDXJ:GetValue('DXJ_STATUS')) .AND. !Empty(DXJ->DXJ_DATENV)
				DXJ->DXJ_DATATU	:= dDatabase
				DXJ->DXJ_HORATU := TIME()
			EndIf
		
			DXJ->DXJ_QTVINC := oDXJ:GetValue('DXJ_QTVINC')
			DXJ->DXJ_FAZ    := oDXJ:GetValue('DXJ_FAZ')
			DXJ->DXJ_STATUS := InvertStatus(oDXJ:GetValue('DXJ_STATUS'))
			DXJ->DXJ_CODCNJ := oDXJ:GetValue('DXJ_CODCNJ')
			DXJ->DXJ_CODVAR := oDXJ:GetValue('DXJ_CODVAR')		
			MsUnlock()
		Endif				
	Endif	
	
	DXJ->(dbCloseArea())
	
	//Atualiza fardos/amostras relacionadas
	For nX := 1 to oDXK:Length()
		oDXK:GoLine(nX)
		
		If oDXK:IsDeleted()
			dbSelectArea('DXK')
			DXK->(dbSetOrder(1))
			If DXK->(MsSeek(FwXFilial('DXK')+oDXJ:GetValue('DXJ_CODIGO')+cTipo+oDXJ:GetValue('DXJ_SAFRA')+oDXK:GetValue('DXK_ETIQ')))
				
				If RecLock('DXK',.F.)
					dbDelete()
					MsUnlock()
					
					A630RetSta(oDXJ:GetValue('DXJ_SAFRA'),oDXK:GetValue('DXK_ETIQ'))
				Endif
			Endif
			DXK->(dbCloseArea())
		Else
			dbSelectArea('DXK')
			DXK->(dbSetOrder(1))
			If !DXK->(MsSeek(FwXFilial('DXK')+oDXJ:GetValue('DXJ_CODIGO')+cTipo+oDXJ:GetValue('DXJ_SAFRA')+oDXK:GetValue('DXK_ETIQ')))
				
				If RecLock('DXK',.T.)
					DXK->DXK_FILIAL := FwXFilial('DXK')
					DXK->DXK_CODROM := oDXJ:GetValue('DXJ_CODIGO')
					
					If DXK->(ColumnPos('DXK_TIPO')) > 0	
						DXK->DXK_TIPO   := cTipo
					endIf
					
					DXK->DXK_SAFRA  := oDXJ:GetValue('DXJ_SAFRA')
					DXK->DXK_ETIQ   := oDXK:GetValue('DXK_ETIQ')
					DXK->DXK_FARDO  := oDXK:GetValue('DXK_FARDO')
					DXK->DXK_CODVAR := oDXK:GetValue('DXK_CODVAR')
					DXK->DXK_PSLIQU := oDXK:GetValue('DXK_PSLIQU')
					DXK->DXK_PSBRUT := oDXK:GetValue('DXK_PSBRUT')
					DXK->DXK_TALHAO := oDXK:GetValue('DXK_TALHAO')
					MsUnlock()
					
					A630AtuSta(oDXJ:GetValue('DXJ_SAFRA'),oDXK:GetValue('DXK_ETIQ'))
				Endif					
			Endif
			DXK->(dbCloseArea())
		Endif	
	Next nX
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} ExistMalaClone
//Verifica se existe mala espelho
@author bruna.rocio
@since 27/02/2017
@version undefined
@param cCodigo, characters, código da mala
@param cTipo, characters, tipo da mala espelho
@type function
/*/
Static Function ExistMalaClone(cCodigo, cTipo, lAberta)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	dbSelectArea('DXJ')
	DXJ->(dbSetOrder(1))
	If DXJ->(MsSeek(FwXFilial('DXJ')+cCodigo+cTipo))
		lRet := .T.
		lAberta := (DXJ->DXJ_STATUS = '7')
	Else
		lRet    := .F.
		lAberta := .F.
	Endif
	DXJ->(dbCloseArea())
	
	RestArea(aArea)
Return lRet

/** -------------------------------------------------------------------------------------
{Protheus.doc} AGRA630GRV
Validação da confirmação dos dados da janela, impede o fechamento 
da janela.

@author Aécio Gomes
@since 02/11/2012
@version 1.0
-------------------------------------------------------------------------------------- **/
Static Function AGRA630GRV()
	Local oModel      	:= FwModelActive()
	Local oAuxDXK	    := oModel:GetModel('MdGridDXK')
	Local aArea			:= GetArea()
	Local lClass	   	:= .F.
	Local lDeleted		:= .F.
	Local lNoClass 		:= .F.
	Local lRet 			:= .T.
	Local nOperac	   	:= oModel:GetOperation()
	Local nX		   	:= 0
	Local lClasHVI      := .F.
	Local nHVI          := 0
	Local nQtdVinc		:= 0	
	Local nQuantTemp    := 0
	Local lForaSeq      := .F.
	Local nIniFardo     := Val(oModel:GetModel('MdFieldDXJ'):GetValue("DXJ_FRDINI"))
	Local nFimFardo     := Val(oModel:GetModel('MdFieldDXJ'):GetValue("DXJ_FRDFIM"))	
	Local oModelDXJ     := oModel:GetModel('MdFieldDXJ')	
	Local lNoConf		:= .F.
	Local lSiConf		:= .F.
	Local lGrava		:= .T.
	If __lnewComerc			
		If !IsInCallStack("AGRA615")

			/****************************************************
			** Validação dentro do AGRA630GRV, pois, se por no 
			** AGRA630POS a mensagem é apresentada em mais locais
			** não apenas na validação final 
			** ps: idenficado em testes
			****************************************************/
			If nOperac = 4 //Alteração
				If lAutMala .And. (oModel:GetValue("MdFieldDXJ","DXJ_AUTOMA") == "1") 
					For nX := 1 To oAuxDXK:Length()
						oAuxDXK:Goline( nX )

						If !oAuxDXK:IsDeleted()

							If Val(oAuxDXK:GetValue("DXK_FARDO")) < nIniFardo .Or.;
							Val(oAuxDXK:GetValue("DXK_FARDO")) > nFimFardo
								DbSelectArea("DXK")
								DXK->(DbSetorder(1))

								If DXK->(ColumnPos('DXK_TIPO')) > 0	
									If !(DXK->(MsSeek(FWxFilial("DXK") + DXJ->DXJ_CODIGO + oAuxDXK:GetValue("DXK_TIPO") + oAuxDXK:GetValue("DXK_SAFRA") + oAuxDXK:GetValue("DXK_ETIQ"))))
										lForaSeq := .T.
										Exit
									EndIf
								else
									If !(DXK->(MsSeek(FWxFilial("DXK") + DXJ->DXJ_CODIGO + oAuxDXK:GetValue("DXK_SAFRA") + oAuxDXK:GetValue("DXK_ETIQ"))))
										lForaSeq := .T.
										Exit
									EndIf
								endIf

								DXK->(dbCloseArea())
							Endif
						Endif

					Next nX							

					If oAuxDXK:Length(.T.) > SuperGetMV("MV_AGRQTML", ,50)
						lRet := .F.
						//#Erro#Numero de amostras superou o estipulado no parametro#Ajustar a quantidade de amostras
						oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), , STR0076, STR0077, STR0078, "", "")
					Endif
				EndIf			
			Endif

			/****************************************************/

			If lRet
				Begin Transaction
					DXI->(dbSetOrder(1))

					// Atualiza tabela DXI com as classificações dos fardos.
					For nX := 1 To  oAuxDXK:Length()
						oAuxDXK:Goline( nX )

						//Romaneio do tipo HVI
						If oModel:GetValue("MdFieldDXJ","DXJ_TIPO") = "2"
							// HVI 
							If  nOperac == 3
								If !AGRIFDBSEEK("DX7",FwFldGet('DXJ_SAFRA')+oAuxDXK:GetValue("DXK_ETIQ"),2,.F.)
									oModel:SetValue("MdFieldDXJ","DXJ_STATUS","4") // HVI Pendente
								Else
									If oModel:GetValue("MdFieldDXJ","DXJ_STATUS") < "5"
										oModel:SetValue("MdFieldDXJ","DXJ_STATUS","5") // HVI Parcial
									Endif	
								Endif
							ElseIf nOperac == 4 
								If AGRIFDBSEEK("DX7",FwFldGet('DXJ_SAFRA')+oAuxDXK:GetValue("DXK_ETIQ"),2,.F.)
									oModel:SetValue("MdFieldDXJ","DXJ_STATUS","4") // HVI Pendente
									lClasHVI := .T.
									nHVI += 1 
								Else
									lClasHVI := .F.
								Endif
							Endif	
						Endif

						// Se operação de inlcusão 
						If nOperac == 3
							Loop
						EndIf

						If oAuxDXK:IsDeleted()
							A630RetSta(oAuxDXK:GetValue("DXK_SAFRA"),oAuxDXK:GetValue("DXK_ETIQ"))
							nQtdVinc++
						EndIf

						// SE tipo do romaneio seja diferente de "1" - Visual
						If FwFldGet('DXJ_TIPO') # "1"
							Loop
						EndIf

						If FWIsInCallStack("A630UPDATE")
							If !lNoClass
								lNoClass := Empty( oAuxDXK:GetValue("DXK_CLAVIS") )
							EndIf

							If !lClass
								lClass := !Empty( oAuxDXK:GetValue("DXK_CLAVIS") )
							EndIf

							If !Empty( oAuxDXK:GetValue("DXK_CLAVIS") )
								If Empty( oAuxDXK:GetValue("DXK_CLACON") )
									oAuxDXK:LoadValue("DXK_CLACON", oAuxDXK:GetValue("DXK_CLAVIS"))
								EndIf
							EndIf
						EndIf

						lDeleted := oAuxDXK:IsDeleted() .Or. nOperac == 5

						If DXI->(MsSeek(FWxFilial("DXI")+oAuxDXK:GetValue("DXK_SAFRA")+oAuxDXK:GetValue("DXK_ETIQ")))
							RecLock("DXI",.F.)
							DXI->DXI_CLAVIS := If( lDeleted, "", oAuxDXK:GetValue("DXK_CLAVIS") )
							DXI->DXI_CLACOM := If( lDeleted, "", oAuxDXK:GetValue("DXK_CLACON") ) //oAuxDXK:GetValue("DXK_CLAVIS") )

							// Informa a data e hora de deleção para excluir o fardo do aplicativo do Beneficiamento											
							If lDeleted
								DXI->DXI_DATATU := dDatabase
								DXI->DXI_HORATU := Time()
							EndIf

							DXI->(MsUnlock())
						EndIf	

						If FWIsInCallStack("A630CONFER")
							If Empty( oAuxDXK:GetValue("DXK_CLACON") )
								lNoConf := .T.
							Else
								lSiConf := .T.
							EndIf					
						EndIf													
					Next

					If FWIsInCallStack("A630CONFER")
						//--Se lNoConf estiver falso 
						//--Se lSiConf estiver verdadeiro
						//--Todos os fardinhos estão conferidos 
						If !lNoConf .AND. lSiConf
							oModel:SetValue("MdFieldDXJ","DXJ_CONFER","1")	//1=Sim 2=Não
						EndIf
					EndIf

					If FwisInCallStack("A630UPDATE")
						If oModel:GetValue("MdFieldDXJ","DXJ_TIPO") = "1"
							If lNoClass .And. !lClass // Se existir somente fardos não classificados mantém o status do romaneio como Pendente
								FwFldPut("DXJ_STATUS","1",,,,.T.)						
							ElseIf lNoClass .And. lClass // Se existir fardos não classificados e classificados mantém o status do romaneio como parcial
								FwFldPut("DXJ_STATUS","2",,,,.T.)
							Else // Mantém o Status do romaneio como classificado
								FwFldPut("DXJ_STATUS","3",,,,.T.)
							EndIf	
								If A630HviImp(oModel:GetValue("MdFieldDXJ","DXJ_CODIGO"))
									A630ClaDXI()
								EndIf

								If DXJ->(ColumnPos('DXJ_DTCLAS')) > 0	
									oModel:SetValue("MdFieldDXJ","DXJ_DTCLAS",ddatabase)
								endIf
						EndIf
					EndIf	
					/**************************************************
					** Tratamento específico para atualização e
					** manutenção de malas automáticas
					** OBS: não pode ser executado no momento da 
					**      classificação
					**************************************************/
					If lAutMala .And. (oModel:GetValue("MdFieldDXJ","DXJ_AUTOMA") == "1") .And. !IsInCallStack('A630UPDATE') .And. !IsInCallStack("UBAF030EST")

						//Atualiza quantidade e abre a mala caso esteja fechada	
						If nOperac = 4 //Alteração	

							// Fora da sequencia da mala		
							If lForaSeq
								lRet := AGRGRAVAHIS(STR0079,"DXJ",DXJ_FILIAL+DXJ_CODIGO+DXJ_TIPO,"A") //#Fardinho fora da Sequencia
							Endif		

							nQuantTemp := oModel:GetValue("MdFieldDXJ","DXJ_QTVINC")
							oModel:SetValue("MdFieldDXJ","DXJ_QTVINC", nQtdVinc)

							If (oModel:GetValue("MdFieldDXJ","DXJ_STATUS") = "1"   .Or. ; 
							oModel:GetValue("MdFieldDXJ","DXJ_STATUS") = "4") .And. ;
							SuperGetMV("MV_AGRQTML", ,50) > nQtdVinc
								oModel:SetValue("MdFieldDXJ","DXJ_STATUS", "7") //Aberta
							EndIf

							If oModel:GetValue("MdFieldDXJ","DXJ_STATUS") = '7' .And.; //Aberta
							nQtdVinc = SuperGetMV("MV_AGRQTML", ,50)	
								If 	oModel:GetValue("MdFieldDXJ","DXJ_TIPO") = '1' //Visual
									oModel:SetValue("MdFieldDXJ","DXJ_STATUS", "1") //Visual Pendente
								Else //HVI
									oModel:SetValue("MdFieldDXJ","DXJ_STATUS", "4") //HVI Pendente
								Endif			
							Endif 

							//Verifica se existe mala par
							If ExistMalaClone(oModel:GetValue("MdFieldDXJ","DXJ_CODIGO"),;
							IIF(oModel:GetValue("MdFieldDXJ","DXJ_TIPO") = '1', '2'/*HVI*/ , '1'/*Visual*/ ))

								If MsgYesNo( STR0083, STR0019 ) //#Existe uma mala par para esta, dejesa replicar as alterações?##Atenção     
									lRet := EspelhaMala(oModel, IIF( oModel:GetValue("MdFieldDXJ","DXJ_TIPO") = '1', '2'/*HVI*/ , '1'/*Visual*/ ))          
								Endif
							Endif						
						ElseIf nOperac = 5 //Exclusão
							//Verifica se existe mala par
							If ExistMalaClone(oModel:GetValue("MdFieldDXJ","DXJ_CODIGO"),;
							IIF(oModel:GetValue("MdFieldDXJ","DXJ_TIPO") = '1', '2'/*HVI*/ , '1'/*Visual*/ ))

								If MsgYesNo( STR0084, STR0019 ) //#Existe uma mala par para esta, deseja excluí-la também?##Atenção     
									lRet := DelMala(oModel:GetValue("MdFieldDXJ","DXJ_CODIGO"),; 
									IIF(oModel:GetValue("MdFieldDXJ","DXJ_TIPO") = '1', '2'/*HVI*/ , '1'/*Visual*/ ))          
								Endif
							Endif
						Endif				
					EndIf

					If !lRet 
						DisarmTransaction()
					Endif	

				End Transaction()
			Endif
		Endif

		If lRet

			If nOperac == MODEL_OPERATION_UPDATE		
				// Informa a data e hora de atualização da mala de classificação apenas quando alterou algum dado da mala (DXJ/DXK) 
				// e também se a mala já foi remetida		
				If !Empty(oModelDXJ:GetValue("DXJ_DATENV")) .AND. (oModelDXJ:IsModified() .OR. oAuxDXK:IsModified())
					oModelDXJ:SetValue('DXJ_DATATU', dDatabase)
					oModelDXJ:SetValue('DXJ_HORATU', Time())
				EndIf			
			EndIf

		EndIf

		If lRet 
			FWFormCommit( oModel )
		Endif
	Else	
		Begin Transaction

			DXI->(dbSetOrder(1))

			// Atualiza tabela DXI com as classificações dos fardos.
			For nX := 1 To  oAuxDXK:Length()
				oAuxDXK:Goline( nX )

				//Romaneio do tipo HVI
				If oModel:GetValue("MdFieldDXJ","DXJ_TIPO") = "2"
					// HVI 
					If  nOperac == 3
						If !AGRIFDBSEEK("DX7",FwFldGet('DXJ_SAFRA')+oAuxDXK:GetValue("DXK_ETIQ"),2,.F.)
							oModel:SetValue("MdFieldDXJ","DXJ_STATUS","4") // HVI Pendente
						Else
							If oModel:GetValue("MdFieldDXJ","DXJ_STATUS") < "5"
								oModel:SetValue("MdFieldDXJ","DXJ_STATUS","5") // HVI Parcial
							Endif	
						Endif
					ElseIf nOperac == 4 
						If AGRIFDBSEEK("DX7",FwFldGet('DXJ_SAFRA')+oAuxDXK:GetValue("DXK_ETIQ"),2,.F.)
							oModel:SetValue("MdFieldDXJ","DXJ_STATUS","4") // HVI Pendente
							lClasHVI := .T.
							nHVI += 1 
						Else
							lClasHVI := .F.
						Endif
					Endif	
				Endif

				// Se operação de inlcusão 
				If nOperac == 3
					Loop
				EndIf

				// SE tipo do romaneio seja diretene de "1" - Visual
				If FwFldGet('DXJ_TIPO') # "1"
					Loop
				EndIf

				If FwisInCallStack("A630UPDATE")
					If !lNoClass
						lNoClass := Empty( oAuxDXK:GetValue("DXK_CLAVIS") )
					EndIf

					If !lClass
						lClass := !Empty( oAuxDXK:GetValue("DXK_CLAVIS") )
					EndIf
				EndIf

				lDeleted := oAuxDXK:IsDeleted() .Or. nOperac == 5

				If DXI->( dbSeek( xFilial("DXI")+oAuxDXK:GetValue("DXK_SAFRA")+oAuxDXK:GetValue("DXK_ETIQ") ) )
					RecLock("DXI",.F.)
					DXI->DXI_CLAVIS := If( lDeleted, "", oAuxDXK:GetValue("DXK_CLAVIS") )
					DXI->DXI_CLACOM := If( lDeleted, "", oAuxDXK:GetValue("DXK_CLAVIS") )
					DXI->(MsUnlock())
				EndIf									
			Next

			If FwisInCallStack("A630UPDATE")
				If oModel:GetValue("MdFieldDXJ","DXJ_TIPO") = "1"
					If lNoClass .And. !lClass // Se existir somente fardos não classificados mantém o status do romaneio como Pendente
						FwFldPut("DXJ_STATUS","1",,,,.T.)
					ElseIf lNoClass .And. lClass // Se existir fardos não classificados e classificados mantém o status do romaneio como parcial
						FwFldPut("DXJ_STATUS","2",,,,.T.)
					Else // Mantém o Status do romaneio como classificado
						FwFldPut("DXJ_STATUS","3",,,,.T.)
					EndIf
				Else
					If !lClasHVI .And.  nHVI = 0
						oModel:SetValue("MdFieldDXJ","DXJ_STATUS","4") //HVI Pendente
					ElseIf lClas .And. nHVI = oAuxDXK:Length()
						oModel:SetValue("MdFieldDXJ","DXJ_STATUS","6") //HVI Importado
					Else
						oModel:SetValue("MdFieldDXJ","DXJ_STATUS","5") //HVI Parcial
					Endif 		
				EndIf
			EndIf

		End Transaction()

		If lGrava 
			FWFormCommit( oModel )
		Endif

	EndIf


	RestArea(aArea)
Return lRet

/** -------------------------------------------------------------------------------------
{Protheus.doc} AGRA630I
Rotina de Inclusão de fardos no Romaneio

@Param	oView - Modelo de dados da View

@author Aécio Gomes
@since 02/11/2012
@version 1.0
-------------------------------------------------------------------------------------- **/
Function AGRA630I(oView)
	Local oModel 	        := FWModelActive()
	Local oSize2 	        := FWDefSize():New(.F.)
	Local oSize3 	        := FWDefSize():New(.F.)
	Local oSize4 	        := FWDefSize():New(.F.)
	Local oAuxDXK	        := oModel:GetModel( 'MdGridDXK' )
	Local oDlg		        := Nil
	Local oFWLayer	    	:= Nil
	Local oBtBarEsq	    	:= Nil
	Local oBtBarDir	    	:= Nil
	Local aCoors	       	:= FWGetDialogSize( oMainWnd )
	Local aCombo 	       	:= {}
	Local aPergs  	   		:= {}
	Local aRet  	       	:= {}
	Local cChavEsq	   		:= Space(10)
	Local cChavDir	   		:= Space(10)
	Local cPesqEsq 	   		:= Space(TamSX3("DXI_ETIQ")[1])
	Local cPesqDir 	   		:= cPesqEsq
	Local lRet		       	:= .T.
	Local nOpcA 	       	:= 0
	Local nQtdFardo	   		:= Space(4)
	Local cRomClas       	:= oModel:GetValue("MdFieldDXJ","DXJ_CODIGO")
	Local cUnidade       	:= oModel:GetValue("MdFieldDXJ","DXJ_CODUNB")
	
	Static lMarcAllD 		:= .T.
	Static lMarcAllE 		:= .T.
	
	Private aItsEsq			:= {}
	Private aItsDir			:= {}
	Private nPeso		   	:= 0
	Private nQtde		   	:= 0
	Private aColsDirAnt 	:= {}
	Private oBrwEsq, oBrwDir

	If Empty(cUnidade) .And. Empty(cUserBenf)
		MSGINFO(STR0070)
		Return
	Endif                         

	if oModel:GetOperation() =  MODEL_OPERATION_VIEW 
		MSGINFO(STR0059) //O modo de visualização não permite a inclusão de fardos
		Return
	EndIf


	//---------------------------------------
	// Adiciona perguntas ao array da parambox
	//---------------------------------------
	aAdd( aPergs ,{1,STR0042,CriaVar("DXI_CODIGO", .F.) ,"@E 999999",'.T.',,'.T.',TamSX3("DXI_CODIGO")[1],.F.}) //"Fardo De ?"
	aAdd( aPergs ,{1,STR0021,CriaVar("DXI_CODIGO", .F.) ,"@E 999999",'.T.',,'.T.',TamSX3("DXI_CODIGO")[1],.F.}) //"Fardo Ate ?"
	aAdd( aPergs ,{1,STR0043,CriaVar("DXI_PRENSA", .F.) ,"@E 9",'.T.',,'.T.',TamSX3("DXI_PRENSA")[1],.F.}) //"Prensa ?"
	aAdd( aPergs ,{1,"Qtd. Fardos",nQtdFardo            ,'@E 999','.T.',,'.T.',3,.F.}) //"Qtd. Fardos ?"

	//--------------------------
	// Chama tela de parametros
	//--------------------------
	lRet := ParamBox(aPergs ,STR0022,@aRet) //"Parametros "

	If lRet
		AADD(aCombo, STR0023 ) //"Fardo"
		AADD(aCombo, STR0024 ) //"Etiqueta"
	EndIf

	If lRet

		If Empty(aRet[4])
			MSGINFO(STR0071)
			Return
		EndIf

		//----- TELA PARA SELECIONAR FARDOS
		//- Coordenadas da area total da Dialog
		oSize:= FWDefSize():New(.T.)
		oSize:AddObject("DLG",100,100,.T.,.T.)
		oSize:SetWindowSize(aCoors)
		oSize:lProp 	:= .T.
		oSize:aMargins := {0,0,0,0}
		oSize:Process()

		DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4];
		TITLE STR0025 OF oMainWnd PIXEL //"Inclusão de Fardos no Romaneio"

		oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3])
		//---------------------------
		// Cria instancia do fwlayer
		//---------------------------
		oFWLayer := FWLayer():New()
		oFWLayer:init( oPnl1, .F. )

		oFWLayer:AddCollumn( 'ESQ' , 45, .F.)
		oFWLayer:AddCollumn( 'MEIO', 10, .F.)
		oFWLayer:AddCollumn( 'DIR' , 45, .F.)

		oFWLayer:addWindow( "ESQ" , "Wnd1", STR0026 , 90, .F., .T.) //"Fardos Sem Classificação"
		oFWLayer:addWindow( "DIR" , "Wnd2", STR0027 , 90, .F., .T.) //"Fardos Selecionados para Classificação" 

		oPnl2 := oFWLayer:getWinPanel( "ESQ", "Wnd1")
		oPnl3 := oFWLayer:GetColPanel( 'MEIO')
		oPnl4 := oFWLayer:getWinPanel( "DIR", "Wnd2")

		oSize4:AddObject("PNL4",100,100,.T.,.T.)
		oSize4:SetWindowSize({0,0,oPnl4:NHEIGHT,oPnl4:NWIDTH})
		oSize4:lProp    := .T.
		oSize4:aMargins := {0,0,1,0}
		oSize4:Process()

		//----------------------
		// Cria barra de botoes
		//----------------------
		oBtBarDir := TBar():New( oPnl4,25,25,.T.,,,,.F. )
		@ 0, 0 COMBOBOX cChavDir ITEMS aCombo SIZE 40,07 PIXEL OF oBtBarDir
		@ 0, 0 MSGET cPesqDir SIZE 100,10 PIXEL OF oBtBarDir PICTURE "@x"
		TButton():New(0,0,STR0028,oBtBarDir,{|| Pesquisa(cChavDir,Alltrim(cPesqDir),@oBrwDir)},Len(STR0029)*4,10,,,,.T.,,) //"Pesquisa"###'Pesquisa'

		//Carrega os itens na Grid de fardos já vinculados
		aItsDir := LoadFarDir(aRet,cRomClas)
		
		oBrwDir := TCBrowse():New( oSize4:aPosObj[1,1], oSize4:aPosObj[1,2], oSize4:aPosObj[1,3], oSize4:aPosObj[1,4], , , , oPnl4, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
		oBrwDir:AddColumn( TCColumn():New(""	 , { || IIf( aItsDir[oBrwDir:nAt,1] == "1", oOK, oNo  ) },,,,"CENTER",010,.t.,.t.,,,,.f., ) )
		oBrwDir:AddColumn( TCColumn():New(STR0050, { || aItsDir[oBrwDir:nAt,2] }									, , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Safra"
		oBrwDir:AddColumn( TCColumn():New(STR0024, { || aItsDir[oBrwDir:nAt,3] }									, , , , "LEFT" , 060, .f., .t., , , , .f., ) ) //"Etiqueta"
		oBrwDir:AddColumn( TCColumn():New(STR0051, { || aItsDir[oBrwDir:nAt,4] }									, , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"Codigo"
		oBrwDir:AddColumn( TCColumn():New(STR0052, { || Transform( aItsDir[oBrwDir:nAt,5], "@E 999,999,999.99" ) }	, , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Bruto"
		oBrwDir:AddColumn( TCColumn():New(STR0053, { || Transform( aItsDir[oBrwDir:nAt,6], "@E 999,999,999.99" ) }	, , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Liquido"
		oBrwDir:AddColumn( TCColumn():New(STR0054, { || aItsDir[oBrwDir:nAt,7] }									, , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"Class. Vis."
		oBrwDir:AddColumn( TCColumn():New(STR0055, { || aItsDir[oBrwDir:nAt,8] }									, , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"Fardao"
		oBrwDir:AddColumn( TCColumn():New(STR0056, { || aItsDir[oBrwDir:nAt,9] }									, , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"Variedade"
		oBrwDir:AddColumn( TCColumn():New(STR0057, { || aItsDir[oBrwDir:nAt,10] }									, , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"Prensa"

		oBrwDir:SetArray( aItsDir )
		oBrwDir:bLDblClick 		:= {|| MarcaUm( oBrwDir, aItsDir, oBrwDir:nAt, .F. )}
		oBrwDir:bHeaderClick 	:= {|| MarcaTudo( oBrwDir, aItsDir, oBrwDir:nAt, @lMarcAllD, .F. ) }
		oBrwDir:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwDir:Refresh(.T.)

		//-----------------------------------
		// Cria Botão marca/desmarca na Grid
		//-----------------------------------
		//--------------------------
		// Dimensionamento da area
		//--------------------------
		oSize2:AddObject("PNL2",100,100,.T.,.T.)
		oSize2:SetWindowSize({0,0,oPnl2:NHEIGHT,oPnl2:NWIDTH})
		oSize2:lProp 	:= .T.
		oSize2:aMargins := {0,0,1,0}
		oSize2:Process()
		//----------------------
		// Cria barra de botoes
		//----------------------
		oBtBarEsq := TBar():New( oPnl2,25,25,.T.,,,,.F. )
		@ 0, 0 COMBOBOX cChavEsq ITEMS aCombo SIZE 40,07 PIXEL OF oBtBarEsq
		@ 0, 0 MSGET cPesqEsq SIZE 100,10 PIXEL OF oBtBarEsq PICTURE "@x"
		TButton():New(0,0, STR0028 ,oBtBarEsq,{|| Pesquisa(cChavEsq,Alltrim(cPesqEsq),@oBrwEsq)},Len(STR0029)*4,10,,,,.T.,,) //"Pesquisa"###'Pesquisa'

		aItsEsq := LoadFardos(aRet)
	
		oBrwEsq := TCBrowse():New( oSize2:aPosObj[1,1], oSize2:aPosObj[1,2], oSize2:aPosObj[1,3], oSize2:aPosObj[1,4], , , , oPnl2, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
		oBrwEsq:AddColumn( TCColumn():New(""	 , { || IIf( aItsEsq[oBrwEsq:nAt,1] == "1", oOK, oNo ) },,,,"CENTER",010,.t.,.t.,,,,.f., ) )
		oBrwEsq:AddColumn( TCColumn():New(STR0050, { || aItsEsq[oBrwEsq:nAt,2] }									, , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Safra"
		oBrwEsq:AddColumn( TCColumn():New(STR0024, { || aItsEsq[oBrwEsq:nAt,3] }									, , , , "LEFT" , 060, .f., .t., , , , .f., ) ) //"Etiqueta"
		oBrwEsq:AddColumn( TCColumn():New(STR0051, { || aItsEsq[oBrwEsq:nAt,4] }									, , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"Codigo"
		oBrwEsq:AddColumn( TCColumn():New(STR0052, { || Transform( aItsEsq[oBrwEsq:nAt,5], "@E 999,999,999.99" ) }	, , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Bruto"
		oBrwEsq:AddColumn( TCColumn():New(STR0053, { || Transform( aItsEsq[oBrwEsq:nAt,6], "@E 999,999,999.99" ) }	, , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Líquido"
		oBrwEsq:AddColumn( TCColumn():New(STR0054, { || aItsEsq[oBrwEsq:nAt,7] }									, , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"Class. Vis."
		oBrwEsq:AddColumn( TCColumn():New(STR0055, { || aItsEsq[oBrwEsq:nAt,8] }									, , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"Fardao"
		oBrwEsq:AddColumn( TCColumn():New(STR0056, { || aItsEsq[oBrwEsq:nAt,9] }									, , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"Variedade"
		oBrwEsq:AddColumn( TCColumn():New(STR0057, { || aItsEsq[oBrwEsq:nAt,10] }									, , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"Prensa"
	
		oBrwEsq:SetArray( aItsEsq )
		oBrwEsq:bLDblClick 		:= {|| MarcaUm( oBrwEsq, aItsEsq, oBrwEsq:nAt, .F. )}
		oBrwEsq:bHeaderClick 	:= {|| MarcaTudo( oBrwEsq, aItsEsq, oBrwEsq:nAt, @lMarcAllE, .F. ) }
		oBrwEsq:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwEsq:Refresh(.T.)

		//Caso um fardo seja adicionado na tela principal e a funcao Incluir Fardos seja acionada novamente. 
		//Estes fardos que já foram adicionados aparecerao ao lado direito novamente
		UpdFardos(oAuxDXK, @oBrwEsq, @oBrwDir)

		//-----------------------------------
		// Cria Botão marca/desmarca na Grid
		//-----------------------------------

		//--------------------------
		// Dimensionamento da area
		//--------------------------
		oSize3:AddObject("PNL3",100,100,.T.,.T.)
		oSize3:SetWindowSize({0,0,oPnl3:NHEIGHT,oPnl3:NWIDTH})
		oSize3:lProp 	:= .T.
		oSize3:aMargins := {0,0,0,0}
		oSize3:Process()

		//----------------
		// Define a fonte
		//----------------
		oFont := TFont():New('Arial',,-12,.T.)

		//-----------------------------------------------------------
		// Cria botoes vincular ou desvincular os fardos do romaneio
		//-----------------------------------------------------------
		TButton():New( (oSize3:APOSOBJ[1][3]/2)-44, oSize3:APOSOBJ[1][1]+5, ">>" , oPnl3, {|| MovFardos( ">", @oBrwEsq, @oBrwDir ) }, oSize3:APOSOBJ[1][4]-10, 15, , /**oFont*/, , .t., , STR0030 ) //"Vincular Marcados"
		TButton():New( (oSize3:APOSOBJ[1][3]/2)-28, oSize3:APOSOBJ[1][1]+5, "<<" , oPnl3, {|| MovFardos( "<", @oBrwEsq, @oBrwDir ) }, oSize3:APOSOBJ[1][4]-10, 15, , /**oFont*/, , .t., , STR0031 ) //"Desvincular Marcados"

		nQtde := Len(aItsDir)

		//---------------------------------------------------------------------------------------------------
		// Apresenta calculos de peso total dos Fardos selecionados e quantidade de itens do romaneio na tela
		//---------------------------------------------------------------------------------------------------
		oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)-5,oSize3:APOSOBJ[1][1]+5,{|| Transform( STR0032 , "@!" )},oPnl3,,oFont,,; //"Quantidade"
		,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
		oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+5,oSize3:APOSOBJ[1][1]+5,{||  Alltrim(Transform( nQtde, '@E 99999') )},oPnl3,,oFont,,;
		,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
		oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+15,oSize3:APOSOBJ[1][1]+5,{|| Transform( STR0033, "@!" )},oPnl3,,oFont,,; //"Peso Total"
		,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
		oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+25,oSize3:APOSOBJ[1][1]+5,{||Alltrim(Transform( nPeso, PesqPict('DXL','DXL_PSLIQU')) )},oPnl3,,oFont,,;
		,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)

		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| nOpcA:= 1, ExecGrav(oDlg, @oBrwDir)},{|| nOpcA:= 2, oDlg:End()})

	EndIf
Return


/** -------------------------------------------------------------------------------------
{Protheus.doc} LoadFardos
Carrega os itens na Grid de fardos sem classificação

@Param	aPergs - Perguntas para completar o filtro

@author Aécio Gomes
@since 02/11/2012
@version 1.0
-------------------------------------------------------------------------------------- **/
Static Function LoadFardos(aPergs)
	Local oModel	   := FwModelActive()
	Local oAuxDXK	   := oModel:GetModel( 'MdGridDXK' )
	Local aArea		   := GetArea()
	Local aColsLoad	   := {}
	Local cAliasQry    := ""
	Local cQry 		   := ""
	Local nCont 	   := 0
	Local nPosEtiq     := 0
	Local cUN          := ""

	If Empty(cUserBenf)
		cUN := oModel:GetValue('MdFieldDXJ',"DXJ_CODUNB")
	Else
		cUN := cUserBenf
	Endif	

	cAliasQry := GetNextAlias()

	If Select(cAliasQry) > 0
		(cAliasQry)->( dbCloseArea() )
	EndIf
	If __lnewComerc
		cQry := "SELECT DXI_SAFRA,DXI_CODIGO,DXI_ETIQ,DXI_PRENSA,DXI_CLAVIS,DXI_CODVAR,DXI_FARDAO,DXI_PSLIQU,DXI_PSBRUT FROM "+ RetSqlName("DXI") + " DXI "
		cQry += "   WHERE DXI_FILIAL = '"+FWxFilial("DXI")+"' "
		cQry += "     AND  DXI.DXI_ETIQ NOT IN ""
		cQry += "(SELECT DXK.DXK_ETIQ  FROM "+ RetSqlName("DXK") +" DXK "
		cQry += "  INNER JOIN   "+ RetSqlName("DXJ") +" DXJ ON  DXJ.D_E_L_E_T_ = ' 'AND DXJ.DXJ_FILIAL = DXK.DXK_FILIAL AND DXJ.DXJ_CODIGO = DXK.DXK_CODROM "

		If DXK->(ColumnPos('DXK_TIPO')) > 0
			cQry += "	 AND DXJ.DXJ_TIPO = DXK.DXK_TIPO "
		endIf 

		cQry += "  WHERE DXK.D_E_L_E_T_ = ' ' AND  DXK.DXK_FILIAL = DXI.DXI_FILIAL AND DXK.DXK_SAFRA =  DXI.DXI_SAFRA AND DXK.DXK_ETIQ = DXI.DXI_ETIQ"
		cQry += "    AND DXJ.DXJ_TIPO  = '"+oModel:GetValue('MdFieldDXJ',"DXJ_TIPO")+"' ) "
		cQry += "    AND DXI_SAFRA	= '"+oModel:GetValue('MdFieldDXJ',"DXJ_SAFRA")+"' "
		cQry += "    AND DXI_PRDTOR	= '"+oModel:GetValue('MdFieldDXJ',"DXJ_PRDTOR")+"' "

	If oModel:GetValue('MdFieldDXJ',"DXJ_TIPO") == '1' 
		cQry += "   AND DXI.DXI_CLAVIS = ' ' "
	Endif
	
	//--------------------------------------------------------------------------------
	// Caso o campo Loja esteja em branco, considera todas as Lojas do produtor
	//--------------------------------------------------------------------------------
	If !Empty( oModel:GetValue('MdFieldDXJ','DXJ_LJPRO') )
		cQry += "   AND DXI_LJPRO	= '"+oModel:GetValue('MdFieldDXJ',"DXJ_LJPRO")+"' "
	Endif

	cQry += "   AND DXI_CODUNB = '"+cUN+"' "

	//--------------------------------------------------------------------------------
	// Caso o campo Fazenda esteja em branco, considera todas as fazendas do produtor
	//--------------------------------------------------------------------------------
	If !Empty( oModel:GetValue('MdFieldDXJ','DXJ_FAZ') )
		cQry += "   AND DXI_FAZ = '"+oModel:GetValue('MdFieldDXJ',"DXJ_FAZ")+"' "
	EndIf

		//--------------------------------------------------------------------
		// Considera as perguntas somente se o campo Variedade estiver vazio
		//--------------------------------------------------------------------
		If !Empty(oModel:GetValue('MdFieldDXJ','DXJ_CODVAR'))
			cQry += "   AND DXI_CODVAR	= '"+oModel:GetValue('MdFieldDXJ',"DXJ_CODVAR")+"' "
		EndIf

		//--------------------------------------------------------------------
		// Considera o conjunto, caso esteja informado
		//--------------------------------------------------------------------
		If !Empty(oModel:GetValue('MdFieldDXJ','DXJ_CODCNJ'))
			cQry += "   AND DXI_CODCNJ	= '"+oModel:GetValue('MdFieldDXJ',"DXJ_CODCNJ")+"' "
		EndIf


		If (!empty(aPergs[1]) .and. !empty(aPergs[2]) )
			cQry += "   AND DXI_CODIGO BETWEEN '"+aPergs[1]+"' AND '"+aPergs[2]+"' "
		endif
		If (!empty(aPergs[3]),cQry += "   AND DXI_PRENSA =  '"+aPergs[3]+"' ",)
		cQry += "   AND DXI.D_E_L_E_T_ = ' ' "
		cQry += " ORDER BY DXI_SAFRA, DXI_CODIGO "
		cQry := ChangeQuery( cQry )
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

		//Carrega Browser esquerdo
		nPosEtiq := aScan(oAuxDXK:AHEADER, {|x| Alltrim(x[2]) == "DXK_ETIQ"}) // Codigo da Etiqueta do Fardinho
	Else
		cQry := "SELECT DXI_PRENSA,DXI_SAFRA,DXI_ETIQ,DXI_CODIGO,DXI_CLAVIS,DXI_CODVAR,DXI_FARDAO,DXI_PSLIQU,DXI_PSBRUT FROM "+ RetSqlName("DXI") + " DXI "
		cQry += " WHERE DXI_FILIAL = '"+xFilial("DXI")+"' "
		cQry += "AND  DXI.DXI_ETIQ NOT IN ""
		cQry += "(SELECT DXK.DXK_ETIQ  FROM "+ RetSqlName("DXK") +" DXK "
		cQry += " INNER JOIN   "+ RetSqlName("DXJ") +" DXJ ON  DXJ.D_E_L_E_T_ = ' 'AND DXJ.DXJ_FILIAL = DXK.DXK_FILIAL AND DXJ.DXJ_CODIGO = DXK.DXK_CODROM
		cQry += " WHERE DXK.D_E_L_E_T_ = ' ' AND  DXK.DXK_FILIAL = DXI.DXI_FILIAL AND DXK.DXK_SAFRA =  DXI.DXI_SAFRA AND DXK.DXK_ETIQ = DXI.DXI_ETIQ";
		+ " AND DXJ.DXJ_TIPO  = '"+oModel:GetValue('MdFieldDXJ',"DXJ_TIPO")+"' ) "
		cQry += "AND DXI_SAFRA	= '"+oModel:GetValue('MdFieldDXJ',"DXJ_SAFRA")+"' "
		cQry += "AND DXI_PRDTOR	= '"+oModel:GetValue('MdFieldDXJ',"DXJ_PRDTOR")+"' "

		If oModel:GetValue('MdFieldDXJ',"DXJ_TIPO") == '1' 
			cQry += "AND DXI.DXI_CLAVIS = ' ' "
		endif

		//--------------------------------------------------------------------------------
		// Caso o campo Loja esteja em branco, considera todas as Lojas do produtor
		//--------------------------------------------------------------------------------
		If !Empty( oModel:GetValue('MdFieldDXJ','DXJ_LJPRO') )
			cQry += "AND DXI_LJPRO	= '"+oModel:GetValue('MdFieldDXJ',"DXJ_LJPRO")+"' "
		Endif

		cQry += "AND DXI_CODUNB = '"+cUN+"' "

		//--------------------------------------------------------------------------------
		// Caso o campo Fazenda esteja em branco, considera todas as fazendas do produtor
		//--------------------------------------------------------------------------------
		If !Empty( oModel:GetValue('MdFieldDXJ','DXJ_FAZ') )
			cQry += "AND DXI_FAZ = '"+oModel:GetValue('MdFieldDXJ',"DXJ_FAZ")+"' "
		EndIf

		//--------------------------------------------------------------------
		// Considera as perguntas somente se o campo Variedade estiver vazio
		//--------------------------------------------------------------------
		If !Empty(oModel:GetValue('MdFieldDXJ','DXJ_CODVAR'))
			cQry += "AND DXI_CODVAR	= '"+oModel:GetValue('MdFieldDXJ',"DXJ_CODVAR")+"' "
		EndIf
		If (!empty(aPergs[1]) .and. !empty(aPergs[2]) )
			cQry += "AND DXI_CODIGO BETWEEN '"+aPergs[1]+"' AND '"+aPergs[2]+"' "
		endif
		If (!empty(aPergs[3]),cQry += "AND DXI_PRENSA =  '"+aPergs[3]+"' ",)
		cQry += "AND DXI.D_E_L_E_T_ = ' ' "
		cQry := ChangeQuery( cQry )
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

		//Quantos registros da tabela
		//	COUNT TO nQtdReg 
		//Limitador para mostrar dados em tela
		//If nQtdReg > Val(aPergs[4])
		//	MSGINFO("Será mostrado apenas "+ Alltrim(aPergs[4]) +" registros.")
		//EndIF

		//Carrega Browser esquerdo
		nPosEtiq := aScan(oAuxDXK:AHEADER, {|x| Alltrim(x[2]) == "DXK_ETIQ"}) // C7odigo da Etiqueta do Fardinho
	EndIF
	//Seleciona a tabela 
	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) .AND. nCont < Val(aPergs[4])

		nCont++

		aAdd( aColsLoad, { "2", (cAliasQry)->DXI_SAFRA, (cAliasQry)->DXI_ETIQ, (cAliasQry)->DXI_CODIGO, (cAliasQry)->DXI_PSBRUT, ;
								(cAliasQry)->DXI_PSLIQU, (cAliasQry)->DXI_CLAVIS, (cAliasQry)->DXI_FARDAO,(cAliasQry)->DXI_CODVAR,(cAliasQry)->DXI_PRENSA } )
		
		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return(aColsLoad)

/** -------------------------------------------------------------------------------------
{Protheus.doc} LoadFarDir
Carrega os itens na Grid de fardos já vinculados
@Param	aPergs - Perguntas para completar o filtro

@author Bruna Rocio
@since 15/07/2015
@version 1.0
-------------------------------------------------------------------------------------- **/
Static Function LoadFarDir(aPergs,cRomClas,oBrw)
	Local oModel	  := FwModelActive()
	Local oAuxDXK	  := oModel:GetModel( 'MdGridDXK' )
	Local aArea	      := GetArea()
	Local aColsLoad   := {}
	Local cAliasQry   := ""
	Local cQry 	      := ""
	Local nCont 	  := 0
	Local nPosEtiq    := 0
	Local cUN         := ""

	If Empty(cUserBenf)
		cUN := oModel:GetValue('MdFieldDXJ',"DXJ_CODUNB")
	Else
		cUN := cUserBenf
	Endif	

	cAliasQry := GetNextAlias()

	cQry := " SELECT * FROM "+ RetSqlName("DXI") + " DXI "
	cQry += " 	INNER JOIN  "+ RetSqlName("DXJ") +" DXJ ON DXJ.DXJ_SAFRA = DXI.DXI_SAFRA "
	cQry += "   AND DXJ.DXJ_PRDTOR = DXI.DXI_PRDTOR "
	cQry += "   AND DXJ_CODIGO     = '"+ cRomClas       +"' " 
	cQry += "   AND DXJ.DXJ_FILIAL = '"+ FWxFilial("DXJ") + "' "
	cQry += "   AND DXJ_TIPO       = '"+oModel:GetValue('MdFieldDXJ',"DXJ_TIPO")+"' "
	cQry += "   AND DXJ.D_E_L_E_T_ = ' ' "

	cQry += " INNER JOIN " + RetSqlName("DXK") + " DXK ON DXK.DXK_CODROM = DXJ.DXJ_CODIGO "
	cQry += "   AND DXK.DXK_FILIAL = '"+ FWxFilial("DXK") + "' "
	
	If DXK->(ColumnPos('DXK_TIPO')) > 0
		cQry += "   AND DXK.DXK_TIPO   = DXJ.DXJ_TIPO "
	endIf
	
	cQry += "   AND DXK.DXK_FARDO  = DXI.DXI_CODIGO "
	cQry += "   AND DXK.D_E_L_E_T_ = ' ' "
	cQry += " WHERE DXI_FILIAL     = '"+ FWxFilial("DXI") +"' "

	cQry += "   AND DXI_SAFRA	= '"+oModel:GetValue('MdFieldDXJ',"DXJ_SAFRA")+"' "
	cQry += "   AND DXI_PRDTOR	= '"+oModel:GetValue('MdFieldDXJ',"DXJ_PRDTOR")+"' "

	//--------------------------------------------------------------------------------
	// Caso o campo Loja esteja em branco, considera todas as Lojas do produtor
	//--------------------------------------------------------------------------------
	If !Empty( oModel:GetValue('MdFieldDXJ','DXJ_LJPRO') )
		cQry += "   AND DXI_LJPRO	= '"+oModel:GetValue('MdFieldDXJ',"DXJ_LJPRO")+"' "
	Endif

	cQry += "   AND DXI_CODUNB = '"+cUN+"' "

	//--------------------------------------------------------------------------------
	// Caso o campo Fazenda esteja em branco, considera todas as fazendas do produtor
	//--------------------------------------------------------------------------------
	If !Empty( oModel:GetValue('MdFieldDXJ','DXJ_FAZ') )
		cQry += "   AND DXI_FAZ = '"+oModel:GetValue('MdFieldDXJ',"DXJ_FAZ")+"' "
	EndIf

	//--------------------------------------------------------------------
	// Considera as perguntas somente se o campo Variedade estiver vazio
	//--------------------------------------------------------------------
	If !Empty(oModel:GetValue('MdFieldDXJ','DXJ_CODVAR'))
		cQry += "  AND DXI_CODVAR	= '"+oModel:GetValue('MdFieldDXJ',"DXJ_CODVAR")+"' "
	EndIf

	If (!empty(aPergs[3]),cQry += "   AND DXI_PRENSA =  '"+aPergs[3]+"' ",)
	cQry += "   AND DXI.D_E_L_E_T_ = '' "
	cQry := ChangeQuery( cQry )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	//Carrega Browser esquerdo
	nPosEtiq := aScan(oAuxDXK:AHEADER, {|x| Alltrim(x[2]) == "DXK_ETIQ"}) // Codigo da Etiqueta do Fardinho

	//Variavel privada. Resetar valor antes da busca dos fardos para somar corretamente.
	nPeso := 0
	
	//Seleciona a tabela 
	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) .AND. nCont < Val(aPergs[4])

		nCont ++

		aAdd( aColsLoad, { "2", (cAliasQry)->DXI_SAFRA, (cAliasQry)->DXI_ETIQ, (cAliasQry)->DXI_CODIGO, (cAliasQry)->DXI_PSBRUT, ;
		 					(cAliasQry)->DXI_PSLIQU, (cAliasQry)->DXI_CLAVIS, (cAliasQry)->DXI_FARDAO,(cAliasQry)->DXI_CODVAR,(cAliasQry)->DXI_PRENSA } )
		
		nPeso += (cAliasQry)->DXI_PSLIQU
		
		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return(aColsLoad)


/** -------------------------------------------------------------------------------------
{Protheus.doc} A630GRAVA
Atualiza os dados dos itens do Romaneio

@Param	oBrowse	- Browser onde estão localizados os registros
oModel 	- Modelo de dados da rotina

@author Aécio Gomes
@since 02/11/2012
@version 1.0
@type function
-------------------------------------------------------------------------------------- **/
Static Function A630GRAVA(oBrowse, oModel)
	Local oView		:= FwViewActive()
	Local oAuxDXK	:= oModel:GetModel( 'MdGridDXK' )
	Local aRRRAY	:= oBrowse:AARRAY
	Local aAuxDXK	:= oAuxDXK:adatamodel
	Local nX		:= 0
	Local lRet		:= .T.
	Local aSaveLine	:= FWSaveRows()
	Local nI        := 0
	Local lCria     := .f.
	Local lExclui   := .t.
	Local nTotFar	:= 0
	Local cFarIni	:= ""
	Local cFarFim	:= ""
	
	nTotFardos := 0
	nTotBruto  := 0
	nTotLiquid := 0
	nTotClsVis := 0

	/***** Exclui os registros que não foram mantidos na inclusao de fardos ****/
	For nI := 1 To Len(aAuxDXK)
		lExclui := .F.
	
		If !Empty(aAuxDXK[nI][1][1][4])	
			If Empty(aRRRAY)
				lExclui := .T.
			EndIf
			For nX := 1 To Len(aRRRAY)
			
				//Se encontrar o registro, mantem a linha
				If aAuxDXK[nI][1][1][4] = aRRRAY[nX][4]
					exit
				Endif
				
				//Se for o ultimo registro e nao encontrar, deleta a linha no grid
				If nX == Len(aRRRAY) .And. aAuxDXK[nI][1][1][4] <> aRRRAY[nX][4]
					lExclui := .T.
				EndIf
				
			Next nX
			If __lnewComerc
				//O registro sera excluido pq foi removido da selecao da direita
				If lExclui .and. oModel:GetOperation() !=  MODEL_OPERATION_DELETE
					oAuxDXK:GoLine(nI)
					oAuxDXK:DeleteLine()
				Endif
			Else
				If lExclui .and. oModel:GetOperation() !=  MODEL_OPERATION_DELETE .And. !oAuxDXK:IsDeleted(nI)
					oAuxDXK:GoLine(nI)
					oAuxDXK:DeleteLine()
				Endif
			EndIf	
		Endif
	Next nI
	
	/*Cria as linhas na tela***********************************************************************/
	For nX:= 1 To Len(aRRRAY)
		lCria 	 := .t.

		For nI := 1 To Len(aAuxDXK)
		
			If !Empty(aAuxDXK[nI][1][1][4])		
				//Se o fardo esta deletado, mas foi adicionado novamente. 
				//Alterar a situacao da linha e buscar a classificacao salva
				If aAuxDXK[nI][1][1][4] = aRRRAY[nX][4] .And. oAuxDXK:IsDeleted(nI)
					oAuxDXK:Goline(nI)
					oAuxDXK:UnDeleteLine()
					aAuxDXK[nI][1][1][6] := aRRRAY[nX][7]
					lCria := .f.
				EndIf
				//Se é um fardo que já existe no grid e não foi deletado, nao adicionar novamente
				If aAuxDXK[nI][1][1][4] = aRRRAY[nX][4] .And. !oAuxDXK:IsDeleted(nI)
					lCria := .F.
				EndIf
			EndIf
		Next nI

			//Inicio do somatorio com os fardos que aparecerao em tela
			nTotFardos++
			If !Empty(aRRRAY[nX][7])
				nTotClsVis ++
			EndIf	       
			nTotBruto  += aRRRAY[nX][5]
		    nTotLiquid += aRRRAY[nX][6]
			//Final do somatorio
		If lCria			
			//Se o código do Fardo está branco na ultima linha do grid, então deve-se alterar esta
			If Empty(aAuxDXK[oAuxDXK:Length()][1][1][4])	
				oAuxDXK:Goline(oAuxDXK:Length())
			//Senao, adiciona-se uma linha e altera-se esta				
			Else
				oAuxDXK:AddLine()
				oAuxDXK:Goline(oAuxDXK:Length())
			EndIf
				
			If !Empty(aRRRAY[nX,2])
				oAuxDXK:LoadValue("DXK_SAFRA",aRRRAY[nX,2])
			EndIf

			If !Empty(aRRRAY[nX,3])
				oAuxDXK:LoadValue("DXK_ETIQ",aRRRAY[nX,3])
			EndIf
			
			If !Empty(aRRRAY[nX,4])
				oAuxDXK:LoadValue("DXK_FARDO",aRRRAY[nX,4])
			EndIf

			If !Empty(aRRRAY[nX,5])
				oAuxDXK:LoadValue("DXK_PSBRUT", aRRRAY[nX,5])
			EndIf
			
			If !Empty(aRRRAY[nX,6])
				oAuxDXK:LoadValue("DXK_PSLIQU", aRRRAY[nX,6])
			EndIf
			
			If !Empty(aRRRAY[nX,7])
				oAuxDXK:LoadValue("DXK_CLAVIS",aRRRAY[nX,7])
			EndIf

			If !Empty(aRRRAY[nX,8])
				oAuxDXK:LoadValue("DXK_TALHAO", retTalhao(aRRRAY[nX,8]))
				oAuxDXK:LoadValue("DXK_DESTAL", A630DESTAL(retTalhao(aRRRAY[nX,8])))
			EndIf

			If !Empty(aRRRAY[nX,9])
				oAuxDXK:LoadValue("DXK_CODVAR", aRRRAY[nX,9])
				oAuxDXK:LoadValue("DXK_DESVAR", A630DESVAR(aRRRAY[nX,9]))
			EndIf

		Endif	
	Next nX

	oModel:LoadValue('AGRA630CALC','TOTBRUTO', nTotBruto)
	oModel:LoadValue('AGRA630CALC','TOTLIQU' , nTotLiquid)
	oModel:LoadValue('AGRA630CALC','TOTCLA'  , nTotClsVis)
	oModel:LoadValue('AGRA630CALC', 'TOTFDI' , nTotFardos)

	For nI := 1 To oAuxDXK:Length()
		oAuxDXK:Goline(nI)
		If !oAuxDXK:IsDeleted()
			nTotFar += 1	

			If Empty(cFarFim) .OR. cFarFim < oAuxDXK:GetValue("DXK_FARDO",nI)
				cFarFim := oAuxDXK:GetValue("DXK_FARDO",nI)
			EndIf

			If Empty(cFarIni) .OR. cFarIni > oAuxDXK:GetValue("DXK_FARDO",nI)
				cFarIni := oAuxDXK:GetValue("DXK_FARDO",nI)
			EndIf 		 
		EndIf
	Next nI

	If DXJ->(ColumnPos('DXJ_FRDINI')) > 0
		oModel:SetValue("MdFieldDXJ", "DXJ_FRDINI", cFarIni)
	EndIf
	If DXJ->(ColumnPos('DXJ_FRDFIM')) > 0
		oModel:SetValue("MdFieldDXJ", "DXJ_FRDFIM", cFarFim)
	EndIf
	
	oModel:SetValue("MdFieldDXJ", "DXJ_QTVINC", nTotFar) 
	
	// Faz validação dos dados
	lRet := oModel:VldData()

	//Apresenta Help de Erro
	If !lRet
		Help(,,STR0036,, oModel:GetErrorMessage()[6],1,0) //'Incluir Fardos'
	EndIf

	lMarcAllE	:= .T.
	lMarcAllD	:= .T.
	oView:SetModified()

	FWRestRows( aSaveLine )
Return(lRet)

/** -------------------------------------------------------------------------------------
{Protheus.doc} Pesquisa
Função de pesquisa de registro no Browse

@author Aécio Gomes
@since 02/11/2012
@version 1.0
-------------------------------------------------------------------------------------- **/
Static Function Pesquisa(cChave, cPesquisa, oBrowse)
	Local nX 		:= 0
	Local nPosAc	:= 0

	If Alltrim(Upper(cChave)) == Upper("Fardo")
		for nX := 1 to len(oBrowse:AARRAY) 
			If oBrowse:AARRAY[nX][4] == cPesquisa 
				nPosAc := nX
				exit
			EndIf
		Next
	Else
	 	for nX := 1 to len(oBrowse:AARRAY) 
			If oBrowse:AARRAY[nX][3] == cPesquisa 
				nPosAc := nX
				exit
			EndIf
		Next
	EndIf

	If nPosAc > 0
		oBrowse:GoPosition(nPosAc)
		
	EndIf

Return


/** -------------------------------------------------------------------------------------
{Protheus.doc} A630CLASS
Monta tela para leitura de etiqueta na classificação dos fardos

@author Aécio Gomes
@since 04/04/2013
@version 1.0
-------------------------------------------------------------------------------------- **/
static Function A630CLASS(oPanel)
	Local oEtiq 		:= Nil
	Local cEtiqueta 	:= CriaVar("DXK_ETIQ", .F.)
	Local oView			

	If !__lnewComerc
		oView := FwViewActive()
	EndIf

	cClasVis  := SPACE(TAMSX3("DXK_CLAVIS")[1])
	oSizeClss := FWDefSize():New(.F.)
	oSizeClss:AddObject("TOTAL",100,100,.T.,.T.)
	oSizeClss:SetWindowSize({0,0,oPanel:NHEIGHT,oPanel:NWIDTH})
	oSizeClss:lProp 		:= .T.
	oSizeClss:aMargins 	:= {0,0,3,0}
	oSizeClss:Process()

	@ oSizeClss:aPosObj[1,1], oSizeClss:aPosObj[1,2] TO oSizeClss:aPosObj[1,3], oSizeClss:aPosObj[1,4] LABEL STR0037  OF oPanel PIXEL  //"CLASSIFICAÇÃO"

	@ oSizeClss:aPosObj[1,1]+8, oSizeClss:aPosObj[1,2]+3 SAY STR0038 SIZE 30, 7 PIXEL OF oPanel //"Tipo"
	If  __lnewComerc
		@ oSizeClss:aPosObj[1,1]+15, oSizeClss:aPosObj[1,2]+3 MSGET oClas VAR cClasVis SIZE 30,10 PIXEL OF oPanel;
		F3 "DXA" VALID ExistCPO("DXA",cClasVis) WHEN A630WHEN() PICTURE PesqPict("DXA","DXA_CODIGO")
	elseif !__lnewComerc
		@ oSizeClss:aPosObj[1,1]+15, oSizeClss:aPosObj[1,2]+3 MSGET oClas VAR cClasVis SIZE 30,10 PIXEL OF oPanel;
		F3 "DXA" VALID fClasValid(oView) WHEN A630WHEN() PICTURE PesqPict("DXA","DXA_CODIGO")
	EndIf
	@ oSizeClss:aPosObj[1,1]+8, oSizeClss:aPosObj[1,2]+40 SAY STR0024 SIZE oSizeClss:aPosObj[1,4]-43, 7 PIXEL OF oPanel //"Etiqueta"
	@ oSizeClss:aPosObj[1,1]+15, oSizeClss:aPosObj[1,2]+40 MSGET oEtiq VAR cEtiqueta SIZE oSizeClss:aPosObj[1,4]-43, 10 PIXEL OF oPanel;
	/*F3* ""*/ VALID A635VldEti(@cEtiqueta,@oEtiq) WHEN A630WHEN() PICTURE PesqPict("DXK","DXK_ETIQ")

Return

/** -------------------------------------------------------------------------------------
{Protheus.doc} A635VldEti
Validação da etiqueta no romaneio e atualização do tipo de classificação

@author Aécio Gomes
@since 04/04/2013
@version 1.0
-------------------------------------------------------------------------------------- **/
Static Function A635VldEti(cEtiqueta,oEtiq)
	Local oModel     := FwModelActive()
	Local oView      := FwViewActive()
	Local oMdGridDXK := oModel:GetModel("MdGridDXK")
	Local aArea      := GetArea()
	Local aRows 	 := FwSaveRows()
	Local nPosEtiq   := GdFieldPos("DXK_ETIQ",oMdGridDXK:AHEADER)
	Local nLinha     := 0
	Local nLinhaBkp  := oMdGridDXK:nLine
	Local lRet       := .T.

	if !Empty(cEtiqueta)
		If FwFldGet('DXJ_TIPO') == "1" // Classificação Visual
	
			If Empty(cClasVis)
				lRet := .F.
				Help("",1,STR0019,, STR0039,1,0) //"ATENÇÃO"###"Tipo de Classificação em Branco"
			EndIf
	
			If lRet .And. !Empty(cEtiqueta) .And. (lRet := nPosEtiq > 0)
			
				For nLinha := 1 To oMdGridDXK:Length()
					If oMdGridDXK:GetValue("DXK_ETIQ",nLinha) == cEtiqueta
						lRet := .T.
						oMdGridDXK:Goline(nLinha)
						exit
					endIf
					
					if nLinha == oMdGridDXK:Length()
						lRet := .F.
						Help("",1,STR0019,, STR0040,1,0)	 //"ATENÇÃO"###"A etiqueta lida não foi localizada nos itens do romaneio!"
					endIf
				Next
				
				//-----------------------------------------
				// Valida se o Fardo já foi blocado
				//-----------------------------------------
				If lRet
					dbSelectArea("DXI")
					DXI->(dbSetOrder(1))
					If (lRet := DXI->(MsSeek( FWxFilial("DXI")+oMdGridDXK:GetValue("DXK_SAFRA",nLinha)+oMdGridDXK:GetValue("DXK_ETIQ",nLinha))))
						If !Empty(DXI_BLOCO)
							lRet := .F.
							//"Atenção"###"Não será permitido alterar a classificação, pois este fardo pertence a um bloco."
							Help("",1,STR0019,, STR0041,1,0)		 
						EndIf
					EndIf				
					DXI->(dbCloseArea())
				EndIf
	
				//-----------------------------------------
				// Se passou pelas validações grava o Tipo
				//-----------------------------------------
				If lRet
					oMdGridDXK:SetValue("DXK_CLAVIS", cClasVis)
				EndIf
			EndIf
			If !lRet
				oMdGridDXK:Goline(nLinhaBkp)
			EndIf
		EndIf
	else
		lRet := .T.
	endIF

	//Refresh nos objetos e seta o foco no campo etiqueta
	If !Empty(cEtiqueta)
		oView:Refresh()
		RestArea(aArea)
		FwRestRows(aRows)

		cEtiqueta := CriaVar("DXK_ETIQ", .F.)
		oEtiq:SetFocus()
	EndIf

Return(lRet)

/** -------------------------------------------------------------------------------------
{Protheus.doc} A630WHEN
Valida modo de edição dos campos da classificação

@author Aécio Gomes
@since 04/04/2013
@version 1.0
-------------------------------------------------------------------------------------- **/
Static Function A630WHEN()
	Local lRet 		:= .T.
	Local oModel    := FwModelActive()
	Local oView		:= FwViewActive()

	If (lRet := ValType(oView) == "O" .And. oView:lActivate)

		If (lRet := (IsInCallStack("A630UPDATE")) .and. oModel:lActivate) 
			lRet := oModel:GetValue("MdFieldDXJ","DXJ_TIPO") == "1"
		EndIf
	EndIf

Return(lRet)

/** -------------------------------------------------------------------------------------
{Protheus.doc} AGRA630CPO
Validacao de campos

@author Aécio Gomes
@since 04/04/2013
@version 1.0
-------------------------------------------------------------------------------------- **/
Function AGRA630CPO()
	Local oModel 		:= FwModelActive()
	Local oMdGridDXK	:= oModel:GetModel('MdGridDXK')
	Local aArea		:= GetArea()
	Local lRet			:= .T.
	If __lnewComerc
		DO CASE
			CASE "DXK_CLAVIS" $ ReadVar()
			// Valida se o fardo pertence para não permitir alterar a classificação
			If FwFldGet('DXJ_TIPO') == "1" .And. oMdGridDXK:IsUpdated()
				DXI->( dbSetOrder(1) ) // Safra+Etiqueta
				If DXI->(MsSeek(FWxFilial("DXI")+FwFldGet("DXK_SAFRA")+FwFldGet("DXK_ETIQ")))
					If !Empty(DXI->DXI_BLOCO)
						lRet := .F.
						//"Atenção"###"Não será permitido alterar a classificação, pois este fardo pertence a um bloco."
						Help("",1,STR0019,, STR0041,1,0)		 
					EndIf
				EndIf
			EndIf
	
			// Valida dado inforamado
			If lRet
				lRet := (Vazio() .Or. ExistCPO("DXA") )
			EndIf
		CASE "DXK_CLACON" $ ReadVar()
			// Valida se o fardo pertence para não permitir alterar a classificação
			If FwFldGet('DXJ_TIPO') == "1" .And. oMdGridDXK:IsUpdated()
				DXI->( dbSetOrder(1) ) // Safra+Etiqueta
				If DXI->(MsSeek(FWxFilial("DXI")+FwFldGet("DXK_SAFRA")+FwFldGet("DXK_ETIQ")))
					If !Empty(DXI->DXI_BLOCO)
						lRet := .F.
						//"Atenção"###"Não será permitido alterar a classificação, pois este fardo pertence a um bloco."
						Help("",1,STR0019,, STR0041,1,0)		 
					EndIf
				EndIf
			EndIf
	
			// Valida dado inforamado
			If lRet
				lRet := (Vazio() .Or. ExistCPO("DXA") )
			EndIf		
		CASE "DXJ_CODVAR" $ ReadVar()
			If !Empty(M->DXJ_CODVAR)
				lRet := ExistCPO("NNV",M->DXJ_CODVAR,2)
			EndIf		
		ENDCASE
	Else
		DO CASE
			CASE "DXK_CLAVIS" $ ReadVar()
			// Valida se o fardo pertence para não permitir alterar a classificação
			If FwFldGet('DXJ_TIPO') == "1"
				DXI->( dbSetOrder(1) ) // Safra+Etiqueta
				If DXI->( dbSeek( xFilial("DXI")+FwFldGet("DXK_SAFRA")+FwFldGet("DXK_ETIQ") ) )
					If !Empty(DXI->DXI_BLOCO)
						lRet := .F.
						Help("",1,STR0019,, STR0041,1,0)		 //"Atenção"###"Não será permitido alterar a classificação, pois este fardo pertence a um bloco."
					EndIf
				EndIf
			EndIf

			// Valida dado inforamado
			If lRet
				lRet := (Vazio() .Or. ExistCPO("DXA") )
			EndIf
			CASE "DXJ_CODVAR" $ ReadVar()
			If !Empty(M->DXJ_CODVAR)
				dbSelectArea("NN1")
				lRet := ExistCPO("NNV", Posicione("NN1",1,xFilial("NN1")+M->DXJ_SAFRA,"NN1_CODPRO")+M->DXJ_CODVAR,1)
			EndIf		
		ENDCASE
	EndIf
	RestArea(aArea)
Return(lRet)

/** -------------------------------------------------------------------------------------
{Protheus.doc} A630CODBAR
Criação do código de barras inteligente

@author silvana.torres
@since 27/04/2017
@version 1.0
-------------------------------------------------------------------------------------- **/
Function A630CODBAR()
    Local oModel 		:= FwModelActive()
	Local aArea			:= GetArea()
	Local lRet			:= .T.

	if Alltrim(oModel:GetValue("MdFieldDXJ","DXJ_SAFRA")) != "" .And. Alltrim(oModel:GetValue("MdFieldDXJ","DXJ_CODIGO")) != ""   
		oModel:SetValue("MdFieldDXJ","DXJ_CODBAR",AGRSmartCode("DXJ", oModel:GetValue("MdFieldDXJ","DXJ_SAFRA"), oModel:GetValue("MdFieldDXJ","DXJ_CODIGO"), oModel:GetValue("MdFieldDXJ","DXJ_TIPO"), "ML"))
	else
		oModel:SetValue("MdFieldDXJ","DXJ_CODBAR","")
	endIf
		
	RestArea(aArea)
Return(lRet)

/** -------------------------------------------------------------------------------------
{Protheus.doc} A630FRDINI
Retorno fardo inicial da sequência

@author Bruna Rocio
@since 10/07/2015
@version 1.0
-------------------------------------------------------------------------------------- **/
Function A630FRDINI( cRom )
	Local cFrdIni := ""
	Local aArea		:= GetArea()
	
	dbSelectArea('DXK')
	DXK->(dbSetOrder(1))
	If DXK->(MsSeek( DXJ->DXJ_FILIAL + cRom ))
		cFrdIni := DXK->DXK_FARDO
	Endif
	DXK->(DbCloseArea())
	
	RestArea(aArea)
Return ( cFrdIni )

/** -------------------------------------------------------------------------------------
{Protheus.doc} A630FRDFIM
Retorno fardo final da sequência

@author Bruna Rocio
@since 10/07/2015
@version 1.0
-------------------------------------------------------------------------------------- **/

Function A630FRDFIM( cRom )
	Local cFrdFim   	:= ""
	Local cAliasDXK 	:= GetNextAlias()
	Local aArea     	:= GetArea()
	Local cFilialPos	:= DXJ->DXJ_FILIAL

	BeginSql Alias cAliasDXK
	SELECT MAX(DXK_FARDO) AS frdFim
	FROM %Table:DXK% DXK
	WHERE DXK.%notDel%
	AND DXK_FILIAL = %exp:cFilialPos% 
	AND DXK_CODROM = %exp:cRom%
	EndSQL

	dbSelectArea(cAliasDXK)
	(cAliasDXK)->( dbGoTop() )

	cFrdFim := (cAliasDXK)->frdFim

	(cAliasDXK)->( DbCloseArea() )

	RestArea(aArea)
Return ( cFrdFim )

/** -------------------------------------------------------------------------------------
{Protheus.doc} A630BRWVAR
Retorno descrição da variedade

@author Bruna Rocio
@since 10/07/2015
@version 1.0
-------------------------------------------------------------------------------------- **/

Function A630BRWVAR(  cSafra, cCodVar )
	Local cVar        := ""
	Local cCodPrd     := ""

	If !__lnewComerc
		cCodPrd     := Posicione("NN1",1,FWxFilial("NN1")+cSafra,"NN1_CODPRO")
		dbSelectArea('NNV')
		dbSetOrder(1)
		If dbSeek( FWxFilial('NNV') + cCodPrd + cCodVar )
			cVar := NNV->NNV_DESCRI
		Endif
	Else
		dbSelectArea('NNV')
		NNV->(dbSetOrder(2))
		If NNV->(MsSeek(FWxFilial('NNV') + cCodVar))
			cVar := NNV->NNV_DESCRI
		Endif
		NNV->(dbCloseArea())
	EndIf 	


Return ( cVar )


/** -------------------------------------------------------------------------------------
{Protheus.doc} A630DESVAR
Retorno descrição da variedade

@author Bruna Rocio
@since 10/07/2015
@version 1.0
-------------------------------------------------------------------------------------- **/

Function A630DESVAR( cCodVar )
	Local cVar        := ""
	Local oModel      := FwModelActive()
	Local oMdFldDXJ   := oModel:GetModel('MdFieldDXJ')
	Local cSafra      := ""
	Local cCodPrd     := ""


	If !__lnewComerc
		cSafra      := oMdFldDXJ:GetValue( 'DXJ_SAFRA' )
		cCodPrd     := Posicione("NN1",1,xFilial("NN1")+cSafra,"NN1_CODPRO")
		dbSelectArea('NNV')
		dbSetOrder(1)
		If dbSeek( xFilial('NNV') + cCodPrd + cCodVar )
			cVar := NNV->NNV_DESCRI
		Endif
	Else
		dbSelectArea('NNV')
		NNV->(dbSetOrder(2))
		If NNV->(MsSeek(FWxFilial('NNV') + cCodVar ))
			cVar := NNV->NNV_DESCRI
		Endif
		NNV->(dbCloseArea())
	EndIf


Return ( cVar )


/** -------------------------------------------------------------------------------------
{Protheus.doc} A630DESTAL
Retorno descrição da variedade

@author Bruna Rocio
@since 10/07/2015
@version 1.0
-------------------------------------------------------------------------------------- **/

Function A630DESTAL( cCodTal )
	Local cDes        := ""
	Local oModel      := FwModelActive()
	Local oMdFldDXJ   := oModel:GetModel('MdFieldDXJ')
	Local cSafra      := oMdFldDXJ:GetValue( 'DXJ_SAFRA' )
	Local cFaz        := oMdFldDXJ:GetValue( 'DXJ_FAZ' )

	dbSelectArea('NN3')
	NN3->(dbSetOrder(1))
	If NN3->(MsSeek(FWxFilial('NN3') + cSafra + cFaz + cCodTal))
		cDes := NN3->NN3_DESCRI
	Endif
	NN3->(dbCloseArea())

Return ( cDes )


/** -------------------------------------------------------------------------------------
{Protheus.doc} A630DESTAL
Retorno descrição da variedade

@author Bruna Rocio
@since 10/07/2015
@version 1.0
-------------------------------------------------------------------------------------- **/

Function A630TALHAO( cCodTal, cSafra, cFaz )
	Local cDes        := ""

	dbSelectArea('NN3')
	NN3->(dbSetOrder(1))
	If NN3->(MsSeek(FWxFilial('NN3') + cSafra + cFaz + cCodTal))
		cDes := NN3->NN3_DESCRI
	Endif
	NN3->(dbCloseArea())

Return ( cDes )

/** -------------------------------------------------------------------------------------
{Protheus.doc} retTalhao
Retorno do Talhao 

@author Bruna Rocio
@since 20/07/2015
@version 1.0
-------------------------------------------------------------------------------------- **/
Static Function retTalhao(  cFardao  )
	Local oModel      := FwModelActive()
	Local oMdFldDXJ   := oModel:GetModel('MdFieldDXJ')
	Local cSafra      := oMdFldDXJ:GetValue( 'DXJ_SAFRA' )
	Local cPrdtor     := oMdFldDXJ:GetValue( 'DXJ_PRDTOR' )
	Local cTalhao     := ""

	//DXL_FILIAL+DXL_CODIGO+DXL_SAFRA+DXL_PRDTOR+DXL_LJPRO+DXL_FAZ        
	dbSelectArea('DXL')
	DXL->(dbSetOrder(1))
	If DXL->(MsSeek(FWxFilial('DXL') + cFardao + cSafra + cPrdtor))
		cTalhao := DXL->DXL_TALHAO
	Endif
	DXL->(dbCloseArea())

Return ( cTalhao )


/**-------------------------------------------------------------------------------------
{Protheus.doc} MarcaUm
Marca/Desmarca Posicionado

@author: 	carlos.augusto
@since: 	09/12/2016
@Uso: 		AGRA630
-------------------------------------------------------------------------------------**/
Static Function MarcaUm( oBrwMrk, aItsMrk, nLinMrk, lDir)
	Local lMarca := .T.

	//Marca caso o fardo nÃ£o tenha sido embarcado
	If lDir .And. !Empty(aItsMrk[ nLinMrk, 6 ])
		lMarca := .F.
	EndIf

	If lMarca
		DO CASE      
			CASE aItsMrk[ nLinMrk, 1 ] == "1"
				aItsMrk[ nLinMrk, 1 ] := "2"
				
			CASE aItsMrk[ nLinMrk, 1 ] == "2"
				aItsMrk[ nLinMrk, 1 ] := "1"
		ENDCASE
	EndIf

	oBrwMrk:Refresh()
Return


/**-------------------------------------------------------------------------------------
{Protheus.doc} MovFardos
Responsavel pela transferencia dos registros entre os browsers

@author: 	carlos.augusto
@since: 	09/12/2016
@Uso: 		AGRA630
-------------------------------------------------------------------------------------**/
Static Function MovFardos( cSeta, oBrwEsq, oBrwDir )
	Local aItsOrig 	:= {}
	Local aItsDest 	:= {}
	Local nX		:= 0 
	Local lRet		:= .T.
	Local lMarc		:= .F.

	If INCLUI .Or. ALTERA
		If cSeta == ">"
			aItsOrig 	:= aClone( aItsEsq )
			aItsDest 	:= aClone( aItsDir )
		EndIf
		If cSeta == "<"
			aItsOrig 	:= aClone( aItsDir )
			aItsDest 	:= aClone( aItsEsq )
		EndIf

		For nX := 1 to Len( aItsOrig )

			If nX > Len( aItsOrig )
				Exit
			EndIf
			
			If aItsOrig[ nX, 1 ] = "1"
				lMarc := .T.
				aAdd( aItsDest, aItsOrig[ nX ] )
				aItsDest[ Len( aItsDest ), 1 ] := "2"

				aDel( aItsOrig, nX )
				aSize( aItsOrig, Len( aItsOrig )-1 )
				nX--
			EndIf

		Next nX

		If lRet .And. lMarc
			aItsOrig := ASort( aItsOrig, , , { | x, y | x[ 1 ] + x[ 2 ] < y[ 1 ] + y[ 2 ]})
			aItsDest := ASort( aItsDest, , , { | x, y | x[ 1 ] + x[ 2 ] < y[ 1 ] + y[ 2 ]})

			If cSeta == ">"
				aItsEsq := aClone( aItsOrig )
				aItsDir := aClone( aItsDest )
				lMarcAllE := .T.
				lMarcAllE := .T.
			EndIf

			If cSeta == "<"
				aItsEsq := aClone( aItsDest )
				aItsDir := aClone( aItsOrig )
				lMarcAllE := .T.
				lMarcAllE := .T.
			EndIf

			oBrwEsq:SetArray( aItsEsq )
			oBrwDir:SetArray( aItsDir )
			oBrwEsq:Refresh()
			oBrwDir:Refresh()
		EndIf
		If !lMarc
			Help( , , STR0019, , STR0058, 1, 0 ) //"Atenção"###"Favor selecionar fardos."
		EndIf
	EndIf

	nQtde := Len(oBrwDir:AARRAY) // Total de itens do romaneio
	nPeso := 0
	For nX := 1 To len(oBrwDir:AARRAY)
		nPeso += oBrwDir:AARRAY[nX, 6] //Peso Total de fardos selecionados
	Next
	
Return(lRet)


/**-------------------------------------------------------------------------------------
{Protheus.doc} MarcaAll
Marca/Desmarca Todos

@author: 	carlos.augusto
@since: 	09/12/2016
@Uso: 		AGRA630
-------------------------------------------------------------------------------------**/
Static Function MarcaTudo( oBrwMrk, aItsMrk, nLinMrk, lMark, lDir )
	Local nX	:= 0

	Default lMark := .T.

	For nX := 1 to Len( aItsMrk )                 

		If aItsMrk[ nX, 1 ] $ "1|2"
			aItsMrk[ nX, 1 ] := If(lMark, "1", "2")
		EndIf
	Next nX

	oBrwMrk:Refresh()
	lMark := !lMark
Return( )

/**-------------------------------------------------------------------------------------
{Protheus.doc} ExecGrav
Recebe o Dialog, Browse e Modelo para ser enviado para o método de gravação.
Realiza a gravação antes de fechar o dialog, pois o mesmo anula variaveis.

@author: 	Carlos Augusto Pereira
@since: 	01/12/2016
@Uso: 		AGRA630
-------------------------------------------------------------------------------------**/
Static Function ExecGrav(oDlg, oBrwDir)
	Local oModel 	        := FWModelActive()
	Local lRet := .T.

	Begin Transaction
		oProcess := MsNewProcess():New( { | lEnd | lRet := A630GRAVA(@oBrwDir,@oModel)}, STR0034, STR0035, .F. ) //"Aguarde"###"Atualizando tabela de dados dos itens do romaneio"
		oProcess:Activate()
		If !lRet
			DisarmTransaction()
		EndIf

	End Transaction

	oDlg:End()

Return 

/**-------------------------------------------------------------------------------------
{Protheus.doc} UpdFardos
Reexibe no Grid direito/Esquerdo os fardos adicionados sem confirmação

@author: 	Carlos Augusto Pereira
@since: 	06/12/2016
@Uso: 		AGRA630
-------------------------------------------------------------------------------------**/
Static Function UpdFardos(oAuxDXK, oBrwEsq, oBrwDir)
	Local aAuxDXK := oAuxDXK:adatamodel
	Local nI, nX
	Local aItsEsq := oBrwEsq:AARRAY
	Local lSelec  := .F.

	For nI := 1 To Len(aAuxDXK)
		If !Empty(aAuxDXK[nI][1][1][4])	
			For nX := 1 To Len(aItsEsq)
				If aAuxDXK[nI][1][1][4] = aItsEsq[nX][4]
					//marca para transferir e captura a classificacao
					aItsEsq[nX][1] := "1"
					aItsEsq[nX][7] := aAuxDXK[nI][1][1][6] 
					lSelec := .T.
				Endif
			Next nX
		Endif
	Next nI

	If lSelec
		MovFardos( ">", @oBrwEsq, @oBrwDir )
	EndIf
Return 

/*/{Protheus.doc} A630FchMl
//Função para fecha mala manual.

@author jeferson.chaves
@since 16/02/2017
@version undefined

@type function
/*/
Function A630FchMl()
	Local cDXJ_Stat := "0"
	Local lAberta   := .F.
	Local cAliasDXK := GetNextAlias()
	Local cMaxFard	:= ""
	Local aSaveArea 
	
	If(DXJ->DXJ_STATUS == "7" .And. DXJ->DXJ_QTVINC > 0)
		If(DXJ->DXJ_TIPO == "1") //Visual
			cDXJ_Stat := "1" //Visual Pendente
		Else
			cDXJ_Stat := "4" //HVI Pendente
		EndIf
		
		If(DXJ->DXJ_AUTOMA = "2") //Não é Mala Automática
			If( cDXJ_Stat != "0")
				If RecLock( "DXJ", .F. )
		            DXJ->( DXJ_STATUS ) := cDXJ_Stat
		            DXJ->( MsUnLock() )
		        EndIf
			EndIf						
		Else
			If(cDXJ_Stat != "0")
				If(DXJ->DXJ_QTVINC <= nQtdMl)
					If(DXJ->DXJ_QTVINC = nQtdMl)
						If RecLock( "DXJ", .F. )
				            DXJ->( DXJ_STATUS ) := cDXJ_Stat
				            DXJ->( MsUnLock() )
				        EndIf
					Else
						//#A mala não atingiu a capacidade máxima. Deseja fechá-la?##Atenção
						If MsgYesNo( STR0069, STR0019 )		
							aSaveArea   := GetArea()
						
							BeginSql Alias cAliasDXK
							  SELECT MAX(DXK_FARDO) AS MaxFardo 
							    FROM %Table:DXK% DXK 
							   WHERE DXK_CODROM =  %exp:DXJ->DXJ_CODIGO% 
							     AND DXK_TIPO 	=  %exp:DXJ->DXJ_TIPO%
							EndSQL
						    
						    (cAliasDXK)->(dbGoTop())
						    IF (cAliasDXK)->(!Eof())
						    	cMaxFard := (cAliasDXK)->MaxFardo
						    EndIf
						    
						    (cAliasDXK)->( dbCloseArea() )
				        	RestArea( aSaveArea )
						    				 
							If AGRGRAVAHIS(STR0066,"DXJ",DXJ_FILIAL+DXJ_CODIGO+DXJ_TIPO,"A") = 1
								If RecLock( "DXJ", .F. )
						            DXJ->DXJ_STATUS := cDXJ_Stat
						            DXJ->DXJ_FRDFIM := cMaxFard
						            DXJ->( MsUnLock() )
						        EndIf
						        
						        //Verifica se existe mala par
								If ExistMalaClone(DXJ->DXJ_CODIGO, IIF(DXJ->DXJ_TIPO = '1', '2'/*HVI*/ , '1'/*Visual*/ ), @lAberta)
								              
								    If lAberta .And. MsgYesNo( STR0085, STR0019 ) //#Existe uma mala par para esta, deseja fechá-la também?##Atenção     
								    	dbSelectArea('DXJ')
								    	DXJ->(dbSetOrder(1))
								    	//Manda tipo invertido
								    	If DXJ->(MsSeek(FwXFilial('DXJ')+DXJ->DXJ_CODIGO+IIF(DXJ->DXJ_TIPO = '1', '2'/*HVI*/ , '1'/*Visual*/ )))
								    		If RecLock( "DXJ", .F. )
									            DXJ->DXJ_STATUS := InvertStatus(cDXJ_Stat)
									            DXJ->DXJ_FRDFIM := cMaxFard
									            MsUnLock() 
									        EndIf
								    	Endif          
								    Endif
								Endif
						        
						    EndIf						 
						EndIf							
					EndIf				
				Else
					//#Atenção##A mala ultrapassou a capacidade máxima e não pode ser fechada!
					Help("",1,STR0019,, STR0072,1,0)
				EndIf
			EndIf			
		EndIf
	Else
		If (DXJ->DXJ_STATUS == "7" .And. DXJ->DXJ_QTVINC = 0)
			//#Atenção##Não permitido o fechamento de mala sem amostra!
			Help("",1,STR0019,, STR0082,1,0)
		Else
			//#Atenção##Mala já fechada!
			Help("",1,STR0019,, STR0074,1,0)	
		EndIf		
	EndIf
	
Return .T.

/*/{Protheus.doc} A630LibMl
//Função para liberar mala.

@author silvana.torres
@since 14/07/2017
@version undefined

@type function
/*/
Function A630LibMl()
	
	If DXJ->DXJ_STATUS == "8" /*mala bloqueada*/
		If AGRGRAVAHIS(STR0092,"DXJ",DXJ_FILIAL+DXJ_CODIGO+DXJ_TIPO,"A") = 1
			If RecLock( "DXJ", .F. )
	            DXJ->( DXJ_STATUS ) := "6" /*HVI importado*/
	            DXJ->( MsUnLock() )
	        EndIf
	     EndIF
	Else
		//#Atenção##A mala não está bloqueada!
		Help("",1,STR0019,, STR0091,1,0)			
	EndIf
	
Return .T.

/*/{Protheus.doc} A630HistMl
//Apresenta o histórico da Mala
@author jeferson.chaves
@since 17/02/2017
@version undefined

@type function
/*/
Function A630HistMl()
	Local cChaveI := "DXJ->("+Alltrim(AGRSEEKDIC("SIX","DXJ1",1,"CHAVE"))+")"
    Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))
    
	AGRHISTTABE("DXJ",cChaveA)	
Return

/*/{Protheus.doc} AGRA630BLR
//Essa função passa filtro feito no browse para relatório
@author marina.muller
@since 10/11/2017
@version 6
@return ${return}, ${return_description}

@type function
/*/
Function AGRA630BLR()
	AGRAR630B(oBrowse:FWFilter():GetFilter())
	
Return .T.


/*/{Protheus.doc} A630HviImp
//TODO Descrição auto-gerada.
@author silvana.torres
@since 23/05/2018
@version undefined
@param cCodMala, characters, descricao
@type function
/*/
Static Function A630HviImp(cCodMala)

	Local lRet := .F.
	Local aSaveArea   := GetArea()
	Local cAliasDXJ   := GetNextAlias()	

	BeginSql Alias cAliasDXJ
	  SELECT 1
	    FROM %Table:DXJ% DXJ
	   WHERE DXJ.%NotDel%
	     AND DXJ_FILIAL 	= %xFilial:DXJ% 
	     AND DXJ.DXJ_TIPO 	= '2' //HVI
	     AND DXJ.DXJ_STATUS = '6' //HVI importado
	     AND DXJ.DXJ_CODIGO	=  %exp:cCodMala%
	EndSQL
    
    (cAliasDXJ)->(dbGoTop())
    
    If (cAliasDXJ)->(!Eof())
    	lRet := .T.
	EndIf

    (cAliasDXJ)->( dbCloseArea() )
    RestArea( aSaveArea )
    
Return lRet

/*/{Protheus.doc} A630ClaDXI
//TODO Descrição auto-gerada.
@author silvana.torres
@since 23/05/2018
@version undefined

@type function
/*/
Static Function A630ClaDXI()

	Local lRet := .T.
	Local aSaveArea   := GetArea()
	Local oModel      	:= FwModelActive()
	Local oAuxDXK	    := oModel:GetModel('MdGridDXK')
	Local nX

	For nX := 1 To oAuxDXK:Length()
		oAuxDXK:Goline( nX )
							
		If !oAuxDXK:IsDeleted()				
				
			dbSelectArea("DXI")
			DXI->(dbSetOrder(1))
			
			If DXI->(MsSeek(FWxFilial("DXI")+oAuxDXK:GetValue("DXK_SAFRA")+oAuxDXK:GetValue("DXK_ETIQ")))
				RecLock("DXI",.F.)
				DXI->DXI_STATUS := '20 ' // Classificado
				DXI->(MsUnlock())
			EndIf
			
			DXI->(dbCloseArea())
		EndIf
	Next nx
	
	RestArea( aSaveArea )
					
Return lRet

/*/{Protheus.doc} A630RetSta
//TODO Descrição auto-gerada.
@author silvana.torres
@since 24/05/2018
@version undefined
@param cSafra, characters, descricao
@param cEtiq, characters, descricao
@type function
/*/
Function A630RetSta(cSafra, cEtiq)

	Local lRet := .T.
	Local aSaveArea   := GetArea()

	dbSelectArea("DXI")
	DXI->(dbSetOrder(1))
	
	If DXI->(MsSeek(FWxFilial("DXI")+cSafra+cEtiq))
		If DXI->DXI_STATUS = "20" // Classificado
			RecLock("DXI",.F.)
			DXI->DXI_STATUS := "10" //Beneficiado 
			DXI->(MsUnlock())
		EndIf
	EndIf
	DXI->(dbCloseArea())
	
	RestArea( aSaveArea )

Return lRet

/*/{Protheus.doc} A630AtuSta
Altera o status do fardinho para classificado 
@author silvana.torres
@since 24/05/2018
@version undefined
@param cSafra, characters, descricao
@param cEtiq, characters, descricao
@type function
/*/
Static Function A630AtuSta(cSafra, cEtiq)

	Local lRet := .T.
	Local aSaveArea   := GetArea()

	dbSelectArea("DXI")
	DXI->(dbSetOrder(1))
	
	If DXI->(MsSeek(FWxFilial("DXI")+cSafra+cEtiq))
		RecLock("DXI",.F.)
		DXI->DXI_STATUS := "20" //Classificado 
		DXI->(MsUnlock())
	EndIf
	DXI->(dbCloseArea())
	
	RestArea( aSaveArea )

Return lRet

/*/
@author: 	Carlos Augusto Pereira
@since: 	30/01/2017
@Uso: 		AGRA630
/*/
//-------------------------------------------------------------------------------------**/
Static Function fClasValid(oView)
	Local lRet 			:= .T.
	Local nOperation 	:= oView:GetbuttonWasPressed()

	if Vazio()
		lRet := .T.
	else
		If Empty(nOperation) .Or. nOperation == 0
			lRet := ExistCPO("DXA",cClasVis)
		EndIf
	endIf

Return lRet

