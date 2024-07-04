#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} GravaSC7A
Fun��o utilizada para gera��o de pedidos de compra pelo SIGAEIC
@author leonardo.magalhaes
@since 09/10/2019
@return Nil
@type function
nOpcao          EXECAUTO
1 - INCLUSAO    3  
2 - ALTERA��O   4
3 - EXCLUSAO    5
/*/
Function GravaSC7A(nOpcao,cCodProd,nQuant,nPreco,cNumPed,cLocal,cCusto,cFornece,cLoja,dEmissao,cNumSc,dDataPr,cItem,cSequen,cObserv,cOrigem,cItemSc,nQtSegum,cSegum,nMoeda,cFluxo,nTaxa,cNumPo,cAprov, cConapro, nDespesa , nDesconto,AitensEIC,aCabEic)

LOCAL aArea	    := GetArea()
LOCAL aAreaSCX  := SCX->(GetArea())
LOCAL aAreaSCH  := SCH->(GetArea())
LOCAL aEntCtb 	:= CtbEntArr()
LOCAL nQtdOri   := 0
LOCAL nDifSC1   := 0
LOCAL nQuantSC  := 0
LOCAL nDecCus1  := GetSX3Cache("CH_CUSTO1", "X3_DECIMAL")
LOCAL nDecCus2  := GetSX3Cache("CH_CUSTO2", "X3_DECIMAL")
LOCAL nDecCus3  := GetSX3Cache("CH_CUSTO3", "X3_DECIMAL")
LOCAL nDecCus4  := GetSX3Cache("CH_CUSTO4", "X3_DECIMAL")
LOCAL nDecCus5  := GetSX3Cache("CH_CUSTO5", "X3_DECIMAL")
Local LGCusto  	:= SuperGetMv("MV_GCUSTO",.F.,.T.)

Local aCpsSC7   := {}
LOCAL nX		:= 0
LOCAL ny		:= 0
Local nz		:= 0
LOCAL lAtuSB2   :=.F.
LOCAL cGrComPad	:= ""
LOCAL cCpoSCX 	:= ""
LOCAL cCpoSCH 	:= ""
Local cInicPad

/*
����������������������������������������������������������������������Ŀ
�LISTA DE PARAMETROS A SER UTILIZADA PARA A INTEGRACAO COM O MODULO    �
�DE IMPORTACAO                                                         �
����������������������������������������������������������������������Ĵ
�	OPCAO       : (1) = Inclusao, (2) = Alteracao, (3) = Exclusao      �
� 	CODIGO      : Codigo do Produto  - Obrigatorio                     �
�  QUANTIDADE  : Quantidade Principal - Obrigatorio                    �
�  PRECO       : Preco Unitario do Item - Obrigatorio                  �
�  NUMERO      : Numero do Pedido - Obrigatorio >>> Este e' o proprio  �
�                Numero do Purchase Order                              �
�  LOCAL       : Local de Entrada >>> Opcional - Caso nao passado, ser��
�                assumido o local padr�o do Produto                    �
�  CENTRO CUSTO: Centro de Custo >>> Opcional - Caso nao passado, ser� �
�                assumido o Centro de Custo do Produto                 �
�  FORNECEDOR  : Codigo do Fornecedor >>> Obrigatorio                  �
�  LOJA        : Loja do Fornecedor >>> Obrigatorio -  O SIGAEIC n�o se�
�                utiliza de loja. Neste caso, ser� assumido '01'       �
�  EMISSAO     : Data de Emiss�o do Pedido >>> Opcional - Se nao for   �
�                passdo ser� assumido a pr�pria DATA BASE              �
�  NUMERO SC   : Numero da Solicita��o de Compra >>> Opcional - Se nao �
�                passada ser� assumido brancos                         �
�  DATA PREVIST: Data Prevista para entrega >>> Opcional - Se nao      �
�                passada ser� assumida a data base                     �
�  ITEM        : Numero do Item do Pedido >>> Opcional - SIGACOM       �
�  SEQUENCIA   : Numero do Sequencia  >>> Opcional - SIGAEIC           �
�  OBSERV      : Observacao do item >>> Opcional                       �
�  ORIGEM      : Rotina Geradora do Pedido >>> Obrigatoria             �
�  ITEM SC     : Item da Solicitacao de Compra >>> Opcional            �
�  QUANT SEG UN: Quant na segunda unidade de medida                    �
�  SEGUNDA UNID: Segunda Unidade Medida                                �
�  MOEDA       : Moeda do Pedido                                       �
�  FLUXO CAIXA : Indicador de fluxo de caixa ou nao                    �
�  TAXA MOEDA  : Taxa da Moeda                                         �
�  NUMERO DO PO: Numero do PO (Purchase Order)                         �
�  APROVADOR   : Aprovador do Pedido                                   �
�  CONT. APROV.: Controle de Aprovacao                                 �
������������������������������������������������������������������������


*/
//����������������������������������������Ŀ
//� ATENCAO:                               �
//� O campo item � usado pelo SIGA com 2   �
//� posi��es o que para o SIGAEIC n�o faz  �
//� sentido. Desta forma, ser� considerado �
//� o campo C7_SEQUEN (Sequencia do Pedido)�
//������������������������������������������

