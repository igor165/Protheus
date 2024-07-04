// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 05     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "OFIOC410.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³OFIOC410³ Autor ³ Andre Luis Almeida       ³ Data ³ 28/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Controle de Registro de Saida de Veiculos na OS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Oficina ( Entrega de Veiculos na Oficina )                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC410()
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private aVetor  := {}
Private cPesq   := space(30)
Private cQtdVei := ""
Private aVeiEnt := { STR0023 , STR0022 } // Veiculos a serem entregues / Veiculos ja entregues
Private cVeiEnt := STR0023 // Veiculos a serem entregues
Private dDtIni  := (dDataBase-day(dDataBase))+1 // 1o. dia do mes corrente
Private dDtFin  := dDataBase // Data atual
Private cTipDt  := STR0025 // "Data da Abertura da OS:"
Private aOrdem  := { STR0006 , STR0016 , STR0007 , STR0008 , STR0019 , STR0021 } // Ordem: Veiculo / Cor / Chassi / OS / Data / Nome do Proprietario
Private cOrdem  := STR0006 // Veiculo
FS_LEVANT(0)

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 22 , .T. , .F. } ) // Pesquisar
aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox

aPos := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oSaiVei TITLE STR0001 From aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] of oMainWnd PIXEL // "Registro da Saida do Veiculo na OS"

	@ aPos[2,1],aPos[2,2] LISTBOX oLbEnt FIELDS HEADER STR0006,STR0016,STR0007,STR0008,STR0019,STR0009,STR0010,STR0011,STR0012 COLSIZES 70,45,60,35,25,85,45,60,80 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1] OF oSaiVei PIXEL ON DBLCLICK (FS_OFIOC410(oLbEnt:nAt))
	oLbEnt:SetArray(aVetor)
	oLbEnt:bLine := { || {aVetor[oLbEnt:nAt,5],aVetor[oLbEnt:nAt,12],aVetor[oLbEnt:nAt,6],aVetor[oLbEnt:nAt,7],Transform(stod(aVetor[oLbEnt:nAt,10]),"@D"),aVetor[oLbEnt:nAt,1]+"-"+aVetor[oLbEnt:nAt,2]+" "+aVetor[oLbEnt:nAt,3],aVetor[oLbEnt:nAt,4],aVetor[oLbEnt:nAt,9],aVetor[oLbEnt:nAt,8]}}
	@ aPos[1,1]+000,aPos[1,2]+000 MSCOMBOBOX oVeiEnt VAR cVeiEnt ITEMS aVeiEnt VALID FS_LEVANT(1) SIZE 90,08 OF oSaiVei PIXEL COLOR CLR_BLUE
	
	@ aPos[1,1]+001,aPos[1,2]+115 SAY cTipDt SIZE 90,08 OF oSaiVei PIXEL COLOR CLR_BLUE // "Data da Abertura da OS:" ou "Data da Saida do Veiculo:"
	@ aPos[1,1]+000,aPos[1,2]+180 MSGET oDtIni VAR dDtIni VALID oDtFin:SetFocus() PICTURE "@D" SIZE 44,08 OF oSaiVei PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+001,aPos[1,2]+228 SAY STR0017 SIZE 20,10 OF oSaiVei PIXEL COLOR CLR_BLUE // a
	@ aPos[1,1]+000,aPos[1,2]+237 MSGET oDtFin VAR dDtFin VALID FS_LEVANT(1) PICTURE "@D" SIZE 44,08 OF oSaiVei PIXEL COLOR CLR_BLUE

	@ aPos[1,1]+013,aPos[1,2]+000 SAY STR0018 SIZE 30,06 OF oSaiVei PIXEL COLOR CLR_BLUE // Ordem
	@ aPos[1,1]+012,aPos[1,2]+020 MSGET oOrdem VAR cOrdem SIZE 60,08 OF oSaiVei PIXEL COLOR CLR_BLUE WHEN .f.
	@ aPos[1,1]+012,aPos[1,2]+080 BUTTON oOrd PROMPT "..." OF oSaiVei SIZE 10,10 PIXEL ACTION FS_ORDEM(9)
	
	@ aPos[1,1]+013,aPos[1,2]+115 SAY STR0004 SIZE 30,10 OF oSaiVei PIXEL COLOR CLR_BLUE // Pesquisa
	@ aPos[1,1]+012,aPos[1,2]+143 MSGET oPesq VAR cPesq VALID FS_PESQ() PICTURE "@!" SIZE 138,08 OF oSaiVei PIXEL COLOR CLR_BLUE
	
	@ aPos[1,1]+012,aPos[1,2]+370 BUTTON oImpr PROMPT STR0020 OF oSaiVei SIZE 35,09 PIXEL ACTION FS_IMPRIMIR() // Imprimir
	@ aPos[1,1]+000,aPos[1,2]+306 MSGET oQtdVei VAR cQtdVei SIZE 100,08 OF oSaiVei PIXEL COLOR CLR_BLUE WHEN .f.

