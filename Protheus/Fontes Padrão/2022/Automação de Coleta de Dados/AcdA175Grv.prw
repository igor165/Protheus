#include "rwmake.ch" 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º  Funcao  ³ CBA175GRV  º Autor ³ Anderson Rodrigues º Data ³Mon  16/09/02     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Acerto do CB0 no estorno do CQ via Protheus					  	 ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                        	 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CBA175GRV()
Local cEtiqueta
Local nX := 0
Local nRec := 0
Private aAreaSD1	:= SD1->(GetArea())
Private aAreaSD7	:= SD7->(GetArea())
Private cNumero		:= SD7->D7_NUMERO
Private cProduto	:= SD7->D7_PRODUTO
Private cLocal		:= SD7->D7_LOCAL
Private cItem		:= ""    
Private nQtdCB0 := 0

If !SuperGetMV("MV_CBPE003",.F.,.F.)
	Return
EndIf

If __cInternet == "AUTOMATICO"
	Return
Endif

If	!lEstorno
	AtuCB0()
	Return
Else

	If GetMV("MV_PDEVLOC") # 0
		AtuCB0()
		Return
	Endif

	autogrlog("Quantidade das etiquetas informadas ultrapassa a quantidade a ser estornada")
	autogrlog(Padr(OemToAnsi("Etiqueta"),20)+" "+;
				PadL(OemToAnsi("Quantidade"),20)+" "+;
				PadL(OemToAnsi("Total"),20))
	
	SD7->(DbSetOrder(2))
	SD7->(MsSeek(xFilial("SD7")+cNumero+cProduto+cLocal))
	While SD7->D7_NUMERO == cNumero .And. SD7->D7_PRODUTO == cProduto .And. SD7->D7_LOCAL == cLocal
		nRec := SD7->(Recno())
		SD7->(dbskip())		
	EndDo
	If nRec > 0
		SD7->(MsGoto(nRec))
	EndIf
	
	For nX:= 1 to SD7->D7_QTDE
		CB0->(DbSetOrder(6))
		If ! CB0->(DbSeek(xFilial("CB0")+SD7->D7_DOC+SD7->D7_SERIE+SD7->D7_FORNECE+SD7->D7_LOJA+SD7->D7_PRODUTO))
			Return
		Endif

		cEtiqueta := Space(20)
		@ 01,001 TO 170,295 DIALOG oDlg TITLE OemToAnsi("Estorno da Baixa CQ da Etiqueta")
		@ 06,008 TO 076,140

		@ 15,016 SAY "Etiqueta"
		@ 15,045 GET cEtiqueta Valid VldEtiq(cEtiqueta) SIZE 70,150		

		@ 050,045 BMPBUTTON TYPE 01 ACTION Continua()
		@ 050,085 BMPBUTTON TYPE 02 ACTION Close(oDlg)
		Activate Dialog oDlg Centered
		If nQtdCB0 >= SD7->D7_QTDE
			Exit
		Endif
	Next
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ VldEtiq  º Autor ³ Anderson Rodrigues º Data ³  16/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao da etiqueta                                     	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function VldEtiq(cEtiqueta)
CB0->(DbSetOrder(1))
If ! CB0->(DbSeek(xFilial("CB0")+cEtiqueta))
	MsgBox("Etiqueta nao encontrada","Atencao","Stop")
	Return .f.
Endif
If CB0->CB0_TIPO # "01"
	MsgBox("Etiqueta Invalida","Atencao","Stop")
	Return .f.
Endif
If CB0->CB0_CODPRO # SD7->D7_PRODUTO
	MsgBox("Etiqueta Invalida","Atencao","Stop")
	Return .f.
Endif
If !CBEndLib(CB0->CB0_LOCAL,CB0->CB0_LOCALI)
	MsgBox("Endereco bloqueado para inventario","Atencao","Stop")
	Return .f.
Endif
If !CBProdLib(CB0->CB0_LOCAL,CB0->CB0_CODPRO,.F.)
	MsgBox("Produto bloqueado para inventario","Atencao","Stop")
	Return .f.
Endif
If (nQtdCB0+CB0->CB0_QTDE) > SD7->D7_QTDE
	autogrlog(" ")
	autogrlog("Quantidade a ser estornada --> "+PadL(SD7->D7_QTDE,20))
	MostraErro()
	Return .f.
Endif
If CB0->CB0_STATUS == "1"
	MsgBox("Etiqueta encerrada por requisicao","Atencao","Stop")
	Return .f.
Endif
If CB0->CB0_STATUS == "2"
	MsgBox("Etiqueta encerrada por inventario","Atencao","Stop")
	Return .f.
