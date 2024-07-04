// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 14     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
	
#include "Protheus.ch"
#include "VEIXX001.CH"
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | VEIXX021   | Autor |  Luis Delorme         | Data | 27/01/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Pedido de Venda de Veiculos                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VEIXX021(xAutoCab,xAutoItens,xAutoCP,nOpc,xOpeMov, xAutoAux,xMostraMsg,cCliFor)
//
Local nCntFor
Local nTamGru := TamSx3("B1_GRUPO")[1]		// Tamanho da variavel de grupo
//
Private lMarcar  := .t.
Private bRefresh := { || .t. } 				// Variavel necessaria ao MAFISREF
Private aIteParc := { { ctod(""),0 } }	// Vetor contendo os titulos a pagar
Private cGruVei  := Left(GetMv("MV_GRUVEI")+space(nTamGru),nTamGru) // Grupo do Veiculo
Private aMemos   := {{"VPN_OBSMEM","VPN_OBSERV"}}
Private lAbortPrint	:= .f.	// Variavel de Aborto de Operacao
Private cOpeMov  := xOpeMov		// Tipo de Operacao de entrada (recebe o valor do parametro)
Private cSerie, cNumero			// Serie e numero da NF quando formulario proprio
Private lMudouNum := .f. 		// Indica se houve mudanca da sequencia de nota fiscal
// Variaveis de integracao
Private lMostraMsg := IIF(xMostraMsg==NIL,.t.,xMostraMsg)
Private aAutoCab     := {} 		// Cabecalho da NF (VPN)
Private aAutoItens   := {}		// Itens da NF (VPO)
Private aAutoIteParc := {}		// Como pagar (SE1)
Private aAutoAux     := {}		// Auxiliar (para retornos de remessa/consignado)
// 'lVX021Auto' indica se todos os vetores de integracao foram preenchidos
Private lVX021Auto := ( xAutoCab<>NIL  .and. xAutoItens<> NIL  .and.;
xAutoCP<>NIL .and. nOpc<>NIL .and. xOpeMov<>NIL )
// VARIAVEIS DE CONTROLE DA TELA (OBJETOS)
Private oFnt1 := TFont():New( "System", , 12 )
Private oFnt2 := TFont():New( "Courier New", , 16,.t. )
Private oFnt3 := TFont():New( "Arial", , 14,.t. )
//
Private cCliForA := cCliFor
Private nOpca := 1
//
Private aNewBot  := {} //Filtro - Foto  / Progresso de Veiculo
Private oOk      := LoadBitmap( GetResources(), "LBTIK" )
Private oNo      := LoadBitmap( GetResources(), "LBNO" )

If !AMIIn(11) .or. !FMX_AMIIn({"VEIXA021"})
    Return()
EndIf

//
If FindFunction("FM_NEWBOT")
	FM_NEWBOT("VX021BOT","aNewBot") // Ponto de Entrada de Manutencao da aNewBot - Definicao de Novos Botoes na EnchoiceBar
	// Exemplo de PE
	// Local aRet := {}
	//	aadd(aRet,{"FILTRO",{|| U_FS_teste1()},"BOTAO1"})
	//	return(aRet)
Endif

//
If cCadastro == NIL
	cCadastro := STR0051
EndIf
// Se for detectado que trata-se de integracao faz os vetores receberemm os parametros
If lVX021Auto
	aAutoItens := xAutoItens
	aAutoCab   := xAutoCab
	aIteParc   := xAutoCP
	aAutoAux   := IIF(xAutoAux==NIL,{},xAutoAux)
EndIf
// Na integracao as variaveis abaixo nao existirao,
// por isso precisamos carrega-las manualmente
INCLUI 	:= nOpc==3
ALTERA 	:= nOpc==4
EXCLUI 	:= nOpc==5
FATURA 	:= nOpc==6
//#############################################################################
//# Chama a tela contendo os dados do veiculo                                 #
//#############################################################################
DBSelectArea("VPN")
lRet := VX021EXEC(alias(),Recno(),nOpc)
//
Return lRet

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Programa  | VX021EXEC  |Autor  | Luis Delorme          | Data | 19/02/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Saida de Veiculos                                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021EXEC(cAlias,nReg,nOpc)
//
Local nCntFor
Local nCntFor2
Local aObjects 	:= {}
Local aObjects1	:= {}
Local aObjects2	:= {}
Local aSizeAut	:= MsAdvSize(.t.)
/*
1 -> Linha inicial area trabalho
2 -> Coluna inicial area trabalho
3 -> Linha final area trabalho
4 -> Coluna final area trabalho
5 -> Coluna final dialog
6 -> Linha final dialog
7 -> Linha inicial dialog
*/
//Local bCampo	  := { |nCPO| Field(nCPO) }
//
// MONTA ESPACAMENTO DAS TELAS
//
// TELA SUPERIOR (ENCHOICE) 	- TAMANHO VERTICAL VARIAVEL
AAdd( aObjects, { 0,	95, .T., .F. } )
// TELA CENTRAL (GETDADOS) 	- TAMANHO VERTICAL FIXO
AAdd( aObjects, { 0,	20, .T., .T. } )
// TELA INFERIOR (FOLDER) 		- TAMANHO VERTICAL FIXO
AAdd( aObjects, { 0,	60, .T., .F. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
// ESPACAMENTO DA TELA DE FOLDER - QUATRO LINHAS DE TAMANHO FIXO + FINAL VARIAVEL
AAdd( aObjects1, { 0, 10, .T., .f. } )
AAdd( aObjects1, { 0, 10, .T., .f. } )
AAdd( aObjects1, { 0, 10, .T., .f. } )
AAdd( aObjects1, { 0, 10, .T., .f. } )
AAdd( aObjects1, { 0, 0, .T., .T. } )
aAbaInt := { 0, 0, aPosObj[3,4]-aPosObj[3,2], aPosObj[3,3]-aPosObj[3,1]-14, 3, 3}
aPosAba1 := MsObjSize( aAbaInt, aObjects1 )
// ESPACAMENTO DA TELA DE CABECALHO - DOZE LINHAS DE TAMANHO FIXO + FINAL VARIAVEL
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 0, .T., .T. } )
aAbaCab := { aPosObj[1,2], aPosObj[1,1], aPosObj[1,4], aPosObj[1,3] , 3, 3 }
aPosAbaCab := MsObjSize( aAbaCab, aObjects2 )
//
// Zera variaveis de controle dos objetos
//
aIteParc := { { ctod(""),0 } }
dDataIni := ctod(" ")
nDias1P  := 0
nParcel  := 0
nInterv  := 0
//##########################################
//# Cria variaveis M->????? da Enchoice    #
//##########################################
dbSelectArea("VPN")
dbSetOrder(1)
//
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VPN")
//
// FILTRA OS CAMPOS DA ENCHOICE DEPENDENDO DO TIPO DE NOTA DE ENTRADA
//
if nOpc==2
	cFiltrVPO := "VPO_NUMPED#"
else
	cFiltrVPO := "VPO_NUMPED#VPO_STATUS#"
endif
If cOpeMov $ "01"
	cFiltrVPNS := " "
EndIf
//
// CAMPOS DE VISUALIZACAO DO FOLDER 1
aOrc := {}
aAdd(aOrc,{'MaFisRet(,"NF_TOTAL")'   ,STR0076,0,"VPN->VPN_VALTOT"}) // Total
aAdd(aOrc,{'MaFisRet(,"NF_VALMERC")' ,STR0069,0,"VPN->VPN_VALMOV"}) // Valor Mercadorias
aAdd(aOrc,{'MaFisRet(,"NF_DESCONTO")',STR0070,0,"VPN->VPN_VALDES"}) // Desconto
aAdd(aOrc,{'MaFisRet(,"NF_DESPESA")' ,STR0072,0,"VPN->VPN_DESACE"}) // Despesa
//
// PONTO DE ENTRADA PARA ALTERACAO DO VETOR aOrc
//
If ExistBlock("VX021MF1")
	ExecBlock("VX021MF1",.f.,.f.)
