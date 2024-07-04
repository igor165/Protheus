#Include "Protheus.ch"
#Include "FWMVCDEF.ch"
#Include "TMSAF74.ch"

Static  cTabDF0	:= ""
Static  cTabDF1	:= ""
Static  cTabDF2	:= ""
Static  oTempTable	:= ""
Static  aFldEdit	:= {"DF1_SERVIC","DF1_DATPRE","DF1_HORPRE","DF1_DATPRC","DF1_HORPRC","DF2_CODPRO"}
Static  aNoFields	:= {"DF0_FILIAL","DF1_FILIAL","DF2_FILIAL","DF0_NUMAGE","DF1_NUMAGE","DF2_NUMAGE","DF1_ITEAGE","DF2_ITEAGE"}
	
#DEFINE TYPE_MODEL	1
#DEFINE TYPE_VIEW  	2

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSAF74
			Tela De Preview Da Inclusão De Agendamentos MRP
@author  	Eduardo Alberti
@version 	Versao P12
@since		29/Feb/2016
@return 	Nil
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Function TmsAF74( aPrwDF0, aPrwDF1, aPrwDF2, aRECNO, lRet )

	Local aArea			:= GetArea()
	Local aButtons		:= {}
	Local lEditFld    	:= ExistBlock('TMSAF74E')							//-- Verifica Se Existe PE Para Manipulação Do Vetor aFldEdit
	Local aUsrFld		:= {}
	Local nRet			:= 0
	Local n1			:= 0
	Local oTbTemp1		:= NIL
	Local oTbTemp2		:= NIL
	Local oTbTemp3		:= NIL
	Local cFunction 	:= ProcName()
	
	Private cGrpVen     := PadR(GetMv("MV_CDRORI"),Len(DUY->DUY_GRPVEN)) //-- Compatibilidade Com TMSAF05
	Private lConfirma   := .T.													//-- Compatibilidade Com TMSAF05
	Private aRecF74		:= {}
	
	Default aPrwDF0		:= {}
	Default aPrwDF1		:= {}
	Default aPrwDF2		:= {}
	Default aRECNO		:= {}
	Default lRet         := .T.
	
	aRecF74 := aRECNO
	
	IIf(ExistFunc('FwPdLogUser'),FwPdLogUser(cFunction),)

	//-- Ponto De Entrada Para Manipulação Dos Campos Que Podem Ser Editáveis Na Tela De Preview
	If lEditFld
		aUsrFld := ExecBlock("TMSAF74E",.F.,.F., aFldEdit )
		If ValType(aUsrFld) == "A" 
			aFldEdit := AClone(aUsrFld)
		EndIf	
	EndIf	

	//-- Gera Tabelas Temporárias No Banco De Dados
	oTbTemp1 := fLoadTabs( "DF0" , aPrwDF0 )
	cTabDF0:= oTbTemp1:GetRealName()

	oTbTemp2 := fLoadTabs( "DF1" , aPrwDF1 )
	cTabDF1:= oTbTemp2:GetRealName()
	
	oTbTemp3 := fLoadTabs( "DF2" , aPrwDF2 )
	cTabDF2:= oTbTemp3:GetRealName()
	
	//-- Desabilita Botões Padrão Deixando Apenas o Botão Cancelar
	aButtons := {	{.F.,Nil},;		//-- 01 - Copiar
					{.F.,Nil},;		//-- 02 - Recortar
					{.F.,Nil},;		//-- 03 - Colar
					{.F.,Nil},;		//-- 04 - Calculadora
					{.F.,Nil},;		//-- 05 - Spool
					{.F.,Nil},;		//-- 06 - Imprimir
					{.T.,STR0010},;	//-- 07 - Confirmar
					{.T.,STR0001},;	//-- 08 - Cancelar ( Fechar	)
					{.F.,Nil},;		//-- 09 - WalkTrhough
					{.F.,Nil},;		//-- 10 - Ambiente
					{.F.,Nil},;		//-- 11 - Mashup
					{.F.,Nil},;		//-- 12 - Help
					{.F.,Nil},;		//-- 13 - Formulário HTML
					{.F.,Nil}}			//-- 14 - ECM
			
	//-- Executa a View (Nesta Rotina Não Existe o Browse Inicial Padrão MVC )
	nRet := FWExecView( 'TMSAF74' /*cTitulo*/ ,'TMSAF74'/*cPrograma*/,MODEL_OPERATION_UPDATE /*nOperation*/,/*oDlg*/, { || .T. }/*bCloseOnOk*/,/*bOk */,/*nPercReducao */,aButtons /*aEnableButtons */,/*bCancel */)  //-- "Pré Visualização Agendamento"
	
	//-- Dropa Arquivos Temporários No Banco De Dados
	oTbTemp1:Delete()
	oTbTemp2:Delete()
	oTbTemp3:Delete()

	//-- Se Houve Erro De Processamento Altera nRet Para Ajustar DDD_STATUS
	nRet := Iif( nRet == 0 .And. Len(aRecF74) == 0 , 1 , nRet ) 	

	//-- Atualiza Status Dos Registros Na Tabela DDD
	If Len(aRECNO) > 0 .And. lRet
		For n1 := 1 To Len( aRECNO )
			DDD->(MsGoTo( aRECNO[ n1 , 1 ] ) )
			RecLock('DDD',.F.)
			DDD->DDD_STATUS := Iif( nRet == 0 , StrZero(3, Len(DDD->DDD_STATUS)) , StrZero(2, Len(DDD->DDD_STATUS)) ) // 1=EDI Importado; 2=Processado; 3=Agendamento Gerado
			DDD->(MsUnLock())
		Next n1
	EndIf	

	RestArea(aArea)

