#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PLSA260.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260MENU
Verifica se os dados podem ser inclusos/alterados 
@author Totvs
@since 13/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLA260VLDEP(nOperation,lAutomato)
Local lRet := .T.
Local aArea		 := GetArea()
Local aAreaBA3   := BA3->(GetArea())
Local nOrdBA1    := BA1->(IndexOrd())
Local nRecBA1    := BA1->(Recno())
Local nOrdBQC    := BQC->(IndexOrd())
Local nRecBQC    := BQC->(Recno())
Local bRest      := { || BA1->(DbSetOrder(nOrdBA1)), BA1->(DbGoTo(nRecBA1)) }
Local bRestBQC   := { || BQC->(dbSetorder(nOrdBQC)), BQC->(dbGoto(nRecBQC)) }
Local oModel     := FWModelActive()

Default lAutomato	:= .F.


//Ja esta posicionado no titular.
BA3->( dbSetorder(01) )
BA3->( MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
BI3->( dbSetorder(01) )
BI3->( MsSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))


If lJuridico 

	If (!Empty(BQC->BQC_DATBLO) .and. !Empty(BQC->BQC_CODBLO)) .and. (nOperation <> MODEL_OPERATION_VIEW)
		If(!lAutomato,Aviso(OemtoAnsi(STR0011),OemtoAnsi(STR0012) ,{OemtoAnsi(STR0015)}),)//"Este subcontrato encontra-se bloqueado. So sera permitido a visualizacao dos registros ja existentes!"
       
		DbSelectArea("BA1")

		Return(.F.)
	
	ElseIf (nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE)
		//BA3->( dbSetorder(01) )
		//BA3->( MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
		If !Empty(BA3->BA3_MOTBLO) 

			If(!lAutomato,Aviso(OemtoAnsi(STR0013),OemtoAnsi(STR0014) ,{OemtoAnsi(STR0015)}),) //"Esta familia encontra-se bloqueada, o registro somente podera ser visualizado."
				
				DbSelectArea("BA1")
				Return (.F.)
		Endif				
	EndIF
EndIF

If (nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE)
	If BA1->BA1_TIPUSU <> 'T' .and. !lAutomato
		MsgAlert('Para inclusão do dependente é necessário posicionar no titular.','Aviso')
		Return
	Endif   	
Endif 


If nOperation == MODEL_OPERATION_DELETE
	If BA1->BA1_TIPUSU	<> 'T'	
		If If(!lAutomato,MsgYesNo(OemtoAnsi(STR0054)),) .or. lAutomato	 //"Deseja realmente excluir o Usuario/Familia?"
			If ! PLSA260Exc(BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_MATRIC,.T.)
				Eval(bRest)
				Eval(bRestBQC)
			//Refaz o filtro...							
				DbSelectArea("BA1")
				Return  
			Endif
		Endif
	Else
		If(!lAutomato,MsgAlert('Para exclusão nessa rotina somente dependentes.','Aviso'),)
		Return(NIL)			
	Endif 			

Endif

If lRet .and. !lAmbos 
	If(!lAutomato,FWExecView('','PL260DEPMVC', nOperation,, { || .T. } ),)
ElseIf lAmbos .AND. nOperation == MODEL_OPERATION_INSERT 
	If(!lAutomato,MsgAlert('NÃ£o foi possivel realizar inclusão ao selecionar a opção Pesquisar no Pergunte.','Aviso'),)
EndIF


