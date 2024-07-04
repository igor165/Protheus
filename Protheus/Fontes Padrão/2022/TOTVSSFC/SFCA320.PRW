#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'SFCA320.CH'
#DEFINE PULALINHA CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA320
Importação de Apontamento
@author Ezequiel Ramos
@since 11/04/2014
@version P11
/*/
//-------------------------------------------------------------------
Function SFCA320()
	Local aFlds
	Local aCoors     := FWGetDialogSize( oMainWnd )//3-altura,4-largura
	Local aFldCYV    := GetCYVFld()
	Local aFldCYX    := GetCYXFld()
	Local aFldCYTM   := GetCYTFldM()
	Local aFldCYTS   := GetCYTFldS()
	Local aFldCZP    := GetCZPFld()
	Local aFldCYW    := GetCYWFld()
	Local aFldCZ0    := GetCZ0Fld()
	Local aFldCY0    := GetCY0Fld()
	Local aFldCZW    := GetCZWFld()
	Private aCampos1 := {{'',"","","","","","",""}}
	Private aCampos2 := {{'',"","","","","","",""}}
	Private aCampos3 := {{'',"","","","","","",""}}
	Private nRadio1  := 1
	Private nRadio3  := 1
	Private oList1,oList2,oList3

	Default lAutomacao := .F.
	
	IF IsBlind() .Or. lAutomacao
		Scheddef()
		
		WndSelFile(aFlds)
	Else
	
		Define MsDialog oDlg TITLE STR0001 From aCoors[1], aCoors[2] To aCoors[3]-2, aCoors[4]-2 PIXEL //"Importação de Apontamento"
	
		@ 000, 000 FOLDER oFolder1 SIZE (aCoors[4]/2), (aCoors[3]/2)-14 OF oDlg ITEMS STR0002,STR0003,STR0004 COLORS 0, 14215660 Pixel //"Apontamento Produção","Apontamento Parada","Apontamento Item Controle" 
		oDlg:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
	
		//Lista Apontamento de Produção
		oList1 := TWBrowse():New( 05, 05, (aCoors[4]/2)-10, ((aCoors[3]/2)-14)-20,,{'',STR0005,STR0006,STR0007,STR0008,STR0009,STR0010,STR0011},{10,50,80,30,30,30,80,80},oFolder1:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Nome Campo","Descrição","Tipo","Tamanho","Decimais","Máscara","Obrigatório"
		oList1:SetArray(aCampos1)
		oList1:bLine := {|| {aCampos1[oList1:nAT,1],aCampos1[oList1:nAT,2],aCampos1[oList1:nAT,3],aCampos1[oList1:nAT,4],aCampos1[oList1:nAT,5],aCampos1[oList1:nAT,6],aCampos1[oList1:nAT,7], aCampos1[oList1:nAT,8]}}
	
		//Lista Apontamento de Produção
		oList2 := TWBrowse():New( 05, 05, (aCoors[4]/2)-10, ((aCoors[3]/2)-14)-20,,{'',STR0005,STR0006,STR0007,STR0008,STR0009,STR0010,STR0011},{10,50,80,30,30,30,80,80},oFolder1:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Nome Campo","Descrição","Tipo","Tamanho","Decimais","Máscara","Obrigatório"
		oList2:SetArray(aCampos2)
		oList2:bLine := {|| {aCampos2[oList2:nAT,1],aCampos2[oList2:nAT,2],aCampos2[oList2:nAT,3],aCampos2[oList2:nAT,4],aCampos2[oList2:nAT,5],aCampos2[oList2:nAT,6],aCampos2[oList2:nAT,7], aCampos2[oList2:nAT,8]}}
	
		//Lista Apontamento de Produção
		oList3 := TWBrowse():New( 05, 05, (aCoors[4]/2)-10, ((aCoors[3]/2)-14)-20,,{'',STR0005,STR0006,STR0007,STR0008,STR0009,STR0010,STR0011},{10,50,80,30,30,30,80,80},oFolder1:aDialogs[3],,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Nome Campo","Descrição","Tipo","Tamanho","Decimais","Máscara","Obrigatório"
		oList3:SetArray(aCampos3)
		oList3:bLine := {|| {aCampos3[oList3:nAT,1],aCampos3[oList3:nAT,2],aCampos3[oList3:nAT,3],aCampos3[oList3:nAT,4],aCampos3[oList3:nAT,5],aCampos3[oList3:nAT,6],aCampos3[oList3:nAT,7], aCampos2[oList2:nAT,8]}}
	
		/*
		1-Apontamento Produção (CYV) – Registro Pai
		2-Componente (CZP)
		3-Recurso(CYW)
		4-Ferramenta (CZ0)
		5-Refugo (CY0)
		6-GGF (CZW)
		7-Apontamento Parada  (CYX) – Registro Pai
		8-MOD Parada (CZ6)
		9-Apontamento Item Controle (CYT) – Registro Pai
		10-Apontamento Item Controle (CYT)
		*/
	
		aFlds := {aFldCYV,aFldCZP,aFldCYW,aFldCZ0,aFldCY0,aFldCZW,aFldCYX,/*aFldCZ6*/,aFldCYTM,aFldCYTS}
	
		RefFldVal("CYV", aFlds[1][1], aFlds[1][2], @oList1, @aCampos1,1)
		RefFldVal("CYX", aFlds[7][1], aFlds[7][2], @oList2, @aCampos2,7)
		RefFldVal("CYT", aFlds[9][1], aFlds[9][2], @oList3, @aCampos3,9)
	
		//Painel com botões
		oPanel1 := TPanel():New( (aCoors[3]/2)-14, 0, ,oDlg, , , , , , (aCoors[4]/2), 14, .F.,.T. )
		@ 0,((aCoors[4]/2)-184) BUTTON oBtnAvanca PROMPT STR0012 SIZE 60,12 ACTION (WndSelFile(aFlds)) OF oPanel1 PIXEL //"Importar"
		@ 0,((aCoors[4]/2)-122) BUTTON oBtnAvanca PROMPT STR0015 SIZE 60,12 ACTION (WndFilter(aFlds)) OF oPanel1 PIXEL //"Filtro"
		@ 0,((aCoors[4]/2)-60)  BUTTON oBtnAvanca PROMPT STR0014 SIZE 60,12 ACTION (oDlg:End()) OF oPanel1 PIXEL //"Sair"
		
		SetKey(VK_F12,{|| WndFilter(aFlds)})
		
		Activate MsDialog oDlg CENTERED
	Endif
	
