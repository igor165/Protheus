#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA002.CH'

Static __lTP002COPIA	:= .F.
Static lRevisao	:= .F.
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA002()
Cadastro de Linhas
 
@sample	GTPA002()
 
@return	oBrowse  Retorna o Cadastro de Linhas
 
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA002(lHist)

Local oBrowse		:= FWMBrowse():New()
Default lHist := .F.

oBrowse:SetAlias("GI2")
oBrowse:SetDescription(STR0001)	//Cadastro de Linhas
oBrowse:SetMenuDef('GTPA002')
//Seleção do filtro no carregamento do historico

If !lHist
	oBrowse:SetFilterDefault ( "GI2_HIST == '2'")
Else
	oBrowse:SetFilterDefault ( "GI2_HIST == '1'")
	
	oBrowse:AddLegend( "GI2_DEL == '2'","YELLOW"	,	OemToAnsi(STR0049))//Alteração	
	oBrowse:AddLegend( "GI2_DEL == '1'","RED"	,	OemToAnsi(STR0050))//Excluido
	
Endif
oBrowse:SetCacheView(.F.)//Desativando o cache do browse, solução temporario para resolver 
						//problemas com event sendo chamado e pelo execView	
//Criação do botão de historico para browse dos registros ativo
If !FwIsInCall('GTPA002HIS')
	oBrowse:AddButton(STR0047, {|| GTPA002HIS(),GA002Filt(oBrowse)}   ) //Criando botão do historico
	oBrowse:AddButton(STR0039, {|| GTPA002B(),GA002Filt(oBrowse)}   ) //Criando botão do "Caracteristicas/linha"
	oBrowse:AddButton(STR0031, {|| GTPA002A(),GA002Filt(oBrowse)}   ) //Criando botão do "Veículos/Linha"	

	oBrowse:AddButton(STR0054, {|| GTPA002P()	, GA002Filt(oBrowse) }   ) //Perfil de Alocação"#"Linhas
	oBrowse:AddButton(STR0053, {|| GTPA002R()	, GA002Filt(oBrowse) }   ) //Replicar Perfil

EndIf

oBrowse:Activate()
Return ( oBrowse )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA002Filt()
Realiza a limpeza do filtro e adiciona novo filtro
 
 
@return	oModel - Objeto do Model
 
@author	Inovação
@since		20/06/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA002Filt(oBrowse)	
oBrowse:CleanFilter()
oBrowse:SetFilterDefault ( "GI2_HIST == '2'")
RETURN

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel - Objeto do Model
 
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStruGI2	:= FWFormStruct(1,'GI2')	 //-- Recebe a estrututa da Tabela de Linha
Local oStruZTP	:= FWFormModelStruct():New() //-- Recebe a Estrutura da Tabela Virtual - DefStrModel
Local oStruItem	:= FWFormStruct( 1,"G5I" )   //-- Recebe a estrututa da Tabela de Secoes da Linha
Local bPosValid	:= {|oModel|TP002TdOK(oModel)}
Local bLinePos	:= {|oModel|TP002LnOk(oModel)}
Local bCommit	:= {|oModel|TP002Grv(oModel)}
Local bInitData	:= {|oModel|InitData(oModel)}

oStruZTP:AddTable("ZTP",{},STR0014)	//"Inserir Trecho"
LoadStruZTP( oStruZTP )

If FwIsInCallStack('GTPIRJ002') .OR. FwIsInCallStack('GI002Job') .OR. FwIsInCallStack('GI002Receb')
	oStruGI2:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStruGI2:SetProperty('*' , MODEL_FIELD_VALID, {||.T.})
	oStruGI2:SetProperty('*' , MODEL_FIELD_WHEN, {||.T.})
	oStruGI2:SetProperty("GI2_NCATEG", MODEL_FIELD_NOUPD, .F.)	

	oStruItem:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStruItem:SetProperty('*' , MODEL_FIELD_VALID, {||.T.})
	oStruItem:SetProperty('*' , MODEL_FIELD_WHEN, {||.T.})
EndIf

oModel := MPFormModel():New('GTPA002',/*bPreValid*/, bPosValid , /*bCommit*/, /*bCancel*/)

oModel:SetCommit(bCommit)

oModel:AddFields('FIELDGI2',/*cOwner*/,oStruGI2)
oModel:AddFields('FIELDZTP','FIELDGI2', oStruZTP,,, {|| } )

oModel:AddGrid('GRIDG5I','FIELDGI2', oStruItem, /*bLinePre*/, bLinePos)

//Criando a relação da grid de Ida e Volta entre GI2 e G5I, filtrando por sentido 
oModel:SetRelation( 'GRIDG5I', { { 'G5I_FILIAL', 'xFilial( "GI2" )' }, { 'G5I_CODLIN', 'GI2_COD' }, {'G5I_VIA', 'GI2_VIA'},{'G5I_REVISA', 'GI2_REVISA'}}, G5I->(IndexKey(1))) // Adiciona Relacionamento grid ida

// Liga o controle de nao repeticao da linha com a mesma localidade
If FwIsInCallStack('GTPIRJ002') .OR. FwIsInCallStack('GI002Job') .OR. FwIsInCallStack('GI002Receb')
	oModel:GetModel( 'GRIDG5I' ):SetUniqueLine( { 'G5I_LOCALI' } )
EndIf
//Desabilita a Gravação automatica do Model FIELDZTP 
oModel:GetModel( 'FIELDZTP'):SetOnlyQuery ( .T. )

// define o numero maximo de linhas, de acordo com a define MAXGETDAD
oModel:GetModel( 'GRIDG5I' ):SetMaxLine(999999)

oModel:AddCalc( 'TOTAL', 'FIELDGI2', 'GRIDG5I', 'G5I_KM'	, 'TOTKM', 'FORMULA',{|| !oModel:GetModel("GRIDG5I"):IsEmpty() } ,,, {|oModel,nTotalAtual,xValor,lSomando| CalcTotal(oModel,nTotalAtual,xValor,lSomando,"G5I_KM")})
oModel:AddCalc( 'TOTAL', 'FIELDGI2', 'GRIDG5I', 'G5I_TEMPO'	, 'TOTHR', 'FORMULA',{|| !oModel:GetModel("GRIDG5I"):IsEmpty() } ,,, {|oModel,nTotalAtual,xValor,lSomando| CalcTotal(oModel,nTotalAtual,xValor,lSomando,'G5I_TEMPO')})

oModel:SetDescription(STR0001)
oModel:GetModel('FIELDGI2'):SetDescription(STR0002)//"Dados da Linha"
oModel:GetModel('GRIDG5I'):SetDescription(STR0019)//"Trecho da Linha"

