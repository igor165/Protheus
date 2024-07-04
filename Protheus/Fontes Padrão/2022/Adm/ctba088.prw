#INCLUDE "ctba088.ch"
#INCLUDE "protheus.ch"
#INCLUDE "ctbarea.ch"
#INCLUDE "MSMGADD.CH"
     
//
// Classe CtbOperation
// Copyright (C) 2007, Microsiga
//

Class CtbOperation

	Data _oArea As Object
	Data _oTree As Object
	
	Data _aButtonsOperation As Array
  
	Data _LayoutId As String

	Data _WindowId1 As String
	Data _WindowId2 As String
	
	Data _PanelId1 As String
	Data _PanelId2 As String

	Data _oGetOperation As Object
	Data _oToolbarOperation As Object
	
	Data _oLayout As Object
	
	Data _aEntries As Array
	Data _aBrowseHeader As Array
	
	Data _oBrwEntries As Object
	
	Method New(oArea, oTree) Constructor

	// métodos
	Method Create()
	Method Read()
	Method Update()
	Method Delete()
	
	Method Confirm()
	Method Cancel()
	
	Method Paste()

	Method ReadLPs()
	
	Method SetStatusToolbar(nStatus)
	Method ListEntries(cProcess, cOperation)
	
EndClass

/* ----------------------------------------------------------------------------

New()

---------------------------------------------------------------------------- */
Method New(oArea, oTree) Class CtbOperation

	Local aButtons := {}
	
	Local aToolButtons := {}
	Local aTextButtons := {}
	
	Local aAllButtons := {}
	
	Local i := 1

	Self:_oArea := oArea
	Self:_oTree := oTree
	
	// Ids	
	Self:_LayoutId := "layout_Operation"
	
	Self:_PanelId1 := "panel_Operation"
	Self:_PanelId2 := "panel_Entries"
	
	Self:_WindowId1 := "wnd_Operation"
	Self:_WindowId2 := "wnd_Entries"

	// objetos private para o layout de lançamento
	Self:_oGetOperation := Nil
	Self:_oToolbarOperation := Nil	

	Self:_aBrowseHeader := {STR0001, STR0002, STR0003, STR0004, ; //"Lanç. Padrão"###"Sequência"###"Descrição"###"Status"
	                        STR0005, STR0006, STR0007} //"Tipo. Lcto"###"Conta Débito"###"Conta Crédito"

	// anteriormente, não era utilizado o objeto Self, mas
	// o próprio objeto criado: oOperation

	// Delete
	aAdd(aButtons, {IMG_DELETE, IMG_DELETE, STR0008, ; //"Excluir"
	               {|| Self:Delete() }, STR0009}) //"Excluir operação"

	// Update
	aAdd(aButtons, {IMG_UPDATE, IMG_UPDATE, STR0010, ; //"Editar"
	               {|| Self:Update() }, STR0011}) //"Editar operação"

	// Create	
	aAdd(aButtons, {IMG_CREATE, IMG_CREATE, STR0012, ; //"Incluir"
	               {|| Self:Create() }, STR0013}) //"Incluir operação"
	               
	// adiciona layout	
	Self:_oArea:AddLayout(Self:_LayoutId)
	Self:_oLayout := Self:_oArea:GetLayout(Self:_LayoutId)
	
	// adiciona janela
	Self:_oArea:AddWindow(100, 30, Self:_WindowId1, ;
	                      STR0014, 5, 6, Self:_oLayout) //"Operação"

	// adiciona painel
	Self:_oArea:AddPanel(100, 100, Self:_PanelId1, CONTROL_ALIGN_ALLCLIENT)

	// adiciona barra de ferramentas
	aToolButtons := CreateToolbar(Self:_PanelId1, aButtons)

	// adiciona botões Confirmar e Cancelar
	Self:_oArea:AddTextButton({{STR0015, STR0016}, ;  //"Cancelar"###"Confirmar"
	                           {{|| ChangeHandler(oTree) }, {|| Self:Confirm() }}, ;
	                           {STR0015, STR0016}}) //"Cancelar"###"Confirmar"
	                          
	aTextButtons := oArea:GetTextButton(Self:_PanelId1)

	// adiciona os botões no layout
	For i := 1 To Len(aTextButtons)
		aAdd(aAllButtons, aTextButtons[i])
	Next

	For i := 1 To Len(aToolButtons)
		aAdd(aAllButtons, aToolButtons[i])
	Next

	// trata botões da mesma maneira	
	Self:_aButtonsOperation := aAllButtons
	
	// adiciona get	
	Self:_oGetOperation := CreateGet("CVG", CVG->(Recno()), 2, 3, ;
	                       Self:_oArea:GetPanel(Self:_PanelId1))
	                       
	// adiciona janela de visualização de operações
	Self:_oArea:AddWindow(100, CtbGetHeight(70), Self:_WindowId2, ;
	                      STR0017, 6, 5, Self:_oLayout) //"Lançamentos Padrão"

	// adiciona painel
	Self:_oArea:AddPanel(100, 100, Self:_PanelId2, CONTROL_ALIGN_ALLCLIENT)
	
	// adiciona browse de operações
	Self:_oBrwEntries := TWBrowse():New(0, 0, 290, 252, , ;
	       Self:_aBrowseHeader, , ;
	       Self:_oArea:GetPanel(Self:_PanelId2),,,,,,, ;
	       Self:_oArea:GetPanel(Self:_PanelId2):oFont,,,,,.F.,,.T.,,.F.,,,)
	Self:_oBrwEntries:Align := CONTROL_ALIGN_ALLCLIENT
	Self:ListEntries()	                       
