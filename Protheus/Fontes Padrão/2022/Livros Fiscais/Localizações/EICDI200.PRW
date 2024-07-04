#INCLUDE "EICDI200.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE aPos  {  15,  1, 70, 315 }

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICDI200 ³ Autor ³ Lucas                 ³ Data ³ 28/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Abrir e Cerrar procesos de Importación...                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function EICDI200()

PRIVATE aRotina := {	{ OemToAnsi(STR0002), "AxPesqui"	, 0 , 1},;	//"Pesquisar"
					 	{ OemToAnsi(STR0003), "AxVisual"	, 0 , 2},;	//"Visualizar"
					 	{ OemToAnsi(STR0004), "EI200Fechar"	, 0 , 3},;	//"Abrir"
					 	{ OemToAnsi(STR0005), "EI200Abrir"	, 0 , 4} }	//"Cerrar"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0001)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"SW6",,"W6_DT_ENCE")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EI200Abrir   ºAutor  ³ Lucas	 	     ºFecha ³  10/19/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para reabrir proceso de importacao                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EI200Abrir(cAlias,nOpcao,bFilBrw)
Local aArea := GetArea()
Local lRet	:=	.T.
Local nRestaura := 0

If !Empty(SW6->W6_DT_ENCE)
		Begin Transaction
		If EI200Bloq(.T.)
			nRestaura ++
		EndIf
		If nRestaura > 0		
			RecLock("SW6",.F.)
			Replace SW6->W6_DT_ENCE With CTOD('')		// Data de Encerramento do Processo
			MsUnlock()
		Endif
		End Transaction
		If Empty(SW6->W6_DT_ENCE)
			Aviso(STR0009,STR0008+Alltrim(SW6->W6_HAWB)+STR0010,{"OK"})//"Reapertura completada"##"El proceso "##" fue reabierto con exito"			
		Else                      
			Aviso(STR0011,STR0008+Alltrim(SW6->W6_HAWB)+STR0012,{"OK"})//"Reapertura completada"##"El proceso "##" fue reabierto con exito"							
		Endif                                                                                                          
Else
	Aviso(STR0015,STR0008+Alltrim(SF1->F1_HAWB)+STR0016,{"OK"})
	lRet	:=	.F.
EndIf
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EI200Fechar ºAutor  ³ Lucas           ºFecha ³  11/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para encerrar proceso de importacao...               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EI200Fechar(cAlias,nOpcao,bFilBrw)
Local aArea := GetArea()
Local lRet	:=	.T. 

If !Empty(SW6->W6_DT_ENCE)
	Aviso(STR0015,STR0008+Alltrim(SW6->W6_HAWB)+STR0022,{"OK"})			//"Inconsistencia"##"El proceso "##
Else

		If MsgYesNo(STR0017+Alltrim(SW6->W6_HAWB)+"?.",STR0006)	//"Confirma el cierre del proceso "##"Confirmacion"

			Begin Transaction 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Restaura reservas³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If EI200Libera(.T.)			
					RecLock("SW6",.F.)
					Replace SW6->W6_DT_ENCE With dDataBase	// Data de Encerramento do Processo
					MsUnlock()
				Endif
			End Transaction
					
			If !Empty(SW6->W6_DT_ENCE)
				Aviso(STR0018,STR0008+Alltrim(SW6->W6_HAWB)+STR0019,{ "OK" })		//"Reapertura completada"##"El proceso "##" fue reabierto con exito"			
			Else                      
				Aviso(STR0020,STR0008+Alltrim(SW6->W6_HAWB)+STR0021,{"OK"})		//"Reapertura completada"##"El proceso "##" fue reabierto con exito"							
			EndIf
		Else
			Aviso(STR0013,STR0014,{ " OK " })
			lRet	:=	.F.
		EndIf
EndIf

