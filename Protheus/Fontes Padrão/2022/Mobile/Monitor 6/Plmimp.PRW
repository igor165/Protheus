#include "Inkey.Ch"
#include "FiveWin.ch"
#INCLUDE "Siga.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PImpPed  ³ Autor ³ Fabio Garbin          ³ Data ³ 14.12.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao dos pedidos de vendas do Palm Pilot             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PImpPed                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function PImpPed()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais do Programa 				   	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aMata410Cab := {}
Local aMata410Item:= {}
Local aArquivos   := {}
//Local aNpos       := {}
//Local cArqNpos    := ""
Local cPathPalm   := GetSrvProfString("HandHeldDir","\HANDHELD\") + "P" + AllTrim(PALMUSER->P_DIR) + "\atual\"
//Local cPath       := ""
//Local cVend       := PALMUSER->P_CODVEND
Local cAlternativa:= GetMv("MV_SFIMPA",,"N") //Importacao alternativa de Pedidos
Local cFilePedC   :="HC5" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local cFilePedI   :="HC6" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  
Local cFileCli    :="HA1" + cEmpAnt + "0" 

Private aCab      := {}
Private aItem     := {}

GravaPLLog(PALMUSER->P_SERIE + Space(20 - Len(PALMUSER->P_SERIE)) + " - Inicio Importacao do Pedido  - " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))

aAdd(aArquivos, {cFilePedC, "HC5", "C5_NUM"})
aAdd(aArquivos, {cFilePedI, "HC6", "C6_NUM+C6_ITEM"})
aAdd(aArquivos, {cFileCli,  "HA1", "A1_COD+A1_LOJA"})

aAdd(aMATA410Cab,{"C5_NUM"                ,"C",06,0}) // Numero do pedido
aAdd(aMATA410Cab,{"C5_TIPO"               ,"C",01,0}) // Tipo de pedido
aAdd(aMATA410Cab,{"C5_CLIENTE"            ,"C",06,0}) // Codigo do cliente
aAdd(aMATA410Cab,{"C5_LOJACLI"            ,"C",02,0}) // Loja do cliente
aAdd(aMATA410Cab,{"C5_TRANSP"             ,"C",06,0}) // Transportadora
aAdd(aMATA410Cab,{"C5_CONDPAG"            ,"C",03,0}) // Codigo da condicao de pagamanto
aAdd(aMATA410Cab,{"C5_VEND1"              ,"C",06,0}) // Codigo do vendedor
aAdd(aMATA410Cab,{"C5_MENNOTA"            ,"C",30,0}) // Mensagem da nota
aAdd(aMATA410Cab,{"C5_EMISSAO"            ,"D",08,0}) // Data de emissao
aAdd(aMATA410Cab,{"C5_COTACAO"            ,"C",06,0}) // Licitacao
aAdd(aMATA410Cab,{"C5_TABELA"             ,"C",03,0}) // Codigo da Tabela de Preco
aAdd(aMATA410Cab,{"C5_TIPOCLI"            ,"C",01,0}) // Tipo do Cliente
aadd(aMATA410Cab,{"C5_DESCONT"            ,"N",15,2}) // Valor da Indenizacao
aadd(aMATA410Cab,{"C5_FORMAPG"            ,"C",06,0}) // Forma de Pagamento
aadd(aMATA410Cab,{"C5_TPFRETE"            ,"C",01,0}) // Tipo de Frete (CIF ou FOB)
aadd(aMATA410Cab,{"C5_PARC1"         	, "N", 12, 2}) // Valor da Parcela 1 
aadd(aMATA410Cab,{"C5_DATA1"         	, "D",  8, 0}) // Data da Parcela 1
aadd(aMATA410Cab,{"C5_PARC2"         	, "N", 12, 2}) // Valor da Parcela 2
aadd(aMATA410Cab,{"C5_DATA2"         	, "D",  8, 0}) // Data da parcela 2
aadd(aMATA410Cab,{"C5_PARC3"         	, "N", 12, 2}) // Valor da Parcela 3
aadd(aMATA410Cab,{"C5_DATA3"         	, "D",  8, 0}) // Data da parcela 3
aadd(aMATA410Cab,{"C5_PARC4"         	, "N", 12, 2}) // Valor da Parce 4
aadd(aMATA410Cab,{"C5_DATA4"         	, "D",  8, 0}) // Data da Parcela 4

//If cPaisLoc <> "BRA"
//	aAdd(aMATA410Cab,{"C5_CLCGC"                ,"C",14,0}) // RUT
//EndIf

aAdd(aMATA410Item,{"C6_NUM"               ,"C",06,0}) // Numero do Pedido
aAdd(aMATA410Item,{"C6_ITEM"              ,"C",02,0}) // Numero do Item no Pedido
aAdd(aMATA410Item,{"C6_PRODUTO"           ,"C",15,0}) // Codigo do Produto
aAdd(aMATA410Item,{"C6_QTDVEN"            ,"N",09,2}) // Quantidade Vendida
aAdd(aMATA410Item,{"C6_PRUNIT"            ,"N",11,2}) // Preco Unitario Bruto
aAdd(aMATA410Item,{"C6_PRCVEN"            ,"N",11,2}) // Preco Unitario Liquido
aAdd(aMATA410Item,{"C6_VALOR"             ,"N",12,2}) // Valor Total do Item
aAdd(aMATA410Item,{"C6_ENTREG"            ,"D",08,0}) // Data da Entrega
aAdd(aMATA410Item,{"C6_UM"                ,"C",02,0}) // Unidade de Medida Primar.
aAdd(aMATA410Item,{"C6_TES"               ,"C",03,0}) // Tipo de Entrada/Saida do Item
aAdd(aMATA410Item,{"C6_LOCAL"             ,"C",02,0}) // Almoxarifado
aAdd(aMATA410Item,{"C6_DESCONT"           ,"N",05,2}) // Percentual de Desconto
aAdd(aMATA410Item,{"C6_ICMS"              ,"N",12,2}) // I.C.M.S
aAdd(aMATA410Item,{"C6_IPI"               ,"N",12,2}) // I.P.I

