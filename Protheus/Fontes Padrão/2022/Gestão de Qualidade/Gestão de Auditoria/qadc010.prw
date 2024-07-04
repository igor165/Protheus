#INCLUDE  "PROTHEUS.CH"
#INCLUDE  "QADC010.CH"
#INCLUDE  "DBTREE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QADC010    ³ Autor ³ Eduardo de Souza   ³ Data ³ 26/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Lancamentos Pendentes                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QADC010()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ SIGAQAD - Controle de Auditoria                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³ BOPS ³Programador³                 Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QADC010()

Local oDlg
Local oTree
Local oPanel
Local oBmp

Private oSay01
Private oSay02
Private oSay03
Private oSay04
Private oSay05
Private oSay06
Private oSay07
Private oSay08
Private oSay09
Private aObj1
Private aObj2
Private aObj3
Private oFont   := TFont():New("Courier New",6,18,,.F.)
Private aLancAud:= {}
Private Inclui  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega Array com Lancamentos Pendentes				 	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgRun(OemToAnsi(STR0001),OemToAnsi(STR0002),{|| QAD10CarLanc()}) // "Carregando Lancamentos..." ### "Aguarde..."	

If Len(aLancAud) > 0
	DEFINE MSDIALOG oDlg FROM 000,000 TO 394,634 PIXEL TITLE OemToAnsi(STR0003) // "Lancamentos Pendentes"

	oTree := DbTree():New(015,003,197,140,oDlg,,,.T.)
	oTree:bChange  := {|| QADC10DlgV(@oTree,@oPanel) }
	oTree:bInit    := {|| QADC10DlgV(@oTree,@oPanel),oTree:TreeSeek(oTree:GetCargo())}

	oPanel:= TPanel():New(015,142," ",oDlg,oFont,.T.,.T.,,,173,181,.T.,.T. )

	@ 001,001 BITMAP oBmp RESNAME "APLOGO" oF oPanel SIZE 060,040 ADJUST NOBORDER WHEN .F. PIXEL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta Objetos Tree                      						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    MsgRun(OemToAnsi(STR0001),OemToAnsi(STR0002),{|| QAD10MonTree(@oTree,@oPanel) }) // "Carregando Lancamentos..." ### "Aguarde..."	

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{ ||oDlg:End() },{ ||oDlg:End() }) CENTERED
Else
	Help("",1,"QADNELANC") // "Nao existem Lancamentos Pendentes"
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QAD10CarLanc³ Autor ³ Eduardo de Souza   ³ Data ³ 26/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega Lancamentos de Auditoria                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAD10CarLanc()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION QAD10CarLanc()

Local lVerEvid:= GetMv("MV_QADEVI",.T.,.F.) 
Local lPend   := .F.
Local lPendEnc:= .F.
Local dDtEncer:= dDataBase
Local nSemAval:= 0

DbSelectArea("QUD")
DbSetOrder(1)

DbSelectArea("QUH")
DbSetOrder(1)
DbSeek(xFilial("QUH"))

While QUH->(!Eof()) .And. QUH->QUH_FILIAL == xFilial("QUH")
	If QUD->(DbSeek(QUH->QUH_FILIAL+QUH->QUH_NUMAUD+QUH->QUH_SEQ))			
		While QUD->(!Eof()) .And. QUD->QUD_FILIAL+QUD->QUD_NUMAUD+QUD->QUD_SEQ == QUH->QUH_FILIAL+QUH->QUH_NUMAUD+QUH->QUH_SEQ
			dDtEncer:= Posicione("QUB",1,xFilial("QUB")+QUD->QUD_NUMAUD,"QUB_ENCREA")			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o Usuario Logado eh auditor nesta Auditoria.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QADCkAudit(QUB->QUB_NUMAUD,.F.)
						
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se Auditoria nao esta encerrada.         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(dDtEncer)						
	
					If lVerEvid
						cTxtEvi := MsMM(QUD->QUD_EVICHV,TamSX3('QUD_EVIDE1')[1])
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se o texto da Evidencia esta preenchido. ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty(cTxtEvi)
							lPend  := .T.
					    EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se questao esta respondida.              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
					If Empty(QUD->QUD_DTAVAL)
						lPend  := .T.
					EndIf
				
	                If lPend
			         	AaDD(aLancAud,{"R",QUH->QUH_FILMAT,QUH->QUH_CODAUD,QUD->QUD_FILIAL,QUD->QUD_NUMAUD,QUD->QUD_CHKLST,QUD->QUD_REVIS,QUD->QUD_CHKITE,QUD->QUD_QSTITE,QUD->(Recno())})
						lPend:= .F.
					EndIf						
	
				EndIf			
   			EndIf
   			QUD->(DbSkip())
		EndDo				
	EndIf
	QUH->(DbSkip())
