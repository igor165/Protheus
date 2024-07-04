#INCLUDE "UBAA020.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


/*{Protheus.doc} UBAA020
//(Vincular fardão a Esteira)
@author marcelo.wesan
@since 29/12/2016
@version undefined
@example
(examples)
@see (links_or_references)
*/

Function UBAA020()
	Local oMBrowse	 		:= Nil
	Local bKeyF12		 	:= SetKey( VK_F12, { || UBAA020INI(.T.) } ) // Facilitador, Pergunte
	Private cUserBenf	 	:= A655GETUNB()// Busca a unidade de beneficiamento
	Private cSafra 	 		:= ""
	Private cProdutor	 	:= ""
	Private cLoja 	 		:= ""
	Private cFazenda 	 	:= ""
	Private cTalhao 	 	:= ""
	Private cVariedade 		:= ""
	Private cProdutoPar		:= ""
	Private lOrdena			:= .F.
	Private lSetOrd 		:= .F.
	
	If .Not. TableInDic('N70') .AND. .Not. TableInDic('N71')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	UBAA020INI(.F.) // Inicializa o pergunte

	oMBrowse := FWMBrowse():New()  // Instancia o Browse
	oMBrowse:SetAlias( "N70" )
	oMBrowse:SetMenuDef( "UBAA020" )
	oMBrowse:SetDescription(STR0001) //"Esteira x Fardão"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
Return( Nil )


Static Function MenuDef()
	Local aRotina := {}
	aAdd( aRotina, { STR0002, 'VIEWDEF.UBAA020A', 0, 2, 0, NIL } )// Visualisar
	aAdd( aRotina, { STR0003, 'VIEWDEF.UBAA020' , 0, 4, 0, NIL } )// Alterar
	aAdd( aRotina, { STR0005, 'VIEWDEF.UBAA020' , 0, 8, 0, NIL } )// Imprimir
Return aRotina


Static Function ModelDef()
	Local oStruN70 	:= FWFormStruct( 1, "N70") // Estrutura Model da N70 - Esteiras
	Local oStruN71 	:= FWFormStruct( 1, "N71") // Estrutura Model para o Field N71 - Esteiras X Fardão
	Local oStruN71GR 	:= FWFormStruct( 1, "N71") // Estrutura Model para Grid N71 - Esteiras X Fardão

	Local oModel 	 := MPFormModel():New("UBAA020", , , {|oModel| GravaDados(oModel)}) // Instancia o Model
	Local bLinePre := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| UBAA020LEG(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}

	oStruN71GR:AddField(STR0009 , "Legenda", 'N71_STSLEG', 'BT' , 1 , 0, , ;
  					   NIL , NIL, NIL, NIL, NIL, .F., .F.) // Adiciona a Estrutura da Grid o Botão de Legenda

  	oStruN71GR:SetProperty( 'N71_STSLEG' , MODEL_FIELD_INIT , {||UBAA020INT('LEG')}) // Seta o inicializador padrão de todas as legendas na grid

	oStruN71:RemoveField('N71_FARDAO')
	oStruN71:RemoveField('N71_PSLIQU')

	// Remove a obrigatoriedade de campos na grid
	oStruN71GR:SetProperty( 'N71_SAFRA' 	, MODEL_FIELD_OBRIGAT , .F.)
	oStruN71GR:SetProperty( 'N71_PRODUT' 	, MODEL_FIELD_OBRIGAT , .F.)
	oStruN71GR:SetProperty( 'N71_LOJA' 		, MODEL_FIELD_OBRIGAT , .F.)
	oStruN71GR:SetProperty( 'N71_FAZEN' 	, MODEL_FIELD_OBRIGAT , .F.)
	oStruN71GR:SetProperty( 'N71_TALHAO'	, MODEL_FIELD_OBRIGAT , .F.)
	oStruN71GR:SetProperty( 'N71_VAR' 		, MODEL_FIELD_OBRIGAT , .F.)

	// Remove a validação dos campos Talhão e Variedades da grid
	oStruN71GR:SetProperty( 'N71_TALHAO' , MODEL_FIELD_VALID , {|| .T.})
	oStruN71GR:SetProperty( 'N71_VAR' , MODEL_FIELD_VALID , {|| .T.})

	// Adição dos botões de Baixo e Cima para ordenação
  	oStruN71GR:AddField('BTN BAIXO', "UP3", 'N71_MOVUP' 	, 'BT' , 1 , 0, {|| UBAA020MOV(1)} , NIL , NIL, NIL, {||"UP3"}, NIL, .F., .T.)
  	oStruN71GR:AddField('BTN CIMA', "DOWN3", 'N71_MOVDW' 	, 'BT' , 1 , 0, {|| UBAA020MOV(2)} , NIL , NIL, NIL, {||"DOWN3"}, NIL, .F., .T.)

	oStruN71GR:AddTrigger('N71_FARDAO', 'N71_STSLEG', , {|| UBAA020INT('LEG')}) // Gatilho no campo fardão para o campo de Legenda
	oStruN71GR:AddTrigger('N71_FARDAO', 'N71_PSLIQU', , {|| UBAA020INT('PSL')}) // Gatilho no campo fardão para o campo de Peso Liquido
	oStruN71GR:AddTrigger('N71_FARDAO', 'N71_TALHAO', , {|| UBAA020INT('TLH')}) // Gatilho no campo fardão para o campo de Talhão
	oStruN71GR:AddTrigger('N71_FARDAO', 'N71_VAR'	, , {|| UBAA020INT('VAR')}) // Gatilho no campo fardão para o campo de Variedade
	oStruN71GR:AddTrigger('N71_FARDAO', 'N71_CODPRO', , {|| UBAA020INT('PRO')}) // Gatilho no campo fardão para o campo de Produto

	oModel:SetDescription(STR0006)//"Esteira"

	//Criação dos submodelos e adição das estruturas
	oModel:AddFields( 'N70UBAA020', /*cOwner*/, oStruN70 )
	oModel:AddFields( 'N71UBAA020', 'N70UBAA020', oStruN71)
	//devido aos debitos tecnico, é necessario adicionar o SetRelation conforme https://jiraproducao.totvs.com.br/browse/DAGROOGD-11879
	oModel:SetRelation( 'N71UBAA020', { { "N71_FILIAL", 'fwxFilial( "N71" )' } , { 'N71_CODEST','N70_CODIGO' }  }, N71->( IndexKey( 1 )))

	oModel:AddGrid( 'N72UBAA020', 'N70UBAA020', oStruN71GR, bLinePre)

	oModel:SetPrimaryKey( { "N70_FILIAL", "N70_CODIGO" } ) // Seta as chaves primárias
	oModel:GetModel( 'N70UBAA020' ):SetDescription(STR0006)//"Esteira"

	oModel:GetModel( 'N71UBAA020' ):SetDescription(STR0001) //"Esteira x Fardão"

	oModel:GetModel( 'N72UBAA020' ):SetUniqueLine( { 'N71_FARDAO' }) // Define o campo que nao pode ser repetido

	oModel:GetModel( 'N72UBAA020' ):SetLoadFilter( , UBAA020DX()) // Carrega o filtro da grid

	oModel:GetModel("N72UBAA020"):SetOptional(.T.)

	oModel:SetRelation('N72UBAA020', { { 'N71_FILIAL', 'fwxFilial( "N71" )' }, { 'N71_CODEST', 'N70_CODIGO' } }, N71->( IndexKey( 3 ) ) )

   	oModel:SetActivate({|oModel|InitFields(oModel)}) // Inicializa os campos conforme o pergunte

