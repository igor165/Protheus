#INCLUDE "GTPA408.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"  

/*
	QUERY
		Arrancar a opção 3-Ambos do campo Filtra por
		Filtro Por:
			1 - Setor - Pega todos horários que possuem as localidades do setor da seguinte forma:
				Tp. Filtro: 1- Extremidades (cada localidade do setor pode estar ou na partida ou na chegada - OBS: Pela GID) 
				Tp. Filtro: 2- Todos os Trechos (cada localidade do setor deve estar ou no trecho de partida ou 
				no trecho de chegada - OBS: Pega pela GIE)
			2 - Localidade: Utiliza os campos Partindo de e Chegando em, da seguinte forma:
				Tp. Filtro: 1- Extremidades (pegar horários pela GID - GID_LOCINI = Partindo de; GID_LOCFIM = Chegando em)
					Se o Campo partindo de estiver em branco, pega todos os horários de GID_LOCFIM = Chegando em
					Se o campo Chegando em estiver em branco, pega todos os horários de GID_LOCINI = Partindo de
				Tp. Filtro: 2- Todos os Trechos (pegar os horários pela GIE - GIE_IDLOCP = partindo de; GIE_IDLOCD )
					Se o Campo partindo de estiver em branco, pega todos os horários de GIE_IDLOCD = Chegando em
					Se o campo Chegando em estiver em branco, pega todos os horários de GIE_IDLOCP = Partindo de
*/

Static oG408AView	:= Nil	//View do MVC GTPA408A - Parâmetros para Filtro
Static oG408BView	:= Nil	//View do MVC GTPA408B - Montagem da Escala de Veículos
Static oG408CView	:= Nil	//View do MVC GTPA408C - Alocação de Veículos para a escala

Static aG408Linha	:= {}
Static aG408Veic	:= {}

Static c408CodEscala	:= ''
Static cG408ResultSet := ""	//Arquivo temporário do ResultSet da query filtrada a partir do step 2

Static nG408Oper		:= 0

/*/{Protheus.doc} G408BSetFromTo   
    Esta função é chamada pela função G408BCarga() para carregar os dados no grid SELECAO2.
	Este grid será carregado, de acordo com as informações do banco, dos registro da tabela
	G52
    @type  Function
    @author(s)	Fernando Amorim 	
				Fernando Radu Muscalu
				Mick William
    @since 27/07/2017
    @version version
    @param	
    @return
			
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPA408()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('G52')
oBrowse:SetDescription(STR0001)//"Escala de Veículos"
oBrowse:SetMenuDef('GTPA408')
oBrowse:Activate()
	
Return

/*/{Protheus.doc} GTPA036
    Programa de importação e exportação de arquivos da máquina DARUMA
    @type  Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 
    @return nil, nulo, sem retorno
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA408Wizard(nOpc)

Local nIntOpc	:= 0

Local oPageWiz  := nil
Local oView     := nil

Local bCancel   := {|| GA408BkSX8(nOpc) }

Default nOpc	:= 1	//1- Assistente (inclusão); 2-Cópia

nG408Oper := nOpc

If ( nOpc == 1 )
	nIntOpc := MODEL_OPERATION_INSERT
Else
	nIntOpc := MODEL_OPERATION_UPDATE
EndIf

oWizard := FWWizardControl():New()

oWizard:SetSize({oMainWnd:nClientHeight * 0.95,oMainWnd:nClientWidth * 0.95})
oWizard:ActiveUISteps()

//Primeira Página - Introdução
oPageWiz := oWizard:AddStep("1")
oPageWiz:SetStepDescription(STR0005)	//"1-Introdução" //"Bem Vindo"
oPageWiz:SetConstruction( {|oPnl| GA408WizScr(oPnl,"1",nIntOpc)} ) //Define o bloco de construção
oPageWiz:SetCancelAction( {|| GA408BkSX8(2)} )//Valida acao cancelar, nao deixa sair do wizard //"Wizard não pode ser cancelado!"

//Segunda Página - definição dos campos de filtro
oPageWiz := oWizard:AddStep("2")
oPageWiz:SetStepDescription(STR0006)	//"Parâmetros para filtro"
oPageWiz:SetConstruction( {|oPnl| GA408WizScr(oPnl,"2",nIntOpc,oWizard:aODlgSize)} ) //Define o bloco de construção
oPageWiz:SetNextAction( {|x| x:= GA408VldStep("2"), Iif(x,GA408CallNextStep("3"),x)} )//Define o bloco ao clicar no botão Próximo
oPageWiz:SetCancelAction( {|| GA408BkSX8(2)} )//Valida acao cancelar, nao deixa sair do wizard //"Wizard não pode ser cancelado!"

//Terceira Página - Montagem da Escala
oPageWiz := oWizard:AddStep("3")
oPageWiz:SetStepDescription(STR0007)	//"Montagem da Escala"
oPageWiz:SetConstruction( {|oPnl| oView := GA408WizScr(oPnl,"3",,oWizard:aODlgSize)} ) //Define o bloco de construção
oPageWiz:SetNextAction( {|lOk|  lOk:=GA408VldStep("3"),Iif(lOk,GA408CallNextStep("4"),lOk) } )//Define o bloco ao clicar no botão Próximo
oPageWiz:SetCancelAction(bCancel)//Valida acao cancelar, nao deixa sair do wizard //"Wizard não pode ser cancelado!"

//Quarta Página - Definição de Veículos
oPageWiz := oWizard:AddStep("4")
oPageWiz:SetStepDescription(STR0008) //"Escolha dos Veículos"
oPageWiz:SetConstruction( {|oPnl| oView := GA408WizScr(oPnl,"4",,oWizard:aODlgSize)} ) //Define o bloco de construção
oPageWiz:SetNextAction( {|lOk|  lOk:=GA408VldStep("4"), If(lOk,GA408Commit(),lOk )  } )//Define o bloco ao clicar no botão Próximo
oPageWiz:SetCancelAction(bCancel)//Valida acao cancelar, nao deixa sair do wizard //"Wizard não pode ser cancelado!"


//Ativa Wizard
oWizard:Activate()

//Desativa Wizard
oWizard:Destroy()

GA408Destroy()

Return()

/*/{Protheus.doc} GA036WizScr
    Função responsável pela montagem dos painéis do Wizard
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param  oPanel, objeto, instância da classe tPanel
            cPage, caractere, nro da página (step) do wizard que é montada
    @return xRet, qualquer, de acordo com a página que é montada, um retorno diferente será usado.
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA408WizScr(oPanel, cPage, nOpc, aWizSize)

Local oFWlayer  := nil
Local oWin      := nil
Local oTxtLn1   := nil
Local oFont     := nil
Local cTexto	:= ""
Local cTexto2	:= ""
Local nTam1     := -18
Local nHeight 	:= 0
Local nWidth	:= 0
Local cTextHtml := ""
Local xRet
Local lCopy		:= IIf(nG408Oper == 2, .t.,.f.)

Default nOpc	:= MODEL_OPERATION_INSERT

oFWLayer := FWLayer():New()
oFWLayer:Init( oPanel, .F.)
oFWLayer:AddCollumn("C1", 100, .T.)
oFWLayer:AddLine("L1", 100)

//Componentes da Interface
Do Case
Case ( cPage == "1" )   //Introdução - Boas Vindas

    oFWLayer:addWindow("C1", "WIN00", STR0009, 100,.F., .F., {|| Nil })	//"Assinstente de Configuração"

    oWin := oFWLayer:getWinPanel("C1", "WIN00")

	cTexto := STR0010 //"Bem vindo ao assistente de Escalas de Veículos."
	cTexto2 := STR0011 //"Através desse assistente será possível criar, alterar e/ou copiar a escala de veículos."

    oFont  := TFont():New('Arial',,nTam1,.T.,.T.)
    // Monta o Texto no formato HTML
  	cTextHtml := '<br><p><center><font face="Arial" size="3">'+ cTexto + '</font></center></p><br>'+;
  	 			  '<p><center><font face="Arial" size="3">'+ cTexto2 + '</font></center></p>'
  	 

  	// Cria o Say permitindo texto no formato HMTL 
  	lHtml := .T.                       
  	
	oTxtLn1:= TSay():New(01,01,{||cTextHtml},oWin,,oFont,,,,.T.,,,620,300,,,,,,lHtml)	
	
	IF lCopy
		c408CodEscala	:= GetSxEnum('G52','G52_CODIGO')
	ElseIF nOpc <> 4
		c408CodEscala	:= GetSxEnum('G52','G52_CODIGO')
	EndIf 

Case ( cPage == "2" )   //Filtro de Horários
    
    oFWLayer:addWindow("C1", "WIN01", STR0012, 100,.F., .F., {|| Nil }) //"Parametrização para filtro"

    oWin    := oFWLayer:getWinPanel("C1", "WIN01")
     
Case ( cPage == "3" )   //Define os horários da escala

    oFWLayer:addWindow("C1", "WIN02", STR0007, 100,.F., .F., {|| Nil })   //"Montagem da Escala"
    oWin    := oFWLayer:getWinPanel("C1", "WIN02")
	
	nHeight := aWizSize[1] - (aWizSize[1]*0.53)	//282//oPanel:oWnd:aControls[8]:oWnd:nClientHeight
    nWidth	:= aWizSize[2] - (aWizSize[2]*0.69)	//470//oPanel:oWnd:aControls[8]:oWnd:nRight-100
    	
Case ( cPage == "4" )   //Define os veículos para rodar na escala

    oFWLayer:addWindow("C1", "WIN03", STR0013, 100,.F., .F., {|| Nil })   //"Seleção dos Veículos"
	oWin    := oFWLayer:getWinPanel("C1", "WIN03")

EndCase

If ( cPage <> "1" )
	GA408SetView(oWin,cPage,nOpc,lCopy)
EndIf

Return(xRet)

/*/{Protheus.doc} GA408SetView
	Chama as Views de MVCs que contemplam cada step do wizard
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 16/06/2017	
	@version version
	@param param, param_type, param_descr
	@return returno,return_type, Instância da classe FwFormView
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GA408SetView(oPanel,cPgWizard,nOpc,lCopy)

Local oView
Local oModel
Local oStruct
Local nP		:= 0
Local nOper 	:= 0

Default lCopy	:= .f.

Do Case
Case ( cPgWizard == "2" )

    oG408AView 	:= FWLoadView("GTPA408A") 
	oView		:= oG408AView
	nOper		:= nOpc

	If ( nOper <> MODEL_OPERATION_INSERT )
		oStruct := oView:GetViewObj("VIEW_CAB")[3]:GetStruct() //oView:GetModel("MASTER"):GetStruct()
		oStruct:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
	EndIf

Case ( cPgWizard == "3" )

    oG408BView := FWLoadView("GTPA408B")
	oView := oG408BView
	nOper		:= MODEL_OPERATION_UPDATE
	
	If ( !lCopy .And. nG408Oper <> 1)
	
		oStruct := oView:GetViewObj("VIEW_CAB")[3]:GetStruct() //oView:GetModel("MASTER"):GetStruct()
		oStruct:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)

	EndIf

Case ( cPgWizard == "4" )

    oG408CView := FWLoadView("GTPA408C")	
	oView := oG408CView
	nOper		:= MODEL_OPERATION_INSERT

End Case

oModel := oView:GetModel()

nP := aScan(oModel:Cargo,{|z| z[1] == "FUNNAME"})

If (nP > 0 )
	oModel:Cargo[nP][2] := "GTPA408"
EndIf

oView:SetOperation(nOper)
oView:SetOwner(oPanel)

If ( cPgWizard == "2" )

	GY4->(DbSetOrder(1))

	GY4->(DbSeek(XFilial("GY4")+G52->G52_CODIGO))

EndIf

oView:Activate(lCopy)

Return(oView)

