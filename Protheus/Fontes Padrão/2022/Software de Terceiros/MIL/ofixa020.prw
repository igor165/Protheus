// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 16     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "OFIXA020.CH"
#include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIXA020 ³ Autor ³ Luis Delorme                      ³ Data ³ 25/06/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pedidos de Transferência de Peças                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIXA020()

Local cFiltro := ""

Private cCadastro := STR0001 // Pedidos de Transferência de Peças
Private aRotina   := MenuDef()
Private aCores    := {;
{'VDD->VDD_STATUS == "S"','BR_AMARELO'},;	// Pendente 
{'VDD->VDD_STATUS == "A"','BR_VERDE'},;		// Atendida
{'VDD->VDD_STATUS == "R"','BR_VERMELHO'},;	// Rejeitado
{'VDD->VDD_STATUS == "E"','BR_PRETO'},;		// NF Emitida
{'VDD->VDD_STATUS == "C"','BR_AZUL'} }      // Entrada Confirmada
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//
DBSelectArea("VAI")
DBSetOrder(4)
DBSeek(xFilial("VAI")+__cUserId)

dbSelectArea("VDD")
dbSetOrder(1)

// Ponto de Entrada para Filtro do Browse
If ExistBlock("OX020FBRW")
	cFiltro := ExecBlock("OX020FBRW", .f., .f.)
EndIf

if !Empty(VAI->VAI_TIPTRA)
	cFiltro := "VDD->VDD_STATUS $ VAI->VAI_TIPTRA" + Iif(Empty(cFiltro), "", " .AND. " + cFiltro)
endif

If !Empty(cFiltro)
	FilBrowse("VDD", {}, cFiltro)
EndIf

mBrowse( 6, 1,22,75,"VDD",,,,,,aCores)
dbClearFilter()
//
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA020A  ³ Autor ³ Luis Delorme                      ³ Data ³ 25/06/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para aceitação do pedido de transferência                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA020A(cAlias,nReg,nOpc)
Local nTam       := 0
Local aObjects   := {} , aPosObj := {} , aInfo := {}
Local aSizeAut   := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lCtrlLote  := GetNewPar("MV_RASTRO","N") == "S"   
Local lOkTela    := .f.
Local ni         := 0
Local _ii        := 0
Local nPos       := 0
Local cB1LocPad  := ""
Local cCor       := ""
Local cQuery     := ""
Local cQAlSQL    := "SQLVDD"
Local aParam     := {}
Local lVDD_TIPTRA:= ( VDD->(FieldPos("VDD_TIPTRA")) > 0 )
Local lVS3_TIPTRA:= ( VS3->(FieldPos("VS3_TIPTRA")) > 0 )
Local lVS3_VENTRA:= ( VS3->(FieldPos("VS3_VENTRA")) > 0 )
Local lVS3_QTDAPR:= ( VS3->(FieldPos("VS3_QTDAPR")) > 0 )
Local aVetOrcSld := {}
Local nAteVDD 	 := 0
Local cFaseConfer := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Local lFaseConfer := (At(cFaseConfer,GetMv("MV_FASEORC")) <> 0)

Local oFilHlp := DMS_FilialHelper():New()

Local cTESSai := ""
Local cTESEnt := ""

Local lOX020WHN  := ExistBlock("OX020WHN")
Local cFilBkp	:= cFilAnt

Private oOkTik   := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik   := LoadBitmap( GetResources() , "LBNO" )
Private oVerm    := LoadBitmap( GetResources() , "BR_VERMELHO" )
Private aVDD     := {}

Private aSdPLtDMS := {}

If !OXA200018_ValidaUsuarioTransf()
	Return .F.
EndIf

cMV_PAR01 := Space(TamSX3("VS3_OPER")[1])
cMV_PAR02 := Space(TamSX3("F4_CODIGO")[1])
cMV_PAR03 := Space(TamSX3("F4_CODIGO")[1])
cMV_PAR04 := Space(TamSX3("VS3_FORMUL")[1]) 
// -------------------------------------------------------------------
// PE para carregar os valores dos campos da parambox.
// -------------------------------------------------------------------
If ExistBlock("OX020PAR")
	aParam := ExecBlock("OX020PAR",.f.,.f.) 
	cMV_PAR01 := aParam[1]
	cMV_PAR02 := aParam[2]
	cMV_PAR03 := aParam[3]
	cMV_PAR04 := aParam[4]
EndIf  

cQuery := "SELECT "+IIf(lVDD_TIPTRA,"VDD.VDD_TIPTRA , ","")
cQuery += "VDD.VDD_QUANT , VDD.VDD_FILORC , VDD.VDD_NUMORC , VDD.R_E_C_N_O_ AS RECVDD , SB1.R_E_C_N_O_ AS RECSB1 FROM "+RetSqlName("VDD")+" VDD "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO=VDD.VDD_GRUPO AND SB1.B1_CODITE=VDD.VDD_CODITE AND SB1.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VDD.VDD_FILIAL='"+xFilial("VDD")+"' AND VDD.VDD_STATUS='S' AND VDD.VDD_FILORC='"+VDD->VDD_FILORC+"' AND VDD.D_E_L_E_T_=' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	SB1->(DbGoTo(( cQAlSQL )->( RECSB1 )))
	cB1LocPad := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
	SB2->(DbSetOrder(1))
	SB2->(DbSeek(VDD->VDD_FILORC+SB1->B1_COD+cB1LocPad))
	SB3->(DbSetOrder(1))
	SB3->(DbSeek(VDD->VDD_FILORC+SB1->B1_COD))
	cCor := "2" // CI 010807 - Traz como "não pode ser selecionado", será atualizado após preencher a formula
	aAdd(aVDD,{ cCor , IIf(lVDD_TIPTRA,( cQAlSQL )->( VDD_TIPTRA ),"") , ( cQAlSQL )->( VDD_FILORC ) , ( cQAlSQL )->( VDD_NUMORC ) , SB1->B1_GRUPO , SB1->B1_CODITE , SB1->B1_DESC , ( cQAlSQL )->( VDD_QUANT ) , SaldoSB2() , SB2->B2_CM1 , SB3->B3_CLASSE , SB3->B3_MEDIA , cB1LocPad , ( cQAlSQL )->( RECVDD ) , ( cQAlSQL )->( RECSB1 ) })
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
DbSelectArea("VDD")

If len(aVDD) <= 0
	MsgAlert(STR0035,STR0013) // "Nenhum registro pendente de transferencia foi encontrado para a Filial do Pedido." / "Atenção"
	Return .f.
EndIf