ACTIVATE MSDIALOG oSaiVei ON INIT EnchoiceBar(oSaiVei,{ || oSaiVei:End() }, { || oSaiVei:End() },,)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_LEVANT³ Autor ³ Andre Luis Almeida      ³ Data ³ 28/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Levanta registros ( Veiculos a serem entregues na Oficina ) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANT(nTip)
Local lA1_IBGE := ( SA1->(FieldPos("A1_IBGE")) > 0 )
Local cQuery   := ""
Local cQAlias  := "SQLVO1"
Local nVeiEnt  := IIf(cVeiEnt==STR0023,1,2)
cTipDt := IIf(nVeiEnt==1,STR0025,STR0024) // "Data da Abertura da OS:" / "Data da Saida do Veiculo:"
aVetor := {}
cQuery := "SELECT VO1.VO1_NUMOSV , VO1.VO1_PROVEI , VO1.VO1_LOJPRO , VO1.VO1_DATABE , VO1.VO1_DATSAI , VO1.VO1_CHAINT FROM "+RetSqlName("VO1")+" VO1 WHERE VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND "
If nVeiEnt == 1 // Veiculos a serem entregues
	cQuery += "VO1.VO1_DATABE>='"+dtos(dDtIni)+"' AND VO1.VO1_DATABE<='"+dtos(dDtFin)+"' AND VO1.VO1_DATSAI='"+space(8)+"' AND VO1.D_E_L_E_T_=' ' "
Else // Veiculos ja entregues
	cQuery += "VO1.VO1_DATSAI>='"+dtos(dDtIni)+"' AND VO1.VO1_DATSAI<='"+dtos(dDtFin)+"' AND VO1.D_E_L_E_T_=' ' "
