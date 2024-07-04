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

	// m�todos
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

	// objetos private para o layout de lan�amento
	Self:_oGetEntry := Nil
	Self:_oToolbarEntry := Nil	
	Self:_lMltSld	:= ( CT5->( FieldPos( "CT5_MLTSLD" ) ) > 0 )
	Self:_cTpSaldos := IIF(Self:_lMltSld,CRIAVAR("CT5_MLTSLD"),"")

	//
	// o objeto oEntry estava "chumbado", ou seja, para o bot�o
	// funcionar, a inst�ncia da classe Entry devia nomeada
	// como oEntry. Agora foi substitu�da por Self.
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

	// adiciona bot�es Confirmar e Cancelar
	Self:_oArea:AddTextButton({{ STR0008, STR0009 }, ; 
	                           {{|| ChangeHandler(oTree) }, {|| Self:Confirm() } }, ;
	                           {STR0010, STR0011 }})
	                          
	aTextButtons := oArea:GetTextButton(Self:_PanelId)

	// adiciona os bot�es no layout
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

	// trata bot�es da mesma maneira	
	Self:_aButtonsEntry := aAllButtons

	// adiciona get	
	Self:_oGetEntry := CreateGet("CT5", CT5->(Recno()), 2, 3, ;
	                       Self:_oArea:GetPanel(Self:_PanelId))
Return Self

/* ----------------------------------------------------------------------------

Create()

Restri��es: A fun��o seta a vari�vel Inclui como verdadeiro e as vari�veis
Altera e Exclui como falsas.

---------------------------------------------------------------------------- */
Method Create() Class CtbEntry

	// altera a confirma��o da opera��o de colar
	Self:_aButtonsEntry[IDX_CONFIRM]:bAction := {|| Self:Confirm()}

	// manipula as vari�veis p�blicas para permitir a altera��o
	Inclui := .T.
	Altera := .F.
	Exclui := .F.

	// destr�i o objeto existente	
	Self:_oGetEntry:oBox:FreeChildren()
	
	// recarrega as vari�veis de mem�ria
	RegToMemory("CT5", .T., , , FunName())

	// recria o objeto, por�m em modo de altera��o
	Self:_oGetEntry := CreateGet("CT5", 0, 3, 3, ;
	                       Self:_oArea:GetPanel(Self:_PanelId))

	// atualiza os estados dos bot�es
	Self:SetStatusToolbar(STATUS_CREATE) 

	// mostra o layout
	Self:_oArea:ShowLayout(Self:_LayoutId)	
Return  


/* ----------------------------------------------------------------------------

Read()

Restri��o: o arquivo CT5 deve estar posicionado, ou seja, a fun��o
ChangeHandler() deve posicionar o registro do CT5 a partir do item selecionado
na �rvore. Read() tamb�m j� marca as vari�veis Inclui, Altera e Exclui
como falsas.

---------------------------------------------------------------------------- */
Method Read() Class CtbEntry
	// multiplos tipos de saldos
	Self:_lMltSld	:= ( CT5->( FieldPos( "CT5_MLTSLD" ) ) > 0 )
	Self:_cTpSaldos := IIF(Self:_lMltSld,CT5->CT5_MLTSLD,"")

	// otimiza��o da leitura - se n�o est� incluindo, alterando ou
	// excluindo um elemento da �rvore, ent�o n�o � necess�rio
	// recriar o Get para visualizar o novo elemento, basta
	// apenas recarregar o get atual
	If !Inclui .And. !Altera .And. !Exclui

		// atualiza a Enchoice do Lan�amento			
		RegToMemory("CT5", .F., , , FunName())
		
		Self:_oGetEntry:EnchRefreshAll()
	Else

		// manipula as vari�veis p�blicas para permitir a altera��o
		Inclui := .F.
		Altera := .F.
		Exclui := .F.
	
		// destr�i o objeto existente	
		Self:_oGetEntry:oBox:FreeChildren()
		
		// recarrega as vari�veis de mem�ria
		RegToMemory("CT5", .F., , , FunName())
	
		// observa��o: a fun��o RegToMemory()
		// necessita do nome da fun��o inicial,
		// caso contr�rio, ela falhar�
	
		// recria o objeto, por�m em modo de altera��o
		Self:_oGetEntry := CreateGet("CT5", CT5->(Recno()), 2, 3, ;
		                       Self:_oArea:GetPanel(Self:_PanelId))
	EndIf

	// atualiza os estados dos bot�es	
	Self:SetStatusToolbar(STATUS_READ)
	
	// mostra o layout
	Self:_oArea:ShowLayout(Self:_LayoutId)
