#INCLUDE 'SFCA102.ch'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#include 'TOTVS.CH'          
#INCLUDE "AP5MAIL.CH"  
#INCLUDE 'FWADAPTEREAI.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA102
Tela de consulta de Manutenção Programada

@author Samantha Preima
@since 22/10/2010
@version P11
/*/
//-------------------------------------------------------------------
Function SFCA102()
Local aCoors := MsAdvSize()
Local oFWLayer
Local oPanelUp 
Local oPanelDown 
Local oDlg
Private oBrowseUp
Private oBrowseDown     
Private cOrdem

Define MsDialog oDlg Title STR0001 From aCoors[7],00 To aCoors[6],aCoors[5] Pixel      // 'Manutenção Programada'

// Cria o conteiner onde serão colocados os browses
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlg, .F., .T. )
                  
// Define Painel Superior
oFWLayer:AddLine( 'UP', 65, .F. )
oFWLayer:AddCollumn( 'UP', 100, .T., 'UP' )
oPanelUp := oFWLayer:GetColPanel( 'UP', 'UP' )
                  
// Cria um FWMarkBrowse Superior para exibir as Paradas Programadas
oBrowseUp:= FWMarkBrowse():New()
oBrowseUp:SetOwner( oPanelUp )
oBrowseUp:SetDescription( STR0002 )  // 'Paradas Programadas'
oBrowseUp:SetMenuDef( 'SFCA102' )
oBrowseUp:SetAlias( 'CZ2' )
oBrowseUp:SetProfileID( '1' )   
oBrowseUp:ForceQuitButton( .T. ) 
oBrowseUp:AddFilter( STR0003, "CZ2_TPSTSP == '1'")  // 'Pendentes'
oBrowseUp:Activate() 
                    
// Define Painel Inferior
oFWLayer:AddLine( 'DOWN', 35, .F. )
oFWLayer:AddCollumn( 'DOWN' ,  100, .T., 'DOWN' )
oPanelDown := oFWLayer:GetColPanel( 'DOWN' , 'DOWN' )
     
// Cria um FWMarkBrowse Inferior para exibir as Paradas Reais
oBrowseDown:= FWMarkBrowse():New()
oBrowseDown:SetOwner( oPanelDown )
oBrowseDown:SetDescription( STR0004 ) // 'Paradas Reais'
oBrowseDown:DisableDetails( .T. )    
oBrowseDown:SetAlias( 'CYX' )    
oBrowseDown:SetProfileID( '2' )  
oBrowseDown:SetMenuDef( '' )       
oBrowseDown:Activate()     
                       
// Cria um relacionamento entre Browses
oRelation := FWBrwRelation():New()
oRelation:AddRelation( oBrowseUp, oBrowseDown, { { 'CYX_FILIAL' , 'xFilial("CYX")' }, { 'CYX_CDMQ', 'CZ2_CDMQ', '=' } } )
oRelation:Activate() 

Activate MsDialog oDlg Center

Return Nil 

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA102' OPERATION 2 ACCESS 0  // 'Visualizar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA102' OPERATION 4 ACCESS 0  // 'Alterar'
ADD OPTION aRotina TITLE STR0007 ACTION 'SFCA102Mud(.T.)' OPERATION 4 ACCESS 0  // 'Aprovar'
ADD OPTION aRotina TITLE STR0008 ACTION 'SFCA102Mud(.F.)' OPERATION 4 ACCESS 0  // 'Rejeitar' 
ADD OPTION aRotina TITLE STR0009 ACTION 'SFCA102Cal()'    OPERATION 2 ACCESS 0  // 'Efetivar'

Return aRotina  

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCZ2 := FWFormStruct( 1, 'CZ2', /*bAvalCampo*/,/*lViewUsado*/ ) // Apontamento de Parada
Local oModel         

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'SFCA102', { |oModel| SFCA102PRE( oModel ) }, { |oModel| SFCA102POS(oModel) }, /*bCommit*/, /*bCancel*/ ) 

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CZ2MASTER', /*cOwner*/, oStruCZ2 )       

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 )    //'Manutenção Programada'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CZ2MASTER' ):SetDescription( STR0001 )  //'Manutenção Programada'