Return ( oModel )

Static Function ViewDef()
	Local oStruN70 	:= FWFormStruct(2,"N70") // Estrutura Model da N70 - Esteiras
	Local oStruN71 	:= FWFormStruct(2,"N71") // Estrutura Model para o Field N71 - Esteiras X Fardão
	Local oStruN71GR 	:= FWFormStruct(2,"N71") // Estrutura Model para Grid N71 - Esteiras X Fardão
	Local oModel   	:= ModelDef()
	Local oView    	:= FWFormView():New()

	// Muda os campos para VISUAL

	oStruN70:SetProperty( 'N70_CODIGO' , MVC_VIEW_CANCHANGE , .F.)
	oStruN70:SetProperty( 'N70_DESCRI' , MVC_VIEW_CANCHANGE , .F.)
	oStruN70:SetProperty( 'N70_CODUNB' , MVC_VIEW_CANCHANGE , .F.)

	If !Empty(cUserBenf)
		oStruN70:RemoveField( "N70_CODUNB" )
	Endif

	//Remove campos desnecessários para visualização
	oStruN71:RemoveField("N71_ORDEM")
	oStruN71:RemoveField("N71_FARDAO")
	oStruN71:RemoveField("N71_PSLIQU")
	oStruN71:RemoveField("N71_CODEST")

	oStruN71GR:RemoveField("N71_SAFRA")
	oStruN71GR:RemoveField("N71_PRODUT")
	oStruN71GR:RemoveField("N71_LOJA")
	oStruN71GR:RemoveField("N71_FAZEN")
	oStruN71GR:RemoveField("N71_TALHAO")
	oStruN71GR:RemoveField("N71_VAR")
	oStruN71GR:RemoveField("N71_CODPRO")
	oStruN71GR:RemoveField("N71_DESPRO")
	oStruN71GR:RemoveField("N71_CODEST")


	// Adiciona na View o botão de Legenda
	oStruN71GR:AddField( "N71_STSLEG" ,'01' , "", "Legenda" , {} , 'BT' ,'@BMP', ;//"Status do Fardão"
	 						NIL, NIL, .T., NIL, NIL, NIL,    NIL, NIL, .T. )

	// Adiciona na View os botões de Baixo e Cima para reordenação
	oStruN71GR:AddField( "N71_MOVUP"  ,'02' , "- ", "UP3"  , {} , 'BT' ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL,    NIL, NIL, .T. )
	oStruN71GR:AddField( "N71_MOVDW"  ,'03' , "+ ", "DOWN3"  , {} , 'BT' ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL,    NIL, NIL, .T. )


	oView:SetModel( oModel ) // Seta o Model na View

	oView:AddField( "UBAA020_N70", oStruN70, "N70UBAA020" ) // Field da Esteira
	oView:AddField( "UBAA020_N71", oStruN71, "N71UBAA020" ) // Field do Esteira X Fardão
	oView:AddGrid( "UBAA020_N72", oStruN71GR, "N72UBAA020", ,{ || UBAA020OV() } ) // Grid do Esteira X Fardão


	oView:CreateVerticallBox( "TELANOVA" , 100 ) // Box Pai

	// Criação de Layout
	oView:CreateHorizontalBox( "SUPERIOR" , 15, "TELANOVA")
	oView:CreateHorizontalBox( "MEIO"	   , 25, "TELANOVA")
	oView:CreateHorizontalBox( "INFERIOR" , 60, "TELANOVA")

	// Atribuição de Layouts a cada SubView
	oView:SetOwnerView("UBAA020_N70", "SUPERIOR")
	oView:SetOwnerView("UBAA020_N71", "MEIO")
	oView:SetOwnerView("UBAA020_N72", "INFERIOR")

	oView:EnableTitleView("UBAA020_N70")
	oView:EnableTitleView("UBAA020_N71")

	// Auto-Increment do campo N71_ORDEM
	oView:addIncrementField("UBAA020_N72", "N71_ORDEM") // Incrementa o Campo Ordem

	// Fecha a tela após salvar os dados 
	oView:SetCloseOnOk({||.T.})
