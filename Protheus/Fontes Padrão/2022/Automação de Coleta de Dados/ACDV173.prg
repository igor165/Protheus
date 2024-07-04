 
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'


Static __nSem173 :=0
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ acdv173  ³ Autor ³ ACD                   ³ Data ³ 08/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Expedicao - Impressao das etiquetas oficiais de volume     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Template function ACDV173(uPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)
Return ACDV173(uPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)

Function ACDV173()
Local aTela
Local nOpc

If ACDGet170() 
	Return ACDV173X(0)
EndIf
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
aTela := VtSave()
VTCLear()                       
	If lVT100B // GetMv("MV_RF4X20")
		@ 0,0 VTSAY "Impr.Etiq.Vol."
		nOpc:=VTaChoice(2,0,3,VTMaxCol(),{"Ordem de Separacao","Pedido de Venda"})
	ElseIf VtModelo()=="RF"
	@ 0,0 VTSAY "Impressao das Etiq."
	@ 1,0 VTSay 'Oficiais de volume' 
	@ 3,0 VTSay 'Selecione:' 
	nOpc:=VTaChoice(3,0,4,VTMaxCol(),{"Ordem de Separacao","Pedido de Venda"})
ElseIf VtModelo()=="MT44" 
	@ 0,0 VTSAY "Impr.Etiq.Vol." 
	@ 1,0 VtSAY "Selecione:"
	nOpc:=VTaChoice(0,20,1,VTMaxCol(),{"Ordem de Separacao","Pedido de Venda"}) 
ElseIf VtModelo()=="MT16" 
	@ 0,0 VTSAY "Impr.Etiq.Vol."
	nOpc:=VTaChoice(1,0,1,VTMaxCol(),{"Ordem de Separacao","Pedido de Venda"}) 
EndIf	
VtRestore(,,,,aTela)
If nOpc == 1 // por ordem de separacao
	ACDV173A()
ElseIf nOpc == 2 // por pedido de venda
	ACDV173B()
EndIf
Return
                
Template function ACDV173A(uPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)
Return ACDV173A(uPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)
Template function ACDV173B(uPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)
Return ACDV173B(uPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)

Function ACDV173A()
ACDV173X(1)
Return
Function ACDV173B()
ACDV173X(2)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACDV173X ³ Autor ³ ACD                   ³ Data ³ 08/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Expedicao - Impressao das etiquetas oficiais de volume     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ACDV173X(nOpc)
Local   cPedido := Space(6)
Private cCodOpe := CBRetOpe()
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
If Type('cOrdSep')=='U'
	Private cOrdSep := Space(6)
EndIf    
                
__nSem173 :=0 // variavel static do fonte para controle de semaforo

If Empty(cCodOpe)
	VTAlert("Operador nao cadastrado","Aviso",.T.,4000) //###
	Return .F.
EndIf

//Verifica se foi chamado pelo programa ACDV170 e se ja foi impressa as
//etiquetas oficiais de volume
If ACDGet170() .AND.CB7->CB7_STATUS >= "7"
	If !A170SLProc() .OR. !("05" $ CB7->CB7_TIPEXP)
   	Return 1 
   EndIf                   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
	//³Ativa/Destativa a tecla avanca e retrocesa                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A170ATVKeys(.t.,.t.)	 //Ativa tecla avanca e retrocede  - Somente neste caso pois eh uma pergunta
ElseIf ACDGet170() .AND. !("05" $ CB7->CB7_TIPEXP)
	Return 1
ElseIf ACDGet170()             
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desativa a  tecla  avanca                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	A170ATVKeys(.f.,.t.)	
EndIf


VTClear()               
If VtModelo()=="RF" .or. lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VTSAY "Impressao das Etiq." //
	@ 1,0 VTSay 'Oficiais de volume' //
EndIf	
If ! CBSolCB7(nOpc,{|| VldCodSep()})
	Return FimImpEtiV(10) 
EndIf                      
If ! ImpVolume()
   Return FimImpEtiV(10)
Endif				
Return FimImpEtiV()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldCodSep³ Autor ³ ACD                   ³ Data ³ 08/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da Ordem de Separacao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldCodSep()
Local lPeVolume:= ExistBlock('IMG05OFI')
Local nOpc	   := 0
Local aItChoice:= {"Imprimir","Estornar","Cancelar"} // "Imprimir" ## "Estornar" ## "Cancelar"
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If Empty(cOrdSep)
   VtKeyBoard(chr(23))
   Return .f.
EndIf

CB7->(DbSetOrder(1))
CB7->(DbSeek(xFilial("CB7")+cOrdSep))

// --> Atencao nao alterar a sequencia das validacoes.