EndIf
//
aCpoEncS  := {} // ARRAY DE CAMPOS DA ENCHOICE
//
While !Eof().and.(x3_arquivo=="VPN")
	If X3USO(x3_usado).and.cNivel>=x3_nivel .and. !(alltrim(x3_Campo) $ cFiltrVPNS)
		AADD(acpoEncS,x3_campo)
	EndIf
	If Inclui
		&("M->"+x3_campo) := CriaVar(x3_campo)
	Else
		If x3_context == "V"
			&("M->"+x3_campo) := &(X3_RELACAO)
		else
			&("M->"+x3_campo) := &("VPN->"+x3_campo)
		EndIf
	EndIf
	DbSkip()
EndDo
M->VPN_OPEMOV := cOpeMov
//#####################################
//# Cria aHeader e aCols da GetDados  #
//#####################################
nUsadoV := 0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VPO")
aHeaderV := {}
While !Eof().And.(x3_arquivo=="VPO")
	If ( X3USO(x3_usado).And.cNivel>=x3_nivel .and. !alltrim(x3_Campo) $ cFiltrVPO);
		.or. ( alltrim(x3_Campo) == "VPO_CHAINT" )
		nUsadoV:=nUsadoV+1
		Aadd(aHeaderV,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	EndIf
	DbSkip()
EndDo
// ZERA A PILHA FISCAL
MaFisEnd()
//
//  CRIA ACOLS
If INCLUI
	aColsV := { Array(nUsadoV+1) }
	aColsV[1,nUsadoV+1] := .F.
	For nCntFor := 1 to nUsadoV
		aColsV[1,nCntFor]:=CriaVar(aHeaderV[nCntFor,2])
	Next
Else
	If cOpeMov $ "01267" 		// VENDA / SIMULACAO / TRANSFERENCIAS / RETORNO
		MaFisIni(M->VPN_CODCLI,M->VPN_LOJA,'C','N',,;
		MaFisRelImp("VEIXX021",{"VPN","VPA"}))
	ElseIf cOpeMov $ "35" 	//  Remessa / Consignado
		if cCliforA == "C"
			MaFisIni(M->VPN_CODCLI,M->VPN_LOJA,'C','N',,;
			MaFisRelImp("VEIXX021",{"VPN","VPO"}))
		Else
			MaFisIni(M->VPN_CODCLI,M->VPN_LOJA,'F','B',,;
			MaFisRelImp("VEIXX021",{"VPN","VPO"}))
		Endif
	ElseIf cOpeMov $ "4" 	//  Devolucao
		MaFisIni(M->VPN_CODCLI,M->VPN_LOJA,'F','D',,;
		MaFisRelImp("VEIXX021",{"VPN","VPO"}))
	EndIf
	
	aColsV:={}
	aRecsVPO := {}
	cQryAl001 := GetNextAlias()
	cQuery := "SELECT VPO.R_E_C_N_O_ RECVPO FROM "+RetSqlName("VPO")+" VPO, "+RetSqlName("VPN")+" VPN"
	cQuery += " WHERE VPO_FILIAL='"+xFilial("VPO")+"' AND"
	cQuery += " VPN_FILIAL='"+xFilial("VPN")+"' AND"
	cQuery += "	VPO_NUMPED='"+VPN->VPN_NUMPED+"' AND"
	cQuery += "	VPN_NUMPED=VPO_NUMPED AND "
	if FATURA
		cQuery += "	VPO_STATUS='A' AND "
	endif
	cQuery += " VPO.D_E_L_E_T_=' ' AND "
	cQuery += " VPN.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
	//
	while !(cQryAl001)->(eof())
		aAdd(aRecsVPO,(cQryAl001)->(RECVPO))
		(cQryAl001)->(DBSkip())
	enddo
	(cQryAl001)->(dbCloseArea())
	//
	dbSelectArea("VPO")
	dbSetOrder(1)
	//
	for nCntFor2 := 1 to Len(aRecsVPO)
		VPO->(DBGoTo(aRecsVPO[nCntFor2]))
		AADD(aColsV,Array(nUsadoV+1))
		aColsV[Len(aColsV),nUsadoV+1] := .F.
		For nCntFor := 1 to nUsadoV
			aColsV[Len(aColsV),nCntFor] := FieldGet(FieldPos(aHeaderV[nCntFor,2]))
			SX3->(DBSetOrder(2))
			SX3->(DBSeek(aHeaderv[nCntFor,2]))
			If SX3->X3_CONTEXT  <> "V"
				&("M->"+aHeaderV[nCntFor,2]) := FieldGet(FieldPos(aHeaderV[nCntFor,2]))
				aColsv[Len(aColsv),nCntFor] := &("VPO->"+SX3->x3_campo)
			else
				&("M->"+aHeaderV[nCntFor,2]) := aColsv[Len(aColsv),nCntFor]
				aColsv[Len(aColsv),nCntFor] := &(SX3->x3_relacao)
			EndIf
		Next
	next
EndIf
//
If !lVX021Auto
	//####################################################
	//# Monta condicao de pagamento e dados da NF        #
	//####################################################
	If !INCLUI
		VX021LOADPD()
	EndIf
	// FUNCOES DE TECLA
	SETKEY(VK_F4,{||VX021KEYF4()})
	// FUNCOES DE CONTROLE DE EVENTOS DA GETDADOS
	// VERIfICA A LINHA INTEIRA DA ACOLS (CHAMADA NA TROCA ENTRE LINHAS)
	cLinOk  := "VX021LINOK()"
	// VERIfICA CADA UM DOS CAMPOS (CHAMADA NA TROCA ENTRE CAMPOS)
	cFieldOk:= "VX021FIELDOK()"
	// VERIfICA TODA A ACOLS
	cTudoOk	:= "VX021TUDOK()"
	// COPIA VETORES DA ACOLS MONTADA PARA AS VARIAVEIS PADRAO DA ACOLS
	aCols	:= aClone(aColsV)
	aHeader	:= aClone(aHeaderV)
	//
	IF ALTERA .or. FATURA
		for nCntFor := 1 to Len(aColsV)
			n := nCntFor
			FGX_VV1SB1("CHAINT", aColsV[n,FG_POSVAR("VPO_CHAINT")] , /* cMVMIL0010 */ , cGruVei )

			MaFisRef("IT_PRODUTO","VX021",SB1->B1_COD)
			MaFisRef("IT_TES","VX021",aColsV[n,FG_POSVAR("VPO_CODTES")])
			MaFisRef("IT_VALMERC","VX021",aColsV[n,FG_POSVAR("VPO_VALMOV")])
			MaFisRef("IT_QUANT","VX021",1)
			MaFisRef("IT_PRCUNI","VX021",aColsV[n,FG_POSVAR("VPO_VALMOV")])
			MaFisRef("IT_DESCONTO","VX021",aColsV[n,FG_POSVAR("VPO_VALDES")])
			MaFisRef("IT_DESPESA","VX021",aColsV[n,FG_POSVAR("VPO_DESVEI")])
		next
	endif
	n := 1
	aCols	:= aClone(aColsV)
	aHeader	:= aClone(aHeaderV)
	// MONTAGEM DA TELA
	// VARIAVEIS PARA DIVISAO DAS LINHAS NA ABA UM DO FOLDER
	dy5 := (aPosAba1[1,4] - aPosAba1[1,2])/5	// STEP DA POSICAO INICIAL
	sl5 := (aPosAba1[2,4] - aPosAba1[2,2])/5	// LARGURA DA CELULA
	sc5 :=  aPosAba1[2,3] - aPosAba1[2,1]		// COMPRIMENTO DA CELULA
	//#############################################################################
	//# Monta a tela da nota fiscal de entrada enchoice + acols + folders         #
	//#############################################################################
	DEFINE MSDIALOG oDlgVPN ;
	FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] ;
	TITLE OemToAnsi(cCadastro) Of oMainWnd PIXEL //"Documento de Entrada"
	//#############
	//# ENCHOICE  #
	//#############
	dData := ddatabase
	dyc7  := (aPosAbaCab[1,4] - aPosAbaCab[1,2])/7	// STEP DA POSICAO INICIAL
	scc7  := aPosAbaCab[2,3] - aPosAbaCab[2,1]		// COMPRIMENTO DA CELULA
	spc   := 45
	// L I N H A  1
	// FSX_POSCPO("VVF_FORPRO","oSayE11",aPosAbaCab[1,1],aPosAbaCab[1,2],spc,"aCombo")
	// FSX_POSCPO("VVF_DATMOV","oSayE12",aPosAbaCab[1,1],aPosAbaCab[1,2]+2.5*dyc7,spc)
	// FSX_POSCPO("VVF_DATEMI","oSayE13",aPosAbaCab[1,1],aPosAbaCab[1,2]+5*dyc7,spc)
	// L I N H A  2
	If cOpeMov $ "0167"
		FSX_POSCPO("VPN_CODCLI","oSayE21",aPosAbaCab[2,1],aPosAbaCab[2,2],;
		spc,,STR0004,"SA1",,"oDlgVPN")//Cliente
		FSX_POSCPO("VPN_LOJA",	"oSayE22",aPosAbaCab[2,1],aPosAbaCab[2,2]+2.5*dyc7,;
		spc,,,,,"oDlgVPN")
	EndIf
	FSX_POSCPO("VPN_NOMCLI","oSayE23",aPosAbaCab[2,1],aPosAbaCab[2,2]+5*dyc7,;
	spc,,STR0006,,,"oDlgVPN")//Nome
	// L I N H A  3
	FSX_POSCPO("VPN_NUMPED","oSayE33",aPosAbaCab[3,1],aPosAbaCab[3,2]+5*dyc7,spc,,,,,"oDlgVPN")
	// L I N H A  4
	FSX_POSCPO("VPN_CODBCO","oSayE41",aPosAbaCab[4,1],aPosAbaCab[4,2],spc,,,,,"oDlgVPN")
	FSX_POSCPO("VPN_CODAGE","oSayE42",aPosAbaCab[4,1],aPosAbaCab[4,2]+2.5*dyc7,spc,,,,,"oDlgVPN")
	// L I N H A  5
	FSX_POSCPO("VPN_FORPAG","oSayE51",aPosAbaCab[5,1],aPosAbaCab[5,2],spc,,,,,"oDlgVPN")
	FSX_POSCPO("VPN_DESFPG","oSayE52",aPosAbaCab[5,1],aPosAbaCab[5,2]+2.5*dyc7,spc,,,,,"oDlgVPN")
	//	FSX_POSCPO("VPN_NATFIN","oSayE53",aPosAbaCab[5,1],aPosAbaCab[5,2]+5*dyc7,spc)
	// L I N H A  6
	FSX_POSCPO("VPN_CODVEN","oSayE61",aPosAbaCab[6,1],aPosAbaCab[5,2],spc,,,,,"oDlgVPN")
	FSX_POSCPO("VPN_NOMVEN","oSayE62",aPosAbaCab[6,1],aPosAbaCab[5,2]+2.5*dyc7,spc,,,,,"oDlgVPN")
	//TODO:
	// FSX_POSCPO("VVF_NATURE","oSayE63",aPosAbaCab[6,1],aPosAbaCab[5,2]+5*dyc7,spc)
	//
	oSayE71 := TSay():New(aPosAbaCab[7,1],aPosAbaCab[7,2],;
	{|| RetTitle("VPN_OBSERV") },oDlgVPN,,oFnt3,,,,.t.,IIf(X3Obrigat("VPN_OBSMEM"),;
	CLR_HBLUE,CLR_BLACK),,spc,8,,,,)
	@ aPosAbaCab[7,1],aPosAbaCab[7,2]+spc GET oVPNObsMem VAR M->VPN_OBSERV OF oDlgVPN ;
	MEMO SIZE (aPosAbaCab[5,2]+2.5*dyc7)-(aPosAbaCab[7,2]+spc) ,025;
	PIXEL MEMO WHEN INCLUI
	//#############################################################################
	//# GETDADOS                                                                  #
	//#############################################################################
	oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],;
	aPosObj[2,4],nOpc,cLinOK,cTudoOk,"";
	,.t.,,,,,cFieldOk,,,,oDlgVPN)
	oGetDados:oBrowse:bChange := {||  VX021VLIN() }
	//
	oGetDados:oBrowse:bDelete := {|| VX021DLIN(nOpc),oGetDados:oBrowse:Refresh() }
	//#############################################################################
	//# RODAPE                                                                    #
	//#############################################################################
	// A B A  1
	@ aPosObj[3,1],aPosObj[3,2] LISTBOX olBox FIELDS HEADER ;
	OemToAnsi(STR0015), OemToAnsi(STR0014) COLSIZES sl5*2, sl5*2 ;
	SIZE aPosObj[3,4]-aPosObj[3,2], aPosObj[3,3]-aPosObj[3,1];
	OF oDlgVPN PIXEL   //Descricao # valor
	//
	olBox:SetArray(aOrc)
	//
	olBox:bLine := { || {  aOrc[olBox:nAt,2] , ;
	FG_AlinVlrs(Transform(aOrc[olBox:nAt,3],"@E 999,999,999.99")) }}
	// INICIALMENTE APENAS O CABECALHO DA TELA ESTARA HABILITADA QUANDO FOR INCLUSAO
	If INCLUI
		oGetDados:disable()
	EndIf
	//
	ACTIVATE MSDIALOG oDlgVPN          ON INIT EnchoiceBar(oDlgVPN,    {|| If(VX021TUDOK(nOpc),VX021GRV(nOpc),.t.)         },{||nOpca := 0,oDlgVPN:End()                                                        },,aNewBot)
	if nOpca == 0
		RollBackSx8()
	Endif
	//
