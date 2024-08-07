#Include "MNTA692.ch"
#Include "RWMAKE.CH"
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

#Define _nVersao 002 //Vers�o do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA692
Rotina de Planejamento de Mobiliza��o e Desmobiliza��o de 
Equipamentos (Bens)

@author Pedro Henrique Soares de Souza
@since 11/12/14
/*/
//---------------------------------------------------------------------
Function MNTA692()

	Local oBrowse
	Local aNGBeginPrm := NGBeginPrm( _nVersao )
	
	If !MntCheckCC("MNTA682")
		Return .F.
	EndIf
		
	oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("TVY")				// Alias da tabela utilizada
		oBrowse:SetMenuDef( "MNTA692" )		// Nome do fonte onde est� a fun��o MenuDef
		oBrowse:SetDescription( STR0001 )	// Descri��o do browse ## "Planejamento de Obras"
		oBrowse:Activate()
    
	NGReturnPrm(aNGBeginPrm)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Op��es de menu

@return aRotina - Estrutura
    [n,1] Nome a aparecer no cabecalho
    [n,2] Nome da Rotina associada
    [n,3] Reservado
    [n,4] Tipo de Transa��o a ser efetuada:
        1 - Pesquisa e Posiciona em um Banco de Dados
        2 - Simplesmente Mostra os Campos
        3 - Inclui registros no Bancos de Dados
        4 - Altera o registro corrente
        5 - Remove o registro corrente do Banco de Dados
        6 - Altera��o sem inclus�o de registros
        7 - C�pia
        8 - Imprimir
    [n,5] Nivel de acesso
    [n,6] Habilita Menu Funcional
    
@author Pedro Henrique Soares de Souza
@since 11/12/14
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina := {}
    
    Add Option aRotina Title STR0004 Action 'PesqBrw'           Operation 1  Access 0 // 'Pesquisar'
    Add Option aRotina Title STR0005 Action 'VIEWDEF.MNTA692'   Operation 2  Access 0 // 'Visualizar'
    Add Option aRotina Title STR0006 Action 'VIEWDEF.MNTA692'   Operation 3  Access 0 // 'Incluir'
    Add Option aRotina Title STR0007 Action 'VIEWDEF.MNTA692'   Operation 4  Access 0 // 'Alterar'
    Add Option aRotina Title STR0008 Action 'VIEWDEF.MNTA692'   Operation 5  Access 0 // 'Excluir'
    Add Option aRotina Title STR0009 Action 'VIEWDEF.MNTA692'   Operation 8  Access 0 // 'Imprimir'
    
Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de modelagem da grava��o

@author Pedro Henrique Soares de Souza
@since 11/12/14
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
    
	Local oStructA := FWFormStruct( 1, 'TVY' )
	Local oStructB := FWFormStruct( 1, 'TVX', {|x| AllTrim(x) <> 'TVX_ID' } )

	//Pr�-valida��o do submodelo(Grid)
	Local bPreValid  := {|oModelGrid, nLine, cAction, cIDField, xValue, xCurrentValue|;
		PreValid(oModelGrid, nLine, cAction, cIDField, xValue, xCurrentValue)}
	
	//P�s-valida��o da linha (LinhaOk)
	Local bLinePost := {|oModelGrid, nLine, cAction, cID, xValue, xCurrentValue|;
		LinePost(oModelGrid, nLine, cAction, cID, xValue, xCurrentValue)}
		
    //Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('MNTA692', /*bPre*/,{|oModel| ValidInfo(oModel)}, {|oModel| CommitInfo(oModel) }, /*bCancel*/ )
    
    //Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:AddFields( 'MNTA692_TVY', /*cOwner*/, oStructA, /*bPre*/, /*bPos*/, /*bCarga*/ )
	
    //Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
	oModel:AddGrid( 'MNTA692_TVX', 'MNTA692_TVY', oStructB,, bLinePost, bPreValid, /*bPosVal*/, /*bLoad*/ )
    
    //Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'MNTA692_TVX', { { 'TVX_FILIAL', 'xFilial( "TVX" )' }, { 'TVX_ID', 'TVY_ID' } }, TVX->( IndexKey(1) ) )
    
    //Liga o controle de n�o repeti��o de linha
	oModel:GetModel( 'MNTA692_TVX' ):SetUniqueLine( { 'TVX_SEQUEN' } )
    
    //Indica que � opcional ter dados informados na Grid
	oModel:GetModel( 'MNTA692_TVX' ):SetOptional(.F.)
	
	//N�o permite exclus�o de registros da Grid
	oModel:GetModel( 'MNTA692_TVX' ):SetNoDeleteLine(.T.)
	
    //Adiciona a descri��o do Modelo de Dados
	oModel:SetDescription( STR0002 ) //"Dados do Planejamento"
    
    //Adiciona a descri��o do Componente do Modelo de Dados
	oModel:GetModel('MNTA692_TVY' ):SetDescription( STR0002 ) //"Dados do Planejamento"
	oModel:GetModel('MNTA692_TVX' ):SetDescription( STR0003 ) //"Hist�rico da Linha de Base"
	
Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o Usu�rio

