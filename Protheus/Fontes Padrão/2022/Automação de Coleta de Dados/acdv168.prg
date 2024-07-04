#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'APVT100.CH'


Static __nSem168 :=0
/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACDV168  ³ Autor ³ ACD                   ³ Data ³ 28/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Geracao de NFs                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACDV168()
Local aTela
Local nOpc 
If ACDGet170()
	Return ACDV168X(0)
EndIf
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
aTela := VtSave()
VTClear()
If lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VTSAY "Geracao NFs"
	nOpc:=VTaChoice(2,0,3,VTMaxCol(),{"Ordem de Separacao","Pedido de Venda"})
ElseIf VtModelo()=="RF"
	@ 0,0 VTSAY "Geracao NFs"
	@ 1,0 VTSay "Selecione:"
	nOpc:=VTaChoice(3,0,6,VTMaxCol(),{"Ordem de Separacao","Pedido de Venda"}) 
ElseIf VtModelo()=="MT44"
	@ 0,0 VTSAY "Geracao NFs"
	@ 1,0 VtSAY "Selecione:"
	nOpc:=VTaChoice(0,20,1,VTMaxCol(),{"Ordem de Separacao","Pedido de Venda"}) 
ElseIf VtModelo()=="MT16"
	@ 0,0 VTSAY "Geracao NFs"
	nOpc:=VTaChoice(1,0,1,VTMaxCol(),{"Ordem de Separacao","Pedido de Venda"}) 
EndIf	
VtRestore(,,,,aTela)
If nOpc == 1 // por ordem de separacao
	ACDV168A()
ElseIf nOpc == 2 // por pedido de venda
	ACDV168B()
EndIf
Return 1

Function ACDV168A()
ACDV168X(1)
Return
Function ACDV168B()
ACDV168X(2)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACDV168X ³ Autor ³ ACD                   ³ Data ³ 03/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Expedicao - Geracao da Nota Fiscal de Saida                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ACDV168X(nOpc)
Private cCodOpe     := CBRetOpe()
Private cNota
Private cDivItemPv  := Alltrim(GetMV("MV_DIVERPV"))
Private lMSErroAuto := .F.
Private lMSHelpAuto := .t.
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
If Type('cOrdSep')=='U'
	Private cOrdSep := Space(6)
EndIf

__nSem168 :=0 // variavel static do fonte para controle de semaforo

If Empty(cCodOpe)
	VTAlert("Operador nao cadastrado","Aviso",.T.,4000) //###
	Return .F.
EndIf

//Verifica se foi chamado pelo programa ACDV170 e se ja foi gerado NFS
If ACDGet170() .AND.CB7->CB7_STATUS >= "5"
	If !A170SLProc() .OR. !("03" $ CB7->CB7_TIPEXP)
		Return 1
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ativa/Destativa a tecla avanca e retrocesa                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A170ATVKeys(.t.,.f.)	 //Ativa tecla avanca e desativa tecla retrocede
ElseIf ACDGet170() .AND. !("03" $ CB7->CB7_TIPEXP)
	Return 1
ElseIf ACDGet170()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desativa a  tecla  avanca                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A170ATVKeys(.f.,.t.)
EndIf

VTClear()
If VtModelo()=="RF" .or. lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VtSay "Geracao de Nota"
EndIf
If ! CBSolCB7(nOpc,{|| VldCodSep()})
	Return MSCBASem() // valor necessario para finalizar o acv170 e liberar o semaforo
EndIf

//Ver se o codigo de separacao devera vir do programa anterior.
If Empty(cOrdSep)
	cOrdSep := CB7->CB7_ORDSEP
EndIf

//If VTLastKey() == 27
//   Return 10
//EndIf

If ! GeraNota()
	Return FimProcNFS(10)
Endif
Return FimProcNFS()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FimProcNFS ³ Autor ³ ACD                 ³ Data ³ 03/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Finalisa o processo de geracao de NFS                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FimProcNFS(nSai)
Default nSai := 1

//Desbloqueia semaforo
MSCBASem()

