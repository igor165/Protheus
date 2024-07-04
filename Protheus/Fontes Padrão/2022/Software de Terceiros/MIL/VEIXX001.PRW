// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 108    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "VEIXX001.CH"

/////// Operacao (VV0_OPEMOV) ////////////
// 0=Venda
// 1=Simulacao
// 2=Transferencia
// 3=Remessa
// 4=Devolucao
// 5=Consignado                                      
// 6=Ret Remessa
// 7=Ret Consignado
// 8=Venda Futura  
// 9=Baixa           // ATENCAO - Movimento tipo 9 foi criado para a CAOA, mas depois da implantação verificou-se que este tipo de movimentação não existe. Se tratava de uma saida por baixa simples sem nota fiscal. Desta forma, este tipo de movimentação foi removido do fonte
///////////////////////////////////////////

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006248_1"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | VEIXX001   | Autor |  Luis Delorme         | Data | 19/02/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Saida de Veiculos                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VEIXX001(xAutoCab,xAutoItens,xAutoCP,nOpc,xOpeMov,xAutoAux,xMostraMsg,xSX5NumNota,xTIPDOC)

Local nCntFor
Local nTamGru := TamSx3("B1_GRUPO")[1]		// Tamanho da variavel de grupo
//
Private bRefresh := { || .t. } 				// Variavel necessaria ao MAFISREF
Private aIteParc := { { ctod(""),0 } }	// Vetor contendo os titulos a pagar
//
Private cGruVei  := Left(GetMv("MV_GRUVEI")+space(nTamGru),nTamGru) // Grupo do Veiculo
Private cGruFor  := "10" // Grupo de Fórmulas de Sa´da por Transferência

Private oSayE18 
Private oSayE19 
Private oSayE21 
Private oSayE22 
Private oGetE18
Private oGetE19
Private oGetE21
Private oGetE22

Private cUsaGrVA := GetNewPar("MV_MIL0010","0") // O Módulo de Veículos trabalhará com Veículos Agrupados por Modelo no SB1 ? (0=Nao / 1=Sim)
//
Private lAbortPrint	:= .f.	// Variavel de Aborto de Operacao
Private cOpeMov := xOpeMov		// Tipo de Operacao de entrada (recebe o valor do parametro)
Private cSerie, cNumero			// Serie e numero da NF quando formulario proprio
Private lMudouNum := .f. 		// Indica se houve mudanca da sequencia de nota fiscal
// Variaveis de integracao
Private lMostraMsg := IIF(xMostraMsg==NIL,.t.,xMostraMsg)
Private aAutoCab := {} 			// Cabecalho da NF (VV0)
Private aAutoItens := {}		// Itens da NF (VVA)
Private aAutoIteParc := {}		// Como pagar (SE1)
Private aAutoAux := {}			// Auxiliar (para retornos de remessa/consignado)
Private cPrefVEI := GetNewPar("MV_PREFVEI","VEI")
// 'lVX001Auto' indica se todos os vetores de integracao foram preenchidos
Private lVX001Auto := ( xAutoCab<>NIL  .and. xAutoItens<> NIL  .and. xAutoCP<>NIL .and. nOpc<>NIL .and. xOpeMov<>NIL )
// VARIAVEIS DE CONTROLE DA TELA (OBJETOS)
Private aTitulo := {STR0002,STR0003}	// Titulo dos folders    - Dados da Nota Fiscal -Como Pagar
Private oFnt1 := TFont():New( "System", , 12 )
Private oFnt2 := TFont():New( "Courier New", , 16,.t. )
Private oFnt3 := TFont():New( "Arial", , 14,.t. )
// Variaveis do Folder 2 - Como Pagar
Private dDataIni		:= ctod(" ")
Private nDias1P
Private nParcel
Private nInterv
Private n := 1
Private cCliForA := "" //GetNewPar("MV_CLFRRC","")
Private aOrc := {}
Private nRecVV0 := 0
//
Private lAtuFiscal := .t. // Atualiza Fiscal
//
Default xSX5NumNota := {.t.,"",""}
Default xTIPDOC     := "1" // 1=NF / 2=SD3 (Mov.Internas)
//
If xTIPDOC == "2" // SD3 ( Mov.Internas )
	lAtuFiscal := .f. // NAO atualizar Fiscal quando Mov.Internas
EndIf
//
If !AMIIn(11) .or. !FMX_AMIIn({"VEIVC140", "VEIXA004", "VEIXA008", "VEIXA011", "VEIXA012","VEIXA013", "VEIXA014", "VEIXA015", "VEIXA016", "VEIXA017", "VEIXA020", "VEIXA023", "VEIXA025" ,"VEIXX021","VEIXA018","VEIXA030","VEIXA040","VEIVC210","VEIVC260","VEIA080"})
	Return()
EndIf
//
If cCadastro == NIL
	cCadastro := STR0001 //Saida de Veiculos
EndIf
// Se for detectado que trata-se de integracao faz os vetores receberemm os parametros
If lVX001Auto
	aAutoItens := xAutoItens
	aAutoCab   := xAutoCab
	aIteParc := xAutoCP
	aAutoAux 	:= IIF(xAutoAux==NIL,{},xAutoAux)
EndIf
// Na integracao as variaveis abaixo nao existirao,
// por isso precisamos carrega-las manualmente
INCLUI 	:= nOpc==3
ALTERA 	:= nOpc==4
EXCLUI 	:= nOpc==5
//#############################################################################
//# Chama a tela contendo os dados do veiculo                                 #
//#############################################################################
DBSelectArea("VV0")
lRet := VX001EXEC(alias(),Recno(),nOpc,xSX5NumNota,xTIPDOC)
If lRet .and. nRecVV0 > 0
	VV0->(DbGoto(nRecVV0))
EndIf
//
Return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Programa  | VX001EXEC  |Autor  | Luis Delorme          | Data | 19/02/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Saida de Veiculos                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001EXEC(cAlias,nReg,nOpc,xSX5NumNota,xTIPDOC)
Local lRet      := .f.
//
Local nCntFor
Local nCntFor2
Local aObjects 	 := {}
Local aObjects1	 := {}
Local aObjects2	 := {}   
Local nPosCpo    := 0
Local aSizeAut	 := MsAdvSize(.t.)
Local oFilHlp    := DMS_FilialHelper():New()
Local aParamBox  := {}
Local aRet       := {}
Local cMV_PAR01  := ""
Local lMV_FILTRF := GetNewPar("MV_FILTRF", .F.)
Local aCliLjDest	 

Private aCliFor  := X3CBOXAVET("VVF_CLIFOR","0")
Private aIndPre  := X3CBOXAVET("VV0_INDPRE","0")
Private aTipoFre := X3CBOXAVET("VV0_TPFRET","1")
Private cCFWhen  := .t.
//
Default xSX5NumNota := {.t.,"",""}
Default xTIPDOC     := "1" // 1=NF / 2=SD3 (Mov.Internas)

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
AAdd( aObjects, { 0,	140, .T., .F. } )
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
AAdd( aObjects2, { 0, 08, .T., .f. } )
AAdd( aObjects2, { 0, 0, .T., .T. } )
aAbaCab := { aPosObj[1,2], aPosObj[1,1], aPosObj[1,4], aPosObj[1,3] , 3, 3 }
aPosAbaCab := MsObjSize( aAbaCab, aObjects2 )
//
// Zera variaveis de controle dos objetos
//
aIteParc := { { ctod(""),0 } }
dDataIni 	:= ctod(" ")
nDias1P 		:= 0
nParcel 		:= 0
nInterv 		:= 0

//##########################################
//# Cria variaveis M->????? da Enchoice    #
//##########################################
dbSelectArea("VV0")
dbSetOrder(1)
//
// FILTRA OS CAMPOS DA ENCHOICE (VV0) E GETDADOS (VVA) DEPENDENDO DO TIPO DE NOTA DE ENTRADA
//
cFiltrVVA := "VVA_FILIAL#VVA_DESMAR#VVA_DESMOD#VVA_NUMTRA#VVA_DESCOR#"
cFiltrVVA += "VVA_SIMVDA#VVA_PLAVEI#VVA_CMFPGC#VVA_COMPGC#VVA_FILENT#VVA_TRACPA#"
cFiltrVVA += "VVA_CODIND#VVA_FATTOT#VVA_FMFTOT#VVA_VMFMOV#VVA_VMFVDA#VVA_VALCVD#"
cFiltrVVA += "VVA_VMFCVD#VVA_COMCOT#VVA_CMFCOT#VVA_COMCTP#VVA_CMFCTP#VVA_RECTEC#"
cFiltrVVA += "VVA_RMFTEC#VVA_DATRTC#VVA_INPICO#VVA_INPCRT#VVA_INPCBF#VVA_INISRT#"
cFiltrVVA += "VVA_INISBF#VVA_BMFFAB#VVA_DATBFB#VVA_TOTIMP#VVA_TMFIMP#VVA_IMFVEN#"
cFiltrVVA += "VVA_ISSCVD#VVA_IMFCVD#VVA_PMFVEN#VVA_CMFVEN#VVA_ISSRTE#VVA_ISSBFB#"
cFiltrVVA += "VVA_IMFRTE#VVA_IMFBFB#VVA_PISRTE#VVA_PISBFB#VVA_PMFRTE#VVA_PMFBFB#"
cFiltrVVA += "VVA_TOTCUS#VVA_TMFCUS#VVA_VCAVEI#VVA_VMFVEI#VVA_ICMCOM#VVA_IMFCOM#"
cFiltrVVA += "VVA_PISENT#VVA_PMFENT#VVA_COFENT#VVA_CMFENT#VVA_JUREST#VVA_JMFEST#"
cFiltrVVA += "VVA_REDCUS#VVA_RMFCUS#VVA_DATRCU#VVA_ACESSO#VVA_AMFSSO#VVA_VDESCO#"
cFiltrVVA += "VVA_VMFSCO#VVA_LUCBRU#VVA_LMFBRU#VVA_TMFDES#VVA_DMFCLI#VVA_SMFVIA#"
cFiltrVVA += "VVA_VMFASS#VVA_VMFREV#VVA_VMFFRE#VVA_DMFVEI#VVA_RMFVEI#VVA_AMFIMP#"
cFiltrVVA += "VVA_LUCLQ1#VVA_LMFLQ1#VVA_DESFIX#VVA_DMFFIX#VVA_VALIRF#VVA_VMFIRF#"
cFiltrVVA += "VVA_COMVDE#VVA_CMFVDE#VVA_COMGER#VVA_CMFGER#VVA_COMPAT#VVA_CMFPAT#"
cFiltrVVA += "VVA_DSPFIN#VVA_DMFFIN#VVA_LUCLQ2#VVA_LMFLQ2#VVA_EMINVD#VVA_USUARI#"
cFiltrVVA += "VVA_PERDES#VVA_PERCVD#VVA_VRENET#VVA_DATVAL#"
cFiltrVVA += "VVA_BONFAB#VVA_BONCON#VVA_BONREG#VVA_BMFREG#VVA_BMFCON#"
cFiltrVVA += "VVA_VALASS#VVA_VALREV#VVA_UTROCO#VVA_PERDVD#VVA_VALDVD#VVA_RECVEI#"
cFiltrVVA += "VVA_ASSIMP#VVA_BONUS#VVA_REBATE#VVA_ENTMEM#VVA_OBSENT#VVA_DTLIBF#"
cFiltrVVA += "VVA_DTLIBE#VVA_DTESUG#VVA_DTEREA#"
cFiltrVVA += "VVA_DTEPRV#VVA_HREPRV#VVA_FIEPRV#VVA_BOEPRV#VVA_USEPRV#"
cFiltrVVA += "VVA_ITETRA#VVA_CODMAR#VVA_GRUMOD#VVA_MODVEI#VVA_CORVEI#VVA_DATENT#VVA_SEGMOD#"
cFiltrVVA += "VVA_HORVAL#VVA_VALTAB#VVA_DESVEI#VVA_SEGVIA#VVA_VALFRE#"
cFiltrVVA += "VVA_CAMPAN#"
If cOpeMov $ "01234567"
	cFiltrVV0S := "VV0_OPEMOV#VV0_NUMTRA#VV0_VALMOV#VV0_CHASSI#VV0_CLIFTD#VV0_LOJFTD#"
	cFiltrVV0S += "VV0_CATVEN#VV0_TIPVEN#VV0_LOJAAV#VV0_LOJALI#VV0_IMPOST#VV0_VALTOT#"
	cFiltrVV0S += "VV0_TIPMOV#VV0_FCICOD#VV0_GERFIN#VV0_TIPDOC#VV0_CAMPAN#"
EndIf
If !(cPaisLoc == "BRA")
	cFiltrVVA += "VVA_VBAICM#VVA_ALIICM#VVA_PISVEN#VVA_COFVEN#VVA_ALIIPI#VVA_ALIPIC#VVA_ICMVEN#"
endif
//
// CAMPOS DE VISUALIZACAO DO FOLDER 1
//
aOrc := {}
If lAtuFiscal // Atualiza Fiscal
	aAdd(aOrc,{'MaFisRet(,"NF_VALMERC")',STR0069,0,"SF2->F2_VALMERC"})
	aAdd(aOrc,{'MaFisRet(,"NF_DESCONTO")',STR0070,0,"SF2->F2_DESCONT"})
	aAdd(aOrc,{'MaFisRet(,"NF_SEGURO")',STR0071,0,"SF2->F2_SEGURO"})
	aAdd(aOrc,{'MaFisRet(,"NF_DESPESA")',STR0072,0,"SF2->F2_DESPESA"})
	aAdd(aOrc,{'MaFisRet(,"NF_FRETE")',STR0073,0,"SF2->F2_FRETE"})
	If (cPaisLoc == "BRA")
		aAdd(aOrc,{'MaFisRet(,"NF_VALICM")',STR0074,0,"SF2->F2_VALICM"})
		aAdd(aOrc,{'MaFisRet(,"NF_VALSOL")',STR0075,0,"SF2->F2_ICMSRET"})
	endif
	aAdd(aOrc,{'MaFisRet(,"NF_TOTAL")',STR0076,0,"SF2->F2_VALBRUT"})
EndIf
//
// PONTO DE ENTRADA PARA ALTERACAO DOS VETORERS ( aOrc ou aAutoCab )
//
If ExistBlock("VX001MF1")
	ExecBlock("VX001MF1",.f.,.f.)
EndIf
//
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV0")
aCpoEncS := {} // ARRAY DE CAMPOS DA ENCHOICE
While !Eof().and.(x3_arquivo=="VV0")
	If X3USO(x3_usado).and.cNivel>=x3_nivel .and. !(alltrim(x3_Campo) $ cFiltrVV0S)
		AADD(acpoEncS,x3_campo)
	EndIf
	If Inclui
		&("M->"+x3_campo):= CriaVar(x3_campo)
	Else
		If x3_context == "V"
			&("M->"+x3_campo):= &(X3_RELACAO)
		Else
			&("M->"+x3_campo):= &("VV0->"+x3_campo)
		EndIf
	EndIf
	DbSkip()
EndDo
M->VV0_OPEMOV := cOpeMov
//#####################################
//# Cria aHeader e aCols da GetDados  #
//#####################################
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVA")
aHeaderV := {}
nUsadoV  := 0
While !Eof().And.(x3_arquivo=="VVA")
	If ( X3USO(x3_usado).And.cNivel>=x3_nivel .and. !alltrim(x3_Campo) $ cFiltrVVA);
		.or. ( alltrim(x3_Campo) == "VVA_CHAINT" )

		nUsadoV:=nUsadoV+1
		Aadd(aHeaderV,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context } )

	EndIf
	If Inclui
		&("M->"+x3_campo) := CriaVar(x3_campo)
	EndIf
	DbSkip()
EndDo
//  CRIA ACOLS
If INCLUI
	aColsV := { Array(nUsadoV+1) }
	aColsV[1,nUsadoV+1] := .F.
	For nCntFor:=1 to nUsadoV
		aColsV[1,nCntFor]:=CriaVar(aHeaderV[nCntFor,2])
	Next
Else
	aColsV:={}
	aRecsVVA := {}
	cQryAl001 := GetNextAlias()
	cQuery := "SELECT VVA.R_E_C_N_O_ RECVVA FROM "+RetSqlName("VVA")+" VVA, "+RetSqlName("VV0")+" VV0"
	cQuery += " WHERE VVA_FILIAL ='"+xFilial("VVA")+"' AND"
	cQuery += " VV0_FILIAL ='"+xFilial("VV0")+"' AND"
	If VV0->(FieldPos("VV0_TIPDOC")) > 0 .and. VV0->VV0_TIPDOC == "2" // 1 = NF / 2 = Mov.Internas (SD3)
		cQuery += " VV0_NUMTRA ='"+VV0->VV0_NUMTRA+"' AND "
	Else
		cQuery += " VV0_NUMNFI ='"+VV0->VV0_NUMNFI+"' AND VV0_SERNFI ='"+VV0->VV0_SERNFI + "' AND "
	EndIf
	cQuery += " VV0_NUMTRA = VVA_NUMTRA AND "
	cQuery += " VVA.D_E_L_E_T_=' ' AND "
	cQuery += " VV0.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
	//
	while !(cQryAl001)->(eof())
		aAdd(aRecsVVA,(cQryAl001)->(RECVVA))
		(cQryAl001)->(DBSkip())
	enddo
	(cQryAl001)->(dbCloseArea())
	//
	dbSelectArea("VVA")
	dbSetOrder(1)
	//
	for nCntFor2 := 1 to Len(aRecsVVA)
		VVA->(DBGoTo(aRecsVVA[nCntFor2]))
		AADD(aColsV,Array(nUsadoV+1))
		For nCntFor:=1 to nUsadoV
			aColsV[Len(aColsV),nCntFor] := FieldGet(FieldPos(aHeaderV[nCntFor,2]))
			If aHeaderV[nCntFor,2]  <> "V"
				&("M->"+aHeaderV[nCntFor,2]) := FieldGet(FieldPos(aHeaderV[nCntFor,2]))
			EndIf
		Next
		aColsV[Len(aColsV),nUsadoV+1]:=.F.
	next
EndIf
// ZERA A PILHA FISCAL
If lAtuFiscal // Atualiza Fiscal
	MaFisEnd()
EndIf
//

If lMV_FILTRF .and. cOpeMov $ "2"
	aAdd(aParamBox,{1,STR0091,Space(TamSX3("VV0_FILIAL")[1]),"@!","","SM0","",0,.f.})  // Filial Destino
	If ParamBox(aParamBox,"",@aRet,,,,,,,,.T.)
		cMV_PAR01 := aRet[01]
	EndIf
