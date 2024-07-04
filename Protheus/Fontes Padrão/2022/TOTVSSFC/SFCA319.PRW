#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'SFCA319.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA319
Iniciar apontamento de produção

@author Samantha Preima
@since 20/05/2014
@version P11
/*/
//-------------------------------------------------------------------
Function SFCA319()

Return NIL

//-------------------------------------------------------------------
// Menu para tela de Apontamento de Produção
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Return aRotina 
  
//-------------------------------------------------------------------
// Model para Apontamento de Produção
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCYV := FWFormStruct( 1, 'CYV', /*bAvalCampo*/,/*lViewUsado*/ ) // Apontamento
Local oModel   

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'SFCA319', /*Pre*/, { | oMdl | SFCA319POS ( oMdl ) }, /*Commit*/ , /*{ | oMdl | SFCA310P ( .F. ) }*/ ) 

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYVMASTER', /*cOwner*/, oStruCYV )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 ) // 'Iniciar Apontamento'

oModel:SetActivate( { |oModel| SFCA319PRE( oModel ) } )  
oModel:SetVldActivate( { |oModel| SFCA319VPR( oModel ) } )  

Return oModel

//-------------------------------------------------------------------
// View para Apontamento de Produção   
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCYV
Local oModel
Local oView
Local cCampos

cCampos := "CYV_NRORPO/CYV_IDAT/CYV_CDAT/CYV_DSAT/CYV_IDATQO/CYV_DTRPBG/CYV_HRRPBG/CYV_NRBG/CYV_CDMQ/CYV_DSMQ/"
cCampos += "CYV_CDACRP/CYV_DSAC/CYV_DTEO/CYV_LGRPEO/CYV_CDUSRP/CYV_NMUSRP/CYV_CDUSOE/CYV_NMUSOE/CYV_DTRP/CYV_HRRP/CYV_NRSQRP/"

oStruCYV := FWFormStruct( 2, 'CYV', { |cField| AllTrim( cField ) + '/' $ cCampos } )
oModel   := FWLoadModel( 'SFCA319' )

// Criação de divisores
oStruCYV:AddGroup( 'Grupo01', STR0002, '', 2 ) //'Apontamento de Produção'
oStruCYV:AddGroup( 'Grupo02', STR0003, '', 2 ) //'Detalhes'

oStruCYV:SetProperty( 'CYV_CDMQ'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_DSMQ'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_NRORPO', MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_IDAT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_IDATQO', MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_CDAT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_DSAT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_CDACRP', MVC_VIEW_GROUP_NUMBER, 'Grupo01' ) 
oStruCYV:SetProperty( 'CYV_DSAC'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )

oStruCYV:SetProperty( 'CYV_DTRPBG', MVC_VIEW_GROUP_NUMBER, 'Grupo02' )
oStruCYV:SetProperty( 'CYV_HRRPBG', MVC_VIEW_GROUP_NUMBER, 'Grupo02' )
oStruCYV:SetProperty( 'CYV_NRBG'  , MVC_VIEW_GROUP_NUMBER, 'Grupo02' ) 

oStruCYV:SetProperty( "CYV_CDACRP", MVC_VIEW_CANCHANGE ,.F.)

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel ) 

// Para nao reabrir a tela, após salvar registro
oView:SetCloseOnOk({||.T.})    

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYV', oStruCYV, 'CYVMASTER' )

oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_NRORPO', MVC_VIEW_ORDEM, '01' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_CDAT'  , MVC_VIEW_ORDEM, '02' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_DSAT'  , MVC_VIEW_ORDEM, '03' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_IDATQO', MVC_VIEW_ORDEM, '04' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_IDAT'  , MVC_VIEW_ORDEM, '05' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_CDACRP', MVC_VIEW_ORDEM, '06' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_DSAC'  , MVC_VIEW_ORDEM, '07' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_CDMQ'  , MVC_VIEW_ORDEM, '08' )
oView:GetViewStruct('VIEW_CYV'):SetProperty('CYV_DSMQ'  , MVC_VIEW_ORDEM, '09' )

Return oView

//-------------------------------------------------------------------
// Pre validação de inicialização de apontamento de produção
// Este é a função que está no menu
//-------------------------------------------------------------------
Function SFCA319INI(xRotAuto)
Local lRet := .T.
Local cNRORPO
Local cIDAT
Local cIDATQO

if xRotAuto == Nil
	lRet := FWExecView('','SFCA319', 3,,{ || .T. },,,,,,,  )
	
	SFCA310F12()
