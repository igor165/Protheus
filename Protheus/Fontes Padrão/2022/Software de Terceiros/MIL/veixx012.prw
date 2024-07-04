// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 13     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼ 

#Include "PROTHEUS.CH"
#Include "VEIXX012.CH"

#DEFINE PULALINHA CHR(13) + CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXX012 º Autor ³ Andre Luis Almeida º Data ³  22/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacoes na Selecao e Digitacao do Veiculo               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nTp     ( 1=Digitacao / 2=Finalizacao )                    º±±
±±º          ³ cFilVei ( Filial de Pesquisa do Veiculo )                  º±±
±±º          ³ cChaInt ( Chassi Interno do Veiculo )                      º±±
±±º          ³ cCodTes ( Codigo do TES )                                  º±±
±±º          ³ cNumAte ( Numero do Atendimento )                          º±±
±±º          ³ lInf    ( Sempre Exibe Cabeçalho Informativo? )            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX012(nTp,cFilVei,cChaInt,cCodTes,cNumAte, pXX012Auto, lInf, oVeiculos)
Local lRet        := .t.
Local cMsg        := ""
Local cMsgAtend   := ""
Local cLocVei     := ""
Local cGruVei     := left(GetMv("MV_GRUVEI")+space(10),len(SB1->B1_GRUPO))
Local cQAlAux     := "SQLPREVIA"
Local cQuery      := ""
Local cFilVVA    := xFilial("VVA")
Local cFilOut    := VXX120031_LevantaOutrasFiliaisVVA( cFilVVA )

Default nTp       := 1
Default cFilVei   := xFilial("VV1")
Default cChaInt   := VV1->VV1_CHAINT
Default cCodTes   := ""
Default pXX012Auto := .f.
Default lInf	  := .f.
Default oVeiculos   := DMS_Veiculo():New()

Private lXX012Auto := pXX012Auto

cNumAte := PadR(cNumAte, GetSX3Cache("VVA_NUMTRA","X3_TAMANHO"))

dbSelectArea("VV1")
dbSetOrder(1) //Filial+ChaInt
dbSeek(cFilVei+cChaInt)

// Se for Finalizacao, verifica se existe VV1, 
// pois pode se tratar de Progresso ou venda futura 
If nTp == 1 // Selecao do Veiculo
	If ExistBlock("VX012VAL")
		lRet := ExecBlock("VX012VAL",.f.,.f.,{xFilial("VVA"),cNumAte,VV1->VV1_CHASSI})
		If !lRet 
			dbSelectArea("VV1")
			Return(.f.)		
		EndIf		
	EndIf
ElseIf nTp == 2 // Validacao na Finalizacao
	If !VV1->(Found())
		cMsg := STR0001 // Veiculo nao cadastrado na tabela VV1!
		cMsg += VXX120041_ChassiMarcaModeloVeiculo(.t.)
		lRet := .f.
	EndIf
EndIf

If lRet
	// Chassi Bloqueado
	If oVeiculos:Bloqueado(VV1->VV1_CHAINT)
		lRet := .f. // A mensagem já é exibida dentro da função Bloqueado()
	EndIf
EndIf

If lRet
	////////////////////////////////////////////////////////////////////////////
	// VALIDA RESERVA TEMPORARIA DO VEICULO                                   //
	////////////////////////////////////////////////////////////////////////////
	lRet := VX016VALID(cNumAte,cChaInt) // Prioridade de Venda -> Reserva Temporaria (Valida Veiculo)
EndIf

If lRet
	////////////////////////////////////////////////////////////////////////////
	// Valida se VEICULO ESTA RESERVADO (Desconsiderar o Atendimento enviado) //
	////////////////////////////////////////////////////////////////////////////
	lRet := VXX120011_ValidaReservado(cNumAte,cChaInt,@cMsg)
EndIf

If lRet
	Do Case
		Case VV1->VV1_SITVEI == "2" // Transito
			cMsg := STR0003 // Veiculo em Transito!
		Case VV1->VV1_SITVEI == "3" // Remessa
			cMsg := STR0004 // Veiculo em Remessa!
		Case VV1->VV1_SITVEI == "4" // Consignado
			cMsg := STR0005 // Veiculo Consignado!
		Case VV1->VV1_SITVEI == "8" // Pedido
			cMsg := STR0018 // Veiculo em Pedido!
	EndCase
	If !Empty(cMsg)
		cMsg += VXX120041_ChassiMarcaModeloVeiculo(.t.)
	EndIf
EndIf