Else
	//################################################################
	//# Monta Enchoice e GetDados automaticamente para a integracao  #
	//################################################################
	aCols	:= {}
	aHeader	:= aClone(aHeaderV)
	If EnchAuto("VPN",aAutoCab)
		MsGetDAuto(aAutoItens,"VX021LINOK",;
		{|| VX021TUDOK(nOpc).And.VX021GRV(nOpc) },aAutoCab,nOpc)
	EndIf
EndIf
//
SET KEY VK_F4 TO
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |VX021LOADPD | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Traz dados do folder 1 (dados da nf)                         |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021LOADPD()
Local nCntFor
//
set delete off
// INICIALIZA FOLDER 1 (INFORMACOES DA NF)
// COM A MACRO DE VISUALIZACAO (POSICAO 4 DO aOrc)
DBSelectArea("VPN")
DBSetOrder(1)
DBSeek(xFilial("VPN")+VPN->VPN_NUMPED)
for nCntFor := 1 to Len(aOrc)
	aOrc[nCntFor,3] := &(aOrc[nCntFor,4])
next
//
set delete on
//
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |VX021VLDENC | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Rotina de validacao da ENCHOICE                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021VLDENC()
//
Local lForn := .f.
//
// INICIALIZA CODIGO DO FORNECEDOR
If ReadVar() == "M->VPN_CODCLI"
	If !Empty(M->VPN_CODCLI)
		If cOpeMov $ "01267" .or. cCliForA == "C"
			DBSelectArea("SA1")
			DBSetOrder(1)
			If !DbSeek(xFilial("SA1")+M->VPN_CODCLI+Alltrim(SA1->A1_LOJA)).and.;
				!DbSeek(xFilial("SA1")+M->VPN_CODCLI)
				Return .f.
			EndIf
		Else
			DBSelectArea("SA2")
			DBSetOrder(1)
			If !DbSeek(xFilial("SA2")+M->VPN_CODCLI+Alltrim(SA2->A2_LOJA)).and.;
				!DbSeek(xFilial("SA2")+M->VPN_CODCLI)
				Return .f.
			EndIf
		EndIf
		M->VPN_LOJA := IIf(cOpeMov$'01267' .or. cCliForA == "C",SA1->A1_LOJA,SA2->A2_LOJA)
		lForn := .t.
	EndIf
