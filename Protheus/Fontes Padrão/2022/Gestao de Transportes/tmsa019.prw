#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMSA019.CH"

#DEFINE TYPE_MODEL	1
#DEFINE TYPE_VIEW  	2

Static cPerg     := "TMSA019"
Static aDataMdl  := {}
Static aItContrat:= {}

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA019
Tela Para Geração De Agendamentos/Solic. Coletas Para Registros Importados Nas Tabelas
DDD (Cabec. Importações Para Agendamentos) e DDE (Itens Da Importação Para Agendamentos)
@author Eduardo Alberti
@version Versao P12
@since 16/Nov/2015
@return Nil
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Function TMSA019(lPerg) 

	Local aArea     := GetArea()
	Local aButtons  := {}

	Private lRet    := .t.

	Default lPerg   := .t.

	//-- Validação Do Dicionário Utilizado
	If ! AliasInDic("DDD")
		MsgNextRel()	//-- É Necessário a Atualização Do Sistema Para a Expedição Mais Recente
		Return()
	EndIf

	//-- Abre Tela De Parametros
	If lPerg .And. !Pergunte( cPerg , .t. )
		Return(.t.)
	EndIf
	
	//-- Desabilita Botões Padrão Deixando Apenas o Botão Cancelar
	aButtons := {{.F.,Nil},;		//-- 01 - Copiar
				 {.F.,Nil},;		//-- 02 - Recortar
				 {.F.,Nil},;		//-- 03 - Colar
				 {.F.,Nil},;		//-- 04 - Calculadora
				 {.F.,Nil},;		//-- 05 - Spool
				 {.F.,Nil},;		//-- 06 - Imprimir
				 {.F.,""},;		//-- 07 - Confirmar
				 {.T.,STR0001},;	//-- 08 - Cancelar ( Fechar	)
				 {.F.,Nil},;		//-- 09 - WalkTrhough
				 {.F.,Nil},;		//-- 10 - Ambiente
				 {.F.,Nil},;		//-- 11 - Mashup
				 {.F.,Nil},;		//-- 12 - Help
				 {.F.,Nil},;		//-- 13 - Formulário HTML
				 {.F.,Nil}}		//-- 14 - ECM
			
	//-- Executa a View (Nesta Rotina Não Existe o Browse Inicial Padrão MVC )
	FWExecView( STR0005 ,'TMSA019',MODEL_OPERATION_UPDATE,, { || .T. },{ || .F. },,aButtons,{ || .T. })  //-- "Geração Agendamento"
	
	RestArea(aArea)

