#Include "Protheus.ch"
#Include "OFIOC310.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC310 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 01/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Graficos PAINEL OFF LINE                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC310(cPAREmp,aPAREmp,cPARPre,aPARPre,aPARGFT,aPARGLB,aPARGQV,aPARAut,cPARAut,lPARAut,nPARTim)
#IFDEF TOP
Local lEmpr := .f.
Local lUsuEmpr := .t.   // Selecionar Empresas      
Private lMarcar := .f.
Private cUsuPerm := "*" // Graficos permitidos do Usuario visualizar 
Private cUsuList := ""  // Lista Automatica de Graficos 
Private lAutom := .f.
Private aVetEmp := {}
Private cEmpr  := ""
Private aEmpr  := {}
Private lPriVez:= .t.
Private cTit   := ""
Private nTime  := GetNewPar("MV_TREFRES",10)
Private aAutom := {}
Private cAutom := ""
Private cTipGraf := ""
Private aGrafico := {}
Private cPrefixo := STR0003
Private aPrefixo := {STR0003,STR0004,STR0005}
Private cTipGFT := cTipGLB := cTipGQV := ""
Private aTipGFT := {"",;
						"FTTTM - "+STR0006,;
						"FTTTA - "+STR0007,;
						"FTPBM - "+STR0008,;
						"FTPBA - "+STR0009,;
						"FTPOM - "+STR0010,;
						"FTPOA - "+STR0011,;
						"FTPCM - "+STR0012,;
						"FTPCA - "+STR0013,;
						"FTSVM - "+STR0014,;
						"FTSVA - "+STR0015,;
						"FTPVM - "+STR0016,;
						"FTPVA - "+STR0017,;
						"FTVNM - "+STR0018,;
						"FTVNA - "+STR0019,;
						"FTVFM - "+STR0020,;
						"FTVFA - "+STR0021,;
						"FTVVM - "+STR0022,;
						"FTVVA - "+STR0023,;
						"FTVUM - "+STR0024,;
						"FTVUA - "+STR0025,;
						"FTVTM - "+STR0026,;
						"FTVTA - "+STR0027}
Private aTipGLB := {"",;
						"LBTTM - "+STR0028,;
						"LBTTA - "+STR0029,;
						"LBPBM - "+STR0008,;
						"LBPBA - "+STR0009,;
						"LBPOM - "+STR0010,;
						"LBPOA - "+STR0011,;
						"LBPCM - "+STR0012,;
						"LBPCA - "+STR0013,;
						"LBVNM - "+STR0018,;
						"LBVNA - "+STR0019,;
						"LBVUM - "+STR0024,;
						"LBVUA - "+STR0025}
Private aTipGQV := {"",;
						"QVTTM - "+STR0030,;
						"QVTTA - "+STR0031,;
						"QVVNM - "+STR0018,;
						"QVVNA - "+STR0019,;
						"QVVFM - "+STR0020,;
						"QVVFA - "+STR0021,;
						"QVVVM - "+STR0022,;
						"QVVVA - "+STR0023,;
						"QVVUM - "+STR0024,;
						"QVVUA - "+STR0025}
