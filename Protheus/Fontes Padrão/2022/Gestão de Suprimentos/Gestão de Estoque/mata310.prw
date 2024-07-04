#INCLUDE "MATA310.ch" //
#INCLUDE "PROTHEUS.CH"
#INCLUDE "dbtree.ch"

#DEFINE OP_EFE	"011" // Efetivar

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MATA310    ³ Autor ³Rodrigo de A Sartorio³ Data ³27/10/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Transferencia de saldos entre filiais                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MATA310()
Local aSize     := MsAdvSize(.T.)
Local oDlg,oTree1,oTree2,oSayOrig01,oSayOrig02,oSayOrig03,oSayOrig04,oSayDest01,oSayDest02,oSayDest03,oSayDest04,aObjects:={},aInfo:={},aPosObj:={},aButtons:={}
Local aDadosOri :={}
Local aDadosDest:={}
// Variavel que indica qual o tree em uso
Local nQualTree :=1
Local ni        :=0
// Picture das informacoes de quantidade
Local cPictQtd  :=PesqPict("SB2","B2_QATU",20)
// Fonte grande para informacao do tree
Local oFontGrande
// Array com dados das filiais
Local aFiliais   :={}
Local aAreaSM0   :=SM0->(GetArea())
// Array com os parametros do programa
Local aParam310  :=Array(30)
// Array com as categorias selecionadas pelo usuario
Local aCategorias:={},aBackcateg:={}
// Variavel com a filial origem
Local cFilOri    := cFilAnt
// Variaveis utilizadas na selecao de categorias
Local oChkQual,lQual,oQual,cVarQ
// Carrega bitmaps
Local oOk        := LoadBitmap( GetResources(), "LBOK")
Local oNo        := LoadBitmap( GetResources(), "LBNO")
// Verificacao de categoria
Local nAchoCateg := 0
Local lRet       :=.T.
Local cCompTit   := ''
Local aBotoes    :={}
Local lCntWEB	 :=.T. //iniciado com .t. devido customizações que não usam a função A310RELAC
Local lCont		 :=.T.

// Variavel utilizada para tratamento especifico para poder de terceiros
Private l310PODER3:= .F.
Private cC6_ITEM  := ""
Private cC6_ITGR  := ""
Private aDescSeek  := {}
// Array com os dados para as transferencias
Private aDadosTransf:={}
Private lNSelSerie	:= .F. 
Private lTesIntEnt   := .F.
Private lTesIntSai   := .F.
Private aLstProd  :={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                               ³
//³ mv_par01        // De  Produto                                     ³
//³ mv_par02        // Ate Produto                                     ³
//³ mv_par03        // De  filial                                      ³
//³ mv_par04        // Ate filial                                      ³
//³ mv_par05        // De  Armazem                                     ³
//³ mv_par06        // Ate Armazem                                     ³
//³ mv_par07        // De  Tipo                                        ³
//³ mv_par08        // Ate Tipo                                        ³
//³ mv_par09        // De  Grupo                                       ³
//³ mv_par10        // Ate Grupo                                       ³
//³ mv_par11        // Filtra Categorias  1 Sim  2 Nao                 ³
//³ mv_par12        // Quebra informacoes 1 Por produto 2 Por Armazem  ³
//³ mv_par13        // Codigo da TES utilizada nas NFs de saida        ³
//³ mv_par14        // Indica como deve gerar o documento              ³
//³ mv_par15        // Codigo da TES utilizada nas NFs de entrada      ³
//³ mv_par16        // Codigo da condicao de pagamento                 ³
//³ mv_par17        // Sugere preco 1 Tab 2 Custo STD 3 Ult Pr 4 CM    ³
//³ mv_par18        // Dados origem - somente filial corrente / todas  ³
//³ mv_par19        // Utilizar Saldo de Terceiros ? 1=Sim / 2 = Nao   ³
//³ mv_par21        // Descricao de Produtos?                          ³
//³ mv_par22        // TP Oper. Saida?                                 ³
//³ mv_par23        // TP Oper. Entrada?                               ³
//³ mv_par24        // Informa produtos manualmente?                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Pergunte("MTA310",.T.) 
	While !A310VldOp()
		lCont:= Pergunte("MTA310",.T.) 
		If !lCont
			Exit 
		EndIf
	Enddo
	If lCont
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega parametros do programa                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For ni := 1 to 30
			aParam310[ni] := &("mv_par"+StrZero(ni,2))
		Next ni
		
		lTesIntSai := !Empty(aParam310[22])
		lTesIntEnt := !Empty(aParam310[23])

		If aParam310[24] == 1
			a310SelPro ()
			If len(aLstProd) == 0 .Or. (len(aLstProd) == 1 .And. empty(aLstProd[1,1]+aLstProd[1,2]))
				aParam310[24] := 2
				lRet:=.F.
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Complemento do Titulo                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SB2->(FieldPos("B2_TIPO")) > 0 .And. aParam310[19] == 1
			l310PODER3 := .T.
			cCompTit   := STR0066 //" ( Saldo de Terceiros ) "
		EndIf
		
		If aParam310[17] == 5 .and. !IsFifoOnLine()
			alert (STR0098) //'Custo FIFO Selecionado no preço do PV porem o Sistema não usa custo fifo. Verifique os parametros MV_CUSFIFO, MV_FFONLIN.')
			lRet:= .F.
		EndIf

		If lRet
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega filiais da empresa corrente                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SM0")
			dbSeek(cEmpAnt)
			Do While ! Eof() .And. SM0->M0_CODIGO == cEmpAnt   
				// Adiciona filial		
				If FWGETCODFILIAL  >= aParam310[03] .And. FWGETCODFILIAL <= aParam310[04]
					Aadd(aFiliais,{FWGETCODFILIAL,SM0->M0_CODIGO,SM0->M0_CGC,SM0->M0_INSC,SM0->M0_FILIAL})
				EndIf
				dbSkip()
			Enddo
			RestArea(aAreaSM0)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta a  tela com o tree da origem e com o tree do destino    ³
			//³resultado da comparacao.                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd( aObjects, { 100, 100, .T., .T., .F. } )
			aAdd( aObjects, { 100, 100, .T., .T., .F. } )
			aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
			aPosObj:= MsObjSize( aInfo, aObjects, .T.,.T. )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inclui botoes na enchoicebar                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AADD(aButtons,{"bmpvisual"	,{|| A310ShPrd(If(nQualTree==1,@oTree1,@oTree2),aParam310[12]) },STR0001,STR0002}) //"Dados do Produto"###"Produto"
			AADD(aButtons,{"NOTE"	    ,{|| A310Relac(@oTree1,@oTree2,aParam310[12],aDadosOri,aDadosDest,@aDadosTransf,cPictQtd,aFiliais,aParam310,@lCntWEB) },STR0003,STR0004}) //"Relaciona origem / destino"###"Relacao"
			AADD(aButtons,{"EXCLUIR"	,{|| A310EstRel(@oTree1,@oTree2,aParam310[12],aDadosOri,aDadosDest,aDadosTransf,cPictQtd,aFiliais,aParam310) },STR0043,STR0044}) //"Estorna Relac."###"Estorno"
			AADD(aButtons,{"PRTETQ"		,{|| A310Lista(aDadosTransf,cPictQtd) },STR0005,STR0006}) //"Itens da transferencia"###"Itens"
			AAdd(aButtons,{"LOCALIZA"	,{|| A310Pesq(@oTree1,@oTree2,aParam310[12]) }, STR0050 } )  //"Pesquisar"
			AAdd(aButtons,{"UPDWARNING"	,{|| Mt310Inf() }, STR0007 } )  //"Legenda"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para inserir botoes na enchoicebar da Rotina ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("M310BUT")
				aBotoes := ExecBlock("M310BUT",.F.,.F.,{aButtons})
				If ValType(aBotoes) == "A"
					aButtons:=aBotoes
				EndIf
			EndIf		
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta interface para selecao das categorias                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aParam310[11] == 1
				// Arquivo compartilhado
				If Empty(xFilial("ACV"))
					dbSelectarea("ACV")
					dbSetOrder(1)
					dbSeek(xFilial("ACV"))
					While !Eof() .And. ACV_FILIAL == xFilial("ACV")
						nAchoCateg:=Ascan(aCategorias,{|x| x[1] == .T. .And. x[2] == xFilial("ACV") .And. x[3] == ACV->ACV_CATEGO })
						If nAchoCateg <= 0
							AADD(aCategorias,{.T.,xFilial("ACV"),ACV->ACV_CATEGO,Posicione("ACU",1,xFilial("ACU")+ACV->ACV_CATEGO,"ACU_DESC")})
						EndIf
						dbSelectarea("ACV")
						dbSkip()
					End
				Else
					// Varre todas as filiais
					For ni:=1 to Len(aFiliais)
						// Altera filial de acordo com lista de filiais
						cFilAnt:=aFiliais[ni,1]
						dbSelectarea("ACV")
						dbSetOrder(1)
						dbSeek(xFilial("ACV"))
						While !Eof() .And. ACV_FILIAL == xFilial("ACV")
							nAchoCateg:=Ascan(aCategorias,{|x| x[1] == .T. .And. x[2] == xFilial("ACV") .And. x[3] == ACV->ACV_CATEGO })
							If nAchoCateg <= 0
								AADD(aCategorias,{.T.,xFilial("ACV"),ACV->ACV_CATEGO,Posicione("ACU",1,xFilial("ACU")+ACV->ACV_CATEGO,"ACU_DESC")})
							EndIf
							dbSelectarea("ACV")
							dbSkip()
						End
					Next ni
					// Restaura filial original
					cFilAnt:=cFilOri
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seleciona as categorias atraves de listbox                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aCategorias) > 0
					aBackCateg:=ACLONE(aCategorias)
					DEFINE MSDIALOG oDlg TITLE STR0008 From 145,0 To 445,628 OF oMainWnd PIXEL //"Selecao de categorias"
					@ 05,15 TO 125,300 LABEL STR0009 OF oDlg  PIXEL  //"Marque as categorias a serem consideradas"
					@ 15,20 CHECKBOX oChkQual VAR lQual PROMPT STR0010 SIZE 50, 10 OF oDlg PIXEL ON CLICK (AEval(aCategorias , {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.))  //"Inverte selecao"
					@ 30,20 LISTBOX oQual VAR cVarQ Fields HEADER "",STR0011,STR0012,STR0013 SIZE 273,090 ON DBLCLICK (aCategorias:=CA310Troca(oQual:nAt,aCategorias),oQual:Refresh()) NoScroll OF oDlg PIXEL //"Filial"###"Categoria"###"Descricao"
					oQual:SetArray(aCategorias)
					oQual:bLine := { || {If(aCategorias[oQual:nAt,1],oOk,oNo),aCategorias[oQual:nAt,2],aCategorias[oQual:nAt,3],aCategorias[oQual:nAt,4]}}
					DEFINE SBUTTON FROM 134,240 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
					DEFINE SBUTTON FROM 134,270 TYPE 2 ACTION (aCategorias:=ACLONE(aBackCateg),oDlg:End()) ENABLE OF oDlg
					ACTIVATE MSDIALOG oDlg CENTERED
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta os conteudos dos dois objetos tree                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0014)+" "+cCompTit FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL  //"Transferencia de produtos entre filiais"
			// Define fonte grande
			DEFINE FONT oFontGrande NAME "Courier New" SIZE 9,14
			// Cria molduras
			@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL OemToAnsi(STR0015)  OF oDlg PIXEL //"Origem"
			@ aPosObj[2,1],aPosObj[2,2] TO aPosObj[2,3],aPosObj[2,4] LABEL OemToAnsi(STR0016) OF oDlg PIXEL  //"Destino"
			// Cria textos
			@ aPosObj[1,1]+08,aPosObj[1,2]+5 SAY oSayOrig01 VAR STR0017 SIZE aPosObj[1,4]-aPosObj[1,2],30 OF oDlg PIXEL 	//"Existem campos com decimais divergentes, poderao ocorrer diferencas de arredondamento" //"Dados da filial/armazem/produto origem."
			oSayOrig01:SetColor(CLR_HRED,GetSysColor(15))
			oSayOrig01:oFont:=oFontGrande
			@ aPosObj[1,1]+16,aPosObj[1,2]+5 SAY oSayOrig02 VAR "" SIZE aPosObj[1,4]-aPosObj[1,2],30 OF oDlg PIXEL 	//"Existem campos com decimais divergentes, poderao ocorrer diferencas de arredondamento" //"Dados da filial/armazem/produto origem."
			oSayOrig02:SetColor(CLR_HRED,GetSysColor(15))
			oSayOrig02:oFont:=oFontGrande
			@ aPosObj[1,1]+24,aPosObj[1,2]+5 SAY oSayOrig03 VAR "" SIZE aPosObj[1,4]-aPosObj[1,2],30 OF oDlg PIXEL 	//"Existem campos com decimais divergentes, poderao ocorrer diferencas de arredondamento" //"Dados da filial/armazem/produto origem."
			oSayOrig03:SetColor(CLR_HRED,GetSysColor(15))
			oSayOrig03:oFont:=oFontGrande
			@ aPosObj[1,1]+32,aPosObj[1,2]+5 SAY oSayOrig04 VAR "" SIZE aPosObj[1,4]-aPosObj[1,2],30 OF oDlg PIXEL 	//"Existem campos com decimais divergentes, poderao ocorrer diferencas de arredondamento" //"Dados da filial/armazem/produto origem."
			oSayOrig04:SetColor(CLR_HRED,GetSysColor(15))
			oSayOrig04:oFont:=oFontGrande
			@ aPosObj[2,1]+08,aPosObj[2,2]+5 SAY oSayDest01 VAR STR0018 SIZE aPosObj[2,4]-aPosObj[2,2],30 OF oDlg PIXEL 	//"Existem campos com decimais divergentes, poderao ocorrer diferencas de arredondamento" //"Dados da filial/armazem destino."
			oSayDest01:SetColor(CLR_HRED,GetSysColor(15))
			oSayDest01:oFont:=oFontGrande
			@ aPosObj[2,1]+16,aPosObj[2,2]+5 SAY oSayDest02 VAR "" SIZE aPosObj[2,4]-aPosObj[2,2],30 OF oDlg PIXEL 	//"Existem campos com decimais divergentes, poderao ocorrer diferencas de arredondamento" //"Dados da filial/armazem destino."
			oSayDest02:SetColor(CLR_HRED,GetSysColor(15))
			oSayDest02:oFont:=oFontGrande
			@ aPosObj[2,1]+24,aPosObj[2,2]+5 SAY oSayDest03 VAR "" SIZE aPosObj[2,4]-aPosObj[2,2],30 OF oDlg PIXEL 	//"Existem campos com decimais divergentes, poderao ocorrer diferencas de arredondamento" //"Dados da filial/armazem destino."
			oSayDest03:SetColor(CLR_HRED,GetSysColor(15))
			oSayDest03:oFont:=oFontGrande
			@ aPosObj[2,1]+32,aPosObj[2,2]+5 SAY oSayDest04 VAR "" SIZE aPosObj[2,4]-aPosObj[2,2],30 OF oDlg PIXEL 	//"Existem campos com decimais divergentes, poderao ocorrer diferencas de arredondamento" //"Dados da filial/armazem destino."
			oSayDest04:SetColor(CLR_HRED,GetSysColor(15))
			oSayDest04:oFont:=oFontGrande
			// Cria trees
			oTree1:= dbTree():New(aPosObj[1,1]+42, aPosObj[1,2],aPosObj[1,3]+5,aPosObj[1,4], oDlg,,,.T.)
			oTree1:lShowHint := .F.
			oTree2:=dbTree():New(aPosObj[2,1]+42, aPosObj[2,2],aPosObj[2,3]+5,aPosObj[2,4], oDlg,,,.T.)
			oTree1:lShowHint := .F.
			// Insere conteudo nos trees
			A310TreeCM(oTree1,oTree2,aParam310[12],aDadosOri,aDadosDest,cPictQtd,aFiliais,aParam310,aCategorias)
			// Evento para qdo ganha foco
			oTree1:bGotFocus := {|| nQualTree:=1 }
			oTree2:bGotFocus := {|| nQualTree:=2 }
			// Evento para mudanca de linha dentro do tree
			oTree1:bChange   := {|| Mat310Ref(@oTree1,aParam310[12],@oSayOrig01,@oSayOrig02,@oSayOrig03,@oSayOrig04,aDadosOri,cPictQtd,aParam310) }
			oTree2:bChange   := {|| Mat310Ref(@oTree2,aParam310[12],@oSayDest01,@oSayDest02,@oSayDest03,@oSayDest04,aDadosDest,cPictQtd,aParam310) }
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| IIf(A310ValOK(aDadosTransf) .and. lCntWEB,(Processa({|lEnd| IIf(cPaisLoc == "BRA", A310Proc(aDadosTransf,aParam310) , A310ProcLoc(aDadosTransf,aParam310) ) },OemToAnsi(STR0019),OemToAnsi(STR0020),.F.),Iif(lNSelSerie,,oDlg:End())),)},{||oDlg:End()},,aButtons) //"Aguarde"###"Gerando transferencias"
		EndIf
	EndIf
EndIf
// Restaura filial original
cFilAnt:=cFilOri
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A310TreeCM³ Autor ³Rodrigo de A Sartorio  ³ Data ³ 27/10/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta os objetos TREE                         			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ A310TreeCM(ExpO1,Exp02,ExpN1,ExpA1,ExpA2,ExpC1,ExpA3,ExpA4,  ³±±
±±³          ³ ExpA5)                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto tree1 utilizado                               ³±±
±±³          ³ ExpO2 = Objeto tree2 utilizado                               ³±±
±±³          ³ ExpN1 = Identifica se apresenta por produto ou por armazem   ³±±
±±³          ³ ExpA1 = Array com dados do tree de origem                    ³±±
±±³          ³ ExpA2 = Array com dados do tree de destino                   ³±±
±±³          ³ ExpC1 = Picture utilizada para apresentar quantidade         ³±±
±±³          ³ ExpA3 = Array com dados das filiais da empresa corrente      ³±±
±±³          ³ ExpA4 = Array com os parametros do programa                  ³±±
±±³          ³ ExpA5 = Array com as categorias selecionadas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA310                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A310TreeCM(oTree1,oTree2,nTipoQuebra,aDadosOri,aDadosDest,cPictQtd,aFiliais,aParam310,aCategorias)
Local nx           :=0
Local nAcho        :=0
Local aQuebras     :={}
Local aArea        :=GetArea()
Local cProdVazio   :=CriaVar("B2_COD"  ,.F.)
Local cArmazemVazio:=CriaVar("B2_LOCAL",.F.)
Local cRecnoVazio  :=StrZero(0,10)
Local cTextoVazio  :=""
Local cQtdAtu      :=""
Local cQtdDisp     :=""
Local cQtdAtu2     :=""
Local cQtdDisp2    :=""
Local cLocalCQ     :=""
Local cFilOri      := cFilAnt
Local cMvCQ			:= GetMvNNR('MV_CQ','98')
Local lExisteSB2   := .F.
Local cAliasSB2    := "SB2"
Local nRegistro    := 0
Local nSaldoMov    := 0
Local a310Filial   := {}
Local aFilsPE      := {}
Local l310Filial   := .F.
Local lCriaSB2     := GetNewPar("MV_SB2AUTO", .F.)   
Local cLen		   := If("SQL" $ TCGetDB(),"LEN","LENGTH")
Local lTranCQ  := IsTranCQ()
Local cLabelTree   := ""
Local i            := {}
Local lFirstCatego := .T.
Local nTamCatego   := Len(ACV->ACV_CATEGO)
Local nAchoCateg   :=0
Local nCateg		:= 0
Local ni			:= 0
Local lRet			:= .T.

//aSM0
//Posicao 01: Empresa Ex( T1 )
//Posicao 02: Filial  Ex( D MG 01 )
//Posicao 11: Perm. Acesso .T. / .F. Ex( .F. )
Local aSM0 		 := FWLoadSM0(.T., .T.)
Local bVldFil 	 := { || Ascan( aSm0, { | x | AllTrim( x[ 02 ] ) == AllTrim( aFiliais[nx,1] )  .And. AllTrim( x[ 01 ] ) == AllTrim( aFiliais[nx,2] ) .And. ( x[ 11 ] ) }  ) > 0 }

// Ponto de entrada para adicionar filtros extras a sentenca SQL 
// que obtem os produtos a serem apresentados
Local lM310Filtro  := ExistBlock('M310FILTRO')
Local cM310Filtro  := ""

// Ponto de entrada para determinar as filiais de origem e destino
// que o usuario tera acesso para transferencia.
If ExistBlock("M310FILIAL")
	l310Filial := .T.
	aFilsPE := ExecBlock("M310FILIAL",.F.,.F.,{cUsuario,aFiliais})
	If ValType(aFilsPE) == "A"
		a310Filial := aClone(aFilsPE)
	Else
		l310Filial := .F.
	EndIf
EndIf

// Criar registros na SB2 para produtos sem saldo na filial
If lCriaSB2
	M310SB2Aut(aFiliais, aParam310, aCategorias)
EndIf

