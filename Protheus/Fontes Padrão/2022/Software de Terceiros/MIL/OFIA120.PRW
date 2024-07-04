#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA120.CH"

/*/{Protheus.doc} OFIA120
	Tela Principal Oportunidades Agrupadas
	Browse's dos Interesses de Veiculos / Balcao / Oficina

	@author Andre Luis Almeida
	@since 21/01/2019
/*/
Function OFIA120()

Local oWorkarea
Local oDlgOA120
Local cCadastro := STR0001 // Oportunidades/Interesses de Veículos/Máquinas, Peças e Serviços
Local aSize     := FWGetDialogSize( oMainWnd )
Local nCntFor   := 0
Local cObj      := ""
Local cLayout   := OA1200041_Profile(1,"LAYOUT" ,"A") // Buscar Layout ( A/B/C/D/E )
Local cOrdem    := OA1200051_BrowsePermitido()
Local nQtdObj   := len(cOrdem)
Local nTamObj   := 300 // Tamanho padrão em PIXEL
Local lPixFixo  := .T. // PIXEL fixo
Private cMotivo := "000011" // Tipo de motivo - utilizado na consulta de Motivos de Cancelamentos
Private aDelMotiv := {}
Private oBrwVDL
Private oBrwVDM
Private oBrwVDQ
Private oBrwVDI
Private oBrwVDJ

SetKey(VK_F12,{ || OA1200011_F12Parametros() })

oDlgOA120 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oWorkArea := FWUIWorkArea():New( oDlgOA120 )

If OA1200041_Profile(1,"TELA100","N") == "S" // Buscar se a Tela é 100 % ? ( S/N )
	lPixFixo := .f. // Não é PIXEL fixo, trabalha com % nos tamanhos dos Objetos Browse's
	nTamObj  := 100 // 100% da tela
	If nQtdObj > 0 // Calcular % dos objetos
		Do Case
			Case cLayout == "A"
				nTamObj := ( 100 / ( nQtdObj + 1 ) ) // minimo 20% = 5 linhas
			Case cLayout == "B"
				If nQtdObj <= 2
					nTamObj := 50 // 50% = 2 linhas
				ElseIf nQtdObj == 3
					nTamObj := 33 // 33% - 3 linhas
				Else
					nTamObj := 25 // 25% - 4 linhas
				EndIf
			Case cLayout == "C"
				If nQtdObj == 1
					nTamObj := 50 // 50% = 2 linhas
				ElseIf nQtdObj <= 3
					nTamObj := 33 // 33% - 3 linhas
				Else
					nTamObj := 25 // 25% - 4 linhas
				EndIf
			Case cLayout == "D"
				If nQtdObj == 1
					nTamObj := 50 // 50% = 2 linhas
				ElseIf nQtdObj == 2
					nTamObj := 33 // 33% - 3 linhas
				Else
					nTamObj := 25 // 25% - 4 linhas
				EndIf
			Case cLayout == "E"
				If nQtdObj <= 2
					nTamObj := 50 // 50% = 2 linhas
				Else
					nTamObj := 33 // 33% = 3 linhas
				EndIf
		EndCase
	EndIf
EndIf

oWorkArea:CreateHorizontalBox( "LINE01", nTamObj-1 , lPixFixo ) // -1 para nao estourar 100% da tela ( criando scroll lateral )
oWorkArea:SetBoxCols( "LINE01", { "OBJOportunidade" } )

