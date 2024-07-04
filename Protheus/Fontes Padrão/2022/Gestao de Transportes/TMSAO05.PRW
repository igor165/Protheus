#INCLUDE "Protheus.ch"
#INCLUDE "TMSAO05.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"                 


//-------------------------------------------------------------------
/*TMSAO05
Cadastro de Macros

@author  Caio Murakami
@since   09/04/2012
@version 1.0      
*/
//-------------------------------------------------------------------
Function TMSAO05(aRotAuto,nOpcAuto)
Local aCoors := FWGetDialogSize( oMainWnd )   
Local oPanelUp, oFWLayer, oPanelDown, oBrowseUp, oBrowseDown, oRelacDAO 

Private cCadastro	:= STR0007
Private oDlgPrinc  
Private aRotina 	        

If aRotAuto == NIL

	DEFINE MSDIALOG oDlgPrinc TITLE STR0007 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL

	oFWLayer := FWLayer():New() //-- Cria novo Layer
	oFWLayer:Init( oDlgPrinc, .F., .T. )
	oFWLayer:AddLine( 'UP', 70, .F. ) //-- Adiciona linha com 70% da tela
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' ) //-- Adiciona coluna com 100% da tela
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )  

	oFWLayer:AddLine( 'DOWN', 30, .F. )//-- Adiciona linha com 30% da tela 
	oFWLayer:AddCollumn( 'LEFT' , 100, .T., 'DOWN' )//-- Coluna para a linha adicionada com 100% da tela	
	oPanelDown := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' ) 
	
	//-- Browse superior vinculado com estrutura oPanelUp criada
	oBrowseUp:= FWmBrowse():New()
	oBrowseUp:SetOwner( oPanelUp )
	oBrowseUp:SetDescription( STR0007 )
	oBrowseUp:SetAlias( 'DAO' )
	oBrowseUp:SetMenuDef( 'TMSAO05' )
	oBrowseUp:DisableDetails()
	oBrowseUp:SetProfileID( '1' ) 
	oBrowseUp:ForceQuitButton()
	oBrowseUp:Activate()
   
	//-- Browse superior vinculado com estrutura oPanelDown criada
	oBrowseDown:= FWMBrowse():New()
	oBrowseDown:SetOwner( oPanelDown )
	oBrowseDown:SetDescription( STR0006 )
	oBrowseDown:SetMenuDef( '' )
	oBrowseDown:DisableDetails()
	oBrowseDown:SetAlias( 'DAQ' )
	oBrowseDown:SetProfileID( '2' )
	oBrowseDown:Activate()
	
   //-- Realiza relacionamento entre os 2 browses criados 
	oRelacDAO:= FWBrwRelation():New()
	oRelacDAO:AddRelation( oBrowseUp , oBrowseDown , { {'xFilial("DAQ")','DAO_FILIAL'},{'DAQ_CODMAC','DAO_CODMAC'} } )
	oRelacDAO:Activate()
	
	ACTIVATE MSDIALOG oDlgPrinc CENTER

Else
	aRotina := MenuDef() 
	FwMvcRotAuto(ModelDef(),"DAO",nOpcAuto,{{"MdFieldDAO",aRotAuto}},.T.,.T.)  //-- Chamada da rotina automatica através do MVC  
EndIf  

Return


