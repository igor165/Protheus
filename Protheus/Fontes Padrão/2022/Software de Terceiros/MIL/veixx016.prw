// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 08     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEIXX016.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXX016 º Autor ³ Rafael             º Data ³  20/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Prioridade de Venda                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpcG (2-Visualizar/4-Alterar/3-Incluir)                   º±±
±±º          ³ cTipo   - Reserva/Desreserva/Cancela/Finaliza              º±±
±±º			 ³ cNumtra - Nro do Atendimento                               º±±
±±º			 ³ cChasin - Chaint                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX016(nOpcG,cTipo,cNumtra,cChasin)
//variaveis controle de janela
Local aTELA     := FWGetDialogSize(oMainWnd)

Local cMsg      := ""
Local aArea     := {}

Private cVisual  := "R"
Private aResTem  := {}
Private cAtend   := cNumtra
Private cChaint  := cChasin
Private nOpc     := nOpcG
Private cAteAtu  := ""
Private cStaAtu  := ""
Private oBrowseR
Private lReserva := ""
Private lDesres  := ""
Private lRenRes  := ""
Private aNewBot  := {}

//GUARDA ALIAS ATUAL.
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
Else
	DbSelectArea("VV0")
EndIf
aArea := sGetArea(aArea,"VV0")
aArea := sGetArea(aArea,"VVA")
aArea := sGetArea(aArea,"VV1")

//verificar se existe chaint se nao pegar pelo atendimento.
if Empty(cChaint)
	dbSelectArea("VV0")
	dbSetOrder(1)
	if dbSeek(xFilial("VV0")+cAtend)
		DbSelectArea("VVA")
		DbSetOrder(1)
		if dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
			dbSelectArea("VV1")
			dbSetOrder(1)
			IF dbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
				cChaint := VV1->VV1_CHAINT
			Else
				MsgStop(STR0002,STR0004) //Veiculo não encontrado! / Atencao
				Return(.t.)
			EndIF
		EndIf
	EndIF
else
	dbSelectArea("VV1")
	dbSetOrder(1)
	If !dbSeek(xFilial("VV1")+cChaint)
		MsgStop(STR0002,STR0004)//Veiculo não encontrado! / Atencao
		Return(.t.)
	EndIf
EndIF

If !VX016VALID( cNumtra , VV1->VV1_CHAINT , .f. ) // Prioridade de Venda - RESERVA TEMPORARIA
	Return .t.
EndIf

//valida se existe reserva para o veiculo
If !VXX120011_ValidaReservado(cNumtra,VV1->VV1_CHAINT,@cMsg) // Verifica se esta reservado em outro Atendimento
	Aviso(STR0004,cMsg,{"OK"},3) // Atencao / OK
	Return .t.
EndIf

//Levanta prioridade de venda
FS_LEVANTA()

IF cTipo$"0/1"
	DEFINE MSDIALOG oResTemp TITLE STR0001 FROM aTELA[1], aTELA[2] TO aTELA[3], aTELA[4] PIXEL // Prioridade de Venda

	// Cria Layer e as linhas
	oLayer := FWLayer():New()
	oLayer:Init(oResTemp, .F., .T.)
	oLayer:AddLine("TOP", 100, .F.)

	// Cria as colunas
	oLayer:AddCollumn("TCOL", 100, .F., "TOP")

	// Variáveis (padrão) para uso das colunas criadas
	cTopCol := oLayer:getColPanel("TCOL", "TOP")

	lReserva := "R" $ cVisual .And. Alltrim(Str(nOpc)) $ "3/4"
	lDesres  := "D" $ cVisual .And. Alltrim(Str(nOpc)) $ "3/4"
	lRenRes  := "S" $ cVisual .And. Alltrim(Str(nOpc)) $ "3/4"

	AADD(aNewBot, { "oReserva", {|| FS_RESVEI("1", lReserva)}, STR0009 }) // Reserva
	AADD(aNewBot, { "oDesres",  {|| FS_DESRESER(aResTem[len(aResTem), 12], "1", lDesres), FS_LEVANTA(.t.)}, STR0010 }) // Desreserva
	AADD(aNewBot, { "oRenRes",  {|| FS_RESVEI("2", lRenRes)}, STR0011 }) // Renovar Reserva

	// Ponto de entrada para inclusão de botões no Ações Relacionadas
	If ExistBlock("VXX16BOT")
		aNewBot := ExecBlock("VXX16BOT", .f., .f., {aNewBot})
	EndIf

	// Browse (Reservas)
	// Usando Componente FWFormBrowse já que está sendo usado array por
	// hierarquia do FWBrowse e esse componente possui inclusão de botão
	oBrowseR := FWFormBrowse():New()
	oBrowseR:SetOwner(cTopCol)
	oBrowseR:SetDataArray()
	oBrowseR:SetArray(aResTem)
	oBrowseR:SetColumns(OR0100026_ColunasBrowseReservadas())
	oBrowseR:DisableReport()
	oBrowseR:Activate()

	ACTIVATE MSDIALOG oResTemp CENTER ON INIT EnchoiceBar(oResTemp, { || oResTemp:End() }, {|| oResTemp:End() },, aNewBot)
