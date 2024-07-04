#Include "Protheus.ch"
#Include "VEIVC120.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVC120 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 03/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ ESTOQUE VIRTUAL POR MODELO                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVC120()
Private lImprimir := .t.
Private cCodMar := space(3)
Private cGruVei := space(6)
Private cModVei := space(30)
Private aModelos := {}
Private lAltQtd := ( __CUSERID $ GetNewPar("MV_USCDESV"," ") )
#IFDEF TOP
	If !FS_VERBASE() // Verifica a existencia dos arquivos envolvidos na Consulta
		MsgAlert(STR0001 ,STR0002 ) //Nao existem dados para esta Consulta ! # Atencao
		Return
	EndIf
	Processa( {|| FS_LEVANT(0) } ) // Levanta Modelos e Qtdes.
	DbSelectArea("VE1")
	DbSelectArea("VVR")
	DbSelectArea("VV2")
	DEFINE MSDIALOG oEstVirt FROM 000,000 TO 29,80 TITLE (STR0003) OF oMainWnd //Estoque Virtual por Modelo
		@ 017,001 LISTBOX oLbMod FIELDS HEADER OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007) COLSIZES 30,50,160,50 SIZE 315,201 OF oEstVirt PIXEL ON DBLCLICK FS_LEVANT(2)  //Marca # Grupo # Modelo # Qtd.Atual
		oLbMod:SetArray(aModelos)                                         
		oLbMod:bLine := { || { aModelos[oLbMod:nAt,1] , aModelos[oLbMod:nAt,2] , aModelos[oLbMod:nAt,3] , FG_AlinVlrs(Transform(aModelos[oLbMod:nAt,4],"@E 999,999,999,999")) }}
		@ 000,001 TO 016,237 LABEL STR0008 OF oEstVirt PIXEL //Filtrar
	   @ 006,005 SAY STR0009 SIZE 25,06 OF oEstVirt PIXEL COLOR CLR_BLUE //Marca:
   	@ 005,022 MSGET oCodMar VAR cCodMar F3 "VE1" VALID (FS_REFRIMP(.F.)) SIZE 20,06 OF oEstVirt PIXEL COLOR CLR_BLUE
	   @ 006,054 SAY STR0010 SIZE 25,06 OF oEstVirt PIXEL COLOR CLR_BLUE //Grupo:
   	@ 005,071 MSGET oGruVei VAR cGruVei F3 "VVR" VALID (FS_REFRIMP(.F.)) SIZE 45,06 OF oEstVirt PIXEL COLOR CLR_BLUE
	   @ 006,119 SAY STR0011 SIZE 25,06 OF oEstVirt PIXEL COLOR CLR_BLUE //Modelo:
   	@ 005,138 MSGET oModVei VAR cModVei F3 "VV2" VALID (FS_REFRIMP(.F.)) SIZE 68,06 OF oEstVirt PIXEL COLOR CLR_BLUE
		@ 005,210 BUTTON oOk PROMPT STR0012 OF oEstVirt SIZE 22,10 PIXEL ACTION Processa( {|| FS_LEVANT(1) } ) //< OK >
		@ 004,244 BUTTON oImp PROMPT STR0013 OF oEstVirt SIZE 30,10 PIXEL ACTION FS_IMPRIMIR() WHEN lImprimir //Imprimir
		@ 004,281 BUTTON oSAIR PROMPT STR0014 OF oEstVirt SIZE 30,10 PIXEL ACTION oEstVirt:End() //SAIR
	ACTIVATE MSDIALOG oEstVirt CENTER
#ENDIF
Return()

