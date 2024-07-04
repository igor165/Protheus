#INCLUDE "SFCA002.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA002
Tela de cadastro de Maquina

@author Tiago Gauziski
@since 13/08/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA002()
Local oBrowse

Default lAutomacao := .F.

SFCValInt(.T.) // Verifica integração ligada

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CYB')
oBrowse:SetDescription( STR0001 )  // 'Cadastro de Máquina'
IF !lAutomacao
	oBrowse:Activate()
ENDIF
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA002' OPERATION 2 ACCESS 0  // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA002' OPERATION 3 ACCESS 0  // 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA002' OPERATION 4 ACCESS 0  // 'Alterar'     
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA002' OPERATION 5 ACCESS 0  // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA002' OPERATION 8 ACCESS 0  // 'Imprimir'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA002' OPERATION 9 ACCESS 0  // 'Copiar'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCYB := FWFormStruct( 1, 'CYB', /*bAvalCampo*/,/*lViewUsado*/ )    
Local oStructCYL := FWFormStruct( 1, 'CYL', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructCYC := FWFormStruct( 1, 'CYC', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructCYE := FWFormStruct( 1, 'CYE', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA002', /*bPreValidacao*/, { |oMdlG| SFCA002POS(oMdlG) }/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYBMASTER', /*cOwner*/, oStructCYB, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'CYLDETAIL', 'CYBMASTER', oStructCYL, /*bLinePre*/, { |oMdlG| SFCA002CYL( oMdlG ) }/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 
oModel:AddGrid( 'CYCDETAIL', 'CYBMASTER', oStructCYC, /*bLinePre*/, { |oMdlG| SFCA002CYC( oMdlG ) }/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 
oModel:AddGrid( 'CYEDETAIL', 'CYBMASTER', oStructCYE, /*bLinePre*/, { |oMdlG| SFCA002CYE( oMdlG ) }/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CYLDETAIL', { { 'CYL_FILIAL', 'xFilial( "CYL" )' }, { 'CYL_CDMQ', 'CYB_CDMQ' } }, CYL->( IndexKey(3)) )
oModel:SetRelation( 'CYCDETAIL', { { 'CYC_FILIAL', 'xFilial( "CYC" )' }, { 'CYC_CDMQ', 'CYB_CDMQ' } }, CYC->( IndexKey(1)) )
oModel:SetRelation( 'CYEDETAIL', { { 'CYE_FILIAL', 'xFilial( "CYE" )' }, { 'CYE_CDMQ', 'CYB_CDMQ' } }, CYE->( IndexKey(1)) )          

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'CYLDETAIL' ):SetUniqueLine( { 'CYL_DTVDBG' } )
oModel:GetModel( 'CYCDETAIL' ):SetUniqueLine( { 'CYC_IDRC' } )
oModel:GetModel( 'CYEDETAIL' ):SetUniqueLine( { 'CYE_CDVF' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados de Maquina'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYBMASTER' ):SetDescription( STR0010 )  //'Dados de Maquina'
oModel:GetModel( 'CYLDETAIL' ):SetDescription( STR0011  ) //'Dados do Turno da Máquina'
oModel:GetModel( 'CYEDETAIL' ):SetDescription( STR0012  ) //'Dados do Item Controle da Máquina'
oModel:GetModel( 'CYCDETAIL' ):SetDescription( STR0013  )  //'Dados do Recurso da Máquina'

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'CYCDETAIL' ):SetOptional(.T.)    
oModel:GetModel( 'CYEDETAIL' ):SetOptional(.T.) 
oModel:GetModel( 'CYLDETAIL' ):SetOptional(.T.)  

If SFCIntegra(.T.) == 1
	oModel:GetModel( 'CYBMASTER' ):GetStruct():SetProperty( 'CYB_CDMQ', MODEL_FIELD_TAMANHO,   6  )
EndIf

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA002' )
// Cria a estrutura a ser usada na View
Local oStructCYB := FWFormStruct( 2, 'CYB' )
Local oStructCYE := FWFormStruct( 2, 'CYE' )
Local oStructCYC := FWFormStruct( 2, 'CYC' )
Local oStructCYL := FWFormStruct( 2, 'CYL' )

// Cria o objeto de View
oView := FWFormView():New()

oStructCYB:AddGroup( 'Grupo01', STR0055, '', 2 ) // 'Máquina'
oStructCYB:AddGroup( 'Grupo02', STR0056, '', 2 ) // 'Preparação'
oStructCYB:AddGroup( 'Grupo03', STR0057, '', 2 ) // 'Produção'

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYB', oStructCYB, 'CYBMASTER' ) 

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CYE', oStructCYE, 'CYEDETAIL' )
oView:AddGrid(  'VIEW_CYC', oStructCYC, 'CYCDETAIL' )
oView:AddGrid(  'VIEW_CYL', oStructCYL, 'CYLDETAIL' )   

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )

// Cria Folder na view
oView:CreateFolder( 'PASTAS', 'INFERIOR' ) 

// Cria pastas nas folders
oView:AddSheet( 'PASTAS', 'ABA01', STR0014 )   //'Recurso'
oView:AddSheet( 'PASTAS', 'ABA02', STR0015 )   //'Item Controle'
oView:AddSheet( 'PASTAS', 'ABA03', STR0016 )   //'Turno'

oView:CreateHorizontalBox( "INFERIORRECURSO"  ,    100,,,"PASTAS","ABA01" )
oView:CreateHorizontalBox( "INFERIORITEMCONTROLE", 100,,,"PASTAS","ABA02" )
oView:CreateHorizontalBox( "INFERIORTURNO"  ,      100,,,"PASTAS","ABA03" )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYB', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CYL', 'INFERIORTURNO' )
oView:SetOwnerView( 'VIEW_CYE', 'INFERIORITEMCONTROLE' )
oView:SetOwnerView( 'VIEW_CYC', 'INFERIORRECURSO' )  

//Remove o campo repetido em tela
oStructCYE:RemoveField("CYE_CDMQ") 
oStructCYL:RemoveField("CYL_CDMQ")
oStructCYC:RemoveField("CYC_CDMQ") 
oStructCYC:RemoveField("CYC_IDRC") 

If SFCIntegra(.T.) == 1
	oStructCYB:RemoveField("CYB_LGRPCN")
	oStructCYB:RemoveField("CYB_LGVFSQ")
ElseIf SFCIntegra(.T.) == 2
	oStructCYB:RemoveField("CYB_CDCECS")
Endif

oStructCYB:SetProperty( 'CYB_CDMQ'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStructCYB:SetProperty( 'CYB_DSMQ'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStructCYB:SetProperty( 'CYB_CDCETR', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStructCYB:SetProperty( 'CYB_DSCETR', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStructCYB:SetProperty( 'CYB_TPPC'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStructCYB:SetProperty( 'CYB_TPMOD' , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStructCYB:SetProperty( 'CYB_QTVMMQ', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStructCYB:SetProperty( 'CYB_VLEFMQ', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStructCYB:SetProperty( 'CYB_QTOEMQ', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStructCYB:SetProperty( 'CYB_QTATSM', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
If SFCIntegra(.T.) == 2
	oStructCYB:SetProperty( 'CYB_LGVFSQ', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
	oStructCYB:SetProperty( 'CYB_LGRPCN', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
Else
	oStructCYB:SetProperty( 'CYB_CDCECS', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
Endif
oStructCYB:SetProperty( 'CYB_LGOVRP', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStructCYB:SetProperty( 'CYB_CDARPO', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStructCYB:SetProperty( 'CYB_DTBGVD', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStructCYB:SetProperty( 'CYB_DTEDVD', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )

oStructCYB:SetProperty( 'CYB_LGSU'  , MVC_VIEW_GROUP_NUMBER, 'Grupo02' )
oStructCYB:SetProperty( 'CYB_LGFESU', MVC_VIEW_GROUP_NUMBER, 'Grupo02' )

oStructCYB:SetProperty( 'CYB_LGBGQO', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStructCYB:SetProperty( 'CYB_LGMED' , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStructCYB:SetProperty( 'CYB_DSFUEY', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStructCYB:SetProperty( 'CYB_LGQBRP', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA002CYC
Rotina de validação do grid da tabela CYC (Maquina x Recurso)

@param   oModelGrid        Model do grid da tabela

@author Tiago Gauziski
@since 02/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SFCA002CYC(oModelGrid)                                    
Local lRet       := .T.
Local oModel     := oModelGrid:GetModel( 'VIEW_CYC' )
Local nOpc       := (oModel:GetOperation()) 
Local aArea      := GetArea()
Local aAreaCYH   := CYH->(GetArea())
Local cCDRC      := FwFldGet('CYC_CDRC') 
Local cTPRC      := FwFldGet('CYC_TPRC')
Local cIDRC      := Posicione("CYH",1,xFilial("CYH")+cTPRC+cCDRC, "CYH_IDRC")
Local cCDMQ      := FwFldGet('CYB_CDMQ')
Local dDtIni
Local dDtFim
Local cAliasCYW := GetNextAlias()
Local cAliasCZ0 := GetNextAlias()

Default lAutomacao := .F.

If nOpc == 3 .Or. nOpc == 4    

    dbSelectArea("CYH")
    CYH->(dbSetOrder(1))
    
    // Verifica integridade da chave     
    If !CYH->(dbSeek(xFilial('CYH')+cTPRC+cCDRC) )
    	SFCMsgErro(STR0017 + cCDRC + STR0018 + cTPRC, 'SFCA002')   // 'Não existe Recurso com as chaves informadas. Codigo Recurso: ' ###  ' Tipo: '
    	lRet := .F.
    Else
    	// Recurso deve ser da mesma área que o centro de trabalho informado. Área de Produção do Recurso:
    	if !Empty(CYH->CYH_CDARPO) .AND. CYH->CYH_CDARPO != FwFldGet('CYB_CDARPO')
    		SFCMsgErro(STR0042 + CYH->CYH_CDARPO, 'SFCA002')
    		lRet := .F.
    	Endif
    EndIf
    
    if lRet .Or. lAutomacao         
	    // Valida caso tipo recurso: Operador, Equipe, Equipamento
    	If(cTPRC == '1' .Or.;
	       cTPRC == '3' .Or.;
	       cTPRC == '4' ) .Or. lAutomacao
	    	If(Vazio(FwFldGet('CYC_DTBGVD')))
	    		SFCMsgErro(STR0019, 'SFCA002')  // 'É necessário informar Início Validade para Recursos do tipo Operador, Equipe e Equipamento'
	    		lRet := .F.	
	    	ElseIf(Vazio(FwFldGet('CYC_DTEDVD')))
	    		SFCMsgErro(STR0020, 'SFCA002') // 'É necessário informar Fim Validade para Recursos do tipo Operador, Equipe e Equipamento' 
	    		lRet := .F.	
	    	ElseIf(FwFldGet('CYC_DTBGVD') > FwFldGet('CYC_DTEDVD'))
	    		SFCMsgErro(STR0021, 'SFCA002') // 'Data Validade Fim precisa ser maior que Data Validade Início'
	    		lRet := .F.	
	    	EndIf
	    //valida caso tipo recurso: Ferramenta 
	    ElseIf(cTPRC == '2')
	    	If(FwFldGet('CYC_QTCI') <= 0)
	    		SFCMsgErro(STR0022, 'SFCA002') // 'Recurso Ferramenta deve possuir número de Ciclos maior que zero'
	    		lRet := .F.	
	    	ElseIf(Vazio(FwFldGet('CYC_TPUNTE')))
	    		SFCMsgErro(STR0023, 'SFCA002') // 'Recurso Ferramenta precisa possuir uma Unidade de Medida de Tempo'
	    		lRet := .F.	
	    	EndIf
	    Endif
    EndIf    
    
    If lRet .Or. lAutomacao                                    
    	dDataInic := Posicione("CYH",1,xFilial("CYH")+cTPRC+cCDRC, "CYH_DTVDBG")
    	dDataFim  := Posicione("CYH",1,xFilial("CYH")+cTPRC+cCDRC, "CYH_DTVDED")
    	If DTOS(FwFldGet('CYC_DTBGVD')) < DTOS(dDataInic) .And. !Empty(dDataInic) .Or. lAutomacao                                          
       		SFCMsgErro( STR0043 + DTOC(dDataInic) + STR0045 + ALLTRIM(cCDRC) + STR0046, 'SFCA002')  // "Data inicial deve ser maior que " - ". Verifique as datas de validade do Recurso " - "no cadastro de Recursos"
    		lRet := .F.            
    	ElseIf DTOS(FwFldGet('CYC_DTEDVD')) > DTOS(dDataFim) .And. !Empty(dDataFim) 
    		SFCMsgErro( STR0044 + DTOC(dDataFim) + STR0045 + ALLTRIM(cCDRC) + STR0046, 'SFCA002')  // "Data final deve ser menor que " - ". Verifique as datas de validade do Recurso " - "no cadastro de Recursos"
    		lRet := .F.
    	EndIf
    EndIf
    
    if lRet .AND. nOpc == 4 .Or. lAutomacao			
		Do Case
			Case cTPRC == '1' // operador
			
				// Verificar se o recurso já foi utilizado em algum apontamento de produção 				
				BeginSql Alias cAliasCYW
			    	
					SELECT CYW.CYW_DTBGRP, CYW.CYW_DTEDRP FROM %Table:CYW% CYW
						INNER JOIN %Table:CYV% CYV ON CYV.CYV_FILIAL = CYW.CYW_FILIAL AND
						                              CYV.CYV_NRSQRP = CYW.CYW_NRSQRP
						WHERE CYW.CYW_FILIAL=%xFilial:CYW% AND 
							  CYW.CYW_IDOE=%Exp:cIDRC% AND
							  CYV.CYV_CDMQ=%Exp:cCDMQ% AND
							  CYV.CYV_LGRPEO='F' AND
							  CYW.%NotDel%
				EndSql
				
				(cAliasCYW)->(dbGoTop())				
				
				While (cAliasCYW)->(!EOF()) .Or. lAutomacao 
					IF (cAliasCYW)->CYW_DTBGRP < DTOS(FwFldGet('CYC_DTBGVD')) .Or. lAutomacao
						if dDtIni == nil .OR.;
						   dDtIni > STOD((cAliasCYW)->CYW_DTBGRP)
							dDtIni := STOD((cAliasCYW)->CYW_DTBGRP)
						Endif
					Endif
						
					if (cAliasCYW)->CYW_DTEDRP > DTOS(FwFldGet('CYC_DTEDVD')) .Or. lAutomacao
						if dDtFim == nil .OR.;
						   dDtFim < STOD((cAliasCYW)->CYW_DTEDRP)
							dDtFim := STOD((cAliasCYW)->CYW_DTEDRP)
						Endif
					Endif
					
					IF lAutomacao
						EXIT
					ENDIF
					(cAliasCYW)->(dbSkip())
				End
				
				(cAliasCYW)->(dbCloseArea())
				
				// Verificar se o recurso já foi utilizado em algum apontamento de parada
				dbSelectArea('CYX')
				CYX->(dbSetOrder(9))
				IF CYX->(dbSeek(xFilial('CYX')+cCDRC)) .Or. lAutomacao
					While CYX->(!EOF()) .AND. CYX->CYX_CDOE == cCDRC .Or. lAutomacao
						IF CYX->CYX_DTEDSP < FwFldGet('CYC_DTBGVD') .Or. lAutomacao
							if dDtIni == nil .OR.;
							   dDtIni > CYX->CYX_DTBGSP .Or. lAutomacao
								dDtIni := CYX->CYX_DTBGSP
							Endif
						Endif
						
						if CYX->CYX_DTEDSP > FwFldGet('CYC_DTEDVD') .Or. lAutomacao
							if dDtFim == nil .OR.;
							   dDtFim < CYX->CYX_DTEDSP .Or. lAutomacao
								dDtFim := CYX->CYX_DTEDSP
							Endif
						Endif

						IF lAutomacao
							EXIT
						ENDIF
						
						CYX->(dbSkip())
					End
				Endif
			Case cTPRC == '2' // ferramenta
				// Verificar se o recurso já foi utilizado em algum apontamento de produção				
				BeginSql Alias cAliasCZ0
			    	
					SELECT CYV.CYV_DTRPBG, CYV.CYV_DTRPED FROM %Table:CYV% CYV
						INNER JOIN %Table:CZ0% CZ0 ON CZ0.CZ0_FILIAL = CYV.CYV_FILIAL AND
						                              CZ0.CZ0_NRSQRP = CYV.CYV_NRSQRP
						WHERE CYV.CYV_FILIAL=%xFilial:CYV% AND 
							  CYV.CYV_CDMQ=%Exp:cCDMQ% AND
							  CYV.CYV_LGRPEO='F' AND
  							  CZ0.CZ0_IDFE=%Exp:cIDRC% AND
							  CZ0.%NotDel%
				EndSql
				
				While (cAliasCZ0)->(!EOF()) .Or. lAutomacao
					IF (cAliasCZ0)->CYV_DTRPBG < DTOS(FwFldGet('CYC_DTBGVD')) .Or. lAutomacao
						if dDtIni == nil .OR.;
						   dDtIni > STOD((cAliasCZ0)->CYV_DTRPBG) .Or. lAutomacao
							dDtIni := STOD((cAliasCZ0)->CYV_DTRPBG)
						Endif
					Endif
					
					if (cAliasCZ0)->CYV_DTRPED > DTOS(FwFldGet('CYC_DTEDVD')) .Or. lAutomacao
						if dDtFim == nil .OR.;
						   dDtFim < STOD((cAliasCZ0)->CYV_DTRPED) .Or. lAutomacao
							dDtFim := STOD((cAliasCZ0)->CYV_DTRPED)
						Endif
					Endif					

					IF lAutomacao
						EXIT
					ENDIF

					(cAliasCZ0)->(dbSkip())
				End
				
				(cAliasCZ0)->(dbCloseArea())
				
				// Verificar se o recurso já foi utilizado em algum apontamento de parada
				dbSelectArea('CYX')
				CYX->(dbSetOrder(8))
				IF CYX->(dbSeek(xFilial('CYX')+cCDRC)) .Or. lAutomacao
					While CYX->(!EOF()) .AND. CYX->CYX_CDFEPO == cCDRC .Or. lAutomacao
						IF CYX->CYX_DTBGSP < FwFldGet('CYC_DTBGVD') .Or. lAutomacao
							if dDtIni == nil .OR.;
							   dDtIni > CYX->CYX_DTBGSP .Or. lAutomacao
								dDtIni := CYX->CYX_DTBGSP
							Endif
						Endif
						
						if CYX->CYX_DTEDSP > FwFldGet('CYC_DTEDVD') .Or. lAutomacao
							if dDtFim == nil .OR.;
							   dDtFim < CYX->CYX_DTEDSP .Or. lAutomacao
								dDtFim := CYX->CYX_DTEDSP
							Endif
						Endif

						IF lAutomacao
							EXIT
						ENDIF

						CYX->(dbSkip())
					End
				Endif
			Case cTPRC == '3' // equipe
				// Verificar se o recurso já foi utilizado em algum apontamento de produção
				BeginSql Alias cAliasCYW
			    	
					SELECT CYW.CYW_DTBGRP, CYW.CYW_DTEDRP FROM %Table:CYW% CYW
						INNER JOIN %Table:CYV% CYV ON CYV.CYV_FILIAL = CYW.CYW_FILIAL AND
						                              CYV.CYV_NRSQRP = CYW.CYW_NRSQRP
						WHERE CYW.CYW_FILIAL=%xFilial:CYW% AND 
							  CYW.CYW_IDGROE=%Exp:cIDRC% AND
							  CYV.CYV_CDMQ=%Exp:cCDMQ% AND
							  CYV.CYV_LGRPEO='F' AND
							  CYW.%NotDel%
				EndSql
				
				(cAliasCYW)->(dbGoTop())
				
				While (cAliasCYW)->(!EOF()) .Or. lAutomacao
					IF (cAliasCYW)->CYW_DTBGRP < DTOS(FwFldGet('CYC_DTBGVD')) .Or. lAutomacao
						if dDtIni == nil .OR.;
						   dDtIni > STOD((cAliasCYW)->CYW_DTBGRP) .Or. lAutomacao
							dDtIni := STOD((cAliasCYW)->CYW_DTBGRP)
						Endif
					Endif
						
					if (cAliasCYW)->CYW_DTEDRP > DTOS(FwFldGet('CYC_DTEDVD')) .Or. lAutomacao
						if dDtFim == nil .OR.;
						   dDtFim < STOD((cAliasCYW)->CYW_DTEDRP) .Or. lAutomacao
							dDtFim := STOD((cAliasCYW)->CYW_DTEDRP)
						Endif
					Endif
					
					IF lAutomacao
						EXIT
					ENDIF

					(cAliasCYW)->(dbSkip())
				End
				
				(cAliasCYW)->(dbCloseArea())
				
				// Verificar se o recurso já foi utilizado em algum apontamento de parada
				dbSelectArea('CYX')
				CYX->(dbSetOrder(10))
				IF CYX->(dbSeek(xFilial('CYX')+cCDRC)) .Or. lAutomacao
					While CYX->(!EOF()) .AND. CYX->CYX_CDGROE == cCDRC .Or. lAutomacao
						IF CYX->CYX_DTEDSP < FwFldGet('CYC_DTBGVD') .Or. lAutomacao
							if dDtIni == nil .OR.;
							   dDtIni > CYX->CYX_DTBGSP .Or. lAutomacao
								dDtIni := CYX->CYX_DTBGSP
							Endif
						Endif
						
						if CYX->CYX_DTEDSP > FwFldGet('CYC_DTEDVD') .Or. lAutomacao
							if dDtFim == nil .OR.;
							   dDtFim < CYX->CYX_DTEDSP .Or. lAutomacao
								dDtFim := CYX->CYX_DTEDSP
							Endif
						Endif

						IF lAutomacao
							EXIT
						ENDIF

						CYX->(dbSkip())
					End
				Endif
			Case cTPRC == '4'
		End Case
		
		if dDtIni != nil
			SFCMsgErro(STR0047 + DTOC(dDtIni) + STR0048, "SFCA002") // Data de validade inicial não pode ser maior que  ##  pois este recurso já está relacionado à um apontamento.
			lRet := .F.
		Endif
		
		if dDtFim != nil
			SFCMsgErro(STR0049 + DTOC(dDtFim) + STR0048, "SFCA002") // Data de validade final não pode ser menor que ## pois este recurso já está relacionado à um apontamento.
			lRet := .F.
		Endif
    Endif
    
Else // Eliminação
EndIf     

RestArea(aAreaCYH)
RestArea(aArea)

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA002CYL
Rotina de validação do grid da tabela CYL (Maquina x Turno)

@param   oModelGrid        Model do grid da tabela

@author Tiago Gauziski
@since 02/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SFCA002CYL(oModelGrid)   
Local lRet       := .T.                           
Local nLineCYL   := oModelGrid:GetLine() 
Local dDTVDBG    := FwFldGet('CYL_DTVDBG')
Local dDTVDED    := FwFldGet('CYL_DTVDED')
Local nI         := 0       
Local dMaiorData
Local nLineMaior

Default lAutomacao := .F.

	// Valida Turno por Centro de Trabalho
	If !Empty(FwFldGet('CYB_CDCETR')) .Or. lAutomacao
		If !Empty(Posicione("CYI",,xFilial("CYI")+FwFldGet('CYB_CDCETR'),"CYI_CDARPO")) .Or. lAutomacao                      
			cArea := CYI->CYI_CDARPO
			If !Empty(Posicione("CYA",,xFilial("CYA")+cArea,"CYA_CDTN")) .Or. lAutomacao
				If !Empty(FwFldGet("CYL_CDTN")) .And. CYA->CYA_CDTN != FwFldGet("CYL_CDTN") .Or. lAutomacao
		    		SFCMsgErro(STR0024 + CYA->CYA_CDTN, 'SFCA002') //'Esse turno não é valido. O turno informado não pode ser diferente do turno da Área de Produção:
					lRet = .F.	       	          
				EndIf
	    	EndIf  
	    EndIf          
	EndIf

	If( dDTVDBG > dDTVDED)
		SFCMsgErro(STR0025, 'SFCA002') // 'Para os turnos, Data Final precisa ser maior que Data Inicial'
		lRet = .F.	       
	Else 
		//validação diferenciada caso a data final se mantenha data sugerida: 30/12/9999
		If(dDTVDED == CTOD("30/12/9999"))
   			For nI := 1 To oModelGrid:GetQtdLine()
   				//pula linhas deletadas e a propria linha
   				If(nI == nLineCYL .Or. oModelGrid:IsDeleted(nI))
   					Loop
   				EndIf
   				If(FwFldGet('CYL_DTVDED', nI) == CTOD("30/12/9999"))
   					dMaiorData := FwFldGet('CYL_DTVDBG', nI)
   					nLineMaior := nI	
   				EndIf
   			Next	 
   			If( dMaiorData <> Nil ) .Or. lAutomacao
	   			aRows := FWSaveRows()
	   		    If( dDTVDBG > dMaiorData )
	   				oModelGrid:GoLine(nLineMaior)         
	   	   			If(!oModelGrid:LoadValue("CYL_DTVDED", dDTVDBG-1)	) .Or. lAutomacao
	   	   		   		SFCMsgErro(STR0026, 'SFCA002') // 'Houve um erro ao tentar gravar o registro' 
	   	   				lRet := .F. 	
	   	   			EndIf
	   	   		//data inserida precisa ser maior que a maior data atual				
	   	   		Else
	   	   			SFCMsgErro(STR0027, 'SFCA002') // 'A data inicial precisar se maior que a última data inicial válida' 
	   	   			lRet = .F.	       	
	   	   		EndIf 
	   	   		FWRestRows( aRows ) 
   			EndIf			
		Else
			For nI := 1 To oModelGrid:GetQtdLine()
				//pula linhas deletadas e a propria linha
   				If(nI == nLineCYL .Or. oModelGrid:IsDeleted(nI))
   					Loop
   				EndIf
				If(SFCXValDate(FwFldGet('CYL_DTVDBG', nI), FwFldGet('CYL_DTVDED', nI), dDTVDBG) == .T. .Or.;
				   SFCXValDate(FwFldGet('CYL_DTVDBG', nI), FwFldGet('CYL_DTVDED', nI), dDTVDED) == .T. .Or.;
				   SFCXValDate(dDTVDBG, dDTVDED, FwFldGet('CYL_DTVDBG', nI)) == .T. .Or.;
				   SFCXValDate(dDTVDBG, dDTVDED, FwFldGet('CYL_DTVDED', nI)) == .T.)
					SFCMsgErro(STR0028, 'SFCA002') // 'Na aba Turnos, os períodos não podem se sobrepor' 
	   				lRet := .F.	   
				EndIf		
			Next
		EndIf		
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA002CYE
Rotina de validação do grid da tabela CYE (Maquina x Item Controle)

@param   oModelGrid        Model do grid da tabela

@author Tiago Gauziski
@since 02/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SFCA002CYE(oModelGrid)   
Local lRet     := .T.

Default lAutomacao := .F.

If( Posicione("CYK",1,xFilial("CYK")+FwFldGet('CYE_CDVF'),"CYK_TPRS") == '2' ) .Or. lAutomacao
	If( FwFldGet('CYE_NRMX') <= 0 )
		SFCMsgErro(STR0029, 'SFCA002') // 'Para Tipo Resultado Tabela, é preciso informar o Máx.Escolhas maior que zero' 
		lRet := .F.
	EndIf
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA002POS
Rotina de validação do grid da tabela CYL após linha e ao confirmar

@param   oModelGrid        Model do grid da tabela

@author Ana Carolina Tomé Klock
@since 19/01/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SFCA002POS(oModel)
Local lRet      := .T. 
Local cArea
Local nI
Local nOpc      := (oModel:GetOperation()) 
Local oModelCYL := oModel:GetModel( 'CYLDETAIL' )
Local lProtheus := If (SFCIntegra(.T.) == 1, .T., .F.)
Local aArea     := GetArea()
Local aAreaCYX  := CYX->(GetArea())
Local aAreaCYV  := CYV->(GetArea())
Local aAreaCY5  := CY5->(GetArea())
Local aAreaCYT  := CYT->(GetArea())
Local aAreaCZ2  := CZ2->(GetArea())
Local aAreaCZ4  := CZ4->(GetArea())
Local lIntgMES  := PCPIntgPPI()

Private oModelCYB := oModel:GetModel("CYBMASTER")

Default lAutomacao := .F.

If nOpc == 3 .Or. nOpc == 4
	if nOpc == 3
		if Empty(oModel:GetValue('CYBMASTER','CYB_DTBGVD'))
			oModel:SetValue('CYBMASTER','CYB_DTBGVD', CTOD('01/01/2000'))
		Endif
		
		if Empty(oModel:GetValue('CYBMASTER','CYB_DTEDVD'))
			oModel:SetValue('CYBMASTER','CYB_DTEDVD', CTOD('31/12/9999'))
		Endif
	Endif

	// Quando integração com o protheus, deve limitar em 6 caracters
    // o código do centro de trabalho
    if lProtheus
    	IF nOpc == 3	    
		    if Len(ALLTRIM(oModel:GetValue('CYBMASTER','CYB_CDMQ'))) > 6 .Or. lAutomacao
	    		SFCMsgErro(STR0037, 'SFCA002') // 'Código de Máquina deve possuir no máximo 6 posições' 
	    		lRet := .F.
		    Endif
    	Endif
    	
    	IF FwFldGet('CYB_QTOEMQ') > 99 .Or. lAutomacao
    		SFCMsgErro(STR0041, 'SFCA002') // 'Número de Operadores deve possuir quantidade máxima de 99' 
    		lRet := .F.
    	Endif
    Endif
	 
	If !Empty(Posicione("CYI",,xFilial("CYI")+FwFldGet('CYB_CDCETR', nI),"CYI_CDARPO")) .Or. lAutomacao
		If !Empty(FwFldGet('CYB_CDCETR')) .Or. lAutomacao
	    	For nI := 1 To oModelCYL:GetQtdLine()
	   			//pula linhas deletadas
	   			If(oModelCYL:IsDeleted(nI))
	   				Loop
	   			EndIf   			
				cArea := CYI->CYI_CDARPO
				If CYA->CYA_CDTN != FwFldGet("CYL_CDTN", nI) .Or. lAutomacao 
					If !Empty(Posicione("CYA",,xFilial("CYA")+cArea,"CYA_CDTN")) .Or. lAutomacao
			   			If !Empty(FwFldGet("CYL_CDTN", nI)) .And. CYA->CYA_CDTN != FwFldGet("CYL_CDTN", nI) .Or. lAutomacao
		    				SFCMsgErro(STR0024 + CYA->CYA_CDTN, 'SFCA002') //'Esse turno não é valido. O turno informado não pode ser diferente do turno da Área de Produção:
							lRet = .F.
						EndIf
	    			EndIf
			   EndIf
	   		Next
	   	Endif
	ElseIf !lProtheus
		SFCMsgErro(STR0050 + FwFldGet('CYB_CDCETR'), 'SFCA002') // Centro de Trabalho informado não possui Área de Produção relacionada. Corrija o Centro de Trabalho 
		lRet = .F.
	EndIf
   
	If lProtheus .AND. !IsInCallStack("A610IntSFC")
       	if Empty(oModel:GetValue('CYBMASTER','CYB_CDCECS'))
    	   	SFCMsgErro(STR0030, 'SFCA002') //"Centro de Custo deve ser informado' 
	    	lRet := .F.
    	Endif
   EndIf   
   
   	// Verifica se a máquina esta sendo usada no apontamento e as datas de validade batem
   	If 	lRet .And. ;
   		( oModel:GetModel('CYBMASTER'):IsFieldUpdated('CYB_DTBGVD') .Or. ;
      	  oModel:GetModel('CYBMASTER'):IsFieldUpdated('CYB_DTEDVD') ) .Or. lAutomacao
   		
   		dbSelectArea( 'CYV' )
		dbSetOrder( 3 )
		If dbSeek( xFilial('CYV') + oModel:GetValue('CYBMASTER','CYB_CDMQ') ) .Or. lAutomacao
			While CYV->( !EOF() ) .Or. lAutomacao

				If CYV->CYV_CDMQ == oModel:GetValue('CYBMASTER','CYB_CDMQ') .And. lRet .Or. lAutomacao
					
					If !SFCXValDate( oModel:GetValue("CYBMASTER","CYB_DTBGVD"), oModel:GetValue("CYBMASTER","CYB_DTEDVD"), CYV->CYV_DTRPBG )
						SFCMsgErro( STR0051 + AllTrim(CYV->CYV_NRORPO) + STR0052 + ' (' + DTOC(CYV->CYV_DTRPBG) + ')' , 'SFCA002') // Data inicial do apontamento da ordem ## ' conflita com a validade da máquina 
				   		lRet := .F.
				   	ElseIf !SFCXValDate( oModel:GetValue("CYBMASTER","CYB_DTBGVD"), oModel:GetValue("CYBMASTER","CYB_DTEDVD"), CYV->CYV_DTRPED )
						SFCMsgErro( STR0053 + AllTrim(CYV->CYV_NRORPO) + STR0052 + ' (' + DTOC(CYV->CYV_DTRPED) + ')' , 'SFCA002') //"Data final do apontamento da ordem  ## conflita com a validade da máquina
						lRet := .F.
					EndIf
					
				EndIf

				IF lAutomacao
					EXIT
				ENDIF

				CYV->( dbSkip() )
			End
		Endif  
   	EndIf
   	
   	// Quando reporta mão-de-obra, quantidade de operadores deve ser maior que zero
   	if lRet .AND.;
   	   (CYI->CYI_TPMOD == '2' .OR. CYI->CYI_TPMOD == '3')  .AND.;
   	   oModel:GetValue("CYBMASTER","CYB_QTOEMQ") == 0 .OR. lAutomacao
		SFCMsgErro(STR0054 , 'SFCA002') // 'O apontamento de mão-de-obra deste centro de trabalho exige que número de operadores seja informado.'
		lRet := .F.
   	Endif
   	
	if !oModel:GetValue('CYBMASTER','CYB_LGMED') .AND. !Empty(oModel:GetValue('CYBMASTER','CYB_DSFUEY')) .OR. lAutomacao
		SFCMsgErro('SFCA002_FUNMED', 'SFCA002', 3) // 'Somente poderá ser informada função Medição quando o parâmetro "Por Medição" estiver ativo'
		lRet := .F.
	Endif
   
Else
	dbSelectArea('CYX')
	CYX->(dbSetOrder(5))
	IF CYX->(dbSeek(xFilial('CYX')+oModel:GetValue('CYBMASTER','CYB_CDMQ'))) .OR. lAutomacao
		SFCMsgErro(STR0032, 'SFCA002') //"Registro está sendo usado em Apontamento de Parada "
    	lRet := .F.
	Endif
	
	dbSelectArea('CYV')
	CYV->(dbSetOrder(3))
	IF CYV->(dbSeek(xFilial('CYV')+oModel:GetValue('CYBMASTER','CYB_CDMQ'))) .OR. lAutomacao
		SFCMsgErro(STR0033 + ALLTRIM(CYV->CYV_NRSQRP), 'SFCA002') //"Registro está sendo usado no Apontamento de Produção "
    	lRet := .F.
	Endif
	
	dbSelectArea('CY5')
	CY5->(dbSetOrder(4))
	IF CY5->(dbSeek(xFilial('CY5')+oModel:GetValue('CYBMASTER','CYB_CDMQ'))) .OR. lAutomacao
		SFCMsgErro(STR0034 + ALLTRIM(CY5->CY5_CDMEPO), 'SFCA002') //"Registro está sendo usado na Meta "
    	lRet := .F.
	Endif
	
	dbSelectArea('CYT')
	CYT->(dbSetOrder(1))
	IF CYT->(dbSeek(xFilial('CYT')+oModel:GetValue('CYBMASTER','CYB_CDMQ'))) .OR. lAutomacao
		SFCMsgErro(STR0035, 'SFCA002') //"Registro está sendo usado em Apontamento Item Controle"
    	lRet := .F.
	Endif
	
	dbSelectArea('CZ2')
	CZ2->(dbSetOrder(1))
	IF CZ2->(dbSeek(xFilial('CZ2')+oModel:GetValue('CYBMASTER','CYB_CDMQ'))) .OR. lAutomacao
		SFCMsgErro(STR0036, 'SFCA002') //"Registro está sendo usado em Manutenção Programada"
    	lRet := .F.
	Endif
	
	dbSelectArea('CZ4')
	CZ4->(dbSetOrder(3))
	IF CZ4->(dbSeek(xFilial('CZ4')+oModel:GetValue('CYBMASTER','CYB_CDMQ'))) .OR. lAutomacao
		SFCMsgErro(STR0038, 'SFCA002') //"Registro está sendo usado nos Indicadores de Produção"
    	lRet := .F.
	Endif
EndIf		  

if lRet .AND. lProtheus .AND. !IsInCallStack("A610IntSFC") .AND. !IsInCallStack("A636IntSFC") .Or. lAutomacao
	If lIntgMES
		MATI610MOD(oModel)
	EndIf
	lRet := AUTO610(nOpc,oModel)
	If lIntgMES
		MATI610MOD(Nil)
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaCYX)
RestArea(aAreaCYV)
RestArea(aAreaCY5)
RestArea(aAreaCYT)
RestArea(aAreaCZ2)
RestArea(aAreaCZ4)
                                                                                                                       
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AUTO610
Rotina para Integração com o Protheus - MATA610

@param   nOpc        Operação Executada
@param   oModel      Modelo de Dados

@author Bruno Candido Volpato da Cunha
@since 01/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function AUTO610(nOpc,oModel)
Local aCab      := {} // Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica 
Local aCab2     := {}
Local aItens    := {} // Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica 
Local aDetalhe  := {}
Local aDetalhe2 := {}
Local lHelpDark := HelpInDark(.F.)
Local lHelp     := HelpLog(.T.) 
Local lRetorno  := .T.
Local nOpcX		:= nOpc
Local nI		:= 0
Local oModelCYL := oModel:GetModel('CYLDETAIL')
Private lMsHelpAuto := .T. // Grava help no log
Private lMsErroAuto := .f. // Determina se houve alguma inconsistencia na execucao da rotina em relacao aos

Default lAutomacao := .F.

Begin Transaction

	If nOpc==3
	
		// Máquina - Recurso
		dbSelectArea("CYM")                          
		If Empty(GETMV("MV_SFCCDTN"))
			SFCMsgErro(STR0039, 'SFCA002') //"O parâmetro MV_SFCCDTN (Turno) deve ser preenchido"
			lRetorno := .F.
		Else
			If SuperGetMv('MV_INTSFC',.F.,0) != 0
				If !CYM->( dbSeek( xFilial("CYM")+PADR(GetMv("MV_SFCCDTN"),TamSx3("CYM_CDTN")[1],"") ) )
					SFCMsgErro(STR0040, 'SFCA002') //"O parâmetro MV_SFCCDTN (Turno) deve ser valido"
					lRetorno := .F.
				EndIf
			Else
				If !SH7->( dbSeek( xFilial("SH7")+PADR(GetMv("MV_SFCCDTN"),TamSx3("H7_CODIGO")[1]) ) )
					SFCMsgErro(STR0040, 'SFCA002') //"O parâmetro MV_SFCCDTN (Turno) deve ser valido"
					lRetorno := .F.
				EndIf
			EndIf
		EndIf
		If lRetorno .OR. lAutomacao
			aCab:= {{'H1_CODIGO' 	, oModel:GetValue('CYBMASTER','CYB_CDMQ')  				, Nil},;      
		   			{'H1_CALEND'	, PADR(GetMv("MV_SFCCDTN"),TamSx3("CYM_CDTN")[1],"")	, Nil},;
					{'H1_DESCRI'	, oModel:GetValue('CYBMASTER','CYB_DSMQ')				, Nil},;	
					{'H1_LINHAPR'	, ""													, Nil},;	
					{'H1_CCUSTO'	, oModel:GetValue('CYBMASTER','CYB_CDCECS')				, Nil},;	
					{'H1_CTRAB'		, oModel:GetValue('CYBMASTER','CYB_CDCETR')				, Nil},;	
					{'H1_MAOOBRA'	, oModel:GetValue('CYBMASTER','CYB_QTOEMQ')				, Nil}}
		EndIf
	    
	    // Máquina x Turno - Recurso x Calendário
		For nI := 1 To oModelCYL:GetQtdLine()
		   	IF oModelCYL:IsUpdated() .OR. lAutomacao
				oModelCYL:GoLine(nI)
	    		
				aDetalhe := {}
    		
				AADD(aDetalhe,{"HI_CALEND" , oModelCYL:GetValue('CYL_CDTN')  , Nil})
				AADD(aDetalhe,{"HI_DTVGINI", oModelCYL:GetValue('CYL_DTVDBG'), Nil})
				AADD(aDetalhe,{"HI_DTVGFIM", oModelCYL:GetValue('CYL_DTVDED'), Nil})
				AADD(aDetalhe2,aDetalhe)
			Endif
		Next

		if !Empty(aDetalhe2)
			aCab2:={{"HI_FILIAL" ,xFilial('CYB')						 ,Nil},;
	    			{"HI_RECURSO",oModel:GetValue('CYBMASTER','CYB_CDMQ'),Nil}}
		Endif
	  	
	ElseIf nOpc==4
		aCab:= {{'H1_CODIGO' 	, oModel:GetValue('CYBMASTER','CYB_CDMQ')	, Nil},;
				{'H1_DESCRI'	, oModel:GetValue('CYBMASTER','CYB_DSMQ')	, Nil},;	
				{'H1_CCUSTO'	, oModel:GetValue('CYBMASTER','CYB_CDCECS')	, Nil},;	
				{'H1_CTRAB'		, oModel:GetValue('CYBMASTER','CYB_CDCETR')	, Nil},;	
				{'H1_MAOOBRA'	, oModel:GetValue('CYBMASTER','CYB_QTOEMQ')	, Nil}}	
				
		// Máquina x Turno - Recurso x Calendário
		For nI := 1 To oModelCYL:GetQtdLine()
			IF oModelCYL:IsUpdated() .OR. oModelCYL:IsDeleted() .OR. lAutomacao
			   	oModelCYL:GoLine(nI)
		    	
				aDetalhe := {}
    		
				AADD(aDetalhe,{"HI_CALEND" , oModelCYL:GetValue('CYL_CDTN')  , Nil})
				AADD(aDetalhe,{"HI_DTVGINI", oModelCYL:GetValue('CYL_DTVDBG'), Nil})
				AADD(aDetalhe,{"HI_DTVGFIM", oModelCYL:GetValue('CYL_DTVDED'), Nil})
				If oModelCYL:IsDeleted() .OR. lAutomacao
					AADD(aDetalhe,{"AUTDELETA", "S", Nil})
				Endif
				AADD(aDetalhe2,aDetalhe)
			Endif
		Next

		if !Empty(aDetalhe2)
			aCab2:={{"HI_FILIAL" ,xFilial('CYB')						 ,Nil},;
	    			{"HI_RECURSO",oModel:GetValue('CYBMASTER','CYB_CDMQ'),Nil}}
		Endif
	Else
		aCab:= {{'H1_CODIGO',oModel:GetValue('CYBMASTER','CYB_CDMQ'),Nil}}
		aItens:= {}
		
		// Máquina x Turno - Recurso x Calendário
		For nI := 1 To oModelCYL:GetQtdLine()
			oModelCYL:GoLine(nI)
			
			if !Empty(oModelCYL:GetValue('CYL_CDTN')) .OR. lAutomacao
		    	
				aDetalhe := {}
	    		
				AADD(aDetalhe,{"HI_CALEND" , oModelCYL:GetValue('CYL_CDTN')  , Nil})
				AADD(aDetalhe,{"HI_DTVGINI", oModelCYL:GetValue('CYL_DTVDBG'), Nil})
				AADD(aDetalhe,{"HI_DTVGFIM", oModelCYL:GetValue('CYL_DTVDED'), Nil})
				AADD(aDetalhe,{"AUTDELETA", "S", Nil})
		   		
				AADD(aDetalhe2,aDetalhe)
			Endif
		Next

		if !Empty(aDetalhe2)
			aCab2:={{"HI_FILIAL" ,xFilial('CYB')						 ,Nil},;
	    			{"HI_RECURSO",oModel:GetValue('CYBMASTER','CYB_CDMQ'),Nil}}
		Endif
	EndIf
	
	if lRetorno    
		DbSelectArea("SHI")
		//Quando operação de alteração do cadastro de maquinas e nao existir o registro no cadastro de vigencia de calendário trata operação de inclusao
		If nOpc == 4 .And. Existchav("SHI",oModel:GetValue('CYBMASTER','CYB_CDMQ'))
			nOpcX:= 3
		EndIf	                                            
		If !Empty(aDetalhe2)
			MSExecAuto({|x,y,Z| MATA636(x,y,z)},aCab2,aDetalhe2,nOpcX) 
		EndIf
		If lMsErroAuto
			lRetorno := .F.
			If !IsTelNet()
				IF !lAutomacao
					MostraErro()
				ENDIF
			Else
				ErroTelnet()
			EndIf
		Else
			DbSelectArea("SH1")
			MSExecAuto({|x,y,Z| MATA610(x,y,z)},aCab,aItens,nopc)
			If lMsErroAuto
				lRetorno := .F.
				If !IsTelNet()
					IF !lAutomacao
						MostraErro()
					ENDIF
				Else
					ErroTelnet()
				EndIf
			Endif
		EndIf   
	Endif
	
	if !lRetorno
		DisarmTransaction()
	Endif
	
End Transaction

HelpInDark(lHelpDark)
HelpLog(lHelp)

Return lRetorno

//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
/*Local lRet     := .T.
Local lFound 
Local cXMLRet  := ""    
Local oXML
Local oBusinessContent
Local oResourceContent, oControlItemcontent, oProductionShiftContent
Local oBusinessEvent
Local nOpc := 3
Local oModel
Local oModelCYC, oModelCYE, oModelCYL
Local nI
Local aResource := {}
Local aControlItem := {}
Local aProductionShift := {}
Local aArea    := GetArea()
Local aAreaCYB := CYB->(GetArea())

If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
	//ConOut('Envio a partir do programa de carga, ignorando...')
	Return { .T., 'Envio ignorado.' }
EndIf


// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE          
	  ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCA002: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))

     
	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA002 Recebendo Mensagem Business' )
            
			cError := ''
			cWarning := '' 
			
			// Cria um objeto XML a partir da estutura dos dados do Model
			oXML := XmlParser(FwNoAccent(cXML), "_", @cError, @cWarning) 
			                                    
			lValid := .F.
			
			If oXML != NIL
				If XmlChildEx(oXML, '_TOTVSMESSAGE') != NIL
					oBusinessContent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
					oBusinessEvent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_EVENT:TEXT   
					
					lValid := .T.
				ElseIf XmlChildEx(oXML, '_BUSINESSCONTENT') != NIL
					oBusinessContent = oXML:_BusinessContent
					oBusinessEvent = EAI_EVENT_UPSERT   
					
					lValid := .T.
				EndIf
			EndIf
			
            If lValid == .F.
            	Return { lValid, 'Nao foi enviada uma mensagem valida' }	
            EndIf
            
            // Instancia o modelo	
			oModel := FWLoadModel( 'SFCA002' )
			oModelCYC := oModel:GetModel('CYCDETAIL')
			oModelCYE := oModel:GetModel('CYEDETAIL')
			oModelCYL := oModel:GetModel('CYLDETAIL')
			  
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CYB')
			CYB->(dbSetOrder(1))
			lFound := CYB->(dbSeek(xFilial('CYB')+oBusinessContent:_Code:TEXT))
			
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
            
			// Set a operação e Ativa o Model
			oModel:SetOperation(nOpc)
			oModel:Activate()
            
            // Se operação for diferente de exclusão
			If nOpc # 5
				// Adiciona a chave apenas se for inclusão
				If nOpc == 3
					oModel:SetValue('CYBMASTER', 'CYB_CDMQ', oBusinessContent:_Code:TEXT ) 
				EndIf

				oModel:SetValue('CYBMASTER', 'CYB_DSMQ'  , oBusinessContent:_Description:TEXT )   
				
				If XmlChildEx(oBusinessContent, "_WORKCENTERCODE") != NIL
					oModel:SetValue('CYBMASTER', 'CYB_CDCETR', oBusinessContent:_WorkCenterCode:TEXT ) 
				EndIf   
				
				If XmlChildEx(oBusinessContent, "_WORKCENTERDESCRIPTION") != NIL
					oModel:SetValue('CYBMASTER', 'CYB_DSCETR', oBusinessContent:_WorkCenterDescription:TEXT ) 
				EndIf  
				
				lAssign := oModel:SetValue('CYBMASTER', 'CYB_TPPC'  , oBusinessContent:_ProcessorType:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYBMASTER', 'CYB_TPMOD' , oBusinessContent:_LaborType:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYBMASTER', 'CYB_QTVMMQ', SFCXStoX(oBusinessContent:_VolumeMachineQuantity:TEXT, 'N') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYBMASTER', 'CYB_VLEFMQ', SFCXStoX(oBusinessContent:_EfficiencyMachineValue:TEXT, 'N') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYBMASTER', 'CYB_QTOEMQ', SFCXStoX(oBusinessContent:_OperatorMachineQuantity:TEXT, 'N') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYBMASTER', 'CYB_QTATSM', SFCXStoX(oBusinessContent:_SimultaneousActivityQuantity:TEXT, 'N') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYBMASTER', 'CYB_LGSU'  , SFCXStoX(oBusinessContent:_IsSetup:TEXT, 'L') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYBMASTER', 'CYB_LGVFSQ', SFCXStoX(oBusinessContent:_IsControlPert:TEXT, 'L') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYBMASTER', 'CYB_LGRPCN', SFCXStoX(oBusinessContent:_IsReportEvent:TEXT, 'L') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYBMASTER', 'CYB_LGOVRP', SFCXStoX(oBusinessContent:_IsOverlapReport:TEXT, 'L') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				
				If XmlChildEx(oBusinessContent, "_COSTCENTERCODE") != NIL
					lAssign := oModel:SetValue('CYBMASTER', 'CYB_CDCECS', oBusinessContent:_CostCenterCode:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				  
				If XmlChildEx(oBusinessContent, "_PRODUCTIONAREACODE") != NIL				
			   		lAssign := oModel:SetValue('CYBMASTER', 'CYB_CDARPO', oBusinessContent:_ProductionAreaCode:TEXT )   ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				           
 				// Recursos	
				For nI := 1 To oModelCYC:Length()
					oModelCYC:GoLine( nI )
					If !oModelCYC:IsDeleted()
				       	oModelCYC:DeleteLine()
					Endif
				Next                        
				
				If XmlChildEx(oBusinessContent, "_LISTOFRESOURCES") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfResources) > 0
					aResource := oBusinessContent:_ListOfResources:_Resource
					If ValType(aResource) == 'O'
						aResource := { aResource }
					EndIf
				EndIf
				
        		For nI := 1 To Len(aResource) 
					oModelCYC:AddLine()
				    oResourceContent := aResource[nI]
				    	     
					lAssign := oModelCYC:SetValue('CYC_CDMQ'  , oBusinessContent:_Code:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYC:SetValue('CYC_TPRC'  , oResourceContent:_ResourceType:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYC:SetValue('CYC_CDRC'  , oResourceContent:_ResourceCode:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYC:SetValue('CYC_NMRC'  , SFCXStoX(oResourceContent:_ResourceName:TEXT, 'C') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYC:SetValue('CYC_DTBGVD', SFCXStoX(oResourceContent:_StartExpirationDate:TEXT, 'D') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYC:SetValue('CYC_DTEDVD', SFCXStoX(oResourceContent:_EndExpirationDate:TEXT, 'D') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYC:SetValue('CYC_LGTEAT', SFCXStoX(oResourceContent:_IsTimeActivity:TEXT, 'L') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYC:SetValue('CYC_QTCI'  , SFCXStoX(oResourceContent:_CycleQuantity:TEXT, 'N') )	  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					
					// Campos que nao estao presentes no xmlschema - verificar
					//oModelCYC:SetValue('CYC_TPUNTE', SFCXStoX(oResourceContent:_UnitTimeType:TEXT, 'C') )		    	   	        
				Next				
                
                // Itens Controle
                For nI := 1 To oModelCYE:Length()
					oModelCYE:GoLine( nI )
					If !oModelCYE:IsDeleted()
				       	oModelCYE:DeleteLine()
					Endif
				Next
				
				If XmlChildEx(oBusinessContent, "_LISTOFCONTROLITEMS") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfControlItems) > 0
					aControlItems := oBusinessContent:_ListOfControlItems:_ControlItem
					If valType(aControlItem) == 'O'
						aControlItem := { aControlItem }
					EndIf
              	EndIf
				
				For nI := 1 To Len(aControlItem)
					oModelCYE:AddLine()    
				    oControlItemContent := aControlItem[nI]
				    	     
					lAssign := oModelCYE:SetValue('CYE_CDMQ'  , oBusinessContent:_Code:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYE:SetValue('CYE_CDVF'  , oControlItemContent:_ControlItemCode:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYE:SetValue('CYE_DSVF'  , SFCXStoX(oControlItemContent:_ControlItemDescription:TEXT, 'C') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					
					If XmlChildEx(oControlItemContent, '_MINVALUE') != NIL
						lAssign := oModelCYE:SetValue('CYE_VLVFMI', SFCXStoX(oControlItemContent:_MinValue:TEXT   , 'N') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYE:SetValue('CYE_VLVFMX', SFCXStoX(oControlItemContent:_MaxValue:TEXT   , 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					If XmlChildEx(oControlItemContent, '_MINDATE') != NIL
						lAssign := oModelCYE:SetValue('CYE_QTDYMI', SFCXStoX(oControlItemContent:_MinDate:TEXT	   , 'N') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
						lAssign := oModelCYE:SetValue('CYE_QTDYMX', SFCXStoX(oControlItemContent:_MaxDate:TEXT	   , 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					EndIf
					
					lAssign := oModelCYE:SetValue('CYE_NRMX'  , SFCXStoX(oControlItemContent:_MaxChoices:TEXT , 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYE:SetValue('CYE_LGVFOB', SFCXStoX(oControlItemContent:_IsMandatory:TEXT, 'L') )			    	   	        ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				Next
				
				// Turno
                For nI := 1 To oModelCYL:Length()
					oModelCYL:GoLine( nI )
					If !oModelCYL:IsDeleted()
				       	oModelCYL:DeleteLine()
					Endif
				Next
	   
				If XmlChildEx(oBusinessContent, "_LISTOFPRODUCTIONSHIFTS") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfProductionShifts) > 0
					aProductionShift := oBusinessContent:_ListOfProductionShifts:_ProductionShift
					If valType(aProductionShift) == 'O'
						aProductionShift := { aProductionShift }
					EndIf
              	EndIf
				
				For nI := 1 To Len(aProductionShift)
					oModelCYL:AddLine()    
				    oProductionShiftContent := aProductionShift[nI]
				    	     
					lAssign := oModelCYL:SetValue('CYL_CDMQ'  , oBusinessContent:_Code:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYL:SetValue('CYL_CDTN'  , oProductionShiftContent:_ProductionShiftCode:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYL:SetValue('CYL_DSTN'  , SFCXStoX(oProductionShiftContent:_ProductionShiftDescription:TEXT, 'C') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYL:SetValue('CYL_DTVDBG', SFCXStoX(oProductionShiftContent:_BeginDate:TEXT, 'D') ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYL:SetValue('CYL_DTVDED', SFCXStoX(oProductionShiftContent:_EndDate:TEXT  , 'D') ) 		    	   	        ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				Next

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
				cXMLRet := SFCXXtoS(aErro[6]) + ' (' + SFCXXtoS(aErro[4]) + ' = "' + SFCXXtoS(aErro[9]) + '")'
				lRet := .F.
			EndIf

			// Desativa o Model
			oModel:DeActivate()

	  // Mensagem é de Response
      ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
            //conout( '+ IntegDef SFCA002 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCA002 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}          
      EndIf
// Chamada é para envio, solicitada pelo MODEL      
ElseIf nTypeTrans == TRANS_SEND
      //conout( '+ IntegDef SFCA002 Enviando Mensagem' )
      
      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()
	  oModelCYC := oModel:GetModel('CYCDETAIL')
	  oModelCYE := oModel:GetModel('CYEDETAIL')
	  oModelCYL := oModel:GetModel('CYLDETAIL')

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet :=  FWEAIBusEvent( "Machine", oModel:GetOperation(), { { "Code", oModel:GetValue("CYBMASTER", 'CYB_CDMQ') } }  )         
       
      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'          


		cXMLRet += '<Code>' 						+ oModel:GetValue("CYBMASTER", 'CYB_CDMQ') 		+ '</Code>'
		cXMLRet += '<Description>' 					+ oModel:GetValue("CYBMASTER", 'CYB_DSMQ') 		+ '</Description>' 
			
		// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		If oModel:GetOperation() # 5                                                                                  
		
			cXMLRet += '<WorkCenterCode>' 	 			+ oModel:GetValue("CYBMASTER", 'CYB_CDCETR')  			+ '</WorkCenterCode>'
			cXMLRet += '<WorkCenterDescription>' 		+ oModel:GetValue("CYBMASTER", 'CYB_DSCETR')  			+ '</WorkCenterDescription>'
			cXMLRet += '<ProcessorType>' 	 			+ oModel:GetValue("CYBMASTER", 'CYB_TPPC')    			+ '</ProcessorType>'
			cXMLRet += '<LaborType>' 	 		     	+ oModel:GetValue("CYBMASTER", 'CYB_TPMOD') 			+ '</LaborType>'
			cXMLRet += '<VolumeMachineQuantity>' 		+ SFCXXtoS(oModel:GetValue("CYBMASTER", 'CYB_QTVMMQ')) 	+ '</VolumeMachineQuantity>'
			cXMLRet += '<EfficiencyMachineValue>'		+ SFCXXtoS(oModel:GetValue("CYBMASTER", 'CYB_VLEFMQ')) 	+ '</EfficiencyMachineValue>'
			cXMLRet += '<OperatorMachineQuantity>'		+ SFCXXtoS(oModel:GetValue("CYBMASTER", 'CYB_QTOEMQ')) 	+ '</OperatorMachineQuantity>'
			cXMLRet += '<SimultaneousActivityQuantity>'	+ SFCXXtoS(oModel:GetValue("CYBMASTER", 'CYB_QTATSM')) 	+ '</SimultaneousActivityQuantity>'
			cXMLRet += '<IsSetup>' 	 		   			+ SFCXXtoS(oModel:GetValue("CYBMASTER", 'CYB_LGSU')  )  + '</IsSetup>'
			cXMLRet += '<IsControlPert>' 	 			+ SFCXXtoS(oModel:GetValue("CYBMASTER", 'CYB_LGVFSQ')) 	+ '</IsControlPert>'
			cXMLRet += '<IsReportEvent>' 	 			+ SFCXXtoS(oModel:GetValue("CYBMASTER", 'CYB_LGRPCN')) 	+ '</IsReportEvent>'
			cXMLRet += '<IsOverlapReport>' 	 			+ SFCXXtoS(oModel:GetValue("CYBMASTER", 'CYB_LGOVRP')) 	+ '</IsOverlapReport>'
			cXMLRet += '<CostCenterCode>' 	 			+ oModel:GetValue("CYBMASTER", 'CYB_CDCECS') 			+ '</CostCenterCode>'
			cXMLRet += '<ProductionAreaCode>' 	 		+ oModel:GetValue("CYBMASTER", 'CYB_CDARPO')  			+ '</ProductionAreaCode>'
			
			// Recurso
			cXMLRet += '<ListOfResources>'
				For nI := 1 To oModelCYC:Length()
					oModelCYC:GoLine( nI )
				
				   	If !oModelCYC:IsDeleted()
				   		cXMLRet += '<Resource>' 
							cXMLRet += '<ResourceType>' 			+ oModelCYC:GetValue('CYC_TPRC') 				+ '</ResourceType>'
							cXMLRet += '<ResourceCode>' 			+ oModelCYC:GetValue('CYC_CDRC')			 	+ '</ResourceCode>'
				   	   		cXMLRet += '<ResourceName>'				+ oModelCYC:GetValue('CYC_NMRC') 				+ '</ResourceName>'
				   	   		cXMLRet += '<StartExpirationDate>'  	+ SFCXXtoS(oModelCYC:GetValue('CYC_DTBGVD'))	+ '</StartExpirationDate>'
							cXMLRet += '<EndExpirationDate>'	 	+ SFCXXtoS(oModelCYC:GetValue('CYC_DTEDVD'))	+ '</EndExpirationDate>'
				   	   		cXMLRet += '<IsTimeActivity>'	  		+ SFCXXtoS(oModelCYC:GetValue('CYC_LGTEAT'))	+ '</IsTimeActivity>'
				   	   		cXMLRet += '<CycleQuantity>'	  		+ SFCXXtoS(oModelCYC:GetValue('CYC_QTCI'))		+ '</CycleQuantity>'
				   	   		// Campos que nao estao presentes no xmlschema - verificar
				   	   		// cXMLRet += '<UnitTimeType>'	  			+ oModelCYC:GetValue('CYC_TPUNTE') 				+ '</UnitTimeType>'
				   		cXMLRet += '</Resource>'
				   	EndIf	      	        
				Next 	 
			cXMLRet += '</ListOfResources>'
					    	   	        		 
			cXMLRet += '<ListOfControlItems>'
				// Item Controle
				For nI := 1 To oModelCYE:Length()
					oModelCYE:GoLine( nI )
				
				   	If !oModelCYE:IsDeleted()
				   		cXMLRet += '<ControlItem>' 
							cXMLRet += '<ControlItemCode>' 			+ oModelCYE:GetValue('CYE_CDVF') 				+ '</ControlItemCode>'
							cXMLRet += '<ControlItemDescription>'	+ oModelCYE:GetValue('CYE_DSVF')			 	+ '</ControlItemDescription>'
				   	   		cXMLRet += '<MinValue>'					+ SFCXXtoS(oModelCYE:GetValue('CYE_VLVFMI')) 	+ '</MinValue>'
				   	   		cXMLRet += '<MaxValue>'				  	+ SFCXXtoS(oModelCYE:GetValue('CYE_VLVFMX'))	+ '</MaxValue>'
							cXMLRet += '<MaxChoices>'	 			+ SFCXXtoS(oModelCYE:GetValue('CYE_NRMX'))		+ '</MaxChoices>'
				   	   		cXMLRet += '<MinDate>'	  				+ SFCXXtoS(oModelCYE:GetValue('CYE_QTDYMI')) 	+ '</MinDate>'
				   	   		cXMLRet += '<MaxDate>'	  				+ SFCXXtoS(oModelCYE:GetValue('CYE_QTDYMX'))	+ '</MaxDate>'
				   	   		cXMLRet += '<IsMandatory>'	  			+ SFCXXtoS(oModelCYE:GetValue('CYE_LGVFOB'))	+ '</IsMandatory>'
				   		cXMLRet += '</ControlItem>'
				   	EndIf	      	        
				Next 
			cXMLRet += '</ListOfControlItems>'    
			
			cXMLRet += '<ListOfProductionShifts>'
				// Turno
				For nI := 1 To oModelCYL:Length()
					oModelCYL:GoLine( nI )
				
				   	If !oModelCYL:IsDeleted()
				   		cXMLRet += '<ProductionShift>' 
							cXMLRet += '<ProductionShiftCode>' 		 	+ oModelCYL:GetValue('CYL_CDTN') 				+ '</ProductionShiftCode>'
							cXMLRet += '<ProductionShiftDescription>'	+ oModelCYL:GetValue('CYL_DSTN')			 	+ '</ProductionShiftDescription>'
				   	   		cXMLRet += '<BeginDate>'					+ SFCXXtoS(oModelCYL:GetValue('CYL_DTVDBG')) 	+ '</BeginDate>'
				   	   		cXMLRet += '<EndDate>'				  		+ SFCXXtoS(oModelCYL:GetValue('CYL_DTVDED'))	+ '</EndDate>'
				   		cXMLRet += '</ProductionShift>'
				   	EndIf			    	   	          	        
				Next 
			cXMLRet += '</ListOfProductionShifts>'		
        EndIf 
		                
	    		
      cXMLRet += '</BusinessContent>'
      
EndIf

RestArea(aAreaCYB) 
RestArea(aArea) 
                        
ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)
*/
Return { lRet, cXMLRet }

Function INTDF_A002( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA002INI
Inicialização padrão dos campos.

@author Lucas Konrad França
@since 19/10/2017
@version P12
@obs Função executada a partir do dicionário de dados.
/*/
//-------------------------------------------------------------------
Function SFCA002INI()
	Local cValue := ""
	
	Default lAutomacao := .F.

	If !Empty(CYL->CYL_CDTN) .Or. lAutomacao
		cValue := Posicione("CYM",1,xFilial("CYM")+CYL->CYL_CDTN,"CYM_DSTN")
	EndIf
Return cValue