/*/{Protheus.doc} GA408Destroy   
   Função responsável por destruir os objetos e redefinir as variáveis estáticas.
    @type  Function
    @author	Fernando Radu Muscalu				
    @since 27/07/2017
    @version version
    @param	
    @return
			
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA408Destroy()

//Destrói a View do MVC GTPA408A - Parâmetros para Filtro
If ( Valtype(oG408AView) == "O" .And. oG408AView:ClassName() == "FWFORMVIEW" )

    If ( oG408AView:IsActive() )
        oG408AView:DeActivate()
    EndIf   

    oG408AView:Destroy()

EndIf

//Destrói a View do MVC GTPA408B - Montagem da Escala de Veículos
If ( Valtype(oG408BView) == "O" .And. oG408BView:ClassName() == "FWFORMVIEW" )

    If ( oG408BView:IsActive() )
        oG408BView:DeActivate()
    EndIf   

    oG408BView:Destroy()

EndIf

//Destrói a View do MVC GTPA408C - Alocação de Veículos para a escala
If ( Valtype(oG408CView) == "O" .And. oG408CView:ClassName() == "FWFORMVIEW" )

    If ( oG408CView:IsActive() )
        oG408CView:DeActivate()
    EndIf   

    oG408CView:Destroy()

EndIf

G408RSetDestroy()

oG408AView		:= Nil	//View do MVC GTPA408A - Parâmetros para Filtro
oG408BView		:= Nil	//View do MVC GTPA408B - Montagem da Escala de Veículos
oG408CView		:= Nil	//View do MVC GTPA408C - Alocação de Veículos para a escala

aG408Linha		:= {}
aG408Veic		:= {}

c408CodEscala	:= ""

nG408Oper		:= 0

Return()

/*/{Protheus.doc} MenuDef
	(long_description)
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 16/06/2017	
	@version version
	@param param, param_type, param_descr
	@return returno,return_type, Instância da classe FwFormView
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function MenuDef()

Local aRotina := {}	

ADD OPTION aRotina TITLE STR0014	Action "PesqBrw"         	OPERATION 1 ACCESS 0 	//"Pesquisar"
ADD OPTION aRotina TITLE STR0015 	Action 'GA408ExecView(1)' 	OPERATION 2 ACCESS 0 	//'VISUALIZAR'
ADD OPTION aRotina TITLE STR0017    Action "GA408Wizard(1)" 	OPERATION 3 ACCESS 0 	//"Assistente"
ADD OPTION aRotina TITLE STR0057    Action 'GA408Wizard(2)'	 	OPERATION 3 ACCESS 0	//"Copiar"
ADD OPTION aRotina TITLE STR0018    Action 'GA408Wizard(3)'  	OPERATION 4 ACCESS 0 	//'ALTERAR'
ADD OPTION aRotina TITLE STR0019	Action 'GA408ExecView(5)' 	OPERATION 5 ACCESS 0 	//'EXCLUIR'
ADD OPTION aRotina TITLE STR0020	Action 'TP408ButCop' 	 	OPERATION 9 ACCESS 0 	//'COPIAR'
ADD OPTION aRotina TITLE STR0059    Action "GTPR408A()" 		OPERATION 2 ACCESS 0 	// "Imprimir Escala de Veículos"
ADD OPTION aRotina TITLE STR0072    Action "GTPC408A()" 		OPERATION 2 ACCESS 0 	// "Divergências de Horários"
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} GA408VldStep()
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function GA408VldStep(cStep)

Local lRet	:= .t.

Do Case

	Case ( cStep == "2" )	//Segunda Página - Parâmetros para filtro

		If ( ValType(oG408AView) == "O" .And. oG408AView:ClassName() == "FWFORMVIEW")
			lRet := GA408FilterValidate(oG408AView:GetModel())
		EndIf

	Case ( cStep == "3" )	//Terceira Página - Montagem da Escala
		lRet := ValidStep('3')
	Case ( cStep == "4" )	//Quart Página - Seleção dos Veículos
		lRet := ValidStep('4')
EndCase

Return(lRet)


/*/{Protheus.doc} GA408FilterValidate
	Função de Validação do step 2 do wizard (filtro)
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 05/07/2017	
	@version version
	@param	oMdlStep2, objeto, instância da classe FWWizardStep
	@return	lRet, lógico, .t. - Step Validado
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GA408FilterValidate(oMdlStep2)

Local lRet	:= .t.
Local cMsgProb	:= ""
Local cMsgSolu	:= ""
Local cTitle	:= ""

cTitle := STR0021 //"Parametrização incompleta"

//Valida se o parâmetro 'Vigência de' foi digitado
If ( Empty(oMdlStep2:GetModel("MASTER"):GetValue("GY4_DATADE")) )
	
	lRet := .f.
	
	cMsgProb := STR0022 //"O campo Vigência de está em branco."
	cMsgSolu := STR0024	//"É necessário preencher o campo 'Vigência de'"

EndIf	

If ( lRet )
	
	//Valida se o parâmetro 'Vigência até' foi digitado
	If ( Empty(oMdlStep2:GetModel("MASTER"):GetValue("GY4_DATATE")) )

		lRet := .f.

		cMsgProb := STR0025 //"O campo Vigência até está em branco."
		cMsgSolu := STR0027	//"É necessário preencher o campo 'Vigência até'"

	EndIf	

EndIf

//Valida se a data final é inferior a data inicial
If ( lRet )

	If ( oMdlStep2:GetModel("MASTER"):GetValue("GY4_DATATE") < oMdlStep2:GetModel("MASTER"):GetValue("GY4_DATADE") )
	
		lRet := .f.

		cMsgProb := STR0028 //"O campo Vigência Final não pode ser inferior à Vigência Inicial."
		cMsgSolu := STR0029 //"Digite uma Vigência Final que seja igual ou superior"

	EndIf

EndIf

If ( lRet )
	
	IF oMdlStep2:GetModel("MASTER"):GetValue("GY4_DATATE") < dDataBase
		
		lRet := .f.
		
		cTitle		:= STR0056	//"Parametrização incorreta"
		cMsgProb 	:= STR0054 //"O campo Vigência Final não pode ser inferior à Data Base do Sistema."
		cMsgSolu 	:= STR0055 //"Digite uma Vigência Final que seja igual ou superior a Data Base do Sistema."
	
	EndIf

EndIf

If ( lRet )
	
	If ( oMdlStep2:GetModel("MASTER"):GetValue("GY4_FILTRO") == "1" )		//Setor
		
		//Valida se o parâmetro 'Setor' foi digitado no caso de 'Filtra por' seja 1-Setor
		If ( Empty(oMdlStep2:GetModel("MASTER"):GetValue("GY4_SETOR")) )

			lRet := .f.

			cMsgProb := STR0030 //"Se existe filtro por setor, ele não pode ficar em branco."
			cMsgSolu := STR0031 //"Preencha o campo 'Setor' para este tipo de filtro."

		EndIf

	ElseIf ( oMdlStep2:GetModel("MASTER"):GetValue("GY4_FILTRO") == "2" )	//Localidade
		
		//Valida se os parâmetros 'Localidades de' e 'Localidade ate' foram digitados
		If ( Empty(oMdlStep2:GetModel("MASTER"):GetValue("GY4_LOCDE")) .And. Empty(oMdlStep2:GetModel("MASTER"):GetValue("GY4_LOCATE")) )
			
			lRet := .f.

			cMsgProb := STR0033 //"Se existe filtro por localidade, as localidades não podem ficar em branco"
			cMsgSolu := STR0034 //"Preencha os campos 'Localidade de' e 'Localidade até', para este tipo de filtro."

		EndIf			
	
	EndIf

EndIf

If ( !lRet )
	FWAlertHelp(cMsgProb,cMsgSolu,cTitle)
EndIf

Return(lRet)


/*/{Protheus.doc} GA408ExecFilter()
	Executa o Filtro via query
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return returno,return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function GA408ExecFilter(cFields,oMdlMaster,cOrder,aFldConv)

Local cQuery	:= ""
Local cFldsAux	:= ""
Local cOrderBy	:= ""
Local cGroupBy  := ""
Local nI		:= 0
Local lRet		:= .t.
Local lTrecho	:= .f. //Select efetuado nos trechos da viagem
Local oMdlStep3	:= NIL

Default cFields 	:= "INTERNAL" 
Default	oMdlMaster	:= oG408AView:GetModel("MASTER")
Default cOrder		:= ""
Default aFldConv	:= {}

lTrecho := Iif( oMdlMaster:GetValue("GY4_TIPO") == "2", .t., .f.)	

If ( cFields == "INTERNAL" )
	
	aFldConv := {}
	oMdlStep3	:= FwLoadModel("GTPA408B")
	cFldsAux :=  GTPFld2Str(oMdlStep3:GetModel("SELECAO1"):GetStruct(),.t.,aFldConv) 
	
	cGroupBy := "GROUP BY " + cFldsAux + ",GI1ORI.GI1_COD,GI1ORI.GI1_DESCRI,GI1DES.GI1_COD,GI1DES.GI1_DESCRI "
	
	cFldsAux += ",GI1ORI.GI1_COD AS GID_LOCORI "
	cFldsAux += ",GI1ORI.GI1_DESCRI AS GID_DSCORI "
	cFldsAux += ",GI1DES.GI1_COD AS GID_LOCDES "
	cFldsAux += ",GI1DES.GI1_DESCRI AS GID_DSCDES "

	cOrderBy := " ORDER BY	GID.GID_COD, GID.GID_LINHA "
	oMdlStep3:Destroy()
Else
	
	cFldsAux :=	cFields
	
	cGroupBy := "GROUP BY " + cFields
	
	If ( At("ORDER BY",Upper(cOrder)) == 0 )
		cOrderBy := " ORDER BY " + cOrder
	Else
		cOrderBy := cOrder
	EndIf	

EndIf

cG408ResultSet := GetNextAlias()

cQuery := " SELECT " + CHR(13)
cQuery += "		'' LEGENDA, "+ CHR(13)
cQuery += "	" + cFldsAux  + CHR(13)
cQuery += "	FROM" + CHR(13)
cQuery += "	" + RetSQLName("GID") + " GID" + CHR(13)
cQuery += "	INNER JOIN" + CHR(13)
cQuery += "		" + RetSQLName("GIE") + " GIE" + CHR(13)
cQuery += "	ON" + CHR(13)
cQuery += "		GIE.D_E_L_E_T_ = ' ' " + CHR(13)
cQuery += "		AND GID.GID_FILIAL = GIE.GIE_FILIAL" + CHR(13)
cQuery += "		AND GID.GID_COD = GIE.GIE_CODGID" + CHR(13)
cQuery += "		AND GID.GID_SENTID = GIE.GIE_SENTID" + CHR(13)
cQuery += "		AND GID.GID_LINHA = GIE.GIE_LINHA" + CHR(13)
cQuery += "		AND GIE.GIE_HIST = '2' " + CHR(13)

cQuery += "		AND (" + CHR(13)
cQuery += "				GID.GID_DOM = 'T'" + CHR(13)
cQuery += "				OR GID.GID_SEG = 'T'" + CHR(13)
cQuery += "				OR GID.GID_TER = 'T'" + CHR(13)
cQuery += "				OR GID.GID_QUA = 'T'" + CHR(13)
cQuery += "				OR GID.GID_QUI = 'T'" + CHR(13)
cQuery += "				OR GID.GID_SEX = 'T'" + CHR(13)
cQuery += "				OR GID.GID_SAB = 'T'" + CHR(13)
cQuery += "		)" + CHR(13)

