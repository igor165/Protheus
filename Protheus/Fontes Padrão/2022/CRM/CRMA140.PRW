#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CRMA140.CH'


//----------------------------------------------------------
/*/{Protheus.doc} CRMA140()
CRMA140 - Check-in\out dos vendedores.

@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------

Function CRMA140(uRotAuto, nOpcAuto, cCodigo)

Local oBrowse := Nil

Private aRotina	:= {}

Default uRotAuto := Nil
Default nOpcAuto := Nil
Default cCodigo  := ""

If uRotAuto == Nil .AND. nOpcAuto == Nil 

	If !Empty(cCodigo)
	
			oBrowse := FWMBrowse():New()
			oBrowse:SetMenuDef("CRMA140")
			oBrowse:SetAlias("AIO")
			oBrowse:SetOnlyFields( {"AIO_TIPO","AIO_DATA","AIO_HORA","AIO_LATITU","AIO_LONGIT"} )
			oBrowse:SetFilterDefault("AIO_IDAGE == '"+cCodigo+"'")
			oBrowse:SetDescription(STR0001)//'Check-in\out'
			
    		oBrowse:Activate()
	
	Else
		Help( ,, STR0002,, STR0013, 1, 0 )	//'Help'//'Este compromisso não possui registros de check-in\out.'
	EndIf
Else
   // Faz a execução da rotina automática 
	FWMVCRotAuto(ModelDef(),"AIO",nOpcAuto,{{"AIOMASTER",uRotAuto}},/*lSeek*/,.T.)

  	If lMsErroAuto
  		MostraErro()
  		lMsErroAuto := .F. //Setando valor padrão para variavel
  	Endif

EndIf



Return

//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Opções disponiveis no menu.

@Return aRotina
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0004  Action "VIEWDEF.CRMA140" 	OPERATION 2 ACCESS 0//'Visualizar'
ADD OPTION aRotina Title STR0005  Action "CRMA140VMP()" 	   OPERATION 8 ACCESS 0//'Mapa'

Return aRotina

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
ModelDef - Atividades do vendedor (area de trabalho)

@Return oModel
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------

Static Function ModelDef()

Local oModel		:= Nil
Local oStruAIO	:= FWFormStruct( 1, "AIO" )

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( "CRMA140", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( "AIOMASTER", /*cOwner*/, oStruAIO )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0006)//'Atendimentos'

oModel:GetModel( "AIOMASTER" ):SetDescription(STR0007)//'Cabeçalho'

Return oModel

//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
ViewDef - Check-in\out vendedores.

@Return oView
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------

Static Function ViewDef()

Local oView 	 := FWFormView():New()
Local oModel 	 := FWLoadModel( "CRMA140" )
Local oStruAIO := FWFormStruct( 2, "AIO" )

oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( "VIEW_AIO_FIELD", oStruAIO, "AIOMASTER" )

oView:AddUserButton( STR0008, "CLIPS", {|oView| CRMA140VMP()} )//'Mapa'

oView:CreateHorizontalBox( "SUPERIOR", 100 )

oView:SetOwnerView( "VIEW_AIO_FIELD", "SUPERIOR" ) 

Return oView

//----------------------------------------------------------
/*/{Protheus.doc} CkcInOut()
CkcInOut - Visualização da localização geografica.

@Return MenuDef
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Function CRMA140VMP()

Local oDlg      := Nil
Local oPanel    := Nil
Local aSize     := MsAdvSize()
Local aArea     := GetArea()
Local aAreaAIO  := AIO->(GetArea())
Local cUrl	      := STR0009//"https://maps.google.com"

If (!Empty(AIO->AIO_LATITU) .AND. AllTrim(AIO->AIO_LATITU) <> "0") .AND.(!Empty(AIO->AIO_LONGIT) .AND. AllTrim(AIO->AIO_LONGIT) <> "0")

       cURL := cUrl+"/maps?q="+Alltrim(AIO->AIO_LATITU+AIO_LONGIT)
       oDlg := FWDialogModal():New()
			oDlg:SetBackground(.F.) // .T. -> escurece o fundo da janela 
			oDlg:SetTitle(STR0010)//"Ordem de Pesquisa"
			oDlg:SetEscClose(.T.)//permite fechar a tela com o ESC
			oDlg:SetSize(aSize[4],aSize[3]) //cria a tela maximizada (chamar sempre antes do CreateDialog)
			oDlg:EnableFormBar(.T.) 
			
	
			oDlg:CreateDialog() //cria a janela (cria os paineis)
			oDlg:createFormBar()//cria barra de botoes
       	    oDlg:addCloseButton()	
       	    oPanel := oDlg:getPanelMain()   
    
      		oTIBrowser := TIBrowser():New(0,0,aSize[3],aSize[4],cUrl,oPanel)
	   		oTIBrowser:GoHome()                   
		
		oDlg:Activate()
Else
	
	Help( ,, STR0011,, STR0012, 1, 0 )//'Help'//'Não foi possível capturar a localização geografica desse registro.'

EndIf        

RestArea(aAreaAIO)
RestArea(aArea)

Return
