#INCLUDE "PLSPRO05.ch" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "PLSMGER.CH"   
          
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSPRO05   บAutor  ณMicrosiga           บ Data ณ 09/18/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Planejamento da Promo็ใo					                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE VERSAO 11.5                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PLSPRO05(cVida,cElegi,cProgram,cCodRis,cStatus,lAjust)   
Local nCntFor    := 1, aSize := {}              
Local cChave     := ""
Local cCadastro  := STR0001   //"Planejamento Individual"
Local nOpcA      := 0
Local aAreaBOD   := BOD->(GetArea())
Local cDura	     := 0
Local nPerio	 := ""
Local dDtCalc	 
Local dDatExam    
Local nSem		 := 7
Local nMes		 := 30
Local nAno		 := 365
Local nP		 := 0
Local nRisco	 := 0
Local aPPanel    := {} 
Local nPosVida   := 0
Local nPosEleg   := 0
Local nPosItem   := 0 
Local nPosProc   := 0
Local nPosDtSug  := 0
Local nPosCodAg  := 0
Local lExist     := .F.  
Local lPassou    := .F.  
Local lMarcado   := .F.  
Local aObjects   := {}
Local nQtdDias   := 0
Local cMarca     := ""
Local dDatIni    := CTOD("")
Local dDatFin    := CTOD("") 
Local dDatIns    := CTOD("") 
Local lDiaVali   := GETNEWPAR("MV_DTVALID",.F.)
LOCAL oCboDur
LOCAL aCboDur := {}
LOCAL aCpCols := {}
LOCAL cCboDur := ""
LOCAL cEdtPer := Space(3)
LOCAL oEdtPer
LOCAL cCodLoc	:= ""
Local oBtRecalc
Local oBtGrvRec
Local lt:=.F.
Local cFiltBOq	 := ""
Local nIndice		 := 0 

Private cMedRes	 := ""
Private nGDOpc	 := GD_INSERT + GD_UPDATE + GD_DELETE
Private aTela    := {}, aGets := {}
Private aCols	 := {}, aHeader := {}, aAux := {}, nUBOQ := 0, nLBOQ := 0, OBOQ
Private oFolder  := 0
Private cCpoBOQ  := ""
Private cGczCodPla
Private nRecalc    := 0
Private nGrvRecalc := 0
Private lMsTela	:=.F.

Default cProgram := ""                                                                    
Default cStatus  := ""                                                                    
Default lAjust:=.F.                                                                    

//Inclui := .T.

If cStatus $ '24'
	MsgInfo(STR0028)
	Return()
ElseIf !Empty(cElegi)
	BOM->(DbSetOrder(2))
	BOM->(MsSeek(xFilial("BOM") +cElegi))
	
	//dDatIni := BOM->BOM_DATINI
	dDatFin := BOM->BOM_DATFIM
	dDatIns := BOM->BOM_DTINSC
	cMedRes := BOM->BOM_MEDRSP
	cCodLoc := BOM->BOM_CODLOC
EndIf


cFiltBOq := "  BOQ_PROGRA = '"+cProgram+"'"
If Empty(dDatIni)
	dDatIni := dDataBase
EndIf
Inclui := .F.
//nLBOQ := HS_BDados("BOQ", @aHeader, @aCols, @nUBOQ, 3,,cFiltBOq , , , , ,,,,,,,,,,,,)

//verifica se o ํndice existe //12-07
If TCCanOpen("BOQ","6")
	nIndice := 6
Else
	nIndice := 2
EndIf

BOQ->(DbSetOrder(nIndice))//BOQ_FILIAL + BOQ_VIDA + BOQ_PROGRA
//Inclusใo de trecho para montar a tela da inclusใo do planejamento com base no cabe็alho da tabela BOQ 
Store Header "BOQ" TO aHeader For .T.
If BOQ->(MsSeek(xFilial("BOQ") + cVida + cProgram ))
	Store COLS "BOQ" TO aCols FROM aHeader VETTRAB aAux While BOQ->(BOQ_FILIAL + BOQ_VIDA + BOQ_PROGRA) == xFilial("BOQ") + cVida + cProgram
Else
	Store COLS Blank "BOQ" TO aCols FROM aHeader
EndIf
Inclui := .T.

aSize	:= MsAdvSize(.T.)

