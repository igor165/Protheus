// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 48     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "PROTHEUS.CH"
#INCLUDE "OFIPM900.CH"

/*/{Protheus.doc} mil_ver
Versao do fonte modelo novo
@author Andre Luis Almeida
@since 05/11/2017
@version undefined

@type function
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007480_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIPM900 ³ Autor ³  Renata / Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Requisicao de Compras/Bloqueia peca/Venda perdida          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes³ Andre | Verificacao do Estoque e Integracao com a Microsiga³±±
±±³          ³       | para mudanca de almoxarifado         Data: 28/10/00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Pecas                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIPM900()
Local aCores  := {	{ 'VE6->VE6_INDREG == "0"', 'BR_VERDE'    } ,;  // Requisicao de Compras
					{ 'VE6->VE6_INDREG == "1"', 'BR_VERMELHO' } ,;  // Vendas Perdidas
					{ 'VE6->VE6_INDREG == "2"', 'BR_AZUL'     } ,;  // Bloqueio de Item
					{ 'VE6->VE6_INDREG == "3"', 'BR_PRETO'    } ,;   // Reserva de Item
					{ 'VE6->VE6_INDREG == "4"', 'BR_AMARELO'  }  }   // Reserva de Item
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0005)   //Requisicao de Compras //"Registro de Operacoes do Item"
Private __cTip := ""
DbSelectArea("VE6")
DbSetorder(1)

if Alltrim(GetNewPar("MV_BLQITE","")) == "" .or. Alltrim(GetNewPar("MV_RESITE","")) == ""
	MsgStop(STR0050)
	return .f.
endif

mBrowse( 6, 1,22,75,"VE6",,,,,,aCores)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFMV900  ³ Autor ³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza dados do VE6, atraves da AXVISUAL()              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFMV900(cAlias,nReg,nOpc)

Local aCampos := {}

aCampos := CAMPOM900(nOpc)
AxVisual(cAlias,nReg,nOpc,aCampos)
SetKey(VK_F4, Nil )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFMI900  ³ Autor ³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclusao dos dados no VE6 atraves do AXINCLUI()            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFMI900(cAlias,nReg,nOpc,aInicCpo,lAutomatico,lPerg,cTitJan,lBoqCancel,lFullAuto,lOPM900Val,lOPM900Rel)

Local bOk,oDlgPM900,aCampos := {}, nMemoria := 0
Local aAltCpo    := {}
Local aColsSlv   := if(Type("aCols") # "U",aClone(aCols),Nil)
Local aHeaderSlv := if(Type("aHeader") # "U",aClone(aHeader),Nil)

Local aSizeAut 	:= MsAdvSize(.t.)
Local aPosObj 	:= {}
Local aObjects 	:= {}

If !cTitJan==Nil
	cCadastro := cTitJan
Endif
aCols   := Nil
aHeader := Nil

Private OFP8600016 := ExistFunc("OFP8600016_VerificacaoFormula")

Private inclui   := .t. , altera   := .f.
Private aTELA[0][0],aGETS[0]

Default lAutomatico := .f.
Default lPerg       := .t.
Default lBoqCancel  := .f.
Default lOPM900Val := .f.
Default lOPM900Rel := .f.
Default lFullAuto   := .f.

If !lAutomatico
	aInicCpo := {}
	//Else
	//   if lPerg
	//      if !PERGUNTE("OFI900")
	//         Return
	//      Endif
	//   Endif
EndIf

If nOpc == 3
	If lPerg
		if !PERGUNTE("OFI900")
			aCols   := aClone(aColsSlv)
			aHeader := aClone(aHeaderSlv)
			Return
		Endif
	Endif
EndIf
PERGUNTE("OFI900",.f.)

nPos := aScan( aInicCpo , { |x| Alltrim(x[1]) == "VE6_INDREG" } )
if nPos > 0
	mv_par01 := val(aInicCpo[nPos,2])+1
endif
__cTip := Str(mv_par01-1,1)

//Monta os Campos
aCampos := CAMPOM900(nOpc)

For nMemoria := 1 to Len(aCampos)
	
	If Alltrim(aCampos[nMemoria]) # "VE6_INDREG" .And. ( (!lAutomatico .Or. ( Len(aInicCpo) == 0 .Or. Ascan( aInicCpo , { |x| Alltrim(x[1]) == aCampos[nMemoria] } ) == 0 )) .or. ( Alltrim(aCampos[nMemoria]) $ "VE6_CODIGO/VE6_QTDITE" ) )
		
		Aadd( aAltCpo , aCampos[nMemoria] )
		
	EndIf
	
	If !Empty(GetMv("MV_FMLPECA")) .and. aCampos[nMemoria] == "VE6_FORMUL" .and. Str(mv_par01-1,1) == "1"    && Venda Perdida
		If OFP8600016 .And. OFP8600016_VerificacaoFormula(&(GetMv("MV_FMLPECA")), .f.)
			&( "M->"+aCampos[nMemoria] ) := &(GetMv("MV_FMLPECA"))
		Else
			&( "M->"+aCampos[nMemoria] ) := CriaVar( aCampos[nMemoria] )
		EndIf
	Else
		&( "M->"+aCampos[nMemoria] ) := CriaVar( aCampos[nMemoria] )
	EndIf
	
Next                            
  
DbSelectArea("VE6")

if !lFullAuto

	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 315, 050, .T., .T. } ) // EnchoiceBar
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 0 , 0 }
	aPosObj := MsObjSize (aInfo, aObjects, .t.)
	//
	
	DEFINE MSDIALOG oDlgPM900 TITLE cCadastro FROM aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] PIXEL OF oMainWnd
	
	EnChoice( cAlias, nReg, nOpc, ,"VE6",oemtoansi(STR0007),aCampos, aPosObj[01],aAltCpo , , , ,"FS_VALIND",,.t. ) //"Quanto … inclus„o?" //"&Requisicao de Compra"
	
	For nMemoria := 1 to Len(aInicCpo)
		&( "M->"+aInicCpo[nMemoria,1] ) := aInicCpo[nMemoria,2]
	Next
	
	If type("__cTip") # "U" .and. Inclui
		M->VE6_INDREG := __cTip
	Endif
	
	ACTIVATE MSDIALOG oDlgPM900 ON INIT EnchoiceBar(oDlgPM900,{|| If(Obrigatorio(aGets,aTela).and. FS_VALIND() , oDlgPM900:End() , .f. ) },{|| If( lBoqCancel, .f. ,oDlgPM900:End() ) } )
else
	For nMemoria := 1 to Len(aInicCpo)
		&( "M->"+aInicCpo[nMemoria,1] ) := aInicCpo[nMemoria,2]
	Next
	
	If type("__cTip") # "U" .and. Inclui
		M->VE6_INDREG := __cTip
	Endif
	If Obrigatorio(aGets,aTela).and. FS_VALIND(lOPM900Val,@lOPM900Rel)
		return .t.
	else
		return .f.
	endif
endif
aCols   := aClone(aColsSlv)
aHeader := aClone(aHeaderSlv)
SetKey(VK_F4, Nil )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CAMPOM900 ³ Autor ³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pega campos do VE6 no SX3                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CAMPOM900(nOpc)

Local aCampos := {}

DbSelectArea("SX3")
DbSetOrder(1)
Dbseek("VE6")

Do While !eof() .and. x3_arquivo == "VE6"
	
	If X3USO(x3_usado) .And. cNivel >= x3_nivel ;
		.And. !( Alltrim(x3_campo) $ [VE6_INDMOT/VE6_DATEXC/VE6_HOREXC/VE6_USUEXC/VE6_OBSMEM] )
		
		If nOpc == 3
			
			If Str(mv_par01-1,1) == "0" .OR. Str(mv_par01-1,1) == "4"    &&  Requisicao de compra
				
				If !( Alltrim(x3_campo) $ [VE6_CODMOT/VE6_DESMOT/VE6_INDMOT/VE6_QTDDES] )
					
					aadd( aCampos , x3_campo )
					
				EndIf
				
			ElseIf Str(mv_par01-1,1) == "1"    && Venda Perdida
				
				If !( Alltrim(x3_campo) $ [VE6_ORIREQ/VE6_DESORI/VE6_FORPED/VE6_DESPED/VE6_NUMOSV/VE6_PEND/VE6_NOMFOR/VE6_CHAINT/VE6_CHASSI/VE6_TIPTEM/VE6_FATPAR/VE6_LOJA/VE6_NOMCLI/VE6_CODCLI/VE6_LOJCLI/VE6_NOMECL/VE6_NOMFAN/VE6_FORPAG/VE6_CODFOR/VE6_LOJFOR/VE6_INDMOT/VE6_CODPED/VE6_USUEXC/VE6_DATEXC/VE6_RAZAO/VE6_QTDDES] )
					
					aadd( aCampos , x3_campo )
					
				Endif
				
			Else     && Bloqueio de Itens
				
				If !( Alltrim(x3_campo) $ [VE6_DESORI/VE6_FORPED/VE6_DESPED/VE6_NUMOSV/VE6_PEND/VE6_FORMUL/VE6_NOMFOR/VE6_VALPEC/VE6_CODMOT/VE6_DESMOT/VE6_CHAINT/VE6_CHASSI/VE6_TIPTEM/VE6_FATPAR/VE6_LOJA/VE6_NOMCLI/VE6_CODCLI/VE6_LOJCLI/VE6_NOMECL/VE6_NOMFAN/VE6_FORPAG/VE6_CODFOR/VE6_LOJFOR/VE6_INDMOT/VE6_CODPED/VE6_USUEXC/VE6_DATEXC/VE6_RAZAO/VE6_QTDDES] )
					
					aadd( aCampos , x3_campo )
					
				Endif
				
			Endif
			
		Else
			
			If VE6->VE6_INDREG == "0" .OR.  VE6->VE6_INDREG == "4"   &&  Requisicao de compra ou backorder
				
				If !( Alltrim(x3_campo) $ [VE6_CODMOT/VE6_DESMOT/VE6_INDMOT/VE6_QTDDES] )
					
					aadd( aCampos , x3_campo )
					
				EndIf
				
			ElseIf VE6->VE6_INDREG == "1"    && Venda Perdida
				
				//				If !( Alltrim(x3_campo) $ [VE6_ORIREQ/VE6_DESORI/VE6_FORPED/VE6_DESPED/VE6_NUMOSV/VE6_PEND/VE6_FORMUL/VE6_NOMFOR/VE6_VALPEC/VE6_CHAINT/VE6_CHASSI/VE6_TIPTEM/VE6_FATPAR/VE6_LOJA/VE6_NOMCLI/VE6_CODCLI/VE6_LOJCLI/VE6_NOMECL/VE6_NOMFAN/VE6_FORPAG/VE6_CODFOR/VE6_LOJFOR/VE6_INDMOT/VE6_CODPED/VE6_USUEXC/VE6_DATEXC/VE6_RAZAO] )
				If !( Alltrim(x3_campo) $ [VE6_ORIREQ/VE6_DESORI/VE6_FORPED/VE6_DESPED/VE6_NUMOSV/VE6_PEND/VE6_NOMFOR/VE6_CHAINT/VE6_CHASSI/VE6_TIPTEM/VE6_FATPAR/VE6_LOJA/VE6_NOMCLI/VE6_CODCLI/VE6_LOJCLI/VE6_NOMECL/VE6_NOMFAN/VE6_FORPAG/VE6_CODFOR/VE6_LOJFOR/VE6_INDMOT/VE6_CODPED/VE6_USUEXC/VE6_DATEXC/VE6_RAZAO/VE6_QTDDES] )
					
					aadd( aCampos , x3_campo )
					
				Endif
				
			Else   && Bloqueio de Itens
				
				If !( Alltrim(x3_campo) $ [VE6_ORIREQ/VE6_DESORI/VE6_FORPED/VE6_DESPED/VE6_NUMOSV/VE6_PEND/VE6_FORMUL/VE6_NOMFOR/VE6_VALPEC/VE6_CODMOT/VE6_DESMOT/VE6_CHAINT/VE6_CHASSI/VE6_TIPTEM/VE6_FATPAR/VE6_LOJA/VE6_NOMCLI/VE6_CODCLI/VE6_LOJCLI/VE6_NOMECL/VE6_NOMFAN/VE6_FORPAG/VE6_CODFOR/VE6_LOJFOR/VE6_INDMOT/VE6_CODPED/VE6_USUEXC/VE6_DATEXC/VE6_RAZAO/VE6_QTDDES] )
					
					aadd( aCampos , x3_campo )
					
				Endif
				
			Endif
			
		EndIf
		
	EndIf
	
	Dbskip()
	
Enddo

DbSelectArea("VE6")
// Funcoes de Tecla
SETKEY(VK_F4,{||GRAVALOTE()})

Return( aCampos )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFME900  ³ Autor ³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para exclusao dos dados VE6                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFME900(cAlias,nReg,nOpc)

Local nCntFor
Local bCampo   := { |nCPO| Field(nCPO) }

Private oDlg,oLbTexto,aVetor:={},aBitmaps := {},cBitMap := Space(8)
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

Private dDatIni :=Ctod("  /  /  ")
Private dDatFin :=dDataBase
Private cMotivo :=Space(3)
Private cDesMot :=Space(20)
Private cUsuario:=Space(6)
Private cItem   :=Space(27)
Private cCliente:=Space(6)
Private cLoja   :=Space(2)
Private cNomCli :=Space(20)
Private nTotal  :=0

Private nTipCon:=nOpcao:=1

DbSelectArea("VE6")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

DEFINE MSDIALOG oDlg TITLE STR0005 From 1,08 to 36,92      of oMainWnd //"Registro de Operacoes do Item"

@ 001,.1 TO 062,333 LABEL STR0008 OF oDlg PIXEL //"Periodo"

@ 007,002 SAY STR0009 OF oDlg SIZE 33,10 PIXEL COLOR CLR_BLACK //"Data Inicial"
@ 007,030 MSGET oDatIni VAR dDatIni PICTURE "@D" SIZE 45,4 OF oDlg PIXEL COLOR CLR_BLACK

@ 007,102 SAY STR0010 OF oDlg SIZE 33,10 PIXEL COLOR CLR_BLACK //"Data Final"
@ 007,130 MSGET oDatFin VAR dDatFin PICTURE "@D" SIZE 45,4 OF oDlg PIXEL COLOR CLR_BLACK

@ 019,002 RADIO oTipCon VAR nTipCon PROMPT STR0007,STR0011 3D OF oDlg PIXEL SIZE 075,10 //"&Requisicao de Compra"###"&Vendas Perdidas"
oTipCon:bChange:={||nTotal:=0,FS_FILT900(),oLbTexto:Refresh()}

@ 020,102 SAY STR0006 OF oDlg SIZE 33,10 PIXEL COLOR CLR_BLACK //"&Motivo"
@ 020,130 MSGET oMotivo VAR cMotivo PICTURE "@!" F3 "VE7" VALID Empty(cMotivo) .or. FG_VALIDA(,"VE7T1Str(nTipCon-1,1)+cMotivo*","cDesMot:=VE7->VE7_DESMOT,oDesMot:Refresh()") SIZE 45,4 OF oDlg PIXEL COLOR CLR_BLACK
@ 020,175 MSGET oDesMot VAR cDesMot PICTURE "@!" SIZE 140,4 OF oDlg PIXEL COLOR CLR_BLACK When .f.
oMotivo:bChange:={||nTotal:=0,FS_FILT900(),oLbTexto:Refresh()}

@ 030,102 SAY STR0012 OF oDlg SIZE 33,10 PIXEL COLOR CLR_BLACK //"&Usuario"
@ 030,130 MSGET oUsuario VAR cUsuario PICTURE "@!" F3 "USR" SIZE 60,4 OF oDlg PIXEL COLOR CLR_BLACK
oUsuario:bChange:={||nTotal:=0,FS_FILT900(),oLbTexto:Refresh()}

@ 040,102 SAY STR0013 OF oDlg SIZE 33,10 PIXEL COLOR CLR_BLACK //"&Item"
@ 040,130 MSGET oItem VAR cItem PICTURE "@!" F3 "SB1" SIZE 100,4 OF oDlg PIXEL COLOR CLR_BLACK
oItem:bChange:={||nTotal:=0,FS_FILT900(),oLbTexto:Refresh()}

@ 050,102 SAY STR0014 OF oDlg SIZE 33,10 PIXEL COLOR CLR_BLACK //"&Cliente"
@ 050,130 MSGET oCliente VAR cCliente PICTURE "@!" F3 "SA1" VALID Empty(cCliente) .or. FG_VALIDA(,"SA1T1cCliente*","cNomCli:=SA1->A1_NREDUZ") SIZE 45,4 OF oDlg PIXEL COLOR CLR_BLACK
oCliente:bChange:={||nTotal:=0,FS_FILT900(),oLbTexto:Refresh()}

@ 050,177 MSGET oLoja VAR cLoja PICTURE "@!" VALID Empty(cLoja) .or. FG_VALIDA(,"SA1T1cCliente+cLoja*","cNomCli:=SA1->A1_NREDUZ") SIZE 25,4 OF oDlg PIXEL COLOR CLR_BLACK
oLoja:bChange:={||nTotal:=0,FS_FILT900(),oLbTexto:Refresh()}

@ 050,205 MSGET oNomCli VAR cNomCli PICTURE "@!" SIZE 100,4 OF oDlg PIXEL COLOR CLR_BLACK When .f.

@ 062,.1 TO 252,333 LABEL "" OF oDlg PIXEL

@ 062,001 BUTTON oMarcar    PROMPT STR0015 OF oDlg SIZE 33,11 PIXEL  ACTION (FS_MARCA900(.T.),oLbTexto:Refresh()) //"&Marcar"
@ 062,040 BUTTON oDesmarcar PROMPT STR0016 OF oDlg SIZE 33,11 PIXEL  ACTION (FS_MARCA900(.F.),oLbTexto:Refresh()) //"&Desmarcar"

@ 072,001 LISTBOX oLbTexto FIELDS HEADER OemToAnsi(" "),;
OemToAnsi(STR0017),; //"Data Registro"
OemToAnsi(STR0018),; //"Hora"
OemToAnsi(STR0019),; //"Nro OS"
OemToAnsi(STR0020),; //"Cliente"
OemToAnsi(STR0021),; //"Loja"
OemToAnsi(STR0022),; //"Chassi"
OemToAnsi(STR0023),; //"Grupo"
OemToAnsi(STR0024),; //"Item"
OemToAnsi(STR0025),; //"Qtd"
OemToAnsi(STR0026); //"Razao"
COLSIZES 30,60,40,60,60,20,60,60,60,60;
SIZE 331,168 OF oDlg PIXEL ON DBLCLICK (If(aVetor[oLbTexto:nAt,1],(aVetor[oLbTexto:nAt,1]:=.F.,oNo),(aVetor[oLbTexto:nAt,1]:=.T.,oOk)))

FS_FILT900()

@ 242,004 BITMAP oBmp RESOURCE "LBOK" OF oDlg NOBORDER SIZE 16,10 WHEN .F. PIXEL
@ 242,015 SAY STR0027 OF oDlg SIZE 20,10 PIXEL COLOR CLR_BLACK //"Deletar"
@ 242,039 BITMAP oBmp1 RESOURCE "LBNO" OF oDlg NOBORDER SIZE 16,10 WHEN .F. PIXEL
@ 242,050 SAY STR0028 OF oDlg SIZE 30,10 PIXEL COLOR CLR_BLACK //"Nao Deletar"

@ 241,240 SAY STR0029 OF oDlg SIZE 33,10 PIXEL COLOR CLR_RED //"Total"
@ 241,270 MSGET oTotal VAR nTotal PICTURE "@E 99,999,999" SIZE 45,4 OF oDlg PIXEL COLOR CLR_BLACK When .f.

DEFINE SBUTTON FROM 253,210 TYPE 17 ACTION (nTotal:=0,FS_FILT900(),oLbTexto:Refresh()) ENABLE OF oDlg    &&Filtro
DEFINE SBUTTON FROM 253,240 TYPE 1 ACTION (FS_ALTE900(),oDlg:End()) ENABLE OF oDlg  &&Ok
DEFINE SBUTTON FROM 253,270 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg   &&Cancela

ACTIVATE MSDIALOG oDlg

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_FILT900³ Autor ³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtra dados no VE6                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FILT900()

aVetor:={}

DbSelectArea("VE6")
DbSeek( xFilial("VE6") + If(nTipCon==1,"0","1") + Dtos(dDatIni) , .T. )

Do While !Eof() .and. VE6->VE6_FILIAL = xFilial("VE6") .And. VE6->VE6_INDREG==If(nTipCon==1,"0","1").And.VE6->VE6_DATREG>=dDatIni.And.VE6->VE6_DATREG<=dDatFin
	
	If Empty(VE6->VE6_DATEXC) .And. (VE6->VE6_RAZAO==cMotivo.Or.Empty(cMotivo)).And.(VE6->VE6_CODUSU==cUsuario.Or.Empty(cUsuario)).And.(Posicione("SB1",7,xFilial("SB1")+VE6->VE6_GRUITE+VE6->VE6_CODITE,"B1_COD")==cItem.Or.Empty(cItem)).And.(VE6->VE6_CODCLI==cCliente.Or.Empty(cCliente)).And.(VE6->VE6_LOJCLI==cLoja.Or.Empty(cLoja)).And.Empty(VE6->VE6_DATEXC)
		
		Aadd(aVetor,{.F.,VE6->VE6_DATREG,val(VE6->VE6_HORREG),VE6->VE6_NUMOSV,VE6->VE6_CODCLI,VE6->VE6_LOJCLI,VE6->VE6_CHAINT,VE6->VE6_GRUITE,VE6->VE6_CODITE,VE6->VE6_QTDITE,VE6->VE6_RAZAO})
		
		nTotal += VE6->VE6_QTDITE
		
	EndIf
	
	DbSelectArea("VE6")
	DbSkip()
	
EndDo

If Len(aVetor) == 0
	Aadd(aVetor,{.F.,Ctod("  /  /  "),0000," "," "," "," "," "," ",0," "})
EndIf

Asort(aVetor,1,,{|x,y|Dtos(x[2])+Str(x[3])+x[4]+x[5]+x[6] > Dtos(y[2])+Str(y[3])+y[4]+y[5]+y[6] })

oLbTexto:SetArray(aVetor)
oLbTexto:bLine := { || { If(aVetor[oLbTexto:nAt,1],oOk,oNo) ,;
Dtoc(aVetor[oLbTexto:nAt,2]) ,;
Transform(aVetor[oLbTexto:nAt,3],"@R 99:99") ,;
aVetor[oLbTexto:nAt,4] ,;
aVetor[oLbTexto:nAt,5] ,;
aVetor[oLbTexto:nAt,6] ,;
aVetor[oLbTexto:nAt,7] ,;
aVetor[oLbTexto:nAt,8] ,;
aVetor[oLbTexto:nAt,9] ,;
Str(aVetor[oLbTexto:nAt,10]) ,;
aVetor[oLbTexto:nAt,11]}}

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_MARCA900 Autor ³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca a marca                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MARCA900(lMarca)

Local i := 0

For i:=1 to Len(aVetor)
	aVetor[i,1] := lMarca
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_ALTE900³ Autor ³  Renata \ Fabio       ³ Data ³ 01/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a Data/Hora/Usuario que cancelou o pedido            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ALTE900()

Local ni := 0

For ni:=1 to Len(aVetor)
	
	If aVetor[ni,1] .And. !Empty(aVetor[ni,2])
		
		DbSelectArea("VE6")
		DbSeek( xFilial("VE6") + If(nTipCon==1,"0","1") + Dtos(aVetor[ni,2]) + Str(aVetor[ni,3],4) + aVetor[ni,4] + aVetor[ni,8] + aVetor[ni,9] )
		
		RecLock("VE6",.F.)
		VE6->VE6_DATEXC:=dDataBase
		VE6->VE6_HOREXC:=Val(Substr(Time(),1,2)+Substr(Time(),4,2))
		VE6->VE6_USUEXC:=__cUserID
		MsUnLock()
		
	EndIf
	
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VALIND ³ Autor ³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Transfere de almoxarifado de acordo com o MV_PAR01          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALIND(lOPM900Val,lOPM900Rel)

Local aItensNew := {} , aSaldo := {}
Local lReturn := .t.
Local nX	  := 0
Local cAglSug := GetNewPar("MV_MIL0053","S")
Local cAtualiza := .f.
Local cCodigo   := ""
Local cFJClassif := ""

Local aItemMov := {}
Local oEst     := DMS_Estoque():New()

Private aMemos
Private lMsHelpAuto , lMsErroAuto, lMsFinalAuto := .f.

Default lOPM900Val := .f.
Default lOPM900Rel := .f.


oPedido := DMS_Pedido():New()
If TYPE('M->VE6_FORPED') != "U" .AND. M->VE6_FORPED == oPedido:GtTpPedBO() .AND. M->VE6_INDREG != '4' /* Backorder */
	MsgInfo(STR0054 /* "Para sugestão de backorder utilizar tipo 4 ('Backorder') ou utilize o painel de orçamento " */, STR0032 /* Atenção */)
	return .f.
