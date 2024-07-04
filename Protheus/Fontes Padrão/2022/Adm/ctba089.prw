#include "protheus.ch"
#include "ctbarea.ch"
#include "ctba089.ch"    

//
// Classe CtbEntry
// Copyright (C) 2007, Microsiga
//

Class CtbEntry

	Data _oArea As Object
	Data _oTree As Object
	
	Data _aButtonsEntry As Array

	Data _PanelId As String
	Data _LayoutId As String
	Data _WindowId As String

	Data _oGetEntry As Object
	Data _oToolbarEntry As Object
	
	Data _oLayout As Object
	
	Data _aClipboard As Array

	// Tipos de Saldos
	Data _nIdBtn As Integer
	Data _cTpSaldos As String
	Data _lMltSld As Boolean
	
	Method New(oArea, oTree) Constructor

	// métodos
	Method Create()
	Method Read()
	Method Update()
	Method Delete()
	
	Method Confirm()
	Method ConfirmPaste()
	Method Cancel()
	
	Method Paste(aClipboard)
	Method PasteEntry(aClipboard)
	Method PasteLink(aClipboard)
	Method PasteReversal(aClipboard)

	Method SetStatusToolbar(nStatus)

	Method SetMltSlds( lVisual, cTpSald, cMltSld )
EndClass

/* ----------------------------------------------------------------------------

New()

---------------------------------------------------------------------------- */
Method New(oArea, oTree) Class CtbEntry

	Local aButtons := {}
	
	Local aTextButtons := {}
	Local aToolButtons := {}
	
	Local aAllButtons := {}
	
	Local i := 0

	Self:_oArea := oArea
	Self:_oTree := oTree
	
	// Ids	
	Self:_PanelId := "panel_entry"
	Self:_LayoutId := "layout_entry"
	Self:_WindowId := "wnd_entry"

	// objetos private para o layout de lançamento
	Self:_oGetEntry := Nil
	Self:_oToolbarEntry := Nil	
	Self:_lMltSld	:= ( CT5->( FieldPos( "CT5_MLTSLD" ) ) > 0 )
	Self:_cTpSaldos := IIF(Self:_lMltSld,CRIAVAR("CT5_MLTSLD"),"")

	//
	// o objeto oEntry estava "chumbado", ou seja, para o botão
	// funcionar, a instância da classe Entry devia nomeada
	// como oEntry. Agora foi substituída por Self.
	//

	// Delete
	aAdd(aButtons, {IMG_DELETE, IMG_DELETE, STR0001, ;
	               {|| Self:Delete() }, STR0002})

	// Update
	aAdd(aButtons, {IMG_UPDATE, IMG_UPDATE, STR0003, ;
	               {|| Self:Update() }, STR0004})

	// Create	
	aAdd(aButtons, {IMG_CREATE, IMG_CREATE, STR0005, ;
	               {|| Self:Create() }, STR0006})
	               
	// adiciona layout	
	Self:_oArea:AddLayout(Self:_LayoutId)
	Self:_oLayout := Self:_oArea:GetLayout(Self:_LayoutId)
	
	// adiciona janela
	Self:_oArea:AddWindow(100, CtbGetHeight(100), Self:_WindowId, ;
	                      STR0007, 7, 7, Self:_oLayout)

	// adiciona painel
   	Self:_oArea:AddPanel(100, 100, Self:_PanelId, CONTROL_ALIGN_ALLCLIENT)

	// adiciona barra de ferramentas
	aToolButtons := CreateToolbar(Self:_PanelId, aButtons)	

	// adiciona botões Confirmar e Cancelar
	Self:_oArea:AddTextButton({{ STR0008, STR0009 }, ; 
	                           {{|| ChangeHandler(oTree) }, {|| Self:Confirm() } }, ;
	                           {STR0010, STR0011 }})
	                          
	aTextButtons := oArea:GetTextButton(Self:_PanelId)

	// adiciona os botões no layout
	For i := 1 To Len(aTextButtons)
		aAdd(aAllButtons, aTextButtons[i])
	Next

	For i := 1 To Len(aToolButtons)
		aAdd(aAllButtons, aToolButtons[i])
	Next

	// Incluir tipos de saldos como ultimo botao
	IF Self:_lMltSld
		Self:_oArea:AddTextButton({{ STR0015 }, ; 
		                           { {|| Self:SetMltSlds( !INCLUI .AND. !ALTERA ) } }, ;
		                           { STR0016 }})
	ENDIF
	
	aTextButtons := oArea:GetTextButton(Self:_PanelId)
	aAdd( aAllButtons, aTextButtons[ Len( aTextButtons ) ] )
	Self:_nIdBtn := Len( aAllButtons )

	// trata botões da mesma maneira	
	Self:_aButtonsEntry := aAllButtons

	// adiciona get	
	Self:_oGetEntry := CreateGet("CT5", CT5->(Recno()), 2, 3, ;
	                       Self:_oArea:GetPanel(Self:_PanelId))