If lRet
	////////////////////////////////////////////////////////////////////////////
	// VERIFICA SE O VEICULO ESTA BLOQUEADO                                   //
	////////////////////////////////////////////////////////////////////////////
	aRet := VM060VEIBLO(VV1->VV1_CHAINT,"B") // Verifica se o Veiculo esta Bloqueado, retorna registro do Bloqueio.
	If len(aRet) > 0
		cMsg := STR0006+" "+aRet[1,1]+PULALINHA+PULALINHA 	// Veiculo Bloqueado por
		cMsg += STR0007+PULALINHA+aRet[1,2]+PULALINHA+PULALINHA  // Motivo:
		cMsg += STR0008+" "+aRet[1,3] // Validade:
		cMsg += VXX120041_ChassiMarcaModeloVeiculo(.t.)
		lRet := .f.
	EndIf
EndIf

If lRet
	////////////////////////////////////////////////////////////////////////////
	// Valida Status de Outros Atendimentos para o mesmo Veiculo              //
	////////////////////////////////////////////////////////////////////////////
	lRet := VXX120021_ValidaStatusAtendimentos( cNumAte , VV1->VV1_CHASSI , VV1->VV1_CHAINT , @cMsg )
EndIf

If lRet .and. !Empty(cCodTes)
	cLocVei := VV1->VV1_LOCPAD
	if Empty(VV1->VV1_LOCPAD)
		cLocVei := GETMV("MV_LOCVEIN") //Novo
		if VV1->VV1_ESTVEI == '1'
			cLocVei := GETMV("MV_LOCVEIU") //Usado
		Endif
	Endif
	if ! FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
		cMsg := STR0010 // Veiculo nao encontrado na tabela de produtos (SB1).
		cMsg += VXX120041_ChassiMarcaModeloVeiculo(.t.)
		lRet := .f.
	endif
	SB1->(dbSetOrder(1))
	If Empty(cLocVei)
		cLocVei := SB1->B1_LOCPAD
	EndIf
	SB2->(dbSetOrder(1))
	If !SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+cLocVei)) .or. SaldoSB2() <= 0
		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4")+cCodTes))
		If SF4->F4_ESTOQUE == "S" // TES Movimenta Estoque
			If FGX_USERVL(xFilial("VAI"),__cUserID,"VAI_ESTNEG","<>","1") // nao Permite Faturar sem Estoque
				cMsg := STR0011 // Veiculo nao esta no estoque ou pertence a outra filial.
				cMsg += VXX120041_ChassiMarcaModeloVeiculo(.t.)
				lRet := .f.
			EndIf
		EndIf
	EndIf
EndIf

If !Empty(cMsg)
	cMsg += PULALINHA+PULALINHA
	cMsg += STR0022+PULALINHA // Veiculo:
	cMsg += Alltrim(IIf(!Empty(VV1->VV1_CHASSI),VV1->VV1_CHASSI,VV1->VV1_CHAINT))+" - "+Alltrim(VV1->VV1_CODMAR)+" "+Alltrim(VV1->VV1_MODVEI)
EndIf