oModel:SetActivate(bInitData)

If FwIsInCallStack('GTPI002_01')
	oStruGI2:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStruGI2:SetProperty('*' , MODEL_FIELD_WHEN, {||.T.})
	oStruGI2:SetProperty('*' , MODEL_FIELD_VALID, {||.T.})
	oStruItem:SetProperty('*' , MODEL_FIELD_WHEN, {||.T.})
	oStruItem:SetProperty('*' , MODEL_FIELD_VALID, {||.T.})

	oModel:GetModel('GRIDG5I'):SetOptional(.T.)
EndIf

Return ( oModel )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
 
@sample	ViewDef()
 
@return	oView - Objeto View
 
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
	
Local oModel	:= FwLoadModel("GTPA002")
Local oView		:= FWFormView():New()
Local oStruGI2	:= FWFormStruct(2, 'GI2')
Local oStruZTP  := FWFormViewStruct():New() 
Local oStruItem	:= FWFormStruct(2,'G5I')

LoadStruZTP( oStruZTP, .T. )

If __lTP002COPIA
	oStruGI2:SetProperty('GI2_COD'	 , MVC_VIEW_CANCHANGE , .F. )
	oStruGI2:SetProperty('GI2_LOCINI', MVC_VIEW_CANCHANGE , .F. )
	oStruGI2:SetProperty('GI2_LOCFIM', MVC_VIEW_CANCHANGE , .F. )
	__lTP002COPIA	:= .F.
EndIf

oStruGI2:RemoveField("GI2_HIST")
oStruGI2:RemoveField("GI2_DEL")

If GI2->(FieldPos("GI2_DTLOG")) > 0 
	oStruGI2:SetProperty('GI2_DTLOG'	 , MVC_VIEW_CANCHANGE , .F. )
EndIf
If GI2->(FieldPos("GI2_HRLOG")) > 0
	oStruGI2:SetProperty('GI2_HRLOG'	 , MVC_VIEW_CANCHANGE , .F. )
EndIf
If GI2->(FieldPos("GI2_STATUS")) > 0
	oStruGI2:SetProperty('GI2_STATUS'	 , MVC_VIEW_CANCHANGE , .F. )
EndIf

oStruItem:SetProperty('G5I_SEQ'		, MVC_VIEW_CANCHANGE , .F. )
oStruItem:SetProperty('G5I_LOCALI'	, MVC_VIEW_CANCHANGE , .F. )
oStruItem:SetProperty('G5I_DESLOC'	, MVC_VIEW_CANCHANGE , .F. )

oStruItem:RemoveField("G5I_REVISA")
oStruItem:RemoveField("G5I_HIST")
oStruItem:RemoveField("G5I_DTALT")

oView:SetModel(oModel)
oView:SetDescription(STR0001) 

oView:AddField(	'VIEW_GI2', oStruGI2	, 'FIELDGI2')
oView:AddField(	'VIEW_ZTP', oStruZTP	, 'FIELDZTP')
oView:AddGrid(	'VIEW_G5I', oStruItem	, 'GRIDG5I')

oView:CreateHorizontalBox('SUPERIOR', 40)	
oView:CreateHorizontalBox('MEIO'	, 15)
oView:CreateVerticalBox('MEIOESQ'	, 65, 'MEIO')
oView:CreateVerticalBox('MEIODIR'	, 35, 'MEIO')
oView:CreateHorizontalBox('INFERIOR', 45)

oView:SetOwnerView('VIEW_GI2','SUPERIOR')
oView:SetOwnerView('VIEW_ZTP','MEIOESQ' )

oView:AddOtherObject("OTHER_PANEL1", {|oPanel| InsButton(oPanel)})
oView:SetOwnerView("OTHER_PANEL1",'MEIODIR')

oView:SetOwnerView('VIEW_G5I','INFERIOR')

oView:SetViewProperty("VIEW_G5I", "GRIDDOUBLECLICK", {{|oGrid,cField,nLineGrid,nLineModel| Ga002DbClk(oGrid,cField,nLineGrid,nLineModel)}})

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_GI2'	,STR0016)	//"Definir Linha"
oView:EnableTitleView('VIEW_ZTP'	,STR0017)	//"Inserir Trecho"
oView:EnableTitleView('OTHER_PANEL1',STR0018)	//"_"
oView:EnableTitleView('VIEW_G5I'	,STR0019)	//"TRECHO IDA"


oView:GetModel('GRIDG5I'):SetNoInsertLine(.T.)// Não permite inclusao no grid
oView:GetModel('GRIDG5I'):SetNoDeleteLine(.T.)// Não permite exclusao no grid

Return ( oView )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com opções do menu
 
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.GTPA002' OPERATION 2 ACCESS 0 // #Visualizar
If !FwIsInCall('GTPA002HIS')
	ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.GTPA002'	OPERATION 3 ACCESS 0 // #Incluir
	ADD OPTION aRotina TITLE STR0005	ACTION 'GTP02Rev'			OPERATION 9 ACCESS 0 // #Alterar
	ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.GTPA002'	OPERATION 5 ACCESS 0 // #Excluir
Endif

Return ( aRotina )

//+--------------------------------------------------------------------------
/*/{Protheus.doc} LoadStruZTP()
LoadStruZTP
Description
Cria estrutura no (Model,View) virtual. Estrutura para auxiliar na inserção dos trechos  
@owner lucas.brustolin
@author lucas.brustolin
@since 11/02/2015
@param 	oPar1  --> Objeto com a estrutura dos dados para alteração
			a passagem deve ocorrer por parametro
		lPar1  --> indica qual tipo de estrutura carregar
			-----> .T. = Model (Default)
			-----> .F. = View

@sample Samples
@version P12
/*/
//+--------------------------------------------------------------------------

Static Function LoadStruZTP(oStruct, lView)

Local aArea   := GetArea()
Local bVld1	:= FwBuildFeature(1, "Vazio() .Or. Positivo( Val(FwFldGet('ZTP_SEQ')) ) ")	
Local bVld2	:= FwBuildFeature(1, "Vazio() .Or. ExistCpo('GI1')")	
Local aTrigAux	:= {}

Local nSeq 	:= TamSx3("G5I_SEQ")[1]

DEFAULT lView := .F.

