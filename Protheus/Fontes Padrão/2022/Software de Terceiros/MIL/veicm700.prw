// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 16     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "Protheus.ch"
#Include "VEICM700.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICM700 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 09/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Geracao das Parcelas e NF ( VQ9 / SF2 / SD2 )              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM700()
Local aSizeAut	:= MsAdvSize(.f.)
Local cVldLimCred := GetNewPar("MV_MIL0141","0") // Valida Limite de Credito do Cliente
Local lVQ9CODVRO  := ( VQ9->(ColumnPos("VQ9_CODVRO")) > 0 )
Private cCadastro := STR0001 // Comissao de Consorcios e Seguros - Geracao das Parcelas e NF
Private aCampos := {}
Private lMenNota:= ( VQ9->(ColumnPos("VQ9_MENNOT")) > 0 ) // Tem campos de Mensagem de NF
Private nRecVRO := 0 // Liberacao de Credito

If Empty(cVldLimCred)
	cVldLimCred := "0" // NAO VALIDAR
EndIf

oVEICM700 := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cCadastro,,,,128,,,,,.t.)

If cVldLimCred <> "0" .and. lVQ9CODVRO // Se tiver habilitado para checar Limite de Credito mostra o Browse de Solicitações de Credito

	oTPanVQ9 := TPanel():New(0,0,"",oVEICM700,NIL,.T.,.F.,NIL,NIL,100,(oVEICM700:nClientHeight/4)-10,.F.,.F.)
	oTPanVQ9:Align := CONTROL_ALIGN_TOP

	oTPanVRO := TPanel():New(0,0,"",oVEICM700,NIL,.T.,.F.,NIL,NIL,100,(oVEICM700:nClientHeight/4)-10,.F.,.F.)
	oTPanVRO:Align := CONTROL_ALIGN_BOTTOM 

Else // Se NAO tiver habilitado para checar Limite de Credito NAO mostra o Browse de Solicitações de Credito

	oTPanVQ9 := TPanel():New(0,0,"",oVEICM700,NIL,.T.,.F.,NIL,NIL,100,100,.F.,.F.)
	oTPanVQ9:Align := CONTROL_ALIGN_ALLCLIENT

EndIf

oBrwVQ9 := FWMBrowse():New()
oBrwVQ9:SetAlias("VQ9")
oBrwVQ9:SetOwner(oTPanVQ9)
oBrwVQ9:SetDescription(cCadastro)
oBrwVQ9:AddFilter( STR0095 , " VQ9_TIPO == '2' ",.f.,.f.,) // Consórcios
oBrwVQ9:AddLegend( "VQ9_TIPO='2' .and.  Empty(VQ9_NUMNFI+VQ9_SERNFI)", "BR_VERDE"   , STR0009 ) // Consorcio sem NF
oBrwVQ9:AddLegend( "VQ9_TIPO='2' .and. !Empty(VQ9_NUMNFI+VQ9_SERNFI)", "BR_BRANCO"  , STR0010 ) // Consorcios com NF
oBrwVQ9:AddFilter( STR0096 , " VQ9_TIPO == '3' ",.f.,.f.,) // Seguros
oBrwVQ9:AddLegend( "VQ9_TIPO='3' .and.  Empty(VQ9_NUMNFI+VQ9_SERNFI)", "BR_AMARELO" , STR0011 ) // Seguros sem NF
oBrwVQ9:AddLegend( "VQ9_TIPO='3' .and. !Empty(VQ9_NUMNFI+VQ9_SERNFI)", "BR_LARANJA" , STR0012 ) // Seguros com NF
oBrwVQ9:AddFilter( STR0097 , " VQ9_TIPO == '4' ",.f.,.f.,) // Serviços Diversos
oBrwVQ9:AddLegend( "VQ9_TIPO='4' .and.  Empty(VQ9_NUMNFI+VQ9_SERNFI)", "BR_AZUL"    , STR0083 ) // Serviços Diversos sem NF
oBrwVQ9:AddLegend( "VQ9_TIPO='4' .and. !Empty(VQ9_NUMNFI+VQ9_SERNFI)", "BR_PRETO"   , STR0084 ) // Serviços Diversos com NF

oBrwVQ9:DisableDetails()
oBrwVQ9:Activate()
oBrwVQ9:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

If cVldLimCred <> "0" .and. lVQ9CODVRO // Se tiver habilitado para checar Limite de Credito mostra o Browse de Solicitações de Credito
	oBrwVRO := FWMBrowse():New()
	oBrwVRO:SetAlias("VRO")
	oBrwVRO:SetOwner(oTPanVRO)
	oBrwVRO:SetDescription(STR0088) // Liberação de Crédito de Clientes referente a Filial e Tipo selecionado acima
	oBrwVRO:SetMenuDef('VEIA200')
	oBrwVRO:AddFilter( STR0094 , " ( VRO_STATUS='0' .or. ( Empty(VRO_USRUTI) .and. DTOS(VRO_DATVAL)>='"+dtos(dDataBase)+"' ) ) ",.t.,.t.,) // Filtro Padrão
	oBrwVRO:AddLegend( "VRO_STATUS='0'"                                                                      , "BR_BRANCO"   , STR0089 ) // Solicitação Pendente Liberação
	oBrwVRO:AddLegend( "VRO_STATUS='1' .and. DTOS(VRO_DATVAL)>='"+dtos(dDataBase)+"' .and. Empty(VRO_USRUTI)", "BR_AMARELO"  , STR0090 ) // Solicitação Liberada e aguardando utilização
	oBrwVRO:AddLegend( "VRO_STATUS='2' .and. DTOS(VRO_DATVAL)>='"+dtos(dDataBase)+"'"                        , "BR_VERMELHO" , STR0091 ) // Solicitação Rejeitada
	oBrwVRO:DisableDetails()
	oBrwVRO:Activate()
	oBrwVRO:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	//
	oRelac:= FWBrwRelation():New()
	oRelac:AddRelation( oBrwVQ9 , oBrwVRO , { { "VRO_FILIAL", "VQ9_FILIAL" } , { "VRO_TIPO" , "VQ9_TIPO" } } )
	oRelac:Activate()
	//
EndIf

oVEICM700:Activate()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM700PAR³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Geracao de NF ( SF2 / SD2 )                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM700PAR()
Local cQuery    := ""
Local cSQLAlias := "SQLALIAS"
Local dDatIni   := ( ( dDataBase - day(dDataBase) ) + 1 )
Local dDatFin   := dDataBase
Local nDias1    := 0 // Dias 1a.parcela
Local nDiasD    := 0 // Dias demais parcelas
Local ni        := 0
Local nx        := 3
Local aParcAux  := {}
Local aParcel   := {}
Local cParcel   := ""
Local dData     := dDataBase
Local nVlr1     := 0
Local nVlr      := 0
Local nVlrTot   := 0
Local nQtd      := 0
Local aObjects  := {} , aPos := {} , aInfo := {}
Local aSizeAut  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local aParamBox := {}
Local aRet      := {}
Local cFilVQ7   := xFilial("VQ7")
Local cFilVQ8   := xFilial("VQ8")
Local cFilVQM   := xFilial("VQM")
Local cFilVQ9   := xFilial("VQ9")
Local nSelecao  := 0 // 2-Consorcio / 3-Seguro / 4-Srv.Divers.
Local lOk       := .f.
Local dDtIParc  := ctod("")
Local dDtFParc  := ctod("")
Local cCodAdm   := space(GeTSX3Cache("VQ7_CODADM","X3_TAMANHO")) // Administradora
Local cCodSeg   := space(GeTSX3Cache("VQ8_SEGURA","X3_TAMANHO")) // Seguradora
Local cNumPed   := space(GeTSX3Cache("VQM_NUMPED","X3_TAMANHO")) // Nro.Pedido
Local nQtdLib   := 0
Local aPvlNfs   := {}
Local cNota     := ""
Local cSerie    := ""
Local cObs      := ""
Local aStatVQ7  := X3CBOXAVET("VQ7_STATUS","0")
Local cStatVQ7  := ""
Local aStatVQ8  := X3CBOXAVET("VQ8_STATUS","0")
Local cStatVQ8  := ""
Local aStatVQM  := X3CBOXAVET("VQM_STATUS","0")
Local cStatVQM  := ""
Local cParamSX6 := space(21)
Local cMsgSC9   := ""
Local i         := 0 
Local aTipCli   := X3CBOXAVET("A1_TIPO","0")
Local aIndPre   := X3CBOXAVET("VV0_INDPRE","0")
Local cIndPre   := ""
Local cTitTELA  := ""
Local cPrefNFT  := GetNewPar("MV_MIL0160","DMS") // Prefixo NF/Titulos de Venda de Serviços Diversos
Local lVQ9CODVRO := ( VQ9->(ColumnPos("VQ9_CODVRO")) > 0 )
Local aEndss 	:= {}
//
Local oCliente  := DMS_Cliente():New()
//
Local ii := 0
//
Private cMenNota:= space(GeTSX3Cache("C5_MENNOTA","X3_TAMANHO"))
Private cMenPad := space(GeTSX3Cache("C5_MENPAD","X3_TAMANHO"))
//
Private cTipCli := ""
Private aCabPV  := {}
Private aItePV  := {}
Private aIteTPV := {}
Private nValTot := 0
Private nValEnd := 0
Private cCodPgt := space(3)
Private cCodCli := space(GeTSX3Cache("A1_COD","X3_TAMANHO"))
Private cLojCli := space(GeTSX3Cache("A1_LOJA","X3_TAMANHO"))
Private cNomCli := ""
Private cCodTES := space(3)
Private cCodSB1 := space(GeTSX3Cache("B1_COD","X3_TAMANHO"))
Private cCodSA3 := space(GeTSX3Cache("A3_COD","X3_TAMANHO"))
Private cNomSB1 := ""
Private cNomSA3 := ""
Private cCodBco := space(3)
Private cCodNat := space(10)
Private oOk     := LoadBitmap( GetResources(), "LBTIK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )   
Private cObserv := space(200)       
Private aMemos  := {{"VQ9_OBSMEM","VQ9_OBSERV"}}
Private aRotina := MenuDef()
//
nSelecao := Aviso(STR0014,STR0018,{STR0015,STR0016,STR0076,STR0017}) // Atencao / Gerar parcelas para? / Consorcio / Seguro / Srv.Divers. / SAIR
If nSelecao == 0 .or. nSelecao == 4 // Cancelou tela ou clicou no botao SAIR
	Return .f.
EndIf
nSelecao++ // Somar um para deixar igual a Base de Dados: 2-Consorcio / 3-Seguro / 4-Srv.Divers.
//
cParamSX6 := left(GetMV("MV_MIL0041")+space(40),40)
cCodPgt   := left(substr(cParamSX6,01,03)+space(03),03)
cCodTES   := left(substr(cParamSX6,04,03)+space(03),03)
cCodSB1   := left(substr(cParamSX6,07,15)+space(15),15)
cCodBco   := left(substr(cParamSX6,22,03)+space(03),03)
cCodNat   := left(substr(cParamSX6,25,10)+space(10),10)
If !Empty(cCodSB1)
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+cCodSB1))
		cNomSB1 := SB1->B1_DESC
	EndIf
