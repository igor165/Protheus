#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINA006.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA006   บAutor  ณJair Ribeiro        บ Data ณ  03/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Amarracao Aprovadores e Superiores                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA006()
Local cFilter		:= "FRS_CODSUP = ''"
Local lDefTop		:= .F.
Local cAlias		:= "FRS"

Private cCadastro 	:= STR0001	//"Aprovadores e Superiores"
Private aRotina   	:= MenuDef()
Private aIndexFil	:= {}
Private bFiltraBrw	:= {|| Nil}

#IFDEF TOP
	lDefTop := .T.
#ENDIF  

If lDefTop
	If  Trim(TcGetDb()) = 'ORACLE'
		cFilter := "trim(FRS_CODSUP) is null"
	Else
		cFilter := "FRS_CODSUP = ''"
	Endif		
Else
	cFilter := 'FRS_CODSUP = ""'
	bFiltraBrw := { || FilBrowse(cAlias,@aIndexFil,@cFilter)}
	DbSelectArea(cAlias)
	Eval(bFiltraBrw)
Endif

FRS->(DbSetOrder(1))
mBrowse(006,001,022,075	,cAlias	,,,,,,,,,,,,,,Iif(lDefTop, cFilter,Nil))
FRS->(DbClearFilter())
FRS->(DbSetOrder(1))

If !lDefTop
	EndFilBrw( cAlias, aIndexFil )
Endif

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA006APS  บAutor  ณJair Ribeiro        บ Data ณ  03/20/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de manutencao de amarracao                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA006APS( cAlias, nReg, nOpc, lAutomato )
 
Local aDms  	:= FWGetDialogSize(oMainWnd)
Local aCpoEnc	:= {"FRS_TIPO","FRS_CODAPR","FRS_NOME","NOUSER","NOUSER","NOUSER"} 
Local oPanelJ	:= Nil
Local oPanelI	:= Nil
Local oDlg		:= Nil
Local oMsGet	:= Nil
//Variaveis para funcao FILLGETDADOS
Local cSeek	 	:= ""
Local bWhile 	:= {|| FRS_FILIAL+FRS_TIPO+FRS_CODAPR}								//Laco FillGetdados
Local aNoFields	:= {"FRS_TIPO","FRS_CODAPR","FRS_NOME"}								//Campos nao usado 
Local cTipo     := ""
Local cAprov	:= FRS->FRS_CODAPR
Local bTudoOK	:= {|lRet| lRet:= (FA006VldApr(nOpc) .And. FA006Obrig(nOpc,cAprov,lAutomato))}
Local lCont		:= .T.
Private cCadastro 	:= STR0001+"-"+(Iif(nOpc=2,STR0003,Iif(nOpc=3,STR0004,Iif(nOpc=4,STR0005,STR0006))))	//"Aprovadores e Superiores" //"Visualizar"//"Incluir"//"Alterar"//"Excluir"
					
Private aCols	:= {}
Private aHeader	:= {}

Private aTela[0][0]
Private aGets[0]
Private oGetD	:= Nil

Default lAutomato := .F.

If nOpc == 5 .and. FRS->FRS_TIPO == "2"
	lCont := FA006VEXC(FRS->FRS_CODAPR)
EndIf 