dEmissao := If(dEmissao==NIl,dDataBase,dEmissao)
nOpcao   := If(nOpcao==Nil,1,nOpcao)
cItem    := If(cItem==Nil,StrZero(1,Len(SC7->C7_ITEM)),cItem)
dDatapr  := If(dDataPr==NIl,dDataBase,dDataPr)
cObserv  := If(cObserv==Nil,"PEDIDO DE IMPORTACAO",cObserv)
cItemSc  := If(cItemSc==Nil,StrZero(1,Len(SC1->C1_ITEM)),cItemSc)
cSequen  := If(cSequen==Nil,"0001",cSequen)
nQtSegum := If(nQtSegum==Nil,0,nQtSegum)
cSegum	 := If(cSegum==Nil,"  ",cSegum)
nMoeda   := If(nMoeda==Nil,1,nMoeda)

//��������������������������������������������������������������Ŀ
//� Verifica o grupo de aprovacao do Comprador.                  �
//����������������������������������������������������������������
dbSelectArea("SY1")
dbSetOrder(3)
If MsSeek(xFilial()+RetCodUsr())
	cGrComPad	:= If(!Empty(Y1_GRUPCOM),SY1->Y1_GRUPCOM,Space(Len(SC7->C7_GRUPCOM)))
EndIf

//Verifica a existencia da SC para atualizacao do SB2
dbSElectArea("SC1")
dbSetOrder(1)
If !dbSeek(xFilial()+cNumSC)
	lAtuSB2:= .T.
EndIf

// Posiciona no fornecedor
dbSelectArea("SA2")
dbSetOrder(1)
dbSeek(xFilial()+cFornece+cLoja)

// Posiciona no produto
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial()+cCodProd)

cLocal := Iif(cLocal==Nil,RetFldProd(SB1->B1_COD,"B1_LOCPAD"),cLocal)

// Verifica se o pedido/item ja'existe
If nOpcao == 1
	dbSelectArea("SC7")
	dbSetOrder(1)
	If	(dbSeek(xFilial()+cNumPed+cItem+cSequen)) .OR.;
		(dbSeek(xFilial()+cNumPed+'01  '+cSequen))// Alex Wallauer (AWR)/Average - 17/02/2003 - Seek p/ os pedidos antigos (versao anterior)
		Help(" ",1,"SC7FOUND")
		RestArea(aArea)
		Return (.F.)
	EndIf
EndIf

// Posiciona nos saldos de estoque
If lAtuSB2
	dbSelectArea("SB2")
	dbSetOrder(1)
	If !(dbSeek(xFilial()+cCodProd+cLocal))
		CriaSB2(cCodProd,cLocal)
	EndIf
EndIf