ConOut("PALMJOB: Importando Pedidos para " + Trim(PALMUSER->P_USER))
If PChkFile(cPathPalm, aArquivos)
	If Upper(cAlternativa) = "N" .Or. Empty(cAlternativa)
		U_fMontaVetor(aMata410Cab, aMata410Item, @aCab, @aItem, cPathPalm)
	Else
		If FindFunction("U_ImpPedAlt")
			U_ImpPedAlt(aMata410Cab, aMata410Item, @aCab, @aItem, cPathPalm)
		Else
		    ConOut("PALMJOB: Funcao alternativa de pedidos U_ImpPedAlt nao compilada no RPO!")
		Endif
	Endif
Else
	ConOut("PALMJOB: Arquivo de pedido nao encontrado.")
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ fMontaVetor³ Autor ³ Fabio Garbin        ³ Data ³ 15/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fMontaVetor(aMata410Cab,aMata410Item,aCab,aItem)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aMata410Cab : Estrutura do arquivo do PedidoC (Cabecalho)  ³±±
±±³          ³ aMata410Item: Estrutura do arquivo do PedidoI (Item)       ³±±
±±³          ³ aCab        : Array com os Dados do Arquivo CDB (Cabecalho)³±±
±±³          ³ aItem       : Array com os Dados do Arquivo CDB (Item)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ AFVM020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function fMontaVetor(aMata410Cab, aMata410Item, aCab, aItem, cPathPalm)

Local cNumPed		:= ""
Local cNumPedPalm   := ""
Local nPosR			:= 0
Local cItemNovo     := "00"
Local aItemTmp		:= {}
Local nPreco		:= 0
Local aPvlNfs       := {} // Valdir
Local lCtbOnline    := Iif(GetMv("MV_ATUSI2")="C",.F.,.T.)
Local cUltVis       := GetMv("MV_HHULTVIS",,"S")  // Parametro para verificar 
Local cHrIni        := Time() // Hora de Inicio para a gravacao do Log
Local cResp         := ""     // Mensagem do no Console do Server e no Log
Local cCliente      := ""
Local cLoja         := ""
Local lConfirmSX8   := .F.
Local cMenNotaS     := ""
Local cMenNotaD     := ""
Local i:=1
Local j := 1
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
   		dbSelectArea("HC5")
		For i:=1 to Len(aMata410Cab)
			If aMata410Cab[i,1] = "C5_NUM"
				aAdd(aCab,{aMata410Cab[i,1],cNumPedPalm,Nil})
			ElseIf aMata410Cab[i,1] = "C5_CLIENTE"
				aAdd(aCab,{aMata410Cab[i,1],HC5->C5_CLI,Nil})
			ElseIf aMata410Cab[i,1] = "C5_TRANSP"
				If !Empty(HC5->C5_TRANSP)
					aAdd(aCab,{aMata410Cab[i,1],HC5->C5_TRANSP,Nil})
				EndIf
			ElseIf aMata410Cab[i,1] = "C5_EMISSAO"
				aAdd(aCab,{aMata410Cab[i,1],HC5->C5_EMISS,Nil})
			ElseIf aMata410Cab[i,1] = "C5_COTAC"
				aAdd(aCab,{aMata410Cab[i,1],cNumPedPalm,Nil})			
			ElseIf aMata410Cab[i,1] = "C5_TIPOCLI" 
				aAdd(aCab,{aMata410Cab[i,1],SA1->A1_TIPO,Nil})	
			ElseIf aMata410Cab[i,1] = "C5_CLCGC"
				aAdd(aCab,{aMata410Cab[i,1],SA1->A1_CGC,Nil})
			Elseif aMata410Cab[i,1] = "C5_TAB"	
				   HC6->(DbSeek(cNumPedPalm, .F.))
				   aAdd(aCab,{aMata410Cab[i,1],HC6->C6_TABELA,Nil})
			ElseIf aMata410Cab[i,1] = "C5_MENNOTA"
				If !Empty(HC5->C5_MENNOTA)
					cMenNotaS := HC5->C5_MENNOTA
					cMenNotaD := ""
					While (nPosR := At(Chr(10),cMenNotaS)) != 0 .Or. (nPosR := At(Chr(13),cMenNotaS)) != 0
						cMenNotaD += Subs(cMenNotaS,1, nPosR - 1)
						cMenNotaS := Subs(cMenNotaS,nPosR + 1, Len(cMenNotaS))
					End
					nPosR := 0
					aAdd(aCab,{aMata410Cab[i,1],cMenNotaD + cMenNotaS,Nil})
				EndIf			
			ElseIf aMata410Cab[i,1] = "C5_LOJACLI"
				aAdd(aCab,{aMata410Cab[i,1],HC5->C5_LOJA,Nil})
			ElseIf aMata410Cab[i,1] = "C5_CONDPAG"
				aAdd(aCab,{aMata410Cab[i,1],HC5->C5_COND,Nil})
			ElseIf aMata410Cab[i,1] = "C5_COTACAO"
				aAdd(aCab,{aMata410Cab[i,1],HC5->C5_COTAC,Nil})
			ElseIf aMata410Cab[i,1] = "C5_TABELA"
				aAdd(aCab,{aMata410Cab[i,1],HC5->C5_TAB,Nil})
			ElseIf aMata410Cab[i,1] = "C5_DESCONT"
				aAdd(aCab,{aMata410Cab[i,1],HC5->C5_DESCONT,Nil})
			ElseIf aMata410Cab[i,1] = "C5_TPFRETE"
				If !Empty(HC5->C5_TPFRETE)
					aAdd(aCab,{aMata410Cab[i,1],HC5->C5_TPFRETE,Nil})
				EndIf
			ElseIf aMata410Cab[i,1] = "C5_FORMAPG"
				If !Empty(HC5->C5_FORMAPG)
					aAdd(aCab,{aMata410Cab[i,1],HC5->C5_FORMAPG,Nil})
				EndIf				
			Else				
				aAdd(aCab,{aMata410Cab[i,1],&("HC5->"+aMata410Cab[i,1]),Nil})
			EndIf
		Next
		DbSelectArea("HC6")
		DbGoTop()
        nPreco := 0
        If DbSeek(cNumPedPalm, .F.)
			While !Eof() .And. C6_NUM=cNumPedPalm
				For j := 1 To Len(aMata410Item)
                	If aMata410Item[j,1] = "C6_NUM"
						aAdd(aItemTmp,{aMata410Item[j,1],cNumPed,Nil})
                	ElseIf aMata410Item[j,1] = "C6_ITEM"
                		cItemNovo := Soma1(cItemNovo,2)
						aAdd(aItemTmp,{aMata410Item[j,1],cItemNovo,Nil})
					ElseIf aMata410Item[j,1] = "C6_PRCVEN"
     					//aAdd(aItemTmp,{aMata410Item[j,1],&("HC6->"+aMata410Item[j,1]),Nil})
     					aAdd(aItemTmp,{aMata410Item[j,1],Round(HC6->C6_PRCVEN,2),Nil})
						dbSelectArea("HC6")
                    ElseIf aMata410Item[j,1] = "C6_VALOR"
	                	aAdd(aItemTmp,{aMata410Item[j,1],Round(HC6->C6_QTDVEN * HC6->C6_PRCVEN,2),Nil})
                    /*
                    ElseIf aMata410Item[j,1] = GetMv("MV_CPOLVR")
						    dbSelectArea("SX3")
						    dbSetOrder(2)
						    If dbSeek(GetMv("MV_CPOLVR")) .And. X3_TIPO="N"
								aAdd(aItemTmp,{aMata410Item[j,1],Val(&("HC6->"+aMata410Item[j,1])),Nil})
							Else
								aAdd(aItemTmp,{aMata410Item[j,1],&("HC6->"+aMata410Item[j,1]),Nil})
							EndIf
							dbSelectArea("HC6")
					*/
					ElseIf aMata410Item[j,1] = "C6_PRUNIT"
						aAdd(aItemTmp,{aMata410Item[j,1],Round(HC6->C6_PRCVEN,2),Nil}) // Preco Bruto
					ElseIf aMata410Item[j,1] = "C6_PRODUTO"
						aAdd(aItemTmp,{aMata410Item[j,1],HC6->C6_PROD,Nil}) // Preco Bruto
					ElseIf aMata410Item[j,1] = "C6_DESCONT"
						aAdd(aItemTmp,{aMata410Item[j,1],HC6->C6_DESC,Nil}) // Preco desconto
					ElseIf aMata410Item[j,1] = "C6_TABELA"
						aAdd(aItemTmp,{aMata410Item[j,1],HC6->C6_TAB,Nil}) // Preco desconto						
					Else
			        	aAdd(aItemTmp,{aMata410Item[j,1],&("HC6->"+aMata410Item[j,1]),Nil})
					EndIf
				Next
				If !Empty(HC5->C5_NOTA) // Valdir				
	  				aAdd(aItemTmp,{"C6_QTDLIB",HC6->C6_QTDVEN,Nil})					
				EndIf
                dbSkip()
                If Len(aItemTmp) > 0
		            aAdd(aItem, aClone(aItemTmp))
                EndIf
				aItemTmp   := {}
			EndDo
			cItemNovo := "00"
		EndIf                
		
		If nNumItem != Len(aItem)
			ConOut("Pedido " + cNumPedPalm + " nao Importado, pedido nao transmitido completamente.")
			aCab  := {}
			aItem := {}
		EndIf

	Endif

	// Ponto de entrada para possibilitar manipulacao dos Array aCab e aItem.
	If ( (ExistBlock("AFVM020A")) )
		ExecBlock("AFVM020A",.F.,.F.)
	EndIf

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
		If cUltVis = "S"
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

