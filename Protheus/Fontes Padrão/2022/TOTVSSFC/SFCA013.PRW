#INCLUDE "SFCA013.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA013
Tela de cadastro de Calendário Genérico

@author Tiago Gauziski
@since 13/08/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA013()
Local oBrowse as object

Default lAutomacao := .F.

SFCValInt() // Verifica integração ligada

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CYG')
oBrowse:SetDescription( STR0001 )  // 'Cadastro de Calendário Genérico'

IF !lAutomacao
	oBrowse:Activate()
ENDIF

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA013' OPERATION 2 ACCESS 0  // 'Visualizar' 
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA013' OPERATION 3 ACCESS 0  // 'Incluir'   
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA013' OPERATION 4 ACCESS 0  // 'Alterar'    
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA013' OPERATION 5 ACCESS 0  // 'Excluir'    
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA013' OPERATION 8 ACCESS 0  // 'Imprimir'  
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA013' OPERATION 9 ACCESS 0  // 'Copiar'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCYG := FWFormStruct( 1, 'CYG', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStructCYZ := FWFormStruct( 1, 'CYZ', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA013', /*bPreValidacao*/, {|oMdl| SFCA013POS(oMdl) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYGMASTER', /*cOwner*/, oStructCYG, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ ) 

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'CYZDETAIL', 'CYGMASTER', oStructCYZ, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:GetModel( 'CYZDETAIL' ):SetMaxLine(999999999)    

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CYZDETAIL', { { 'CYZ_FILIAL', 'xFilial( "CYZ" )' }, { 'CYZ_CDCL', 'CYG_CDCL' } }, CYZ->(IndexKey(1)) )    

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'CYZDETAIL' ):SetUniqueLine( { 'CYZ_DTCL' } )

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'CYZDETAIL' ):SetOptional(.F.)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0010 ) //'Modelo de Dados de Calendário Genérico'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYGMASTER' ):SetDescription( STR0011 )     //'Dados de Dados de Calendário Genérico'
oModel:GetModel( 'CYZDETAIL' ):SetDescription( STR0012 )     //'Dados de Calendario do Calendário Genérico'

If SFCIntegra() == 2
	oModel:GetModel( 'CYGMASTER' ):GetStruct():SetProperty( 'CYG_CDCL',  MODEL_FIELD_TAMANHO, 9 )
Endif

Return oModel
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA013' )
// Cria a estrutura a ser usada na View
Local oStructCYG := FWFormStruct( 2, 'CYG' )
Local oStructCYZ := FWFormStruct( 2, 'CYZ' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYG', oStructCYG, 'CYGMASTER' )    

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid( 'VIEW_CYZ', oStructCYZ, 'CYZDETAIL' )                                                      

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 18 )
oView:CreateHorizontalBox( 'INFERIOR', 82 )    

//Adiciona um botao para inserir calendário genérico
oView:AddUserButton( STR0009, 'SFCA013', { |oMdl| SFCA013GER(oMdl) } )  // 'Gerar calendário'

//Remove o campo repetido em tela
oStructCYZ:RemoveField("CYZ_CDCL")

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYG', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CYZ', 'INFERIOR' ) 

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA013GER
Gera as datas automaticamente conforme solicitação do usuário

