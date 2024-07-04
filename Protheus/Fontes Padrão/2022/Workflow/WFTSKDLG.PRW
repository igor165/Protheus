#INCLUDE "PROTHEUS.CH"
#INCLUDE "WFTSKDLG.ch"
#Include "SIGAWF.CH"


Static __oWFTskDlg := nil

Function WFTskManDlg(oOwner)
	if __oWFTskDlg == nil
		__oWFTskDlg := WFTskManDlg():New(oOwner)
	end
Return __oWFTskDlg

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºClasse	 ³WFTskManDlgºAutor ³Cesar A. Bianchi    º Data ³  20/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Interface grafica do Messenger (WorkFlow)                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10 - Messenger                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Class WFTskManDlg
	data oDlg 			//Formulario "Dialog" principal
	data oBtnNewMsg	    //Botao "Nova Mensagem"
	data oBtnRastro		//Botao "Rastreabilidade"
	data oBtnDelMsg		//Botao "Remover" Mensagem
	data oBtnHis		//Botao "Historico"
	data oBtnEnd		//Botao "Sair"
	data oList			//Objeto "ListBox" 
	data oItens			//Objeto "MsSelect" com os itens
	data oMeter			//Objeto "TMeter" - Regua de Processamento
	data oTimer			//Objeto "TTimer" - Executa a cada 20 Segundos
	data aCmpBrw		//Campos que estao presentes na MsSelect
	data aList			//Array "Itens do ListBox"
	data aUserButtons	//Array com os botoes de usuario na EnchoiceBar
	data cUserId		//Cod. Usuario Logado
	data cUserName		//Nome do Usuario Logado
	data cMarca       	//Marca de selecao
	data nOpc			//Seta a Opcao Escolhida (WorkFlow ou Menssagens)
	data cList			//String com o item selecionado.	
	data aMarked		//Array com os itens Marcados para exclusao
	data oTaskMan 		//Owner
	data nRecnoWF6		//Recno da WF6 em selecao na MsSelect
	Data aFolders
	Data oTempTable     // Objeto de tabela temporária.
	
	Method New(oOwner) CONSTRUCTOR	
	Method NewTRB()
	Method LoadTRB()
	Method DestroyTRB()
	Method Refresh()
	Method Show()
	Method ChangeItem()
	Method ExecuteAction()
	Method SetOpc(nOption)
	Method SetList(aUserList)
	Method MarkMsg()
	Method NewMsg()
	Method OpenMsg()
	Method HstMsg()
	Method DeleteMsg()
	Method EndApp()
	Method RastroWork()	
	Method AddButton()
	Method HtmlFile(cAcao)
	Method AddFolder()

Endclass
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |New 										º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |19/01/10   								º
ºDescription: |Metodo Construtor da classe WFTskManDlg	º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method New(oOwner,nOption) class WFTskManDlg

::oDlg         := Nil		
::oBtnNewMsg   := Nil
::oBtnRastro   := Nil
::oBtnDelMsg   := Nil
::oBtnHis      := Nil
::oBtnEnd      := Nil
::oList        := Nil
::oMeter       := Nil
::aList        := {}
::oItens       := Nil
::aCmpBrw      := {} 
::cUserId      := __cUserId
::cList        := ""
::aMarked      := {}
::oTaskMan     := oOwner
::aFolders     := {}
::nRecnoWF6	   := 0
::aUserButtons := {}
::oTempTable   := Nil

//Coleta o nome do usuario
PswOrder(1)
If (PswSeek(::cUserId, .T.))
    ::cUserName := upper(Pswret(1)[1,2])