HC5->(dbCloseArea())
HC6->(dbCloseArea())
HA1->(dbCloseArea())
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ LibCred    ³ Autor ³ VALDIR              ³ Data ³ 30/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LibCred(cNumPed)						  		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNumPed : Numero do Pedido a ser Liberado				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AFVM020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LibCred(cNumPed)
SC9->(DbSetOrder(1))
SC9->(DbSeek(xFilial("SC9")+cNumPed) )                    //FILIAL+NUMERO+ITEM
While SC9->(!EOF()) .and. SC9->C9_FILIAL == xFilial("SC9") .and. SC9->C9_PEDIDO == cNumPed
// Parametros nOpc: 1 - Libera
//                  2 - Rejeita
//            lAtuCred : Indica se Libera Credito
//            lAtuEst  : Indica se Libera Estoque
   a450Grava(1,.T.,.F.)
   SC9->(DbSkip())
End         

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PImpOco  ³ Autor ³ Fabio Garbin          ³ Data ³ 29.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao das Nao Positivacoes do Palm Pilot              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PImpOco                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                            	                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PImpOco                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M. Vieira   ³06/02/04³      ³ Adaptacao p/ a versao eADVPL             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function PImpOco()
Local aArquivos  := {}
Local cFileNpos  :="HD5" + cEmpAnt + "0" 
Local nSeq       := 1
Local cPathPalm  := GetSrvProfString("HandHeldDir","\HANDHELD\") + "P" + AllTrim(PALMUSER->P_DIR) + "\atual\"
Local cVend      := PALMUSER->P_CODVEND
Local lImpOK     :=.f.

aAdd(aArquivos, {cFileNpos,"HD5","AD5_CODCLI+AD5_LOJA+AD5_DTHR"})

ConOut("PALMJOB: Importando Ocorrencias para " + Trim(PALMUSER->P_USER))
If PChkFile(cPathPalm, aArquivos)
	dbSelectArea("HD5")
	dbSetOrder(1)
	While HD5->( !Eof() )                     
	    lImpOk:=.f.		
		// Verifica a proxima sequencia
		dbSelectArea("AD5")
		dbSetOrder(1)
		While dbSeek(xFilial("AD5")+cVend+Subs(HD5->AD5_DTHR,1,8)+StrZero(nSeq,2))
			nSeq := nSeq + 1
		EndDo	                                           
		//Importa apontamentos de nao venda (Ocorrencias)
        If !Empty(HD5->AD5_CODNPO) .And. Alltrim(HD5->AD5_ROTER) != "P"
			RecLock("AD5",.T.)
			AD5->AD5_FILIAL  := xFilial("AD5")
			AD5->AD5_VEND    := cVend
			AD5->AD5_DATA    := StoD(Subs(HD5->AD5_DTHR,1,8))
			AD5->AD5_SEQUEN  := StrZero(nSeq,2)
			AD5->AD5_CODCLI  := HD5->AD5_CODCLI
			AD5->AD5_LOJA    := HD5->AD5_LOJA
			AD5->AD5_EVENTO  := HD5->AD5_CODNPO
		    AD5->(MsUnlock())              
		    ConOut("PALMJOB: Ocorrencia " + HD5->AD5_CODNPO + " importada com sucesso.")
		    lImpOk:=.t.
	    Endif               
	    
	    dbSelectArea("HD5")
	    If lImpOK
		   // Marca registro no Diretorio Atual como processado
		   RecLock("HD5",.F.)
		   HD5->AD5_ROTER := "P"
		   HD5->(MsUnlock())
        Endif		    
        
		HD5->( dbSkip() )
  	EndDo		
	HD5->(dbCloseArea())	
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PImpPsq  ³ Autor ³ Fabio Garbin          ³ Data ³ 01.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao das pesquisas colhidas Palm Pilot               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PImpPsq                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function PImpPsq()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais do Programa 				   	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArquivos  := {}
Local cPathPalm  := GetSrvProfString("HandHeldDir","\HANDHELD\") + "P" + AllTrim(PALMUSER->P_DIR) + "\atual\"
Local cVend      := PALMUSER->P_CODVEND
Local cScript    := ""
Local cCliente   := ""
Local cOperador  := ""
Local cObsTmk    := ""
Local cCampanha  := ""
Local dDataAtend := CtoD("  /  /  ")
Local cHoraIni   := ""
Local cHoraFim   := ""
Local cPergunta  := ""
Local cCodResp   := ""
Local cTipoPerg  := "" 

aAdd(aArquivos, {"perg", "SPT", "SCRIPER"})
aAdd(aArquivos, {"pergopc", "OPC", "SCRIPER"})
aAdd(aArquivos, {"resp", "RSP", "PQPRCLI"})

ConOut("PALMJOB: Importando Respostas para " + Trim(PALMUSER->P_USER))
If PChkFile(cPathPalm, aArquivos)
    // Busca o Operador correspondente ao Vendedor
    dbSelectArea("SU7")
    dbSetOrder(1)
    While !Eof() .And. xFilial() = xFilial("SU7")
    	If cVend = SU7->U7_COD
    		cOperador := SU7->U7_COD
    	EndIf
    	dbSkip()
    EndDo
	dbSelectArea("RSP")
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		If (cScript <> Subs(RSP->PQPRCLI,9,4)) .Or. (cCliente <> Subs(RSP->PQPRCLI,1,6)) .Or. (cLoja <> Subs(RSP->PQPRCLI,7,2))
			cScript      := Subs(RSP->PQPRCLI,9,4)
			cCliente     := Subs(RSP->PQPRCLI,1,6) //Subs(RSP->PQPRCLI,12,6)
			cLoja        := Subs(RSP->PQPRCLI,7,2)
			cObsTmk      := "Telemarketing - Palm - " + DtoC(dDataBase)
			cAtendimento := GetSXENum("SUC","UC_CODIGO")
	        cCampanha    := SPT->CODCAMP
	        dDataAtend   := StoD(Left(RSP->DTINI,8))
	        cHoraIni     := Right(RSP->DTINI,8)
	        cHoraFim     := Right(RSP->DTFIM,8)
			// Cria O Atendimento da Pesquisa
			RecLock("SUC",.T.)
			SUC->UC_FILIAL   := xFilial("SUC")
			SUC->UC_CODIGO   := cAtendimento
			SUC->UC_CLIENTE  := cCLiente
			SUC->UC_LOJA     := cLoja
			SUC->UC_MIDIA    := GetNewPar("MV_TKMIDPM","000001") // Parametro deve ser Criado e Preenchido
			SUC->UC_OPERADOR := If(!Empty(cOperador),cOperador,cVend)
			SUC->UC_OPERACA  := "ATIVO"
			SUC->UC_STATUS   := "01"
			SUC->UC_TIPO     := GetNewPar("MV_TKTIPPM","000001") // Parametro deve ser Criado e Preenchido
			SUC->UC_DATA     := dDataAtend
			SUC->UC_INICIO   := cHoraIni
			SUC->UC_FIM      := cHoraFim
			SUC->UC_CODCONT  := RSP->CODCONT
			SUC->UC_CODCAMP  := cCampanha
			SUC->UC_DIASDAT  := (CTOD("01/01/2045","dd/mm/yyyy") - UC_DATA)
			SUC->UC_HORADAT  := 86400 - ( (VAL(Substr(UC_INICIO,1,2))*3600) + ( VAL(Substr(UC_INICIO,4,2))*60) + VAL(Substr(UC_INICIO,7,2)))
			MSMM(,TamSx3("UC_OBS")[1],,cObsTmk,1,,,"SUC","UC_CODOBS")
            MsUnlock()
            ConfirmSX8()
			ConOut("PALMJOB: Atendimento " + cAtendimento + " cadastrado com sucesso.")
		EndIf	
		cChave := Subs(RSP->PQPRCLI,9,6)
    	SPT->(dbSetOrder(1))
		SPT->(dbSeek(cChave))
	    dbSelectArea("RSP")
    	dbSetOrder(1)
		cPergunta := SPT->CODAP5
	    cCodResp  := PadL(AllTrim(RSP->RESP),7,"0")
	    cTipoPerg := SPT->TPPERG
		SUP->(dbSetOrder(2))
		SUP->(dbSeek(xFilial("SUP")+cCampanha+cPergunta))
		// Grava Respostas da Pesquisa
	    RecLock("SUK",.T.)
		SUK->UK_FILIAL  := xFilial("SUK")
		SUK->UK_CODATEN := cAtendimento
		SUK->UK_CODSCRI := PadL(cScript,6,"0")
		SUK->UK_CODPERG := cPergunta
		If cTipoPerg = "3"
			MSMM(,TamSx3("UK_RESMEMO")[1],,AllTrim(RSP->RESP),1,,,"SUK","UK_CODMEMO")
		Else
			SUK->UK_CODRESP := cCodResp
		EndIf
		SUK->UK_SCORE := SUP->UP_SCORE
	    MsUnlock()
		dbSelectArea("RSP")
		// Apaga Respostas ja Cadatradas
	    RecLock("RSP",.F.)
	   	dbDelete()
	    MsUnlock()
	    dbSelectArea("RSP")
	    dbSkip()
	 EndDo
	SPT->(dbCloseArea())
	OPC->(dbCloseArea())
	RSP->(dbCloseArea())

Else
	ConOut("PALMJOB: Arquivo de pesquisa nao encontrado.")
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PImpCli  ³ Autor ³ Fabio Garbin          ³ Data ³ 14.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao dos Clientes do Palm Pilot                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PImpCli                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function PImpCli()

Local aCliente   := {} // Contem os dados do arquivo de CLIENTES
Local aMata030   := {}
Local aArquivos  := {}
Local i          := 0
Local cPathPalm  := GetSrvProfString("HandHeldDir","\HANDHELD\") + "P" + AllTrim(PALMUSER->P_DIR) + "\atual\"
Local cCodCli    := ""
Local cCodLoja   := ""
Local cCliPalm   := ""
Local cLojPalm   := ""
Local cFiltro    := ""
Local cVend      := PALMUSER->P_CODVEND
Local aCliNovo   :={}
Local cFileCli   :="HA1" + cEmpAnt + "0" 
Local cFilePedC  :="HC5" + cEmpAnt + "0" 
Local cFileCont  :="HU5" + cEmpAnt + "0" 
//Local cFileAtend :="HAT" + cEmpAnt + "0" 
Local cFileNpos  :="HD5" + cEmpAnt + "0" 
Local cFileInv	 :="HIN" + cEmpAnt + "0" 

// Preenche o array com os campos do cliente a serem enviados
aadd(aMata030,{"A1_COD"					, "C", 06, 0}) // Codigo do Cliente
aadd(aMata030,{"A1_LOJA"				, "C", 02, 0}) // Loja do Cliente
aadd(aMata030,{"A1_CGC"					, "C", 14, 0}) // CGC/CPF do cliente
aadd(aMata030,{"A1_NOME"				, "C", 40, 0}) // Nome do cliente
aadd(aMata030,{"A1_NREDUZ"				, "C", 20, 0}) // Nome Reduzido do cliente
aadd(aMata030,{"A1_TIPO"				, "C", 01, 0}) // Tipo do cliente
aadd(aMata030,{"A1_END"			   		, "C", 40, 0}) // Endereco do cliente
aadd(aMata030,{"A1_MUN"					, "C", 15, 0}) // Municipio do cliente
aadd(aMata030,{"A1_EST"					, "C", 02, 0}) // Estado do cliente
aadd(aMata030,{"A1_BAIRRO"				, "C", 30, 0}) // Bairro do cliente
aadd(aMata030,{"A1_CEP"					, "C", 08, 0}) // Cod Enderecamento Postal
aadd(aMata030,{"A1_TEL"					, "C", 15, 0}) // Telefone do cliente
aadd(aMata030,{"A1_EMAIL"				, "C", 30, 0}) // Telefone do cliente
aadd(aMata030,{"A1_VEND"				, "C", 06, 0}) // Codigo do Vendedor
aadd(aMata030,{"A1_RISCO"				, "C", 01, 0}) // Grau de Risco do cliente
aadd(aMata030,{"A1_INSCR" 				, "C", 18, 0}) // Inscricao estadual
aadd(aMata030,{"A1_ULTVIS"				, "D", 08, 0}) // Data da ultima Visita
//aadd(aMata030,{"A1_STATUS"			    , "C", 01, 0}) // Status (N=Novo, A=Alterado)

aAdd(aArquivos, {cFileCli , "HA1", "A1_COD"})
//aAdd(aArquivos, {cFilePedC, "HC5", "C5_CLI"})
aAdd(aArquivos, {cFilePedC, "HC5", "C5_NUM"})
aAdd(aArquivos, {cFileCont, "HU5", "U5_CODCON"})
//aAdd(aArquivos, {cFileAtend,"HAT", "AT_DATA+AT_FLGVIS+AT_NUMPED"})
aAdd(aArquivos, {cFileNpos, "HD5", "AD5_CODCLI+AD5_LOJA+AD5_DTHR"})
aAdd(aArquivos, {cFileInv,  "HIN", "IN_GRUPO+IN_PROD+IN_CLI+IN_LOJA"})

ConOut("PALMJOB: Importando Cliente para " + Trim(PALMUSER->P_USER))
If PChkFile(cPathPalm, aArquivos)
	dbSelectArea("HA1")
	dbSetOrder(1)
	cFiltro := "A1_STATUS = 'N' .Or. A1_STATUS = 'A'"
	Set Filter to &cFiltro
	dbGoTop()
    While !Eof()
	   	If HA1->A1_STATUS = "N"

			// Guardo o codigo e loja do palm
			cCliPalm:=HA1->A1_COD
			cLojPalm:=HA1->A1_LOJA
			           
	    	cCodCli := GetSxeNum("SA1","A1_COD")
	    	cCodLoj := HA1->A1_LOJA  // Loja que foi incluida no Palm
	    	dbSelectArea("SA1")
	    	dbSetOrder(1)
	    	While dbSeek(xFilial("SA1")+cCodCli+cCodLoj )
				ConfirmSX8()
	  			cCodCli := GetSxeNum("SA1","A1_COD")
	  			dbSkip()
	  		EndDo
			dbSelectArea("HA1")
			dbSetOrder(1)	  			
    	ElseIf HA1->A1_STATUS = "A"
    		cCodCli := HA1->A1_COD
    		cCodLoj := HA1->A1_LOJA  // Loja que foi incluida no Palm
    	EndIf		
		For i := 1 To Len(aMata030)
			If aMata030[i,1] = "A1_COD"
				aadd(aCliente,{aMata030[i,1], cCodCli, Nil})
			ElseIf aMata030[i,1] = "A1_VEND"
				aadd(aCliente,{aMata030[i,1], cVend, Nil})
			ElseIf aMata030[i,1] = "A1_LOJA"
				aadd(aCliente,{aMata030[i,1], cCodLoj, Nil})
			ElseIf aMata030[i,1] = "A1_TIPO"
				aadd(aCliente,{aMata030[i,1], If(!Empty(&("HA1->"+aMata030[i,1])),&("HA1->"+aMata030[i,1]),"R"), Nil})
			Else
				aadd(aCliente,{aMata030[i,1], &("HA1->"+aMata030[i,1]) ,Nil})
			EndIf
		Next
		lMsHelpAuto := .T.
		If HA1->A1_STATUS = "N"   // Inclui novo Cliente
			lMsErroAuto := .F.
			Mata030(aCliente)
		ElseIf HA1->A1_STATUS = "A"
	    	lMsErroAuto := .F.
	    	Mata030(aCliente,4)   // Altera Cliente
		EndIf
		If !lMsErroAuto .And. HA1->A1_STATUS $ "AN"
		    ConOut("PALMJOB: Cliente " + cCodCli + " cadastrado com sucesso.")
		    ConfirmSX8()
		   	dbSelectArea("HA1")	
		    RecLock("HA1",.F.)
		   	HA1->A1_STATUS := "P"
		    MsUnlock()        
            
			//Funcoes que acertam o novo cod. do cliente nas outras tabelas
		    AcertaPed(cCliPalm, cCodCLi, cCodLoj)
			AcertaCon(cCliPalm, cCodCli, cCodLoj)
			AcertaNPos(cCliPalm, cCodCli, cCodLoj)
			AcertaInv(cCliPalm, cCodCli, cCodLoj)
			
			// Atualiza do Proximo Cliente no cadastro de Vendedores
		    dbSelectArea("SA3")
    		If dbSeek( xFilial("SA3") + cVend , .F. )
				RecLock("SA3",.F.)                   
  				SA3->A3_PROXCLI := StrZero( Val(SA3->A3_PROXCLI)+1,6 )
    		 	MsUnlock()
	    	EndIf

		Else
			// Cliente nao Incluido
			ConOut("PALMJOB: Cliente nao Incluido")
			If HA1->A1_STATUS = "N"
				RollBackSX8()
			EndIf
			MostraErro(cPathPalm)
		EndIf						
		aCliente := {}
		dbSelectArea("HA1")
		dbSkip()
	EndDo
	HA1->(dbCloseArea())
	HU5->(dbCloseArea())
	HC5->(dbCloseArea())
	HD5->(dbCloseArea())
	HIN->(dbCloseArea())
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AcertaPed| Autor ³ Fabio Garbin          ³ Data ³ 27.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acerta o Codigo do Pedido na tabela HC5XXX do ATUAL qdo    ³±±
±±³          ³ Cliente for Novo                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AcertaPed                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PImpCli                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function AcertaPed(cCodPalm, cCodCli, cCodLoja)
// So para quem usa numeracao do Proheus
// Lembra que guardei o codigo la do cliente no vetor ?
// Pois eh agora vou pesquisar no vetor se ele este codigo do pedido estiver lah
// significa que o cliente deste pedido tb eh novo.
 // Qdo o Pedido e de um Cliente Novo Altera o Cliente no Diretorio Atual

Local cChave := cCodPalm
Local cFiltro:= ""

dbSelectArea("HC5")
dbSetOrder(1)
cFiltro := "HC5->C5_STATUS = 'N'"
Set Filter to &cFiltro

While !HC5->( Eof() )
    If HC5->C5_CLI == cChave                                         
	    //ConOut("Pedido: " + HC5->C5_COTAC + " Cliente: " + HC5->C5_CLI) 
		RecLock("HC5",.F.)
		HC5->C5_CLI := cCodCli
		HC5->C5_LOJA:= cCodLoja
		HC5->(MsUnlock())
	Endif
	
	dbSelectArea("HC5")
	HC5->(dbSkip())
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AcertaCon| Autor ³ Fabio Garbin          ³ Data ³ 14.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acerta o Codigo do Cliente na tabela Contato do ATUAL qdo  ³±±
±±³          ³ Cliente for Novo                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AcertaCon                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PImpCli                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function AcertaCon(cCodPalm, cCodCli, cCodLoja)
// So para quem usa numeracao do Proheus
// Qdo o Contato e de um Cliente Novo Altera o Cliente/Loja no Diretorio Atual

Local cChave := cCodPalm
Local cFiltro:= ""

dbSelectArea("HU5")
dbSetOrder(1)
cFiltro := "HU5->U5_STATUS = 'N'"
Set Filter to &cFiltro

While !HU5->(Eof())
	If HU5->U5_CLIENTE == cChave
		RecLock("HU5", .F.)
		HU5->U5_CLIENTE := cCodCli
		HU5->U5_LOJA    := cCodLoja
		HU5->(MsUnlock())
	Endif
	dbSelectArea("HU5")
	HU5->(dbSkip())
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AcertaNPos| Autor ³ Cleber Martinez       ³ Data ³ 20.02.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acerta o Codigo do Cliente na tabela Atend. do ATUAL qdo   ³±±
±±³          ³ Cliente for Novo                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AcertaNPos                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PImpCli                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function AcertaNPos(cCodPalm, cCodCli, cCodLoja)
// So para quem usa numeracao do Proheus
// Qdo a ocorrencia e de um Cliente Novo Altera o Cliente/Loja no Diretorio Atual

Local cChave := cCodPalm

dbSelectArea("HD5")
dbSetOrder(1)
dbGoTop()

While !HD5->(Eof())
	If HD5->AD5_CODCLI == cChave
		RecLock("HD5", .F.)
		HD5->AD5_CODCLI	:= cCodCli
		HD5->AD5_LOJA  	:= cCodLoja
		HD5->(MsUnlock())
	Endif
	dbSelectArea("HD5")
	HD5->(dbSkip())
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AcertaInv | Autor ³ Cleber Martinez       ³ Data ³ 20.02.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acerta o Codigo do Cliente na tabela Invent. do ATUAL qdo  ³±±
±±³          ³ Cliente for Novo                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AcertaInv                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PImpCli                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function AcertaInv(cCodPalm, cCodCli, cCodLoja)
// So para quem usa numeracao do Proheus
// Qdo o Inventario e de um Cliente Novo altera o Cliente/Loja no Diretorio Atual
Local cChave := cCodPalm

dbSelectArea("HIN")
dbSetOrder(1)
dbGotop()

While !HIN->(Eof())
	If HIN->IN_CLI == cChave
		RecLock("HIN", .F.)
		HIN->IN_CLI  := cCodCli
		HIN->IN_LOJA := cCodLoja
		HIN->(MsUnlock())
	Endif
	dbSelectArea("HIN")
	HIN->(dbSkip())
EndDo

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PImpCon  ³ Autor ³ Fabio Garbin          ³ Data ³ 15.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao dos Contatos do Palm Pilot                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PImpCon                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function PImpCon()

Local aContato   := {} // Contem os dados do arquivo de CONTATOS
Local aArquivos  := {}
Local i          := 0
Local cPathPalm  := GetSrvProfString("HandHeldDir","\HANDHELD\") + "P" + AllTrim(PALMUSER->P_DIR) + "\atual\"
Local cPath      := ""
Local cCodCon    := ""
Local cFiltro    := ""
Local cVend      := PALMUSER->P_CODVEND
Local cFileCont  :="HU5" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI  

aAdd(aArquivos, {cFileCont, "HU5", "U5_CODCON"})

ConOut("PALMJOB: Importando Contatos para " + Trim(PALMUSER->P_USER))
If PChkFile(cPathPalm, aArquivos)
	dbSelectArea("HU5")
	dbSetOrder(1)
	cFiltro := "U5_STATUS = 'N' .Or. U5_STATUS = 'A'"
	Set Filter to &cFiltro
    While !Eof()
    	If HU5->U5_STATUS = "N"
			cCodCon := GetSxeNum("SU5","U5_CODCONT")
	    	dbSelectArea("SU5")
	    	dbSetOrder(1)
	    	While dbSeek(xFilial("SU5") + cCodCon )
				ConfirmSX8()
	  			cCodCon := GetSxeNum("SU5","U5_CODCONT")
	  			dbSkip()
	  		EndDo
			dbSelectArea("HU5")
			dbSetOrder(1)	  	
		ElseIf HU5->U5_STATUS = "A"
			cCodCon := HU5->U5_CODCON
		EndIf	
		dbSelectArea("SU5")
		dbSetOrder(1)
		If HU5->U5_STATUS = "N"
			RecLock("SU5",.T.)
		ElseIf HU5->U5_STATUS = "A"
			dbSeek(xFilial("SU5")+cCodCon)
			RecLock("SU5",.F.)	
		EndIf
		If SA1->(dbSeek( xFilial("SU5")+HU5->U5_CLIENTE+HU5->U5_LOJA ))
			If !Empty(cCodCon)
				//SU5->U5_FILIAL  := xFilial("SU5")
				SU5->U5_CODCONT := cCodCon
				SU5->U5_CLIENTE := HU5->U5_CLIENTE
			   	SU5->U5_LOJA    := HU5->U5_LOJA
				SU5->U5_CONTAT  := HU5->U5_CONTAT
				SU5->U5_FONE    := HU5->U5_FONE
				SU5->U5_CPF     := HU5->U5_CPF			
				SU5->U5_FUNCAO  := HU5->U5_FUNCAO
				SU5->U5_CELULAR := HU5->U5_CELULAR
				SU5->U5_NIVER   := HU5->U5_DTNASC
				SU5->U5_NIVEL   := "01"
				SU5->U5_ATIVO   := "1"
			    SU5->(MsUnlock())
			    ConfirmSX8()
			EndIf
		    If dbSeek(xFilial("SU5")+cCodCon) .And. HU5->U5_STATUS $ "AN"
		    	dbSelectArea("AC8")
		    	dbSetOrder(1)
		    	If dbSeek(xFilial("AC8")+cCodCon+"SA1"+xFilial("SA1")+HU5->U5_CLIENTE)
					RecLock("AC8", .F.)
				Else
					RecLock("AC8", .T.)
				EndIf
		        AC8->AC8_FILIAL := xFilial("AC8") 
				AC8->AC8_FILENT := xFilial("SA1")
				AC8->AC8_ENTIDA := "SA1"
				AC8->AC8_CODENT := HU5->U5_CLIENTE + HU5->U5_LOJA 
				AC8->AC8_CODCON := cCodCon
				AC8->(MsUnlock())
		        ConOut("PALMJOB: Contato " + cCodCon + " cadastrado com sucesso.")	    	
		    //Else
		    	//ConOut("PALMJOB: Contato nao cadastrado.")
		    EndIf
		  	dbSelectArea("HU5")	
		  	RecLock("HU5",.F.)
		  	HU5->U5_STATUS := "P"
		  	MsUnlock()
	   Else
			ConOut("PALMJOB: Cliente deste contato nao cadastrado !")
	   EndIf
		dbSelectArea("HU5")
		dbSkip()
	EndDo
	HU5->(dbCloseArea())
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PImpMsg  ³ Autor ³ Marcelo Vieira        ³ Data ³ 10.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao das mensagens do Palm Pilot                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PImpMsg                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PImpMsg()                                   
Local aMensagem  := {} // Contem os dados do arquivo de Mensagens
Local aArquivos  := {}
Local i          := 0
Local cPathPalm  := GetSrvProfString("HandHeldDir","\HANDHELD\") + "P" + AllTrim(PALMUSER->P_DIR) + "\atual\"
Local cPath      := ""
Local cCodMsg    := ""
Local cFiltro    := ""
Local cVend      := PALMUSER->P_CODVEND
Local cAliasMsg  := "" 
Local cPrefixCpo := ""
Local cFileMsg   := "HMV" + cEmpAnt + "0" 

cAliasMsg  := AllTrim(GetMv("MV_TBLMSG",,""))
cPrefixCpo := Subs(cAliasMsg,2,2)+"_"

aAdd(aArquivos, { cFileMsg, "HMV", "HMV_COD"})
	
ConOut("PALMJOB: Importando Mensagens para " + Trim(PALMUSER->P_USER))
If PChkFile(cPathPalm, aArquivos)
	If Empty(cAliasMsg)
	   ConOut("PALMJOB: Tabela de mensagens nao definida ( verifique o parametro MV_TBLMSG )" )
	   Return  
	Endif
	
	dbSelectArea("HMV")
	dbSetOrder(1)
	cFiltro := "HMV_STATUS = 'N' .Or. HMV_STATUS = 'A' "
	Set Filter to &cFiltro
	dbGoTop()
    While !HMV->(Eof())  	
    	If HMV->HMV_STATUS = "N"
			cCodMsg := GetSxeNum(cAliasMsg,cPrefixCpo+"CODMSG")
	    	dbSelectArea(cAliasMsg)
	    	dbSetOrder(1)
	    	While (cAliasMsg)->( dbSeek(xFilial(cAliasMsg) + cCodMsg))
				ConfirmSX8()
	  			cCodMsg := GetSxeNum(cAliasMsg,cPrefixCpo+"CODMSG")
	  			dbSkip()
	  		EndDo	  		
	  	ElseIf 	HMV->HMV_STATUS = "A"
       	  	 cCodMsg := MSG->HMV_CODMSG
	  	Else	  	
			dbSelectArea("HMV")
			dbSetOrder(1)	  	
			dbSkip()
			Loop	
		EndIf	

		dbSelectArea(cAliasMsg)
		dbSetOrder(1)
		
		If HMV->HMV_STATUS = "N"
			(cAliasMsg)->( RecLock(cAliasMsg,.T.) )
		Else
			If dbSeek(xFilial(cAliasMsg)+cCodMsg + 	(cAliasMsg)->&(cPrefixCpo+"ORIMSG")  + cVend )
				(cAliasMsg)->( RecLock(cAliasMsg,.F.) )	
			EndIf
		EndIf

		(cAliasMsg)->&(cPrefixCpo+"FILIAL")  := xFilial(cAliasMsg)
		(cAliasMsg)->&(cPrefixCpo+"CODMSG")  := cCodMsg
		(cAliasMsg)->&(cPrefixCpo+"CODVEND") := cVend
		(cAliasMsg)->&(cPrefixCpo+"DATAMSG") := HMV->HMV_DATA
		(cAliasMsg)->&(cPrefixCpo+"DATAVIG") := HMV->HMV_DTVIG
		(cAliasMsg)->&(cPrefixCpo+"ORIMSG")  := HMV->HMV_ORI
		(cAliasMsg)->&(cPrefixCpo+"MENSAGE") := HMV->HMV_MSG
	    (cAliasMsg)->(MsUnlock())

	    If (cAliasMsg)->( dbSeek(xFilial(cAliasMsg)+ cCodMsg ) .And. HMV->HMV_STATUS $ "N" )
	        ConfirmSX8()
	        ConOut("PALMJOB: Mensagem " + cCodMsg + " cadastrada com sucesso.")
	    Else
	    	ConOut("PALMJOB: Mensagem nao cadastrada.")
	    EndIf
	   	dbSelectArea("HMV")	
	    RecLock("HMV",.F.)
	   	HMV->HMV_STATUS := "P"
	    MsUnlock()
		
		dbSelectArea("HMV")
		dbSkip()
	EndDo
	Set Filter to 
	HMV->(dbCloseArea())
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PImpInv  ³ Autor ³ Cleber Martinez       ³ Data ³ 16.02.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Importacao do Inventario apontado no SFACRM                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PImpInv                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³  /  /  ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function PImpInv()

Local aArquivos  := {}
Local cPathPalm  := GetSrvProfString("HandHeldDir","\HANDHELD\") + "P" + AllTrim(PALMUSER->P_DIR) + "\atual\"
Local cAliasInv  := "" 
Local cPrefixCpo := ""
Local cFileInv   := "HIN" + cEmpAnt + "0" 
Local nReg := 0

cAliasInv  := GetMv("MV_TBLINV",,"") //Alias da tabela de Inventario no Protheus
cPrefixCpo := Subs(cAliasInv,2,2)+"_"

aAdd(aArquivos, {cFileInv, "HIN", "IN_GRUPO+IN_PROD+IN_CLI+IN_LOJA"})
	
ConOut("PALMJOB: Importando Inventario para " + Trim(PALMUSER->P_USER))
If PChkFile(cPathPalm, aArquivos)
	If Empty(cAliasInv)
	   ConOut("PALMJOB: Tabela de inventario nao definida (verifique o parametro MV_TBLINV)" )
	   Return  
	Endif
	
	dbSelectArea("HIN")
	dbSetOrder(1)
	While !HIN->( Eof() )
		
		dbSelectArea(cAliasInv)
		dbSetOrder(1)
		 	
		If dbSeek(xFilial(cAliasInv) + HIN->IN_GRUPO+HIN->IN_PROD+HIN->IN_CLI+HIN->IN_LOJA)
			(cAliasInv)->( RecLock(cAliasInv,.F.) )	
		Else
			(cAliasInv)->( RecLock(cAliasInv,.T.) )
		EndIf

		(cAliasInv)->&(cPrefixCpo+"FILIAL")  := xFilial(cAliasInv)
		(cAliasInv)->&(cPrefixCpo+"CLI")     := HIN->IN_CLI
		(cAliasInv)->&(cPrefixCpo+"LOJA")    := HIN->IN_LOJA
		(cAliasInv)->&(cPrefixCpo+"GRUPO")   := HIN->IN_GRUPO
		(cAliasInv)->&(cPrefixCpo+"PROD")    := HIN->IN_PROD
		(cAliasInv)->&(cPrefixCpo+"DATA")    := HIN->IN_DATA
		(cAliasInv)->&(cPrefixCpo+"QTD")     := HIN->IN_QTD
		(cAliasInv)->&(cPrefixCpo+"PRECO")	  := HIN->IN_PRECO
	    (cAliasInv)->(MsUnlock())
        
         nReg++
	   	dbSelectArea("HIN")
	    RecLock("HIN",.F.)
        dbDelete() //Apaga o registro ja importado do diret. atual
	    MsUnlock()
		
		dbSelectArea("HIN")
		dbSkip()		
	Enddo
	If nReg > 0
		ConOut("PALMJOB: Inventario importado com sucesso.")
	Endif
	HIN->(dbCloseArea())
EndIf
	
Return 