EndIf
// INICIALIZA-SE A FUNCAO FISCAL ASSIM QUE O FORNECEDOR EH ESCOLHIDO
If ReadVar() == "M->VPN_LOJA" .or. lForn
	If Empty(M->VPN_LOJA)
		Return .t.
	EndIf
	If cOpeMov $ "01267" .or. cCliForA == "C"
		DBSelectArea("SA1")
		DBSetOrder(1)
		If !DbSeek(xFilial("SA1")+M->VPN_CODCLI+M->VPN_LOJA)
			Return .f.
		EndIf
	Else
		DBSelectArea("SA2")
		DBSetOrder(1)
		If !DbSeek(xFilial("SA2")+M->VPN_CODCLI+M->VPN_LOJA)
			Return .f.
		EndIf
	EndIf
	M->VPN_NOMCLI := IIf(cOpeMov$'01267' .or. cCliForA == "C",SA1->A1_NOME,SA2->A2_NOME)
	If !MaFisFound('NF')
		If cOpeMov $ "01267" 		// VENDA / SIMULACAO / TRANSFERENCIAS / RETORNO
			MaFisIni(M->VPN_CODCLI,M->VPN_LOJA,'C','N',,;
			MaFisRelImp("VEIXX021",{"VPN","VPA"}))
		ElseIf cOpeMov $ "35" 	//  Remessa / Consignado
			if cCliforA == "C"
				MaFisIni(M->VPN_CODCLI,M->VPN_LOJA,'C','N',,;
				MaFisRelImp("VEIXX021",{"VPN","VPO"}))
			Else
				MaFisIni(M->VPN_CODCLI,M->VPN_LOJA,'F','B',,;
				MaFisRelImp("VEIXX021",{"VPN","VPO"}))
			Endif
		ElseIf cOpeMov $ "4" 	//  Devolucao
			MaFisIni(M->VPN_CODCLI,M->VPN_LOJA,'F','D',,;
			MaFisRelImp("VEIXX021",{"VPN","VPO"}))
		EndIf
		// HABILITA DIGITACAO DOS ITENS CASO A ROTINA NAO SEJA AUTOMATICA
		If !lVX021Auto
			oGetDados:Enable()
		EndIf
	Else
		MaFisRef("NF_CODCLIFOR","VX021",M->VPN_CODCLI)
		MaFisRef("NF_LOJA","VX021",M->VPN_LOJA)
		// CHAMAMOS A FUNCAO FIELDOK CADA VEZ QUE ALGUM
		// CAMPO QUE INTREFIRA NO FISCAL FOR ALTERADO
		VX021RECALC()
	EndIf
	if !Empty(M->VPN_CODAGE)
		FG_Seek("SA6","M->VPN_CODBCO",1,.f.)
		M->VPN_CODAGE := SA6->A6_AGENCIA
	endif
	Return .t.
EndIf
// QUANDO DIGITAR A FORMA DE PAGAMENTO DEVEMOS ATUALIZAR
// O COMO PAGAR CASO A INTEGRACAO FISCAL EXISTA
If ReadVar() == "M->VPN_FORPAG"
	If !MaFisFound('NF')
		Return .t.
	EndIf
EndIf
//
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |VX021CHASSI | Autor | Andre/Manoel          | Data | 19/07/99 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Funcao de Inclusao de Veiculos atraves da Entrada            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021CHASSI()
//
Local nCntFor
//
If Empty(M->VPO_CHASSI)
	Return .f.
EndIf
// TENTA PROCURAR O CHASSI NO CADASTRO
lAchou := FG_POSVEI("M->VPO_CHASSI","VV1->VV1_CHASSI")
If !lAchou
	Return .f.
EndIf
FGX_AMOVVEI(xFilial("VV1"),M->VPO_CHASSI)
// ##########################################################
// # VERIFICA RESTRICOES DE MOVIMENTACAO PARA VALIDAR       #
// # SE O VEICULO PODE REALIZAR A SAIDA                     #
// ##########################################################
////	SE A ULTIMA MOVIMENTACAO FOR DE SAIDA NAO PODEMOS REALIZAR NENHUMA OUTRA SAIDA
If VV1->VV1_ULTMOV == "S"
	DBSelectArea("VV0")
	DBSetOrder(1)
	DBSeek(VV1->VV1_FILSAI+VV1->VV1_NUMTRA)
	cOpeTxt := ""
	Do Case
		Case VV0->VV0_OPEMOV == "0"
			cOpeTxt := STR0016   //VENDA
		Case VV0->VV0_OPEMOV == "2"
			cOpeTxt := STR0017	//TRANSFERENCIA
		Case VV0->VV0_OPEMOV == "3"
			cOpeTxt := STR0018	//REMESSA
		Case VV0->VV0_OPEMOV == "4"
			cOpeTxt := STR0019	//DEVOLUCAO
		Case VV0->VV0_OPEMOV == "5"
			cOpeTxt := STR0020	//CONSIGNACAO
		Case VV0->VV0_OPEMOV == "6"
			cOpeTxt := STR0021	//RETORNO DE REMESSA
		Case VV0->VV0_OPEMOV == "7"
			cOpeTxt := STR0022	//RETORNO DE CONSIGNACAO
	EndCase
	MsgStop(STR0023 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
	STR0024+" "+cOpeTxt+"." + CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0025+": " + VV0->VV0_FILIAL +;
	" "+STR0026+":"+Alltrim(VV0->VV0_NUMNFI)+"-"+Alltrim( FGX_MILSNF("VV0", 2, "VV0_SERNFI") ), STR0027)//Impossivel continuar. ### A ultima movimentacao do veiculo foi uma SAIDA por ### Filial ### NF ### Atencao
	//
	Return .f.
EndIf
// SE A ULTIMA ENTRADA FOR UMA REMESSA/CONSIGNACAO >DE< TERCEIROS NAO REALIZAR
// NENHUMA SAIDA A NAO SER O RETORNO DESSA REMESSA/CONSIGNACAO
DBSelectArea("VVF")
DBSetOrder(1)
DBSeek(VV1->VV1_FILSAI+VV1->VV1_TRACPA)
If VVF->VVF_OPEMOV $ "24"
	If VVF->VVF_OPEMOV == "2"
		cOpeTxt := STR0018	//REMESSA
	Else // VVF->VVF_OPEMOV == "4"
		cOpeTxt := STR0020	//CONSIGNACAO
	EndIf
	// ABAIXO VERIfICAMOS SE TRATA-SE DE UMA MOVIMENTACAO DE
	// SAIDA/ENTRADA PARA REMESSA OU CONSIGNADO (RESPECTIVAMENTE)
	If !((VVF->VVF_OPEMOV == "2" .AND. cOpeMov == "6") .or.;
		(VVF->VVF_OPEMOV == "4" .AND. cOpeMov == "7") )
		MsgStop(STR0023 + CHR(13) + CHR(10) + CHR(13) + CHR(10) +;
		STR0029+" " + cOpeTxt + "." +;
		CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0025+": " + VV0->VV0_FILIAL +;
		" "+STR0026+":"+Alltrim(VVF->VVF_NUMNFI)+"-"+Alltrim( FGX_MILSNF("VVF", 2, "VVF_SERNFI") ),STR0027)//Impossivel continuar ### A ultima movimentacao do veiculo foi uma ENTRADA por ### Filial ### NF ### Atencao
		Return .f.
	EndIf
EndIf
// VERIfICA SE O CHASSI JA FOI DIGITADO EM UMA LINHA ANTERIOR
For nCntFor := 1 to Len(aCols)
	If nCntFor # n .and. aCols[nCntFor,FG_POSVAR("VPO_CHASSI")] == M->VPO_CHASSI
		MsgStop(STR0028)  //Chassi ja digitado
		M->VPO_CHAINT := ""
		aCols[n,FG_POSVAR("VPO_CHAINT")] := ""
		M->VPO_CODTES := ""
		aCols[n,FG_POSVAR("VPO_CODTES")] := ""
		Return .f.
	EndIf
Next
// #######################################################
// # FIM DAS VERIFICACOES DE RESTRICOES DE MOVIMENTACAO  #
// # PARA VALIDAR SE O VEICULO PODE REALIZAR A SAIDA     #
// #######################################################
If cOpeMov $ "067"
	cTipoMov := "N"
ElseIf cOpeMov $ "35"
	cTipoMov := "R"
ElseIf cOpeMov == "2"
	cTipoMov := "T"
ElseIf cOpeMov == "4"
	cTipoMov := "C"