Static Function FS_LEVANT(nx) // Levantamento/Atualizacao dos Modelos/Qtdes //
Local cQuery  := ""
Local cQAlias := "SQLVV2"
Local lOk     := .f.
Local cXMar   := ""
Local cXGru   := ""
Local cXMod   := ""
Local nXQtd   := 0
Local nXAtu   := 0
Local ni      := 1
If nx < 2
// Levantamento do Estoque por Modelo //
	aModelos := {}
	cQuery := "SELECT VV2.VV2_CODMAR , VV2.VV2_GRUMOD , VV2.VV2_MODVEI , VV2.VV2_QTDATU FROM "+RetSqlName("VV2")+" VV2  WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND "
	If !Empty(cCodMar)
		cQuery += "VV2.VV2_CODMAR='"+cCodMar+"' AND "
	EndIf
	If !Empty(cGruVei)
		cQuery += "VV2.VV2_GRUMOD='"+cGruVei+"' AND "
	EndIf
	If !Empty(cModVei)
		cQuery += "VV2.VV2_MODVEI='"+cModVei+"' AND "
	EndIf
	cQuery += "VV2.D_E_L_E_T_=' ' ORDER BY VV2.VV2_CODMAR , VV2.VV2_GRUMOD , VV2.VV2_MODVEI "

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	Do While !( cQAlias )->( Eof() )
		aadd(aModelos,{ ( cQAlias )->( VV2_CODMAR ) , ( cQAlias )->( VV2_GRUMOD ) , ( cQAlias )->( VV2_MODVEI ) , ( cQAlias )->( VV2_QTDATU ) })
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
	If len(aModelos) <= 0
		Aadd(aModelos,{ "" , "" , "" , 0 })
	EndIf
Else
//Tela para preencher Qtd.Atual //
	If lAltQtd
		ni    := oLbMod:nAt
   	cXMar := aModelos[oLbMod:nAt,1]
   	cXGru := aModelos[oLbMod:nAt,2]
   	cXMod := aModelos[oLbMod:nAt,3]
   	nXQtd := aModelos[oLbMod:nAt,4]
   	If !Empty(cXMar+cXMod)
			DEFINE MSDIALOG oAltEst FROM 000,000 TO 011,30 TITLE (STR0015) OF oMainWnd //Inclui Estoque Virtual
			   @ 006,005 SAY STR0009 SIZE 25,06 OF oAltEst PIXEL COLOR CLR_BLUE //marca
	   		@ 005,033 MSGET oXCod VAR cXMar SIZE 82,06 OF oAltEst PIXEL COLOR CLR_BLUE WHEN .f.
			   @ 017,005 SAY STR0010 SIZE 25,06 OF oAltEst PIXEL COLOR CLR_BLUE //grupo
	   		@ 016,033 MSGET oXGru VAR cXGru SIZE 82,06 OF oAltEst PIXEL COLOR CLR_BLUE WHEN .f.
		   	@ 028,005 SAY STR0011 SIZE 25,06 OF oAltEst PIXEL COLOR CLR_BLUE //modelo
		   	@ 027,033 MSGET oXMod VAR cXMod SIZE 82,06 OF oAltEst PIXEL COLOR CLR_BLUE WHEN .f.
		   	@ 039,005 SAY STR0016 SIZE 25,06 OF oAltEst PIXEL COLOR CLR_BLUE //Qtd.Atual:
		   	@ 038,033 MSGET oXQtd VAR nXQtd PICTURE("9999") SIZE 82,06 OF oAltEst PIXEL COLOR CLR_BLUE WHEN .f.
		   	@ 050,005 SAY STR0017 SIZE 25,06 OF oAltEst PIXEL COLOR CLR_BLUE //Incluir:
		   	@ 049,033 MSGET oXAtu VAR nXAtu PICTURE("9999") VALID FS_VALQTD(nXQtd+nXAtu>=0) SIZE 82,06 OF oAltEst PIXEL COLOR CLR_BLUE
				@ 068,017 BUTTON oOk PROMPT STR0012 OF oAltEst SIZE 35,10 PIXEL ACTION (lOk:=.t.,oAltEst:End()) //ok
				@ 068,069 BUTTON oSAIR PROMPT STR0014 OF oAltEst SIZE 35,10 PIXEL ACTION oAltEst:End() //sair
			ACTIVATE MSDIALOG oAltEst CENTER
	   	// Alterar VV2 //
			If lOk
				DbSelectArea("VV2")
	         DbSetOrder(1)
	         If DbSeek( xFilial("VV2") + cXMar + cXMod )
					RecLock("VV2",.f.)
						VV2->VV2_QTDATU := ( nXQtd + nXAtu )
					MsUnLock()
	         	aModelos[oLbMod:nAt,4] := VV2->VV2_QTDATU
	         	If ni >= len(aModelos)
	         		ni := 1
	         	Else
	         		ni++	         	
	         	EndIf
				EndIf
			EndIf
		EndIf
	Else
		MsgStop(STR0018 ,STR0002) //Usuario sem permissao para INCLUIR a quantidade do Estoque Virtual. # Atencao
		nx := 0
	EndIf
