#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA950.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA950
Rotina para Log do Rodízio. 

@author     Valdiney V GOMES
@version    12
@since      09/06/2015
/*/
//------------------------------------------------------------------------------
Function CRMA950( aAuto, nOpcAuto )
	Local oBrowse 		:= Nil
	Local oModel 		:= Nil 
	Local lOk			:= .T.
	
	Private lMsErroAuto	:= .F.	

	Default aAuto		:= {}
	Default nOpcAuto 	:= MODEL_OPERATION_INSERT

	If ! ( Empty( aAuto ) )
		//-------------------------------------------------------------------
		// Recupera o modelo de dados. 
		//-------------------------------------------------------------------		
		oModel 	:= ModelDef()
		aRotina := MenuDef() 
		
		//-------------------------------------------------------------------
		// Execução por rotina automática. 
		//-------------------------------------------------------------------
		FWMVCRotAuto( oModel, "AZ4", nOpcAuto, {{ "AZ4MASTER", aAuto }} )
		
		//-------------------------------------------------------------------
		// Verifica se ocorreu erro na rotina automática. 
		//-------------------------------------------------------------------		
		If ( lMsErroAuto )
			lOk := .F.
			MostraErro()
		EndIf
	Else
		//-------------------------------------------------------------------
		// Execução por interface com usuário. 
		//-------------------------------------------------------------------
		oBrowse := FWMBrowse():New()

		oBrowse:SetAlias("AZ4")
		oBrowse:SetDescription( STR0001 ) //"Log do Rodízio"
		oBrowse:DisableDetails()
		oBrowse:Activate()		
	EndIf 
Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define as opções disponíveis no menu do Log do Rodízio.

@return aRotina Rotinas que serão exibidas no menu. 

@author     Valdiney V GOMES
@version    12
@since      09/06/2015
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.CRMA950" OPERATION 2 ACCESS 0 //"Visualizar"
Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o modelo de dados do Log do Rodízio.

@return oModel Modelo de dados do Log do Rodízio.

@author     Valdiney V GOMES
@version    12
@since      09/06/2015
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel		:= Nil	
	Local oAZ4Struct	:= FWFormStruct( 1, "AZ4" )

    //-------------------------------------------------------------------
	// Define a estrutura do modelo de dados. 
	//-------------------------------------------------------------------
	oModel	:= MPFormModel():New("CRMA950")
	oModel:AddFields("AZ4MASTER",, oAZ4Struct )
	oModel:SetPrimaryeKey( { "AZ4_FILIAL", "AZ4_CODLOG" } )

	//-------------------------------------------------------------------
	// Define a descrição do modelo de dados. 
	//-------------------------------------------------------------------	
	oModel:SetDescription( STR0001 )
	oModel:GetModel("AZ4MASTER"):SetDescription( STR0004 ) //"Log"
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Camada de visualização do Log do Rodízio.

@return oView Camada de visualização do Log do Rodízio. 

@author     Valdiney V GOMES
@version    12
@since      09/06/2015
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView			:= Nil
	Local oModel 		:= Nil
	Local oAZ4Struct	:= FWFormStruct( 2, "AZ4")

	//-------------------------------------------------------------------
	// Remove o campo AZ4_LGPROC da camada de visualização. 
	//-------------------------------------------------------------------
	oAZ4Struct:RemoveField("AZ4_LGPROC")

	//-------------------------------------------------------------------
	// Define o modelo utilizado pela camada de visualização. 
	//-------------------------------------------------------------------	
	oModel 	:= FWLoadModel( "CRMA950" )	
	oView	:= FWFormView():New()
	oView:SetModel( oModel )  

	//-------------------------------------------------------------------
	// Define a estrutura da dcamada de visualização. 
	//-------------------------------------------------------------------
	oView:AddField( "VIEW_AZ4", oAZ4Struct	, "AZ4MASTER" )
	oView:CreateHorizontalBox( "ALL", 100 )
	oView:SetOwnerView( "VIEW_AZ4",	"ALL" )
	oView:EnableTitleView( "VIEW_AZ4" )
	
	//-------------------------------------------------------------------
	// Insere botão para visualização do log. 
	//-------------------------------------------------------------------	
	oView:AddUserButton( STR0004, "", { || CRMA950Viewer( oModel:GetModel("AZ4MASTER"):GetValue("AZ4_LGPROC") ) } ) //"Log"
Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA940Init
Inicializado padrão para os campos AZ4_DSCMEM. 

@param cField, caracter, Nome do campo. 
@param lBrowse, lógico, Define que a inicializacao será no browse
@return cReturn, caracter,Descrição do campo. 
		 
@author     Valdiney V GOMES
@version    12
@since      10/06/2015
/*/
//------------------------------------------------------------------------------
Function CRMA950Init( cField, lBrowse )
	Local cReturn 	:= ""
	
	Default cField	:= ""
	Default lBrowse 	:= .F.
	
	If ( lBrowse .Or. ! ( INCLUI ) )
		If ( cField == "AZ4_DSCMEM" )	
			//-------------------------------------------------------------------
			// Recupera a descrição do membro. 
			cReturn := Posicione( "AZ7", 1,	xFilial("AZ7") + AZ7->AZ7_CODROD + AZ7->AZ7_CODFLA + AZ7->AZ7_TPMEM + AZ7->AZ7_CODMEM, "AZ7_DSCMEM" )
		ElseIf( cField == "AZ4_DSCCNT" )
			//-------------------------------------------------------------------
			// Recupera a descrição da conta. 
			//-------------------------------------------------------------------
			Do Case
				Case AZ4->AZ4_CNTENT == "SA1"					
					cReturn := Posicione( "SA1", 1, xFilial("SA1")+AZ4->AZ4_CODENT, "A1_NOME" )
				Case AZ4->AZ4_CNTENT == "ACH"
					cReturn := Posicione( "ACH", 1, xFilial("ACH")+AZ4->AZ4_CODENT, "ACH_RAZAO" )
				Case AZ4->AZ4_CNTENT == "SUS"
					cReturn := Posicione( "SUS", 1, xFilial("SUS")+AZ4->AZ4_CODENT, "US_NOME" )
				OtherWise
					cReturn := ""
			EndCase		
		EndIf 
	EndIf 