// Define a chave primaria utilizada pelo modelo
oModel:SetPrimaryKey( { 'CZ2_FILIAL', 'CZ2_CDMQ', 'CZ2_NRORMN' } ) 

// Valida se a hora estará disponível para alteração
oModel:SetVldActivate( { |oModel|  SFCA102VAL( oModel ) } )   

Return oModel

//-------------------------------------------------------------------
// View de Apontamento de Parada
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCZ2 := FWFormStruct( 2, 'CZ2' ) 
Local oModel   := FWLoadModel( 'SFCA102' )   
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )    

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CZ2', oStruCZ2, 'CZ2MASTER' )

// Para não reabrir a tela após salvar registro
oView:SetCloseOnOk( { || .T. } )  

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'PAI', 100 ) 

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CZ2', 'PAI' )       

// Caso esteja considerando hora centesimal
If GetMv('MV_SFCTPRE') == '2'            
	oModel:Activate()
	oModel:GetModel('CZ2MASTER'):LoadValue('CZ2_HCBGPL', SFCXHRTOCEN( FwFldGet('CZ2_HRBGPL') ) )
	oModel:GetModel('CZ2MASTER'):LoadValue('CZ2_HCEDPL', SFCXHRTOCEN( FwFldGet('CZ2_HREDPL') ) )
	oStruCZ2:RemoveField('CZ2_HRBGPL')
	oStruCZ2:RemoveField('CZ2_HREDPL')
Else                                                                      
	oStruCZ2:RemoveField('CZ2_HCBGPL')	
	oStruCZ2:RemoveField('CZ2_HCEDPL')	
EndIf

// Impede alteração de campos da chave
oStruCZ2:SetProperty('CZ2_CDMQ'  , MVC_VIEW_CANCHANGE ,.F.)
oStruCZ2:SetProperty('CZ2_NRSQSP', MVC_VIEW_CANCHANGE ,.F.)
oStruCZ2:SetProperty('CZ2_NRORMN', MVC_VIEW_CANCHANGE ,.F.)
oStruCZ2:SetProperty('CZ2_CDSP'  , MVC_VIEW_CANCHANGE ,.F.)
oStruCZ2:SetProperty('CZ2_TPSTSP', MVC_VIEW_CANCHANGE ,.F.)
If IsInCallStack("NGSFCINCPP") .Or. IsInCallStack("NGSFCATPRD")
	oStruCZ2:SetProperty('CZ2_LGMN', MVC_VIEW_CANCHANGE, .T.)
EndIF
	
Return oView     

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA102VAL
Valida se será possível alterar data e hora das paradas