Return Self

/* ----------------------------------------------------------------------------

Create()

Restrições: A função seta a variável Inclui como verdadeiro e as variáveis
Altera e Exclui como falsas.

---------------------------------------------------------------------------- */
Method Create() Class CtbEntry

	// altera a confirmação da operação de colar
	Self:_aButtonsEntry[IDX_CONFIRM]:bAction := {|| Self:Confirm()}

	// manipula as variáveis públicas para permitir a alteração
	Inclui := .T.
	Altera := .F.
	Exclui := .F.

	// destrói o objeto existente	
	Self:_oGetEntry:oBox:FreeChildren()
	
	// recarrega as variáveis de memória
	RegToMemory("CT5", .T., , , FunName())

	// recria o objeto, porém em modo de alteração
	Self:_oGetEntry := CreateGet("CT5", 0, 3, 3, ;
	                       Self:_oArea:GetPanel(Self:_PanelId))

	// atualiza os estados dos botões
	Self:SetStatusToolbar(STATUS_CREATE) 

	// mostra o layout
	Self:_oArea:ShowLayout(Self:_LayoutId)	
Return  


/* ----------------------------------------------------------------------------

Read()

Restrição: o arquivo CT5 deve estar posicionado, ou seja, a função
ChangeHandler() deve posicionar o registro do CT5 a partir do item selecionado
na árvore. Read() também já marca as variáveis Inclui, Altera e Exclui
como falsas.

---------------------------------------------------------------------------- */
Method Read() Class CtbEntry
	// multiplos tipos de saldos
	Self:_lMltSld	:= ( CT5->( FieldPos( "CT5_MLTSLD" ) ) > 0 )
	Self:_cTpSaldos := IIF(Self:_lMltSld,CT5->CT5_MLTSLD,"")

	// otimização da leitura - se não está incluindo, alterando ou
	// excluindo um elemento da árvore, então não é necessário
	// recriar o Get para visualizar o novo elemento, basta
	// apenas recarregar o get atual
	If !Inclui .And. !Altera .And. !Exclui

		// atualiza a Enchoice do Lançamento			
		RegToMemory("CT5", .F., , , FunName())
		
		Self:_oGetEntry:EnchRefreshAll()
	Else

		// manipula as variáveis públicas para permitir a alteração
		Inclui := .F.
		Altera := .F.
		Exclui := .F.
	
		// destrói o objeto existente	
		Self:_oGetEntry:oBox:FreeChildren()
		
		// recarrega as variáveis de memória
		RegToMemory("CT5", .F., , , FunName())
	
		// observação: a função RegToMemory()
		// necessita do nome da função inicial,
		// caso contrário, ela falhará
	
		// recria o objeto, porém em modo de alteração
		Self:_oGetEntry := CreateGet("CT5", CT5->(Recno()), 2, 3, ;
		                       Self:_oArea:GetPanel(Self:_PanelId))
	EndIf

	// atualiza os estados dos botões	
	Self:SetStatusToolbar(STATUS_READ)
	
	// mostra o layout
	Self:_oArea:ShowLayout(Self:_LayoutId)
Return

