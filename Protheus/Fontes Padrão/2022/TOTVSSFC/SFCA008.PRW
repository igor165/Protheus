#INCLUDE "SFCA008.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA008
Tela de cadastro de Meta de Produção

@author Tiago Gauziski
@since 24/09/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA008()
Local aCoors := MsAdvSize()
Local oPanelUp, oFWLayer, oPanel 

Private oDlgPrinc, oBrowseUp, oBrowse
Private aFieldsDisp := {}
Private aFieldsSel  := {}
Default lAutomacao  := .F. 

SFCValProg() // Verifica se está atualizado

If !lAutomacao
	Define MsDialog oDlgPrinc Title STR0001 From aCoors[7],00 To aCoors[6],aCoors[5] Pixel      // 'Metas de Produção'

	// Cria o conteiner onde serão colocados os browses
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )
        
	// Define Painel Superior
	oFWLayer:AddLine( 'UP', 65, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )
                    
	// Painel Inferior
	oFWLayer:AddLine( 'DOWN', 35, .F. )
	oFWLayer:AddCollumn( 'LEFT' ,  100, .T., 'DOWN' )
	oPanel := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' )
     
	// FWMarkBrowse Inferior
	oBrowse:= FWMarkBrowse():New()
	oBrowse:SetOwner( oPanel )
	oBrowse:SetDescription( STR0002 ) // 'Meta Máquina'
	oBrowse:DisableDetails( .T. )    
	oBrowse:SetAlias( 'CY5' )    
	//oBrowse:SetDataQuery()
	oBrowse:SetProfileID( '2' )  
	oBrowse:SetMenuDef( '' )       
	oBrowse:Activate()

	// FWMarkBrowse Superior
	oBrowseUp:= FWMarkBrowse():New()
	oBrowseUp:SetOwner( oPanelUp )
	oBrowseUp:SetDescription( STR0001 )  //"Metas de Produção"
	oBrowseUp:SetMenuDef( 'SFCA008' )
	oBrowseUp:SetAlias( 'CYU' )
	oBrowseUp:SetProfileID( '1' )   
	oBrowseUp:ForceQuitButton( .T. )  
	oBrowseUp:SetChange( { || SFCA008REL( CYU->CYU_CDMEPO ) })
	oBrowseUp:Activate()

	Activate MsDialog oDlgPrinc Center
EndIf

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION 'PesqBrw'        OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0004 ACTION 'SFCA008E(1)'    OPERATION 2 ACCESS 0  // 'Visualizar'
ADD OPTION aRotina TITLE STR0005 ACTION 'SFCA008E(3)'    OPERATION 3 ACCESS 0  // 'Incluir'    
ADD OPTION aRotina TITLE STR0006 ACTION 'SFCA008E(4)'    OPERATION 4 ACCESS 0  // 'Alterar'    
ADD OPTION aRotina TITLE STR0007 ACTION 'SFCA008E(5)'    OPERATION 5 ACCESS 0  // 'Excluir'    
//ADD OPTION aRotina TITLE STR0008 ACTION 'SFCA008E(8)'    OPERATION 8 ACCESS 0  // 'Imprimir'   
//ADD OPTION aRotina TITLE STR0009 ACTION 'SFCA008E(9)'    OPERATION 9 ACCESS 0  // 'Copiar'     
ADD OPTION aRotina TITLE STR0010 ACTION 'SFCA008P(.T.)'  OPERATION 3 ACCESS 0  // 'Importação Componente Meta' 
ADD OPTION aRotina TITLE STR0011 ACTION 'SFCA008AP(.T.)' OPERATION 3 ACCESS 0  // 'Gerar Indicadores' 		 

Return aRotina
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCYU := FWFormStruct( 1, 'CYU', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStructCY5 := FWFormStruct( 1, 'CY5', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStructCYS := FWFormStruct( 1, 'CYS', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel  

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA008', /*bPreValidacao*/, { |oMdl| SFCA008DEL(oMdl) }/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYUMASTER', /*cOwner*/, oStructCYU, { |oMdl| SFCA008PRE(oMdl) }/*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ ) 

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'CY5DETAIL', 'CYUMASTER', oStructCY5, /*bLinePre*/, { |oMdl| SFCA008aLP( oMdl ) }/*bLinePost*/, /*bPreVal*/, { |oMdl| SFCA008APS( oMdl ) } /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CYSDETAIL', 'CY5DETAIL', oStructCYS, /*bLinePre*/, { |oMdl| SFCA008bLP( oMdl ) }/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CY5DETAIL', { { 'CY5_FILIAL', 'xFilial( "CY5" )' }, { 'CY5_CDMEPO', 'CYU_CDMEPO' } }, CY5->(IndexKey(1)) )
oModel:SetRelation( 'CYSDETAIL', { { 'CYS_FILIAL', 'xFilial( "CYS" )' }, { 'CYS_IDMEPO', 'CY5_IDMEPO' } }, CYS->(IndexKey(1)) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'CY5DETAIL' ):SetUniqueLine( { 'CY5_IDMEPO' } )
oModel:GetModel( 'CYSDETAIL' ):SetUniqueLine( { 'CYS_NRSQME' } )

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'CY5DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CYSDETAIL' ):SetOptional(.T.)

// Não permite incluir/alterar linhas na FormGrid
oModel:GetModel( 'CYSDETAIL' ):SetNoInsertLine()
oModel:GetModel( 'CYSDETAIL' ):SetNoUpdateLine()                                                          

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0012 )  //'Modelo de Dados de Metas de Produção'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYUMASTER' ):SetDescription( STR0013 )  // 'Dados de Metas de Produção'
oModel:GetModel( 'CY5DETAIL' ):SetDescription( STR0014 )  // 'Dados de Metas Máquina'
oModel:GetModel( 'CYSDETAIL' ):SetDescription( STR0015 )  // 'Dados de Componentes da Meta'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA008' )
// Cria a estrutura a ser usada na View
Local oStructCYU := FWFormStruct( 2, 'CYU' )
Local oStructCY5 := FWFormStruct( 2, 'CY5' )
Local oStructCYS := FWFormStruct( 2, 'CYS' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona um botao para escolher os indicadores de cada máquina
oView:AddUserButton( STR0016, 'SFCA008', { || SFCA008IND() } )  // 'Indicadores da Máquina'

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYU', oStructCYU, 'CYUMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CY5', oStructCY5, 'CY5DETAIL' ) 
oView:AddGrid(  'VIEW_CYS', oStructCYS, 'CYSDETAIL' ) 

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 34 )
oView:CreateHorizontalBox( 'INFERIORMAQUINA', 33 )
oView:CreateHorizontalBox( 'INFERIORCOMPONENTE', 33 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYU', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CY5', 'INFERIORMAQUINA' )
oView:SetOwnerView( 'VIEW_CYS', 'INFERIORCOMPONENTE' )

//Remove o campo repetido em tela
oStructCY5:RemoveField("CY5_CDMEPO")
oStructCY5:RemoveField('CYS_IDMEPO')
oStructCYU:RemoveField('CYU_TPHIME')
oStructCYU:RemoveField('CYU_NRLV')

//Adiciona auto incremento
oView:AddIncrementField("VIEW_CYS","CYS_NRSQME")   

Return oView   

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCA008IND
Tela de seleção de indicador