EndIf
//
FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
// SETA VARIAVEL FISCAL
MaFisRef("IT_PRODUTO","VX021",SB1->B1_COD)
//Traz o TES padrao para esta operacao de saida (S) normal (N)
dbSelectArea("VZA")
dbSetOrder(1)
If dbSeek( xFilial("VZA")+"S"+cTipoMov+VV1->VV1_ESTVEI )
	aCols[n,FG_POSVAR("VPO_CODTES")] := VZA->VZA_CODTES
	M->VPO_CODTES := VZA->VZA_CODTES
	MaFisRef("IT_TES","VX021",VZA->VZA_CODTES)
EndIf
// PREENCHE OS CAMPOS LIGADOS AO VEICULO
M->VPO_CHASSI := VV1->VV1_CHASSI
aCols[n,FG_POSVAR("VPO_CHASSI")] := VV1->VV1_CHASSI
M->VPO_CHAINT := VV1->VV1_CHAINT
aCols[n,FG_POSVAR("VPO_CHAINT")] := VV1->VV1_CHAINT
M->VPO_ESTVEI := VV1->VV1_ESTVEI
acols[n,FG_POSVAR("VPO_ESTVEI")] := VV1->VV1_ESTVEI
M->VPO_CODORI := VV1->VV1_CODORI
acols[n,FG_POSVAR("VPO_CODORI")] := VV1->VV1_CODORI
M->VPO_PLAVEI := VV1->VV1_PLAVEI
acols[n,FG_POSVAR("VPO_PLAVEI")] := VV1->VV1_PLAVEI

DBSelectArea("VE1")
DBSeek(xFilial("VE1")+VV1->VV1_CODMAR)
FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
DBSelectArea("VVC")
DBSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI)
//
M->VPO_DESMAR := VE1->VE1_DESMAR
acols[n,FG_POSVAR("VPO_DESMAR")] := M->VPO_DESMAR
M->VPO_DESCOR := VVC->VVC_DESCRI
acols[n,FG_POSVAR("VPO_DESCOR")] := M->VPO_DESCOR
M->VPO_DESMOD := VV2->VV2_DESMOD
acols[n,FG_POSVAR("VPO_DESMOD")] := M->VPO_DESMOD
//
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX021FIELDOK| Autor |  Luis Delorme         | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | FieldOK do aCols - Atualiza os campos com o fiscal.          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021FIELDOK()
Local nCntFor
// A ROTINA ATUALIZA OS CAMPOS DA INTEGRACAO FISCAL
If MaFisFound("IT",n)
	if ReadVar() == "M->VPO_CHASSI"
		If M->VPN_OPEMOV $ "235"	// TRANSFERENCIA
			nValCus := 0
			//
			FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			//
			cQryAlias := GetNextAlias()
			cQuery := "SELECT B2_CM1 FROM "+RetSqlName("SB2")
			cQuery += " WHERE B2_FILIAL='"+xFilial("SB2")+"'"
			cQuery += " AND B2_QATU > 0 "
			cQuery += " AND B2_COD='"+SB1->B1_COD+"'"
			cQuery += " AND D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
			//
			(cQryAlias)->(dbGoTop())
			if !(cQryAlias)->(eof())
				nValCus := (cQryAlias)->(B2_CM1)
			endif
			(cQryAlias)->(dbCloseArea())
			
			MaFisRef("IT_VALMERC","VX021",nValCus)
		endif
	endif
	// PROBLEMA DO TES NA ROTINA AUTOMATICA
	if lVX021Auto
		cTesTemp := MaFisRet(n,"IT_TES")
		if !Empty(M->VPO_CODTES)  .and. Empty(cTesTemp)
			MaFisRef("IT_TES","VX021",M->VPO_CODTES)
		endif
	endif
	M->VPO_CODTES := MaFisRet(n,"IT_TES")
	aCols[n,FG_POSVAR("VPO_CODTES")] := M->VPO_CODTES
	M->VPO_VALMOV := MaFisRet(n,"IT_VALMERC")
	aCols[n,FG_POSVAR("VPO_VALMOV")] := M->VPO_VALMOV
	MaFisRef("IT_QUANT","VX021",1)
	MaFisRef("IT_PRCUNI","VX021",M->VPO_VALMOV)
	M->VPO_VALDES := MaFisRet(n,"IT_DESCONTO")
	aCols[n,FG_POSVAR("VPO_VALDES")] := M->VPO_VALDES
	//	M->VPO_VALFRE := MaFisRet(n,"IT_FRETE")
	//	aCols[n,FG_POSVAR("VPO_VALFRE")] := M->VPO_VALFRE
	M->VPO_DESVEI := MaFisRet(n,"IT_DESPESA")
	aCols[n,FG_POSVAR("VPO_DESVEI")] := M->VPO_DESVEI
	//
	// ATUALIZA O FOLDER 1 (INFORMACOES DA NF)
	//
	for nCntFor := 1 to Len(aOrc)
		aOrc[nCntFor,3] := &(aOrc[nCntFor,1])
	next
	if !lVX021Auto
		olBox:nAt := 1
		olBox:SetArray(aOrc)
		olBox:bLine := { || {  aOrc[olBox:nAt,2],;
		FG_AlinVlrs(Transform(aOrc[olBox:nAt,3],"@E 999,999,999.99")) }}
		olBox:SetFocus()
		olBox:Refresh()
	endif
EndIf
//
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX021LINOK  | Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Calcula Pis e Cofins de Substituicao                         |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021LINOK()
Local nCntFor := 0
// VERIfICA OS CAMPOS OBRIGATORIOS

// pula registros deletados
If aCols[n,len(aHeader)+1]
	Return .t.
EndIf
For nCntFor := 1 to Len(aHeader)
	If X3Obrigat(aHeader[nCntFor,2])  .and. (Empty(aCols[n,nCntFor]))
		Help(" ",1,"OBRIGAT2",,RetTitle(aHeader[nCntFor,2]),4,1)
		Return .f.
	EndIf
Next
// CASO ESTEJA NA ROTINA AUTOMATICA DEVEMOS CHAMAR O FIELDOK
// UMA VEZ PARA INICIALIZAR AS VARIAVEIS FISCAIS
If lVX021Auto
	VX021FIELDOK()
EndIf
//
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX021TUDOK  | Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Validacao do Tudo OK da janela                               |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function VX021TUDOK(nOpc)
Local nCntFor
Local nCnCpo := 0
//
if ExistBlock("VX021TOK")
	If !ExecBlock("VX021TOK",.f.,.f.)
		Return .f.
	Endif
Endif
//
// VERIFICACOES DOS CAMPOS OBRIGATORIOS DA ENCHOICE
if nOpc == 3 .or. nOpc == 4
	For nCntFor := 1 to Len(acpoEncS)
		If X3Obrigat(acpoEncS[nCntFor]) .and. Empty(&("M->"+acpoEncS[nCntFor]))
			Help(" ",1,"OBRIGAT2",,acpoEncS[nCntFor],4,1)
			Return .f.
		EndIf
	Next
	For nCntFor := 1 to Len(aHeader)
		If X3Obrigat(aHeader[nCntFor,2])
			For nCnCpo := 1 to Len(aCols)
				If aCols[n,Len(aCols[n])] == .f.
					if (Empty(aCols[nCnCpo,nCntFor]))
						Help(" ",1,"OBRIGAT2",,RetTitle(aHeader[nCntFor,2]),4,1)
						Return .f.
					Endif
				Endif
			Next
		EndIf
	Next
Endif
If nOpc == 4 .or. nOpc == 2
	Return .t.
EndIf
// SE DER OK NA JANELA DIRETO DO ACOLS NAO PASSA PELO LINOK. CHAMA-SE A FUNCAO AQUI
If !(VX021LINOK()) .and. !lVX021Auto
	Return .f.
EndIf

If !MaFisFound('NF')
	// TRANSFORMAR EM HELP
	HELP(" ",1,"NVAZIO",,STR0030,4,0) //Favor preencher os dados da nota fiscal
	Return .f.