EndIf
::SetOpc(nOption)
::SetList(::aList)
::NewTRB()
::LoadTRB(1)
::cMarca	:= getMark()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |NewTRB									º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |19/01/10   								º
ºDescription: |Inicializa a area "TRB"					º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method NewTRB() class WFTskManDlg
	Local aTRB   := {}
	Local cQuery := "" 
    
    //Campos que estarao na MsSelect
	::aCmpBrw := {{ "TRB_OK"  		 ,,"  " 				  	 	, "@!" },;
					{"TRB_DE"        ,, Sx3Get("WF6_DE",4)   	 	, "@!" /*Sx3Get("WF6_DE",6)*/ },; 
					{"TRB_PARA"  	 ,, Sx3Get("WF6_PARA",4)    	, "@!" /*Sx3Get("WF6_PARA",6)*/},;
					{"TRB_DATA"      ,, Sx3Get("WF6_DATA",4)       	, "@!" /*Sx3Get("WF6_DATA",6)*/},;
					{"TRB_HORA"      ,, Sx3Get("WF6_HORA",4)      	, "@!" /*Sx3Get("WF6_HORA",6)*/},; 
					{"TRB_DTVENC"    ,, Sx3Get("WF6_DTVENC",4) 		, "@!" /*Sx3Get("WF6_DTVENC",6)*/},;
					{"TRB_HRVENC" 	 ,, Sx3Get("WF6_HRVENC",4) 		, "@!" /*Sx3Get("WF6_HRVENC",6)*/}}
	

	//Campos que compoe a tabela TRB
	Aadd( aTRB, {"TRB_OK"  	      ,"C"    ,2            			 	,0    })
	Aadd( aTRB, {"TRB_DE"  	      ,"C"    ,TamSx3("WF6_DE")[1]		 	,0    })
	Aadd( aTRB, {"TRB_PARA"  	  ,"C"    ,TamSx3("WF6_PARA")[1] 	 	,0    })
	Aadd( aTRB, {"TRB_DATA"  	  ,"C"    ,TamSx3("WF6_DATA")[1] 	 	,0    })
	Aadd( aTRB, {"TRB_HORA"  	  ,"C"    ,TamSx3("WF6_HORA")[1] 	 	,0    })
	Aadd( aTRB, {"TRB_DTVENC"  	  ,"C"    ,TamSx3("WF6_DTVENC")[1] 	 	,0    })
	Aadd( aTRB, {"TRB_HRVENC"  	  ,"C"    ,TamSx3("WF6_HRVENC")[1] 	 	,0    })
	Aadd( aTRB, {"TRB_RECWF6"  	  ,"N"    ,10 						 	,0    })
	
	//-----------------------------------------
	// Fecha área TRB caso esteja aberta.
	//-----------------------------------------
	iif(Select('TRB')>0,TRB->(dbCloseArea()),Nil)

	//-----------------------------------------
	// Criação do objeto de arquivo temporário.
	//-----------------------------------------
	::oTempTable := FWTemporaryTable():New( "TRB" )
	::oTemptable:SetFields( aTRB )

	::oTempTable:AddIndex( "indice1", { "TRB_DATA", "TRB_HORA" } )

	//-----------------------------------------
	// Criação da tabela.
	//-----------------------------------------
	::oTempTable:Create()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |LoadTRB									º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |19/01/10   								º
ºDescription: |Carrega os dados da tabela "TRB"			º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method LoadTRB(nItem) class WFTskManDlg
Local cKey := xFilial( "WF6" ) + Upper(Left(::cUserName + Space( 15 ),15 ))
Local cFilter := '4'
                         
//Alimenta a TRB (MsSelect)
if Select('TRB') == 0
	::NewTRB()
endif     

//Monta o Filtro
if nItem == 1 
	//Itens em aberto
	cFilter := "13"
elseif nItem == 2
	//Itens Lidos
	if ::nOpc == 1
		cFilter := "0"
	else	
		cFilter := "2"
	endif
elseif nItem == 3
	//Itens Enviados
	cFilter := "4"
endif 