//-------------------------------+
// lView = .T. - Estrutura Model |
//-------------------------------+
If !lView
	
	// ZTP_SEQ - Sequencia do trecho
	oStruct:AddField( ;
	                STR0042       		, ;              	// [01] Titulo do campo //"Seq."
	                STR0042         		, ;              	// [02] ToolTip do campo //"Seq."
	                "ZTP_SEQ" 			, ;              	// [03] Id do Field
	                'C'               	, ;              	// [04] Tipo do campo
	                nSeq           	, ;              	// [05] Tamanho do campo
	                0                 	, ;              	// [06] Decimal do campo
	                bVld1				, ;              	// [07] Code-block de validação do campo
	                Nil	           	, ;              	// [08] Code-block de validação When do campo
	                Nil              	, ;        		// [09] Lista de valores permitido do campo
	                Nil               	, ;              	// [10] Indica se o campo tem preenchimento obrigatório
	                Nil                , ;              	// [11] Code-block de inicializacao do campo
	                Nil               , ;              	// [12] Indica se trata-se de um campo chave
	                .F.                , ;              	// [13] Indica se o campo pode receber valor em uma operação de update.
	                .T.     )          				  	// [14] Indica se o campo é virtual
	
	// ZTP_TRECHO - CODIGO DA LOCALIDADE
	oStruct:AddField( ;
	                STR0057       		, ;              	// [01] Titulo do campo //"Trecho"
	                STR0057         	, ;              	// [02] ToolTip do campo //"Trecho"
	                "ZTP_TRECHO" 		, ;              	// [03] Id do Field
	                'C'               	, ;              	// [04] Tipo do campo
	                TamSx3("GI1_COD")[1] 					,;             // [05] Tamanho do campo
	                0                 	, ;              	// [06] Decimal do campo
	                bVld2			    , ;             // [07] Code-block de validação do campo
	                Nil	           	, ;              	// [08] Code-block de validação When do campo
	                Nil              	, ;        		// [09] Lista de valores permitido do campo
	                Nil               	, ;              	// [10] Indica se o campo tem preenchimento obrigatório
	                Nil                , ;              	// [11] Code-block de inicializacao do campo
	                Nil               , ;              	// [12] Indica se trata-se de um campo chave
	                .F.                , ;              	// [13] Indica se o campo pode receber valor em uma operação de update.
	                .T.     )          				  	// [14] Indica se o campo é virtual
	                
	               
	// ZTP_DESC - DESCRIÇÃO DA ROTA                 
	oStruct:AddField( ;
	                STR0058 		, ;              	// [01] Titulo do campo //"Desc. Local."
	                STR0058		, ;        	// [02] ToolTip do campo	//"Desc. Local."
	                "ZTP_DESC" 			, ;              	// [03] Id do Field
	                'C'               	, ;              	// [04] Tipo do campo
	                TamSx3("GI1_DESCRI")[1], ;          	// [05] Tamanho do campo
	                0                 	, ;              	// [06] Decimal do campo
	                Nil             	, ;              	// [07] Code-block de validação do campo
	                Nil          		, ;              	// [08] Code-block de validação When do campo
	                Nil              	, ;        		// [09] Lista de valores permitido do campo
	                Nil               	, ;              	// [10] Indica se o campo tem preenchimento obrigatório
	                Nil                , ;              	// [11] Code-block de inicializacao do campo
	                Nil               	, ;              	// [12] Indica se trata-se de um campo chave
	                .F.                , ;              	// [13] Indica se o campo pode receber valor em uma operação de update.
	                .T.     )          				  	// [14] Indica se o campo é virtual
	                
	
	// GATILHO - para descrição da localidade do campo fake             
	aTrigAux := FwStruTrigger("ZTP_TRECHO", "ZTP_DESC", "Posicione('GI1',1,xFilial('GI1') + FwFldGet('ZTP_TRECHO'), 'GI1_DESCRI')")
	oStruct:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	
	
	// GATILHO - para adicionar sequencia na grid
	aTrigAux := FwStruTrigger("ZTP_SEQ", "ZTP_SEQ", "GA0002Seq()")
	oStruct:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])

Else
//------------------------------+
// lView = .F. - Estrutura View |
//------------------------------+	

	// ZTP_TRECHO - Sequencia do Trecho 
	oStruct:AddField( ;
					"ZTP_SEQ"		  , ;    	// [01] Campo
					"01"            , ;    	// [02] Ordem
					STR0042          , ;    	// [03] Titulo //"Seq."
					STR0042          , ;   	// [04] Descricao //"Seq."
					Nil	            , ;   	// [05] Help
					"GET"           , ;    	// [06] Tipo do campo   COMBO, Get ou CHECK
					"999"    	  	, ;    	// [07] Picture
							         , ;  	// [08] PictVar
					""			 	 , ;		// [09] F3
					.T. 	 		  ,	;    	// [10] Editavel
						            , ;    	// [11] Folder
					  	           , ;    	// [12] Group
						 			  , ;    	// [13] Lista Combo
						            , ;    	// [14] Tam Max Combo
						         	  , ;    	// [15] Inic. Browse
					.T.     )				 	// [16] Virtual
		
	// ZTP_TRECHO - CODIGO DA Trecho 
	oStruct:AddField( ;
					"ZTP_TRECHO"		  , ;    	// [01] Campo
					"02"            , ;    	// [02] Ordem
					STR0043   		, ; // [03] Titulo //"Loc. Trecho"
					STR0043          , ;   	// [04] Descricao //"Loc. Trecho"
					Nil	            , ;   	// [05] Help
					"GET"           , ;    	// [06] Tipo do campo   COMBO, Get ou CHECK
					"@!"        	  , ;    	// [07] Picture
							         , ;  	// [08] PictVar
					"GI1"			  , ;		// [09] F3
					.T. 	 		  ,	;    	// [10] Editavel
						            , ;    	// [11] Folder
					  	           , ;    	// [12] Group
						 			  , ;    	// [13] Lista Combo
						            , ;    	// [14] Tam Max Combo
						         	  , ;    	// [15] Inic. Browse
					.T.     )				 	// [16] Virtual	

	// ZTP_DESC - DESCRIÇÃO DA Trecho 
	oStruct:AddField( ;
					"ZTP_DESC"	 , ;    	// [01] Campo
					"03"            , ;    	// [02] Ordem
					STR0041	,;// [03] Titulo //"Desc. Trecho"
					STR0041	, ; // [04] Descricao //"Desc. Trecho"
					Nil	            , ;   	// [05] Help
					"GET"           , ;    	// [06] Tipo do campo   COMBO, Get ou CHECK
					"@!"        	  , ;    	// [07] Picture
							         , ;  	// [08] PictVar
					""  			  , ;		// [09] F3
					.F. 	 		  ,	;    	// [10] Editavel
						            , ;    	// [11] Folder
					  	           , ;    	// [12] Group
						 			  , ;    	// [13] Lista Combo
						            , ;    	// [14] Tam Max Combo
						         	  , ;    	// [15] Inic. Browse
					.T.     )				 	// [16] Virtual		 								
	