Default cPAREmp := ""
Default aPAREmp := aEmpr
Default cPARPre := cPrefixo
Default aPARPre := aClone(aPrefixo)
Default aPARGFT := aClone(aTipGFT)
Default aPARGLB := aClone(aTipGLB)
Default aPARGQV := aClone(aTipGQV)
Default aPARAut := aClone(aAutom)
Default cPARAut := cAutom
Default lPARAut := lAutom
Default nPARTim := nTime
aEmpr := aPAREmp
cPrefixo := cPARPre
aPrefixo := aClone(aPARPre)
aTipGFT  := aClone(aPARGFT)
aTipGLB  := aClone(aPARGLB)
aTipGQV  := aClone(aPARGQV)
aAutom   := aClone(aPARAut)
cAutom   := cPARAut
lAutom   := lPARAut
nTime    := nPARTim
	If !Empty(cPAREmp)
		cEmpr := STR0036+" "
		aEmpr := FS_EMPRESAS() // Levantamento das Empresas
		If len(aEmpr) == 0
			MsgAlert(STR0033,STR0032)
			Return
		EndIf
	Else
		If !FS_VERBASE() // Verifica a existencia dos arquivos envolvidos na Consulta
			MsgAlert(STR0033+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0034+" "+SM0->M0_CODIGO+"/"+SM0->M0_CODFIL,STR0032)
			Return
		EndIf
		aAdd(aEmpr,{ SM0->M0_CODIGO , SM0->M0_CODFIL })
	EndIf
	If len(aEmpr) == 1 .and. (aEmpr[1,1]+aEmpr[1,2]==SM0->M0_CODIGO+SM0->M0_CODFIL)
		cEmpr := Alltrim(SM0->M0_NOMECOM)+" ( "+SM0->M0_CODIGO+"/"+SM0->M0_CODFIL+" )"
	EndIf
	If len(aAutom) == 0
		lAutom := FS_AUTOM("L")
	EndIf
	DEFINE MSDIALOG oGrafPOL FROM 000,000 TO 027,100 TITLE (STR0001+" - "+cEmpr) OF oMainWnd
		@ 181,002 TO 202,232 LABEL (" "+STR0002+" ") OF oGrafPOL PIXEL
		@ 188,005 MSCOMBOBOX oPrefixo VAR cPrefixo ITEMS aPrefixo VALID (oTimeS:lActive:=.f.,FS_PREFGRAF()) SIZE 45,07 OF oGrafPOL PIXEL COLOR CLR_BLUE
		@ 188,050 MSCOMBOBOX oTipGFT VAR cTipGFT ITEMS aTipGFT VALID (oTimeS:lActive:=.f.,FS_GRAFICO(cTipGFT)) SIZE 179,07 OF oGrafPOL PIXEL COLOR CLR_BLUE
		@ 188,050 MSCOMBOBOX oTipGLB VAR cTipGLB ITEMS aTipGLB VALID (oTimeS:lActive:=.f.,FS_GRAFICO(cTipGLB)) SIZE 179,07 OF oGrafPOL PIXEL COLOR CLR_BLUE
		@ 188,050 MSCOMBOBOX oTipGQV VAR cTipGQV ITEMS aTipGQV VALID (oTimeS:lActive:=.f.,FS_GRAFICO(cTipGQV)) SIZE 179,07 OF oGrafPOL PIXEL COLOR CLR_BLUE
	   oTipGLB:lVisible:=.f.
		oTipGQV:lVisible:=.f.
		@ 188,345 BUTTON oEmpr PROMPT UPPER(STR0035) OF oGrafPOL SIZE 49,10 PIXEL ACTION (lEmpr:=.t.,oGrafPOL:End()) WHEN lUsuEmpr
		@ 188,234 BUTTON oIncl PROMPT "=>" OF oGrafPOL SIZE 15,10 PIXEL ACTION (oTimeS:lActive:=FS_AUTOM("I"))
		@ 181,251 TO 202,343 LABEL (" "+STR0037+" ") OF oGrafPOL PIXEL
		@ 188,254 MSCOMBOBOX oAutom VAR cAutom ITEMS aAutom SIZE 39,07 OF oGrafPOL PIXEL COLOR CLR_BLUE WHEN (len(aAutom)>0)
		@ 188,293 BUTTON oExcl PROMPT "X" OF oGrafPOL SIZE 10,10 PIXEL ACTION (oTimeS:lActive:=FS_AUTOM("E")) WHEN (len(aAutom)>0)
		@ 188,305 MSGET oTime VAR nTime PICTURE("99") VALID(nTime>=1.and.nTime<=99,oTimeS:NINTERVAL:=(1000*nTime)) SIZE 15,06 OF oGrafPOL PIXEL COLOR CLR_BLUE WHEN (len(aAutom)>0)
		@ 188,320 BUTTON oPlay PROMPT ">" OF oGrafPOL SIZE 10,10 PIXEL ACTION (oTimeS:lActive:=.t.) WHEN (len(aAutom)>0)
		@ 188,330 BUTTON oStop PROMPT "||" OF oGrafPOL SIZE 10,10 PIXEL ACTION (oTimeS:lActive:=.f.) WHEN (len(aAutom)>0)
		DEFINE TIMER oTimeS INTERVAL (1000*nTime) ACTION FS_AUTOM("V") OF oGrafPOL
		oTimeS:lActive := lAutom
	ACTIVATE MSDIALOG oGrafPOL CENTER
	If lEmpr
		OFIOC310(cEmpr,aEmpr,cPrefixo,aPrefixo,aTipGFT,aTipGLB,aTipGQV,aAutom,cAutom,lAutom,nTime)
	EndIf
