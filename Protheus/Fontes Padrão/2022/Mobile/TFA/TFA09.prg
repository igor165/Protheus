#INCLUDE "TFA09.ch"
#include "eADVPL.ch"

/*************************************** DESPESAS ****************************************/
Function Despesas(cOS, cNrItem, aOS)                  

Local oSay, oDlg, oIncluirBt, oAlterarBt, oExcluirBt, oSairBt, oLbx
Local oItem, oProd, oQtde, oTotal, oServ
Local aDespesas := {}, nDesp := 1, nNrDesp := 0, cItem := space(5), cNrOS := ""
Local cProd := space(25), cQtde := space(5), cTotal := space(5), cServ := space(20)

If Len(aOS) == 0
	return nil
Endif

MsgStatus(STR0001) //"Por favor, aguarde..."

cNrOS := cOS + cNrItem

SET DELE ON

DEFINE DIALOG oDlg TITLE STR0002 //"Despesas"

@ 18,02 LISTBOX oLbx VAR nDesp ITEMS aDespesas SIZE 150,60 ACTION SelectDesp(aDespesas, nDesp, cNrOS, oItem, oProd, oQtde, oTotal, oServ) of oDlg
@ 80,02 BUTTON oIncluirBt CAPTION STR0003 SIZE 35,12 ACTION IncluiDespesa(cNrOS, nNrDesp, aDespesas, nDesp, oLbx, oItem, oProd, oQtde, oTotal, oServ) Of oDlg //"Incluir"
@ 80,42 BUTTON oAlterarBt CAPTION STR0004 SIZE 35,12 ACTION AlteraDespesa(aDespesas, nDesp, cNrOS, nNrDesp, oLbx, oItem, oProd, oQtde, oTotal, oServ) Of oDlg //"Alterar"
@ 80,82 BUTTON oExcluirBt CAPTION STR0005 SIZE 35,12 ACTION ExcluiDespesa(aDespesas, nDesp, cNrOS, nNrDesp, oLbx, oItem, oProd, oQtde, oTotal, oServ) Of oDlg //"Excluir"
@ 80,122 BUTTON oSairBt CAPTION STR0006 SIZE 28,12 ACTION CloseDialog() Of oDlg //"Sair"

@ 100,02 SAY oSay PROMPT STR0007 BOLD of oDlg //"Item: "
@ 100,32 GET oItem VAR cItem READONLY NO UNDERLINE of oDlg
@ 115,02 SAY oSay PROMPT STR0008 of oDlg       //"Produto:"
@ 115,40 GET oProd VAR cProd READONLY NO UNDERLINE of oDlg
@ 130,02 SAY oSay PROMPT STR0009 of oDlg         //"Qtde.:"
@ 130,30 GET oQtde VAR cQtde READONLY NO UNDERLINE of oDlg
@ 130,70 SAY oSay PROMPT STR0010 of oDlg  //"Total: R$"
@ 130,112 GET oTotal VAR cTotal READONLY NO UNDERLINE PICTURE "@E 9,999.99" of oDlg
@ 145,02 SAY oSay PROMPT STR0011 of oDlg //"Serviço: "
@ 145,42 GET oServ VAR cServ READONLY NO UNDERLINE of oDlg

ListarDesp(aDespesas, nDesp, nNrDesp, cNrOS, oLbx)
SelectDesp(aDespesas, nDesp, cNrOS, oItem, oProd, oQtde, oTotal, oServ)
ClearStatus()

ACTIVATE DIALOG oDlg

Return nil

	
Function ListarDesp(aDespesas, nDesp, nNrDesp, cNrOS, oLbx)

dbSelectArea("ABC")
dbSetOrder(1)
dbGoTop()

nNrDesp := 0
aSize(aDespesas,0)   
While !Eof()
	If ABC->ABC_NUMOS == cNrOS
		aAdd(aDespesas, ABC->ABC_ITEM + " - " + ABC->ABC_DESCRI)
		nNrDesp := nNrDesp + 1  
	EndIf   
	dbSkip()        
Enddo

SetArray(oLbx,aDespesas)

Return nil


Function SelectDesp(aDespesas, nDesp, cNrOS, oItem, oProd, oQtde, oTotal, oServ)

Local cTmpOS := ""              //Chave para pesquisa (OS + Item)

