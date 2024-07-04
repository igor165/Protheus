#Include 'MNTA686.ch'
#Include 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'

#Define _nVersao 003 //Vers�o do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA686
Suspens�es de Aluguel

@return Nil

@author Pedro Henrique Soares de Souza
@since 02/08/2014
/*/
//---------------------------------------------------------------------
Function MNTA686()

	Local aNGBeginPrm := NGBeginPrm( _nVersao )
	Local oBrowse
	
	/*--------------------------------------------------------------------
	As vari�veis aRotina e cCadastro s�o utilizadas na fun��o MsDocument
	no fonte MATXFUNC, n�o retir�-las!
	--------------------------------------------------------------------*/
	Private aRotina     := {}
	Private cCadastro   := STR0001
		
	If !MntCheckCC("MNTA686")
		Return .F.
	EndIf
	
	oBrowse := FWMBrowse():New()
	
		oBrowse:SetAlias( "TVB" )           // Alias da tabela utilizada
		oBrowse:SetMenuDef( "MNTA686" )     // Nome do fonte onde esta a fun��o MenuDef
		oBrowse:SetDescription( STR0001 )   // Descri��o do browse ## "Suspens�es de Aluguel"

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
@since 02/08/2014
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	aRotina	:= {}
	//Local lPyme		:= If( Type( "__lPyme" ) <> "U", __lPyme, .F. )
	
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.MNTA686" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0007 ACTION "MNTA686CAD(3)"	  OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0008 ACTION "MNTA686CAD(4)"	  OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0009 ACTION "MNTA686CAD(5)"	  OPERATION 5 ACCESS 0 // "Excluir"
	
	If Type("__lPyme") == "U" .Or. !__lPyme
		//Adiciona a op��o 'Conhecimento' em A��es Relacionadas
		ADD OPTION aRotina TITLE STR0010 ACTION "MNTA686DOC" OPERATION 4 ACCESS 0 // "Conhecimento"
	EndIf

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de Modelagem da grava��o

@return oModel

@author Pedro Henrique Soares de Souza
@since 02/08/2014
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oModel

	Local oStructTVB := FWFormStruct(1,"TVB")

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("MNTA686", /*bPre*/, { |oModel| ValidInfo( oModel ) }, /*bCommit*/, /*bCancel*/)
    
	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:AddFields("MNTA686_TVB", Nil, oStructTVB, /*bPre*/, /*bPost*/, /*bLoad*/)

	oModel:SetDescription( STR0001 )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o usu�rio

@return oView

@author Pedro Henrique Soares de Souza
@since 02/08/2014
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel("MNTA686")
	Local oView  := FWFormView():New()

	// Objeto do model a se associar a view.
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MNTA686_TVB" , FWFormStruct(2, "TVB"), /*cLinkID*/ )    //

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "MASTER" , 100, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )

	// Associa um View a um box
	oView:SetOwnerView( "MNTA686_TVB" , "MASTER" )

	//Inclus�o de itens nas A��es Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)
    
Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidInfo
Valida��o ao confirmar tela

@param oModel

@return lRet L�gico