RestArea(aAreaBA3)
RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo MVC PL260DEPMVC 
@author  totver
@version P12
@since   26/07/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Static oModel			
	Local oStruBA3 		:= FWFormStruct( 1, 'BA3'    , { |cCampo| PLS260CamMenu('BA3',cCampo,'S') })
	Local oStruBA1 		:= FWFormStruct( 1, 'BA1'    , { |cCampo| PLS260CamMenu('BA1',cCampo,'S') })
	Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC","BA1_CONEMP","BA1_VERCON","BA1_SUBCON","BA1_VERSUB"} // Campos a serem adicionado na estrutura
	
	Local aCamposBA3	:= {"BA3_TIPOUS","BA3_CODEMP","BA3_CONEMP","BA3_VERCON","BA3_SUBCON","BA3_VERSUB",;
							"BA3_DATBAS","BA3_MATRIC","BA3_FORPAG","BA3_FORCTX"} // Campos a serem adicionado na estrutura	
	
							
	Local nNx

	
	oModel := MPFormModel():New('PL260DEPMVC')	
	inclui := .F.
		
	oStruBA1:RemoveField( 'BA1_EQUIPE')
	oStruBA1:RemoveField( 'BA1_NOMEQ' )
	oStruBA1:RemoveField( 'BA1_CODVEN')
	oStruBA1:RemoveField( 'BA1_NOMVEN')
	oStruBA1:RemoveField( 'BA1_NOMVE2')
	oStruBA1:RemoveField( 'BA1_CODVE2')	
	oStruBA3:RemoveField( 'BA3_EQUIPE')
	oStruBA3:RemoveField( 'BA3_NOMEQ' )

	//inicialização do campo matricula do titular

	oStruBA3:AddField(	 	;
				"Matricula Titular"		, ;	// [01] Titulo do campo		
				"Matricula Titular"		, ;	// [02] ToolTip do campo	
				"MATTIT"				, ;	// [03] Id do Field
				"C"						, ;	// [04] Tipo do campo
				17						, ;	// [05] Tamanho do campo
				0 						, ;	// [06] Decimal do campo
				{ || .T. }				, ;	// [07] Code-block de validação do campo
				{ || .F. }				, ;	// [08] Code-block de validação When do campo
										, ;	// [09] Lista de valores permitido do campo
				.F.						,;	// [10] Indica se o campo tem preenchimento obrigatÃ¯Â¿Â½rio
				{ || RetTitular(1)} 				)// [11] Inicializador Padrão do campo
	
	oStruBA3:AddField(	 				;
				"Titular"				, ;	// [01] Titulo do campo		
				"Titular"				, ;	// [02] ToolTip do campo	
				"NOMETIT"				, ;	// [03] Id do Field
				"C"						, ;	// [04] Tipo do campo
				90						, ;	// [05] Tamanho do campo
				0 						, ;	// [06] Decimal do campo
				{ || .T. }				, ;	// [07] Code-block de validação do campo
				{ || .F. }				, ;	// [08] Code-block de validação When do campo
										, ;	// [09] Lista de valores permitido do campo
				.F.						,;	// [10] Indica se o campo tem preenchimento obrigatÃ¯Â¿Â½rio
				{ || RetTitular(2)} 				)// [11] Inicializador Padrão do campo
	
				
		// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA3)
		oStruBA3 := CriaCampMVC(1,@oStruBA3,@aCamposBA3[nNx]) 
	Next
	
	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
		oStruBA1 := CriaCampMVC(1,@oStruBA1,@aCamposBA1[nNx]) 
	Next



					
	aAux := FwStruTrigger(;
							"BA1_GRAUPA", ;												// [01] Id do campo de origem
							"BA1_TIPREG" , ;											// [02] Id do campo de destino
							"AtuTipReg()" )
	
	oStruBA1:AddTrigger( ;
			aAux[1], ;                                                      // [01] Id do campo de origem
			aAux[2], ;                                                      // [02] Id do campo de destino
			aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
			aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho
				
	
	//Adiciona ao modelo uma estrutura de formulario
	oModel:AddFields( 'BA1MASTER',NIL, oStruBA1 )
    oModel:AddFields( 'BA3DETAIL', 'BA1MASTER', oStruBA3) 
		
	oModel:GetModel( "BA3DETAIL" ):SetOptional( .T. )
	oModel:GetModel( "BA3DETAIL" ):SetOnlyQuery( .T. )

	oModel:SetPrimaryKey({})

	//Faz relaciomaneto entre os componentes do model
    //oModel:SetRelation( 'BA3DETAIL', { { 'BA3_FILIAL', 'xFilial( "BA3" )' }, { '(BA3_CODINT || BA3_CODEMP || BA3_MATRIC)', 'BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC)' } }, BA3->( IndexKey( 1 ) ) )
	
	oModel:SetRelation( 'BA3DETAIL', { {  'BA3_FILIAL', 'xFilial( "BA3" )' }, { 'BA3_CODINT', 'BA1_CODINT'}, { 'BA3_CODEMP', 'BA1_CODEMP'}, { 'BA3_MATRIC', 'BA1_MATRIC' } }, BA3->( IndexKey( 1 ) ) )


	//Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( FunDesc() )	
	

	//Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'BA1MASTER' ):SetDescription( 'Beneficiario' )	
	oModel:GetModel( 'BA3DETAIL' ):SetDescription( 'Familia' )	

	/*Inicializadores Padroes*/
	
	oStruBA3:setProperty('BA3_CODPLA',MODEL_FIELD_VALID, { || PLSABA3MVC(oModel) .And. PLSA260GCMvc(oModel) })
	oStruBA3:setProperty('BA3_CODPLA',MODEL_FIELD_INIT, { || BA3->BA3_CODPLA })

	oStruBA3:setProperty('BA3_VERSAO',MODEL_FIELD_VALID, { || EXISTCPO("BIL", RetFilPla(oModel),1) .And. PLSA260GCMvc(oModel) })
	oStruBA3:setProperty('BA3_VERSAO',MODEL_FIELD_INIT , { || BA3->BA3_VERSAO })
	oStruBA3:setProperty('BA3_MATRIC',MODEL_FIELD_INIT , { || BA3->BA3_MATRIC })
	oStruBA3:setProperty('BA3_CODEMP',MODEL_FIELD_INIT , { || BA3->BA3_CODEMP })
	oStruBA3:setProperty('BA3_DESPLA',MODEL_FIELD_INIT , { || Alltrim(BI3->BI3_DESCRI) })
	
	
	oStruBA3:setProperty( 'BA3_DATBAS', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "BA3->BA3_DATBAS" ) )
	oStruBA3:setProperty( 'BA3_FORCTX', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "BA3->BA3_FORCTX" ) )
	
	oStruBA1:setProperty( 'BA1_GRAUPA', MODEL_FIELD_WHEN, { || .T.} )

	oStruBA1:setProperty( 'BA1_CODINT', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, GetSx3Cache("BA3_CODINT", "X3_RELACAO") ) )
	oStruBA1:setProperty( 'BA1_CODEMP', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, GetSx3Cache("BA3_CODEMP", "X3_RELACAO") ) )
	oStruBA1:setProperty( 'BA1_MATRIC', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, GetSx3Cache("BA3_MATRIC", "X3_RELACAO") ) )

	oStruBA1:setProperty( 'BA1_DESUSU', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, GetSx3Cache("BA1_DESUSU", "X3_RELACAO") ) )
	oStruBA1:setProperty( 'BA1_DTVLCR', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, GetSx3Cache("BA3_DTVLCR", "X3_RELACAO") ) )	
		
	oStruBA1:setProperty( 'BA1_TIPUSU', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, GetSx3Cache("BA1_TIPUSU", "X3_RELACAO") ) )


	oStruBA1:setProperty( 'BA1_DESGRA', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, GetSx3Cache("BA1_DESGRA", "X3_RELACAO") ))
	oStruBA1:setProperty( 'BA1_DATINC', MODEL_FIELD_INIT, { || Date() } )
	oStruBA1:setProperty( 'BA1_DATCAR', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, GetSx3Cache("BA1_DATCAR", "X3_RELACAO") ) )
	oStruBA1:setProperty( 'BA1_IMAGE' , MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, GetSx3Cache("BA1_IMAGE" , "X3_RELACAO") ) )
	oStruBA1:setProperty( 'BA1_CPFUSR', MODEL_FIELD_VALID, { || VldCpfUsrMVC(oModel)} )
	oStruBA1:setProperty( 'BA1_RESFAM', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, GetSx3Cache("BA1_RESFAM" , "X3_RELACAO") ) )

	//Instala o evento padrão do programa.
	oModel:InstallEvent("PLSA260EVDEF",/*cOwner*/,PLSA260EVDEF():New()	)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicaÃ¯Â¿Â½Ã¯Â¿Â½o 
