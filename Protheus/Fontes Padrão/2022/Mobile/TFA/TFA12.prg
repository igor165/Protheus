#INCLUDE "TFA12.ch"
#include "eADVPL.ch"

//Function GravaReq(cTmpOS, cItemOS, cSeq, cItemReq, cProduto, nQtd, aServ, aReq, nReq, nItemReq, oLbx, oItemReqTx, oProdutoTx, oQtdTx, oServico)
Function GravaReq(nOpcao, cTmpOS, cItemOS, cSeq, cItemReq, cProduto, nQtd, cServ, aReq, oBrwReq)

//Guarda descricao do produto, cod. do tecnico e codigo de servico
Local cDescrProd := "", cCodTec := "", cCodServ := "", nLinha := 0
//cEmissao := ""

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(cProduto)
If SB1->(Found())
	cDescrProd := SB1->B1_DESC
EndIf                         

dbSelectArea("AA5")
dbSetOrder(2)
dbSeek(cServ)
If AA5->(Found())
	cCodServ := AA5->AA5_CODSER   	
EndIf

dbSelectArea("AA1")
cCodTec := AA1->AA1_CODTEC

//Validacao dos campos em branco
If Empty(cItemOS)
	MsgStop(STR0001,STR0002) //"Campo Item de OS em branco"###"Aviso"
	return nil
EndIf

If Empty(cSeq)
	MsgStop(STR0003,STR0002) //"Campo Seq. em branco"###"Aviso"
	return nil
EndIf

If Empty(cItemReq)
	MsgStop(STR0004,STR0002) //"Campo Item de Req. em branco"###"Aviso"
	return nil
EndIf

If Empty(cProduto)
	MsgStop(STR0005,STR0002) //"Campo Produto em branco"###"Aviso"
	return nil
EndIf            

If Empty(nQtd) .Or. nQtd <= 0
	MsgStop(STR0006,STR0002) //"Qtde inválida"###"Aviso"
	return nil
EndIf         

If Empty(cCodServ)
	MsgStop(STR0007,STR0002) //"Campo Serviço em branco"###"Aviso"
	return nil
EndIf

/* Grava o cabecalho da Requisicao (ABF) caso seja 
o primeiro item e a requisicao ainda nao tenha sido gravada */

//If cItemReq == "01"
If Len(aReq) == 0
	dbSelectArea("ABF")
	dbSetOrder(1)
	dbSeek(cTmpOS + cItemOS)
	If ABF->(!Found())   
		dbappend()
		ABF->ABF_EMISSA	:= strzero(year(date()),4) + strzero(month(date()),2) + strzero(day(date()),2)
		//cEmissao := ABF->ABF_EMISSA
		//Alert("Data emissao: " + cEmissao)
		ABF->ABF_NUMOS	:= cTmpOS
		ABF->ABF_ITEMOS	:= cItemOS
		ABF->ABF_SEQRC	:= cSeq
		ABF->ABF_CODTEC	:= cCodTec
		ABF->ABF_SOLIC	:= ""		
		dbcommit()
		//MsgAlert("Req. gravada c/ sucesso","Aviso")
	//Else
	//	MsgStop("Requisicao ja existente!","Aviso")
	EndIf	
EndIf

//Grava o item da requisicao
dbSelectArea("ABG")
dbSetOrder(1)
dbSeek(cTmpOS + cItemOS + cItemReq)

If ABG->(!Found()) //Inclusao
	dbappend()
	ABG->ABG_NUMOS	:= cTmpOS
	ABG->ABG_ITEMOS	:= cItemOS        
	ABG->ABG_ITEM	:= cItemReq	
	ABG->ABG_SEQRC	:= cSeq        
	ABG->ABG_CODPRO	:= cProduto     
	ABG->ABG_DESCRI	:= cDescrProd          
	ABG->ABG_QUANT	:= nQtd            
	ABG->ABG_CODSER	:= cCodServ
	ABG->ABG_CODTEC	:= cCodTec
	dbcommit()
    //Atualiza browse de requisicoes
	aAdd(aReq, {ABG->ABG_ITEM, ABG->ABG_DESCRI, ABG->ABG_QUANT})
	SetArray(oBrwReq, aReq)
