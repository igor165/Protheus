User Function CHKISS
Local nTotiss := 0
Local cChave
DbselectArea("VSC")
cIndice:="VSC_NUMNFI + VSC_SERNFI + VSC_TIPSER"
cIndVSc := CriaTrab(Nil, .F.)
IndRegua("VSC",cIndVSC,cIndice,,,"Selecionando Registros")
Dbgotop()         
cChave := VSC->(VSC_NUMNFI + VSC_SERNFI + VSC_TIPSER)
Do While ! VSC->(Eof()) 
	If cChave == VSC->(VSC_NUMNFI + VSC_SERNFI + VSC_TIPSER)
		nTotISS += VSC->VSC_VALISS	
	Endif 
	VSC->(DbSkip())
	If cChave <> VSC->(VSC_NUMNFI + VSC_SERNFI + VSC_TIPSER)  .or. VSC->(Eof()) 
		DbselectArea("VSC")
		DbSkip(-1)
		VOK->(dbSetOrder(1))
		VOK->(dbSeek(xFilial("VOK")+VSC->VSC_TIPSER))
		SB1->(dbSetOrder(7))
		If SB1->(dbSeek(xFilial("SB1")+VOK->VOK_GRUITE+VOK->VOK_CODITE))
		   SF2->(dbSetOrder( 1 ))
			If SF2->(DbSeek( xFilial("SF2") + VSC->VSC_NUMNFI + VSC->VSC_SERNFI ))
				SD2->(DbSetOrder(3))
				If SD2->(DbSeek( xFilial("SD2") + VSC->VSC_NUMNFI + VSC->VSC_SERNFI + SF2->F2_CLIENTE + SF2->F2_LOJA + SB1->B1_COD , .f. ))
					If SD2->D2_VALISS <> nTotISS 
						Reclock("VSC",.F.)
						VSC->VSC_VALISS := VSC->VSC_VALISS + (SD2->D2_VALISS - nTotISS)
						MsUnlock()                                                            
					Endif
	 			EndIF
			EndIF
		EndIF	
		VSC->(DbSkip())
		cChave := VSC->(VSC_NUMNFI + VSC_SERNFI + VSC_TIPSER)
		nTotISS := 0
	EndIF
	                                                                                     
EndDo
Return