@author Ana Carolina Tome Klock
@since 27/01/11
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCA008IND() 

	Local oDlg
	Local oBrwEsq
	Local oBrwDir
	Local nAlt   	:= 400
	Local nLrg   	:= 570
	Local aField    := {}
	Local lDefault  := .F.
	Private cTitle  := STR0017 + FwFldGet('CY5_IDMEPO')  //'Indicadores da Maquina '
	Default lAutomacao := .F.
	                                                                               
	//-------------------------------------------------------------------
	// Preenche os Campos Disponiveis com os Indicadores do Banco 
	//-------------------------------------------------------------------  
	aFieldsDisp := {}
	aFieldsSel := {}
	dbSelectArea("CYJ")
	dbSeek(xFilial("CYJ"))
	Do While ! Eof() .And. CYJ_FILIAL == xFilial("CYJ")
    	If !Empty(Posicione("CY8",,xFilial("CY8")+FwFldGet('CY5_IDMEPO')+CYJ->CYJ_CDIN,"CY8_CDIN"))
	    	Aadd(aFieldsSel, {CY8->CY8_CDIN})
	    Else 
	    	Aadd(aFieldsDisp, {CYJ->CYJ_CDIN})
	    EndIf
		dbSkip()
	Enddo   
	
	If !lAutomacao
		Define MsDialog oDlg Title cTitle From 00,00 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
	
		//-------------------------------------------------------------------
		// Browser da esquerda - Indicadores Disponíveis                      
		//-------------------------------------------------------------------            
		oBrwEsq := TWBrowse():New( 35 , 1, 130, 150,, { STR0018 },{30}, oDlg, ,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )  // 'Campos Disponíveis'
		oBrwEsq:SetArray(aFieldsDisp)
		oBrwEsq:bLine := {||{ If(Len(aFieldsDisp) > 0,aFieldsDisp[oBrwEsq:nAt][1], ) } }

		TButton():New(60,136,'>',oDlg,{||  SFCXMOVE(@oBrwEsq, @oBrwDir, @aFieldsDisp, @aFieldsSel, .F., aFieldsDisp[oBrwEsq:nAt][1] ,.T., FwFldGet('CY5_IDMEPO') ) },10,10,,,,.T.)
		TButton():New(75,136,'<',oDlg,{||  SFCXMOVE(@oBrwDir, @oBrwEsq, @aFieldsSel, @aFieldsDisp, .T., aFieldsSel[oBrwEsq:nAt][1] , .F., FwFldGet('CY5_IDMEPO') ) },10,10,,,,.T.)
		TButton():New(90,136,'>>',oDlg,{|| SFCXALL (@oBrwEsq, @oBrwDir, @aFieldsDisp, @aFieldsSel, .F., .T., FwFldGet('CY5_IDMEPO') ) },10,10,,,,.T.)
		TButton():New(105,136,'<<',oDlg,{|| SFCXALL (@oBrwDir, @oBrwEsq, @aFieldsSel, @aFieldsDisp, .T., .F., FwFldGet('CY5_IDMEPO') ) },10,10,,,,.T.)
		TButton():New(120,136,'/\',oDlg,{|| SFCXMOVEUP(@oBrwDir, @aFieldsSel) },10,10,,,,.T.)
		TButton():New(135,136,'\/',oDlg,{|| SFCXMOVEDO(@oBrwDir, @aFieldsSel) },10,10,,,,.T.)   
	
		//-------------------------------------------------------------------
		// Browser da direita - Indicadores Selecionados                      
		//-------------------------------------------------------------------
		oBrwDir := TWBrowse():New( 35 , 152, 130, 150,, { STR0019 },{30}, oDlg, ,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )  // 'Campos Selecionados'
		oBrwDir:SetArray(aFieldsSel)
		oBrwDir:bLine := { || { If(Len(aFieldsSel) > 0,aFieldsSel[oBrwDir:nAt][1], ) } } 
		oBrwDir:bWhen := { || { If(Len(aFieldsSel) > 0, oButton:Enable(), oButton:Disable() ) } }

		//-------------------------------------------------------------------
		// Detalhes do Indicador Selecionado
		//-------------------------------------------------------------------   
      
		oButton := TButton():New(187,225, STR0020 , oDlg, {|| SFCA008FOL(aFieldsSel[oBrwDir:nAt][1], FwFldGet('CY5_IDMEPO'))}, 50, 10,,,,.T.)  // 'Detalhe Indicador'
    
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(SFCX000OK()  ,ODlg:End(),NIL)},{||,ODlg:End()},,,,,,,, .F. ) CENTERED 
	EndIf

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA008FOL
Rotina para administrar os indicadores
   
@param   cIdMePo       (obrigatório) Código da Máquina
@param   cCdIn         (obrigatório) Código do Indicador

