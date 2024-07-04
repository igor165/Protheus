#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#define COL_GRID 5
Static objCENFUNLGP := CENFUNLGP():New()

/*/{Protheus.doc} PLSANONIMI
	(Tela de logs de anonimizacao de dados (LGPD))
	@type  Function
	@author David Juan
	@since 23/03/2020
	@version P12
	@param lAuto, logico
	@return oBrowse, objeto
	/*/
Function PLSANONIMI()
	
	private oBrowse := Nil
	private aCampos := {}

	If FWAliasInDic("B6E", .F.)

		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias('B6E')
		oBrowse:SetDescription('Logs de Anonimização')
		oBrowse:SetMenuDef('PLSANONIMI')
		oBrowse:Activate()

	else
		MsgAlert("Tabela B6E não existe.") 
	EndIf

Return( NIL )

/*/{Protheus.doc} MenuDef
	(Definicao dos menus)
	@type  Static Function
	@author David Juan
	@since 23/03/2020
	@version P12
	@return aRotina, array
	/*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { "Anonimizar"	, 'PLSANONWIZ()' 		, 0 , 3	} )
	aAdd( aRotina, { "Visualizar"	, 'VIEWDEF.PLSANONIMI' 	, 0 , 2	} )

Return aRotina

/*/{Protheus.doc} ModelDef
	Definicao do modelo MVC para a tabela B6E
	@type  Static Function
	@author David Juan
	@since 27/03/2020
	@version P12
	@return oModel	objeto model criado
/	*/
Static Function ModelDef()
	Local oStruB6E := FWFormStruct( 1, 'B6E', , )
	Local oModel := MPFormModel():New( "PLSANONIMI", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) 

	oModel:AddFields( 'B6EMASTER', , oStruB6E )
	oModel:SetPrimaryKey({})
	oModel:GetModel( 'B6EMASTER' ):SetDescription( "Anonimização" ) 
	oModel:SetDescription( "Log de Anonimização" )

Return oModel

/*/{Protheus.doc} ViewDef
	Definicao da visao MVC para a tabela B6E
	@type  Static Function
	@author David Juan
	@since 27/03/2020
	@version P12
	@return oView	objeto view criado
	/*/
