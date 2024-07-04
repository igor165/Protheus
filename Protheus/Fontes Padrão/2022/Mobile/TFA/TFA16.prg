#INCLUDE "TFA16.ch"
#include "eADVPL.ch"

//Carrega clientes no listbox de acordo com o botao pressionado (PgUp ou PgDn)
Function ListaCli(nTop, aCliente, nCli, oLbx)

Local i := 0, nCargaMax := GetListRows(oLbx)

dbSelectArea("SA1")
dbSetOrder(2)

if Len(aCliente) > 0 
   dbGoTo(nTop)
else
   dbGoTop()
endif                       

aSize(aCliente,0)

For i := 1 to nCargaMax
	aAdd(aCliente, Alltrim(SA1->A1_NOME))
	dbSkip()
	If Eof()
	   break
	EndIf
Next

If (oLbx != nil)
	SetArray(oLbx, aCliente)
EndIf

Return nil


//****************************** Consulta de Fabricantes ***********************************
Function ConsFabric(cFabric, oFabricTx)

Local oDlg, oLbx, oPesquisaBt, oPesquisaTx, oRetornaBt, oProximoBt, oAnteriorBt, oConsCbx
Local nFabric := 1, aFabric := {}, cPesquisa := space(30)
Local i := 0, nTop := 0, cTmpFabric := space(20)
Local aCons := {}, nCons := 1                        

aadd(aCons,"Código")
aadd(aCons,"Descrição")
	   
dbSelectArea("SA2")
dbSetOrder(2)
dbGoTop()
nTop := SA2->(Recno())

/*While !Eof() .And. i < 10
	aAdd(aFabric, Alltrim(SA2->A2_NREDUZ))
	dbSkip()
	i := i + 1
Enddo */

DEFINE DIALOG oDlg TITLE STR0001 //"Selecione um Fabricante"

@ 18,02 LISTBOX oLbx VAR nFabric ITEMS aFabric SIZE 139,115 of oDlg

#ifdef __PALM__
	@ 130,02 GET oPesquisaTx VAR cPesquisa of oDlg
	@ 145,60 BUTTON oPesquisaBt CAPTION STR0002 SIZE 40,12 ACTION PesquisaFabric(cPesquisa, oFabricTx, oPesquisaTx, oLbx, aFabric, nFabric, nTop, aCons, nCons) of oDlg //"Pesquisar"
	@ 145,110 BUTTON oRetornaBt CAPTION STR0003 SIZE 40,12 ACTION CloseDialog() of oDlg //"Retornar"
#else
	cPesquisa := space(45)
	@ 130,02 GET oPesquisaTx VAR cPesquisa of oDlg
	@ 145,60 BUTTON oPesquisaBt CAPTION STR0002 SIZE 43,12 ACTION PesquisaFabric(cPesquisa, oFabricTx, oPesquisaTx, oLbx, aFabric, nFabric, nTop, aCons, nCons) of oDlg //"Pesquisar"
	@ 145,110 BUTTON oRetornaBt CAPTION STR0003 SIZE 43,12 ACTION CloseDialog() of oDlg //"Retornar"
#endif
ListaFabric(nTop, aFabric, nFabric, oLbx)

@ 145,02 COMBOBOX oConsCbx VAR nCons ITEMS aCons SIZE 50,30 of oDlg
@ 18,145 BUTTON oAnteriorBt CAPTION Chr(5) SYMBOL SIZE 10,12 ACTION PgUpFabr(aFabric, nFabric, oLbx, nTop) of oDlg
@ 115,145 BUTTON oProximoBt CAPTION Chr(6) SYMBOL SIZE 10,12 ACTION PgDnFabr(aFabric, nFabric, oLbx, nTop) of oDlg

ACTIVATE DIALOG oDlg

cFabric         := aFabric[nFabric]
cTmpFabric      := cFabric

SetText(oFabricTx, cTmpFabric)

dbSelectArea("SA2")
dbSetOrder(2)
dbSeek(cFabric)

If SA2->(Found())
	cFabric := SA2->A2_COD + SA2->A2_LOJA
EndIf

Return nil
	

Function PgUpFabr(aFabric, nFabric, oLbx, nTop)

Local nRec := SA2->(Recno()), nCargaMax := GetListRows(oLbx)

SA2->(dbGoTop())
If SA2->(Recno()) == nTop
	return
EndIf
SA2->(dbGoTo(nTop))
SA2->(dbSkip(-nCargaMax))
nTop := SA2->(Recno())
ListaFabric(@nTop, aFabric, nFabric, oLbx)

Return nil
	