EndIf
//
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX021GRV    |Autor  |  Luis Delorme         | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Gravacao da nota fiscal de saida                             |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021GRV(nOpc)
Local lRet := .f.
Local nCntFor
//
lMsErroAuto := .f.
//
If nOpc == 5
	//#############################################################################
	//# CANCELAMENTO DA NOTA FISCAL                                               #
	//#############################################################################
	lRet := VX021CANCEL()
	If !lRet
		If lMsErroAuto
			MostraErro()
		EndIf
		Return .f.
	EndIf
ElseIf nOpc == 3 .or. nOpc == 6
	//#############################################################################
	//# EMISSAO DA NOTA FISCAL                                                    #
	//#############################################################################
	// SE A ROTINA FISCAL SE PERDEU POR ALGUM MOTIVO O PROCESSO DEVE SER REINICIADO
	If !MaFisFound('NF')
		MsgStop(STR0027+;
		" "+STR0078)
		Return .f.
	EndIf
	//Ponto de Entrada - Antes da gravacao do Atendimento
	If ExistBlock("VX021AGA")
		If !ExecBlock("VX021AGA",.f.,.f.)
			return .f.
		Endif
	Endif
	// Ponto de Entrada Antes da Gravacao da Nota Fiscal
	If ExistBlock("VX021ANF")
		ExecBlock("VX021ANF",.f.,.f.)
	EndIf
	//
	lRet := VX021EMINF(nOpc)
	If !lRet
		If !lVX021Auto
			MostraErro()
		EndIf
		Return .f.
	EndIf
	//
	// Ponto de Entrada Depois da Gravacao da Nota Fiscal
	If ExistBlock("VX021DNF")
		ExecBlock("VX021DNF",.f.,.f.)
	EndIf
