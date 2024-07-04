#INCLUDE "TMKA273.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"

STATIC aDescEsca												// Usado na funcao TKREGRADESC 
STATIC lChecaKit  := SuperGetMv("MV_TMKKIT")                    // Indica se o sistema vai lancar automaticamente KIT 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA273   º Autor ³ Vendas Clientes     º Data ³  28/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Este fonte possui somente funcoes de uso exclusivo do        º±±
±±º          ³atendimento TELEVENDAS.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TELEVENDAS  						               			   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271EvaLi³ Autor ³ Vendas Clientes       ³ Data ³ 06/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a validade da linha digitada do item atual do TLV  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273EvaLi()

Local lTkEvali	:= ExistBlock("TKEVALI")			// P.E. para TLV
Local nPProd		:= aPosicoes[1][2]				// Posicao do Produto
Local nPQtd		:= aPosicoes[4][2]					// Posicao da Quantidade
Local nPVrUnit	:= aPosicoes[5][2]					// Posicao do Valor Unitario
Local nPVlrItem	:= aPosicoes[6][2]					// Posicao do Valor do item
Local nPTes		:= aPosicoes[11][2]					// Posicao do Tes
Local nValRet		:= 0									// Valor de retorno do desconto no cabecalho (Regra de Desconto)
Local lRet			:= .T.									// Retorno da funcao
Local lFoundTes	:= .T.									// Retorno do DbSeek

If lTkEvali
	If !ExecBlock( "TKEVALI", .F., .F. )
		lRet := .F.
	Endif
Endif

// Se a linha não estiver apagada
If lRet .AND. !aCols[n][Len(aHeader)+1]

	// Se o produto, a quantidade ou o preco unitário e do item estiverem vazios, não avança
	If Val(M->UA_OPER) <> ATENDIMENTO .AND. ! Empty(M->UA_OPER)
		If 	Empty(aCols[n][nPProd])		.OR.;
			Empty(aCols[n][nPVrUnit])	.OR.;
			Empty(aCols[n][nPTes])
			Help(" ",1,"A010VAZ")
			lRet := .F.
		Endif
	Endif

	If Val(M->UA_OPER) == ATENDIMENTO .And. Empty( aCols[n][nPProd] )
		lRet := .F.
	Else
		// Se a quantidade ou o valor total for igual a 0,00
		If Empty( aCols[n][nPQtd] ) .OR. Empty( aCols[n][nPVlrItem] )
			// Se a TES não permite nao lança
			If ! MaTesSel(aCols[n][nPTes])
					Help(" ",1,"A410VZ")
					lRet := .F.
			Else
				// Caso contrário, atualiza a flag para que o sistema considere o valor e quantidade = 0,00
				lTesTit := .F.
			EndIf
		EndIf
	EndIf

	If lRet
		DbSelectArea("SF4")
		DbSetOrder(1)
		lFoundTes := DbSeek(xFilial("SF4") + aCols[n][nPTes])

		If !lFoundTes
			Help( " ",1,"A010TES")
			lRet := .F.
			// (Localizações) Quando o tipo for "3" não pode haver movimentação de estoque
		ElseIf cPaisLoc <> "BRA" .AND. (Type(M->UA_DOCGER) <> "U" .AND. M->UA_DOCGER == "3")
			If SF4->F4_ESTOQUE == "S"
				Help(" ",1,"A410RMFUT")
				lRet := .F.
			Endif
		Endif

		// Aplica a regra da TABELA DE DESCONTOS no Cabecalho e executa o cálculo da linha considerando: DESCONTO EM CASCATA + DESCONTO DO ITEM
		If lRet
			nValRet := TkRegraDesc(	2 ,aValores[TOTAL] ,@M->UA_DESC4 ,NIL ,M->UA_CONDPG , NIL)
			// Se existe um desconto de cabeçalho nas regras de desconto, atualiza o campo M->DESC4
			If nValRet < 0
				nValRet := 0
			Else
				M->UA_DESC4 := nValRet
			Endif
			//³Se foi aplicado o valor de indenização, calcula o total do desconto no fim de todos os cálculos
			If M->UA_PDESCAB > 0 .And. nValRet <> 0
				Tk273CalcDesc()
			Endif
		Endif
	Endif

	// Se for atendimento, libera a linha, mostrando assim apenas as mensagens
	If !lRet .AND. Val(M->UA_OPER) == ATENDIMENTO .AND. !Empty(M->UA_OPER)
		lRet := .T.
	EndIf

	// Ponto de Entrada M410ACDL - Utilizado para validar os itens liberados que possuam Ordem de Separação (SIGAACD)
	If lRet .And. ExistTemplate("M410ACDL")
		lRet := ExecTemplate("M410ACDL",.F.,.F.)
	EndIf
	If lRet .And. ExistBlock("M410ACDL")
		lRet := ExecBlock("M410ACDL",.F.,.F.)
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271DelTlv  ³ Autor³ Vendas Clientes       ³ Data ³ 01/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Recalcula os valores do pedido ao deletar o item              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Valor dos Juros                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK273DelTlv(nVlJur, nOpc)

Local aAreaSC6	:= SC6->(GetArea())						// Salva area da tabela SC6 -> Itens do Pedido de Vendas
Local cPrcFiscal	:= TkPosto(M->UA_OPERADO,"U0_PRECOF") 	// Preco fiscal bruto 1=SIM / 2=NAO
Local nLinha		:= 0										// Contador informando a partir de qual linha sera atualizado		
Local nPProd		:= aPosicoes[1][2]						// Produto	
Local nPVlrItem	:= aPosicoes[6][2] 						// Posicao do Valor do Item 	
Local nPValDesc	:= aPosicoes[10][2]						// Posicao do Valor do Desconto	em Valor
Local nPItem		:= aPosicoes[20][2]						// ItemPV
Local lTMKVDEL	:= ExistBlock("TMKVDEL")				// P.E. do TLV
Local lTKVDACR	:= Iif(SuperGetMV("MV_TMKLOJ",,.F. )== "S" .And. GetNewPar("MV_TKVDACR",.F.),.T.,.F.)	//Se possuir integração com o SIGALOJA, faz o cálculo do acrescimo sobre o total menos o desconto.
Local lRet			:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recalcula os valores somente para os itens que nao foram deletados.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinha := n

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a linha ja foi faturada, se sim nao permite a delecao da linha.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> 3
	DbSelectArea("SC6")
	DbSetOrder(1)
	If ! Empty(SUA->UA_NUMSC5)
		If DbSeek(xFilial("SC6") + SUA->UA_NUMSC5 + aCols[nLinha][nPItem] + aCols[nLinha][nPProd])
			If !Empty(SC6->C6_QTDENT)	// Verifica se a quantidade entregue está preenchida
				Help("",1,"A410FAT")
				(aCols[nLinha][Len(aHeader)+1]) := .F.
				lRet	:= .F.
			EndIf
		EndIf
	EndIf
EndIf

If lRet
	If ! Empty(aCols[nLinha][1])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a linha for valida       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (!aCols[nLinha][Len(aHeader)+1])
			If (cPrcFiscal == "1")	//SIM
				aValores[DESCONTO] += aCols[nLinha][nPValDesc]
			Endif
			aValores[MERCADORIA] += aCols[nLinha][nPVlrItem]
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a linha  estiver apagada ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (aCols[nLinha][Len(aHeader)+1])
			If (cPrcFiscal == "1")	//SIM
				aValores[DESCONTO] -= aCols[nLinha][nPValDesc]
			Endif
			aValores[MERCADORIA] -= aCols[nLinha][nPVlrItem]
		Endif
	Endif

	//Caso possua valor de % de indemização, força o recálculo do desconto.
	If M->UA_PDESCAB > 0
		Tk273CalcDesc()
	EndIf

	If lTKVDACR .And. M->UA_OPER == "2"
		Tk273RodImposto("NF_DESCONTO",aValores[DESCONTO])
		Tk273RodImposto("NF_DESPESA",aValores[DESPESA])
	Else
		Tk273RodImposto("NF_DESPESA",aValores[DESPESA])
		Tk273RodImposto("NF_DESCONTO",aValores[DESCONTO])
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deleta o item da rotina fiscal ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !MaFisFound("IT",n)
		MaFisAdd( "", "", 0,  0,;
		          0,  "", "", NIL,;
		          0,  0,  0,  0,;
		          0)
	Endif
	MaFisDel(n,aCols[n][Len(aCols[n])])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza novamente os valores, pois quando um item é deletado³
	//³o valor é diminui devido o rateio, por exemplo:              ³
	//³                                                             ³
	//³O atendimento tem 3 itens                                    ³
	//³Depesa é igual a 1,00                                        ³
	//³MaFisFound/Add/Del                                           ³
	//³Ficam 2 itens                                                ³
	//³Despesa é igual a 0,67                                       ³
	//³                                                             ³
	//³Por esse motivo é necessário re-informar os valores.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk273RodImposto("NF_FRETE",aValores[FRETE])
	If lTKVDACR .And. M->UA_OPER == "2"
		Tk273RodImposto("NF_DESCONTO",aValores[DESCONTO])
		Tk273RodImposto("NF_DESPESA",aValores[DESPESA])
	Else
		Tk273RodImposto("NF_DESPESA",aValores[DESPESA])
		Tk273RodImposto("NF_DESCONTO",aValores[DESCONTO])
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o valor de acordo com os detalhes da condicao ³
	//³de pagamento                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk273RecCpg()

	Eval(bRefresh)

	If lTMKVDEL
		ExecBlock( "TMKVDEL", .F., .F. )
	Endif
EndIf

RestArea(aAreaSC6)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tk271FRefresh³ Autor ³ Vendas Clientes        ³ Data ³ 10/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa o refresh nos objetos do array.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273FRefresh()

Local nX := 0			// Contador

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao estiver usando a entrada automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTk271Auto 
	For nX := 1 to Len(aObj)
		If ValType(aObj[nX]) <> "U"
	 		aObj[nX]:Refresh()
	 	EndIf
	Next nX
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tk271Refresh ³ Autor ³ Vendas Clientes     ³ Data ³ 10/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa o Refresh do Folder.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                        
Function Tk273Refresh(lForca)

Local aArea		:= GetArea()	   				// Salva a area atual
Local lMV_TMKFIS:= IIf(lTk271Auto, .T., GetNewPar("MV_TMKFIS",.T.))	// (Não divulgar) Parametro que indica que a atualização da MATXFIS é feita de maneira on-line, no off-line a MATXFIS só é atualizada quando se entra na condição de pagamento.
Local nX 		:=0     
Local nPQtd 	:= aPosicoes[4][2]		   		// Posicao da Quantidade
Local nPVrUnit  := aPosicoes[5][2]
Local nPVlrItem := aPosicoes[6][2]				// Posicao do Valor do item 

Default lForca	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando o parâmetro MV_TMKFIS estiver como .F.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->UA_CLIENTE) .And. (lMV_TMKFIS .Or. lForca)

	//Para nao aplicar o suframa ao item, que sera aplicado apenas no total.
	If MaFisRet(, "NF_DESCZF") > 0 
		For nX := 1 To Len(aCols)
			If !GDDeleted(nX)
				aCols[nX][nPVlrItem] := A410Arred(aCols[nX][nPQtd]*aCols[nX][nPVrUnit],"UB_VLRITEM")
			EndIf 
		Next nX
	EndIf
	
	//Não considera o acréscimo financeiro e nem o desconto de SUFRAMA no valor da mercadoria 
	aValores[MERCADORIA] := MaFisRet(, "NF_VALMERC") - aValores[ACRESCIMO]
	aValores[SUFRAMA]	 := MaFisRet(, "NF_DESCZF")
	aValores[TOTAL]		 := MaFisRet(, "NF_TOTAL")  
	aValores[BASEDUP]	 := MaFisRet(, "NF_BASEDUP")
	
EndIf

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271TlvImp ³ Autor ³ Vendas Clientes     ³ Data ³ 08/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o folder do rodape com REFRESH                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk273TlvImp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o item do pedido de venda  ³
//³foi eliminado por resíduo. (MV_RSDOFAT)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Tk273VldRes()
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao estiver usando a entrada automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  !lTk271Auto 
	Eval(bFolderRefresh)
	oFoldRodape:Refresh()
Endif	

Return(.T.)