#ENDIF
Return
#IFDEF TOP
Static Function FS_AUTOM(cTp) // Lista Automatica
Local aAux := {}
Local cAux := ""
Local ni := 0
Local nj := 0
lAutom := .f.
Do Case
   Case cTp == "L" // Levantamento Usuario
		aAutom := {}
		cAutom := ""
		If cUsuPerm # "*"
	   	aTipGFT := FS_PERM("FT",aTipGFT)
   		cTipGFT := ""
   		aTipGLB := FS_PERM("LB",aTipGLB)
	   	cTipGLB := ""
   		aTipGQV := FS_PERM("QV",aTipGQV)
   		cTipGQV := ""
			aPrefixo:= {}
			cPrefixo:= ""
   		If len(aTipGFT) > 1
		   	cPrefixo := STR0003
				aAdd(aPrefixo,STR0003)
   		EndIf
	   	If len(aTipGLB) > 1
   			If Empty(cPrefixo)
	   			cPrefixo := STR0004
   			EndIf
				aAdd(aPrefixo,STR0004)
   		EndIf
   		If len(aTipGQV) > 1
	   		If Empty(cPrefixo)
		   		cPrefixo := STR0005
   			EndIf
				aAdd(aPrefixo,STR0005)
	   	EndIf
	   EndIf
		If cUsuList # "*"
	   	FS_LIST("FT",aTipGFT)
  			FS_LIST("LB",aTipGLB)
			FS_LIST("QV",aTipGQV)
		Else
      	For ni := 1 to Len(aTipGFT)
      		If !Empty(aTipGFT[ni])
					aAdd(aAutom,left(aTipGFT[ni],5))
				EndIf
			Next
      	For ni := 1 to Len(aTipGLB)
      		If !Empty(aTipGLB[ni])
					aAdd(aAutom,left(aTipGLB[ni],5))
				EndIf
			Next
      	For ni := 1 to Len(aTipGQV)
      		If !Empty(aTipGQV[ni])
					aAdd(aAutom,left(aTipGQV[ni],5))
				EndIf
			Next
			If len(aAutom) > 0
				cAutom := aAutom[1]
			EndIf
		EndIf
  	Case cTp == "I" // Inclui Novo
   	If !Empty(cTipGraf)
	      aAux := aClone(aAutom)
			cAux := left(cTipGraf,5)
			cAutom := ""
	      aAutom := {}
			aAdd(aAutom,left(cTipGraf,5))
			cAutom := left(cTipGraf,5)
      	For ni := 1 to Len(aAux)
	      	If left(cTipGraf,5) # aAux[ni]
					aAdd(aAutom,aAux[ni])
				EndIf
			Next
		EndIf
   Case cTp == "E" // Exclui
     	If !Empty(cAutom)
	      aAux := aClone(aAutom)
			cAux := cAutom
			cAutom := ""
	      aAutom := {}
      	For ni := 1 to Len(aAux)
	      	If cAux # aAux[ni]
					aAdd(aAutom,aAux[ni])
				EndIf
			Next
			If len(aAutom) > 0
				cAutom := aAutom[1]
			Else
				aAdd(aAutom,"")
			EndIf
		EndIf
   Case cTp == "V" // Visualiza Grafico Automaticamente
		If !Empty(cAutom) .and. len(aAutom) > 1
			oTipGFT:lVisible := .f.
			oTipGLB:lVisible := .f.
			oTipGQV:lVisible := .f.
			lAutom := .t.
			ni := aScan(aAutom,{ |x| left(x,5) == cAutom } )
			If ni > 0
				ni++
				If ni > len(aAutom)
					ni := 1
				EndIf
				cAutom := aAutom[ni]
			EndIf
			If left(cAutom,2) == "FT"
			   cPrefixo := STR0003
				ni := aScan(aTipGFT, {|x| left(x,5) == cAutom })
				If ni > 0
					cTipGFT := aTipGFT[ni]
					FS_GRAFICO(cTipGFT)
				EndIf
				oTipGFT:lVisible := .t.
				oTipGFT:Refresh()
			ElseIf left(cAutom,2) == "LB"
			   cPrefixo := STR0004
				ni := aScan(aTipGLB, {|x| left(x,5) == cAutom })
				If ni > 0
					cTipGLB := aTipGLB[ni]
					FS_GRAFICO(cTipGLB)
				EndIf            
				oTipGLB:lVisible := .t.
				oTipGLB:Refresh()
			ElseIf left(cAutom,2) == "QV"
			   cPrefixo := STR0005
				ni := aScan(aTipGQV, {|x| left(x,5) == cAutom })
				If ni > 0
					cTipGQV := aTipGQV[ni]
					FS_GRAFICO(cTipGQV)
				EndIf
				oTipGQV:lVisible := .t.
				oTipGQV:Refresh()
			EndIf
			oAutom:Refresh()
			oPrefixo:Refresh()
		EndIf
