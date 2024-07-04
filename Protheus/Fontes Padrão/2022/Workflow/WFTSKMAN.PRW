#INCLUDE "COLORS.CH"
#INCLUDE "SIGAWF.CH"
#INCLUDE "WFTSKMAN.CH"	

Static __oWFTaskMan := nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWF_MSGSTT บAutor  ณB.I. TEAM			 บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de abertura do messenger, executada na inicializacao บฑฑ
ฑฑบ          ณdo Protheus Remote, caso o parametro MV_MSSINT seja True    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso         ณMP912                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function WF_MSGSTT() 
	local lJob 		:= IsBlind()
	local lTelnet 	:= IsTelnet()	 
		
	If (WFGetMV("MV_MSSINT",.F.)) .And. !(lJob) .And. !(lTelnet)
		//WFDTaskRmt()
		WFATaskRmt()              
	endif

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWFDTaskRmtบAutor  ณB.I. TEAM			 บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de que finaliza a rotina do messenger. (OBSOLETA)    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMP912                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function WFATaskRmt()
	If setMDIChild(0)
		PtRunInSession("MAIN_THREAD","WFATaskRmt()")
	Else
		WFTaskRmt(.T.)
	endIf
return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWF_MSGSTT บAutor  ณB.I. TEAM			 บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de abertura do messenger, quando o mesmo eh executadoบฑฑ
ฑฑบ          ณa partir do menu xnu do Protheus Remote. 				      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMP912                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function WFDTaskRmt()

	If setMDIChild(0)
		PtRunInSession("MAIN_THREAD","WFDTaskRmt()")
	Else	
		if __oWFTaskMan <> nil 
			__oWFTaskMan := nil
		endIf
	endIf
return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWFTaskRmt บAutor  ณB.I. TEAM			 บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInstancia o objeto do menu inicial da rotina Messenger e    บฑฑ
ฑฑบ          ณexibe a tela caso o parametro de entrada seja True 	      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMP912                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static function WFTaskRmt(lActive)
Local oTaskMan 	:= Nil
Local cHostN	:= ""
Local cServN	:= ""
Local aKillId	:= {}
Local nX		:= 0
Local lContinua := .T.

//-----------------------------------------------------------------
// Verifica se a thread do messenger esta rodando. Se sim, entao mata e recria.
//-----------------------------------------------------------------	
if __oWFTaskMan <> nil

	CursorWait()

	//-----------------------------------------------------------------
	// Se a rotina esta sendo exibida, entao nao faz nada 
	//-----------------------------------------------------------------
	if !WFInDsp()	
		cHostN	:= UPPER(__oWFTaskMan:cHostName)
		cServN	:= UPPER(__oWFTaskMan:cServerN)
		aKillId := WFGetTrIds()	
		__oWFTaskMan := nil
		
		For nX := 1 To Len(aKillId)
			KillUser( aKillId[nX,1], cHostN, aKillId[nX,2], cServN )
			Sleep( 1000 )
		Next nX		
	else	
		//Nao recria, pois ja esta sendo exibido
		lContinua := .F.
	endif
	CursorArrow()	
else	
	ControlFile(.F.)
endif

//Recria
if lContinua
	oTaskMan := WFTskManObj({cEmpAnt,cFilAnt})
	oTaskMan:ActiveRmt(.T.)	
endif

return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWFGetTrIdsบAutor  ณB.I. TEAM           บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna as IDs das threads que estao executando esta rotina บฑฑ
ฑฑบ          ณnesta estacao                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMP912                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function WFGetTrIds()
Local aRet 	:= {}
Local nX	:= 0
Local aTrhds:= GetUserInfoArray()

For nX := 1 to len(aTrhds)
	if (alltrim(upper(aTrhds[nX,02])) == alltrim(upper(__oWFTaskMan:cHostName))) .and. alltrim(upper(aTrhds[nX,05])) == "WFTASKUSER"
		aAdd(aRet,{aTrhds[nX,01],aTrhds[nX,03]})			
	endif
Next nX
	
Return aRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWFTskManObjบAutor ณB.I. TEAM           บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega o objeto do menu principal do messenger caso este   บฑฑ
ฑฑบ          ณainda nao tenha sido inicializado anterioremente. Valida    บฑฑ
ฑฑบ          ณatraves da variavel estatica __oWFTaskMan.				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMP912                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
function WFTskManObj(aParams)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRealiza o ajuste do dicionario de dados.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarrega o objeto caso o mesmo ainda nao tenha sido inicializadoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	if __oWFTaskMan == nil
		__oWFTaskMan := TWFTaskMan():New(aParams)
	end
