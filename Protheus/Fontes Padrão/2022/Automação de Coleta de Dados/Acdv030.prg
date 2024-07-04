#INCLUDE "Acdv030.ch" 
#include "protheus.ch"
#include "apvt100.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ACDV030  ³ Autor ³ ACD                   ³ Data ³ 04/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa principal do VT100 para o inventario              ³±±
±±³          ³ Cadastro de Mestre de inventario                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACD                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template function ACDV030()
Return ACDV030()

Function ACDV030()
Local nCont := 2        
Local cEtiqueta
Local lLocaliz := GetMV("MV_LOCALIZ")=="S"
Private cArmazem 
Private cArmazem2 
Private cProduto     
Private cEtiEAN                        
Private cEndereco                                  
Private dDtInv
Private cTipInv  
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
     

If ! SuperGetMV("MV_CBPE012",.F.,.F.)
	CBAlert(STR0018) //"Necessario ativar o parametro MV_CBPE012"
	Return .F.
EndIf

While .t.
	cArmazem := Space(Tamsx3("B1_LOCPAD")[1])
	cArmazem2:= Space(Tamsx3("B1_LOCPAD")[1])
	cEndereco:= Space(15)
	cTipInv  := Space(01)
	cProduto := Space(Tamsx3("B1_COD")[1])        
	cEtiqueta:= IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
	dDtInv   := dDatabase                  
	nCont    := 2
   VTClear()
   @ 0,0 VTSay STR0001 //"Mestre de Inventario"
	@ 1,0 VTSay STR0002 VTGet cArmazem  Pict "@!" Valid ! Empty(cArmazem) //"Armazem"
	@ 2,0 VTSay STR0003 VTGet dDtInv Valid  dDtInv >= dDatabase //"Data   "
	VtRead
	If VTLastkey() == 27
	   Exit
	EndIf	   
	If lVT100B
		VTClear
		If ! lLocaliz
			If UsaCB0("01")
				@ 0,0 VTSay STR0004 //"Etiqueta Produto"
				@ 1,0 VTGet cEtiqueta Valid VldEtiq(cEtiqueta,"01") pict "@!"
			Else
				@ 0,0 VTSay STR0005 //"Produto"
				@ 1,0 VTGet cEtiqueta Valid VldProd(cEtiqueta) pict "@!"
			EndIf
			cTipInv := "1"
		Else
			@ 0,0 VTSay Padc(STR0006,20,"-") //" Selecione "
			@ 3,0 VTSay Repl("-",20)
			cTipInv := Str(VTAchoice(1,0,2,19,{STR0005,STR0007}),1) //"Produto"###"Endereco"
			If Empty(Val(cTipInv))
				Loop
			EndIf
			VTClear
			If cTipInv == "1"
				If UsaCB0("01")
					@ 0,0 VTSay STR0004 //"Etiqueta Produto"
					@ 1,0 VTGet cEtiqueta Valid VldEtiq(cEtiqueta,"01") pict "@!"
				Else
					@ 0,0 VTSay STR0005 //"Produto"
					@ 1,0 VTGet cEtiqueta Valid VldProd(cEtiqueta) pict "@!"
				EndIf
			Else
				If UsaCB0("02")
					@ 0,0 VTSay STR0008 //"Etiqueta Endereco"
					@ 1,0 VTGet cEtiqueta Valid VldEtiq(cEtiqueta,"02") pict "@!"
				Else
					@ 0,0 VTSay STR0007 //"Endereco"
					@ 1,0 VTGet cArmazem2 Valid ! Empty(cArmazem2)
					@ 1,3 VTSay "-" VTGet cEndereco Valid VldEnd() pict "@!"
				EndIf
			EndIf
		EndIf
		@ 2,0 VTSay STR0009  //"Contagens OK"
		@ 3,0 VTGet nCont PICT "9" Valid nCont > 0
	Else
		If ! lLocaliz 
			If UsaCB0("01")
				@ 3,0 VTSay STR0004 //"Etiqueta Produto"
					@ 4,0 VTGet cEtiqueta Valid VldEtiq(cEtiqueta,"01") pict "@!"
				Else	
					@ 3,0 VTSay STR0005 //"Produto"
					@ 4,0 VTGet cEtiqueta Valid VldProd(cEtiqueta) pict "@!"		
				EndIf	
				cTipInv := "1"
		   Else  
		   		@ 4,0 VTSay Padc(STR0006,20,"-") //" Selecione "
		   		@ 7,0 VTSay Repl("-",20)
			   cTipInv := Str(VTAchoice(5,0,6,19,{STR0005,STR0007}),1) //"Produto"###"Endereco"
			   If Empty(Val(cTipInv))
			      Loop
			   EndIf  
			   @ 4,0 VTSay Space(20)
			   @ 5,0 VTSay Space(20)
			   @ 6,0 VTSay Space(20)	   	   
			   @ 7,0 VTSay Space(20)	   	   
			   If cTipInv == "1"          
			      If UsaCB0("01")
						@ 3,0 VTSay STR0004 //"Etiqueta Produto"
						@ 4,0 VTGet cEtiqueta Valid VldEtiq(cEtiqueta,"01") pict "@!"
			      Else
						@ 3,0 VTSay STR0005 //"Produto"
						@ 4,0 VTGet cEtiqueta Valid VldProd(cEtiqueta) pict "@!"
					EndIf	
			   Else   
			      If UsaCB0("02")
						@ 3,0 VTSay STR0008 //"Etiqueta Endereco"
						@ 4,0 VTGet cEtiqueta Valid VldEtiq(cEtiqueta,"02") pict "@!"
			      Else
						@ 3,0 VTSay STR0007 //"Endereco"
						@ 4,0 VTGet cArmazem2 Valid ! Empty(cArmazem2)
						@ 4,3 VTSay "-" VTGet cEndereco Valid VldEnd() pict "@!"
					EndIf	
			   EndIf                   
			EndIf        
			@ 5,0 VTSay STR0009  //"Contagens OK"
			@ 6,0 VTGet nCont PICT "9" Valid nCont > 0
		EndIf
			VTRead
			If VTLastkey() == 27
			   Exit
			EndIf	          
			If ! VTYesNo(STR0010,STR0011,.t.) //"Confirma a inclusao"###"Aviso"
			   Loop
			EndIf   
			RecLock("CBA",.t.)
			CBA->CBA_FILIAL := xFilial()
			CBA->CBA_CODINV := GetSXENum("CBA","CBA_CODINV")
			CBA->CBA_DATA   := dDtInv
			CBA->CBA_CONTS  := nCont
			CBA->CBA_TIPINV := cTipInv
			CBA->CBA_LOCAL  := cArmazem
			CBA->CBA_PROD   := cProduto
			CBA->CBA_LOCALI := cEndereco
			CBA->CBA_STATUS := "0"
			CBA->(MsUnLock())   
			If __lSX8
				ConfirmSx8()
			EndIf		
