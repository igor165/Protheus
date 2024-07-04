#INCLUDE "ACDV230.ch" 
#INCLUDE "protheus.ch"
#INCLUDE "apvt100.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ACDV230    ³ Autor ³ Desenv.    ACD      ³ Data ³ 24/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Montagem de Pallet                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaACD           	    								           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template function ACDV230(uPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)
Return ACDV230(uPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)

Function ACDV230()
Local   bkey09 := VTSetKey(09,{|| ACD230Hist()},STR0025)// CTRL+I //"Informacoes"
Local   bKey24 := VTSetKey(24,{|| Estorna()},STR0026)   // CTRL+X //"Estorno"
Private aHisEti:= {}
Private cEti   := If(UsaCB0("01"),Space(TamSX3("CB0_CODET2")[1]), IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) ) )		
Private cLocalImp := CBRLocImp("MV_IACD04")
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf


While .T.
   cEti   := If(UsaCB0("01"),Space(TamSX3("CB0_CODET2")[1]), IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) ) )
   
	VTClear()			
	@ 0,0 VTSay STR0001 //"Montagem de Pallet"
	@ 2,0 VTSay STR0002  VTGet cEti pict '@!' Valid VldEti() .and. ! Empty(aHisEti) //"Produto  :"
	@ IIf(lVT100B /*GetMv("MV_RF4X20")*/,3,4),0 VTSay STR0003  VTGet cLocalImp pict '@!' F3 "CB5" Valid VldLocImp() //"Local Imp:"
	VTRead                               
	If VTLastKey() == 27 .and. Empty(aHisEti)
	   Exit
	ElseIf VTLastKey() == 27 .and. ! Empty(aHisEti)	   
      If VTYesNo(STR0004,STR0005,.t.) //'Aborta a operacao ?'###'Pergunta'
	      Exit   
	   Else
	      Loop
	   Endif	 
   EndIf	   
   If VTYesNo(STR0006,STR0007,.t.) //"Confirma geracao do Pallet ?"###"Pergunta"
	   GeraPallet( cLocalImp )  
	Else
	   Loop   
	EndIf
	aHisEti:={}
Enddo

Vtsetkey(09,bkey09)
Vtsetkey(24,bkey24)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ VldEti     ³ Autor ³ Anderson Rodrigues  ³ Data ³ 24/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica integridade da etiqueta                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaACD           	    								           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldEti()
Local nPos
Local aEtiqueta
Local aItensPallet

If Empty(cEti) 
	Return .t.
Endif

nPos         := Ascan(aHisEti,{|x| x == cEti})
If nPos > 0	
   VTBeep(2)
	VTAlert(STR0008,STR0009,.t.,4000) //"Etiqueta ja informada"###"Aviso"
	VtClearGet("cEti")
	Return .f.
Endif

aItensPallet := CBItPallet(cEti)
If Len(aItensPallet) > 0
   VTBeep(2)
   VTAlert(STR0010,STR0009,.T.,4000)    //"Etiqueta invalida"###"AVISO"
   VtClearGet("cEti")
   Return .f.
Endif

aEtiqueta    := CBRetEti(cEti,"01")
If Empty(aEtiqueta)  
   VTBeep(2)
   VTAlert(STR0010,STR0009,.t.,4000)  //"Etiqueta invalida"###"Aviso"
   VtClearGet("cEti")
   Return .f.
EndIf

//--Valida se a etiqueta já foi consumida por outro processo
If CB0->CB0_STATUS $ "123"  
	VTBeep(2)
	VTAlert(STR0010,STR0009,.T.,4000) //"Etiqueta invalida"###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf	

If !Empty(aEtiqueta[21])
   VTBeep(2)
   VTAlert(STR0011+aEtiqueta[21],STR0009,.t.,4000)  //"Etiqueta ja pertence ao Pallet "###"Aviso"
   VtClearGet("cEti")
   Return .f.
Endif

If !LocalizPallet( aEtiqueta[10], aEtiqueta[9], aHisEti )
   VTBeep(2)
   VTAlert( STR0027 ,STR0009,.t.,4000)  //""Produto em Armazem e/ou Endereco Diferente ao da Montagem.""###"Aviso"
   VtClearGet("cEti")
   Return .f.
EndIf

If ExistBlock('ACD230ET') .and. !Execblock("ACD230ET",,,{aEtiqueta})
   VTBeep(2)
   VTAlert(STR0010,STR0009,.T.,4000)    //"Etiqueta invalida"###"AVISO"
   VtClearGet("cEti")
   Return .f.
EndIf
aadd(aHisEti,cEti)
VtClearGet("cEti")
Return .f.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Estorna    ³ Autor ³ Anderson Rodrigues  ³ Data ³ 24/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o estorno da(s) etiqueta(s) informada(s)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAACD            	    		  			                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Estorna()
Local aTela := VTSave()

cEti  := If(UsaCB0("01"),Space(TamSX3("CB0_CODET2")[1]), IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) ) )			

VTClear()