If nSai<>10 .AND. Empty(CB7->(CB7_NOTA+CB7_SERIE))
	nSai := 0
EndIf
//Verifica se esta sendo chamado pelo ACDV170 e se existe um avanco
//ou retrocesso forcado pelo operador
If ACDGet170() .AND. A170AvOrRet()
	nSai := A170ChkRet()
EndIf
Return nSai



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldCodSep³ Autor ³ ACD                   ³ Data ³ 03/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da Ordem de Separacao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldCodSep()

If Empty(cOrdSep)
	VtKeyBoard(chr(23))
	Return .f.
EndIf

CB7->(DbSetOrder(1))
If !CB7->(DbSeek(xFilial("CB7")+cOrdSep))
	VtAlert("Ordem de separacao nao encontrada.","Aviso",.t.,4000,3) //###
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If !("03") $ CB7->CB7_TIPEXP
	VtAlert("Ordem de separacao nao configurada para Gerar Nota","Aviso",.t.,4000,3) //###
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If CB7->CB7_STATUS == "0" .OR. CB7->CB7_STATUS == "1"
	VtAlert("Ordem de separacao possui itens nao separados","Aviso",.t.,4000,3) //###
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If ("02" $ CB7->CB7_TIPEXP) .and. (CB7->CB7_STATUS == "2" .OR. CB7->CB7_STATUS == "3")
	VtAlert("Ordem de separacao possui itens nao embalados","Aviso",.t.,4000,3) //###
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If EmbqInic()  //CB7->CB7_STATUS  == "7" .OR. CB7->CB7_STATUS  == "8"
	VtAlert("Ordem de separacao em processo de embarque","Aviso",.t.,4000,3) //###
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If CB7->CB7_STATUS == "9" .and. !("03" $ CBUltExp(CB7->CB7_TIPEXP))
	VtAlert('Ordem de separacao encerrada','Atencao',.T.)  //###
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If CB7->CB7_STATPA == "1" .AND. CB7->CB7_CODOPE # cCodOpe  // SE ESTIVER EM SEPARACAO E PAUSADO SE DEVE VERIFICAR SE O OPERADOR E' O MESMO
	VtBeep(3)
	If !VTYesNo("Ordem Separacao iniciada pelo operador "+CB7->CB7_CODOPE+". Deseja continuar ?","Aviso",.T.) //######
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
EndIf

If ! MSCBFSem() //fecha o semaforo, somente um separador por ordem de separacao
	VtAlert("Geracao de NFS ja esta em andamento...!","Aviso",.t.,4000,3) //###
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

RecLock("CB7",.f.)
If !Empty(CB7->CB7_STATPA)  // se estiver pausado tira o STATUS  de pausa
	CB7->CB7_STATPA := " "
EndIf
CB7->CB7_CODOPE := cCodOpe
CB7->(MsUnlock())
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GeraNota ³ Autor ³ ACD                   ³ Data ³ 03/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Geracao da Nota Fiscal                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraNota()
Local   aPvlNfs :={}
Local   cSerie  := GetMV("MV_ACDSERI")
Local   lExcNF  := GetMV("MV_CBEXCNF")=='1'
Local   lGeraSTel := SuperGetMv("MV_GNRENF", .F., .F.)  == .T. 
Local   aRegSD2
Local   aRegSE1
Local   aRegSE2
Local   lNFOK
Local   lSai       := .f.
Local	nI
Local   cUltTipoExp:= CBUltExp(CB7->CB7_TIPEXP)
Private nModulo    := 4

