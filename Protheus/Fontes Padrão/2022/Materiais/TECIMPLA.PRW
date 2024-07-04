#INCLUDE "TECIMPLA.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TopConn.ch"  
#INCLUDE "Fileio.ch"
#INCLUDE "SHELL.ch"
#INCLUDE 'protheus.ch'

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECWizardI
@description Criação dos Wizard
@return aRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECWizardI()
Local nIntOpc	:= 0
Local nOpc      := 2
Local oPageWiz  := nil
Local oView     := nil
Local oPanel
Local oNewPag
Local cCodCli := cFornec := Space(8)
Local cNome      := cProdDe := cProdAte:= Space(30)
Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 1000) .AND. (GetScreenRes()[1] <= 1500)) //786 x 1366
Local cGrupo  := Space(4)

Local oStepWiz := nil
Local oDlg := nil
Local oPanelBkg

Local bCancel   := {|| TecImpCanc(nOpc) }

DocWizard()

nG408Oper := nOpc
nIntOpc := MODEL_OPERATION_INSERT

oWizard := FWWizardControl():New()

If lMonitor
	oWizard:SetSize({oMainWnd:nClientHeight* 0.95, oMainWnd:nClientWidth* 0.95 })
Else
	oWizard:SetSize({oMainWnd:nClientHeight * 0.70,oMainWnd:nClientWidth * 0.43})
EndIf
oWizard:ActiveUISteps()

//Primeira Página - Introdução
oPageWiz := oWizard:AddStep("1")
oPageWiz:SetStepDescription(STR0001)	//"Bem-vindo(a)"
oPageWiz:SetConstruction( {|oPnl| TecImpWiza(oPnl,"1",nIntOpc)} ) //Define o bloco de construção
oPageWiz:SetCancelAction( {|| TecImpCanc(1)} )//Valida acao cancelar, nao deixa sair do wizard //"Wizard não pode ser cancelado!"

//Segunda Página - definição dos campos de filtro
oPageWiz := oWizard:AddStep("2")
oPageWiz:SetStepDescription(STR0002)	//"parâmetros Inciais"
oPageWiz:SetConstruction( {|oPnl| TecImpWiza(oPnl,"2",nIntOpc,oWizard:aODlgSize)} ) //Define o bloco de construção
oPageWiz:SetNextAction( {|x| x:= TecImpVldS("2")/*, MostraMSG("3")*/} )//Define o bloco ao clicar no botão Próximo
oPageWiz:SetCancelAction( {|| TecImpCanc(1)} )//Valida acao cancelar, nao deixa sair d]o wizard //"Wizard não pode ser cancelado!"

//Terceira Página - Montagem da Escala
oPageWiz := oWizard:AddStep("3")
oPageWiz:SetStepDescription(STR0003)	//"Orçamento e Precificação"
oPageWiz:SetConstruction( {|oPnl| oView := TecImpWiza(oPnl,"3",,oWizard:aODlgSize)} ) //Define o bloco de construção
oPageWiz:SetPrevAction( {|oPnl| FwAlertHelp(STR0004)} ) // "Não é possivel retorna a tela de parametrização, por favor cancele a operação atual."
oPageWiz:SetCancelAction(bCancel)//Valida acao cancelar, nao deixa sair do wizard //"Wizard não pode ser cancelado!"

//Terceira Página - Montagem da Escala
oPageWiz := oWizard:AddStep("4")
oPageWiz:SetStepDescription(STR0005)	//"Contratos"
oPageWiz:SetConstruction( {|oPnl| oView := TecImpWiza(oPnl,"4",,oWizard:aODlgSize)} ) //Define o bloco de construção
oPageWiz:SetNextAction( {|lOk|  lOk:=TecImpVldS("4")} )//Define o bloco ao clicar no botão Próximo
oPageWiz:SetCancelAction(bCancel)//Valida acao cancelar, nao deixa sair do wizard //"Wizard não pode ser cancelado!"

//Quarta Página - Definição de Veículos
oPageWiz := oWizard:AddStep("5")
oPageWiz:SetStepDescription(STR0006) //"Operacional"
oPageWiz:SetConstruction( {|oPnl| oView := TecImpWiza(oPnl,"5",,oWizard:aODlgSize)} ) //Define o bloco de construção
oPageWiz:SetNextAction( {|lOk|  lOk:=TecImpVldS("5")} )//Define o bloco ao clicar no botão Próximo
oPageWiz:SetCancelAction(bCancel)//Valida acao cancelar, nao deixa sair do wizard //"Wizard não pode ser cancelado!"

