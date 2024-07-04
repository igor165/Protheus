#Include "Protheus.ch"
#Include 'FWMVCDef.ch'
#Include 'FWBrowse.ch'
#Include 'GPEM017.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEM017D
Browse com as funcionalidades de importação de terceiros para o Middleware
@author  lidio.oliveira
@since   21/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Function GPEM017D()

    Local oBrowse       := FWmBrowse():New()
    Local cMsgDesatu    := ""

    //Valida existência da Tabela RED
	If !ChkFile("RED")
		cMsgDesatu := CRLF + OemToAnsi(STR0382) + CRLF
	EndIf

    If !Empty(cMsgDesatu)
		//ATENCAO"###"Tabela RED não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
		Help( " ", 1, OemToAnsi(STR0045),, cMsgDesatu, 1, 0 ) //Atenção
		Return
	EndIf

    If !fVldCmpRED()
        Return ()
    EndIf

    oBrowse:SetDescription(STR0381) //Importação de XML para o Middleware
    oBrowse:SetAlias("RED")
    oBrowse:SetMenuDef("GPEM017D")

    oBrowse:AddLegend( "RED_STATUS=='1'", "BR_AZUL"			, "Pendente (Somente XML)"  )
    oBrowse:AddLegend( "RED_STATUS=='2'", "BR_AMARELO"		, "Pendente (Somente Recibo)"  )
    oBrowse:AddLegend( "RED_STATUS=='3'", "BR_CINZA"		, "Pendente (Completo)"  )
    oBrowse:AddLegend( "RED_STATUS=='4'", "BR_VERDE_ESCURO"	, "XML Integrado (Sem Recibo)"  )
    oBrowse:AddLegend( "RED_STATUS=='5'", "BR_VERDE"		, "XML + Recibo Integrado (Com Recibo)"  )
    oBrowse:AddLegend( "RED_STATUS=='6'", "BR_VERMELHO"		, "Erro na Integração"  )

    oBrowse:Activate()

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu
@author  lidio.oliveira
@since   21/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina   := {}
    Local lProcess  := .F.
    Local aSubProc  := {}

    ADD OPTION aRotina Title OemToAnsi(STR0380) Action "PesqBrw"                OPERATION 1 ACCESS 0 //Pesquisar
    ADD OPTION aRotina Title OemToAnsi(STR0383) Action "VIEWDEF.GPEM017D"       OPERATION 2 ACCESS 0 //Visualizar
    ADD OPTION aRotina Title OemToAnsi(STR0385) Action "GPEM017E( !lProcess ) " OPERATION 3 ACCESS 0 //Importar

    // ADCIONA O ARRAY DO SUBMENU A OPÇÃO DO MENU.
    ADD OPTION aRotina TITLE OemToAnsi(STR0386) Action aSubProc OPERATION 9 ACCESS 0 // Opção de processamento dos eventos

    // ADICIONA OPÇOES NO SUBMENU.
    ADD OPTION aSubProc Title OemToAnsi(STR0387) Action "GPEM017F(1)"  OPERATION 4 ACCESS 0 // Processa eventos de tabela
    ADD OPTION aSubProc Title OemToAnsi(STR0393) Action "GPEM017F(2)"  OPERATION 4 ACCESS 0 // Processa eventos não periódicos
	ADD OPTION aSubProc Title OemToAnsi(STR0392) Action "GPEM017F(3)"  OPERATION 4 ACCESS 0 // Processa eventos periódicos

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo
@author  lidio.oliveira
@since   21/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel  := Nil
Local oStruct := FWFormStruct(1, "RED")

oModel := MPFormModel():New("MODEL_RED", /*bPre*/, /*bTudoOk*/ )
oModel:AddFields("REDMASTER",,oStruct)

//Setando as descrições
oModel:SetDescription(STR0381)
oModel:GetModel("REDMASTER"):SetDescription(STR0384) //Importador Middleware

