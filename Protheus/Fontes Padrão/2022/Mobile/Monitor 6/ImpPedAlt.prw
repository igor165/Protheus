#include "Inkey.Ch"
#include "FiveWin.ch"
#INCLUDE "Siga.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpPedAlt³ Autor ³ Cleber Martinez       ³ Data ³ 04/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao alternativa dos Pedidos de Venda                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpPedAlt                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpPedAlt(aMata410Cab,aMata410Item,aCab,aItem)          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aMata410Cab : Estrutura do arquivo HC5 (Cabecalho - ATUAL) ³±±
±±³          ³ aMata410Item: Estrutura do arquivo HC6 (Item - ATUAL)      ³±±
±±³          ³ aCab        : Array com os Dados do Arquivo HC5 (Cab.)	  ³±±
±±³          ³ aItem       : Array com os Dados do Arquivo HC6 (Item)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ AFVM020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function ImpPedAlt(aMata410Cab, aMata410Item, aCab, aItem, cPathPalm)

Local cNumPed		:= ""
Local cNumPedPalm   := ""
Local nPosR			:= 0
Local cItemNovo     := "00"
Local aItemTmp		:= {}
Local nPreco		:= 0
Local aPvlNfs       := {} // Valdir
Local lCtbOnline    := Iif(GetMv("MV_ATUSI2")="C",.F.,.T.)
Local cHrIni        := Time() // Hora de Inicio para a gravacao do Log
Local cResp         := ""     // Mensagem no Console do Server e no Log
Local cCliente      := ""
Local cLoja         := ""
Local lConfirmSX8   := .F.
Local cMenNotaS     := ""
Local cMenNotaD     := ""