Else
	If aResTem[len(aResTem),2]=="1"
		FS_DESRESER(aResTem[len(aResTem),12 ],cTipo)
	EndIF
EndIF
// Volta posicoes originais dos Arquivos
DbSelectArea("VV1")
sRestArea(aArea)
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | FS_RESVEI  | Autor | Rafael Goncalves      | Data | 21/07/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Realiza gravacao da prioridade de venda do veiculo.          |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
##|Parametros| cTipo - 1 gravacao/2-renovacao                               |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_RESVEI(cTipo, lEfetuar)
Local nQtdRes := 0 //quantidade de reserva para o usuario.
Local nQtdRen := 0 //quantidade de Renovacao.
Local dDtRes := dDataBase
Local nHorRes := val(SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2))
Local nMinDesr:= GetNewPar("MV_RESERVT",60)//parametro minutos para desrreserva
Local cHorTmp := ""
Local cQuery  := ""
Local cQAlias := "SQLVRE"

Default lEfetuar := .t.

If lEfetuar
	cQuery := "SELECT VRE.VRE_USURES , VRE.VRE_STATUS , VRE.VRE_DATDES , VRE.VRE_HORDES , VRE.VRE_NUMATE , VRE.VRE_CHAINT , VRE.VRE_QTDREN , VRE.R_E_C_N_O_ "
	cQuery += "FROM "+RetSqlName("VRE")+" VRE WHERE VRE.VRE_FILIAL='"+xFilial("VRE")+"' AND "
	cQuery += "VRE.D_E_L_E_T_=' ' ORDER BY VRE.R_E_C_N_O_"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() )
		//armazenar quantidade de reservas validas para o usuario.
		If ( cQAlias )->( VRE_USURES ) == __CUSERID
			IF ( cQAlias )->( VRE_STATUS ) == "1"
				dDtRes	:= stod(( cQAlias )->( VRE_DATDES ))
				If dDtRes == dDataBase // data da reserva for igual a data de hoje
					cHorTmp	:= strzero(( cQAlias )->( VRE_HORDES ),4)
					If cHorTmp > SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)//se a hora for maior que a hora atual
						nQtdRes += 1
					EndIf
				ElseIf dDtRes > dDataBase // data da reserva for maior que a data de hoje
					nQtdRes += 1
				EndIf
			EndIF
		EndIF

		// Ponto de entrada para validar se prossegue com a operação
		If ExistBlock("VXX16VLD")
			If !VXX016018_PEVXX16VLD(cTipo,"1",( cQAlias )->( R_E_C_N_O_ ))
				Return
			EndIf
		EndIf

		IF cTipo="2"
			//armazena a quantidade de renovacao para o chaint do veiculo do atendimento atual.
			If cAtend==(cQAlias)->(VRE_NUMATE)//reservado para o atendimento atual
				IF ( cQAlias )->( VRE_CHAINT ) == cChaint
					If ( cQAlias )->( VRE_USURES ) == __CUSERID
						nQtdRen	:= ( cQAlias )->( VRE_QTDREN )+1
						IF ( cQAlias )->( VRE_STATUS ) == "1"
							dDtRes	:= stod(( cQAlias )->( VRE_DATDES ))
							If dDtRes == dDataBase // data da reserva for igual a data de hoje
								cHorTmp	:= strzero(( cQAlias )->( VRE_HORDES ),4)
								If cHorTmp > SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)//se a hora for maior que a hora atual
									DbSelectArea("VAI")
									DbSetOrder(4)
									If DbSeek( xFilial("VAI") + __CUSERID )
										IF VAI->VAI_RESREN < nQtdRen
											MsgStop(STR0023,STR0004)//Excedeu limite de renovacao de reservas! ### /Andre
											( cQAlias )->( DbCloseArea() )
											Return
										Else
											//realiza o cancelamento da reserva
											FS_DESRESER(( cQAlias )->( R_E_C_N_O_ ),"1")
										EndIf
									EndIF
								EndIf
							ElseIf dDtRes > dDataBase // data da reserva for maior que a data de hoje
								DbSelectArea("VAI")
								DbSetOrder(4)
								If DbSeek( xFilial("VAI") + __CUSERID )
									IF VAI->VAI_RESREN < nQtdRen
										MsgStop(STR0023,STR0004)//Excedeu limite de renovacao de reservas! ### Andre
										( cQAlias )->( DbCloseArea() )
										Return
									Else
										//realiza o cancelamento da reserva
										FS_DESRESER(( cQAlias )->( R_E_C_N_O_ ),"1")
									EndIf
								EndIF
							EndIf
						EndIF
					Else
						nQtdRen := 0
					EndIf
				EndIF
			EndIF
		EndIf
		
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( DbCloseArea() )

	DbSelectArea("VAI")
	DbSetOrder(4)
	If DbSeek( xFilial("VAI") + __CUSERID )
		if cTipo="2"
			IF VAI->VAI_RESREN < nQtdRen
				MsgStop(STR0023,STR0004)//Excedeu limite de renovacao de reservas! ### Atencao ### Andre
				Return
			EndIF
		Else
			IF VAI->VAI_RESQTD < nQtdRes
				MsgStop(STR0024,STR0004)//Excedeu limite de reservas simultanea! ### Atencao ### Andre
				Return
			EndIF
		EndIF
	EndIF

	dbSelectArea("VV0")
	dbSetOrder(1)
	dbSeek(xFilial("VV0")+cAtend)

	nHorDesr := nHorRes

	IF nMinDesr > 0
		//calcula dias adicionais
		nHorDesr := val(SUBSTR(strzero(nHorRes,4),1,2)+"00")
		nTotMin := ((nHorDesr/100)*60)+Val(SUBSTR(strzero(nHorRes,4),3,2))
		nTDes :=((nMinDesr+nTotMin)/60)/24
		nDiasDes := int(nTDes)
		dDatDesr := dDataBase+nDiasDes
		IF dDatDesr <> dDataBase
			nMinDesr := (((nTDes-nDiasDes)*24)*60)
		EndIF
		//calcula hora
		nM := ( Val(SUBSTR(strzero(nHorRes,4),3,2)) + nMinDesr )
		nX := ( nM / 60 )
		nH := Int(nX)
		nM := ( ( nX - nH ) * 60 )
		If dDatDesr <> dDataBase
			nHorDesr:=0
		EndIF
		nHorDesr := ( nHorDesr + ( nH * 100 ) ) + nM
	EndIf

	//grava prioridade de venda do veiculo.
	DbSelectArea("VRE")
	RecLock("VRE",.T.)
	VRE->VRE_FILIAL := xFilial("VRE")
	VRE->VRE_CHAINT := cChaint
	VRE->VRE_STATUS := "1"//RESERVADO
	VRE->VRE_TIPO   := "1"//RESERVA TEMPORARIA
	VRE->VRE_FILATE := VV0->VV0_FILIAL
	VRE->VRE_NUMATE := cAtend
	VRE->VRE_USURES := __CUSERID
	VRE->VRE_DATRES := dDataBase
	VRE->VRE_HORRES := nHorRes
	VRE->VRE_USUDES := __CUSERID
	VRE->VRE_DATDES := dDatDesr
	VRE->VRE_HORDES := nHorDesr
	VRE->VRE_TIPDES := "0"//AUTOMATICA
	VRE->VRE_QTDREN := nQtdRen
	MsUnlock()

	// Ponto de entrada apos a Reserva/Desreserva TEMPORARIA do Veiculo
	If ExistBlock("VXX16RES")
		ExecBlock("VXX16RES", .f., .f., {cTipo,"1"}) // cTipo ( 1 - Reserva / 2 - Renovar Reserva ) / 1-Usuario acionou o Botao
	EndIf

	FS_LEVANTA(.t.)
