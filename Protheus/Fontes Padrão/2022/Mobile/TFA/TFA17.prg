#INCLUDE "TFA17.ch"
#include "eADVPL.ch"

/********************************* Consulta de Produto ************************************/
Function ConsProduto(cProduto, oProdutoTx, oProdAntTx, lAnterior)

Local oDlgProd, oListProd, oPesquisaBt, oPesquisaTx, oRetornaBt, oProximoBt, oAnteriorBt, oConsCbx
Local nProd := 1, aProd := {}, cPesquisa := space(30), i := 0, nTop := 0, cTmpProd := space(20)
Local aCons := {}, nCons := 1

aadd(aCons,STR0001) //"Código"
aadd(aCons,STR0002) //"Descrição"

dbSelectArea("SB1")
dbSetOrder(2)
dbGoTop()
nTop := SB1->(Recno())

DEFINE DIALOG oDlgProd TITLE STR0003 //"Selecione um Produto"

@ 18,02 LISTBOX oListProd VAR nProd ITEMS aProd SIZE 139,115 of oDlgProd
#ifdef __PALM__
	@ 130,02 GET oPesquisaTx VAR cPesquisa of oDlgProd
	@ 145,60 BUTTON oPesquisaBt CAPTION STR0004 SIZE 40,12 ACTION PesquisaProd(cPesquisa, oProdutoTx, oPesquisaTx, oListProd, aProd, nProd, nTop, aCons, nCons) of oDlgProd //"Pesquisar"
	@ 145,110 BUTTON oRetornaBt CAPTION STR0005 SIZE 40,12 ACTION CloseDialog() of oDlgProd //"Retornar"
#else
	cPesquisa := space(45)
	@ 130,02 GET oPesquisaTx VAR cPesquisa of oDlgProd
	@ 145,60 BUTTON oPesquisaBt CAPTION STR0004 SIZE 43,12 ACTION PesquisaProd(cPesquisa, oProdutoTx, oPesquisaTx, oListProd, aProd, nProd, nTop, aCons, nCons) of oDlgProd //"Pesquisar"
	@ 145,110 BUTTON oRetornaBt CAPTION STR0005 SIZE 43,12 ACTION CloseDialog() of oDlgProd //"Retornar"
#endif  
ListaProd(nTop, aProd, nProd, oListProd)

@ 145,02 COMBOBOX oConsCbx VAR nCons ITEMS aCons SIZE 50,30 of oDlgProd
@ 18,145 BUTTON oAnteriorBt CAPTION Chr(5) SYMBOL SIZE 10,12 ACTION PgUpProd(aProd, nProd, oListProd, nTop) of oDlgProd
@ 115,145 BUTTON oProximoBt CAPTION Chr(6) SYMBOL SIZE 10,12 ACTION PgDnProd(aProd, nProd, oListProd, nTop) of oDlgProd

ACTIVATE DIALOG oDlgProd

cProduto := aProd[nProd]
cTmpProd := cProduto

If lAnterior
	SetText(oProdAntTx, cTmpProd)
Else
	SetText(oProdutoTx, cTmpProd)
EndIf

dbSelectArea("SB1")
dbSetOrder(2)
dbSeek(cProduto)

If SB1->(Found())
	cProduto := SB1->B1_COD
EndIf

Return nil


Function PgUpProd(aProd, nProd, oListProd, nTop)

Local nRec := SB1->(Recno()), nCargaMax := GetListRows(oListProd)

SB1->(dbGoTop())
If SB1->(Recno()) == nTop
	return
EndIf
SB1->(dbGoTo(nTop))
SB1->(dbSkip(-nCargaMax))
nTop := SB1->(Recno())
ListaProd(@nTop, aProd, nProd, oListProd)

Return nil
	

Function PgDnProd(aProd, nProd, oListProd, nTop)

Local nRec := SB1->(Recno()), nCargaMax := GetListRows(oListProd)