@author Pedro Henrique Soares de Souza
@since 11/12/14
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel 		:= FWLoadModel( "MNTA692" )
	
	Local oView  		:= FWFormView():New()
	
	Local oStructVA	:= FWFormStruct( 2, 'TVY' )
	Local oStructVB	:= FWFormStruct( 2, 'TVX', { |x| !( AllTrim(x) $ 'TVX_ID, TVX_CODMOT' ) } )
		
	// Define qual o Modelo de dados ser� utilizado
	oView:SetModel( oModel )
	
	//Valida se o planejamento pode ou n�o ser alterado/exclu�do	
	oView:SetViewCanActivate({|| fValidView( oModel )}) 
    
    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_TVY', oStructVA, 'MNTA692_TVY' )
    
    //Adiciona um titulo para o formul�rio
	oView:EnableTitleView( 'VIEW_TVY' ,STR0002 ) //"Dados do Planejamento"
    
    //Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid( 'VIEW_TVX', oStructVB, 'MNTA692_TVX' )

    //Adiciona um titulo para o grid
	oView:EnableTitleView('VIEW_TVX', STR0003 ) //"Hist�rico da Linha de Base"
    
    //Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
	oView:CreateHorizontalBox( 'INFERIOR', 60 )
    
    //Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_TVY', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_TVX', 'INFERIOR' )
	
	//Fecha a tela ap�s confirmar
	oView:SetCloseOnOk( {|| .T.} )
	
	//BlocoS executado ap�s confirma��o/cancelamento da tela
	oView:SetAfterOkButton( {|| fResetBloc() } )
	oView:SetViewAction( 'BUTTONCANCEL', { |oView| fResetBloc( oView ) } )

	//Inclus�o de itens nas A��es Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)
    
Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} CommitInfo
Confirma��o da tela de cadastro

@param oModel Modelo de dados

@return lRet Indica se a grava��o foi bem sucedida.

@author Pedro Henrique Soares de Souza
@since 11/12/14
/*/
//---------------------------------------------------------------------
Static Function CommitInfo(oModel)
    
	Local aSaveLines, aArea := GetArea()
	
	Local oModelGrid	:= oModel:GetModel( 'MNTA692_TVX' )
	
	Local nSizeCols	:= oModelGrid:Length()
	Local nOperation	:= oModel:GetOperation()
	
	Local lChanged	:= ( fGetQtdReg() <> nSizeCols )
	
	If nOperation == MODEL_OPERATION_DELETE
		fMemoSYP(oModelGrid, nOperation)
	EndIf
	
	//---------------------------------------------------------------------
	//Grava��o Geral
	//---------------------------------------------------------------------
	FwFormCommit(oModel)
	
	//---------------------------------------------------------------------
	//Atualiza��o dos campos da TVY com �ltima altera��o TVX
	//---------------------------------------------------------------------
	If ( nOperation == MODEL_OPERATION_INSERT .Or.;
		  nOperation == MODEL_OPERATION_UPDATE ) .And. lChanged
		
		aSaveLines := FwSaveRows()
		
		//Posiciona na �ltima linha (mais atualizada)
		oModelGrid:GoLine( nSizeCols )

		dbSelectArea('TVY')		
		dbSetOrder(1)
		If dbSeek(xFilial('TVY') + oModel:GetValue('MNTA692_TVY','TVY_ID') )
		
			RecLock('TVY', .F.)
			
			TVY->TVY_DTINIC	:= oModel:GetValue('MNTA692_TVX','TVX_DTINIC')
			TVY->TVY_DTFIM	:= oModel:GetValue('MNTA692_TVX','TVX_DTFIM')
			TVY->TVY_QUANT	:= oModel:GetValue('MNTA692_TVX','TVX_QUANT')
			TVY->TVY_DTALT	:= oModel:GetValue('MNTA692_TVX','TVX_DTALT')
			
			//Caso seja inclus�o atualiza grava respons�vel pelo plano
			If nOperation == MODEL_OPERATION_INSERT
				TVY->TVY_CODUSU	:= oModel:GetValue('MNTA692_TVX','TVX_CODUSU')
			EndIf
			
			TVY->( MsUnlock() )
		
		EndIf
		
		//---------------------------------------------------------------------
		//Grava��o do campo memo TVX_MOTIVO
		//---------------------------------------------------------------------
		fMemoSYP(oModelGrid, nOperation)

		FwRestRows( aSaveLines )
		
	EndIf
	
	RestArea( aArea )
    
Return .T.

//---------------------------------------------------------------------
// In�cio -> Valida��es
//---------------------------------------------------------------------

//---------------------------------------------------------------------
/*/{Protheus.doc} fValidView
Verifica se o view deve ou n�o ser ativado.

