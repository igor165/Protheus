#INCLUDE "rwmake.ch" 
#INCLUDE "acdmta265E.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออออปฑฑ
ฑฑบ Funcao   ณ CBMTA265E  บ Autor ณ Anderson Rodrigues บ Data ณMon  16/09/02     บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออออนฑฑ
ฑฑบDescrio ณ Faz Acerto do CB0 no estorno da Distribuicao  					 นฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso        ณ SIGAACD                        	                                 บฑฑ
ฑฑบParametros ณ nExecuta  = 1 = Executa Validacao com visualizacao da Tela       บฑฑ
ฑฑบ			  ณ   		  = 2 = Executa Gravacao CB0					         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/    
Function CBMTA265E(nExecuta,nAcols)
Local nX        := 0
Local cDoc      := ""
Local n         := 0   
Local lRet      := .F.
Local aAreaCB0  := CB0->(GetArea()) 
Local aAreaSD3  := SD3->(GetArea())
Local aCb0Qtd   := {}
Local nQtdAux   := 0
Local cSeekCB0  := ""

Private nTamCodEt := TamSx3("CB0_CODETI")[1]
Private nTamCodE2 := TamSx3("CB0_CODET2")[1]
Private nQtdCB0  :=  0
Static aEtiqLida := {}
Static cEtiqueta

If !SuperGetMV("MV_CBPE016",.F.,.F.)
	Return .T.
EndIf

If Type("l265AUTO") =="L" .and. l265AUTO 
	Return .T.
EndIf

// Posicionar no Registro SDB correto
SDB->(DbSeek(xFilial("SDB")+SDA->DA_PRODUTO+SDA->DA_LOCAL+SDA->DA_NUMSEQ+SDA->DA_DOC+SDA->DA_SERIE+SDA->DA_CLIFOR+SDA->DA_LOJA+aCols[nAcols,nPosItem]))

If nExecuta == 2 .And. SDB->DB_ESTORNO # "S"
	Return .T.
EndIf
autogrlog(STR0001) // "Quantidade das etiquetas informadas ultrapassa a quantidade a ser estornada"
autogrlog(Padr(OemToAnsi(STR0002),20)+" "+;   // "Etiqueta"	
		    PadL(OemToAnsi(STR0003),20)+" "+;  // "Quantidade"
		    PadL(OemToAnsi(STR0004),20)) 		//  "Total"
		    

