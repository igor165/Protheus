#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSAO30.CH' 

//-------------------------------------------------------------------
/*TMSAO30

Configurador de parametros da jornada de trabalho do motorista

@author  Caio Murakami
@since   22/11/2012
@version 1.0      
*/
//-------------------------------------------------------------------

Function TMSAO30(aRotAuto, aItensAuto, nOpcAuto )
Local aCoors 		:= FWGetDialogSize( oMainWnd )   
Local oPanelUp, oFWLayer, oPanelDown, oBrowseUp, oBrowseDown, oRelacDAO 
Local lAptJor		:= SuperGetMv("MV_CONTJOR",,.F.) //-- Apontamento da jornada de trabalho do motorista 

Private cCadastro	:= STR0001
Private oDlgPrinc  
Private aRotina    

Default aRotAuto 		:= NIL  
Default aItensAuto 	:= {}

If !lAptJor
	Help(,1,"TMSAO3002" ) //-- Jornada nao habilitada
	Return
EndIf	


If aRotAuto == Nil
  		
	DEFINE MSDIALOG oDlgPrinc TITLE cCadastro FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL

	oFWLayer := FWLayer():New() //-- Cria novo Layer
	oFWLayer:Init( oDlgPrinc, .F., .T. )
	oFWLayer:AddLine( 'UP', 45, .F. ) //-- Adiciona linha com 45% da tela
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' ) //-- Adiciona coluna com 100% da tela
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )  

	oFWLayer:AddLine( 'DOWN', 55, .F. )//-- Adiciona linha com 55% da tela 
	oFWLayer:AddCollumn( 'LEFT' , 100, .T., 'DOWN' )//-- Coluna para a linha adicionada com 100% da tela	
	oPanelDown := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' ) 
	
	//-- Browse superior vinculado com estrutura oPanelUp criada
	oBrowseUp:= FWmBrowse():New()
	oBrowseUp:SetOwner( oPanelUp )
	oBrowseUp:SetDescription( cCadastro )
	oBrowseUp:SetAlias( 'DEZ' )
	oBrowseUp:SetMenuDef( 'TMSAO30' )
	oBrowseUp:DisableDetails() 
	oBrowseUp:SetProfileID( '1' ) 
	oBrowseUp:ForceQuitButton()
	oBrowseUp:Activate()
   
	//-- Browse superior vinculado com estrutura oPanelDown criada
	oBrowseDown:= FWMBrowse():New()
	oBrowseDown:SetOwner( oPanelDown )
	oBrowseDown:SetDescription( STR0001 )
	oBrowseDown:SetMenuDef( '' )
	oBrowseDown:DisableDetails()
	oBrowseDown:SetAlias( 'DEY' ) 	
	oBrowseDown:SetProfileID( '2' )
	oBrowseDown:Activate()
	
   //-- Realiza relacionamento entre os 2 browses criados 
	oRelacDAO:= FWBrwRelation():New()
	oRelacDAO:AddRelation( oBrowseUp , oBrowseDown , { {"DEY_FILIAL","xFilial('DEY')" },{"DEY_TIPTRA","DEZ_TIPTRA"},{"DEY_SERTMS","DEZ_SERTMS"}} )
	oRelacDAO:Activate()
	
	ACTIVATE MSDIALOG oDlgPrinc CENTER 

Else
	aRotina   := MenuDef() 
	FwMvcRotAuto(ModelDef(),"DEZ",nOpcAuto,{ {"MdFieldDEZ",aRotAuto},{"MdGridDEY",aItensAuto}  },.T.,.T.)  //-- Chamada da rotina automatica através do MVC  
EndIf

Return

//-------------------------------------------------------------------
/*MenuDef
@author  Caio Murakami
@since   21/01/2013
@version 1.0      
*/
//-------------------------------------------------------------------

Static Function MenuDef()  
Local aRot := {}   

	aAdd( aRot, { STR0002    	, 'VIEWDEF.TMSAO30', 0, 3, 0, NIL } )	//-- Incluir
	aAdd( aRot, { STR0003     	, 'VIEWDEF.TMSAO30', 0, 4, 0, NIL } )	//-- Alterar
	aAdd( aRot, { STR0004    	, 'VIEWDEF.TMSAO30', 0, 5, 0, NIL } )	//-- Excluir
	aAdd( aRot, { STR0005   	, 'VIEWDEF.TMSAO30', 0, 2, 0, NIL } )	//-- Visualizar	
	aAdd( aRot, { STR0006  		, 'VIEWDEF.TMSAO30', 0, 8, 0, NIL } )	//-- Imprimir
	aAdd( aRot, { STR0007 		, 'VIEWDEF.TMSAO30', 0, 9, 0, NIL } )	//-- Copiar

Return aRot


