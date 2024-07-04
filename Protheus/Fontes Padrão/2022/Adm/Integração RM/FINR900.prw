#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINR900.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFinrRM01  บAutor  ณCesar A. Bianchi    บ Data ณ  30/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a impressao do relatorio de Posicao Financeira do   บฑฑ
ฑฑบ          ณAluno/Cliente selecionado.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso		 ณ Integracao Protheus x Classis Net                          ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se InPosRel 						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function FinrRM01()
Local cCod    := alltrim(TRB->CODIGO)
Local cNome	  := alltrim(TRB->NOME)
Local cEnd	  := ""
Local cCPF	  := ""
Local aArea	  := getArea()
Local cTitulo := STR0001 //"Relแtorio de Posi็ใo Financeira"
Private m_pag   := 01  
Private aReturn :=  {"Zebrado", 1, "Administracao", 2, 2, 1,"",1}
Private cPerg2  := "INPFI2"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExibe interface do tipo "Pergunte"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Pergunte(cPerg2,.F.)
wnrel := SetPrint('SE1',cPerg2,cPerg2,@cTitulo,"","","",.F.,{},.F.,"G",,.F.,.F.,,,.F.,'COM1')
	
If nLastKey == 27
	Set Filter To
	Return
EndIf
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณImprime o relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SetDefault(aReturn,'SE1')
RptStatus({|lEnd| FnrPosStp(mv_par01,cCod,cNome,cEnd,cCpf)},cTitulo)

RestArea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFnrPosStp บAutor  ณCesar A. Bianchi    บ Data ณ  01/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o relatorio tipo "Set Print" - Posicao Financeira     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso		 ณ Integracao Protheus x Classis Net                          ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se InPosStp 						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function FnrPosStp(nOpcx,cCod,cNome,cEnd,cCpf)
Local Col  	 := 3
Local Lin  	 := 6
Local cQuery := ""
Local cColuns:= STR0002 //"PREFIXO     NUM      PARC    TIPO    VENCTO    VALOR    VLRPAGO   DESC   MULTA"
Local cFilImp:= ""
Local cTotTit := Space(10)
Local cTotAtr := Space(10)
Local cTotAbr := Space(10)
Local cTotBx  := Space(10)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine qual o filtro de titulosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	Case nOpcx == 1
		cFilImp := STR0003 //"Todos os tํtulos."	
	Case nOpcx == 2
		cFilImp := STR0004 //"Em Atraso."
	Case nOpcx == 3
		cFilImp := STR0005 //"Em Aberto."
	Case nOpcx == 4
		cFilImp := STR0006 //"Baixados."	
End Case

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณImprime o primeiro cabecalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Cabec(STR0007,'','',cPerg2,"P",15) //POSICAO FINANCEIRA

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณImprime informacoes do aluno.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ 6,Col PSAY iif(lPesqAlu,STR0008,STR0009) + alltrim(UPPER(cCod))
@ 7,Col PSAY STR0010 + alltrim(upper(cNome)) //"Nome: "
@ 8,Col PSAY STR0011 + alltrim(upper(cEnd)) //"Endere็o: "
@ 9,Col PSAY iif(lPesqAlu,STR0012,STR0013) + alltrim(UPPER(CCpf)) //"Resp. Financeiro: " /CPF
@ 10,Col PSAY STR0014 + upper(cFilImp) //"Imprimir tํtulos: " 
@ 11,Col PSAY __PrtThinLine()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณImprime o primeiro sub-cabecalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ 13,Col-2 PSAY cColuns
@ 14,Col PSAY __PrtThinLine()
Lin := 15

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSeleciona os titulos a serem impressosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery := " SELECT SE1.E1_PREFIXO PREFIXO, SE1.E1_NUM NUM, "
cQuery += " SE1.E1_PARCELA PARCELA, SE1.E1_TIPO TIPO, SE1.E1_VENCTO VEN, "
cQuery += " SE1.E1_VALOR VALOR, (SE1.E1_VALOR - SE1.E1_SALDO) VLRPAGO, SE1.E1_DESCONT DES, SE1.E1_MULTA MUL FROM " 
cQuery += retsqlname('SE1') + " SE1 "
cQuery += " WHERE SE1.E1_FILIAL = '" + xFilial('SE1') + "'"
if lPesqAlu
	cQuery += " AND SE1.E1_NUMRA = '" + TRB->CODIGO + "'"