/* ----------------------------------------------------------------------------

Update()

Restrição: o arquivo CT5 deve estar posicionado, ou seja, a função
ChangeHandler() deve posicionar o registro do CT5 a partir do item selecionado
na árvore.

---------------------------------------------------------------------------- */
Method Update() Class CtbEntry

	// altera a confirmação da operação de colar
	Self:_aButtonsEntry[IDX_CONFIRM]:bAction := {|| Self:Confirm()}

	// manipula as variáveis públicas para permitir a alteração
	Inclui := .F.
	Altera := .T.
	Exclui := .F.

	/*If SoftLock("CT5")
		MsgStop("CT5 não pode ser travado.")
		Return
	EndIf	*/

	// destrói o objeto existente	
	Self:_oGetEntry:oBox:FreeChildren()

	// recarrega as variáveis de memória
	RegToMemory("CT5", .F.,,, FunName())

	//
	// WOP: a função RegToMemory() necessita do nome
	//      da função inicial, caso contrário, ela falhará.
	//      Por esta razão é chamada a função FunName()
	//

	// recria o objeto, porém em modo de alteração
	Self:_oGetEntry := CreateGet("CT5", CT5->(Recno()), 4, 4, ;
	                       Self:_oArea:GetPanel(Self:_PanelId))

	// atualiza os estados dos botões	
	Self:SetStatusToolbar(STATUS_UPDATE)

	// mostra o layout
	Self:_oArea:ShowLayout(Self:_LayoutId)	
Return

/* ----------------------------------------------------------------------------

Delete()

---------------------------------------------------------------------------- */
Method Delete() Class CtbEntry
	// DelHandler(Self:_oTree)
Return Nil

/* ----------------------------------------------------------------------------

Confirm()

Restrições: Esta função tem como premissas:

- O lançamento padrão (CT5) pode apenas ser incluído abaixo de uma operação,
ou seja, um nó do tipo NODE_TYPE_OPERATION

- Valida apenas a inclusão, pois os campos CT5_LANPAD e CT5_SEQLAN não podem
ser modificados na alteração

- Se for uma inclusão, é necessário incluir o relacionamento entre operação
e lançamento padrão. Isto é feito criando-se o registro no CVI. Neste caso,
o CVG deve estar posicionado

- Se for uma alteração, não é necessário criar um registro no CVI, basta
apenas modificá-lo para refletir o novo relacionamento. Neste caso, tanto o
CVI quanto o CT5 devem estar posicionados

---------------------------------------------------------------------------- */