aAdd( aObjects, { 100, 020, .T., .T.} )
aAdd( aObjects, { 100, 070, .T., .T.} )
aAdd( aObjects, { 100, 010, .T., .T.} )
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPPanel := MsObjSize( aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlgPlan TITLE cCadastro + IIf( !EMpty(cProgram)," - Programa: " + cProgram,"") From 000, 000 To 500, 700 Of oMainWnd Pixel   //000 000 400 600


oPPesq	:=	tPanel():New(000, 000,, oDlgPlan,,,,,, 500, 700)
oPPesq:Align := CONTROL_ALIGN_ALLCLIENT

DEFINE FONT oFont1 NAME "Arial" SIZE 10,15 BOLD

aCboDur :={STR0005,STR0006,STR0007,STR0008}//"Dia(s)","Semana(s)","Mes(es)","Ano(s)"

@020,010 SAY STR0009    SIZE 300,50 FONT oFont1 PIXEL COLOR CLR_HBLUE OF oPPesq //"Perํodo"
@020,050 MsGet oEdtPer    Var cEdtPer Size 020,010 COLOR CLR_BLACK PIXEL  OF oPPesq Picture "999"
@020,080 SAY STR0010    SIZE 300,50 FONT oFont1 PIXEL COLOR CLR_HBLUE OF oPPesq //"Dura็ใo"
@020,120 COMBOBOX oCboDur Var cCboDur ITEMS aCboDur SIZE 092,010          OF oPPesq PIXEL COLOR CLR_HBLUE
oBtRecalc := tButton():New(018, 213,STR0029, oPPesq, {|| MsgRun(STR0003,, {||PlsRecalc(oBOQ,aCboDur,cCboDur,cEdtPer,aCpCols,@nRecalc)})}, 030, 012,,,, .T.) //"Gerar"###"Gerando Planejamento"
oBtGrvRec := tButton():New(018, 250,STR0030, oPPesq, {|| MsgRun(STR0003,, {||PlsGrvRec(cProgram,@nGrvRecalc)})}, 030, 012,,,, .T.) //"Gerar"###"Gerando Planejamento"

oBOQ := MsNewGetDados():New(040, 005, 225, 345,nGDOpc,,,,,,99999,,,, oPPesq, aHeader, aCols)

If !Empty(cVida)
	If nIndice == 6 
		cChave   := cVida+cProgram
	Else
		cChave	  := cVida+cElegi
	EndIf
	dbSelectArea("BOQ")
	dbSetOrder(nIndice)
	dbGoTop()
	
	If BOQ->(DbSeek(xFilial("BOQ") + cChave))
		lExist := .T.
		GeraAcols(aCols,aHeader,oBOQ,dDatExam,cChave,lExist,,,,cCodLoc)
	Else
		If !lPassou
			oBOQ:aCols := {}
			lPassou  := .T.
		EndIf
		
		dbSelectArea("BOD")
		BOD->(dbSetOrder(1))//BOD_FILIAL, BOD_CODPRO, BOD_ITEM, BOD_PROCED
		BOD->(dbGoTop())
		
		If BOD->(DbSeek(xFilial("BOD") + cProgram))
			While BOD->(!EOF())
				cRisco := Alltrim(BOD->BOD_RISCO)
				
				If cRisco == Alltrim(BOM->BOM_GRARIS)
					
					cCodTab := BOD->BOD_CODTAB
					cProced := BOD->BOD_PROCED
					cItem   := BOD->BOD_ITEM
					cPreAge := BOD->BOD_PREAGE
					cCodDis := BOD->BOD_CODDIS
					
					If BOD->(BOD_CODPRO+BOD_ITEM+BOD_PROCED) == cProgram+cItem+cProced
						If !BOD->BOD_DATPRO == CTOD(" / / ")
							//VIDA 		ELEGI   PROCED	DT SUGER	COD AGEND DT AGEND	HOR AGEND	STATUS
							If lDiaVali
								dDatExam := DataValida(BOD->BOD_DATPRO)
							Else
								dDatExam := BOD->BOD_DATPRO
							EndIf
							
							GeraAcols(aCols,aHeader,oBOQ,dDatExam,cChave,lExist,cPreAge,cCodDis,cRisco,cCodLoc)
						Else
							nPerio := BOD->BOD_PERIOD // 0=Durante Programa;1=Semana;2=Mes;3=Ano
							cDura  := BOD->BOD_DURACA
							
							If BOD->BOD_FATGER == '1' // Por Periodo
								If cDura == '0'//Durante o programa
									nQtdDias := dDatFin - dDatIni
									dDtCalc  := dDatIns
									For nP := 1 To nPerio
										
										If lDiaVali
											dDatExam := DataValida(dDtCalc +Round((nQtdDias / nPerio),0))
										Else
											dDatExam := dDtCalc +(nQtdDias / nPerio)
										EndIf
										
										dDtCalc := dDatExam
										GeraAcols(aCols,aHeader,oBOQ,dDatExam,cChave,lExist,cPreAge,cCodDis,cRisco,cCodLoc)
									Next nP
									
								ElseIf cDura == '2' //Semana
									dDtCalc := dDatIns
									
									While dDtCalc <= dDatFin
										
										If lDiaVali
											dDatExam := DataValida(dDtCalc + Round((nSem / nPerio),0))
										Else
											dDatExam := dDtCalc + (nSem / nPerio)
										EndIf
										
										dDtCalc := dDatExam
										If dDtCalc <= dDatFin
											GeraAcols(aCols,aHeader,oBOQ,dDatExam,cChave,lExist,cPreAge,cCodDis,cRisco,cCodLoc)
										EndIf
									EndDo
									
								ElseIf cDura == '3' //Mes
									dDtCalc := dDatIns
									While dDtCalc <= dDatFin
										
										If lDiaVali
											dDatExam := DataValida(dDtCalc + Round((nMes / nPerio),0))
										Else
											dDatExam := dDtCalc + (nMes / nPerio)
										EndIf
										
										dDtCalc := dDatExam
										If dDtCalc <= dDatFin
											GeraAcols(aCols,aHeader,oBOQ,dDatExam,cChave,lExist,cPreAge,cCodDis,cRisco,cCodLoc)
										EndIf
									EndDo
									
								Else //Ano
									dDtCalc := dDatIns
									While dDtCalc <= dDatFin
										
										If lDiaVali
											dDatExam := DataValida(dDtCalc + Round((nAno / nPerio),0))
										Else
											dDatExam := dDtCalc + (nAno / nPerio)
										EndIf
										
										dDtCalc := dDatExam
										If dDtCalc <= dDatFin
											GeraAcols(aCols,aHeader,oBOQ,dDatExam,cChave,lExist,cPreAge,cCodDis,cRisco,cCodLoc)
										EndIf
									EndDo
								EndIf
							Else //BOD->BOD_FATGER == '0'
								If cDura == '1'//Dias
									nQtdDias := BOD->BOD_PERIOD
									dDtCalc := dDatIns
									
									If lDiaVali
										dDatExam := DataValida(dDtCalc +Round((nQtdDias ),0))
									Else
										dDatExam := dDtCalc + nQtdDias
									EndIf
									
									dDtCalc := dDatExam
									GeraAcols(aCols,aHeader,oBOQ,dDatExam,cChave,lExist,cPreAge,cCodDis,cRisco,cCodLoc)
									
								ElseIf cDura == '2' //Semana
									dDtCalc := dDatIns
									
									If lDiaVali
										dDatExam := DataValida(dDtCalc + Round((nSem * nPerio),0))
									Else
										dDatExam := dDtCalc + (nSem * nPerio)
									EndIf
									
									dDtCalc := dDatExam
									GeraAcols(aCols,aHeader,oBOQ,dDatExam,cChave,lExist,cPreAge,cCodDis,cRisco,cCodLoc)
									
								ElseIf cDura == '3' //Mes
									dDtCalc := dDatIns
									
									If lDiaVali
										dDatExam := DataValida(dDtCalc + Round((nMes * nPerio),0))
									Else
										dDatExam := dDtCalc + (nMes * nPerio)
									EndIf
									
									dDtCalc := dDatExam
									GeraAcols(aCols,aHeader,oBOQ,dDatExam,cChave,lExist,cPreAge,cCodDis,cRisco,cCodLoc)
									
								Else //Ano
									dDtCalc := dDatIns
									
									If lDiaVali
										dDatExam := DataValida(dDtCalc + Round((nAno * nPerio),0))
									Else
										dDatExam := dDtCalc + (nAno * nPerio)
									EndIf
									
									dDtCalc := dDatExam
									GeraAcols(aCols,aHeader,oBOQ,dDatExam,cChave,lExist,cPreAge,cCodDis,cRisco,cCodLoc)
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
				BOD->(dbSkip())
			EndDo
			RestArea(aAreaBOD)
		EndIf
	EndIf
EndIf

HS_GDPesqu(aHeader,aCols,oBOQ,oPPesq,001,.T.)
aCpCols := aClone(oBOQ:ACOLS)

        /*
If (dDatIni != CTOD("") .And. dDatFin != CTOD("")) .And. (dDatIni < dDataBase)

	PLSaCols(aCols,aHeader,oBOQ)
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nOpcA:=1,oDlg:End()},{||nOpcA:=0,oDlg:End()},,)
	
Else  */   
If lAjust ==.F.  //Ajuste feito pela Fun็ใo de Usuario PLATUBOQ
	ACTIVATE MSDIALOG oDlgPlan CENTERED ON INIT EnchoiceBar(oDlgPlan,{|| nOpcA:=1,oDlgPlan:End()},{||nOpcA:=0,oDlgPlan:End()},,)
Else
		Begin Transaction
			GrvPlan(cProgram)
		End Transaction
Endif
	
If nOpcA == 1  
	If nRecalc <> nGrvRecalc .and. !(lMsTela )
		MsgInfo(STR0022)//"O Planejamento foi Recalculado e nใo foi Gravado!"  
	Else
		Begin Transaction
			GrvPlan(cProgram)
		End Transaction
	EndIf

ElseIf FunName() == 'HSPAHMA7' .and. (cStatus=='0') .or. !MsSeek(xFilial("BOQ")+cChave)      //.or. !Empty(cStatus) )
	If !(lMsTela )
	If MsgYesNo(STR0023) //"Nใo foi concluido a Inscri็ใo do Paciente, Deseja Mant๊-lo como Elegivel?"
	cPrograma := BOM->BOM_CODPRO
	dbSelectArea("BOQ")
	BOQ->(dbSetOrder(2))//BOQ_FILIAL, BOQ_VIDA, BOQ_ELEGIB
	If !MsSeek(xFilial("BOQ")+cChave)//Se houve planejamento nao mexe no status da BOM
		dbSelectArea("BOM")
		dbSetOrder(1)//BOM_FILIAL, BOM_CODPRO, BOM_VIDA, BOM_STATUS
		If MsSeek(xFilial("BOM")+cPrograma+cVida)
			RecLock("BOM", .F.)
			BOM->BOM_STATUS := "0" //Elegivel
				BOM->BOM_DTINSC := CTOD(" / / ")
			MsUnlock()
		EndIf
		EndIf
	Else
//GeraAcols(aCols,aHeader,oBOQ,dDatExam,cChave,lExist,cPreAge,cCodDis,cRisco,cCodLoc)
	MsgInfo(STR0024)//"Favor, ้  Necessario Gravar o Planejamento para Inscrever o Beneficiแrio!" 
	PLSPRO05(cVida,cElegi,cProgram,cCodRis,cStatus,lAjust)   
		Endif
	EndIf
EndIf
	
/*If !Empty(cEdtPer)
	PLSaCols(aCols,aHeader,oBOQ,aCboDur,cCboDur,oCboDur,oEdtPer,cEdtPer)
EndIf*/


Return(Nil)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GeraAcols   บAutor  ณMicrosiga        บ Data ณ  09/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para alimentar o aCols.                             บฑฑ 
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GeraAcols(aCols,aHeader,oBOQ,dDatExam,cChave,lExist,cPreAge,cCodDis,cRisco,cCodloc)
Local nInd := 0                   
Local aArea := getArea()
Private aAux := {}
Default lExist 	:= .F.
Default cCodLoc	:=""
Default cPreAge	:=""    
Default cCodDis	:=""    
Default cRisco	:=""    

If lExist
	Store Header "BOQ" TO aHeader For .T.
	DbSelectArea("BOQ")
	DbSetOrder(2)//BOQ_FILIAL, BOQ_VIDA, BOQ_ELEGIB
	
	If MsSeek(xFilial("BOQ")+cChave)
		Store COLS "BOQ" TO oBOQ:aCols FROM oBOQ:aHeader VETTRAB aAux While BOQ->BOQ_FILIAL == xFilial("BOQ").And. BOQ->(BOQ_VIDA+BOQ_ELEGIB) == cChave
	Else
		Store COLS Blank "BOQ" TO oBOQ:aCols FROM oBOQ:aHeader
	EndIf
	// ALIMENTA A DESCRICAO DO MEDICO E PROCEDIMENTO
	For nInd := 1 To Len(oBOQ:aCols)
		nPosCodTab := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_CODTAB"})
		nPosProced := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_PROCED"})
		nPosMedRsp := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_MEDRSP"})
		nPosDesPro := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_DESPRO"})
		nPosNomMed := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_NOMMED"})
		nPosCodLoc := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_CODLOC"})
		nPosLocal  := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_LOCAL"})

		oBOQ:aCols[nInd,nPosDesPro] := POSICIONE('BR8',1,XFILIAL('BR8')+oBOQ:aCols[nInd,nPosCodTab]+oBOQ:aCols[nInd,nPosProced],'BR8_DESCRI') 

		If !Empty(oBOQ:aCols[nInd,nPosMedRsp])
	   		oBOQ:aCols[nInd, nPosNomMed] :=  Posicione("SRA",11,xFilial("SRA") + oBOQ:aCols[nInd,nPosMedRsp], "RA_NOME")
	 	EndIf		
	 	
	 	If !Empty(oBOQ:aCols[nInd,nPosCodLoc])
	   		oBOQ:aCols[nInd, nPosLocal] :=  Posicione('BD1',1,xFilial('BD1')+PlsIntPad()+BOM->BOM_CODLOC,'BD1_DESLOC')
	 	EndIf
	 	
	Next nInd
	
Else
	aadd(oBOQ:aCols,{})
	nTamCols := Len(oBOQ:aCols)
	nInd     := 1

	For nInd := 1 To Len(oBOQ:aHeader)+1
		aadd(oBOQ:aCols[nTamCols],nInd)
		If nInd <= Len(oBOQ:aHeader)
			oBOQ:aCols[nTamCols,nInd]    := CriaVar(oBOQ:aHeader[nInd,2])
			
			If AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "ITEM"
				oBOQ:aCols[nTamCols,nInd] := GETSXENUM('BOQ','BOQ_ITEM')
				
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "VIDA"
				oBOQ:aCols[nTamCols,nInd] := SubStr(cChave,1,8) //cVida
		
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "ELEGIB"
				oBOQ:aCols[nTamCols,nInd] := SubStr(cChave,9,6) //cElegi  
				
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "NOME"
				oBOQ:aCols[nTamCols,nInd] :=  Posicione("BTS",1,xFilial("BTS") + SubStr(cChave,1,8), "BTS_NOMUSR") //Posicione("BOM",3,xFilial("BOM") +  SubStr(cChave,1,8), "BOM_NOME")
					
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "CODTAB"
				oBOQ:aCols[nTamCols,nInd] := cCodTab
				
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "PROCED"
				oBOQ:aCols[nTamCols,nInd] := cProced
				
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "DESPRO"
				oBOQ:aCols[nTamCols,nInd] := POSICIONE('BR8',1,XFILIAL('BR8')+cCodTab+cProced,'BR8_DESCRI')
				
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "DATSUG"
				oBOQ:aCols[nTamCols,nInd] := dDatExam
				
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "CODAGE"
				oBOQ:aCols[nTamCols,nInd] := ""
				
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "DATAGE"
				If !BOD->BOD_DATPRO == CTOD(" / / ")
					oBOQ:aCols[nTamCols,nInd] := CTOD(" / / ")
				EndIf
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "HORAGE"
				oBOQ:aCols[nTamCols,nInd] := ""//cHorAge
				
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "STATUS"
				oBOQ:aCols[nTamCols,nInd] := "0" //cStatus
			
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "PREAGE"
				oBOQ:aCols[nTamCols,nInd] := cPreAge
			
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "CODDIS"
				oBOQ:aCols[nTamCols,nInd] := cCodDis
					
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "PROGRA"
				oBOQ:aCols[nTamCols,nInd] := BOM->BOM_CODPRO
				
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "RISCO"
				oBOQ:aCols[nTamCols,nInd] := cRisco
			
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "MEDRSP"
				oBOQ:aCols[nTamCols,nInd] := cMedRes   
				
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "NOMMED"
				oBOQ:aCols[nTamCols,nInd] :=  Posicione("SRA",11,xFilial("SRA") + cMedRes, "RA_NOME")
				
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "CODLOC"
				oBOQ:aCols[nTamCols,nInd] := cCodLoc   
				
			ElseIf AllTrim(Subs(oBOQ:aHeader[nInd,2],5,6)) == "LOCAL"
				oBOQ:aCols[nTamCols,nInd] :=  Posicione('BD1',1,xFilial('BD1')+PlsIntPad()+cCodLoc,'BD1_DESLOC')
			Endif
			
		Else
			oBOQ:aCols[nTamCols,nInd] := .F.
		Endif
		ConfirmSx8()
	Next nInd   
	
	nPosdtSug := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_DATSUG"}) 
	aSort(oBOQ:aCols,,,{|x,y| x[nPosdtSug] < y[nPosdtSug]})

EndIf
RestArea(aArea)
Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GrvPlan  บAutor  ณMicrosiga           บ Data ณ  09/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para gerar o Planejamento do paciente.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GrvPlan(cProgram)
Local aArea		:= getArea()
Local nInd      := 0
Local lAlt
Local nPItem   := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_ITEM"})
Local nPVida   := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_VIDA"})
Local nPElig   := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_ELEGIB"})  
Local nPTab    := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_CODTAB"})
Local nPProc   := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_PROCED"})
Local nPDtSu   := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_DATSUG"})
Local nPCodAg  := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_CODAGE"})
Local nPDtAg   := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_DATAGE"})
Local nPHorAg  := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_HORAGE"})
Local nPStatus := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_STATUS"})
Local nPPreAg  := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_PREAGE"})
Local nPCodDis := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_CODDIS"})
Local nPRisco  := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_RISCO"})
Local nPMedRes := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_MEDRSP"})
Local nNome	   := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_NOME  "})
Local nCodLoc  := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_CODLOC"})
Local nLocal   := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_LOCAL "})
Local cmsn0		:=""
Local cPlaneOk	:=""
Local cmsn1		:=""
Local cPlaneCa	:=""
Local cmsn2		:=""
Local cPlaneNa	:=""
Local lMsn		:=.F.

dbSelectArea("BOQ")
dbSetOrder(1)//BOQ_FILIAL, BOQ_ITEM, BOQ_VIDA, BOQ_ELEGIB, BOQ_CODTAB, BOQ_PROCED, BOQ_DATSUG, BOQ_CODAGE
dbGoTop()

For nInd := 1 To Len(oBOQ:aCols)
	lAlt:= !BOQ->(DbSeek(xFilial("BOQ") + oBOQ:aCols[nInd,nPItem]+oBOQ:aCols[nInd,nPVida]+oBOQ:aCols[nInd,nPElig]+oBOQ:aCols[nInd,nPTab]+oBOQ:aCols[nInd,nPProc]))
	If !lAlt .AND. oBOQ:aCols[nInd, Len(oBOQ:aHeader)+1 ] == .T.		
		If !(oBOQ:aCols[nInd,nPStatus] $ '235')
			RecLock("BOQ", .F., .F. )		
	   		BOQ->BOQ_STATUS := '5'
			BOQ->(MsUnlock())
			cPlaneOk+= "|"+oBOQ:aCols[nInd,nPItem] +" | , | "
			cmsn0:=STR0025
			lMsn:=.T.				 
		ElseIf oBOQ:aCols[nInd,nPStatus] $ '5'
		    cPlaneCa+= "|"+oBOQ:aCols[nInd,nPItem] +" | , | "
			cmsn1:=STR0026
			lMsn:=.T.
		Else
			cPlaneNa+= "|"+oBOQ:aCols[nInd,nPItem] +" | , | "
			cmsn2:=STR0027
			lMsn:=.T.	
			Loop
		Endif 
		
	EndIf   
	If !oBOQ:aCols[nInd, Len(oBOQ:aHeader)+1 ] 
		BOQ->(RecLock("BOQ",lAlt))
		BOQ->BOQ_FILIAL := xFilial("BOQ")
		
		If nPItem > 0
			BOQ->BOQ_ITEM   := oBOQ:aCols[nInd,nPItem]
		EndIf
		If nPVida > 0
			BOQ->BOQ_VIDA   := oBOQ:aCols[nInd,nPVida]
		EndIf
		If nPElig > 0
			BOQ->BOQ_ELEGIB := oBOQ:aCols[nInd,nPElig]
		EndIf 
		If nPTab > 0
			BOQ->BOQ_CODTAB := oBOQ:aCols[nInd,nPTab]
		EndIf
		If nPProc > 0
			BOQ->BOQ_PROCED := oBOQ:aCols[nInd,nPProc]
		EndIf
		If nPDtSu > 0
			BOQ->BOQ_DATSUG := oBOQ:aCols[nInd,nPDtSu]
		EndIf
		If nPCodAg > 0
			BOQ->BOQ_CODAGE := oBOQ:aCols[nInd,nPCodAg]
		EndIf
		If nPDtAg > 0
			BOQ->BOQ_DATAGE := oBOQ:aCols[nInd,nPDtAg]
		EndIf
		If nPHorAg > 0
			BOQ->BOQ_HORAGE := oBOQ:aCols[nInd,nPHorAg]
		EndIf
		If nPStatus > 0
			BOQ->BOQ_STATUS := oBOQ:aCols[nInd,nPStatus]
		EndIf
		If nPPreAg > 0
			BOQ->BOQ_PREAGE := oBOQ:aCols[nInd,nPPreAg]
		EndIf
		If nPCodDis > 0
			BOQ->BOQ_CODDIS := oBOQ:aCols[nInd,nPCodDis]
		EndIf  
		If nPRisco > 0
			BOQ->BOQ_RISCO := oBOQ:aCols[nInd,nPRisco]
		EndIf 
		If nPMedRes > 0
			BOQ->BOQ_MEDRSP := oBOQ:aCols[nInd,nPMedRes]
		Endif
		If nNome > 0
			BOQ->BOQ_NOME := oBOQ:aCols[nInd,nNome]
		Endif
		If nCodLoc > 0
			BOQ->BOQ_CODLOC := oBOQ:aCols[nInd,nCodLoc]
		Endif
		If nLocal > 0
			BOQ->BOQ_LOCAL := oBOQ:aCols[nInd,nLocal]
		Endif
		BOQ->BOQ_PROGRA := cProgram
		ConfirmSx8()	
		BOQ->(MsUnlock())
	EndIf             

Next nInd
If lMsn
	MsgInfo(cmsn0+cPlaneOk+cmsn1+cPlaneCa+cmsn2+cPlaneNa)
Endif
lMsTela:=.T.
RestArea(aArea)
Return   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PlsPreAg บAutor  ณMicrosiga           บ Data ณ  10/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que lista os pacientes Pr้-Agendados, chamada no    บฑฑ
ฑฑบ          ณ A็๕es Relacionadas no momento de agendar.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PlsPreAg(dDataInicial,dDataFinal,cCodDis,cNroSeqE,cItemAg,cMatVid,cCodSin,nDias) 

Local cTitulo    := STR0004  //"Agendamentos Sugeridos"
Local aArea	     := GetArea()
Local cFilter    := ""   
Local cProgram   := ""
Local aObjects   := {}
Local nInd       := 1
Local nTamCols   := 0
Local nPVida     := 0   
Local nOpca	     := 0
Local cRetPac    := ""
Local cFilterBOQ :=""
Local cPerg      := "PMPRO04" 
Local cCodloc    :=""
Local cPrograma	 := ""
Local dDatIni
Local dDatInF
Local aJoinBOM	 :={} 
Local cFilteBom	 :=""
Local lConsProm	:= .F.
Local aRetPro	:={}
Default cMatVid  := ""  
Default cItemAg  := ""  
Default cNroSeqE := "" 
                
Private aCols	 := {}, aHeader := {}, nUBOQ := 0, nLBOQ := 0, OBOQ
Private oMBrwBOQ
Private dDIniBOQ	:= dDataInicial
Private dDFimBOQ    := dDataFinal

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ	MBrowse da dos pacientes elegiveis/inscritos ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	

DbSelectArea("BOQ")
cAlias := "BOQ" 

If (FunName() != 'HSPAHM54'   .AND. FunName() != 'HSPAHMA7' )
	If !Empty(cNroSeqE)
		cFilter := " BOQ_FILIAL == '"+xFilial("BOQ")+"' "
		cFilter += " .AND. BOQ_ELEGIB == '"  + cNroSeqE + "'"
		cFilter += " .AND. D_E_L_E_T_ <> '*'"    
		
		oMBrwBOQ:= FWMBrowse():New()
		oMBrwBOQ:SetAlias(cAlias)
		oMBrwBOQ:SetDescription(cTitulo)
		oMBrwBOQ:SetFilterDefault(cFilter)
		oMBrwBOQ:DisableDetails()
//		oMBrwBOQ:lLocate := .T.
		oMBrwBOQ:SetWalkThru(.F.)
		oMBrwBOQ:SetAmbiente(.F.)
		oMBrwBOQ:ForceQuitButton()
		oMBrwBOQ:SetMenuDef("PLSPRO05")
		oMBrwBOQ:Activate()  
	Else	
		cFilter := " BOQ_FILIAL == '"+xFilial("BOQ")+"' "
		//cFilter += " .AND. (BOQ_CODDIS ==  '"+cCodDis+"' "
		//cFilter += " .OR.  BOQ_CODDIS == '" +Space(TamSx3('BOQ_CODDIS')[1]) + "' )"
		cFilter += " .AND. BOQ_PREAGE == '0' "
		cFilter += " .AND. BOQ_STATUS == '0' "

	If FunName() != 'HSPAHM54' 
		cFilter += " .AND. BOQ_DATSUG >= '"+DTOS(dDataInicial)+"'
		cFilter += " .AND. BOQ_DATSUG <= '"+DTOS(dDataFinal)+"' "
   EndIf

		cFilter += " .AND. D_E_L_E_T_ <> '*'"
	   
		oMBrwBOQ:= FWMarkBrowse():New()
		oMBrwBOQ:SetAlias(cAlias)
		oMBrwBOQ:SetFieldMark( 'BOQ_IDMARK' )
		oMBrwBOQ:SetDescription(cTitulo)
		oMBrwBOQ:SetFilterDefault(cFilter)
	//	oMBrwBOQ:DisableDetails()
	//	oMBrwBOQ:lLocate := .T.
		oMBrwBOQ:SetWalkThru(.F.)
		oMBrwBOQ:SetAmbiente(.F.)
		oMBrwBOQ:ForceQuitButton()
		oMBrwBOQ:SetMenuDef("PLSPRO05")
		oMBrwBOQ:Activate()
	EndIf
	
Else
	
	cFilterBOQ += " BOQ_FILIAL = '"+xFilial("BOQ")+"' "
	cFilterBOQ += "AND BOQ_STATUS = '1' "
	cFilterBOQ += "AND BOQ_CODAGE = '' "
	cFilterBOQ += "AND BOQ_PREAGE = '0' "	
	If  !Empty(cMatVid) .And. FunName() == 'HSPAHM54'
		cFilterBOQ += "AND BOQ_VIDA = '" +cMatVid+ "'"
	Else 

		If Pergunte(cPerg, .T.) 
			cCodloc    := MV_PAR01
			dDatIni    := MV_PAR02
			dDatInF	   := MV_PAR03
			If Type("MV_PAR04") # "U"
				cPrograma  := MV_PAR04
		Endif
		Endif
	       
		If !Empty(cCodloc)
	   		cFilteBom:= "  AND BOM_CODLOC = '"+cCodloc+"' "   
	    Endif
		If !Empty(cPrograma)
	   		cFilterBOQ += "  AND BOQ_PROGRA = '"+cPrograma+"' "   
	    Endif
	    
	    IF !Empty(dDatIni)
	   		cFilteBom+= "  AND BOQ_DATSUG >= '" + DTOS(dDatIni) + "'"
	    Endif 
	    
	    IF !Empty(dDatInF)
	   		cFilteBom+= "  AND BOQ_DATSUG <= '" + DTOS(dDatInF) + "'"
	    Endif
	       
       	aJoinBOM := {{" JOIN " + RetSqlName("BOM") + " BOM", "" , "  BOQ.BOQ_ELEGIB  = BOM.BOM_NROSEQ "+cFilteBom +" AND BOM.D_E_L_E_T_ <> '*' AND BOM.BOM_STATUS NOT IN ('2', '4') AND BOM.BOM_FILIAL = '" + xFilial("BOM") + "'", ""}}	                                    
   	EndIf
	Inclui := .F.
	nLBOQ := HS_BDados("BOQ" , @aHeader,@aCols , @nUBOQ , 1   , , cFilterBOQ,        ,        ,        ,         ,        ,        ,        ,        ,        ,     ,        ,         ,           ,         ,         , aJoinBOM)
	Inclui := .T.

	aSize	:= MsAdvSize(.T.)
	
	aAdd( aObjects, { 100, 020, .T., .T.} )
	aAdd( aObjects, { 100, 070, .T., .T.} )
	aAdd( aObjects, { 100, 010, .T., .T.} )
	aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPPanel := MsObjSize( aInfo, aObjects, .T.)
	
	DEFINE MSDIALOG oDlg TITLE cTitulo From 000, 000 To 500, 700 Of oMainWnd Pixel   //000 000 400 600
	
	oBOQ := MsNewGetDados():New(035, 005, 220, 345,0,,,,,,99999,,,, oDlg, aHeader, aCols)    // 000 000 300 500
	
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()},,)  
EndIf