/*                                    
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Tk271Descont³ Autor ³ Vendas Clientes    ³ Data ³ 28/07/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para validar o desconto no rodape de acordo com o   ³±±
±±³          ³ posto de venda do operador                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Referencia ( vide MATXFIS)                         ³±±
±±³          ³ ExpC2 = Valor da Referencia                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273Desconto(cReferencia,xValor)

Local nDesconto := &( ReadVar() )  							//Valor informado no rodape de DESCONTO
Local cDesconto := TkPosto(M->UA_OPERADO,"U0_DESCONT")		//Posto de venda
Local nPVlrItem	:= aPosicoes[6][2]	
Local nPTes	    := aPosicoes[11][2]					// Posicao do Tes 	
Local nLinha 	:= 1
Local lTKVDACR	:= Iif(SuperGetMV("MV_TMKLOJ",,.F. )== "S" .And. GetNewPar("MV_TKVDACR",.F.),.T.,.F.)	//Se possuir integração com o SIGALOJA, faz o cálculo do acrescimo sobre o total menos o desconto.
Local lSimpNac	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³So pode dar desconto se o Posto de venda estiver configurado para Item ou Ambos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (AllTrim(cDesconto) <> "2") .AND. (AllTrim(cDesconto) <> "3")   // Ambos ou Total
	If  !lTk271Auto 
		Help( " ", 1, "NAO_DESCON")
	Endif	
	nDesconto 		   := 0
	aValores[DESCONTO] := 0
Else
	If MaFisFound()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Rateio do desconto do rodape nos itens                                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aValores[DESCONTO])
			lSimpNac := Tk273SimpNacBA()
			For nLinha := 1 to len(aCols)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Recalcula os valores somente para os itens que nao foram deletados.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (!aCols[nLinha][Len(aHeader)+1]) 
					DbSelectArea("SF4")
					DbSetOrder(1)
					If DbSeek(xFilial("SF4") + aCols[nLinha][nPTes]) .And. ((GetNewPar("MV_TPDPIND","1")=="1") .Or. (GetNewPar("MV_TPDPIND","1")=="2" .And. SF4->F4_DUPLIC='S'))
						If !lSimpNac
							MaFisAlt("IT_DESCONTO",(aValores[DESCONTO]/aValores[TOTAL])*aCols[nLinha][nPVlrItem],nLinha)
						EndIf
					Endif
				EndIf	
			Next nLinha
		EndIf
		If lTKVDACR .And. M->UA_OPER == "2"
			Tk273RecCpg()
		EndIf
		Tk273RodImposto(cReferencia,xValor)
	Endif	
Endif

Eval(bRefresh)
	
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tk271RodImposto ³Autor  ³ Vendas Clientes ³ Data ³ 26/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Configura MATXFIS de acordo a solicitação por parâmetro    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Referencia ( vide MATXFIS)                         ³±±
±±³          ³ ExpC2 = Valor da Referencia                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk273RodImposto(cReferencia, xValor)

Local aArea		:= GetArea()					// Salva a area atual
Local lMV_TMKFIS:= IIf(lTk271Auto, .T., GetNewPar("MV_TMKFIS",.T.))	// (Não divulgar) Parametro que indica que a atualização da MATXFIS é feita de maneira on-line, no off-line a MATXFIS só é atualizada quando se entra na condição de pagamento.
Local lSimpNac	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o parâmetro MV_TMKFIS estiver como .F., não faz a    ³
//³atualização da matxfis, pois esse processo demora demais³
//³quando há muitos itens na televendas. Essa atualização  ³
//³só ocorre quando a condição de pagamento é executada.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MaFisFound("NF") .AND. !(MaFisRet(,cReferencia) == xValor) .AND. lMV_TMKFIS
	lSimpNac := Tk273SimpNacBA()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Workaround para forçar o cálculo correto de suframa, sem  ³
	//³esse workaround a matxfis distribui incorretamente o valor³
	//³suframa entre os itens da televendas.                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cReferencia == "NF_FRETE" .Or. cReferencia == "NF_DESPESA" .Or.;
		(cReferencia == "NF_DESCONTO" .And. !lSimpNac)
		//Refaz os cálculos dos impostos
		MaFisAlt(cReferencia, 0)
		Tk273TpCliRecal(MaFisRet(,"NF_TPCLIFOR"))
	EndIf

	If cReferencia == "NF_TPCLIFOR" .And. (ReadVar() == "M->UA_TIPOCLI")
		xValor := &(ReadVar())
		//Refaz os cálculos dos impostos na mudança do tipo de cliente/fornecedor
		Tk273TpCliRecal(xValor)
	ElseIf !lSimpNac
		MaFisAlt(cReferencia,xValor)
	EndIf

	Tk273AtuNFs()
		
Endif

RestArea(aArea)	
Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tk273AtuNFs     ³Autor  ³ Vendas Clientes ³ Data ³ 17/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo de valores de FRETE, DESCONTO e DESPESA   ³±±
±±³          ³nos IMPOSTOS e no total do pedido.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk273AtuNFs()

Local aArea	     := GetArea()	     // Salva a area atual

If !Tk273SimpNacBA(.T.)
	MaFisAlt("NF_DESCONTO", aValores[DESCONTO])	
EndIf
MaFisAlt("NF_FRETE",aValores[FRETE])
MaFisAlt("NF_DESPESA",aValores[DESPESA])

Eval(bRefresh)
Eval(bGDRefresh)

RestArea(aArea)

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk273CalcDesc ºAutor  ³ Vendas Clientesº Data ³  07/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Aplica valor do % de Indenizacao no valor total de Desconto º±±
±±º          ³no Rodape                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TELEVENDAS                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273CalcDesc()

Local lRet   := .T.                  											// Retorno da funcao
Local nValor := 0																// Valor do desconto em PDESCAB
Local nAux 	 := 0 																// Valor auxiliar para calculo
                                                                                
If(ReadVar()== "M->UA_PDESCAB")
	nValor := &( ReadVar() )
Else
	nValor := M->UA_PDESCAB
Endif

If (nValor >= 0) .AND. MaFisFound("NF")
	nAux 				:= A410Arred((aValores[MERCADORIA] * nValor) /100,"D2_PRCVEN") 
	aValores[DESCONTO] 	:= nAux	
	Tk273RodImposto("NF_DESCONTO",nAux)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O total de descontos do cabecalho sera desabilitado                       ³ 
	//³porque nao e possivel controlar simultaneamente o desconto em % e no TOTAL³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lDesconto := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a indenizacao nao esta preenchida o Operador pode usar o desconto no TOTAL³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nValor == 0 
	lDesconto := .T.
Endif

Eval(bFolderRefresh)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271Calcula     ³ Autor ³ Vendas Clientes      ³ Data ³ 28/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o valor dos campos de desconto e acrescimo           		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tk271Calcula(ExpC1,ExpN2,ExpL3)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do campo para utilizacao na funcao                  ³±±
±±³          ³ ExpN2 = Linha do aCols para analise                              ³±±
±±³          ³ ExpL3 = Define se todos os campos serao calculados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas - SX3                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273Calcula(cCampo,nLinha,lTudo)

Local aAreaSC6	:= SC6->(GetArea())			// Salva area da tabela SC6
Local nValor   							    // Get atual do campo
Local nPProd    := aPosicoes[1][2]		   		// Posicao do Produto
Local nPQtd 	:= aPosicoes[4][2]		   		// Posicao da Quantidade
Local nPTes	    := aPosicoes[11][2]		   		// Posicao da TES
Local nPItem	:= aPosicoes[20][2]        		// Posicao do Item
Local nPPrcTab  := aPosicoes[15][2]				// Posicao do Preco de Tabela
Local nPCFO		:= aPosicoes[12][2]				// Posicao da CF
Local aListaKit	:= {}							// Itens do cadastro de KIT
Local nCont 	:= 0 							// Contador	de Itens do KIT
Local nAtual  	:= 0							// Linha atual depois da inclusao de KIT 
Local nColuna 	:= 1   							// Contador de colunas do aHeader
Local cItem 	:= ""							// Valor do item dos produtos (01,02,...)
Local lRet      := .F.							// Retorno da funcao
Local nPVrUnit  := aPosicoes[5][2]				// Posicao do Valor unitario
Local lReplace  := .F.							// Indica se o codigo do produto esta sendo alterado no acols
Local nPValDesc := aPosicoes[10][2]			// $ Desconto em Valor
Local cAltPed	:= SuperGetMV("MV_ALTPED")  // Parametro que permite a edição de pedido já faturado
Local lRsDoFAt  := IIF(SuperGetMv("MV_RSDOFAT") == "S",.F.,.T.)  // Parametro que permite a edição de pedido eliminado por residuo
Local lTKVDACR	:= Iif(SuperGetMV("MV_TMKLOJ",,.F. )== "S" .And. GetNewPar("MV_TKVDACR",.F.),.T.,.F.)	//Se possuir integração com o SIGALOJA, faz o cálculo do acrescimo sobre o total menos o desconto.
Local npCodFCI	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "UB_FCICOD"})
Local nPosItem		:= Ascan(aHeader,{|x| ALLTRIM(x[2])=="UB_ITEM"})
Local nAcresRat := 0
Local cNaturez  := Tk273DpNat(M->UA_CLIENTE,M->UA_LOJA) //Obtem Natureza do Cliente/Prospect

Default cCampo  := ReadVar() 
Default nLinha 	:= N						// Linha a ser utilizada no calculo
Default lTudo 	:= .F.						// Define se todas as linhas serao recalculadas

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz uma cópia do aCols quando é utilizado a edição por linha na MsGetDados.	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If !lTk271Auto .And. Type("oGetTlv") == "O" .And. Type("aColsEdit") == "A" .And.;
   oGetTlv:lEditLine .And. (cCampo == "UB_PRODUTO")
	aColsEdit := aClone(aCols) 
EndIf

//Checa se este item do pedido esta amarrado com alguma Ordem de Producao
If !Empty(M->UA_NUMSC5) .And. SuperGetMV("MV_ALTPVOP") == "N"
	DbSelectArea("SUB")
	DbSetOrder(1)
	If SUB->(DbSeek(xFilial('SUB')+M->UA_NUM+aCols[n][nPosItem]))
		DbSelectArea("SC6")
		DbSetOrder(1)
		If SC6->(DbSeek(xFilial('SC6')+SUB->UB_NUMPV+SUB->UB_ITEMPV))
			If SC6->C6_OP == "01"
				Help(" ",1,"A410TEMOP")
				Return(lRet)
			EndIf
		EndIf
	EndIf
EndIf

nValor := M->&(cCampo)		
If Empty(M->UA_CLIENTE)
	Help(" ",1,"SEM CLIENT")
	Return(lRet)
Endif	

SC6->(DbSetOrder(1))
If SC6->(DbSeek(xFilial("SC6") + M->UA_NUMSC5 + aCols[nLinha][nPItem] + aCols[nLinha][nPProd]))
	If cAltPed == "N" .AND. SC6->C6_QTDENT > 0
		Help("",1,"A410PEDFAT")
		RestArea(aAreaSC6)
		Return(.F.)
	ElseIf lRsDoFat .And. AllTrim(SC6->C6_BLQ) $ "RS"
		Help(" ",1,"A410ELIM")
		RestArea(aAreaSC6)
		Return(.F.)
	EndIf
	RestArea(aAreaSC6)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe os produtos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCampo <> "UB_PRODUTO"
	If Empty(aCols[nLinha][nPProd])
		Return(lRet)
	Endif
Else
	If	Upper(AllTrim(aCols[nLinha][nPProd])) <> Upper(AllTrim(nValor)) .AND.;
		Upper(AllTrim(aCols[nLinha][nPProd])) <> ""
		
		lReplace := .T.	
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento efetuado para carregar o código FCI ao informar o produto (Legislação FCI)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If npCodFCI > 0 .And. AllTrim(aHeader[npCodFCI][2]) == "UB_FCICOD"  //SIGAFIS
		aCols[n][npCodFCI] := Upper( XFciGetOrigem( M->UB_PRODUTO, M->UA_EMISSAO )[2] )	
	Endif
Endif  

Do Case
 	Case (cCampo == "UA_TABELA")
 	    nValor := aCols[nLinha][nPProd]
		lRet := TKP000A(nValor,nLinha,lTudo)

 	Case (cCampo == "UB_PRODUTO")
		lRet := TKP000A(nValor,nLinha,lTudo)
	
	Case (cCampo == "UB_QUANT")
		lRet := TKP000B(nValor,nLinha)
		
	Case (cCampo == "UB_VRUNIT")
		lRet := TkP000C(nValor,nLinha)
		
	Case (cCampo == "UB_DESC")
		lRet := TkP000D(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	
		
	Case (cCampo == "UB_VALDESC")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a TES utilizada e diferente da TES de bonificacao calcula os acrescimos e descontos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := TkP000E(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	
		
	Case (cCampo == "UB_ACRE")
		lRet := TkP000G(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	
			
	Case (cCampo == "UB_VALACRE")
		lRet := TkP000H(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	

Endcase

Eval(bRefresh)

MaFisAlt("IT_TES",aCols[nLinha][nPTes],nLinha)
If !Empty(cNaturez)
	MaFisAlt("NF_NATUREZA",cNaturez)
EndIf

If MaFisFound()		

	MaColsToFis(aHeader	, aCols	, nLinha	, "TK273"	,;
					.T.		)	

	aCols[nLinha][nPCFO] := TK273Cfo(,,aCols[nLinha][nPTes])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcula os valores influenciados pela condicao de pagamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk273RecCpg(,,nLinha,@nAcresRat) //Recalcula os valores influenciados pela condicao de pagamento

	If cCampo == "UA_TABELA" .OR. (cCampo == "UB_PRODUTO" .AND. !lReplace)
		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Em caso de alteracao de valor no aCols, atualiza a informacao na MatXFis atraves da    |
		//|função MaFisToCols() e MaFisAlt()                                                      |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisAlt("IT_QUANT",aCols[nLinha][nPQtd],nLinha)
		MaFisAlt("IT_PRCUNI",aCols[nLinha][nPVrUnit],nLinha)
		MaFisAlt("IT_VALMERC",A410Arred(aCols[nLinha][nPQtd]*(aCols[nLinha][nPVrUnit])+nAcresRat ,"UB_VLRITEM"),nLinha)
		MaFisAlt("IT_CF",aCols[nLinha][nPCFO],nLinha)

		If cPaisLoc == "BRA" .And. !Empty(aCols[nLinha][nPTes]) .And. ( M->UA_DESC4 > 0 .OR. M->UA_DESC1 > 0 .OR. M->UA_DESC2 > 0 .OR. M->UA_DESC3 > 0)
			SF4->(dbSetOrder(1))
			SF4->(dbseek(xFilial("SF4")+aCols[nLinha][nPTes]))
			If SF4->F4_IPI == "S" .And. SF4->F4_TPIPI == "B" 
				MaFisAlt("IT_BASEIPI",aCols[nLinha][nPPrcTab],nLinha)				
			EndIf			
		EndIf  

	Else	   
		                                               	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Em caso de alteracao de valor no aCols, atualiza a informacao na MatXFis atraves da    |
		//|função MaFisToCols() e MaFisAlt()                                                      |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		MaFisAlt("IT_QUANT",aCols[nLinha][nPQtd],nLinha)
		MaFisAlt("IT_PRCUNI",aCols[nLinha][nPVrUnit],nLinha)
		MaFisAlt("IT_VALMERC",A410Arred(aCols[nLinha][nPQtd]*(aCols[nLinha][nPVrUnit])+nAcresRat ,"UB_VLRITEM"),nLinha)
		MaFisAlt("IT_CF",aCols[nLinha][nPCFO],nLinha)

		If cPaisLoc == "BRA" .And. cCampo $ ("UB_DESC/UB_VALDESC") .And. !Empty(aCols[nLinha][nPTes])
			SF4->(dbSetOrder(1))
			SF4->(dbseek(xFilial("SF4")+aCols[nLinha][nPTes]))
			If SF4->F4_TPIPI == "B"
				MaFisAlt("IT_BASEIPI",MaFisRet(nLinha,"IT_BASEIPI") + aCols[nLinha][nPValDesc],nLinha)				
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Incluido esta atualizacao, devido algumas funcoes alterarem o valor da despesa e do   |
		//| desconto, sem atualizar na matxfis.													  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTKVDACR .And. M->UA_OPER == "2"
			Tk273RodImposto("NF_DESCONTO",aValores[DESCONTO])
			Tk273RodImposto("NF_DESPESA",aValores[DESPESA])
		Else
			Tk273RodImposto("NF_DESPESA",aValores[DESPESA])
			Tk273RodImposto("NF_FRETE",aValores[FRETE]) 
			Tk273RodImposto("NF_DESCONTO",aValores[DESCONTO])
		EndIf

	Endif

	MaFisToCols(aHeader,aCols,nLinha,"TK273")

	If cCampo == "UB_PRODUTO" .Or. cCampo == "UB_QUANT" .And. aCols[nLinha][nPVrUnit]>0
		Tk273AtuNFs()
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atuliza o vetor aValores - Detalhes do rodape³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Eval(bRefresh)
Endif

If M->UA_PDESCAB > 0
	Tk273CalcDesc()
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se esse TES gera titulos para nao obrigar a selecao das condicoes de pagamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF4")
DbSetOrder(1)
If DbSeek(xFilial("SF4")+aCols[nLinha][nPTes])
	If SF4->F4_DUPLIC == "S"
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a TES nao estiver bloqueada valida se a quantidade pode ser igual a 0,00  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MaTesSel(aCols[nLinha][nPTes])
			lTesTit := .F.				
		Else
			lTesTit := .T.	
		Endif
	Else
		lTesTit := .F.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe o KIT no cadastro de acessorios³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lChecaKit) .AND. (cCampo == "UB_PRODUTO")
	
	DbSelectArea("SUG")
	DbSetOrder(2)
	If DbSeek(xFilial("SUG") + nValor)
		If nValor == SUG->UG_PRODUTO
			DbSelectArea("SU1")
			DbSetOrder(1)
			If DbSeek(xFilial("SU1")+SUG->UG_CODACE)
				While (! Eof()) .AND. (SU1->U1_FILIAL == xFilial("SU1")) .AND. (SU1->U1_CODACE == SUG->UG_CODACE)
						
					If SU1->U1_KIT == "1"  //SIM
						
						AADD(aListaKit,{SU1->U1_ACESSOR,;			//Codigo do Acessorio
										SU1->U1_QTD})				//Quantidade
					Endif
					
					SU1->(DbSkip())
				End
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pega o conteudo o ultimo item (Valor)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cItem 	:= aCols[Len(aCols)][nPItem]
			nAtual  := 0
			nAtual	:= Len(aCols)
			
			For nCont := 1 to Len(aListaKit)
				AADD(aCols,Array(Len(aHeader)+1))
				nAtual ++
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³X3_TITULO   1³
				//³X3_CAMPO    2³
				//³X3_PICTURE  3³
				//³X3_TAMANHO  4³
				//³X3_DECIMAL  5³
				//³X3_VALID    6³
				//³X3_USADO    7³
				//³X3_TIPO     8³
				//³X3_ARQUIVO  9³
				//³X3_CONTEXT 10³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inicializa as variaveis da aCols (tratamento para    ³
				//³campos criados pelo usu rio)							³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nColuna := 1 to Len( aHeader )
					
					If aHeader[nColuna][8] == "C"
						aCols[nAtual][nColuna] := Space(aHeader[nColuna][4])
						
					ElseIf aHeader[nColuna][8] == "D"
						aCols[nAtual][nColuna] := dDataBase
						
					ElseIf aHeader[nColuna][8] == "M"
						aCols[nAtual][nColuna] := ""
						
					ElseIf aHeader[nColuna][8] == "N"
						aCols[nAtual][nColuna] := 0
						
					Else
						aCols[nAtual][nColuna] := .F.
					Endif
					
				Next nColuna
				
				aCols[nAtual][Len(aHeader)+1] := .F.
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o aCols com o acessorio, atualizado o item o produto e a quantidade alem da funcao fiscal ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cItem 			 	  := Soma1(cItem,Len(cItem))
				aCols[nAtual][nPItem] := cItem
				
				M->UB_PRODUTO	 	  := aListaKit[nCont][1]
				aCols[nAtual][nPProd] := aListaKit[nCont][1]
				
				M->UB_QUANT  		 := aListaKit[nCont][2]
				aCols[nAtual][nPQtd] := aListaKit[nCont][2]
								
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualizar a variavel n, pois as funcoes fiscais usam ela como referencia                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				n := nAtual
				
				TKP000A(M->UB_PRODUTO,nAtual,NIL)
				
				n := nAtual

				TKP000B(M->UB_QUANT,nAtual)				                                                                       
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza as informacoes do acols em relacao a MatXFis para o novo item. |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				MaFisToCols(aHeader,aCols,nAtual,"TK273",.F.)
				Tk273Calcula("UB_PRODUTO",nAtual)                        				
				
			Next nCont
			n := nAtual
			M->UB_PRODUTO := nValor // Inicializa a variavel de memoria com o item pai

            Eval(bGDRefresh)
		Endif
	Endif
Endif    

lRet:= Iif (cCampo == "M->UB_TES",.T.,lRet) 

If M->UA_PDESCAB > 0
	Tk273CalcDesc()
Endif

Return(lRet)

/*                                                    
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TKP000A  ³ Autor ³ Vendas Clientes       ³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o preco de acordo com o produto -   UB_PRODUTO    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto                                  ³±±
±±³          ³ ExpN2 = Linha do aCols para analise                        ³±±
±±³          ³ ExpL3 = Define se todos os campos serao calculados         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkP000A(nValor,nLinha,lTudo)

Local lRet   	:= .F.						// Retorno da funcao
Local nPProd	:= aPosicoes[1][2]			// Posicao do Codigo do produto
Local nPDescri  := aPosicoes[2][2]			// Posicao da Descricao do Produto
Local nPSitProd := aPosicoes[3][2]			// Posicao da Situacao do Produto
Local nPQtd 	:= aPosicoes[4][2]			// Posicao da Quantidade
Local nPVrUnit  := aPosicoes[5][2]			// Posicao do Valor unitario
Local nPVlrItem	:= aPosicoes[6][2]			// Posicao do Valor do item
Local nPLocal   := aPosicoes[7][2]			// Posicao do Local
Local nPUm	    := aPosicoes[8][2]			// Posicao da Unidade de medida
Local nPTes	    := aPosicoes[11][2]         // Posicao da TES     			
Local nPCFO		:= aPosicoes[12][2]			// Posicao da CF
Local nPPrcTab  := aPosicoes[15][2]			// Posicao do Preco de Tabela
Local nVrUnit	:= 0 						// Valor unitario
Local nDesc		:= 0						// Valor de desconto
Local cEstado   := SuperGetMV("MV_ESTADO")	// Estado da empresa que esta vendendo
Local lTMKTabRef:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o item do pedido de venda  ³
//³foi eliminado por resíduo. (MV_RSDOFAT)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Tk273VldRes()
	Return .F.
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no produto digitado ou escolhido para ter certeza que esta no registro correto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SB1")
DbSetOrder(1)      
If !DbSeek( xFilial("SB1") + nValor)
	Help(" ",1,"A010VAZ")
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o bloqueio de registro do Produto escolhido              ³
//³ tratamento do  campo de bloqueio B1_MSBLQL                      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExistCpo("SB1", nValor)
	Return(lRet)
Endif        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A Bolívia não trabalha com o campo B1_IPI.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BOL"
	MaFisAlt("IT_ALIQIPI",SB1->B1_IPI,nLinha)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta a mensagem de ajuda sobre a quantidade de lote³
//³mínimo.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Empty(aCols[nLinha][nPQtd])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se tiver quantidade mínima de venda, use ela.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SB1->B1_LOTVEN > 0
		aCols[nLinha][nPQtd] := SB1->B1_LOTVEN
	Else
		aCols[nLinha][nPQtd] := 1
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida a quantidade informada de acordo com a quantidade³
	//³mínima de venda permitido.                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !FtVldQtVen( nValor, aCols[nLinha][nPQtd], .F.)
		aCols[nLinha][nPQtd] := SB1->B1_LOTVEN
	EndIf
Endif

MaFisAlt("IT_QUANT",aCols[nLinha][nPQtd],nLinha)
MaFisAlt("IT_PRODUTO",nValor,nLinha)

aCols[nLinha][nPProd]   := SB1->B1_COD
aCols[nLinha][nPDescri] := SB1->B1_DESC
aCols[nLinha][nPUm]     := SB1->B1_UM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sempre gatilha a TES quando for digitado o codigo do produto e somente nao gatilha quando a linha for de bonificacao³      
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPTes] <> &(SuperGetMv("MV_BONUSTS"))
	If Empty( RetFldProd(SB1->B1_COD,"B1_TS") ) 
		aCols[nLinha][nPTes] := Tmk273TPad()
	Else
		aCols[nLinha][nPTes] := RetFldProd(SB1->B1_COD,"B1_TS")
	Endif	
Endif	

aCols[nLinha][nPLocal]  := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
aCols[nLinha][nPSitProd]:= SB1->B1_SITPROD
aCols[nLinha][nPVrUnit] := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico o ESTADO do cliente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF4")
DbSetOrder(1)
If DbSeek(xFilial("SF4") + aCols[nLinha][nPTes] )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o bloqueio de registro da TES utilizada                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ExistCpo("SF4", aCols[nLinha][nPTes])
		aCols[nLinha][nPTes]:=CriaVar("UB_TES",.F.)
	Endif
	lRet := .T.	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a tabela nao for vazia pega o preco de tabela,              ³
//³caso contrario pega o valor informado no Cadastro do Produto   ³
//³Isso ocorre para manter a compatiblizacao com o SIGAFAT        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->UA_TABELA)
	lTMKTabRef := Iif(ExistBlock("TMKTABREF"),ExecBlock("TMKTABREF"),.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for uma tabela de preco valida calcula o valor unitario do item³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVrUnit := MaTabPrVen(	M->UA_TABELA	,aCols[nLinha][nPProd]	,aCols[nLinha][nPQtd]	,M->UA_CLIENTE	,;
							M->UA_LOJA		,M->UA_MOEDA			,NIL					,NIL			,;
							NIL				,.T.					,lProspect				,NIL			,;
							lTMKTabRef		)
Else
	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek( xFilial("SB1")+aCols[nLinha][nPProd] )
		nVrUnit := xMoeda(SB1->B1_PRV1,1,M->UA_MOEDA,dDataBase)
	Endif
Endif

If aCols[nLinha][nPTes] $ (SuperGetMv("MV_BONUSTS")) .And. nVrUnit == 0
	nVrUnit := 1
EndIf

aCols[nLinha][nPVrUnit] := nVrUnit
aCols[nLinha][nPPrcTab] := nVrUnit
aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Só aplica regra de desconto se houver o preço de tabela.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPPrcTab] > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aplica a regra da TABELA DE DESCONTOS no item          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nDesc := TkRegraDesc(	1			, aValores[TOTAL]	, 0		, NIL	,;
							M->UA_CONDPG, nLinha			)
	nDesc	:= If(nDesc < 0,0,nDesc)
	TkP000D(nDesc,nLinha)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver DESCONTO EM CASCATA ja aplica o valor no item³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	(M->UA_DESC4 > 0) .OR. ;
	(M->UA_DESC1 > 0) .OR. ;
	(M->UA_DESC2 > 0) .OR. ;
	(M->UA_DESC3 > 0)
	Tk273DesCab(nLinha,lTudo)
Endif

Eval(bGDRefresh)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TKP000B  ³ Autor ³ Vendas Clientes       ³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o valor do item de acordo com quantidade- UB_QUANT³±±
±±³          ³ o valor do item vai considerar somente os DESCONTOS de:    ³±±
±±³          ³ - CABECALHO                                                ³±±
±±³          ³ - ITEM                                                     ³±±
±±³          ³ O ACRESCIMO sera sempre atualizado com 0                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Quantidade                                         ³±±
±±³          ³ ExpN2 = Linha do aCols para analise                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                     
Function TkP000B(nValor,nLinha)

Local aAreaSC6	:= SC6->(GetArea())			// Salva area da tabela SC6
Local aAreaSUA	:= SUA->(GetArea())			// Salva area da tabela SUA
Local lRet		:= .F.						// Retorno da funcao
Local nPProd	:= aPosicoes[1][2]			// Produto	
Local nPQtd     := aPosicoes[4][2]			// Quantidade          
Local nPVrUnit  := aPosicoes[5][2]			// Valor unitario
Local nPVlrItem := aPosicoes[6][2]			// Valor do item
Local nPAcre 	:= aPosicoes[13][2]			// % Acrescimo
Local nPValAcre := aPosicoes[14][2]			// $ Acrescimo em Valor
Local nPPrcTab  := aPosicoes[15][2]			// Preco de Tabela
Local nPItem	:= aPosicoes[20][2]			// Item
Local nDesc		:= 0 						// Variavel auxiliar	
Local cAltPed	:= SuperGetMV("MV_ALTPED")  // Parametro que permite a edição de pedido já faturado
Local cAtenAtu	:= ""						// Variável que irá pegar o pedido do atendimento atual
Local lTMKTabRef:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o item do pedido de venda  ³
//³foi eliminado por resíduo. (MV_RSDOFAT)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Tk273VldRes()
	Return .F.
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a quantidade nao foi alterada, nao sera necessario o³
//³recalculo dos valores                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPQtd] == nValor
	RestArea(aAreaSC6)
	Return (.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida a quantidade informada deacordo com a quantidade³
//³mínima de permitido de venda.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !FtVldQtVen( aCols[nLinha][nPProd], nValor, .T.)
	RestArea(aAreaSC6)
	Return (.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o parametro MV_ALTPED, caso seja nao, nao e permitido alterar³
//³nada no pedido, se sim a quantidade digitada devera ser maior que a   ³
//³quantidade entregue.                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SUA")
DbSetOrder(1)
If DbSeek(xFilial("SUA") + M->UA_NUM)
	cAtenAtu := SUA->UA_NUMSC5
EndIf

DbSelectArea("SC6")
DbSetOrder(1)
If DbSeek(xFilial("SC6") + SUA->UA_NUMSC5 + aCols[nLinha][nPItem] + aCols[nLinha][nPProd])
	If cAltPed == "N" .AND. SC6->C6_QTDENT > 0
		Help("",1,"A410PEDFAT")
		RestArea(aAreaSC6)
		RestArea(aAreaSUA)
		Return(.F.)
	ElseIf nValor < SC6->C6_QTDENT	// Verifica se a quantidade digitada é menor que a quantidade entregue
		Help("",1,"A410PEDJFT")
		RestArea(aAreaSC6)
		RestArea(aAreaSUA)
		Return(.F.)
	EndIf
	
	//Validações referentes à integração do OMS com o Cockpit Logístico Neolog
	If (SuperGetMV("MV_CPLINT",.F.,"2") == "1") .And. FindFunction("OMSCPLVlQt")
		IF !OMSCPLVlQt("C6_QTDVEN",nValor,.T.)
			Return(.F.)
		EndIf
	EndIf	
EndIf

If !Empty(M->UA_TABELA)
	lTMKTabRef := Iif(ExistBlock("TMKTABREF"),ExecBlock("TMKTABREF"),.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for uma tabela de preço valida calcula o valor unitario do item    ³
	//³Utilizada a funcao de materiais para  calculo da faixa.               ³                                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[nLinha][nPVrUnit] := MaTabPrVen(	M->UA_TABELA	,aCols[nLinha][nPProd]	,nValor		,M->UA_CLIENTE	,;
											M->UA_LOJA		,M->UA_MOEDA			,NIL		,NIL			,;
											NIL				,.T.					,lProspect	,NIL			,;
											lTMKTabRef		)
	aCols[nLinha][nPPrcTab] := aCols[nLinha][nPVrUnit]
Endif

aCols[nLinha][nPQtd]    := nValor
aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd] * aCols[nLinha][nPVrUnit],"UB_VLRITEM")

MaFisAlt("IT_QUANT",aCols[nLinha][nPQtd],nLinha)
MaFisAlt("IT_PRCUNI",aCols[nLinha][nPVrUnit],nLinha)
MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera os ACRESCIMOS 			  ³	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPAcre] 	 := 0 
aCols[nLinha][nPValAcre] := 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aplica a regra da TABELA DE DESCONTOS                  ³
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDesc := TkRegraDesc(	1 			, aValores[TOTAL]	, 0	, NIL	,;
						M->UA_CONDPG, nLinha			)
nDesc := IIf(nDesc < 0,0,nDesc)
lRet  := TkP000D(nDesc,nLinha)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver DESCONTO EM CASCATA ja aplica o valor no item³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	(M->UA_DESC4 > 0)	.OR.;
	(M->UA_DESC1 > 0)	.OR.;
	(M->UA_DESC2 > 0)	.OR.;
	(M->UA_DESC3 > 0)	.OR.;
	(ReadVar() == "M->UB_QUANT")
	
	Tk273DesCab(nLinha,.F.)
	
Endif

RestArea(aAreaSC6)
RestArea(aAreaSUA)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TKP000C  ³ Autor ³ Vendas Clientes       ³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o valor do item quando o unitario for atualizado   ³±±
±±³			 ³ UB_VRUNIT                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor unitario                                     ³±±
±±³          ³ ExpN2 = Linha do aCols para analise                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TELEVENDAS                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkP000C(nValor,nLinha)

Local lRet 		:= .T.									// Retorno da funcao
Local lRecalc	:= .T.									// Indica se os valores devem ser recalculados
Local nPQtd		:= aPosicoes[4][2]						// Quantidade
Local nPVrUnit	:= aPosicoes[5][2]						// Valor unitario
Local nPVlrItem := aPosicoes[6][2]						// Valor do item 
Local nPDesc 	:= aPosicoes[9][2]						// % Desconto
Local nPAcre 	:= aPosicoes[13][2]						// % Acrescimo
Local nPValDesc := aPosicoes[10][2]						// $ Desconto em valor
Local nPValAcre := aPosicoes[14][2]						// $ Acrescimo em valor	
Local nPPrctab  := aPosicoes[15][2]						// Posicao do Preco de Tabela
Local nPProd  := aPosicoes[1][2]						// Posicao do Produto
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF") 	// Preco fiscal bruto 1=SIM / 2=NAO
Local lTk27300C := ExistBlock("TK27300C")				// P.E. utilizado na alteracao do preco unitario
Local nDesc		:= 0									// Desconto vindo da regra de desconto
Local lTMKTabRef:=.F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o item do pedido de venda  ³
//³foi eliminado por resíduo. (MV_RSDOFAT)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Tk273VldRes()
	Return .F.
EndIf          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a existencia do ponto de entrada de validacao do preco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTk27300C
	lRet := ExecBlock( "TK27300C", .F., .F. )
	If ValType(lRet) <> "L"
		lRet := .F.
	Endif	
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente ira recalcular o item e zerar os acrescimos/descontos³
//³quando o valor do item realmente for alterado.               ³
//³Se o usuario apenas pressionar <Enter> sobre o campo sem     ³
//³modificar seu valor, nenhum tratamento se faz necessario     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRecalc := (aCols[nLinha][nPVrUnit] <> nValor)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso seja verdadeira executa os processos de validacao. A        ³
//³variavel lRet e sempre inicializada com .T. para caso nao exista ³
//³o ponto de entrada, o processo seja realizado normalmente        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. lRecalc
	aCols[nLinha][nPVrUnit] := nValor
	
	aCols[nLinha][nPDesc]   := 0
	aCols[nLinha][nPAcre]   := 0
	aCols[nLinha][nPValDesc]:= 0
	aCols[nLinha][nPValAcre]:= 0
	aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se não tiver preço de tabela, o valor inicialmente digitado³
	//³substituirá o preço de tabela que está zerado.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCols[nLinha][nPPrctab] == 0
		aCols[nLinha][nPPrctab] := aCols[nLinha][nPVrUnit]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aplica a regra da TABELA DE DESCONTOS no item já       ³
		//³que quando o mesmo foi incluido a regra não foi        ³
		//³aplicada por não ter preço de tabela.                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nDesc := TkRegraDesc(	1			, aValores[TOTAL]	, 0		, NIL	,;
								M->UA_CONDPG, nLinha			)
		nDesc := IIf(nDesc < 0,0,nDesc)
		TkP000D(nDesc,nLinha)
	ElseIf INCLUI
		If SB1->B1_COD <> aCols[nLinha][nPProd] // Verifica se eh o mesmo produto
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+aCols[nLinha][nPProd])) // Existe pois passou pela validacao do campo
		EndIf
		nPrcProd := SB1->B1_PRV1
		If Empty(M->UA_TABELA) .And. nPrcProd == 0
			aCols[nLinha][nPPrctab] := aCols[nLinha][nPVrUnit]
		Else
			If !Empty(M->UA_TABELA)
				lTMKTabRef := Iif(ExistBlock("TMKTABREF"),ExecBlock("TMKTABREF"),.F.)
				nPrcProd := 	MaTabPrVen(	M->UA_TABELA,;
													aCols[nLinha][nPProd],;
													aCols[nLinha][nPQtd],;
													M->UA_CLIENTE,;
													M->UA_LOJA,;
													M->UA_MOEDA,;
													NIL,;
													NIL,;
													NIL,;
													.T.,;
													lProspect,;
													Nil,;
													lTMKTabRef)

			EndIf
			aCols[nLinha][nPPrctab] := IIf((nPrcProd == 0) .And. (aCols[nLinha][nPPrctab] > 0),aCols[nLinha][nPVrUnit],nPrcProd)
		EndIf
	EndIf
	
	MaFisAlt("IT_PRCUNI",aCols[nLinha][nPVrUnit],nLinha)
	MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)
	If cPrcFiscal == "1"  // Se for Preco fiscal bruto = 1 - Sim
		aValores[DESCONTO] := 0
		If !aCols[nLinha][Len(aHeader)+1]		// Se a linha for valida
			aValores[DESCONTO] += aCols[nLinha][nPValDesc]
		Endif	
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o valor de memória, para evitar que o refresh da³
//³GetDados volte o aCols ao valor digitado inicialmente.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M->UB_VRUNIT := aCols[nLinha][nPVrUnit]

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TkP000D  ³ Autor ³ Vendas Clientes     	³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do desconto (%) do item campo - UB_DESC          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor do desconto(%)                               ³±±
±±³          ³ ExpN2 = Linha do aCols para analise                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TELEVENDAS                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkP000D(nValor,nLinha)

Local lRet		:=.F.										// Retorno da funcao
Local nPQtd		:= aPosicoes[4][2]							// Posicao da Quantidade
Local nPVrUnit	:= aPosicoes[5][2]							// Posicao do Valor unitario
Local nPVlrItem := aPosicoes[6][2]							// Posicao do Valor do item
Local nPDesc 	:= aPosicoes[9][2]							// Posicao do % Desconto
Local nPValDesc := aPosicoes[10][2]							// Posicao do $ Desconto em Valor
Local nPTes	    := aPosicoes[11][2]							// Posicao do Codigo do TES
Local nPAcre 	:= aPosicoes[13][2]							// Posicao do Acrescimo em %
Local nPValAcre := aPosicoes[14][2]							// Posicao do % Acrescimo	
Local nPPrctab  := aPosicoes[15][2]							// Posicao do Preco de Tabela
Local cDesconto := TkPosto(M->UA_OPERADO,"U0_DESCONT")		// Desconto  1=ITEM / 2=TOTAL / 3=AMBOS / 4=NAO
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF")		// Preco fiscal bruto 1=SIM / 2=NAO
Local cTesBonus := SuperGetMv("MV_BONUSTS") 				// Codigo da TES usado para as regras de bonificacao
Local cTes    	:= aCols[nLinha][nPTes]						// Conteudo do TES
Local lTemPrcTab:= If(aCols[nLinha][nPPrcTab]>0,.T.,.F.)	// Se tem preço de tabela

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o item do pedido de venda  ³
//³foi eliminado por resíduo. (MV_RSDOFAT)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Tk273VldRes()
	Return .F.
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se não tiver preço de tabela, ignora a tentativa de cálculo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTemPrcTab
	Return(.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( cTes == cTesBonus )
	Return(lRet)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³So pode dar desconto se o Posto de venda estiver configurado para Item ou Ambos						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(cDesconto) == "2" .OR. AllTrim(cDesconto) == "4"   // Desconto = Total ou Desconto = Nao
	If nValor > 0 
		If  !lTk271Auto 
			Help( " ", 1, "NAO_DESCON")
		Endif	
		aCols[nLinha][nPDesc] := 0
		Return(lRet)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O valor de deconto (%) nao pode ser maior ou igual a 100%  			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nValor >= 100
	Help( " ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPDesc] := 0
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrego novamente o valor de desconto calculado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPDesc]	:= nValor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera os valores de acréscimo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPValAcre]	:= 0
aCols[nLinha][nPAcre]		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula os descontos, tanto do cabeçalho como do item.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk273DesCLi(nLinha,1)	// Percentual

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o posto de venda do operador estiver com preco fiscal bruto = SIM  ³
//³o valor unitario do produto sera jogado no desconto total 		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(cPrcFiscal) != "2"  // SIM
	aCols[nLinha][nPVlrItem]	:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
	aCols[nLinha][nPValDesc]	:= aCols[nLinha][nPVlrItem] - A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VALDESC")
	aCols[nLinha][nPValAcre]	:= 0
	aCols[nLinha][nPAcre]		:= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Jogo o desconto desse item no TOTAL pois o valor do unitario nao sera recalculado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPrcFiscal == "1"  // Se for PRECO FISCAL BRUTO igual a SIM
		aValores[DESCONTO]:= 0
		If !aCols[nLinha][Len(aHeader)+1]		// Se a linha for valida
			aValores[DESCONTO] += aCols[nLinha][nPValDesc]
		Endif	
		Eval(bRefresh)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O desconto nao pode ser maior que o valor de Tabela		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPValDesc] >= ( aCols[nLinha][nPPrcTab] * aCols[nLinha][nPQtd] ) .AND. nValor > 0
	Help(" ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPDesc]   := 0
	aCols[nLinha][nPValDesc]:= 0
	Return(lRet)
Endif


lRet:=.T.

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TkP000E  ³ Autor ³ Vendas Clientes       ³ Data ³ 20/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do desconto (R$) do item campo - UB_VALDESC      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor do desconto (R$)                             ³±±
±±³          ³ ExpN2 = Linha do aCols para analise                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TELEVENDAS                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkP000E(nValor,nLinha)

Local lRet		:=.F.										// Retorno da funcao
Local nPQtd		:= aPosicoes[4][2]							// Posicao da Quantidade
Local nPVrUnit	:= aPosicoes[5][2]							// Posicao do Valor unitario
Local nPVlrItem := aPosicoes[6][2]							// Posicao do Valor do item
Local nPDesc 	:= aPosicoes[9][2]							// Posicao do Desconto em %
Local nPValDesc := aPosicoes[10][2]							// Posicao do Valor desconto $
Local nPTes     := aPosicoes[11][2]							// Posicao do TES
Local nPAcre 	:= aPosicoes[13][2]							// Posicao do Acrescimo em %
Local nPValAcre := aPosicoes[14][2]							// Posicao do Valor do Acrescimo $
Local nPPrcTab  := aPosicoes[15][2]							// Posicao do Preco de Tabela
Local cDesconto := TkPosto(M->UA_OPERADO,"U0_DESCONT")		// Desconto  1=ITEM / 2=TOTAL / 3=AMBOS / 4=NAO
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF")		// Preco fiscal bruto 1=SIM / 2=NAO
Local cTesBonus := SuperGetMv("MV_BONUSTS") 				// Codigo da TES usado para as regras de bonificacao
Local cTes    	:= aCols[nLinha][nPTes]						// Conteudo do TES
Local lTemPrcTab:= If(aCols[nLinha][nPPrcTab]>0,.T.,.F.)	// Se tem preço de tabela

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o item do pedido de venda  ³
//³foi eliminado por resíduo. (MV_RSDOFAT)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Tk273VldRes()
	Return .F.
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se não tiver preço de tabela, ignora a tentativa de cálculo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTemPrcTab
	Return(.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³So pode dar desconto se o Posto de venda estiver      	³
//³configurado para Item ou Ambos					    	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(cDesconto) == "2" .OR. AllTrim(cDesconto) == "4"   // Item ou Total
	If nValor > 0 
		If  !lTk271Auto 
			Help( " ", 1, "NAO_DESCON")
		Endif	
		aCols[nLinha][nPValDesc] := 0
		Return(lRet)
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O Valor do desconto nao pode ser maior que o vlr. do item³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nValor >= aCols[nLinha][nPQtd] * aCols[nLinha][nPPrcTab]
	Help( " ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPValDesc] := 0
	aCols[nLinha][nPDesc]    := 0
	aCols[nLinha][nPValDesc] := 0
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrego novamente o valor de desconto calculado		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPValDesc] := nValor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera os valores de acréscimo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPValAcre]	:= 0
aCols[nLinha][nPAcre]		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula os descontos, tanto do cabeçalho como do item.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tk273DesCLi(nLinha,2)	// R$

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o posto de venda do operador  trabalha com     ³
//³preco fiscal bruto jogo o desconto no total       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(cPrcFiscal) != "2"  //Preco Fiscal Bruto = 2-Nao
	aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
	aCols[nLinha][nPValDesc]:= aCols[nLinha][nPVlrItem] - A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VALDESC")
	aCols[nLinha][nPValAcre]:= 0
	aCols[nLinha][nPAcre]	:= 0	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Jogo o desconto desse item no TOTAL pois o valor do unitario nao sera recalculado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPrcFiscal == "1"  // Se for PRECO FISCAL BRUTO igual a SIM
		aValores[DESCONTO]:= 0
		If !aCols[nLinha][Len(aHeader)+1]		// Se a linha for valida
			aValores[DESCONTO] += aCols[nLinha][nPValDesc]
		Endif	
	Endif
	Eval(bRefresh)
Endif

lRet := .T.

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TKP000G  ³ Autor ³ Vendas Clientes       ³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o Valor do item de acordo com o acrescimo - UB_ACRE³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor do acrescimo                                 ³±±
±±³          ³ ExpN2 = Linha do aCols para analise                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkP000G(nValor,nLinha)

Local cCampo 	:= ReadVar()								// Valor digitado pelo usuario
Local lRet 	 	:= .F.										// Retorno da funcao
Local nPQtd		:= aPosicoes[4][2]							// Posicao da Quantidade	
Local nPVrUnit	:= aPosicoes[5][2]							// Posicao do Valor unitario
Local nPVlrItem := aPosicoes[6][2]							// Posicao do Valor do item
Local nPValDesc := aPosicoes[10][2]							// Posicao do Valor desconto $
Local nPTes	    := aPosicoes[11][2]							// Posicao do TES
Local nPAcre 	:= aPosicoes[13][2]							// Posicao do Acrescimo em %
Local nPValAcre := aPosicoes[14][2]							// Posicao do Acrescimo em $		
Local nPPrcTab  := aPosicoes[15][2]							// Posicao do Preco de Tabela
Local nValUni   := 0										// Variavel auxiliar para calculo do unitario	
Local nVlrTab   := 0										// Variavel auxiliar 
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF")		// Preco fiscal bruto 1=SIM / 2=NAO
Local cAcrescimo:= TkPosto(M->UA_OPERADO,"U0_ACRESCI")		// Acrescimo 1=ITEM / 2=NAO
Local cTesBonus := SuperGetMv("MV_BONUSTS") 				// Codigo da TES usado para as regras de bonificacao
Local cTes    	:= aCols[nLinha][nPTes]						// Conteudo do TES	
Local lTemPrcTab:= If(aCols[nLinha][nPPrcTab]>0,.T.,.F.)	// Se tem preço de tabela

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o item do pedido de venda  ³
//³foi eliminado por resíduo. (MV_RSDOFAT)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Tk273VldRes()
	Return .F.
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se não tiver preço de tabela, ignora a tentativa de cálculo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTemPrcTab
	Return(.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o posto de venda nao recalcula o unitario nao pode dar acrescimo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCampo == "M->UB_ACRE"
	If AllTrim(cAcrescimo) == "2"  // Acrescimo = 2 - Nao
		If nValor > 0 
			Help( " ", 1, "NAO_ACRESC")
			aCols[nLinha][nPAcre]:= 0
			Return(lRet)
		Endif	
	ElseIf AllTrim(cPrcFiscal) == "1"  // Preco Fiscal Bruto NAO (NAO ALTERA O UNITARIO NAO PODE DAR ACRESCIMO)
		If nValor > 0 
			Help( " ", 1, "NAO_ACRESC")
			aCols[nLinha][nPAcre]:= 0
			Return(lRet)
		Endif	
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz os calculos de desconto baseando-se no Preco de Tabela  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aplica descontos existentes, tanto do cabeçalho quando do³
	//³item.                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrTab := nVlrTab - If(M->UA_DESC1 > 0, ( nVlrTab * M->UA_DESC1 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC2 > 0, ( nVlrTab * M->UA_DESC2 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC3 > 0, ( nVlrTab * M->UA_DESC3 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC4 > 0, ( nVlrTab * M->UA_DESC4 ) / 100, 0)	
	nVlrTab := nVlrTab - ( aCols[nLinha][nPValDesc] / aCols[nLinha][nPQtd] )
Else
	nVlrTab := aCols[nLinha][nPVrUnit] - aCols[nLinha][nPValAcre]
Endif

aCols[nLinha][nPAcre]:= nValor

nValUni	:= A410Arred(nVlrTab * (100 + nValor) / 100,"UB_VRUNIT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O Acrescimo sempre recalcula  o valor do unitario porque se o for jogado no total (ACRESCIMO RODAPE)      ³
//³no momento de gerar o SC6 ser  gerado uma DIZIMA PERIODICA consequentemente n„o vai bater o valor liquido ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPVrUnit] := nValUni
aCols[nLinha][nPValAcre]:= A410Arred(((nVlrTab * aCols[nLinha][nPAcre]) / 100) * aCols[nLinha][nPQtd],"UB_VALACRE")
aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")

lRet := .T.

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TKP000H  ³ Autor ³ Vendas Clientes       ³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o Acrescimo do Item em valores -  UB_VALACRE       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor do acrescimo                                 ³±±
±±³          ³ ExpN2 = Linha do aCols para analise                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkP000H(nValor,nLinha)

Local lRet 		:= .F.										// Retorno da funcao
Local nPQtd		:= aPosicoes[4][2]							// Posicao da Quantidade
Local nPVrUnit  := aPosicoes[5][2]							// Posicao do Valor unitario	
Local nPVlrItem := aPosicoes[6][2]							// Posicao do Valor do Item
Local nPValDesc := aPosicoes[10][2]							// Posicao do Valor de Desconto
Local nPTes	    := aPosicoes[11][2]							// Posicao do TES
Local nPAcre 	:= aPosicoes[13][2]							// Posicao do Acrescimo
Local nPValAcre := aPosicoes[14][2]							// Posicao do Valor de Acrescimo
Local nPPrctab  := aPosicoes[15][2]							// Posicao do Preco de Tabela
Local nValUni   := 0										// Variavel auxiliar
Local nVlrTab   := 0										// Valor de Tabela
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF") 		// Preco fiscal bruto 1=SIM / 2=NAO
Local cAcrescimo:= TkPosto(M->UA_OPERADO,"U0_ACRESCI") 		// Acrescimo 1=ITEM / 2=NAO
Local cTesBonus := SuperGetMv("MV_BONUSTS")					// Codigo da TES usado para as regras de bonificacao
Local cTes    	:= aCols[nLinha][nPTes]						// Conteudo do TES
Local lTemPrcTab:= If(aCols[nLinha][nPPrcTab]>0,.T.,.F.)	// Se tem preço de tabela

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o item do pedido de venda  ³
//³foi eliminado por resíduo. (MV_RSDOFAT)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Tk273VldRes()
	Return .F.
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se não tiver preço de tabela, ignora a tentativa de cálculo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTemPrcTab
	Return(.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o posto de venda nao recalcula o unitario nao pode dar acrescimo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(cAcrescimo) == "2"  // Acrescimo = 1 - Nao
	If nValor > 0 
		Help( " ", 1, "NAO_ACRESC")
		Return(lRet)
	Endif	
ElseIf AllTrim(cPrcFiscal) == "1"  // Preco Fiscal Bruto = 1- NAO
	If nValor > 0 
		Help( " ", 1, "NAO_ACRESC")
		Return(lRet)
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz os calculos de desconto baseando-se no preco de tabela  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aplica descontos existentes, tanto do cabeçalho quando do³
	//³item.                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrTab := nVlrTab - If(M->UA_DESC1 > 0, ( nVlrTab * M->UA_DESC1 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC2 > 0, ( nVlrTab * M->UA_DESC2 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC3 > 0, ( nVlrTab * M->UA_DESC3 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC4 > 0, ( nVlrTab * M->UA_DESC4 ) / 100, 0)
	nVlrTab := nVlrTab - ( aCols[nLinha][nPValDesc] / aCols[nLinha][nPQtd] )
Else
	nVlrTab := aCols[nLinha][nPVrUnit] - aCols[nLinha][nPValAcre]
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula o % em funcao do acrescimo informado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPValAcre] := nValor

nValor 					 := (nValor / aCols[nLinha][nPQtd])
nValor 					 := (nValor / nVlrTab) * 100

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O valor de acrescimo n„o pode passar de 100 % se o campo UB_ACRE estiver com tamanho 5 decimal 2 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TamSX3("UB_ACRE")[1] <= 5
	If nValor >= 100
		MsgStop(STR0013) //"O Valor de Acréscimo não pode ser maior que 100%"
		nValor := 0                  
		aCols[nLinha][nPValAcre] := 0
		Return(lRet)
	Endif
Endif

aCols[nLinha][nPAcre]:= nValor

nValUni := A410Arred(nVlrTab * (100 + nValor) / 100,"UB_VRUNIT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O Acrescimo sempre recalcula  o valor do unitario porque se o for jogado no total (ACRESCIMO RODAPE)      ³
//³no momento de gerar o SC6 ser  gerado uma DIZIMA PERIODICA consequentemente n„o vai bater o valor liquido ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPVrUnit] := nValUni
aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")

Tk273Trigger("UB_VLRITEM",nLinha)

lRet := .T.

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tmk271TPad  ³ Autor ³ Vendas Clientes     ³ Data ³ 19/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializacao do Tes Padrao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void TKTesPad(Void)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tmk273TPad()

Local aArea  := GetArea()   					// Salva a area atual
Local cTes   := CriaVar("F4_CODIGO",.F.)		// Conteudo do TES

cTes := SuperGetMv("MV_TESSAI")
DbSelectArea("SF4")
DbSetOrder(1)
If !DbSeek(xFilial("SF4")+cTes)
	cTes := CriaVar("F4_CODIGO",.F.)
Endif

RestArea(aArea)
Return(cTes)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TkRegraDesc³ Autor ³ Vendas Clientes       ³ Data ³25/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao  para atualizacao do desconto no pedido de venda     ³±±
±±³          ³Baseado na rotina MAREGRADESC                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Tipo de Desconto                                     ³±±
±±³          ³       1 - Desconto de Item do TELEVENDAS                   ³±±
±±³          ³       2 - Desconto de CABECALHO do TELEVENDAS              ³±±
±±³          ³ExpN2: Total dos Valores da Mercadoria sem Desconto         ³±±
±±³          ³ExpN3: Variavel de desconto de cabecalho a ser atualizada   ³±±
±±³          ³ExpA4: Array contendo as regras que NAO devem ser considera-³±±
±±³          ³       das.                                                 ³±±
±±³          ³ExpC5	:Codigo da condicao de pagamento                      ³±±
±±³          ³ExpN6	:Numero da linha do acols para analise                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Percentual de Desconto da Regra                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina tem como objetivo atualizar os campos:          ³±±
±±³          ³UB_DESCONT e UA_DESC4 de acordo com as regras de desconto   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Televendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkRegraDesc(	nTipo		, nTotDoc	, nDescCab	, aRegrasExc	,;
						cCodPagto	, nLinha	)

Local aArea     := GetArea()						// Salva a Area 
Local nDesconto := -1								// Variavel auxiliar de desconto
Local nPProd    := aPosicoes[1][2]					// Posicao do Produto
Local nPQtd     := aPosicoes[4][2]					// Posicao da Quantidade
Local nPDesc	:= aPosicoes[9][2]					// Posicao do Desconto %
Local lDescEsca	:= GetNewPar("MV_DESCLOT",.F.)		// Parametro de LOTE
Local nX		:= 0 								// Contador

Local nPos 		:= 0								// Auxiliar
Local aProds	:= {}								// Array com os produtos
Local nCnt 		:= 0								// Contador
Local cForma	:= ""								// Forma de pagamento
Local nVlrAntN 
Local nPPrcTab 	:= aPosicoes[15][2]					// Posicao do Preco de tabela
Local nUnitario :=0									// Preco Unitario

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ€¿
//³- nVlrAntN deve ser inicializada com NIL                                                                            ³
//³- Utilizando para guardar valor anterior de n <- Indica rigistro posicionado no aCols                               ³
//³- Foi incluido para não ocorrer problemas ao utilizar rotina automatica na inclusao de um atendimento pelo televenda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ€Ù

DEFAULT nTipo   := 1								// Defaults de compatibilizacao	
DEFAULT nTotDoc := 0								// Total do documento
DEFAULT nDescCab:= 0								// Descricao cabecalho
DEFAULT aRegrasExc:={}								// Vetor de regras
DEFAULT cCodPagto := CriaVar( 'ACO_CONDPG', .F. )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando o desconto for por item, precisa do valor unitario ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nTipo == 1)
	nUnitario 	:= aCols[nLinha,nPPrcTab]
EndIf

If nTipo == 1 //Item do TELEVENDAS
	cAliasQry := GetNextAlias()

	cQuery := "SELECT ACO.ACO_FILIAL, ACO_CODREG, ACO_CODCLI, ACO_LOJA, ACO_CONDPG, ACO_FORMPG "
	cQuery += " FROM "+ RetSqlName("ACO") +" ACO , " + RetSqlName("ACP") +" ACP "
	cQuery += "WHERE ACO.ACO_FILIAL='"+xFilial("ACO")+"' AND "
	cQuery += "(ACO.ACO_CODCLI = '"+ CriaVar( 'A1_COD',  .F. ) +"' OR ACO.ACO_CODCLI='"+M->UA_CLIENTE+"') AND "
	cQuery += "(ACO.ACO_LOJA = '"+ CriaVar( 'A1_LOJA',  .F. ) +"' OR ACO.ACO_LOJA='"+M->UA_LOJA+"') AND "
	cQuery += "(ACO.ACO_CODTAB = '"+ CriaVar( 'DA0_CODTAB',  .F. ) +"' OR ACO.ACO_CODTAB = '"+M->UA_TABELA+"') AND "
	cQuery += "(ACO.ACO_CONDPG = '"+ CriaVar( 'DA0_CONDPG',  .F. ) +"' OR ACO.ACO_CONDPG='"+cCodPagto+"') AND "
	
	If ACO->( ColumnPos( 'ACO_MSBLQL' ) ) > 0
		cQuery += "ACO.ACO_MSBLQL = '2' AND "
	EndIf	
	
	cQuery += "ACO.D_E_L_E_T_=' ' AND "
	cQuery += "ACP.ACP_FILIAL='"+ FWxFilial("ACP")+"' AND "
	cQuery += "ACP.ACP_CODREG=ACO.ACO_CODREG AND "
	cQuery += "(ACP.ACP_CODPRO='"+ CriaVar( 'B1_COD', .F. ) +"' OR ACP.ACP_CODPRO='"+aCols[nLinha][nPProd]+"') AND "
	cQuery += "ACP.ACP_FAIXA>="+Alltrim(StrZero(aCols[nLinha,nPQtd],18,2))+" AND "
	cQuery += "ACP.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY ACO_CFAIXA"
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	If !EOF() .AND. !BOF()
		If !Empty(cCodPagto)
			SE4->(dbSetOrder(1))
			SE4->(DbSeek(xFilial("SE4")+cCodPagto))
			cForma := SE4->E4_FORMA
		EndIf
		nDesconto := MaRgrDesc(	aCols[nLinha][nPProd]	, M->UA_CLIENTE	, M->UA_LOJA	, M->UA_TABELA	,;
								aCols[nLinha,nPQtd]		, cCodPagto		, cForma		, 1				,;
								NIL						, aRegrasExc,/*cCodRegDe*/, nUnitario )
	Else
		If nPDesc <> 0
			nDesconto := aCols[nLinha][nPDesc]
		Endif
	Endif
	
	IIf( Select( cAliasQry ) > 0, ( cAliasQry )->( dbCloseArea() ), Nil  )
