#INCLUDE "SFCA006.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA006  
Tela de cadastro de Recurso

@author Tiago Gauziski
@since 13/08/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA006()
Local oBrowse

SFCValInt(.T.) // Verifica integração ligada

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CYH')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Recurso'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA006' OPERATION 2 ACCESS 0  // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA006' OPERATION 3 ACCESS 0  // 'Incluir'   
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA006' OPERATION 4 ACCESS 0  // 'Alterar'   
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA006' OPERATION 5 ACCESS 0  // 'Excluir'   
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA006' OPERATION 8 ACCESS 0  // 'Imprimir'   
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA006' OPERATION 9 ACCESS 0  // 'Copiar'
     
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCYH := FWFormStruct( 1, 'CYH', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA006', /*bPreValidacao*/, { |oX| SFCA006POS( oX ) }/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYHMASTER', /*cOwner*/, oStructCYH, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados de Recurso'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYHMASTER' ):SetDescription( STR0010 )   //'Dados de Dados de Recurso'  

oModel:GetModel( 'CYHMASTER' ):GetStruct():SetProperty( 'CYH_NMRC',  MODEL_FIELD_OBRIGAT,  .T. )

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA006' )
// Cria a estrutura a ser usada na View
Local oStructCYH := FWFormStruct( 2, 'CYH' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYH', oStructCYH, 'CYHMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYH', 'TELA' )

If SFCIntegra(.T.) == 1
	oStructCYH:RemoveField("CYI_CDMOD")
Endif

Return oView

//-------------------------------------------------------------------
// SFCA006VCD - Valida tamanho do campo
//-------------------------------------------------------------------
Function SFCA006VCD() 
Local lRet  := .T. 
Local cTipo := FwFldGet('CYH_TPRC')   
Local cCod  := FwFldGet('CYH_CDRC')
Local nTamanho := Len(ALLTRIM(FwFldGet('CYH_CDRC')))

Do Case
	Case cTipo == '1'
		If SFCIntegra(.T.) == 2
			IF nTamanho != 6
				SFCMsgErro(STR0025, "SFCA006") // 'Código do Operador deve possuir 6 posições'
	    		lRet := .F.
		  	Else	  		
	  			IF VAL(cCod) == 0
	  				SFCMsgErro(STR0026, "SFCA006") // 'Código de operador deverá possuir formato numérico com 6 posições'
			    	lRet := .F.
	  			Endif
	  		Endif
		Endif
	Case cTipo == '2'
		// Integração com Protheus
		If SFCIntegra(.T.) == 1
			IF Len(ALLTRIM(FwFldGet('CYH_CDRC'))) > 6
				SFCMsgErro(STR0015, "SFCA006") // 'Código da Ferramenta deve possuir no máximo 6 posições'
	    		lRet := .F.
	   		Endif
		// Integração com Datasul
		Else
			IF Len(ALLTRIM(FwFldGet('CYH_CDRC'))) > 16
				SFCMsgErro(STR0027, "SFCA006") // 'Código da Ferramenta deve possuir no máximo 16 posições'
	    		lRet := .F.
			Endif
	   	Endif
	Case cTipo == '3'
		If SFCIntegra(.T.) == 2 .AND. Len(ALLTRIM(FwFldGet('CYH_CDRC'))) > 8
			SFCMsgErro(STR0028, "SFCA006") // 'Código da Equipe deve possuir no máximo 8 posições'
    		lRet := .F.
		Endif
End Case

Return lRet
              
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA006POS 
Rotina para Validar os dados no momento da inclusão ou alteração
Uso Geral.

@param   oModel        Objeto do model principal
@author Tiago Gauziski
@since 03/08/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA006POS (oModel)
Local lRet      := .T.
local nOpc      := (oModel:GetOperation())
Local aArea     := GetArea()
Local aAreaCYH  := CYH->(GetArea())
Local aAreaCYC  := CYC->(GetArea())
Local aAreaCYB  := CYB->(GetArea())
Local aAreaCYI  := CYI->(GetArea())
Local aAreaCYX  := CYX->(GetArea())
Local aAreaCYW  := CYW->(GetArea())
Local aAreaCZ6  := CZ6->(GetArea())
Local aAreaCZ1  := CZ1->(GetArea())
Local aAreaCZ5  := CZ5->(GetArea())
Local aAreaCY9  := CY9->(GetArea())
Local aAreaCZ0  := CZ0->(GetArea())
Local oModelCZ1, oModelCYH
Local nI := 0
Local dDtIni
Local dDtFim
Local lIntgMES := PCPIntgPPI()

If nOpc == 3 .OR. nOpc == 4   
	If SFCIntegra(.T.) == 2 .And. !IsInCallStack("MNTA080") .And. FwFldGet("CYH_TPRC") == '4'
   		SFCMsgErro(STR0024, "SFCA006")  // 'Não é possível criar equipamento quando integrado com o Protheus'
		lRet := .F.          
	ElseIf FwFldGet('CYH_TPRC') == '2'
		IF Empty(FwFldGet('CYH_QTUNCI'))
			SFCMsgErro(STR0012, "SFCA006") // 'Unidades Ciclo deve ser informado'
			lRet := .F.
		Endif
		
		if SFCIntegra(.T.) == 2 .AND. Empty(FwFldGet('CYH_CDMPRC'))
			SFCMsgErro(STR0022, "SFCA006") // 'Item Ferramenta deve ser informado'
	    	lRet := .F.
		Endif
	Endif
	
	dbSelectArea("CYH")
   	CYH->(dbSetOrder(1))
	
	If lRet 
	
		if nOpc == 3         
		    If CYH->(dbSeek(xFilial('CYH')+FwFldGet('CYH_TPRC')+FwFldGet('CYH_CDRC')))
				SFCMsgErro(STR0013, "SFCA006") // 'Já existe Recurso com a chave informada'
				lRet := .F.
		    EndIf
		Else
			// Se alterou datas.. 
			if (CYH->CYH_DTVDBG != FwFldGet('CYH_DTVDBG')) .OR.;
			   (CYH->CYH_DTVDED != FwFldGet('CYH_DTVDED'))
			     
				// verificar datas do recurso quando ele já está relacionado à uma máquina
				dbSelectArea('CYC')
				CYC->(dbSetOrder(3))
				IF CYC->(dbSeek(xFilial('CYC')+CYH->CYH_IDRC))
				
					While CYC->(!EOF()) .AND. CYC->CYC_IDRC == CYH->CYH_IDRC
					
						IF CYC->CYC_DTBGVD < FwFldGet('CYH_DTVDBG')
							if dDtIni == nil .OR.;
							   dDtIni > CYC->CYC_DTBGVD
								dDtIni := CYC->CYC_DTBGVD
							Endif
						Endif
						
						if CYC->CYC_DTEDVD > FwFldGet('CYH_DTVDED')	
							if dDtFim == nil .OR.;
							   dDtFim < CYC->CYC_DTEDVD
								dDtFim := CYC->CYC_DTEDVD
							Endif
						Endif
					
						CYC->(dbSkip())
					End
				Endif
				
				if dDtIni != nil
					SFCMsgErro(STR0030 + DTOC(dDtIni) + STR0031, "SFCA006") // Data de validade inicial não pode ser maior que  ##  pois este recurso já está relacionado à uma máquina.
					lRet := .F.
				Endif
				
				if dDtFim != nil
					SFCMsgErro(STR0032 + DTOC(dDtFim) + STR0031, "SFCA006") // Data de validade final não pode ser menor que  ##  pois este recurso já está relacionado à uma máquina.
					lRet := .F.
				Endif								
			Endif
		
			// Valivar se ao colocar uma área ou trocar a área, se os operadores relacionados à máquina não ficam com área diferente
			IF FwFldGet('CYH_TPRC') == '1' .AND. !Empty(FwFldGet('CYH_CDARPO'))
				CYH->(dbSeek(xFilial('CYH')+FwFldGet('CYH_TPRC')+FwFldGet('CYH_CDRC')))		
				if FwFldGet('CYH_CDARPO') != CYH->CYH_CDARPO
			   
					dbSelectArea("CYC")
				   	CYC->(dbSetOrder(3))
				   	IF CYC->(dbSeek(xFilial('CYC')+FwFldGet('CYH_IDRC')))
				   		dbSelectArea("CYB")
					   	CYB->(dbSetOrder(1))
					   	if CYB->(dbSeek(xFilial('CYB')+CYC->CYC_CDMQ))
					   		dbSelectArea("CYI")
						   	CYI->(dbSetOrder(1))
						   	if CYI->(dbSeek(xFilial('CYI')+CYB->CYB_CDCETR)) .AND.;
						   	   CYI->CYI_CDARPO != FwFldGet('CYH_CDARPO')
						   		SFCMsgErro(STR0023 + CYB->CYB_CDMQ +; // Recurso está relacionado a uma máquina que possui uma Área de Produção diferente. Máquina:
						   		           STR0029 + CYI->CYI_CDARPO, "SFCA006") // Área de Produção:
								lRet := .F. 
						   	Endif
					   	Endif
					Endif
				Endif
			Endif
		Endif
    Endif 
    
    if lRet
    	lRet := SFCA006VCD()
    Endif 
    
    If lRet .And. FwFldGet('CYH_TPRC') != '2' .AND. (Empty(FwFldGet('CYH_DTVDBG')) .OR. Empty(FwFldGet('CYH_DTVDED')))
    	SFCMsgErro(STR0014, "SFCA006") // 'Datas de validade devem ser informadas'
		lRet := .F.
	Endif
	
	if lRet .AND. FwFldGet('CYH_TPRC') == '2' .AND. SFCIntegra(.T.) == 1 .AND. !IsInCallStack("A620IntSFC")
		IF Empty(FwFldGet('CYH_DTVDBG')) .OR. Empty(FwFldGet('CYH_DTVDED'))
			SFCMsgErro(STR0014, "SFCA006") // 'Datas de validade devem ser informadas'
			lRet := .F.
		Else
			lRet := AUTO620(nOpc,oModel)
		Endif
	EndIf
	//Integração TOTVS MES
	If lRet .And. lIntgMES .And. oModel:GetValue('CYHMASTER','CYH_TPRC') $ '12'
		lRet := SFCA006PPI(, oModel:GetValue('CYHMASTER','CYH_CDRC'), .F., .T., .F., oModel)
	EndIf
Else
	dbSelectArea('CYC')
	CYC->(dbSetOrder(3))
	IF CYC->(dbSeek(xFilial('CYC')+oModel:GetValue('CYHMASTER','CYH_IDRC')))
		SFCMsgErro(STR0016 + ALLTRIM(CYC->CYC_CDMQ), "SFCA006") //"Registro está sendo usado na Máquina "
    	lRet := .F.
	Endif  
	
	If lRet .And. FwFldGet('CYH_TPRC') == '1' // Operador
		dbSelectArea('CYW')
		CYW->(dbSetOrder(3))
		IF CYW->(dbSeek(xFilial('CYW')+oModel:GetValue('CYHMASTER','CYH_IDRC')))
			SFCMsgErro(STR0019 + ALLTRIM(CYW->CYW_NRSQRP), "SFCA006") //"Registro está sendo usado no Apontamento de Produção "
   			lRet := .F.
		Endif
		
		dbSelectArea('CYX')
		CYX->(dbSetOrder(9))
		IF CYX->(dbSeek(xFilial('CYX')+oModel:GetValue('CYHMASTER','CYH_CDRC')))
			SFCMsgErro(STR0017, "SFCA006") //"Registro está sendo usado em Apontamento de Parada"
	    	lRet := .F.
		Endif
		
		dbSelectArea('CZ6')
		CZ6->(dbSetOrder(1))
		IF CZ6->(dbSeek(xFilial('CZ6')+oModel:GetValue('CYHMASTER','CYH_CDRC')))
			SFCMsgErro(STR0017, "SFCA006") //"Registro está sendo usado em Apontamento de Parada"
	    	lRet := .F.
		Endif
		
		dbSelectArea('CZ1')
		CZ1->(dbSetOrder(2))
		IF CZ1->(dbSeek(xFilial('CZ1')+oModel:GetValue('CYHMASTER','CYH_IDRC')))
			SFCMsgErro(STR0020 + ALLTRIM(CZ1->CZ1_IDRCGR), "SFCA006") //"Registro está sendo usado na Equipe "
	    	lRet := .F.
		Endif
		
		dbSelectArea('CZ5')
		CZ5->(dbSetOrder(5))
		IF CZ5->(dbSeek(xFilial('CZ5')+oModel:GetValue('CYHMASTER','CYH_CDRC')))
			SFCMsgErro(STR0021, "SFCA006") //"Registro está sendo usado nos Indicadores da Produção "
	    	lRet := .F.
		Endif
		
	ElseIf lRet .And. FwFldGet('CYH_TPRC') == '2' // Ferramenta
		dbSelectArea('CYX')
		CYX->(dbSetOrder(8))
		IF CYX->(dbSeek(xFilial('CYX')+oModel:GetValue('CYHMASTER','CYH_CDRC')))
			SFCMsgErro(STR0017, "SFCA006") //"Registro está sendo usado em Apontamento de Parada"
	    	lRet := .F.
		Endif
	
		dbSelectArea('CY9')
		CY9->(dbSetOrder(4))
		IF CY9->(dbSeek(xFilial('CY9')+oModel:GetValue('CYHMASTER','CYH_CDRC')))
			SFCMsgErro(STR0018 + ALLTRIM(CY9->CY9_NRORPO), "SFCA006") //"Registro está sendo usado em Operação da Ordem de Produção "
    		lRet := .F.
		Endif
	
		dbSelectArea('CZ0')
		CZ0->(dbSetOrder(2))
		IF CZ0->(dbSeek(xFilial('CZ0')+oModel:GetValue('CYHMASTER','CYH_IDRC')))
			SFCMsgErro(STR0019 + ALLTRIM(CZ0->CZ0_NRSQRP), "SFCA006") //"Registro está sendo usado no Apontamento de Produção "
	   		lRet := .F.
		Endif
		
		dbSelectArea('CZ5')
		CZ5->(dbSetOrder(6))
		IF CZ5->(dbSeek(xFilial('CZ5')+oModel:GetValue('CYHMASTER','CYH_CDRC')))
			SFCMsgErro(STR0021, "SFCA006") //"Registro está sendo usado nos Indicadores da Produção "
	    	lRet := .F.
		Endif
		
	ElseIf lRet .And. FwFldGet('CYH_TPRC') == '3' // Equipe
		dbSelectArea('CYX')
		CYX->(dbSetOrder(10))
		IF CYX->(dbSeek(xFilial('CYX')+oModel:GetValue('CYHMASTER','CYH_CDRC')))
			SFCMsgErro(STR0017, "SFCA006") //"Registro está sendo usado em Apontamento de Parada"
	    	lRet := .F.
		Endif
		
		dbSelectArea('CYW')
		CYW->(dbSetOrder(4))
		IF CYW->(dbSeek(xFilial('CYW')+oModel:GetValue('CYHMASTER','CYH_IDRC')))
			SFCMsgErro(STR0019 + ALLTRIM(CYW->CYW_NRSQRP), "SFCA006") //"Registro está sendo usado no Apontamento de Produção "
   			lRet := .F.
		Endif
		
		dbSelectArea('CZ5')
		CZ5->(dbSetOrder(4))
		IF CZ5->(dbSeek(xFilial('CZ5')+oModel:GetValue('CYHMASTER','CYH_CDRC')))
			SFCMsgErro(STR0021, "SFCA006") //"Registro está sendo usado nos Indicadores da Produção "
	    	lRet := .F.
		Endif
		
		// Quando equipe, deve eliminar todos os registros de operadores relacionados
		dbSelectArea('CZ1')
		CZ1->(dbSetOrder(1))
		CZ1->(dbSeek(xFilial('CZ1')+oModel:GetValue('CYHMASTER','CYH_IDRC')))
		
		oModelCYH := FWLoadModel( 'SFCA012' ) 
		oModelCYH:SetOperation(4)
		oModelCYH:Activate()
			
		oModelCZ1 := oModelCYH:GetModel('CZ1DETAIL')
			
		For nI := 1 To oModelCZ1:GetQtdLine()
			oModelCZ1:GoLine(nI)
			oModelCZ1:DeleteLine()
		Next
			
		if oModelCYH:VldData()  
			oModelCYH:CommitData()
		Endif		
	Endif
	//Integração TOTVS MES
	If lRet .And. lIntgMES .And. oModel:GetValue('CYHMASTER','CYH_TPRC') $ '12'
		lRet := SFCA006PPI(, oModel:GetValue('CYHMASTER','CYH_CDRC'), .T., .T., .F., oModel)
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaCYH)
RestArea(aAreaCYC)
RestArea(aAreaCYB)
RestArea(aAreaCYI)
RestArea(aAreaCYX)
RestArea(aAreaCYW)
RestArea(aAreaCZ6)
RestArea(aAreaCZ1)
RestArea(aAreaCZ5)
RestArea(aAreaCY9)
RestArea(aAreaCZ0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AUTO620
Rotina para Integração com o Protheus - MATA620

@param   nOpc        Operação Executada
@param   oModel      Modelo de Dados

@author Bruno Candido Volpato da Cunha
@since 01/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function AUTO620(nOpc,oModel)
Local aDadosAuto := {} // Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica
Local nValid     := 0
Local lRetorno //Variável com Retorno 
Local lHelpDark := HelpInDark(.F.)
Local lHelp     := HelpLog(.T.)

Private lMsHelpAuto := .T. // Grava help no log
Private lMsErroAuto := .f.	// Determina se houve alguma inconsistencia na execucao da rotina em relacao aos
						
nModulo := 10
	
nValid := if(oModel:GetValue('CYHMASTER','CYH_DTVDED') < DATE(),0,oModel:GetValue('CYHMASTER','CYH_DTVDED') - DATE())
nValid := If(nValid > 99999, 99999, nValid)

If nOpc==3
	aDadosAuto := {{'H4_CODIGO' , oModel:GetValue('CYHMASTER','CYH_CDRC')	, Nil},;
				   {'H4_DESCRI'	, oModel:GetValue('CYHMASTER','CYH_NMRC')	, Nil},;	
				   {'H4_VIDAUTI', nValid									, Nil},;			
				   {'H4_TIPOVID', "D"					   					, Nil},;			
				   {'H4_DTAQUIS', oModel:GetValue('CYHMASTER','CYH_DTVDBG')	, Nil}}
ElseIf nOpc==4
	aDadosAuto := {{'H4_CODIGO' , oModel:GetValue('CYHMASTER','CYH_CDRC')	, Nil},;
			       {'H4_DESCRI'	, oModel:GetValue('CYHMASTER','CYH_NMRC')	, Nil},;	
				   {'H4_TIPOVID', "D"										, Nil},;				
				   {'H4_DTAQUIS', oModel:GetValue('CYHMASTER','CYH_DTVDBG') , Nil}}
Else
	aDadosAuto := {{'H4_CODIGO' , oModel:GetValue('CYHMASTER','CYH_CDRC')	, Nil}}
EndIf

MSExecAuto({|x,y| MATA620(x,y)},aDadosAuto,nOpc)
If lMsErroAuto 
	lRetorno := .F.
	If !IsTelNet()
		MostraErro()
	Else
		ErroTelnet()
	EndIf
Else
	lRetorno:=.T.
EndIf

HelpInDark(lHelpDark)
HelpLog(lHelp)

Return lRetorno
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local lRet     := .T.
Local lFound 
Local cXMLRet  := ""    
Local oXML
Local oBusinessContent
Local oBusinessEvent
Local nOpc     := 3
Local oModel
Local aArea    := GetArea()
Local aAreaCYH := CYH->(GetArea())
              
If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
	//ConOut('Envio a partir do programa de carga, ignorando...')
	Return { .T., 'Envio ignorado.' }
EndIf

// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE     

	  //ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCA006: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))

     
	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA006 Recebendo Mensagem Business' )
            
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
			oModel := FWLoadModel( 'SFCA006' )
			  
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CYH')
			CYH->(dbSetOrder(1))
			lFound := CYH->(dbSeek(xFilial('CYH')+oBusinessContent:_Type:TEXT+oBusinessContent:_Code:TEXT))
			
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
					lAssign := oModel:SetValue('CYHMASTER', 'CYH_TPRC', oBusinessContent:_Type:TEXT);If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYHMASTER', 'CYH_CDRC', oBusinessContent:_Code:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent, '_NAME') != NIL
			   		oModel:SetValue('CYHMASTER', 'CYH_NMRC'   , oBusinessContent:_Name:TEXT ) 
				EndIf
				
				If XmlChildEx(oBusinessContent, '_PRODUCTIONAREACODE') != NIL
				   	lAssign := oModel:SetValue('CYHMASTER', 'CYH_CDARPO' , oBusinessContent:_ProductionAreaCode:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYHMASTER', 'CYH_DSARPO' , oBusinessContent:_ProductionAreaDescription:TEXT )                                                                          ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				                                                             
				If XmlChildEx(oBusinessContent, '_TOOLCODE') != NIL				
					lAssign := oModel:SetValue('CYHMASTER', 'CYH_CDMPRC' , oBusinessContent:_ToolCode:TEXT ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYHMASTER', 'CYH_DSMPRC' , oBusinessContent:_ToolDescription:TEXT )   ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent, '_UNITCYCLEQUANTITY') != NIL
					lAssign := oModel:SetValue('CYHMASTER', 'CYH_QTUNCI' , SFCXStoX(oBusinessContent:_UnitCycleQuantity:TEXT, 'N') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent, '_LABORCODE') != NIL
					lAssign := oModel:SetValue('CYHMASTER', 'CYH_CDMOD'  , oBusinessContent:_LaborCode:TEXT )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
			    
			    If XmlChildEx(oBusinessContent, '_STARTEXPIRATIONDATE') != NIL
					lAssign := oModel:SetValue('CYHMASTER', 'CYH_DTVDBG' , SFCXStoX(oBusinessContent:_StartExpirationDate:TEXT, 'D' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYHMASTER', 'CYH_DTVDED' , SFCXStoX(oBusinessContent:_EndExpirationDate:TEXT, 'D') );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent, '_PRODUCTIONSHIFTNUMBER') != NIL
					lAssign := oModel:SetValue('CYHMASTER', 'CYH_NRTN'   , oBusinessContent:_ProductionShiftNumber:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
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
            //conout( '+ IntegDef SFCA006 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCA006 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}
      EndIf
// Chamada é para envio, solicitada pelo MODEL      
ElseIf nTypeTrans == TRANS_SEND
      //conout( '+ IntegDef SFCA006 Enviando Mensagem' )
      
      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet :=  FWEAIBusEvent( "Resource",oModel:GetOperation(), { { "Type", oModel:GetValue("CYHMASTER", "CYH_TPRC") }, { "Code", oModel:GetValue("CYHMASTER", "CYH_CDRC") } }  )          

      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'                                                                                                                     
                                                                                                               
		cXMLRet += '<Type>' 					  	 	+ oModel:GetValue("CYHMASTER", 'CYH_TPRC') 					+ '</Type>'
		cXMLRet += '<Code>' 					  	 	+ oModel:GetValue("CYHMASTER", 'CYH_CDRC') 					+ '</Code>'
		
		// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		If oModel:GetOperation() # 5
			cXMLRet += '<Name>'		 					+ oModel:GetValue("CYHMASTER", 'CYH_NMRC') 					+ '</Name>'
			cXMLRet += '<ProductionAreaCode>'			+ oModel:GetValue("CYHMASTER", 'CYH_CDARPO') 	   			+ '</ProductionAreaCode>'   
			cXMLRet += '<ProductionAreaDescription>'	+ oModel:GetValue("CYHMASTER", 'CYH_DSARPO')     			+ '</ProductionAreaDescription>'
			cXMLRet += '<UnitCycleQuantity>'			+ SFCXXtoS( oModel:GetValue("CYHMASTER", 'CYH_QTUNCI') ) 	+ '</UnitCycleQuantity>'
			cXMLRet += '<StartExpirationDate>'	 		+ SFCXXtoS( oModel:GetValue("CYHMASTER", 'CYH_DTVDBG') )   + '</StartExpirationDate>'
			cXMLRet += '<EndExpirationDate>' 			+ SFCXXtoS( oModel:GetValue("CYHMASTER", 'CYH_DTVDED') )	+ '</EndExpirationDate>'
			cXMLRet += '<ToolCode>'	   					+ oModel:GetValue("CYHMASTER", 'CYH_CDMPRC')     			+ '</ToolCode>'
			cXMLRet += '<ToolDescription>'				+ oModel:GetValue("CYHMASTER", 'CYH_DSMPRC') 	   			+ '</ToolDescription>'  
			cXMLRet += '<LaborCode>'		 	   		+ oModel:GetValue("CYHMASTER", 'CYH_CDMOD')     			+ '</LaborCode>'
			cXMLRet += '<ProductionShiftNumber>' 		+ oModel:GetValue("CYHMASTER", 'CYH_NRTN') 	   				+ '</ProductionShiftNumber>' 
        EndIf
		                
      cXMLRet += '</BusinessContent>'
      
EndIf

RestArea(aArea)
RestArea(aAreaCYH)
                        
//ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)


Return { lRet, cXMLRet }


Function INTDF_A006( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCA006PPI

Realiza a integração com o PC-Factory - PPI Multitask

@param cXml      - XML que será enviado. Caso não seja passado esse parametro, será realizada
                   a chamada do Adapter para criação do XML.
                   Se for passado esse parâmetro, não será exibida a mensagem de erro caso exista,
                   nem será considerado o filtro da tabela SOE. 
@param cRecurso  - Obrigatório quando utilizado o parâmetro cXml. Contém o código do recurso.
@param lExclusao - Indica se está chamando para rotina de exclusão de produto.
@param lFiltra   - Identifica se será realizado ou não o filtro do registro.
@param lPendAut  - Indica se será gerada a pendência sem realizar a pergunta para o usuário, caso ocorra algum erro.

@author  Lucas Konrad França
@version P118
@since   12/04/2016
@return  lRet  - Indica se a integração com o PC-Factory foi realizada. 
           .T. -> Integração Realizada
           .F. -> Integração não realizada.
/*/
//-------------------------------------------------------------------------------------------------
Function SFCA006PPI(cXml, cRecurso, lExclusao, lFiltra, lPendAut, oModel)
   Local aArea     := GetArea()
   Local aAreaCYH  := CYH->(GetArea())
   Local lRet      := .T.
   Local aRetXML   := {}
   Local aRetWS    := {}
   Local aRetData  := {}
   Local aRetArq   := {}
   Local cNomeXml  := ""
   Local cGerouXml := ""
   Local cOperacao := ""
   
   //Variável utilizada para identificar que está sendo executada a integração para o PPI dentro do MATI200.
   Private lRunPPI := .T.
   //Variável utilizada no filtro
   Private oModelCYH
   
   Default cXml      := ""
   Default cRecurso  := ""
   Default lExclusao := .F.
   Default lFiltra   := .T.
   Default lPendAut  := .F.
   Default oModel    := Nil

	If !Empty(oModel)
		oModelCYH := oModel:GetModel("CYHMASTER")
	EndIf

   If Empty(cXml)
      If lExclusao 
         cOperacao := Lower(STR0006) //"excluir"
      Else
         If INCLUI
            cOperacao := Lower(STR0004) //"incluir"
         Else
            cOperacao := Lower(STR0005) //"alterar"
         EndIf
      EndIf
   Else
      If PCPEvntXml(cXml) == "delete"
         lExclusao := .T.
      EndIf
   EndIf

   If Empty(cXml)
      cRecurso := oModel:GetValue("CYHMASTER","CYH_CDRC")
   EndIf

   //Realiza filtro na tabela SOE, para verificar se o produto entra na integração.
   If !Empty(cXml) .Or. !lFiltra .Or. PCPFiltPPI("CYH", cRecurso,"oModelCYH:GetValue('?')")
      //Adapter para criação do XML
      If Empty(cXml)
         SFCI006MOD(oModel)
         aRetXML := SFCI006("", TRANS_SEND, EAI_MESSAGE_BUSINESS)
         SFCI006MOD(Nil)
      Else
         aRetXML := {.T.,cXml}
      EndIf
      /*
         aRetXML[1] - Status da criação do XML
         aRetXML[2] - String com o XML
      */
      If aRetXML[1]
         //Retira os caracteres especiais
         aRetXML[2] := EncodeUTF8(aRetXML[2])
      
         //Busca a data/hora de geração do XML
         aRetData := PCPxDtXml(aRetXML[2])
         /*
            aRetData[1] - Data de geração AAAAMMDD
            aRetData[1] - Hora de geração HH:MM:SS
         */
      
         //Envia o XML para o PCFactory
         aRetWS := PCPWebsPPI(aRetXML[2])
         /*
            aRetWS[1] - Status do envio (1 - OK, 2 - Pendente, 3 - Erro.)
            aRetWS[2] - Mensagem de retorno do PPI
         */
      
         If aRetWS[1] != "1" .And. Empty(cXml)
            If lPendAut
               lRet := .T.
            Else
	            //"Atenção! Ocorreram erros na integração com o TOTVS MES. Erro: "
	            // XXXXXX
	            // XXXXXX
	            // "Deseja incluir/alterar/excluir a estrutura no protheus e gerar pendência para integração?"
	            If !MsgYesNo(STR0033 + AllTrim(aRetWS[2]) + CHR(10)+;
	                         STR0034 + AllTrim(cOperacao) + STR0035)
	               lRet := .F.
	            EndIf
	         EndIf
         EndIf
         
         If lRet
            //Cria o XML fisicamente no diretório parametrizado
            aRetArq := PCPXmLPPI(aRetWS[1],"CYH",cRecurso,aRetData[1],aRetData[2],aRetXML[2])
            /*
               aRetArq[1] Status da criação do arquivo. .T./.F.
               aRetArq[2] Nome do XML caso tenha criado. Mensagem de erro caso não tenha criado o XML.
            */
            If !aRetArq[1]
               If Empty(cXml) .And. !lPendAut
                  Alert(aRetArq[2])
               EndIf
            Else
               cNomeXml := aRetArq[2]
            EndIf
            If Empty(cNomeXml)
               cGerouXml := "2"
            Else
               cGerouXml := "1"
            EndIf
            //Cria a tabela SOF
            PCPCriaSOF("CYH",cRecurso,aRetWS[1],cGerouXml,cNomeXml,aRetData[1],aRetData[2],__cUserId,aRetWS[2],aRetXML[2])
            //Array com os componentes que tiveram erro.
            If Type('aIntegPPI') == "A"
               If aRetWS[1] != "1"
                  aAdd(aIntegPPI,{cRecurso,aRetWS[2]})
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf
   //Tratativa para retornar .F. mesmo quando é pendência automática;
   //Utilizado apenas para o programa de sincronização.
   If (AllTrim(FunName()) == "PCPA111") .And. Len(aRetWs) > 0 .And. aRetWS[1] != "1"
      lRet := .F.
   EndIf
   RestArea(aArea)
   CYH->(RestArea(aAreaCYH))
Return lRet	