EndCase
If cTp $ "I/E"
	oAutom:AITEMS := aAutom
	If len(aAutom) == 1
		If Empty(aAutom[1])
			aAutom := {}
		EndIf
	EndIf
	oAutom:Refresh()
EndIf
Return(lAutom)
              
Static Function FS_PERM(cTp,aAux)
Local ni := 0
Local nj := 0
Local nx := 0
Local cPer := cUsuPerm
Local cAux := ""
Local nAux := 0
Local aRet := {}
aAdd(aRet,"")
For ni := 1 to len(cPer)
	cAux := left(cPer,5)
	nAux := len(Alltrim(cAux))
	If nAux == 0
		Exit
	EndIf
	If cTp $ cAux
		For nj := 1 to len(aAux)
			If left(aAux[nj],nAux) == left(cAux,nAux)
				nx := aScan(aRet, {|x| x == aAux[nj] })
				If nx == 0
					aAdd(aRet,aAux[nj])
				EndIf
  			EndIf
  		Next
  	EndIf
  	cPer := substr(cPer,7)
Next
Return(aRet)

Static Function FS_LIST(cTp,aAux)
Local ni := 0
Local nj := 0
Local nx := 0
Local cLis := cUsuList
Local cAux := ""
Local nAux := 0
For ni := 1 to len(cLis)
	cAux := left(cLis,5)
	nAux := len(Alltrim(cAux))
	If nAux == 0
		Exit
	EndIf
	If cTp $ cAux
		For nj := 1 to len(aAux)
			If left(aAux[nj],nAux) == left(cAux,nAux)
				nx := aScan(aAutom,{|x| x == left(aAux[nj],5) })
				If nx == 0
					aAdd(aAutom,left(aAux[nj],5))
				EndIf				
  			EndIf
  		Next
  	EndIf
	cLis := substr(cLis,7)
Next
Return()

Static Function FS_PREFGRAF()
	oTipGFT:lVisible := .f.
	oTipGLB:lVisible := .f.
	oTipGQV:lVisible := .f.
	Do Case
	   Case cPrefixo == STR0003
	   	cTipGFT:=""
		   oTipGFT:lVisible := .t.
		   oTipGFT:SetFocus()
		Case cPrefixo == STR0004
	   	cTipGLB:=""
			oTipGLB:lVisible := .t.
	   	oTipGLB:SetFocus()
		Case cPrefixo == STR0005
	   	cTipGQV:=""
			oTipGQV:lVisible := .t.
		   oTipGQV:SetFocus()
	EndCase