Return Nil

//-------------------------------------------------------------------
// Menu para tela de Apontamento de Produção
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Return aRotina 

//-------------------------------------------------------------------
//Window Filter - Janela com Filtro para Lists
//-------------------------------------------------------------------
Static Function WndFilter(aFlds)
	Local nLargura := 300
	Local nAltura  := 200
	
	Default lAutomacao := .F.
	
	IF !lAutomacao
		Define DIALOG oDlgFiltro TITLE STR0015  From 0, 0 To 22, 75 SIZE nLargura, nAltura PIXEL
		@ 0, 0 FOLDER oFolderFiltro SIZE (nLargura/2), (nAltura/2) OF oDlgFiltro ITEMS STR0002,STR0004 COLORS 0, 14215660 PIXEL
		@ 5, 5 RADIO oRadio1 VAR nRadio1 ITEMS STR0016, STR0017, STR0018,STR0019,STR0020,STR0021 SIZE 100,9 ON CHANGE RefList1(nRadio1,aFlds) PIXEL OF oFolderFiltro:aDialogs[1] //"Apontamento Produção (Pai)", "Componente", "Recurso","Ferramenta","Refugo","GGF"
		@ 5, 5 RADIO oRadio3 VAR nRadio3 ITEMS STR0022, STR0004 SIZE 100,9 ON CHANGE RefList3(nRadio3,aFlds) PIXEL OF oFolderFiltro:aDialogs[2] //"Apontamento Item Controle (Pai)", "Apontamento Item Controle"
		Activate MsDialog oDlgFiltro CENTERED
	ENDIF
	
Return Nil

//-------------------------------------------------------------------
//Refresh List1 - Atualiza List1
//-------------------------------------------------------------------
Static Function RefList1(nRadio,aFlds)

	Do Case
		Case nRadio == 1
			RefFldVal("CYV", aFlds[1][1], aFlds[1][2], @oList1, @aCampos1,1)
		Case nRadio == 2
			RefFldVal("CZP", aFlds[2][1], aFlds[2][2], @oList1, @aCampos1,2)
		Case nRadio == 3
			RefFldVal("CYW", aFlds[3][1], aFlds[3][2], @oList1, @aCampos1,3)
		Case nRadio == 4
			RefFldVal("CZ0", aFlds[4][1], aFlds[4][2], @oList1, @aCampos1,4)
		Case nRadio == 5
			RefFldVal("CY0", aFlds[5][1], aFlds[5][2], @oList1, @aCampos1,5)
		Case nRadio == 6
			RefFldVal("CZW", aFlds[6][1], aFlds[6][2], @oList1, @aCampos1,6)
	EndCase
	
Return Nil

//-------------------------------------------------------------------
//Refresh List3 - Atualiza List3
//-------------------------------------------------------------------
Static Function RefList3(nRadio,aFlds)

	Do Case
		Case nRadio == 1
			RefFldVal("CYT", aFlds[9][1], aFlds[9][2], @oList3, @aCampos3,9)
		Case nRadio == 2
			RefFldVal("CYT", aFlds[10][1],aFlds[10][2],@oList3, @aCampos3,10)
	EndCase
	
Return Nil

//-------------------------------------------------------------------
// Pega os campos marotos
//-------------------------------------------------------------------
Static Function GetFields(cTabela,aFldFilS,aFldFilO,nTipo)
	Local nI, nJ, nX
	Local oOk    := LoadBitmap( GetResources(), "LBOK" )
	Local oNOk   := LoadBitmap( GetResources(), "LBNO" )
	Local aCmpsS := {}
	Local aCmpsO := {}
	Local lAchou := .T.
	Local temp
	Local Struct := FWFormStruct(3,cTabela)
	Local nPos := 0
	Local nPos2 := 0

	Default lAutomacao := .F.
	
	aAdd(aCmpsS,{1,   " ", STR0052, "N", 10, 0, "", oOk}) //"Nº Reporte"
	aAdd(aCmpsS,{2, nTipo, STR0053, "N",  2, 0, "", oOk}) //"Tipo Registro"
	
	nX := 2

	For nI := 1 To Len(aFldFilS)
	
		nPos := Ascan(Struct[1],{|x|Alltrim(x[3]) == aFldFilS[nI]})
		nPos2 := Ascan(Struct[3],{|x|Alltrim(x[1]) == aFldFilS[nI]})
		
		if nPos > 0
			nX++
			IF lAutomacao
				EXIT
			ENDIF
			aAdd(aCmpsS,{nX,aFldFilS[nI],Struct[1][nPos][2],Struct[1][nPos][4],Struct[1][nPos][5],Struct[1][nPos][6],Struct[3][nPos2][7],oOk})
		Endif
	Next
		
	For nI := 1 To Len(aFldFilO)
		nPos := Ascan(Struct[1],{|x|Alltrim(x[3]) == aFldFilO[nI]})
		nPos2 := Ascan(Struct[3],{|x|Alltrim(x[1]) == aFldFilO[nI]})
		
		if nPos > 0
			nX++
			IF lAutomacao
				EXIT
			ENDIF			
			aAdd(aCmpsS,{nX,aFldFilO[nI],Struct[1][nPos][2],Struct[1][nPos][4],Struct[1][nPos][5],Struct[1][nPos][6],Struct[3][nPos2][7],oNOk})
		Endif
	Next
	
	//Copia os campos opcionais e obrigatórios em uma array só
	For nI := 1 To Len(aCmpsO)
		aAdd(aCmpsS,aCmpsO[nI])
	Next
	
	//Verifica se faltou algum campo
	If Len(aCmpsS) != Len(aFldFilS) + Len(aFldFilO) + 2
		//Verifica se foi um campo obrigatório
		For nI := 2 To Len(aFldFilS)
			lAchou := .F.
			For nJ := 1 To Len(aCmpsS)
				If AllTrim(aFldFilS[nI]) == AllTrim(aCmpsS[nJ][1])
					lAchou := .T.
				EndIf
			Next
			If !lAchou
				MsgStop(STR0023 + " " + aFldFilS[nI] + ".") //"Dicionário desatualizado. Não foi possível encontrar o campo"
			EndIf
		Next
		
		//Verifica se foi um campo opcional
		For nI := 2 To Len(aFldFilO)
			lAchou := .F.
			For nJ := 1 To Len(aCmpsS)
				If AllTrim(aFldFilO[nI]) ==  AllTrim(aCmpsS[nJ][1]) .Or. lAutomacao
					lAchou := .T.
				EndIf
			Next
			If !lAchou .OR. lAutomacao
				MsgStop(STR0023 + " " + aFldFilO[nI] + ".") //"Dicionário desatualizado. Não foi possível encontrar o campo"
			EndIf
		Next
	Else
		//Organiza aCmps conforme aFldFilS e aFldFilO
		For nI := 1 To Len(aFldFilS)
			If aFldFilS[nI] != aCmpsS[nI+2][2]
				//Começa a repetição do terceiro campo, pois o primeiro e segundo são fixos
				For nJ := 3 To Len(aCmpsS)
					If AllTrim(aFldFilS[nI]) == AllTrim(aCmpsS[nJ][2])
						temp         := aCmpsS[nJ]
						aCmpsS[nJ]   := aCmpsS[nI+2]
						aCmpsS[nI+2] := temp
					EndIf
				Next
			EndIf
		Next
		
		//Organiza aCmps conforme aFldFilS e aFldFilO
		For nI := 1 To Len(aFldFilO)
			If aFldFilO[nI] != aCmpsS[Len(aFldFilS)+nI+2][2]
				//Começa a repetição do terceiro campo, pois o primeiro e segundo são fixos
				For nJ := 3 To Len(aCmpsS)
					If AllTrim(aFldFilO[nI]) == AllTrim(aCmpsS[nJ][2])
						temp       := aCmpsS[nJ]
						aCmpsS[nJ] := aCmpsS[nI + Len(aFldFilS) + 2]
						aCmpsS[nI + Len(aFldFilS) + 2] := temp
					EndIf
				Next
			EndIf
		Next
	EndIf
	