/*If Select("TRBBOQ") > 0
  TRBBOQ->(dbCloseArea())
EndIf*/

If nOpca == 1
If FunName() = 'HSPAHM54'
	aRetPro	:=FS_VldUsPr(cGcsCodLoc)
	lConsProm	:= aRetPro[1]
	If  !lConsProm  
		MsgInfo(STR0021)//"Usuario sem Permissใo para Agendamento da Promo็ใo a Sa๚de"
	Return()
	Endif
Endif	
	nPVida  := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_VIDA"})
	
	If nPVida > 0
		cMatVid := oBOQ:aCols[oBOQ:nAt][nPVida]
	EndIf

	cRetPac:= PLSRTGBH(cMatVid)
	If Empty(cRetPac)
		MsgInfo(STR0011) //"A Vida Informada nao esta vinculada a um paciente. "
	Else
		
		nPTab   := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_CODTAB"})
		nPProc  := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_PROCED"})
		nPItem  := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_ITEM"})
		nPProg  := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_PROGRA"})
		
		If nPTab > 0
			cCodTab := oBOQ:aCols[oBOQ:nAt][nPTab]
		EndIf
		
		If nPProc > 0
			cProced := oBOQ:aCols[oBOQ:nAt][nPProc]
		EndIf
		
		If nPItem > 0
			cItemAg := oBOQ:aCols[oBOQ:nAt][nPItem]
		EndIf
		     
		If nPProg > 0
			cProgram := oBOQ:aCols[oBOQ:nAt][nPProg]
		EndIf
		
		//PREENCHIMENTO AUTOMATICO DOS CAMPOS
		dbSelectArea("BOM") 
		dbSetOrder(1)//BOM_FILIAL, BOM_CODPRO, BOM_VIDA, BOM_STATUS
		If BOM->(MsSeek(xFilial("BOM") + cProgram+cMatVid ) )
			If (BOM->BOM_DATFIM <> CTOD("") .And. BOM->BOM_DATFIM < dDataBase) .Or. BOM->BOM_STATUS == '2' //0=Elegivel;1=Inscrito;2=Finalizado;3=Pendencias;4=Bloqueado
				MsgInfo(STR0012+cProgram+STR0013) //"Nใo serแ possํvel realizar o agendamento, pois, o Programa "### " estแ encerrado!"
			Else	
				M->GM8_REGGER := cRetPac
				GBH->(DbSetOrder(1) )
				GBH->(MsSeek(xFilial("GBH") + cRetPac)  )
				M->GM8_NOMPAC := GBH->GBH_NOME
				M->GM8_TELPAC := GBH->GBH_TEL
				
				/*GD4->(DbSetOrder(1) )
				GD4->(MsSeek(xFilial("GD4") + cRetPac ) )*/
				DbSelectArea("GD4")
				GD4->(DbSetOrder(2)) //Gd4_FILIAL + GD4_REGGER
				GD4->(DbSeek(xFilial("GD4") + cRetPac+"1" ))
				M->GM8_MATRIC := GD4->GD4_MATRIC
				M->GM8_CODPLA := GD4->GD4_CODPLA
				cGczCodPla    := GD4->GD4_CODPLA
				M->GM8_DESPLA := Posicione("GCM",2,xFilial("GCM") + M->GM8_CODPLA, "GCM_DESPLA")
				M->GM8_SQCATP := GD4->GD4_SQCATP
				
				/*GD4->(DbSetOrder(1) )
				GD4->(MsSeek(xFilial("GD4") + cRetPac ) )*/
				
				M->GM8_CODPRO := Posicione("GA7",12,xFilial("GA7") + cCodTab+cProced, "GA7_CODPRO")
				M->GM8_DESPRO := Posicione("GA7",12,xFilial("GA7") + cCodTab+cProced, "GA7_DESC") //GA7_FILIAL, GA7_TABPLS, GA7_PROPLS  
				               
				M->GM8_PROMO  := "1" 
				M->GM8_PROGRA := cItemAg // Item sequencial do agendamento   
				
				If Empty(M->GM8_DESPRO)
				    MsgInfo(STR0031)//"Este Procedimento nใo possui vinculo com a Tabela Padrใo do Plano de Saude."                                                                                                                                                                                                                                                                                                                                                                                                                                       
					M->GM8_CODPRO := ""
					M->GM8_PROMO  := "" 
					M->GM8_PROGRA := ""
				EndIf
			EndIf
		EndIf		
	EndIf