@author Ana Carolina Tomé Klock
@since 20/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA013GER( oModel )
    Local oDlg      := NIL										// Componentes da Tela
	Local oPanel    := NIL										// Componentes da Tela
	Local oRadio    := NIL          					        // Componentes da Tela
    Local acCombo   := { STR0013, STR0014 }          			// Itens do combobox - '1=Dia útil' ### '2=Descanso'
    Local nOpc      := oModel:GetOperation()
    Private aCombo  := { '2', '1', '1', '1', '1', '1', '2' }    // Valores do combobox    
    Private dDTBG   := date() - 30		 	    				// Data Inicial
    Private dDTED   := date()                  				 	// Data Final 
    Private alCombo := { .F., .T., .T., .T., .T., .T., .F. }    // Valores do checkbox

	Default lAutomacao := .F.
    
    if nOpc == 3 .OR. nOpc == 4 

		IF !lAutomacao
			Define MsDialog oDlg Title  STR0015 + AllTrim(oModel:GetModel('CYGMASTER'):GetValue('CYG_CDCL'))  From 00,00 To 350, 400 Pixel  // 'Gerar Calendário para '
			
				oSize := FWDefSize():New(.T.,,,oDlg)
				oSize:AddObject("Panel1", 100, 100, .T., .T. ) //Panel 1 em 100% da tela
			
				oSize:lProp := .T. //permite redimencionar as telas de acordo com a proporção do AddObject
				oSize:Process() //executa os calculos
				
				oPanel := TPanel():New(oSize:GetDimension("Panel1","LININI"),;
									oSize:GetDimension("Panel1","COLINI"),,oDlg,,,,,,;
									oSize:GetDimension("Panel1","XSIZE"),;
									oSize:GetDimension("Panel1","YSIZE"))
								
				@ 011,010 Say STR0016           	    Of oPanel COLOR CLR_BLACK Pixel        // 'Data Inicial: '
				@ 008,040 MsGet oDTRPINI    Var dDTBG     Size 50,10 Pixel Of oPanel      
				@ 011,107 Say STR0017              		Of oPanel COLOR CLR_BLACK Pixel        // 'Data Final: '
				@ 008,135 MsGet oDTRPFIM    Var dDTED     Size 50,10 Pixel Of oPanel
						
				@ 030,010 Say STR0018          	        Of oPanel COLOR CLR_BLACK Pixel 	   // 'Domingo: '
				oCombo1 := TComboBox():New( 028, 040, {|u| if( Pcount( )>0, aCombo[1] := u, aCombo[1] ) }, acCombo, 50, 10, oPanel, , , , , , .T., , , , , , , , , 'aCombo[1]'  )
				oCheck1 := TCheckBox():New( 030, 100, STR0025, {|u| if( Pcount( )>0, alCombo[1] := u, alCombo[1]) }, oPanel, 60, 07 )    // 'Permite Manutenção'
				
				@ 045,010 Say STR0019          	        Of oPanel COLOR CLR_BLACK Pixel // 'Segunda: '                    
				oCombo2 := TComboBox():New( 043, 040, {|u| if( Pcount( )>0, aCombo[2] := u, aCombo[2] ) }, acCombo, 50, 10, oPanel, , , , , , .T., , , , , , , , , 'aCombo[2]'  )
				oCheck1 := TCheckBox():New( 045, 100, STR0025, {|u| if( Pcount( )>0, alCombo[2] := u, alCombo[2]) }, oPanel, 60, 07 )    // 'Permite Manutenção'
				
				@ 060,010 Say STR0020          	        Of oPanel COLOR CLR_BLACK Pixel   // 'Terça: '                 
				oCombo3 := TComboBox():New( 058, 040, {|u| if( Pcount( )>0, aCombo[3] := u, aCombo[3] ) }, acCombo, 50, 10, oPanel, , , , , , .T., , , , , , , , , 'aCombo[3]'  )
				oCheck3 := TCheckBox():New( 060, 100, STR0025, {|u| if( Pcount( )>0, alCombo[3] := u, alCombo[3]) }, oPanel, 60, 07 )    // 'Permite Manutenção'
				
				@ 075,010 Say STR0021          	        Of oPanel COLOR CLR_BLACK Pixel   // 'Quarta: '                 
				oCombo4 := TComboBox():New( 073, 040, {|u| if( Pcount( )>0, aCombo[4] := u, aCombo[4] ) }, acCombo, 50, 10, oPanel, , , , , , .T., , , , , , , , , 'aCombo[4]'  )
				oCheck4 := TCheckBox():New( 075, 100, STR0025, {|u| if( Pcount( )>0, alCombo[4] := u, alCombo[4]) }, oPanel, 60, 07 )    // 'Permite Manutenção'
				
				@ 090,010 Say STR0022          	        Of oPanel COLOR CLR_BLACK Pixel  // 'Quinta: '                  
				oCombo5 := TComboBox():New( 088, 040, {|u| if( Pcount( )>0, aCombo[5] := u, aCombo[5] ) }, acCombo, 50, 10, oPanel, , , , , , .T., , , , , , , , , 'aCombo[5]'  )
				oCheck5 := TCheckBox():New( 090, 100, STR0025, {|u| if( Pcount( )>0, alCombo[5] := u, alCombo[5]) }, oPanel, 60, 07 )    // 'Permite Manutenção'
				
				@ 105,010 Say STR0023          	        Of oPanel COLOR CLR_BLACK Pixel  // 'Sexta: '                    
				oCombo6 := TComboBox():New( 103, 040, {|u| if( Pcount( )>0, aCombo[6] := u, aCombo[6] ) }, acCombo, 50, 10, oPanel, , , , , , .T., , , , , , , , , 'aCombo[6]'  )
				oCheck6 := TCheckBox():New( 105, 100, STR0025, {|u| if( Pcount( )>0, alCombo[6] := u, alCombo[6]) }, oPanel, 60, 07 )    // 'Permite Manutenção'
				
				@ 120,010 Say STR0024  	       	        Of oPanel COLOR CLR_BLACK Pixel  // 'Sábado: '                  
				oCombo7 := TComboBox():New( 118, 040, {|u| if( Pcount( )>0, aCombo[7] := u, aCombo[7] ) }, acCombo, 50, 10, oPanel, , , , , , .T., , , , , , , , , 'aCombo[7]'  )
				oCheck7 := TCheckBox():New( 120, 100, STR0025, {|u| if( Pcount( )>0, alCombo[7] := u, alCombo[7]) }, oPanel, 60, 07 )    // 'Permite Manutenção'
				
			Activate MsDialog oDlg Centered On Init EnchoiceBar( oDlg, { || If( SFCA013VAL(oModel), oDlg:End(), NIL) }, { || oDlg:End() } )  
		ENDIF
	Endif

Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA013VAL
Valida os parâmetros inseridos pelo usuário 