If ( oMdlMaster:GetValue("GY4_FILTRO") == "1" )		//Filtra por Setor

	If ( oMdlMaster:GetValue("GY4_TPFILT") == "1" )	//Tipo: Extremidades

		cQuery += "	AND ( " + chr(13)
		cQuery += "			GIE.GIE_IDLOCP IN " + chr(13)
		cQuery += "			( " + chr(13)
		cQuery += "				SELECT " + chr(13)
		cQuery += "					GY1_LOCAL " + chr(13)
		cQuery += "				FROM " + chr(13)
		cQuery += "					" + RetSQLName("GY1") + " GY1 " + chr(13)
		cQuery += "				INNER JOIN " + chr(13)
		cQuery += "					( " + chr(13)
		cQuery += "						SELECT " + chr(13)
		cQuery += "							MIN(GIE_SEQ) MIN_SEQ " + chr(13)
		cQuery += "						FROM " + chr(13)
		cQuery += "							" + RetSQLName("GIE") + " MINIMUM " + chr(13)
		cQuery += "						WHERE " + chr(13)
		cQuery += "							MINIMUM.GIE_FILIAL = GIE.GIE_FILIAL " + chr(13)
		cQuery += "							AND MINIMUM.GIE_CODGID = GIE.GIE_CODGID " + chr(13)
		cQuery += "							AND MINIMUM.GIE_HIST = '2' " + chr(13)
		cQuery += "							AND MINIMUM.D_E_L_E_T_ = ' ' " + chr(13)
		cQuery += "					) MIN_GIE " + chr(13)
		cQuery += "				ON " + chr(13)
		cQuery += "					GIE.GIE_SEQ = MIN_GIE.MIN_SEQ " + chr(13)
		cQuery += "				WHERE " + chr(13)
		cQuery += "					GY1_FILIAL = '" + xFilial("GY1") + "' " + chr(13)
		cQuery += "					AND GY1.D_E_L_E_T_ = ' ' " + chr(13)
		cQuery += "					AND GY1_SETOR = '" + oMdlMaster:GetValue("GY4_SETOR") + "' " + chr(13)
		cQuery += "			) " + chr(13)
		cQuery += "			OR " + chr(13)
		cQuery += "			GIE_IDLOCD IN " + chr(13)
		cQuery += "			( " + chr(13)
		cQuery += "				SELECT " + chr(13)
		cQuery += "					GY1_LOCAL " + chr(13)
		cQuery += "				FROM " + chr(13)
		cQuery += "					" + RetSQLName("GY1") + " GY1 " + chr(13)
		cQuery += "				INNER JOIN " + chr(13)
		cQuery += "					( " + chr(13)
		cQuery += "						SELECT " + chr(13)
		cQuery += "							MAX(GIE_SEQ) MAX_SEQ " + chr(13)
		cQuery += "						FROM " + chr(13)
		cQuery += "							" + RetSQLName("GIE") + " MAXIMUM " + chr(13)
		cQuery += "						WHERE " + chr(13)
		cQuery += "							MAXIMUM.GIE_FILIAL = GIE.GIE_FILIAL " + chr(13)
		cQuery += "							AND MAXIMUM.GIE_CODGID = GIE.GIE_CODGID " + chr(13)
		cQuery += "							AND MAXIMUM.GIE_HIST = '2' " + chr(13)
		cQuery += "							AND MAXIMUM.D_E_L_E_T_ = ' ' " + chr(13)
		cQuery += "					) MAX_GIE " + chr(13)
		cQuery += "				ON " + chr(13)
		cQuery += "					GIE.GIE_SEQ = MAX_GIE.MAX_SEQ " + chr(13)
		cQuery += "				WHERE " + chr(13)
		cQuery += "					GY1_FILIAL = '" + xFilial("GY1") + "' " + chr(13)
		cQuery += "					AND GY1.D_E_L_E_T_ = ' ' " + chr(13)
		cQuery += "					AND GY1_SETOR = '" + oMdlMaster:GetValue("GY4_SETOR") + "' " + chr(13)
		cQuery += "			) " + chr(13)
		cQuery += "	) " + chr(13)
		
	Else
												//Tipo: Todos os Trechos
		cQuery += "	AND ( " + chr(13)
		cQuery += "			GIE_IDLOCP IN " + chr(13)
		cQuery += "			( " + chr(13)
		cQuery += "				SELECT " + chr(13)
		cQuery += "					GY1_LOCAL " + chr(13)
		cQuery += "				FROM " + chr(13)
		cQuery += "					" + REtSQLName("GY1") + " GY1 " + chr(13) 
		cQuery += "				WHERE " + chr(13)
		cQuery += "					GY1_FILIAL = '" + xFilial("GY1") + "' " + chr(13)
		cQuery += "					AND GY1.D_E_L_E_T_ = ' ' " + chr(13)
		cQuery += "					AND GY1_SETOR = '" + oMdlMaster:GetValue("GY4_SETOR") + "' " + chr(13)
		cQuery += "			) " + chr(13)
		cQuery += "			OR " + chr(13)
		cQuery += "			GIE_IDLOCD IN " + chr(13)
		cQuery += "			( " + chr(13)
		cQuery += "				SELECT " + chr(13)
		cQuery += "					GY1_LOCAL " + chr(13)
		cQuery += "				FROM " + chr(13)
		cQuery += "					" + REtSQLName("GY1") + " GY1 " + chr(13)
		cQuery += "				WHERE " + chr(13)
		cQuery += "					GY1_FILIAL = '" + xFilial("GY1") + "' " + chr(13)
		cQuery += "					AND GY1.D_E_L_E_T_ = ' ' " + chr(13)
		cQuery += "					AND GY1_SETOR = '" + oMdlMaster:GetValue("GY4_SETOR") + "' " + chr(13)
		cQuery += "			) " + chr(13)
		cQuery += "		) " + chr(13)
	
	EndIf

ElseIf ( oMdlMaster:GetValue("GY4_FILTRO") == "2" )	//Filtra por Localidade

	If ( oMdlMaster:GetValue("GY4_TPFILT") == "1" )	//Tipo: Extremidades
		If ( !Empty(oMdlMaster:GetValue("GY4_LOCDE")) .Or. !Empty(oMdlMaster:GetValue("GY4_LOCATE")) )
			cQuery += "	AND GIE_CODGID IN (" + chr(13)
	
			//'Partindo de e 'Chegando em' estão preenchidos
			If ( !Empty(oMdlMaster:GetValue("GY4_LOCDE")) .And. !Empty(oMdlMaster:GetValue("GY4_LOCATE")) )
	
				cQuery += "	SELECT " + chr(13) 
				cQuery += "		MIN_GIE.GIE_CODGID " + chr(13)
				cQuery += "	FROM
				cQuery += "		" + RetSQLName("GIE") + " MIN_GIE " + chr(13)
				cQuery += "	INNER JOIN " + chr(13)
				cQuery += "		( " + chr(13)
				cQuery += "			SELECT " + chr(13) 
				cQuery += "				B.GIE_CODGID " + chr(13)
				cQuery += "			FROM " + chr(13)
				cQuery += "				" + RetSQLName("GIE") + " B " + chr(13)
				cQuery += "			WHERE " + chr(13)
				cQuery += "				GIE_FILIAL = '" + xFilial("GIE") + "' " + chr(13)
				cQuery += "				AND GIE_IDLOCD = '" + oMdlMaster:GetValue("GY4_LOCATE") + "' " + chr(13)
				cQuery += "				AND GIE_SEQ =  " + chr(13)
				cQuery += "				( " + chr(13)
				cQuery += "					SELECT  " + chr(13)
				cQuery += "						MAX(GIE_SEQ)  " + chr(13)
				cQuery += "					FROM  " + chr(13)
				cQuery += "						" + RetSQLName("GIE") + " A  " + chr(13)
				cQuery += "					WHERE  " + chr(13)
				cQuery += "						A.D_E_L_E_T_ = ' '  " + chr(13)
				cQuery += "						AND A.GIE_FILIAL = '" + xFilial("GIE") + "' " + chr(13)
				cQuery += "						AND A.GIE_CODGID = B.GIE_CODGID " + chr(13)
				cQuery += "				) " + chr(13)
				cQuery += "				AND B.D_E_L_E_T_ = ' '  " + chr(13)
				cQuery += "		) MAX_GIE " + chr(13)
				cQuery += "	ON " + chr(13)
				cQuery += "		MIN_GIE.GIE_CODGID = MAX_GIE.GIE_CODGID " + chr(13)
				cQuery += "	WHERE " + chr(13)
				cQuery += "		MIN_GIE.GIE_FILIAL = '" + xFilial("GIE") + "' " + chr(13)
				cQuery += "		AND MIN_GIE.GIE_IDLOCP = '" + oMdlMaster:GetValue("GY4_LOCDE") + "' " + chr(13)
				cQuery += "		AND MIN_GIE.GIE_SEQ = '001' " + chr(13)
				cQuery += "		AND MIN_GIE.D_E_L_E_T_ = ' ' " + chr(13)
	
			//'Partindo de' preenchido e 'Chegando em' não está preenchido
			ElseIf ( !Empty(oMdlMaster:GetValue("GY4_LOCDE")) .And. Empty(oMdlMaster:GetValue("GY4_LOCATE")) )
	
				cQuery += "	SELECT " + chr(13) 
				cQuery += "		MIN_GIE.GIE_CODGID " + chr(13)
				cQuery += "	FROM " + chr(13)
				cQuery += "		" + RetSQLName("GIE") + " MIN_GIE " + chr(13)
				cQuery += "	WHERE " + chr(13)
				cQuery += "		MIN_GIE.GIE_FILIAL = '" + xFilial("GIE") + "' " + chr(13)
				cQuery += "		AND MIN_GIE.GIE_IDLOCP = '" + oMdlMaster:GetValue("GY4_LOCDE") + "' " + chr(13)
				cQuery += "		AND MIN_GIE.GIE_SEQ = '001' " + chr(13)
				cQuery += "		AND MIN_GIE.D_E_L_E_T_ = ' ' " + chr(13)
	
			//'Partindo de' não está preenchido e 'Chegando em' está preenchido
			ElseIf ( Empty(oMdlMaster:GetValue("GY4_LOCDE")) .And. !Empty(oMdlMaster:GetValue("GY4_LOCATE")) )
	
				cQuery += "	SELECT " + chr(13)
				cQuery += "		MAX_GIE.GIE_CODGID " + chr(13)
				cQuery += "	FROM " + chr(13)
				cQuery += "		" + RetSQLName("GIE") + " MAX_GIE " + chr(13)
				cQuery += "	WHERE " + chr(13)
				cQuery += "		MAX_GIE.GIE_FILIAL = '" + xFilial("GIE") + "' " + chr(13)
				cQuery += "		AND MAX_GIE.GIE_IDLOCD = '" + oMdlMaster:GetValue("GY4_LOCATE") + "' " + chr(13)
				cQuery += "		AND MAX_GIE.GIE_SEQ =  " + chr(13)
				cQuery += "		( " + chr(13)
				cQuery += "			SELECT  " + chr(13)
				cQuery += "				MAX(GIE_SEQ)  " + chr(13)
				cQuery += "			FROM  " + chr(13)
				cQuery += "				" + RetSQLName("GIE") + " A  " + chr(13)
				cQuery += "			WHERE  " + chr(13)
				cQuery += "				A.D_E_L_E_T_ = ' '  " + chr(13)
				cQuery += "				AND A.GIE_FILIAL = '" + xFilial("GIE") + "' " + chr(13)
				cQuery += "				AND A.GIE_CODGID = MAX_GIE.GIE_CODGID " + chr(13)
				cQuery += "		) " + chr(13)
				cQuery += "		AND MAX_GIE.D_E_L_E_T_ = ' ' " + chr(13)
	
			EndIf
	
			cQuery += ") " + chr(13)			
		Endif
		
	Else	//Tipo: Todos os Trechos
		//'Partindo de' e 'Chegando em' preenhcidos
		If ( !Empty(oMdlMaster:GetValue("GY4_LOCDE")) .And. !Empty(oMdlMaster:GetValue("GY4_LOCATE")) )
			cQuery += "	AND ( GIE_IDLOCP = '" + oMdlMaster:GetValue("GY4_LOCDE") + "' OR GIE_IDLOCD = '" + oMdlMaster:GetValue("GY4_LOCATE") + "') " + chr(13)
		//'Partindo de' preenchido e 'Chegando em' em branco
		ElseIf ( !Empty(oMdlMaster:GetValue("GY4_LOCDE")) .And. Empty(oMdlMaster:GetValue("GY4_LOCATE")) )
			cQuery += "	AND  GIE_IDLOCP = '" + oMdlMaster:GetValue("GY4_LOCDE") + "' " + chr(13)
		//'Partindo de' em branco e 'Chegando em' preenchido
		ElseIf ( Empty(oMdlMaster:GetValue("GY4_LOCDE")) .And. !Empty(oMdlMaster:GetValue("GY4_LOCATE")) )
			cQuery += "	AND  GIE_IDLOCD = '" + oMdlMaster:GetValue("GY4_LOCATE") + "' " + chr(13)
		EndIf

	EndIf
ElseIf ( oMdlMaster:GetValue("GY4_FILTRO") == "3" )	//Filtra por Serviço
	cQuery += "	AND GID_NUMSRV = '" + oMdlMaster:GetValue("GY4_NUMSRV") + "' " + chr(13)