//Carrega a TRB
dbSelectArea("WF6")
WF6->(dbSetOrder(1))
if WF6->(dbSeek(cKey))
	While !WF6->(Eof()) .and. (WF6->WF6_FILIAL + WF6->WF6_PROPRI ) == cKey
		if alltrim(WF6->WF6_PROPRI) $ alltrim(::cUserName) .and. WF6->WF6_STATUS $ cFilter .and. ((::nOpc == 2 .and. WF6_GRUPO == '00002') .or. (::nOpc == 1 .and. WF6_GRUPO == '00001'))
	 		//Grava na TRB
		    RecLock('TRB',.T.)
			TRB->TRB_OK  	:= "  "
			TRB->TRB_DE  	:= alltrim(WF6->WF6_DE)
			TRB->TRB_PARA	:= alltrim(WF6->WF6_PARA)
			TRB->TRB_DATA	:= Iif(ValType(WF6->WF6_DATA) == 'D', DTOC(WF6->WF6_DATA),WF6->WF6_DATA)
			TRB->TRB_HORA	:= WF6->WF6_HORA
			TRB->TRB_DTVENC	:= Iif(ValType(WF6->WF6_DTVENC) == 'D', DTOC(WF6->WF6_DTVENC),WF6->WF6_DTVENC)
			TRB->TRB_HRVENC	:= WF6->WF6_HRVENC
			TRB->TRB_RECWF6	:= WF6->(Recno())
			TRB->(msUnlock())
		endif
		WF6->(dbSkip()) 
	EndDo
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |DestroyTRB								º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |19/01/10   								º
ºDescription: |Apaga fisicamente a area temporaria TRB 	º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method DestroyTRB() class WFTskManDlg
	Iif(Select('TRB')>0,TRB->(dbCloseArea()),Nil)

	//---------------------------------
	//Exclui a tabela temporária. 
	//---------------------------------
	If !( ::oTempTable == Nil )
		::oTempTable:Delete()
	EndIf
Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |ChangeItem								º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |19/01/10   								º
ºDescription: |Executa as acoes ao alterar o item 		º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method ChangeItem() class WFTskManDlg
Processa( {|| ::Refresh()}, STR0039) //"Sincronizando..."
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |Refresh									º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |19/01/10   								º
ºDescription: |Atualiza a MsSelect, conforme o item sel.º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method Refresh() class WFTskManDlg
Local lEncontrou := .F.

if ValType(::oItens) == 'O'
	::oTimer:Deactivate()
	::NewTRB()
	::oMeter:Set(1)
	::LoadTRB(::oList:nAt)
	::oMeter:Set(2)
	dbSelectArea('TRB')	
	TRB->(dbGoTop())
	While TRB->(!Eof())
		if aScan(::aMarked,TRB->TRB_RECWF6) > 0
			RecLock('TRB',.F.)
			TRB->TRB_OK := ::cMarca
			TRB->(msUnlock())
			lEncontrou := .T.
		endif
		TRB->(dbSkip())	
	EndDo
	::oMeter:Set(3)
	
	//Se nao encontrou nenhum, entao o usuario selecionou outro item esquedo.
	//Sendo assim, o Array de marcacoes deve ser limpo	
	::aMarked := iif(!lEncontrou,{},::aMarked)	
	::oItens:oBrowse:GoTop()
	TRB->(dbGoTop()) 
	::oItens:oBrowse:Refresh()	
	
	//Volta a regua apos concluir
	::oMeter:Set(0)
	
    //Reativa o Timer
	::oTimer:Activate()
endif
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |Show()									º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |19/01/10   								º
ºDescription: |Monta e Exibe a Dialog					º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method Show() class WFTskManDlg
Local  bOkBtn 		:= {|| ::ExecuteAction() }
Local  bCancelBtn 	:= {|| ::EndApp()} 

//Monta o Formulario Principal
::oDlg:= MSDIALOG():Create()
::oDlg:cName     		:= "oDlg"
::oDlg:cCaption  		:= iif(::nOpc==1,STR0040,STR0041) + STR0021 //"WorkFlow" ou "Mensagens" - Gerenciador de Tarefas"
::oDlg:nLeft     		:= 0
::oDlg:nTop      		:= 0
::oDlg:nWidth    		:= 750
::oDlg:nHeight   		:= 420
::oDlg:lShowHint 		:= .F.
::oDlg:lCentered 		:= .T.
::oDlg:bInit 			:= {|| EnchoiceBar(::oDlg, {|| ::ExecuteAction() }, bCancelBtn,,::aUserButtons) }

