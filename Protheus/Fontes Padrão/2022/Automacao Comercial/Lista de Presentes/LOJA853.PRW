#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA853.CH"
#DEFINE CRLF CHR(13)+CHR(10)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA853   บAutor  ณMicrosiga           บ Data ณ  07/26/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela para selecao de itens das sugestoes de lista para      บฑฑ
ฑฑบ          ณa tela de criacao de lista de eventos                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณLOJA853(Exp01)                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaResult[A] : Array com os itens selecionados na tela        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณExp01[C] : Codigo do tipo do evento                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA843.PRW                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function LOJA853(cCodEve)

Local nB        := 0												// Variavel utilizada como contador em loop utilizando For
Local nC        := 0												// Variavel utilizada como contador em loop utilizando For
Local oDlgSel														// Objeto da caixa de dialogo (tela)
Local oLbxSel														// Objeto do grid com as informacoes sobre as sugestoes de listas
Local oTit1															// Objeto para o texto facilitadores na tela
Local oListBx1														// Objeto do grid com as informacoes sobre os itens da sugestao selecionada
Local oCheck    := LoadBitMap(GetResources(),"LBOK"			)		// Objeto com a imagem de quando o item da lista foi selecionado
Local oNoCheck  := LoadBitMap(GetResources(),"LBNO"			)		// Objeto com a imagem de quando o item da lista foi desmarcado
Local oCan	  := LoadBitMap(GetResources(),"BR_VERDE"		)		// Objeto com a imagem de quando o item da lista esta OK - produto desbloquado
Local oNoCan	  := LoadBitMap(GetResources(),"BR_VERMELHO"	)	// Objeto com a imagem de quando o item da lista esta OK - produto bloquado
Local nOpcx     := 0												// Variavel para controle da opcao escolhida ao sair da tela - botao OK = 1
Local nValLista := 0												// Contem o somatorio do valor de todos os itens uma determinada lista
Local aSugest   := {}                        						// Lista com os dados necessarios para popular o grid das sugestoes
Local aResult   := {}												// Array com os itens selecionados e que e retornado para a funcao chamadora
Local aButton   := {}												// Array com os botoes da enchoice bar que podem ser acrescentados
Local aEstrut   := {}												// Recebe o retorno da funcao LJ853STRU com os dados das sugestoes do tipo de lista selecionado
Local lClick    := .F.												// Variavel utilizada para controle da selecao dos itens nos grids da tela
Local cTit1     := STR0001 //"Facilitadores"							// Texto a ser apresentado na tela
Local nX		:= 0
Local nY		:= 0
Default cCodEve   := ""

Aadd(aButton,{"RELATORIO",{||LJ853Print(@aSugest)},STR0002,STR0002})       //"Imprimir" # "Imprimir"

DbSelectArea("ME7")
ME7->(DbSetOrder(2))
If Empty(cCodEve)
	ME7->(DbGoTop())
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerificar se existe sugestใo de lista para o tipo de evento passado no parametroณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !ME7->(DbSeek(xFilial("ME7")+cCodEve))
		Alert(STR0019)   //// "Nใo existem Sugest๕es para este tipo de Evento!"
		Return(aResult)
	Endif
Endif



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVarrer a tabela ME7 em busca de todas as sugestoes de lista do tipo de evento enviado no parametroณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While ME7->(!Eof())
	
	If !Empty(cCodEve) .AND. ME7->(ME7_FILIAL+ME7_TIPLIS) <> xFilial("ME7")+cCodEve
		Exit
	Endif
    
    If ME7->ME7_STATUS == "1"
		aEstrut := LJ853STRU(ME7->ME7_CODIGO)
		If LEN(aEstrut) > 0
			aAdd(aSugest,aEstrut)
			aEstrut := {}
		Endif
	Endif
		
	ME7->(DbSkip())
End                                       			

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso nao tenha encontrado nenhuma sugestao o array e preenchido com valores default .ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aSugest) == 0
	aAdd(aEstrut,{"","","","","",STR0015,{},.F.,0})
	aAdd(aEstrut[1,7],{.F.,.F.,"","","","","","",0,0}) 
	aAdd(aSugest,aEstrut)