EndIf

RestArea(aArea)

Return            

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณ MenuDef ณ Autor ณ Totvs                  ณ Data ณ 21/09/12 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ MenuDef													  ณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
PRIVATE aRotina := {}      
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Opcoes de menu															 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

AaDd( aRotina, { "Visualizar", 			"VIEWDEF.PLSPRO05", 0, MODEL_OPERATION_VIEW,   0, NIL } )//"Visualizar"
AaDd( aRotina, { "Incluir", 			"VIEWDEF.PLSPRO05", 0, MODEL_OPERATION_INSERT, 0, NIL } ) //"Incluir"
AaDd( aRotina, { "Alterar", 			"VIEWDEF.PLSPRO05", 0, MODEL_OPERATION_UPDATE, 0, NIL } ) //"Alterar"
AaDd( aRotina, { "Excluir", 			"VIEWDEF.PLSPRO05", 0, MODEL_OPERATION_DELETE, 0, NIL } ) //"Excluir"
If "HSPAHM53" $ FunName()
	aAdd( aRotina, { STR0014,				"ProAge()"	  , 0, 5, 0, NIL } ) //"Agenda"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fim da rotina															 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Return aRotina  

//---------------------------------------------------------------------------
//ModelDef de inclusใo de pacientes no programa									|
//---------------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruBOQ := FWFormStruct( 1, 'BOQ', /*bAvalCampo*/, /*lViewUsado*/ )
// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( STR0015, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) //'Agendamentos Sugeridos'
// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
oModel:AddFields( 'BOQMASTER', NIL, oStruBOQ )
// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0015 )//'Agendamentos Sugeridos'
// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'BOQMASTER' ):SetDescription( STR0015 ) //'Agendamentos Sugeridos'
Return oModel

