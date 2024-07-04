#include "protheus.ch"
#include "ctbarea.ch"
#include "ctba087.ch"

//
// Classe CtbProcess
// Copyright (C) 2007, Microsiga
//

Class CtbProcess

	Data _oArea As Object
	Data _oTree As Object
	
	Data _aButtonsProcess As Array

	Data _PanelId1 As String
	Data _PanelId2 As String
	
	Data _LayoutId As String
	Data _WindowId1 As String
	Data _WindowId2 As String

	Data _oGetProcess As Object
	Data _oToolbarProcess As Object
	Data _oBrwOperations As Object
	
	Data _oLayout As Object
	
	Data _aOperations As Array
	Data _aBrowseHeader As Array
	
	Method New(oArea, oTree) Constructor

	// m�todos
	Method Create()
	Method Read()
	Method Update()
	Method Delete()
	
	Method Confirm()
	Method Cancel()

	Method SetStatusToolbar(nStatus)
	Method ListOperations()
	
EndClass

/* ----------------------------------------------------------------------------

New()

---------------------------------------------------------------------------- */
Method New(oArea, oTree) Class CtbProcess

	Local aButtons := {}

	Local aToolButtons := {}
	Local aTextButtons := {}
	
	Local aAllButtons := {}
	
	Local i := 1
	
	Self:_oArea := oArea
	Self:_oTree := oTree
	
	// Ids	
	Self:_PanelId1 := "panel_process"
	Self:_PanelId2 := "panel_operations"
	Self:_LayoutId := "layout_process"
	Self:_WindowId1 := "wnd_process"
	Self:_WindowId2 := "wnd_operations"

	// objetos private para o layout de lan�amento
	Self:_oGetProcess := Nil
	Self:_oToolbarProcess := Nil	

	Self:_aBrowseHeader := {STR0000, STR0001} //"Opera��o"###"Descri��o"

	// Delete
	aAdd(aButtons, {IMG_DELETE, IMG_DELETE, STR0004, ; //"Excluir"
	               {|| Self:Delete() }, STR0005}) //"Excluir processo"

	// Update
	aAdd(aButtons, {IMG_UPDATE, IMG_UPDATE, STR0006, ; //"Editar"
	               {|| Self:Update() }, STR0007}) //"Editar processo"

	// Create	
	aAdd(aButtons, {IMG_CREATE, IMG_CREATE, STR0008, ; //"Incluir"
	               {|| Self:Create() }, STR0009}) //"Incluir processo"
	               
	// adiciona layout	
	Self:_oArea:AddLayout(Self:_LayoutId)
	Self:_oLayout := Self:_oArea:GetLayout(Self:_LayoutId)
	
	// adiciona janela
	Self:_oArea:AddWindow(100, 30, Self:_WindowId1, ;
	                      STR0010, 3, 4, Self:_oLayout) //"Processo"

	// adiciona painel
	Self:_oArea:AddPanel(100, 100, Self:_PanelId1, CONTROL_ALIGN_ALLCLIENT)

	// adiciona barra de ferramentas
	aToolButtons := CreateToolbar(Self:_PanelId1, aButtons)		

	// adiciona bot�es Confirmar e Cancelar
	Self:_oArea:AddTextButton({{STR0011, STR0012}, ;  //"Cancelar"###"Confirmar"
	                           {{|| ChangeHandler(oTree) }, {|| Self:Confirm() }}, ;
	                           {STR0011, STR0012}}) //"Cancelar"###"Confirmar"
	                          
	aTextButtons := oArea:GetTextButton(Self:_PanelId1)

	// adiciona os bot�es no layout
	For i := 1 To Len(aTextButtons)
		aAdd(aAllButtons, aTextButtons[i])
	Next

	For i := 1 To Len(aToolButtons)
		aAdd(aAllButtons, aToolButtons[i])
	Next

	// trata bot�es da mesma maneira	
	Self:_aButtonsProcess := aAllButtons

		
	// adiciona get	
	Self:_oGetProcess := CreateGet("CVJ", CVJ->(Recno()), 2, 3, ;
	                       Self:_oArea:GetPanel(Self:_PanelId1))
	
	// adiciona janela de visualiza��o de opera��es
	Self:_oArea:AddWindow(100, CtbGetHeight(70), Self:_WindowId2, ;
	                      STR0013, 4, 3, Self:_oLayout) //"Opera��es"

	// adiciona painel
	Self:_oArea:AddPanel(100, 100, Self:_PanelId2, CONTROL_ALIGN_ALLCLIENT)
	
	// adiciona browse de opera��es
	Self:_oBrwOperations := TWBrowse():New(0, 0, 290, 252, , ;
	       Self:_aBrowseHeader, , ;
	       Self:_oArea:GetPanel(Self:_PanelId2),,,,,,, ;
	       Self:_oArea:GetPanel(Self:_PanelId2):oFont,,,,,.F.,,.T.,,.F.,,,)
	Self:_oBrwOperations:Align := CONTROL_ALIGN_ALLCLIENT
	Self:ListOperations()