//-------------------------------------------------------------------
/*MenuDef
@author  Caio Murakami
@since   09/04/2012
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}  

ADD OPTION aRotina TITLE OemToAnsi(STR0001) ACTION "PesqBrw"         OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE OemToAnsi(STR0002) ACTION "VIEWDEF.TMSAO05" OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE OemToAnsi(STR0003) ACTION "VIEWDEF.TMSAO05" OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE OemToAnsi(STR0004) ACTION "VIEWDEF.TMSAO05" OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE OemToAnsi(STR0005) ACTION "VIEWDEF.TMSAO05" OPERATION 5 ACCESS 0 // "Excluir" 
    
Return aRotina


//-------------------------------------------------------------------
/*ModelDef
Model do Cadastro de Macros

@author  Caio Murakami
@since   09/04/2012
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 	   := Nil
Local oStructDAO 	:= Nil 
Local oStructDAQ	:= NIL     
Local oStructDAZ	:= NIl

oStructDAO := FwFormStruct(1,'DAO',,)
oStructDAQ := FwFormStruct(1,'DAQ',,)
oStructDAZ := FwFormStruct(1,'DAZ',,)

                                                           
//-- Gatilhos do grid
oStructDAQ:AddTrigger( 'DAQ_TAMCPO', 'DAQ_POSFIM', {||.T.},{|oModel,cField,cValue,nLine|AO05Trigg(oModel,cField,cValue,nLine)})
oStructDAQ:AddTrigger( 'DAQ_POSINI', 'DAQ_POSFIM', {||.T.},{|oModel,cField,cValue,nLine|AO05Trigg(oModel,cField,cValue,nLine)})

oModel:= MpFormModel():New('TMSAO05',/*bPreValid*/,/*bPosValid*/,{|oModel|CommitMdl(oModel) },/*Cancel*/) 

oModel:AddFields('MdFieldDAO',,oStructDAO ,/*bPreValid*/, /*bPos*/,/*Carga*/)

//-- MdGridDAQ
oModel:AddGrid('MdGridDAQ','MdFieldDAO', oStructDAQ,,{|oModel|PosVldDAQ(oModel)},/*bPre*/, /*bPosVal*/, /*BLoad*/ ) 
oModel:SetRelation('MdGridDAQ',{ {'DAQ_FILIAL','xFilial("DAQ")'},{'DAQ_CODMAC','DAO_CODMAC'} }, DAQ->( IndexKey(1) ) )

//-- MdGridDAZ
oModel:AddGrid('MdGridDAZ','MdFieldDAO',oStructDAZ,,/*{|oModel|AO05DAZPre(oModel) }*/,, , /*BLoad*/ )
oModel:SetRelation('MdGridDAZ',{ {'DAZ_FILIAL','xFilial("DAO")'},{'DAZ_CODMAC','DAO_CODMAC'} }, DAZ->( IndexKey(1) ) ) 

//-- MdGridDAQ
oModel:GetModel( 'MdGridDAQ' ):SetOptional(.T.) //-- Permite grid sem dados
oModel:GetModel( 'MdGridDAQ' ):SetDescription(STR0006)

//-- MdGridDAZ
oModel:GetModel( 'MdGridDAZ' ):SetOptional(.T.)
oModel:GetModel( 'MdGridDAZ' ):SetDescription(STR0010)   
oModel:GetModel( 'MdGridDAZ' ):SetUniqueLine({'DAZ_SERTMS'})

//-- MdFieldDAO
oModel:SetDescription(STR0007) 								//-- Cadastro de Macros 
oModel:GetModel('MdFieldDAO'):SetDescription(STR0007) //-- Cadastro de Macros 
oModel:SetPrimaryKey({'DAO_CODMAC'})   

Return ( oModel )  

