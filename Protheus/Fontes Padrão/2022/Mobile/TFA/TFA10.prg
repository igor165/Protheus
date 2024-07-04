#INCLUDE "TFA10.ch"
#include "eADVPL.ch"

Function RegravaDespesa(cNrOS, cNrDesp, cProduto, nQtde, nValor, nTotal, aServico)

Local cCodTec := "", cDescrProd := "", cCodServ := ""

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(cProduto)
If SB1->(Found())
	cDescrProd := SB1->B1_DESC
EndIf                         

dbSelectArea("AA5")
dbSetOrder(2)
dbSeek(aServico)
If AA5->(Found())
	cCodServ := AA5->AA5_CODSER     
EndIf

dbSelectArea("AA1")
cCodTec := AA1->AA1_CODTEC

If !VrfDespesa(cNrDesp,cProduto,nQtde,nValor,nTotal,cCodServ)
	Return nil
Endif

dbSelectArea("ABC")
dbSetOrder(1)
dbSeek(cNrOS + cNrDesp)

If ABC->(Found())
	ABC->ABC_NUMOS          := cNrOS
	//ABC->ABC_SUBOS        := ""   
	ABC->ABC_CODTEC         := cCodTec
	ABC->ABC_SEQ            := "01"
	ABC->ABC_ITEM           := cNrDesp
	ABC->ABC_CODPRO         := cProduto
	ABC->ABC_DESCRI         := cDescrProd
	ABC->ABC_QUANT          := nQtde
	ABC->ABC_VLUNIT         := nValor
	ABC->ABC_VALOR          := nTotal
	ABC->ABC_CODSER         := cCodServ
	//ABC->ABC_CUSTO        := 0
Else
	MsgStop(STR0001,STR0002) //"Item nao encontrado!"###"Aviso"
EndIf

CloseDialog()

Return nil


Function ExcluiDespesa(aDespesas, nDesp, cNrOS, nNrDesp, oLbx, oItem, oProd, oQtde, oTotal, oServ)

Local cChave := ""

SET DELE ON

If Len(aDespesas) == 0
	//Alert("array zero")
	return nil
EndIf

If nDesp > 0 .And. !Empty(aDespesas[nDesp])
	cChave := cNrOS + Substr(aDespesas[nDesp],1,2)
	dbSelectArea("ABC")
	dbSetOrder(1)
	dbSeek(cChave)
	
	If ABC->(Found())
		//Perguntar se o usuario deseja realmente excluir... (OK)
		If MsgYesOrNo(STR0003 + Substr(aDespesas[nDesp],1,2) + "?",STR0004) //"Deseja excluir a despesa "###"Atenção"
			dbDelete()
			//PACK
			SetText(oItem,  space(2))
			SetText(oProd,  space(20))
			SetText(oQtde,  space(2))
			SetText(oTotal, space(5))
			SetText(oServ,  space(20))
			//ListarDesp(aDespesas, nDesp, nNrDesp, cNrOS, oLbx)    
			aDel(aDespesas,nDesp)
			aSize(aDespesas,Len(aDespesas)-1)
			SetArray(oLbx,aDespesas)
			If Len(aDespesas) == 0
			     nNrDesp := 0
			EndIf
		EndIf
	EndIf
EndIf

Return nil
	  

Function GravaDespesa(cNrOS, cNrDesp, cProduto, nQtde, nValor, nTotal, aServico)

Local cCodTec := "", cDescrProd := "", cCodServ := ""

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(cProduto)
If SB1->(Found())
	cDescrProd := SB1->B1_DESC
	//Alert(cDescrProd)
EndIf                         

dbSelectArea("AA5")
dbSetOrder(2)
dbSeek(aServico)
If AA5->(Found())
	cCodServ := AA5->AA5_CODSER     
EndIf

dbSelectArea("AA1")
cCodTec := AA1->AA1_CODTEC

If !VrfDespesa(cNrDesp,cProduto,nQtde,nValor,nTotal,cCodServ)
	Return nil
Endif

dbSelectArea("ABC")
dbSetOrder(1)
dbSeek(cNrOS + cNrDesp)

If ABC->(!Found())
	dbappend()
	ABC->ABC_NUMOS          := cNrOS
	ABC->ABC_SUBOS          := ""   
	ABC->ABC_CODTEC         := cCodTec
	ABC->ABC_SEQ            := "01"
	ABC->ABC_ITEM           := cNrDesp
	ABC->ABC_CODPRO         := cProduto
	ABC->ABC_DESCRI         := cDescrProd
	ABC->ABC_QUANT          := nQtde
	ABC->ABC_VLUNIT         := nValor
	ABC->ABC_VALOR          := nTotal
	ABC->ABC_CODSER         := cCodServ
	ABC->ABC_CUSTO          := 0
	dbcommit()
Else
	MsgStop(STR0005,STR0002) //"Registro ja existente!"###"Aviso"
EndIf

CloseDialog()

Return nil


Function CalcDespesa(nQtde, nValor, nTotal, oTotalTx)

nTotal := nQtde * nValor
//SetText(oTotalTx, str(nTotal))
SetText(oTotalTx, nTotal)      

Return nil


Function Key_qtde(oQtdeTx)
	Keyboard(1,oQtdeTx)
	SetFocus(oQtdeTx)
Return nil
		       
Function Key_unitario(oValorTx)
	Keyboard(1,oValorTx)
	SetFocus(oValorTx)	
Return nil


//Validacao dos campos em branco
Function VrfDespesa(cNrDesp,cProduto,nQtde,nValor,nTotal,cCodServ)

If Empty(cNrDesp)
	MsgStop(STR0006,STR0002) //"Campo Nr. Despesa em branco"###"Aviso"
	Return .F.
EndIf

If Empty(cProduto)                                
	MsgStop(STR0007,STR0002) //"Campo Produto em branco"###"Aviso"
	Return .F.
EndIf

If Empty(nQtde) .Or. nQtde <= 0
	MsgStop(STR0008,STR0002) //"Qtde inválida"###"Aviso"
	Return .F.
EndIf

If Empty(nValor) .Or. nValor <= 0
	MsgStop(STR0009,STR0002) //"Valor Unit. inválido"###"Aviso"
	Return .F.
EndIf

If Empty(nTotal)
	MsgStop(STR0010,STR0002) //"Campo Total em branco"###"Aviso"
	Return .F.
EndIf

If Empty(cCodServ)
	MsgStop(STR0011,STR0002) //"Campo Serviço em branco"###"Aviso"
	Return .F.
EndIf
Return .T.