aObjects := {}
AAdd( aObjects, { 05 , 17 , .T. , .F. } )  // Cabecalho
AAdd( aObjects, { 01 , 00 , .T. , .T. } )  // Listbox
AAdd( aObjects, { 05 , 17 , .T. , .F. } )  // Legenda
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlg1 TITLE STR0036  From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL // Aceitar Transferencias de Peças entre Filiais
//
nTam := ( aPosObj[1,4] / 10 )
@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL ("") OF oDlg1 PIXEL // Caixa Cabecalho
@ aPosObj[1,1]+005,aPosObj[1,2]+(nTam*01) SAY STR0029 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE // Tipo de Operacao
@ aPosObj[1,1]+004,aPosObj[1,2]+(nTam*02) MSGET oMV_PAR01 VAR cMV_PAR01 PICTURE "@!" F3 "DJ" VALID OXA020TPOP() SIZE (nTam),08 OF oDlg1 PIXEL COLOR CLR_BLUE HASBUTTON WHEN iif(lOX020WHN,OXA200038_PEOX020WHN(1),.T.)
@ aPosObj[1,1]+005,aPosObj[1,2]+(nTam*03) SAY STR0005 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE // TES SAIDA
@ aPosObj[1,1]+004,aPosObj[1,2]+(nTam*04) MSGET oMV_PAR02 VAR cMV_PAR02 PICTURE "@!" F3 "SF4" VALID OXA020VTES() SIZE (nTam),08 OF oDlg1 PIXEL COLOR CLR_BLUE HASBUTTON WHEN iif(lOX020WHN,OXA200038_PEOX020WHN(2),.T.)
@ aPosObj[1,1]+005,aPosObj[1,2]+(nTam*05) SAY STR0033 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE // TES ENTRADA
@ aPosObj[1,1]+004,aPosObj[1,2]+(nTam*06) MSGET oMV_PAR03 VAR cMV_PAR03 PICTURE "@!" F3 "SF4" VALID OXA020TESE() SIZE (nTam),08 OF oDlg1 PIXEL COLOR CLR_BLUE HASBUTTON WHEN iif(lOX020WHN,OXA200038_PEOX020WHN(3),.T.)
@ aPosObj[1,1]+005,aPosObj[1,2]+(nTam*07) SAY STR0078 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE // FÓRMULA
@ aPosObj[1,1]+004,aPosObj[1,2]+(nTam*08) MSGET oMV_PAR04 VAR cMV_PAR04 PICTURE "@!" F3 "VEG" VALID OXA200028_ValidaFormula(@aVDD) SIZE (nTam),08 OF oDlg1 PIXEL COLOR CLR_BLUE HASBUTTON WHEN iif(lOX020WHN,OXA200038_PEOX020WHN(4),.T.)

//
oLbVDD := TWBrowse():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4]-2,(aPosObj[2,3]-aPosObj[2,1]),,,,oDlg1,,,,,{ || FS_VDDACEIT(oLbVDD:nAt) },,,,,,,.F.,"",.T.,,.F.,,,)
oLbVDD:SetArray(aVDD)
oLbVDD:addColumn( TCColumn():New( "" , { || IIf(aVDD[oLbVDD:nAt,01]=="1",oOkTik,IIf(aVDD[oLbVDD:nAt,01]=="0",oNoTik,oVerm)) }                  ,,,, "LEFT" ,  08 ,.T.,.F.,,,,.F.,) ) // Tik
oLbVDD:addColumn( TCColumn():New( STR0037   , { || IIf(!Empty(aVDD[oLbVDD:nAt,02]),X3CBOXDESC("VDD_TIPTRA",aVDD[oLbVDD:nAt,02]),"") }   ,,,, "LEFT" ,  40 ,.F.,.F.,,,,.F.,) ) // "Tp.Transf."
oLbVDD:addColumn( TCColumn():New( STR0038   , { || aVDD[oLbVDD:nAt,03] }                                                                ,,,, "LEFT" ,  40 ,.F.,.F.,,,,.F.,) ) // "Filial"
oLbVDD:addColumn( TCColumn():New( STR0039   , { || aVDD[oLbVDD:nAt,04] }                                                                ,,,, "LEFT" ,  40 ,.F.,.F.,,,,.F.,) ) // "Orçamento"
oLbVDD:addColumn( TCColumn():New( STR0040   , { || aVDD[oLbVDD:nAt,05] }                                                                ,,,, "LEFT" ,  30 ,.F.,.F.,,,,.F.,) ) // "Grupo"
oLbVDD:addColumn( TCColumn():New( STR0041   , { || aVDD[oLbVDD:nAt,06] }                                                                ,,,, "LEFT" ,  65 ,.F.,.F.,,,,.F.,) ) // "Código"
oLbVDD:addColumn( TCColumn():New( STR0042   , { || aVDD[oLbVDD:nAt,07] }                                                                ,,,, "LEFT" , 110 ,.F.,.F.,,,,.F.,) ) // "Descrição"
oLbVDD:addColumn( TCColumn():New( STR0043   , { || FG_AlinVlrs(Transform(aVDD[oLbVDD:nAt,08],X3PICTURE("VDD_QUANT"))) }                 ,,,, "RIGHT",  55 ,.F.,.F.,,,,.F.,) ) // "Qtd.Solicitada"
oLbVDD:addColumn( TCColumn():New( STR0044   , { || FG_AlinVlrs(Transform(aVDD[oLbVDD:nAt,09],X3PICTURE("B2_QATU"))) }                   ,,,, "RIGHT",  55 ,.F.,.F.,,,,.F.,) ) // "Qtd.Estoque"
oLbVDD:addColumn( TCColumn():New( STR0045   , { || FG_AlinVlrs(Transform(aVDD[oLbVDD:nAt,10],X3PICTURE("B2_CM1"))) }                    ,,,, "RIGHT",  55 ,.F.,.F.,,,,.F.,) ) // "Custo Unitário"
oLbVDD:addColumn( TCColumn():New( STR0046   , { || aVDD[oLbVDD:nAt,11] }                                                                ,,,, "LEFT" ,  55 ,.F.,.F.,,,,.F.,) ) // "Classif.ABC"
oLbVDD:addColumn( TCColumn():New( STR0047   , { || FG_AlinVlrs(Transform(aVDD[oLbVDD:nAt,12],"@EZ 99999,999,999")) }                    ,,,, "RIGHT",  55 ,.F.,.F.,,,,.F.,) ) // "Giro Estoque"
//
nTam := ( aPosObj[3,4] / 16 )
@ aPosObj[3,1]+005,aPosObj[3,2]+(nTam*01)+00 BITMAP oxNTik RESOURCE "LBNO" OF oDlg1 NOBORDER SIZE 10,10 when .f. PIXEL
@ aPosObj[3,1]+005,aPosObj[3,2]+(nTam*01)+15 SAY STR0048 SIZE 80,8 OF oDlg1 PIXEL COLOR CLR_BLUE // Peça(s) não selecionada(s)
@ aPosObj[3,1]+005,aPosObj[3,2]+(nTam*06)+00 BITMAP oxCTik RESOURCE "LBTIK" OF oDlg1 NOBORDER SIZE 10,10 when .f. PIXEL
@ aPosObj[3,1]+005,aPosObj[3,2]+(nTam*06)+15 SAY STR0049 SIZE 80,8 OF oDlg1 PIXEL COLOR CLR_BLUE // Peça(s) selecionada(s)
@ aPosObj[3,1]+005,aPosObj[3,2]+(nTam*11)+00 BITMAP oxVerm RESOURCE "BR_VERMELHO" OF oDlg1 NOBORDER SIZE 10,10 when .f. PIXEL
@ aPosObj[3,1]+005,aPosObj[3,2]+(nTam*11)+15 SAY STR0050 SIZE 80,8 OF oDlg1 PIXEL COLOR CLR_BLUE // Peça(s) com custo zerado
//
ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| IIf(FS_OKACEITA(),(lOkTela:=.t.,oDlg1:End()),.f.) } , {|| oDlg1:End() },,)