Do Case
	Case cLayout == "A"
		If nQtdObj >= 1
			oWorkArea:CreateHorizontalBox( "LINE02", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE02", { "OBJ1" } )
		EndIf
		If nQtdObj >= 2
			oWorkArea:CreateHorizontalBox( "LINE03", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE03", { "OBJ2" } )
		EndIf
		If nQtdObj >= 3
			oWorkArea:CreateHorizontalBox( "LINE04", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE04", { "OBJ3" } )
		EndIf
		If nQtdObj >= 4
			oWorkArea:CreateHorizontalBox( "LINE05", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE05", { "OBJ4" } )
		EndIf
	Case cLayout == "B"
		If nQtdObj >= 1
			oWorkArea:CreateHorizontalBox( "LINE02", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE02", { "OBJ1" , "OBJ2" } )
		EndIf			
		If nQtdObj >= 3
			oWorkArea:CreateHorizontalBox( "LINE03", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE03", { "OBJ3" } )
		EndIf
		If nQtdObj >= 4
			oWorkArea:CreateHorizontalBox( "LINE04", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE04", { "OBJ4" } )
		EndIf
	Case cLayout == "C"
		If nQtdObj >= 1
			oWorkArea:CreateHorizontalBox( "LINE02", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE02", { "OBJ1" } )
		EndIf
		If nQtdObj >= 2
			oWorkArea:CreateHorizontalBox( "LINE03", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE03", { "OBJ2" , "OBJ3" } )
		EndIf
		If nQtdObj >= 4
			oWorkArea:CreateHorizontalBox( "LINE04", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE04", { "OBJ4" } )
		EndIf
	Case cLayout == "D"
		If nQtdObj >= 1
			oWorkArea:CreateHorizontalBox( "LINE02", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE02", { "OBJ1" } )
		EndIf
		If nQtdObj >= 2
			oWorkArea:CreateHorizontalBox( "LINE03", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE03", { "OBJ2" } )
		EndIf
		If nQtdObj >= 3
			oWorkArea:CreateHorizontalBox( "LINE04", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE04", { "OBJ3" , "OBJ4" } )
		EndIf
	Case cLayout == "E"
		If nQtdObj >= 1
			oWorkArea:CreateHorizontalBox( "LINE02", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE02", { "OBJ1" , "OBJ2" } )
		EndIf
		If nQtdObj >= 3
			oWorkArea:CreateHorizontalBox( "LINE03", nTamObj , lPixFixo )
			oWorkArea:SetBoxCols( "LINE03", { "OBJ3" , "OBJ4" } )
		EndIf
EndCase

oWorkArea:Activate()

VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI") + __cUserID))

// Browse Oportunidades
oBrwVDL:= FWMBrowse():New() 
oBrwVDL:SetOwner(oWorkarea:GetPanel("OBJOportunidade"))
oBrwVDL:SetAlias("VDL")
oBrwVDL:DisableLocate()
oBrwVDL:DisableDetails()
oBrwVDL:SetAmbiente(.F.)
oBrwVDL:SetWalkthru(.F.)
oBrwVDL:SetMenuDef("OFIA050")
oBrwVDL:SetDescription(STR0002) // Oportunidades
oBrwVDL:SetInsert(.f.)
oBrwVDL:SetUseFilter()
oBrwVDL:lOptionReport := .f.
oBrwVDL:Activate()

For nCntFor := 1 to len(cOrdem)

	cObj := "OBJ"+strzero(nCntFor,1)

	Do Case

		Case substr(cOrdem,nCntFor,1) == "1" // Browse Interesses de Veiculos/Maquinas
			oBrwVDM:= FWMBrowse():New() 
			oBrwVDM:SetOwner(oWorkarea:GetPanel(cObj))
			oBrwVDM:SetAlias("VDM")
			oBrwVDM:lChgAll := .f. // nao apresentar a tela para escolher a filial
			oBrwVDM:DisableLocate()
			oBrwVDM:DisableDetails()
			oBrwVDM:SetAmbiente(.F.)
			oBrwVDM:SetWalkthru(.F.)
			oBrwVDM:SetMenuDef("VEICM680")
			oBrwVDM:SetDescription(STR0003) // Interesses de Veículos/Máquinas
			If !VCM680BrwAct(oBrwVDM,.f.,.f.)
				Return
			EndIf
			oBrwVDM:SetInsert(.f.)
			oBrwVDM:SetUseFilter()
			oBrwVDM:lOptionReport := .f.
			oBrwVDM:Activate()
			oRelacVDM:= FWBrwRelation():New() 
			oRelacVDM:AddRelation( oBrwVDL , oBrwVDM , { { "VDM_FILIAL" , "VDL_FILIAL" }, { "VDM_CODOPO" , "VDL_CODOPO" } }) 
			oRelacVDM:Activate() 

		Case substr(cOrdem,nCntFor,1) == "2" // Browse Interesses de Balcão de Peças
			oBrwVDQ:= FWMBrowse():New() 
			oBrwVDQ:SetOwner(oWorkarea:GetPanel(cObj))
			oBrwVDQ:SetAlias("VDQ")
			oBrwVDQ:lChgAll := .f. // nao apresentar a tela para escolher a filial
			oBrwVDQ:DisableLocate()
			oBrwVDQ:DisableDetails()
			oBrwVDQ:SetAmbiente(.F.)
			oBrwVDQ:SetWalkthru(.F.)
			oBrwVDQ:SetMenuDef("OFIA100")
			oBrwVDQ:SetDescription(STR0004) // Interesses de Balcão de Peças
			OA1000091_BrowseVDQ(oBrwVDQ)
			oBrwVDQ:SetInsert(.f.)
			oBrwVDQ:SetUseFilter()
			oBrwVDQ:lOptionReport := .f.
			oBrwVDQ:Activate()
			oRelacVDQ:= FWBrwRelation():New() 
			oRelacVDQ:AddRelation( oBrwVDL , oBrwVDQ , { { "VDQ_FILIAL" , "VDL_FILIAL" }, { "VDQ_CODOPO" , "VDL_CODOPO" } }) 
			oRelacVDQ:Activate() 

		Case substr(cOrdem,nCntFor,1) == "3" // Browse Interesses de Oficina Peças
			oBrwVDI:= FWMBrowse():New() 
			oBrwVDI:SetOwner(oWorkarea:GetPanel(cObj))
			oBrwVDI:SetAlias("VDI")
			oBrwVDI:lChgAll := .f. // nao apresentar a tela para escolher a filial
			oBrwVDI:DisableLocate()
			oBrwVDI:DisableDetails()
			oBrwVDI:SetAmbiente(.F.)
			oBrwVDI:SetWalkthru(.F.)
			oBrwVDI:SetMenuDef("OFIA110")
			oBrwVDI:SetDescription(STR0005) // Interesses de Oficina Peças
			OA1100091_Browse("oBrwVDI","VDI")
			oBrwVDI:SetInsert(.f.)
			oBrwVDI:SetUseFilter()
			oBrwVDI:lOptionReport := .f.
			oBrwVDI:Activate()
			oRelacVDI:= FWBrwRelation():New() 
			oRelacVDI:AddRelation( oBrwVDL , oBrwVDI , { { "VDI_FILIAL" , "VDL_FILIAL" }, { "VDI_CODOPO" , "VDL_CODOPO" } }) 
			oRelacVDI:Activate() 

		Case substr(cOrdem,nCntFor,1) == "4" // Browse Interesses de Oficina Serviços
			oBrwVDJ:= FWMBrowse():New() 
			oBrwVDJ:SetOwner(oWorkarea:GetPanel(cObj))
			oBrwVDJ:SetAlias("VDJ")
			oBrwVDJ:lChgAll := .f. // nao apresentar a tela para escolher a filial
			oBrwVDJ:DisableLocate()
			oBrwVDJ:DisableDetails()
			oBrwVDJ:SetAmbiente(.F.)
			oBrwVDJ:SetWalkthru(.F.)
			oBrwVDJ:SetMenuDef("OFIA110")
			oBrwVDJ:SetDescription(STR0006) // Interesses de Oficina Serviços
			OA1100091_Browse("oBrwVDJ","VDJ")
			oBrwVDJ:SetInsert(.f.)
			oBrwVDJ:SetUseFilter()
			oBrwVDJ:lOptionReport := .f.
			oBrwVDJ:Activate()
			oRelacVDJ:= FWBrwRelation():New() 
			oRelacVDJ:AddRelation( oBrwVDL , oBrwVDJ , { { "VDJ_FILIAL" , "VDL_FILIAL" }, { "VDJ_CODOPO" , "VDL_CODOPO" } }) 
			oRelacVDJ:Activate() 
	EndCase

Next

oDlgOA120:Activate( , , , , , , ) //ativa a janela

SetKey(VK_F12,Nil)

Return

/*/{Protheus.doc} OA1200011_F12Parametros
	F12 - Parametros/Configuracoes da Rotina

	@author Andre Luis Almeida
	@since 21/01/2019
/*/
Function OA1200011_F12Parametros()
Local lOkTela   := .f.
Local cLayout   := ""
Local cOrdem    := ""
Local cTela100  := ""
Local lTela100  := .f.
Local aVetOrdem := {}
Local nCntFor   := 0
Local cSTR0015 := STR0015 // Necessário pois dava erro na versao nova quando STRs estavam diretamente no objeto sem utilizar variavel
Local cSTR0016 := STR0016 // Necessário pois dava erro na versao nova quando STRs estavam diretamente no objeto sem utilizar variavel
Local cSTR0017 := STR0017 // Necessário pois dava erro na versao nova quando STRs estavam diretamente no objeto sem utilizar variavel
Local cSTR0018 := STR0018 // Necessário pois dava erro na versao nova quando STRs estavam diretamente no objeto sem utilizar variavel
Local cSTR0019 := STR0019 // Necessário pois dava erro na versao nova quando STRs estavam diretamente no objeto sem utilizar variavel
Private lA := .f.
Private lB := .f.
Private lC := .f.
Private lD := .f.
Private lE := .f.
//
SetKey(VK_F12,Nil)
//
cLayout := OA1200041_Profile(1,"LAYOUT","A") // Buscar Layout ( A/B/C/D/E )
&("l"+cLayout) := .t.
//
cOrdem := OA1200051_BrowsePermitido()
//
For nCntFor := 1 to len(cOrdem)
	Do Case
		Case substr(cOrdem,nCntFor,1) == "1"
			aAdd(aVetOrdem,{STR0008,"1"}) // Veículos/Máquinas
		Case substr(cOrdem,nCntFor,1) == "2"
			aAdd(aVetOrdem,{STR0009,"2"}) // Balcão Peças
		Case substr(cOrdem,nCntFor,1) == "3"
			aAdd(aVetOrdem,{STR0010,"3"}) // Oficina Peças
		Case substr(cOrdem,nCntFor,1) == "4"
			aAdd(aVetOrdem,{STR0011,"4"}) // Oficina Serviços
	EndCase
Next
//
If len(aVetOrdem) == 0

	MsgInfo(STR0012,STR0007) // Usuário sem permissão. / Atenção

Else

	cTela100 := OA1200041_Profile(1,"TELA100","N") // Buscar se a Tela 100% ? ( S/N )
	If cTela100 == "S"
		lTela100 := .t.
	EndIf

	DEFINE MSDIALOG oOA120PARAM FROM 0,0 TO 265,850 TITLE STR0013 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // PARAMETROS
		//
		@ 05,005 TO 110,310 LABEL STR0014 OF oOA120PARAM PIXEL // Layout tela
		//
		@ 15,010 TO 105,065 LABEL "" OF oOA120PARAM PIXEL
		@ 20,035 CHECKBOX oA VAR lA PROMPT "" OF oOA120PARAM ON CLICK OA1200021_ClickLayout("A",@cLayout) SIZE 08,08 PIXEL
		@ 30,015 MSGET oAO VAR cSTR0015 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // Oportunidade
		@ 45,015 MSGET oA1 VAR cSTR0016 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // 1º Interesse
		@ 60,015 MSGET oA2 VAR cSTR0017 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // 2º Interesse
		@ 75,015 MSGET oA3 VAR cSTR0018 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // 3º Interesse
		@ 90,015 MSGET oA4 VAR cSTR0019 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // 4º Interesse

		@ 15,070 TO 105,125 LABEL "" OF oOA120PARAM PIXEL
		@ 20,095 CHECKBOX oB VAR lB PROMPT "" OF oOA120PARAM ON CLICK OA1200021_ClickLayout("B",@cLayout) SIZE 08,08 PIXEL
		@ 30,075 MSGET oBO VAR cSTR0015 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // Oportunidade
		@ 45,075 MSGET oB1 VAR cSTR0016 PICTURE "@!" SIZE 20,08 OF oOA120PARAM PIXEL WHEN .f. // 1º Interesse
		@ 45,100 MSGET oB2 VAR cSTR0017 PICTURE "@!" SIZE 20,08 OF oOA120PARAM PIXEL WHEN .f. // 2º Interesse
		@ 60,075 MSGET oB3 VAR cSTR0018 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // 3º Interesse
		@ 75,075 MSGET oB4 VAR cSTR0019 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // 4º Interesse

		@ 15,130 TO 105,185 LABEL "" OF oOA120PARAM PIXEL
		@ 20,155 CHECKBOX oC VAR lC PROMPT "" OF oOA120PARAM ON CLICK OA1200021_ClickLayout("C",@cLayout) SIZE 08,08 PIXEL
		@ 30,135 MSGET oCO VAR cSTR0015 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // Oportunidade
		@ 45,135 MSGET oC1 VAR cSTR0016 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // 1º Interesse
		@ 60,135 MSGET oC2 VAR cSTR0017 PICTURE "@!" SIZE 20,08 OF oOA120PARAM PIXEL WHEN .f. // 2º Interesse
		@ 60,160 MSGET oC3 VAR cSTR0018 PICTURE "@!" SIZE 20,08 OF oOA120PARAM PIXEL WHEN .f. // 3º Interesse
		@ 75,135 MSGET oC4 VAR cSTR0019 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // 4º Interesse

		@ 15,190 TO 105,245 LABEL "" OF oOA120PARAM PIXEL
		@ 20,215 CHECKBOX oD VAR lD PROMPT "" OF oOA120PARAM ON CLICK OA1200021_ClickLayout("D",@cLayout) SIZE 08,08 PIXEL
		@ 30,195 MSGET oDO VAR cSTR0015 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // Oportunidade
		@ 45,195 MSGET oD1 VAR cSTR0016 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // 1º Interesse
		@ 60,195 MSGET oD2 VAR cSTR0017 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // 2º Interesse
		@ 75,195 MSGET oD3 VAR cSTR0018 PICTURE "@!" SIZE 20,08 OF oOA120PARAM PIXEL WHEN .f. // 3º Interesse
		@ 75,220 MSGET oD4 VAR cSTR0019 PICTURE "@!" SIZE 20,08 OF oOA120PARAM PIXEL WHEN .f. // 4º Interesse

		@ 15,250 TO 105,305 LABEL "" OF oOA120PARAM PIXEL
		@ 20,275 CHECKBOX oE VAR lE PROMPT "" OF oOA120PARAM ON CLICK OA1200021_ClickLayout("E",@cLayout) SIZE 08,08 PIXEL
		@ 30,255 MSGET oEO VAR cSTR0015 PICTURE "@!" SIZE 45,08 OF oOA120PARAM PIXEL WHEN .f. // Oportunidade
		@ 45,255 MSGET oE1 VAR cSTR0016 PICTURE "@!" SIZE 20,08 OF oOA120PARAM PIXEL WHEN .f. // 1º Interesse
		@ 45,280 MSGET oE2 VAR cSTR0017 PICTURE "@!" SIZE 20,08 OF oOA120PARAM PIXEL WHEN .f. // 2º Interesse
		@ 60,255 MSGET oE3 VAR cSTR0018 PICTURE "@!" SIZE 20,08 OF oOA120PARAM PIXEL WHEN .f. // 3º Interesse
		@ 60,280 MSGET oE4 VAR cSTR0019 PICTURE "@!" SIZE 20,08 OF oOA120PARAM PIXEL WHEN .f. // 4º Interesse

		@ 05,315 TO 080,423 LABEL STR0020 OF oOA120PARAM PIXEL // Ordem dos Interesses
		@ 15,320 LISTBOX oLbOrdem FIELDS HEADER "",STR0021 COLSIZES 10,40 SIZE 080,060 OF oOA120PARAM PIXEL // Sequencia

		oLbOrdem:SetArray(aVetOrdem)
		oLbOrdem:bLine := { || { strzero(oLbOrdem:nAt,1)+"º" , aVetOrdem[oLbOrdem:nAt,1] }}
		@ 28,403 BUTTON oSobe  PROMPT "/\" OF oOA120PARAM SIZE 15,15 PIXEL ACTION OA1200031_OrdemBrowses(@aVetOrdem,"/\",oLbOrdem:nAt,@cOrdem)
		@ 48,403 BUTTON oDesce PROMPT "\/" OF oOA120PARAM SIZE 15,15 PIXEL ACTION OA1200031_OrdemBrowses(@aVetOrdem,"\/",oLbOrdem:nAt,@cOrdem)

		@ 85,315 TO 110,423 LABEL STR0022 OF oOA120PARAM PIXEL // Tela
		@ 96,320 CHECKBOX oTela100 VAR lTela100 PROMPT STR0023 OF oOA120PARAM ON CLICK ( cTela100 := IIf(lTela100,"S","N") ) SIZE 150,08 PIXEL // Ajusta o tamanho da tela para 100%

		DEFINE SBUTTON FROM 115,355 TYPE 1 ACTION (lOkTela := .t. , oOA120PARAM:End()) ENABLE OF oOA120PARAM
		DEFINE SBUTTON FROM 115,390 TYPE 2 ACTION (oOA120PARAM:End()) ENABLE OF oOA120PARAM
		//
	ACTIVATE MSDIALOG oOA120PARAM CENTER

	If lOkTela
		//
		OA1200041_Profile(2,"LAYOUT" ,cLayout ) // Gravar Layout - ( A/B/C/D/E )
		OA1200041_Profile(2,"ORDEM"  ,cOrdem  ) // Gravar Ordem - ( 1234 )
		OA1200041_Profile(2,"TELA100",cTela100) // Gravar se a Tela é 100% ? ( S/N )
		//
		MsgAlert(STR0024,STR0007) // Para que as Configurações tenham efeito, será necessário fechar e abrir a rotina novamente. / Atenção
		//
	EndIf

EndIf

SetKey(VK_F12,{ || OA1200011_F12Parametros() })

Return

/*/{Protheus.doc} OA1200021_ClickLayout
	Click no Layout desejado dos Browse's de Veiculos / Balcao / Oficina

	@author Andre Luis Almeida
	@since 21/01/2019
/*/
Static Function OA1200021_ClickLayout(cTp,cLayout)
lA := lB := lC := lD := lE := .f.
&("l"+cTp) := .t.
cLayout := cTp
oA:Refresh()
oB:Refresh()
oC:Refresh()
oD:Refresh()
oE:Refresh()
Return

/*/{Protheus.doc} OA1200031_OrdemBrowses
	Ordem dos Browse's de Veiculos / Balcao / Oficina

	@author Andre Luis Almeida
	@since 21/01/2019
/*/
Static Function OA1200031_OrdemBrowses(aVetOrdem,cTp,nLin,cOrdem)
Local aAux    := {}
Local nAux    := 0
Local nCntFor := 0
If cTp == "/\" // Sobe
	If nLin <> 1
		nAux := nLin-1 // Voltar 1 linha
	EndIf
Else // cTp == "\/" // Desce
	If nLin <> len(aVetOrdem)
		nAux := nLin+1 // Avancar 1 linha
	EndIf
EndIf
If nAux > 0
	aAux := { aVetOrdem[nLin,1] , aVetOrdem[nLin,2] }
	aVetOrdem[nLin,1] := aVetOrdem[nAux,1]
	aVetOrdem[nLin,2] := aVetOrdem[nAux,2]
	aVetOrdem[nAux,1] := aAux[1]
	aVetOrdem[nAux,2] := aAux[2]
	oLbOrdem:nAt := nAux
	oLbOrdem:Refresh()
	cOrdem := ""
	For nCntFor := 1 to len(aVetOrdem)
		cOrdem += aVetOrdem[nCntFor,2]
	Next
EndIf
Return

/*/{Protheus.doc} OA1200041_Profile
	Profile Ler/Gravar parametros

	@author Andre Luis Almeida
	@since 21/01/2019
/*/
Static Function OA1200041_Profile(nTp,cParametro,cConteudo)
Local cRet     := ""
Local oProfile := FWProfile():New()
oProfile:SetTask("OFIA120")
oProfile:SetType(cParametro)
If nTp == 1 // Leitura do Profile
	oProfile:Load()
	cRet := oProfile:GetStringProfile()
	If Empty(cRet)
		cRet := cConteudo
	EndIf
Else // nTp == 2 Gravacao do Profile
	oProfile:SetStringProfile(cConteudo)
	oProfile:Save()
	oProfile:Destroy()
EndIf
Return cRet

/*/{Protheus.doc} OA1200051_BrowsePermitido
	Browse's permitidos para o usuario

	@author Andre Luis Almeida
	@since 22/01/2019
/*/
Function OA1200051_BrowsePermitido()
Local nPos   := 0
Local cOrdem := OA1200041_Profile(1,"ORDEM","1234") // Buscar Ordem dos Browse ( 1234 )
//
VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI") + __cUserID))
//
// Interesse de Veiculos/Maquinas
If ( "1" $ cOrdem )
	If VAI->VAI_OPIVEI <> "1" // NAO Permitido
		cOrdem := StrTran( cOrdem , "1" , "" )
	EndIf
Else
	If VAI->VAI_OPIVEI == "1" // Permitido
		cOrdem += "1"
	EndIf
EndIf
//
// Interesse de Peças Balcao
If ( "2" $ cOrdem )
	If VAI->VAI_OPIBAL <> "1" // NAO Permitido
		cOrdem := StrTran( cOrdem , "2" , "" )
	EndIf
Else
	If VAI->VAI_OPIBAL == "1" // Permitido
		cOrdem += "2"
	EndIf
EndIf
//
// Interesse de Peças Oficina
If ( "3" $ cOrdem )
	If VAI->VAI_OPIOFP <> "1" // NAO Permitido
		cOrdem := StrTran( cOrdem , "3" , "" )
	EndIf
Else
	If VAI->VAI_OPIOFP == "1" // Permitido
		cOrdem += "3"
	EndIf
EndIf
//
// Interesse de Serviços Oficina
If ( "4" $ cOrdem )
	If VAI->VAI_OPIOFS <> "1" // NAO Permitido
		cOrdem := StrTran( cOrdem , "4" , "" )
	EndIf
Else
	If VAI->VAI_OPIOFS == "1" // Permitido
		cOrdem += "4"
	EndIf
EndIf
//
Return cOrdem

/*/{Protheus.doc} OA1200061_RefreshBrowse
	Refresh nos Browse's - necessario pois zera Browse do lado

	@author Andre Luis Almeida
	@since 11/02/2019
/*/
Function OA1200061_RefreshBrowse()
Local cOrdem  := OA1200051_BrowsePermitido()
Local nCntFor := 1
Local nAt     := oBrwVDL:At()
oBrwVDL:Gotop()
oBrwVDL:Goto(nAt)
For nCntFor := 1 to len(cOrdem)
	Do Case
		Case substr(cOrdem,nCntFor,1) == "1" // Browse Interesses de Veiculos/Maquinas
			oBrwVDM:Refresh() // Veiculos/Maquinas
		Case substr(cOrdem,nCntFor,1) == "2" // Browse Interesses de Balcão de Peças
			oBrwVDQ:Refresh() // Pecas Balcao
		Case substr(cOrdem,nCntFor,1) == "3" // Browse Interesses de Oficina Peças
			oBrwVDI:Refresh() // Pecas Oficina
		Case substr(cOrdem,nCntFor,1) == "4" // Browse Interesses de Oficina Serviços
			oBrwVDJ:Refresh() // Servicos Oficina
	EndCase
Next
Return