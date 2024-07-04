User Function GrvPIS()
Local cNota   :=""
Local cSerie  := ""
Local ctipFat := ""
DbSelectArea("SD2")
DbGotop()
Do While !Eof()       
		If SD2->D2_LOCAL <> "VU" //.OR. SD2->D2_TIPO == "B"
			DbSkip()
			Loop
		EndIF                    
		cNota  := SD2->D2_DOC
		cSerie := SD2->D2_SERIE
		VV0->(DBSETORDER(4))
		VV0->(DbSeek(XFILIAL("VV0")+ cNota + cSerie))
		FG_SEEK("VVA","VV0->VV0_NUMTRA",1,.f.)
		FG_SEEK("VVG","VVA->VVA_CHAINT+VVA->VVA_TRACPA",2,.f.)
		FG_SEEK("VV1","VVA->VVA_CHAINT",1,.f.)
		cTipFat :=  VV0->VV0_TIPFAT
		dbSelectArea("SD2")
      dbSetOrder(3)
  		FG_SEEK("SB1","SD2->D2_COD",1,.f.)
  		FG_SEEK("SF4","SD2->D2_TES",1,.f.)
		RecLock("SD2",.f.)
		If cTipFat == "2" //Faturamento Direto
			aPisCof := CalcPiscofSai(VVA->VVA_VALCVD)
			GrvPisCof(VVA->VVA_VALCVD,aPiscof,"S")
		Else
			if cTipFat == "1" // Veiculo Usado      
				aPisCof := CalcPiscofSai((VVA->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)))
				GrvPisCof((VVA->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)),aPiscof,"S")
			Endif  
			if VV1->VV1_SITVEI == "3" //Remessa
				aPisCof := CalcPiscofSai(0)
				GrvPisCof((VVA->VVA_VALVDA-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)),aPiscof,"S")
			EndIF
		ENDIF
		MsUnlock()
		dbSelectArea("VV0")
		dbSetOrder(1)  
		DbSelectArea("SD2")
		DbSkip()
EndDo     
MSGINFO("PROCESSO FINALIZADO")
Return .t.