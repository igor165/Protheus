#INCLUDE "TFA11.ch"
#include "eADVPL.ch"

/*************************************** DETALHES *****************************************/
Function Detalhes(cOS, cNrItem, aOS)

Local oDlg, oSay, oGet, oRetornarBt	//oOcorr, oProd 
Local cOcorr := space(10), cProduto := space(10), cNrSerie := space(10)
Local cDescrProduto := space(20), cDescrOcorr := space(20), cNrOS := cOS
Local cObserv := space(20)

If Len(aOS) == 0
	return nil	
Endif         

MsgStatus(STR0001) //"Por favor, aguarde..."

dbSelectArea("AB7")
dbSetOrder(1)
dbSeek(cNrOS + cNrItem)

If AB7->(Found())
	cOcorr   := AB7->AB7_CODPRB
	cProduto := AB7->AB7_CODPRO
	cNrSerie := AB7->AB7_NUMSER
	cObserv  := Alltrim(AB7->AB7_MEMO2)
	
	dbSelectArea("AAG")
	dbSetOrder(1)
	dbSeek(cOcorr)
	If AAG->(Found())
		cDescrOcorr := AAG->AAG_DESCRI
	EndIf	
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(cProduto)
	If SB1->(Found())
		cDescrProduto := SB1->B1_DESC
	EndIf
EndIf

DEFINE DIALOG oDlg TITLE STR0002 //"Detalhes"

@ 20,02 SAY oSay PROMPT STR0003 BOLD of oDlg //"Ocorrência:"
@ 20,63 GET oGet VAR cOcorr READONLY NO UNDERLINE of oDlg
@ 35,02 GET oGet VAR cDescrOcorr READONLY NO UNDERLINE of oDlg //oOcorr
@ 50,02 SAY oSay PROMPT STR0004 BOLD of oDlg //"Produto:"
@ 50,63 GET oGet VAR cProduto READONLY NO UNDERLINE of oDlg
@ 65,02 GET oGet VAR cDescrProduto READONLY NO UNDERLINE of oDlg //oProd
@ 80,02 SAY oSay PROMPT STR0005 BOLD of oDlg //"Nr. de Série:"
@ 80,63 GET oGet VAR cNrSerie READONLY NO UNDERLINE of oDlg
@ 95,02 SAY oSay PROMPT "Obs. da Ocorr.:" BOLD of oDlg
@ 110,02 GET oGet VAR cObserv MULTILINE READONLY NO UNDERLINE SIZE 155,30 of oDlg

@ 145,50 BUTTON oRetornarBt CAPTION STR0006 SIZE 60,12 ACTION CloseDialog() of oDlg //"Retornar"
ClearStatus()

ACTIVATE DIALOG oDlg

Return nil


/*********************************** REQUISICOES ****************************************/
Function Requisicoes(cOS, cNrItem, aOS)

Local oDlg, oBrwReq, oGet, oSay, oIncluirBt, oAlterarBt, oExcluirBt, oSairBt
Local oItemOSTx, oSeqTx
Local cSeq := "01", nReq := 1, aReq := {}
Local cTmpOS := cOS, cItemOS := cNrItem

If Len(aOS) == 0
	return nil
Endif

MsgStatus(STR0001) //"Por favor, aguarde..."

SET DELE ON

DEFINE DIALOG oDlg TITLE STR0007 //"Requisições"

@ 20,02 SAY oSay PROMPT STR0008 BOLD of oDlg //"O.S.: "
@ 20,27 GET oGet VAR cTmpOS READONLY NO UNDERLINE of oDlg
@ 20,70 SAY oSay PROMPT STR0009 BOLD of oDlg //"Item da OS: "
@ 20,130 GET oItemOSTx VAR cItemOS READONLY NO UNDERLINE of oDlg
@ 33,02 SAY oSay PROMPT STR0010 of oDlg //"Seq. Solicit.: "
#ifdef __PALM__
	@ 33,55 GET oSeqTx VAR cSeq of oDlg
#else      
	cSeq := "01 "
	@ 33,55 GET oSeqTx VAR cSeq of oDlg
#endif

//@ 45,02 LISTBOX oLbx VAR nReq ITEMS aReq SIZE 152,45 ACTION SelectReq(aReq, nReq, cTmpOS, cItemOS, oItemReqTx, oProdutoTx, oQtdTx, oServico) Of oDlg
@ 45,02 BROWSE oBrwReq SIZE 152,65 OF oDlg
SET BROWSE oBrwReq ARRAY aReq
ADD COLUMN oCol TO oBrwReq ARRAY ELEMENT 1 HEADER STR0011 WIDTH 30 //"Item"
ADD COLUMN oCol TO oBrwReq ARRAY ELEMENT 2 HEADER STR0012 WIDTH 95 //"Produto"
ADD COLUMN oCol TO oBrwReq ARRAY ELEMENT 3 HEADER STR0013 WIDTH 30 //"Qtde"

@ 120,02 BUTTON oIncluirBt CAPTION STR0014 SIZE 40,12  ACTION ManutReq(1,aReq,cTmpOS,cItemOS,cSeq,oBrwReq) Of oDlg //"Incluir"
@ 120,60 BUTTON oAlterarBt CAPTION STR0015 SIZE 40,12  ACTION ManutReq(2,aReq,cTmpOS,cItemOS,cSeq,oBrwReq) Of oDlg //"Alterar"
@ 120,120 BUTTON oExcluirBt CAPTION STR0016 SIZE 35,12 ACTION ExcluiReq(oBrwReq,aReq,cTmpOS,cItemOS) Of oDlg //"Excluir"