Else
	If cTipo == "1"
		MsgAlert("Reserva ativa!"; // Reserva ativa!
			+ CHR(13);
			+ "Selecione a opção Desreserva ou Renovar Reserva.", STR0004) // Selecione a opção Desreserva ou Renovar Reserva. / Atenção
	Else
		MsgAlert("Nenhuma Reserva ativa!"; // Nenhuma Reserva ativa!
			+ CHR(13);
			+ "Selecione a opção Reserva.", STR0004) // Selecione a opção Reserva. / Atenção
	EndIf
EndIf
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | VX016VALID | Autor | Andre Luis Almeida    | Data | 20/07/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Valida se o Veiculo pode ser selecionado/faturado, verifica  |##
##|          | se existe prioridade de venda -> reserva temporaria          |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX016VALID(cNumAte,cChaInt,lDesAutom)
Local lRet    	 := .t.
Local dDtRes  	 := dDataBase
Local cHorTmp 	 := ""
Local cMsg    	 := ""
Local cQuery  	 := ""
Local cQAlias 	 := "SQLVRE"
Local cQAliasVVA := "SQLVVA"
Default lDesAutom := .t.

cNumAte := PadR(cNumAte, GetSX3Cache("VRE_NUMATE","X3_TAMANHO"))

If !Empty(cNumAte) .and. lDesAutom
	cQuery := "SELECT VRE.R_E_C_N_O_ AS RECVRE, VRE.VRE_CHAINT AS CHAINT FROM "+RetSqlName("VRE")+" VRE WHERE VRE.VRE_FILIAL='"+xFilial("VRE")+"' AND "
	cQuery += "VRE.VRE_STATUS='1' AND VRE.VRE_NUMATE='"+cNumAte+"' AND VRE.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() )

		//Verifica está deletado no VVA para realizar a desreserva
		cQuery := "SELECT VVA.R_E_C_N_O_ FROM "+RetSqlName("VVA")+" VVA "
		cQuery += "WHERE VVA.VVA_NUMTRA = '"+cNumAte+"'	AND VVA.VVA_CHAINT = '"+( cQAlias )->CHAINT+"' AND VVA.D_E_L_E_T_=' '"		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAliasVVA, .F., .T. )

		If ( cQAliasVVA )->( Eof() )
			FS_DESRESER(( cQAlias )->( RECVRE ),"1") // Desreserva pelo Usuario ( Prioridade de Venda )
		EndIf
		( cQAlias )->( DbSkip() )
		( cQAliasVVA )->( DbCloseArea() )
	EndDo
	( cQAlias )->( DbCloseArea() )
