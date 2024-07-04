// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 17     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEIXX004.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXX004 º Autor ³ Rafael Goncalves   º Data ³  03/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Reservas de veiculo no atendimento novo                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc - (2-Visualizar/4-Alterar/3-Incluir)                  º±±
±±º          ³ cParAte  - Nro do Atendimento                              º±±
±±º			 ³ cParCha  - Chaint                                          º±±
±±º			 ³ cChamada - Momento chamada da funcao / 0 = cancela reserva º±±
±±º			 ³ cIteTra  - Item do Atendimento                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX004(nOpc,cParAte,cParCha,cChamada,cIteTra)
Local lPosVVA    := .f.
Local aStaRes 	 := {("0="+STR0003),("1="+STR0004)} // Nao / Sim
Local cAtend	 := cParAte//numero do atendimento
Local cCanRes    := IIf(cChamada=="0","0","1")
Local nRegVV0    := VV0->(Recno())
Local nRegVV1    := VV1->(Recno())
Local lAltRes	 := .t.
Local cCodMca 	 := ""
Local cGrMod  	 := ""
Local cModVec 	 := ""
Local cAnoMod 	 := ""
Local nOpcao 	 := 2
Local cEstVei 	 := ""
Local _ni 	  	 := 0
Local cQuery     := ""
Local cQAlias    := "SQLVVAVV0"
Local cBloqStat  := GetNewPar("MV_BLQSTAV","LO") // Nao mostrar veiculos que estao em Atendimentos com os STATUS informados neste Parametro
Local nCont      := 0
Local cMsg       := ""
Local cFilVVA    := ""
Local cFilVV0    := xFilial("VV0")
Local lVVA_HORVAL := ( VVA->(FieldPos("VVA_HORVAL")) <> 0 )
Private cStaRes  := "0"
Private dDtRes   := ctod("")
Private cHorRes  := space(5)
Private nLimDia  := 0   // dias da regra de reserva.
Default nOpc     := "2" // visualizar
Default cChamada := "1" // gravacao
Default cIteTra  := ""

If cChamada == "5"
	If Empty(cParAte)
		MsgStop(STR0005,STR0002) // Atendimento nao selecionado! / Atencao
		Return(.t.)
	EndIf
	If Empty(cParCha)
		MsgStop(STR0006,STR0002) // Veiculo nao selecionado! / Atencao
		Return(.t.)
	EndIf
EndIf

//verificar se existe chaint se nao pegar pelo atendimento.
If Empty(cParCha)
	dbSelectArea("VV0")
	dbSetOrder(1)
	If dbSeek(xFilial("VV0")+cParAte)
		DbSelectArea("VVA")
		DbSetOrder(1)
		If dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
			dbSelectArea("VV1")
			dbSetOrder(1)
			If dbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
				cParCha := VV1->VV1_CHAINT
			Else
				MsgStop(STR0007,STR0002) // Veiculo nao encontrado! / Atencao
				Return(.t.)
			EndIf
		EndIf
	EndIf
Else
	dbSelectArea("VV1")
	dbSetOrder(1)
	If !dbSeek(xFilial("VV1")+cParCha)
		If cChamada == "5"
			MsgStop(STR0007,STR0002) // Veiculo nao encontrado! / Atencao
		EndIf
		Return(.t.)
	EndIf
EndIf
//
If !VX016VALID( cParAte , cParCha , .f. ) // Prioridade de Venda - RESERVA TEMPORARIA
	Return .t.
EndIf
//
If !VXX120011_ValidaReservado(cParAte,cParCha,@cMsg) // Verifica se esta reservado em outro Atendimento
	Aviso(STR0002,cMsg,{"OK"},3) // Atencao / OK
	Return .t.
EndIf
//
cFilVVA := "("
//
cQuery := "SELECT DISTINCT VVA_FILIAL FROM "+RetSqlName("VVA")+" WHERE D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
Do While !( cQAlias )->( Eof() )
	cFilVVA += "'"+( cQAlias )->( VVA_FILIAL )+"',"
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
//
cFilVVA := left(cFilVVA,len(cFilVVA)-1)+")"
//
//ler VV0 para verificar se veiculo reservado em outro atendimento.
cQuery := "SELECT VV0.VV0_FILIAL , VV0.VV0_NUMTRA , VV9.VV9_STATUS , VV0.R_E_C_N_O_ AS RECVV0 "
If lVVA_HORVAL
	cQuery += ", VVA.VVA_RESERV AS RESERV , VVA.VVA_DATVAL AS DATVAL , VVA.VVA_HORVAL AS HORVAL "
