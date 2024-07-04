#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TMSA250A.CH"

#DEFINE TYPE_MODEL	1
#DEFINE TYPE_VIEW  	2

Static aDocsNPrev    := {}
Static cViagemIni	 := ''
Static cViagemFim	 := ''
Static cFilialOri	 := ''
Static nOpcx 		 := 3
Static cAliasQry	 := ''
Static cAliasT		 := GetNextAlias()
Static lTM250APos    := ExistBlock("Tms250APos")

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  Geração de Contratos de Carreteiro dos Documentos não previstos na viagem
@author Leandro Paulino
@version Versao P12
@since 02/Mai/2017
@return Nil
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Function TMSA250A(nOpcx, cViagemDe , cViagemAte, cFilOri , cQryCTCCom, aDocs)
Local aArea    := GetArea()
Local aButtons := {}
Local lRet     := .T.

Default nOpcx 		:= 3
Default cViagemDe 	:= ''
Default cViagemAte	:= ''
Default cFilOri 	:= ''
Default cQryCTCCom	:= ''
Default	aDocs		:= {}

aDocsNPrev := {}
nOpc 	   := nOpcx
cViagemIni := cViagemDe
cViagemFim := cViagemAte
cFilialOri := cFilOri
cAliasQry  := cQryCTCCom


	//-- Desabilita Botões Padrão Deixando Apenas o Botão Cancelar
	aButtons := {{.F.,Nil},;		//-- 01 - Copiar
				 {.F.,Nil},;		//-- 02 - Recortar
				 {.F.,Nil},;		//-- 03 - Colar
				 {.F.,Nil},;		//-- 04 - Calculadora
				 {.F.,Nil},;		//-- 05 - Spool
				 {.F.,Nil},;		//-- 06 - Imprimir
				 {.T.,'Confirmar'},;//-- 07 - Confirmar
				 {.T.,'Cancelar'},;	//-- 08 - Cancelar ( Fechar	)
				 {.F.,Nil},;		//-- 09 - WalkTrhough
				 {.F.,Nil},;		//-- 10 - Ambiente
				 {.F.,Nil},;		//-- 11 - Mashup
				 {.F.,Nil},;		//-- 12 - Help
				 {.F.,Nil},;		//-- 13 - Formulário HTML
				 {.F.,Nil}}			//-- 14 - ECM
    A250ABusDC()
	If (cAliasT)->(!EOF())
		//-- Executa a View (Nesta Rotina Não Existe o Browse Inicial Padrão MVC )
		lRet := FWExecView( STR0001 ,'TMSA250A',MODEL_OPERATION_UPDATE,, { || .T. },{ || .T. },20,aButtons ,{ || .T. }) == 0//-- "'Documentos Não Previstos' "
	EndIf

	aDocs:= aClone(aDocsNPrev)
	aDocsNPrev:= {}