If lCont			
	If nOpc	 == 3
	   	FILLGETDADOS(nOpc,"FRS"	,1,,,,aNoFields,,,,,.T.,,,)
		aCols[1,aScan(aHeader,{|x| Trim(x[2])=="FRS_SEQ"})] := StrZero(1,Len(FRS->FRS_SEQ))
		RegToMemory("FRS",.T.)
	Else
		cSeek:= xFilial("FRS")+PadR(FRS->FRS_TIPO,TamSx3("FRS_TIPO")[1])+PadR(FRS->FRS_CODAPR,TamSx3("FRS_CODAPR")[1])	//Chave de busca para fillgetdados
		FILLGETDADOS(nOpc,"FRS",1,cSeek,bWhile,{|| (!Empty(FRS_CODSUP))},aNoFields,,,,,,,,)
		RegToMemory("FRS",.F.,,, FunName())
	EndIf
	
	If nOpc != 3
		cTipo   := FRS->FRS_TIPO
		cAprov	:= FRS->FRS_CODAPR	
	EndIf
	oDlg:= MSDialog():New(aDms[1],aDms[2],aDms[3],aDms[4], cCadastro,,,,,,,,oMainWnd,.T.)		//"Aprovadores e Superiores"	
		
		oPanelI := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,30,30,.T.,.T. )
	  	oPanelI:Align := CONTROL_ALIGN_TOP
		oMsGet := Msmget():New("FRS",,nOpc	,,,,aCpoEnc	,{18,2,210,318},,,,,,oPanelI,.F.,.T.,,,,)
	   	oMsGet:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT

	   	If nOpc == 4   
		   	oMsGet:LACTIVE := .F.
		EndIf
		
		oPanelJ := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,30,30,.T.,.T. )
		oPanelJ:Align := CONTROL_ALIGN_ALLCLIENT			
		oGetD := MsNewGetDados():New(0,050,150,200,If(nOpc != 2 .and. nOpc != 5 ,GD_INSERT+GD_UPDATE+GD_DELETE,0),"AllWaysTrue","AllWaysTrue","+FRS_SEQ",,,,,,"F006DELOK",oPanelJ,aHeader,aCols)
		oGetD:ldelete:=.T.
	   	oGetD:oBrowse:Align	:= CONTROL_ALIGN_ALLCLIENT
  IF !lAutomato	   	  		
	oDlg:Activate(,,,,,,EnchoiceBar(oDlg,{|| Iif((Obrigatorio(aGets,aTela) .and. Eval(bTudoOK)),(FA006GRV(nOpc,cTipo,cAprov),oDlg:End()),Nil)},{||oDlg:End()})) 
  Else
    If FindFunction ("GetParAuto")  // Tratamiento para scripts automatizados
         aRetAuto  := GetParAuto("FINA006TESTCASE")
         nOpc		:= aRetAuto[1]
         cTipo		:= aRetAuto[2]
         cAprov		:= aRetAuto[3]
         If nOpc == 3
             FA006VldSup()
         	 aCols[1][2] := aRetAuto[4]
	         aCols[1][3] := FA006RetName(aRetAuto[4],cTipo)
	         If Eval(bTudoOK)
	            FA006GRV(nOpc,,cAprov,lAutomato)
	         Endif
         Endif
     Endif
  Endif
EndIf
Return Nil    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA006GRV  บAutor  ณJair Ribeiro        บ Data ณ  03/20/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclusao/Alteracao/Exclusao na base de dados		          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA006GRV(nOpc,cTipo,cCodA,lAutomato)
Local aDados	:= aClone(oGetD:aCols)
Local aCabec	:= aClone(oGetD:aHeader)
Local nI		:= 0	
Local nJ		:= 0
Local nPosI		:= aScan(aCabec,{|x| AllTrim(x[2]) == "FRS_CODSUP"})
Local nPosS		:= aScan(aCabec,{|x| AllTrim(x[2]) == "FRS_SEQ"})
Local bCampo	:= {|n| FieldName(n)}
Local aSuper	:= {}
Local cSeq		:= StrZero(1,Len(FRS->FRS_SEQ))
Local nRec      := aScan(aCabec,{|x| AllTrim(x[2]) == "FRS_REC_WT"})
Default lAutomato := .F.

IF lAutomato
   aDados	:= aClone(aCols)
   aCabec	:= aClone(aHeader)
Endif