//---------------------------------------------------------------------------
//ViewDef de inclusใo de pacientes no programa									|
//---------------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruBOQ := FWFormStruct( 2, 'BOQ' )
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'PLSPRO05' )

If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	If BOQ->BOQ_STATUS <> '0'
		Help( ,, STR0016,, STR0017)// 'Help' ###"Somente planejamento em aberto pode ser alterado!"
		Return()
	EndIf                    
Endif
// Cria o objeto de View                                                      
oView := FWFormView():New()

// Define qual o Modelo de dados serแ utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_BOQ' , oStruBOQ, 'BOQMASTER'   )
oView:EnableTitleView( 'VIEW_BOQ' )

Return oView  
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ProAge   บAutor  ณMicrosiga           บ Data ณ  10/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para alterar o Status do Planejamento.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ProAge()
Local lMlBrw := .T.   
Local cMarca := oMBrwBOQ:Mark()

If lMlBrw
	BOQ->(dbGoTop())
	While !BOQ->(Eof()) 
		If oMBrwBOQ:IsMark(cMarca).AND. BOQ->BOQ_DATSUG >= dDIniBOQ .AND. BOQ->BOQ_DATSUG <= dDFimBOQ  .AND. BOQ->BOQ_STATUS == "0"
			BOQ->(RecLock("BOQ",.F.))
			BOQ_STATUS := "1"
			BOQ->(MsUnlock())
		EndIf
		BOQ->(dbSkip())
	EndDo 