EndIf
//
If !lVX001Auto
	//####################################################
	//# Monta condicao de pagamento e dados da NF        #
	//####################################################
	If !INCLUI
		VX001LOADCP()
		VX001LOADNF()
	EndIf
	// FUNCOES DE TECLA
	SETKEY(VK_F4,{||VX001KEYF4()})
	// FUNCOES DE CONTROLE DE EVENTOS DA GETDADOS
	// VERIfICA A LINHA INTEIRA DA ACOLS (CHAMADA NA TROCA ENTRE LINHAS)
	cLinOk        :="VX001LINOK('"+xTIPDOC+"')"
	// VERIfICA CADA UM DOS CAMPOS (CHAMADA NA TROCA ENTRE CAMPOS)
	cFieldOk      :="VX001FIELDOK()"
	// VERIfICA TODA A ACOLS
	cTudoOk		  :="VX001TUDOK("+strzero(nOpc,1)+",'"+xTIPDOC+"')"
	// COPIA VETORES DA ACOLS MONTADA PARA AS VARIAVEIS PADRAO DA ACOLS
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
	DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE (cCadastro) Of oMainWnd PIXEL //Documento de Saida
	oDlg:lEscClose := .F.
	//#############
	//# ENCHOICE  #
	//#############
	dData := ddatabase
	dyc7 := (aPosAbaCab[1,4] - aPosAbaCab[1,2]) / 7	// STEP DA POSICAO INICIAL
	scc7 := aPosAbaCab[2,3] - aPosAbaCab[2,1]		// COMPRIMENTO DA CELULA
	spc := 45
	// L I N H A  1
	// FSX_POSCPO("VVF_FORPRO","oSayE11",aPosAbaCab[1,1],aPosAbaCab[1,2],spc,"aCombo")
	// FSX_POSCPO("VVF_DATMOV","oSayE12",aPosAbaCab[1,1],aPosAbaCab[1,2]+2.5*dyc7,spc)
	// FSX_POSCPO("VVF_DATEMI","oSayE13",aPosAbaCab[1,1],aPosAbaCab[1,2]+5*dyc7,spc)
	// L I N H A  2

	If nOpc == 3 // Somente INCLUIR
		If cOpeMov $ "02"
			M->VV0_CLIFOR := "C"    
			cCFWhen := .f.
			If lMV_FILTRF .and. !Empty(cMV_PAR01)
				aCliLjDest := oFilHlp:GetCodCli(cMV_PAR01, .T.) //  Busca Codigo e Loja de Cliente da Filial Destino
				M->VV0_CODCLI := aCliLjDest[1]
				M->VV0_LOJA	  := aCliLjDest[2]
			EndIf
		Else
			if cOpeMov $ "4"
				M->VV0_CLIFOR := "F"
			EndIf
			cCFWhen := "(Empty(M->VV0_CODCLI) .or. Empty(M->VV0_LOJA))"
		Endif
	EndIf

	oTSCEnch := TScrollBox():New(oDlg ,aPosObj[1,1] , aPosObj[1,2] , aPosObj[1,3] - aPosObj[1,1], aPosObj[1,4] - aPosObj[1,2], .t. , , .t. )
	nAJLinha := 4 - aPosAbaCab[1,1]
	For nCntFor := 1 to Len(aPosAbaCab)
		aPosAbaCab[nCntFor,1] += nAJLinha
	Next nCntFor
	
	nPosCpo := 1
	FSX_POSCPO("VV0_CLIFOR","oSayE20",aPosAbaCab[nPosCpo,1],aPosAbaCab[2,2],spc,"aCliFor",,,,"oTSCEnch","oGetE20",cCFWhen)
	FSX_POSCPO("VV0_NUMPED","oSayE33",aPosAbaCab[nPosCpo,1],aPosAbaCab[2,2]+5*dyc7,spc,,,,,"oTSCEnch","oGetE33")

	++nPosCpo
	// L I N H A  3
	If ! Empty(M->VV0_CLIFOR)
		cCliForA := M->VV0_CLIFOR
	Endif
	If cOpeMov $ "01"
		FSX_POSCPO("VV0_CODCLI","oSayE21",aPosAbaCab[nPosCpo,1],aPosAbaCab[3,2],spc,,STR0004,"SA1",,"oTSCEnch","oGetE21")//Cliente
		FSX_POSCPO("VV0_LOJA",	"oSayE22",aPosAbaCab[nPosCpo,1],aPosAbaCab[3,2]+2.5*dyc7,spc,,,,"VX001VALCLI()","oTSCEnch","oGetE22")
	ElseIf cOpeMov $ "2" // TRANSFERENCIA
		FSX_POSCPO("VV0_CODCLI","oSayE21",aPosAbaCab[nPosCpo,1],aPosAbaCab[3,2],spc,,STR0004,"A1VXTR","VXA014VALCLI()","oTSCEnch","oGetE21")//Cliente
		FSX_POSCPO("VV0_LOJA",	"oSayE22",aPosAbaCab[nPosCpo,1],aPosAbaCab[3,2]+2.5*dyc7,spc,,,,"VXA014VALCLI() .AND. VX001VALCLI()","oTSCEnch","oGetE22")
	Else
		if nOpc <> 2
			FSX_POSCPO("VV0_CODCLI","oSayE21",aPosAbaCab[nPosCpo,1],aPosAbaCab[3,2],spc,,STR0004,"SA1",,"oTSCEnch","oGetE21")//Cliente
			FSX_POSCPO("VV0_CODCLI","oSayE18",aPosAbaCab[nPosCpo,1],aPosAbaCab[3,2],spc,,STR0005,"SA2",,"oTSCEnch","oGetE21")//Fornecedor
			oSayE18:lVisible := .f.
		Else 
			if cCliForA == "C"
				FSX_POSCPO("VV0_CODCLI","oSayE21",aPosAbaCab[nPosCpo,1],aPosAbaCab[3,2],spc,,STR0004,"SA1",,"oTSCEnch","oGetE21")//Cliente
			Else
				FSX_POSCPO("VV0_CODCLI","oSayE18",aPosAbaCab[nPosCpo,1],aPosAbaCab[3,2],spc,,STR0005,"SA2",,"oTSCEnch","oGetE21")//Fornecedor
			Endif
		Endif	
		FSX_POSCPO("VV0_LOJA",	"oSayE22",aPosAbaCab[nPosCpo,1],aPosAbaCab[3,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE22")
	EndIf
	FSX_POSCPO("VV0_NOMCLI","oSayE23",aPosAbaCab[nPosCpo,1],aPosAbaCab[3,2]+5*dyc7,spc,,STR0006,,,"oTSCEnch","oGetE23")//Nome
	// L I N H A  4
	++nPosCpo
	FSX_POSCPO("VV0_CODBCO","oSayE41",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[4,2],spc,,,,,"oTSCEnch","oGetE41")
	FSX_POSCPO("VV0_CODAGE","oSayE42",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[4,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE42")
	FSX_POSCPO("VV0_INDPRE","oSayE43",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[4,2]+5*dyc7,spc,"aIndPre",,,,"oTSCEnch","oGetE43")
	// L I N H A  5
	++nPosCpo
	FSX_POSCPO("VV0_FORPAG","oSayE51",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[5,2],spc,,,,,"oTSCEnch","oGetE51")
	FSX_POSCPO("VV0_DESFPG","oSayE52",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[5,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE52")
	FSX_POSCPO("VV0_NATFIN","oSayE53",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[5,2]+5*dyc7,spc,,,,,"oTSCEnch","oGetE53")
	// L I N H A  6
	++nPosCpo
	FSX_POSCPO("VV0_CODVEN","oSayE61",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[6,2],spc,,,,,"oTSCEnch","oGetE61")
	FSX_POSCPO("VV0_NOMVEN","oSayE62",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[6,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE62")
	FSX_POSCPO("VV0_CODTRA","oSayE53",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[6,2]+5*dyc7,spc,,,,,"oTSCEnch","oGetE63")
	// L I N H A  7
	++nPosCpo
	FSX_POSCPO("VV0_PESOL", "oSayE71",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[7,2],spc,,,,,"oTSCEnch","oGetE71")
	FSX_POSCPO("VV0_PBRUTO","oSayE72",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[7,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE72")
	FSX_POSCPO("VV0_VOLUME","oSayE73",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[7,2]+5*dyc7,spc,,,,,"oTSCEnch","oGetE73")
	// L I N H A  8
	++nPosCpo
	FSX_POSCPO("VV0_ESPECI","oSayE81",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[8,2],spc,,,,,"oTSCEnch","oGetE81")
	FSX_POSCPO("VV0_VEICUL","oSayE82",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[8,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE82")
	FSX_POSCPO("VV0_SEGURO","oSayE83",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[8,2]+5*dyc7,spc,,,,,"oTSCEnch","oGetE83")
	// L I N H A  9
	++nPosCpo
	FSX_POSCPO("VV0_DESACE","oSayE91",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[9,2],spc,,,,,"oTSCEnch","oGetE91")
	FSX_POSCPO("VV0_VALFRE","oSayE92",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[9,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE92")
	FSX_POSCPO("VV0_TPFRET","oSayE93",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[9,2]+5*dyc7,spc,"aTipoFre",,,,"oTSCEnch","oGetE93")

	
	// L I N H A  10
	++nPosCpo
	If VV0->(FieldPos("VV0_CLIENT")) <> 0
		FSX_POSCPO("VV0_CLIENT","oSayE94",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[10,2],spc,,,,,"oTSCEnch","oGetE94")
		FSX_POSCPO("VV0_LOJENT","oSayE95",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[11,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE95")
	Endif
	FSX_POSCPO("VV0_CODA1U","oSayE96",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[10,2]+5*dyc7,spc,,,,,"oTSCEnch","oGetE96")
	// L I N H A  11
	++nPosCpo
	FSX_POSCPO("VV0_MENPAD","oSayE101",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[10,2],spc,,,,,"oTSCEnch","oGetE101")
	FSX_POSCPO("VV0_MENNOT","oSayE102",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[10,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE102")

	// L I N H A  12
	++nPosCpo
	oSayE101 := TSay():New(aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosCpo,2],	{|| RetTitle("VV0_OBSERV") },oTSCEnch,,oFnt3,,,,.t.,IIf(X3Obrigat("VV0_OBSMEM"),CLR_HBLUE,CLR_BLACK),,spc,8)
	If INCLUI
		@ aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosCpo,2]+spc GET oVV0ObsMem VAR M->VV0_OBSERV OF oTSCEnch MEMO SIZE (aPosAbaCab[5,2]+2.5*dyc7)-(aPosAbaCab[nPosCpo,2]+spc+5),050 	PIXEL MEMO
	Else
		@ aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosCpo,2]+spc GET oVV0ObsMem VAR M->VV0_OBSERV OF oTSCEnch MEMO SIZE (aPosAbaCab[5,2]+2.5*dyc7)-(aPosAbaCab[nPosCpo,2]+spc+5),050 	PIXEL READONLY MEMO
	EndIf
	//
	oSayE102 := TSay():New(aPosAbaCab[nPosCpo,1],aPosAbaCab[10,2]+2.5*dyc7,{|| RetTitle("VV0_OBSENF") },oTSCEnch,,oFnt3,,,,.t.,IIf(X3Obrigat("VV0_OBSMNF"),CLR_HBLUE,CLR_BLACK),,spc,8)
	If INCLUI
		@ aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosCpo,2]+spc+(2.5*dyc7) GET oVV0ObsMem VAR M->VV0_OBSENF OF oTSCEnch MEMO SIZE (aPosAbaCab[5,2]+2.5*dyc7)-(aPosAbaCab[nPosCpo,2]+spc+5),050 PIXEL MEMO
	Else
		@ aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosCpo,2]+spc+(2.5*dyc7) GET oVV0ObsMem VAR M->VV0_OBSENF OF oTSCEnch MEMO SIZE (aPosAbaCab[5,2]+2.5*dyc7)-(aPosAbaCab[nPosCpo,2]+spc+5),050 PIXEL READONLY MEMO
	EndIf

	//#############################################################################
	//# GETDADOS                                                                  #
	//#############################################################################
	oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]*0.95,;
		aPosObj[2,4],nOpc,cLinOK,cTudoOk,"";
		,.t.,,,,,cFieldOk,,,,oDlg)
	//
	oGetDados:oBrowse:bDelete       := {|| VX001DLIN(),oGetDados:oBrowse:Refresh() }
	//
	oFolder := TFolder():New(aPosObj[3,1]*0.95,aPosObj[3,2],aTitulo,{},;
		oDlg,,,,.t.,.f.,aPosObj[3,4] -aPosObj[3,2],(aPosObj[3,3]-aPosObj[3,1])/0.75)
		cChave1 :=cChave2 :=cChave3 :=cChave4 :=""
	//#############################################################################
	//# FOLDER                                                                    #
	//#############################################################################
	// A B A  1
	@ aPosAba1[1,1],aPosAba1[1,2] LISTBOX olBox FIELDS HEADER ;
		OemToAnsi(STR0015), OemToAnsi(STR0014) COLSIZES sl5*2, sl5*2 ;
		SIZE aPosAba1[5,4] - aPosAba1[1,2], (aPosAba1[5,3] - aPosAba1[1,1])/0.65;
		OF oFolder:aDialogs[1] PIXEL   //Descricao # valor
	//
	olBox:SetArray(aOrc)
	//
	olBox:bLine := { || {  aOrc[olBox:nAt,2] , FG_AlinVlrs(Transform(aOrc[olBox:nAt,3],"@E 999,999,999.99")) }}
	// A B A  2
	oSay21 := TSay():New(aPosAba1[1,1],aPosAba1[1,2],{|| STR0007 },oFolder:aDialogs[2],,oFnt1,,,,.t.,CLR_BLUE,,sl5,sc5)//Data Inicial
	oDatIni:= TGet():New(aPosAba1[1,1],aPosAba1[1,2]+dy5,{|u| If(PCount()>0,dDataIni:=u,dDataIni)}, oFolder:aDialogs[2],sl5,sc5,"@D",,,,,,,.T.,,,,,,,,,,"dDataIni")
	//
	oSay22 := TSay():New(aPosAba1[2,1],aPosAba1[2,2],{|| STR0008 },oFolder:aDialogs[2],,oFnt1,,,,.t.,CLR_BLUE,,sl5,sc5)//Dias 1a.Parc
	oDias1P:= TGet():New(aPosAba1[2,1],aPosAba1[2,2]+dy5,{|u| If(PCount()>0,nDias1P:=u,nDias1P)}, oFolder:aDialogs[2],sl5,sc5,"@E 9999",,,,,,,.T.,,,,,,,,,,"nDias1P")
	//
	oSay23 := TSay():New(aPosAba1[3,1],aPosAba1[3,2],{|| STR0009 },oFolder:aDialogs[2],,oFnt1,,,,.t.,CLR_BLUE,,sl5,sc5)//Parcelas
	oParcel:= TGet():New(aPosAba1[3,1],aPosAba1[3,2]+dy5,{|u| If(PCount()>0,nParcel:=u,nParcel)}, oFolder:aDialogs[2],sl5,sc5,"@E 9999",,,,,,,.T.,,,,,,,,,,"nParcel")
	//
	oSay24 := TSay():New(aPosAba1[4,1],aPosAba1[4,2],{|| STR0010 },oFolder:aDialogs[2],,oFnt1,,,,.t.,CLR_BLUE,,sl5,sc5)//Intervalo
	oInterv:= TGet():New(aPosAba1[4,1],aPosAba1[4,2]+dy5,{|u| If(PCount()>0,nInterv:=u,nInterv)}, oFolder:aDialogs[2],sl5,sc5,"@E 9999",,,,,,,.T.,,,,,,,,,,"nInterv")//nInterv
	// BOTOES DO COMO PAGAR
	oBtnCalc:=tButton():New(aPosAba1[1,1],aPosAba1[1,2]+2*dy5,STR0011,oFolder:aDialogs[2],{||VX001CANPAR(1),VX001ATUCP()},sl5,sc5,,,,.T.)//Calcular
	oBtnDesf:=tButton():New(aPosAba1[2,1],aPosAba1[2,2]+2*dy5,STR0012,oFolder:aDialogs[2],{||VX001CANPAR(0)},sl5,sc5,,,,.T.)//Desfazer
	// LISTBOX DO COMO PAGAR
	@ aPosAba1[1,1],aPosAba1[1,2]+3*dy5 LISTBOX oLbParc FIELDS HEADER STR0013,STR0014 COLSIZES 40,50 SIZE 2*dy5 , aPosAba1[5,3]-aPosAba1[1,1] OF oFolder:aDialogs[2] PIXEL ON DBLCLICK VX001ALTFIN(oLbParc:nAt)//Data ### Valor
	//
	oLbParc:SetArray(aIteParc)
	//
	oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
	// INICIALMENTE APENAS O CABECALHO DA TELA ESTARA HABILITADA QUANDO FOR INCLUSAO
	If INCLUI
		oGetDados:disable()
		oFolder:disable()
	Else
		oBtnCalc:disable()
		oBtnDesf:disable()
	EndIf
	oDatIni:disable()
	oDias1P:disable()
	oParcel:disable()
	oInterv:disable()
	//
	ACTIVATE MSDIALOG oDlg  ON INIT EnchoiceBar(oDlg,{|| lRet := IIf(VX001TUDOK(nOpc,xTIPDOC),VX001GRV(nOpc,xSX5NumNota,xTIPDOC),.f.)},{||nOpca:=0,oDlg:End()})
	//
Else
	lRet := .t.
	//################################################################
	//# Monta Enchoice e GetDados automaticamente para a integracao  #
	//################################################################
	aCols	:= {}
	aHeader	:= aClone(aHeaderV)
	If EnchAuto("VV0",aAutoCab)    
		MsGetDAuto(aAutoItens,"VX001LINOK('"+xTIPDOC+"')",	{|| VX001TUDOK(nOpc,xTIPDOC).and.VX001GRV(nOpc,xSX5NumNota,xTIPDOC) },aAutoCab,nOpc)
	EndIf
EndIf
//
SET KEY VK_F4 TO
Return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |VX001LOADNF | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Traz dados do folder 1 (dados da nf)                         |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001LOADNF()
Local nCntFor
If VV0->(FieldPos("VV0_TIPDOC")) > 0 .and. VV0->VV0_TIPDOC == "2" // 1 = NF / 2 = Mov.Internas (SD3)
	Return
EndIf
//
set delete off
// INICIALIZA FOLDER 1 (INFORMACOES DA NF)
// COM A MACRO DE VISUALIZACAO (POSICAO 4 DO aOrc)
DBSelectArea("SF2")
DBSetOrder(1)
DBSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
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
##|Fun‡…o    |VX001LOADCP | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Traz dados do folder 2 (dados do como pagar)                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001LOADCP()
//
aIteParc := {}
//
If VV0->(FieldPos("VV0_TIPDOC")) > 0 .and. VV0->VV0_TIPDOC == "2" // 1 = NF / 2 = Mov.Internas (SD3)
	aAdd(aIteParc,{ ctod(""), 0 })
	Return
EndIf
//
set delete off
DBSelectArea("SF2")
DBSetOrder(1)
If DBSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
	//
	If !Empty(SF2->F2_DUPL)
		cAlSE1 := "SQLSE1"
		cQuery := "SELECT SE1.E1_VENCREA, SE1.E1_VALOR "
		cQuery += "FROM "+RetSqlName("SE1")+" SE1 "
		cQuery += "WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' AND "
		cQuery += "SE1.E1_PREFIXO = '"+SF2->F2_PREFIXO+"' AND "
		cQuery += "SE1.E1_NUM = '"+SF2->F2_DUPL+"' "
		cQuery += IIf(VV0->VV0_SITNFI =="0"," AND SE1.D_E_L_E_T_<>' ' "," AND SE1.D_E_L_E_T_=' ' ")
		cQuery += "ORDER BY SE1.E1_VENCREA"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlSE1, .F., .T. )
		While !( cAlSE1 )->( Eof() )
			aAdd(aIteParc,{ stod( (cAlSE1)->( E1_VENCREA )), (cAlSE1)->( E1_VALOR ) } )
			( cAlSE1 )->( DBSkip() )
		EndDo
		( cAlSE1 )->( dbCloseArea() )
	EndIf
	//
EndIf
set delete on
If Empty(aIteParc)
	aAdd(aIteParc,{ ctod(""), 0 })
EndIf
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |VX001VLDENC | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Rotina de validacao da ENCHOICE                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001VLDENC()
//
Local oCliente  := DMS_Cliente():New()
Local oFornece  := OFFornecedor():New()
Local lForn 	:= .f.
Local lVldCGC 	:= .f. //Transferencia ou Agrega e Desagrega
Local nInd := ASCAN(FWLoadSM0(), {|i| i[1] == cEmpAnt .AND. i[2] == cFilant })
Local cM0Cgc := FWLoadSM0()[nInd][18]

//
If IsInCallStack("VEIXX002") // Retornar .T. quando for Atendimento de Veiculos
	Return .t.
EndIf
//
// INICIALIZA CODIGO DO FORNECEDOR 
If cOpeMov $ "67" .or. FM_PILHA("VEIXA040")
	nnPosCF := ascan(aAutoCab,{|x| x[1] == "VV0_CLIFOR" })
	cCliForA := aAutoCab[nnPosCF,2]        
Endif	

If ReadVar() == "M->VV0_CODCLI"
	lVldCGC 	:= cOpeMov == "2" .or. FM_PILHA("VEIXA040") //Transferencia ou Agrega e Desagrega
	lForn := VX00101_ClienteValido(M->VV0_CODCLI, M->VV0_LOJA, cCliForA, cM0Cgc,lVldCGC)
	If lForn .and. !Empty(M->VV0_CODCLI) .and. !Empty(M->VV0_LOJA)
		If cCliForA == "C"
			If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
				Return .f.
			EndIf
		Else
			If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
				Return .f.
			EndIf
		EndIf
	EndIf
	if Empty(M->VV0_LOJA)
		return lForn // se a loja está em branco retorno e deixo o cara digitar senão deixa entrar abaixo que inicia fiscal etc...
	endif
EndIf

// INICIALIZA-SE A FUNCAO FISCAL ASSIM QUE O FORNECEDOR EH ESCOLHIDO
If ReadVar() == "M->VV0_LOJA" .or. lForn
	If Empty(M->VV0_LOJA)
		Return .t.
	EndIf
	If cCliForA == "C"
		DBSelectArea("SA1")
		DBSetOrder(1)
		If !DbSeek(xFilial("SA1")+M->VV0_CODCLI+M->VV0_LOJA)
			Return .f.
		Else
			If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
				Return .f.
			EndIf
		EndIf
		if Empty(M->VV0_NATFIN)
			if !Empty(GetNewPar("MV_NATVEIS",""))
				M->VV0_NATFIN := Left(GetNewPar("MV_NATVEIS","")+space(20),TamSX3("VV0_NATFIN")[1])
			elseif !Empty(SA1->A1_NATUREZ)
				M->VV0_NATFIN := SA1->A1_NATUREZ
			endif
		endif
	Else
		DBSelectArea("SA2")
		DBSetOrder(1)
		If !DbSeek(xFilial("SA2")+M->VV0_CODCLI+M->VV0_LOJA)
			Return .f.
		Else
			If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
				Return .f.
			EndIf
		EndIf
		if Empty(M->VV0_NATFIN)
			if !Empty(GetNewPar("MV_NATVEIS",""))
				M->VV0_NATFIN := Left(GetNewPar("MV_NATVEIS","")+space(20),TamSX3("VV0_NATFIN")[1])
			elseif !Empty(SA2->A2_NATUREZ)
				M->VV0_NATFIN := SA2->A2_NATUREZ
			endif
		endif
	EndIf
	M->VV0_NOMCLI := IIf(cCliForA == "C",SA1->A1_NOME,SA2->A2_NOME)
	If lAtuFiscal // Atualiza Fiscal
		If !MaFisFound('NF')
			if cCliforA == "C" .and. cOpeMov <> "4"    
				MaFisIni(M->VV0_CODCLI,M->VV0_LOJA,'C','N',, MaFisRelImp("VEIXX001",{"VV0","VVA"}))
			Elseif cCliforA == "F" .and. cOpeMov <> "4" 
				if cOpeMov$"3567"
					MaFisIni(M->VV0_CODCLI,M->VV0_LOJA,'F','B',, MaFisRelImp("VEIXX001",{"VV0","VVA"}))
				Else
					MaFisIni(M->VV0_CODCLI,M->VV0_LOJA,'F','N',, MaFisRelImp("VEIXX001",{"VV0","VVA"}))
				Endif	
			ElseIf cOpeMov $ "4" 	//  Devolucao
				MaFisIni(M->VV0_CODCLI,M->VV0_LOJA,'F','D',, MaFisRelImp("VEIXX001",{"VV0","VVA"}))
			EndIf
			// HABILITA DIGITACAO DOS ITENS CASO A ROTINA NAO SEJA AUTOMATICA
			If !lVX001Auto
				oGetDados:Enable()
				oFolder:Enable()
			EndIf
		Else
			MaFisRef("NF_CODCLIFOR","VX001",M->VV0_CODCLI)
			MaFisRef("NF_LOJA","VX001",M->VV0_LOJA)
			// CHAMAMOS A FUNCAO FIELDOK CADA VEZ QUE ALGUM
			// CAMPO QUE INTREFIRA NO FISCAL FOR ALTERADO
			VX001RECALC()
		EndIf
	EndIf
	if !Empty(M->VV0_CODAGE)
		FG_Seek("SA6","M->VV0_CODBCO",1,.f.)
		M->VV0_CODAGE := SA6->A6_AGENCIA
	endif
	Return .t.
EndIf
// QUANDO DIGITAR A FORMA DE PAGAMENTO DEVEMOS ATUALIZAR
// O COMO PAGAR CASO A INTEGRACAO FISCAL EXISTA
If lAtuFiscal .and. ReadVar() == "M->VV0_FORPAG" // Atualiza Fiscal
	If !MaFisFound('NF')
		Return .t.
	Else
		VX001ATUCP()
	EndIf
EndIf

// SE INFORMAR OS CAMPOS VV0_CLIENT E VV0_LOJENT, DEVE CALCULAR OS IMPOSTOS
// PARA O "CLIENTE ENTREGA"
If ReadVar() == "M->VV0_CLIENT"
	lForn := VX00101_ClienteValido(M->VV0_CLIENT, M->VV0_LOJENT, cCliForA, cM0Cgc,lVldCGC)
	If lForn .and. !Empty(M->VV0_CLIENT) .and. !Empty(M->VV0_LOJENT)
		If cCliForA == "C"
			If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
				Return .f.
			EndIf
		Else
			If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
				Return .f.
			EndIf
		EndIf
	EndIf
	if Empty(M->VV0_LOJENT)
		return lForn // se a loja está em branco retorno e deixo o cara digitar senão deixa entrar abaixo que inicia fiscal etc...
	endif
EndIf

//ATUALIZA IMPOSTOS UTILIZANDO O "CLIENTE ENTREGA" COMO REFERENCIA
If lAtuFiscal .and. ReadVar() == "M->VV0_LOJENT" // Atualiza Fiscal
	If MaFisFound('NF')
		MaFisRef("NF_CODCLIFOR","VX001",M->VV0_CLIENT)
		MaFisRef("NF_LOJA","VX001",M->VV0_LOJENT)

		VX001RECALC()
	EndIf
EndIf


Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |VX001CHASSI | Autor | Andre/Manoel          | Data | 19/07/99 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Funcao de Inclusao de Veiculos atraves da Entrada            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001CHASSI()
Local nCntFor
Local lAtivoImob := .f.
Local oVeiculos  := DMS_Veiculo():New()
//
If Empty(M->VVA_CHASSI)
	Return .f.
EndIf

// TENTA PROCURAR O CHASSI NO CADASTRO
VV1->(DBSetOrder(2))
lAchou := ( VV1->(DBSeek(xFilial("VV1")+M->VVA_CHASSI)) )
If !lAchou
	Return .f.
Else
	// Chassi Bloqueado
	If oVeiculos:Bloqueado("", M->VVA_CHASSI)
		Return .f. // A mensagem já é exibida dentro da função Bloqueado()
	EndIf
EndIf

if VV1->(FieldPos("VV1_IMOBI")) > 0
	lAtivoImob := VV1->VV1_IMOBI == "1"	
Else
	lAtivoImob := VV1->VV1_SITVEI == " "	
Endif

// Verifica se ja houve entrada do Veículo
if !lAtivoImob .and. Empty(VV1->VV1_SITVEI) // não Ativo OU Ativo e não Saída por Venda
	MsgStop(STR0084,STR0027)
	return .f.
endif

FGX_AMOVVEI(xFilial("VV1"),M->VVA_CHASSI)

// ##########################################################
// # VERIFICA RESTRICOES DE MOVIMENTACAO PARA VALIDAR       #
// # SE O VEICULO PODE REALIZAR A SAIDA                     #
// ##########################################################
////	SE A ULTIMA MOVIMENTACAO FOR DE SAIDA NAO PODEMOS REALIZAR NENHUMA OUTRA SAIDA
If VV1->VV1_ULTMOV = "S" .AND. !(FM_PILHA("VEIXA040")) //VEIXA040 = Agrega/Desagrega
	DBSelectArea("VV0")
	DBSetOrder(1)
	DBSeek(VV1->VV1_FILSAI+VV1->VV1_NUMTRA)
	cOpeTxt := ""
	Do Case
		Case VV0->VV0_OPEMOV=="0"
			cOpeTxt := STR0016   //VENDA
		Case VV0->VV0_OPEMOV=="2"
			cOpeTxt := STR0017	//TRANSFERENCIA
		Case VV0->VV0_OPEMOV=="3"
			cOpeTxt := STR0018	//REMESSA
		Case VV0->VV0_OPEMOV=="4"
			cOpeTxt := STR0019	//DEVOLUCAO
		Case VV0->VV0_OPEMOV=="5"
			cOpeTxt := STR0020	//CONSIGNACAO
		Case VV0->VV0_OPEMOV=="6"
			cOpeTxt := STR0021	//RETORNO DE REMESSA
		Case VV0->VV0_OPEMOV=="7"
			cOpeTxt := STR0022	//RETORNO DE CONSIGNACAO
		//Case VV0->VV0_OPEMOV=="9"
		//	cOpeTxt := "BAIXA"
	EndCase
	
	if !(VV0->VV0_OPEMOV == "0" .and. cOpemov == "3") .or. (GetNewPar("MV_MIL0007","1") == "0" .and. cOpemov == "3") // Permitida a Saida por Remessa de Veículos (0=Não permitida;1=Permitida)

		MsgStop(STR0023 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
			STR0024+" "+cOpeTxt+"." + CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0025+": " + VV0->VV0_FILIAL +;
			" "+STR0026+":"+Alltrim(VV0->VV0_NUMNFI)+"-"+Alltrim(VV0->VV0_SERNFI),STR0027)//Impossivel continuar. ### A ultima movimentacao do veiculo foi uma SAIDA por ### Filial ### NF ### Atencao
		//
		Return .f.
	endif
EndIf

// VERIFICA SE A FILIAL EH A MESMA DO VEICULO
if !Empty(VV1->VV1_FILENT) .and. Alltrim(VV1->VV1_FILENT) != Alltrim(cFilAnt)
	MsgStop(STR0083,STR0027)
	return .f.
endif

// SE A ULTIMA ENTRADA FOR UMA REMESSA/CONSIGNACAO >DE< TERCEIROS NAO REALIZAR
// NENHUMA SAIDA A NAO SER O RETORNO DESSA REMESSA/CONSIGNACAO
// EXISTEM CASOS EM QUE EH POSSIVEL REALIZAR UMA SAIDA POR REMESSA PARA OUTRA FILIAL ENTÃO
// É POSSIVEL FAZER SAÍDA POR REMESSA QUANDO A ULTIMA MOVIMENTAÇÃO FOR UMA ENTRADA POR REMESSA
VVF->(DBSetOrder(1))
VVF->(DBSeek(VV1->VV1_FILENT+VV1->VV1_TRACPA))
VV1->(DBSeek(xFilial("VV1")+M->VVA_CHASSI))
If VVF->VVF_OPEMOV $ "24"
	If VVF->VVF_OPEMOV=="2"
		cOpeTxt := STR0018	//REMESSA
	Else // VVF->VVF_OPEMOV=="4"
		cOpeTxt := STR0020	//CONSIGNACAO
	EndIf
	// ABAIXO VERIfICAMOS SE TRATA-SE DE UMA MOVIMENTACAO DE
	// SAIDA/ENTRADA PARA REMESSA OU CONSIGNADO (RESPECTIVAMENTE)
	If !((VVF->VVF_OPEMOV = "2" .AND. cOpeMov $ "36") .or. (VVF->VVF_OPEMOV = "4" .AND. cOpeMov $ "57") )

		MsgStop(STR0023 + CHR(13) + CHR(10) + CHR(13) + CHR(10) +;
			STR0029+" " + cOpeTxt + "." +;
			CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0025+": " + VV0->VV0_FILIAL +;
			" "+STR0026+":"+Alltrim(VVF->VVF_NUMNFI)+"-"+Alltrim(VVF->VVF_SERNFI),STR0027)//Impossivel continuar ### A ultima movimentacao do veiculo foi uma ENTRADA por ### Filial ### NF ### Atencao
		Return .f.
	EndIf
EndIf

// VERIfICA SE O CHASSI JA FOI DIGITADO EM UMA LINHA ANTERIOR
For nCntFor := 1 to Len(aCols)
	If nCntFor # n .and. aCols[nCntFor,FG_POSVAR("VVA_CHASSI")] == M->VVA_CHASSI
		MsgInfo(STR0028)  //Chassi ja digitado
		M->VVA_CHAINT := ""
		aCols[n,FG_POSVAR("VVA_CHAINT")] := ""
		M->VVA_CODTES := ""
		aCols[n,FG_POSVAR("VVA_CODTES")] := ""
		Return .f.
	EndIf
Next

// #######################################################
// # FIM DAS VERIFICACOES DE RESTRICOES DE MOVIMENTACAO  #
// # PARA VALIDAR SE O VEICULO PODE REALIZAR A SAIDA     #
// #######################################################
Do Case
	Case cOpeMov $ "067"
		cTipoMov := "N"
	Case cOpeMov $ "35"
		cTipoMov := "R"
	Case cOpeMov == "2"
		cTipoMov := "T"
	Case cOpeMov == "4"
		cTipoMov := "C"
EndCase
//

FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )

// SETA VARIAVEL FISCAL
If lAtuFiscal // Atualiza Fiscal
	MaFisRef("IT_PRODUTO","VX001",SB1->B1_COD)
EndIf

// PREENCHE OS CAMPOS LIGADOS AO VEICULO
M->VVA_CHASSI := aCols[n,FG_POSVAR("VVA_CHASSI")] := VV1->VV1_CHASSI
M->VVA_CHAINT := aCols[n,FG_POSVAR("VVA_CHAINT")] := VV1->VV1_CHAINT
M->VVA_ESTVEI := acols[n,FG_POSVAR("VVA_ESTVEI")] := VV1->VV1_ESTVEI
M->VVA_CODORI := acols[n,FG_POSVAR("VVA_CODORI")] := VV1->VV1_CODORI
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX001FIELDOK| Autor |  Luis Delorme         | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | FieldOK do aCols - Atualiza os campos com o fiscal.          |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001FIELDOK()
Local nCntFor  
Local ni := 0
Local aUltMov := {}
Local nValMerc   := 0
Local cFormTransf:= GetNewPar("MV_CUSTRFV","")

// Ponto de Entrada para o usuário fazer a validação dos campos.
if ExistBlock("VXX01FOK")
	if !ExecBlock("VXX01FOK",.f.,.f.)
		Return .f.
	Endif
Endif

// A ROTINA ATUALIZA OS CAMPOS DA INTEGRACAO FISCAL
If lAtuFiscal .and. MaFisFound("IT",n) // Atualiza Fiscal
	if lVX001Auto

		MaFisRef("NF_TPFRETE","VX001"," ")   
		MaFisRef("NF_TPFRETE","VX001",M->VV0_TPFRET)

		If M->VV0_OPEMOV == "6" // Saida por Retorno Remessa
			aUltMov := FM_VEIMOVS( M->VVA_CHASSI , "E" , "2" ) // Posiciona na Entrada por Remessa
			If Len(aUltMov) > 0
				VVF->(DbSetOrder(1))
				If VVF->(MsSeek(aUltMov[1,2]+aUltMov[1,3]))
					SD1->(DbSetOrder(1))
					cProdSB1 := MaFisRet(n,"IT_PRODUTO")
					If SD1->(MsSeek(VVF->VVF_FILIAL+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+cProdSB1))
						MaFisRef("IT_NFORI","VX001",SD1->D1_DOC) 
						MaFisRef("IT_SERORI","VX001",SD1->D1_SERIE)
						MaFisRef("IT_BASVEIC","VX001",SD1->D1_TOTAL)
						MaFisRef("IT_BASEICM","VX001",SD1->D1_BASEICM)
					Endif
				EndIf
			Endif
		EndIf

	Endif
		
	if ReadVar() == "M->VVA_CODTES"              
		
		MaFisRef("NF_TPFRETE","VX001"," ")   
		MaFisRef("NF_TPFRETE","VX001",M->VV0_TPFRET)
	
		if !MaAvalTes("S",M->VVA_CODTES)
			return .f.
		endif
	endif
	//
	if ReadVar() == "M->VVA_CHASSI"      
		If (M->VV0_OPEMOV $ "2.3") .and. VV1->VV1_ESTVEI == "1"  //  2-transferencia de usado ; 3-Remessa de usado
			aUltMov := FM_VEIMOVS( M->VVA_CHASSI , "E"  )
			For ni := 1 to Len(aUltMov)                     
				If aUltMov[ni,5] == "0" // Entrada por Compra
					VVF->(DbSetOrder(1))
					If VVF->(MsSeek(aUltMov[ni,2]+aUltMov[ni,3]))
						SD1->(DbSetOrder(1))
						cProdSB1 := MaFisRet(n,"IT_PRODUTO")				
						If SD1->(MsSeek(VVF->VVF_FILIAL+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+cProdSB1))
							MaFisRef("IT_NFORI","VX001",SD1->D1_DOC) 
							MaFisRef("IT_SERORI","VX001",SD1->D1_SERIE)
							If M->VV0_OPEMOV <> "2" // Diferente de Transferencia, pois Transferencia nao pode pegar a Base da Entrada conforme orientação https://tdn.totvs.com/pages/releaseview.action?pageId=567761617
								MaFisRef("IT_BASVEIC","VX001",SD1->D1_TOTAL)
							EndIf
						Endif
					EndIf
					Exit
				Endif
			Next
		Endif
		//                                     
		If M->VV0_OPEMOV == "2"// 2=TRANSFERENCIA
			if !Empty(cFormTransf)
				nValMerc := FG_FORMULA(cFormTransf)
				If VVA->(FieldPos("VVA_FORMUL")) <> 0 //.and. nValMerc > 0
					M->VVA_FORMUL := cFormTransf
					aCols[n,FG_POSVAR("VVA_FORMUL")] := M->VVA_FORMUL
				Endif
			Endif
			If nValMerc == 0
				iF VV1->VV1_ESTVEI == "1"  //  2-transferencia de usado
					nValMerc := MaFisRet(n,"IT_BASVEIC")
				Else
					nValMerc := M->VVA_VALVDA
				Endif
			Endif
			MaFisRef("IT_VALMERC","VX001",nValMerc)
		ElseIf M->VV0_OPEMOV $ "35"	// 3=REMESSA / 5=CONSIGNADO
			nValMerc := 0
			//
			FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			//
			cQryAlias := GetNextAlias()
			cQuery := "SELECT B2_CM1 FROM "+RetSqlName("SB2")
			cQuery += " WHERE B2_FILIAL ='"+xFilial("SB2")+"'"
			cQuery += " AND B2_QATU > 0 "
			cQuery += " AND B2_COD ='"+SB1->B1_COD+"'"
			cQuery += " AND D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
			//
			(cQryAlias)->(dbGoTop())
			if !(cQryAlias)->(eof())
				nValMerc := (cQryAlias)->(B2_CM1)
			endif
			(cQryAlias)->(dbCloseArea())
			//
			MaFisRef("IT_VALMERC","VX001",nValMerc)
			//
		endif
		//
		M->VVA_CENCUS := aCols[n,FG_POSVAR("VVA_CENCUS")] := VV1->VV1_CC
		M->VVA_CONTA  := aCols[n,FG_POSVAR("VVA_CONTA")]  := VV1->VV1_CONTA
		M->VVA_CLVL   := aCols[n,FG_POSVAR("VVA_CLVL")]   := VV1->VV1_CLVL
		M->VVA_ITEMCT := aCols[n,FG_POSVAR("VVA_ITEMCT")] := VV1->VV1_ITEMCC
		
	endif
	//
	If ReadVar() == "M->VVA_VALMOV"
		If M->VV0_OPEMOV == "2"// 2=TRANSFERENCIA
			If VVA->(FieldPos("VVA_FORMUL")) <> 0
				if !Empty(M->VVA_FORMUL)
					If M->VVA_VALMOV <> FG_FORMULA(M->VVA_FORMUL)
						M->VVA_FORMUL := aCols[n,FG_POSVAR("VVA_FORMUL")] := Space(TamSx3("VVA_VALMOV")[1])
					Endif
				Endif
			Endif
		Endif
	Endif
	//
	If ReadVar() == "M->VVA_FORMUL"
		If M->VV0_OPEMOV == "2"// 2=TRANSFERENCIA
			nValMerc := M->VVA_VALMOV := FG_FORMULA(M->VVA_FORMUL)
			MaFisRef("IT_VALMERC","VX001",nValMerc)
		Endif
	Endif
	//
	If ReadVar() == "M->VVA_OPER"
		cTESSai := MaTesInt(2,M->VVA_OPER,M->VV0_CODCLI,M->VV0_LOJA,iif(cCliForA == "C","C","F"),SB1->B1_COD)
		MaFisRef("IT_TES","VX001",cTESSai)
		MaFisRef("NF_TPFRETE","VX001"," ")   
		MaFisRef("NF_TPFRETE","VX001",M->VV0_TPFRET)
	Endif
	// PROBLEMA DO TES NA ROTINA AUTOMATICA
	if lVX001Auto
		cTesTemp := MaFisRet(n,"IT_TES")
		if !Empty(M->VVA_CODTES)  .and. Empty(cTesTemp)
			MaFisRef("IT_TES","VX001",M->VVA_CODTES)
		endif
	endif
	M->VVA_CODTES := aCols[n,FG_POSVAR("VVA_CODTES")] := MaFisRet(n,"IT_TES")
	M->VVA_VALUNI := M->VVA_VALMOV := MaFisRet(n,"IT_VALMERC")
	MaFisRef("IT_QUANT","VX001",1)
	MaFisRef("IT_PRCUNI","VX001",M->VVA_VALMOV)
	aCols[n,FG_POSVAR("VVA_VALMOV")] := M->VVA_VALMOV
	M->VVA_VALDES := aCols[n,FG_POSVAR("VVA_VALDES")] := MaFisRet(n,"IT_DESCONTO")
	If (cPaisLoc == "BRA")
		M->VVA_ALIIPI := acols[n,FG_POSVAR("VVA_ALIIPI")] := MaFisRet(n,"IT_ALIQIPI")
		M->VVA_VBAICM := aCols[n,FG_POSVAR("VVA_VBAICM")] := MaFisRet(n,"IT_BASEICM")
		M->VVA_ALIICM := aCols[n,FG_POSVAR("VVA_ALIICM")] := MaFisRet(n,"IT_ALIQICM")
		M->VVA_ICMVEN := aCols[n,FG_POSVAR("VVA_ICMVEN")] := MaFisRet(n,"IT_VALICM")
		M->VVA_PISVEN := aCols[n,FG_POSVAR("VVA_PISVEN")] := MaFisRet(n,"IT_VALPS3")
		M->VVA_COFVEN := aCols[n,FG_POSVAR("VVA_COFVEN")] := MaFisRet(n,"IT_VALCF3")
	endif
	//
	// ATUALIZA O FOLDER 1 (INFORMACOES DA NF)
	//
	for nCntFor := 1 to Len(aOrc)
		aOrc[nCntFor,3] := &(aOrc[nCntFor,1])
	next
	if !lVX001Auto
		olBox:nAt := 1
		olBox:SetArray(aOrc)
		olBox:bLine := { || {  aOrc[olBox:nAt,2],;
		FG_AlinVlrs(Transform(aOrc[olBox:nAt,3],"@E 999,999,999.99")) }}
		olBox:SetFocus()
		olBox:Refresh()
	endif
	//
	// ATUALIZA COMO PAGAR
	VX001ATUCP()
	//
EndIf
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX001LINOK  | Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Validacao da Linha do aCols                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001LINOK(xTIPDOC)
Local nCntFor   := 0
Local cCposObr  := ""
Default xTIPDOC := "1" // Gerar ? ( 1 = NF / 2 = Mov.Interna (SD3) )
//
if ExistBlock("VXX01LOK")
	if !ExecBlock("VXX01LOK",.f.,.f.)
		Return .f.
	Endif
Endif
//
// pula registros deletados
If aCols[n,len(aHeader)+1]
	Return .t.
EndIf

// Campos Obrigatorios quando NF, mesmo quando nao estao marcados como Obrigatorio no SX3 //
If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	cCposObr := "VVA_CODTES/"
EndIf
For nCntFor:=1 to Len(aHeader)
	If ( aHeader[nCntFor,2] $ cCposObr .or. X3Obrigat(aHeader[nCntFor,2]) ) .and. Empty(aCols[n,nCntFor])
		Help(" ",1,"OBRIGAT2",,RetTitle(aHeader[nCntFor,2]),4,1)
		Return .f.
	EndIf
Next

DBSelectArea("VV1")
DBSetOrder(2)
If DBSeek(xFilial("VV1")+aCols[n,FG_POSVAR("VVA_CHASSI")])
	If VV1->VV1_ULTMOV = "S"
		DBSelectArea("VV0")
		DBSetOrder(1)
		DBSeek(VV1->VV1_FILSAI+VV1->VV1_NUMTRA)
		if VV0->VV0_OPEMOV == "0" .and. cOpemov == "3"
			DBSelectArea("SF4")
			DBSetOrder(1)
			if dbSeek(xFilial("SF4")+aCols[n,FG_POSVAR("VVA_CODTES")])
				if SF4->F4_ESTOQUE == "S"
					MsgStop(STR0060,STR0061)
					return .f.
				endif
			endif
		endif
	endif
	If !VX001VLDESTQ( n , .t. ) // Validar Estoque quando o TES movimentar Estoque
		Return .f.
	EndIf
EndIf

// CASO ESTEJA NA ROTINA AUTOMATICA DEVEMOS CHAMAR O FIELDOK
// UMA VEZ PARA INICIALIZAR AS VARIAVEIS FISCAIS
If lVX001Auto
	VX001FIELDOK()
EndIf
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX001TUDOK  | Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Verificacao Final                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function VX001TUDOK(nOpc,xTIPDOC)
Local nCntFor   := 0
Local cCposObr  := ""
Local oVeiculos := DMS_Veiculo():New()
Default xTIPDOC := "1" // Gerar ? ( 1 = NF / 2 = Mov.Interna (SD3) )

If nOpc == 4 .or. nOpc == 2 .or. nOpc == 5
	Return .t.
EndIf

If xTIPDOC == "2" // 2 = Mov.Interna (SD3)
	Return .t.
EndIf
//
if ExistBlock("VXX01TOK")
	if !ExecBlock("VXX01TOK",.f.,.f.)
		Return .f.
	Endif
Endif
//
// SE DER OK NA JANELA DIRETO DO ACOLS NAO PASSA PELO LINOK. CHAMA-SE A FUNCAO AQUI
If !VX001LINOK(xTIPDOC) .and. !lVX001Auto
	Return .f.
EndIf
//
// Campos Obrigatorios quando NF, mesmo quando nao estao marcados como Obrigatorio no SX3 //
If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	cCposObr := "VV0_CODVEN/VV0_FORPAG/"
EndIf
// VERIFICACOES DOS CAMPOS OBRIGATORIOS DA ENCHOICE
For nCntFor:=1 to Len(acpoEncS)
	If ( acpoEncS[nCntFor] $ cCposObr .or. X3Obrigat(acpoEncS[nCntFor]) ) .and. Empty(&("M->"+acpoEncS[nCntFor]))
		Help(" ",1,"OBRIGAT2",,acpoEncS[nCntFor],4,1)
		Return .f.
	EndIf
Next
// Validar ESTOQUE de TODAS as linhas da aCols
If !VX001VLDESTQ( 0 , .t. ) // Validar Estoque quando o TES movimentar Estoque
	Return .f.
EndIf
// VERIfICACOES DE COMO PAGAR
nValor := 0
For nCntFor := 1 to Len(aIteParc)
	nValor += aIteParc[nCntFor,2]
Next
If lAtuFiscal // Atualiza Fiscal
	If !MaFisFound('NF')
		// TRANSFORMAR EM HELP
		HELP(" ",1,"NVAZIO",,STR0030,4,0) //Favor preencher os dados da nota fiscal
		Return .f.
	EndIf
	If nValor # MaFisRet(,"NF_BASEDUP") 
		if !M->VV0_OPEMOV$"467"
			// TRANSFORMAR EM HELP
			HELP(" ",1,"NVAZIO",,STR0031,4,0) //Valor dos tutulos diverge do valor da nota fiscal
			Return .f.
		Else                            
			nValor := MaFisRet(,"NF_BASEDUP") 
		Endif
	EndIf
EndIf

// Validar Data da Movimentacao de cada Veiculo
For nCntFor := 1 to len(acols)
	If !aCols[nCntFor,len(aHeader)+1]
		If oVeiculos:DtUltimaMovimentacao(aCols[nCntFor,FG_POSVAR("VVA_CHASSI")]) > M->VV0_DATMOV // Valida referente a Data do Movimento
			FMX_HELP("VX001TUDOK",STR0090 + CRLF + CRLF + aCols[nCntFor,FG_POSVAR("VVA_CHASSI")] ) // Chassi com movimentacao posterior a data deste movimento.
			Return .f.
		EndIf
	EndIf	
next

// COMPATIBILIZAÇÃO COM O VEIVM030
if ExistBlock("VM030ANF") .and. M->VV0_OPEMOV$"57"
	if !ExecBlock("VM030ANF",.f.,.f.)
		Return(.f.)
	Endif
Endif
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX001ALTFIN  |Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Permite alteracao das datas dos titulos                      |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001ALTFIN(nCel)
//
Local nOpca := 0
Local nPar1  := nPar2  := nPar3  := 0
Local nSoma1 := nSoma2 := nSoma3 := 0
Local dNovaData := aIteParc[nCel,1]
Local nNovoValor:= aIteParc[nCel,2]
Local valorMax := 0
Local nCntFor
//
DBSelectArea("SE4")
DBSetOrder(1)
DBSeek(xFilial("SE4")+M->VV0_FORPAG)
//
For nCntFor :=1 to Len(aIteParc)
	nSoma1 += aIteParc[nCntFor,2]
Next
//
For nCntFor := 1 to nCel - 1
	valorMax += aIteParc[nCntFor,2]
Next
//
valorMax := nSoma1 - valorMax - (Len(aIteParc)-nCel)
//
If Empty(dNovaData) .and. (nNovoValor = 0)
	Return
EndIf

DEFINE MSDIALOG oDlgFin TITLE STR0009 From 18,43 to 25,76 of oMainWnd //Parcelas

@ 010, 025 SAY STR0013 SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_BLUE//data
@ 010, 048 MSGET oNovaData  VAR dNovaData  PICTURE "@D" VALID !EMPTY(dNovaData) ;
SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_HBLUE WHEN (Alltrim(SE4->E4_TIPO)=="A")
@ 021, 025 SAY   STR0014 SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_BLUE //valor
@ 021, 048 MSGET oNovoValor VAR nNovoValor PICTURE "@E 999,999,999.99" ;
VALID (nNovoValor > 0 .AND. nNovoValor<=valorMax )  SIZE 58,08 OF oDlgFin ;
PIXEL COLOR CLR_HBLUE WHEN (nCel # Len(aIteParc).and.Alltrim(SE4->E4_TIPO)=="A")
//
DEFINE SBUTTON FROM 38,60 TYPE 1 ACTION (nOpca := 1,oDlgFin:End()) ENABLE OF oDlgFin 
DEFINE SBUTTON FROM 38,95 TYPE 2 ACTION (nOpca := 2,oDlgFin:End()) ENABLE OF oDlgFin 
ACTIVATE MSDIALOG oDlgFin CENTER

If nOpca == 1
	aIteParc[nCel,1] := dNovaData
	aIteParc[nCel,2] := nNovoValor
	For nCntFor:=1 to nCel
		nSoma2 := nSoma2 + aIteParc[nCntFor,2]
	Next
	nPar1:= (Len(aIteParc)-nCel)
	nSoma3 := Round( (nSoma1 - nSoma2) / nPar1 ,2)
	nResto := nSoma2
	For nCntFor:=nCel+1 to Len(aIteParc)
		nResto += nSoma3
		aIteParc[nCntFor,2] := nSoma3
	Next
	nResto := nSoma1 - nResto
	If nCel+1 <= Len(aIteParc)
		aIteParc[nCel+1,2] += nResto
	EndIf
	//
	oLbParc:Refresh()
EndIf
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX001ATUCP  |Autor  |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Atualiza como pagar                                          |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001ATUCP()
//
DBSelectArea("SE4")
DBSetOrder(1)
DBSeek(xFilial("SE4")+M->VV0_FORPAG)
//
If lAtuFiscal // Atualiza Fiscal
	If lVX001Auto
		If Alltrim(SE4->E4_TIPO) # "A"
			aIteParc := Condicao(MaFisRet(,"NF_BASEDUP"),M->VV0_FORPAG,,M->VV0_DATEMI)
		EndIf
		//
		Return
	EndIf
	If Alltrim(SE4->E4_TIPO) # "A"
		dDataIni := ctod(" ")
		nDias1P := 0
		nParcel := 0
		nInterv := 0
		aIteParc := Condicao(MaFisRet(,"NF_BASEDUP"),M->VV0_FORPAG,,M->VV0_DATEMI)
		oDatIni:disable()
		oDias1P:disable()
		oParcel:disable()
		oInterv:disable()
	Else
		If dDataIni == ctod(" ") .and. nDias1P==0 .and. nParcel==0 .and. nInterv==0
			dDataIni := ddatabase
			oDatIni:enable()
			oDias1P:enable()
			oParcel:enable()
			oInterv:enable()
			nParcel := 1
			If Len(aIteParc)<=1
				VX001CALPAR()
			Endif
		Else
			If Len(aIteParc)<=1
				VX001CALPAR()
			Endif
		EndIf
	EndIf
EndIf
If Empty(aIteParc)
	aIteParc := { { ctod(""),0 } }
EndIf
oLbParc:nAt := 1
oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
oLbParc:refresh()
oDatIni:refresh()
oDias1P:refresh()
oParcel:refresh()
oInterv:refresh()
oGetDados:oBrowse:Refresh()
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX001CALPAR  |Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Calcula as parcelas do como pagar                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001CALPAR()
Local nCntFor := 0
Local nValor  := 0
If lAtuFiscal // Atualiza Fiscal
	nValor := MaFisRet(,"NF_BASEDUP")
EndIf
if nValor == 0
	aIteParc := {}
	return .t.
endif
//
If Empty(M->VV0_FORPAG)
	MsgStop(STR0032,STR0027)//A forma de pagamento nao foi preenchida.","Atencao
	Return
EndIf
If (nParcel < 1) .or. (dDataIni < ddatabase) .or. (nParcel > nValor)
	MsgStop(STR0033,STR0027)//Os dados para calculo das percelas nao foram preenchidos corretamente.","Atencao
	Return
EndIf

aIteParc := {}
nValBase := Round(nValor / nParcel ,2)

For nCntFor := 1 to nParcel
	aAdd(aIteParc, {(dDataIni + nDias1P) + ((nCntFor - 1)*nInterv ) , nValBase} )
Next
//
nResto := nValor - (nValBase * nParcel)
//
aIteParc[1,2] += nResto
//
oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
oLbParc:refresh()
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX001CANPAR  |Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Cancela como pagar                                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001CANPAR(nTp)
Default nTp := 0
aIteParc := { { ctod(""),0 } }
If nTp == 0
	dDataIni := ctod(" ")
	nDias1P := 0
	nParcel := 0
	nInterv := 0
Endif
oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
oLbParc:refresh()
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX001GRV    |Autor  |  Luis Delorme         | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Gravacao da nota fiscal de saida                             |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001GRV(nOpc,xSX5NumNota,xTIPDOC)
Local lRet := .f.
Default xSX5NumNota := {.t.,"",""}
Default xTIPDOC     := "1" // 1=NF / 2=SD3 (Mov.Internas)
//
lMsErroAuto := .f.
//
If nOpc == 5
	//#############################################################################
	//# CANCELAMENTO DA NOTA FISCAL                                               #
	//#############################################################################
	lRet := VX001CANCEL()
	If !lRet
		If lMsErroAuto
			MostraErro()
		EndIf
		Return .f.
	EndIf
ElseIf nOpc == 3
	//#############################################################################
	//# EMISSAO DA NOTA FISCAL                                                    #
	//#############################################################################
	// SE A ROTINA FISCAL SE PERDEU POR ALGUM MOTIVO O PROCESSO DEVE SER REINICIADO
	If lAtuFiscal .and. !MaFisFound('NF') // Atualiza Fiscal
		MsgStop(STR0027+;
		" "+STR0078)
		Return .f.
	EndIf
	// Ponto de Entrada Antes da Gravacao da Nota Fiscal
	If ExistBlock("VX001ANF")
		If !ExecBlock("VX001ANF",.f.,.f.)
			Return .f.
		Endif
	EndIf
	//
	lRet := VX001EMINF(xSX5NumNota,xTIPDOC)
	If !lRet
		If !lVX001Auto
			MostraErro()
		EndIf
		Return .f.
	EndIf
	//
	// Ponto de Entrada Depois da Gravacao da Nota Fiscal
	If ExistBlock("VX001DNF")
		ExecBlock("VX001DNF",.f.,.f.)
	EndIf
EndIf
//
If !lVX001Auto
	oDlg:End()
EndIf
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX001EMINF  | Autor |  Luis Delorme         | Data | 31/07/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |Gravacao e Integracao de Veiculos Normais                     |##
##+----------+--------------------------------------------------------------+##
##|Uso       |Veiculos  (Modelo3)                                           |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001EMINF(xSX5NumNota,xTIPDOC)
Local aIte          := {}
Local nCntFor, nCntFor2, x_
Local cQryVVA       := "SQLVVA"

Local aVetAtuSD2    := {}

Local nProdAgrup    := 0

Local aUltMov       := {}
                            
Local ni            := 0 
Local nCustoVeiculo := 0

Local lTIPMOV       := ( VV0->(FieldPos("VV0_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )
Local lVV0_TIPDOC   := ( VV0->(FieldPos("VV0_TIPDOC")) > 0 ) // Gerar: 1=NF / 2=SD3 (Mov.Internas)
Local aSB1SD3       := {}
Local nModBkp
Local cModBkp

Local lOkTit        := .t.
Local nRecSF2       := 0

Local cFilDest := "" // Filial de Destino ( Filial da Entrada )
Local cObs     := ""

Default xSX5NumNota := {.t.,"",""}
Default xTIPDOC     := "1" // 1=NF / 2=SD3 (Mov.Internas)

Private cGruVei     := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo

Private lVVA_SEGMOD := VVA->(ColumnPos("VVA_SEGMOD")) > 0 

// TODAS AS VERIfICACOES JA FORAM REALIZADAS
// AS ROTINAS FISCAIS ESTAO CARREGADAS E DISPONIVEIS
// RESTA AGORA GRAVAR AS TABELAS VV0,VVA,SB1,VV1 e INTEGRAR
For nCntFor = 1 to len(acols)
	n = nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	FGX_AMOVVEI(xFilial("VV1"),aCols[nCntFor,FG_POSVAR("VVA_CHASSI")])
next
//
If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	lRemito := .f.
	If !(cPaisLoc == "BRA")
		nOpcAviso := Aviso(STR0037,STR0038,{STR0039,STR0040})//Faturamento # Escolha o tipo de documento a ser emitido. # Nota Fiscal # Remito
		if nOpcAviso == 1
			lRemito := .f.
		else
			lRemito := .t.
		endif
	endif
	//
	if lRemito
		cSerie := "R  "
		cNumero := NxtSX5Nota("R  ", NIL, GetNewPar("MV_TPNRNFS","1"))
	else
		If xSX5NumNota[1]
			lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"))
		Else
			lRet := .t.
			cNumero := xSX5NumNota[2]
			cSerie  := xSX5NumNota[3]
		EndIf
		If !lRet
			Return .f.
		EndIf
	EndIf
endif
//#############################################################################
//# INICIO DO CONTROLE DE TRANSACAO                                           #
//#############################################################################
BEGIN TRANSACTION
//
//#######################
//# Gravacao do VV0     #
//#######################
dbSelectArea("VV0")
M->VV0_NUMTRA := GetSxENum("VV0","VV0_NUMTRA")

If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	M->VV0_NUMNFI := cNumero := padr(cNumero,GetSX3Cache("F2_DOC","X3_TAMANHO"))
	M->VV0_SERNFI := cSerie  := padr(cSerie,GetSX3Cache("F2_SERIE","X3_TAMANHO"))

	// SE FOI ENCONTRADA NF PARA ESSA TRANSACAO HOUVE UM ERRO INESPERADO
	//set delete off
	DBSelectArea("SF2")
	DBSetOrder(1)
	If DBSeek(xFilial("SF2")+cNumero+cSerie)
		DisarmTransaction()
		RollBackSxE()
		MsgStop(STR0041,STR0027)//Ja existe documento com a numeracao escolhida. ### Atencao
		Return .f.
	EndIf
	MaFisRef("NF_FRETE"  ,"VX001",M->VV0_VALFRE) // Valor digitado na Tela
	MaFisRef("NF_DESPESA","VX001",M->VV0_DESACE) // Valor digitado na Tela
EndIf
//
// MONTA OS CAMPOS DO VV0 DEPENDENTES DE FISCAL
If lAtuFiscal // Atualiza Fiscal
	DBSelectArea("SX3")
	DBSetOrder(1)
	DBSeek("VV0")
	while SX3->X3_ARQUIVO=="VV0"
		cValid	:= AllTrim(UPPER(SX3->X3_VALID))
		If "MAFISREF"$cValid
			nPosRef := AT('MAFISREF("',cValid) + 10
			cRefCols:=Substr(cValid,nPosRef,AT('","VX001",',cValid)-nPosRef )
			&("M->"+X3_CAMPO):= MaFisRet(,cRefCols)
		EndIf
		DbSkip()
	enddo
EndIf
// DA RECLOCK NA TABELA PARA INCLUIR REGISTRO
If !RecLock("VV0",.t.)
	DisarmTransaction()
	RollBackSxE()
	Help("  ",1,"REGNLOCK")
	Return .f.
EndIf
// GRAVA TODOS OS CAMPOS QUE ESTAO NA MEMORIA
FG_GRAVAR("VV0")
//
VV0->VV0_FILIAL := xFilial("VV0")      
VV0->VV0_SITNFI := "1" && Valida
VV0->VV0_DTHEMI := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo
VV0->VV0_OPEMOV := cOpeMov
If lTIPMOV
	VV0->VV0_TIPMOV := "0" // 0 = Normal
EndIf
If lVV0_TIPDOC
	VV0->VV0_TIPDOC := xTIPDOC // 1=NF / 2=SD3 (Mov.Internas)
EndIf
VV0->VV0_STATUS := "F"
VV0->VV0_ALIICM := 0
//
cObs := "***  " + Left(Alltrim(UsrRetName(__CUSERID)), 15) + "  " + Transform(dDataBase,"@D")
cObs += " - " + Transform(Time(), "@R 99:99") + "  ***" + Chr(13) + Chr(10)
cObs += VV0_OBSERV
MSMM(VV0->VV0_OBSMEM, TamSx3("VV0_OBSERV")[1],, cObs, 1,,, "VV0", "VV0_OBSMEM")
ConfirmSx8()

MSMM(VV0->VV0_OBSMNF, TamSx3("VV0_OBSENF")[1],, VV0_OBSENF, 1,,, "VV0", "VV0_OBSMNF")
ConfirmSx8()
MsUnlock()

//#############################
//# Fim da Gravacao do VV0    #
//#############################
nRecVV0 := VV0->(Recno())
nSlv := n			// Salva a variavel n do acols
aItePv :={}
aItemRm := {}
nSeqPed := 0
For nCntFor = 1 to len(acols)
	// JANELA DE ABORTO
	If VX001ABORT()
		Return .f.
	EndIf
	n = nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	nSeqPed ++
	//
	lGrCodInd := .f.
	//
	DBSelectArea("VV1")
	DBSetOrder(2)
	DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VVA_CHASSI")])

	FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)

	//	
	nCustoVeiculo := FGX_CUSVEI( VV1->VV1_CHAINT , VV1->VV1_CODMAR , VV1->VV1_MODVEI , VV2->VV2_SEGMOD , VV1->VV1_CORVEI , dDataBase ) // B2_CM1 + Indice
	//
	if 	cOpeMov $ "35" // Remessa / Consignado
		aMovsRem := FGX_VEIMOVS( aCols[nCntFor,FG_POSVAR("VVA_CHASSI")] , "E")
		if Len(aMovsRem) > 0
			DBSelectArea("VVG")
			DBSetOrder(1)
			DBSeek(aMovsRem[1,2]+aMovsRem[1,3]+aCols[nCntFor,FG_POSVAR("VVA_CHAINT")])

			FGX_VV1SB1("CHAINT", aCols[nCntFor,FG_POSVAR("VVA_CHAINT")] , /* cMVMIL0010 */ , cGruVei )

			DBSelectArea("SB2")
			DBSetOrder(1)
			DBSeek(aMovsRem[1,2]+SB1->B1_COD+VV1->VV1_LOCPAD)

			nCustoVeiculo := SB2->B2_CM1
			cCodIndRem :=  VVG->VVG_CODIND
			lGrCodInd := .t.
		endif
	Elseif 	cOpeMov $ "2" // transferencia
		aMovsTrf := FGX_VEIMOVS( aCols[nCntFor,FG_POSVAR("VVA_CHASSI")] , "E")
		if Len(aMovsTrf) > 0
			DBSelectArea("VVG")
			DBSetOrder(1)
			DBSeek(aMovsTrf[1,2]+aMovsTrf[1,3]+aCols[nCntFor,FG_POSVAR("VVA_CHAINT")])

			FGX_VV1SB1("CHAINT", aCols[nCntFor,FG_POSVAR("VVA_CHAINT")] , /* cMVMIL0010 */ , cGruVei )

			DBSelectArea("SB2")
			DBSetOrder(1)
			DBSeek(aMovsTrf[1,2]+SB1->B1_COD+VV1->VV1_LOCPAD)  
			
			nCustoVeiculo := SB2->B2_CM1
			cCodIndRem :=  VVG->VVG_CODIND
			lGrCodInd := .t.
		endif
	endif
	
	//################################################################
	//# Gravacao do VVA                                              #
	//################################################################
	DBSelectArea("VV1")
	DBSetOrder(2)
	If !(DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VVA_CHASSI")]))
		MsgStop(STR0079+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0082+aCols[nCntFor,FG_POSVAR("VVA_CHASSI")],STR0061)
		DisarmTransaction()
		RollBackSxE()
		Return .f.
	EndIf
	dbSelectArea("VVA")
	RecLock("VVA",.t.)
	FG_GRAVAR("VVA",aCols,aHeader,nCntFor)
	VVA->VVA_FILIAL := xFilial("VVA")
	VVA->VVA_NUMTRA := VV0->VV0_NUMTRA
	VVA->VVA_CHAINT := VV1->VV1_CHAINT
	VVA->VVA_ESTVEI := VV1->VV1_ESTVEI
	if lGrCodInd
		VVA->VVA_CODIND := cCodIndRem
	endif
	VVA->VVA_VCAVEI := nCustoVeiculo
	//
	VVA->VVA_FATTOT := VVA->VVA_VALMOV+VVA->VVA_COMCOT+VVA->VVA_COMCTP+VVA->VVA_RECTEC+VVA->VVA_BONFAB
	VVA->VVA_LUCBRU := VVA->VVA_FATTOT-VVA->VVA_TOTIMP-VVA->VVA_VCAVEI-VVA->VVA_VALFRE
	VVA->VVA_LUCLQ1 := VVA->VVA_LUCBRU-VVA->VVA_JUREST-VVA->VVA_ACESSO-VVA->VVA_VDESCO-VVA->VVA_DESCLI-VVA->VVA_SEGVIA-VVA->VVA_VALASS-VVA->VVA_VALREV-VVA->VVA_DESVEI-VVA->VVA_ASSIMP-VVA->VVA_COMVDE-VVA->VVA_COMGER-VVA->VVA_COMPAT //LUCRO MARGINAL
	VVA->VVA_LUCLQ2 := VVA->VVA_LUCLQ1-VVA->VVA_DESFIX+(VVA->VVA_REDCUS+VVA->VVA_RECVEI-VVA->VVA_DSPFIN)      //LAIR
	//
	VX001MFORTE(VV1->VV1_CHAINT)
	//
	If VVA->(FieldPos("VVA_ITETRA")) <> 0
		VVA->VVA_CODMAR := VV1->VV1_CODMAR
		//VVA->VVA_GRUMOD := FM_SQL("SELECT VV2_GRUMOD FROM " + RetSQLName("VV2") + " VV2 WHERE VV2_FILIAL = '" + xFilial("VV2") + "' AND VV2_CODMAR = '" + VV1->VV1_CODMAR + "' AND VV2_MODVEI = '" + VV1->VV1_MODVEI + "' AND D_E_L_E_T_ = ' '")
		VVA->VVA_GRUMOD := VV2->VV2_GRUMOD
		VVA->VVA_MODVEI := VV1->VV1_MODVEI
		If lVVA_SEGMOD
			VVA->VVA_SEGMOD := VV1->VV1_SEGMOD
		EndIf
		VVA->VVA_CORVEI := VV1->VV1_CORVEI
		VVA->VVA_VALTAB := VVA->VVA_VALMOV
	EndIf
	//
	MsUnlock()
	//################################################################
	//# Gravacao do VV1                                              #
	//################################################################
	//
	DBSelectArea("VV1")
	If cOpeMov $ "02" // VENDA
		// SE FOR VENDA GRAVA O CLIENTE
		reclock("VV1",.f.)
		VV1->VV1_PROATU := SA1->A1_COD
		VV1->VV1_LJPATU := SA1->A1_LOJA
		VV1->VV1_DOCIND := SA1->A1_CGC
		MsUnlock()
	ElseIf cOpemov $ "4" // DEVOLUCAO DE COMPRA
		reclock("VV1",.f.)
		VV1->VV1_PROATU := ""
		VV1->VV1_LJPATU := ""
		VV1->VV1_DOCIND := ""
		MsUnlock()
	EndIf
	dbSelectArea("VV0")
	RecLock("VV0",.f.)
	VV0->VV0_TIPFAT := VV1->VV1_ESTVEI // Grava 0 para Novos e 1 para Usados
	MsUnlock()

	dbSelectArea("SB1")
	If FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , cUsaGrVA , cGruVei )
		

		if GetNewPar("MV_MIL0024","S")=="S" // Atualiza SB1 nas movimentações de saída? S/N
			RecLock("SB1",.f.)
			SB1->B1_PICM   := VVA->VVA_ALIICM
			SB1->B1_IPI    := VVA->VVA_ALIIPI
			SB1->B1_PRV1   := VVA->VVA_VALVDA
			MsUnlock()
		endif

		//
		// Grava localização
		//
		if GetNewPar("MV_LOCVZL","N")=="S"  // USA LOCALIZACAO DE VEICULOS
			DBSelectArea("SB5")
			DBSetOrder(1)
			if DBSeek(xFilial("SB5")+SB1->B1_COD)
				DBSelectArea("VZL")
				DBSetOrder(1)
				if DBSeek(xFilial("VZL")+SB1->B1_LOCPAD+SB5->B5_LOCALI2)
					if VZL->VZL_QTDATU > 0
						reclock("VZL",.f.)
						VZL->VZL_QTDATU := VZL->VZL_QTDATU - 1
						msunlock()
					endif
				endif
			endif
		endif

	Else
		FMX_HELP("VEIXX001ERR01",STR0050) // "O veículo não está corretamente cadastrado na tabela de peças (SB1)."
		DisarmTransaction()
		RollBackSxE()
		Return .f.
	EndIf
	dbSetOrder(1)

	If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
		//
		//################################################################
		//# Gravacao do Pedido de Venda                                  #
		//################################################################
		lLiberaPed := .f.
		DBSelectArea("SF4")
		DBSetOrder(1)
		dbSeek(xFilial("SF4")+VVA->VVA_CODTES)
		if lRemito
			aLin := {}
			aAdd(aLIN,{"D2_ITEM"    ,STRZERO(nSeqPed,2),NIL})
			aAdd(aLIN,{"D2_COD"     ,SB1->B1_COD ,NIL})
			aAdd(aLIN,{"D2_QUANT"   ,1 ,NIL})
			aAdd(aLIN,{"D2_PRCVEN"  ,VVA->VVA_VALMOV+VVA->VVA_VALDES,NIL})
			aAdd(aLIN,{"D2_TOTAL"  ,VVA->VVA_VALMOV+VVA->VVA_VALDES,NIL})
			aAdd(aLIN,{"D2_TES"     ,VVA->VVA_CODTES  ,NIL})
			aAdd(aLIN,{"D2_LOCAL"   ,SB1->B1_LOCPAD  ,NIL})
			aAdd(aItemRm,aClone(aLIN))
		else
			aIteTempPV := {}
			If cUsaGrVA == "1" .and. nProdAgrup > 0 // Usa Veiculos de forma Agrupada por Modelo no SB1
				SB1->(dbGoto(nProdAgrup))
			Endif
			//
			aAdd(aIteTempPV,{"C6_NUM"    ,VV0->VV0_NUMPED						,Nil})
			aAdd(aIteTempPV,{"C6_ITEM"   ,STRZERO(nSeqPed,2)					,Nil})
			aAdd(aIteTempPV,{"C6_PRODUTO",SB1->B1_COD  							,Nil})
			aAdd(aIteTempPV,{"C6_ENTREG" ,VV0->VV0_DATMOV  						,Nil})
			aAdd(aIteTempPV,{"C6_UM"     ,"UN"           						,Nil})
			aAdd(aIteTempPV,{"C6_TES"    ,VVA->VVA_CODTES  						,Nil})
			aAdd(aIteTempPV,{"C6_LOCAL"  ,SB1->B1_LOCPAD   						,Nil})
			aAdd(aIteTempPV,{"C6_CLASFIS",SB1->B1_ORIGEM+SF4->F4_SITTRIB		,Nil})
			aAdd(aIteTempPV,{"C6_DESCRI" ,SB1->B1_DESC  						,Nil})
			aAdd(aIteTempPV,{"C6_CLI"    ,VV0->VV0_CODCLI      					,Nil})
			aAdd(aIteTempPV,{"C6_LOJA"   ,VV0->VV0_LOJA         				,Nil})
			DBSelectArea("SF4")
			DBSetOrder(1)
			dbSeek(xFilial("SF4")+VVA->VVA_CODTES)
			if SF4->F4_ESTOQUE == "S" .or. cOpeMov != "3"
				//		aAdd(aIteTempPV,{"C6_QTDLIB" ,1              						,Nil})
				aAdd(aIteTempPV,{"C6_QTDVEN" ,1            							,Nil})
				aAdd(aIteTempPV,{"C6_PRUNIT" ,VVA->VVA_VALMOV						,Nil})
				aAdd(aIteTempPV,{"C6_PRCVEN" ,VVA->VVA_VALMOV+VVA->VVA_VALDES		,Nil})
				aAdd(aIteTempPV,{"C6_VALOR"  ,VVA->VVA_VALMOV+VVA->VVA_VALDES		,Nil})
				aAdd(aIteTempPV,{"C6_VALDESC",VVA->VVA_VALDES  						,Nil})
			else
				lLiberaPed := .t.
				aAdd(aIteTempPV,{"C6_QTDLIB" ,0              						,Nil})
				aAdd(aIteTempPV,{"C6_QTDVEN" ,1            							,Nil})
				aAdd(aIteTempPV,{"C6_PRCVEN" ,VVA->VVA_VALMOV+VVA->VVA_VALDES		,Nil})
				aAdd(aIteTempPV,{"C6_VALOR"  ,VVA->VVA_VALMOV+VVA->VVA_VALDES		,Nil})
				aAdd(aIteTempPV,{"C6_PRUNIT" ,VVA->VVA_VALMOV						,Nil})
				aAdd(aIteTempPV,{"C6_VALDESC",VVA->VVA_VALDES  						,Nil})
			endif

			// Ticket: 2353361
			// ISSUE: MMIL-2867
			// O TES está sendo enviado novamente pois na base do cliente ocorria uma falha. O conteúdo do TES
			//   na aCols (MATA410) ficava com conteúdo VAZIO.
			// O problema não foi reproduzido em base teste, mas verificamos que passando o TES novamente
			//   a falha não ocorria novamente.
			// A mensagem de HELP disparada era A410VZ.
			aAdd(aIteTempPV,{"C6_TES"    ,VVA->VVA_CODTES  						,Nil})

			If SC6->(FieldPos("C6_CHASSI")) > 0
				aAdd(aIteTempPV,{"C6_CHASSI" ,VV1->VV1_CHASSI,Nil}) // Chassi do Veiculo -  Descricao do Produto
			Endif

			If SC6->(FieldPos("C6_CC"))>0 .and. VVA->(FieldPos("VVA_CENCUS"))>0
				aAdd(aIteTempPV,{"C6_CC" , VVA->VVA_CENCUS , Nil})
			Endif
			If SC6->(FieldPos("C6_CONTA"))>0 .and. VVA->(FieldPos("VVA_CONTA"))>0
				aAdd(aIteTempPV,{"C6_CONTA" , VVA->VVA_CONTA , Nil})
			Endif
			If SC6->(FieldPos("C6_ITEMCTA"))>0 .and. VVA->(FieldPos("VVA_ITEMCT"))>0
				aAdd(aIteTempPV,{"C6_ITEMCTA" , VVA->VVA_ITEMCT , Nil})
			Endif
			If SC6->(FieldPos("C6_CLVL"))>0 .and. VVA->(FieldPos("VVA_CLVL"))>0
				aAdd(aIteTempPV,{"C6_CLVL" , VVA->VVA_CLVL , Nil})
			Endif
			If SC6->(FieldPos("C6_FCICOD"))>0 .and. (VVA->(FieldPos("VVA_FCICOD"))>0 .and. !Empty(VVA->VVA_FCICOD) )
				aAdd(aIteTempPV,{"C6_FCICOD" , VVA->VVA_FCICOD , Nil})
			Endif

			// NT 2021.004 v1.21 - Alecsandre Ferreira
			if SC6->(FieldPos("C6_OBSCONT")) > 0 .AND. (VVA->(FieldPos("VVA_OBSCON")) > 0 .and. !Empty(VVA->VVA_OBSCON) )
				aAdd(aIteTempPV,{"C6_OBSCONT", VVA->VVA_OBSCON, Nil})
			endif          

			if SC6->(FieldPos("C6_OBSCCMP")) > 0 .AND. (VVA->(FieldPos("VVA_OBSCCM")) > 0 .and. !Empty(VVA->VVA_OBSCCM) )
				aAdd(aIteTempPV,{"C6_OBSCCMP", VVA->VVA_OBSCCM, Nil})
			endif         

			if SC6->(FieldPos("C6_OBSFISC")) > 0 .AND. (VVA->(FieldPos("VVA_OBSFIS")) > 0 .and. !Empty(VVA->VVA_OBSFIS) )
				aAdd(aIteTempPV,{"C6_OBSFISC", VVA->VVA_OBSFIS, Nil})
			endif         

			if SC6->(FieldPos("C6_OBSFCMP")) > 0 .AND. (VVA->(FieldPos("VVA_OBSFCP")) > 0 .and. !Empty(VVA->VVA_OBSFCP) )
				aAdd(aIteTempPV,{"C6_OBSFCMP", VVA->VVA_OBSFCP, Nil})
			endif
			// NT 2021.004 v1.21    

			If VV0->VV0_OPEMOV $ "0.2" .and. VV0->VV0_TIPFAT == "1" // Venda ou transferência  de Usado
				aUltMov := FM_VEIMOVS( VV1->VV1_CHASSI , "E"  )
				For ni := 1 to Len(aUltMov)                     
					If aUltMov[ni,5] == "0" // Entrada por Compra
						Dbselectarea("VVF")
						DbSetOrder(1)
						If DbSeek(aUltMov[ni,2]+aUltMov[ni,3])
							Dbselectarea("SD1")
							DbSetOrder(1)  
							If DbSeek(VVF->VVF_FILIAL+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD)
								aAdd(aIteTempPV,{"C6_NFORI" ,SD1->D1_DOC,Nil})
								aAdd(aIteTempPV,{"C6_SERIORI" ,SD1->D1_SERIE,Nil})
								aAdd(aIteTempPV,{"C6_ITEMORI" ,SD1->D1_ITEM,Nil})
								If VV0->VV0_OPEMOV <> "2" // Diferente de Transferencia, pois Transferencia nao pode pegar a Base da Entrada conforme orientação https://tdn.totvs.com/pages/releaseview.action?pageId=567761617
									aAdd(aIteTempPV,{"C6_BASVEIC" ,SD1->D1_TOTAL,Nil})
								EndIf
							Endif
						EndIf
						Exit
					Endif
				Next
			
			Endif
			
			if cOpeMov $ "467"
				for nCntFor2 := 1 to Len(aAutoAux[nCntFor])
					aAdd(aIteTempPV,aAutoAux[nCntFor,nCntFor2])
				next
			endif
			//
			aAdd(aItePv,aClone(aIteTempPV))
		endif
		If SD2->(FieldPos("D2_CHASSI")) > 0 
			aadd(aVetAtuSD2,{SB1->B1_COD,STRZERO(nSeqPed,2),VVA->VVA_CHASSI}) // Referência dos Elementos no SD2: D2_COD, D2_ITEM, D2_CHASSI
		Endif
	EndIf
Next

// VV0_OPEMOV: 0=Venda;1=Simulacao;2=Transferencia;3=Remessa;4=Devolucao;5=Consignado;6=Ret Remessa;7=Ret Consignado;8=Venda Futura;9=Baixa
cC5Tipo := "N"
Do Case
	Case cOpeMov $ "35" // Saida por Remessa/Consignado
		If cCliForA == "F" // utiliza Fornecedor
			cC5Tipo := "B" // Beneficiamento
		EndIf

	Case cOpeMov $ "4" // Devolucao
		cC5Tipo := "D" // D-Devolucao

	Case cOpeMov $ "67" // Saida por Retorno Remessa/Consignado
		If cCliForA == "F" // utiliza Fornecedor
			cC5Tipo := "D" // D-Devolucao
		EndIf
EndCase

If VV0->(FieldPos("VV0_TIPO")) > 0
	dbSelectArea("VV0")
	RecLock("VV0",.f.)
	VV0->VV0_TIPO := cC5Tipo
	MsUnlock()
Endif                                             
//

If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)

	If !(cPaisLoc == "BRA")
		aCab := {}
		aAdd(aCAB,{"F2_CLIENTE",VV0->VV0_CODCLI	,NIL})
		aAdd(aCAB,{"F2_LOJA"   ,VV0->VV0_LOJA		,NIL})
		aAdd(aCAB,{"F2_SERIE"  ,"R  "					,NIL})
		aAdd(aCAB,{"F2_DOC"   ,cNumero    			,NIL})
		aAdd(aCAB,{"F2_EMISSAO",dDatabase  			,NIL})
		aAdd(aCAB,{"F2_MOEDA"  ,1          			,NIL})
		aAdd(aCAB,{"F2_TXMOEDA",1          			,NIL})
		aAdd(aCAB,{"F2_TIPOREM","0"        			,NIL})
		aAdd(aCAB,{"F2_TIPO"   ,cC5Tipo    			,NIL})
		lMsErroAuto := .F.
		nAnt    := MAFISSAVE()
		MAFISEND()
		if cC5Tipo == "B"
			if !lRemito
				aAdd(aCab,{"F2_TIPODOC"	,"11"           												,Nil})
				aAdd(aCab,{"F2_ESPECIE"	,"NF"           												,Nil})
			else
				aAdd(aCab,{"F2_TIPODOC"	,"52"           												,Nil})
				aAdd(aCab,{"F2_ESPECIE"	,"RFB"           												,Nil})
			endif
		elseif cC5Tipo == "D"
			if !lRemito
				aAdd(aCab,{"F2_TIPODOC"	,"11"           												,Nil})
				aAdd(aCab,{"F2_ESPECIE"	,"NF"           												,Nil})
			else
				aAdd(aCab,{"F2_TIPODOC"	,"61"           												,Nil})
				aAdd(aCab,{"F2_ESPECIE"	,"RCD"           												,Nil})
			endif
		else // if cF1Tipo == "N"
			if !lRemito
				aAdd(aCab,{"F2_TIPODOC"	,"1"           												,Nil})
				aAdd(aCab,{"F2_ESPECIE"	,"NF"           												,Nil})
			else
				aAdd(aCab,{"F2_TIPODOC"	,"50"           												,Nil})
				aAdd(aCab,{"F2_ESPECIE"	,"RFN"           												,Nil})
			endif
		endif
		//
		if lRemito
			if cC5Tipo == "D"
				MsExecAuto({|x,y,z| MATA102DN(x,y,z)},aCAB,aITEMRm,3)
			else
				MsExecAuto({|x,y,z| MATA462N(x,y,z)},aCAB,aITEMRm,3)
			endif
		else
			MsExecAuto({|x,y,z| MATA467N(x,y,z)},aCAB,aITEMRm,3)
		endif
		//
		MAFISRESTORE(nAnt)
		//
		If lMSErroAuto
			DisarmTransaction()
			RollBackSxE()
			return .f.
		endif
	else
		
		aCabPV := {}
		//	aAdd(aCabPV,{"C5_NUM"    ,VV0->VV0_NUMPED  										,Nil})
		aAdd(aCabPV,{"C5_TIPO"   ,cC5Tipo												,Nil})
		aAdd(aCabPV,{"C5_CLIENTE",VV0->VV0_CODCLI  										,Nil})
		aAdd(aCabPV,{"C5_LOJAENT",VV0->VV0_LOJA   	  									,Nil})
		aAdd(aCabPV,{"C5_LOJACLI",VV0->VV0_LOJA  	   									,Nil})
		aAdd(aCabPV,{"C5_CONDPAG",VV0->VV0_FORPAG										,Nil})
		aAdd(aCabPV,{"C5_VEND1"  ,VV0->VV0_CODVEN	 									,Nil})
		aAdd(aCabPV,{"C5_EMISSAO",VV0->VV0_DATMOV										,Nil})
		aAdd(aCabPV,{"C5_TIPOCLI",IIf(cCliForA == "C",SA1->A1_TIPO,"R")				,Nil})
		aAdd(aCabPV,{"C5_BANCO"  ,VV0->VV0_CODBCO  										,Nil})
		aAdd(aCabPV,{"C5_INCISS" ,"N"            	  									,Nil})
		aAdd(aCabPV,{"C5_TIPLIB" ,"2"            	  									,Nil})
		aAdd(aCabPV,{"C5_MOEDA"  ,1              							 			,Nil})
		aAdd(aCabPV,{"C5_LIBEROK","S"            										,Nil})
		aAdd(aCabPV,{"C5_COMIS1" ,0              		 								,Nil})
		aAdd(aCabPV,{"C5_DESPESA",VV0->VV0_DESACE  	 								,Nil})
		aAdd(aCabPV,{"C5_FRETE" ,VV0->VV0_VALFRE 		 								,Nil})
		
		If VV0->(FieldPos("VV0_SEGURO")) > 0 .and. VV0->VV0_SEGURO > 0
			aAdd(aCabPV,{"C5_SEGURO" ,VV0->VV0_SEGURO 		 								,Nil})		
		EndIf
		if SC5->(FieldPos("C5_NATUREZ")) > 0
			aAdd(aCabPV,{"C5_NATUREZ" ,VV0->VV0_NATFIN							   		,Nil})
		endif
		if SC5->(FieldPos("C5_TRANSP")) > 0
			aAdd(aCabPV,{"C5_TRANSP" ,VV0->VV0_CODTRA  									,Nil})
		Endif
		If !Empty(VV0->VV0_TPFRET)
			aAdd(aCabPV,{"C5_TPFRETE",Alltrim(VV0->VV0_TPFRET)							,NIL})	// Tipo do Frete
		EndIf
		If VV0->(FieldPos("VV0_PESOL")) > 0 .and. VV0->VV0_PESOL > 0
			aAdd(aCabPV,{"C5_PESOL",VV0->VV0_PESOL										,Nil})	// Peso Liquido
		EndIf
		If VV0->(FieldPos("VV0_PBRUTO")) > 0 .and. VV0->VV0_PBRUTO > 0
			aAdd(aCabPV,{"C5_PBRUTO",VV0->VV0_PBRUTO									,Nil})	// Peso Bruto
		EndIf
		If VV0->(FieldPos("VV0_VOLUME")) > 0 .and. VV0->VV0_VOLUME > 0
			aAdd(aCabPV,{"C5_VOLUME1",VV0->VV0_VOLUME									,Nil})	// Volume
		EndIf
		If VV0->(FieldPos("VV0_ESPECI")) > 0 .and. !Empty(VV0->VV0_ESPECI)
			aAdd(aCabPV,{"C5_ESPECI1",VV0->VV0_ESPECI									,Nil})	// Especie
		EndIf
		If VV0->(FieldPos("VV0_VEICUL")) > 0 .and. !Empty(VV0->VV0_VEICUL)
			aAdd(aCabPV,{"C5_VEICULO",VV0->VV0_VEICUL									,Nil})	// Veiculo
		EndIf
		If SC5->(FieldPos("C5_INDPRES")) > 0 .and. ( VV0->(FieldPos("VV0_INDPRE")) > 0 .and. !Empty(VV0->VV0_INDPRE) )
			aAdd(aCabPV,{"C5_INDPRES"  ,VV0->VV0_INDPRE   								,Nil}) 	// Presenca do Comprador
		Endif
		If SC5->(FieldPos("C5_CLIENT")) > 0 .and. ( VV0->(FieldPos("VV0_CLIENT")) > 0 .and. !Empty(VV0->VV0_CLIENT) )
			aAdd(aCabPV,{"C5_CLIENT"  ,VV0->VV0_CLIENT   								,Nil}) 	// Cliente Entrega
		Endif
		If SC5->(FieldPos("C5_LOJAENT")) > 0 .and. ( VV0->(FieldPos("VV0_LOJENT")) > 0 .and. !Empty(VV0->VV0_LOJENT) )
			aAdd(aCabPV,{"C5_LOJAENT"  ,VV0->VV0_LOJENT   								,Nil}) 	// Loja do cliente de entrega
		Endif
		If SC5->(FieldPos("C5_CODA1U")) > 0 .and. ( VV0->(FieldPos("VV0_CODA1U")) > 0 .and. !Empty(VV0->VV0_CODA1U) )
			aAdd(aCabPV,{"C5_CODA1U"  ,VV0->VV0_CODA1U   								,Nil})
		Endif
		If ! Empty(VV0->VV0_MENNOT)
			aAdd(aCabPV,{"C5_MENNOTA",VV0->VV0_MENNOT ,Nil}) // Mensagem da NF
		EndIf
		If ! Empty(VV0->VV0_MENPAD)
			aAdd(aCabPV,{"C5_MENPAD" ,VV0->VV0_MENPAD ,Nil}) // Mensagem Padrao NF
		EndIf                

		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("SC5")
		While !Eof().and.(x3_arquivo=="SC5")
			If Alltrim(x3_campo) != "C5_NUM"
				wVar := "M->"+x3_campo
				&wVar:= CriaVar(x3_campo)
			Endif
			dbSkip()
		EndDo
		
		For x_:=1 to Len(aCabPV)
			Private &("M->"+aCabPV[x_,1]) := aCabPV[x_,2]
		Next
		nAnt    := MAFISSAVE()
		MAFISEND()

		// CHAMADA DO MATA410 COM OS DADOS DA INTEGRACAO
		lMsErroAuto := .f.
		//
		// Ponto de Entrada antes do Pedido de Venda
		//
		if ExistBlock("VX001APV")
			ExecBlock("VX001APV",.f.,.f.)
		Endif
		//
		MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItePv,3)
		//
		MAFISRESTORE(nAnt)
		//
		If lMsErroAuto
			DisarmTransaction()
			RollBackSxE()
			Return .f.
		EndIf
		// JANELA DE ABORTO
		If VX000ABORT()
			Return .f.
		EndIf
		
		dbSelectArea("VV0")
		RecLock("VV0",.f.)
		VV0->VV0_NUMPED := SC5->C5_NUM
		MsUnlock()
		
		aRegSC6 := {}
		//################################################################
		//# Gera F2/D2, Atualiza Estoque, Financeiro, Contabilidade      #
		//################################################################
		aPvlNfs := {}
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5")+VV0->VV0_NUMPED))
		//
		SC6->(dbSetOrder(1))
		SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))
		
		SC9->(DbSetOrder(1))
		if !(SC9->(MsSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM)))) //FILIAL+NUMERO+ITEM
			
			lCredito := .t.
			lEstoque := .t.
			lLiber   := .t.
			lTransf  := .f.
			
			dbSelectArea("SC6")
			dbSetOrder(1)
			dbSeek(xFilial("SC6")+VV0->VV0_NUMPED+"01")
			While !eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == VV0->VV0_NUMPED
				dbSelectArea("SC9")
				if !dbSeek(xFilial("SC9")+VV0->VV0_NUMPED+SC6->C6_ITEM)
					nQtdLib := SC6->C6_QTDVEN
					nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf)
				Endif
				dbSelectArea("SC6")
				dbSkip()
			Enddo

			If !lEstoque
				MsgStop(STR0077,STR0027)
				DisarmTransaction()
				RollBackSxE()
				Return .f.
			Endif
		
		endif

		aPvlNfs := {}
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5")+VV0->VV0_NUMPED))
		//
		SC6->(dbSetOrder(1))
		SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))
		
		While SC6->(!Eof() .And. C6_FILIAL == xFilial("SC6")) .And. SC6->C6_NUM == SC5->C5_NUM
			
			SC9->(DbSetOrder(1))
			SC9->(MsSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))) //FILIAL+NUMERO+ITEM
			
			SE4->(DbSetOrder(1))
			SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )  //FILIAL+CONDICAO PAGTO
			
			SB1->(DbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))    //FILIAL+PRODUTO
			
			SB2->(DbSetOrder(1))
			SB2->(MsSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL))) //FILIAL+PRODUTO+LOCAL
			
			SF4->(DbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))   //FILIAL+TES
			
			nPrcVen := SC9->C9_PRCVEN
			If ( SC5->C5_MOEDA <> 1 )
				nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
			EndIf
			
			Aadd(aPvlNfs,{ SC9->C9_PEDIDO,;
			SC9->C9_ITEM,;
			SC9->C9_SEQUEN,;
			SC9->C9_QTDLIB,;
			nPrcVen,;
			SC9->C9_PRODUTO,;
			.f.,;
			SC9->(RecNo()),;
			SC5->(RecNo()),;
			SC6->(RecNo()),;
			SE4->(RecNo()),;
			SB1->(RecNo()),;
			SB2->(RecNo()),;
			SF4->(RecNo())})
			SC6->(DbSkip())
		EndDo
		//
		If len(aPvlNfs) == 0 .and. !FGX_SC5BLQ(VV0->VV0_NUMPED,.t.) // Verifica SC5 bloqueado
			DisarmTransaction()
			RollBackSxE()
			Return .f.
		EndIf
		//
		If Len(aPvlNfs) > 0
			PERGUNTE("MT460A",.f.)
			nModBkp := nModulo
			cModBkp := cModulo
			nModulo := 5
			cModulo := "FAT"
			cNota := MaPvlNfs(aPvlNfs,cSerie,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1), .F., 0, 0, .T., .F.)
			nModulo := nModBkp
			cModulo := cModBkp		
		EndIf
		//
		// Atualiza SF2
		If cOpeMov == "2" // transferencia
			cFilDest := FWLoadSM0()[aScan(FWLoadSM0(),{|i| i[18] == SA1->A1_CGC}),2]  // Filial de Destino do Veiculo que está sendo Transferido
		Endif
		DBSelectArea("SF2")
		reclock("SF2",.f.)
		cPrefAnt := SF2->F2_PREFIXO
		SF2->F2_PREFORI := cPrefVEI
		If !Empty(cFilDest)
			SF2->F2_FILDEST := cFilDest
		Endif
		cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
		SF2->F2_PREFIXO := cPrefNF
		msunlock()
		//
		nRecSF2 := SF2->(RecNo())
		//
		If SD2->(FieldPos("D2_CHASSI")) > 0 
			// Atualiza SD2
			DbSelectArea("SD2")
			DbSetOrder(3)
			For nCntFor = 1 to len(aVetAtuSD2)
				If DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+aVetAtuSD2[nCntFor,1]+aVetAtuSD2[nCntFor,2])
					RecLock("SD2",.f.)
					SD2->D2_CHASSI := aVetAtuSD2[nCntFor,3]
					msUnlock()
				Endif
			Next
		Endif
		DbSelectArea("VV0")
		DbGoTo(nRecVV0)
		reclock("VV0",.f.)
		VV0->VV0_NUMNFI := SF2->F2_DOC
		VV0->VV0_SERNFI := SF2->F2_SERIE
		msunlock()
		
		DbSelectArea("SE1")
		DbSetorder(1)
		If !Empty(SF2->F2_DUPL)
			cAliasSE1 := GetNextAlias()
			cQuery    := "SELECT SE1.R_E_C_N_O_ RECSE1 "
			cQuery    += "FROM "+RetSqlName("SE1")+" SE1 "
			cQuery    += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND SE1.E1_PREFIXO = '"+cPrefAnt+"' AND SE1.E1_NUM = '"+SF2->F2_DUPL+"' AND  "
			cQuery    += "SE1.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSE1, .F., .T. )
			While ( cAliasSE1 )->(!Eof())
				DbSelectArea("SE1")
				DbGoto(( cAliasSE1 )->RECSE1)
				RecLock("SE1",.f.)
					SE1->E1_PREFIXO := SF2->F2_PREFIXO
					SE1->E1_PREFORI := SF2->F2_PREFORI
				msunlock()
				( cAliasSE1 )->(DbSkip())
			Enddo
			( cAliasSE1 )->( dbCloseArea() )
		EndIf
		
		DBSelectArea("SF2")
		//################################################################
		//# Fim da Emissao da Nota Fiscal de Saida                       #
		//################################################################
		if Alltrim(SE4->E4_TIPO)=="A"  .and. aIteParc[1,1] != ctod("")
			//#############################################################################
			//# Gravacao dos Titulos a receber                                            #
			//#############################################################################
			nParcelas := 0
			//
			for nCntFor := 1 to Len(aIteParc)
				cNatureza := VV0->VV0_NATFIN
				cCodBco :=  VV0->VV0_CODBCO
				cTipCob  := if(!Empty(cCodBco),"1","0") // TODO:
				/*
				if Empty(cCodBco)
				cCodBco := VS1->VS1_CODBCO
				if Empty(cCodBco)
				cCodBco := GetNewPar("MV_BCOCXA","")
				if Empty(cCodBco)
				MsgInfo(STR0024 ,STR0019)
				DisarmTransaction()
				return .f.
				Endif
				Endif
				endif
				*/
				FG_Seek("SA6","cCodBco",1,.f.)
				if SA6->A6_BORD == "0"
					cNumBord := "BCO"+SA6->A6_COD
					dDatBord := dDataBase
				else
					cNumBord :=""
					dDatBord := cTod("")
				Endif
				//
				nParcelas++
				if TamSx3("E1_PARCELA")[1] = 1
					cParcela := ConvPN2PC(nParcelas)
				Else
					cParcela := Soma1( strzero(nParcelas-1,TamSx3("E1_PARCELA")[1]) )
				Endif
				//
				aTitulo := {{"E1_PREFIXO" ,cPrefNF																	,Nil},;
				{"E1_NUM"     ,cNota 																				,Nil},;
				{"E1_PARCELA" ,cParcela																				,Nil},;
				{"E1_TIPO"    ,"DP "																				,Nil},;
				{"E1_NATUREZ" ,cNatureza																			,Nil},;
				{"E1_SITUACA",cTipCob																				,Nil},;
				{"E1_CLIENTE" ,SA1->A1_COD																			,Nil},;
				{"E1_LOJA"    ,SA1->A1_LOJA																			,Nil},;
				{"E1_EMISSAO" ,dDataBase																			,Nil},;
				{"E1_VENCTO"  ,aIteParc[nCntFor,1]     		           												,Nil},;
				{"E1_VENCREA" ,DataValida(aIteParc[nCntFor,1]) 			   											,Nil},;
				{"E1_VALOR"   ,aIteParc[nCntFor,2]											   			         	,Nil},;
				{"E1_NUMBOR"  ,cNumBord																				,Nil},;
				{"E1_DATABOR" ,dDatBord																				,Nil},;
				{"E1_PORTADO" ,cCodBco																				,Nil},;
				{"E1_PREFORI" ,cPrefVEI 																			,Nil},;
				{"E1_VEND1"  , SA3->A3_COD																			,nil},;
				{"E1_COMIS1" , SA3->A3_COMIS																		,nil},;
				{"E1_BASCOM1", aIteParc[nCntFor,2]																	,nil},;
				{"E1_PEDIDO" , VV0->VV0_NUMPED																		,nil},;
				{"E1_NUMNOTA", cNota																				,nil},;
				{"E1_ORIGEM" , "MATA460"																			,nil},;
				{"E1_SERIE"  , cSerie																				,nil} }
				//
				pergunte("FIN040",.F.)
				_nRecSA1 := SA1->(Recno())//salva posicao SA1
				
				MSExecAuto({|x| FINA040(x)},aTitulo)
				
				SA1->(Dbgoto(_nRecSA1))	//volta posicao SA1
				
				//
				If lMsErroAuto
					DisarmTransaction()
					RollBackSxE()
					MostraErro()
					Return .f.
				EndIf
			next
		
			DbSelectArea("SF2")
			DbGoTo(nRecSF2)
			RecLock("SF2",.f.)
				SF2->F2_DUPL := cNota // Nro Titulo = Nro NF
			MsUnLock()
		
		endif
		
		//################################################################
		//# Fim da Emissao da Nota Fiscal de Saida                       #
		//################################################################
		MAFISEND()
		// JANELA DE ABORTO
		If VX001ABORT()
			DisarmTransaction()
			RollBackSxE()
			Return .f.
		EndIf
	
	EndIf
	//