Return(.t.)

Static Function FS_GRAFICO(cTpG)
	Local dDtI  := ctod("01/01/"+right(strzero(year(dDataBase)-2,4),2))
	Local dDtF  := dDataBase
	Local cPeriod:= " ( "+strzero(year(dDataBase)-2,4)+"-"+STR0038+" / "+strzero(year(dDataBase)-1,4)+"-"+STR0039+" / "+strzero(year(dDataBase),4)+"-"+STR0040+" )"
	Local cQuery:= ""
	Local cQPai := "SQLPAINEL"
	Local nEmpr := 0
	Local cPr	:= ""
	Local cTp   := ""
	Local ni    := 0
	Local	nVlr  := 0
	Local	nVlr1 := 0
	Local	nVlr2 := 0
	Local nVlr3 := 0
	Local cAno  := ""
	Local nGraf := 4
	Local aAux  := {}
	Local cValor:= ""
	Default cTpG:= ""
	cTit  := ""
	cTipGraf := cTpG
	cPr := left(cTipGraf,5)
	cTp := substr(cPr,3,2)
	If !Empty(cPr)
		Do Case
		   Case left(cPr,2) == "FT"
		   	cTit := STR0003+" - "
			Case left(cPr,2) == "LB"
	   		cTit := STR0004+" - "
			Case left(cPr,2) == "QV"
	   		cTit := STR0005+" - "
	   EndCase
		If right(cPr,1) == "A"
			nGraf := 1
		EndIf
		aGrafico := {}
		aAdd(aGrafico,{ 0 , 0 , 0 , STR0041 }) // 01
		aAdd(aGrafico,{ 0 , 0 , 0 , STR0042 }) // 02
		aAdd(aGrafico,{ 0 , 0 , 0 , STR0043 }) // 03
		aAdd(aGrafico,{ 0 , 0 , 0 , STR0044 }) // 04
		aAdd(aGrafico,{ 0 , 0 , 0 , STR0045 }) // 05
		aAdd(aGrafico,{ 0 , 0 , 0 , STR0046 }) // 06
		aAdd(aGrafico,{ 0 , 0 , 0 , STR0047 }) // 07
		aAdd(aGrafico,{ 0 , 0 , 0 , STR0048 }) // 08
		aAdd(aGrafico,{ 0 , 0 , 0 , STR0049 }) // 09
		aAdd(aGrafico,{ 0 , 0 , 0 , STR0050 }) // 10
		aAdd(aGrafico,{ 0 , 0 , 0 , STR0051 }) // 11
		aAdd(aGrafico,{ 0 , 0 , 0 , STR0052 }) // 12
 	   If left(cPr,2) $ "FT/LB"
			cValor := " - "+STR0053
		EndIf
		For nEmpr := 1 to len(aEmpr)
			cQuery := "SELECT "+FG_CONVSQL("SUBS")+"(VJC.VJC_DATVEN,1,6) DTA , "
			Do Case
			   Case left(cPr,2) == "FT"
					cQuery += "SUM(VJC.VJC_VALVDA) VLR "
				Case left(cPr,2) == "LB"
					cQuery += "SUM( ( VJC.VJC_VALVDA - ( VJC.VJC_VALCUS + VJC.VJC_VALIMP ) ) ) VLR "
				Case left(cPr,2) == "QV"
					cQuery += "SUM(VJC.VJC_QUANT) VLR "
			EndCase
			cQuery += "FROM VJC"+aEmpr[nEmpr,1]+"0 VJC "
			If Empty(xFilial("VJC"))
				cQuery += "WHERE VJC.VJC_FILIAL='"+xFilial("VJC")+"' AND "
			Else
				cQuery += "WHERE VJC.VJC_FILIAL='"+aEmpr[nEmpr,2]+"' AND "
			EndIf
			cQuery += "VJC.VJC_DATVEN>='"+dtos(dDtI)+"' AND VJC.VJC_DATVEN<='"+dtos(dDtF)+"' AND VJC.VJC_PERIOD='R' AND "
			If cTp # "TT"
				Do Case
				   Case cTp $ "PB/PO/SV/VN/VF/VU"
						cQuery += "VJC.VJC_TIPO='"+cTp+"' AND "
					Case cTp == "PC"
					 	cQuery += "VJC.VJC_TIPO IN ('PB','PO') AND "
					Case cTp == "PV"
					 	cQuery += "VJC.VJC_TIPO IN ('PB','PO','SV') AND "
					Case cTp == "VV"
					 	cQuery += "VJC.VJC_TIPO IN ('VN','VF') AND "
					Case cTp == "VT"
					 	cQuery += "VJC.VJC_TIPO IN ('VN','VF','VU') AND "
			   EndCase
			Else
		 	   If left(cPr,2) == "LB"
					cQuery += "VJC.VJC_TIPO<>'SV' AND "
				ElseIf left(cPr,2) == "QV"
					cQuery += "VJC.VJC_TIPO IN ('VN','VF','VU') AND "
				EndIf
			EndIf	
			cQuery += "VJC.D_E_L_E_T_=' ' GROUP BY "+FG_CONVSQL("SUBS")+"(VJC.VJC_DATVEN,1,6)"
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQPai , .F., .T. )
			ni   := 0
			cAno := ""
			Do While !( cQPai )->( Eof() )
				If left(( cQPai )->( DTA ),4) # cAno
					cAno := left(( cQPai )->( DTA ),4)
					If right(cPr,1) == "A"
						nVlr := 0
					EndIf
					ni++
				EndIf
				If right(cPr,1) == "M"
					nVlr := 0
				EndIf
				nVlr += int( ( cQPai )->( VLR ) / If(left(cPr,2)$"FT/LB",1000,1) )
				aGrafico[val(right(( cQPai )->( DTA ),2)),ni] += nVlr
			  	( cQPai )->( DbSkip() )
			EndDo
			( cQPai )->( dbCloseArea() )
		Next
		nVlr  := 0
		nVlr1 := 0
		nVlr2 := 0
		nVlr3 := 0
		aAux  := aClone(aGrafico)
		aGrafico := {}
		If right(cPr,1) == "M" 
			For ni := 1 to len(aAux)
				aAdd(aGrafico,{ aAux[ni,1] , aAux[ni,4] , })
				aAdd(aGrafico,{ aAux[ni,2] , aAux[ni,4] , })
				aAdd(aGrafico,{ aAux[ni,3] , aAux[ni,4] , })
			Next
		Else // right(cPr,1) == "A"
			For ni := 1 to len(aAux)
				nVlr := aAux[ni,1]
				If nVlr == 0
					nVlr := nVlr1
				Else
					nVlr1 := aAux[ni,1]
				EndIf
				aAdd(aGrafico,{ nVlr , aAux[ni,4] , })
				nVlr := aAux[ni,2]
				If nVlr == 0
					nVlr := nVlr2
				Else
					nVlr2 := aAux[ni,2]
				EndIf
				aAdd(aGrafico,{ nVlr , aAux[ni,4] , })
				nVlr := aAux[ni,3]
				If nVlr == 0
					nVlr := nVlr3
				Else
					nVlr3 := aAux[ni,3]
				EndIf
				aAdd(aGrafico,{ nVlr , aAux[ni,4] , })
			Next
		EndIf
		If lPriVez
			FG_GRAFICO(oGrafPOL,cEmpr,15,2,,,aGrafico,nGraf,.f.)
			lPriVez := .f.
		EndIf
		FG_GRAFICO(oGrafPOL,cTit+cTipGraf+cPeriod+cValor,15,2,,,aGrafico,nGraf,.f.)
	EndIf
