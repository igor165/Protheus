#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAO15.CH"
#INCLUDE "APWIZARD.ch"

#DEFINE CRMARCA  1
#DEFINE CRCORBRW 2
#DEFINE CRALIAS  3
#DEFINE CRNOME   4
#DEFINE CRROTINA 5
#DEFINE CRMODEL  6
#DEFINE CRFILTRO 7

Static oWebChannel 	:= Nil
Static oWebEngine  	:= Nil
Static nWebPort    	:= 0
Static lRotaInt     := SuperGetMV("MV_ROTAINT",,.F.) //Maplink e TPR
Static lIntTPR      := .F.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º TMSAO15    º Autor º  Caio Murakami     º Data º 08.05.12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Programa  º Cadastro de referencia por municipio                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   º TMSAO15()                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametrosº                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   º Nil                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       º SIGATMS                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAO15(aRotAuto,nOpcAuto)  
Local oBrowse  := Nil
Local cRoteiri := ""

Private aRotina   := MenuDef()
Private cCadastro := STR0001 //-- "Cadastro de referencia" 
Private lAuto		:= .F.

If !IsBlind() .And. !IsInCallStack("TMSExecAuto")
	If lRotaInt .And. FindFunction( 'TMSROTEIRI')  
		cRoteiri:= TMSROTEIRI()   //Verifica o Roteirizador
    	lIntTPR:= cRoteiri == "2"
	EndIf
EndIf

If aRotAuto == NIL
	oBrowse := FWmBrowse():New()	
	oBrowse:SetAlias( 'DAR' )   		 
	oBrowse:SetDescription( cCadastro ) 
	oBrowse:Activate()	
Else  
	lAuto := .T.
	FwMVCRotAuto(ModelDef(), "DAR", nOpcAuto, {{"MdFieldDAR",aRotAuto}},.T.,.T.) // Chamada da rotina automatica atraves do MVC
EndIf

lIntTPR := .F.
lRotaInt:= .F.

Return NIL

//-------------------------------------------------------------------
/*MenuDef


@author  Caio Murakami
@since   08/05/2012
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina 	:= {}

ADD OPTION aRotina TITLE OemToAnsi(STR0002) ACTION "PesqBrw"         OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE OemToAnsi(STR0003) ACTION "VIEWDEF.TMSAO15" OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE OemToAnsi(STR0004) ACTION "VIEWDEF.TMSAO15" OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE OemToAnsi(STR0005) ACTION "VIEWDEF.TMSAO15" OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE OemToAnsi(STR0006) ACTION "VIEWDEF.TMSAO15" OPERATION 5 ACCESS 0 // "Excluir" 

If lRotaInt
	ADD OPTION aRotina TITLE OemToAnsi(STR0013) ACTION "TMSAO15Wzd" OPERATION 2 ACCESS 0 // "Wizard  - Geocode " 
	ADD OPTION aRotina TITLE OemToAnsi(STR0011 + '-'+ STR0008) ACTION "TMSAO15CGI" OPERATION 2 ACCESS 0 // "Carga de Dados - Geocode " 
EndIf

Return aRotina  

//-------------------------------------------------------------------
/*ModelDef

Cadastro de referencia por municipios

@author  Caio Murakami
@since   09/04/2012
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel     := Nil
Local oStructDAR := Nil  

oStructDAR := FwFormStruct(1,"DAR",,) 

oStructDAR:SetProperty( 'DAR_ENTIDA' , MODEL_FIELD_INIT  , {||'CC2'})  
oStructDAR:SetProperty( 'DAR_FILENT' , MODEL_FIELD_INIT  , {||xFilial('CC2')}) 
oStructDAR:SetProperty( 'DAR_ENTIDA' , MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"TMSAO15Vld()") ) 
oStructDAR:SetProperty( 'DAR_CODENT' , MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"TMSAO15Vld()") ) 
oStructDAR:SetProperty( 'DAR_LATITU' , MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"TMSAO15Vld()") ) 
oStructDAR:SetProperty( 'DAR_LONGIT' , MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"TMSAO15Vld()") ) 

oStructDAR:AddTrigger(  'DAR_ENTIDA' , 'DAR_FILENT', {||.T.},{|oModel,cField,cValue,nLine|AO15Trigg(oModel,cField,cValue,nLine,'DAR_FILENT')})
oStructDAR:AddTrigger(  'DAR_ENTIDA' , 'DAR_CODENT', {||.T.},{|oModel,cField,cValue,nLine|AO15Trigg(oModel,cField,cValue,nLine,'DAR_CODENT')})

oModel:= MpFormModel():New("TMSAO15",,{|oModel|PosVldMdl(oModel)},,/*Cancel*/)  
oModel:AddFields("MdFieldDAR",,oStructDAR,,,/*Carga*/)
oModel:SetDescription(STR0001) 								
oModel:GetModel("MdFieldDAR"):SetDescription(STR0001) 
oModel:SetPrimaryKey({"DAR_FILIAL","DAR_FILENT","DAR_ENTIDA","DAR_CODENT","DAR_LATITU","DAR_LONGIT"})

Return ( oModel )

//-------------------------------------------------------------------
/*ViewDef

Cadastro de referencia por municipios

@author  Caio Murakami
@since   09/04/2012
@version 1.0      
*/
//-------------------------------------------------------------------    
Static Function ViewDef()
Local oView      
Local oModel     := FwLoadModel("TMSAO15")
Local oStructDAR := FwFormStruct(2,"DAR")  