Return

/* ----------------------------------------------------------------------------

Update()

Restri��o: o arquivo CT5 deve estar posicionado, ou seja, a fun��o
ChangeHandler() deve posicionar o registro do CT5 a partir do item selecionado
na �rvore.

---------------------------------------------------------------------------- */
Method Update() Class CtbEntry

	// altera a confirma��o da opera��o de colar
	Self:_aButtonsEntry[IDX_CONFIRM]:bAction := {|| Self:Confirm()}

	// manipula as vari�veis p�blicas para permitir a altera��o
	Inclui := .F.
	Altera := .T.
	Exclui := .F.

	/*If SoftLock("CT5")
		MsgStop("CT5 n�o pode ser travado.")
		Return
	EndIf	*/

	// destr�i o objeto existente	
	Self:_oGetEntry:oBox:FreeChildren()

	// recarrega as vari�veis de mem�ria
	RegToMemory("CT5", .F.,,, FunName())

	//
	// WOP: a fun��o RegToMemory() necessita do nome
	//      da fun��o inicial, caso contr�rio, ela falhar�.
	//      Por esta raz�o � chamada a fun��o FunName()
	//

	// recria o objeto, por�m em modo de altera��o
	Self:_oGetEntry := CreateGet("CT5", CT5->(Recno()), 4, 4, ;
	                       Self:_oArea:GetPanel(Self:_PanelId))

	// atualiza os estados dos bot�es	
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

Restri��es: Esta fun��o tem como premissas:

- O lan�amento padr�o (CT5) pode apenas ser inclu�do abaixo de uma opera��o,
ou seja, um n� do tipo NODE_TYPE_OPERATION

- Valida apenas a inclus�o, pois os campos CT5_LANPAD e CT5_SEQLAN n�o podem
ser modificados na altera��o

- Se for uma inclus�o, � necess�rio incluir o relacionamento entre opera��o
e lan�amento padr�o. Isto � feito criando-se o registro no CVI. Neste caso,
o CVG deve estar posicionado

- Se for uma altera��o, n�o � necess�rio criar um registro no CVI, basta
apenas modific�-lo para refletir o novo relacionamento. Neste caso, tanto o
CVI quanto o CT5 devem estar posicionados

---------------------------------------------------------------------------- */