Else // xTIPDOC == "2" // 1=NF / 2=SD3 (Mov.Internas) - Agrega/Desagrega

	aSB1SD3    := {}
	SB1->(DbSetOrder(7))
	For nCntFor := 1 to len(aCols)
		//
		FGX_VV1SB1("CHAINT", aCols[nCntFor,FG_POSVAR("VVA_CHAINT")] , /* cMVMIL0010 */ , cGruVei )
		// ( Codigo SB1 , Qtde , Valor , Centro de Custo , Conta Contab , Item Conta , Class.Valor )
		aAdd(aSB1SD3,{	SB1->B1_COD ,;
						1 ,;
						aCols[nCntFor,FG_POSVAR("VVA_VALMOV")] ,;
						aCols[nCntFor,FG_POSVAR("VVA_CENCUS")] ,;
						aCols[nCntFor,FG_POSVAR("VVA_CONTA")] ,;
						aCols[nCntFor,FG_POSVAR("VVA_ITEMCT")] ,;
						aCols[nCntFor,FG_POSVAR("VVA_CLVL")] })
	Next
	SB1->(DbSetOrder(1))
	If !VXX040SD3( "2" , "1" ,   , aSB1SD3 ) // Mov.Interna Peça ( 2=Saida , 1=Tp.Normal , Codigo VDV , aSB1 )
		DisarmTransaction()
		RollBackSxE()
		Return .f.
	EndIf
	DbSelectArea("VV0")
	DbGoTo(nRecVV0)