If lOkTela

	cFilAnt := VDD->VDD_FILPED // Muda cFilAnt para pegar o número correto de orçamento na Filial que será criado o Orçamento
	If FindFunction( "OX001PrxNro" )
		cNroOrc := OX001PrxNro()
	Else
		cNroOrc := GetSXENum("VS1","VS1_NUMORC")
		ConfirmSX8()
	Endif

	SA1->(DbGoTo( oFilHlp:GetCliente(VDD->VDD_FILORC) ))

	dbSelectArea("VS1")
	RecLock("VS1",.t.)
	VS1->VS1_FILIAL := VDD->VDD_FILPED
	VS1->VS1_NUMORC := cNroOrc
	VS1->VS1_TIPORC := "3" // Transferencia
	VS1->VS1_DATORC := dDataBase
	VS1->VS1_CLIFAT := SA1->A1_COD
	VS1->VS1_LOJA   := SA1->A1_LOJA
	VS1->VS1_NCLIFT := SA1->A1_NOME
	VS1->VS1_STATUS := Iif(lFaseConfer, cFaseConfer,"F") // Aguardando conferencia ou Pronto para Transferir
	VS1->VS1_FILDES := VDD->VDD_FILORC
	MsUnlock()
	If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
		OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0001 ) // Grava Data/Hora na Mudança de Status do Orçamento / Pedidos de Transferência de Peças
	EndIf
	
	If VS1->VS1_STATUS == cFaseConfer // Foi para Fase de Conferencia
		If ExistFunc("OA3610011_Tempo_Total_Conferencia_Saida_Orcamento")
			OA3610011_Tempo_Total_Conferencia_Saida_Orcamento( 1 , VS1->VS1_NUMORC ) // 1=Iniciar o Tempo Total da Conferencia de Saida caso não exista o registro
		EndIf
	EndIf

	lUsaVenc := ( SuperGetMv('MV_LOTVENC') == 'S' )
	
	nSeq := 1

	For _ii := 1 to Len(aVDD)
		If aVDD[_ii,1] == "1"
			DbSelectArea("VDD")
			DbGoto(aVDD[_ii,14])
			DbSelectArea("SB1")
			DbGoto(aVDD[_ii,15])            
			If lCtrlLote .and. Rastro( SB1->B1_COD )
				nPos := aScan(aVetOrcSld, {|x| x[1] == SB1->B1_COD}) // Verificar se existe algum registro selecionado
				If nPos == 0
					aadd(aVetOrcSld,{SB1->B1_COD,VDD->VDD_QUANT,aVDD[_ii,13]})
				Else
					aVetOrcSld[nPos,2] += VDD->VDD_QUANT
				Endif
			Endif
		Endif
	Next

	For _ii := 1 to Len(aVetOrcSld)
		aSalOX := SldPorLote(aVetOrcSld[_ii,1],aVetOrcSld[_ii,3],aVetOrcSld[_ii,2],NIL,"","","","",NIL,NIL,NIL,lUsaVenc,nil,nil,dDataBase)
		For ni := 1 to Len(aSalOX)
			aAdd(aSdPLtDMS,{aVetOrcSld[_ii,1],aSalOX[ni,1],aSalOX[ni,5]})
		Next
	Next

	For ni := 1 to len(aVDD)
		If aVDD[ni,1] == "1"
			DbSelectArea("VDD")
			DbGoto(aVDD[ni,14])
			If VDD->VDD_QUANT <> aVDD[ni,8]
				RecLock("VDD",.f.)
				VDD->VDD_QUANT := aVDD[ni,8]
				MsUnlock()
			Endif
			DbSelectArea("SB1")
			DbGoto(aVDD[ni,15])            
			nAteVDD := aVDD[ni,8]
			
			If !Empty(cMV_PAR01) //Se preencheu operação, necessário verificar se tem TES Inteligente para utilizar ela no item
				cTESSai  := MaTesInt(2,cMV_PAR01,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
				cTESEnt	 := MaTesInt(1,cMV_PAR01,SA2->A2_COD,SA2->A2_LOJA,"F",SB1->B1_COD)
			EndIf

			If lCtrlLote .and. Rastro( SB1->B1_COD )
//				aSaldos := SldPorLote(SB1->B1_COD,aVDD[ni,13],VDD->VDD_QUANT,NIL,"","","","",NIL,NIL,NIL,lUsaVenc,nil,nil,dDataBase)
				nPos := aScan(aSdPLtDMS, {|x| x[1] == SB1->B1_COD}) // Verificar se existe algum registro selecionado				
				For _ii := nPos to Len(aSdPLtDMS)
				
					If aSdPLtDMS[_ii,1] == SB1->B1_COD .and. aSdPLtDMS[_ii,3] > 0 .and. nAteVDD > 0

						dbSelectArea("VS3")
						RecLock("VS3",.t.)
						VS3->VS3_FILIAL := VDD->VDD_FILPED
						VS3->VS3_NUMORC := cNroOrc
						VS3->VS3_SEQUEN := strzero(_ii,3)
						VS3->VS3_GRUITE := VDD->VDD_GRUPO
						VS3->VS3_CODITE := VDD->VDD_CODITE
						VS3->VS3_QTDINI := aSdPLtDMS[_ii,3]
						VS3->VS3_TESSAI := iif(!Empty(cTESSai),cTESSai,cMV_PAR02)
						VS3->VS3_TESENT := iif(!Empty(cTESEnt),cTESEnt,cMV_PAR03)
						VS3->VS3_QTDITE := aSdPLtDMS[_ii,3]
						VS3->VS3_ARMORI := aVDD[ni,13]
						VS3->VS3_LOCAL  := aVDD[ni,13]
						VS3->VS3_VALPEC := aVDD[ni,10] 
						VS3->VS3_FORMUL := cMV_PAR04						
						VS3->VS3_LOTECT := aSdPLtDMS[_ii,2]
						If lVS3_TIPTRA
							VS3->VS3_TIPTRA := VDD->VDD_TIPTRA
						EndIf
						If lVS3_VENTRA
							VS3->VS3_VENTRA := VDD->VDD_VENTRA
						EndIf
						If lVS3_QTDAPR
							VS3->VS3_QTDAPR := aSdPLtDMS[_ii,3]
						EndIf
						MsUnlock()
						nAteVDD -= aSdPLtDMS[_ii,3]
						aSdPLtDMS[_ii,3] -= aSdPLtDMS[_ii,3]
					Else                              
						If aSdPLtDMS[_ii,1] <> SB1->B1_COD
							exit
						Endif
					EndIf
				Next	
			Else

				dbSelectArea("VS3")
				RecLock("VS3",.t.)
				VS3->VS3_FILIAL := VDD->VDD_FILPED
				VS3->VS3_NUMORC := cNroOrc
				VS3->VS3_SEQUEN := strzero(nSeq++,3)
				VS3->VS3_GRUITE := VDD->VDD_GRUPO
				VS3->VS3_CODITE := VDD->VDD_CODITE
				VS3->VS3_QTDINI := VDD->VDD_QUANT
				VS3->VS3_TESSAI := iif(!Empty(cTESSai),cTESSai,cMV_PAR02)
				VS3->VS3_TESENT := iif(!Empty(cTESEnt),cTESEnt,cMV_PAR03)
				VS3->VS3_QTDITE := VDD->VDD_QUANT
				VS3->VS3_ARMORI := aVDD[ni,13]
				VS3->VS3_LOCAL  := aVDD[ni,13]
				VS3->VS3_VALPEC := aVDD[ni,10] 
				VS3->VS3_FORMUL := cMV_PAR04
				If lVS3_TIPTRA
					VS3->VS3_TIPTRA := VDD->VDD_TIPTRA
				EndIf
				If lVS3_VENTRA
					VS3->VS3_VENTRA := VDD->VDD_VENTRA
				EndIf
				If lVS3_QTDAPR
					VS3->VS3_QTDAPR := VDD->VDD_QUANT
				EndIf
				MsUnlock()
			Endif
			DbSelectArea("VDD")
			reclock("VDD",.f.)
			VDD->VDD_ORCFOR := cNroOrc
			VDD->VDD_STATUS := "A"
			msunlock()
	    EndIf
	Next

	MsgInfo(STR0051 +CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0038+": "+VDD->VDD_FILPED+CHR(13)+CHR(10)+STR0039+": "+cNroOrc,STR0013) // Orçamento Gerado com sucesso! / Filial / Orçamento / Atenção
	
	// PONTO DE ENTRADA PARA ALTERACAO DO ORÇAMENTO AO ACEITAR O PEDIDO DE TRANSFERENCIA
	If ExistBlock("OX020ORC")
		ExecBlock("OX020ORC",.f.,.f.)
	EndIf

	cFilAnt := cFilBkp

EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_OKACEITAºAutor ³ Andre Luis Almeida º Data ³  03/11/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ OK tela do Aceite                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OKACEITA()
Local ni   := 0
Local lRet := .f.
Local cTipoNota  := Alltrim(GetNewPar("MV_MIL0027","2"))

For ni := 1 to len(aVDD)
	If aVDD[ni,1] == "1" // Peça selecionada
		lRet := .t.
		Exit
	EndIf
Next
If lRet

	If cTipoNota == "1"
		If Empty(cMV_PAR02)
			MsgStop(STR0052,STR0013) // "Necessário preencher o TES de Saida!" / "Atenção"
			lRet := .f.
		EndIf
		If Empty(cMV_PAR03)
			MsgStop(STR0053,STR0013) // "Necessário preencher o TES de Entrada!" / "Atenção"
			lRet := .f.
		EndIf
	ElseIf cTipoNota == "2"
		If Empty(cMV_PAR02)
			MsgStop(STR0052,STR0013) // "Necessário preencher o TES de Saida!" / "Atenção"
			lRet := .f.
		EndIf
	EndIf

	If Empty(cMV_PAR04)
		MsgStop(STR0079,STR0013) // "Necessário preencher a fórmula para compor o valor da transferência!" / "Atenção"
		lRet := .f.
	EndIf
Else
	MsgStop(STR0054,STR0013) // "Necessário selecionar uma ou mais Peças!" / "Atenção"
EndIf
Return lRet
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VDDACEITºAutor ³ Andre Luis Almeida º Data ³  03/11/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Duplo clique no listbox do Aceite                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VDDACEIT(nLinha)
Local aRet      := {}
Local aParamBox := {}
Local nPos      := 0
If aVDD[nLinha,14] > 0 // Existe registro VDD
	If aVDD[nLinha,1] == "2" // CUSTO <= 0
		MsgStop(STR0055,STR0013) // "Peça com custo zerado. Impossivel selecionar." / "Atenção"
	ElseIf aVDD[nLinha,1] == "1" // Registro selecionado
		aVDD[nLinha,1] := "0"
	Else // Registro nao selecionado
		nPos := aScan(aVDD, {|x| x[1] == "1" }) // Verificar se existe algum registro selecionado
	    If nPos > 0
			If !Empty(aVDD[nLinha,2]) .and. !Empty(aVDD[nPos,2]) .and. aVDD[nLinha,2] <> aVDD[nPos,2]
				MsgStop(STR0056,STR0013) // "Tipo de Transferencia é diferente do Tipo de Transferencia já selecionado. Impossivel continuar." / "Atenção"
				Return
			EndIf
			If aVDD[nLinha,3] <> aVDD[nPos,3]
				MsgStop(STR0057,STR0013) // "Filial do Orçamento é diferente da Filial do Orçamento já selecionada. Impossivel continuar." / "Atenção"
				Return
			EndIf
			If Left(aVDD[nLinha,4],1) == "P" .and. Left(aVDD[nLinha,4],1) <> Left(aVDD[nPos,4],1)
				MsgStop(STR0058,STR0013) // "Não é possível selecionar Pedido de Transferência com origens diferentes. Impossivel continuar." / "Atenção"
				Return
			EndIf
		EndIf
		If Left(aVDD[nLinha,4],1) == "P"
			AADD(aParamBox,{1,RetTitle("B1_GRUPO") ,aVDD[nLinha,5],"@!",'',"",".F.",030,.F.}) // 1 - Grupo
			AADD(aParamBox,{1,RetTitle("B1_CODITE"),aVDD[nLinha,6],"@!",'',"",".F.",080,.F.}) // 2 - CodIte
			AADD(aParamBox,{1,RetTitle("B1_DESC")  ,aVDD[nLinha,7],"@!",'',"",".F.",120,.F.}) // 3 - Descricao
			AADD(aParamBox,{1,STR0059              ,aVDD[nLinha,8],X3PICTURE("VDD_QUANT"),"MV_PAR04>=0" ,"",".T.",070,.F.}) // Qtd.Solicitada
			If ParamBox(aParamBox,STR0059,@aRet,,,,,,,,.f.) // Qtd.Solicitada
				aVDD[nLinha,8] := aRet[4]
				If aVDD[nLinha,8] > 0
					aVDD[nLinha,1] := "1"
				EndIf
			EndIf
		Else
			aVDD[nLinha,1] := "1"
		EndIf		
	EndIf
	oLbVDD:Refresh()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA020R  ³ Autor ³ Luis Delorme                      ³ Data ³ 25/06/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para rejeição  do pedido de transferência                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA020R(cAlias,nReg,nOpc)

Local aParamBox   := {}
Local aItensNew   := {}

Local aItemMov    := {}
Local oEst        := DMS_Estoque():New()

Local nQuant      := 0 
Local cBkpFil     := cFilAnt

if VDD->VDD_STATUS != "S"
	return .f.
endif

If !OXA200018_ValidaUsuarioTransf()
	Return .F.
EndIf

if !MsgYesNo(STR0012, STR0013) //Deseja REJEITAR a transferência ?
	return .f.
endif

MV_PAR01 := ""
aAdd(aParamBox,{1,STR0014,Space(254),"","","","",120,.F.})
while Empty(MV_PAR01)
	If !(ParamBox(aParamBox,STR0001,,,,,,,,,.f.))
		return .f.
	endif
enddo

DBSelectArea("VDD")
reclock("VDD",.f.)
VDD->VDD_MOTIVO := MV_PAR01
VDD->VDD_STATUS := "R"
msunlock()
                       
DBSelectArea("VS3")
DBSetOrder(2)
if DBSeek(VDD->VDD_FILORC + VDD->VDD_NUMORC + VDD->VDD_GRUPO + VDD->VDD_CODITE)
	nQuant := VS3->VS3_QTDITE - VS3->VS3_QTDTRA 
	reclock("VS3",.f.)
	VS3->VS3_QTDTRA := VS3->VS3_QTDTRA - VDD->VDD_QUANT
	msunlock()
endif

DBSelectArea("SB1")
DBSetOrder(7)
DBSeek(xFilial("SB1")+VDD->VDD_GRUPO+VDD->VDD_CODITE)
dbSetOrder(1)

if nQuant > 0
	cFilAnt := VDD->VDD_FILORC
	cDocumento  := Criavar("D3_DOC")
	cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
	cDocumento	:= A261RetINV(cDocumento)
			
	aItensNew := {}
	aadd (aItensNew,{ cDocumento , ddatabase})

	If Localiza(SB1->B1_COD)
		cLocOri := GetMv( "MV_RESLOC" )
	Else
		cLocOri := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
	EndIf

	cArmDes := VS3->VS3_LOCAL
	cLocDes := VS3->VS3_LOCALI

	aItemMov := oEst:SetItemSD3(SB1->B1_COD          ,; //Código do Produto
								GetMv( "MV_RESITE" ) ,; // Armazém de Origem
								cArmDes              ,; // Armazém de Destino
								cLocOri              ,; // Localização Origem
								cLocDes              ,; // Localização Destino
								nQuant                ) // Qtd a transferir

	aAdd(aItensNew, aClone(aItemMov))

	If (ExistBlock("OX020AP"))
		aItensNew := ExecBlock("OX020AP", .f., .f., {aItensNew})
	EndIf

	lMsErroAuto := .F.
	MSExecAuto({|x| MATA261(x)},aItensNew)
	cFilAnt := cBkpFil
	If lMsErroAuto
		&& Cancela Gravacao
		Mostraerro()
		DisarmTransaction()
		Break
	EndIf                  
	DBSelectArea("VS3")
	DBSetOrder(2)
	if DBSeek(VDD->VDD_FILORC + VDD->VDD_NUMORC + VDD->VDD_GRUPO + VDD->VDD_CODITE)
		RecLock("VS3",.F.)
		VS3->VS3_DOCSDB := ""
		MsUnlock()           
	Endif	
Endif	
MsgStop(STR0027)

// PONTO DE ENTRADA AO REJEITAR O PEDIDO DE TRANSFERENCIA
If ExistBlock("OX020REJ")
	ExecBlock("OX020REJ",.f.,.f.)
EndIf


return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Pedidos de Transferência de Peças                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {;
{ (STR0002) ,"AxPesqui"			, 0 , 1},; 	// Pesquisar
{ (STR0003) ,"OXA020A"			, 0 , 4},;	// Aceitar
{ (STR0004) ,"OXA020R"			, 0 , 4},;	// Rejeitar
{ (STR0060) ,"OXA020I"			, 0 , 3},;	// Incluir Pedido
{ (STR0007) ,"OXA020LEG"		, 0 , 6}}	// Legenda
//
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA003LEG ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Pedidos de Transferência de Peças                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA020LEG()
Local aLegenda := {;
{'BR_AMARELO',STR0024},;
{'BR_VERDE',STR0006},;
{'BR_VERMELHO',STR0008},;
{'BR_PRETO',STR0009},;
{'BR_AZUL',STR0010}}
//
BrwLegenda(cCadastro,STR0007,aLegenda)
//
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OXA020VTES³ Autor ³ Luis Delorme                     ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verificação do TES                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA020VTES()
if !Empty(cMV_PAR02)
	DBSelectArea("SF4")
	DBSetOrder(1)
	if DBSeek(xFilial("SF4")+cMV_PAR02)
		if SF4->F4_TIPO != "S" .or. SF4->F4_ESTOQUE != "S"      
			if SF4->F4_TIPO != "S"
				MsgStop(STR0030)
			Else
				MsgStop(STR0031)
			Endif	
			cMV_PAR01 := Space(TamSX3("VS3_OPER")[1])
			cMV_PAR02 := Space(TamSX3("F4_CODIGO")[1])
			oMV_PAR01:Refresh()
			oMV_PAR02:Refresh()
			return .f.
		endif                
		return .t.
	Else
		return .f.
	endif
Endif
return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OXA020TESE³ Autor ³ Luis Delorme                     ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verificação do TES                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA020TESE()
if !Empty(cMV_PAR03)
	DBSelectArea("SF4")
	DBSetOrder(1)
	if DBSeek(xFilial("SF4")+cMV_PAR03)
		if SF4->F4_TIPO != "E" .or. SF4->F4_ESTOQUE != "S"      
			if SF4->F4_TIPO != "E"
				MsgStop(STR0032)
			Else
				MsgStop(STR0031)
			Endif	
			cMV_PAR01 := Space(TamSX3("VS3_OPER")[1])
			cMV_PAR03 := Space(TamSX3("F4_CODIGO")[1])
			oMV_PAR01:Refresh()
			oMV_PAR03:Refresh()
			return .f.
		endif                
		return .t.
	Else
		return .f.
	endif
Endif
return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OXA020LBOX³ Autor ³ Luis Delorme                      ³ Data ³ 25/06/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Listbox para escolha das filiais que possuem peças excedentes          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA020LBOX(cFilOrc,cCodGrupo,cCodIte, nQuant)

Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cB1LocPad := ""
Local nCont
Local cFilAntAnt := cFilAnt
aIte1 := {}

//Levanta as Filiais
For nCont := 1 to Len(aSM0)
	
	if aSM0[nCont] == cFilOrc
		loop
	endif
	
	cFilAnt := aSM0[nCont]
	
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+cCodGrupo+cCodIte)
	cB1LocPad := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
	//
	nSaldo := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+cB1LocPad)
	SB2->(DBSetOrder(1))
	SB2->(DBSeek(xFilial("SB2")+SB1->B1_COD+cB1LocPad))
	NNR->(DBSetOrder(1))
	NNR->(dbSeek(xFilial("NNR")+cB1LocPad))
	aAdd(aIte1,{FWFilialName()+"/"+cFilAnt,TRANS(nSaldo,"@E 999,999,999.99"),TRANS(0,"@E 999,999,999.99"),cFilAnt, nSaldo})