RestArea(aArea)
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³EI200Bloq ³ Autor ³ Lucas 				³ Data ³ 03.02.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Bloqueia Quantidades em estoque das Faturas de Importacao   ³±±
±±³          ³FOB/CIF para o processo de importacao 					  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EI200Bloq(ExpL1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICDI200                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EI200Bloq()			
Local aAreaSB2, aAreaSB8, aAreaSDA
Local cSeek := ""
Local nOrd  := 3
Local aArea := GetArea()
Local aSB2	:=	{}
Local aSB8	:=	{}
Local aSDA	:=	{}
Local lRet  := .T.
Local lPedido	:= .F.
Local cCondSB8	:= ""
Local aRecnoSD1	:=	{}
Local nEmpenha	:=	0
Local nQtdEmp	:=	0 
Local nEmpenha2	:=	0
Local nQtdEmp2	:=	0
Local nX		:=	0                                                
Local nTotQtd2	:=	0
Local aSF1 		:= {}
Local lFobClass := .T.

DbSelectArea("SB2")
aAreaSB2 := GetArea()
DbSelectArea("SB8")
aAreaSB8 := GetArea()
DbSelectArea("SDA")
aAreaSDA := GetArea()	

DbSelectArea("SWN")
DbSetOrder(3)
If DbSeek(xFilial("SWN")+SW6->W6_HAWB+"5")          
	While !Eof() .And. xFilial('SWN')+SW6->W6_HAWB+"5" == SWN->WN_FILIAL+SWN->WN_HAWB+SWN->WN_TIPO_NF
		If Ascan(aSF1,{|x| x[1] ==xFilial('SF1')+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA}) == 0
			//Posicionar o SF1		
			DbSelectArea('SF1')	
			DbSetOrder(1)
			MsSeek(xFilial()+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA)
			While !Eof().AND. xFilial()+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA == F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
		  
			   	If SF1->F1_TIPO == 'N' .And. Alltrim(SF1->F1_ESPECIE)==ALLTRIM(MVNOTAFIS)
					If Empty(SF1->F1_STATUS)  //-- Nota de FOB nao Classificada
						lFobClass := .F.
					EndIf
					Aadd(aSF1,{xFilial('SF1')+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA,SF1->(Recno())})
	   				Exit
			   	Endif
		     	DbSkip()
			EndDo      
		Endif
		DbSelectArea('SWN')
		DbSkip()
	EndDo
EndIf

For nX := 1 To Len(aSF1)	
	 
	SF1->(DbGoTO(aSF1[nX][2]))
	DbSelectArea("SD1")
	DbSetOrder(1)
	MsSeek(xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

	While ! SD1->(EOF()) .And. SD1->D1_FILIAL==XFilial('SD1').And. D1_DOC==SF1->F1_DOC .And. D1_SERIE==SF1->F1_SERIE .And. SD1->D1_FORNECE==SF1->F1_FORNECE .AND. SD1->D1_LOJA==SF1->F1_LOJA .AND. SD1->D1_TIPO==SF1->F1_TIPO
         
  	   If ALLTRIM(SF1->F1_ESPECIE) == ALLTRIM(SD1->D1_ESPECIE) .And. SF1->F1_TIPO == SD1->D1_TIPO
			Aadd(aRecnoSD1,SD1->(Recno()))

			DbSelectArea("SB2")
			DbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL)
			If (nPosRec	:=	Ascan(aSB2,{|x| x[1]==RECNO()})) == 0
				AAdd(aSB2,{Recno(),SD1->D1_QUANT})									
				nPosRec	:=	Len(aSB2)
			Else
			   aSB2[nPosRec][2]	+=	SD1->D1_QUANT
			EndIf				

	      	If SaldoSB2(.T.) < aSB2[nPosRec][2] .And. lFobClass
				lRet	:=	.F.
			EndIf

			If Rastro(SD1->D1_COD) .And. lRet .And. lFobClass
				If Rastro(SD1->D1_COD    ,"S") 
					nOrd  := 2
					cSeek := (xFilial("SB8")+SD1->D1_NUMLOTE+SD1->D1_LOTECTL+SD1->D1_COD+SD1->D1_LOCAL)
				Else
					nOrd  := 3
					cSeek := (xFilial("SB8")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_LOTECTL)
				EndIf

				DbSelectArea("SB8")
				DbSetOrder(nOrd)
				If DbSeek(cSeek)
    		        If (nPosRec	:=	Ascan(aSB8,{|x| x[1]==RECNO()})) == 0
						AAdd(aSB8,{Recno(),SD1->D1_QUANT})									
						nPosRec	:=	Len(aSB8)
					Else
					   aSB8[nPosRec][2]	+=	SD1->D1_QUANT
					EndIf
					If SaldoLote(SB8->B8_PRODUTO,SB8->B8_LOCAL,SB8->B8_LOTECTL,If(nOrd==2,SB8->B8_NUMLOTE,Nil),,,.T.)<aSB8[nPosRec][2]
	    				lRet	:=	.F.
					EndIf   
				EndIf
			EndIf
	
			If lRet .and. Localiza(SD1->D1_COD)  .And. lFobClass
				If  SaldoSDA(SD1->D1_COD,SD1->D1_LOCAL,SD1->D1_LOTECTL,SD1->D1_NUMLOTE,.T.) <  SD1->D1_QUANT
			    	DbSelectArea("SBF")
	    			DbSetOrder(2)
		    		DbSeek(xFilial("SBF")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_LOTECTL+SD1->D1_NUMLOTE)
		    		If Found()
						Aviso(STR0023,STR0024,{ " OK " })//"Productos ya distribuidos"##"Favor revertir las ubicaiones antes de reabrir el proceso" proceso "			
    						lRet := .F.   	                		    
			 		EndIf
				EndIf
			EndIf
		EndIf	
		DbSelectArea("SD1")
		DbSkip()
	EndDo	
Next

If lRet	

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   	//³ MV_LIBIMP - Parametro utilizado para Bloquear o saldo do     |
   	//|             produto enquanto o processo estiver em aberto.	 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetNewPar("MV_LIBIMP","S")=="S" .Or. lFobClass

		For nX := 1 To Len(aRecnoSD1)
			SD1->(DbGoTo(aREcnoSD1[nX]))
			cTpOp := If(Empty(SD1->D1_OP),"F","P")
    	                                                        
			SB1->(DbSetOrder(1))
			SB1->(MsSeek(xFilial()+SD1->D1_COD))
			If Empty(SB1->B1_CONV) .And. !Empty(SD1->D1_QTSEGUM)
				nTotQtd2 := SD1->D1_QTSEGUM
			ElseIf !Empty(SB1->B1_CONV)
				nTotQtd2 := SB1->(ConvUm(SB1->B1_COD,(SD1->D1_QUANT),SD1->D1_QTSEGUM,2))
			EndIf

			DbSelectArea("SB2")
			DbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL)
			RecLock("SB2",.F.)
			If lPedido
				Replace B2_RESERVA With B2_RESERVA+SD1->D1_QUANT 
				Replace B2_RESERV2 With B2_RESERV2+nTotQtd2
			Else
				If cTpOp  == "P"	// OP PREVISTA
					Replace B2_QEMPPRE With B2_QEMPPRE+SD1->D1_QUANT
					Replace B2_QEPRE2  With B2_QEPRE2 +nTotQtd2
				ElseIf cTpOp  == "F"	// OP FIRME
					Replace B2_QEMP  With B2_QEMP + SD1->D1_QUANT
					Replace B2_QEMP2 With B2_QEMP2+nTotQtd2
				EndIf
			EndIf
			MsUnlock()
	    	
			If Rastro(SD1->D1_COD)
				If Rastro(SD1->D1_COD,"S") 
					nOrd  := 2
					cSeek := (xFilial("SB8")+SD1->D1_NUMLOTE+SD1->D1_LOTECTL+SD1->D1_COD+SD1->D1_LOCAL)
					cCondSB8 := "B8_FILIAL+B8_NUMLOTE+B8_LOTECTL+B8_PRODUTO+B8_LOCAL=="
					cCondSB8 := "xFilial('SB8')+SD1->D1_NUMLOTE+SD1->D1_LOTECTL+SD1->D1_COD+SD1->D1_LOCAL"
				Else
					nOrd  := 3
					cSeek := (xFilial("SB8")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_LOTECTL)
					cCondSB8 := "B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL=="
					cCondSB8+="xFilial('SB8')+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_LOTECTL"
				EndIf
		      	nQtdEmp	:=	SD1->D1_QUANT                                   
      				nQtdEmp2	:=	nTotQtd2
			                                   
				DbSelectArea("SB8")
				DbSetOrder(nOrd)
				If DbSeek(cSeek) 
					While !Eof() .And. &(cCondSB8) .And. nQtdEmp >	0
						If B8_ITEM == SD1->D1_ITEM
               	 			nEmpenha	:=	IIf(nQtdEmp  > (SB8->B8_SALDO-SB8->B8_EMPENHO),(SB8->B8_SALDO-SB8->B8_EMPENHO),nQtdEmp)
	            	     	nEmpenha2:=	IIf(nQtdEmp2 > (SB8->B8_SALDO2-SB8->B8_EMPENH2),(SB8->B8_SALDO2-SB8->B8_EMPENH2),nQtdEmp2)
							nQtdEmp	-=	nEmpenha
							nQtdEmp2	-=	nEmpenha2
							RecLock("SB8",.F.)
							Replace SB8->B8_EMPENHO With (SB8->B8_EMPENHO + nEmpenha)
							Replace SB8->B8_EMPENH2 With (SB8->B8_EMPENH2 + nEmpenha2)
							MsUnlock()
						EndIf
						DbSkip()
					EndDo			
				EndIf
			EndIf
			If Localiza(SD1->D1_COD)
				DbSelectArea("SDA")
				DbSetOrder(1)
				If dbSeek(xFilial("SDA")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ+SD1->D1_DOC)
					RecLock("SDA",.F.)
					Replace SDA->DA_EMPENHO With (SDA->DA_EMPENHO + SD1->D1_QUANT)
					Replace SDA->DA_EMP2 With (SDA->DA_EMP2 +nTotQtd2)					
					MsUnlock()
				EndIf
			EndIf		
		Next
	EndIf	