Return aCmpsS
//-------------------------------------------------------------------
//Refresh Field Value - Atualiza valores dos campos
//Parametros: Caractere Tabela, Caracte Campos Obrigatórios, Caracte Campos Opcionais, Objeto Lista, Array Campos(valores)
//-------------------------------------------------------------------
Static Function RefFldVal(cTabela,aFldFilS,aFldFilO,oList,aCampos,nTipo) 
	Local cReserv

	Default lAutomacao := .F.
	
	aCampos := GetFields(cTabela,aFldFilS,aFldFilO,nTipo)
	IF !lAutomacao
		oList:SetArray(aCampos)
		oList:bLine := {|| {aCampos[oList:nAT,1],aCampos[oList:nAT,2],aCampos[oList:nAT,3],aCampos[oList:nAT,4],aCampos[oList:nAT,5],aCampos[oList:nAT,6],aCampos[oList:nAT,7],aCampos[oList:nAT,8]}}
		oList:Refresh()
	ENDIF
	
Return Nil
//-------------------------------------------------------------------
//Window Selection File - Janela para selecionar Arquivo
//-------------------------------------------------------------------
Static Function WndSelFile(aFlds)
	Local nLargura     := 550
	Local nAltura      := 176
	Local lProd        := .T.
	Local lPara        := .T.
	Local lCont        := .T.
	Local cDelimitador := ";"
	Local lValida      := .T.
	Private cFile      := Space(99999)
	Private cFileSaida := ''

	Default lAutomacao := .F.
	
	if IsBlind()
		Scheddef()
		
		cFile      := alltrim(lower(MV_PAR01))
		cFileSaida := alltrim(lower(MV_PAR06))
		
		//CONOUT('cFileSaida:' + cFileSaida)
		
		IF !lAutomacao
			ValidFile(.T.,if(MV_PAR03==1,.t.,.f.),if(MV_PAR04==1,.t.,.f.),if(MV_PAR05==1,.t.,.f.),MV_PAR02,aFlds)
		ENDIF
	Else
	
		DEFINE DIALOG oDlgWOF TITLE STR0024 FROM 0, 0 TO 22, 75 SIZE nLargura, nAltura PIXEL //"Seleção Importação"
		
		//Painel Origem
		oPanelOrigem   := TPanel():New( 005, 005, ,oDlgWOF, , , , , , (nLargura/4)-10, (nAltura/2)-19, .F.,.T. )
		@ 00,000 SAY oSay  VAR STR0025 OF oPanelOrigem FONT (TFont():New('Arial',0,-13,.T.,.T.)) PIXEL //"Origem"
		@ 18,005 SAY oAcao VAR STR0026 OF oPanelOrigem PIXEL //"Arquivo:" 
		@ 27,005 MSGET cFile SIZE 100,010 OF oPanelOrigem WHEN .T. PIXEL
		@ 27,105 BUTTON oBtnAvanca PROMPT STR0027 SIZE 15,12 ACTION (SelectFile()) OF oPanelOrigem PIXEL //"Abrir" 
		@ 41,005 SAY oAcao VAR STR0028 OF oPanelOrigem PIXEL //"Delimitador:" 
		@ 50,005 MSGET cDelimitador SIZE 030,010 OF oPanelOrigem WHEN .T. PIXEL
		@ 50,050 CHECKBOX oValida VAR lValida PROMPT STR0054 SIZE 80,10 Of oPanelOrigem PIXEL WHEN .T. // 'Apenas Validar'
		
		//Painel Importar
		oPanelImportar := TPanel():New( 005, (nLargura/4)+5, ,oDlgWOF, , , , , , (nLargura/2)-10, (nAltura/2)-19, .F.,.T. )
		@ 00,0 SAY oSay VAR STR0012 OF oPanelImportar FONT (TFont():New('Arial',0,-13,.T.,.T.)) PIXEL
		@ 20,5 CHECKBOX oChkProd VAR lProd PROMPT STR0029 SIZE 80,10 Of oPanelImportar PIXEL WHEN .T. //"Produção"
		@ 30,5 CHECKBOX oChkPara VAR lPara PROMPT STR0030 SIZE 80,10 Of oPanelImportar PIXEL WHEN .T. //"Parada"
		@ 40,5 CHECKBOX oChkCont VAR lCont PROMPT STR0031 SIZE 80,10 Of oPanelImportar PIXEL WHEN .T. //"Item Controle"
		
		//Painel com botões
		oPanelBtn := TPanel():New( (nAltura/2)-14, 0, ,oDlgWOF, , , , , , (nLargura/2), 14, .F.,.T. )
		@ 000,((nLargura/2)-122) BUTTON oBtnAvanca PROMPT STR0032  SIZE 60,12 ACTION RptStatus( {|lEnd| ValidFile(!lValida,lProd,lPara,lCont,cDelimitador,aFlds) }, STR0055, if(lValida,STR0056,STR0057) ) OF oPanelBtn PIXEL //"Confirmar" ## 'Aguarde' ## 'Validando..' ## 'Importando..'
		@ 000,((nLargura/2)-60)  BUTTON oBtnAvanca PROMPT STR0033  SIZE 60,12 ACTION (oDlgWOF:End()) OF oPanelBtn PIXEL //"Cancelar"
			
		ACTIVATE MSDIALOG oDlgWOF CENTER
	Endif
	