EndIf
If ( cFields == "INTERNAL" )
	cQuery += "	INNER JOIN " + RetSQLName("GI1") + " GI1ORI ON " + chr(13)
	cQuery += "			GI1ORI.GI1_FILIAL = '" + xFilial("GI1") + "'  " + chr(13)
	cQuery += "			AND GI1ORI.GI1_COD = ( " + chr(13)
	cQuery += "		Select GIE_IDLOCP from " + RetSQLName("GIE") + " GIE " + chr(13)
	cQuery += "			INNER JOIN (	 " + chr(13)
	cQuery += "					SELECT MIN(GIE_SEQ) MIN_SEQ " + chr(13)
	cQuery += "					FROM " + RetSQLName("GIE") + " GIE " + chr(13)
	cQuery += "					WHERE GIE.D_E_L_E_T_ = ' '  " + chr(13)
	cQuery += "						AND GID.GID_FILIAL = GIE.GIE_FILIAL " + chr(13)
	cQuery += "						AND GID.GID_COD = GIE.GIE_CODGID " + chr(13)
	cQuery += "						AND GID.GID_SENTID = GIE.GIE_SENTID " + chr(13)
	cQuery += "						AND GID.GID_LINHA = GIE.GIE_LINHA " + chr(13)
	cQuery += "						AND GIE.GIE_HIST = '2'  " + chr(13)
	cQuery += "					) MINGIE ON " + chr(13)
	cQuery += "					GIE_SEQ = MINGIE.MIN_SEQ " + chr(13)
	cQuery += "						AND GID.GID_FILIAL = GIE.GIE_FILIAL " + chr(13)
	cQuery += "						AND GID.GID_COD = GIE.GIE_CODGID " + chr(13)
	cQuery += "						AND GID.GID_SENTID = GIE.GIE_SENTID " + chr(13)
	cQuery += "						AND GID.GID_LINHA = GIE.GIE_LINHA " + chr(13)
	cQuery += "						AND GIE.GIE_HIST = '2'  " + chr(13)
	cQuery += "						AND GIE.D_E_L_E_T_ = ' '  " + chr(13)
	cQuery += "				) " + chr(13)
	cQuery += "			AND GI1ORI.D_E_L_E_T_ = ' ' " + chr(13)
    cQuery += "	 " + chr(13)
	cQuery += "		INNER JOIN " + RetSQLName("GI1") + " GI1DES ON " + chr(13)
	cQuery += "			GI1DES.GI1_FILIAL = '" + xFilial("GI1") + "'  " + chr(13)
	cQuery += "			AND GI1DES.GI1_COD = ( " + chr(13)
	cQuery += "		Select GIE_IDLOCD from " + RetSQLName("GIE") + " GIE " + chr(13)
	cQuery += "					INNER JOIN (	 " + chr(13)
	cQuery += "								SELECT MAX(GIE_SEQ) MAX_SEQ " + chr(13)
	cQuery += "								FROM " + RetSQLName("GIE") + " GIE " + chr(13)
	cQuery += "								WHERE GIE.D_E_L_E_T_ = ' '  " + chr(13)
	cQuery += "									AND GID.GID_FILIAL = GIE.GIE_FILIAL " + chr(13)
	cQuery += "									AND GID.GID_COD = GIE.GIE_CODGID " + chr(13)
	cQuery += "									AND GID.GID_SENTID = GIE.GIE_SENTID " + chr(13)
	cQuery += "									AND GID.GID_LINHA = GIE.GIE_LINHA " + chr(13)
	cQuery += "									AND GIE.GIE_HIST = '2'  " + chr(13)
	cQuery += "								)  " + chr(13)
	cQuery += "						MAXGIE	ON " + chr(13)
	cQuery += "						GIE_SEQ = MAXGIE.MAX_SEQ " + chr(13)
	cQuery += "						AND GID.GID_FILIAL = GIE.GIE_FILIAL " + chr(13)
	cQuery += "							AND GID.GID_COD = GIE.GIE_CODGID " + chr(13)
	cQuery += "							AND GID.GID_SENTID = GIE.GIE_SENTID " + chr(13)
	cQuery += "							AND GID.GID_LINHA = GIE.GIE_LINHA " + chr(13)
	cQuery += "							AND GIE.GIE_HIST = '2'  " + chr(13)
	cQuery += "							AND GIE.D_E_L_E_T_ = ' '   " + chr(13)
	cQuery += "	) " + chr(13)
	cQuery += "	AND GI1DES.D_E_L_E_T_ = ' ' " + chr(13)
Endif
cQuery += "	WHERE" + CHR(13)
cQuery += "		GID.GID_FILIAL = '" + XFilial("GID") + "' " + CHR(13)
cQuery += "		AND (( '" + DToS(oMdlMaster:GetValue("GY4_DATADE")) + "' BETWEEN GID.GID_INIVIG AND GID.GID_FINVIG " + CHR(13)
cQuery += "			OR '" + DToS(oMdlMaster:GetValue("GY4_DATATE")) + "' BETWEEN GID.GID_INIVIG AND GID.GID_FINVIG ) "  + CHR(13)
cQuery += "		OR ( GID.GID_INIVIG >= '" + DToS(oMdlMaster:GetValue("GY4_DATADE")) + "' AND " + CHR(13)
cQuery += "			GID.GID_FINVIG <= '" + DtoS(oMdlMaster:GetValue("GY4_DATATE")) + "')) " + CHR(13)

cQuery += "		AND GID.GID_HIST = '2' " + CHR(13)
cQuery += "		AND GID.D_E_L_E_T_ = ' ' " + CHR(13)
cQuery += "	" + cGroupBy
cQuery += "	" + cOrderBy

cQuery := ChangeQuery(cQuery)

dbUseArea (.T., "TOPCONN", TcGenQry(,,cQuery),cG408ResultSet, .T., .T.)

For nI := 1 to Len(aFldConv)	
	TCSetField(cG408ResultSet,aFldConv[nI,1],aFldConv[nI,2],aFldConv[nI,3])
Next nI

lRet := (cG408ResultSet)->(!Eof())

Return(lRet)

/*/{Protheus.doc} GA408ResultSet
	Retorna o alias do arquivo do resultset
	@type  Function
	@author Fernando Radu Muscalu
	@since 05/07/2017
	@version version
	@param 
	@return cG408ResultSet, caractere, variável estática cG408ResultSet
	@example
	(examples)
	@see (links_or_references)
/*/
Function GA408ResultSet()
Return(cG408ResultSet)

/*/{Protheus.doc} G408AGetModel()
    (long_description)
    @type Function
    @author Fernando Radu Muscalu
    @since 13/06/2017
    @version version
    @param  
    @return oG408AModel, objeto, Instãncia da Classe FwFormModel - variável estática deste fonte
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA408GetModel(cIdModel)

Local oModel

Do Case
Case ( cIdModel == "GTPA408A" )

	If ( Valtype(oG408AView) == "O" )
		oModel := oG408AView:GetModel()
	EndIf

Case ( cIdModel == "GTPA408B" )
	
	If ( Valtype(oG408BView) == "O" )
		oModel := oG408BView:GetModel()
	EndIf

Case ( cIdModel == "GTPA408C" )
	
	If ( Valtype(oG408CView) == "O" )
		oModel := oG408CView:GetModel()
	EndIf

End Case

Return(oModel)

/*/{Protheus.doc} G408AGetModel()
    (long_description)
    @type Function
    @author Fernando Radu Muscalu
    @since 13/06/2017
    @version version
    @param  
    @return oG408AModel, objeto, Instãncia da Classe FwFormModel - variável estática deste fonte
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA408GetView(cIdView)

Local oView

Do Case
Case ( cIdView == "GTPA408A" )

	If ( Valtype(oG408AView) == "O" )
		oView := oG408AView
	EndIf

Case ( cIdView == "GTPA408B" )
	
	If ( Valtype(oG408BView) == "O" )
		oView := oG408BView
	EndIf

Case ( cIdView == "GTPA408C" )
	
	If ( Valtype(oG408CView) == "O" )
		oView := oG408CView
	EndIf

End Case

Return(oView)

/*/{Protheus.doc} ValidStep
Valida ok do step
@type function
@author Fernando Amorim(Cafu)
@since 07/07/2017
@version 12.1.16
/*/
Static Function ValidStep(cStep)

Local lRet 		:= .T.
Local oModel	:= Nil
Local oMdlCab	:= Nil
Local oMdlSel2	:= Nil
Local oMdlVeic	:= Nil
Local nX		:= 0
Local lMarcVeic := .F.
Local aCaraclin := {}

If cStep == '3'
	
	oModel		:= GA408GetModel("GTPA408B")	
	oMdlCab		:= oModel:GetModel( 'CABESC' )
	oMdlSel2	:= oModel:GetModel( 'SELECAO2' )
	
	If Empty(oMdlCab:GetValue( 'ESCALA' )) .Or. Empty(oMdlCab:GetValue( 'DESCRICAO')) .or. Empty(oMdlCab:GetValue("LOCALMANUT"))
		lRet := .F.
		FwAlertHelp(STR0047,STR0046) //'Informe os campos obrigatórios'
	EndIf
	if oMdlSel2:IsEmpty() .Or. ( oMdlSel2:Length() == 1 .and. Empty(oMdlSel2:GetValue( 'GID_LINHA' )))
		lRet := .F.
		FwAlertHelp(STR0049,STR0048)	 //'Informe ao menos 1 horário'		
	Endif
	
	If lRet
		aG408Linha 	:= {}
		aCaraclin	:= {}
		aG408Veic 	:= {}
		
		For nX:= 1 To oMdlSel2:Length()
			oMdlSel2:GoLine(nX)
			If ascan(aG408Linha,oMdlSel2:GetValue('GID_LINHA')) <= 0
				aAdd(aG408Linha,oMdlSel2:GetValue('GID_LINHA'))
			Endif
		Next nX

		For nX := 1 to Len(aG408Linha)
			aCaraclin	:= CaracLin(aG408Linha[nX],@aCaraclin)			
		Next nX 

		If Len(aG408Linha) > 0 //.And. len(aCaraclin) > 0
			aG408Veic 	:= CaracVeic(aCaraclin)
		Endif
	Endif

Elseif cStep == '4'

	oModel		:= GA408GetModel("GTPA408C")	
	oMdlVeic	:= oModel:GetModel( 'VEICULO' )

	lMarcVeic := .F.
	lRet 	  := .T.
		
	If ( oMdlVeic:Length() >= GA408GetModel("GTPA408B"):GetModel("SELECAO2"):MaxValueField("G52DIA") )
	
		For nX:= 1 To oMdlVeic:Length()
			oMdlVeic:GoLine(nX)
			If oMdlVeic:GetValue('CHECKVEI')
				lMarcVeic := .T.
				Exit
			Endif
		Next nX
		
		If !lMarcVeic
			lRet := .F.
			FwAlertHelp(STR0051,STR0052) //"VEÍCULO","Marque pelo menos um veículo para escala."
		Endif						
	Else
	
		lRet := .F.
		FwAlertHelp(STR0063, STR0064, I18N(STR0065, {cValToChar(GA408GetModel("GTPA408B"):GetModel("SELECAO2"):MaxValueField("G52DIA"))}))	// "Não é possível finalizar o cadastro da escala."	// "Uma escala não pode possuir menos veículos do que a quantidade de dias estipulada.	// "Neste caso seria #1 veículos a menos."
		
	EndIf
	
Endif

If lRet // SetKey adicionado como solução de contorno de automação TIR (método ClickImage não está funcionando)
	SetKey( VK_F5 ,{|| } ) 
	SetKey( VK_F6 ,{|| } ) 
	SetKey( VK_F7 ,{|| } ) 
	SetKey( VK_F8 ,{|| } ) 
Endif

Return lRet

/*/{Protheus.doc} CaracLin
Valida ok do step
@type function
@author Fernando Amorim(Cafu)
@since 12/07/2017
@version 12.1.16
/*/
Static Function CaracLin(cLinha,aCaraclin)
Local cAliasCl	:= GetNextAlias()
Local aRetCarac	:= aCaraclin

BeginSQL Alias cAliasCl

	SELECT G9D_CODCAR
	FROM %Table:G9D% G9D
	WHERE G9D_FILIAL = %xFilial:G9D%
	AND G9D_CODLIN = %Exp:cLinha%
	AND %NotDel%
	
