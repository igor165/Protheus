#INCLUDE "Acdv210.ch" 
#include "protheus.ch"
#include "apvt100.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ACDV210    ³ Autor ³ Anderson Rodrigues  ³ Data ³ 01/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Divisao da Etiqueta                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAACD                 								      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Template function ACDV210(uPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)
Return ACDV210(uPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)

Function ACDV210()

Local cEtiqueta
Local aTela		:= Vtsave()
Local cLocalImp := CBRLocImp("MV_IACD02")

Private cCodOpe :=CBRetOpe()
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf


If Empty(cCodOpe)
	VTAlert(STR0001,STR0002,.T.,3000) //"Operador nao cadastrado"###"Aviso"
	Return .F.
EndIf

While .t.	
	cEtiqueta := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
	VtClear
	@ 0,0 VTSay STR0003+STR0004 //'Divisao de Etiquetas'
	If lVT100B // GetMv("MV_RF4X20")
		@ 1,0 VTSay 'Local Imp:' VTGet cLocalImp Pict '@!' F3 "CB5" Valid VldLocImp(cLocalImp) //'Local Imp:'
		@ 2,0 VTSay STR0005 //'Leitura da Etiqueta'
		@ 3,0 VTGet cEtiqueta Pict "@!" Valid VldEti(cEtiqueta,cLocalImp)
	Else
		@ 2,0 VTSay 'Local Imp:' VTGet cLocalImp Pict '@!' F3 "CB5" Valid VldLocImp(cLocalImp) //'Local Imp:'
		@ 3,0 VTSay STR0005 //'Leitura da Etiqueta'
		@ 4,0 VTGet cEtiqueta Pict "@!" Valid VldEti(cEtiqueta,cLocalImp)
	EndIf
	VTRead		
	If VtLastKey() == 27
	   Exit
	Endif
Enddo                   
VTRestore(,,,,aTela)
Return .t.


Static Function VldEti(cEtiqueta,cLocalImp)
Local aTela       
Local nQuant
Local aEtiqueta
Local nDecQuan	:= TamSX3("D1_QUANT")[2]
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
If Empty(cEtiqueta)
	Return .f.
EndIf

aEtiqueta := CBRetEti(cEtiqueta,"01")

If Empty(aEtiqueta)
	VTALERT(STR0006,STR0002,.T.,3000,2) //"Etiqueta invalida."###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf

//--Valida se a etiqueta já foi consumida por outro processo
If CB0->CB0_STATUS $ "123"  
	VTBeep(2)
	VTAlert(STR0006,STR0002,.T.,3000,2) //"Etiqueta invalida"###"Aviso"
	VTKeyBoard(chr(20))
	Return .F.
EndIf	

If QtdComp( aEtiqueta[2] ) == QtdComp( 1 / 10**nDecQuan )
	VTALERT(STR0007,STR0002,.T.,3000,2) //"Etiqueta com quantidade indivisivel"###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf

If ! Empty(CB0->CB0_PEDCOM)
	SC7->(DbSetOrder(1))
	If ! SC7->(DbSeek(xFilial()+CB0->CB0_PEDCOM))
		VTALERT(STR0011,STR0002,.T.,4000,2) //"Pedido nao encontrado"###"Aviso"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf                 
EndIf

If ValidOrdSep(aEtiqueta[1],cEtiqueta)
	VTBeep(2)
	VTAlert(STR0006,STR0002,.T.,3000,2) //"Etiqueta invalida"###"Aviso"
	VTKeyBoard(chr(20))
	Return .F.
EndIf

aTela := VtSave()
nQuant := 0
If lVT100B // GetMv("MV_RF4X20")
	@ 2,0 VTSay STR0012 //'Digite a Quantidade'
	@ 3,0 VTGet nQuant    Pict CBPictQtde() Valid VldQuant(nQuant,aEtiqueta[2])
Else
	@ 3,0 VTSay STR0012 //'Digite a Quantidade'
	@ 4,0 VTGet nQuant    Pict CBPictQtde() Valid VldQuant(nQuant,aEtiqueta[2])	
EndIf
VTRead  	 
VtRestore(,,,,aTela)
If VtLastKey() == 27
	VTKeyBoard(chr(20))
	Return .F.