EndIf
//
AADD(aParamBox,{1,STR0019,dDatIni,"@D","","","",50,.t.}) // Dt.Inicial Venda
AADD(aParamBox,{1,STR0020,dDatFin,"@D","","","",50,.t.}) // Dt.Final Venda
Do Case
	Case nSelecao == 2 // Consorcio
		cTitTELA := STR0015 // Consorcio
		AADD(aParamBox,{1,STR0021,space(GeTSX3Cache("VQ7_CODADM","X3_TAMANHO")),"@!","Empty(MV_PAR03).or.FG_Seek('VV4','MV_PAR03',1,.f.)","VV4","",50,.t.}) // Administradora
		For ni := 1 to len(aStatVQ7)
			aAdd(aParamBox,{5,STR0023+" - "+aStatVQ7[ni],.F.,150,"",.F.}) // Status
		Next
	Case nSelecao == 3 // Seguro
		cTitTELA := STR0016 // Seguro
		AADD(aParamBox,{1,STR0022,space(GeTSX3Cache("VQ8_SEGURA","X3_TAMANHO")),"@!","Empty(MV_PAR03).or.FG_Seek('VC9','MV_PAR03',1,.f.)","VC9","",50,.t.}) // Seguradora
		For ni := 1 to len(aStatVQ8)
			aAdd(aParamBox,{5,STR0023+" - "+aStatVQ8[ni],.F.,150,"",.F.}) // Status
		Next
	Case nSelecao == 4 // Serv.Diversos
		cTitTELA := STR0085 // Prestação de Servicos Diversos
		AADD(aParamBox,{1,STR0077,space(GeTSX3Cache("VQM_NUMPED","X3_TAMANHO")),"@!","","","",50,.t.}) // Nro.Pedido
		For ni := 1 to len(aStatVQM)
			aAdd(aParamBox,{5,STR0023+" - "+aStatVQM[ni],.F.,150,"",.F.}) // Status
		Next
EndCase
If ParamBox(aParamBox,STR0024,@aRet,,,,,,,,.f.,.f.) // Gerar
	dDatIni := aRet[01] // Dt. Inicial
	dDatFin := aRet[02] // Dt. Final
	Do Case
		Case nSelecao == 2 // Consorcio
			cCodAdm := aRet[03] // Administradora
			If Empty(cCodAdm)
				MsgStop(STR0025,STR0014) // Necessario informar a Administradora do Consorcio. / Atencao
				Return .f.
			EndIf
			For ni := 1 to len(aStatVQ7)
				nx++
				cStatVQ7 += IIf(aRet[nx],"'"+left(aStatVQ7[ni],GeTSX3Cache("VQ7_STATUS","X3_TAMANHO"))+"',","")
			Next
			If len(cStatVQ7) > 0
				cStatVQ7 := left(cStatVQ7,len(cStatVQ7)-1)
			Else
				MsgStop(STR0026,STR0014) // Necessario informar o Indicador do Consorcio (STATUS). / Atencao
				Return .f.
			EndIf
		Case nSelecao == 3 // Seguro
			cCodSeg := aRet[03] // Seguradora
			If Empty(cCodSeg)
				MsgStop(STR0027,STR0014) // Necessario informar a Seguradora do Seguro. / Atencao
				Return .f.
			EndIf
			For ni := 1 to len(aStatVQ8)
				nx++
				cStatVQ8 += IIf(aRet[nx],"'"+left(aStatVQ8[ni],GeTSX3Cache("VQ8_STATUS","X3_TAMANHO"))+"',","")
			Next
			If len(cStatVQ8) > 0
				cStatVQ8 := left(cStatVQ8,len(cStatVQ8)-1)
			Else
				MsgStop(STR0028,STR0014) // Necessario informar o Indicador do Seguro (STATUS). / Atencao
				Return .f.
			EndIf
		Case nSelecao == 4 // Serv.Diversos
			cNumPed := aRet[03] // Nro.Pedido
			If Empty(cNumPed)
				MsgStop(STR0078,STR0014) // Necessario informar o Numero do Pedido. / Atencao
				Return .f.
			EndIf
			For ni := 1 to len(aStatVQM)
				nx++
				cStatVQM += IIf(aRet[nx],"'"+left(aStatVQM[ni],GeTSX3Cache("VQM_STATUS","X3_TAMANHO"))+"',","")
			Next
			If len(cStatVQM) > 0
				cStatVQM := left(cStatVQM,len(cStatVQM)-1)
			Else
				MsgStop(STR0079,STR0014) // Necessario informar o Indicador do Servicos Diversos (STATUS). / Atencao
				Return .f.
			EndIf
	EndCase
Else
	Return .f.
EndIf

Do Case
////////////////////////////////////
	Case nSelecao == 2 // Consorcio VQ7
////////////////////////////////////
		DbSelectArea("VV4")
		DbSetOrder(1)
		If DbSeek(xFilial("VV4")+cCodAdm)
			cCodCli := VV4->VV4_CODCLI
			cLojCli := VV4->VV4_LOJCLI
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
				If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
					Return .f.
				EndIf
				cNomCli := SA1->A1_NOME
				cTipCli := SA1->A1_TIPO
			EndIf
			If OA2000021_Existe_Solicitacao(strzero(nSelecao,1),cCodCli,cLojCli,"1",0,dDataBase,.t.) <= 0 // Procura por Solicitacao Liberada
				If OA2000021_Existe_Solicitacao(strzero(nSelecao,1),cCodCli,cLojCli,"0",0,dDataBase,.t.) <= 0 // Procura por Solicitacao Pendente Liberação
					OA2000021_Existe_Solicitacao(strzero(nSelecao,1),cCodCli,cLojCli,"2",0,dDataBase,.t.) // Procura por Solicitacao Rejeitada
				EndIf
			EndIf
		EndIf
		nDias1 := 15
		nDiasD := 120
		cQuery := "SELECT VQ9.R_E_C_N_O_ RECVQ9 , VQ9.VQ9_CODIGO , VQ9.VQ9_DATVEN , VQ9.VQ9_NUMPAR , VQ9.VQ9_VALCOM , VQ7.VQ7_DATVDA , "
		cQuery += "VQ7.VQ7_CODCLI , VQ7.VQ7_LOJCLI , SA1.A1_NOME , VQ7.VQ7_CODADM , VQ7.VQ7_CODGRU , VQ7.VQ7_CODQUO , VQ7.VQ7_CODVEN , SA3.A3_NOME "
		cQuery += "FROM "+RetSQLName("VQ9")+" VQ9 "
		cQuery += "JOIN	"+RetSQLName("VQ7")+" VQ7 ON ( VQ7.VQ7_FILIAL='"+xFilial("VQ7")+"' AND VQ7.VQ7_CODIGO=VQ9.VQ9_CODIGO AND VQ7.VQ7_DATVDA>='"+dtos(dDatIni)+"' AND VQ7.VQ7_DATVDA<='"+dtos(dDatFin)+"' AND VQ7.VQ7_CODADM='"+cCodAdm+"' AND VQ7.VQ7_STATUS IN ("+cStatVQ7+") AND VQ7.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VQ7.VQ7_CODCLI AND SA1.A1_LOJA=VQ7.VQ7_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VQ7.VQ7_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VQ9.VQ9_FILIAL='"+xFilial("VQ9")+"' AND "
		cQuery += "VQ9.VQ9_TIPO='2' AND VQ9.VQ9_NUMNFI=' ' AND VQ9.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
		While !(cSQLAlias)->(Eof())
			cObs := " / "+STR0029+":"+(cSQLAlias)->( VQ7_CODVEN )+"-"+left((cSQLAlias)->( A3_NOME ),15)
			cObs += " / "+STR0030+":"+(cSQLAlias)->( VQ7_CODCLI )+"-"+(cSQLAlias)->( VQ7_LOJCLI )+" "+left((cSQLAlias)->( A1_NOME ),15)
			cObs += " / "+STR0031+":"+(cSQLAlias)->( VQ7_CODADM )+" "+STR0032+":"+(cSQLAlias)->( VQ7_CODGRU )+" "+STR0033+":"+(cSQLAlias)->( VQ7_CODQUO )
			aAdd(aParcel,{ .f. , (cSQLAlias)->( VQ9_NUMPAR ) , stod((cSQLAlias)->( VQ9_DATVEN )) , round((cSQLAlias)->( VQ9_VALCOM ),2) , (cSQLAlias)->( VQ9_CODIGO ) , "2" , Transform(stod((cSQLAlias)->( VQ7_DATVDA )),"@D")+cObs , (cSQLAlias)->( RECVQ9 ) })
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
		cQuery := "SELECT VQ7.VQ7_CODIGO , VQ7.VQ7_DATVDA , VQ7.VQ7_QTDPCM , VQ7.VQ7_COMTOT , VQ7.VQ7_VLRVEN , "
		cQuery += "VQ7.VQ7_CODCLI , VQ7.VQ7_LOJCLI , SA1.A1_NOME , VQ7.VQ7_CODADM , VQ7.VQ7_CODGRU , VQ7.VQ7_CODQUO , VQ7.VQ7_CODVEN , SA3.A3_NOME "
		cQuery += "FROM "+RetSQLName("VQ7")+" VQ7 "
		cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VQ7.VQ7_CODCLI AND SA1.A1_LOJA=VQ7.VQ7_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VQ7.VQ7_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VQ7.VQ7_FILIAL='"+xFilial("VQ7")+"' AND "
		cQuery += "VQ7.VQ7_DATVDA>='"+dtos(dDatIni)+"' AND VQ7.VQ7_DATVDA<='"+dtos(dDatFin)+"' AND VQ7.VQ7_STATUS IN ("+cStatVQ7+") AND "
		cQuery += "VQ7.VQ7_CODADM='"+cCodAdm+"' AND VQ7.VQ7_GEROUP='0' AND VQ7_QTDPCM > 0 AND VQ7.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
		While !(cSQLAlias)->(Eof())
			If aScan(aParcel,{|x| x[6]+x[5] == "2"+(cSQLAlias)->( VQ7_CODIGO ) }) <= 0
				dData    := stod((cSQLAlias)->( VQ7_DATVDA )) + nDias1
				nQtd     := 0
				nVlr1    := 0
				nVlr     := 0
				nVlrTot  := 0
				aParcAux := {}
				For ni := 1 to (cSQLAlias)->( VQ7_QTDPCM )
					cParcel := strzero(ni,3)+strzero((cSQLAlias)->( VQ7_QTDPCM ),3)
					If ni == 1 .and. (cSQLAlias)->( VQ7_QTDPCM ) > 1 // 1a.parcela 1%
						nVlr1 := ( (cSQLAlias)->( VQ7_VLRVEN ) * ( 1 / 100 ) )
						nVlr  := nVlr1
						nQtd  := 1
					Else
						nVlr := ( (cSQLAlias)->( VQ7_COMTOT ) - nVlr1 ) / ( (cSQLAlias)->( VQ7_QTDPCM ) - nQtd )
					EndIf
					cObs := " / "+STR0029+":"+(cSQLAlias)->( VQ7_CODVEN )+"-"+left((cSQLAlias)->( A3_NOME ),15)
					cObs += " / "+STR0030+":"+(cSQLAlias)->( VQ7_CODCLI )+"-"+(cSQLAlias)->( VQ7_LOJCLI )+" "+left((cSQLAlias)->( A1_NOME ),15)
					cObs += " / "+STR0031+":"+(cSQLAlias)->( VQ7_CODADM )+" "+STR0032+":"+(cSQLAlias)->( VQ7_CODGRU )+" "+STR0033+":"+(cSQLAlias)->( VQ7_CODQUO )
					aAdd(aParcAux,{ .f. , cParcel , dData , round(nVlr,2) , (cSQLAlias)->( VQ7_CODIGO ) , "2" , Transform(stod((cSQLAlias)->( VQ7_DATVDA )),"@D")+cObs , 0 })
					dData   += nDiasD
					nVlrTot += nVlr
				Next
				If nVlrTot <> (cSQLAlias)->( VQ7_COMTOT )
					If nVlrTot > (cSQLAlias)->( VQ7_COMTOT )
						aParcAux[len(aParcAux),4] := ( aParcAux[len(aParcAux),4] - ( nVlrTot - (cSQLAlias)->( VQ7_COMTOT ) ) )
					Else // nVlrTot < (cSQLAlias)->( VQ7_COMTOT )
						aParcAux[len(aParcAux),4] := ( aParcAux[len(aParcAux),4] + ( (cSQLAlias)->( VQ7_COMTOT ) - nVlrTot ) )
					EndIf
				EndIf
				For ni := 1 to len(aParcAux)
					aAdd(aParcel,aParcAux[ni])
				Next
			EndIf
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
////////////////////////////////////
	Case nSelecao == 3 // Seguro VQ8