EndSQL
		
While !(cAliasCl)->(EOF())
	If ascan(aCaraclin,(cAliasCl)->G9D_CODCAR) <=0
		aAdd(aRetCarac,(cAliasCl)->G9D_CODCAR)
	Endif	
	(cAliasCl)->(DbSkip())
	
End
Return aRetCarac

/*/{Protheus.doc} GA408CallNextStep()
	Função que checa se há necessidade de executar novamente o Filtro de acordo com os parâmetros 
	do step 1
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 13/07/2017
	@version version
	@param cStep, caractere, string com o nro do step do wizard que será chamado a seguir
	@return .t., lógico, sempre verdadeiro
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GA408CallNextStep(cStep)

Local lRet 	:= .f.
Local lExec	:= .f.

If ( cStep == "3" )

	If ( !Empty(cG408ResultSet) )
		
		(cG408ResultSet)->(DbGoTop())
		If nG408Oper == 1
			lExec := MsgYesNo(STR0053) //"Os horários já foram filtrados anteriormente. Deseja filtrá-los novamente?"
		Endif	
		If ( lExec )

			G408RSetDestroy()//(cG408ResultSet)->(DbCloseArea())

			lRet := GA408ExecFilter()

			If ( Valtype(oG408BView) == "O" .And. oG408BView:IsActive() )
				GA408ResetStep("3")
			EndIf	

		Else
			lRet := .t.
		EndIf
	
	ElseIf ( Empty(cG408ResultSet) )
		lRet := GA408ExecFilter()
	EndIf

EndIf

If ( cStep == "4" )
	If ( Valtype(oG408CView) == "O" .And. oG408CView:IsActive() )
		GA408ResetStep("4")
	EndIf	
Endif
Return(.t.)

/*/{Protheus.doc} GA408ResetStep()
	Refaz a view de acordo com o step passado pelo parâmetro
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 13/07/2017
	@version version
	@param cStep, caractere, string com o nro do step do wizard que será chamado a seguir
	@return nil, nulo, sem retorno
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GA408ResetStep(cStep)

Do Case 
Case ( cStep == "3")
	
	oG408BView:GetModel():DeActivate()
	oG408BView:GetModel():Activate()
	oG408BView:Refresh()

Case ( cStep == "4" )
	
	oG408CView:GetModel():DeActivate()
	oG408CView:GetModel():Activate()
	oG408CView:Refresh()

End Case

Return()

/*/{Protheus.doc} CaracVeic
Valida ok do step
@type function
@author Fernando Amorim(Cafu)
@since 12/07/2017
@version 12.1.16
/*/

Static Function CaracVeic(aCaraclin)
Local cAliasVei	:= GetNextAlias()
//Local aRetCarac	:= {}
Local nX		:= 0	
Local cCaracts	:= ''
Local cWhere	:= ''


If len(aCaraclin) > 0
	For nX := 1 to Len(aCaraclin)
		cCaracts += "'"+aCaraclin[nX] +"'" + ','
	Next nX
	cCaracts := SubStr(cCaracts,1,len(cCaracts)-1)
	
	cWhere   += "% TB_CARACTE IN ( " + cCaracts + " ) AND %"
	
	BeginSQL Alias cAliasVei
		
		SELECT
		TAB2.CONT,TAB1.TB_CODBEM
		FROM
		(
		SELECT
		 
			TB_CARACTE,
			TB_CODBEM
		FROM 
			%Table:STB% STB 		
		INNER JOIN 
			%Table:ST9% ST9
		ON
		ST9.T9_FILIAL = %xFilial:ST9%
		AND	ST9.T9_FILIAL = STB.TB_FILIAL
		AND	ST9.T9_CODBEM = STB.TB_CODBEM
		AND T9_CATBEM IN ('2','4')
		AND ST9.%NotDel%		
		WHERE
			TB_FILIAL = %xFilial:STB% 
			AND  %Exp:cWhere% 
			STB.%NotDel% 
			 ) TAB1,
		(
		SELECT
			TB_CODBEM,
		    count(*) CONT
		FROM 
			%Table:STB% STB
		INNER JOIN 
			%Table:ST9% ST9
		ON
		ST9.T9_FILIAL = %xFilial:ST9%
		AND	ST9.T9_FILIAL = STB.TB_FILIAL
		AND	ST9.T9_CODBEM = STB.TB_CODBEM
		AND T9_CATBEM IN ('2','4')
		AND ST9.%NotDel%
		WHERE	
			TB_FILIAL = %xFilial:STB% 
			AND  %Exp:cWhere% 
			STB.%NotDel%
			
		GROUP BY  TB_CODBEM) TAB2
		WHERE
			TAB1.TB_CODBEM = TAB2.TB_CODBEM AND
			TAB1.TB_CODBEM IS NOT NULL
			GROUP BY TAB1.TB_CODBEM,TAB2.CONT
		HAVING TAB2.CONT >= %Exp:Len(aCaraclin)%
		
	EndSQL
Else

	BeginSQL Alias cAliasVei
	
	SELECT		 
		TB_CARACTE,
		TB_CODBEM
	FROM 
		%Table:STB% STB 		
	INNER JOIN 
		%Table:ST9% ST9
	ON
		ST9.T9_FILIAL = %xFilial:ST9%
		AND	ST9.T9_FILIAL = STB.TB_FILIAL
		AND	ST9.T9_CODBEM = STB.TB_CODBEM
		AND T9_CATBEM IN ('2','4')
		AND ST9.%NotDel%		
	WHERE
		TB_FILIAL = %xFilial:STB% 
		AND STB.%NotDel% 

	EndSQL
Endif
		
While !(cAliasVei)->(EOF())
	If ascan(aG408Veic,(cAliasVei)->TB_CODBEM) <=0
		If VldVeicLin((cAliasVei)->TB_CODBEM)
			aAdd(aG408Veic,(cAliasVei)->TB_CODBEM)
		Endif
	Endif
	(cAliasVei)->(DbSkip())
	
End
Return aG408Veic

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetaVeic
	Busca o array static aG408Veic
@since		13/07/2017       
@version	P12
/*/
//------------------------------------------------------------------------------
Function GetaVeic()

Return aG408Veic

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetCodEscala
	Busca o o codigo da escala
@since		13/07/2017       
@version	P12
/*/
//------------------------------------------------------------------------------
Function GetCodEscala()

Return c408CodEscala

//------------------------------------------------------------------------------
/*/{Protheus.doc} GA408Commit
	Grava escala e dependencias
@author Fernando Amorim(Cafu)
@since		13/07/2017       
@version	P12
/*/
//------------------------------------------------------------------------------
Function GA408Commit()

Local lRet  := .T.
Local lPerCom 		:= .T.

Local oModel408E 	:= FWLOADModel('GTPA408E')
Local oModel408C 	:= GA408GetModel('GTPA408C')
Local oModel408A	:= GA408GetModel('GTPA408A')
Local oModel408B 	:= GA408GetModel('GTPA408B')
Local oMdlVei	 	:= oModel408C:GetModel( 'VEICULO' ) 
Local oMdlSel2	 	:= oModel408B:GetModel( 'SELECAO2' ) 
Local oMdlCab		:= oModel408B:GetModel( 'CABESC'   )
Local oMdlG52		:= Nil	
Local oMdlGQA		:= Nil
Local oMdlGZQ		:= Nil	
Local oMdlMstr		:= Nil
Local oMdlGY4		:= Nil

Local aFldMdl		:= {}
Local aFldGID		:= {}
Local aUpd			:= {}
Local aLinha		:= {}
Local aSeek			:= {}

Local nX		 	:= 0
Local nI			:= 0

Local cRetErr		:= ''	
Local cAltDel		:= ''	
Local cSetorG		:= ''
Local cConfSXE		:= .T.
	
oModel408E:SetOperation(MODEL_OPERATION_INSERT)
oModel408E:Activate()

oMdlG52	 	:= oModel408E:GetModel( 'G52DETAIL' )
oMdlMstr 	:= oModel408E:GetModel( "MASTER" )
oMdlGY4		:= oModel408E:GetModel( "GY4DETAIL" )
oMdlGZQ		:= oModel408E:GetModel( "GZQDETAIL" )

lRet := oMdlMstr:SetValue( "G52_CODIGO"	, oMdlCab:GetValue('ESCALA') ) .And. ;
		oMdlMstr:SetValue( "G52_DESCRI"	, oMdlCab:GetValue('DESCRICAO')) 

cAltDel := oMdlCab:GetValue('ESCALA')
cSetorG := oModel408A:GetModel("MASTER"):GetValue("GY4_SETOR")

If ( lRet )

	For nX := 1 To oMdlSel2:Length()

		oMdlSel2:GoLine( nX )

		If !oMdlG52:IsEmpty()

			lRet := oMdlG52:Length() < oMdlG52:AddLine()

		endif

		If ( lRet )
			
			lRet := oMdlG52:SetValue( "G52_FILIAL"	, xFilial('G52') ) .And. ;
					oMdlG52:SetValue( "G52_CODIGO"	, oMdlCab:GetValue('ESCALA') ) .And. ;
					oMdlG52:SetValue( "G52_DESCRI"	, oMdlCab:GetValue('DESCRICAO') )
					
			If ( lRet )
				
				aFldGID := oMdlSel2:GetStruct():GetFields()
				
				For nI := 1 to Len(aFldGID)
					
					aUpd := GA408RetDePara(aFldGID[nI,3], oMdlSel2)
					
					If ( Len(aUpd) > 0 )
					
						If ( oMdlG52:HasField(aUpd[1]) )
							
							If ( "PMANUT" $ aFldGID[nI,3] ) 
								
								TPNomeLinh(oMdlSel2:GetValue("GID_LINHA",nX),aLinha,oMdlSel2:GetValue("GID_SENTID",nX))
								
								If (  Alltrim(aLinha[1,2][2,1]) == Alltrim(oMdlCab:GetValue("LOCALMANUT")) )
									aUpd[2] := "1"
								Else	
									aUpd[2] := "2"
								EndIf
							
							ElseIf ( "G52SEC"  $ aFldGID[nI,3] )
								aUpd[2] := Iif(Empty(aUpd[2]),"2",aUpd[2])		
							EndIf
							
							lRet := oMdlG52:SetValue(aUpd[1],aUpd[2])
									
						EndIf
							
					EndIf
					
					If ( !lRet )
						Exit
					EndIf	
						
				Next nI
				
			EndIf	

		Else
			Exit
		EndIf
		
		If ( lRet )
			
			If ( oMdlSel2:GetValue("G52SEC") == "1" )
				
				aUpd	:= {{"GIE_SEQ"}}
				aSeek	:= {}
				
				aAdd(aSeek,{"GIE_CODGID",oMdlSel2:GetValue("GID_COD")})
				aAdd(aSeek,{"GIE_IDLOCP",oMdlSel2:GetValue("G52SECINI")})
				aAdd(aSeek,{"GIE_IDLOCD",oMdlSel2:GetValue("G52SECFIM")})				
				
				If ( GTPSeekTable("GIE",aSeek,aUpd) )
								
					lRet := oMdlGZQ:SetValue("GZQ_ESCALA",oMdlCab:GetValue('ESCALA')) .And.;
							oMdlGZQ:SetValue("GZQ_SEQESC",oMdlSel2:GetValue("G52SEC")) .And.;
							oMdlGZQ:SetValue("GZQ_SERVIC",oMdlSel2:GetValue("GID_COD")) .And.;
							oMdlGZQ:SetValue("GZQ_SEQSER",aUpd[2,1])
				Else
					lRet := .f.
				EndIf
								
			EndIf
			
		EndIf
		
		If ( !lRet )
			Exit
		EndIf
		
			
	Next nX

EndIf

If ( lRet )

	oMdlGQA	 := oModel408E:GetModel( 'GQADETAIL' )

	For nX := 1 To oMdlVei:Length()

		oMdlVei:GoLine( nX )

		If ( oMdlVei:GetValue("CHECKVEI") )

			If !oMdlGQA:IsEmpty()
				lRet := oMdlGQA:Length() < oMdlGQA:AddLine()
			endif

			If ( lRet )
			
				lRet := oMdlGQA:SetValue( "GQA_FILIAL"	, xFilial('GQA')) .And.;
						oMdlGQA:SetValue( "GQA_CODESC"	, oMdlCab:GetValue('ESCALA') ) .And.;
						oMdlGQA:SetValue( "GQA_CODVEI"	, oMdlVei:GetValue('VEICULO') ) .And.;
						oMdlGQA:SetValue( "GQA_DESVEI"	, oMdlVei:GetValue('DESCRICAO') ) 	
			
			EndIf

			If ( !lRet )
				Exit
			EndIf

		EndIf

	Next nX