Else
	cQuery += ", VV0.VV0_RESERV AS RESERV , VV0.VV0_DATVAL AS DATVAL , VV0.VV0_HORVAL AS HORVAL "
EndIf
cQuery += " , VVA.R_E_C_N_O_ AS RECVVA "
cQuery += "FROM "+RetSqlName("VVA")+" VVA "
cQuery += " JOIN "+ RetSqlName("VV0")+" VV0 ON (VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VV0.D_E_L_E_T_=' ') "
cQuery += " JOIN "+ RetSqlName("VV9")+" VV9 ON (VV9.VV9_FILIAL=VVA.VVA_FILIAL AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND VV9.D_E_L_E_T_=' ') "
cQuery += "WHERE VVA.VVA_FILIAL IN "+cFilVVA+" AND VVA.VVA_CHAINT='"+VV1->VV1_CHAINT+"' AND "
If lVVA_HORVAL
	cQuery += "VVA.VVA_RESERV IN ('1','3') AND "
Else
	cQuery += "VV0.VV0_RESERV IN ('1','3') AND "
EndIf
cQuery += "VVA.D_E_L_E_T_=' '"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
Do While !( cQAlias )->( Eof() )
	cAtend	:= ( cQAlias )->( VV0_NUMTRA )
	cStaRes	:= "1"
	dDtRes	:= stod(( cQAlias )->( DATVAL ))
	cHorRes	:= ( cQAlias )->( HORVAL )
	
	If ( ( cQAlias )->( VV0_FILIAL )+( cQAlias )->( VV0_NUMTRA ) ) <> ( cFilVV0+cParAte )  //verifica se a reserva do veiculo é para outro atendimento.
		lAltRes := .f.
	EndIf
	
	If !( cQAlias )->( VV9_STATUS ) $ cBloqStat //status diferente de Liberado realiza o cancelamento da reserva.
		//verificar se a reserva nao esta vencida se tiver cancela a reserva
		If dDtRes <= dDataBase // data da reserva for menor ou igual a data de hoje
			If cHorRes < SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)//se a hora for menor que a hora atual
				//cancelar reserva do veiculo
				If ( cQAlias )->( RESERV ) $ "1/3"
					dbSelectArea("VVA")
					VVA->(DbGoTo(( cQAlias )->( RECVVA )))
					VVA->(RecLock("VVA",.f.))
					VVA->VVA_RESERV := ""
					VVA->VVA_DATVAL := ctod("")
					If lVVA_HORVAL
						VVA->VVA_HORVAL := space(5)
					EndIf
					VVA->(MsUnlock())
					dbSelectArea("VV0")
					VV0->(DbGoTo(( cQAlias )->( RECVV0 )))
					VV0->(RecLock("VV0",.f.))
					VV0->VV0_RESERV := ""
					VV0->VV0_DATVAL := ctod("")
					VV0->VV0_HORVAL := space(4)
					VV0->(MsUnlock())
				EndIf
				If VV1->VV1_RESERV $ "1/3"
					dbSelectArea("VV1")
					VV1->(RecLock("VV1",.f.))
					VV1->VV1_RESERV := ""
					VV1->VV1_DTHRES := ""
					VV1->VV1_DTHVAL := ""
					VV1->(MsUnlock())
				EndIf
				lAltRes := .t.
			EndIf
		EndIf
	EndIf
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )

If cChamada == "5" //mostra tela
	
	If nOpc <> 3 .and. nOpc <> 4  // diferente de INCLUIR ou ALTERAR
		lAltRes := .f. // Nao deixar alterar
	EndIf
	
	If FGX_USERVL(xFilial("VAI"),__cUserID,"VAI_RESVEI","<>","1") // Verificar se usuario pode realizar a reserva do veiculo.
		MsgStop(STR0008,STR0002) // Usuario sem permissao para realizar a reserva do veiculo. / Atencao
		Return(.t.)
	EndIf

	VV2->(DbSetOrder(1))
	VV2->(DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	
	DEFINE MSDIALOG oTelaRes TITLE STR0001 FROM 003,000 TO 20,50 OF oMainWnd // Reserva de Veiculo
	
	@ 021,025 SAY STR0009 SIZE 40,08 OF oTelaRes PIXEL COLOR CLR_BLUE // Atendimento
	@ 020,070 MSGET oAtend VAR cAtend PICTURE "@!" SIZE 43,08 OF oTelaRes PIXEL COLOR CLR_BLUE WHEN .f.

	@ 036,025 SAY STR0019 SIZE 40,08 OF oTelaRes PIXEL COLOR CLR_BLUE // Veiculo
	@ 035,070 MSGET oAtend VAR (Alltrim(VV1->VV1_CODMAR)+" - "+Alltrim(VV2->VV2_DESMOD))  PICTURE "@!" SIZE 110,08 OF oTelaRes PIXEL COLOR CLR_BLUE WHEN .f.
	@ 045,070 MSGET oAtend VAR VV1->VV1_CHASSI PICTURE "@!" SIZE 110,08 OF oTelaRes PIXEL COLOR CLR_BLUE WHEN .f.
	
	@ 061,025 SAY STR0010 SIZE 40,08 OF oTelaRes PIXEL COLOR CLR_BLUE // Reservado
	@ 060,070 MSCOMBOBOX oStaRes VAR cStaRes VALID IIf(cStaRes=="1",(FS_VALRES(cParAte,cParCha),cCanRes:="1"),cCanRes:="0") ITEMS aStaRes SIZE 45,09 OF oTelaRes PIXEL COLOR CLR_BLUE WHEN lAltRes
	
	//botão necessario para realizar o when dos campos data e hora - corretamente
	@ 241,010 BUTTON oOpcoes  PROMPT "" OF oTelaRes SIZE 1,1 PIXEL ACTION oDtRes:setFocus()
	
	@ 076,025 SAY STR0011 SIZE 40,08 OF oTelaRes PIXEL COLOR CLR_BLUE // Data Validade
	@ 075,070 MSGET oDtRes VAR dDtRes PICTURE "@D" VALID(VX004VlRe(1,cParAte,cParCha)) SIZE 45,08 OF oTelaRes PIXEL COLOR CLR_BLUE WHEN (lAltRes .and. cStaRes=="1")
	
	@ 091,025 SAY STR0012 SIZE 40,08 OF oTelaRes PIXEL COLOR CLR_BLUE // Hora Validade
	@ 090,070 MSGET oHorRes VAR cHorRes PICTURE "@R 99:99" VALID(VX004VlRe(2,cParAte,cParCha)) SIZE 45,08 OF oTelaRes PIXEL COLOR CLR_BLUE WHEN (lAltRes .and. cStaRes=="1")
	
	ACTIVATE MSDIALOG oTelaRes CENTER ON INIT (EnchoiceBar(oTelaRes,{|| nOpcao:=1 , oTelaRes:End()},{ || nOpcao:=2 , oTelaRes:End()},,))
Else
	If cCanRes == "1" // grava reserva
		If FS_VALTAR(cParAte,cChamada,cParCha,0,.f.)
			nOpcao := 1
		Else
			nOpcao := 0
		EndIf
	Else // cancela reserva
		If lAltRes // valida se veiculo reservado para atendimento que esta cancelando.
			nOpcao := 1
		EndIf
	EndIf
EndIf

If nOpcao == 1 .and. lAltRes // grava reserva do veiculo
	
	lPosVVA := .f. // Posicionamento no VVA
	
	If !Empty(cIteTra) .and. VVA->(FieldPos("VVA_ITETRA")) > 0

		dbSelectArea("VVA")
		dbSetOrder(4)
		If dbSeek(xFilial("VVA")+cParAte+cIteTra)
			lPosVVA := .t.
		EndIf
		
	Else
	
		dbSelectArea("VVA")
		dbSetOrder(1)
		If dbSeek(xFilial("VVA")+cParAte+VV1->VV1_CHASSI)
			lPosVVA := .t.
		EndIf
	
	EndIf
	
	If lPosVVA // Posicionamento no VVA

		If Empty(dDtRes)
			dDtRes := dDataBase+nLimDia
		EndIf
		If Empty(cHorRes)
			cHorRes := SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)
		EndIf
		If cCanRes == "1" // reserva
			//
			VVA->(RecLock("VVA",.f.))
			VVA->VVA_RESERV := "1"
			VVA->VVA_DATVAL := dDtRes
			If lVVA_HORVAL
				VVA->VVA_HORVAL := cHorRes
			EndIf
			VVA->(MsUnlock())
			//
			VEIVM130TAR(cParAte,"7","1",cFilVV0) // Tarefas: 7-Reserva / 1-Atendimento
			//
			VV1->(RecLock("VV1",.f.))
			VV1->VV1_RESERV := "1"
			VV1->VV1_DTHRES := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo
			VV1->VV1_DTHVAL := left(Dtoc(dDtRes),6) + right(Dtoc(dDtRes),2) + "/" + cHorRes // Dia/Mes/Ano(2 posicoes)/Hora:Minuto
			VV1->(MsUnlock())
			//
			dbSelectArea("VV0")
			dbSetOrder(1)
			If dbSeek(xFilial("VV0")+cParAte)
				If !lVVA_HORVAL
					VV0->(RecLock("VV0",.f.))
					VV0->VV0_RESERV := "1"
					VV0->VV0_DATVAL := dDtRes
					VV0->VV0_HORVAL := cHorRes
					VV0->(MsUnlock())
				EndIf
			EndIf
		
		Else // cancela reserva
			//
			VVA->(RecLock("VVA",.f.))
			VVA->VVA_RESERV := ""
			VVA->VVA_DATVAL := ctod("")
			If lVVA_HORVAL
				VVA->VVA_HORVAL := space(5)
			EndIf
			VVA->(MsUnlock())
			//
			VEIVM130TAR(cParAte,"8","1",cFilVV0) // Tarefas: 8-Cancela Reserva / 1-Atendimento
			//
			VV1->(RecLock("VV1",.f.))
			VV1->VV1_RESERV := ""
			VV1->VV1_DTHRES := ""
			VV1->VV1_DTHVAL := ""
			VV1->(MsUnlock())

			dbSelectArea("VV0")
			dbSetOrder(1)
			If dbSeek(xFilial("VV0")+cParAte)
				VV0->(RecLock("VV0",.f.))
				VV0->VV0_RESERV := ""
				VV0->VV0_DATVAL := ctod("")
				VV0->VV0_HORVAL := ""
				VV0->(MsUnlock())
			EndIf
			//
		EndIf
		//
		M->VV0_RESERV := VV0->VV0_RESERV
		M->VV0_DATVAL := VV0->VV0_DATVAL
		M->VV0_HORVAL := VV0->VV0_HORVAL
		//
		M->VVA_RESERV := VVA->VVA_RESERV
		M->VVA_DATVAL := VVA->VVA_DATVAL
		If lVVA_HORVAL
			M->VVA_HORVAL := VVA->VVA_HORVAL
		EndIf
		If FindFunction("VX002ACOLS") .and. FM_PILHA("VEIXX002")
			VX002ACOLS("VVA_RESERV")
			VX002ACOLS("VVA_DATVAL")
			VX002ACOLS("VVA_HORVAL")
		EndIf

		//Ponto de Entrada apos a RESERVA e DESRESERVA do Veiculo
		If ExistBlock("VX04DRES")
			ExecBlock("VX04DRES",.f.,.f.,{ VVA->VVA_CHASSI , VVA->VVA_CHAINT , xFilial("VV0") , cParAte , cCanRes })
		EndIf

	EndIf