If CB7->(Eof())
	VtAlert("Ordem de separacao nao encontrada.","Aviso",.t.,4000,3) //###
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If !("05") $ CB7->CB7_TIPEXP
	VtAlert("Ordem de separacao nao configurada para Impresao de Volumes Oficias","Aviso",.t.,4000,3) //###
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If CB7->CB7_STATUS == "0" .OR. CB7->CB7_STATUS == "1"
	VtAlert("Ordem de separacao possui itens nao separados","Aviso",.t.,4000,3) //###
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
Endif

If "02" $ CB7->CB7_TIPEXP .and. (CB7->CB7_STATUS == "2" .OR. CB7->CB7_STATUS == "3")
	VtAlert("Ordem de separacao possui itens nao embalados","Aviso",.t.,4000,3) //###
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If "03" $ CB7->CB7_TIPEXP .and. Empty(CB7->(CB7_NOTA+CB7_SERIE))//(CB7->CB7_STATUS  # "5")
	VtAlert("Nota nao gerada para esta Ordem de separacao","Aviso",.t.,4000,3) //###
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif
 
If !ACDGet170() .and. "04" $ CB7->CB7_TIPEXP .and. (CB7->CB7_STATUS  # "6")
	VtAlert("Nota nao impressa para esta Ordem de separacao","Aviso",.t.,4000,3) //###
	VtKeyboard(Chr(20))  // zera o get
	Return .F.	
EndIf

If CB7->CB7_STATUS  == "8"
	VtAlert("Ordem de separacao em processo de embarque","Aviso",.t.,4000,3) //###
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If CB7->CB7_STATUS == "9" .And. !("05" $ CBUltExp(CB7->CB7_TIPEXP))
   VtAlert('Ordem de separacao encerrada','Atencao',.T.)  //###
   VtKeyboard(Chr(20))  // zera o get      
   Return .F.		
Endif

If CB7->CB7_STATUS # "0" .AND. CB7->CB7_STATPA == "1" .AND. CB7->CB7_CODOPE # cCodOpe  // SE ESTIVER EM SEPARACAO E PAUSADO SE DEVE VERIFICAR SE O OPERADOR E' O MESMO
   VtBeep(3)
   If !VTYesNo("Ordem Separacao iniciada pelo operador "+CB7->CB7_CODOPE+". Deseja continuar ?","Aviso",.T.) //######
      VtKeyboard(Chr(20))  // zera o get
      Return .F.
   EndIf
EndIf

If CB7->CB7_STATUS  == "7" .Or. (CB7->CB7_STATUS == "9" .And. ("05" $ CBUltExp(CB7->CB7_TIPEXP)))
	aTela := VtSave()
	VTCLear()
	If lVT100B // GetMv("MV_RF4X20")
		@ 0,0 VTSAY "Etiq.Ofic.Impressas "	// "Etiq.Ofic.Impressas "
		nOpc:=VTaChoice(2,0,3,VTMaxCol(),aItChoice)
	ElseIf Vtmodelo()=="RF"
		@ 0,0 VTSAY "Etiq.Ofic.Impressas "	// "Etiq.Ofic.Impressas "
		@ 1,0 VTSay "Selecione: "			// "Selecione:"
		nOpc:=VTaChoice(3,0,6,VTMaxCol(),aItChoice)
	ElseIf VtModelo()=="MT44"
		@ 0,0 VTSAY "Etiq.Ofic.Impressas "	// "Etiq.Ofic.Impressas "
		@ 1,0 VTSay "Selecione: "			// "Selecione:"
		nOpc:=VTaChoice(0,20,1,39,aItChoice)
	ElseIf VtModelo()=="MT16"
		@ 0,0 VTSAY "Etiq.Ofic.Impressas "+"Selecione: " // "Etiq.Ofic.Impressas " ## "Selecione:"
		nOpc:=VTaChoice(1,0,1,19,aItChoice)
	EndIf
	VtRestore(,,,,aTela)

	If nOpc == 2 // Estorna
		// Atualiza o status da separacao para a etapa anterior
		RecLock("CB7",.F.)
		CB7->CB7_STATUS := CBAntProc(CB7->CB7_TIPEXP,"05*")
		CB7->(MsUnLock())

		// Reabre os volumes da separacao
		CB9->(DbSetOrder(1))
		CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
		While CB9->(!Eof() .AND. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+CB7->CB7_ORDSEP)
			If !Empty(CB9->CB9_VOLUME) .And. CB6->(DbSeek(xFilial("CB6")+CB9->CB9_VOLUME))
				RecLock("CB6",.F.)
				CB6->CB6_STATUS := "1" // Aberto
				CB6->(MsUnlock())
			EndIf
			CB9->(DbSkip())
		EndDo

		VtKeyboard(Chr(20)) // Zera o Get
		Return .F.
	ElseIf nOpc == 3
		VtKeyboard(Chr(20)) // Zera o Get
		Return .F.
	EndIf
Endif

If ! lPeVolume
	VTAlert("Programa para impressao das etiquetas oficiais de volume nao existe, verifique !!!","Aviso",.T.,4000) //###
	Return .F.
EndIf
                         
If ! MSCBFSem() //fecha o semaforo, somente um separador por ordem de separacao
   VtAlert("Impressao de volumes ja esta em andamento por outro operador...!","Aviso",.t.,4000,3) //###
   VtKeyboard(Chr(20))  // zera o get
   Return .F.
EndIf             

RecLock("CB7",.f.) //
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
±±³Fun‡ao    ³ ImpVolume³ Autor ³ ACD                   ³ Data ³ 08/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera Etiquetas Oficiais de Volumes e/ou SubVolumes         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpVolume()
Local aArea   := sGetArea()
Local nX      := 0
Local aVolume := {}
Local cImp    := CBRLocImp("MV_IACD01")
Local _cStatus := CB7->CB7_STATUS
Local lACD173CF := ExistBlock("ACD173CF")

If lACD173CF
   If !Execblock("ACD173CF",.F.,.F.)
      Return .f.
   Endif
Endif

If ! VTYesNo("Confirma a impressao de etiquetas oficiais de volume","Aviso",.t.)  //###
	_cStatus :=  CBAntProc(CB7->CB7_TIPEXP,"05*")
   RecLock("CB7")
   CB7->CB7_STATPA := "1"  // EM PAUSA
   CB7->CB7_STATUS := _cStatus
   CB7->(MsUnlock())
   Return .f.
EndIf

VTMsg('Imprimindo ...')  //
aArea := sGetArea(aArea,"CB6")
CB5SetImp(cImp,.T.)
CB9->(DbSetOrder(1))
CB9->(DBSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
While CB9->(!Eof() .and. xFilial("CB7")+CB7->CB7_ORDSEP == CB9_FILIAL+CB9_ORDSEP)
	If ascan(aVolume,CB9->CB9_VOLUME) ==0
		aadd(aVolume,CB9->CB9_VOLUME)
	EndIf
	CB9->(DbSkip())
EndDo
For nX := 1 to len(aVolume)
	CB6->(DBSetOrder(1))
	CB6->(DBSeek(xFilial("CB6")+aVolume[nX]))
	ExecBlock("IMG05OFI",,,{len(aVolume),nX})
	RecLock("CB6",.F.)
	CB6->CB6_STATUS := "3" // Encerrado
	CB6->(MsUnlock())
Next
MSCBCLOSEPRINTER()
sRestArea(aArea)
CB7->(RecLock('CB7',.F.))
CB7->CB7_VOLEMI :="1"
If "05" $ CBUltExp(CB7->CB7_TIPEXP)
	CB7->CB7_STATUS := "9"  // finalizou...	
	VTAlert('Processo de expedicao finalizado','Aviso',.t.,4000)  //###
Else
	CB7->CB7_STATUS := "7"  // imprimiu volume
	CB7->CB7_STATPA := "1"  // Pausa
	VTAlert("Etiquetas impressas com sucesso","Aviso",.t.,4000)  //###
EndIf
CB7->(MsUnlock())
CBLogExp(cOrdSep)
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FimImpEtiV ³ Autor ³ ACD                 ³ Data ³ 07/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Finalisa o processo de Impressao de NFS                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/              
Static Function FimImpEtiV(nSai)
Default nSai := 1       

MSCBASem() // valor necessario para finalizar o acv170 e liberar o semaforo

//Verifica se esta sendo chamado pelo ACDV170 e se existe um avanco 
//ou retrocesso forcado pelo operador
If ACDGet170() .AND. A170AvOrRet() 
 	nSai := A170ChkRet()         
EndIf
Return nSai



Static Function MSCBFSem()
Local nC:= 0
__nSem173 := -1
While __nSem173  < 0
   __nSem173  := MSFCreate("V173"+cCodOpe+".sem") 
   IF  __nSem173  < 0                  
     SLeep(50)             
     nC++
     If nC == 3
		  Return .f.
	  EndIf                      
  Endif
End              
FWrite(__nSem173,"Operador: "+cCodOpe+" Impr. de Volumes na Ordem de Separacao: "+cOrdSep) //###
Return .t.

Static Function MSCBASem()
If __nSem173 > 0
  Fclose(__nSem173)
  FErase("V173"+cCodOpe+".sem")
EndIf  
Return 10
