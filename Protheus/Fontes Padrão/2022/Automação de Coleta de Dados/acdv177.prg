#INCLUDE 'PROTHEUS.CH'  
#INCLUDE 'APVT100.CH'
#INCLUDE 'ACDV177.CH'

Function ACDV177()
Local aTela
Local nOpc    
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf  

aTela := VtSave()
VTCLear()
If lVT100B //GetMv("MV_RF4X20")
	@ 0,0 VTSAY STR0001 + " " + STR0002 //"Expedicao" + "Selecione:"
	nOpc:=VTaChoice(2,0,3,VTMaxCol(),{STR0003,STR0004,STR0005,STR0006}) //"Ordem de Separacao","Pedido de Venda","Nota Fiscal","Ordem Producao"
ElseIf VtModelo() =="RF"
	@ 0,0 VTSAY STR0001 //"Expedicao" 
	@ 1,0 VTSay STR0002 //'Selecione:'
	nOpc:=VTaChoice(3,0,6,VTMaxCol(),{STR0003,STR0004,STR0005,STR0006}) //"Ordem de Separacao","Pedido de Venda","Nota Fiscal","Ordem Producao"
ElseIf VtModelo()=="MT44"
	@ 0,0 VTSAY STR0001 //"Expedicao" 
	@ 1,0 VTSay STR0002 //'Selecione:'
	nOpc:=VTaChoice(0,20,1,39,{STR0003,STR0004,STR0005,STR0006}) //"Ordem de Separacao","Pedido de Venda","Nota Fiscal","Ordem Producao"
ElseIf VtModelo()=="MT16"
	@ 0,0 VTSAY STR0001 + STR0002
	nOpc:=VTaChoice(1,0,1,19,{STR0003,STR0004,STR0005,STR0006}) //"Ordem de Separacao","Pedido de Venda","Nota Fiscal","Ordem Producao"
EndIf	
VtRestore(,,,,aTela)
If nOpc == 1 // por ordem de separacao
	ACDV177A()  
ElseIf nOpc == 2 // por pedido de venda
	ACDV177B()
ElseIf nOpc == 3 // por Nota Fiscal 
	ACDV177C()
ElseIf nOpc == 4 // por Ordem de producao
	ACDV177D()		
EndIf   
Return NIL
           
Function ACDV177A()
ACDV177X(1)
Return NIL

Function ACDV177B()
ACDV177X(2)
Return NIL

Function ACDV177C()
ACDV177X(3)
Return NIL

Function ACDV177D()
ACDV177X(4)
Return NIL

Static Function ACDV177X(nOpc)  
Local nI,nPos
Local cRotScript  := ""        
Local cRoteiro    := GetNewPar("MV_ROTV170","01*02*03*04*05*06*")
Private aProc	  := {	{"01",STR0007,"ACDV166"	,"2",.T.},; //"Separacao"
					 	{"02",STR0008,"ACDV167"	,"4",.T.},; //"Embalagem"	
					 	{"03",STR0009,"ACDV168"	,"5",.T.},; //"Geracao Nfs"
					 	{"04",STR0010,"ACDV169"	,"6",.T.},; //"Impressao de Nfs"	
					 	{"05",STR0011,"ACDV173"	,"7",.T.},; //"Impr.Etiq. Oficiais de Volumes"
					 	{"06",STR0012,"ACDV175"	,""	,.T.}} //"Embarque"    
							 	
Private nProcesso   := 1       
Private cOrdSep     := Space(TamSX3("CB7_ORDSEP")[1])
Private cUltProc
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If Empty(cRoteiro)
   cRoteiro      := "01*02*03*04*05*06*"
EndIf

cUltProc :=StrTran(CBUltExp(cRoteiro),"*","")

VTClear()
If VTModelo()=="RF" .or. lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VtSay STR0001 // "Expedicao" 
EndIf	
If ! CBSolCB7(nOpc,{|| VldCodSep()})
   Return
EndIf     
  
//Desativar processo da expressao da ordem de separacao  
cRotScript := StrTran(CB7->CB7_TIPEXP,"00*","01*")   
For nI:=1 To Len(aProc)
	If !aProc[nI,1] $ cRotScript
		aProc[nI,5] := .F.
	EndIf
Next                                              