If nOpcao == 2 .Or. nOpcao == 3
	dbSelectArea("SC7")
	If	(dbSeek(xFilial()+cNumPed+cItem+cSequen)) .OR.;
		(dbSeek(xFilial()+cNumPed+'01  '+cSequen))// Alex Wallauer (AWR)/Average - 17/02/2003 - Seek p/ os pedidos antigos (versao anterior)
		If (nOpcao == 3)
			Reclock("SC7")
			cItemSc:= SC7->C7_ItemSC
			dbDelete()
			If lAtuSB2
				Reclock("SB2",.F.)
				SB2->B2_SALPEDI -= (SC7->C7_QUANT - SC7->C7_QUJE)
			EndIf
			dbSelectArea("SC1")
			dbSetOrder(2)
			If dbSeek(xFilial()+cCodProd+cNumSc+cItemSc)
				RecLock("SC1",.F.)
				SC1->C1_QUJE := SC1->C1_QUJE - ( SC7->C7_QUANT - SC7->C7_QUJE )
				MsUnlock()
			EndIf
			DbSelectArea("SCH")
			SCH->(DbSetOrder(1)) //-- CH_FILIAL + CH_PEDIDO + CH_FORNECE + CH_LOJA + CH_ITEMPD + CH_ITEM
			If SCH->(DbSeek(xFilial("SCH") + cNumPed + cFornece + cLoja + cItem))
				While SCH->(!Eof()) .And. ((SCH->CH_PEDIDO + SCH->CH_FORNECE + SCH->CH_LOJA + SCH->CH_ITEMPD) == (cNumPed + cFornece + cLoja + cItem))
					RecLock("SCH")
						SCH->(DbDelete())
					SCH->(MsUnLock())
					SCH->(DbSkip())
				EndDo
			EndIf
		Else
			nQtdOri := (SC7->C7_QUANT - SC7->C7_QUJE)
			If lAtuSB2
				Reclock("SB2",.F.)
				SB2->B2_SALPEDI := B2_SALPEDI - nQtdOri + nQuant
			EndIf
		Endif
		//Elizabete-Average-01/2003
		//Ao alterar ou deletar um item da PO que foi originada por uma autorizacao de
		//entrega no SIGACOM, deve-se atualizar o saldo no SC3 do contrato de parceria
		If SC7->C7_TIPO == 2 .AND. !EMPTY(SC7->C7_NUMSC)
			If SC3->(dbSeek(xFilial("SC3")+SC7->C7_NUMSC + SC7->C7_ITEM))
				SC3->(RecLock("SC3",.F.))
				If nOpcao == 2  // alteracao
					SC3->C3_QUJE := (SC3->C3_QUJE - SC7->C7_QUANT) + nQuant
				Else
					SC3->C3_QUJE := SC3->C3_QUJE + SC7->C7_QUANT
				EndIf
				SC3->C3_ENCER := IIf(SC3->C3_QUANT - SC3->C3_QUJE > 0," ","E")
				MsUnlock()
			EndIf
		EndIf

	Else
		Help(" ",1,"SC7NOFOUND")
		RestArea(aArea)
		Return (.F.)
	Endif
Endif

If nOpcao == 1
	RecLock("SC7",.T.)
Else
	RecLock("SC7")
Endif