EndIf

RestArea(aArea)

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} InsButton()
Insere os botões para manipulação dos trechos. 
Inserir, Alterar e Remover
 
@sample	GTPA002()
  
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function InsButton( oPanel )

	//-- Insere botao no objeto oPanel
	@ 23, 010 Button STR0027 	Size 40, 15 Message STR0027		Pixel; // "Inserir"
		Action  (InsTrecho(),ZTPRefresh()) of oPanel 

	//-- Insere botao no objeto oPanel
	@ 23, 060 Button STR0028 	Size 40, 15 Message STR0028		Pixel; // "Alterar"
		Action  (AltExcTrecho(4),ZTPRefresh()) of oPanel
		
	//-- Insere botao no objeto oPanel
	@ 23, 110 Button STR0029 	Size 40, 15 Message STR0029		Pixel; // "Remover"
		Action  (AltExcTrecho(5),ZTPRefresh()) of oPanel	
			
Return

/*/{Protheus.doc} ZTPRefresh
@author jacomo.fernandes
@since 03/03/2017
@version undefined

@type function
/*/
Static Function ZTPRefresh()
Local oView		:= FwViewActive()
Local oModel	:= oView:GetModel()

//-- Limpa os campos apos insercao
If oModel:GetOperation() == MODEL_OPERATION_UPDATE .OR. oModel:GetOperation() == MODEL_OPERATION_INSERT 
	oModel:ClearField('FIELDZTP',"ZTP_SEQ")
	oModel:ClearField('FIELDZTP',"ZTP_TRECHO")
	oModel:ClearField('FIELDZTP',"ZTP_DESC")
	oView:Refresh()	
Endif
Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} InsTrecho()
Insere um novo trecho na grid em sequencia, com base no campo SEQ.
 
@sample	GTPA002()
  
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function InsTrecho()

Local oModel	:= FwModelActive()
Local oTrecho	:= oModel:GetModel('GRIDG5I')
Local n1		:= 0
Local cAuxSeq	:= ""
Local lMsgOk	:= .T.
Local cSeq		:= AllTrim(oModel:GetValue('FIELDZTP',"ZTP_SEQ"))
Local cTrecho	:= AllTrim(oModel:GetValue('FIELDZTP',"ZTP_TRECHO"))

oTrecho:SetNoInsertLine(.F.)// permite inclusao no grid
/*Realizar ajuste para adicionar a linha caso tiver uma sequencia cadastrada*/ 
If !Empty(cSeq) .And. !Empty(cTrecho)	

	// -- Avalia se a sequencia informada é valida
	If VldZTPSeq(3)	
			
		//-- Adiciona o novo trecho na grid Secoes verifica se existe a sequencia inserida
		If oTrecho:SeekLine({{"G5I_SEQ",cSeq }})
			If IsBlind() .or. MsgYesNo(STR0040,STR0037)//'Já Possui uma sequencia nesse valor deseja adicionar?'##'Atenção'
				For n1 := oTrecho:GetLine() to oTrecho:Length() 
					If oTrecho:GetValue('G5I_SEQ',n1) >= cSeq .and. oTrecho:GetValue('G5I_SEQ',n1) != '999'
						oTrecho:GoLine(n1)
						cAuxSeq := Soma1(oTrecho:GetValue('G5I_SEQ'))
						oTrecho:SetValue("G5I_SEQ", cAuxSeq )
					Else
						Exit
					Endif
				Next
				lMsgOk		:= .T.
			Else
				lMsgOk		:= .F.
			Endif
		EndIf
		
		If lMsgOk
			oTrecho:AddLine()
			//Adicionando o novo item na grid
			oTrecho:SetValue("G5I_SEQ"		, cSeq)
			oTrecho:SetValue("G5I_LOCALI"	, cTrecho)
			oTrecho:SetValue("G5I_VENDA"	, "1")
			
			//-- Ordena array com base no campo sequencia	
			GA002Order(oTrecho)
			
			oTrecho:GoLine(1)
		Endif
	EndIf
EndIf	

oTrecho:SetNoInsertLine()// Nao permite inclusao no grid

Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AltExcTrecho()
Altera e Exclui um trecho na grid.
 
@sample	GTPA002()
  
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function AltExcTrecho(nOpc)

Local oModel	:= FwModelActive() 
Local oTrecho	:= oModel:GetModel('GRIDG5I')
Local cSeq		:= AllTrim(oModel:GetValue('FIELDZTP',"ZTP_SEQ"))
Local cTrecho	:= AllTrim(oModel:GetValue('FIELDZTP',"ZTP_TRECHO"))

If nOpc == 4 //Alteração
	
	If !Empty(cSeq) .And. !Empty(cTrecho)	
		If VldZTPSeq(nOpc) 
			//-- Procura a sequencia no grid  na qual deseja alterar o registro
			If oTrecho:SeekLine({ {"G5I_SEQ",cSeq} })
				oTrecho:SetValue("G5I_LOCALI",cTrecho )					
			EndIf		
		EndIf
	EndIf

ElseIf nOpc == 5 //Exclusão
	
	If !Empty(cSeq)
		
		If VldZTPSeq(nOpc) 
			//-- Procura a sequencia nno grid  na qual deseja alterar o registro
			oModel:GetModel('GRIDG5I'):SetNoDeleteLine(.F.)// permite exclusao no grid
			If oTrecho:SeekLine({ {"G5I_SEQ",cSeq} })
				oTrecho:DeleteLine()					
			EndIf
			oModel:GetModel('GRIDG5I'):SetNoDeleteLine()// permite exclusao no grid		
		EndIf
	EndIf

EndIf

//-- Posiciona na primeira linha.
oTrecho:GoLine(1)

Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA002SetTr()
Realiza o gatilho do cabeçalho para grid. Onde é definido 
a localidade de origem e destino da linha.
 
@sample	GTPA002()
  
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------

Function GA002SetTr(cField)
Local oModel	:= FwModelActive()
Local oTrecho	:= oModel:GetModel('GRIDG5I')
Local cSeq		:= ""
Local nSeq 	    := TamSx3("G5I_SEQ")[1]
Local cValue	:= oModel:GetModel('FIELDGI2'):GetValue(cField)
Local cRet		:= cValue 
Local oView		:= nil 

oModel:GetModel('GRIDG5I'):SetNoInsertLine(.F.)// permite inclusao no grid