EndIf

If !Empty(cChaInt)
	cQuery := "SELECT VRE.R_E_C_N_O_ AS RECVRE , VRE.VRE_NUMATE , VRE.VRE_USURES , VRE.VRE_DATDES , VRE.VRE_HORDES FROM "+RetSqlName("VRE")+" VRE WHERE "
	cQuery += "VRE.VRE_FILIAL='"+xFilial("VRE")+"' AND VRE.VRE_CHAINT='"+cChaInt+"' AND VRE.VRE_STATUS='1' AND VRE.VRE_NUMATE<>'"+cNumAte+"' AND VRE.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() )
		dDtRes	:= stod(( cQAlias )->( VRE_DATDES ))
		If dDtRes == dDataBase // data da reserva for igual a data de hoje
			cHorTmp	:= strzero(( cQAlias )->( VRE_HORDES ),4)
			If cHorTmp > SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)//se a hora da reserva for maior que a hora atual
				lRet := .f.
			EndIf
		ElseIf dDtRes > dDataBase // data da reserva for maior que a data de hoje
			lRet := .f.
		EndIf
		If !lRet
			VV1->(DbSetOrder(1))
			VV1->(DbSeek(xFilial("VV1")+cChaInt))
			FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)			
			cMsg := STR0025 +CHR(13)+CHR(10)+CHR(13)+CHR(10) //Veiculo com Prioridade de Venda! Impossivel continuar.
			cMsg += "  - "+ STR0026 +": "+Alltrim(VV1->VV1_CHASSI)+" - "+VV1->VV1_CODMAR+" "+Alltrim(VV1->VV1_MODVEI)+" - "+Alltrim(VV2->VV2_DESMOD)+CHR(13)+CHR(10)//Veiculo
			cMsg += "  - "+ STR0027 +": "+( cQAlias )->( VRE_NUMATE )+CHR(13)+CHR(10)//Atendimento
			cMsg += "  - "+ STR0028 +": "+( cQAlias )->( VRE_USURES )+" - "+UsrRetName(( cQAlias )->( VRE_USURES ))+CHR(13)+CHR(10)//Usuario
			cMsg += "  - "+ STR0029 +": "+Transform(stod(( cQAlias )->( VRE_DATDES )),"@D")+" "+Transform(( cQAlias )->( VRE_HORDES ),"@R 99:99")+STR0030 //Validade / hs
			FMX_HELP("VX016VALID",cMsg)
			// Ponto de Entrada para inclusão do atendimento (veículo) na Lista de Espera
			If ExistBlock("VXX16ESP")
				ExecBlock("VXX16ESP", .f., .f., {cNumAte, cChaInt})
			EndIf
			Exit
		Else
			FS_DESRESER(( cQAlias )->( RECVRE ),"0") // Desreserva Automatica ( Prioridade de Venda )
		EndIf
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( DbCloseArea() )
EndIf
Return(lRet)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | FS_DESRESER| Autor | Rafael Goncalves      | Data | 21/07/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Desreserva ( Prioridade de Venda )                           |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_DESRESER(nRecVRE, cTipDes, lEfetuar)
Default lEfetuar := .t.