//Quarta Página - Definição de Veículos
oPageWiz := oWizard:AddStep("6")
oPageWiz:SetStepDescription(STR0007) //"Armamento"
oPageWiz:SetConstruction( {|oPnl| oView := TecImpWiza(oPnl,"6",,oWizard:aODlgSize)} ) //Define o bloco de construção
oPageWiz:SetCancelAction(bCancel)//Valida acao cancelar, nao deixa sair do wizard //"Wizard não pode ser cancelado!"

//Quarta Página - Definição de Veículos
oPageWiz := oWizard:AddStep("7")
oPageWiz:SetStepDescription(STR0008) //"Resultado"
oPageWiz:SetConstruction( {|oPnl| oView := TecImpWiza(oPnl,"7",,oWizard:aODlgSize)} ) //Define o bloco de construção
oPageWiz:SetNextAction( {|lOk|  lOk := MsgYesNo(STR0009, STR0010), IIF(lOk, ImplaReq(), FwAlertHelp(STR0011,STR0012))  } )//"Concorda com a edição dos parâmetros?" ## "Facilitador de Implantação" ## "Implantação" ## "Operação Cancelada."
oPageWiz:SetCancelAction(bCancel)//Valida acao cancelar, nao deixa sair do wizard //"Wizard não pode ser cancelado!"

//Ativa Wizard
oWizard:Activate()

//Desativa Wizard
oWizard:Destroy()

Return()

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecImpWiza
@description Criação das telas do wizard
@return aRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TecImpWiza(oPanel, cPage, nOpc, aWizSize)
Local oFWlayer  := nil
Local oWin      := nil
Local oTxtLn1   := nil
Local oFont     := nil
Local cTexto	:= ""
Local cTexto2	:= ""
Local lContinua	:= .T.
Local nTam1     := -18
Local nHeight 	:= 0
Local nWidth	:= 0
Local cTextHtml := ""
Local xRet
Local lCopy		:= IIf(nG408Oper == 2, .t.,.f.)
Local lMonitor	:= IsBlind() .OR. ((GetScreenRes()[2] <= 1000) .AND. (GetScreenRes()[1] <= 1500)) //786 x 1366

Default nOpc	:= MODEL_OPERATION_INSERT

oFWLayer := FWLayer():New()
oFWLayer:Init( oPanel, .F.)
oFWLayer:AddCollumn("C1", 100, .T.)
oFWLayer:AddLine("L1", 100)

//Componentes da Interface
Do Case
Case ( cPage == "1" )   //Introdução - Boas Vindas

    oFWLayer:addWindow("C1", "WIN00", STR0038, 100,.F., .F., {|| Nil })	//"Assinstente de Configuração"

    oWin := oFWLayer:getWinPanel("C1", "WIN00")

	cTexto := STR0013  //"Bem-vindo(a) ao Facilitador de Implantação!"
	cTexto2 := STR0014  //"Por meio deste assistente é possível configurar o módulo Prestadores de Serviços Terceirização."

    oFont  := TFont():New('Arial',,nTam1,.T.,.T.)
    // Monta o Texto no formato HTML
  	cTextHtml := '<br><p><center><font face="Arial" size="3">'+ cTexto + '</font></center></p><br>'+;
  	 			  '<p><center><font face="Arial" size="3">'+ cTexto2 + '</font></center></p>'
  	 

  	// Cria o Say permitindo texto no formato HMTL 
  	lHtml := .T.                       
  	
	If lMonitor
		oTxtLn1:= TSay():New(01,01,{||cTextHtml},oWin,,oFont,,,,.T.,,,620,300,,,,,,lHtml)	
	Else
		oTxtLn1:= TSay():New(01,01,{||cTextHtml},oWin,,oFont,,,,.T.,,,405,100,,,,,,lHtml)	
	EndIf
Case ( cPage == "2" )   //Filtro de Horários
    
    oFWLayer:addWindow("C1", "WIN01", STR0039, 100,.F., .F., {|| Nil }) //"Parametrização para filtro"

    oWin    := oFWLayer:getWinPanel("C1", "WIN01")
     