//-- A mesma picture deve ser utilizada no cadastro de posicionamento
Local cPicture:= PesqPict('DAV','DAV_LATITU')

oStructDAR:SetProperty( 'DAR_LATITU' , MVC_VIEW_PICT  ,cPicture )
oStructDAR:SetProperty( 'DAR_LONGIT' , MVC_VIEW_PICT  ,cPicture )

oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField('VwFieldDAR', oStructDAR , 'MdFieldDAR') 

If lIntTPR .And. FindFunction("T25URLMap")
	oView:AddOtherObject("VIEW_HTML" , {|oPanel,oModel| T15PNHTML(oPanel,oModel)})
	oView:CreateHorizontalBox( "SUPERIOR", 27 )// Primeira Linha da Tela
	oView:CreateHorizontalBox( "INFERIOR", 73 )// Segunda  Linha da Tela
	oView:SetOwnerView( 'VwFieldDAR', 'SUPERIOR' )
	oView:SetOwnerView( "VIEW_HTML","INFERIOR" )
Else
	oView:CreateHorizontalBox('TELA',100)
	oView:SetOwnerView('VwFieldDAR','TELA')
EndIf
oView:EnableTitleView('VwFieldDAR',STR0001)

Return ( oView ) 

//-------------------------------------------------------------------
/* AO15Trigg
Gatilhos dos campos da tabela DAR

@author  Caio Murakami
@since   22/05/2012
@version 1.0
*/
//-------------------------------------------------------------------
Static Function AO15Trigg(oModel,cField,cValue,nLine,cDest)
Local xRet 		:= Nil  

If 'DAR_ENTIDA' $ cField
	
	If 'DAR_FILENT' $ cDest		
	 	xRet := xFilial(AllTrim(cValue))
	ElseIf 'DAR_CODENT' $ cDest
		xRet := ""
	EndIf 
		
EndIf

Return xRet

//-------------------------------------------------------------------
/* PosVldMdl
Valid do Model                   
@author  Caio Murakami
@since   22/05/2012
@version 1.0
*/
//------------------------------------------------------------------- 
Static Function PosVldMdl(oModel)
Local lRet 		:= .T. 

If oModel:GetOperation() == 3
	DEFAULT M->DAR_FILENT := CriaVar('DAR_FILENT', .F.) 
	DEFAULT M->DAR_ENTIDA := CriaVar('DAR_ENTIDA', .F.) 
	DEFAULT M->DAR_CODENT := CriaVar('DAR_CODENT', .F.) 
	DEFAULT M->DAR_LATITU := CriaVar('DAR_LATITU', .F.)  
	DEFAULT M->DAR_LONGIT := CriaVar('DAR_LONGIT', .F.) 
	
	DAR->( dbSetOrder(1) )
	If DAR->( dbSeek(xFilial("DAR") + M->DAR_FILENT + M->DAR_ENTIDA + M->DAR_CODENT + M->DAR_LATITU + M->DAR_LONGIT))
		lRet := .F.
		Help("", 1, "JAGRAVADO")
	EndIf 
EndIf

Return lRet

//-------------------------------------------------------------------
/* TMSAO15Vld
Valid dos campos                
@author  Caio Murakami
@since   22/05/2012
@version 1.0
*/
//------------------------------------------------------------------- 
Function TMSAO15Vld()
Local lRet 		:= .T.    
Local cAlias	:= ""     
Local cLatitu	:= ""
Local cLongit	:= ""
Local oModel	:= FwModelActive()
Local cField	:= ReadVar()   
Local oView    := FwViewActive()

oModel := oModel:GetModel("MdFieldDAR")

If 'DAR_ENTIDA' $ cField  
	//-- Campo DAR_ENTIDA é preenchido com o alias de tabelas, por isso a verificacao AliasInDic
	cAlias := oModel:GetValue('DAR_ENTIDA')
	If !Vazio() .And. cAlias <> 'SM0'
		If !AliasInDic(cAlias)
			lRet := .F.
			Help("",1, "REGNOIS") //Nao existe registro relacionado a este codigo.
		EndIf
   EndIf   
   
ElseIf 'DAR_LATITU' $ cField  

	cLatitu := TMSLatLong(oModel:GetValue("DAR_LATITU"))
		   
	If !(SubStr(cLatitu,1,1) $ "-;0")
	  lRet := .F.
	  Help( ,,'TMSAO1501') 
	EndIf 
	If lRet 
		oModel:SetValue("DAR_LATITU", cLatitu)
		If !IsBlind() .And. !IsInCallStack("TMSExecAuto") 
	   		oView:Refresh()
			If lIntTPR
				T15ShowCrd()
			EndIf
	 	EndIf
	EndIf 
	                                                                                             
ElseIf 'DAR_LONGIT' $ cField  
  	
  	cLongit := TMSLatLong(oModel:GetValue("DAR_LONGIT")) 
  	  
	If !(SubStr(cLongit,1,1) $ "-;0")
		lRet := .F.
		Help( ,,'TMSAO1501')		
	EndIf    
	If lRet 
		oModel:SetValue("DAR_LONGIT", cLongit)  
		If !IsBlind() .And. !IsInCallStack("TMSExecAuto")
	   		oView:Refresh()
			If lIntTPR
				T15ShowCrd()
			EndIf
	 	EndIf
	EndIf 