Else  //Alteracao
	ABG->ABG_CODPRO	:= cProduto     
	ABG->ABG_DESCRI	:= cDescrProd          
	ABG->ABG_QUANT	:= nQtd            
	ABG->ABG_CODSER	:= cCodServ
	dbcommit()
	nLinha := GridRow(oBrwReq)
	aReq[nLinha,2] := ABG->ABG_DESCRI
	aReq[nLinha,3] := ABG->ABG_QUANT 	
	GridSetRow(oBrwReq,nLinha)
    //MsgStop("Registro ja existente!","Aviso")
EndIf
CloseDialog()    

Return nil


//Function ExcluiReq(aReq, nReq, cTmpOS, cItemOS, nItemReq, oLbx, oItemReqTx, oProdutoTx, oQtdTx, oServico, nQtd)
Function ExcluiReq(oBrwReq,aReq,cTmpOS,cItemOS)

Local cChave := "", nReq := GridRow(oBrwReq)

SET DELE ON

If len(aReq) == 0
	Return nil
EndIf

If nReq > 0 //.And. !Empty(aReq[nReq])                     
	cChave := cTmpOS + cItemOS + aReq[nReq,1]
	dbSelectArea("ABG")
	dbSetOrder(1)
	dbSeek(cChave)
	
	If ABG->(Found())
		//Perguntar se o usuario deseja realmente excluir... (OK)
		If MsgYesOrNo(STR0008 + aReq[nReq,1] + "?",STR0009) //"Deseja excluir o item "###"Atenção"
			dbDelete()        
			//PACK

			aDel(aReq,nReq)
			aSize(aReq,Len(aReq)-1)  
			SetArray(oBrwReq,aReq)				

			//Exclui o cabecalho da req. (ABF) quando nao houverem mais itens
			If Len(aReq) == 0
				//nItemReq := 0
				ExcluiCabec(cTmpOS, cItemOS)
			EndIf          
		EndIf

	EndIf

EndIf

Return nil
          

Function ExcluiCabec(cTmpOS, cItemOS)

Local cChave := cTmpOS + cItemOS

SET DELE ON

dbSelectArea("ABF")
dbSetOrder(1)
dbSeek(cChave)
If ABF->(Found())   
	dbDelete()
	//PACK      
EndIf

Return nil


Function SelectReq(aReq, nReq, cTmpOS, cItemOS, oItemReqTx, oProdutoTx, oQtdTx, oServico)

Local cChave := "" 		//Chave para pesquisa

If ( nReq <= Len(aReq) )
	cChave := cTmpOS + cItemOS + Substr(aReq[nReq],1,2)
	dbSelectArea("ABG")
	dbSetOrder(1)      
	dbGoTop()
	dbSeek(cChave)
	
	SetText(oItemReqTx,		ABG->ABG_ITEM)
	SetText(oProdutoTx,		ABG->ABG_DESCRI)
	SetText(oQtdTx,			ABG->ABG_QUANT)
	//SetText(oServico,		ABG->ABG_CODSER)
EndIf

Return nil


//Limpar campos da tela Requisicoes
Function LimpaReq(oItemReqTx, oProdutoTx, oQtdTx, oServico, nQtd)

SetText(oItemReqTx, Space(2))
SetText(oProdutoTx, Space(20))
nQtd := 0

#ifdef __PALM__
	SetText(oQtdTx,		str(nQtd))
#else
	SetText(oQtdTx,		nQtd)
#endif

Return nil