//Monta o ListBox "Itens"
/*TRECHO COMENTADO POIS A PROPRIEDADE BCHANGE NAO ESTA FUNCIONANDO - 20/01/2010 - SIGA3286
  LISTBOX MONTADO ATRAVES DO @ xx,yy no final do bloco	
::oList := TListBox():Create(::oDlg)
::oList:nLeft     		:= 10
::oList:nTop      		:= 40
::oList:nWidth    		:= 110
::oList:nHeight   		:= 180
::oList:aItems		  	:= ::aList
::oList:cVariable		:= "::aList"
::oList:bChange			:= {|| msgInfo('bChange')}
::oList:bLClicked		:= {|| msgInfo('bLeftClicked  ')}
::oList:bRClicked		:= {|| msgInfo('bRightClicked ')}*/
@ 35,5 LISTBOX ::oList VAR ::cList SIZE 55,90 OF ::oDlg ITEMS ::aList ON CHANGE {|| ::ChangeItem()} ON RIGHT CLICK {|| ::ChangeItem()} PIXEL
::oList:GoTop()

//Monta a MsSelect "Itens"
::oItens   	    		:= MsSelect():New("TRB","TRB_OK","",::aCmpBrw,,::cMarca,{ 35, 65, 180, 365 },,,)
::oItens:bAval  		:= { || ::MarkMsg()}
::oItens:oBrowse:Refresh()


//Monta o Botao "Nova Mensagem"
::oBtnNewMsg:= TButton():Create(::oDlg)
::oBtnNewMsg:cName 		:= "oBtnNewMsg"
::oBtnNewMsg:cCaption 	:= STR0042 //"Nova Mensagem"
::oBtnNewMsg:nLeft 		:= 10
::oBtnNewMsg:nTop  		:= 255
::oBtnNewMsg:nWidth    	:= 110
::oBtnNewMsg:nHeight 	:= 25
::oBtnNewMsg:lShowHint 	:= .F.
::oBtnNewMsg:lReadOnly 	:= .F.
::oBtnNewMsg:Align 		:= 0
::oBtnNewMsg:bAction 	:= {|| ::NewMsg() }
::oBtnNewMsg:lActive	:= ::nOpc == 2
::oBtnNewMsg:lVisible	:= ::nOpc == 2

//Monta o Botao "Rastreabilidade"
::oBtnRastro:= TButton():Create(::oDlg)
::oBtnRastro:cName 		:= "oBtnRastro"
::oBtnRastro:cCaption 	:= STR0043 //"Rastreabilidade"
::oBtnRastro:nLeft 		:= 10
::oBtnRastro:nTop  		:= 255
::oBtnRastro:nWidth    	:= 110
::oBtnRastro:nHeight 	:= 25
::oBtnRastro:lShowHint 	:= .F.
::oBtnRastro:lReadOnly 	:= .F.
::oBtnRastro:Align 		:= 0
::oBtnRastro:bAction 	:= {|| ::RastroWork() }
::oBtnRastro:lActive	:= ::nOpc == 1
::oBtnRastro:lVisible	:= ::nOpc == 1

//Monta o Botao "Remover Mensagem"
::oBtnDelMsg:= TButton():Create(::oDlg)
::oBtnDelMsg:cName 		:= "oBtnDelMsg"
::oBtnDelMsg:cCaption 	:= STR0044 //"Remover Item(s)"
::oBtnDelMsg:nLeft 		:= 10
::oBtnDelMsg:nTop  		:= 280
::oBtnDelMsg:nWidth    	:= 110
::oBtnDelMsg:nHeight 	:= 25
::oBtnDelMsg:lShowHint 	:= .F.
::oBtnDelMsg:lReadOnly 	:= .F.
::oBtnDelMsg:Align 		:= 0
::oBtnDelMsg:bAction 	:= {|| ::DeleteMsg() }