SB1->(dbGoTo(nTop))
SB1->(dbSkip(nCargaMax))
If !Eof()
   nTop := SB1->(Recno())
   ListaProd(@nTop, aProd, nProd, oListProd)
Else
   SB1->(dbGoTo(nRec))
EndIf

Return nil


Function PesquisaProd(cPesquisa, oProdutoTx, oPesquisaTx, oListProd, aProd, nProd, nTop, aCons, nCons)

Local nRec := 0, i := 1, cTipoCons := Substr(aCons[nCons],1,1)
Local nCargaMax := GetListRows(oListProd)

If cTipoCons == "D" //descricao
	cPesquisa := Upper(cPesquisa)
	dbSelectArea("SB1")
	dbSetOrder(2)
	dbSeek(cPesquisa)  
Else				//codigo
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(cPesquisa)  
EndIf

If SB1->(Found())
	nRec := SB1->(Recno())
	cPesquisa := SB1->B1_DESC
	//SetText(oPesquisaTx, cPesquisa)
	If cTipoCons == "C"
		SB1->(dbSetOrder(2))
		dbSeek(cPesquisa)
		nRec := SB1->(Recno())
	EndIf	
	
	dbGoTo(nRec)
	aSize(aProd,0)
	For i := 1 to nCargaMax
		aAdd(aProd, Alltrim(SB1->B1_DESC))
		dbSkip()
		If Eof()
		   break
		EndIf
	Next
	
	nTop := nRec // Atualiza nTop com a posicao localizada na tabela
	SetArray(oListProd, aProd)
Else
	MsgAlert(STR0006,STR0007) //"Produto nao encontrado!"###"Aviso"
	cPesquisa := ""
EndIf

Return nil


//Lista produtos de acordo com o botao selecionado (PgUp ou PgDn)
Function ListaProd(nTop, aProd, nProd, oListProd)

Local i := 0, nCargaMax := GetListRows(oListProd)

dbSelectArea("SB1")
dbSetOrder(2)

If Len(aProd) > 0 
   dbGoTo(nTop)
Else
   dbGoTop()
EndIf                       

aSize(aProd,0)

For i := 1 to nCargaMax
	aAdd(aProd, Alltrim(SB1->B1_DESC))
	dbSkip()
	If Eof()
	   break
	EndIf
Next

If (oListProd != nil)
	SetArray(oListProd, aProd)
EndIf

Return nil      


/********************************* Consulta de Cliente ************************************/
Function ConsCliente(cCliente, oClienteLb, cTraslado, oTrasladoTx)

Local oDlg, oLbx, oPesquisaBt, oPesquisaTx, oRetornaBt, oProximoBt, oAnteriorBt, oConsCbx
Local nCli := 1, aCliente := {}, cPesquisa := space(30), i := 0, nTop := 0, cTmpCliente := ""
Local aCons := {}, nCons := 1                        

aadd(aCons,STR0001) //"Código"
aadd(aCons,STR0002) //"Descrição"

dbSelectArea("SA1")
dbSetOrder(2)
dbGoTop()
nTop := SA1->(Recno())

/*While !Eof() .And. i < 10
	aAdd(aCliente, Alltrim(SA1->A1_NOME))
	dbSkip()             
	i := i + 1
Enddo */

DEFINE DIALOG oDlg TITLE STR0008 //"Selecione um Cliente"

@ 18,02 LISTBOX oLbx VAR nCli ITEMS aCliente SIZE 139,115 of oDlg
#ifdef __PALM__
	@ 130,02 GET oPesquisaTx VAR cPesquisa of oDlg       
	@ 145,60 BUTTON oPesquisaBt CAPTION STR0004 SIZE 40,12 ACTION PesquisaCliente(cPesquisa, oClienteLb, oPesquisaTx, oLbx, aCliente, nCli, nTop, aCons, nCons) of oDlg //"Pesquisar"
	@ 145,110 BUTTON oRetornaBt CAPTION STR0005 SIZE 40,12 ACTION CloseDialog() of oDlg //"Retornar"