#ifdef __PALM__
	@ 140,02 BUTTON oSairBt  CAPTION STR0017 SIZE 40,12 ACTION CloseDialog() of oDlg //"Sair"
#else
	@ 140,02 BUTTON oSairBt  CAPTION STR0017 SIZE 40,12 ACTION CloseDialog() of oDlg //"Sair"
#endif

ListarReq(aReq, cTmpOS, cItemOS, oBrwReq)
//SelectReq(aReq, nReq, cTmpOS, cItemOS, oBrwReq)
ClearStatus()

ACTIVATE DIALOG oDlg

Return nil


Function ManutReq(nOpcao,aReq,cTmpOS,cItemOS,cSeq,oBrwReq)

Local cTmpReq := "",cItemReq := space(03), nQtd := 0, aServ := {}, nServ := 1
Local oDlg, oSay, oItemReqTx, oQtdTx, oServico, oGravarBt, oProdBt, oQtdeBt
Local cProduto := space(20), oProdutoTx, nItemReq := 0
Local aCmpPrd:={}, aIndPrd:={}

MsgStatus(STR0001) //"Por favor, aguarde..."

//Consulta Padrao de Produtos
Aadd(aCmpPrd,{STR0018,SB1->(FieldPos("B1_COD")),60}) //"Código"
Aadd(aCmpPrd,{STR0019,SB1->(FieldPos("B1_DESC")),90}) //"Descrição"
Aadd(aIndPrd,{STR0018,1}) //"Código"
Aadd(aIndPrd,{STR0019,2}) //"Descrição"

dbSelectArea("AA5")
dbgotop()
dbSetOrder(2)
While !Eof()
	aAdd(aServ, AllTrim(AA5->AA5_DESCRI))
	dbSkip()
EndDo

ClearStatus()

If nOpcao == 1
	nItemReq := Len(aReq)               
	If Len(aReq) > 0
		cItemReq := aReq[nItemReq,1]
	Else
		cItemReq := "00"
	Endif
	cItemReq := StrZero(Val(cItemReq)+1, 2)
	DEFINE DIALOG oDlg TITLE STR0020 //"Incluir Req."
Else        
	If Len(aReq) == 0
		MsgStop(STR0021,STR0022) //"Nenhum item selecionado!"###"Atenção"
		return nil
	endif
	nItemReq := GridRow(oBrwReq)
	cItemReq := aReq[nItemReq,1]
	dbSelectArea("ABG")
	dbSetOrder(1)
	dbSeek(cTmpOS + cItemOS + cItemReq)
	If ABG->(Found())
		cProduto := ABG->ABG_CODPRO
		nQtd     := ABG->ABG_QUANT
	Endif
	DEFINE DIALOG oDlg TITLE STR0023 //"Alterar Req."
Endif

@ 20,02 SAY oSay PROMPT STR0024 of oDlg //"Item: "
#ifdef __PALM__
	@ 20,35 GET oItemReqTx VAR cItemReq READONLY of oDlg
#else                                                    
	cItemReq := space(5)
	@ 20,35 GET oItemReqTx VAR cItemReq READONLY of oDlg
#endif

@ 40,02 BUTTON oProdBt CAPTION STR0025 SIZE 30,12 ACTION SFConsPadrao("SB1",cProduto,oProdutoTx,aCmpPrd,aIndPrd,) of oDlg //"Prod.:"
//ConsProduto(cProduto, oProdutoTx, oProdAntTx, .f.)
@ 40,35 GET oProdutoTx VAR cProduto READONLY of oDlg
@ 60,02 BUTTON oQtdeBt CAPTION STR0026 SIZE 30,12 ACTION Keyb_Num(oQtdTx) of oDlg //"Qtde:"
#ifdef __PALM__
	@ 60,35 GET oQtdTx VAR nQtd SIZE 25,20 of oDlg
	@ 80,02 SAY oSay PROMPT STR0027 of oDlg //"Serviço: "
	@ 80,35 COMBOBOX oServico VAR nServ ITEMS aServ SIZE 80,45 of oDlg	
#else
	@ 60,35 GET oQtdTx VAR nQtd /*SIZE 25,13*/ of oDlg
	@ 80,02 SAY oSay PROMPT STR0027 of oDlg //"Serviço: "
	@ 80,35 COMBOBOX oServico VAR nServ ITEMS aServ SIZE 80,45 of oDlg
#endif

@ 130,30 BUTTON oGravarBt CAPTION STR0028 SIZE 40,12 ACTION GravaReq(nOpcao, cTmpOS, cItemOS, cSeq, cItemReq, cProduto, nQtd, aServ[nServ], aReq, oBrwReq) of oDlg //"Gravar"
@ 130,90 BUTTON oCancelBt CAPTION STR0029 SIZE 40,12 ACTION CloseDialog() of oDlg //"Cancelar"

ACTIVATE DIALOG oDlg

Return nil


//Function ListarReq(aReq, nReq, cTmpOS, cItemOS, nItemReq, oLbx)
Function ListarReq(aReq, cTmpOS, cItemOS, oBrwReq)

dbSelectArea("ABG")
dbSetOrder(1)
dbGoTop()

aSize(aReq,0)
While !Eof()
	If ABG->ABG_NUMOS == cTmpOS .And. ABG->ABG_ITEMOS == cItemOS
		aAdd(aReq, {ABG->ABG_ITEM , ABG->ABG_DESCRI , ABG->ABG_QUANT })
	EndIf	
	dbSkip()	
Enddo

SetArray(oBrwReq, aReq)

Return nil