Endif
If !Empty(CB0->CB0_OPREQ) 
	MsgBox("Etiqueta requisitada para a OP "+CB0->CB0_OPREQ,"Atencao","Stop")
	Return .f.
Endif
If !Empty(CB0->CB0_CC)
	MsgBox("Etiqueta requisitada para o Centro de Custo "+CB0->CB0_CC,"Atencao","Stop")
	Return .f.
Endif
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ Continua º Autor ³ Anderson Rodrigues º Data ³  16/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Prossegue com o estorno da etiqueta                        	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Continua()
nQtdCB0:= nQtdCB0+CB0->CB0_QTDE
autogrlog(padr(CB0->CB0_CODETI,20)+" "+;
			padL(CB0->CB0_QTDE,20)+" "+;
			padL(nQtdCB0,20))
RecLock("CB0",.f.)
CB0->CB0_LOCAL := SD7->D7_LOCAL
CB0->CB0_LOCALI:= " "
CB0->CB0_NUMSEQ:= " "
CB0->(CBLog("03",{CB0_CODPRO,CB0_QTDE,CB0_LOTE,CB0_SLOTE,CB0_LOCAL,CB0_LOCALI,CB0_NUMSEQ,CB0_NFENT,CB0_CODETI,"Estorno"}))
CB0->(MsUnlock())
Close(oDlg)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ AtuCB0   º Autor ³ Robson Sales       º Data ³  19/02/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza as etiquetas na CB0 com base na Baixa do CQ       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AtuCB0()
Local aInfoD7 := {}
Local nQtde	:= 0
Local nQtdeAte:= 0
Local cD7NumSeq:=SD7->D7_NUMSEQ //Para OP

// Posiciona no ultimo registro gerado para SD7
SD7->(DbSetOrder(2))
SD7->(MsSeek(xFilial("SD7")+cNumero+cProduto+cLocal))
While SD7->D7_NUMERO == cNumero .And. SD7->D7_PRODUTO == cProduto .And. SD7->D7_LOCAL == cLocal
	SD7->(dbskip())		
EndDo
SD7->(dbskip(-1))

nQtdeAte:= SD7->D7_QTDE //Quantos registros de etiquetas deve ser atualizado

// Posiciona na NF
cItem := Space(TamSX3("D1_ITEM")[1])
IF !Empty(SD7->D7_DOC)

	SD1->(dbsetorder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	SD1->(MsSeek(xFilial("SD1")+SD7->D7_DOC+SD7->D7_SERIE+SD7->D7_FORNECE+SD7->D7_LOJA+SD7->D7_PRODUTO))
	While SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD) == SD7->(SD7->D7_DOC+SD7->D7_SERIE+SD7->D7_FORNECE+SD7->D7_LOJA+SD7->D7_PRODUTO)
		If SD1->D1_NUMCQ == SD7->D7_NUMERO
			cItem := SD1->D1_ITEM
		EndIf
		SD1->(dbskip())
	EndDo

EndIf

//Posiciona e atualiza a etiqueta no CB0
CB0->(DbSetOrder(6)) //CB0_FILIAL+CB0_NFENT+CB0_SERIEE+CB0_FORNEC+CB0_LOJAFO+CB0_CODPRO
If CB0->(DbSeek(xFilial("CB0")+SD7->D7_DOC+SD7->D7_SERIE+SD7->D7_FORNECE+SD7->D7_LOJA+SD7->D7_PRODUTO))
	While CB0->(!Eof()) .And. xFilial("CB0")+SD7->(D7_DOC+D7_SERIE+D7_FORNECE+D7_LOJA+D7_PRODUTO) == CB0->(CB0_FILIAL+CB0_NFENT+CB0_SERIEE+CB0_FORNEC+CB0_LOJAFO+CB0_CODPRO)
		//Item da NF ou Nr.Sequencia
		If (! Empty(SD7->D7_DOC) .And. CB0->CB0_ITNFE == cItem) .Or. ;
		   (Empty(SD7->D7_DOC) .And. cD7NumSeq==CB0->CB0_NUMSEQ) 

			aInfoD7 := CB175InfD7(SD7->D7_DOC,SD7->D7_SERIE, SD7->D7_FORNECE, SD7->D7_LOJA, SD7->D7_PRODUTO,SD7->D7_LOCAL,SD7->D7_NUMERO,CB0->CB0_NUMSEQ)

			If Len(aInfoD7)>0
			   If CB0->CB0_LOCAL != aInfoD7[1] .Or. CB0->CB0_SLOTE !=aInfoD7[2] .Or. CB0->CB0_LOCALI!=aInfoD7[3]  
					RecLock("CB0",.F.)
					CB0->CB0_LOCAL  := aInfoD7[1]
					CB0->CB0_SLOTE  := aInfoD7[2]
					CB0->CB0_LOCALI := aInfoD7[3]
					CB0->(MsUnlock())
					nQtde++
				EndIf
			EndIf		
		EndIf
		CB0->(DbSkip())
		If nQtde>=nQtdeAte 
		   Exit
		EndIf
	EndDo