Static Function ViewDef()  
	Local oStruB6E := FWFormStruct( 2, 'B6E' ) 
	Local oModel   := FWLoadModel( 'PLSANONIMI' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B6E' , oStruB6E, 'B6EMASTER' )     
	oView:CreateHorizontalBox( 'GERAL', 100 )
	oView:SetOwnerView( 'VIEW_B6E' , 'GERAL'  )

Return oView

/*/{Protheus.doc} PLSCAMANON
	(Busca os campos de um alias que podem ser anonimizados conforme a configuracao para Protected Data (tabela XAM) e retorna os campos que serão anonimizados.)
	@type  Function
	@author David Juan
	@since 23/03/2020
	@version P12
	@param 
	@return aCampAnon, array
	@see https://tdn.totvs.com/display/public/PROT/FwProtectedDataUtil
	/*/
Function PLSCAMANON (aAlias)
	Local aCampAnon 		:= {}
	Default aAlias		:= PLSALIANON()

	aCampAnon := objCENFUNLGP:camposAnoni(aAlias)

Return aCampAnon

/*/{Protheus.doc} PLSALIANON
	(Retorna os alias que contem campos passíveis de anonimizacao.)
	@type  Function
	@author David Juan
	@since 23/03/2020
	@version P12
	@param 
	@return aAlias, array
	/*/
Function PLSALIANON()
	Local aAlias		:= {}

	/*
	Alias comentados nao tem vinculo com a BA1 (Beneficiarios) portanto nao serao anonimizados a principio
	*/

	aAdd(aAlias,'B2N')
	// aAdd(aAlias,'B3E')
	// aAdd(aAlias,'B3U')
	aAdd(aAlias,'B5D')
	// aAdd(aAlias,'B9H')
	// aAdd(aAlias,'B9P')
	// aAdd(aAlias,'B9W')
	// aAdd(aAlias,'B9Y')
	aAdd(aAlias,'BA3')
	aAdd(aAlias,'BA5')
	// aAdd(aAlias,'BB8')
	// aAdd(aAlias,'BBG')
	// aAdd(aAlias,'BCR')
	// aAdd(aAlias,'BE7')
	// aAdd(aAlias,'BJM')
	// aAdd(aAlias,'BQC')
	aAdd(aAlias,'BTS')
	// aAdd(aAlias,'BXJ')
	// aAdd(aAlias,'BXL')
	// aAdd(aAlias,'BXM')
	// aAdd(aAlias,'BXN')
	// aAdd(aAlias,'BXO')
	// aAdd(aAlias,'BXQ')
	// aAdd(aAlias,'BXS')
	aAdd(aAlias,'BA1')

Return aAlias

/*/{Protheus.doc} PLSANONWIZ
	(Wizard para anonimização dos dados)
	@type  Function
	@author David Juan
	@since 23/03/2020
	@version P12
	@param 
	@return 
	@see https://tdn.totvs.com/display/framework/FWWizardControl
	/*/
Function PLSANONWIZ(lGravou)
    Local oPanel
    Local oNewPag
    Local oPanelBkg
    Private oStepWiz 		:= nil
    Private oDlgMaster 	:= nil
    Private cMatric 	:= Space(8)
    Private cBenef 		:= Space(70)
	Private nRecno

    //Para que a tela da classe FWWizardControl fique no layout com bordas arredondadas
    //iremos fazer com que a janela do Dialog oculte as bordas e a barra de titulo
    //para isso usaremos os estilos WS_VISIBLE e WS_POPUP
    DEFINE DIALOG oDlgMaster TITLE 'Anonimização LGPD' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )
    oDlgMaster:nWidth := 800
    oDlgMaster:nHeight := 620
    oPanelBkg:= tPanel():New(0,0,"",oDlgMaster,,,,,,300,300)
    oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT
    //Instancia a classe FWWizard
    oStepWiz:= FWWizardControl():New(oPanelBkg)
    oStepWiz:ActiveUISteps()
    
    //----------------------
    // Pagina 1
    //----------------------
    oNewPag := oStepWiz:AddStep("1")
    //Altera a descrição do step
    oNewPag:SetStepDescription("Selecione o Beneficiário")
    //Define o bloco de construção
    oNewPag:SetConstruction({|Panel|cria_pg1(Panel, @cMatric, @cBenef)})
    //Define o bloco ao clicar no botão Próximo
    oNewPag:SetNextAction({||valida_pg1(@cMatric, @cBenef)})
    //Define o bloco ao clicar no botão Cancelar
    oNewPag:SetCancelAction({||, .T., oDlgMaster:End()})
    
    //----------------------
    // Pagina 2
    //----------------------
    oNewPag := oStepWiz:AddStep("2", {|Panel|cria_pg2(Panel)})
    oNewPag:SetStepDescription("Campos a serem excluídos")
    oNewPag:SetNextAction({||valida_pg2(@cMatric, @cBenef)})
    oNewPag:SetCancelAction({||, .T., oDlgMaster:End()})
    
    oNewPag:SetPrevAction({|| .T.})
    oNewPag:SetPrevTitle("Voltar")
    
    //----------------------
    // Pagina 3
    //----------------------
    oNewPag := oStepWiz:AddStep("3")
	oNewPag:SetConstruction({|Panel|cria_pg3(Panel),oDlgMaster:End()})

    oStepWiz:Activate()
    
    ACTIVATE DIALOG oDlgMaster CENTER
	FreeObj( oStepWiz )
	oBrowse:GoBottom()