Return Self

/* ----------------------------------------------------------------------------

Create()

Restri��es: A fun��o seta a vari�vel Inclui como verdadeiro e as vari�veis
Altera e Exclui como falsas.

---------------------------------------------------------------------------- */
Method Create() Class CtbProcess

	// manipula as vari�veis p�blicas para permitir a altera��o
	Inclui := .T.
	Altera := .F.
	Exclui := .F.

	// destr�i o objeto existente	
	Self:_oGetProcess:oBox:FreeChildren()
	
	// recarrega as vari�veis de mem�ria
	RegToMemory("CVJ", .T., , , FunName())

	// seta o m�dulo
	M->CVJ_MODULO := AllTrim(Str(DecodeRecno(Self:_oTree:GetCargo())))
	
	// recria o objeto, por�m em modo de altera��o
	Self:_oGetProcess := CreateGet("CVJ", 0, 3, 3, ;
	                       Self:_oArea:GetPanel(Self:_PanelId1))

	//
	Self:ListOperations()

	// atualiza os estados dos bot�es
	Self:SetStatusToolbar(STATUS_CREATE) 
	
	// mostra o layout
	Self:_oArea:ShowLayout(Self:_LayoutId)	
Return  


/* ----------------------------------------------------------------------------

Read()

Restri��o: o arquivo CVJ deve estar posicionado, ou seja, a fun��o
ChangeHandler() deve posicionar o registro do CVJ a partir do item selecionado
na �rvore. Read() tamb�m j� marca as vari�veis Inclui, Altera e Exclui
como falsas.

---------------------------------------------------------------------------- */
Method Read() Class CtbProcess

	// otimiza��o da leitura - se n�o est� incluindo, alterando ou
	// excluindo um elemento da �rvore, ent�o n�o � necess�rio
	// recriar o Get para visualizar o novo elemento, basta
	// apenas recarregar o get atual
	If !Inclui .And. !Altera .And. !Exclui

		// atualiza a Enchoice do Lan�amento			
		RegToMemory("CVJ", .F., , , FunName())
		
		Self:_oGetProcess:EnchRefreshAll()
	Else

		// manipula as vari�veis p�blicas para permitir a altera��o
		Inclui := .F.
		Altera := .F.
		Exclui := .F.
	
		// destr�i o objeto existente	
		Self:_oGetProcess:oBox:FreeChildren()
		
		// recarrega as vari�veis de mem�ria
		RegToMemory("CVJ", .F., , , FunName())
	
		// observa��o: a fun��o RegToMemory()
		// necessita do nome da fun��o inicial,
		// caso contr�rio, ela falhar�
	
		// recria o objeto, por�m em modo de altera��o
		Self:_oGetProcess := CreateGet("CVJ", CVJ->(Recno()), 2, 3, ;
		                       Self:_oArea:GetPanel(Self:_PanelId1))
	EndIf

	// lista as opera��es
	Self:ListOperations(CVJ->CVJ_PROCES, CVJ->CVJ_MODULO)

	// atualiza os estados dos bot�es	
	Self:SetStatusToolbar(STATUS_READ)

	// mostra o layout
	Self:_oArea:ShowLayout(Self:_LayoutId)	
Return

/* ----------------------------------------------------------------------------

Update()

Restri��o: o arquivo CVJ deve estar posicionado, ou seja, a fun��o
ChangeHandler() deve posicionar o registro do CVJ a partir do item selecionado
na �rvore.

---------------------------------------------------------------------------- */
Method Update() Class CtbProcess

	// manipula as vari�veis p�blicas para permitir a altera��o
	Inclui := .F.
	Altera := .T.
	Exclui := .F.

	/*If SoftLock("CVJ")
		MsgStop("CVJ n�o pode ser travado.")
		Return
	EndIf	*/

	// destr�i o objeto existente	
	Self:_oGetProcess:oBox:FreeChildren()

	// recarrega as vari�veis de mem�ria
	RegToMemory("CVJ", .F.,,, FunName())

	//
	// WOP: a fun��o RegToMemory() necessita do nome
	//      da fun��o inicial, caso contr�rio, ela falhar�.
	//      Por esta raz�o � chamada a fun��o FunName()
	//

	// recria o objeto, por�m em modo de altera��o
	Self:_oGetProcess := CreateGet("CVJ", CVJ->(Recno()), 4, 4, ;
	                       Self:_oArea:GetPanel(Self:_PanelId1))

	// atualiza os estados dos bot�es	
	Self:SetStatusToolbar(STATUS_UPDATE)
	
	// mostra o layout
	Self:_oArea:ShowLayout(Self:_LayoutId)
Return

/* ----------------------------------------------------------------------------

Delete()

---------------------------------------------------------------------------- */
Method Delete() Class CtbProcess
	//DelHandler(Self:_oTree)
