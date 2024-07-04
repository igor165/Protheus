// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 19     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEIXX005.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  25/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007322_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXX005 º Autor ³ Andre Luis Almeida º Data ³  01/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Financiamento / Leasing                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc (2-Visualizar/4-Alterar/3-Incluir)                    º±±
±±º          ³ aParFin (Vetor de Parametros)                              º±±
±±º			 ³	 aParFin[01] = Valor                                      º±±
±±º			 ³	 aParFin[02] = Cliente                                    º±±
±±º			 ³	 aParFin[03] = Loja                                       º±±
±±º			 ³	 aParFin[04] = Tipo de Pessoa (F-isica/J-uridica)         º±±
±±º			 ³	 aParFin[05] = Chassi Interno (CHAINT)                    º±±
±±º			 ³	 aParFin[06] = Estado do Veiculo (Novo/Usado)             º±±
±±º			 ³	 aParFin[07] = Grupo do Modelo                            º±±
±±º			 ³	 aParFin[08] = Modelo do Veiculo                          º±±
±±º			 ³	 aParFin[09] = TAXA do DIA ( Banco )                      º±±
±±º			 ³	 aParFin[10] = TAXA do DIA ( Tabela )                     º±±
±±º			 ³	 aParFin[11] = TAXA do DIA ( Tipo da Tabela )             º±±
±±º			 ³	 aParFin[12] = Nro do Atendimento                         º±±
±±º			 ³	 aParFin[13] = VAS->(RecNo())                             º±±
±±º			 ³	 aParFin[14] = VAR->(RecNo())                             º±±
±±º			 ³	 aParFin[15] = Vetor com os N veiculos do Atendimento     º±±
±±º			 ³	  - [15,n,1] = Chassi Interno (CHAINT)                    º±±
±±º			 ³	  - [15,n,2] = Estado do Veiculo (Novo/Usado)             º±±
±±º			 ³	  - [15,n,3] = Grupo do Modelo                            º±±
±±º			 ³	  - [15,n,4] = Modelo do Veiculo                          º±±
±±º			 ³	  - [15,n,5] = Marca do Veiculo                           º±±
±±º          ³ aVS9 (Pagamentos)                                          º±±
±±º			 ³	 aVS9[1] = aHeader                                        º±±
±±º          ³   aVS9[2] = aCols                                          º±±
±±º          ³ aVSE (Observacoes Pagamento)                               º±±
±±º			 ³	 aVSE[1] = aHeader                                        º±±
±±º          ³   aVSE[2] = aCols                                          º±±
±±º          ³ lZerar (Zerar Financiamento/Leasing)                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX005(nOpc,aParFin,aVS9,aVSE,lZerar)
Local aObjects  := {} , aPos := {} , aInfo := {} 
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lRet      := .f.
Local nCntFor   := 1
Local nPos      := 0
Local nx        := 0
Local ni        := 0
Local cTpPgVS9  := ""
Local cComboFI  := ""
Local aComboFI  := X3CBOXAVET("VAR_TIPTAB","1")
Local aComboPar := {"=","<",">"}
Local aComboPer := {"=","<",">"}
Local aComboEnt := {"=","<",">"}
Local nVlFin    := 0
Local nVlPar    := 0
//
Local cBanco    := SPACE(TamSx3("VAR_CODBCO")[1])
Local nQtdParc  := 0
Local nPerEnt   := 0
Local nVlrEnt   := 0
//
Local nOpcao    := 0
Local cTpPagCon := FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='3' AND VSA.D_E_L_E_T_=' '") // VSA_TIPO='3' ( Consorcio )
Local cTpFiname := FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='6' AND VSA.D_E_L_E_T_=' '") // VSA_TIPO='6' ( Finame )
Local nLinhaVS9 := 0
Local dDtTit    := dDataBase
Local dADtTit   := ctod("") // Data do Titulo Financiamento Atual
Local nAVlFin   := 0  // Valor Financiamento Atual 
Local cATipo    := "" // Tipo de Tabela Financiamento Atual
Local cADesc    := "" // Descricao Financiamento Atual
Local cATabel   := "" // Tabela Financiamento Atual 
Local nAJuros   := 0  // Juros Financiamento Atual 
Local cQuery    := ""
Local cSQLAlias := "SQLALIAS"
Local cSQLAux   := "SQLAUX"
Local cNumAte   := aParFin[12] // Numero do Atendimento
Local aFiltros  := {} 
Private cCQtdParc := ">"
Private cCPerEnt := ">"
Private cCVlrEnt := ">"

Private aTabFAI := {}
Private aHeaderVS9 := aClone(aVS9[1])
Private aHeaderVSE := aClone(aVSE[1])
Default lZerar  := .f.
If !Empty(aParFin[12])
	DbSelectArea("VV9")
	DbSetOrder(1)
	DbSeek(xFilial("VV9")+aParFin[12])
	DbSelectArea("VV0")
	DbSetOrder(1)
	DbSeek(xFilial("VV0")+aParFin[12])
EndIf
nVlFin := aParFin[1]
If !Empty(aParFin[2]+aParFin[3])
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+aParFin[2]+aParFin[3]))
	aParFin[4] := SA1->A1_PESSOA