If ( nDesp <= Len(aDespesas) )
	cTmpOS := cNrOS + Substr(aDespesas[nDesp],1,2)
	dbSelectArea("ABC")
	dbSetOrder(1)      
	dbGoTop()
	dbSeek(cTmpOS)
	
	SetText(oItem,          ABC->ABC_ITEM)
	SetText(oProd,          ABC->ABC_DESCRI)
	//SetText(oQtde,          str(ABC->ABC_QUANT))
	SetText(oQtde,          ABC->ABC_QUANT)
    //SetText(oTotal,         str(ABC->ABC_VALOR))
    SetText(oTotal,         ABC->ABC_VALOR)
	SetText(oServ,          ABC->ABC_CODSER)
EndIf

Return nil


Function IncluiDespesa(cNrOS, nNrDesp, aDespesas, nDesp, oLbx, oItem, oProd, oQtde, oTotal, oServ)

Local oDlg, oSay, oProdutoBt, oQtdeBt, oValorBt, oCbx, oCancelarBt, oGravarBt, oProdutoTx
Local nQtde := 0, nValor := 0, nTotal := 0, nServico := 1, aServico := {}, cNrDesp := space(1)
Local cProduto := space(20), oTotalTx, oItemTx //oProdAntTx, lAnterior := .f.
Local oQtdeTx, oValorTx
Local aCmpPrd:={},aIndPrd:={}

MsgStatus(STR0001) //"Por favor, aguarde..."
//Consulta Padrao de Produtos
Aadd(aCmpPrd,{STR0012,SB1->(FieldPos("B1_COD")),60}) //"Código"
Aadd(aCmpPrd,{STR0013,SB1->(FieldPos("B1_DESC")),90}) //"Descrição"
Aadd(aIndPrd,{STR0012,1}) //"Código"
Aadd(aIndPrd,{STR0013,2}) //"Descrição"

dbSelectArea("AA5")
dbgotop()
dbSetOrder(2)      
While !Eof()
	aAdd(aServico, AllTrim(AA5->AA5_DESCRI))
	dbSkip()
EndDo                                      

nNrDesp := nNrDesp + 1
cNrDesp := StrZero(nNrDesp, 2)

DEFINE DIALOG oDlg TITLE STR0014 //"Incluir despesa"

@ 18,02 SAY oSay PROMPT STR0007 BOLD of oDlg //"Item: "
@ 18,30 GET oItemTx VAR cNrDesp READONLY NO UNDERLINE of oDlg
@ 38,02 BUTTON oProdutoBt CAPTION STR0015 SIZE 40,12 ACTION SFConsPadrao("SB1",cProduto,oProdutoTx,aCmpPrd,aIndPrd,) of oDlg //"Produto"
//ConsProduto(cProduto, oProdutoTx, oProdAntTx, .f.)
@ 38,48 GET oProdutoTx VAR cProduto READONLY of oDlg
@ 58,02 BUTTON oQtdeBt CAPTION STR0016 SIZE 40,12 ACTION Key_qtde(oQtdeTx) of oDlg //"Qtde"
@ 58,48 GET oQtdeTx VAR nQtde VALID CalcDespesa(nQtde, nValor, nTotal, oTotalTx) of oDlg
@ 78,02 BUTTON oValorBt CAPTION STR0017 SIZE 40,12 ACTION Key_unitario(oValorTx) of oDlg //"Vlr Unit"
@ 78,48 GET oValorTx VAR nValor PICTURE "@E 9,999.99" VALID CalcDespesa(nQtde, nValor, nTotal, oTotalTx) of oDlg
@ 98,02 SAY oSay PROMPT STR0010 of oDlg //"Total: R$"
@ 98,48 GET oTotalTx VAR nTotal READONLY /*NO UNDERLINE*/ PICTURE "@E 9,999.99" of oDlg
@ 118,02 SAY oSay PROMPT STR0018 of oDlg //"Serviço"
@ 118,48 COMBOBOX oCbx VAR nServico ITEMS aServico SIZE 90,60 of oDlg
@ 143,02 BUTTON oCancelarBt CAPTION STR0019 SIZE 40,12 ACTION CloseDialog() of oDlg //"Cancelar"
@ 143,107 BUTTON oGravarBt CAPTION STR0020 SIZE 40,12 ACTION GravaDespesa(cNrOS, cNrDesp, cProduto, nQtde, nValor, nTotal, aServico[nServico]) of oDlg //"Gravar"

ClearStatus()
ACTIVATE DIALOG oDlg

ListarDesp(aDespesas, nDesp, nNrDesp, cNrOS, oLbx)
SelectDesp(aDespesas, nDesp, cNrOS, oItem, oProd, oQtde, oTotal, oServ)