Return cReturn  

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA950Viewer
Monta a interface de visualização do log.

@return cLog, caracter, Log a ser exibido. 

@author  Valdiney V GOMES 
@version P12
@since   10/07/2015  
/*/
//-------------------------------------------------------------------
Function CRMA950Viewer( cLog ) 
	Local oModel    := Nil
	Local oDlg      := Nil
	Local oPanel    := Nil
	Local oLog	   	:= Nil 
	Local oFont    	:= Nil 
	
	Default cLog	:= ""
	
	//-------------------------------------------------------------------
	// Monta o janela para exibição do log. 
	//------------------------------------------------------------------- 
	oDlg := FWDialogModal():New()	   	
	oDlg:SetBackground( .F. )
	oDlg:SetEscClose( .T. )
	oDlg:SetSize( 300, 320 )
	oDlg:EnableFormBar( .T. )
	oDlg:CreateDialog() 
	oDlg:addCloseButton()
	
	//-------------------------------------------------------------------
	// Define a fonte do campo texto.  
	//-------------------------------------------------------------------	
	oFont := TFont():New( "Currier",, 15, .T., .T. )
		
	//-------------------------------------------------------------------
	// Recupera o container para o campo texto.  
	//-------------------------------------------------------------------		
	oPanel := oDlg:getPanelMain()

	//-------------------------------------------------------------------
	// Monta o campo texto com o conteúdo do log .  
	//-------------------------------------------------------------------	
	@ 000,000 GET oLog VAR cLog SIZE 0,0 MEMO HSCROLL OF oPanel PIXEL READONLY FONT oFont
	oLog:Align := CONTROL_ALIGN_ALLCLIENT			 
	
	oDlg:activate()	
Return 