Return (oView)


/*{Protheus.doc} UBAA020INI
(long_description)
@type function
@author roney.maia
@since 09/01/2017
@version 1.0
@param InicP, ${param_type}, (Validador para abrir ou não o pergunte em tela)
*/
Function UBAA020INI(InicP)
	
	Pergunte('UBAA020001', InicP)

	cSafra 	:= Iif(!Empty(MV_PAR01), MV_PAR01, '') // Safra
	cProdutor 	:= Iif(!Empty(MV_PAR03), MV_PAR03, '') // Produtor
	cLoja 		:= Iif(!Empty(MV_PAR04), MV_PAR04, '') // Loja
	cFazenda 	:= Iif(!Empty(MV_PAR05), MV_PAR05, '') // Fazenda
	cTalhao 	:= Iif(!Empty(MV_PAR06), MV_PAR06, '') // Talhão
	cVariedade	:= Iif(!Empty(MV_PAR07), MV_PAR07, '') // Variedade
	cProdutoPar	:= Iif(!Empty(MV_PAR02), MV_PAR02, '') // Produto
Return

/*{Protheus.doc} UBAA020MOV
(Função de movimentação acionada pelos botões do "OTHER_PANEL")
@type function
@author roney.maia
@since 09/01/2017
@version 1.0
@param nTipo, numérico, (Tipo de movimento 1 - Cima, 2 - Abaixo)
@see (SFCA318.PRW)
*/
//-------------------------------------------------------------------
// Carregar Mover
// LineShift = idModel,linhaOrigem,linhaDestino
//-------------------------------------------------------------------
Static Function UBAA020MOV(nTipo)
	Local oView     	 := FWViewActive() // View que se encontra Ativa
	Local oModel    	 := FWModelActive() // Model que se encontra Ativo
	Local oModelN71GR	 := oModel:GetModel('N72UBAA020') // Submodelo da Grid
	Local nLinhaOld 	 := oView:GetLine('N72UBAA020') // Linha atualmente posicionada
	Local cLinAtu	  	 := oModelN71GR:GetValue("N71_ORDEM", nLinhaOld) // Pega o valor da Ordem na linha atual
	Local lRet 			 := .T.

	if oModelN71GR:GetValue('N71_STSLEG') != 'BR_AMARELO' 
		If nTipo == 1 // Para cima
	
			If nLinhaOld != 1
			
				oModelN71GR:GoLine(nLinhaOld - 1) //Verifica se o fardão de cima esta em beneficiamento.
				if oModelN71GR:GetValue('N71_STSLEG') = 'BR_AMARELO'
					oModel:SetErrorMessage( , , oModel:GetId() , "", "", "Fardões com status 'em beneficiamento' não podem ser movidos." , "", "", "")
					lRet := .F.
				else
					oModelN71GR:GoLine(nLinhaOld) //Volta pra linha originalmente selecionada				
				
					oModelN71GR:LoadValue("N71_ORDEM", oModelN71GR:GetValue("N71_ORDEM", nLinhaOld - 1)) // Seta o valor da linha de cima para atual
		
					oModelN71GR:GoLine(nLinhaOld - 1) // Move o posicionamento para a linha de cima
		
					oModelN71GR:LoadValue("N71_ORDEM", cLinAtu) // Seta o valor da Ordem no qual foi solicitada a movimentação
		
					oView:LineShift('N72UBAA020',nLinhaOld ,nLinhaOld - 1) // Realiza a troca de linhas
		
					oModelN71GR:GoLine(nLinhaOld - 1)
				endIf
	
			EndIf
	
		Else // Para baixo
	
			If nLinhaOld < oView:Length('N72UBAA020')
	
				oModelN71GR:LoadValue("N71_ORDEM", oModelN71GR:GetValue("N71_ORDEM", nLinhaOld + 1)) // Seta o valor da linha de baixo para atual
	
				oModelN71GR:GoLine(nLinhaOld + 1) // Move o posicionamento para a linha de baixo
	
				oModelN71GR:LoadValue("N71_ORDEM", cLinAtu) // Seta o valor da Ordem no qual foi solicitada a movimentação
	
				oModelN71GR:GoLine(nLinhaOld)
	
				oView:LineShift('N72UBAA020',nLinhaOld,nLinhaOld + 1) // Realiza a troca de linhas
	
				oModelN71GR:GoLine(nLinhaOld)
	
			EndIf
	
		EndIf
	
		oView:Refresh('N72UBAA020') // Atualiza a SubView da Grid
	
	
		If nTipo == 1
			oModelN71GR:GoLine(nLinhaOld - 1)
		Else
			oModelN71GR:GoLine(nLinhaOld + 1)
		Endif
	else
		lRet := .F.
		oModel:SetErrorMessage( , , oModel:GetId() , "", "", "Fardões com status 'em beneficiamento' não podem ser movidos." , "", "", "")
	endIf

Return lRet