@author Pedro Henrique Soares de Souza
@since 06/08/2014
/*/
//---------------------------------------------------------------------
Static Function ValidInfo(oModel)
    
	Local aArea     := GetArea()
	Local nRecTVB, cAliasQry, cQuery
    
	Local lRet      := .T.
	//Local lAsked    := .F.
	Local lAltera   := oModel:GetOperation() == MODEL_OPERATION_UPDATE
	Local lInclui   := oModel:GetOperation() == MODEL_OPERATION_INSERT
    
	If  lAltera .Or. lInclui
    
		If lAltera
			nRecTVB :=  TVB->( Recno() )
		EndIf
        
		cAliasQry := GetNextAlias()
        
		cQuery := " SELECT TVB.TVB_DATINI, TVB.TVB_DATFIM, TVB.TVB_MOTIVO, TVC.TVC_DESMOT "
		cQuery += " FROM " + RetSQLName("TVB") + ' TVB, ' + RetSQLName("TVC") + ' TVC'
		cQuery += " WHERE TVB.TVB_CODBEM = '" + FWFldGet('TVB_CODBEM') + "' "
		cQuery += "   AND TVB.TVB_MOTIVO = TVC.TVC_MOTIVO "
		cQuery += "   AND ( (" + fDataSQL('TVB_DATINI') + " >= TVB.TVB_DATINI AND 	" + fDataSQL('TVB_DATFIM') + " <= TVB.TVB_DATFIM) "
		cQuery += "       	 OR (" + fDataSQL('TVB_DATFIM') + " >= TVB.TVB_DATINI AND " + fDataSQL('TVB_DATFIM') + " <= TVB.TVB_DATFIM)"
		cQuery += "           OR (" + fDataSQL('TVB_DATINI') + " <= TVB.TVB_DATINI AND " + fDataSQL('TVB_DATFIM') + " >= TVB.TVB_DATFIM)"
		cQuery += "           OR (" + fDataSQL('TVB_DATINI') + " = TVB.TVB_DATFIM )"
		cQuery += "           OR (" + fDataSQL('TVB_DATFIM') + " = TVB.TVB_DATINI ) )"

		If NGSX2MODO("TVB") == NGSX2MODO("TVC")
			cQuery += " AND TVB.TVB_FILIAL = TVC.TVC_FILIAL"
		Else
			cQuery += " AND TVB.TVB_FILIAL = '" + xFilial("TVB") + "'"
			cQuery += " AND TVC.TVC_FILIAL = '" + xFilial("TVC") + "'"
		Endif
        
		If lAltera
			cQuery += " AND TVB.R_E_C_N_O_ <> '" + AllTrim( Str(nRecTVB) ) + "' "
		Endif
        
		cQuery += " AND TVB.D_E_L_E_T_ <> '*'"
		cQuery += " AND TVC.D_E_L_E_T_ <> '*'"
		cQuery += " ORDER BY TVB.TVB_DATINI"
        
		cQuery := ChangeQuery(cQuery)
        
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T. )
		If !( lRet:= (cAliasQry)->( EoF() ) )
			Help(" ", 1, "NGATENCAO",, STR0002 + Chr(13) + Chr(13) +; //"J� existe uma parada para o Bem no intervalo:"
				AllTrim( NGRETTITULO("TVB_DATINI") ) + ': ' + DToC( SToD( (cAliasQry)->TVB_DATINI) ) + Chr(13) +;
				AllTrim( NGRETTITULO("TVB_DATFIM") ) + ': ' + DToC( SToD( (cAliasQry)->TVB_DATFIM) ) + Chr(13) +;
				AllTrim( NGRETTITULO("TVB_MOTIVO") ) + ': ' + AllTrim((cAliasQry)->TVB_MOTIVO) + ' - ' +;
				AllTrim( (cAliasQry)->TVC_DESMOT ) + chr(13), 1, 0)
		Endif
        
		(cAliasQry)->(dbCloseArea())
        
		/*If lInclui .And. lRet
			If (lRet := ExistChav( "TVB", FwFldGet("TVB_CODBEM") + FwFldGet("TVB_MOTIVO") + DToS( FWFldGet('TVB_DATINI') ), 1 ))
				dbSelectArea("TVG")
				dbSetOrder(1)
				If dbSeek( xFilial("TVG") + FwFldGet("TVB_CODBEM") )
					While !EoF() .And. xFilial("TVG") == TVG->TVG_FILIAL .And.;
							TVG->TVG_CODBEM == FwFldGet("TVB_CODBEM") .And. !lAsked
                            
						If AllTrim( Str( Year( FWFldGet('TVB_DATINI') ) ) ) == TVG->TVG_ANOREF .And.;
								StrZero( Month( FWFldGet('TVB_DATINI') ), 2) == TVG->TVG_MESREF
							lAsked := .T.
							lRet   := ApMsgYesNo(STR0003,STR0005) //"C�lculo do custo do aluguel j� foi processado, confirma inclus�o?" ## "ATENCAO"
						EndIf
                        
						dbSelectArea("TVG")
						dbSkip()
					EndDo
				EndIf
			EndIf
		EndIf*/
	EndIf
    
	RestArea( aArea )
    
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA686VAL
Valid dos campos da tabela TVB

@return lRet L�gico