//Monta o Botão "Historico"
::oBtnHis := TButton():Create(::oDlg)
::oBtnHis:cName 		:= "oBtnHis"
::oBtnHis:cCaption 		:= STR0045 //"Histórico"
::oBtnHis:nLeft 		:= 10
::oBtnHis:nTop  		:= 310
::oBtnHis:nWidth    	:= 110
::oBtnHis:nHeight 		:= 25
::oBtnHis:lShowHint 	:= .F.
::oBtnHis:lReadOnly 	:= .F.
::oBtnHis:Align 		:= 0
::oBtnHis:bAction 		:= {|| ::HstMsg()}
::oBtnHis:lActive		:= ::nOpc == 2
::oBtnHis:lVisible		:= ::nOpc == 2

//Botao Sair
::oBtnEnd := TButton():Create(::oDlg)
::oBtnEnd:cName 		:= "oBtnEnd"
::oBtnEnd:cCaption 		:= STR0046 //"Sair"
::oBtnEnd:nLeft 		:= 10
::oBtnEnd:nTop  		:= iif(::nOpc==1,310,340)
::oBtnEnd:nWidth    	:= 110
::oBtnEnd:nHeight 		:= 25
::oBtnEnd:lShowHint 	:= .F.
::oBtnEnd:lReadOnly 	:= .F.
::oBtnEnd:Align 		:= 0
::oBtnEnd:bAction 		:= {|| ::EndApp()}

//Cria a regua de processamento.
::oMeter := TMeter():Create(::oDlg)
::oMeter:nLeft 			:= 10
::oMeter:nTop  	   		:= 390
::oMeter:nWidth  	  	:= 720
::oMeter:nHeight 		:= 15
::oMeter:cToolTip		:= STR0047 //"Indicador da sincronização"
::oMeter:SetTotal(3) 

//Monta o Timer
//Atualiza a cada 45 Segundos
::oTimer := TTimer():New(45000, {|| ::Refresh() }, ::oDlg )
::oTimer:Activate()

//Exibe o Dialog Pronto
::oList:nAt := 2
::oList:GoTop()
::oDlg:Activate()
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |SetList()								º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |20/01/10   								º
ºDescription: |Monsta a Lista de Itens (Esquerda)		º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method SetList(aUserList) class WFTskManDlg
Default aUserList := {}

If ValType(aUserList) == "A" .and. Len(aUserList) > 0
	//Lista definida pelo usuario ao instanciar a Classe
	::aList := aClone(aUserList)
else
	//Monta a lista de Acordo com a opcao (WorkFlow ou Mensagens)
	if ::nOpc == 1
		::aList := {STR0048,STR0049,STR0050}  //"Proc. em Aberto","Proc. em Execução","Proc. Respondidos"
	else
		::aList := {STR0051,STR0052,STR0053}  //"Itens Em Aberto","Itens Lidos","Itens Enviados"
	endif
endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |ExecuteAction()							º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |20/01/10   								º
ºDescription: |Executado ao Clicar no Bot OK(Enchoice)	º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method ExecuteAction() class WFTskManDlg
	/*Local bBlock
	Local nRecNo
    
  	if Select('TRB') > 0 .and. TRB->(!Eof()) .and. ::nOpc == 1 //Somente WorkFlow
		if ::oTimer <> nil
			ProcessMessages()
  	   		::oTimer:DeActivate()
	  	End

	  	dbSelectArea( "WF6" )
  		WF6->(dbSetOrder(1))
		WF6->(dbGoTo(TRB->TRB_RECWF6))
	
		BEGIN SEQUENCE
			if FindFunction( "U_WFPEMSG1" )
				U_WFPEMSG1()
			end
			bBlock := &( AllTrim(WF6->WF6_ACAO))
			Eval( bBlock, Self )
			if FindFunction("U_WFPEMSG2")
				U_WFPEMSG2()
			end
		END SEQUENCE

		::Refresh()
		
		if ::oTimer <> NIL
			::oTimer:Activate()
			ProcessMessages()
		endif
	endif */
	::EndApp()
return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |DeleteMsg()								º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |20/01/10   								º
ºDescription: |Exclui os itens marcados com X			º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method DeleteMsg() class WFTskManDlg