//-------------------------------------------------------------------
/*ModelDef
Model dos Parametros da Jornada de Trabalho

@author  Caio Murakami
@since   21/01/2013
@version 1.0      
*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel 	   := Nil
Local oStruDEZ	 	:= FwFormStruct(1,"DEZ")
Local oStruDEY		:= FwFormStruct(1,"DEY")
                                                      
oModel:= MpFormModel():New("TMSAO30",,,,/*Cancel*/)  

oModel:AddFields("MdFieldDEZ",,oStruDEZ,/*bPreValid*/,{|oModel|PosVldMdl(oModel)})
oModel:SetDescription(STR0001)
 								
oModel:AddGrid("MdGridDEY" , "MdFieldDEZ" , oStruDEY, ,{|oModel|PosVldDEY(oModel)} , , , )
oModel:SetRelation( "MdGridDEY",{{"DEY_FILIAL","xFilial('DEY')" },{"DEY_SERTMS","DEZ_SERTMS"},{"DEY_TIPTRA","DEZ_TIPTRA"} } , DEY->( IndexKey(1) ) ) 
oModel:GetModel("MdGridDEY"):SetUniqueLine({'DEY_CODPAR','DEY_TIPVEI'}) 
 
oModel:SetPrimaryKey({"DEY_FILIAL","DEY_SERTMS","DEY_TIPTRA","DEY_CODPAR","DEY_TIPVEI"})

Return oModel

//-------------------------------------------------------------------
/* ViewDef
Definicao da View 

@author  Caio Murakami
@since   21/01/2013
@version 1.0
*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oStruDEZ 	:= FwFormStruct(2,"DEZ")
Local oStruDEY 	:= FwFormStruct(2,"DEY")
Local oModel     	:= FwLoadModel('TMSAO30')            
Local oView    	:= FwFormView():New()

oView:SetModel(oModel)
oView:AddField('VwFieldDEZ', oStruDEZ , 'MdFieldDEZ') 
oView:AddGrid('VwGridDEY' , oStruDEY , 'MdGridDEY')                                

oView:CreateHorizontalBox('CABECALHO',40)  
oView:CreateHorizontalBox('GRID',60)
oView:SetOwnerView('VwFieldDEZ','CABECALHO')   
oView:SetOwnerView('VwGridDEY','GRID')   

DEY->( DbGoTo(0) )

Return oView 


//--------------------------------------------------------------------
/*PosVldMdl() 
Pos Valid do Model

@author  Caio Murakami
@since   05/02/2013
@version 1.0

*/
//--------------------------------------------------------------------

Static Function PosVldMdl( oModel )
Local lRet 		:= .T.
Local cTipTra  := oModel:GetValue("DEZ_TIPTRA")
Local cSerTMS	:= oModel:GetValue("DEZ_SERTMS") 
Local nOpc		:= oModel:GetOperation()  
Local aAreaDEZ := DEZ->( GetArea() ) 

If nOpc == 3
	DEZ->( dbSetOrder(1) ) 	
	If DEZ->( MsSeek( xFilial("DEZ")+cTipTra+cSerTMS ) )
		lRet := .F.
		Help(,1,"TMSAO3001" ) //-- O registro já existe
	EndIf                                             
EndIf


RestArea( aAreaDEZ ) 
Return lRet 


//--------------------------------------------------------------------
/*PosVldDEY() 
Pos Valid do Grid

@author  Caio Murakami
@since   05/02/2013
@version 1.0

*/
//--------------------------------------------------------------------

Static Function PosVldDEY( oModel )   
Local lRet 		:= .T.
Local cTipTra	:= M->DEZ_TIPTRA
Local cSerTMS	:= M->DEZ_SERTMS
Local cCodPar	:= oModel:GetValue("DEY_CODPAR")
Local cTipVei	:= oModel:GetValue("DEY_TIPVEI")
Local aAreaDEY	:= DEY->( GetArea() )  

If oModel:IsInserted()
	DEY->( dbSetOrder(1) )

	If DEY->( MsSeek(xFilial("DEY") + cSerTMS+cTipTra+cCodPar+cTipVei ) )
   	lRet := .F.
		Help(,1,"TMSAO3001" ) //-- O registro já existe
   EndIf
Endif

RestArea( aAreaDEY ) 
Return lRet     

//--------------------------------------------------------------------
/*TMSAO05Vld() 
Validação de campos

@author  Caio Murakami
@since   05/02/2013
@version 1.0

*/
//--------------------------------------------------------------------
Function TMSAO30Vld(cField) 
Local lRet 		:= .T. 
Local oModel   := FwModelActive()
Local cValue	

Default cField := ReadVar()

If 'DEY_TEMPO' $ cField       

	oModel := oModel:GetModel("MdGridDEY")
	
	cValue := oModel:GetValue("DEY_TEMPO")
	cValue := StrTran(cValue," ","0")
	oModel:SetValue('DEY_TEMPO',cValue)
	
EndIf

Return lRet 		