Return Self

/* ----------------------------------------------------------------------------

Create()

Restrições: A função seta a variável Inclui como verdadeiro e as variáveis
Altera e Exclui como falsas.

---------------------------------------------------------------------------- */
Method Create() Class CtbOperation

	// manipula as variáveis públicas para permitir a alteração
	Inclui := .T.
	Altera := .F.
	Exclui := .F.

	// destrói o objeto existente	
	Self:_oGetOperation:oBox:FreeChildren()
	
	// recarrega as variáveis de memória
	RegToMemory("CVG", .T., , , FunName())
  
	// preencher os campos que deve ser preenchidos automaticamente
  M->CVG_PROCES := GetValByRecno("CVJ", ;
	                               DecodeRecno(Self:_oTree:GetCargo()), ;
	                               "CVJ_PROCES", ;
	                               "")
	                               
	// recria o objeto, porém em modo de alteração
	Self:_oGetOperation := CreateGet("CVG", 0, 3, 3, ;
	                       Self:_oArea:GetPanel(Self:_PanelId1))
  
	// mostra o browse de lançamentos padrão
	Self:ListEntries()
	
	// atualiza os estados dos botões
	Self:SetStatusToolbar(STATUS_CREATE) 
	
	// mostra o layout
	Self:_oArea:ShowLayout(Self:_LayoutId)	
Return  


/* ----------------------------------------------------------------------------

Read()

Restrição: o arquivo CVG deve estar posicionado, ou seja, a função
ChangeHandler() deve posicionar o registro do CVG a partir do item selecionado
na árvore. Read() também já marca as variáveis Inclui, Altera e Exclui
como falsas.

---------------------------------------------------------------------------- */
Method Read() Class CtbOperation

	// otimização da leitura - se não está incluindo, alterando ou
	// excluindo um elemento da árvore, então não é necessário
	// recriar o Get para visualizar o novo elemento, basta
	// apenas recarregar o get atual
	If !Inclui .And. !Altera .And. !Exclui

		// atualiza a Enchoice do Lançamento			
		RegToMemory("CVG", .F., , , FunName())
		
		Self:_oGetOperation:EnchRefreshAll()
	Else

		// manipula as variáveis públicas para permitir a alteração
		Inclui := .F.
		Altera := .F.
		Exclui := .F.
	
		// destrói o objeto existente	
		Self:_oGetOperation:oBox:FreeChildren()
		
		// recarrega as variáveis de memória
		RegToMemory("CVG", .F., , , FunName())
	
		// observação: a função RegToMemory()
		// necessita do nome da função inicial,
		// caso contrário, ela falhará
	
		// recria o objeto, porém em modo de alteração
		Self:_oGetOperation := CreateGet("CVG", CVG->(Recno()), 2, 3, ;
		                       Self:_oArea:GetPanel(Self:_PanelId1))
	EndIf

	// lista os lançamentos padrão
	Self:ListEntries(CVG->CVG_PROCES, CVG->CVG_OPER)

	// atualiza os estados dos botões	
	Self:SetStatusToolbar(STATUS_READ)

	// mostra o layout
	Self:_oArea:ShowLayout(Self:_LayoutId)	