oModel:SetPrimaryKey({"RED_FILIAL", "RED_CHVERP", "RED_CHVGOV", "RED_STATUS", "RED_CNPJ" })

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Monta a view
@author  lidio.oliveira
@since   31/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView     := Nil
Local oStruct   := FWFormStruct(2, "RED")
Local oModel    := FWLoadModel("GPEM017D")

//Criando a View
oView := FWFormView():New()
oView:SetModel(oModel)

//Adicionando os campos do cabeçalho e o grid dos filhos
oView:AddField("VIEW_RED", oStruct, "REDMASTER")

//Amarrando a view com as box
oView:CreateHorizontalBox("CABEC", 100)
oView:SetOwnerView("VIEW_RED", "CABEC")

//Habilitando título
oView:EnableTitleView("VIEW_RED",STR0381)

Return oView

/*/
{Protheus.doc} fVldCmpRED
Valida o compartilhamento das tabelas RED x RJE.

@type		Static Function
@author		Silvio C. Stecca
@since		23/01/2021
@version	12.1.XX
@param
@return		lCmpTab, Logico, Retorna se o compartilhamento entre as tabelas estão ok.
/*/
Static Function fVldCmpRED()

	Local oButton2
	Local oGroup1
	Local oPanel1
	Local oSay1
	Local cSession	:= "AlertaRED"
	Local lChkMsg	:= fwGetProfString(cSession, "MSG_JOBRAZ_" + cUserName, '', .T.) == ""
	Local cTabelas	:= ""
	Local aCmpTab	:= {}
	Local nCnt		:= 0
    Local lRet      := .T.

	Static oDlg

	// ENCONTRA O COMPARTILHAMENTO ENTRE AS TABELAS RED/RJE
	aAdd(aCmpTab, {"RED" + " - " + Alltrim(FWX2Nome("RED")), FWModeAccess("RED", 1) + FWModeAccess("RED", 2) + FWModeAccess("RED", 3)})
	aAdd(aCmpTab, {"RJE" + " - " + Alltrim(FWX2Nome("RJE")), FWModeAccess("RJE", 1) + FWModeAccess("RJE", 2) + FWModeAccess("RJE", 3)})

	// VERIFICA SE AS TABELAS ESTÃO COM O MESMO TIPO DE COMPARTILHAMENTO.
	For nCnt := 2 to Len(aCmpTab)
		If aCmpTab[nCnt, 2] != aCmpTab[1, 2]
			cTabelas += aCmpTab[1, 1] + " x " + aCmpTab[nCnt, 1] + CRLF
            lRet :=  .F.
		EndIf
	Next nCnt

	If lChkMsg .And. !Empty(cTabelas)
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0388) FROM 000, 000 TO 200, 550 COLORS 0, 16777215 PIXEL //"Compartilhamento Tabelas eSocial"
			@ 000, 000 MSPANEL oPanel1 SIZE 375, 150 OF oDlg COLORS 0, 16777215 RAISED
			@ 005, 012 GROUP oGroup1 TO 075, 265 PROMPT OemToAnsi(STR0045) OF oPanel1 COLOR 0, 16777215 PIXEL //"Atenção"
			@ 013, 017 SAY oSay1 PROMPT + CRLF + OemToAnsi(STR0389) + CRLF + CRLF + cTabelas + CRLF + OemToAnsi(STR0390) SIZE 245, 200 OF oPanel1 COLORS 0, 16777215 PIXEL // "Encontrado divergência entre o compartilhamento das tabelas: " ## "É necessário que o compartilhamento entre as tabelas seja o mesmo. Ajuste e execute a rotina novamente."

			@ 080, 228 BUTTON oButton2 PROMPT OEMToAnsi(STR0391) SIZE 037, 012 OF oPanel1 PIXEL

			oButton2:bLClicked := {|| oDlg:End() }

		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf

Return lRet