//Inciando processo para evitar problemas na primeira execucao
For nI:=1 To Len(aProc)
	If aProc[nI,5]
		//Verifica se o processo esta ligado ou nao
		If !IsFimLig(nI)  
			Return
		EndIf
		nProcesso := Val(aProc[nI,1])
		Exit
	EndIf
Next              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sempre seta as teclas de avanco e retorno, pois dentro de alguns      ³
//³processos, estas teclas sao desativadas.(Exemplo: ACDV166, o retroceso³
//³eh desativado)                                                        ³	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
VtSetKey(5,{|| A170Retrocede() },STR0013) //Retrocede
VtSetKey(6,{|| A170Avanca() },STR0014) //Avança

ACDSet170(.t.)                                    
While .t.                    
	If !IsFimLig(nProcesso)
		Exit
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa processos conforme o step                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
   If nProcesso ==1      //Separacao                    
	   nProcesso += GetRealProc(ACDV166(),nProcesso,aProc)
   ElseIf nProcesso ==2  //Embalagem 
	   nProcesso += GetRealProc(ACDV167(),nProcesso,aProc)
   ElseIf nProcesso ==3  //Gera NF  
	   nProcesso += GetRealProc(ACDV168(),nProcesso,aProc)
   ElseIf nProcesso ==4  //Imprime NF
	   nProcesso += GetRealProc(ACDV169(),nProcesso,aProc)
   ElseIf nProcesso ==5  //Imprime Etiq. volumes oficiais
	   nProcesso += GetRealProc(ACDV173(),nProcesso,aProc)
   ElseIf nProcesso ==6  //Embarque
	   nProcesso += GetRealProc(ACDV175(),nProcesso,aProc)
   ElseIf nProcesso >=7  //Fimm
   	If CB7->CB7_STATUS=="9"
			VtAlert(STR0015,STR0016,.t.,3000)   	 //"Expedicao finalizado com sucesso!","FIM"###
   	Else
	      VtAlert(STR0018,STR0017,.t.,3000) //###"Expedicao com status de andamento","Aviso"
	   EndIf
      Exit
 	EndIf                 
End
ACDSet170(.f.)
Return                         


///*******************************funcoes para serem colocados no acdxfun**********************************

Static _lA170 := .f.
STATIC __lAvanca   := .F.
STATIC __lRetrocede:= .F.
STATIC __lPulaProc := .F.
STATIC __lAtvAvanca:= .F.
STATIC __lAtvRetroc:= .F.

Function ACDGet170()
Return _lA170

Function ACDSet170(lvar)
default lvar:= .f.
_lA170:=lvar
Return 
               
Function A170Avanca()
If !__lAtvAvanca
	Return
EndIf
__lAvanca   := .T.
__lRetrocede:= .F.
Return VtKeyBoard(CHR(27)) //VtKeyBoard("#VAI#"+CHR(13))

Function A170Retrocede()
If !__lAtvRetroc
	Return
EndIf
__lAvanca   := .F.
__lRetrocede:= .T.
Return VtKeyBoard(CHR(27))//VtKeyBoard("#VOLTA#"+CHR(13))                        


//Verifica se existe salto de processo        
Function A170SLProc()                
Return __lPulaProc

Function A170SetProc(lVar)
Default lVar := .f.
__lPulaProc := lVar
Return

Function A170ChkRet(nRetorno)   
Default nRetorno := 0
If __lAvanca
	nRetorno := 1
ElseIf __lRetrocede                                	
	nRetorno := -1
EndIf        
__lAvanca    := .F.
__lRetrocede := .F.
//Ativa Salto
A170SetProc(.T.)
VtKeyBoard(CHR(20))
VTInkey()
Return nRetorno        
       
//Verifica se possui um Avanco ou Retrocesso
Function A170AvOrRet()  
Return __lAvanca .or. __lRetrocede
               
Function A170ATVKeys(lAvanca,lRetrocede)
Default lAvanca   := .f.
Default lRetrocede:= .f.

 __lAtvAvanca:= lAvanca
 __lAtvRetroc:= lRetrocede
Return

Function CBSolCB7(nOpc,bBlcVld)
Local cPedido,cNota,cSerie,cOP
Local aTela:= VtSave()
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
If nOpc == 0
   Return Eval(bBlcVld)