Return(.t.)

// Levantamento das Empresas SX2 //
Static Function FS_EMPRESAS()
Local nRecSM0 := SM0->(Recno())
Local aVetAux := {}
Local ni      := {}
Local cEmpLibs := ""
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
DbSelectArea("SM0")
DbGoTop()
cEmpLibs := FG_FilLib(2) // retorna empresas filiais que o usuario pode acessar
Do While !Eof()
	If SM0->M0_CODIGO+SM0->M0_CODFIL $ cEmpLibs
		If FS_VERBASE()
		   ni := aScan(aEmpr,{|x| x[1]+x[2] == SM0->M0_CODIGO+SM0->M0_CODFIL })
			aAdd( aVetEmp, { (ni>0) ,SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_FILIAL, SM0->M0_NOME })
		EndIf
	EndIf
	DbSelectArea("SM0")
	DbSkip()
EndDo
DbGoTo(nRecSM0)
If Len(aVetEmp) > 1
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 250,400 TITLE STR0035 PIXEL
	   @ 001,001 LISTBOX oLbEmp FIELDS HEADER  OemToAnsi(""),OemToAnsi(STR0054),OemToAnsi(STR0055),OemToAnsi(STR0034),OemToAnsi(STR0056);
				   COLSIZES 10,15,15,50,50 SIZE 165,120 OF oDlgEmp ON DBLCLICK ( aVetEmp[oLbEmp:nAt,1] := !aVetEmp[oLbEmp:nAt,1] ) PIXEL
	   oLbEmp:SetArray(aVetEmp)
	   oLbEmp:bLine := { || {  If(aVetEmp[oLbEmp:nAt,1],oOk,oNo) ,;
	                                  aVetEmp[oLbEmp:nAt,2],;
	                                  aVetEmp[oLbEmp:nAt,3],;
	                                  aVetEmp[oLbEmp:nAt,4],;
	                                  aVetEmp[oLbEmp:nAt,5] }}
	   DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp
	@ 002, 002 CHECKBOX oMacTod VAR lMarcar PROMPT "" OF oDlgEmp ON CLICK If( FS_TIK(lMarcar ) , .t. , ( lMarcar:=!lMarcar , oDlgEmp:Refresh() ) ) 	SIZE 70,08 PIXEL COLOR CLR_BLUE
	ACTIVATE MSDIALOG oDlgEmp CENTER