EndIf

If ( lRet )

	aFldMdl := oMdlGY4:GetStruct():GetFields()
	
	lRet := oMdlGY4:SetValue("GY4_ESCALA",oMdlCab:GetValue("ESCALA"))

	If ( lRet )
	
		For nX := 1 to Len(aFldMdl)
			
			lRet := oMdlGY4:SetValue(aFldMdl[nX,3],oModel408A:GetModel("MASTER"):GetValue(aFldMdl[nX,3]))
			
			If ( !lRet )
				Exit
			EndIf

		Next nX
	
	EndIf

EndIf

If ( lRet )

    oMdl408E := FwLoadModel("GTPA408E")
    oMdl408E:SetOperation(MODEL_OPERATION_DELETE)

	BEGIN TRANSACTION
		DbSelectArea("G52")
	    G52->(DbSetOrder(1))
	     
	    If G52->( DbSeek(xFilial("G52") + cAltDel  ) )
	    	oMdl408E:Activate()
	 		If oMdl408E:IsActive() 
	 			If oMdl408E:VldData()
	 				lPerCom :=  oMdl408E:CommitData()
	 			Else
	 				JurShowErro( oMdl408E:GetErrorMessage() )
	 				DisarmTransaction()
	 				lRet := .F.
	 			EndIf
	 		
	 		EndIf   	
	 		cConfSXE := .F.	
	    EndIf
	    
		If lPerCom

			lRet := oModel408E:VldData() .And. oModel408E:CommitData()
		
		Else
			JurShowErro( oModel408E:GetErrorMessage() )
			DisarmTransaction()
			lRet := .F.
		EnDIf
	
	END TRANSACTION
	
EndIf

If ( !lRet )

    cRetErr := GTPGetErrorMsg(oModel408E)   	
	FwAlertHelp("GRAVAÇÃO",cRetErr)
	RollBackSX8()
Else
	If cConfSXE
		ConfirmSx8()
	EndIf
Endif
						
If Valtype(oModel408E) = "O"
	oModel408E:DeActivate()
	oModel408E:Destroy()
	oModel408E:= nil
EndIf											

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldVeicLin
	Grava escala e dependencias
@author Fernando Amorim(Cafu)
@since		13/07/2017       
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function VldVeicLin(cCodBem)
 
 Local lRet := .F.
 Local nX	:= 0
 
 GYZ->(DbSetOrder(1))
 For nX := 1 to Len(aG408Linha)
 	If GYZ->(DbSeek(xFilial('GYZ')+ aG408Linha[nX] ))
 		While (!Eof() .and. xFilial('GYZ') == GYZ->GYZ_FILIAL .And.	GYZ->GYZ_CODLIN == aG408Linha[nX] )
 			If Alltrim(GYZ->GYZ_CODVEI)== Alltrim(cCodBem)
 				 lRet := .T. 	
 				 Exit			 
 			Endif
 			GYZ->(DbSkip())
 		End
	Endif		
 Next nX 
 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GA408GetOperation()
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function GA408GetOperation()

Return (nG408Oper)

//-------------------------------------------------------------------
/*/{Protheus.doc} GA408BkSX8()
Exibe o Alerta de Cancelamento da Operação e 
realiza o RollBack da SXE.
@author  Mick William da Silva
@since   26/07/2017
@version version
/*/
//-------------------------------------------------------------------
Static Function GA408BkSX8(nOpc)

	Local lRet := .T.
	Default nOpc := 1	// 1-Incluir; 2-Copiar; 3-Alterar
	
	RollBackSX8()
	IF nOpc == 2
		FWAlertInfo(STR0058) //"O Assistente de Configuração foi Cancelado!"
	Else
		If !FwAlertYesNo(STR0004)		// "O Assistente de Configuração será cancelado e as informações parametrizadas serão perdidas. Deseja continuar?"
			lRet := .F. 
		EndIf
	EndIf

	If lRet // SetKey adicionado como solução de contorno de automação TIR (método ClickImage não está funcionando)
		SetKey( VK_F5 ,{|| } ) 
		SetKey( VK_F6 ,{|| } ) 
		SetKey( VK_F7 ,{|| } ) 
		SetKey( VK_F8 ,{|| } ) 
	Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G408RSetDestroy()

Mata os valores das variáveis estáticas do código-fonte

@sample	G408RSetDestroy()

@params	
		
@return 
@author	Fernando Radu Muscalu
@since		17/08/2015
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function G408RSetDestroy()

If ( !Empty(cG408ResultSet) .And. Select(cG408ResultSet) > 0 )
	(cG408ResultSet)->(DbCloseArea())
EndIf

cG408ResultSet := ""

Return()

/*/{Protheus.doc} G408IsHoraEscala()
	Verifica se um horário já possui uma escala que não seja a escala que o usuário está informando
	@type  Function
	@author Fernando Radu Muscalu
	@since 19/10/2017
	@version version
	@param	cCodHora, caractere, Código do Horário a ser pesquisado
			cNotEscala, caractere, Código da Escala que deve ser ignorada na pesquisa
	@return array, array, array com as informações:
				[1] - lógico, .t. existe o horário em outra escala
				[2] - cFoundId, caractere, código da escala na qual o horário pesquisado já existe
				[3] - cFoundDesc, caractere, descrição da escala na qual o horário pesquisado já existe 
	@example
	(examples)
	@see (links_or_references)
/*/
Function G408IsHoraEscala(cCodHora,cNotEscala)

Local lExist 	:= .f.

Local cAlias	:= GetNextAlias()
Local cFoundId	:= ""
Local cFoundDesc	:= ""

Default cNotEscala	:= ""

BeginSQL Alias cAlias

	SELECT
		DISTINCT
		G52_CODIGO,
		G52_DESCRI
	FROM
		%Table:G52% G52
	WHERE
		G52_FILIAL = %XFilial:G52%
		AND G52.%NotDel%
		AND G52_SERVIC = %Exp:cCodHora%
		AND G52_CODIGO <> %Exp:cNotEscala%
	
EndSQL

lExist := !Empty((cAlias)->G52_CODIGO)

If ( lExist )
	cFoundId	:= Alltrim((cAlias)->G52_CODIGO)
	cFoundDesc	:= Alltrim((cAlias)->G52_DESCRI)
EndIf

(cAlias)->(DbCloseArea())

Return({lExist,cFoundId,cFoundDesc})

/*/{Protheus.doc} G408IsVeicEscala()
	Verifica se um veículo já existe em uma escala que não seja a escala que o usuário está informando
	@type  Function
	@author Fernando Radu Muscalu
	@since 19/10/2017
	@version version
	@param	cCodHora, caractere, Código do Veículo a ser pesquisado
			cNotEscala, caractere, Código da Escala que deve ser ignorada na pesquisa
	@return array, array, array com as informações:
				[1] - lógico, .t. existe o horário em outra escala
				[2] - cFoundId, caractere, código do veículo na qual o horário pesquisado já existe
				[3] - cFoundDesc, caractere, descrição do veículo na qual o horário pesquisado já existe 
	@example
	(examples)
	@see (links_or_references)
/*/
Function G408IsVeicEscala(cCodVeic,cNotEscala)

Local lExist 	:= .F.

Local cAlias	:= GetNextAlias()

Local oModelData := GA408GetModel("GTPA408A")
Local cDataIni   := DTOS(oModelData:GetModel("MASTER"):GetValue("GY4_DATADE"))
Local cDataFim   := DTOS(oModelData:GetModel("MASTER"):GetValue("GY4_DATATE"))

Default cNotEscala	:= ""

BeginSQL Alias cAlias

	SELECT
		GQA_CODESC,
		G52_DESCRI NOM_ESCALA
	FROM
		%Table:GQA% GQA
	INNER JOIN %Table:G52% G52
	ON	G52.G52_FILIAL = %XFilial:G52%
		AND G52.%NotDel%
		AND G52.G52_CODIGO = GQA.GQA_CODESC			
	INNER JOIN %Table:GY4% GY4
	ON  GY4.GY4_FILIAL = %XFilial:GY4%
		AND GY4.GY4_ESCALA = G52.G52_CODIGO
		AND GY4.GY4_TIPO = '1'
		AND GY4.%NotDel%
		AND 1 = (CASE 
			WHEN GY4.GY4_DATADE <> '' AND GY4.GY4_DATATE <> '' 
				THEN (CASE 
						WHEN (%Exp:cDataIni% >= GY4.GY4_DATADE 
								AND %Exp:cDataIni% <= GY4.GY4_DATATE)  
								OR (%Exp:cDataFim% >= GY4.GY4_DATADE 
									AND %Exp:cDataFim% <= GY4.GY4_DATATE)  
								OR (GY4.GY4_DATADE >= %Exp:cDataIni% 
									AND GY4.GY4_DATADE <= %Exp:cDataFim%)  
								OR (GY4.GY4_DATATE >= %Exp:cDataIni% 
									AND GY4.GY4_DATATE <= %Exp:cDataFim%)
							THEN 1
						ELSE 0
					END)
		END)
	WHERE
		GQA.GQA_FILIAL = %XFilial:GQA%
		AND GQA.%NotDel%
		AND GQA_CODVEI = %Exp:cCodVeic%
		AND GQA_CODESC <> %Exp:cNotEscala%

EndSQL

If (cAlias)->(!EOF())
	lExist := .T.
EndIf

(cAlias)->(DbCloseArea())

Return ({lExist})

/*/{Protheus.doc} GA408GIDG52   
    Esta função carrega um array com a relação entre os campos da tabela GID com
	a tabela G52
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/07/2017
    @version version
    @param
    @return aDePara, array, Array com os campos relacionados
			aDePara[n,1], caractere, nome do campo da tabela GID
			aDePara[n,2], caractere, nome do campo da tabela G52
				obs: quando o elemento aDePara[n,2] é "NO" significa
				que não há um campo em G52 relacionado à qualquer campo em
				GID
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA408GIDG52()

Local aDePara	:= {}

aAdd(aDePara,{"GID_FILIAL","G52_FILIAL"})
aAdd(aDePara,{"GID_COD","G52_SERVIC"})
aAdd(aDePara,{"GID_LINHA","G52_LINHA"})
aAdd(aDePara,{"GID_VIA","NO"})
aAdd(aDePara,{"GID_SENTID","G52_SENTID"})
aAdd(aDePara,{"GID_HORCAB","G52_HRSDRD"})
aAdd(aDePara,{"GID_SEG","G52_SEGUND"})
aAdd(aDePara,{"GID_TER","G52_TERCA"})
aAdd(aDePara,{"GID_QUA","G52_QUARTA"})
aAdd(aDePara,{"GID_QUI","G52_QUINTA"})
aAdd(aDePara,{"GID_SEX","G52_SEXTA"})
aAdd(aDePara,{"GID_SAB","G52_SABADO"})
aAdd(aDePara,{"GID_FER","NO"})
aAdd(aDePara,{"GID_DOM","G52_DOMING"})
aAdd(aDePara,{"GID_INIVIG","NO"})
aAdd(aDePara,{"GID_FINVIG","NO"})
aAdd(aDePara,{"GID_SERVIC","NO"})
aAdd(aDePara,{"GID_LOTACA","NO"})
aAdd(aDePara,{"GID_ATUALI","NO"})
aAdd(aDePara,{"GID_VIGENC","NO"})
aAdd(aDePara,{"GID_DTATU","NO"})
aAdd(aDePara,{"GID_HRATU","NO"})
aAdd(aDePara,{"GID_REVISA","NO"})
aAdd(aDePara,{"GID_HIST","NO"})
aAdd(aDePara,{"GID_DTALT","NO"})
aAdd(aDePara,{"GID_DEL","NO"})
aAdd(aDePara,{"GID_HORFIM","G52_HRCHRD"})
aAdd(aDePara,{"GID_NLINHA","NO",{|a,b,c| TPNomeLinh(a,b,c)}})
aAdd(aDePara,{"GID_NUMSRV","G52_NUMSRV"})
aAdd(aDePara,{"GID_MSBLQL","NO"})
aAdd(aDePara,{"G52SEQUEN","G52_SEQUEN"})
aAdd(aDePara,{"G52DIA","G52_DIA"})
aAdd(aDePara,{"G52PMANUT","G52_PMANUT"})
aAdd(aDePara,{"G52HRSDGR","G52_HRSDGR"})
aAdd(aDePara,{"G52HRCHGR","G52_HRCHGR"})
aAdd(aDePara,{"G52HRGRFI","G52_HRGRFI"})
aAdd(aDePara,{"G52DIAPAR","G52_DIAPAR"})
aAdd(aDePara,{"G52SEC","G52_SEC"})
aAdd(aDePara,{"NO_LOCORI","G52_LOCORI", {|a| GA408Local(a,"O")	} })
aAdd(aDePara,{"NO_LOCORI","G52_LOCDST", {|a| GA408Local(a,"D")} })

Return(aDePara)

/*/{Protheus.doc} GA408Local()
	Função que retorna a localidade ou de destino ou de origem
	@type  Function
	@author Fernando Radu Muscalu
	@since 19/10/2017
	@version version
	@param	cLinha, caractere, Código da Linha
			cDireção, caractere, "O" - Origem; "D" - destino
	@return cRet, caractere, Código da localidade
	@example
	(examples)
	@see (links_or_references)