ElseIf nTipo == 2 //Cabecalho do TELEVENDAS
	If nLinha <> NIL
		nVlrAntN := IIf(Type("N") <> "U",n,NIL)
		n := nLinha
	EndIf
	If ACO->(DbSeek(xFilial("ACO")))
		aDescEsca	:= Array(Len(aCols)+1)
		aFill(aDescEsca,0)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcular o total de produtos suas quantidades para calcular o desconto escalable³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lDescEsca
			For nX := 1 to Len(aCols)
				If (Len(aCols[nX]) == Len(aHeader)+1) .AND. !aCols[nX][Len(aCols[nX])]

					nPos :=	Ascan(aProds,{|x| x[1] == aCols[nX][nPProd]})
					If nPos > 0
						aProds[nPos][3] += aCols[nX][nPQtd]
					Else
						AAdd(aProds,{aCols[nX][nPProd],;
									 Posicione("SB1",1,xFilial("SB1")+aCols[nX][nPProd],"B1_GRUPO"),;
									 aCols[nX][nPQtd],;
									 0,;
									 .T.})
					Endif
				Endif
			Next nX
		Endif
		SE4->(dbSetOrder(1))
		SE4->(DbSeek(xFilial("SE4")+cCodPagto))
		nDesconto := MaRgrDesc(	aCols[n][nPProd]	, M->UA_CLIENTE	, M->UA_LOJA	, M->UA_TABELA	,;
								nTotDoc				, cCodPagto		, SE4->E4_FORMA	, 2				,;
								aProds				, aRegrasExc, /*cCodRegDe*/, nUnitario 	)

		If nDescCab <> nDesconto
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se houve desconto escalavel, aplicar ele a cada um dos ³
			//³produtos que fazem parte da regra.                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lDescEsca 
				nDescCab  := nDesconto
				
			Else
				//Distribui no array dos descontos escalaveis os descontos
				For nX := 1 to Len(aProds)
					If aProds[nX][5]
						nCnt :=	Ascan(aCols,{|x| x[nPProd] == aProds[nX][1]})
						While nCnt > 0
							aDescEsca[nCnt]	:=	aProds[nX][4]
							nCnt :=	Ascan(aCols,{|x| x[nPProd] == aProds[nX][1]},nCnt+1)
						End
					Else
						nCnt :=	Ascan(aCols,{|x| x[nPProd] == aProds[nX][2]})
						While nCnt > 0
							aDescEsca[nCnt]	:=	aProds[nX][4]
							nCnt	:=	Ascan(aCols,{|x| Posicione('SB1',1,xFilial('SB1')+x[nPProd],"B1_GRUPO") == aProds[nX][2]},nCnt+1)
						End
					Endif
				Next nX
			Endif
			TK273Recalc()
			lRefresh :=	.T.
		Endif
	Endif
	If nVlrAntN <> NIL
		n := nVlrAntN
	EndIf