@author Ana Carolina Tome Klock
@since 09/12/2011
@version P11
/*/
//-------------------------------------------------------------------
Function SFCA102VAL( oModel )
      
   	If CZ2->CZ2_TPSTSP != '1'
  		oModel:GetModel('CZ2MASTER'):GetStruct():SetProperty("CZ2_DTBGPL"  , MVC_VIEW_CANCHANGE ,.F.)
  		oModel:GetModel('CZ2MASTER'):GetStruct():SetProperty("CZ2_DTEDPL"  , MVC_VIEW_CANCHANGE ,.F.) 
  		If GetMv('MV_SFCTPRE') == '2' 
	  		oModel:GetModel('CZ2MASTER'):GetStruct():SetProperty("CZ2_HCBGPL"  , MVC_VIEW_CANCHANGE ,.F.)
	  		oModel:GetModel('CZ2MASTER'):GetStruct():SetProperty("CZ2_HCEDPL"  , MVC_VIEW_CANCHANGE ,.F.)  
	  	Else    
	  		oModel:GetModel('CZ2MASTER'):GetStruct():SetProperty("CZ2_HRBGPL"  , MVC_VIEW_CANCHANGE ,.F.)
	  		oModel:GetModel('CZ2MASTER'):GetStruct():SetProperty("CZ2_HREDPL"  , MVC_VIEW_CANCHANGE ,.F.) 
	  	EndIf
  	EndIf  

Return .T.


Function SFCA102PRE( oModel )

  	If oModel:GetOperation() == 4 .And. SuperGetMV("MV_NGMNSFC",.F.,1) != 1 
		oModel:GetModel('CZ2MASTER'):GetStruct():SetProperty("CZ2_DTEDPL"  , 13  ,.T.)                         
  		If GetMv('MV_SFCTPRE') == '2' 
	  		oModel:GetModel('CZ2MASTER'):GetStruct():SetProperty("CZ2_HCEDPL" , 13  ,.T.) 
	  	Else    
	  		oModel:GetModel('CZ2MASTER'):GetStruct():SetProperty("CZ2_HREDPL" , 13  ,.T.) 
	  	EndIf
	EndIF
 
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA102POS
Realiza a pós-validação da tela
                          
@param 	  oModel     (Obrigatório) Modelo da Tela

@author Ana Carolina Tome Klock
@since 09/12/2011
@version P11
/*/
//-------------------------------------------------------------------          
Function SFCA102POS( oModel )
Local lRet  := .T. 

Default lAutomacao := .F.

// Valida a possibilidade de alteração da dada conforme Ordem de Manutenção (SIGAMNT) 
If SFCIntegra() == 1
	If oModel:GetOperation() == 3
	  	If IsInCallStack('MNTA410') .And. SuperGetMV("MV_NGMNSFC",.F.,1) != 1
	  	    dbSelectArea('CYF')
	  	    dbSetOrder(1)
	  	    If CYF->(dbSeek( xFilial('CYF')+FwFldGet('CZ2_CDTN') ) )
				oModel:GetModel('CZ2MASTER'):LoadValue('CZ2_NRTN', CYF->CYF_NRTN )
			EndIf               
		EndIf 
	ElseIf oModel:GetOperation() == 4 .And. !IsInCallStack("NGSFCATPRD")
		lRet := NGSFCPDIS( oModel )
	EndIf
EndIf
		 
// Não permite excluir a parada programada caso já tenha uma parada real relacionada
If oModel:GetOperation() == 5 .Or. lAutomacao
 	dbSelectArea('CYX') 
	dbSetOrder(4)
	If dbSeek( xFilial('CYX') + FwFldGet('CZ2_NRSQSP') ) .Or. lAutomacao
   		SFCMsgErro( STR0010, 'SFCA102') // 'Existe uma Parada Real relacionada a Manutenção Programada, impossibilitando a eliminação do registro'
        lRet := .F.
	EndIf          
EndIf
    
Return lRet   

//-------------------------------------------------------------------
// Busca o número de parada programada com base na ordem de manutenção
// passada como parâmetro
//-------------------------------------------------------------------
Function SFCA102BPR(cFil,cOrdMnt)
Local cNRSQSP  := ''
Local aArea    := GetArea()
Local aAreaCZ2 := CZ2->(GetArea())

Default lAutomacao := .F.

dbSelectArea('CZ2')
CZ2->(dbSetOrder(4))
If CZ2->(dbSeek(cFil+cOrdMnt)) .Or. lAutomacao
	cNRSQSP := CZ2->CZ2_NRSQSP
Endif

RestArea(aArea)
RestArea(aAreaCZ2)

Return cNRSQSP   

//-------------------------------------------------------------------
// Busca de sequencia para nova parada programada
//-------------------------------------------------------------------
Function SFCA102NR(cFILIAL,cCDMQ)
Local cSequencia := ''
Local nTamanho   := TamSX3('CZ2_NRSQSP')[1] 
Local nCount 	 := 0
Local aArea      := GetArea()

