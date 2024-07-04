#Include 'Protheus.ch'
#INCLUDE "rwmake.ch"       
#INCLUDE "WFC003.ch"     
#include "SIGAWF.CH"  
#include 'fileio.ch'

/******************************************************************************
	WFC008()
	CADASTRO DE FILAS DE ENVIO DE E-MAILS DO WORKFLOW
	Funcao principal do cadastro de filas de envio de email
******************************************************************************/
FUNCTION WFC008( cAlias, nReg, nOpcx )
	Local aColors	:= {} 
	
	default nOpcx 	:= 0
	default nOpcx 	:= WF_INICIO
    
    dbSelectArea("SX2")
    
    IF !( SX2->(dbSeek("WFQ")) )
    	alert(STR0069) //"Para utilizar esta funcionalidade, favor executar o update U_UPDWF002"
    	Return 
    EndIf 

	if nOpcx == WF_INICIO
		PRIVATE aRotina := MenuDef()
		PRIVATE cCadastro := STR0070 // "Cadastro de filas de Emails" 

		ChkFile("WFQ")
		DbSelectArea( "WFQ" )
		dbSetOrder( 1 )
		aColors := {}
		AAdd( aColors, { "WFQ_ATIVA","ENABLE" } )
		AAdd( aColors, { "!WFQ_ATIVA", "DISABLE" } )
		mBrowse( 6, 1, 22, 75, "WFQ",,,,,, aColors )
		WFQ->( DbCloseArea() )
	else
		do case
			case nOpcx == 6
				ConnectQueue(.T.,.F.)
			case nOpcx == 7
				ConnectQueue(.F.,.F.)
			case nOpcx == 8
			    ConnectQueue(.F.,.T.)
			otherwise
				ShowDlg( cAlias, nReg, nOpcx )
		endcase
	end
Return .T.

STATIC Function MenuDef()
	local aMenuDef := {}
	AAdd( aMenuDef,	{ STR0002,"AxPesqui", 0, WF_PESQUISAR } ) //"Pesquisar"
	AAdd( aMenuDef, { STR0003, "WFC008", 0, WF_VISUALIZAR } ) //"Visualizar"
	AAdd( aMenuDef,	{ STR0004, "WFC008", 0, WF_INCLUIR } ) //"Incluir"
	AAdd( aMenuDef, { STR0005, "WFC008", 0, WF_ALTERAR } ) //"Alterar"
	AAdd( aMenuDef, { STR0006, "WFC008", 0, WF_EXCLUIR, 3 } ) //"Excluir"
	AAdd( aMenuDef, { STR0071, "WFC008", 0, 6 } )  //"Configurar"
	AAdd( aMenuDef, { STR0072, "WFC008", 0, 7 } )  //"Ativar"
	AAdd( aMenuDef, { STR0073, "WFC008", 0, 8 } )  //"Desativar"
return aMenuDef


