#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'CRMA800.ch'

//-----------------------------------------------------------------------
/*/{Protheus.doc} CRMA802()
  	 
Traking da Proposta 

@author Ronaldo Robes 
@since  10/05/2015

@version P12
/*/
//-----------------------------------------------------------------------


Function CRMA800A()

FWExecView(Upper('Visualizar'),"CRMA800A",MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOK*/,/*bOk*/,/*nPercReducao*/,/*aButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,/*oModelAct*/) //"Alterar"

Return Nil


//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
  	 
Traking da Proposta 

@author Ronaldo Robes 
@since  10/05/2015

@version P12
/*/
//-----------------------------------------------------------------------


Static Function ModelDef()

	Local oModel	:= Nil
	Local oStrADY	:= Nil

  

	oStrADY 	:= FWFormStruct( 1, 'ADY')


	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('CRMA800A')//,,,bCommit)

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields('ADYMASTER',,oStrADY)
	

	// Adiciona ao modelo uma estrutura de formulário de edição por grid

	
	oModel:SetPrimarykey({'ADY_PROPOS'})
	
	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription('TRAKING')


Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
  	 
Traking da Proposta 

@author Ronaldo Robes 
@since  10/05/2015

@version P12
/*/
//-----------------------------------------------------------------------

Static Function ViewDef()

	Local oView
	Local oModel 	:= FWLoadModel("CRMA800A")
	Local oStrADY	:= Nil
    Local bFilADY   := {|cCampo| Alltrim(cCampo) $ "ADY_PROPOS|ADY_OPORTU|ADY_DESOPO"+;
    "|ADY_ENTIDA|ADY_DATA|ADY_HREMIS|ADY_USREMI|ADY_DTUPL|ADY_HRUPLO|ADY_USRUPL|ADY_DTAPRP|ADY_HRAPRP|ADY_USAPRP"+; 
    "|ADY_DTPDV|ADY_HRPDV|ADY_USRPDV|ADY_DTFAT|ADY_HRFAT|ADY_USRFAT|ADY_DTAPRO|ADY_HRAPRO|ADY_USAPRO|ADY_OBSAPR|ADY_DTREPR|ADY_HRREPR"+;
     "|ADY_USREPR|ADY_MTREPR|ADY_OBSREP|"}
 

	oStrADY 	:= FWFormStruct( 2, 'ADY',bFilADY )
 
	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)   
     

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ADY'  , oStrADY, 'ADYMASTER')

  oStrADY:addGroup( 'GRUPO01', STR0020, '', 2 )
  
    oStrADY:SetProperty( 'ADY_PROPOS', MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
    oStrADY:SetProperty( 'ADY_OPORTU', MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
    oStrADY:SetProperty( 'ADY_DESOPO', MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
    oStrADY:SetProperty( 'ADY_ENTIDA', MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
   
   oStrADY:addGroup( 'GRUPO02', STR0021 , '', 2 )
  
    oStrADY:SetProperty( 'ADY_DATA', MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    oStrADY:SetProperty( 'ADY_HREMIS', MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    oStrADY:SetProperty( 'ADY_USREMI', MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    oStrADY:SetProperty( 'ADY_DTUPL', MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    oStrADY:SetProperty( 'ADY_HRUPLO', MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    oStrADY:SetProperty( 'ADY_USRUPL', MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    
   oStrADY:addGroup( 'GRUPO03', STR0022 , '', 2 )
  
    oStrADY:SetProperty( 'ADY_DTAPRO', MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
    oStrADY:SetProperty( 'ADY_HRAPRO', MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
    oStrADY:SetProperty( 'ADY_USAPRP', MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
 
   oStrADY:addGroup( 'GRUPO04', STR0023 , '', 2 )
  
    oStrADY:SetProperty( 'ADY_DTPDV', MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
    oStrADY:SetProperty( 'ADY_HRPDV', MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
    oStrADY:SetProperty( 'ADY_USRPDV', MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
  
  oStrADY:addGroup( 'GRUPO05', STR0024 , '', 2 )
  
    oStrADY:SetProperty( 'ADY_DTFAT', MVC_VIEW_GROUP_NUMBER, 'GRUPO05' )
    oStrADY:SetProperty( 'ADY_HRFAT', MVC_VIEW_GROUP_NUMBER, 'GRUPO05' )
    oStrADY:SetProperty( 'ADY_USRFAT', MVC_VIEW_GROUP_NUMBER, 'GRUPO05' )
   
  
   oStrADY:addGroup( 'GRUPO06', STR0025 , '', 2 )
  
    oStrADY:SetProperty( 'ADY_DTAPRP', MVC_VIEW_GROUP_NUMBER, 'GRUPO06' )
    oStrADY:SetProperty( 'ADY_HRAPRP', MVC_VIEW_GROUP_NUMBER, 'GRUPO06' )
    oStrADY:SetProperty( 'ADY_USAPRP', MVC_VIEW_GROUP_NUMBER, 'GRUPO06' )
    oStrADY:SetProperty( 'ADY_OBSAPR', MVC_VIEW_GROUP_NUMBER, 'GRUPO06' )
  
  oStrADY:addGroup( 'GRUPO07', STR0026 , '', 2 )
  
    oStrADY:SetProperty( 'ADY_DTREPR', MVC_VIEW_GROUP_NUMBER, 'GRUPO07' )
    oStrADY:SetProperty( 'ADY_HRREPR', MVC_VIEW_GROUP_NUMBER, 'GRUPO07' )
    oStrADY:SetProperty( 'ADY_USREPR', MVC_VIEW_GROUP_NUMBER, 'GRUPO07' )
    oStrADY:SetProperty( 'ADY_MTREPR', MVC_VIEW_GROUP_NUMBER, 'GRUPO07' )
    oStrADY:SetProperty( 'ADY_OBSREP', MVC_VIEW_GROUP_NUMBER, 'GRUPO07' ) 
     
	oView:CreateHorizontalBox('CORPO',100)

  // Relaciona o D da View com o "box" para exibicao 
	oView:SetOwnerView( 'VIEW_ADY'  , 'CORPO'  	)
	
	
Return oView