EndIf
If !Empty(aParFin[5])
	VV1->(DbSetOrder(1))
	VV1->(DbSeek(xFilial("VV1")+aParFin[5]))
	aParFin[6] := VV1->VV1_ESTVEI
	VV2->(DbSetOrder(1))
	VV2->(DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	aParFin[7] := VV2->VV2_GRUMOD 
	aParFin[8] := VV2->VV2_MODVEI
EndIf
// Fator de reducao 90%
for nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.90)
next   
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0, 30, .T. , .f. } ) // ATUAL ( Financiamento / Leasing )
AAdd( aObjects, { 0,  0, .T. , .T. } ) // Financiamento / Leasing
aPos := MsObjSize( aInfo, aObjects )
aVSE[2] := {}
If nOpc == 3 .or. nOpc == 4 // Incluir / Alterar
	For ni := 1 to len(aVS9[2]) // Selecionar o Financiamento / Leasing ja utilizado neste Atendimento
		If !aVS9[2,ni,len(aVS9[2,ni])]
			If !Empty(aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")])
				If !Empty(cTpPagCon) // Verifica se ja existe Consorcio NAO quitado para o Atendimento
					If aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] == cTpPagCon
						If left(aVS9[2,ni,FG_POSVAR("VS9_REFPAG","aHeaderVS9")],1) == "0" // Existe Consorcio NAO quitado - 
							MsgStop(STR0003,STR0002) // Ja existe Consorcio NAO quitado para este Atendimento. Impossivel incluir Financiamento! / Atencao
							Return lRet
						EndIf
					EndIf
				EndIf
				If !Empty(cTpFiname) // Verifica se ja existe Finame para o Atendimento
					If aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] == cTpFiname
						MsgStop(STR0004,STR0002) // Ja existe Finame para este Atendimento. Impossivel incluir Financiamento! / Atencao
						Return lRet
					EndIf
				EndIf
			EndIf
			VSA->(DbSetOrder(1))
			VSA->(DbSeek(xFilial("VSA")+aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")]))
			If VSA->VSA_TIPO == "1"
				nLinhaVS9 := ni // Linha do aCols do VS9
	           	aAdd(aVSE[2],Array(len(aVSE[1])+1))
	           	aVSE[2,1,FG_POSVAR("VSE_NUMIDE","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_NUMIDE","aHeaderVS9")]
				aVSE[2,1,FG_POSVAR("VSE_TIPOPE","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_TIPOPE","aHeaderVS9")]
				aVSE[2,1,FG_POSVAR("VSE_TIPPAG","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")]
				aVSE[2,1,FG_POSVAR("VSE_SEQUEN","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")]
				aVSE[2,1,len(aVSE[2,1])] := .t.
			EndIf
		EndIf
	Next
EndIf

If !Empty(aParFin[12]) // Traz dados do Financiamento Atual
	DbSelectArea("VV0")
	DbSetOrder(1)
	If DbSeek( xFilial("VV0") + aParFin[12] )
		nAVlFin	:= VV0->VV0_VALFIN // Valor do Financiamento Atual
		If nAVlFin > 0
			cATabel	:= VV0->VV0_TABFAI // Tabela Financiamento Atual
			nAJuros := VV0->VV0_COEFIC // Juros Financiamento Atual 
			cQuery := "SELECT VS9.VS9_TIPPAG , VS9.VS9_DATPAG , VS9.VS9_VALPAG , VS9.VS9_REFPAG , VS9.VS9_SEQUEN FROM "+RetSQLName("VS9")+" VS9 "
			cQuery += "INNER JOIN "+RetSQLName("VSA")+" VSA ON ( VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG=VS9.VS9_TIPPAG AND VSA.VSA_TIPO='1' AND VSA.D_E_L_E_T_ = ' ' ) "
			cQuery += "WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+aParFin[12]+"' AND VS9.VS9_TIPOPE = 'V' AND VS9.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
			If !(cSQLAlias)->(Eof())
				dADtTit := stod((cSQLAlias)->( VS9_DATPAG ))
				cATipo := Alltrim(X3CBOXDESC("VAR_TIPTAB",left((cSQLAlias)->( VS9_REFPAG ),1)))
				cQuery := "SELECT VSE.VSE_DESCCP , VSE.VSE_VALDIG FROM "+RetSqlName("VSE")+" VSE WHERE "
				cQuery += "VSE.VSE_FILIAL='"+xFilial("VSE")+"' AND VSE.VSE_NUMIDE='"+aParFin[12]+"' AND VSE.VSE_TIPOPE='V' AND VSE.VSE_TIPPAG='"+(cSQLAlias)->( VS9_TIPPAG )+"' AND VSE.VSE_SEQUEN='"+(cSQLAlias)->( VS9_SEQUEN )+"' AND VSE.D_E_L_E_T_=' ' ORDER BY VSE.VSE_DESCCP"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAux, .F., .T. )
				While !(cSQLAux)->(Eof())
					cADesc += Alltrim(substr((cSQLAux)->( VSE_DESCCP ),2))+" "+Alltrim((cSQLAux)->( VSE_VALDIG ))+" "
					If left((cSQLAux)->( VSE_DESCCP ),1) == "4"
						Exit
					EndIf
					(cSQLAux)->(dbSkip())
				EndDo
				(cSQLAux)->(dbCloseArea())
			EndIf
			(cSQLAlias)->(dbCloseArea())
		EndIf
	EndIf
EndIf

If !lZerar

	If nOpc == 3 .or. nOpc == 4 // Inclusao ou Alteracao
		If ExistBlock("VX05FILT")
			aFiltros := ExecBlock("VX05FILT",.f.,.f.)
			If !Empty(aFiltros[1])
				cBanco   := aFiltros[1] // Banco
			EndIf
			If !Empty(aFiltros[2])
				cComboFI := aFiltros[2] // Financiamento ou Leasing
			EndIf
			If aFiltros[3] > 0
				nQtdParc := aFiltros[3] // Qtde de Parcelas
			EndIf
			If aFiltros[4] > 0
				nPerEnt := aFiltros[4] // % Entrada
			EndIf
			If aFiltros[5] > 0
				nVlrEnt := aFiltros[5] // Vlr.Entrada
			EndIf
		EndIf
	EndIf

	FS_LISTAFI(0,cBanco,nVlFin,cComboFI,aParFin,nQtdParc,nPerEnt,nVlrEnt) // Carrega ListBox INICIAL

	DEFINE MSDIALOG oTelaFin TITLE STR0001 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Financiamento / Leasing
		oTelaFin:lEscClose := .F.
	
		@ aPos[1,1]+001,aPos[1,2] TO aPos[1,3]+002,aPos[1,4]+001 LABEL STR0005 OF oTelaFin PIXEL // Financiamento Atual
		@ aPos[1,1]+009,aPos[1,2]+005 SAY STR0006 SIZE 72,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Valor
		@ aPos[1,1]+017,aPos[1,2]+005 MSGET oAVlFin VAR nAVlFin PICTURE "@E 99,999,999.99" SIZE 47,08 OF oTelaFin PIXEL HASBUTTON COLOR CLR_BLACK WHEN .f.
		@ aPos[1,1]+009,aPos[1,2]+053 SAY STR0007 SIZE 72,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Data
		@ aPos[1,1]+017,aPos[1,2]+053 MSGET oADtTit VAR dADtTit PICTURE "@D" SIZE 46,08 OF oTelaFin PIXEL HASBUTTON COLOR CLR_BLACK WHEN .f.
		@ aPos[1,1]+009,aPos[1,2]+099 SAY STR0008 SIZE 72,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Tipo
		@ aPos[1,1]+017,aPos[1,2]+099 MSGET oATipo VAR cATipo SIZE 50,08 OF oTelaFin PIXEL COLOR CLR_BLACK WHEN .f.
		@ aPos[1,1]+009,aPos[1,2]+150 SAY STR0009 SIZE 72,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Descricao
		@ aPos[1,1]+017,aPos[1,2]+150 MSGET oADesc VAR cADesc PICTURE "@!" SIZE aPos[1,4]-223,08 OF oTelaFin PIXEL COLOR CLR_BLACK WHEN .f.
		@ aPos[1,1]+009,aPos[1,4]-069 SAY STR0010 SIZE 72,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Tabela
		@ aPos[1,1]+017,aPos[1,4]-069 MSGET oATabel VAR cATabel SIZE 25,08 OF oTelaFin PIXEL COLOR CLR_BLACK WHEN .f.
		@ aPos[1,1]+009,aPos[1,4]-043 SAY STR0011 SIZE 72,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Coeficiente
		@ aPos[1,1]+017,aPos[1,4]-043 MSGET oAJuros VAR nAJuros PICTURE "@E 9.99999999" SIZE 42,08 OF oTelaFin PIXEL HASBUTTON COLOR CLR_BLACK WHEN .f.
	    //
		nCntFor := ( aPos[2,4] / 28 )
		@ aPos[2,1],aPos[2,2] TO aPos[2,3]+003,aPos[2,4]+001 LABEL STR0013 OF oTelaFin PIXEL // Novo Financiamento
		@ aPos[2,1]+011,aPos[2,2]+(nCntFor*0)+005 SAY STR0006  SIZE 72,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Valor
		@ aPos[2,1]+010,aPos[2,2]+(nCntFor*1)+005 MSGET oVlFin VAR nVlFin PICTURE "@E 99,999,999.99" VALID ( nVlFin >= 0 .and. FS_LISTAFI(1,cBanco,nVlFin,cComboFI,aParFin,nQtdParc,nPerEnt,nVlrEnt)) SIZE nCntFor*3,08 OF oTelaFin PIXEL HASBUTTON COLOR CLR_BLACK WHEN (nOpc == 3 .or. nOpc == 4 )
		@ aPos[2,1]+011,aPos[2,2]+(nCntFor*4)+007 SAY STR0012  SIZE 72,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Banco
		@ aPos[2,1]+010,aPos[2,2]+(nCntFor*5)+009 MSGET oBanco VAR cBanco PICTURE "@!" F3 "VAR" VALID FS_LISTAFI(1,cBanco,nVlFin,cComboFI,aParFin,nQtdParc,nPerEnt,nVlrEnt) SIZE nCntFor*1,08 OF oTelaFin PIXEL HASBUTTON COLOR CLR_BLACK WHEN (nOpc == 3 .or. nOpc == 4 )
		@ aPos[2,1]+011,aPos[2,2]+(nCntFor*7)+011 SAY STR0008  SIZE 72,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Tipo
		@ aPos[2,1]+010,aPos[2,2]+(nCntFor*8)+011 MSCOMBOBOX oComboFI VAR cComboFI VALID FS_LISTAFI(1,cBanco,nVlFin,cComboFI,aParFin,nQtdParc,nPerEnt,nVlrEnt) SIZE nCntFor*3,08 ITEMS aComboFI OF oTelaFin PIXEL COLOR CLR_BLACK WHEN (nOpc == 3 .or. nOpc == 4 )

		@ aPos[2,1]+011,aPos[2,2]+(nCntFor*12)+001 SAY STR0014  SIZE 72,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Parcelas
		@ aPos[2,1]+010,aPos[2,2]+(nCntFor*13)+007 MSCOMBOBOX oComboPar VAR cCQtdParc  SIZE 20,08 ITEMS aComboPar OF oTelaFin ON CHANGE FS_LISTAFI(1,cBanco,nVlFin,cComboFI,aParFin,nQtdParc,nPerEnt,nVlrEnt) PIXEL COLOR CLR_BLACK 
		@ aPos[2,1]+010,aPos[2,2]+(nCntFor*14)+009 MSGET oQtdParc VAR nQtdParc PICTURE "@E 9999" VALID FS_LISTAFI(1,cBanco,nVlFin,cComboFI,aParFin,nQtdParc,nPerEnt,nVlrEnt) SIZE nCntFor*1.5,08 OF oTelaFin PIXEL HASBUTTON COLOR CLR_BLACK WHEN (nOpc == 3 .or. nOpc == 4 )

		@ aPos[2,1]+011,aPos[2,2]+(nCntFor*16)+007 SAY STR0029  SIZE 72,8 OF oTelaFin PIXEL COLOR CLR_BLUE // % Entrada
		@ aPos[2,1]+010,aPos[2,2]+(nCntFor*18)+002 MSCOMBOBOX oComboPer VAR cCPerEnt  SIZE 20,08 ITEMS aComboPer OF oTelaFin ON CHANGE FS_LISTAFI(1,cBanco,nVlFin,cComboFI,aParFin,nQtdParc,nPerEnt,nVlrEnt) PIXEL COLOR CLR_BLACK 
		@ aPos[2,1]+010,aPos[2,2]+(nCntFor*19)+004 MSGET oPerEnt VAR nPerEnt PICTURE "@E 999.99" VALID ( nPerEnt >= 0 .and. nPerEnt <= 100 .and. FS_LISTAFI(1,cBanco,nVlFin,cComboFI,aParFin,nQtdParc,nPerEnt,nVlrEnt) ) SIZE nCntFor*1,08 OF oTelaFin PIXEL HASBUTTON COLOR CLR_BLACK WHEN (nOpc == 3 .or. nOpc == 4 )

		@ aPos[2,1]+011,aPos[2,2]+(nCntFor*21)+012 SAY STR0030  SIZE 72,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Vlr.Entrada
		@ aPos[2,1]+010,aPos[2,2]+(nCntFor*23.5)+003 MSCOMBOBOX oComboEnt VAR cCVlrEnt  SIZE 20,08 ITEMS aComboEnt OF oTelaFin ON CHANGE FS_LISTAFI(1,cBanco,nVlFin,cComboFI,aParFin,nQtdParc,nPerEnt,nVlrEnt) PIXEL COLOR CLR_BLACK 
		@ aPos[2,1]+010,aPos[2,2]+(nCntFor*24.5)+006 MSGET oVlrEnt VAR nVlrEnt PICTURE "@E 999,999.99" VALID ( nVlrEnt >=0 .and. FS_LISTAFI(1,cBanco,nVlFin,cComboFI,aParFin,nQtdParc,nPerEnt,nVlrEnt)) SIZE nCntFor*3,08 OF oTelaFin PIXEL HASBUTTON COLOR CLR_BLACK WHEN (nOpc == 3 .or. nOpc == 4 )
        //
		@ aPos[2,1]+025,aPos[2,2]+001 LISTBOX oLboxFAI FIELDS HEADER;
			STR0012, ; // Banco
			STR0008, ; // Tipo
			STR0010, ; // Tabela
			STR0014, ; // Parcelas
			STR0011, ; // Coeficiente
			STR0015, ; // Valor Parcela
			STR0016, ; // Minimo Entrada
			STR0017 ;  // Nivel de Retorno
			COLSIZES 80,50,80,40,50,50,50,50 SIZE aPos[2,4]-4,aPos[2,3]-aPos[2,1]-25 OF oTelaFin PIXEL ON DBLCLICK ( nPos:=oLboxFAI:nAt , IIf(FS_VALIDOK(nOpc,nVlFin,nPos,cNumAte,aVS9),( nOpcao:=1 , oTelaFin:End() ),.f.) )
		oLboxFAI:SetArray(aTabFAI)
		oLboxFAI:bLine := { || { aTabFAI[oLboxFAI:nAt,01],;
		aTabFAI[oLboxFAI:nAt,02],;
		aTabFAI[oLboxFAI:nAt,03]+" "+aTabFAI[oLboxFAI:nAt,11],;
		FG_AlinVlrs(Transform(aTabFAI[oLboxFAI:nAt,04],"@E 9999")),;
		FG_AlinVlrs(Transform(aTabFAI[oLboxFAI:nAt,05],"@E 9.99999999")),;
		FG_AlinVlrs(Transform(aTabFAI[oLboxFAI:nAt,06],"@E 999,999,999.99")),;
		aTabFAI[oLboxFAI:nAt,09],;
		aTabFAI[oLboxFAI:nAt,10]}}

	ACTIVATE MSDIALOG oTelaFin CENTER ON INIT (EnchoiceBar(oTelaFin,{|| nPos:=oLboxFAI:nAt , IIf(FS_VALIDOK(nOpc,nVlFin,nPos,cNumAte,aVS9),( nOpcao:=1 , oTelaFin:End() ),.f.) },{ || oTelaFin:End()},,))

Else // Zerar Financiamento/Leasing
	
	nOpcao := 1 // OK Tela
	nVlFin := 0 // Valor zerado
	
EndIf

If nOpcao == 1 // OK Tela
	If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
		lRet := .t.
		aParFin[01] := 0
		aParFin[09] := "" 
		aParFin[10] := "" 
		aParFin[11] := ""
		aParFin[13] := 0
		aParFin[14] := 0 
		If ( nVlFin == 0 .or. aTabFAI[nPos,7] == 0 ) .and. nLinhaVS9 > 0 // Retirar Financiamento ja Existente no VS9
			aVS9[2,nLinhaVS9,len(aVS9[2,nLinhaVS9])] := .t. // Deletar aCols do VS9
		Else // Fazer Financiamento
			If nPos > 0
				If aTabFAI[nPos,7] > 0
					aParFin[01] := nVlFin
					VAS->(DbGoTo(aTabFAI[nPos,7]))
					VAR->(DbGoTo(aTabFAI[nPos,8]))
					aParFin[09] := VAR->VAR_CODBCO // TAXA do DIA ( Banco )
					aParFin[10] := VAS->VAS_CODIGO // TAXA do DIA ( Tabela )
					aParFin[11] := VAR->VAR_TIPTAB // TAXA do DIA ( Tipo da Tabela )
					aParFin[13] := VAS->(RecNo())
					aParFin[14] := VAR->(RecNo())
			    	cTpPgVS9 := FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='1' AND VSA.VSA_CODCLI='"+VAR->VAR_BCOCLI+"' AND VSA.VSA_LOJA='"+VAR->VAR_BCOLOJ+"' AND VSA.D_E_L_E_T_=' '") // VSA_TIPO='1' ( Financiamento / Leasing )
					dDtTit   := ( dDataBase + FM_SQL("SELECT VSA.VSA_DIADEF FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+cTpPgVS9+"' AND VSA.D_E_L_E_T_=' '") )
	                If nLinhaVS9 > 0 .and. aVS9[2,nLinhaVS9,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] == cTpPgVS9 // Reutiliza registro do VS9
						nPos := nLinhaVS9
					Else // Inclui na aCols do VS9
						If nLinhaVS9 > 0 // Deletar Linha existente do VS9
							aVS9[2,nLinhaVS9,len(aVS9[2,nLinhaVS9])] := .t. // Deletar aCols do VS9
						EndIf
			           	aAdd(aVS9[2],Array(len(aVS9[1])+1)) 
			           	nPos := len(aVS9[2])
			    	EndIf
					aVS9[2,nPos,FG_POSVAR("VS9_NUMIDE","aHeaderVS9")] := PadR(aParFin[12],aVS9[1,FG_POSVAR("VS9_NUMIDE","aHeaderVS9"),4]," ") // Nro do Atendimento
					aVS9[2,nPos,FG_POSVAR("VS9_TIPOPE","aHeaderVS9")] := "V" // Veiculos
					aVS9[2,nPos,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] := cTpPgVS9
					aVS9[2,nPos,FG_POSVAR("VS9_DATPAG","aHeaderVS9")] := dDtTit
					aVS9[2,nPos,FG_POSVAR("VS9_VALPAG","aHeaderVS9")] := nVlFin
					aVS9[2,nPos,FG_POSVAR("VS9_REFPAG","aHeaderVS9")] := VAR->VAR_TIPTAB
					aVS9[2,nPos,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")] := "01"
					aVS9[2,nPos,len(aVS9[2,nPos])] := .f.
					If VAR->VAR_TACFIN == "1"
						nVlFin += VAS->VAS_VLRTAC
					EndIf	
					If VAS->VAS_COEFIC > 0
						nVlPar := ( nVlFin * VAS->VAS_COEFIC )
					EndIf
					nx := len(aVSE[2])
					For ni := (nx+1) to (nx+6)
			           	aAdd(aVSE[2],Array(len(aVSE[1])+1))
						aVSE[2,ni,FG_POSVAR("VSE_NUMIDE","aHeaderVSE")] := aParFin[12] // Nro do Atendimento
						aVSE[2,ni,FG_POSVAR("VSE_TIPOPE","aHeaderVSE")] := "V"
						aVSE[2,ni,FG_POSVAR("VSE_TIPPAG","aHeaderVSE")] := cTpPgVS9
						Do Case
							Case ni == (nx+1) // Cod.Banco
								aVSE[2,ni,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "1"+" "
								aVSE[2,ni,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "CODBCO"
								aVSE[2,ni,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := VAR->VAR_CODBCO
							Case ni == (nx+2) // Nome Banco
								aVSE[2,ni,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "2"+"-"
								aVSE[2,ni,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "NOMBCO"
								aVSE[2,ni,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := VAR->VAR_NOMBCO
							Case ni == (nx+3) // Qtde.Parcelas
								aVSE[2,ni,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "3"+" "
								aVSE[2,ni,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "QTDPAR"
								aVSE[2,ni,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := Alltrim(str(val(VAS->VAS_QTDPAR)))
							Case ni == (nx+4) // Valor Parcela
								aVSE[2,ni,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "4"+"x"
								aVSE[2,ni,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "VALPAR"
								aVSE[2,ni,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := Transform(nVlPar,"@E 999,999.99")
							Case ni == (nx+5) // Cod.Tabela
								aVSE[2,ni,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "5"+STR0010+":" // Tabela
								aVSE[2,ni,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "CODTAB"
								aVSE[2,ni,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := VAS->VAS_CODIGO
							Case ni == (nx+6) // Coeficiente
								aVSE[2,ni,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "6"+STR0011+":" // Coeficiente
								aVSE[2,ni,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "COEFIC"
								aVSE[2,ni,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := Transform(VAS->VAS_COEFIC,"@E 999,999.9999999")
						EndCase
						aVSE[2,ni,FG_POSVAR("VSE_TIPOCP","aHeaderVSE")] := "1"
						aVSE[2,ni,FG_POSVAR("VSE_TAMACP","aHeaderVSE")] := 15
						aVSE[2,ni,FG_POSVAR("VSE_DECICP","aHeaderVSE")] := 0
						aVSE[2,ni,FG_POSVAR("VSE_PICTCP","aHeaderVSE")] := "@!"
						aVSE[2,ni,FG_POSVAR("VSE_SEQUEN","aHeaderVSE")] := "01"
						aVSE[2,ni,len(aVSE[2,ni])] := .f.
					Next
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALIDOK ³ Autor ³ Andre Luis Almeida  ³ Data ³ 03/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida TUDO OK da Janela                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALIDOK(nOpc,nVlFin,nPos,cNumAte,aVS9)
Local lRet := .t.
If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
	If nVlFin > 0 .and. aTabFAI[nPos,7] <= 0
		lRet := .f.
		MsgStop(STR0018,STR0002) // Favor selecionar uma tabela para o Financiamento/Leasing! / Atencao
	EndIf
	/////////////////////////////////////////////////////////////////////
	// Validar o % / Vlr de Entrada em relacao ao Total do Atendimento //
	/////////////////////////////////////////////////////////////////////
	If !VX005VLENT(cNumAte,aTabFAI[nPos,7],aVS9) // Nro do Atendimento / VAS->(RecNo()) / aVS9
		lRet := .f.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LISTAFI ³ Autor ³ Andre Luis Almeida  ³ Data ³ 05/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lista as tabelas do FI no listbox                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LISTAFI(nTp,cBanco,nVlFin,cComboFI,aParFin,nQtdParc,nPerEnt,nVlrEnt)
Local cNivRet := GetNewPar("MV_FIBTABR","               ") // Niveis de Retorno possiveis quando nao informado o Cliente
Local nValPar := 0
Local nFinTot := 0
aTabFAI := {}
If nVlFin > 0 .and. (GetNewPar("MV_FIALLBC","S") == "S" .or. !Empty(cBanco))
	DbSelectArea("VAR")
	DbSetOrder(1)
	DbSeek(xFilial("VAR")+Alltrim(cBanco))
	While !Eof() .and. VAR->VAR_FILIAL == xFilial("VAR")
		If !Empty(cBanco)
			If VAR->VAR_CODBCO != cBanco
				DbSelectArea("VAR")
				DbSkip()
				Loop
			EndIf
		EndIf
		If !Empty(cComboFI)
			If VAR->VAR_TIPTAB != cComboFI
				DbSelectArea("VAR")
				DbSkip()
				Loop
			EndIf
		EndIf
		DbSelectArea("VZV")
		DbSetOrder(1)
		If !DbSeek(xFilial("VZV")+VAR->VAR_CODIGO+cFilAnt)
			DbSelectArea("VAR")
			DbSkip()
			Loop
		EndIf
		dbSelectArea("VAS")
		dbSetOrder(1)
		dbSeek(xFilial("VAS")+VAR->VAR_CODBCO+VAR->VAR_CODIGO+VAR->VAR_TIPTAB)
		While !Eof() .and. VAS->VAS_FILIAL == xFilial("VAS") .and. VAS->VAS_CODBCO+VAS->VAS_CODIGO+VAS->VAS_TIPTAB==VAR->VAR_CODBCO+VAR->VAR_CODIGO+VAR->VAR_TIPTAB
			// Filtrar Qtde de Parcelas
			Do Case
    		  Case cCQtdParc == "=" // igual
				If val(VAS->VAS_QTDPAR) <> nQtdParc
					dbSelectArea("VAS")
					dbSkip()
					Loop	
				EndIf
		      Case cCQtdParc == "<" // menor ou igual
				If val(VAS->VAS_QTDPAR) > nQtdParc
					dbSelectArea("VAS")
					dbSkip()
					Loop	
				EndIf
		      Case cCQtdParc == ">" // maior ou igual
				If val(VAS->VAS_QTDPAR) < nQtdParc
					dbSelectArea("VAS")
					dbSkip()
					Loop	
				EndIf
			EndCase

			// Filtrar % Entrada
			Do Case
				Case cCPerEnt == "=" // igual
					If VAS->VAS_PERENT <> nPerEnt
						dbSelectArea("VAS")
						dbSkip()
						Loop
					EndIf
				Case cCPerEnt == "<" // menor ou igual
					If VAS->VAS_PERENT > nPerEnt
						dbSelectArea("VAS")
						dbSkip()
						Loop
					EndIf
				Case cCPerEnt == ">" // maior ou igual
					If VAS->VAS_PERENT < nPerEnt
						dbSelectArea("VAS")
						dbSkip()
						Loop
					EndIf
			EndCase

			// Filtrar Vlr. Entrada
			Do Case
				Case cCVlrEnt == "=" // igual
					If VAS->VAS_VLRENT <> nVlrEnt
						dbSelectArea("VAS")
						dbSkip()
						Loop	
					EndIf
				Case cCVlrEnt == "<" // menor ou igual
					If VAS->VAS_VLRENT > nVlrEnt
						dbSelectArea("VAS")
						dbSkip()
						Loop	
					EndIf
		        Case cCVlrEnt == ">" // maior ou igual
					If VAS->VAS_VLRENT < nVlrEnt
						dbSelectArea("VAS")
						dbSkip()
						Loop	
					EndIf
			EndCase

			If FS_VALIDFI(.f.,aParFin,cNivRet) // VALIDA TABELA FI / VIGENCIA / NIVEL DE RETORNO DO USUARIO
				nValPar := 0
				nFinTot := nVlFin	
				If VAR->VAR_TACFIN == "1"
					nFinTot += VAS->VAS_VLRTAC
				EndIf	
				If VAS->VAS_COEFIC > 0
					nValPar := (nFinTot) * VAS->VAS_COEFIC
				EndIf
				cMinEnt := ""
				If VAS->VAS_PERENT > 0
					cMinEnt := FG_AlinVlrs(space(7)+Transform(VAS->VAS_PERENT,"@E 999.99")+"%")
				ElseIf VAS->VAS_VLRENT > 0
					cMinEnt := FG_AlinVlrs(Transform(VAS->VAS_VLRENT,"@E 999,999,999.99"))
				EndIf
				aadd(aTabFAI,{VAR->VAR_CODBCO+"-"+Left(VAR->VAR_NOMBCO,15),X3CBOXDESC("VAR_TIPTAB",VAR->VAR_TIPTAB),VAR->VAR_CODIGO,val(VAS->VAS_QTDPAR),VAS->VAS_COEFIC,nValPar,VAS->(RecNo()),VAR->(RecNo()),cMinEnt,VAS->VAS_NIVRET,VAR->VAR_DESCOD})
			EndIf
			dbSelectArea("VAS")
			dbSkip()
		Enddo
		dbSelectArea("VAR")
		dbSkip()
	Enddo
EndIf
If len(aTabFAI) == 0
	aAdd(aTabFAI, {"","","",0,0,0,0,0,"","",""} )
EndIf
If nTp > 0
	oLboxFAI:nAt := 1
	oLboxFAI:SetArray(aTabFAI)
	oLboxFAI:bLine := { || { aTabFAI[oLboxFAI:nAt,01],;
	aTabFAI[oLboxFAI:nAt,02],;
	aTabFAI[oLboxFAI:nAt,03]+" "+aTabFAI[oLboxFAI:nAt,11],;
	FG_AlinVlrs(Transform(aTabFAI[oLboxFAI:nAt,04],"@E 9999")),;
	FG_AlinVlrs(Transform(aTabFAI[oLboxFAI:nAt,05],"@E 9.99999999")),;
	FG_AlinVlrs(Transform(aTabFAI[oLboxFAI:nAt,06],"@E 999,999,999.99")),;
	aTabFAI[oLboxFAI:nAt,09],;
	aTabFAI[oLboxFAI:nAt,10]}}
	oLboxFAI:Refresh()
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALIDFI  ³ Autor ³ Andre Luis Almeida ³ Data ³ 05/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacos do FI                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALIDFI(lMsg,aParFin,cNivRet)
Local cNRUser := VA670NRET(xFilial("VAI"),__cUserID,dDataBase) // Retorna o Nivel de Retorno atual do Usuario Logado
Local lNveic  := .f.
Local ni      := 0
Local lRet    := .t.
Default lMsg  := .t.
If Empty(cNRUser) .or. ( cNRUser > VAS->VAS_NIVRET ) // Desconsiderar Taxas abaixo do nivel de retorno do usuario
	lRet := .f.
EndIf
If lRet .and. Empty(aParFin[2]+aParFin[3]) // Quando nao informado o cliente/loja, desconsiderar Taxas que nao estao com o nivel de retorno no parametro
	If !( VAS->VAS_NIVRET $ cNivRet )
		lRet := .f.
	EndIf
EndIf
If lRet .and. VAR->VAR_PESSOA <> "3"
	If (VAR->VAR_PESSOA == "1" .AND. aParFin[4] <> "F") .OR. (VAR->VAR_PESSOA == "2" .AND. aParFin[4] <> "J")
		If lMsg
			MsgStop(STR0019,STR0002) // Tabela nao se aplica ao tipo de pessoa (Fisica/Juridica). / Atencao
		EndIf
		lRet := .f.
	EndIf
EndIf
If lRet
	If len(aParFin) > 14 // Possui vetor dos N veiculos do Atendimento ?
		If len(aParFin[15]) > 0 // Possui veiculos no Atendimento ?
			lNveic := .t.
		Else
			aParFin[15] := {} // Cria aParFin[15]
			aAdd(aParFin[15],{aParFin[5],aParFin[6],aParFin[7],aParFin[8],""}) // Preenche aParFin[15]
		EndIf
	Else
		aAdd(aParFin,{}) // Cria aParFin[15]
		aAdd(aParFin[15],{aParFin[5],aParFin[6],aParFin[7],aParFin[8],""}) // Preenche aParFin[15]
	EndIf
	For ni := 1 to len(aParFin[15])

		If !Empty(Alltrim(aParFin[15,ni,1]+aParFin[15,ni,3]+aParFin[15,ni,4]+aParFin[15,ni,5])) // Verificar se o veiculo nao foi EXCLUIDO no Atendimento

			If VAR->VAR_APLICA <> "3"
				If val(VAR->VAR_APLICA)-1 <> val(aParFin[15,ni,2]) // aParFin[6]
					If lMsg
						MsgStop(STR0020,STR0002) // Tabela nao se aplica ao estado do veiculo (Novo/Usado). / Atencao
					EndIf
					lRet := .f.
					Exit
				EndIf
			EndIf   	
			If VAR->(FieldPos("VAR_CODMAR")) > 0 .and. !Empty(VAR->VAR_CODMAR)
				If !Empty(Alltrim(aParFin[15,ni,5])) .and. VAR->VAR_CODMAR <> aParFin[15,ni,5]
					If lMsg
						MsgStop(STR0024,STR0002) // Tabela nao se aplica a Marca do veiculo. / Atencao
					EndIf
					lRet := .f.
					Exit
				EndIf
			EndIf
			If !Empty(VAR->VAR_GRUMOD)
				If !(Alltrim(aParFin[15,ni,3]) $ Alltrim(VAR->VAR_GRUMOD)) // aParFin[7]
					If lMsg
						MsgStop(STR0021,STR0002) // Tabela nao se aplica ao Grupo de Modelo do veiculo. / Atencao
					EndIf
					lRet := .f.
					Exit
				EndIf
			EndIf
			If !Empty(VAR->VAR_MODVEI)
				If Alltrim(VAR->VAR_MODVEI) <> Alltrim(aParFin[15,ni,4]) // aParFin[8]
					If lMsg
						MsgStop(STR0022,STR0002) // Tabela nao se aplica ao Modelo do veiculo. / Atencao
					EndIf
					lRet := .f.
					Exit
				EndIf
			EndIf
			If !Empty(VAS->VAS_DATFIN)
				If (VAS->VAS_DATINI > dDataBase) .or. (VAS->VAS_DATFIN < dDataBase)
					If lMsg
						MsgStop(STR0023,STR0002) // Tabela esta fora do periodo de validade. / Atencao
					EndIf
					lRet := .f.
					Exit
				EndIf
			EndIf
			If !Empty(aParFin[15,ni,1]) // aParFin[5] - Existe VV1 ( CHAINT )
				VV1->(DbSetOrder(1))
				VV1->(DbSeek(xFilial("VV1")+aParFin[15,ni,1])) // aParFin[5]
				If VAR->(FieldPos("VAR_ANOINI")) > 0
					If !Empty(VAR->VAR_ANOINI) .or. !Empty(VAR->VAR_ANOFIN)
						If VV1->VV1_FABMOD < VAR->VAR_ANOINI .or. VV1->VV1_FABMOD > VAR->VAR_ANOFIN
							If lMsg
								MsgStop(STR0025,STR0002) // Tabela nao se aplica ao Ano de Fabricacao/Modelo do veiculo. / Atencao
							EndIf
							lRet := .f.
							Exit
						EndIf
					EndIf
				EndIf
			EndIf

		EndIf

	Next    	
	If !lNveic
		aParFin[15] := {}
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VX005VLENT ³ Autor ³ Andre Luis Almeida  ³ Data ³ 20/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida % ou Vlr Entrada p/ utilizar Financiamento/Leasing  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nNumAte = Numero do Atendimento                            ³±±
±±³          ³ nRecVAS = VAS->(RecNo())                                   ³±±
±±³          ³ aVS9 = Vetor com aHeader/aCols das parcelas do Atendimento ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX005VLENT(cNumAte,nRecVAS,aVS9)
Local lRet    := .t.
Local cMsg    := STR0026+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Financiamento/Leasing necessita de Valor Minimo de Entrada!
Local ni      := 0
Local nValEnt := 0
Local nValAux := 0
Private aHeaderVS9 := aClone(aVS9[1])
VV0->(DbSetOrder(1))
If VV0->(DbSeek(xFilial("VV0")+cNumAte))
	DbSelectArea("VAS")
	DbGoto(nRecVAS) // VAS->(RecNo())
	If VAS->VAS_PERENT > 0 // %
		nValEnt := ( VV0->VV0_VALTOT * ( VAS->VAS_PERENT / 100 ) ) // Calcular o Vlr da Entrada
		cMsg    += Transform(VAS->VAS_PERENT,"@E 999.99")+STR0027 // % do Valor do Atendimento.
	ElseIf VAS->VAS_VLRENT > 0 // Vlr de Entrada Fixo
		nValEnt := VAS->VAS_VLRENT
		cMsg    += Transform(VAS->VAS_VLRENT,"@E 999,999,999.99")
	EndIf
	VSA->(DbSetOrder(1))
	For ni := 1 to len(aVS9[2])
		If !aVS9[2,ni,len(aVS9[2,ni])]
			VSA->(DbSeek(xFilial("VSA")+aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")]))
			If VSA->VSA_TIPO <> "1" // VSA_TIPO <> '1' ( Tudo menos Financiamento )
				nValAux += aVS9[2,ni,FG_POSVAR("VS9_VALPAG","aHeaderVS9")]
			EndIf
		EndIf
	Next
	If nValAux < nValEnt
		MsgStop(cMsg,STR0002) // / Atencao
		lRet := .f.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VX005F3RET  ³ Autor ³ Andre / Rafael     ³ Data ³ 06/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Nivel de Retorno                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc ( 2=Visualizar / 3=Incluir / 4=Alterar / 5=Excluir )  ³±±
±±³          ³ cRetDef = Nivel Retorno Default, posiciona automaticamente)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX005F3RET(nOpc,cRetDef)
Local aRet      := {}
Local aParamBox := {}
Local aCombo    := {}  
Local ni        := 1
Local cRetorno  := cRetDef
If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
	For ni := 0 to 50
		aadd(aCombo,StrZero(ni,2))
	Next
	AADD(aParamBox,{2,STR0017,cRetDef,aCombo,50,"",.F.}) // Nivel de Retorno
Else
	AADD(aParamBox,{1,STR0017,cRetDef,"@!","","",".F.",50,.F.}) // Nivel de Retorno
EndIf
If ParamBox(aParamBox,STR0017,@aRet,,,,,,,,.f.) // Nivel de Retorno
	cRetorno := aRet[1]
EndIf
Return(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VX005TXDIA  ³ Autor ³ Andre Luis Almeida ³ Data ³ 06/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Simulacao do Financiamento ( TAXA DO DIA )                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aParFin (Vetor de Parametros)                              ³±±
±±º			 ³	 aParFin[01] = Valor                                      º±±
±±º			 ³	 aParFin[02] = Cliente                                    º±±
±±º			 ³	 aParFin[03] = Loja                                       º±±
±±º			 ³	 aParFin[04] = Tipo de Pessoa (F-isica/J-uridica)         º±±
±±º			 ³	 aParFin[05] = Chassi Interno (CHAINT)                    º±±
±±º			 ³	 aParFin[06] = Estado do Veiculo (Novo/Usado)             º±±
±±º			 ³	 aParFin[07] = Grupo do Modelo                            º±±
±±º			 ³	 aParFin[08] = Modelo do Veiculo                          º±±
±±º			 ³	 aParFin[09] = TAXA do DIA ( Banco )                      º±±
±±º			 ³	 aParFin[10] = TAXA do DIA ( Tabela )                     º±±
±±º			 ³	 aParFin[11] = TAXA do DIA ( Tipo da Tabela )             º±±
±±º			 ³	 aParFin[12] = Nro do Atendimento                         º±±
±±º			 ³	 aParFin[13] = VAS->(RecNo())                             º±±
±±º			 ³	 aParFin[14] = VAR->(RecNo())                             º±±
±±º			 ³	 aParFin[15] = Vetor com os N veiculos do Atendimento     º±±
±±º			 ³	  - [15,n,1] = Chassi Interno (CHAINT)                    º±±
±±º			 ³	  - [15,n,2] = Estado do Veiculo (Novo/Usado)             º±±
±±º			 ³	  - [15,n,3] = Grupo do Modelo                            º±±
±±º			 ³	  - [15,n,4] = Modelo do Veiculo                          º±±
±±º			 ³	  - [15,n,5] = Marca do Veiculo                           º±±
±±³          ³ aSimFinanc (Vetor por Referencia) - Retorna Vetor ListBox  ³±±
±±³			 ³	 Tipo de Tabela (Financiamento/Leasing)                   ³±±
±±³			 ³	 Qtde de Parcelas                                         ³±±
±±³			 ³	 Valor da Parcela                                         ³±±
±±³			 ³	 RecNo do VAS                                             ³±±
±±³			 ³	 RecNo do VAR                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX005TXDIA(aParFin,aSimFinanc)
Local cNivRet := GetNewPar("MV_FIBTABR","               ") // Niveis de Retorno possiveis quando nao informado o Cliente
Local cBcoTab := GetNewPar("MV_FIBCTBV","               ") // Banco, Tabela e Tipo da Tabela utilizado na Simulacao ( TAXA DO DIA )
Local cFIBco  := substr(cBcoTab,1,len(VAS->VAS_CODBCO))
Local cFITab  := substr(cBcoTab,len(cFIBco)+1,len(VAS->VAS_CODIGO))
Local cFITip  := substr(cBcoTab,len(cFIBco+cFITab)+1,1)
Local nValFin := 0
Local nValPar := 0
If !Empty(aParFin[09]) // TAXA do DIA ( Banco )
	cFIBco := aParFin[09]
EndIf
If !Empty(aParFin[10]) // TAXA do DIA ( Tabela )
	cFITab := aParFin[10]
EndIf
If !Empty(aParFin[11]) // TAXA do DIA ( Tipo da Tabela )
	cFITip := aParFin[11]
EndIf
aSimFinanc := {}
If aParFin[1] > 0
	cFIBco := left(cFIBco+space(10),TamSx3("VAS_CODBCO")[1])
	cFITab := left(cFITab+space(10),TamSx3("VAS_CODIGO")[1])
	DbSelectArea("VAR")
	DbSetOrder(1)
	DbSeek(xFilial("VAR")+cFIBco+cFITab)
	While !Eof() .and. VAR->VAR_FILIAL == xFilial("VAR") .and. VAR->VAR_CODBCO==cFIBco .and. VAR->VAR_CODIGO==cFITab
		If !Empty(cFITip)
			If VAR->VAR_TIPTAB <> cFITip // Financiamento / Leasing
				DbSelectArea("VAR")
				DbSkip()
				Loop
			EndIf
		EndIf
		DbSelectArea("VZV")
		DbSetOrder(1)
		If !DbSeek(xFilial("VZV")+VAR->VAR_CODIGO+cFilAnt)
			DbSelectArea("VAR")
			DbSkip()
			Loop
		EndIf
		DbSelectArea("VAS")
		DbSetOrder(1)
		DbSeek(xFilial("VAS")+VAR->VAR_CODBCO+VAR->VAR_CODIGO+VAR->VAR_TIPTAB)
		While !Eof() .and. VAS->VAS_FILIAL == xFilial("VAS") .and. VAS->VAS_CODBCO+VAS->VAS_CODIGO+VAS->VAS_TIPTAB==VAR->VAR_CODBCO+VAR->VAR_CODIGO+VAR->VAR_TIPTAB
			If FS_VALIDFI(.f.,aParFin,cNivRet) // VALIDA TABELA FI / VIGENCIA / NIVEL DE RETORNO DO USUARIO
				nValFin := aParFin[1]
				If VAR->VAR_TACFIN == "1"
					nValFin += VAS->VAS_VLRTAC
				EndIf	
				If VAS->VAS_COEFIC > 0
					nValPar := ( nValFin * VAS->VAS_COEFIC )
				EndIf
				aadd(aSimFinanc,{X3CBOXDESC("VAR_TIPTAB",VAR->VAR_TIPTAB),val(VAS->VAS_QTDPAR),nValPar,VAS->(RecNo()),VAR->(RecNo())})
			EndIf
			DbSelectArea("VAS")
			DbSkip()
		EndDo
		DbSelectArea("VAR")
		DbSkip()
	EndDo
EndIf
If len(aSimFinanc) <= 0
	aadd(aSimFinanc,{"",0,0,0,0})
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VX005TXPAD  ³ Autor ³ Andre Luis Almeida ³ Data ³ 21/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Volta TAXA do DIA padrao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aParFin (Vetor de Parametros)                              ³±±
±±º			 ³	 aParFin[01] = Valor                                      º±±
±±º			 ³	 aParFin[02] = Cliente                                    º±±
±±º			 ³	 aParFin[03] = Loja                                       º±±
±±º			 ³	 aParFin[04] = Tipo de Pessoa (F-isica/J-uridica)         º±±
±±º			 ³	 aParFin[05] = Chassi Interno (CHAINT)                    º±±
±±º			 ³	 aParFin[06] = Estado do Veiculo (Novo/Usado)             º±±
±±º			 ³	 aParFin[07] = Grupo do Modelo                            º±±
±±º			 ³	 aParFin[08] = Modelo do Veiculo                          º±±
±±º			 ³	 aParFin[09] = TAXA do DIA ( Banco )                      º±±
±±º			 ³	 aParFin[10] = TAXA do DIA ( Tabela )                     º±±
±±º			 ³	 aParFin[11] = TAXA do DIA ( Tipo da Tabela )             º±±
±±º			 ³	 aParFin[12] = Nro do Atendimento                         º±±
±±º			 ³	 aParFin[13] = VAS->(RecNo())                             º±±
±±º			 ³	 aParFin[14] = VAR->(RecNo())                             º±±
±±º			 ³	 aParFin[15] = Vetor com os N veiculos do Atendimento     º±±
±±º			 ³	  - [15,n,1] = Chassi Interno (CHAINT)                    º±±
±±º			 ³	  - [15,n,2] = Estado do Veiculo (Novo/Usado)             º±±
±±º			 ³	  - [15,n,3] = Grupo do Modelo                            º±±
±±º			 ³	  - [15,n,4] = Modelo do Veiculo                          º±±
±±º			 ³	  - [15,n,5] = Marca do Veiculo                           º±±
±±³          ³ aSimFinanc (Vetor por Referencia) - Retorna Vetor ListBox  ³±±
±±³			 ³	 Tipo de Tabela (Financiamento/Leasing)                   ³±±
±±³			 ³	 Qtde de Parcelas                                         ³±±
±±³			 ³	 Valor da Parcela                                         ³±±
±±³			 ³	 RecNo do VAS                                             ³±±
±±³			 ³	 RecNo do VAR                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX005TXPAD(aParFin,aSimFinanc)
// Deixar em Branco variaveis para pegar automaticamente a TAXA do DIA padrao
aParFin[09] := "" // TAXA do DIA ( Banco )
aParFin[10] := "" // TAXA do DIA ( Tabela )
aParFin[11] := "" // TAXA do DIA ( Tipo da Tabela )
VX005TXDIA(@aParFin,@aSimFinanc)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX005TXUTIL º Autor ³ Andre Luis Almeida º Data ³ 21/04/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Utilizar Financiamento da TAXA do DIA  (BOTAO NA TELA)     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aParFin (Vetor de Parametros)                              º±±
±±º			 ³	 aParFin[01] = Valor                                      º±±
±±º			 ³	 aParFin[02] = Cliente                                    º±±
±±º			 ³	 aParFin[03] = Loja                                       º±±
±±º			 ³	 aParFin[04] = Tipo de Pessoa (F-isica/J-uridica)         º±±
±±º			 ³	 aParFin[05] = Chassi Interno (CHAINT)                    º±±
±±º			 ³	 aParFin[06] = Estado do Veiculo (Novo/Usado)             º±±
±±º			 ³	 aParFin[07] = Grupo do Modelo                            º±±
±±º			 ³	 aParFin[08] = Modelo do Veiculo                          º±±
±±º			 ³	 aParFin[09] = TAXA do DIA ( Banco )                      º±±
±±º			 ³	 aParFin[10] = TAXA do DIA ( Tabela )                     º±±
±±º			 ³	 aParFin[11] = TAXA do DIA ( Tipo da Tabela )             º±±
±±º			 ³	 aParFin[12] = Nro do Atendimento                         º±±
±±º			 ³	 aParFin[13] = VAS->(RecNo())                             º±±
±±º			 ³	 aParFin[14] = VAR->(RecNo())                             º±±
±±º			 ³	 aParFin[15] = Vetor com os N veiculos do Atendimento     º±±
±±º			 ³	  - [15,n,1] = Chassi Interno (CHAINT)                    º±±
±±º			 ³	  - [15,n,2] = Estado do Veiculo (Novo/Usado)             º±±
±±º			 ³	  - [15,n,3] = Grupo do Modelo                            º±±
±±º			 ³	  - [15,n,4] = Modelo do Veiculo                          º±±
±±º			 ³	  - [15,n,5] = Marca do Veiculo                           º±±
±±º          ³ aVS9 (Pagamentos)                                          º±±
±±º			 ³	 aVS9[1] = aHeader                                        º±±
±±º          ³   aVS9[2] = aCols                                          º±±
±±º          ³ aVSE (Observacoes Pagamento)                               º±±
±±º			 ³	 aVSE[1] = aHeader                                        º±±
±±º          ³   aVSE[2] = aCols                                          º±±
±±º          ³ aSimFinanc (Vetor por Referencia) - Retorna Vetor ListBox  º±±
±±º			 ³	 Tipo de Tabela (Financiamento/Leasing)                   º±±
±±º			 ³	 Qtde de Parcelas                                         º±±
±±º			 ³	 Valor da Parcela                                         º±±
±±º			 ³	 RecNo do VAS                                             º±±
±±º			 ³	 RecNo do VAR                                             º±±
±±º          ³ nLinha (linha referente ao ListBox do vetor aSimFinanc)    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX005TXUTIL(aParFin,aVS9,aVSE,aSimFinanc,nLinha)
Local nx        := 0
Local ni        := 0
Local nPos      := 0
Local nVlFin    := aParFin[1]
Local nVlPar    := 0
Local cTpPgVS9  := ""
Local cTpPagCon := FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='3' AND VSA.D_E_L_E_T_=' '") // VSA_TIPO='3' ( Consorcio )
Local cTpFiname := FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='6' AND VSA.D_E_L_E_T_=' '") // VSA_TIPO='6' ( Finame )
Local nLinhaVS9 := 0
Private aHeaderVS9 := aClone(aVS9[1])
Private aHeaderVSE := aClone(aVSE[1])
aVSE[2] := {}
For ni := 1 to len(aVS9[2]) // Selecionar o Financiamento / Leasing ja utilizado neste Atendimento
	If !aVS9[2,ni,len(aVS9[2,ni])]
		If !Empty(aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")])
			If !Empty(cTpPagCon) // Verifica se ja existe Consorcio NAO quitado para o Atendimento
				If aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] == cTpPagCon
					If left(aVS9[2,ni,FG_POSVAR("VS9_REFPAG","aHeaderVS9")],1) == "0" // Existe Consorcio NAO quitado - 
						MsgStop(STR0003,STR0002) // Ja existe Consorcio NAO quitado para este Atendimento. Impossivel incluir Financiamento! / Atencao
						Return(.f.)
					EndIf
				EndIf
			EndIf
			If !Empty(cTpFiname) // Verifica se ja existe Finame para o Atendimento
				If aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] == cTpFiname
					MsgStop(STR0004,STR0002) // Ja existe Finame para este Atendimento. Impossivel incluir Financiamento! / Atencao
					Return(.f.)
				EndIf
			EndIf
		EndIf
		VSA->(DbSetOrder(1))
		VSA->(DbSeek(xFilial("VSA")+aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")]))
		If VSA->VSA_TIPO == "1"
			nLinhaVS9 := ni // Linha do aCols do VS9
           	aAdd(aVSE[2],Array(len(aVSE[1])+1))
           	aVSE[2,1,FG_POSVAR("VSE_NUMIDE","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_NUMIDE","aHeaderVS9")]
			aVSE[2,1,FG_POSVAR("VSE_TIPOPE","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_TIPOPE","aHeaderVS9")]
			aVSE[2,1,FG_POSVAR("VSE_TIPPAG","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")]
			aVSE[2,1,FG_POSVAR("VSE_SEQUEN","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")]
			aVSE[2,1,len(aVSE[2,1])] := .t.
		EndIf
	EndIf
Next
If aSimFinanc[nLinha,4] == 0 .or. aSimFinanc[nLinha,5] == 0
	MsgStop(STR0028,STR0002) // Taxa do Dia nao informada. Impossivel incluir Financiamento! / Atencao
	Return(.f.)
EndIf
/////////////////////////////////////////////////////////////////////
// Validar o % / Vlr de Entrada em relacao ao Total do Atendimento //
/////////////////////////////////////////////////////////////////////
If !VX005VLENT(aParFin[12],aSimFinanc[nLinha,4],aVS9) // Nro do Atendimento / VAS->(RecNo()) / aVS9
	Return(.f.)
EndIf
VAS->(DbGoTo(aSimFinanc[nLinha,4]))
VAR->(DbGoTo(aSimFinanc[nLinha,5]))
aParFin[09] := VAR->VAR_CODBCO // TAXA do DIA ( Banco )
aParFin[10] := VAS->VAS_CODIGO // TAXA do DIA ( Tabela )
aParFin[11] := VAR->VAR_TIPTAB // TAXA do DIA ( Tipo da Tabela )
aParFin[13] := VAS->(RecNo())
aParFin[14] := VAR->(RecNo())
If nLinhaVS9 > 0 // Reutiliza registro do VS9
	nPos := nLinhaVS9
Else // Inclui na aCols do VS9
   	aAdd(aVS9[2],Array(len(aVS9[1])+1)) 
   	nPos := len(aVS9[2])
EndIf
cTpPgVS9 := FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='1' AND VSA.VSA_CODCLI='"+VAR->VAR_BCOCLI+"' AND VSA.VSA_LOJA='"+VAR->VAR_BCOLOJ+"' AND VSA.D_E_L_E_T_=' '") // VSA_TIPO='1' ( Financiamento / Leasing )
aVS9[2,nPos,FG_POSVAR("VS9_NUMIDE","aHeaderVS9")] := PadR(aParFin[12],aVS9[1,FG_POSVAR("VS9_NUMIDE","aHeaderVS9"),4]," ") // Nro do Atendimento
aVS9[2,nPos,FG_POSVAR("VS9_TIPOPE","aHeaderVS9")] := "V" // Veiculos
aVS9[2,nPos,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] := cTpPgVS9
aVS9[2,nPos,FG_POSVAR("VS9_DATPAG","aHeaderVS9")] := dDataBase
aVS9[2,nPos,FG_POSVAR("VS9_VALPAG","aHeaderVS9")] := nVlFin
aVS9[2,nPos,FG_POSVAR("VS9_REFPAG","aHeaderVS9")] := VAR->VAR_TIPTAB
aVS9[2,nPos,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")] := "01"
aVS9[2,nPos,len(aVS9[2,nPos])] := .f.
If VAR->VAR_TACFIN == "1"
	nVlFin += VAS->VAS_VLRTAC
EndIf
If VAS->VAS_COEFIC > 0
	nVlPar := ( nVlFin * VAS->VAS_COEFIC )
EndIf
nx := len(aVSE[2])
For ni := (nx+1) to (nx+6)
   	aAdd(aVSE[2],Array(len(aVSE[1])+1))
	aVSE[2,ni,FG_POSVAR("VSE_NUMIDE","aHeaderVSE")] := aParFin[12] // Nro do Atendimento
	aVSE[2,ni,FG_POSVAR("VSE_TIPOPE","aHeaderVSE")] := "V"
	aVSE[2,ni,FG_POSVAR("VSE_TIPPAG","aHeaderVSE")] := cTpPgVS9
	Do Case
		Case ni == (nx+1) // Cod.Banco
			aVSE[2,ni,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "1"+" "
			aVSE[2,ni,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "CODBCO"
			aVSE[2,ni,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := VAR->VAR_CODBCO
		Case ni == (nx+2) // Nome Banco
			aVSE[2,ni,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "2"+"-"
			aVSE[2,ni,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "NOMBCO"
			aVSE[2,ni,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := VAR->VAR_NOMBCO
		Case ni == (nx+3) // Qtde.Parcelas
			aVSE[2,ni,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "3"+" "
			aVSE[2,ni,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "QTDPAR"
			aVSE[2,ni,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := Alltrim(str(val(VAS->VAS_QTDPAR)))
		Case ni == (nx+4) // Valor Parcela
			aVSE[2,ni,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "4"+"x"
			aVSE[2,ni,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "VALPAR"
			aVSE[2,ni,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := Transform(nVlPar,"@E 999,999.99")
		Case ni == (nx+5) // Cod.Tabela
			aVSE[2,ni,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "5"+STR0010+":" // Tabela
			aVSE[2,ni,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "CODTAB"
			aVSE[2,ni,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := VAS->VAS_CODIGO
		Case ni == (nx+6) // Coeficiente
			aVSE[2,ni,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "6"+STR0011+":" // Coeficiente
			aVSE[2,ni,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "COEFIC"
			aVSE[2,ni,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := Transform(VAS->VAS_COEFIC,"@E 999,999.9999999")
	EndCase
	aVSE[2,ni,FG_POSVAR("VSE_TIPOCP","aHeaderVSE")] := "1"
	aVSE[2,ni,FG_POSVAR("VSE_TAMACP","aHeaderVSE")] := 15
	aVSE[2,ni,FG_POSVAR("VSE_DECICP","aHeaderVSE")] := 0
	aVSE[2,ni,FG_POSVAR("VSE_PICTCP","aHeaderVSE")] := "@!"
	aVSE[2,ni,FG_POSVAR("VSE_SEQUEN","aHeaderVSE")] := "01"
	aVSE[2,ni,len(aVSE[2,ni])] := .f.
Next
Return(.t.)