#INCLUDE "TFA05.ch"
#include "eADVPL.ch"

Function AlteraItem(aItens, nItens, nNrItem, cNrOS, oLbx, oItem, oFabric, oProd, oNrSerie, oQtde, oServ)

Local oDlg, oSay, oGet, oFabricBt, oProdutoBt, oCancelarBt
Local oGravarBt, oServico, oProdAntBt, oTrocar
Local oSerieAntLb, oSerieAntTx, oFabricTx, oProdutoTx, oProdAntTx
Local cNrSerie := space(10), nQtde := 0, aServico := {}, nServ := 1
Local cSerieAnt := space(06), lTrocar := .f., cFabric := space(23), cProduto := space(20)
Local lAnterior:=.f., cProdAnt:="", cNrItem := "" 
Local oGetQtd, oQtdeBt, oGetSerie, oSerieBt
Local aCmpPrd:={}, aIndPrd:={}, aCmpFab:={}, aIndFab:={}

If Len(aItens) == 0
	return nil
EndIf

MsgStatus(STR0001) //"Por favor, aguarde..."

//Consulta Padrao de Produtos
Aadd(aCmpPrd,{STR0002,SB1->(FieldPos("B1_COD")),60}) //"Código"
Aadd(aCmpPrd,{STR0003,SB1->(FieldPos("B1_DESC")),90}) //"Descrição"
Aadd(aIndPrd,{STR0002,1}) //"Código"
Aadd(aIndPrd,{STR0003,2}) //"Descrição"

//Consulta Padrao de Fabricantes
Aadd(aCmpFab,{STR0002,SA1->(FieldPos("A1_COD")),40}) //"Código"
Aadd(aCmpFab,{"Loja",SA1->(FieldPos("A1_LOJA")),15}) 
Aadd(aCmpFab,{STR0004,SA1->(FieldPos("A1_NOME")),90}) //"Nome"
Aadd(aIndFab,{STR0002,1}) //"Código"
Aadd(aIndFab,{STR0004,2}) //"Nome"

dbSelectArea("AA5")
dbGotop()
dbSetOrder(2)      
While !Eof()
	aAdd(aServico, AllTrim(AA5->AA5_DESCRI))
	dbSkip()
EndDo

cNrItem := Substr(aItens[nItens],1,2)
dbSelectArea("ABA")
dbSetOrder(1)
dbSeek(cNrOS + cNrItem)

If ABA->(Found())
	cFabric         := ABA->ABA_CODFAB
	cProduto        := ABA->ABA_CODPRO
	cNrSerie        := Alltrim(ABA->ABA_NUMSER)
	nQtde           := ABA->ABA_QUANT
	cProdAnt		:= ABA->ABA_ANTPRO
	cSerieAnt       := ABA->ABA_ANTSER
EndIf

DEFINE DIALOG oDlg TITLE STR0005 //"Alteração de Item"