If lEfetuar

	// Ponto de entrada para validar se prossegue com a operação
	If ExistBlock("VXX16VLD")
		If !VXX016018_PEVXX16VLD(cTipDes,"1",nRecVRE)
			Return
		EndIf
	EndIf

	DbSelectArea("VRE")
	DbGoTo(nRecVRE)
	RecLock("VRE",.f.)
	VRE->VRE_STATUS := "0" // Desreserva
	VRE->VRE_TIPDES := cTipDes
	If cTipDes == "1" // Pelo Usuario
		VRE->VRE_USUDES := __cUserID
		VRE->VRE_DATDES := dDataBase
		VRE->VRE_HORDES := Val(Substr(Time(),1,2)+Substr(Time(),4,2))
	EndIf
	MsUnLock()
	// Ponto de entrada apos a Reserva/Desreserva TEMPORARIA do Veiculo
	If ExistBlock("VXX16RES")
		ExecBlock("VXX16RES", .f., .f., {"0",cTipDes}) // 0 - Desreserva / cTipDes ( 0-Automatico/1-Usuario )
	EndIf
Else
	MsgAlert("Nenhuma Reserva ativa!"; // Nenhuma Reserva ativa!
		+ CHR(13);
		+ "Selecione a opção Reserva.", STR0004) // Selecione a opção Reserva. / Atenção
EndIf
Return()

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | FS_LEVANTA | Autor | Rafael Goncalves      | Data | 21/07/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Carrega Reservas Temporarias                                 |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_LEVANTA(lChama)
Local cQuery    := "SQL"
Local cSQLAlias := "SQLALIAS"
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt:= cFilAnt
Local nCont     := 0
Local _ni       := 0
Local aFiliais  := {}
Default lChama  := .f.
aResTem := {}

For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aAdd(aFiliais,{ xFilial("VV9") , FWFilialName() })
Next
cFilAnt := cBkpFilAnt