ElseIf Len(aSugest) > 0 //Caso nใo haja nenhum produto na ME8, insere valores default
	For nX:= 1 to Len(aSugest)
		If Len(aSugest[nX]) > 0
			For nY := 1 to Len(aSugest[nX])
				If Len(aSugest[nX][nY][7]) == 0
					Aadd(aSugest[nX][nY][7] , {.F.,.F.,"","","","","","",0,0} )
				EndIf
			Next nY
		EndIf
	Next nX
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriar a caixa de dialogo (tela)ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oDlgSel := TDialog():New(001,001,480,1000,OemToAnsi(STR0003),,,,,,,,oMainWnd,.T.) //"Sugestao de Lista"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta 2o listbox na tela ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oLBxSel := TwBrowse():New(015,005,490,58,,{"",STR0004,STR0005,STR0006,STR0007,STR0013,STR0008},,oDlgSel,,,,,,,,,,,,.T.,,.T.,,.F.,,,) //Sugestao#Descricao#Tipo Evento#Evento#Status

oLBxSel:SetArray(aSugest)

oLBxSel:bLine:={||{Iif(	aSugest[oLBxSel:nAt,1,8],oCheck,oNoCheck)	,;
						aSugest[oLBxSel:nAt,1,2]					,;
						aSugest[oLBxSel:nAt,1,3]					,;
						aSugest[oLBxSel:nAt,1,4]					,;
						aSugest[oLBxSel:nAt,1,5]					,;
						Transform(aSugest[oLBxSel:nAt,1,9],"@E 999,999,999.99"),;
						aSugest[oLBxSel:nAt,1,6]					}}

oLBxSel:bChange:={||	oListBx1:SetArray(aSugest[oLBxSel:nAt,1,7])                                           					,;
						oListBx1:bLine := {||{	Iif(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,1],oCheck,oNoCheck)  					,;
												Iif(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,2],oCan  ,oNoCan  )  					,;
													aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,7]					   				,;
													aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,8]									,;
													aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,10]									,;
													Transform(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,9],"@E 999,999,999.99")}}	,;
						oListBx1:Refresh()													   			  						}						

oLBxSel:BlDblClick := {||	lClick:=!aSugest[oLBxSel:nAt,1,8] 		,;
							aSugest[oLBxSel:nAt,1,8]:=lClick   		,;
							nValLista := 0					   		,;
							aEval(aSugest[oLBxSel:nAt,1,7],{|xMark| Iif(xMark[2],(xMark[1]:=lClick, nValLista += Iif(lClick,xMark[9],0)),xMark[1]:=.F.)}),;
							aSugest[oLBxSel:nAt,1,9] := nValLista	,;
							oListBx1:Refresh()}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta 2o listbox na tela ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ 075, 005 Say oTit1 Var cTit1 Size 140, 010 Pixel Of oDlgSel // Font oFntVlr
oListBx1 := TwBrowse():New(085,005,490,150,,{"","",STR0011,STR0012,STR0020,STR0013},,oDlgSel,,,,,,,,,,,,.T.,,.T.,,.F.,,,) //Produto#Descricao Produto#Quantidade#Preco

oListBx1:SetArray(aSugest[oLBxSel:nAt,1,7])

oListBx1:bLine := {|| {	Iif(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,1],oCheck,oNoCheck)  				,;
						Iif(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,2],oCan  ,oNoCan  )  				,;
							aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,7]				   				,;
							aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,8]								,;
							aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,10]								,;							
							Transform(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,9],"@E 999,999,999.99")	}}	

oListBx1:BlDblClick := {||	lClick:=!aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,1]	 							,;
							Iif	(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,2]		 							,;
								(aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,1]:= lClick	   						,;
							Iif	(lClick,aSugest[oLBxSel:nAt,1,9]+=aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,9]	,;
								aSugest[oLBxSel:nAt,1,9]-=aSugest[oLBxSel:nAt,1,7,oListBx1:nAt,9])),.T.)	,;
							oLBxSel:Refresh()}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtivar a caixa de dialogoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Activate MsDialog oDlgSel Center On Init EnchoiceBar(oDlgSel, {||(oDlgSel:End(),nOpcx:=1)}, {|| (oDlgSel:End(),nOpca := 0)},,aButton)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe for clicado no botao ok da enchoicebar e houver registrosณ
//ณselecionados nos grids de produtos estes serao carregado no ณ
//ณarray aSugest que e o retorno da funcao.                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpcx == 1
	For nB := 1 To LEN(aSugest)
		If aSugest[nB,1,8]
			For nC := 1 To LEN(aSugest[nB,1,7])
				If aSugest[nB,1,7,nC,1]
					aAdd(aResult,{	aSugest[nB,1,7,nC,3],;  // [01] Facilitador
									aSugest[nB,1,7,nC,4],;  // [02] Descricao do facilitador
									aSugest[nB,1,7,nC,5],;  // [03] Grupo da lista
									aSugest[nB,1,7,nC,6],;  // [04] Descricao do grupo da lista
									aSugest[nB,1,7,nC,7],;  // [05] Codigo do produto
									aSugest[nB,1,7,nC,8],;  // [06] Descricao do produto
									aSugest[nB,1,7,nC,9],;  // [07] Preco
									aSugest[nB,1,7,nC,10]}) // [08] Quantidade
				Endif			
			Next nC			
		Endif
	Next nB	