EndIf
If nx > 0
	FS_REFRIMP(.T.)
	oLbMod:nAt := ni
	oLbMod:SetArray(aModelos)
	oLbMod:bLine := { || { aModelos[oLbMod:nAt,1] , aModelos[oLbMod:nAt,2] , aModelos[oLbMod:nAt,3] , FG_AlinVlrs(Transform(aModelos[oLbMod:nAt,4],"@E 999,999,999,999")) }}
	oLbMod:SetFocus()
	oLbMod:Refresh()
EndIf
Return(.t.)

Static Function FS_REFRIMP(lTipo) // WHEN do Botao Imprimir // 
lImprimir := lTipo
oImp:Refresh()
return(.t.)

Static Function FS_VALQTD(lRet) // Valida Quantidade Negativa //
If !lRet                             								
	MsgStop(STR0019 +CHR(13)+CHR(10)+CHR(13)+CHR(10)+ STR0020 ,STR0002) //Qtde Digitada Invalida # Estoque Virtual nao pode ser negativo # Atencao
EndIf
Return(lRet)

Static Function FS_VERBASE() // Verifica a Base da Empresa para realizar a Consulta //
Local cQuery  := ""
Local cQAlias := "SQLERRO"
Local lOk     := .t.
Private bBlock:= ErrorBlock()
Private bErro := ErrorBlock( { |e| lOk := .f. } )
If (VV2->(FieldPos("VV2_QTDATU"))<>0)
	cQuery := "SELECT VV2.VV2_CODMAR FROM "+RetSqlName("VV2")+" VV2  WHERE VV2.VV2_CODMAR='1'"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	( cQAlias )->( dbCloseArea() )
Else
	lOk := .f.
EndIf
ErrorBlock(bBlock)
Return(lOk)

Static Function FS_IMPRIMIR() // Imprimir
	Local ni := 0
	Private cDesc1 := ""
	Private cDesc2 := ""
	Private cDesc3 := ""
	Private tamanho:= "P"
	Private limite := 80
	Private cString:= "VV2"
	Private titulo := STR0003 //Estoque Virtual por Modelo"                               
	Private cabec1 := IIF(!Empty(cCodMar+cGruVei+cModVei),STR0021 +": "+cCodMar+"  "+ STR0010 +" "+cGruVei+"  "+ STR0011 +" "+cModVei,"")//Filtro = Marca # Grupo: # Modelo:
	Private cabec2 := space(9)+ STR0022 //Marca  Grupo   Modelo                            Qtde.Atual
	Private aReturn:= {"",1,"",1,2,1,"",1}  
   Private nomeprog:= "VEIVC120"
	Private nLastKey:= 0
	If Empty(cabec1)
	   cabec1 := cabec2
	   cabec2 := ""
	EndIf
	nomeprog := SetPrint(cString,nomeprog,nil,titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
	If nLastKey == 27
		Return
	EndIf     
	SetDefault(aReturn,cString)
	nLin  := 0
	m_pag := 1
	Set Printer to &nomeprog
	Set Printer On
	Set Device  to Printer
	nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) + 1
	For ni := 1 to len(aModelos)
		If nLin >= 60
			nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) + 1
		EndIf
		@ nLin++, 09 PSAY aModelos[ni,1]+"    "+aModelos[ni,2]+"  "+aModelos[ni,3]+Transform(aModelos[ni,4],"@E 99,999,999,999")
	Next
	Set Printer to
	Set Device to Screen
	If aReturn[5] == 1
	   OurSpool( nomeprog )
	EndIf
	MS_Flush()
Return