//-------------------------------------------------------------------
/* ViewDef
Definicao da Visao

@author  Caio Murakami
@since   09/04/2012
@version 1.0
*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oStruDAO := FwFormStruct(2,'DAO') 
Local oStruDAQ := FwFormStruct(2,'DAQ') 
Local oStruDAZ := FwFormStruct(2,'DAZ')

Local oModel   := FwLoadModel('TMSAO05')            
Local oView    

oView := FwFormView():New()
oView:SetModel(oModel)  

oView:AddField('VwFieldDAO', oStruDAO , 'MdFieldDAO') 
oView:AddGrid( 'VwGridDAQ', oStruDAQ , 'MdGridDAQ')
oView:AddGrid( 'VwGridDAZ', oStruDAZ , 'MdGridDAZ')

oView:CreateHorizontalBox('CABECALHO',35)
oView:CreateHorizontalBox('GRID_DAZ',25)
oView:CreateHorizontalBox('GRID_DAQ',40)

oView:SetOwnerView('VwFieldDAO','CABECALHO')
oView:SetOwnerView('VwGridDAQ','GRID_DAQ')
oView:SetOwnerView('VwGridDAZ','GRID_DAZ')

oView:AddIncrementField('VwGridDAQ','DAQ_ITEM')

oView:EnableTitleView('VwFieldDAO',STR0008) //-- Cadastro de Macros
oView:EnableTitleView('VwGridDAQ',STR0009) //-- Configuração de Macros                      
oView:EnableTitleView('VwGridDAZ',STR0010) //-- Cod. Ocorrencia por Macro

Return oView      
 

//-------------------------------------------------------------------
/*IntegDef
Mensagem Unica

@author  Caio Murakami
@since   09/04/2012
@version 1.0      
*/
//-------------------------------------------------------------------

Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

Local aRet := {}

aRet := TMSIO05( cXML , nTypeTrans , cTypeMessage )

Return aRet   


//-------------------------------------------------------------------
/*PosVldDAQ
Validador de linha

@author  Caio Murakami
@since   09/04/2012
@version 1.0      
*/
//-------------------------------------------------------------------


Static Function PosVldDAQ(oModel)
Local lRet 		:= .T.
Local cCpoMac	:= oModel:GetValue("DAQ_CPOMAC")
Local aSaveLine:=	FWSaveRows()

If Empty(cCpoMac)
	Help("" ,, 'TMSAO0502') //--'Para se utilizar o configurador de macro deve-se haver no minimo um campo configurado' 
	lRet := .F.
EndIf
 
FwRestRows( aSaveLine ) 
Return lRet 


//-------------------------------------------------------------------
/*AO05Trigg
Gatilhos do model

@author  Caio Murakami
@since   15/05/2012
@version 1.0      
*/
//-------------------------------------------------------------------

Function AO05Trigg(oModel,cField,cValue,nLine)
Local xRet		:= 0
Local nLength	:= 0
Local aArea		:= GetArea()
Local aSaveLine:=	FWSaveRows() 

Default cField := ReadVar() 

If oModel <> NIL

	nLength:= oModel:Length()
	               
	If 'DAQ_TAMCPO' $ cField     
	
		If oModel:GetValue('DAQ_POSINI') != 0 
			xRet := oModel:GetValue(cField) + oModel:GetValue('DAQ_POSINI') - 1 
		EndIf	
		
	ElseIf 'DAQ_POSINI' $ cField 
		
		xRet := oModel:GetValue('DAQ_TAMCPO') + oModel:GetValue(cField) - 1 
	
	EndIf       

Else
	
	If 'DAQ_CPOMAC' $ cField  
		If M->DAQ_CPOMAC ==  '01' 
			xRet := TamSX3("DT6_FILDOC")[1]
		ElseIf M->DAQ_CPOMAC ==  '02'    
			xRet := TamSX3("DT6_DOC")[1]
		ElseIf M->DAQ_CPOMAC ==  '03'
			xRet := TamSX3("DT6_QTDVOL")[1]
		ElseIf M->DAQ_CPOMAC ==  '05'
			xRet := TamSX3("DAQ_FILIAL")[1]
		ElseIf M->DAQ_CPOMAC ==  '06'
		 	xRet := TamSX3("DTQ_FILORI")[1]
		ElseIf M->DAQ_CPOMAC ==  '07'
		   xRet := TamSX3("DTQ_VIAGEM")[1]
		ElseIf Empty(M->DAQ_CPOMAC)
			xRet := 0
		EndIf		
	EndIf	
	
EndIf

FwRestRows( aSaveLine ) 
RestArea( aArea )

Return xRet 