EndIf
//
END TRANSACTION

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
MsRUnLock()

lOkTit := VXX001TIT() // Gerar Financeiro
If !lOkTit .and. lMostraMsg
	MsgAlert(STR0085,STR0027) // A Movimentação de Saida foi Finalizada gerando NF, porém existe(m) inconsistência(s) na Geração dos Titulos. Favor corrigir a(s) pendência(s) e solicitar novamente a Geração dos Titulos. / Atenção!
EndIf

// ###############################################
// ATUALIZA O STATUS DO VEICULO                  #
// ###############################################
For nCntFor = 1 to len(acols)
	n = nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	// ALTERA STATUS DOS VEICULOS
	FGX_AMOVVEI(xFilial("VV1"),aCols[nCntFor,FG_POSVAR("VVA_CHASSI")])
Next
//
If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)

	if cOpeMov == "4" // DEVOLUCAO
		
		// ATUALIZA O STATUS DA NF PARA DEVOLVIDA OU DEVOLVIDA PARCIALMENTE
		cChave := ""
		if Len(aAutoAux) > 0
			nPos := ascan(aAutoAux[1],{|x| x[1] == "C6_NFORI" })
			if nPos != 0
				cChave := aAutoAux[1,nPos,2]
			endif
			nPos := ascan(aAutoAux[1],{|x| x[1] == "C6_SERIORI" })
			if nPos != 0
				cChave += aAutoAux[1,nPos,2]
			endif
			
			cSitNF := "2"
			DBSelectArea("VVF")
			DBSetOrder(6)
			if DBSeek(xFilial("VVF")+cChave)
				DBSelectArea("VVG")
				DbSetOrder(1)
				if !DBSeek(xFilial("VVG")+VVF->VVF_TRACPA)
					Help(" ",1,"ARQITEINCO")
				Endif
				while !eof() .and. xFilial("VVG")+VVF->VVF_TRACPA == VVG->VVG_FILIAL + VVG->VVG_TRACPA
					
					if !FG_Seek("VV1","VVG->VVG_CHASSI",2,.f.)
						Help(" ",1,"VEINFNEXCD")
						nOpca := 0
						Return (.f.)
					Endif
					
					//					if  VV1->VV1_ULTMOV != "S" .and. VV1->VV1_FILENT == VVF->VVF_FILIAL .and. VV1->VV1_TRACPA == VVF->VVF_TRACPA
					if  VV1->VV1_ULTMOV == "E" .and. VV1->VV1_FILENT == VVF->VVF_FILIAL .and. VV1->VV1_TRACPA == VVF->VVF_TRACPA
						cSitNF := "3"
						exit
					Endif
					
					DBSelectArea("VVG")
					DBSkip()
				enddo
				
				DBSelectArea("VVF")
				reclock("VVF",.f.)
				VVF->VVF_SITNFI := cSitNF//"2"
				msunlock()
				
			Endif
			
		endif
	endif
	//
	dbSelectArea("VV0")
	DbGoTo(nRecVV0)
	//
	if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) <> "S"
		//	PE para Impressao da NF de veiculos
		If ExistBlock("NFSAIVEI")
			ExecBlock("NFSAIVEI",.f.,.f.,{VV0->VV0_NUMNFI,VV0->VV0_SERNFI})
		Endif
	EndIF
	//
	if lMostraMsg
		FMX_TELAINF( "1" , { { Alltrim(VV0->VV0_SERNFI) , Alltrim(VV0->VV0_NUMNFI) , STR0042 } } ) // "EMITIDO"
	endif

	if cOpeMov $ "6/7" // RETORNO DE REMESSA/ RETORNO DE CONSIGNADO
		// ATUALIZA O STATUS DA NF PARA DEVOLVIDA
		cChave := ""
		if Len(aAutoAux) > 0
			nPos := ascan(aAutoAux[1],{|x| x[1] == "C6_NFORI" })
			if nPos != 0
				cChave := aAutoAux[1,nPos,2]
			endif
			nPos := ascan(aAutoAux[1],{|x| x[1] == "C6_SERIORI" })
			if nPos != 0
				cChave += aAutoAux[1,nPos,2]
			endif
			DBSelectArea("VVF")
			dbClearFilter()
			DBSetOrder(6)
			if DBSeek(xFilial("VVF")+cChave)
				RecLock("VVF",.F.)		    
				VVF->VVF_SITNFI := "2"
				MsUnlock()
			endif
			FilBrowse('VVF',{},'VVF->VVF_OPEMOV=="4" .AND. VVF->VVF_SITNFI=="1" .AND. !Empty(VVF->VVF_NUMNFI) .AND. xFilial("VVF")==VVF->VVF_FILIAL .AND. VXA017FIL()')
		endif
	Endif