EndDo

DbSelectArea("QUB")
DbSetOrder(2)
DbSeek(xFilial("QUB"))

While QUB->(!Eof()) .And. QUB->QUB_FILIAL == xFilial("QUB")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Usuario Logado eh auditor nesta Auditoria.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QADCkAudit(QUB->QUB_NUMAUD,.F.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se Auditoria nao esta Encerrada.         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		If Empty(QUB->QUB_ENCREA)
			If QUD->(DbSeek(xFilial("QUD")+QUB->QUB_NUMAUD))
				lPendEnc:= .T.
				While QUD->(!Eof()) .and. (QUD->QUD_FILIAL + QUD->QUD_NUMAUD) == (xFilial("QUD") + QUB->QUB_NUMAUD)
	
					If lVerEvid
						cTxtEvi := MsMM(QUD->QUD_EVICHV,TamSX3('QUD_EVIDE1')[1])
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se o texto da Evidencia esta preenchido. ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty(cTxtEvi)
							lPendEnc:= .F.
							Exit
					    EndIf
					EndIf					
					nSemAval   += If(Empty(QUD->QUD_DTAVAL), 1, 0)
					QUD->(DbSkip())
				Enddo	     
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se questao esta respondida.              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
				If nSemAval > 0
					lPendEnc:= .F.
				EndIf                        
			EndIf
					
			If lPendEnc
				AaDD(aLancAud,{"E",QUB->QUB_FILMAT,QUB->QUB_AUDLID,QUB->QUB_FILIAL,QUB->QUB_NUMAUD,"","","","",QUB->(Recno())})
			EndIf			
	
		EndIf
	EndIf
	QUB->(DbSkip())
EndDo

QUB->(DbSetOrder(1))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³QAD10MonTree³ Autor ³ Eduardo de Souza ³ Data ³ 26/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Monta objeto Tree                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QAD10MonTree(ExpO1,ExpO2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpO1 - Objeto Tree Usuarios                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOC030                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAD10MonTree(oTree)

Local oMenu
Local nSeqTree := 0
Local nCnt     := 0
Local cFilMat  := ""
Local cMatQAA  := ""
Local cFilAud  := ""
Local cNumAud  := ""
Local cCheckLst:= ""
Local cRevis   := ""
Local lCriaTree:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordena Pendencias por Usuario.    							   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aLancAud) > 1
	Asort(aLancAud,,,{|x,y| x[2]+x[3]+x[1]+x[4]+x[5]+x[6]+x[7]+x[8]+x[9] < y[2]+y[3]+y[1]+y[4]+y[5]+y[6]+y[7]+y[8]+y[9]})
EndIf

For nCnt:= 1 to Len(aLancAud)
			
	If cFilMat+cMatQAA <> aLancAud[nCnt,2]+aLancAud[nCnt,3]
		oTree:AddTree( Padr(aLancAud[nCnt,2]+"-"+aLancAud[nCnt,3]+" "+Alltrim(QA_NUSR(aLancAud[nCnt,2],aLancAud[nCnt,3])),100), .F., "BMPUSER",,,,"QAA"+aLancAud[nCnt,2]+aLancAud[nCnt,3])
		lCriaTree:= .T.
	EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Resultados da Auditoria.  				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aLancAud[nCnt,1] == "R"

		If lCriaTree
			oTree:AddTree(PADR(OemToAnsi(STR0032),100),.F. ,"PESQUISA",,,,StrZero(nSeqTree++,4)) // "Resultados"
			lCriaTree:= .F.
		EndIf
				
		If cFilAud+cNumAud <> aLancAud[nCnt,4]+aLancAud[nCnt,5]
			oTree:AddTree(PADR(OemToAnsi(STR0005)+": "+AllTrim(aLancAud[nCnt,5]),100),.F. ,"PMSDOC",,,,"QUB"+aLancAud[nCnt,4]+aLancAud[nCnt,5]) // "Auditoria"
		EndIf
		
		If cCheckLst+cRevis <> aLancAud[nCnt,6]+aLancAud[nCnt,7]
			oTree:AddTree(PADR(OemToAnsi(STR0006)+": "+AllTrim(aLancAud[nCnt,6])+" - "+AllTrim(aLancAud[nCnt,7]),100),.F.,"RELATORIO",,,,"QU2"+aLancAud[nCnt,6]+aLancAud[nCnt,7]) // "Check List"
		EndIf
	
		oTree:AddTreeItem(PADR(OemToAnsi(STR0007)+": "+AllTrim(aLancAud[nCnt,8])+" - "+OemToAnsi(STR0008)+": "+AllTrim(aLancAud[nCnt,9]),100),"FOLDER9",,StrZero(aLancAud[nCnt,10],7)) // "Topico" ### "Questao"
	
		cFilMat  := aLancAud[nCnt,2]
		cMatQAA  := aLancAud[nCnt,3]
		cFilAud  := aLancAud[nCnt,4]
		cNumAud  := aLancAud[nCnt,5]
		cCheckLst:= aLancAud[nCnt,6]
		cRevis   := aLancAud[nCnt,7]

		If Len(aLancAud) >= nCnt+1

			If aLancAud[nCnt+1,1] == "E" .Or. cFilAud+cNumAud <> aLancAud[nCnt+1,4]+aLancAud[nCnt+1,5] .Or. cFilMat+cMatQAA <> aLancAud[nCnt+1,2]+aLancAud[nCnt+1,3]
				oTree:EndTree()
				cFilAud:= ""
				cNumAud:= ""
			EndIf

			If aLancAud[nCnt+1,1] == "E" .Or. cFilAud+cNumAud+cCheckLst+cRevis <> aLancAud[nCnt+1,4]+aLancAud[nCnt+1,5]+aLancAud[nCnt+1,6]+aLancAud[nCnt+1,7] .Or. ;
				cFilMat+cMatQAA <> aLancAud[nCnt+1,2]+aLancAud[nCnt+1,3]
				oTree:EndTree()
				cCheckLst:= "" 
				cRevis   := ""
			EndIf
		
			If aLancAud[nCnt+1,1] == "E"
				oTree:EndTree()				
				lCriaTree:= .T.
				If cFilMat+cMatQAA <> aLancAud[nCnt+1,2]+aLancAud[nCnt+1,3]
					oTree:EndTree()
					cFilMat:= ""
					cMatQAA:= ""
				EndIf
			ElseIf cFilMat+cMatQAA <> aLancAud[nCnt+1,2]+aLancAud[nCnt+1,3]
				oTree:EndTree()
				oTree:EndTree()
				cFilMat:= ""
				cMatQAA:= ""
			EndIf
		Else
			oTree:EndTree()
			oTree:EndTree()
			oTree:EndTree()
			oTree:EndTree()		
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Encerramento de Auditoria.				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf aLancAud[nCnt,1] == "E"
		cFilMat  := aLancAud[nCnt,2]
		cMatQAA  := aLancAud[nCnt,3]

		If lCriaTree
			oTree:AddTree(PADR(OemToAnsi(STR0033),100),.F. ,"BMPINCLUIR",,,,StrZero(nSeqTree++,4)) // "Encerramento"
        	lCriaTree:= .F.
        EndIf

		oTree:AddTreeItem(PADR(OemToAnsi(STR0005)+": "+AllTrim(aLancAud[nCnt,5]),100),"FOLDER9",,"QUB"+aLancAud[nCnt,4]+aLancAud[nCnt,5]) // "Auditoria"

		If Len(aLancAud) >= nCnt+1

			If aLancAud[nCnt+1,1] == "R"
				oTree:EndTree()				
				lCriaTree:= .T.
			ElseIf cFilMat+cMatQAA <> aLancAud[nCnt+1,2]+aLancAud[nCnt+1,3]
				oTree:EndTree()
				oTree:EndTree()
				cFilMat:= ""
				cMatQAA:= ""
			EndIf
		Else
			oTree:EndTree()
			oTree:EndTree()
		EndIf			
	EndIf	
Next nCnt	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o menu de opcoes POPUP                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MENU oMenu POPUP
	MENUITEM OemToAnsi(STR0034) Action FActionQAD(1,oTree)	// "Cadastro"
ENDMENU

oTree:bRClicked:= { |o,x,y| QADAtivPopUp(o,x,y,oMenu) } // Posicao x,y em relação a Dialog

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QADC10DlgV ³ Autor ³ Eduardo de Souza ³ Data ³ 26/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Monta Tela com os detalhes da consulta                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QADC10DlgV(ExpO1,ExpO2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpO1 - Objeto Tree Usuarios                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QADC010                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QADC10DlgV(oTree,oPanel)
Local nCnt	:= 1

QAA->(DbSetOrder(1))

If SubStr(oTree:GetCargo(),1,3) == "QAA"

	If QAA->(DbSeek(SubStr(oTree:GetCargo(),4)))
			
		If aObj2 <> NIL
			For nCnt:= 1 To Len(aObj2)
				aObj2[nCnt]:cCaption:= " "
			Next nCnt
		EndIf
			
		If aObj3 <> NIL			
			For nCnt:= 1 To Len(aObj3)
				aObj3[nCnt]:cCaption:= " "
			Next nCnt
		EndIf

		If aObj1 == NIL
			aObj1:= {}
			@ 040,005 SAY oSay01 PROMPT OemToAnsi(STR0009)+" "+QAA->QAA_MAT SIZE 070,010 OF oPanel PIXEL // "Codigo      :"
			@ 050,005 SAY oSay02 PROMPT OemToAnsi(STR0010)+" "+QAA->QAA_NOME SIZE 150,010 OF oPanel PIXEL // "Nome        :"
			@ 060,005 SAY oSay03 PROMPT OemToAnsi(STR0011)+" "+AllTrim(QAA->QAA_CC)+" - "+Posicione("QAD",1,xFilial("QAD")+QAA->QAA_CC,"QAD_DESC") SIZE 150,010 OF oPanel PIXEL // "Departamento:"
			@ 070,005 SAY oSay04 PROMPT OemToAnsi(STR0012)+" "+AllTrim(QAA->QAA_CODFUN)+" - "+Posicione("QAC",1,xFilial("QAC")+QAA->QAA_CODFUN,"QAC_DESC") SIZE 150,010 OF oPanel PIXEL // "Cargo       :"
			@ 080,005 SAY oSay05 PROMPT OemToAnsi(STR0013)+" "+QAA->QAA_EMAIL SIZE 150,010 OF oPanel PIXEL // "e-mail      :"
			@ 090,005 SAY oSay06 PROMPT OemToAnsi(STR0014)+" "+If(QAA->QAA_AUDIT=="1",OemToAnsi(STR0015),OemToAnsi(STR0016)) SIZE 150,010 OF oPanel PIXEL // "Auditor     :" ### "Sim" ### "Nao"
			Aadd(aObj1,oSay01)
			Aadd(aObj1,oSay02)
			Aadd(aObj1,oSay03)
			Aadd(aObj1,oSay04)
			Aadd(aObj1,oSay05)
			Aadd(aObj1,oSay06)
		Else
			aObj1[1]:cCaption := OemToAnsi(STR0009)+" "+QAA->QAA_MAT
			aObj1[2]:cCaption := OemToAnsi(STR0010)+" "+QAA->QAA_NOME
			aObj1[3]:cCaption := OemToAnsi(STR0011)+" "+AllTrim(QAA->QAA_CC)+" - "+Posicione("QAD",1,xFilial("QAD")+QAA->QAA_CC,"QAD_DESC")
			aObj1[4]:cCaption := OemToAnsi(STR0012)+" "+AllTrim(QAA->QAA_CODFUN)+" - "+Posicione("QAC",1,xFilial("QAC")+QAA->QAA_CODFUN,"QAC_DESC")
			aObj1[5]:cCaption := OemToAnsi(STR0013)+" "+QAA->QAA_EMAIL
			aObj1[6]:cCaption := OemToAnsi(STR0014)+" "+If(QAA->QAA_AUDIT=="1",OemToAnsi(STR0015),OemToAnsi(STR0016))
		EndIf
	EndIf

ElseIf SubStr(oTree:GetCargo(),1,3) == "QUB"

	If QUB->(DbSeek(SubStr(oTree:GetCargo(),4)))

		If aObj1 <> NIL			
			For nCnt:= 1 To Len(aObj1)
				aObj1[nCnt]:cCaption:= " "
			Next nCnt
		EndIf

		If aObj3 <> NIL			
			For nCnt:= 1 To Len(aObj3)
				aObj3[nCnt]:cCaption:= " "
			Next nCnt
		EndIf

		If aObj2 == NIL
			aObj2:= {}
			@ 040,005 SAY oSay01 PROMPT OemToAnsi(STR0017)+" "+QUB->QUB_NUMAUD SIZE 070,010 OF oPanel PIXEL // "Auditoria     :"
			@ 050,005 SAY oSay02 PROMPT OemToAnsi(STR0018)+" "+QUB->QUB_MOTAUD+" - "+Posicione("SX5",1,xFilial("SX5")+"QE"+QUB->QUB_MOTAUD,"X5DESCRI()") SIZE 150,010 OF oPanel PIXEL // "Motivo        :"
			@ 060,005 SAY oSay03 PROMPT OemToAnsi(STR0019)+" "+QADCBox("QUB_TIPAUD", QUB->QUB_TIPAUD) SIZE 150,010 OF oPanel PIXEL // "Tipo          :"
			@ 070,005 SAY oSay04 PROMPT OemToAnsi(STR0020)+" "+DtoC(QUB->QUB_INIAUD) SIZE 100,010 OF oPanel PIXEL // "Inicio        :"
			@ 080,005 SAY oSay05 PROMPT OemToAnsi(STR0021)+" "+DtoC(QUB->QUB_ENCAUD) SIZE 100,010 OF oPanel PIXEL // "Encerramento  :"
			@ 090,005 SAY oSay06 PROMPT OemToAnsi(STR0022)+" "+Posicione("QAA",1,QUB->QUB_FILMAT+QUB->QUB_AUDLID,"QAA_NOME") SIZE 150,010 OF oPanel PIXEL	// "Auditor Lider :"
			@ 100,005 SAY oSay07 PROMPT OemToAnsi(STR0023)+" "+Posicione("SA2",1,xFilial("SA2")+QUB->QUB_CODFOR,"A2_NOME") SIZE 150,010 OF oPanel PIXEL // "Fornecedor    :"
			@ 110,005 SAY oSay08 PROMPT OemToAnsi(STR0024)+" "+QUB->QUB_AUDRSP SIZE 150,010 OF oPanel PIXEL // "Auditado Resp.:"
			@ 120,005 SAY oSay09 PROMPT OemToAnsi(STR0025)+" "+AllTrim(Str(QUB->QUB_IQS)) SIZE 070,010 OF oPanel PIXEL // "Nota IQS      :"
			Aadd(aObj2,oSay01)
			Aadd(aObj2,oSay02)
			Aadd(aObj2,oSay03)
			Aadd(aObj2,oSay04)
			Aadd(aObj2,oSay05)
			Aadd(aObj2,oSay06)
			Aadd(aObj2,oSay07)
			Aadd(aObj2,oSay08)
			Aadd(aObj2,oSay09)			
        Else
			aObj2[1]:cCaption := OemToAnsi(STR0017)+" "+QUB->QUB_NUMAUD
			aObj2[2]:cCaption := OemToAnsi(STR0018)+" "+QUB->QUB_MOTAUD+" - "+Posicione("SX5",1,xFilial("SX5")+"QE"+QUB->QUB_MOTAUD,"X5DESCRI()")
			aObj2[3]:cCaption := OemToAnsi(STR0019)+" "+QADCBox("QUB_TIPAUD", QUB->QUB_TIPAUD)
			aObj2[4]:cCaption := OemToAnsi(STR0020)+" "+DtoC(QUB->QUB_INIAUD)
			aObj2[5]:cCaption := OemToAnsi(STR0021)+" "+DtoC(QUB->QUB_ENCAUD)
			aObj2[6]:cCaption := OemToAnsi(STR0022)+" "+Posicione("QAA",1,QUB->QUB_FILMAT+QUB->QUB_AUDLID,"QAA_NOME")
			aObj2[7]:cCaption := OemToAnsi(STR0023)+" "+Posicione("SA2",1,xFilial("SA2")+QUB->QUB_CODFOR,"A2_NOME")
			aObj2[8]:cCaption := OemToAnsi(STR0024)+" "+QUB->QUB_AUDRSP
			aObj2[9]:cCaption := OemToAnsi(STR0025)+" "+AllTrim(Str(QUB->QUB_IQS))
		EndIf
	EndIf

ElseIf SubStr(oTree:GetCargo(),1,3) == "QU2"

	If QU2->(DbSeek(xFilial("QU2")+SubStr(oTree:GetCargo(),4)))

		If aObj1 <> NIL
			For nCnt:= 1 To Len(aObj1)
				aObj1[nCnt]:cCaption:= " "
			Next nCnt
		EndIf

		If aObj2 <> NIL
			For nCnt:= 1 To Len(aObj2)
				aObj2[nCnt]:cCaption:= " "
			Next nCnt
		EndIf

		If aObj3 == NIL
			aObj3:= {}			
			@ 040,005 SAY oSay01 PROMPT OemToAnsi(STR0026)+" "+QU2->QU2_CHKLST SIZE 070,010 OF oPanel PIXEL // "Check List  :"
			@ 050,005 SAY oSay02 PROMPT OemToAnsi(STR0027)+" "+QU2->QU2_REVIS  SIZE 070,010 OF oPanel PIXEL // "Revisao     :"
			@ 060,005 SAY oSay03 PROMPT OemToAnsi(STR0028)+" "+QU2->QU2_DESCRI SIZE 200,010 OF oPanel PIXEL // "Descricao   :"
			@ 070,005 SAY oSay04 PROMPT OemToAnsi(STR0029)+" "+QU2->QU2_OBSERV SIZE 200,010 OF oPanel PIXEL // "Observacao  :"
			@ 080,005 SAY oSay05 PROMPT OemToAnsi(STR0030)+" "+DtoC(QU2->QU2_ULTREV) SIZE 100,010 OF oPanel PIXEL // "Ult. Revisao:"
			Aadd(aObj3,oSay01)
			Aadd(aObj3,oSay02)
			Aadd(aObj3,oSay03)
			Aadd(aObj3,oSay04)
			Aadd(aObj3,oSay05)
		Else
			aObj3[1]:cCaption := OemToAnsi(STR0026)+" "+QU2->QU2_CHKLST
			aObj3[2]:cCaption := OemToAnsi(STR0027)+" "+QU2->QU2_REVIS
			aObj3[3]:cCaption := OemToAnsi(STR0028)+" "+QU2->QU2_DESCRI
			aObj3[4]:cCaption := OemToAnsi(STR0029)+" "+QU2->QU2_OBSERV
			aObj3[5]:cCaption := OemToAnsi(STR0030)+" "+DtoC(QU2->QU2_ULTREV)
		EndIf
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FActionQAD ³ Autor ³ Eduardo de Souza    ³ Data ³ 05/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa para carregar os Cadastros                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FActionQAD(nOpcao,oTree)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Numerico contendo a opcao(1-Cad)                   ³±±
±±³          ³ ExpO1 - Objeto do Tree para poder pegar o numero do recno()³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FActionQAD(nOpcao,oTree)

Local cCargo:= oTree:GetCargo()

Private cCadastro:= ""
Private Altera   := .F.

If Left(cCargo,3) == "QAA"
	If QAA->(DbSeek(SubStr(oTree:GetCargo(),4)))
		If nOpcao == 1
			cCadastro:= "Usuarios"
			AxVisual("QAA",QAA->(RecNo()),2)
		EndIf
	EndIf


ElseIf Left(cCargo,3) == "QUB"
	If QUB->(DbSeek(SubStr(oTree:GetCargo(),4)))
		If nOpcao == 1
			cCadastro:= "Auditorias"
			Qad100Man("QUB",QUB->(RecNo()),2)
		EndIf
	EndIf

ElseIf Left(cCargo,3) == "QU2"
	If QU2->(DbSeek(xFilial("QU2")+SubStr(oTree:GetCargo(),4)))
		If nOpcao == 1
			cCadastro:= "Check List"
			AxVisual("QU2",QU2->(RecNo()),2)
		EndIf
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QADAtivPopUp³ Autor ³ Eduardo de Souza    ³ Data ³ 05/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa para Ativar Pop-Up                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADAtivPopUp(oTree,nX,nY,oMenu)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto do Tree                                     ³±±
±±³          ³ ExpN1 - Numerico contendo as coordenadas da linha          ³±±
±±³          ³ ExpN2 - Numerico contendo as coordenadas da coluna         ³±±
±±³          ³ ExpO2 - Objeto do POPUP - Menu                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QADAtivPopUp(oTree,nX,nY,oMenu)

Local cCargo := oTree:GetCargo() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilita todos os itens do menu                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AEval( oMenu:aItems, { |x| x:Disable() } ) 

If Left(cCargo,3) == "QU2" .Or. Left(cCargo,3) == "QAA" .Or. Left(cCargo,3) == "QUB"
	oMenu:aItems[1]:enable()
EndIf

oMenu:Activate( nX, nY, oTree )

Return