EndIf

If Type("M->VE6_QTDITE") # "U"
	If M->VE6_QTDITE == 0
		Return( .t. )
	Endif
Endif

if Type("M->VE6_GRUITE") # "U" .and. Type("M->VE6_CODITE") # "U"
	cGruite := M->VE6_GRUITE
	cCodite := M->VE6_CODITE
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FNC 4436/2009                                                        ³
//³Rubens - 11/09/2009                                                  ³
//³Validacao de Req. de Compra, Origem = Oficina e Forma requer Num. OS ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if M->VE6_INDREG == "0" .OR. M->VE6_INDREG == "4"
	DbSelectArea("VEJ")
	DbSetOrder(1)
	If DbSeek( xFilial("VEJ") + M->VE6_CODMAR + M->VE6_FORPED )
		if empty(M->VE6_NUMOSV) .and. VEJ->VEJ_PEDOSV == "1"
			help(" ",1,"OFIPM90003") //ordem de serico nao informada
			return(.f.)
		endif
	endif
endif

if FG_SEEK("SB1","cGruite+cCodIte",7,.f.)
	
	If M->VE6_INDREG == "2" .Or. M->VE6_INDREG == "3"
		SB2->(dbSetOrder(1))
		SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")))
		nSaldo := SaldoSB2()
		
		//aSaldo := CalcEst(SB1->B1_COD,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"),dDataBase+1)
		
		if nSaldo <= 0
			MsgInfo(STR0030+SB1->B1_DESC+STR0031,STR0032) //"Produto -> "###" sem Estoque, Verifique..."###"Atencao!"
			Return( .f. )
		Endif
		
	EndIf
	
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para validaca   					       		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("OFIPMCHK") )
	lReturn := ExecBlock("OFIPMCHK",.F.,.F.,{lReturn})
	If !lReturn
		return .f.
	EndIf