Default lAutomacao := .F.
                  
If SFCIntegra() == 1 .And. Empty(cCDMQ)
	cCDMQ := ST9->T9_RECFERR
EndIf

dbSelectArea('CZ2')
dbSetOrder(1)
If CZ2->(dbSeek(cFilial+cCDMQ)) .Or. lAutomacao
	While CZ2->(!EOF()) .Or. lAutomacao
		If AllTrim(CZ2->CZ2_CDMQ) == AllTrim(cCDMQ)
			nCount := Val( CZ2->CZ2_NRSQSP )
		EndIf
		IF lAutomacao
			EXIT
		ENDIF
		CZ2->(dbSkip())
	End
	nTamanho   -= Len( AllTrim( Str( nCount + 1 ) ) ) 
	cSequencia := Replicate('0', nTamanho) + AllTrim( Str( nCount + 1 ) )
Else
	cSequencia := Replicate('0', nTamanho-1) + '1'   
EndIf

RestArea( aArea )

Return cSequencia 

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA102Mud
Muda o estado da parada
                          
@param 	  lMuda     (Obrigatório) Tipo de operacao (.T. para Aprovar e .F. para Reprovar)

@author Ana Carolina Tome Klock
@since 09/12/2011
@version P11
/*/
//-------------------------------------------------------------------
Function SFCA102Mud(lMuda)  
	Local cCDMQ    := CZ2->CZ2_CDMQ                
	Local cNRSQSP  := CZ2->CZ2_NRSQSP        
	Local cPara    := Posicione('CYB',1,xFilial('CYB')+cCDMQ, 'CYB_CDCETR')
	Local cPara	   := AllTrim(Posicione('CYI',1,xFilial('CYI')+cPara,'CYI_DSELUS'))
	Local aReturn  := {} 
	Local cAssunto := STR0011 // "Parada Programada Rejeitada no SFC"
	Local cMsg     := STR0012 + AllTrim(cCDMQ) + STR0013 + cNRSQSP + STR0014  // "A parada programada para a máquina " ### " com sequência " ### " foi reprovada no Módulo Chão de Fábrica."
	
	Default lAutomacao := .F.
	
	If Empty(cPara)
		cPara := SuperGetMV("MV_SFCMAIL",.F.,'')
	EndIf    
	 
	dbSelectArea('CZ2') 
	dbSetOrder(1)
	dbSeek(xFilial('CZ2')+cCDMQ+cNRSQSP)
	While CZ2->(!EOF()) .Or. lAutomacao
	    If ( (AllTrim(CZ2->CZ2_CDMQ) == AllTrim(cCDMQ)) .And. (AllTrim(CZ2->CZ2_NRSQSP) == AllTrim(cNRSQSP)) .And. (AllTrim(CZ2->CZ2_TPSTSP) == '1') ) .Or. lAutomacao
			If IIF(!lAutomacao, ApMsgYesNo( STR0015 ), .T.) // 'Deseja alterar o estado da parada?' 
		    	IF !lAutomacao  
					RecLock("CZ2",.F.)
					If lMuda
						CZ2->CZ2_TPSTSP := '2'
					Else					
						Define MsDialog	oDlg Title STR0016 FROM 00,00 To 470,500 Pixel //'Compor Mensagem'
						TSay():New( 010, 015, { || STR0017 }, oDlg, , , , , , .T., CLR_BLACK, CLR_WHITE )     // 'Assunto: '
						TGet():New( 018, 015, { |u| If (Pcount()>0, cAssunto := u, cAssunto ) }, oDlg, 150, 7, , {||}, , , , , , .T., , ,{||} , , ,{||}, .F., , , cAssunto )
						TSay():New( 032, 015, { || STR0018 }, oDlg, , , , , , .T., CLR_BLACK, CLR_WHITE ) 	  // 'Mensagem: '
						oText := TSimpleEditor():New( 040, 015, oDlg, 200, 150, , .F. )                        
						oText:Load( cMsg )
						Activate MsDialog oDlg Centered On Init EnchoiceBar( oDlg, { || oDlg:End() }, { || oDlg:End() } )
						
						aReturn := NGSFCMAIL( cPara, cAssunto, cMsg ) 
						If aReturn[1]
							CZ2->CZ2_TPSTSP := '3'
						EndIf
						SFCMsgErro( aReturn[2], 'SFCA102' )   
					EndIf                 
					MsUnlock()                                      
		    	ENDIF
		    EndIf  
		ElseIf (AllTrim(CZ2->CZ2_CDMQ) == AllTrim(cCDMQ)) .And. (AllTrim(CZ2->CZ2_NRSQSP) == AllTrim(cNRSQSP)) .And. (AllTrim(CZ2->CZ2_TPSTSP) == '2') .And. !lMuda
			SFCMsgErro( STR0019, 'SFCA102' )  // 'Não é possível rejeitar uma parada aprovada'     
		ElseIf (AllTrim(CZ2->CZ2_CDMQ) == AllTrim(cCDMQ)) .And. (AllTrim(CZ2->CZ2_NRSQSP) == AllTrim(cNRSQSP)) .And. (AllTrim(CZ2->CZ2_TPSTSP) == '3') .And. !lMuda
			SFCMsgErro( 'Parada já foi rejeitada', 'SFCA102' )	 
		ElseIf (AllTrim(CZ2->CZ2_CDMQ) == AllTrim(cCDMQ)) .And. (AllTrim(CZ2->CZ2_NRSQSP) == AllTrim(cNRSQSP)) .And. (AllTrim(CZ2->CZ2_TPSTSP) == '2') .And. lMuda
			SFCMsgErro( 'Parada já foi aprovada', 'SFCA102' )  
		ElseIf (AllTrim(CZ2->CZ2_CDMQ) == AllTrim(cCDMQ)) .And. (AllTrim(CZ2->CZ2_NRSQSP) == AllTrim(cNRSQSP)) .And. (AllTrim(CZ2->CZ2_TPSTSP) == '3') .And. lMuda
			If ApMsgYesNo( STR0015 ) // 'Deseja alterar o estado da parada?' 
		    	RecLock("CZ2",.F.)
		    	CZ2->CZ2_TPSTSP := '2'   
				MsUnlock()
			EndIf                  
	    EndIf 
		IF lAutomacao
			EXIT
		ENDIF     
		CZ2->(dbSkip())
    End        
    
	IF !lAutomacao
    	oBrowseUp:Refresh()
	ENDIF

Return Nil    

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA102CAL
Valida se a parada já foi aprovada e efetiva a parada

@author Ana Carolina Tome Klock
@since 09/12/2011
@version P11
/*/
//-------------------------------------------------------------------
Function SFCA102Cal()
 	Local aArea      := GetArea()
	Local aAreaCZ2   := CZ2->( GetArea() )
    Private lSFCA102 := .T.

	Default lAutomacao := .F.           
                               
    If CZ2->CZ2_TPSTSP == '1'
    	RecLock("CZ2",.F.)
		CZ2->CZ2_TPSTSP := '2'
		MsUnlock()
	ElseIf CZ2->CZ2_TPSTSP == '3'
		SFCMsgErro( STR0020, 'SFCA102' ) // "Não é possível efetivar uma parada rejeitada"  
		Return Nil
	EndIf         
	
    oModel:= FwLoadModel('SFCA311') 
    oModel:SetOperation(3)
    oModel:Activate()
    oModel:SetValue("CYXMASTER", "CYX_FILIAL", xFilial("CYX") )
    oModel:SetValue("CYXMASTER", "CYX_CDMQ"  , CZ2->CZ2_CDMQ  )
    oModel:SetValue("CYXMASTER", "CYX_NRSQSP", CZ2->CZ2_NRSQSP)
    oModel:SetValue("CYXMASTER", "CYX_NRORMN", CZ2->CZ2_NRORMN)
    oModel:SetValue("CYXMASTER", "CYX_CDSP"  , CZ2->CZ2_CDSP  )
    oModel:SetValue("CYXMASTER", "CYX_DTBGSP", CZ2->CZ2_DTBGPL)
    oModel:SetValue("CYXMASTER", "CYX_HRBGSP", CZ2->CZ2_HRBGPL)
    oModel:SetValue("CYXMASTER", "CYX_DTEDSP", CZ2->CZ2_DTEDPL)
    oModel:SetValue("CYXMASTER", "CYX_HREDSP", CZ2->CZ2_HREDPL)
    
	IF !lAutomacao
		FWExecView('','SFCA311', MODEL_OPERATION_INSERT,,{ || .T. }, /*bOk*/,,, /*bCancel*/,,, oModel )
	ENDIF

	RestArea( aAreaCZ2 )
	RestArea( aArea )                                                                      