EndIf
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
If !( cQAlias )->( Eof() )
	Do While !( cQAlias )->( Eof() )
		DbSelectArea("VV1")
		DbSetOrder(1)
		If DbSeek( xFilial("VV1") + ( cQAlias )->(VO1_CHAINT ) )
			DbSelectArea("VV2")
			DbSetOrder(1)
			DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
			DbSelectArea("VVC")
			DbSetOrder(1)
			DbSeek( xFilial("VVC") + VV1->VV1_CODMAR + VV1->VV1_CORVEI )
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + ( cQAlias )->( VO1_PROVEI ) + ( cQAlias )->( VO1_LOJPRO ) )
			If lA1_IBGE
				VAM->(DbSetOrder(1))	
				VAM->(Dbseek(xFilial("VAM")+SA1->A1_IBGE))
				aAdd(aVetor,{ ( cQAlias )->( VO1_PROVEI ) , ( cQAlias )->( VO1_LOJPRO ) , left(SA1->A1_NOME,30) , "("+VAM->VAM_DDD+") "+Alltrim(SA1->A1_TEL) , VV1->VV1_CODMAR+" "+VV2->VV2_DESMOD , VV1->VV1_CHASSI , ( cQAlias )->( VO1_NUMOSV ) , Alltrim(VAM->VAM_DESCID)+"-"+VAM->VAM_ESTADO , Transform(SA1->A1_CGC,If(Len(Alltrim(SA1->A1_CGC))>12,"@R 99.999.999/9999-99","@R 999.999.999-99")) , IIf(nVeiEnt==1,( cQAlias )->( VO1_DATABE ),( cQAlias )->( VO1_DATSAI )) , nVeiEnt , left(VVC->VVC_DESCRI,19) })
			Else
				aAdd(aVetor,{ ( cQAlias )->( VO1_PROVEI ) , ( cQAlias )->( VO1_LOJPRO ) , left(SA1->A1_NOME,30) , Alltrim(SA1->A1_TEL) , VV1->VV1_CODMAR+" "+VV2->VV2_DESMOD , VV1->VV1_CHASSI , ( cQAlias )->( VO1_NUMOSV ) , Alltrim(SA1->A1_MUN)+"-"+SA1->A1_EST , Transform(SA1->A1_CGC,If(Len(Alltrim(SA1->A1_CGC))>12,"@R 99.999.999/9999-99","@R 999.999.999-99")) , IIf(nVeiEnt==1,( cQAlias )->( VO1_DATABE ),( cQAlias )->( VO1_DATSAI )) , nVeiEnt , left(VVC->VVC_DESCRI,19) })
			EndIf
		EndIf
	  	( cQAlias )->( DbSkip() )
	EndDo
Else
	MsgAlert(STR0003,STR0002) // Nenhum Veiculo encontrado! / Atencao