Next

cFilAnt := cFilAntAnt
if Len(aIte1) == 0
	MsgStop(STR0015 ,STR0013)
	return .f.
endif
xOpca := 0
 
DEFINE MSDIALOG xDlg TITLE STR0018 From 10,10 to 36,79 of oMainWnd    //"Localizacao do Item"
//
@ 019,002 SAY (STR0020+Alltrim(cCodGrupo) + "/"+Alltrim(cCodIte)+ "    "+STR0019+ Alltrim(Transform(nQuant,"@E999.999,99"))) SIZE 200,08 OF xDlg PIXEL COLOR CLR_BLACK
@ 032, 001 LISTBOX oLbHeadx FIELDS HEADER	(STR0021),;  //"Localizacao"
(STR0022),;
(STR0023);
COLSIZES 80,120,48 SIZE 271,132 OF xDlg PIXEL ON DBLCLICK (OXA020TIK(nQuant))
//
oLbHeadx:SetArray(aIte1)
oLbHeadx:bLine := { || { aIte1[oLbHeadx:nAt,1] , FG_AlinVlrs(aIte1[oLbHeadx:nAt,2]) , FG_AlinVlrs(aIte1[oLbHeadx:nAt,3]) }}

DEFINE SBUTTON FROM 177, 213 TYPE 1 ACTION (xOpca := 1, xDlg:End()) ENABLE OF xDlg
DEFINE SBUTTON FROM 177, 240 TYPE 2 ACTION (xOpca := 2, xDlg:End()) ENABLE OF xDlg