/*{Protheus.doc} UBAA020VFA
(Validação para o vinculo de fardões x esteira, campo FARDÃO)
@type function
@author roney.maia
@since 09/01/2017
@version 1.0
@return ${return}, ${T - Aprovado, F - Reprovado}
*/
Function UBAA020VFA()
	Local lRet 		:= .T.
	Local lRetN71 	:= ExistCpo("N71", FwFldGet("N71_FARDAO")+FwFldGet("N71_SAFRA")+FwFldGet("N71_PRODUT")+FwFldGet("N71_LOJA")+FwFldGet("N71_FAZEN"), 2)
	Local lRetDXL 	:= ExistCpo("DXL", FwFldGet("N71_FARDAO")+FwFldGet("N71_SAFRA")+FwFldGet("N71_PRODUT")+FwFldGet("N71_LOJA")+FwFldGet("N71_FAZEN"), 1)
	Local oModel		:= FwModelActive()
	Local oModelN71FL	:= oModel:GetModel('N71UBAA020')
	Local lBlind		:= IsBlind()
	Local lAPI			:= (FWIsInCallStack("AlteraCottonBalesOnTreadmill"))

//	Local oModelN71GR 	:= oModel:GetModel("N72UBAA020")

	Local lN71Vld		:= Iif(!Empty(oModelN71FL:GetValue("N71_SAFRA")) ;
							.AND. !Empty(oModelN71FL:GetValue("N71_PRODUT")) ;
							.AND. !Empty(oModelN71FL:GetValue("N71_LOJA")) ;
							.AND. !Empty(oModelN71FL:GetValue("N71_FAZEN")), .T., .F.)


	If !lN71Vld // Validação de campos obrigatórios
		Help('', 1, 'OBRIGAT')
		Return .F.
	EndIf

	if !lAPI 
		If !lBlind
			If !lRetN71 .AND. lRetDXL
				lRet := .T.
			Else
				If Vazio() .OR. !lRetDXL // Se Vazio ou não possui fardão na DXL
					Help('', 1, STR0010, , STR0011, 1 ) // #Atenção!#Informe um fardão válido.#
				EndIf
				If lRetN71 // Se fardão ja existe vinculado a uma esteira
					Help('', 1, STR0010, , STR0012, 1 ) // #Atenção!#Fardão já incluso ou relacionado a outra esteira.#
				EndIf
				lRet := .F.
			EndIf
		Endif
	endIf
Return lRet


