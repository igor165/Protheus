User Function CalPISPE
/* SERVICOS */

DbSelectArea("VSC")
DbGotop()
Do While ! VSC->(Eof())
	VO4->(DBGOTO(VAL(VSC->VSC_RECVO4)))
	FG_Seek("SB1","VSC->VSC_GRUSER+VSC->VSC_CODSER",7,.f.)
	FG_SEEK("SF4","VO4->VO4_CODTES",1,.f.)        
	Reclock("VSC",.F.)   
	VSC->VSC_VALPIS :=  0
	VSC->VSC_VALCOF :=  0
	aPisCof := CalcPisCofSai(VSC->VSC_VALSER)
	If aPisCof[1,1] > 0 
		VSC_VALPIS := aPisCof[1,1]
	EndIf
	If aPisCof[1,2] > 0
		VSC_VALCOF := aPisCof[1,2] 
	Endif	            
	VSC_TOTIMP := VSC_VALISS + VSC_VALCOF + VSC_VALPIS
	VSC_LUCBRU := VSC_VALSER - VSC_TOTIMP - VSC_CUSTOT
	VSC_LUCLIQ := VSC_LUCBRU - VSC_DESVAR
	VSC_RESFIN := VSC_LUCLIQ - VSC_CUSFIX - VSC_DESFIX - VSC_DESDEP - VSC_DESADM
	VSC_VMFBRU := FG_CalcMF({ {VSC->VSC_DATVEN ,VSC->VSC_LUCBRU} })
	VSC_VMFSER := VSC_VMFBRU - FG_CALCMF( {{VSC_DATVEN,VSC_VALDES}} )
	VSC_VMFPIS := FG_CALCMF({{FG_RTDTIMP("PIS",VSC_DATVEN),VSC_VALPIS}})
	VSC_VMFCOF := FG_CALCMF({{FG_RTDTIMP("COF",VSC_DATVEN),VSC_VALCOF}})
	VSC_TMFIMP := VSC_VMFPIS + VSC_VMFISS + VSC_VMFCOF
	VSC_LMFBRU := VSC_VMFSER - VSC_TMFIMP - VSC_CMFSER
	VSC_LMFLIQ := VSC_LMFBRU - VSC_DMFVAR
	VSC_RMFFIN := VSC_LMFLIQ - VSC_CMFFIX - VSC_DMFFIX - VSC_DMFADM - VSC_DMFDEP
	MsUnlock()
	VSC->(DbSkip())
EndDo                  

/* PECAS */

DbSelectArea("VEC")
DbGoTop()
While !Eof() 
	If VEC->VEC_BALOFI == "B"   
   	DbSelectArea( "VS1" )
	   DbSetOrder(3)
    	If !DbSeek( xFilial("VS1") + VEC->VEC_NUMNFI + VEC->VEC_SERNFI , .f. )
	   	DbSelectArea("VEC")
   		Dbskip()
	   	Loop
   	EndIf                                                                 
   	cSeekSF2 := VEC->VEC_NUMNFI + VEC->VEC_SERNFI + VS1->VS1_CLIFAT + VS1->VS1_LOJA
   Else
   	DbSelectArea( "VS1" )
	   DbSetOrder(1)
    	DbSeek( xFilial("VS1") + VEC->VEC_NUMORC, .f. )
		DbSelectArea( "VOO" )
		DbSetOrder(4)
		DbSeek( xFilial("VOO") + VEC->VEC_NUMNFI + VEC->VEC_SERNFI , .t. )
   	cSeekSF2 := VEC->VEC_NUMNFI + VEC->VEC_SERNFI + VOO->VOO_FATPAR + VOO->VOO_LOJA
   EndIf  

  	DbSelectArea( "SF2" )
   DbSetOrder(1)
   If !DbSeek( xFilial("SF2") + cSeekSF2 , .f. )
   	cSeekSF2 := VEC->VEC_NUMNFI + VEC->VEC_SERNFI 
	Endif
   
  	If !DbSeek( xFilial("SF2") + cSeekSF2 , .f. )
   	DbSelectArea("VEC")
  		Dbskip()
   	Loop
  	Else                                  
	  	cSeekSF2 := VEC->VEC_NUMNFI + VEC->VEC_SERNFI + SF2->F2_CLIENTE + SF2->F2_LOJA
		DbSelectArea( "SD2" )
		DbSetOrder(3)
		If !DbSeek( xFilial("SD2") + cSeekSF2 + VEC->VEC_PECINT , .f. )
	   	DbSelectArea("VEC")
   		Dbskip()
	   	Loop
      EndIf
  	EndIf
	If VEC->VEC_BALOFI == "B"
		DbSelectArea( "SD2" )
		DbSetOrder(3)
		If !DbSeek( xFilial("SD2") + cSeekSF2 + VEC->VEC_PECINT , .f. )
	   	DbSelectArea("VEC")
   		Dbskip()
	   	Loop
      EndIf
	 	
	EndIf
	DbSelectArea( "SF4" )
	DbSetOrder(1)
	DbSeek( xFilial("SF4") + SD2->D2_TES )    
	FG_Seek("SB1","SD2->D2_COD",1,.f.)   
	DbSelectArea("VEC")	   
	aPisCof := CalcPisCofSai(VEC->VEC_VALVDA)
	Reclock("VEC",.F.)                    
	VEC->VEC_VALCOF  := 0
	VEC->VEC_VALPIS := 0
	If aPisCof[1,2] > 0
		VEC_VALCOF := aPisCof[1,2]
	Endif
	If aPisCof[1,1] > 0	
		VEC_VALPIS := aPisCof[1,1]
	Endif
	VEC_TOTIMP := VEC_VALICM + VEC_VALCOF + VEC_VALPIS
	VEC_LUCBRU := VEC_VALVDA - VEC_TOTIMP - VEC_CUSTOT
	VEC_LUCLIQ := VEC_LUCBRU - VEC_DESVAR
	VEC_RESFIN := VEC_LUCLIQ - VEC_DESFIX - VEC_CUSFIX - VEC_DESDEP - VEC_DESADM

	VEC_VMFBRU := FG_CALCMF( {{VEC_DATVEN,VEC->VEC_LUCBRU}} )
	VEC_VMFVDA := VEC_VMFBRU - FG_CALCMF( {{VEC_DATVEN,VEC_VALDES}} )
	VEC_VMFPIS := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VEC_VALPIS} })
	VEC_VMFCOF := FG_CALCMF( { {FG_RTDTIMP("COF",dDataBase),VEC_VALCOF} })
	VEC_TMFIMP := VEC_VMFICM + VEC_VMFCOF + VEC_VMFPIS
	VEC_LMFBRU := VEC_VMFVDA - VEC_TMFIMP - VEC_CMFTOT
	VEC_RMFFIN := VEC_LMFLIQ - VEC_DMFFIX - VEC_CMFFIX - VEC_DMFDEP - VEC_DMFADM
	MsUnlockAll()
   DbSkip()
EndDo

Return .T.
	