If ! EMPTY(CB7->(CB7_NOTA+CB7_SERIE))
	If !lExcNF
		VTAlert("Conforme informado no parametro MV_CBEXCNF a nota deve ser excluida pelo Protheus","Aviso",.t.,6000,3)  //###
		Reclock('CB7',.f.)
		CB7->CB7_STATPA := "1"  // Pausa
		CB7->(MsUnLock())
		Return .f.
	EndIf
	If CB7->CB7_STATUS == "6"
		VTAlert("Nota ja impressa para esta Ordem de Separacao","Aviso",.t.,3000)  //###
		If ! VTYesNo("Deseja prosseguir com a excluisao ?","Aviso",.t.)  //###
			Reclock('CB7',.f.)
			CB7->CB7_STATPA := "1"  // Pausa
			CB7->(MsUnLock())
			Return .f.
		EndIf
	Else
		If ! VTYesNo("Deseja excluir a nota?","Aviso",.t.)  //###
			Reclock('CB7',.f.)
			CB7->CB7_STATPA := "1"  // Pausa
			CB7->(MsUnLock())
			Return .f.
		EndIf
	Endif
	If VTLastKey()== 27
		Return .f.
	EndIf
	
	Begin transaction
		VTClear()
		VTMsg('Excluindo nota...')  //
		If ExistBlock("ACD170FIM")  //Ponto de Entrada antes da Tratativa da Nota Fiscal (2 = exclusao)
			ExecBlock("ACD170FIM",,,{2,CB7->CB7_NOTA,CB7->CB7_SERIE})
		EndIf
		SF2->(DbSetOrder(1))
		If ! SF2->(DbSeek(xFilial("SF2")+CB7->(CB7_NOTA+CB7_SERIE)))
			VTAlert("Nota "+CB7->(CB7_NOTA)+"-"+SerieNfId("CB7",2,"CB7_SERIE")+" nao encontrada ","Aviso",.t.,6000,3) 		 //######
			DisarmTransaction()
			BREAK
		EndIf
		If ! MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
			VTAlert("Falha na exclusao da nota","Aviso",.t.,6000,3) 		 //###
			DisarmTransaction()
			BREAK
		EndIf
		If VTLastKey()== 27
			DisarmTransaction()
			BREAK
		EndIf
		SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.F.,.F.))
		AtuCB0(cNota,cSerie,.t.)
		Reclock('CB7',.f.)
		CB7->CB7_STATUS := CBAntProc(CB7->CB7_TIPEXP,"03*")
		CB7->(MsUnlock())
	End transaction
	Reclock('CB7',.f.)
	CB7->CB7_STATPA := "1"  // Pausa
	CB7->(MsUnLock())