// Atualiza Registro do Pedido de Compras
If (nOpcao == 1 .or. nOpcao == 2)
	nDifSC1	:= SC7->C7_QUANT - nQuant

	// atualiza campos do inicializador padrao
	aCpsSC7 := FWSX3Util():GetAllFields( "SC7" , .F. ) 
	For nZ := 1 to len(aCpsSC7)
		If AllTrim(Upper(aCpsSC7[nZ])) <> "C7_NUM" .And. Empty(&(aCpsSC7[nZ])) 
			cInicPad  :=  &(ALLTRIM(GetSX3Cache(aCpsSC7[nZ],"X3_RELACAO")))
			If !Empty(cInicPad)
				Replace &(AllTrim(aCpsSC7[nZ] )) With cInicPad
			Endif
		Endif 
	Next	
	
	For nY:= 1 to len(AitensEIC)
		
		If nOpcao = 2 .And. AitensEIC[nY][1] $ "C7_ORIGEM|C7_NUMSC" 
			loop
		Elseif 	FieldPos(AllTrim(AitensEIC[nY][1])) > 0 .and. !(!LGCusto .and. ALLTRIM(AitensEIC[nY][1]) = "C7_CC")
			Replace &(AllTrim(AitensEIC[nY][1] )) With AitensEIC[nY][2]
		Endif
	Next
	
	For nY := 1 to len(aCabEic)	

		If 	FieldPos(AllTrim(aCabEic[nY][1])) > 0 .And. !(aCabEic[nY][1] $ "C7_DESPESA|C7_FRETE|C7_SEGURO" )
			Replace &(AllTrim(aCabEic[nY][1] )) With aCabEic[nY][2]
		Endif
		
	Next
	If alltrim(C7_CONTATO) == ""
		Replace C7_CONTATO With SA2->A2_CONTATO
	Endif

	If Empty(SC7->C7_FISCORI)
		If !Empty(SC7->C7_NUMSC) .AND. FWModeAccess("SC1") == "E"
			Replace C7_FISCORI With xFilial("SC1")
		Else
			Replace C7_FISCORI With SC7->C7_FILIAL
		Endif
	Endif
	
	If alltrim(C7_DESCRI) == ""
		Replace C7_DESCRI With SB1->B1_DESC
	Endif	
	
	If alltrim(C7_UM) ==  ""
		Replace C7_UM With SB1->B1_UM
	Endif	
	
	If	alltrim(C7_SEGUM) == ""
		Replace C7_SEGUM With SB1->B1_SEGUM
	Endif
	If C7_QUANT > 0 .and. C7_QTSEGUM = 0
		Replace C7_QTSEGUM     With ConvUm(SC7->C7_PRODUTO,C7_QUANT,C7_QTSEGUM,2)
	Endif
	If C7_QTSEGUM > 0 .and. C7_QUANT = 0
		Replace C7_QUANT     With ConvUm(SC7->C7_PRODUTO,C7_QUANT,C7_QTSEGUM,1)
	Endif
	If	C7_TOTAL == 0
		Replace C7_TOTAL       With C7_PRECO*C7_QUANT
	Endif
	If nOpcao == 1 
		Replace C7_TIPO    With 1
	Endif

	//���������������������������������������������������������������������Ŀ
	//�Na inclusao gravar o DEFAULT para ocampo C7_FILENT que eh obrigatorio�
	//�����������������������������������������������������������������������
	If nOpcao == 1 .AND. EMPTY(SC7->C7_FILENT)
		Replace C7_FILENT	With	CriaVar('C7_FILENT',.T.)
	Endif
	dbSelectArea("SC1")
	dbSetOrder(1)
	If dbSeek(xFilial("SC1")+cNumSc+cItemSc)

		//���������������������������������������������������������������������Ŀ
		//�Na inclusao gravar o DEFAULT para ocampo C7_FILENT que eh obrigatorio�
		//�����������������������������������������������������������������������
		
		SC7->C7_CLVL    := SC1->C1_CLVL
		SC7->C7_CONTA   := SC1->C1_CONTA
		SC7->C7_ITEMCTA := SC1->C1_ITEMCTA

		If nOpcao == 1
			nQuantSC := SC7->C7_QUANT
		Else
			nQuantSC :=  nDIFSC1
		EndIf

		// atualiza dados da SC
		If !Empty(cNumSc) //-- Se possui SC, atualiza relacionamento com SCs
			SC1->(dbSetOrder(2))
			SC1->(dbSeek(xFilial("SC1")+cCodProd+cNumSc+cItemSc))
			While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_PRODUTO+C1_NUM+C1_ITEM) == xFilial("SC1")+cCodProd+cNumSc+cItemSc
				//-- Atualiza acumulado das SCs atendidas pelo pedido da medicao
				MaAvalSC("SC1",6,,"SC7")
				SC1->(dbSkip())
			EndDo		
		EndIf

		If nOpcao == 1
			DbSelectArea("SCX")
			SCX->(DbSetOrder(1)) //-- CX_FILIAL + CX_SOLICIT + CX_ITEMSOL + CX_ITEM
			If SCX->(DbSeek(xFilial("SCX") + cNumSc + cItemSc))
				While SCX->(!Eof()) .And. ((SCX->CX_SOLICIT + SCX->CX_ITEMSOL) == (cNumSc + cItemSc))
					RecLock("SCH", .T.)
						SCH->CH_FILIAL 	:= xFilial("SCH")
						SCH->CH_PEDIDO 	:= cNumPed
						SCH->CH_FORNECE := cFornece
						SCH->CH_LOJA 	:= cLoja
						SCH->CH_ITEMPD 	:= cItem
						SCH->CH_ITEM 	:= SCX->CX_ITEM
						SCH->CH_PERC 	:= SCX->CX_PERC
						SCH->CH_CC 		:= SCX->CX_CC
						SCH->CH_CONTA 	:= SCX->CX_CONTA 
						SCH->CH_ITEMCTA := SCX->CX_ITEMCTA
						SCH->CH_CUSTO1 	:= Round((SC7->C7_TOTAL * (SCX->CX_PERC / 100)), nDecCus1)
						If nMoeda == 2
							SCH->CH_CUSTO2 := Round((SC7->C7_TOTAL * (SCX->CX_PERC / 100)), nDecCus2)
						ElseIf nMoeda == 3 
							SCH->CH_CUSTO3 := Round((SC7->C7_TOTAL * (SCX->CX_PERC / 100)), nDecCus3) 
						ElseIf nMoeda == 4
							SCH->CH_CUSTO4 := Round((SC7->C7_TOTAL * (SCX->CX_PERC / 100)), nDecCus4) 
						ElseIf nMoeda == 5
							SCH->CH_CUSTO5 := Round((SC7->C7_TOTAL * (SCX->CX_PERC / 100)), nDecCus5) 
						EndIf
						SCH->CH_PERC 	:= SCX->CX_PERC
						For nX := 1 To Len(aEntCtb)
							cCpoSCH := "CH_EC" + aEntCtb[nX]
							cCpoSCX := "CX_EC" + aEntCtb[nX]
			
							&("SCH->" + cCpoSCH + "DB") := &("SCX->" + cCpoSCX + "DB")
							&("SCH->" + cCpoSCH + "CR") := &("SCX->" + cCpoSCX + "CR")
						Next nX
					SCH->(MsUnLock())
					SCX->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

	//-- Executa avalia��o do tipo de Compra
	SC7->C7_TIPCOM := MRetTipCom(,.T.,"PC")