Endif

RestArea(aArea)
Return(nDesconto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271Recalc     ³Autor ³ Vendas Clientes  ³ Data ³ 20/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Recalcula os valores do pedido 		               	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Linha do aCols a Ser atualizada                      ³±±
±±³          ³ExpL2: .T. - Indica que so a linha selecionada deve ser atu-³±±
±±³          ³             -lizada.                                       ³±±
±±³          ³ExpL3: .F. - Indica se a chamada vem do valid do campo      ³±±
±±³          ³             UA_TABELA.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK273Recalc(nLen, lUpdOnlySelected, lAltPre)

Local nLinha	:= 0							// Contador de Linha		
Local nPosAnt	:= 1							// Posicao atual do N no aCols
Local lTudo		:= .F.							// Flag que indica que havera recalculo de todos os itens nas demais funcoes
Local nPProd	:= aPosicoes[1][2]				// Produto
Local nPQtd 	:= aPosicoes[4][2]				// Quantidade	
Local nPVrUnit  := aPosicoes[5][2]				// Valor unitario
Local nPVlrItem	:= aPosicoes[6][2]				// Valor do item
Local nPPrcTab  := aPosicoes[15][2]				// Preco de Tabela
Local nPVlrAcres:= aPosicoes[14][2]				// Acréscimo em valor
Local nVrUnit	:= 0							// Variavel auxiliar com valor unitario
Local nIniLoop  := 0							// Valor que deve iniciar o loop de atualizacao
Local nFimLoop  := 0							// Valor que deve para o loop de atualizacao
Local lMV_PVRECAL := SuperGetMV("MV_PVRECAL")	// Se não é para atualiza a tabela de preço quando alterada
Local lRecalc    := .F.
Local lCondPg   := (ReadVar()=="M->UA_CONDPG")
Local lCondTab  := .F. 							// Verifica se a condicao escolhida esta na tabela de precos
Local lTKVDACR	:= Iif(SuperGetMV("MV_TMKLOJ",,.F. )== "S" .And. GetNewPar("MV_TKVDACR",.F.),.T.,.F.)	//Se possuir integração com o SIGALOJA, faz o cálculo do acrescimo sobre o total menos o desconto.
Local lnLenDef	:= If( nLen == Nil, .T., .F. )
Local nAcresRat := 0
Local lTMKTabRef:= Iif(!Empty(M->UA_TABELA) .And. ExistBlock("TMKTABREF"),ExecBlock("TMKTABREF"),.F.)

//Default nLen 	:= Len(aCols)					// Valor default e o total de linhas dos itens do televendas
Default lUpdOnlySelected:= .F.					// Indica se deve atualizar apenas a linha informada no primeiro parametro. Por padrao, atualiza todos.
Default lAltPre			:= .F.					// Se a função está sendo executada do Valid do campo UA_TABELA (Ela foi criada para garantir que só haverá alteração nos valores dos itens baseados na tabela de preço, somento quando o usuário solicitar)

CursorWait()
If lnLenDef
	nLen 	:= Len(aCols)
EndIf

If N <> Nil
	nPosAnt	:= N
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera os valores de desconto, acrescimo, mercadoria e total.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("M->UA_CONDPG") <> "U" .And. (ReadVar() == "M->UA_CONDPG") .And. !lAltPre
	//Não zero o desconto se o operador alterar a condição de pagamento na tela do atendimento
	aValores[DESCONTO]  	:= 0
EndIf
aValores[MERCADORIA]	:= 0
aValores[SUFRAMA]		:= 0
aValores[TOTAL]			:= 0
aValores[BASEDUP]		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o valor do UA_DESC4  quando altera a tabela de preço.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAltPre
	TkRegraDesc(2,NIL,@M->UA_DESC4,NIL,M->UA_CONDPG,NIL)
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Novas variaveis de controle do loop de atualizacao.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nIniLoop := 1
If lUpdOnlySelected 
	nIniLoop := nLen
Endif        
nFimLoop := nLen

If lCondPg
	dbSelectArea("DA0")
	dbSetOrder(1) 
	If MsSeek(xFilial("DA0")+M->UA_TABELA)
		lCondTab := DA0_CONDPG == M->UA_CONDPG
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a rotina que ira calcular os valores de Valor Unitario, Valor Item, Desconto e Acrescimo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLinha := nIniLoop to nFimLoop  
   
	If (!aCols[nLinha][Len(aHeader)+1]) .AND. (!Empty(aCols[nLinha][nPProd]))

		lRecalc := .F.

 		If lCondPg .Or. ( lCondTab .And. aPesqDA1(M->UA_TABELA,aCols[nLinha][nPProd]) )
			lRecalc := .T.
		Else 	
			lRecalc := .F.
		Endif	

		If !lRecalc .And. lCondPg// .And.((!(TkRegraDesc(2,NIL,@M->UA_DESC4,NIL,M->UA_CONDPG,NIL)>0) .Or.(!(TkRegraDesc(1,NIL,NIL,NIL,NIL,nLinha) > 0)))) 				
		    If (TkRegraDesc(2,NIL,@M->UA_DESC4,NIL,M->UA_CONDPG,NIL)>0)
				lRecalc := .T.
			ElseIf !lRecalc .And. (TkRegraDesc(1,NIL,NIL,NIL,M->UA_CONDPG,nLinha) > 0)
				lRecalc := .T.	
			Else 	
				lRecalc := .F.
			Endif	
		Endif
		
		If lCondPg .And. !lRecalc
			Tk273RodImposto("NF_TOTAL",aValores[TOTAL])
			Loop
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recalcula os valores somente para os itens que nao foram deletados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa a rotina que ira calcular os valores de Valor Unitario, Valor Item, Desconto e Acrescimo.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a tabela nao for vazia pega o preco de tabela,              ³                                   
			//³caso contrario pega o valor informado no Cadastro do Produto   ³
			//³Isso ocorre para manter a compatiblizacao com o SIGAFAT        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aCols[nLinha][nPPrcTab] == 0 .Or. ( lAltPre .And. !lMV_PVRECAL)
				If !Empty(M->UA_TABELA)
			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for uma tabela de preco valida calcula o valor unitario do item³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nVrUnit := MaTabPrVen(	M->UA_TABELA	,aCols[nLinha][nPProd]	,aCols[nLinha][nPQtd]	,M->UA_CLIENTE	,;
											M->UA_LOJA		,M->UA_MOEDA			,NIL					,NIL			,;
											NIL				,.T.					,lProspect,				,Nil			,;
											lTMKTabRef		)
	 		  	Else
					DbSelectArea("SB1")
					DbSetOrder(1)
					If DbSeek( xFilial("SB1")+aCols[nLinha][nPProd] )
						nVrUnit := SB1->B1_PRV1
					Endif	
				Endif

				If aCols[nLinha][nPVrUnit] > 0 .And. nVrUnit > 0
					aCols[nLinha][nPVrUnit] := nVrUnit + aCols[nLinha][nPVlrAcres]
				Endif
			
			Else
				nVrUnit := aCols[nLinha][nPPrcTab]
			EndIf
	        
			If nVrUnit > 0
				aCols[nLinha][nPPrcTab] := nVrUnit
			Endif
			
			aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
	      	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se houve desconto em cascata ou se há uma regra de    ³
			//³desconto, atualiza o preço unitário e suas respectivas³
			//³informações.                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If 	(M->UA_DESC4 > 0) .OR. ;
				(M->UA_DESC1 > 0) .OR. ;
				(M->UA_DESC2 > 0) .OR. ;
				(M->UA_DESC3 > 0) .OR. ;
				(lAltPre .And. !lMV_PVRECAL .And. TkRegraDesc(1,NIL,NIL,NIL,NIL,nLinha) > 0)
				
				Tk273DesCab(nLinha,lTudo)
			Endif
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizacao das informacoes fiscais (MatXFis)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisAlt("IT_QUANT",aCols[nLinha][nPQtd],nLinha)
	MaFisAlt("IT_PRCUNI",aCols[nLinha][nPVrUnit],nLinha)

	//Valor do acrescimo referente ao item.
	nAcresRat := 0
	Tk273RecCpg(,,nLinha,@nAcresRat)

	MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem]+nAcresRat,nLinha)

	If lTKVDACR .And. M->UA_OPER == "2"
		Tk273RodImposto("NF_DESCONTO",aValores[DESCONTO])
		Tk273RodImposto("NF_DESPESA",aValores[DESPESA])
	Else
		Tk273RodImposto("NF_DESPESA",aValores[DESPESA])
		Tk273RodImposto("NF_DESCONTO",aValores[DESCONTO])
	EndIf
	