Return Nil           

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCNGMAIL
Função para envio de e-mail.

@param cPara        Lista dos destinatários da mensagem
@param cAssunto		Assunto do email
@param cMensagem 	Corpo do email 
@param lMsg         Indica se mostra mensagem de erro 

@author Ana Carolina Tome Klock
@since 13/02/2012
@version 1.0
/*/
//------------------------------------------------------------------- 
Function SFCNGMAIL(cOrdServ, cAssunto, cMsg)
Local lResulConn := .T.
Local lResulSend := .T.   
Local lConnect   := .T.
Local lRet       := .T.
Local cError     := ""    
Local cPara		 := Posicione( 'CZ2', 4, xFilial('CZ2')+cOrdServ, 'CZ2_CDMQ')
Local cPara      := Posicione('CYB',1,xFilial('CYB')+cPara, 'CYB_CDCETR')
Local cPara	     := AllTrim(Posicione('CYI',1,xFilial('CYI')+cPara,'CYI_DSELUS'))     

Local cFrom    	:= GetMV("MV_RELACNT")  // Conta do Remetente - o cliente receberá o email com este rementente - naoresponda@sfc.com.br 
Local lAuth     := GetMV("MV_RELAUTH")  // Servidor de EMAIL necessita de Autenticacao? - .F.
Local cContAuth := GetMV("MV_RELACNT")  // Conta do Remetente - se fizer autenticação, ele precisa de uma variável a mais para o remetente para alterar.
Local cPswAuth  := GetMV("MV_RELAPSW")  // Senha para autenticacäo no servidor de e-mail - em branco

Default lAutomacao := .F.
    
   	CONNECT SMTP SERVER GetMV("MV_RELSERV") ACCOUNT GetMV("MV_RELACNT") PASSWORD GetMV("MV_RELPSW") RESULT lConnect
    
    If lConnect .Or. lAutomacao
   
		If Empty(cPara)
			cPara := SuperGetMV("MV_SFCMAIL",.F.,'')
		EndIf
	
		If !lResulConn
			Get MAIL ERROR cError
			DISCONNECT SMTP SERVER
			Return  { .F., STR0021 + AllTrim(cError) } // "Falha na conexão com o servidor: "
		Endif                
		
		If lAuth .Or. lAutomacao
			// Primeiro tenta fazer a Autenticacao de E-mail utilizando o e-mail completo
			If ! ( lRet := MailAuth( cContAuth, cPswAuth ) )
				// Se nao conseguiu fazer a Autenticacao usando o E-mail completo, tenta fazer
				// a autenticacao usando apenas o nome de usuario do E-mail, sem o @..
				If !lRet
					nA        := At( '@', cContAuth )
					cContAuth := If( nA > 0, SubStr( cContAuth, 1, nA - 1), cContAuth )
					If !( lRet  := MailAuth( cContAuth, cPswAuth ) )
						IF !lAutomacao
							Return  { .F., STR0022 + AllTrim(cContAuth) } // "Falha ao atenticar conta: "
						ENDIF
					EndIf
		
				EndIf
			EndIf
		EndIf
		
		// Realiza o envio do e-mail
		SEND MAIL FROM cFrom TO cPara SUBJECT cAssunto BODY cMsg RESULT lResulSend
		
		If !lResulSEND 
			Get MAIL ERROR cError		 
			DISCONNECT SMTP SERVER                                                                                                
		   	Return { .F., STR0023 + AllTrim(cError) } // "Falha ao enviar e-mail: "
		Else      
	   		DISCONNECT SMTP SERVER
			Return { .T., STR0023 } // "E-mail enviado com sucesso"
		EndIf
		
	EndIf
	
	
Return { .F., STR0025 } // "Falha na conexão com o banco"  
                                                           
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCNGVCAL
Função para validação da existência do Turno

@param    cCDTN   Calendário do Protheus/Turno do Chão de Fábrica

@author Ana Carolina Tome Klock
@since 04/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCNGVCAL( cCDTN )
Local lRet := .T.           

	dbSelectArea('CYF')
	dbSetOrder(1)
	If !(CYF->(dbSeek( xFilial('CYF')+cCDTN ) ))
		SFCMsgErro('Número de turno inexistente no módulo Chão de Fábrica','SFCA102')
		lRet := .F.
	EndIf  

Return lRet

//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local lRet     := .T.
Local lFound 
Local cXMLRet  := ""    
Local oXML
Local oBusinessContent
Local oBusinessEvent
Local nOpc := 3
Local oModel
Local aArea    := GetArea()
Local aAreaCZ2 := CZ2->(GetArea())

Default lAutomacao := .F.

IF !lAutomacao   
	If nTypeTrans == TRANS_SEND .And. IsInCallStack('CARGADTS_SFC')
		//ConOut('Envio a partir do programa de carga, ignorando...')
		Return { .T., 'Envio ignorado.' }
	EndIf
ENDIF

// Se mensagem for de Recebimento  
If IIF( !lAutomacao, nTypeTrans == TRANS_RECEIVE, .T.)

	//Conout( '****************' )
	//Conout( '+ IntegDef SFCA102' ) 
	//Conout( '****************' )
	//Conout( FwNoAccent(cXML) )
	//Conout( '****************' )

	
	//  Se mensagem for de Negócio	
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		//conout( '+ IntegDef SFCA102 Recebendo Mensagem Business' )
		
		cError := ''
		cWarning := '' 
		
		// Cria um objeto XML a partir da estutura dos dados do Model
		oXML := XmlParser(FwNoAccent(cXML), "_", @cError, @cWarning) 
											
		lValid := .F.
		
		If XmlChildEx(oXML, '_TOTVSMESSAGE') != NIL
			oBusinessContent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
			oBusinessEvent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_EVENT:TEXT   
			
			lValid := .T.
		ElseIf XmlChildEx(oXML, '_BUSINESSCONTENT') != NIL
			oBusinessContent = oXML:_BusinessContent
			oBusinessEvent = EAI_EVENT_UPSERT   
			
			lValid := .T.
		EndIf
		
		If lValid == .F.
			IF !lAutomacao
				Return { lValid, 'Não foi enviada uma mensagem válida.' }
			ENDIF	
		EndIf
				
		// Instancia o modelo	
		oModel := FWLoadModel( 'SFCA102' )
			
		// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
		dbSelectArea('CZ2')
		CZ2->(dbSetOrder(1))
		IF !lAutomacao
			lFound := CZ2->(dbSeek(xFilial('CZ2') + PadR(oBusinessContent:_MachineCode:TEXT, Len(CZ2->CZ2_CDMQ)) + oBusinessContent:_Sequence:TEXT))
			
			// Verifica se a mensagem é de Inclusão/Alteração
			If UPPER(oBusinessEvent) == EAI_EVENT_UPSERT
				// Se foi encontrado, envia como Alteração
				If lFound
					nOpc := 4
				Else 
					// Caso não esteja cadastrado na Base de Dados, trata como Inclusão
					nOpc := 3						
				EndIf
			Else  
				// Apaga o registro  
				nOpc := 5						
			EndIf
		ENDIF
		
		// Set a operação e Ativa o Model
		oModel:SetOperation(nOpc)
		oModel:Activate()
		
		// Se operação for diferente de exclusão
		If nOpc # 5
			IF !lAutomacao
				// Adiciona a chave apenas se for inclusão
				If nOpc == 3
					oModel:SetValue('CZ2MASTER', 'CZ2_CDMQ'  , oBusinessContent:_MachineCode:TEXT) 
					oModel:SetValue('CZ2MASTER', 'CZ2_NRSQSP', oBusinessContent:_Sequence:TEXT   ) 
				EndIf         

				oModel:SetValue('CZ2MASTER', 'CZ2_DSMQ'  , oBusinessContent:_MachineDescription:TEXT ) 
				oModel:SetValue('CZ2MASTER', 'CZ2_NRORMN', oBusinessContent:_MaintenanceOrder:TEXT )   
				oModel:SetValue('CZ2MASTER', 'CZ2_CDSP'  , oBusinessContent:_StopReasonCode:TEXT ) 
				oModel:SetValue('CZ2MASTER', 'CZ2_DSSP'  , oBusinessContent:_StopReasonDescription:TEXT )
				oModel:SetValue('CZ2MASTER', 'CZ2_DTBGPL', SFCXStoX(oBusinessContent:_StartDate:TEXT, 'D') )
				oModel:SetValue('CZ2MASTER', 'CZ2_HRBGPL', oBusinessContent:_StartTime:TEXT )    
				oModel:SetValue('CZ2MASTER', 'CZ2_DTEDPL', SFCXStoX(oBusinessContent:_EndDate:TEXT, 'D') )
				oModel:SetValue('CZ2MASTER', 'CZ2_HREDPL', oBusinessContent:_EndTime:TEXT ) 
				oModel:SetValue('CZ2MASTER', 'CZ2_CDTN'  , oBusinessContent:_ProductionShiftCode:TEXT )
				oModel:SetValue('CZ2MASTER', 'CZ2_DSTN'  , oBusinessContent:_ProductionShiftDescription:TEXT )
				oModel:SetValue('CZ2MASTER', 'CZ2_NRTN'  , oBusinessContent:_TurnNumber:TEXT )  
				//oModel:SetValue('CZ2MASTER', 'CZ2_LGMN'  , SFCXStoX(oBusinessContent:_IsActive:TEXT, 'L') )
			ENDIF
		EndIf
		
		// Validação no Model    
		if oModel:VldData()  
			// Caso nao ocorra erros, efetiva os dados no banco
			oModel:CommitData()    
			
			// Retorna OK
			cXMLRet := 'Mensagem de ' + IF(nOpc == 3,'Criacao', IF(nOpc == 4, 'Alteracao', 'Delecao')) + ' recebida com sucesso.'
		Else
			// Cria TAG com o Erro ocorrido para retornar ao EAI
			aErro := oModel:GetErrorMessage()
			cXMLRet := '<Error>' + aErro[6] + '</Error>'
			lRet := .F.
		EndIf

		// Desativa o Model
		oModel:DeActivate()

	// Mensagem é de Response
	ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
		//conout( '+ IntegDef SFCA102 Recebendo Mensagem Response' )
		cXMLRet := 'Resposta recebida com sucesso.'
	// Mensagem é de Whois
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		//conout( '+ IntegDef SFCA102 Recebendo Mensagem WHOIS' )
		cXMLRet := '1.000'
	EndIf  
EndIf

RestArea(aAreaCZ2)
RestArea(aArea)

Return { lRet, cXMLRet } 