ElseIf 'DAR_CODENT' $ cField //.And. nModulo == 39

  	If oModel:GetOperation() == MODEL_OPERATION_INSERT
	  
		If Empty(oModel:GetValue('DAR_ENTIDA'))
			Help(,,'HELP',,"Favor informar a entidade primeiro (DAR_ENTIDA).",1,0,)
			Return .F.
		EndIf

		lRet := TMSAO15UNI(oModel:GetValue('DAR_FILENT'), oModel:GetValue('DAR_ENTIDA'), oModel:GetValue('DAR_CODENT'))
		
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/* TmsAO15CC2
Consulta Especifica CC2DAR
                  
@author  Caio Murakami
@since   15/06/2012
@version 1.0
*/
//------------------------------------------------------------------- 
Function TmsAO15CC2()

Local aAreaAtu    := GetArea()
Local lRet        := .T.
Local oModel		:= FwModelActive()
Local cEntida 		:= "" 

If !Empty(oModel)
	oModel 	:= oModel:GetModel('MdFieldDAR')
	cEntida := oModel:GetValue('DAR_ENTIDA')

	If ('CC2' $ cEntida)         

		lRet := ConPad1(,,,"CC2",,,.F.)
		If lRet
			Var_IXB := TMS120CdUf( CC2->CC2_EST , "1") + CC2->CC2_CODMUN
		Else
			//Help(,,"NOSXB")
		EndIf	
	Else 
		lRet := ConPad1(,,,AllTrim(cEntida),,,.F.)
		If lRet
			dbSelectArea(cEntida)
			dbSetOrder(1)
			Var_IXB := Iif(cEntida <> "SM0" , Substr(&(IndexKey()),Len(CC2->CC2_FILIAL)+1), ; 
											Substr(&(IndexKey()),Len(FWGrpCompany())+1 ) )

		EndIf
	EndIf
Else
	lRet := ConPad1(,,,"DAR",,,.F.)
EndIf
RestArea( aAreaAtu )

Return lRet  

//-------------------------------------------------------------------
/*IntegDef

@author  Caio Murakami
@since   15/06/2012
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local aRet := {}

aRet := TMSIO15( cXML , nTypeTrans , cTypeMessage )

Return aRet   

//-------------------------------------------------------------------
/*AtuDARSM0

@author  Caio Murakami
@since   02/08/2019
@version 1.0      
*/
//------------------------------------------------------------------- 
Function TMSAO15Wzd()
Local aArea		:= GetArea()
Local oWizard	
Local aFilChck	:= FindDARSM0()

//------------------------------------------------------------
// Tela de Apresentacao
//------------------------------------------------------------
oWizard := APWizard():New(		STR0008 ,; //"GeocCode"
								STR0010  ,;	//-- "Carga de Dados"
								STR0009  ,; //-- "Esse assistente auxilia na obtenção das coordenadas geograficas"                                                                                                                                                                                                                                                                                                                                                                                                                                                   
								STR0009 + STR0010  ,; //-- " através da utilização da API Geocode do Roteirizador"  
								{|| .T. },; // bNext
								{|| .T. },; // bFinish
								, , , )

oWizard:NewPanel( 	STR0010 ,;  //"Carga de Dados"
					STR0012 ,;  //"Seleciona a filial que deseja obter as referências geograficas"
					{|| .T.} ,; // bBack
					{|| .T. }  , ; // bNext
					{|| GerDARSM0( @aFilChck ) }  ,; // bFinish
					.F. ,; // Se .T. será criado um painel, se .F. será criado um scrollbox
					{|| GetFilias( oWizard, , , , @aFilChck )}) // bExecute lArq := ParamBox(aParam, "Arquivos de Importação", @aRet) })						

oWizard:Activate(	.T./*<.lCenter.>*/,;
					{||.T.}/*<bValid>*/, ;
					{||.T.}/*<bInit>*/, ;
					{||.T.}/*<bWhen>*/ )

RestArea(aArea)
Return

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getFolder
	
@author 
@since
@version 1.0		

@param oWizard, objeto, componente do wizard que servira de base para a tela
@return cPathArq, String com o folder selecionado
@description
	

/*/
//--------------------------------------------------------------------------------------------------------

Static Function getFilias(oWizard, cPathArq, cPathLay, lExport, aFilChck)
Local nLinha	:= 14
Local nCount	:= 1 
Local cSay		:= ""
Local cMacroChk	:= ""
Local cPosFil	:= ""
Local cVariable	:= ""
Local cGet		:= ""

oWizard:oMPanel[oWizard:nPanel]:FreeChildren()

For nCount := 1 To Len(aFilChck)
	cSay		:= aFilChck[nCount,1] + "/" + aFilChck[nCount,2]
	cPosFil		:= Str(nCount)
	cVariable	:= "aFilChck["+Str(nCount)+"][3]"
	cGet		:= "{ |U| If(PCOUNT() > 0, "+cVariable+" := U, "+cVariable+")} "
	&(cMacroChk) := TCheckBox():New( nLinha, 01, cSay, &cGet, oWizard:oMPanel[oWizard:nPanel], 100, 210, , , , , , , , .T., , , )
	
	nLinha += 12
Next nCount

Return

//-------------------------------------------------------------------
/*AtuDARSM0

@author  Caio Murakami
@since   02/08/2019
@version 1.0      
*/
//------------------------------------------------------------------- 
Static Function FindDARSM0()
Local aAreaSM0  := SM0->(GetArea())
Local aSM0		:= FWLoadSM0()
Local nCount	:= 1 
Local cCodFil	:= ""
Local cCodEmp	:= ""
Local aFiliais	:= {}