Next nLinha

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Volta a posicao anterior do N ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
n := nPosAnt      
		      
Eval(bListRefresh)

CursorArrow()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Trigger³ Autor ³ Vendas Clientes     ³ Data ³ 25/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o folder do rodape com REFRESH                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1:Campo que sera atualizado                            ³±±
±±³          ³ ExpN2:Linha do aCols                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk273Trigger(cCampo,nTrigger)

Local lRet		:= .F.							   		// Retorno da funcao										
Local aArea 	:= GetArea()							// Salva a area atual
Local nPosCpo	:= Ascan(aHeader,{|x| x[2]=cCampo})	// Posicao do campo na GetDados
Local nSavN		:= n							   		// Salva a posicao do ACOLS	
Local nPProd    := aPosicoes[1][2]				   		// Posicao do Produto
Local nPTes	    := aPosicoes[11][2]				   		// Posicao do TES	
Local cTesAnt	:= aCols[n][nPTes]				   		// Conteudo atual do TES
Local cProdAnt  := aCols[n][nPProd]				   		// Conteudo atual do Produto

If nTrigger <> NIL
	n := nTrigger
Endif

If nPosCpo > 0
	//Carrega a variavel de memoria para execucao do X3_VALID 
	M->&(AllTrim(aHeader[nPosCpo][2])) := aCols[n][nPosCpo]
	
	If &( aHeader[nPosCpo][6] )  //Se o conteudo do X3_VALID desse campo for verdadeiro
		lRet := .T.
		If MaFisFound("NF")
			Tk273TlvImp()
		Endif
	Endif