@author Ana Carolina Tomé Klock
@since 27/01/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA008FOL(cCdIn, cIdMePo)
	Local oDlg 
	Private	dDtVdBg, dDtVdEd, cFaixa1, cFaixa2, cFaixa3, nValor0, nValor1, nValor2, nValor3 
	Private cTitulo1, cTitulo2, cTitulo3, cDescri1, cDescri2, cDescri3
	Default lAutomacao := .F.
	 
	If !lAutomacao	
		Define MsDialog oDlg Title STR0021 + cCdIn From 00,00 To 370,560 Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel //"Detalhes do Indicador " 
			aTFolder := { STR0022, STR0023, STR0024, STR0025 }     // 'Detalhes' ### 'Faixa 1' ### 'Faixa 2' ### 'Faixa 3'
	    	oTFolder := TFolder():New( 03,01,aTFolder,,oDlg,,,,.T.,,281,172)  
	      
	    	If !Empty(Posicione("CY8",,xFilial("CY8")+cIdMePo+cCdIn,"CY8_CDIN")) 
		    	cFaixa1  := CY8->CY8_DSMI 
				cTitulo1 := CY8->CY8_DSSIMI
				cDescri1 := CY8->CY8_DSMSMI	
				cFaixa2  := CY8->CY8_DSXA   
				cTitulo2 := CY8->CY8_DSSIXA
				cDescri2 := CY8->CY8_DSMSXA
				cFaixa3  := CY8->CY8_DSMX
				cTitulo3 := CY8->CY8_DSSIMX
				cDescri3 := CY8->CY8_DSMSMX 
				nValor0  := 0
				nValor1  := CY8->CY8_VLPNMI
				nValor2  := CY8->CY8_VLPNMX
				nValor3  := 100 
				dDtVdBg  := CY8->CY8_DTVDBG 
		    	dDtVdEd	 := CY8->CY8_DTVDED 
		 	EndIf
    
	    	// Folder 1
	  		@ 10,020  Say STR0026             Of oTFolder:aDialogs[1]  COLOR CLR_BLACK Pixel //"Máquina"
	  		@ 20,020  MsGet oIdMePo Var cIdMePo Size 070,10 Pixel Of oTFolder:aDialogs[1]
	  		oIdMePo:Disable()
	  		@ 10,150  Say STR0027             Of oTFolder:aDialogs[1]  COLOR CLR_BLACK Pixel //"Indicador"
	  		@ 20,150  MsGet oCdIn   Var cCdIn   Size 070,10 Pixel Of oTFolder:aDialogs[1]
			oCdIn:Disable()  	
	  		@ 40,020  Say STR0028    		  Of oTFolder:aDialogs[1]  COLOR CLR_BLACK Pixel //"Início Validade"
	  		@ 50,020  MsGet dDtVdBg  			Size 070,10 Pixel Of oTFolder:aDialogs[1]
	  		@ 40,150  Say STR0029             Of oTFolder:aDialogs[1]  COLOR CLR_BLACK Pixel //"Fim Validade"
	 		@ 50,150  MsGet dDtVdEd 			Size 070,10 Pixel Of oTFolder:aDialogs[1]

	    	// Folder 2
	   		@ 10,020  Say STR0030             Of oTFolder:aDialogs[2]  COLOR CLR_BLACK Pixel //"Mensagem"
	    	@ 20,020  MsGet cFaixa1 			Size 090,10 Pixel Of oTFolder:aDialogs[2]
	    	@ 10,150  Say STR0031   	      Of oTFolder:aDialogs[2]  COLOR CLR_BLACK Pixel //"Título da Mensagem"
	  		@ 20,150  MsGet cTitulo1			Size 090,10 Pixel Of oTFolder:aDialogs[2] 	
	  		@ 40,020  Say STR0032      		  Of oTFolder:aDialogs[2]  COLOR CLR_BLACK Pixel //"Descricao"
	  		@ 50,020  MsGet cDescri1 			Size 150,10 Pixel Of oTFolder:aDialogs[2] 
	  		@ 70,020  Say STR0033       	  Of oTFolder:aDialogs[2]  COLOR CLR_BLACK Pixel //"Limite Inicial"
	  		@ 80,020  MsGet oValor0 Var nValor0 Size 070,10 Pixel Of oTFolder:aDialogs[2]
	  		oValor0:Disable()
	  		@ 70,150  Say STR0034        	  Of oTFolder:aDialogs[2]  COLOR CLR_BLACK Pixel //"Limite Final"
	 		@ 80,150  MsGet nValor1 		 	Size 070,10 Pixel Of oTFolder:aDialogs[2]
	  	
	    	// Folder 3
	   		@ 10,020  Say STR0030             Of oTFolder:aDialogs[3]  COLOR CLR_BLACK Pixel //"Mensagem"
	    	@ 20,020  MsGet cFaixa2 			Size 90,10 Pixel Of oTFolder:aDialogs[3]
	    	@ 10,150  Say STR0031             Of oTFolder:aDialogs[3]  COLOR CLR_BLACK Pixel //"Título da Mensagem"
	  		@ 20,150  MsGet cTitulo2 			Size 90,10 Pixel Of oTFolder:aDialogs[3] 	
	  		@ 40,020  Say STR0032      		  Of oTFolder:aDialogs[3]  COLOR CLR_BLACK Pixel //"Descricao"
	  		@ 50,020  MsGet cDescri2  			Size 150,10 Pixel Of oTFolder:aDialogs[3] 
	  		@ 70,020  Say STR0033      		  Of oTFolder:aDialogs[3]  COLOR CLR_BLACK Pixel //"Limite Inicial"
	  		@ 80,020  MsGet nValor1 			Size 70,10 Pixel Of oTFolder:aDialogs[3]
	  		@ 70,150  Say STR0034        	  Of oTFolder:aDialogs[3]  COLOR CLR_BLACK Pixel //"Limite Final"
	 		@ 80,150  MsGet nValor2  			Size 70,10 Pixel Of oTFolder:aDialogs[3]

	    	// Folder 4
	   		@ 10,020  Say STR0030             Of oTFolder:aDialogs[4]  COLOR CLR_BLACK Pixel //"Mensagem"
	    	@ 20,020  MsGet cFaixa3 			Size 90,10 Pixel Of oTFolder:aDialogs[4]
	    	@ 10,150  Say STR0031             Of oTFolder:aDialogs[4]  COLOR CLR_BLACK Pixel //"Título da Mensagem"
	  		@ 20,150  MsGet cTitulo3 			Size 90,10 Pixel Of oTFolder:aDialogs[4] 	
	  		@ 40,020  Say STR0032      		  Of oTFolder:aDialogs[4]  COLOR CLR_BLACK Pixel //"Descricao"
	  		@ 50,020  MsGet cDescri3			Size 150,10 Pixel Of oTFolder:aDialogs[4]
	  		@ 70,020  Say STR0033     		  Of oTFolder:aDialogs[4]  COLOR CLR_BLACK Pixel //"Limite Inicial"
	  		@ 80,020  MsGet nValor2 			Size 70,10 Pixel Of oTFolder:aDialogs[4]
	  		@ 70,150  Say STR0034       	  Of oTFolder:aDialogs[4]  COLOR CLR_BLACK Pixel //"Limite Final"
	 		@ 80,150  MsGet oValor3 Var nValor3 Size 70,10 Pixel Of oTFolder:aDialogs[4] 
	 		oValor3:Disable()
 
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(SFCA008FVL()  ,ODlg:End(),NIL)},{||,ODlg:End(),},,{ { STR0035, { || SFXCOMPMSG(2) }, STR0035, STR0035 } }) CENTERED  // 'Compor Mensagem'
	EndIf
	
Return  

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA008PRE
Rotina para impedir alteração da chave 

@param   oModel       Model do grid da tabela

@author Ana Carolina Tomé Klock
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA008PRE(oModel)                                   
	Local lRet		:= .T.
	Local nOpc      := (oModel:GetModel():GetOperation())
	Local oModelCYU
	Default lAutomacao := .F.

	If !lAutomacao 
		oModelCYU :=	oModel:GetStruct( 'CYU_VIEW' )
	EndIf
	
	If nOpc != 3
		oModelCYU:SetProperty("CYU_CDMEPO",13,.T.) 
	EndIf
	     
Return lRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA008DEL
Rotina para deletar os filhos

@param   oModel       Model do grid da tabela

@author Ana Carolina Tomé Klock
@since 23/05/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA008DEL(oModel)  
	Local cCDMEPO := oModel:GetValue('CYUMASTER','CYU_CDMEPO')
	Local nOpc	  := oModel:GetModel():GetOperation()
	Local cTipo   := oModel:GetValue('CYUMASTER','CYU_TPME') 
	Local cIdMePo    
	Local aAreaCY5
	Local lRet    := .T.
	Local oModelCY5 := oModel:GetModel('CY5DETAIL') 
	Local nI := 0
	
	If nOpc == 5 
		If ApMsgYesNo( STR0068 ) // 'Deseja remover meta máquina e seus componentes/indicadores relacionados?' 
		    dbSelectArea( 'CY5' )
			dbSeek(xFilial('CY5')+cCDMEPO)
			While CY5->(!EOF())
			    If CY5->CY5_CDMEPO == cCDMEPO
			    	cIdMePo  := CY5->CY5_IDMEPO 
			        aAreaCY5 := CY5->(GetArea())  
			   	    DelRelation( 'CY8', cIdMePo, "IDMEPO" )
	   				DelRelation( 'CY4', cIdMePo, "IDMEPO" )
	   				DelRelation( 'CZ4', cIdMePo, "IDMEPO" ) 
	   				DelRelation( 'CZ5', cIdMePo, "IDMEPO" ) 
	   				DelRelation( 'CYS', cIdMePo, "IDMEPO" )   
			   	    RestArea(aAreaCY5)
			   	    DBRLock()
		         	DBDelete()   
		            DBUnlock() 
			    EndIf 
			    CY5->(dbSkip())
		 	End
		Else
			lRet := .F.
		EndIf
    Else
	    For nI := 1 To oModelCY5:GetQtdLine()
    		oModelCY5:GoLine(nI)
    		
			IF !oModelCY5:IsDeleted()
				Do Case
					Case cTipo == '1'
						nHoras := 24
					Case cTipo == '2'
						nHoras := 24 * 7
					Case cTipo == '3'
						nHoras := 24 * 31
				End Case
		
				if oModelCY5:GetValue('CY5_QTTEPL') > nHoras
					SFCMsgErro ( STR0050 + ALLTRIM(STR(nHoras)) + ' na máquina ' + oModelCY5:GetValue('CY5_CDMQ'), "SFCA008") // 'Quantidade de horas não deve ultrapassar '
					lRet := .F.
				Else
					lRet := SFCA008aLP(oModelCY5)
				Endif					
			Endif
		Next
	EndIf   