@author Ana Carolina Tomé Klock
@since 25/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA013VAL( oModel )   
    Local lRet      := Nil
	Local nWeekDay  := 0
	LocAL nCount    := 0
    Local lSobrepoe := .T.
    Local lPergunta := .T.   
    
	If (DTOS(dDTBG) > DTOS(dDTED))
		Help( ,, 'Help',, STR0026, 1, 0 ) // 'A data inicial deve ser menor que a data final'
    	lRet := .F.
	Else                                                                                                  
   		While (dDTBG <= dDTED)                                                                        
			If !oModel:GetModel('CYZDETAIL'):SeekLine( { {'CYZ_DTCL', dDTBG} } )
				If !Empty( oModel:GetModel('CYZDETAIL'):GetValue('CYZ_DTCL') )
					oModel:GetModel('CYZDETAIL'):AddLine()
				EndIf    
				nWeekDay := Dow( dDTBG )              
				oModel:GetModel('CYZDETAIL'):SetValue( 'CYZ_CDCL', oModel:GetModel('CYGMASTER'):GetValue('CYG_CDCL') )
				oModel:GetModel('CYZDETAIL'):SetValue( 'CYZ_DTCL', dDTBG )
				oModel:GetModel('CYZDETAIL'):SetValue( 'CYZ_TPDY', aCombo[nWeekDay] )
				oModel:GetModel('CYZDETAIL'):SetValue( 'CYZ_LGMN', aLCombo[nWeekDay] )        
			Elseif lSobrepoe
				For nCount := 1 to oModel:GetModel('CYZDETAIL'):Length()
				    If oModel:GetModel('CYZDETAIL'):GetValue('CYZ_DTCL', nCount) == dDTBG
				    
				    	IF lPergunta
				    		IF !MSGYESNO(STR0033) // 'Existem registros na faixa de datas informada. Deseja sobrepor?'
				    			lSobrepoe := .F.
				    		Endif
				    		
				    		lPergunta := .F.
				    	Endif
				    	
				    	if lSobrepoe				    
					    	nWeekDay := Dow( dDTBG )  
					    	oModel:GetModel('CYZDETAIL'):SetValue( 'CYZ_CDCL', oModel:GetModel('CYGMASTER'):GetValue('CYG_CDCL') )
							oModel:GetModel('CYZDETAIL'):SetValue( 'CYZ_DTCL', dDTBG )
							oModel:GetModel('CYZDETAIL'):SetValue( 'CYZ_TPDY', aCombo[nWeekDay] )
							oModel:GetModel('CYZDETAIL'):SetValue( 'CYZ_LGMN', aLCombo[nWeekDay] )  
						Endif
						
						Exit
				    EndIf
				Next
			EndIf	      
			dDTBG += 1 
		End 
		lRet := .T.
	EndIf          
	oModel:GetModel('CYZDETAIL'):GoLine(1)
  
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA013POS
Pós-Validação SFCA013 - Faz a chamada da Integração do Protheus

@param   oModel      Modelo de Dados