ElseIf nOpc ==1  // por codigo da Ordem de Separacao
   cOrdSep := Space(TamSX3("CB7_ORDSEP")[1])       
	@ If(VTModelo()=="RF" .or. lVT100B /*GetMv("MV_RF4X20")*/,2,0),0 VTSay STR0019  //"Informe o codigo:"
	@ If(VTModelo()=="RF" .or. lVT100B /*GetMv("MV_RF4X20")*/,3,1),0 VTGet cOrdSep PICT "@!" F3 "CB7"  Valid Eval(bBlcVld)
	VTRead                                                                        		
ElseIf nOpc ==2 // por pedido
	cPedido := Space(TamSX3("C6_NUM")[1])
	@ If(VTModelo()=="RF" .or. lVT100B /*GetMv("MV_RF4X20")*/,2,0),0 VTSay STR0020  //"Informe o Pedido"
	@ If(VTModelo()=="RF" .or. lVT100B /*GetMv("MV_RF4X20")*/,3,1),0 VTSay STR0021 VTGet cPedido PICT "@!"  F3 "CBL"  Valid (VldGet(cPedido) .and. CBSelCB7(1,cPedido) .and. Eval(bBlcVld))//'de venda: '
	VTRead                                                                        		
ElseIf nOpc ==3 // por Nota fiscal    
   cNota  := Space(TamSx3("F2_DOC")[1])
   cSerie := Space(SerieNfId("SF1",6,"F2_SERIE"))
	@ If(VTModelo()=="RF" .or. lVT100B /*GetMv("MV_RF4X20")*/,2,0),00 VTSay STR0022 //"Informe a NFS"
	@ If(VTModelo()=="RF" .or. lVT100B /*GetMv("MV_RF4X20")*/,3,1),00 VTSAY  STR0023 VTGet cNota   pict '@S<20>' F3 "CBM"  Valid VldGet(cNota) //"Nota"
	@ If(VTModelo()=="RF" .or. lVT100B /*GetMv("MV_RF4X20")*/,3,1),14 VTSAY '-' VTGet cSerie  pict '@!'   	  Valid Empty(cSerie) .or. CBSelCB7(2,cNota+cSerie,.T.,cNota,cSerie) .and. Eval(bBlcVld)
	VTRead                                                                        	   
ElseIf nOpc ==4 // por OP
   cOP:= Space(13)      
	If lVT100B // GetMv("MV_RF4X20")
		@ 1,0 VTSay STR0024
		@ 2,0 VTSay STR0025
	ElseIf VTModelo()=="RF"
	   @ 2,0 VTSay STR0024
		@ 3,0 VTSay STR0025
	Else 
	   @ 0,0 VTSay STR0026
	EndIf	
	@ IIf(lVT100B /*GetMv("MV_RF4X20")*/,3,If(VTModelo()=="RF",4,1)),0 VTGet cOP Pict "@!" F3 "SC2" Valid (VldGet(cOp) .and. CBSelCB7(3,cOP) .and. Eval(bBlcVld) )
	VTRead                                                                        		
EndIf     
VTRestore(,,,,aTela)
If VTLastKey() == 27
 	Return .f.
EndIf
Return .t.


//Verifica se o conteudo da variavel esta em branco, caso esteja chama consulta F3 da mesma
Static Function VldGet(cVar)
If Empty(cVar)
	VtKeyBoard(chr(23))
	Return .F.
EndIf

Return .T.



/*
nModo 
1=Pedido
2=Nota Fiscal Saida
3=OP
*/

Function CBSelCB7(nModo,cChave,lSerie,cNota,cSerie)
Local aOrdSep:={}   
Local aCab
Local aSize
Local nPos                  
Local aTela                   

Default lSerie := .F.

DbSelectArea("CB7")
CB7->(DbSetOrder(1))
DbSelectArea("CB8")

If lSerie
	CBMULTDOC("SF2",cNota,@cSerie)
EndIf

If nModo == 1 // pedido
	CB8->(DbSetOrder(2)) 
	CB8->(DbSeek(xFilial("CB8")+cChave))
	bBlock:={|| CB8->(CB8_FILIAL+CB8_PEDIDO) == xFilial("CB8")+cChave}
ElseIf nModo == 2
	CB8->(DbSetOrder(5)) 
	CB8->(DbSeek(xFilial("CB8")+cChave))
	bBlock:={|| CB8->(CB8_FILIAL+CB8_NOTA+CB8_SERIE) == xFilial("CB8")+cNota+cSerie}
	If CB8->(!Found())
		CB7->(DbSetOrder(4)) 
		If CB7->(DbSeek(xFilial("CB7")+cChave))
			cChave := CB7->CB7_ORDSEP
			CB8->(DbSetOrder(1))
			If CB8->(DbSeek(xFilial("CB8")+cChave))
				bBlock:={|| CB8->(CB8_FILIAL+CB8_ORDSEP) == xFilial("CB8")+cChave}
			EndIf
		EndIf
	EndIf