Return lRet                                
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA008FVL
Rotina de validação da Tela SFCA008FOL

@author Ana Carolina Tomé Klock
@since 28/01/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA008FVL()
	Local lRet := .T.    

	If Empty(cFaixa1)
		SFCMsgErro( STR0036, "SFCA008") //"Mensagem para a Faixa Crítica deve ser informada"
		lRet := .F.
	ElseIf Empty(cFaixa2)
   		SFCMsgErro( STR0037, "SFCA008") //"Mensagem para a Faixa Regular deve ser informada"
		lRet := .F.  
	ElseIf Empty(cFaixa3)
   		SFCMsgErro( STR0038, "SFCA008") //"Mensagem para a Faixa Melhor deve ser informada"
		lRet := .F.
	ElseIf nValor1 == 0
		SFCMsgErro( STR0039, "SFCA008") //"O Limite Final da Faixa deve ser maior que 0"
		lRet := .F.  
	ElseIf nValor2 == 0 
		SFCMsgErro( STR0040, "SFCA008") //"O Limite Final da Faixa 2 deve ser maior que 0"
		lRet := .F.
	ElseIf nValor2 <= nValor1                                 
		SFCMsgErro( STR0041, "SFCA008") //"O Limite Final da Faixa 2 deve ser maior que o Limite Inicial"
		lRet := .F.
	Else
		RecLock("CY8",.F.)
	   		CY8->CY8_DSMI   := cFaixa1     
	   		CY8->CY8_DSSIMI := cTitulo1  
	   		CY8->CY8_DSMSMI := cDescri1 
	   		CY8->CY8_DSXA   := cFaixa2    
	   		CY8->CY8_DSSIXA := cTitulo2  
	   		CY8->CY8_DSMSXA := cDescri2  
	   		CY8->CY8_DSMX   := cFaixa3     
	   		CY8->CY8_DSSIMX := cTitulo3  
	   		CY8->CY8_DSMSMX := cDescri3 
	   		CY8->CY8_VLPNMI := nValor1   
	   		CY8->CY8_VLPNMX := nValor2
	   		CY8->CY8_DTVDBG := dDtVdBg
	   		CY8->CY8_DTVDED := dDtVdEd                
	   	MsUnlock()
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA008aPS
Rotina de validação do grid da tabela CY5

@param   oModelGrid        Model do grid da tabela

@author Tiago Gauziski
@since 28/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA008aPS (oModelGrid)
Local lRet          := .T.
Local nI			:= 0
Local dDataBGAnt	:= CTOD("31/12/9999")
Local oModel        
Local oModelCY5     	  
Local cMaq			:= ''
Local dRegistro     
Local cData         := ''
Local aArea         := GetArea()
Local aAreaCZ4      := CZ4->(GetArea())
Default lAutomacao 	:= .F.

If !lAutomacao
	oModel        := oModelGrid:GetModel( 'VIEW_CY5' )
	oModelCY5     := oModel:GetModel("CY5DETAIL")	  

	// Calcular final dos registros
	If oModelCY5:Length() > 0
		For nI := 1 To oModelCY5:Length()
			oModelCY5:GoLine(nI)
			cMaq       := oModelCY5:GetValue('CY5_CDMQ')
			dDataBGAnt := CTOD("31/12/9999")
			dRegistro  := oModelCY5:GetValue('CY5_DTBGRE')
		
			If oModelCY5:IsDeleted(nI)
				dbSelectArea("CZ4")
				cQueryCZ4 := "SELECT CZ4_DTRE FROM " + RetSQLName("CZ4") + " CZ4 WHERE CZ4_IDMEPO = '" + FwFldGet('CY5_IDMEPO') + "' AND D_E_L_E_T_=' ' ORDER BY CZ4_DTRE DESC"
   				cCZ4 := GetNextAlias()                                                      	  		
				dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQueryCZ4), cCZ4, .T., .F. ) 
				If (cCZ4)->(!EOF())                                          
					cData := DTOC(STOD(CZ4_DTRE))
					(cCZ4)->(dbSkip())
				EndIf
				If !Empty(cData)
					If ApMsgYesNo( STR0069 + ALLTRIM(cMaq) + STR0070 ) // "Deseja remover máquina " ### " e seus componentes/indicadores relacionados?" 
   			   			DelRelation( 'CY8', FwFldGet('CY5_IDMEPO'), "IDMEPO" )
   			  			DelRelation( 'CY4', FwFldGet('CY5_IDMEPO'), "IDMEPO" )
   			  			DelRelation( 'CZ4', FwFldGet('CY5_IDMEPO'), "IDMEPO" ) 
   			  			DelRelation( 'CZ5', FwFldGet('CY5_IDMEPO'), "IDMEPO" ) 
   			  			DelRelation( 'CYS', FwFldGet('CY5_IDMEPO'), "IDMEPO" )
            		Else                                                      
               			SFCMsgErro( STR0071 + ALLTRIM(cMaq) + STR0072 + cData, "SFCA008" ) // "Para máquina " ### ", a última data calculada foi: "                     
            	    	lRet := .F.
            		EndIf
				EndIf
				cData := ''
			EndIf
		Next 
	EndIf
EndIf

RestArea(aAreaCZ4)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA008aLp
Rotina de validação do grid da tabela CY5

@param   oModelGrid        Model do grid da tabela

@author Tiago Gauziski
@since 28/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA008aLP (oModelGrid)                                    
Local lRet          := .T.
Local lExistComp    := .F.
Local lDataForaAlt  := .F.
Local nHorasComp    := 0
Local oModel        
Local oModelCYS     
Local oModelCY5     
Local nI            := 0   
Local nJ            := 0
Local cCDTN         := SFCTurnoMaq(FwFldGet('CY5_CDMQ'),FwFldGet('CY5_DTBGRE'))  
Default lAutomacao 	:= .F. 

If !lAutomacao
	oModel        := oModelGrid:GetModel( 'VIEW_CY5' )
	oModelCYS     := oModel:GetModel("CYSDETAIL")
	oModelCY5     := oModel:GetModel("CY5DETAIL")
EndIf

FwFldPut('CY5_NRTN', Replicate( "0", len(FwFldGet('CY5_NRTN'))-len(AllTrim(FwFldGet('CY5_NRTN'))) ) + AllTrim( FwFldGet('CY5_NRTN') ))
FWFldPut('CY5_DTEDRE', FwFldGet('CY5_DTEDRE'))
                                                                                                                                               
If Empty(FwFldGet('CY5_DTBGRE'))
	SFCMsgErro( STR0042, "SFCA008") // 'É necessário informar a Data Inicial'
	lRet := .F.
EndIf

// Verificar se turno inicia de acordo com tipo
Do Case
	Case FwFldGet('CYU_TPME') == '2' // Semanal
		if DOW(FwFldGet('CY5_DTBGRE')) != 1
   			SFCMsgErro( STR0046, "SFCA008") // 'Quando meta Semanal, data de início deve ser um Domingo'
			lRet := .F.
   		Endif
    Case FwFldGet('CYU_TPME') == '3' // Mensal
    	if DAY(FwFldGet('CY5_DTBGRE')) != 1
    		SFCMsgErro( STR0047, "SFCA008") // 'Quando meta Mensal, data de início deve ser dia 1'
   			lRet := .F.
		Endif
