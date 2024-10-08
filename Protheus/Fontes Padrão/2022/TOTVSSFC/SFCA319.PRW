#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'SFCA319.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA319
Iniciar apontamento de produ��o

@author Samantha Preima
@since 20/05/2014
@version P11
/*/
//-------------------------------------------------------------------
Function SFCA319()

Return NIL

//-------------------------------------------------------------------
// Menu para tela de Apontamento de Produ��o
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Return aRotina 
  
//-------------------------------------------------------------------
// Model para Apontamento de Produ��o
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCYV := FWFormStruct( 1, 'CYV', /*bAvalCampo*/,/*lViewUsado*/ ) // Apontamento
Local oModel   

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'SFCA319', /*Pre*/, { | oMdl | SFCA319POS ( oMdl ) }, /*Commit*/ , /*{ | oMdl | SFCA310P ( .F. ) }*/ ) 

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'CYVMASTER', /*cOwner*/, oStruCYV )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 ) // 'Iniciar Apontamento'

oModel:SetActivate( { |oModel| SFCA319PRE( oModel ) } )  
oModel:SetVldActivate( { |oModel| SFCA319VPR( oModel ) } )  

Return oModel

//-------------------------------------------------------------------
// View para Apontamento de Produ��o   
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

// Cria��o de divisores
oStruCYV:AddGroup( 'Grupo01', STR0002, '', 2 ) //'Apontamento de Produ��o'
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

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel ) 

// Para nao reabrir a tela, ap�s salvar registro
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
// Pre valida��o de inicializa��o de apontamento de produ��o
// Este � a fun��o que est� no menu
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
	   
		AutoGRLog(STR0005) // '� preciso informar a ordem de produ��o, opera��o e split para incluir um apontamento de produ��o. Campos CYV_NRORPO, CYV_IDAT, CYV_IDATQO'
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
// Pre valida��o de inicializa��o de apontamento de produ��o
//-------------------------------------------------------------------
Static Function SFCA319VPR(oModel)
Local lRet := .T.
Local lValid := .F.

If ( Type( 'cPROG' ) == 'C' ) .And. ( cPROG == 'APIREST' ) .And. oModel:GetOperation() == 3 //API
	lValid := .T.
EndIf

If ( Type( 'lExAutSFC' ) == 'L' ) .And. lExAutSFC  .And. oModel:GetOperation() == 3 //EXECAUT PADR�O
	lValid := .T.
EndIf

if (IsInCallStack('SFCA310') .AND. oModel:GetOperation() == 3) .Or.  lValid  
	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbSeek(xFilial('CYB')+if(Empty(CYY->CYY_CDMQ),_MaqSFC310,CYY->CYY_CDMQ)))
	
	if CYB->CYB_LGSU .AND. Empty(CYY->CYY_DTBGSU)
		SFCMsgErro('SFCA319_INMQPR','SFCA319', 3) // M�quina n�o pode iniciar apontamento pois exige prepara��o
		lRet := .F.
	Endif
	
	If lRet
		if !CYB->CYB_LGBGQO
			SFCMsgErro('SFCA319_INIMAQ','SFCA319',3) // M�quina n�o pode iniciar apontamento
			lRet := .F.
		Endif
	EndIf
	
	If lRet
		lRet := SFCApAbeSp(CYY->CYY_NRORPO, CYY->CYY_IDAT, CYY->CYY_IDATQO)
	EndIf
Endif