Return( Nil )

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@author Eduardo Alberti
@version Versao P12
@since 16/Nov/2015
@return Nil
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oView   	:= NIL		//-- Recebe o objeto da View
	Local oModel  	:= NIL		//-- Objeto do Model
	Local oStruCab   	:= NIL   	//-- Recebe a Estrutura cabecalho
	Local oStruGrd  	:= NIL  	//-- Recebe a Estrutura
	Local oStruTot	:= NIL   	//-- Recebe a Estrutura da tabela DDW

	//-- Cria Primeira Estrutura (Field) Na Parte Superior Da Tela
	oStruCab	:= FWFormModelStruct():New()
	oStruCab:AddField(	STR0006		, ; //-- Titulo do campo  //-- "Marcar Todos Itens MRP"
							STR0006		, ; //-- ToolTip do campo //-- "Marcar Todos Itens MRP"
							'MRK_ALL' 		, ; //-- Nome do Campo
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

	//-- Cria Segunda Estrutura (Grid) Na Parte Central Da Tela
	oStruGrd	:= A019StrGrd(TYPE_MODEL)

	//-- Cria Terceira Estrutura (Field) Na Parte Inferior Da Tela
	oStruTot	:= A019StrTot(TYPE_MODEL)

	oModel := MPFormModel():New( "TMSA019",, /*{ |oModel| PosVldMdl( oModel ) }*/ ,/*bCommit*/, /*bCancel*/ )

	//-- Adiciona Objetos Criados à Model
	oModel:AddFields('MdFieldCab',,oStruCab,,,{||})
	
	oModel:AddGrid('MdGridTRB','MdFieldCab', oStruGrd,  /* bLinePre */, /* nLinePost */ ,/*bPre*/, /*bPos*/,{|oMdl| TM019LdGrd(oMdl) } /*BLoad*/ )
	
	oModel:AddFields('MdFieldTot','MdFieldCab',oStruTot,,,{||})
	
	//-- Seta Descrição Para Cada Divisão Da Model
	oModel:GetModel('MdFieldCab' ):SetDescription( STR0002 ) 	//-- "Arq. Importados"
	oModel:GetModel('MdGridTRB'):SetDescription( STR0003 ) 		//-- "Itens" 
	oModel:SetDescription( STR0002 ) 								//-- "Arq. Importados"
	oModel:GetModel( 'MdFieldTot' ):SetDescription( STR0002 ) 	//-- "Arq. Importados" 
	
	//-- Adiciona Restrições Aos Objetos Da Model
	oModel:GetModel( 'MdGridTRB' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MdGridTRB' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MdGridTRB' ):SetOptional( .T. )
	
	//--oModel:GetModel('MdFieldCab'):SetOnlyQuery( .T. )
	oModel:GetModel('MdGridTRB'):SetOnlyQuery( .T. )
	oModel:GetModel('MdFieldTot'):SetOnlyQuery( .T. )

	//-- Seta Chave Primária Da Model
	oModel:SetPrimaryKey({"MRK_ALL"})  
	
	//-- Ativação Da Model
	oModel:SetActivate( )

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
	Local oStruGrd  	:= NIL  	// Recebe a Estrutura
	Local oStruTot	:= NIL   	// Recebe a Estrutura da tabela DDW

	oModel		:= FwLoadModel( "TMSA019" )

	//-- Cria Primeira Estrutura (Field) Na Parte Superior Da Tela
	//-- Adiciona o campo de marcação(CheckBox)
	oStruCab:= FWFormViewStruct():New()
	oStruCab:AddField(	'MRK_ALL'	, ; // Nome do Campo
							'01'   	, ; // Ordem
							STR0006	, ; // Titulo do campo  		//-- "Marcar Todos Itens MRP"
							STR0006	, ; // Descrição do campo	//-- "Marcar Todos Itens MRP"
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

	//-- Cria Segunda Estrutura (Grid) Na Parte Central Da Tela
	oStruGrd	:= A019StrGrd(TYPE_VIEW)
	
	//-- Cria Terceira Estrutura (Field) Na Parte Inferior Da Tela
	oStruTot	:= A019StrTot(TYPE_VIEW)

	//-- Cria o objeto de View
	oView := FwFormView():New()
	
	//-- Define qual o Modelo de dados será utilizado na View
	oView:SetModel(oModel)     

	//-- Alteração de propriedades do campo
	oStruGrd:SetProperty( '*' 			, MVC_VIEW_CANCHANGE,.F.) //-- Bloqueia Todos Os Campos Da Grid
	oStruGrd:SetProperty( 'TRB_MARK' 	, MVC_VIEW_CANCHANGE,.T.) //-- Habilita Somente o Campo Mark Da Grid
	oStruTot:SetProperty( '*' 			, MVC_VIEW_CANCHANGE,.F.) //-- Bloqueia Todos Totalizadores

	//-- Adiciona Botões				
	oView:AddUserButton( STR0004  			, 'CLIPS', {|oView| TMSA019Agd(oView)} )		//-- "Gerar Agendamento"
	oView:AddUserButton( STR0019  			, 'CLIPS', {|oView| TMSA019Mnt(oView,2 )} )	//-- "Visualizar"
	oView:AddUserButton( STR0021  			, 'CLIPS', {|oView| TMSA019Mnt(oView,4 )} )	//-- "Alterar"
	oView:AddUserButton( STR0025			, 'CLIPS', {|oView| TMSA019Mnt(oView,99)} )	//-- "Parametros"	
	oView:AddUserButton( STR0043			, 'CLIPS', {|oView| TMSA019Vis(oView)} )		//-- "Agend.Gerados"
	oView:AddUserButton( STR0018  			, 'CLIPS', {|oView| TMSA019Leg(oView)} )		//-- "Legenda"

	//-- Adiciona Os Objetos Criados à View
	oView:AddField('VwFieldCab', oStruCab , 'MdFieldCab') 
	oView:AddGrid( 'VwGridTRB' , oStruGrd , 'MdGridTRB')   
	oView:AddField('VwFieldTot', oStruTot , 'MdFieldTot')
		
	//-- Dimensiona a Tela Da View
	oView:CreateHorizontalBox('CABECALHO', 10)
	oView:CreateHorizontalBox('GRID'	  , 80)  
	oView:CreateHorizontalBox('TOTALIZAD', 10)

	//-- Seta Os Objetos para Cada Dimensão Criada
	oView:SetOwnerView('VwFieldCab'	,'CABECALHO')
	oView:SetOwnerView('VwGridTRB'	,'GRID'     )     
	oView:SetOwnerView('VwFieldTot'	,'TOTALIZAD')
	
	//-- Define Acao a Ser Executada Quando a Linha é Marcada No Grid (Apos a Validacao Do Campo).
	oView:SetFieldAction( 'TRB_MARK'	, { |oView, cIDView, cField, xValue| Tmsa019Act( oView, cIDView, cField, xValue ) } )
	
	//-- Define Acao a Ser Executada Quando a Field é Marcada No Cabeçalho (Apos a Validacao Do Campo).
	oView:SetFieldAction( 'MRK_ALL'		, { |oView, cIDView, cField, xValue| Tmsa019Act( oView, cIDView, cField, xValue ) } )

	//-- Não Permite Abertura Da Tela De "Salvar Dados Do Formulário"
	oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

Return(oView)
//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A019StrGrd
@author Eduardo Alberti
@version Versao P12
@since 16/Nov/2015
@return Nil
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Static Function A019StrGrd(nType)

	Local oStruct   := Nil
	Local nX        := 0
	Local aDadosCpo := {}
	Local cCampo    := ""
	Local aAux      := {}
	Local aCampos   := {}

	Default nType   := TYPE_MODEL        //  1=Tipo Model / 2= Tipo View
	
	//-- Carrega Vetor De Campos Da Grid (Conforme Query Principal)
	aAdd(aCampos,"DDD_NUMMRP")
	aAdd(aCampos,"DDD_DATAGE")
	aAdd(aCampos,"DDD_HORAGE")
	aAdd(aCampos,"DDD_DATPRC")
	aAdd(aCampos,"DDD_CODSOL")
	aAdd(aCampos,"DUE_NREDUZ")

	aAdd(aCampos,"DDD_CLIDES")
	aAdd(aCampos,"DDD_LOJDES")
	aAdd(aCampos,"DDD_SQEDES")
	aAdd(aCampos,"DDD_NOMDES")

	aAdd(aCampos,"DDE_QTDVOL")
	aAdd(aCampos,"DDE_QTDUNI")
	aAdd(aCampos,"DDE_PESO"  )
	aAdd(aCampos,"DDE_VALMER")
	aAdd(aCampos,"DDE_BASSEG")
	aAdd(aCampos,"DDE_METRO3")
	aAdd(aCampos,"DDE_PESOM3")

	aAdd(aCampos,"DDD_CLIREM")
	aAdd(aCampos,"DDD_LOJREM")
	aAdd(aCampos,"DDD_SQEREM")
	aAdd(aCampos,"DDD_NOMREM")

	aAdd(aCampos,"DDD_CLIDEV")
	aAdd(aCampos,"DDD_LOJDEV")
	aAdd(aCampos,"DDD_NOMDEV")
	
	aAdd(aCampos,"DDD_ARQUIV")
	aAdd(aCampos,"DDD_CODLAY")	
	aAdd(aCampos,"RECNO"     )
	
	//-- Ponto De Entrada Para Alteração Da Posição Dos Campos Na Grid
	If ExistBlock("Tms019Pos")
		aCampos :=	ExecBlock("Tms019Pos",.f.,.f.,{ aCampos , nType })
	EndIf	

	If nType == TYPE_MODEL

		//-- Executa o Método Construtor Da Classe.
		oStruct := FWFormModelStruct():New()

		//-- Legenda De Status Da Linha Da Grid
		oStruct:AddField(	'' ,;													//-- [01] C Titulo do campo
							'' ,; 													//-- [02] C ToolTip do campo
							'TRB_LEGEN',;											//-- [03] C identificador (ID) do Field
							'C' ,; 												//-- [04] C Tipo do campo
							15,; 													//-- [05] N Tamanho do campo
							0 ,;													//-- [06] N Decimal do campo
							Nil,; 													//-- [07] B Code-block de validação do campo /*{|| TMSA019Leg("D")} ,;	*/	
							Nil ,;													//-- [08] B Code-block de validação When do campo
							NIL ,; 												//-- [09] A Lista de valores permitido do campo
							NIL ,; 												//-- [10] L Indica se o campo tem preenchimento obrigatório
							Nil ,;													//-- [11] B Code-block de inicializacao do campo //-- {|a,b,c,d| TMSA019Leg(a,b,c,d)}
							NIL ,; 												//-- [12] L Indica se trata de um campo chave
							NIL ,; 												//-- [13] L Indica se o campo pode receber valor em uma operação de update.
							.T.  ) 												//-- [14] L Indica se o campo é virtual

		//-- Check Box De Marcação Da Linha Da Grid
		oStruct:AddField(	'' ,;													//-- [01] C Titulo do campo
							'' ,; 													//-- [02] C ToolTip do campo
							'TRB_MARK' ,;											//-- [03] C identificador (ID) do Field
							'L' ,; 												//-- [04] C Tipo do campo
							1 ,; 													//-- [05] N Tamanho do campo
							0 ,;													//-- [06] N Decimal do campo
							Nil ,;					 								//-- [07] B Code-block de validação do campo      //-- {|| T146MrkDoc() }
							Nil ,;													//-- [08] B Code-block de validação When do campo //-- {|| TMA146VDoc(FwFldGet('T01_SERTMS'),'D') }
							NIL ,; 												//-- [09] A Lista de valores permitido do campo
							NIL ,; 												//-- [10] L Indica se o campo tem preenchimento obrigatório
							NIL ,; 												//-- [11] B Code-block de inicializacao do campo
							NIL ,; 												//-- [12] L Indica se trata de um campo chave
							NIL ,; 												//-- [13] L Indica se o campo pode receber valor em uma operação de update.
							.T.  ) 												//-- [14] L Indica se o campo é virtual

		//-- Status Da Linha
		oStruct:AddField(	'Status' ,;											//-- [01] C Titulo do campo
							'Status' ,; 											//-- [02] C ToolTip do campo
							'TRB_STAT' ,;											//-- [03] C identificador (ID) do Field
							'C' ,; 												//-- [04] C Tipo do campo
							15,; 													//-- [05] N Tamanho do campo
							0 ,;													//-- [06] N Decimal do campo
							Nil ,;					 								//-- [07] B Code-block de validação do campo      //-- {|| T146MrkDoc() }
							Nil ,;													//-- [08] B Code-block de validação When do campo //-- {|| TMA146VDoc(FwFldGet('T01_SERTMS'),'D') }
							NIL ,; 												//-- [09] A Lista de valores permitido do campo
							NIL ,; 												//-- [10] L Indica se o campo tem preenchimento obrigatório
							NIL ,; 												//-- [11] B Code-block de inicializacao do campo
							NIL ,; 												//-- [12] L Indica se trata de um campo chave
							NIL ,; 												//-- [13] L Indica se o campo pode receber valor em uma operação de update.
							.T.  ) 												//-- [14] L Indica se o campo é virtual


		//-- Inclui Campos Constantes Na Query Principal ( Somente Campos Existentes No Dicionário ).
		For nX := 1 To Len(aCampos)

			If SubStr(aCampos[nX],1,3) <> 'REC'

				aDadosCpo:= TMSX3Cpo( aCampos[nX] )
				If Empty(aDadosCpo) .Or. Len(aDadosCpo) < 6
					TMSLogMsg("ERROR", FunName() + " Erro No Campo: " + aCampos[nX])
				Else
					oStruct:AddField(aDadosCpo[1],aDadosCpo[2],aCampos[nX],aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])
				EndIf	

			EndIf

		Next nX
	Else

		oStruct := FWFormViewStruct():New()

		oStruct:AddField(	'TRB_LEGEN',;		// [01] C Nome do Campo
							'00',;				// [02] C Ordem
							'' ,;				// [03] C Titulo do campo
							'',;		// [04] C Descrição do campo
							{}  ,;				// [05] A Array com Help
							'BT',;				// [06] C Tipo do campo
							'@BMP',;			// [07] C Picture
							NIL,;				// [08] B Bloco de Picture Var
							NIL,;				// [09] C Consulta F3
							.t.,;				// [10] L Indica se o campo é editável
							NIL,;				// [11] C Pasta do campo
							NIL,;				// [12] C Agrupamento do campo
							Nil,;				// [13] A Lista de valores permitido do campo (Combo)
							NIL,;				// [14] N Tamanho Maximo da maior opção do combo
							NIL,;				// [15] C Inicializador de Browse
							.T.,;				// [16] L Indica se o campo é virtual
							Nil )				// [17] C Picture Variável
					
		oStruct:AddField( 'TRB_MARK',;		// [01] C Nome do Campo
							'01',;				// [02] C Ordem
							'' ,;				// [03] C Titulo do campo
							'' ,;				// [04] C Descrição do campo
							{} ,;				// [05] A Array com Help
							'L',;				// [06] C Tipo do campo
							'@BMP',;			// [07] C Picture
							NIL,;				// [08] B Bloco de Picture Var
							NIL,;				// [09] C Consulta F3
							.T.,;				// [10] L Indica se o campo é editável
							NIL,;				// [11] C Pasta do campo
							NIL,;				// [12] C Agrupamento do campo
							NIL,;				// [13] A Lista de valores permitido do campo (Combo)
							NIL,;				// [14] N Tamanho Maximo da maior opção do combo
							NIL,;				// [15] C Inicializador de Browse
							.T.,;				// [16] L Indica se o campo é virtual
							Nil )				// [17] C Picture Variável

		oStruct:AddField( 'TRB_STAT',;		// [01] C Nome do Campo
							'02',;				// [02] C Ordem
							'Status' ,;		// [03] C Titulo do campo
							'Status' ,;		// [04] C Descrição do campo
							{} ,;				// [05] A Array com Help
							'C',;				// [06] C Tipo do campo
							'@!',;				// [07] C Picture
							NIL,;				// [08] B Bloco de Picture Var
							NIL,;				// [09] C Consulta F3
							.T.,;				// [10] L Indica se o campo é editável
							NIL,;				// [11] C Pasta do campo
							NIL,;				// [12] C Agrupamento do campo
							NIL,;				// [13] A Lista de valores permitido do campo (Combo)
							NIL,;				// [14] N Tamanho Maximo da maior opção do combo
							NIL,;				// [15] C Inicializador de Browse
							.T.,;				// [16] L Indica se o campo é virtual
							Nil )				// [17] C Picture Variável

		For nX := 1 To Len(aCampos)
			If SubStr(aCampos[nX],1,3) <> 'REC'
				
				aDadosCpo:= TMSX3Cpo( aCampos[nX] )
				If Empty(aDadosCpo) .Or. Len(aDadosCpo) < 4
					TMSLogMsg("ERROR", FunName() + " Erro No Campo: " + aCampos[nX])
				Else
					oStruct:AddField(aCampos[nX],StrZero((nX + 2 ),2),aDadosCpo[1],aDadosCpo[2],{""},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil)					
				EndIf						
			EndIf		
		Next nX
	EndIf

Return(oStruct)
//-------------------------------------------------------------------
/*/{Protheus.doc} Tmsa019Act
Atualiza As Fields De Totalização Conforme Os Campos São Marcados Na Grid  
@author Eduardo Alberti
@since  Nov/2015
@version P12
/*/
//-------------------------------------------------------------------
Function Tmsa019Act( oView, cIDView, cField, xValue )

	Local aArea		:= GetArea()
	Local oModel	 	:= FWModelActive()	//-- Captura Model Ativa
	Local aSaveLines	:= FWSaveRows()		//-- Captura Posicionamento Da Grid
	Local lMrkAll		:= oModel:GetValue( 'MdFieldCab', 'MRK_ALL'  )
	Local lMarked		:= .f.
	Local cNumMRP		:= oModel:GetValue( 'MdGridTRB' , 'DDD_NUMMRP')
	//Local cStatus		:= oModel:GetValue( 'MdGridTRB' , 'TRB_STAT'  )
	Local oModelGrid	:= oModel:GetModel( 'MdGridTRB' )
	Local nLinOld		:= oModelGrid:nLine
	
	Local nI 			:= 0

	Local nTot_Vols	:= 0	//-- Total Itens
	Local nTot_Unit	:= 0	//-- Total Unitizadores	
	Local nTot_Peso	:= 0
	Local nTot_Pes3	:= 0
	Local nTot_Vlrr	:= 0
	
	Local nQtd_Grid	:= 0
	Local nVol_Grid	:= 0
	Local nPes_Grid	:= 0
	Local nPe3_Grid	:= 0
	Local nVal_Grid	:= 0

	If cField == "TRB_MARK"
	
		//-- Define Se a Linha Posicionada Está Marcada Ou Desmarcada
		lMarked := xValue

		//-- Informa Usuário Que Registro Já Foi Processado
		//If SubStr(cStatus,1,1) <> '2' .And. lMarked
			//Help("",1,"TMSA01901",/*Titulo*/, STR0014 /*Mensagem*/,1,0) //-- "Registro Já Processado! Disponível Somente Para Atualização De Totalizadores No Rodapé Da Tela."
		//EndIf

		//-- Se Estiver Selecionado Para Marcar Todos Do Mesmo Numero MRP
		If lMrkAll
		
			//-- Executa Loop Em Toda a Grid
			For nI := 1 To oModelGrid:Length()
			
				//-- Posiciona Na Linha Da Grid Conforme o Cursor
				oModelGrid:GoLine( nI )
				
				//-- Marca Ou Desmarca Grupo De MRPs
				If oModel:GetValue( 'MdGridTRB' , 'DDD_NUMMRP') == cNumMRP
				
					oModel:SetValue( 'MdGridTRB' , 'TRB_MARK' , Iif(lMarked,.t.,.f.) )
					
				EndIf	

				//-- Se Estiver Marcado Soma Totalizadores
				If oModel:GetValue( 'MdGridTRB' , 'TRB_MARK') 					
				
					nTot_Vols	+= oModel:GetValue( 'MdGridTRB' , 'DDE_QTDVOL')	//-- Total Itens
					nTot_Unit	+= oModel:GetValue( 'MdGridTRB' , 'DDE_QTDUNI')	//-- Total Unitizadores
					nTot_Peso	+= oModel:GetValue( 'MdGridTRB' , 'DDE_PESO')
					nTot_Pes3	+= oModel:GetValue( 'MdGridTRB' , 'DDE_PESOM3')
					nTot_Vlrr	+= oModel:GetValue( 'MdGridTRB' , 'DDE_VALMER')
					
				EndIf
			Next		
			
			//-- Dá Refresh na View De Grid Para Atualizar Dados Na Tela
			oView:Refresh('VwGridTRB')
		
			//-- Atualiza Fields De Totalização Conforme Marcação
			oModel:SetValue( 'MdFieldTot' , 'TOT_VOLS' , nTot_Vols )	//-- Total Itens
			oModel:SetValue( 'MdFieldTot' , 'TOT_UNIT' , nTot_Unit )	//-- Total Unitizadores
			oModel:SetValue( 'MdFieldTot' , 'TOT_PESO' , nTot_Peso )
			oModel:SetValue( 'MdFieldTot' , 'TOT_PES3' , nTot_Pes3 )
			oModel:SetValue( 'MdFieldTot' , 'TOT_VLRR' , nTot_Vlrr )

		Else

			nTot_Vols	:= oModel:GetValue( 'MdFieldTot', 'TOT_VOLS'  )	//-- Total Itens
			nTot_Unit	:= oModel:GetValue( 'MdFieldTot', 'TOT_UNIT'  )	//-- Total Unitizadores
			nTot_Peso	:= oModel:GetValue( 'MdFieldTot', 'TOT_PESO'  )
			nTot_Pes3	:= oModel:GetValue( 'MdFieldTot', 'TOT_PES3'  )
			nTot_Vlrr	:= oModel:GetValue( 'MdFieldTot', 'TOT_VLRR'  )
			
			nQtd_Grid	:= oModel:GetValue( 'MdGridTRB' , 'DDE_QTDUNI')
			nVol_Grid	:= oModel:GetValue( 'MdGridTRB' , 'DDE_QTDVOL')
			nPes_Grid	:= oModel:GetValue( 'MdGridTRB' , 'DDE_PESO')
			nPe3_Grid	:= oModel:GetValue( 'MdGridTRB' , 'DDE_PESOM3')
			nVal_Grid	:= oModel:GetValue( 'MdGridTRB' , 'DDE_VALMER')
	
			//-- Atualiza Fields De Totalização Conforme Marcação
			oModel:SetValue( 'MdFieldTot' , 'TOT_VOLS' , Iif(xValue,( nTot_Vols + nVol_Grid ),( nTot_Vols - nVol_Grid )) )	//-- Total Itens
			oModel:SetValue( 'MdFieldTot' , 'TOT_UNIT' , Iif(xValue,( nTot_Unit + nQtd_Grid ),( nTot_Unit - nQtd_Grid )) )	//-- Total Unitizadores
			oModel:SetValue( 'MdFieldTot' , 'TOT_PESO' , Iif(xValue,( nTot_Peso + nPes_Grid ),( nTot_Peso - nPes_Grid )) )
			oModel:SetValue( 'MdFieldTot' , 'TOT_PES3' , Iif(xValue,( nTot_Pes3 + nPe3_Grid ),( nTot_Pes3 - nPe3_Grid )) )
			oModel:SetValue( 'MdFieldTot' , 'TOT_VLRR' , Iif(xValue,( nTot_Vlrr + nVal_Grid ),( nTot_Vlrr - nVal_Grid )) )
			
		EndIf	
	EndIf
	
	//-- Força Posicionamento De Linha Pois o RECNO da Grid Está Zerado
	oModelGrid:GoLine( nLinOld )

	//-- Atualiza Grid Para o Posicionamento Correto
	oView:Refresh('VwGridTRB')

	//-- Dá Refresh na View De Totalizações Para Atualizar Dados Na Tela
	oView:Refresh('VwFieldTot')

	//-- Reposiciona na Linha Original Da Grid
	//FWRestRows( aSaveLines )

	RestArea(aArea)

Return .t.
//-------------------------------------------------------------------
/*/{Protheus.doc} A019StrTot
Executa Query Para Geração Do Browse Temporário
@author Eduardo Alberti
@since  Nov/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function A019StrTot( nType )

	Local oStruct   := Nil

	If nType == TYPE_MODEL

		oStruct := FWFormModelStruct():New()

		// Adiciona Campos De Totalização

		oStruct:AddField(	STR0007					, ; // Titulo do campo	//-- "Quantidade" 
							STR0007					, ; // ToolTip do campo	//-- "Quantidade"
							'TOT_VOLS'					, ; // Nome do Campo
							'N' 						, ; // Tipo do campo
							TamSX3("DDE_QTDVOL")[1]	, ; // Tamanho do campo
							TamSX3("DDE_QTDVOL")[2]	, ; // Decimal do campo
							NIL							, ; // Code-block de validação do campo
							NIL							, ; // Code-block de validação When do campo
							{} 							, ; // Lista de valores permitido do campo
							.F.							, ; // Indica se o campo tem preenchimento obrigatório
							NIL							, ; // Code-block de inicializacao do campo
							NIL 						, ; // Indica se trata de um campo chave
							NIL 						, ; // Indica se o campo pode receber valor em uma operação de update.
							.T. 						) 	// Indica se o campo é virtual

		oStruct:AddField(	STR0026					, ; // Titulo do campo	//-- "Unitizadores"  
							STR0026					, ; // ToolTip do campo	//-- "Unitizadores" 
							'TOT_UNIT'					, ; // Nome do Campo
							'N' 						, ; // Tipo do campo
							TamSX3("DDE_QTDUNI")[1]	, ; // Tamanho do campo
							TamSX3("DDE_QTDUNI")[2]	, ; // Decimal do campo
							NIL							, ; // Code-block de validação do campo
							NIL							, ; // Code-block de validação When do campo
							{} 							, ; // Lista de valores permitido do campo
							.F.							, ; // Indica se o campo tem preenchimento obrigatório
							NIL							, ; // Code-block de inicializacao do campo
							NIL 						, ; // Indica se trata de um campo chave
							NIL 						, ; // Indica se o campo pode receber valor em uma operação de update.
							.T. 						) 	// Indica se o campo é virtual

		oStruct:AddField(	STR0009					, ; // Titulo do campo	//-- "Peso"  
							STR0009					, ; // ToolTip do campo	//-- "Peso"
							'TOT_PESO'					, ; // Nome do Campo
							'N' 						, ; // Tipo do campo
							TamSX3("DDE_PESO")[1]	, ; // Tamanho do campo
							TamSX3("DDE_PESO")[2]	, ; // Decimal do campo
							NIL							, ; // Code-block de validação do campo
							NIL							, ; // Code-block de validação When do campo
							{} 							, ; // Lista de valores permitido do campo
							.F.							, ; // Indica se o campo tem preenchimento obrigatório
							NIL							, ; // Code-block de inicializacao do campo
							NIL 						, ; // Indica se trata de um campo chave
							NIL 						, ; // Indica se o campo pode receber valor em uma operação de update.
							.T. 						) 	// Indica se o campo é virtual

		oStruct:AddField(	STR0010					, ; // Titulo do campo	//-- "Peso M3" 
							STR0010					, ; // ToolTip do campo	//-- "Peso M3"
							'TOT_PES3'					, ; // Nome do Campo
							'N' 						, ; // Tipo do campo
							TamSX3("DDE_PESOM3")[1]	, ; // Tamanho do campo
							TamSX3("DDE_PESOM3")[2]	, ; // Decimal do campo
							NIL							, ; // Code-block de validação do campo
							NIL							, ; // Code-block de validação When do campo
							{} 							, ; // Lista de valores permitido do campo
							.F.							, ; // Indica se o campo tem preenchimento obrigatório
							NIL							, ; // Code-block de inicializacao do campo
							NIL 						, ; // Indica se trata de um campo chave
							NIL 						, ; // Indica se o campo pode receber valor em uma operação de update.
							.T. 						) 	// Indica se o campo é virtual

		oStruct:AddField(	STR0011					, ; // Titulo do campo	//-- "Valor" 
							STR0011					, ; // ToolTip do campo	//-- "Valor"
							'TOT_VLRR'					, ; // Nome do Campo
							'N' 						, ; // Tipo do campo
							TamSX3("DDE_VALMER")[1]	, ; // Tamanho do campo
							TamSX3("DDE_VALMER")[2]	, ; // Decimal do campo
							NIL							, ; // Code-block de validação do campo
							NIL							, ; // Code-block de validação When do campo
							{} 							, ; // Lista de valores permitido do campo
							.F.							, ; // Indica se o campo tem preenchimento obrigatório
							NIL							, ; // Code-block de inicializacao do campo
							NIL 						, ; // Indica se trata de um campo chave
							NIL 						, ; // Indica se o campo pode receber valor em uma operação de update.
							.T. 						) 	// Indica se o campo é virtual

	Else

		oStruct := FWFormViewStruct():New()

		oStruct:AddField('TOT_VOLS'  						, ; // [01] C Nome do Campo
							'01'    							, ; // [02] C Ordem
							STR0007							, ; // [03] C Titulo do campo  		//-- "Quantidade"
							STR0007   							, ; // [04] C Descrição do campo	//-- "Quantidade"
							{" "}   							, ; // [05] A Array com Help 
							'N'    							, ; // [06] C Tipo do campo
							PesqPict("DDE","DDE_QTDVOL")	, ; // [07] C Picture
							NIL    							, ; // [08] B Bloco de Picture Var
							''     							, ; // [09] C Consulta F3
							.F.    							, ; // [10] L Indica se o campo é editável
							NIL    							, ; // [11] C Pasta do campo
							NIL    							, ; // [12] C Agrupamento do campo
							{ }    							, ; // [13] A Lista de valores permitido do campo (Combo)
							NIL    							, ; // [14] N Tamanho Maximo da maior opção do combo
							NIL    							, ; // [15] C Inicializador de Browse
							.T.    							, ; // [16] L Indica se o campo é virtual
							NIL     						 	)   // [17] C Picture Variável

		oStruct:AddField('TOT_UNIT'  						, ; // [01] C Nome do Campo
							'02'    							, ; // [02] C Ordem
							STR0026							, ; // [03] C Titulo do campo  		//-- "Unitizadores"
							STR0026   							, ; // [04] C Descrição do campo  	//-- "Unitizadores"
							{" "}   							, ; // [05] A Array com Help
							'N'    							, ; // [06] C Tipo do campo
							PesqPict("DDE","DDE_QTDUNI")	, ; // [07] C Picture
							NIL    							, ; // [08] B Bloco de Picture Var
							''     							, ; // [09] C Consulta F3
							.F.    							, ; // [10] L Indica se o campo é editável
							NIL    							, ; // [11] C Pasta do campo
							NIL    							, ; // [12] C Agrupamento do campo
							{ }    							, ; // [13] A Lista de valores permitido do campo (Combo)
							NIL    							, ; // [14] N Tamanho Maximo da maior opção do combo
							NIL    							, ; // [15] C Inicializador de Browse
							.T.    							, ; // [16] L Indica se o campo é virtual
							NIL     						 	)   // [17] C Picture Variável

		oStruct:AddField('TOT_PESO'  						, ; // [01] C Nome do Campo
							'03'    							, ; // [02] C Ordem
							STR0009							, ; // [03] C Titulo do campo  		//-- "Peso"
							STR0009   							, ; // [04] C Descrição do campo	//-- "Peso"
							{" "}   							, ; // [05] A Array com Help 
							'N'    							, ; // [06] C Tipo do campo
							PesqPict("DDE","DDE_PESO")		, ; // [07] C Picture
							NIL    							, ; // [08] B Bloco de Picture Var
							''     							, ; // [09] C Consulta F3
							.F.    							, ; // [10] L Indica se o campo é editável
							NIL    							, ; // [11] C Pasta do campo
							NIL    							, ; // [12] C Agrupamento do campo
							{ }    							, ; // [13] A Lista de valores permitido do campo (Combo)
							NIL    							, ; // [14] N Tamanho Maximo da maior opção do combo
							NIL    							, ; // [15] C Inicializador de Browse
							.T.    							, ; // [16] L Indica se o campo é virtual
							NIL     						 	)   // [17] C Picture Variável

		oStruct:AddField('TOT_PES3'  						, ; // [01] C Nome do Campo
							'04'    							, ; // [02] C Ordem
							STR0010							, ; // [03] C Titulo do campo  		//-- "Peso M3"
							STR0010   							, ; // [04] C Descrição do campo	//-- "Peso M3"
							{" "}   							, ; // [05] A Array com Help 
							'N'    							, ; // [06] C Tipo do campo
							PesqPict("DDE","DDE_PESOM3")	, ; // [07] C Picture
							NIL    							, ; // [08] B Bloco de Picture Var
							''     							, ; // [09] C Consulta F3
							.F.    							, ; // [10] L Indica se o campo é editável
							NIL    							, ; // [11] C Pasta do campo
							NIL    							, ; // [12] C Agrupamento do campo
							{ }    							, ; // [13] A Lista de valores permitido do campo (Combo)
							NIL    							, ; // [14] N Tamanho Maximo da maior opção do combo
							NIL    							, ; // [15] C Inicializador de Browse
							.T.    							, ; // [16] L Indica se o campo é virtual
							NIL     						 	)   // [17] C Picture Variável

		oStruct:AddField('TOT_VLRR'  						, ; // [01] C Nome do Campo
							'05'    							, ; // [02] C Ordem
							STR0011							, ; // [03] C Titulo do campo  		//-- "Valor3"
							STR0011   							, ; // [04] C Descrição do campo	//-- "Valor"
							{" "}   							, ; // [05] A Array com Help 
							'N'    							, ; // [06] C Tipo do campo
							PesqPict("DDE","DDE_VALMER")	, ; // [07] C Picture
							NIL    							, ; // [08] B Bloco de Picture Var
							''     							, ; // [09] C Consulta F3
							.F.    							, ; // [10] L Indica se o campo é editável
							NIL    							, ; // [11] C Pasta do campo
							NIL    							, ; // [12] C Agrupamento do campo
							{ }    							, ; // [13] A Lista de valores permitido do campo (Combo)
							NIL    							, ; // [14] N Tamanho Maximo da maior opção do combo
							NIL    							, ; // [15] C Inicializador de Browse
							.T.    							, ; // [16] L Indica se o campo é virtual
							NIL     						  	)   // [17] C Picture Variável

	EndIf

Return(oStruct)
//-------------------------------------------------------------------
/*/{Protheus.doc} TM019LdGrd
Função Para Execução da Query Que Será Enviada Para o Grid Da Tela Por
Meio da Função FWLoadByAlias
@author Eduardo Alberti
@since  Nov/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function TM019LdGrd( oMdl )

	Local aArea      := GetArea()
	Local nTotReg    := 0
	Local cAliasT    := GetNextAlias()
	Local bQuery     := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
	Local aRet       := {}
	Local aStruQry   := {}
	Local nLinha     := 0

	//-- Recarrega Variaveis Antes Da Execução
	Pergunte( cPerg , .f. )

	cQuery := ""
	cQuery += " SELECT      DDD.DDD_DATAGE, DDD.DDD_HORAGE, DDD.DDD_DATPRC, DDD.DDD_ARQUIV, DDD.DDD_CODLAY, DDD.DDD_NUMMRP, "
	
	cQuery += "             CASE DDD.DDD_STATUS "
	cQuery += "             WHEN '1' THEN '1-' || '" + STR0015 + "' " //-- Importado
	cQuery += "             WHEN '2' THEN '2-' || '" + STR0016 + "' " //-- Pendente
	cQuery += "             WHEN '3' THEN '3-' || '" + STR0017 + "' " //-- Processado
	cQuery += "             ELSE          '            ' " 
	cQuery += "             END  AS TRB_STAT , "
	
	cQuery += "             CASE DDD.DDD_STATUS "
	cQuery += "             WHEN '1' THEN 'BR_AMARELO' "
	cQuery += "             WHEN '2' THEN 'BR_VERDE' "
	cQuery += "             WHEN '3' THEN 'BR_VERMELHO' "
	cQuery += "             END  AS TRB_LEGEN , "
	
	cQuery += "             DDD.DDD_CODSOL, DUE.DUE_NREDUZ, "													//-- Solicitante
	cQuery += "             DDD.DDD_CLIDEV, DDD.DDD_LOJDEV,                 TOMA.A1_NOME AS DDD_NOMDEV, "	//-- Tomador
	cQuery += "             DDD.DDD_CLIREM, DDD.DDD_LOJREM, DDD.DDD_SQEREM, REMT.A1_NOME AS DDD_NOMREM, "	//-- Remetente
	cQuery += "             DDD.DDD_CLIDES, DDD.DDD_LOJDES, DDD.DDD_SQEDES, DEST.A1_NOME AS DDD_NOMDES, "	//-- Destinatário

	cQuery += "             SUM(DDE.DDE_QTDVOL) AS DDE_QTDVOL , "
	cQuery += "             SUM(DDE.DDE_QTDUNI) AS DDE_QTDUNI , "
	cQuery += "             SUM(DDE.DDE_PESO)   AS DDE_PESO   , "
	cQuery += "             SUM(DDE.DDE_VALMER) AS DDE_VALMER , "
	cQuery += "             SUM(DDE.DDE_BASSEG) AS DDE_BASSEG , "
	cQuery += "             SUM(DDE.DDE_METRO3) AS DDE_METRO3 , "
	cQuery += "             SUM(DDE.DDE_PESOM3) AS DDE_PESOM3 , "
	cQuery += "             0 RECNO "

	cQuery += " FROM        " +	RetSqlName("DDD") + " DDD "  					//-- Agendatentos Cabecalho

	cQuery += " INNER JOIN  " +	RetSqlName("DDE") + " DDE "  					//-- AgendametosS Itens
	cQuery += " ON          DDE.DDE_FILIAL  =  '" + xFilial("DDE") + "' "
	cQuery += " AND		   DDE.DDE_DATAGE  =  DDD.DDD_DATAGE "
	cQuery += " AND		   DDE.DDE_HORAGE  =  DDD.DDD_HORAGE "
	cQuery += " AND		   DDE.DDE_CLIDES  =  DDD.DDD_CLIDES "
	cQuery += " AND		   DDE.DDE_LOJDES  =  DDD.DDD_LOJDES "
	cQuery += " AND		   DDE.DDE_SQEDES  =  DDD.DDD_SQEDES "
	cQuery += " AND		   DDE.DDE_CLIREM  =  DDD.DDD_CLIREM "
	cQuery += " AND		   DDE.DDE_LOJREM  =  DDD.DDD_LOJREM "
	cQuery += " AND		   DDE.DDE_SQEREM  =  DDD.DDD_SQEREM "
	cQuery += " AND		   DDE.D_E_L_E_T_  =  ' ' "

	cQuery += " INNER JOIN  " +	RetSqlName("DUE") + " DUE "  					//-- Solicitantes
	cQuery += " ON          DUE.DUE_FILIAL  =  '" + xFilial("DUE") + "' "
	cQuery += " AND         DUE.DUE_CODSOL  =  DDD.DDD_CODSOL "
	cQuery += " AND         DUE.D_E_L_E_T_  =  ' ' "

	cQuery += " INNER JOIN  " +	RetSqlName("SA1") + " TOMA " 					//-- Clientes (Tomador)
	cQuery += " ON          TOMA.A1_FILIAL  =  '" + xFilial("SA1") + "' "
	cQuery += " AND         TOMA.A1_COD     =  DDD.DDD_CLIDEV "
	cQuery += " AND         TOMA.A1_LOJA    =  DDD.DDD_LOJDEV "
	cQuery += " AND         TOMA.D_E_L_E_T_ =  ' ' "

	cQuery += " INNER JOIN  " +	RetSqlName("SA1") + " REMT " 					//-- Clientes (Remetente)
	cQuery += " ON          REMT.A1_FILIAL  =  '" + xFilial("SA1") + "' "
	cQuery += " AND         REMT.A1_COD     =  DDD.DDD_CLIREM "
	cQuery += " AND         REMT.A1_LOJA    =  DDD.DDD_LOJREM "
	cQuery += " AND         REMT.D_E_L_E_T_ =  ' ' "

	cQuery += " INNER JOIN  " +	RetSqlName("SA1") + " DEST " 					//-- Clientes (Destinatario)
	cQuery += " ON          DEST.A1_FILIAL  =  '" + xFilial("SA1") + "' "
	cQuery += " AND         DEST.A1_COD     =  DDD.DDD_CLIDES "
	cQuery += " AND         DEST.A1_LOJA    =  DDD.DDD_LOJDES "
	cQuery += " AND         DEST.D_E_L_E_T_ =  ' ' "

	cQuery += " WHERE       DDD.DDD_FILIAL  =  '" + xFilial("DDD") + "' "

	If MV_PAR19 == 2 //-- Pendentes
		cQuery += " AND         DDD.DDD_STATUS  =  '2' " 							//-- 1=EDI Importado; 2=Processado; 3=Agendamento Gerado
	ElseIf	MV_PAR19 == 3 //-- Processados
		cQuery += " AND         DDD.DDD_STATUS  =  '3' " 							//-- 1=EDI Importado; 2=Processado; 3=Agendamento Gerado
	EndIf
		
	cQuery += " AND         DDD.DDD_CODSOL  BETWEEN  '" + MV_PAR01       + "' AND '" + MV_PAR02       + "' "
	cQuery += " AND         DDD.DDD_CLIDEV  BETWEEN  '" + MV_PAR03       + "' AND '" + MV_PAR05       + "' "
	cQuery += " AND         DDD.DDD_LOJDEV  BETWEEN  '" + MV_PAR04       + "' AND '" + MV_PAR06       + "' "
	cQuery += " AND         DDD.DDD_CLIREM  BETWEEN  '" + MV_PAR07       + "' AND '" + MV_PAR09       + "' "
	cQuery += " AND         DDD.DDD_LOJREM  BETWEEN  '" + MV_PAR08       + "' AND '" + MV_PAR10       + "' "
	cQuery += " AND         DDD.DDD_CLIDES  BETWEEN  '" + MV_PAR11       + "' AND '" + MV_PAR13       + "' "
	cQuery += " AND         DDD.DDD_LOJDES  BETWEEN  '" + MV_PAR12       + "' AND '" + MV_PAR14       + "' "
	cQuery += " AND         DDD.DDD_DATAGE  BETWEEN  '" + DtoS(MV_PAR15) + "' AND '" + DtoS(MV_PAR16) + "' "
	cQuery += " AND         DDD.DDD_DATPRC  BETWEEN  '" + DtoS(MV_PAR17) + "' AND '" + DtoS(MV_PAR18) + "' "
	cQuery += " AND         DDD.D_E_L_E_T_  =  ' ' "
	cQuery += " GROUP BY    DDD.DDD_DATAGE, DDD.DDD_HORAGE, DDD.DDD_DATPRC, DDD.DDD_NUMMRP, "
	cQuery += "             DDD.DDD_CODSOL, DUE.DUE_NREDUZ, "
	cQuery += "             DDD.DDD_CLIDEV, DDD.DDD_LOJDEV,                 TOMA.A1_NOME, "
	cQuery += "             DDD.DDD_CLIREM, DDD.DDD_LOJREM, DDD.DDD_SQEREM, REMT.A1_NOME, "
	cQuery += "             DDD.DDD_CLIDES, DDD.DDD_LOJDES, DDD.DDD_SQEDES, DEST.A1_NOME, "
	cQuery += "             DDD.DDD_ARQUIV, DDD.DDD_CODLAY, DDD.DDD_STATUS  "
	cQuery += " ORDER BY    DDD.DDD_DATAGE, DDD.DDD_HORAGE, DDD.DDD_DATPRC , DDD.DDD_NUMMRP,  DDD_CODSOL, DDD_CLIREM, DDD_LOJREM, DDD.DDD_CLIDES, DDD.DDD_LOJDES "

	cQuery := ChangeQuery(cQuery)

	//-- Executa QUERY
	Eval(bQuery)
	
	//-- Formata Campos Da Query
	aStruQry := (cAliasT)->(DbStruct())
	
	For nLinha := 1 To Len(aStruQry)		
	   	   If GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO") == "D" .Or. GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO") == "N"
	          TCSetField( cAliasT , aStruQry[nLinha][1], GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO"), GetSX3Cache(aStruQry[nLinha][1],"X3_TAMANHO") , GetSX3Cache(aStruQry[nLinha][1],"X3_DECIMAL"))
	       Endif		
	Next nLinha	

	/*
	FWLoadByAlias
	Função que realiza a carga de um submodelo baseado em um alias existente
	
	@param oObj                           Objeto do submodelo (FWFormFieldsModel ou FWFormGridModel)
	@param cAlias             Alias para carga .
	@param cAliasReal      Alias Real. Utilizado para carga de campos MEMO reais na tabela, se houver e para uso real de inicializadores padrao, 
	                                                           se nao for informado usa a tabela definida na estrutura do objeto.
	@param cFieldRecno  Nome do campo que contem o numero do recno. Quando a tabela foi criada a partir de uma query
	                                                           deve ter uma coluna contendo o recno() real do registro. Se o nome desta coluna for R_E_C_N_O_ ou 
	                                                           RECNO ou Alias+RECNO, nao é preciso informar o nome da coluna neste parametro, caso contrario deve-se informar.
	@param lCopy              Apenas para compatibilidade, Nao usar
	@param lQuery             Indica que o alias foi criado a partir de uma query.
	*/
	
	// Como tem o campo R_E_C_N_O_, nao é preciso informar qual o campo contem o Recno() real
	aRet := FWLoadByAlias( oMdl , cAliasT , 'DDD' , Nil , Nil , .t. ) 
	
	//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf	

	RestArea(aArea)

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA019Agd
Gera Os Agendamentos Conforme Itens Marcados Na Grid
@author Eduardo Alberti
@since  Nov/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function TMSA019Agd(oView)

	Local lOk := .f.

	Processa( { || lOk := TMSA019Ag2(oView) }, STR0012 , STR0013 + '...',.F.) //-- "Aguarde" "Processando"

Return lOk

Static Function TMSA019Ag2(oView)

	Local aArea		:= GetArea()
	Local aSaveLines	:= FWSaveRows()	//-- Captura Posicionamento Da Grid
	Local oModel		:= oView:GetModel() 
	Local oModelGrid	:= oView:GetModel( 'MdGridTRB' )
	Local nLinOld		:= oModelGrid:nLine
	Local nI 			:= 0
	Local aDadAgen	:= {}
	Local aPrwDF0		:= {}
	Local aPrwDF1		:= {}
	Local aPrwDF2		:= {}
	Local aRecDDD		:= {}
	Local nRet			:= 0	
	
	Default lRet         := .T.
	
	//-- Seta Gauge De Processamento
	ProcRegua(oModelGrid:Length())

	//-- Executa Loop Em Toda a Grid
	For nI := 1 To oModelGrid:Length()
	
		//-- Incrementa Gauge De Processamento
		IncProc()
			
		//-- Posiciona Na Linha Da Grid Conforme o Cursor
		oModelGrid:GoLine( nI )
				
		//-- Verifica Se Linha Não Está Deletada
		If !oModelGrid:IsDeleted()
		
			//-- Esvazia Vetor
			aDadAgen := {}		
			
			//-- Verifica Se Item Da Grid Está Marcado
			If oModel:GetValue( 'MdGridTRB' , 'TRB_MARK' ) .And. Substr(oModel:GetValue( 'MdGridTRB' , 'TRB_STAT' ),1,1) == '2' //-- 2 = Pendente
			
				//-- Incrementa Vetor De Referencias Do Processamento
				aAdd( aDadAgen ,{	"DDD_NUMMRP" , oModel:GetValue( 'MdGridTRB' , 'DDD_NUMMRP') 		})
				aAdd( aDadAgen ,{	"DDD_DATAGE" , DtoS(oModel:GetValue( 'MdGridTRB' , 'DDD_DATAGE'))	})
				aAdd( aDadAgen ,{	"DDD_HORAGE" , oModel:GetValue( 'MdGridTRB' , 'DDD_HORAGE') 		})
				aAdd( aDadAgen ,{	"DDD_DATPRC" , DtoS(oModel:GetValue( 'MdGridTRB' , 'DDD_DATPRC'))	})
				aAdd( aDadAgen ,{	"DDD_CODSOL" , oModel:GetValue( 'MdGridTRB' , 'DDD_CODSOL') 		})
				aAdd( aDadAgen ,{	"DDD_CLIDEV" , oModel:GetValue( 'MdGridTRB' , 'DDD_CLIDEV') 		})
				aAdd( aDadAgen ,{	"DDD_LOJDEV" , oModel:GetValue( 'MdGridTRB' , 'DDD_LOJDEV') 		})
				aAdd( aDadAgen ,{	"DDD_CLIREM" , oModel:GetValue( 'MdGridTRB' , 'DDD_CLIREM') 		})
				aAdd( aDadAgen ,{	"DDD_LOJREM" , oModel:GetValue( 'MdGridTRB' , 'DDD_LOJREM') 		})
				aAdd( aDadAgen ,{	"DDD_CLIDES" , oModel:GetValue( 'MdGridTRB' , 'DDD_CLIDES') 		})
				aAdd( aDadAgen ,{	"DDD_LOJDES" , oModel:GetValue( 'MdGridTRB' , 'DDD_LOJDES') 		})
				aAdd( aDadAgen ,{	"DDD_ARQUIV" , oModel:GetValue( 'MdGridTRB' , 'DDD_ARQUIV') 		})
				aAdd( aDadAgen ,{	"DDD_CODLAY" , oModel:GetValue( 'MdGridTRB' , 'DDD_CODLAY') 		})
				
				//-- Executa Rotina De Geração Do Agendamento Automático
				TMSAgAUT(	oModel:GetValue( 'MdGridTRB' , 'DDD_CLIREM') ,;
							oModel:GetValue( 'MdGridTRB' , 'DDD_LOJREM') ,;
							oModel:GetValue( 'MdGridTRB' , 'DDD_CODLAY') ,;
							aDadAgen	,;
							aPrwDF0	,;
							aPrwDF1	,;
							aPrwDF2	,;
							@aRecDDD	)
							
			EndIf
		EndIf	
	Next nI
	
	//-- Executa Tela Preview
	If Len( aPrwDF0 ) > 0
		nRet := TmsAF74( aPrwDF0, aPrwDF1, aPrwDF2, aRecDDD, @lRet )
	EndIf	
		
	If nRet == 0 .And. lRet
		//-- Atualiza Status Da Linha Processada
		For nI := 1 To oModelGrid:Length()
		
			//-- Posiciona Na Linha Da Grid Conforme o Cursor
			oModelGrid:GoLine( nI )
					
			//-- Verifica Se Linha Não Está Deletada
			If !oModelGrid:IsDeleted()
			
				//-- Verifica Se Item Da Grid Está Marcado
				If oModel:GetValue( 'MdGridTRB' , 'TRB_MARK' ) .And. Substr(oModel:GetValue( 'MdGridTRB' , 'TRB_STAT' ),1,1) == '2' //-- 2 = Pendente
				
						oModelGrid:SetValue("TRB_LEGEN"	,"BR_VERMELHO"  			)
						oModelGrid:SetValue("TRB_STAT"	,"3-" + Upper(STR0017) 	)
							
				EndIf
			EndIf	
		Next nI	
	EndIf

	//-- Força Posicionamento De Linha Pois o RECNO da Grid Está Zerado
	oModelGrid:GoLine( nLinOld )
			
	//-- Dá Refresh na View De Grid Para Atualizar Dados Na Tela
	oView:Refresh('VwGridTRB')
	
	//-- Reposiciona na Linha Original Da Grid
	//FWRestRows( aSaveLines )

	RestArea(aArea)

Return(.t.)

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA019Leg
Mostra Legenda Dos Status De Registros
@author Eduardo Alberti
@since  Nov/2015
@version P12
/*/
//-------------------------------------------------------------------
Function TMSA019Leg()

	Local aLegenda := {}

	Aadd(aLegenda,{"BR_AMARELO"	, STR0015})	//-- "Importado"
	Aadd(aLegenda,{"BR_VERDE"	, STR0016})	//-- "Pendente"
	Aadd(aLegenda,{"BR_VERMELHO", STR0017})	//-- "Processado"
 
	If Len(aLegenda) > 0
		BrwLegenda( STR0018 , STR0018 , aLegenda )  //-- Legenda
	EndIf
				
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA019Mnt
Executa FWExecView Para Manutenção Das Tabelas DDD e DDE
@author Eduardo Alberti
@since  Nov/2015
@version P12
/*/
//-------------------------------------------------------------------
Function TMSA019Mnt(oView,nOpc)

	Local aArea		:= GetArea()
	Local oModel		:= oView:GetModel()
	Local aSaveLines	:= FWSaveRows()	//-- Captura Posicionamento Da Grid
	Local oModelGrid	:= oModel:GetModel( 'MdGridTRB' )
	Local nLinOld		:= oModelGrid:nLine
	Local nOpcMdl		:= 0
	Local cDescOpc	:= ""
	Local aButtons	:= {}
	Local aMarks		:= {}
	Local lOk			:= .f.

	//-- Determina Variáveis De Posicionamento
	Local cDDD_DATAGE	:= ""
	Local cDDD_HORAGE	:= ""
	Local cDDD_CLIDES	:= ""
	Local cDDD_LOJDES	:= ""
	Local cDDD_SQEDES	:= ""
	Local cDDD_CLIREM	:= ""
	Local cDDD_LOJREM	:= ""
	Local cDDD_SQEREM	:= ""
	
	Default nOpc		:= 2 //-- Visualizar

	If nOpc <> 99			//-- 99 = "Parametros"
		cDDD_DATAGE	:= DtoS(oModel:GetValue( 'MdGridTRB' , 'DDD_DATAGE'))
		cDDD_HORAGE	:= oModel:GetValue( 'MdGridTRB' , 'DDD_HORAGE')
		cDDD_CLIDES	:= oModel:GetValue( 'MdGridTRB' , 'DDD_CLIDES')
		cDDD_LOJDES	:= oModel:GetValue( 'MdGridTRB' , 'DDD_LOJDES')
		cDDD_SQEDES	:= oModel:GetValue( 'MdGridTRB' , 'DDD_SQEDES')
		cDDD_CLIREM	:= oModel:GetValue( 'MdGridTRB' , 'DDD_CLIREM')
		cDDD_LOJREM	:= oModel:GetValue( 'MdGridTRB' , 'DDD_LOJREM')
		cDDD_SQEREM	:= oModel:GetValue( 'MdGridTRB' , 'DDD_SQEREM')
	EndIf	

	//-- Determina Modo De Acesso Aos Registros
	If nOpc == 2				//-- 2 = Visualizar

		nOpcMdl := MODEL_OPERATION_VIEW
		cDescOpc:= STR0019 	//-- "Visualizar"

	ElseIf nOpc == 4			//-- 4 = Alterar

		nOpcMdl := MODEL_OPERATION_UPDATE
		cDescOpc:= STR0021 	//-- "Alterar"

	ElseIf nOpc == 99			//-- 99 = "Parametros"
	
		Pergunte( cPerg , .t. )
	
	Else

		nOpcMdl := MODEL_OPERATION_VIEW
		cDescOpc:= STR0019 	//-- "Visualizar"

	EndIf

	If nOpc <> 99			//-- 99 = "Parametros"

		//-- Posiciona No Cabeçalho Dos Registros Importados
		DbSelectArea("DDD")
		DbSetOrder(1) //-- DDD_FILIAL+DTOS(DDD_DATAGE)+DDD_HORAGE+DDD_CLIDES+DDD_LOJDES+DDD_SQEDES+DDD_CLIREM+DDD_LOJREM+DDD_SQEREM
		If MsSeek( xFilial("DDD") + cDDD_DATAGE + cDDD_HORAGE + cDDD_CLIDES + cDDD_LOJDES + cDDD_SQEDES + cDDD_CLIREM + cDDD_LOJREM + cDDD_SQEREM ,.f.)
	
			//-- Executa a View
			lOk := ( FWExecView( cDescOpc ,'TMSA019A', nOpcMdl, , { || .T. } ) == 0 )  
	
		Else
			Help("",1,"TMSA01902",/*Titulo*/, STR0024 /*Mensagem*/,1,0) //-- "Registro Não Encontrado!"
		EndIf
	EndIf	

	//-- Tratamento Para Atualização Da Tela Do Model TMSA019
	If ( lOk .And. nOpcMdl == MODEL_OPERATION_UPDATE ) .Or. (nOpc == 99) //-- 99 = "Parametros"
		
		//-- Carrega Vetor Que Salva a Marcação De Itens
		aMarks := Tmsa019Mrk( oView , oModel , oModelGrid )

		//-- Na nova carga do Grid, as linhas existentes são apagadas.
		If oModelGrid:CanClearData() 
			oModelGrid:ClearData()
		EndIf		
		
		//-- Desativa Modelo Da Grid
		oModelGrid:DeActivate()
		
		//-- Ativa Modelo Da Grid Para Forçar Execução Da Query De Montagem Da Grid
		oModelGrid:Activate()
		
		//-- Verifica Se Primeira Linha Está Vazia
		If ValType(oModelGrid:aDataModel) == "A" .And. Len(oModelGrid:aDataModel) > 1
		
			aDataMdl := oModelGrid:aDataModel	//-- Copia Array Para Variavel Static Para Testar Se a Posição Existe No Vetor
			If Type('aDataMdl[1,1,1,1]') <> "U" .And. Empty(oModelGrid:aDataModel[1,1,1,1])
			
				//-- Deleta Linha Em Branco Da Grid
				aDel(oModelGrid:aDataModel , 1 )
				aSize(oModelGrid:aDataModel , Len(oModelGrid:aDataModel) -1 )
				
			EndIf
		EndIf
		
		//-- Executa Função Para Atualização Dos Fields De Totais
		Tmsa019Tot( oView , oModel , oModelGrid, aMarks )	
		
		//-- Força Posicionamento De Linha Pois o RECNO da Grid Está Zerado
		oModelGrid:GoLine( nLinOld )

		//-- Dá Refresh na View De Grid Para Atualizar Dados Na Tela
		oView:Refresh('VwGridTRB')
		
	EndIf		

	//-- Reposiciona na Linha Original Da Grid
	//FWRestRows( aSaveLines )
	
	RestArea(aArea)

Return .F.
//-------------------------------------------------------------------
/*/{Protheus.doc} Tmsa019Mrk
Salva Marcações De Usuário Da Grid
@author Eduardo Alberti
@since  Dec/2015
@version P12
/*/
//-------------------------------------------------------------------
Function Tmsa019Mrk( oView , oModel , oModelGrid )

	Local aArea		:= GetArea()
	Local aRet			:= {}
	Local nI 			:= 0

	//-- Variáveis De Posicionamento
	Local cDDD_DATAGE	:= ""
	Local cDDD_HORAGE	:= ""
	Local cDDD_CLIDES	:= ""
	Local cDDD_LOJDES	:= ""
	Local cDDD_SQEDES	:= ""
	Local cDDD_CLIREM	:= ""
	Local cDDD_LOJREM	:= ""
	Local cDDD_SQEREM	:= ""

	//-- Inicializa Variáveis Default
	Default oView			:= FWViewActive()
	Default oModel		:= oView:GetModel()
	Default oModelGrid	:= oView:GetModel( 'MdGridTRB' )
	
	//-- Executa Loop Em Toda a Grid
	For nI := 1 To oModelGrid:Length()
	
		//-- Posiciona Na Linha Da Grid Conforme o Cursor
		oModelGrid:GoLine( nI )
				
		//-- Verifica Se Linha Não Está Deletada
		If !oModelGrid:IsDeleted()
		
			//-- Se Estiver Marcado Soma Totalizadores
			If oModel:GetValue( 'MdGridTRB' , 'TRB_MARK')

				cDDD_DATAGE	:= DtoS(oModel:GetValue( 'MdGridTRB' , 'DDD_DATAGE'))
	 			cDDD_HORAGE	:= oModel:GetValue( 'MdGridTRB' , 'DDD_HORAGE')
	 			cDDD_CLIDES	:= oModel:GetValue( 'MdGridTRB' , 'DDD_CLIDES')
	 			cDDD_LOJDES	:= oModel:GetValue( 'MdGridTRB' , 'DDD_LOJDES')
	 			cDDD_SQEDES	:= oModel:GetValue( 'MdGridTRB' , 'DDD_SQEDES')
	 			cDDD_CLIREM	:= oModel:GetValue( 'MdGridTRB' , 'DDD_CLIREM')
	 			cDDD_LOJREM	:= oModel:GetValue( 'MdGridTRB' , 'DDD_LOJREM')
	 			cDDD_SQEREM	:= oModel:GetValue( 'MdGridTRB' , 'DDD_SQEREM')

				//-- Posiciona No Cabeçalho Dos Registros Importados
				DbSelectArea("DDD")
				DbSetOrder(1) //-- DDD_FILIAL+DTOS(DDD_DATAGE)+DDD_HORAGE+DDD_CLIDES+DDD_LOJDES+DDD_SQEDES+DDD_CLIREM+DDD_LOJREM+DDD_SQEREM
				If MsSeek( xFilial("DDD") + cDDD_DATAGE + cDDD_HORAGE + cDDD_CLIDES + cDDD_LOJDES + cDDD_SQEDES + cDDD_CLIREM + cDDD_LOJREM + cDDD_SQEREM ,.f.)
				
					aAdd( aRet, DDD->(Recno()) )
					
				EndIf
			EndIf
		EndIf
	Next nI				

	RestArea(aArea)

Return(aRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} Tmsa019Tot
Executa Função Para Atualização Dos Fields De Totalização
@author Eduardo Alberti
@since  Dec/2015
@version P12
/*/
//-------------------------------------------------------------------
Function Tmsa019Tot( oView , oModel , oModelGrid, aMarks )

	Local aArea		:= GetArea()
	Local nI 			:= 0

	//-- Variáveis De Posicionamento
	Local cDDD_DATAGE	:= ""
	Local cDDD_HORAGE	:= ""
	Local cDDD_CLIDES	:= ""
	Local cDDD_LOJDES	:= ""
	Local cDDD_SQEDES	:= ""
	Local cDDD_CLIREM	:= ""
	Local cDDD_LOJREM	:= ""
	Local cDDD_SQEREM	:= ""

	//-- Variaveis De Totalização
	Local nTot_Vols	:= 0
	Local nTot_Unit	:= 0
	Local nTot_Peso	:= 0
	Local nTot_Pes3	:= 0
	Local nTot_Vlrr	:= 0
	
	//-- Inicializa Variáveis Default
	Default oView			:= FWViewActive()
	Default oModel		:= oView:GetModel()
	Default oModelGrid	:= oView:GetModel( 'MdGridTRB' )
	Default aMarks		:= {}
	
	//-- Executa Loop Em Toda a Grid
	For nI := 1 To oModelGrid:Length()
	
		//-- Posiciona Na Linha Da Grid Conforme o Cursor
		oModelGrid:GoLine( nI )
				
		//-- Verifica Se Linha Não Está Deletada
		If !oModelGrid:IsDeleted()
		
			//-- Atribui Marcações Anteriores Caso Existam
			If Len(aMarks) > 0

				cDDD_DATAGE	:= DtoS(oModel:GetValue( 'MdGridTRB' , 'DDD_DATAGE'))
	 			cDDD_HORAGE	:= oModel:GetValue( 'MdGridTRB' , 'DDD_HORAGE')
	 			cDDD_CLIDES	:= oModel:GetValue( 'MdGridTRB' , 'DDD_CLIDES')
	 			cDDD_LOJDES	:= oModel:GetValue( 'MdGridTRB' , 'DDD_LOJDES')
	 			cDDD_SQEDES	:= oModel:GetValue( 'MdGridTRB' , 'DDD_SQEDES')
	 			cDDD_CLIREM	:= oModel:GetValue( 'MdGridTRB' , 'DDD_CLIREM')
	 			cDDD_LOJREM	:= oModel:GetValue( 'MdGridTRB' , 'DDD_LOJREM')
	 			cDDD_SQEREM	:= oModel:GetValue( 'MdGridTRB' , 'DDD_SQEREM')

				//-- Posiciona No Cabeçalho Dos Registros Importados
				DbSelectArea("DDD")
				DbSetOrder(1) //-- DDD_FILIAL+DTOS(DDD_DATAGE)+DDD_HORAGE+DDD_CLIDES+DDD_LOJDES+DDD_SQEDES+DDD_CLIREM+DDD_LOJREM+DDD_SQEREM
				If MsSeek( xFilial("DDD") + cDDD_DATAGE + cDDD_HORAGE + cDDD_CLIDES + cDDD_LOJDES + cDDD_SQEDES + cDDD_CLIREM + cDDD_LOJREM + cDDD_SQEREM ,.f.)
				
					//-- Se Localizar o RECNO No Vetor o Registro Estava Marcado
					If aScan( aMarks , DDD->( Recno()) ) > 0
					
						//-- Marca Item
						oModel:SetValue( 'MdGridTRB' , 'TRB_MARK' , .t. )
						
						//-- Se Estiver Marcado Soma Totalizadores
						nTot_Vols	+= oModel:GetValue( 'MdGridTRB' , 'DDE_QTDVOL')	//-- Total Itens
						nTot_Unit	+= oModel:GetValue( 'MdGridTRB' , 'DDE_QTDUNI')	//-- Total Unitizadores
						nTot_Peso	+= oModel:GetValue( 'MdGridTRB' , 'DDE_PESO')
						nTot_Pes3	+= oModel:GetValue( 'MdGridTRB' , 'DDE_PESOM3')
						nTot_Vlrr	+= oModel:GetValue( 'MdGridTRB' , 'DDE_VALMER')
					
					EndIf
				EndIf
			EndIf
		EndIf
	Next nI

	//-- Atualiza Fields De Totalização Conforme Marcação
	If ( nTot_Unit + nTot_Vols + nTot_Peso + nTot_Pes3 + nTot_Vlrr  ) > 0

		oModel:SetValue( 'MdFieldTot' , 'TOT_VOLS' , nTot_Vols )	//-- Total Itens
		oModel:SetValue( 'MdFieldTot' , 'TOT_UNIT' , nTot_Unit )	//-- Total Unitizadores
		oModel:SetValue( 'MdFieldTot' , 'TOT_PESO' , nTot_Peso )
		oModel:SetValue( 'MdFieldTot' , 'TOT_PES3' , nTot_Pes3 )
		oModel:SetValue( 'MdFieldTot' , 'TOT_VLRR' , nTot_Vlrr )
		
		//-- Refresh Totalizador
		oView:Refresh('VwFieldTot')
		
	EndIf	
	
	RestArea(aArea)

Return(.t.)
//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA019Vis
Tela Para Visualização Do Detalhamento De Geração De Agendamentos e/ou Solicitação De Coletas Gerados
@author Eduardo Alberti
@since  Dec/2015
@version P12
/*/
//-------------------------------------------------------------------
Function TMSA019Vis(oView)

	Local aArea		:= GetArea()
	Local oModel		:= oView:GetModel()
	Local aSaveLines	:= FWSaveRows()	//-- Captura Posicionamento Da Grid
	Local oModelGrid	:= oModel:GetModel( 'MdGridTRB' )
	Local nLinOld		:= oModelGrid:nLine
	Local nI			:= 0
	Local nJ			:= 0
	Local aDadTmp		:= {}
	Local aDadAge		:= {}

	Local cQuery		:= ""
	Local nTotReg		:= 0
	Local cAliasT		:= GetNextAlias()
	Local bQuery		:= {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
	
	Local aButtons	:= {}
	Local oDlgTmp		
	Local oListTmp
	Local aCoord		:= MsAdvSize(.T.)
	Local lOpcClick	:= .f.
	Local aCab			:= {}
	Local nCount		:= 0
	
	 
 	//-- Executa Loop Em Toda a Grid
	For nI := 1 To oModelGrid:Length()
	
		//-- Posiciona Na Linha Da Grid Conforme o Cursor
		oModelGrid:GoLine( nI )
				
		//-- Verifica Se Linha Não Está Deletada
		If !oModelGrid:IsDeleted()
		
			//-- Se Estiver Marcado Soma Totalizadores
			If	oModel:GetValue( 'MdGridTRB' , 'TRB_MARK') .And. ;  //-- Marcado
				Substr(oModel:GetValue( 'MdGridTRB' , 'TRB_STAT' ),1,1) == '3' //-- 3 = Processado
			
				nCount ++ //-- Incrementa Contador

				cQuery := ""
				cQuery += " SELECT      DF0.DF0_NUMAGE, "       							//-- Numero Agendamento
				cQuery += "             DF0.DF0_NUMMRP, "
				cQuery += "             DF0.DF0_DATCAD, "
				cQuery += "             CASE DF0.DF0_STATUS "
				cQuery += "             WHEN '1' THEN '1-' || '" + STR0027 + "' " 		//-- "A Confirmar"
				cQuery += "             WHEN '2' THEN '2-' || '" + STR0028 + "' " 		//-- "Confirmado"
				cQuery += "             WHEN '3' THEN '3-' || '" + STR0029 + "' " 		//-- "Em Processo"
				cQuery += "             WHEN '4' THEN '4-' || '" + STR0030 + "' " 		//-- "Encerrado"
				cQuery += "             WHEN '5' THEN '5-' || '" + STR0031 + "' " 		//-- "Planejado"				
				cQuery += "             WHEN '9' THEN '9-' || '" + STR0032 + "' " 		//-- "Cancelado"
				cQuery += "             END  AS DF0_STATUS, "
				cQuery += "             DF1.DF1_DOC, "        							//-- Número Solic. Coleta
				cQuery += "             DF1.DF1_SERIE, "      							//-- Série Solic. Coleta
				cQuery += "             DDD.R_E_C_N_O_ AS RECDDD, " 
				cQuery += "             DF0.R_E_C_N_O_ AS RECDF0, "
				cQuery += "             DF1.R_E_C_N_O_ AS RECDF1  "
				cQuery += " FROM        " +	RetSqlName("DF0") + " DF0 "        		//-- Cabec. Agendamento
				cQuery += " INNER JOIN  " +	RetSqlName("DDD") + " DDD "        		//-- Cabecalho MRP
				cQuery += " ON          DDD.DDD_FILIAL =  '" + xFilial("DDD") + "' "
				cQuery += " AND         DDD.DDD_DATAGE =  '" + DtoS(oModel:GetValue( 'MdGridTRB' , 'DDD_DATAGE')) + "' "
				cQuery += " AND         DDD.DDD_HORAGE =  '" +      oModel:GetValue( 'MdGridTRB' , 'DDD_HORAGE')  + "' "
				cQuery += " AND         DDD.DDD_CLIDES =  '" +      oModel:GetValue( 'MdGridTRB' , 'DDD_CLIDES')  + "' "
				cQuery += " AND         DDD.DDD_LOJDES =  '" +      oModel:GetValue( 'MdGridTRB' , 'DDD_LOJDES')  + "' "
				cQuery += " AND         DDD.DDD_SQEDES =  '" +      oModel:GetValue( 'MdGridTRB' , 'DDD_SQEDES')  + "' "
				cQuery += " AND         DDD.DDD_CLIREM =  '" +      oModel:GetValue( 'MdGridTRB' , 'DDD_CLIREM')  + "' "
				cQuery += " AND         DDD.DDD_LOJREM =  '" +      oModel:GetValue( 'MdGridTRB' , 'DDD_LOJREM')  + "' "
				cQuery += " AND         DDD.DDD_SQEREM =  '" +      oModel:GetValue( 'MdGridTRB' , 'DDD_SQEREM')  + "' "
				cQuery += " AND         DDD.D_E_L_E_T_ =  ' ' "
				cQuery += " INNER JOIN  " +	RetSqlName("DF1") + " DF1 "          		//-- Itens Agendamento
				cQuery += " ON          DF1.DF1_FILIAL =  '" + xFilial("DF0") + "' "
				cQuery += " AND         DF1.DF1_NUMAGE =  DF0.DF0_NUMAGE "
				cQuery += " AND         DF1.D_E_L_E_T_ =  ' ' "
				cQuery += " WHERE       DF0.DF0_FILIAL =  '" + 		xFilial("DF0") + "' "
				cQuery += " AND         DF0.DF0_CODSOL =  '" + 		oModel:GetValue( 'MdGridTRB' , 'DDD_CODSOL') 	+ "' "
				cQuery += " AND         DF0.DF0_NUMMRP =  '" + 		oModel:GetValue( 'MdGridTRB' , 'DDD_NUMMRP') 	+ "' "
				cQuery += " AND         DF0.DF0_DATCAD =  '" + DtoS(	oModel:GetValue( 'MdGridTRB' , 'DDD_DATAGE'))	+ "' "
				cQuery += " AND         DF0.D_E_L_E_T_ =  ' ' "

				cQuery := ChangeQuery(cQuery)
			
				//-- Executa Query
				Eval(bQuery)
				
				//-- Limpa Vetor Temporário
				aDadTmp := {}

				DbSelectArea(cAliasT)
				While (cAliasT)->(!Eof())
				
					aAdd( aDadTmp , {		(cAliasT)->DF0_NUMMRP	,;	//-- 01 - Numero Do MRP
											(cAliasT)->DF0_NUMAGE 	,;	//-- 02 - Numero Agendamento
									  StoD((cAliasT)->DF0_DATCAD) 	,;	//-- 03 - Data Cadastramento
											(cAliasT)->DF0_STATUS 	,;	//-- 04 - Descritivo Do Status
											(cAliasT)->DF1_DOC 		,;	//-- 05 - Documento Sol. Coleta
											(cAliasT)->DF1_SERIE 	,;	//-- 06 - Série Documento Sol. Coleta
											(cAliasT)->RECDDD 		,;	//-- 07 - Recno Tabela DDD
											(cAliasT)->RECDF0 		,;	//-- 08 - Recno Tabela DF0
											(cAliasT)->RECDF1 		})	//-- 09 - Recno Tabela DF1
				
					DbSelectArea(cAliasT)
					(cAliasT)->(DbSkip())
				EndDo
				
				//-- Copia Vetor Temporario Para Vetor Da Dialog
				For nJ := 1 To Len(aDadTmp)
				
					//-- Inclui Linha No Vetor aDadAge (Vetor Unidimensional Vazio).
					aAdd( aDadAge , Array( Len(aDadTmp[nJ])))
					
					//-- Inclui Dados Do Vetor Origem Na Linha Criada No Vetor Destino.
					aCopy( aDadTmp[nJ] , aDadAge[Len(aDadAge)] , Nil , Nil , Nil /*Len(aDadAge)*/ )				
				
				Next nJ

				//-- Fecha Arquivo Temporário
				If Select(cAliasT) > 0
					(cAliasT)->(DbCloseArea())
				EndIf	
			EndIf
		EndIf
	Next nI
	
	//-- Verifica Se Houve Itens Marcados Para Visualização
	If nCount > 0 .And. Len(aDadAge) > 0

		//-- Abre Tela Informando Os Agendamentos / Solic. Coleta Gerados
		aAdd(aButtons	,{ STR0033 ,{|| Tmsa019VAg( 'A' , aDadAge , oListTmp:nAT ) 	}, STR0033	, STR0033 })	//-- "Vis. Agendamento" 
		aAdd(aButtons	,{ STR0034 ,{|| Tmsa019VAg( 'S' , aDadAge , oListTmp:nAT ) 	}, STR0034	, STR0034 })	//-- "Vis. Sol. Coleta"				
				
		//--		Num.MRP,	"Agendamento" , "Data"  , "Status" , "Doc.Coleta" , "Série" , "Rec. DDD" , "Rec. DF0" , "Rec. DF1"
		aCab := { STR0045,	STR0035       , STR0036 , STR0037  , STR0038      , STR0039 , "Rec. DDD" , "Rec. DF0" , "Rec. DF1" }

		oDlgTmp 			:= TDialog():New(000,000,aCoord[6]/1.5,aCoord[5]/1.5,OemToAnsi( STR0040 ),,,,,,,,oMainWnd,.T.) //-- "Resumo Do Processamento"
		oListTmp 			:= TWBrowse():New(030,003,oDlgTmp:nClientWidth/2-5,oDlgTmp:nClientHeight/2-45,,aCab,,oDlgTmp,,,,,,,,,,, STR0041 ,.F.,,.T.,,.F.,,,) //-- "Duplo Clique No Número Do Agendamento Visualiza Agendamento; Duplo Clique No Documento Ou Série Visualiza Solicitação De Coleta."
		oListTmp:lHScroll	:= .F.

		oListTmp:bLDblClick  := { || Tmsa019VAg( '' , aDadAge , oListTmp:nAT , oListTmp:nColPos ) }
				
		oListTmp:SetArray(aDadAge)

		oListTmp:bLine := {||{;
			aDadAge[oListTmp:nAt][01],;
			aDadAge[oListTmp:nAt][02],;
			aDadAge[oListTmp:nAt][03],;
			aDadAge[oListTmp:nAt][04],;
			aDadAge[oListTmp:nAt][05],;
			aDadAge[oListTmp:nAt][06],;
			aDadAge[oListTmp:nAt][07],;					
			aDadAge[oListTmp:nAt][08],;
			aDadAge[oListTmp:nAt][09]}}

		EnchoiceBar(oDlgTmp,{|| lOpcClick := .t., oDlgTmp:End()},{|| oDlgTmp:End() },/*lMsgDel*/,aButtons,/*nRecno*/,/*cAlias*/,/*lMashups*/,/*lImpCad*/,/*lPadrao*/,/*lHasOk*/ .F.,/*lWalkThru*/,/*cProfileID*/)

		oDlgTmp:Activate(,,,.T.)				
	
	Else
		Help("",1,"TMSA01903",/*Titulo*/, STR0042 /*Mensagem*/,1,0) //-- "Marque Somente Registros Processados Para Visualização Dos Agendamentos e/ou Solicitações De Coleta Gerados!"
	EndIf
  
	//-- Força Posicionamento De Linha Pois o RECNO da Grid Está Zerado
	oModelGrid:GoLine( nLinOld )

	//-- Dá Refresh na View De Grid Para Atualizar Dados Na Tela
	oView:Refresh('VwGridTRB')

	//-- Reposiciona na Linha Original Da Grid
	//FWRestRows( aSaveLines )
	
	RestArea(aArea)

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} Tmsa019VAg
Tela Para Visualização Dos Agendamentos e/ou Solicitação De Coletas
@author Eduardo Alberti
@since  Dec/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function Tmsa019VAg( cTipo , aDadAge , nLin , nCol )

	Local aArea := GetArea()
	Local aArDF0:= DF0->(GetArea())
	Local aArDT5:= DT5->(GetArea())
	
	If Empty(cTipo) .And. nCol == 2
		cTipo := "A"
	ElseIf Empty(cTipo) .And. ( nCol == 5 .Or. nCol == 6 ) 
		cTipo := "S"
	ElseIf Empty(cTipo)
		cTipo := "A"
	EndIf				 

	//-- Preserva Objetos De Tela Já Aberta
	SaveInter()

	//-- Visualização Do Agendamento
	If cTipo == "A"
	
		DbSelectArea("DF0")
		DF0->( DbSetOrder(1) ) //-- DF0_FILIAL+DF0_NUMAGE
		If DF0->( MsSeek(xFilial("DF0") + aDadAge[ nLin , 02 ] ) )
			Inclui := .F.
			Altera	:= .F.
			TMSF05Mnt("DF0",DF0->(Recno()),2)
		EndIf
		
	ElseIf cTipo == "S"

		//-- Visualização Da Solicitação De Coleta
		DbSelectArea("DT5")
		DT5->( DbSetOrder( 4 ) ) //-- DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
		If	DT5->( MsSeek( xFilial('DT5') + FWCodFil() + aDadAge[ nLin , 05 ] + aDadAge[ nLin , 06 ] , .F. ) )
			Inclui := .F.
			TmsA460Mnt( 'DT5', DT5->( Recno() ), 2 )
		EndIf	
	EndIf	

	//-- Retorna Objetos Da Tela Anterior
	RestInter()

	RestArea(aArDT5)
	RestArea(aArDF0)
	RestArea(aArea)

Return(.t.)
//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA019Prc
Tela Do Processamento On-Line EDI Para Visualização Do Detalhamento De Geração De Agendamentos e/ou Solicitação De Coletas Gerados 
Acionada pela Rotina TMSME10
@author Eduardo Alberti
@since  Dec/2015
@version P12
/*/
//-------------------------------------------------------------------
Function TMSA019Prc( aMrp , nTipo )

	Local aArea		:= GetArea()
	Local nI			:= 0
	Local nJ			:= 0
	Local aDadTmp		:= {}
	Local aDadAge		:= {}

	Local cQuery		:= ""
	Local nTotReg		:= 0
	Local cAliasT		:= GetNextAlias()
	Local bQuery		:= {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
	
	Local aButtons	:= {}
	Local oDlgTmp
	Local oListTmp
	Local oTit1
	Local aCoord		:= MsAdvSize(.T.)
	Local lOpcClick	:= .f.
	Local aCab			:= {}
	Local nCount		:= 0
	
	Default nTipo		:= 1
	
 	//-- Executa Loop Em Todo Vetor
	For nI := 1 To Len(aMRP)

		cQuery := ""
		cQuery += " SELECT      DF0.DF0_NUMMRP, " 
		cQuery += "             DF0.DF0_NUMAGE, "       							//-- Numero Agendamento
		cQuery += "             DF0.DF0_DATCAD, "
		cQuery += "             CASE DF0.DF0_STATUS "
		cQuery += "             WHEN '1' THEN '1-' || '" + STR0027 + "' " 		//-- "A Confirmar"
		cQuery += "             WHEN '2' THEN '2-' || '" + STR0028 + "' " 		//-- "Confirmado"
		cQuery += "             WHEN '3' THEN '3-' || '" + STR0029 + "' " 		//-- "Em Processo"
		cQuery += "             WHEN '4' THEN '4-' || '" + STR0030 + "' " 		//-- "Encerrado"
		cQuery += "             WHEN '5' THEN '5-' || '" + STR0031 + "' " 		//-- "Planejado"
		cQuery += "             WHEN '9' THEN '9-' || '" + STR0032 + "' " 		//-- "Cancelado"
		cQuery += "             END  AS DF0_STATUS, "
		cQuery += "             DF1.DF1_DOC, "        							//-- Número Solic. Coleta
		cQuery += "             DF1.DF1_SERIE, "      							//-- Série Solic. Coleta
		cQuery += "             DF0.R_E_C_N_O_ AS RECDF0, "
		cQuery += "             DF1.R_E_C_N_O_ AS RECDF1  "
		cQuery += " FROM        " +	RetSqlName("DF0") + " DF0 "        		//-- Cabec. Agendamento
		cQuery += " INNER JOIN  " +	RetSqlName("DF1") + " DF1 "          		//-- Itens Agendamento
		cQuery += " ON          DF1.DF1_FILIAL =  '" + xFilial("DF0") + "' "
		cQuery += " AND         DF1.DF1_NUMAGE =  DF0.DF0_NUMAGE "
		cQuery += " AND         DF1.D_E_L_E_T_ =  ' ' "

		//-- Quando nTipo = 2 Passa Parametros Adicionais De Filtro
		If nTipo == 2
		
			DbSelectArea("DDD")
			DDD->(DbGoTo(aMRP[nI,2]))

			cQuery += " INNER JOIN  " +	RetSqlName("DDD") + " DDD "        		//-- Cabecalho MRP
			cQuery += " ON          DDD.DDD_FILIAL =  '" + xFilial("DDD")        + "' "
			cQuery += " AND         DDD.DDD_DATAGE =  '" + DtoS(DDD->DDD_DATAGE) + "' "
			cQuery += " AND         DDD.DDD_HORAGE =  '" +      DDD->DDD_HORAGE  + "' "
			cQuery += " AND         DDD.DDD_CLIDES =  '" +      DDD->DDD_CLIDES  + "' "
			cQuery += " AND         DDD.DDD_LOJDES =  '" +      DDD->DDD_LOJDES  + "' "
			cQuery += " AND         DDD.DDD_SQEDES =  '" +      DDD->DDD_SQEDES  + "' "
			cQuery += " AND         DDD.DDD_CLIREM =  '" +      DDD->DDD_CLIREM  + "' "
			cQuery += " AND         DDD.DDD_LOJREM =  '" +      DDD->DDD_LOJREM  + "' "
			cQuery += " AND         DDD.DDD_SQEREM =  '" +      DDD->DDD_SQEREM  + "' "
			cQuery += " AND         DDD.DDD_NUMMRP = DF0.DF0_NUMMRP "
			cQuery += " AND         DDD.D_E_L_E_T_ =  ' ' "
					
		EndIf

		cQuery += " WHERE       DF0.DF0_FILIAL =  '" + xFilial("DF0") + "' "
		cQuery += " AND         DF0.DF0_NUMMRP =  '" + PadR(aMRP[nI,1], TamSX3("DF0_NUMMRP")[1]) + "' "
		cQuery += " AND         DF0.D_E_L_E_T_ =  ' ' "

		cQuery := ChangeQuery(cQuery)
			
		//-- Executa Query
		Eval(bQuery)
				
		//-- Limpa Vetor Temporário
		aDadTmp := {}

		DbSelectArea(cAliasT)
		While (cAliasT)->(!Eof())
				
			aAdd( aDadTmp , {		(cAliasT)->DF0_NUMMRP 		,;	//-- 01 - Número MRP
									(cAliasT)->DF0_NUMAGE 		,;	//-- 02 - Numero Agendamento
									StoD((cAliasT)->DF0_DATCAD)	,;	//-- 03 - Data Cadastramento
									(cAliasT)->DF0_STATUS 		,;	//-- 04 - Descritivo Do Status
									(cAliasT)->DF1_DOC 			,;	//-- 05 - Documento Sol. Coleta
									(cAliasT)->DF1_SERIE 		,;	//-- 06 - Série Documento Sol. Coleta
									(cAliasT)->RECDF0 			,;	//-- 07 - Recno Tabela DF0
									(cAliasT)->RECDF1 			})	//-- 08 - Recno Tabela DF1
				
			DbSelectArea(cAliasT)
			(cAliasT)->(DbSkip())
		EndDo
				
		//-- Copia Vetor Temporario Para Vetor Da Dialog
		For nJ := 1 To Len(aDadTmp)
				
			If Ascan( aDadAge , { |x| x[1] + x[2] + DtoS(x[3]) + x[4] + x[5] + x[6]  == ( aDadTmp[nJ,01] + aDadTmp[nJ,02] + DtoS(aDadTmp[nJ,03]) + aDadTmp[nJ,04] + aDadTmp[nJ,05] + aDadTmp[nJ,06] ) }) == 0

				//-- Inclui Linha No Vetor aDadAge (Vetor Unidimensional Vazio).
				aAdd( aDadAge , Array( Len(aDadTmp[nJ])))
						
				//-- Inclui Dados Do Vetor Origem Na Linha Criada No Vetor Destino.
				aCopy( aDadTmp[nJ] , aDadAge[Len(aDadAge)] , Nil , Nil , Nil /*Len(aDadAge)*/ )

			EndIf				
		Next nJ

		//-- Fecha Arquivo Temporário
		If Select(cAliasT) > 0
			(cAliasT)->(DbCloseArea())
		EndIf
	Next nI
	
	//-- Verifica Se Houve Itens Marcados Para Visualização
	If Len(aDadAge) > 0

		//-- Abre Tela Informando Os Agendamentos / Solic. Coleta Gerados
		aAdd(aButtons	,{ STR0033 ,{|| Tmsa019VAg( 'A' , aDadAge , oListTmp:nAT ) 	}, STR0033	, STR0033 })	//-- "Vis. Agendamento"
		aAdd(aButtons	,{ STR0034 ,{|| Tmsa019VAg( 'S' , aDadAge , oListTmp:nAT ) 	}, STR0034	, STR0034 })	//-- "Vis. Sol. Coleta"
				
		//--      "Número MRP","Agendamento" , "Data"  , "Status" , "Doc.Coleta" , "Série" , "Rec. DDD" , "Rec. DF0" , "Rec. DF1"
		aCab := { STR0045     , STR0035      , STR0036 , STR0037  , STR0038      , STR0039 , "Rec. DF0" , "Rec. DF1" }

		oDlgTmp 			:= TDialog():New(000,000,aCoord[6]/1.5,aCoord[5]/1.5,OemToAnsi( Iif( nTipo == 1 ,STR0040,STR0044) ),,,,,,,,oMainWnd,.T.) //-- "Resumo Do Processamento" Ou "Relação De Registros Não Processados"
		
		@ 030, 003 Say oTit1 Var Iif( nTipo == 1 ,STR0040,STR0044 ) Size 140, 010 Pixel Of oDlgTmp
		
		oListTmp 			:= TWBrowse():New(040,003,oDlgTmp:nClientWidth/2-5,oDlgTmp:nClientHeight/2-45,,aCab,,oDlgTmp,,,,,,,,,,, STR0041 ,.F.,,.T.,,.F.,,,) //-- "Duplo Clique No Número Do Agendamento Visualiza Agendamento; Duplo Clique No Documento Ou Série Visualiza Solicitação De Coleta."
		oListTmp:lHScroll	:= .F.

		oListTmp:bLDblClick  := { || Tmsa019VAg( '' , aDadAge , oListTmp:nAT , oListTmp:nColPos ) }
				
		oListTmp:SetArray(aDadAge)

		oListTmp:bLine := {||{;
			aDadAge[oListTmp:nAt][01],;
			aDadAge[oListTmp:nAt][02],;
			aDadAge[oListTmp:nAt][03],;
			aDadAge[oListTmp:nAt][04],;
			aDadAge[oListTmp:nAt][05],;
			aDadAge[oListTmp:nAt][06],;
			aDadAge[oListTmp:nAt][07],;
			aDadAge[oListTmp:nAt][08]}}

		EnchoiceBar(oDlgTmp,{|| lOpcClick := .t., oDlgTmp:End()},{|| oDlgTmp:End() },,aButtons)

		oDlgTmp:Activate(,,,.T.)
	
	EndIf
					
	RestArea(aArea)

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA019Vld
Validação Dos Campos Editáveis 
@author Eduardo Alberti
@since  Jun/2016
@version P12
/*/
//-------------------------------------------------------------------
Function TMSA019Vld()

	Local lRet       := .t.
	Local aAreas     := {DC5->(GetArea()),GetArea()}
	Local cCampo     := Upper(Alltrim(ReadVar()))
	Local aItContrat := {}

	If cCampo == 'M->DDD_SERVIC'

		If !Empty(M->DDD_SERVIC)

			//-- Valida o codigo do servico digitado.
			DbSelectArea("DC5")
			DC5->( DbSetOrder( 1 ) )
			If DC5->( ! MsSeek( xFilial('DC5') + M->DDD_SERVIC, .F. ) )
				Help(' ', 1, 'TMSA04013', , M->DDD_SERVIC , 4, 1 )	//-- Codigo do servico nao encontrado (DC5).  //'Servico: '
				lRet := .F.
			ElseIf DC5->DC5_DOCTMS == '7' .Or. DC5->DC5_DOCTMS == '8' //Não permite a digitação dos serviços com complemento tipo "7=CTRC Reentrega" e "8=CTRC Complemento".
				Help("",1,"TMSA05040") // Servico Invalido ...
				lRet := .F.
			EndIf
	
			If lRet

				TMSPesqServ(	'DF1',;
								M->DDD_CLIDEV,;
								M->DDD_LOJDEV,;
								StrZero(1,Len(DC5->DC5_SERTMS)),;
								M->DDD_TIPTRA,;
								@aItContrat,;
								.F.,;
								M->DDD_TIPFRE,,,,,,,,;
								M->DDD_CDRORI,;
								M->DDD_CDRDES,,,,,,,,;
								M->DDD_CODNEG )
	
				nSeek := Ascan(aItContrat, { |x| x[3] == &(ReadVar()) })

				If nSeek == 0
					Help('',1,"TMSA05040") // Servico Invalido ...
					lRet := .f.
				EndIf
			EndIf
		EndIf
	EndIf

	aEval(aAreas,{|x,y| RestArea(x) })

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA019Whe
Verifica Se Habilita Campos Para Edição 
@author Eduardo Alberti
@since  Jun/2016
@version P12
/*/
//-------------------------------------------------------------------
Function TMSA019Whe()

	Local lRet   := .t.
	Local cCampo := Upper(Alltrim(ReadVar()))
	Local oModel
	Local oView

	If cCampo $ "M->DDD_SERVIC|M->DDD_CODNEG|M->DDD_NCONTR|M->DDD_SRVCOL"

		If cCampo $ "M->DDD_SERVIC" .And. Type("M->DDD_CODNEG") <> "U" .And. Empty(M->DDD_CODNEG)
			lRet := .f.
		ElseIf cCampo $ "M->DDD_NCONTR"

			If IsInCallStack("TMSA019") .Or. IsInCallStack("TMSA019A")

				oModel := FWModelActive() //-- Captura Model Ativa
				oView  := FWViewActive()  //-- Captura View Ativa

				If oModel:cSource == "TMSA019A"
					If !Empty(oModel:GetValue( 'TMSA019A_CAB' , 'DDD_NCONTR' ))
						lRet := .f.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
Return(lRet)
	