Else
	IF Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_NRORPO'}) == 0 .OR.;
	   Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_IDAT'}) == 0 .OR.;
	   Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_IDATQO'}) == 0
	   
		AutoGRLog(STR0005) // 'É preciso informar a ordem de produção, operação e split para incluir um apontamento de produção. Campos CYV_NRORPO, CYV_IDAT, CYV_IDATQO'
		lMsErroAuto := .T.
	   
		lRet := .F.
	Else
		cNRORPO := PadR(xRotAuto[Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_NRORPO'})][2],TamSX3('CYV_NRORPO')[1])
		cIDAT   := PadR(xRotAuto[Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_IDAT'})][2],TamSX3('CYV_IDAT')[1])
		cIDATQO := PadR(xRotAuto[Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'CYV_IDATQO'})][2],TamSX3('CYV_IDATQO')[1])

		dbSelectArea('CYY')
		CYY->(dbSetOrder(1))
		IF CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))

			aRotina := MenuDef()	
			FWMVCRotAuto(ModelDef(),"CYV",3,{{"CYVMASTER",xRotAuto}})
		Endif
	Endif	
Endif

Return lRet 

//-------------------------------------------------------------------
// Pre validação de inicialização de apontamento de produção
//-------------------------------------------------------------------
Static Function SFCA319VPR(oModel)
Local lRet := .T.
Local lValid := .F.

If ( Type( 'cPROG' ) == 'C' ) .And. ( cPROG == 'APIREST' ) .And. oModel:GetOperation() == 3 //API
	lValid := .T.
EndIf

If ( Type( 'lExAutSFC' ) == 'L' ) .And. lExAutSFC  .And. oModel:GetOperation() == 3 //EXECAUT PADRÃO
	lValid := .T.
EndIf

if (IsInCallStack('SFCA310') .AND. oModel:GetOperation() == 3) .Or.  lValid  
	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbSeek(xFilial('CYB')+if(Empty(CYY->CYY_CDMQ),_MaqSFC310,CYY->CYY_CDMQ)))
	
	if CYB->CYB_LGSU .AND. Empty(CYY->CYY_DTBGSU)
		SFCMsgErro('SFCA319_INMQPR','SFCA319', 3) // Máquina não pode iniciar apontamento pois exige preparação
		lRet := .F.
	Endif
	
	If lRet
		if !CYB->CYB_LGBGQO
			SFCMsgErro('SFCA319_INIMAQ','SFCA319',3) // Máquina não pode iniciar apontamento
			lRet := .F.
		Endif
	EndIf
	
	If lRet
		lRet := SFCApAbeSp(CYY->CYY_NRORPO, CYY->CYY_IDAT, CYY->CYY_IDATQO)
	EndIf
Endif

If lValid .And. lRet
	// Verificar se existe apontamento de preparação iniciado
	If SFCSetupIn(If(Empty(CYY->CYY_CDMQ),_MaqSFC310,CYY->CYY_CDMQ))
		SFCMsgErro('SFCA319_PREINI','SFCA319', 3) // Existe apontamento de preparação iniciado para esta máquina, portanto apontamento de produção não pode ser iniciado
		lRet := .F.
	Endif

	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbSeek(xFilial('CYB')+If(Empty(CYY->CYY_CDMQ),_MaqSFC310,CYY->CYY_CDMQ)))

	dbSelectArea('CYY')
	CYY->(dbSetOrder(1))
	CYY->(dbSeek(xFilial('CYY')+CYY->CYY_NRORPO+CYY->CYY_IDAT+CYY->CYY_IDATQO))
	
	If lRet
		// Verifica se existe apontamento de produção em aberto para split
		lRet := SFCApAbeSp(CYY->CYY_NRORPO, CYY->CYY_IDAT,  CYY->CYY_IDATQO)
	EndIf
	
	If lRet
		// Verifica se existe apontamento de produção em aberto para maquina	
		lRet := SFCApAbeMq(If(Empty(CYY->CYY_CDMQ),_MaqSFC310,CYY->CYY_CDMQ))
	EndIf
	
	If lRet
		if !CYB->CYB_LGBGQO
			SFCMsgErro('SFCA319_INIMAQ','SFCA319',3) // Máquina não pode iniciar apontamento
			lRet := .F.
		Endif
	EndIf
	
	If lRet
		if CYB->CYB_LGSU .AND. Empty(CYY->CYY_DTBGSU)
			SFCMsgErro('SFCA319_NAOPRE','SFCA319', 3) // Não realizada preparação para este Split, portanto máquina que utiliza preparação não pode iniciar este apontamento de produção
			lRet := .F.
		EndIf
	Endif