EndIf

DbSelectArea("VV0") // posiciona novamente no registro salvo
VV0->(DbGoTo(nRegVV0))
DbSelectArea("VV1")	// posiciona novamente no registro salvo
VV1->(DbGoTo(nRegVV1))

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VX004VlRe    ³ Autor ³ Rafael Goncalves  ³ Data ³ 04/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a data da reserva do veiculo para o atendimento     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VX004VlRe(nCamp,cParAte,cParCha)
Local lRet  := .t.
default nCamp := 1
If FS_VALTAR(cParAte,"5",cParCha,nCamp)
	If val(substr(cHorRes,1,2)) > 23
		lRet := .f.
	ElseIf val(substr(cHorRes,1,2)) < 00
		lRet := .f.
	ElseIf val(substr(cHorRes,3,2)) > 59
		lRet := .f.
	ElseIf val(substr(cHorRes,3,2)) < 00
		lRet := .f.
	EndIf
EndIf
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FS_VALTAR ºAutor  ³RAFAEL GONCALVES    º Data ³  04/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta se existe tarefa para o veiculo                   º±±
±±º          ³ realizando ou nao a reaserva do veiculo                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veículo                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ 1-Numero atendimento                                       º±±
±±ºParametros³ 2-Momento da chamada                                       º±±
±±º          ³ 3-Chaint                                                   º±±
±±º          ³ 4-1=Data/2=Hora validar pelo usuario                       º±±
±±º          ³ 5-Data da validade da reserva                              º±±
±±º          ³ 6-Hora da Validade da Reserva                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_VALTAR(cAtend,cChamada,cChaint,nCamp,lVerTare)