Else
	If ! VTYesNo("Confirma a geracao da nota?","Aviso",.t.) 		 //###
		RecLock("CB7")
		CB7->CB7_STATPA := "1"  // EM PAUSA
		CB7->(MsUnlock())
		Return .f.
	EndIf
	If VTLastKey()== 27
		Return .f.
	EndIf    
	
	If ExistBlock("ACD168NFOK")	  //Ponto de Entrada apos confirmar geracao da nota, valida continuidade do processamento.
		lNFOK := ExecBlock("ACD168NFOK",.F.,.F.)
		lNFOK := If(ValType(LNFOK)=="L",lNFOK,.F.)
		If !lNFOK
			RecLock("CB7")
			CB7->CB7_STATPA := "1"  // EM PAUSA
			CB7->(MsUnlock())
			Return .f.
		Endif
	EndIf	 	

	Begin transaction

		VTClear()
		VTMsg('Gerando nota...')  //
		Analisa()
		Libera(aPvlNfs)
		Pergunte("MT460A",.F.) 
		IF Empty(aPvlNfs)
			VTAlert('Problema com empenho','Aviso',.t.,2000)  //###
			MsUnLockAll()
			lSai:= .t.
			DisarmTransaction()
			BREAK
		EndIf
		If lGeraSTel			
			If (mv_par01  == 2) .And. (mv_par17  == 1) .And. (mv_par18  == 1) .And.; 
				(mv_par19  = 1) .And.  (mv_par20  == 2)
				For nI:=1 To Len(aPvlNfs)
					cNota := MaPvlNfs(aPvlNfs[nI],cSerie, .F., .F., .F., .T., .F., 0, 0, .T., .F.)
					AtuCB0(cNota,cSerie,.F.,(nI==1))
				Next
			ElseIf (mv_par18  == 1)
				mv_par01  := 2
				mv_par17  := 1
								
				 For nI:=1 To Len(aPvlNfs)
				 cNota := MaPvlNfs(aPvlNfs[nI],cSerie, .F., .F., .F., .T., .F., 0, 0, .T., .F.)
				    AtuCB0(cNota,cSerie,.F.,(nI==1))
				 Next	
			 Else
			 	mv_par01  := 2
				For nI:=1 To Len(aPvlNfs)
					cNota := MaPvlNfs(aPvlNfs[nI],cSerie, .F., .F., .F., .T., .F., 0, 0, .T., .F.)
					AtuCB0(cNota,cSerie,.F.,(nI==1))
				Next
			EndIf
		Else
			For nI:=1 To Len(aPvlNfs)
				cNota := MaPvlNfs(aPvlNfs[nI],cSerie, .F., .F., .F., .T., .F., 0, 0, .T., .F.)
				AtuCB0(cNota,cSerie,.F.,(nI==1))
			Next
		EndIf

	End transaction
	dbUnLockAll()

	If lMsErroAuto
		VTDispFile(NomeAutoLog(),.t.)
	EndIf
	If lSai .OR. lMsErroAuto 
		Reclock('CB7',.f.)
		CB7->CB7_STATPA := "1"  // Pausa
		CB7->(MsUnLock())
		Return .f.
	Endif
	If !lMsErroAuto .and. ExistBlock("ACD170FIM")  //Ponto de Entrada apos a Tratativa da Nota Fiscal (1 = geracao)
		ExecBlock("ACD170FIM",,,{1,cNota,cSerie})
	EndIf
	Reclock('CB7',.f.)
	If "03" $ cUltTipoExp
		CB7->CB7_STATUS := "9"  // FINALIZADO		
		VTAlert('Processo de expedicao finalizado','Aviso',.t.,4000) 		 //###
	Else
		CB7->CB7_STATUS := "5"  // gerado nota fiscal
		CB7->CB7_STATPA := "1"  // Pausa
		VTAlert("Nota Fiscal Gerada com sucesso","Aviso",.t.,4000) 		 //###
	EndIf
	CB7->(MsUnLock())
EndIf
MsUnLockAll()
CBLogExp(cOrdSep)
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AtuCB0   ³ Autor ³ ACD                   ³ Data ³ 03/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualizacao das Etiquetas apos a geracao da Nota           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtuCB0(cNota,cSerie,lEstorna,lInfoNFs)
Local aVolume := {}
Local aRetCB0 := {}
Default lEstorna := .F.
Default lInfoNFs := .T.

CB7->(DbSetOrder(1))
CB7->(DbSeek(xFilial("CB7")+cOrdSep))