/*{Protheus.doc} UBAA020LEG
(Apresenta o Box de Legendas caso clicar duas vezes no campo)
@type function
@author roney.maia
@since 10/01/2017
@version 1.0
@param oGridModel, objeto, (oGrid)
@param nLine, numérico, (Linha selecionada)
@param cAction, character, (Ação na Linha)
@param cIDField, character, (Campo Selecionado)
@param xValue, variável, (Valor a ser atribuido)
@param xCurrentValue, variável, (Valor corrente)
@return ${Logico}, ${ .T. - Aprovado / .F. - Reprovado}

*/
Function UBAA020LEG(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
   	Local aLegenda 	:= {}
   	Local cTitulo  	:= STR0009 //"Status do Fardão"
   	Local oModel		:= Nil
   	Local oView		:= Nil
   	Local oModelN71FL	:= Nil // SubModelo N71 Field
   	Local nQtTroc		:= 0 // Variavel de controle de quantidade de trocas de linha
   	Local nNextLine	:= 0 // Variavel de controle paras as próximas linhas
   	Local lRet			:= .T.

	Local cSafra	   	:= ""
	Local cProdut		:= ""
	Local cLoja		:= ""
	Local cFazen		:= ""
	Local cTalhao		:= ""
	Local cVariedade	:= ""
	Local cCodProdut	:= ""

	If !(cIDField == "N71_ORDEM")
		oModel			:= FwModelActive()
	   	oModelN71FL	:= oModel:GetModel("N71UBAA020") // SubModelo N71 Field

		cSafra	   		:= oModelN71FL:GetValue("N71_SAFRA") // Valor atual no Field - campo Safra
		cProdut		:= oModelN71FL:GetValue("N71_PRODUT") // Valor atual no Field - campo Produtor
		cLoja			:= oModelN71FL:GetValue("N71_LOJA") // Valor atual no Field - campo Loja
		cFazen			:= oModelN71FL:GetValue("N71_FAZEN") // Valor atual no Field - campo Fazenda
		cTalhao		:= oModelN71FL:GetValue("N71_TALHAO") // Valor atual no Field - campo Talhao
		cVariedade		:= oModelN71FL:GetValue("N71_VAR") // Valor atual no Field - campo Variedade
		cCodProdut		:= oModelN71FL:GetValue("N71_CODPRO") // Valor atual no Field - campo Produto
   	EndIf

    If cIDField == "N71_STSLEG" .AND. cAction != "SETVALUE"
	    aLegenda := {    { "BR_BRANCO"  , STR0013 },; // "Previsto"
	    				 	{ "BR_AZUL"    , STR0014 },; // "Em Romaneio de Entrada"
	                     { "BR_VERDE"   , STR0015 },; // "Disponível"
	                     { "BR_AMARELO" , STR0016 },; // "Em Beneficiamento"
	                     { "BR_VERMELHO", STR0017 },; // "Beneficiado"
	                     { "BR_PRETO"   , STR0018 } } // "Finalizado"

	    BrwLegenda(cTitulo, "Legenda", aLegenda) // Apresenta um Box de Legendas
    EndIf

    // Seta os valores dos campos para gravação
   	If cIDField == "N71_FARDAO" .AND. cAction == "SETVALUE" .AND. !Empty(xValue)
	   	oGridModel:LoadValue("N71_SAFRA", cSafra)
		oGridModel:LoadValue("N71_PRODUT", cProdut)
		oGridModel:LoadValue("N71_LOJA", cLoja)
		oGridModel:LoadValue("N71_FAZEN", cFazen)
		oGridModel:LoadValue("N71_TALHAO", cTalhao)
		oGridModel:LoadValue("N71_VAR", cVariedade)
		oGridModel:LoadValue("N71_CODPRO", cCodProdut)

	EndIf

	// Validação Responsavel por reordenar as linhas através do campo Ordem, manualmente.
	If cIDField == "N71_ORDEM" .AND. cAction == "SETVALUE"
		oView 			:= FwViewActive()
		oModel			:= FwModelActive()
		nQtTroc		:= 0

		If xValue < 0 // Verifica se o número informado é negativo para validação
			Return lRet
		EndIf

		If xValue < xCurrentValue // Incremento, ou melhor, foi informado um valor superior ao que estava em campo

			nNextLine	:= nLine - 1
			// Atribui o ultimo valor da grid se caso o valor atribuido ser maior que o valor da grid
			If 	xValue == 0
				xValue := 1
			EndIf

			If nLine != 1
				nQtTroc := xCurrentValue - xValue
			EndIf

			While nQtTroc != 0

				oGridModel:GoLine(nLine)
				//oView:LineShift('N72UBAA020',nLine , nNextLine) // Realiza a troca de linhas
				oModel:GetModel("N72UBAA020"):LineShift(nLine , nNextLine)
				nLine--
				nNextLine--
				nQtTroc--

			EndDo

			lOrdena := .T. // Inicia a reordenação do grid através do changeline

		ElseIf xValue > xCurrentValue // Decremento, ou melhor, foi informado um valor inferior ao que estava em campo

			nNextLine	:= nLine + 1
			// Atribui o ultimo valor da grid quando atribuido o valor um valor maior que a grid
			If 	xValue > oGridModel:Length()
				xValue := oGridModel:GetValue('N71_ORDEM', oGridModel:Length())
			EndIf

			If nLine != oGridModel:Length()
				nQtTroc := xValue - xCurrentValue
			EndIf

			While nQtTroc != 0

				oGridModel:GoLine(nLine)
				//oView:LineShift('N72UBAA020',nLine , nNextLine) // Realiza a troca de linhas
				oModel:GetModel("N72UBAA020"):LineShift(nLine , nNextLine)
				nLine++
				nNextLine++
				nQtTroc--

			EndDo

			lOrdena := .T. // Inicia a reordenação do grid através do changeline

		EndIf

		lSetOrd := .T. // Ativa Reordenação da grid através do Array
		UBAA020OV() // Reordena a Grid
	EndIf
Return lRet


/*{Protheus.doc} UBAA020INT
(Verifica o status do fardão para atribuição as legendas,
também acionado por gatilho, tanto para legenda como para o
campo de peso liquido)
@type function
@author roney.maia
@since 10/01/2017
@version 1.0
@return ${cValor}, ${Retorna o valor a ser atribuido na legenda ou no peso liquido}
*/
Function UBAA020INT(nParam)
	Local cValor    		:= ""
	Local nValor    		:= 0
	Local aArea	  		:= GetArea()
	Local xFardInt  		:= .T.
	Local xSafraInt 		:= .T.
	Local xProdInt  		:= .T.
	Local xLojInt   		:= .T.
	Local xFazenInt 		:= .T.
	Local lExist    		:= .T.
	Local cChave    		:= ""
	Local sTsLeg	  		:= ""
	Local oModel	  		:= Nil
	Local oModelN71FL 	:= Nil
	Local lTipoG			:= .T.

	If nParam != 'LEG'
		oModel	  := FwModelActive()
	   	oModelN71FL := oModel:GetModel("N71UBAA020")
	EndIf

	If nParam == 'LEG' // Inicializador padrão e gatilho para o campo de legenda
		xFardInt  :=  Iif(TYPE("N71_FARDAO") == "U", .F., .T.) // Verifica se a variavel existe
		xSafraInt :=  Iif(TYPE("N71_SAFRA") == "U", .F., .T.)
		xProdInt  :=  Iif(TYPE("N71_PRODUT") == "U", .F., .T.)
		xLojInt   :=  Iif(TYPE("N71_LOJA") == "U", .F., .T.)
		xFazenInt :=  Iif(TYPE("N71_FAZEN") == "U", .F., .T.)
		lExist    := 	xFardInt .AND. xSafraInt .AND. xProdInt .AND. xLojInt .AND. xFazenInt
		cChave    :=  Iif( lExist ,N71_FARDAO + N71_SAFRA + N71_PRODUT + N71_LOJA + N71_FAZEN , "")
		sTsLeg	   := 	Iif(!Empty(cChave),Posicione('DXL',1,fwxFilial("DXL")+cChave,"DXL_STATUS"), "3")

		If sTsLeg == "1"
			cValor := "BR_BRANCO"
		ElseIf sTsLeg == "2"
			cValor := "BR_AZUL"
		ElseIf sTsLeg == "3"
			cValor := "BR_VERDE"
		ElseIf sTsLeg == "4"
			cValor := "BR_AMARELO"
		ElseIf sTsLeg == "5"
			cValor := "BR_VERMELHO"
		ElseIf sTsLeg == "6"
			cValor := "BR_PRETO"
		EndIf

		lTipoG := .T.

	ElseIf nParam == 'PSL' // Gatilho para campo de peso líquido
		xFardInt  :=  FwFldGet("N71_FARDAO")
		xSafraInt :=  oModelN71FL:GetValue("N71_SAFRA")
		xProdInt  :=  oModelN71FL:GetValue("N71_PRODUT")
		xLojInt   :=  oModelN71FL:GetValue("N71_LOJA")
		xFazenInt :=  oModelN71FL:GetValue("N71_FAZEN")
		cChave    :=  xFardInt + xSafraInt + xProdInt + xLojInt + xFazenInt
		nValor    := 	Posicione('DXL',1,fwxFilial("DXL")+cChave,"DXL_PSLIQU")

		lTipoG := .F.
	ElseIf nParam == 'TLH' // Gatilho para campo de talhão
		xFardInt  :=  FwFldGet("N71_FARDAO")
		xSafraInt :=  oModelN71FL:GetValue("N71_SAFRA")
		xProdInt  :=  oModelN71FL:GetValue("N71_PRODUT")
		xLojInt   :=  oModelN71FL:GetValue("N71_LOJA")
		xFazenInt :=  oModelN71FL:GetValue("N71_FAZEN")
		cChave    :=  xFardInt + xSafraInt + xProdInt + xLojInt + xFazenInt
		cValor    := 	Posicione('DXL',1,fwxFilial("DXL")+cChave,"DXL_TALHAO")

		lTipoG := .T.
	ElseIf nParam == 'VAR' // Gatilho para campo de variedade
		xFardInt  :=  FwFldGet("N71_FARDAO")
		xSafraInt :=  oModelN71FL:GetValue("N71_SAFRA")
		xProdInt  :=  oModelN71FL:GetValue("N71_PRODUT")
		xLojInt   :=  oModelN71FL:GetValue("N71_LOJA")
		xFazenInt :=  oModelN71FL:GetValue("N71_FAZEN")
		cChave    :=  xFardInt + xSafraInt + xProdInt + xLojInt + xFazenInt
		cValor    := 	Posicione('DXL',1,fwxFilial("DXL")+cChave,"DXL_CODVAR")

		lTipoG := .T.
		
	ElseIf nParam == 'PRO' // Gatilho para campo de produto
		xFardInt  :=  FwFldGet("N71_FARDAO")
		xSafraInt :=  oModelN71FL:GetValue("N71_SAFRA")
		xProdInt  :=  oModelN71FL:GetValue("N71_PRODUT")
		xLojInt   :=  oModelN71FL:GetValue("N71_LOJA")
		xFazenInt :=  oModelN71FL:GetValue("N71_FAZEN")
		cChave    :=  xFardInt + xSafraInt + xProdInt + xLojInt + xFazenInt
		cValor    := 	Posicione('DXL',1,fwxFilial("DXL")+cChave,"DXL_CODPRO")

		lTipoG := .T.


	Endif

	RestArea(aArea)

Return Iif(lTipoG, cValor, nValor)


/*{Protheus.doc} GravaDados
(Pós Modelo para gravação dos dados)
@type function
@author roney.maia
@since 11/01/2017
@version 1.0
@param oModel, objeto, (Modelo de Dados)
@return ${Logico}, ${.T. = Ok}
*/
Static Function GravaDados(oModel)

	Local nI				:= 0
	Local oModelN71FL 	:= oModel:GetModel("N71UBAA020")
	Local oModelN71GR 	:= oModel:GetModel("N72UBAA020")
	Local nLines			:= oModelN71GR:Length()
	Local nDelLin			:= 0

	oModelN71FL:SetOnlyQuery() // Método que torna todos os campos do submodelo N71 - FIELD em somente para pesquisa

	lOrdena := .T.
	UBAA020OV() // Reordenada a Grid Antes de Salvar

	// Valida se o fardão deletado está em beneficiamento
	For nI := 1 To oModelN71GR:Length()
		oModelN71GR:GoLine( nI )

		If  oModelN71GR:IsDeleted(nI) .AND. oModelN71GR:GetValue("N71_STSLEG") == "BR_AMARELO"
		                                                                                   //"Este fardão está sendo beneficiado, não é possivel exclui-lo!" + "Termine seu beneficiamento! "
	        oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0019,  STR0020, "", "")


			Return .F.
		EndIf
	Next

	// Realiza reordenação devido a linhas deletadas
	For nI := 1 To nLines
		If oModelN71GR:IsDeleted(nI)
			nDelLin++
		Else
			oModelN71GR:GoLine(nI)
			oModelN71GR:LoadValue("N71_ORDEM", oModelN71GR:GetValue("N71_ORDEM") - nDelLin)
		EndIf

	Next