Return

/* ----------------------------------------------------------------------------

Update()

Restrição: o arquivo CVG deve estar posicionado, ou seja, a função
ChangeHandler() deve posicionar o registro do CVG a partir do item selecionado
na árvore.

---------------------------------------------------------------------------- */
Method Update() Class CtbOperation

	// manipula as variáveis públicas para permitir a alteração
	Inclui := .F.
	Altera := .T.
	Exclui := .F.

	/*If SoftLock("CVG")
		MsgStop("CVG não pode ser travado.")
		Return
	EndIf	*/

	// destrói o objeto existente	
	Self:_oGetOperation:oBox:FreeChildren()

	// recarrega as variáveis de memória
	RegToMemory("CVG", .F.,,, FunName())

	//
	// WOP: a função RegToMemory() necessita do nome
	//      da função inicial, caso contrário, ela falhará.
	//      Por esta razão é chamada a função FunName()
	//

	// recria o objeto, porém em modo de alteração
	Self:_oGetOperation := CreateGet("CVG", CVG->(Recno()), 4, 4, ;
	                       Self:_oArea:GetPanel(Self:_PanelId1))

	// atualiza os estados dos botões	
	Self:SetStatusToolbar(STATUS_UPDATE)
	
	// mostra o layout
	Self:_oArea:ShowLayout(Self:_LayoutId)
Return

/* ----------------------------------------------------------------------------

Delete()

---------------------------------------------------------------------------- */
Method Delete() Class CtbOperation
	//DelHandler(Self:_oTree)
Return Nil

/* ----------------------------------------------------------------------------

Confirm()

---------------------------------------------------------------------------- */

Method Confirm() Class CtbOperation
	Local i := 0

	If Obrigatorio(Self:_oGetOperation:aGets, Self:_oGetOperation:aTela) // .And. Validação
	dbSelectArea("CVG")
	
	// gravar as alterações do CVG			
	RecLock("CVG", Inclui)

	For i := 1 To CVG->(FCount())
		FieldPut(i, &("M->" + CVG->(FieldName(i))))
	Next

	CVG->CVG_FILIAL := xFilial("CVG")
  CVG->(MsUnlock())

	If Inclui
	
		// adiciona o item na árvore
		AddItem(Self:_oTree, {CodeCargo(CVG->(Recno()), NODE_TYPE_OPERATION), ;
		                CVG->CVG_DESCRI, IMG_COL_OPERATION, IMG_EXP_OPERATION})

		// posiciona a árvore
		Self:_oTree:TreeSeek(CodeCargo(CVG->(Recno()), NODE_TYPE_OPERATION))
	Else

		If Altera

			//
			// WOP: Esta inversão na expressão ao invés de utilizar o operador
			//      <> é para evitar um erro na avaliação de expressão
			//
			//If !(AllTrim(Upper(Self:_oTree:GetPrompt())) == ;
			//     AllTrim(Upper(CVG->CVG_DESCRI)))
				Self:_oTree:ChangePrompt(CVG->CVG_DESCRI, ;
				                         CodeCargo(CVG->(Recno()), ;
				                         NODE_TYPE_OPERATION))
			//EndIf
		EndIf
	EndIf	
	

	// Read() já seta as variáveis Inclui, Altera e Exclui para falsas.	
	
	// recarregar o registro
	Self:Read()
	EndIf
Return