If lRet
	////////////////////////////////////////////////////////////////////////////
	// VERIFICA ATENDIMENTOS EM ABERTO PARA O VEICULO                         //
	////////////////////////////////////////////////////////////////////////////
	
	cQuery := "SELECT VV9.VV9_FILIAL , VV9.VV9_NUMATE , VV9.VV9_STATUS , VV0.VV0_CODVEN"
	cQuery += "  FROM "+RetSQLName("VVA")+" VVA "
	cQuery += "  JOIN "+RetSQLName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VV0.D_E_L_E_T_ = ' ' ) "
	cQuery += "  JOIN "+RetSQLName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VVA.VVA_FILIAL AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND VV9.VV9_STATUS = 'A' AND VV9.D_E_L_E_T_ = ' ' ) " // Considerar somente atendimento em aberto 
	cQuery += " WHERE "
	cQuery += "  ( ( VVA.VVA_FILIAL='"+cFilVVA+"' AND VVA.VVA_NUMTRA<>'"+cNumAte+"' ) " + IIf( ! Empty(cFilOut) , " OR ( VVA.VVA_FILIAL IN ("+cFilOut+") ) " , "" ) + " ) "
	If !Empty(VV1->VV1_CHASSI)
		cQuery += "  AND VVA.VVA_CHASSI='"+VV1->VV1_CHASSI+"'" // Necessario devido a validação nas demais Filiais
	Else
		cQuery += "  AND VVA.VVA_CHAINT='"+VV1->VV1_CHAINT+"'"
		cQuery += "  AND VVA.VVA_CHASSI=' '" // Necessario devido a validação nas demais Filiais
	EndIf
	cQuery += "  AND VVA.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY VV9.VV9_FILIAL, VV9.VV9_NUMATE"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
	While !( cQAlAux )->(Eof())
		cMsgAtend += STR0019+" "+( cQAlAux )->( VV9_FILIAL )+PULALINHA // Filial:
		cMsgAtend += STR0020+" "+( cQAlAux )->( VV9_NUMATE ) // Atendimento:
		cMsgAtend += " ( "+IIf(VV1->VV1_SITVEI == "1",STR0012,STR0013)+" )"+PULALINHA // Em Aberto com Veiculo ja Vendido / Atendimento em Aberto
		cMsgAtend += STR0021+" "+( cQAlAux )->( VV0_CODVEN )+" - "+left(FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+( cQAlAux )->( VV0_CODVEN )+"' AND D_E_L_E_T_=' '"),25)+PULALINHA // Vendedor:
		cMsgAtend += Replicate("-",80)+PULALINHA
		( cQAlAux )->(dbSkip())
	EndDo
	( cQAlAux )->(dbCloseArea())
	If !Empty(cMsgAtend)
		If Empty(cMsg)
			cMsg += VXX120041_ChassiMarcaModeloVeiculo(.f.)
		EndIf
		cMsg += PULALINHA+PULALINHA
		cMsg += STR0014+PULALINHA // Chassi selecionado no(s) seguinte(s) atendimento(s):
		cMsg += Replicate("-",80)+PULALINHA
		cMsg += cMsgAtend
	EndIf

EndIf

If !Empty(cMsg)
	If lRet .or. lInf // Informativo!
		If nTp == 1 // Selecao do Veiculo
			Aviso(STR0015,cMsg,{STR0017},3) // Informativo! / OK
		EndIf
	Else // Validacao - Impossivel continuar!
		If lXX012Auto
			FMX_HELP("VX012ERR001", cMsg)
		Else
			Aviso(STR0016,cMsg,{STR0017},3) // Impossivel continuar! / OK
		EndIf
	EndIf
EndIf

If !lXX012Auto .and. !Empty(VV1->VV1_CHAINT)
	If FindFunction("VEIC130")
		VEIC130( { VV1->VV1_CHAINT } ) // Visualizar Bonus disponiveis para este Veiculo
	EndIf
EndIf

dbSelectArea("VV1")
Return(lRet)

/*/{Protheus.doc} VXX120011_ValidaReservado
	Valida Reserva de Veiculos
	
	@author Andre Luis Almeida
	@since 23/02/2020
/*/
Function VXX120011_ValidaReservado(cNumAte,cChaInt,cMsg)
Local lReserv    := .f.
Local dDatRes    := ctod("")
Local cHorTmp    := ""
Local cQuery     := ""
Local cQAlAux    := "SQLAUX"
Local lRet       := .t.
Local cFilVVA    := xFilial("VVA")
Local cFilOut    := VXX120031_LevantaOutrasFiliaisVVA( cFilVVA )
Local lVVA_HORVAL := ( VVA->(ColumnPos("VVA_HORVAL")) <> 0 )
Default cChaInt  := ""

cNumAte := PadR(cNumAte, GetSX3Cache("VVA_NUMTRA","X3_TAMANHO"))

If !Empty(cChaInt)
	dbSelectArea("VV1")
	dbSetOrder(1) //Filial+ChaInt
	dbSeek(xFilial("VV1")+cChaInt)