Return Nil
//-------------------------------------------------------------------
//Valid File - Valida o arquivo
//-------------------------------------------------------------------
Static Function ValidFile(lImporta,lProd,lPara,lCont,cDelimitador,aFlds)
	Local nI, nJ
	Local nHandle
	Local aModels
	Local oModelCYV,oModelCYVM,oModelCZP,oModelCYW,oModelCZ0,oModelCY0,oModelCZW
	Local oModelCYT,oModelCYTM,oModelCYTS,oModelCYX,oModelCYXM
	Local nTipo        := 0
	Local nTipoAnt     := 0
	Local aDados       := {}
	Local cLinha       := ""
	Local lErro	       := .F.
	Local lErroLinha   := .F.
	Local lContinua    := .T.
	Local lAchou       := .F.
	Local lHlpDark
	Local cLabel       := ''
	Local lErroArq     := .F.
	Local nQuant       := 0

	Default lAutomacao := .F.
	
	If !lProd .AND. !lPara .AND. !lCont
		MsgStop(STR0034) //"Preencha pelo menos um tipo de importação."
		Return Nil
	EndIf
	
	lHlpDark := HelpInDark(.T.)
	
	If FOpen(cFile) > 0 .Or. lAutomacao
		//Lê o arquivo completo
		FT_FUSE(cFile)
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			cLinha := FT_FREADLN()
			aAdd(aDados,Separa(cLinha,cDelimitador,.T.))
			IF lAutomacao
				EXIT
			ENDIF
			FT_FSKIP()
		EndDo
		FT_FUSE()
		
		// Arquivo de erros
		if IsBlind()
			nHandle := FCreate(alltrim(cFileSaida),0)
						
			FWrite(nHandle, 'Importando arquivo ' + alltrim(cFile) + " em " + ALLTRIM(DTOC(DATE())) + " " + TIME() + PULALINHA)
		Else
			nHandle := FCreate(GETTEMPPATH() + "errosImportacao.log")
		Endif
		
		// Eliminado do array os caras que não serão importados
		For nI := Len(aDados) to 1 Step - 1
			if Empty(aDados[nI])
				ADel(aDados,nI)
				nQuant++
			Else			
				aDados[nI][2] := VAL(aDados[nI][2])
			
				If (!lProd .AND. (aDados[nI][2] == 1 .OR. aDados[nI][2] == 2 .OR. aDados[nI][2] == 3 .OR.;
								 aDados[nI][2] == 4 .OR. aDados[nI][2] == 5 .OR. aDados[nI][2] == 6)) .OR.;
				   (!lPara .AND. aDados[nI][2] == 7 ) .OR.;
				   (!lCont .AND. (aDados[nI][2] == 9 .OR. aDados[nI][2] == 10 ))
				   ADel(aDados,nI)
				   nQuant++
				Endif
			Endif
		Next
		
		// Tira a quantidade que foi tirada
		IF !lAutomacao
			ASIZE(aDados,Len(aDados) - nQuant)
		ELSE
			aDados := {{"", 10,"","","","","","","","","","","","","","","","","","","","","",""}}
		ENDIF
		
		IF !IsBlind()
			if lImporta
				SetRegua(Len(aDados) * 2 + 2)
			Else
				SetRegua(Len(aDados))
			Endif
		Endif
		
		For nI := 1 to Len(aDados)
			IF !IsBlind()
				IncRegua()
			Endif
			
			if (nI == 1 .OR. aDados[nI][1] != aDados[nI - 1][1])
				if aDados[nI][2] != 1 .AND. aDados[nI][2] != 7 .AND. aDados[nI][2] != 9
					FWrite(nHandle, STR0036 + ALLTRIM(STR(nI)) + ': ' + 'Na troca de sequência, o primeiro registro deve ser tipo 1,7 ou 9' + PULALINHA) // 'Linha ' ## "Tipo de registro inválido na linha."
					lErroArq := .T.
				Endif
			Endif
		
			if aDados[nI][2] < 1 .OR. aDados[nI][2] > 10 .OR. aDados[nI][2] == 8
				FWrite(nHandle, STR0036 + ALLTRIM(STR(nI)) + ': ' + STR0042 + PULALINHA) // 'Linha ' ## "Tipo de registro inválido na linha."
			Else
				Do Case
					Case aDados[nI][2] == 1 // Produção
						if Len(aDados[nI]) < 24
							lErro := .T.
						Endif
					Case aDados[nI][2] == 2 // Componente
						if Len(aDados[nI]) < 4
							lErro := .T.
						Endif
					Case aDados[nI][2] == 3 // Recurso
						if Len(aDados[nI]) < 8
							lErro := .T.
						Endif
					Case aDados[nI][2] == 4 // Ferramenta
						if Len(aDados[nI]) < 3
							lErro := .T.
						Endif
					Case aDados[nI][2] == 5 // Refugo
						if Len(aDados[nI]) < 5
							lErro := .T.
						Endif
					Case aDados[nI][2] == 6 // GGF
						if Len(aDados[nI]) < 4
							lErro := .T.
						Endif
					Case aDados[nI][2] == 7 // Parada
						if Len(aDados[nI]) < 12
							lErro := .T.
						Endif
					Case aDados[nI][2] == 8 // Não utilizado
					Case aDados[nI][2] == 9 // Item Controle Pai
						if Len(aDados[nI]) < 5
							lErro := .T.
						Endif
					Case aDados[nI][2] == 10 // Item Controle Filho
						if Len(aDados[nI]) < 6
							lErro := .T.
						Endif
				End Case
			Endif
		
			if lErro 
				FWrite(nHandle, STR0036 + ALLTRIM(STR(nI)) + ': ' + STR0058 + PULALINHA) // 'Linha ' ## 'Faltam dados para importação.'
				lErro := .F.
				lErroArq := .T.
			Endif
		Next
		
		IF !lErroArq .AND. lImporta .Or. lAutomacao
		
			Begin Transaction
			
				//Models Apontamento Produção  - CYV		
				oModelCYV	:= FwLoadModel( 'SFCA316' )
				oModelCYVM	:= oModelCYV:GetModel( 'CYVMASTER' )
				oModelCZP	:= oModelCYV:GetModel( 'CZPDETAIL' )
				oModelCYW	:= oModelCYV:GetModel( 'CYWDETAIL' )
				oModelCZ0	:= oModelCYV:GetModel( 'CZ0DETAIL' )
				oModelCY0	:= oModelCYV:GetModel( 'CY0DETAIL' )
				oModelCZW	:= oModelCYV:GetModel( 'CZWDETAIL' )
				oModelCYV:SetOperation(3)
				
				IF !IsBlind()
					IncRegua()
				Endif
				
				//Models Apontamento Parada  - CYX
				oModelCYX	:= FwLoadModel( 'SFCA311' )
				oModelCYXM	:= oModelCYX:GetModel( 'CYXMASTER' )
				oModelCYX:SetOperation(3)
				
				IF !IsBlind()
					IncRegua()
				Endif
				
				//Models Apontamento Item Controle - CYT
				oModelCYT	:= FwLoadModel( 'SFCA312' )
				oModelCYTM	:= oModelCYT:GetModel( 'CYTMASTER' )
				oModelCYTS	:= oModelCYT:GetModel( 'CYTDETAIL' )
				oModelCYT:SetOperation(3)
				
				aModels	:= {oModelCYVM,oModelCZP,oModelCYW,oModelCZ0,oModelCY0,oModelCZW,oModelCYXM,/*oModelCZ6*/,oModelCYTM,oModelCYTS}
				aModelsCommit:={oModelCYV,,,,,,oModelCYX,,oModelCYT}
				
				For nI := 1 To Len(aDados)
					IF !IsBlind()
						IncRegua()
					Endif
				
					If Len(aDados[nI]) > 2 .Or. lAutomacao
						If aDados[nI][2] == 1 .OR. aDados[nI][2] == 2 .OR. aDados[nI][2] == 3 .OR.;
						   aDados[nI][2] == 4 .OR. aDados[nI][2] == 5 .OR. aDados[nI][2] == 6 .OR.;
						   aDados[nI][2] == 7 .OR. aDados[nI][2] == 9 .OR. aDados[nI][2] == 10
					
							//Comita o model anterior se for diferente do atual
							If nI > 1 .AND. (aDados[nI][1] != aDados[nI-1][1] .OR. aDados[nI][2] == 7 .OR. aDados[nI][2] == 9) .Or. lAutomacao
								
								//Pega o tipo do reporte anterior
								IF !lAutomacao
									nTipoAnt := aDados[nI-1][2]
								ENDIF
								
								if nTipoAnt != 0 .Or. lAutomacao
								
									//Procura o model pai
									While nTipoAnt != 1 .AND. nTipoAnt != 7 .AND. nTipoAnt != 9
										nTipoAnt--
										IF lAutomacao
											EXIT
										ENDIF
									End
									
									if nTipoAnt == 1 .OR. nTipoAnt == 9 .Or. lAutomacao
										if lErroLinha .Or. lAutomacao
											lContinua  := .F.
											lErroLinha := .F.
										Endif
									Endif
									
									//Valida e commita ou apresenta mensagem de erro
									If lContinua .Or. lAutomacao
										IF !lAutomacao .And. aModelsCommit[nTipoAnt]:VldData()
											aModelsCommit[nTipoAnt]:CommitData()
										Else
											lErro := .T.
											IF !lAutomacao
									  			aErro := aModelsCommit[nTipoAnt]:GetErrorMessage()
											ENDIF						  		
											
											cLabel := GetSx3Cache(alltrim(aErro[4]),'X3_TITULO')
									  		
									  		IF !Empty(cLabel)
									  			FWrite(nHandle, STR0036 + ALLTRIM(STR(nI - 1)) + ': ' + ALLTRIM( aErro[6] ) + if(Empty(cLabel),'',STR0059 + cLabel) + PULALINHA) // 'Linha ' ## ' Campo: '
									  		Else
									  			FWrite(nHandle, STR0036 + ALLTRIM(STR(nI - 1)) + ': ' + ALLTRIM( aErro[6] ) + PULALINHA) // 'Linha '
									  		Endif
										EndIf 
									Endif
									
									IF !lAutomacao
										aModelsCommit[nTipoAnt]:DeActivate()
									ENDIF

									lContinua := .T.
								Endif
							EndIf
							
							nTipo := aDados[nI][2]
						   
							If nTipo >= 2 .AND. nTipo <= 6 .AND. !aModels[nTipo]:CanInsertLine()
								lErro := .T.
								
								FWrite(nHandle, STR0036 + ALLTRIM(STR(nI)) + ': ' + STR0037 + PULALINHA) // 'Linha ' ## "Impossível registrar valores da linha. O grid está bloqueado para este tipo de inserção."
							Else

								Do Case
									Case nTipo == 1 .Or. lAutomacao// Produção - CYV
										lErroLinha := .F.
										
										dbSelectArea('CYY')
										CYY->(dbSetOrder(1))
										IF CYY->(dbSeek(xFilial('CYY')+Padr(aDados[nI][3],TamSx3("CYY_NRORPO")[1])+Padr(aDados[nI][4],TamSx3("CYY_IDAT")[1])+Padr(aDados[nI][5],TamSx3("CYY_IDATQO")[1]))) .Or. lAutomacao
										
											oModelCYV:Activate()
									
											oModelCYVM:SetValue('CYV_NRORPO', aDados[nI][3])
											oModelCYVM:SetValue('CYV_IDAT'  , aDados[nI][4])
											oModelCYVM:SetValue('CYV_IDATQO', aDados[nI][5])
											
											if oModelCYVM:SetValue('CYV_CDMQ'  , aDados[nI][6]) .Or. lAutomacao
											
												if !Empty(aDados[nI][20]) .Or. lAutomacao
													oModelCYVM:SetValue('CYV_DTBGSU', STOD(aDados[nI][20]))
													oModelCYVM:SetValue('CYV_HRBGSU', aDados[nI][21])
													oModelCYVM:SetValue('CYV_DTEDSU', STOD(aDados[nI][22]))
													oModelCYVM:SetValue('CYV_HREDSU', aDados[nI][23])
													oModelCYVM:SetValue('CYV_CDSU'  , aDados[nI][19])
												Endif
												
												if (Empty(aDados[nI][12]) .OR. VAL(aDados[nI][12]) == 0) .AND.;
												   (Empty(aDados[nI][13]) .OR. VAL(aDados[nI][13]) == 0) .Or. lAutomacao
													IF !Empty(aDados[nI][7]) .Or. lAutomacao 
														oModelCYVM:SetValue('CYV_QTATRP', VAL(aDados[nI][7]))
													Endif
												Else
													oModelCYVM:SetValue('CYV_NRBG', VAL(aDados[nI][12]))
													oModelCYVM:SetValue('CYV_NRED', VAL(aDados[nI][13]))
												Endif
												
												oModelCYVM:SetValue('CYV_VLPNRY', VAL(aDados[nI][24]))
												oModelCYVM:SetValue('CYV_DTRPBG', STOD(aDados[nI][8]))
												oModelCYVM:SetValue('CYV_HRRPBG', aDados[nI][9])
												oModelCYVM:SetValue('CYV_DTRPED', STOD(aDados[nI][10]))
												oModelCYVM:SetValue('CYV_HRRPED', aDados[nI][11]) 
												oModelCYVM:SetValue('CYV_NRDO'  , aDados[nI][14])
												oModelCYVM:SetValue('CYV_NRSR'  , aDados[nI][15])
												oModelCYVM:SetValue('CYV_CDDP'  , aDados[nI][16])
												oModelCYVM:SetValue('CYV_CDLOSR', aDados[nI][17])
												oModelCYVM:SetValue('CYV_DTVDLO', STOD(aDados[nI][18]))
											Endif
											
											if !Empty(oModelCYV:GetErrorMessage()[6])
												lErro      := .T.
												lErroLinha := .T.
												
												FWrite(nHandle, STR0036 + ALLTRIM(STR(nI)) + ': ' + alltrim(oModelCYV:GetErrorMessage()[4]) + ": " + oModelCYV:GetErrorMessage()[6] + PULALINHA) // 'Linha ' 
											Endif
										Else
											lErro      := .T.
											lErroLinha := .T.
	
											FWrite(nHandle, STR0036 + ALLTRIM(STR(nI)) + ': ' + STR0060 + PULALINHA) // 'Linha ' ## 'Não existe split com a chave informada'
										Endif
										
									Case nTipo == 2 // Componente - CZP
									
										lAchou := .F.
										
										IF !lErroLinha
									
											For nJ := 1 to oModelCZP:GetQtdLine()
												oModelCZP:GoLine(nJ)
												
												if ALLTRIM(oModelCZP:GetValue('CZP_CDMT')) == ALLTRIM(aDados[nI][3])
													oModelCZP:SetValue('CZP_QTRPPO', VAL(aDados[nI][4]))
													lAchou := .T.
													Exit
												Endif
											Next
											
											if !lAchou
												lErro    := .T.
												lErroLinha := .T.
		
												FWrite(nHandle, STR0036 + ALLTRIM(STR(nI)) + ': ' + STR0038 + ALLTRIM(aDados[nI][3]) + STR0039 + PULALINHA) // 'Linha ' ## 'O Componente ' ## ' não está relacionado à ordem de produção.'
											Endif
										Endif
										
									Case nTipo == 3 // Recurso - CYW
									
										if !lErroLinha
									
											IF oModelCYW:GetQtdLine() == 1 .AND. (!Empty(oModelCYW:GetValue('CYW_CDOE')) .AND. !Empty(oModelCYW:GetValue('CYW_CDGROE')))
												oModelCYW:AddLine()
											Endif
										
											oModelCYW:SetValue('CYW_DTBGRP', STOD(aDados[nI][3]))
											oModelCYW:SetValue('CYW_HRBGRP', aDados[nI][4])
											oModelCYW:SetValue('CYW_DTEDRP', STOD(aDados[nI][5]))
											oModelCYW:SetValue('CYW_HREDRP', aDados[nI][6])
											oModelCYW:SetValue('CYW_CDGROE', aDados[nI][7])
											oModelCYW:SetValue('CYW_CDOE'  , aDados[nI][8])
										Endif
										
									Case nTipo == 4 // Ferramenta - CZ0
									
										if !lErroLinha
											IF oModelCZ0:GetQtdLine() == 1 .AND. (!Empty(oModelCZ0:GetValue('CZ0_CDFE')))
												oModelCZ0:AddLine()
											Endif
										
											oModelCZ0:SetValue('CZ0_CDFE', aDados[nI][3])
										Endif
										
									Case nTipo == 5 // Refugo - CY0
									
										if !lErroLinha
											IF oModelCY0:GetQtdLine() == 1 .AND. !Empty(oModelCY0:GetValue('CY0_CDRF'))
												oModelCY0:AddLine()
											Endif
									
											oModelCY0:SetValue('CY0_CDRF', aDados[nI][3])
										
											IF !Empty(aDados[nI][4])
												oModelCY0:SetValue('CY0_QTRF', VAL(aDados[nI][4]))
											Endif
										
											if !Empty(aDados[nI][5])
												oModelCY0:SetValue('CY0_QTRT', VAL(aDados[nI][5]))
											Endif
										Endif
										
									Case nTipo == 6 // GGF - CZW
										lAchou := .F.
										
										if !lErroLinha
										
											For nJ := 1 to oModelCZW:GetQtdLine()
												oModelCZW:GoLine(nJ)
										
												if !oModelCZW:IsDeleted()
													if ALLTRIM(oModelCZW:GetValue('CZW_CDCETR')) == ALLTRIM(aDados[nI][3])
														oModelCZW:SetValue('CZW_HRTEGF', VAL(aDados[nI][4]))
														lAchou := .T.
														Exit
													Endif
												Endif
											Next
										
											IF !lAchou
												IF oModelCZW:GetQtdLine() > 1 .OR. (oModelCZW:GetQtdLine() == 1 .AND. !Empty(oModelCZW:GetValue('CZW_CDCETR')))
													oModelCZW:AddLine()
												Endif
										
												oModelCZW:SetValue('CZW_CDCETR', aDados[nI][3])
												oModelCZW:SetValue('CZW_HRTEGF', VAL(aDados[nI][4]))
											Endif
										Endif
									
									Case nTipo == 7 // Parada - CYX
									
										oModelCYX:Activate()
									
										oModelCYXM:SetValue('CYX_CDMQ'  , aDados[nI][3])
										oModelCYXM:SetValue('CYX_CDSP'  , aDados[nI][4])
										
										oModelCYXM:SetValue('CYX_DTBGSP', STOD(aDados[nI][5]))
										oModelCYXM:SetValue('CYX_HRBGSP', aDados[nI][6])
										oModelCYXM:SetValue('CYX_DTEDSP', STOD(aDados[nI][7]))
										oModelCYXM:SetValue('CYX_HREDSP', aDados[nI][8])
										oModelCYXM:SetValue('CYX_NRSQSP', aDados[nI][9])
										oModelCYXM:SetValue('CYX_CDFEPO', aDados[nI][10])
										oModelCYXM:SetValue('CYX_CDGROE', aDados[nI][11])
										oModelCYXM:SetValue('CYX_CDOE'  , aDados[nI][12])
										
										if !Empty(oModelCYX:GetErrorMessage()[6])
											lErro      := .T.
											lErroLinha := .T.
											
											FWrite(nHandle, STR0036 + ALLTRIM(STR(nI)) + ': ' + alltrim(oModelCYX:GetErrorMessage()[4]) + ": " + oModelCYX:GetErrorMessage()[6] + PULALINHA) // 'Linha ' 
										Endif
									
									Case nTipo == 8 // MOD Parada - CZ6
										// Não serão importados estes registros, pois são gerados automaticamente
									
									Case nTipo == 9 // Item Controle - CYT
										lErroLinha := .F.
									
										Sleep(1000)
										
										oModelCYT:Activate()
										
										oModelCYTM:SetValue('CYT_CDMQ',aDados[nI][3])
										oModelCYTM:SetValue('CYT_DTRP',STOD(aDados[nI][4]))
										oModelCYTM:SetValue('CYT_HRRP',aDados[nI][5])
									Case nTipo == 10 // Item Controle Filho - CYT
										lAchou := .F.
									
										For nJ := 1 to oModelCYTS:GetQtdLine()
											oModelCYTS:GoLine(nJ)
											
											if ALLTRIM(oModelCYTS:GetValue('CYT_CDVF')) == ALLTRIM(aDados[nI][3])
												IF !Empty(aDados[nI][4])
													oModelCYTS:SetValue('CYT_DSRS', aDados[nI][4])
												Endif
												
												if !Empty(aDados[nI][5])
													oModelCYTS:SetValue('CYT_DTRS', STOD(aDados[nI][5]))
												Endif
												
												if !Empty(aDados[nI][6])
													oModelCYTS:SetValue('CYT_VLRS', VAL(aDados[nI][6]))
												Endif
												
												lAchou := .T.
												Exit
											Endif
										Next
										
										IF !lAchou
											lErro    := .T.
											lErroLinha := .T.
	
											FWrite(nHandle, STR0036 + ALLTRIM(STR(nI)) + ': ' + STR0040 + ALLTRIM(aDados[nI][3]) + STR0041 + ALLTRIM(oModelCYTM:GetValue('CYT_CDMQ')) + PULALINHA) // 'Linha ' ## 'O Item Controle ' ## ' não está relacionado à maquina '
										Endif
								End Case
							Endif
						EndIf
					Else
						lErro := .T.
						
						FWrite(nHandle, STR0036 + ALLTRIM(STR(nI)) + ': ' + STR0043 + PULALINHA) // 'Linha ' ## "O arquivo possui algum erro de formatação na linha."
					EndIf
				Next
				
				//Procura o model pai
				if !lErroLinha .and. ValType(nTipo) == 'N' .AND. nTipo > 0
				
					While nTipo != 1 .AND. nTipo != 7 .AND. nTipo != 9
						nTipo--
					End
					
					//Valida e commita ou apresenta mensagem de erro
					If aModelsCommit[nTipo]:VldData()
						lErro := !aModelsCommit[nTipo]:CommitData()
						
						if lErro
							aErro := aModelsCommit[nTipo]:GetErrorMessage()
						Endif
					Else
						lErro := .T.
				  		aErro := aModelsCommit[nTipo]:GetErrorMessage()
			
				  		FWrite(nHandle, STR0036 + ALLTRIM(STR(nI - 1)) + ': ' + INTEGXTOS( aErro[6] ) + PULALINHA) // 'Linha '
					EndIf
					
				Else
					lErro := .T.
				Endif
			
				if lErro
					if IsBlind()
						FWrite(nHandle, STR0044 + PULALINHA)  // 'Foram gerados erros durante o processo'
					Else
						ApMsgInfo(STR0044) // 'Foram gerados erros durante o processo'
					Endif
				Else
					if IsBlind()
						FWrite(nHandle, STR0045 + PULALINHA)  // 'Importação realizada com sucesso'
					Else
						ApMsgInfo(STR0045, "SFCA320") // 'Importação realizada com sucesso'
					Endif
				EndIf
				
				FClose(nHandle)
				
				if lErro .AND. !IsBlind() .And. !lAutomacao
					ShellExecute("open",GETTEMPPATH() + "errosImportacao.log","","",5) // 5=SW_SHOW
				Endif
				
				HelpInDark(lHlpDark)
				
				if lErro
					DisarmTransaction()
				Endif
			
			End Transaction
		Else
			FClose(nHandle)
			
			if lErroArq
				ApMsgInfo(STR0044) // 'Foram gerados erros durante o processo'

				ShellExecute("open",GETTEMPPATH() + "errosImportacao.log","","",5) // 5=SW_SHOW
			Else
				ApMsgInfo(STR0046, "SFCA320") //"Arquivo foi validado e está correto, pronto para importação!"
			Endif
		Endif
	Else
		//conout('ERRO: ' + str(ferror()))
		MsgStop(STR0047)//"Arquivo não existe."
	EndIf
	