Else // xTIPDOC == "2" // 1=NF / 2=SD3 (Mov.Internas)

	if lMostraMsg
		FMX_TELAINF( "4" , { { STR0087 , STR0042 } } ) // Mov.Interna / EMITIDO
	EndIf

EndIf
//
Return(.t.)
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX001CANCEL  | Autor |  Luis Delorme        | Data | 31/07/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |Cancelamento de Nota Fiscal - Veiculos Normais                |##
##+----------+--------------------------------------------------------------+##
##|Uso       |Veiculos  (Modelo3)                                           |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001CANCEL()
Local nCntFor, cont2
Local aUltMov := {}
Local lNFeCancel  := SuperGetMV('MV_CANCNFE',.F.,.F.) .AND. SF2->(FieldPos("F2_STATUS")) > 0
//
If VV0->(FieldPos("VV0_TIPDOC")) > 0 .and. VV0->VV0_TIPDOC == "2" // 1 = NF / 2 = Mov.Internas (SD3)
	MsgInfo(STR0086,STR0027) // Esta Saida se trata de Mov.Interna. Impossivel continuar! / Atencao
	Return .f.
EndIf

// VERIfICA SE A NF ESTA CANCELADA OU DEVOLVIDA
If VV0->VV0_SITNFI # "1"   // NF nao-valida
	MsgStop(STR0044 ,STR0027) //Nota Fiscal esta cancelada ou devolvida./### atencao
	Return(.f.)