For nX:= 1 to SDB->DB_QUANT
   If TRIM(SDB->DB_ORIGEM)=='SD3' 
	   n:=0
	   //Busca Nro de Documento na tab.movimentos internos//
	   SD3->(DbSetOrder(8))
	   If !SD3->(DbSeek(xFilial("SD3")+SDB->DB_DOC+SDB->DB_NUMSEQ))
	   		Return .T.
	   EndIf
       cDoc:=SD3->D3_OP
       
		// Verifica se o movimento esta atrelado a uma OP
		If !Empty(cDoc)
		//Localiza a Etiqueta atrav้s do NumSeq// 
			CB0->(DbSetOrder(7))
			CB0->(DbSeek(xFilial("CB0")+cDoc))
			Do While CB0->(!Eof()) .And. CB0->(xFilial("CB0")+cDoc)==Xfilial("CB0")+cDoc 
				If CB0->CB0_NUMSEQ == SDB->DB_NUMSEQ 
					n++
					Exit
				EndIf
				CB0->(DbSkip())  
			EndDo                                                   
			If n==0
				Return .T.
			EndIf
		EndIf
   Else
       CB0->(DbSetOrder(6))
       If ! CB0->(DbSeek(xFilial("CB0")+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA+SDB->DB_PRODUTO))
           Return .T.
  	   Endif   
   EndIf 
   
   RestArea(aAreaCB0)   
   RestArea(aAreaSD3)
                        
   If nExecuta == 1
	   cEtiqueta := Space(20)
	   @ 01,001 TO 170,295 DIALOG oDlg TITLE OemToAnsi(STR0005) // "Estorno do Enderecamento da Etiqueta"
	   @ 06,008 TO 076,140
		
	   @ 15,016 SAY STR0002 // "Etiqueta"
	   @ 15,045 GET cEtiqueta Valid VldEtiq(cEtiqueta) SIZE 70,150		
				
	   @ 050,045 BMPBUTTON TYPE 01 Action (lRet:=.T.,Close(oDlg))
	   @ 050,085 BMPBUTTON TYPE 02 Action (lRet:=.F.,Close(oDlg))
	   Activate Dialog oDlg Centered		
	   If !lRet
	   		Exit
	   	EndIf	
	   If nQtdCB0 >= SDB->DB_QUANT
    	  Exit      
	   Endif 
	 // Verificar se o movimento foi gerado por uma OP
	 If Alltrim(SDB->DB_ORIGEM)=='SD3'
	 	If Len(Alltrim(cEtiqueta)) <=  nTamCodEt
		 	CB0->(DbSetOrder(1))
		 	If CB0->(MsSeek(xFilial("CB0")+cEtiqueta))
		 		If CB0->CB0_NUMSEQ == SDB->DB_NUMSEQ
			 		nX := nX + CB0->CB0_QTDE
					nX := nX - 1
					AAdd(aEtiqLida,cEtiqueta)
				EndIf
			EndIf
		ElseIf Len(Alltrim(cEtiqueta)) ==  nTamCodE2-1   // Codigo Interno  pelo codigo do cliente
		 	CB0->(DbSetOrder(2))
		 	If CB0->(MsSeek(xFilial("CB0")+cEtiqueta))
		 		If CB0->CB0_NUMSEQ == SDB->DB_NUMSEQ
			 		nX := nX + CB0->CB0_QTDE
					nX := nX - 1
					AAdd(aEtiqLida,cEtiqueta)
				EndIf
			EndIf
		EndIf 
	 Else
		  // Verificar a quantidade da Etiqueta quando utilizar a quantidade maior que 1
		 CB0->(DbSetOrder(6))
		 If CB0->(DbSeek(cSeekCB0 := xFilial("CB0")+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA+SDB->DB_PRODUTO))
		 
		 	// Posiciona na etiqueta digitada pelo usuario, para a correta atualizacao da CB0
		 	While CB0->(!Eof()) .And. cSeekCB0 == xFilial("CB0")+CB0->(CB0_NFENT+CB0_SERIEE+CB0_FORNEC+CB0_LOJAFO+CB0_CODPRO) ;
		 		  .And. AllTrim(CB0->CB0_CODETI) <> AllTrim(cEtiqueta)
		 		CB0->(DbSkip())
		 		Loop
		 	EndDo
		 	If AllTrim(CB0->CB0_CODETI) == AllTrim(cEtiqueta) .And. CB0->CB0_NUMSEQ == SDB->DB_NUMSEQ
			   	nX := nX + CB0->CB0_QTDE
				nX := nX - 1
				AAdd(aEtiqLida,cEtiqueta)
			Else
				MsgBox(STR0006,STR0007,STR0008) // "Etiqueta nao pertence a essa movimentacao da tabela SDB" | "Atencao" | "Parar"
				nX := nX - 1
			EndIf
		 Else	
		 	//Se nao localizou informacoes diretamente na CB0, verifica se trata-se de um movimento oriundo da baixa do CQ (SD7)
		  	SD7->(DbSetOrder(3))
			If SD7->(DbSeek(xFilial("SD7")+SDA->DA_PRODUTO+SDA->DA_NUMSEQ)) 
				//Se localizou na SD7, procura na CB0 o documento de entrada que originou o registro
				If CB0->(DbSeek(xFilial("CB0")+SD7->D7_DOC+SD7->D7_SERIE+SD7->D7_FORNECE+SD7->D7_LOJA+SD7->D7_PRODUTO))
					nX := nX + CB0->CB0_QTDE
					nX := nX - 1	
					AAdd(aEtiqLida,cEtiqueta)
				EndIf
			EndIf	
		EndIf
	 EndIf
    Else   
    	lRet:=.T.
    	Continua()  //Grava
	EndIf
Next 

If nExecuta == 2
	aEtiqLida := {}
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณ VldEtiq  บ Autor ณ Anderson Rodrigues บ Data ณ  16/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao da etiqueta                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function VldEtiq(cEtiqueta)
Local ny := 0

// Posiciona na etiqueta que sera validada
If Len(Alltrim(cEtiqueta)) <=  nTamCodEt   // Codigo Interno
	CB0->(DbSetOrder(1))
	If !CB0->(DbSeek(xFilial("CB0")+Padr(cEtiqueta,nTamCodEt)))
		MsgBox(STR0009 ,STR0007,STR0008) // "Etiqueta nao encontrada" | "Atencao" | "Parar"
		Return .F.
	EndIf
ElseIf Len(Alltrim(cEtiqueta)) ==  nTamCodE2-1   // Codigo Interno  pelo codigo do cliente
	CB0->(DbSetOrder(2))
	If !CB0->(DbSeek(xFilial("CB0")+Padr(cEtiqueta,nTamCodE2)))
		MsgBox(STR0009 ,STR0007,STR0008) // "Etiqueta nao encontrada" | "Atencao" | "Parar"
		Return .F.
	EndIf
Else
	MsgBox(STR0009 ,STR0007,STR0008) // "Etiqueta nao encontrada" | "Atencao" | "Parar"
	Return .F.