Local cQuery     := ""
Local cQAlias    := "SQLVZM"
Local cTarefa    := ""
Local _ni        :=1
Local lRetTar    := .t.
Local lAchou     := .f.
Local cTexto     := ""
Local cCodMca 	 := ""
Local cGrMod  	 := ""
Local cModVec  	 := ""
Local cAnoMod  	 := ""
Local cEstVei 	 := ""
Default cChamada := ""
Default nCamp    := 0
Default cAtend   := ""
Default cChaint  := ""
Default lVerTare := .f.

dbSelectArea("VV1")
dbSetOrder(1)
dbSeek(xFilial("VV1")+cChaint)

dbSelectArea("VV2")
dbSetOrder(1)
dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI)

cCodMca := VV1->VV1_CODMAR
cGrMod  := VV2->VV2_GRUMOD
cModVec := VV1->VV1_MODVEI
cAnoMod := VV1->VV1_FABMOD
cEstVei := VV1->VV1_ESTVEI

If cChamada $ "1/2/3/4/5" .and. cAtend <> ""
	
	cQuery := "SELECT VZM.VZM_REQTAR , VZM.VZM_LIMDIA FROM "+RetSqlName("VZM")+" VZM  WHERE "
	cQuery += "VZM.VZM_FILIAL='"+xFilial("VZM")+"' AND VZM.VZM_CHAMAD='"+cChamada+"' AND "
	cQuery += "(VZM.VZM_CODMAR='"+SPACE(LEN(VV1->VV1_CODMAR))+"' OR VZM.VZM_CODMAR='"+cCodMca+"') AND "
	cQuery += "(VZM.VZM_GRUMOD='"+SPACE(LEN(VV2->VV2_GRUMOD))+"' OR VZM.VZM_GRUMOD='"+cGrMod +"') AND "
	cQuery += "(VZM.VZM_MODVEI='"+SPACE(LEN(VV1->VV1_MODVEI))+"' OR VZM.VZM_MODVEI='"+cModVec+"') AND "
	cQuery += "(VZM.VZM_FABMOD='"+SPACE(LEN(VV1->VV1_FABMOD))+"' OR VZM.VZM_FABMOD='"+cAnoMod+"') AND "
	cQuery += "(VZM.VZM_ESTVEI='"+SPACE(LEN(VV1->VV1_ESTVEI))+"' OR VZM.VZM_ESTVEI='"+cEstVei+"') AND "
	cQuery += "VZM.D_E_L_E_T_=' ' ORDER BY VZM.VZM_CODMAR DESC , VZM.VZM_GRUMOD DESC , VZM.VZM_MODVEI DESC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	If !( cQAlias )->( Eof() )
		lAchou := .t.
		nLimDia := ( cQAlias )->( VZM_LIMDIA )
		If !Empty(( cQAlias )->( VZM_REQTAR ))
			For _ni:=1 to 5
				If !Empty(Substr(( cQAlias )->( VZM_REQTAR ),(_ni*7)-6,6))
					cTarefa := Substr(( cQAlias )->( VZM_REQTAR ),(_ni*7)-6,6)
					DbSelectArea("VAY")
					DbSetOrder(3)
					If DbSeek( xFilial("VAY") + cAtend + cTarefa)
						If !(VAY->VAY_STATUS $ "1/2")
							DbSelectArea("VAX")
							DbSetOrder(1)
							If DbSeek( xFilial("VAX") + VAY->VAY_CODTAR)
								cTexto := cTexto + CHR(13)+CHR(10)+" - " +ALLTRIM(VAX->VAX_DESTAR)
								lRetTar := .f.
							EndIf
						EndIf
					Else
						DbSelectArea("VAX")
						DbSetOrder(1)
						If DbSeek( xFilial("VAX") + cTarefa)
							cTexto := cTexto + CHR(13)+CHR(10)+" - " +ALLTRIM(VAX->VAX_DESTAR)
							lRetTar := .f.
						EndIf
					EndIf
				EndIf
			Next
		EndIf
	EndIf
	( cQAlias )->( dbCloseArea() )
	
	//verifica a chamada da tela para verificar se existe tarefa para realizar a reserva pelo usuario.
	If lVerTare
		If !lAchou
			MsgStop(STR0013,STR0002) // Nao existe nenhuma regra cadastrada. Impossivel realizar a reserva. ### Atencao
			Return(.f.)
		EndIf
	EndIf
	If !lAchou .and. !(cChamada $ "3/4/5") // Nao achou nenhuma regra cadastrada e nao esta Pre-Aprovando / Aprovando / Pelo Usuario
		Return(.f.)
	EndIf
	
	//se for chamado pela cada ou hora
	If !Empty(nCamp) .and. lRetTar// valida se a chamada e na validacao da data ou hora para ver se a informada nao e maior que a da regra se for maior informar o usuario.
		If nLimDia > 0
			If nCamp==1 //data de validade da reserva.
				If dDtRes <= (dDataBase+nLimDia)
					Return(.t.)
				Else
					MsgInfo(STR0014+CHR(13)+CHR(10)+STR0015,STR0002) // Data informada é superior a data limite informada na regra para reserva de veiculo. / A data da reserva sera alterada para o limite configurado. / Atencao
					dDtRes := dDataBase+nLimDia
					Return(.t.)
				EndIf
			ElseIf nCamp==2 // hora  da validade da reserva
				If Dtos(dDtRes)+cHorRes <= (Dtos(dDataBase+nLimDia)+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2))
					Return(.t.)
				Else
					MsgInfo(STR0016+CHR(13)+CHR(10)+STR0017,STR0002) // Hora informada é superior a hora limite informada na regra para reserva de veiculo. / A hora da reserva sera alterada para o limite configurado. / Atencao
					cHorRes := SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)
					Return(.t.)
				EndIf
			EndIf
		Else
			Return(.f.)
		EndIf
	EndIf
	
	If !lRetTar
		MsgStop(STR0018+cTexto,STR0002)// Impossivel realizar a reserva do veiculo pois existe(m) tarefa(s) pendente(s): / Atencao
		If cChamada =="5" // se for chamado pelo usuario ele retorna falso para nao permitir o usuario reservar
			oTelaRes:End()
		EndIf
		Return(.f.)
	EndIf