Endif

If nTrigger <> NIL
	n := nSavN
Endif

aCols[n][nPTes] := cTesAnt
aCols[n][nPProd]:= cProdAnt
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tk273DesCab³ Autor ³ Vendas Clientes      ³ Data ³ 20/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao corrige os dados entre o cabecalho e a GetDados ³±±
±±³          ³avaliando Desconto, CFOP , Tipo do Pedido e Tabela de Preco ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Posicao inicial no acols                             ³±±
±±³          ³ExpL2: Indica se o recalculo e  somente do desconto de      ³±±
±±³          ³cabecalho.                                                  ³±±
±±³          ³ExpN3: Valor que será utilizado prioritariamente.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk273DesCab(nPos,lTudo,nValor)

Local aArea		:= GetArea()
Local nPProd    := aPosicoes[1][2]		// Produto
Local nPQtd		:= aPosicoes[4][2]		// Quantidade
Local nPPrcUni	:= aPosicoes[5][2]		// Preco Unitario
Local nPVlrItem	:= aPosicoes[6][2]		// Valor do Item
Local nPDescon	:= aPosicoes[9][2]		// Desconto em %
Local nPVlDesc	:= aPosicoes[10][2]		// Desconto em R$
Local nPAcre	:= aPosicoes[13][2]		// Valor de Acrescimo R$
Local nPTes	    := aPosicoes[11][2]		   		// Tes
Local nPValAcre	:= aPosicoes[14][2]		// Valor de Acrescimo R$
Local nPPrcTab 	:= aPosicoes[15][2]		// Preco de Tabela
Local nVlrTabela:= 0	  				// Valor de Tabela		
Local nDesconto := 0 					// Valor de Desconto
Local nLinha 	:= 0					// Linha para inicio de calculo
Local nInicio   := 0 					// Contador para indicar o inicio da Getdados
Local nFim		:= 0					// Contador para indicar o fim da Getdados
Local nAnt		:= 0					// Armazena a posicao anterior do "n"
Local nValAcre	:= 0					// Backup do valor ($) de acréscimo
Local cDesconto := TkPosto(M->UA_OPERADO,"U0_DESCONT")		// Desconto  1=ITEM / 2=TOTAL / 3=AMBOS / 4=NAO
Local lRet		:= .T.

Default lTudo	:= .T.					// Inicializa com .T. 
Default nValor	:= 0					// Valor que será utilizado prioritariamente para os cálculos.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se ja existe uma linha posicionada para o calculo ele sera feito a partir desse ponto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPos <> NIL
	nInicio := nPos 	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso contrario, comeca da primeira posicao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nInicio := 1 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for para calcular todos o final sera o ultimo item do aCols³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTudo 
	nInicio := 1
	nFim    := Len(aCols)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso contrario, o inicio e o fim serao a partir da linha atual³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAnt	:= n					
	nFim := nInicio 
	n := nInicio
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se podera dar descontos no cabeçalho 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(cDesconto) == "1" .OR. AllTrim(cDesconto) == "4" .OR. AllTrim(cDesconto) == "2"  // Desconto = Item ou Desconto = Nao ou Desconto = total 
	If M->UA_DESC1 > 0 .OR. M->UA_DESC2 > 0 .OR. M->UA_DESC3 > 0 .OR. M->UA_DESC4 > 0
		If  !lTk271Auto 
			Help( " ", 1, "NAO_DESCON")
		Endif
		M->UA_DESC1:= 0
		M->UA_DESC2:= 0
		M->UA_DESC3:= 0
		M->UA_DESC4:= 0	
		lRet:= .F.
	Endif