ElseIf nModo == 3
	CB8->(DbSetOrder(6)) 
	CB8->(DbSeek(xFilial("CB8")+cChave))
	bBlock:={|| CB8->(CB8_FILIAL+AllTrim(CB8_OP)) == xFilial("CB8")+AllTrim(cChave)}
EndIf      			
While ! CB8->(Eof()) .and. eval(bBlock)
    If CB8->CB8_TIPSEP=='1' // PRE-SEPARACAO
       CB8->(DbSkip())
       Loop 
    EndIf
   If nModo==1
	   If Ascan(aOrdSep,{|x| x[1]+x[3] == CB8->(CB8_ORDSEP+CB8_PEDIDO)}) == 0
	      CB8->(aadd(aOrdSep,{CB8_ORDSEP,CB8_LOCAL,CB8_PEDIDO,CB7->CB7_CODOPE}))						  
	   EndIf   
	ElseIf nModo==2
	   If Ascan(aOrdSep,{|x| x[1]+x[3]+x[4] == CB8->(CB8_ORDSEP+CB8_NOTA+CB8_SERIE)}) == 0
	      CB8->(aadd(aOrdSep,{CB8_ORDSEP,CB8_LOCAL,CB8_NOTA,CB8_SERIE,CB7->CB7_CODOPE}))						  
	   EndIf   
	ElseIf nModo==3
	   If Ascan(aOrdSep,{|x| x[1]+x[3] == CB8->(CB8_ORDSEP+CB8_OP)}) == 0
	      CB8->(aadd(aOrdSep,{CB8_ORDSEP,CB8_LOCAL,CB8_OP,CB7->CB7_CODOPE}))						  
	   EndIf   
	EndIf			   
   CB8->(DbSkip())
Enddo

If Empty(aOrdSep)
	VtAlert(STR0042,STR0017,.t.,4000,3)  //### "Ordem de separação não encontrada","Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

aOrdSep := aSort(aOrdSep,,,{|x,y| x[1] < y[1]})
If len(aOrdSep) == 1 .and. ! Empty(cChave)
   cOrdSep:= aOrdSep[1,1]
   Return .T.
EndIf      
aTela := VTSave()   
VtClear   
If nModo ==1 
	acab :={STR0028,STR0029,STR0030,STR0031} //"Ord.Sep","Arm","PEDIDO","Operador"
	aSize   := {7,3,7,6}                                  	
ElseIf nModo==2
	acab :={STR0028,STR0029,STR0035,STR0032,STR0031} //"Ord.Sep","Arm","Nota","Serie","Operador"
	aSize   := {7,3,6,4,6}                                  	
ElseIf nModo==3
	acab :={STR0028,STR0029,STR0034,STR0031} //"Ord.Sep","Arm","O.P.","Operador"
	aSize   := {7,3,13,6}                                  	
EndIF	

nPos := 1
npos := VTaBrowse(,,,,aCab,aOrdSep,aSize,,nPos)
VtRestore(,,,,aTela)
If VtLastkey() == 27                 
	VtKeyboard(Chr(20))  // zera o get
   Return .f.
EndIf    
cOrdSep:=aOrdSep[nPos,1]                  
VtKeyboard(Chr(13))  // zera o get
Return .T.              



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CBUltExp ³ Autor ³ Anderson Rodrigues    ³ Data ³ 02/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Ordena a String que contem a configuracao da expedicao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD															        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CBUltExp(cString)
Local cRetorno:= ""
Local nX      := 0
Local aTipExp := {}  
cString := Alltrim(cString)
cString := StrTran(cString,"08*","")
cString := StrTran(cString,"10*","")
cString := StrTran(cString,"11*","")

For nX:= 1 to Len(cString) Step 3
   aadd(aTipExp,{Substr(cString,nX,3)})
Next
aTipExp := aSort(aTipExp,,,{|x,y| x[1] < y[1]})
For nX:= 1 to Len(aTipExp)
   cRetorno+= aTipExp[nX,1]
