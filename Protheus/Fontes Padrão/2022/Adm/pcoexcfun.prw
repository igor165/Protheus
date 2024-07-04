#include "PROTHEUS.CH"
Static aCelulas := {}
STATIC cObjXLS	 

Function PcoExcIni(cObjeto)
Local aArea	:= GetArea()
Local cObjAux
Local cAuxStr 

cObjXLS := cObjeto
// Verifica a existencia de registros na tabela 
cObjAux := "C:\APEXCEL\["
If At("][", cObjeto) == 0
	cObjAux += "("+Alltrim(AK1->AK1_CODIGO)+")("+cRevisa+")"+cObjeto
Else
    cAuxStr := StrTran(cObjeto, "[", "(")	
   	cAuxStr := StrTran(cAuxStr, "]", ")")	
   	cObjAux += cAuxStr
EndIf
cObjAux += "]PLAN1"

dbSelectArea("AL5")
dbSetOrder(1)
While dbSeek(xFilial()+UPPER(cObjAux))
	RecLock("AL5",.F.)
	dbDelete()
	MsUnlock()
End

RestArea(aArea)
Return .T.
         

Function PcoExcLink(xValor,cCelula,cObjeto)
Local nPos := aScan(aCelulas,{|x| x[1]==cCelula})
If ValType(cCelula) == "C"
	dbSelectArea("AL5")
	dbSetOrder(1)
	If dbSeek(xFilial()+PadR(UPPER(AllTrim(cObjeto)), Len(AL5->AL5_OBJETO))+Upper(Alltrim(cCelula))) 
		RecLock("AL5",.F.)
		AL5->AL5_CONTEU := Str(xValor)
		AL5_STATUS	:= "1"
		MsUnlock()
	Else 
		RecLock("AL5",.T.)
		AL5_FILIAL := xFilial("AL5")
		AL5_OBJETO := UPPER(AllTrim(cObjeto))
		AL5_CELULA := UPPER(AllTrim(cCelula))
		AL5_CONTEU := Str(xValor)
		AL5_STATUS	:= "1"
		MsUnlock()
	EndIf
EndIf

Return xValor


Function PcoSetLink(cObjeto,cCelula)
Local nValor := M->AK2_VALOR


Return nValor


Function PcoExcFin(cObjeto,cLinks,lAtuAK2)
Local aArea	:= GetArea()
Local aAreaAKR	:= AKR->(GetArea())
Local aAreaAK1	:= AK1->(GetArea())
Local aAreaAK2	:= AK2->(GetArea())
Local aAreaAL5	:= AL5->(GetArea())
Local lRet	:= .F.
Local cAtualiz	:= ""
Local cFormul
Local cObjAux, cAuxStr
Local cPlanilha
Local cVerPlan
Local lObjFull, cObjOri
Local aRecAL5 := {}
Local aRecAK2 := {}
Local nX
DEFAULT lAtuAK2	:=	.T.

//somente atualizara a planilha editada no Excel 
cPlanilha := Alltrim(AK1->AK1_CODIGO)
cVerPlan := cRevisa

cObjAux := "C:\APEXCEL\["
If At("][", cObjeto) == 0
	cObjAux += "("+Alltrim(AK1->AK1_CODIGO)+")("+cRevisa+")"+cObjeto
Else
    cAuxStr := StrTran(cObjeto, "[", "(")	
   	cAuxStr := StrTran(cAuxStr, "]", ")")	
   	cObjAux += cAuxStr
EndIf
cObjAux += "]PLAN1"

dbSelectArea("AKR")
dbSetOrder(1)

dbSelectArea("AK1")
dbSetOrder(1)

dbSelectArea("AK2")
dbSetOrder(11)
cObjOri := cObjeto

//pesquisa a formula que referencia o objeto com aspas duplas
lObjFull:= dbSeek(xFilial()+'PCOSETLINK("'+UPPER(AllTrim(cObjeto)))
If !lObjFull //pesquisa a formula que referencia o objeto com aspas simples
	lObjFull:= dbSeek(xFilial()+"PCOSETLINK('"+UPPER(AllTrim(cObjeto)))
EndIf 
If !lObjFull //pesquisa a formula que referencia o objeto com aspas simples
	If (nPosVer := At("][", cObjeto)) > 0
		cObjeto := Subs(cObjeto, nPosVer+2)
		nPosVer := At("]", cObjeto)
		cObjeto := Subs(cObjeto, nPosVer+1)
	EndIf	