Method Confirm() Class CtbEntry
	
	Local i := 0
	Local cProcess := ""
	Local cOperation := "" 
	Local lSuccess := .T.
	
	If Obrigatorio(Self:_oGetEntry:aGets, Self:_oGetEntry:aTela)

		// valida a inclus�o	
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
		
		// gravar as altera��es do CT5			
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
		
			// toda inclus�o deve incluir tamb�m o CVI	
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
	
			// adiciona o item na �rvore
			AddItem(Self:_oTree, {CodeCargo(CVI->(Recno()), NODE_TYPE_ENTRY), ;
			                CT5->CT5_DESC,;
			                SetEntryImg(1,.F.,CT5->CT5_DC,(CT5->CT5_STATUS=='2')),;
			                SetEntryImg(2,.F.,CT5->CT5_DC,(CT5->CT5_STATUS=='2'))})
      
			// atualiza a �rvore
			RefreshTree(Self:_oTree, CodeCargo(CVI->(Recno()), NODE_TYPE_ENTRY))

			Self:_oTree:TreeSeek(CodeCargo(CVI->(Recno()), NODE_TYPE_ENTRY))
		Else
	
			If Altera
	
				// verifica se existe o link no CVI, pois se existir o registro
				// est� classificado. caso contr�rio, apenas o CT5 (lan�amento
				// padr�o n�o classificado) que est� sendo editado e n�o h� raz�o
				// para procurar o n� CVI na �rvore		
				dbSelectArea("CVI")
				CVI->(dbSetOrder(2))
				If CVI->(MsSeek(xFilial("CVI") + CT5->CT5_LANPAD + CT5->CT5_SEQUEN))
	
					//
					// WOP: Esta invers�o na express�o ao inv�s de utilizar o operador
					//      <> � para evitar um erro na avalia��o de express�o
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
	    
		// Read() j� seta as vari�veis Inclui, Altera e Exclui para falsas.	
		
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
		// WOP: preenche _aClipboard pois aClipboard n�o � vis�vel no bloco
		//      de c�digo abaixo
		//
		Self:_aClipboard := aClipboard

		// altera a confirma��o da opera��o de colar
		Self:_aButtonsEntry[IDX_CONFIRM]:bAction := {|| Self:ConfirmPaste()}

		// manipula as vari�veis p�blicas para permitir a altera��o
		Inclui := .T.
		Altera := .F.
		Exclui := .F.
	
		// destr�i o objeto existente	
		Self:_oGetEntry:oBox:FreeChildren()
		
		// recarrega as vari�veis de mem�ria
		RegToMemory("CT5", .T., , , FunName())
		
		For i := 1 To CT5->(FCount())
			&("M->" + CT5->(FieldName(i))) := aClipboard[i]
		Next
        
		// zera o c�digo da seq��ncia
		M->CT5_SEQUEN := Space(Len(CT5->CT5_SEQUEN))
		// zera o c�digo do lancamento padrao
		M->CT5_LANPAD := Space(Len(CT5->CT5_LANPAD))
		
		// inverte o lan�amento caso especificado
		If lReversal .And. GetFromFieldPos(CT5->(FieldPos("CT5_DC"))) $ "123"
		
			Do Case
			// d�bito, cola como cr�dito
			Case GetFromFieldPos(CT5->(FieldPos("CT5_DC"))) == "1"
				M->CT5_DC := "2"
			// cr�dito, cola como d�bito
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
		
		// recria o objeto, por�m em modo de altera��o
		Self:_oGetEntry := CreateGet("CT5", 0, 3, 3, ;
		                       Self:_oArea:GetPanel(Self:_PanelId))
		
		// atualiza os estados dos bot�es
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
		
		// adiciona o item na �rvore
		AddItem(Self:_oTree, {CodeCargo(CVI->(Recno()), NODE_TYPE_ENTRY), ;
		        GetFromFieldPos(CT5->(FieldPos("CT5_DESC"))), ;
                SetEntryImg(1,.F.,CT5->CT5_DC,(CT5->CT5_STATUS=='2')),;
                SetEntryImg(2,.F.,CT5->CT5_DC,(CT5->CT5_STATUS=='2'))})
		
		// posiciona o item na �rvore
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

	// desabilita todos os bot�es
	For i := 1 To Len(Self:_aButtonsEntry)
		Self:_aButtonsEntry[i]:Hide()
	Next
	
	// Habilita o botao para consulta/edicao dos tipos de saldos
	Self:_aButtonsEntry[ Self:_nIdBtn ]:Show()

	Do Case
	
		Case nStatus == STATUS_CREATE // incluir

			// habilita o bot�es de Confirmar e Cancelar
			Self:_aButtonsEntry[IDX_CONFIRM]:Show()
			Self:_aButtonsEntry[IDX_CANCEL]:Show()

			// muda o t�tulo da janela
			oArea:SetTitleWindow(Self:_WindowId, STR0006)
			
		Case nStatus == STATUS_READ   // visualizar

			// habilita o bot�o de Editar
			Self:_aButtonsEntry[IDX_UPDATE]:Show()
			
			oArea:SetTitleWindow(Self:_WindowId, STR0014)
			
		Case nStatus == STATUS_UPDATE // editar

			// habilita o bot�es de Confirmar e Cancelar
			Self:_aButtonsEntry[IDX_CONFIRM]:Show()
			Self:_aButtonsEntry[IDX_CANCEL]:Show()
			
			oArea:SetTitleWindow(Self:_WindowId, STR0004)

		Case nStatus == STATUS_DELETE // excluir
		
		Case nStatus == STATUS_UNKNOWN // desconhecido
		
	EndCase
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �SetMltSlds� Autor � Totvs                 � Data � 02.10.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para tratamento da multipla selecao do tipo de saldo���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � SetMltSlds()                                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CTBA086                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

// Fun��o Dummy para Gerar Pacote
Function CTBA089()

Return