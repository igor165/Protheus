 
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'


Static __nSem169 :=0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACDV169  ³ Autor ³ ACD                   ³ Data ³ 07/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Expedicao - Programa Principal - Impressao de NFS          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Function ACDV169()
Local aTela
Local nOpc
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If ACDGet170() 
	Return ACDV169X(0)
EndIf
aTela := VtSave()
VTCLear()                                                               
If lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VTSAY "Impressao de Nota"
	nOpc:=VTaChoice(2,0,3,VTMaxCol(),{"Ordem de Separacao","Nota Fiscal"})
ElseIf VtModelo()=="RF"
	@ 0,0 VTSAY "Impressao de Nota" 
	@ 1,0 VTSay 'Selecione:' 
	nOpc:=VTaChoice(3,0,6,VTMaxCol(),{"Ordem de Separacao","Nota Fiscal"})
ElseIf VtModelo()=="MT44" 
	@ 0,0 VTSAY "Impressao de Nota" 
	@ 1,0 VtSAY "Selecione:"
	nOpc:=VTaChoice(0,20,1,VTMaxCol(),{"Ordem de Separacao","Nota Fiscal"})
ElseIf VtModelo()=="MT16" 
	@ 0,0 VTSAY "Impressao de Nota" 
	nOpc:=VTaChoice(1,0,1,VTMaxCol(),{"Ordem de Separacao","Nota Fiscal"})
EndIf	
VtRestore(,,,,aTela)
If nOpc == 1 // por pre-separacao
	ACDV169A()
ElseIf nOpc == 2 // por Nota Fiscal
	ACDV169C()
EndIf
Return

Function ACDV169A()
ACDV169X(1)
Return

Function ACDV169C()
ACDV169X(3)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACDV169X ³ Autor ³ ACD                   ³ Data ³ 07/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Expedicao - Impressao de Notas Fiscais de Saida            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ACDV169X(nOpc)
Local   cPedido := Space(6)
Private cCodOpe := CBRetOpe()
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
If Type('cOrdSep')=='U'
	Private cOrdSep := Space(6)
EndIf    

__nSem169 :=0 // variavel static do fonte para controle de semaforo


If Empty(cCodOpe)
	VTAlert("Operador nao cadastrado","Aviso",.T.,4000) //###
	Return .F.
EndIf    

//Verifica se foi chamado pelo programa ACDV170 e se NFS ja foi impressa
If ACDGet170() .AND.CB7->CB7_STATUS >= "6"
	If !A170SLProc() .OR. !("04" $ CB7->CB7_TIPEXP)
   	Return 1 
   EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
	//³Ativa/Destativa a tecla avanca e retrocesa                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A170ATVKeys(.t.,.t.)	 //Ativa tecla avanca e retrocede   - Somente neste caso pois eh mensagem e nao tem estorno.
ElseIf ACDGet170() .AND. !("04" $ CB7->CB7_TIPEXP)         
	Return 1
ElseIf ACDGet170()      
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desativa a  tecla  avanca                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	A170ATVKeys(.f.,.t.)	
EndIf

VTClear()               
If VtModelo()=="RF" .or. lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VtSay "Impressao de Nota" 
EndIf	
If ! CBSolCB7(nOpc,{|| VldCodSep()})
   Return FimImpNFS(10)
EndIf                      

If ! ImpNota()
   Return FimImpNFS(10)
Endif				

Return FimImpNFS()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldCodSep³ Autor ³ ACD                   ³ Data ³ 07/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da Ordem de Separacao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldCodSep()
Local lPeNota:= ExistBlock(GetMV("MV_CBIXBNF")) // Ponto de Entrada para impressao da Nota

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

If !("04") $ CB7->CB7_TIPEXP
	VtAlert("Ordem de separacao nao configurada para Impresao de Nota","Aviso",.t.,4000,3) //###
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

If CB7->CB7_ORIGEM != "2"
	If CB7->CB7_STATUS < "5" .Or. CB7->CB7_ORIGEM == "2"
		VtAlert("Nao eh possivel imprimir Nota Fiscal!","Aviso",.t.,4000,3) //###
		VtAlert("Ordem de separacao nao possui Nota Fiscal gerada","Aviso",.t.,4000) //###
		VtKeyboard(Chr(20))  // zera o get
		Return .F.		
	Endif