EndIf
		
Return   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PlsGrvPAg  บAutor  ณMicrosiga         บ Data ณ  10/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para alterar o Status do Planejamento, ap๓s o       บฑฑ
ฑฑบ          ณ Agendamento.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PlsGrvPAg(dDatage,cHorAge,cCodAge,cItemAg,nOpc,cRegger) 
Local cCodTab := ""
Local cProced := ""
Local cRisco  := "" 
Local cSinali := "" 
Local cResumo := STR0018 //"Quantidade de dias que antecedem a consulta e que o sinalizador deve disparar. " 
Local dSinali
Local cMatVid	:=""
Local cCodLoc :=""
Default cRegger	:=""
cMatVid:=PLSRTVID(cRegger)

dbSelectArea("BOQ")
BOQ->(DbSetOrder(1)) //BOQ_FILIAL, BOQ_ITEM, BOQ_VIDA, BOQ_ELEGIB, BOQ_CODTAB, BOQ_PROCED, BOQ_DATSUG, BOQ_CODAGE
//If BOQ->(MsSeek(xFilial("BOQ")+cItemAg+cMatVid))
	If nOpc == 3
		If BOQ->(MsSeek(xFilial("BOQ")+cItemAg+cMatVid))
			BOQ->(RecLock("BOQ",.F.))
			BOQ->BOQ_CODAGE := ""
			BOQ->BOQ_DATAGE := CTOD("")
			BOQ->BOQ_HORAGE := ""
			BOQ->BOQ_STATUS := "1" //0=Incluido;1=Lib Agenda;2=Agendado; 3=Realizado;4=Nao Realizado
			BOQ->(MsUnlock())
		EndIf  
	Else
	
		If BOQ->(MsSeek(xFilial("BOQ")+cItemAg+cMatVid))
			BOQ->(RecLock("BOQ",.F.))
			BOQ->BOQ_CODAGE := cCodAge
			BOQ->BOQ_DATAGE := dDatage
			BOQ->BOQ_HORAGE := cHorAge
			BOQ->BOQ_STATUS := "2" //0=Incluido;1=Lib Agenda;2=Agendado; 3=Realizado;4=Nao Realizado
			BOQ->(MsUnlock())
		EndIf  

	cCodTab := BOQ->BOQ_CODTAB
	cProced := BOQ->BOQ_PROCED
	cRisco  := BOQ->BOQ_RISCO
	cCodPro := BOQ->BOQ_PROGRA
	
	If BOQ->( FieldPos('BOQ_CODLOC') ) > 0
		cCodLoc := BOQ->BOQ_CODLOC
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalculo dos dias do sinalizador.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("BOD")
	BOD->(DbSetOrder(2)) //BOD_FILIAL, BOD_CODTAB, BOD_PROCED, BOD_RISCO
	
	If BOD->(DBSeek(xFilial("BOD")+cCodTab+cProced+cRisco))  
		cSinali := BOD->BOD_CODSIN 
		If !Empty(BOD->BOD_CODSIN) .And. !Empty(BOD->BOD_PERSIN)
			dSinali:= DataValida(dDatage-BOD->BOD_PERSIN)
		EndIf
	EndIf  

	dbSelectArea("BOJ")
	BOJ->(DbSetOrder(1))//BOJ_FILIAL, BOJ_CODSIN
	  
	If BOJ->(MsSeek(xFilial("BOJ")+cSinali))
		
		dbSelectArea("BOS")
		BOS->(RecLock("BOS",.T.))
		BOS->BOS_FILIAL := xFilial("BOS")
		BOS->BOS_RESUMO := cResumo
		BOS->BOS_DATSIN := dSinali
		BOS->BOS_HORAIN := Time() 
		BOS->BOS_TEXTO  := BOJ->BOJ_TEXTO
		BOS->BOS_ACAO   := BOJ->BOJ_TXTACA
		BOS->BOS_ORIGEM := FunName()
		BOS->BOS_DESTIN := BOJ->BOJ_DESTIN
		BOS->BOS_CODSIN := BOJ->BOJ_CODSIN
		BOS->BOS_AUTOMA := '1'
		BOS->BOS_VIDA   := cMatVid
		BOS->BOS_STATUS := '0'
		BOS->BOS_NROSEQ := GETSXENUM('BOS','BOS_NROSEQ',, 1)
		BOS->BOS_CODPRO := cCodPro
		If BOS->( FieldPos('BOS_CODLOC') ) > 0
			BOS->BOS_CODLOC :=cCodLoc
		Endif
		BOS->(MsUnlock())
	EndIf