@param oModel Modelo de dados

@author Pedro Henrique Soares de Souza
@since 12/12/2014
/*/
//---------------------------------------------------------------------
Static Function fValidView( oModel )

	Local nDtMaxAlt	:= SuperGetMV("MV_NGDTPLA", .F., "0", cFilAnt)
	Local lRet			:= .T.
	
	//Verifica se o conte�do do par�metro � num�rico ou n�o
	nDtMaxAlt := IIf( ValType(nDtMaxAlt) <> "N", 0, nDtMaxAlt)
	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And.;
			oModel:GetOperation() == MODEL_OPERATION_DELETE
		
		Do Case
			Case Day(dDataBase) > nDtMaxAlt
			
				ApMsgInfo(STR0010, STR0034) 
				//"O Per�odo M�ximo para a altera��o/exclus�o do Planejamento j� foi ultrapassado."###"Aten��o"
			
			Case TVY->TVY_DTINIC <= dDataBase
		
				ApMsgInfo(STR0011, STR0034) 
				//"N�o � poss�vel alterar/excluir este Planejamento porque a Data Atual � superior"
				//" ou igual a Data de In�cio do Planejamento."###"Aten��o"
			
			Case PswAdmin(,,RetCodUsr()) <> 0 .And. AllTrim( RetCodUsr() ) <> AllTrim(TVY->TVY_CODUSU)
				
				ApMsgInfo(STR0012 + CRLF + STR0013, STR0034) 
				//"Voc� n�o possui permiss�o para manipular este registro."
				//"Somente Administradores ou o pr�prio Respons�vel pelo Planejamento podem alter�-lo/exclu�-lo."###"Aten��o"
				
			OtherWise
				
				lRet := .T.
		EndCase
	EndIf
	
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidInfo
Valida��o ao confirmar tela (TudoOk)

@param oModel Modelo de dados

@return lRet Indica se todas as informa��es est�o corretas

@author Pedro Henrique Soares de Souza
@since 11/12/14
/*/
//---------------------------------------------------------------------
Function ValidInfo( oModel )

	Local lRet		:= .T.
	Local aArea 	:= GetArea()
	
	//Verifica se a opera��o n�o � uma exclus�o, se for n�o necessita valida��o
	If oModel:GetOperation() <> MODEL_OPERATION_DELETE
	
		//Verifica a consist�ncia das datas do Plano, de Inicio, e Fim
		lRet := fValData(1) .And. fValData(2) .And. fValData(3) .And. fCheckDupl()
		
	EndIf
	
	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} LinePost
Valida��o da linha do Grid

@return lRet L�gico