Endif

If CB7->CB7_STATUS  == "7" .OR. CB7->CB7_STATUS  == "8"
	VtAlert("Ordem de separacao em processo de embarque","Aviso",.t.,4000,3) //###
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If CB7->CB7_STATUS == "9"
   VtAlert('Ordem de separacao encerrada','Atencao',.T.)  //###
   VtKeyboard(Chr(20))  // zera o get      
   Return .F.		
Endif

If CB7->CB7_STATUS # "0" .AND. CB7->CB7_STATPA == "1" .AND. CB7->CB7_CODOPE # cCodOpe  // SE ESTIVER EM SEPARACAO E PAUSADO SE DEVE VERIFICAR SE O OPERADOR E' O MESMO
   VtBeep(3)
   If !VTYesNo("Ordem de Separacao iniciada pelo operador "+CB7->CB7_CODOPE+". Deseja continuar ?","Aviso",.T.) //######
      VtKeyboard(Chr(20))  // zera o get
      Return .F.
   EndIf
ElseIf CB7->CB7_STATUS # "0" .AND. CB7->CB7_STATPA == " " .AND. CB7->CB7_STATUS # "2"  //Ordem Separacao ja esta em andamento...
   VtAlert("Ordem de Separacao ja esta em andamento por outro operador!","Aviso",.t.,4000,3) //###
   VtKeyboard(Chr(20))  // zera o get
   Return .F.
EndIf

If CB7->CB7_STATUS  == "6" 
   VtBeep(3)
	If !VTYesNo("NFS ja impressa para esta Ordem de separacao, deseja imprimir novamente ?","Aviso",.t.,4000) //###
	   VtKeyboard(Chr(20))  // zera o get
	   Return .F.
	Endif
Endif

If ! lPeNota
	VTAlert("Programa de impressao da NFS nao informado, verifique o parametro MV_CBIXBNF","Aviso",.T.,4000) //###
	Return .F.
EndIf
                         
If ! MSCBFSem() //fecha o semaforo, somente um separador por ordem de separacao
   VtAlert("Impressao de NFS ja esta em andamento...!","Aviso",.t.,4000,3) //###
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
±±³Fun‡ao    ³ ImpNota  ³ Autor ³ ACD                   ³ Data ³ 07/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressao da Nota Fiscal                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpNota()
VTClear()
If ! VTYesNo("Confirma a impressao da nota","Aviso",.t.) 	 //###
   RecLock("CB7")
   CB7->CB7_STATPA := "1"  // EM PAUSA
   CB7->(MsUnlock())
   Return .f.
EndIf

Vtmsg("Imprimindo Nota ...") //
ExecBlock(Alltrim(GETMV("MV_CBIXBNF")))

CB7->(RecLock('CB7',.f.))
CB7->CB7_NFEMIT :="1"
If "04" $ CBUltExp(CB7->CB7_TIPEXP)
	CB7->CB7_STATUS := "9"  // finalizou...	
	VTAlert('Processo de expedicao finalizado','Aviso',.t.,4000)  //###
Else
	CB7->CB7_STATUS := "6"  // imprimiu nota fiscal
	CB7->CB7_STATPA := "1"  // Pausa
	VTAlert("Nota Fiscal Impressa com sucesso","Aviso",.t.,4000)  //###
EndIf
CB7->(MsUnlock())
CBLogExp(cOrdSep)
Return .t.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FimImpNFS  ³ Autor ³ ACD                 ³ Data ³ 07/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Finalisa o processo de Impressao de NFS                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/              
Static Function FimImpNFS(nSai)
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
__nSem169 := -1
While __nSem169  < 0
   __nSem169  := MSFCreate("V169"+cCodOpe+".sem") 
   IF  __nSem169  < 0                  
     SLeep(50)             
     nC++
     If nC == 3
		  Return .f.
	  EndIf                      
  Endif
End              
FWrite(__nSem169,"Operador: "+cCodOpe+" Impressao de NFS na Ordem de Separacao: "+cOrdSep) //###
Return .t.

Static Function MSCBASem()
If __nSem169 > 0
  Fclose(__nSem169)
  FErase("V169"+cCodOpe+".sem")
EndIf  
Return 10