Return Nil

/* ----------------------------------------------------------------------------

Confirm()

---------------------------------------------------------------------------- */

Method Confirm() Class CtbProcess
	Local i := 0

	If Obrigatorio(Self:_oGetProcess:aGets, Self:_oGetProcess:aTela) // .And. Valida��o
	dbSelectArea("CVJ")
	
	// gravar as altera��es do CVJ			
	RecLock("CVJ", Inclui)

	For i := 1 To CVJ->(FCount())
		FieldPut(i, &("M->" + CVJ->(FieldName(i))))
	Next

	CVJ->CVJ_FILIAL := xFilial("CVJ")
  CVJ->(MsUnlock())

	If Inclui
		
		// adiciona o item na �rvore
		AddItem(Self:_oTree, {CodeCargo(CVJ->(Recno()), NODE_TYPE_PROCESS), ;
		                CVJ->CVJ_DESCRI, IMG_COL_PROCESS, IMG_EXP_PROCESS})

		// posiciona a �rvore
		Self:_oTree:TreeSeek(CodeCargo(CVJ->(Recno()), NODE_TYPE_PROCESS))
	Else

		If Altera

			//
			// WOP: Esta invers�o na express�o ao inv�s de utilizar o operador
			//      <> � para evitar um erro na avalia��o de express�o
			//
			Self:_oTree:ChangePrompt(CVJ->CVJ_DESCRI, ;
			                         CodeCargo(CVJ->(Recno()), ;
			                         NODE_TYPE_PROCESS))
		EndIf
	EndIf	

	// Read() j� seta as vari�veis Inclui, Altera e Exclui para falsas.	
	
	// recarregar o registro
	Self:Read()
	EndIf
Return

/* ----------------------------------------------------------------------------

SetStatusToolbar()

---------------------------------------------------------------------------- */
Method SetStatusToolbar(nStatus) Class CtbProcess

	Local i := 0

	// desabilita todos os bot�es
	For i := 1 To Len(Self:_aButtonsProcess)
		Self:_aButtonsProcess[i]:Hide()
	Next

	Do Case
	
		Case nStatus == STATUS_CREATE // incluir

			// habilita o bot�es de Confirmar e Cancelar
			Self:_aButtonsProcess[IDX_CONFIRM]:Show()
			Self:_aButtonsProcess[IDX_CANCEL]:Show()

			oArea:SetTitleWindow(Self:_WindowId1, STR0009) //"Incluir Processo"
			
		Case nStatus == STATUS_READ   // visualizar

			// habilita o bot�o de Editar
			Self:_aButtonsProcess[IDX_UPDATE]:Show()
			
			oArea:SetTitleWindow(Self:_WindowId1, STR0010) //"Processo"
			
		Case nStatus == STATUS_UPDATE // editar

			// habilita o bot�es de Confirmar e Cancelar
			Self:_aButtonsProcess[IDX_CONFIRM]:Show()
			Self:_aButtonsProcess[IDX_CANCEL]:Show()
			
			oArea:SetTitleWindow(Self:_WindowId1, STR0007)			 //"Editar Processo"
		
		Case nStatus == STATUS_DELETE // excluir
		
		Case nStatus == STATUS_UNKNOWN // desconhecido
		
	EndCase
Return

/* ----------------------------------------------------------------------------

ListOperations()

---------------------------------------------------------------------------- */
Method ListOperations(cProcess, cModule) Class CtbProcess
	Local aArea := GetArea()
	Local aAreaCVG := CVG->(GetArea())

	Default cProcess := ""
		
	Self:_aOperations := {}

	dbSelectArea("CVG")
	CVG->(dbSetOrder(1))
	CVG->(MsSeek(xFilial("CVG") + cProcess))
	
	While !CVG->(Eof()) .And. CVG->CVG_FILIAL == xFilial("CVG") .And. ;
	                          CVG->CVG_PROCES == cProcess

		//Se for modulo ativo fixo e processo 110 nao carrega as operacoes abaixo pois s�o do estoque
		If Ctb86Exc( CVG->CVG_PROCES, cModule, CVG->CVG_OPER)  //CVG->CVG_PROCES = '110' .And. If(cModule = '01', CVG->CVG_OPER $ "005|010|015|020", CVG->CVG_OPER=='110')
			CVG->( dbSkip() )
			Loop
		EndIf

		Aadd(Self:_aOperations, {CVG->CVG_OPER, CVG->CVG_DESCRI})
		
		CVG->(dbSkip())	
	End
	
	If Len(Self:_aOperations) == 0
		Self:_aOperations := {{"", ""}}	
	EndIf

	Self:_oBrwOperations:SetArray(Self:_aOperations)
	Self:_oBrwOperations:bLine := {|| Self:_aOperations[Self:_oBrwOperations:nAT] }
	Self:_oBrwOperations:Refresh()

	RestArea(aAreaCVG)
	RestArea(aArea)
Return Nil