/******************************************************************************
	ShowDlg()
	Apresenta a janela de cadastro de contas de e-mail do workflow
******************************************************************************/
STATIC FUNCTION ShowDlg( cAlias, nReg, nOpcx )    
    Local cCaption	:= STR0070 //"Cadastro de filas de email"
    Local teste,EMP,FIL
	Local aFolders
	Local nFolder, nEnchoice
	Local oDlg, oFont, oGroup, oFolder                                                              
	Local cProtocol := WFGetProtocol()[2], cCaption

	PRIVATE aFields := Array( QUEUE_FLDCOUNT,2 )
	PRIVATE lInsertMode := .f., lViewMode := .f., lEditMode := .f., lDeleteMode := .f.
    
	ChkFile( "WFQ" )

	DbSelectArea( "WFQ" )

	do case
		case aRotina[nOpcx][4] == 2
			lViewMode := .T.
			cCaption := STR0074 //"Vizualizar Fila de Email"
		case aRotina[nOpcx][4] == 3
			lInsertMode := .T.
			cCaption := STR0075 //"Incluir Fila de Email"
		case aRotina[nOpcx][4] == 4
			lEditMode := .T.
			cCaption := STR0076 //"Alterar Fila de Email"
		case aRotina[nOpcx][4] == 5
			lDeleteMode	:= .T.
			lViewMode	:= .T.
			cCaption := STR0077 //"Excluir Fila de Email"
	endcase

   //	cCaption := FormatStr( cCaption + " " + cCadastro, AllTrim( WFQ_PASTA ) )

	while .t.
		nFolder := 1
		nEnchoice := 1
		aFolders := { STR0030 } //"Caixa de Correio"
         
		if lInsertMode
			aFields[ QUEUE_NAME       ,  2 ] := CriaVar( "WFQ_NOME",.t. )
			aFields[ QUEUE_HOSTNAME   ,  2 ] := CriaVar( "WFQ_HOST",.t. )
			aFields[ QUEUE_PORT       ,  2 ] := CriaVar( "WFQ_PORTA",.t. )
			aFields[ QUEUE_ROOTPATH   ,  2 ] := CriaVar( "WFQ_ROOT",.t. )
			aFields[ QUEUE_ENVIRONMENT,  2 ] := CriaVar( "WFQ_FENV" ,.t. )
   			aFields[ QUEUE_EMPRESA    ,  2 ] := CriaVar( "WFQ_FEMP",.t. )
   			aFields[ QUEUE_FILIAL     ,  2 ] := CriaVar( "WFQ_FFIL",.t. )
		else
			aFields[ QUEUE_NAME       ,  2 ]:= WFQ_NOME	
			aFields[ QUEUE_HOSTNAME   ,  2 ]:= WFQ_HOST
			aFields[ QUEUE_PORT       ,  2 ]:= WFQ_PORTA
			aFields[ QUEUE_ROOTPATH   ,  2 ]:= WFQ_ROOT	
			aFields[ QUEUE_ENVIRONMENT,  2 ]:= WFQ_FENV	
			aFields[ QUEUE_EMPRESA    ,  2 ]:= WFQ_FEMP
			aFields[ QUEUE_FILIAL     ,  2 ]:= WFQ_FFIL			 
        EndIf

		DEFINE MSDIALOG oDlg FROM 92,69 TO 400,750 TITLE cCaption PIXEL
		DEFINE FONT oFont NAME "Arial" SIZE 0, -14 BOLD
	
	   //	oFolder := TFolder():New( 15, 05, aFolders, aFolders, oDlg, nFolder,,,.T., .T., 240, 150 )
	
	   	@  40, 10 SAY STR0078 PIXEL OF oDlg //"Nome: "
		@  40, 35 MSGET	aFields[ QUEUE_NAME,1 ] VAR aFields[ QUEUE_NAME,2 ] PIXEL SIZE 165, 10 OF oDlg 
		
		@  60, 10 SAY STR0079 PIXEL OF oDlg //"Hostname: "
		@  60, 35 MSGET	aFields[ QUEUE_HOSTNAME,1 ] VAR aFields[ QUEUE_HOSTNAME,2 ] PIXEL SIZE 100, 10 OF oDlg   
		
		@  60, 140 SAY STR0080 PIXEL OF oDlg //"Porta: "
		@  60, 160 MSGET	aFields[ QUEUE_PORT,1 ] VAR aFields[ QUEUE_PORT,2 ] PICTURE "99999" PIXEL SIZE 40, 10 OF oDlg

		@  80, 10 SAY STR0081 PIXEL OF oDlg //"Ambiente:"
		@  80, 35 MSGET aFields[ QUEUE_ENVIRONMENT,1 ] VAR aFields[ QUEUE_ENVIRONMENT,2 ] PIXEL SIZE 100, 10 OF oDlg
		
		@  100,10 SAY STR0082 PIXEL OF oDlg //"Empresa: "
		@  100,35 MSGET	aFields[ QUEUE_EMPRESA,1 ] VAR aFields[ QUEUE_EMPRESA,2 ] PIXEL SIZE 25, 10 OF oDlg
		
		@  100, 90 SAY STR0083 PIXEL OF oDlg //"Filial: "
		@  100, 110 MSGET aFields[ QUEUE_FILIAL,1 ] VAR aFields[ QUEUE_FILIAL,2 ]  PIXEL SIZE 25, 10 OF oDlg
 
 		If ( lViewMode ) .or. ( lDeleteMode )
			aFields[ QUEUE_NAME,1 ]:SetDisable()
			aFields[ QUEUE_HOSTNAME,1   ]:SetDisable()
			aFields[ QUEUE_ENVIRONMENT,1  ]:SetDisable()
			aFields[ QUEUE_EMPRESA,1  ]:SetDisable()
			aFields[ QUEUE_FILIAL,1  ]:SetDisable()
		EndIf
		
		If ( lEditMode ) 
			aFields[ QUEUE_NAME,1 ]:SetDisable()
		EndIf

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg, {|| nEnchoice := BtnOk( oDlg ) }, {|| nEnchoice := 1, oDlg:End() } )
	
		If nEnchoice == 1
			exit
		EndIf
    end

return NIL

STATIC FUNCTION BtnOk( oDlg )
	local lResult := .t.
	local nResult := 0

	If ( lInsertMode .or. lEditMode )
		if lInsertMode
			lResult := ExistChav( "WFQ", aFields[ QUEUE_NAME,2 ] )
		end
		if lResult
			lResult := SaveData()
		end
	elseif lDeleteMode
		lResult := DeleteData()
	end
	
   //	if lResult
	
		if !lInsertMode
			nResult := 1
		end
		
	oDlg:End()
  //	end

Return nResult

/******************************************************************************
	DeleteData()
	Abre uma janela de confirmacao de EXCLUSAO da caixa de correio atualmente
	apresentado na janela de cadastro atraves do botao OK.
******************************************************************************/
STATIC FUNCTION DeleteData()
	local lResult
	local cMsg := FormatStr( STR0084, AllTrim( WFQ->WFQ_NOME ) ) //"Deseja realmente excluir a fila "
	DbSelectArea( "WFQ" )
	if ( lResult := MsgYesNo( cMsg, STR0085 ) ) //"Excluir Fila de Email"
		if Reclock("WFQ")
			DbDelete()
			MsUnlock()
		end
	end