@author Pedro Henrique Soares de Souza
@since 13/05/2014
/*/
//---------------------------------------------------------------------
Static Function LinePost(oModelGrid, nLine, cAction, cIDField, xValue, xCurrentValue)
    
	Local lRet		:= .T.
	Local oModel	:= oModelGrid:GetModel()
	
	Local nOperation	:= oModel:GetOperation()
	Local nNumReg		:= 0
	
	Local cQuery, cAliasST9 := GetNextAlias()
	
	//Verifica se a Quantidade de Bens est� de acordo com a Familia e o Modelo
	If oModelGrid:IsInserted()
		dbSelectArea( "TVY" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TVY" ) + M->TVY_ID )
			If !( lRet := TVY->TVY_DTINIC <> FwFldGet('TVX_DTINIC') .Or.;
							TVY->TVY_DTFIM <> FwFldGet('TVX_DTFIM') .Or.;
							TVY->TVY_QUANT <> FwFldGet('TVX_QUANT') )
				
				Help( ,, 'Help',, STR0035 +;
					AllTrim( RetTitle("TVX_DTINIC") ) + "', '" +;
					AllTrim( RetTitle("TVX_DTFIM") ) + STR0022 +;
					AllTrim( RetTitle("TVX_QUANT") ) + "'." + CRLF + CRLF + STR0036, 1, 0)
			EndIf
		Else
			cQuery := " SELECT Count(*) AS NUMREG" 
			cQuery += " FROM " + RetSqlName('ST9')
			cQuery += " WHERE T9_FILIAL = " + ValToSql( xFilial('ST9') )
			cQuery += "   AND T9_CODFAMI = " + ValToSql( FwFldGet('TVY_CODFAM') )
			cQuery += "   AND T9_TIPMOD = " + ValToSql( FwFldGet('TVY_TIPMOD') )
			cQuery += "   AND T9_CATBEM = '4'"
			cQuery += "   AND T9_SITBEM = 'A'"
			cQuery += "   AND D_E_L_E_T_ <> '*'"
				
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasST9, .F., .F.)
			
			If (cAliasST9)->( !EoF() )
				nNumReg := (cAliasST9)->NUMREG
			EndIf
			
			(cAliasST9)->( dbCloseArea() )
		
			If FwFldGet('TVX_QUANT') > nNumReg
				If !( lRet := MsgYesNo(STR0014 + STR0015 + STR0016 + CRLF + CRLF + STR0017, STR0034) )
					Help( ,, 'Quant',, STR0014 + STR0015 + STR0016, 1, 0)
				EndIf
				
				//"A Quantidade Prevista de Bens para este Planejamento � superior"
				//" a Quantidade de Equipamentos cadastrados no sistema para esta"
				//" Fam�lia e Modelo." ## "Deseja prosseguir?" ## "Aten��o"
			EndIf
		EndIf
	EndIf
	
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} PreValid
Pr�-Valida��o da modelo (Grid)

@return lRet L�gico

@author Pedro Henrique Soares de Souza
@since 13/05/2014
/*/
//---------------------------------------------------------------------
Static Function PreValid(oModelGrid, nLine, cAction, cIDField, xValue, xCurrentValue)
	
	Local lRet		:= .T.
	Local oModel	:= oModelGrid:GetModel()
	
	Local nLineMax, nOperation := oModel:GetOperation()
	
	Do Case

		Case  nOperation == MODEL_OPERATION_UPDATE
			
			If !oModelGrid:CanInsertLine()
				oModelGrid:SetNoInsertLine(.F.)
			EndIf
			
			nLineMax := fGetQtdReg() + 1
			
			oModelGrid:SetMaxLine( nLineMax )
			
			//Bloqueia altera��o de linhas existentes
			lRet := !( cAction == 'CANSETVALUE' .And. !oModelGrid:IsInserted() )
			
		Case nOperation == MODEL_OPERATION_INSERT 
		
			oModelGrid:SetNoInsertLine(.T.)

	EndCase
	
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA692VAL
Valid dos campos envolvidos da rotina MNTA692

@param cCampo Indica o campo a ser validado

@return lRet Indica se o conte�do est� ou n�o correto