@author Pedro Henrique Soares de Souza
@since 13/05/2014
/*/
//---------------------------------------------------------------------
Function MNTA686VAL()
    
	Local lRet := .F.
    
	Do Case
	
		Case ReadVar() $ "M->TVB_CODBEM"
			lRet := ExistCpo('ST9', M->TVB_CODBEM, 1) .AND. MNTA686BEM()
	        
		Case ReadVar() $ "M->TVB_MOTIVO"
			lRet := ExistCpo('TVC', M->TVB_MOTIVO)
	            
		Case ReadVar() $ "M->TVB_DATINI"
			lRet := MNTA686DAT()
	            
		Case ReadVar() $ "M->TVB_DATFIM"
			lRet := MNTA686DAT()
	            
		OtherWise
			lRet := .T.
		
	EndCase
    
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT686DAT()
Valida��o das datas

@Return L�gico - Indica se a data � ou n�o v�lida.

@author Marcos Wagner Junior
@since 24/06/2010
/*/
//---------------------------------------------------------------------
Static Function MNTA686DAT()
    
	If !Empty(M->TVB_DATINI) .And. !Empty(M->TVB_DATFIM)
		If M->TVB_DATINI > M->TVB_DATFIM
			ApMsgStop( STR0004, STR0005 ) //"De Data n�o poder� ser maior que At� Data!"###"ATEN��O"
			Return .F.
		Endif
	Endif
    
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA686BEM()
Verifica se o bem existe na tabela TTM - Ve�culos do Grupo

@author Marcos Wagner Junior
@since 24/06/2010

Fun��o adaptada para Codebase

@author Pedro Henrique Soares de Souza
@since 09/10/2014
/*/
//---------------------------------------------------------------------
Static Function MNTA686BEM()

	Local lFoundTTM	:= .F.
	Local aOldArea	:= GetArea()
    
	If !Empty( M->TVB_CODBEM )
    
    	dbSelectArea("ST9")
    	dbSetOrder(1)
    	If dbSeek(xFilial("ST9") + M->TVB_CODBEM)

    		dbSelectArea("TTM")
    		dbSetOrder(1)
    		If dbSeek(M->TVB_CODBEM + ST9->T9_PLACA)
				If TTM->TTM_ALUGUE == '1'
					lFoundTTM := .T.
				EndIf
			EndIf	

		EndIf
        
		If !lFoundTTM
			 Help(" ", 1,STR0005,,STR0011, 3, 1)			
		EndIf
	EndIf
    
	RestArea(aOldArea)
    
Return lFoundTTM

//---------------------------------------------------------------------
/*/{Protheus.doc} fDataSQL()
Carrega e converte valor de determinado campo data para o formato SQL. 

@author Pedro Henrique Soares de Souza
@since 07/07/2015
/*/
//---------------------------------------------------------------------
Static Function fDataSQL( cField )
Return ValToSql( DToS( FWFldGet( cField ) ) ) 

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA686CAD()
Fun��o de Inclus�o/Altera��o/Exclus�o  

@author Bruno Lobo de Souza
@since 09/09/2015
/*/
//---------------------------------------------------------------------
Function MNTA686CAD( nOper )

	Local nOk := 1
	
	// FWExecView retorna 0 em caso de Confirma��o, e 1 no caso de Cancelamento
	nOk := FWExecView( cCadastro/*cTitulo*/, "MNTA686"/*cPrograma*/, nOper/*nOperation*/, /*oDlg*/,;
						{|| .T. }/*bCloseOnOk*/, {|| fVldOk() }/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/)
	
Return nOk

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldOk()
Valida confirma��o da tela 

@author Bruno Lobo de Souza
@since 09/09/2015
/*/
//---------------------------------------------------------------------
Static Function fVldOk()
	
	Local lRet := .T.
	
	If FWFldGet( "TVB_DATINI" ) <> TVB->TVB_DATFIM 
    	lRet := ApMsgYesNo( STR0003, STR0005 ) //"C�lculo do custo do aluguel j� foi processado, ao confirmar � importante refazer o c�lculo."##"ATENCAO"
    EndIf
    
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA686DOC
Valida confirma��o da tela 

@author Bruno Lobo de Souza
@since 09/09/2015
/*/
//---------------------------------------------------------------------
Function MNTA686DOC()

	dbSelectArea( "TVB" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TVB" ) + TVB->TVB_CODBEM + TVB->TVB_MOTIVO + DtoS(TVB->TVB_DATINI) )
	
	MsDocument( 'TVB', TVB->( Recno() ), 4 )
Return