EndIf

Return lRet

//-------------------------------------------------------------------
// Pre validação de inicialização de apontamento de produção
//-------------------------------------------------------------------
Static Function SFCA319PRE(oModel)
Local oModelCYV := oModel:GetModel( 'CYVMASTER' )
Local lRet      := .T.

// Apontamento modelo I precisa ter os campos iniciados pois está posicionado no split
IF oModel:GetOperation() == 3 .AND. IsInCallStack('SFCA310')
	oModelCYV:SetValue('CYV_NRORPO', CYY->CYY_NRORPO)
	oModelCYV:SetValue('CYV_IDAT'  , CYY->CYY_IDAT)
	oModelCYV:SetValue('CYV_IDATQO', CYY->CYY_IDATQO)
	oModelCYV:SetValue('CYV_CDMQ'  , if(Empty(CYY->CYY_CDMQ),_MaqSFC310,CYY->CYY_CDMQ))
Endif

Return lRet

//-------------------------------------------------------------------
// Pos validação de inicialização de apontamento de produção
//-------------------------------------------------------------------
Static Function SFCA319POS(oModel)
Local oModelCYV := oModel:GetModel('CYVMASTER')
Local lRet      := .T.
Local cNRORPO   := oModelCYV:GetValue('CYV_NRORPO')
Local cIDAT     := oModelCYV:GetValue('CYV_IDAT')
Local cIDATQO   := oModelCYV:GetValue('CYV_IDATQO')
Local cMaquina  := oModelCYV:GetValue('CYV_CDMQ')
Local nNRBG     := oModelCYV:GetValue('CYV_NRBG')
Local nOpc      := oModel:GetOperation()

// Verifica se já foi iniciado um apontamento para a mesma operação
if nOpc == 3
	// Verificar se existe apontamento de preparação iniciado
	If SFCSetupIn(cMaquina)
		SFCMsgErro('SFCA319_PREINI','SFCA319', 3) // Existe apontamento de preparação iniciado para esta máquina, portanto apontamento de produção não pode ser iniciado
		lRet := .F.
	Endif

	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbSeek(xFilial('CYB')+cMaquina))
	
	// Verifica se existe apontamento de produção em aberto para split
	lRet := SFCApAbeSp(cNRORPO, cIDAT, cIDATQO)
	
	// Verifica se existe apontamento de produção em aberto para maquina
	lRet := SFCApAbeMq(cMaquina, oModelCYV:GetValue('CYV_NRSQRP'))
	
	if !CYB->CYB_LGBGQO
		SFCMsgErro('SFCA319_INIMAQ','SFCA319',3) // Máquina não pode iniciar apontamento
		lRet := .F.
	Endif
	
	if CYB->CYB_LGSU .AND. Empty(CYY->CYY_DTBGSU)
		SFCMsgErro('SFCA319_NAOPRE','SFCA319', 3) // Não realizada preparação para este Split, portanto máquina que utiliza preparação não pode iniciar este apontamento de produção
		lRet := .F.
	Endif
	
	dbSelectArea('CYY')
	CYY->(dbSetOrder(1))
	CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))
	
	IF !Empty(CYY->CYY_CDMQ) .AND. CYY->CYY_CDMQ != cMaquina
		SFCMsgErro('SFCA319_ALOC','SFCA319') // Split já está alocado para outra máquina
		lRet := .F.
	Endif
	
	Pergunte('SFCA310A',.F.)
		
	IF nNRBG > 0
		if !CYB->CYB_LGMED
			SFCMsgErro('SFCA319_MAQMED','SFCA319',3) // Máquina não realiza apontamento por medição
			lRet := .F.
		Elseif MV_PAR01 == 1 /*Não*/
			SFCMsgErro('SFCA319_NAOMED','SFCA319',3) // A função de apontamento por medição não está ligada
			lRet := .F.
		Endif
	Endif
	
	if lRet
		oModelCYV:SetValue('CYV_TPSTRP', '1')
		oModelCYV:SetValue('CYV_DTRP'  , Date())
		oModelCYV:SetValue('CYV_HRRP'  , Time())
		oModelCYV:SetValue('CYV_CDUSRP', RetCodUsr())
	
		if Empty(CYY->CYY_CDMQ)
			SFCA315A(CYY->CYY_NRORPO, CYY->CYY_IDAT, CYY->CYY_IDATQO, .F., cMaquina)
		Endif
	Endif
ElseIf nOpc == 5
	lRet := .F.
Endif

Return lRet