EndIf
	
ConfirmSx8()
     
Return    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PlsAtuBOQ  บAutor  ณMicrosiga         บ Data ณ  11/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o status do Planejamento - BOQ e da movimenta็ใo  บฑฑ
ฑฑบ          ณ BOM logo ap๓s o atendimento - HSPAHM24.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PlsAtuBOQ(cPacien,cIteBoq)
Local cMatVid	 := ""
Local cProgram	:= ""

cMatVid := PLSRTVID(cPacien)

dbSelectArea("BOQ")
dbSetOrder(1)//BOQ_FILIAL, BOQ_VIDA, BOQ_ELEGIB

If BOQ->(MsSeek(xFilial("BOQ")+cIteBoq))
	cProgram := BOQ->BOQ_PROGRA
	//While BOQ->(!EOF()) .And. BOQ->BOQ_VIDA == cMatVid
		If	BOQ->BOQ_STATUS == '2'//0=Incluido;1=Lib Agenda;2=Agendado; 3=Realizado;4=Nao Realizado
			BOQ->(RecLock("BOQ",.F.))
			BOQ->BOQ_STATUS := "3"
			BOQ->(MsUnlock())
		EndIf
		BOQ->(dbSkip())
	//EndDo
EndIf   

//----------------------------------------------------------------------------------------------------|
// Atualiza o status da movimenta็ใo BOM, logo ap๓s o paciente cumprir suas pendencias de consultas,  |
// retornando status para inscrito.																	  |
//----------------------------------------------------------------------------------------------------|

dbSelectArea("BOM")
dbSetOrder(1)//BOM_FILIAL, BOM_CODPRO, BOM_VIDA, BOM_STATUS

If BOM->(MsSeek(xFilial("BOM")+cProgram+cMatVid))
	If BOM->BOM_STATUS == "3" //0=Elegivel;1=Inscrito;2=Finalizado;3=Pendencias;4=Bloqueado
		BOM->(RecLock("BOM",.F.))
		BOM->BOM_STATUS := "1"
		BOM->(MsUnlock())
	EndIf
EndIf

Return

//--------------------------------------------------------------------------
//VALID dos campos do formulario de cadastro dos programas 					|
//--------------------------------------------------------------------------
Function PlsVldBOQ()
Local cCpo    := ReadVar() 
Local lRet    := .T.
Local cTabPad := ""  
//Local oModel  := FwModelActive()  
Local nPTab    := 0

If ValType(oBOQ) <> 'U'
	nPTab := Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_CODTAB"})
EndIf

If "BOQ_CODTAB" $ cCpo
	If (lRet := (Vazio() .OR. BR4->(ExistCpo('BR4',M->BOQ_CODTAB,1))))
		cCpoBOQ := &(cCpo)
	EndIf
           
ElseIf "BOQ_PROCED" $ cCpo  
	If ValType(oBOQ) <> 'U'
	If nPTab > 0
		cTabPad := oBOQ:aCols[oBOQ:nAt][nPTab]                       
		If (lRet := (Vazio() .OR. BR8->(ExistCpo('BR8',cTabPad+M->BOQ_PROCED,1))))
			cCpoBOQ := &(cCpo)
		EndIf
	Else
		lRet := .F.					
	EndIf	
	Else
		If (lRet := (Vazio() .OR. BR8->(ExistCpo('BR8',M->BOQ_CODTAB+M->BOQ_PROCED,1))))
			cCpoBOQ := &(cCpo)
		EndIf
	EndIf
EndIf

Return(lRet)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VldAgend  บAutor  ณMicrosiga          บ Data ณ  11/21/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se o paciente que esta sendo agendado no HSP		  บฑฑ
ฑฑบ          ณ possui planejamento gerado.								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function VldAgend(lOrcm,lAviso)
Local cMatVid := "" 
Local lPerg:=.F.
DEFAULT lOrcm :=.T.
Default lAviso:=.T.
If GM8->( FieldPos('GM8_PROMO') ) > 0
	If M->GM8_PROMO == '0'
		cMatVid :=	PLSRTVID(M->GM8_REGGER)
	
		dbSelectArea("BOQ")
		dbSetOrder(4)//BOQ_FILIAL, BOQ_VIDA
		If BOQ->(dbSeek(xFilial("BOQ")+cMatVid + "1" )) 
		
			While BOQ->(!EOF()) .AND. 	!lPerg .And. BOQ->(BOQ_FILIAL+BOQ_VIDA+BOQ_STATUS) == xFilial("BOQ")+cMatVid + "1"  //0=Incluido;1=Lib Agenda;2=Agendado; 3=Realizado;4=Nao Realizado  ---Somente exibe os que tenha preagendamento
				If BOQ->BOQ_PREAGE == "0"
					lPerg:=.T.
				Endif
				BOQ->(dbSkip())

				
			Enddo
			
			If lPerg .and. lOrcm
			If lAviso
				If MsgYesNo(STR0019) //"Este paciente possui planejamento gerado. Deseja Abri-lo?"
					PlsPreAg(CTOD(""),CTOD(""),"''","","",cMatVid,"","")
				EndIf
			Else
					PlsPreAg(CTOD(""),CTOD(""),"''","","",cMatVid,"","")
			Endif	
			EndIf
		EndIf
	EndIf