EndIf

lMsErroAuto := .f.
lMsHelpAuto := .t.

Begin Transaction

DbSelectArea("SB2")
DbSetOrder(1)

DbSelectArea("SB1")
DbSetOrder(7)
DbSeek( xFilial("SB1") + M->VE6_GRUITE + M->VE6_CODITE )
DbSetOrder(1)

DbSelectArea("SB5")
DbSetOrder(1)
DbSeek( xFilial("SB5") + SB1->B1_COD )

If !FM_PILHA("OFIXX001") .AND. (M->VE6_INDREG == "2" .Or. M->VE6_INDREG == "3")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Movimentacao interna do Item                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aItensNew:={}
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	//
	// Adiciona cabecalho com numero do documento e data da transferencia modelo II
	//
	aadd (aItensNew,{ nextnumero("SD3",2,"D3_DOC",.t.), ddatabase})
	
	// sequencia
	// produto, descricao, unidade de medida, local/localizacao origem
	// produto, descricao, unidade de medida, local/localizacao destino
	// numero de serie, lote, sublote, data de validade, qunatidade
	// quantidade na 2 unidade, estorno, numero de sequencia

	aItemMov := oEst:SetItemSD3(SB1->B1_COD          ,; //Código do Produto
								FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")  ,; // Armazém de Origem
								GetMv("MV_BLQITE")   ,; // Armazém de Destino
								FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2") ,; // Localização Origem
								GetMv("MV_BLQLOC")   ,; // Localização Destino
								M->VE6_QTDITE        ,; // Qtd a transferir
								M->VE6_LOTECT        ,; // Nro de lote
								M->VE6_NUMLOT        ,; // Nro de Sub-Lote
								M->VE6_NUMSER         ) // Nro de Série

	aAdd(aItensNew, aClone(aItemMov))

	If (ExistBlock("OF900AP"))
		aItensNew := ExecBlock("OF900AP", .f., .f., {aItensNew})
	EndIf

	MSExecAuto({|x| MATA261(x)},aItensNew)
	
	If lMsErroAuto
		&& Cancela Gravacao
		DisarmTransaction()
		Break
	EndIf
	
