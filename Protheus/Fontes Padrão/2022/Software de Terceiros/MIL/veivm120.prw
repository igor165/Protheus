// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 16     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEIVM120.ch"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  13/11/2017
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
±±³Funcao    ³ VEIVM120 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 10/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Movimentacoes de Veiculos (SD3)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM120()
Private cChassi  := space(len(VV1->VV1_CHASSI))
Private cLocDe   := space(len(SB5->B5_LOCALI2))
Private cLocPara := space(len(SB5->B5_LOCALI2))
Private cArmDe   := space(len(SB2->B2_LOCAL))
Private cVeiculo := space(250)
Private cChaInt  := ""
Public cArmPara := space(len(SB2->B2_LOCAL))
DEFINE MSDIALOG oMovIntVei FROM 000,000 TO 009,085 TITLE (STR0001) OF oMainWnd // Movimentacao Interna de Veiculos
@ 004,002 TO 030,282 LABEL (" "+STR0002+" ") OF oMovIntVei PIXEL // Veiculo
//  	@ 014,110 BUTTON oBusca PROMPT "..." OF oMovIntVei SIZE 10,10 PIXEL ACTION FS_CONVEI() // Consulta Veiculo
@ 014,008 MSGET oChassi VAR cChassi VALID FS_VALVEI() F3 "V13" SIZE 100,08 OF oMovIntVei PIXEL COLOR CLR_BLUE
oChassi:SetFocus()
@ 015,125 SAY cVeiculo SIZE 250,08 OF oMovIntVei PIXEL COLOR CLR_BLUE
@ 035,002 TO 061,335 LABEL (" "+STR0003+" ") OF oMovIntVei PIXEL // Armazem / Localizacao
@ 046,007 SAY STR0004 SIZE 40,08 OF oMovIntVei PIXEL COLOR CLR_BLUE // De
@ 045,025 MSGET oArmDe VAR cArmDe SIZE 20,08 OF oMovIntVei PIXEL COLOR CLR_BLUE WHEN .f.
@ 045,045 MSGET oLocDe VAR cLocDe SIZE 60,08 OF oMovIntVei PIXEL COLOR CLR_BLUE WHEN .f.
@ 046,137 SAY STR0005 SIZE 40,08 OF oMovIntVei PIXEL COLOR CLR_BLUE // Para
@ 045,155 MSGET oArmPara VAR cArmPara PICTURE "@!" F3 "NNR" VALID FS_VALARM() SIZE 25,08 OF oMovIntVei PIXEL COLOR CLR_BLUE
@ 045,180 MSGET oLocPara VAR cLocPara PICTURE "@!" F3 "VZP" VALID FS_VALLOC() SIZE 60,08 OF oMovIntVei PIXEL COLOR CLR_BLUE
@ 045,287 BUTTON oConf PROMPT STR0006 OF oMovIntVei SIZE 45,10 PIXEL ACTION (FS_VEIVM120(),FS_VALVEI(),oArmPara:SetFocus()) WHEN ( !Empty(cChassi) .and. (!Empty(cArmPara) .and. !Empty(cLocPara)) ) // CONFIRMAR
@ 007,287 BUTTON oSair PROMPT STR0007 OF oMovIntVei SIZE 45,10 PIXEL ACTION oMovIntVei:End() // SAIR
@ 020,287 BUTTON oRast PROMPT STR0008 OF oMovIntVei SIZE 45,10 PIXEL ACTION VEIVC140(cChassi, cChaInt) WHEN !Empty(cChassi) // Rastreamento
ACTIVATE MSDIALOG oMovIntVei CENTER
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALARM³ Autor ³  Andre Luis Almeida   ³ Data ³ 10/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Valida Armazem					                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALARM() // Valida Armazem
Local lRet := .t.
If !Empty(cArmPara)
	lRet := .f.
	DbSelectArea("NNR")
	DbSetOrder(1)
	If DbSeek(xFilial("NNR")+cArmPara)
		lRet := .t.
	Else
		MsgStop(STR0014,STR0009) // "Armazem nao encontrado!" / Atencao
	EndIf
EndIf
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALLOC³ Autor ³  Andre Luis Almeida   ³ Data ³ 10/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³   Valida Localizacao				                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALLOC() // Valida Localizacao
Local lRet := .f.
If Empty(cLocPara+cLocDe)
	lRet := .t.
EndIf
If (cArmDe+cLocDe)<>(cArmPara+cLocPara)
	lRet := .t.
EndIf
if TCCanOpen(RetSQLName("VZL")) // USA LOCALIZACAO DE VEICULOS
    if !Empty(cArmPara) .and. !Empty(cLocPara)
		DBSelectArea("VZL")
		DBSetOrder(1)
		if !DBSeek(xFilial("VZL")+cArmPara+cLocPara)
			MsgStop(STR0015,STR0009) // Localizacao nao encontrada! / Atencao
			lRet := .f.
		else
			if VZL->VZL_QTDATU >= VZL->VZL_QTDMAX
				MsgStop(STR0016,STR0009) // Localizacao esta lotada! / Atencao
				lRet := .f.
			endif
		Endif	
	EndIf
endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VALVEI ³ Autor ³  Andre Luis Almeida   ³ Data ³ 10/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida chassi						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALVEI()
Local lRet := .f.
Local cQuery   := ""
Local cQAlSB2  := "SQLSB2"
cVeiculo := space(250)
cLocDe := cLocPara := space(len(SB5->B5_LOCALI2))
cArmDe := cArmPara := space(len(SB2->B2_LOCAL))  
If !Empty(cChassi)
	If FG_POSVEI("cChassi","VV1->VV1_CHASSI") .and. VV1->VV1_GRASEV <> "6"
		cChaInt := VV1->VV1_CHAINT
		FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , /* cGruVei */ )
		DbSetOrder(1)
		DbSelectArea("SB5")
		DbSetOrder(1)
		DbSeek(xFilial("SB5")+SB1->B1_COD)
		cLocDe := SB5->B5_LOCALI2
		oLocDe:Refresh()
		cQuery := "SELECT SB2.B2_LOCAL FROM "+RetSqlName("SB2")+" SB2 WHERE SB2.B2_FILIAL='"+xFilial("SB2")+"' AND SB2.B2_COD='"+SB1->B1_COD+"' AND SB2.B2_QATU > 0 AND SB2.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSB2 , .F., .T. )
		If !( cQAlSB2 )->( Eof() )
			cArmDe := ( cQAlSB2 )->( B2_LOCAL )
			oArmDe:Refresh()
			lRet := .t.
		EndIf
		( cQAlSB2 )->( dbCloseArea() )
		If lRet
			DbSelectArea("VV2")
			DbSetOrder(1)
			DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
			DbSelectArea("VVC")
			DbSetOrder(1)
			DbSeek( xFilial("VVC") + VV1->VV1_CODMAR + VV1->VV1_CORVEI )
			cVeiculo := IIf(!Empty(VV1->VV1_PLAVEI),Transform(VV1->VV1_PLAVEI,X3Picture("VV1_PLAVEI"))+" ","")+VV1->VV1_CODMAR+" "+LEFT(VV2->VV2_DESMOD,20)+" "+left(VVC->VVC_DESCRI,15)
		Else
			MsgStop(STR0011,STR0009) // Veiculo nao esta no estoque! / Atencao
		EndIf
	Else
		cChaInt := ""
		MsgStop(STR0012,STR0009) // Veiculo nao encontrado! / Atencao
	EndIf
Else
	cChaInt := ""
	lRet := .t.
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VEIVM120³ Autor ³  Andre Luis Almeida  ³ Data ³ 10/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Movimentacao Interna						                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VEIVM120() // Movimentacao Interna
Local cDocumento
Local aItensNew := {}

Local aItemMov := {}
Local oEst     := DMS_Estoque():New()

If !Empty(cChassi)
	If (cArmDe+cLocDe) <> (cArmPara+cLocPara)
		If !Empty(cArmPara) .and. !Empty(cLocPara)
			DbSelectArea("SB1")
			BEGIN TRANSACTION
			// Cria Movimentacao Interna //
			cDocumento  := Criavar("D3_DOC")
			cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
			cDocumento	:= A261RetINV(cDocumento)
			aadd ( aItensNew,{cDocumento,dDataBase})

			aItemMov := oEst:SetItemSD3(SB1->B1_COD       ,; //Código do Produto
										cArmDe            ,; // Armazém de Origem
										cArmPara          ,; // Armazém de Destino
										cLocDe            ,; // Localização Origem
										cLocPara          ,; // Localização Destino
										1                  ) // Qtd a transferir

			aAdd(aItensNew, aClone(aItemMov))

			If (ExistBlock("VM120AV"))
				aItensNew := ExecBlock("VM120AV", .f., .f., {aItensNew})
			EndIf

			lMSErroAuto := .f.
			MSExecAuto({|x| MATA261(x)},aItensNew)
			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
				Return()
			EndIf
			// Altera a HORA da Movimentacao //
			If SD3->(FieldPos("D3_HREMIS")) <> 0
				DbSelectArea("SD3")
				RecLock("SD3",.f.)
				SD3->D3_HREMIS  := left(time(),5)
				MsUnlock()
			EndIf
			// Altera o Endereco DMS no SB5 //
			DbSelectArea("SB5")
			DbSetOrder(1)
			DbSeek( xFilial("SB5") + SB1->B1_COD )
			RecLock("SB5",!Found())
			SB5->B5_FILIAL  := xFilial("SB5")
			SB5->B5_COD     := SB1->B1_COD
			SB5->B5_LOCALI2 := cLocPara
			MsUnlock()
			// Altera quantidade da localizacao //
			if TCCanOpen(RetSQLName("VZL"))  // USA LOCALIZACAO DE VEICULOS
				DBSelectArea("VZL")
				DBSetOrder(1)
				if DBSeek(xFilial("VZL")+cArmDe+cLocDe)
					if VZL->VZL_QTDATU > 0
						reclock("VZL",.f.)
						VZL->VZL_QTDATU := VZL->VZL_QTDATU - 1
						msunlock()
					endif
				endif
				if DBSeek(xFilial("VZL")+cArmPara+cLocPara)
					reclock("VZL",.f.)
					VZL->VZL_QTDATU := VZL->VZL_QTDATU + 1
					msunlock()
				endif
			endif
			END TRANSACTION
			If ExistBlock("VM120DGR") // Ponto de Entrada apos a Gravacao da Movimentacao Interna
				ExecBlock("VM120DGR",.f.,.f.,{ SB1->B1_COD , VV1->VV1_CHASSI , cArmDe , cArmPara })
			EndIf
			MsgInfo(STR0010,STR0009) // Movimentacao efetuada com sucesso! / Atencao
		EndIf
	EndIf
EndIf
Return()

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