EndIf

Return(lPerg)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PlsRecalc   บAutor  ณMicrosiga        บ Data ณ  07/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para alimentar o aCols quando for montar a tela     บฑฑ 
ฑฑบ          ณ do objeto oPlan.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PlsRecalc(oBOQ,aCboDur,cCboDur,cEdtPer,aCpCols,nRecalc)

Local nInd     := 0
Local nA       := 0
Local aAuxC    	:= {}
Local nPDtSu   	:= Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_DATSUG"})  
Local dDataAg  	:= CTOD("")
Local nDiasSum 	:= 1
Local dDatSum  	:= dDataBase
Local dPrimDt  	:= CTOD("")
Local nDiasIni	:= 0 

Private aAux  	:= {}

Default aCboDur := {}
Default cCboDur := ""
Default cEdtPer := ""  

oBOQ:aCols := aClone(aCpCols)
            /*
For nInd := 1 To Len(oBOQ:aHeader)
	If !dDataBase > oBOQ:aCols[nInd,nPDtSu]
		aadd(aAuxC,oBOQ:aCols[nInd])
	EndIf
Next nInd */

If cCboDur == STR0005//"Dia(s)"
	nDiasSum := Val(cEdtPer)	
ElseIf cCboDur == STR0006//"Semana(s)"	
	nDiasSum := (Val(cEdtPer) * 7)	
ElseIf cCboDur == STR0007//"Mes(es)"  
	nDiasSum := (Val(cEdtPer) * 30)              
Else //Ano                         
	nDiasSum := (Val(cEdtPer) * 365)
EndIf      
   
dDatSum 	:= dDatSum + nDiasSum
If nPDtSu > 0
	dPrimDt	:= oBOQ:aCols[1,nPDtSu]  
EndIf	

/*While dPrimDt > dDataBase
	nDiasIni ++
	dPrimDt := dPrimDt -1
EndDo  
*/
                       
For nInd := 1 To Len(oBOQ:aCols)
	If oBOQ:aCols[nInd,nPDtSu] > dDatSum    
		If nDiasIni == 0
			If (nInd - 1) > 0   .AND.  oBOQ:aCols[nInd-1,nPDtSu]  < oBOQ:aCols[nInd,nPDtSu]
				nDiasIni := (oBOQ:aCols[nInd,nPDtSu] - oBOQ:aCols[nInd-1,nPDtSu])
			EndIf
		EndIf
		aadd(aAuxC,oBOQ:aCols[nInd])
	EndIf
Next nInd        

If nDiasIni == 0
	nDiasIni := 1
EndIf
  
If Len(aAuxC) == 0 
	MsgInfo(STR0020) //"Para o periodo informado de participacao no programa nao existe planejamento!"
	Return()
Else
	For nInd := 1 To Len(aAuxC)
		aAuxC[nInd,nPDtSu] :=   IIf  (	(aAuxC[nInd,nPDtSu] - (nDiasSum))  < dDataBase, dDataBase, 	aAuxC[nInd,nPDtSu] - (nDiasSum))
	Next nInd        
EndIf 

oBOQ:SetArray(aAuxC)
oBOQ:oBrowse:Refresh(aAuxC)

aCpCols := aClone(oBOQ:aCols)

nRecalc ++

/*
If !Empty(cEdtPer)
	If !Empty(cCboDur)
		If cCboDur == "Dia(s)"
			aAuxC := {}
			For nInd := 1 To Len(oBOQ:aCols)
				If !dDataBase > oBOQ:aCols[nInd,nPDtSu]
					dDataAg:= oBOQ:aCols[nInd,nPDtSu]+Val(cEdtPer)
					oBOQ:aCols[nInd,nPDtSu] := dDataAg
					aadd(aAuxC,oBOQ:aCols[nInd])
				EndIf
			Next nInd 

		ElseIf cCboDur == "Semana(s)"
			aAuxC := {}
			For nInd := 1 To Len(oBOQ:aCols)
				If !dDataBase > oBOQ:aCols[nInd,nPDtSu]
					dDataAg:= oBOQ:aCols[nInd,nPDtSu]+(Val(cEdtPer)*7)
					oBOQ:aCols[nInd,nPDtSu] := dDataAg
					aadd(aAuxC,oBOQ:aCols[nInd])
				EndIf
			Next nInd 
			
		ElseIf cCboDur == "Mes(es)"  
			aAuxC := {}
			For nInd := 1 To Len(oBOQ:aCols)
				If !dDataBase > oBOQ:aCols[nInd,nPDtSu]
					dDataAg:= oBOQ:aCols[nInd,nPDtSu]+(Val(cEdtPer)*30)
					oBOQ:aCols[nInd,nPDtSu] := dDataAg
					aadd(aAuxC,oBOQ:aCols[nInd])
				EndIf
			Next nInd 
			
		Else //cCboDur == "Ano(s)"
			aAuxC := {}
			For nInd := 1 To Len(oBOQ:aCols)
				If !dDataBase > oBOQ:aCols[nInd,nPDtSu]
					dDataAg:= oBOQ:aCols[nInd,nPDtSu]+(Val(cEdtPer)*360)
					oBOQ:aCols[nInd,nPDtSu] := dDataAg
					aadd(aAuxC,oBOQ:aCols[nInd])
				EndIf
			Next nInd 
		EndIf 
	EndIf 
EndIf
*/
 
Return()
        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PlsGrvRec   บAutor  ณMicrosiga        บ Data ณ  07/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para alimentar o aCols quando for montar a tela     บฑฑ 
ฑฑบ          ณ do objeto oPlan.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PlsGrvRec(cProgram,nGrvRecalc)

Local nInd     := 0
Local nPVida  	:= Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_VIDA"})  
Local nPEleg  	:= Ascan(oBOQ:aHeader,{|x| Alltrim(x[2])=="BOQ_ELEGIB"})  
Local cVida   	:= ""
Local cEleg   	:= ""

For nInd := 1 To 1
	cVida := oBOQ:aCols[nInd,nPVida]
	cEleg := oBOQ:aCols[nInd,nPEleg]
Next nInd        

Begin Transaction

	dbSelectArea("BOQ")
	BOQ->(dbSetOrder(2))//BOQ_FILIAL, BOQ_VIDA, BOQ_ELEGIB
	If BOQ->(dbSeek(xFilial("BOQ")+cVida+cEleg))
		While !BOQ->(EOF()) .And. BOQ->(BOQ_FILIAL+BOQ_VIDA+BOQ_ELEGIB) == xFilial("BOQ")+cVida+cEleg
			BOQ->(RecLock("BOQ",.F.))
			DbDelete()
			BOQ->(MsUnlock())
			BOQ->(dbSkip())
		EndDo
	EndIf
	
	GrvPlan(cProgram)

End Transaction

nGrvRecalc ++
lMsTela:=.T.
Return()