@author Pedro Henrique Soares de Souza
@since 13/05/2014
/*/
//---------------------------------------------------------------------
Function MNTA692VAL( cCampo )
    
	Local lRet := .F.
       
	Do Case
		Case ReadVar() == "M->TVY_CODFAM"
			lRet := ExistCpo('ST6', FwFldGet('TVY_CODFAM'), 1)
		            
		Case ReadVar() == "M->TVY_TIPMOD"
			lRet := ExistCpo('TQR', FwFldGet('TVY_TIPMOD'), 1)
		            
		Case ReadVar() == "M->TVY_DTPLAN"
			lRet := fValData(1)
		            
		Case ReadVar() == "M->TVX_DTINIC"
			lRet := fValData(2)
					            
		Case ReadVar() == "M->TVX_DTFIM"
			lRet := fValData(3)
		
		Case ReadVar() == "M->TVX_QUANT"
			lRet := !Empty( FwFldGet('TVX_QUANT') ) .And. Positivo()
		
		OtherWise
			lRet := .T.
	EndCase
    
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValData
Fun��o que verifica consist�ncia das datas. 

@param nParam	1 - Data do Plano
				2 - Data de Inicio
				3 - Data de Fim

@return lRet Indica se a data n est� ou n�o correta.

@author Pedro Henrique Soares de Souza
@since 15/12/2014
/*/
//---------------------------------------------------------------------
Static Function fValData(nParam)

	Local lRet := .T.

	Default nParam := 1

	If nParam == 1
	
		If !( lRet := FWFldGet("TVY_DTPLAN") <= dDataBase )
		
			Help( ,, 'Help',, STR0018 + AllTrim( RetTitle("TVY_DTPLAN") ) + STR0019, 1, 0 )
			//"A '" ## "' n�o pode ser superior a Data Atual."
		EndIf
		
	ElseIf nParam == 2
	
		If !( lRet := FWFldGet("TVX_DTINIC") >= FWFldGet("TVY_DTPLAN") )
		
			Help( ,, 'Help',, STR0018 + AllTrim( RetTitle("TVX_DTINIC") ) + STR0020 + AllTrim( RetTitle("TVY_DTPLAN") ) + "'.", 1, 0 )
			//"A '" ## "' n�o pode ser inferior a '"
		EndIf
		
	ElseIf nParam == 3
	
		If !( lRet := FWFldGet("TVX_DTFIM") >= FWFldGet("TVX_DTINIC") )
		
			Help( ,, 'Help',, STR0018 + AllTrim( RetTitle("TVX_DTFIM") ) + STR0020 + AllTrim( RetTitle("TVX_DTINIC") ) + "'.", 1, 0 )
			//"A '" ## "' n�o pode ser inferior a '"
			
		ElseIf FWFldGet("TVX_DTFIM") == FWFldGet("TVX_DTINIC")
			
			//"Aten��o" ## "Os campos de '" ## "' e '" ## "' est�o iguais."
			//"Este Planejamento realmente possui a mesma Data para o In�cio e Fim?"
			If !( lRet := MsgYesNo( STR0021 + AllTrim( RetTitle("TVX_DTINIC") ) + ;
								STR0022 + AllTrim( RetTitle("TVX_DTFIM") ) + STR0023 + CRLF + CRLF + STR0024, STR0034) )
			
				Help( ,, 'Help',, STR0018 + RetTitle("TVX_DTFIM") + STR0025 + AllTrim( RetTitle("TVX_DTINIC") ) + "'.", 1, 0 )
				//"A '" ## "' n�o pode ser igual a '"
			EndIf
		EndIf
		
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCheckDupl
Verifica se existe um planejamento com mesma fam�lia e modelo.

@return lRet Indica se um registro com as condi��es acima j� existe.
			Retorna .F. caso j� exista.