If cField = "GI2_LOCINI"
	cSeq := StrZero(1,nSeq)
ElseIf cField = "GI2_LOCFIM"
	cSeq := Replicate("9",nSeq )
EndIf

If !oTrecho:SeekLine({{ "G5I_SEQ", cSeq }}) 
	If oTrecho:Length() >= 1 
		oTrecho:GoLine( oTrecho:AddLine() )
	EndIf		
EndIf
oTrecho:SetValue("G5I_SEQ"		, cSeq )
oTrecho:SetValue("G5I_LOCALI"	, cValue)
oTrecho:SetValue("G5I_VENDA"	, "1")
	
GA002Order(oTrecho)
oTrecho:GoLine(1)

If !IsBlind()
	oModel:GetModel('GRIDG5I'):SetNoInsertLine()//Não permite inclusao no grid
	oView:= FwViewActive()
	oView:Refresh('VIEW_G5I')
Endif
Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA0002Seq()
Formata a sequencia digitada, exemplo: tamanho do campo com zero a esquerda.
 
@sample	GTPA002()
  
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GA0002Seq(cValue)
Local oModel	:= FwModelActive()
Local oField	:= oModel:GetModel('FIELDZTP')
Local cRet		:= ""
Local nSeq 	:= TamSx3("G5I_SEQ")[1]
Default cValue	:= oField:GetValue("ZTP_SEQ")

// Formata valor da Sequencia
cRet := StrZero(Val(cValue), nSeq) 
oField:SetValue("ZTP_SEQ",cRet )

Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldZTPSeq()
Valida a sequencia digitada conforme ação executada (Inserção/Alteração/Remoção)
 
@sample	GTPA002()
  
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function VldZTPSeq(nOpc)

Local oModel		:= FwModelActive()
Local oField		:= oModel:GetModel('FIELDZTP')
Local oTrecho		:= oModel:GetModel('GRIDG5I')
Local nSeq 	        := TamSx3("G5I_SEQ")[1]
Local cSeq			:= AllTrim(oField:GetValue("ZTP_SEQ"))
Local cTrecho		:= AllTrim(oField:GetValue("ZTP_TRECHO"))
Local lRet			:= .T.

//-- Avalia Sequencia: Não poderá definir sendo igual a 0, 001 ou Fim 999.
If Empty(cSeq) .Or. Val(cSeq) == 0 .or.  cSeq = StrZero(1, nSeq) .Or. cSeq = Replicate("9",nSeq)
	Help( ,, 'Help',"GTPA002", STR0021, 1, 0 )//A sequência informada não poderá ser igual a de inicio, fim ou zero.
	lRet := .F.
EndIf

//-- Validação da inserção do trecho 
If lRet .And. nOpc = 3
	//-- Avalia Trecho: Se o mesmo já foi inserido.
	If oTrecho:SeekLine( {{"G5I_LOCALI", cTrecho}})  
		Help( ,, 'Help',"GTPA002", STR0023, 1, 0 )//O trecho informado já foi definido para uma outra sequência.
		lRet := .F.
	EndIf

//-- Validação da alteração do trecho
ElseIf lRet .And. nOpc = 4
	//-- Avalia Sequencia: Se a sequencia informada consta no trecho para efetuar alteracao da mesma.
	If !oTrecho:SeekLine({ {"G5I_SEQ",cSeq} })
		Help( ,, 'Help',"GTPA002", STR0025, 1, 0 )//A sequência informada não consta em nenhum trecho abaixo:
		lRet := .F.
	ElseIf oTrecho:GetValue("G5I_LOCALI") == cTrecho
		Help( ,, 'Help',"GTPA002", STR0024, 1, 0 ) //Sequência e Trecho já foram definidos na seção abaixo.
		lRet := .F.
	EndIf
	
//-- Validação da remoção do trecho
ElseIf lRet .And. nOpc = 5
	//-- Avalia Sequencia: Se a sequencia informada consta no trecho para efetuar o delete da mesma.
	If !oTrecho:SeekLine({ {"G5I_SEQ",cSeq} })
		Help( ,, 'Help',"GTPA002", STR0025, 1, 0 )//A sequência informada não consta em nenhum trecho abaixo:
		lRet := .F.
	EndIf
EndIf
oTrecho:GoLine(1)

Return(lRet)
	

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ga002DbClk()
Ação de double click na grid de localidade caso usuário precise alterar um linha do grid ou deletar
dando double click na linha os dados necessario será passada para realizar ação desejada

@sample	GTPA002()
  
@author	Inovação
@since		21/02/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function Ga002DbClk(oGrid,cField,nLineGrid,nLineModel)

Local oModel	:= FwModelActive()
Local oView		:= FWViewActive()
Local oMdlZTP	:= oModel:GetModel('FIELDZTP')
Local oMdlGrid	:= oGrid:GetModel('GRIDG5I')
Local lRet		:= .T.
If (oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE ) .and. ;
	( cField == 'G5I_SEQ' .Or. cField == 'G5I_LOCALI' .OR.  cField == 'G5I_DESLOC')
	
	//Passando os valores para field ZTP
	oMdlZTP:SetValue('ZTP_SEQ',OMdlGrid:GetValue('G5I_SEQ'))
	oMdlZTP:SetValue('ZTP_TRECHO',OMdlGrid:GetValue('G5I_LOCALI'))
	
	oMdlGrid:GoLine(1)
	oView:Refresh()	