////////////////////////////////////
		nDias1 := 30
		nDiasD := 30
		cQuery := "SELECT VQ9.R_E_C_N_O_ RECVQ9 , VQ9.VQ9_CODIGO , VQ9.VQ9_DATVEN , VQ9.VQ9_NUMPAR , VQ9.VQ9_VALCOM , VQ8.VQ8_DATVIG , "
		cQuery += "VQ8.VQ8_CODCLI , VQ8.VQ8_LOJCLI , SA1.A1_NOME , VQ8.VQ8_APOLIC , VQ8.VQ8_CORRET , VQ8.VQ8_SEGURA , VQ8.VQ8_CODVEN , SA3.A3_NOME "
		cQuery += "FROM "+RetSQLName("VQ9")+" VQ9 "
		cQuery += "JOIN	"+RetSQLName("VQ8")+" VQ8 ON ( VQ8.VQ8_FILIAL='"+xFilial("VQ8")+"' AND VQ8.VQ8_CODIGO=VQ9.VQ9_CODIGO AND VQ8.VQ8_DATVIG>='"+dtos(dDatIni)+"' AND VQ8.VQ8_DATVIG<='"+dtos(dDatFin)+"' AND VQ8.VQ8_SEGURA='"+cCodSeg+"' AND VQ8.VQ8_STATUS IN ("+cStatVQ8+") AND VQ8.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VQ8.VQ8_CODCLI AND SA1.A1_LOJA=VQ8.VQ8_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VQ8.VQ8_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VQ9.VQ9_FILIAL='"+xFilial("VQ9")+"' AND "
		cQuery += "VQ9.VQ9_TIPO='3' AND VQ9.VQ9_NUMNFI=' ' AND VQ9.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
		While !(cSQLAlias)->(Eof())
			cObs := " / "+STR0029+":"+(cSQLAlias)->( VQ8_CODVEN )+"-"+left((cSQLAlias)->( A3_NOME ),15)
			cObs += " / "+STR0030+":"+(cSQLAlias)->( VQ8_CODCLI )+"-"+(cSQLAlias)->( VQ8_LOJCLI )+" "+left((cSQLAlias)->( A1_NOME ),15)
			cObs += " / "+STR0034+":"+(cSQLAlias)->( VQ8_APOLIC )+" "+STR0035+":"+(cSQLAlias)->( VQ8_CORRET )+" "+STR0022+":"+(cSQLAlias)->( VQ8_SEGURA )
			aAdd(aParcel,{ .f. , (cSQLAlias)->( VQ9_NUMPAR ) , stod((cSQLAlias)->( VQ9_DATVEN )) , round((cSQLAlias)->( VQ9_VALCOM ),2) , (cSQLAlias)->( VQ9_CODIGO ) , "3" , Transform(stod((cSQLAlias)->( VQ8_DATVIG )),"@D")+cObs , (cSQLAlias)->( RECVQ9 ) })
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
		cQuery := "SELECT VQ8.VQ8_CODIGO , VQ8.VQ8_DATVIG , VQ8.VQ8_QTDPCM , VQ8.VQ8_COMTOT , VQ8.VQ8_VALTOT , "
		cQuery += "VQ8.VQ8_CODCLI , VQ8.VQ8_LOJCLI , SA1.A1_NOME , VQ8.VQ8_APOLIC , VQ8.VQ8_CORRET , VQ8.VQ8_SEGURA , VQ8.VQ8_CODVEN , SA3.A3_NOME "
		cQuery += "FROM "+RetSQLName("VQ8")+" VQ8 "
		cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VQ8.VQ8_CODCLI AND SA1.A1_LOJA=VQ8.VQ8_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VQ8.VQ8_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VQ8.VQ8_FILIAL='"+xFilial("VQ8")+"' AND "
		cQuery += "VQ8.VQ8_DATVIG>='"+dtos(dDatIni)+"' AND VQ8.VQ8_DATVIG<='"+dtos(dDatFin)+"' AND VQ8.VQ8_STATUS IN ("+cStatVQ8+") AND "
		cQuery += "VQ8.VQ8_SEGURA='"+cCodSeg+"' AND VQ8.VQ8_GEROUP='0' AND VQ8.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
		While !(cSQLAlias)->(Eof())
			If aScan(aParcel,{|x| x[6]+x[5] == "3"+(cSQLAlias)->( VQ8_CODIGO ) }) <= 0
				dData    := stod((cSQLAlias)->( VQ8_DATVIG )) + nDias1
				nVlr     := 0
				nVlrTot  := 0
				aParcAux := {}
				For ni := 1 to (cSQLAlias)->( VQ8_QTDPCM )
					cParcel := strzero(ni,3)+strzero((cSQLAlias)->( VQ8_QTDPCM ),3)
					nVlr := ( (cSQLAlias)->( VQ8_COMTOT ) / (cSQLAlias)->( VQ8_QTDPCM ) )
					cObs := " / "+STR0029+":"+(cSQLAlias)->( VQ8_CODVEN )+"-"+left((cSQLAlias)->( A3_NOME ),15)
					cObs += " / "+STR0030+":"+(cSQLAlias)->( VQ8_CODCLI )+"-"+(cSQLAlias)->( VQ8_LOJCLI )+" "+left((cSQLAlias)->( A1_NOME ),15)
					cObs += " / "+STR0034+":"+(cSQLAlias)->( VQ8_APOLIC )+" "+STR0035+":"+(cSQLAlias)->( VQ8_CORRET )+" "+STR0022+":"+(cSQLAlias)->( VQ8_SEGURA )
					aAdd(aParcAux,{ .f. , cParcel , dData , round(nVlr,2) , (cSQLAlias)->( VQ8_CODIGO ) , "3" , Transform(stod((cSQLAlias)->( VQ8_DATVIG )),"@D")+cObs , 0 })
					dData   += nDiasD
					nVlrTot += nVlr
				Next
				If nVlrTot <> (cSQLAlias)->( VQ8_COMTOT )
					If nVlrTot > (cSQLAlias)->( VQ8_COMTOT )
						aParcAux[len(aParcAux),4] := ( aParcAux[len(aParcAux),4] - ( nVlrTot - (cSQLAlias)->( VQ8_COMTOT ) ) )
					Else // nVlrTot < (cSQLAlias)->( VQ8_COMTOT )
						aParcAux[len(aParcAux),4] := ( aParcAux[len(aParcAux),4] + ( (cSQLAlias)->( VQ8_COMTOT ) - nVlrTot ) )
					EndIf
				EndIf
				For ni := 1 to len(aParcAux)
					aAdd(aParcel,aParcAux[ni])
				Next
			EndIf
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
////////////////////////////////////
	Case nSelecao == 4 // Servicos Diversos VQM