Case ( cPage == "3" )   //Define os horários da escala
	SetFilCont(5, .F.)
	If GetImplaF()[1]
		SetFilCont(, , .T.)
		SetFilCont(1, GetImplaF()[1])
		oFWLayer:addWindow("C1", "WIN02", STR0003, 100,.F., .F., {|| Nil })   //"Orçamento e Precificação"
		oWin    := oFWLayer:getWinPanel("C1", "WIN02")
		
		nHeight := aWizSize[1] - (aWizSize[1]*0.53)	//282//oPanel:oWnd:aControls[8]:oWnd:nClientHeight
		nWidth	:= aWizSize[2] - (aWizSize[2]*0.69)	//470//oPanel:oWnd:aControls[8]:oWnd:nRight-100
	Else
		oFWLayer:addWindow("C1", "WIN00", STR0003, 100,.F., .F., {|| Nil })	//"Assinstente de Configuração"

		oWin := oFWLayer:getWinPanel("C1", "WIN00")

		cTexto := STR0015 //"Não foi selecionado a opção para ser processada."
		cTexto2 := STR0016  //"Por favor selecione a próxima pagina para continuar com a implantação."

		oFont  := TFont():New('Arial',,nTam1,.T.,.T.)
		// Monta o Texto no formato HTML
		cTextHtml := '<br><p><center><font face="Arial" size="3">'+ cTexto + '</font></center></p><br>'+;
					'<p><center><font face="Arial" size="3">'+ cTexto2 + '</font></center></p>'
		

		// Cria o Say permitindo texto no formato HMTL 
		lHtml := .T.                       
		
		If lMonitor
			oTxtLn1:= TSay():New(01,01,{||cTextHtml},oWin,,oFont,,,,.T.,,,620,300,,,,,,lHtml)	
		Else
			oTxtLn1:= TSay():New(01,01,{||cTextHtml},oWin,,oFont,,,,.T.,,,405,100,,,,,,lHtml)	
		EndIf
		lContinua := .F.
	EndIf
    	
Case ( cPage == "4" )   //Define os veículos para rodar na escala

	If GetImplaF()[2]
		SetFilCont(, , .T.)
		SetFilCont(2, GetImplaF()[2])
		oFWLayer:addWindow("C1", "WIN02", STR0005, 100,.F., .F., {|| Nil })   //"Contratos"
		oWin    := oFWLayer:getWinPanel("C1", "WIN02")
		
		nHeight := aWizSize[1] - (aWizSize[1]*0.53)	//282//oPanel:oWnd:aControls[8]:oWnd:nClientHeight
		nWidth	:= aWizSize[2] - (aWizSize[2]*0.69)	//470//oPanel:oWnd:aControls[8]:oWnd:nRight-100
	Else
		oFWLayer:addWindow("C1", "WIN00", STR0005, 100,.F., .F., {|| Nil })	//"Assinstente de Configuração"

		oWin := oFWLayer:getWinPanel("C1", "WIN00")

		cTexto := STR0015 //"Não foi selecionado a opção para ser processada."
		cTexto2 := STR0016  //"Por favor selecione a proxima pagina para continuar com a implantação."

		oFont  := TFont():New('Arial',,nTam1,.T.,.T.)
		// Monta o Texto no formato HTML
		cTextHtml := '<br><p><center><font face="Arial" size="3">'+ cTexto + '</font></center></p><br>'+;
					'<p><center><font face="Arial" size="3">'+ cTexto2 + '</font></center></p>'
		

		// Cria o Say permitindo texto no formato HMTL 
		lHtml := .T.                       
		
		If lMonitor
			oTxtLn1:= TSay():New(01,01,{||cTextHtml},oWin,,oFont,,,,.T.,,,620,300,,,,,,lHtml)	
		Else
			oTxtLn1:= TSay():New(01,01,{||cTextHtml},oWin,,oFont,,,,.T.,,,405,100,,,,,,lHtml)	
		EndIf	
		lContinua := .F.
	EndIf