//
ACTIVATE MSDIALOG xDlg CENTER 
//
aRet := {}
//
if xOpca == 2
	return aRet
endif                                         
//
for nCont := 1 to Len(aIte1)
	if Val(aIte1[nCont,3]) > 0
		aAdd(aRet,{ cCodGrupo, cCodite, aIte1[nCont,1], val(aIte1[nCont,3]), aIte1[nCont,4], aIte1[nCont,5] }) //adicionei o saldo aqui
	endif
next
return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OXA020TIK ³ Autor ³ Luis Delorme                      ³ Data ³ 25/06/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Clique na listbox de peças excedentes da concessionaria                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA020TIK(nQuant)

Local nCont 
MV_PAR01 := ""
aParamBox := {}
aAdd(aParamBox,{1,STR0016,0,"@E 999,999,999.99","MV_PAR01 > 0",,"",0,.T.})
If !(ParamBox(aParamBox,STR0006,,,,,,,,,.f.))
	return .f.
endif
//
nQuantAtu := 0
//
for nCont := 1 to Len(aIte1)
	if oLbHeadx:nAt != nCont
		nQuantAtu += val(aIte1[nCont,3])
	endif
next
if nQuantAtu + MV_PAR01 > nQuant 
	MsgStop(STR0017,STR0013)
	return .f.