EndIf 

dbSelectArea("AL5")
dbSetOrder(1)

Begin Transaction  
	dbSelectArea("AL5")
	dbSeek(xFilial()+UPPER(cObjAux))
	While AL5->(!Eof() .And. AL5_FILIAL+Alltrim(AL5_OBJETO) == xFilial()+UPPER(cObjAux))
	   aAdd(aRecAL5, { AL5->(Recno()), AL5->AL5_CELULA, AL5->AL5_CONTEUDO, AL5->AL5_STATUS})
	   AL5->(dbSkip())
	End
	
	If !Empty(aRecAL5)
		If lAtuAK2
			dbSelectArea("AK2")
			//pesquisa a formula PcoSetLink com Aspas Duplas
			dbSeek(xFilial()+'PCOSETLINK("'+UPPER(AllTrim(cObjeto)),.T.) 
			While !Eof() .And. AK2_FILIAL+AK2->AK2_FORMUL= xFilial()+'PCOSETLINK("'+UPPER(AllTrim(cObjeto))
				If Alltrim(AK2->AK2_ORCAME)==cPlanilha .And. ;
			   		Alltrim(AK2->AK2_VERSAO)==cVerPlan
			   		aAdd(aRecAK2, AK2->(Recno())) 
				EndIf
						
				dbSelectArea("AK2")
				dbSkip()			
			End
			//pesquisa a formula PcoSetLink com Aspas Simples
			dbSeek(xFilial()+"PCOSETLINK('"+UPPER(AllTrim(cObjeto)),.T.)
			While !Eof() .And. AK2_FILIAL+AK2_FORMUL = xFilial()+"PCOSETLINK('"+UPPER(AllTrim(cObjeto)) 
				If Alltrim(AK2->AK2_ORCAME)==cPlanilha .And. ;
			   		Alltrim(AK2->AK2_VERSAO)==cVerPlan
			   		aAdd(aRecAK2, AK2->(Recno())) 
				EndIf
		
				dbSelectArea("AK2")			
				dbSkip()
			End
			dbSelectArea("AK2")
				
			For nX := 1 TO Len(aRecAK2)
				AK2->(dbGoto(aRecAK2[nX]))
		
				cFormul := UPPER(AllTrim(AK2->AK2_FORMUL))
							
				nPosIni := AT("(",cFormul)+2
				nPosFim := AT(",",Substr(cFormul,nPosIni))-2
				cCelula := Alltrim(Upper(Substr(cFormul,nPosIni+nPosFim+2)))
				If "'" $ cCelula .Or. '"' $ cCelula
					cCelula 	:= StrTran(cCelula, ")", "")
					cCelula 	:= StrTran(cCelula, '"', '')
					cCelula 	:= StrTran(cCelula, "'", '')
				Else
					cCelula	:=	&(Substr(cCelula,1,Len(cCelula)-1) )
				Endif		
				nPosAL5 := aScan(aRecAL5, {|aVal| Alltrim(aVal[2]) == Alltrim(cCelula) .And. aVal[4]=="1"})
				
				If nPosAL5 > 0 .And. Alltrim(cCelula)==Upper(Alltrim(aRecAL5[nPosAL5][2])) .And. ;
					AK2->AK2_VALOR != Val(aRecAL5[nPosAL5][3])
					//array e variaveis para atualizar a planilha
					aAdd(aFormExcel, {aRecAL5[nPosAL5][2], Alltrim(AK2->AK2_FORMUL), AK2_PERIOD, AK2->AK2_CLASSE, Val(aRecAL5[nPosAL5][3])})
					If Upper(Alltrim(AK2_FORMUL)) == Upper(Alltrim(cFormAK2))
						nValueExcel := Val(aRecAL5[nPosAL5][3])
					EndIf	
					cAtualiz += "Celula Excel : "+aRecAL5[nPosAL5][2]+CHR(13)+CHR(10)
					cAtualiz += "Planilha : "+AK2->AK2_ORCAME+CHR(13)+CHR(10)
					cAtualiz += "Versao : "+AK2->AK2_VERSAO+CHR(13)+CHR(10)
					cAtualiz += "Periodo : "+DTOC(AK2->AK2_DATAI)+"-"+DTOC(AK2_DATAF)+CHR(13)+CHR(10)
					cAtualiz += "Formula : "+AK2->AK2_FORMUL+CHR(13)+CHR(10)
					cAtualiz += "Valor Anterior : "+Str(AK2->AK2_VALOR)+CHR(13)+CHR(10)
					cAtualiz += "Valor Atualizado : "+Str(Val(aRecAL5[nPosAL5][3]))+CHR(13)+CHR(10)+CHR(13)+CHR(10)
					aRecAL5[nPosAL5][4] := "2"
					RecLock("AK2",.F.)
					AK2->AK2_VALOR := Val(aRecAL5[nPosAL5][3])
					AK2->(MsUnlock())
					If ( AK1->(MsSeek(xFilial('AK1')+AK2->AK2_ORCAME)) .And. AK2->AK2_VERSAO == AK1->AK1_VERSAO ) 
						PcoDetLan("000252","01","PCOA100")
					ElseIf ( AKR->(MsSeek(xFilial('AKR')+AK2->AK2_ORCAME+AK2->AK2_VERSAO)))
						PcoDetLan("000252","03","PCOA100")
					Else
						PcoDetLan("000252","02","PCOA100")
					EndIf
	
				EndIf
	
			Next	
		Else
			cFormul := UPPER(AllTrim(M->AK2_FORMUL))
						
			nPosIni := AT("(",cFormul)+2
			nPosFim := AT(",",Substr(cFormul,nPosIni))-2
			cCelula := Alltrim(Upper(Substr(cFormul,nPosIni+nPosFim+2)))
			If "'" $ cCelula .Or. '"' $ cCelula
				cCelula 	:= StrTran(cCelula, ")", "")
				cCelula 	:= StrTran(cCelula, '"', '')
				cCelula 	:= StrTran(cCelula, "'", '')
			Else
				cCelula	:=	&(Substr(cCelula,1,Len(cCelula)-1) )
			Endif		
			nPosAL5 := aScan(aRecAL5, {|aVal| Alltrim(aVal[2]) == Alltrim(cCelula) .And. aVal[4]=="1"})
			
			If nPosAL5 > 0 .And. Alltrim(cCelula)==Upper(Alltrim(aRecAL5[nPosAL5][2]))
				//array e variaveis para atualizar a planilha
			   aAdd(aFormExcel, {aRecAL5[nPosAL5][2], Alltrim(M->AK2_FORMUL), M->AK2_PERIOD, M->AK2_CLASSE, Val(aRecAL5[nPosAL5][3])})
				If Upper(Alltrim(M->AK2_FORMUL)) == Upper(Alltrim(cFormAK2))
					nValueExcel := Val(aRecAL5[nPosAL5][3])
				EndIf	
				aRecAL5[nPosAL5][4] := "2"
			Endif			
   		Endif
   		
	    //atualiza tabela AL5 e deleta os registros
	  	dbSelectArea("AL5")
		For nX := 1 TO Len(aRecAL5)	
			dbGoto(aRecAL5[nX][1])
			RecLock("AL5",.F.)
			AL5->AL5_STATUS := "2"
			dbDelete()
			MsUnlock()
		Next
		
		lRet := .T.
	
	EndIf

End Transaction

cObjeto := cObjOri

If !lRet
	cLinks	:= "Erros foram encontrados na Integração Excel x SIGAPCO !"+CHR(13)+CHR(10)
	cLinks	+= "Objeto : "+cObjeto+CHR(13)+CHR(10)
	cLinks	+= "Data : "+DTOC(MsDate())+CHR(13)+CHR(10)
	cLinks	+= "Rotina :"+FunName()+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cLinks	+= "Campos processados : "+DTOC(MsDate())+CHR(13)+CHR(10)
	cLinks 	+= cAtualiz
Else
	cLinks	:= "Integração Excel x SIGAPCO - Atualização efetuada com sucesso !"+CHR(13)+CHR(10)
	cLinks	+= "Objeto : "+cObjeto+CHR(13)+CHR(10)
	cLinks	+= "Data : "+DTOC(MsDate())+CHR(13)+CHR(10)
	cLinks	+= "Rotina :"+FunName()+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cLinks 	+= cAtualiz
EndIf

RestArea(aAreaAKR)
RestArea(aAreaAK1)
RestArea(aAreaAK2)
RestArea(aAreaAL5)
RestArea(aArea)
Return lRet