cQuery := "SELECT VRE.VRE_STATUS , VRE.VRE_NUMATE , VRE.VRE_USUDES , VRE.VRE_DATDES , VRE.VRE_HORDES , VRE.VRE_TIPDES , VRE.VRE_FILATE , VRE.VRE_TIPO , VRE.VRE_USURES , VRE.VRE_DATRES , VRE.VRE_HORRES , VRE.VRE_QTDREN , VRE.R_E_C_N_O_ FROM "+RetSqlName("VRE")+" VRE "
cQuery += "WHERE VRE.VRE_CHAINT='"+cChaint+"' AND VRE.VRE_FILIAL='"+xFilial("VRE")+"' AND VRE.D_E_L_E_T_=' ' ORDER BY VRE.R_E_C_N_O_"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F., .T. )
While !( ( cSQLAlias )-> (eof() ) )
	//Verifica ultimo status do veiculo para exibir botoes corretos
	If (cSQLAlias)->(VRE_STATUS)=="1"
		If cAtend==(cSQLAlias)->(VRE_NUMATE)//reservado para o atendimento atual
			dDtRes	:= stod(( cSQLAlias )->( VRE_DATDES ))
			If dDtRes == dDataBase // data da reserva for igual a data de hoje
				cHorTmp	:= strzero(( cSQLAlias )->( VRE_HORDES ),4)
				If cHorTmp > SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)//se a hora for maior que a hora atual
					//habilita botao desreservar e o botao renovar reserva
					cVisual := "DS"
				Else
					FS_DESRESER(( cSQLAlias )->( R_E_C_N_O_ ),"0")
				EndIf
			ElseIf dDtRes > dDataBase // data da reserva for maior que a data de hoje
				//habilita botao desreservar e o botao renovar reserva
				cVisual := "DS"
			ElseIf dDtRes < dDataBase // data da reserva for menor que a data de hoje
				FS_DESRESER(( cSQLAlias )->( R_E_C_N_O_ ),"0")
			EndIf
		Else //reservado em outro atendimento permite somente visualizar
			cVisual := ""
		EndIF
	ElseIf( cSQLAlias)->(VRE_STATUS)<>"1" //habilita botao reservar
		cVisual := "R"
	EndIF
	cAteAtu:=(cSQLAlias)->(VRE_NUMATE) //grava ultimo atendimento para exibir na tela.
	cStaAtu:=(cSQLAlias)->(VRE_STATUS) //grava o ultimo status para exibir na tela.
	_ni := aScan(aFiliais,{|x| x[1] == (cSQLAlias)->(VRE_FILATE) })
	aAdd(aResTem, { IIf(_ni>0,(cSQLAlias)->(VRE_FILATE)+" - "+aFiliais[_ni,2],(cSQLAlias)->(VRE_FILATE)) , (cSQLAlias)->(VRE_STATUS) , (cSQLAlias)->(VRE_TIPO) ,(cSQLAlias)->(VRE_USURES)+" - "+UsrRetName((cSQLAlias)->(VRE_USURES)),(cSQLAlias)->(VRE_DATRES),(cSQLAlias)->(VRE_HORRES),(cSQLAlias)->(VRE_USUDES)+" - "+UsrRetName((cSQLAlias)->(VRE_USUDES)),(cSQLAlias)->(VRE_DATDES),(cSQLAlias)->(VRE_HORDES),(cSQLAlias)->(VRE_TIPDES),(cSQLAlias)->(VRE_QTDREN),(cSQLAlias)->(R_E_C_N_O_ ) })
	(cSQLAlias)->( DBSkip() )
enddo
( cSQLAlias )->( dbCloseArea() )

If Len(aResTem)<=0
	//12 - RECNO
	aAdd(aResTem, {"","","","","","","","","","",0,"" })
EndIF

If lChama
	oBrowseR:SetArray(aResTem)
	oBrowseR:Refresh()

	lReserva := "R" $ cVisual .And. Alltrim(Str(nOpc)) $ "3/4"
	lDesres  := "D" $ cVisual .And. Alltrim(Str(nOpc)) $ "3/4"
	lRenRes  := "S" $ cVisual .And. Alltrim(Str(nOpc)) $ "3/4"
EndIf

Return