If lValid .And. lRet
	// Verificar se existe apontamento de prepara��o iniciado
	If SFCSetupIn(If(Empty(CYY->CYY_CDMQ),_MaqSFC310,CYY->CYY_CDMQ))
		SFCMsgErro('SFCA319_PREINI','SFCA319', 3) // Existe apontamento de prepara��o iniciado para esta m�quina, portanto apontamento de produ��o n�o pode ser iniciado
		lRet := .F.
	Endif

	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbSeek(xFilial('CYB')+If(Empty(CYY->CYY_CDMQ),_MaqSFC310,CYY->CYY_CDMQ)))

	dbSelectArea('CYY')
	CYY->(dbSetOrder(1))
	CYY->(dbSeek(xFilial('CYY')+CYY->CYY_NRORPO+CYY->CYY_IDAT+CYY->CYY_IDATQO))
	
	If lRet
		// Verifica se existe apontamento de produ��o em aberto para split
		lRet := SFCApAbeSp(CYY->CYY_NRORPO, CYY->CYY_IDAT,  CYY->CYY_IDATQO)
	EndIf
	
	If lRet
		// Verifica se existe apontamento de produ��o em aberto para maquina	
		lRet := SFCApAbeMq(If(Empty(CYY->CYY_CDMQ),_MaqSFC310,CYY->CYY_CDMQ))
	EndIf
	
	If lRet
		if !CYB->CYB_LGBGQO
			SFCMsgErro('SFCA319_INIMAQ','SFCA319',3) // M�quina n�o pode iniciar apontamento
			lRet := .F.
		Endif
	EndIf
	
	If lRet
		if CYB->CYB_LGSU .AND. Empty(CYY->CYY_DTBGSU)
			SFCMsgErro('SFCA319_NAOPRE','SFCA319', 3) // N�o realizada prepara��o para este Split, portanto m�quina que utiliza prepara��o n�o pode iniciar este apontamento de produ��o
			lRet := .F.
		EndIf
	Endif
EndIf

Return lRet

//-------------------------------------------------------------------
// Pre valida��o de inicializa��o de apontamento de produ��o
//-------------------------------------------------------------------
Static Function SFCA319PRE(oModel)
Local oModelCYV := oModel:GetModel( 'CYVMASTER' )
Local lRet      := .T.

// Apontamento modelo I precisa ter os campos iniciados pois est� posicionado no split
IF oModel:GetOperation() == 3 .AND. IsInCallStack('SFCA310')
	oModelCYV:SetValue('CYV_NRORPO', CYY->CYY_NRORPO)
	oModelCYV:SetValue('CYV_IDAT'  , CYY->CYY_IDAT)
	oModelCYV:SetValue('CYV_IDATQO', CYY->CYY_IDATQO)
	oModelCYV:SetValue('CYV_CDMQ'  , if(Empty(CYY->CYY_CDMQ),_MaqSFC310,CYY->CYY_CDMQ))
Endif

Return lRet

//-------------------------------------------------------------------
// Pos valida��o de inicializa��o de apontamento de produ��o
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

// Verifica se j� foi iniciado um apontamento para a mesma opera��o
if nOpc == 3
	// Verificar se existe apontamento de prepara��o iniciado
	If SFCSetupIn(cMaquina)
		SFCMsgErro('SFCA319_PREINI','SFCA319', 3) // Existe apontamento de prepara��o iniciado para esta m�quina, portanto apontamento de produ��o n�o pode ser iniciado
		lRet := .F.
	Endif

	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbSeek(xFilial('CYB')+cMaquina))
	
	// Verifica se existe apontamento de produ��o em aberto para split
	lRet := SFCApAbeSp(cNRORPO, cIDAT, cIDATQO)
	
	// Verifica se existe apontamento de produ��o em aberto para maquina
	lRet := SFCApAbeMq(cMaquina, oModelCYV:GetValue('CYV_NRSQRP'))
	
	if !CYB->CYB_LGBGQO
		SFCMsgErro('SFCA319_INIMAQ','SFCA319',3) // M�quina n�o pode iniciar apontamento
		lRet := .F.
	Endif
	
	if CYB->CYB_LGSU .AND. Empty(CYY->CYY_DTBGSU)
		SFCMsgErro('SFCA319_NAOPRE','SFCA319', 3) // N�o realizada prepara��o para este Split, portanto m�quina que utiliza prepara��o n�o pode iniciar este apontamento de produ��o
		lRet := .F.
	Endif
	
	dbSelectArea('CYY')
	CYY->(dbSetOrder(1))
	CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))
	
	IF !Empty(CYY->CYY_CDMQ) .AND. CYY->CYY_CDMQ != cMaquina
		SFCMsgErro('SFCA319_ALOC','SFCA319') // Split j� est� alocado para outra m�quina
		lRet := .F.
	Endif
	
	Pergunte('SFCA310A',.F.)
		
	IF nNRBG > 0
		if !CYB->CYB_LGMED
			SFCMsgErro('SFCA319_MAQMED','SFCA319',3) // M�quina n�o realiza apontamento por medi��o
			lRet := .F.
		Elseif MV_PAR01 == 1 /*N�o*/
			SFCMsgErro('SFCA319_NAOMED','SFCA319',3) // A fun��o de apontamento por medi��o n�o est� ligada
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