@author  Roberto Barbosa
@version P2
@since   26/07/19
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 


Local aCampBA1 := {} 
Local aCampBA3 := {} 
Local oStruBA3 		:= FWFormStruct( 2, 'BA3'    , { |cCampo| PLS260CamMenu('BA3',cCampo,'N',@aCampBA3) },.T./*lViewUsado*/)
Local oStruBA1 		:= FWFormStruct( 2, 'BA1'    , { |cCampo| PLS260CamMenu('BA1',cCampo,'N',@aCampBA1) },.T./*lViewUsado*/)
Local oModel   		:= FWLoadModel( 'PL260DEPMVC' )
Local aCamposBA1  	:= {"BA1_CODEMP","BA1_MATRIC","BA1_CODINT"} // Campos a serem adicionado na estrutura
Local aCamposBA3  	:= {"BA3_TIPOUS","BA3_CODEMP","BA3_CONEMP","BA3_VERCON","BA3_SUBCON","BA3_VERSUB","BA3_FORCTX"} // Campos a serem adicionado na estrutura
Local nNx

	oView := FWFormView():New()
	oView:SetModel( oModel )

	//Campo de matricula do titular
	oStruBA3:AddField("MATTIT"	,;	// [01]  C   Nome do Campo
					"01"			,;	// [02]  C   Ordem
					"Matricula Titular"	,;	// [03]  C   Titulo do campo
					"Matricula Titular"	,;	// [04]  C   Descricao do campo
					NIL					,;	// [05]  A   Array com Help
					"C"					,;	// [06]  C   Tipo do campo
					"@!"				,;	// [07]  C   Picture
					NIL					,;	// [08]  B   Bloco de Picture Var
					NIL					,;	// [09]  C   Consulta F3
					.F.					,;	// [10]  L   Indica se o campo Ã© alteravel
					NIL					,;	// [11]  C   Pasta do campo
					NIL					,;	// [12]  C   Agrupamento do campo
					NIL 				,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL					,;	// [14]  N   Tamanho maximo da maior opÃ§Ã£o do combo
					NIL					,;	// [15]  C   Inicializador de Browse
					.F.					,;	// [16]  L   Indica se o campo Ã© virtual
					NIL					,;	// [17]  C   Picture Variavel
					NIL					)	// [18]  L   Indica pulo de linha apÃ³s o campo

	//Campo de matricula do titular
	oStruBA3:AddField("NOMETIT"	,;	// [01]  C   Nome do Campo
					"01"			,;	// [02]  C   Ordem
					"Titular"	,;	// [03]  C   Titulo do campo
					"Titular"	,;	// [04]  C   Descricao do campo
					NIL					,;	// [05]  A   Array com Help
					"C"					,;	// [06]  C   Tipo do campo
					"@!"				,;	// [07]  C   Picture
					NIL					,;	// [08]  B   Bloco de Picture Var
					NIL					,;	// [09]  C   Consulta F3
					.F.					,;	// [10]  L   Indica se o campo Ã© alteravel
					NIL					,;	// [11]  C   Pasta do campo
					NIL					,;	// [12]  C   Agrupamento do campo
					NIL 				,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL					,;	// [14]  N   Tamanho maximo da maior opÃ§Ã£o do combo
					NIL					,;	// [15]  C   Inicializador de Browse
					.F.					,;	// [16]  L   Indica se o campo Ã© virtual
					NIL					,;	// [17]  C   Picture Variavel
					NIL					)	// [18]  L   Indica pulo de linha apÃ³s o campo

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
		oStruBA1 := CriaCampMVC(2,oStruBA1,aCamposBA1[nNx],StrZero(nNx,2))
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA3)
		oStruBA3 := CriaCampMVC(2,oStruBA3,aCamposBA3[nNx],StrZero(nNx,2))
	Next

	oView:AddField( 'VIEW_BA1', oStruBA1, 'BA1MASTER' )
	oView:AddField( 'VIEW_BA3', oStruBA3, 'BA3DETAIL' )

	oStruBA3:SetNoFolder()
	oStruBA1:SetNoFolder()

	//Grupo 01 BA1
	oStruBA1:AddGroup( 'GrupoBA1_1', OemToAnsi('Dados do Dependente') , '1', 2 )
	oStruBA1:SetProperty( "BA1_CODEMP" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_INFANS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_MATRIC" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DTVLCR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_CPFUSR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_MATVID" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_NOMUSR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_CODINT" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DATNAS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DRGUSR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )		
	oStruBA1:SetProperty( "BA1_CDMNAS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )	
	oStruBA1:SetProperty( "BA1_MUNNAS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_SEXO"   ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_PISPAS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_ESTCIV" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_TIPREG" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DIGITO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_TIPUSU" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DESUSU" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DESCIV" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_GRAUPA" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DATINC" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_MAE"    ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DATADM" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DATCAR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DESGRA" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_IDADE"  ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_OPEORI" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_OPEDES" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_RESFAM" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )	

	For nNx := 1 to Len(aCampBA1)
		oStruBA1:SetProperty( aCampBA1[nNx] ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	Next nNx

	
	oStruBA1:AddGroup( 'GrupoBA1_2', OemToAnsi('Endereço') , '1', 2 )
	oStruBA1:SetProperty( "BA1_CEPUSR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_ENDERE" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_NR_END" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_COMEND" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )	
	oStruBA1:SetProperty( "BA1_BAIRRO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_CODMUN" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )	
	oStruBA1:SetProperty( "BA1_MUNICI" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_ESTADO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_DDD"    ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_TELEFO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )		
	oStruBA1:SetProperty( "BA1_ORIEND" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	
	oView:CreateHorizontalBox( 'SUPERIOR', 20 )
	oView:CreateHorizontalBox( 'INFERIOR', 80 )

	
	oView:SetOwnerView( 'VIEW_BA3', 'SUPERIOR'  )
	oView:SetOwnerView( 'VIEW_BA1', 'INFERIOR' )

	
	
Return oView




//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260MENU
Monta o Menu do PLSA260MVC 
@author Roberto Barbosa
@since 14/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function PLS260CamMenu(cAlias,cCampo,cModel,aCampos)
Local lRet := .F.


Default  aCampos:= {}

cCampo := AllTrim(cCampo)

If cAlias == "BA3"
	 If cCampo $ "BA3_CODPLA,BA3_DESPLA,BA3_DATBAS,BA3_VERSAO,BA3_CODINT,BA3_CODEMP,BA3_VENCTO" .OR.;
	 		 (cModel == 'S' .AND. cCampo $ ("BA3_RATSAI,BA3_DESMEN,BA3_TIPOUS,BA3_CONEMP,BA3_SUBCON,BA3_VERCON,BA3_VERSUB,BA3_ROTINA,BA3_MODPAG,BA3_DESFOR,BA3_DEFOTX"))
		lRet := .T.		
	EndIF

ElseIf cAlias == "BA1" 
	If cCampo $ "BA1_CPFUSR,BA1_MATVID,BA1_NOMUSR,BA1_DATNAS,BA1_DRGUSR,BA1_CDMNAS,BA1_MUNNAS,BA1_SEXO,BA1_PISPAS,BA1_ESTCIV,BA1_TIPREG,BA1_DIGITO,BA1_TIPUSU,BA1_DESUSU,BA1_CONEMP,BA1_IMAGE,BA1_RESFAM" .or.;
			cCampo $	"BA1_DESCIV,BA1_GRAUPA,BA1_DATINC,BA1_MAE,BA1_DATCAR,BA1_DESGRA,BA1_IDADE,BA1_OPEORI,BA1_OPEDES,BA1_CEPUSR,BA1_ENDERE,BA1_NR_END,BA1_COMEND,BA1_BAIRRO" .or.;
				cCampo $ "BA1_CODMUN,BA1_MUNICI,BA1_DATADM,BA1_ESTADO,BA1_DDD,BA1_TELEFO,BA1_ORIEND,BA1_CODINT,BA1_MATRIC,BA1_DTVLCR,BA1_INFANS" .OR.;
					(cModel == 'S' .AND. cCampo $ ("BA1_CODPLA,BA1_VERSAO,BA1_DATINC,BA1_CONEMP,BA1_SUBCON,BA1_VERCON,BA1_VERSUB,BA1_INTERD,BA1_OPERES,BA1_LOCANS,BA1_LOCATE,BA1_LOCEMI,BA1_REEWEB,BA1_10ANOS,BA1_INSALU,BA1_INFCOB,BA1_MUDFAI,BA1_LOCSIB"))
					

		lRet := .T.		
	EndIF
EndIF


If !lret
 	// Incluindo os campos customizados
	IF GetSx3Cache(cCampo, "X3_PROPRI") = "U"
		lRet := .T.		
		AaDD(aCampos,cCampo)
	Endif
Endif



Return lRet



/*/{Protheus.doc} AtuTipReg()
// Gatilha a tabela de Grau de parentesco
@author totver
@since 16/10/2010
@version 1.0
@return cTipReg 

@type function
/*/
Function AtuTipReg()

Local oModel     := FWModelActive()
Local cTipReg	:= ''
Local cCodInt	:= oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODINT')
Local cCodEmp	:= oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODEMP')
Local cMatric	:= oModel:GetModel('BA3DETAIL'):GetValue('BA3_MATRIC')
Local aAreaBA1	:= BA1->(GetArea())
Local lLibera	:= .F.
Local nQtdDep	:= 0
Local nQtdCon	:= 0


cTipReg := Posicione('BT2',1,xFilial('BT2')+FwFldGet('BA1_GRAUPA'),'BT2_CODDEP')

nQtdDep		:= Val(BT2->BT2_SEQATE)  - Val(BT2->BT2_SEQDE) 
cTipRegIni	:= BT2->BT2_SEQDE

if ExistBlock("PLSTPRG")
	ExecBlock("PLSTPRG",.F.,.F.,{cTipRegIni})
Endif	

BA1->(DbSetOrder(2))
While .T.
	BA1->(DbGoTop())
	If BA1->((DbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric)))
		While !BA1->(Eof()) .and. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial('BA1')+cCodInt+cCodEmp+cMatric

			If BA1->BA1_TIPREG == cTipRegIni 
				nQtdCon++
			    If nQtdCon  <  nQtdDep 
					cTipRegIni := StrZero(Val(cTipRegIni)+1,2)
					lLibera:=	.F.
					Exit
				Else
					MsgAlert('Ja existe o número necessário para esse grau de parentesco. ','Aviso')	
					oModel := FWModelActive() 
					oModel := oModel:GetModel( "BA1MASTER" )
					oModel:SetValue( "BA1_GRAUPA", '') 
					cTipRegIni:= ''
				Endif
						
			Else 
				lLibera:=	.T.	
			Endif 
			
			BA1->(DbSkip())
		Enddo	
	Endif 
	
	If llibera
		exit 
	Endif 
		
Enddo		

RestArea(aAreaBA1)


Return (cTipRegIni)



/*/{Protheus.doc} RetTitular()
// Gatilha a tabela de desconto caso o produto tenha uma.
@author Totver
@since 14/10/2019
@version 1.0
@return cRet

@type function
/*/

Static Function RetTitular(nTipo)
Local cMatric := BA1->(BA1_CODINT+BA1_CODEMP)
Local cRet := ''
Local aAreaBA1:= BA1->(GetArea())
Default nTipo := 0 

If nTipo = 1
	cRet := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
Else
	cRet := alltrim(BA1->BA1_NOMUSR)
Endif

RestArea(aAreaBA1)


Return (cRet)