Case ( cPage == "5" )   //Define os veículos para rodar na escala
	If GetImplaF()[3]
		SetFilCont(, , .T.)
		SetFilCont(3, GetImplaF()[3])
		oFWLayer:addWindow("C1", "WIN02", STR0006, 100,.F., .F., {|| Nil })   //"Operacional"
		oWin    := oFWLayer:getWinPanel("C1", "WIN02")
		
		nHeight := aWizSize[1] - (aWizSize[1]*0.53)	//282//oPanel:oWnd:aControls[8]:oWnd:nClientHeight
		nWidth	:= aWizSize[2] - (aWizSize[2]*0.69)	//470//oPanel:oWnd:aControls[8]:oWnd:nRight-100
	Else
		oFWLayer:addWindow("C1", "WIN00", STR0006, 100,.F., .F., {|| Nil })	//"Assinstente de Configuração"

		oWin := oFWLayer:getWinPanel("C1", "WIN00")

		cTexto := STR0015 //"Não foi selecionado a opção para ser processada."
		cTexto2 := STR0016  //"Por favor selecione a proxima pagina para continuar com a implantação."

		oFont  := TFont():New('Arial',,nTam1,.T.,.T.)
		// Monta o Texto no formato HTML
		cTextHtml := '<br><p><center><font face="Arial" size="3">'+ cTexto + '</font></center></p><br>'+;
					'<p><center><font face="Arial" size="3">'+ cTexto2 + '</font></center></p>'
		

		// Cria o Say permitindo texto no formato HMTL 
		lHtml := .T.                       
		
		If lMonitor
			oTxtLn1:= TSay():New(01,01,{||cTextHtml},oWin,,oFont,,,,.T.,,,620,300,,,,,,lHtml)	
		Else
			oTxtLn1:= TSay():New(01,01,{||cTextHtml},oWin,,oFont,,,,.T.,,,405,100,,,,,,lHtml)	
		EndIf	
		lContinua := .F.
	EndIf
Case ( cPage == "6" )   //Define os veículos para rodar na escala
	If GetImplaF()[4]
		SetFilCont(, , .T.)
		SetFilCont(4, GetImplaF()[4])
		oFWLayer:addWindow("C1", "WIN02", STR0007, 100,.F., .F., {|| Nil })   //"Armamento"
		oWin    := oFWLayer:getWinPanel("C1", "WIN02")
		
		nHeight := aWizSize[1] - (aWizSize[1]*0.53)	//282//oPanel:oWnd:aControls[8]:oWnd:nClientHeight
		nWidth	:= aWizSize[2] - (aWizSize[2]*0.69)	//470//oPanel:oWnd:aControls[8]:oWnd:nRight-100
	Else
		oFWLayer:addWindow("C1", "WIN00", STR0007, 100,.F., .F., {|| Nil })	//"Armamentos"

		oWin := oFWLayer:getWinPanel("C1", "WIN00")

		cTexto := STR0015 //"Não foi selecionado a opção para ser processada."
		cTexto2 := STR0016  //"Por favor selecione a proxima pagina para continuar com a implantação."

		oFont  := TFont():New('Arial',,nTam1,.T.,.T.)
		// Monta o Texto no formato HTML
		cTextHtml := '<br><p><center><font face="Arial" size="3">'+ cTexto + '</font></center></p><br>'+;
					'<p><center><font face="Arial" size="3">'+ cTexto2 + '</font></center></p>'
		

		// Cria o Say permitindo texto no formato HMTL 
		lHtml := .T.                       
		
		If lMonitor
			oTxtLn1:= TSay():New(01,01,{||cTextHtml},oWin,,oFont,,,,.T.,,,620,300,,,,,,lHtml)	
		Else
			oTxtLn1:= TSay():New(01,01,{||cTextHtml},oWin,,oFont,,,,.T.,,,405,100,,,,,,lHtml)	
		EndIf
		lContinua := .F.
	EndIf
Case ( cPage == "7" )   //Define os veículos para rodar na escala
	oFWLayer:addWindow("C1", "WIN00", STR0018, 100,.F., .F., {|| Nil })	//"Resultados"

    oWin := oFWLayer:getWinPanel("C1", "WIN00")

	cTexto := STR0040  //"Finalização da Implantação." 
	cTexto2 := STR0041  //"Ao confirmar serão incorporadas as atualizações..."

    oFont  := TFont():New('Arial',,nTam1,.T.,.T.)
    // Monta o Texto no formato HTML
  	cTextHtml := '<br><p><center><font face="Arial" size="3">'+ cTexto + '</font></center></p><br>'+;
  	 			  '<p><center><font face="Arial" size="3">'+ cTexto2 + '</font></center></p>'
  	 

  	// Cria o Say permitindo texto no formato HMTL 
  	lHtml := .T.                       
  	
	If lMonitor
		oTxtLn1:= TSay():New(01,01,{||cTextHtml},oWin,,oFont,,,,.T.,,,620,300,,,,,,lHtml)	
	Else
		oTxtLn1:= TSay():New(01,01,{||cTextHtml},oWin,,oFont,,,,.T.,,,405,100,,,,,,lHtml)	
	EndIf	