@author Bruno Candido Volpato da Cunha
@since 01/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA013POS(oModel)
Local lRet 		:= .T.
Local nOpc 		:= oModel:GetOperation()
Local oModelCYG := oModel:GetModel('CYGMASTER')
Local aArea     := GetArea()
Local aAreaCYA  := CYA->(GetArea())
Local aAreaCYI  := CYI->(GetArea())

Default lAutomacao := .F.

IF nOpc == 5
	dbSelectArea('CYA')
	CYA->(dbSetOrder(3))
	IF CYA->(dbSeek(xFilial('CYA')+oModelCYG:GetValue('CYG_CDCL')))
		SFCMsgErro(STR0030 + ALLTRIM(CYA->CYA_CDARPO), 'SFCA013') //"Registro está sendo usado na Área de Produção "
    	lRet := .F.
	Endif
	
	dbSelectArea('CYI')
	CYI->(dbSetOrder(3))
	IF CYI->(dbSeek(xFilial('CYI')+oModelCYG:GetValue('CYG_CDCL')))
		SFCMsgErro(STR0031 + ALLTRIM(CYI->CYI_CDCETR), 'SFCA013') //"Registro está sendo usado no Centro de Trabalho "
    	lRet := .F.
	Endif
	
	if PADR(GetMv("MV_SFCCDCL"),TamSx3("CYG_CDCL")[1],"") == oModelCYG:GetValue('CYG_CDCL')
	
		SFCMsgErro(STR0032, 'SFCA013') //"Registro está sendo usado no parâmetro MV_SFCCDCL (Calendário Padrão)"
    	lRet := .F.
	Endif
Endif

if lRet .AND. SFCIntegra() == 1 .AND. !IsInCallStack("A640IntSFC") .Or. lAutomacao
	lRet := AUTO640(nOpc,oModel)
Endif

RestArea(aAreaCYA)
RestArea(aAreaCYI)
RestArea(aArea)

Return lRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} AUTO640
Rotina para Integração com o Protheus - MATA640

@param   nOpc        Operação Executada
@param   oModel      Modelo de Dados

@author Bruno Candido Volpato da Cunha
@since 01/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function AUTO640(nOpc,oModel)
Local oModelCYZ := oModel:GetModel('CYZDETAIL')
Local oModelCYG := oModel:GetModel('CYGMASTER')
Local nI		:= 0
Local dMenor    := CTOD('31/12/9999')
Local lRet      := .T.
Local nTpDiaAnt := ''
Local lHelpDark := HelpInDark(.F.)
Local lHelp     := HelpLog(.T.)
Local aArea     := GetArea()
Local aAreaCYZ  := CYZ->(GetArea())
Local cCalenPad := PadR(SuperGetMV("MV_SFCCDCL",.F.,""),TamSX3("CYZ_CDCL")[1])

Private lMsHelpAuto := .T. // Grava help no log
Private lMsErroAuto := .F.	// Determina se houve alguma inconsistencia na execucao da rotina em relacao aos

Default lAutomacao := .F.