/* ----------------------------------------------------------------------------

Paste()

---------------------------------------------------------------------------- */
Method Paste(aClipboard) Class CtbOperation

	// manipula as variáveis públicas para permitir a alteração
	Inclui := .T.
	Altera := .F.
	Exclui := .F.

	// destrói o objeto existente	
	Self:_oGetOperation:oBox:FreeChildren()
	
	// recarrega as variáveis de memória
	RegToMemory("CVG", .T., , , FunName())
  
	// observação: utilizando este método não é possível copiar o registro de
	// origem, deletá-lo e colar, pois os dados são copiados diretamente do
	// mesmo
	If Len(aClipboard) > 0

	  	M->CVG_PROCES := GetValByRecno("CVJ", ;
		                               DecodeRecno(Self:_oTree:GetCargo()), ;
		                               "CVJ_PROCES", ;
		                               "")			
		M->CVG_DESCRI := GetFromFieldPos(CVG->(FieldPos("CVG_DESCRI")))
		
	EndIf
		                               
	// recria o objeto, porém em modo de alteração
	Self:_oGetOperation := CreateGet("CVG", 0, 3, 3, ;
	                       Self:_oArea:GetPanel(Self:_PanelId1))

	// mostra o browse de lançamentos padrão
	Self:ListEntries(CVG->CVG_PROCES, CVG->CVG_OPER)

	// atualiza os estados dos botões
	Self:SetStatusToolbar(STATUS_CREATE) 
	
	// mostra o layout
	Self:_oArea:ShowLayout(Self:_LayoutId)	
	
	aClipboard := {}
Return


/* ----------------------------------------------------------------------------

SetStatusToolbar()

---------------------------------------------------------------------------- */
Method SetStatusToolbar(nStatus) Class CtbOperation

	Local i := 0

	// desabilita todos os botões
	For i := 1 To Len(Self:_aButtonsOperation)
		Self:_aButtonsOperation[i]:Hide()
	Next

	Do Case
	
		Case nStatus == STATUS_CREATE // incluir

			// habilita o botões de Confirmar e Cancelar
			Self:_aButtonsOperation[IDX_CONFIRM]:Show()
			Self:_aButtonsOperation[IDX_CANCEL]:Show()
			
			oArea:SetTitleWindow(Self:_WindowId1, STR0013) //"Incluir Operação"
					
		Case nStatus == STATUS_READ   // visualizar

			// habilita o botão de Editar
			Self:_aButtonsOperation[IDX_UPDATE]:Show()
			
			oArea:SetTitleWindow(Self:_WindowId1, STR0014) //"Operação"
			
		Case nStatus == STATUS_UPDATE // editar

			// habilita o botões de Confirmar e Cancelar
			Self:_aButtonsOperation[IDX_CONFIRM]:Show()
			Self:_aButtonsOperation[IDX_CANCEL]:Show()
			
			oArea:SetTitleWindow(Self:_WindowId1, STR0011) //"Editar Operação"
		
		Case nStatus == STATUS_DELETE // excluir
		
		Case nStatus == STATUS_UNKNOWN // desconhecido
		
	EndCase
Return

/* ----------------------------------------------------------------------------

ListEntries()

---------------------------------------------------------------------------- */
Method ListEntries(cProcess, cOperation) Class CtbOperation
	Local aArea := GetArea()
	Local aAreaCT5 := CT5->(GetArea())
	Local aAreaCVI := CVI->(GetArea())

	Default cProcess   := ""	
	Default cOperation := ""
	
	Self:_aEntries := {}

	// seleciona amarrações
	dbSelectArea("CVI")
	CVI->(dbSetOrder(3))
	CVI->(MsSeek(xFilial("CVI") + cProcess + cOperation))
	
	While !CVI->(Eof()) .And. CVI->CVI_FILIAL == xFilial("CVI") .And. ;
		                        CVI->CVI_PROCES == cProcess .And. ;
	                          CVI->CVI_OPER	== cOperation

		dbSelectArea("CT5")
		CT5->(dbSetOrder(1))
		If CT5->(MsSeek(xFilial("CT5") + CVI->CVI_LANPAD + CVI->CVI_SEQLAN))
  	
			Aadd(Self:_aEntries, {CT5->CT5_LANPAD, CT5->CT5_SEQUEN, CT5->CT5_DESC, ;
			                      CT5->CT5_STATUS, CT5->CT5_TPSALD, CT5->CT5_DEBITO, ;
			                      CT5->CT5_CREDIT})
		EndIf		
	
		dbSelectArea("CVI")		
		CVI->(dbSkip())		
	End

	If Len(Self:_aEntries) == 0
		Self:_aEntries := {{"", "", "", ""}}	
	EndIf

	Self:_oBrwEntries:SetArray(Self:_aEntries)
	Self:_oBrwEntries:bLine := {|| Self:_aEntries[Self:_oBrwEntries:nAT] }
	Self:_oBrwEntries:Refresh()
		
	RestArea(aAreaCVI)
	RestArea(aAreaCT5)	
	RestArea(aArea)			