CB6->(DBSetOrder(1))
// soma a quantidade de volumes da ordem de separacao
CB9->(DbSetOrder(1))
CB9->(DBSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
While CB9->(!Eof() .and. xFilial("CB9")+CB7->CB7_ORDSEP == CB9_FILIAL+CB9_ORDSEP)
	If ascan(aVolume,CB9->CB9_VOLUME) ==0
		aadd(aVolume,CB9->CB9_VOLUME)
		If CB6->(DbSeek(xFilial("CB6")+CB9->CB9_VOLUME))
			RecLock('CB6')
			If !lEstorna  
				If lInfoNFs
					CB6->CB6_NOTA := cNota
					//CB6->CB6_SERIE:= cSerie 
					SerieNfId("CB6",1,"CB6_SERIE",,,,cSerie)
				Else
					CB6->CB6_NOTA := ''
					CB6->CB6_SERIE:= ''
				EndIf
			Else
				CB6->CB6_NOTA := ''
				CB6->CB6_SERIE:= ''
			EndIf
			CB6->(MsUnlock())
		EndIf
	EndIf
	aRetCB0 := CBRetEti(CB9->CB9_CODETI,'01')
	If !Empty(aRetCB0)
		If ! lEstorna
			If lInfoNFs
				aRetCB0[13] := cNota
				aRetCB0[14] := SubStr(cSerie,1,3)
			Else
				aRetCB0[13] := ''
				aRetCB0[14] := ''
			EndIf
		Else
			aRetCB0[13] := ''
			aRetCB0[14] := ''
		EndIf
		CBGrvEti("01",aRetCB0,CB9->CB9_CODETI)
	EndIf
	CB9->(DbSkip())
EndDo
If !lEstorna
	SF2->(DbSetOrder(1))
	SF2->(DbSeek(xFilial("SF2")+PADR(cNota,TamSX3("F2_DOC")[1])+cSerie))
	RecLock("SF2",.F.)
	SF2->F2_VOLUME1 := Len(aVolume)   // grava quantidade de volumes na nota
	SF2->(MsUnlock())

	SD2->(DbSetOrder(3))
	If SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		RecLock("SD2",.F.)
		While SD2->(! Eof()) .and. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA ==;
				SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
			RecLock("SD2",.F.)
			SD2->D2_ORDSEP:= cOrdSep   // grava ordem de separacao	
			SD2->(DbSkip())
		Enddo
		SD2->(MsUnlock())
	Endif
	If lInfoNFs
		RecLock('CB7')
		CB7->CB7_NOTA := cNota
		//CB7->CB7_SERIE:= cSerie
		SerieNfId("CB7",1,"CB7_SERIE",,,,cSerie)
		CB7->CB7_VOLEMI:= " "
		CB7->CB7_NFEMIT:= " "
		CB7->(MsUnlock())
	EndIf
Else
	RecLock('CB7')
	CB7->CB7_NOTA   := ""
	CB7->CB7_SERIE  := ""
	CB7->CB7_VOLEMI := " "
	CB7->CB7_NFEMIT := " "
	CB7->(MsUnlock())
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Libera   ³ Autor ³ ACD                   ³ Data ³ 07/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Liberacao dos itens do pedido para a geracao da Nota       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Libera(aPvlNfs,lEstorno,aItensDiverg)
Local	cSeeKCB9	:= ""
Local	nItem		:= 0
Local   nX   
Local   nPrcVen		:=0
Local   lContinua   := .f.
Local   aEmp        :={}
Local   aPedidos    :={}
Local	nMaxItens	:= GETMV("MV_NUMITEN")			//Numero maximo de itens por nota (neste caso por ordem de separacao)- by Erike
Local   lACD168FLIB := .F.
Default lEstorno    := .f.
Default aItensDiverg:= {}

nMaxItens := If(Empty(nMaxItens),99,nMaxItens)

CB8->(DbSetOrder(1))
CB8->(DbSeek(xFilial("CB8")+cOrdSep))
While  CB8->(! Eof() .AND. CB8_FILIAL+CB8_ORDSEP==xFilial('CB8')+cOrdSep)
	If Ascan(aPedidos,{|x| x[1]+x[2]== CB8->(CB8_PEDIDO+CB8_ITEM)}) == 0
		aadd(aPedidos,{CB8->CB8_PEDIDO,CB8->CB8_ITEM})
	EndIf
	CB8->(DbSkip())
EndDo

aPvlNfs  :={}
For nX:= 1 to len(aPedidos)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Libera quantidade embarcada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SC5->(dbSetOrder(1)) //-- C5_FILIAL+C5_NUM
	SC5->(DbSeek(xFilial("SC5")+aPedidos[nx,1]))
	SC6->(DbSetOrder(1)) //-- C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	SC6->(DbSeek(xFilial("SC6")+aPedidos[nx,1]+aPedidos[nx,2]))
	SC9->(DbSetOrder(1)) //-- C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	If !SC9->(DbSeek(xFilial("SC9")+aPedidos[nx,1]+aPedidos[nx,2]))
		If lEstorno
			Do While SC6->(!Eof() .and. C6_FILIAL+C6_NUM+C6_ITEM==xFilial("SC6")+aPedidos[nX,1]+aPedidos[nx,2])
				aEmp := CarregaEmpenho(lEstorno)
				nQtdLib := SC6->C6_QTDVEN
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ LIBERA (Pode fazer a liberacao novamente caso com novos lotes³
				//³         caso possua)                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaLibDoFat(SC6->(Recno()),nQtdLib,.T.,.T.,.F.,.F.,	.F.,.F.,	NIL,{||SC9->C9_ORDSEP := cOrdSep},aEmp,.T.)
				SC6->(DbSkip())
			EndDo
		EndIf
		Loop
	EndIf

	Do While SC6->(!Eof() .and. C6_FILIAL+C6_NUM+C6_ITEM==xFilial("SC6")+aPedidos[nx,1]+aPedidos[nx,2])

		If !Empty(aItensDiverg)
			nPosItemDiv := Ascan(aItensDiverg,{|x| x[1]+x[2]+x[3]== SC6->(C6_NUM+C6_ITEM+C6_PRODUTO)})
			If nPosItemDiv == 0
				SC6->(DbSkip())
				Loop
			EndIf
		EndIf
		If lEstorno
			nQtdLib := SC6->C6_QTDVEN
		Else
			nQtdLib := SC6->C6_QTDEMP
		EndIf
		/*
		// ESTORNA A LIBERACAO PRIMEIRO
		SC9->(DbSetOrder(1))
		If ! SC9->(DbSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM)))               //FILIAL+NUMERO+ITEM
			SC6->(DbSkip())
			Loop
		EndIf
		*/
		lContinua:= .f.
		While SC9->(! Eof() .and. C9_FILIAL+C9_PEDIDO+C9_ITEM==xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))
			If Empty(SC9->C9_NFISCAL) .and. SC9->C9_AGREG == CB7->CB7_AGREG
				lContinua:= .t.
				Exit
			EndIf
			SC9->(DbSkip())
		End
		If ! lContinua
			SC6->(DbSkip())
			Loop
		EndIf

		CB8->(DbSetOrder(2))
		If ! CB8->(DbSeek(xFilial("CB8")+SC6->(C6_NUM+C6_ITEM)))
			SC6->(DbSkip())
			Loop
		EndIf

		If ExistBlock("ACD168FLIB")
			// Ponto de entrada para forcar a liberacao de pedidos:
			lACD168FLIB := (If(ValType((lACD168FLIB := ExecBlock("ACD168FLIB",.F.,.F.))) == "L",lACD168FLIB,.F.))
		EndIf
		//Esta validacao sera verdadeira se o produto tiver rastro e nao houver verficacao no momento da leitura
		//sendo assim sendo necessario estonar o SDC e gera outro conforme os itens lidos pelo coletor.
		//ou se o item do pedido estiver marcado com divergencia da leitura o mesmo devera ser estornado e sera
		//necessario liberar novamente sem o vinculo da ordem de separacao.
		If (RASTRO(SC6->C6_PRODUTO) .AND. CB8->CB8_CFLOTE <> "1" ) .or. !Empty(aItensDiverg) .or. lACD168FLIB
			aEmp 			:= CarregaEmpenho(lEstorno) // Nao eh estorno
			SC9->(DbSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM)))
			While SC9->(! Eof() .and. C9_FILIAL+C9_PEDIDO+C9_ITEM==xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))
				If ! Empty(SC9->C9_NFISCAL) .or. SC9->C9_AGREG # CB7->CB7_AGREG
					SC9->(DbSkip())
					Loop
				EndIf
				SC9->(a460Estorna())	 //estorna o que estava liberado no sdc e sc9
				SC9->(DbSkip())
			Enddo
			If !Empty(aItensDiverg)
				// NAO LIBERA CREDITO NEM ESTOQUE...ITEM COM DIVERGENCIA APONTADA (MV_DIVERPV)
				MaLibDoFat(SC6->(Recno()),0,.F.,.F.,.F.,.F.,	.F.,.F.,	NIL,{||SC9->C9_ORDSEP := Space(TamSx3("C9_ORDSEP")[1])},aEmp,.T.)
			Else
				// LIBERA NOVAMENTE COM OS NOVOS LOTES
				MaLibDoFat(SC6->(Recno()),nQtdLib,.T.,.T.,.F.,.F.,	.F.,.F.,	NIL,{||SC9->C9_ORDSEP := cOrdSep},aEmp,.T.)
			EndIf
		EndIf

		SC9->(DbSetOrder(1))
		SC9->(DbSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM)))               //FILIAL+NUMERO+ITEM
		While SC9->(! Eof() .and. C9_FILIAL+C9_PEDIDO+C9_ITEM==xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))
			If ! Empty(SC9->C9_NFISCAL) .or. SC9->C9_AGREG # CB7->CB7_AGREG .or. SC9->C9_ORDSEP # CB7->CB7_ORDSEP
				SC9->(DbSkip())
				Loop
			EndIf                            
			
			//-- So carrega pedidos para serem separados de produtos separados
			If cSeeKCB9 <> SC9->(xFilial("SC9")+C9_ORDSEP+C9_ITEM+C9_PRODUTO+C9_LOCAL) 
				CB9->(DbSetOrder(6)) 
				cSeekCB9 := xFilial("CB9")+cOrdSep+SC9->(C9_ITEM+C9_PRODUTO+C9_LOCAL)
				If ! CB9->( DbSeek(cSeekCB9) )
					SC9->( DbSkip() )
					Loop
				EndIf
			EndIf
						
			SE4->(DbSetOrder(1))
			SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))              //FILIAL+PRODUTO
			SB2->(DbSetOrder(1))
			SB2->(DbSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL)))  //FILIAL+PRODUTO+LOCAL
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES) )                 //FILIAL+CODIGO

			nPrcVen := SC9->C9_PRCVEN
			
			If ( SC5->C5_MOEDA <> 1 )
				nPrcVen := a410Arred(xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase,8),"D2_PRCVEN")
			EndIf
					   
			If Empty(nItem) .Or. (nItem >=nMaxItens)
				aadd(aPvlNfs,{})
				nItem := 0
			EndIf
			SC9->(aadd(aPvlNfs[Len(aPvlNfs)],;
				{C9_PEDIDO,;  					// 01
				C9_ITEM   ,;					// 02
				C9_SEQUEN ,;					// 03
				C9_QTDLIB ,;					// 04
				nPrcVen   ,;					// 05
				C9_PRODUTO,;					// 06
				(SF4->F4_ISS=="S"),;			// 07
				SC9->(RecNo()),;				// 08
				SC5->(RecNo()),;				// 09
				SC6->(RecNo()),;				// 10
				SE4->(RecNo()),;				// 11
				SB1->(RecNo()),;				// 12
				SB2->(RecNo()),;				// 13
				SF4->(RecNo())}))				// 14
			nItem++
			SC9->(DbSkip())
		EndDo
		SC6->(DbSkip())
	Enddo