Function PgDnFabr(aFabric, nFabric, oLbx, nTop)

Local nRec := SA2->(Recno()), nCargaMax := GetListRows(oLbx)

SA2->(dbGoTo(nTop))
SA2->(dbSkip(nCargaMax))
If !Eof()
   nTop := SA2->(Recno())
   ListaFabric(@nTop, aFabric, nFabric, oLbx)
Else
   SA2->(dbGoTo(nRec))
EndIf

Return nil


// Pesquisa pela(s) letra(s) inicial(is) ou pelo cod. do fabricante
Function PesquisaFabric(cPesquisa, oFabricTx, oPesquisaTx, oLbx, aFabric, nFabric, nTop, aCons, nCons)

Local nRec := 0, i := 1, cTipoCons := Substr(aCons[nCons],1,1)
Local nCargaMax := GetListRows(oLbx)

If cTipoCons == "D"			//descricao
	cPesquisa := Upper(cPesquisa)
	dbSelectArea("SA2")
	dbSetOrder(2)
	dbSeek(cPesquisa)  
Else						//codigo
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(cPesquisa)  
EndIf

If SA2->(Found())
	nRec := SA2->(Recno())
	cPesquisa := SA2->A2_NREDUZ
	//SetText(oPesquisaTx, cPesquisa)
	If cTipoCons == "C"
		SA2->(dbSetOrder(2))
		dbSeek(cPesquisa)
		nRec := SA2->(Recno())
	EndIf

	dbGoTo(nRec)
	aSize(aFabric,0)
	For i := 1 to nCargaMax
		aAdd(aFabric, Alltrim(SA2->A2_NREDUZ))
		dbSkip()
		If Eof()
		   break
		EndIf
	Next
	
	nTop := nRec // Atualiza nTop com a posicao localizada na tabela
	SetArray(oLbx, aFabric)
Else
	MsgAlert(STR0004,STR0005) //"Fabric. nao encontrado!"###"Aviso"
	cPesquisa := ""
EndIf

Return nil


//Lista fabricantes de acordo c/ o botao pressionado (PgUp ou PgDn)
Function ListaFabric(nTop, aFabric, nFabric, oLbx)

Local i := 0, nCargaMax := GetListRows(oLbx)

dbSelectArea("SA2")
dbSetOrder(2)

If Len(aFabric) > 0 
   dbGoTo(nTop)
Else
   dbGoTop()
EndIf                       

//Alert("Recno: " + str(nTop))
aSize(aFabric,0)
For i := 1 to nCargaMax
	aAdd(aFabric, Alltrim(SA2->A2_NREDUZ))
	dbSkip()
	If Eof()
	   break
	EndIf
Next

If (oLbx != nil)
	SetArray(oLbx, aFabric)
EndIf

Return nil                                              


//**************************** Consulta a lista de Ocorrencias *****************************
Function ConsOcorrencia(cOcorrencia, oOcorrLb)

Local oDlg, oLbx, oPesquisaBt, oPesquisaTx, oRetornaBt, oProximoBt, oAnteriorBt, oConsCbx
Local nOcorr := 1, aOcorr := {}, cPesquisa := space(30), i := 0, nTop := 0, cTmpOcorr := ""
Local aCons := {}, nCons := 1                        

aadd(aCons,"Código")
aadd(aCons,"Descrição")

dbSelectArea("AAG")
dbSetOrder(2)
dbGoTop()
nTop := AAG->(Recno())

/*While !Eof() .And. i < 10
	aAdd(aOcorr, Alltrim(AAG->AAG_DESCRI))
	dbSkip()             
	i := i + 1
Enddo */

DEFINE DIALOG oDlg TITLE STR0006 //"Selecione uma Ocorrencia"

@ 18,02 LISTBOX oLbx VAR nOcorr ITEMS aOcorr SIZE 139,115 of oDlg
#ifdef __PALM__
	@ 130,02 GET oPesquisaTx VAR cPesquisa of oDlg
	@ 145,60 BUTTON oPesquisaBt CAPTION STR0002 SIZE 40,12 ACTION PesquisaOcorr(cPesquisa, oOcorrLb, oPesquisaTx, oLbx, aOcorr, nOcorr, nTop, aCons, nCons) of oDlg //"Pesquisar"
	@ 145,110 BUTTON oRetornaBt CAPTION STR0003 SIZE 40,12 ACTION CloseDialog() of oDlg //"Retornar"