////////////////////////////////////
		nDias1 := 30
		nDiasD := 30
		cQuery := "SELECT VQ9.R_E_C_N_O_ RECVQ9 , VQ9.VQ9_CODIGO , VQ9.VQ9_DATVEN , VQ9.VQ9_NUMPAR , VQ9.VQ9_VALCOM , VQM.VQM_DATPED , "
		cQuery += "VQM.VQM_CODCLI , VQM.VQM_LOJCLI , SA1.A1_NOME , VQM.VQM_NUMPED , VQM.VQM_TIPSER , VQM.VQM_NROREF , VQM.VQM_CODVEN , SA3.A3_NOME "
		cQuery += "FROM "+RetSQLName("VQ9")+" VQ9 "
		cQuery += "JOIN	"+RetSQLName("VQM")+" VQM ON ( VQM.VQM_FILIAL='"+xFilial("VQM")+"' AND VQM.VQM_CODIGO=VQ9.VQ9_CODIGO AND VQM.VQM_DATPED>='"+dtos(dDatIni)+"' AND VQM.VQM_DATPED<='"+dtos(dDatFin)+"' AND VQM.VQM_NUMPED='"+cNumPed+"' AND VQM.VQM_STATUS IN ("+cStatVQM+") AND VQM.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VQM.VQM_CODCLI AND SA1.A1_LOJA=VQM.VQM_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VQM.VQM_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VQ9.VQ9_FILIAL='"+xFilial("VQ9")+"' AND "
		cQuery += "VQ9.VQ9_TIPO='4' AND VQ9.VQ9_NUMNFI=' ' AND VQ9.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
		While !(cSQLAlias)->(Eof())
			cObs := " / "+STR0029+":"+(cSQLAlias)->( VQM_CODVEN )+"-"+left((cSQLAlias)->( A3_NOME ),15)
			cObs += " / "+STR0030+":"+(cSQLAlias)->( VQM_CODCLI )+"-"+(cSQLAlias)->( VQM_LOJCLI )+" "+left((cSQLAlias)->( A1_NOME ),15)
			cObs += " / "+STR0077+":"+(cSQLAlias)->( VQM_NUMPED )+" "+STR0080+":"+(cSQLAlias)->( VQM_TIPSER )+" "+STR0081+":"+(cSQLAlias)->( VQM_NROREF )
			aAdd(aParcel,{ .f. , (cSQLAlias)->( VQ9_NUMPAR ) , stod((cSQLAlias)->( VQ9_DATVEN )) , round((cSQLAlias)->( VQ9_VALCOM ),2) , (cSQLAlias)->( VQ9_CODIGO ) , "4" , Transform(stod((cSQLAlias)->( VQM_DATPED )),"@D")+cObs , (cSQLAlias)->( RECVQ9 ) })
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
		cQuery := "SELECT VQM.VQM_CODIGO , VQM.VQM_DATPED , VQM.VQM_QTDPCM , VQM.VQM_COMTOT , VQM.VQM_VALTOT , "
		cQuery += "VQM.VQM_CODCLI , VQM.VQM_LOJCLI , SA1.A1_NOME , VQM.VQM_NUMPED , VQM.VQM_TIPSER , VQM.VQM_NROREF , VQM.VQM_CODVEN , SA3.A3_NOME "
		cQuery += "FROM "+RetSQLName("VQM")+" VQM "
		cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VQM.VQM_CODCLI AND SA1.A1_LOJA=VQM.VQM_LOJCLI AND SA1.D_E_L_E_T_=' ' ) "
		cQuery += "LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VQM.VQM_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VQM.VQM_FILIAL='"+xFilial("VQM")+"' AND "
		cQuery += "VQM.VQM_DATPED>='"+dtos(dDatIni)+"' AND VQM.VQM_DATPED<='"+dtos(dDatFin)+"' AND VQM.VQM_STATUS IN ("+cStatVQM+") AND "
		cQuery += "VQM.VQM_NUMPED='"+cNumPed+"' AND VQM.VQM_GEROUP='0' AND VQM.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
		While !(cSQLAlias)->(Eof())
			If aScan(aParcel,{|x| x[6]+x[5] == "4"+(cSQLAlias)->( VQM_CODIGO ) }) <= 0
				dData    := stod((cSQLAlias)->( VQM_DATPED )) + nDias1
				nVlr     := 0
				nVlrTot  := 0
				aParcAux := {}
				For ni := 1 to (cSQLAlias)->( VQM_QTDPCM )
					cParcel := strzero(ni,3)+strzero((cSQLAlias)->( VQM_QTDPCM ),3)
					nVlr := ( (cSQLAlias)->( VQM_COMTOT ) / (cSQLAlias)->( VQM_QTDPCM ) )
					cObs := " / "+STR0029+":"+(cSQLAlias)->( VQM_CODVEN )+"-"+left((cSQLAlias)->( A3_NOME ),15)
					cObs += " / "+STR0030+":"+(cSQLAlias)->( VQM_CODCLI )+"-"+(cSQLAlias)->( VQM_LOJCLI )+" "+left((cSQLAlias)->( A1_NOME ),15)
					cObs += " / "+STR0077+":"+(cSQLAlias)->( VQM_NUMPED )+" "+STR0080+":"+(cSQLAlias)->( VQM_TIPSER )+" "+STR0081+":"+(cSQLAlias)->( VQM_NROREF )
					aAdd(aParcAux,{ .f. , cParcel , dData , round(nVlr,2) , (cSQLAlias)->( VQM_CODIGO ) , "4" , Transform(stod((cSQLAlias)->( VQM_DATPED )),"@D")+cObs , 0 })
					dData   += nDiasD
					nVlrTot += nVlr
				Next
				If nVlrTot <> (cSQLAlias)->( VQM_COMTOT )
					If nVlrTot > (cSQLAlias)->( VQM_COMTOT )
						aParcAux[len(aParcAux),4] := ( aParcAux[len(aParcAux),4] - ( nVlrTot - (cSQLAlias)->( VQM_COMTOT ) ) )
					Else // nVlrTot < (cSQLAlias)->( VQM_COMTOT )
						aParcAux[len(aParcAux),4] := ( aParcAux[len(aParcAux),4] + ( (cSQLAlias)->( VQM_COMTOT ) - nVlrTot ) )
					EndIf
				EndIf
				For ni := 1 to len(aParcAux)
					aAdd(aParcel,aParcAux[ni])
				Next
			EndIf
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
EndCase
DbSelectArea("VQ9")
////////////////////////////////////
If Len(aParcel) > 0

	DbSelectArea("VQ9")
	aObjects := {}
	AAdd( aObjects, { 05, 80 , .T., .F. } )  //Cabecalho
	AAdd( aObjects, {  1, 10, .T. , .T. } )  //list box
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPos := MsObjSize (aInfo, aObjects,.F.)      

	DEFINE MSDIALOG oGerarParc From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] TITLE (cTitTELA+" - "+STR0036) of oMainWnd PIXEL
	oGerarParc:lEscClose := .F.
	@ aPos[1,1]+00,aPos[1,2]+003 TO aPos[1,1]+30,140 LABEL STR0037 OF oGerarParc PIXEL
	@ aPos[1,1]+12,aPos[1,2]+009 MSGET oDatIni VAR dDatIni PICTURE "@D" SIZE 45,8 OF oGerarParc PIXEL COLOR CLR_BLUE WHEN .f.
	@ aPos[1,1]+12,aPos[1,2]+060 SAY STR0039 SIZE 10,8 OF oGerarParc PIXEL COLOR CLR_BLUE // a
	@ aPos[1,1]+12,aPos[1,2]+070 MSGET oDatFin VAR dDatFin PICTURE "@D" SIZE 45,8 OF oGerarParc PIXEL COLOR CLR_BLUE WHEN .f.

	@ aPos[1,1]+30,aPos[1,2]+003 TO aPos[1,1]+61,140 LABEL STR0038 OF oGerarParc PIXEL
	@ aPos[1,1]+42,aPos[1,2]+009 MSGET oDtIParc VAR dDtIParc PICTURE "@D" SIZE 45,8 OF oGerarParc PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+42,aPos[1,2]+060 SAY STR0039 SIZE 10,8 OF oGerarParc PIXEL COLOR CLR_BLUE // a
	@ aPos[1,1]+42,aPos[1,2]+070 MSGET oDtFParc VAR dDtFParc PICTURE "@D" SIZE 45,8 OF oGerarParc PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+42,aPos[1,2]+118 BUTTON oSelec PROMPT "OK" OF oGerarParc SIZE 15,10 PIXEL ACTION FS_SELEC(@aParcel,dDtIParc,dDtFParc)
	
	@ aPos[1,1]+64,aPos[1,2]+003 TO aPos[1,1]+80,140 LABEL "" OF oGerarParc PIXEL
	@ aPos[1,1]+68,aPos[1,2]+009 SAY STR0041 SIZE 100,8 OF oGerarParc PIXEL COLOR CLR_BLUE // Total selecao:
	@ aPos[1,1]+67,aPos[1,2]+050 MSGET oValTot VAR nValTot PICTURE "@E 999,999,999.99" SIZE 80,8 OF oGerarParc PIXEL COLOR CLR_BLUE WHEN .f.

	@ aPos[1,1]+00,aPos[1,2]+141 TO aPos[1,1]+80,aPos[1,4] LABEL STR0042 OF oGerarParc PIXEL

	@ aPos[1,1]+11,aPos[1,2]+145 SAY STR0066 SIZE 40,8 OF oGerarParc PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+10,aPos[1,2]+180 MSGET oCodPgt VAR cCodPgt PICTURE "@!" VALID (vazio().or.(FG_Seek("SE4","cCodPgt",1,.f.).and.SE4->E4_TIPO<>"9".and.SE4->E4_TIPO<>"A")) F3 "SE4" SIZE 20,8 OF oGerarParc PIXEL COLOR CLR_BLUE

	@ aPos[1,1]+11,aPos[1,2]+275 SAY STR0068 SIZE 40,8 OF oGerarParc PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+10,aPos[1,2]+300 MSGET oCodCli VAR cCodCli PICTURE "@!" VALID FS_DESCR(1,nSelecao) F3 "SA1" SIZE 35,8 OF oGerarParc PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+10,aPos[1,2]+336 MSGET oLojCli VAR cLojCli PICTURE "@!" VALID FS_DESCR(1,nSelecao) SIZE 15,8 OF oGerarParc PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+10,aPos[1,2]+354 MSGET oNomCli VAR cNomCli PICTURE "@!" SIZE (aPos[1,4]-364),8 OF oGerarParc PIXEL COLOR CLR_BLUE WHEN .f.

	@ aPos[1,1]+22,aPos[1,2]+145 SAY STR0069 SIZE 40,8 OF oGerarParc PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+21,aPos[1,2]+180 MSGET oCodTES VAR cCodTES PICTURE "@!" VALID (vazio().or.(FG_Seek("SF4","cCodTES",1,.f.).and.SF4->F4_TIPO=="S")) F3 "SF4" SIZE 20,8 OF oGerarParc PIXEL COLOR CLR_BLUE

	@ aPos[1,1]+22,aPos[1,2]+275 SAY STR0071 SIZE 40,8 OF oGerarParc PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+21,aPos[1,2]+300 MSGET oCodSB1 VAR cCodSB1 PICTURE "@!" VALID FS_DESCR(2,nSelecao) F3 "SB1" SIZE 67,8 OF oGerarParc PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+21,aPos[1,2]+370 MSGET oNomSB1 VAR cNomSB1 PICTURE "@!" SIZE (aPos[1,4]-380),8 OF oGerarParc PIXEL COLOR CLR_BLUE WHEN .f.

	@ aPos[1,1]+33,aPos[1,2]+145 SAY STR0067 SIZE 40,8 OF oGerarParc PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+32,aPos[1,2]+180 MSGET oCodBco VAR cCodBco PICTURE "@!" SIZE 20,8 OF oGerarParc PIXEL COLOR CLR_BLUE

	@ aPos[1,1]+33,aPos[1,2]+275 SAY STR0075 SIZE 40,8 OF oGerarParc PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+32,aPos[1,2]+300 MSGET oCodSA3 VAR cCodSA3 PICTURE "@!" VALID FS_DESVEND() F3 "SA3" SIZE 57,8 OF oGerarParc PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+32,aPos[1,2]+370 MSGET oNomSA3 VAR cNomSA3 PICTURE "@!" SIZE (aPos[1,4]-380),8 OF oGerarParc PIXEL COLOR CLR_BLUE WHEN .f.

	@ aPos[1,1]+44,aPos[1,2]+145 SAY STR0070 SIZE 40,8 OF oGerarParc PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+43,aPos[1,2]+180 MSGET oCodNat VAR cCodNat PICTURE "@!" VALID (vazio().or.FG_Seek("SED","cCodNat",1,.f.)) F3 "SED" SIZE 45,8 OF oGerarParc PIXEL COLOR CLR_BLUE
    
	@ aPos[1,1]+55,aPos[1,2]+145 SAY STR0073 SIZE 40,8 OF oGerarParc PIXEL COLOR CLR_BLUE // Tp.Cliente
	@ aPos[1,1]+54,aPos[1,2]+180 MSCOMBOBOX oTipCli VAR cTipCli SIZE 90,08 ITEMS aTipCli OF oGerarParc PIXEL COLOR CLR_BLUE
    
	@ aPos[1,1]+66,aPos[1,2]+145 SAY STR0074 SIZE 40,8 OF oGerarParc PIXEL COLOR CLR_BLUE // Ind.Presenca
	@ aPos[1,1]+65,aPos[1,2]+180 MSCOMBOBOX oIndPre VAR cIndPre SIZE 90,08 ITEMS aIndPre OF oGerarParc PIXEL COLOR CLR_BLUE

	If lMenNota // Tem campos de Mensagem de NF
		@ aPos[1,1]+45,aPos[1,2]+275 SAY STR0087 SIZE 50,8 OF oGerarParc PIXEL COLOR CLR_BLUE // Mensagem NF
		@ aPos[1,1]+54,aPos[1,2]+275 MSGET oMenPad VAR cMenPad PICTURE "@!" VALID (texto().or.Vazio()) F3 "SM4" SIZE 40,8 OF oGerarParc PIXEL COLOR CLR_BLUE
		@ aPos[1,1]+65,aPos[1,2]+275 MSGET oMenNota VAR cMenNota PICTURE "@!" SIZE 95,8 OF oGerarParc PIXEL COLOR CLR_BLUE
		@ aPos[1,1]+44,aPos[1,2]+375 SAY STR0072 SIZE 150,8 OF oGerarParc PIXEL COLOR CLR_BLUE
		@ aPos[1,1]+51,aPos[1,2]+375 GET oObserv VAR cObserv OF oGerarParc MEMO SIZE (aPos[1,4]-385),aPos[1,3]-aPos[1,1]-55 PIXEL MEMO
	Else
		@ aPos[1,1]+44,aPos[1,2]+275 SAY STR0072 SIZE 150,8 OF oGerarParc PIXEL COLOR CLR_BLUE
		@ aPos[1,1]+51,aPos[1,2]+275 GET oObserv VAR cObserv OF oGerarParc MEMO SIZE (aPos[1,4]-285),aPos[1,3]-aPos[1,1]-55 PIXEL MEMO
	EndIf

	@ aPos[2,1],aPos[2,2]+2 LISTBOX oLbParc FIELDS HEADER "",STR0008,STR0049,STR0050,(STR0051+" / "+STR0029+" / "+STR0030) COLSIZES 10,30,40,50,280 SIZE aPos[2,4]-4,aPos[2,3]-aPos[2,1]-10 OF oGerarParc PIXEL ON DBLCLICK FS_TIK(@aParcel,oLbParc:nAt,@dDtIParc,@dDtFParc,oLbParc:nColPos)
	oLbParc:SetArray(aParcel)
	oLbParc:bLine := { || {IIf(aParcel[oLbParc:nAt,1],oOk,oNo) , Transform(aParcel[oLbParc:nAt,2],"@R 999/999") , Transform(aParcel[oLbParc:nAt,3],"@D") , FG_AlinVlrs(Transform(aParcel[oLbParc:nAt,4],"@E 999,999,999.99")) , aParcel[oLbParc:nAt,7] }}

	ACTIVATE MSDIALOG oGerarParc ON INIT EnchoiceBar(oGerarParc,{|| IIf(FS_VALOK(nSelecao),(lOk:=.t.,oGerarParc:End()),.t.)},{ || oGerarParc:End()},,)
	
	If lOk

		If nSelecao == 3 // Seguro
			aEndss := FS_ENDOSSO(nSelecao)
			For ii := 1 to len(aEndss)
				If aEndss[ii,1]
					nValTot := round(nValTot,2) - aEndss[ii,4]
				Endif
			Next
		Endif

		lOk := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"),"")
		If !lOk
			Return .f.
		EndIf
		//

		//
		Begin Transaction
		//

		For ni := 1 to len(aParcel)
			If aParcel[ni,1]
				Do Case
					Case aParcel[ni,6] == "2" // Consorcio
						DbSelectArea("VQ7")
						DbSetOrder(2)
						If DbSeek(cFilVQ7+aParcel[ni,5])
							RecLock("VQ7",.f.)
								VQ7->VQ7_GEROUP := "1"
								VQ7->VQ7_SALDO  -= aParcel[ni,4]
							MsUnLock()
						EndIf
					Case aParcel[ni,6] == "3" // Seguro
						DbSelectArea("VQ8")
						DbSetOrder(1)
						If DbSeek(cFilVQ8+aParcel[ni,5])
							RecLock("VQ8",.f.)
								VQ8->VQ8_GEROUP := "1"
								VQ8->VQ8_SALDO  -= aParcel[ni,4]
							MsUnLock()
						EndIf
					Case aParcel[ni,6] == "4" // Servicos Diversos
						DbSelectArea("VQM")
						DbSetOrder(1)
						If DbSeek(cFilVQM+aParcel[ni,5])
							RecLock("VQM",.f.)
								VQM->VQM_GEROUP := "1"
								VQM->VQM_SALDO  -= aParcel[ni,4]
							MsUnLock()
						EndIf
				EndCase
			EndIf
		Next
		For ni := 1 to len(aParcel)
			If aParcel[ni,8] == 0
				DbSelectArea("VQ9")
				RecLock("VQ9",.t.)
				VQ9->VQ9_FILIAL := cFilVQ9
				VQ9->VQ9_TIPO   := aParcel[ni,6]
				VQ9->VQ9_CODIGO := aParcel[ni,5]
				VQ9->VQ9_NUMPAR := aParcel[ni,2]
				VQ9->VQ9_DATVEN := aParcel[ni,3]
				VQ9->VQ9_VALCOM := aParcel[ni,4]
				MsUnLock()
			EndIf
		Next
		//
		SA1->(DbSetOrder(1))
		SA1->(MsSeek(xFilial("SA1")+cCodCli+cLojCli))
		//
		SB1->(DbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+cCodSB1))
		//
		SE4->(dbSetOrder(1))
		SE4->(MsSeek(xFilial("SE4")+cCodPgt))
		//
		aCabPV  := {}
		aItePV  := {}
		aIteTPV := {}
		//
		cNumPed := CriaVar("C5_NUM")
		aAdd(aCabPV,{"C5_NUM"    ,cNumPed			,Nil})		// Numero do pedido
		aAdd(aCabPV,{"C5_TIPO"   ,"N"           	,Nil}) 		// Tipo de pedido
		aAdd(aCabPV,{"C5_CLIENTE",SA1->A1_COD  		,Nil})		// Codigo do cliente
		aAdd(aCabPV,{"C5_LOJACLI",SA1->A1_LOJA 		,Nil})		// Loja do cliente
		aAdd(aCabPV,{"C5_TABELA" ,space(GeTSX3Cache("C5_TABELA","X3_TAMANHO")),Nil})	// Tabela de Preco
		aAdd(aCabPV,{"C5_CONDPAG",cCodPgt			,Nil}) 		// Codigo da condicao de pagamento
		aAdd(aCabPV,{"C5_EMISSAO",dDataBase     	,Nil})		// Data de emissao
		aAdd(aCabPV,{"C5_DESC1"  ,0             	,Nil}) 		// Percentual de Desconto
		aAdd(aCabPV,{"C5_TIPLIB" ,"2"           	,Nil})		// Liberacao por Pedido de Venda
		aAdd(aCabPV,{"C5_MOEDA"  ,1             	,Nil})		// Moeda
		aAdd(aCabPV,{"C5_LIBEROK","S"           	,Nil})		// Liberacao Total
		If !Empty(cTipCli) 
			aAdd(aCabPV,{"C5_TIPOCLI",cTipCli,Nil})
		EndIf
		If !Empty(cIndPre) .and. SC5->(FieldPos("C5_INDPRES")) > 0
			aAdd(aCabPV,{"C5_INDPRES",cIndPre,Nil})
		EndIf
		If !Empty(cCodBco)
			aAdd(aCabPV,{"C5_BANCO"  ,cCodBco		,Nil})
		EndIf
		If !Empty(cCodNat) .and. SC5->(FieldPos("C5_NATUREZ")) > 0
			aAdd(aCabPV,{"C5_NATUREZ" ,cCodNat		,Nil})
		EndIf
		If !Empty(cCodSA3) .and. SC5->(FieldPos("C5_VEND1")) > 0
			aAdd(aCabPV,{"C5_VEND1",cCodSA3,Nil}) 
		EndIf		
		If lMenNota // Tem campos de Mensagem de NF
			If !Empty(cMenNota)
				aAdd(aCabPV,{"C5_MENNOTA",cMenNota  ,Nil}) // Mensagem da NF
			EndIf
			If !Empty(cMenPad)
				aAdd(aCabPV,{"C5_MENPAD" ,cMenPad   ,Nil}) // Mensagem Padrao NF
			EndIf		
		EndIf
		//
		aAdd(aIteTPV,{"C6_NUM"    ,cNumPed			,Nil}) // Numero do Pedido
		aAdd(aIteTPV,{"C6_ITEM"   ,"01"				,Nil}) // Numero do Item no Pedido
		aAdd(aIteTPV,{"C6_PRODUTO",SB1->B1_COD		,Nil}) // Codigo do Produto
		aAdd(aIteTPV,{"C6_QTDVEN" ,1				,Nil}) // Quantidade Vendida
		aAdd(aIteTPV,{"C6_QTDLIB" ,0				,Nil}) // Quantidade Liberada para faturamento
		aAdd(aIteTPV,{"C6_PRUNIT" ,nValTot			,Nil}) // Preco Unitario Liquido *
		aAdd(aIteTPV,{"C6_PRCVEN" ,nValTot			,Nil}) // Preco Unitario Liquido *
		aAdd(aIteTPV,{"C6_VALOR"  ,nValTot			,Nil}) // Valor Total do Item *
		aAdd(aIteTPV,{"C6_CLI"    ,SA1->A1_COD		,Nil}) // Cliente
		aAdd(aIteTPV,{"C6_LOJA"   ,SA1->A1_LOJA		,Nil}) // Loja do Cliente
		aAdd(aIteTPV,{"C6_ENTREG" ,dDataBase		,Nil}) // Data da Entrega
		aAdd(aIteTPV,{"C6_UM"     ,SB1->B1_UM   	,Nil}) // Unidade de Medida Primar.
		aAdd(aIteTPV,{"C6_TES"    ,cCodTES			,Nil}) // Tipo de Entrada/Saida do Item
		aAdd(aIteTPV,{"C6_LOCAL"  ,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")	,Nil}) // Almoxarifado
		aAdd(aIteTPV,{"C6_DESCRI" ,SB1->B1_DESC		,Nil}) // Descricao do Produto
		aAdd(aItePV,aClone(aIteTPV))
		// PE para Alteração dos Vetores aCabPV e aItePV, antes da Geração do Pedido de Venda
		if ExistBlock("PEGERNFS")
			if !ExecBlock("PEGERNFS",.f.,.f.)
				Return .f.
			Endif
		Endif
		//
		lMSHelpAuto := .t.
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItePv,3) //Faz Liberacao do Pedido se LiberOk = "S" e QtdLib = QtdEmp
		if lMsErroAuto
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			MostraErro()
			MaFisEnd()
			MaFisRestore()
			Return .f.
		Endif
		//
		cNumPed := SC5->C5_NUM
		//
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ LIBERACAO do Pedido de Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lCredito := .t.
		lEstoque := .t.
		lLiber   := .t.
		lTransf  := .f.
		SC9->(dbSetOrder(1))
		SC6->(dbSetOrder(1))
		SC6->(dbSeek(xFilial("SC6") + cNumPed + "01"))
		While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPed
			If !SC9->(dbSeek(xFilial("SC9")+cNumPed+SC6->C6_ITEM))
				nQtdLib := SC6->C6_QTDVEN
				nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf)
			EndIf
			SC6->(dbSkip())
		Enddo
		//
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Selecionando Itens para Faturamento ... ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SC5->(dbSetOrder(1))
		SC6->(dbSetOrder(1))
		SB1->(dbSetOrder(1))
		SB2->(dbSetOrder(1))
		SB5->(dbSetOrder(1))
		SF4->(dbSetOrder(1))
		SE4->(dbSetOrder(1))
		SC9->(dbSeek(xFilial("SC9") + cNumPed + "01"))
		While !SC9->(Eof()) .and. xFilial("SC9") == SC9->C9_FILIAL .and. SC9->C9_PEDIDO == cNumPed
			If Empty(SC9->C9_BLEST)
				SC5->(dbSeek( xFilial("SC5") + SC9->C9_PEDIDO ))
				SC6->(dbSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM ))
				SB1->(dbSeek( xFilial("SB1") + SC9->C9_PRODUTO ))
				SB2->(dbSeek( xFilial("SB2") + SB1->B1_COD ))
				SB5->(dbSeek( xFilial("SB5") + SB1->B1_COD ))
				SF4->(MsSeek( xFilial("SF4") + SC6->C6_TES ))
				SE4->(MsSeek( xFilial("SE4") + SC5->C5_CONDPAG ))
				aAdd(aPvlNfs,{SC9->C9_PEDIDO,;
								SC9->C9_ITEM,;
								SC9->C9_SEQUEN,;
								SC9->C9_QTDLIB,;
								SC9->C9_PRCVEN,;
								SC9->C9_PRODUTO,;
								SF4->F4_ISS=="S",;
								SC9->(RecNo()),;
								SC5->(RecNo()),;
								SC6->(RecNo()),;
								SE4->(RecNo()),;
								SB1->(RecNo()),;
								SB2->(RecNo()),;
								SF4->(RecNo())})
			Else
				cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLEST"))+": "+SC9->C9_BLEST+CHR(13)+CHR(10)
			EndIf
			SC9->(dbSkip())
		Enddo
		If !Empty(cMsgSC9) // Problema!!!
			MsgStop(STR0008+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsgSC9,STR0002) // Pedido sem itens liberados! / Atencao
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			MaFisEnd()
			Return .f.
		EndIf		
		If len(aPvlNfs) == 0 .and. !FGX_SC5BLQ(cNumPed,.t.) // Verifica SC5 bloqueado
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			MaFisEnd()
			Return .f.
		EndIf
		ConfirmSx8()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gerando Nota Fiscal de Saida ... ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCntSE1 := 0
		cNota := MaPvlNfs(aPvlNfs,;           // 01
						  cSerie,;            // 02
						  (mv_par01 == 1),;   // 03
						  (mv_par02 == 1),;   // 04
						  (mv_par03 == 1),;   // 05
						  (mv_par04 == 1),;   // 06
						  .F.,;               // 07
						  0,;                 // 08
						  0,;                 // 09
						  .T.,;               // 10
						  .F.,;               // 11
						  ,;				  // 12
						  ,;				  // 13
						  ,;				  // 14
						  ,;				  // 15
						  ,)				  // 16
		If lMsErroauto
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			MaFisEnd()
			MostraErro()
			Return .f.
		EndIf
		ConfirmSx8()
		//
		If nRecVRO > 0 // Utilizou a Liberacao de Credito
			OA2000041_Utiliza_Solicitacao(nRecVRO,nValTot)
		EndIf
		//
		DbSelectArea("VQ9")
		DbSetOrder(1) // VQ9_FILIAL+VQ9_TIPO+VQ9_CODIGO+VQ9_NUMPAR
		For ni := 1 to len(aParcel)
			If aParcel[ni,1]
				If VQ9->(DbSeek(cFilVQ9+strzero(nSelecao,1)+aParcel[ni,5]+aParcel[ni,2]))
					RecLock("VQ9",.f.)
					VQ9->VQ9_NUMNFI := cNota
					VQ9->VQ9_SERNFI := cSerie
					If lMenNota // Tem campos de Mensagem de NF
						VQ9->VQ9_MENNOT := cMenNota
						VQ9->VQ9_MENPAD := cMenPad
					EndIf
					If lVQ9CODVRO .and. nRecVRO > 0 // Utilizou a Liberacao de Credito
						VQ9->VQ9_CODVRO := VRO->VRO_CODIGO // VRO ja posicionado na funcao OA2000041_Utiliza_Solicitacao()
					EndIf
					MSMM(,GeTSX3Cache("VQ9_OBSERV","X3_TAMANHO"),,cobserv,1,,,"VQ9","VQ9_OBSMEM")
					MsUnLock()
				EndIf
			EndIf
		Next
		DbSelectArea("VQF")
		DbSetOrder(2)
		For ii := 1 to len(aEndss)
			If aEndss[ii,1]
				RecLock("VQf",.f.)
				If DbSeek(xFilial("VQF")+aEndss[ii,2]+aEndss[ii,3])
					RecLock("VQF",.f.)
					VQF->VQF_NFENDO := cNota
					VQF->VQF_SRENDO := cSerie
					VQF->VQF_DTUSOE := dDataBase
					MsUnLock()
				Endif
			Endif
		Next
		//
		If !Empty(cCodBco) .or. !Empty(cCodSA3) .or. !Empty(cPrefNFT) // GRAVAR E1_PORTADO / E1_VEND1 / E1_PREFORI
			DbSelectArea("SE1")
			DbSetOrder(1)
			DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL)
			While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. SE1->E1_PREFIXO==SF2->F2_PREFIXO .and. SE1->E1_NUM==SF2->F2_DUPL
				RecLock("SE1",.f.)
				If !( SE1->E1_TIPO $ MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVPIABT )
					SE1->E1_PORTADO := cCodBco
				EndIf
				SE1->E1_VEND1   := cCodSA3
				SE1->E1_PREFORI := cPrefNFT
				MsUnLock()
				DbSkip()
			EndDo
		EndIf
		If !Empty(cCodSA3) .or. !Empty(cPrefNFT) // GRAVAR F2_VEND1 / F2_PREFORI
			RecLock("SF2",.f.)  
			SF2->F2_PREFORI := cPrefNFT		
			SF2->F2_VEND1   := cCodSA3		
			MsUnLock()
	  	Endif
		//
		End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX6")
		MsRUnLock()
		//
		MsUnlockAll()
		//
		PutMv("MV_MIL0041",cCodPgt+cCodTES+cCodSB1+cCodBco+cCodNat)
		//
		FMX_TELAINF( "1" , { { Alltrim(cSerie) , Alltrim(cNota) , "EMITIDO" } } ) // "EMITIDO"
		//		
	EndIf