@author Pedro Henrique Soares de Souza
@since 15/12/2014
/*/
//---------------------------------------------------------------------
Static Function fCheckDupl()

	Local lRet		 := .T.
	Local aAreaTVY := TVY->( GetArea() )
		
	Local oModel     := FWModelActive()
	Local oModelGrid := oModel:GetModel( 'MNTA692_TVX' )
	
	Local aSaveLines := FwSaveRows()
	
	Local cMsgErro   := "" 
	
	oModelGrid:GoLine( oModelGrid:Length() )
	
	If !Empty( FwFldGet('TVY_CODFAM') ) .And. !Empty( FwFldGet('TVY_TIPMOD') )
	
		//Verifica duplicidade de Planejamento por Familia e Modelo no periodo selecionado
		dbSelectArea("TVY")
		dbSetOrder(4)
		If dbSeek(xFilial("TVY") + FwFldGet('TVY_CODFAM') + FwFldGet('TVY_TIPMOD'))
				
			While !EoF() .And. TVY->TVY_FILIAL == xFilial("TVY") .And.;
				TVY->TVY_CODFAM == FwFldGet('TVY_CODFAM') .And. TVY->TVY_TIPMOD == FwFldGet('TVY_TIPMOD')
								
				If FwFldGet('TVY_ID') <> TVY->TVY_ID
									
					//Se a Data de Inicio no cadastro for MENOR que a da base, quer dizer que estamos verificando um planejamento ANTERIOR
					If FwFldGet('TVX_DTINIC') < TVY->TVY_DTINIC
										
						If FwFldGet('TVX_DTFIM') >= TVY->TVY_DTINIC
							cMsgErro := STR0018 + AllTrim( RetTitle("TVX_DTFIM") ) + STR0026 + STR0027
											
							//"A '" ## "' n�o pode ser maior nem igual ao in�cio de um outro planejamento j� cadastrado."
							//"Um planejamento deve terminar antes do pr�ximo ser iniciado."
						EndIf
										
					//Se a Data de Inicio no cadastro for MAIOR que a da base, quer dizer que estamos verificando um planejamento POSTERIOR
					ElseIf FwFldGet('TVX_DTINIC') > TVY->TVY_DTINIC
									
						If FwFldGet('TVX_DTINIC') <= TVY->TVY_DTFIM
										
							cMsgErro := STR0018 + AllTrim( RetTitle("TVX_DTINIC") ) + STR0028 + STR0029
											
							//"A '" ## "' n�o pode ser menor nem igual ao t�rmino de um outro planejamento j� cadastrado."
							//"Um planejamento deve iniciar depois do anterior ter sido encerrado."
						EndIf
					EndIf
								
					If !( lRet := Empty(cMsgErro) )
								
						Help( ,, 'Help',, STR0031 + CRLF + CRLF +;
							AllTrim( RetTitle("TVY_CODFAM") ) + ": " + AllTrim( FwFldGet('TVY_CODFAM') ) + " | " +;
							AllTrim( RetTitle("TVY_TIPMOD") ) + ": " + AllTrim(FwFldGet('TVY_TIPMOD') ) + CRLF +;
							STR0032 + DTOC( FwFldGet('TVX_DTINIC') ) + " - " + DTOC( FwFldGet('TVX_DTFIM') ) + CRLF + CRLF +; 
							cMsgErro + CRLF + CRLF + STR0033, 5, 0 )

						Exit
					EndIf
				EndIf
						
				dbSelectArea("TVY")
				dbSkip()
			EndDo
		EndIf
	EndIf
	
	FwRestRows( aSaveLines )
	
	RestArea(aAreaTVY)
	
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA692REL
Carrega X3_RELACAO dos campos da tabela TVY e TVZ

@return cReturn Valor que ser� usado por padr�o

@author Pedro Henrique Soares de Souza
@since 22/09/2015
/*/
//---------------------------------------------------------------------
Function MNTA692REL()

	Local cReturn
	
	Local oModel    := FWModelActive()
	Local lInclui	  := oModel:GetOperation() == MODEL_OPERATION_INSERT
	
	Do Case
		Case ReadVar() == "M->TVY_ID"
			cReturn := IIf(lInclui, GetSXENum('TVY', 'TVY_ID'), TVY->TVY_ID)
		            
		Case ReadVar() == "M->TVY_DESFAM"
			cReturn := IIf(lInclui, ' ', NGSEEK('ST6', TVY->TVY_CODFAM, 1, 'T6_NOME'))
		
		Case ReadVar() == "M->TVY_DESMOD"
			cReturn := IIf(lInclui, ' ', NGSEEK('TQR', TVY->TVY_TIPMOD, 1, 'TQR_DESMOD'))
		      
		Case ReadVar() == "M->TVY_DESFAM"
			cReturn := IIf(lInclui, ' ', NGSEEK('ST6', TVY->TVY_CODFAM, 1, 'T6_NOME'))
		     
		Case ReadVar() == "M->TVY_DTPLAN"
			cReturn := IIf(lInclui, dDataBase, TVY->TVY_DTPLAN)
		      
		Case ReadVar() == "M->TVX_SEQUEN"
			cReturn := fNextSeq()
			
		Case ReadVar() == "M->TVX_DTINIC"
			cReturn := IIf(lInclui, dDataBase, TVY->TVY_DTINIC)
		      
		Case ReadVar() == "M->TVX_DTFIM"
			cReturn := IIf(lInclui, dDataBase, TVY->TVY_DTFIM)
			
		Case ReadVar() == "M->TVX_QUANT"
			cReturn := IIf(lInclui, 0, TVY->TVY_QUANT)
			
		Case ReadVar() == "M->TVX_MOTIVO"
			cReturn := IIf(lInclui, STR0030, MSMM(TVX->TVX_CODMOT) )
			
		Case ReadVar() == "M->TVX_DTALT"
			cReturn := dDatabase
			
		Case ReadVar() == "M->TVX_CODUSU"
			cReturn := RetCodUsr()
			
		Case ReadVar() == "M->TVX_NOMUSU"
			cReturn := UsrFullName( RetCodUsr() )
		      
		OtherWise
			cReturn := ' '
			
	EndCase