Return( nRet )

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@author Eduardo Alberti
@version Versao P12
@since 29/Feb/2016
@return Nil
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oView   	:= NIL		//-- Recebe o objeto da View
	Local oModel  	:= NIL		//-- Objeto do Model
	Local oStruCab   	:= NIL   	//-- Recebe a Estrutura cabecalho
	Local oGrdDF0  	:= NIL  	//-- Recebe a Estrutura
	Local oGrdDF1  	:= NIL  	//-- Recebe a Estrutura
	Local oGrdDF2  	:= NIL  	//-- Recebe a Estrutura
	
	Local bLoadDF0	:= {|oModel| fF74Load(oModel,'DF0')}
	Local bLoadDF1	:= {|oModel| fF74Load(oModel,'DF1')}
	Local bLoadDF2	:= {|oModel| fF74Load(oModel,'DF2')}
	
	Local bLinePost	:=  {|oGridModel, nLine| LinePosGrid(oGridModel, nLine )}
	
	Local n1			:= 0
	
	Default lRet         := .T.
	
	//-- Cria Primeira Estrutura (Field) Na Parte Superior Da Tela
	oStruCab	:= FWFormModelStruct():New()

	//-- Campo Dummy (Sem Utilização - Somente Para Compatibilidade MVC)
	oStruCab:AddField(	STR0007		, ; //-- Titulo do campo  //-- "Repete Valores Para Todos Itens"
							STR0007		, ; //-- ToolTip do campo //-- "Repete Valores Para Todos Itens"
							'RPT_ALL' 		, ; //-- Nome do Campo
							'L' 			, ; //-- Tipo do campo
							1	 			, ; //-- Tamanho do campo
							0 				, ; //-- Decimal do campo
							NIL				, ; //-- Code-block de validação do campo
							NIL				, ; //-- Code-block de validação When do campo
							{} 				, ; //-- Lista de valores permitido do campo
							.F.				, ; //-- Indica se o campo tem preenchimento obrigatório
							NIL				, ; //-- Code-block de inicializacao do campo
							NIL 			, ; //-- Indica se trata de um campo chave
							NIL 			, ; //-- Indica se o campo pode receber valor em uma operação de update.
							.T. 			)   //-- Indica se o campo é virtual

	//-- Cria Segunda Estrutura (Grid) 
	oGrdDF0	:= FWFormStruct( TYPE_MODEL , 'DF0' )	//-- A019StrGrd(TYPE_MODEL)

	//-- Cria Terceira Estrutura (Grid) 
	oGrdDF1	:= FWFormStruct( TYPE_MODEL , 'DF1' )	//-- A019StrGrd(TYPE_MODEL)

	//-- Cria Quarta Estrutura (Grid) 
	oGrdDF2	:= FWFormStruct( TYPE_MODEL , 'DF2' )	//-- A019StrGrd(TYPE_MODEL)

	oModel := MPFormModel():New( "TMSAF74",, /*{ |oModel| PosVldMdl( oModel ) }*/ ,{|oModel| TMSAF74Agd(oModel,@lRet)}/*bCommit*/, /*bCancel*/ )

	//-- Adiciona Objetos Criados à Model
	oModel:AddFields('MdFieldCab',,oStruCab,,,{||})
	
	//--   AddGrid(<cId >, <cOwner >, <oModelStruct >, <bLinePre >, <bLinePost >, <bPre >, <bLinePost >, <bLoad >)-> NIL
	oModel:AddGrid('MdGridDF0','MdFieldCab'	, oGrdDF0,  /* bLinePre */, bLinePost /* bLinePost */ ,/*bPre*/, /*bPos*/, bLoadDF0 /*BLoad*/ )
	
	oModel:AddGrid('MdGridDF1','MdGridDF0'		, oGrdDF1,  /* bLinePre */, bLinePost /* bLinePost */ ,/*bPre*/, /*bPos*/, bLoadDF1 /*BLoad*/ )

	oModel:AddGrid('MdGridDF2','MdGridDF1'		, oGrdDF2,  /* bLinePre */, bLinePost /* bLinePost */ ,/*bPre*/, /*bPos*/, bLoadDF2 /*BLoad*/ )

	oModel:SetRelation("MdGridDF1",{	{"DF1_FILIAL",'xFilial("DF1")'},;
											{"DF1_NUMAGE","DF0_NUMAGE"    } }, "DF1_FILIAL + DF1_NUMAGE" )//DF1->(IndexKey(1)))

	oModel:SetRelation("MdGridDF2",{	{"DF2_FILIAL",'xFilial("DF2")'},;
											{"DF2_NUMAGE","DF1_NUMAGE"    },;
											{"DF2_ITEAGE","DF1_ITEAGE"    } }, "DF2_FILIAL + DF2_NUMAGE + DF2_ITEAGE" )//DF2->(IndexKey(1)))
	
	//-- Seta Descrição Para Cada Divisão Da Model
	oModel:GetModel('MdFieldCab'):SetDescription( STR0002 ) 	//-- "Pré Visualização Agendamento"
	oModel:GetModel('MdGridDF0' ):SetDescription( STR0003 )		//-- "Agendamento"
	oModel:GetModel('MdGridDF1' ):SetDescription( STR0004 )		//-- "Itens Agendamento"
	oModel:GetModel('MdGridDF2' ):SetDescription( STR0005 )		//-- "Produtos Por Itens Agendamento"

	oModel:SetDescription( STR0002 ) 								//-- "Pré Visualização Agendamento"
	
	//-- Adiciona Restrições Aos Objetos Da Model
	oModel:GetModel( 'MdGridDF0' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MdGridDF0' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MdGridDF0' ):SetOptional( .T. )

	oModel:GetModel( 'MdGridDF1' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MdGridDF1' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MdGridDF1' ):SetOptional( .T. )

	oModel:GetModel( 'MdGridDF2' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MdGridDF2' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MdGridDF2' ):SetOptional( .T. )

	//-- Não Permite Gravação Direta Da Model
	oModel:GetModel('MdGridDF0'):SetOnlyQuery( .T. )
	oModel:GetModel('MdGridDF1'):SetOnlyQuery( .T. )
	oModel:GetModel('MdGridDF2'):SetOnlyQuery( .T. )
	
	//-- Seta Utilização De aHeader e aCols Para Compatibilização Com Fontes/Validações Antigos
	oModel:GetModel('MdGridDF0'):SetUseOldGrid( .T. )
	oModel:GetModel('MdGridDF1'):SetUseOldGrid( .T. )
	oModel:GetModel('MdGridDF2'):SetUseOldGrid( .T. )		
	
	//-- Habilita Campos Para Edição
	For n1 := 1 To Len( aFldEdit )
		Do Case
		Case Substr( aFldEdit[n1] , 1 , 3 ) == "DF0"
			oGrdDF0:SetProperty( aFldEdit[n1] , MODEL_FIELD_WHEN , {|| .T. } )
		Case Substr( aFldEdit[n1] , 1 , 3 ) == "DF1"
			oGrdDF1:SetProperty( aFldEdit[n1] , MODEL_FIELD_WHEN , {|| .T. } )
		Case Substr( aFldEdit[n1] , 1 , 3 ) == "DF2"
			oGrdDF2:SetProperty( aFldEdit[n1] , MODEL_FIELD_WHEN , {|| .T. } )
		EndCase
	Next n1
	
	//-- Inclui Gatilhos Nos Campos Editáveis 
	For n1 := 1 To Len( aFldEdit )
	
		//-- Monta Estrutura de Gatilhos
		aTrigger :=	FwStruTrigger(	;
						aFldEdit[n1]		,; // Campo de Dominio (tem que existir no Model)
						aFldEdit[n1]		,; // Campo de ContraDominio (tem que existir no Model)
						"Tmsaf74Gat()"	,; // Regra de Preenchimento
											,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
											,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
											,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
											,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
											)  // Condição para execução do gatilho (Opcional)
	
		//-- Inclui Gatilhos Conforme Tabelas
		Do Case
		Case Substr( aFldEdit[n1] , 1 , 3 ) == "DF0"
			oGrdDF0:AddTrigger(	aTrigger[1] , ; 	// [01] identificador (ID) do campo de origem
									aTrigger[2] , ; 	// [02] identificador (ID) do campo de destino
									aTrigger[3] , ; 	// [03] Bloco de código de validação da execução do gatilho
									aTrigger[4] ) 	// [04] Bloco de código de execução do gatilho
		Case Substr( aFldEdit[n1] , 1 , 3 ) == "DF1"
			oGrdDF1:AddTrigger(	aTrigger[1] , ; 	// [01] identificador (ID) do campo de origem
									aTrigger[2] , ; 	// [02] identificador (ID) do campo de destino
									aTrigger[3] , ; 	// [03] Bloco de código de validação da execução do gatilho
									aTrigger[4] ) 	// [04] Bloco de código de execução do gatilho
		Case Substr( aFldEdit[n1] , 1 , 3 ) == "DF2"
			oGrdDF2:AddTrigger(	aTrigger[1] , ; 	// [01] identificador (ID) do campo de origem
									aTrigger[2] , ; 	// [02] identificador (ID) do campo de destino
									aTrigger[3] , ; 	// [03] Bloco de código de validação da execução do gatilho
									aTrigger[4] ) 	// [04] Bloco de código de execução do gatilho
		EndCase
	Next n1	

	//-- Ajusta Obrigatoriedade Do Campo
	oGrdDF1:SetProperty( "DF1_DATCAN" , MODEL_FIELD_OBRIGAT , .f. )
	oGrdDF1:SetProperty( "DF1_OBSCAN" , MODEL_FIELD_OBRIGAT , .f. )

	//-- Seta Chave Primária Da Model
	oModel:SetPrimaryKey({"DF0_FILIAL","DF0_NUMAGE"})

	//-- Ativação Da Model Com Execução De Rotina Posterior a Montagem Da Model
	oModel:SetActivate( { |oModel| ActiveMdl( oModel ) } ) 