Return
//--------------------------
// Construção da página 1
//--------------------------
Static Function cria_pg1(oPanel, cMatric, cBenef)
	Local bValid
	Local cMsg1
	Local cMsg2
	Local oTFont
	Local oTGet1
	Local oTGet2

	bValid := 	{|| PLSPESUSER(),;
				nRecno := BA1->(Recno()),;
				BA1->(DbGoTo(nRecno)),;
				cBenef := BA1->BA1_NOMUSR,;
				cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;
				oTGet1:CtrlRefresh(),;
				oTGet2:CtrlRefresh()}

	oTFont := TFont():New('Arial',,-12,.T.)
	cMsg1 := "A anonimização é o último ato para eliminar definitivamente informações sensíveis ou pessoais vinculadas à uma determinada pessoa."
	cMsg2 := "Selecione abaixo o Beneficiário que terá seus dados anonimizados."
    
    oSay1 := TSay():New(10,25,{||cMsg1},oPanel,,oTFont,,,,.T.,,,300,20)
    oSay2 := TSay():New(30,25,{||cMsg2},oPanel,,oTFont,,,,.T.,,,300,20)
    oSay3 := TSay():New(70,25,{||'Matrícula'},oPanel,,,,,,.T.,,,50,20)
    oSay4 := TSay():New(70,107,{||'Nome do Beneficiário'},oPanel,,,,,,.T.,,,100,20)
    oTGet1 := tGet():New(80,025,{|u| if(PCount()>0,cMatric:=u,cMatric)}, oPanel ,70,9,/*Alltrim(X3Picture("B1N_MATRIC"))*/PesqPict( "B1N", "B1N_MATRIC" ),{ ||   },,,,,,.T.,,, {|| .T. } ,,,,.F.,,"SA1","cMatric", , , , .F., .T. )
    oTGet2 := tGet():New(80,107,{|u| if(PCount()>0,cBenef:=u,cBenef)},oPanel ,220,9, ,{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,"","cBenef",,,,.T.,.T.)
	oTButton := TButton():New( 80, 335, "Selecionar",oPanel,{|| }, 40,10,,,.F.,.T.,.F.,,.F., {||},,.F. )
	oTButton:bAction := bValid

Return
//----------------------------------------
// Validação do botão Próximo da página 1
//----------------------------------------
Static Function valida_pg1(cMatric, cBenef)
	Local lRet 		:= .T.
	if empty(nRecno)
		MsgAlert("Selecione um Beneficiário")
		lRet := .F.
	EndIf

Return lRet
//--------------------------
// Construção da página 2
//--------------------------
Static Function cria_pg2(oPanel)
	Local cCampos
	Local cMsg
	Local cSep := "," + space(5)

	cMsg	:= "Os campos indicados abaixo serão excluídos PERMANENTEMENTE" + CRLF 
	cMsg 	+= "E ao clicar em 'AVANÇAR' você está ciente que este processo é IRREVERSÍVEL"
	aCampos := PLSCAMANON()	
	cCampos := ArrtokStr(aCampos,cSep)

	oTFont1 := TFont():New('Arial',,-16,.T.,.T.)
	oTFont2 := TFont():New('Arial',,-18,.T.)
	oTMultiget1 := tMultiget():new(01,01,{| u | if( pCount() > 0, cMsg := u, cMsg )},oPanel,398,50,oTFont1,,,,,.T.,nil,nil,{||},nil,nil,.T.,{||},nil,nil,.F.,.F.)
	oTMultiget2 := tMultiget():new(51,01,{| u | if( pCount() > 0, cCampos := u, cCampos )},oPanel,398,151,oTFont2,,,,,.T.,nil,nil,{||},nil,nil,.T.,{||},nil,nil,.F.,.F.)

Return
//----------------------------------------
// Validação do botão Próximo da página 2
//----------------------------------------
Static Function valida_pg2(cMatric, cBenef)
	If MsgYesNo("Confirma a exclusão dos campos apresentados?" + CRLF + CRLF + "Beneficiário selecionado: "+ CRLF + cMatric +' - '+ cBenef  + CRLF + CRLF +"ESTE PROCESSO NÃO PODERÁ SER DESFEITO","AVISO")
		if PLSSENANON()
			Return(.T.)
		EndIf
	EndIf
Return(.F.)
//--------------------------
// Construção da página 3
//--------------------------
Static Function cria_pg3(oPanel)
    
	Processa( {|| PLSANONREC() }, "Aguarde...", "Efetuando anonimização...",.F.)
	Processa( {|| PLSLOGANON() }, "Aguarde...", "Gravando Log...",.F.)
	MsgInfo("Processo de Anonimização Concluído com Sucesso","TOTVS")

Return(.T.)

/*/{Protheus.doc} PLSSENANON
	(Tela para informar a senha do supervisor)
	@type  Function
	@author David Juan
	@since 25/03/2020
	@version P12
	@param 
	@return lRet, logico
	/*/

function PLSSENANON()

	LOCAL oSay			:= NIL
	LOCAL oDlg		  	:= NIL
	LOCAL lRet		  	:= .F.
	LOCAL cSenhaAc   	:= Space(15)
	LOCAL bOK     		:= {|| Iif(!Empty(cSenhaAc) .And. PLSGETSPRO(cSenhaAC), Eval(bAviso), Eval(bStop)), oDlg:End()}
	Local bAviso  		:= {||lRet := .T.}
	Local bStop  		:= {||MsgStop("Senha inválida."), lRet := .F.}
	local cUsuSup 		:= AllTrim(PswRet()[1][2])
	local cTitulo 		:= 'Senha do Usuário: ' + cUsuSup
	LOCAL bCancel    	:= {|| nOpca := 0,oDlg:End() }

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 009,000 TO 018,050

	@ 040,005  SAY 	oSay PROMPT "Senha: "  	SIZE 190,050 			OF oDlg PIXEL 	COLOR CLR_RED
	@ 038,060 MSGET cSenhaAc    		SIZE 035,006 			OF oDlg PIXEL 	PASSWORD

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.F.) } )

return lRet