EndIf

If M->VE6_INDREG == "0" .OR. M->VE6_INDREG == "4" //.And. SB1->B1_FLAGSUG == "1" .And. SB1->B1_CLASSVE == "1"
	
	// lOPM900Val tratar para que o sistema nao mostra a tela de parametros para cada item do orcamento quando chamado pelo orçamento
	// ou pelo painel do orçamento
	If !lOPM900Val
		ValidPerg("MTA297M")
		Pergunte("MTA297M",.t.)
	Endif	
	aConsumo := aConsumoSC( Str(Year( dDataBase),2) + Str(Month( dDataBase),2) )
	nAtual   :=len(aConsumo) + 1
	
	
	if GetMv("MV_ULTPED",.T.,)   
		cCodigo := GETMV("MV_ULTPED")
	Else
		cCodigo := "000001"
	Endif	
	DbSelectArea("VEJ")
	DbSetOrder(1)
	If DbSeek( xFilial("VEJ") + M->VE6_CODMAR + M->VE6_FORPED )
		cCodigo := 	VEJ->VEJ_ULTPED
	EndIf
	
	DbSelectArea("SFJ")
	DbSetOrder(1)
	// lOPM900Val tratar para que caso o parametro MV_MIL0053 estaja configurado para nao aglutinar em uma sugestao de 
	// sugestao de compra ja existente o sistema nao gera uma numeração para cada item do orçamento.
	if DbSeek( xFilial("SFJ") + cCodigo ) .and. (cAglSug == "S" .or. lOPM900Val); 
		.And. ( Empty(SFJ->FJ_SOLICIT);
		.And. Empty(SFJ->FJ_FORNECE);
		.And. Empty(SFJ->FJ_LOJA) ;
		.And. Empty(SFJ->FJ_FILENT) ;
		.And. Empty(SFJ->FJ_COND) .and. ( VEJ->VEJ_PROGRA != "2" .or. M->VE6_INDREG == "4")  )

		If !Softlock("SFJ")
			lMsErroAuto := .t.
			DisarmTransaction()
			Break
		EndIf

		cCodigo  := SFJ->FJ_CODIGO 
		cAtualiza := .f.
		
	Else
		
		cCodigo  := CriaVar("FJ_CODIGO",.T.)
		DbSelectArea("SFJ")
		ConfirmSX8()
		
		DbSelectArea("VEJ")
		If Found()
			RecLock("VEJ",.f.)
			VEJ->VEJ_ULTPED := cCodigo
			MsUnLock()
		EndIf
		cAtualiza := .t.
		
		/*		DbSelectArea("SX6")
		DbSetOrder(1)
		DbSeek( xFilial("SX6") + "MV_ULTPED" )
		RecLock("SX6",.f.)
		SX6->X6_CONTEUD := cCodigo
		SX6->X6_CONTSPA := cCodigo
		SX6->X6_CONTENG := cCodigo
		MsUnLock()
		*/
		
		PutMv("MV_ULTPED",cCodigo)
		
	EndIf
	
	DbSelectArea("SFJ")
	DbSetOrder(1)
	If !DbSeek( xFilial("SFJ") + cCodigo )

		RecLock("SFJ",.T.)
		SFJ->FJ_FILIAL  := xFilial("SFJ")
		SFJ->FJ_CODIGO  := cCodigo
		SFJ->FJ_FORPED  := M->VE6_FORPED
		SFJ->FJ_DATREF  := dDataBase
		SFJ->FJ_DIASSUG := 1
		SFJ->FJ_CUSUNIT := Str(MV_PAR02,1)
		SFJ->FJ_TIPPRC  := Str(MV_PAR03,1)
		SFJ->FJ_IMPORT  := Str(MV_PAR05,1)
		SFJ->FJ_TIPPED  := M->VE6_FORPED // antes não gravava, agora no backorder vai gravar
		
		If Alltrim(MV_PAR04) == "*"
			SFJ->FJ_CLASSIF := "AA/AB/AC/BA/BB/BC/CA/CB/CC/"
		Else
		   cFJClassif	:= ""
			For nX:=1 to Len(AllTrim(MV_PAR04)) Step 3
				cFJClassif += Upper(SubStr(MV_PAR04,nX,2))+"/"
			Next
			SFJ->FJ_CLASSIF := cFJClassif
		EndIf
		
		SFJ->FJ_ANO     := Left(Dtos(dDataBase),4)
		SFJ->FJ_MES     := Strzero(Month(dDataBase),2)
		SFJ->FJ_GRUPODE := left(MV_PAR07,4)
		SFJ->FJ_GRUPOAT := left(right(Alltrim(MV_PAR07),5),4)
		SFJ->FJ_SOLICIT:=""
		MsUnlock()
		
	EndIf
	
	DbSelectArea("SDF")
	DbSetOrder(1)
	DbSeek( xFilial("SDF") + cCodigo + SB1->B1_COD )
	
	RecLock("SDF",!Found())
	SDF->DF_FILIAL  := xFilial("SDF")
	SDF->DF_CODIGO  := cCodigo
	SDF->DF_FLAG    := "A"
	SDF->DF_PRODUTO := SB1->B1_COD
	SDF->DF_QTDSUG  += M->VE6_QTDITE
	If SDF->DF_QTDSUG < 1
		SDF->DF_QTDSUG := 1
	Endif
	
	IF SB1->B1_QE > 0
		If int(SDF->DF_QTDSUG/SB1->B1_QE) < (SDF->DF_QTDSUG/SB1->B1_QE)
			SDF->DF_QTDSUG := (int(SDF->DF_QTDSUG/SB1->B1_QE) + 1) * SB1->B1_QE
		Else
			SDF->DF_QTDSUG := int(SDF->DF_QTDSUG/SB1->B1_QE) * SB1->B1_QE
		EndIf
	EndIF
	
	If MV_PAR03 == 1
		If SB1->B1_UPRC > 0
			If SDF->DF_QTDINF > 0
				SDF->DF_VLRTOT  := (SDF->DF_QTDINF*SB1->B1_UPRC)
			Else
				SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*SB1->B1_UPRC)
			EndIf
		Else
			SB2->(DbSetOrder(1))
			SB2->(Dbseek(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")))
			If SDF->DF_QTDINF > 0
				SDF->DF_VLRTOT  := (SDF->DF_QTDINF*SB2->B2_CM1)
			Else
				SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*SB2->B2_CM1)
			EndIf
		Endif
	ElseIF MV_PAR03 == 2
		SB5->(Dbseek(xFilial("SB5")+SB1->B1_COD))
		If SDF->DF_QTDINF > 0
			SDF->DF_VLRTOT  := (SDF->DF_QTDINF*SB5->B5_PRV2)
		Else
			SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*SB5->B5_PRV2)
		EndIf
	Else
		If SDF->DF_QTDINF > 0
			SDF->DF_VLRTOT  := (SDF->DF_QTDINF*FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1"))
		Else
			SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1"))
		EndIf
		
	EndIF
	
	If SDF->DF_VLRTOT < 0.01
		SDF->DF_VLRTOT := 0.01
	Endif
	
	If M->VE6_INDREG == "4"
		SDF->DF_QTDINF := SDF->DF_QTDSUG
	Else
		SDF->DF_QTDINF  := 0
	EndIf
	
	SDF->DF_M03     := (aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/3
	SDF->DF_M12     := (aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3]+aConsumo[nAtual-4]+;
	aConsumo[nAtual-5]+aConsumo[nAtual-6]+aConsumo[nAtual-7]+aConsumo[nAtual-8]+;
	aConsumo[nAtual-9]+aConsumo[nAtual-10]+aConsumo[nAtual-11]+aConsumo[nAtual-12])/12
	If SB1->B1_QE == 0
		SDF->DF_QE      := 1
	Else
		SDF->DF_QE      := SB1->B1_QE
	Endif
	SDF->DF_D01     := aConsumo[nAtual-1]
	SDF->DF_D02     := aConsumo[nAtual-2]
	SDF->DF_D03     := aConsumo[nAtual-3]
	SDF->DF_D04     := aConsumo[nAtual-4]
	SDF->DF_D05     := aConsumo[nAtual-5]
	SDF->DF_D06     := aConsumo[nAtual-6]
	SDF->DF_D07     := aConsumo[nAtual-7]
	SDF->DF_D08     := aConsumo[nAtual-8]
	SDF->DF_D09     := aConsumo[nAtual-9]
	SDF->DF_D10     := aConsumo[nAtual-10]
	SDF->DF_D11     := aConsumo[nAtual-11]
	SDF->DF_D12     := aConsumo[nAtual-12]
	
	MsUnlock()
	
	Pergunte("OFI900",.f.)
	
EndIf

RecLock("VE6" , .T. ) 

FG_GRAVAR("VE6")   
VE6_SUGCOM := SFJ->FJ_CODIGO
If M->VE6_INDREG == "2"     && Bloqueio de Itens
   VE6_VALPEC := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1")
   VE6_QTDBLQ := M->VE6_QTDITE
Endif

aMemos := {{"VE6_OBSMEM","VE6_OBSERV"}}
cVar := aMemos[1][2]
MSMM(,TamSx3("VE6_OBSERV")[1],,&cVar,1,,,"VE6","VE6_OBSMEM")

MsUnLock()

End Transaction

SFJ->(MsUnlock()) // Unlock do SoftLock

lMsHelpAuto := .f.

lOPM900Rel := .t.
If !FM_PILHA("OFIXX001") .or. (VEJ->VEJ_PROGRA == "2" .and. M->VE6_INDREG <> "4")
	if cAtualiza
		if !Empty(cCodigo)
			MsgInfo(STR0051+CHR(13)+ CHR(10)+STR0052+cCodigo)
		Endif	
	Else
		if !Empty(cCodigo)
			MsgInfo(STR0053+CHR(13)+ CHR(10)+STR0052+cCodigo)
		Endif	
	Endif	
Else
	cOPM900Sug := cCodigo
Endif
If ExistBlock("OF900DGR")
   ExecBlock("OF900DGR",.f.,.f.,)
Endif

If lMsErroAuto
	MostraErro()
EndIf

Return( !lMsErroAuto )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VEFATPAR³ Autor³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o tipo de tpo esta na os                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VEFATPAR(lValida)

FG_SEEK("VOI","M->VE6_TIPTEM",1,.F.)
lValida := If(lValida # NIL,FG_TIPTPFAT(M->VE6_TIPTEM,"M->VE6_FATPAR","M->VE6_LOJA","M->VE6_NOMCLI",Posicione("VV1",1,xFilial("VV1")+VO1->VO1_CHAINT,"VV1_CODMAR"),"P",M->VE6_NUMOSV,.f.),FG_TIPTPFAT(M->VE6_TIPTEM,,,,,,,,.f.))

Return(lValida)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VLPM900³ Autor ³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao dos dados                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VLPM900()

If type("M->VE6_FORPED") != "U"
	if M->VE6_FORPED = "03" //UNID. PARADA
		Return(FG_VALPEC(M->VE6_TIPTEM,,M->VE6_GRUITE,M->VE6_CODITE,,.t.))
	elseif M->VE6_INDREG # "0" .AND. M->VE6_INDREG # "4"
		return(.f.)
	endif
EndIf

return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VALPOR ³ Autor ³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Traz o valor da peca atraves da formula                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALFOR()
Local lRet := .t.

If OFP8600016 .And. !OFP8600016_VerificacaoFormula(M->VE6_FORMUL)
	lRet := .f.
EndIf

return(lRet.And.FG_SEEK("VEG","M->VE6_FORMUL",1,.F.,"M->VE6_NOMFOR","VEG_DESCRI").and.If(Type("M->VE6_TIPTEM")!= "U",FG_VALPEC(M->VE6_TIPTEM,"M->VE6_FORMUL",M->VE6_GRUITE,M->VE6_CODITE,"M->VE6_VALPEC",.F.),FG_VALPEC("","M->VE6_FORMUL",M->VE6_GRUITE,M->VE6_CODITE,"M->VE6_VALPEC",.F.)))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_TPTPO  ³ Autor ³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se OS existe                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TPTPO()

if FG_SEEK("VO2","M->VE6_NUMOSV+'P'",1,.F.) = .t.
	return(FG_SEEK("VO3","M->VE6_TIPTEM",4,.F.) .and. FS_VEFATPAR(.T.))
elseif FG_SEEK("VO2","M->VE6_NUMOSV+'S'",1,.F.) = .t.
	return(FG_SEEK("VO4","M->VE6_TIPTEM",6,.F.) .and. FS_VEFATPAR(.T.))
else
	return(.f.)
endif

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_ORDSER ³ Autor ³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca pela OS o chassi                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ORDSER()

If Type("M->VE6_FORPED") != "U"
	If M->VE6_FORPED = "03"  //UNID.PARADA
		
		If FG_SEEK("VO1","M->VE6_NUMOSV",1,.F.,"M->VE6_CHAINT","VO1_CHAINT")
			
			FG_SEEK("VV1","M->VE6_CHAINT",1,.F.,"M->VE6_CHASSI","VV1_CHASSI")
			
			Return( .t. )
			
		Else
			
			Return( .f. )
			
		EndIF
		
	Else
		
		Return( .t. )
		
	EndIf
EndIf

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_ORIREQ ³ Autor ³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca a descricao da origem da requisicao                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ORIREQ()

if M->VE6_INDREG = "0" .OR. M->VE6_INDREG = "4"
	
	M->VE6_DESORI := if(M->VE6_ORIREQ="1",OemtoAnsi("BALCAO"),OemtoAnsi("OFICINA"))     //,
	
	return( !empty(M->VE6_ORIREQ) .And. PERTENCE("12") )
	
else
	
	return(.t.)
	
endif

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFMI900  ³ Autor ³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica cpos nao obrigatorios, mas necessarios            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_REQCOP()

if M->VE6_INDREG = "0" .OR. M->VE6_INDREG = "4"
	
	if empty(M->VE6_ORIREQ)
		help(" ",1,"OFIPM90001") //sem origem da requisicao
		return(.f.)
	endif
	
	if empty(M->VE6_FORPED)
		help(" ",1,"OFIPM90002") //forma do pedido nao informada
		return(.f.)
	endif
	
	if empty(M->VE6_NUMOSV) .and.  M->VE6_FORPED=="03"  //UP
		help(" ",1,"OFIPM90003") //ordem de serico nao informada
		return(.f.)
	endif
	
endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFMI900  ³ Autor ³  Renata \ Fabio       ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Descricao do Produto                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_DESCVE6()

Local cAliasAnt :=Alias()
Local cRet := " "

If Type("cGruIte") # "U" .and. Type("cCodIte") # "U"
	DbSelectArea("SB1")
	DbSetOrder(7)
	If DbSeek(xFilial("SB1")+cGruIte+cCodIte)
		cRet := B1_DESC
	EndIf
EndIf

DbSelectArea(cAliasAnt)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CLI    ³ Autor ³  Renata               ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Para saber emqual assunto sera usado o cpo codcli - when   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CLI()

if M->VE6_INDREG = "0" .and. val(M->VE6_NUMOSV) = 0
	return(.t.)
elseif M->VE6_INDREG = "3"
	return(.t.)
endif

return(.f.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ----ÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VALOFIPM900³ Autor ³ Ednilson          ³ Data ³ 15/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ----ÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao criada por falta de espaco no atusx                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALOFIPM900()

If (M->VE6_INDREG # "0" .AND. M->VE6_INDREG # "4") .OR. M->VE6_ORIREQ == "1" 
	Return(.f.)
EndIf

If VEJ->VEJ_PEDOSV # "1"
	Return(.f.)
Endif

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aConsumoSC³ Autor ³ Alex Sandro Valario   ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acumula no Array aConsumo a demanda dos produtos			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function aConsumoSC(cAnoMes)
Local nX,nLen
Local nRecnoSBL :=SBL->(Recno())
Local nOrdemSBL :=SBL->(IndexOrd())
Local cPAnoMes:=""
Local aConsumo :={}
SBL->(DBSetOrder(1))
SBL->(DBSeek(xFilial("SBL")+SB1->B1_COD))
While (! SBL->(Eof()) .and. xFilial("SBL")==SBL->BL_FILIAL .and. SBL->BL_PRODUTO ==SB1->B1_COD);
	.And. SBL->BL_ANO+SBL->BL_MES <= cAnoMes
	
	Aadd(aConsumo,SBL->BL_DEMANDA)
	cPAnoMes := SBL->(BL_ANO+BL_MES)
	SBL->(DbSkip())
	If ! SBL->(Eof()) .and. SBL->BL_PRODUTO ==SB1->B1_COD
		IF Right(cPAnoMes,2)=="12"
			cPAnoMes := Str(Val(Left(cPAnoMes,4))+1,4)+"01"
		Else
			cPAnoMes := Left(cPAnoMes,4)+StrZero(Val(Right(cPAnoMes,2))+1,2)
		Endif
		While cPAnoMes < SBL->(BL_ANO+BL_MES)
			Aadd(aConsumo,0 )
			IF Right(cPAnoMes,2)=="12"
				cPAnoMes := Str(Val(Left(cPAnoMes,4))+1,4)+"01"
			Else
				cPAnoMes := Left(cPAnoMes,4)+StrZero(Val(Right(cPAnoMes,2))+1,2)
			EndIf
		End
	EndIf
End
SBL->(DbSetOrder(nOrdemSBL))
SBL->(DbGoto(nRecnoSBL))
nLen :=len(aConsumo)
If Len(aConsumo) < 120
	For nX := 1 to 120-nLen
		aadd(aConsumo,0)
		aIns(aConsumo,1)
		aConsumo[1] := 0
	Next
EndIf
Return aConsumo   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GRAVALOTE ³ Autor ³ Thiago				³ Data ³ 01/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava campo lote e sub-lote								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GRAVALOTE()

 if readvar() $ "M->VE6_LOTECT,M->VE6_NUMLOT"
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFiliaL("SB1")+M->VE6_GRUITE+M->VE6_CODITE)
	F4LOTE(,,,"OPM900",SB1->B1_COD,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"))
endif       

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MenuDef   ³ Autor ³ Alex Sandro Valario   ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Criacao do menu arotina									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},;      //PESQUISAR
{ STR0002 ,"OFMV900", 0 , 2},;    //VISUALIZAR
{ STR0003 ,"OFMI900", 0 , 3},;   	//INCLUIR
{ STR0004 ,"OFME900", 0 , 4},;   	//EXCLUIR
{ STR0037 ,"OFP900L", 0 , 2,0,.f.}}	//LEGENDA
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OFP900L   ³ Autor ³ Alex Sandro Valario   ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Criacao da legenda       								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFP900L()
Local aLegenda  := {{ 'BR_VERDE'   , STR0033 } ,;	// Requisicao de Compras
					{ 'BR_VERMELHO', STR0034 } ,;	// Vendas Perdidas
					{ 'BR_AZUL'    , STR0035 } ,;	// Bloqueio de Item
					{ 'BR_PRETO'   , STR0036 } }	// Reserva de Item

BrwLegenda(cCadastro,STR0037 ,aLegenda)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OFP900PM  ³ Autor ³ Luis Delorme          ³ Data ³ 27/03/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Criacao da legenda       								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFP900PM()

DBSelectArea("SBM")
DBSetOrder(1)
if DBSeek(xFilial("SBM")+M->VE6_GRUITE)
	M->VE6_CODMAR := SBM->BM_CODMAR
endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ValidPerg ³ Autor ³ Alex Sandro Valario   ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Criacao das perguntes       								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg(cPergMil)
Local _sAlias := Alias()
Local aRegs := {}
Local i,j
dbSelectArea("SX1")
dbSetOrder(1)
cPergMil := left(cPergMil+space(15),len(SX1->X1_GRUPO))

Aadd(aRegs,{cPergMil,"01",STR0038  ,"","","mv_ch1","N",3 ,0,0,"G","(mv_par01 > 0)","mv_par01","","","","60","","","","","","","","","","","","","","","","","","","","","","S","","","","" } )
Aadd(aRegs,{cPergMil,"02",STR0039  ,"","","mv_ch2","N",1 ,0,4,"C","","mv_par02","Alto","Alto","High","","mv_par02","Medio","Promedio","Average","","mv_par02","Baixo","Bajo","Low","","mv_par02","Todos","Todos","All","","","","","","","","S","","","","" } )
Aadd(aRegs,{cPergMil,"03",STR0040  ,"","","mv_ch3","N",1 ,0,2,"C","","mv_par03","UltPrc / CusMd","","","","mv_par03","Reposicao","Precio de Venta","Sales Price","","mv_par03","Preco de Venda","Reposicion","Replacement","","","","","","","","","","","","","S","","","","" } )
Aadd(aRegs,{cPergMil,"04",STR0041  ,"","","mv_ch4","C",18,0,0,"G","","mv_par04","","","","AA/AB/AC/BA/BB/BC/","","","","","","","","","","","","","","","","","","","","","","S","","","","" } )
Aadd(aRegs,{cPergMil,"05",STR0042  ,"","","mv_ch5","N",1 ,0,2,"C","","mv_par05","Sim","Si","Yes","","mv_par05","Nao","No","No","","","","","","","","","","","","","","","","","","S","","","","" } )
Aadd(aRegs,{cPergMil,"06",STR0043  ,"","","mv_ch6","N",1 ,0,1,"C","FS_GRP_TSUGEST()","mv_par06","Original","Original","Original","","","Nao Original","Nao Original","Nao Original","","","Ambos","Ambos","Ambos","","","","","","","","","","","","","S","","","","" } )
Aadd(aRegs,{cPergMil,"07",STR0044  ,"","","mv_ch7","C",99,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SBM","S","","","","" } )
Aadd(aRegs,{cPergMil,"08",STR0045  ,"","","mv_ch8","C",15,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SB1","S","","","","" } )
Aadd(aRegs,{cPergMil,"09",STR0046  ,"","","mv_ch9","C",15,0,0,"G","","mv_par09","","","","ZZZZZZZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","SB1","S","","","","" } )
Aadd(aRegs,{cPergMil,"10",STR0047  ,"","","MV_CHA","C",99,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
Aadd(aRegs,{cPergMil,"11",STR0048  ,"","","MV_CHB","N",2 ,0,0,"G","","mv_par11","","","","12","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
Aadd(aRegs,{cPergMil,"12",STR0049  ,"","","MV_CHC","N",2 ,0,0,"G","If(MV_PAR12 <= MV_PAR11,.T.,.F.)","mv_par12","","","","6","","","","","","","","","","","","","","","","","","","","","","","","","","" } )

For i:=1 to Len(aRegs)
	If !dbSeek(cPergMil+aRegs[i,2])
		RecLock("SX1",.t.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_sAlias)
Return

/*----------------------------------------------------
 Suavizar a nova verificação de integração com o WMS
------------------------------------------------------*/
Static Function a261IntWMS(cProduto)
Default cProduto := ""
	If FindFunction("IntWMS")
		Return IntWMS(cProduto)
	Else
		Return IntDL(cProduto)
	EndIf
Return