Return nil


Function AlteraDespesa(aDespesas, nDesp, cNrOS, nNrDesp, oLbx, oItem, oProd, oQtde, oTotal, oServ)

Local oDlg, oSay, oProdutoBt, oQtdeBt, oValorBt, oCbx, oCancelarBt, oGravarBt, oProdutoTx
Local oQtdeTx, oValorTx
Local nQtde := 0, nValor := 0, nTotal := 0, nServico := 1, aServico := {}, cNrDesp := ""
Local cProduto := space(20), oTotalTx, oItemDesp //oProdAntTx, lAnterior := .f.,
Local aCmpPrd:={},aIndPrd:={}

If Len(aDespesas) == 0
	return nil
EndIf

MsgStatus(STR0001) //"Por favor, aguarde..."
//Consulta Padrao de Produtos
Aadd(aCmpPrd,{STR0012,SB1->(FieldPos("B1_COD")),60}) //"Código"
Aadd(aCmpPrd,{STR0013,SB1->(FieldPos("B1_DESC")),90}) //"Descrição"
Aadd(aIndPrd,{STR0012,1}) //"Código"
Aadd(aIndPrd,{STR0013,2}) //"Descrição"

dbSelectArea("AA5")
dbGoTop()
dbSetOrder(2)      
While !Eof()
	aAdd(aServico, AllTrim(AA5->AA5_DESCRI))
	dbSkip()
EndDo

cNrDesp := Substr(aDespesas[nDesp],1,2)
dbSelectArea("ABC")
dbSetOrder(1)
dbSeek(cNrOS + cNrDesp)

If ABC->(Found())
	cProduto := ABC->ABC_CODPRO
	nQtde    := ABC->ABC_QUANT 
	nValor   := ABC->ABC_VLUNIT
	nTotal   := ABC->ABC_VALOR
EndIf

DEFINE DIALOG oDlg TITLE STR0021 //"Alterar despesa"

@ 18,02 SAY oSay PROMPT STR0007 BOLD of oDlg //"Item: "
@ 18,30 GET oItemDesp VAR cNrDesp READONLY NO UNDERLINE of oDlg
@ 38,02 BUTTON oProdutoBt CAPTION STR0015 SIZE 40,12 ACTION SFConsPadrao("SB1",cProduto,oProdutoTx,aCmpPrd,aIndPrd,) of oDlg //"Produto"
//ConsProduto(cProduto, oProdutoTx, oProdAntTx, .f.)
@ 38,48 GET oProdutoTx VAR cProduto READONLY of oDlg
@ 58,02 BUTTON oQtdeBt CAPTION STR0016 SIZE 40,12 ACTION Key_qtde(oQtdeTx) of oDlg //"Qtde"
@ 58,48 GET oQtdeTx VAR nQtde VALID CalcDespesa(nQtde, nValor, nTotal, oTotalTx) of oDlg
@ 78,02 BUTTON oValorBt CAPTION STR0017 SIZE 40,12 ACTION Key_unitario(oValorTx) of oDlg //"Vlr Unit"
@ 78,48 GET oValorTx VAR nValor PICTURE "@E 9,999.99" VALID CalcDespesa(nQtde, nValor, nTotal, oTotalTx) of oDlg
@ 98,02 SAY oSay PROMPT STR0010 of oDlg //"Total: R$"
@ 98,48 GET oTotalTx VAR nTotal READONLY /*NO UNDERLINE*/ PICTURE "@E 9,999.99" of oDlg
@ 118,02 SAY oSay PROMPT STR0018 of oDlg //"Serviço"
@ 118,48 COMBOBOX oCbx VAR nServico ITEMS aServico SIZE 90,60 of oDlg
@ 143,02 BUTTON oCancelarBt CAPTION STR0019 SIZE 40,12 ACTION CloseDialog() of oDlg //"Cancelar"
@ 143,107 BUTTON oGravarBt CAPTION STR0020 SIZE 40,12 ACTION RegravaDespesa(cNrOS, cNrDesp, cProduto, nQtde, nValor, nTotal, aServico[nServico]) of oDlg //"Gravar"

ClearStatus()

ACTIVATE DIALOG oDlg

ListarDesp(aDespesas, nDesp, nNrDesp, cNrOS, oLbx)
SelectDesp(aDespesas, nDesp, cNrOS, oItem, oProd, oQtde, oTotal, oServ)

Return nil