EndIf
( cQAlias )->( dbCloseArea() )
cQtdVei := space(10)+str(len(aVetor),15)+" "+STR0005 // nnnn veiculo(s)
If len(aVetor) <= 0
	aAdd(aVetor,{ "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , 2 , "" })
	cQtdVei := ""
EndIf
FS_ORDEM(nTip)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_ORDEM³ Autor ³ Andre Luis Almeida      ³ Data ³ 28/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Ordena Vetor para apresentacao dos veiculos                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ORDEM(nTip)
Local cOrdAnt := cOrdem
If nTip == 9
	DEFINE MSDIALOG oOrdVet TITLE STR0018 From 000,000 to 003,030 of oMainWnd
		@ 006,006 MSCOMBOBOX oOrdem VAR cOrdem ITEMS aOrdem SIZE 80,08 OF oOrdVet PIXEL COLOR CLR_BLUE
		DEFINE SBUTTON FROM 006,087 TYPE 1 ACTION (cOrdAnt:=cOrdem,oOrdVet:End(),FS_ORDEM(1)) ENABLE OF oOrdVet PIXEL
	ACTIVATE MSDIALOG oOrdVet CENTER
	cOrdem := cOrdAnt
Else
	If cOrdem == STR0006 // Veiculo
		aSort(aVetor,1,,{|x,y| x[5]+x[6] < y[5]+y[6] })
	ElseIf cOrdem == STR0016 // Cor
		aSort(aVetor,1,,{|x,y| x[12]+x[5]+x[6] < y[12]+y[5]+y[6] })
	ElseIf cOrdem == STR0007 // Chassi
		aSort(aVetor,1,,{|x,y| x[6] < y[6] })
	ElseIf cOrdem == STR0008 // OS
		aSort(aVetor,1,,{|x,y| x[7] < y[7] })
	ElseIf cOrdem == STR0019 // Data
		aSort(aVetor,1,,{|x,y| x[10] < y[10] })
	ElseIf cOrdem == STR0021 // Nome do Proprietario
		aSort(aVetor,1,,{|x,y| x[3] < y[3] })
	EndIf
	If nTip > 0
		oLbEnt:nAt := 1
		oLbEnt:SetArray(aVetor)
		oLbEnt:bLine := { || {aVetor[oLbEnt:nAt,5],aVetor[oLbEnt:nAt,12],aVetor[oLbEnt:nAt,6],aVetor[oLbEnt:nAt,7],Transform(stod(aVetor[oLbEnt:nAt,10]),"@D"),aVetor[oLbEnt:nAt,1]+"-"+aVetor[oLbEnt:nAt,2]+" "+aVetor[oLbEnt:nAt,3],aVetor[oLbEnt:nAt,4],aVetor[oLbEnt:nAt,9],aVetor[oLbEnt:nAt,8]}}
		oLbEnt:SetFocus()
		oLbEnt:Refresh()
	EndIf
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_OFIOC410³ Autor ³ Andre Luis Almeida    ³ Data ³ 28/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Executa a Entrega do Veiculo na Oficina                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OFIOC410(nPos)
Local lRet    := .f.
Local cQuery  := ""
Local cQAlVS1 := "SQLVS1"
If !Empty(aVetor[nPos,7]) .and. aVetor[nPos,11] == 1 // Veiculos a serem entregues
	If MsgYesNo(STR0013+CHR(13)+CHR(10)+CHR(13)+CHR(10)+aVetor[nPos,5]+CHR(13)+CHR(10)+aVetor[nPos,12]+CHR(13)+CHR(10)+STR0007+": "+aVetor[nPos,6]+CHR(13)+CHR(10)+STR0009+": "+aVetor[nPos,1]+"-"+aVetor[nPos,2]+" "+aVetor[nPos,3]+CHR(13)+CHR(10)+STR0011+": "+aVetor[nPos,9]+CHR(13)+CHR(10)+STR0012+": "+aVetor[nPos,8]+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0008+": "+aVetor[nPos,7]+CHR(13)+CHR(10)+STR0019+": "+Transform(stod(aVetor[nPos,10]),"@D"),STR0002)
		DbSelectArea("VO1")
		DbSetOrder(1)
		If DbSeek( xFilial("VO1") + aVetor[nPos,7] )
			RecLock("VO1",.f.)
				VO1->VO1_DATSAI := dDataBase
				VO1->VO1_HORSAI := val(left(time(),2)+substr(time(),4,2))
			MsUnLock()
			If FindFunction("OM350STATUS")
			    if VS1->(FieldPos("VS1_NUMAGE")) # 0
			    	cQuery := "SELECT VS1.VS1_NUMAGE FROM "+RetSqlName("VS1")+" VS1 WHERE "
					cQuery += "VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_NUMOSV='"+VO1->VO1_NUMOSV+"' AND VS1.VS1_NUMAGE<>' ' AND VS1.D_E_L_E_T_=' ' "
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlVS1, .F., .T. )
					While !( cQAlVS1 )->( Eof() )
						OM350STATUS(( cQAlVS1 )->( VS1_NUMAGE ),"1","3") // Finaliza Agendamento
						( cQAlVS1 )->( DbSkip() )
					EndDo
					( cQAlVS1 )->( dbCloseArea() )
					DbSelectArea("VO1")
				Endif
			EndIf
			MsgInfo(STR0014,STR0002) // Operacao realizada com sucesso! / Atencao
			lRet := .t.
		EndIf
	EndIf
EndIf
If lRet
	FS_LEVANT(1)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_PESQ   ³ Autor ³ Andre Luis Almeida    ³ Data ³ 28/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Pesquisa no Vetor                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQ()
Local ni := 0
If !Empty(cPesq)
	Do Case
		Case cOrdem == STR0016 // Cor
			ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[12] }) // Cor
		Case cOrdem == STR0007 // Chassi
			ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[6] })  // Chassi
		Case cOrdem == STR0008 // OS
			ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[7] })  // OS
		Case cOrdem == STR0021 // Nome do Proprietario
			ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[3] })  // Nome do Proprietario
	EndCase
	If	ni == 0
		ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[7] })                     // OS
		If	ni == 0
			ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[6] })                 // Chassi
			If ni == 0
				ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[3] })             // Nome do Proprietario
				If ni == 0
					ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[5] })         // Marca/Modelo
					If ni == 0
						ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[12] })    // Cor
						If ni == 0
							ni := aScan(aVetor, {|x| Alltrim(cPesq) $ x[9] }) // CPF/CNPJ
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
If ni > 0
	oLbEnt:nAt := ni