Begin Transaction
	FRS->(DbSetOrder(1))
	If nOpc == 3
		If RecLock("FRS",.T.)
			For nI := 1 To FCount()
				FieldPut(nI,M->&(EVAL(bCampo,nI)))
			Next nI
			FRS->FRS_FILIAL	:= xFilial("FRS")
			FRS->FRS_SEQ	:= StrZero(0,Len(FRS->FRS_SEQ))
			FRS->FRS_CODSUP	:= ""			
			FRS->(MsUnlock())
		EndIf
	ElseIf nOpc == 4 
		If FRS->(DbSeek(xFilial("FRS")+cTipo+cCodA+StrZero(0,Len(FRS->FRS_SEQ))))
			If RecLock("FRS",.F.)
				For nI := 1 To FCount()
					FieldPut(nI,M->&(EVAL(bCampo,nI)))
				Next nI
				FRS->FRS_FILIAL	:= xFilial("FRS")
				FRS->FRS_SEQ	:= StrZero(0,Len(FRS->FRS_SEQ))
				FRS->FRS_CODSUP	:= ""			
				FRS->(MsUnlock())
			EndIf 
		EndIf
	ElseIf nOpc == 5 
		If FRS->(DbSeek(xFilial("FRS")+cTipo+cCodA+StrZero(0,Len(FRS->FRS_SEQ))))
			If FRS->(RecLock("FRS",.F.,.T.))
				FRS->(DbDelete())
				FRS->(MsUnLock())
			EndIf
	    EndIf	
	EndIf 
	
	FRS->(DbSetOrder(3))
	For nI := 1 To Len(aDados)
		lDelete:= aDados[nI][6] 		
		If lDelete
			DbSelectArea("FRS") 
			If aDados[nI][nRec] <> 0
				DbGoto(aDados[nI][nRec])
				FRS->(RecLock("FRS",.F.,.T.))
			EndIf
		Else
			If aDados[nI][nRec] != 0
				DbGoto(aDados[nI][nRec])
				FRS->(RecLock("FRS",.F.))			
			Else
				FRS->(RecLock("FRS",.T.))
			EndIf
		EndIf

		If nOpc != 5
	   		If !GDDeleted(nI,aCabec,aDados)
	   	   		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Atualiza dados da GetDados                     ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				For nJ:=1 to Len(aCabec)
					FRS->(FieldPut(FieldPos(aCabec[nJ,2]),aDados[nI,nJ]))
				Next nJ
				If Empty(aDados[nI,nPosS])
			   		FRS->FRS_SEQ 	:= cSeq
			   		cSeq			:= Soma1(cSeq)
				EndIf
				FRS->FRS_FILIAL	:= xFilial("FRS")
				FRS->FRS_TIPO 	:= M->FRS_TIPO
				FRS->FRS_CODAPR	:= M->FRS_CODAPR
				aAdd(aSuper,aDados[nI][nPosI])
	   		Else   
		   		If aDados[nI][nRec] != 0
		   		    DbGoto(aDados[nI][nRec])
	   		   		FRS->(DbDelete())
	   		 	EndIf
	   		EndIf
		Else
			FRS->(DbDelete())
		EndIf
	Next nI
	FRS->(MsUnLock())
End Transaction
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF006DELOK บAutor  ณJair Ribeiro        บ Data ณ  03/20/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao para DELOK                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F006DELOK()
Local lRet	:= .T.
Local nPosI	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2]) == "FRS_SEQ"})
Local nPosS	:= aScan(oGetD:aHeader,{|x| AllTrim(x[2]) == "FRS_CODSUP"})
Local nI	:= 0
Local nSeq	:= StrZero(1,Len(FRQ->FRQ_ITEM))

 If !GDDeleted(n,oGetD:aHeader,oGetD:aCols)
 	For nI:= 1 To Len(oGetD:aCols)
 		If nI != n .and. !GDDeleted(nI,oGetD:aHeader,oGetD:aCols)
 			oGetD:aCols[nI,nPosI] := nSeq 
 			nSeq := Soma1(nSeq)
 		Else
 			oGetD:aCols[nI,nPosI] := ""
 		EndIf 
 	Next nI	
 ElseIf aScanX(oGetD:aCols,{|x,y| AllTrim(x[2]) == oGetD:aCols[n,nPosS] .and. y!= n .and. !GDDeleted(y,aHeader,oGetD:aCols)})>0
 	Help( " ", 1, "F006DELOKA" )
	lRet	:= .F.		
 ElseIf oGetD:aCols[n,nPosS] == M->FRS_CODAPR
 	Help( " ", 1, "F006DELOKB" )
	lRet	:= .F.
 Else
 	For nI:= 1 To Len(oGetD:aCols)
 		If nI == n .or. !GDDeleted(nI,oGetD:aHeader,oGetD:aCols)
 			oGetD:aCols[nI,nPosI] := nSeq 
 			nSeq := Soma1(nSeq)
 		Else
 			oGetD:aCols[nI,nPosI] := ""
 		EndIf 
 	Next nI	
 EndIf
 oGetD:oBrowse:Refresh() 
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA006VldAprบAutor ณJair Ribeiro        บ Data ณ  03/20/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao do Aprovador                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA006VldApr(nOpc)
Local lRet		:= .T.	
Local aArea		:= {}
Local cAlias	:= "" 
Local cTipo		:= ""
Local nRecno	:= 0
Local nRecnoA	:= FRS->(Recno()) 
Local cAprovA   := FRS->FRS_CODAPR
Local cAprovD   := M->FRS_CODAPR