Endif
If VTYesNo(STR0013,STR0014,.t.) //'Confirma a Geracao da Nova Etiqueta'###'Atencao'
  	ImpEti(nQuant,cLocalImp) 	   	
EndIf
Return .T.

Static Function VldQuant(nQuant,nQuantOri)
If nQuant == 0 .OR. nQuant >= nQuantOri
	VTALERT(STR0015,STR0002,.T.,3000,2) //"Quantidade invalida"###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
Endif	
Return

Static Function ImpEti(nQuant,cLocalImp)
Local cCodEtiOri := Space(Len(CB0->CB0_CODETI))
Local cNewEtiq   := ""
Local nRecno           
Local nRecnoCB0  := CB0->(Recno()) 
Local aNewFields := {}
Local aACD210NE  := {}

VTMsg(STR0018) //"Imprimindo..."

CB0->(DbGoto(nRecnoCB0))
cCodEtiOri := CB0->CB0_CODETI

aNewFields :={	{"CB0_CODETI"	,CBProxCod("MV_CODCB0")	},;
				{"CB0_QTDE"		,nQuant		}}

If ExistBlock("ACD210NE") .And. ValType(aACD210NE := ExecBlock("ACD210NE",.F.,.F.,{aNewFields})) == "A"
	aNewFields := aClone(aACD210NE)
EndIf

nRecno:= CB0->(CBCopyRec(aNewFields))	
CB0->(DbGoto(nRecno))
SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial()+CB0->CB0_CODPRO))
CB5SetImp(cLocalImp,IsTelNet())
If ExistBlock('IMG01')			
   ExecBlock("IMG01",,,{,,CB0->CB0_CODETI,1})
EndIf	
If ExistBlock('IMG00')
	ExecBlock("IMG00",,,{"ACDV210"})
EndIf
MSCBCLOSEPRINTER()
//Gravacao do log da nova etiqueta gerada:
CbLog("07",{CB0->CB0_CODPRO,CB0->CB0_QTDE,CB0->CB0_LOTE,CB0->CB0_SLOTE,CB0->CB0_LOCAL,CB0->CB0_LOCALI,CB0->CB0_OP,CB0->CB0_CODETI,cCodEtiOri,NIL})
cNewEtiq := CB0->CB0_CODETI

CB0->(DbGoto(nRecnoCB0))
Reclock("CB0",.f.)
CB0->CB0_QTDE := CB0->CB0_QTDE - nQuant
CB0->(MSUnlock())

If ExistBlock("ACD210DI")
      ExecBlock("ACD210DI",.F.,.F., {cCodEtiOri,cNewEtiq})
EndIf

Return

/*/{Protheus.doc} ValidOrdSep
	@long_description 
	Verifica se a etiqueta informada possui amarração com 
	alguma ordem de separação com a sua separação já finalizada
	@author pedro.missaglia
	@since 03/2020
	@version 1.00
	@return true, logico
/*/
Static Function ValidOrdSep(cProd, cCodEti)
	Local cArea := GetArea()
	Local lRet := .F.
	Local cAliasCB9 := 'CB9'
	Local cAliasCB7 := 'CB7'

	dbSelectArea(cAliasCB9)
	(cAliasCB9)->(DbSetOrder(3))
	If ((cAliasCB9)->(DbSeek(xFilial()+cProd+cCodEti)))
		dbSelectArea(cAliasCB7)
		(cAliasCB7)->(DbSetOrder(1))
		If ((cAliasCB7)->(DbSeek(xFilial()+((cAliasCB9)->CB9_ORDSEP))))
			If !Empty((cAliasCB7)->CB7_DTINIS)
				lRet := .T.
			EndIf 
		EndIf

	EndIf

	(cAliasCB9)->(dbCloseArea())
	(cAliasCB7)->(dbCloseArea())
	RestArea(cArea)
	
Return lRet

/*/{Protheus.doc} VldLocImp
	Valida local de impressao
	@author andre.oliveira
	@since 01/2020
	@version 1.00
	@return logico
/*/
Static Function VldLocImp(cCodigo)
	Local lRet := .T.

	If !ExistCpo("CB5",cCodigo)
		VTAlert("Local de impressao invalido.",STR0017,.t.,3000,3) //'Local de impressao inválido.'###'Aviso'
		lRet := .F.
	EndIf

Return lRet