// Varre todas as filiais
For nx:=1 to Len(aFiliais)
	// Altera filial de acordo com lista de filiais
	cFilAnt:=aFiliais[nx,1]
	// Recupera o Armazem de CQ da Filial
    cLocalCQ := cMvCQ
	// Array com os produtos/armazens da filial
	aQuebras:={}
	// Adiciona filial do tree
	If nTipoQuebra == 1
		cTextoVazio:=cProdVazio+cArmazemVazio+cRecnoVazio
	ElseIf nTipoQuebra == 2
		cTextoVazio:=cArmazemVazio+cProdVazio+cRecnoVazio
	EndIf

	lRet := Eval( bVldFil ) //Validacao do Acesso do Usuário as Filiais do Sistema
	If l310Filial .And. !Empty(a310Filial[1])
		If (aFiliais[nx,1] $ a310Filial[1])
			oTree1:AddTree(STR0021+aFiliais[nx,1]+" "+aFiliais[nx,5]+Space(60),.T.,,,"PREDIO","PREDIO","1"+aFiliais[nx,1]+cTextoVazio)			 //"Filial "
			lRet := .T.
		EndIf			
	Else	
		// Somente filial corrente
		If lRet .And. ( aParam310[18] == 2 .Or. ( aParam310[18] == 1 .And. cFilAnt == cFilOri ) )
			oTree1:AddTree(STR0021+aFiliais[nx,1]+" "+aFiliais[nx,5]+Space(60),.T.,,,"PREDIO","PREDIO","1"+aFiliais[nx,1]+cTextoVazio)			 //"Filial "
		EndIf
	EndIf	
	
	If l310Filial .And. !Empty(a310Filial[2])
		If (aFiliais[nx,1] $ a310Filial[2])	
			oTree2:AddTree(STR0021+aFiliais[nx,1]+" "+aFiliais[nx,5]+Space(60),.T.,,,"PREDIO","PREDIO","1"+aFiliais[nx,1]+cTextoVazio)			 //"Filial "
			lRet := .T.
		EndIf
	Else
		If lRet
			oTree2:AddTree(STR0021+aFiliais[nx,1]+" "+aFiliais[nx,5]+Space(60),.T.,,,"PREDIO","PREDIO","1"+aFiliais[nx,1]+cTextoVazio)			 //"Filial "			
		EndIf
	EndIf

	If ( lRet )
	// Adiciona armazens da filial com seus respectivos produtos
	dbSelectArea("SB2")
	dbSetOrder(nTipoQuebra)
	// Montagem da query
	// Pesquisa categorias da filial corrente
	nAchoCateg:=Ascan(aCategorias,{|x| x[2] == xFilial("ACV")})
	nCateg:=Ascan(aCategorias,{|x| x[1] })
	If aParam310[11] == 1 .And. !(nCateg > 0) // Verifica se selecionou alguma categoria
		Return NIL
	Endif
	
	lFirstCatego := .T.
	cAliasSB2 := GetNextAlias()
	cQuery:= "SELECT SB2.*,SB2.R_E_C_N_O_ REGB2 FROM "+RetSqlName("SB2")+" SB2, "+RetSqlName("SB1")+" SB1"
	// Filtra categorias
	If aParam310[11] == 1 .And. nAchoCateg > 0
		cQuery+= ", "+RetSqlName("ACV")+" ACV "
	EndIf
	cQuery+= " WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"'"
	If aParam310[24] = 2
		cQuery+= " AND SB1.B1_COD >= '"+aParam310[01]+"'"
		cQuery+= " AND SB1.B1_COD <= '"+aParam310[02]+"'"
		cQuery+= " AND SB1.B1_TIPO >= '"+aParam310[07]+"'"
		cQuery+= " AND SB1.B1_TIPO <= '"+aParam310[08]+"'"
		cQuery+= " AND SB1.B1_GRUPO >= '"+aParam310[09]+"'"
		cQuery+= " AND SB1.B1_GRUPO <= '"+aParam310[10]+"'"
	Else
		cQuery+= " AND SB1.B1_COD IN ("
		For ni := 1 to len(aLstProd)
			If ni > 1
				cQuery+=","
			EndiF 
			cQuery+="'"+aLstProd[ni,1]+"'"
		Next ni
		cQuery+=") "
	EndiF
	cQuery+= " AND SB1.D_E_L_E_T_=' '"
	cQuery+= " AND SB1.B1_MSBLQL <> '1'"
	cQuery+= " AND SB2.B2_FILIAL='"+xFilial("SB2")+"'"
	cQuery+= " AND SB2.B2_COD = SB1.B1_COD"
	cQuery+= " AND SB2.B2_LOCAL >= '"+aParam310[05]+"'"
	cQuery+= " AND SB2.B2_LOCAL <= '"+aParam310[06]+"'"
	cQuery+= " AND SB2.D_E_L_E_T_=' ' "
	// Filtra categorias
	If aParam310[11] == 1 .And. nAchoCateg > 0
		cQuery+= " AND ACV.ACV_FILIAL='"+xFilial("ACV")+"'"
		cQuery+= " AND ((SB2.B2_COD = ACV.ACV_CODPRO AND ACV.ACV_GRUPO='' )OR (ACV.ACV_GRUPO = SB1.B1_GRUPO AND ACV.ACV_GRUPO<> ' ')"
		cQuery+= " OR(SUBSTRING(SB2.B2_COD,1,"+cLen+"(RTRIM(ACV.ACV_REFGRD))) = RTRIM(ACV.ACV_REFGRD) AND ACV.ACV_REFGRD<>' '))"
		cQuery+= " AND ACV.D_E_L_E_T_=' ' AND ACV.ACV_CATEGO IN ("
		For i:=nAchoCateg to Len(aCategorias)
			If aCategorias[i,2] == xFilial("ACV")
				If aCategorias[i,1]
					If !lFirstCatego
						cQuery+= ","
					Else
						lFirstCatego:=.F.
					EndIf
					cQuery+= "'"+SubStr(aCategorias[i,3],1,nTamCatego)+"'"
				EndIf
			Else
				Exit
			EndIf
		Next i
		cQuery+= ") "
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PONTO DE ENTRADA PARA ADICIONAR FILTROS A QUERY PRINCIPAL³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lM310Filtro
		//--Filtros adicionais
		cM310Filtro := ExecBlock( 'M310FILTRO', .F., .F.)
		
		If ValType( cM310Filtro ) == 'C' .And. !Empty( cM310Filtro )
			cQuery += " AND " + cM310Filtro + " "
		EndIf
	EndIf
	
	cQuery += " ORDER BY "+SqlOrder(SB2->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB2,.T.,.T.)
	dbSelectArea(cAliasSB2)
	dbGotop()
	lExisteSB2:=!Eof()
	
	If lExisteSB2
		While !((cAliasSB2)->(Eof())) .And. (cAliasSB2)->B2_FILIAL == xFilial("SB2")		
			//-- Pesquisa
			AADD( aDescSeek , { aFiliais[nx,1],(cAliasSB2)->B2_COD, AllTrim(Upper(StrTran(Posicione("SB1",1,xFilial("SB1")+(cAliasSB2)->B2_COD,"B1_DESC")," ",""))), (cAliasSB2)->B2_LOCAL})			
						
			nAcho:=Ascan(aQuebras,If(nTipoQuebra==1,(cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL))
			If nAcho == 0
				If Len(aQuebras) > 0
					// Somente filial corrente
					If aParam310[18] == 2 .Or. (aParam310[18] == 1 .And. cFilAnt == cFilOri)
						If oTree1:nTotal > 0
							oTree1:EndTree()
						EndIf
					EndIf
					If oTree2:nTotal > 0
						oTree2:EndTree()
					EndIf
				EndIf
				AADD(aQuebras,If(nTipoQuebra==1,(cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL))				
				If nTipoQuebra == 1 				   
				   If aParam310[21] == 1 // Mostrar descrição do produto
						cLabelTree := STR0022+Alltrim((cAliasSB2)->B2_COD)+" - "+Posicione("SB1",1,xFilial("SB1")+(cAliasSB2)->B2_COD,"B1_DESC") //"Produto "                                                            })
					Else
						cLabelTree := STR0022+Alltrim((cAliasSB2)->B2_COD) //"Produto"
					EndIf									
					If l310Filial .And. !Empty(a310Filial[1])
						If (aFiliais[nx,1] $ a310Filial[1])
							oTree1:AddTree(cLabelTree,.T.,,,"BOXBOM1","BOXBOM1","2"+aFiliais[nx,1]+(cAliasSB2)->B2_COD+cArmazemVazio+cRecnoVazio)					
						EndIf
					Else				
						// Somente filial corrente
						If aParam310[18] == 2 .Or. (aParam310[18] == 1 .And. cFilAnt == cFilOri)
							oTree1:AddTree(cLabelTree,.T.,,,"BOXBOM1","BOXBOM1","2"+aFiliais[nx,1]+(cAliasSB2)->B2_COD+cArmazemVazio+cRecnoVazio)
						EndIf
					EndIf						
					If l310Filial .And. !Empty(a310Filial[2])
						If (aFiliais[nx,1] $ a310Filial[2])
							oTree2:AddTree(cLabelTree,.T.,,,"BOXBOM1","BOXBOM1","2"+aFiliais[nx,1]+(cAliasSB2)->B2_COD+cArmazemVazio+cRecnoVazio)					
						EndIf
					Else	                                                                                                    
						oTree2:AddTree(cLabelTree,.T.,,,"BOXBOM1","BOXBOM1","2"+aFiliais[nx,1]+(cAliasSB2)->B2_COD+cArmazemVazio+cRecnoVazio)
    				EndIf					
				Else
					If l310Filial .And. !Empty(a310Filial[1])
						If (aFiliais[nx,1] $ a310Filial[1])
							oTree1:AddTree(STR0023+(cAliasSB2)->B2_LOCAL,.T.,,,"ARMAZEM","ARMAZEM","2"+aFiliais[nx,1]+(cAliasSB2)->B2_LOCAL+cProdVazio+cRecnoVazio)							 //"Armazem "
						EndIf
					Else							
						// Somente filial corrente
						If aParam310[18] == 2 .Or. (aParam310[18] == 1 .And. cFilAnt == cFilOri)
							oTree1:AddTree(STR0023+(cAliasSB2)->B2_LOCAL,.T.,,,"ARMAZEM","ARMAZEM","2"+aFiliais[nx,1]+(cAliasSB2)->B2_LOCAL+cProdVazio+cRecnoVazio)							 //"Armazem "
						EndIf
					EndIf
					If l310Filial .And. !Empty(a310Filial[2])
						If (aFiliais[nx,1] $ a310Filial[2])
							oTree2:AddTree(STR0023+(cAliasSB2)->B2_LOCAL,.T.,,,"ARMAZEM","ARMAZEM","2"+aFiliais[nx,1]+(cAliasSB2)->B2_LOCAL+cProdVazio+cRecnoVazio)								 //"Armazem "					
						EndIf
					Else							
						oTree2:AddTree(STR0023+(cAliasSB2)->B2_LOCAL,.T.,,,"ARMAZEM","ARMAZEM","2"+aFiliais[nx,1]+(cAliasSB2)->B2_LOCAL+cProdVazio+cRecnoVazio)								 //"Armazem "
    				EndIf
				EndIf
			EndIf

			nRegistro := (cAliasSB2)->REGB2
					SB2->(MsGoto(nRegistro))
			
			// Saldo atual do produto
			If l310PODER3
				nSaldoMov := SaldoTerc((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL,"D",dDataBase,,,,l310PODER3)[1]
			Else
				// Saldo do armazem de CQ				
				If lTranCQ .And. AllTrim((cAliasSB2)->B2_LOCAL)==AllTrim(cLocalCQ)
					// Saldo do Produto no CQ
				    nSaldoMov := SldMovCQ(.T.,(cAliasSB2)->B2_COD,'','','','','','','','','','','',.F.,.T.)[1]
				Else
					// Saldo do Produto
					nSaldoMov := SaldoMov(.F.,.T.,nil,.F.,0,0,.T.)
				EndIf
			EndIf	
			
			AADD(aDadosDest,{nRegistro,(cAliasSB2)->B2_QATU,nSaldoMov ,(cAliasSB2)->B2_QTSEGUM,ConvUm((cAliasSB2)->B2_COD,nSaldoMov,0,2),(cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL})
			// Somente filial corrente
			If aParam310[18] == 2 .Or. (aParam310[18] == 1 .And. cFilAnt == cFilOri)
				AADD(aDadosOri,{nRegistro,(cAliasSB2)->B2_QATU,nSaldoMov,(cAliasSB2)->B2_QTSEGUM,ConvUm((cAliasSB2)->B2_COD,nSaldoMov,0,2),(cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL})
			EndIf
			cQtdAtu  := Transform(aDadosDest[Len(aDadosDest),2],cPictQtd)
			cQtdDisp := Transform(aDadosDest[Len(aDadosDest),3],cPictQtd)
			cQtdAtu2 := Transform(aDadosDest[Len(aDadosDest),4],cPictQtd)
			cQtdDisp2:= Transform(aDadosDest[Len(aDadosDest),5],cPictQtd)
			If nTipoQuebra == 1  //Quebra por produto 
				If l310Filial .And. !Empty(a310Filial[1])
					If (aFiliais[nx,1] $ a310Filial[1])
						oTree1:AddTreeItem((cAliasSB2)->B2_LOCAL+" - "+cQtdDisp,"ARMAZEM","ARMAZEM","3"+aFiliais[nx,1]+(cAliasSB2)->B2_COD+(cAliasSB2)->B2_LOCAL+StrZero(nRegistro,10))
					EndIf	
				Else			
					// Somente filial corrente
					If aParam310[18] == 2 .Or. (aParam310[18] == 1 .And. cFilAnt == cFilOri)
						oTree1:AddTreeItem((cAliasSB2)->B2_LOCAL+" - "+cQtdDisp,"ARMAZEM","ARMAZEM","3"+aFiliais[nx,1]+(cAliasSB2)->B2_COD+(cAliasSB2)->B2_LOCAL+StrZero(nRegistro,10))
					EndIf
				EndIf
				If l310Filial .And. !Empty(a310Filial[2])
					If (aFiliais[nx,1] $ a310Filial[2])
						oTree2:AddTreeItem((cAliasSB2)->B2_LOCAL+" - "+cQtdDisp,"ARMAZEM","ARMAZEM","3"+aFiliais[nx,1]+(cAliasSB2)->B2_COD+(cAliasSB2)->B2_LOCAL+StrZero(nRegistro,10))	
		        	EndIf
                Else
					oTree2:AddTreeItem((cAliasSB2)->B2_LOCAL+" - "+cQtdDisp,"ARMAZEM","ARMAZEM","3"+aFiliais[nx,1]+(cAliasSB2)->B2_COD+(cAliasSB2)->B2_LOCAL+StrZero(nRegistro,10))
				EndIf	   
			Else
				If aParam310[21] == 1 // Mostrar descrição do produto para armazen
					cLabelTree := Alltrim((cAliasSB2)->B2_COD)+" - "+Posicione("SB1",1,xFilial("SB1")+(cAliasSB2)->B2_COD,"B1_DESC") //"Produto "
				Else
					cLabelTree := Alltrim((cAliasSB2)->B2_COD) //"Produto"
				EndIf								
				If l310Filial .And. !Empty(a310Filial[1])
					If (aFiliais[nx,1] $ a310Filial[1])
						oTree1:AddTreeItem(cLabelTree +" - "+cQtdDisp,"BOXBOM1","BOXBOM1","3"+aFiliais[nx,1]+(cAliasSB2)->B2_LOCAL+(cAliasSB2)->B2_COD+StrZero(nRegistro,10))						
					EndIf
				Else		
					// Somente filial corrente
					If aParam310[18] == 2 .Or. (aParam310[18] == 1 .And. cFilAnt == cFilOri)
						oTree1:AddTreeItem(cLabelTree +" - "+cQtdDisp,"BOXBOM1","BOXBOM1","3"+aFiliais[nx,1]+(cAliasSB2)->B2_LOCAL+(cAliasSB2)->B2_COD+StrZero(nRegistro,10))						
					EndIf
	            Endif
				If l310Filial .And. !Empty(a310Filial[2])
					If (aFiliais[nx,1] $ a310Filial[2])
						oTree2:AddTreeItem(cLabelTree +" - "+cQtdDisp,"BOXBOM1","BOXBOM1","3"+aFiliais[nx,1]+(cAliasSB2)->B2_LOCAL+(cAliasSB2)->B2_COD+StrZero(nRegistro,10))				
        			EndIf
        		Else        			
					oTree2:AddTreeItem(cLabelTree +" - "+cQtdDisp,"BOXBOM1","BOXBOM1","3"+aFiliais[nx,1]+(cAliasSB2)->B2_LOCAL+(cAliasSB2)->B2_COD+StrZero(nRegistro,10))
    			EndIf
			EndIf			
			(cAliasSB2)->(dbSkip())
		End
		// Somente filial corrente
		If aParam310[18] == 2 .Or. (aParam310[18] == 1 .And. cFilAnt == cFilOri)
			If oTree1:nTotal > 0
				oTree1:EndTree()// Fecha ultimo ITEM
			EndIf
		EndIf
		If oTree2:nTotal > 0
			oTree2:EndTree()// Fecha ultimo ITEM
		EndIf
		EndIf
		dbSelectArea(cAliasSB2)
		dbCloseArea()
		// Somente filial corrente
		If aParam310[18] == 2 .Or. (aParam310[18] == 1 .And. cFilAnt == cFilOri)
			If oTree1:nTotal > 0
				oTree1:EndTree()// Fecha filial
			EndIf
		EndIf

	EndIf

	If oTree2:nTotal > 0
		oTree2:EndTree()// Fecha filial
	EndIf

Next nx

IIf( Select( cAliasSB2 ) > 0, ( cAliasSB2 )->( dbCloseArea() ), Nil )
// Restaura area original
RestArea(aArea)
// Restaura filial original
cFilAnt:=cFilOri
RETURN

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M310SB2Aut ³ Autor ³Emerson Rony Oliveira³ Data ³ 11/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria registro na SB2 para produtos sem saldo na filial.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ M310SB2Aut(ExpA1,ExpA2,ExpA3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor contendo as filiais envolvidas               ³±±
±±³          ³ ExpA2 = Vetor contendo os parametros da rotina             ³±±
±±³          ³ ExpA3 = Vetor contendo as categorias utilizadas            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M310SB2Aut(aFiliais, aParam310, aCategorias)
Local aProdutos := {}
Local aArea     := GetArea()
Local aAreaSB1  := SB1->(GetArea())
Local aAreaSB2  := SB2->(GetArea())
Local cAliasSB1 := "SB1"
Local cFilOri   := cFilAnt
Local nX        := 0
Local cDbType		:= TCGetDB()
Local cFuncNull	:= ""
Local cLen		   := If("SQL" $ TCGetDB(),"LEN","LENGTH") 
Local cQuery       := ""
Local nI           := 0
Local lFirstCatego := .T.
Local nTamCatego   := Len(ACV->ACV_CATEGO)
Local nAchoCateg   := 0

// Ponto de entrada para adicionar filtros extras a sentenca SQL 
// que obtem os produtos a serem apresentados
Local lM310Filtro  := ExistBlock('M310FILTRO')
Local cM310Filtro  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nome da funcao do banco de dados que substitui NULL por 0 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case cDbType $ "DB2/POSTGRES"
		cFuncNull	:= "COALESCE"
	Case cDbType $ "ORACLE/INFORMIX"  
  		cFuncNull	:= "NVL"
 	Otherwise
 		cFuncNull	:= "ISNULL"
EndCase


// Varre todas as filiais
For nX := 1 to Len(aFiliais)
	// Altera filial de acordo com lista de filiais
	cFilAnt := aFiliais[nX,1]

	dbSelectArea("SB1")
	dbSetOrder(1)
	lFirstCatego := .T.
	nAchoCateg   := Ascan(aCategorias,{|x| x[2] == xFilial("ACV")})
	cAliasSB1    := GetNextAlias()
	
	cQuery := "SELECT SB1.B1_COD, SB1.B1_LOCPAD"
	cQuery += " FROM "+RetSqlName("SB1")+" SB1"
	cQuery += " LEFT JOIN "+RetSqlName("SB2")+" SB2 ON ("
	cQuery += " SB2.B2_FILIAL = '"+xFilial("SB2")+"'"
	cQuery += " AND SB2.B2_COD = SB1.B1_COD"
	cQuery += " AND SB2.B2_LOCAL >= '"+aParam310[05]+"'"
	cQuery += " AND SB2.B2_LOCAL <= '"+aParam310[06]+"'"
	cQuery += " AND SB2.D_E_L_E_T_ = ' ')"
	// Filtra categorias
	If aParam310[11] == 1 .And. nAchoCateg > 0
		cQuery+= ", "+RetSqlName("ACV")+" ACV "
	EndIf
	cQuery += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery += " AND SB1.B1_COD >= '"+aParam310[01]+"'"
	cQuery += " AND SB1.B1_COD <= '"+aParam310[02]+"'"
	cQuery += " AND SB1.B1_TIPO >= '"+aParam310[07]+"'"
	cQuery += " AND SB1.B1_TIPO <= '"+aParam310[08]+"'"
	cQuery += " AND SB1.B1_GRUPO >= '"+aParam310[09]+"'"
	cQuery += " AND SB1.B1_GRUPO <= '"+aParam310[10]+"'"
	cQuery += " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " AND "+cFuncNull+"(SB2.B2_FILIAL, '') = ''"
	// Filtra categorias
	If aParam310[11] == 1 .And. nAchoCateg > 0
		cQuery += " AND ACV.ACV_FILIAL = '"+xFilial("ACV")+"'"
		cQuery += " AND ((SB1.B1_COD = ACV.ACV_CODPRO AND ACV.ACV_GRUPO = '' )OR (ACV.ACV_GRUPO = SB1.B1_GRUPO AND ACV.ACV_GRUPO <> ' ')"
		cQuery += " OR (SUBSTRING(SB1.B1_COD,1," + cLen + "(RTRIM(ACV.ACV_REFGRD))) = RTRIM(ACV.ACV_REFGRD) AND ACV.ACV_REFGRD<>' '))"
		cQuery += " AND ACV.D_E_L_E_T_=' ' AND ACV.ACV_CATEGO IN ("
		For nI := nAchoCateg To Len(aCategorias)
			If aCategorias[nI,2] == xFilial("ACV")
				If aCategorias[nI,1]
					IIf(!lFirstCatego, cQuery += ",", lFirstCatego := .F.)
					cQuery += "'"+SubStr(aCategorias[nI,3],1,nTamCatego)+"'"
				EndIf
			Else
				Exit
			EndIf
		Next nI
		cQuery+= ") "
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PONTO DE ENTRADA PARA ADICIONAR FILTROS A QUERY PRINCIPAL³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lM310Filtro
		//--Filtros adicionais
		cM310Filtro := ExecBlock( 'M310FILTRO', .F., .F.)
		
		If ValType( cM310Filtro ) == 'C' .And. !Empty( cM310Filtro )
			cQuery += " AND " + cM310Filtro + " "
		EndIf
	EndIf
				
	cQuery += " ORDER BY "+SqlOrder(SB1->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1,.T.,.T.)
	
	dbSelectArea(cAliasSB1)
	While !(cAliasSB1)->(Eof())
		aAdd(aProdutos, {(cAliasSB1)->B1_COD, (cAliasSB1)->B1_LOCPAD, xFilial("SB2")})
		dbSkip()
	EndDo
		
	dbSelectArea(cAliasSB1)
	dbCloseArea()

Next nX

//Cria registro na SB2 para os produtos que ainda nao possuem saldo na filial
If Len(aProdutos) > 0
	For nX := 1 to Len(aProdutos)
		CriaSB2(aProdutos[nX,1], aProdutos[nX,2], aProdutos[nX,3])
	Next nX
EndIf

RestArea(aAreaSB2)
RestArea(aAreaSB1)
RestArea(aArea)
// Restaura filial original
cFilAnt := cFilOri
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A310ShPrd  ³ Autor ³Rodrigo A Sartorio   ³ Data ³ 27/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra os dados do produto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ A310ShPrd(ExpO1,ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto tree utilizado                              ³±±
±±³          ³ ExpN1 = Identifica se apresenta por produto ou por armazem ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A310ShPrd(oTree,nTipoQuebra)
Local cProduto:=SubStr(oTree:GetCargo(),TAMSX3('B1_FILIAL') [1] + If(nTipoQuebra==1,2,4),Len(SB2->B2_COD))
Local aArea:=GetArea()
Private cCadastro:=STR0002 //"Produto"
dbSelectArea("SB1")
dbSetOrder(1)
If MSSeek(xFilial("SB1")+cProduto)
	AxVisual("SB1",SB1->(Recno()),1)
EndIf
RestArea(aArea)
RETURN

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A310Relac  ³ Autor ³Rodrigo A Sartorio   ³ Data ³ 28/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relaciona origem e destino                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ A310Relac(ExpO1,Exp02,ExpN1,ExpA1,ExpA2,ExpA3,ExpC1,ExpA4, ³±±
±±³          ³ ExpA5)                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto tree1 utilizado                             ³±±
±±³          ³ ExpO2 = Objeto tree2 utilizado                             ³±±
±±³          ³ ExpN1 = Identifica se apresenta por produto ou por armazem ³±±
±±³          ³ ExpA1 = Array com dados do tree de origem                  ³±±
±±³          ³ ExpA2 = Array com dados do tree de destino                 ³±±
±±³          ³ ExpA3 = Array com dados da transferencia                   ³±±
±±³          ³ ExpC1 = Picture utilizada para apresentar quantidade       ³±±
±±³          ³ ExpA4 = Array com dados das filiais da empresa corrente    ³±±
±±³          ³ ExpA5 = Array com parametros configurados                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A310Relac(oTree1,oTree2,nTipoQuebra,aDadosOri,aDadosDest,aDadosTransf,cPictQtd,aFiliais,aParam310,lCntWEB)
Local oDlg
Local cCargo1  :=oTree1:GetCargo()
Local cCargo2  :=oTree2:GetCargo()
Local cFilDest :=SubStr(cCargo2,2,FWGETTAMFILIAL)
Local cProduto2:=SubStr(cCargo2,If(nTipoQuebra==1,FWGETTAMFILIAL+2,FWGETTAMFILIAL+2+TamSx3("B2_LOCAL")[1]),Len(SB2->B2_COD))
Local cLoclzPict
Local cLocDest :=""
Local nAcho    :=0
Local nAcho2   :=0
Local nAchoTr  :=0
Local lConfirma:=.F.
Local cQtdDisp :=""
Local cQtdDisp2:=""
Local cCliente :=""
Local cLojaCli :=""
Local cFornece :=""
Local cLojaFornece:=""
Local lContinua:=.T.
Local lTesOrig :=.T.
Local lTesDest :=.T.
Local lEstNeg  :=.F.
Local nQuant2    :=0
Local nQtd2UM    :=0
Local lM310QTD   := .F.
Local aButtons   := {}
Local cLocalCQ   := ''
Local cFilBkp    := cFilAnt
Local lTranCQ    := IsTranCQ()
Local cTESSai    := ""
Local cTESEnt    := ""
Local lIsPrdOK	:= .F.
Local cMVTRFVLDP	:= SuperGetMV("MV_TRFVLDP",.F.,"1")	//-- 1: códigos iguais; 2: SA5; 3: Não valida
Private nQuant   :=0
Private nQuant2UM:=0
Private cFilOrig :=SubStr(cCargo1,2,FWGETTAMFILIAL)
Private cLocaliz:=Space(TamSx3("BF_LOCALIZ"   )[1])    
Private cProduto1:=SubStr(cCargo1,If(nTipoQuebra==1,FWGETTAMFILIAL+2,FWGETTAMFILIAL+2+TamSx3("B2_LOCAL")[1]),Len(SB2->B2_COD))
Private cLocOrig :=""         
Private cLoteDigi:=Space(TamSx3("B8_LOTECTL"   )[1]) 
Private cNumLote :=Space(TamSx3("B8_NUMLOTE"   )[1])
Private dDtValid2 :=CTOD("  /  /  ")  
Private cNumSerie:=Space(TamSx3("BF_NUMSERI"   )[1])
Private cNumseqCQ:=Space(TamSx3("D7_NUMSEQ"    )[1])
Private lValTes  :=.F.

lCntWEB := .F.

lIsPrdOK := A310VldPrd(cFilOrig,cProduto1,cFilDest,cProduto2,aParam310[19] == 1)

If lContinua
	// Produto origem preenchido e produto destino preenchido
	If Substr(cCargo1,1,1) == "3" .And. Substr(cCargo2,1,1) == "3" .And. lIsPrdOK
		// Armazem origem e armazem destino
		cLocOrig:=SubStr(cCargo1,FWGETTAMFILIAL+2+If(nTipoQuebra==1,Len(SB2->B2_COD),0),Len(SB2->B2_LOCAL))
		cLocDest:=SubStr(cCargo2,FWGETTAMFILIAL+2+If(nTipoQuebra==1,Len(SB2->B2_COD),0),Len(SB2->B2_LOCAL))
		// Quantidade total disponivel na origem
		nAcho :=Ascan(aDadosOri ,{ |x| x[1] == Val(Right(cCargo1,10))})
		nAcho2:=Ascan(aDadosDest,{ |x| x[1] == Val(Right(cCargo2,10))})
		// Verifica se o armazem esta bloqueado
		If AvalBlqLoc(cProduto1,cLocOrig,aParam310[13],.T.,cProduto2,cLocDest,aParam310[15],cFilOrig,cFilDest)	
			lContinua := .F.		
		EndIf
		// Processa Dialog
		If lContinua .And. nAcho > 0 .And. nAcho2 > 0 
			//nQuant   :=aDadosOri[nAcho,3]
			//nQuant2UM:=aDadosOri[nAcho,5]	 
			If ExistBlock("M310QTD")
				lM310QTD := ExecBlock( "M310QTD", .F., .F.)
				if lM310QTD
					nQuant2:= aDadosOri[nAcho,3]
					nQtd2UM:= aDadosOri[nAcho,5]	
				EndIf
			EndIf

			//Verifica o armazem de CQ da Filial Origem
			cFilAnt  := cFilOrig
			cLocalCQ := GetMvNNR('MV_CQ','98')
			lEstNeg  := (GetMv('MV_ESTNEG')=='N')

			// Caso seja o armazem de CQ habilita a pesquisa do saldo rejeitado.
			If lTranCQ .And. AllTrim(cLocalCQ)==AllTrim(cLocOrig)
				AAdd(aButtons,{"LOCALIZA"	,{|| A310ConCQ(cProduto1,cLocOrig,cFilOrig) }, STR0081 } ) //'Consulta Saldo CQ'
			EndIf	

			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ativa tecla F4 para comunicacao com Saldos dos Lotes         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Set Key VK_F4 To A310AvalF4()
			 
			cLocaliz   := Criavar("D3_LOCALIZ")
			cLoclzPict := Trim(X3Picture("D3_LOCALIZ"))
							
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Dialog                                                 ³    
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DEFINE MSDIALOG oDlg FROM  000,000 TO 450,680 TITLE OemToAnsi(STR0024) PIXEL	 //"Dados da transferˆncia"
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula dimensões                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSize := FwDefSize():New(.T.,,,oDlg)              
			oSize:AddObject( "ORIGEM"  ,  100, 20, .T., .T. ) // Totalmente dimensionavel
			oSize:AddObject( "RASTRO"  ,  100, 20, .T., .T. ) // Totalmente dimensionavel 
			oSize:AddObject( "LOCALIZ" ,  100, 20, .T., .T. ) // Totalmente dimensionavel
			oSize:AddObject( "DESTINO" ,  100, 20, .T., .T. ) // Totalmente dimensionavel	
			oSize:AddObject( "QTD"     ,  100, 20, .T., .T. ) // Totalmente dimensionavel
			
			oSize:lProp 	:= .T. // Proporcional             
			oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
		
			oSize:Process() 	   // Dispara os calculos  
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Campos Produto Origem                                        ³    
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ oSize:GetDimension("ORIGEM","LININI") ,oSize:GetDimension("ORIGEM","COLINI") TO ;
					oSize:GetDimension("ORIGEM","LINEND"), oSize:GetDimension("ORIGEM","COLEND") LABEL STR0015  OF oDlg  PIXEL //"Origem"                

			@ oSize:GetDimension("ORIGEM","LININI")+12,oSize:GetDimension("ORIGEM","COLINI")+3   SAY STR0002 SIZE 24,07 OF oDlg PIXEL  //"Produto"
			@ oSize:GetDimension("ORIGEM","LININI")+12,oSize:GetDimension("ORIGEM","COLINI")+149 SAY STR0011 SIZE 32,13 OF oDlg PIXEL  //"Filial"
			@ oSize:GetDimension("ORIGEM","LININI")+12,oSize:GetDimension("ORIGEM","COLINI")+225 SAY STR0025 SIZE 35,13 OF oDlg PIXEL  //"Armazem"
			
			@ oSize:GetDimension("ORIGEM","LININI")+10,oSize:GetDimension("ORIGEM","COLINI")+27  MSGET cProduto1	When .F. SIZE 096,09 OF oDlg PIXEL
			@ oSize:GetDimension("ORIGEM","LININI")+10,oSize:GetDimension("ORIGEM","COLINI")+167 MSGET cFilOrig  	When .F. SIZE 041,09 OF oDlg PIXEL
			@ oSize:GetDimension("ORIGEM","LININI")+10,oSize:GetDimension("ORIGEM","COLINI")+257 MSGET cLocOrig 	When .F. SIZE 018,09 OF oDlg PIXEL
						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Campos Produto Destino                                       ³    
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ oSize:GetDimension("DESTINO","LININI") ,oSize:GetDimension("DESTINO","COLINI") TO ;
	   				oSize:GetDimension("DESTINO","LINEND"), oSize:GetDimension("DESTINO","COLEND") LABEL STR0016  OF oDlg  PIXEL //"Destino"
	     
			@ oSize:GetDimension("DESTINO","LININI")+12,oSize:GetDimension("DESTINO","COLINI")+3   SAY STR0002 SIZE 24,07 OF oDlg PIXEL  //"Produto"
			@ oSize:GetDimension("DESTINO","LININI")+12,oSize:GetDimension("DESTINO","COLINI")+149 SAY STR0011 SIZE 32,13 OF oDlg PIXEL  //"Filial"
			@ oSize:GetDimension("DESTINO","LININI")+12,oSize:GetDimension("DESTINO","COLINI")+225 SAY STR0025 SIZE 35,13 OF oDlg PIXEL  //"Armazem"
	
	   		@ oSize:GetDimension("DESTINO","LININI")+10,oSize:GetDimension("DESTINO","COLINI")+27  MSGET cProduto2	When .F. SIZE 096,09 OF oDlg PIXEL
			@ oSize:GetDimension("DESTINO","LININI")+10,oSize:GetDimension("DESTINO","COLINI")+167 MSGET cFilDest 	When .F. SIZE 041,09 OF oDlg PIXEL
			@ oSize:GetDimension("DESTINO","LININI")+10,oSize:GetDimension("DESTINO","COLINI")+257 MSGET cLocDest 	When .F. SIZE 018,09 OF oDlg PIXEL
		    
		 
		 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Campos Rastreabilidade                                       ³    
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ oSize:GetDimension("RASTRO","LININI") ,oSize:GetDimension("RASTRO","COLINI") TO ;
	   				oSize:GetDimension("RASTRO","LINEND"), oSize:GetDimension("RASTRO","COLEND") LABEL "Rastreabilidade"  OF oDlg  PIXEL //"Rastreabilidade"
	     
			@ oSize:GetDimension("RASTRO","LININI")+12,oSize:GetDimension("RASTRO","COLINI")+3   SAY "Lote"             SIZE 012,013 OF oDlg PIXEL  //"Lote"
			@ oSize:GetDimension("RASTRO","LININI")+12,oSize:GetDimension("RASTRO","COLINI")+100 SAY "Sub-Lote"         SIZE 022,007 OF oDlg PIXEL  //"Sub-Lote"
			@ oSize:GetDimension("RASTRO","LININI")+10,oSize:GetDimension("RASTRO","COLINI")+175 SAY "Data de Validade" SIZE 025,016 OF oDlg PIXEL  //"Data de Validade"
	
	   		@ oSize:GetDimension("RASTRO","LININI")+10,oSize:GetDimension("RASTRO","COLINI")+27  MSGET cLoteDigi Valid IIF(Vazio(),.T.,A310Lote()) When !A310IsCQ() .And. ((Rastro(cProduto1,"S") .Or. Rastro(cProduto1,"L"))) SIZE 045,009 OF oDlg PIXEL
			@ oSize:GetDimension("RASTRO","LININI")+10,oSize:GetDimension("RASTRO","COLINI")+125 MSGET cNumLote  Valid IIF(Vazio(),.T.,A310Lote()) When Rastro(cProduto1,"S")SIZE 027,009 OF oDlg PIXEL
			@ oSize:GetDimension("RASTRO","LININI")+10,oSize:GetDimension("RASTRO","COLINI")+200 MSGET dDtValid2 Valid dDtValid2 > dDataBase SIZE 044,009 When .F. OF oDlg PIXEL
		    
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Campos Localização                                           ³    
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ oSize:GetDimension("LOCALIZ","LININI") ,oSize:GetDimension("LOCALIZ","COLINI") TO ;
	   				oSize:GetDimension("LOCALIZ","LINEND"), oSize:GetDimension("LOCALIZ","COLEND") LABEL "Localização"  OF oDlg  PIXEL //"Localização"
	     
			@ oSize:GetDimension("LOCALIZ","LININI")+11,oSize:GetDimension("LOCALIZ","COLINI")+3   SAY "Endereço"     SIZE 24,07 OF oDlg PIXEL  //"Produto"
			@ oSize:GetDimension("LOCALIZ","LININI")+11,oSize:GetDimension("LOCALIZ","COLINI")+115 SAY "Numero Serie" SIZE 35,13 OF oDlg PIXEL  //"Filial"
	
	   		@ oSize:GetDimension("LOCALIZ","LININI")+10,oSize:GetDimension("LOCALIZ","COLINI")+28  MSGET cLocaliz  Valid IIF(Vazio(),.T.,ExistCpo("SBE",cLocOrig+cLocaliz)) F3 "SBE" Picture cLoclzPict When Localiza(cProduto1) SIZE 060,09 OF oDlg PIXEL
			@ oSize:GetDimension("LOCALIZ","LININI")+10,oSize:GetDimension("LOCALIZ","COLINI")+160 MSGET cNumSerie When Localiza(cProduto1) SIZE 085,09 OF oDlg PIXEL   
	 		 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Campos de quantidade                                         ³    
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ oSize:GetDimension("QTD","LININI"),oSize:GetDimension("QTD","COLINI") TO;
			     oSize:GetDimension("QTD","LINEND")-4, oSize:GetDimension("QTD","COLEND")  LABEL "" OF oDlg  PIXEL

			@ oSize:GetDimension("QTD","LININI")+8,oSize:GetDimension("QTD","COLINI")+3   SAY STR0026 SIZE 30,16 OF oDlg PIXEL //"Quantidade"
			@ oSize:GetDimension("QTD","LININI")+7,oSize:GetDimension("QTD","COLINI")+130 SAY STR0027 SIZE 30,16 OF oDlg PIXEL //"Quantidade 2a UM"

  			@ oSize:GetDimension("QTD","LININI")+6,oSize:GetDimension("QTD","COLINI")+35  MSGET IIF(lM310QTD, nQuant2, nQuant)    Picture cPictQtd  When .T. Valid A310Quant(1) SIZE 68,09 OF oDlg PIXEL HASBUTTON
			@ oSize:GetDimension("QTD","LININI")+6,oSize:GetDimension("QTD","COLINI")+170 MSGET IIF(lM310QTD, nQtd2UM, nQuant2UM) Picture cPictQtd  When .T. Valid A310Quant(2) SIZE 68,09 OF oDlg PIXEL HASBUTTON
			
			ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||If(A310TOk(cFilOrig,cProduto1,cLocOrig,cFilDest,cLocDest,aFiliais,aParam310,@cCliente,@cLojaCli,@cFornece,@cLojaFornece, IIF(lM310QTD, nQuant2, nQuant), IIF(lM310QTD, nQtd2UM, nQuant2UM)),(lConfirma:=.T.,oDlg:End()),lConfirma:=.F.)},{||oDlg:End()},,aButtons)
			// Caso confirmado coloca na lista de transferencias e retira o saldo da origem
			// Atualiza saldo atual do produto de origem, caso tenha havido alguma
			// movimentacao durante a operacao de relacao de transferencia	
			a310AtuOri(@aDadosOri,nAcho,lTranCQ)
			If aDadosOri[nAcho][3] < NQUANT .And. lEstNeg .And. !lValTES
			   Help(' ', 1, 'MA240NEGAT')
			   lconfirma:=.F.
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processa o TES Inteligente - SAIDA   ³    
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lconfirma
				If lTesIntSai
					// Posiciona na Filial Origem
					cFilAnt := cFilOrig
					cTESSai := MaTesInt(2,aParam310[22],cCliente,cLojaCli,"C",cProduto1)
					If Empty(cTESSai)
						Help(" ",1,"A310TESSAI")
						lConfirma := .F.
					EndIf
					cFilAnt := cFilBkp
				Else
					cTESSai := aParam310[13]
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processa o TES Inteligente - ENTRADA ³    
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lTesIntEnt
					// Posiciona na Filial Destino
					cFilAnt := cFilDest
					cTESEnt := MaTesInt(1,aParam310[23],cFornece,cLojaFornece,"F",cProduto1)
					If Empty(cTESEnt)
						Help(" ",1,"A310TESENT")
						lConfirma := .F.
					EndIf
					cFilAnt := cFilBkp
				Else
					cTESEnt := aParam310[15]
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza a validacao dos TES selecionados ³    
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lConfirma
				lConfirma := A310VldTes(cFilOrig,cFilDest,.T.,{cTESSai,cTESEnt},@lTesOrig,@lTesDest)
			EndIf

			If lConfirma
				// Array com dados para transferencia
				// [1] Filial  origem
				// [2] Produto origem
				// [3] Armazem origem
				// [4] Quantidade origem
				// [5] Quantidade origem 2a UM
				// [6] Filial  destino
				// [7] Armazem destino
				// [8] Cliente na Origem
				// [9] Loja na Origem
				// [10] Fornecedor no destino
				// [11] Loja no destino
				// [12] Documento na origem
				// [13] Serie do documento na origem
				// [14] Informacoes sobre o Poder de Terceiros
				// [14] Identificados Poder 3
				// [15] Cliente/Fornecedor Poder 3
				// [16] Loja Poder 3
				// [17] Lote Origem
				// [18] Sub-Lote Origem
				// [19] Data de Validade
				// [20] Endereço
				// [21] Numero de Serie
				// [22] Numero Sequencial do CQ
				// [23] TES Saida
				// [24] TES Entrada
				nAchoTr := aScan(aDadosTransf,{ |x| x[1] == cFilOrig .And.;
													x[2] == cProduto1 .And.;
													x[3] == cLocOrig .And.;
													x[6] == cFilDest .And.;
													x[7] == cLocDest .And.;
													x[17] == cLoteDigi .And.;
													x[18] == cNumLote .And.;
													x[20] == cLocaliz .And.;
													x[21] == cNumSerie .And.;
													x[25] == cProduto2 .And.;
													Iif(lTranCQ .And. AllTrim(cLocalCQ)==AllTrim(cLocOrig),x[22] == cNumseqCQ,.T.)})

				If nAchoTr > 0
					aDadosTransf[nAchoTr,4]+=nQuant
					aDadosTransf[nAchoTr,5]+=nQuant2UM
				Else
					aAdd(aDadosTransf,{	cFilOrig,;								// [01] Filial  origem
										cProduto1,;								// [02] Produto origem
										cLocOrig,;								// [03] Armazem origem
										IIF(lM310QTD, nQuant2, nQuant),;		// [04] Quantidade origem
										IIF(lM310QTD, nQtd2UM, nQuant2UM),;		// [05] Quantidade origem 2a UM
										cFilDest,;								// [06] Filial  destino
										cLocDest,;								// [07] Armazem destino
										cCliente,;								// [08] Cliente na Origem
										cLojaCli,;								// [09] Loja na Origem
										cFornece,;								// [10] Fornecedor no destino
										cLojaFornece,;							// [11] Loja no destino
										"",;									// [12] Documento na origem
										"",;									// [13] Serie do documento na origem
										"",;									// [14] Identificados Poder 3
										"",;									// [15] Cliente/Fornecedor Poder 3
										"",;									// [16] Loja Poder 3
										cLoteDigi,;								// [17] Lote Origem
										cNumLote,;								// [18] Sub-Lote Origem
										dDtValid2,;								// [19] Data de Validade
										cLocaliz,;								// [20] Endereço
										cNumSerie,;								// [21] Numero de Serie
										Iif(lTranCQ .And. AllTrim(cLocalCQ)==AllTrim(cLocOrig),cNumseqCQ,""),; // [22] NumSeq do CQ
										cTESSai,;								// [23] TES de Saída
										cTESEnt,;								// [24] TES de entrada
										cProduto2})								// [25] Produto destino
					//-- Ao adicionar dados em aDadosTransf, tratar no MATA311
				EndIf
				// Abaixa o saldo da origem
				If lTesOrig
					aDadosOri[nAcho,3]-= IIF(lM310QTD, nQuant2, nQuant)
					aDadosOri[nAcho,5]-= IIF(lM310QTD, nQtd2UM, nQuant2UM)
				EndIf	
				cQtdDisp:=Transform(aDadosOri[nAcho,3],cPictQtd)
				// Atualiza informacoes no tree
				oTree1:ChangePrompt(AllTrim(aDadosOri[nAcho,If(nTipoQuebra == 1,7,6)])+If(aParam310[21]== 1 .AND.nTipoQuebra==2 ," - "+Posicione("SB1",1,xFilial("SB1")+cProduto1,"B1_DESC"),"")+" - "+cQtdDisp,cCargo1)
				Eval(oTree1:bChange)
				
				// Aumenta o saldo da Destino
				If lTesDest
					aDadosDest[nAcho2,3]+= IIF(lM310QTD, nQuant2, nQuant)
					aDadosDest[nAcho2,5]+= IIF(lM310QTD, nQtd2UM, nQuant2UM)
				EndIf	
				cQtdDisp2:=Transform(aDadosDest[nAcho2,3],cPictQtd)
				// Atualiza informacoes no tree
			   	oTree2:ChangePrompt(AllTrim(aDadosDest[nAcho2,If(nTipoQuebra == 1,7,6)])+If(aParam310[21]== 1 .AND.nTipoQuebra==2," - "+Posicione("SB1",1,xFilial("SB1")+cProduto1,"B1_DESC"),"")+" - "+cQtdDisp2,cCargo2)
				Eval(oTree2:bChange)
				lCntWEB:=.T.
			EndIf
		EndIf
	Else
		// Nao foram selecionados itens validos para transferencia.
		If cMVTRFVLDP == '2'
			Help(" ",1,"A310SELER2")
		else
			Help(" ",1,"A310SELERR")
		EndIf
	EndIf                           
	
EndIf
//Desabilita na tela a tecla F4  
SetKey( VK_F4, Nil)	        
// Retorna para Filial de Origem
cFilAnt  := cFilBkp
RETURN

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Mat310Ref  ³ Autor ³Rodrigo A Sartorio   ³ Data ³ 27/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua o refresh do tree selecionado                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Mat310Ref(ExpO1,ExpN1,Exp02,ExpA1,ExpC1)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto tree utilizado                              ³±±
±±³          ³ ExpN1 = Identifica se apresenta por produto ou por armazem ³±±
±±³          ³ ExpO2 = Objeto SAY utilizado                               ³±±
±±³          ³ ExpA1 = Array com dados do tree                            ³±±
±±³          ³ ExpC1 = Picture utilizada para apresentar quantidade       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mat310Ref(oTree,nTipoQuebra,oSay01,oSay02,oSay03,oSay04,aDados,cPictQtd,aParam310)
Local cCargo  	:=oTree:GetCargo()
Local cProduto	:=SubStr(cCargo,If(nTipoQuebra==1,FWGETTAMFILIAL+2,FWGETTAMFILIAL+2+TamSx3("B2_LOCAL")[1]),Len(SB2->B2_COD))
Local nRecno  	:=Val(Right(cCargo,10))
Local nAcho  	:=0
Local cQtdAtu 	:=""
Local cQtdDisp	:=""
Local cQtdAtu2	:=""
Local cQtdDisp2	:=""
Local cTexto01 	:=""
Local cTexto02 	:=""
Local cTexto03 	:=""
Local cTexto04  :=""
Local cDescri 	:=""
// Procura dado com base no registro
SB1->(dbSetOrder(1))
If SB1->(MsSeek(xFilial("SB1")+cProduto))
	cDescri := SubStr(SB1->B1_DESC,1,30)
EndIf
If Substr(cCargo,1,1) == "3"
	nAcho:=Ascan(aDados,{ |x| x[1] == nRecno})
	If nAcho > 0
		cQtdAtu  :=Transform(aDados[nAcho,2],cPictQtd)
		cQtdDisp :=Transform(aDados[nAcho,3],cPictQtd)
		cQtdAtu2 :=Transform(aDados[nAcho,4],cPictQtd)
		cQtdDisp2:=Transform(aDados[nAcho,5],cPictQtd)		
		If aParam310[21] == 1 // Mostrar descrição do produto
			cTexto01 :=STR0022+AllTrim(cProduto)	// Produto
			cTexto02 :=STR0054+AllTrim(cDescri)		// Descricao
			cTexto03 :=STR0028+cQtdDisp				// Qtd disponivel
			cTexto04 :=STR0029+cQtdAtu 				// Qtd total
		Else
			cTexto01 :=STR0022+AllTrim(cProduto)	// Produto
			cTexto02 :=STR0028+cQtdDisp				// Qtd disponivel
			cTexto03 :=STR0029+cQtdAtu 				// Qtd total
			cTexto04 :=' '
		EndIf
	EndIf
Else
	If aParam310[21] == 1 // Mostrar descrição do produto
		cTexto01 :=STR0022+AllTrim(cProduto) // Produto
		cTexto02 :=STR0054+AllTrim(cDescri)  // Descricao
	Else
		cTexto01 :=STR0022+AllTrim(cProduto) // Produto
		cTexto02 := ' '
	EndIf	
EndIf
If Empty(cDescri)
	cTexto01 := STR0018 //"Dados da filial/armazem destino." 
	cTexto02 := ""
Endif
// Muda texto
oSay01:SetText(cTexto01)
oSay01:Refresh()
oSay02:SetText(cTexto02)
oSay02:Refresh()
oSay03:SetText(cTexto03)
oSay03:Refresh()
oSay04:SetText(cTexto04)
oSay04:Refresh()
RETURN

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A310Lista  ³ Autor ³Rodrigo A Sartorio   ³ Data ³ 28/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apresenta dados para transferencia entre filiais           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ A310Lista(ExpA1,ExpC1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os dados das transferencias              ³±±
±±³          ³ ExpC1 = Picture utilizada para apresentar quantidade       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A310Lista(aDadosTransf,cPictQtd)
LOCAL oDlg
LOCAL oQual
LOCAL cVar      := ""
LOCAL aSize     := MsAdvSize(.F.)
LOCAL aPosObj   := {}
LOCAL aObjects  := {}

// Se existirem informacoes para a consulta apresenta os dados
If Len(aDadosTransf) > 0
	// Verifica posicionamento dos objetos
	AAdd(aObjects,{100,100,.T.,.T.,.T.})
	AAdd(aObjects,{100,30 ,.T.,.F.})
	aInfo:={aSize[1],aSize[2],aSize[3],aSize[4],3,2}
	aPosObj:=MsObjSize(aInfo,aObjects)
	// Monta dialog
	DEFINE MSDIALOG oDlg TITLE STR0030 From aSize[7],00 To  aSize[6],aSize[5] OF oMainWnd PIXEL //"Dados para transferencias"
	@ aPosObj[1][1],aPosObj[1][2]  LISTBOX oQual VAR cVar Fields HEADER STR0031,"Produto origem",STR0032,STR0033,STR0027,STR0034,"Produto destino",STR0035,STR0077,STR0078,STR0079,STR0080 SIZE aPosObj[1][3],aPosObj[1][4] PIXEL //"Filial origem"###"Produto origem"###"Armazem origem"###"Quantidade origem"###"Quantidade 2a UM"###"Filial destino"###"Produto destino"###"Armazem destino"###Lote###SubLote###Endereco###Num. Série
	oQual:SetArray(aDadosTransf)
	oQual:bLine := { || {aDadosTransf[oQual:nAT][1],aDadosTransf[oQual:nAT][2],aDadosTransf[oQual:nAT][3],;
				Transform(aDadosTransf[oQual:nAT][4],cPictQtd),Transform(aDadosTransf[oQual:nAT][5],cPictQtd),;
				aDadosTransf[oQual:nAT][6],aDadosTransf[oQual:nAT][25],aDadosTransf[oQual:nAT][7],aDadosTransf[oQual:nAT][17],;
				aDadosTransf[oQual:nAT][18],aDadosTransf[oQual:nAT][20],aDadosTransf[oQual:nAT][21]}} 
	DEFINE SBUTTON FROM aPosObj[2][1]+10,aPosObj[2][4]-28 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
Else
	Help(" ",1,"A310NODATA")
EndIf
RETURN

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A310TOk    ³ Autor ³Rodrigo A Sartorio   ³ Data ³ 28/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a validacao da transferencia sugerida               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ A310TOk(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpA1,ExpA2,ExpC6,   ³±±
±±³          ³         ExpC7,ExpC8,ExpC9,ExpN1)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da filial origem da transferencia           ³±±
±±³          ³ ExpC2 = Codigo do produto da transferencia                 ³±±
±±³          ³ ExpC3 = Codigo do armazem origem da transferencia          ³±±
±±³          ³ ExpC4 = Codigo da filial destino da transferencia          ³±±
±±³          ³ ExpC5 = Codigo do armazem destino da transferencia         ³±±
±±³          ³ ExpA1 = Array com dados das filiais da empresa corrente    ³±±
±±³          ³ ExpA2 = Array com parametros configurados                  ³±±
±±³          ³ ExpC6 = Codigo do cliente                                  ³±±
±±³          ³ ExpC7 = Loja do cliente                                    ³±±
±±³          ³ ExpC8 = Codigo do fornecedor                               ³±±
±±³          ³ ExpC9 = Loja do fornecedor                                 ³±±
±±³          ³ ExpN1 = Quantidade a ser transferida                       ³±±
±±³          ³ ExpN2 = Quantidade 2UM a ser transferida                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A310TOk(cFilOrig,cProduto1,cLocOrig,cFilDest,cLocDest,aFiliais,aParam310,cCliente,cLojaCli,cFornece,cLojaFornece,nQuant,nQuant2UM)
Local lRet		 := .T.
Local cFilOri	 := cFilAnt
Local nAcho 	 := ASCAN(aFiliais,{|x| x[1] == cFilOrig})
Local nAcho2	 := ASCAN(aFiliais,{|x| x[1] == cFilDest})
Local lA310Fil   := AllTrim(SuperGetMv("MV_A310FIL",.F.,"N")) == "S"
Local lRetPE     := .T.
Local lPoder3    := aParam310[19]==1
Local lUsaFilTrf := UsaFilTrf()
Local lTranCQ    := IsTranCQ()
Local cArqIdx    := "" 
Local cCQOrig    := "" 
Local cCQDest    := "" 
Local cSeekD7    := ""
Local cMvCQ		:= GetMvNNR('MV_CQ','98')
Local nIndex     := 0
Local cFilAntBkp := cFilAnt


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a permissao do armazem origem na filial origem. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := lRet .AND. MaAvalPerm(3,{cLocOrig,cProduto1})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a permissao do armazem destino na filial destino.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAnt := cFilDest
lRet 	:= lRet .AND. MaAvalPerm(3,{cLocDest,cProduto1})
cFilAnt := cFilAntBkp

If lRet .And. Empty(nQuant)
	lRet:=.F.
	// Não é permitido a confirmação com o campo de quantidade zerado
	Help(" ",1,"A310QTD")	
EndIf

If lRet .And. lA310Fil
	// Nao permite origem e destino identicos e armazem origem e destino identicos
	If cFilOrig == cFilDest .And. cLocOrig == cLocDest
		// A transferencia entre filiais so deve ser feita para armazens origem e destino diferentes
		Aviso("A310AMZ",STR0059,{"Ok"}) //"A transferencia entre filiais so devera ser feita para Armazens origem e destino diferentes"
		lRet:=.F.
	EndIf	
Else
	// Nao permite origem e destino identicos
	If cFilOrig == cFilDest
		// A transferencia entre filiais so deve ser feita para filiais origem e destino diferentes
		Help(" ",1,"A310FIL")
		lRet:=.F.
	EndIf	
EndIf
// Valida dados da filial destino no cadastro da filial origem
If lRet .And. nAcho > 0 .And. nAcho2 > 0

	cFilAnt:=cFilOrig
	cCQOrig:=cMvCQ 	// Recupera o armazem de CQ da Filial de Origem

	cFilAnt:=aFiliais[nAcho,1]
	cCQDest:=cMvCQ 	// Recupera o armazem de CQ da Filial de Destino

	dbSelectArea("SA1")
	
	If lUsaFilTrf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta filtro e indice temporario na SA1 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArqIdx := CriaTrab(,.F.)
		IndRegua("SA1", cArqIdx, "A1_FILIAL+A1_FILTRF",,,STR0076) //"Selecionando Registros ..."
		nIndex := RetIndex("SA1")
		dbSetOrder(nIndex+1) // A1_FILIAL+A1_FILTRF
	Else
		dbSetOrder(3)
	EndIf
	
	If !lPoder3
		If !dbSeek(xFilial("SA1")+IIF(!lUsaFilTrf, Substr(aFiliais[nAcho2,3],1,Len(SA1->A1_CGC)), Substr(aFiliais[nAcho2,1],1,Len(SA1->A1_FILIAL))))
			// Nao existem dados da filial destino cadastrados como cliente na filial origem. A transferencia nao sera realizada
			Help(" ",1,"A310DATFL1")
			lRet:=.F.
		Else
			If !CliForOrig('SA1', @cCliente, @cLojaCli, lUsaFilTrf)
				// Os registros da filial destino estão bloqueados para uso.
				Help(" ",1,"A310CLIBLQ")
				lRet:=.F.
			EndIf
		EndIf
		
		// Apagar o indice temporario
		If lUsaFilTrf
			dbSelectArea("SA1")
			RetIndex("SA1")
			Ferase( cArqIdx + OrdBagExt() )
		EndIf
	EndIf
	
	// Somente permitir a transferencia do armazem de CQ quando a origem e destino forem CQ
	If lRet .And. lTranCQ
		If AllTrim(cCQOrig)==AllTrim(cLocOrig) .Or.;
		AllTrim(cCQDest)==AllTrim(cLocDest)
			If !(AllTrim(cCQOrig)==AllTrim(cLocOrig) .And.;
				AllTrim(cCQDest)==AllTrim(cLocDest))
				Help(" ",1,"A310NOCQ")
				lRet:=.F.
			EndIf	
		EndIf
	EndIf
	
	// Valida TES de saida na filial origem
	If lRet .And. !lTesIntSai
		SF4->(dbSetOrder(1))
		lRet:=SF4->(MsSeek(xFilial("SF4")+aParam310[13]))
		If !lRet
			// Nao existe a TES de saida na filial origem
			Help(" ",1,"A310TESSAI")
		EndIf
	EndIf
	// Valida condicao de pagamento na filial origem
	If lRet
		SE4->(dbSetOrder(1))
		lRet:=SE4->(MsSeek(xFilial("SE4")+aParam310[16]))
		If !lRet
			// Nao existe a condicao de pagamento na filial origem
			Help(" ",1,"A310CONSAI")
		EndIf
	EndIf
EndIf
// Valida dados da filial origem no cadastro da filial destino
If lRet .And. nAcho > 0 .And. nAcho2 > 0

	cFilAnt:=aFiliais[nAcho2,1]
	
	// Valida e obtem fornecedor e loja da filial origem
	A310VlForn(cFilOrig,cFilDest,@cFornece,@cLojaFornece,lPoder3)

	// Valida TES de entrada na filial destino
	If aParam310[14] == 2
		If lRet .And. !lTesIntEnt
			SF4->(dbSetOrder(1))
			lRet:=SF4->(MsSeek(xFilial("SF4")+aparam310[15]))
			If !lRet
				// Nao existe a TES de entrada na filial destino
				Help(" ",1,"A310TESENT")
			EndIf
		EndIf
	EndIf
	// Valida condicao de pagamento na filial destino
	If lRet
		SE4->(dbSetOrder(1))
		lRet:=SE4->(MsSeek(xFilial("SE4")+aParam310[16]))
		If !lRet
			// Nao existe a condicao de pagamento na filial destino
			Help(" ",1,"A310CONENT")
		EndIf
	EndIf
EndIf
// Valida Relacionamento CQ
If lRet .And. lTranCQ .And. AllTrim(cLocOrig)==AllTrim(cCQOrig)
	If Type('cNumSeqCQ')=='C' .And. Empty(cNumSeqCQ)
		Help(" ",1,"A310CQRELA")
		lRet := .F.
	EndIf
EndIf
// Valida Lote/SubLote do CQ
If lRet .And. lTranCQ .And. (Type('cNumSeqCQ')=='C' .And. !Empty(cNumSeqCQ))
	If AllTrim(cLocOrig)==AllTrim(cCQOrig)
		dbSelectArea("SD7")
		dbsetorder(3)
		If MsSeek(cSeekD7:=xFilial("SD7")+cProduto1+cNumSeqCQ)
			Do While !Eof() .And. cSeekD7==D7_FILIAL+D7_PRODUTO+D7_NUMSEQ
				If AllTrim(D7_LOCAL)==AllTrim(cCQOrig) .And. D7_TIPO==2 .And. D7_ESTORNO <> 'S'
					If !(Alltrim(D7_LOTECT+D7_NUMLOTE)==AllTrim(cLoteDigi+cNumLote))
						Help(" ",1,"A310NOLOTE")
						lRet := .F.
					EndIf
				EndIf
				dbSkip()
			EndDo
		EndIf			
	EndIf 
EndIf

If lRet .And. ExistBlock("M310TUDOK")
	lRet := If(ValType(lRetPE:=ExecBlock("M310TUDOK",.F.,.F.,{nQuant,cFilOrig,cProduto1,cLocOrig,cFilDest,cLocDest,nQuant2UM}))=="L",lRetPE,lRet)
Endif

// Restaura filial original
cFilAnt:=cFilOri


RETURN lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mt310Inf  ³ Autor ³Rodrigo de A Sartorio  ³ Data ³ 03/11/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Legenda do tree das transferencias                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA310                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mt310Inf()
Local oDlg,oBmp1,oBmp2,oBmp3
Local oBut1
DEFINE MSDIALOG oDlg TITLE STR0007 OF oMainWnd PIXEL FROM 0,0 TO 200,550 //"Legenda"
@ 2,3 TO 080,273 LABEL STR0036 PIXEL  //"Simbolos"
@ 18,10 BITMAP oBmp1 RESNAME "PREDIO" SIZE 16,16 NOBORDER PIXEL
@ 18,30 SAY OemToAnsi(STR0011) OF oDlg PIXEL  //"Filial"
@ 18,150 BITMAP oBmp2 RESNAME "PMSTASK1" SIZE 16,16 NOBORDER PIXEL
@ 18,170 SAY OemToAnsi(STR0002) OF oDlg PIXEL  //"Produto"
@ 30,10 BITMAP oBmp3 RESNAME "ARMAZEM" SIZE 16,16 NOBORDER PIXEL
@ 30,30 SAY OemToAnsi(STR0025) OF oDlg PIXEL  //"Armazem"
DEFINE SBUTTON oBut1 FROM 085,244 TYPE 1  ACTION (oDlg:End())  ENABLE of oDlg
ACTIVATE MSDIALOG oDlg CENTERED
Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ CA310Troca                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Rodrigo de Almeida Sartorio              ³ Data ³ 03/11/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Troca marcador entre x e branco                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³nIt        Linha onde o click do mouse ocorreu              ³±±
±±³           ³aArray     Array com as opcoes para selecao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CA310Troca(nIt,aArray)
aArray[nIt,1] := !aArray[nIt,1]
Return aArray

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ A310Proc                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Rodrigo de Almeida Sartorio              ³ Data ³ 16/11/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Processa transferencia                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³aDadosTransf Array com dados para transferencia             ³±±
±±³           ³aParam310    Array com as perguntas selecionadas            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A310Proc(aDadosTransf,aParam310,aSeries,aNotasTransf)
// Variavel com a filial origem
Local cFilOri      := cFilAnt
// Array com os parametros do programa
Local aParam460:=Array(30)
Local cPedido   := ""
Local cWhile    := ""
Local cSerie    := ""
Local cNotaFeita:= ""
Local cPedidos  := ""
Local cSeekD1   := ""
Local cLocalCQ  := ""
Local cChavSA2  := ""
Local cMvCQ		:= GetMvNNR('MV_CQ','98')
Local aCabec    := {}
Local aItens    := {}
Local aPvlNfs   := {}
Local aBloqueio := {{"","","","","","","",""}}
Local aNotas    := {}
Local aDadosAux := {}
Local nItemNf   := 0
Local nSaveSX8  := 0
Local nAchoSerie:= 0
Local nPrcVen   := 0
Local nPosDAux  := 0
Local nBloqueio := 0
Local ni        := 1
Local nx        := 1
Local nW		:= 1
Local nW1		:= 1
Local nOpc      := 0
//Local aSeries   :={}
Local nTamSD2	:= TamSX3("D2_DOC")[1]
Local lRegTransf:= IsInCallStack("MATA311") .Or. ( Type("cOpId311") == "C" .And. cOpId311 == OP_EFE ) //-- Verifica se veio da rotina de registro de transferência
Local lTranCQ   := IsTranCQ()
Local lContinua := .T.
Local lPergunte := .T.
Local lRet := .T.

// Array com notas geradas
Local aNotaFeita:= {}

// Variaveis para rotina automatica
Local lMostraErro   := .F.
Local lReferencia   := .F.
Local cGrade        := "N"
Local aColsAux      := { }
Local nItGrd        := 0
Local nGrdItem      := 0
Local c311FilDes    := ""
// Verifica se existe ponto para manipulacao de itens
Local lExecItens:=ExistBlock("M310ITENS")           
Local aBackItens:={}
Local lExecCabec:=ExistBlock("M310CABEC")
Local aBackCabec:={}
Local lM310PERG :=ExistBlock("M310PERG")
Local uPergunte
Local lMTA310OK :=ExistBlock("MTA310OK")
Local aRetCFF	  :={}
Local aDadosTRF :={}
Local nQtFIFO   := 0
Local nBsStOri := 0
Local nVlStOri := 0
Local nBsStEnt := 0
Local nVlStEnt := 0
Local nAlqIcm := 0
Local lIntMNT := ( AllTrim(SuperGetMV("MV_NGMNTES", .F., "N")) == "S" ) // Usa Integração com Estoque?
Local nPosImp := 0
Local aImpNota:= {}
Local nLenDados := 0
Local l311NumPed:= NNT->(FieldPos('NNT_NUMPED')) > 0 .And. "5" $ GetSX3Cache("NNS_STATUS","X3_VALID") .And. Type('l311GerPed') == "L"
Local lM310PPed := ExistBlock("M310PPED")

//Array com notas geradas e filial destino
Default aNotasTransf := {}
Default aSeries := {}

Private lMsErroAuto := .F.
Private cNumero     := ""
// Variavel utilizada para verificar se o numero da nota foi alterado pelo usuario (notas de saida e entrada
// com formulario proprio).
Private lMudouNum := .F.
// Variavel utilizada para tratamento especifico para poder de terceiros
Private l310PODER3:= aParam310[19] == 1
Private c310FilMov:=""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                               ³
//³ mv_par01        // De  Produto                                     ³
//³ mv_par02        // Ate Produto                                     ³
//³ mv_par03        // De  filial                                      ³
//³ mv_par04        // Ate filial                                      ³
//³ mv_par05        // De  Armazem                                     ³
//³ mv_par06        // Ate Armazem                                     ³
//³ mv_par07        // De  Tipo                                        ³
//³ mv_par08        // Ate Tipo                                        ³
//³ mv_par09        // De  Grupo                                       ³
//³ mv_par10        // Ate Grupo                                       ³
//³ mv_par11        // Filtra Categorias  1 Sim  2 Nao                 ³
//³ mv_par12        // Quebra informacoes 1 Por produto 2 Por Armazem  ³
//³ mv_par13        // Codigo da TES utilizada nas NFs de saida        ³
//³ mv_par14        // Indica como deve gerar o documento              ³
//³ mv_par15        // Codigo da TES utilizada nas NFs de entrada      ³
//³ mv_par16        // Codigo da condicao de pagamento                 ³
//³ mv_par17        // Sugere preco 1 Tab 2 Custo STD 3 Ult Pr 4 CM    ³
//³ mv_par18        // Dados origem - somente filial corrente / todas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Ajusta array aDadosTransf para transferencia de armazem de terceiros
If l310PODER3
	aDadosTransf := A310Terc(aClone(aDadosTransf))
EndIf	

// Array com dados para transferencia
// [01] Filial  origem
// [02] Produto origem
// [03] Armazem origem
// [04] Quantidade origem
// [05] Quantidade origem 2a UM
// [06] Filial  destino
// [07] Armazem destino
// [08] Cliente na Origem
// [09] Loja na Origem
// [10] Fornecedor no destino
// [11] Loja no destino
// [12] Documento na origem
// [13] Serie do documento na origem
// [14] Identificados Poder 3
// [15] Cliente/Fornecedor Poder 3
// [16] Loja Poder 3
// [17] Lote Origem
// [18] Sub-Lote Origem
// [19] Data de Validade
// [20] Endereço
// [21] Numero de Serie

// Verifica se o array esta vazio
If Empty(aDadosTransf)
	Aviso("SEMDADOS",STR0067,{"Ok"}) //"Não existe nenhuma tranferencia de materiais pendente a ser executada."
	lContinua := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³P.E para validar a execução das transferências. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. lMTA310OK
	lContinua := ExecBlock("MTA310OK",.F.,.F.,{aClone(aDadosTransf)})
	If ValType(lContinua) != "L"
		lContinua := .F.
	EndIf
EndIf

// Varre array para efetuar gravacoes
If lContinua .And. Empty(aSeries)
	// Sorteia array para aglutinar por filial origem e destino
	ASORT(aDadosTransf,,,{|x,y| x[1]+x[6]+x[2]+x[3] < y[1]+y[6]+y[2]+y[3] })
	For nx :=1 to Len(aDadosTransf)
		lNSelSerie := .F.
		If nx == 1 .Or. (aDadosTransf[nx,1] # aDadosTransf[nx-1,1])
			// Atualiza para a filial origem
			cFilant:=aDadosTransf[nx,1]
			// Obtem serie para as notas desta filial
			cSerie  := ""
			cNumero := ""
			lContinua:=Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS"),cFilAnt)
			// Caso tenha selecionado numero
			If !lContinua .or. Empty(cNumero)
				// A filial XX nao teve uma serie de nota fiscal de saida selecionada para geracao
				//Help(" ",1,"A310SERERR",,cFilAnt,1,10)
			   	lContinua :=.F.
			   	If Empty(cNumero)
			   		lNSelSerie := .T.
			   	EndIf
			   	Exit
			Else
				AADD(aSeries,{cFilAnt,cSerie,cNumero})
			EndIf
		EndIf
	Next nx
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. M310PERG - Utilizado para visualizar ou não o grupo de  ³
//| perguntas MT460A.                                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lM310PERG
	uPergunte := ExecBlock("M310PERG",.F.,.T.)
	If ValType(uPergunte) == "L"
		lPergunte := uPergunte
	EndIf
EndIf

Pergunte("MT460A",lPergunte)

If mv_par16 == 2 .and. !ExistBlock("M461IMPF",,.T.)
	Help(NIL, NIL, STR0123, NIL, STR0121, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0122})
	lContinua := .F.
EndIf

// Processamento das Transferencias
If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta regua de processamento                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcRegua(Len(aDadosTransf)*2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa geracao de documentos de saida                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega parametros do programa                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nx := 1 to 30
		aParam460[nx] := &("mv_par"+StrZero(nx,2))
	Next nx
	// Sorteia array para aglutinar por filial origem e destino
	ASORT(aDadosTransf,,,{|x,y| x[1]+x[6]+x[2]+x[3] < y[1]+y[6]+y[2]+y[3] })
	// Varre array para efetuar gravacoes
	While (ni <= Len(aDadosTransf))
		
		// Variavel para rotina automatica
		lMsErroAuto := .F.
		// Array auxiliar
		aDadosAux   := {}
		// Atualiza para a filial origem
		cFilant:=aDadosTransf[ni,1]
		// Armazena o código da filial destino
		c311FilDes := aDadosTransf[ni,6]
		// Array para geracao de notas
		aNotas   := {}
		// Arrays com itens e bloqueios
		aPvlNfs  := {}
		aBloqueio:= {}
		nOpc 	 := 2
		// Cabecalho do pedido
		aCabec   := {}
		// Itens do pedido
		aItens   := {}
		// Variavel que controla numeracao
		nSaveSX8 := GetSx8Len()
		// Tratamento para Cliente/Fornecedor que utilizam PODER3
		If l310PODER3
			// Troca Cliente/Fornecedor
			aDadosTransf[ni,08] := aDadosTransf[ni,15]
			// Troca Loja
			aDadosTransf[ni,09] := aDadosTransf[ni,16]
		EndIf	
		// Variavel para processamento
		If l310PODER3
			cWhile:=aDadosTransf[ni,1]+aDadosTransf[ni,6]+aDadosTransf[ni,08]+aDadosTransf[ni,09]
		Else
			cWhile:=aDadosTransf[ni,1]+aDadosTransf[ni,6]
		EndIf	
		// Obtem serie para as notas desta filial
		nAchoSerie:=ASCAN(aSeries,{|x| x[1] == cFilAnt})
		// Caso tenha selecionado serie para esta filial
		If nAchoSerie > 0
			// Atualiza para a filial destino
			cFilant:=aDadosTransf[ni,6]
			// Verifica se Numero e serie já foram cadastrados
			dbSelectArea("SF1")
			dbSetOrder(1)
			If MsSeek(xFilial("SF1")+aSeries[nAchoSerie,3]+aSeries[nAchoSerie,2]+aDadosTransf[ni,10]+aDadosTransf[ni,11])
				Aviso(STR0037,STR0042,{"Ok"}) //"A numeração informada para esta transferencia já possui um documento registrado com a mesma numeração, favor informar uma nova numeração. "
				Exit
			EndIf
			// Atualiza para a filial origem
			cFilant:=aDadosTransf[ni,1]
			// Serie para geracao da nota
			cSerie:=aSeries[nAchoSerie,2]
			//Codigo Armazem de CQ
			cLocalCQ := cMvCQ
			// Cabecalho do pedido
			cPedido := GetSxeNum("SC5","C5_NUM")
			RollBAckSx8()
			aadd(aCabec,{"C5_NUM",cPedido,Nil})
			If l310PODER3
				aadd(aCabec,{"C5_TIPO"	,"B",Nil})
			Else
				aadd(aCabec,{"C5_TIPO"	,"N",Nil})
			EndIf	
			aadd(aCabec,{"C5_CLIENTE",aDadosTransf[ni,8],Nil})
			aadd(aCabec,{"C5_LOJACLI",aDadosTransf[ni,9],Nil})
			aadd(aCabec,{"C5_LOJAENT",aDadosTransf[ni,9],Nil})
			If lRegTransf
				SA1->(DbSetOrder(1))
				If SA1->(DbSeek(xFilial("SA1")+aDadosTransf[ni,8]+aDadosTransf[ni,9]))
					aadd(aCabec,{"C5_CONDPAG",SA1->A1_COND,Nil})
				Endif
			Else
				aadd(aCabec,{"C5_CONDPAG",aParam310[16],Nil})
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para ALTERAR os dados do cabecalho do pedido de vendas  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lExecCabec
				aBackCabec:=ACLONE(aCabec)
				aCabec:=ExecBlock("M310CABEC",.F.,.F.,{"MATA410",aCabec,aParam310})
				If ValType(aCabec) # "A"
					aCabec:=ACLONE(aBackCabec)
				EndIf
			EndIf
			// Contador dos itens
			cC6_ITEM := Strzero(0, TamSX3("C6_ITEM")[1])
			cC6_ITGR := Strzero(0, TamSX3("C6_ITEMGRD")[1])
			// ATENCAO - VARIAVEL CRIADAS POR CAUSA DA QUEBRA NO FATURAMENTO
			aNotaFeita:={}
			aImpNota := {}
			While (ni <= Len(aDadosTransf)) .And. (aDadosTransf[ni,1]+aDadosTransf[ni,6]+aDadosTransf[ni,15]+aDadosTransf[ni,16] == cWhile)
				// Incrementa regua de processamento
				IncProc()
				aLinha := {}
				cGrade :="N"
				// Quando utilizado poder de terceiros obtem preco de venda da nota de remessa 
				If l310PODER3
					SB6->(dbSetOrder(3))
					If SB6->(dbSeek(xFilial("SB6")+aDadosTransf[ni,14]+aDadosTransf[ni,2]+"R"))
						dbSelectArea("SD1")
						dbSetOrder(2)
						If dbSeek(cSeekD1:=xFilial("SD1")+aDadosTransf[ni,2]+SB6->(B6_DOC+B6_SERIE+B6_CLIFOR+B6_LOJA))
							Do While !Eof() .And. cSeekD1 == D1_FILIAL+D1_COD+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
								If aDadosTransf[ni,14] == SD1->D1_IDENTB6
									nPrcVen := SD1->D1_VUNIT
									Exit
								EndIf
								dbSkip()
							EndDo
						EndIf
					EndIf
				// Obtem preco de venda do produto
				Else
					If aParam310[17] == 1
						SA1->(dbSetOrder(1))
						SA1->(dbSeek(xFilial("SA1")+aDadosTransf[ni,8]+aDadosTransf[ni,9]))
						nPrcVen := MaTabPrVen(SA1->A1_TABELA,aDadosTransf[ni,2],aDadosTransf[ni,4],aDadosTransf[ni,8],aDadosTransf[ni,9],1,dDataBase)
					// Obtem preco - custo standard
					ElseIf aParam310[17] == 2
						If RetArqProd(aDadosTransf[ni,2])
							nPrcVen := Posicione("SB1",1,xFilial("SB1")+aDadosTransf[ni,2],"B1_CUSTD")
						Else
						    SB1->(dbSetOrder(1))
						    SB1->(dbSeek(xFilial("SB1")+aDadosTransf[ni,2]))
							nPrcVen := RetFldProd(SB1->B1_COD,"B1_CUSTD")
						EndIf
					// Obtem preco - ultimo preco de compra
					ElseIf aParam310[17] == 3
						If RetArqProd(aDadosTransf[ni,2])
							nPrcVen := Posicione("SB1",1,xFilial("SB1")+aDadosTransf[ni,2],"B1_UPRC")
						Else
						    SB1->(dbSetOrder(1))
						    SB1->(MsSeek(xFilial("SB1")+aDadosTransf[ni,2]))
							nPrcVen := RetFldProd(SB1->B1_COD,"B1_UPRC")
						EndIf	
					// Obtem preco - custo medio unitario do armazem
					ElseIf aParam310[17] == 4
						SB2->(dbSetOrder(1))
						If SB2->(MsSeek(xFilial("SB2")+aDadosTransf[ni,2]+aDadosTransf[ni,3]))
							nPrcVen:=SB2->B2_CM1
						EndIf						
					ElseIf aParam310[17] == 5
						If IsFifoOnLine()
							nQtFIFO:=aDadosTransf[ni,4]
							aRetCFF:={}
							SBD->(DbSetOrder(1))
							SBD->(Dbgotop())
							SBD->(dbSeek(xFilial("SBD") + aDadosTransf[ni,2] + aDadosTransf[ni,3] + " "))
							while SBD->(!EOF()) .and. SBD->BD_FILIAL+SBD->BD_PRODUTO+SBD->BD_LOCAL+SBD->BD_STATUS == xFilial("SBD")+aDadosTransf[ni,2] + aDadosTransf[ni,3]+' ' .and. nQtFIFO > 0	 
								If SBD->BD_QFIM  > 0
									nQtFIFO -= SBD->BD_QFIM
									If nQtFIFO >= 0
										aadd(aRetCFF,{SBD->BD_QFIM, SBD->BD_CUSFIM1 / SBD->BD_QFIM}) 
									Else
										nQtFIFO += SBD->BD_QFIM
										aadd(aRetCFF,{nQtFIFO, SBD->BD_CUSFIM1 / SBD->BD_QFIM}) 
										exit
									EndIf 
								EndIf
								SBD->(dbSkip())
							EndDo
						EndIf
					EndIf
				EndIf
				// Senao encontrou nenhum valor assume 1
				If QtdComp(nPrcVen,.T.) == QtdComp(0,.T.)
					nPrcVen := 1
				EndIf
				nLenDados := len(aDadosTransf[ni])
				aDadosTRF:=array(IIf(len(aRetCFF)>0,len(aRetCFF),1),nLenDados+2)
				
				For nW  := 1 to IIf(len(aRetCFF)>0,len(aRetCFF),1)
					For nW1 := 1 to nLenDados
						aDadosTRF[nW,nW1] := aDadosTransf[ni,nW1]
					Next nW1 
				Next nW
				If l310PODER3 .or. aParam310[17] < 5
					aDadosTRF[1,nLenDados + 1]:=nPrcVen
					aDadosTRF[1,nLenDados + 2]:=aDadosTransf[ni,4]
				Else
					For nW := 1 to len(aRetCFF)			
						aDadosTRF[nW,nLenDados + 1]:= aRetCFF[nW,2]
						aDadosTRF[nW,nLenDados + 2]:= aRetCFF[nW,1]								
					Next nW
					If aDadosTRF[1,25] == NIL 
						aDadosTRF[1,nLenDados + 1] := 1
					EndIf
					If aDadosTRF[1,26] == NIL
						aDadosTRF[1,nLenDados + 2]:= 1
					EndIf					
				EndIf
				For nW := 1 to Len(aDadosTRF)
					aLinha:={}
					cProdRef   :=aDadosTRF[nW,2]
					lReferencia:=MatGrdPrrf(@cProdRef,.T.)
					If lReferencia
						nAchou:=AScan(aColsAux,{|x|x[1]==cProdRef.and. x[2]==aDadosTRF[nW,3]})
						If nAchou >0
							cC6_ITEM := AcolsAux[nAchou,3]
							cC6_ITGR := Soma1(cC6_ITGR)
						Else
							cC6_ITEM := Soma1(cC6_ITEM)
							cC6_ITGR := Strzero(1, TamSX3("C6_ITEMGRD")[1])
							aadd(aColsAux,{cProdref,aDadosTRF[nW,3],cC6_ITEM,cC6_ITGR})
						Endif
						cGrade:="S"
					Else
						cC6_ITEM := Soma1(cC6_ITEM)
					EndIf
					aadd(aLinha,{"C6_ITEM"   	,cC6_ITEM								,Nil})
					aadd(aLinha,{"C6_PRODUTO"	,aDadosTRF[nW,2]						,Nil})
					aadd(aLinha,{"C6_LOCAL"  	,aDadosTRF[nW,3]						,Nil})
					aadd(aLinha,{"C6_QTDVEN" 	,aDadosTRF[nW,nLenDados + 2]			,Nil})
					aadd(aLinha,{"C6_PRCVEN"	,A410Arred(aDadosTRF[nW,nLenDados + 1],"C6_PRCVEN"),Nil})
					aadd(aLinha,{"C6_PRUNIT" 	,A410Arred(aDadosTRF[nW,nLenDados + 1],"C6_PRUNIT"),Nil})
					aadd(aLinha,{"C6_VALOR"  	,A410Arred(aDadosTRF[nW,nLenDados + 2] * A410Arred(aDadosTRF[nW,nLenDados + 1],"C6_PRCVEN"),"C6_VALOR"),Nil})
					aadd(aLinha,{"C6_TES"   	,aDadosTRF[nW,23],Nil})
					// Checa se utiliza rastreabilidade por lote
					If Rastro(aDadosTRF[nW,2],"L")
						aadd(aLinha,{"C6_LOTECTL",aDadosTRF[nW,17],Nil})
						aadd(aLinha,{"C6_DTVALID",aDadosTRF[nW,19],Nil})
					EndIf
					// Checa se utiliza rastreabilidade por sublote
					If Rastro(aDadosTRF[nW,2],"S")                          
						aadd(aLinha,{"C6_LOTECTL",aDadosTRF[nW,17],Nil})
				   		aadd(aLinha,{"C6_NUMLOTE",aDadosTRF[nW,18],Nil})
						aadd(aLinha,{"C6_DTVALID",aDadosTRF[nW,19],Nil})
					EndIf         
					// Checa se utiliza localização
					If Localiza(aDadosTRF[nW,2])
						aadd(aLinha,{"C6_NUMSERI",aDadosTRF[nW,21],Nil})
						aadd(aLinha,{"C6_LOCALIZ",aDadosTRF[nW,20],Nil})
					EndIf				
					// Grava Numero Sequencial CQ	
					If lTranCQ .And. AllTrim(cLocalCQ)==AllTrim(aDadosTRF[nW,3])
						aadd(aLinha,{"C6_NRSEQCQ",aDadosTRF[nW,22],Nil})
					EndIf
	
					aadd(aLinha,{"C6_GRADE"		,cGrade									,Nil})
					aadd(aLinha,{"C6_ITEMGRD"	,If(cGrade=="S",cC6_ITGR,Criavar("C6_ITEMGRD", .F.)),Nil})
					// Obtem o Documento/Serie/Itens Originais para a devolucao de poder de terceiros
					If l310PODER3
						SB6->(dbSetOrder(3))
						If SB6->(dbSeek(xFilial("SB6")+aDadosTRF[nW,14]+aDadosTRF[nW,2]+"R"))
							dbSelectArea("SD1")
							dbSetOrder(2)
							If dbSeek(cSeekD1:=xFilial("SD1")+aDadosTRF[nW,2]+SB6->(B6_DOC+B6_SERIE+B6_CLIFOR+B6_LOJA))
								Do While !Eof() .And. cSeekD1 == D1_FILIAL+D1_COD+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
									If aDadosTRF[nW,14] == SD1->D1_IDENTB6
										aadd(aLinha,{"C6_NFORI"		,SD1->D1_DOC	,Nil})
										aadd(aLinha,{"C6_SERIORI"	,SD1->D1_SERIE	,Nil})
										aadd(aLinha,{"C6_ITEMORI"	,SD1->D1_ITEM	,Nil})
										aadd(aLinha,{"C6_IDENTB6"	,SD1->D1_IDENTB6,Nil})
										Exit
									EndIf
									dbSkip()
								EndDo
							EndIf
						EndIf
					EndIf
					aadd(aItens,aLinha)
					aadd(aDadosAux,{cPedido,cC6_ITEM,aDadosTRF[nW,7],aDadosTRF[nW,25]})
				Next nw
				ni++
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para ALTERAR os dados do pedido de vendas   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lExecItens
				aBackItens:=ACLONE(aItens)
				aItens:=ExecBlock("M310ITENS",.F.,.F.,{"MATA410",aItens})
				If ValType(aItens) # "A"
					aItens:=ACLONE(aBackItens)
				EndIf
			EndIf
			// Inclusao do pedido
			MATA410(aCabec,aItens,3)
			// Checa erro de rotina automatica
			If lMsErroAuto
				lMostraErro	:=.T.
			Else
				// Confirma SX8
				While ( GetSx8Len() > nSaveSX8 )
					ConfirmSX8()
				Enddo
	    		If lM310PPed
	    			ExecBlock("M310PPED",.F.,.F.)
	        	EndIf
				// Liberacao de pedido
				Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
				// Checa itens liberados
				Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
				// Caso tenha itens liberados manda faturar
				If Empty(aBloqueio) .And. !Empty(aPvlNfs)
					nItemNf  := a460NumIt(cSerie)
					aadd(aNotas,{})
					// Efetua as quebras de acordo com o numero de itens
					For nX := 1 To Len(aPvlNfs)
						If Len(aNotas[Len(aNotas)])>=nItemNf
							aadd(aNotas,{})
						EndIf
						aadd(aNotas[Len(aNotas)],aClone(aPvlNfs[nX]))
					Next nX

					
					// Gera as notas de acordo com a quebra
					For nX := 1 To Len(aNotas)
						cNotaFeita:=MaPvlNfs(aNotas[nX],cSerie,aParam460[01]==1,aParam460[02]==1,aParam460[03]==1,aParam460[04]==1,aParam460[05]==1,aParam460[07],aParam460[08],aParam460[15]==1,aParam460[16]==2)
						AADD(aNotaFeita,PADR(cNotaFeita,nTamSD2))
						
						If !( Empty( cNotaFeita ) )
							SFT->( dbSetOrder( 1 ) ) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
							If SFT->( dbSeek( FWxFilial( 'SFT' ) + 'S' + SF2->F2_SERIE + SF2->F2_DOC + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
								While !SFT->( Eof() ) .And. SFT->FT_FILIAL == FWxFilial( 'SFT' ) .And. SFT->FT_TIPOMOV == 'S' .And. SFT->FT_SERIE == SF2->F2_SERIE .And. SFT->FT_NFISCAL == SF2->F2_DOC .And. SFT->FT_CLIEFOR == SF2->F2_CLIENTE .And. SFT->FT_LOJA == SF2->F2_LOJA
									Aadd( aImpNota,{ PADR(cNotaFeita,nTamSD2), SFT->FT_ITEM, SFT->FT_PRODUTO, SFT->FT_BSTANT, SFT->FT_PSTANT, SFT->FT_VSTANT, SFT->FT_BFCANTS, SFT->FT_PFCANTS, SFT->FT_VFCANTS } )
									SFT->( dbSkip() )
								EndDo
							EndIf
						EndIf
						
					Next nX
					// Varre notas fiscais de saida geradas para gerar notas fiscais de entrada
					For nx:=1 to Len(aNotaFeita)
					
						//Se houver integração com MNT buscar combustivel para transferencia
						If lIntMnt .And. FindFunction("NGTRANCOMB")
							NGTRANCOMB(aItens[1][2][2],aItens[1][3][2],aItens[1][4][2],aNotaFeita[nX],cSerie)
						EndIf
						
						aColsAux:={}
						nItem	:=0
						nItGrd	:=0
						dbSelectArea("SD2")
						dbSetOrder(3)
						If dbSeek(xFilial("SD2")+PadR(aNotaFeita[nx],TamSX3("D2_DOC")[1])+cSerie+aDadosTransf[ni-1,8]+aDadosTransf[ni-1,9])

							aadd(aNotasTransf,{aDadosTransf[ni-1,6],aNotaFeita[nX],cSerie})
							// Cabecalho da nota fiscal de entrada
							aCabec   := {}
							aadd(aCabec,{"F1_TIPO"   	,"N"})
							aadd(aCabec,{"F1_FORMUL" 	,"N"})
							aadd(aCabec,{"F1_DOC"    	,aNotaFeita[nx]})
							aadd(aCabec,{"F1_SERIE"  	,cSerie})
							aadd(aCabec,{"F1_EMISSAO"	,dDataBase})
							If l310PODER3
								aadd(aCabec,{"F1_FORNECE"	,aDadosTransf[ni-1,08]})
								aadd(aCabec,{"F1_LOJA"   	,aDadosTransf[ni-1,09]})
								cChavSA2 := aDadosTransf[ni-1,08]+aDadosTransf[ni-1,09]
							Else
								aadd(aCabec,{"F1_FORNECE"	,aDadosTransf[ni-1,10]})
								aadd(aCabec,{"F1_LOJA"   	,aDadosTransf[ni-1,11]})
								cChavSA2 := aDadosTransf[ni-1,10]+aDadosTransf[ni-1,11]
							EndIf	
							aadd(aCabec,{"F1_ESPECIE"	,aParam310[20]})
							If lRegTransf
								SA2->(DbSetOrder(1))
								If SA2->(DbSeek(xFilial("SA2")+cChavSA2))
									aadd(aCabec,{"F1_COND"		,SA2->A2_COND})
								Endif
							Else
								aadd(aCabec,{"F1_COND"		,aParam310[16]})
							Endif
							aadd(aCabec,{"F1_EST"		,M310GetUF(aDadosTransf[ni-1],l310PODER3)})      
						    // Carrega dados do Cliente de Origem da Nota Fiscal - UPDEST09 //							
							aadd(aCabec,{"F1_FILORIG", SD2->D2_FILIAL})
							aadd(aCabec,{"F1_CLIORI" , SD2->D2_CLIENTE})
							aadd(aCabec,{"F1_LOJAORI", SD2->D2_LOJA})
							aadd(aCabec,{"F1_TPFRETE", SF2->F2_TPFRETE})
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Ponto de entrada para ALTERAR os dados do cabecalho do Documento Entrada ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lExecCabec
								aBackCabec:=ACLONE(aCabec)
								aCabec:=ExecBlock("M310CABEC",.F.,.F.,{If(aParam310[14] == 1,"MATA140","MATA103"),aCabec,aParam310})
								If ValType(aCabec) # "A"
									aCabec:=ACLONE(aBackCabec)
								EndIf
							EndIf

							// Itens da nota fiscal de entrada
							aItens   := {}
							While !Eof() .And. xFilial("SD2")+aNotaFeita[nx]+cSerie+aDadosTransf[ni-1,8]+aDadosTransf[ni-1,9] == D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA
								// Incrementa regua de processamento
								IncProc()
								cGrade  :="N"
								aLinha  := {}
								cProdRef:=SD2->D2_COD
								lReferencia:=MatGrdPrrf(@cProdRef,.T.)
								nBsStOri := 0
								nVlStOri := 0
								nBsStEnt := 0
								nVlStEnt := 0
								nAlqIcm  := 0
								nPosDAux := 0
								If lReferencia
									nAchou:=AScan(aColsAux,{|x|x[1]==cProdRef.and. x[2]==aDadosTransf[ni-1,7]})
									If nAchou >0
										nItem:=AcolsAux[nAchou,3]
										nItgrd ++
									Else
										nItem++
										nItgrd:=1
										aadd(aColsAux,{cProdRef,aDadosTransf[ni-1,7],nItem,nItGrd})
									Endif
										cGrade:="S"
									If aParam310[14] == 1
										If nGrdItem == 0
											nGrdItem := nItem
										Else
											nItem  := nGrdItem + 1
											nItgrd := nGrdItem + 1
											nGrdItem := nItem
										EndIf
									EndIf
								Else
									nItem++
								Endif
								//-- Variavel para buscar dados do destino (já que variavel ni e consequentemente array aDadosTransf não estão posicionados)
								If !lReferencia
									nPosDAux := Ascan(aDadosAux,{|x| x[1]+x[2] == SD2->(D2_PEDIDO+D2_ITEMPV)})
								EndIf
								
								aadd(aLinha,{"D1_ITEM"	,Strzero(Val(SD2->D2_ITEM),4),Nil})
								If nPosDAux > 0
									aadd(aLinha,{"D1_COD"	,aDadosAux[nPosDAux,4]	,Nil})
									aadd(aLinha,{"D1_LOCAL"	,aDadosAux[nPosDAux,3]	,Nil})
								Else	//-- Item adicionado pelo PE M310ITENS (não tem detalhes do destino no aDadosAux)
									aadd(aLinha,{"D1_COD"	,SD2->D2_COD	,Nil})
									aadd(aLinha,{"D1_LOCAL"	,aDadosTransf[ni-1,7]	,Nil})
								EndIf
								aadd(aLinha,{"D1_UM"    ,SD2->D2_UM,Nil})
								aadd(aLinha,{"D1_QUANT"	,SD2->D2_QUANT,Nil})
								aadd(aLinha,{"D1_VUNIT"	,SD2->D2_PRCVEN,Nil})
								aadd(aLinha,{"D1_TOTAL"	,SD2->D2_TOTAL,Nil})
								
								aadd(aLinha,{"D1_GRADE",cGrade,Nil}) 
								aadd(aLinha,{"D1_ITEMGRD",If(cGrade=="S",Strzero(nItGrd,2)," "),Nil}) 
								// Checa geracao de documento
								cFilAnt:= aDadosTransf[ni-1,6]
								
								If aParam310[14] == 2       // Nota Classificada
									aadd(aLinha,{"D1_TES",aDadosTransf[iif(nItem>len(aDadosTransf),len(aDadosTransf),nItem),24],Nil}) //
								ElseIf aParam310[14] == 1   // Nota a classificar
									aadd(aLinha,{"D1_TESACLA",SubStr(aDadosTransf[iif(nItem>len(aDadosTransf),len(aDadosTransf),nItem), 24 ],1,Len("D1_TESACLA")),Nil})
								Endif		
								// Checa se utiliza rastreabilidade
								If Rastro(SD2->D2_COD)
									If lRegTransf
										aadd(aLinha,{"D1_LOTECTL",aDadosTransf[iif(nItem>len(aDadosTransf),len(aDadosTransf),nItem),26],Nil})
									Else
										aadd(aLinha,{"D1_LOTECTL",SD2->D2_LOTECTL,Nil})
									EndIf
									If Rastro(SD2->D2_COD,"S")                              
										aadd(aLinha,{"D1_NUMLOTE",SD2->D2_NUMLOTE,Nil})
									EndIf
									aadd(aLinha,{"D1_DTVALID",SD2->D2_DTVALID,Nil})
									aadd(aLinha,{"D1_DFABRIC",SD2->D2_DFABRIC,Nil})
								EndIf
								If cPaisLoc == "BRA"
									aadd(aLinha,{"D1_FCICOD",SD2->D2_FCICOD,Nil})
								EndIf
																
								// Tratamento para gravacao dos campos D1_BASNDES e D1_ICMNDES.
								// Mesmo tratamento feito no NFESEFAZ para impressao nas infos. complementares.							

								cFilAnt:= aDadosTransf[ni-1,1]
								nPosImp := Ascan( aImpNota, { | x | Alltrim( x[ 01 ] ) == AllTrim( SD2->D2_DOC ) .And. Alltrim( x[ 02 ] ) == AllTrim( SD2->D2_ITEM ) .And. Alltrim( x[ 03 ] ) == AllTrim( SD2->D2_COD )  } )
								If nPosImp > 0
									If aImpNota[ nPosImp ][ 04 ] > 0
										aAdd( aLinha,{ "D1_BASNDES", aImpNota[ nPosImp ][ 04 ], Nil } )
									EndIf
									If aImpNota[ nPosImp ][ 05 ] > 0
										aAdd( aLinha,{ "D1_ALQNDES", aImpNota[ nPosImp ][ 05 ], Nil } )
									EndIf
									If aImpNota[ nPosImp ][ 06 ] > 0
										aAdd( aLinha,{ "D1_ICMNDES", aImpNota[ nPosImp ][ 06 ], Nil } )
									EndIf
									If aImpNota[ nPosImp ][ 07 ] > 0
										aAdd( aLinha,{ "D1_BFCPANT", aImpNota[ nPosImp ][ 07 ], Nil } )
									EndIf
									If aImpNota[ nPosImp ][ 08 ] > 0
										aAdd( aLinha,{ "D1_AFCPANT", aImpNota[ nPosImp ][ 08 ], Nil } )
									EndIf
									If aImpNota[ nPosImp ][ 09 ] > 0
										aAdd( aLinha,{ "D1_VFCPANT", aImpNota[ nPosImp ][ 09 ], Nil } )
									EndIf
								EndIf

								aAdd(aLinha,{"D1_CLASFIS",SD2->D2_CLASFIS,Nil})
								aAdd(aLinha,{"D1_POTENCI",SD2->D2_POTENCI,Nil})
								aadd(aItens,aLinha)		
								dbSelectArea("SD2")
								dbSkip()
							End
							ASORT(aitens,,,{|x,y| x[1,2] < y[1,2] }) //classifica o aitens por item da sd2

							// Caso tenha itens e cabecalho definidos
							If Len(aItens) > 0 .And. Len(aCabec) > 0
								// Atualiza para a filial destino
								cFilant:=aDadosTransf[ni-1,6]
								// Reinicializa ambiente para o fiscal
								If MaFisFound()
									MaFisEnd()
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Ponto de entrada para ALTERAR os dados do pedido de vendas   ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lExecItens
									aBackItens:=ACLONE(aItens)
									aItens:=ExecBlock("M310ITENS",.F.,.F.,{If(aParam310[14] == 1,"MATA140","MATA103"),aItens})
									If ValType(aItens) # "A"
										aItens:=ACLONE(aBackItens)
									EndIf
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Carrega variavel c310FilMov com a filial de origem do movimento      ³
								//³ Eh necessaria para a geracao do documento de entrada qdo usado poder ³
								//³ de terceiro na funcao A103TrfFil() no MATA103.                       ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If l310PODER3
									c310FilMov := aDadosTransf[ni-1,1]
								EndIf
								// Checa geracao de documento
								If aParam310[14] == 2
									// Inclui nota de entrada
									MATA103(aCabec,aItens,3,If(aParam310[25] == 1,.T.,.F.))
								ElseIf aParam310[14] == 1
									// Inclui pre-nota
									MATA140(aCabec,aItens,3)
								EndIf
								// Checa erro de rotina automatica
								If lMsErroAuto
									lMostraErro	:=.T.
								EndIf
								// Atualiza para a filial origem  
								cFilant:=aDadosTransf[ni-1,1]  

							    // Carrega dados do Fornecedor de Destino da Nota Fiscal - UPDEST09 //
								dbSelectArea("SF2")
								dbSetOrder(1)
								If dbSeek(xFilial("SF2")+PadR(aNotaFeita[nx],TamSX3("D2_DOC")[1])+cSerie+aDadosTransf[ni-1,8]+aDadosTransf[ni-1,9])
								   RecLock("SF2",.F.) 
								   SF2->F2_FILDEST:=aDadosTransf[ni-1,6]   
								   SF2->F2_FORDES :=aDadosTransf[ni-1,iif(l310PODER3,08,10)]
   									SF2->F2_LOJADES:=aDadosTransf[ni-1,iif(l310PODER3,09,11)]
   									SF2->F2_FORMDES:="N"
								   MsUnlock()
								EndIf
							EndIf                               
						EndIf
					Next nx
				Elseif lRegTransf .And. l311NumPed
					For nBloqueio := 1 to Len(aBloqueio)
						AADD(aBloqueio[nBloqueio],c311FilDes) 
						AADD(a311Bloq,aBloqueio[nBloqueio]) 
					Next nBloqueio
				Else
					cPedidos := ""
					For nBloqueio := 1 To Len(aBloqueio)
						If nBloqueio # 1 .And. aBloqueio[nBloqueio,1] == aBloqueio[nBloqueio-1,1] 
							Loop
						EndIf
						cPedidos += aBloqueio[nBloqueio,1]+"/"
					Next nBloqueio
					Aviso(STR0063,STR0064 + SubStr(cPedidos,1,Len(cPedidos)-1) + " " + STR0065,{"Ok"}) //"PV Bloqueado"###"O(s) Pedido de Venda(s) Nro(s) "###" foram bloqueados, por este motivo o processo de Transferencia de Materiais foi cancelado. Para maiores detalhes verificar os pedidos de vendas bloqueados atraves do modulo de Faturamento."
				EndIf
			EndIf
		Else
			// A filial XX nao teve uma serie de nota fiscal de saida selecionada para geracao
			Help(" ",1,"A310SERERR",,cFilAnt,1,10)
			// Variavel para processamento
			cWhile:=aDadosTransf[ni,1]
			// Varre todos os itens com esta filial origem
			While (ni <= Len(aDadosTransf)) .And. aDadosTransf[ni,1] == cWhile
				// Incrementa regua de processamento
				IncProc()
				ni++
			End
		EndIf
	End
	If lRegTransf .And. Len(a311Bloq) > 0
		//Obtém o número dos pedidos de venda gerados na transferência
		cPedidos := ""
		For nBloqueio := 1 To Len(a311Bloq)
			If nBloqueio # 1 .And. a311Bloq[nBloqueio,1] == a311Bloq[nBloqueio-1,1] 
				Loop
			EndIf
		cPedidos += a311Bloq[nBloqueio,1]+"/"
		Next nBloqueio
		
		//Apresenta a tela de bloqueio
		Do while nOpc == 2
			nOpc := Aviso(STR0063,STR0064 + SubStr(cPedidos,1,Len(cPedidos)-1) + " " + STR0105 + Space(200) + STR0106,{STR0109,STR0110,STR0111})
			If nOpc == 2
				MA311Tela(a311Bloq)
			Endif
		EndDo

		//Continua com a gravação caso o usuário escolha continuar com o processo
		If nOpc == 3
			lRet := MsgYesNo(STR0108, STR0063)
			IIF(lRet,l311GerPed := .T.,)
		Else
			lRet := .F.
		EndIf
	EndIf
Else
	lRet := .F.
EndIf
// Limpa conteudo da variavel usada no MATA103
c310FilMov := ""
// Restaura filial original
cFilAnt:=cFilOri
// Mostra erro em rotina automatica
If lMostraErro
	If IsBlind()
		ConOut(Mostraerro())
	Else
		Mostraerro()
	EndIf
	lRet := .F.
EndIf

RETURN lRet
/*exemplo ponto de entrada
User Function M310ITENS
Local cPrograma:=PARAMIXB[1]
Local aItens   :=PARAMIXB[2]
Local nx
Local nz

If cPrograma == "MATA410" // Pedido de venda
// ARRAY AITENS (PADRAO DAS ROTINAS AUTOMATICAS)
// [1]       ITEM 1
// [1][1]    CAMPO 1 DO ITEM 1
// [1][1][1] NOME DO CAMPO
// [1][1][2] CONTEUDO DO CAMPO
// [1][1][3] VALIDACAO A SER UTILIZADA

// Exemplo MUDANDO ARMAZEM
For nx:=1 to Len(aItens)
For nz:=1 to Len(aItens[nx])
If "C6_LOCAL" $ aItens[nx,nz,1]
aItens[nx,nz,2]	:="02"
EndIf
Next nz
Next nx
EndIf
RETURN aItens*/

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A310EstRel ³ Autor ³Nereu Humberto Junior³ Data ³ 11/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Estorna relacionamento origem e destino                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ A310EstRel(ExpO1,Exp02,ExpN1,ExpA1,ExpA2,ExpA3,ExpC1,ExpA4,³±±
±±³          ³ ExpA5)                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto tree1 utilizado                             ³±±
±±³          ³ ExpO2 = Objeto tree2 utilizado                             ³±±
±±³          ³ ExpN1 = Identifica se apresenta por produto ou por armazem ³±±
±±³          ³ ExpA1 = Array com dados do tree de origem                  ³±±
±±³          ³ ExpA2 = Array com dados do tree de destino                 ³±±
±±³          ³ ExpA3 = Array com dados da transferencia                   ³±±
±±³          ³ ExpC1 = Picture utilizada para apresentar quantidade       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A310EstRel(oTree1,oTree2,nTipoQuebra,aDadosOri,aDadosDest,aDadosTransf,cPictQtd,aFiliais,aParam310)
Local oDlg
Local cCargo1:=oTree1:GetCargo()
Local cCargo2:=oTree2:GetCargo()
Local cFilOrig:=SubStr(cCargo1,2,FWGETTAMFILIAL)
Local cFilDest:=SubStr(cCargo2,2,FWGETTAMFILIAL)
Local cProduto1:=SubStr(cCargo1,If(nTipoQuebra==1,FWSIZEFILIAL()+2,FWSIZEFILIAL()+2+TamSx3("B2_LOCAL")[1]),Len(SB2->B2_COD))
Local cProduto2:=SubStr(cCargo2,If(nTipoQuebra==1,FWSIZEFILIAL()+2,FWSIZEFILIAL()+2+TamSx3("B2_LOCAL")[1]),Len(SB2->B2_COD))
Local cLocOrig:=""
Local cLocDest:=""
Local nAcho :=0,nAcho2:=0,nStart:=1,nX:=1
Local nQtdEst:=0,nQtdEst2Um:=0
Local lConfirma:=.F.
Local cQtdDisp :=""
Local cQtdDisp2:=""
Local aPosQtd := {}     
Local nDeletados :=0
Local lIsPrdOK := .T.

lIsPrdOK := A310VldPrd(cFilOrig,cProduto1,cFilDest,cProduto2,aParam310[19]==1)

// Produto origem preenchido e produto destino preenchido
If Substr(cCargo1,1,1) == "3" .And. Substr(cCargo2,1,1) == "3" .And. lIsPrdOK
	// Armazem origem e armazem destino
	cLocOrig:=SubStr(cCargo1,FWSIZEFILIAL()+2+If(nTipoQuebra==1,Len(SB2->B2_COD),0),Len(SB2->B2_LOCAL))
	cLocDest:=SubStr(cCargo2,FWSIZEFILIAL()+2+If(nTipoQuebra==1,Len(SB2->B2_COD),0),Len(SB2->B2_LOCAL))
	
	nAcho  :=Ascan(aDadosOri,{ |x| x[1] == Val(Right(cCargo1,10))})
	nAcho2 :=Ascan(aDadosDest,{ |x| x[1] == Val(Right(cCargo2,10))})
	// Quantidade ja estabelecida relacao     
	nStart:=Ascan(aDadosTransf,{ |x| x[1] == cFilOrig .And. x[2] == cProduto1 .And. x[3] == cLocOrig .And. x[6] == cFilDest .And. x[7] == cLocDest .And. x[25] == cProduto2})
	If nStart > 0
		Do While (nPos := Ascan(aDadosTransf,{ |x| x[1] == cFilOrig .And. x[2] == cProduto1 .And. x[3] == cLocOrig .And. x[6] == cFilDest .And. x[7] == cLocDest .And. x[25] == cProduto2},nStart)) > 0
			If nPos > 0
				nQtdEst    += aDadosTransf[nPos,4]
				nQtdEst2Um += aDadosTransf[nPos,5]						
				Aadd(aPosQtd,{nPos,aDadosTransf[nPos,4],aDadosTransf[nPos,5]})
			EndIf	
			If (nStart := ++nPos) > Len(aDadosTransf)
				Exit
			EndIf
		EndDo
	Endif	
	
	If nAcho > 0 .And. nAcho2 > 0 .And. Len(aPosQtd) > 0
				
		DEFINE MSDIALOG oDlg FROM  140,000 TO 460,680 TITLE OemToAnsi(STR0045) PIXEL	 //"Dados do Estorno"
		@ 036,006 TO 066,320 LABEL OemToAnsi(STR0015)  OF oDlg  PIXEL //"Origem"
		@ 072,006 TO 102,320 LABEL OemToAnsi(STR0016) OF oDlg  PIXEL //"Destino"
		@ 108,006 TO 138,320 LABEL OemToAnsi(STR0044) OF oDlg  PIXEL //"Estorno"
		@ 044,049 MSGET cProduto1	When .F. SIZE 096,09 OF oDlg PIXEL
		@ 044,170 MSGET cFilOrig  	When .F. SIZE 041,09 OF oDlg PIXEL
		@ 044,250 MSGET cLocOrig 	When .F. SIZE 018,09 OF oDlg PIXEL
		@ 079,049 MSGET cProduto2	When .F. SIZE 096,09 OF oDlg PIXEL
		@ 079,170 MSGET cFilDest  	When .F. SIZE 041,09 OF oDlg PIXEL
		@ 079,250 MSGET cLocDest 	When .F. SIZE 018,09 OF oDlg PIXEL
		@ 116,049 MSGET nQtdEst Picture cPictQtd  When .F. SIZE 68,09 OF oDlg PIXEL
		@ 116,170 MSGET nQtdEst2Um Picture cPictQtd  When .F. SIZE 68,09 OF oDlg PIXEL
		@ 046,021 SAY OemtoAnsi(STR0002) SIZE 24,07 OF oDlg PIXEL  //"Produto"
		@ 046,152 SAY OemtoAnsi(STR0011) SIZE 32,13 OF oDlg PIXEL  //"Filial"
		@ 046,218 SAY OemtoAnsi(STR0025) SIZE 35,13 OF oDlg PIXEL  //"Armazem"
		@ 081,021 SAY OemtoAnsi(STR0002) SIZE 24,07 OF oDlg PIXEL  //"Produto"
		@ 081,152 SAY OemtoAnsi(STR0011) SIZE 32,13 OF oDlg PIXEL  //"Filial"
		@ 081,218 SAY OemtoAnsi(STR0025) SIZE 35,13 OF oDlg PIXEL  //"Armazem"
		@ 118,019 SAY OemToAnsi(STR0026) SIZE 30,16 OF oDlg PIXEL //"Quantidade"
		@ 118,140 SAY OemToAnsi(STR0027) SIZE 30,16 OF oDlg PIXEL //"Quantidade 2a UM"
		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||If(MsgYesNo(OemToAnsi(STR0046),OemToAnsi(STR0037)),(lConfirma:=.T.,oDlg:End()),lConfirma:=.F.)},{||oDlg:End()}) //"Deseja realmente estornar a relação origem x destino ?"
		// Caso confirmado coloca na lista de transferencias e retira o saldo da origem
		If lConfirma		
        	If ExistBlock("M310ESTO")
	    		ExecBlock("M310ESTO",.F.,.F.,{cProduto1, cFilOrig, cLocOrig, cProduto2,cFilDest, cLocDest, nQtdEst})
	        EndIf			
		    For nX := 1 To Len(aPosQtd)
				aDadosTransf[aPosQtd[nX,1]-nDeletados,4] -= aPosQtd[nX,2]
				aDadosTransf[aPosQtd[nX,1]-nDeletados,5] -= aPosQtd[nX,3]
				//Se quantidade zerada exclui da lista de transferencia
				If aDadosTransf[aPosQtd[nX,1]-nDeletados,4] == 0 .And. aDadosTransf[aPosQtd[nX,1]-nDeletados,5] == 0
					aDel(aDadosTransf, aPosQtd[nX,1]-nDeletados)
					aSize(aDadosTransf, Len(aDadosTransf)-1)
					nDeletados++
				Endif
			Next
			// Volta o saldo da origem
			aDadosOri[nAcho,3]+=nQtdEst
			aDadosOri[nAcho,5]+=nQtdEst2Um
			cQtdDisp:=Transform(aDadosOri[nAcho,3],cPictQtd)
			// Atualiza informacoes no tree
			oTree1:ChangePrompt(aDadosOri[nAcho,If(nTipoQuebra == 1,7,6)]+" - "+cQtdDisp,cCargo1)
			Eval(oTree1:bChange)
				
			// Abaixa o saldo da Destino
			aDadosDest[nAcho2,3]-=nQtdEst
			aDadosDest[nAcho2,5]-=nQtdEst2Um
			cQtdDisp2:=Transform(aDadosDest[nAcho2,3],cPictQtd)
			// Atualiza informacoes no tree
			oTree2:ChangePrompt(aDadosDest[nAcho2,If(nTipoQuebra == 1,7,6)]+" - "+cQtdDisp2,cCargo2)
			Eval(oTree2:bChange)				
		EndIf
	Else
		Aviso(STR0037,STR0047,{"Ok"}) //"Não existe relaçao origem x destino estabelecida !"
	EndIf
Else
	// Nao foram selecionados itens validos para o estorno.    
	Help(" ",1,"A310SELEST")
EndIf
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ A310ProcLoc                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Marcos Vinicius Ferreira                 ³ Data ³ 18/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Processa transferencia (Localizada)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³aDadosTransf Array com dados para transferencia             ³±±
±±³           ³aParam310    Array com as perguntas selecionadas            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A310ProcLoc(aDadosTransf,aParam310)
// Variavel com a filial origem
Local cFilOri      := cFilAnt

Local cPedido   := ""
Local cWhile    := ""
Local cSerie    := ""

Local aCabec    := {}
Local aItens    := {}
Local aPvlNfs   := {}
Local aBloqueio := {{"","","","","","","",""}}
Local aNotas    := {}
Local aSeries   := {}
Local aNfs      := {}
Local aNotaGera := {}
Local aSX5      := {}
Local aParams   := {}

Local nItemNf   := 0
Local nSaveSX8  := 0
Local nAchoSerie:= 0
Local nPrcVen   := 0
Local ni        := 1
Local nx        := 1
Local ny        := 1
Local lRet      := .T.
Local lRegTransf	:= IsInCallStack("MATA311") //-- Verifica se veio da rotina de registro de transferência

// Array com notas geradas
Local aNotaFeita:= {}

// Variaveis para rotina automatica
Local lMostraErro   := .F.

// Verifica se existe ponto para manipulacao de itens
Local lExecItens:=ExistBlock("M310ITENS")           
Local aBackItens:={}
Local lExecCabec:=ExistBlock("M310CABEC")
Local aBackCabec:={}

Private lMsErroAuto := .F.
Private cNumero     := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                               ³
//³ mv_par01        // De  Produto                                     ³
//³ mv_par02        // Ate Produto                                     ³
//³ mv_par03        // De  filial                                      ³
//³ mv_par04        // Ate filial                                      ³
//³ mv_par05        // De  Armazem                                     ³
//³ mv_par06        // Ate Armazem                                     ³
//³ mv_par07        // De  Tipo                                        ³
//³ mv_par08        // Ate Tipo                                        ³
//³ mv_par09        // De  Grupo                                       ³
//³ mv_par10        // Ate Grupo                                       ³
//³ mv_par11        // Filtra Categorias  1 Sim  2 Nao                 ³
//³ mv_par12        // Quebra informacoes 1 Por produto 2 Por Armazem  ³
//³ mv_par13        // Codigo da TES utilizada nas NFs de saida        ³
//³ mv_par14        // Indica como deve gerar o documento              ³
//³ mv_par15        // Codigo da TES utilizada nas NFs de entrada      ³
//³ mv_par16        // Codigo da condicao de pagamento                 ³
//³ mv_par17        // Sugere preco 1 Tab 2 Custo STD 3 Ult Pr 4 CM    ³
//³ mv_par18        // Dados origem - somente filial corrente / todas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Array com dados para transferencia
// [1] Filial  origem
// [2] Produto origem
// [3] Armazem origem
// [4] Quantidade origem
// [5] Quantidade origem 2a UM
// [6] Filial  destino
// [7] Armazem destino
// [8] Cliente na Origem
// [9] Loja na Origem
// [10] Fornecedor no destino
// [11] Loja no destino
// [12] Documento na origem
// [13] Serie do documento na origem         
// [14] Informacoes sobre o Poder de Terceiros
// [14] Identificados Poder 3
// [15] Cliente/Fornecedor Poder 3
// [16] Loja Poder 3
// [17] Lote Origem
// [18] Sub-Lote Origem
// [19] Data de Validade
// [20] Endereço
// [21] Numero de Serie

// Varre array para efetuar gravacoes
For nx :=1 to Len(aDadosTransf)
	If nx == 1 .Or. (aDadosTransf[nx,1] # aDadosTransf[nx-1,1])
		// Atualiza para a filial origem
		cFilant:=aDadosTransf[nx,1]
		// Obtem serie para as notas desta filial
		aSX5    := LocXSx5NF(,,,.T.,.T.)
		If Len(aSX5) > 0
			cNumero := aSX5[1]
			cSerie  := aSX5[2]
			// Caso tenha selecionado numero
			If !Empty(cNumero)
				AADD(aSeries,{cFilAnt,cSerie,cNumero})
			EndIf
		Else 
			Aviso(STR0037,STR0049,{"Ok"}) //"Operação Cancelada"
			lRet := .F.		
		EndIf	
	EndIf
Next nx

If lRet .And. Pergunte('MT468C',.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta regua de processamento                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcRegua(Len(aDadosTransf)*2)

	aParams	:=	{	Space(Len(SC9->C9_PEDIDO)),;			//Pedido de
					Replicate('z',Len(SC9->C9_PEDIDO)),;	//Pedido ate
					Space(Len(SA1->A1_COD))	,;				//Cliente de
					Replicate('z',Len(SA1->A1_COD)),; 		//Cliente ate
					Space(Len(SA1->A1_LOJA)),;				//Loja de
					Replicate('z',Len(SA1->A1_LOJA)),; 	//Loja ate
					Space(Len(SB1->B1_GRUPO)),;			//Grupo de
					Replicate('z',Len(SB1->B1_GRUPO)),; 	//Grupo ate
					Space(Len(SA1->A1_AGREG)),;			//Agregador de
					Replicate('z',Len(SA1->A1_AGREG)),;	//Agregador ate
					mv_par01,;								//lDigita
					mv_par02,;								//lAglutina
					mv_par03,; 								//lGeraLanc
					2,;										//lInverte
					mv_par04,;								//lAtuaSC7
					mv_par05,;								//nSepara
					0,; 									//nValorMin
					2,; 									//factura proforma
					Space(Len(SC5->C5_TRANSP)),;			//Transportadora de
					Replicate('z',Len(SC5->C5_TRANSP)),; 	//Trasnportadora ate
					2,;										//Reajusta na mesma nota
					If(cPaisLoc=="URU",1,mv_par06),;		//Fatura Pedido pela
					If(cPaisLoc=="URU",1,mv_par07),;		//Moeda para faturamento
					If(cPaisLoc=="URU",1,mv_par08)} 		//Contabiliza por?

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa geracao de documentos de saida                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Sorteia array para aglutinar por filial origem e destino
	ASORT(aDadosTransf,,,{|x,y| x[1]+x[6]+x[2]+x[3] < y[1]+y[6]+y[2]+y[3] })
	// Varre array para efetuar gravacoes
	While (ni <= Len(aDadosTransf))
		
		// Variavel para rotina automatica
		lMsErroAuto := .F.
		// Atualiza para a filial origem
		cFilant:=aDadosTransf[ni,1]
		// Array para geracao de notas
		aNotas   := {}
		// Arrays com itens e bloqueios
		aPvlNfs  := {}
		aBloqueio:= {}
		// Cabecalho do pedido
		aCabec   := {}
		// Itens do pedido
		aItens   := {}
		// Variavel que controla numeracao
		nSaveSX8 := GetSx8Len()
		// Variavel para processamento
		cWhile:=aDadosTransf[ni,1]+aDadosTransf[ni,6]
		// Obtem serie para as notas desta filial
		nAchoSerie:=ASCAN(aSeries,{|x| x[1] == cFilAnt})
		// Caso tenha selecionado serie para esta filial
		If nAchoSerie > 0
			// Atualiza para a filial destino
			cFilant:=aDadosTransf[ni,6]
			// Verifica se Numero e serie ja foram cadastrados
			dbSelectArea("SF1")
			dbSetOrder(1)
			If MsSeek(xFilial("SF1")+aSeries[nAchoSerie,3]+aSeries[nAchoSerie,2]+aDadosTransf[ni,10]+aDadosTransf[ni,11])
				Aviso(STR0037,STR0042,{"Ok"}) //"A numeracao informada para esta transferencia ja possui um documento registrado com a mesma numeracao, favor informar uma nova numeracao. "
				Exit
			EndIf
			// Atualiza para a filial origem
			cFilant:=aDadosTransf[ni,1]
			// Serie para geracao da nota
			cSerie:=aSeries[nAchoSerie,2]
			//-- Numero para geracao da nota 
			cNumero:=aSeries[nAchoSerie,3]
			// Cabecalho do pedido
			cPedido := GetSxeNum("SC5","C5_NUM")
			RollBAckSx8()
			aadd(aCabec,{"C5_NUM",cPedido,Nil})
			aadd(aCabec,{"C5_TIPO","N",Nil})
			aadd(aCabec,{"C5_CLIENTE",aDadosTransf[ni,8],Nil})
			aadd(aCabec,{"C5_LOJACLI",aDadosTransf[ni,9],Nil})
			aadd(aCabec,{"C5_LOJAENT",aDadosTransf[ni,9],Nil})
			If lRegTransf
				SA1->(DbSetOrder(1))
				If SA1->(DbSeek(xFilial("SA1")+aDadosTransf[ni,8]+aDadosTransf[ni,9]))
					aadd(aCabec,{"C5_CONDPAG",SA1->A1_COND,Nil})
				EndIf
			Else
				aadd(aCabec,{"C5_CONDPAG",aParam310[16],Nil})
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para ALTERAR os dados do cabecalho do pedido de vendas  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lExecCabec
				aBackCabec:=ACLONE(aCabec)
				aCabec:=ExecBlock("M310CABEC",.F.,.F.,{"MATA410",aCabec,aParam310})
				If ValType(aCabec) # "A"
					aCabec:=ACLONE(aBackCabec)
				EndIf
			EndIf			
			// Contador dos itens
			cC6_ITEM := Strzero(0, TamSX3("C6_ITEM")[1])
			// ATENCAO - VARIAVEL CRIADAS POR CAUSA DA QUEBRA NO FATURAMENTO
			aNotaFeita:={}
			aNotaGera :={}
			While (ni <= Len(aDadosTransf)) .And. (aDadosTransf[ni,1]+aDadosTransf[ni,6] == cWhile)
				// Incrementa regua de processamento
				IncProc()
				aLinha := {}
				// Obtem preco de venda do produto
				If aParam310[17] == 1
					SA1->(dbSetOrder(1))
					SA1->(dbSeek(xFilial("SA1")+aDadosTransf[ni,8]+aDadosTransf[ni,9]))
					nPrcVen := MaTabPrVen(SA1->A1_TABELA,aDadosTransf[ni,2],aDadosTransf[ni,4],aDadosTransf[ni,8],aDadosTransf[ni,9],1,dDataBase)
				// Obtem preco - custo standard
				ElseIf aParam310[17] == 2
					If RetArqProd(aDadosTransf[ni,2])
						nPrcVen := Posicione("SB1",1,xFilial("SB1")+aDadosTransf[ni,2],"B1_CUSTD")
					Else
					    SB1->(dbSetOrder(1))
					    SB1->(dbSeek(xFilial("SB1")+aDadosTransf[ni,2]))
						nPrcVen := RetFldProd(SB1->B1_COD,"B1_CUSTD")
					EndIf
				// Obtem preco - ultimo preco de compra
				ElseIf aParam310[17] == 3
					If RetArqProd(aDadosTransf[ni,2])
						nPrcVen := Posicione("SB1",1,xFilial("SB1")+aDadosTransf[ni,2],"B1_UPRC")
					Else
					    SB1->(dbSetOrder(1))
					    SB1->(dbSeek(xFilial("SB1")+aDadosTransf[ni,2]))
						nPrcVen := RetFldProd(SB1->B1_COD,"B1_UPRC")
					EndIf	
				// Obtem preco - custo medio unitario do armazem
				ElseIf aParam310[17] == 4
					SB2->(dbSetOrder(1))
					If SB2->(MsSeek(xFilial("SB2")+aDadosTransf[ni,2]+aDadosTransf[ni,3]))
						nPrcVen:=SB2->B2_CM1
					EndIf
				EndIf
				// Senao encontrou nenhum valor assume 1
				If QtdComp(nPrcVen,.T.) == QtdComp(0,.T.)
					nPrcVen := 1
				EndIf
				aadd(aLinha,{"C6_ITEM"   ,Soma1(cC6_ITEM),Nil})
				aadd(aLinha,{"C6_PRODUTO",aDadosTransf[ni,2],Nil})
				aadd(aLinha,{"C6_LOCAL"  ,aDadosTransf[ni,3],Nil})
				aadd(aLinha,{"C6_QTDVEN" ,aDadosTransf[ni,4],Nil})
				aadd(aLinha,{"C6_PRCVEN" ,A410Arred(nPrcVen,"C6_PRCVEN"),Nil})
				aadd(aLinha,{"C6_PRUNIT" ,A410Arred(nPrcVen,"C6_PRUNIT"),Nil})
				aadd(aLinha,{"C6_VALOR"  ,A410Arred((aDadosTransf[ni,4]*A410Arred(nPrcVen,"C6_PRUNIT")),"C6_VALOR"),Nil})
				If lRegTransf
					aadd(aLinha,{"C6_TES"    ,aDadosTransf[ni,22],Nil}) 
				Else
					aadd(aLinha,{"C6_TES"    ,aDadosTransf[ni,23],Nil})   
				Endif
				// Checa se utiliza rastreabilidade por lote
				If Rastro(aDadosTransf[ni,2],"L")
					aadd(aLinha,{"C6_LOTECTL",aDadosTransf[ni,17],Nil})
					aadd(aLinha,{"C6_DTVALID",aDadosTransf[ni,19],Nil})
				EndIf
				// Checa se utiliza rastreabilidade por sublote
				If Rastro(aDadosTransf[ni,2],"S")                        
					aadd(aLinha,{"C6_LOTECTL",aDadosTransf[ni,17],Nil})
			   		aadd(aLinha,{"C6_NUMLOTE",aDadosTransf[ni,18],Nil})
					aadd(aLinha,{"C6_DTVALID",aDadosTransf[ni,19],Nil})
				EndIf         
				// Checa se utiliza localização
				If Localiza(aDadosTransf[ni,2])
					aadd(aLinha,{"C6_LOCALIZ",aDadosTransf[ni,20],Nil})
					aadd(aLinha,{"C6_NUMSERI",aDadosTransf[ni,21],Nil})
				EndIf	
				aadd(aItens,aLinha)
				// Incrementa contadores
				ni++
			End
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para ALTERAR os dados do pedido de vendas   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lExecItens
				aBackItens:=ACLONE(aItens)
				aItens:=ExecBlock("M310ITENS",.F.,.F.,{"MATA410",aItens})
				If ValType(aItens) # "A"
					aItens:=ACLONE(aBackItens)
				EndIf
			EndIf
			// Inclusao do pedido
			MATA410(aCabec,aItens,3)
			// Checa erro de rotina automatica
			If lMsErroAuto
				lMostraErro	:=.T.
			Else
				// Confirma SX8
				While ( GetSx8Len() > nSaveSX8 )
					ConfirmSX8()
				Enddo
				// Liberacao de pedido
				Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
				// Checa itens liberados
				Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
				// Caso tenha itens liberados manda faturar
				If Empty(aBloqueio) .And. !Empty(aPvlNfs)
					nItemNf  := a460NumIt(cSerie)
					aadd(aNotas,{})
					// Efetua as quebras de acordo com o numero de itens
					For nX := 1 To Len(aPvlNfs)
						If Len(aNotas[Len(aNotas)])>=nItemNf
							aadd(aNotas,{})
						EndIf
						aadd(aNotas[Len(aNotas)],aClone(aPvlNfs[nX]))
					Next nX
					// Gera as notas de acordo com a quebra
					For nX := 1 To Len(aNotas)

						aNfs := {}
						For nY := 1 To Len(aNotas[nX])
							//-- Grava numero do registro da tabela SC9
							dbSelectArea("SC9")
							dbSetOrder(1)
							If dbSeek(xFilial("SC9")+aNotas[nX,nY,1]+aNotas[nX,nY,2]+aNotas[nX,nY,3]+aNotas[nX,nY,6])
								Aadd( aNfs , SC9->(Recno()) )
							EndIf
						Next nY
							
						// Gera documento de saida
						If Len(aNfs) > 0
							MsAguarde({|| a468nFatura("SC9",aParams,@aNFs,,.F.,,@aNotaGera,.T.,cSerie,cNumero)},'Preparando documentos')
						EndIf	
					
						If Len(aNotaGera) > 0
							AADD(aNotaFeita,aNotaGera[1,2]) // Documento
						EndIf	

					Next nX

					// Varre notas fiscais de saida geradas para gerar notas fiscais de entrada
					For nx:=1 to Len(aNotaFeita)
						dbSelectArea("SD2")
						dbSetOrder(3)
						If dbSeek(xFilial("SD2")+PadR(aNotaFeita[nx],TamSX3("D2_DOC")[1])+cSerie+aDadosTransf[ni-1,8]+aDadosTransf[ni-1,9])
							
							// Cabecalho da nota fiscal de entrada
							aCabec   := {}
							aadd(aCabec,{"F1_TIPO"   ,"N"})
							aadd(aCabec,{"F1_FORMUL" ,"N"})
							aadd(aCabec,{"F1_DOC"    ,aNotaFeita[nx]})
							aadd(aCabec,{"F1_SERIE"  ,cSerie})
							aadd(aCabec,{"F1_EMISSAO",dDataBase})
							aadd(aCabec,{"F1_FORNECE",aDadosTransf[ni-1,10]})
							aadd(aCabec,{"F1_LOJA"   ,aDadosTransf[ni-1,11]})
							aadd(aCabec,{"F1_ESPECIE",aParam310[20]})
							If lRegTransf
								SA2->(DbSetOrder(1))
								If SA2->(DbSeek(xFilial("SA2")+cChavSA2))
									aadd(aCabec,{"F1_COND"   ,SA2->A2_COND})
								Endif
							Else
								aadd(aCabec,{"F1_COND"   ,aParam310[16]})
							Endif
							aadd(aCabec,{"F1_TIPODOC","10"})
							aadd(aCabec,{"F1_MOEDA"		,1})
							aadd(aCabec,{"F1_TXMOEDA"	,1})
							If cPaisLoc == "ARG"
								aadd(aCabec,{"F1_PROVENT"	,"BA"})
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Ponto de entrada para ALTERAR os dados do cabecalho do pedido de vendas  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lExecCabec
								aBackCabec:=ACLONE(aCabec)
								aCabec:=ExecBlock("M310CABEC",.F.,.F.,{"MATA101N",aCabec,aParam310})
								If ValType(aCabec) # "A"
									aCabec:=ACLONE(aBackCabec)
								EndIf
							EndIf							
							// Itens da nota fiscal de entrada
							aItens   := {}
							While !Eof() .And. xFilial("SD2")+aNotaFeita[nx]+cSerie+aDadosTransf[ni-1,8]+aDadosTransf[ni-1,9] == D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA
								// Incrementa regua de processamento
								IncProc()
								aLinha := {}
								aadd(aLinha,{"D1_COD",aDadosTransf[ni-1,25],Nil})
								aadd(aLinha,{"D1_QUANT",SD2->D2_QUANT,Nil})
								aadd(aLinha,{"D1_VUNIT",SD2->D2_PRCVEN,Nil})
								aadd(aLinha,{"D1_TOTAL",SD2->D2_TOTAL,Nil})
								aadd(aLinha,{"D1_LOCAL",aDadosTransf[ni-1,7],Nil})
								aadd(aLinha,{"D1_EMISSAO",dDataBase,Nil})
								aadd(aLinha,{"D1_DTDIGIT",dDataBase,Nil})
								// Checa geracao de documento
								If lRegTransf
									aadd(aLinha,{"D1_TES",aDadosTransf[nx,23],Nil})
								Else
									aadd(aLinha,{"D1_TES",aParam310[15],Nil})
								Endif
								// Checa se utiliza rastreabilidade 
								cFilAnt:= aDadosTransf[nx,6]
								If Rastro(SD2->D2_COD,"L")
									aadd(aLinha,{"D1_LOTECTL",SD2->D2_LOTECTL,Nil})
									aadd(aLinha,{"D1_DTVALID",SD2->D2_DTVALID,Nil})
								EndIf
								If Rastro(SD2->D2_COD,"S")                           
									aadd(aLinha,{"D1_LOTECTL",SD2->D2_LOTECTL,Nil})
									aadd(aLinha,{"D1_NUMLOTE",SD2->D2_NUMLOTE,Nil})
									aadd(aLinha,{"D1_DTVALID",SD2->D2_DTVALID,Nil})
								EndIf
								aadd(aItens,aLinha)
								cFilAnt:= aDadosTransf[nx,1]
								dbSelectArea("SD2")
								dbSkip()
							End
							// Caso tenha itens e cabecalho definidos
							If Len(aItens) > 0 .And. Len(aCabec) > 0
								// Atualiza para a filial destino
								cFilant:=aDadosTransf[ni-1,6]
								// Reinicializa ambiente para o fiscal
								If MaFisFound()
									MaFisEnd()
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Ponto de entrada para ALTERAR os dados do pedido de vendas   ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lExecItens
									aBackItens:=ACLONE(aItens)
									aItens:=ExecBlock("M310ITENS",.F.,.F.,{"MATA101N",aItens})
									If ValType(aItens) # "A"
										aItens:=ACLONE(aBackItens)
									EndIf
								EndIf
								// Inclui nota de entrada
								MATA101N(aCabec,aItens,3,.T.)
								// Checa erro de rotina automatica
								If lMsErroAuto
									lMostraErro	:=.T.
								EndIf
								// Atualiza para a filial origem
								cFilant:=aDadosTransf[ni-1,1]
							EndIf
						EndIf
					Next nx
				EndIf
			EndIf
		Else
			// A filial XX nao teve uma serie de nota fiscal de saida selecionada para geracao
			Help(" ",1,"A310SERERR",,cFilAnt,1,10)
			// Variavel para processamento
			cWhile:=aDadosTransf[ni,1]
			// Varre todos os itens com esta filial origem
			While (ni <= Len(aDadosTransf)) .And. aDadosTransf[ni,1] == cWhile
				// Incrementa regua de processamento
				IncProc()
				ni++
			End
		EndIf	
	End
EndIf
// Restaura filial original
cFilAnt:=cFilOri
// Mostra erro em rotina automatica
If lMostraErro
	MostraErro()
EndIf
RETURN

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A310Pesq   ³ Autor ³Rodrigo A Sartorio   ³ Data ³ 28/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa produtos                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ A310Pesq(ExpO1,Exp02,ExpN1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto tree1 utilizado                             ³±±
±±³          ³ ExpO2 = Objeto tree2 utilizado                             ³±±
±±³          ³ ExpN1 = Identifica se apresenta por produto ou por armazem ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A310Pesq(oTree1,oTree2,nTipoQuebra)
Local cFilVazio    := Space(Len(cFilAnt))
Local cProdVazio   := CriaVar("B2_COD"  ,.F.)
Local cArmazemVazio:= CriaVar("B2_LOCAL",.F.)
Local cFilSeek := ""
Local cDescSeek:= ""
Local cArmSeek := ""
Local cPesqTrFil   := cFilVazio+cProdVazio+cArmazemVazio 
Local cTexto       := If(nTipoQuebra == 1,OemToAnsi(STR0051),OemToAnsi(STR0052))
Local oDlg,oUsado,lCancel:=.F.
Local nUsado       := 1
Local aTipPesq     := {}
Local cTipSelPesq  := "" 
Local nPos 
Local nB1LocPad 	:= TamSx3("B1_LOCPAD")[1]

DEFINE MSDIALOG oDlg TITLE STR0050 From 145,0 To 320,400 OF oMainWnd PIXEL
If mv_par21 == 1
	aAdd(aTipPesq,cTexto)
	aAdd(aTipPesq,"Filial+Armazem+Descricao")
	@ 07,20 COMBOBOX cTipSelPesq ITEMS aTipPesq SIZE 70,185 OF oDlg PIXEL
Else
	@ 10,15 TO 40,185 LABEL cTexto OF oDlg PIXEL
EndIf 
@ 20,20 MSGET cPesqTrFil Picture "@!S19" OF oDlg PIXEL
@ 42,15 TO 70,115 LABEL OemToAnsi(STR0053) OF oDlg  PIXEL
@ 50,20 RADIO oUsado VAR nUsado 3D SIZE 70,10 PROMPT  OemToAnsi(STR0015),OemToAnsi(STR0016) OF oDlg PIXEL
DEFINE SBUTTON FROM 075,131 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
DEFINE SBUTTON FROM 075,158 TYPE 2 ACTION (oDlg:End(),lCancel:=.T.) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg
// PESQUISA NO TREE O CONTEUDO DIGITADO
If !lCancel .And. !Empty(cPesqTrFil)
	
	If cTipSelPesq == "Filial+Armazem+Descricao"
		//-- Pesquisa por descrição 
		cFilSeek  := Substr(Alltrim(Upper(cPesqTrFil)),1                                      ,FWSIZEFILIAL()        )//Filial Digitada
		cArmSeek  := Substr(Alltrim(Upper(cPesqTrFil)),FWSIZEFILIAL()+1                       ,nB1LocPad)//Armazem Digitado
		cDescSeek := Substr(Alltrim(Upper(cPesqTrFil)),FWSIZEFILIAL() + 1 + nB1LocPad ,Len(cPesqTrFil)            )//Conteudo
		
		nPos:= aScan(aDescSeek,{ |x| cFilSeek == x[1] .and. StrTran(cDescSeek, " ","") $ x[3] .and. cArmSeek == x[4] })	
			
		If nPos <> 0
			If nTipoQuebra == 1
				cPesqTrFil   := aDescSeek[nPos][1]+aDescSeek[nPos][2]+aDescSeek[nPos][4] //-- Filial+Cod.Produto+Armazem
			ElseIf nTipoQuebra == 2
				cPesqTrFil   := aDescSeek[nPos][1]+aDescSeek[nPos][4]+aDescSeek[nPos][2] //-- Filial+Armazem+Cod.Produto
			EndIf
      EndIf
        
   ElseIf nTipoQuebra == 1 	
		cFilSeek  := Substr(Alltrim(Upper(cPesqTrFil)),1               ,FWSIZEFILIAL()     )//-- Filial Digitada
		cDescSeek := Substr(Alltrim(Upper(cPesqTrFil)),FWSIZEFILIAL()+1,Len(AllTrim(cPesqTrFil)))//-- Conteudo   
				
		nPos:= aScan(aDescSeek,{ |x| cFilSeek == x[1] .And. ( AllTrim(StrTran(cDescSeek," ","")) $ AllTrim(StrTran(x[2]+x[4]," ","")) ) })
		If nPos <> 0
			cPesqTrFil  := aDescSeek[nPos][1]+aDescSeek[nPos][2]+aDescSeek[nPos][4] //-- Filial+Cod.Produto+Armazem
      	EndIf         
   Else
		cFilSeek  := Substr(Alltrim(Upper(cPesqTrFil)),1                       ,FWSIZEFILIAL()        )//-- Filial Digitada
		cArmSeek  := Substr(Alltrim(Upper(cPesqTrFil)),FWSIZEFILIAL()+1        ,nB1LocPad)//-- Armazem Digitado
		cDescSeek := Substr(Alltrim(Upper(cPesqTrFil)),FWSIZEFILIAL() + nB1LocPad + 1,Len(cPesqTrFil)            )//-- Conteudo   
				
		nPos:= aScan(aDescSeek,{ |x| cFilSeek == x[1] .and. Alltrim(cDescSeek) $ x[2] .and. cArmSeek == x[4] })				
		If nPos <> 0
			cPesqTrFil   := aDescSeek[nPos][1]+aDescSeek[nPos][4]+aDescSeek[nPos][2] //-- Filial+Armazem+Cod.Produto
      	EndIf           
	EndIf    

	If nPos <> 0
		If nUsado == 1
			oTree1:TreeSeek("3"+Alltrim(cPesqTrFil))
			oTree1:SetFocus()
		ElseIf nUsado == 2
			oTree2:TreeSeek("3"+Alltrim(cPesqTrFil))
			oTree2:SetFocus()
		EndIf
	Else 
		Alert("Não foi encontrado o conteudo digitado."+Chr(13)+Chr(10)+"Verifique o conteudo digitado.")	
	EndIf
EndIf 

Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A310VldTes ³ Autor ³Marcos V. Ferreira   ³ Data ³ 10/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da TES                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ A310VldTes(cFilOrig,cFilDest)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilOrig  = Codigo da Filial Origem                        ³±±
±±³          ³ cFilDest  = Codigo da Filial Destin                        ³±±
±±³          ³ lValida   = Verifica se valida Tes                         ³±±
±±³          ³ aParam310 = Parametros do MATA310                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A310VldTes(cFilOrig,cFilDest,lValida,aParam,lTesOrig,lTesDest)
Local aAreaAnt  := GetArea()
Local aAreaSF4  := SF4->(GetArea())
Local lRet      := .T.
Local cFilBkp   := cFilAnt // Armazena a filial corrente

Default lValida  := .T.
Default lTesOrig := .T.
Default lTesDest := .T.
Default cFilOrig := ""
Default cFilDest := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida TES de Transferencia entre Filiais                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF4")
If lValida
	//Carrega Filial Origem e Destino
	cFilAnt  := cFilOrig
	cFilOrig := xFilial("SF4")
	cFilAnt  := cFilDest
	cFilDest := xFilial("SF4")
	
	// Restaura a filial corrente
	cFilAnt  := cFilBkp

	// Verifica se a Tes esta cadastrada na Filial Origem
	If lRet .And. !MsSeek(cFilOrig+aParam[1])
		Aviso(STR0037,STR0038 + aParam[1] + STR0060 + cFilOrig + STR0061, {"Ok"}) //"A TES XXX de saida não esta cadastrada na filial ##. Favor verificar se a TES esta cadastrada."
		lRet := .F.
	EndIf
	// Verifica se a Tes esta cadastrada na Filial Destino
	If lRet .And. !MsSeek(cFilDest+aParam[2])
		Aviso(STR0037,STR0038 + aParam[2] + STR0062 + cFilDest + STR0061, {"Ok"}) //"A TES XXX de entrada não esta cadastrada na filial ##. Favor verificar se a TES esta cadastrada."
		lRet := .F.
	EndIf
	// Verifica se o TES pode ser utilizada na operacao
	If lRet .And. !(MAAVALTES("S",aParam[1]) .And. MAAVALTES("E",aParam[2]))
		lRet := .F.
	EndIf
	// Validacao para o campo F4_TRANSFIL
	If lRet 
		If MsSeek(cFilOrig+aParam[1]) .And. SF4->F4_TRANFIL == "2"
			If Aviso(STR0037,STR0038 + aParam[1] + STR0039, {STR0040,STR0041}) == 2 //"A TES XXX não esta configurada para ser utilizada no processo de transferencia entre filiais. Favor verificar se o campo 'Trans. Filial' esta ativado no cadastro de TES."
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet
		If MsSeek(cFilDest+aParam[2]) .And. SF4->F4_TRANFIL == "2"
			If Aviso(STR0037,STR0038 + aParam[2] + STR0039, {STR0040,STR0041}) == 2  //"A TES XXX não esta configurada para ser utilizada no processo de transferencia entre filiais. Favor verificar se o campo 'Trans. Filial' esta ativado no cadastro de TES."
				lRet := .F.
			EndIf
		EndIf
	EndIf
	// Validacao para os campos de impostos F4_CREDICM e F4_CREDIPI
	If lRet .And. MsSeek(cFilOrig+aParam[1]) .And. (SF4->F4_CREDICM == 'S' .Or. SF4->F4_CREDIPI == 'S')
		If Aviso(STR0037,STR0038+ aParam[1] + STR0055, {STR0040,STR0041}) == 2 // "A TES " ### " de saida selecionada possue configuração de impostos o que podera causar divergencia nos custos. Deseja continua ?"
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. MsSeek(cFilDest+aParam[2]) .And. (SF4->F4_CREDICM == 'S' .Or. SF4->F4_CREDIPI == 'S')
		If Aviso(STR0037,STR0038+ aParam[2] + STR0056, {STR0040,STR0041}) == 2 // "A TES " ### " de entrada selecionada possue configuração de impostos o que podera causar divergencia nos custos. Deseja continua ?"
			lRet := .F.
		EndIf
	EndIf
	// Validacao para o campo F4_ESTOQUE
	If lRet .And. MsSeek(cFilOrig+aParam[1]) .And. SF4->F4_ESTOQUE == 'N'
		If Aviso(STR0037,STR0038+ aParam[1] + STR0058, {STR0040,STR0041}) == 2 // "A TES " ### " de entrada selecionada possue configuração para não atualizar estoque o que pode causar divergencia nos movimentos de transferencia. Deseja continua ?"
			lRet := .F.
		Else
			lTesOrig := .F.
		EndIf
	EndIf
	If lRet .And. MsSeek(cFilDest+aParam[2]) .And. SF4->F4_ESTOQUE == 'N'
		If Aviso(STR0037,STR0038+ aParam[2] + STR0057 , {STR0040,STR0041}) == 2 // "A TES " ### " de saida selecionada possue configuração para não atualizar estoque o que pode causar divergencia nos movimentos de transferencia. Deseja continua ?"
			lRet := .F.
		Else
			lTesDest := .F.
		EndIf
	EndIf
	// Validacao para o campo F4_PODER3
	If l310PODER3
		If lRet .And. MsSeek(cFilOrig+aParam[2]) .And. (SF4->F4_PODER3 == 'N' .Or. SF4->F4_PODER3 == ' ')
			Aviso(STR0037,STR0038+ aParam[2] + " " + STR0070, {STR0069}) // "A TES " ### "de entrada selecionada não possui configuração para controlar PODER DE TERCEIROS, por isso não sera possivel realizar a transferencia !"
			lRet := .F.
		EndIf
		If lRet .And. MsSeek(cFilDest+aParam[1]) .And. (SF4->F4_PODER3 == 'N' .Or. SF4->F4_PODER3 == ' ')
			Aviso(STR0037,STR0038+ aParam[1] + " " + STR0071, {STR0069}) // "A TES " ### "de saida selecionada não possui configuração para controlar PODER DE TERCEIROS, por isso não sera possivel realizar a transferencia !"
			lRet := .F.
		EndIf
		If lRet .And. MsSeek(cFilOrig+aParam[2]) .And. SF4->F4_PODER3 <> 'D'
			Aviso(STR0037,STR0038+ aParam[2] + " " + STR0072, {STR0069}) // "A TES " ### "de entrada selecionada nao esta configurada como uma TES de devolucao de poder de terceiros, por isso não sera possivel realizar a transferencia !"
			lRet := .F.
		EndIf
		If lRet .And. MsSeek(cFilDest+aParam[1]) .And. SF4->F4_PODER3 <> 'R'
			Aviso(STR0037,STR0038+ aParam[1] + " " + STR0073, {STR0069}) // "A TES " ### "de saida selecionada não esta configurada como uma TES de remessa de poder de  terceiros, por isso não sera possivel realizar a transferencia !"
			lRet := .F.
		EndIf
	EndIf
EndIf
RestArea(aAreaSF4)
RestArea(aAreaAnt)
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A310Terc   ³ Autor ³Microsiga S/A        ³ Data ³ 27/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para preparar o array aDadosTransf para   ³±±
±±³          ³ transferencia de materiais que utilizam controle de poder  ³±±
±±³          ³ de terceiros.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ A310Terc(aDadosTransf)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A310Terc(aDadosTransf)
Local aDeTerc  := {}
Local aRet     := {}
Local aNewDados:= {}
Local nQtdOrig := 0
Local nQtd2Orig:= 0
Local nNewQtd  := 0
Local nX       := 0
Local nY       := 0
Local cFilBack := cFilAnt
Local nPos     := 0
Default aDadosTransf := {}

// Conteudo do array aDadosTransf
// [01] Filial  origem
// [02] Produto origem
// [03] Armazem origem
// [04] Quantidade origem
// [05] Quantidade origem 2a UM
// [06] Filial  destino
// [07] Armazem destino
// [08] Cliente na Origem
// [09] Loja na Origem
// [10] Fornecedor no destino
// [11] Loja no destino
// [12] Documento na origem
// [13] Serie do documento na origem
// [14] Identificados Poder 3
// [15] Cliente/Fornecedor Poder 3
// [16] Loja Poder 3
// [17] Lote 
// [18] Sub-Lote 
// [19] Data do Lote 
// [20] Numero de Serie do Produto 
// [21] Localizacao do produto   

For nX := 1 to Len(aDadosTransf)
	nQtdOrig  := aDadosTransf[nx,04]
	nQtd2Orig := aDadosTransf[nx,05]
	aNewDados := {}
	nNewQtd   := 0
	
	// Atualiza para a filial origem
	cFilant:=aDadosTransf[nx,1]
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna array com o saldo do produto por documento           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    aDeTerc := SaldoTerc(aDadosTransf[nx,02],aDadosTransf[nx,03],"D",dDataBase,Nil,Nil,Nil,.T.,Nil,.T.)
	
    For nY := 1 to Len(aDeTerc)
		If aDeTerc[nY,4] > 0
			//-- Calculo de saldo por documento
			If aDeTerc[nY,04] > nQtdOrig
				nNewQtd  := nQtdOrig
				nQtdOrig := 0	
			Else
				nNewQtd  := aDeTerc[nY,04]
				nQtdOrig := nQtdOrig - nNewQtd
			EndIf
			//-- Quebra por Documento de Remessa de Terceiros
			aAdd(aNewDados,aClone(aDadosTransf[nX]))
			nPos := Len(aNewDados)
			aNewDados[nPos,04] := nNewQtd		// [04] Quantidade origem
			aNewDados[nPos,05] := nNewQtd		// [05] Quantidade origem 2a UM
			aNewDados[nPos,14] := aDeTerc[nY,1]	// [14] Identificados Poder 3
			aNewDados[nPos,15] := aDeTerc[nY,2]	// [15] Cliente/Fornecedor Poder 3
			aNewDados[nPos,16] := aDeTerc[nY,3]	// [16] Loja Poder 3
							 		
		EndIf     	
		//-- Quantidade Atendida
		If nQtdOrig <= 0
			Exit
		EndIf
    Next nY

	//-- Analisa a Quantidade de Terceiros Versus Quantidade de Transferencia
    If Len(aNewDados) > 0
        nNewQtd := 0
		For nY := 1 to Len(aNewDados)
			nNewQtd += aNewDados[nY,4]			
		Next nY    
        If nNewQtd == aDadosTransf[nX,4]
			For nY := 1 to Len(aNewDados)
		    	aAdd(aRet,aNewDados[nY])
		    Next nY	
	    Else
			Aviso(STR0037,STR0068,{"Ok"}) //"Não existe quantidade disponivel para atender a tranferencia"
			aNewDados := {}
			Exit
	    EndIf	
    EndIf
    
Next nX
// Restaura filial original
cFilAnt := cFilBack
Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A310ValOK  ³ Autor ³Emerson R. Oliveira  ³ Data ³ 27/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de validacao do botao OK da janela principal        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ A310ValOK()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com dados para transferencia                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A310ValOK(aDadosTransf)
Local lContinua := .T.
Local lMTA310OK := ExistBlock("MTA310OK")

// Verifica se o array esta vazio
If Empty(aDadosTransf)
	Aviso("SEMDADOS",STR0067,{"Ok"}) //"Não existe nenhuma tranferencia de materiais pendente a ser executada."
	lContinua := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³P.E para validar a execução das transferências. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. lMTA310OK
	lContinua := ExecBlock("MTA310OK",.F.,.F.,{aClone(aDadosTransf)})
	If ValType(lContinua) != "L"
		lContinua := .T. // Padrao do funcionamento da rotina
	EndIf
EndIf

Return lContinua

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A310AVALF4³ Autor ³ Leonardo Quintania    ³ Data ³ 02/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada da funcao F4                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A310AvalF4()
 
nQuant:=0
nQuant2UM :=0

cFilAnt:= cFilOrig                  

If Upper(ReadVar()) $ "CNUMLOTE/CLOTEDIGI"	
	F4Lote   (,,,"A310",cProduto1,cLocOrig,Nil,cLocaliz)
ElseIf Upper(ReadVar()) $ "CLOCALIZ/CNUMSERIE"
	F4Localiz(,,,"A310",cProduto1,cLocOrig,,ReadVar() )
EndIf
Return Nil           


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A310Lote   ³ Autor ³ Leonardo Quintania    ³ Data ³ 12/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡„o referente aos campos de Lote                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A310Lote()
Local cAlias := Alias()
Local nOrder := IndexOrd()
Local nRecno := Recno()
Local lRet   := .T.
Local cVar	 := Upper(ReadVar())

If Empty(&(ReadVar()))
	Help(" ",1,"MA310LOTE")
	lRet:=.F.
EndIf

If lRet
	If Rastro(cProduto1,'S') .And. If(cVar == "CNUMLOTE",!Empty(cLoteDigi),!Empty(cNumLote))
		SB8->(dbSetOrder(2))
		If SB8->(dbSeek(xFilial('SB8') + cNumLote + cLoteDigi + cProduto1 + cLocOrig, .F.))
			cLoteDigi := SB8->B8_LOTECTL
			dDtValid2  := SB8->B8_DTVALID  
			cNumLote := SB8->B8_NUMLOTE
		Else
			Help(' ', 1, 'A310LOTERR')
			lRet := .F.
		EndIf
	Else
		SB8->(dbSetOrder(3))
		If SB8->(dbSeek(xFilial('SB8')+cProduto1+cLocOrig+cLoteDigi, .F.))
			dDtValid2:=SB8->B8_DTVALID  
			cLoteDigi := SB8->B8_LOTECTL
		Else
			Help(' ', 1, 'A310LOTERR')
			lRet := .F.
		EndIf
	EndIf
EndIf

dbSelectArea(cAlias)
dbSetOrder(nOrder)
MsGoto(nRecno)
Return lRet               


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A310Quant ³ Autor ³ Leonardo Quintania    ³ Data ³13/09/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Trata a Convers„o de Unidades de Medida e validações de Qtd³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A310Quant(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpN1 = 1 - Trata 1a Unidade de Medida                     ³±±
±±³          ³         2 - Trata 2a Unidade de Medida                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MatA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A310Quant(nTipoUM)

Local aAreaAnt   := GetArea()
Local aAreaSB1   := SB1->(GetArea())
Local aAreaSB2   := SB2->(GetArea())
Local aAreaSB8   := SB8->(GetArea())
Local aAreaSBE   := SBE->(GetArea())
Local aAreaSD1   := SD1->(GetArea())
Local lEstNeg    := .F.
Local lRastro    := .F.
Local lLocaliza  := .F.
Local lRet       := .T.
Local cFilBkp    := cFilAnt
Local nTam1UM    := TamSX3('D3_QUANT')[1]
Local nTam2UM    := TamSX3('D3_QTSEGUM')[1]
Local nDec1UM    := TamSX3('D3_QUANT')[2]
Local nDec2UM    := TamSX3('D3_QTSEGUM')[2]
Local nQuantVld  := 0
Local nSaldoCQ   := 0
Local cLocalCQ   := ""
Local lEmpPrev   := If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)    
Local lTranCQ    := IsTranCQ()
local cclieTRF   := ' '
local cLJTRF     := ' '

SB1->(dbSetOrder(1))

If nTipoUM == 1
	//-- Verifica se deve reiniciar a 2a.UM com base na 1a.UM digitada
	nQuantVld := Round(QtdComp(ConvUm(cProduto1, nQuant, nQuant2UM,2)), nDec2UM)
	If !(StrZero(nQuant2UM,nTam2UM,nDec2UM)==StrZero(nQuantVld,nTam2UM,nDec2UM))
		nQuant2UM := nQuantVld
	EndIf
ElseIf nTipoUM == 2
	//-- Verifica se deve reiniciar a 1a.UM com base na 2a.UM digitada
	nQuantVld := Round(QtdComp(ConvUm(cProduto1, nQuant, nQuant2UM,2)), nDec2UM)
	//-- Recalcula a 1a.UM somente quando a reconversao para a 2a.UM divergir da 2a.UM digitada
	If !(StrZero(nQuant2UM,nTam2UM,nDec2UM)==StrZero(nQuantVld,nTam2UM,nDec2UM))
		nQuantVld := Round(QtdComp(ConvUm(cProduto1, nQuant, nQuant2UM, 1)), nDec1UM)
		If !(StrZero(nQuant,nTam1UM,nDec1UM)==StrZero(nQuantVld,nTam1UM,nDec1UM))
			nQuant := nQuantVld
		EndIf
	EndIf
EndIf

//-- Valida Movimenta‡äes c/Quantidade Negativa
If QtdComp(nQuant) < QtdComp(0)
	Help(' ', 1, 'POSIT')
	lRet := .F.
EndIf

//-- Valida a quantidade do processo de controle de qualidade
If lRet .And. lTranCQ
    cFilAnt :=cFilOrig
	// Recupera o Armazem de CQ da Filial
    cLocalCQ := GetMvNNR('MV_CQ','98')
	// Verifica se o armazem de Origem e de CQ
	If AllTrim(cLocOrig)==AllTrim(cLocalCQ)
		dbSelectArea("SD1")
		dbSetOrder(5)
		If MsSeek(xFilial("SD1")+cProduto1+cLocOrig+cNumseqCQ)
			nSaldoCQ := SaldoRJCQ(SD1->D1_COD,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,,SD1->D1_ITEM,,SD1->D1_LOCAL)[8]
			If nQuant > nSaldoCQ
				Help(' ', 1, 'A310SLDCQ')
				lRet := .F.
			EndIf
		EndIf
		// verifica se o saldo informado é maior que o saldo existente no cq origem e sequencia para não gerar saldo negativo. 
		lEstNeg   := (GetMv('MV_ESTNEG')=='S')
		If !lEstNeg
			dbSelectArea("SD7")
			dbSetOrder(3)
			If MsSeek(xFilial("SD7")+cProduto1+cNumseqCQ)   
			   If nQuant > D7_SALDO
				  Help(' ', 1, 'A310SLDCQ')
				  lRet := .F.			   	
			   EndIf
			EndIf
		EndIf
	EndIf
	cFilAnt := cFilBkp
EndIf

If lRet
	lEstNeg   := (GetMv('MV_ESTNEG')=='N')
	lRastro   := Rastro(cProduto1)
	lLocaliza := Localiza(cProduto1)
EndIf

If lRet .And. (lEstNeg.Or.lRastro.Or.lLocaliza)
	//-- Valida Saldo em Estoque Negativo
	If lEstNeg
		dbSelectArea('SB2')
		aAreaSB2 := GetArea()
		SB2->(dbSetOrder(1))
		If !SB2->(MsSeek(cFilOrig+cProduto1+cLocOrig))
			Help(' ', 1, 'REGNOIS')
			lRet := .F.
		ElseIf QtdComp(SaldoMov(Nil, Nil,Nil, ( Mv_Par19 == 1 ), Nil,Nil,.T.,Nil,Nil)) < QtdComp(nQuant)	// mv_par19 -> Utilizar Saldo de Terceiros ? 1=Sim / 2 = Nao
			dbselectarea('SF4')
			DbSetOrder(1)
			cFilAnt := cFilOrig
			CliForOrig('SA2', @cclieTRF, @cLJTRF,UsaFilTrf())
			If dbseek (xfilial('SF4')+Iif(lTesIntSai,MaTesInt(2,MV_PAR22,cclieTRF,cLJTRF,"C",cProduto1),MV_PAR13))
				lValTES := .T.
				If F4_ESTOQUE = 'S'
					Help(' ', 1, 'MA240NEGAT')
					lRet := .F.
					lValTES := .F.
				EndIf
			EndIf
		EndIf
		dbSetOrder(aAreaSB2[2])
		MsGoto(aAreaSB2[3])
	EndIf

	//-- Valida Saldo em Estoque ref. a Rastreabilidade
	nQtdLote:=0
	If lRet .And. lRastro
		dbSelectArea('SB8')
		aAreaSB8 := GetArea()
		If	Rastro(cProduto1, 'S')
			SB8->(dbSetOrder(2))
			If SB8->(MsSeek(xFilial('SB8')+cNumLote+cLoteDigi+cProduto1+cLocOrig, .F.))
				If QtdComp(SB8Saldo(Nil,.T.,Nil,Nil,Nil,lEmpPrev,Nil,dDataBase) - A310VerSld(1)) < QtdComp(nQuant)
					Help(' ', 1, 'A240NEGAT' )
					lRet := .F.
				EndIf
			EndIf
		ElseIf QtdComp(SaldoLote(cProduto1,cLocOrig,cLoteDigi,Nil,Nil,Nil,Nil,dDataBase) - A310VerSld(1)) < QtdComp(nQuant)
			Help(' ', 1, 'A240NEGAT')
			lRet := .F.
		EndIf
		dbSetOrder(aAreaSB8[2])
		MsGoto(aAreaSB8[3])
	EndIf

	//-- Valida Saldo em Estoque ref. a Localiza‡Æo
	nQtdLote:=0
	If lRet .And. lLocaliza
		If lRet
			dbSelectArea('SBE')
			aAreaSBE := GetArea()
			SBE->(dbSetOrder(1))          
			If lRet .And. QtdComp(SaldoSBF(cLocOrig,cLocaliz,cProduto1,cNumSerie,cLoteDigi,cNumLote) - A310VerSld(2))<QtdComp(nQuant)
				Help(' ', 1, 'SALDOLOCLZ')
				lRet := .F.
			EndIf
			dbSetOrder(aAreaSBE[2])
			MsGoto(aAreaSBE[3])
		EndIf
	EndIf
EndIf

SB1->(dbSetOrder(aAreaSB1[2]))
SB1->(MsGoto(aAreaSB1[3]))
RestArea(aAreaSD1)
RestArea(aAreaAnt)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A310VerSld³ Autor ³ Leonardo Quintania    ³ Data ³13/09/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica o saldo do lote em memoria que já foi consumido.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A310VerSld(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MatA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A310VerSld(nVld)
Local nI       :=0
Local nQtdLote :=0

For nI := 1 to Len(aDadosTransf)
	
	If nVld==1
		If aDadosTransf[nI,1] == cFilOrig .And. aDadosTransf[nI,2] == cProduto1 .And. ;
				aDadosTransf[nI,3] == cLocOrig .And. aDadosTransf[nI,17] == cLoteDigi .And.; 
					aDadosTransf[nI,18] == cNumLote
			nQtdLote=+aDadosTransf[nI,4]	
		EndIf
	ElseIf nVld==2
		If aDadosTransf[nI,1] == cFilOrig .And. aDadosTransf[nI,2] == cProduto1 .And. ;
				aDadosTransf[nI,3] == cLocOrig .And. aDadosTransf[nI,17] == cLoteDigi .And.; 
					aDadosTransf[nI,18] == cNumLote .And. aDadosTransf[nI,20]==cLocaliz .And. aDadosTransf[nI,21]==cNumSerie
			nQtdLote=+aDadosTransf[nI,4]	
		EndIf
	EndIf 
Next nI

Return nQtdLote


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A310ConCQ ³ Autor ³ TOTVS S/A            ³ Data ³ 08/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a consulta do saldo disponivel para o armazem de CQ    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A310ConCQ(ExpC1,ExpC2,ExpC3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ ExpC1 = Codigo do Produto                                  ³±±
±±³          ³ ExpC2 = Armazem                                            ³±±
±±³          ³ ExpC3 = Codigo da Filial Origem                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A310ConCQ( cCod, cLocal, cFilOrig )
Local aArrayF4		:= {}
Local aHeaderF4		:= {}
Local aPosObj		:= {}
Local aObjects		:= {}
Local aSaldo        := {}
Local nOpca         := 0
Local nSaldo        := 0
Local nAchou        := 0
Local nSaldo2UM     := 0
Local cQuery        := ""
Local cAliasSD7     := "SD7"
Local aTamQtde      := TamSX3("D7_QTDE")
Local aSize			:= MsAdvSize(.F.)
Local nHdl			:= GetFocus()
Local aAreaAnt      := GetArea()
Local cCadastro     := STR0093 // "Consulta Saldo Rejeitado para o armazem de CQ"
Local cFilBkp       := cFilAnt

Local oDlg2, nOAT, cVar
                            
// Ajusta para Filial Origem
cFilAnt   := cFilOrig
cAliasSD7 := GetNextAlias()
cQuery := "SELECT D7_FILIAL , D7_NUMERO, D7_SEQ    , D7_TIPO   , D7_QTDE   , D7_NUMSEQ,  D7_LOCAL,  "
cQuery +=       " D7_LOCDEST, D7_DATA  , D7_LOTECTL, D7_NUMLOTE, D7_LOCALIZ, D7_NUMSERI, D7_PRODUTO, D7_QTSEGUM, "
cQuery +=       " D7_DOC   , D7_SERIE  , D7_FORNECE, D7_LOJA "
cQuery +=  " FROM "+RetSqlName("SD7")+" SD7 "
cQuery += " WHERE SD7.D7_FILIAL='"+xFilial("SD7")+"'"
cQuery +=   " AND D7_PRODUTO = '" + cCod + "' "
cQuery +=   " AND D7_LOCAL = '"   + cLocal + "' "
cQuery +=   " AND D7_TIPO = "     + STR(0) + " "
cQuery +=   " AND D7_LIBERA  = ' ' "
cQuery +=   " AND D_E_L_E_T_ = ' ' "
cQuery +=   " ORDER BY D7_FILIAL, D7_NUMERO, D7_LOTECTL, D7_NUMLOTE "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD7,.T.,.T.)
aEval(SD7->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasSD7,x[1],x[2],x[3],x[4]),Nil)})

dbSelectArea(cAliasSD7)
dbGotop()
	
Do While !Eof()
		
	aSaldo := SldMovCQ( .F.,;
						(cAliasSD7)->D7_PRODUTO,;
						(cAliasSD7)->D7_LOTECTL,;
						(cAliasSD7)->D7_NUMLOTE,;
						(cAliasSD7)->D7_NUMERO,;
						(cAliasSD7)->D7_NUMSEQ,;
						(cAliasSD7)->D7_DOC,;
						(cAliasSD7)->D7_SERIE,;
						(cAliasSD7)->D7_FORNECE,;
						(cAliasSD7)->D7_LOJA,;
						Nil,;
						dDataBase,;
						(cAliasSD7)->D7_LOCAL,;
						.F., .T. )				

	// Saldo Disponivel
        nSaldo    := aSaldo[1]
        nSaldo2UM := aSaldo[2]
        
   	// Verifica o saldo ja relacionado
		nAchou:=Ascan(aDadosTransf,{ |x| x[1]  == cFilOrig  .And.;
		                               	x[2]  == (cAliasSD7)->D7_PRODUTO .And.;
		                                x[3]  == (cAliasSD7)->D7_LOCAL   .And.;
		                                x[17] == (cAliasSD7)->D7_LOTECTL .And.;
		                                x[18] == (cAliasSD7)->D7_NUMLOTE .And.;
		                                x[22] == (cAliasSD7)->D7_NUMSEQ})
	If nAchou>0
		// Subtrai o consumo do saldo disponivel
		nSaldo   := nSaldo    - aDadosTransf[nAchou,4]
		nSaldo2UM:= nSaldo2UM - aDadosTransf[nAchou,5]
	EndIf
		                                   
	// Adiciona o saldo de CQ no array de consulta
	If nSaldo > 0
			AADD(aArrayF4, {(cAliasSD7)->D7_NUMERO	,;  			   		//Numero do CQ
							Str(nSaldo		,aTamQtde[1],aTamQtde[2]),;		//Saldo a Transferir
							Str(nSaldo2UM	,aTamQtde[1],aTamQtde[2]),;		//Saldo a Transferir na 2UM
							(cAliasSD7)->D7_NUMSEQ	,;				   		//Nro. Sequencial
							(cAliasSD7)->D7_LOCAL	,;						//Armazem de Origem
							(cAliasSD7)->D7_DATA	,;				 		//Data de entrada no CQ
							(cAliasSD7)->D7_LOTECTL	,;				   		//Lote
							(cAliasSD7)->D7_NUMLOTE })				   		//SubLote
	EndIf
	dbSkip()
EndDo
(cAliasSD7)->(dbCloseArea())
dbSelectArea("SD7")
// Restaura para a Filial Corrente
cFilAnt := cFilBkp

If !Empty(aArrayF4)

	AAdd( aObjects, { 100, 100, .T., .T.,.T. } )
	AAdd( aObjects, { 100, 30, .T., .F. } )

	aSize[ 3 ] -= 50
	aSize[ 4 ] -= 50 	
	
	aSize[ 5 ] -= 100
	aSize[ 6 ] -= 100
	
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg2 TITLE cCadastro From aSize[7],00 To  aSize[6],aSize[5] OF oMainWnd PIXEL	
                                                                                                                                                                                                                                                
		aHeaderF4 := {STR0082,STR0085,STR0095,STR0086,STR0087,STR0088,STR0089,STR0090,STR0091,STR0092} //"Numero CQ","Saldo a Transf.","Sld. Transf. 2UM","Nr.Sequencial","Armazem Orig.","Data CQ.","Lote","SubLote","Endereco CQ","Nro. Serie"

        oQual := VAR := cVar := TWBrowse():New( aPosObj[1][1], aPosObj[1][2], aPosObj[1][3], aPosObj[1][4],,aHeaderF4,,,,,,,{|nRow,nCol,nFlags|(nOpca := 1,oDlg2:End())},,,,,,, .F.,, .T.,, .F.,,, )
		oQual:SetArray(aArrayF4)
		oQual:bLine := { || aArrayF4[oQual:nAT] }
	
	DEFINE SBUTTON FROM aPosObj[2][1]+10 ,aPosObj[2][4]-58  TYPE 1 ACTION (nOpca := 1,oDlg2:End()) ENABLE OF oDlg2
	DEFINE SBUTTON FROM aPosObj[2][1]+10 ,aPosObj[2][4]-28  TYPE 2 ACTION oDlg2:End() ENABLE OF oDlg2
	
	ACTIVATE MSDIALOG oDlg2 VALID (nOAT := oQual:nAT,.T.) CENTERED
	
	If nOpca ==1
		// Carrega as informacoes de Lote/SubLote
		If Rastro(cProduto1,'S')
			SB8->(dbSetOrder(2))
			If SB8->(dbSeek(xFilial('SB8') + aArrayF4[nOAT][8] + aArrayF4[nOAT][7] + cProduto1 + cLocOrig, .F.))
				cLoteDigi := SB8->B8_LOTECTL
				dDtValid2 := SB8->B8_DTVALID  
				cNumLote  := SB8->B8_NUMLOTE
			Else
				Help(' ', 1, 'A310LOTERR')
				lRet := .F.
			EndIf
		ElseIf Rastro(cProduto1,"L")
			SB8->(dbSetOrder(3))
			If SB8->(dbSeek(xFilial('SB8')+cProduto1+cLocOrig+aArrayF4[nOAT][7], .F.))
				dDtValid2 :=SB8->B8_DTVALID  
				cLoteDigi :=SB8->B8_LOTECTL
			Else
				Help(' ', 1, 'A310LOTERR')
				lRet := .F.
			EndIf
		EndIf
		nQuant    := Val(aArrayF4[ nOAT, 2 ])
		nQuant2UM := Val(aArrayF4[ nOAT, 3 ])
		cNumSeqCQ :=     aArrayF4[ nOAT, 4 ]
	EndIf
Else
	Help(' ',1,'A310SEMCQ')
EndIf
RestArea(aAreaAnt)
SetFocus(nHdl)
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A310IsCQ  ³ Autor ³ TOTVS S/A            ³ Data ³ 26/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se o armazem da filial Origem e CQ                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A310IsCQ()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A310IsCQ()
Local lRet    := .F.
Local cFilBkp := cFilAnt
Local lTranCQ := IsTranCQ()
// Ajusta para filial origem
cFilAnt := cFilOrig
// Verifica se o usuario selecionou o armazem de CQ
If lTranCQ .And. cLocOrig == GetMvNNR('MV_CQ','98')
	lRet := .T.
EndIf
// Restaura filial correnta
cFilAnt := cFilBkp
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ a310AtuOri³ Autor ³ Isaias Florencio     ³ Data ³ 03/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza saldo atual do produto de origem                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ a310AtuOri()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function a310AtuOri(aDadosOri,nAcho,lTranCQ)
Local aAreaAnt := GetArea()
Local aAreaSB2 := SB2->(GetArea())
Local cLocalCQ := GetMvNNR('MV_CQ','98')
Local nQuantTrf:= 0
Local nX       := 0

Default lTranCQ:= .F.

If ValType(aDadosTransf) == "A" .And. !Empty(aDadosTransf)
	For nX := 1 To Len(aDadosTransf)
		If aDadosTransf[nX,2]+aDadosTransf[nX,3] == aDadosOri[nAcho][6]+aDadosOri[nAcho][7]
			nQuantTrf += aDadosTransf[nX,4]
		EndIf
	Next nX
EndIf

// Somente atualizar o saldo quando nao utilizar transferencia entre CQ's
If !(lTranCQ .And. AllTrim(aDadosOri[nAcho][7])==AllTrim(cLocalCQ))
	SB2->(DbSetOrder(1)) // FILIAL + CODIGO + LOCAL 
	SB2->(MsSeek(cFilOrig+aDadosOri[nAcho][6]+aDadosOri[nAcho][7]))
	
	aDadosOri[nAcho][2] := SB2->B2_QATU
	aDadosOri[nAcho][3] := SaldoMov(Nil, Nil,Nil,( mv_Par19 == 1 ), Nil,Nil,.T.,Nil,Nil) - nQuantTrf
	aDadosOri[nAcho][4] := SB2->B2_QTSEGUM
	aDadosOri[nAcho][5] := ConvUm(SB2->B2_COD,aDadosOri[nAcho][3],0,2)
EndIf	
RestArea(aAreaSB2)
RestArea(aAreaAnt)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M310GetUF ³ Autor ³ Materiais            ³ Data ³ 10/03/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna a UF do Fornecedor da Filial Destino               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M310GetUF(aDadosTransf,lTerceiros)

Local aArea		:= GetArea()
Local aAreaSA2	:= SA2->(GetArea())
Local cFilAux	:= cFilAnt
Local cUF		:= ""

cFilAnt := aDadosTransf[6]

If lTerceiros
	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+aDadosTransf[8]+aDadosTransf[9])
		cUF := SA1->A1_EST
	EndIf
Else
	dbSelectArea("SA2")
	dbSetOrder(1)
	If dbSeek(xFilial("SA2")+aDadosTransf[10]+aDadosTransf[11])
		cUF := SA2->A2_EST
	EndIf
EndIf

cFilAnt := cFilAux

RestArea(aAreaSA2)
RestArea(aArea)

Return cUF

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A310VldOp ³ Autor ³ Materiais            ³ Data ³ 30/03/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a digitacao dos perguntes de TES e Operacao do TES  ³±±
±±³          ³ Inteligente.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A310VldOp()

Local lRet := .T.

// Valida o TES e Operacao de SAIDA
If Empty(mv_par13) .And. Empty(mv_par22)
	Aviso("TESSSAIDA",STR0096,{"Ok"})//"Informe um TES ou um Tipo de Operação (TES Inteligente) para a Saída."
	lRet := .F.
EndIf
// Valida o TES e Operacao de ENTRADA
If Empty(mv_par15) .And. Empty(mv_par23)
	Aviso("TESENTRADA",STR0097,{"Ok"})//"Informe um TES ou um Tipo de Operação (TES Inteligente) para a Entrada."
	lRet := .F.
EndIf

// Valida a Especie do Documento de Entrada                               
If SuperGetMV("MV_ESPOBG",.F.,.F.) .And. Empty(mv_par20)
	Help(,,"ESPDOCENT",,STR0104,1,0)//"Informe Especie Documento de Entrada."
	lRet := .F.
Else
	If !ExistCpo('SX5','42'+mv_par20)                               
		lRet := .F.
	Endif
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Tela para informar os produtos manualmente
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a310SelPro()
Local oDlg
Local aStruct  := {}
Local nX	   := 0
Local aButtons := {}
Local nCnt     := 0
Local nUsado   := 0
Local nY	   := 0
Local nPosDel  := 0
Local aProd    := {}
Local cCampoSX3   as character
Local aTamanhoSX3 as array
Local nTamanho    as numeric
Local nDecimal    as numeric
Local cTipo       as character

Private aHeader	:={}
Private acols   :={}
Private oGetDB

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SB1")
While !Eof() .and. SX3->X3_ARQUIVO == "SB1"

	cCampoSX3 := AllTrim(SX3->X3_CAMPO)
	If cCampoSX3 == "B1_COD" .or. cCampoSX3 == "B1_DESC"

		aTamanhoSX3 := TamSX3(cCampoSX3)
		nTamanho := aTamanhoSX3[1]
		nDecimal := aTamanhoSX3[2]
		cTipo := SX3->X3_TIPO

		AADD(aHeader,{ Trim(X3Titulo()), cCampoSX3, X3Picture(cCampoSX3), nTamanho, nDecimal, ;
						Iif(cCampoSX3== "B1_DESC","","ExistCPO('SB1')"), "", cTipo,;
						IiF (cCampoSX3 == "B1_COD","SB1",""),;
						Iif(cCampoSX3== "B1_DESC","V",SX3->X3_CONTEXT),;
						SX3->X3_CBOX, SX3->X3_RELACAO, "",; 
						Iif(cCampoSX3== "B1_DESC",SX3->X3_VISUAL,"A"),,,.T.})
		AADD(aStruct,{cCampoSX3,cTipo,nTamanho,nDecimal})
	EndIf
	DbSkip()
End

// Define aCols da GetDados
dbSelectArea("SB1")
dbsetorder(1)
dbseek(xFilial('SB1')+Replicate('Z',Tamsx3('B1_COD')[1]))
dbskip()
aAdd( aCols,  Array(Len(aHeader)+1))

nCnt++
nUsado:=0

For nX:= 1 To Len(aHeader)
	nUsado++
	If aHeader[nX][10] == "V"
		aCols[nCnt][nUsado] := CriaVar(AllTrim(aHeader[nX][2]))
	Else
		aCols[nCnt][nUsado] := &(aHeader[nX][2])
	Endif   
Next nX
nPosDel := nUsado+1
aCols[nCnt][nPosDel] := .F.

oDlg := MSDIALOG():New(000,000,500,600, "Lista de produtos",,,,,,,,,.T.)
oGetDB := MsnewGetDados():New(35,10,250,300,GD_UPDATE+GD_INSERT+GD_DELETE,,,/* cIniCpos*/,{'B1_COD'},/* nFreeze*/,/* nMax*/,"a310SPDES",,,oDLG,aHeader,aCols)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||aProd:=aClone(oGetDB:aCols),oDlg:End()},{||oDlg:End()},,aButtons)

//Tratamento para adicionar no array principal apenas itens não deletados
For nY := 1 to Len(aProd)
	If aProd[nY][nPosDel] == .F.
		AADD(aLstProd,aProd[nY])
	EndIf
Next nY

Return 

Function a310SPDES()
Local lRet		:= .T.
Local cCampo	:= AllTrim(ReadVar())
Local nCont	:= 0

If cCampo == "M->B1_COD"
	oGetDB:aCols[oGetDB:nAt][2]	:= POSICIONE('SB1',1,xFilial('SB1')+M->B1_COD,'B1_DESC')
	M->B1_DESC := oGetDB:aCols[oGetDB:nAt][2]
	For nCont := 1 to Len(oGetDB:aCols)
		If nCont <> oGetDB:nAt
			If M->B1_COD == oGetDB:aCols[nCont][1] 
				MsgInfo ('O produto '+alltrim(M->B1_COD)+' Ja foi selecionado anteriormente na linha '+cValtochar(ncont))
			Endif
		Endif
	Next nCont
	Dbselectarea('SB1')
	dbsetorder(1)
	If !MsSeek(xfilial('SB1')+M->B1_COD)
		MsgInfo ('Produto '+alltrim(M->B1_COD)+' Inexistente')
	Endif 
EndiF
	
Return lRet

/*/{Protheus.doc} A310VldPrd
//Função que valida a relação do código origem e destino
@author andre.oliveira
@since 20/03/2020
@version 1.0
@return lRet, Indica se a relação é valida
@param cFilOri, characters, Código da filial de origem
@param cPrdOri, characters, Código do produto de origem
@param cFilDes, characters, Código da filial de destino
@param cPrdDes, characters, Código do produto de destino
@param lPoder3, characters, Identifica se é processo de poder 3
@type function
/*/
Function A310VldPrd(cFilOri,cPrdOri,cFilDes,cPrdDes,lPoder3)
	Local lRet			:= .T.
	Local cMVTRFVLDP	:= SuperGetMV("MV_TRFVLDP",.F.,"1")	//-- 1: códigos iguais; 2: SA5; 3: Não valida
	Local cFornece		:= ""
	Local cLoja			:= ""
	Local cFilBkp		:= cFilAnt

	Default lPoder3 := .F.

	//-- Codigo origem deve ser igual ao destino
	If cMVTRFVLDP == "1"
		lRet := cPrdOri == cPrdDes
	//-- Valida pelo SA5
	ElseIf cMVTRFVLDP == "2"
		cFilAnt := cFilDes //-- Altera filial logada
		lRet := A310VlForn(cFilOri,cFilDes,@cFornece,@cLoja,lPoder3) //-- Obtem codigo e loja da filial origem
		cFilAnt := cFilBkp //-- Restaura filial original

		If lRet
			BeginSQL Alias "SA5TMP"
				SELECT A5_FORNECE,
					A5_LOJA
				FROM %Table:SA5%
				WHERE %NotDel% AND
					A5_FILIAL = %Exp:xFilial("SA5",cFilDes)% AND
					A5_FORNECE = %Exp:cFornece% AND
					A5_LOJA = %Exp:cLoja% AND
					A5_PRODUTO = %Exp:cPrdDes% AND
					A5_CODPRF = %Exp:cPrdOri%
			EndSQL
			lRet := !SA5TMP->(EOF())
			SA5TMP->(dbCloseArea())
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} A310VlForn
//Função que valida a relação do código origem e destino
@author andre.oliveira
@since 20/03/2020
@version 1.0
@return lRet, Indica se a relação é valida
@param cFilDes, characters, Código da filial de destino
@param cFornece, characters, Recebe código do fornecedor (referencia)
@param cLoja, characters, Recebe loja do fornecedor (referencia)
@param lPoder3, characters, Identifica se é processo de poder 3
@type function
/*/
Static Function A310VlForn(cFilOri,cFilDes,cFornece,cLoja,lPoder3)
	Local lUsaFilTrf := UsaFilTrf()
	Local cArqIdx    := ""
	Local nIndex     := 0
	Local aSM0       := FWLoadSM0(.T.,,.T.) 
	Local nAcho 	 := aScan(aSM0,{|x| x[SM0_GRPEMP] == cEmpAnt .and. x[SM0_CODFIL] == cFilOri})
	Local lRet		 := .T.

	Default lPoder3 := .F.

	dbSelectArea("SA2")
	If lUsaFilTrf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta filtro e indice temporario na SA2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArqIdx := CriaTrab(,.F.)
		IndRegua("SA2", cArqIdx, "A2_FILIAL+A2_FILTRF",,,STR0076) //"Selecionando Registros ..."
		nIndex := RetIndex("SA2")
		dbSetOrder(nIndex+1) // A2_FILIAL+A2_FILTRF
	Else
		dbSetOrder(3)
	EndIf

	If !lPoder3
		If !dbSeek(xFilial("SA2")+IIF(!lUsaFilTrf, PadR(aSM0[nAcho,SM0_CGC],Len(SA2->A2_CGC)),cFilOri))
			// Nao existem dados da filial origem cadastrados como fornecedor na filial destino. A transferencia nao sera realizada
			Help(" ",1,"A310DATFL2")
			lRet:=.F.
		ElseIf !CliForOrig('SA2', @cFornece, @cLoja, lUsaFilTrf)
			// Os registros da filial origem estão bloqueados para uso. 
			Help(" ",1,"A310FORBLQ")
			lRet:=.F.
		EndIf
	EndIf

	// Apagar o indice temporario
	If lUsaFilTrf
		dbSelectArea("SA2")
		RetIndex("SA2")
		Ferase( cArqIdx + OrdBagExt() )
	EndIf
Return lRet

/*/{Protheus.doc} A310VlEsp
 Função que valida a Especie do Documento de Entrada na pergunta MTA310.
@author pedro.bruno
@since 25/05/2021
@version 1.0
@return lRet, Indica se Especie do Documento de Entrada é válida
@type function
/*/
Function A310VlEsp()
	Local lRet := .T.

	// Valida a Especie do Documento de Entrada                               
	If SuperGetMV("MV_ESPOBG",.F.,.F.) .And. Empty(mv_par20)
		Help(,,"ESPDOCENT",,STR0104,1,0)//"Informe Especie Documento de Entrada."
		lRet := .F.
	Else
		If !ExistCpo('SX5','42'+mv_par20)                               
			lRet := .F.
		Endif
	Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MA311Tela()
Função responsável por apresentar a tela na efetivação da transferência
entre filiais quando o pedido de venda está bloqueado.
@author Squad Entradas
@since 14/10/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MA311Tela(aBloqueio)
	Local oDlg, oQual
	Local cCadastro := STR0107

	DEFINE MSDIALOG oDlg TITLE cCadastro From 09,0 To 27.5,85 OF oMainWnd
	@ 0.5,0.5 LISTBOX oQual VAR cVar Fields HEADER STR0112,STR0113,STR0114,STR0115,STR0116 SIZE 280,130    //"Pedido"###"Item"###"Produto"###"Quantidade"###"Bloqueio"
	oQual:SetArray(aBloqueio)
	oQual:bLine := {|| {aBloqueio[oQual:nAT][1],aBloqueio[oQual:nAT][2],AllTrim(aBloqueio[oQual:nAT][4]),aBloqueio[oQual:nAT][5],;
	If(!Empty(aBloqueio[oQual:nAT][6]),STR0119,"") + If(!Empty(aBloqueio[oQual:nAT][7]),If(!Empty(aBloqueio[oQual:nAT][6]),"/" + STR0118,STR0118),"") +;
	If(!Empty(aBloqueio[oQual:nAT][8]),If(!Empty(aBloqueio[oQual:nAT][6]) .Or. !Empty(aBloqueio[oQual:nAT][7]),"/" + STR0120,STR0120),"")}}
	oQual:lHScroll := .F.
	@ 045,295 BUTTON STR0117 SIZE 030, 012 PIXEL OF oDlg ACTION (oDlg:End())
	@ 065,295 BUTTON STR0118 SIZE 030, 012 PIXEL OF oDlg ACTION MaViewSB2(aBloqueio[oQual:nAT][4])
	@ 085,295 BUTTON STR0112 SIZE 030, 012 PIXEL OF oDlg ACTION MA311VPed(aBloqueio[oQual:nAT][1])
	ACTIVATE MSDIALOG oDlg

Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} MA311VPed()
Função responsável por apresentar a tela na efetivação da transferência
entre filiais quando o pedido de venda está bloqueado.
@author Squad Entradas
@since 14/10/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MA311VPed(cPedido)

	//Desabilita a função F4 para não apresentar erro na visualização do pedido
	SetKey( VK_F4, Nil)	 

	//Posiciona no pedido de venda
	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek(xFilial("SC5")+cPedido)

	MATA410(,,,,"A410Visual")

	//Restaura a consulta F4.
	SetKey(VK_F4,{|| A311SetKey() })

Return