Next
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CarregaEmpenho ³ Autor ³ Anderson Rodrigues  ³ Data ³ 06/01/04³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna os produtos realmente separados para atualizar o emp. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CarregaEmpenho()
Local aEmp:={}
Local aEtiqueta:={}
Local dValidLot:= sToD("")

CB9->(DBSetOrder(11))
CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+SC6->C6_ITEM+SC6->C6_NUM))
While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP+CB9_ITESEP+CB9_PEDIDO == xFilial("SC9")+CB7->CB7_ORDSEP+SC6->C6_ITEM+SC6->C6_NUM)
	nPos :=ascan(aEmp,{|x| x[1]+x[2]+x[3]+x[4]+x[11] == CB9->(CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+CB9_LCALIZ+CB9_LOCAL)})
	If nPos ==0

		// Busca validade do lote para gravar na liberacao do PV (C9_DTVALID)
		SB8->(DbSetOrder(3))
		If SB8->(DbSeek(xFilial("SB8") + CB9->(CB9_PROD + CB9_LOCAL + CB9_LOTECT + CB9_NUMLOT)))
			dValidLot := SB8->B8_DTVALID
		EndIf

		CB9->(aadd(aEmp,{CB9_LOTECT,CB9_NUMLOT,CB9_LCALIZ,CB9_NUMSER,CB9_QTESEP,ConvUM(CB9_PROD,CB9_QTESEP,0,2),dValidLot,,,,CB9_LOCAL,0}))
	Else
		aEmp[nPos,5] +=CB9->CB9_QTESEP
	EndIf
	If ! Empty(CB9->CB9_CODETI)
		aEtiqueta := CBRetEti(CB9->CB9_CODETI,"01")
		If ! Empty(aEtiqueta)
			aEtiqueta[13]:= CB7->CB7_NOTA
			aEtiqueta[14]:= SerieNfId("CB7",2,"CB7_SERIE")
			CBGrvEti("01",aEtiqueta,CB9->CB9_CODETI)
		EndIf
	EndIf
	CB9->(DBSkip())