EndIf

If cChamada =="5" // se for chamado pelo usuario ele retorna true para permitir o usuario reservar
	Return(.t.)
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALRES    ³ Autor ³ Rafael Goncalves  ³ Data ³ 04/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se existe regra no ComboBox                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALRES(cParAte,cParCha)
If !FS_VALTAR(cParAte,"5",cParCha,,.t.)
	cStaRes := "0"
	oTelaRes:End()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VEIXX04RESº Autor ³ Rafael Goncalves   º Data ³  03/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Reservas de veiculo no atendimento novo                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cParAte - Nro do Atendimento                               º±±
±±º			 ³ cParCha - Chaint                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX04RES(cParAte,cParCha)
Local lVVA_HORVAL := ( VVA->(FieldPos("VVA_HORVAL")) <> 0 )
Local dDtRes  	  := dDataBase+60 // limite de 60 dias
Local cHorRes     := SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2) // hora atual
dbSelectArea("VV1")
dbSetOrder(1)
If dbSeek(xFilial("VV1")+cParCha) //CHAINT
	VV1->(RecLock("VV1",.f.))
	VV1->VV1_RESERV := "1"
	VV1->VV1_DTHRES := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo
	VV1->VV1_DTHVAL := left(Dtoc(dDtRes),6) + right(Dtoc(dDtRes),2) + "/" + cHorRes // Dia/Mes/Ano(2 posicoes)/Hora:Minuto
	VV1->(MsUnlock())
Else
	Return//se nao encontrar realiza return