EndIf
If len(aVetEmp) == 1
	aVetEmp[1,1] := .t.
EndIf
For ni := 1 to len(aVetEmp)
	If aVetEmp[ni,1]
		aAdd( aVetAux , { aVetEmp[ni,2] , aVetEmp[ni,3] })
		cEmpr += aVetEmp[ni,2]+"/"+aVetEmp[ni,3]+", "
	EndIf
Next
If len(aVetAux) >= 1
	cEmpr := substr(cEmpr,1,len(cEmpr)-2)
EndIf
Return(aVetAux)

    //
	Static Function FS_TIK(lMarcar)
	Local ni := 0
	Default lMarcar := .f.
	For ni := 1 to Len(aVetEmp)
		If lMarcar 
			aVetEmp[ni,1] := .t.
		Else
			aVetEmp[ni,1] := .f.
		EndIf
	Next
	oLbEmp:SetFocus()
	oLbEmp:Refresh()
	Return(.t.)

// Verifica a Base da Empresa para realizar a Consulta //
Static Function FS_VERBASE()
Local cQuery  := ""
Local cQAlias := "SQLERRO"
Local lOk     := .t.
Private bBlock:= ErrorBlock()
Private bErro := ErrorBlock( { |e| lOk := .f. } )
cQuery := ChangeQuery( "SELECT VJC.VJC_NUMNFI FROM VJC"+SM0->M0_CODIGO+"0 VJC WHERE VJC.VJC_NUMNFI='1'" )
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
ErrorBlock(bBlock)
Return(lOk)
#ENDIF