EndDo
Return aEmp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Analisa  ³ Autor ³ Anderson Rodrigues    ³ Data ³ 06/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Analisa itens do Pedido de Vendas e da Ordem de separacao  ³±±
±±³          ³ que nao devem ser gerados na Nota devido a divergencia     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Analisa()
Local  aSvAlias     := GetArea()
Local  aSvCB8       := CB8->(GetArea())
Local  aSvSC6       := SC6->(GetArea())
Local  aItensDiverg := {}
Local  nX

If CB7->CB7_ORIGEM # "1" .or. CB7->CB7_DIVERG # "1"
	Return
EndIf

CB8->(DbSetOrder(1))
CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP))
While CB8->(!Eof() .and. CB8_ORDSEP == CB7->CB7_ORDSEP)
	If Empty(CB8->CB8_OCOSEP)
		CB8->(DbSkip())
		Loop
	Endif
	If AllTrim(CB8->CB8_OCOSEP) == cDivItemPv
		aadd(aItensDiverg,{CB8->CB8_PEDIDO,CB8->CB8_ITEM,CB8->CB8_SEQUEN,CB8->CB8_PROD,If(CB8->(CB8_QTDORI-CB8_SALDOS)==0,CB8->CB8_QTDORI,CB8->(CB8_QTDORI-CB8_SALDOS)),CB8->(Recno()),CB8->CB8_LOCAL,CB8->CB8_LCALIZ})
	EndIf
	CB8->(DbSkip())