EndIf
//
DBSelectArea("SF2")
DBSetOrder(1)
If !dbSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
	MsgStop(STR0080+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0081+VV0->VV0_NUMNFI+" / "+VV0->VV0_SERNFI,STR0061)
	Return(.f.)
EndIf
//
dbSelectArea("SD2")
dbSetOrder(3)
If !dbSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
	MsgStop(STR0080+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0081+VV0->VV0_NUMNFI+" / "+VV0->VV0_SERNFI,STR0061)
	Return(.f.)
EndIf
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Ponto de Entrada para validacao do Cancelamento de NF |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("VX001CNF")
	lRet := ExecBlock("VX001CNF",.f.,.f.)
	If !lRet
		Return.f.
	EndIf
EndIf
//
// ARMAZENA A NF DE ORIGEM PARA ALTERAR STATUS CASO HAJA CANCELAMENTO (cOpeMov = "4")
cChaveOri := SD2->D2_NFORI+SD2->D2_SERIORI
//
For nCntFor = 1 to len(acols)
	n = nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	//
	// VERIFICAR SE A MOVIMENTACAO SELECIONADA EH A ULTIMA
	//
	FGX_AMOVVEI(xFilial("VV1"),aCols[nCntFor,FG_POSVAR("VVA_CHASSI")])
	DBSelectArea("VV1")
	DBSetOrder(2)
	DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VVA_CHASSI")])
	If !(FM_PILHA("VEIXA040")) 
		aUltMov := FGX_VEIMOVS( aCols[nCntFor,FG_POSVAR("VVA_CHASSI")] , , )
		If len(aUltMov) > 0
			If aUltMov[1,1] == "E" .or. aUltMov[1,2] <> VV0->VV0_FILIAL .or. aUltMov[1,3] <> VV0->VV0_NUMTRA
				MsgStop(STR0023+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0045+" "+STR0046+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0047+": "+Alltrim(VV1->VV1_CHASSI),STR0027)//Impossivel Continuar ### Um dos veiculos constantes da nota fiscal sofreu movimentacao # posterior a sua emissao. # chassi             ### atencao
				Return .f.
			EndIf
		EndIf
	EndIf