EndIf

RestArea(aAreaSB2)
RestArea(aAreaSB8)
RestArea(aAreaSDA)
RestArea(aArea)
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ EI200Libera³ Autor ³Lucas       		    ³ Data ³ 11.12.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Libera quantidades empenhadas em estoque referente 'as NF de³±± 
±±³          ³Importacao     					                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EI200Libera()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EI200Libera                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EI200Libera()

Local aArea		:= GetArea()
Local aSWN, aSW6, aSD3, aSB8, aSDA, aSDB, aSB2
Local cSeek		:= ""
Local nOrd		:= 3
Local lEncerra	:= .F.
Local lRet		:= .F.
Local lPedido	:= .F. 
Local cTpOp		:= " "
Local cCondSB8	:= ""
Local aSF1		:= {}
Local nX		:= 0
Local nEmpenha	:= 0
Local nQtdEmp	:= 0 
Local	nEmpenha2:= 0
Local nQtdEmp2	:= 0
Local nTotQtd2	:= 0
Local lFobClass := .T.

dbSelectArea("SB2")
aSB2 := GetArea()
dbSelectArea("SW6")
aSW6 := GetArea()
dbSelectArea("SD3")
aSD3 := GetArea()
dbSelectArea("SB8")
aSB8 := GetArea()
dbSelectArea("SDA")
aSDA := GetArea()
dbSelectArea("SDB")
aSDB := GetArea()