EndIf
If VV1->VV1_RESERV $ "1/3" // Reservado
	If !Empty(VV1->VV1_DTHVAL)
		lReserv := .t.
		dDatRes := ctod(subs(VV1->VV1_DTHVAL,1,8))
		if dDataBase > dDatRes
			lReserv := .f.
		Elseif dDataBase == dDatRes
			cHorTmp := subs(VV1->VV1_DTHVAL,10,2)+":"+subs(VV1->VV1_DTHVAL,12,2)
			if Substr(Time(),1,5) > cHorTmp
				lReserv := .f.
			Endif
		Endif
		If lReserv
			//
			cQuery := "SELECT VV0.VV0_FILIAL , VV0.VV0_NUMTRA , VV0.VV0_CODVEN , "
			If lVVA_HORVAL
				cQuery += "VVA.VVA_RESERV AS RESERV , VVA.VVA_DATVAL AS DATVAL , VVA.VVA_HORVAL AS HORVAL "
			Else
				cQuery += "VV0.VV0_RESERV AS RESERV , VV0.VV0_DATVAL AS DATVAL , VV0.VV0_HORVAL AS HORVAL "
			EndIf
			cQuery += "FROM "+RetSqlName("VVA")+" VVA "
			cQuery += "JOIN "+RetSqlName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VV0.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE "
			cQuery += "  ( ( VVA.VVA_FILIAL='"+cFilVVA+"' AND VVA.VVA_NUMTRA<>'"+cNumAte+"' ) " + IIf( ! Empty(cFilOut) , " OR ( VVA.VVA_FILIAL IN ("+cFilOut+") ) " , "" ) + " ) "
			If !Empty(VV1->VV1_CHASSI)
				cQuery += "  AND VVA.VVA_CHASSI='"+VV1->VV1_CHASSI+"'" // Necessario devido a validação nas demais Filiais
			Else
				cQuery += "  AND VVA.VVA_CHAINT='"+VV1->VV1_CHAINT+"'"
				cQuery += "  AND VVA.VVA_CHASSI=' '" // Necessario devido a validação nas demais Filiais
			EndIf
			cQuery += "  AND VVA.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
			Do While !( cQAlAux )->( Eof() )
				If ( cQAlAux )->( RESERV ) $ "1/3"
					dDtRes	:= stod(( cQAlAux )->( DATVAL ))
					cHorTmp	:= ( cQAlAux )->( HORVAL )
					If dDtRes == dDataBase // data da reserva for igual a data de hoje
						If cHorTmp < SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)//se a hora for menor que a hora atual
							lRet := .f.
						EndIf
					ElseIf dDtRes > dDataBase // data da reserva for maior que a data de hoje
						lRet := .f.
					EndIf
					If !lRet
						cMsg := STR0002+PULALINHA+PULALINHA // Veiculo Reservado!
						cMsg += STR0019+" "+( cQAlAux )->( VV0_FILIAL )+PULALINHA // Filial:
						cMsg += STR0020+" "+( cQAlAux )->( VV0_NUMTRA )+PULALINHA // Atendimento: 
						cMsg += STR0021+" "+( cQAlAux )->( VV0_CODVEN )+" - "+left(FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+( cQAlAux )->( VV0_CODVEN )+"' AND D_E_L_E_T_=' '"),25)+PULALINHA // Vendedor:
						cMsg += STR0008+" "+Transform(dDtRes,"@D")+" "+Transform(cHorTmp,"@R 99:99") // Validade:
						Exit
					EndIf
				EndIf
				( cQAlAux )->( DbSkip() )
			EndDo
			( cQAlAux )->( DbCloseArea() )
			If !lRet
				cMsg += VXX120041_ChassiMarcaModeloVeiculo(.t.)
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} VXX120021_ValidaStatusAtendimentos
	Valida se existe outros Atendimentos (por Status) com o mesmo Veiculo
	
	@author Andre Luis Almeida
	@since 06/03/2020