EndCase

If ( cPage <> "1" ) .AND. ( cPage <> "7" )
	If lContinua
		TecImpView(oWin,cPage,nOpc,lCopy)
	EndIf
EndIf

Return(xRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecImpVldS
@description Criação dos Wizard
@return aRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TecImpVldS(cStep)
Local aParImpl	:= {}
Local lRet	:= .T.
Local nX

Do Case

	Case ( cStep == "2" )	//Segunda Página - Parâmetros para filtro
		If ascan( GetImplaF(), {|x| x }) == 0
			lRet := .F.
			FwAlertHelp(STR0011,STR0019) //"Implantação" ## "Por favor selecione uma opção na tela para continuar."
		EndIf
	Case ( cStep == "4" )	//Quart Página - Seleção dos Veículos
		aParImpl := GetParImpl()
		If ascan( aParImpl, {|a| ALLTRIM(a[1]) == AllTrim("MV_GSISS") .AND. a[2] }) > 0
			If ascan( aParImpl, {|a| ALLTRIM(a[1]) == AllTrim("MV_GSDSGCN") .AND. a[2] == '2' }) > 0 .OR. ascan( aParImpl, {|a| ALLTRIM(a[1]) == AllTrim("MV_ORCPRC") .AND. a[2] }) > 0
				lRet := MsgYesNo(STR0042, STR0043) //"A integração com o RH está desligada, porém a integração com benefícios está ativa. Deseja continuar?" ## "Integração RH"
			EndIf
		EndIf
	Case ( cStep == "5" )	//Quart Página - Seleção dos Veículos
		aParImpl := GetParImpl()
		If ascan( aParImpl, {|a| ALLTRIM(a[1]) == AllTrim("MV_TECXRH") .AND. !a[2] }) > 0
			If ascan( aParImpl, {|a| ALLTRIM(a[1]) == AllTrim("MV_BENEXGS") .AND. a[2] }) > 0 .OR. ascan( aParImpl, {|a| ALLTRIM(a[1]) == AllTrim("MV_GSBENAG") .AND. a[2] }) > 0
				lRet := MsgYesNo(STR0020, STR0021) //"A integração com o RH está desligada, porém a integração com benefícios está ativa. Deseja continuar?" ## "Integração RH"
			EndIf
		EndIf
EndCase

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecImpCanc
@description Criação dos Wizard
@return aRet
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TecImpCanc(nOpc)

	Local lRet := .T.
	Default nOpc := 1	// 1-Incluir; 2-Copiar; 3-Alterar

	IF nOpc == 1
		FWAlertInfo(STR0036) //"O Assistente de Configuração foi Cancelado!"
	Else
		If !FwAlertYesNo(STR0037)		// "O Assistente de Configuração será cancelado e as informações parametrizadas serão perdidas. Deseja continuar?"
			lRet := .F. 
		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecImpView
@description Criação dos Wizard
@return aRet
@author Augusto Albuquerque
@since  05/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TecImpView(oPanel,cPgWizard,nOpc,lCopy)
Local oView
Local oModel
Local oStruct
Local nP		:= 0
Local nOper 	:= 0

Default lCopy	:= .f.

Do Case
Case ( cPgWizard == "2" )

    oG408AView 	:= FWLoadView("TECIMPLB") 
	oView		:= oG408AView
	nOper		:= nOpc

Case ( cPgWizard == "3" )

    oG408BView := FWLoadView("TECIMPLB")
	oView := oG408BView
	nOper := MODEL_OPERATION_INSERT

Case ( cPgWizard == "4" )

    oG408CView := FWLoadView("TECIMPLB")	
	oView := oG408CView
	nOper		:= MODEL_OPERATION_INSERT

Case ( cPgWizard == "5" )

    oG408DView := FWLoadView("TECIMPLB")	
	oView := oG408DView
	nOper		:= MODEL_OPERATION_INSERT

Case ( cPgWizard == "6" )

    oG408EView := FWLoadView("TECIMPLB")	
	oView := oG408EView
	nOper		:= MODEL_OPERATION_INSERT

End Case

oModel := oView:GetModel()

oView:SetOperation(nOper)
oView:SetOwner(oPanel)

oView:Activate(lCopy)

Return(oView)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DocWizard
@description Criação dos Wizard
@return aRet
@author Augusto Albuquerque
@since  05/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function DocWizard()
Local oDlg	 	:= Nil
Local cLink  	:= "https://tdn.totvs.com/pages/viewpage.action?pageId=615604097"
Local oMemo     := Nil

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0022) FROM 0,0 TO 150,600 PIXEL //Atenção