Default nOpc	:= Iif( INCLUI,3,Iif(ALTERA,4,5))

If M->FRS_TIPO == "1"
	cAlias 	:= "FRO"
	cTipo 	:= STR0009 
    aArea	:= (cAlias)->(GetArea())
ElseIf M->FRS_TIPO == "2"
	cAlias 	:= "FRP"
	cTipo 	:= STR0010
    aArea	:= (cAlias)->(GetArea())
ElseIf Empty(cAlias)
	Help(" ",1,"F006TIPO",,STR0011,1,0)
	lRet := .F.
EndIf

If lRet	.and. (nOpc == 3 .or. nOpc == 4) 
	If ReadVar() == "M->FRS_CODAPR" 
		(cAlias)->(DbSetOrder(1)) //FRP_FILIAL+FRP_COD - FRO_FILIAL+FRO_COD
		If (cAlias)->(DbSeek(xFilial(cAlias)+Padr(M->FRS_CODAPR,TamSx3("FRP_COD")[1])))
			If !INCLUI
				nRecno	:= FRS->(Recno())
			EndIf
			If  lRet .And. ReadVar() == "M->FRS_CODAPR"
				FRS->(DbSetOrder(1))   
				If FRS->(DbSeek(xFilial("FRS")+Padr(M->FRS_TIPO,TamSx3("FRS_TIPO")[1])+Padr(M->FRS_CODAPR,TamSx3("FRS_CODAPR")[1]))) 
					Help( " ", 1, "F006VLAPRA" )
					lRet	:= .F.	
				ElseIf aScanX(oGetD:aCols,{|x,y| AllTrim(x[2]) == ALLTRIM(M->FRS_CODAPR) .and. !GDDeleted(y,aHeader,oGetD:aCols)})>0 .and. FRS->FRS_TIPO == "2" 
					Help( " ", 1, "F006VLAPRB" )
					lRet	:= .F.  
				EndIf
			EndIf
		Else
			Help(" ",1,"F006TIPO",,STR0012+cTipo,1,0)
			lRet := .F.
		EndIf
     EndIf
EndIf                    

If nOpc == 4
	FRS->(DbGotop())
	While FRS->(!EOF())
		If !Empty(FRS->FRS_CODSUP)
			If FRS->FRS_CODSUP == cAprovD .And.  FRS->FRS_CODAPR == cAprovA
				Help(" ",1,"F006GEST",,STR0018,1,0) //"Gestor jแ informado como Superior"
				lRet	:= .F.  
				 oGetD:oBrowse:Refresh() 	
			EndIf
		EndIf
		FRS->(DbSkip())
	Enddo       
	DbGoto(nRecno)
EndIf


If !Empty(aArea)
	(cAlias)->(RestArea(aArea))
EndIf
Return lRet 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA006VldSupบAutor ณJair Ribeiro        บ Data ณ  03/20/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao do Superior                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA006VldSup()
Local lRet		:= .T.
Local nPosS		:= aScan(aHeader,{|x| AllTrim(x[2]) == "FRS_SEQ"}) 
Local aArea		:= {}
Local cAlias	:= "FRP"
Local cTipo 	:= STR0010
Local cMoedaSup := ""
Local cMoedaAprov := ""
Local lAutomato := IsBlind()

aArea	:= (cAlias)->(GetArea())
If lAutomato
	If FindFunction ("GetParAuto")  // Tratamiento para scripts automatizados
	         aRetAuto  := GetParAuto("FINA006TESTCASE")
	         M->FRS_TIPO		:= aRetAuto[2]
	         M->FRS_CODAPR		:= aRetAuto[3]
	         M->FRS_CODSUP		:= aRetAuto[4]
	         n:=1
	Endif