return __oWFTaskMan

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWFTaskUserบAutor  ณB.I. TEAM           บ Data ณ  xx/xx/xx   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInstancia a classe do "menu principal" do Messenger na variaบฑฑ
ฑฑบ          ณvel estatica 												  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMP912                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
function WFTaskUser(cParams)
	Local aParams
	
	if cParams == nil
		return
	end

	Private cUsuario := ""
	Private __cUserID := ""
	Private oMainWnd
	PRIVATE __oTaskMan  

	aParams := WFTokenChar( cParams, "|" )
	
	aParams[2] :=  StrTran(	aParams[2],'*',' ')
	
	RPCSETTYPE( WF_RPCSETTYPE )
	WFPREPENV( aParams[1], aParams[2], "WFTASKUSER" )
	ChkFile( "WF6" )

	__cUserID := aParams[ 3 ]
	PswOrder( 1 )
	PswSeek( __cUserID )
	cUsuario := __cUserID + PswRet(1)[1][2]

	if !( left( lower( getVersao() ),3 ) == "tot" )
		setTheme(getTheme(),.T.) // .T. = lActive
	endIf

	__oTaskMan:= WFTskManObj( { aParams[ 1 ], aParams[ 2 ] } )
	__oTaskMan:cUserFile := aParams[ 4 ]
	__oTaskMan:cLCKFile := aParams[ 5 ]	
	//__oTaskMan:lActiveRmt := .T.
	__oTaskMan:Execute(aParams[7])