Else
	oLbEnt:nAt := 1
EndIf
oLbEnt:SetArray(aVetor)
oLbEnt:bLine := { || {aVetor[oLbEnt:nAt,5],aVetor[oLbEnt:nAt,12],aVetor[oLbEnt:nAt,6],aVetor[oLbEnt:nAt,7],Transform(stod(aVetor[oLbEnt:nAt,10]),"@D"),aVetor[oLbEnt:nAt,1]+"-"+aVetor[oLbEnt:nAt,2]+" "+aVetor[oLbEnt:nAt,3],aVetor[oLbEnt:nAt,4],aVetor[oLbEnt:nAt,9],aVetor[oLbEnt:nAt,8]}}
oLbEnt:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_IMPRIMIR³ Autor ³ Andre Luis Almeida    ³ Data ³ 28/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Impressao do array                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR()
Local cDesc1	:= ""
Local cDesc2	:= ""
Local cDesc3	:= ""
Local cAlias	:= ""
Local ni 		:= 0 
Private nLin    := 1
Private aReturn := { "" , 1 , "" , 1 , 2 , 1 , "" , 1 }
Private cTamanho:= "G"            // P/M/G
Private Limite  := 132           // 80/132/220
Private aOrdem  := {}             // Ordem do Relatorio
Private cTitulo := STR0001 //"Registro da Saida do Veiculo na OS"
Private cNomeRel:= "OFIOC410"
Private nLastKey:= 0
Private cabec1  := ""
Private cabec2  := ""
Private nCaracter:=15
Private m_Pag   := 1 
cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cAlias)
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
cabec1 := " "+LEFT(cVeiEnt+space(35),35) +"  "+ cTipDt+ " " + transform(dDtIni,"@D")+" "+STR0015+" "+ transform(dDtFin,"@D")+"      "+STR0018+" "+cOrdem
cabec2 := " "+left(STR0006+space(27),27)+"  "+left(STR0016+space(18),18) +"  "+ left(STR0007+space(25),25) +"  "+ left(STR0008+space(10),10) +"  "+ left(STR0019+space(8),8) +"  "+ left(STR0009+space(38),38)+"  "+left(STR0010+space(14),14) +"  "+ left(STR0011+space(18),18) +"  "+STR0012
nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1             
For ni:= 1 to len(aVetor) 
	If nLin >= 60
		nLin := cabec(ctitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
	EndIf               //Veiculo                             //Cor                                   //chassi                                                                //OS                                   //data                                          //Proprietario                                                               //Fone                                 //CPF/CNPJ
	@ nLin++ ,01 psay left(aVetor[ni,5]+space(27),27) +"  "+ left(aVetor[ni,12]+space(18),18) +"  "+ left(aVetor[ni,6]+space(25),25) +"  "+ left(aVetor[ni,7]+space(10),10) +"  "+ Transform(stod(aVetor[ni,10]),"@D")+"  "+ left(aVetor[ni,1]+"-"+aVetor[ni,2]+" "+aVetor[ni,3]+space(38),38) +"  "+ left(aVetor[ni,4]+space(14),14) +"  "+ left(aVetor[ni,9]+space(18),18) +"  "+ left(aVetor[ni,8]+space(40),40)
Next
Ms_Flush()
Set Printer to
Set Device  to Screen
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf
Return()