EndIf
RestArea(aAreaSD1)
RestArea(aAreaSD7)

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³CB175Lclizº Autor ³ Isaias Florencio   º Data ³  14/10/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna endereco do movimento original                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CB175Lcliz(cProd,cLocal,cNumSeq,cNumDoc)
Local aAreaAnt := GetArea()
Local cLocaliz := Space(TamSX3("BF_LOCALIZ")[1])
Local cAliasTmp	:= GetNextAlias()
Local cQuery     	:= ''
cQuery := "SELECT MAX(SDB.R_E_C_N_O_) AS RECNO,SDB.DB_LOCALIZ AS LOCALIZ FROM "+ RetSqlName("SDB")+" SDB "
cQuery += "WHERE SDB.DB_FILIAL	= '" + xFilial('SDB') + "' AND "
cQuery += "SDB.DB_PRODUTO	= '" + cProd   + "' AND SDB.DB_LOCAL = '"+ cLocal  + "' AND "
cQuery += "SDB.DB_NUMSEQ  	= '" + cNumSeq + "' AND SDB.DB_DOC   = '"+ cNumDoc + "' AND "
cQuery += "SDB.D_E_L_E_T_   = ' ' GROUP BY SDB.DB_LOCALIZ "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

If (cAliasTmp)->(!Eof())
	cLocaliz := (cAliasTmp)->LOCALIZ
EndIf

(cAliasTmp)->(DbCloseArea())


RestArea(aAreaAnt)
Return cLocaliz

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CB175InfD7³Isaias Florencio                 º Data ³  14/10/2014         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna array com informacoes do ultimo registro da movimentacao SD7     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AtuCB0                                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CB175InfD7(cNumDoc,cSerie, cForn, cLoja, cProd,cLocal,cNumero,cCB0Seq)
Local aRet := {}
Local aAreaAnt := GetArea()
Local aAreaSD7 := SD7->(GetArea())
Local nRecno   := 0
Local cAliasTmp	:= CriaTrab(Nil,.F.)
Local cQuery     	:= ''

cQuery := "SELECT MAX(SD7.R_E_C_N_O_) AS RECNO, SD7.D7_LOCDEST ,SD7.D7_NUMLOTE "
cQuery += "FROM "+ RetSqlName("SD7")+" SD7 "
cQuery += "WHERE SD7.D7_FILIAL	= '" + xFilial('SD7') + "' AND "
cQuery += "SD7.D7_PRODUTO = '" + cProd   + "' AND SD7.D7_LOCAL = '" + cLocal + "' AND "
if !Empty(cNumDoc) .And. !Empty(cForn)  
   cQuery += "SD7.D7_DOC  = '" + cNumDoc + "' AND SD7.D7_SERIE = '" + cSerie + "' AND "
   cQuery += "SD7.D7_FORNECE = '" + cForn + "' AND SD7.D7_LOJA = '" + cLoja + "' AND "
else
	If Empty(cNumDoc) //Produção, sem documento de entrada
		cQuery += "SD7.D7_NUMERO  = '" + cNumero + "' AND "
	EndIf
EndIf
cQuery += "SD7.D_E_L_E_T_   = ' ' "
cQuery += "GROUP BY SD7.D7_LOCDEST, SD7.D7_NUMLOTE ORDER BY 1 DESC "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

If (cAliasTmp)->(!Eof())
	nRecno :=  (cAliasTmp)->(RECNO)
	aAdd(aRet, (cAliasTmp)->(D7_LOCDEST))
	aAdd(aRet, (cAliasTmp)->(D7_NUMLOTE))
EndIf

(cAliasTmp)->(DbCloseArea())

If nRecno > 0
	SD7->(MsGoto(nRecno))
	aAdd(aRet, IIF(SD7->((D7_TIPO == 7 .Or. D7_TIPO == 6) .And. D7_ESTORNO == 'S'),SD7->(CB175Lcliz(D7_PRODUTO,D7_LOCAL,D7_NUMSEQ,D7_NUMERO)),;
								CB175Lcliz(CB0->CB0_CODPRO,CB0->CB0_LOCAL,CB0->CB0_NUMSEQ,SD7->D7_NUMERO)))
EndIf

RestArea(aAreaSD7)
RestArea(aAreaAnt)
Return aRet