/*/{Protheus.doc} OR0100026_ColunasBrowseReservadas
Retorna as colunas do Browse de Reservas
@author Fernando Vitor Cavani
@since 26/11/2019
@version 1.0
@return aColumns, array, colunas VRE das Reservas efetudas
@type function
/*/
Static Function OR0100026_ColunasBrowseReservadas()
Local aColumns := {}

AAdd(aColumns, FWBrwColumn():New())
aColumns[1]:SetData(&("{|| aResTem[oBrowseR:At(),1] }"))
aColumns[1]:SetTitle(STR0012) // Filial
aColumns[1]:SetSize(10) // 20 %

AAdd(aColumns, FWBrwColumn():New())
aColumns[2]:SetData(&("{|| Iif(!Empty(aResTem[oBrowseR:At(),2]), X3CBOXDESC('VRE_STATUS', aResTem[oBrowseR:At(),2]), '') }"))
aColumns[2]:SetTitle(STR0013) // Status
aColumns[2]:SetSize(10) // 20 %

AAdd(aColumns, FWBrwColumn():New())
aColumns[3]:SetData(&("{|| Iif(!Empty(aResTem[oBrowseR:At(),3]), X3CBOXDESC('VRE_TIPO', aResTem[oBrowseR:At(),3]), '') }"))
aColumns[3]:SetTitle(STR0014) // Tipo
aColumns[3]:SetSize(20) // 20 %

AAdd(aColumns, FWBrwColumn():New())
aColumns[4]:SetData(&("{|| aResTem[oBrowseR:At(),4] }"))
aColumns[4]:SetTitle(STR0015) // Usuario Reserva
aColumns[4]:SetSize(30) // 20 %

AAdd(aColumns, FWBrwColumn():New())
aColumns[5]:SetData(&("{|| SToD(aResTem[oBrowseR:At(),5]) }"))
aColumns[5]:SetTitle(STR0016) // Data Reserva
aColumns[5]:SetSize(10) // 20 %

AAdd(aColumns, FWBrwColumn():New())
aColumns[6]:SetData(&("{|| Transform(aResTem[oBrowseR:At(),6], '@R 99:99') }"))
aColumns[6]:SetTitle(STR0017) // Hora Reserva
aColumns[6]:SetSize(5) // 20 %

AAdd(aColumns, FWBrwColumn():New())
aColumns[7]:SetData(&("{|| aResTem[oBrowseR:At(),7] }"))
aColumns[7]:SetTitle(STR0018) // Usuario Desreserva
aColumns[7]:SetSize(30) // 20 %

AAdd(aColumns, FWBrwColumn():New())
aColumns[8]:SetData(&("{|| SToD(aResTem[oBrowseR:At(),8]) }"))
aColumns[8]:SetTitle(STR0019) // Data Desreserva
aColumns[8]:SetSize(10) // 20 %

AAdd(aColumns, FWBrwColumn():New())
aColumns[9]:SetData(&("{|| Transform(aResTem[oBrowseR:At(),9], '@R 99:99') }"))
aColumns[9]:SetTitle(STR0020) // Hora Desreserva
aColumns[9]:SetSize(5) // 20 %

AAdd(aColumns, FWBrwColumn():New())
aColumns[10]:SetData(&("{|| Iif(!Empty(aResTem[oBrowseR:At(),10]), X3CBOXDESC('VRE_TIPDES', aResTem[oBrowseR:At(),10]), '') }"))
aColumns[10]:SetTitle(STR0021) // Tipo Desreserva
aColumns[10]:SetSize(20) // 20 %

AAdd(aColumns, FWBrwColumn():New())
aColumns[11]:SetData(&("{|| aResTem[oBrowseR:At(),11] }"))
aColumns[11]:SetTitle(STR0022) // Qtde Renovacao
aColumns[11]:SetSize(5) // 20 %
Return aColumns

/*/{Protheus.doc} VXX016018_PEVXX16VLD
	Função para chamada do PE VXX16VLD
	@author Matheus Teixeira
	@since 05/08/2021
/*/
Static Function VXX016018_PEVXX16VLD(cTipo,nOpc,nRecno)
	Local lRet := .T.
	
	lRet := ExecBlock("VXX16VLD", .f., .f., {cTipo,nOpc,nRecno})

Return lRet