Else

	Do Case
		Case nSelecao == 2 // Consorcio
			MsgAlert(STR0052,STR0014) // Nenhuma venda aberta de Consorcio no periodo! / Atencao
		Case nSelecao == 3 // Seguro
			MsgAlert(STR0053,STR0014) // Nenhuma venda aberta de Seguro no periodo! / Atencao
		Case nSelecao == 4 // Servicos Diversos
			MsgAlert(STR0082,STR0014) // Nenhuma venda aberta de Servicos Diversos no periodo! / Atencao
	EndCase

EndIf
////////////////////////////////////
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_DESCR ³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Descricao do Cliente (1) / Produto (2)                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DESCR(nTp,nSelecao)
Local lRet := .t.
//
Local oCliente   := DMS_Cliente():New()
//
If nTp == 1 // Cliente
	cNomCli := ""
	If Empty(cCodCli)
		cLojCli := space(GeTSX3Cache("A1_LOJA","X3_TAMANHO"))
	EndIf
	If !Empty(cCodCli+cLojCli)
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+cCodCli+Alltrim(cLojCli)))
			If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
				lRet := .f.
			Else
				cLojCli := SA1->A1_LOJA
				cNomCli := SA1->A1_NOME
				cTipCli := SA1->A1_TIPO
				If UPPER(ReadVar()) == "CLOJCLI" // Somente verificar Solicitacao se estiver no campo da LOJA do Cliente.
					If OA2000021_Existe_Solicitacao(strzero(nSelecao,1),cCodCli,cLojCli,"1",0,dDataBase,.t.) <= 0 // Procura por Solicitacao Liberada
						If OA2000021_Existe_Solicitacao(strzero(nSelecao,1),cCodCli,cLojCli,"0",0,dDataBase,.t.) <= 0 // Procura por Solicitacao Pendente Liberação
							OA2000021_Existe_Solicitacao(strzero(nSelecao,1),cCodCli,cLojCli,"2",0,dDataBase,.t.) // Procura por Solicitacao Rejeitada
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			lRet := .f.
		EndIf
	EndIf
	oLojCli:Refresh()
	oNomCli:Refresh()
	oTipCli:Refresh()