Next
//################################################################
//# Cancela o documento de saida                                 #
//################################################################
aRegSD2 := {}
aRegSE1 := {}
aRegSE2 := {}

aLocaliz := {}
if GetNewPar("MV_LOCVZL","N")=="S"  // USA LOCALIZACAO DE VEICULOS
	For nCntFor = 1 to len(acols)
		n = nCntFor
		// pula registros deletados
		If aCols[nCntFor,len(aHeader)+1]
			loop
		EndIf
		//
		// VERIFICAR SE A MOVIMENTACAO SELECIONADA EH A ULTIMA
		//
		DBSelectArea("VV1")
		DBSetOrder(2)
		DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VVA_CHASSI")])
		//
		FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
		//
		if DBSeek(xFilial("VZL")+SB1->B1_LOCPAD+SB5->B5_LOCALI2)
			if VZL->VZL_QTDATU < VZL->VZL_QTDMAX
				reclock("VZL",.f.)
				VZL->VZL_QTDATU := VZL->VZL_QTDATU + 1
				msunlock()
				aAdd(aLocaliz,{SB1->B1_COD,SB1->B1_LOCPAD,SB5->B5_LOCALI2})
			else
				aRet := {}
				aParamBox := {}
				MsgInfo(STR0062,STR0061)
				VZL->(DBSetOrder(1))
				aAdd(aParamBox,{1,STR0063,Space(2),"","VZL->(DBSeek(xFilial('VZL')+MV_PAR01))","NNR","",0,.F.})
				aAdd(aParamBox,{1,STR0064,Space(15),"","VZL->(DBSeek(xFilial('VZL')+MV_PAR01+MV_PAR02))","VZL","",0,.F.})
				lContinua := .f.
				while !lContinua
					If !(ParamBox(aParamBox,STR0065+Alltrim(VV1->VV1_CHASSI),@aRet))
						if MsgYesNo(STR0066,STR0061)
							aAdd(aLocaliz,{SB1->B1_COD,"",""})
							lContinua := .t.
						endif
					else
						DBSelectArea("VZL")
						DBSetOrder(1)
						if DBSeek(xFilial("VZL")+SB1->B1_LOCPAD+SB5->B5_LOCALI2)
							if VZL->VZL_QTDATU < VZL->VZL_QTDMAX
								aAdd(aLocaliz,{SB1->B1_COD,aRet[1],aRet[2]})
								lContinua := .t.
							endif
						endif
					Endif
				enddo
			endif
		endif
	next
endif

if GetNewPar("MV_LOCVZL","N")=="S" .and. Len(aLocaliz) > 0  // USA LOCALIZACAO DE VEICULOS    TODO: LOCALIZACAO
	nIndLocali := 0
	For nCntFor = 1 to len(acols)
		n = nCntFor
		// pula registros deletados
		If aCols[nCntFor,len(aHeader)+1]
			loop
		EndIf
		nIndLocali++
		DBSelectArea("SB1")
		DBSetOrder(1)
		DBSeek(xFilial("SB1")+aLocaliz[nIndLocali,1])
		//
		DBSelectArea("SB5")
		DBSetOrder(1)
		DBSeek(xFilial("SB5")+SB1->B1_COD)
		//
		DBSelectArea("VZL")
		DBSetOrder(1)
		if DBSeek(xFilial("VZL")+aLocaliz[nIndLocali,2]+aLocaliz[nIndLocali,3])
			if VZL->VZL_QTDATU < VZL->VZL_QTDMAX
				reclock("VZL",.f.)
				VZL->VZL_QTDATU := VZL->VZL_QTDATU + 1
				msunlock()
			else
				MsgStop(STR0067+aLocaliz[nIndLocali,2]+"/"+aLocaliz[nIndLocali,3]+STR0068,STR0061)
				return .f.
			endif
		endif
	next
endif

lMsErroAuto := .f.

dbSelectArea("SF2")
dbSetOrder(1)
dbSeek(xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
//
cNumTit := SF2->F2_DUPL
cPrefNF := SF2->F2_PREFIXO

// Transmite o Cancelamento para o SEFAZ automaticamente
conout("VEIXX001 - ENTROU NO PROCESSO DE CANCELAMENTO:  "+Dtoc(dDataBase)+" - "+Time())
If lNFeCancel
	If !FGX_STATF2("D",VV0->VV0_SERNFI,VV0->VV0_NUMNFI,VV0->VV0_CODCLI,VV0->VV0_LOJA,"S") // verifica se NF foi Deletada
		//################################################################
		//# VerIfica se o estorno do documento de saída pode ser feito   #
		//################################################################
		If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
			// Alias da Tabela SF2,Recno do SF2, Array com os registro do SD2,
			// Array com os registro do SE1, Array com os registro do SE2 )
			//
			//################################################################
			//# Estorna o documento de saida                                 #
			//################################################################
			PERGUNTE("MTA521",.f.)
			conout("VEIXX001 - CHAMOU O MADELNFS:  "+Dtoc(dDataBase)+" - "+Time())
			If !SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1),(mv_par03 == 1), (mv_par04 == 1)))
				Return(.f.)
			Endif
			conout("VEIXX001 - RETONO POSITIVO DO MADELNFS:  "+Dtoc(dDataBase)+" - "+Time())
		Else
			//Nao pode ser excluida.
			Return(.f.)
		EndIf          
		If !FGX_STATF2("V",VV0->VV0_SERNFI,VV0->VV0_NUMNFI,VV0->VV0_CODCLI,VV0->VV0_LOJA,"S") /// Verifica STATUS da NF no SEFAZ
			Return(.f.)
		Endif
	Endif
Endif

BEGIN TRANSACTION

If !lNFeCancel

	//################################################################
	//# VerIfica se o estorno do documento de saída pode ser feito   #
	//################################################################
	If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
		// Alias da Tabela SF2,Recno do SF2, Array com os registro do SD2,
		// Array com os registro do SE1, Array com os registro do SE2 )
		//
		//################################################################
		//# Estorna o documento de saida                                 #
		//################################################################
		PERGUNTE("MTA521",.f.)
		SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,;
		(mv_par01 == 1), (mv_par02 == 1),;
		(mv_par03 == 1), (mv_par04 == 1)))
	Else
		//Nao pode ser excluida.
		lMsErroAuto:= .T.
		Return(.f.)
	EndIf

Endif
	
conout("VEIXX001 - INICIOU O PROCESSO DE EXCLUSÃO DO PEDIDO DE VENDAS:  "+Dtoc(dDataBase)+" - "+Time())
dbSelectArea("SC5")
dbSetOrder(1)
If dbSeek(xFilial("SC5")+VV0->VV0_NUMPED)
	//
	aMata410Cab   := {{"C5_NUM"		, VV0->VV0_NUMPED,Nil}}   //Numero do pedido SC5
	//
	SC6->(dbSetOrder(1))
	SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))
	//
	While SC6->(!Eof() .And. C6_FILIAL == xFilial("SC6")) ;
		.And. SC6->C6_NUM == SC5->C5_NUM
		//
		aMata410Itens := {	{"C6_NUM"	, VV0->VV0_NUMPED,Nil},;
		{"C6_ITEM"	, SC6->C6_ITEM , Nil}}   //Numero do Pedido SC6
		DBSkip()
	enddo
	// Exclui Liberacao
	SC9->(dbSetOrder(1))
	SC9->(dbSeek(xFilial("SC9")+VV0->VV0_NUMPED))
	While !SC9->(Eof()) .And. xFilial('SC9') == SC9->C9_FILIAL ;
		.and. VV0->VV0_NUMPED == SC9->C9_PEDIDO
		SC9->(a460Estorna())
		SC9->(dbSkip())
	EndDo
	//
	MSExecAuto({|x,y,z|Mata410(x,y,z)},aMata410Cab,{aMata410Itens},5)
	//
	If lMsErroAuto
		DisarmTransaction()
		Return .f.
	EndIf
EndIf
//
If !Empty(cNumTit)
	dbSelectArea("SE1")
	dbSetOrder(1)
	If dbSeek(xFilial("SE1")+cPrefNF+cNumTit)
		aParcelas := {}
		while !Eof() .and. SE1->E1_FILIAL == xFilial('SE1') .and. SE1->E1_PREFIXO == cPrefNF .and. SE1->E1_NUM == cNumTit
			AADD(aParcelas,{;
			{"E1_PREFIXO" ,E1_PREFIXO ,nil},;
			{"E1_NUM"     ,E1_NUM     ,nil},;
			{"E1_PARCELA" ,E1_PARCELA ,nil},;
			{"E1_TIPO"    ,E1_TIPO    ,nil},;
			{"E1_NATUREZA",E1_NATUREZA,nil},;
			{"E1_CLIENTE" ,E1_CLIENTE ,nil},;
			{"E1_LOJA"    ,E1_LOJA    ,nil},;
			{"E1_EMISSAO" ,E1_EMISSAO ,nil},;
			{"E1_VENCTO"  ,E1_VENCTO  ,nil},;
			{"E1_VENCREA" ,E1_VENCREA ,nil},;
			{"E1_VALOR"   ,E1_VALOR   ,nil},;
			{"E1_NUMBOR"  ,E1_NUMBOR  ,Nil},;
			{"E1_DATABOR" ,E1_DATABOR ,Nil},;
			{"E1_PORTADO" ,E1_PORTADO ,Nil},;
			{"E1_SITUACA" ,E1_SITUACA ,Nil}})
			dbSelectArea("SE1")
			dbSkip()
		Enddo
		//
		pergunte("FIN040",.F.)
		For cont2 := 1 to len(aParcelas)
			lMsErroAuto := .f.
			MSExecAuto({|x,y| FINA040(x,y)},aParcelas[cont2],5)
			If lMsErroAuto
				DisarmTransaction()
				Return .f.
			EndIf
		Next
	EndIf
	//	
	dbSelectArea("SA1")
	dbSetOrder(1)
	DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
	//
	dbSelectArea("SA2")
	dbSetOrder(3)
	If DbSeek(xFilial("SA2")+SA1->A1_CGC)
		//
		dbSelectArea("SA2")
		dbSetOrder(1)
		//
		dbSelectArea("SE2")
		dbSetOrder(6)
		If dbSeek(xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefNF+cNumTit)           
			//
			aParcelas := {}
			while ! Eof() .and. SE2->E2_FILIAL == xFilial('SE2') .and. SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == SA2->A2_COD+SA2->A2_LOJA+cPrefNF+cNumTit
			
					AADD(aParcelas,{{"E2_PREFIXO" ,E2_PREFIXO ,nil},;
					{"E2_NUM"     ,E2_NUM     ,nil},;
					{"E2_PARCELA" ,E2_PARCELA ,nil},;
					{"E2_TIPO"    ,E2_TIPO    ,nil},;
					{"E2_NATUREZA",E2_NATUREZA,nil},;
					{"E2_FORNECE" ,E2_FORNECE ,nil},;
					{"E2_LOJA"    ,E2_LOJA    ,nil},;
					{"E2_EMISSAO" ,E2_EMISSAO ,nil},;
					{"E2_VENCTO"  ,E2_VENCTO  ,nil},;
					{"E2_VENCREA" ,E2_VENCREA ,nil},;
					{"E2_VALOR"   ,E2_VALOR   ,nil},;
					{"E2_NUMBOR"  ,E2_NUMBOR  ,Nil} })
					
				dbSelectArea("SE2")
				dbSkip()
			Enddo
	
			dbSelectArea("SE2")
			dbSetOrder(1)
			//
			pergunte("FIN050",.F.)
			For cont2 := 1 to len(aParcelas)
				lMsErroAuto := .f.
				MSExecAuto({|x,y,z| FINA050(x,y,z)},aParcelas[cont2],,5)
				If lMsErroAuto
					DisarmTransaction()
					Return .f.
				EndIf
			Next
		EndIf
	EndIf
EndIf
//
// SINALIZA O CANCELAMENTO NO VV0
//
DBSelectArea("VV0")
reclock("VV0",.f.)
VV0->VV0_SITNFI := "0"
VV0->VV0_STATUS := "C"
conout("VEIXX001 - VOLTOU STATUS DO VEICULO:  "+Dtoc(dDataBase)+" - "+Time())
if cOpeMov $ "6/7"  // RETORNO DE REMESSA/ RETORNO DE CONSIGNADO
	// ATUALIZA O STATUS DA NF PARA DEVOLVIDA
	DBSelectArea("VVF")
	dbClearFilter()
	DBSetOrder(6)
	if DBSeek(xFilial("VVF")+cChaveOri)
	    RecLock("VVF",.F.)		    
		VVF->VVF_SITNFI := "1"
		MsUnlock()
	Endif
	FilBrowse('VVF',{},'VVF->VVF_OPEMOV=="4" .AND. VVF->VVF_SITNFI=="1" .AND. !Empty(VVF->VVF_NUMNFI) .AND. xFilial("VVF")==VVF->VVF_FILIAL .AND. VXA017FIL()')
Endif
msunlock()
//
END TRANSACTION
//
// ###############################################
// ATUALIZA O STATUS DO VEICULO                  #
// ###############################################
For nCntFor = 1 to len(acols)
	n = nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	// ALTERA STATUS DOS VEICULOS
	FGX_AMOVVEI(xFilial("VV1"),aCols[nCntFor,FG_POSVAR("VVA_CHASSI")])
Next
//
if cOpeMov == "4" // DEVOLUCAO
	// ATUALIZA O STATUS DA NF DE "DEVOLVIDA" PARA "VALIDA"
	cSitNF := "1"
	nContVVG := 0
	nContVV1 := 0
	DBSelectArea("VVF")
	DBSetOrder(6)
	if DBSeek(xFilial("VVF")+cChaveOri)
		if !FG_Seek("VVG","VVF->VVF_TRACPA",1,.f.)
			Help(" ",1,"ARQITEINCO")
		Endif
		while !eof() .and. xFilial("VVG")+VVF->VVF_TRACPA == VVG->VVG_FILIAL + VVG->VVG_TRACPA
			nContVVG++
			if !FG_Seek("VV1","VVG->VVG_CHASSI",2,.f.)
				Help(" ",1,"VEINFNEXCD")
				nOpca := 0
				Return (.f.)
			Endif
			
			if VV1->VV1_ULTMOV == "E" .and. VV1->VV1_FILENT == VVF->VVF_FILIAL .and. VV1->VV1_TRACPA == VVF->VVF_TRACPA
				nContVV1++
			Endif
			
			DBSelectArea("VVG")
			DBSkip()
		enddo
		If nContVV1 == nContVVG
			cSitNF := "1"
		Else
			cSitNF := "3"
		Endif
		
		reclock("VVF",.f.)
		VVF->VVF_SITNFI := cSitNF
		msunlock()
	endif
endif
//
dbSelectArea("VV0")
//
if lMostraMsg
	FMX_TELAINF( "1" , { { Alltrim(VV0->VV0_SERNFI) , Alltrim(VV0->VV0_NUMNFI) , STR0048 } } ) // "CANCELADO"
endif
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX001DLIN   | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001DLIN()
//
If aCols[n,Len(aCols[n])]
	aCols[n,Len(aCols[n])] := .f.
Else
	aCols[n,Len(aCols[n])] := .t.
EndIf
If lAtuFiscal // Atualiza Fiscal
	MaFisDel(n,aCols[n,Len(aCols[n])])
EndIf
//
VX001FIELDOK()
//
oGetDados:obrowse:SetFocus()
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX001KEYF4  | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Chamada da tecla de atalho <F4>. Executa comandos dependen-  |##
##|          | do do campo selecionado ( ReadVar() ).                       |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001KEYF4()
If ReadVar() == "M->VVA_CHASSI"
	DBSelectArea("VV1")
	DBSetOrder(2)
	If DBSeek(xFilial("VV1")+M->VVA_CHASSI)
		VXA010A("VV1",RecNo(),3)
	EndIf