Endif

If lRet	
	(cAlias)->(DbSetOrder(1)) //FRP_FILIAL+FRP_USER - FRO_FILIAL+FRO_USER
	If (cAlias)->(DbSeek(xFilial(cAlias)+Padr(M->FRS_CODSUP,TamSx3("FRP_COD")[1])))
		If M->FRS_TIPO == "2" .and. M->FRS_CODAPR == M->FRS_CODSUP
			Help( " ", 1, "F006DELOKB" )  //"Superior Nใo Cadastrado"
			lRet	:= .F.
		ElseIf aScanX(oGetD:aCols,{|x,y| AllTrim(x[2]) == ALLTRIM(M->FRS_CODSUP) .and. !GDDeleted(y,aHeader,oGetD:aCols) .and. oGetD:oBrowse:nAt != y})>0
			Help( " ", 1, "F006DELOKA" )
			lRet	:= .F.	
		ElseIf Empty( oGetD:aCols[n,nPosS] )
			oGetD:aCols[n,nPosS]:= StrZero(1,Len(FRS->FRS_SEQ))
			oGetD:oBrowse:Refresh()
		ElseIf M->FRS_TIPO == "2"
			cMoedaSup := FRP->FRP_MOEDA
			If (cAlias)->(DbSeek(xFilial(cAlias)+Padr(M->FRS_CODAPR,TamSx3("FRP_COD")[1])))
				cMoedaAprov := FRP->FRP_MOEDA
			Endif
			If cMoedaAprov != cMoedaSup 
				Help( " ", 1, "F006MOEDA",, STR0015,1,0 )//"Aprovador e Superior devem estar na mesma Moeda"                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
				lRet	:= .F.
			Endif
		EndIf
	Else
		Help( " ", 1, "F006CODINV",, STR0019,1,0 )//"Superior nใo Cadastrado"
		lRet	:= .F.
	EndIf
EndIf

If !Empty(aArea)
	(cAlias)->(RestArea(aArea))
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA006RetNameบAutorณJair Ribeiro        บ Data ณ  06/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA006RetName(cCodigo,cTipo)
Local cName			:= ""
Default cCodigo		:= ""

If !Empty(cTipo)
	If cTipo == "1"  //Cadastro de Analistas Financeiros
		cName := UsrFullName(FRO->(GetAdvfVal("FRO","FRO_USER",xFilial("FRO")+cCodigo,1,"")))
	
	ElseIf cTipo == "2"	//Cadastro de Gestores Financeiros
		cName := UsrFullName(FRP->(GetAdvfVal("FRP","FRP_USER",xFilial("FRP")+cCodigo,1,"")))     
	EndIf
Else
	cName := UsrFullName(FRP->(GetAdvfVal("FRP","FRP_USER",xFilial("FRP")+cCodigo,1,"")))
EndIf
Return cName
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณ ConPadFRQ   บ Autor ณ Jair Ribeiro			 บ Data ณ 15/08/07  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Abre a tela de pesquisa referente a tabela do Gestor ou Analista บฑฑ
ฑฑบ          ณ 				                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestores x Superiores                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ConPadFRQ()
Local aEntid := {{"FRO","FRO_COD"},{"FRP","FRP_COD"}}
Local cEntid
Local cCampo
Local lRet

If !Empty(M->FRS_TIPO)
	If Val(M->FRS_TIPO)<= Len(aEntid) 
		cEntid := aEntid[Val(M->FRS_TIPO),1]
		cCampo := aEntid[Val(M->FRS_TIPO),2]
	
		lRet   := ConPad1( ,,,cEntid,,,.F. )
    	If lRet
    		M->FRS_CODAPR 	:= (cEntid)->&cCampo
    	EndIf
    EndIf	
Else
	Help(" ",1,"F006TIPO",,STR0011,1,0)
EndIf
Return .T.   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA006ObrigบAutor  ณMicrosiga           บ Data ณ  07/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida Campos na getdados                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FA006Obrig(nOpc,cAprovA,lAutomato)
Local nI	:= 0