EndDo
If ! Empty(aItensDiverg)
	//Exclusao dos itens divergentes do CB8 que nao devem ser gerados na Nota e ajuste do SC9
	For nX:=1 to len(aItensDiverg)
		SC9->(DbsetOrder(1))
		If SC9->(DbSeek(xFilial("SC9")+aItensDiverg[nX,1]+aItensDiverg[nX,2]+aItensDiverg[nX,3]+aItensDiverg[nX,4]))
			RecLock("SC9",.f.)
			SC9->C9_ORDSEP:= " "
			SC9->(MsUnlock())
		Endif
		CB8->(DbGoto(aItensDiverg[nX,6]))
		RecLock("CB8",.f.)
		CB8->(DbDelete())
		CB8->(MsUnlock())
	Next
	//Alteracao do CB7:
	RecLock("CB7",.f.)
	CB7->CB7_DIVERG := " "
	CB7->(MsUnlock())
EndIf
RestArea(aSvSC6)
RestArea(aSvCB8)
RestArea(aSvAlias)
Return


//Indica se o embarque ja esta iniciado.
Static Function EmbqInic()
CB9->(DbSetOrder(5))
Return CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"3"))



Static Function MSCBFSem()
Local nC:= 0
__nSem168 := -1
While __nSem168  < 0
	__nSem168  := MSFCreate("V168"+cCodOpe+".sem")
	IF  __nSem168  < 0
		SLeep(50)
		nC++
		If nC == 3
			Return .f.
		EndIf
	Endif
End
FWrite(__nSem168,"Operador: "+cCodOpe+" Geracacao de NFS na Ordem de Separacao: "+cOrdSep) //###
Return .t.

Static Function MSCBASem()
If __nSem168 > 0
	Fclose(__nSem168)
	FErase("V168"+cCodOpe+".sem")
EndIf
Return 10