If nOpc # 5 .Or. lAutomacao
	If oModelCYG:GetValue('CYG_CDCL') == cCalenPad
 
		For nI := 1 to oModelCYZ:Length()
			oModelCYZ:GoLine(nI)
			nTpDiaAnt := ''
		 
			dbSelectArea('CYZ')
			CYZ->(dbSetOrder(1))
			CYZ->(dbGoTop())
		
			if CYZ->(dbSeek(xFilial('CYZ')+oModelCYG:GetValue('CYG_CDCL')+DTOS(oModelCYZ:GetValue('CYZ_DTCL'))))  .Or. lAutomacao
			    nTpDiaAnt := CYZ->CYZ_TPDY
   			Endif


			If (oModelCYZ:GetValue('CYZ_TPDY') == '2' .Or. oModelCYZ:GetValue('CYZ_TPDY') == '3') .AND.;
			   ((oModelCYZ:IsUpdated() .AnD. nTpDiaAnt <> oModelCYZ:GetValue('CYZ_TPDY')) .OR. oModelCYZ:IsInserted()) .Or. lAutomacao
			
				aDados    := {}// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica 
				aItens    := {}// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica 
				aCab      := {}// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica 
									
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   				//³Quando se tratar de inclusao deverao ser passados os dados de cabecalho e itens contendo ³
   				//³array com os intervalos de horas para a data especificada no cabecalho.                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If oModelCYZ:GetValue('CYZ_TPDY') == '2'
					aCab := {{"H9_DTINI"  ,oModelCYZ:GetValue('CYZ_DTCL') , Nil},;
							 {"H9_RECURSO","", Nil},;      
							 {"H9_CCUSTO" ,"", Nil},;
							 {"H9_MOTIVO" ,STR0034, Nil}} //"Descanso"
				Else								
					aCab := {{"H9_DTINI"  ,oModelCYZ:GetValue('CYZ_DTCL') , Nil},;
							 {"H9_RECURSO","", Nil},;      
							 {"H9_CCUSTO" ,"", Nil},;
							 {"H9_MOTIVO" ,STR0029, Nil}} //"Feriado"   
			 	EndIf
			 
	   			aAdd(aItens,{})
			        
   				MSExecAuto({|v,x,y,z| MATA640(v,x,y,z)},.F.,3,aCab,aItens)

				If lMsErroAuto 
					lRet := .F.
					If !IsTelNet()
						IF !lAutomacao
							MostraErro()
						ENDIF
					Else
						ErroTelnet()
					EndIf
					Exit
				Else
					lRet:=.T.
	   			EndIf  
			ElseIf ((oModelCYZ:IsUpdated() .OR. oModelCYZ:IsInserted()) .AND. (oModelCYZ:GetValue('CYZ_TPDY') == '1') .AND. nTpDiaAnt <> '') .OR. oModelCYZ:IsDeleted(nI)
		
				aDados    := {}// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica 
				aItens    := {}// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica 
				aCab      := {}// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica 
									
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   				//³Quando se tratar de inclusao deverao ser passados os dados de cabecalho e itens contendo ³
   				//³array com os intervalos de horas para a data especificada no cabecalho.                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCab := {{"H9_DTINI"  ,oModelCYZ:GetValue('CYZ_DTCL') , Nil}} 
			 
   				aAdd(aItens,{})
	        
   				MSExecAuto({|v,x,y,z| MATA640(v,x,y,z)},.F.,5,aCab,aItens)

				If lMsErroAuto 
					lRet := .F.
					If !IsTelNet()
						MostraErro()
					Else
						ErroTelnet()
					EndIf
					Exit
				Else
					lRet:=.T.
	   			EndIf
			EndIf
		Next
	EndIf
EndIf

RestArea(aAreaCYZ)
RestArea(aArea)
 
HelpInDark(lHelpDark)
HelpLog(lHelp)

Return lRet
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local lRet     := .T.
Local lFound 
Local cXMLRet  := ""    
Local oXML
Local oBusinessContent
Local oCalendarContent
Local oBusinessEvent
Local nOpc := 3
Local oModel
Local oModelCYZ
Local nI, nJ, nK := 1, nX := 1
Local aCalendar := {}
Local aArea     := GetArea()
Local aAreaCYG  := CYG->(GetArea())

Default lAutomacao := .F.

IF !lAutomacao
	If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
		//ConOut('Envio a partir do programa de carga, ignorando...')
		Return { .T., 'Envio ignorado.' }
	EndIf
ENDIF