Return FwFormCommit(oModel, , {|oModel,cID,cAlias| .T.})


/*{Protheus.doc} InitFields
(Seta propriedade da estrutura para permitir
update e inserir valores iniciais conforme pergunte)
@type function
@author roney.maia
@since 11/01/2017
@version 1.0
@param oModel, objeto, (Model para manipulação de valores)
@return ${Logico}, ${.T. = Ok}
*/
Static Function InitFields(oModel)
	Local oModelN71 		:= oModel:GetModel('N71UBAA020') // SubModelo N71 Field
	Local oModelN71GR 		:= oModel:GetModel("N72UBAA020")
	Local nI				:= 0
	Local nLines			:= oModelN71GR:Length()
	Local lFldEmpty 		:= 	Iif(!Empty(cSafra) .OR. !Empty(cProdutor) ;
						 	.OR. !Empty(cLoja) .OR. !Empty(cFazenda) ;
						 	.OR. !Empty(cTalhao) .OR. !Empty(cVariedade) .OR. !Empty(cProdutoPar), .T., .F.)

	// Torna possível alterar os campos ao inicializar ou após o commit
	oModelN71:GetStruct():SetProperty( 'N71_SAFRA' 	, MODEL_FIELD_NOUPD , .F.)
	oModelN71:GetStruct():SetProperty( 'N71_PRODUT' , MODEL_FIELD_NOUPD , .F.)
	oModelN71:GetStruct():SetProperty( 'N71_LOJA' 	, MODEL_FIELD_NOUPD , .F.)
	oModelN71:GetStruct():SetProperty( 'N71_FAZEN' 	, MODEL_FIELD_NOUPD , .F.)
	oModelN71:GetStruct():SetProperty( 'N71_TALHAO' , MODEL_FIELD_NOUPD , .F.)
	oModelN71:GetStruct():SetProperty( 'N71_VAR' 	, MODEL_FIELD_NOUPD , .F.)
	oModelN71:GetStruct():SetProperty( 'N71_CODPRO' , MODEL_FIELD_NOUPD , .F.)

	If oModel:GetOperation() == 4 .AND. lFldEmpty// Caso a operação for Alterar, inicializa os campos
		If .NOT. Empty(cSafra)
			oModelN71:LoadValue("N71_SAFRA"		, cSafra)
		EndIf
		If .NOT. Empty(cProdutor)
			oModelN71:LoadValue("N71_PRODUT"	, cProdutor)
		EndIf
		If .NOT. Empty(cLoja)
			oModelN71:LoadValue("N71_LOJA"		, cLoja)
		EndIf
		If .NOT. Empty(cFazenda)
			oModelN71:LoadValue("N71_FAZEN"		, cFazenda)
		EndIf
		If .NOT. Empty(cTalhao)
			oModelN71:LoadValue("N71_TALHAO"	, cTalhao)
		EndIf
		If .NOT. Empty(cVariedade)
			oModelN71:LoadValue("N71_VAR"		, cVariedade)
		EndIf
		If .NOT. Empty(cProdutoPar)
			oModelN71:LoadValue("N71_CODPRO"	, cProdutoPar)
			oModelN71:LoadValue("N71_DESPRO"	, Posicione('SB1',1,fwxFilial('SB1')+cProdutoPar,'B1_DESC'))
		EndIf
	EndIf

	If oModel:GetOperation() == 4
		// Realiza reordenação de linhas ao inicializar a rotina
		For nI := 1 To nLines
			oModelN71GR:GoLine(nI)
			oModelN71GR:LoadValue("N71_ORDEM", nI)
		Next
	EndIf