Next         
cRetorno:= Right(cRetorno,3)
Return cRetorno  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CBAntProc³ Autor ³ ACD                   ³ Data ³ 10/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status do processo anterior                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD															        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CBAntProc(cString,cProc)
Local cRetorno:= cProc
Local nX      := 0
Local aTipExp := {}  
Local nPos    := 0               
Local aAux    := 	{	{"00*",STR0036},;//"2-Separacao finalizada"
					  	{"01*",STR0036},;//"2-Separacao finalizada"
						{"02*",STR0037},;//"4-Embalagem finalizada"
						{"03*",STR0038},;//"5-Geracao de nota"
						{"04*",STR0039},;//"6-Impressao de nota"
						{"05*",STR0040},;//"7-Impressao de volumes"
						{"06*",STR0041}}//"8-Embarcado"

cString := Alltrim(cString)
cString := StrTran(cString,"08*","")
cString := StrTran(cString,"10*","")
cString := StrTran(cString,"11*","")      

For nX:= 1 to Len(cString) Step 3
   aadd(aTipExp,Substr(cString,nX,3))
Next
aTipExp := aSort(aTipExp,,,{|x,y| x < y })
nPos := ascan(aTipExp,cProc)
If nPos > 1
	cRetorno := aTipExp[nPos-1]
EndIf     
nPos:= Ascan(aAux,{|x| x[1] == cRetorno })
Return Left(aAux[nPos,2],1)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldCodSep³ Autor ³ ACD                   ³ Data ³ 25/01/05 ³±±
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
	VtAlert(STR0042,STR0017,.t.,4000,3) //###"Ordem de separação não encontrada.", "Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³GetRealProc³ Autor ³ERIKE YURI DA SILVA    ³ Data ³ 07/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a checagem da lista de processos ativos para navegar³±±
±±³          ³ corretamente.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                         	                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/              
Static Function GetRealProc(nAcao,nProcAtu,aProc)
Local nRet := nAcao
Local nI

If nAcao==1			//Avancando
	nProcAtu++
	For nI:= nProcAtu To Len(aProc)
	    If aProc[nI,5]
	    	nRet := nAcao   
			Exit
	    EndIf  
	    nAcao++
	Next
ElseIf nAcao==-1	//Retrocedento
	nProcAtu--
	For nI:= nProcAtu To 1 Step(-1)
	    If aProc[nI,5]
	    	nRet := nAcao
		    Exit
	    EndIf  
	    nAcao--
	Next
EndIf
Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³GetRealSts ³ Autor ³ERIKE YURI DA SILVA    ³ Data ³ 07/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a checagem da lista de processos ativos retornando o³±±
±±³          ³ status corretamente.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                         	                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/              
Function GetRealSts(nAcao,nProcAtu,aProc)
Local nRet := nAcao
Local nI        

If nAcao==1			//Avancando
	nProcAtu++
	For nI:= nProcAtu To Len(aProc)
	    If aProc[nI,5]
	    	 nRet := nAcao   
	       Exit
	    EndIf  
	    nAcao++
	Next
ElseIf nAcao==-1	//Retrocedento
	nProcAtu--
	For nI:= nProcAtu To 1 Step(-1)
	    If aProc[nI,5]
	    	 nRet := nAcao
	       Exit
	    EndIf  
	    nAcao--
	Next
EndIf
Return nRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³IsFimLig   ³ Autor ³ERIKE YURI DA SILVA    ³ Data ³ 13/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Analise se o processo atual eh maior que o ultimo processo  ³±±
±±³          ³ permitido para execucao ligada a partir do parametro        ³±±
±±³          ³ MV_ROTV170.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                         	                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/              
Static Function IsFimLig(nProcAtu)
//Local nPos
Local cProc                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o processo a ser executado esta ligado ou nao no parametro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
cProc := StrZero(nProcAtu,2)

If nProcAtu < 7 .AND. cProc > cUltProc
//	nPos := AsCan(aProc,{|x| x[1]==cUltProc})
	If cProc $ CB7->CB7_TIPEXP //.AND. aProc[nPos,4] > CB7->CB7_STATUS
		VTAlert(STR0043 +aProc[nProcAtu,2]+ STR0044,STR0017,.t.)//"A partir do processo " ##" as rotinas nao estao ligadas no Acdv170, eh necessario executar os programas do menu." ##"Aviso"
			Return .F.  					
	EndIf
EndIf             
Return .T.