ElseIf nTp == 2 // Produto
	cNomSB1 := ""
	If !Empty(cCodSB1)
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1")+cCodSB1))
			cNomSB1 := SB1->B1_DESC
		Else
			lRet := .f.
		EndIf
	EndIf
	oNomSB1:Refresh()
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALOK ³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do OK da tela                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALOK(nSelecao)
Local lRet := .t.
Local cMsg := ""
Local cVldLimCred := GetNewPar("MV_MIL0141","0") // Valida Limite de Credito do Cliente
Local cCondPagNAO := GetNewPar("MV_CPNCLC","") // Condicoes de Pagamento que NAO devem ser checados os Limites de Credito
Local lVQ9CODVRO  := ( VQ9->(ColumnPos("VQ9_CODVRO")) > 0 )
If Empty(cVldLimCred)
	cVldLimCred := "0" // NAO VALIDAR
EndIf
If nValTot <= 0
	MsgStop(STR0060,STR0014) // Necessario informar uma ou mais parcelas! / Atencao
	lRet := .f.
EndIf
If lRet .and. Empty(cCodCli+cLojCli)
	MsgStop(STR0064,STR0014) // Necessario informar o Cliente/Loja! / Atencao
	lRet := .f.
EndIf
If lRet .and. Empty(cCodTES)
	MsgStop(STR0061,STR0014) // Necessario informar um TES para geração da NF de comissao! / Atencao
	lRet := .f.
EndIf
If lRet .and. Empty(cCodSB1)
	MsgStop(STR0062,STR0014) // Necessario informar um Produto para compor a NF de comissao! / Atencao
	lRet := .f.