/*/
Function GA408Local(cLinha,cDirecao)

Local cRet		:= ""

Local aLinha	:= {}

aLinha := GetAdvFVal("GI2",{"GI2_LOCINI","GI2_LOCFIM"},xFilial("GI2")+cLinha,1,{})
							
If ( cDirecao == "O" .And. Len(aLinha) > 0 )
	cRet := aLinha[1]
Else
	cRet := aLinha[2]
EndIf

Return(cRet)

/*/{Protheus.doc} GA408RetDePara()
	Função que retorna a localidade ou de destino ou de origem
	@type  Function
	@author Fernando Radu Muscalu
	@since 19/10/2017
	@version version
	@param	cLinha, caractere, Código da Linha
			cDireção, caractere, "O" - Origem; "D" - destino
	@return cRet, caractere, Código da localidade
	@example
	(examples)
	@see (links_or_references)
/*/
Function GA408RetDePara(cFrom, oSrcModel, nLine)

Local aDePara 	:= GA408GIDG52()

Local cFldList	:= "G52SEQUEN|G52DIA|G52PMANUT|G52HRSDGR|G52HRCHGR|G52HRGRFI|G52DIAPAR|G52NUMSRV|G52SEC"
Local cTo		:= ""
Local cFldLinha	:= ""
Local cFldSentid:= ""
Local cLinha	:= ""
Local cSentido	:= ""

Local nP		:= 0	
Local nIFrom	:= Iif(Substr(cFrom,1,3) == "GID" .or. Upper(Alltrim(cFrom)) $ cFldList, 1,2)
Local nITo		:= Iif (nIFrom == 1, 2, 1)

Local xRet

Default nLine	:= oSrcModel:GetLine()

If ( nIFrom + nITo > 1 )

	nP := aScan(aDePara,{|x| Upper(Alltrim(x[nIFrom])) == Upper(Alltrim(cFrom)) } )
	
	If ( nP > 0 .And. Len(aDePara[nP]) == 2 )
		cTo 	:= aDePara[nP,nITo]
		xRet	:= oSrcModel:GetValue(cFrom,nLine)
	ElseIf ( nP > 0 .And. Len(aDePara[nP]) > 2 )
		
		cTo		:= aDePara[nP,nITo]
		
		If ( Substr(cFrom,1,3) == "GID" .or. Upper(Alltrim(cFrom)) $ cFldList )
			cFldLinha := "GID_LINHA"
			cFldSentid:= "GID_SENTID"
		Else
			cFldLinha := "G52_LINHA"
			cFldSentid:= "G52_SENTID"
		EndIf
		
		cLinha 	:= GA408RetDePara(cFldLinha, oSrcModel, nLine)[2]
		
		If ( "NLINHA" $ aDePara[nP,nIFrom] )
							
			cSentido:= GA408RetDePara(cFldSentid, oSrcModel, nLine)[2]	
			
			xRet 	:= Eval(aDePara[nP,3],cLinha,,cSentido)
		
		ElseIf ( "LOCORI" $ aDePara[nP,nIFrom] )
			xRet := Eval(aDePara[nP,3],cLinha,"O")
		ElseIf ( "LOCDES" $ aDePara[nP,nIFrom] )
			xRet := Eval(aDePara[nP,3],cLinha,"D")	
		EndIf
			 	
	EndIf

EndIf

Return({cTo,xRet})

/*/{Protheus.doc} GA408Garagem()
	Função que retorna a hora de chegada ou saída garagem.
	@type  Function
	@author Fernando Radu Muscalu
	@since 19/10/2017
	@version version
	@param	cLinha, caractere, Código da Linha
			cDireção, caractere, "O" - Origem; "D" - destino
	@return cRet, caractere, Código da localidade
	@example
	(examples)
	@see (links_or_references)
/*/
Function GA408Garagem(cLinha,cHoras,cSaidCheg)

Local aAreaGI1	:= GI1->(GetArea())
Local aAreaGI2	:= GI2->(GetArea())

Local cRetHrs	:= ""

GI2->(DbSetOrder(1))

If ( GI2->(DbSeek(xFilial("GI2") + cLinha)) ) 

	GI1->(DbSetOrder(1))

	//Saída, calcula-se o horário de saída da Garagem
	If ( cSaidCheg == "S" .And. GI1->(DbSeek(xFilial("GI1") + GI2->GI2_LOCINI)) ) 
			
			If ( Empty(GI1->GI1_HRGRRD) .Or. GI1->GI1_HRGRRD == "0000" )
				cRetHrs := cHoras
			Else
				cRetHrs := GTFormatHour(SubHoras(GTFormatHour(cHoras,"99.99"), GTFormatHour(GI1->GI1_HRGRRD,"99.99")),"9999")
			EndIf
	//Chegada, calcula-se o horário de chegada à garagem				
	ElseIf ( cSaidCheg == "C"  .And. GI1->(DbSeek(xFilial("GI1") + GI2->GI2_LOCFIM)) )	 
			
			If ( Empty(GI1->GI1_HRRDGR) .Or. GI1->GI1_HRRDGR == "0000" )
				cRetHrs := cHoras
			Else
				cRetHrs := GTFormatHour(SomaHoras(GTFormatHour(cHoras,"99.99"),GTFormatHour(GI1->GI1_HRRDGR,"99.99")),"9999")
			EndIf	
		
	EndIf
	
EndIf

RestArea(aAreaGI1)
RestArea(aAreaGI2)

If ( Empty(cRetHrs) )
	cRetHrs := cHoras 
EndIf	

Return(cRetHrs)

/*/{Protheus.doc} G408Secionamento()
	Função responsável por efetuar a chamada da tela de Secionamento
	@type  Function
	@author Fernando Radu Muscalu
	@since 22/02/2018
	@version version
	
	@param	oView,	objeto, instância da Classe FwFormView()
			
	@return lRet,	Lógico, .t. Secionamento ou Visualização efetuada com sucesso
	
	@example
	lRet := G408Secionamento(oView)
	
	@see (links_or_references)
/*/
Function G408Secionamento(oView)

Local oMdlSel
Local oMdlGZQ

//Local nI		:= 0

Local cMsgProb	:= ""
Local cMsgSolu	:= ""
Local cTitle	:= ""

Local lRet		:= .f.

Default oView	:= GA408GetView('GTPA408B')

oMdlSel	:= Iif ( G408FGetFocus() == "V_SELECAO", oView:GetModel("SELECAO1"), oView:GetModel("SELECAO2"))
oMdlGZQ	:= oView:GetModel("GZQDETAIL")

If (	(G408FGetFocus() == "V_SELECAO" .And. oMdlSel:GetValue("G52SEC") <> "1") .And.;
		(	oMdlSel:GetValue( 'GID_SEG' ) .OR. oMdlSel:GetValue( 'GID_TER' ) .OR.; 
			oMdlSel:GetValue( 'GID_QUA' ) .OR. oMdlSel:GetValue( 'GID_QUI' ) .OR.; 
			oMdlSel:GetValue( 'GID_SEX' ) .OR. oMdlSel:GetValue( 'GID_SAB' ) .OR.; 
			oMdlSel:GetValue( 'GID_DOM' ) ) )  
	
	lRet := .t.
	
Else	
	
	If ( G408FGetFocus() == "V_SELECAO" )
	
		If !ValSectGrid(oView)
			If ( MsgYesNo(STR0071) ) //"Deseja desfazer o secionamento do serviço (horário)?"
				DesfazSect(oView)
			EndIf
		Else
			cMsgProb := STR0066		// "Não será possível secionar este horário (serviço), "
			cMsgProb += STR0067		// "porque ele, ou fora secionado anteriormente, ou não possui frequências."
			
			cMsgSolu := STR0068		// "Selecione algum serviço que se enquadre no perfil para secionamento."
			
			cTitle := STR0069		// "Não é possível secionar o serviço!"
			
			FWAlertHelp(cMsgProb,cMsgSolu,cTitle)			
		Endif	
	EndIf
	
EndIf

If ( lRet )

	GID->(DbSetOrder(1)) // GID_FILIAL+GID_COD
	If ( GID->(DbSeek(xFilial("GID") + oMdlSel:GetValue("GID_COD"))) )
	
		If ( G408FGetFocus() == "V_SELECAO" )
			
			If ( MsgYesNo(STR0070) )	// "Deseja realmente secionar o serviço (horário)?"
				ScatterService(oView)
			EndIf
		
		EndIf
		
	EndIf
	
EndIf

Return(lRet)

/*/{Protheus.doc} ValSectGrid
Valida se existe secionamento na SELECAO2
@type function
@author henrique.toyada
@since 25/02/2019
@version 1.0
@param oView, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ValSectGrid(oView)

Local lRet := .F.
Local oMdlSel1	:= oView:GetModel("SELECAO1")
Local oMdlSel2	:= oView:GetModel("SELECAO2")
//Local cPosLegenda := ""
Local cPosHorario := ""
Local cPosLinha   := ""
Local cPosSentido := ""
Local cPosNumSrv  := ""

cPosHorario  := oMdlSel1:GetValue("GID_COD")
cPosLinha    := oMdlSel1:GetValue("GID_LINHA")
cPosSentido  := oMdlSel1:GetValue("GID_SENTID")
cPosNumSrv   := oMdlSel1:GetValue("GID_NUMSRV")

	lRet := oMdlSel1:IsDeleted()
	If !lRet
		lRet := oMdlSel2:SeekLine({;
							{"GID_COD",cPosHorario   },;
							{"GID_LINHA",cPosLinha   },;
							{"G52SEC","1"            },;
							{"GID_NUMSRV",cPosNumSrv };
							})  
	EndIf

Return lRet