#else
	cPesquisa := space(45)
	@ 130,02 GET oPesquisaTx VAR cPesquisa of oDlg
	@ 145,60 BUTTON oPesquisaBt CAPTION STR0002 SIZE 43,12 ACTION PesquisaOcorr(cPesquisa, oOcorrLb, oPesquisaTx, oLbx, aOcorr, nOcorr, nTop, aCons, nCons) of oDlg //"Pesquisar"
	@ 145,110 BUTTON oRetornaBt CAPTION STR0003 SIZE 43,12 ACTION CloseDialog() of oDlg //"Retornar"
#endif
ListaOcorr(nTop, aOcorr, nOcorr, oLbx)

@ 145,02 COMBOBOX oConsCbx VAR nCons ITEMS aCons SIZE 50,30 of oDlg
@ 18,145 BUTTON oAnteriorBt CAPTION Chr(5) SYMBOL SIZE 10,12 ACTION PgUpOcorr(aOcorr, nOcorr, oLbx, nTop) of oDlg
@ 115,145 BUTTON oProximoBt CAPTION Chr(6) SYMBOL SIZE 10,12 ACTION PgDnOcorr(aOcorr, nOcorr, oLbx, nTop) of oDlg

ACTIVATE DIALOG oDlg

cOcorrencia := aOcorr[nOcorr]
cTmpOcorr   := cOcorrencia
SetText(oOcorrLb, cTmpOcorr)

Return nil


Function PgUpOcorr(aOcorr, nOcorr, oLbx, nTop)

Local nRec := AAG->(Recno()), nCargaMax := GetListRows(oLbx)

AAG->(dbGoTop())
If AAG->(Recno()) == nTop
	return
EndIf
AAG->(dbGoTo(nTop))
AAG->(dbSkip(-nCargaMax))
nTop := AAG->(Recno())
ListaOcorr(@nTop, aOcorr, nOcorr, oLbx)

Return nil


Function PgDnOcorr(aOcorr, nOcorr, oLbx, nTop)

Local nRec := AAG->(Recno()), nCargaMax := GetListRows(oLbx)

AAG->(dbGoTo(nTop))
AAG->(dbSkip(nCargaMax))
If !Eof()
   nTop := AAG->(Recno())
   ListaOcorr(@nTop, aOcorr, nOcorr, oLbx)
Else
   AAG->(dbGoTo(nRec))
EndIf

Return nil


//Pesquisa pela(s) letra(s) inicial(is) ou pelo cod. da ocorrencia
Function PesquisaOcorr(cPesquisa, oOcorrLb, oPesquisaTx, oLbx, aOcorr, nOcorr, nTop, aCons, nCons)

Local nRec := 0, i := 1, cTipoCons := Substr(aCons[nCons],1,1) 
Local nCargaMax := GetListRows(oLbx)

If cTipoCons == "D"
	cPesquisa := Upper(cPesquisa)
	dbSelectArea("AAG")
	dbSetOrder(2)
	dbSeek(cPesquisa)  
Else
	dbSelectArea("AAG")
	dbSetOrder(1)
	dbSeek(cPesquisa)  
EndIf

If AAG->(Found())
	nRec := AAG->(Recno())
	cPesquisa := AAG->AAG_DESCRI
	//SetText(oPesquisaTx, cPesquisa)
	If cTipoCons == "C"
		AAG->(dbSetOrder(2))
		dbSeek(cPesquisa)
		nRec := AAG->(Recno())
	EndIf
	
	dbGoTo(nRec)
	aSize(aOcorr,0)
	For i := 1 to nCargaMax
		aAdd(aOcorr, Alltrim(AAG->AAG_DESCRI))
		dbSkip()
		If Eof()
		   break
		EndIf
	Next
	
	nTop := nRec // Atualiza nTop com a posicao localizada na tabela
	SetArray(oLbx, aOcorr)
Else
	MsgAlert(STR0007,STR0005) //"Ocorrencia nao encontrada!"###"Aviso"
	cPesquisa := ""
EndIf

Return nil              


//Carrega ocorrencias no listbox de acordo com o botao pressionado (PgUp ou PgDn)
Function ListaOcorr(nTop, aOcorr, nOcorr, oLbx)

Local i := 0, nCargaMax := GetListRows(oLbx)

dbSelectArea("AAG")
dbSetOrder(2)

if Len(aOcorr) > 0 
   dbGoTo(nTop)
else
   dbGoTop()
endif                       

aSize(aOcorr,0)
For i := 1 to nCargaMax
	aAdd(aOcorr, Alltrim(AAG->AAG_DESCRI))
	dbSkip()
	If Eof()
	   break
	EndIf
Next

If (oLbx != nil)
	SetArray(oLbx, aOcorr)
EndIf

Return nil                                             