Endif

If lRet
	For nLinha := nInicio to nFim
	
		If !aCols[nLinha][Len(aHeader)+1] .AND. !Empty(aCols[nLinha][nPProd]) // Se a linha for valida
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Reavalia os precos dos itens                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nValor > 0
				nVlrTabela := nValor
			Else
				nVlrTabela := aCols[nLinha][nPPrcTab]
			EndIf
			
			If (aCols[nLinha][nPPrcUni] > 0)
			   	aCols[nLinha][nPPrcUni] 	:= FtDescCab(nVlrTabela,{M->UA_DESC1,M->UA_DESC2,M->UA_DESC3,M->UA_DESC4})
				aCols[nLinha][nPVlrItem]	:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPPrcUni],"UB_VLRITEM")
				nValAcre 					:= aCols[nLinha][nPValAcre]
				aCols[nLinha][nPValAcre]	:= 0
				aCols[nLinha][nPAcre]		:= 0
				MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)
			Endif
				
			If (aCols[nLinha][nPPrcTab] > 0)
				aCols[nLinha][nPPrcTab] := nVlrTabela
				MaFisAlt("IT_PRCUNI",aCols[nLinha][nPPrcTab],nLinha)
			Endif
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pega o desconto que será aplicado no item.              ³
			//³Se ha desconto vindo da regra de desconto.              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nDesconto := TkRegraDesc(1,NIL,NIL,NIL,M->UA_CONDPG,nLinha)
			nDesconto := IIf(nDesconto < 0,0,nDesconto)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se há desconto a ser aplicado.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( (nDesconto > 0 .Or. aCols[nLinha][nPVlDesc] > 0) .AND. ;
				 aCols[nLinha][nPPrcUni] > 0  .AND. ;
				 aCols[nLinha][nPVlrItem] > 0 .AND. ;
				 aCols[nLinha][nPPrcTab] > 0 )
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Aplica do desconto no item.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCols[nLinha][nPPrcUni] := FtDescItem( @aCols[nLinha][nPPrcUni],;			//ExpN1: Preco de lista aplicado o desconto de cabecalho    
				  										@aCols[nLinha,nPPrcTab],; 			//ExpN2: Preco de Venda	
														aCols[nLinha,nPQtd],;				//ExpN3: Quantidade vendida
														@aCols[nLinha,nPVlrItem],;			//ExpN4: Valor Total (do item)
														@nDesconto,;              			//ExpN5: Percentual de desconto
														@aCols[nLinha,nPVlDesc],;			//ExpN6: Valor do desconto
														@aCols[nLinha,nPDescon],;			//ExpN7: Valor do desconto original
														1)									//ExpN8: Tipo de Desconto (1 % OU 2 R$)	
														
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o desconto de acordo com a regra de desconto.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCols[nLinha][nPDescon] := nDesconto
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se já tiver acréscimo preenchido, adiciona o acréscimo³
				//³novamente.                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nValAcre > 0
					TkP000H(nValAcre, nLinha)
				EndIf
				
				MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)
			Endif 
			If cPaisLoc == "BRA" .And. !Empty(aCols[nLinha][nPTes]) .And. ( M->UA_DESC4 > 0 .OR. M->UA_DESC1 > 0 .OR. M->UA_DESC2 > 0 .OR. M->UA_DESC3 > 0)
				SF4->(dbSetOrder(1))
				SF4->(dbseek(xFilial("SF4")+aCols[nLinha][nPTes]))
				If SF4->F4_IPI == "S" .And. SF4->F4_TPIPI == "B" 
					MaFisAlt("IT_BASEIPI",aCols[nLinha][nPPrcTab],nLinha)				
				EndIf
			EndIf												    												    
	 	Else 		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pega o desconto que será aplicado de acordo       ³
			//³com o cabeçalho da regra de desconto.             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nDesc := TkRegraDesc(2,NIL,@M->UA_DESC4,NIL,M->UA_CONDPG,nLinha)
			If nDesc >= 0
				M->UA_DESC4 := nDesc
			EndIf
		Endif	
	
	Next nLinha  
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o aCols e o rodape.                            ³
//³Não pode rodar o MatFisToCols pois perde as atualizações³
//³feitas na aCols por gatilhos de cliente.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bGDRefresh)
Eval(bRefresh)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna o estado de entrada da rotina                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTudo
	n := nAnt
EndIf
RestArea(aArea)

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMKA271Cfo³Autor  ³ Vendas Clientes    ³ Data ³  10/01/02   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Atualizacao do CFO conforme a TES informada/Gatilho no SX7  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do cliente                                    ³±±
±±³          ³ExpC2: Loja do cliente                                      ³±±
±±³          ³ExpC3: Tes utiizada                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TELEVENDAS                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK273Cfo( cCodCli,	cCodLoja, cTes )

Local aArea	   := GetArea()						// Salva a area atual
Local cEstado  := SuperGetMv("MV_ESTADO")		// Estado atual da empresa usuaria
Local cAlias   := ""							// alias do SA1 ou SUS	
Local cTipoCli := IIf(Type("M->UA_TIPOCLI") == "U",SUA->UA_TIPOCLI,M->UA_TIPOCLI)	// variavel para identificar o TIPO do cliente / prospect
Local cEstCli  := ""							// Estado do cliente
Local cInsCli  := ""							// Inscricao estadual do cliente
Local aDadosCFO:= {}							// Array para a funcao fiscal		
Local cRet	   := ""							// Retorno para o campo de CFO 
Local cTpFrete := IIf(Type("M->UA_TPFRETE") == "U",SUA->UA_TPFRETE,M->UA_TPFRETE)
Local lCliEntr := SUA->(ColumnPos("UA_CLIENT")) > 0 .And. SUA->(ColumnPos("UA_LOJAENT")) > 0

If lProspect
	cAlias := "SUS"
Else
	cAlias := "SA1"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao tiver parametros, carrega com as variaveis de memoria³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cCodCli)
	cCodCli	:= M->UA_CLIENTE
	cCodLoja:= M->UA_LOJA
Endif        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o campo M->UB_TES não existe retorna para não gerar³
//³erro no gatilho.                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cTes) .And. Type("M->UB_TES") == "U"
	Return cRet
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se não passou por parâmetro, pega da variável de memória.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cTes)
	cTes := M->UB_TES
Endif

If lCliEntr .And. !lProspect .And. cAlias == "SA1" .And. !Empty(M->UA_CLIENT) .And. !Empty(M->UA_LOJAENT)	
	cCodCli  := M->UA_CLIENT
	cCodLoja := M->UA_LOJAENT
EndIf

DbSelectArea( cAlias )
DbSetOrder( 1 )
If DbSeek( xFilial( cAlias ) + cCodCli + cCodLoja )
	If lProspect
		cEstCli  := SUS->US_EST
		cInsCli  := SUS->US_INSCR
	Else
		cEstCli  := SA1->A1_EST
		cInsCli  := SA1->A1_INSCR
	Endif
Endif                                                 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o bloqueio de registro da TES utilizada                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistCpo("SF4", cTes)
	
	DbSelectArea("SF4")
	DbSetOrder(1)
	If DbSeek( xFilial( "SF4" ) + cTes )
	
		If SF4->F4_DUPLIC == "S"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a TES nao estiver bloqueada valida se a quantidade pode ser igual a 0,00  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        If MaTesSel(cTes)
				lTesTit := .F.				
			Else
				lTesTit := .T.	
			Endif
		Else
			lTesTit := .F.
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenche o CFO                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc<>"BRA"
			cRet := AllTrim( SF4->F4_CF )
		Else
			Aadd(aDadosCFO,{"OPERNF"	,"S" 			})
			Aadd(aDadosCFO,{"TPCLIFOR"	,cTipoCli 		})
			Aadd(aDadosCFO,{"UFDEST"	,cEstCli 		})
			Aadd(aDadosCFO,{"INSCR"		,cInsCli 		})	 	
			Aadd(aDadosCFO,{"CONTR"		,SA1->A1_CONTRIB})
			Aadd(aDadosCFO,{"FRETE" 	,cTpFrete		})

			cRet := MaFisCfo(,SF4->F4_CF,aDadosCFO)		
		Endif
	Endif
Endif
	
RestArea( aArea )
Return( cRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk273GetOk  ³ Autor ³ Vendas Clientes     ³ Data ³ 11/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida‡„o Geral da GetDados de Televendas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso  	 ³TeleVendas    								              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet: .T. para validar a linha ou .F. para não validar     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk273GetOK()

Local lTkEvali			:= ExistBlock("TKEVALI")		// P.E. para TLV
Local nLinha			:= 1							// Contador das linhas do ACOLS
Local nPProd    		:= aPosicoes[1][2]				// Produto
Local nPQtd     		:= aPosicoes[4][2]				// Quantidade
Local nPVrUnit  		:= aPosicoes[5][2]				// Valor Unitario
Local nPVlrItem 		:= aPosicoes[6][2]				// Valor do item 
Local nPTes	    		:= aPosicoes[11][2]				// Tes 	
Local lRet 	 			:= .T.							// Retorno da funcao
Local lNewLin			:= .F.							// Indica se a linha do acols esta em branco
Local nDeletadas		:= 0        

If lTkEvali
	If !ExecBlock( "TKEVALI", .F., .F. )
		lRet := .F. 
	Endif
Endif

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se foi criada uma linha em branco no aCols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto
		lNewLin := oGetTlv:lNewLine
		If !Empty(M->UA_VEND) .AND. !ExistCpo("SA3",M->UA_VEND)
			lRet := .F.
		EndIf		
		If !Empty(M->UA_TABELA) .AND. !ExistCpo("DA0",M->UA_TABELA)
			lRet := .F.
		EndIf		
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o usuario estiver fazendo um ATENDIMENTO não   ³
	//³valida todos os campos ele poderá gravar o mínimo.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Val(M->UA_OPER) <> ATENDIMENTO .AND. !Empty(M->UA_OPER)
		For nLinha := 1 to Len(aCols)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a linha nao estiver deletada e se a mesma nao for uma³
			//³nova linha em branco (sem nenhum campo informado)       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLinha == Len(aCols) .AND. lNewLin
				Loop
			Endif
			
			If !aCols[nLinha][Len(aHeader)+1] 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o produto, a quantidade ou o preco unitario e do item estiverem vazios nao avanca³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If 	Empty(aCols[nLinha][nPProd]) 	.OR.;
					Empty(aCols[nLinha][nPVrUnit]) 	.OR.;			
					Empty(aCols[nLinha][nPTes])
			        
					If !lTk271Auto
						Help(" ",1,"A010VAZ")
						lRet := .F.
					Endif	       
					Return(lRet)
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se a quantidade for igual a 0,00 ou o valor total³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(aCols[nLinha][nPQtd]) .OR. Empty(aCols[nLinha][nPVlrItem])

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a TES nao permite nao lanca³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                If ! MaTesSel(aCols[nLinha][nPTes])
						Help(" ",1,"A410VZ")
						lRet := .F.
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Caso contrario, atualiza a flag para que o sistema considere valor e quantidade = 0,00 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lTesTit := .F.				
					EndIf                          

					Return(lRet)

				EndIf		
					
			Else
				nDeletadas++	// -- Conta as linhas deletadas					
			EndIf
			
		Next nLinha

	EndIf
		
	If nDeletadas == Len(aCols) // -- se todas as linhas estiverem deletadas não continua,
		Help(" ",1,"A410VZ")	// -- exceto para o tipo ATENDIMENTO, que poderá ser gravado sem informar nenhum item.
		lRet := .F.			
	EndIf
	
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tk273Sx3   ³ Autor ³ Vendas Clientes      ³ Data ³ 01/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega os campos do PARAMETRO em um array para a gravacao  ³±±
±±³          ³das rotinas de TeleMarketing e Televendas               	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela que sera carrega do SX3              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com os campos do Alias								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Somente Televendas                                 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273Sx3(cAlias)

Local aSx3Aux := {}   				// Array de retorno

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os campos do alias solicitado pelo SX3   	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cAlias)
While !Eof() .AND. (X3_ARQUIVO == cAlias)
	
	If X3Uso(X3_USADO) 
		
		
		Aadd(aSx3Aux,{	X3_CAMPO,;				// 01 - Nome do Campo
						X3_CONTEXT,;           	// 02 - Indica se o campo eh Virtual
						.T.	,;					// 03 - 
						AllTrim(X3Titulo())})	// 04 - Descricao do Campo no idioma corrente
	Else

		Aadd(aSx3Aux,{	X3_CAMPO,;				// 01 - Nome do Campo
						X3_CONTEXT,;           	// 02 - Indica se o campo eh Virtual
						.F.	,;					// 03 - 
						AllTrim(X3Titulo())})	// 04 - Descricao do Campo no idioma corrente				
		
	Endif
	SX3->(DbSkip())
End
                                                       
Return(aSx3Aux)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tk273DesCLi³ Autor ³ Vendas Clientes      ³ Data ³ 05/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Aplica o desconto informado no cabecalho e depois o desconto³±±
±±³          ³atual do item                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Linha do aCols para analise.                         ³±±
±±³          ³ExpN2: Tipo de Desconto (1 % OU 2 R$)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TELEVENDAS                                          		  ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk273DesCLi(nLinha,nTipo)

Local aArea		:= GetArea()			// Salva a area atual
Local nPQtd		:= aPosicoes[4][2]		// Quantidade
Local nPPrcUni	:= aPosicoes[5][2]		// Preco Unitario
Local nPVlrItem	:= aPosicoes[6][2]		// Valor do Item 
Local nPDescon	:= aPosicoes[9][2]		// Desconto em %
Local nPVlDesc	:= aPosicoes[10][2]		// Desconto em R$
Local nPValAcre	:= aPosicoes[14][2]		// Valor de Acrescimo R$
Local nPPrcTab 	:= aPosicoes[15][2]		// Preco de Tabela
Local nVlrTabela:= 0					// Valor de Tabela

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Reavalia os precos dos itens                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlrTabela := aCols[nLinha][nPPrcTab]
			
If (aCols[nLinha][nPPrcUni] > 0)
	aCols[nLinha][nPPrcUni] := FtDescCab(nVlrTabela,{M->UA_DESC1,M->UA_DESC2,M->UA_DESC3,M->UA_DESC4})
	aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPPrcUni],"UB_VLRITEM")
	MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver acrescimo no item - acumula no valor de tabela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPValAcre] > 0 
	aCols[nLinha][nPPrcUni] += aCols[nLinha][nPValAcre]
Endif	
	
If (aCols[nLinha][nPPrcTab] > 0)
	aCols[nLinha][nPPrcTab] := nVlrTabela
	MaFisAlt("IT_PRCUNI",aCols[nLinha][nPPrcTab],nLinha)