DAR->(dbSetOrder(1))
For nCount := 1 To Len(aSM0)
	cCodEmp		:= aSM0[nCount,1]
	cCodFil		:= aSM0[nCount,2]
	
	If !DAR->( dbSeek( xFilial("DAR") + Space(  TamSX3("DAR_FILENT")[1]  ) + "SM0" + cCodFil ) )
		Aadd( aFiliais , { cCodEmp , cCodFil , .T. })
	EndIf

Next nCount

RestArea(aAreaSM0)
Return aFiliais

//-------------------------------------------------------------------
/*GerDARSM0

@author  Caio Murakami
@since   02/08/2019
@version 1.0      
*/
//------------------------------------------------------------------- 
Static Function GerDARSM0(aFilChck)
Local oDadosGeo	:= NIL
Local cEnd		:= ""
Local cEst		:= ""
Local cMun		:= ""
Local cBairro	:= ""
Local cCep		:= ""
Local aGeoCode	:= {}
Local aCpoRet	:= {}
Local cLatitu	:= ""
Local cLongit	:= ""
Local nCount	:= 1 
Local aAux		:= ""
Local nAux		:= 1
Local nPos		:= 0
Local cFilEnt	:= ""
Local cEntida	:= "SM0"
Local cCodEnt	:= ""
Local cRoteiri  := ""
Local lRet      := .T.
Local cSigla    := ""

aAdd( aCpoRet, "M0_ESTENT" )
aAdd( aCpoRet, "M0_CIDENT" )
aAdd( aCpoRet, "M0_ENDENT" )
aAdd( aCpoRet, "M0_BAIRENT" )
aAdd( aCpoRet, "M0_CEPENT" )

If FindFunction( 'TMSROTEIRI') 
	cRoteiri:= TMSROTEIRI()   //Verifica o Roteirizador
    If cRoteiri == "2"
        oDadosGeo:= TMSBCATPRNeolog():New()
        lRet:= oDadosGeo:Auth()
    EndIf
EndIf

If lRet
    For nCount := 1 To Len(aFilChck)

        If aFilChck[nCount,3]
            cEnd	:= ""
            cEst	:= ""
            cMun	:= ""
            cBairro	:= ""
            cCep	:= ""
            cCodEnt	:= aFilChck[nCount,2]

            aAux	:= FWSM0Util():GetSM0Data( aFilChck[nCount,1] , aFilChck[nCount,2] , aCpoRet )
            
            For nAux := 1 To Len(aCpoRet)

                nPos	:= AScan(aAux , { |X| X[1] == aCpoRet[nAux] })
                If nPos > 0 
                    If aCpoRet[nAux] == "M0_ESTENT"
                        cEst	:= aAux[nPos,2]
                    ElseIf aCpoRet[nAux] == "M0_CIDENT"
                        cMun	:= aAux[nPos,2]
                    ElseIf aCpoRet[nAux] == "M0_ENDENT"
                        cEnd	:= aAux[nPos,2]
                    ElseIf aCpoRet[nAux] == "M0_BAIRENT"
                        cBairro	:= aAux[nPos,2]
                    ElseIf aCpoRet[nAux] == "M0_CEPENT"
                        cCep	:= aAux[nPos,2]
                    EndIf
                EndIf
            Next nAux 

            If cRoteiri == '2'  //TPR Neolog
                cIdent     := cFilEnt+cEntida+cCodEnt     //Chave da DAR		

                oDadosGeo:AddAddress( cIdent, Iif(Empty(cSigla) .Or. AllTrim(cSigla)== "*","BRA",cSigla) , cEst, cMun, cCep, cEnd )
                lRet:= oDadosGeo:PostGeoLoc()				
                If lRet
                    aGeoCode:= oDadosGeo:GetGeoLoc()
                Else
                    oDadosGeo:ShowError()
                EndIf
            EndIf

            If Len(aGeoCode) > 0
                cLatitu  	:= aGeoCode[1]
                cLongit 	:= aGeoCode[2]
                FWMsgRun( ,{|| TMSROT015(cFilEnt,cEntida,cCodEnt,cLatitu,cLongit) },,STR0014 ) //-- "Atualizando referências geográficas"
            EndIf

        EndIf

    Next nCount
EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} TMSAO15UNI()
//Valida duplicidade de entidade
@author  Equipe OMS
@since   04/11/2021
@version 1.0      
*/
//------------------------------------------------------------------- 
Static Function TMSAO15UNI(cFilEnt, cEntidade , cCodEnt)
	Local lRet := .T.
	Local aArea := GetArea()

	DAR->(DbSetOrder(1))
	If DAR->(DbSeek(FwXfilial("DAR")+cFilEnt+cEntidade+cCodEnt ))
		lRet := .F.
		Help(,,'HELP',,"A entidade já possui coordenadas cadastrada.",1,0,)
	EndIf

	RestArea(aArea)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} T15PNHTML()