Return(oModel)
//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@author Eduardo Alberti
@version Versao P12
@since 16/Nov/2015
@return Nil
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oView   	:= NIL		// Recebe o objeto da View
	Local oModel  	:= NIL		// Objeto do Model
	Local oStruCab   	:= NIL   	// Recebe a Estrutura cabecalho
	Local oGrdDF0  	:= NIL  	// Recebe a Estrutura
	Local n1			:= 0
	
	Default lRet         := .T.

	oModel		:= FwLoadModel( "TMSAF74" )

	//-- Cria Primeira Estrutura (Field) Na Parte Superior Da Tela
	//-- Adiciona o campo de marcação(CheckBox)
	oStruCab:= FWFormViewStruct():New()

	oStruCab:AddField(	'RPT_ALL'	, ; // Nome do Campo
							'01'   	, ; // Ordem
							STR0007	, ; // Titulo do campo  		//-- "Repete Valores Para Todos Itens"
							STR0007	, ; // Descrição do campo	//-- "Repete Valores Para Todos Itens"
							{" "}  	, ; // Array com Help
							'L'    	, ; // Tipo do campo
							''     	, ; // Picture
							NIL    	, ; // Bloco de Picture Var
							''     	, ; // Consulta F3
							.T.    	, ; // Indica se o campo é editável
							NIL    	, ; // Pasta do campo
							NIL    	, ; // Agrupamento do campo
							{ }    	, ; // Lista de valores permitido do campo (Combo)
							NIL    	, ; // Tamanho Maximo da maior opção do combo
							NIL    	, ; // Inicializador de Browse
							.T.    	, ; // Indica se o campo é virtual
							NIL      	)   // Picture Variável

	//-- Cria Segunda Estrutura (Grid) 
	oGrdDF0	:= FWFormStruct( TYPE_VIEW , 'DF0' )	//--A019StrGrd(TYPE_VIEW)
	
	//-- Cria Terceira Estrutura (Grid)
	oGrdDF1	:= FWFormStruct( TYPE_VIEW , 'DF1' )	//--A019StrGrd(TYPE_VIEW)

	//-- Cria Quarta Estrutura (Grid)
	oGrdDF2	:= FWFormStruct( TYPE_VIEW , 'DF2' )	//--A019StrGrd(TYPE_VIEW)

	//-- Remove Campos
	oGrdDF1:RemoveField( "DF1_PRDAGE" )
	oGrdDF1:RemoveField( "DF1_TIPVEI" )
	oGrdDF1:RemoveField( "DF1_DATCAN" )
	oGrdDF1:RemoveField( "DF1_CODOBC" )
	
	//-- Cria o objeto de View
	oView := FwFormView():New()
	
	//-- Define qual o Modelo de dados será utilizado na View
	oView:SetModel(oModel)

	//-- Alteração de propriedades do campo
	oGrdDF0:SetProperty( '*' 			, MVC_VIEW_CANCHANGE,.F.) //-- Bloqueia Todos Os Campos Da Grid
	oGrdDF1:SetProperty( '*' 			, MVC_VIEW_CANCHANGE,.F.) //-- Bloqueia Todos Os Campos Da Grid
	oGrdDF2:SetProperty( '*' 			, MVC_VIEW_CANCHANGE,.F.) //-- Bloqueia Todos Os Campos Da Grid

	//-- Alteração de propriedades do campo
	For n1 := 1 To Len( aFldEdit )
		Do Case
		Case Substr( aFldEdit[n1] , 1 , 3 ) == "DF0"
			oGrdDF0:SetProperty( aFldEdit[n1] , MVC_VIEW_CANCHANGE ,.T.) //-- Habilita Somente o Campo Mark Da Grid
		Case Substr( aFldEdit[n1] , 1 , 3 ) == "DF1"
			oGrdDF1:SetProperty( aFldEdit[n1] , MVC_VIEW_CANCHANGE ,.T.) //-- Habilita Somente o Campo Mark Da Grid
		Case Substr( aFldEdit[n1] , 1 , 3 ) == "DF2"
			oGrdDF2:SetProperty( aFldEdit[n1] , MVC_VIEW_CANCHANGE ,.T.) //-- Habilita Somente o Campo Mark Da Grid
		EndCase
	Next n1
	
	//-- Adiciona Botões				
	//oView:AddUserButton( STR0006 			, 'CLIPS', {|oView| TMSAF74Agd(oView)} )		//-- "Gerar Agendamento"

	//-- Adiciona Os Objetos Criados à View
	oView:AddField('VwFieldCab', oStruCab , 'MdFieldCab')
	oView:AddGrid( 'VwGridDF0' , oGrdDF0  , 'MdGridDF0')
	oView:AddGrid( 'VwGridDF1' , oGrdDF1  , 'MdGridDF1')
	oView:AddGrid( 'VwGridDF2' , oGrdDF2  , 'MdGridDF2')
		
	//-- Dimensiona a Tela Da View
	oView:CreateHorizontalBox('CABECALHO', 10)
	oView:CreateHorizontalBox('GRIDDF0'  , 30)
	oView:CreateHorizontalBox('GRIDDF1'  , 25)
	oView:CreateHorizontalBox('GRIDDF2'  , 35)

	//-- Seta Os Objetos para Cada Dimensão Criada
	oView:SetOwnerView('VwFieldCab'	,'CABECALHO')
	oView:SetOwnerView('VwGridDF0'	,'GRIDDF0'  )
	oView:SetOwnerView('VwGridDF1'	,'GRIDDF1'  )
	oView:SetOwnerView('VwGridDF2'	,'GRIDDF2'  )
	
	//-- Fecha Tela Após Confirmação (Persistencia De Dados) 
	oView:SetCloseOnOk({|| .T.})
	
	//-- Não Permite Abertura Da Tela De "Salvar Dados Do Formulário"
	oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

Return(oView)

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fF74Load
Carregamento Das Grids De Preview Do Agendamento
@author Eduardo Alberti
@version Versao P12
@since 01/Mar/2016
@return Nil
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Static Function fF74Load( oMdlGrid , cTab )

	Local aArea      := GetArea()
	Local cTabTmp	 := "TMPX"
	Local oGridOwner := Nil
	Local nLineOwner := 0	
	Local cNumAge    := ""
	Local cIteAge    := ""
	Local cQuery     := ""
	Local aRet       := {}
	
	If cTab == "DF0"
	
		cQuery	:= ""
		cQuery += " SELECT		*
		cQuery += " FROM			" + cTabDF0 + " " + cTabTmp
		cQuery += " ORDER BY    TMPX.DF0_NUMAGE "

		cAliasT := fSetFields(cQuery, cTabTmp)
	
	ElseIf ctab == "DF1"
	
		oGridOwner := oMdlGrid:GetOwner()
		nLineOwner := oGridOwner:GetLine()
		cNumAge    := oGridOwner:GetValue( "DF0_NUMAGE", nLineOwner )

		cQuery	:= ""
		cQuery += " SELECT		*
		cQuery += " FROM			" + cTabDF1 + " " + cTabTmp
		cQuery += " WHERE			TMPX.DF1_NUMAGE = '" + cNumAge + "' "
		cQuery += " ORDER BY		TMPX.DF1_NUMAGE, TMPX.DF1_ITEAGE  "

		cAliasT := fSetFields(cQuery, cTabTmp)

	ElseIf ctab == "DF2"
	
		oGridOwner := oMdlGrid:GetOwner()
		nLineOwner := oGridOwner:GetLine()
		cNumAge    := oGridOwner:GetValue( "DF1_NUMAGE", nLineOwner )
		cIteAge    := oGridOwner:GetValue( "DF1_ITEAGE", nLineOwner )

		cQuery	:= ""
		cQuery += " SELECT		*
		cQuery += " FROM			" + cTabDF2 + " " + cTabTmp
		cQuery += " WHERE			TMPX.DF2_NUMAGE = '" + cNumAge + "' "
		cQuery += " AND			TMPX.DF2_ITEAGE = '" + cIteAge + "' "
		cQuery += " ORDER BY		TMPX.DF2_NUMAGE, TMPX.DF2_ITEAGE  "

		cAliasT := fSetFields(cQuery, cTabTmp)

	EndIf
		
	/*
	FWLoadByAlias
	Função que realiza a carga de um submodelo baseado em um alias existente
	
	@param oObj               Objeto do submodelo (FWFormFieldsModel ou FWFormGridModel)
	@param cAlias             Alias para carga .
	@param cAliasReal         Alias Real. Utilizado para carga de campos MEMO reais na tabela, se houver e para uso real de inicializadores padrao, 
	                          se nao for informado usa a tabela definida na estrutura do objeto.
	@param cFieldRecno        Nome do campo que contem o numero do recno. Quando a tabela foi criada a partir de uma query
	                          deve ter uma coluna contendo o recno() real do registro. Se o nome desta coluna for R_E_C_N_O_ ou 
	                          RECNO ou Alias+RECNO, nao é preciso informar o nome da coluna neste parametro, caso contrario deve-se informar.
	@param lCopy              Apenas para compatibilidade, Nao usar
	@param lQuery             Indica que o alias foi criado a partir de uma query.
	*/
		
	// Como tem o campo R_E_C_N_O_, nao é preciso informar qual o campo contem o Recno() real
	aRet := FWLoadByAlias( oMdlGrid , cAliasT , cTab , Nil , Nil , .f. )
	
	//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(dbCloseArea())
	EndIf	

	RestArea(aArea)

