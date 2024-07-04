#INCLUDE "SFCA312.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

#DEFINE  CABECALHO "CYT_CDMQ/CYT_DTRP/CYT_HRRP/CYT_HCRP/CYT_DTSQVF/CYT_HRSQVF/CYT_HCSQVF/CYT_DSMQ/"

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA312
Tela de Apontamento de Item de Controle

@author Samantha Preima
@since 28/09/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA312()
Private oBrowse

Default lAutomacao := .F.

SFCValInt() // Verifica integração ligada

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( 'CYT' )
oBrowse:SetDescription( STR0001 ) // 'Apontamento de Item de Controle'
IF !lAutomacao
	oBrowse:Activate()
ENDIF
Return NIL

//-------------------------------------------------------------------
Function SFCA312CMM(oModel)
	FWFormCommit( oModel ) // Salva os campos padrões do model
Return .T.

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0027 ACTION 'VIEWDEF.SFCA312' OPERATION 2 ACCESS 0     // 'Visualizar'
ADD OPTION aRotina TITLE STR0028 ACTION 'VIEWDEF.SFCA312' OPERATION 3 ACCESS 0     // 'Incluir' 
ADD OPTION aRotina TITLE STR0029 ACTION 'VIEWDEF.SFCA312' OPERATION 4 ACCESS 0     // 'Alterar' 
ADD OPTION aRotina TITLE STR0030 ACTION 'VIEWDEF.SFCA312' OPERATION 5 ACCESS 0     // 'Eliminar'   

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCYT := FWFormStruct( 1, 'CYT', { |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } ,/*lViewUsado*/ )
Local oStruDet := FWFormStruct( 1, 'CYT', { |cCampo| !AllTrim( cCampo ) + '/' $ CABECALHO } ,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'SFCA312', /*pre*/, { | oMdl | SFCA312POS( oMdl ) }, { | oMdl | SFCA312CMM( oMdl ), SFCA311PER() },{ || SFCA311PER() },, )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYTMASTER', /*cOwner*/, oStruCYT )

oModel:AddGrid( 'CYTDETAIL', 'CYTMASTER', oStruDet,{ |oGrid,nLine,cAcao,cCampo| IF(cCampo=='CYT_DSRS',SFCA312LPRE(oGrid, nLine, cAcao, cCampo ),.T.) },{ | oGrid | SFCA312LPOS( oGrid ) },,,{ | oGrid | SFCA312LOAD( oGrid ) } )

oModel:SetRelation( 'CYTDETAIL', { { 'CYT_FILIAL', 'xFilial( "CYT" )' } , { 'CYT_CDMQ', 'CYT_CDMQ' }, { 'CYT_DTSQVF', 'DTOS(CYT_DTSQVF)' } , { 'CYT_HRSQVF', 'CYT_HRSQVF' }}, CYT->( IndexKey( 1 ) ) )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 ) //'Apontamento de Item de Controle'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYTMASTER' ):SetDescription( STR0001 ) //'Apontamento de Item de Controle'
oModel:GetModel( 'CYTDETAIL' ):SetDescription( STR0002 ) //'Itens de Controle'

oModel:SetPrimaryKey( { 'CYT_CDMQ', 'CYT_DTSQVF', 'CYT_HRSQVF', 'CYT_CDVF' } )

oModel:GetModel( 'CYTDETAIL' ):SetNoInsertLine(.T.)
oModel:GetModel( 'CYTDETAIL' ):SetNoUpdateLine(.T.) 

oStruDet:SetProperty( 'CYT_DTRS', MODEL_FIELD_WHEN, {|| SFCA312WHE(1) } ) 
oStruDet:SetProperty( 'CYT_VLRS', MODEL_FIELD_WHEN, {|| SFCA312WHE(2) } ) 
oStruDet:SetProperty( 'CYT_DSRS', MODEL_FIELD_WHEN, {|| SFCA312WHE(3) } ) 