Return .T.


/*{Protheus.doc} UBAA020DX
(Consulta de filtro da grid para apresentar fardões somente em
estado de disponível ou beneficiamento)
@type function
@author roney.maia
@since 12/01/2017
@version 1.0
@return ${Character}, ${Query}
*/
Static Function UBAA020DX()
	Local cQry      := ""

	cQry  := " EXISTS (SELECT * FROM "+ retSqlName('DXL')+" DXL"
	cQry  += " WHERE D_E_L_E_T_ <> '*'"
	cQry  += " AND DXL_FILIAL = '"+ FWXFILIAL('DXL')+"'"
	cQry  += " AND DXL_CODIGO = N71_FARDAO"
	cQry  += " AND DXL_SAFRA = N71_SAFRA"
	cQry  += " AND DXL_PRDTOR = N71_PRODUT"
	cQry  += " AND DXL_LJPRO = N71_LOJA"
	cQry  += " AND DXL_FAZ = N71_FAZEN"
	cQry  += " AND DXL_RDMTO = 0"
	cQry  += " AND (DXL_STATUS = '3' OR DXL_STATUS = '4' ))"

Return cQry

/*{Protheus.doc} UBAA020VL
(Monta o Filtro em formato SQL para a consulta padrão do campo N71_FARDAO)
@type function
@author roney.maia
@since 17/01/2017
@version 1.0
@return ${cQry}, ${Retorna o filtro em formato de string para consulta em sql}
*/
// SXB - DXLN71, Filtro : #UBAA020VL()

Function UBAA020VL()
	Local oModel 	:=	FwModelActive()
	Local oStruN71 	:=	oModel:GetModel('N71UBAA020')
	Local cSafraInt :=	AllTrim(oStruN71:GetValue('N71_SAFRA'))
	Local cProdInt 	:=	AllTrim(oStruN71:GetValue('N71_PRODUT'))
	Local cLojInt 	:=	AllTrim(oStruN71:GetValue('N71_LOJA'))
	Local cFazenInt :=	AllTrim(oStruN71:GetValue('N71_FAZEN'))
	Local cTlhInt 	:=	AllTrim(oStruN71:GetValue('N71_TALHAO'))
	Local cVarInt 	:=	AllTrim(oStruN71:GetValue('N71_VAR'))
	Local cCodPro 	:=	AllTrim(oStruN71:GetValue('N71_CODPRO'))
	Local cQry	 		:=	""

	cQry  += "@D_E_L_E_T_ <> '*'"
	cQry  += " AND DXL_FILIAL = '" + FWXFILIAL('DXL') + "'"
	cQry  += " AND DXL_SAFRA = '" + cSafraInt + "' AND DXL_PRDTOR = '" + cProdInt + "'"
	cQry  += " AND DXL_LJPRO = '" + cLojInt + "' AND DXL_FAZ = '" + cFazenInt + "'"

	 If .Not. Empty(cTlhInt)
			cQry  += " AND DXL_TALHAO = '"+ cTlhInt+ "'"
	EndIf

	 If .Not. Empty(cVarInt)
			cQry +=" AND DXL_CODVAR = '"+ cVarInt+ "'"
	EndIf

	If .Not. Empty(cCodPro)
		cQry +=" AND DXL_CODPRO = '"+ cCodPro + "'"
	EndIf
	cQry  += " AND DXL_STATUS = '3'"
	// Que não tenha vinculo em outra esteira.
	cQry  += " AND NOT EXISTS (SELECT * FROM "+ retSqlName('N71')+" N71"
	cQry  += " WHERE D_E_L_E_T_ <> '*' AND N71_SAFRA = DXL_SAFRA AND N71_PRODUT = DXL_PRDTOR"
	cQry  += " AND N71_LOJA = DXL_LJPRO AND N71_FAZEN = DXL_FAZ AND N71_FARDAO = DXL_CODIGO)
	