/*/{Protheus.doc} PLSANONREC
	(Efetua a anonimizacao dos campos conforme o alias e o(s) recno(s))
	@type  Function
	@author Silvia Sant'Anna
	@since 26/03/2020
	@version P12
	/*/
Function PLSANONREC(aAlias)
	Local cAlias		:= ''	
	Local i				:= 0	
	Local aRecno 		:= {}
	LOCAL cSQL 			:= ""
	LOCAL aRet 			:= {}
	Default aAlias		:= PLSALIANON()

	ProcRegua(Len(aAlias))
	For i := 1 to Len(aAlias)
		IncProc()
		aRecno := {}
		do case
		case aAlias[i] == "BA1"
			cAlias := aAlias[i]
			aAdd(aRecno, nRecno )
			aadd(aRet, objCENFUNLGP:Anonimizar(cAlias, aRecno))
			
		case aAlias[i] == "BTS"
			cAlias := aAlias[i]
			(cAlias)->(DbSetorder(1)) //BTS_FILIAL+BTS_MATVID
			if (cAlias)->(MsSeek(xFilial(cAlias) + BA1->BA1_MATVID))
				while !((cAlias)->(eof())) .and. (cAlias)->(BTS_FILIAL+BTS_MATVID) == xFilial(cAlias) + BA1->BA1_MATVID
					aAdd(aRecno, (cAlias)->(Recno()) )
					(cAlias)->(dbSkip())
				endDo 
				aadd(aRet, objCENFUNLGP:Anonimizar(cAlias, aRecno))
			EndIf

		case aAlias[i] == "BA3"
			cAlias := aAlias[i]
			(cAlias)->(DbSetorder(1)) // BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
			If (cAlias)->(MsSeek(xFilial(cAlias) + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
				while !((cAlias)->(eof())) .and. (cAlias)->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB) == xFilial(cAlias) + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)
					aAdd(aRecno, (cAlias)->(Recno()) ) 
					(cAlias)->(dbSkip())
				endDo
				aadd(aRet, objCENFUNLGP:Anonimizar(cAlias, aRecno))
			EndIf

		case aAlias[i] == "B2N"
			cAlias := aAlias[i]
			(cAlias)->(dbSetOrder(2)) //B2N_FILIAL+B2N_CPFUSR
			if (cAlias)->(MsSeek(xFilial(cAlias) + BA1->BA1_CPFUSR))
				while !((cAlias)->(eof())) .and. (cAlias)->(B2N_FILIAL+B2N_CPFUSR) == xFilial(cAlias) + BA1->BA1_CPFUSR
					aAdd(aRecno, (cAlias)->(Recno()) ) 
					(cAlias)->(dbSkip())
				endDo
				aadd(aRet, objCENFUNLGP:Anonimizar(cAlias, aRecno))
			EndIf

		case aAlias[i] == "B5D"
			cAlias := aAlias[i]
			cSQL := "SELECT " + cAlias + "_FILIAL, " + cAlias + "_CODINT, " + cAlias + "_MATRIC, R_E_C_N_O_ Recno FROM "+ RetSQLName(cAlias) + " WHERE "
			cSQL += cAlias + "_FILIAL = '"+ xFilial(cAlias) + "' AND "
			cSQL += cAlias + "_CODINT = '"+ BA1->BA1_CODINT + "' AND "
			cSQL += cAlias + "_MATRIC = '"+ BA1->(BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO) +"'  "
			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBB5D",.F.,.T.)

			If ! TRBB5D->(Eof())
				TRBB5D->( dbGotop() )
				While !TRBB5D->( Eof() )
					aAdd(aRecno, TRBB5D->(Recno()) ) 
					TRBB5D->( dbSkip() )
				Enddo
				aadd(aRet, objCENFUNLGP:Anonimizar(cAlias, aRecno))
			EndIf
			TRBB5D->(DbCloseArea())
		endcase
		
	next

Return aRet

/*/{Protheus.doc} PLSLOGANON
	Grava o log de anonimizacao.
	@author Silvia Sant'Anna
	@since 26/03/2020
	@version P12
/*/
function PLSLOGANON()
	
	B6E->( RecLock("B6E",.T.) )
		ProcRegua(B6E->(LastRec()))
		B6E->B6E_FILIAL	:= xFilial("B6E")
		B6E->B6E_USR	:= PLSRtCdUsr() + '-' + PLRETOPE()
		B6E->B6E_DATA	:= Date()
		B6E->B6E_HORA	:= SubStr(Time(),1,5)
		B6E->B6E_CAMPOS	:= AllTrim(ArrtokStr(aCampos,','))
		B6E->B6E_MATRIC	:= BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)
		IncProc()
	B6E->( MsUnLock() )

return