oModel:SetActivate( { |oModel| SFCA312PRE( oModel ) } )  

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCYT := FWFormStruct( 2, 'CYT' ,{ |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } )
Local oStruDet := FWFormStruct( 2, 'CYT' ,{ |cCampo| !AllTrim( cCampo ) + '/' $ CABECALHO } )
Local oModel   := FWLoadModel( 'SFCA312' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYT', oStruCYT, 'CYTMASTER' )

oView:AddGrid( 'VIEW_DET', oStruDET, 'CYTDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'PAI'  ,  30 )
oView:CreateHorizontalBox( 'FILHO',  70 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYT', 'PAI'   )
oView:SetOwnerView( 'VIEW_DET', 'FILHO' )

If GetMv("MV_SFCTPRE") == '2'
	oStruCYT:RemoveField('CYT_HRSQVF')
	oStruCYT:RemoveField('CYT_HRRP')
Else
	oStruCYT:RemoveField('CYT_HCSQVF')
	oStruCYT:RemoveField('CYT_HCRP')	
EndIf

oView:AddUserButton( STR0031, 'CLIPS', { |oView| SFCA312VFTabela() } )

Return oView

//-------------------------------------------------------------------
// SFCA312PRE
//-------------------------------------------------------------------
Static Function SFCA312PRE(oModel)
Local lRet := .T.

Default lAutomacao := .F.

if (oModel:GetOperation() == 3 .AND. IsInCallStack('SFCA310')) .OR. lAutomacao 
	oModel:SetValue('CYTMASTER','CYT_CDMQ', _MaqSFC310)
Endif

Return lRet

//-------------------------------------------------------------------
// Função when de campo
//-------------------------------------------------------------------
Function SFCA312WHE(nTipo)
Local lRet  := .F.
Local cTipo := ''
Local oModel := FwModelActive()

Default lAutomacao := .F.

oModel := oModel:GetModel('CYTDETAIL')

dbSelectArea('CYK')
CYK->(dbSetOrder(1))
IF (CYK->(dbSeek(xFilial('CYK')+oModel:GetValue('CYT_CDVF')))) .OR. lAutomacao
	cTipo := CYK->CYK_TPRS
Endif

Do Case
	Case nTipo == 1 // Data
		IF cTipo == '4'
			lRet := .T.
		Endif
	Case nTipo == 2 // Numérico 
		if cTipo == '1'
			lRet := .T.
		Endif
	Case nTipo == 3 // Observação
		IF cTipo == '3'
			lRet := .T.
		ElseIf cTipo == '2' .AND. IsInCallStack('SFCA320')
			lRet := .T.
		Endif
End Case

Return lRet
 
//-------------------------------------------------------------------
// Função executada no antes de entrar na linha
//-------------------------------------------------------------------
Static Function SFCA312LPRE(oGrid, nLine, cAcao, cCampo)
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaCYK := CYK->( GetArea() )

Default lAutomacao := .F.

IF IsInCallStack('SFCA320')
	lRet := .T.
Else
	if (!IsInCallStack( 'SFCA312DET' ) .AND. cAcao == 'SETVALUE' .Or. IsInCallStack('ACDV312')) .OR. lAutomacao

		dbSelectArea('CYK')
		CYK->(dbSetOrder(1))
		CYK->(dbGoTop())
		IF (CYK->(dbSeek(xFilial('CYK')+oGrid:GetValue('CYT_CDVF'))) .AND. CYK->CYK_TPRS == '2') .OR. lAutomacao
			  
			SFCMsgErro(STR0003,'SFCA312') //'Para inserir valores em resultado do tipo tabela, utilize o botão Rest.Tabela no MENU.'
			lRet := .F.  
			
		EndIf    
		
		RestArea(aAreaCYK)
	Endif
Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
// Função executada no pós validação do model
//-------------------------------------------------------------------
Static Function SFCA312LPOS(oModelDET)
Local lRet      := .T.
Local oModel    := oModelDET:GetModel()
Local nOpc      := oModel:GetOperation()
Local oModelCYT := oModel:GetModel( 'CYTMASTER' )
Local aArea     := GetArea()
Local aAreaCYE  := CYE->( GetArea() )
Local aAreaCYK  := CYK->( GetArea() )

Default lAutomacao := .F.

if ( nOpc == 3 .OR. nOpc == 4 ) .AND. !IsInCallStack( 'SFCA312DET' )
	
	dbSelectArea("CYE")
	CYE->(dbSetOrder(1))
	CYE->(dbGoTop())
	
	// Verificar se item controle tem relação com a maquina informada
	if CYE->(!dbSeek(xFilial('CYE')+oModelCYT:GetValue('CYT_CDMQ')+oModelDET:GetValue('CYT_CDVF')))
		SFCMsgErro(STR0004,'SFCA312') //"Item Controle informado não possui relação com a Máquina selecionada"
		lRet := .F.
	Endif
	
	if lRet	.OR. lAutomacao
		lRet := SFCA312VAL(oModelDET,oModelCYT)
	Endif
	
	RestArea( aAreaCYE )
Endif

RestArea( aAreaCYK )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
// Função executada no pós validação do model
//-------------------------------------------------------------------
Static Function SFCA312POS (oModel)
Local lRet      := .T.
Local oModelCYT := oModel:GetModel( 'CYTMASTER' )
Local oModelDET := oModel:GetModel( 'CYTDETAIL' )
Local nOpc      := oModel:GetOperation()
Local nI		:= 0
Local aArea     := GetArea()
Local aAreaCYB  := CYB->(GetArea())

if nOpc == 3 .OR. nOpc == 4

	CYB->(dbSetOrder(1))
	CYB->(dbGoTop())
	CYB->(dbSeek(xFilial('CYB')+oModelCYT:GetValue('CYT_CDMQ')))

	// Verifica se máquina está válida
	if !(CYB->CYB_DTBGVD <= oModelCYT:GetValue('CYT_DTRP') .AND.;
		 CYB->CYB_DTEDVD >= oModelCYT:GetValue('CYT_DTRP'))
		SFCMsgErro(STR0032, "SFCA312") //"Máquina inválida para o período de apontamento de produção informado."
		lRet := .F.
	Endif

	For nI := 1 To oModelDET:Length()

		oModelDET:GoLine( nI )
		
		If !oModelDET:IsDeleted()
			lRet := SFCA312VAL(oModelDET,oModelCYT)
			
			if !lRet
				Exit
			End
		Endif
	    
	Next
	
	If lRet
		If ( lRet := oModelCYT:LoadValue( 'CYT_DTSQVF', DATE() ) )
			lRet := oModelCYT:LoadValue( 'CYT_HRSQVF', TIME() )
		EndIf
		
		If GetMv("MV_SFCTPRE") == '2'
			oModelCYT:LoadValue( 'CYT_HRRP', SFCXCENTOHR(oModelCYT:GetValue('CYT_HCRP')) )
		Endif
	EndIf	
Endif

RestArea(aAreaCYB)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
// Validações das linhas de item controle
//-------------------------------------------------------------------
Static Function SFCA312VAL(oModelDET,oModelCYT)
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaCYE := CYE->( GetArea() )
Local aAreaCYK := CYK->( GetArea() )

Default lAutomacao := .F.

dbSelectArea('CYK')
CYK->(dbSetOrder(1))
if CYK->(dbSeek(xFilial('CYK')+oModelDET:GetValue('CYT_CDVF'))) .OR. lAutomacao
	
	dbSelectArea('CYE')
	CYE->(dbSetOrder(1))
	CYE->(dbSeek(xFilial('CYE')+oModelCYT:GetValue('CYT_CDMQ')+oModelDET:GetValue('CYT_CDVF')))
	
	IF CYK->CYK_TPRS == "2" // Tabela
		
		if !Empty(oModelDET:GetValue('CYT_VLRS')) .OR.;
			!Empty(oModelDET:GetValue('CYT_DTRS'))
			SFCMsgErro(STR0005,'SFCA312') //"Item Controle é do tipo Tabela e os campos Valor e Data não serão considerados"
			oModelDET:ClearField('CYT_VLRS')
			oModelDET:ClearField('CYT_DTRS')
		Endif
		
		if CYE->CYE_LGVFOB == .T.
			if Empty(oModelDET:GetValue('CYT_DSRS'))
				SFCMsgErro(STR0006 + oModelDET:GetValue('CYT_CDVF') + STR0007,'SFCA312') //"Item Controle "###" é obrigatório e seu resultado deve possuir valor"
				lRet := .F.
			Endif
			
			if oModelDET:IsDeleted()
				SFCMsgErro(STR0006 + oModelDET:GetValue('CYT_CDVF') + STR0008,'SFCA312') //"Item Controle "###" não pode ser eliminado pois é obrigatório"
				lRet := .F.
			Endif
		Endif
		
	Else
		
		Do Case
			Case CYK->CYK_TPRS == '1' // numerico
				if !Empty(oModelDET:GetValue('CYT_DSRS')) .OR.;
					!Empty(oModelDET:GetValue('CYT_DTRS'))
					SFCMsgErro(STR0009,'SFCA312') //"Item Controle é do tipo Numérico e os campos Observação e Data não serão considerados"
					oModelDET:ClearField('CYT_DSRS')
					oModelDET:ClearField('CYT_DTRS')
				Endif
				
				if CYE->CYE_LGVFOB
					IF Empty(oModelDET:GetValue('CYT_VLRS'))
						SFCMsgErro(STR0006 + oModelDET:GetValue('CYT_CDVF') + STR0010 + ALLTRIM(STR(CYE->CYE_VLVFMI)) + STR0011 + ALLTRIM(STR(CYE->CYE_VLVFMX)),'SFCA312') //"Item Controle "###" é obrigatório e seu resultado deve possuir valor entre "###" e "
						lRet := .F.
					Endif
					
					if oModelDET:IsDeleted()
						SFCMsgErro(STR0006 + oModelDET:GetValue('CYT_CDVF') + STR0008,'SFCA312') //"Item Controle "###" não pode ser eliminado pois é obrigatório"
						lRet := .F.
					Endif
				Endif
				
				if !Empty(oModelDET:GetValue('CYT_VLRS'))
					if CYE->CYE_VLVFMI > oModelDET:GetValue('CYT_VLRS') .OR.;
						CYE->CYE_VLVFMX < oModelDET:GetValue('CYT_VLRS')
						SFCMsgErro(STR0012 + ALLTRIM(STR(CYE->CYE_VLVFMI)) + STR0011 + ALLTRIM(STR(CYE->CYE_VLVFMX)),'SFCA312') //"Resultado deve possuir valor entre "###" e "
						lRet := .F.
					Endif
				Endif
				
			Case CYK->CYK_TPRS == '3' // observacao
				if !Empty(oModelDET:GetValue('CYT_VLRS')) .OR.;
					!Empty(oModelDET:GetValue('CYT_DTRS'))
					SFCMsgErro(STR0013,'SFCA312') //"Item Controle é do tipo Observação e os campos Valor e Data não serão considerados"
					oModelDET:ClearField('CYT_VLRS')
					oModelDET:ClearField('CYT_DTRS')
				Endif
				
				if CYE->CYE_LGVFOB == .T.
					IF Empty(oModelDET:GetValue('CYT_DSRS'))
						SFCMsgErro(STR0006 + oModelDET:GetValue('CYT_CDVF') + STR0007,'SFCA312') //"Item Controle "###" é obrigatório e seu resultado deve possuir valor"
						lRet := .F.
					Endif
					
					if oModelDET:IsDeleted()
						SFCMsgErro(STR0006 + oModelDET:GetValue('CYT_CDVF') + STR0008,'SFCA312') //"Item Controle "###" não pode ser eliminado pois é obrigatório"
						lRet := .F.
					Endif
				Endif
				
			Case CYK->CYK_TPRS == '4' // data
				if !Empty(oModelDET:GetValue('CYT_VLRS')) .OR.;
					!Empty(oModelDET:GetValue('CYT_DSRS'))
					SFCMsgErro(STR0014,'SFCA312') //"Item Controle é do tipo Data e os campos Valor e Observação não serão considerados"
					oModelDET:ClearField('CYT_VLRS')
					oModelDET:ClearField('CYT_DSRS')
				Endif
				
				if CYE->CYE_LGVFOB == .T.
					IF Empty(oModelDET:GetValue('CYT_DTRS'))
						SFCMsgErro(STR0006 + oModelDET:GetValue('CYT_CDVF') + STR0007,'SFCA312') //"Item Controle "###" é obrigatório e seu resultado deve possuir valor"
						lRet := .F.
					Endif
					
					if oModelDET:IsDeleted()
						SFCMsgErro(STR0006 + oModelDET:GetValue('CYT_CDVF') + STR0008,'SFCA312') //"Item Controle "###" não pode ser eliminado pois é obrigatório"
						lRet := .F.
					Endif
				Endif
				
				
				if !Empty(oModelDET:GetValue('CYT_DTRS'))
					if oModelDET:GetValue('CYT_DTRS') < DATE() - CYE->CYE_QTDYMI .OR.;
						oModelDET:GetValue('CYT_DTRS') > DATE() + CYE->CYE_QTDYMX
						SFCMsgErro(STR0015 + DTOC(DATE() - CYE->CYE_QTDYMI) + STR0011 + DTOC(DATE() + CYE->CYE_QTDYMX),'SFCA312') //"Item Controle deve possuir valor entre "###" e "
						lRet := .F.
					Endif
				Endif
		Endcase
	Endif
	
	RestArea( aAreaCYE )
Endif

RestArea( aAreaCYK )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
// Função executada no botão de Resultado tabela.
//-------------------------------------------------------------------
Function SFCA312VFTabela()
Local oOK       := LoadBitmap(GetResources(),'br_verde')
Local oNO       := LoadBitmap(GetResources(),'XCLOSE')
Local aList     := {}
Local aListAux  := {}
Local oModel    := FWModelActive()
Local oModelDET := oModel:GetModel( 'CYTDETAIL' )
Local cCDMQ     := oModel:GetModel( 'CYTMASTER' ):GetValue( 'CYT_CDMQ' )
Local cCDVF     := oModelDET:GetValue( 'CYT_CDVF' )
Local cDSRS     := AllTRim( oModelDET:GetValue( 'CYT_DSRS' ) )
Local aArea     := GetArea()
Local aAreaCYK  := CYK->( GetArea() )
Local aAreaCY1  := CY1->( GetArea() )
Local aAreaCY2  := CY2->( GetArea() )
Local oDlgPrinc
Local nOpc      := oModel:GetOperation()

Default lAutomacao := .F.

if nOpc == 3 .OR. nOpc == 4

	dbSelectArea('CYK')
	CYK->(dbSetOrder(1))
	CYK->(dbGoTop())
	if CYK->(dbSeek(xFilial('CYK')+cCDVF)) .AND. CYK->CYK_TPRS == '2' .Or. lAutomacao
		
		dbSelectArea('CY1')
		CY1->(dbSetOrder(1))
		CY1->(dbSeek(xFilial('CY1')+CYK->CYK_CDTB))
		
		Define Font oFont Name 'Courier New' Size 0, -12
		
		IF !lAutomacao
			Define MsDialog oDlgPrinc From 0,0 to 300,600 Pixel Title STR0016 //'Seleção Tabela Resultado'
		ENDIF

		dbSelectArea('CY2')
		CY2->(dbSetOrder(2))
		IF CY2->(dbSeek(xFilial('CY2')+CYK->CYK_CDTB)) .Or. lAutomacao
		
			While CY2->(!EOF()) .AND. CY2->CY2_CDTB == CYK->CYK_CDTB .Or. lAutomacao
				aListAux := {IF(ALLTRIM(CY2->CY2_DSRS) $ cDSRS,.T.,.F.), CY2->CY2_NRSQ, CY2->CY2_DSRS}
				aadd(aList, aListAux)
				CY2->(dbSkip())
				IF lAutomacao
					EXIT
				ENDIF
			End
			
		Endif
		
		IF !lAutomacao
			oSay:= tSay():New(04,05,{||STR0017 + cCDVF + ' - ' + CYK->CYK_DSVF},oDlgPrinc,,,,,,.T.,CLR_RED,CLR_WHITE,200,20) //'Item Controle: '
			oSay:= tSay():New(14,05,{||STR0018 + CYK->CYK_CDTB + ' - ' + CY1->CY1_DSTB},oDlgPrinc,,,,,,.T.,CLR_RED,CLR_WHITE,200,20) //'Tabela Resultado: '
			
			oList := VCBrowse():New( 30 , 01, 300, 100,,{'',STR0019,STR0020},{20,50,50}, oDlgPrinc, ,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) //'Sequencia'###'Observação'
			oList:SetArray(aList)
			oList:bLine := {||{If(aList[oList:nAt,01],oOK,oNO),aList[oList:nAt,02],aList[oList:nAt,03] } }
			oList:bLDblClick := {|| aList[oList:nAt][1] := !aList[oList:nAt][1],oList:DrawSelect()}
			
			TButton():New(135,110,STR0021,oDlgPrinc,{|| if( SFCA312OK(cCDMQ,cCDVF,aList),oDlgPrinc:End(),NIL)},40,10,,,,.T.) //'Ok'
			TButton():New(135,160,STR0022,oDlgPrinc,{|| if(SFCA312Cancelar(aList),oDlgPrinc:End(),NIL) },40,10,,,,.T.) //'Cancelar'
			
			RestArea(aAreaCY1)
			RestArea(aAreaCY2)
			
			Activate MsDialog oDlgPrinc Centered
		ENDIF
	Else
		SFCMsgErro(STR0023,'SFCA312') //'Selecione um registro de item controle do tipo tabela'
	Endif
	
	oModelDET:GoLine(1)
	
	RestArea(aArea)
	RestArea(aAreaCYK)
Endif

Return cDSRS

//-------------------------------------------------------------------
// Função para botão ok da selecão da tabela resultado
//-------------------------------------------------------------------
Function SFCA312OK (cCDMQ,cCDVF,aList)
Local nQuant    := 0
Local nCount    := 0
Local lRet      := .T.
Local oModel    := FWModelActive()
Local oModelDET := oModel:GetModel('CYTDETAIL') 
Local aArea     := GetArea()
Local aAreaCYE  := CYE->( GetArea() )
Local cDSRS     := ''

Default lAutomacao := .F.

dbSelectArea('CYE')
CYE->(dbSetOrder(1))
CYE->(dbGoTop())
if CYE->(dbSeek(xFilial('CYE')+cCDMQ+cCDVF)) .OR. lAutomacao

	For nCount := 1 To Len(aList)
		
		if aList[nCount][1] == .T.
			IF !Empty(cDSRS)
				cDSRS += ';'
			Endif
			
			cDSRS += ALLTRIM(aList[nCount][3])
			
			nQuant += 1
		Endif
		
	Next
	
	if CYE->CYE_NRMX < nQuant
		SFCMsgErro(STR0024 + ALLTRIM(STR(CYE->CYE_NRMX)) + STR0026,'SFCA312') //'Somente é possível selecionar ' ## ' opções'
		cDSRS := ''
		lRet  :=  .F.
	Endif
Endif

RestArea(aAreaCYE)
RestArea(aArea)

oModelDET:LoadValue('CYT_DSRS', cDSRS )

Return lRet

//-------------------------------------------------------------------
// Função para botão cancelar da selecão da tabela resultado
//-------------------------------------------------------------------
Function SFCA312Cancelar(aList)
Local nCount := 0

For nCount := 1 To Len(aList)
	
	aList[nCount][1] := .F.
	
Next

Return .T.

//-------------------------------------------------------------------
// Carregar itens controle relacionados à maquina
//-------------------------------------------------------------------
Function SFCA312DET()
Local oModel     := FwModelActive()
Local oModelCYT  :=	oModel:GetModel( 'CYTMASTER' )
Local oModelDET  :=	oModel:GetModel( 'CYTDETAIL' )
Local nOperation := oModel:GetOperation()
Local aArea      := GetArea()
Local aAreaCYE   := CYE->( GetArea() )
Local aAreaCYK   := CYK->( GetArea() )
Local nCT        := 1
Local lOk        := .F.
Local cMaquina   := ''
Local nI         := 0

Default lAutomacao := .F.

if !Empty(oModelCYT:GetValue( 'CYT_CDMQ' )) .OR. lAutomacao
	cMaquina := oModelCYT:GetValue( 'CYT_CDMQ' )
Endif

If nOperation == MODEL_OPERATION_INSERT
	
	oModelDET:DeActivate(.T.)
	oModelDET:Activate()
	
	oModelDET:SetNoDeleteLine(.F.)
	
	// Deletar todas as linhas antes
	For nI := 1 to oModelDET:GetQtdLine()
		oModelDET:GoLine(nI)
		
		if !oModelDET:IsDeleted()
		
			dbSelectArea('CYK')
			CYK->(dbSetOrder(1))
			if CYK->(dbSeek(xFilial('CYK')+oModelDET:GetValue('CYT_CDVF'))) .OR. lAutomacao
				
				dbSelectArea('CYE')
				CYE->(dbSetOrder(1))
				CYE->(dbSeek(xFilial('CYE')+oModelCYT:GetValue('CYT_CDMQ')+oModelDET:GetValue('CYT_CDVF')))
				
				IF CYK->CYK_TPRS == "1" // Numérico
					oModelDET:ClearField('CYT_VLRS')
				ElseIf CYK->CYK_TPRS == "2" .OR. CYK->CYK_TPRS == "3" // Tabela ou Observação
					oModelDET:ClearField('CYT_DSRS') 
				ElseIf CYK->CYK_TPRS == "4" // Data
					oModelDET:ClearField('CYT_DTRS')
				Endif
			Endif
		 
			oModelDET:DeleteLine()
		Endif
	Next
	
	CYE->(dbSetOrder(1))
	CYE->(dbGoTop())
	if CYE->(dbSeek(xFilial('CYE')+cMaquina)) .OR. lAutomacao
		
		oModelDET:SetNoUpdateLine(.F.)
		oModelDET:SetNoInsertLine(.F.)
		
		While !CYE->(EOF()) .AND. CYE->CYE_CDMQ == cMaquina .OR. lAutomacao
		
			if nCT > oModelDET:GetQtdLine()
				oModelDET:AddLine()
			Else
				oModelDET:GoLine(nCT)
				
				if oModelDET:IsDeleted()
					oModelDET:UnDeleteLine()
				Endif
			Endif
			
			nCT++
					
			CYK->(dbSetOrder(1))
			CYK->(dbGoTop())
			if CYK->(dbSeek(xFilial('CYK')+CYE->CYE_CDVF)) .OR. lAutomacao
				oModelDET:SetValue( 'CYT_CDVF', CYK->CYK_CDVF )	
			EndIf
			
			IF lAutomacao
				EXIT
			ENDIF
			CYE->(dbSkip())
		End
		
		oModelDET:SetNoInsertLine(.T.)
		
		oModelDET:GoLine( 1 )
		
	Else
		oModelDET:SetNoUpdateLine(.T.)
		SFCMsgErro(STR0025,'SFCA312') //'Esta Máquina não possui itens de controle relacionados'
	Endif
	
	oModelDET:SetNoDeleteLine(.T.)
	
EndIf

RestArea( aAreaCYE )
RestArea( aArea )

Return cMaquina

//-------------------------------------------------------------------
// Carregar itens controle relacionados à maquina
//-------------------------------------------------------------------
Static Function SFCA312LOAD( oGrid )
Local oModel     := oGrid:GetModel()
Local nOperation := oModel:GetOperation()
Local aLoad

If nOperation == MODEL_OPERATION_UPDATE
	oGrid:SetNoUpdateLine(.F.)
EndIf

aLoad := FormLoadGrid( oGrid, .F. )

Return aLoad
  
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local lRet     := .T.
Local lFound 
Local cXMLRet  := ""    
Local oXML
Local oCtItemContent := {}
Local oBusinessEvent
Local oBusinessContent
Local nOpc := 3
Local oModel, oModelCYT
Local nI

Default lAutomacao := .F.

IF !lAutomacao   
	If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
		//ConOut('Envio a partir do programa de carga, ignorando...')
		Return { .T., 'Envio ignorado.' }
	EndIf
ENDIF

// Se mensagem for de Recebimento
If IIF( !lAutomacao, nTypeTrans == TRANS_RECEIVE, .F.)

	  //ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCA312: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))

	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA312 Recebendo Mensagem Business' )
            
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
	  		
			
			If XmlChildEx(oBusinessContent, "_LISTOFCONTROLITEM") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfControlItem) > 0
				oCtItemContent = oBusinessContent:_ListOfControlItem:_ControlItem
				
				If ValType(oCtItemContent) == 'O'
					oCtItemContent := { oCtItemContent }
				EndIf
	        Endif
			
			// Instancia o modelo	
			oModel := FWLoadModel( 'SFCA312' )
			oModelCYT := oModel:GetModel('CYTDETAIL')
			                                 
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados	                             
			dbSelectArea('CYT')
			CYT->(dbSetOrder(1))
			
			
			lFound := CYT->(dbSeek(xFilial('CYT')+PadR(oCtItemContent[1]:_MachineCode:TEXT, Len(CYT->CYT_CDMQ)) + DTOS(SFCXStoX(oCtItemContent[1]:_PertControlDate:TEXT, 'D')) + PadR(oCtItemContent[1]:_PertControlHour:TEXT, Len(CYT->CYT_HRSQVF)) + oCtItemContent[1]:_ControlItemCode:TEXT ) )
			
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
				    lAssign := oModel:SetValue('CYTMASTER', 'CYT_CDMQ'  , oCtItemContent[1]:_MachineCode:TEXT                     );If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModel:SetValue('CYTMASTER', 'CYT_CDVF'  , oCtItemContent[1]:_ControlItemCode:TEXT                 );If !lAssign; Return SFCXMKERR(oModel); EndIf

					lAssign := oModel:SetValue('CYTMASTER', 'CYT_DTSQVF', SFCXStoX(oCtItemContent[1]:_PertControlDate:TEXT, 'D' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModel:SetValue('CYTMASTER', 'CYT_HRSQVF', oCtItemContent[1]:_PertControlHour:TEXT                 )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				   
				EndIf
				
				If XmlChildEx(oCtItemContent[1], "_REPORTDATE") != NIL
					lAssign := oModel:SetValue('CYTMASTER', 'CYT_DTRP'  , SFCXStoX(oCtItemContent[1]:_ReportDate:TEXT     , 'D' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYTMASTER', 'CYT_HRRP'  , oCtItemContent[1]:_ReportHour:TEXT				       );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				//oModel:SetValue('CYTMASTER', 'CYT_HCRP'  , oCtItemContent[1]:_Report:TEXT                          )                         
				
				For nI := 1 To oModelCYT:Length()
					oModelCYT:GoLine( nI )
					If !oModelCYT:IsDeleted()
				       	oModelCYT:DeleteLine()
					Endif
				Next                        
				
				oModelCYT:SetNoInsertLine(.F.)
     			oModelCYT:SetNoUpdateLine(.F.)
     				    	
				For nI := 1 To Len(oCtItemContent)
			   		oModelCYT:AddLine() 
				    lAssign := oModelCYT:SetValue('CYT_CDVF'  			 , oCtItemContent[nI]:_ControlItemCode:TEXT                 );If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCYT:SetValue('CYT_DSRS'            , oCtItemContent[nI]:_ResultDescription:TEXT		        );If !lAssign; Return SFCXMKERR(oModel); EndIf
				    
				    If XmlChildEx(oCtItemContent[nI], "_RESULTDATE") != NIL
				    	lAssign := oModelCYT:SetValue('CYT_DTRS'            , SFCXStoX(oCtItemContent[nI]:_ResultDate:TEXT     , 'D' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				    EndIf                   
				    
				    If XmlChildEx(oCtItemContent[nI], "_RESULTVALUE") != NIL				    
				        lAssign := oModelCYT:SetValue('CYT_VLRS'  			 , SFCXStoX(oCtItemContent[nI]:_ResultValue:TEXT    , 'N' ) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				    EndIf
            	Next        
            	                  
            	oModelCYT:SetNoInsertLine(.T.)   
            	
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
            //conout( '+ IntegDef SFCA312 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCA312 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}
      EndIf
 // Chamada é para envio, solicitada pelo MODEL      
ElseIf IIF(!lAutomacao, nTypeTrans == TRANS_SEND, .T.)
      //conout( '+ IntegDef SFCA312 Enviando Mensagem' )
      
      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()
      oModelCYT := oModel:GetModel('CYTDETAIL')

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet :=  FWEAIBusEvent( "ControlItemReport", oModel:GetOperation(),{ { "MachineCode"    , SFCXXtoS(oModel:GetValue("CYTMASTER", 'CYT_CDMQ'  )) }  , ;
     																		 { "PertControlDate", SFCXXtoS(oModel:GetValue("CYTMASTER", 'CYT_DTSQVF')) } , ;
      																		 { "PertControlHour", SFCXXtoS(oModel:GetValue("CYTMASTER", 'CYT_HRSQVF')) } , ;
      																		 { "ControlItemCode"    , SFCXXtoS(oModelCYT:GetValue('CYT_CDVF')) } } )         
       
      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'          
      cXMLRet += '<ListOfControlItem>'          
	
	  For nI := 1 To oModelCYT:Length()
	  	  oModelCYT:GoLine( nI )        
		  cXMLRet += '<ControlItem>'          
		
		  cXMLRet += '<MachineCode>' 					+ SFCXXtoS(oModel:GetValue("CYTMASTER", 'CYT_CDMQ')) 		+ '</MachineCode>'
		  cXMLRet += '<PertControlDate>'  				+ SFCXXtoS(oModel:GetValue("CYTMASTER", 'CYT_DTSQVF')) 		+ '</PertControlDate>'   
		  cXMLRet += '<PertControlHour>'  				+ SFCXXtoS(oModel:GetValue("CYTMASTER", 'CYT_HRSQVF')) 		+ '</PertControlHour>'   
		  cXMLRet += '<ControlItemCode>'      				+ SFCXXtoS(oModelCYT:GetValue('CYT_CDVF'))			 		+ '</ControlItemCode>'
		
		  // Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		  If oModel:GetOperation() # 5
		 		
		      cXMLRet += '<MachineDescription>'				+ SFCXXtoS(oModel:GetValue("CYTMASTER", 'CYT_DSMQ')) 		+ '</MachineDescription>'
			  cXMLRet += '<ReportDate>'  			   		+ SFCXXtoS(oModel:GetValue("CYTMASTER", 'CYT_DTRP')) 		+ '</ReportDate>'   
			  cXMLRet += '<ReportHour>'  					+ SFCXXtoS(oModel:GetValue("CYTMASTER", 'CYT_HRRP')) 		+ '</ReportHour>'    
			  cXMLRet += '<Report>'  						+ SFCXXtoS(oModel:GetValue("CYTMASTER", 'CYT_HCRP')) 		+ '</Report>'      
			  cXMLRet += '<ControlItemDescription>'  		+ SFCXXtoS(oModelCYT:GetValue('CYT_DSVF')) 					+ '</ControlItemDescription>' 
			  cXMLRet += '<ResultDescription>'  			+ SFCXXtoS(oModelCYT:GetValue('CYT_DSRS')) 	   				+ '</ResultDescription>'   
			  cXMLRet += '<ResultDate>'  					+ SFCXXtoS(oModelCYT:GetValue('CYT_DTRS')) 					+ '</ResultDate>'   
			  cXMLRet += '<ResultValue>'  					+ SFCXXtoS(oModelCYT:GetValue('CYT_VLRS')) 					+ '</ResultValue>'   
				
	      EndIf    
	      cXMLRet += '</ControlItem>'                	
	  Next         
      cXMLRet += '</ListOfControlItem>'	    		
      cXMLRet += '</BusinessContent>'
      
EndIf
                        
//ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)


Return { lRet, cXMLRet }

Function INTDF_A312( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)