Return Nil

/* ----------------------------------------------------------------------------

New()

---------------------------------------------------------------------------- */
Method ReadLPs() Class CtbOperation
Local oRadioVer
Local aVersoes	:=	{}
Local aLPS	:=	{}
Local cCond	:=	""              
Local nX                      
LOcal aDados	:=	{}
Local oOk		:= LoadBitMap(GetResources(), "LBOK")
Local oNo		:= LoadBitMap(GetResources(), "LBNO")
Local aTam
Local aHead
Local oLBCVK
Local oBar
Local oGetCPOS
Private cCadastro	:=	STR0018 //"Lancamentos padroes pre-configurados"
Private aGets,aTela
CVG->(MsGoTo(DecodeRecno(Self:_oTree:GetCargo())))
CVJ->(DbSetOrder(1))
CVJ->(DbSeek(xFilial('CVJ')+CVG->CVG_PROCES))


aLPS	:=	GetVldLPs(CVJ->CVJ_MODULO,CVG->CVG_PROCES,CVG->CVG_OPER)
If CVJ->CVJ_MODULO == '07' //SIGAGPE
	cCond	:=	"% CVK_LANPAD BETWEEN 'A  ' AND 'z  ' %"	
ElseIF CVJ->CVJ_MODULO == '33' //SIGAPLS
	cCond	:=	"% CVK_LANPAD BETWEEN '9A0' AND '9CZ' %"	
ElseIf CVJ->CVJ_MODULO == '34' //SIGACTB
	cCond	:=	"% CVK_LANPAD BETWEEN '0  ' AND '499' %"	
Else              
	For nX := 1 To Len(aLPs)
		cCond	+=	"'"+aLPs[nX]+"',"
	Next nX	         
	cCond	:=	"% CVK_LANPAD IN ("+Substr(cCond,1,Len(cCond)-1)+") %"	
Endif

BeginSql alias 'VLDLAN'
	SELECT CVK_LANPAD, CVK_DESC, CVK.R_E_C_N_O_ as CVKRECNO 
	FROM %TABLE:CVK% CVK
	WHERE 	CVK_FILIAL=%xFilial:CVK% AND 
			%Exp:cCond% AND
			CVK_VERSAO =
				( SELECT MAX(CVK_VERSAO)
					FROM %TABLE:CVK% CVK
					WHERE 	CVK_FILIAL=%xFilial:CVK% AND 
						%exp:cCond% AND 
						CVK.%NotDel%
					GROUP BY CVK_VERSAO
    			) AND
			CVK.%NotDel%

EndSql	

//Carrega os dados no array
While !Eof()
	AAdd(aDados,{-1,CVK_LANPAD,CVK_DESC,CVKRECNO})	
	DbSkip()
Enddo	
DbCloseArea()