Gera painel HTML
@author Equipe OMS
@since 05/11/2021
@version 1.0
@type function
/*/
//--------------------------------------------------------------------
Static Function T15PNHTML( oPanel, oModel )
	
	Local nMyWidth := 0
	Local nMyHeight := 0
	Local cLink		:= "" 

	cLink		:= T25URLMap()
	WebEngine()
	oMainWnd:CoorsUpdate()  // Atualiza as corrdenadas da Janela MAIN
	nMyWidth  := oMainWnd:nClientWidth
	nMyHeight := oMainWnd:nClientHeight
	oWebEngine := TWebEngine():New(oPanel, 0, 0, nMyHeight, nMyWidth,, nWebPort)
	LogMsg( "TMSAO15",0, 0,1, cValToChar(TIME()), '',cLink+ "?totvstec_websocket_port="+cValToChar(nWebPort))
	oWebEngine:navigate(RTrim(cLink) + "?totvstec_websocket_port="+cValToChar(nWebPort))
	oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
Return

/*/-----------------------------------------------------------
{Protheus.doc} WebEngine()
//Cria WebChannel para comunicação 
@author Equipe OMS
@since 05/11/2021
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function WebEngine()
	oWebChannel := TWebChannel():New()
	nWebPort    := oWebChannel:connect() // Efetua conexão e retorna a porta do WebSocket
	// Verifica conexão
	If !oWebChannel:lConnected
		MsgStop("Erro na conexão com o WebSocket") //Erro na conexão com o WebSocket
		Return // Aborta aplicação
	EndIf
	oWebChannel:bJsToAdvpl := {|self,codeType,codeContent| JsToAdvpl(self,codeType,codeContent) }
Return

/*/-----------------------------------------------------------
{Protheus.doc} JsToAdvpl()
//Recebe evento do JS
@author Equipe OMS
@since 05/11/2021
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function JsToAdvpl(self,codeType,codeContent)
 	If valType(codeType) == "C"
		If codeType == "pageStarted"
			If SetTPRToken() 
				T15ShowCrd()
			EndIf
		ElseIf codeType == "updCoord"
			OnUpdCoord(codeContent)
		EndIf
	EndIf
Return

/*/-----------------------------------------------------------
{Protheus.doc} T15ShowCrd() 
//Envia coordenadas para o JS para atualizar no mapa
@author Equipe OMS
@since 05/11/2021
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function T15ShowCrd()
	Local oModel	:= FwModelActive()
	Local oJsonObj  := JsonObject():New()
	Local oSubModel := NIL

	If !Empty(oModel)
		oSubModel := oModel:GetModel("MdFieldDAR")
		oJsonObj["latitude"] := oSubModel:GetValue("DAR_LATITU")
		oJsonObj["longitude"] := oSubModel:GetValue("DAR_LONGIT")   
		oWebChannel:advplToJs("TMSAO15", oJsonObj:toJSON())
		FreeObj(oJsonObj)
	EndIf
Return

/*/-----------------------------------------------------------
{Protheus.doc} OnUpdCoord()
//Recebe coordenadas do JS para atualizar na DAR
@author Equipe OMS
@since 05/11/2021
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function OnUpdCoord(codeContent)
	Local oView := FwViewActive()
	Local oModel    := FWModelActive()
	Local oModelDAR := oModel:GetModel("MdFieldDAR")
	Local oJsonObj   := JsonObject():New()
	Local  lat := "0"
	Local  long := "0"

	If !oModel:GetOperation() == MODEL_OPERATION_VIEW
		oJsonObj:fromJSON(codeContent)
		lat := cValToChar(oJsonObj["latitude"])
		long := cValToChar(oJsonObj["longitude"])
		oModelDAR:SetValue("DAR_LATITU",lat)
		oModelDAR:SetValue("DAR_LONGIT",long)
		oView:Refresh()
		oModel:lModify := .T.
		oView:lModify := .T.
	Else
		Help(,,'HELP',,"Não é possível alterar as coordenadas em modo de visualização.",1,0,)
	EndIf

Return

/*/-----------------------------------------------------------
{Protheus.doc} SetTPRToken()
@author Caio Murakami   
@since 15/09/2021
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function SetTPRToken()
Local oTPRNeolog	:= NIl 
Local lRet			:= .F. 
Local cToken        := "" 

oTPRNeolog:= TMSBCATPRNeolog():New() 
If oTPRNeolog:Auth() 
    lRet	:= .T. 
    cToken  := oTPRNeolog:GetAcessToken()
    oWebChannel:advplToJs("TPRsetToken" , cToken )
EndIf 

Return lRet


//-------------------------------------------------------------------
/*GerDARProc - Função de Envio dos dados de Geolocalização para a TPR
@author  Rafael Souza
@since   15/12/2021
@version 1.0      
*/
//------------------------------------------------------------------- 
Static Function GerDARProc(aListBox)
Local aGetArea	:= GetArea()
Local nI 		:= 0
Local cSigla	:= ""
Local cFilEnt   := ""
Local cEntida   := ""
Local cCodEnt   := ""
Local cEnd      := ""
Local cEst      := ""
Local cMun      := ""
Local cBairro   := ""
Local cCep      := ""
Local cIdent	:= ""
Local lRet		:= .T. 
Local cIdGeo	:= ""
Local aEndGeo	:= {}
Local aCargaIni := {}
Local cError 	:= ""
Local cResult 	:= ""
Local cJson 	:= ""
Local nCount    := 0 