//-------------------------------------------------------------------
/*TmsAO05Vld
Valida os campos

@author  Caio Murakami
@since   15/05/2012
@version 1.0      
*/
//-------------------------------------------------------------------
 
Function TmsAO05Vld()
Local lRet := .T.
Local aSaveLine:=	FWSaveRows()
Local aArea		:= GetArea()
Local nLine    := 0
Local nPosIni	:= 0
Local nPosFim	:= 0 
Local nCount	:= 0
Local aCpoMac	:= {} 
Local lVldMac	:= .T.
Local oModel
 
Local cField  := ReadVar()

If 'DAQ_CPOMAC' $ cField
	
	lRet := Vazio() .Or. TMSValField(SubStr(cField,4,Len(cField)), .T. ) 
	
	If lRet
		/*
 		[01]-Fil. Doc.  
  	 	[02]-Doc.
  	 	[03]-Qtd. Vol. 
		[04]-Obs. Macro
	 	[05]-Filial 
		[06]-Fil. Ori. 
		[07]-Viagem 
	 	*/
		aCpoMac := TMSValField(SubStr(cField,4,Len(cField)),.F.,,.F.,.T.)	
	 	oModel := FwModelActive()
	 	oModel := oModel:GetModel('MdGridDAZ')
	 	
	 	For nCount := 1 To oModel:Length()
	 		If !Empty(oModel:GetValue('DAZ_CODOCO'))
	 			lVldMac := .F.
	 			Exit	
	 		EndIf	
	 	Next nCount 
	 	
	 	//-- Se nao houver ocorrencia vinculada, deve-se permitir apenas os campos: [05]-Filial  [06]-Fil. Ori. [07]-Viagem 
	 	If lVldMac
	 		lRet := M->DAQ_CPOMAC $ '05/06/07'	
	 	EndIf
	 	 
	EndIf
	 
ElseIf 'DAQ_POSINI' $ cField

	oModel  := FwModelActive()
	oModel  := oModel:GetModel("MdGridDAQ")    
   nLine	  := oModel:GetLine()
   nPosIni := FwFldGet("DAQ_POSINI")
   
   If nLine > 1 
   	nLine--
   	oModel:GoLine(nLine)
   	nPosFim := oModel:GetValue("DAQ_POSFIM")
   	
   	While oModel:IsDeleted() .And. nLine > 1
   		nLine--   		
     		oModel:GoLine(nLine)
     		nPosFim := oModel:GetValue("DAQ_POSFIM")
   	EndDo
   	
   	If nPosIni <= nPosFim
   		Help( "",, 'TMSAO0501') //-- A posição inicial deve ser maior que a posição final do campo de macro anterior
   		lRet := .F.
   	EndIf   		
   EndIf

ElseIf 'DAO_CODMAC' $ cField

	lRet := ExistChav("DAO",M->DAO_CODMAC,1)

ElseIf 'DAO_ATIVID' $ cField   

	lRet := Vazio() .Or. ExistCpo("SX5","L3"+M->DAO_ATIVID)	

   If Empty(M->DAO_ATIVID)
   	M->DAO_TIPAPO := '0'
   Else	
   	M->DAO_TIPAPO := '3'
   EndIF

ElseIf 'DAO_TIPAPO' $ cField	     

   lRet := Iif(!Empty(M->DAO_ATIVID),Pertence("123"),Pertence("0") )  
   
ElseIf 'DAZ_CODOCO' $ cField       

	lRet := Vazio() .Or. ExistCpo("DT2", M->DAZ_CODOCO,1)  

EndIf

FwRestRows( aSaveLine ) 
RestArea( aArea ) 

Return lRet   


//-------------------------------------------------------------------
/* CommitMdl
Efetua a gravacao do model

@author  Caio Murakami
@since   02/01/13
@version 1.0
*/
//-------------------------------------------------------------------

 
Static Function CommitMdl(oModel)
Local lRet := .T.

//-- Efetua a gravacao do Model
FwFormCommit( oModel )

Return lRet	 
              