End Case    

If !lAutomacao	
	For nI := 1 To oModelCY5:GetQtdLine()-1
		oModelCY5:GoLine(nI)
		cMaq       := oModelCY5:GetValue('CY5_CDMQ')
		dDataBGAnt := CTOD("31/12/9999")
		dRegistro  := oModelCY5:GetValue('CY5_DTBGRE')
	
		If !oModelCY5:IsDeleted(nI)
			For nJ := 1 To oModelCY5:Length()
				If nI != nJ					
					oModelCY5:GoLine(nJ)
					If !oModelCY5:IsDeleted(nJ) .AND. oModelCY5:GetValue('CY5_CDMQ') == cMaq
						If oModelCY5:GetValue('CY5_DTBGRE') > dRegistro .And. dDataBGAnt > oModelCY5:GetValue('CY5_DTBGRE')
							dDataBGAnt := oModelCY5:GetValue('CY5_DTBGRE')-1
						Endif
					Endif
				EndIf
			Next 
			oModelCY5:GoLine(nI)
			oModelCY5:LoadValue('CY5_DTEDRE',dDataBGAnt)  
		EndIf
	Next      


	If (lRet .AND. oModelCY5:IsUpdated())
		//verifica se data final é maior que data inicial
		If(FwFldGet('CY5_DTBGRE') > FwFldGet('CY5_DTEDRE'))
    		SFCMsgErro( STR0043, "SFCA008") // 'Data Final deve ser maior ou igual que a Data Inicial'
			lRet := .F.
    	ElseIf(!Empty(Val(FwFldGet('CY5_NRTN'))))
    		CYR->(dbSetOrder(1))
			if !CYR->(dbSeek(xFilial('CYR')+cCDTN+FwFldGet('CY5_NRTN')))
				SFCMsgErro( STR0044 + cCDTN, "SFCA008") // 'Número de turno não existe para esta máquina. Modelo Turno: '
   				lRet := .F.
			Else
				For nI := 1 To oModelCYS:GetQtdLine()
    				If(!Empty(Val(FwFldGet('CYS_NRTN'))))
	    				If(FwFldGet('CYS_NRTN', nI) != FwFldGet('CY5_NRTN'))
	    	   				SFCMsgErro( STR0045, "SFCA008") // 'Não é possível alterar turno, pois existe um componente com turno diferente'
			   				lRet := .F.
			   				Exit
	    				EndIf
		    		EndIf
    			Next
			Endif
    	
    		// Verificar se turno inicia de acordo com tipo
    		Do Case
    			Case FwFldGet('CYU_TPME') == '2' // Semanal
    				if DOW(FwFldGet('CY5_DTBGRE')) != 1
    					SFCMsgErro( STR0046, "SFCA008") // 'Quando meta Semanal, data de início deve ser um Domingo'
		   				lRet := .F.
    				Endif
    			Case FwFldGet('CYU_TPME') == '3' // Mensal
    				if DAY(FwFldGet('CY5_DTBGRE')) != 1
    					SFCMsgErro( STR0047, "SFCA008") // 'Quando meta Mensal, data de início deve ser dia 1'
		   				lRet := .F.
    				Endif
    		End Case
    	Else
			For nI := 1 To oModelCYS:GetQtdLine()           
				//verifica se existe componente para esta Meta Maquina
				If(!lExistComp)
					lExistComp := .T.
				EndIf
				nHorasComp := nHorasComp + FwFldGet('CYS_QTTEPL', nI)
				//validação para verificar se existe algum componente fora da faixa de data da Meta Máquina
				If(!Empty(FwFldGet('CYS_DTBGRE', nI)) .And.;
			   	!Empty(FwFldGet('CYS_DTEDRE', nI)))
					If(FwFldGet('CY5_DTBGRE') > FwFldGet('CYS_DTEDRE', nI) .Or.;
				   	FwFldGet('CY5_DTEDRE') < FwFldGet('CYS_DTBGRE', nI))
						lDataForaAlt := .T.
						Exit
					EndIf
				EndIf 
			Next  
			If(lDataForaAlt)
				SFCMsgErro( STR0049, "SFCA008") // 'Existem componentes dentro do período informado'
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA008bLp
Rotina de validação do grid da tabela CYS

@param   oModelGrid        Model do grid da tabela

@author Tiago Gauziski
@since 07/10/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA008bLP (oModelGrid)
Local lRet          := .T.
Local nHorasComp    := 0
Local nI            := 0 
Default lAutomacao  := .F.

If !lAutomacao 
	If (oModelGrid:IsUpdated() .Or. oModelGrid:IsInserted())
		If(!SFCXValDate(FwFldGet('CY5_DTBGRE'), FwFldGet('CY5_DTEDRE'), FwFldGet('CYS_DTBGRE')) .Or.;
	   	!SFCXValDate(FwFldGet('CY5_DTBGRE'), FwFldGet('CY5_DTEDRE'), FwFldGet('CYS_DTEDRE'))) 
			SFCMsgErro( STR0051, "SFCA008") // 'Período de datas do componente precisa ser maior o da Meta Máquina'
  			lRet := .F.   	   
		ElseIf(!Empty(Val(FwFldGet('CYS_NRTN'))) .And. !Empty(Val(FwFldGet('CY5_NRTN'))))
 			If(FwFldGet('CYS_NRTN') != FwFldGet('CY5_NRTN'))
   				SFCMsgErro( STR0052, "SFCA008") // 'Não é possível alterar componente, pois a máquina está com um turno diferente'
   				lRet := .F.   		
   			EndIf		
		EndIf
		If(FwFldGet('CYS_QTTEPL') > 0)
			For nI := 1 To oModelGrid:GetQtdLine()
				nHorasComp := nHorasComp + FwFldGet('CYS_QTTEPL', nI)		
			Next			
	    	If(nHorasComp > FwFldGet('CY5_QTTEPL'))
	    		SFCMsgErro( STR0053, "SFCA008") // 'Quantidade de Horas Planejada dos componentes não pode ser superior a quantidade de horas usada pela Meta Máquina'
				lRet := .F. 		
	    	EndIf
		EndIf
	EndIf 
EndIf
                            
Return (lRet)  

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA008P
Rotina para abrir a tela de perguntas SFCA008 e caso válido,
efetuar processamento de importação de componentes

@param   lExibe        Variável lógica para definir se é para abrir a tela de perguntas

@author Tiago Gauziski
@since 07/10/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA008P(lExibe)
Local cQuery    := ""
Local cCDCETR   := ""
Local aArea     := GetArea()
Local aAreaCYS  := CYS->(GetArea())
Local cPergunte := "SFCA008"
Local iIntegSFC := SFCIntegra()

If(Empty(CYU->CYU_CDMEPO))
	SFCMsgErro( STR0054, "SFCA008") // 'Não existe nenhuma Meta cadastrada'
ElseIf(Empty(CY5->CY5_IDMEPO))
	SFCMsgErro( STR0055, "SFCA008") // 'Não existe nenhuma Máquina da Meta de Produção cadastrada'