Return cQry


/*{Protheus.doc} UBAA020VLP
(Validação de campos do Pergunte)
@type function
@author roney.maia
@since 17/01/2017
@version 1.0
@param cCampo, character, (Campo atual da validação)
@return ${Logico}, ${.T. - Aprovado, .F. - Reprovado}
*/
Function UBAA020VLP(cCampo)
	Local cValid := .T.

	If cCampo == "SAF" // MV_PAR01 - Safra
		cValid := Vazio() .OR. ExistCpo('NJU')
	ElseIf cCampo == "PRD" // MV_PAR02 - Produtor
		cValid := Vazio() .OR. ExistCpo('NJ0', MV_PAR03 + IIF(!Empty(MV_PAR04), MV_PAR04, ''))
	ElseIf cCampo == "LOJ" // MV_PAR03 - Loja
		cValid := Vazio() .OR. ExistCpo('NJ0', MV_PAR03 + IIF(!Empty(MV_PAR04), MV_PAR04, ''))
	ElseIf cCampo == "FAZ" // MV_PAR04 - Fazenda
		cValid := Vazio() .OR. ExistCpo('NN2', MV_PAR03 + MV_PAR04 + MV_PAR05, 3)
	ElseIf cCampo == "TLH" // MV_PAR05 - Talhão
		cValid := Vazio() .OR. ExistCpo('NN3', MV_PAR01 + MV_PAR05 + MV_PAR06, 1)
	ElseIf cCampo == "VAR" // MV_PAR06 - Variedade
		cValid := Vazio() .OR. ExistCpo("NN4", MV_PAR01 + MV_PAR05 + MV_PAR06 + MV_PAR07, 2)
	ElseIf cCampo == "PRO" // MV_PAR07 - Produto
		cValid := Vazio() .OR. ExistCpo('SB1')
	EndIf

Return cValid


/*{Protheus.doc} UBAA020OV
(Reordena a Grid em Tempo de Execução, no Foco da Grid e no Commit)
@type function
@author roney.maia
@since 17/01/2017
@version 1.0
@param oView, Objeto (View Ativa)
@param cViewID, Caracter (ID da View)
@return ${Logico}, ${.T. - Aprovado, .F. - Reprovado}
*/
Static Function UBAA020OV()
	Local oView			:= FwViewActive()
	Local oModel 		:= FwModelActive()
	Local oModelN71GR 	:= oModel:GetModel('N72UBAA020')
	Local aSvRows 		:= FWSaveRows() // Obtem a Grid com os dados atuais
	Local lRet 			:= .T.
	Local nIt 			:= 0
	Local nIt2 			:= 0

	// Reordena a Grid
	If lSetOrd

		For nIt := 1 To oModelN71GR:Length()


			aSvRows[1][1]:ADATAMODEL[nIt][1][1][6] := nIt
		Next

	   	FwRestRows(aSvRows)
		if VALTYPE(oView) == 'O'
			oView:Refresh()
		endIf
		lSetOrd := .F.

	// Reordena no foco da grid caso a ordem tenha sido editada manualmente e durante a gravação de dados
	ElseIf lOrdena
		For nIt2 := 1 To oModelN71GR:Length()
			oModelN71GR:GoLine(nIt2)
			oModelN71GR:LoadValue("N71_ORDEM", nIt2)
			If VALTYPE(oView) == 'O' .AND. oModelN71GR:Length() == nIt2
				oModelN71GR:GoLine(1)
				oView:Refresh('N72UBAA020')
				oModelN71GR:GoLine(1)
			EndIf
		Next
		lOrdena := .F.
	EndIf

Return lRet

/*{Protheus.doc} UBAA020F3
Função de filtro da consulta NN4N71.
Função no campo N71_VAR - X3_F3

@author 	ana.olegini
@since 		13/12/2017
@return 	lRetorno, Retorno .T. verdadeiro e .F. Falso
*/
Function UBAA020F3()
	Local lRetorno := .F.
	
	lRetorno := IF( IsIncallStack("Pergunte"),	;
	                NN4->NN4_SAFRA = MV_PAR01     .AND. NN4->NN4_FAZ = MV_PAR05	    .AND. NN4->NN4_TALHAO = MV_PAR06, ;
	                NN4->NN4_SAFRA = M->N71_SAFRA .AND. NN4->NN4_FAZ = M->N71_FAZEN .AND. NN4->NN4_TALHAO = M->N71_TALHAO )

Return lRetorno