EndIf
Return (lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA002Order
Ordena a grid conforme a sequencia

@sample	GA002Order(oGridG5I)
@param oGridG5I, object ,Grid utilizada para os trechos
@author	Inovação
@since		03/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GA002Order(oGridG5I)

Local n1		:= 0
Local n2		:= 1
Local aDataMdl	:= aClone(oGridG5I:GetData())
Local aStruct	:= oGRIDG5I:GetStruct():aFields
Local nPosSeq	:= aScan(aStruct,{|x| x[3] == "G5I_SEQ"})
Local aSeq		:= {}

//Adiciona no aSeq as sequencias apenas das linhas ativas
aEval( aDataMdl,{|x,y| If(!x[3]/*Deletado?*/, aAdd(aSeq,x[1,1,nPosSeq] ) , ) } )

//Ordena o aSeq conforme as sequencias
aSort(aSeq,,,{|x,y| x < y })

If nPosSeq > 0
	For n1 := 1 to oGRIDG5I:Length()
		If !oGRIDG5I:IsDeleted(n1)
			If oGRIDG5I:GetValue("G5I_SEQ",n1) <> aSeq[n2]
				nLineGrd	:= aScan(oGridG5I:GetData(),{|x| x[1,1,2] == aSeq[n2] .and. !x[3] }) //Busca a linha ativa que contem a sequencia
				If nLineGrd > 0
					oGRIDG5I:LineShift(n1,nLineGrd) //Troca a linha com a outra
				Endif	
			Endif
			n2++
		Endif
	Next
Endif
oGRIDG5I:GoLine(1)
aSize(aDataMdl,0)
aDataMdl := nil
aSize(aSeq,0)
aSeq := nil

Return

/*/{Protheus.doc} CalcTotal
@author jacomo.fernandes
@since 06/03/2017
@version undefined
@param oModel, object, descricao
@param nTotalAtual, numeric, descricao
@param xValor, , descricao
@param lSomando, logical, descricao
@param cCampo, characters, descricao
@type function
/*/
Static Function CalcTotal(oModel,nTotalAtual,xValor,lSomando,cCampo)
Local nRet	:= 0
Local nVal	:= 0 
Local nTot	:= 0 
Local xRet	:= X3Picture(cCampo)
Local cCpoGI2	:= ""
If cCampo == "G5I_TEMPO"
	nVal	:= HoraToInt(GTFormatHour(xValor,'99:99'))
	cCpoGI2	:= "GI2_HRPADR"
	xRet := StrTran(xRet,"@R ","")
	xRet := StrTran(xRet,":",".")
	nTot := Val(xRet)
Else
	nVal	:= xValor
	cCpoGI2	:= "GI2_KMTOTA"
	xRet := StrTran(xRet,"@E ","")
	xRet := StrTran(xRet,",","")
	nTot := Val(xRet)
Endif
If lSomando 
	nRet := nTotalAtual + nVal
Else
	nRet := nTotalAtual - nVal
Endif
IF nRet > nTot 
	nRet := nTot
Endif
If oModel:GetOperation() <> MODEL_OPERATION_DELETE .and. oModel:GetOperation() <> MODEL_OPERATION_VIEW
	oModel:GetModel('FIELDGI2'):SetValue(cCpoGI2,If(cCampo == "G5I_TEMPO", GTFormatHour(IntToHora(nRet),'9999'),nRet))
Endif
Return nRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Funcao para chamar o Adapter para integracao via Mensagem Unica 

@sample 	IntegDef( cXML, nTypeTrans, cTypeMessage )
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				'0'- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				'1'- para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				'20' - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				'21' - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				'22' - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				'23' - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return  	aRet[1] - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.)
			aRet[2] - String contendo informacoes sobre o processamento
			aRet[3] - String com o nome da mensagem Unica deste cadastro                        
@author  	Jacomo Lisa
@since   	15/02/2017
@version  	P12.1.8
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Return GTPI002( cXml, nTypeTrans, cTypeMessage )

/*/{Protheus.doc} GA002VldLc
@author jacomo.fernandes
@since 06/03/2017
@version undefined
@param cField, characters, descricao
@type function
/*/
//-------------------------------------------------------------------
Function GA002VldLc(cField)
Local lRet := .T.
Local oModel	:= FwModelActive()
Local oTrecho	:= oModel:GetModel('GRIDG5I')
Local cSeq		:= ""
Local nSeq 	    := TamSx3("G5I_SEQ")[1]
Local cValue	:= oModel:GetModel('FIELDGI2'):GetValue(cField)
DEFAULT cField	:= SubStr(ReadVar(),3) //Remove o "M->" de M->GI2_LOCXXX
If cField = "GI2_LOCINI"
	cSeq := StrZero(1,nSeq)
ElseIf cField = "GI2_LOCFIM"
	cSeq := Replicate("9",nSeq )
EndIf

If !Empty(cSeq) .and. !Empty(cValue) 
	lRet := ExistCpo("GI1",cValue,1) 
	
	If lRet .and. oTrecho:SeekLine({{ "G5I_LOCALI", cValue }}) .and. oTrecho:GetValue("G5I_SEQ") <> cSeq
		lRet := .F.
		Help( ,, 'Help',"GA002VldLc", STR0023, 1, 0 )//O trecho informado já foi definido para uma outra sequência.
	EndIf

Endif

Return lRet

/*/{Protheus.doc} TP002TdOK
Validação antes do commit
@author Inovação 
@since 11/04/2017
@version undefined
@param oModel
@type function
/*/
//-------------------------------------------------------------------
Static Function TP002TdOK(oModel)
Local lRet		:= .T.
Local lInt      := .T.
Local oMdlG5I	:= oModel:GetModel('GRIDG5I')
Local oMdlGI2	:= oModel:GetModel('FIELDGI2')
Local nI		:= 0
Local nY		:= 0
Local nTotVend	:= 0
Local nX		:= 1
Local lVersi	:= .T.
Local lver		:= .T.	
Local cValExt   := ""

// Realiza validação, caso tenha apenas 2 localidade
//Não podendo que os 2 seja nao venda ou um deles seja venda
//Verifica tamanho do array caso for menor ou igual 2 será iniciada a validação 
If FwIsInCallStack('GTPIRJ002') .OR. FwIsInCallStack('GI002Job') .OR. FwIsInCallStack('GI002Receb')
	If oMdlG5I:Length(.T.) <= 2 

		For nI	:= 1 to oMdlG5I:Length()
			If !oMdlG5I:IsDeleted(nI) .and. oMdlG5I:GetValue('G5I_VENDA',nI) != "1"
				If !IsBlind()
					Help( ,, 'Help',"TP002TdOK", STR0044, 1, 0 )//Localidade não pode ser venda igual a não!
				Else
					oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"TP002TdOK",STR0044)//Localidade não pode ser venda igual a não!
				Endif
				lRet := .F.
				exit
			EndIf
		Next

	Else

		For nY := 1 to oMdlG5I:Length()
			If !oMdlG5I:IsDeleted(nY) .and. oMdlG5I:GetValue('G5I_VENDA',nY) != "2"	
				nTotVend++
				If nTotVend >= 2
					Exit
				Endif
			EndIf
		Next
		If nTotVend < 2
			If !IsBlind()
				Help( ,, 'Help',"TP002TdOK", STR0044, 1, 0 )//Localidade não pode ser venda igual a não!
			Else
				oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"TP002TdOK",STR0044)//Localidade não pode ser venda igual a não!
			Endif
			lRet := .F.
			
		EndIf

	EndIf

	//Verifica chave duplicada
	If lRet .And. (oMdlGI2:GetOperation() == MODEL_OPERATION_INSERT) .And. !lRevisao 
		
		If (!ExistChav("GI2", oMdlGI2:GetValue("GI2_COD"))) 
			If !IsBlind()
				Help( ,, 'Help',"TP002TdOK", STR0045, 1, 0 )//Chave duplicada!
			Else
				oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"TP002TdOK",STR0045)//Chave duplicada!
			Endif
			lRet := .F.
			
		EndIf
		
	EndIf