Endif

If nOpcao == 2
	DbSelectArea("SCH")
	SCH->(DbSetOrder(1)) //-- CH_FILIAL + CH_PEDIDO + CH_FORNECE + CH_LOJA + CH_ITEMPD + CH_ITEM
	If SCH->(DbSeek(xFilial("SCH") + cNumPed + cFornece + cLoja + cItem))
		While SCH->(!Eof()) .And. ((SCH->CH_PEDIDO + SCH->CH_FORNECE + SCH->CH_LOJA + SCH->CH_ITEMPD) == (cNumPed + cFornece + cLoja + cItem))
			RecLock("SCH", .F.)
				SCH->CH_CUSTO1 := Round((SC7->C7_TOTAL * (SCH->CH_PERC / 100)), nDecCus1)
				If nMoeda == 2
					SCH->CH_CUSTO2 := Round((SC7->C7_TOTAL * (SCH->CH_PERC / 100)), nDecCus2)
				ElseIf nMoeda == 3 
					SCH->CH_CUSTO3 := Round((SC7->C7_TOTAL * (SCH->CH_PERC / 100)), nDecCus3) 
				ElseIf nMoeda == 4
					SCH->CH_CUSTO4 := Round((SC7->C7_TOTAL * (SCH->CH_PERC / 100)), nDecCus4) 
				ElseIf nMoeda == 5
					SCH->CH_CUSTO5 := Round((SC7->C7_TOTAL * (SCH->CH_PERC / 100)), nDecCus5) 
				EndIf
			SCH->(MsUnLock())
			SCH->(DbSkip())
		EndDo
	EndIf