EndIf
If lRet .and. Empty(cCodPgt)
	MsgStop(STR0063,STR0014) // Necessario informar a Condição de Pagamento da NF de comissao! / Atencao
	lRet := .f.
EndIf
If lRet .and. Empty(cCodSA3)
	MsgStop(STR0086,STR0014) // Necessario informar campo vendedor! / Atencao
	lRet := .f.
EndIf

If nValTot <= nValEnd
	MsgStop(STR0105,STR0014) // Valor do Endosso maior que o total da NF! / Atencao
	lRet := .f.
EndIf

nRecVRO := 0 // Liberacao de Credito
If lRet .and. ( strzero(nSelecao,1) $ cVldLimCred ) // 2-Consorcio / 3-Seguro / 4-Srv.Divers.
	If Empty(cCondPagNAO) .or. !AllTrim(cCodPgt) $ cCondPagNAO // Verificar se a Condicao de Pagamento deve checar Limite de Credito
		/////////////////////////////////////////
		// CHECAR LIMITE DE CREDITO DO CLIENTE //
		/////////////////////////////////////////
		If !FGX_AVALCRED( cCodCli , cLojCli , nValTot , .t. )
			If lVQ9CODVRO
				nRecVRO := OA2000021_Existe_Solicitacao(strzero(nSelecao,1),cCodCli,cLojCli,"1",nValTot,dDataBase,.f.) // Procura por Solicitacao Liberada
				If nRecVRO <= 0
					If OA2000021_Existe_Solicitacao(strzero(nSelecao,1),cCodCli,cLojCli,"0",nValTot,dDataBase,.t.) <= 0 // Procura por Solicitacao Pendente Liberação
						OA2000021_Existe_Solicitacao(strzero(nSelecao,1),cCodCli,cLojCli,"2",nValTot,dDataBase,.t.) // Procura por Solicitacao Rejeitada
						cMsg := STR0092+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Deseja Solcitar Liberação?
						cMsg += STR0068+" "+cCodCli+"-"+cLojCli+" "+cNomCli+CHR(13)+CHR(10)+CHR(13)+CHR(10)
						Do Case
							Case strzero(nSelecao,1) == "2"
								cMsg += STR0015 // Consorcio
							Case strzero(nSelecao,1) == "3"
								cMsg += STR0016 // Seguro
							Case strzero(nSelecao,1) == "4"
								cMsg += STR0085 // Prestação de Serviços Diversos
						EndCase
						cMsg += " - "+STR0050+": "+Alltrim(Transform(nValTot,"@E 999,999,999.99")) // Valor
						If MsgYesNo(cMsg,STR0093) // Cliente sem Limite de Crédito!
							OA2000031_Cria_Solicitacao(strzero(nSelecao,1),cCodCli,cLojCli,nValTot)
						EndIf
					EndIf
					lRet := .f.
				EndIf
			Else // Forma ANTIGA - caso nao exista os campos novos para Liberacao de Credito
				Help("  ",1,"LIMITECRED",,(STR0068+" "+cCodCli+"-"+cLojCli+" "+cNomCli),4,1)
				lRet := .f.
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK   ³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tik                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(aParcel,nPos,dDtIParc,dDtFParc,nCol)
Local aParamBox := {}
Local aRet      := {}
Local ni        := 0
If nCol <= 1
	aParcel[nPos,1] := !aParcel[nPos,1]
Else
	AADD(aParamBox,{1,STR0059,aParcel[nPos,4],"@E 999,999,999.99","","","",80,.t.}) // Valor da Parcela
	If ParamBox(aParamBox,STR0059,@aRet,,,,,,,,.f.,.f.) // Valor da Parcela
		aParcel[nPos,4] := aRet[01] // Valor
		aParcel[nPos,1] := .t.
		If aParcel[nPos,8] > 0
			DbSelectArea("VQ9")
			DbGoto(aParcel[nPos,8])
			RecLock("VQ9",.f.)
				VQ9->VQ9_VALCOM := aParcel[nPos,4]
			MsUnLock()			
		EndIf
	Else
		Return()
	EndIf
EndIf
nValTot := 0
aEval(aParcel , {|x| nValTot += IIF( x[1] , x[4] , 0 ) } )
nValTot := round(nValTot,2)
oValTot:Refresh()
dDtIParc := ctod("")
dDtFParc := ctod("")
For ni := 1 to len(aParcel)
	If aParcel[ni,1]
		If dDtFParc < aParcel[ni,3]
			dDtFParc := aParcel[ni,3]
			If Empty(dDtIParc)
				dDtIParc := aParcel[ni,3]
			EndIf
		EndIf
		If dDtIParc > aParcel[ni,3]
			dDtIParc := aParcel[ni,3]
		EndIf
	EndIf
Next
oDtIParc:Refresh()
oDtFParc:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_SELEC ³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Selecao das parcelas pela Data                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SELEC(aParcel,dDtIParc,dDtFParc)
Local ni := 0
nValTot := 0
For ni := 1 to len(aParcel)
	aParcel[ni,1] := .f.
	If aParcel[ni,3] >= dDtIParc .and. aParcel[ni,3] <= dDtFParc
		aParcel[ni,1] := .t.
		nValTot += aParcel[ni,4]
	EndIf
Next
oValTot:Refresh()
oLbParc:SetArray(aParcel)
oLbParc:bLine := { || {IIf(aParcel[oLbParc:nAt,1],oOk,oNo) , Transform(aParcel[oLbParc:nAt,2],"@R 999/999") , Transform(aParcel[oLbParc:nAt,3],"@D") , FG_AlinVlrs(Transform(aParcel[oLbParc:nAt,4],"@E 999,999,999.99")) , aParcel[oLbParc:nAt,7] }}
oLbParc:Refresh()
Return()                       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM700TPG³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Titulos Pagamentos (Total/Parcial)                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM700TPG()
Local nSaldo  := 0
Local cRet    := ""
Local cQuery  := ""
Local cNamSF2 := ""
Local cNamSE1 := ""
Local cFilSF2 := ""
Local cFilSE1 := ""
If !Empty(VQ9->VQ9_NUMNFI+VQ9->VQ9_SERNFI)
	cNamSF2 := RetSQLName("SF2")
	cNamSE1 := RetSQLName("SE1")
	cFilSF2 := xFilial("SF2")
	cFilSE1 := xFilial("SE1")
	cQuery := "SELECT SUM(SE1.E1_SALDO) "
	cQuery += "FROM "+cNamSF2+" SF2 "
	cQuery += "JOIN	"+cNamSE1+" SE1 ON ( SE1.E1_FILIAL='"+cFilSE1+"' AND SE1.E1_PREFIXO=SF2.F2_PREFIXO AND SE1.E1_NUM=SF2.F2_DOC AND SE1.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE SF2.F2_FILIAL='"+cFilSF2+"' AND SF2.F2_DOC='"+VQ9->VQ9_NUMNFI+"' AND SF2.F2_SERIE='"+VQ9->VQ9_SERNFI+"' AND SF2.D_E_L_E_T_=' '"
	nSaldo := FM_SQL(cQuery)
	If nSaldo == 0
		cRet := STR0054 // Total
		If Empty(VQ9->VQ9_DATPAG)
			cQuery := "SELECT MAX(SE1.E1_BAIXA) "
			cQuery += "FROM "+cNamSF2+" SF2 "
			cQuery += "JOIN	"+cNamSE1+" SE1 ON ( SE1.E1_FILIAL='"+cFilSE1+"' AND SE1.E1_PREFIXO=SF2.F2_PREFIXO AND SE1.E1_NUM=SF2.F2_DOC AND SE1.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE SF2.F2_FILIAL='"+cFilSF2+"' AND SF2.F2_DOC='"+VQ9->VQ9_NUMNFI+"' AND SF2.F2_SERIE='"+VQ9->VQ9_SERNFI+"' AND SF2.D_E_L_E_T_=' '"
			RecLock("VQ9",.f.)
				VQ9->VQ9_DATPAG := stod(FM_SQL(cQuery))
			MsUnLock()
		EndIf
	Else
		cQuery := "SELECT SUM(SE1.E1_VALOR) "
		cQuery += "FROM "+cNamSF2+" SF2 "
		cQuery += "JOIN	"+cNamSE1+" SE1 ON ( SE1.E1_FILIAL='"+cFilSE1+"' AND SE1.E1_PREFIXO=SF2.F2_PREFIXO AND SE1.E1_NUM=SF2.F2_DOC AND SE1.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE SF2.F2_FILIAL='"+cFilSF2+"' AND SF2.F2_DOC='"+VQ9->VQ9_NUMNFI+"' AND SF2.F2_SERIE='"+VQ9->VQ9_SERNFI+"' AND SF2.D_E_L_E_T_=' '"
	    If nSaldo <> FM_SQL(cQuery)
			cRet := STR0055 // Parcial
		EndIf
		If !Empty(VQ9->VQ9_DATPAG)
			RecLock("VQ9",.f.)
				VQ9->VQ9_DATPAG := ctod("")
			MsUnLock()
		EndIf
	EndIf
Else
	If !Empty(VQ9->VQ9_DATPAG)
		RecLock("VQ9",.f.)
			VQ9->VQ9_DATPAG := ctod("")
		MsUnLock()
	EndIf
EndIf
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM700CML³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Comissao Liberada na data ?                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM700CML()
Local aComLib   := X3CBOXAVET("VQ9_COMLIB","0")
Local aParamBox := {}
Local aRet      := {}
If !Empty(VQ9->VQ9_NUMNFI+VQ9->VQ9_SERNFI)
	AADD(aParamBox,{2,STR0006,VQ9->VQ9_COMLIB,aComLib,50,"!Empty(MV_PAR01)",.t.}) // Comissao Liberada
	AADD(aParamBox,{1,STR0013,VQ9->VQ9_DATLIB,"@D","","","",50,.f.}) // Dt.Liberacao
	If ParamBox(aParamBox,"",@aRet,,,,,,,,.t.,.t.)
		DbSelectArea("VQ9")
		RecLock("VQ9",.f.)
		VQ9->VQ9_COMLIB := aRet[01] // Comissão Liberada? 1=Sim / 0=Nao
		VQ9->VQ9_DATLIB := aRet[02] // Dt.Liberação
		MsUnLock()
	EndIf
Else
	MsgStop(STR0056,STR0014) // NF/Serie nao gerada! / Atencao