EndIf

//Revisão para alteração do cadastro
If oModel:GetOperation() == MODEL_OPERATION_DELETE
	
	cValExt := GTPxExcInt("GI2", "GI2_COD", GI2->GI2_COD)
	If !Empty(cValExt)
		Help(,,'GTPA002DELINTEGR',, "Linhas de integração não podem ser Excluídas!" ,1,0)
		lInt := .F.
	EndIf
EndIf
If lInt
//Revisão para alteração do cadastro
	If	!oModel:GetOperation() == MODEL_OPERATION_DELETE .And. lVersi == .T.
		oMdlGI2:SetValue('GI2_DTALT', DDATABASE)
		oMdlGI2:SetValue('GI2_HIST', '2')
		oMdlGI2:SetValue('GI2_DEL', '2')
		For nX	:= 1 to oMdlG5I:Length()
			
			oMdlG5I:GoLine(nX)
			oMdlG5I:SetValue('G5I_REVISA',oMdlGI2:GetValue('GI2_REVISA'))
			oMdlG5I:SetValue('G5I_HIST', '2')
		
		Next nX
	//Revisão para deleção do registro, transformando em apenas historico
	ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE .And. lVersi == .T.
		
		//Verifica variavel do sistema para o versionamento
		If SuperGetMv('MV_TPREV') == '1'
			If IsBlind() .or. MsgYesNo(STR0048,STR0037) //" Deseja versionar o Registro""Atenção"
				lver		:= .T.
			Else
				lver		:= .F.
			Endif
		ElseIf SuperGetMv('MV_TPREV') == '2'
			lver		:= .T.
		ElseIf SuperGetMv('MV_TPREV') == '3'
			lver		:= .F.
		EndIf
		
		If lver
			//Desativando o modelo para realizar mudança para update e reativando o modelo
			oModel:DeActivate()
			oModel:SetOperation(4)
			oModel:Activate()
			
			oMdlGI2:SetValue('GI2_DTALT', DDATABASE)
			oMdlGI2:SetValue('GI2_HIST', '1')
			oMdlGI2:SetValue('GI2_DEL', '1')
			For nX	:= 1 to oMdlG5I:Length()
				
				oMdlG5I:GoLine(nX)
				oMdlG5I:SetValue('G5I_DTALT', DDATABASE)
				oMdlG5I:SetValue('G5I_HIST', '1')
			
			Next nX
		EndIf
	Else

		//Adicionando nuemro da revisão na inclusão
		oMdlGI2:SetValue('GI2_HIST', '2')
		
		For nX	:= 1 to oMdlG5I:Length()
			oMdlG5I:GoLine(nX)
			oMdlG5I:SetValue('G5I_HIST', '2')
			oMdlG5I:SetValue('G5I_REVISA', oMdlGI2:GetValue('GI2_REVISA'))
		Next nX	

	EndIf
EndIf
Return ( lRet )

/*/{Protheus.doc} TP002LnOk
Verifica se localidade de inicio e fim está com flag sim no campo vendas
@author Inovação 
@since 11/04/2017
@version undefined
@param oModel
@type function
/*/
//-------------------------------------------------------------------
Static Function TP002LnOk(oModel)
Local lRet		:= .T.
//Validalidação do campo de venda
If FwIsInCallStack('GTPIRJ002') .OR. FwIsInCallStack('GI002Job')
	If !(oModel:GetValue('G5I_VENDA',1) == '1' .And. oModel:GetValue('G5I_VENDA',oModel:Length()) == '1')
		lRet	:= .F.
		Help( ,, 'Help',"TP002LnOk", STR0046, 1, 0 )// Localidade Início e Localidade Fim, status da venda obrigatório para 'Sim'
	EndIf 
EndIf
Return(lRet)

/*/{Protheus.doc} GTP02Rev
Verifica se vai realizar versionamento ou alteração padrão
@author Inovação 
@since 11/04/2017
@version undefined
@param oModel
@type function
/*/
//-------------------------------------------------------------------
Function GTP02Rev()
Local lver

If SuperGetMv('MV_TPREV') == '1'
	If IsBlind() .or. MsgYesNo(STR0048,STR0037) //" Deseja versionar o registro ?""Atenção"
		lver		:= .T.
	Else
		lver		:= .F.
	Endif
ElseIf SuperGetMv('MV_TPREV') == '2'
	lver		:= .T.
ElseIf SuperGetMv('MV_TPREV') == '3'
	lver		:= .F.
EndIf

If lver
	__lTP002COPIA := .T.
	lRevisao  := .T.
	if !IsBlind()
		FWExecView(STR0028,"GTPA002",OP_COPIA,,{|| .T.}) //"Revisão" / "Alterar"
	endif
Else
	if !IsBlind()
		FWExecView(STR0028,"GTPA002",MODEL_OPERATION_UPDATE,,{|| .T.}) //"Alteração" / "Alterar"
	endif
EndIf

lRevisao  := .F.

Return 

/*/{Protheus.doc} TP002Grv
//Bloco de commit customizado
@author Inovação 
@since 11/04/2017
@version undefined
@param oModel
@type function
/*/
//-------------------------------------------------------------------

Static Function TP002Grv(oModel)
Local lRet		:= .T.
Local lJob      := .T.
Local oMdlGI2	:= oModel:GetModel("FIELDGI2")
Local cCod		:= oMdlGI2:GetValue('GI2_COD')
Local cRevisa	:= oMdlGI2:GetValue('GI2_REVISA')
Local nOp		:= oModel:GetOperation()
Local aArea		:= GetArea()
//Valida o commite de GI4

FwFormCommit(oModel)// Realizando commite no GI2 e G5I

