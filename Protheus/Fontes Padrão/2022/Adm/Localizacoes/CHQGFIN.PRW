/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CHQGFIN  ³ Autor ³ CHILE...               ³ Data ³ 30.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Punto de Entrada para generar Cheques en Financiero...      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcChq := 1 - Ingreso o 2 - BorradO              		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC		                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CHQGFIN()
Local nOpcChq := ParamIxb//()

If cPaisLoc <> "BRA" .And. AllTrim(SE2->E2_TIPO) == "PA"

	If nOpcChq == 1

		SA6->(dbSeek(xFilial("SA6")+SA2->A2_BANCO))

		dbSelectArea("SEF")	
		RecLock("SEF",.T.)
		Replace EF_FILIAL	With xFilial("SEF")
		Replace EF_NUM     	With "TESTE"
		Replace EF_BANCO	With SA6->A6_BANCO
		Replace EF_AGENCIA 	With SA6->A6_AGENCIA
		Replace EF_CONTA	With SA6->A6_NUMCON	
		Replace EF_VALOR   	With SE2->E2_VALOR
		Replace EF_BENEF	With SA2->A2_NOME
		Replace EF_VENCTO	With SE2->VENCTO
		Replace EF_DATA	 	With SE2->E2_EMISSAO
		Replace EF_HIST 	With "Antecipo Agente de Aduana"
		Replace EF_CART 	With "P"
		Replace EF_LIBER 	With If(nPagar==1,GetMV("MV_LIBCHEQ"),"S")
		Replace EF_ORIGEM  	With "EICDUPL"
		Replace EF_FORNECE 	With SA2->A2_COD
		Replace EF_LOJA	 	With SA2->A2_LOJA
		Replace EF_LA      	With "S"
		Replace EF_SEQUENC 	With "01"
		Replace EF_TITULO  	With "TESTE"
		Replace EF_TIPO    	With "ORP"
		MsUnlock()
	
		DbSelectArea("SE2")
		RecLock("SE2",.F.)
		Replace E2_SITUACA  With "0"
		Replace E2_PORTADO  With SA6->A6_BANCO
		Replace E2_BCOCHQ   With SA6->A6_BANCO
		Replace E2_AGECHQ   With SA6->A6_AGECHQ
		Replace E2_CTACHQ   With SA6->A6_CTACHQ
		MsUnlock()
	
		ContabEic("DETAIL","590",.T.)
    
    Else 

		SA6->(dbSeek(xFilial("SA6")+SA2->A2_BANCO+SA2->A2_AGENCIA))

		dbSelectArea("SEF")	
		If dbSeek(xFilial("SEF")+SA6->A6_BANCO+SA6->A6_AGENCIA+SA6->A6_CONTA+"TESTE")
		
		   ContabEIC("DETAIL","591",.T.)
		   	
		   RecLock("SEF",.F.)
		   DbDelete()
		   MsUnLock()
		EndIf
	EndIf	   
EndIf
Return