DbSelectArea("HC5")
DbGoTop()
While !Eof()

	cNumPedPalm := HC5->C5_COTAC
	cCliente    := HC5->C5_CLI    // CLIENTE  
	cLoja       := HC5->C5_LOJA   // LOJA
	nNumItem    := HC5->C5_QTDITE // QTDE DE ITENS DO PEDIDO
	
	// Posiciona o Cadastro de Clientes
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))
    
	HA1->(dbSetOrder(1))
	HA1->(dbSeek(cCliente+cLoja))
	
	If AllTrim(HC5->C5_STATUS) = "N" .And. AllTrim(HA1->A1_STATUS) <> "N"
		
		// Busca o Proximo Numero de Pedido
		SX3->(dbSetOrder(2))
		SX3->(dbSeek("C5_NUM"))
		//If Empty(SX3->X3_RELACAO)
			lConfirmSX8 := .T.
			cNumPed     := GetSxeNum("SC5","C5_NUM")
			SC5->(dbSetOrder(1))
			While SC5->(dbSeek(xFilial("SC5")+cNumPed))
				ConfirmSX8()
				cNumPed := GetSxeNum("SC5","C5_NUM")
			EndDo
		//EndIf
		SX3->(dbSetOrder(1))

	    GravaPLLog(PALMUSER->P_SERIE + Space(20 - Len(PALMUSER->P_SERIE)) + " - Inicio Import.  - " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
		ConOut("PALMJOB: Importacao(2) do Pedido: " + cNumPed)
		   		
   		dbSelectArea("HC5")
		RecLock("SC5",.T.)
		SC5->C5_FILIAL := xFilial("SC5")
		For i:=1 to Len(aMata410Cab)
			If aMata410Cab[i,1] = "C5_NUM"
				Replace &("SC5->"+aMata410Cab[i,1]) With cNumPed
			ElseIf aMata410Cab[i,1] = "C5_CLIENTE"
				Replace &("SC5->"+aMata410Cab[i,1]) With HC5->C5_CLI 
			ElseIf aMata410Cab[i,1] = "C5_TRANSP"
				If !Empty(HC5->C5_TRANSP)
					Replace &("SC5->"+aMata410Cab[i,1]) With HC5->C5_TRANSP 
				EndIf
			ElseIf aMata410Cab[i,1] = "C5_EMISSAO"
				Replace &("SC5->"+aMata410Cab[i,1]) With HC5->C5_EMISS 				
			ElseIf aMata410Cab[i,1] = "C5_TIPOCLI" 
				Replace &("SC5->"+aMata410Cab[i,1]) With SA1->A1_TIPO
			ElseIf aMata410Cab[i,1] = "C5_CLCGC"
				Replace &("SC5->"+aMata410Cab[i,1]) With SA1->A1_CGC
			Elseif aMata410Cab[i,1] = "C5_TAB"	
				   HC6->(DbSeek(cNumPedPalm, .F.))
				   Replace &("SC5->"+aMata410Cab[i,1]) With HC6->C6_TABELA
			ElseIf aMata410Cab[i,1] = "C5_MENNOTA"
				If !Empty(HC5->C5_MENNOTA)
					cMenNotaS := HC5->C5_MENNOTA
					cMenNotaD := ""
					While (nPosR := At(Chr(10),cMenNotaS)) != 0 .Or. (nPosR := At(Chr(13),cMenNotaS)) != 0
						cMenNotaD += Subs(cMenNotaS,1, nPosR - 1)
						cMenNotaS := Subs(cMenNotaS,nPosR + 1, Len(cMenNotaS))
					End
					nPosR := 0
					Replace &("SC5->"+aMata410Cab[i,1]) With cMenNotaD+cMenNotaS
				EndIf			
			ElseIf aMata410Cab[i,1] = "C5_LOJACLI"
				Replace &("SC5->"+aMata410Cab[i,1]) With HC5->C5_LOJA
			ElseIf aMata410Cab[i,1] = "C5_CONDPAG"
				Replace &("SC5->"+aMata410Cab[i,1]) With HC5->C5_COND
			ElseIf aMata410Cab[i,1] = "C5_COTACAO"
				Replace &("SC5->"+aMata410Cab[i,1]) With HC5->C5_COTAC
			ElseIf aMata410Cab[i,1] = "C5_TABELA"
				Replace &("SC5->"+aMata410Cab[i,1]) With HC5->C5_TAB
			ElseIf aMata410Cab[i,1] = "C5_DESCONT"
				Replace &("SC5->"+aMata410Cab[i,1]) With HC5->C5_DESCONT
			ElseIf aMata410Cab[i,1] = "C5_TPFRETE"
				If !Empty(HC5->C5_TPFRETE)
					Replace &("SC5->"+aMata410Cab[i,1]) With HC5->C5_TPFRETE
				EndIf
			ElseIf aMata410Cab[i,1] = "C5_FORMAPG"
				If !Empty(HC5->C5_FORMAPG)
					Replace &("SC5->"+aMata410Cab[i,1]) With HC5->C5_FORMAPG
				EndIf				
			Else				
				Replace &("SC5->"+aMata410Cab[i,1]) With &("HC5->"+aMata410Cab[i,1])
			EndIf
		Next
		SC5->(MsUnLock())
		
		DbSelectArea("HC6")
		DbGoTop()
        nPreco := 0
        If DbSeek(cNumPedPalm, .F.)

			While !Eof() .And. HC6->C6_NUM = cNumPedPalm
				RecLock("SC6",.T.)
				SC6->C6_FILIAL := xFilial("SC6")
				For j := 1 To Len(aMata410Item)
                	If aMata410Item[j,1] = "C6_NUM"
						Replace &("SC6->"+aMata410Item[j,1]) With cNumPed
                	ElseIf aMata410Item[j,1] = "C6_ITEM"
                		cItemNovo := Soma1(cItemNovo,2)
						Replace &("SC6->"+aMata410Item[j,1]) With cItemNovo
					ElseIf aMata410Item[j,1] = "C6_PRCVEN"
						Replace &("SC6->"+aMata410Item[j,1]) With Round(HC6->C6_PRCVEN,2)
                    ElseIf aMata410Item[j,1] = "C6_VALOR"
						Replace &("SC6->"+aMata410Item[j,1]) With Round(HC6->C6_QTDVEN * HC6->C6_PRCVEN,2)
					ElseIf aMata410Item[j,1] = "C6_PRUNIT"
						Replace &("SC6->"+aMata410Item[j,1]) With Round(HC6->C6_PRCVEN,2)
					ElseIf aMata410Item[j,1] = "C6_PRODUTO"
						Replace &("SC6->"+aMata410Item[j,1]) With HC6->C6_PROD
					ElseIf aMata410Item[j,1] = "C6_DESCONT"
						Replace &("SC6->"+aMata410Item[j,1]) With HC6->C6_DESC
					ElseIf aMata410Item[j,1] = "C6_TABELA"
						Replace &("SC6->"+aMata410Item[j,1]) With HC6->C6_TAB
					ElseIf aMata410Item[j,1] = "C6_ICMS"
					    //
					ElseIf aMata410Item[j,1] = "C6_IPI"
					    //
					Else
			        	Replace &("SC6->"+aMata410Item[j,1]) With &("HC6->"+aMata410Item[j,1])
					EndIf
				Next
				SC6->(MsUnLock())
				
                HC6->(dbSkip())
			EndDo

			cItemNovo := "00"
		EndIf                
		
	    dbSelectArea("HC5")	
		RecLock("HC5",.F.)
		HC5->C5_STATUS := "P"
		MsUnlock()
		If lConfirmSX8
		  	ConfirmSX8()
		EndIf
	    GravaPLLog(PALMUSER->P_SERIE + Space(20 - Len(PALMUSER->P_SERIE)) + " - Fim Import. Pedido - " + cNumPed + " - " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
	    ConOut("PALMJOB: Pedido " + cNumPed + " importado com sucesso")
	    
		// Atualiza Data da Ultima Visita no cadastro de Clientes
	 	dbSelectArea("SA1")
		If dbSeek( xFilial("SA1") + SC5->C5_CLIENTE, .F. )
    		RecLock("SA1",.F.)
		    SA1->A1_ULTVIS := SC5->C5_EMISSAO
    		MsUnlock()
	    EndIf
		// Atualiza o cod. do proximo pedido no cadastro de vendedores
	    dbSelectArea("SA3")
	  	If dbSeek( xFilial("SA3") + SC5->C5_VEND1, .F. )
			RecLock("SA3",.F.)
	    	SA3->A3_PROXPED := If(Val(cNumPedPalm)>=Val(SA3->A3_PROXPED),StrZero(Val(cNumPedPalm) + 1,6),SA3->A3_PROXPED)
    		MsUnlock()
    	EndIf

	Endif

	// Ponto de entrada para possibilitar manipulacao dos Array aCab e aItem.
	//If ( (ExistBlock("AFVM020A")) )
	//	ExecBlock("AFVM020A",.F.,.F.)
	//EndIf

    If Len(aCab) > 0 .And. Len(aItem) > 0
		// Busca o Proximo Numero de Pedido
		SX3->(dbSetOrder(2))
		SX3->(dbSeek("C5_NUM"))
		If Empty(SX3->X3_RELACAO)
			lConfirmSX8 := .T.
			cNumPed     := GetSxeNum("SC5","C5_NUM")
			SC5->(dbSetOrder(1))
			While SC5->(dbSeek(xFilial("SC5")+cNumPed))
				ConfirmSX8()
				cNumPed := GetSxeNum("SC5","C5_NUM")
			EndDo
		EndIf
		SX3->(dbSetOrder(1))

		nPos := Ascan(aCab, { |X| X[1] = "C5_NUM" })
		If nPos > 0 .And. !Empty(cNumPed)
			aCab[nPos,2] := cNumPed
		ElseIf nPos > 0
			aCab := aDel(aCab,nPos)
			aCab := aSize(aCab,Len(aCab)-1)
		EndIf

	    lMsHelpAuto := .T.
	    lMsErroAuto := .F.
	    GravaPLLog(PALMUSER->P_SERIE + Space(20 - Len(PALMUSER->P_SERIE)) + " - Inicio MATA410  - " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
	    SF4->(Mata410(aCab,aItem,3))
	    GravaPLLog(PALMUSER->P_SERIE + Space(20 - Len(PALMUSER->P_SERIE)) + " - Fim MATA410  - " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))

	    cNumPed := SC5->C5_NUM
		ConOut("PALMJOB: Importacao de arquivos - Pedido: " + cNumPed) //"Importacao de arquivos - Pedido: "
			    
		cItemNovo := "00"

		If !lMsErroAuto
		    cResp := "PALMJOB: Pedido " + cNumPed + " importado com sucesso."
			GravaPLLog(PALMUSER->P_SERIE + Space(20 - Len(PALMUSER->P_SERIE)) + " - Fim Importacao do Pedido = " + cNumPed + "  - " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
		    dbSelectArea("HC5")	
		    RecLock("HC5",.F.)			// Altera o FLag para 0
		    HC5->C5_STATUS := "P"
		    MsUnlock()
		    If lConfirmSX8
		    	ConfirmSX8()
		    EndIf
		    If !Empty(HC5->C5_NOTA) // Valdir
  		  	   	If HC6->(DbSeek(cNumPedPalm, .F.))
		       		LibCred(cNumPed) 
		  		 	aPvlNfs:={}
				   	SC9->(DbSetOrder(1))
					SC5->(DbSetOrder(1))
					SC6->(DbSetOrder(1))
					SE4->(DbSetOrder(1))
					SB1->(DbSetOrder(1))
					SB2->(DbSetOrder(1))
					SF4->(DbSetOrder(1))
					While HC6->(!Eof()) .And. HC6->C6_NUM=cNumPedPalm
						SC9->(DbSeek(xFilial("SC9")+cNumPed+HC6->C6_ITEM))               //FILIAL+NUMERO+ITEM
						SC5->(DbSeek(xFilial("SC5")+cNumPed))                             //FILIAL+NUMERO
						SC6->(DbSeek(xFilial("SC6")+cNumPed+HC6->C6_ITEM))               //FILIAL+NUMERO+ITEM
						SE4->(DbSeek(xFilial("SE4")+HC5->C5_CONDPAG))                    //CONDICAO DE PGTO			
						SB1->(DbSeek(xFilial("SB1")+HC6->C6_PROD))                    //FILIAL+PRODUTO
						SB2->(DbSeek(xFilial("SB2")+HC6->C6_PROD+HC6->C6_LOCAL))    //FILIAL+PRODUTO+LOCAL
						SF4->(DbSeek(xFilial("SF4")+HC6->C6_TES))                        //FILIAL+CODIGO
						aAdd(aPvlNfs,{;
						     cNumPed, ;              //Numero Pedido
						     HC6->C6_ITEM,;         //Item 
						     HC6->C6_ITEM,;         //Sequencia
						     HC6->C6_QTDVEN ,;      //Qtd Liberada
						     HC6->C6_PRCVEN,;       //preco de Venda
						     HC6->C6_PROD,.f.,; //Produto
							 SC9->(RecNo()),;
							 SC5->(RecNo()),;
						  	 SC6->(RecNo()),;
						  	 SE4->(RecNo()),;
						  	 SB1->(RecNo()),;
						  	 SB2->(RecNo()),;
						  	 SF4->(RecNo())})
		      		 		 HC6->(DbSkip())
					EndDo
					MaPvlNfs2(aPvlNfs,HC5->C5_SERIE,HC5->C5_NOTA, .F., .F., lCtbOnline, .T., .F., 0, 0, .T., .F.,)
				EndIf
			EndIf
		Else
			// Pedido nao Incluido
			cResp := "PALMJOB: Pedido nao Incluido"
		    If lConfirmSX8
				RollBackSX8()
		    EndIf
			MostraErro(cPathPalm)
		EndIf
		ConOut(cResp)
		PSaveLog(PALMUSER->P_SERIE,PALMUSER->P_USERID,MsDate(),cHrIni,Time(),cResp)		
		// Atualiza Data da Ultima Visita no cadastro de Clientes
	 	dbSelectArea("SA1")
    	nPosR := Ascan(aCab, { |X| X[1] = "C5_CLIENTE" })
	    If( nPosR > 0 )
		    If dbSeek( xFilial("SA1") + aCab[nPosR,2], .F. )
    			RecLock("SA1",.F.)
     			nPosR := Ascan(aCab, { |X| X[1] = "C5_EMISSAO" })
		     	SA1->A1_ULTVIS := aCab[nPosR,2]
    		  	MsUnlock()
	    	EndIf
		EndIf
		// Atualiza do Proximo Pedido no cadastro de Vendedores
	    dbSelectArea("SA3")
    	nPosR := Ascan(aCab, { |X| X[1] = "C5_VEND1" })
	  	If( nPosR > 0 )
		  	If dbSeek( xFilial("SA3") + aCab[nPosR,2], .F. )
				RecLock("SA3",.F.)
		    	SA3->A3_PROXPED := If(Val(cNumPedPalm)>=Val(SA3->A3_PROXPED),StrZero(Val(cNumPedPalm) + 1,6),SA3->A3_PROXPED)
    		 	MsUnlock()
	    	EndIf
	    Endif
    EndIf
	aCab    := {}
    aItem   := {}
    cNumped := ""
    dbSelectArea("HC5")
	dbSkip()
EndDo
dbSelectArea("HC5")
dbCloseArea("HC5")
dbSelectArea("HC6")
dbCloseArea("HC6")
dbSelectArea("HA1")
dbCloseArea("HA1")
Return Nil