@ 00,00 VtSay STR0014 //"Estorno da Etiqueta"
@ 02,00 VtGet cEti pict "@!" Valid VldEstorno()
VtRead
VtRestore(,,,,aTela)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ACD230Hist ³ Autor ³ Anderson Rodrigues  ³ Data ³ 24/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra as etiqueta(s) lid(a)s 					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAACD           	    								  		     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ACD230Hist()
Local aSave := VTSAVE()
Local aCab  := {STR0015,STR0016,STR0017} //"Etiqueta"###"Produto"###"Quantidade"
Local	aSize := {20,15,10}
Local aProds:= {}
Local nX
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

CB0->(DbSetOrder(1))
For nX:= 1 to Len(aHisEti)
   If CB0->(DbSeek(xFilial("CB0")+aHisEti[nX]))       
      aadd(aProds,{CB0->CB0_CODETI,CB0->CB0_CODPRO,Str(CB0->CB0_QTDE,8,2)})   
   Endif
Next
   
VtClear()
@ 0,0 VTSay STR0018	 //"Etiqueta(s) Lida(s):"
VTaBrowse(2,0,IIf(lVT100B /*GetMv("MV_RF4X20")*/,3,7),19,aCab,aProds,aSize)
If VtLastKey() == 27
   VtRestore(,,,,aSave)
Endif
VtRestore(,,,,aSave)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ VldEstorno ³ Autor ³ Anderson Rodrigues  ³ Data ³ 25/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o estorno da Leitura da(s) etiqueta(s)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAACD            	    		  			                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldEstorno()
Local nPos

If Empty(cEti)
	Return .f.
EndIF
nPos:= Ascan(aHisEti,{|x| AllTrim(x) == AllTrim(cEti)})
If nPos == 0
   VTBeep(2)
   VTALERT(STR0019,STR0009,.T.,3000) //"Etiqueta nao encontrada"###"AVISO"
   VtKeyboard(Chr(20))
   Return .f.
Endif
If ! VTYesNo(STR0020,STR0021,.t.) //"Confirma o estorno da etiqueta ?"###"ATENCAO"
   VtKeyboard(Chr(20))
   Return .f.
EndIf
While .t.
   nPos:= Ascan(aHisEti,{|x| AllTrim(x) == AllTrim(cEti)})
   If nPos == 0
      Exit
   Endif
   aDel(aHisEti,nPos)
   aSize(aHisEti,Len(aHisEti)-1)
   VtKeyboard(Chr(20))
Enddo
Return .f. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ GeraPallet ³ Autor ³ Anderson Rodrigues  ³ Data ³ 25/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera o Pallet das etiquetas lidas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAACD            	    		  			                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ImprPallet( cLocalImp, cEtiPallet, lGrvCB0 )
Default lGrvCB0   := .T.
Default cEtiPallet:= Nil

Return GeraPallet( cLocalImp, cEtiPallet, lGrvCB0 )

Static Function GeraPallet( cLocalImp, cEtiPallet, lGrvCB0 )
Local nX

Default lGrvCB0   := .T.
Default cEtiPallet:= Nil

CB0->(DbSetOrder(1))

If lGrvCB0
   cEtiPallet := CBProxCod("MV_CODCB0")
   For nX:= 1 to Len(aHisEti)
      CBRetEti(aHisEti[nX],"01")
      If !CB0->(EOF())
         Reclock("CB0",.f.)
         CB0->CB0_PALLET:= cEtiPallet
         CB0->(MsUnlock())
      Endif
   Next
EndIf

VTMsg(STR0022) //"Imprimindo..."

IF ! CB5SetImp(cLocalImp,IsTelNet())
	VTBeep(3)
	VTAlert(STR0023,STR0024,.t.,3000) //'Local de impressao nao configurado, MV_IACD04'###'Aviso'
	Return .F.
EndIf

If ExistBlock("IMG10")
   ExecBlock("IMG10",,,{ cEtiPallet } )
EndIf

If ExistBlock('IMG00')
	ExecBlock("IMG00",,,{ "ACDV230", cEtiPallet } )
EndIf

MSCBCLOSEPRINTER()
Return .T.

/*/{Protheus.doc} LocalizPallet
//Valida se endereço da etiqueta lida é o mesmo
@author andre.oliveira
@since 04/02/2020
@version 1.0

@type function
/*/
Function LocalizPallet( cLocal, cLocalizEti, aVldEtix )
Local lRet        := .T.
Local aAreaCB0    := CB0->(GetArea())
Local aEtiLida    := {}
Default aVldEtix  := {}

If Len( aVldEtix ) > 0
   aEtiLida := CBRetEti( aVldEtix[1], "01" )
   lRet := AllTrim( aEtiLida[10] ) == AllTrim( cLocal ) .And. AllTrim( aEtiLida[9] ) == AllTrim( cLocalizEti )
EndIf

CB0->(RestArea(aAreaCB0))
Return lRet

/*/{Protheus.doc} VldLocImp
Valida o local de impressao informado
@type function
@version 12.1.25
@author andre.oliveira
@since 20/01/2021
/*/
Static Function VldLocImp()
   Local lRet := .T.
   
   CB5->(dbSetOrder(1))
   If !CB5->(MsSeek(xFilial("CB5")+cLocalImp))
      VTBeep(3)
      VTAlert(STR0028,STR0024,.t.,3000) //'Local de impressão invalido.'###'Aviso'
      lRet := .F.
   EndIf
Return lRet