EndDo
Return    

Static Function VldProd(cEtiqueta)
Local aEtiqueta:={}
If cEtiqueta # NIL
	If ! CBLoad128(@cEtiqueta)
		VTKeyboard(chr(20))
		Return .f.
	EndIf                  
	If ! CBRetTipo(cEtiqueta) $ "EAN8OU13-EAN14-EAN128" 
		VTBEEP(3)
		VTAlert(STR0016,STR0011,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VTKeyboard(chr(20))
		Return .f.
	EndIf      
   aEtiqueta := CBRetEtiEAN(cEtiqueta) 
	If Empty(aEtiqueta) 
		VTBEEP(3)
		VTAlert(STR0016,STR0011,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VTKeyboard(chr(20))
		Return .f.
	EndIf                
	cProduto := aEtiqueta[1]
EndIf     
SB1->(DbSetOrder(1))
If ! SB1->(DbSeek(xFilial()+cProduto))
	VTBeep(3)
	VTAlert(STR0017,STR0011,.t.,4000) //"Produto nao cadastrado"###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf
CBA->(DbSetOrder(3))
If CBA->(DBSeek(xFilial()+cTipInv+"0"+cArmazem+cProduto)) .and. CBA->CBA_DATA <= dDtInv
	VTBeep(3)
	VTAlert(STR0012+CBA->CBA_CODINV,STR0011,.t.,4000) //"Inventario ja cadastrado "###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
Endif
If CBA->(DBSeek(xFilial()+cTipInv+"1"+cArmazem+cProduto)) 
	VTBeep(3)
	VTAlert(STR0013+CBA->CBA_CODINV,STR0011,.t.,4000) //"Inventario em andamento "###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf
Return .t.	                            

Static Function VldEnd()               
Begin Sequence
	If cArmazem # cArmazem2
		VTBeep(3)
		VTAlert(STR0014,STR0011,.t.,4000) //"Armazem invalido "###"Aviso"
		break	
	EndIf
	SBE->(DbSetOrder(1))
	If ! SBE->(DbSeek(xFilial()+cArmazem2+cEndereco))
		VTBeep(3)
		VTAlert(STR0015,STR0011,.t.,4000) //"Endereco invalido "###"Aviso"
		break	
	EndIf
	CBA->(DbSetOrder(2))
	If CBA->(DBSeek(xFilial()+cTipInv+"0"+cArmazem2+cEndereco)) .and. CBA->CBA_DATA <= dDtInv
		VTBeep(3)
		VTAlert(STR0012+CBA->CBA_CODINV,STR0011,.t.,4000) //"Inventario ja cadastrado "###"Aviso"
		break		
	Endif
	If CBA->(DBSeek(xFilial()+cTipInv+"1"+cArmazem2+cEndereco)) 
		VTBeep(3)
		VTAlert(STR0013+CBA->CBA_CODINV,STR0011,.t.,4000) //"Inventario em andamento "###"Aviso"
		break
	EndIf	
Recover
   If ! UsaCb0("02")
		VTClearGet("cArmazem2")
		VTClearGet("cEndereco")
		VTGetSetFocus("cArmazem2")
	Else
		VTClearGet("cEtiqueta")		
		VTGetSetFocus("cEtiqueta")		
	EndIf	
	Return .f.	
End
Return .t.

Static Function VldEtiq(cEtiqueta,cTipo)
Local aEtiqueta:={}
If cTipo == "01"
   If ! Empty(cEtiqueta)
		aEtiqueta := CBRetEti(cEtiqueta,cTipo)
		If Len(aEtiqueta) ==0
			VTBeep(3)
			VTAlert(STR0016,STR0011,.t.,4000) //"Etiqueta invalida"###"Aviso"
			VTKeyBoard(chr(20))       
			Return .f.
		EndIf 
	   cProduto := aEtiqueta[1]
   Else	
	   cProduto := Space(Tamsx3("B1_COD")[1])
   EndIf                 
   Return VldProd()   
Else                       
	aEtiqueta := CBRetEti(cEtiqueta,cTipo)
	If Len(aEtiqueta) ==0
		VTBeep(3)
		VTAlert(STR0016,STR0011,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VTKeyBoard(chr(20))       
		Return .f.
	EndIf 
   cEndereco:= aEtiqueta[1]
	cArmazem2:= aEtiqueta[2]
   Return VldEnd()
EndIf
If aEtiqueta[10] <> cArmazem
	VTBeep(3)
	VTAlert(STR0019,STR0011,.t.,4000) //"Armazem da etiqueta difere do Mestre de Inventario!"###'Aviso'
	VTKeyBoard(chr(20))       
	Return .F.
EndIf
Return .t.