Else
	If iIntegSFC == 1
		cPergunte := "SFCA008PCP"
	EndIf
    
	If Pergunte( cPergunte, lExibe )    
		cCDMQ := CY5->CY5_CDMQ
		cCDCETR := POSICIONE("CYB",1,XFILIAL("CYB")+cCDMQ, "CYB_CDCETR")                                 
		
		DbSelectArea("CYS")
		dbSeek( xFilial("CYS") + CY5->CY5_IDMEPO )
		
		// No caso de reimportacao, apaga as ordens ja incorporadas..                                   
		If (iIntegSFC == 1 .AND. MV_PAR16 == 1) .OR.;
		   (iIntegSFC == 2 .AND. MV_PAR38 == 1)
			Do While CYS->(!Eof())
			   	DBRLock(Recno()) 
				DBDelete() 
				MsUnlock()
				dbSkip()
			Enddo
		Else
		    Do While CYS->(!Eof())   		
		   		cNrOrPo := Posicione("CYY",1,XFILIAL("CYY")+CYS->CYS_NRORPO+CYS->CYS_IDAT+CYS->CYS_IDATQO, "CYY_NRORPO")
		   		cIdAtQo := Posicione("CYY",1,XFILIAL("CYY")+CYS->CYS_NRORPO+CYS->CYS_IDAT+CYS->CYS_IDATQO, "CYY_IDATQO")
		   		cIdAt 	:= Posicione("CYY",1,XFILIAL("CYY")+CYS->CYS_NRORPO+CYS->CYS_IDAT+CYS->CYS_IDATQO, "CYY_IDAT")
		    	If (CYS->CYS_TPMV = '2' .And. CYS->CYS_NRORPO = cNrOrPo .And. CYS->CYS_IDAT = cIdAt .And. CYS->CYS_IDATQO = cIdAtQo)
			    	DBRLock(Recno()) 
			   		DBDelete() 
			   		MsUnlock()
			    EndIf 
			    dbSkip()
			Enddo
		EndIf   
		
		IF iIntegSFC == 1 // Pergunte SFCA008PCP
			// Aplicar o filtro escolhido, e cadastrar nas metas de produção as ordens encontradas
			cQuery := "SELECT CYY.CYY_NRORPO,CYY.CYY_IDATQO,CYY.CYY_IDAT,CYY.CYY_DTIMC,CYY.CYY_DTFMC,CYY.CYY_HRIMC," 
			cQuery += "       CYY.CYY_HRFMT,CYY.CYY_QTAT,CYY.CYY_QTPASU,CYY.CYY_QTTEPP,CYY_QTPAPP, CYY_CDCETR, CYY_CDMQ "
			cQuery += "FROM " + RetSQLName( 'CYY' ) + " CYY " 
			cQuery += "INNER JOIN " + RetSQLName( 'CYQ' ) + " CYQ ON CYY.CYY_FILIAL = CYQ.CYQ_FILIAL AND CYY.CYY_NRORPO = CYQ.CYQ_NRORPO AND CYQ.D_E_L_E_T_ = ' ' "
			cQuery += "WHERE CYQ.CYQ_FILIAL  = '" + xFilial('CYQ') + "' AND "
			cQuery += "		 CYQ.CYQ_NRORPO >= '" + MV_PAR01 + "' AND CYQ.CYQ_NRORPO <= '" + MV_PAR02 + "' AND " //ordem de produção de...até
			cQuery += "	     CYQ.CYQ_CDDP   >= '" + MV_PAR03 + "' AND CYQ.CYQ_CDDP   <= '" + MV_PAR04 + "' AND " //depósito de...até
			cQuery += "      CYQ.CYQ_CDAC   >= '" + MV_PAR05 + "' AND CYQ.CYQ_CDAC   <= '" + MV_PAR06 + "' AND " //item de...até
			cQuery += "      CYQ.CYQ_CDFA   >= '" + MV_PAR07 + "' AND CYQ.CYQ_CDFA   <= '" + MV_PAR08 + "' AND " //familia de...até
			cQuery += "      CYQ.CYQ_CDGE   >= '" + MV_PAR09 + "' AND CYQ.CYQ_CDGE   <= '" + MV_PAR10 + "' AND " //grupo de estoque de...até
			cQuery += "      CYQ.CYQ_DTBGOR >= '" + DTOS(MV_PAR11) + "' AND CYQ.CYQ_DTEDOR <= '" + DTOS(MV_PAR12) + "'" //inicio fim ordem de...até
			/*###########SITUAÇÃO ORDEM###########*/
			If(MV_PAR13 == 1)
				cQuery += " OR  CYQ.CYQ_TPSTOR = '1'  " //não iniciada 
			EndIf    
			If(MV_PAR14 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPSTOR = '6'  " // iniciada
		 	EndIf
		 	If(MV_PAR15 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPSTOR = '7'  " // finalizada
		 	EndIf
		 	cQuery += "  AND   CYQ.D_E_L_E_T_ = ' ' ORDER BY CYY.CYY_DTIMC, CYY.CYY_HRIMC"
		Else
			// Aplicar o filtro escolhido, e cadastrar nas metas de produção as ordens encontradas
			cQuery := "SELECT CYY.CYY_NRORPO,CYY.CYY_IDATQO,CYY.CYY_IDAT,CYY.CYY_DTIMC,CYY.CYY_DTFMC,CYY.CYY_HRIMC," 
			cQuery += "       CYY.CYY_HRFMT,CYY.CYY_QTAT,CYY.CYY_QTPASU,CYY.CYY_QTTEPP,CYY_QTPAPP, CYY_CDCETR, CYY_CDMQ "
			cQuery += "FROM " + RetSQLName( 'CYY' ) + " CYY " 
			cQuery += "INNER JOIN " + RetSQLName( 'CYQ' ) + " CYQ ON CYY.CYY_FILIAL = CYQ.CYQ_FILIAL AND CYY.CYY_NRORPO = CYQ.CYQ_NRORPO AND CYQ.D_E_L_E_T_ = ' ' "
			cQuery += "WHERE CYQ.CYQ_FILIAL  = '" + xFilial('CYQ') + "' AND "
			cQuery += "		 CYQ.CYQ_NRORPO >= '" + MV_PAR01 + "' AND CYQ.CYQ_NRORPO <= '" + MV_PAR02 + "' AND " //ordem de produção de...até
		   	cQuery += "	     CYQ.CYQ_CDES   >= '" + MV_PAR03 + "' AND CYQ.CYQ_CDES   <= '" + MV_PAR04 + "' AND " //estabelecimento de...até
			cQuery += "	     CYQ.CYQ_CDLIPO >=  " + STR(MV_PAR05) + "  AND CYQ.CYQ_CDLIPO <=  " + STR(MV_PAR06) + "  AND " //linha de produção de...até
			cQuery += "	     CYQ.CYQ_CDDP   >= '" + MV_PAR07 + "' AND CYQ.CYQ_CDDP   <= '" + MV_PAR08 + "' AND " //depósito de...até
			cQuery += "	     CYQ.CYQ_CDUSPL >= '" + MV_PAR09 + "' AND CYQ.CYQ_CDUSPL <= '" + MV_PAR10 + "' AND " //planejador de...até
			cQuery += "      CYQ.CYQ_CDAC   >= '" + MV_PAR11 + "' AND CYQ.CYQ_CDAC   <= '" + MV_PAR12 + "' AND " //item de...até
			cQuery += "      CYQ.CYQ_CDFA   >= '" + MV_PAR13 + "' AND CYQ.CYQ_CDFA   <= '" + MV_PAR14 + "' AND " //familia de...até
			cQuery += "      CYQ.CYQ_CDGE   >= '" + MV_PAR15 + "' AND CYQ.CYQ_CDGE   <= '" + MV_PAR16 + "' AND " //grupo de estoque de...até
			cQuery += "      CYQ.CYQ_CDUNNG >= '" + MV_PAR17 + "' AND CYQ.CYQ_CDUNNG <= '" + MV_PAR18 + "' AND " //familia de...até
			cQuery += "      CYQ.CYQ_DTBGOR >= '" + DTOS(MV_PAR19) + "' AND CYQ.CYQ_DTEDOR <= '" + DTOS(MV_PAR20) + "'" //inicio fim ordem de...até
			/*###########SITUAÇÃO ORDEM###########*/
			If(MV_PAR21 == 1)
				cQuery += " OR  CYQ.CYQ_TPSTOR = '1'  " //não iniciada 
			EndIf    
			If(MV_PAR22 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPSTOR = '4'  " // separada
		 	EndIf
		 	If(MV_PAR23 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPSTOR = '8'  " // terminada
		 	EndIf
			If(MV_PAR24 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPSTOR = '6'  " // iniciada
		 	EndIf
		 	If(MV_PAR25 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPSTOR = '2'  " // liberada 
		 	EndIf
		 	If(MV_PAR26 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPSTOR = '7'  " // finalizada
		 	EndIf
		 	If(MV_PAR27 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPSTOR = '3'  " // alocada
		 	EndIf
		 	If(MV_PAR28 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPSTOR = '5'  " // requisitada
		 	EndIf
		 	/*###########TIPO ORDEM###########*/
		 	If(MV_PAR29 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPORPO = '1'  " // interna
		 	EndIf
		 	If(MV_PAR30 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPORPO = '3'  " // interna/externa
		 	EndIf
		 	If(MV_PAR31 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPORPO = '2'  " // externa
		 	EndIf
		 	If(MV_PAR32 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPORPO = '8'  " // ferramentaria
		 	EndIf
		 	If(MV_PAR33 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPORPO = '6'  " // manutenção
		 	EndIf
		 	If(MV_PAR34 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPORPO = '5'  " // concerto
		 	EndIf
		 	If(MV_PAR35 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPORPO = '4'  " // retrabalho
		 	EndIf
		 	If(MV_PAR36 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPORPO = '9'  " // reaproveitamento
		 	EndIf
		 	If(MV_PAR37 == 1) 
		   		cQuery += " OR  CYQ.CYQ_TPORPO = '7'  " // ativo fixo
		 	EndIf
			cQuery += "  AND   CYQ.D_E_L_E_T_ = ' ' ORDER BY CYY.CYY_DTIMC, CYY.CYY_HRIMC"
		Endif
		
		cTmp := GetNextAlias()
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. ) 

		While (cTmp)->(!EOF()) 
			If (CY5->CY5_CDMQ == (cTmp)->CYY_CDMQ) .Or. ( Empty((cTmp)->CYY_CDMQ) .And. cCDCETR == (cTmp)->CYY_CDCETR )    
				If (STOD((cTmp)->CYY_DTFMC) >= CY5->CY5_DTBGRE .And. STOD((cTmp)->CYY_DTFMC) <= CY5->CY5_DTEDRE)       
					RecLock("CYS", .T.) //inclusao  
		        	CYS->CYS_FILIAL := xFilial("CYS") // Retorna a filial de acordo com as configurações do ERP
		        	CYS->CYS_NRSQME := GetSXENum("CYS","CYS_NRSQME")  //ARRUMAR A GERAÇÃO DE NÚMERO SEQUENCIAL                                    
		        	CYS->CYS_NRORPO := CYU->CYU_CDMEPO
		        	CYS->CYS_IDMEPO := CY5->CY5_IDMEPO
		        	CYS->CYS_TPMV   := "2" 
		        	CYS->CYS_CDAC   := Posicione("CYQ",1,xFilial("CYQ")+(cTmp)->CYY_NRORPO,"CYQ_CDAC")
		        	CYS->CYS_DSAC   := POSICIONE("CZ3",1,XFILIAL("CZ3")+CYS->CYS_CDAC, "CZ3_DSAC")
		        	CYS->CYS_CDRE   := Posicione("CYQ",1,xFilial("CYQ")+(cTmp)->CYY_NRORPO,"CYQ_CDRE")
		        	CYS->CYS_NRTN   := CY5->CY5_NRTN
		        	CYS->CYS_NRORPO := (cTmp)->CYY_NRORPO
		        	CYS->CYS_IDATQO := (cTmp)->CYY_IDATQO
		        	CYS->CYS_IDAT   := (cTmp)->CYY_IDAT
		        	CYS->CYS_DTBGRE := STOD((cTmp)->CYY_DTIMC)
		        	CYS->CYS_DTEDRE := STOD((cTmp)->CYY_DTFMC)
		        	CYS->CYS_HRBGAT := (cTmp)->CYY_HRIMC
		        	CYS->CYS_HREDAT := (cTmp)->CYY_HRFMT
		        	CYS->CYS_QTPLAT := (cTmp)->CYY_QTAT
		        	CYS->CYS_QTPLUN := (cTmp)->CYY_QTAT
	        		CYS->CYS_QTTEPL := ((cTmp)->CYY_QTPASU + (cTmp)->CYY_QTTEPP + (cTmp)->CYY_QTPAPP) / 3600
	        		CYS->CYS_CDMQ   := CY5->CY5_CDMQ 
	        		MsUnLock() // Confirma e finaliza a operação    
	    		EndIf
        	EndIf  
        	
			(cTmp)->(dbSkip()) 
			//Exit
		End
		(cTmp)->(dbCloseArea()) 		  
	EndIf
EndIf

RestArea(aAreaCYS)
RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA008AP
Rotina para abrir a tela de perguntas SFCA008A e caso válido,
efetuar processamento de geração dos indicadores

@param   lExibe        Variável lógica para definir se é para abrir a tela de perguntas

@author Samantha Preima
@since 05/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA008AP(lExibe)
Local dIni, dFim
Local oDlg, oCombo
Local cMetaIni := PadR("",25)
Local cMetaFim := PadR("",25, "z")
Local dData    := date()
Local cTime	   := time()
Local lSetup       := .T.
Local lExtra       := .T.
Local lParada      := .T.
Local lRefugo  	   := .T.
Local lMail    	   := .F.
Default lAutomacao := .F. 

Define Font oFont Name 'Courier New' Size 0, -12

If !lAutomacao
	Define MsDialog oDlg From 0,0 to 280,415 PIXEL TITLE STR0056 // 'Gerar Indicadores'
    
		tSay():New(10.5,29.5,{|| STR0057 },oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) // 'Meta De:'
		@ 08, 62 MSGET cMetaIni SIZE 90,7 PIXEL OF oDlg WHEN .T.
           
		tSay():New(25.5,29.5,{|| STR0058 },oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) // 'Meta Até:'
		@ 23, 62 MSGET cMetaFim SIZE 90,7 PIXEL OF oDlg WHEN .T.
	
		tSay():New(40.5,29.5,{|| STR0059 },oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) // 'Data:'
		@ 38, 62 MSGET dData SIZE 40,7 PIXEL OF oDlg WHEN .T. 
	 
		tSay():New(55.5,29.5,{|| STR0060 },oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,100,20) // 'Hora:'
		@ 53, 62 MSGET cTime SIZE 20,7 PIXEL OF oDlg WHEN .T. PICTURE "@E 99:99:99"
	
		@ 70,  29.5 Checkbox oTPREP3 Var lParada PROMPT STR0063	Size 200,7 Pixel Of oDlg  // 'Considera Parada altera Eficiência'
		@ 80,  29.5 Checkbox oTPREP4 Var lRefugo PROMPT STR0064 Size 200,7 Pixel Of oDlg  // 'Considera Fator Refugo'
		@ 90,  29.5 Checkbox oTPREP1 Var lExtra  PROMPT STR0061 Size 200,7 Pixel Of oDlg  // 'Considera Tempo Extra como Disponível'
		@ 100, 29.5 Checkbox oTPREP2 Var lSetup  PROMPT STR0062	Size 200,7 Pixel Of oDlg  // 'Considera Preparação altera Eficiência'
		@ 110, 29.5 Checkbox oTPREP5 Var lMail   PROMPT STR0073 Size 200,7 Pixel Of oDlg  // 'Envia E-mail'

		TButton():New(120,120, STR0065 ,oDlg,{|| if(SFCA008OK(cMetaIni,cMetaFim,dData,cTime,lSetup,lExtra,lParada,lRefugo,lMail),oDlg:End(),NIL)},40,10,,,,.T.)
		TButton():New(120,165, STR0066 ,oDlg,{|| oDlg:End() },40,10,,,,.T.)
	
	Activate MsDialog oDlg Centered
EndIf

Return nil

//------------------------------------------------------------------- 
// OK da tela de geração de indicadores
//-------------------------------------------------------------------
Function SFCA008OK (cMetaIni,cMetaFim,dData,cTime,lSetup,lExtra,lParada,lRefugo,lEmail)
Local aArea    := GetArea()
Local aAreaCY5 := CY5->(GetArea())
Local aAreaCYU := CYU->(GetArea())
Local lRet     := .T.
	
if dData > date() .OR. (dData == date() .AND. cTime > time())
	MsgInfo( STR0067 ) // 'Data ou Hora Inválida'
	lRet := .F.
Else
	CY5->(dbCloseArea())
	dbSelectArea('CY5')
    	dbSetOrder(1)
	While CY5->(!EOF())                                            
		if CY5->CY5_CDMEPO >= ALLTRIM(cMetaIni) .AND. CY5->CY5_CDMEPO <= ALLTRIM(cMetaFim) .AND.;
		   CY5->CY5_DTBGRE <= dData    .AND. CY5->CY5_DTEDRE >= dData
		   
			dbSelectArea('CYU')
			CYU->(dbSetOrder(1))
			CYU->(dbGoTop())
			CYU->(dbSeek(xFilial('CYU')+CY5->CY5_CDMEPO))
			
			dFim := dData
		   
			if CYU->CYU_TPME == '1' // Diário                                            
				dIni := dFim
			ElseIf CYU->CYU_TPME == '2' // Semanal
				dIni := if(DOW(dFim)==1,dFim,dFim - (DOW(dFim) - 1))
			Else // Mensal
				dIni := CTOD('01/' + ALLTRIM(STR(MONTH(dFim))) + '/' + ALLTRIM(STR(YEAR(dFim))))
			Endif

			SFCXMETA(CY5->CY5_CDMEPO, CY5->CY5_IDMEPO, CY5->CY5_CDMQ, dIni, dFim, cTime, lSetup, lExtra, lParada, lRefugo, lEmail, CYU->CYU_TPME)
		Endif
	
		CY5->(dbSkip())
	End
Endif

RestArea(aAreaCYU)
RestArea(aAreaCY5)
RestArea(aArea)

Return lRet

//------------------------------------------------------------------- 
//função implementada pelo Ernani
//-------------------------------------------------------------------
Function SFCA008E( nOpera )
	Local aArea    := GetArea()
	Local aAreaCYU := CYU->( GetArea() )
	Local aAreaCY5 := CY5->( GetArea() )
	Local aAreaCYS := CYS->( GetArea() )
	Default lAutomacao := .F.
	                              
	If !lAutomacao
		FWExecView( STR0001,'SFCA008', nOpera,, { || .T. },/*bOk*/)   // 'Metas de Produção'  
		oBrowseUp:Refresh() 
	EndIf
	RestArea( aAreaCYS )
	RestArea( aAreaCY5 )
	RestArea( aAreaCYU )
	RestArea( aArea )    
	//oBrowseUp:GoUp(1)      
	//oBrowseUp:GoDown(1)
	SFCA008REL( CYU->CYU_CDMEPO )    

Return NIL

//------------------------------------------------------------------- 
// gatilho numero turno
//-------------------------------------------------------------------
Function SFCA008DAT()
Local nHoras    := 0
Local cMaquina  := FwFldGet('CY5_CDMQ')
Local cTurno    := FwFldGet('CY5_NRTN')
Local dRefer    := FwFldGet('CY5_DTBGRE')
Local cCDTN     := SFCTurnoMaq(cMaquina,dRefer)
Local aArea     := GetArea()
Local aAreaCYR  := CYR->(GetArea())

dbSelectArea('CYR')
CYR->(dbSetOrder(1))
CYR->(dbGoTop())

If Val(cTurno) == 0	 
	if CYR->(dbSeek(xFilial('CYR')+cCDTN))
		While CYR->(!EOF()) .AND. CYR->CYR_CDTN == cCDTN
			If CYR->CYR_TPTE == '1'				
				nHoras += SFCA311VTP(cCDTN, CYR->CYR_NRDYWK, CYR->CYR_HRBG, CYR->CYR_HRED, 0, 0)[1] / 3600
			EndIf
			CYR->(dbSkip())
		End
	Endif
	
	Do Case 
		Case FwFldGet('CYU_TPME') == '1'
			nHoras := nHoras / 7			
		Case FwFldGet('CYU_TPME') == '3'
			nHoras := nHoras * 4
	End Case
	
Else
	if CYR->(dbSeek(xFilial('CYR')+cCDTN+cTurno))

		While CYR->(!EOF()) .AND. CYR->CYR_CDTN == cCDTN .And. CYR->CYR_NRTN == cTurno 
			If CYR->CYR_TPTE == '1'
				nHoras += SFCA311VTP(cCDTN, CYR->CYR_NRDYWK, CYR->CYR_HRBG, CYR->CYR_HRED, 0, 0)[1] / 3600
			EndIf
			CYR->(dbSkip())
		End
	Endif
	
	Do Case 
		Case FwFldGet('CYU_TPME') == '1'
			nHoras := nHoras / 7			
		Case FwFldGet('CYU_TPME') == '3'
			nHoras := nHoras * 4
	End Case
EndIf

FwFldPut('CY5_QTTEPL', nHoras)

RestArea(aAreaCYR)
RestArea(aArea)

Return nHoras
//-------------------------------------------------------------------
/*/{Protheus.doc} DelRelation
Rotina de remover itens relacionados

@param   cTab		(Obrigatório) Nome da Tabela
@param   xChave     (Obrigatório) Chave para Exclusao
@param   cNomeChave (Obrigatório) Nome da Chave para Exclusao

@author Ana Carolina Tome Klock
@since 23/05/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DelRelation (cTab, xChave, cNomeChave)

	dbSelectArea( cTab )
    dbSeek( xFilial(cTab) + xChave )
    While (cTab)->(!EOF())
    	If (cTab)->&(cTab+"_"+cNomeChave) == xChave
	      	DBRLock()
	        DBDelete()   
	        DBUnlock() 
	    EndIf
        (cTab)->(dbSkip())
    End
    
Return Nil     

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA008REL
Rotina para atualizar relacionamento entre o Browse Superior (CYU) com o Browse Inferior (CY5)

@param  cCDMEPO		(Obrigatório) Meta posicionada no Browse Superior

@author Ana Carolina Tome Klock
@since 20/12/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA008REL( cCDMEPO )
     Default lAutomacao := .F.
     
	 If !lAutomacao
	 	oBrowse:SetFilterDefault("CY5_CDMEPO = '" + cCDMEPO + "'")
     	oBrowse:Refresh()                   
	 EndIf

Return Nil