// Se mensagem for de Recebimento
If IIF(!lAutomacao, nTypeTrans == TRANS_RECEIVE, .F. )         

	  //ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCA013: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))


	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA013 Recebendo Mensagem Business' )
            
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
			oModel := FWLoadModel( 'SFCA013' )
			oModelCYZ := oModel:GetModel('CYZDETAIL')
			  
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CYG')
			CYG->(dbSetOrder(1))
			lFound := CYG->(dbSeek(xFilial('CYG') + PadR(oBusinessContent:_Code:TEXT, Len(CYG_CDCL))))
			
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
					lAssign := oModel:SetValue('CYGMASTER', 'CYG_CDCL', oBusinessContent:_Code:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				lAssign := oModel:SetValue('CYGMASTER', 'CYG_DSCL'  , oBusinessContent:_Description:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf                      
				
				If XmlChildEx(oBusinessContent, "_LISTOFCALENDARS") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfCalendars) > 0
	            	aCalendar := oBusinessContent:_ListOfCalendars:_Calendar
					If ValType(aCalendar) == 'O'
						aCalendar := { aCalendar }
					EndIf                                                                                                                              
				EndIf                                                                                                                                  
				
				
				//Limitação Model
				/*
				If Len(aCalendar) >= 990
					Return {.F., 'Limite de linhas (990) foi excedido para Calendario Generico ' + oBusinessContent:_Code:TEXT + '. Verificar mensagem.'}
				EndIf
				*/

				For nI := 1 To oModelCYZ:Length()
					oModelCYZ:GoLine( nI )
					If Len(aCalendar) > 0 .And. !Empty(oModelCYZ:GetValue('CYZ_DTCL'))
						nJ := 1 
						nX := 1
						While (nJ <= nK)
							If SFCXStoX( aCalendar[nJ]:_CalendarDate:TEXT,'D' ) == oModelCYZ:GetValue('CYZ_DTCL') 
								lAssign := oModelCYZ:SetValue('CYZ_CDCL', oBusinessContent:_Code:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
				  				lAssign := oModelCYZ:SetValue('CYZ_LGMN', SFCXStoX(aCalendar[nJ]:_IsMaintanence:TEXT, 'L') );If !lAssign; Return SFCXMKERR(oModel); EndIf
								lAssign := oModelCYZ:SetValue('CYZ_TPDY', SFCXStoX(aCalendar[nJ]:_DayType:TEXT, 'C') );If !lAssign; Return SFCXMKERR(oModel); EndIf
								ADel( aCalendar, nJ )        
								ASize( aCalendar, len(aCalendar)-1 )
								nK := len(aCalendar)
								nX := 0
								Exit
							EndIf
							nJ++   
						End 
						If nX != 0
							oModelCYZ:DeleteLine()
						EndIf    
					Else
				   		oModelCYZ:DeleteLine()
					EndIf
				Next   
				
    			For nI := 1 To Len(aCalendar) 
					oCalendarContent := aCalendar[nI]
					oModelCYZ:AddLine() 
				    lAssign := oModelCYZ:SetValue('CYZ_CDCL'  , oBusinessContent:_Code:TEXT );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYZ:SetValue('CYZ_DTCL'  , SFCXStoX(oCalendarContent:_CalendarDate:TEXT , 'D') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYZ:SetValue('CYZ_LGMN'  , SFCXStoX(oCalendarContent:_IsMaintanence:TEXT, 'L') );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCYZ:SetValue('CYZ_TPDY'  , SFCXStoX(oCalendarContent:_DayType:TEXT      , 'C') );If !lAssign; Return SFCXMKERR(oModel); EndIf
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
            //conout( '+ IntegDef SFCA013 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCA013 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}
      EndIf
// Chamada é para envio, solicitada pelo MODEL      
ElseIf IIF(!lAutomacao, nTypeTrans == TRANS_SEND, .T. )  
      //conout( '+ IntegDef SFCA013 Enviando Mensagem' )
      
      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()
	  oModelCYZ := oModel:GetModel('CYZDETAIL')

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet :=  FWEAIBusEvent( "GenericCalendar", oModel:GetOperation(), { { "Code", oModel:GetValue("CYGMASTER", 'CYG_CDCL') } }  )         
       
      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'          


		cXMLRet += '<Code>' 						+ oModel:GetValue("CYGMASTER", 'CYG_CDCL') 		+ '</Code>'
			
		// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		If oModel:GetOperation() # 5                                                                                  
		
			cXMLRet += '<Description>' 					+ oModel:GetValue("CYGMASTER", 'CYG_DSCL') 		+ '</Description>' 
			
			// Recurso
			cXMLRet += '<ListOfCalendars>'
				For nI := 1 To oModelCYZ:Length()
					oModelCYZ:GoLine( nI )
				
				   	If !oModelCYZ:IsDeleted()
				   		cXMLRet += '<Calendar>' 
							cXMLRet += '<CalendarDate>'    			+ SFCXXtoS(oModelCYZ:GetValue('CYZ_DTCL'))		+ '</CalendarDate>'
							cXMLRet += '<IsMaintanence>' 			+ SFCXXtoS(oModelCYZ:GetValue('CYZ_LGMN'))	 	+ '</IsMaintanence>'
				   	   		cXMLRet += '<DayType>'			  		+ oModelCYZ:GetValue('CYZ_TPDY') 				+ '</DayType>'
				   		cXMLRet += '</Calendar>'
				   	EndIf	      	        
				Next 	 
			cXMLRet += '</ListOfCalendars>'

        EndIf 		                
	    		
      cXMLRet += '</BusinessContent>'
      
EndIf

RestArea(aAreaCYG)
RestArea(aArea) 
                        
//ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)


Return { lRet, cXMLRet }

Function INTDF_A013( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)
