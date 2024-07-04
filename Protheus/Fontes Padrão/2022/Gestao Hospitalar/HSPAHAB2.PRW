#INCLUDE "HSPAHAB2.ch"
#INCLUDE "PROTHEUS.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHAB2  บ Autor ณ MARCELO JOSE       บ Data ณ  13/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CADASTRO DE MOTIVOS DE INTERDICAO                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHAB2()
 Private cCadastro := STR0001 //"Cadastro de MOTIVO DE INTERDICAO"
 Private aRotina   := MenuDef()
 Private cDelFunc  := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
 Private cString   := "GDI"
 dbSelectArea("GDI")
 dbSetOrder(1)
 dbSelectArea(cString)
 mBrowse( 6,1,22,75,cString)

Return(NIL) 
/****************************************************************************************************************/
Function HS_MOVAB2(cAlias,nReg,nOpc)

Local oDlg	:= NIL
Local lOk 	:= .F.                               

DbSelectArea(cAlias)
RegToMemory("GDI",(nOpc == 3))

aSize := MsAdvSize(.T.)
aObjects := {}	
AAdd( aObjects, { 100, 100, .T., .T. } )	
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )
 
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) From aSize[7],0 TO aSize[6]+25,aSize[5]	PIXEL of oMainWnd
 
 oEnchoice:=MsMGet():New("GDI",nReg,nOpc, , , , ,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, , , , ,,oDlg)
 oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT
 
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||lOk := HS_AB2TudOk(), Iif(lOk,oDlg:End(),)},{||lOk := .F. ,oDlg:End()}, , )
If lOk .and. (nOpc == 3 .or. nOpc == 4 .or. nOpc == 5)
 ConfirmSx8()
	FS_AB2Grav(nOpc)
Else
	RollBackSxe()
Endif
Return(NIL)

/*****************************************************************************************************************/
Static Function FS_AB2Grav(nOpc)

Local lGraOk	:= .T.
Local nCont		:= 0
Local nCpo
Local bCampo	:= { |nCPO| Field(nCPO) }

DbSelectArea("GDI")
DbSetOrder(1)

Begin Transaction

If (nOpc == 3 .or. nOpc == 4)
	
	If nOpc == 4
		RecLock("GDI",.F.)
	Else
		RecLock("GDI",.T.)
	Endif
	
	For nCont := 1 To FCount()
		
		If "FILIAL"$Field(nCont)
			FieldPut(nCont,xFilial("GDI"))
		Elseif "LOGARQ"$Field(nCont)
			FieldPut(nCont,HS_LOGARQ())
		Else
			FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
		Endif
		
	Next nCont

	MsUnlock()	

Elseif nOpc == 5
 DbSelectArea("GAV")
 DBSetOrder(7) //GAV/7
 If !DbSeek(xFilial("GAV") + GDI->GDI_CODIGO ) 
 	RecLock("GDI",.F.)
 	DbDelete()
	 MsUnlock()
	Else
 	HS_MsgInf(STR0008,STR0009,STR0001) //"Este Codigo esta sendo usado pelo Cadastro de Leito. Impossivel Exclui-lo!" ###"Atencao"###"Cadastro de MOTIVO DE INTERDICAO"
EndIf  
	
Endif

End Transaction

DbSelectArea("GCQ")
DbSetOrder(1)

Return lGraOk

/******************************************************************************************************************/
Function HS_AB2TudOk()

Local lRetorno			:= .T.

If Empty(M->GDI_CODIGO)
	lRetorno := .F.
	HS_MsgInf(STR0010,STR0009,STR0001) //###"Atencao"###"Cadastro de MOTIVO DE INTERDICAO" //"Campos obrigatorios"
Endif
If Empty(M->GDI_DESC)
	lRetorno := .F.
	HS_MsgInf(STR0010,STR0009,STR0001) //###"Atencao"###"Cadastro de MOTIVO DE INTERDICAO" //"Campos obrigatorios"
Endif
Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 11/07/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao                      ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRotina :=	{{STR0002, "AxPesqui" , 0, 1, 0, nil},; //"Pesquisar"
                     {STR0003, "HS_MOVAB2", 0, 2, 0, nil},; //"Visualizar"
                     {STR0004, "HS_MOVAB2", 0, 3, 0, nil},; //"Incluir"
                     {STR0005, "HS_MOVAB2", 0, 4, 0, nil},; //"Alterar"
                     {STR0006, "HS_MOVAB2", 0, 5, 0, nil}}  //"Excluir" 
Return(aRotina)