return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse	 ณWFInDsp   บAutor  ณB.I. TEAM		   	 บ Data ณ  XX/XX/XX   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se arquivo de lock que controla o messenger existe บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10 - Messenger                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function WFInDsp()
Local lRet			:= .T.
Local cFileEnable 	:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine o path do arquivoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cFileEnable := AllTrim(Lower(GetTempPath()))	
cFileEnable += iif(Right(cFileEnable,1 ) <> "\","\","")
cFileEnable += "MessengerLock.lck"

lRet := File(cFileEnable)
	
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse	 ณTWFTaskManบAutor  ณB.I. TEAM		   	 บ Data ณ  XX/XX/XX   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria ou exclui o arquivo de lock que controla se o messengerบฑฑ
ฑฑบ          ณesta ou nao em execucao					          		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10 - Messenger                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ControlFile(lCreate)
Local cFileEnable 	:= ""
Local nTry 			:= 3
Local lRet			:= .F.
Local nX			:= 0
Local nHdl			:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine o path do arquivoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cFileEnable := AllTrim(Lower(GetTempPath()))	
cFileEnable += iif(Right(cFileEnable,1 ) <> "\","\","")
cFileEnable += "MessengerLock.lck"

CursorWait()
if lCreate
	if !File(cFileEnable)
		nHdl := FCreate(cFileEnable)
		FClose(nHdl)
	else
		lRet := .T.
	endif
else
	if File(cFileEnable)
		For nX := 1 to nTry
			lRet := FErase(cFileEnable) >= 0
			if lRet 
				exit
			endif
			Sleep(800)
		Next nX
	else
		lRet := .F.	
	endif
	
endif
CursorArrow()
	
Return lRet                                                                                     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse	 ณTWFTaskManบAutor  ณB.I. TEAM		   	 บ Data ณ  XX/XX/XX   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface grafica do Messenger 					          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10 - Messenger                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
class TWFTaskMan
	data oDlg
	data oBox
	data oTimer
	data hLCKFile
	data hUSRFile
	data cUserName
	data cUserMaster
	data cUserFile
	data cLCKFile
	data cUserID
	data cIdent
	data aGroups
	data lForceDlg
	data lOnStart
	data lActiveRmt
	data lRefresh
	data cMarca
	data lFechou
	data oSayWfl
	data oBtnWfl
	data oSayMsg
	data oBtnMsg
	data oFont
	data oBtnClose
	data lMessenger
	data cUserN
	data cHostName
	data cServerN 
	data nQdtNewMsg
		
	method New() CONSTRUCTOR
	method ActiveRmt(lActive)
	method Execute()
	method ChkNewTasks()
	method ShowMainDlg() 
	method ShowTskDlg( nOption )
	method BtnAction( nRow, nCol, cCaption, nBotton, nLeft, cAction, oDialog, lPixel )
	method RunTimer()
	Method CloseDlg()
	Method LoadLabel(nTipo)
	Method SetFont()
	Method EnableMess()
	Method PaintDlg()
	Method CountIten(nTipo)
	Method ReLoadSay()
	Method InExec()
	Method EndExec()
		
EndClass

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |New										บ
บAuthor:      |B.I. TEAM 	 							บ
บDate:        |xx/xx/xxxx  								บ
บDescription: |Metodo construtor da classe TWFTaskMan   บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
method New() class TWFTaskMan
	::lForceDlg := .f.
	::lRefresh := .f.
	::lOnStart := .t.
	::aGroups := {}
	::lActiveRmt := .f.
	::cUserName := AllTrim( Subs( cUsuario,7,15 ) )
	::cUserMaster := Subs( cUsuario,7,15 )
	::cUserFile := ""
	::cIdent := ""
	::lFechou := .F. // Inicia este atributo como true, quer dizer que o messenger estแ ativo.
	::SetFont()
	::EnableMess()
		
	//Variaveis para controle de re-execucao
	::cUserN		:= cUserName	
	::cHostName 	:= GetComputerName()
	::cServerN  	:= &("GetSrvInfo()[1]")
	
return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |ActiveRmt								บ
บAuthor:      |B.I. TEAM 	 							บ
บDate:        |19/01/10   								บ
บDescription: |Executa uma nova thread para o messenger บ
บ             |(Valida se o mesmo ja se encotra em exec)บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
method ActiveRmt(lActive) class TWFTaskMan
	Local cCommand      	:= ""
	Local cUserPath     	:= ""
	Local cActiveDriver	:= GetPvProfString( "DRIVERS", "ACTIVE", "TCP", GetRemoteIniName() )	
	Local aDriverOptions	:= {}
	Local cArquivo			:= 0
	Local cText := ""
	Local cTitle := ""

	Default lActive := .T.

	//------------------------------------------------------------
	// Tokeniza o driver recebido pela ','.
	//------------------------------------------------------------	
	aDriverOptions := aBIToken( cActiveDriver, ",", .F. )
	
	//------------------------------------------------------------
	// Caso o Driver recebido tenha mais de um valor, recebe o Driver Substituto.
	//------------------------------------------------------------
	If Len( aDriverOptions ) > 1
		cActiveDriver := GetPvProfString( "DRIVERS", "WFMSG", "TCP", GetRemoteIniName() )
	EndIf

	if lActive		
		//------------------------------------------------------------
		// Coleta o path da pasta de arquivos tempoarios do sistema operacional
		//------------------------------------------------------------
		cUserPath := AllTrim( Lower( GetTempPath() ) )		
		if Right(cUserPath,1 ) <> "\"
			cUserPath += "\"
		end
		
		//------------------------------------------------------------
		// Monta os paths dos arquivos do usuario e de lock
		//------------------------------------------------------------		
		::cUserFile := cUserPath
		::cUserFile += "wfmsg_"  
		::cUserFile += __cUserID
		::cUserFile += "_"
		::cUserFile += AllTrim( Str( Day( MsDate() ) + Month( MsDate() ) + Val( SubStr( Time(), 4, 2 ) + left( Time(), 2 ) ) ) )
		::cLCKFile  := ::cUserFile + ".lck"
		::cUserFile += ".ctl"
		
		//------------------------------------------------------------
		// Cria os arquivos caso nao existam
		//------------------------------------------------------------
		if !File(::cLCKFile)
			::hLCKFile := FCreate(::cLCKFile)
			FClose(::hLCKFile)
		Endif
		if !File(::cUserFile)
			::hUSRFile := FCreate(::cUserFile)
			FClose(::hUSRFile)
		endif

		//------------------------------------------------------------
		// Verifica se algum dos arquivos existem 
		//------------------------------------------------------------
		lActive := ::InExec()

		//------------------------------------------------------------
		// Se messenger nao esta ativo, entใo executa-o atrav้s de uma nova thread
		//------------------------------------------------------------
		if !lActive
			if ( GetRemoteType() <> 5 )
				//Coleta o caminho do smartclient.exe
				cCommand := GetRemoteIniName()
				If ( GetRemoteType() == 2 )
					cCommand := Subs( cCommand, At(':', cCommand)+1 )
					cCommand := Subs( cCommand, 1, Rat('/', cCommand) ) + 'smartclient '
				Else
					cCommand := Subs(cCommand, 1, Rat('\', cCommand) ) + 'smartclient.exe '
				EndIf
				
				cArquivo := cCommand

				//Monta a string de parametros
				cCommand += "-Q -P=WFTASKUSER -E=" 					//Funcao de PopUp
				cCommand +=	GetEnvServer() 							//Ambiente
				cCommand += " -C=" + cActiveDriver					//Tipo de Conexao e Parametros da rotina a ser executada
				cCommand += " -A=" + cEmpAnt + "|" + StrTran (cFilAnt,' ','*') + "|"	//Empresa e Filial
				cCommand += AllTrim( __cUserID ) + "|"  			//Usuario corrente
				cCommand += ::cUserFile + "|"						//Nome do arquivo de controle do usuario
				cCommand += ::cLCKFile 	 + "|"						//Nome do arquivo de controle de semaforo
				cCommand += __cUserId + "|"							//Id Usuario     
				cCommand += cBIStr(WFGetMV("MV_WFMESSE",.F.))		//VerSenha -> Respeita parโmetro MV_WFMESSE 				
				cCommand += " -M"  									//Multiplas Instancias

				//Executa a nova thread
				//https://tdn.totvs.com/display/tec/ShellExecute
				If ShellExecute("Open",cArquivo,cCommand,"",1) > 32
					::lActiveRmt := .F.
					__oWFTaskMan:lActiveRmt := .F.
					ControlFile(.F.)
				else
					::lActiveRmt := .T.
					__oWFTaskMan:lActiveRmt := .T.
					ControlFile(.T.)
				endif
			else
				cTitle := "SmartClient HTML/WEBAPP"
				cText := "Op็ใo nao disponivel para ser executada via Browse !" 
			
				MsgAlert(cText, cTitle)
				::lActiveRmt := .F.
				__oWFTaskMan:lActiveRmt := .F.
				ControlFile(.F.)
			endif	
		else
			//Se esta ativo, verifica se existe arquivo de lock. Se sim, entao apaga-o
			if WFInDsp()
				ControlFile(.F.)
				WFTaskRmt(.T.)			
			endif			
		endif
	endif

return self

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |InExec									บ
บAuthor:      |Cesar A. Bianchi							บ
บDate:        |19/01/10   								บ
บDescription: |Verifica se esta rotina esta em execucao บ
บ             |por em alguma thread, atraves da chave 	บ
บ             |rotina+user+hostname                     บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method InExec() class TWFTaskMan
Local lRet 		:= .F.
Local nX		:= 1
Local aThreads	:= GetUserInfoArray()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ LAYOUT DE aTHREADS ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
aThreads[x][01] = (C) Nome de usuario
aThreads[x][02] = (C) Nome da maquina local
aThreads[x][03] = (N) ID da Thread
aThreads[x][04] = (C) Servidor (caso esteja usando Balance; caso contrario eh vazio)
aThreads[x][05] = (C) Nome da funcao que esta sendo executada
aThreads[x][06] = (C) Ambiente(Environment) que esta sendo executado
aThreads[x][07] = (C) Data e hora da conexใo
aThreads[x][08] = (C) Tempo em que a thread estแ ativa (formato hh:mm:ss)
aThreads[x][09] = (N) Numero de instrucoes
aThreads[x][10] = (N) Numero de instrucoes por segundo
aThreads[x][11] = (C) Observacoes
aThreads[x][12] = (N) (*) Memoria consumida pelo processo atual, em bytes
aThreads[x][13] = (C) (**) SID - ID do processo em uso no TOPConnect/TOTVSDBAccess, caso utilizado.
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVarre o array, verificando se esta rotina esta em execucao nesta estacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CursorWait()
For nX := 1 to len(aThreads)
    if alltrim(upper(aThreads[nX,2]	)) == alltrim(upper(::cHostName)) .and. alltrim(upper(aThreads[nX,5])) == "WFTASKUSER"
		lRet := .T.
		exit		
    endif
Next nX

CursorArrow()	
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |Execute									บ
บAuthor:      |B.I. TEAM 								บ
บDate:        |xx/xx/xxxx  								บ
บDescription: |											บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
method Execute(cShowMsg) class TWFTaskMan
	Local nC
	Local cKey := xFilial( "WF6" ) + Upper( Left( ::cUserName + Space( 15 ),15 ) )
	Local aGrps, aGrp
	Local lReload := .T.
	
	//--------------------------------------------------------
	// Obtem os nomes de grupos.
	//--------------------------------------------------------
	aGrps := WFTokenChar( AllTrim( WFGetMV( "MV_WF6GRPS", "" ) ), ";" )
	AAdd( ::aGroups, { "00001", STR0002, "WFTaskWF", 0 } )	
    
	//--------------------------------------------------------
	// O botao mensagens so sera exibido se o usuario tiver permissใo [MV_WFMESSE + VerSenha(130)]
	//--------------------------------------------------------	
	If (cShowMsg == "T")	
		AAdd( ::aGroups, { "00002", STR0001, "WFTaskMsg", 0 } )
	EndIf	
	                   
	For nC := 1 to Len(aGrps)
		while Len( aGrp := WFTokenChar( aGrps[ nC ], ":" ) ) < 3
			AAdd( aGrp, "" )
		end
		aGrp[ 1 ] := Left( aGrp[ 1 ] + Space( 5 ),5 )
		aGrp[ 2 ] := AllTrim( aGrp[ 2 ] )
		aGrp[ 3 ] := AllTrim( aGrp[ 3 ] )
		if At( "(", aGrp[ 3 ] ) > 0
			aGrp[ 3 ] := Left( aGrp[ 3 ], At( "(", aGrp[ 3 ] ) -1 )
		end
		AAdd( ::aGroups, { aGrp[ 1 ], aGrp[ 2 ], aGrp[ 3 ], 0 } )
	next

	//--------------------------------------------------------
	// Rotina em backgroud fica executando este la็o.
	//--------------------------------------------------------
	While !::lFechou	
		//--------------------------------------------------------
		// Verifica se tem novas mensagens
		// STATUS 1: Nao lida e nao alertado 
		//--------------------------------------------------------		
		If ::ChkNewTasks() > 0
			lReload := .T.
		Endif

		//--------------------------------------------------------
		// Grava todas os status 1 como 3 para nao voltar a alertar o usuario
		// STATUS 3: - Nao lida e jแ alertado                                
		//--------------------------------------------------------		
		dbSelectArea("WF6")
		WF6->(dbSetOrder(2))
		
		While WF6->(dbSeek(cKey+"1"))
			If RecLock("WF6",.F.)
				WF6->WF6_STATUS := "3"
				WF6->WF6_FLAG := ""
				WF6->(msUnlock("WF6"))
			EndIf
		EndDo

		//--------------------------------------------------------
		// Por fim, alerta o usuario (se novas lReload True).
		// Manter a chamada neste local, atrav้s do flag lReload.
		// por questao de refresh do Timer quando tela esta ativa.
		//--------------------------------------------------------
		if lReload
			lReload := .F.
			::ShowMainDlg()
		endif
		
		//--------------------------------------------------------
		// Pausa para proxima leitura.
		//--------------------------------------------------------
		Sleep(5000)
	EndDo

Return Self

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |EndExec									บ
บAuthor:      |Cesar A. Bianchi							บ
บDate:        |19/01/10   								บ
บDescription: |Finaliza a execucao do messenger, matandoบ
บ             |a thread refenrente caso usuario deseje.	บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method EndExec() class TWFTaskMan

	If !MsgYesNo( STR0013 ) // 'Deseja manter o monitoramento de novas mensagens ativo ?'
		//----------------------------------------------------
		//Apaga os arquivos criados.
		//----------------------------------------------------
		iif( File( ::cUserFile)	, FErase( ::cUserFile )	, Nil )
		iif( File( ::cLCKFile )	, FErase( ::cLCKFile )	, Nil )	
		
		//----------------------------------------------------
		// Coloca o atributo lFechou como true para finalizar a thread.
		//----------------------------------------------------
		::lFechou := .T.
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |ChkNewTasks								บ
บAuthor:      |B.I. TEAM 								บ
บDate:        |xx/xx/xxxx  								บ
บDescription: |Verifica se chegaram novas mensagens paraบ
บ             |o usuario 								บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method ChkNewTasks() class TWFTaskMan
	Local nC, nTasks := 0
	Local cKey := xFilial( "WF6" ) + Upper( Left( ::cUserName + Space( 15 ),15 ) )

	DbSelectArea( "WF6" )
	DbSetOrder( 1 )

	For nC := 1 to Len( ::aGroups )
		::aGroups[ nC,4 ] := 0
		
		if dbSeek( cKey + ::aGroups[ nC,1 ] + "1" ) 
			while !Eof() .and. ( WF6_FILIAL + WF6_PROPRI + WF6_GRUPO + WF6_STATUS ) == ( cKey + ::aGroups[ nC,1 ] + "1" )
				::aGroups[ nC,4 ]++
				nTasks++
				DbSkip()
			end
			if DbSeek( cKey + ::aGroups[ nC,1 ] + "3" )
				while !Eof() .and. ( WF6_FILIAL + WF6_PROPRI + WF6_GRUPO + WF6_STATUS ) == ( cKey + ::aGroups[ nC,1 ] + "3" )
					::aGroups[ nC,4 ]++
					nTasks++
					DbSkip()
				end
			end
		end
	Next

return nTasks

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |ShowMainDlg()							บ
บAuthor:      |Cesar A. Bianchi							บ
บDate:        |30/03/10   								บ
บDescription: |Apresenta a Dialog Principal 			บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method ShowMainDlg() class TWFTaskMan

	If ValType(::oDlg) != "O"
		//--------------------------------------------------------
		// Monta a tela.
		//--------------------------------------------------------
		::PaintDlg()
	endif
	
	//--------------------------------------------------------
	// Exibe a Tela.
	//--------------------------------------------------------
	ControlFile( .T. )
	::oTimer:Activate()
	::oDlg:Activate()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |CloseDlg									บ
บAuthor:      |Cesar A. Bianchi 						บ
บDate:        |30/03/10   								บ
บDescription: |Finaliza a Dialog Principal	 			บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method CloseDlg() class TWFTaskMan
	//--------------------------------------------------------
	// Finaliza os arquivos de controle do Messenger.
	//--------------------------------------------------------
	ControlFile(.F.)
	
	//--------------------------------------------------------
	// Se o Objeto de Timer estiver criado, o desativa.
	//--------------------------------------------------------
	If ( ValType(::oTimer) == "O" )
		::oTimer:DeActivate()
	EndIf 
	
	//--------------------------------------------------------
	// Finaliza o Dialog principal.
	//--------------------------------------------------------
	If ( ValType(::oDlg) == "O" )
		::oDlg:End()
	EndIf   

	::EndExec()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |ShowTskDlg								บ
บAuthor:      |Cesar A. Bianchi 						บ
บDate:        |30/03/10   								บ
บDescription: |Apresenta a Dialog com os itens 			บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
method ShowTskDlg( nOption ) class TWFTaskMan
	Local oTaskDlg
	
	default nOption := 0
	
	if nOption <> 0
		::lForceDlg := .t. 
	
		if ::oTimer <> NIL
			ProcessMessages()
			::oTimer:DeActivate()
		end
		
		oTaskDlg := WFTskManDlg():New( Self, nOption )
				
		if FindFunction( ::aGroups[ nOption,3 ] )
 			//Desativa os itens da dialog principal
			::oDlg:lActive := .F.
			::oDlg:Refresh()
			//Exibe a Dialog de Mensagens/Workflow
			oTaskDlg:Show()
			::ReLoadSay()
			//Reativa a Dialog principal
			::oDlg:lActive := .T.
			::oDlg:Refresh()
		end
	end
return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |RunTimer()								บ
บAuthor:      |B.I. TEAM								บ
บDate:        |01/01/01   								บ
บDescription: |Executa acoes quando o timer eh atingido บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method RunTimer() class TWFTaskMan
	Local cLastAlias := Alias()
	Local lRefresh := .f.
	Local cKey := xFilial( "WF6" ) + Upper( Left( ::cUserName + Space( 15 ),15 ) )

	if ::oTimer <> NIL
		ProcessMessages()
		::oTimer:DeActivate()
	end
 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe rotina esta sendo visualizada, verifica se chegaram novas mensagensณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	if WFInDsp()
		dbSelectArea("WF6")
		WF6->(dbSetOrder(2))
		
		dbSelectArea("WF6")
		WF6->(dbSetOrder(2))
		While WF6->(dbSeek(cKey+"1"))
			if RecLock("WF6",.F.)
				WF6->WF6_STATUS := "3"
				WF6->WF6_FLAG := ""
				WF6->(msUnlock("WF6"))
			endif
			lRefresh := .T.
			::lForceDlg := lRefresh
		EndDo
	endif
    
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe chegaram novas mensagens, fecha e reabre a dialog (refresh)ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	if lRefresh 
		//::oDlg:End()
		//::oTimer := NIL
		::ReLoadSay()
	end

	if ::oTimer <> NIL
		::oTimer:Activate()
		ProcessMessages()
	endif
	
	//Volta pro alias anterior ao disparo do timmer
	if !Empty(cLastAlias)
		dbSelectArea(cLastAlias)
	end
	
return self

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |LoadLabel()								บ
บAuthor:      |Cesar A. Bianchi							บ
บDate:        |30/03/10   								บ
บDescription: |Monta a Say "Itens Pendentes" 			บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method LoadLabel(nTipo) class TWFTaskMan
Local cRet := Replicate("*",20)
//nTipo = 1 -> Workflow
//nTipo = 2 -> Mensagens
cRet := STR0005 + AllTrim(Str(::CountIten(nTipo))) + STR0006

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |SetFont()								บ
บAuthor:      |Cesar A. Bianchi							บ
บDate:        |30/03/10   								บ
บDescription: |Define o estilo da fonte dos obj "Say" 	บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method SetFont() class TWFTaskMan
DEFINE FONT ::oFont NAME "Arial" SIZE 0, 14 BOLD
Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |EnableMess()								บ
บAuthor:      |Cesar A. Bianchi							บ
บDate:        |30/03/10   								บ
บDescription: |Valida o botao Mensagens esta disponivel บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method EnableMess() class TWFTaskMan
::lMessenger := getNewPar("MV_WFMESSE",.T.)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |PaintDlg()								บ
บAuthor:      |Cesar A. Bianchi							บ
บDate:        |30/03/10   								บ
บDescription: |Monta a tela "Gerenciador Mensagens" 	บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method PaintDlg() class TWFTaskMan

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o formulario principalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
::oDlg:= MSDIALOG():Create()
::oDlg:cName     		:= "oDlg"
::oDlg:cCaption  		:= STR0003  //Gerenciador de Tarefas
::oDlg:nLeft     		:= 0
::oDlg:nTop      		:= 0
::oDlg:nWidth    		:= 450
::oDlg:nHeight   		:= iif(::lMessenger,220,180)
::oDlg:lShowHint 		:= .F.
::oDlg:lCentered 		:= .T.    

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Box "Pendencias" ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
::oBox:= TGROUP():Create(::oDlg)
::oBox:cName 	   		:= "oBox"
::oBox:cCaption  		:= STR0004 //"Pendencias"
::oBox:nLeft 	   		:= 10
::oBox:nTop  	   		:= 10
::oBox:nWidth 			:= 420
::oBox:nHeight 			:= iif(::lMessenger,120,70)
::oBox:lShowHint  		:= .F.
::oBox:lReadOnly  		:= .F.
::oBox:Align      		:= 0
::oBox:lVisibleControl 	:= .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o botao WorkFlowณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
::oBtnWfl:=TButton():Create(::oDlg)
::oBtnWfl:cName 		:= "oBtnWfl"
::oBtnWfl:cCaption 		:= ::aGroups[1,2]
::oBtnWfl:nLeft 		:= 30
::oBtnWfl:nTop  		:= 30
::oBtnWfl:nWidth    	:= 120
::oBtnWfl:nHeight  		:= 35
::oBtnWfl:lShowHint 	:= .F.
::oBtnWfl:lReadOnly 	:= .F.
::oBtnWfl:Align 		:= 0
::oBtnWfl:bAction 		:= {||( ::ShowTskDlg(1))}  
::oBtnWfl:oFont			:= ::oFont

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o Say "Itens Pendentes" (WorkFlow)ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
::oSayWfl:= TSAY():Create(::oDlg)
::oSayWfl:cName				:= "oSayWfl"
::oSayWfl:cCaption 			:= ::LoadLabel(1) //Itens (x) pendentes
::oSayWfl:nLeft 			:= 170
::oSayWfl:nTop 				:= 40
::oSayWfl:nWidth 	   		:= 200        
::oSayWfl:nHeight 			:= 15
::oSayWfl:lShowHint 		:= .F.
::oSayWfl:lReadOnly 		:= .F.
::oSayWfl:Align 			:= 0
::oSayWfl:lVisibleControl	:= .T.
::oSayWfl:lWordWrap 	  	:= .F.
::oSayWfl:lTransparent 		:= .F.
::oSayWfl:oFont				:= ::oFont

if ::lMessenger
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta o botao "Mensagens"ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	::oBtnMsg:=TButton():Create(::oDlg)
	::oBtnMsg:cName 		:= "oBtnMsg"
	::oBtnMsg:cCaption 		:= ::aGroups[2,2]
	::oBtnMsg:nLeft 		:= 30
	::oBtnMsg:nTop  		:= 80
	::oBtnMsg:nWidth    	:= 120
	::oBtnMsg:nHeight  		:= 35
	::oBtnMsg:lShowHint 	:= .F.
	::oBtnMsg:lReadOnly 	:= .F.
	::oBtnMsg:Align 		:= 0
	::oBtnMsg:bAction 		:= {||( ::ShowTskDlg(2))}  
	::oBtnMsg:oFont			:= ::oFont	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta o Say "Itens Pendentes" (WorkFlow)ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	::oSayMsg:= TSAY():Create(::oDlg)
	::oSayMsg:cName				:= "oSayMsg"
	::oSayMsg:cCaption 			:= ::LoadLabel(2) //Itens (x) pendentes
	::oSayMsg:nLeft 			:= 170
	::oSayMsg:nTop 				:= 90
	::oSayMsg:nWidth 	   		:= 200
	::oSayMsg:nHeight 			:= 15
	::oSayMsg:lShowHint 		:= .F.
	::oSayMsg:lReadOnly 		:= .F.
	::oSayMsg:Align 			:= 0
	::oSayMsg:lVisibleControl	:= .T.
	::oSayMsg:lWordWrap 	  	:= .F.
	::oSayMsg:lTransparent 		:= .F.
	::oSayMsg:oFont				:= ::oFont
endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o botao "Fechar"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
::oBtnClose:=TButton():Create(::oDlg)
::oBtnClose:cName 			:= "oBtnClose"
::oBtnClose:cCaption 		:= STR0007
::oBtnClose:nLeft 			:= 310
::oBtnClose:nTop  			:= iif(::lMessenger,150,120)
::oBtnClose:nWidth  	  	:= 120
::oBtnClose:nHeight  		:= 30
::oBtnClose:lShowHint	 	:= .F.
::oBtnClose:lReadOnly 		:= .F.
::oBtnClose:Align 			:= 0
::oBtnClose:bAction 		:= {||( ::CloseDlg() )}  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria o timer de refreshณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
::oTimer := TTimer():New(5000, {|| ::RunTimer() }, ::oDlg )
  
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |CountItem()								บ
บAuthor:      |Cesar A. Bianchi							บ
บDate:        |30/03/10   								บ
บDescription: |Conta os itens pendentes de leitura  	บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method CountIten(nTipo) class TWFTaskMan
Local nTasks := 0
Local cKey := xFilial( "WF6" ) + Upper( Left( ::cUserName + Space( 15 ),15 ) )
	
dbSelectArea("WF6")
WF6->(dbSetOrder(1))

If nTipo == 1 //WorkFlow
	if WF6->(dbSeek(cKey))
		While !WF6->(Eof()) .and. (WF6->WF6_FILIAL + WF6->WF6_PROPRI ) == cKey
			if alltrim(WF6->WF6_PROPRI) $ alltrim(::cUserName) .and. (WF6->WF6_STATUS $ "13") .and. (WF6->WF6_GRUPO == '00001')
				nTasks ++ 
			endif
			WF6->(dbSkip())	
		EndDo
	endif

elseif nTipo == 2 //Mensagens
	if WF6->(dbSeek(cKey))
		While !WF6->(Eof()) .and. (WF6->WF6_FILIAL + WF6->WF6_PROPRI ) == cKey
			if upper(alltrim(WF6->WF6_PROPRI)) $ upper(alltrim(Self:cUserName)) .and. (WF6->WF6_STATUS $ "13") .and. (WF6->WF6_GRUPO == '00002')
				nTasks ++ 
			endif
			WF6->(dbSkip())	
		EndDo
	endif
endif

Return nTasks

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
บMethod:      |ReLoadSay()								บ
บAuthor:      |Cesar A. Bianchi							บ
บDate:        |30/03/10   								บ
บDescription: |Recarrega as legendas de itens pendentes	บ
บAplication:  |MP10 - Messenger							บ
บÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method ReLoadSay() class TWFTaskMan

::oSayWfl:cCaption	:= ::LoadLabel(1) //Itens (x) pendentes
::oSayWfl:Refresh()
if ::lMessenger
	::oSayMsg:cCaption	:= ::LoadLabel(2) //Itens (x) pendentes
	::oSayMsg:Refresh()
endif
	
::oDlg:Refresh()

Return