Endif

If ( aCols[nLinha][nPDescon] > 0  .OR. ;
	 aCols[nLinha][nPVlDesc] > 0  .AND. ;
	 aCols[nLinha][nPPrcUni] > 0  .AND. ;
	 aCols[nLinha][nPVlrItem] > 0 .AND. ;
	 aCols[nLinha][nPPrcTab] > 0 )

 	 aCols[nLinha][nPPrcUni] := FtDescItem( @aCols[nLinha][nPPrcUni],;			//ExpN1: Preco de lista aplicado o desconto de cabecalho    
	  										@aCols[nLinha,nPPrcTab],; 			//ExpN2: Preco de Venda	
											aCols[nLinha,nPQtd],;				//ExpN3: Quantidade vendida
											@aCols[nLinha,nPVlrItem],;			//ExpN4: Valor Total (do item)
											@aCols[nLinha][nPDescon],;       	//ExpN5: Percentual de desconto
											@aCols[nLinha,nPVlDesc],;			//ExpN6: Valor do desconto
											@aCols[nLinha,nPDescon],;			//ExpN7: Valor do desconto original
											nTipo)								//ExpN8: Tipo de Desconto (1 % OU 2 R$)	
	MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)
Endif

Eval(bRefresh)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna o estado de entrada da rotina                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)
Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK273ChkTes  ºAutor  ³ Vendas Clientes º Data ³  23/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe Tes que gera duplicata                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273ChkTes()

Local aArea		:= GetArea()						// Salva a area atual
Local lTesDupl 	:= .F.              				// Flag de TES com duplicatas	
Local nUsado   	:= Len(aHeader)						// Tamanho do aHeader
Local nPTes	    := aPosicoes[11][2]					// Posicao do Tes 	
Local nLinha   	:= 0 								// Variavel do For
Local nPQtd     := aPosicoes[4][2]					// Posicao da Quantidade

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o campo de TES esta no browse³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPTes > 0 .AND. Type("aCols") <> "U"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Varre o aCols para verificar o TES                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLinha := 1 to Len(aCols)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item esta deletado                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !aCols[nLinha][nUsado+1] 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca o TEs e verificar se gera duplicata         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SF4")
			DbSetOrder(1)
			If DbSeek( xFilial("SF4") + aCols[nLinha][nPTes] ) 
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se a TES esta configurada para gerar titulo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF4->F4_DUPLIC == "S"
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a quantidade for igual a 0                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aCols[nLinha][nPQtd] == 0
			
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Valida se a TES esta configurada para permitir que o sistema considere a quantidade = 0,00 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                        If MaTesSel(aCols[nLinha][nPTes])
							
							// Nao obriga que o valor total seja maior que 0,00 no atendimento
							lTesDupl := .F.

						Endif
					Else
					
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Troca a variavel indicando que existem TES com duplicata      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
						lTesDupl := .T.
					Endif
						
					Exit	
					
				Endif	
		
			Endif			        	

		Endif   
		
	Next nLinha
	
Endif	

RestArea(aArea)

Return(lTesDupl)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Tk273VldResºAutor º Vendas Clientes    º Data º  16/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta função tem a finalidade de validar se um item que foi º±±
±±º		     ³ eliminado resíduo, pode ser alterado ou não.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Nenhum													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 							                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk273VldRes()

Local aAreaSC6	:= SC6->(GetArea())			// Salva area da tabela SC6
Local aAreaSUA	:= SUA->(GetArea())			// Salva area da tabela SUA
Local nPProd    := aPosicoes[1][2]	   		// Posicao do Produto
Local nPItem	:= aPosicoes[20][2]    		// Posicao do Item
Local lRsDoFAt  := IIF(SuperGetMv("MV_RSDOFAT") == "S",.F.,.T.)  // Parametro que permite a edição de pedido eliminado por residuo

If lRsDoFat
	DbSelectArea("SUA")
	DbSetOrder(1)
	DbSeek(xFilial("SUA") + M->UA_NUM)
	
	DbSelectArea("SC6")
	DbSetOrder(1)
	If DbSeek(xFilial("SC6") + SUA->UA_NUMSC5 + aCols[n][nPItem] + aCols[n][nPProd])
		If AllTrim(SC6->C6_BLQ) $ "RS"
			Help(" ",1,"A410ELIM")
			RestArea(aAreaSC6)
			RestArea(aAreaSUA)		
			Return .F.
		EndIf
	EndIf
EndIf

RestArea(aAreaSC6)
RestArea(aAreaSUA)
		
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk273EditLineºAutor  ³ Vendas Clientes º Data ³  04/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função utilizada para recalcular o item, quando é usuário  º±±
±±º		     ³ clica no botão fechar da janela de edição por linha da     º±±
±±º		     ³ MsGetDados.											      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk273EditLine(nLinha)

Local nPProd	:= aPosicoes[1][2]			// Produto	
Local nPQtd     := aPosicoes[4][2]			// Quantidade          
Local nPVrUnit  := aPosicoes[5][2]			// Valor unitario
Local nPDesc 	:= aPosicoes[9][2]			// % Desconto
Local nPTes	    := aPosicoes[11][2]			// Posicao do Tes 	
Local nPAcre 	:= aPosicoes[13][2]			// % Acrescimo
Local nPValAcre := aPosicoes[14][2]			// $ Acrescimo em Valor

DEFAULT nLinha := N

aColsEdit	:= aClone(aCols)
If MaFisFound() .And. Type("aColsEdit") == "A" .And. !Empty(aColsEdit) .And. !GDDeleted(nLinha)
	If (aColsEdit[nLinha][nPProd] <> M->UB_PRODUTO) .Or. (aColsEdit[nLinha][nPQtd] <> M->UB_QUANT) .Or.;
		(aColsEdit[nLinha][nPVrUnit] <> M->UB_VRUNIT) .Or. (aColsEdit[nLinha][nPDesc] <> M->UB_DESC) .Or.;
		(aColsEdit[nLinha][nPTes] <> M->UB_TES) .Or. (aColsEdit[nLinha][nPAcre] <> M->UB_ACRE) .Or.;
		(aColsEdit[nLinha][nPValAcre] <> M->UB_VALACRE)
	
		MaColsToFis(aHeader,aColsEdit,nLinha,"TK273",.T.)
		Eval(bRefresh)	
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Tk273SvMemo

Função para salvar o conteúdo do campo Memo

@param cAlias, Caracter, Alias da tabela para salvar o conteudo do campo Memo
@param nOper, Numerico, nOper = 1 Salva o Conteudo, nOper = 2 - Restaura o Conteudo
@param aCpo, Array, Array com os campos a serem restaurados

@return aMemo

@author Serviços
@since 05/11/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Function Tk273SvMemo(cAlias,nOper,aCpo)
Local aMemo 	:= {}   				// Array de retorno
Local aArea	:= GetArea()
Local nX		:= 0

Default cAlias 	:= ""
Default aCpo		:= {}

If !Empty(cAlias) .And. nOper == 1

	//Carrega os campos do alias solicitado pelo SX3
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAlias)
	While !Eof() .AND. (X3_ARQUIVO == cAlias) 
		If X3Uso(X3_USADO) .And. X3_TIPO = "M"
			Aadd(aMemo,{	X3_CAMPO,;				// 01 - Nome do Campo
							M->&(SX3->X3_CAMPO)})           	// 02 - Conteúdo do campo			
		EndIf
		
		SX3->(DbSkip())
	End

ElseIf nOper == 2 .And. Len(aCpo) > 0
	
	For nX := 1 To Len(aCpo)
		M->&(aCpo[nX][1]) := aCpo[nX][2]		
	Next nX
	
EndIf

RestArea(aArea)
                                                       
Return(aMemo)

//-------------------------------------------------------------------
/*/{Protheus.doc} Tk273TpCliRecal

Função utilizada para recalcular os impostos na mudança do tipo de cliente/fornecedor

@param cTpCliFor, Caracter, Tipo do Cliente/Fornecedor

@return Nil

@author Serviços
@since 08/04/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Static Function Tk273TpCliRecal(cTpCliFor)

Local aArea    	:= GetArea()
Local aAreaSB1 	:= SB1->(GetArea())
Local aAreaSF4 	:= SF4->(GetArea())
Local nX 	   	:= 0 
Local nAcresRat	:= 0
Local cNaturez  := Tk273DpNat(M->UA_CLIENTE, M->UA_LOJA)
Local lCliEntreg:= SUA->(ColumnPos("UA_CLIENT")) > 0 .And. SUA->(ColumnPos("UA_LOJAENT")) > 0
Local cCodCli   := IIF(lCliEntreg .And. !lProspect .And. !Empty(M->UA_CLIENT),M->UA_CLIENT,M->UA_CLIENTE)
Local cLojCli   := IIF(lCliEntreg .And. !lProspect .And. !Empty(M->UA_LOJAENT),M->UA_LOJAENT,M->UA_LOJA)
Local cContrib  := Posicione("SA1",1,xFilial("SA1") + cCodCli + cLojCli,"A1_CONTRIB")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Encerra as operacoes fiscais  O parametro FALSE         ³
//³nao faz a inicializacao do refresh do rodape de impostos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisEnd(.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa os dados do cliente na FUNCAO FISCAL³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisIni( cCodCli,;										// 1-Codigo Cliente/Fornecedor
		  cLojCli,;										// 2-Loja do Cliente/Fornecedor
		 "C",;											// 3-C:Cliente , F:Fornecedor
		 "N",;											// 4-Tipo da NF
		 cTpCliFor,;									// 5-Tipo do Cliente/Fornecedor
		 Nil,;											// 6-Relacao de Impostos que suportados no arquivo
		 Nil,;											// 7-Tipo de complemento
		 Nil,;											// 8-Permite Incluir Impostos no Rodape .T./.F.
		 Nil,;											// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
		 "MATA461",;									// 10-Nome da rotina que esta utilizando a funcao
		 Nil,;											// 11-Tipo de documento
		 Nil,;  										// 12-Especie do documento 
	     IIF(lProspect,M->UA_CLIENTE+M->UA_LOJA,""))	// 13- Codigo e Loja do Prospect 

MaFisClear()

If !lProspect .And. !Empty(cContrib) .And. cContrib == "1" .And. MaFisRet(,"NF_LINSCR")
	//Se o clinte de entrega for inscrito (A1_CONTRIB) altera a MATXFIS para retornar o CFOP correto
	MaFisAlt("NF_LINSCR",.F.)
EndIf

//Seta natureza da operação
If !Empty(cNaturez)
	MaFisAlt("NF_NATUREZA", cNaturez)
EndIf

// Recalcula os impostos dos produtos
For nX := 1 To Len(aCols)

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+aCols[nX][aPosicoes[1][2]]))     
 
	SF4->(DbSetOrder(1))
	SF4->(DbSeek(xFilial("SF4")+aCols[nX][aPosicoes[11][2]]))		

	MaFisIniLoad(nX, ;
				{aCols[nX][aPosicoes[1][2]],;	//IT_PRODUTO
				aCols[nX][aPosicoes[11][2]],; 	//IT_TES
				SB1->B1_CODISS,; 				//IT_CODISS
				aCols[nX][aPosicoes[4][2]],;	//IT_QUANT
				"",; 							//IT_NFORI
				"",; 							//IT_SERIORI
				0,;								//IT_RECNOSB1
				0,;								//IT_RECNOSF4
				0  }) 							//IT_RECORI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcula os valores influenciados pela condicao de pagamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAcresRat := 0
	Tk273RecCpg(,,nX,@nAcresRat)
	
	//Verifica se o item está deletado e retira dos calculos fiscais
	If GDDeleted(nX)
		If !MaFisFound("IT",nX)
			MaFisAdd( "", "", 0,  0,;
					0,  "", "", NIL,;
					0,  0,  0,  0,;
					0)
		Endif
		MaFisDel(nX,aCols[nX][Len(aCols[nX])])
	EndIf
		
	MaFisLoad("IT_VALMERC"	,aCols[nX][aPosicoes[6][2]] + nAcresRat	,nX) 
	MaFisLoad("IT_PRCUNI"	,aCols[nX][aPosicoes[15][2]],nX)        
	MaFisLoad("IT_DESCONTO"	,aCols[nX][aPosicoes[10][2]],nX)
	MaFisLoad("IT_CF"		,TK273Cfo(cCodCli,cLojCli,aCols[nX][aPosicoes[11][2]]),nX)
	MaFisRecal("",nX)
    MaFisEndLoad(nX,2)					

Next nX

RestArea(aAreaSB1)
RestArea(aAreaSF4)
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Tk273DpNat(cEntidade,cCod,cLoja,c1DupNat)
@description	Função utilizada para selecionar a natureza base para um processo de Televendas,
                onde o PEDIDO ainda não está criado, e por conseguinte, não possui a informação
                da natureza da duplicata com base no SC5
@param cCod       Caracter, Código do Cliente/Prospect
@param cLoja     Caracter, Loja do Cliente/Prospect
@return cRet     Código da Natureza
@author Squad CRM/Faturamento
@since 02/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function Tk273DpNat(cCod, cLoja)
	Local cRet			:= Upper(AllTrim(SuperGetMv("MV_1DUPNAT",.F.,""))) 	
	Default cCod		:= ""
	Default cLoja		:= ""
	
	If ("C5_NATUREZ" $ cRet .Or. Empty(cRet) ) .And. ( !Empty(cCod) .And. !Empty(cLoja) )
		If !lProspect
			cRet	:= Posicione("SA1",1,xFilial("SA1")+cCod+cLoja,"A1_NATUREZ")
		Else
			cRet	:= Posicione("SUS",1,xFilial("SUS")+cCod+cLoja,"US_NATUREZ")
		EndIf
	Else	
		cRet := ""
	EndIf
Return cRet 

/*/{Protheus.doc} Tk273SimpNacBA(lRecal)
	@description	Função utilizada para identificar se será aplicado desconto de ICMS Simples Nacional.
					Quando se enquadra nesta condição o calculo deve ser feito no fim do processo.
	@type  Static Function
	@author william.batista
	@since 10/07/2020
	@version 12.1.27
	@param lRecal, logic, indica se será processado o desconto
	@return lSNBA, logic, indica se o a origem e destino contemplam o simples nacional
	/*/
Static Function Tk273SimpNacBA(lRecal)
	
Local lSNBA	:= SuperGetMv('MV_ESTADO') == 'BA' .AND. MaFisRet(,"NF_UFDEST") == "BA"  .AND. MaFisRet(,"NF_SIMPNAC") == "1"
Local cVar	:= ReadVar()

DEFAULT lRecal := .F.

	If lSNBA .AND. lRecal .AND. !(cVar $ "M->UB_DESC|M->UB_VALDESC")
		Tk273TpCliRecal(MaFisRet(,"NF_TPCLIFOR"))
		MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC")-0.01,0+MAFISRET(,"NF_DESCONTO")+aValores[DESCONTO]))
	EndIf

Return lSNBA