Local nPosC	:= aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("FRS_CODSUP")})
Local aColsX:= aClone(oGetD:aCols) 
Local nDel := 0 
Local lRet	:= .T.  
Local nRecno:= FRS->(Recno())
Local cAprovD:= M->FRS_CODAPR
Default lAutomato := .F.

If lAutomato
   aColsX :=  aClone(aCols)
Endif
If nOpc != 5
	For nI:= 1 To Len(aColsX)
		If !GDDeleted(nI,aHeader,aColsX) 
	 		If Empty(aColsX[nI,nPosC]) 
	 			Help(" ",1,"F006SUP1",,STR0014+AllTrim(Str(nI)),1,0)
	 	 		lRet:= .F.
	 	 		Exit
	 	 	EndIf
	 	ElseIf Len(aColsX) > 0 .And. aColsX[nI][Len(aHeader)+1] 
	 		nDel ++
		EndIf
	Next nI
EndIf  

If nDel == Len(aColsX)
	Help(" ",1,"F006SUP2",,STR0017,1,0)         
	lRet := .F.
EndIf    

Return lRet	 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA006VEXC บAutor  ณMicrosiga           บ Data ณ  07/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Regra de exclusao                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA006VEXC(cCodApro)
Local lRet	:= .T.
Local cQry	:= "" 

cQry := "SELECT EU_CODAPRO FROM "+RetSqlName("SEU")+" EU"
cQry += " WHERE EU.EU_CODAPRO = '"+cCodApro+"'" 
cQry += " AND EU.EU_STATUS = '03'"
cQry += " AND EU.EU_FILIAL = '"+xFilial("SEU")+"'"
cQry += " AND EU.D_E_L_E_T_ = ''" 


If Select("APR") > 0
 APR->(DbCloseArea())
EndIf
cQry := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"APR",.T.,.T.) 
	
If APR->(!EOF())
	Help(" ", 1,"FA006VEXC",,STR0013,1,0) //"Aprovador com tํtulos aprovados! Nใo ้ possํvel excluir grupo!"
	lRet	:= .F.
EndIf 

Return lRet   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA006User  บAutor ณ Danilo Dias        บ Data ณ 26/04/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o nome do gestor no cadastro de usuแrios.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa006User( cCodigo, lNome, nIndice, nMoeda )

Local cRet		:= ""
Local aArea		:= GetArea()
Local aAreaFRP	:= {}
Local cMoeda	:= ""

Default lNome   := .T. 
Default nIndice := 1	//Filial + C๓digo + Moeda
Default nMoeda	:= 0

If nMoeda > 0
	cMoeda := StrZero(nMoeda,TamSx3("E2_MOEDA")[1])
EndIf

aAreaFRP := FRP->(GetArea())
	
dbSelectArea("FRP")
FRP->(dbSetOrder(nIndice))
FRP->(dbGoTop())
	
If FRP->(dbSeek( xFilial() + cCodigo + cMoeda) )
	If lNome
		//Retorna o nome de usuแrio
		cRet := FWGetUserName( FRP->FRP_USER )
	Else  
		//Retorna o c๓digo de gestor
		cRet := FRP->FRP_COD
	EndIf	
EndIf  

RestArea(aAreaFRP)
RestArea(aArea)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef	บAutor  ณJair Ribeiro        บ Data ณ  03/20/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Menu                                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()  

Private aRotina := {{ OemToAnsi(STR0002)	,"AxPesqui",	0,1,0,.F.},;	//"Pesquisar"
					{ OemToAnsi(STR0003)	,"FA006APS", 	0,2,0,nil},;	//"Visualizar"
					{ OemToAnsi(STR0004)	,"FA006APS",	0,3,0,nil},;	//"Incluir"
					{ OemToAnsi(STR0005)	,"FA006APS", 	0,4,0,nil},; 	//"Alterar"
					{ OemToAnsi(STR0006)	,"FA006APS", 	0,5,3,nil}}		//"Excluir"
					
If ExistBlock ("MTFA006MNU")
	ExecBlock ("MTFA006MNU",.F.,.F.)
EndIf 
Return (aRotina)