Endif

Return(aResult)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJ853STRU บAutor  ณMicrosiga           บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o array com a sugestao do codigo passao no paramentro บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณLJ853STRU(Exp01)                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaRetorno[A] : Array com as sugestoes e seus respectivo pro- บฑฑ
ฑฑบ          ณdutos                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณExp01[C] : codigo da tabela de sugestao                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA853.PRW                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LJ853STRU(cCodTab)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclara variaveis ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aArea    := ME7->(GetArea())		// Guardar a area antes de manipula-la para depois restaura-lo ao estado original
Local aRetorno := {}					// Array de retorno da funcao com os dados da sugestao e seus itens consultados
Local nPosTab  := 0						// Variavel utilizada para identificao do numero da linha no array aRetorno para
										// inclusao dos itens da sugestao na linha correta
Local nPrcLis  := 0						// Valor do item
Default cCodTab  := ""					

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso nao seja informada a tabela na variavel cCodTab ณ
//ณo componente retornara todas as sugestoes existentes ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("ME7")
ME7->(DbSetOrder(1))
If Empty(cCodTab)
	ME7->(DbGoTop())
Else
	ME7->(DbSeek(xFilial("ME7")+cCodTab))
Endif

While ME7->(!Eof())
	
	If !Empty(cCodTab) .AND. ME7->(ME7_FILIAL+ME7_CODIGO) <> xFilial("ME7")+cCodTab
		Exit
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta a estrutura de arvore das sugestoes ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("ME8")
	ME8->(DbSetOrder(1))
	ME8->(DbSeek(xfilial("ME8")+ME7->ME7_CODIGO))
	While ME8->(!Eof()) .AND. ME8->(ME8_FILIAL+ME8_CODIGO) == xFilial("ME8")+ME7->ME7_CODIGO
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAgrupa por tabela ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nPosTab := aScan(aRetorno,{|x| x[1]+x[2] == ME7->ME7_FILIAL+ME7->ME7_CODIGO})
		If nPosTab == 0
			aAdd(aRetorno,{	ME7->ME7_FILIAL								,; //01
							ME7->ME7_CODIGO								,; //02
							ME7->ME7_DESCRI								,; //03
							ME7->ME7_TIPLIS								,; //04
							ME7->ME7_DESCTP								,; //05
							Iif(ME7->ME7_STATUS=="1",STR0014,STR0015)	,; //06
							{}											,; //07
							.F.											,; //08
							0											}) //09
			nPosTab := LEN(aRetorno)
		Endif
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCria lista dos produtos da sugestao em questaoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If SB1->(DbSeek(xFilial("SB1")+ME8->ME8_CODPRO))

			nPrcLis := Lj843PrcV(ME8->ME8_CODPRO)
			
			//Quando alterar este retorno, alterar a variแvel aSugest da fun็ใo Loja853							
			aAdd(aRetorno[nPosTab,7],{	.F.                     	   	,; //01
										SB1->B1_MSBLQL<>"1" 			,; //02
										ME8->ME8_FACIL				   	,; //03
										ME8->ME8_DESFAC				   	,; //04
		   								ME8->ME8_GRPLIS					,; //05
		   								ME8->ME8_DESGRP					,; //06
										SB1->B1_COD						,; //07
										SB1->B1_DESC					,; //08
										nPrcLis							,; //09
										ME8->ME8_QTDADE                 }) //10
		EndIf
		
		ME8->(DbSkip())
	End
	
	ME7->(DbSkip())
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFim da estrutura de arvore ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea(aArea)	
Return aRetorno
                      
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJ853PrintบAutor  ณMicrosiga           บ Data ณ  07/26/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChama o relatorio de sugestao de lista                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณLJ853Print(Exp01)                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNao tem                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณExp01[A] : Array com os itens as sugestoes para o relatorio บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA853.PRW                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function LJ853Print(aSugest)

Local cRelSug := GetMv("MV_RELSUG",,"LJ853HLP")	// Rotina para execucao do relatorio de sugestao

ExecBlock(cRelSug,.F.,.F.,aSugest)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJ853HLP  บAutor  ณMicrosiga           บ Data ณ  07/26/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao chamada quando o parametro MV_RELSUG nao esta preen- บฑฑ
ฑฑบ          ณchido                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณLJ853HLP()		                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNao tem                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณNao tem                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLOJA853.PRW                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function LJ853HLP()

Aviso("LOJA853",STR0016,{STR0017},1,STR0018)

Return()