endif
//
aIte1[oLbHeadx:nAt,3] := TRANS(MV_PAR01,"@E 999,999,999.99")
//
oLbHeadx:SetArray(aIte1)
oLbHeadx:bLine := { || { aIte1[oLbHeadx:nAt,1] , FG_AlinVlrs(aIte1[oLbHeadx:nAt,2]) , FG_AlinVlrs(aIte1[oLbHeadx:nAt,3]) }}
//
return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OXA020TPOP ºAutor  ³Thiago             º Data ³  05/05/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao do Tipo de Opercao                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA020TPOP()

If !Empty(cMV_PAR01)
	Existcpo("SX5","DJ"+cMV_PAR01)
EndIf

aSM0 := FWArrFilAtu(cEmpAnt,VDD->VDD_FILORC) // Filial Destino
cCGCDest := aSM0[18] // SM0->M0_CGC
dbSelectArea("SA1")
dbSetOrder(3)
dbSeek(xFilial("SA1")+cCGCDest) 

dbSelectArea("SA2")
dbSetOrder(3)
dbSeek(xFilial("SA2")+cCGCDest) 

dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+VDD->VDD_GRUPO+VDD->VDD_CODITE)
cTESSai := MaTesInt(2,cMV_PAR01,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
cMV_PAR02 := cTESSai
cTESEnt := MaTesInt(1,cMV_PAR01,SA2->A2_COD,SA2->A2_LOJA,"F",SB1->B1_COD)
cMV_PAR03 := cTESEnt

oMV_PAR02:Refresh()
oMV_PAR03:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  OXA020I ºAutor  ³ Andre Luis Almeida º Data ³  01/11/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Transferencia de Pecas                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA020I()
Local nTam         := 0
Local aObjects     := {} , aPosObj := {} , aInfo := {}
Local aSizeAut     := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local aFilAux      := FWArrFilAtu()
Local aTipTra      := X3CBOXAVET("VDD_TIPTRA","0") // {"0=Avulsa","1=Reposição","2=Devolução","3=Garantia"}
Local lPEVldFilial := ExistBlock("OX020FIL") //Ponto de entrada para validar filial de origem e destino no momento em que é selecionada.
Private cTipTra    := "0"
Private aFiliais   := FWAllFilial( aFilAux[3] , aFilAux[4] , aFilAux[1] , .f. )
Private cFilOri    := cFilAnt
Private cFilDes    := cFilAnt
Private cVenTra    := FGX_USERVL( xFilial("VAI"),__cUserID,"VAI_CODVEN","?")
//
Private aVDD       := {}
//
FS_VDD("",0)
//
aObjects := {}
AAdd( aObjects, { 05 , 17 , .T. , .F. } )  // Cabecalho
AAdd( aObjects, { 05 , 20 , .T. , .F. } )  // Botoes
AAdd( aObjects, { 01 , 00 , .T. , .T. } )  // Listbox
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)
//
SetKey(VK_F5 , { || FS_VDD("I",oLbVDD:nAt)  } )
SetKey(VK_F6 , { || FS_VDD("A",oLbVDD:nAt)  } )
SetKey(VK_F7 , { || FS_VDD("E",oLbVDD:nAt)  } )
//SetKey(VK_F8 , { || FS_VDD("X",oLbVDD:nAt)  } )
//
DEFINE MSDIALOG oDlg1 TITLE STR0061 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL // "Transferência de Peças entre Filiais"
//
nTam := ( ( aPosObj[1,4] - 10 ) / 13 )
@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL ("") OF oDlg1 PIXEL // Caixa Cabecalho
If len(aTipTra) > 0
	@ aPosObj[1,1]+005,aPosObj[1,2]+(nTam*00)+005 SAY STR0062 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE // "Tp.Transferencia: "
	@ aPosObj[1,1]+004,aPosObj[1,2]+(nTam*01)+005 MSCOMBOBOX oTipTra VAR cTipTra ITEMS aTipTra SIZE (nTam),08 OF oDlg1 PIXEL
Else
	cTipTra := ""