DbSelectArea("SWN")
DbSetOrder(3)
If DbSeek(xFilial("SWN")+SW6->W6_HAWB+"5")          
	While !Eof() .And. xFilial('SWN')+SW6->W6_HAWB+"5" == WN_FILIAL+SWN->WN_HAWB+SWN->WN_TIPO_NF
		If Ascan(aSF1,{|x| x[1] ==xFilial('SF1')+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA}) == 0
			//Posicionar o SF1		
			DbSelectArea('SF1')	
			DbSetOrder(1)
			MsSeek(xFilial()+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA)
			While !Eof().AND. xFilial()+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA == F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
				If SF1->F1_TIPO == 'N' .And. Alltrim(SF1->F1_ESPECIE)==ALLTRIM(MVNOTAFIS)
					If Empty(SF1->F1_STATUS) //-- Nota de FOB nao Classificada
						lFobClass := .F.
					EndIf
					Aadd(aSF1,{xFilial('SF1')+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA,SF1->(Recno())})
			   		Exit
		   		EndIf
				DbSkip()
			EndDo      
		EndIf
		DbSelectArea('SWN')
		DbSkip()
	EndDo
EndIf

For nX := 1 To Len(aSF1)
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MV_LIBIMP - Parametro utilizado para Bloquear o saldo do     |
   	//|             produto enquanto o processo estiver em aberto.	 ³
   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetNewPar("MV_LIBIMP","S")=="S" .Or. lFobClass

	   	SF1->(DbGoTO(aSF1[nX][2]))
		DbSelectArea("SD1")
		DbSetOrder(1)
		MsSeek(xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

		While ! SD1->(EOF()) .And. SD1->D1_FILIAL==XFilial('SD1').And. D1_DOC==SF1->F1_DOC .And. D1_SERIE==SF1->F1_SERIE .And. SD1->D1_FORNECE==SF1->F1_FORNECE .AND. SD1->D1_LOJA==SF1->F1_LOJA .AND. SD1->D1_TIPO==SF1->F1_TIPO
         
			If ALLTRIM(SF1->F1_ESPECIE) == ALLTRIM(SD1->D1_ESPECIE) .And. SF1->F1_TIPO == SD1->D1_TIPO
				DbSelectArea("SB2")
				DbSetOrder(1)
				If DbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL)
   	  	  			//cTpOp := If(Empty(SD1->D1_OP),"F","P")
    	    		cTpOp := "F"
					SB1->(DbSetOrder(1))
					SB1->(MsSeek(xFilial()+SD1->D1_COD))
					If Empty(SB1->B1_CONV) .And. !Empty(SD1->D1_QTSEGUM)
						nTotQtd2 := SD1->D1_QTSEGUM
					ElseIf !Empty(SB1->B1_CONV)
						nTotQtd2 := SB1->(ConvUm(SB1->B1_COD,(SD1->D1_QUANT),SD1->D1_QTSEGUM,2))
					EndIf
               	
					If ! Empty(SD1->D1_QUANT)
						DbSelectArea("SB2")
						DbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL)
						RecLock("SB2",.F.)
						If lPedido
							Replace B2_RESERVA With B2_RESERVA-SD1->D1_QUANT 
							Replace B2_RESERV2 With B2_RESERV2-nTotQtd2
						Else
							If cTpOp  == "P"	// OP PREVISTA
								Replace B2_QEMPPRE With B2_QEMPPRE-SD1->D1_QUANT
								Replace B2_QEPRE2  With B2_QEPRE2 -nTotQtd2
							ElseIf cTpOp  == "F"	// OP FIRME
								Replace B2_QEMP  With B2_QEMP - SD1->D1_QUANT
								Replace B2_QEMP2 With B2_QEMP2-nTotQtd2
							EndIf
						EndIf
						MsUnlock()
					EndIf				        		        		
				EndIf
			
				If Rastro(SD1->D1_COD)
					If Rastro(SD1->D1_COD,"S") 
						nOrd  := 2
						cSeek := (xFilial("SB8")+SD1->D1_NUMLOTE+SD1->D1_LOTECTL+SD1->D1_COD+SD1->D1_LOCAL)
						cCondSB8 := "B8_FILIAL+B8_NUMLOTE+B8_LOTECTL+B8_PRODUTO+B8_LOCAL=="
						cCondSB8 := "xFilial('SB8')+SD1->D1_NUMLOTE+SD1->D1_LOTECTL+SD1->D1_COD+SD1->D1_LOCAL"
					Else
						nOrd  := 3
						cSeek := (xFilial("SB8")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_LOTECTL)
						cCondSB8 := "B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL=="
						cCondSB8+="xFilial('SB8')+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_LOTECTL"
					EndIf
			      	nQtdEmp	:=	SD1->D1_QUANT                                   
	   				nQtdEmp2	:=	nTotQtd2                                   
					                                   
					DbSelectArea("SB8")
					DbSetOrder(nOrd)
					If DbSeek(cSeek) 
						While !Eof() .And. &(cCondSB8) .And. nQtdEmp >	0
							If B8_ITEM == SD1->D1_ITEM
	                		 	nEmpenha	:=	IIf(nQtdEmp  > SB8->B8_EMPENHO,SB8->B8_EMPENHO,nQtdEmp)
			                 	nEmpenha2	:=	IIf(nQtdEmp2 > SB8->B8_EMPENH2,SB8->B8_EMPENH2,nQtdEmp2)
								nQtdEmp		-=	nEmpenha
								nQtdEmp2	-=	nEmpenha2
								RecLock("SB8",.F.)
								Replace SB8->B8_EMPENHO With (SB8->B8_EMPENHO - nEmpenha)
								Replace SB8->B8_EMPENH2 With (SB8->B8_EMPENH2 - nEmpenha2)
								MsUnlock()
							EndIf
							DbSkip()
						EndDo			
					EndIf
				EndIf
		
				If Localiza(SD1->D1_COD)
					DbSelectArea("SDA")
					DbSetOrder(1)
					If dbSeek(xFilial("SDA")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ+SD1->D1_DOC)
						RecLock("SDA",.F.)
						Replace SDA->DA_EMPENHO	With SDA->DA_EMPENHO - SD1->D1_QUANT
						Replace SDA->DA_EMP2	With SDA->DA_EMP2 - nTotQtd2						
						MsUnlock()
  					EndIf
       	
					DbSelectArea("SDB")
					DbSetOrder(1)
					If DbSeek(xFilial("SDB")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ+SD1->D1_DOC)
						RecLock("SDB",.F.)
						Replace SDB->DB_EMPENHO	With SDB->DB_EMPENHO - SD1->D1_QUANT
						Replace SDB->DB_EMP2	With SDB->DB_EMP2 - nTotQtd2
						MsUnlock()
					EndIf
				EndIf
				lEncerra := .T.
			EndIf	
			
			DbSelectArea("SD1")					
			DbSkip()
		EndDo
	Else
		lEncerra := .T.
	EndIf	
Next

RestArea(aSW6)
RestArea(aSB2)
RestArea(aSD3)
RestArea(aSB8)
RestArea(aSDA)
RestArea(aSDB)
RestArea(aArea) 
Return( lEncerra )