Return cReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} fNextSeq
Carrega sequ�ncia da linha base do planejamento

@return cSequen Valor que ser� usado para nova sequ�cia

@author Pedro Henrique Soares de Souza
@since 22/09/2015
/*/
//---------------------------------------------------------------------
Static Function fNextSeq()

	Local oModel		:= FWModelActive()
	Local oModelGrid	:= oModel:GetModel( 'MNTA692_TVX' )
	
	Local nLine	:= oModelGrid:Length()
	Local cSequen	:= Replicate('0', TamSX3('TVX_SEQUEN')[1])
	
	For nLine := oModelGrid:Length() To 1 Step -1
            
		oModelGrid:GoLine( nLine )
		
		If !oModelGrid:IsDeleted()
			If!Empty( cSequen := oModelGrid:GetValue('TVX_SEQUEN') )
				Exit
			EndIf
		EndIf
            
	Next nLine
	
	cSequen := Soma1( cSequen )

Return cSequen

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetQtdReg
Conta n�mero de registros da linha base

@return nNumReg N�mero de registros encontrados

@author Pedro Henrique Soares de Souza
@since 22/09/2015
/*/
//---------------------------------------------------------------------
Static Function fGetQtdReg()

	Local aArea	:= GetArea()
	
	Local nNumReg := 1
	Local cQuery, cAliasTVX := GetNextAlias()
	
	cQuery := " SELECT Count(*) AS NUMREG" 
	cQuery += " FROM " + RetSqlName('TVX')
	cQuery += " WHERE TVX_FILIAL = " + ValToSql( TVY->TVY_FILIAL )
	cQuery += "   AND TVX_ID = " + ValToSql( TVY->TVY_ID )
	cQuery += "   AND D_E_L_E_T_ <> '*'"
		
	cQuery := ChangeQuery(cQuery)
		
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery),cAliasTVX, .F., .F.)
		
	If (cAliasTVX)->( !EoF() )
		nNumReg := (cAliasTVX)->NUMREG
	EndIf
	
	(cAliasTVX)->( dbCloseArea() )
	
	RestArea(aArea)
		
Return nNumReg

//---------------------------------------------------------------------
/*/{Protheus.doc} fMemoSYP
Deleta registros da tabela SYP

@return nNumReg N�mero de registros encontrados

@author Pedro Henrique Soares de Souza
@since 22/09/2015
/*/
//---------------------------------------------------------------------
Static Function fMemoSYP(oModelGrid, nOperation)

	Local aSaveLines		  := FWSaveRows()
	Local nLine, nSizeCols := oModelGrid:Length()
	
	//Indica se � opera��o de dele��o ou insert/update
	Local lDelete	:= ( nOperation == MODEL_OPERATION_DELETE )
	Local lInsert := ( nOperation == MODEL_OPERATION_INSERT )
	
	Local cCodMSMM, cTextSYP
	
	For nLine := 1 To nSizeCols
		
		oModelGrid:GoLine( nLine )
		
		cCodMSMM := IIf( lInsert, Nil, FwFldGet('TVX_CODMOT') )
		cTextSYP := IIf( lDelete, Nil, FwFldGet('TVX_MOTIVO') )
			
		If !oModelGrid:IsDeleted()
			MSMM(cCodMSMM,,, cTextSYP, IIf( lDelete, 2, 1 ),,, "TVX", "TVX_CODMOT")
		EndIf
		
	Next nLine
		
	FwRestRows( aSaveLines )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fResetBloc
Reseta configura��o de bloqueio de inser��o

@return Nil Nulo

@author Pedro Henrique Soares de Souza
@since 22/09/2015
/*/
//---------------------------------------------------------------------
Static Function fResetBloc( oView )

	Local oModel		:= FWModelActive()
	Local oModelGrid	:= oModel:GetModel( 'MNTA692_TVX' )
	
	If !oModelGrid:CanInsertLine()
		oModelGrid:SetNoInsertLine(.F.)
	EndIf
	
Return .T.