Method Confirm() Class CtbEntry
	
	Local i := 0
	Local cProcess := ""
	Local cOperation := "" 
	Local lSuccess := .T.
	
	If Obrigatorio(Self:_oGetEntry:aGets, Self:_oGetEntry:aTela)

		// valida a inclusão	
		If Inclui
			cProcess := GetValByRecno("CVG", ;
			                               DecodeRecno(Self:_oTree:GetCargo()), ;
			                               "CVG_PROCES")
	
			cOperation := GetValByRecno("CVG", ;
			                            DecodeRecno(Self:_oTree:GetCargo()), ;
			                            "CVG_OPER")
	
		  If !IsValidEntry(cProcess, cOperation, M->CT5_LANPAD)
		  	Aviso(STR0012, ;
							STR0013, ;
							{"OK"})
		  	lSuccess := .F.
		  	Return lSuccess
		  EndIf
		EndIf

		dbSelectArea("CT5")
		
		// gravar as alterações do CT5			
		RecLock("CT5", Inclui)
	
		For i := 1 To CT5->(FCount())
			FieldPut(i, &("M->" + CT5->(FieldName(i))))
		Next

		IF Self:_lMltSld
			If !( CT5->CT5_TPSALD $ Self:_cTpSaldos )
				Self:_cTpSaldos += ";" + CT5->CT5_TPSALD
			EndIf
			CT5->CT5_MLTSLD	:= IIF(Self:_lMltSld,Self:_cTpSaldos,"")
		ENDIF
	
		CT5->CT5_FILIAL	:= xFilial("CT5")
		CT5->(MsUnlock())
	
		If Inclui
		
			// toda inclusão deve incluir também o CVI	
			dbSelectArea("CVI")
			Reclock("CVI", Inclui)
			
			CVI->CVI_FILIAL := xFilial("CVI")
	
			CVI->CVI_PROCES := GetValByRecno("CVG", ;
			                               DecodeRecno(Self:_oTree:GetCargo()), ;
			                               "CVG_PROCES")
	
			CVI->CVI_OPER := GetValByRecno("CVG", ;
			                               DecodeRecno(Self:_oTree:GetCargo()), ;
			                               "CVG_OPER")
	
			CVI->CVI_LANPAD := CT5->CT5_LANPAD
			CVI->CVI_SEQLAN := CT5->CT5_SEQUEN
			
			CVI->(MsUnlock())
	
			// adiciona o item na árvore
			AddItem(Self:_oTree, {CodeCargo(CVI->(Recno()), NODE_TYPE_ENTRY), ;
			                CT5->CT5_DESC,;
			                SetEntryImg(1,.F.,CT5->CT5_DC,(CT5->CT5_STATUS=='2')),;
			                SetEntryImg(2,.F.,CT5->CT5_DC,(CT5->CT5_STATUS=='2'))})
      
			// atualiza a árvore
			RefreshTree(Self:_oTree, CodeCargo(CVI->(Recno()), NODE_TYPE_ENTRY))

			Self:_oTree:TreeSeek(CodeCargo(CVI->(Recno()), NODE_TYPE_ENTRY))
		Else
	
			If Altera
	
				// verifica se existe o link no CVI, pois se existir o registro
				// está classificado. caso contrário, apenas o CT5 (lançamento
				// padrão não classificado) que está sendo editado e não há razão
				// para procurar o nó CVI na árvore		
				dbSelectArea("CVI")
				CVI->(dbSetOrder(2))
				If CVI->(MsSeek(xFilial("CVI") + CT5->CT5_LANPAD + CT5->CT5_SEQUEN))
	
					//
					// WOP: Esta inversão na expressão ao invés de utilizar o operador
					//      <> é para evitar um erro na avaliação de expressão
					//
					//If !(AllTrim(Upper(Self:_oTree:GetPrompt())) == ;
					//     AllTrim(Upper(CT5->CT5_DESC)))
					Self:_oTree:ChangePrompt(CT5->CT5_LANPAD+"-"+CT5->CT5_DESC, ;
					                         CodeCargo(CVI->(Recno()), ;
					                         NODE_TYPE_ENTRY))     
					Self:_oTree:ChangeBmp(SetEntryImg(1,.F.,CT5->CT5_DC,(CT5->CT5_STATUS=='2')),;
											SetEntryImg(1,.F.,CT5->CT5_DC,(CT5->CT5_STATUS=='2')),;
											CodeCargo(CVI->(Recno()),NODE_TYPE_ENTRY))
					                            
	
					                         
				Else
					Self:_oTree:ChangePrompt(CT5->CT5_LANPAD+"-"+CT5->CT5_DESC, ;
					                         CodeCargo(CT5->(Recno()), ;
					                         NODE_TYPE_ENTRY + NODE_TYPE_UNCLASSIFIED))
					Self:_oTree:ChangeBmp(SetEntryImg(1,.F.,CT5->CT5_DC,(CT5->CT5_STATUS=='2')),;
											SetEntryImg(1,.F.,CT5->CT5_DC,(CT5->CT5_STATUS=='2')),;
											CodeCargo(CVI->(Recno()),NODE_TYPE_ENTRY))
	
					//EndIf
				EndIf
			EndIf
		EndIf	
	    
		// Read() já seta as variáveis Inclui, Altera e Exclui para falsas.	
		
		// recarregar o registro
		Self:Read()
	EndIf
Return lSuccess

/* ----------------------------------------------------------------------------

Paste()

---------------------------------------------------------------------------- */
Method Paste(aClipboard) Class CtbEntry
Return Self:PasteEntry(aClipboard)

/* ----------------------------------------------------------------------------

PasteReversal()

---------------------------------------------------------------------------- */
Method PasteReversal(aClipboard) Class CtbEntry
Return Self:PasteEntry(aClipboard, .T.)