EndIf
@ aPosObj[1,1]+005,aPosObj[1,2]+(nTam*03)+005 SAY STR0063 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE // "Filial Origem: "
@ aPosObj[1,1]+004,aPosObj[1,2]+(nTam*04)+005 MSCOMBOBOX oFilOri VAR cFilOri ITEMS aFiliais VALID FS_TROCAFIL() .AND. iif(lPEVldFilial,ExecBlock("OX020FIL", .f., .f., {1,cFilOri}),.T.) SIZE (nTam*2),08 OF oDlg1 PIXEL
@ aPosObj[1,1]+005,aPosObj[1,2]+(nTam*07)+005 SAY STR0064 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE //"Filial Destino: "
@ aPosObj[1,1]+004,aPosObj[1,2]+(nTam*08)+005 MSCOMBOBOX oFilDes VAR cFilDes ITEMS aFiliais VALID iif(lPEVldFilial,ExecBlock("OX020FIL", .f., .f., {2,cFilDes}),.T.) SIZE (nTam*2),08 OF oDlg1 PIXEL 
@ aPosObj[1,1]+005,aPosObj[1,2]+(nTam*11)+005 SAY STR0065 SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLUE // "Vendedor: "
@ aPosObj[1,1]+004,aPosObj[1,2]+(nTam*12)+005 MSGET oVenTra VAR cVenTra PICTURE "@!" F3 "SA3" VALID FG_Seek("SA3","cVenTra",1,.f.) SIZE (nTam),08 OF oDlg1 PIXEL COLOR CLR_BLUE HASBUTTON
//
nTam := ( ( aPosObj[2,4] - 10 ) / 08 )
//nTam := ( ( aPosObj[2,4] - 10 ) / 11 )
@ aPosObj[2,1]+004,aPosObj[2,2]+(nTam*00)+005 BUTTON oBotInc PROMPT (STR0066+" <F5>")          OF oDlg1 SIZE (nTam*2),12 PIXEL ACTION FS_VDD("I",oLbVDD:nAt) // "Incluir Peça"
@ aPosObj[2,1]+004,aPosObj[2,2]+(nTam*03)+005 BUTTON oBotAlt PROMPT (STR0067+" <F6>")          OF oDlg1 SIZE (nTam*2),12 PIXEL ACTION FS_VDD("A",oLbVDD:nAt) // "Alterar Peça"
@ aPosObj[2,1]+004,aPosObj[2,2]+(nTam*06)+005 BUTTON oBotExc PROMPT (STR0068+" <F7>")          OF oDlg1 SIZE (nTam*2),12 PIXEL ACTION FS_VDD("E",oLbVDD:nAt) // "Excluir Peça"
//@ aPosObj[2,1]+004,aPosObj[2,2]+(nTam*09)+005 BUTTON oBotAva PROMPT ("Incluir Avançado"+" <F8>") OF oDlg1 SIZE (nTam*2),12 PIXEL ACTION FS_VDD("X",oLbVDD:nAt)
//
oLbVDD := TWBrowse():New(aPosObj[3,1],aPosObj[3,2],aPosObj[3,4]-2,(aPosObj[3,3]-aPosObj[3,1]),,,,oDlg1,,,,,{ || FS_VDD("A",oLbVDD:nAt) },,,,,,,.F.,"",.T.,,.F.,,,)
oLbVDD:SetArray(aVDD)
oLbVDD:addColumn( TCColumn():New( STR0040  , { || aVDD[oLbVDD:nAt,01] }                                                ,,,, "LEFT" ,  35 ,.F.,.F.,,,,.F.,) ) // "Grupo"
oLbVDD:addColumn( TCColumn():New( STR0041  , { || aVDD[oLbVDD:nAt,02] }                                                ,,,, "LEFT" ,  65 ,.F.,.F.,,,,.F.,) ) // "Código"
oLbVDD:addColumn( TCColumn():New( STR0042  , { || aVDD[oLbVDD:nAt,03] }                                                ,,,, "LEFT" , 125 ,.F.,.F.,,,,.F.,) ) // "Descrição"
oLbVDD:addColumn( TCColumn():New( STR0043  , { || FG_AlinVlrs(Transform(aVDD[oLbVDD:nAt,04],X3PICTURE("VDD_QUANT"))) } ,,,, "RIGHT",  65 ,.F.,.F.,,,,.F.,) ) // "Qtd.Solicitada"
oLbVDD:addColumn( TCColumn():New( STR0044  , { || FG_AlinVlrs(Transform(aVDD[oLbVDD:nAt,05],X3PICTURE("B2_QATU"))) }   ,,,, "RIGHT",  65 ,.F.,.F.,,,,.F.,) ) // "Qtd.Estoque"
oLbVDD:addColumn( TCColumn():New( STR0045  , { || FG_AlinVlrs(Transform(aVDD[oLbVDD:nAt,06],X3PICTURE("B2_CM1"))) }    ,,,, "RIGHT",  65 ,.F.,.F.,,,,.F.,) ) // "Custo Unitário"
oLbVDD:addColumn( TCColumn():New( STR0046  , { || aVDD[oLbVDD:nAt,07] }                                                ,,,, "LEFT" ,  65 ,.F.,.F.,,,,.F.,) ) // "Classif.ABC" 
oLbVDD:addColumn( TCColumn():New( STR0047  , { || FG_AlinVlrs(Transform(aVDD[oLbVDD:nAt,08],"@EZ 99999,999,999")) }    ,,,, "RIGHT",  65 ,.F.,.F.,,,,.F.,) ) // "Giro Estoque"
//
ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| IIf(FS_OK(),oDlg1:End(),.f.) } , {|| oDlg1:End() },,)
//
SetKey(VK_F5 , Nil )
SetKey(VK_F6 , Nil )
SetKey(VK_F7 , Nil )
//SetKey(VK_F8 , Nil )
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  FS_VDD  ºAutor  ³ Andre Luis Almeida º Data ³  01/11/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Inclusao/Alteracao/Exclusao do aVDD                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VDD(cTp,nLinha)
Local cBkpFil    := cFilAnt
Local aRet       := {}
Local aParamBox  := {}
Local cGruIte    := space(TamSX3("B1_GRUPO")[1])
Local cCodIte    := space(TamSX3("B1_CODITE")[1])
Local cDesIte    := ""
Local nQtdSol    := 0
If len(aVDD) == 1 .and. aVDD[1,9] == 0
	If ( cTp == "I" .or. cTp == "A" )
		cTp := "I"
		aVDD := {}
	ElseIf cTp == "E"
		cTp := ""
	ElseIf cTp == "X"
		aVDD := {}
	EndIf
EndIf
If !Empty(cTp)
	//
	SetKey(VK_F5 , Nil )
	SetKey(VK_F6 , Nil )
	SetKey(VK_F7 , Nil )
//	SetKey(VK_F8 , Nil )
	//
	If cTp == "X" // Incluir Avancado 
		
	Else
		If cTp <> "I"
			cGruIte := aVDD[nLinha,1]
			cCodIte := aVDD[nLinha,2]
			cDesIte := aVDD[nLinha,3]
			nQtdSol := aVDD[nLinha,4]
		EndIf
		//
		cFilAnt := cFilOri
		//
		AADD(aParamBox,{1,RetTitle("B1_GRUPO") ,cGruIte,"@!",'VAZIO() .or. FG_Seek("SBM","MV_PAR01",1,.f.)'                  ,"SBM",IIf(cTp=="I",".T.",".F."),030,.F.}) // 1 - Grupo
		AADD(aParamBox,{1,RetTitle("B1_CODITE"),cCodIte,"@!",'VAZIO() .or. ( FG_POSSB1("MV_PAR02","SB1->B1_CODITE","MV_PAR01") .and. FG_Seek("SB1","MV_PAR01+MV_PAR02",7,.f.,"MV_PAR03","B1_DESC") )',"B11",IIf(cTp=="I",".T.",".F."),080,.F.}) // 2 - CodIte
		AADD(aParamBox,{1,RetTitle("B1_DESC")  ,cDesIte,"@!",''                                                              ,""   ,".F.",120,.F.}) // 3 - Descricao
		AADD(aParamBox,{1,STR0059              ,nQtdSol,X3PICTURE("VDD_QUANT"),"MV_PAR04>0" ,"",IIf(cTp<>"E",".T.",".F."),070,.T.}) // Qtd.Solicitada
		If ParamBox(aParamBox,STR0069,@aRet,,,,,,,,.f.) // Transferencia de Peças
			If cTp <> "E"
				If !Empty(aRet[2])
					SB1->(DbSetOrder(7))
					If SB1->(DbSeek(xFilial("SB1")+aRet[1]+aRet[2]))
						If cTp == "I"
							aAdd(aVDD,{SB1->B1_GRUPO,SB1->B1_CODITE,SB1->B1_DESC,0,0,0,"",0,SB1->(RecNo())})
							nLinha := len(aVDD)
						EndIf
						aVDD[nLinha,4] := aRet[4]
					EndIf
				EndIf	
				FS_TROCAFIL()
			Else
				aDel(aVDD,nLinha)
				aSize(aVDD,Len(aVDD)-1)
			EndIf	
		EndIf
		//
		cFilAnt := cBkpFil
		//
	EndIf
EndIf
If len(aVDD) == 0 
	aAdd(aVDD,{Space(TamSX3("B1_GRUPO")[1]),Space(TamSX3("B1_CODITE")[1]),"",0,0,0,"",0,0})
EndIf
If !Empty(cTp)
	//
	oLbVDD:nAt := 1
	oLbVDD:SetArray(aVDD)
	oLbVDD:Refresh()
	//
	SetKey(VK_F5 , { || FS_VDD("I",oLbVDD:nAt)  } )
	SetKey(VK_F6 , { || FS_VDD("A",oLbVDD:nAt)  } )
	SetKey(VK_F7 , { || FS_VDD("E",oLbVDD:nAt)  } )