Return lResult                                                                                                

/******************************************************************************
	SaveData()
	Grava as informacoes apos a verificacao da validacao dos dados.
******************************************************************************/
STATIC FUNCTION SaveData()
		DbSelectArea( "WFQ" )
		if RecLock("WFQ", lInsertMode )
			WFQ_FILIAL  := xFilial( "WFQ" )
			WFQ_NOME  := aFields[ QUEUE_NAME, 2 ]			// Nome
			WFQ_HOST  := aFields[ QUEUE_HOSTNAME, 2 ]		// Hostname
			WFQ_ROOT  := GetSrvProfString("ROOTPATH","")  	// RootPath			
			WFQ_PORTA := aFields[ QUEUE_PORT, 2 ]			// Porta
			WFQ_EMAIL := rtrim(WFGetMV("MV_WFMLBOX",""))	// Email
			WFQ_FENV  := aFields[ QUEUE_ENVIRONMENT, 2 ] 	// Ambiente
			WFQ_FEMP  := rTrim(aFields[ QUEUE_EMPRESA, 2 ])	// Empresa
			WFQ_FFIL  := aFields[ QUEUE_FILIAL, 2 ] 		// Filial					
			MsUnlock()
		EndIf
Return .T.   

Static Function ConnectQueue(lConfigure,lTurnOff)
	Local lReturn:=.F.
	Local oRpcConnection := NIL    
	Local cMailBox:=""
	Local cServerIni := GetAdv97()
	
	Default lConfigure:=.T.    
	Default lTurnOff:= .F.
	
	
	if !(lTurnOff )
	    DbSelectArea( "WFQ" )
			
		oRpcConnection:= TRPC():New(alltrim(WFQ_FENV))   	
	   
	    if(oRpcConnection:Connect( alltrim(WFQ_HOST), nBIval(WFQ_PORTA)) )
		   lReturn:=.T.  
	  
		   MsgInfo(STR0086) //"Servidor da Fila de email está ativo!"
		   
		    if(lConfigure)  
   			   	oRpcConnection:CallProc("WFPrepEnv",rTrim(WFQ_FEMP),alltrim(WFQ_FFIL))      
		       	cMailBox:= alltrim(oRpcConnection:CallProc("WFGetMV","MV_WFMLBOX","")) 
			   
			   	if(cMailBox=="")
	   			   lReturn:=.F.
	 			   alert(STR0087) //"Fila não possui conta de email do workflow ativa!!"
	 			Else                                                                       
		           oRpcConnection:CallProc("WritePProString","QueueSendMail", "Environment", allTrim(WFQ_FENV),GetADV97()) 
		           oRpcConnection:CallProc("WritePProString","QueueSendMail", "Main", "QueueSendMail" ,GetADV97()) 
		           oRpcConnection:CallProc("WritePProString","QueueSendMail", "nParms", "3",GetADV97()) 
				   oRpcConnection:CallProc("WritePProString","QueueSendMail", "parm1", rTrim(WFQ_FEMP),GetADV97()) 
				   oRpcConnection:CallProc("WritePProString","QueueSendMail", "parm2", alltrim(WFQ_FFIL),GetADV97()) 
	   			   oRpcConnection:CallProc("WritePProString","QueueSendMail", "parm3", alltrim(WFQ_NOME),GetADV97())
	   			   oRpcConnection:CallProc("WritePProString","QueueManagerInfo", "Hostname", GetComputerName() ,GetADV97())         
	   			   oRpcConnection:CallProc("WritePProString","QueueManagerInfo", "Port", GetPvProfString("TCP", "Port","", cServerIni),GetADV97())                               
	   			   oRpcConnection:CallProc("WritePProString","QueueManagerInfo", "Environment",  GetEnvServer() ,GetADV97())    			      			   
	  			   oRpcConnection:CallProc("WritePProString","QueueManagerInfo", "Emp",  cEmpAnt ,GetADV97())    			      			   
	   			   oRpcConnection:CallProc("WritePProString","QueueManagerInfo", "fil",  cFilAnt ,GetADV97())    			      			    	   			   
	   			   	   				   
			       MsgInfo(STR0088) //"Fila de envio de email configurada. Adicione o Job QueueSendMail na seção [ONSTART] no arquivo de configuração da fila antes de sua utilização."
				EndIf
			EndIf
	         	        
		    oRpcConnection:Disconnect()       
		Else  
			alert(STR0089) //"Não foi possível estabelecer conexão. Verifique se o Hostname e a porta estão corretos e certifique de que o servidor da fila esteja disponível."
		EndIf       
	Else
	     msgInfo(STR0090) //"A fila foi desativada."
	EndIf	
	 
	if RecLock("WFQ")   
	   WFQ_ATIVA:= lReturn 
	endif 
	
	MsUnlock() 
	dbCloseArea()	 
	
Return lReturn