Return Nil

//-------------------------------------------------------------------
//Select File - Seleciona Arquivo
//-------------------------------------------------------------------
Static Function SelectFile() 
	cFile := cGetFile(STR0049 + "|*.txt|" + STR0050 + "|*.*",STR0051,0,"C:\",.T.,,.F.)//"Arquivo de Texto","Todos Arquivos","Selecione o arquivo para importação"
	
Return Nil
//-------------------------------------------------------------------
//Retorna array com Campos Obrigatórios e Opcionais da tabela CYV
//-------------------------------------------------------------------
Static Function GetCYVFld()
	aFldCYV := {{"CYV_NRORPO","CYV_IDAT","CYV_IDATQO","CYV_CDMQ","CYV_QTATRP","CYV_DTRPBG",;
				 "CYV_HRRPBG","CYV_DTRPED","CYV_HRRPED"},;
				{"CYV_NRBG","CYV_NRED","CYV_NRDO","CYV_NRSR","CYV_CDDP","CYV_CDLOSR","CYV_DTVDLO",;
				 "CYV_CDSU","CYV_DTBGSU","CYV_HRBGSU","CYV_DTEDSU","CYV_HREDSU","CYV_VLPNRY"}}
				 
Return aFldCYV
//-------------------------------------------------------------------
//Retorna array com Campos Obrigatórios e Opcionais da tabela CYX
//-------------------------------------------------------------------
Static Function GetCYXFld()
	Local aFldCYX := {{"CYX_CDMQ","CYX_CDSP","CYX_DTBGSP","CYX_HRBGSP","CYX_DTEDSP","CYX_HREDSP"},;
					  {"CYX_NRSQSP","CYX_CDFEPO","CYX_CDGROE","CYX_CDOE"}}
					  
Return aFldCYX

//-------------------------------------------------------------------
//Retorna array com Campos Obrigatórios e Opcionais da tabela CYT
//-------------------------------------------------------------------
Static Function GetCYTFldM()
	Local aFldCYTM := {{"CYT_CDMQ"},{"CYT_DTRP","CYT_HRRP"}}
	
Return aFldCYTM

//-------------------------------------------------------------------
//Retorna array com Campos Obrigatórios e Opcionais da tabela CYT
//-------------------------------------------------------------------
Static Function GetCYTFldS()
	Local aFldCYTS := {{"CYT_CDVF"},{"CYT_DSRS","CYT_DTRS","CYT_VLRS"}}
	
Return aFldCYTS

//-------------------------------------------------------------------
//Retorna array com Campos Obrigatórios e Opcionais da tabela CZP
//-------------------------------------------------------------------
Static Function GetCZPFld()
	Local aFldCZP := {{"CZP_CDMT","CZP_QTRPPO"},{}}
	
Return aFldCZP

//-------------------------------------------------------------------
//Retorna array com Campos Obrigatórios e Opcionais da tabela CYW
//-------------------------------------------------------------------
Static Function GetCYWFld()
	Local aFldCYW := {{"CYW_DTBGRP","CYW_HRBGRP","CYW_DTEDRP","CYW_HREDRP"},;
					  {"CYW_CDGROE","CYW_CDOE"}}
					 
Return aFldCYW

//-------------------------------------------------------------------
//Retorna array com Campos Obrigatórios e Opcionais da tabela CZ0
//-------------------------------------------------------------------
Static Function GetCZ0Fld()
	Local aFldCZ0 := {{"CZ0_CDFE"},{}}
	
Return aFldCZ0

//-------------------------------------------------------------------
//Retorna array com Campos Obrigatórios e Opcionais da tabela CY0
//-------------------------------------------------------------------
Static Function GetCY0Fld()
	Local aFldCY0 := {{"CY0_CDRF"},{"CY0_QTRF","CY0_QTRT"}}
	
Return aFldCY0

//-------------------------------------------------------------------
//Retorna array com Campos Obrigatórios e Opcionais da tabela CZW
//-------------------------------------------------------------------
Static Function GetCZWFld()
	Local aFldCZW := {{"CZW_CDCETR","CZW_HRTEGF"},{}}
	
Return aFldCZW

//-------------------------------------------------------------------
//função para schedule
//-------------------------------------------------------------------
Static Function Scheddef()
Local aParam

aParam := { "P",;                      //Tipo R para relatorio P para processo   
			"SFCA320",;// Pergunte do relatorio, caso nao use passar ParamDef            
			"CYV",;  // Alias            
			{},;   //Array de ordens   
			""}	
			    
Return aParam