Private oDadosGeo	:= NIL

Default aListBox := {}

aCargaIni := TMO15Rot(aListBox)

If FindFunction( 'TMSROTEIRI') 
	cRoteiri:= TMSROTEIRI()   //Verifica o Roteirizador
    If cRoteiri == "2"
        oDadosGeo:= TMSBCATPRNeolog():New()
        lRet:= oDadosGeo:Auth()
    EndIf
EndIf

If lRet
    For nI := 1 To Len(aCargaIni)

		dbSelectArea(aCargaIni[nI,3])
		dbGoTop()

		cIndAlias := CriaTrab( Nil, .F. )
		IndRegua((aCargaIni[nI,CRALIAS]), cIndAlias, IndexKey(), , aCargaIni[nI,CRFILTRO],"Selecionando Registros", .F.) //--"Selecionando Registros..."

		nIndAlias := RetIndex(aCargaIni[nI,3])+1
		DbSetOrder( nIndAlias + 1 )
		ProcRegua( (aCargaIni[nI,3])->( LastRec() ) )  
		nCount := 0
		While .T. 

			//-- Verifica se é final de arquivo ou o limite de envio para integrar com TPR
			If (aCargaIni[nI,3])->(Eof()) .Or. nCount == 50
				Begin Sequence 
					cIdGeo := GetSxENum("DMR","DMR_IDROT")
					oDadosGeo:SetRoutId(cFilAnt + cIdGeo)
					lRet:= oDadosGeo:PostGeoLoc()

					If !lRet 
						RollBackSX8()
						oDadosGeo:ShowError()
						cJson	:= oDadosGeo:GetJsonEnv()
						cError  := oDadosGeo:GetError() 
					Else 
						ConfirmSX8()
						cResult := oDadosGeo:GetResult()
						cJson	:= oDadosGeo:GetJsonEnv()
					EndIf 

					If lRet //-->Grava DMR / DMS / DLU 
						T146GrvRot( cIdGeo , aEndGeo ,cJson , cResult , cError)
					EndIf 
					nCount := 0 //Restaura o valor inicial de ncount para novo envio.
				End Sequence 

				//---- Limpa Objeto da integração
				FwFreeObj(oDadosGeo)    
				FwFreeArray(aEndGeo)
				oDadosGeo:= Nil
				aEndGeo := {} 

				//-- Se for final de arquivo, sai do Laço de repetição.
				If (aCargaIni[nI,3])->(Eof())
					Exit
				EndIf
			EndIf //-- Final de arquivo ou Limite de envio

			ncount ++  
			
			If oDadosGeo == Nil 
				oDadosGeo:= TMSBCATPRNeolog():New()	
				oDadosGeo:Auth()
			EndIf 

			If aCargaIni[nI,3] == "SA1"
				cFilEnt:= SA1->A1_FILIAL
				cEntida:= "SA1"
				cCodEnt:= SA1->A1_COD+SA1->A1_LOJA
				cEnd   := SA1->A1_END
				cEst   := SA1->A1_EST
				cMun   := SA1->A1_MUN
				cBairro:= SA1->A1_BAIRRO
				cCep   := SA1->A1_CEP
				cSigla := Posicione('SYA',1,xFilial('SYA')+SA1->A1_PAIS,'YA_SIGLA')
				
			ElseIf aCargaIni[nI,3] == "DUE"
				cFilEnt:= DUE->DUE_FILIAL
				cEntida:= "DUE"
				cCodEnt:= DUE->DUE_CODSOL
				cEnd   := DUE->DUE_END
				cEst   := DUE->DUE_EST
				cMun   := DUE->DUE_MUN
				cBairro:= DUE->DUE_BAIRRO
				cCep   := DUE->DUE_CEP
			ElseIf aCargaIni[nI,3] == "DUL"
				cFilEnt:= DUL->DUL_FILIAL
				cEntida:= "DUL"
				cCodEnt:= DUL->DUL_SEQEND
				cEnd   := DUL->DUL_END
				cEst   := DUL->DUL_EST
				cMun   := DUL->DUL_MUN
				cBairro:= DUL->DUL_BAIRRO
				cCep   := DUL->DUL_CEP
			EndIf

			//--Chama o método de endereço
			cIdent     := cFilEnt+cEntida+cCodEnt
			Aadd(aEndGeo,{cEntida,cIdent,nIndAlias} )
			oDadosGeo:AddAddress( cIdent, Iif(Empty(cSigla) .Or. AllTrim(cSigla)== "*","BRA",cSigla) , cEst, cMun, cCep, cEnd )	
			
			(aCargaIni[nI,3])->(dbSkip())
		EndDo 
		
		If	File( cIndAlias + OrdBagExt() )
			DbSelectArea((aCargaIni[nI,3]))
			DbClearFilter()
			Ferase( cIndAlias + OrdBagExt() )
		EndIf

	RetIndex((aCargaIni[nI,3]))	
		
    Next nI
EndIf