@ 18,02 SAY oSay PROMPT STR0006 of oDlg //"Item:"
@ 18,25 GET oGet VAR cNrItem READONLY NO UNDERLINE of oDlg
@ 31,02 BUTTON oFabricBt CAPTION STR0007 SIZE 35,12 ACTION SFConsPadrao("SA1",cFabric,oFabricTx,aCmpFab,aIndFab,) of oDlg //"Fabric."
//ConsFabric(cFabric, oFabricTx)
@ 31,40 GET oFabricTx VAR cFabric READONLY of oDlg
@ 46,02 BUTTON oProdutoBt CAPTION STR0008 SIZE 60,12 ACTION SFConsPadrao("SB1",cProduto,oProdutoTx,aCmpPrd,aIndPrd,) of oDlg //"Prod./Eqpto."
//ConsProduto(cProduto, oProdutoTx, oProdAntTx, .f.)
@ 46,64 GET oProdutoTx VAR cProduto READONLY of oDlg
@ 61,02 BUTTON oSerieBt CAPTION STR0009 ACTION Keyb_Num(oGetSerie) of oDlg //"Nr Série"
@ 61,45 GET oGetSerie VAR cNrSerie of oDlg
@ 61,100 BUTTON oQtdeBt CAPTION STR0010 ACTION Keyb_Num(oGetQtd) of oDlg //"Qtde"
@ 61,135 GET oGetQtd VAR nQtde of oDlg
@ 76,02 CHECKBOX oTrocar VAR lTrocar CAPTION STR0011 ACTION TrocarProd(lTrocar, oProdAntBt, oProdAntTx, oSerieAntLb, oSerieAntTx) of oDlg  //"Trocar produtos"
@ 91,02 BUTTON oProdAntBt CAPTION STR0012 SIZE 60,12 ACTION SFConsPadrao("SB1",cProdAnt,oProdAntTx,aCmpPrd,aIndPrd,) of oDlg //"Produto Ant."
//ConsProduto(cProduto, oProdutoTx, oProdAntTx, .t.)
@ 91,63 GET oProdAntTx VAR cProdAnt READONLY of oDlg
@ 106,02 BUTTON oSerieAntLb CAPTION STR0013 ACTION Keyb_Num(oSerieAntTx) of oDlg //"Nr Série Ant."
@ 106,65 GET oSerieAntTx VAR cSerieAnt of oDlg
@ 130,02 SAY oSay PROMPT STR0014 of oDlg //"Serviço:"
@ 130,40 COMBOBOX oServico VAR nServ ITEMS aServico SIZE 80,60 Of oDlg
@ 145,02 BUTTON oCancelarBt CAPTION STR0015 SIZE 40,12 ACTION CloseDialog() of oDlg //"Cancelar"
@ 145,115 BUTTON oGravarBt CAPTION STR0016 SIZE 35,12 ACTION RegravaItem(cNrOS,cNrItem,cFabric,cProduto,cNrSerie,nQtde,cProdAnt,cSerieAnt,aServico[nServ]) of oDlg //"Gravar"

HideControl(oProdAntBt)
HideControl(oProdAntTx)
HideControl(oSerieAntLb)
HideControl(oSerieAntTx)                
ClearStatus()

ACTIVATE DIALOG oDlg

ListarItens(aItens, nItens, nNrItem, cNrOS, oLbx)
SelectItens(aItens, nItens, cNrOS, oItem, oFabric, oProd, oNrSerie, oQtde, oServ)

Return nil


Function RegravaItem(cNrOS,cNrItem,cFabric,cProduto,cNrSerie,nQtde,cProdAnt,cSerieAnt,aServico)

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
dbSeek(cNrOS + cNrItem)

If ABA->(Found())
	
	ABA->ABA_ITEM 	:= cNrItem
	ABA->ABA_CODFAB := Substr(cFabric,1,6)
	ABA->ABA_LOJAFA := cLojaFabric 
	ABA->ABA_CODPRO := cProduto
	ABA->ABA_NUMSER := cNrSerie
	ABA->ABA_QUANT  := nQtde  
    ABA->ABA_CODSER := cCodServ
	ABA->ABA_FABANT := "" 
	ABA->ABA_LOJANT := "" 
	ABA->ABA_ANTPRO := cProdAnt
	ABA->ABA_ANTSER := cSerieAnt
	ABA->ABA_NUMOS  := cNrOS 
	ABA->ABA_CODTEC := cCodTec
	ABA->ABA_SEQ  	:= "01"
	ABA->ABA_DESCRI := cDescrProd
	
Else

	MsgStop(STR0017,STR0018) //"Item não encontrado!"###"Aviso"
	
EndIf

CloseDialog()

Return nil


Function TrocarProd(lTrocar, oProdAntBt, oProdAntTx, oSerieAntLb, oSerieAntTx)
	If lTrocar
		ShowControl(oProdAntBt) 
		ShowControl(oProdAntTx)
		ShowControl(oSerieAntLb)
		ShowControl(oSerieAntTx)
	Else
		HideControl(oProdAntBt)
		HideControl(oProdAntTx) 
		HideControl(oSerieAntLb)
		HideControl(oSerieAntTx)        
	EndIf
Return nil