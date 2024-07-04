#INCLUDE "TFA03.ch"
#include "eADVPL.ch"

// Controla tela de itens, despesas, pendencias, requisicoes etc...
Function Itens(cOS, cNrItem, aOS)

Local oDlg, oIncluirBt, oAlterarBt, oExcluirBt, oSairBt, oLbx
Local oItem, oFabric, oProd, oNrSerie, oQtde, oServ, cItem := "", cNrOS := ""
Local oSay, aItens := {}, nItens := 1, nNrItem := 0, cFabric := space(06)
Local cProd := space(20), cNrSerie := space(10), nQtde := 0, cServ := space(20)

If Len(aOS) == 0
	return nil
Endif
MsgStatus(STR0001) //"Por favor, aguarde..."

cNrOS := cOS + cNrItem  

SET DELE ON

DEFINE DIALOG oDlg TITLE STR0002 //"Itens"

@ 18,02 LISTBOX oLbx VAR nItens ITEMS aItens SIZE 150,60 ACTION SelectItens(aItens, nItens, cNrOS, oItem, oFabric, oProd, oNrSerie, oQtde, oServ) of oDlg
@ 80,02 BUTTON oIncluirBt CAPTION STR0003 SIZE 35,12 ACTION IncluiItem(cNrOS, nNrItem, aItens, nItens, oLbx, oItem, oFabric, oProd, oNrSerie, oQtde, oServ) Of oDlg //"Incluir"
@ 80,42 BUTTON oAlterarBt CAPTION STR0004 SIZE 35,12 ACTION AlteraItem(aItens, nItens, nNrItem, cNrOS, oLbx, oItem, oFabric, oProd, oNrSerie, oQtde, oServ) Of oDlg //"Alterar"
@ 80,82 BUTTON oExcluirBt CAPTION STR0005 SIZE 35,12 ACTION ExcluiItem(aItens, nItens, cNrOS, nNrItem, oLbx, oItem, oFabric, oProd, oNrSerie, oQtde, oServ) Of oDlg //"Excluir"
@ 80,122 BUTTON oSairBt CAPTION STR0006 SIZE 28,12 ACTION CloseDialog() of oDlg //"Sair"
	   
@ 100,02 SAY oSay PROMPT STR0007 BOLD of oDlg //"Item: "
@ 100,32 GET oItem VAR cItem READONLY NO UNDERLINE SIZE 15,12 of oDlg
@ 100,65 SAY oSay PROMPT STR0008 of oDlg //"Fabric.:"
@ 100,100 GET oFabric VAR cFabric READONLY NO UNDERLINE of oDlg
@ 115,02 SAY oSay PROMPT STR0009 of oDlg //"Prod./Eqpto.:"
@ 115,60 GET oProd VAR cProd READONLY NO UNDERLINE of oDlg
@ 130,02 SAY oSay PROMPT STR0010 of oDlg //"Nr. Série:"
@ 130,43 GET oNrSerie VAR cNrSerie READONLY NO UNDERLINE of oDlg
@ 130,110 SAY oSay PROMPT STR0011 of oDlg //"Qtde.:"
@ 130,140 GET oQtde VAR nQtde READONLY NO UNDERLINE of oDlg
@ 145,02 SAY oSay PROMPT STR0012 of oDlg //"Serv.:"
@ 145,30 GET oServ VAR cServ READONLY NO UNDERLINE SIZE 90,12 of oDlg
//@ 145,130 BUTTON oSairBt CAPTION "Sair" SIZE 25,12 ACTION CloseDialog() of oDlg

ListarItens(aItens, nItens, nNrItem, cNrOS, oLbx)
SelectItens(aItens, nItens, cNrOS, oItem, oFabric, oProd, oNrSerie, oQtde, oServ)
ClearStatus()

ACTIVATE DIALOG oDlg

Return nil


Function ListarItens(aItens, nItens, nNrItem, cNrOS, oLbx)

//Local aTmpItens := {}

dbSelectArea("ABA")
dbSetOrder(1)
dbGoTop()

nNrItem := 0     
aSize(aItens,0)   

While !Eof()
	If ABA->ABA_NUMOS == cNrOS
		aAdd(aItens, ABA->ABA_ITEM + " - " + ABA->ABA_DESCRI)
		nNrItem := nNrItem + 1  //Val(Substr(aItens[nItens], 1, 2))
	EndIf   
	dbSkip()        
Enddo

SetArray(oLbx, aItens)
Return nil


Function SelectItens(aItens, nItens, cNrOS, oItem, oFabric, oProd, oNrSerie, oQtde, oServ)

Local cTmpOS := ""              //Chave para pesquisa (OS + Item)

If ( nItens <= Len(aItens) )
	cTmpOS := cNrOS + Substr(aItens[nItens],1,2)
	dbSelectArea("ABA")
	dbSetOrder(1)      
	dbGoTop()
	dbSeek(cTmpOS)
	
	SetText(oItem,          ABA->ABA_ITEM)
	SetText(oFabric,        ABA->ABA_CODFAB)
	SetText(oProd,          ABA->ABA_DESCRI)
	SetText(oNrSerie,       ABA->ABA_NUMSER)
	SetText(oQtde,          str(ABA->ABA_QUANT))
	SetText(oServ,          ABA->ABA_CODSER)
EndIf

Return nil


Function IncluiItem(cNrOS, nNrItem, aItens, nItens, oLbx, oItem, oFabric, oProd, oNrSerie, oQtde, oServ)