elseif nOpc == 4
	//
	DBSelectArea("SX3")
	DBSetOrder(1)
	DBSeek("VPN")
	while SX3->X3_ARQUIVO=="VPN"
		cValid	:= AllTrim(UPPER(SX3->X3_VALID))
		If "MAFISREF"$cValid
			nPosRef := AT('MAFISREF("',cValid) + 10
			cRefCols:=Substr(cValid,nPosRef,AT('","VX021",',cValid)-nPosRef )
			&("M->"+X3_CAMPO):= MaFisRet(,cRefCols)
		EndIf
		DbSkip()
	enddo
	//
	reclock("VPN",.f.)
	FG_GRAVAR("VPN")
	//
	VPN->VPN_FILIAL := xFilial("VPN")
	VPN->VPN_DTHEMI := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo
	VPN->VPN_OPEMOV := cOpeMov
	VPN->VPN_STATUS := "A"
	
	msunlock()
	//
	DBSelectArea("VPO")
	DBSetOrder(1)
	For nCntFor := 1 to len(acols)
		// JANELA DE ABORTO
		If VX021ABORT()
			Return .f.
		EndIf
		n := nCntFor
		// pula registros deletados
		If aCols[nCntFor,len(aHeader)+1]
			if DBSeek(xFilial("VPO")+VPN->VPN_NUMPED+aCols[nCntFor,FG_POSVAR("VPO_CHAINT")])
				reclock("VPO",.f.,.t.)
				DBDelete()
				msunlock()
				dbSelectArea("VV1")
				dbSetOrder(1)
				If dbSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VPO_CHAINT")])//CHAINT
					VV1->(RecLock("VV1",.f.))
					VV1->VV1_RESERV := " "
					VV1->VV1_DTHRES := ""
					VV1->VV1_DTHVAL := ""
					VV1->(MsUnlock())
				EndIf
			endif
			loop
		EndIf
		lGrCodInd := .f.
		//################################################################
		//# Gravacao do VPO                                              #
		//################################################################
		DBSelectArea("VV1")
		DBSetOrder(2)
		If !(DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VPO_CHASSI")]))
			MsgStop(STR0079,STR0036+": VX021E03")
			DisarmTransaction()
			Return .f.
		EndIf
		DBSelectArea("VPO")
		DBSetOrder(1)
		DBSeek(xFilial("VPO")+VPN->VPN_NUMPED+aCols[nCntFor,FG_POSVAR("VPO_CHAINT")])
		RecLock("VPO",!found())
		FG_GRAVAR("VPO",aCols,aHeader,nCntFor)
		VPO->VPO_FILIAL := xFilial("VPO")
		VPO->VPO_NUMPED := VPN->VPN_NUMPED
		VPO->VPO_STATUS := "A"
		MsUnlock()
	next
endif

//
If !lVX021Auto
	oDlgVPN:End()
EndIf
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX021EMINF  | Autor |  Luis Delorme         | Data | 31/07/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |Gravacao e Integracao de Veiculos Normais                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021EMINF(nOpc)
Local aIte := {}
Local aCabNFE :={}
Local nCntFor, nCntFor2, x_
Local i := 0
//
//#######################
//# Gravacao do VV0     #
//#######################
dbSelectArea("VPN")
//M->VPN_NUMPED := GetSxENum("VPN","VPN_NUMPED")
//#############################################################################
//# INICIO DO CONTROLE DE TRANSACAO                                           #
//#############################################################################

if nOpc != 6
	DBSelectArea("SX3")
	DBSetOrder(1)
	DBSeek("VPN")
	while SX3->X3_ARQUIVO=="VPN"
		cValid	:= AllTrim(UPPER(SX3->X3_VALID))
		If "MAFISREF"$cValid
			nPosRef := AT('MAFISREF("',cValid) + 10
			cRefCols:=Substr(cValid,nPosRef,AT('","VX021",',cValid)-nPosRef )
			&("M->"+X3_CAMPO):= MaFisRet(,cRefCols)
		EndIf
		DbSkip()
	enddo
	// DA RECLOCK NA TABELA PARA INCLUIR REGISTRO
	If !RecLock("VPN",.t.)
		Help("  ",1,"REGNLOCK")
		DisarmTransaction()
		Return .f.
	EndIf
	// GRAVA TODOS OS CAMPOS QUE ESTAO NA MEMORIA
	FG_GRAVAR("VPN")
	//
	VPN->VPN_FILIAL := xFilial("VPN")
	VPN->VPN_DTHEMI := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo
	VPN->VPN_OPEMOV := cOpeMov
	
	if INCLUI
		VPN->VPN_STATUS := "A"
	endif
	//
	MSMM(VPN->VPN_OBSMEM,TamSx3("VPN_OBSERV")[1],,&(aMemos[1][2]),1,,,"VPN","VPN_OBSMEM")
	ConfirmSx8()
	MsUnlock()
	//#############################
	//# Fim da Gravacao do VPN    #
	//#############################
	nRecVPN := Recno()
	nSlv    := n			// Salva a variavel n do acols
	aItePv  := {}
	aItemRm := {}
	For nCntFor := 1 to len(acols)
		// JANELA DE ABORTO
		If VX021ABORT()
			Return .f.
		EndIf
		n := nCntFor
		// pula registros deletados
		If aCols[nCntFor,len(aHeader)+1]
			loop
		EndIf
		//
		lGrCodInd := .f.
		//################################################################
		//# Gravacao do VPO                                              #
		//################################################################
		DBSelectArea("VV1")
		DBSetOrder(2)
		If !(DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VPO_CHASSI")]))
			MsgStop(STR0079,STR0036+": VX021E03")
			DisarmTransaction()
			Return .f.
		EndIf
		dbSelectArea("VPO")
		RecLock("VPO",.t.)
		FG_GRAVAR("VPO",aCols,aHeader,nCntFor)
		VPO->VPO_FILIAL := xFilial("VPO")
		VPO->VPO_NUMPED := VPN->VPN_NUMPED
		VPO->VPO_CHAINT := VV1->VV1_CHAINT
		VPO->VPO_STATUS := "A"
		MsUnlock()
		//################################################################
		//# Gravacao do VV1                                              #
		//################################################################
		//
		ddTres := dDatabase + GetNewPar("MV_DDTRES",30)
		DBSelectArea("VV1")
		If cOpeMov $ "02" // VENDA
			// SE FOR VENDA GRAVA O CLIENTE
			reclock("VV1",.f.)
			VV1->VV1_RESERV := "1"
			VV1->VV1_DTHRES := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo
			VV1->VV1_DTHVAL := left(Dtoc(dDtRes),6) + right(Dtoc(dDtRes),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo
			VV1->(MsUnlock())
			msunlock()
		ElseIf cOpemov $ "4" // DEVOLUCAO DE COMPRA
			reclock("VV1",.f.)
			MsUnlock()
		EndIf
	next
endif
//
// inicio da geração
//
aVetCus := {}
lSelecionou := .f.
//
if nOpc == 6
	if MsgYesNo(STR0052,STR0053)
		For nCntFor := 1 to len(acols)
			// pula registros deletados
			If aCols[nCntFor,len(aHeader)+1]
				loop
			EndIf
			aAdd(aVetCus,{.f.,aCols[nCntFor,FG_POSVAR("VPO_CHASSI")] })
		next
		DEFINE MSDIALOG oCusVeic FROM 0,0 TO 250,450 TITLE STR0054 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
		oCusVeic:lEscClose := .F.
		@ 15,3 LISTBOX oLstVei FIELDS HEADER " ",STR0055 COLSIZES ;
		10,50  SIZE 221,109 OF oCusVeic PIXEL ON DBLCLICK (Iif(!Empty(aVetCus[oLstVei:nAt,02]),FS_TIK(@aVetCus,oLstVei:Nat),.t.))
		oLstVei:SetArray(aVetCus)
		oLstVei:bLine := { || { IIf(aVetCus[oLstVei:nAt,01],oOk,oNo),;
		aVetCus[oLstVei:nAt,02]  }}
		oLstVei:bHeaderClick := {|oObj,nCol| If( nCol==1,  FS_TIK( @aVetCus,oLstVei:Nat, .T.) , FS_TIK(@aVetCus,oLstVei:Nat )) , oLstVei:Refresh() }
		ACTIVATE MSDIALOG oCusVeic ON INIT EnchoiceBar(oCusVeic,{|| nOpcao:=1,oCusVeic:End() , .f. },{|| nOpcao:=0,oCusVeic:End() } ) CENTER
		For nCntFor := 1 to len(aVetCus)
			if aVetCus[nCntFor,1] == .t.
				lSelecionou := .t.
			endif
		next
		if lSelecionou == .t.
			//
			lGeraVarias := .f.
			nAchou := 0
			For i := 1 to Len(aVetCus)
				if aVetCus[i,1]
					nAchou += 1
				Endif
			Next
			if nAchou > 1
				if MsgYesNo(STR0056,STR0053)
					lGeraVarias := .t.
				endif
			Endif
			//
			xAutoCab := {}
			xAutoItens := {}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta array de integracao com o VEIXX000                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd(xAutoCab,{"VV0_FILIAL"  ,xFilial("VV0")		,Nil})
			aAdd(xAutoCab,{"VV0_FORPRO"  ,"1"   		 		,Nil})
			aAdd(xAutoCab,{"VV0_CODCLI"  ,VPN->VPN_CODCLI		,Nil})
			aAdd(xAutoCab,{"VV0_LOJA"    ,VPN->VPN_LOJA			,Nil})
			aAdd(xAutoCab,{"VV0_CODBCO"  ,VPN->VPN_CODBCO		,Nil})
			aAdd(xAutoCab,{"VV0_CODAGE"  ,VPN->VPN_CODAGE		,Nil})
			aAdd(xAutoCab,{"VV0_FORPAG"  ,VPN->VPN_FORPAG		,Nil})
			aAdd(xAutoCab,{"VV0_CODVEN"  ,VPN->VPN_CODVEN		,Nil})
			//
			If ExistBlock("VX021ACB")
				ExecBlock("VX021ACB",.f.,.f.)
			EndIf
			//
			for nCntFor := 1 to len(aCols)
				nPos := ascan(aVetCus,{|x| x[2] == aCols[nCntFor,FG_POSVAR("VPO_CHASSI")]})
				if aVetCus[nPos,1] == .f.
					loop
				endif
				DBSelectArea("VV1")
				DBSetOrder(2)
				DBSeek(xFilial("VV1")+VVG->VVG_CHASSI)
				xAutoIt := {}
				aAdd(xAutoIt,{"VVA_FILIAL"  ,xFilial("VVA")		,Nil})
				aAdd(xAutoIt,{"VVA_CHASSI"  ,aCols[nCntFor,FG_POSVAR("VPO_CHASSI")] 	,Nil})
				aAdd(xAutoIt,{"VVA_CODTES"  ,aCols[nCntFor,FG_POSVAR("VPO_CODTES")]		,Nil})
				aAdd(xAutoIt,{"VVA_VALMOV"  ,aCols[nCntFor,FG_POSVAR("VPO_VALMOV")]		,Nil})
				aAdd(xAutoIt,{"VVA_VALDES"  ,aCols[nCntFor,FG_POSVAR("VPO_VALDES")]		,Nil})
				aAdd(xAutoIt,{"VVA_DESVEI"  ,aCols[nCntFor,FG_POSVAR("VPO_DESVEI")]		,Nil})
				//
				aAdd(xAutoItens,xAutoIt)
				if lGeraVarias
					lMsErroAuto := .f.
					If ExistBlock("VX021AIV")
						ExecBlock("VX021AIV",.f.,.f.)
					EndIf
					//
					aColsSav := aClone(aCols)
					aHeaderSav := aClone(aHeader)
					//
					MSExecAuto({|x,y,w,z,k,l| VEIXX001(x,y,w,z,k,l)},xAutoCab,xAutoItens,{},3,"0",NIL )
					//
					aCols := aClone(aColsSav)
					aHeader := aClone(aHeaderSav)
					//
					If lMsErroAuto
						DisarmTransaction()
						MostraErro()
						n := 1
						Return .t.
					EndIf
					xAutoItens := {}
				endif
			next
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chama a integracao com o VEIXX000                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !lGeraVarias
				lMsErroAuto := .f.
				If ExistBlock("VX021AIV")
					ExecBlock("VX021AIV",.f.,.f.)
				EndIf
				//
				aColsSav := aClone(aCols)
				aHeaderSav := aClone(aHeader)
				//
				MSExecAuto({|x,y,w,z,k,l| VEIXX001(x,y,w,z,k,l)},xAutoCab,xAutoItens,{},3,"0",NIL )
				//
				aCols := aClone(aColsSav)
				aHeader := aClone(aHeaderSav)
				//
				If lMsErroAuto
					DisarmTransaction()
					MostraErro()
					n := 1
					Return .t.
				endif
			endif
			//
			for nCntFor := 1 to Len(aCols)
				nPos := ascan(aVetCus,{|x| x[2] == aCols[nCntFor,FG_POSVAR("VPO_CHASSI")]})
				if aVetCus[nPos,1] == .f.
					loop
				endif
				DBSelectArea("VPO")
				DBSetOrder(1)
				DBSeek(xFilial("VPO")+VPN->VPN_NUMPED+aCols[nCntFor,FG_POSVAR("VPO_CHAINT")])
				RecLock("VPO",.f.)
				VPO->VPO_STATUS := "F"
				MsUnlock()
			next
			DBSelectArea("VPO")
			DBSetOrder(1)
			DBSeek(xFilial("VPO")+VPN->VPN_NUMPED)
			lTemFechado := .f.
			lTemAberto := .f.
			while !eof() .and. xFilial("VPO")+VPN->VPN_NUMPED == VPO->VPO_FILIAL + VPO->VPO_NUMPED
				if VPO_STATUS == "F"
					lTemFechado := .t.
				else
					lTemAberto := .t.
				endif
				DBSkip()
			enddo
			if lTemFechado .and. lTemAberto
				cStatus := "P"
			elseif lTemFechado .and. !lTemAberto
				cStatus := "F"
			else
				cStatus := "A"
			endif
			DBSelectArea("VPN")
			reclock("VPN",.f.)
			VPN->VPN_STATUS := cStatus
			msunlock()
			
			//
		EndIf
	endif
endif

n := 1

Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX021CANCEL  | Autor |  Luis Delorme        | Data | 31/07/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |Cancelamento de Nota Fiscal - Veiculos Normais                |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021CANCEL()
Local nCntFor
//
//
// ###############################################
// ATUALIZA O STATUS DO VEICULO                  #
// ###############################################
if VPN->VPN_STATUS $ "FC"
	MsgStop(STR0057,STR0053)
	Return(.f.)
Endif
if VPN->VPN_STATUS == "P"
	MsgStop(STR0058,STR0053)
	Return(.f.)
Endif
For nCntFor := 1 to len(acols)
	n := nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	// ALTERA STATUS DOS VEICULOS
	
	dbSelectArea("VPO")
	dbSetOrder(1)
	dbSeek(xFilial("VPO")+VPN->VPN_NUMPED+aCols[nCntFor,2])
	if VPO->VPO_STATUS == "A"
		if VV1->VV1_RESERV == "1"
			RecLock("VV1",.f.)
			VV1->VV1_RESERV := "0"
			MsUnlock()
		Endif
	Endif
Next
dbSelectArea("VPN")
RecLock("VPN",.f.)
VPN->VPN_STATUS := "C"
MsUnlock()
//
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX021DLIN   | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021DLIN(nOpc)
//
if Len(aCols) == 1
	MsgStop(STR0059)
	Return(.f.)
Endif
if nOpc <> 3 .and. nOpc <> 4
	Return(.f.)
Endif
If aCols[n,Len(aCols[n])]
	aCols[n,Len(aCols[n])] := .f.
Else
	aCols[n,Len(aCols[n])] := .t.
EndIf
MaFisDel(n,aCols[n,Len(aCols[n])])
//
VX021FIELDOK()
//
oGetDados:obrowse:SetFocus()
//
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX021KEYF4  | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Chamada da tecla de atalho <F4>. Executa comandos dependen-  |##
##|          | do do campo selecionado ( ReadVar() ).                       |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021KEYF4()
If ReadVar() == "M->VPO_CHASSI"
	DBSelectArea("VV1")
	DBSetOrder(2)
	If DBSeek(xFilial("VV1")+M->VPO_CHASSI)
		VXA010A("VV1",RecNo(),3)
	EndIf
EndIf
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX021ABORT  | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Janela de aborto. Podera ser chamada apenas dentro de tran-  |##
##|          | sacoes. Exibe uma mensagem e seta o lMsErroAuto para .t.     |##
##|          | caso o usuario tenha optado por abortar a operacao           |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021ABORT()
If lAbortPrint
	If MsgYesNo(STR0049,STR0027)	//Tem certeza que deseja abortar esta operacao ?"###"Atencao
		Help("  ",1,"M160PROABO")
		DisarmTransaction()
		Return .t.
	Else
		lAbortPrint := .F.
	EndIf
EndIf
Return .f.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX021BRWNOME| Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Browse do Nome do Cliente/Fornecedor - Depependendo do tipo  |##
##|          | de operacao a funcao retorna o cliente ou o fornecedor.      |##
##|          | As operacoes de remessa, consignacao e devolucao tomam o     |##
##|          | fornecedor ao inves do cliente. As demais utilizam o cliente |##
##|          | (padrao).                                                    |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021BRWNOME()
Local cAlias  := Alias()
Local nRecSA1 := SA1->(RecNo())
Local nRecSA2 := SA2->(RecNo())
Local cNome
//
If VPN->VPN_OPEMOV $ "345" .and. cCliForA <> "C"
	DBSelectArea("SA2")
	DBSetOrder(1)
	DBSeek(xFilial("SA2")+VPN->VPN_CODCLI+VPN->VPN_LOJA)
	cNome := SA2->A2_NREDUZ
Else
	DBSelectArea("SA1")
	DBSetOrder(1)
	DBSeek(xFilial("SA1")+VPN->VPN_CODCLI+VPN->VPN_LOJA)
	cNome := SA1->A1_NREDUZ
EndIf
//
SA1->(DBGoTo(nRecSA1))
SA1->(DBGoTo(nRecSA2))
//
DBSelectArea(cAlias)
//
Return cNome

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX021RECALC | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Atualiza os campos da Integracao Fiscal                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021RECALC()
Local nCntFor
// A ROTINA ATUALIZA OS CAMPOS DA INTEGRACAO FISCAL
For nCntFor := 1 to len(acols)
	n := nCntFor
	If MaFisFound("IT",n)
		M->VPO_CODTES := MaFisRet(n,"IT_TES")
		aCols[n,FG_POSVAR("VPO_CODTES")] := M->VPO_CODTES
		M->VPO_VALMOV := MaFisRet(n,"IT_VALMERC")
		aCols[n,FG_POSVAR("VPO_VALMOV")] := M->VPO_VALMOV
		MaFisRef("IT_QUANT","VX021",1)
		MaFisRef("IT_PRCUNI","VX021",M->VPO_VALMOV)
		M->VPO_VALDES := MaFisRet(n,"IT_DESCONTO")
		aCols[n,FG_POSVAR("VPO_VALDES")] := M->VPO_VALDES
		if VPO->(FieldPos("VPO_VALFRE")) <> 0
			M->VPO_VALFRE := MaFisRet(n,"IT_FRETE")
			aCols[n,FG_POSVAR("VPO_VALFRE")] := M->VPO_VALFRE
		Endif
		M->VPO_DESVEI := MaFisRet(n,"IT_DESPESA")
		aCols[n,FG_POSVAR("VPO_DESVEI")] := M->VPO_DESVEI
		//
		// ATUALIZA O FOLDER 1 (INFORMACOES DA NF)
		//
		for nCntFor := 1 to Len(aOrc)
			aOrc[nCntFor,3] := &(aOrc[nCntFor,1])
		next
		if !lVX021Auto
			olBox:nAt := 1
			olBox:SetArray(aOrc)
			olBox:bLine := { || {  aOrc[olBox:nAt,2],;
			FG_AlinVlrs(Transform(aOrc[olBox:nAt,3],"@E 999,999,999.99")) }}
			olBox:SetFocus()
			olBox:Refresh()
		endif
		//
		// ATUALIZA COMO PAGAR
		// VX021ATUCP()
		//
	EndIf
	//
next
//
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | VX021VTES  | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Validacao no Campo TES                                       |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021VTES()
Local lRet := .f.
DBSelectArea("SF4")
DBSetOrder(1)
if dbSeek(xFilial("SF4")+M->VPO_CODTES)
	lRet := MaFisRef("IT_TES","VX021",M->VPO_CODTES)
endif
return lRet

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |  VX021VNFE | Autor |  BOBY-Antonio         | Data | 31/08/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Preenchiento automatico de valores trazidos da NF de entrada.|##
##|          | FNC 18966                                                    |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021VNFE()
Local aArea := GetArea()
Local lRet  := .T.
DBSelectArea("VVG")
DBSetOrder(2)
If DBSeek(xFilial("VVG")+aCols[n,FG_POSVAR("VPO_CHAINT")])
	aCols[n,FG_POSVAR("VPO_VALVDA")] := M->VPO_VALVDA:= VVG->VVG_VALUNI
	lRet := .T.
EndIf
RestArea(aArea)
Return lRet

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |  VX021RB1  | Autor |  Luis Delorme         | Data | 12/11/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Funcao para trigeer do tes inteligente (ver sx7)             |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021RB1()
FGX_VV1SB1("CHAINT", M->VPO_CHAINT , /* cMVMIL0010 */ , /* cGruVei */ )
return SB1->B1_COD

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |  FS_TIK    | Autor |  Luis Delorme         | Data | 26/01/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Funcao para trigeer do tes inteligente (ver sx7)             |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_TIK(aVetCus,nLinha, lMarcaTudo)
Local nCntFor
Default lMarcaTudo := .f.
if lMarcaTudo
	lMarcar := !lMarcar
	For nCntFor := 1 to Len(aVetCus)
		aVetCus[nCntFor,1] := lMarcar
	next
	return
endif
If aVetCus[nLinha,1]
	aVetCus[nLinha,1]:= .F.
ElseIf !aVetCus[nLinha,1]
	aVetCus[nLinha,1]:= .T.
EndIf
Return()

/*
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |  VX021VLIN | Autor |  Thiago               | Data | 26/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Funcao para validar a linha 							        |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX021VLIN()
if Empty(aCols[n,1])
	aCols[n,2] := ""
	aCols[n,3] := ""
	aCols[n,4] := ""
	aCols[n,5] := ""
Endif
oGetDados:oBrowse:Refresh()
Return(.t.)