//	SetKey(VK_F8 , { || FS_VDD("X",oLbVDD:nAt)  } )
	//
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TROCAFILºAutor ³ Andre Luis Almeida º Data ³  01/11/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Troca a Filial de Origem                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TROCAFIL()
Local lRet    := .t.
Local ni      := 0
Local cBkpFil := cFilAnt
cFilAnt := cFilOri
For ni := 1 to len(aVDD)
	If !Empty(aVDD[ni,1]+aVDD[ni,2])
		SB1->(DbSetOrder(7))
		If SB1->(DbSeek(xFilial("SB1")+aVDD[ni,1]+aVDD[ni,2]))
			aVDD[ni,3] := SB1->B1_DESC
			SB2->(DbSetOrder(1))
			SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")))
			aVDD[ni,5] := SaldoSB2()
			aVDD[ni,6] := SB2->B2_CM1
			SB3->(DbSetOrder(1))
			SB3->(DbSeek(xFilial("SB3")+SB1->B1_COD))
			aVDD[ni,7] := SB3->B3_CLASSE
			aVDD[ni,8] := SB3->B3_MEDIA
			aVDD[ni,9] := SB1->(RecNo())
		Else
			MsgAlert(STR0070+CHR(13)+CHR(10)+CHR(13)+CHR(10)+aVDD[ni,1]+" "+aVDD[ni,2],STR0013) // "Peça não encontrada na Filial de Origem." / "Atenção"
			lRet := .f.
	    EndIf
    EndIf
Next
oLbVDD:nAt := 1
oLbVDD:SetArray(aVDD)
oLbVDD:Refresh()
cFilAnt := cBkpFil
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  FS_OK   ºAutor  ³ Andre Luis Almeida º Data ³  01/11/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ OK na tela de Incluir Pedido ( VDD )                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OK()
Local ni   := 0
Local aSM0 := {}
Local lVDD_TIPTRA := ( VDD->(FieldPos("VDD_TIPTRA")) > 0 )
Local lVDD_VENTRA := ( VDD->(FieldPos("VDD_VENTRA")) > 0 )
//
If len(aVDD) == 1 .and. aVDD[1,9] == 0
	MsgStop(STR0071,STR0013) // "Não há itens para realizar a transferência." / "Atenção"
	Return .f.
Endif
//
If cFilOri == cFilDes
	MsgStop(STR0072,STR0013) // "Filial de Origem não pode ser a mesma da Filial de Destino!" / "Atenção"
	Return .f.
EndIf
//
aSM0 := FWArrFilAtu(cEmpAnt,cFilOri) // Filial Origem
dbSelectArea("SA2")
dbSetOrder(3)
If !dbSeek(xFilial("SA2")+aSM0[18])
	MsgStop(STR0073+CHR(13)+CHR(10)+CHR(13)+CHR(10)+AllTrim(RetTitle("A2_CGC"))+": "+Transform(aSM0[18],x3Picture("A2_CGC")),STR0013) // "Filial de Origem não encontrada como Fornecedor!" / "Atenção"
	Return .f.
EndIf
aSM0 := FWArrFilAtu(cEmpAnt,cFilDes) // Filial Destino
dbSelectArea("SA1")
dbSetOrder(3)
If !dbSeek(xFilial("SA1")+aSM0[18])
	MsgStop(STR0074+CHR(13)+CHR(10)+CHR(13)+CHR(10)+AllTrim(RetTitle("A1_CGC"))+": "+Transform(aSM0[18],x3Picture("A1_CGC")),STR0013) // "Filial de Destino não encontrada como Cliente!" / "Atenção"
	Return .f.
EndIf
///////////////////////////////////
// Buscar o ultimo nro de Pedido //
///////////////////////////////////
ni := ( TamSX3("VDD_NUMORC")[1] - 1 )
cNumOrc := FM_SQL("SELECT MAX(VDD_NUMORC) FROM "+RetSqlName("VDD")+" WHERE VDD_FILIAL='"+xFilial("VDD")+"' AND VDD_NUMORC LIKE 'P%'")
cNumOrc := "P"+strzero(val(right(cNumOrc,ni))+1,ni)
//
For ni := 1 to len(aVDD)
	dbSelectArea("VDD")
	RecLock("VDD",.t.)
		VDD->VDD_FILIAL := xFilial("VDD")
		VDD->VDD_CODIGO := GetSXENum("VDD","VDD_CODIGO")
		ConfirmSX8()
		VDD->VDD_FILORC := cFilDes
		VDD->VDD_NUMORC := cNumOrc
		VDD->VDD_GRUPO  := aVDD[ni,1]
		VDD->VDD_CODITE := aVDD[ni,2]
		VDD->VDD_QUANT  := aVDD[ni,4]
		VDD->VDD_FILPED := cFilOri
		VDD->VDD_STATUS := "S"
		If lVDD_TIPTRA
			VDD->VDD_TIPTRA := cTipTra
		EndIf
		If lVDD_VENTRA
			VDD->VDD_VENTRA := cVenTra
		EndIf
	MsUnlock()
Next
MsgInfo(STR0075,STR0013) // "Pedido de Transferencia criado com sucesso!" / "Atenção"
Return .t.

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

/*/{Protheus.doc} OXA200018_ValidaUsuarioTransf

@author matheus.silva
@since 27/04/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OXA200018_ValidaUsuarioTransf()

	If VAI->(FieldPos("VAI_USRTRA")) > 0
		DBSelectArea("VAI")
		DBSetOrder(4)
		DBSeek(xFilial("VAI")+__cUserId)

		Do Case 
		Case VAI->VAI_USRTRA = "1"
			If VDD->VDD_FILORC <> cFilAnt
				MsgStop(STR0076,STR0013) //Necessário estar logado na filial destino para aprovar ou rejeitar essa transferência. / Atenção
				Return .F.
			EndIf
		Case VAI->VAI_USRTRA = "2"
			MsgStop(STR0077,STR0013) //Usuário sem permissão para aceitar ou rejeitar transferências. / Atenção
			Return .F.
		EndCase
	EndIf
	
Return .T.

/*/{Protheus.doc} OXA200028_ValidaFormula

CI 010807 - Rotina foi alterada para solicitar ao usuário que informe uma formula
para compro o valor da transferencia, ao invés de utilizar o custo da filial destino

@author matheus.silva
@since 24/06/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OXA200028_ValidaFormula(aVDD)
	Local nCont 

	If !OFP8600016_VerificacaoFormula(cMV_PAR04, .T.)
		Return .F.
	EndIf

	For nCont := 1 to Len(aVDD)
		SB1->(DbGoTo(aVDD[nCont,15]))
		SB2->(DbSetOrder(1))
		SB2->(MsSeek(aVDD[nCont,3]+SB1->B1_COD+aVDD[nCont,13]))
		SB3->(DbSetOrder(1))
		SB3->(MsSeek(aVDD[nCont,3]+SB1->B1_COD))

		aVDD[nCont,10] := Fg_Formula(cMV_PAR04)

		If aVDD[nCont,10] <= 0
			aVDD[nCont,1] := "2" // Nao pode ser selecionado
		Else
			aVDD[nCont,1] := "1" // Pode ser selecionado
		EndIf		
	Next nCont

	oLbVDD:Refresh()

Return .T.

/*/{Protheus.doc} OXA200038_PEOX020WHN

CI 010891 - Ponto de Entrada para validar se habilita a edição dos campos ou não

nTipo = 1 - Tipo de operação
nTipo = 2 - TES saida
nTipo = 3 - TES entrada
nTipo = 4 - Fórmula

@author matheus.silva
@since 11/08/2021
@version 1.0
@return ${lRet - .F./.T.}, ${Retorna True ou False}

@type function
/*/
Static Function OXA200038_PEOX020WHN(nTipo)
	Local lRet

	lRet := ExecBlock("OX020WHN", .f., .f., {nTipo})

Return lRet