#else
	cPesquisa := space(45)
	@ 130,02 GET oPesquisaTx VAR cPesquisa of oDlg       
	@ 145,60 BUTTON oPesquisaBt CAPTION STR0004 SIZE 43,12 ACTION PesquisaCliente(cPesquisa, oClienteLb, oPesquisaTx, oLbx, aCliente, nCli, nTop, aCons, nCons) of oDlg //"Pesquisar"
	@ 145,110 BUTTON oRetornaBt CAPTION STR0005 SIZE 43,12 ACTION CloseDialog() of oDlg //"Retornar"
#endif
ListaCli(nTop, aCliente, nCli, oLbx)

@ 145,02 COMBOBOX oConsCbx VAR nCons ITEMS aCons SIZE 50,30 of oDlg
@ 18,145 BUTTON oAnteriorBt CAPTION Chr(5) SYMBOL SIZE 10,12 ACTION PgUpCli(aCliente, nCli, oLbx, nTop) of oDlg
@ 115,145 BUTTON oProximoBt CAPTION Chr(6) SYMBOL SIZE 10,12 ACTION PgDnCli(aCliente, nCli, oLbx, nTop) of oDlg

ACTIVATE DIALOG oDlg

cCliente    := aCliente[nCli]
cTmpCliente := cCliente
SetText(oClienteLb, cTmpCliente)

//Busca o traslado padrão do cliente selecionado
dbSelectArea("SA1")
dbSetOrder(2)
dbSeek(cCliente)
If SA1->(Found())
	cTraslado := SA1->A1_TMPSTD
	SetText(oTrasladoTx, cTraslado)
EndIf  

Return nil


Function PgUpCli(aCliente, nCli, oLbx, nTop)

Local nRec := SA1->(Recno()), nCargaMax := GetListRows(oLbx)

SA1->(dbGoTop())
If SA1->(Recno()) == nTop
	return
EndIf
SA1->(dbGoTo(nTop))
SA1->(dbSkip(-nCargaMax))
nTop := SA1->(Recno())
ListaCli(@nTop, aCliente, nCli, oLbx)

Return nil


Function PgDnCli(aCliente, nCli, oLbx, nTop)

Local nRec := SA1->(Recno()), nCargaMax := GetListRows(oLbx)

SA1->(dbGoTo(nTop))
SA1->(dbSkip(nCargaMax))
If !Eof()
   nTop := SA1->(Recno())
   ListaCli(@nTop, aCliente, nCli, oLbx)
Else
   SA1->(dbGoTo(nRec))
EndIf

Return nil


Function PesquisaCliente(cPesquisa, oClienteLb, oPesquisaTx, oLbx, aCliente, nCli, nTop, aCons, nCons)

Local nRec := 0, i := 1, cTipoCons := Substr(aCons[nCons],1,1)
Local nCargaMax := GetListRows(oLbx)

If cTipoCons == "D" //descricao
	cPesquisa := Upper(cPesquisa)
	dbSelectArea("SA1")
	dbSetOrder(2)
	dbSeek(cPesquisa)
Else				//codigo
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(cPesquisa)	
EndIf

If SA1->(Found())      
	nRec := SA1->(Recno())
	cPesquisa := SA1->A1_NOME
	//SetText(oPesquisaTx, cPesquisa)
	If cTipoCons == "C"
		SA1->(dbSetOrder(2))
		dbSeek(cPesquisa)
		nRec := SA1->(Recno())
	EndIf
	
	dbGoTo(nRec)
	aSize(aCliente,0)
	For i := 1 to nCargaMax
		aAdd(aCliente, Alltrim(SA1->A1_NOME))
		dbSkip()
		If Eof()
		   break
		EndIf
	Next
	
	nTop := nRec // Atualiza nTop com a posicao localizada na tabela
	SetArray(oLbx, aCliente)
Else
	MsgAlert(STR0009,STR0007) //"Cliente nao encontrado!"###"Aviso"
	cPesquisa := ""
EndIf

Return nil