EndIf

// Validacoes
If CB0->CB0_TIPO # "01"
	MsgBox(STR0010,STR0007,STR0008) // "Etiqueta Invalida" | "Atencao" | "Parar"
	Return .F.
Endif
If CB0->CB0_CODPRO # SDB->DB_PRODUTO
	MsgBox(STR0010,STR0007,STR0008) // "Etiqueta Invalida" | "Atencao" | "Parar"
	Return .F.
Endif
If !CBEndLib(CB0->CB0_LOCAL,CB0->CB0_LOCALI)
   MsgBox(STR0011,STR0007,STR0008) // "Endereco bloqueado para inventario" | "Atencao" | "Parar"
	Return .F.
Endif
If !CBProdLib(CB0->CB0_LOCAL,CB0->CB0_CODPRO,.F.)
   MsgBox(STR0012,STR0007,STR0008) // "Produto bloqueado para inventario" | "Atencao" | "Parar"
	Return .F.
Endif
If (nQtdCB0+CB0->CB0_QTDE) > SDB->DB_QUANT
	autogrlog(" ")
	autogrlog(STR0013 + PadL(SDB->DB_QUANT,20)) // "Quantidade a ser estornada --> " 
	MostraErro()
	Return .F.
Endif
If CB0->CB0_STATUS == "1"
   MsgBox(STR0014,STR0007,STR0008) // "Etiqueta encerrada por requisicao" | "Atencao" | "Parar"
	Return .F.
Endif
If CB0->CB0_STATUS == "2"
   MsgBox(STR0015,STR0007,STR0008) // "Etiqueta encerrada por inventario" | "Atencao" | "Parar"
	Return .F.
Endif
If !Empty(CB0->CB0_OPREQ) 
   MsgBox(STR0016 + CB0->CB0_OPREQ,STR0007,STR0008) // "Etiqueta requisitada para a OP " | "Atencao" | "Parar"
	Return .F.
Endif
If !Empty(CB0->CB0_CC)
   MsgBox(STR0017+CB0->CB0_CC,STR0007,STR0008) // "Etiqueta requisitada para o Centro de Custo " | "Atencao" | "Parar"
	Return .F.
Endif
If IsInCallStack("A265Estorn")
   If CB0->CB0_NUMSEQ <> SDA->DA_NUMSEQ .And. SDA->DA_ORIGEM == 'SD3'
   	   // "A etiqueta nao corresponde ao endere็o " | "Atencao" | "Parar"
	   MsgBox(STR0018 + cEtiqueta + STR0019 + CB0->CB0_LOCALI,STR0007,STR0008) 
	   	Return .F.
   EndIf
EndIf	
If !Empty(aEtiqLida) 
	For ny:= 1 to Len(aEtiqLida)
		If aEtiqLida[ny] == cEtiqueta
			// "A etiqueta " ja foi informada para este estorno " | "Atencao" | "Parar"
	   		MsgBox(STR0018 + AllTrim(cEtiqueta) + STR0020,STR0007,STR0008)
	   		Return .F.
		Endif 
	Next
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณ Continua บ Autor ณ Anderson Rodrigues บ Data ณ  16/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Prossegue com o estorno da etiqueta                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Continua()  
Local aArea:=GetArea()
Local ny := 0

For ny:= 1 to Len(aEtiqLida)
		//Posiciona Etiqueta
		If Len(Alltrim(aEtiqLida[ny])) <=  nTamCodEt   // Codigo Interno
			CB0->(DbSetOrder(1))
			CB0->(MsSeek(xFilial("CB0")+aEtiqLida[ny]))
		ElseIf Len(Alltrim(aEtiqLida[ny])) ==  nTamCodE2-1   // Codigo Interno  pelo codigo do cliente
			CB0->(DbSetOrder(2))
			CB0->(MsSeek(xFilial("CB0")+aEtiqLida[ny]))
		EndIf
		
		If CB0->(!Eof())
			nQtdCB0:= nQtdCB0+CB0->CB0_QTDE				
			autogrlog(padr(CB0->CB0_CODETI,20)+" "+padL(CB0->CB0_QTDE,20)+" "+ padL(nQtdCB0,20)) 
			
			RecLock("CB0",.f.)
			CB0->CB0_LOCAL := SDB->DB_LOCAL
			CB0->CB0_LOCALI:= " "
			CB0->(CBLog("01",{CB0_CODPRO,CB0_QTDE,CB0_LOTE,CB0_SLOTE,CB0_LOCAL,CB0_LOCALI,CB0_NUMSEQ,CB0_NFENT,CB0_CODETI,"Estorno"}))
			CB0->(MsUnlock()) 
		EndIf
Next

RestArea(aArea)
Return 
