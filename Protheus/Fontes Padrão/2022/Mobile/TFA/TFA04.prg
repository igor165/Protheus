#INCLUDE "TFA04.ch"
#include "eADVPL.ch"

Function GravaItem(cNrOS,cNrItem,cFabric,cProduto,cNrSerie,nQtde,cProdAnt,cSerieAnt,aServico)

//Guarda descricao do produto, cod. do tecnico e cod. de servico
Local cDescrProd := "", cCodTec := "", cCodServ := ""  
Local cLojaFabric:= ""

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

dbSelectArea("SA1")
dbSetOrder(1)
If dbSeek(cFabric,.t.)
	cLojaFabric := SA1->A1_LOJA
Endif

If !VrfItem(cNrItem,cFabric,cProduto,cNrSerie,nQtde,cCodServ)
	return nil
Endif

dbSelectArea("ABA")
dbSetOrder(1)
dbSeek(cNrOS+cNrItem)

If ABA->(!Found())
	dbappend()
	ABA->ABA_ITEM   := cNrItem 
	ABA->ABA_CODFAB := Substr(cFabric,1,6)
	ABA->ABA_LOJAFA := cLojaFabric
	ABA->ABA_CODPRO := cProduto
	ABA->ABA_NUMSER := cNrSerie
	ABA->ABA_QUANT  := nQtde  
	ABA->ABA_LOCAL  := "" 
	ABA->ABA_LOCALI := "" 
	ABA->ABA_CODSER := cCodServ
	ABA->ABA_FABANT := "" 
	ABA->ABA_LOJANT := "" 
	ABA->ABA_ANTPRO := cProdAnt
	ABA->ABA_ANTSER := cSerieAnt
	ABA->ABA_NUMOS  := cNrOS
	ABA->ABA_CUSTO  := 0
	ABA->ABA_CODTEC := cCodTec
	ABA->ABA_SEQ    := "01" 
	ABA->ABA_SUBOS  := "" 
	ABA->ABA_DESCRI := cDescrProd
	ABA->ABA_LOCALD := "" 
	ABA->ABA_LOCLZD := "" 
	ABA->ABA_SEQRC  := "" 
	ABA->ABA_ITEMRC := "" 
	dbcommit()
Else
	MsgStop(STR0001,STR0002) //"Registro ja existente!"###"Aviso"
EndIf

CloseDialog()                         

Return nil


Function ExcluiItem(aItens, nItens, cNrOS, nNrItem, oLbx, oItem, oFabric, oProd, oNrSerie, oQtde, oServ)

Local cChave := ""

SET DELE ON

If Len(aItens) == 0
	return nil
EndIf

If nItens > 0 .And. !Empty(aItens[nItens])          
	cChave   := cNrOS + Substr(aItens[nItens],1,2)
	dbSelectArea("ABA")
	dbSetOrder(1)
	dbSeek(cChave)
	
	If ABA->(Found())
		//Perguntar se o usuario deseja realmente excluir... (OK)
		If MsgYesOrNo(STR0003 + Substr(aItens[nItens],1,2) + "?",STR0004) //"Deseja excluir o item "###"Atenção"
			dbDelete()        
			//PACK
			SetText(oItem,          space(2))
			SetText(oFabric,        space(15))
			SetText(oProd,          space(20))
			SetText(oNrSerie,       space(10))
			SetText(oQtde,          space(3))
			SetText(oServ,          space(10))
			//ListarItens(aItens, nItens, nNrItem, cNrOS, oLbx)
			aDel(aItens,nItens)
			aSize(aItens,Len(aItens)-1)
			SetArray(oLbx,aItens)
			If Len(aItens) == 0
			    nNrItem := 0 
			EndIf   
		EndIf
	EndIf
EndIf

Return nil


Function VrfItem(cNrItem,cFabric,cProduto,cNrSerie,nQtde,cCodServ)
//Validacao dos campos em branco
If Empty(cNrItem)
	MsgStop(STR0005,STR0002) //"Campo Nr. Item em branco"###"Aviso"
	Return .F.
EndIf

/*
If Empty(cFabric)
	MsgStop(STR0006,STR0002) //"Campo Fabricante em branco"###"Aviso"
	Return .F.
EndIf
*/

If Empty(cProduto)
	MsgStop(STR0007,STR0002) //"Campo Produto em branco"###"Aviso"
	Return .F.
EndIf

/*
If Empty(cNrSerie)
	MsgStop(STR0008,STR0002) //"Campo Nr. Série em branco"###"Aviso"
	Return .F.
EndIf
*/

If Empty(nQtde) .Or. nQtde <= 0
	MsgStop(STR0009,STR0002) //"Qtde Inválida"###"Aviso"
	Return .F.
EndIf

If Empty(cCodServ)
	MsgStop(STR0010,STR0002) //"Campo Serviço em branco"###"Aviso"
	Return .F.
EndIf
Return .T.