else
	cQuery += " AND SE1.E1_CLIENTE = '" + TRB->CODIGO + "'"
endif	
if nOpcx == 2
	cQuery += " AND SE1.E1_VENCTO <= '" + dtos(dDataBase) + "'"
	cQuery += " AND SE1.E1_STATUS = 'A' "
elseif nOpcx == 3
	cQuery += " AND SE1.E1_STATUS = 'A' "
elseif nOpcx == 4
	cQuery += " AND SE1.E1_STATUS = 'B' "
endif
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY SE1.E1_VENCTO ASC, SE1.E1_NUM ASC, SE1.E1_PARCELA ASC "
cQuery := ChangeQuery(cQuery)
iif(Select('TCQ')>0,TCQ->(dbCloseArea()),Nil)
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "TCQ", .F., .F. )  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณImprime os titulos selecionadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While TCQ->(!Eof())
	//Calcula salto de pagina
	if Lin > 58
		Cabec(STR0007,'','',cPerg2,"P",15) //"POSIวรO FINANCEIRA"
		@ 6,Col-2 PSAY cColuns
		@ 7,Col PSAY __PrtThinLine()
		@ 9,Col PSAY __PrtThinLine()
		Lin  := 10		
	endif

	//Imprime os dados
	@ Lin,Col    PSAY alltrim(TCQ->PREFIXO)  	+ replicate(" ",6-len(alltrim(TCQ->PREFIXO)))
	@ Lin,Col+7  PSAY alltrim(TCQ->NUM)      	+ replicate(" ",10-len(alltrim(TCQ->NUM)))
	@ Lin,Col+20 PSAY alltrim(TCQ->PARCELA) 	+ replicate(" ",4-len(alltrim(TCQ->PARCELA)))
	@ Lin,Col+28 PSAY alltrim(TCQ->TIPO)    	+ replicate(" ",6-len(alltrim(TCQ->TIPO)))
	@ Lin,Col+34 PSAY dtoc(stod(TCQ->VEN))   	+ replicate(" ",16-len(dtoc(stod(TCQ->TIPO))))
	@ Lin,Col+46 PSAY replicate(" ",5 - len(alltrim(Transform(TCQ->VALOR	,"@E 999,999.99")))) + alltrim(Transform(TCQ->VALOR	,"@E 999,999.99"))
	@ Lin,Col+56 PSAY replicate(" ",5 - len(alltrim(Transform(TCQ->VLRPAGO	,"@E 999,999.99")))) + alltrim(Transform(TCQ->VLRPAGO	,"@E 999,999.99"))
	@ Lin,Col+64 PSAY replicate(" ",5 - len(alltrim(Transform(TCQ->DES		,"@E 999,999.99")))) + alltrim(Transform(TCQ->DES		,"@E 999,999.99"))
	@ Lin,Col+72 PSAY replicate(" ",5 - len(alltrim(Transform(TCQ->MUL		,"@E 999,999.99")))) + alltrim(Transform(TCQ->MUL		,"@E 999,999.99"))
    Lin++
	@ Lin,Col PSAY __PrtThinLine()
    Lin++
    
    //Proximo titulo
	TCQ->(dbSkip())
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณImprime o subtotalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if Lin > 58
	//Controle de cabecalho
	Cabec(STR0007,'','',cPerg2,"P",15) //"POSIวรO FINANCEIRA"
	Lin  := 10		
endif
	
@ Lin++ ,Col+20  PSAY STR0015// "Subtotais" 
@ Lin++ ,Col+40  PSAY STR0016 + Replicate(" ",10 - len(cTotTit)) + cTotTit //"Total Titulos:   " 
@ Lin++ ,Col+40  PSAY STR0017 + Replicate(" ",10 - len(cTotAtr)) + cTotAtr //"Total em Atraso: "
@ Lin++ ,Col+40  PSAY STR0018 + Replicate(" ",10 - len(cTotAbr)) + cTotAbr //"Total em Aberto: "
@ Lin++ ,Col+40  PSAY STR0019 + Replicate(" ",10 - len(cTotBx)) +  cTotBx //"Total Baixado:   "'
@ Lin++ ,Col PSAY __PrtThinLine()


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExibe o relatorio em tela caso a impressao seja em discoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5] = 1
   	Set Device to Screen
   	Set Printer To 
   	dbCommitAll()
   	OurSpool(wnrel)
Endif

Ms_Flush()
Return