EndIf

If nOpcao == 1 .And. lAtuSB2
	Reclock("SB2")
	SB2->B2_SALPEDI += SC7->C7_QUANT
Endif
If lAtuSB2
	SB2->(MsUnlock())
EndIf

RestArea(aAreaSCX)
RestArea(aAreaSCH)

If ExistBlock("GRVSC7")
	ExecBlock("GRVSC7",.F.,.F.)
Endif
SC7->(MsUnlock())
RestArea(aArea)

Return 

/*/{Protheus.doc} MT120AAprov
Gera alcada para o pedido de impota��o
@return Nil
@type function
/*/

Function MT120AAprov(nTipoPed,nItTot,cA120Num,cCodUser)
Local lAlcPedCTB  	:= SuperGetMv("MV_APRPCEC",.F.,.F.)
Local cGrupo        := EasyGParam("MV_PCAPROV")
LOCAL aAreaSC7 		:= SC7->(GetArea())
Local lGeraSCR  	:= .F.
Local lFirstNiv		:= .F.
Local lAltAprov		:= .F.
Local lAltGrup		:= .F.
Local cGrComPad		:= ""
local nGrp			:= 0
Local n120Totlib	:= 0
Local n120TotExc	:= 0
Local lBloqIP		:= .F.
Local aFilSCH := {}

Private	aHeadSC7:={}
Private aColsSC7:={}
Private aHeadSCH:={}
Private aColsSCH:={}


default aUsrLib		:= {}
//����������������������������������������������������������Ŀ
//� Verifica se deve gerar o arquivo de pedidos bloqueados   �
//������������������������������������������������������������
If SC7->C7_QUJE < SC7->C7_QUANT
	If !lAlcPedCTB
		If Empty(SC7->C7_APROV)
			SC7->C7_CONAPRO := "L"     
		Else
			SC7->C7_CONAPRO := "B"
		EndIf
	EndIf
	If SC7->C7_RESIDUO <> "S"	
		n120Totlib := nItTot
	    n120TotExc := nItTot
	EndIf
	SC7->C7_ENCER   := Space(len(SC7->C7_ENCER))
	lGeraSCR := .T.