/* ----------------------------------------------------------------------------

PasteEntry()

---------------------------------------------------------------------------- */
Method PasteEntry(aClipboard, lReversal) Class CtbEntry
	Local lCreateLink := .F.
	Local i := 0
	
	Default lReversal := .F.

	If Len(aClipboard) > 0

		//
		// WOP: preenche _aClipboard pois aClipboard não é visível no bloco
		//      de código abaixo
		//
		Self:_aClipboard := aClipboard

		// altera a confirmação da operação de colar
		Self:_aButtonsEntry[IDX_CONFIRM]:bAction := {|| Self:ConfirmPaste()}

		// manipula as variáveis públicas para permitir a alteração
		Inclui := .T.
		Altera := .F.
		Exclui := .F.
	
		// destrói o objeto existente	
		Self:_oGetEntry:oBox:FreeChildren()
		
		// recarrega as variáveis de memória
		RegToMemory("CT5", .T., , , FunName())
		
		For i := 1 To CT5->(FCount())
			&("M->" + CT5->(FieldName(i))) := aClipboard[i]
		Next
        
		// zera o código da seqüência
		M->CT5_SEQUEN := Space(Len(CT5->CT5_SEQUEN))
		// zera o código do lancamento padrao
		M->CT5_LANPAD := Space(Len(CT5->CT5_LANPAD))
		
		// inverte o lançamento caso especificado
		If lReversal .And. GetFromFieldPos(CT5->(FieldPos("CT5_DC"))) $ "123"
		
			Do Case
			// débito, cola como crédito
			Case GetFromFieldPos(CT5->(FieldPos("CT5_DC"))) == "1"
				M->CT5_DC := "2"
			// crédito, cola como débito
			Case GetFromFieldPos(CT5->(FieldPos("CT5_DC"))) == "2"
				M->CT5_DC := "1"
			EndCase					

			M->CT5_CREDIT := GetFromFieldPos(CT5->(FieldPos("CT5_DEBITO")))
			M->CT5_DEBITO := GetFromFieldPos(CT5->(FieldPos("CT5_CREDIT")))
			
			M->CT5_CCC := GetFromFieldPos(CT5->(FieldPos("CT5_CCD")))
			M->CT5_CCD := GetFromFieldPos(CT5->(FieldPos("CT5_CCC")))
			
			M->CT5_ITEMC := GetFromFieldPos(CT5->(FieldPos("CT5_ITEMD")))
			M->CT5_ITEMD := GetFromFieldPos(CT5->(FieldPos("CT5_ITEMC")))

			M->CT5_CLVLCR := GetFromFieldPos(CT5->(FieldPos("CT5_CLVLDB")))
			M->CT5_CLVLDB := GetFromFieldPos(CT5->(FieldPos("CT5_CLVLCR")))

			M->CT5_ATIVCR := GetFromFieldPos(CT5->(FieldPos("CT5_ATIVDE")))
			M->CT5_ATIVDE := GetFromFieldPos(CT5->(FieldPos("CT5_ATIVCR")))
		
		EndIf
			
		M->CT5_CVKVER	:=	CriaVar('CT5_CVKVER')
		M->CT5_CVKSEQ	:=	CriaVar('CT5_CVKSEQ')	
		
		// recria o objeto, porém em modo de alteração
		Self:_oGetEntry := CreateGet("CT5", 0, 3, 3, ;
		                       Self:_oArea:GetPanel(Self:_PanelId))
		
		// atualiza os estados dos botões
		Self:SetStatusToolbar(STATUS_CREATE) 
		
		// mostra o layout
		Self:_oArea:ShowLayout(Self:_LayoutId)
	EndIf
Return

/* ----------------------------------------------------------------------------

PasteLink()

---------------------------------------------------------------------------- */
Method PasteLink(aClipboard) Class CtbEntry

/*	If Len(aClipboard) > 0
		dbSelectArea("CVI")
		Reclock("CVI", .T.)
		
		CVI->CVI_FILIAL := xFilial("CVI")
		
		CVI->CVI_OPER := GetValByRecno("CVG", ;
		                               DecodeRecno(Self:_oTree:GetCargo()), ;
		                               "CVG_OPER")
		
		CVI->CVI_LANPAD := GetFromFieldPos(CT5->(FieldPos("CT5_LANPAD")))
		CVI->CVI_SEQLAN := GetFromFieldPos(CT5->(FieldPos("CT5_SEQUEN")))
		
		CVI->(MsUnlock())
		
		// adiciona o item na árvore
		AddItem(Self:_oTree, {CodeCargo(CVI->(Recno()), NODE_TYPE_ENTRY), ;
		        GetFromFieldPos(CT5->(FieldPos("CT5_DESC"))), ;
                SetEntryImg(1,.F.,CT5->CT5_DC,(CT5->CT5_STATUS=='2')),;
                SetEntryImg(2,.F.,CT5->CT5_DC,(CT5->CT5_STATUS=='2'))})
		
		// posiciona o item na árvore
		Self:_oTree:TreeSeek(CodeCargo(CVI->(Recno()), NODE_TYPE_ENTRY))
		
		// limpa o clipboard
	EndIf*/