/************************************** PENDENCIAS ****************************************
Function Pendencias(cOS)

Local oSay, oGet, aPendencias := {}, nPend := 1, aStatus := {}, nStatus := 1, cDescricao := space(25)
Local oDlg, oGravarBt, oExcluirBt, oSairBt, oOcorrBt, oLbx, oStatus, oOcorrLb
Local cProd := space(06), cSerie := space(07), cOcorrencia := space(20), cNrOS := cOS

aAdd(aStatus, "1 = Pendente")
aAdd(aStatus, "2 = Baixado")

dbSelectArea("AB7")
dbSetIndex("IT1")
dbSetOrder(1)
dbSeek(cNrOS)

If AB7->(Found())
	cProd  := AB7->AB7_CODPRO
	cSerie := AB7->AB7_NUMSER
Else
	cProd  := Space(Len(AB7->AB7_CODPRO))
	cSerie := Space(Len(AB7->AB7_NUMSER))
EndIf

dbSelectArea("ABD")
dbSetOrder(1)
dbGoTop()

aSize(aPendencias,0)
While !Eof() 
	If ABD->ABD_CODPRO = Alltrim(cProd)
		aAdd(aPendencias, ABD->ABD_CODPRO + " - " + ABD->ABD_NUMSER)
	EndIf
	dbSkip()	
Enddo

DEFINE DIALOG oDlg TITLE "Pendências"

@ 18,02 SAY oSay PROMPT "Cód. Prod.:" Of oDlg
@ 18,45 GET oGet VAR cProd READONLY NO UNDERLINE of oDlg
@ 32,02 SAY oSay PROMPT "Nr. Série:" Of oDlg
@ 32,45 GET oGet VAR cSerie READONLY NO UNDERLINE of oDlg
@ 45,02 LISTBOX oLbx VAR nPend ITEMS aPendencias SIZE 150,45 Of oDlg

@ 110,02 SAY oSay PROMPT "Status:" Of oDlg
@ 110,40 COMBOBOX oStatus VAR nStatus ITEMS aStatus SIZE 80,30 Of oDlg
@ 127,02 BUTTON oOcorrBt CAPTION "Ocorr.:" SIZE 35,12 ACTION ConsOcorrencia(cOcorrencia, oOcorrLb) Of oDlg
@ 127,45 GET oOcorrLb VAR cOcorrencia of oDlg 
@ 142,02 SAY oSay PROMPT "Descr.:" of oDlg
@ 142,32 GET oGet VAR cDescricao of oDlg

@ 93,02 BUTTON oGravarBt CAPTION "Gravar" SIZE 35,12 ACTION GravaPend(cProd, cSerie, aStatus[nStatus], cOcorrencia, cDescricao, aPendencias, oLbx) Of oDlg
@ 93,60 BUTTON oExcluirBt CAPTION "Excluir" SIZE 35,12 ACTION ExcluiPend(aPendencias, nPend, oLbx, cProd, oOcorrLb, oGet) Of oDlg
@ 93,117 BUTTON oSairBt CAPTION "Sair" SIZE 35,12 ACTION CloseDialog() Of oDlg

ACTIVATE DIALOG oDlg

Return nil
       

Function GravaPend(cProd, cSerie, aStatus, cOcorrencia, cDescricao, aPendencias, oLbx)

Local cCodOcorr := ""

dbSelectArea("AAG")
dbSetOrder(2)
dbSeek(cOcorrencia)
If AAG->(Found())
	cCodOcorr := AAG->AAG_CODPRB
EndIf                           

dbSelectArea("ABD")
dbSetOrder(1)
dbSeek(cProd)
If ABD->(!Found())
	dbappend()
	ABD->ABD_CODPRO	:= cProd
	ABD->ABD_NUMSER	:= cSerie         
	ABD->ABD_STATUS	:= Substr(aStatus,1,1)
	ABD->ABD_MEMO1	:= ""
	ABD->ABD_CODPRB	:= cCodOcorr       
	ABD->ABD_DESCRI	:= cDescricao      
	ABD->ABD_DATA	:= Date()          
	dbcommit()
	aAdd(aPendencias, AllTrim(cProd) + " - " + Alltrim(cSerie))
	SetArray(oLbx, aPendencias)
Else
    MsgStop("Já existe pendencia p/ este produto!","Aviso")
EndIf

Return nil


Function ExcluiPend(aPendencias, nPend, oLbx, cProd, oOcorrLb, oGet)

Local cChave := Substr(aPendencias[nPend],1,6)

dbSelectArea("ABD")
dbSetOrder(1)
dbSeek(cChave)

If ABD->(Found())
	//Perguntar se o usuario deseja realmente excluir...
	If MsgYesOrNo("Confirma exclusão?","Atenção")
		dbDelete()        
		PACK
		SetText(oOcorrLb, space(20))
		SetText(oGet,	  space(20))
		ListarPend(aPendencias, nPend, oLbx, cProd)
  	EndIf
EndIf

Return nil


Function ListarPend(aPendencias, nPend, oLbx, cProd)

dbSelectArea("ABD")
dbSetOrder(1)
dbGoTop()

aSize(aPendencias,0)
While !Eof() 
	If ABD->ABD_CODPRO = Alltrim(cProd)
		aAdd(aPendencias, ABD->ABD_CODPRO + " - " + ABD->ABD_NUMSER)
	EndIf
	dbSkip()	
Enddo
SetArray(oLbx, aPendencias)

Return nil
*/