EndIf
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX001ABORT  | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Janela de aborto. Podera ser chamada apenas dentro de tran-  |##
##|          | sacoes. Exibe uma mensagem e seta o lMsErroAuto para .t.     |##
##|          | caso o usuario tenha optado por abortar a operacao           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001ABORT()
//
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
##|Fun‡„o    |VX001BRWNOME| Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Browse do Nome do Cliente/Fornecedor - Depependendo do tipo  |##
##|          | de operacao a funcao retorna o cliente ou o fornecedor.      |##
##|          | As operacoes de remessa, consignacao e devolucao tomam o     |##
##|          | fornecedor ao inves do cliente. As demais utilizam o cliente |##
##|          | (padrao).                                                    |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001BRWNOME()
Local cAlias := Alias()
Local nRecSA1 := SA1->(RecNo())
Local nRecSA2 := SA2->(RecNo())
Local cNome
//
If VV0->VV0_OPEMOV == "4"  .or. (cCliForA <> "C")
	DBSelectArea("SA2")
	DBSetOrder(1)
	DBSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
	cNome :=  SA2->A2_NREDUZ
Else
	DBSelectArea("SA1")
	DBSetOrder(1)
	DBSeek(xFilial("SA1")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
	cNome :=  SA1->A1_NREDUZ
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
##|Fun‡„o    |VX001RECALC | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Recalculo das Variaveis Fiscais                              |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001RECALC()
Local nCntAcols
Local nCntAcorc
//
If FM_PILHA("VEIXX002") // Retornar .T. quando for Atendimento de Veiculos
	Return .t.
EndIf
//
If lAtuFiscal // Atualiza Fiscal
	// A ROTINA ATUALIZA OS CAMPOS DA INTEGRACAO FISCAL
	For nCntAcols = 1 to len(acols)
		n = nCntAcols
		If MaFisFound("IT",n)
			/*CI 010134 - NESSA FUNÇÃO, DEVE ATUALIZAR APENAS OS VALORES DE IMPOSTOS*/
			If (cPaisLoc == "BRA")
				M->VVA_ALIIPI := acols[n,FG_POSVAR("VVA_ALIIPI")] := MaFisRet(n,"IT_ALIQIPI")
				M->VVA_VBAICM := aCols[n,FG_POSVAR("VVA_VBAICM")] := MaFisRet(n,"IT_BASEICM")
				M->VVA_ALIICM := aCols[n,FG_POSVAR("VVA_ALIICM")] := MaFisRet(n,"IT_ALIQICM")
				M->VVA_ICMVEN := aCols[n,FG_POSVAR("VVA_ICMVEN")] := MaFisRet(n,"IT_VALICM")
				M->VVA_PISVEN := aCols[n,FG_POSVAR("VVA_PISVEN")] := MaFisRet(n,"IT_VALPS3") // está gravando o ST no campo.... ok...
				M->VVA_COFVEN := aCols[n,FG_POSVAR("VVA_COFVEN")] := MaFisRet(n,"IT_VALCF3") // está gravando o ST no campo.... ok...
			endif
			//
			// ATUALIZA O FOLDER 1 (INFORMACOES DA NF)
			//
			for nCntAcorc := 1 to Len(aOrc)
				aOrc[nCntAcorc,3] := &(aOrc[nCntAcorc,1])
			next
			if !lVX001Auto
				olBox:nAt := 1
				olBox:SetArray(aOrc)
				olBox:bLine := { || {  aOrc[olBox:nAt,2],;
				FG_AlinVlrs(Transform(aOrc[olBox:nAt,3],"@E 999,999,999.99")) }}
				olBox:SetFocus()
				olBox:Refresh()
			endif
			//
			// ATUALIZA COMO PAGAR
			VX001ATUCP()
			//
		EndIf
		//
	next
EndIf
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX001TES    | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Verificacao de passagem do TES para MAFISREF                 |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001VTES()
Local lRet := .t.
If lAtuFiscal // Atualiza Fiscal
	lRet := .f.
	DBSelectArea("SF4")
	DBSetOrder(1)
	if dbSeek(xFilial("SF4")+M->VVA_CODTES)
		lRet := MaFisRef("IT_TES","VX001",M->VVA_CODTES)
	EndIf
endif
return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |  VX001VNFE | Autor |  BOBY-Antonio         | Data | 31/08/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Preenchiento automatico de valores trazidos da NF de entrada.|##
##|          | FNC 18966                                                    |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001VNFE()

Local aArea := GetArea()
Local lRet  := .T.

DBSelectArea("VVG")
DBSetOrder(2)
If DBSeek(xFilial("VVG")+aCols[n,FG_POSVAR("VVA_CHAINT")])
	aCols[n,FG_POSVAR("VVA_VALVDA")] := M->VVA_VALVDA:= VVG->VVG_VALUNI
	lRet := .T.
EndIf

RestArea(aArea)

Return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |  VX001RB1  | Autor |  Luis Delorme         | Data | 12/11/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Funcao para trigeer do tes inteligente (ver sx7)             |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001RB1()
	FGX_VV1SB1("CHAINT", M->VVA_CHAINT , /* cMVMIL0010 */ , /* cGruVei */ )
return SB1->B1_COD
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX001MFORTE  ºAutor  ³ Rubens         º Data ³  21/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Calcula Valores em Moeda Forte                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX001MFORTE(cChaInt)

// Posiciona no Veiculo para Procurar a Transacao de Entrada
VV1->(dbSetOrder(1))
VV1->(dbSeek(xFilial("VV1") + cChaInt ))

VVA->VVA_VMFMOV := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_VALMOV}} )
VVA->VVA_CMFVDE := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_COMVDE}} )
VVA->VVA_CMFGER := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_COMGER}} )
VVA->VVA_SMFVIA := FG_CalcMF({ {FG_RtDtCV("SGV",VV1->VV1_CODMAR,M->VV0_DATMOV),VVA->VVA_SEGVIA} })
VVA->VVA_VMFASS := FG_CalcMF({ {FG_RtDtCV("ASS",VV1->VV1_CODMAR,M->VV0_DATMOV),VVA->VVA_VALASS} })
VVA->VVA_RMFTEC := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_RECTEC}} )
VVA->VVA_BMFFAB := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_BONFAB}} )
If VVA->(FieldPos("VVA_BMFREG"))>0 .and. VVA->(FieldPos("VVA_BONREG"))>0
	VVA->VVA_BMFREG := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_BONREG}} )
EndIf
If VVA->(FieldPos("VVA_BMFCON"))>0 .and. VVA->(FieldPos("VVA_BONCON"))>0
	VVA->VVA_BMFCON := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_BONCON}} )
EndIf
VVA->VVA_VMFVDA := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_VALVDA}} )
VVA->VVA_RMFVEI := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_RECVEI}} )
VVA->VVA_IMFVEN := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_ICMVEN}} )
VVA->VVA_PMFVEN := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_PISVEN}} )
VVA->VVA_CMFVEN := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_COFVEN}} )
VVA->VVA_IMFRTE := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_ISSRTE}} )
VVA->VVA_PMFRTE := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_PISRTE}} )
VVA->VVA_PMFBFB := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_PISBFB}} )
VVA->VVA_IMFBFB := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_ISSBFB}} )
VVA->VVA_VMFVEI := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_VCAVEI}} )
VVA->VVA_RMFCUS := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_REDCUS}} )
VVA->VVA_VMFFRE := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_VALFRE}} )
VVA->VVA_AMFSSO := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_ACESSO}} )
VVA->VVA_DMFVEI := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_DESVEI}} )
VVA->VVA_DMFCLI := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_DESCLI}} )
VVA->VVA_VMFREV := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_VALREV}} )
VVA->VVA_JMFEST := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_JUREST}} )
VVA->VVA_FMFTOT := VVA->VVA_VMFMOV+VVA->VVA_CMFCOT+VVA->VVA_CMFCTP+VVA->VVA_RMFTEC+VVA->VVA_BMFFAB
VVA->VVA_TMFCUS := FG_FORMULA(GetNewPar("MV_TMFCUFN","VVA->VVA_VMFVEI-VVA->VVA_RMFCUS+VVA->VVA_JMFEST+VVA->VVA_VMFFRE+VVA->VVA_AMFSSO+VVA->VVA_VMFSCO+VVA->VVA_PMFENT+VVA->VVA_CMFENT"))
VVA->VVA_TMFIMP := VVA->VVA_IMFVEN+VVA->VVA_IMFCVD+VVA->VVA_PMFVEN+VVA->VVA_CMFVEN+VVA->VVA_IMFRTE+VVA->VVA_PMFRTE+VVA->VVA_IMFBFB+VVA->VVA_PMFBFB
VVA->VVA_LMFBRU := VVA->VVA_FMFTOT-VVA->VVA_TMFIMP-VVA->VVA_VMFVEI-VVA->VVA_VMFFRE
VVA->VVA_LMFLQ1 := VVA->VVA_LMFBRU-VVA->VVA_JMFEST-VVA->VVA_AMFSSO-VVA->VVA_VMFSCO-VVA->VVA_DMFCLI-VVA->VVA_SMFVIA-VVA->VVA_VMFASS-VVA->VVA_VMFREV-VVA->VVA_DMFVEI-VVA->VVA_AMFIMP-VVA->VVA_CMFVDE-VVA->VVA_CMFGER-VVA->VVA_CMFPAT //LUCRO MARGINAL
VVA->VVA_LMFLQ2 := VVA->VVA_LMFLQ1-VVA->VVA_DMFFIX+(VVA->VVA_RMFCUS+VVA->VVA_RMFVEI-VVA->VVA_DMFFIN) //LAIR

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX001CLIFOR  ºAutor  ³ Thiago         º Data ³  10/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao do campo VV0_CLIFOR.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX001CLIFOR()
//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Saida por Venda   ou   Saida por Remessa   ou   Saida por Transferencia   ou   Saida por Consignacao //
//////////////////////////////////////////////////////////////////////////////////////////////////////////
If FM_PILHA("VEIXA011") .or. FM_PILHA("VEIXA013") .or. FM_PILHA("VEIXA014") .or. FM_PILHA("VEIXA015")
	If ReadVar() == "M->VV0_CLIFOR"
		If !Empty(M->VV0_CLIFOR)
			cCliForA := M->VV0_CLIFOR
		Endif              
	Endif

	if cCliForA == "C" //cOpeMov $ "35" .and. cCliForA == "C"
		oSayE18:lVisible := .f.
		oSayE21:lVisible := .t.
		oGetE21:cf3 := "SA1"
	Else
		oSayE21:lVisible := .f.
		oSayE18:lVisible := .t.
		oGetE21:cf3 := "SA2"
	Endif        
Endif
Return(.t.)
           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX001VALCLI  ºAutor  ³ Thiago         º Data ³  14/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao do campo Loja do cliente.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX001VALCLI()
           
If VV0->(FieldPos("VV0_CLIENT")) <> 0
	if Empty(M->VV0_CLIENT) .or. Empty(M->VV0_LOJENT)    
		M->VV0_CLIENT := M->VV0_CODCLI
		M->VV0_LOJENT := M->VV0_LOJA 
	Endif
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VXX001TIT  ºAutor  ³ Andre Luis Almeida º Data ³  14/03/17 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao do campo Loja do cliente.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXX001TIT() // Gerar Financeiro
Local lRet      := .t.
Local _nRecSA1  := 0
Local cSQLAlias := "SQLVS9"
Local cQuery    := ""
Local cNumBord  := ""
Local dDatBord  := cTod("")
Local cPrefVEI  := GetNewPar("MV_PREFVEI","VEI")
Local aTitulo   := {}
//
// COMECAR NOVA TRANSACAO PARA O FINANCEIRO
BEGIN TRANSACTION
//
SF2->( DbSetOrder(1) )
SF2->( DbSeek( xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI ) )
//
SE4->( DbSetOrder(1) )
SE4->( DbSeek( xFilial("SE4") + SF2->F2_COND ) )
//
If Alltrim(SE4->E4_TIPO) == "A" // Negociada
//
	SA6->( DbSetOrder(1) )
	SA6->( DbSeek( xFilial("SA6") + VV0->VV0_CODBCO ) )
	If SA6->A6_BORD == "0"
		cNumBord := "BCO"+SA6->A6_COD
		dDatBord := dDataBase
	EndIf
	//
	SA1->( DbSetOrder(1) )
	SA1->( DbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
	_nRecSA1 := SA1->( Recno() )//salva posicao SA1
	//
	SA3->( DbSetOrder(1) )
	SA3->( MsSeek( xFilial("SA3") + VV0->VV0_CODVEN ) )
	//
	cQuery := "SELECT VS9.VS9_TIPPAG , VS9.VS9_DATPAG , VS9.VS9_VALPAG , VS9.VS9_REFPAG "
	cQuery += "  FROM "+RetSQLName("VS9")+" VS9 "
	cQuery += " WHERE VS9.VS9_FILIAL = '"+xFilial("VS9")+"'"
	cQuery += "   AND VS9.VS9_NUMIDE = '"+VV0->VV0_NUMTRA+"'"
	cQuery += "   AND VS9.VS9_TIPOPE = 'V'"
	cQuery += "   AND VS9.VS9_VALPAG > 0 "
	cQuery += "   AND VS9.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->( Eof() )
		aTitulo := {{"E1_PREFIXO" ,SF2->F2_PREFIXO									,Nil},;
					{"E1_NUM"     ,SF2->F2_DOC 										,Nil},;
					{"E1_PARCELA" ,Alltrim((cSQLAlias)->( VS9_REFPAG ))				,Nil},;
					{"E1_TIPO"    ,(cSQLAlias)->( VS9_TIPPAG )						,Nil},;
					{"E1_NATUREZ" ,VV0->VV0_NATFIN									,Nil},;
					{"E1_SITUACA" ,IIf(!Empty(VV0->VV0_CODBCO),"1","0")				,Nil},;
					{"E1_CLIENTE" ,SA1->A1_COD										,Nil},;
					{"E1_LOJA"    ,SA1->A1_LOJA										,Nil},;
					{"E1_EMISSAO" ,dDataBase										,Nil},;
					{"E1_VENCTO"  ,stod((cSQLAlias)->( VS9_DATPAG ))				,Nil},;
					{"E1_VENCREA" ,DataValida(stod((cSQLAlias)->( VS9_DATPAG )))	,Nil},;
					{"E1_VALOR"   ,(cSQLAlias)->( VS9_VALPAG )						,Nil},;
					{"E1_NUMBOR"  ,cNumBord											,Nil},;
					{"E1_DATABOR" ,dDatBord											,Nil},;
					{"E1_PORTADO" ,VV0->VV0_CODBCO									,Nil},;
					{"E1_PREFORI" ,cPrefVEI 										,Nil},;
					{"E1_VEND1"  , SA3->A3_COD										,nil},;
					{"E1_COMIS1" , SA3->A3_COMIS									,nil},;
					{"E1_BASCOM1", (cSQLAlias)->( VS9_VALPAG )						,nil},;
					{"E1_PEDIDO" , VV0->VV0_NUMPED									,nil},;
					{"E1_NUMNOTA", SF2->F2_DOC										,nil},;
					{"E1_ORIGEM" , "MATA460"										,nil},;
					{"E1_SERIE"  , SF2->F2_SERIE									,nil} }
		//
		lMsErroAuto := .f.
		//
		pergunte("FIN040",.F.)
		MSExecAuto({|x| FINA040(x)},aTitulo)
		SA1->( Dbgoto( _nRecSA1 ) )	//volta posicao SA1
		//
		If lMsErroAuto
			DisarmTransaction()
			RollBackSxE()
			MostraErro()
			lRet := .f.
			Exit
		EndIf
		//
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	DbSelectArea("VV0")
//
EndIf
//
END TRANSACTION
//

If lRet // Gerou Financeiro
	DbSelectArea("VV0")
	If ( VV0->(FieldPos("VV0_GERFIN")) > 0 ) // Campo que controla se gerou FINANCEIRO (Titulos)
		RecLock("VV0",.f.)
			VV0->VV0_GERFIN := "1"
		MsUnLock()
	EndIf
EndIf
//
Return lRet

/*/{Protheus.doc} VX00101_ClienteValido
	Valida se o destino é do grupo de empresas usando o documento cpf/cnpj

	@type function
	@author Vinicius Gati
	@since 05/12/2017
/*/
Function VX00101_ClienteValido(cCodCli, cLoja, cTipo, cM0CGC, lVldCGC)
Default lVldCGC := .f.
	if lVldCGC .and. Empty(cM0CGC)
		return .f.
	endif
	If cTipo == "C"
		DBSelectArea("SA1")
		DBSetOrder(1)
		If DbSeek(xFilial("SA1")+cCodCli+Alltrim(cLoja))
			If lVldCGC
				If FM_PILHA("VEIXA040") // Agrega e Desagrega
					If Empty(cLoja)
						return .t.
					EndIf
					If Alltrim(SA1->A1_CGC) == Alltrim(cM0CGC) // Precisa ser o mesmo CNPJ da Filial Logada
						return .t.
					EndIf
				Else
					DbSelectArea("SA1")
					DBSetOrder(3)
					DbSeek(xFilial("SA1")+LEFT(SA1->A1_CGC, 8))
					while ! EOF()  .AND. LEFT(SA1->A1_CGC, 8) == LEFT(cM0CGC, 8)
						if Alltrim(SA1->A1_CGC) != Alltrim(cM0CGC) .AND. SA1->A1_COD == cCodCli
							SA1->(DBSetOrder(1))
							return .t.
						endif
						dbskip()
					enddo
					SA1->(DBSetOrder(1))
				EndIf
			Else
				return .t.
			EndIF
		else
			Return .f.
		EndIf
	Else
		DBSelectArea("SA2")
		DBSetOrder(1)
		If DbSeek(xFilial("SA2")+cCodCli+Alltrim(cLoja))
			If lVldCGC
				If FM_PILHA("VEIXA040") // Agrega e Desagrega
					If Empty(cLoja)
						return .t.
					EndIf
					If Alltrim(SA2->A2_CGC) == Alltrim(cM0CGC) // Precisa ser o mesmo CNPJ da Filial Logada
						return .t.
					EndIf
				Else
					DbSelectArea("SA2")
					DBSetOrder(3)
					DbSeek(xFilial("SA2")+LEFT(SA2->A2_CGC, 8))
					while ! EOF() .AND. LEFT(SA2->A2_CGC, 8) == LEFT(cM0CGC, 8)
						if Alltrim(SA2->A2_CGC) != Alltrim(cM0CGC) .AND. SA2->A2_COD == cCodCli
							SA2->(DBSetOrder(1))
							return .t.
						endif
						dbskip()
					enddo
					SA2->(DBSetOrder(1))
				EndIf
			Else
				return .t.
			EndIf
		else
			Return .f.
		EndIf
	EndIf
Return .F.

/*/{Protheus.doc} VX001VLDESTQ
	Valida Estoque dos Veiculos na aCols quando o TES movimentar Estoque

	@type function
	@author Andre Luis Almeida
	@since 16/04/2018
/*/
Static Function VX001VLDESTQ(nLinha,lMsg)
Local lRet        := .t.
Local ni          := 0
Local nTotal      := 0
Local nPVVACHASSI := FG_POSVAR("VVA_CHASSI")
Local nPVVACODTES := FG_POSVAR("VVA_CODTES")
Default nLinha    := 0
Default lMsg      := .t.
If nLinha <> 0 // Validar linha especifica da aCols
	nTotal := nLinha
Else // Validar TODAS as linhas da aCols
	nLinha := 1
	nTotal := len(aCols)
EndIf
If FGX_USERVL(xFilial("VAI"),__cUserID,"VAI_ESTNEG","<>","1") // nao Permite Faturar sem Estoque
	VV1->(DBSetOrder(2))
	SB1->(DBSetOrder(7))
	SB2->(DbSetOrder(1))
	SF4->(DBSetOrder(1))
	For ni := nLinha to nTotal
		If !aCols[ni,len(aHeader)+1]
			SF4->(MsSeek(xFilial("SF4")+aCols[ni,nPVVACODTES]))
			If SF4->F4_ESTOQUE == "S"
				VV1->(MsSeek(xFilial("VV1")+aCols[ni,nPVVACHASSI]))
				FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
				If !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)) .or. SB2->B2_QATU <= 0 //FILIAL+PRODUTO+LOCAL
					If lMsg // Mostra Mensagem ?
						// STR0088 - Veiculo/Máquina não esta no estoque ou pertence a outra filial!
						// STR0089 - Verifique o estoque do mesmo ou utilize um TES que não movimenta estoque.
						ShowHelpDlg("VX001VLDESTQ",	{STR0088+CHR(13)+CHR(10)+CHR(13)+CHR(10)+VV1->VV1_CHASSI},,{STR0089})
					EndIf
					lRet := .f.
				EndIf
			EndIf
		EndIf
	Next
	SB1->(DBSetOrder(1))
EndIf
Return lRet

/*/{Protheus.doc} VX00102_SelecionaValidEnchoic
	Seleciona qual validação deverá usar, de acordo com a rotina que está chamando
	Utilizado no valid dos campos VV0_CLIENT e VV0_LOJENT
	@type function
	@author Matheus Teixeira Silva
	@since 30/11/2020
/*/
Function VX00102_SelecionaValidEnchoic()

If FM_PILHA("VEIXX001")
	VX001VLDENC()
ElseIf FM_PILHA("VEIXX002") 
	VX002VLDENC()
EndIf

Return .T.