If lRet
    MsgInfo("Dados enviados para o Planejamento de Rotas (TPR) com sucesso!") //"Dados enviados para o Planejamento de Rotas (TPR) com sucesso!"
Else
	Help('',1,'TMSA14652') //Integração não realizada. 
EndIf 

RestArea(aGetArea)
FwFreeArray(aEndGeo)
Return lRet 


//-----------------------------------------------------
/*/ TMSAO15CGI - Tela Carga Inicial Geolocalização - TPR 
@author Rafael 
@version P12
@since 21/12/2021
/*/
//------------------------------------------------------
Function TMSAO15CGI()
Local aSize     := {}
Local aObjects  := {}
Local aListBox  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local oOk       := LoadBitMap(GetResources(),"LBOK")
Local oNo       := LoadBitMap(GetResources(),"LBNO")
Local oBtn01
Local oBtn02
Local nPosi := 20

Private oVerde		:= LoadBitmap( GetResources()	,	'BR_VERDE'		)
Private oAmarelo	:= LoadBitmap( GetResources()	,	'BR_AMARELO'	)
Private oListBox	:= Nil
Private oDlg		:= Nil
Private oQtdDoc		:= Nil
Private oQtdMrk		:= Nil
Private nQtdDoc		:= 0
Private nQtdMrk		:= 0
Private lExecAuto	:= .F.

//-- Checkbox
Private lAllMark:= .F.   // Usado para o controle da marca de todos os documentos
//-- Rotinas Marcadas
Private aRotMark:= {}

CursorWait()

//-- Array com as tabelas a serem integradas TMS x TPR
Aadd(aListBox,{'2', oVerde, 'SA1',"Cadastro de Clientes" ,'CRMA980','CRMA980_SA1', NIL }) //Cadastro de Clientes
Aadd(aListBox,{'2', oVerde, 'DUE',"Cadastro de Solicitantes" ,'TMSA440','TMSA440_DUE', NIL }) //Cadastro de Solicitantes
Aadd(aListBox,{'2', oVerde, 'DUL',"Cadastro de Endereços Solicitantes" ,'TMSA450','TMSA450_DUL', NIL }) //Cadastro de Endereços Solicitantes

CursorArrow()

aSize    := MsAdvSize(.F. )
aObjects := {}

AAdd( aObjects, { 100, 020, .T., .F., .T.  } )
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 020, .F., .F. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3, .T.  }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE STR0011 + "-" + STR0008 From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL //"Carga de Dados - Geocode"

	oPanel := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[1,3]), (aPosObj[1,4]), .T.,.T.)

	@ 005,005 CHECKBOX oAllMark VAR lAllMark PROMPT STR0024 SIZE 168, 08; //-- Marca/Desmarca Todos
	ON CLICK(TMSAO15All(aListBox)) OF oPanel PIXEL

	//-- Cabecalho dos campos do Monitor.
	@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields HEADER;
		"","",STR0025,STR0026, STR0027 SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL

	oListBox:SetArray( aListBox )
	oListBox:bLDblClick := { || TMSAO15Mrk(aListBox) }
	oListBox:bLine      := { || {	Iif(aListBox[ oListBox:nAT,CRMARCA ] == '1',oOk,oNo),;
											aListBox[ oListBox:nAT,CRCORBRW],;
											aListBox[ oListBox:nAT,CRALIAS ],;
											aListBox[ oListBox:nAT,CRROTINA],;
											aListBox[ oListBox:nAT,CRNOME  ]}}

	//-- Botoes da tela do monitor.
	@ aPosObj[3,1],aPosObj[3,4] - 100 BUTTON oBtn01 PROMPT STR0015 ACTION TMSAO15Leg() OF oDlg PIXEL SIZE 035,011 //-- "Legenda"
	@ aPosObj[3,1],aPosObj[3,4] - 060 BUTTON oBtn02 PROMPT STR0016 ACTION Iif(MsgYesNo(STR0019,STR0011),; //--"Confirma o Processamento",Carga Inicial
		Processa( { || GerDARProc(aListBox) }, , STR0017, .T. ),'') OF oDlg PIXEL SIZE 035,011 //"Transmitindo para TPR"
	@ aPosObj[3,1],aPosObj[3,4] - 020 BUTTON oBtn03 PROMPT STR0018 ACTION TMSAO15Fil(@aListBox) OF oDlg PIXEL SIZE 035,011 //-- "Filtro"

	
	@ aPosObj[3,1],aPosObj[3,4] + nPosi BUTTON oBtn05 PROMPT STR0020 ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //-- "Sair"

ACTIVATE MSDIALOG oDlg CENTERED

Return ( Nil )


//-----------------------------------------------------
/*/ TMSAO15All - Marcar / Desmarcar Todos  
@author Rafael
@version P12
@since 16/12/2021
/*/
//------------------------------------------------------
Static Function TMSAO15All(aListBox)
Local nI      := 0
Local lRefresh:= .T.
Local lUmItem := .F.

CursorWait()
nQtdMrk := 0

For nI := 1 To Len(aListBox)
	TMSAO15Mrk(aListBox,nI,lRefresh,lUmItem)
Next nI

CursorArrow()

oListBox:Refresh()

Return Nil

//-----------------------------------------------------
/*/ TMSAO15Mrk - Marcar / Desmarcar  
@author Rafael 
@version P12
@since 16/12/2021
/*/
//------------------------------------------------------
Static Function TMSAO15Mrk(aListBox,nItem,lRefresh,lUmItem,lRetMark)
Local nPosMrk := 0