Return(aRet)

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fSetFields

@author  	arume.alexandre
@version 	Versao P12
@since		30/05/2018
@parameters cQuery
@parameters cTabTmp
@return 	cAliasT

/*/
//--------------------------------------------------------------------------------------------------------
Static Function fSetFields(cQuery, cTabTmp)

	Local nTotReg    	:= 0
	Local cAliasT    	:= GetNextAlias()
	Local bQuery     	:= {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
	Local aStruQry		:= {}
	Local oStructTmp	:= Nil
	Local aFldsTmp		:= {}
	Local nLine			:= 0
	Local nPos			:= 0

	cQuery := ChangeQuery(cQuery)

	//-- Executa Query
	Eval(bQuery)

	//-- Formata Campos Da Query
	aStruQry := (cAliasT)->(DbStruct())

	oStructTmp := FWFormStruct(1, cTabTmp)
	aFldsTmp := oStructTmp:aFields

	For nLine := 1 To Len(aStruQry)

		If (nPos := aScan(aFldsTmp, {|x| AllTrim(x[3]) == aStruQry[nLine][1]})) > 0
			If aFldsTmp[nPos][4] == "D" .Or. aFldsTmp[nPos][4] == "N"
				TCSetField( cAliasT , aStruQry[nLine][1], aFldsTmp[nPos][4] , aFldsTmp[nPos][5] , aFldsTmp[nPos][6] )
			Endif
		EndIf
	Next nLine

	FreeObj(oStructTmp)

	aSize(aFldsTmp, 0)
	aFldsTmp := Nil

Return cAliasT

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fLoadTabs
			Converte Vetor Em Tabela No Banco De Dados
@author  	Eduardo Alberti
@version 	Versao P12
@since		08/Mar/2016
@return 	Nil
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Static Function fLoadTabs( cTab , aDados )

	Local aArea			:= GetArea()
	Local n1			:= 0
	Local n2			:= 0
	Local n3			:= 0
	Local n4      		:= 0
	Local aStruTab		:= {}
	Local cDrive		:= __LocalDrive
	Local aCampos		:= {}
	Local aProds		:= {}
	Local cPrefix		:= "AGE"
	Local cAgend		:= cPrefix + StrZero(0,(TamSX3("DF0_NUMAGE")[1]) - Len(cPrefix) )
	Local cIteAge		:= ""
	Local oTempTable	:= NIL
	Local oStructTmp	:= Nil
	Local aFldsTmp		:= {}
	Local cTabTmp		:= "TMPX"

	//-- Verifica o drive de criacao do temporario ( Altera RDD )
	If TcSrvType() <> "AS/400"
		cDrive := __cRDD
	EndIf
	
	//-- Define Estrutura Da Tabela	
	oStructTmp := FWFormStruct(1, cTab)
	aFldsTmp := oStructTmp:aFields

	For n1 := 1 To Len(aFldsTmp)
		If ( X3Uso( GetSx3Cache(aFldsTmp[n1][3], "X3_USADO")) .And. GetSX3Cache(aFldsTmp[n1][3], "X3_NIVEL") <= cNivel ) .Or. aFldsTmp[n1][3] $ "DF2_NUMAGE|DF2_ITEAGE"
			aAdd( aStruTab, { aFldsTmp[n1][3] , aFldsTmp[n1][4] , aFldsTmp[n1][5] , aFldsTmp[n1][6] })
		EndIf
	Next
	
	//-- Adiciona manualmente campos DF2_NUMAGE|DF2_ITEAGE caso não exista
	If cTab == "DF2"

		If aScan( aStruTab , { |x| x[1] == "DF2_NUMAGE" }  ) == 0 
			aAdd( aStruTab, { 	GetSx3Cache("DF2_NUMAGE", "X3_CAMPO") 	,;
								GetSx3Cache("DF2_NUMAGE", "X3_TIPO")	,;
								GetSx3Cache("DF2_NUMAGE", "X3_TAMANHO")	,;
								GetSx3Cache("DF2_NUMAGE", "X3_DECIMAL") })
		EndIf

		If aScan( aStruTab , { |x| x[1] == "DF2_ITEAGE" }  ) == 0 
			aAdd( aStruTab, { 	GetSx3Cache("DF2_ITEAGE", "X3_CAMPO") 	,;
								GetSx3Cache("DF2_ITEAGE", "X3_TIPO")	,;
								GetSx3Cache("DF2_ITEAGE", "X3_TAMANHO")	,;
								GetSx3Cache("DF2_ITEAGE", "X3_DECIMAL") })
		EndIf

	EndIf

	FreeObj(oStructTmp)

	aSize(aFldsTmp, 0)
	aFldsTmp := Nil

	//------------------------------------------------------------------------------ 
	//--  INICIO - Bloco De Criacao Dos Arquivos Temporarios No Banco De Dados 
	//------------------------------------------------------------------------------	
	oTempTable := FWTemporaryTable():New(cTabTmp)
	oTempTable:SetFields( aStruTab )

	If cTab == "DF0"
		oTempTable:AddIndex("01", {"DF0_NUMAGE"} )
	ElseIf cTab == "DF1"
		oTempTable:AddIndex("01", {"DF1_NUMAGE"} )
	ElseIf cTab == "DF2"
		oTempTable:AddIndex("01", {"DF2_NUMAGE"} )
	EndIf

	oTempTable:Create()

	//------------------------------------------------------------------------------ 
	//--   FIM   - Bloco De Criacao Dos Arquivos Temporarios No Banco De Dados 
	//------------------------------------------------------------------------------	

	//-- Inicializa Controle De Sequence
	Begin Sequence
	
		//-- Verifica Se Criou Tabela
		If Select("TMPX") <= 0
			Break
		EndIf

		//-- Tratamento Tabela DF0	
		If cTab == "DF0"
		
			//-- Verifica Tamanho Do Vetor
			If Len( aDados ) == 0
				Break
			EndIf

			For n1 := 1 To Len(aDados)
			
				//-- Incrementa Número Agendamento (Temporário)
				cAgend := Soma1(cAgend)
			
				//-- Trava Para Gravação
				RecLock( "TMPX" , .t. )
				
				TMPX->DF0_NUMAGE := cAgend
				
				aCampos := aDados[ n1 ]
				For n2 := 1 To Len( aCampos )
				
					If cTab == Substr(aCampos[n2][1],1,3) 

						//-- Efetua Macro Substituição
						If GetSX3Cache( aCampos[n2][1],"X3_TIPO" ) == "C" .And. aScan( aNoFields , Alltrim(aCampos[n2][1]) ) == 0
							&( "TMPX" + "->" + aCampos[n2][1]) := aCampos[n2][2]
						ElseIf GetSX3Cache( aCampos[n2][1],"X3_TIPO" ) == "D" .And. aScan( aNoFields , Alltrim(aCampos[n2][1]) ) == 0
							&( "TMPX" + "->" + aCampos[n2][1]) := StoD(aCampos[n2][2])
						ElseIf GetSX3Cache( aCampos[n2][1],"X3_TIPO" ) == "N" .And. aScan( aNoFields , Alltrim(aCampos[n2][1]) ) == 0
							&( "TMPX" + "->" + aCampos[n2][1]) := Val(aCampos[n2][2])
						EndIf
					
						//-- Atualiza Campos Virtuais
						If Alltrim(aCampos[n2][1]) == "DF0_CODSOL"
						
							DbSelectArea("DUE")
							DbSetOrder(1)
							If MsSeek( xFilial("DUE") + aCampos[n2][2] )
							
								If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF0_NOMSOL' }) > 0
									TMPX->DF0_NOMSOL 	:= DUE->DUE_NOME
								EndIf
								If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF0_END' }) > 0
									TMPX->DF0_END		:= DUE->DUE_END
								EndIf
								If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF0_BAIRRO' }) > 0
									TMPX->DF0_BAIRRO	:= DUE->DUE_BAIRRO
								EndIf
								If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF0_MUN' }) > 0								
									TMPX->DF0_MUN		:= DUE->DUE_MUN
								EndIf
								If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF0_EST' }) > 0								
									TMPX->DF0_EST		:= DUE->DUE_EST
								EndIf
								If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF0_CEP' }) > 0								
									TMPX->DF0_CEP		:= DUE->DUE_CEP
								EndIf
								If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF0_SEQEND' }) > 0								
									TMPX->DF0_SEQEND	:= Space(Len(TMPX->DF0_SEQEND))
								EndIf
							EndIf
						EndIf
					EndIf

				Next n2
				
				//-- Destrava Registro
				TMPX->(MsUnlock())
				
			Next n1
		
		ElseIf cTab == "DF1"
		
			For n1 := 1 To Len(aDados)
			
				//-- Incrementa Número Agendamento (Temporário)
				cAgend := Soma1(cAgend)
			
				//-- Itens Do Agendamento
				aItens := aDados[ n1 ]

				For n2 := 1 To Len(aItens)
				
					//-- Trava Para Gravação
					RecLock( "TMPX" , .t. )
				
					TMPX->DF1_NUMAGE := cAgend
					TMPX->DF1_ITEAGE := StrZero( n2 ,(TamSX3("DF1_ITEAGE")[1]))
				
					aCampos := aItens[ n2 ]
					For n3 := 1 To Len( aCampos )
					
						If cTab == Substr(aCampos[n3][1],1,3) 
							
							//-- Efetua Macro Substituição
							If GetSX3Cache( aCampos[n3][1],"X3_TIPO" ) == "C" .And. aScan( aNoFields , Alltrim(aCampos[n3][1]) ) == 0
								&( "TMPX" + "->" + aCampos[n3][1]) := aCampos[n3][2]
							ElseIf GetSX3Cache( aCampos[n3][1],"X3_TIPO" ) == "D" .And. aScan( aNoFields , Alltrim(aCampos[n3][1]) ) == 0
								&( "TMPX" + "->" + aCampos[n3][1]) := StoD(aCampos[n3][2])
							ElseIf GetSX3Cache( aCampos[n3][1],"X3_TIPO" ) == "N" .And. aScan( aNoFields , Alltrim(aCampos[n3][1]) ) == 0
								&( "TMPX" + "->" + aCampos[n3][1]) := Val(aCampos[n3][2])
							EndIf

							//-- Atualiza Campos Virtuais
							If Alltrim(aCampos[n3][1]) $ "DF1_CLIDES|DF1_LOJDES"
						
								DbSelectArea("SA1")
								DbSetOrder(1)
								If MsSeek( xFilial("SA1") + TMPX->DF1_CLIDES + TMPX->DF1_LOJDES , .F. )
							
									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_NOMDES' }) > 0
										TMPX->DF1_NOMDES 	:= SA1->A1_NOME
									EndIf
									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_CDRDES' }) > 0
										TMPX->DF1_CDRDES 	:= SA1->A1_CDRDES
									EndIf
									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_ENDDES' }) > 0
										TMPX->DF1_ENDDES 	:= SA1->A1_END
									EndIf
									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_BAIDES' }) > 0									
										TMPX->DF1_BAIDES	:= SA1->A1_BAIRRO
									EndIf
									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_MUNDES' }) > 0									
										TMPX->DF1_MUNDES 	:= SA1->A1_MUN
									EndIf
									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_ESTDES' }) > 0									
										TMPX->DF1_ESTDES 	:= SA1->A1_EST
									EndIf
									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_CEPDES' }) > 0									
										TMPX->DF1_CEPDES 	:= SA1->A1_CEP
									EndIf
									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_SQEDES' }) > 0									
										TMPX->DF1_SQEDES	:= SPACE(LEN(TMPX->DF1_SQEDES))
									EndIf

								EndIf
							ElseIf Alltrim(aCampos[n3][1]) $ "DF1_CLIDEV|DF1_LOJDEV"
						
								DbSelectArea("SA1")
								DbSetOrder(1)
								If MsSeek( xFilial("SA1") + TMPX->DF1_CLIDEV + TMPX->DF1_LOJDEV , .F. )
									TMPX->DF1_NOMDEV 	:= SA1->A1_NOME
								EndIf
								
							ElseIf Alltrim(aCampos[n3][1]) $ "DF1_CLIREM|DF1_LOJREM"
						
								DbSelectArea("SA1")
								DbSetOrder(1)
								If MsSeek( xFilial("SA1") + TMPX->DF1_CLIREM + TMPX->DF1_LOJREM , .F. )

									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_NOMREM' }) > 0
										TMPX->DF1_NOMREM 	:= SA1->A1_NOME
									EndIf
									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_END' }) > 0
										TMPX->DF1_END	 	:= SA1->A1_END
									EndIf
									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_BAIRRO' }) > 0
										TMPX->DF1_BAIRRO 	:= SA1->A1_BAIRRO
									EndIf
									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_MUN' }) > 0									
										TMPX->DF1_MUN	 	:= SA1->A1_MUN
									EndIf
									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_EST' }) > 0									
										TMPX->DF1_EST	 	:= SA1->A1_EST
									EndIf
									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_CEP' }) > 0									
										TMPX->DF1_CEP	 	:= SA1->A1_CEP
									EndIf
									If aScan( aStruTab , { |x| Alltrim(x[1]) == 'DF1_SQEREM' }) > 0									
										TMPX->DF1_SQEREM 	:= Space(Len(TMPX->DF1_SQEREM))
									EndIf
									
								EndIf
							ElseIf Alltrim(aCampos[n3][1]) $ "DF1_CODNEG"
						
								DbSelectArea("DDB")
								DbSetOrder(1)
								If MsSeek( xFilial("DDB") + TMPX->DF1_CODNEG , .F. )
									TMPX->DF1_DESNEG 	:= DDB->DDB_DESCRI								
								EndIf
								
							ElseIf Alltrim(aCampos[n3][1]) $ "DF1_SERVIC"
								If !Empty(Tabela("L4",TMPX->DF1_SERVIC,.F.))

									TMPX->DF1_DESSER 	:= Tabela("L4",TMPX->DF1_SERVIC,.F.)
								
								EndIf
							ElseIf Alltrim(aCampos[n3][1]) $ "DF1_SQEDES"
						
								DbSelectArea("SA1")
								DbSetOrder(1)
								If MsSeek( xFilial("SA1") + TMPX->DF1_CLIDES + TMPX->DF1_LOJDES , .F. )

									TMPX->DF1_NOMDES 	:= SA1->A1_NOME
								
									DbSelectArea("DUL")
									DbSetOrder(2)
									MsSeek( xFilial("DUL") + TMPX->DF1_CLIDES + TMPX->DF1_LOJDES + TMPX->DF1_SQEDES )

									TMPX->DF1_ENDDES 	:= Iif(Empty(TMPX->DF1_SQEDES), SA1->A1_END		, DUL->DUL_END)
									TMPX->DF1_BAIDES 	:= Iif(Empty(TMPX->DF1_SQEDES), SA1->A1_BAIRRO	, DUL->DUL_BAIRRO)
									TMPX->DF1_MUNDES 	:= Iif(Empty(TMPX->DF1_SQEDES), SA1->A1_MUN		, DUL->DUL_MUN)
									TMPX->DF1_ESTDES	:= Iif(Empty(TMPX->DF1_SQEDES), SA1->A1_EST		, DUL->DUL_EST)
									TMPX->DF1_CEPDES 	:= Iif(Empty(TMPX->DF1_SQEDES), SA1->A1_CEP		, DUL->DUL_CEP)
								
								EndIf
							ElseIf Alltrim(aCampos[n3][1]) $ "DF1_SQEREM"
						
								DbSelectArea("DUE")
								DbSetOrder(3)
								If MsSeek( xFilial("DUE") + TMPX->DF1_CLIREM + TMPX->DF1_LOJREM, .F. )

									TMPX->DF1_NOMREM 	:= DUE->DUE_NOME
								
									DbSelectArea("DUL")
									DbSetOrder(2)
									MsSeek( xFilial("DUL") + TMPX->DF1_CLIREM + TMPX->DF1_LOJREM + TMPX->DF1_SQEREM  )

									TMPX->DF1_END	 	:= Iif(Empty(TMPX->DF1_SQEREM), DUE->DUE_END	, DUL->DUL_END)
									TMPX->DF1_BAIRRO 	:= Iif(Empty(TMPX->DF1_SQEREM), DUE->DUE_BAIRRO	, DUL->DUL_BAIRRO)
									TMPX->DF1_MUN	 	:= Iif(Empty(TMPX->DF1_SQEREM), DUE->DUE_MUN	, DUL->DUL_MUN)
									TMPX->DF1_EST		:= Iif(Empty(TMPX->DF1_SQEREM), DUE->DUE_EST	, DUL->DUL_EST)
									TMPX->DF1_CEP	 	:= Iif(Empty(TMPX->DF1_SQEREM), DUE->DUE_CEP	, DUL->DUL_CEP)
								
								EndIf
							ElseIf Alltrim(aCampos[n3][1]) $ "DF1_TIPTRA"

								__ReadVar := "M->DF1_TIPTRA"
								M->DF1_TIPTRA := TMPX->DF1_TIPTRA
								TMPX->DF1_DESTPT 	:= TMSValField('M->DF1_TIPTRA',.F.,'DF1_DESTPT')
								
							ElseIf Alltrim(aCampos[n3][1]) $ "DF1_CDRORI"
							
								TMPX->DF1_REGORI := Posicione("DUY",1,xFilial("DUY")+TMPX->DF1_CDRORI,"DUY_DESCRI")							

							ElseIf Alltrim(aCampos[n3][1]) $ "DF1_CDRDES"
							
								TMPX->DF1_REGDES := Posicione("DUY",1,xFilial("DUY")+TMPX->DF1_CDRDES,"DUY_DESCRI")							

							EndIf
						EndIf
					Next n3

					//-- Destrava Registro
					TMPX->(MsUnlock())

				Next n2
			Next n1
		ElseIf cTab == "DF2"
		
			For n1 := 1 To Len(aDados)
			
				//-- Incrementa Número Agendamento (Temporário)
				cAgend := Soma1(cAgend)
			
				//-- Itens Do Agendamento
				aItens := aDados[ n1 ]

				For n2 := 1 To Len(aItens)
				
					cIteAge:= StrZero( n2 ,(TamSX3("DF2_ITEAGE")[1]))
					aProds := aItens[ n2 ]
					
					For n3 := 1 To Len(aProds)
				
						//-- Trava Para Gravação
						RecLock( "TMPX" , .t. )
					
						TMPX->DF2_NUMAGE := cAgend
						TMPX->DF2_ITEAGE := cIteAge
					
						aCampos := aProds[ n3 ]
						For n4 := 1 To Len( aCampos )

							If cTab == Substr(aCampos[n4][1],1,3) 
								
								//-- Efetua Macro Substituição
								If GetSX3Cache( aCampos[n4][1],"X3_TIPO" ) == "C" .And. aScan( aNoFields , Alltrim(aCampos[n4][1]) ) == 0
									&( "TMPX" + "->" + aCampos[n4][1]) := aCampos[n4][2]
								ElseIf GetSX3Cache( aCampos[n4][1],"X3_TIPO" ) == "D" .And. aScan( aNoFields , Alltrim(aCampos[n4][1]) ) == 0
									&( "TMPX" + "->" + aCampos[n4][1]) := StoD(aCampos[n4][2])
								ElseIf GetSX3Cache( aCampos[n4][1],"X3_TIPO" ) == "N" .And. aScan( aNoFields , Alltrim(aCampos[n4][1]) ) == 0
									&( "TMPX" + "->" + aCampos[n4][1]) := aCampos[n4][2]
								EndIf

								//-- Atualiza Campos Virtuais
								If Alltrim(aCampos[n4][1]) $ "DF2_CODEMB"
									If !Empty(Tabela("MG",TMPX->DF2_CODEMB,.F.))
								
										TMPX->DF2_DESEMB	:= Tabela("MG",TMPX->DF2_CODEMB,.F.)
									
									EndIf
								ElseIf Alltrim(aCampos[n4][1]) $ "DF2_CODPRO"

									DbSelectArea("SB1")
									DbSetOrder(1)
									If MsSeek( xFilial("SB1") + TMPX->DF2_CODPRO , .F. )
								
										TMPX->DF2_DESPRO	:= SB1->B1_DESC
									
									EndIf
								EndIf
							EndIf
		
						Next n4

						//-- Destrava Registro
						TMPX->(MsUnlock())

					Next n3
				Next n2
			Next n1
		EndIf
	
	//-- Finaliza Controle De Sequence
	End Sequence

	(cTabTmp)->( dbCloseArea() )
	RestArea(aArea)

Return( oTempTable )
//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsaf74Gat
			Execução Dos Gatilhos Dos Campos Editaveis Do Modelo
@author  	Eduardo Alberti
@version 	Versao P12
@since		14/Mar/2016
@return 	Nil
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Function Tmsaf74Gat()

	Local aArea 		:= GetArea()
	Local cCampo		:= ReadVar()
	Local cValor		:= &(ReadVar())
	Local cView			:= ""
	Local oModel		:= FWModelActive()	//-- Captura Model Ativa
	Local oView			:= FWViewActive()		//-- Captura View Ativa
	Local aSaveLines	:= FWSaveRows()		//-- Captura Posicionamento Da Grid
	Local oModelGrid	:= Nil
	Local lRptAll		:= oModel:GetValue( 'MdFieldCab', 'RPT_ALL'  )
	Local n1			:= 0
	Local nLinOld		:= 0
	
	//-- Se Estiver Marcado Para Repetir Todos Itens
	If lRptAll

		Do Case
		Case "DF0" $ cCampo
			oModelGrid	:= oModel:GetModel( 'MdGridDF0' )
			cView		:= 'VwGridDF0'
		Case "DF1" $ cCampo
			oModelGrid	:= oModel:GetModel( 'MdGridDF1' )
			cView		:= 'VwGridDF1'
		Case "DF2" $ cCampo
			oModelGrid	:= oModel:GetModel( 'MdGridDF2' )
			cView		:= 'VwGridDF2'
		EndCase
		
		//-- Determina Linha Original
		nLinOld		:= oModelGrid:nLine

 		//-- Executa Loop Em Toda a Grid
		For n1 := 1 To oModelGrid:Length()
	
			//-- Posiciona Na Linha Da Grid Conforme o Cursor
			oModelGrid:GoLine( n1 )
				
			//-- Verifica Se Linha Não Está Deletada
			If !oModelGrid:IsDeleted()
				oModelGrid:SetValue( Substr(cCampo,4,10) , cValor )
			EndIf

		Next n1
	
		//-- Reposiciona na Linha Original Da Grid
		FWRestRows( aSaveLines )

		//-- Força Posicionamento De Linha
		oModelGrid:GoLine( nLinOld )		
	
		//-- Dá Refresh na View De Grid Para Atualizar Dados Na Tela
		oView:Refresh( cView )

	EndIf
	
	RestArea(aArea)

Return(cValor)

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSAF74Agd
			Função Para Converter a Model Em Vetores Para Geração Automática Do(s) Agendamento(s)
@author  	Eduardo Alberti
@version 	Versao P12
@since		15/Mar/2016
@return 	Booleano
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Function TMSAF74Agd(oModel,lRet)

	Default lRet := .t.

	Processa( { || lRet := TMSAF74Ag2(oModel,lRet) }, STR0008 , STR0009 + '...',.F.) //-- "Aguarde" "Processando"

Return .t.
//--------------------------------------------------------------------------------------------------------
//-- SubRotina
//--------------------------------------------------------------------------------------------------------
Static Function TMSAF74Ag2(oModel,lRet)

	Local aArea			:= GetArea()
	
	Local oMdlGrdDF0	:= oModel:GetModel( 'MdGridDF0' )
	Local oStructDF0	:= oMdlGrdDF0:GetStruct()
	Local aFieldsDF0	:= oStructDF0:GetFields()

	Local oMdlGrdDF1	:= oModel:GetModel( 'MdGridDF1' )
	Local oStructDF1	:= oMdlGrdDF1:GetStruct()
	Local aFieldsDF1	:= oStructDF1:GetFields()

	Local oMdlGrdDF2	:= oModel:GetModel( 'MdGridDF2' )
	Local oStructDF2	:= oMdlGrdDF2:GetStruct()
	Local aFieldsDF2	:= oStructDF2:GetFields()

	Local n1 			:= 0
	Local n2			:= 0
	Local n3			:= 0
	Local n4			:= 0
	Local n5			:= 0
	Local n6			:= 0

	Local nLinDF1		:= 0
	Local nLinDF2		:= 0
	
	Local aAutDF0		:= {}
	Local aAutDF1		:= {}
	Local aAutDF2		:= {}
	
	Default lRet		:= .t.
	
	Private Inclui	:= .t.
	
	//-- Seta Gauge De Processamento
	ProcRegua(oMdlGrdDF0:Length())

	//-- Inicializa Controle Transacional
	Begin Transaction

	//-- Executa Loop Em Toda a Grid
	For n1 := 1 To oMdlGrdDF0:Length()
	
		//-- Incrementa Gauge De Processamento
		IncProc()
			
		//-- Posiciona Na Linha Da Grid Conforme o Cursor
		oMdlGrdDF0:GoLine( n1 )
				
		//-- Verifica Se Linha Não Está Deletada
		If !(oMdlGrdDF0:IsDeleted())
		
			//-- Executa Loop Em Todos Campos Da Grid
			For n2 := 1 To Len(aFieldsDF0)
							
				//--------------------------------------------------------------------------------------------------------
				//-- Bloco De Geração DF0
				//--------------------------------------------------------------------------------------------------------
				
				//-- Não Envia Campos Virtuais
				If GetSX3Cache(aFieldsDF0[n2,03],"X3_CONTEXT") <> 'V' .And. aScan( aNoFields , Alltrim( GetSX3Cache(aFieldsDF0[n2,03],"X3_CAMPO") ) ) == 0 //-- Não Inclui Campos Existentes No Vetor aNoFields
				
					//-- Verifica Se Item Da Grid Está Marcado
					If !Empty(oModel:GetValue( 'MdGridDF0' , aFieldsDF0[n2,03] ))
					
						xValor := Nil						
						If GetSX3Cache(aFieldsDF0[n2,03],"X3_TIPO") == "D"
							xValor := oModel:GetValue( 'MdGridDF0' , aFieldsDF0[n2,03] )
						Else
							xValor := oModel:GetValue( 'MdGridDF0' , aFieldsDF0[n2,03] )
						EndIf
					
						aAdd( aAutDF0 , { aFieldsDF0[n2,03] , xValor , Nil } )
						
					EndIf
				EndIf
			Next n2
			
			//--------------------------------------------------------------------------------------------------------
			//-- Bloco De Geração DF1
			//--------------------------------------------------------------------------------------------------------			
			nLinDF1 := 0
			For n3 := 1 To oMdlGrdDF1:Length()

				//-- Posiciona Na Linha Da Grid Conforme o Cursor
				oMdlGrdDF1:GoLine( n3 )
				
				//-- Verifica Se Linha Não Está Deletada
				If !(oMdlGrdDF1:IsDeleted())
					
					nLinDF1 ++				//-- Incrementa Contador De Linhas
					aAdd( aAutDF1 , {} )	//-- Adiciona Linha No Vetor
		
					//-- Executa Loop Em Todos Campos Da Grid
					For n4 := 1 To Len(aFieldsDF1)

						//-- Não Envia Campos Virtuais
						If GetSX3Cache(aFieldsDF1[n4,03],"X3_CONTEXT") <> 'V' .And. aScan( aNoFields , Alltrim(GetSX3Cache(aFieldsDF1[n4,03],"X3_CAMPO")) ) == 0 //-- Não Inclui Campos Existentes No Vetor aNoFields
					
							//-- Verifica Se Item Da Grid Está Marcado
							If !Empty(oModel:GetValue( 'MdGridDF1' , aFieldsDF1[n4,03] ))
						
								xValor := Nil
								If GetSX3Cache(aFieldsDF1[n4,03],"X3_TIPO") == "D"
									xValor := oModel:GetValue( 'MdGridDF1' , aFieldsDF1[n4,03] )
								Else
									xValor := oModel:GetValue( 'MdGridDF1' , aFieldsDF1[n4,03] )
								EndIf
						
								aAdd( aAutDF1[nLinDF1] , { aFieldsDF1[n4,03] , xValor , Nil } )
							EndIf
						EndIf
					Next n4

					//--------------------------------------------------------------------------------------------------------
					//-- Bloco De Geração DF2
					//--------------------------------------------------------------------------------------------------------			
					nLinDF2 := 0
					
					aAdd( aAutDF2 , {} )	//-- Adiciona Linha No Vetor
					
					For n5 := 1 To oMdlGrdDF2:Length()
		
						//-- Posiciona Na Linha Da Grid Conforme o Cursor
						oMdlGrdDF2:GoLine( n5 )
						
						//-- Verifica Se Linha Não Está Deletada
						If !(oMdlGrdDF2:IsDeleted())
							
							nLinDF2 ++				//-- Incrementa Contador De Linhas
							aAdd( aAutDF2[n3] , {} )	//-- Adiciona Linha No Vetor
				
							//-- Executa Loop Em Todos Campos Da Grid
							For n6 := 1 To Len(aFieldsDF2)

								//-- Não Envia Campos Virtuais
								If GetSX3Cache(aFieldsDF2[n6,03],"X3_CONTEXT") <> 'V' .And. aScan( aNoFields , Alltrim(GetSX3Cache(aFieldsDF2[n6,03],"X3_CAMPO")) ) == 0 //-- Não Inclui Campos Existentes No Vetor aNoFields
																	
									//-- Verifica Se Item Da Grid Está Marcado
									If !Empty(oModel:GetValue( 'MdGridDF2' , aFieldsDF2[n6,03] ))
								
										xValor := Nil
										If GetSX3Cache(aFieldsDF2[n6,03],"X3_TIPO") == "D"
											xValor := oModel:GetValue( 'MdGridDF2' , aFieldsDF2[n6,03] )
										Else
											xValor := oModel:GetValue( 'MdGridDF2' , aFieldsDF2[n6,03] )
										EndIf
								
										aAdd( aAutDF2[ n3 , nLinDF2 ] , { aFieldsDF2[n6,03] , xValor , Nil } )
									EndIf
								EndIf
							Next n6
						EndIf
					Next n5
				EndIf
			Next n3
		EndIf

		//-- Gera Agendamento
		If Len(aAutDF0) > 0 .And. Len(aAutDF1) > 0 .And. Len(aAutDF2) > 0 

			SaveInter()
			TMSF05Mnt('DF0', 0, 3, .F. , .F., aAutDF0, aAutDF1, aAutDF2, .t. , @lRet ) //-- Executa Validação Nos Vetores de Automação
			RestInter()
						
			If lRet
				SaveInter()
				aTrigger      := {} //-- Esvazia Variável Para Não Dar Erro De EvalTrigger
				TMSF05Mnt('DF0', 0, 3, .F. , .F., aAutDF0, aAutDF1, aAutDF2 )
				RestInter()
				aAutDF0		:= {}
				aAutDF1		:= {}
				aAutDF2		:= {}
			Else
				aRecF74 := {} //-- Esvazia para Não Gravar Como "Processado"
				DisarmTransaction()
				Exit
			EndIf
		EndIf	

	Next n1
	
	//-- Finaliza Controle Trasacional
	End Transaction

	RestArea(aArea)

Return(lRet)

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ActiveMdl
			Função Dummy Para o Sistema Entender Que a Tela Foi Alterada Permitindo Assim a Sua Gravação
@author  	Eduardo Alberti
@version 	Versao P12
@since		16/Mar/2016
@return 	Booleano
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ActiveMdl(oModel)

	Local lRet 		:= .T. 		// Recebe o Retorno
	Local lRptAll		:= oModel:GetValue( 'MdFieldCab', 'RPT_ALL'  )

	oModel:SetValue( 'MdFieldCab', 'RPT_ALL', lRptAll  )

Return lRet
//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LinePosGrid
			Validação Da Linha Da Grid Após Alteração
@author  	Eduardo Alberti
@version 	Versao P12
@since		17/Mar/2016
@return 	Booleano
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Static Function LinePosGrid( oGridModel , nLine )

	Local lOk := .f.

	Processa( { || lOk := LinePosGr2( oGridModel , nLine ) }, "" , STR0011 + '...',.F.) //-- "Validando"

Return lOk
//--------------------------------------------------------------------------------------------------------
//-- SubRotina
//--------------------------------------------------------------------------------------------------------
Static Function LinePosGr2( oGridModel , nLine )

	Local aArea			:= GetArea()
	
	Local oModel		:= oGridModel:GetModel()

	Local oMdlGrdDF0	:= oModel:GetModel( 'MdGridDF0' )
	Local oStructDF0	:= oMdlGrdDF0:GetStruct()
	Local aFieldsDF0	:= oStructDF0:GetFields()
	Local nPosDF0		:= oMdlGrdDF0:GetLine()

	Local oMdlGrdDF1	:= oModel:GetModel( 'MdGridDF1' )
	Local oStructDF1	:= oMdlGrdDF1:GetStruct()
	Local aFieldsDF1	:= oStructDF1:GetFields()

	Local oMdlGrdDF2	:= oModel:GetModel( 'MdGridDF2' )
	Local oStructDF2	:= oMdlGrdDF2:GetStruct()
	Local aFieldsDF2	:= oStructDF2:GetFields()

	Local aSaveLines	:= FWSaveRows()	//-- Captura Posicionamento Da Grid

	Local n1 			:= 0
	Local n2			:= 0
	Local n3			:= 0
	Local n4			:= 0
	Local n5			:= 0
	Local n6			:= 0

	Local nLinDF1		:= 0
	Local nLinDF2		:= 0
	
	Local aAutDF0		:= {}
	Local aAutDF1		:= {}
	Local aAutDF2		:= {}
	
	Default lRet 		:= .t.

	Private Inclui	:= .t.
	
	//-- Seta Gauge De Processamento
	ProcRegua(oMdlGrdDF1:Length())

	//-- Executa Somente Na Linha Posicionada Do Grid
	For n1 := nPosDF0 To nPosDF0
	
		//-- Posiciona Na Linha Da Grid Conforme o Cursor
		oMdlGrdDF0:GoLine( n1 )
				
		//-- Verifica Se Linha Não Está Deletada
		If !(oMdlGrdDF0:IsDeleted())
		
			//-- Executa Loop Em Todos Campos Da Grid
			For n2 := 1 To Len(aFieldsDF0)

				//--------------------------------------------------------------------------------------------------------
				//-- Bloco De Geração DF0
				//--------------------------------------------------------------------------------------------------------
				//-- Não Envia Campos Virtuais
				If GetSX3Cache(aFieldsDF0[n2,03] , "X3_CONTEXT") <> 'V' .And. aScan( aNoFields , Alltrim(GetSX3Cache(aFieldsDF0[n2,03] , "X3_CAMPO")) ) == 0 //-- Não Inclui Campos Existentes No Vetor aNoFields
				
					//-- Verifica Se Item Da Grid Está Marcado
					If !Empty(oModel:GetValue( 'MdGridDF0' , aFieldsDF0[n2,03] ))
					
						xValor := Nil
						If GetSX3Cache(aFieldsDF0[n2,03] , "X3_TIPO")  == "D"
							xValor := oModel:GetValue( 'MdGridDF0' , aFieldsDF0[n2,03] )
						Else
							xValor := oModel:GetValue( 'MdGridDF0' , aFieldsDF0[n2,03] )
						EndIf
					
						aAdd( aAutDF0 , { aFieldsDF0[n2,03] , xValor , Nil } )
						
					EndIf
				EndIf
			Next n2
			
			//--------------------------------------------------------------------------------------------------------
			//-- Bloco De Geração DF1
			//--------------------------------------------------------------------------------------------------------			
			nLinDF1 := 0
			For n3 := 1 To oMdlGrdDF1:Length()

				//-- Incrementa Gauge De Processamento
				IncProc()

				//-- Posiciona Na Linha Da Grid Conforme o Cursor
				oMdlGrdDF1:GoLine( n3 )
				
				//-- Verifica Se Linha Não Está Deletada
				If !(oMdlGrdDF1:IsDeleted())
					
					nLinDF1 ++				//-- Incrementa Contador De Linhas
					aAdd( aAutDF1 , {} )	//-- Adiciona Linha No Vetor
		
					//-- Executa Loop Em Todos Campos Da Grid
					For n4 := 1 To Len(aFieldsDF1)

						//-- Não Envia Campos Virtuais
						If GetSX3Cache(aFieldsDF1[n4,03]  , "X3_CONTEXT") <> 'V' .And. aScan( aNoFields , Alltrim( GetSX3Cache(aFieldsDF1[n4,03]  , "X3_CAMPO") ) ) == 0 //-- Não Inclui Campos Existentes No Vetor aNoFields
					
							//-- Verifica Se Item Da Grid Está Marcado
							If !Empty(oModel:GetValue( 'MdGridDF1' , aFieldsDF1[n4,03] ))
						
								xValor := Nil
								If GetSX3Cache(aFieldsDF1[n4,03] ,"X3_TIPO") == "D"
									xValor := oModel:GetValue( 'MdGridDF1' , aFieldsDF1[n4,03] )
								Else
									xValor := oModel:GetValue( 'MdGridDF1' , aFieldsDF1[n4,03] )
								EndIf
						
								aAdd( aAutDF1[nLinDF1] , { aFieldsDF1[n4,03] , xValor , Nil } )
							EndIf
						EndIf
					Next n4

					//--------------------------------------------------------------------------------------------------------
					//-- Bloco De Geração DF2
					//--------------------------------------------------------------------------------------------------------			
					nLinDF2 := 0
					
					aAdd( aAutDF2 , {} )	//-- Adiciona Linha No Vetor
					
					For n5 := 1 To oMdlGrdDF2:Length()
		
						//-- Posiciona Na Linha Da Grid Conforme o Cursor
						oMdlGrdDF2:GoLine( n5 )
						
						//-- Verifica Se Linha Não Está Deletada
						If !(oMdlGrdDF2:IsDeleted())
							
							nLinDF2 ++				//-- Incrementa Contador De Linhas
							aAdd( aAutDF2[n3] , {} )	//-- Adiciona Linha No Vetor
				
							//-- Executa Loop Em Todos Campos Da Grid
							For n6 := 1 To Len(aFieldsDF2)

								//-- Não Envia Campos Virtuais
								If GetSX3Cache(aFieldsDF2[n6,03]   , "X3_CONTEXT") <> 'V' .And. aScan( aNoFields , Alltrim(GetSX3Cache(aFieldsDF2[n6,03]   , "X3_CAMPO")) ) == 0 //-- Não Inclui Campos Existentes No Vetor aNoFields
							
									//-- Verifica Se Item Da Grid Está Marcado
									If !Empty(oModel:GetValue( 'MdGridDF2' , aFieldsDF2[n6,03] ))
								
										xValor := Nil
										If GetSX3Cache(aFieldsDF2[n6,03]   , "X3_TIPO") == "D"
											xValor := oModel:GetValue( 'MdGridDF2' , aFieldsDF2[n6,03] )
										Else
											xValor := oModel:GetValue( 'MdGridDF2' , aFieldsDF2[n6,03] )
										EndIf
								
										aAdd( aAutDF2[ n3 , nLinDF2 ] , { aFieldsDF2[n6,03] , xValor , Nil } )
									EndIf
								EndIf
							Next n6
						EndIf
					Next n5
				EndIf
			Next n3
		EndIf

		//-- Validação
		If Len(aAutDF0) > 0 .And. Len(aAutDF1) > 0 .And. Len(aAutDF2) > 0 

			SaveInter()
			aTrigger      := {} //-- Esvazia Variável Para Não Dar Erro De EvalTrigger
			
			TMSF05Mnt('DF0', 0, 3, .F. , .F., aAutDF0, aAutDF1, aAutDF2, .t. , @lRet ) //-- Executa Validação Nos Vetores de Automação

			RestInter()
			aAutDF0		:= {}
			aAutDF1		:= {}
			aAutDF2		:= {}

		EndIf	
	Next n1
	
	RestArea(aArea)
	
	//-- Reposiciona na Linha Original Da Grid
	FWRestRows( aSaveLines )	

Return( lRet )