TSay():New( 010,010,{||OemToAnsi(STR0023 )},oDlg,,TFont():New("Tahoma",,-12,.T.,.T.) ,.F.,.F.,.F.,.T.,CLR_BLACK)  //"Prezado cliente,"
TSay():New( 020,010,{||OemToAnsi(STR0024 )},oDlg,,TFont():New("Tahoma",,-12,.T.,.T.) ,.F.,.F.,.F.,.T.,CLR_BLACK)  //"As documentações foram centralizadas na seguinte pagina: "
@ 030,010 GET oMemo VAR cLink SIZE 273,010 PIXEL READONLY MEMO

TButton():New(050,010, OemToAnsi(STR0025), oDlg,{|| ShellExecute("Open", cLink, "", "", SW_NORMAL) },030,011,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Abrir Link"
TButton():New(050,050, OemToAnsi(STR0026), oDlg,{|| oDlg:End() },26,11,,,.F.,.T.,.F.,,.F.,,,.F. )  //"Ok"

ACTIVATE MSDIALOG oDlg CENTER

Return ( .T. )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ImplaReq
@description Criação dos Wizard
@return aRet
@author Augusto Albuquerque
@since  05/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static function ImplaReq()
FwMsgRun(Nil,{|| TecImplaR()}, Nil, STR0027) //"Atualizando parâmetros..."
Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecImplaR
@description Criação dos Wizard
@return aRet
@author Augusto Albuquerque
@since  05/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TecImplaR()
Local aParImpl 	:= GetParImpl()
Local cMsg		:= ""
Local cMsgCon	:= ""
Local cMsgNes	:= ""
Local cLink		:= "https://tdn.totvs.com/pages/viewpage.action?pageId=615604097"
Local nX
Local lRetPut	:= .T.

Begin Transaction
	For nX := 1 To Len(aParImpl)
		If aParImpl[nX][3]
			If (UPPER(aParImpl[nX][1]) == 'RECORRENTE'  .OR. UPPER(aParImpl[nX][1]) == 'ARMAMENTO')
				If aParImpl[nX][2]
					If Empty(cMsgNes)
						cMsgNes := REPLICATE(" ", 28) + STR0028 + CRLF + CRLF //"Modificações Necessarias"
					EndIf
					If UPPER(aParImpl[nX][1]) == 'RECORRENTE'
						cMsgNes += STR0029 + cLink + CRLF + CRLF //"Para a implementação do contrato recorrente por favor acessar a doc: "
					Else
						cMsgNes += STR0030 + cLink + CRLF + CRLF //"Para a implementação do armamento multiflial por favor acessar a doc: "
					EndIf
				EndIf
			Else
				lRetPut := PUTMV(aParImpl[nX][1], aParImpl[nX][2])
				If Empty(cMsgCon)
					cMsgCon := REPLICATE(" ", 28) + STR0031 + CRLF + CRLF //"Modificações Realizadas"
				EndIf
				If lRetPut
					cMsgCon += STR0032 + aParImpl[nX][1] + STR0033 + aParImpl[nX][4] + CRLF + CRLF //"Alteração do parametro: " ## " para valor "
				Else
					cMsgCon += STR0034 + aParImpl[nX][1] + STR0035 + CRLF + CRLF //"Não foi encontrado o parametro " ## ". Nenhum valor alterado"
				EndIf
			EndIf
		EndIf
	Next nX
End Transaction
If !Empty(cMsgNes)
	cMsgNes += "---------------------------------------------------------------------------------" + CRLF + CRLF
	cMsg += cMsgNes
EndIf
If !Empty(cMsgCon)
	cMsg += cMsgCon
EndIf
If !isBlind() .AND. !empty(cMsg)
	AtShowLog(cMsg,STR0010 ,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.) //"Facilitador de Implantação"
EndIf

Return