EndIf
Return()            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VCM700CNF³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancelamento da NF ( SF2 / SD2 )                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM700CNF()
Local ni        := 0
Local cNF       := VQ9->VQ9_NUMNFI
Local cSer      := VQ9->VQ9_SERNFI
Local aVQ9      := {}
Local cQuery    := ""
Local cSQLAlias := "SQLALIAS"
Local lVQ9CODVRO := ( VQ9->(ColumnPos("VQ9_CODVRO")) > 0 )
If !Empty(cNF+cSer)
	If MsgYesNo(STR0057+" "+cNF+"-"+cSer+" ?",STR0014) // Confirma o cancelamento da NF: / Atencao

		cQuery := "SELECT VQ9.R_E_C_N_O_ RECVQ9 "
		cQuery += "FROM "+RetSQLName("VQ9")+" VQ9 "
		cQuery += "WHERE VQ9.VQ9_FILIAL='"+xFilial("VQ9")+"' AND "
		cQuery += "VQ9.VQ9_NUMNFI='"+cNF+"' AND VQ9.VQ9_SERNFI='"+cSer+"' AND VQ9.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
		While !(cSQLAlias)->(Eof())
			aAdd(aVQ9,(cSQLAlias)->( RECVQ9 ))
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
		//
		Begin Transaction
		//
		If FMX_EXCNFS(cNF,cSer,.t.)
			For ni := 1 to len(aVQ9)
				DbSelectArea("VQ9")
				DbGoTo(aVQ9[ni])
				RecLock("VQ9",.f.)
					VQ9->VQ9_NUMNFI := ""
					VQ9->VQ9_SERNFI := ""
					If lMenNota // Tem campos de Mensagem de NF
						VQ9->VQ9_MENNOT := ""
						VQ9->VQ9_MENPAD := ""
					EndIf
					If lVQ9CODVRO // Utilizou a Liberacao de Credito
						VQ9->VQ9_CODVRO := ""
					EndIf
				MsUnLock()
				Do Case
					Case VQ9->VQ9_TIPO == "2" // Consorcio
						DbSelectArea("VQ7")
						DbSetOrder(2)
						If DbSeek(xFilial("VQ7")+VQ9->VQ9_CODIGO)
							RecLock("VQ7",.f.)
								VQ7->VQ7_SALDO += VQ9->VQ9_VALCOM
								VQ7->VQ7_GEROUP := "0"
							MsUnLock()
						EndIf
					Case VQ9->VQ9_TIPO == "3" // Seguro
						DbSelectArea("VQ8")
						DbSetOrder(1)
						If DbSeek(xFilial("VQ8")+VQ9->VQ9_CODIGO)
							RecLock("VQ8",.f.)
								VQ8->VQ8_SALDO += VQ9->VQ9_VALCOM
								VQ8->VQ8_GEROUP := "0"
							MsUnLock()
						EndIf

						FS_CANCENDOS(cNF,cSer)

					Case VQ9->VQ9_TIPO == "4" // Servicos Diversos
						DbSelectArea("VQM")
						DbSetOrder(1)
						If DbSeek(xFilial("VQM")+VQ9->VQ9_CODIGO)
							RecLock("VQM",.f.)
								VQM->VQM_SALDO += VQ9->VQ9_VALCOM
								VQM->VQM_GEROUP := "0"
							MsUnLock()
						EndIf
				EndCase
			Next		
		EndIf
		//
		End Transaction
		//
	EndIf
Else
	MsgStop(STR0058,STR0014) // NF/Serie nao gerada! Impossivel cancelar! / Atencao
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida    ³ Data ³ 09/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ MenuDef ( aRotina )                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { { STR0002 , "AxPesqui" , 0 , 1 },; // Pesquisar
                   { STR0003 , "AxVisual" , 0 , 2 },; // Visualizar
                   { STR0004 , "VCM700PAR", 0 , 3 },; // Gerar NF
                   { STR0005 , "VCM700CNF", 0 , 4 },; // Cancelar NF
                   { STR0006 , "VCM700CML", 0 , 4 }}  // Comissão Liberada

If (ExistBlock("VCM700MD")) // Ponto de Entrada para adicionar opções no Menu
	aRotina := ExecBlock("VCM700MD", .f., .f., {aRotina})
EndIf
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_DESVEND³ Autor ³ Thiago				     ³ Data ³ 10/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Nome do Vendedor.								                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DESVEND()
Local lRet := .t.
If Empty(cCodSA3)
	MsgStop(STR0086,STR0014) // Necessario informar campo vendedor! / Atencao
	cNomSA3 := ""
	lRet := .f.	
Else
	dbSelectArea("SA3")
	DbSetOrder(1)
	if DbSeek(xFilial("SA3")+cCodSA3)
		cNomSA3 := SA3->A3_NOME     
	Else
		cNomSA3 := ""
		lRet := .f.	
	Endif
EndIf
oNomSA3:Refresh()
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    FS_ENDOSSO Autor ³ Jose Luis Silveira Filho³ Data ³ 17/01/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula endosso  .						                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_ENDOSSO(nSelecao)

Local cQuery    := ""
Local cSQLAlias := "SQLALIAS"
Local aEndss := {}
Local aObjects  := {} , aPos := {} , aInfo := {}
Local aSizeAut  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nPosic := 0
Local lOkE      := .f.

	cQuery := " SELECT VQF.VQF_CODSEG, VQF.VQF_CODEND, VQF.VQF_OBSERV, VQF.VQF_CODCLI, VQF.VQF_LOJCLI, VQF.VQF_VALOR, VQF.VQF_DATCAD, VQF.R_E_C_N_O_ RECVQF "
	cQuery += " FROM "+RetSQLName("VQF")+" VQF "
	cQuery += " WHERE VQF.VQF_FILIAL='"+xFilial("VQF")+"' AND VQF.VQF_NFENDO = ' ' AND D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
	
	While !(cSQLAlias)->(Eof())
		nPosic :=  aScan(aEndss,{|x| x[3] == (cSQLAlias)->( VQF_CODEND ) })
		if nPosic == 0
			aAdd(aEndss,{ .f. , (cSQLAlias)->( VQF_CODSEG ) ,;
				(cSQLAlias)->( VQF_CODEND ) ,;
				round((cSQLAlias)->( VQF_VALOR ),2) ,;
				(cSQLAlias)->(VQF_OBSERV ) ,;
				Transform(stod((cSQLAlias)->( VQF_DATCAD )),"@D"),;
				(cSQLAlias)->( RECVQF ) })
		endif
			(cSQLAlias)->(dbSkip())
	EndDo
	
(cSQLAlias)->(dbCloseArea())

If len(aEndss) > 0
	if MsgYesNo(STR0106,STR0107)//"Deseja lista-los"//"Identificados Endossos para as parcelas selecionadas"

		DbSelectArea("VQF")
		aObjects := {}
		AAdd( aObjects, { 05, 35 , .T., .F. } )  //Cabecalho
		AAdd( aObjects, {  1, 10, .T. , .T. } )  //list box
		aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
		aPos := MsObjSize (aInfo, aObjects,.F.)
		DEFINE MSDIALOG oListEndos From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] TITLE (STR0098) of oMainWnd PIXEL //"Selecione os Endossos"
		oListEndos:lEscClose := .F.

		@ aPos[1,1]+01,aPos[1,2]+003 TO aPos[1,1]+100,140 LABEL "" OF oListEndos PIXEL
		@ aPos[1,1]+05,aPos[1,2]+009 SAY STR0041 SIZE 100,8 OF oListEndos PIXEL COLOR CLR_BLUE // Total selecao:
		@ aPos[1,1]+03,aPos[1,2]+050 MSGET oValTot VAR nValTot PICTURE "@E 999,999,999.99" SIZE 80,8 OF oListEndos PIXEL COLOR CLR_BLUE WHEN .f.

		@ aPos[1,1]+21,aPos[1,2]+003 TO aPos[1,1]+100,140 LABEL "" OF oListEndos PIXEL
		@ aPos[1,1]+25,aPos[1,2]+009 SAY STR0099 SIZE 100,8 OF oListEndos PIXEL COLOR CLR_BLUE // Total Endosso:
		@ aPos[1,1]+23,aPos[1,2]+050 MSGET oValEnd VAR nValEnd PICTURE "@E 999,999,999.99" SIZE 80,8 OF oListEndos PIXEL COLOR CLR_BLUE WHEN .f.

		@ aPos[2,1],aPos[2,2]+2 LISTBOX oLbEnds FIELDS HEADER "",STR0100,STR0101,STR0102,STR0103,STR0104; // "Codigo Seguro" // "Codigo Endosso" // "Valor Endosso" // "Observação" // "Data Cadastro" //
		 COLSIZES 10,30,40,50,280 SIZE aPos[1,4]-4,aPos[2,3]-aPos[2,1]-10 OF oListEndos PIXEL ON DBLCLICK FS_TKEND(@aEndss,oLbEnds:nAt,oLbEnds:nColPos)
		oLbEnds:SetArray(aEndss)
		oLbEnds:bLine := { || {IIf(aEndss[oLbEnds:nAt,1],oOk,oNo) , aEndss[oLbEnds:nAt,2] , aEndss[oLbEnds:nAt,3], FG_AlinVlrs(Transform(aEndss[oLbEnds:nAt,4],"@E 999,999,999.99")) , aEndss[oLbEnds:nAt,5], Transform(aEndss[oLbEnds:nAt,6],"@D"), aEndss[oLbEnds:nAt,7] }}
		ACTIVATE MSDIALOG oListEndos ON INIT EnchoiceBar(oListEndos,{|| IIf(FS_VALOK(nSelecao),(lOkE:=.t.,oListEndos:End()),.t.)},{ || oListEndos:End()},,)
	Endif
Endif
return aEndss

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ FS_TKEND Autor ³ Jose Luis Silveira Filho    ³ Data ³ 17/01/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tik                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_TKEND(aEndss,nPos,nCol)

If nCol <= 1
	aEndss[nPos,1] := !aEndss[nPos,1]
Else
	nValEnd := aEndss[nPos,4] // Valor
	aEndss[nPos,1] := .t.
EndIf

nValEnd := 0
aEval(aEndss , {|x| nValEnd += IIF( x[1] , x[4] , 0 ) } )
nValEnd := round(nValEnd,2)
oValEnd:Refresh()

Return nValEnd

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ FS_CANCENDOS Autor ³ Jose Luis Silveira Filho³ Data ³ 17/01/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancela Endosso                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_CANCENDOS(cNF,cSer)
Local cQuery    := ""
Local cSQLAlias := "SQLALIAS"
Local ni        := 0
Local aVQF := {}

cQuery := "SELECT VQF.R_E_C_N_O_ RECVQF "
cQuery += "FROM "+RetSQLName("VQF")+" VQF "
cQuery += "WHERE VQF.VQF_FILIAL='"+xFilial("VQF")+"' AND "
cQuery += "VQF.VQF_NFENDO = '"+Alltrim(cNF)+"' AND VQF.VQF_SRENDO = '"+Alltrim(cSer)+"' AND VQF.D_E_L_E_T_=' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
While !(cSQLAlias)->(Eof())
	aAdd(aVQF,(cSQLAlias)->( RECVQF ))
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
//
DbSelectArea("VQF")
DbSetOrder(3)
For ni := 1 to len(aVQF)
	DbSelectArea("VQF")
	DbGoTo(aVQF[ni])
	RecLock("VQF",.f.)
		VQF->VQF_NFENDO := ""
		VQF->VQF_SRENDO := ""
		VQF->VQF_DTUSOE := ctod("  / /  ")
	MsUnLock()
Next

Return