/*/
Function VXX120021_ValidaStatusAtendimentos( cNumAte , cChassi , cChaInt , cMsg )
Local cFilVVA    := xFilial("VVA")
Local cFilOut    := VXX120031_LevantaOutrasFiliaisVVA( cFilVVA )
Local cQuery      := ""
Local cQAlAux     := "SQLAUX"
Local lRet        := .t.
Local cBloqStat   := GetNewPar("MV_BLQSTAV","LO") // Nao mostrar veiculos que estao em Atendimentos com os STATUS informados neste Parametro
Local lSelVeiUti  := ( GetNewPar("MV_MIL0018","1") == "1" ) // Seleciona o veiculo quando o mesmo ja esta relacionado em outro atendimento? (0=Nao/1=Sim)
Local lVV9_APRPUS := ( VV9->(ColumnPos("VV9_APRPUS")) <> 0 )

cNumAte := PadR(cNumAte, GetSX3Cache("VVA_NUMTRA","X3_TAMANHO"))
//
If !lSelVeiUti .or. !Empty(cBloqStat) // Nao mostrar veiculos que estao em Atendimentos com os STATUS informados neste Parametro
	//
	If !Empty(cChaInt)
		dbSelectArea("VV1")
		dbSetOrder(1) //Filial+ChaInt
		dbSeek(xFilial("VV1")+cChaInt)
	EndIf
	//
	////////////////////////////////////////////////////////////////////////
	// VERIFICA ATENDIMENTOS COM STATUS QUE BLOQUEIAM O VEICULO           //
	////////////////////////////////////////////////////////////////////////
	cQuery := "SELECT VV9.VV9_FILIAL , VV9.VV9_NUMATE , VV9.VV9_STATUS , VV0.VV0_CODVEN , "
	If lVV9_APRPUS .and. "L" $ cBloqStat // Considerar Aprovacao Previa se considera Status Aprovado
		cQuery += " VV9.VV9_APRPUS AS APR_PREVIA "
	Else
		cQuery += " ' ' AS APR_PREVIA " // Branco para desconsiderar Aprovacao Previa
	EndIf
	cQuery += "  FROM "+RetSQLName("VVA")+" VVA "
	cQuery += "  JOIN "+RetSQLName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VV0.D_E_L_E_T_ = ' ' ) "
	cQuery += "  JOIN "+RetSQLName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VVA.VVA_FILIAL AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND VV9.VV9_STATUS NOT IN ('C','F','T','R','D') AND VV9.D_E_L_E_T_ = ' ' ) "
	cQuery += " WHERE "
	cQuery += "  ( ( VVA.VVA_FILIAL='"+cFilVVA+"' AND VVA.VVA_NUMTRA<>'"+cNumAte+"' ) " + IIf( ! Empty(cFilOut) , " OR ( VVA.VVA_FILIAL IN ("+cFilOut+") ) " , "" ) + " ) "
	If !Empty(cChassi)
		cQuery += "  AND VVA.VVA_CHASSI='"+cChassi+"'" // Necessario devido a validação nas demais Filiais
	Else
		cQuery += "  AND VVA.VVA_CHAINT='"+cChaInt+"'"
		cQuery += "  AND VVA.VVA_CHASSI=' '" // Necessario devido a validação nas demais Filiais
	EndIf
	cQuery += "  AND VVA.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
	While !( cQAlAux )->( Eof() )
		If !lSelVeiUti .or. ( cQAlAux )->( VV9_STATUS ) $ cBloqStat .or. !Empty( ( cQAlAux )->( APR_PREVIA ) ) // STATUS de outro Atendimento do mesmo Veiculo que bloqueia novo Atendimento
			cMsg := STR0009+PULALINHA+PULALINHA // Veiculo ja esta bloqueado!
			cMsg += STR0019+" "+( cQAlAux )->( VV9_FILIAL )+PULALINHA // Filial:
			cMsg += STR0020+" "+( cQAlAux )->( VV9_NUMATE )+PULALINHA // Atendimento:
			cMsg += STR0021+" "+( cQAlAux )->( VV0_CODVEN )+" - "+left(FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+( cQAlAux )->( VV0_CODVEN )+"' AND D_E_L_E_T_=' '"),25) // Vendedor:
			lRet := .f.
			Exit
		EndIf
		( cQAlAux )->( dbSkip() )
	EndDo
	( cQAlAux )->( dbCloseArea() )
	If !lRet
		cMsg += VXX120041_ChassiMarcaModeloVeiculo(.t.)
	EndIf
EndIf
//
Return lRet

/*/{Protheus.doc} VXX120031_LevantaOutrasFiliaisVVA
	Levanta Outras Filiais do VVA
	
	@author Andre Luis Almeida
	@since 06/03/2020
/*/
Static Function VXX120031_LevantaOutrasFiliaisVVA( cFilVVA )
Local aFilAtu    := FWArrFilAtu()
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt := cFilAnt
Local nCntFor    := 0
Local cFilOut    := ""
//	
For nCntFor := 1 to len(aSM0)
	cFilAnt := aSM0[nCntFor]
	If cFilVVA <> xFilial("VVA")
		cFilOut += "'"+xFilial("VVA")+"',"
	EndIf
Next
cFilOut := Iif(Len(cFilOut)>0,left(cFilOut,len(cFilOut)-1),"' '")
cFilAnt := cBkpFilAnt
//
Return cFilOut

/*/{Protheus.doc} VXX120041_ChassiMarcaModeloVeiculo
	Carrega Veiculo para Mensagens de Erro
	
	@author Andre Luis Almeida
	@since 06/03/2020
/*/
Function VXX120041_ChassiMarcaModeloVeiculo(lPulaLinha)
Local cRet := ""
Default lPulaLinha := .t.
If lPulaLinha
	cRet += PULALINHA+PULALINHA
EndIf
cRet += STR0022+PULALINHA // Veiculo:
cRet += Alltrim(IIf(!Empty(VV1->VV1_CHASSI),VV1->VV1_CHASSI,VV1->VV1_CHAINT))+" - "+Alltrim(VV1->VV1_CODMAR)+" "+Alltrim(VV1->VV1_MODVEI)
Return cRet