Default nItem   := oListBox:nAt
Default lRefresh:= .T.
Default lUmItem := .T.
Default lRetMark:= .F.

If lUmItem
	aListBox[nItem,CRMARCA] := Iif(aListBox[nItem,CRMARCA] == '1','2','1')
	If(aListBox[nItem,CRMARCA]) == '1'
		nQtdMrk += 1
	ElseIf(aListBox[nItem,CRMARCA]) == '2'
		nQtdMrk -= 1
	EndIf
Else
	If lAllMark
		aListBox[nItem,CRMARCA] := '1'
		nQtdMrk += 1
	Else
		aListBox[nItem,CRMARCA] := '2'
		nQtdMrk := 0
	EndIf
EndIf
nPosMrk := Ascan(aRotMark,{ | e | e[1]+e[2] == aListBox[nItem,CRALIAS]+aListBox[nItem,CRROTINA] })
If nPosMrk == 0
	Aadd(aRotMark,{ aListBox[nItem,CRROTINA], aListBox[nItem,CRALIAS], '' })
	nPosMrk := Len(aRotMark)
EndIf
aRotMark[nPosMrk,3] := aListBox[nItem,CRMARCA]
If lRefresh
	oListBox:Refresh()
EndIf

Return Nil

//-----------------------------------------------------
/*/ TMSAO15Fil - Filtro das tabelas   
@author Rafael
@version P12
@since 16/12/2021
/*/
//------------------------------------------------------
Static Function TMSAO15Fil(aListBox)
Default aListBox := {}

aListBox[oListBox:nAT,CRFILTRO] := BuildExpr( aListBox[ oListBox:nAT,CRALIAS ], ,aListBox[oListBox:nAT,CRFILTRO])

If !Empty(aListBox[oListBox:nAT,CRFILTRO] )
	aListBox[ oListBox:nAT,CRCORBRW] := oAmarelo
	oListBox:Refresh()
Else
	aListBox[ oListBox:nAT,CRCORBRW] := oVerde
	oListBox:Refresh()
EndIf

Return ( Nil )

//-----------------------------------------------------
/*/ TMSAO15Leg - Legenda do filtro da rotina 
@author TOTVS
@version P12
@since 16/12/2021
/*/
//------------------------------------------------------
Static Function TMSAO15Leg()

BrwLegenda( STR0023	, STR0018,;		//-- Filtro
			{{'BR_AMARELO' 	, STR0021 },;  	//-- Filtrado
			{'BR_VERDE'    	, STR0022 }})  //-- Sem Filtro

Return Nil

//-----------------------------------------------------
/*/ TMO15Rot - Preparar rotinas para processamento
@author Rafael
@version P12
@since 16/12/2021
/*/
//------------------------------------------------------
Static Function TMO15Rot(aListBox)
Local   nI         	:= 0
Local   aRotProc	:= {}

For nI := 1 To Len(aListBox)
	If aListBox[nI,1] == '1'
		Aadd(aRotProc, {aListBox[nI,1],aListBox[nI,2],aListBox[nI][3],aListBox[nI][4], aListBox[nI][5], aListBox[nI][6], aListBox[nI][7]} )
	EndIf
Next nI

Return ( aRotProc )

//---------------------------------------------------------------------
/*/ T15PrcGeo - Processa o retorno da Geolocalização Assincrona da TPR
@author Rafael Souza
@version P12
@since 27/12/2021
/*/
//---------------------------------------------------------------------
Function T15PrcGeo(cIdRot, aGeoLoc)
Local lRet 		:= .T. 
Local nI 		:= 0
Local cFilEnt   := ""
Local cEntida   := ""
Local cCodEnt   := ""
Local nTamFil    := TamSx3("DAR_FILIAL")[1]
Local nTamEnt    := TamSx3("DAR_ENTIDA")[1]

Default cIdRot 	:= ""
Default aGeoLoc := {}

For nI := 1 To Len(aGeoLoc)    
              
	cFilEnt:= SubStr(aGeoloc[nI]:IDENTIFIER, 1        , nTamFil)
	cEntida:= SubStr(aGeoloc[nI]:IDENTIFIER, nTamFil+1, nTamEnt)
	cCodEnt:= SubStr(aGeoloc[nI]:IDENTIFIER, nTamFil+nTamEnt+1)

	lRet:= TMSROT015(cFilEnt,cEntida,cCodEnt,aGeoLoc[nI]:LATITUDE,aGeoLoc[nI]:LONGITUDE) 

	If lRet    
        TmsLogMsg("INFO","Geolocalização processada com sucesso'") 
	//--Atualiza DMS 
		DMS->(DbSetOrder(4))  
        If DMS->(DbSeek(xFilial("DMS")+cIdRot+aGeoloc[nI]:IDENTIFIER))
            Reclock("DMS",.F.)
			DMS->DMS_ENTEXT:= 'DAR'
			DMS->DMS_STATUS:= '3'
			DMS->(MsUnLock())
        EndIf	    
    Else
        TmsLogMsg("WARN","Falha no processamento da Geolocalização")   
    EndIf 

Next nI 

FwFreeArray(aGeoLoc)
Return lRet 