If Len(aDados) > 0

	oWizard := APWizard():New(	STR0019/*<chTitle>*/,; //"Atencao" //"Atencao"
								STR0020/*<chMsg>*/, ; //"Este assistente lhe ajudara a incluir um novo lancamento padrao."
  								STR0021/*<cTitle>*/, ;  //"Inclusao de lancamento padroa"
								STR0022+Capital(Alltrim(CVG->CVG_DESCri))+STR0023+Capital(Alltrim(CVJ->CVJ_DESCRI))+"." /*<cText>*/,;  //"Selecione um lancamento padrao para a operacao "###" do processo "
	  							{|| .T.}/*<bNext>*/, ;
								{|| .T.}/*<bFinish>*/,;
								/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)
	
	oWizard:NewPanel( 	STR0024/*<chTitle>*/,;  //"Lancamento padrao"
						STR0025/*<chMsg>*/, ;  //"Neste passo voce deverá selecionar o lancamento padrao desejado."
						{||.T.}/*<bBack>*/, ;
						{||oGetCPOS:=VerifDados(aDados,oWizard:oMPanel[3],oGetCPOS),.T.}/*<bNext>*/, ;
						{|| .T. }/*<bFinish>*/,;
						.T./*<.lPanel.>*/,;
					 	{|| .T.}/*<bExecute>*/ )

	oWizard:NewPanel( 	STR0024/*<chTitle>*/,;  //"Lancamento padrao"
						STR0026/*<chMsg>*/, ;  //"Neste passo voce deverá preencher os dados solicitados, ou confirmar caso nenhum dado seja solicitado."
			   			{||.F.}/*<bBack>*/, ; //	
						{||.F.}/*<bNext>*/, ;
						{|| If(CT5VldGets(aDados),(GravaCVKCT5(aDados),.T.),.F.)}/*<bFinish>*/,;
						.T./*<.lPanel.>*/,;
					 	{|| .T.}/*<bExecute>*/ )

	
	//Cria ListoBox do painel 2	
	aHead	:=	{'',STR0027,STR0028} //'Codigo'###'Descricao'
	aTam	:=	{10,20,100}
	oLBCVK	:= TwBrowse():New(0,0,200,200, 	,aHead,aTam,oWizard:oMPanel[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLBCVK:SetArray(aDados)
	oLBCVK:bLine := {|| {If(aDados[oLBCVK:nAt,1]>0,oOk,oNo),aDados[oLBCVK:nAt,2],aDados[oLBCVK:nAt,3]}}
	oLBCVK:Align := CONTROL_ALIGN_ALLCLIENT	  
	oLBCVK:bLDblClick :={ || aDados[oLBCVK:nAt,1]	:=	ChkDblClick(aDados[oLBCVK:nAt,1],aDados[oLBCVK:nAt,4])}
	//Cria button bar do painel 2
	DEFINE BUTTONBAR oBar SIZE 15,15 3D TOP OF oWizard:oMPanel[2]
	oBar:Align := CONTROL_ALIGN_TOP
	oBtn:=TBtnBmp():NewBar( "BMPVISUAL","BMPVISUAL",,,STR0029, {|| CVK->(MsGoTo(aDados[oLBCVK:nAT][4])),axVisual('CVK',aDados[oLBCVK:nAT][4],2) },.T.,oBar,,,STR0030)  //"Visualizar Lancamento"###"Visualizar"
	oBtn:Align := CONTROL_ALIGN_RIGHT	
	
	
		
		oWizard:Activate( .T./*<.lCenter.>*/,;
								 {||.T.}/*<bValid>*/, ;
								 {||.T.}/*<bInit>*/, ;
								 {||.T.}/*<bWhen>*/ )
	
	// atualiza a árvore
	RefreshTree(Self:_oTree, CodeCargo(CVI->(Recno()), NODE_TYPE_ENTRY))
	Self:_oTree:TreeSeek(CodeCargo(CVI->(Recno()), NODE_TYPE_ENTRY))
Else
	Aviso('Sem lancamentos','Nao existem lançamentos pre-cadastrados para este processo e operação',{'Ok'})
Endif
Return Nil        
                                 

Static Function ChkDblClick(nAtual,nRecCVI)

Do Case               
//Se esta marcado, desmarca
Case nAtual > 0
	nAtual	*= -1
//Se esta desmarcado, vamos verificar se precisamos de confirmacao
Case nAtual < 0
	//Nunca foi solicitada verificacao
	If nAtual == -1    
		CVK->(MsGoTo(nRecCVI))
		BeginSql alias 'TEMP'
			SELECT Count(*) CONTA FROM %TABLE:CT5% CT5 
			WHERE CT5_FILIAL=%xFilial:CT5% AND CT5_LANPAD = %Exp:CVK->CVK_LANPAD%  AND
				  CT5_CVKSEQ=%EXP:CVK->CVK_SEQUEN% AND	
				CT5.%NotDel%
		EndSql	
		If CONTA == 0	
        	nAtual	*= -1
        Else
        	nOpcao	:=	Aviso(STR0035,STR0036,{STR0037,STR0038})		 //'Lancamento ja importado'###'Este lancamento ja foi importado, deseja sobrescrever o lancamento anterior?'###'Sim'###'Cancelar'
			If nOpcao == 1
				nAtual	:=	2
			Endif	
		Endif
		DbCloseArea()
	ElseIf nAtual == -2
		nAtual	*=	-1
	Endif
EndCase	
Return nAtual         

Static Function VerifDados(aDados,oPanel,oGetCpos)
Local nX,nY
Local cSeq                                                              
Local aCamposPerg
DbSelectArea('CVK')
For nX:= 1  To Len(aDados)
	If aDados[nX,1] > 0     
	    CVK->(MsGoTo(aDados[nX,4]))
	    Aadd(aDados[nX],{})
		For nY:=1 TO Fcount()
			If Substr(FieldGet(nY),1,1) =='*'
				AAdd(aDados[nX,5],{"CT5_"+Substr(FieldName(nY),5),Substr(FieldGet(nY),2),""})
		    Endif
		Next    
	Endif
Next
SX3->(DbSetOrder(2))
If ValType(oGetCpos) == "O"
	oGetCpos:oBox:FreeChildren()
	aGets	:=	Nil
	aTela	:=	Nil
Endif	
aCamposS	:=	{}
For nX:= 1 TO Len(aDados)
   	If aDados[nX,1] >0  
		For nY:=1 To Len(aDados[nX,5])
			SX3->( MsSeek( PadR( aDados[nX,5,nY,1], 10 ) ) )
			ADD FIELD aCamposS ;
			TITULO SX3->X3_TITULO ;
			CAMPO 'CPO_'+STRZERO(nX,3)+STRZERO(nY,3) ;                  
			TIPO SX3->X3_TIPO ;
			TAMANHO SX3->X3_TAMANHO ;
			DECIMAL SX3->X3_DECIMAL ;
			PICTURE PesqPict(SX3->X3_ARQUIVO,SX3->X3_CAMPO) ;
			NIVEL SX3->X3_NIVEL ;                                                  
			F3 SX3->X3_F3 	
			aCamposS[Len(aCamposS),7]	:= &('{ || '+ Alltrim(SX3->X3_VALID)+"}")
			_SetNamedPrvt("CPO_"+STRZERO(nX,3)+STRZERO(nY,3),aDados[nX,5,nY,2], 'READLPS') //Tem que ser privada no metodo onde esta o Wizard
		Next nY	
	Endif
Next
If Len(aCamposS) > 0
	oGetCpos:= MsMGet():New("CVK",/*CVK->(RecNo())*/,3,,,,,{0,0,400,400},,3,,,,oPanel,,,,,,.T.,aCamposS)		
	oGetCpos:oBox:Align := CONTROL_ALIGN_ALLCLIENT		
Else
	@ 0, 0 Say oGetCpos Var "" ;
	       Of oPanel PIXEL HTML 	
	oGetCpos:Align := CONTROL_ALIGN_ALLCLIENT
	oGetCpos:cCaption :=	"<p>Nao é necessário digitar nenhum dado adicional para os lançamentos escolhidos, clique em finalizar para confirmar a operação.</P>"
Endif
Return oGetCpos


Static Function CT5VldGets(aDados)
Local nX,nY
Local nCampo	:=	0                        
Local cCampo	:=	""
For nX:= 1 TO Len(aDados)
   	If aDados[nX,1]  > 0  
		For nY:=1 To Len(aDados[nX,5])
			nCampo++
			If aDados[nX,5,nY,2] == &('CPO_'+STRZERO(nX,3)+STRZERO(nY,3))                                      
				cCampo	+=	StrZero(nCampo,2)+","
			Endif
		Next nY	
	Endif
Next
If !Empty(cCampo)                                                                                     
	If Len(cCampo) > 3
		Aviso(STR0031, STR0032+Substr(cCampo,1,Len(cCampo)-1)+".",{ STR0033} ) //'Dados nao validos'###'Digite dados válidos para os campos nas posicoes '###'Ok'
	Else
		Aviso(STR0031, STR0034+Substr(cCampo,1,Len(cCampo)-1)+".",{ STR0033} )	 //'Dados nao validos'###'Digite um dado válido para o campo na posicao '###'Ok'
	Endif
Endif
Return Empty(cCampo)

Static Function GravaCVKCT5(aDados)
Local nY,nX
For nX:= 1  To Len(aDados)
	If aDados[nX,1] >0 
	    CVK->(MsGoTo(aDados[nX,4]))

		If aDados[nX,1] > 1
			BeginSql alias 'TEMP'
				SELECT CT5_SEQUEN FROM %TABLE:CT5% CT5 
				WHERE CT5_FILIAL=%xFilial:CT5% AND CT5_LANPAD = %Exp:CVK->CVK_LANPAD%  AND
					  CT5_CVKSEQ=%EXP:CVK->CVK_SEQUEN% AND	
					CT5.%NotDel%
			EndSql	
			cSeq	:=	TEMP->CT5_SEQUEN 
			DbCloseArea()			
			CT5->(DbSetOrder(1))
			CT5->(MsSeek(xFilial('CT5')+CVK->CVK_LANPAD +cSeq))
			CVI->(DbSetOrder(3))
			CVI->(MsSeek(xFilial('CVI')+CVG->CVG_PROCES+CVG->CVG_OPER+CVK->CVK_LANPAD +cSeq))
		Else
		    cSeq	:=	CT5GetSeq(aDados[nX,2])
		Endif
		RecLock('CT5',(aDados[nX,1] == 1))
		//Grava todos os campos do CVK que existem no CT5
		For nY:=1 TO Fcount()
			If CT5->(FieldName(nY)) <> "CT5_SEQUEN" .And. (nPosCpo	:= CVK->(FieldPos('CVK_'+Substr(CT5->(FieldName(nY)),5))))> 0
				CT5->(FieldPut(nY,CVK->(FieldGet(nPosCPo))))
		    Endif
		Next    
		//Grava os campos que oram solicitados ao usuario		
		For nY:=1 To Len(aDados[nX,5])
			CT5->(FieldPut(FieldPos(aDados[nX,5,nY,1]),&('CPO_'+STRZERO(nX,3)+STRZERO(nY,3))))
		Next nY	
		//Grava os campos padroes
		CT5_FILIAL	:=	xFilial('CT5')  	
		CT5_SEQUEN	:=	cSeq
		CT5_CVKSEQ	:=	CVK->CVK_SEQUEN
		CT5_CVKVER	:=	CVK->CVK_VERSAO
		MsUnLock()			     
		//Grava o vinculo com CVI

		RecLock('CVI',(aDados[nX,1] == 1))
		CVI_FILIAL	:=	xFilial()
		CVI_LANPAD	:=	CT5->CT5_LANPAD
		CVI_SEQLAN	:=	CT5->CT5_SEQUEN
		CVI_PROCES	:=  CVG->CVG_PROCES
		CVI_OPER	:=  CVG->CVG_OPER
		MsUnLock()	    
		FreeUsedCodes()
	Endif
Next	

Return .T.

Function CT5GetSeq(cLanPad)

BeginSql alias 'SEQCT5'
	SELECT MAX(CT5_SEQUEN) CT5_SEQUEN
	FROM %TABLE:CT5% CT5
	WHERE 	CT5_FILIAL=%xFilial:CT5% AND 
			CT5_LANPAD = %Exp:cLanPad%  AND
			CT5.%NotDel%
EndSql	
If EOF()
	cRet	:=	StrZero(1,Len(CT5->CT5_SEQUEN))
Else
	cRet	:=	Soma1(SEQCT5->CT5_SEQUEN)
Endif
DbCloseArea()
While !FreeForUse('CT5',cLanPad+cRet) 
	cRet	:=	Soma1(cRet)	
Enddo	

Return cRet                      