EndIf
dbSelectArea("VVA")
dbSetOrder(1)
If dbSeek(xFilial("VVA")+cParAte+VV1->VV1_CHASSI) //ATENDIMENTO+CHASSI
	VVA->(RecLock("VVA",.f.))
	VVA->VVA_RESERV := "1"
	VVA->VVA_DATVAL := dDtRes
	If lVVA_HORVAL
		VVA->VVA_HORVAL := cHorRes
	EndIf
	VVA->(MsUnlock())
Else
	Return//se nao encontrar realiza return
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VXX04REVJ1º Autor ³ Rafael Goncalves   º Data ³  03/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Reservas de veiculo verificando o VJ1                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cChassi - Chassi do Veiculo                                º±±
±±º			 ³ cChaint - Chaint                                           º±±
±±º			 ³ cTipo   - 0-cancela / 1 reserva.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXX04REVJ1(cChassi,cChaint,cTipo)
Local lVVA_HORVAL := ( VVA->(FieldPos("VVA_HORVAL")) <> 0 )
Local cNumTra     := ""
Local cQuery      := ""
default cChassi   := ""
default cChaint   := ""
default cTipo     := "1"

If Empty(cChassi) .and. Empty(cChaint)
	Return
EndIf

If Empty(cChaint)
	DbSelectArea("VV1")
	DbSetOrder(2)
	DbSeek(xFilial("VV1")+cChassi)
	cChaint:= VV1->VV1_CHAINT
EndIf

If cTipo == "1" //reserva de veiculo
	//posicionar no VV1 para pegar o chaint
	If VJ1->(FieldPos("VJ1_NUMTRA")) > 0
		cQuery := "SELECT VJ1.VJ1_NUMTRA FROM "+RetSqlName("VJ1")+" VJ1 "
		cQuery += "JOIN "+ RetSqlName("VV9")+" VV9 ON (VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND VV9.VV9_NUMATE=VJ1.VJ1_NUMTRA AND VV9.VV9_STATUS='L' AND VV9.D_E_L_E_T_=' ') "
		cQuery += "WHERE VJ1.VJ1_FILIAL='"+xFilial("VJ1")+"' AND VJ1.VJ1_CHAINT='"+cChaint+"' AND VJ1.VJ1_NUMNFI='000000' AND VJ1.D_E_L_E_T_=' '"
		cNumTra := FM_SQL(cQuery)
	EndIf
	If !Empty(cNumTra)
		VEIXX04RES(cNumTra,cChaint)//realiza a reserva do veiculo para 60 dias.
	EndIf
ElseIf cTipo == "0" //cancelamento da reserva de veiculo
	//posicionar no VV1 para pegar o chaint
	If VJ1->(FieldPos("VJ1_NUMTRA")) > 0
		cQuery := "SELECT VJ1.VJ1_NUMTRA FROM "+RetSqlName("VJ1")+" VJ1 "
		cQuery += "JOIN "+ RetSqlName("VV9")+" VV9 ON (VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND VV9.VV9_NUMATE=VJ1.VJ1_NUMTRA AND VV9.VV9_STATUS<>'F' AND VV9.D_E_L_E_T_=' ') "
		cQuery += "WHERE VJ1.VJ1_FILIAL='"+xFilial("VJ1")+"' AND VJ1.VJ1_CHAINT='"+cChaint+"' AND VJ1.D_E_L_E_T_=' '"
		cNumTra := FM_SQL(cQuery)
	EndIf
	If !Empty(cNumTra)
		//Cancelamento da Reserva
		DbSelectArea("VV1")//cancela reserva do veiculo.
		DbSetOrder(2)
		If DbSeek(xFilial("VV1")+cChassi)
			If VV1->VV1_RESERV $ "1/3"
				VV1->(RecLock("VV1",.f.))
				VV1->VV1_RESERV := ""
				VV1->VV1_DTHRES := ""
				VV1->VV1_DTHVAL := ""
				VV1->(MsUnlock())
			EndIf
		EndIf
		DbSelectArea("VVA")
		DbSetOrder(1)
		If DbSeek(xFilial("VVA")+cNumTra+VV1->VV1_CHASSI)
			If VVA->VVA_RESERV $ "1/3"
				VVA->(RecLock("VVA",.f.))
				VVA->VVA_RESERV := ""
				VVA->VVA_DATVAL := ctod("")
				If lVVA_HORVAL
					VVA->VVA_HORVAL := space(5)
				EndIf
				VVA->(MsUnlock())
			EndIf
		EndIf
	EndIf
EndIf

Return