Return

/* ----------------------------------------------------------------------------

ConfirmPaste()

---------------------------------------------------------------------------- */
Method ConfirmPaste() Class CtbEntry

	Local cSelCargo := Self:_oTree:GetCargo()
	Local aClipboard := Self:_aClipboard
	
	If Self:Confirm()

		If Len(aClipboard) > 0
			
			If aClipboard[Len(aClipboard) - 2] == CLIPBOARD_CUT
				Self:_oTree:TreeSeek(aClipboard[Len(aClipboard) - 3])
				DelHandler(Self:_oTree)
				Self:_oTree:TreeSeek(cSelCargo)
			EndIf
			
			// esvazia o clipboard	
			aClipboard := {}		
		EndIf
	EndIf
Return

/* ----------------------------------------------------------------------------

SetStatusToolbar()

---------------------------------------------------------------------------- */
Method SetStatusToolbar(nStatus) Class CtbEntry

	Local i := 0

	// desabilita todos os botões
	For i := 1 To Len(Self:_aButtonsEntry)
		Self:_aButtonsEntry[i]:Hide()
	Next
	
	// Habilita o botao para consulta/edicao dos tipos de saldos
	Self:_aButtonsEntry[ Self:_nIdBtn ]:Show()

	Do Case
	
		Case nStatus == STATUS_CREATE // incluir

			// habilita o botões de Confirmar e Cancelar
			Self:_aButtonsEntry[IDX_CONFIRM]:Show()
			Self:_aButtonsEntry[IDX_CANCEL]:Show()

			// muda o título da janela
			oArea:SetTitleWindow(Self:_WindowId, STR0006)
			
		Case nStatus == STATUS_READ   // visualizar

			// habilita o botão de Editar
			Self:_aButtonsEntry[IDX_UPDATE]:Show()
			
			oArea:SetTitleWindow(Self:_WindowId, STR0014)
			
		Case nStatus == STATUS_UPDATE // editar

			// habilita o botões de Confirmar e Cancelar
			Self:_aButtonsEntry[IDX_CONFIRM]:Show()
			Self:_aButtonsEntry[IDX_CANCEL]:Show()
			
			oArea:SetTitleWindow(Self:_WindowId, STR0004)

		Case nStatus == STATUS_DELETE // excluir
		
		Case nStatus == STATUS_UNKNOWN // desconhecido
		
	EndCase
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³SetMltSlds³ Autor ³ Totvs                 ³ Data ³ 02.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para tratamento da multipla selecao do tipo de saldo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SetMltSlds()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA086                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method SetMltSlds( lVisual, cTpSald, cMltSld ) Class CtbEntry
	Local aArea		:= CT5->( GetArea() )
	Local aTpSaldo 	:= {}
	Local nInc		:= 0
	Local cSaldos	:= ""
	
	DEFAULT lVisual := .T. 
	DEFAULT cTpSald := M->CT5_TPSALD
	DEFAULT cMltSld	 := M->CT5_MLTSLD

	cPreSel := cMltSld
	If cTpSald # cPreSel
		cPreSel	+= ";" + cTpSald
	EndIf

	aTpSaldo := CtbTpSld( cPreSel, ";", lVisual )
	For nInc := 1 To Len( aTpSaldo )
		cSaldos += aTpSaldo[ nInc ]
		If nInc < Len( aTpSaldo )
			cSaldos += ";"
		EndIf
	Next

	If !lVisual
		Self:_cTpSaldos	:= cSaldos
		M->CT5_MLTSLD 	:= Self:_cTpSaldos
	EndIf
	
	RestArea( aArea )
Return NIL

// Função Dummy para Gerar Pacote
Function CTBA089()

Return