If nOp == MODEL_OPERATION_INSERT .And. lRevisao == .T.

	If cRevisa != '000'
		cRevisa := StrZero(Val(cRevisa)-1,tamsx3('GI3_REVISA')[1])
	EndIf
	//Desativa o registro anterior
	dbSelectArea("GI2")
	GI2->(dbSetOrder(3))//GI2_FILIAL + GI2_COD + GI2_REVISA
	If GI2->(dbSeek(xFilial("GI2")+cCod+cRevisa)) 
		GI2->(RecLock(("GI2"),.F.))
		GI2->GI2_HIST:= "1"
		GI2->(MsUnlock())
		GI2->(dbSkip())
	EndIf
	
		
	dbSelectArea("G5I")
	G5I->(dbSetOrder(4))//G5I_FILIAL+G5I_CODLIN+G5I_REVISA                                                                                                                        
	
	If G5I->(dbSeek(xFilial("G5I")+cCod+cRevisa))
		While G5I->(!Eof()) .AND. G5I->G5I_CODLIN == cCod .And. G5I->G5I_REVISA == cRevisa
			G5I->(RecLock(("G5I"),.F.))
			G5I->G5I_HIST:= "1"
			G5I->(MsUnlock())
			G5I->(dbSkip())
		EndDo
	EndIf
		
EndIf	

StartJob("GTPA002F",GetEnvServer(),.F.,lJob,cEmpAnt,cFilAnt,cCod,cRevisa,nOp,lRevisao)

RestArea(aArea)
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} InitData
Inicializador caso seja feito versionamento
@author Inovação 
@since 11/04/2017
@version undefined
@param oModel
@type function
/*/
//-------------------------------------------------------------------

Static Function InitData(oModel)
Local oMdlGI2		:= oModel:GetModel('FIELDGI2')
Local cNewRev		:= StrZero(Val(GI2 -> GI2_REVISA)+1,tamsx3('GI2_REVISA')[1])
Local cOrgao		:= GI2 -> GI2_ORGAO 
//Inicializando os dados 
If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !lRevisao 
	
	cNewRev	:= Replicate('0',tamsx3('GI2_REVISA')[1]) 
	oMdlGI2:LoadValue('GI2_HIST', '2')
	oMdlGI2:LoadValue('GI2_REVISA', cNewRev)
	oMdlGI2:LoadValue('GI2_DEL', '2')
	
ElseIf oModel:GetOperation() != MODEL_OPERATION_DELETE .And. lRevisao 
	
	oMdlGI2:LoadValue('GI2_HIST', '2')
	oMdlGI2:LoadValue('GI2_REVISA', cNewRev)
	oMdlGI2:LoadValue('GI2_DEL', '2')
	oMdlGI2:LoadValue('GI2_ORGAO', cOrgao)

EndIF
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA002His
@author Inovação 
@since 11/04/2017
@version undefined
@param oModel
@type function
Realiza chamada do browse com lista de todos historico
/*/
//-------------------------------------------------------------------
Function GTPA002His()
Return GTPA002(.t.) 


/*/{Protheus.doc} GA002LoadGI2(oModel,cIdSubMdl)
	Carrega os dados do submodelo de cIdSubMdl na ativação do modelo de dados
	@type  Function
	@author Fernando Radu Muscalu
	@since 02/06/2017
	@version version
	@param	oModel, objeto, instância da Classe FwFormModel
			cIdSubMdl, caractere, Id do Submodelo da tabela GI2
	@return .t., lógico, retorna verdadeiro
	@example
	(examples)
	@see (links_or_references)
/*/
Function GA002LoadGI2(oModel,cIdSubMdl)

oModel:GetModel(cIdSubMdl):LoadValue("GI2_COD",GI2->GI2_COD)
oModel:GetModel(cIdSubMdl):LoadValue("DSCLINHA",TPNomeLinh(oModel:GetModel("GI2MASTER"):GetValue("GI2_COD")))

Return(.t.)

/*/{Protheus.doc} GA002StrGI2(oStrGI2,cProgram)
	Ajusta a estrutura da tabela GI2 
	@type  Function
	@author Fernando Radu Muscalu
	@since 02/06/2017
	@version version
	@param	oModel, objeto, instância da Classe FwFormModel
			cIdSubMdl, caractere, Id do Submodelo da tabela GI2
	@return .t., lógico, retorna verdadeiro
	@example
	(examples)
	@see (links_or_references)
/*/
Function GA002StrGI2(oStrGI2,cProgram,cTipo)

Default cProgram := "GTPA002"

If ( "GTPA002" <> cProgram )

	If ( cTipo == "M" )	//Estrutura do Modelo de dados
		
		oStrGI2:AddField(	STR0051,;     				    // 	[01]  C   Titulo do campo   //"Desc. Linha"
							STR0052,;	                    // 	[02]  C   ToolTip do campo  //"Descrição Linha"
							"DSCLINHA",;	    			// 	[03]  C   Id do Field
							"C",;				    		// 	[04]  C   Tipo do campo
							TamSx3("GI1_DESCRI")[1]*2+1,;		// 	[05]  N   Tamanho do campo
							0,;						        // 	[06]  N   Decimal do campo
							Nil,;							// 	[07]  B   Code-block de validação do campo
							Nil,;							// 	[08]  B   Code-block de validação When do campo
							Nil,;							//	[09]  A   Lista de valores permitido do campo
							.F.,;							//	[10]  L   Indica se o campo tem preenchimento obrigatório
							Nil,;							//	[11]  B   Code-block de inicializacao do campo
							.F.,;							//	[12]  L   Indica se trata-se de um campo chave
							.F.,;							//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
							.T. )							// 	[14]  L   Indica se o campo é virtual
		
	Else
		//Adiciona os campos para a View
		oStrGI2:AddField(	"DSCLINHA",;			    	// [01]  C   Nome do Campo
							'02',;				// [02]  C   Ordem
							STR0051,;			// [03]  C   Titulo do campo "Desc. Linha"
							STR0052,;     // [04]  C   Descricao do campo "Descrição da Linha"
							{STR0052},;	// [05]  A   Array com Help "Descrição da Linha"
							"GET",;					    	// [06]  C   Tipo do campo
							"",;							// [07]  C   Picture
							NIL,;							// [08]  B   Bloco de Picture Var
							"",;							// [09]  C   Consulta F3
							.F.,;							// [10]  L   Indica se o campo é alteravel
							NIL,;							// [11]  C   Pasta do campo
							"",;							// [12]  C   Agrupamento do campo
							NIL,;							// [13]  A   Lista de valores permitido do campo (Combo)
							NIL,;							// [14]  N   Tamanho maximo da maior opção do combo
							NIL,;							// [15]  C   Inicializador de Browse
							.T.,;							// [16]  L   Indica se o campo é virtual
							NIL,;							// [17]  C   Picture Variavel
							.F.)							// [18]  L   Indica pulo de linha após o campo

		GTPOrdVwStruct(oStrGI2,{{"GI2_COD","DSCLINHA"}})						

		//Ajusta as propriedades das estruturas
		oStrGI2:SetProperty("GI2_COD",MVC_VIEW_CANCHANGE,.F.)	

	EndIf

EndIf

Return(.t.)