EndIf  
//����������������������������������������������������������Ŀ
//� Gera arquivo de controle de alcadas SCR.                 �
//������������������������������������������������������������
BEGIN TRANSACTION
	If lGeraSCR .And. n120TotLib > 0
		//��������������������������������������������������������������Ŀ
		//� Limpa o Filtro do SCR caso ele exista                        �
		//����������������������������������������������������������������
		dbSelectArea("SCR")
		DbClearFilter()
		dbSelectArea("SC7")

		//��������������������������������������������������������������Ŀ
		//� Verifica o grupo de aprovacao do Comprador.                  �
		//����������������������������������������������������������������
		dbSelectArea("SY1")
		dbSetOrder(3)
		If MsSeek(xFilial()+cCodUser)
			If !lAltAprov
				cGrupo		:= If(!Empty(Y1_GRAPROV),SY1->Y1_GRAPROV,cGrupo)
			EndIf
			If !lAltGrup
				cGrComPad	:= If(!Empty(Y1_GRUPCOM),SY1->Y1_GRUPCOM,Space(Len(SC7->C7_GRUPCOM)))
			EndIf
		EndIf
		
		cGrupo:= If(Empty(SC7->C7_APROV),cGrupo,SC7->C7_APROV)
		//���������������������������������������������������������������������������������������������Ŀ
		//� Ponto de entrada para alterar o Grupo de Aprovacao.          								�
		//� Obs.: Na alteracao do pedido, pode ser usado para alterar o saldo do mesmo (var. n120TotLib)�
		//�����������������������������������������������������������������������������������������������
		If ExistBlock("MT120APV")
			nGrp:=0
			cMT120APV := ExecBlock("MT120APV",.F.,.F.)
			If ValType(cMT120APV) == "C"
				cGrupo := cMT120APV
				nGrp:=1
			EndIf
		EndIf
			
		//Se nao executar o Pe: MT120APV 
		If nGrp==0
			cGrupo:= If(Empty(SC7->C7_APROV),cGrupo,SC7->C7_APROV)  
		EndIf

		//�������������������������������������Ŀ
		//�Cria alcada de aprovacao do IP ou PC �
		//���������������������������������������
		If lAlcPedCTB .AND. nTipoPed <> 2
			nMoedaPed := SC7->C7_MOEDA
			nTxMoeda  := SC7->C7_TXMOEDA
			COMGerC7Ch(cA120Num,@aFilSCH)
			lBloqIP := MaEntCtb("SC7","SCH",cA120Num,"IP",aHeadSC7,aColsSC7,aHeadSCH,aColsSCH,1,SC7->C7_EMISSAO,,cGrupo)
		EndIf		

		//�����������������������������������������������������������������Ŀ
		//� Efetua a gravacao do campo de controle de aprovacao C7_CONAPRO  �
		//�������������������������������������������������������������������
		cBanco := Alltrim(Upper(TCGetDb()))
		SC7->(DBCOMMIT())
		cQuery := "UPDATE "+RetSqlname("SC7")+" "
		cQuery += "SET C7_GRUPCOM = '"+cGrComPad+"' "
		cQuery += "WHERE C7_FILIAL='"+xFilial("SC7")+"' AND "
		cQuery += "C7_NUM='"+cA120Num+"' AND "
		cQuery += "C7_GRUPCOM = '"+Space(Len(SC7->C7_GRUPCOM))+"' "
		If TcSrvType() <> "AS/400"
			cQuery += "AND D_E_L_E_T_=' ' "
		Else
			cQuery += "AND @DELETED@=' ' "
		Endif

		TcSqlExec(cQuery)
		
		If !lBloqIP .And. !Empty(cGrupo) 
			lFirstNiv := MaAlcDoc({cA120Num,if(nTipoPed == 1,"PC","AE"),n120TotLib,,,cGrupo,,SC7->C7_MOEDA,SC7->C7_TXMOEDA,SC7->C7_EMISSAO},,1)
		Endif 

		cQuery := "UPDATE "+RetSqlname("SC7")+" "
		cQuery += "SET C7_APROV = '"+IIF(lBloqIP,Space(Len(SC7->C7_APROV)),cGrupo)+"' " 
		cQuery += "WHERE C7_FILIAL='"+xFilial("SC7")+"' AND "
		cQuery += "C7_NUM='"+cA120Num+"' AND "
		If nGrp == 0
			cQuery += "C7_APROV = '"+Space(Len(SC7->C7_APROV))+"' AND "
		EndIf	
		If TcSrvType() <> "AS/400"
			cQuery += "D_E_L_E_T_=' ' "
		Else
			cQuery += "@DELETED@=' ' "
		Endif

		TcSqlExec(cQuery)
	EndIf
END TRANSACTION 

//Verifica se gerou SCR para deixar bloqueado ou liberado.
SCR->(dbSetOrder(1))
If nTipoPed == 2 .And. SCR->(dbSeek(xFilial('SCR')+'AE'+cA120Num))
	l120SCR := .T.
ElseIf SCR->(dbSeek(xFilial('SCR')+'PC'+cA120Num)) .Or. SCR->(dbSeek(xFilial('SCR')+'IP'+cA120Num))
	
	l120SCR := .T.
Else
	l120SCR := .F.
EndIf

If SC7->(dbSeek(xFilial("SC7")+cA120Num))
	While SC7->(! Eof() .And. C7_FILIAL+C7_NUM==xFilial("SC7")+cA120Num)
		If !Empty(SC7->C7_APROV)
			RecLock("SC7",.F.)
			If !lFirstNiv .And. l120SCR
				SC7->C7_CONAPRO := 'B'
			Else
				SC7->C7_CONAPRO := 'L' 
			EndIf
			MsUnlock()
		Endif	
	SC7->(dbSkip())
	EndDo
Endif
RestArea(aAreaSC7)
Return