Local oDlg, oSay, oGet, oFabricBt, oProdutoBt, oCancelarBt, oGravarBt, oServico, oProdAntBt, oTrocar, oSerieAntLb, oSerieAntTx, oFabricTx, oProdutoTx, oProdAntTx, cNrItem := "" 
Local cNrSerie := space(10), nQtde := 0, aServico := {}, nServ := 1, cSerieAnt := space(06), lTrocar := .f., cFabric := space(23), cProduto := space(20)
Local lAnterior := .f., cProdAnt := "", oGetQtd, oQtdeBt, oGetSerie, oSerieBt
Local aCmpPrd:={},aIndPrd:={},aCmpFab:={},aIndFab:={}

MsgStatus(STR0001) //"Por favor, aguarde..."

//Consulta Padrao de Produtos
Aadd(aCmpPrd,{STR0013,SB1->(FieldPos("B1_COD")),60}) //"Código"
Aadd(aCmpPrd,{STR0014,SB1->(FieldPos("B1_DESC")),90}) //"Descrição"
Aadd(aIndPrd,{STR0013,1}) //"Código"
Aadd(aIndPrd,{STR0014,2}) //"Descrição"

//Consulta Padrao de Fabricantes
Aadd(aCmpFab,{STR0013,SA1->(FieldPos("A1_COD")),40})	//"Código"
Aadd(aCmpFab,{"Loja" ,SA1->(FieldPos("A1_LOJA")),15})
Aadd(aCmpFab,{STR0015,SA1->(FieldPos("A1_NOME")),90})	//"Nome"
Aadd(aIndFab,{STR0013,1}) //"Código"
Aadd(aIndFab,{STR0015,2}) //"Nome"

dbSelectArea("AA5")
dbGotop()
dbSetOrder(2)      
While !Eof()
	aAdd(aServico, AllTrim(AA5->AA5_DESCRI))
	dbSkip()
EndDo

nNrItem := nNrItem + 1
cNrItem := StrZero(nNrItem, 2)

DEFINE DIALOG oDlg TITLE STR0016 //"Itens da OS"

@ 18,02 SAY oSay PROMPT STR0017 of oDlg //"Item:"
@ 18,25 GET oGet VAR cNrItem READONLY NO UNDERLINE of oDlg
@ 31,02 BUTTON oFabricBt CAPTION STR0018 SIZE 35,12 ACTION SFConsPadrao("SA1",cFabric,oFabricTx,aCmpFab,aIndFab,) of oDlg //"Fabric."
//ConsFabric(cFabric, oFabricTx)
#ifdef __PALM__
	@ 31,40 GET oFabricTx VAR cFabric READONLY of oDlg
	@ 46,64 GET oProdutoTx VAR cProduto READONLY of oDlg
	@ 61,45 GET oGetSerie VAR cNrSerie of oDlg	
	@ 106,65 GET oSerieAntTx VAR cSerieAnt of oDlg	
#else
	cFabric := space(35)
	@ 31,40 GET oFabricTx VAR cFabric READONLY of oDlg
	cProduto := space(28)
	@ 46,64 GET oProdutoTx VAR cProduto READONLY of oDlg
	cNrSerie := space(17)
	@ 61,45 GET oGetSerie VAR cNrSerie of oDlg	
	cSerieAnt := space(17)
	@ 106,65 GET oSerieAntTx VAR cSerieAnt of oDlg	
#endif

@ 46,02 BUTTON oProdutoBt CAPTION STR0019 SIZE 60,12 ACTION SFConsPadrao("SB1",cProduto,oProdutoTx,aCmpPrd,aIndPrd,) of oDlg //"Prod./Eqpto."
// ConsProduto(cProduto, oProdutoTx, oProdAntTx, .f.)
@ 61,02 BUTTON oSerieBt CAPTION STR0020 ACTION Keyb_Num(oGetSerie) of oDlg //"Nr Série"

@ 61,100 BUTTON oQtdeBt CAPTION STR0021 ACTION Keyb_Num(oGetQtd) of oDlg //"Qtde"
@ 61,135 GET oGetQtd VAR nQtde of oDlg
@ 76,02 CHECKBOX oTrocar VAR lTrocar CAPTION STR0022 ACTION TrocarProd(lTrocar, oProdAntBt, oProdAntTx, oSerieAntLb, oSerieAntTx) of oDlg  //"Trocar produtos"
@ 91,02 BUTTON oProdAntBt CAPTION STR0023 SIZE 60,12 ACTION SFConsPadrao("SB1",cProdAnt,oProdAntTx,aCmpPrd,aIndPrd,) of oDlg //"Produto Ant."
//ConsProduto(cProduto, oProdutoTx, oProdAntTx, .t.)
@ 91,63 GET oProdAntTx VAR cProdAnt READONLY of oDlg

@ 106,02 BUTTON oSerieAntLb CAPTION STR0024 ACTION Keyb_Num(oSerieAntTx) of oDlg //"Nr Série Ant."
@ 130,02 SAY oSay PROMPT STR0025 of oDlg //"Serviço:"
@ 130,40 COMBOBOX oServico VAR nServ ITEMS aServico SIZE 80,60 Of oDlg
@ 145,02 BUTTON oCancelarBt CAPTION STR0026 SIZE 40,12 ACTION CloseDialog() of oDlg //"Cancelar"
@ 145,115 BUTTON oGravarBt CAPTION STR0027 SIZE 35,12 ACTION GravaItem(cNrOS,cNrItem,cFabric,cProduto,cNrSerie,nQtde,cProdAnt,cSerieAnt,aServico[nServ]) of oDlg //"Gravar"

HideControl(oProdAntBt)
HideControl(oProdAntTx)
HideControl(oSerieAntLb)
HideControl(oSerieAntTx)                
ClearStatus()

ACTIVATE DIALOG oDlg

ListarItens(aItens, nItens, nNrItem, cNrOS, oLbx)
SelectItens(aItens, nItens, cNrOS, oItem, oFabric, oProd, oNrSerie, oQtde, oServ)

Return nil