/*/{Protheus.doc} DesfazSect
Desfaz secionamento da linha
@type function
@author henrique.toyada
@since 25/02/2019
@version 1.0
@param oView, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DesfazSect(oView)

Local cPosLegenda := ""
Local cPosHorario := ""
Local cPosLinha   := ""
Local cPosSentido := ""
Local cPosNumSrv  := ""
Local cPosNumDOM  := ""
Local cPosNumSEG  := ""
Local cPosNumTER  := ""
Local cPosNumQUA  := ""
Local cPosNumQUI  := ""
Local cPosNumSEX  := ""
Local cPosNumSAB  := ""	
Local nLinhaSel1  := 0
//Local nI          := 0

//Local aFrequence  := {}
//Local aSeek       := {}

Local lRet        := .T.
Local lRetGrid    := .F.
Local lValGrid    := .T.

Local oMdlSel1	:= oView:GetModel("SELECAO1")
Local oMdl408F 	:= FwLoadModel("GTPA408F")

oMdlSel1:SetNoInsertLine(.F.)
oMdlSel1:SetNoDeleteLine(.F.)
								
cPosLegenda  := oMdlSel1:GetValue("LEGENDA")
cPosHorario  := oMdlSel1:GetValue("GID_COD")
cPosLinha    := oMdlSel1:GetValue("GID_LINHA")
cPosSentido  := oMdlSel1:GetValue("GID_SENTID")
cPosNumSrv   := oMdlSel1:GetValue("GID_NUMSRV")
	
	While lValGrid
		lValGrid := oMdlSel1:SeekLine({;
					{"GID_COD",cPosHorario   },;
					{"GID_LINHA",cPosLinha   },;
					{"G52SEC","1"            },;
					{"GID_NUMSRV",cPosNumSrv };
					})  
		
		cPosNumDOM   := oMdlSel1:GetValue("GID_DOM") 
		cPosNumSEG   := oMdlSel1:GetValue("GID_SEG") 
		cPosNumTER   := oMdlSel1:GetValue("GID_TER") 
		cPosNumQUA   := oMdlSel1:GetValue("GID_QUA") 
		cPosNumQUI   := oMdlSel1:GetValue("GID_QUI") 
		cPosNumSEX   := oMdlSel1:GetValue("GID_SEX") 
		cPosNumSAB   := oMdlSel1:GetValue("GID_SAB") 
		
		If lValGrid
			If oMdlSel1:CanDeleteLine()
				oMdlSel1:DeleteLine()
				lRetGrid := oMdlSel1:SeekLine({;
							{"GID_COD",cPosHorario   },;
							{"GID_LINHA",cPosLinha   },;
							{"G52SEC","3"            },;
							{"GID_NUMSRV",cPosNumSrv };
							})   
				
				If lRetGrid
					oMdlSel1:LoadValue("GID_DOM",cPosNumDOM) 
					oMdlSel1:LoadValue("GID_SEG",cPosNumSEG) 
					oMdlSel1:LoadValue("GID_TER",cPosNumTER) 
					oMdlSel1:LoadValue("GID_QUA",cPosNumQUA) 
					oMdlSel1:LoadValue("GID_QUI",cPosNumQUI) 
					oMdlSel1:LoadValue("GID_SEX",cPosNumSEX) 
					oMdlSel1:LoadValue("GID_SAB",cPosNumSAB) 
					oMdlSel1:LoadValue("G52SEC","2")
					nLinhaSel1 := oMdlSel1:GetLine()
				EndIf
			EndIf
		EndIf
		
	End
	
oMdlSel1:SetNoDeleteLine(.T.)

oMdl408F:DeActivate()
oMdl408F:Destroy()

If ( Upper(oView:ClassName()) == "FWFORMVIEW" .And. oView:IsActive() )
	oView:Refresh("V_SELECAO")
EndIf

oMdlSel1:SetNoInsertLine(.T.)
oMdlSel1:SetLine(nLinhaSel1)
Return lRet

/*/{Protheus.doc} G408ScattServ()
	Função responsável por gerar os itens do lado direito "SELECAO1"
	@type  Function
	@author Fernando Radu Muscalu
	@since 22/02/2018
	@version version
	
	@param	oSubModel,	objeto, instância da Classe FwFormView()
			
	@return lRet,	Lógico, .t. Secionamento ou Visualização efetuada com sucesso
	
	@example
	lRet := G408ScattServ(oSubModel)
	
	@see (links_or_references)
/*/
Function G408ScattServ(oSubModel)

Default oSubModel := GA408GetView("GTPA408B") 

Return(ScatterService(oSubModel))

/*/{Protheus.doc} ScatterService()
	Função responsável por gerar os itens do lado direito "SELECAO1"
	@type  Function
	@author Fernando Radu Muscalu
	@since 22/02/2018
	@version version
	
	@param	oView,	objeto, instância da Classe FwFormView()
			
	@return lRet,	Lógico, .t. Secionamento ou Visualização efetuada com sucesso
	
	@example
	lRet := ScatterService(oView)
	
	@see (links_or_references)
/*/		
Static Function ScatterService(oView)

Local cLegenda		:= ""
Local cHorario		:= ""
Local cLinha		:= ""
Local cSentido		:= ""
Local cNumSrv		:= ""
Local cLocSecIni 	:= ""
Local cLocSecFim 	:= ""
Local cHrSecIni		:= ""
Local cHrSecFim		:= ""
Local cHrSecSD		:= ""
Local cHrSecCH		:= ""
Local cDscSecIni	:= ""
Local cDscSecFim	:= ""
Local cNomeLinha	:= ""
Local nLinhaSel1	:= 0
Local nI			:= 0
Local aFrequence	:= {}
Local lRet          := .T.
Local lValGrid      := .F.
Local oMdl408F 	:= FwLoadModel("GTPA408F")
Local oMdlSel1	:= oView:GetModel("SELECAO1")

oMdl408F:SetOperation(MODEL_OPERATION_VIEW)
oMdl408F:Activate()

oMdlSel1:SetNoInsertLine(.f.)
								
cLegenda		:= oMdlSel1:GetValue("LEGENDA")
cHorario		:= oMdlSel1:GetValue("GID_COD")
cLinha			:= oMdlSel1:GetValue("GID_LINHA")
cSentido		:= oMdlSel1:GetValue("GID_SENTID")
cNumSrv			:= oMdlSel1:GetValue("GID_NUMSRV")

nLinhaSel1		:= oMdlSel1:GetLine()

lRet := oMdlSel1:LoadValue("GID_DOM",.f.) .And.;
		oMdlSel1:LoadValue("GID_SEG",.f.) .And.;
		oMdlSel1:LoadValue("GID_TER",.f.) .And.;
		oMdlSel1:LoadValue("GID_QUA",.f.) .And.;
		oMdlSel1:LoadValue("GID_QUI",.f.) .And.;
		oMdlSel1:LoadValue("GID_SEX",.f.) .And.;
		oMdlSel1:LoadValue("GID_SAB",.f.) .And.;
		oMdlSel1:LoadValue("G52SEC","3")

aFrequence := G408ServFreqStand(cHorario)
		
If ( lRet )

	For nI := 1 to oMdl408F:GetModel("GIEDETAIL"):Length()
	
		cLocSecIni 	:= oMdl408F:GetModel("GIEDETAIL"):GetValue("GIE_IDLOCP",nI)
		cLocSecFim 	:= oMdl408F:GetModel("GIEDETAIL"):GetValue("GIE_IDLOCD",nI)
		cHrSecIni	:= oMdl408F:GetModel("GIEDETAIL"):GetValue("GIE_HORLOC",nI)
		cHrSecFim	:= oMdl408F:GetModel("GIEDETAIL"):GetValue("GIE_HORDES",nI)
		cHrSecSD	:= GA408Garagem(cLinha,cHrSecIni,"S")
		cHrSecCH	:= GA408Garagem(cLinha,cHrSecFim,"C")
		cDscSecIni	:= Alltrim(Posicione("GI1",1,xFilial("GI1")+cLocSecIni,"GI1_DESCRI"))
		cDscSecFim	:= Alltrim(Posicione("GI1",1,xFilial("GI1")+cLocSecFim,"GI1_DESCRI"))
		cNomeLinha	:= cDscSecIni + "/" + cDscSecFim
		
		lValGrid := oMdlSel1:SeekLine({;
		{"GID_COD",cHorario     },;
		{"GID_LINHA",cLinha     },;
		{"GID_NLINHA",cNomeLinha},;
		{"GID_SENTID",cSentido  },;
		{"G52SECINI",cLocSecIni },;
		{"G52SECFIM",cLocSecFim },;
		{"GID_HORCAB",cHrSecIni },;
		{"GID_HORFIM",cHrSecFim },;
		{"G52HRSDGR",cHrSecSD   },;
		{"G52HRCHGR",cHrSecCH   },;
		{"G52SEC","1"           },;
		{"GID_NUMSRV",cNumSrv   };
		})   
		
		
		If !lValGrid
			If ( oMdlSel1:GetLine() < oMdlSel1:AddLine() )
				
				lRet := oMdlSel1:LoadValue("ORIGINLINE",nLinhaSel1) .And.;
						oMdlSel1:LoadValue("LEGENDA",cLegenda     ) .And.;
						oMdlSel1:LoadValue("GID_COD",cHorario     ) .And.;
						oMdlSel1:LoadValue("GID_LINHA",cLinha     ) .And.;
						oMdlSel1:LoadValue("GID_NLINHA",cNomeLinha) .And.;
						oMdlSel1:LoadValue("GID_SENTID",cSentido  ) .And.;
						oMdlSel1:LoadValue("G52SECINI",cLocSecIni ) .And.;
						oMdlSel1:LoadValue("G52SECFIM",cLocSecFim ) .And.;
						oMdlSel1:LoadValue("GID_HORCAB",cHrSecIni ) .And.;
						oMdlSel1:LoadValue("GID_HORFIM",cHrSecFim ) .And.;
						oMdlSel1:LoadValue("G52HRSDGR",cHrSecSD   ) .And.;
						oMdlSel1:LoadValue("G52HRCHGR",cHrSecCH   ) .And.;
						oMdlSel1:LoadValue("G52SEC","1"           ) .And.;
						oMdlSel1:LoadValue("GID_NUMSRV",cNumSrv   ) .And.;
						oMdlSel1:LoadValue("GID_SEG",aFrequence[2,2]) .And.;
						oMdlSel1:LoadValue("GID_TER",aFrequence[2,3]) .And.;
						oMdlSel1:LoadValue("GID_QUA",aFrequence[2,4]) .And.;
						oMdlSel1:LoadValue("GID_QUI",aFrequence[2,5]) .And.;
						oMdlSel1:LoadValue("GID_SEX",aFrequence[2,6]) .And.;
						oMdlSel1:LoadValue("GID_SAB",aFrequence[2,7]) .And.;
						oMdlSel1:LoadValue("GID_DOM",aFrequence[2,1])
			EndIf
		EndIf
	Next nI

EndIf

oMdl408F:DeActivate()
oMdl408F:Destroy()

If ( Upper(oView:ClassName()) == "FWFORMVIEW" .And. oView:IsActive() )
	oView:Refresh("V_SELECAO")
EndIf

oMdlSel1:SetNoInsertLine(.t.)
oMdlSel1:GoLine(nLinhaSel1)

Return(lRet)

/*/{Protheus.doc} G408RetDayOfWeek()
	Converte dia da semana em número ou número em dia da semana
	@type  Function
	@author Fernando Radu Muscalu
	@since 22/02/2018
	@version version
	
	@param	cDayWeek,	caractere, dia da semana (ex: SEG, TER, QUA,...)
			nDay,		numérico, Nro do dia (ex: 1 - refere-se a domingo)
			
	@return xRet,	qualquer, Pode retornar caractere com o dia ("SEG") ou um numérico (1)
	
	@example
	xRet := G408RetDayOfWeek(cDayWeek,nDay)
	
	@see (links_or_references)
/*/

Function G408RetDayOfWeek(cDayWeek,nDay)

Local aWeek	:= {}

Default cDayWeek	:= ""
Default nDay 		:= 0

aAdd(aWeek,{"DOM",1})
aAdd(aWeek,{"SEG",2})
aAdd(aWeek,{"TER",3})
aAdd(aWeek,{"QUA",4})
aAdd(aWeek,{"QUI",5})
aAdd(aWeek,{"SEX",6})
aAdd(aWeek,{"SAB",7})

If ( Empty(cDayWeek) .And. Empty(nDay) )
	xRet := aClone(aWeek)
Else
	
	If ( !Empty(cDayWeek) )
		
		nP := aScan(aWeek,{|x| Upper(x[1]) $ Upper(Alltrim(cDayWeek)) })
		
		If ( nP > 0 )
			xRet := aWeek[nP,2]
		EndIf
		
	ElseIf ( !Empty(nDay) )
	
		nP := aScan(aWeek,{|x| x[2] == nDay })
		
		If ( nP > 0 )
			xRet := aWeek[nP,1]
		EndIf
	
	EndIf
	
EndIf	

Return(xRet)

/*/{Protheus.doc} Teste
	Executa a View do modelo GTPA408E, tanto para visualização quanto
	para exclusão

	@type  Function
	@author user
	@since 11/04/2022
	@version version
	@param nOpc, numérico, Opção de manutenção (view = 1 ou exclusão = 5)
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function GA408ExecView(nOpc)
	
	FWExecView("Escala de Veículos","GTPA408E",nOpc,,{|| .T.})

Return()