RestArea(aArea)
Return lRet


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@author Leandro Paulino
@version Versao P12
@since 02/Mai/2017
@return Nil
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oView   	:= NIL		//-- Recebe o objeto da View
Local oModel  	:= NIL		//-- Objeto do Model
Local oStruCab 	:= NIL   	//-- Recebe a Estrutura cabecalho
Local oStruGrd 	:= NIL  	//-- Recebe a Estrutura
Local oStruTot	:= NIL   	//-- Recebe a Estrutura da tabela DDW

	//-- Cria Primeira Estrutura (Field) Na Parte Superior Da Tela
	oStruCab	:= FWFormModelStruct():New()
	oStruCab:AddField(	    STR0002			, ; //-- Titulo do campo  //-- "Marca Desmarca Todos"
							STR0002			, ; //-- ToolTip do campo //-- "Marca Desmarca Todos"
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

	//-- Cria campo para simular interação do usuário após a abertura da tela, assim não será apresentada a mensagem que o modelo não foi alterado.
	oStruCab:AddField(	    ''				, ; //-- Titulo do campo  //-- "Marca Desmarca Todos"
							''				, ; //-- ToolTip do campo //-- "Marca Desmarca Todos"
							'TELA' 			, ; //-- Nome do Campo
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
	oStruGrd	:= A250AStrGd(TYPE_MODEL)

	oModel := MPFormModel():New( "TMSA250A",, { |oModel| PosVldMdl( oModel ) } ,, /*bCancel*/ )

	//-- Adiciona Objetos Criados à Model
	oModel:AddFields('MdFieldCab',,oStruCab,,,{||})

	oModel:AddGrid('MdGridTRB','MdFieldCab', oStruGrd,  /* bLinePre */, /* nLinePost */ ,/*bPre*/, /*bPos*/,{|oMdl| a250ALdGrd(oMdl) } /*BLoad*/ )

	//-- Seta Descrição Para Cada Divisão Da Model
	oModel:GetModel('MdFieldCab' ):SetDescription(STR0004) 	//--"Documentos não previstos."
	oModel:GetModel('MdGridTRB'):SetDescription(STR0005) //--'Itens'
	oModel:SetDescription(STR0006) 							//--"Itens não previstos."

	//-- Adiciona Restrições Aos Objetos Da Model
	oModel:GetModel( 'MdGridTRB' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MdGridTRB' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MdGridTRB' ):SetOptional( .T. )

	oModel:GetModel('MdFieldCab'):SetOnlyQuery( .T. )
	oModel:GetModel('MdGridTRB'):SetOnlyQuery( .T. )

	//-- Seta Chave Primária Da Model
	oModel:SetPrimaryKey({"MRK_ALL"})

	//-- Ativação Da Model
	oModel:SetActivate( )


	//-- Ativação Da Model Com Execução De Rotina Posterior a Montagem Da Model
	oModel:SetActivate( { |oModel| ActiveMdl( oModel ) } )

Return(oModel)

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@author Leandro Paulibo
@version Versao P12
@since 03/Mai/2017
@return Nil
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oView   	:= NIL		// Recebe o objeto da View
	Local oModel  	:= NIL		// Objeto do Model
	Local oStruCab 	:= NIL   	// Recebe a Estrutura cabecalho
	Local oStruGrd 	:= NIL  	// Recebe a Estrutura
	Local oStruTot	:= NIL   	// Recebe a Estrutura da tabela DDW

	oModel		:= FwLoadModel( "TMSA250A" )

	//-- Cria Primeira Estrutura (Field) Na Parte Superior Da Tela
	//-- Adiciona o campo de marcação(CheckBox)
	oStruCab:= FWFormViewStruct():New()
	oStruCab:AddField(	'MRK_ALL'	, ; // Nome do Campo
							'01'   	, ; // Ordem
							STR0007	, ; // Titulo do campo  				//-- 'Marca/Desmarca Todos'
							STR0008, ; // Descrição do campo				//-- "Marcar Desmarcar Todos Doc."
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
	oStruGrd	:= A250AStrGd(TYPE_VIEW)

    //-- Cria o objeto de View
	oView := FwFormView():New()

	//-- Define qual o Modelo de dados será utilizado na View
	oView:SetModel(oModel)

	//-- Alteração de propriedades do campo
	oStruGrd:SetProperty( '*' 			, MVC_VIEW_CANCHANGE,.F.) //-- Bloqueia Todos Os Campos Da Grid
	oStruGrd:SetProperty( 'TRB_MARK' 	, MVC_VIEW_CANCHANGE,.T.) //-- Habilita Somente o Campo Mark Da Grid

	oView:AddUserButton( STR0009		, 'CLIPS', {|oView| TMA250AVis(oView)} )		//-- "Visualizar"

	//-- Adiciona Os Objetos Criados à View
	oView:AddField('VwFieldCab', oStruCab , 'MdFieldCab')
	oView:AddGrid ('VwGridTRB' , oStruGrd , 'MdGridTRB')

	//-- Dimensiona a Tela Da View
	oView:CreateHorizontalBox('CABECALHO' ,25)
	oView:CreateHorizontalBox('GRID'	  ,75)

    oView:EnableTitleView( 'VwFieldCab',"Selecione os documentos não previstos que deverão participar da geração do contrato de carreteiro." ) //--"Selecione os documentos não previstos que deverão participar da geração do contrato de carreteiro"

    //-- Seta Os Objetos para Cada Dimensão Criada
    oView:SetOwnerView('VwFieldCab','CABECALHO')
    oView:SetOwnerView('VwGridTRB' ,'GRID'     )

    oView:EnableTitleView( 'VwGridTRB',STR0001  ) //--Documentos não previstos"

	oView:ShowInsertMsg(.F.)
    oView:ShowUpdatetMsg(.F.)

	//-- Define Acao a Ser Executada Quando a Field é Marcada No Cabeçalho (Apos a Validacao Do Campo).
	oView:SetFieldAction( 'MRK_ALL'		, { |oView, cIDView, cField, xValue| TmA250AMrk( oView, cIDView, cField, xValue ) } )

	//-- Não Permite Abertura Da Tela De "Salvar Dados Do Formulário"
	oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

Return(oView)

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A250AStrGd
@author Leandro Paulino
@version Versao P12
@since 03/mai/2017
@return Nil
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Static Function A250AStrGd(nType)

	Local oStruct   := Nil
	Local nX        := 0
	Local aDadosCpo := {}
	Local aCampos   := {}

	Default nType   := TYPE_MODEL        //  1=Tipo Model / 2= Tipo View

	//-- Carrega Vetor De Campos Da Grid (Conforme Query Principal)
	aAdd(aCampos,"DUD_FILDOC"   )
	aAdd(aCampos,"DUD_DOC"      )
	aAdd(aCampos,"DUD_SERIE"    )
    aAdd(aCampos,"DUD_FILORI"   )
    aAdd(aCampos,"DUD_VIAGEM"   )
    aAdd(aCampos,"RECNO"        )

	//-- Ponto De Entrada Para Alteração Da Posição Dos Campos Na Grid
	If lTM250APos
		aCampos :=	ExecBlock("Tms250APos",.f.,.f.,{ aCampos , nType })
	EndIf

	If nType == TYPE_MODEL

		//-- Executa o Método Construtor Da Classe.
		oStruct := FWFormModelStruct():New()

		//-- Check Box De Marcação Da Linha Da Grid
		oStruct:AddField(	'' ,;													//-- [01] C Titulo do campo
							'' ,; 													//-- [02] C ToolTip do campo
							'TRB_MARK' ,;											//-- [03] C identificador (ID) do Field
							'L' ,; 												    //-- [04] C Tipo do campo
							1 ,; 													//-- [05] N Tamanho do campo
							0 ,;													//-- [06] N Decimal do campo
							Nil ,;					 								//-- [07] B Code-block de validação do campo      //-- {|| T146MrkDoc() }
							Nil ,;													//-- [08] B Code-block de validação When do campo //-- {|| TMA146VDoc(FwFldGet('T01_SERTMS'),'D') }
							NIL ,; 												    //-- [09] A Lista de valores permitido do campo
							NIL ,; 												    //-- [10] L Indica se o campo tem preenchimento obrigatório
							NIL ,; 												    //-- [11] B Code-block de inicializacao do campo
							NIL ,; 											    	//-- [12] L Indica se trata de um campo chave
							NIL ,; 										    		//-- [13] L Indica se o campo pode receber valor em uma operação de update.
							.T.  ) 									    			//-- [14] L Indica se o campo é virtual

        //-- Check Box De Marcação Da Linha Da Grid
        oStruct:AddField(	'' ,;													//-- [01] C Titulo do campo
							'' ,; 													//-- [02] C ToolTip do campo
							'RECNO' ,;  											//-- [03] C identificador (ID) do Field
							'N' ,; 		    										//-- [04] C Tipo do campo
							1 ,; 													//-- [05] N Tamanho do campo
							0 ,;													//-- [06] N Decimal do campo
							Nil ,;					 								//-- [07] B Code-block de validação do campo      //-- {|| T146MrkDoc() }
							Nil ,;													//-- [08] B Code-block de validação When do campo //-- {|| TMA146VDoc(FwFldGet('T01_SERTMS'),'D') }
							NIL ,; 			    									//-- [09] A Lista de valores permitido do campo
							NIL ,; 				    								//-- [10] L Indica se o campo tem preenchimento obrigatório
							NIL ,; 					    							//-- [11] B Code-block de inicializacao do campo
							NIL ,; 						    						//-- [12] L Indica se trata de um campo chave
							NIL ,; 							    					//-- [13] L Indica se o campo pode receber valor em uma operação de update.
							.T.  ) 								    				//-- [14] L Indica se o campo é virtual

		//-- Inclui Campos Constantes Na Query Principal ( Somente Campos Existentes No Dicionário ).
		For nX := 1 To Len(aCampos)

			If SubStr(aCampos[nX],1,5) <> 'RECNO'

				aDadosCpo:= TMSX3Cpo( aCampos[nX] )
				If Empty(aDadosCpo) .Or. Len(aDadosCpo) < 6
					TmsLogMsg("WARN", FunName() + STR0003 + aCampos[nX] ) //"Erro No Campo: "
				Else
					oStruct:AddField(aDadosCpo[1],aDadosCpo[2],aCampos[nX],aDadosCpo[6],aDadosCpo[3],aDadosCpo[4])
				EndIf

			EndIf

		Next nX
	Else

		oStruct := FWFormViewStruct():New()

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

		For nX := 1 To Len(aCampos)
			If SubStr(aCampos[nX],1,3) <> 'REC'

				aDadosCpo:= TMSX3Cpo( aCampos[nX] )
				If Empty(aDadosCpo) .Or. Len(aDadosCpo) < 4
					TmsLogMsg("WARN", FunName() + STR0003 + aCampos[nX] ) //--" Erro No Campo: "
				Else
					oStruct:AddField(aCampos[nX],StrZero((nX + 2 ),2),aDadosCpo[1],aDadosCpo[2],{""},aDadosCpo[6],aDadosCpo[5],Nil,Nil,.F.,Nil)
				EndIf
			EndIf
		Next nX
	EndIf

Return(oStruct)

//-------------------------------------------------------------------
/*/{Protheus.doc}   a250ABusDC
Função Para Execução da Query Que Será Enviada Para o Grid Da Tela Por
Meio da Função FWLoadByAlias
@author Leandro Paulino
@since  03/Mai/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function A250ABusDC()
	Local aArea      := GetArea()
	Local aAreaDTQ	 := GetArea('DTQ')
	Local aAreaDUD	 := GetArea('DUD')
	Local bQuery     := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.)}
    Local cQuery     := ""
	Local aCampos    := {}
	Local cTabTemp   := ""
	Local oTempTable := NIL
	Local cAliasTab  := ""

	If nOpc == 4
		AAdd(aCampos, { "FILORI"    , "C",  TamSX3("DTQ_FILORI")[1] , 0 })
		AAdd(aCampos, { "VIAGEM"    , "C",  TamSX3("DTQ_VIAGEM")[1] , 0 })
		cAliasTab := GetNextAlias()

		oTempTable := FWTemporaryTable():New(cAliasTab)
		oTempTable:SetFields( aCampos )
		oTempTable:AddIndex("01", {"FILORI","VIAGEM"} )
		oTempTable:Create()

		cTabTemp:= oTempTable:GetRealName()

		(cAliasQry)->(DbGoTop())
		While (cAliasQry)->(!Eof())
			//Monta clausula IN para trazer as viagens que fazem parte do contrato complementar
			DTQ->(dbGoTo((cAliasQry)->(DTQREC)))

			RecLock(cAliasTab,.T.)
			(cAliasTab)->FILORI := cFilialOri
			(cAliasTab)->VIAGEM := DTQ->DTQ_VIAGEM
			(cAliasTab)->(MsUnlock())

			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(DbGoTop())

	EndIf

	//-- Recarrega Variaveis Antes Da Execução
	//Pergunte( cPerg , .f. )
	cQuery := " SELECT      DUD.DUD_FILDOC, DUD.DUD_DOC, DUD.DUD_SERIE, DUD.DUD_FILORI, DUD.DUD_VIAGEM, DUD.R_E_C_N_O_ RECNO "

	cQuery += " FROM        " + RetSqlName("DUD") +  " DUD"                   //--Documentos

	//-- Faz Inner Join Com Tabela Temporária
	If nOpc == 4
		cQuery += " INNER JOIN " + cTabTemp + " cTbTmp "
		cQuery += " ON cTbTmp.FILORI = DUD.DUD_FILORI "
		cQuery += " AND cTbTmp.VIAGEM = DUD.DUD_VIAGEM "
	EndIf

	cQuery += " WHERE       DUD.DUD_FILIAL  =   '" + FwxFilial("DUD")   + "' "
	If nOpc == 3 //--Contrato por viagem
		cQuery += " AND         DUD.DUD_FILORI  =   '" + cFilialOri         + "' "
		cQuery += " AND         DUD.DUD_VIAGEM  >=  '" + cViagemIni         + "' "
		cQuery += " AND         DUD.DUD_VIAGEM  <=  '" + cViagemFim         + "' "
		cQuery += " AND         DUD.DUD_VIAGEM  <> ' ' "
	EndIf
	cQuery += " AND         DUD.DUD_DTRNPR  <> ' '"
	cQuery += " AND         DUD.D_E_L_E_T_  =  ' '"

	cQuery := ChangeQuery(cQuery)

	Eval(bQuery)

	If nOpc == 4
		oTempTable:Delete()
	EndIf

	RestArea(aAreaDTQ)
	RestArea(aAreaDUD)
	RestArea(aArea)

Return cAliasT

//-------------------------------------------------------------------
/*/{Protheus.doc}   a250bLdGrd
Função Para Execução da Query Que Será Enviada Para o Grid Da Tela Por
Meio da Função FWLoadByAlias
@author Leandro Paulino
@since  03/Mai/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function a250aLdGrd( oMdl )

Default oMdl := FwLoadModel('TMSA250A')

	// Como tem o campo R_E_C_N_O_, nao é preciso informar qual o campo contem o Recno() real
	aRet := FWLoadByAlias( oMdl , cAliasT , 'DUD' , Nil , Nil , .t. )

	//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TmA250AMrk
Atualiza os marks das linhas.
@author Leandro Paulino
@since  Maio/2017
@version P12
/*/
//-------------------------------------------------------------------
Function TmA250AMrk( oView, cIDView, cField, xValue )

	Local aArea		    := GetArea()
	Local oModel	 	:= FWModelActive()	//-- Captura Model Ativa
	Local aSaveLines	:= FWSaveRows()		//-- Captura Posicionamento Da Grid
	Local lMarked		:= .F.
	Local oModelGrid	:= oModel:GetModel( 'MdGridTRB' )
	Local nLinOld		:= oModelGrid:nLine

	Local nI 			:= 0

    //-- Define Se a Linha Posicionada Está Marcada Ou Desmarcada
    lMarked := xValue

    //-- Se Estiver Selecionado Para Marcar Todos Do Mesmo Numero MRP
    //-- Executa Loop Em Toda a Grid
    For nI := 1 To oModelGrid:Length()

        //-- Posiciona Na Linha Da Grid Conforme o Cursor
        oModelGrid:GoLine( nI )

        //-- Marca Ou Desmarca Grupo De MRPs
        oModel:SetValue( 'MdGridTRB' , 'TRB_MARK' , Iif(lMarked,.t.,.f.) )

    Next

    //-- Dá Refresh na View De Grid Para Atualizar Dados Na Tela
    oView:Refresh('VwGridTRB')

	//-- Força Posicionamento De Linha Pois o RECNO da Grid Está Zerado
	oModelGrid:GoLine( nLinOld )

	//-- Atualiza Grid Para o Posicionamento Correto
	oView:Refresh('VwGridTRB')

	//-- Reposiciona na Linha Original Da Grid
	FWRestRows( aSaveLines )

	RestArea(aArea)

Return .t.


//-------------------------------------------------------------------
/*/{Protheus.doc} PosVldMdl
PosValid para montar array com retorno dos documentos marcados
@author Leandro Paulino
@since  Maio/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function PosVldMdl(oModel)

    Local oModelGrid    := Nil
    Local nCount        := 0
    Local nTamGrid      := 0

    Default oModel:= FwLoadModel( "TMSA250A" )

    oModelGrid	:= oModel:GetModel( 'MdGridTRB' )
    nTamGrid    := oModelGrid:Length()

    //--Monta array com o RECNO dos Documentos que foram marcados.

    For nCount:= 1 To nTamGrid

        oModelGrid:GoLine(nCount)

        If oModel:GetValue( 'MdGridTRB' , 'TRB_MARK' )
            AADD(aDocsNPrev , oModel:GetValue( 'MdGridTRB' , 'RECNO' ) )
        EndIf

    Next nCount

Return .T.

Static Function TMA250AVis(oView)
Local oModel		:= oView:GetModel()
Local oModelGrid	:= oModel:GetModel( 'MdGridTRB' )
Local aArea			:= GetArea()
Default oView := NIL

DT6->(dbSetOrder(1))
If DT6->(dbSeek(FwxFilial('DT6')+oModelGrid:GetValue('DUD_FILDOC' ) + oModelGrid:GetValue('DUD_DOC' ) + oModelGrid:GetValue('DUD_SERIE' )))
	TmsA500Mnt('DT6', DT6->(Recno()), 2 )
EndIf

RestArea(aArea)

Return Nil


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ActiveMdl
			Função Dummy Para o Sistema Entender Que a Tela Foi Alterada Permitindo Assim a Sua Gravação
@author  	Leandro Paulino
@version 	Versao P12
@since		03/Mai/2017
@return 	Booleano
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ActiveMdl(oModel)

Local lRet       := .T.            // Recebe o Retorno
Local lRptAll    := .T.            // Recebe o valor do campo do Cab

// Inicializa alterações nos objetos
oModel:LoadValue( 'MdFieldCab', 'TELA', lRptAll  )

Return lRet