if Select('TRB') > 0

    ::oTimer:Deactivate()
	
	//Exclui o(s) iten(s) Marcado(s)	 
	if Len(::aMarked) <= 0
		msgStop(STR0054) 		//'Não existem itens marcados para exclusão.'
	Elseif MsgYesNo(STR0055) 	//'Confirma a exclusão do(s) item(ns) selecionado(s) ? '
		TRB->(dbGoTop())
		While TRB->(!Eof())
			if !Empty(TRB->TRB_OK)
			 	dbSelectArea('WF6')
			 	WF6->(dbSetOrder(1))
			 	WF6->(dbGoTo(TRB->TRB_RECWF6))      
			 	
			 	//Verifica se foi posicionado corretamente.
			 	If WF6->(Recno()) == TRB->TRB_RECWF6
					RecLock('WF6',.F.)
					WF6->(dbDelete())
					WF6->(msUnlock())
			 	endif
			Endif
			TRB->(dbSkip())
		EndDo	
	Endif
	::Refresh()	
	::oTimer:Activate()
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |NewMsg()									º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |20/01/10   								º
ºDescription: |Cria uma nova Mensagem					º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method NewMsg() class WFTskManDlg
Local oNewMsg	:= Nil

::oTimer:Deactivate()
oNewMsg   := TWFTaskMsg():New(Self)
oNewMsg:NewMsgDlg()
::Refresh()
::oTimer:Activate()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |HstMsg()									º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |20/01/10   								º
ºDescription: |Exibe o Historico de Mensagens			º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method HstMsg() class WFTskManDlg
Local oHstMsg

if ::oList:nAt > 0
	::oTimer:Deactivate()
	::nRecnoWF6 := TRB->TRB_RECWF6
	oHstMsg:= TWFTaskMsg():New(Self)
	oHstMsg:HistoryDlg()
	::oTimer:Activate()
else
	msgInfo(STR0056) //"É necessário selecionar um item para exibir o histórico."
endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |OpenMsg()								º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |21/01/10   								º
ºDescription: |Abre a mensagem selecionada				º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method OpenMsg() class WFTskManDlg
Local oOpnMsg 	:= Nil
Local cFileText := ""

if TRB->TRB_RECWF6 > 0
	::oTimer:Deactivate()
	::nRecnoWF6 := TRB->TRB_RECWF6
	oOpnMsg:= TWFTaskMsg():New(Self)
	cFileText := oOpnMsg:GetFileText(::nRecnoWF6)
	oOpnMsg:OpenMsgDlg(cFileText)
	::oTimer:Activate()
endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |SetOpc()									º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |20/01/10   								º
ºDescription: |Seta a variavel nOpc (WorfKlow ou Mensag.º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method SetOpc(nOption) class WFTskManDlg
//nOption == 1 -> WorkFlow
//nOption == 2 -> Mensagens

if ValType(nOption) == "N"
	::nOpc := nOption
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |MarkMsg()								º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |20/01/10   								º
ºDescription: |Marca/Desmarca uma Mensagem.				º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method MarkMsg() class WFTskManDlg
Local nPos 		:= 0
Local oBrowser  := Nil
Local cHtml 	:= ""

if ::oItens:oBrowse:ColPos == 1
	RecLock('TRB',.F.)
	if Empty(TRB->TRB_OK)
		TRB->TRB_OK := ::cMarca
		aAdd(::aMarked,TRB->TRB_RECWF6)
	else
		TRB->TRB_OK := "  "
		nPos := aScan(::aMarked,TRB->TRB_RECWF6)
		::aMarked := aDel(::aMarked,nPos)
		::aMarked := aSize(::aMarked,Len(::aMarked)-1)
		TRB->(msUnlock())
	endif
else
	if ::nOpc == 1
	 	::nRecnoWF6 := TRB->TRB_RECWF6
	 	dbSelectArea('WF6')
	 	WF6->(dbSetOrder(1))
	 	WF6->(dbGoTo(::nRecnoWF6))
	 	cHtml := ::HtmlFile(WF6->WF6_ACAO)
	 	oBrowser := TWFTaskWF():New(Self)
	 	oBrowser:IBrowser(cHtml)
	elseif ::nOpc == 2
		::OpenMsg()	     	
	endif
endif

::oItens:oBrowse:Refresh()
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |HtmlFile()								º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |21/01/10   								º
ºDescription: |Retorna o nome do arquivo html contido emº
º             |WF6_ACAO                                 º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method HtmlFile(cAcao) Class WFTskManDlg
Local cFile := 'web/'
Local nI	:= 0

For nI := 0 to Len(cAcao)
	//Localiza a primeira aspas dupla
	if substr(cAcao,nI,1) == '"'
		nI++
		While substr(cAcao,nI,1) != '"'
			cFile += substr(cAcao,nI,1)
			nI++		
		EndDo
	endif
Next nI

Return cFile

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |RastroWork()								º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |21/01/10   								º
ºDescription: |Exibe o rastro do item de workflow selec.º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method RastroWork() class WFTskManDlg
Local oRastro := TWFTaskWF():New(Self) 

::nRecnoWF6 := TRB->TRB_RECWF6
::oTimer:Deactivate()
CursorWait()
oRastro:Rastreability()
CursorArrow()
::oTimer:Activate()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |EndApp()									º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |20/01/10   								º
ºDescription: |Finaliza a Aplicação (End Thread)		º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Method EndApp() class WFTskManDlg
::oDlg:End()
::DestroyTRB()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |AddButton()								º
ºAuthor:      |Cesar A. Bianchi							º
ºDate:        |21/01/10   								º
ºDescription: |Metodo para adicionar botoes de usuario 	º
º			  |na EnchoiceBar           				º
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
method AddButton( cCaption, bAction ) class WFTskManDlg
	default cCaption := STR0011 + AllTrim( Str( Len( ::aUserButtons ) ) ), bAction := { |o| .t. } //"Botao"
	AAdd( ::aUserButtons, { cCaption, bAction } )
return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ºMethod:      |AddFolder()								º
ºAuthor:      |Desconhecido								º
ºDate:        |XX/XX/XXXX  								º
ºDescription: |Utilizado pela Classe WfTskMsg NAO REMOVAº
ºAplication:  |MP10 - Messenger							º
ºÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
method AddFolder( cFolder, bBlock, cResource ) class WFTskManDlg
	default cFolder := STR0010 + AllTrim( Str( Len( ::aFolders ) ) )
	AAdd( ::aFolders, { cFolder, bBlock, cResource, LoadBitmap( GetResource(), cResource ), {} } )
return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Sx3Get    ºAutor  ³Cesar Bianchi       º Data ³  30/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna uma propriedade do SX3 de acordo com o parametro    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³WorkFlow                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Sx3Get(cField,nOpc)
Local xRet  	:= ""
Local aArea 	:= getArea()

dbSelectArea('SX3')
SX3->(dbSetOrder(2))
If SX3->(dbSeek(cField))
	Do Case
		Case nOpc == 1
			//Tamanho do campo
			xRet := SX3->X3_TAMANHO
		Case nOpc == 2
			//Decimanl do campo
			xRet := SX3->X3_DECIMAL
		Case nOpc == 3
			//Tipo do Campo
			xRet := SX3->X3_TIPO
		Case nOpc == 4
			//Titulo do Campo			
			If __Language == 'SPANISH'
				xRet := SX3->X3_TITSPA
			Else
				If __Language == 'ENGLISH'
					xRet := SX3->X3_TITENG
				Else
					xRet :=	SX3->X3_TITULO
				EndIf
			EndIf
		Case nOpc == 5
			//Descricao do Campo

			IF __Language == 'SPANISH'
				xRet := SX3->X3_DESCSPA
			Else
				IF __Language == 'ENGLISH'
					xRet := SX3->X3_DESCENG
				Else
					xRet := SX3->X3_DESCRIC
				EndIf
			EndIf
		Case nOpc == 6
			//Picture
			if empty(SX3->X3_PICTURE)
				xRet := "@!"
			else
				xRet := alltrim(SX3->X3_PICTURE)
			endif
	End Case
endif
		
RestArea(aArea)
Return xRet  
