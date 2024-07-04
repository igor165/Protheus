#include "Protheus.ch"
#include "VEIXX000.CH"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | VEIXX000   | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Entrada de Veiculos                                          |##
##|          | Executa a entrada de veiculos por todas as modalidades.      |##
##|          | Possui interface de integracao.                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/

////////////////////////////////////////
//       Operacoes (VVF_OPEMOV)       //
//                                    //
//  0=Normal                          //
//  1=Ped.Fabrica                     //
//  2=Remessa                         //
//  3=Transferencia                   //
//  4=Consignacao                     //
//  5=Devolucao                       //
//  6=Frete                           //
//  7=Retorno de Remessa              //
//  8=Retorno de Consignacao          //
//                                    //
////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// xTIPDOC -> "1" = Gera nota fiscal de Entrada - SD1/SF1                                                               //
//            "2" = Gera movimentacao interna - SD3                                                                     //
//            "3" = Nao gera movimentacao de entrada Back Office (Nota Fiscal de Entrada / Mov. Interna de Estoque)     //
//                  Opcao utilizada na integração com CAOA, neste caso o veiculo pode ser importado e a nota fiscal     //
//                  já foi digitada no BackOffice                                                                       //
//            "4" = Nao gera movimentacao de entrada Back Office (Nota Fiscal de Entrada / Mov. Interna de Estoque)     //
//                  Opcao utilizada na integração com CAOA, neste caso o veiculo foi produzido pela montadora através   //
//                  de uma Ordem de Produção no PCP                                                                     //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function VEIXX000(xAutoCab,xAutoItens,xAutoCP,nOpc,xOpeMov,xAutoAux,xMostraMsg,xSX5NumNota,xTIPDOC)
Local aBotAux := {}
//
Local nTamGru := TamSx3("B1_GRUPO")[1]	// Tamanho da variavel de grupo
//
Private bRefresh := { || .t. }				// Variavel necessaria ao MAFISREF
Private aCampos  := {}							// Variavel de integracao com o VEIVA010
Private cChassi  := {}							// Variavel de integracao com o VEIVA010
Private aIteParc := { { ctod("") , 0 , {} } }	// Vetor contendo os titulos a pagar
Private aParcCust := {}							// Vetor com os Campos Customizados no Como Pagar
//
Private cGruVei  := Left(GetMv("MV_GRUVEI")+space(nTamGru),nTamGru)
Private cUsaGrVA := GetNewPar("MV_MIL0010","0") // O Módulo de Veículos trabalhará com Veículos Agrupados por Modelo no SB1 ? (0=Nao / 1=Sim)
//
Private lAbortPrint	:= .f.	// Variavel de Aborto de Operacao
Private cX0OpeMov := xOpeMov		// Tipo de Operacao de entrada
Private cSerie, cNumero					// Serie e numero da NF quando formulario proprio
Private lMudouNum := .f. 				// Indica se houve mudanca da sequencia de nota fiscal
Private lLivreDebito := .f.				// Indica se sera gerado titulo (avaliacao de veiculos)
// Variaveis de integracao
Private lMostraMsg := IIF(xMostraMsg==NIL,.t.,xMostraMsg)
Private aAutoCab := {} 					// Cabecalho da NF (VVF)
Private aAutoItens := {}				// Itens da NF (VVG)
Private aAutoIteParc := {}				// Como pagar (SE2)
Private aAutoAux := {}					// Auxiliar (para retornos de remessa/consignado)
// 'lVX000Auto' indica se todos os vetores de integracao foram preenchidos
Private lVX000Auto := ( xAutoCab<>NIL .and. xAutoItens<> NIL .and. xAutoCP<>NIL .and. nOpc<>NIL .and. xOpeMov<>NIL )
// VARIAVEIS DE CONTROLE DA TELA (OBJETOS)
Private aTitulo := {STR0001,STR0002}	// Dados da Nota Fiscal","Como Pagar # Titulo dos folders
Private oFnt1 := TFont():New( "System", , 12 )
Private oSayE34
Private oSayE21
Private oGetE21
Private oGetE101 // Necessario para refresh na tela - Total Frete
Private oGetE72  // Necessario para refresh na tela - Peso Liquido
Private oGetE73  // Necessario para refresh na tela - Peso Bruto
Private oFnt2 := TFont():New( "Courier New", , 16,.t. )
Private oFnt3 := TFont():New( "Arial", , 14,.t. )
//
Private aCposUser := {} // Campos customizáveis do cabeçalho (VVF)
//
// Variaveis do Folder 2 - Como Pagar
Private dDataIni := ctod(" ")
Private nDias1P
Private nParcel
Private nInterv
Private lImpXml := ( FM_PILHA("U_IMPXMLV") .or. FM_PILHA("U_IXMLVJD") )
Private n := 1
Private cCliForA := ""//GetNewPar("MV_CLFRRC","")
Private aOrc     := {}
Private nRecVVF  := 0
// Variáveis do Folder 3 - Moeda
Private nMoedaCor
Private nTaxaMoeda
//
Private aNewBot  := {}
//
Private lAtuFiscal := .t. // Atualiza Fiscal
Private lMoeda     := VVF->(FieldPos("VVF_MOEDA")) > 0 .Or. VVF->(FieldPos("VVF_TXMOED")) > 0
//
Default xSX5NumNota := {.t.,"",""}
Default xTIPDOC     := "1" // 1=NF / 2=SD3 (Mov.Internas)
Default xAutoCab    := {}
Default xAutoItens  := {}
Default xAutoCP     := {}
//
Private PARxTIPDOC := xTIPDOC
//
If lMoeda
	aAdd(aTitulo, STR0107) // Moeda # Título dos folders
EndIf

If xTIPDOC == "2" // SD3 ( Mov.Internas )
	lAtuFiscal := .f. // NAO atualizar Fiscal quando Mov.Internas
EndIf
If xTIPDOC == "3" // Integracao com SIGAEIC
EndIf
If xTIPDOC == "4" // Integracao com o SIGAPCP
	lAtuFiscal := .f.
EndIf
//
//if !(FindFunction("FMX_CNPJLB")) .or. !FMX_CNPJLB()
//	If !AMIIn(11) .or. (!FMX_AMIIn({"VEIVC140", "VEIXA001", "VEIXA002", "VEIXA003", "VEIXA004", "VEIXA005", "VEIXA006", "VEIXA007", "VEIXA008", "VEIXA012", "VEIXA016", "VEIXA017" ,"VEIXA021", "VEIXA026", "VEIXA027","OFIIA340","VEIXA340","VEIXA018","VEIXA030","VEIXA040","VEIVC210","IMPXMLV","VEIVC260"}))
//		Return()
//	EndIf
//endif
If cX0OpeMov != nil
	If cX0OpeMov == "0" // O botão somente deve aparecer em casos de Entrada por Compra
		// Inclusão de AMS no Outras Ações
		If nOpc == 3 // Somente na Opção Incluir
			aadd(aNewBot,{"BMPVISUAL", {|| VX000IAMS() } , STR0106+" "+GetNewPar("MV_MIL0106","AMS") })  // Incluir AMS
		Endif
	Endif
	If ( ExistBlock("VX000BOT") )
		aBotAux := ExecBlock("VX000BOT",.F.,.F.,{nOpc,cX0OpeMov,aNewBot})
		If ( ValType(aBotAux) == "A" )
			aNewBot := aClone(aBotAux)
		EndIf
	EndIf
EndIf
//
If ! lVX000Auto .AND. cCadastro == NIL
	cCadastro := STR0003 //Entrada de Veiculos
EndIf
// Se for detectado que trata-se de integracao faz os vetores receberem os parametros
If lVX000Auto
	aAutoCab	 := xAutoCab
	aAutoItens	 := xAutoItens
	aAutoIteParc := xAutoCP
	aIteParc	 := xAutoCP
	aAutoAux 	 := IIF(xAutoAux==NIL,{},xAutoAux)
EndIf
// Na integracao as variaveis abaixo nao existirao,
// por isso precisamos carrega-las manualmente
INCLUI 	:= nOpc==3
ALTERA 	:= nOpc==4
EXCLUI 	:= nOpc==5
//#############################################################################
//# Chama a tela contendo os dados do veiculo                                 #
//#############################################################################
DBSelectArea("VVF")
lRet := VX000EXEC(alias(),Recno(),nOpc,xSX5NumNota,xTIPDOC)
If lRet .and. nRecVVF > 0
	VVF->(DbGoto(nRecVVF))
EndIf
//
Return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Programa  | VX000EXEC  |Autor  | Luis Delorme          | Data | 11/12/08 |##
##+----------+------------+-------+-----------------------+------+----------´##
##|Descri‡„o | Entrada de Veiculos                                          |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000EXEC(cAlias,nReg,nOpc,xSX5NumNota,xTIPDOC)
Local lRet      := .f.
//
Local nCntFor
Local nCntFor2
Local nPos
Local aObjects 	:= {}
Local aObjects1	:= {}
Local aObjects2	:= {}
Local aSizeAut	:= MsAdvSize(.t.)
Local ni        := 0
Local nLinha    := 0
Local nColuna   := 0
Local nLinCpo   := 0
Local nColCpo   := 0

Private aCliFor  := X3CBOXAVET("VVF_CLIFOR","0")
Private cCombo   := {}
//
Default xSX5NumNota := {.t.,"",""}
Default xTIPDOC     := "1" // 1=NF / 2=SD3 (Mov.Internas)
//
aParcCust := {}
If (FM_PILHA("VEIXA001")) // Somente Entrada de Veiculos por Compra
	If ExistBlock("VX000CCP")
		aParcCust := ExecBlock("VX000CCP",.f.,.f.) // Campos Customizados na Grid de Parcelas
		// aParcCust[x,1] Titulo da Coluna no ListBox
		// aParcCust[x,2] Campo do SE2 ( se informado será gravado na integracao com o FINA - Geração do Titulo )
		// aParcCust[x,3] Picture do Campo
		// aParcCust[x,4] Tamanho da Coluna no ListBox
		// aParcCust[x,5] Posicionamento - Alinhamento no ListBox: LEFT / RIGHT
		// aParcCust[x,6] Conteudo default
		VX0000041_CarregaDefaultCamposCustomizadosParcelas(1)
	EndIf
EndIf
//
/*
1 -> Linha inicial area trabalho
2 -> Coluna inicial area trabalho
3 -> Linha final area trabalho
4 -> Coluna final area trabalho
5 -> Coluna final dialog
6 -> Linha final dialog
7 -> Linha inicial dialog
*/
If ! lVX000Auto
	// Local bCampo	  := { |nCPO| Field(nCPO) }
	//
	// MONTA ESPACAMENTO DAS TELAS
	//
	// TELA SUPERIOR (ENCHOICE) - TAMANHO VERTICAL FIXO
	AAdd( aObjects, { 0,	115, .T., .F. } )
	// TELA CENTRAL (GETDADOS) - TAMANHO VERTICAL VARIAVEL
	AAdd( aObjects, { 0,	20, .T., .T. } )
	// TELA INFERIOR (FOLDER) - TAMANHO VERTICAL FIXO
	AAdd( aObjects, { 0,	75, .T., .F. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	// ESPACAMENTO DA TELA DE FOLDER - QUATRO LINHAS DE TAMANHO FIXO + FINAL VARIAVEL
	AAdd( aObjects1, { 0, 10, .T., .f. } )
	AAdd( aObjects1, { 0, 10, .T., .f. } )
	AAdd( aObjects1, { 0, 10, .T., .f. } )
	AAdd( aObjects1, { 0, 10, .T., .f. } )
	AAdd( aObjects1, { 0, 0, .T., .T. } )
	aAbaInt := {0, 0, aPosObj[3,4]-aPosObj[3,2], aPosObj[3,3]-aPosObj[3,1]-14, 3, 3}
	aPosAba1 := MsObjSize( aAbaInt, aObjects1 )
	// ESPACAMENTO DA TELA DE CABECALHO -  DOZE LINHAS DE TAMANHO FIXO + FINAL VARIAVEL
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
	aAbaCab := { aPosObj[1,2], aPosObj[1,2], aPosObj[1,4], aPosObj[1,3] , 3, 3 }
	aPosAbaCab := MsObjSize( aAbaCab, aObjects2 )
EndIf
//
// Zera variaveis de controle dos objetos
//
aIteParc := { { ctod("") , 0 , {} } }
VX0000041_CarregaDefaultCamposCustomizadosParcelas(1)

dDataIni 	:= ctod(" ")
nDias1P 		:= 0
nParcel 		:= 0
nInterv 		:= 0
nMoedaCor       := 1
nTaxaMoeda      := 1
//##########################################
//# Cria variaveis M->????? da Enchoice    #
//##########################################
dbSelectArea("VVF")
dbSetOrder(1)
//
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVF")
//
// FILTRA OS CAMPOS DA ENCHOICE DEPENDENDO DO TIPO DE NOTA DE ENTRADA
//
cFiltrVVFS := "VVF_CONFRE#VVF_TESFRE#VVF_OPEMOV#VVF_NUMTRA#VVF_TRACPA#VVF_VALMOV#"
cFiltrVVFS += "VVF_TOTSEG#VVF_TOTFRE#VVF_VBAIPI#VVF_ALIIPI#VVF_VALIPI#VVF_VBAICM#"
cFiltrVVFS += "VVF_TOTICM#VVF_ICMRET#VVF_NUMPED#VVF_ALIICM#VVF_TIPMOV#VVF_TIPDOC#"
cFiltrVVFS += "VVF_MOEDA#VVF_TXMOED#"

Do Case
	Case cX0OpeMov $ "015" // COMPRA / PED.FABRICA / DEVOLUCAO
		cFiltrVVG := "VVG_PICOSB#"
	Case cX0OpeMov $ "23478" // REMESSA / TRANSFERENCIA / CONSIGNACAO / RETORNO DE REMESSA / RETORNO DE CONSIGNACAO
		cFiltrVVG := "VVG_VCNVEI#VVG_CODIND#VVG_CONFRE#VVG_PICOSB#"
EndCase

If !(cPaisLoc == "BRA")
	cFiltrVVG += "VVG_VBAIPI#VVG_ALIIPI#VVG_VALIPI#VVG_VBAICM#VVG_ALIICM#VVG_ICMCOM#"
	cFiltrVVG += "VVG_VBICRT#VVG_ICMRET#VVG_PISENT#VVG_COFENT#VVG_VALDES#VVG_BASCOF#"
	cFiltrVVG += "VVG_ALICOF#VVG_VALCOF#VVG_BASPIS#VVG_ALIPIS#VVG_VALPIS#VVG_BAIMP5"
	cFiltrVVG += "#VVG_ALIMP5#VVG_VLIMP5#VVG_BAIMP6#VVG_ALIMP6#VVG_VLIMP6#VVG_CF#"
endif
//
// CAMPOS DE VISUALIZACAO DO FOLDER 1
//
aOrc := {}
If lAtuFiscal // Atualiza Fiscal
	aAdd(aOrc, {'MaFisRet(,"NF_VALMERC")',  STR0031, 0, "SF1->F1_VALMERC"})   //Valor Mercadorias
	aAdd(aOrc, {'MaFisRet(,"NF_DESCONTO")', STR0032, 0, "SF1->F1_DESCONT"})   //Desconto
	aAdd(aOrc, {'MaFisRet(,"NF_SEGURO")',   STR0033, 0, "SF1->F1_SEGURO"})    //Seguro
	aAdd(aOrc, {'MaFisRet(,"NF_DESPESA")',  STR0034, 0, "SF1->F1_DESPESA"})   //Despesa
	aAdd(aOrc, {'MaFisRet(,"NF_FRETE")',    STR0035, 0, "SF1->F1_FRETE"})     //Frete
	If (cPaisLoc == "BRA")
		aAdd(aOrc, {'MaFisRet(,"NF_VALICM")', STR0036, 0, "SF1->F1_VALICM"})  //ICMS
		aAdd(aOrc, {'MaFisRet(,"NF_VALSOL")', STR0037, 0, "SF1->F1_ICMSRET"}) //ICMS ST
		aAdd(aOrc, {'MaFisRet(,"NF_VALPIS")', STR0108, 0, "SF1->F1_VALPIS"})  //PIS
		aAdd(aOrc, {'MaFisRet(,"NF_VALCOF")', STR0109, 0, "SF1->F1_VALCOFI"}) //COFINS
		aAdd(aOrc, {'MaFisRet(,"NF_VALPS2")', STR0110, 0, "SF1->F1_VALIMP6"}) //PS2
		aAdd(aOrc, {'MaFisRet(,"NF_VALCF2")', STR0111, 0, "SF1->F1_VALIMP5"}) //CF2
	endif
	aAdd(aOrc, {'MaFisRet(,"NF_TOTAL")',    STR0038, 0, "SF1->F1_VALBRUT"})   //Total
EndIf
//
// PONTO DE ENTRADA PARA ALTERACAO DO VETOR aOrc
//
If ExistBlock("VX000MF1")
	ExecBlock("VX000MF1",.f.,.f.)
EndIf
//
aCpoEncS  := {} // ARRAY DE CAMPOS DA ENCHOICE
//
While !Eof().and.(x3_arquivo=="VVF")
	If X3USO(x3_usado).and.cNivel>=x3_nivel .and. !(alltrim(x3_Campo) $ cFiltrVVFS)
		AADD(acpoEncS,x3_campo)
	EndIf
	If Inclui
		&("M->"+x3_campo):= CriaVar(x3_campo)
	Else
		If x3_context == "V"
			&("M->"+x3_campo):= &(X3_RELACAO)
		Else
			&("M->"+x3_campo):= &("VVF->"+x3_campo)
		EndIf
	EndIf
	DbSkip()
EndDo
If lImpXml
	Do Case
		Case FM_PILHA("U_IMPXMLV")
			M->VVF_CLIFOR := "F"
			M->VVF_FORPRO := "0"
			M->VVF_DATEMI := dEmissao
			M->VVF_OPEMOV := "0"
			M->VVF_DATMOV := dDataBase
			M->VVF_SITNFI := "1"
			M->VVF_NUMNFI := cNF_XML
			M->VVF_SERNFI := cSerie_XML
			M->VVF_CODFOR := SA2->A2_COD
			M->VVF_LOJA   := SA2->A2_LOJA
			M->VVF_NOMFOR := SA2->A2_NOME
			M->VVF_FORPAG := cCondicao
			M->VVF_NATURE := cNaturez
			M->VVF_CHVNFE := cChNFe
		Case FM_PILHA("U_IXMLVJD") // IXMLVJD
			For nCntFor := 1 to len(aAutoCab)
				&("M->"+aAutoCab[nCntFor,1]) := aAutoCab[nCntFor,2]
			Next
			If len(aAutoIteParc) > 0
				aIteParc := aClone(aAutoIteParc)
			EndIf
	EndCase
EndIf
M->VVF_OPEMOV := cX0OpeMov
//#####################################
//# Cria aHeader e aCols da GetDados  #
//#####################################
nUsadoV:=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVG")
aHeaderV:={}
While !Eof().And.(x3_arquivo=="VVG")

	If (X3USO(x3_usado) .And. cNivel>=x3_nivel .and. !alltrim(x3_Campo) $ cFiltrVVG) .or. ( alltrim(x3_Campo) == "VVG_CHAINT" )

		nUsadoV := nUsadoV+1
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

If lImpXml

	aColsV := {}

	Do Case
		Case FM_PILHA("U_IMPXMLV")

			aColsV := { Array(nUsadoV+1) }
			aColsV[Len(aCols),nUsadoV+1] := .F.

			FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			DBSetOrder(1)
			cTESEnt := MaTesInt(1,Alltrim(cOper),SA2->A2_COD,SA2->A2_LOJA,"F",SB1->B1_COD)

			M->VVG_CHASSI := VV1->VV1_CHASSI
			M->VVG_CHAINT := VV1->VV1_CHAINT
			M->VVG_ESTVEI := VV1->VV1_ESTVEI
			M->VVG_LOCPAD := VV1->VV1_LOCPAD
			M->VVG_CODORI := VV1->VV1_CODORI
			M->VVG_SITTRI := IIF(VV1->VV1_PROVEI=="1","0","1")
			M->VVG_VALUNI := nTValMerc
			M->VVG_CODTES := cTesEnt
			M->VVG_VBAIPI := val(nBaseIPI)
			M->VVG_ALIIPI := val(nAliIPI)
			M->VVG_VALIPI := val(nValIPI)
			M->VVG_VBAICM := val(nBaseICM)
			M->VVG_ALIICM := val(nAliICM)
			M->VVG_ICMCOM := val(nValICM)
			M->VVG_VBICRT := val(nBICMST)
			M->VVG_ICMRET := val(nValST)
			
			For nCntFor:=1 to nUsadoV
				aColsV[1,nCntFor]:=CriaVar(aHeaderV[nCntFor,2])
			Next

			M->VVG_OPER   := Alltrim(cOper)
			aColsV[1,FG_POSVAR("VVG_CHASSI","aHeaderV")] := M->VVG_CHASSI
			aColsV[1,FG_POSVAR("VVG_CHAINT","aHeaderV")] := M->VVG_CHAINT
			aColsV[1,FG_POSVAR("VVG_ESTVEI","aHeaderV")] := M->VVG_ESTVEI
			aColsV[1,FG_POSVAR("VVG_LOCPAD","aHeaderV")] := M->VVG_LOCPAD
			aColsV[1,FG_POSVAR("VVG_SITTRI","aHeaderV")] := M->VVG_SITTRI
			aColsV[1,FG_POSVAR("VVG_VALUNI","aHeaderV")] := M->VVG_VALUNI
			aColsV[1,FG_POSVAR("VVG_OPER","aHeaderV")]   := M->VVG_OPER
			aColsV[1,FG_POSVAR("VVG_CODTES","aHeaderV")] := M->VVG_CODTES
			aColsV[1,FG_POSVAR("VVG_CODORI","aHeaderV")] := M->VVG_CODORI
			aColsV[1,FG_POSVAR("VVG_VBAIPI","aHeaderV")] :=	M->VVG_VBAIPI
			aColsV[1,FG_POSVAR("VVG_ALIIPI","aHeaderV")] :=	M->VVG_ALIIPI
			aColsV[1,FG_POSVAR("VVG_VALIPI","aHeaderV")] :=	M->VVG_VALIPI
			aColsV[1,FG_POSVAR("VVG_VBAICM","aHeaderV")] :=	M->VVG_VBAICM
			aColsV[1,FG_POSVAR("VVG_ALIICM","aHeaderV")] :=	M->VVG_ALIICM
			aColsV[1,FG_POSVAR("VVG_ICMCOM","aHeaderV")] :=	M->VVG_ICMCOM
			aColsV[1,FG_POSVAR("VVG_VBICRT","aHeaderV")] :=	M->VVG_VBICRT
			aColsV[1,FG_POSVAR("VVG_ICMRET","aHeaderV")] :=	M->VVG_ICMRET

		Case FM_PILHA("U_IXMLVJD") // IXMLVJD

			For nCntFor := 1 to len(aAutoItens)
				AADD(aColsV,Array(nUsadoV+1))
				For nCntFor2:=1 to nUsadoV
					aColsV[len(aColsV),nCntFor2]:=CriaVar(aHeaderV[nCntFor2,2])
				Next
				For nCntFor2:=1 to len(aAutoItens[nCntFor])
					nPos := FG_POSVAR(aAutoItens[nCntFor,nCntFor2,1],"aHeaderV")
					If nPos > 0
						aColsV[len(aColsV),nPos] := aAutoItens[nCntFor,nCntFor2,2]
					EndIf
					&("M->"+aAutoItens[nCntFor,nCntFor2,1]) := aAutoItens[nCntFor,nCntFor2,2]
				Next
				aColsV[Len(aColsV),nUsadoV+1]:=.F.
			Next

	EndCase

Else

	If INCLUI
		aColsV := { Array(nUsadoV+1) }
		aColsV[1,nUsadoV+1] := .F.
		For nCntFor:=1 to nUsadoV
			aColsV[1,nCntFor]:=CriaVar(aHeaderV[nCntFor,2])
		Next
	Else
		aColsV:={}
		dbSelectArea("VVG")
		dbSetOrder(1)
		dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
		While !eof() .and. VVG->VVG_FILIAL == xFilial("VVG");
			.and. VVF->VVF_TRACPA == VVG->VVG_TRACPA
			AADD(aColsV,Array(nUsadoV+1))
			For nCntFor:=1 to nUsadoV
				aColsV[Len(aColsV),nCntFor] := FieldGet(FieldPos(aHeaderV[nCntFor,2]))
				If aHeaderV[nCntFor,2]  <> "V"
					&("M->"+aHeaderV[nCntFor,2]) := FieldGet(FieldPos(aHeaderV[nCntFor,2]))
				EndIf
			Next
			aColsV[Len(aColsV),nUsadoV+1]:=.F.
			DbSkip()
		EndDo
	EndIf
EndIf
//
If xTIPDOC == "1" .OR. lAtuFiscal // 1=NF / 2=SD3 (Mov.Internas)
	// ZERA A PILHA FISCAL
	MaFisEnd()
EndIf
//
If ! lVX000Auto
	//####################################################
	//# Monta condicao de pagamento e dados da NF        #
	//####################################################
	If !INCLUI
		VX000LOADCP()
		VX000LOADNF()

		If lMoeda
			VX0000016_LoadMoeda()
		EndIf
	EndIf
	// FUNCOES DE TECLA //// ƒ€
	SETKEY(VK_F4,{||VX000KEYF4()})
	// FUNCOES DE CONTROLE DE EVENTOS DA GETDADOS
	cLinOk        :="VX000LINOK('"+xTIPDOC+"')"
	cFieldOk      :="VX000FIELDOK()"
	cTudoOk		  :="VX000TUDOK("+strzero(nOpc,1)+",'"+xTIPDOC+"')"
	// COPIA VETORES DA ACOLS MONTADA PARA AS VARIAVEIS PADRAO DA ACOLS
	aCols	:= aClone(aColsV)
	aHeader	:= aClone(aHeaderV)
	// MONTAGEM DA TELA
	// VARIAVEIS PARA DIVISAO DAS LINHAS NA ABA UM DO FOLDER
	dy5 := (aPosAba1[1,4] - aPosAba1[1,2])/5	// STEP DA POSICAO INICIAL
	sl5 := (aPosAba1[2,4] - aPosAba1[2,2])/5	// LARGURA DA CELULA
	sc5 :=  aPosAba1[2,3] - aPosAba1[2,1]			// COMPRIMENTO DA CELULA
	//#############################################################################
	//# Monta a tela da nota fiscal de entrada enchoice + acols + folders         #
	//#############################################################################
	DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE (cCadastro) Of oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Documento de Entrada
	oDlg:lEscClose := .F.
	//#############
	//# ENCHOICE  #
	//#############
	aCombo := {"1="+STR0004,"0="+STR0005} //Sim - Nao
	dyc7 := (aPosAbaCab[1,4] - aPosAbaCab[1,2])/7	// STEP DA POSICAO INICIAL
	scc7 := aPosAbaCab[2,3] - aPosAbaCab[2,1]		// COMPRIMENTO DA CELULA
	spc := 45
	
	If nOpc == 3 // Somente INCLUIR
		If cX0OpeMov $ "245" // remessa / consignacao / devolucao
			M->VVF_CLIFOR := "C"
		Else
			if cX0OpeMov $ "78" // retorno de remessa / retorno de consignacao 
				M->VVF_CLIFOR := "C"
			Else
				M->VVF_CLIFOR := "F"
			Endif
		Endif
	Endif

	// Cabeçalho
	oTScroll := TScrollBox():New(oDlg, aPosObj[1,1], aPosObj[1,2], aPosObj[1,3] - 015,  ;
		aPosObj[1,4] - 004, .T., .T., .T.)

	// L I N H A  1
	If cX0OpeMov $ "0"
		cCFWhen := .f.
	Else
		cCFWhen := "(Empty(M->VVF_CODFOR) .or. Empty(M->VVF_LOJA))"
	Endif
	FSX_POSCPO("VVF_CLIFOR", "oSayE12", aPosAbaCab[1,1], aPosAbaCab[1,2],               ;
		spc, "aCliFor",,,, "oTScroll", "oGetE12", cCFWhen)
	FSX_POSCPO("VVF_FORPRO", "oSayE11", aPosAbaCab[1,1], aPosAbaCab[1,2] + 2.4 * dyc7,  ;
		spc, "aCombo",,,, "oTScroll", "oGetE11")
	FSX_POSCPO("VVF_DATEMI", "oSayE13", aPosAbaCab[1,1], aPosAbaCab[1,2] + 4.8 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE13")

	// L I N H A  2
	FSX_POSCPO("VVF_CODFOR", "oSayE21", aPosAbaCab[2,1], aPosAbaCab[2,2],             ;
		spc,, RetTitle("VV0_CODCLI"), "SA1",, "oTScroll", "oGetE21")
	FSX_POSCPO("VVF_CODFOR", "oSayE34", aPosAbaCab[2,1], aPosAbaCab[2,2],             ;
		spc,, RetTitle("VVF_CODFOR"), "SA2",, "oTScroll", "oGetE21")
	FSX_POSCPO("VVF_LOJA", "oSayE22", aPosAbaCab[2,1], aPosAbaCab[2,2] + 2.4 * dyc7,  ;
		spc,, RetTitle("A1_LOJA"),,, "oTScroll", "oGetE22")
	FSX_POSCPO("VVF_NOMFOR", "oSayE23", aPosAbaCab[2,1], aPosAbaCab[2,2] + 4.8 * dyc7,;
		spc,, STR0097,,, "oTScroll", "oGetE23") // Nome
	If M->VVF_CLIFOR == "C"
		oSayE34:lVisible := .f.
	Else
		oSayE21:lVisible := .f.
	EndIf

	// L I N H A  3
	FSX_POSCPO("VVF_NUMNFI", "oSayE31", aPosAbaCab[3,1], aPosAbaCab[3,2],               ;
		spc,,,,, "oTScroll", "oGetE31")
	FSX_POSCPO("VVF_SERNFI", "oSayE32", aPosAbaCab[3,1], aPosAbaCab[3,2] + 2.4 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE32")
	FSX_POSCPO("VVF_NUMPED", "oSayE33", aPosAbaCab[3,1], aPosAbaCab[3,2] + 4.8 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE33")

	// L I N H A  4
	FSX_POSCPO("VVF_FORPAG", "oSayE41", aPosAbaCab[4,1], aPosAbaCab[4,2],               ;
		spc,,,,, "oTScroll", "oGetE41")
	FSX_POSCPO("VVF_DESFPG", "oSayE42", aPosAbaCab[4,1], aPosAbaCab[4,2] + 2.4 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE42")
	FSX_POSCPO("VVF_NATURE", "oSayE43", aPosAbaCab[4,1], aPosAbaCab[4,2] + 4.8 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE43")

	// L I N H A  5
	FSX_POSCPO("VVF_CODBCO", "oSayE51", aPosAbaCab[5,1], aPosAbaCab[5,2],               ;
		spc,,,,, "oTScroll", "oGetE51")
	FSX_POSCPO("VVF_CODAGE", "oSayE52", aPosAbaCab[5,1], aPosAbaCab[5,2] + 2.4 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE52")
	FSX_POSCPO("VVF_CODCOM", "oSayE53", aPosAbaCab[5,1], aPosAbaCab[5,2] + 4.8 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE53")

	// L I N H A  6
	FSX_POSCPO("VVF_DESACE", "oSayE61", aPosAbaCab[6,1], aPosAbaCab[6,2],               ;
		spc,,,,, "oTScroll", "oGetE61",,,,,, .t.)
	FSX_POSCPO("VVF_TRANSP", "oSayE62", aPosAbaCab[6,1], aPosAbaCab[6,2] + 2.4 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE62")
	FSX_POSCPO("VVF_ESPEC1", "oSayE63", aPosAbaCab[6,1], aPosAbaCab[6,2] + 4.8 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE63")

	// L I N H A  7
	FSX_POSCPO("VVF_VOLUM1", "oSayE71", aPosAbaCab[7,1], aPosAbaCab[7,2],               ;
		spc,,,,, "oTScroll", "oGetE71")
	FSX_POSCPO("VVF_PLIQUI", "oSayE72", aPosAbaCab[7,1], aPosAbaCab[7,2] + 2.4 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE72")
	FSX_POSCPO("VVF_PBRUTO", "oSayE73", aPosAbaCab[7,1], aPosAbaCab[7,2] + 4.8 * dyc7,  ;
		spc,,,,, "oTScroll", "oGetE73")

	// L I N H A  8
	FSX_POSCPO("VVF_ESPECI", "oSayE81", aPosAbaCab[8,1], aPosAbaCab[8,2],               ;
		spc,,,,, "oTScroll", "oGetE81")
	//
	oSayE71 := TSay():New(aPosAbaCab[8,1], aPosAbaCab[8,2] + 2.4 * dyc7, {|| RetTitle("VVF_OBSERV") },;
		oTScroll,, oFnt3,,,, .t., IIf(X3Obrigat("VVF_OBSMEM"), CLR_HBLUE, CLR_BLACK),, spc, 8)
	If INCLUI
		@ aPosAbaCab[8,1], aPosAbaCab[8,2] + 2.4 * dyc7 + spc GET oVVFObsMem VAR M->VVF_OBSERV OF oTScroll MEMO;
			SIZE (aPosAbaCab[5,2] + 2 * dyc7) - (aPosAbaCab[7,2] + spc) - 5, 031 PIXEL MEMO
	Else
		@ aPosAbaCab[8,1], aPosAbaCab[8,2] + 2.4 * dyc7 + spc GET oVVFObsMem VAR M->VVF_OBSERV OF oTScroll MEMO;
			SIZE (aPosAbaCab[5,2] + 2 * dyc7) - (aPosAbaCab[7,2] + spc) - 5, 031 PIXEL READONLY MEMO
	EndIf
	//
	oSayE71 := TSay():New(aPosAbaCab[8,1], aPosAbaCab[8,2] + 4.8 * dyc7, {|| RetTitle("VVF_OBSENF") },;
		oTScroll,, oFnt3,,,, .t., IIf(X3Obrigat("VVF_OBSMNF"), CLR_HBLUE, CLR_BLACK),, spc, 8)
	If INCLUI
		@ aPosAbaCab[8,1], aPosAbaCab[8,2] + 4.8 * dyc7 + spc GET oVVFObsMem VAR M->VVF_OBSENF OF oTScroll MEMO;
			SIZE (aPosAbaCab[5,2] + 2 * dyc7) - (aPosAbaCab[7,2] + spc) - 5, 031 PIXEL MEMO
	Else
		@ aPosAbaCab[8,1], aPosAbaCab[8,2] + 4.8 * dyc7 + spc GET oVVFObsMem VAR M->VVF_OBSENF OF oTScroll MEMO;
			SIZE (aPosAbaCab[5,2] + 2 * dyc7) - (aPosAbaCab[7,2] + spc) - 5, 031 PIXEL READONLY MEMO
	EndIf

	// L I N H A  9
	FSX_POSCPO("VVF_CHVNFE", "oSayE91", aPosAbaCab[9,1], aPosAbaCab[9,2],                    ;
		spc,,,,, "oTScroll")
	
	If At("VVF_TOTFRE",cFiltrVVFS) <> 0
		FSX_POSCPO("VVF_TOTFRE", "oSayE101", aPosAbaCab[10,1], aPosAbaCab[10,2],               ;
			spc,,,,, "oTScroll", "oGetE101",,,,,, .t.)
	EndIf

	// Veículo Transportador (Integração MATA103 - CI 008022)
	If VVF->(FieldPos("VVF_VEICU1")) > 0
		FSX_POSCPO("VVF_VEICU1", "oSayE111", aPosAbaCab[11,1], aPosAbaCab[11,2],               ;
			spc,,,,, "oTScroll", "oGetE111")
	EndIf

	If VVF->(FieldPos("VVF_VEICU2")) > 0
		FSX_POSCPO("VVF_VEICU2", "oSayE112", aPosAbaCab[11,1], aPosAbaCab[11,2] + 2.4 * dyc7,  ;
			spc,,,,, "oTScroll", "oGetE112")
	Endif

	If VVF->(FieldPos("VVF_VEICU3")) > 0
		FSX_POSCPO("VVF_VEICU3", "oSayE113", aPosAbaCab[11,1], aPosAbaCab[11,2] + 4.8 * dyc7,  ;
			spc,,,,, "oTScroll", "oGetE113")
	EndIf

	nLinha := 12 // Sequência
	if M->VVF_FORPRO == "1" .or. INCLUI
		nLinha := 13

		if VVF->(FieldPos("VVF_MENPAD")) > 0
			FSX_POSCPO("VVF_MENPAD", "oSayE121", aPosAbaCab[12,1], aPosAbaCab[12,2],             ;
				spc,,,,, "oTScroll", "oGetE121")
		Endif	
		if VVF->(FieldPos("VVF_MENNOT")) > 0
			FSX_POSCPO("VVF_MENNOT", "oSayE122", aPosAbaCab[12,1], aPosAbaCab[12,2] + 2.4 * dyc7,;
				spc,,,,, "oTScroll", "oGetE122")
		Endif	
	Endif

	If VVF->(FieldPos("VVF_TPFRET")) > 0
		aCBOX_TPFret := X3CBOXAVET("VVF_TPFRET","1")
		FSX_POSCPO("VVF_TPFRET", "oSayE123", aPosAbaCab[12,1], aPosAbaCab[12,2] + 4.8 * dyc7,  ;
			spc, "aCBOX_TPFret",,,, "oTScroll", "oGetE123")
	EndIf

	// Ponto de Entrada para adicionar campos customizáveis da VVF
	If ExistBlock("VX000CPO")
		aCposUser := ExecBlock("VX000CPO", .f., .f.)
	EndIf

	If Len(aCposUser) > 0
		nColuna := 1
		nLinCpo := aPosAbaCab[nLinha,1]
		nColCpo := aPosAbaCab[1,2]

		For ni := 1 to Len(aCposUser)
			SX3->(DbSetOrder(2))

			If !Empty(aCposUser[ni]) .And. SX3->(DbSeek(aCposUser[ni]))
				If SX3->X3_CONTEXT <> "V" .And. SX3->X3_TIPO <> "M" // Somente campos Reais (não Memos)
					cCombo  := {}

					If SX3->X3_TIPO == "C" .And. !Empty(SX3->X3_CBOX)
						cCombo := X3CBOXAVET(SX3->X3_CAMPO, "0")
					EndIf

					FSX_POSCPO(aCposUser[ni], "oSayE" + Alltrim(Str(nLinha)) + Alltrim(Str(nColuna)),   ;
						nLinCpo, nColCpo, spc, Iif(Len(cCombo) > 0 .And. !Empty(cCombo[1]), "cCombo", ""),;
						,,, "oTScroll", "oGetE" + Alltrim(Str(nLinha)) + Alltrim(Str(nColuna)))

					nColuna++
					If nColuna == 2
						nColCpo := aPosAbaCab[1,2] + 2.4 * dyc7
					ElseIf nColuna == 3
						nColCpo := aPosAbaCab[1,2] + 4.8 * dyc7
					Else
						nLinha++
						nColuna := 1
						nLinCpo := aPosAbaCab[2,1] - aPosAbaCab[1,1] + nLinCpo
						nColCpo := aPosAbaCab[1,2]
					EndIf
				Else
					aCposUser[ni] := "" // CAMPO NAO EXISTE NA BASE - NAO GRAVAR
				EndIf
			Else
				aCposUser[ni] := "" // CAMPO NAO EXISTE NA BASE - NAO GRAVAR
			EndIf
		Next

		SX3->(DbSetOrder(1))
	EndIf

	//#############################################################################
	//# GETDADOS                                                                  #
	//#############################################################################
	nLinha := 20 // Altura entre TScrollBox e MsGetDados
	oGetDados := MsGetDados():New(aPosObj[2,1] + nLinha, aPosObj[2,2], aPosObj[2,3],;
		aPosObj[2,4], nOpc, cLinOK, cTudoOk, "",;
		IIf(nOpc > 2 .and. nOpc < 5, .t., .f.),,,,, cFieldOk,,,, oDlg)
	//
	oGetDados:oBrowse:bDelete := {|| VX000DLIN(.t.), oGetDados:oBrowse:Refresh() }
	//
	oFolder := TFolder():New(aPosObj[3,1], aPosObj[3,2], aTitulo, {},;
		oDlg,,,, .t., .f., aPosObj[3,4] - aPosObj[3,2], aPosObj[3,3] - aPosObj[3,1])
	//#############################################################################
	//# FOLDER                                                                    #
	//#############################################################################
	// A B A  1
	@ aPosAba1[1,1], aPosAba1[1,2] LISTBOX olBox FIELDS HEADER          ;
		OemToAnsi(STR0006), OemToAnsi(STR0007) COLSIZES sl5 * 2, sl5 * 2  ; // Descricao / Valor
		SIZE aPosAba1[5,4] - aPosAba1[1,2], aPosAba1[5,3] - aPosAba1[1,1] ;
		OF oFolder:aDialogs[1] PIXEL
	//
	olBox:SetArray(aOrc)
	//
	olBox:bLine := {|| { aOrc[olBox:nAt,2],;
		FG_AlinVlrs(Transform(aOrc[olBox:nAt,3], "@E 999,999,999.99")) }}

	// A B A  2
	oSay21 := TSay():New(aPosAba1[1,1], aPosAba1[1,2],                               ;
		{|| STR0008 }, oFolder:aDialogs[2],, oFnt1,,,, .t., CLR_BLUE,, sl5, sc5) // Data Inicial
	//
	oDatIni:= TGet():New(aPosAba1[1,1], aPosAba1[1,2] + dy5,                         ;
		{|u| If(PCount() > 0, dDataIni := u, dDataIni)}, oFolder:aDialogs[2], sl5, sc5,;
		"@D",,,,,,, .T.,,,,,,,,,, "dDataIni")
	//
	oSay22 := TSay():New(aPosAba1[2,1], aPosAba1[2,2],                               ;
		{|| STR0009 }, oFolder:aDialogs[2],, oFnt1,,,, .t., CLR_BLUE,, sl5, sc5) // Dias 1a.Parc
	//
	oDias1P:= TGet():New(aPosAba1[2,1], aPosAba1[2,2] + dy5,                         ;
		{|u| IIf(PCount() > 0, nDias1P := u, nDias1P)}, oFolder:aDialogs[2], sl5, sc5, ;
		"@E 9999",,,,,,, .T.,,,,,,,,,, "nDias1P")
	//
	oSay23 := TSay():New(aPosAba1[3,1], aPosAba1[3,2],                               ;
		{|| STR0010 }, oFolder:aDialogs[2],, oFnt1,,,, .t., CLR_BLUE,, sl5, sc5) // Parcelas
	//
	oParcel:= TGet():New(aPosAba1[3,1], aPosAba1[3,2] + dy5,                         ;
		{|u| If(PCount() > 0, nParcel := u, nParcel)}, oFolder:aDialogs[2], sl5, sc5,  ;
		"@E 9999",,,,,,, .T.,,,,,,,,,, "nParcel")
	//
	oSay24 := TSay():New(aPosAba1[4,1], aPosAba1[4,2],                               ;
		{|| STR0011 }, oFolder:aDialogs[2],, oFnt1,,,, .t., CLR_BLUE,, sl5, sc5) // Intervalo
	//
	oInterv:= TGet():New(aPosAba1[4,1], aPosAba1[4,2] + dy5,                         ;
		{|u| If(PCount() > 0, nInterv := u, nInterv)}, oFolder:aDialogs[2], sl5, sc5,  ;
		"@E 9999",,,,,,, .T.,,,,,,,,,, "nInterv")

	// BOTOES DO COMO PAGAR
	oBtnCalc := tButton():New(aPosAba1[1,1], aPosAba1[1,2] + 2 * dy5,                ;
		STR0012, oFolder:aDialogs[2], {|| VX000CANPAR(1), VX000ATUCP()}, sl5, sc5,,,, .T.) // Calcular
	oBtnDesf := tButton():New(aPosAba1[2,1], aPosAba1[2,2] + 2 * dy5,                ;
		STR0013, oFolder:aDialogs[2], {|| VX000CANPAR(0)}, sl5, sc5,,,, .T.) // Desfazer

	// LISTBOX DO COMO PAGAR
	oLbParc := TWBrowse():new(aPosAba1[1,1], aPosAba1[1,2] + 3 * dy5 , 2 * dy5 , aPosAba1[5,3] - aPosAba1[1,1] ,,,,oFolder:aDialogs[2],,,,,{ || VX000ALTFIN(oLbParc:nAt) },,,,,,,.F.,,.T.,,.F.,,,)
	oLbParc:addColumn( TCColumn():new( STR0014 , { || Transform(aIteParc[oLbParc:nAt,1],"@D") }                ,,,, "LEFT"  , 40 ,.F.,.F.,,,,.F.,) ) // Data
	oLbParc:addColumn( TCColumn():new( STR0007 , { || Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99") } ,,,, "RIGHT" , 50 ,.F.,.F.,,,,.F.,) ) // Valor
	If len(aParcCust) > 0
		For nCntFor := 1 to len(aParcCust)
			oLbParc:addColumn( TCColumn():new( &("aParcCust["+str(nCntFor)+",1]") , &("{ || Transform(aIteParc[oLbParc:nAt,3,"+str(nCntFor)+"],aParcCust["+str(nCntFor)+",3]) }") ,,,, &("aParcCust["+str(nCntFor)+",5]") , &("aParcCust["+str(nCntFor)+",4]") ,.F.,.F.,,,,.F.,) ) // Campos Customizados no aIteParc
		Next
	EndIf
	oLbParc:nAt := 1
	oLbParc:setArray( aIteParc )
	
	If lMoeda
		// A B A  3
		If VVF->(FieldPos("VVF_MOEDA")) > 0
			oSay31 := TSay():New(aPosAba1[1,1], aPosAba1[1,2],;
				{|| RetTitle("VVF_MOEDA") }, oFolder:aDialogs[3],, oFnt1,,,, .t., CLR_BLUE,, sl5, sc5) // Moeda

			oMoeda := TGet():New(aPosAba1[1,1], aPosAba1[1,2] + dy5,;
				{|u| If(PCount() > 0, nMoedaCor := u, nMoedaCor)}, oFolder:aDialogs[3], sl5, sc5,;
				X3Picture("VVF_MOEDA"), {|| nMoedaCor <= MoedFin() .And. nMoedaCor <> 0 .And. VX0000026_AtualizaTaxa(oMoeda, oTaxa, oSay31) };
				,,,,,, .T.,,,,,,,,,, "nMoedaCor")
			oMoeda:lReadOnly := IIF((INCLUI .Or. ALTERA), .f., .t.)
		EndIf

		If VVF->(FieldPos("VVF_TXMOED")) > 0
			oSay32 := TSay():New(aPosAba1[2,1], aPosAba1[2,2],;
				{|| RetTitle("VVF_TXMOED") }, oFolder:aDialogs[3],, oFnt1,,,, .t., CLR_BLUE,, sl5, sc5) // Taxa Moeda

			oTaxa := TGet():New(aPosAba1[2,1], aPosAba1[2,2] + dy5,;
				{|u| If(PCount() > 0, nTaxaMoeda := u, nTaxaMoeda)}, oFolder:aDialogs[3], sl5, sc5,;
				X3Picture("VVF_TXMOED"), {|| VX000ATUCP()},,,,,, .T.,,,,,,,,,, "nTaxaMoeda")
				oTaxa:lReadOnly := IIF((INCLUI .Or. ALTERA) .And. nMoedaCor <> 1, .f., .t.)
		EndIf
	EndIf
	//
	// INICIALMENTE APENAS O CABECALHO DA TELA ESTARA HABILITADA QUANDO FOR INCLUSAO
	If INCLUI
		If !lImpXml
			oGetDados:disable()
			oFolder:disable()
		Endif
	Else
		oBtnCalc:disable()
		oBtnDesf:disable()
	EndIf
	//
	oDatIni:disable()
	oDias1P:disable()
	oParcel:disable()
	oInterv:disable()
	//
	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| lRet := IIf(VX000TUDOK(nOpc,xTIPDOC),VX000GRV(nOpc,cX0OpeMov,xSX5NumNota,xTIPDOC),.f.)},{|| IIf(VX000TSAIR(nOpc,cX0OpeMov),(nOpca:=0,oDlg:End()),.t.)},,aNewBot), VX000RDVFor() )
	//
Else
	lRet := .t.
	//################################################################
	//# Monta Enchoice e GetDados automaticamente para a integracao  #
	//################################################################
	aCols	:= {}
	aHeader := aClone(aHeaderV)
	// Cancelamento
	If nOpc == 5
		nRecVVF := VX000POSVVF(aAutoCab)
		If nRecVVF <> 0

			VVF->(dbGoTo(nRecVVF))

			aCols := {}
			dbSelectArea("VVG")
			dbSetOrder(1)
			dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
			While !eof() .and. VVG->VVG_FILIAL == xFilial("VVG") .and. VVF->VVF_TRACPA == VVG->VVG_TRACPA
				AADD(aCols,Array(nUsadoV+1))

				For nCntFor:=1 to nUsadoV
					aCols[Len(aCols),nCntFor] := FieldGet(FieldPos(aHeaderV[nCntFor,2]))
					If aHeaderV[nCntFor,2]  <> "V"
						&("M->"+aHeaderV[nCntFor,2]) := FieldGet(FieldPos(aHeaderV[nCntFor,2]))
					EndIf
				Next

				aCols[Len(aCols),nUsadoV+1]:=.F.
				DbSkip()
			EndDo

			If Len(aCols) == 0
				FMX_HELP("VEIX000E14",STR0114,STR0115 + " - " + VVF->VVF_TRACPA ) // "Erro ao carregar itens do movimento." // "Verifique o movimento
			Else
				lRet := VX000GRV(nOpc,cX0OpeMov,xSX5NumNota,xTIPDOC)
			EndIf

		Else
			lRet := .f.
		EndIf
	Else
		If EnchAuto("VVF",aAutoCab)
			MsGetDAuto(aAutoItens,"VX000LINOK('"+xTIPDOC+"')",{|| VX000TUDOK(nOpc,xTIPDOC).And.VX000GRV(nOpc,cX0OpeMov,xSX5NumNota,xTIPDOC)},aAutoCab,nOpc)
		Else
			lRet := .f.
		EndIf
	EndIf
EndIf
//
SET KEY VK_F4 TO
Return lRet

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |VX000LOADNF | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Traz dados do folder 1 (dados da nf)                         |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000LOADNF()
Local nCntFor
If VVF->(FieldPos("VVF_TIPDOC")) > 0 .and. VVF->VVF_TIPDOC == "2" // 1 = NF / 2 = Mov.Internas (SD3)
	Return
EndIf
//
If VVF->VVF_SITNFI == "0" // Nf Cancelada
	set delete off
Endif
//
if VVF->(FieldPos("VVF_RECSF1")) > 0 .and. VVF->VVF_RECSF1 > 0
	DBSelectArea("SF1")
	DbGoTo(VVF->VVF_RECSF1)
Else
	DBSelectArea("SF1")
	DBSetOrder(1)
	DBSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA)
Endif
for nCntFor := 1 to Len(aOrc)
	aOrc[nCntFor,3] := &(aOrc[nCntFor,4])
next
//
If VVF->VVF_SITNFI == "0" // Nf Cancelada
	set delete on
Endif
//
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |VX000LOADCP | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Traz dados do folder 2 (dados do como pagar)                 |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000LOADCP()
Local nCntFor := 0
//
aIteParc := {}
//
If VVF->(FieldPos("VVF_TIPDOC")) > 0 .and. VVF->VVF_TIPDOC == "2" // 1 = NF / 2 = Mov.Internas (SD3)
	aAdd(aIteParc,{ ctod("") , 0 , {} })
	VX0000041_CarregaDefaultCamposCustomizadosParcelas(1)
	Return
EndIf

set delete off
DBSelectArea("SF1")
DBSetOrder(1)
If DBSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI)
	//
	cAlSE2 := "SQLSE2"
	cQuery := "SELECT E2_VENCREA, E2_VALOR "
	//
	If len(aParcCust) > 0
		For nCntFor := 1 to len(aParcCust)
			cQuery += ", "+aParcCust[nCntFor,2]
		Next
	EndIf
	//
	cQuery += "  FROM "+RetSqlName("SE2")+" "
	cQuery += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
	cQuery += "   AND E2_PREFIXO = '"+SF1->F1_PREFIXO+"'"
	cQuery += "   AND E2_NUM = '"+VVF->VVF_NUMNFI+"'"
	cQuery += "   AND E2_FORNECE = '"+VVF->VVF_CODFOR+"'"
	cQuery += "   AND E2_LOJA = '"+VVF->VVF_LOJA+"'"
	cQuery += "   AND D_E_L_E_T_"+IIf(VVF->VVF_SITNFI =="0","<>","=")+"' '"
	cQuery += " ORDER BY E2_VENCREA"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlSE2, .F., .T. )
	While !( cAlSE2 )->( Eof() )
		aAdd(aIteParc,{ stod( ( cAlSE2 )->( E2_VENCREA )), ( cAlSE2 )->( E2_VALOR ) , {} } )
		If len(aParcCust) > 0
			For nCntFor := 1 to len(aParcCust)
				aAdd(aIteParc[len(aIteParc),3],&("( cAlSE2 )->( "+aParcCust[nCntFor,2]+" )"))
			Next
		EndIf
		( cAlSE2 )->( DBSkip() )
	EndDo
	( cAlSE2 )->( dbCloseArea() )
	//
EndIf
set delete on
If Empty(aIteParc)
	aAdd(aIteParc,{ ctod("") , 0 , {} })
	VX0000041_CarregaDefaultCamposCustomizadosParcelas(1)
EndIf

Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |VX000VLDENC | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Rotina de validacao da ENCHOICE                              |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000VLDENC()
//
Local nCntFor
Local aFilAtu    := FWArrFilAtu()
Local cBkpFilAnt := cFilAnt
Local nCont      := 0
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local oCliente   := DMS_Cliente():New()
Local oFornece   := OFFornecedor():New()

// INICIALIZA CODIGO DO FORNECEDOR
If ReadVar() == "M->VVF_CODFOR"
	If !Empty(M->VVF_CLIFOR)
		cCliForA := M->VVF_CLIFOR
	Endif
	If !Empty(M->VVF_CODFOR)
		If cCliForA == "C"
			DBSelectArea("SA1")
			DBSetOrder(1)
			If lVX000Auto
				If !DbSeek(xFilial("SA1")+M->VVF_CODFOR+Alltrim(SA1->A1_LOJA)).and.;
					!DbSeek(xFilial("SA1")+M->VVF_CODFOR)
				ElseIf !DbSeek(xFilial("SA1")+M->VVF_CODFOR)
					Return .f.
				EndIf
			Else
				If M->VVF_CODFOR == SA1->A1_COD .and. DbSeek(xFilial("SA1")+M->VVF_CODFOR+Alltrim(SA1->A1_LOJA))
					M->VVF_LOJA := SA1->A1_LOJA
				ElseIf !DbSeek(xFilial("SA1")+M->VVF_CODFOR)
					Return .f.
				EndIf

			EndIf
		Else
			DBSelectArea("SA2")
			DBSetOrder(1)
			If lVX000Auto
				If !DbSeek(xFilial("SA2")+M->VVF_CODFOR+Alltrim(SA2->A2_LOJA)).and.;
					!DbSeek(xFilial("SA2")+M->VVF_CODFOR)
				ElseIf !DbSeek(xFilial("SA2")+M->VVF_CODFOR)
					Return .f.
				EndIf
			Else
				If M->VVF_CODFOR == SA2->A2_COD .and. DbSeek(xFilial("SA2")+M->VVF_CODFOR+Alltrim(SA2->A2_LOJA))
					M->VVF_LOJA := SA2->A2_LOJA
				ElseIf !DbSeek(xFilial("SA2")+M->VVF_CODFOR)
					Return .f.
				EndIf
			EndIf
		EndIf
		If !Empty(M->VVF_CODFOR) .and. !Empty(M->VVF_LOJA)
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
	EndIf
EndIf
// INICIALIZA-SE A FUNCAO FISCAL ASSIM QUE O FORNECEDOR EH ESCOLHIDO
If ReadVar() == "M->VVF_LOJA" //.or. lForn
	If Empty(M->VVF_LOJA)
		Return .t.
	EndIf
	If cCliForA == "C"
		DBSelectArea("SA1")
		DBSetOrder(1)
		If !DbSeek(xFilial("SA1")+M->VVF_CODFOR+M->VVF_LOJA)
			Return .f.
		EndIf
		if Empty(M->VVF_NATURE)
			if !Empty(GetNewPar("MV_NATVEIE",""))
				M->VVF_NATURE := Left( GetNewPar("MV_NATVEIE","") +space(20),TamSX3("VVF_NATURE")[1])
			elseif !Empty(SA1->A1_NATUREZ)
				M->VVF_NATURE := SA1->A1_NATUREZ
			endif
		endif
	Else
		DBSelectArea("SA2")
		DBSetOrder(1)
		If !DbSeek(xFilial("SA2")+M->VVF_CODFOR+M->VVF_LOJA)
			Return .f.
		EndIf
		if Empty(M->VVF_NATURE)
			if !Empty(GetNewPar("MV_NATVEIE",""))
				M->VVF_NATURE := Left( GetNewPar("MV_NATVEIE","") +space(20),TamSX3("VVF_NATURE")[1])
			elseif !Empty(SA2->A2_NATUREZ)
				M->VVF_NATURE := SA2->A2_NATUREZ
			endif
		endif
	EndIf
	If !Empty(M->VVF_CODFOR) .and. !Empty(M->VVF_LOJA)
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
	M->VVF_NOMFOR := IIf(cCliForA == "C",SA1->A1_NOME,SA2->A2_NOME)
	If lAtuFiscal // Atualiza Fiscal
		If !MaFisFound('NF')
			If cCliForA == "F" .and. cX0OpeMov <> "5"
				MaFisIni(M->VVF_CODFOR,M->VVF_LOJA,'F','N',,	MaFisRelImp("VEIXX000",{"VVF","VVG"}))
			ElseIf cCliForA == "C" .and. cX0OpeMov <> "5"
				MaFisIni(M->VVF_CODFOR,M->VVF_LOJA,'C','B',,	MaFisRelImp("VEIXX000",{"VVF","VVG"}))
			elseif cX0OpeMov $ "5" 	//  Devolucao
				MaFisIni(M->VVF_CODFOR,M->VVF_LOJA,'C','D',,	MaFisRelImp("VEIXX000",{"VVF","VVG"}))
			EndIf
			// HABILITA DIGITACAO DOS ITENS CASO A ROTINA NAO SEJA AUTOMATICA
			If !lVX000Auto .and. !lImpXml
				oGetDados:Enable()
				oFolder:Enable()
			EndIf
		Else
			MaFisRef("NF_CODCLIFOR","VVG00",M->VVF_CODFOR)
			MaFisRef("NF_LOJA","VVG00",M->VVF_LOJA)
			// CHAMAMOS A FUNCAO FIELDOK CADA VEZ QUE ALGUM
			// CAMPO QUE INTREFIRA NO FISCAL FOR ALTERADO
			if !lVX000Auto
				VX000FIELDOK()
			endif
		EndIf
	EndIf
	FG_Seek("SA6","M->VVF_CODBCO",1,.f.)
	M->VVF_CODAGE := SA6->A6_AGENCIA
	Return .t.
EndIf
// QUANDO DIGITAR A FORMA DE PAGAMENTO DEVEMOS ATUALIZAR
//O COMO PAGAR CASO A INTEGRACAO FISCAL EXISTA
If lAtuFiscal .and. ReadVar() == "M->VVF_FORPAG" // Atualiza Fiscal
	If !MaFisFound('NF')
		Return .t.
	Else
		VX000ATUCP()
	EndIf
EndIf
// DEVEMOS VERIFICAR SE JA FOI DADA ENTRADA DA NOTA DIGITADA
If ReadVar() == "M->VVF_NUMNFI" .OR. ReadVar() == "M->VVF_SERNFI" .OR. lVX000Auto
	If !Empty(M->VVF_NUMNFI) .AND. !Empty(M->VVF_SERNFI)
		If PARxTIPDOC == "1"
			aFil    := {}
			aAdd( aFil , { "  " , STR0015 })  //Compartilhado
			For nCont := 1 to Len(aSM0)
				cFilAnt := aSM0[nCont]
				aFilial := FWArrFilAtu(cEmpAnt,cFilAnt)
				aAdd( aFil , { cFilAnt , aFilial[5] })
			Next
			cFilAnt := cBkpFilAnt
			dbSelectArea("SF1")
			dbSetOrder(1)
			For nCntFor := 1 to Len(aFil)
				If dbSeek(aFil[nCntFor,1] + M->VVF_NUMNFI + M->VVF_SERNFI + M->VVF_CODFOR + M->VVF_LOJA)
					FMX_HELP("VEIX000E05", STR0016) //NF de Entrada ja existe para este fornecedor.","Atencao!
					Return .f.
					Exit
				EndIf
			Next
		ElseIf PARxTIPDOC == "3"
			dbSelectArea("SF1")
			dbSetOrder(1)
			If ! dbSeek(xFilial("SF1") + M->VVF_NUMNFI + M->VVF_SERNFI + M->VVF_CODFOR + M->VVF_LOJA)
				FMX_HELP("VEIX000E06", STR0116 ) // "Nota Fiscal de Entrada não encontrada para este fornecedor."
				Return .f.
			EndIf

			cSQL := "SELECT VVF_TRACPA " +;
				" FROM " + RetSQLName("VVF") + " VVF " +;
				" WHERE VVF.VVF_FILIAL = '" + xFilial("VVF") + "'" +;
				  " AND VVF.VVF_CODFOR = '" + M->VVF_CODFOR + "'" +;
				  " AND VVF.VVF_LOJA   = '" + M->VVF_LOJA   + "'" +;
				  " AND VVF.VVF_NUMNFI = '" + M->VVF_NUMNFI + "'" +;
				  " AND VVF.VVF_SERNFI = '" + M->VVF_SERNFI + "'" +;
				  " AND VVF.VVF_SITNFI = '1' " +;
				  " AND VVF.D_E_L_E_T_ = ' '"
			cNumTraDig := FM_SQL(cSQL)
			If ! Empty(cNumTraDig)
				FMX_HELP("VEIX000E07", STR0117 + CHR(13) + CHR(10) + RetTitle("VVF_TRACPA") + ": " + cNumTraDig) // "Movimento de entrada já foi criado para a Nota Fiscal de Entrada informada."
				Return .f.
			EndIf
		EndIf
	EndIf
EndIf
//
If ReadVar() == "M->VVF_NUMOP"
	cSQL := "SELECT R_E_C_N_O_ " + ;
		" FROM " + RetSQLName("SD3") + " D3 " + ;
		" WHERE D3.D3_FILIAL = '" + xFilial("SD3") + "' " + ;
		  " AND D3.D3_OP = '" + M->VVF_NUMOP + "'" +;
		  " AND D3.D3_CF LIKE 'PR%'" +; // Movimento de Producao do SIGAPCP
		  " AND D3.D3_ESTORNO = ' '" +; // Movimentos validos 
		  " AND D3.D_E_L_E_T_ = ' '"
	If FM_SQL(cSQL) == 0
		FMX_HELP("VEIX000E16", STR0118 + CHR(13) + CHR(10) + RetTitle("VVF_NUMOP") + ": " + M->VVF_NUMOP, STR0119 ) // "Lançamento de Produção não encontrado na tabela de movimentações." // "Verifique se existe um lançamento de produção válido na tabela de movimentação para a ordem de produção informada."
		Return .f.
	EndIf

	cSQL := "SELECT VVF_TRACPA " +;
		" FROM " + RetSQLName("VVF") + " VVF " +;
		" WHERE VVF.VVF_FILIAL = '" + xFilial("VVF") + "'" +;
			" AND VVF.VVF_NUMOP = '" + M->VVF_NUMOP + "'" +;
			" AND VVF.VVF_SITNFI = '1' " +;
			" AND VVF.D_E_L_E_T_ = ' '"
	cNumTraDig := FM_SQL(cSQL)
	If ! Empty(cNumTraDig)
		FMX_HELP("VEIX000E15", STR0120 + CHR(13) + CHR(10) + RetTitle("VVF_TRACPA") + ": " + cNumTraDig) // "Movimento de entrada já foi criado para a Ordem de Produção informada."
		Return .f.
	EndIf

EndIf
//
If ReadVar() == "M->VVF_TPFRET"
	MaFisRef("NF_TPFRETE","VX000",M->VVF_TPFRET)
EndIf
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | VX000Inc   | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o |  Funcao de Inclusao de Veiculos atraves da Entrada           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000INC(cAlias,nReg,nOpc)
//
Local nCntFor   := 0
Local aSM0      := {}
Local oVeiculos := DMS_Veiculo():New()
Local nRecVV1   := 0
Local nRecSB1   := 0

// Desconsiderar CHASSI em branco
If Empty(M->VVG_CHASSI)
	Return .f.
EndIf

// Nao deixar alterar quando o Item for AMS - Veiculos SEM CHASSI ( VV1_GRASEV = '6' )
If FM_SQL("SELECT VV1.R_E_C_N_O_ FROM "+RetSqlName("VV1")+" VV1 WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHASSI='"+aCols[n,FG_POSVAR("VVG_CHASSI")]+"' AND VV1.VV1_GRASEV='6' AND VV1.D_E_L_E_T_=' '") > 0
	Return .f.
EndIf

// TENTA PROCURAR O CHASSI NO CADASTRO SE ENCONTRAR VERIFICA SE JA NAO ESTA NO
// ESTOQUE CASO CONTRARIO CADASTRA O VEICULO CHAMANDO A FUNCAO DO VEIVA010
lAchou := FG_POSVEI("M->VVG_CHASSI","VV1->VV1_CHASSI")
If !lAchou
	// SE A ROTINA FOR AUTOMATICA NAO EH PERMITIDO CADASTRO DE VEICULOS
	If lVX000Auto
		Return .f.
	EndIf

	cChassi := M->VVG_CHASSI 			// preenchimento da variavel de integracao
	cTmpVarObs := M->VVF_OBSERV
	cChassiPre :=  cChassi
	lRetVA010 := VXA010I("VV1",,3)
	M->VVF_OBSERV := cTmpVarObs

	If !lRetVA010
		Return .f.
	Else
		M->VVG_CHASSI := VV1->VV1_CHASSI
		aCols[n,FG_POSVAR("VVG_CHASSI")] := M->VVG_CHASSI
	EndIf
Else
	If VV1->VV1_SITVEI == "8" // veiculo EM PEDIDO
		If !FM_PILHA("U_IXMLVJD") 
			VXA010A("VV1",VV1->(RecNo()),3)
		EndIf
		If ! FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			Return .f.
		EndIf
	EndIf

	// Chassi Bloqueado
	If oVeiculos:Bloqueado("", M->VVG_CHASSI)
		Return .f. // A mensagem já é exibida dentro da função Bloqueado()
	EndIf
EndIf

cChassi := M->VVG_CHASSI
If VV1->VV1_SITVEI <> "8" // Veiculo nao eh EM PEDIDO
	FGX_AMOVVEI(xFilial("VV1"),cChassi)
Else // Pedido
	If !lVX000Auto .and. !Empty(VV1->VV1_FILENT) .and. ( VV1->VV1_FILENT <> xFilial("SD1") )
		If !MsgYesNo(STR0098+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
					STR0099+": "+VV1->VV1_FILENT+CHR(13)+CHR(10)+;
					STR0100+": "+xFilial("SD1"),STR0017) // O Chassi esta Pedido para outra Filial. Deseja continuar? / Filial do Pedido / Filial Atual  / Atencao
			Return .f.
		EndIf
	EndIf
EndIf

// ##########################################################
// # VERIFICA RESTRICOES DE MOVIMENTACAO PARA VALIDAR       #
// # SE O VEICULO PODE REALIZAR A ENTRADA                   #
// ##########################################################
//
//	SE A ULTIMA MOVIMENTACAO FOR DE ENTRADA NAO PODEMOS REALIZAR NENHUMA OUTRA ENTRADA
If VV1->VV1_ULTMOV == "E" .AND. !(FM_PILHA("VEIXA040")) //VEIXA040 = Agrega/Desagrega
	DBSelectArea("VVF")
	DBSetOrder(1)
	DBSeek(VV1->VV1_FILENT+VV1->VV1_TRACPA)
	Do Case
		Case VVF->VVF_OPEMOV=="0"
			cOpeTxt := STR0018	//COMPRA
		Case VVF->VVF_OPEMOV=="1"
			cOpeTxt := STR0019	//COMPRA//PED.FABRICA
		Case VVF->VVF_OPEMOV=="2"
			cOpeTxt := STR0020	//REMESSA
		Case VVF->VVF_OPEMOV=="3"
			cOpeTxt := STR0021	//TRANSFERENCIA
		Case VVF->VVF_OPEMOV=="4"
			cOpeTxt := STR0022	//CONSIGNACAO
		Case VVF->VVF_OPEMOV=="5"
			cOpeTxt := STR0023	//DEVOLUCAO
		Case VVF->VVF_OPEMOV=="6"
			cOpeTxt := STR0024	//FRETE
		Case VVF->VVF_OPEMOV=="7"
			cOpeTxt := STR0025	//RETORNO DE REMESSA
		Case VVF->VVF_OPEMOV=="8"
			cOpeTxt := STR0026	//RETORNO DE CONSIGNACAO
	EndCase
	//
	MsgStop(STR0027 + CHR(13) + CHR(10) + CHR(13) + CHR(10)+;
		STR0028+" " + cOpeTxt + "." +;
		CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0029+": " + VVF->VVF_FILIAL +;
		" "+STR0030+":" + Alltrim(VVF->VVF_NUMNFI)+"-"+Alltrim(VVF->VVF_SERNFI),STR0017)//Impossivel continuar. # A ultima movimentacao do veiculo foi uma ENTRADA por # Filial # NF # Atencao
	//
	Return .f.
EndIf

// VERIFICA RESTRICOES DA ENTRADA x SAIDA
If !(FM_PILHA("VEIXA006"))
	DBSelectArea("VV0")
	DBSetOrder(1)
	DBSeek(VV1->VV1_FILSAI+VV1->VV1_NUMTRA)
EndIf
//
DBSelectArea("SA1")
dbSetOrder(1)
if FWModeAccess("SA1",3) == "E"
	SA1->(DBSeek(VV0->VV0_FILIAL+VV0->VV0_CODCLI+VV0->VV0_LOJA))
else
	SA1->(DBSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA))
endif
//
cOpeTXT := " "
Do Case
	Case VV0->VV0_OPEMOV=="0"
		cOpeTxt := STR0112	//VENDA
	Case VV0->VV0_OPEMOV=="1"
		cOpeTxt := STR0113	//SIMULACAO
	Case VV0->VV0_OPEMOV=="2"
		cOpeTxt := STR0021	//TRANSFERENCIA
	Case VV0->VV0_OPEMOV=="3"
		cOpeTxt := STR0020	//REMESSA
	Case VV0->VV0_OPEMOV=="4"
		cOpeTxt := STR0023	//DEVOLUCAO
	Case VV0->VV0_OPEMOV=="5"
		cOpeTxt := STR0022	//CONSIGNACAO
	Case VV0->VV0_OPEMOV=="6"
		cOpeTxt := STR0025	//RETORNO DE REMESSA
	Case VV0->VV0_OPEMOV=="7"
		cOpeTxt := STR0026	//RETORNO DE CONSIGNACAO
EndCase

// ABAIXO VERIFICAMOS SE TRATA-SE DE UMA MOVIMENTACAO DE SAIDA/ENTRADA
// PARA TRANSFERENCIA, REMESSA OU CONSIGNADO (RESPECTIVAMENTE)
lRemFilial = .f.
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
If !((VV0->VV0_OPEMOV = "2" .AND. cX0OpeMov == "3") .or.;
	(VV0->VV0_OPEMOV = "3" .AND. cX0OpeMov == "7") .or.;
	(VV0->VV0_OPEMOV = "5" .AND. cX0OpeMov == "8")) .and.;
	!(cX0OpeMov $ "01245")
	if ((cX0OpeMov == "3" .and. VV0->VV0_OPEMOV == "3") .or.;
		(cX0OpeMov == "4" .and. VV0->VV0_OPEMOV == "5") .or.;
		(cX0OpeMov == "7" .and. VV0->VV0_OPEMOV == "6") .or.;
		(cX0OpeMov == "8" .and. VV0->VV0_OPEMOV == "7") ) .and.;
		aSM0[18] == SA1->A1_CGC
		if !(FM_PILHA("VEIXA008"))
			MsgStop(STR0039+" "+STR0040,STR0017) // Entradas por remessa, consignacao ou retornos entre filiais devem # ser realizadas na rotina de remessas entre filiais. # Atencao
			Return .f.
		else
			lRemFilial = .t.
		endif
	endif
	//
	if !lRemFilial
		MsgStop(STR0027 + CHR(13) + CHR(10) + CHR(13) + CHR(10) +;
		STR0041+" " + cOpeTxt + "." +;
		CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0029 +": " + VV0->VV0_FILIAL +;
		" "+STR0030+":" + Alltrim(VV0->VV0_NUMNFI) + "-" + Alltrim(VV0->VV0_SERNFI),STR0017) //Impossivel continuar.#  ultima movimentacao do veiculo foi uma SAIDA por #  "Filial: " + VV0->VV0_FILIAL # NF # atencao
		//
		Return .f.
	endif
EndIf
//
// VERIFICA SE O CHASSI JA FOI DIGITADO EM UMA LINHA ANTERIOR
//
For nCntFor := 1 to Len(aCols)
	If !aCols[nCntFor,len(aHeader)+1]
		If nCntFor # n .and. aCols[nCntFor,FG_POSVAR("VVG_CHASSI")] == M->VVG_CHASSI
			FMX_HELP("VEIX000E07", STR0042)//Chassi ja digitado.
			M->VVG_CHAINT := ""
			aCols[n,FG_POSVAR("VVG_CHAINT")] := ""
			M->VVG_CODTES := ""
			aCols[n,FG_POSVAR("VVG_CODTES")] := ""
			Return .f.
		EndIf
	EndIf
Next
// #######################################################
// # FIM DAS VERIFICACOES DE RESTRICOES DE MOVIMENTACAO  #
// # PARA VALIDAR SE O VEICULO PODE REALIZAR A ENTRADA   #
// #######################################################
cTipoMov := "X" // TODO: nao tem tes padrao para os retornos
Do Case
	Case cX0OpeMov $ "0178"
		cTipoMov := "N"
	Case cX0OpeMov == "2"
		cTipoMov := "R"
	Case cX0OpeMov == "3"
		cTipoMov := "T"
	Case cX0OpeMov == "4"
		cTipoMov := "C"
EndCase

// SUGERE ALMOXARIFADO
VX000ALMVEI()
//
// PREENCHE OS CAMPOS LIGADOS AO VEICULO
DBSelectArea("VV1")
DBSetOrder(2)
DBSeek(xFilial("VV1")+cChassi)

FGX_VV1SB1("CHASSI", cChassi, cUsaGrVA , cGruVei )
If lAtuFiscal // Atualiza Fiscal
	// SETA VARIAVEL FISCAL
	MaFisRef("IT_PRODUTO","VVG00",SB1->B1_COD)
EndIf
M->VVG_SITTRI := SB1->B1_ORIGEM
acols[n,FG_POSVAR("VVG_SITTRI")] := SB1->B1_ORIGEM
M->VVG_CHASSI := VV1->VV1_CHASSI
aCols[n,FG_POSVAR("VVG_CHASSI")] := VV1->VV1_CHASSI
M->VVG_CHAINT := VV1->VV1_CHAINT
aCols[n,FG_POSVAR("VVG_CHAINT")] := VV1->VV1_CHAINT
M->VVG_ESTVEI := VV1->VV1_ESTVEI
acols[n,FG_POSVAR("VVG_ESTVEI")] := VV1->VV1_ESTVEI
M->VVG_CODORI := VV1->VV1_CODORI
acols[n,FG_POSVAR("VVG_CODORI")] := VV1->VV1_CODORI
M->VVG_LOCPAD := VV1->VV1_LOCPAD
acols[n,FG_POSVAR("VVG_LOCPAD")] := VV1->VV1_LOCPAD

If VV1->(FieldPos("VV1_CONTA")) > 0
	If !Empty(VV1->VV1_CONTA)
		If FG_POSVAR("VVG_CONTA") > 0 .and. Empty(acols[n,FG_POSVAR("VVG_CONTA")])
			M->VVG_CONTA := acols[n,FG_POSVAR("VVG_CONTA")] := VV1->VV1_CONTA
		EndIf
	EndIf
	If !Empty(VV1->VV1_CC)
		If FG_POSVAR("VVG_CENCUS") > 0 .and. Empty(acols[n,FG_POSVAR("VVG_CENCUS")])
			M->VVG_CENCUS := acols[n,FG_POSVAR("VVG_CENCUS")] := VV1->VV1_CC
		EndIf
	EndIf
	If !Empty(VV1->VV1_ITEMCC)
		If FG_POSVAR("VVG_ITEMCT") > 0 .and. Empty(acols[n,FG_POSVAR("VVG_ITEMCT")])
			M->VVG_ITEMCT := acols[n,FG_POSVAR("VVG_ITEMCT")] := VV1->VV1_ITEMCC
		EndIf
	EndIf
	If !Empty(VV1->VV1_CLVL)
		If FG_POSVAR("VVG_CLVL") > 0 .and. Empty(acols[n,FG_POSVAR("VVG_CLVL")])
			M->VVG_CLVL := acols[n,FG_POSVAR("VVG_CLVL")] := VV1->VV1_CLVL
		EndIf
	EndIf
EndIf

// VERIFICA SE EXISTE AVALIACAO VALIDA E ALTERA PRECO DE COMPRA
if cX0OpeMov == "0"
	DBSelectArea("VAZ")
	DBSetOrder(1)
	DBSeek(xFilial("VAZ") + acols[n,FG_POSVAR("VVG_CHASSI")])
	while xFilial("VAZ") + acols[n,FG_POSVAR("VVG_CHASSI")] == VAZ->VAZ_FILIAL + VAZ->VAZ_CHASSI
		if VAZ->VAZ_APROVA == "1" .or. VAZ->VAZ_APROVA == "2"
			M->VVG_VALUNI := acols[n,FG_POSVAR("VVG_VALUNI")] := VAZ->VAZ_VALCOM
			If lAtuFiscal // Atualiza Fiscal
				MaFisRef("IT_PRCUNI","VVG00",M->VVG_VALUNI)
				MaFisRef("IT_VALMERC","VVG00",M->VVG_VALUNI)
			EndIf
		endif
		DBSkip()
	enddo
endif
//
// Totalizar Peso dos Veiculos na cabeça da NF //
//
nRecVV1 := VV1->(RecNo())
nRecSB1 := SB1->(RecNo())
M->VVF_PLIQUI := 0
M->VVF_PBRUTO := 0
for nCntFor := 1 to Len(aCols) // Totalizar variaveis para calculo proporcional
	// pula itens deletados
	if !aCols[nCntFor,Len(aCols[nCntFor])] .and. !Empty(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
		FGX_VV1SB1("CHAINT", aCols[nCntFor,FG_POSVAR("VVG_CHAINT")] , /* cMVMIL0010 */ , cGruVei )
		M->VVF_PLIQUI += SB1->B1_PESO // Atualiza PESO LIQUIDO na tela
		M->VVF_PBRUTO += SB1->B1_PESBRU // Atualiza PESO BRUTO na tela
	EndIf
Next
If ValType(oGetE72) == "O" // Existe o Objeto
	oGetE72:Refresh() // M->VVF_PLIQUI -> Necessario para refresh na tela - Peso Liquido
	oGetE73:Refresh() // M->VVF_PBRUTO -> Necessario para refresh na tela - Peso Bruto
EndIf
VV1->(DbGoTo(nRecVV1))
SB1->(DbGoTo(nRecSB1))
//
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |VX000ALMVEI | Autor | Manoel                | Data | 27/07/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o |  Oferece AlmoxarIfado do Veiculo                             |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/

Function VX000ALMVEI()
//
Local lTesvazio
//
lTesvazio := Empty(M->VVG_CODTES)
If !lVX000Auto // A ROTINA AUTOMATICA NUNCA DEVE REFERENCIAR OBJETOS VISUAIS
	// PARA AS ENTRADAS EXCETO VDI/FROTISTA:
	If cX0OpeMov $ "02345678"
		// SE FOR VEICULO NOVO E TEM PARAMETRO
		If M->VVG_ESTVEI == "0" .and. Trim(GETMV("MV_LOCVEIN")) <> ""
			// ENTAO USA O PARAMETRO DE VEICULO NOVO
			M->VVG_LOCPAD := GETMV("MV_LOCVEIN")
			// SENAO SE FOR USADO E TEM PARAMETRO
		ElseIf  M->VVG_ESTVEI == "1" .and. Trim(GETMV("MV_LOCVEIU")) <> ""
			// ENTAO USA O PARAMETRO DE VEICULO USADO
			M->VVG_LOCPAD := GETMV("MV_LOCVEIU")
		Else
			// SENAO DEIXA O LOCAL PADRAO EM BRANCO
			M->VVG_LOCPAD := "  "
		EndIf
		// PARA VDI/FROTISTA
	ElseIf cX0OpeMov == "1"
		// SE TEM O PARAMETRO
		If !Empty(GETMV("MV_LOCVEIC"))
			// ENTAO USA O PARAMETRO
			M->VVG_LOCPAD := GETMV("MV_LOCVEIC")
		Else
			// DEIXA O LOCAL PADRAO EM BRANCO
			M->VVG_LOCPAD := "  "
		EndIf
	Else
		// DEIXA O LOCAL PADRAO EM BRANCO
		M->VVG_LOCPAD := "  "
	EndIf
	// ATUALIZA O ACOLS E DA REFRESH NA ACOLS
	aCols[n,FG_POSVAR("VVG_LOCPAD")] := M->VVG_LOCPAD
	oGetDados:oBrowse:Refresh(.t.)
EndIf
//
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000FIELDOK| Autor |  Luis Delorme         | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | FieldOK do aCols - Atualiza os campos com o fiscal.          |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000FIELDOK()
Local aMovVei := {}
Local lRet    := .t.
Local aArea   := GetArea()
//
// A ROTINA ATUALIZA OS CAMPOS DA INTEGRACAO FISCAL
if ReadVar() == "M->VVG_CHASSI"
	//
	DBSelectArea("VV1")
	DBSetOrder(2)
	DbSeek(xFilial("VV1")+M->VVG_CHASSI)
	If VV1->VV1_ULTMOV == "S"  .and. M->VVG_ESTVEI <> "1"
		If MsgYesNo(STR0096,STR0017)
			M->VVG_ESTVEI := "1"
			aCols[n,FG_POSVAR("VVG_ESTVEI")] := M->VVG_ESTVEI
		Endif
	Endif
	If cUsaGrVA == "1" // Usa Veiculos de forma Agrupada por Modelo no SB1
		If !FGX_VV2SB1()
			MsgStop(STR0095,STR0017) //
			lRet := .f.
		Endif
	Endif
	//
Elseif ReadVar() == "M->VVG_ESTVEI"
	//
	DBSelectArea("VV1")
	DBSetOrder(2)
	DbSeek(xFilial("VV1")+M->VVG_CHASSI)
	If VV1->VV1_ULTMOV == "S"
		if M->VVG_ESTVEI == "0"
			aMovVei := FGX_VEIMOVS(M->VVG_CHASSI)
			If (aMovVei[1,5] <> "4") .or. (aMovVei[1,5] == "4" .and. VV1->VV1_ESTVEI <> "0") // Não foi uma Devolucao de Compra e o Veículo ja nao era mais NOVO
				//				MsgInfo(STR0094,STR0017)
				//				Return(.f.)
			Endif
		Endif
	Endif
	//
Elseif ReadVar() == "M->VVG_ITPED"
	//
	if  Empty(M->VVG_ITPED)
		Return .t.
	endif
	DBSelectArea("SC7")
	if !DBSeek(xFilial("SC7")+M->VVG_NUMPED+M->VVG_ITPED)
		lRet := .f.
	endif
	if lRet .and. SC7->C7_FORNECE + SC7->C7_LOJA != M->VVF_CODFOR+M->VVF_LOJA
		MsgStop(STR0069+Alltrim(SC7->C7_FORNECE)+"-"+Alltrim(SC7->C7_LOJA)+")",STR0017) // "O fornecedor escolhido é diferente do fornecedor do pedido de compra ("
		lRet := .f.
	endif
	//
	if lRet .and. Empty(M->VVG_CHASSI)
		MsgStop(STR0070,STR0017) // "Preencha o campo CHASSI antes de escolher o item do pedido de compra."
		lRet := .f.
	endif
	//
	If lRet
		DBSelectArea("VV1")
		DBSetOrder(2)
		DbSeek(xFilial("VV1")+M->VVG_CHASSI)
		//
		FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
		SB1->(DBSetOrder(1))
		if SB1->B1_COD != SC7->C7_PRODUTO
			MsgStop(STR0071,STR0017)   // "O modelo do veículo não corresponde ao modelo do pedido de compra para o item escolhido."
			lRet := .f.
		EndIf
		If lRet
			M->VVG_VALUNI := aCols[n,FG_POSVAR("VVG_VALUNI")] := SC7->C7_PRECO
			M->VVG_VALDES := aCols[n,FG_POSVAR("VVG_VALDES")] := ( SC7->C7_DESC1 + SC7->C7_DESC2 + SC7->C7_DESC3 )
			If lAtuFiscal // Atualiza Fiscal
				MaFisRef("IT_PRCUNI","VVG00",M->VVG_VALUNI)
				MaFisRef("IT_VALMERC","VVG00",M->VVG_VALUNI)
				MaFisRef("IT_DESCONTO","VVG00",M->VVG_VALDES)
			EndIf
		Endif
	Endif
	//
ElseIf ReadVar() == "M->VVG_VALUNI" .and. cX0OpeMov == "0"
	//
	DBSelectArea("VAZ")
	DBSetOrder(1)
	DBSeek(xFilial("VAZ") + acols[n,FG_POSVAR("VVG_CHASSI")])
	while xFilial("VAZ") + acols[n,FG_POSVAR("VVG_CHASSI")] == VAZ->VAZ_FILIAL + VAZ->VAZ_CHASSI
		if (VAZ->VAZ_APROVA == "1" .or. VAZ->VAZ_APROVA == "2") .and. M->VVG_VALUNI != VAZ->VAZ_VALCOM .and. VAZ->VAZ_VALCOM > 0
			M->VVG_VALUNI := VAZ->VAZ_VALCOM
			If lAtuFiscal // Atualiza Fiscal
				MaFisRef("IT_PRCUNI","VVG00",M->VVG_VALUNI)
				MaFisRef("IT_VALMERC","VVG00",M->VVG_VALUNI)
			EndIf
			lRet := .f.
			exit
		endif
		DBSkip()
	enddo
	//
ElseIf ReadVar() == "M->VVG_CODIND"
	//
	If !Empty(M->VVG_CODIND)
		DBSelectArea("VVH")
		DBSetOrder(1)
		If DbSeek(xFilial("VVH")+M->VVG_CODIND)
			aCols[n,FG_POSVAR("VVG_DIACAR")] := M->VVG_DIACAR := VVH->VVH_DIACAR
		Else
			lRet := .f.
		EndIf
	EndIf
	//
EndIf
//
If lRet
	//
	If lAtuFiscal .and. MaFisFound("IT",n) // Atualiza Fiscal
		//
		if cX0OpeMov $ "57"
			DBSelectArea("SD2")
			DBSetOrder(3)
			if !Empty(VV0->VV0_CLIALI) .and. VV0->VV0_CATVEN=="7"
				DBSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CLIALI+VV0->VV0_LOJALI+SB1->B1_COD)
			else
				DBSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CODCLI+VV0->VV0_LOJA+SB1->B1_COD)
			endif
			MaFisAlt("IT_RECORI",SD2->(Recno()),n)
		Endif
		If ReadVar() == "M->VVG_OPER" .and. !Empty(M->VVG_OPER)
			cTESEnt := MaTesInt(1,M->VVG_OPER,M->VVF_CODFOR,M->VVF_LOJA,iif(cCliForA == "C","C","F"),SB1->B1_COD)
			MaFisRef("IT_TES","VVG00",cTESEnt)
		Endif
		M->VVG_CODTES := aCols[n,FG_POSVAR("VVG_CODTES")] := MaFisRet(n,"IT_TES")
		M->VVG_VALUNI := aCols[n,FG_POSVAR("VVG_VALUNI")] := MaFisRet(n,"IT_VALMERC")

		MaFisRef("IT_QUANT","VVG00",1)
		MaFisRef("IT_PRCUNI","VVG00",M->VVG_VALUNI)

		M->VVG_TOTSEG := aCols[n,FG_POSVAR("VVG_TOTSEG")] := MaFisRet(n,"IT_SEGURO")
		M->VVG_TOTFRE := aCols[n,FG_POSVAR("VVG_TOTFRE")] := MaFisRet(n,"IT_FRETE")
		M->VVG_DESACE := aCols[n,FG_POSVAR("VVG_DESACE")] := MaFisRet(n,"IT_DESPESA")
		If FG_POSVAR("VVG_II") > 0
			M->VVG_II := aCols[n,FG_POSVAR("VVG_II")] := MaFisRet(n,"IT_VALII")
		EndIf
		If FG_POSVAR("VVG_ALIQII") > 0
			M->VVG_ALIQII := aCols[n,FG_POSVAR("VVG_ALIQII")] := MaFisRet(n,"IT_ALIQII")
		EndIf
		// CAMPOS LOCALIZADOS BRASIL
		If cPaisLoc == "BRA"
			if FG_POSVAR("VVG_VBAIPI") > 0
				M->VVG_VBAIPI := aCols[n,FG_POSVAR("VVG_VBAIPI")] := MaFisRet(n,"IT_BASEIPI")
			endif
			if FG_POSVAR("VVG_ALIIPI") > 0
				M->VVG_ALIIPI := acols[n,FG_POSVAR("VVG_ALIIPI")] := MaFisRet(n,"IT_ALIQIPI")
			endif
			if FG_POSVAR("VVG_VALIPI") > 0
				M->VVG_VALIPI := aCols[n,FG_POSVAR("VVG_VALIPI")] := MaFisRet(n,"IT_VALIPI")
			endif
			if FG_POSVAR("VVG_VBAICM") > 0
				M->VVG_VBAICM := aCols[n,FG_POSVAR("VVG_VBAICM")] := MaFisRet(n,"IT_BASEICM")
			endif
			if FG_POSVAR("VVG_ALIICM") > 0
				M->VVG_ALIICM := aCols[n,FG_POSVAR("VVG_ALIICM")] := MaFisRet(n,"IT_ALIQICM")
			endif
			if FG_POSVAR("VVG_ICMCOM") > 0
				M->VVG_ICMCOM := aCols[n,FG_POSVAR("VVG_ICMCOM")] := MaFisRet(n,"IT_VALICM")
			endif
			if FG_POSVAR("VVG_VBICRT") > 0
				M->VVG_VBICRT := acols[n,FG_POSVAR("VVG_VBICRT")] := MaFisRet(n,"IT_BASESOL")
			endif
			if FG_POSVAR("VVG_ICMRET") > 0
				M->VVG_ICMRET := acols[n,FG_POSVAR("VVG_ICMRET")] := MaFisRet(n,"IT_VALSOL")
			endif
			if FG_POSVAR("VVG_PISENT") > 0
				M->VVG_PISENT := aCols[n,FG_POSVAR("VVG_PISENT")] := ( MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2") )
			endif
			if FG_POSVAR("VVG_COFENT") > 0
				M->VVG_COFENT := aCols[n,FG_POSVAR("VVG_COFENT")] := ( MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2") )
			endif
			If FG_POSVAR("VVG_BASCOF") > 0
				M->VVG_BASCOF := aCols[n, FG_POSVAR("VVG_BASCOF")] := MaFisRet(n, "IT_BASECOF")
			EndIf
			If FG_POSVAR("VVG_ALICOF") > 0
				M->VVG_ALICOF := aCols[n, FG_POSVAR("VVG_ALICOF")] := MaFisRet(n, "IT_ALIQCOF")
			EndIf
			If FG_POSVAR("VVG_VALCOF") > 0
				M->VVG_VALCOF := aCols[n, FG_POSVAR("VVG_VALCOF")] := MaFisRet(n, "IT_VALCOF")
			EndIf
			If FG_POSVAR("VVG_BASPIS") > 0
				M->VVG_BASPIS := aCols[n, FG_POSVAR("VVG_BASPIS")] := MaFisRet(n, "IT_BASEPIS")
			EndIf
			If FG_POSVAR("VVG_ALIPIS") > 0
				M->VVG_ALIPIS := aCols[n, FG_POSVAR("VVG_ALIPIS")] := MaFisRet(n, "IT_ALIQPIS")
			EndIf
			If FG_POSVAR("VVG_VALPIS") > 0
				M->VVG_VALPIS := aCols[n, FG_POSVAR("VVG_VALPIS")] := MaFisRet(n, "IT_VALPIS")
			EndIf
			If FG_POSVAR("VVG_BAIMP5") > 0
				M->VVG_BAIMP5 := aCols[n, FG_POSVAR("VVG_BAIMP5")] := MaFisRet(n, "IT_BASECF2")
			EndIf
			If FG_POSVAR("VVG_ALIMP5") > 0
				M->VVG_ALIMP5 := aCols[n, FG_POSVAR("VVG_ALIMP5")] := MaFisRet(n, "IT_ALIQCF2")
			EndIf
			If FG_POSVAR("VVG_VLIMP5") > 0
				M->VVG_VLIMP5 := aCols[n, FG_POSVAR("VVG_VLIMP5")] := MaFisRet(n, "IT_VALCF2")
			EndIf
			If FG_POSVAR("VVG_BAIMP6") > 0
				M->VVG_BAIMP6 := aCols[n, FG_POSVAR("VVG_BAIMP6")] := MaFisRet(n, "IT_BASEPS2")
			EndIf
			If FG_POSVAR("VVG_ALIMP6") > 0
				M->VVG_ALIMP6 := aCols[n, FG_POSVAR("VVG_ALIMP6")] := MaFisRet(n, "IT_ALIQPS2")
			EndIf
			If FG_POSVAR("VVG_VLIMP6") > 0
				M->VVG_VLIMP6 := aCols[n, FG_POSVAR("VVG_VLIMP6")] := MaFisRet(n, "IT_VALPS2")
			EndIf
			If FG_POSVAR("VVG_CF") > 0
				M->VVG_CF := aCols[n, FG_POSVAR("VVG_CF")] := MaFisRet(n, "IT_CF")
			EndIf
		endif
		//
		// ATUALIZA O FOLDER 1 (INFORMACOES DA NF)
		//
		VX000ATUF1("DESPESA")
		VX000ATUF1("FRETE")
		// ATUALIZA COMO PAGAR
		VX000ATUCP()
		//
	EndIf
//
Endif
//
RestArea( aArea )
//
Return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000LINOK  | Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Verifica se a linha da aCols esta coerente                   |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000LINOK(xTIPDOC)
Local nCntFor   := 0
Local cCposObr  := ""
Local aRetPE    := {}
Default xTIPDOC := "1" // Gerar ? ( 1 = NF / 2 = Mov.Interna (SD3) )

// VERIFICA OS CAMPOS OBRIGATORIOS
// O CAMPO VVG_LOCPAD INDICA O ALMOXARIFADO DE ENTRADA DO VEICULO E NAO PODE NUNCA
// ESTAR VAZIO ESSE CAMPO DEVE SER OBRIGATORIO EM UMA PROXIMA ATUALIZACAO DO ATUSX
//
// pula registros deletados
If aCols[n,len(aHeader)+1]
	Return .t.
EndIf

// Campos Obrigatorios quando NF, mesmo quando nao estao marcados como Obrigatorio no SX3 //
If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	cCposObr := "VVG_CODTES/VVG_LOCPAD/VVG_CODORI/VVG_SITTRI/VVG_ESTVEI/"
EndIf
For nCntFor:=1 to Len(aHeader)
	If ( aHeader[nCntFor,2] $ cCposObr .or. X3Obrigat(aHeader[nCntFor,2]) ) .and. Empty(aCols[n,nCntFor])
		Help("VX000LINOK",1,"OBRIGAT2",,RetTitle(aHeader[nCntFor,2]),4,1)
		Return .f.
	EndIf
Next
// CASO ESTEJA NA ROTINA AUTOMATICA DEVEMOS CHAMAR O FIELDOK
// UMA VEZ PARA INICIALIZAR AS VARIAVEIS FISCAIS
If lVX000Auto
	VX000FIELDOK()
EndIf
//
if GetNewPar("MV_PCOMVEI","0") == "1"
	cStatus := Posicione("VV1",2,xFilial("VV1")+GDFieldGet("VVG_CHASSI",n),"VV1_ESTVEI")
	If cStatus == "0" .And. cX0OpeMov == "0"
		If Empty(GDFieldGet("VVG_NUMPED",n))
			Aviso(STR0017,STR0072,{"Ok"})//"Veiculo novo. Favor informar numero do pedido de compra!"
			return .f.
		EndIf
	EndIf
endif
//
If ExistBlock('PEV000LOK')
	aRetPE := ExecBlock('PEV000LOK')
	if aRetPE[1]
		if !Empty(aRetPE[2])
			M->VVF_FORPRO := "1"
			M->VVF_SERNFI := "R"
			M->VVF_NUMNFI := aRetPE[2]
		endif
		return .t.
	else
		return .f.
	endif
EndIf

Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000TUDOK  | Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |                                                              |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function VX000TUDOK(nOpc,xTIPDOC)
Local nCntFor   := 0
Local nConta    := 0
Local cCposObr  := ""
Local nValorPar := 0
Local nValorDoc := 0
Local oVeiculos := DMS_Veiculo():New()

Default xTIPDOC := "1" // Gerar ? ( 1 = NF / 2 = Mov.Interna (SD3) )

If nOpc == 4 .or. nOpc == 2 .or. nOpc == 5
	Return .t.
EndIf

If xTIPDOC == "2" // 2 = Mov.Interna (SD3)\
	Return .t.
EndIf

If xTIPDOC == "4" // 4 = Movimento de Producao - SIGAPCP
	Return .t.
EndIf

// SE DER OK NA JANELA DIRETO DO ACOLS NAO PASSA PELO LINOK. CHAMA-SE A FUNCAO AQUI
If !VX000LINOK(xTIPDOC) .and. !lVX000Auto
	Return .f.
EndIf
// VERIFICA O NRO DE LINHAS DIGITADAS
For nCntFor = 1 to len(aCols)
	If !aCols[nCntFor,len(aCols[nCntFor])]
		nConta++
	EndIf
Next
If nConta == 0
	FMX_HELP("VEIX000E04",STR0043) //Nao existe nenhuma linha valida nos itens da nota fiscal. ## atencao
	Return .f.
EndIf
//
// Campos Obrigatorios quando NF, mesmo quando nao estao marcados como Obrigatorio no SX3 //
If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	cCposObr := "VVF_FORPAG/"
EndIf
// VERIFICACOES DOS CAMPOS OBRIGATORIOS DA ENCHOICE
For nCntFor:=1 to Len(acpoEncS)
	If ( acpoEncS[nCntFor] $ cCposObr .or. X3Obrigat(acpoEncS[nCntFor]) ) .and. Empty(&("M->"+acpoEncS[nCntFor]))
		Help(" ",1,"OBRIGAT2",,acpoEncS[nCntFor],4,1)
		Return .f.
	EndIf
Next
//
If M->VVF_FORPRO == "0"
	If Empty(M->VVF_NUMNFI)
		Help(" ",1,"OBRIGAT2",,RetTitle("VVF_NUMNFI"),4,1)
		Return .f.
	EndIf
EndIf
If lAtuFiscal // Atualiza Fiscal
	If !MaFisFound('NF')
		VX000RDVFOR()
		If !MaFisFound('NF')
			// TRANSFORMAR EM HELP
			HELP(" ",1,"NVAZIO",,STR0044,4,1)//Favor preencher os dados da nota fiscal.
			Return .f.
		EndIf
	EndIf
	// CARREGA AITEPARC
	If lVX000Auto
		// Ajusta valor do Frete neste ponto, pois quando se trata de ExecAuto,
		//	o frete estava sendo ZERADO no fiscal...
		If M->VVF_TOTFRE > 0
			MaFisRef("NF_FRETE","VVG00",M->VVF_TOTFRE)
		EndIf
		//
		VX000ATUCP()
	EndIf

	// VERIFICACOES DE COMO PAGAR
	// Valor das Parcelas
	nValorPar := 0
	For nCntFor := 1 to Len(aIteParc)
		nValorPar += aIteParc[nCntFor,2]
	Next

	// Valor do Documento
	nValorDoc := VX0000036_AtualizaValorPelaMoedaETaxaMoeda()

	// Verificação de valores divergentes
	If nValorPar # nValorDoc .and. !(cX0OpeMov $ "578") .and. !PARxTIPDOC $ "3/4"
		// TRANSFORMAR EM HELP
		HELP(" ",1,"NVAZIO",,STR0045,4,1)//Valor dos titulos diverge do valor da nota fiscal
		Return .f.
	EndIf
EndIf

// Validar Data da Movimentacao de cada Veiculo e verificar ARMAZENS
For nCntFor := 1 to len(aCols)
	If !aCols[nCntFor,len(aHeader)+1]
		If oVeiculos:DtUltimaMovimentacao(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")]) > M->VVF_DATMOV // Valida referente a Data do Movimento
			FMX_HELP("VX000TUDOK",STR0130 + CRLF + CRLF + aCols[nCntFor,FG_POSVAR("VVG_CHASSI")] ) // Chassi com movimentacao posterior a data deste movimento.
			Return .f.
		EndIf
		DBSelectArea("NNR")
		If !DBSeek(xFilial("NNR") + aCols[nCntFor,FG_POSVAR("VVG_LOCPAD")])
			If !(MsgYesNo(STR0046+" '"+aCols[nCntFor,FG_POSVAR("VVG_LOCPAD")]+"' "+STR0047+CHR(10)+CHR(13)+STR0048+" '"+Alltrim(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])+"' ?"))//O armazem # nao existe no sistema # Deseja cria-lo para o chassi
				Return .f.
			EndIf
		EndIf
	EndIf
Next
//
// Ponto de Entrada para validacao
If ( ExistBlock("VX000TOK") )
	lRet := ExecBlock("VX000TOK",.F.,.F.)
	If !lRet
		return .f.
	EndIf
EndIf
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    |VX000TSAIR  | Autor | Andre Luis Almeida    | Data | 25/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | SAIR DA JANELA PRINCIPAL VEIXX000                            |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function VX000TSAIR(nOpc,cX0OpeMov)
Local lRet := .t.
// Ponto de Entrada para validacao
If ( ExistBlock("VX000SAI") )
	lRet := ExecBlock("VX000SAI",.F.,.F.,{nOpc,cX0OpeMov})
EndIf
Return lRet

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000ALTFIN |Autor  |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Permite alteracao das datas dos titulos                      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000ALTFIN(nCel)
//
Local nOpca := 0
Local nPar1  := 0
Local nSoma1 := nSoma2 := nSoma3 := 0
Local dNovaData := aIteParc[nCel,1]
Local nNovoValor:= aIteParc[nCel,2]
Local valorMax := 0
Local nCntFor
//
//If nCel == Len(aIteParc)
//	Return
//EndIf
//
DBSelectArea("SE4")
DBSetOrder(1)
DBSeek(xFilial("SE4")+M->VVF_FORPAG)
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

DEFINE MSDIALOG oDlgFin TITLE STR0010 From 18,43 to 25,76 of oMainWnd //Parcelas

@ 010, 025 SAY STR0014 SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_BLUE//data
@ 010, 048 MSGET oNovaData  VAR dNovaData  PICTURE "@D" VALID !EMPTY(dNovaData) ;
SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_HBLUE WHEN (Alltrim(SE4->E4_TIPO)=="A")
@ 021, 025 SAY   STR0007 SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_BLUE //valor
@ 021, 048 MSGET oNovoValor VAR nNovoValor PICTURE "@E 999,999,999.99" ;
VALID (nNovoValor > 0 .AND. nNovoValor<=valorMax )  SIZE 58,08 OF oDlgFin ;
PIXEL COLOR CLR_HBLUE WHEN (nCel # Len(aIteParc).and.Alltrim(SE4->E4_TIPO)=="A")
//

DEFINE SBUTTON FROM 38,60 TYPE 1 ACTION (nOpca := 1,oDlgFin:End()) ENABLE OF oDlgFin
DEFINE SBUTTON FROM 38,95 TYPE 2 ACTION (nOpca := 2,oDlgFin:End()) ENABLE OF oDlgFin
ACTIVATE MSDIALOG oDlgFin CENTER

if nOpca == 1
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
##|Fun‡„o    |VX000ATUCP  |Autor  |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Atualiza contas a pagar                                      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000ATUCP()
//
Local nCntFor := 0
Local nValor  := 0
Local aAux    := {}

DBSelectArea("SE4")
DBSetOrder(1)
DBSeek(xFilial("SE4")+M->VVF_FORPAG)
//
If lAtuFiscal // Atualiza Fiscal
	If lVX000Auto
		If Alltrim(SE4->E4_TIPO) # "A"
			// Verificação de Moeda e Taxa Moeda
			nValor := VX0000036_AtualizaValorPelaMoedaETaxaMoeda()
			aAux   := Condicao(nValor, M->VVF_FORPAG,, M->VVF_DATEMI)
			aIteParc := {}
			For nCntFor := 1 to len(aAux)
				aAdd(aIteParc,{aAux[nCntFor,1],aAux[nCntFor,2],{}})
				VX0000041_CarregaDefaultCamposCustomizadosParcelas(len(aIteParc))
			Next
		EndIf
		//
		Return
	EndIf
	If Alltrim(SE4->E4_TIPO) # "A"
		dDataIni := ctod(" ")
		nDias1P := 0
		nParcel := 0
		nInterv := 0

		// Verificação de Moeda e Taxa Moeda
		nValor := VX0000036_AtualizaValorPelaMoedaETaxaMoeda()
		aAux   := Condicao(nValor, M->VVF_FORPAG,, M->VVF_DATEMI)
		aIteParc := {}
		For nCntFor := 1 to len(aAux)
			aAdd(aIteParc,{aAux[nCntFor,1],aAux[nCntFor,2],{}})
			VX0000041_CarregaDefaultCamposCustomizadosParcelas(len(aIteParc))
		Next

		oDatIni:disable()
		oDias1P:disable()
		oParcel:disable()
		oInterv:disable()
	Else
		If nDias1P==0 .and. nParcel==0 .and. nInterv==0
			dDataIni := M->VVF_DATEMI
			oDatIni:enable()
			oDias1P:enable()
			oParcel:enable()
			oInterv:enable()
			nParcel := 1
			If Len(aIteParc)<=1
				VX000CALPAR()
			Endif
		Else
			If Len(aIteParc)<=1
				VX000CALPAR()
			Endif
		EndIf
	EndIf
EndIf
If Empty(aIteParc)
	aIteParc := { { ctod("") , 0 , {} } }
	VX0000041_CarregaDefaultCamposCustomizadosParcelas(1)
EndIf

If (FM_PILHA("VEIXA001")) // Somente Entrada de Veiculos por Compra
	If Alltrim(SE4->E4_TIPO) == "A" // Somente quando SE4 for do tipo Negociada
		If ExistBlock("VX000PAR") // chamar PE que possibilita customizar o aIteParc e/ou preencher os campos adicionais customizadaos no aIteParc[x,3]
			aIteParc := ExecBlock("VX000PAR",.f.,.f.,{aIteParc,aParcCust})
		EndIf
	EndIf
EndIf

oLbParc:nAt := 1
oLbParc:SetArray(aIteParc)
oLbParc:refresh()
oDatIni:refresh()
oDias1P:refresh()
oParcel:refresh()
oInterv:refresh()
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000CALPAR |Autor  |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Calcula as parcelas do contas a pagar                        |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000CALPAR()
Local nCntFor := 0
Local nValor  := 0
If lAtuFiscal // Atualiza Fiscal
	// Verificação de Moeda e Taxa Moeda
	nValor := VX0000036_AtualizaValorPelaMoedaETaxaMoeda()
EndIf
if nValor == 0
	return .t.
endif
//
If Empty(M->VVF_FORPAG)
	MsgInfo(STR0049,STR0017) //A forma de pagamento nao foi preenchida. # Atencao
	Return
EndIf
If (nParcel < 1) .or. (nParcel > nValor)
	MsgInfo(STR0050,STR0017)//Os dados para calculo das percelas nao foram preenchidos corretamente. # Atencao
	Return
EndIf

aIteParc := {}
nValBase := Round(nValor / nParcel ,2)

For nCntFor := 1 to nParcel
	aAdd(aIteParc, {(dDataIni + nDias1P) + ((nCntFor - 1)*nInterv ) , nValBase , {} } )
	VX0000041_CarregaDefaultCamposCustomizadosParcelas(len(aIteParc))
Next
//
nResto := nValor - (nValBase * nParcel)
//
aIteParc[1,2] += nResto
//
oLbParc:nAt := 1
oLbParc:SetArray(aIteParc)
oLbParc:refresh()
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000CANPAR |Autor  |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Cancela contas a pagar                                       |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000CANPAR(nTp)
Default nTp := 0
aIteParc := { { ctod("") , 0 , {} } }
VX0000041_CarregaDefaultCamposCustomizadosParcelas(1)
If nTp == 0
	dDataIni := ctod(" ")
	nDias1P := 0
	nParcel := 0
	nInterv := 0
EndIf
oLbParc:nAt := 1
oLbParc:SetArray(aIteParc)
oLbParc:refresh()
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000GRV    |Autor  |  Luis Delorme         | Data | 20/12/08 |##
##+----------+--------------+-------+---------------------+------+----------+##
##|Descri‡„o | Gravacao da nota fiscal de entrada                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
0#+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000GRV(nOpc,cX0OpeMov,xSX5NumNota,xTIPDOC)
Local lRet          := .f.
Default xSX5NumNota := {.t.,"",""}
Default xTIPDOC     := "1" // 1=NF / 2=SD3 (Mov.Internas)
//
lMsErroAuto := .f.
//
If nOpc == 5 .or. nOpc == 4
	//#############################################################################
	//# CANCELAMENTO DA NOTA FISCAL                                               #
	//#############################################################################
	lRet := VX000CANCEL()
	If !lRet
		If ! lVX000Auto
			If lMsErroAuto
				MostraErro()
				Break
			EndIf
		EndIf
		Return .f.
	EndIf
	// Ponto de Entrada Depois do Cancelamento da Nota Fiscal
	If lRet
		If ExistBlock("VX000DCA")
			ExecBlock("VX000DCA",.f.,.f.,{nOpc,cX0OpeMov})
		EndIf
	EndIf
ElseIf nOpc == 3
	//#############################################################################
	//# EMISSAO DA NOTA FISCAL                                                    #
	//#############################################################################
	// SE A ROTINA FISCAL SE PERDEU POR ALGUM MOTIVO O PROCESSO DEVE SER REINICIADO
	If lAtuFiscal .and. !MaFisFound('NF')
		MsgInfo(STR0069,STR0053+": VX000E01")//Ocorreu um erro inesperado # Favor contactar o administrador do sistema. # Codigo
		Return .f.
	EndIf
	// Ponto de Entrada Antes da Gravacao da Nota Fiscal
	If ExistBlock("VX000ANF")
		ExecBlock("VX000ANF",.f.,.f.,{nOpc,cX0OpeMov})
	EndIf
	//
	lRet := VX000EMINF(nOpc,xSX5NumNota,xTIPDOC)
	If !lRet
		If lMsErroAuto
			MostraErro()
		EndIf
		Return .f.
	EndIf
	// Ponto de Entrada Depois da Gravacao da Nota Fiscal
	If lRet
		If ExistBlock("VX000DNF")
			ExecBlock("VX000DNF",.f.,.f.,{nOpc,cX0OpeMov})
		EndIf
	EndIf
EndIf
//
If !lVX000Auto
	oDlg:End()
EndIf
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000EMINF  | Autor |  Luis Delorme         | Data | 31/07/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |Gravacao e Integracao de Veiculos Normais                     |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000EMINF(nOpc,xSX5NumNota,xTIPDOC)
Local nCntFor, nCntFor2
Local cClasFis     := ""
Local nL

Local cQuery       := ""
Local cVVAFil      := ""
Local cQAlAux      := "SQLAUX"
Local cQAlVAZ      := "SQLVAZ"
Local cQAlVS9      := "SQLVS9"
Local cQAlSE1      := "SQLSE1"
Local cMsgVAZ      := ""
Local c9Parcel     := ""
Local c9TipPag     := ""
Local cNumTit      := ""
Local cDMSPrefOri  := GetNewPar("MV_PREFVEI","VEI")
Local nRecNoVS9    := 0
Local nRecNoVAZ    := 0
Local lBaixarSE1   := .f.
Local aChassiMov   := {}
Local nCntForDel
Local lTIPMOV      := ( VVF->(FieldPos("VVF_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )
Local lVVF_TIPDOC  := ( VVF->(FieldPos("VVF_TIPDOC")) > 0 ) // Gerar: 1=NF / 2=SD3 (Mov.Internas)
Local aSB1SD3      := {}
Local aFilAtu      := FWArrFilAtu()
Local aSM0         := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt   := cFilAnt
Local nCont        := 0
Local cFilVVA      := "("
Local lVV1Comp     := .t.
Local cFilVV1      := xFilial("VV1")
Local cSqlVVA      := "SQLVVA"
Local aVV1         := {}
Local i            := 0
Local lD1_CC       := SD1->(FieldPos("D1_CC")) > 0
Local lVVGCENCUS   := VVG->(FieldPos("VVG_CENCUS")) > 0
Local lD1CONTA     := SD1->(FieldPos("D1_CONTA")) > 0
Local lVVGCONTA    := VVG->(FieldPos("VVG_CONTA")) > 0
Local lD1ITECT     := SD1->(FieldPos("D1_ITEMCTA")) > 0
Local lVVGITECT    := VVG->(FieldPos("VVG_ITEMCT")) > 0
Local lD1CLVL      := SD1->(FieldPos("D1_CLVL")) > 0
Local lVVGCLVL     := VVG->(FieldPos("VVG_CLVL")) > 0
Local lVVGFCICD    := VVG->(FieldPos("VVG_FCICOD")) > 0
Local lD1FCICOD    := SD1->(FieldPos("D1_FCICOD")) > 0
Local lCpoALIQII   := SD1->(FieldPos("D1_ALIQII")) > 0 .And. VVG->(FieldPos("VVG_ALIQII")) > 0
Local lCpoII       := SD1->(FieldPos("D1_II")) > 0 .And. VVG->(FieldPos("VVG_II")) > 0
Local lCpoBASCOF   := SD1->(FieldPos("D1_BASECOF")) > 0 .And. VVG->(FieldPos("VVG_BASCOF")) > 0
Local lCpoALICOF   := SD1->(FieldPos("D1_ALQCOF")) > 0 .And. VVG->(FieldPos("VVG_ALICOF")) > 0
Local lCpoVALCOF   := SD1->(FieldPos("D1_VALCOF")) > 0 .And. VVG->(FieldPos("VVG_VALCOF")) > 0
Local lCpoBASPIS   := SD1->(FieldPos("D1_BASEPIS")) > 0 .And. VVG->(FieldPos("VVG_BASPIS")) > 0
Local lCpoALIPIS   := SD1->(FieldPos("D1_ALQPIS")) > 0 .And. VVG->(FieldPos("VVG_ALIPIS")) > 0
Local lCpoVALPIS   := SD1->(FieldPos("D1_VALPIS")) > 0 .And. VVG->(FieldPos("VVG_VALPIS")) > 0
Local lCpoBAIMP5   := SD1->(FieldPos("D1_BASIMP5")) > 0 .And. VVG->(FieldPos("VVG_BAIMP5")) > 0
Local lCpoALIMP5   := SD1->(FieldPos("D1_ALQIMP5")) > 0 .And. VVG->(FieldPos("VVG_ALIMP5")) > 0
Local lCpoVLIMP5   := SD1->(FieldPos("D1_VALIMP5")) > 0 .And. VVG->(FieldPos("VVG_VLIMP5")) > 0
Local lCpoBAIMP6   := SD1->(FieldPos("D1_BASIMP6")) > 0 .And. VVG->(FieldPos("VVG_BAIMP6")) > 0
Local lCpoALIMP6   := SD1->(FieldPos("D1_ALQIMP6")) > 0 .And. VVG->(FieldPos("VVG_ALIMP6")) > 0
Local lCpoVLIMP6   := SD1->(FieldPos("D1_VALIMP6")) > 0 .And. VVG->(FieldPos("VVG_VLIMP6")) > 0
Local lCpoCF       := SD1->(FieldPos("D1_CF")) > 0 .And. VVG->(FieldPos("VVG_CF")) > 0
//
Local lCpoNFORI    := SD1->(FieldPos("D1_NFORI"))   > 0 .and. VVG->(FieldPos("VVG_NFORI"))  > 0
Local lCpoSERORI   := SD1->(FieldPos("D1_SERIORI")) > 0 .and. VVG->(FieldPos("VVG_SERORI")) > 0
Local lCpoITEORI   := SD1->(FieldPos("D1_ITEMORI")) > 0 .and. VVG->(FieldPos("VVG_ITEORI")) > 0
//
Local lRet         := .t.
Local nOpcSB1      := 3
Local aVetSB1      := {}
Local oVeiculos    := DMS_Veiculo():New()
//
Local cFilOrig := "" // Filial de Origem ( Filial da Saida )
//
Local lVVD_FILENT := VVD->(FieldPos("VVD_FILENT")) <> 0
//
Local cTpFrete := ""
//
Local nTotDesp := 0
//
Private aIteNFE    := {}
Private aCabNFE    := {}

Default xSX5NumNota:= {.t.,"",""}
Default xTIPDOC    := "1" // 1=NF / 2=SD3 (Mov.Internas)

if cX0OpeMov == "0" // Entrada p/ Compra
	For nCont := 1 to Len(aSM0)
		cFilAnt := aSM0[nCont]
		If lVV1Comp .and. cFilVV1 <> xFilial("VV1") // Verifica se o VV1 nao eh compartilhado
			lVV1Comp := .f.
		EndIf
		cFilVVA += "'"+xFilial("VVA")+"',"
	Next
	cFilAnt := cBkpFilAnt
	cFilVVA := left(cFilVVA,len(cFilVVA)-1)+")"
Endif
lReturn := VX000Help(M->VVF_FORPRO,M->VVF_ESPECI)
if !lReturn
	Return(.f.)
Endif

//
// TODAS AS VERIFICACOES JA FORAM REALIZADAS
// AS ROTINAS FISCAIS ESTAO CARREGADAS E DISPONIVEIS
// RESTA AGORA GRAVAR AS TABELAS VVF,VVG,SB1,VV1 e INTEGRAR COM FATURAMENTO
// MATA103 (NFE) e COM FINANCEIRO FINA050
//
For nCntFor := 1 to len(acols)
	n := nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	FGX_AMOVVEI(xFilial("VV1"),aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
next
//#######################
//# Gravacao do VVF     #
//#######################
dbSelectArea("VVF")
lRemito := .f.
If !(cPaisLoc == "BRA") .AND. Alltrim(M->VVF_SERNFI) =="R"
	lRemito := .T.
endif

If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	If M->VVF_FORPRO == "1"//Formulario Proprio = Sim
		lRemito:= .f.
		if Alltrim(M->VVF_SERNFI) =="R"
			lRemito := .t.
		elseIf !(cPaisLoc == "BRA")
			nOpcAviso := Aviso(STR0054,STR0055,{STR0056,STR0057}) //Faturamento # Escolha o tipo de documento a ser emitido # Nota Fiscal # Remito
			if nOpcAviso == 1
				lRemito := .f.
			else
				lRemito := .t.
			endif
		endif
		if lRemito
			cSerie := "R  "
			if Empty(M->VVF_NUMNFI)
				cNumero := NxtSX5Nota("R  ", NIL, GetNewPar("MV_TPNRNFS","1"))
			else
				cNumero := M->VVF_NUMNFI
				lMudouNum = .t.
			endif
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
			If GetNewPar("MV_TPNRNFS","1") == "3" // SD9
				cNumero := ""
			Endif
		endif
	EndIf
EndIf
//#############################################################################
//# INICIO DO CONTROLE DE TRANSACAO                                           #
//#############################################################################
BEGIN TRANSACTION

// QUANDO FOR FORMULARIO PROPRIO IGUAL A SIM E O PARAMETRO MV_TPNRNFS FOR IGUAL A 3 -> EMISSAO DE NOTAS PELO SD9
// O CONTEUDO DA VARIVEL cNumero PODE SER ALTERADO NO MOMENTO DA CHAMADA DO MATA103

dbSelectArea("VVF")
M->VVF_TRACPA := GetSxENum("VVF","VVF_TRACPA")
ConfirmSx8()

If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	If M->VVF_FORPRO == "1" //Formulario Proprio = Sim
		If !(lMudouNum) .and. lRemito
			cNumero := NxtSX5Nota(cSerie, NIL, GetNewPar("MV_TPNRNFS","1"))
		EndIf
		M->VVF_NUMNFI := cNumero
		M->VVF_SERNFI := cSerie
	Else
		cNumero := M->VVF_NUMNFI
		cSerie := M->VVF_SERNFI
	EndIf
	//
	dbSelectArea("VVF")
	dbSetOrder(6)
	// SE FOI ENCONTRADA NF PARA ESSA TRANSACAO HOUVE UM ERRO
	If VVF->(dbSeek(xFilial("VVF")+cNumero+cSerie + M->VVF_CODFOR + M->VVF_LOJA))
		If VVF->VVF_SITNFI # "0"
			MsgInfo(STR0058,STR0017) //Ja existe nota fiscal com a numeracao escolhida. # atencao
			DisarmTransaction()
			lMSErroAuto := .t.
			Return .f.
		EndIf
	EndIf
EndIf
// CALCULA O NUMERO DE VEICULOS DIGITADOS
For nCntFor = 1 to len(aCols)
	If !aCols[nCntFor,len(aCols[nCntFor])]
		M->VVF_QTDVEI := M->VVF_QTDVEI + 1
	EndIf
Next
// MONTA OS CAMPOS DO VVF DEPENDENTES DE FISCAL
If lAtuFiscal // Atualiza Fiscal
	DBSelectArea("SX3")
	DBSetOrder(1)
	DBSeek("VVF")
	while SX3->X3_ARQUIVO=="VVF"
		cValid	:= AllTrim(UPPER(SX3->X3_VALID))
		If "MAFISREF"$cValid
			nPosRef := AT('MAFISREF("',cValid) + 10
			if AT('","VX000",',cValid) > 0
				cRefCols:=Substr(cValid,nPosRef,AT('","VX000",',cValid)-nPosRef )
				&("M->"+X3_CAMPO):= MaFisRet(,cRefCols)
			endif
		EndIf
		DbSkip()
	enddo
EndIf
// DA RECLOCK NA TABELA PARA INCLUIR REGISTRO
If !RecLock("VVF",.t.)
	Help("  ",1,"REGNLOCK")
	DisarmTransaction()
	RollBackSX8()
	Return .f.
EndIf

M->VVF_ALIICM := 0

// GRAVA TODOS OS CAMPOS QUE ESTAO NA MEMORIA
FG_GRAVAR("VVF")
//
VVF->VVF_FILIAL := xFilial("VVF")
VVF->VVF_SITNFI := "1" // Valida
VVF->VVF_QTDVEI := M->VVF_QTDVEI
VVF->VVF_DTHEMI := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo
VVF->VVF_OPEMOV := cX0OpeMov

If lTIPMOV
	VVF->VVF_TIPMOV := "0" // 0 = Normal
EndIf

If lVVF_TIPDOC
	VVF->VVF_TIPDOC := xTIPDOC // 1=NF / 2=SD3 (Mov.Internas)
EndIf

If lMoeda
	VVF->VVF_MOEDA  := nMoedaCor
	VVF->VVF_TXMOED := nTaxaMoeda
EndIf

// Gravar campos customizáveis da VVF
If Len(aCposUser) > 0
	For nCntFor := 1 to Len(aCposUser)
		If !Empty(aCposUser[nCntFor]) .And. GetSx3Cache(aCposUser[nCntFor], "X3_PROPRI") == "U";
			.And. GetSx3Cache(aCposUser[nCntFor], "X3_CONTEXT") == "R" // Campo customizável real
			&("VVF->" + aCposUser[nCntFor]) := &("M->" + aCposUser[nCntFor])
		EndIf
	Next
EndIf
//
MSMM(VVF->VVF_OBSMEM,TamSx3("VVF_OBSERV")[1],,VVF_OBSERV,1,,,"VVF","VVF_OBSMEM")
MSMM(VVF->VVF_OBSMNF,TamSx3("VVF_OBSENF")[1],,VVF_OBSENF,1,,,"VVF","VVF_OBSMNF")
MsUnlock()
//#############################
//# Fim da Gravacao do VVF    #
//#############################
nRecVVF := VVF->(Recno())
nSlv := n			// Salva a variavel n do acols

nCntForDel := 0
For nCntFor = 1 to len(acols)
	// JANELA DE ABORTO
	If VX000ABORT()
		DisarmTransaction()
		RollBackSX8()
		Return .f.
	EndIf
	n := nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	nCntForDel ++
	//################################################
	//# Calculo do Custo do Veiculo                  #
	//################################################
	DBSelectArea("VV1")
	DBSetOrder(2)
	DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])

	if cX0OpeMov == "0" // Entrada p/ Compra
		aAdd(aVV1,{VV1->(Recno())})
	Endif

	DBSelectArea("VV2")
	DBSetOrder(1)
	DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD)
	DBSelectArea("VVH")
	DBSetOrder(1)
	DbSeek(xFilial("VVH")+VVG->VVG_CODIND)
	DBSelectArea("VVG")
	FG_MEMVAR()

	nCustoVeiculo := 0
	If M->VVG_ESTVEI == "0" //Novo
		If !Empty(VV2->VV2_FORCUS)       //Modelo do Veiculo
			nCustoVeiculo := FGX_FORMULA(VV2->VV2_FORCUS)
		ElseIf !Empty(VE4->VE4_FORCTB)   //Parametros da Montadora do Custo Contabil
			nCustoVeiculo := FGX_FORMULA(VE4->VE4_FORCTB)
		EndIf
	Else // Usado
		cFor := GetMv("MV_VUCCTB")
		If !Empty(cFor)
			nCustoVeiculo := FG_FORMULA(cFor)
		EndIf
	EndIf
	If nCustoVeiculo <= 0
		If lAtuFiscal .and. MaFisFound('NF') // Atualiza Fiscal
			nCustoVeiculo := MaFisRet(nCntFor,"IT_TOTAL")
		Else
			nCustoVeiculo := M->VVG_VALUNI
		EndIf
	EndIf

	lGrCodInd := .f.
	if cX0OpeMov $ "24578" // Remessa / Consignado / Devolução / Ret Remessa / Ret Consig
		aMovsRem := FGX_VEIMOVS( aCols[nCntFor,FG_POSVAR("VVG_CHASSI")] , "S")
		if Len(aMovsRem) > 0
			DBSelectArea("VVA")
			DBSetOrder(1)
			DBSeek(aMovsRem[1,2]+aMovsRem[1,3]+aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
			nCustoVeiculo := VVA->VVA_VCAVEI
			cCodIndRem :=  VVA->VVA_CODIND
			lGrCodInd := .t.
		endif
	Elseif cX0OpeMov == "3" // Tranferencia
		aMovsTrf := FGX_VEIMOVS( aCols[nCntFor,FG_POSVAR("VVG_CHASSI")] , "S")
		if Len(aMovsTrf) > 0
			DBSelectArea("VVA")
			DBSetOrder(1)
			DBSeek(aMovsTrf[1,2]+aMovsTrf[1,3]+aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
			cCodIndRem :=  VVA->VVA_CODIND
			lGrCodInd := .t.
			cFilOrig := aMovsTrf[1,2] // Filial de Origem - referente a Saida por Transferencia
		endif
	endif
	//################################################################
	//# Gravacao do VVG                                              #
	//################################################################
	DBSelectArea("VV1")
	DBSetOrder(2)
	If !(DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VVG_CHASSI")]))
		DisarmTransaction()
		RollBackSX8()
		MsgInfo(STR0070,STR0053+": VX000E03")//Ocorreu um erro inesperado # Favor contactar o administrador do sistema # Codigo
		Return .f.
	EndIf
	dbSelectArea("VVG")
	RecLock("VVG",.t.)
	FG_GRAVAR("VVG",aCols,aHeader,nCntFor)
	VVG->VVG_FILIAL := xFilial("VVG")
	VVG->VVG_TRACPA := VVF->VVF_TRACPA
	VVG->VVG_CHAINT := VV1->VV1_CHAINT
	if !cX0OpeMov $ "03" .or. xTIPDOC == "2" .or. xTIPDOC == "4" // ( Compra e Transferencia ) OU ( Gerar SD3 (Mov.Interna) ) OU Prov. Producao - SIGAPCP
		VVG->VVG_VCNVEI := nCustoVeiculo
	Endif
	if lGrCodInd
		VVG->VVG_CODIND := cCodIndRem
	endif
	//
	If Len(aAutoAux) >= nCntFor
		If lCpoNFORI
			nPos := ascan(aAutoAux[nCntFor],{|x| x[1] == "D1_NFORI" })
			If nPos > 0
				VVG->VVG_NFORI := aAutoAux[nCntFor,nPos,2]
			EndIf
		EndIf
		If lCpoSERORI
			nPos := ascan(aAutoAux[nCntFor],{|x| x[1] == "D1_SERIORI" })
			If nPos > 0
				VVG->VVG_SERORI := aAutoAux[nCntFor,nPos,2]
			EndIf
		EndIf
		If lCpoITEORI
			nPos := ascan(aAutoAux[nCntFor],{|x| x[1] == "D1_ITEMORI" })
			If nPos > 0
				VVG->VVG_ITEORI := aAutoAux[nCntFor,nPos,2]
			EndIf
		EndIf
	EndIf
	//
	MsUnlock()
	lLivreDebito := .f.
	if cX0OpeMov == "0" // compra
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica baixa do veículo dado como entrada em atendimentos  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If VS9->(FieldPos("VS9_PARCEL"))>0

			If VV1->VV1_CHASSI == aCols[nCntFor,FG_POSVAR("VVG_CHASSI")]
				cMsgVAZ := ""
				lBaixarSE1 := .f.
				////////////////////////////////////////////////////
				// Utilizar somente a ultima AVALIACAO do Veiculo //
				////////////////////////////////////////////////////
				cQuery := "SELECT VAZ.R_E_C_N_O_ VAZRECNO , VAZ.VAZ_CODIGO , VAZ.VAZ_TIPAVA , VAZ.VAZ_APROVA FROM "+RetSqlName("VAZ")+" VAZ WHERE "
				cQuery += "VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ.VAZ_CHASSI='"+VV1->VV1_CHASSI+"' AND VAZ.D_E_L_E_T_=' '"
				cQuery += "ORDER BY VAZ.VAZ_REVISA DESC"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAZ, .F., .T. )
				If !( cQAlVAZ )->( Eof() )
					If ( cQAlVAZ )->( VAZ_APROVA ) == "0" // Avaliacao nao Aprovada
						cMsgVAZ := STR0073+VV1->VV1_CHASSI+". "+ STR0074// "Existe avaliação não aprovada para o chassi " "Impossivel continuar."
					Else
						If ( cQAlVAZ )->( VAZ_TIPAVA ) == "1" // Troca
							///////////////////////////
							// Verificar Atendimento //
							///////////////////////////
							cQuery := "SELECT VV9.VV9_STATUS , VV9.VV9_NUMATE , VV0.VV0_NUMNFI , VS9.R_E_C_N_O_ VS9RECNO , VS9.VS9_PARCEL , VS9.VS9_DATBAI , VS9.VS9_TIPPAG FROM "+RetSqlName("VS9")+" VS9 "
							cQuery += "INNER JOIN "+RetSQLName("VV0")+" VV0 ON 	( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_NUMTRA=VS9.VS9_NUMIDE AND VV0.D_E_L_E_T_=' ' ) "
							cQuery += "INNER JOIN "+RetSQLName("VV9")+" VV9 ON 	( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.D_E_L_E_T_=' ' ) "
							cQuery += "WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_TIPOPE='V' AND VS9.VS9_REFPAG='"+( cQAlVAZ )->( VAZ_CODIGO )+"' AND VS9.D_E_L_E_T_=' '"
							dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS9, .F., .T. )
							If !( cQAlVS9 )->( Eof() )
								////////////////////////////////////////////////////////////////
								// Verificar se o Atendimento esta 'Aprovado' ou 'Finalizado' //
								////////////////////////////////////////////////////////////////
								If !( ( cQAlVS9 )->( VV9_STATUS ) $ "L/F" ) .and. GetNewPar("MV_BLQVEIU","S") == "S"
									cMsgVAZ := STR0075+( cQAlVS9 )->( VV9_NUMATE )+STR0076+VV1->VV1_CHASSI+"."+STR0074
								Else

									/////////////////////////////////////////////////////////////////////
									// Baixar automaticamente o Titulo correspondente ao Veiculo Usado //
									/////////////////////////////////////////////////////////////////////
									If Empty(( cQAlVS9 )->( VS9_DATBAI )) .and. GetNewPar("MV_BCRVEIU","S") == "S"
										cNumTit := "V"+Right(( cQAlVS9 )->( VV9_NUMATE ),TamSx3("E1_NUM")[1]-1)
										If GetNewPar("MV_TITATEN","0") == "0" // Gera Titulo na Finalizacao
											If !Empty(( cQAlVS9 )->( VV0_NUMNFI ))
												cNumTit := ( cQAlVS9 )->( VV0_NUMNFI )
											EndIf
										EndIf
										c9Parcel   := ( cQAlVS9 )->( VS9_PARCEL )
										c9TipPag   := ( cQAlVS9 )->( VS9_TIPPAG )
										lBaixarSE1 := .t.
									EndIf
								EndIf
							Else
								cMsgVAZ := STR0077+VV1->VV1_CHASSI+STR0074
							EndIf
							nRecNoVS9  := ( cQAlVS9 )->( VS9RECNO )
							nRecNoVAZ  := ( cQAlVAZ )->( VAZRECNO )
							( cQAlVS9 )->( dbCloseArea() )
						EndIf
					EndIf
				EndIf
				( cQAlVAZ )->( dbCloseArea() )
				DbSelectArea("VAZ")
				If !Empty(cMsgVAZ)
					MsgStop(cMsgVAZ,STR0017)
					DisarmTransaction()
					RollBackSX8()
					return .f.
				EndIf
				If lBaixarSE1
					//
					DBSelectArea("SF4")
					DBSetOrder(1)
					DBSeek(xFilial("SF4")+aCols[nCntFor,FG_POSVAR("VVG_CODTES")])
					if Alltrim(SF4->F4_DUPLIC) == "S"
						MsgStop(STR0078,STR0017) // "Para compra de veiculos envolvidos em troca utilize um T.E.S. que não gere titulos. Impossivel continuar."
						DisarmTransaction()
						RollBackSX8()
						return .f.
					Endif
					//
					lLivreDebito := .t.
					//
					///////////////////////////////////////////////////////////////////
					// Baixar Titulo no SE1 - Titulo correspondente ao Veiculo Usado //
					///////////////////////////////////////////////////////////////////
					cQuery := "SELECT SE1.R_E_C_N_O_ AS RECSE1 FROM " + RetSQLName("SE1") + " SE1 WHERE SE1.E1_FILIAL='" + xFilial("SE1") + "' AND SE1.E1_NUM='"+cNumTit+"' AND SE1.E1_PREFORI='"+cDMSPrefOri+"' AND "
					cQuery += "SE1.E1_PARCELA='"+Alltrim(c9Parcel)+"' AND SE1.E1_TIPO='"+Alltrim(c9TipPag)+"' AND SE1.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSE1, .F., .T. )
					While !( cQAlSE1 )->(Eof())
						DbSelectArea("SE1")
						DbGoTo(( cQAlSE1 )->RECSE1)
						aBaixa  := {{"E1_PREFIXO" ,E1_PREFIXO         ,Nil } ,;
						{"E1_NUM"	   ,E1_NUM             ,Nil } ,;
						{"E1_PARCELA"  ,E1_PARCELA         ,Nil } ,;
						{"E1_TIPO"	   ,E1_TIPO            ,Nil } ,;
						{"AUTMOTBX"	   ,"NOR"              ,Nil } ,;
						{"AUTDTBAIXA"  ,dDataBase          ,Nil } ,;
						{"AUTDTCREDITO",dDataBase          ,Nil } ,;
						{"AUTHIST"	  ,"BAIXA VEIC USADO"  ,Nil } ,;
						{"AUTVALREC"   ,SE1->E1_VALOR      ,Nil }}
						MSExecAuto({|x| FINA070(x)},aBaixa)
						If lMsErroAuto
							( cQAlSE1 )->( dbCloseArea() )
							DbSelectArea("SE1")
							DisarmTransaction()
							RollBackSX8()
							MostraErro()
							Return .f.
						EndIf
						( cQAlSE1 )->(dbSkip())
					EndDo
					( cQAlSE1 )->( dbCloseArea() )
					//////////////////////////
					// Atualiza arquivo VS9 //
					//////////////////////////
					DbSelectArea("VS9")
					DbGoto(nRecNoVS9)
					RecLock("VS9",.f.)
					VS9->VS9_DATBAI := ddatabase
					MsUnLock()
					//
				endif
				If nRecNoVAZ <> 0
					//////////////////////////
					// Atualiza arquivo VAZ //
					//////////////////////////
					DbSelectArea("VAZ")
					DbGoto(nRecNoVAZ)
					RecLock("VAZ",.f.)
					VAZ->VAZ_TRACPA := VVF->VVF_TRACPA
					VAZ->VAZ_FILENT := VVF->VVF_FILIAL
					MsUnLock()
					//
				EndIf
				DbSelectArea("SE1")
			endif
		endif
	EndIf
	//
	// Monta e verifica localização
	//
	//cLocaliz := left(GetNewPar("MV_RECVEIC","RECEPCAO VEIC")+space(TamSX3("D3_LOCALIZ")[1]),TamSX3("D3_LOCALIZ")[1])
	if GetNewPar("MV_LOCVZL","N")=="S" .and. !Empty(VVG->VVG_LOCPAD) .and. !Empty(VVG->VVG_LOCALIZ)  // USA LOCALIZACAO DE VEICULOS
		cLocaliz := VVG->VVG_LOCALIZ
		DBSelectArea("VZL")
		DBSetOrder(1)
		if DBSeek(xFilial("VZL")+VVG->VVG_LOCPAD+VVG->VVG_LOCALIZ)
			if VZL->VZL_QTDATU < VZL->VZL_QTDMAX
				reclock("VZL",.f.)
				VZL->VZL_QTDATU := VZL->VZL_QTDATU + 1
				msunlock()
			else
				DisarmTransaction()
				RollBackSX8()
				MsgInfo(STR0079+Alltrim(VVG->VVG_LOCPAD)+"/"+Alltrim(VVG->VVG_LOCALIZ)+STR0080,STR0017)
				return .f.
			endif
		endif
	endif
	//
	SF4->(DbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+VVG->VVG_CODTES))
	//################################################################
	//# Gravacao do VV1                                              #
	//################################################################
	If cX0OpeMov $ "0135" // COMPRAS, TRANSFERENCIA e DEVOLUCAO
		// Le SA1 e posiciona no codigo da propria concessionaria
		// O SA1 ficara, entao, posicionado no cliente que
		// representa a propria concessionaria
		DBSelectArea("SA1")
		dbSetOrder(3)
		lAchouSA1 := .F.
		aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
		cTexto = aSM0[18]
		nAt = At("-",cTexto)
		while nAt != 0
			cTexto := Subs(cTexto,1,nAt-1) + Subs(cTexto,nAt+1)
			nAt = At("-",cTexto)
		enddo
		If dbSeek(xFilial("SA1")+cTexto)
			lAchouSA1 := .t.
		EndIf
		If !lAchouSA1
			FMX_HELP("VEIX000E02",STR0081+" ["+aSM0[18]+"] "+STR0082+" "+STR0083)//A empresa com CNPJ nro ## nao esta cadastrada ## corretamente no cadastro de clientes. CNPJ nao encontrado
			DisarmTransaction()
			RollBackSX8()
			Return .f.
		EndIf
	ElseIf cX0OpeMov $ "24" // REMESSA e CONSIGNADO
		// NESSE CASO O CLIENTE JA ESTA POSICIONADO NO PREENCHIMENTO DA NF.
		// ELE EH O PROPRIETARIO DO VEICULO
		DBSelectArea("SA1")
		dbSetOrder(1)
		DBSeek(xFilial("SA1")+M->VVF_CODFOR+M->VVF_LOJA)
		lAchouSA1 := .t.
	EndIf
	//
	reclock("VV1",.f.)
	If cX0OpeMov $ "0135" // COMPRAS, TRANSFERENC e DEVOLUCAO
		VV1->VV1_PROATU := SA1->A1_COD
		VV1->VV1_LJPATU := SA1->A1_LOJA
		VV1->VV1_DOCIND := SA1->A1_CGC
		VV1->VV1_ESTVEI := VVG->VVG_ESTVEI
	EndIf
	If VV1->VV1_SITVEI == "1" .and. cX0OpeMov $ "05" // VEICULO JA VENDIDO E ESTA REALIZANDO UMA ENTRADA POR COMPRA OU POR DEVOLUCAO
		VV1->VV1_RESERV = "0"
		VV1->VV1_HORRES := stod("00000000")
		VV1->VV1_HORVEN := stod("00000000")
	EndIf
	VV1->VV1_LOCPAD := VVG->VVG_LOCPAD
	MsUnlock()

	//#############################################################################
	//# Gravacao do SB1                                                           #
	//#############################################################################
	If GetNewPar("MV_MIL0003","1") == "1"
		nOpcSB1 := 3 // Incluir
		dbSelectArea("SB1")
		cAuxCodSB1 := ""
		If FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			nOpcSB1 := 4 // Alterar
			cAuxCodSB1 := SB1->B1_COD
		endif
		aVetSB1 := {}
		aAdd(aVetSB1,{"B1_LOCPAD"  ,VVG->VVG_LOCPAD })
		If nOpcSB1 == 3 .OR. (nOpcSB1 == 4 .AND. Alltrim(SB1->B1_TE) == '')
			aAdd(aVetSB1,{"B1_TE"      ,VVG->VVG_CODTES })
		Endif
		aAdd(aVetSB1,{"B1_IPI"     ,VVG->VVG_ALIIPI })
		If VV1->(FieldPos("VV1_CONTA")) > 0
			If !Empty(VV1->VV1_CONTA)
				aAdd(aVetSB1,{"B1_CONTA"   ,VV1->VV1_CONTA  })
			EndIf
			If !Empty(VV1->VV1_CC)
				aAdd(aVetSB1,{"B1_CC"      ,VV1->VV1_CC     })
			EndIf
			If !Empty(VV1->VV1_ITEMCC)
				aAdd(aVetSB1,{"B1_ITEMCC"  ,VV1->VV1_ITEMCC })
			EndIf
			If !Empty(VV1->VV1_CLVL)
				aAdd(aVetSB1,{"B1_CLVL"    ,VV1->VV1_CLVL   })
			EndIf
		Else
			If !Empty(VVG->VVG_CONTA)
				aAdd(aVetSB1,{"B1_CONTA"   ,VVG->VVG_CONTA  })
			EndIf
			If !Empty(VVG->VVG_CENCUS)
				aAdd(aVetSB1,{"B1_CC"      ,VVG->VVG_CENCUS })
			EndIf
			If !Empty(VVG->VVG_ITEMCT)
				aAdd(aVetSB1,{"B1_ITEMCC"  ,VVG->VVG_ITEMCT })
			EndIf
			If !Empty(VVG->VVG_CLVL)
				aAdd(aVetSB1,{"B1_CLVL"    ,VVG->VVG_CLVL   })
			EndIf
		EndIf
		aAdd(aVetSB1,{"B1_PRV1"            ,VV1->VV1_SUGVDA })
		If !Empty(VV1->VV1_GRTRIB)
			aAdd(aVetSB1,{"B1_GRTRIB"      ,VV1->VV1_GRTRIB })
		EndIf
		If !Empty(VVG->VVG_SITTRI)
			aAdd(aVetSB1,{"B1_ORIGEM"      ,left(VVG->VVG_SITTRI,TamSX3("B1_ORIGEM")[1]) })
		Endif

		// Grupo TI
		If VV1->(FieldPos("VV1_GRPTI")) > 0 .and. SB1->(FieldPos("B1_GRPTI")) > 0
			aAdd(aVetSB1,{"B1_GRPTI"       ,VV1->VV1_GRPTI })
		EndIf
		//
		DbSelectArea("VV1")
		RegToMemory("VV1",.f.) // Cria variaveis de Memoria que podem ser utilizadas no PE VA010AB1
		//
		lRet := oVeiculos:CriaPeca(VV1->VV1_CHAINT,nOpcSB1,aVetSB1,"VA010AB1",cAuxCodSB1) // Inclui/Altera SB1 do Veiculo
		If !lRet
			DisarmTransaction()
			RollBackSX8()
			MostraErro()
			return .f.
		Endif
		//
	EndIf
	//
	dbSelectArea("SB1")
	dbSetOrder(1)
	If cUsaGrVA == "1" // Usa Veiculos de forma Agrupada por Modelo no SB1
		If ! FGX_VV2SB1()
			FMX_HELP("VEIX000E03",STR0121 + "(SB1)") // "Produto referente ao modelo de veículo não encontrado no cadastro de produtos."
			DisarmTransaction()
			RollBackSX8()
			Return .f.
		EndIf
	EndIf
	//
	if cX0OpeMov $ "57" // Devolução // Retorno de Remessa
		DBSelectArea("SD2")
		DBSetOrder(3)
		if !Empty(VV0->VV0_CLIALI) .and. VV0->VV0_CATVEN=="7"
			DBSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CLIALI+VV0->VV0_LOJALI+SB1->B1_COD)
		else
			DBSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CODCLI+VV0->VV0_LOJA+SB1->B1_COD)
		endif
		If lAtuFiscal // Atualiza Fiscal
			MaFisAlt("IT_RECORI",SD2->(Recno()),nCntFor)
		EndIf
		If VVF->(ColumnPos("VVF_TPFRET")) == 0
			DBSelectArea("SF2")
			DBSetOrder(1)
			If DBSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
				cTpFrete := SF2->F2_TPFRETE // Se Devolução, utilizar o mesmo Tipo de Frete da Saida
			EndIf
		EndIf
	Endif
	//
	cClasFis := VVG->VVG_SITTRI
	If Empty(Right(VVG->VVG_SITTRI,2))
		cClasFis := SB1->B1_ORIGEM+SF4->F4_SITTRIB
	Endif
	//
	aTemp := {}

	If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)

		aAdd(aTemp,{"D1_DOC"     ,VVF->VVF_NUMNFI							,Nil})
		aAdd(aTemp,{"D1_SERIE"   ,VVF->VVF_SERNFI							,Nil})
		aAdd(aTemp,{"D1_ITEM"    ,strzero(nCntForDel,TamSX3("D1_ITEM")[1])	,Nil})
		aAdd(aTemp,{"D1_COD"     ,SB1->B1_COD             					,Nil})
		aAdd(aTemp,{"D1_UM"      ,SB1->B1_UM             					,Nil})
		aAdd(aTemp,{"D1_QUANT"   ,1											,Nil})
		aAdd(aTemp,{"D1_VUNIT"   ,MaFisRet(nCntFor,"IT_VALMERC")			,Nil})
		aAdd(aTemp,{"D1_TOTAL"   ,MaFisRet(nCntFor,"IT_VALMERC")			,Nil})
		aAdd(aTemp,{"D1_EMISSAO" ,VVF->VVF_DATEMI							,Nil})
		aAdd(aTemp,{"D1_TES"     ,MaFisRet(nCntFor,"IT_TES")				,Nil})
		aAdd(aTemp,{"D1_VALFRE"  ,MaFisRet(nCntFor,"IT_FRETE")				,Nil})
		aAdd(aTemp,{"D1_PESO"    ,SB1->B1_PESBRU							,Nil})
		aAdd(aTemp,{"D1_RATEIO"  ,'2'                      					,Nil})
		aAdd(aTemp,{"D1_VALIPI"  ,MaFisRet(nCntFor,"IT_VALIPI")				,Nil})
		aAdd(aTemp,{"D1_IPI"     ,MaFisRet(nCntFor,"IT_ALIQIPI")			,Nil})
		aAdd(aTemp,{"D1_BASEIPI" ,MaFisRet(nCntFor,"IT_BASEIPI")			,Nil})
		aAdd(aTemp,{"D1_PICM"    ,MaFisRet(nCntFor,"IT_ALIQICM")			,Nil})
		aAdd(aTemp,{"D1_VALICM"  ,MaFisRet(nCntFor,"IT_VALICM")				,Nil})
		aAdd(aTemp,{"D1_BRICMS"  ,MaFisRet(nCntFor,"IT_BASESOL")			,Nil})
		aAdd(aTemp,{"D1_ICMSRET" ,MaFisRet(nCntFor,"IT_VALSOL") 			,Nil})
		aAdd(aTemp,{"D1_BASEICM" ,MaFisRet(nCntFor,"IT_BASEICM")			,Nil})
		aAdd(aTemp,{"D1_VALICM"  ,MaFisRet(nCntFor,"IT_VALICM")				,Nil})
		aAdd(aTemp,{"D1_VALDESC" ,MaFisRet(nCntFor,"IT_DESCONTO")			,Nil})
		aAdd(aTemp,{"D1_LOCAL"   ,VVG->VVG_LOCPAD          					,Nil})
		if !cX0OpeMov $ "03" // Compra e Transferencia
			aAdd(aTemp,{"D1_CUSTO"   ,nCustoVeiculo            				,Nil})
		Endif
		aAdd(aTemp,{"D1_CLASFIS" ,cClasFis	            					,Nil})
		aAdd(aTemp,{"D1_CHASSI" ,VV1->VV1_CHASSI           					,Nil})
		aAdd(aTemp,{"D1_PLACA"  ,VV1->VV1_PLAVEI           					,Nil})

		if lD1_CC .and. lVVGCENCUS .and. !Empty(VVG->VVG_CENCUS)
			aAdd(aTemp,{"D1_CC"  ,VVG->VVG_CENCUS          					,Nil})
		Endif
		if lD1CONTA .and. lVVGCONTA .and. !Empty(VVG->VVG_CONTA)
			aAdd(aTemp,{"D1_CONTA"  ,VVG->VVG_CONTA        					,Nil})
		Endif
		if lD1ITECT .and. lVVGITECT .and. !Empty(VVG->VVG_ITEMCT)
			aAdd(aTemp,{"D1_ITEMCTA"  ,VVG->VVG_ITEMCT     					,Nil})
		Endif
		if lD1CLVL .and. lVVGCLVL .and. !Empty(VVG->VVG_CLVL)
			aAdd(aTemp,{"D1_CLVL"  ,VVG->VVG_CLVL       					,Nil})
		Endif
		
		if lD1FCICOD .and. lVVGFCICD .and. !Empty(VVG->VVG_FCICOD)
			aAdd(aTemp,{"D1_FCICOD"  ,VVG->VVG_FCICOD     					,Nil})
		Endif

		If nOpc == 3 .and. cX0OpeMov == "5" // Somente INCLUIR e devolucao de Venda
			aAdd(aTemp,{"D1_DESPESA",0										,Nil}) // Zerar DESPESA, pois a Saida por Venda não utiliza o Valor da Despesa para calculo TOTAL do SF2.
		EndIf

		// Origem: NF / Serie / Item
		If lCpoNFORI .and. !Empty(VVG->VVG_NFORI)
			aAdd(aTemp,{"D1_NFORI",VVG->VVG_NFORI       					,Nil})
		Endif		
		If lCpoSERORI .and. !Empty(VVG->VVG_SERORI)
			aAdd(aTemp,{"D1_SERIORI",VVG->VVG_SERORI     					,Nil})
		Endif
		If lCpoITEORI .and. !Empty(VVG->VVG_ITEORI)
			aAdd(aTemp,{"D1_ITEMORI",VVG->VVG_ITEORI     					,Nil})
		Endif

		// Valor Importação
		If lCpoALIQII .And. !Empty(VVG->VVG_ALIQII)
			aAdd(aTemp,{"D1_ALIQII"  ,MaFisRet(nCntFor,"IT_ALIQII")			,Nil})
		EndIf
		If lCpoII .And. !Empty(VVG->VVG_II)
			aAdd(aTemp,{"D1_II"      ,MaFisRet(nCntFor,"IT_VALII")			,Nil})
		EndIf

		If (cPaisLoc == "BRA")
			// Cofins
			If lCpoBASCOF .And. !Empty(VVG->VVG_BASCOF)
				aAdd(aTemp,{"D1_BASECOF"  ,MaFisRet(nCntFor,"IT_BASECOF")		,Nil})
			EndIf
			If lCpoALICOF .And. !Empty(VVG->VVG_ALICOF)
				aAdd(aTemp,{"D1_ALQCOF"   ,MaFisRet(nCntFor,"IT_ALIQCOF")		,Nil})
			EndIf
			If lCpoVALCOF .And. !Empty(VVG->VVG_VALCOF)
				aAdd(aTemp,{"D1_VALCOF"  ,MaFisRet(nCntFor,"IT_VALCOF")			,Nil})
			EndIf

			// Pis
			If lCpoBASPIS .And. !Empty(VVG->VVG_BASPIS)
				aAdd(aTemp,{"D1_BASEPIS"  ,MaFisRet(nCntFor,"IT_BASEPIS")		,Nil})
			EndIf
			If lCpoALIPIS .And. !Empty(VVG->VVG_ALIPIS)
				aAdd(aTemp,{"D1_ALQPIS"   ,MaFisRet(nCntFor,"IT_ALIQPIS")		,Nil})
			EndIf
			If lCpoVALPIS .And. !Empty(VVG->VVG_VALPIS)
				aAdd(aTemp,{"D1_VALPIS"  ,MaFisRet(nCntFor,"IT_VALPIS")			,Nil})
			EndIf

			// CF2
			If lCpoBAIMP5 .And. !Empty(VVG->VVG_BAIMP5)
				aAdd(aTemp,{"D1_BASIMP5"  ,MaFisRet(nCntFor,"IT_BASECF2")		,Nil})
			EndIf
			If lCpoALIMP5 .And. !Empty(VVG->VVG_ALIMP5)
				aAdd(aTemp,{"D1_ALQIMP5"  ,MaFisRet(nCntFor,"IT_ALIQCF2")		,Nil})
			EndIf
			If lCpoVLIMP5 .And. !Empty(VVG->VVG_VLIMP5)
				aAdd(aTemp,{"D1_VALIMP5"  ,MaFisRet(nCntFor,"IT_VALCF2")		,Nil})
			EndIf

			// PS2
			If lCpoBAIMP6 .And. !Empty(VVG->VVG_BAIMP6)
				aAdd(aTemp,{"D1_BASIMP6"  ,MaFisRet(nCntFor,"IT_BASEPS2")		,Nil})
			EndIf
			If lCpoALIMP6 .And. !Empty(VVG->VVG_ALIMP6)
				aAdd(aTemp,{"D1_ALQIMP6"  ,MaFisRet(nCntFor,"IT_ALIQPS2")		,Nil})
			EndIf
			If lCpoVLIMP6 .And. !Empty(VVG->VVG_VLIMP6)
				aAdd(aTemp,{"D1_VALIMP6"  ,MaFisRet(nCntFor,"IT_VALPS2")		,Nil})
			EndIf

			// Código Fiscal
			If lCpoCF .And. !Empty(VVG->VVG_CF)
				aAdd(aTemp,{"D1_CF"  ,MaFisRet(nCntFor,"IT_CF")					,Nil})
			EndIf
		EndIf

		if Len(aAutoAux) >= nCntFor
			for nCntFor2 := 1 to Len(aAutoAux[nCntFor])
				aAdd(aTemp,aAutoAux[nCntFor,nCntFor2])
			next
		endif
		//
		aAdd(aIteNFE,aclone(aTemp))
	
		//Totaliza despesas para quando não vier calculado no VVF
		If nOpc == 3 .and. cX0OpeMov == "5" // Somente INCLUIR e devolucao de Venda
			nTotDesp += 0 // Zerar DESPESA, pois a Saida por Venda não utiliza o Valor da Despesa para calculo TOTAL do SF2.
		Else
			nTotDesp += MaFisRet(nCntFor,"IT_DESPESA")
		EndIf

	EndIf

Next
//
If VVF->VVF_FORPRO == "0" //Formulario Proprio = Nao
	cFormul := "N"
Else
	cFormul := "S"
EndIf
//
If cCliForA == "C"
	DBSelectArea("SA1")
	DBSetOrder(1)
	DbSeek(xFilial("SA1")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
Endif
//
If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	cEspecie:=Space(5)
	cTiposDoc:=Alltrim(SuperGetMv('MV_ESPECIE'))
	cTiposDoc:=StrTran(cTiposDoc,";",chr(13)+chr(10))
	nLinhas:=MLCount(cTiposDoc)
	For nL:=1 to nLinhas
		cEspecie:=Alltrim(StrTran(MemoLine(cTiposDoc,,nL),Chr(13),Chr(10)))
		nPosSign:=Rat("=",cEspecie)
		If nPosSign>0 .and. Alltrim(cSerie)==Alltrim(Substr(cEspecie,1,nPosSign-1)) // Heverson
			cEspecie:=Substr(cEspecie,nPosSign+1)
			SX5->(MsSeek(xFilial("SX5")+"42"+cEspecie))
			If SX5->(!Found())
				cEspecie:=Space(5)
			Endif
			Exit
		Else
			cEspecie:=Space(5)
		Endif
	Next
	//
EndIf

// VVF_OPEMOV: 0=Normal;1=Ped.Fabrica;2=Remessa;3=Transferencia;4=Consignacao;5=Devolucao;6=Frete;7=Retorno de Remessa;8=Retorno de Consignacao
cF1Tipo := "N"
Do Case
	Case cX0OpeMov <> "5" // Diferente de Devolucao
		If cCliForA == "C" // utiliza Cliente
			cF1Tipo := "B" // Beneficiamento
		EndIf

	Case cX0OpeMov $ "5" // Devolucao
		cF1Tipo := "D" // D-Devolucao

EndCase

SA2->(DbGoTop())
SA2->(dbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA))

If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)

	aAdd(aCabNFE,{"F1_TIPO"		, cF1Tipo	,Nil})
	aAdd(aCabNFE,{"F1_FORMUL"	,cFormul       	 											,Nil})
	aAdd(aCabNFE,{"F1_DOC"		,VVF->VVF_NUMNFI											,Nil})
	aAdd(aCabNFE,{"F1_SERIE"	,VVF->VVF_SERNFI											,Nil})
	If cF1Tipo <> "D"
		aAdd(aCabNFE,{"F1_COND"		,VVF->VVF_FORPAG 										,Nil})
	Endif
	aAdd(aCabNFE,{"F1_EMISSAO"	,VVF->VVF_DATEMI											,Nil})
	aAdd(aCabNFE,{"F1_FORNECE"	,VVF->VVF_CODFOR											,Nil})
	aAdd(aCabNFE,{"F1_LOJA"		,VVF->VVF_LOJA  											,Nil})
	
	If VVF->VVF_DESACE > 0
		aAdd(aCabNFE,{"F1_DESPESA"	,VVF->VVF_DESACE  											,Nil})
	Else
		aAdd(aCabNFE,{"F1_DESPESA"	,nTotDesp  											,Nil})
	EndIf
	aAdd(aCabNFE,{"F1_BRICMS"	,MaFisRet(,"NF_BASESOL")									,Nil})
	aAdd(aCabNFE,{"F1_ICMSRET"	,MaFisRet(,"NF_VALSOL")										,Nil})
	aAdd(aCabNFE,{"F1_FRETE"	,MaFisRet(,"NF_FRETE")										,Nil})
	If !Empty(cTpFrete)
		aAdd(aCabNFE,{"F1_TPFRETE"	,cTpFrete												,Nil})
	Else
		If VVF->(ColumnPos("VVF_TPFRET")) <> 0 .and. ! Empty(VVF->VVF_TPFRET)
			aAdd(aCabNFE,{"F1_TPFRETE"	,VVF->VVF_TPFRET										,Nil})
		EndIf
	EndIf
	aAdd(aCabNFE,{"F1_SEGURO"	,MaFisRet(,"NF_SEGURO")										,Nil})
	aAdd(aCabNFE,{"F1_VALMERC"	,MaFisRet(,"NF_VALMERC")									,Nil})
	aAdd(aCabNFE,{"F1_VALBRUT"	,MaFisRet(,"NF_TOTAL")										,Nil})
	aAdd(aCabNFE,{"F1_BASEICM"	,MaFisRet(,"NF_BASEICM")									,Nil})
	aAdd(aCabNFE,{"F1_VALICM"	,MaFisRet(,"NF_VALICM")										,Nil})
	aAdd(aCabNFE,{"F1_BASEIPI"	,MaFisRet(,"NF_BASEIPI")									,Nil})
	aAdd(aCabNFE,{"F1_VALIPI"	,MaFisRet(,"NF_VALIPI")										,Nil})
	aAdd(aCabNFE,{"F1_EST"		,iIf(cCliForA == "C",SA1->A1_EST,SA2->A2_EST)				,Nil})
	If VVF->(FieldPos("VVF_DEVMER")) > 0 .and. !Empty(VVF->VVF_DEVMER)
		aAdd(aCabNFE,{"F1_DEVMERC"	,VVF->VVF_DEVMER										,Nil})
	EndIf
	aAdd(aCabNFE,{"F1_PLIQUI"		,VVF->VVF_PLIQUI   ,Nil})
	aAdd(aCabNFE,{"F1_PBRUTO"		,VVF->VVF_PBRUTO   ,Nil})
	If VVF->(FieldPos("VVF_TRANSP")) > 0 .AND. !Empty(VVF->VVF_TRANSP)
		aAdd(aCabNFE,{"F1_TRANSP"  ,VVF->VVF_TRANSP  ,Nil})
	Endif
	aAdd(aCabNFE,{"F1_ESPECI1",VVF->VVF_ESPEC1  ,Nil})
	aAdd(aCabNFE,{"F1_VOLUME1" ,VVF->VVF_VOLUM1  ,Nil})
	aAdd(aCabNFE,{"F1_ESPECI2",VVF->VVF_ESPEC2  ,Nil})
	aAdd(aCabNFE,{"F1_VOLUME2" ,VVF->VVF_VOLUM2  ,Nil})
	aAdd(aCabNFE,{"F1_ESPECI3",VVF->VVF_ESPEC3  ,Nil})
	aAdd(aCabNFE,{"F1_VOLUME3" ,VVF->VVF_VOLUM3  ,Nil})
	aAdd(aCabNFE,{"F1_ESPECI4",VVF->VVF_ESPEC4  ,Nil})
	aAdd(aCabNFE,{"F1_VOLUME4" ,VVF->VVF_VOLUM4  ,Nil})

	If (cPaisLoc == "BRA")
		If M->VVF_FORPRO == "1"//Formulario Proprio = Sim
			If VVF->(FieldPos("VVF_ESPECI")) <> 0 .AND. !Empty(VVF->VVF_ESPECI)
				aAdd(aCabNFE,{"F1_ESPECIE"	,VVF->VVF_ESPECI    ,Nil})
			Else
				aAdd(aCabNFE,{"F1_ESPECIE" , cEspecie ,Nil})
			Endif
			if VVF->(FieldPos("VVF_MENPAD")) > 0 .and. SF1->(FieldPos("F1_MENPAD")) > 0
				aAdd(aCabNFE,{"F1_MENPAD" , VVF->VVF_MENPAD ,Nil})
			Endif
			if VVF->(FieldPos("VVF_MENNOT")) > 0 .and. SF1->(FieldPos("F1_MENNOTA")) > 0
				aAdd(aCabNFE,{"F1_MENNOTA" , VVF->VVF_MENNOT ,Nil})
			Endif
		Else
			if VVF->(FieldPos("VVF_ESPECI")) <> 0 .and. !Empty(VVF->VVF_ESPECI)
				aAdd(aCabNFE,{"F1_ESPECIE" , VVF->VVF_ESPECI ,Nil})
			else
				aAdd(aCabNFE,{"F1_ESPECIE" ,GetNewPar("MV_ESPECNF","NF"),Nil})
			endif
		Endif
	Else
		if cF1Tipo == "B"
			if lRemito
				aAdd(aCabNFE,{"F1_TIPODOC"	,"62"           												,Nil})
				aAdd(aCabNFE,{"F1_ESPECIE"	,"RCB"           												,Nil})
			else
				aAdd(aCabNFE,{"F1_TIPODOC"	,"12"           												,Nil})
				aAdd(aCabNFE,{"F1_ESPECIE"	,"NF"           												,Nil})
			endif
		elseif cF1Tipo == "D"
			if lRemito
				aAdd(aCabNFE,{"F1_TIPODOC"	,"51"           												,Nil})
				aAdd(aCabNFE,{"F1_ESPECIE"	,"RFD"           												,Nil})
			else
				aAdd(aCabNFE,{"F1_TIPODOC"	,"12"           												,Nil})
				aAdd(aCabNFE,{"F1_ESPECIE"	,"NF"           												,Nil})
			endif
		else // if cF1Tipo == "N"
			if lRemito
				aAdd(aCabNFE,{"F1_TIPODOC"	,"60"           												,Nil})
				aAdd(aCabNFE,{"F1_ESPECIE"	,"RCN"           												,Nil})
			else
				aAdd(aCabNFE,{"F1_TIPODOC"	,"10"           												,Nil})
				aAdd(aCabNFE,{"F1_ESPECIE"	,"NF"           												,Nil})
			endif
		endif
	endif

	If VVF->(FieldPos("VVF_CHVNFE")) > 0
		aAdd(aCabNFE,{"F1_CHVNFE"		,VVF->VVF_CHVNFE   ,Nil})
	endif

	If !Empty(cFilOrig) .and. SF1->(FieldPos("F1_FILORIG")) > 0
		aAdd(aCabNFE,{"F1_FILORIG"		, cFilOrig ,Nil}) // Filial de Origem ( Filial da Saida )
	EndIf

	// Veículo Transportador (Integração MATA103 - CI 008022)
	If VVF->(FieldPos("VVF_VEICU1")) > 0
		aAdd(aCabNFE,{"F1_VEICUL1"		,VVF->VVF_VEICU1   ,Nil})
	EndIf

	If VVF->(FieldPos("VVF_VEICU2")) > 0
		aAdd(aCabNFE,{"F1_VEICUL2"		,VVF->VVF_VEICU2   ,Nil})
	EndIf

	If VVF->(FieldPos("VVF_VEICU3")) > 0
		aAdd(aCabNFE,{"F1_VEICUL3"		,VVF->VVF_VEICU3   ,Nil})
	EndIf

	If VVF->(FieldPos("VVF_CLIRET")) > 0
		aAdd(aCabNFE,{"F1_FORRET"		,VVF->VVF_CLIRET   ,Nil})
		aAdd(aCabNFE,{"F1_LOJARET"		,VVF->VVF_LOJRET   ,Nil})
	EndIf

	If VVF->(FieldPos("VVF_CLIENT")) > 0
		aAdd(aCabNFE,{"F1_FORENT"		,VVF->VVF_CLIENT   ,Nil})
		aAdd(aCabNFE,{"F1_LOJAENT"		,VVF->VVF_LOJENT   ,Nil})
	EndIf

	// Moeda
	If VVF->(FieldPos("VVF_MOEDA")) > 0
		aAdd(aCabNFE,{"F1_MOEDA"		,VVF->VVF_MOEDA    ,Nil})
	EndIf
	If VVF->(FieldPos("VVF_TXMOED")) > 0
		aAdd(aCabNFE,{"F1_TXMOEDA"		,VVF->VVF_TXMOED   ,Nil})
	EndIf

	aAdd(aCabNFE,{"E2_NATUREZ"	,VVF->VVF_NATURE													,Nil})
	//
	// JANELA DE ABORTO
	//
	If VX000ABORT()
		RollBackSX8()
		Return .f.
	EndIf
	//
	//Chamada do MATA103 (Nota Fiscal de Entrada)
	//
	SF1->(dbSetOrder(1))
	SD1->(dbSetOrder(1))
	SB1->(dbSetOrder(1))
	//
	DbSelectArea("SF1")
	dbSetOrder(1)
	If dbSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA)
		DisarmTransaction()
		RollBackSX8()
		FMX_HELP("VEIX000E01",STR0059) //Numeracao de Nota Fiscal ja existente..."
		Return .f.
	EndIf
	//
	nAnt    := MAFISSAVE()
	MAFISEND()

EndIf

// Chamada de PE Antes da gravação da chamada do ExecAuto do Mata103
If ExistBlock("VX000AIN")
	ExecBlock("VX000AIN",.f.,.f.,{nOpc,cX0OpeMov})
Endif
//

If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)

	if !lRemito .and. M->VVF_FORPRO == "1" .and. xSX5NumNota[1] // Não é um Remito e Formulario Proprio = SIM
		cNumero := NxtSX5Nota(cSerie, NIL, GetNewPar("MV_TPNRNFS","1")) // Incrementa Nro Nota + 1
	EndIf
	If !(cPaisLoc == "BRA")
		if lRemito
			if cF1Tipo == "D"
				MsExecAuto({|x,y,z| Mata462DN(x,y,z) },aCabNFE,aIteNFE,3)
			else
				MsExecAuto({|x,y,z| MATA102N(x,y,z) },aCabNFE,aIteNFE,3)
			endif
		else
			MsExecAuto({|x,y,z| MATA101N(x,y,z) },aCabNFE,aIteNFE,3)
		endif
	else
		aCampos := {}
		MSExecAuto({|x,y| MATA103(x,y)},aCabNFE,aIteNFE)
	endif

	MAFISRESTORE(nAnt)

ElseIf xTIPDOC == "2" // 1=NF / 2=SD3 (Mov.Internas) - Agrega/Desagrega

	aSB1SD3    := {}
	SB1->(DbSetOrder(7))
	For nCntFor := 1 to len(aCols)
		FGX_VV1SB1("CHAINT", aCols[nCntFor,FG_POSVAR("VVG_CHAINT")] , /* cMVMIL0010 */ , cGruVei )
		// ( Codigo SB1 , Qtde , Valor , Centro de Custo , Conta Contab , Item Conta , Class.Valor )
		aAdd(aSB1SD3,{	SB1->B1_COD ,;
						1 ,;
						aCols[nCntFor,FG_POSVAR("VVG_VALUNI")] ,;
						aCols[nCntFor,FG_POSVAR("VVG_CENCUS")] ,;
						aCols[nCntFor,FG_POSVAR("VVG_CONTA")] ,;
						aCols[nCntFor,FG_POSVAR("VVG_ITEMCT")] ,;
						aCols[nCntFor,FG_POSVAR("VVG_CLVL")] })
	Next
	SB1->(DbSetOrder(1))
	If !VXX040SD3( "1" , "1" ,   , aSB1SD3 ) // Mov.Interna Peça ( 1=Entrada , 1=Tp.Normal , Codigo VDV , aSB1 )
		DisarmTransaction()
		RollBackSX8()
		Return .f.
	EndIf

EndIf
//
If lMsErroAuto
	DisarmTransaction()
	RollBackSX8()
	Return .f.
EndIf
// JANELA DE ABORTO
If VX000ABORT()
	DisarmTransaction()
	RollBackSX8()
	Return .f.
EndIf

if cX0OpeMov == "0" // Entrada p/ Compra
	For i := 1 to Len(aVV1)
		dbSelectArea("VV1")
		dbGoto(aVV1[i,1])
		cQuery := "SELECT VVA.R_E_C_N_O_ AS RECVVA "
		cQuery +=  " FROM " + RetSqlName("VVA") + " VVA "
		cQuery += "INNER JOIN "+RetSQLName("VV9")+" VV9 ON  VV9.VV9_FILIAL  = VVA.VVA_FILIAL AND VV9.VV9_NUMATE = VVA.VVA_NUMTRA AND VV9.VV9_STATUS NOT IN ('F','C') AND VV9.D_E_L_E_T_=' ' "
		If lVV1Comp // VV1 Compartilhado
			cQuery += " WHERE VVA.VVA_FILIAL IN " + cFilVVA + " AND "
		Else // VV1 Exclusivo
			cQuery += " WHERE VVA.VVA_FILIAL = '" + cFilVV1 + "' AND "
		Endif
		cQuery += "VVA.VVA_CHAINT = '" + VV1->VV1_CHAINT + "' AND VVA.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSqlVVA, .F., .T. )
		While !(cSqlVVA)->(Eof())
			DBSelectArea("VVA")
	       	DbGoTo((cSqlVVA)->(RECVVA))
			RecLock("VVA",.f.)
			If VVA->(FieldPos("VVA_CODMAR")) > 0 .and. !Empty(VVA->VVA_CODMAR)
				VVA->VVA_VCAVEI := FGX_CUSVEI(VVA->VVA_CHAINT , VVA->VVA_CODMAR , VVA->VVA_MODVEI , VV2->VV2_SEGMOD , VVA->VVA_CORVEI , dDataBase )
			Else
				VVA->VVA_VCAVEI := FGX_CUSVEI(VVA->VVA_CHAINT , VV1->VV1_CODMAR , VV1->VV1_MODVEI , VV2->VV2_SEGMOD , VV1->VV1_CORVEI , dDataBase )
			EndIf
			VVA->VVA_TOTCUS := FG_FORMULA(GetNewPar("MV_TOTCUFN","VVA->VVA_VCAVEI-VVA->VVA_REDCUS+VVA->VVA_JUREST+VVA->VVA_ACESSO+VVA->VVA_VDESCO+VVA->VVA_PISENT+VVA->VVA_COFENT"))
			VVA->VVA_TOTIMP := VVA->VVA_ICMVEN+VVA->VVA_ISSCVD+VVA->VVA_PISVEN+VVA->VVA_COFVEN+VVA->VVA_ISSRTE+VVA->VVA_PISRTE+VVA->VVA_ISSBFB+VVA->VVA_PISBFB
			VVA->VVA_LUCBRU := VVA->VVA_FATTOT-VVA->VVA_TOTIMP-VVA->VVA_VCAVEI
			VVA->VVA_LUCLQ1 := VVA->VVA_LUCBRU-VVA->VVA_JUREST-VVA->VVA_ACESSO-VVA->VVA_VDESCO-VVA->VVA_DESCLI-VVA->VVA_SEGVIA-VVA->VVA_VALASS-VVA->VVA_VALREV-VVA->VVA_DESVEI-VVA->VVA_ASSIMP-VVA->VVA_COMVDE-VVA->VVA_COMGER-VVA->VVA_COMPAT //LUCRO MARGINAL
			VVA->VVA_LUCLQ2 := VVA->VVA_LUCLQ1-VVA->VVA_DESFIX+(VVA->VVA_REDCUS+VVA->VVA_RECVEI-VVA->VVA_DSPFIN)
			MsUnlock()
			dbSelectArea(cSqlVVA)
			(cSqlVVA)->(dbSkip())
		Enddo
		(cSqlVVA)->(DbCloseArea())
	Next
Endif

DbSelectArea("VVF")
DbGoTo(nRecVVF)

If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)

	If M->VVF_FORPRO == "1" // Formulario Proprio = SIM
		DbSelectArea("VVF")
		RecLock("VVF",.f.)
		VVF->VVF_NUMNFI := SF1->F1_DOC
		MsUnlock()
		cNumero := SF1->F1_DOC
		M->VVF_NUMNFI := cNumero
	Endif

	if cX0OpeMov $ "03" // Compra e Transferencia
		//
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSelectArea("VVG")
		dbSetOrder(1)
		//
		If dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)

			While !EOF() .and. VVG->VVG_FILIAL == VVF->VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA

				DbSelectArea("SB1")
				If FGX_VV1SB1("CHAINT", VVG->VVG_CHAINT , /* cMVMIL0010 */ , cGruVei )

					If SD1->(dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD))
						RecLock("VVG",.F.)
						VVG->VVG_VCNVEI := SD1->D1_CUSTO
						MsUnLock()
					EndIf

				Endif
				dbSelectArea("VVG")
				DbSkip()
			Enddo
		Endif
		//
	EndIf

	If VVG->(FieldPos("VVG_NUMPED"))>0
		//VVF=Cabecalho da entrada de veiculo / VVG=Itens da entrada de veiculo
		dbSelectArea("VVG")
		dbSetOrder(1)
		If dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)

			While !EOF() .and. VVG->VVG_FILIAL == VVF->VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA
				
				If !Empty(VVG->VVG_NUMPED)
				
					//verifica se existe o pedido
					dbSelectArea("SC7")
					dbSetOrder(1)
					If dbSeek(xFilial("SC7")+VVG->VVG_NUMPED+VVG->VVG_ITPED)
						if 	SC7->C7_ENCER == "E" //Encerrado
							MsgStop(STR0084+Alltrim(SC7->C7_PRODUTO),STR0017) //"Não há saldo suficiente no pedido de compra para o produto "
							DisarmTransaction()
							RollBackSX8()
							Return .f.
						endif
						// Grava os dados na tabela SC7
						RecLock("SC7",.F.)
						SC7->C7_QUJE := SC7->C7_QUJE + 1     //Sempre somo um pq no VVG cada item eh um registro
						//Verifica Saldo Pedido
						If SC7->C7_QUANT == SC7->C7_QUJE
							SC7->C7_ENCER := "E" //Encerrado
						EndIf
						MsUnLock()
						//Localiza o codigo do produto no SB1
						FGX_VV1SB1("CHAINT", VVG->VVG_CHAINT , /* cMVMIL0010 */ , cGruVei )
						//Grava dados SD1
						dbSelectArea("SD1")
						dbSetOrder(1)
						If dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD)
							RecLock("SD1",.F.)
							D1_PEDIDO := VVG->VVG_NUMPED
							D1_ITEMPC := VVG->VVG_ITPED
							MsUnLock()
						EndIf

					EndIf

				EndIf

				dbSelectArea("VVG")
				DbSkip()
			Enddo
		EndIf
	EndIf

	//#############################################################################
	//# Gravacao dos Titulos a Pagar                                              #
	//#############################################################################
	// TODO: Considera Beneficiamento na geracao do titulo?
	DBSelectArea("SF1")
	DBSetOrder(1)
	DbSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA)
	//
	dbSelectArea("VVF")
	RecLock("VVF",.f.)
	if VVF->(FieldPos("VVF_TIPO")) > 0
		VVF->VVF_TIPO := SF1->F1_TIPO
	Endif
	if VVF->(FieldPos("VVF_RECSF1")) > 0
		VVF->VVF_RECSF1 := SF1->(Recno())
	Endif
	MsUnlock()

	DBSelectArea("SE4")
	DBSetOrder(1)
	DBSeek(xFilial("SE4")+SF1->F1_COND)
	lGeraTitulo:= (SE4->E4_TIPO == "A" .and. !lLivreDebito .and. Alltrim(SF4->F4_DUPLIC) == "S" .and. cX0OpeMov != "5")

	If lGeraTitulo
		dbSelectArea("SF1")
		RecLock("SF1",.f.)
		SF1->F1_DUPL    := SF1->F1_DOC
		SF1->F1_PREFIXO := &(GetNewPar("MV_2DUPREF","cSerie"))
		MsUnlock()
		//
		cCodBco2 := M->VVF_CODBCO
		cNumBord2:= ""
		dDatBord2:= cTod("")
		FG_Seek("SA6","cCodBco2",1,.f.)
		If SA6->A6_BORD == "0"
			cNumBord2 := "BCO"+SA6->A6_COD
			dDatBord2 := dDataBase
		EndIf
		For nCntFor := 1 to Len(aIteParc)
			aVetDesp := {}
			aAdd(aVetDesp,{"E2_PREFIXO"  ,&(GetNewPar("MV_2DUPREF","cSerie"))				,Nil})
			aAdd(aVetDesp,{"E2_NUM"      ,VVF->VVF_NUMNFI    								,Nil})
			aAdd(aVetDesp,{"E2_TIPO"     ,Iif(cX0OpeMov$"245","NCC","DP ")					,Nil})
			aAdd(aVetDesp,{"E2_NATUREZ"  ,VVF->VVF_NATURE    								,Nil})
			aAdd(aVetDesp,{"E2_PARCELA"  ,Strzero(nCntFor,TamSx3("E2_PARCELA")[1])			,Nil})
			aAdd(aVetDesp,{"E2_FORNECE"  ,M->VVF_CODFOR      								,Nil})
			aAdd(aVetDesp,{"E2_LOJA"     ,M->VVF_LOJA        								,Nil})
			aAdd(aVetDesp,{"E2_EMISSAO"  ,M->VVF_DATEMI										,Nil})
			aAdd(aVetDesp,{"E2_VENCTO"   ,aIteParc[nCntFor,1]								,Nil})
			aAdd(aVetDesp,{"E2_VALOR"    ,aIteParc[nCntFor,2]								,Nil})
			aAdd(aVetDesp,{"E2_VLCRUZ"   ,aIteParc[nCntFor,2]								,Nil})
			aAdd(aVetDesp,{"E2_NUMBOR"   ,cNumBord2   										,Nil})
			aAdd(aVetDesp,{"E2_PORTADO"  ,cCodBco2    										,Nil})
			If len(aIteParc[nCntFor]) >= 3
				For nCntFor2 := 1 to len(aParcCust)
					aAdd(aVetDesp,{aParcCust[nCntFor2,2], aIteParc[nCntFor,3,nCntFor2]		,Nil})
				Next
			EndIf
			If ExistBlock("VX000ICP") // Ponto de Entrada para alterar informações do Contas a Pagar
				aVetDesp := ExecBlock("VX000ICP", .f., .f., {aVetDesp})
			EndIf

			pergunte("FIN050",.F.)
			MsExecAuto({|x,y,z| FINA050(x,y,z)},aVetDesp)
			If lMsErroAuto
				DisarmTransaction()
				RollBackSX8()
				Return .F.
			EndIf
			cAliAntG := alias()
			DbSelectArea("SE2")
			reclock("SE2",.f.)
			SE2->E2_ORIGEM := "MATA100"
			SE2->E2_LA := "S"
			msunlock()
			DBSelectArea(cAliAntG)
		Next
	EndIf
	//#############################################################################
	//# Fim da Emissao da Nota Fiscal de Entrada                                  #
	//#############################################################################
	MAFISEND()
	// JANELA DE ABORTO
	If VX000ABORT()
		RollBackSX8()
		Return .f.
	EndIf

	if cX0OpeMov $ "5/7/8" // DEVOLUCAO/ RETORNO DE REMESSA/ RETORNO DE CONSIGNADO
		// ATUALIZA O STATUS DA NF PARA DEVOLVIDA
		cChave := ""
		if Len(aAutoAux) > 0
			nPos := ascan(aAutoAux[1],{|x| x[1] == "D1_NFORI" })
			if nPos != 0
				cChave := aAutoAux[1,nPos,2]
			endif
			nPos := ascan(aAutoAux[1],{|x| x[1] == "D1_SERIORI" })
			if nPos != 0
				cChave += aAutoAux[1,nPos,2]
			endif
			DBSelectArea("VV0")
			DBSetOrder(4)
			if DBSeek(xFilial("VV0")+cChave)
				reclock("VV0",.f.)
				VV0->VV0_SITNFI := "2"
				msunlock()
			endif
		endif
	endif

EndIf

// Integracao com BackOffice - NF de Entrada é digitada no BackOffice (SIGAEIC)
If xTIPDOC == "3"
	SF1->(DbSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA))
	//
	dbSelectArea("VVF")
	RecLock("VVF",.f.)
	VVF->VVF_TIPO := SF1->F1_TIPO
	VVF->VVF_RECSF1 := SF1->(Recno())
	MsUnlock()
	
	if cX0OpeMov $ "03" // Compra e Transferencia
		//
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSelectArea("VVG")
		dbSetOrder(1)
		dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
		While !EOF() .and. VVG->VVG_FILIAL == VVF->VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA

			If FGX_VV1SB1("CHAINT", VVG->VVG_CHAINT , /* cMVMIL0010 */ , cGruVei )

				If SD1->(dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD))
					RecLock("VVG",.F.)
					VVG->VVG_VCNVEI := SD1->D1_CUSTO
					MsUnLock()
				EndIf

			Endif
			dbSelectArea("VVG")
			DbSkip()
		Enddo
	Endif

EndIf

// ###############################################
// ATUALIZA O STATUS DO VEICULO                  #
// ###############################################
// ALTERA STATUS DOS VEICULOS
aChassiMov := {}

For nCntFor = 1 to len(acols)
	n := nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf

	aAdd(aChassiMov,{ aCols[nCntFor,FG_POSVAR("VVG_CHAINT")] , aCols[nCntFor,FG_POSVAR("VVG_CHASSI")] })

	dbSelectArea("SB1")
	dbSetOrder(7)
	DBSelectArea("SF4")
	DBSetOrder(1)
	MsSeek(xFilial("SF4")+aCols[nCntFor,FG_POSVAR("VVG_CODTES")])
	if SF4->F4_ESTOQUE == "S" .and. SF4->F4_PODER3 == "N"
		dbSelectArea("SB1")
		// Posiciona no Produto Correto 
		If FGX_VV1SB1("CHAINT", aChassiMov[Len(aChassiMov),1] , /* cMVMIL0010 */ , cGruVei )
			DbSelectArea("SB5")
			DbSetOrder(1)
			DbSeek( xFilial("SB5") + SB1->B1_COD )
			RecLock("SB5",!Found())
			SB5->B5_FILIAL  := xFilial("SB5")
			SB5->B5_COD     := SB1->B1_COD
			SB5->B5_LOCALI2 := M->VVG_LOCALIZ //GetNewPar("MV_RECVEIC","RECEPCAO VEIC")
			MsUnlock()
		EndIf
	endif
	// ATUALIZA IMOBILIZADO
	If ( Alltrim(SF4->F4_CF) == "1551" .or. SF4->F4_OPEMOV == "07" ) .and. VV1->VV1_IMOBI $ "0. "
		DbSelectArea("VV1")
		RecLock("VV1",.f.)
		VV1->VV1_IMOBI := "1"	// Imobilizado
		MsUnlock()
	Endif

Next

If cX0OpeMov <> "0" .and. cX0OpeMov <> "7" .and. cX0OpeMov <> "8"  // Diferente de Entrada por  0-Compra  7-Ret.Remessa  8-Ret.Consignacao
	////////////////////////////////////////
	// Levanta todas as Filiais VVA / VVD //
	////////////////////////////////////////
	cVVAFil := ""
	cQuery  := "SELECT DISTINCT VVA_FILIAL FROM "+RetSQLName("VVA")+" WHERE D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
	While !( cQAlAux )->( Eof() )
		cVVAFil += "'"+( cQAlAux )->( VVA_FILIAL )+"',"
		( cQAlAux )->( dbSkip() )
	EndDo
	( cQAlAux )->( dbCloseArea() )
	cVVAFil := IIf(!Empty(cVVAFil),left(cVVAFil,len(cVVAFil)-1),"'"+xFilial("VVA")+"'")
	//
	For nCntFor := 1 to Len(aChassiMov)
		/////////
		// VV1 //
		/////////
		VV1->(DbSetOrder(1)) // CHAINT
		VV1->(DbSeek(xFilial("VV1")+aChassiMov[nCntFor,1])) // CHAINT
		/////////
		// VVA //
		/////////
		cQuery := "SELECT R_E_C_N_O_ RECVVA FROM "+RetSQLName("VVA")+" WHERE "
		cQuery += "VVA_FILIAL IN ("+cVVAFil+") AND VVA_CHAINT='"+VV1->VV1_CHAINT+"' AND "
		cQuery += "VVA_FILENT='"+VV1->VV1_FILENT+"' AND VVA_TRACPA='"+VV1->VV1_TRACPA+"' AND D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
		While !( cQAlAux )->( Eof() )
			DbSelectArea("VVA")
			DbGoto(( cQAlAux )->( RECVVA ))
			RecLock("VVA",.f.)
			VVA->VVA_FILENT := VVF->VVF_FILIAL // Novo FILENT
			VVA->VVA_TRACPA := VVF->VVF_TRACPA // Novo TRACPA
			MsUnLock()
			( cQAlAux )->( dbSkip() )
		EndDo
		( cQAlAux )->( dbCloseArea() )
		/////////
		// VVD //
		/////////
		cQuery := "SELECT R_E_C_N_O_ RECVVD FROM "+RetSQLName("VVD")+" WHERE "
		If !lVVD_FILENT
			cQuery += "VVD_FILIAL='"+VV1->VV1_FILENT+"'"
		Else
			cQuery += "( ( VVD_FILIAL = '" + xFilial("VVD")  + "' AND VVD_FILENT = '" + VV1->VV1_FILENT + "' ) " // novos registros
			cQuery += "OR (VVD_FILIAL = '" + VV1->VV1_FILENT + "' AND VVD_FILENT = ' ' ) ) " // registro antigos
		Endif
		cQuery += " AND VVD_CHAINT='"+VV1->VV1_CHAINT+"'"
		cQuery += " AND VVD_TRACPA='"+VV1->VV1_TRACPA+"' AND D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
		While !( cQAlAux )->( Eof() )
			DbSelectArea("VVD")
			DbGoto(( cQAlAux )->( RECVVD ))
			RecLock("VVD",.f.)
			VVD->VVD_FILIAL := VVF->VVF_FILIAL // Novo FILENT
			VVD->VVD_TRACPA := VVF->VVF_TRACPA // Novo TRACPA
			MsUnLock()
			( cQAlAux )->( dbSkip() )
		EndDo
		( cQAlAux )->( dbCloseArea() )

	Next
EndIf
//
End Transaction
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
MsRUnLock()

If !lMsErroAuto

	DbSelectArea("VVF")
	DbGoTo(nRecVVF)

	If lMostraMsg
		If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
			FMX_TELAINF( "1" , { { Alltrim(VVF->VVF_SERNFI) , Alltrim(VVF->VVF_NUMNFI) , STR0060 } } ) // "EMITIDO"
		Else
			FMX_TELAINF( "4" , { { STR0102 , STR0060 } } ) // Mov.Interna / EMITIDO
		EndIf
	endif

	//
	// ALTERA STATUS DOS VEICULOS
	For nCntFor := 1 to Len(aChassiMov)
		//
		FGX_AMOVVEI(xFilial("VV1"),aChassiMov[nCntFor,2])

		If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)

			VV1->(dbSetOrder(2))
			VV1->(DBSEEK(xFilial("VV1")+aChassiMov[nCntFor,2]))

			If GetNewPar("MV_PERGVTR","N") == "S"

				If VV1->VV1_SITVEI == "0"
					// Declaracao da ParamBox
					aRet := {}
					aParamBox := {}
					aCombo := {"0-"+OemtoAnsi(STR0091),"2-"+OemtoAnsi(STR0092)}
					aAdd(aParamBox,{2,OemtoAnsi(STR0093),"1",aCombo,70,"",.F.}) // Tipo caractere
					//
					While !(ParamBox(aParamBox,"",@aRet))
					Enddo
					//
					cSitVei := Left(aRet[1],1)
					If cSitVei == "2"
						RecLock("VV1",.f.)
						VV1->VV1_SITVEI := cSitVei
						MsUnlock()
						If VV1->VV1_SITVEI == "2"
							DbSelectArea("VZK")
							RecLock("VZK",.t.)
							VZK_FILIAL := xFilial("VZK")
							VZK_CHASSI := VV1->VV1_CHASSI
							VZK_NUMNFI := VVF->VVF_NUMNFI
							VZK_SERNFI := VVF->VVF_SERNFI
							VZK_CODFOR := VVF->VVF_CODFOR
							VZK_LOJA   := VVF->VVF_LOJA
							VZK_DATENT := dDataBase // Data de Entrada do Veiculo em Transito
							MsUnlock()
						Endif
					Endif
				Endif
			Endif

			If FindFunction("VXX04REVJ1")
				VXX04REVJ1(aChassiMov[nCntFor,2],"","1")//realiza a reserva do veiculo - VEIXX004
			EndIf

		EndIf

	next
	//
	DbSelectArea("VVF")
	DbGoTo(nRecVVF)
	//
	//ConfirmSx8()
	//
	If VVF->VVF_FORPRO == "1"
		If ExistBlock("NFENTVEI")
			//Impressao da Nota Fiscal de Entrada
			ExecBlock("NFENTVEI",.f.,.f.,{VVF->VVF_NUMNFI,VVF->VVF_SERNFI,VVF->VVF_CODFOR,VVF->VVF_LOJA})
		Endif
	Endif
	//
	// Imprime termo de responsabilidade de multas do veiculo
	if GetNewPar("MV_RESPMUL","1") == "2"
		If ExistBlock("VA610MUL")
			ExecBlock("VA610MUL",.f.,.f.,{"2"})
		Endif
	Endif
EndIf
//
Return(.t.)
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000CANCEL | Autor |  Luis Delorme         | Data | 31/07/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |Cancelamento de Nota Fiscal - Veiculos Normais                |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000CANCEL()
Local nCntFor
Local cNumTit
Local cDMSPrefOri := GetNewPar("MV_PREFVEI","VEI")
Local lMVBCRVEIU  := (GetNewPar("MV_BCRVEIU","S") == "S")
Local cAliasSE1   := "TSE1"
Local aUltMov     := {}
Local nRecSF4     := 0
Local nRecVV1     := 0
Local lExcluiNF   := .t.

If VVF->VVF_TIPDOC == "2" // 1 = NF / 2 = Mov.Internas (SD3)
	MsgInfo(STR0101,STR0017) // Esta Entrada se trata de Mov.Interna. Impossivel continuar! / Atencao
	Return .f.
EndIf
If VVF->VVF_TIPDOC $ "3/4" // 3 = SIGAEIC - Nota Fiscal foi digitada no modulo de importacao / 4 = Mov. Interna de Produção - SIGAPCP
	lExcluiNF := .f.
EndIf
//
// VERIFICA SE A NF ESTA CANCELADA OU DEVOLVIDA
If VVF->VVF_SITNFI # "1"   // NF nao-valida
	FMX_HELP("VEIX000E08",STR0062 ) //Nota Fiscal esta cancelada ou devolvida # atencao
	lMsErroAuto := .t.
	Return .f.
EndIf
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Ponto de Entrada para validacao do Cancelamento de NF |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("VX000CNF")
	lRet := ExecBlock("VX000CNF",.f.,.f.)
	If !lRet
		lMsErroAuto := .t.
		Return.f.
	EndIf
EndIf
//
If VVF->VVF_TIPDOC $ "1/3"
	DBSelectArea("SF1")
	DBSetOrder(1)
	If !dbSeek(xFilial("SF1") + VVF->VVF_NUMNFI + VVF->VVF_SERNFI + VVF->VVF_CODFOR + VVF->VVF_LOJA)
		FMX_HELP("VEIX000E09", STR0071 + chr(13) + chr(10) + "VX000E05") //Ocorreu um erro inesperado # Favor contactar o administrador do sistema.","Codigo
		lMsErroAuto := .t.
		Return .f.
	EndIf
	//
	dbSelectArea("SD1")
	dbSetOrder(1)
	If !dbSeek(xFilial("SD1") + VVF->VVF_NUMNFI + VVF->VVF_SERNFI + VVF->VVF_CODFOR + VVF->VVF_LOJA)
		FMX_HELP("VEIX000E10", STR0071 + chr(13) + chr(10) + "VX000E06")//Ocorreu um erro inesperado # Favor contactar o administrador do sistema.","Codigo
		lMsErroAuto := .t.
		Return .f.
	EndIf
EndIf
// ARMAZENA A NF DE ORIGEM PARA ALTERAR STATUS DELA PARA
// VALIDA CASO HAJA CANCELAMENTO (quando cX0OpeMov = "5")
cChaveOri := SD1->D1_NFORI+SD1->D1_SERIORI
//
cStrSE2 := xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC
//
// Se existir Frete para a NF a ser cancelada, deve-se excluir o Conhecimento para
// so depois cancelar a NF Entrada. Caso haja mais NF's referente ao Conhecimento,
// deve-se incluir novamente este Conhecimento para ratear novamente seu valor as
// NF's restantes
//
For nCntFor = 1 to len(acols)
	n = nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	// JANELA DE ABORTO
	If VX000ABORT()
		Return .f.
	EndIf
	//
	// VERIFICAR SE A MOVIMENTACAO SELECIONADA EH A ULTIMA
	//
	FGX_AMOVVEI(xFilial("VV1"),aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
	DBSelectArea("VV1")
	DBSetOrder(2)
	DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
	If !(FM_PILHA("VEIXA040"))
		aUltMov := FGX_VEIMOVS( aCols[nCntFor,FG_POSVAR("VVG_CHASSI")] , , )
		If len(aUltMov) > 0
			If aUltMov[1,1] == "S" .or. aUltMov[1,2] <> VVF->VVF_FILIAL .or. aUltMov[1,3] <> VVF->VVF_TRACPA
				FMX_HELP("VEIX000E11",;
					STR0027 + CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
					STR0064 + " " + STR0065 + CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
					STR0066 + ": "+Alltrim(VV1->VV1_CHASSI)) ////Impossivel continuar # Um dos veiculos constantes da nota fiscal sofreu movimentacao # posterior a sua emissao # Chassi # Atencao
				lMSErroAuto := .t.
				Return .f.
			EndIf
		EndIf
	EndIf
Next
//#################################################################
//# Montagem dos Itens para integracao MATA103                    #
//#################################################################
aIteNFE := {}
BEGIN TRANSACTION
//
DbSelectArea("VS9")
if cX0OpeMov == "0" .and. VS9->(FieldPos("VS9_PARCEL"))>0

	cQryAl001 := GetNextAlias()
	cQuery := "SELECT VS9.VS9_PARCEL, VS9.VS9_TIPPAG, VS9.VS9_NUMIDE, VS9.R_E_C_N_O_ VS9RECNO, VAZ.R_E_C_N_O_ VAZRECNO , VV0_NUMNFI , VV0_NUMTRA "
	cQuery +=  " FROM "+RetSqlName("VAZ")+" VAZ JOIN "+RetSqlName("VS9")+" VS9 ON VS9.VS9_FILIAL ='"+xFilial("VS9")+"' AND VS9.VS9_REFPAG = VAZ.VAZ_CODIGO AND VS9.D_E_L_E_T_=' ' "
	cQuery +=  " JOIN "+RetSqlName("VV0")+" VV0 ON VV0.VV0_FILIAL = '"+xFilial("VV0")+"' AND VV0.VV0_NUMTRA = VS9.VS9_NUMIDE AND VV0.D_E_L_E_T_ = ' '"
	cQuery += " WHERE VAZ.VAZ_FILIAL ='"+xFilial("VAZ")+"'"
	cQuery +=   " AND VAZ.VAZ_TRACPA ='" + VVF->VVF_TRACPA + "'"
	cQuery +=   " AND VAZ.VAZ_FILENT ='" + VVF->VVF_FILIAL + "'"
	cQuery +=   " AND VAZ.D_E_L_E_T_ =' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
	While !(cQryAl001)->(Eof())

		// Estorna a baixa do titulo referente ao veiculo usado utilizado em atendimento
		If lMVBCRVEIU
			cNumTit := "V"+Right(( cQryAl001 )->( VV0_NUMTRA ),TamSx3("E1_NUM")[1]-1)
			If GetNewPar("MV_TITATEN","0") == "0" // Gera Titulo na Finalizacao
				If !Empty(( cQryAl001 )->( VV0_NUMNFI ))
					cNumTit := ( cQryAl001 )->( VV0_NUMNFI )
				EndIf
			EndIf

			cQuery := "SELECT E1_PREFIXO , E1_NUM , E1_PARCELA , E1_TIPO "
			cQuery +=  " FROM " + RetSQLName("SE1") + " SE1 "
			cQuery += " WHERE SE1.E1_FILIAL='" + xFilial("SE1") + "'"
			cQuery +=   " AND SE1.E1_NUM='"+cNumTit+"'"
			cQuery +=   " AND SE1.E1_PREFORI='"+cDMSPrefOri+"'"
			cQuery +=   " AND SE1.E1_PARCELA='"+Alltrim((cQryAl001)->VS9_PARCEL)+"'"
			cQuery +=   " AND SE1.E1_TIPO='"+Alltrim((cQryAl001)->VS9_TIPPAG)+"'"
			cQuery +=   " AND SE1.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSE1, .F., .T. )
			If !(cAliasSE1)->(Eof())
				aBaixa  := {;
					{"E1_PREFIXO"	,(cAliasSE1)->E1_PREFIXO	,Nil } ,;
					{"E1_NUM"		,(cAliasSE1)->E1_NUM		,Nil } ,;
					{"E1_PARCELA"	,(cAliasSE1)->E1_PARCELA	,Nil } ,;
					{"E1_TIPO"		,(cAliasSE1)->E1_TIPO	,Nil } ,;
					{"AUTMOTBX"		,"NOR"		,Nil } ,;
					{"AUTDTBAIXA"	,dDataBase	,Nil } ,;
					{"AUTDTCREDITO"	,dDataBase	,Nil }}
				//
				MSExecAuto({|x,y| FINA070(x,y)},aBaixa,5)
				//
				If lMsErroAuto
					(cQryAl001)->(dbCloseArea())
					(cAliasSE1)->(dbCloseArea())
					dbSelectArea(VVF)
					DisarmTransaction()
					MostraErro()
					Return .f.
				EndIf
			EndIf
			(cAliasSE1)->(dbCloseArea())
			//
			DBSelectArea("VS9")
			DBGoto((cQryAl001)->(VS9RECNO))
			reclock("VS9",.f.)
			VS9->VS9_DATBAI := ctod("00/00/00")
			msunlock()
			//
		EndIf // lMVBCRVEIU
		//

		DBSelectArea("VAZ")
		DBGoto((cQryAl001)->(VAZRECNO))
		reclock("VAZ",.f.)
		VAZ->VAZ_TRACPA := ""
		VAZ->VAZ_FILENT := ""
		msunlock()

		(cQryAl001)->(DBSkip())

	End
	(cQryAl001)->(dbCloseArea())
	dbSelectArea("VVF")

endif
//
dbSelectArea("SD1")
dbSetOrder(1)
dbSeek(xFilial("SD1") + VVF->VVF_NUMNFI + VVF->VVF_SERNFI + VVF->VVF_CODFOR + VVF->VVF_LOJA)
While !eof() .and. xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA == ;
	SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
	aTemp := {}
	//
	aAdd(aTemp,{"D1_DOC"    ,SD1->D1_DOC    ,Nil})
	aAdd(aTemp,{"D1_SERIE"  ,SD1->D1_SERIE  ,Nil})
	aAdd(aTemp,{"D1_FORNECE",SD1->D1_FORNECE,Nil})
	aAdd(aTemp,{"D1_LOJA"   ,SD1->D1_LOJA   ,Nil})
	aAdd(aTemp,{"D1_COD"    ,SD1->D1_COD    ,Nil})
	aAdd(aTemp,{"D1_ITEM"   ,SD1->D1_ITEM   ,Nil})
	If !Empty( SD1->D1_NFORI + SD1->D1_SERIORI )
		aAdd(aTemp,{"D1_NFORI"  ,SD1->D1_NFORI  ,Nil})
		aAdd(aTemp,{"D1_SERIORI",SD1->D1_SERIORI,Nil})
	EndIf
	//
	aAdd(aIteNFE,aclone(aTemp))
	//
	// Decrementa Localização
	//
	if GetNewPar("MV_LOCVZL","N")=="S"  // USA LOCALIZACAO DE VEICULOS
		DBSelectArea("SB1")
		DBSetOrder(1)
		DBSeek(xFilial("SB1")+SD1->D1_COD)
		//
		DBSelectArea("SB5")
		DBSetOrder(1)
		DBSeek(xFilial("SB5")+SD1->D1_COD)
		//
		if DBSeek(xFilial("VZL")+SB1->B1_LOCPAD + SB5->B5_LOCALI2)
			if VZL->VZL_QTDATU > 0
				reclock("VZL",.f.)
				VZL->VZL_QTDATU := VZL->VZL_QTDATU - 1
				msunlock()
			endif
		endif
		//
	endif
	//
	DBSelectArea("SD1")
	DbSkip()
	//
enddo
If lExcluiNF
	//#############################################################################
	//# Montagem do cabecalho para integracao MATA103                             #
	//#############################################################################
	aCabNFE   := {}
	//
	aAdd(aCabNFE,{"F1_DOC"		,VVF->VVF_NUMNFI,Nil})
	aAdd(aCabNFE,{"F1_SERIE"	,VVF->VVF_SERNFI,Nil})
	aAdd(aCabNFE,{"F1_FORNECE"	,VVF->VVF_CODFOR,Nil})
	aAdd(aCabNFE,{"F1_LOJA" 	,VVF->VVF_LOJA  ,Nil})
	aAdd(aCabNFE,{"F1_TIPO"		,SF1->F1_TIPO   ,Nil})
	aAdd(aCabNFE,{"F1_FORMUL"	,SF1->F1_FORMUL ,Nil})
	aAdd(aCabNFE,{"F1_EMISSAO"	,SF1->F1_EMISSAO,Nil})
	aAdd(aCabNFE,{"F1_ESPECIE"	,SF1->F1_ESPECIE,Nil})
	aAdd(aCabNFE,{"F1_COND"		,SF1->F1_COND   ,Nil})
	aAdd(aCabNFE,{"F1_EST"		,SF1->F1_EST    ,Nil})
	If VVF->(FieldPos("VVF_TRANSP")) > 0 .AND. !Empty(VVF->VVF_TRANSP)
		aAdd(aCabNFE,{"F1_TRANSP"  ,VVF->VVF_TRANSP  ,Nil})
	EndIf
	aAdd(aCabNFE,{"F1_ESPECIE1",VVF->VVF_ESPEC1  ,Nil})
	aAdd(aCabNFE,{"F1_VOLUME1" ,VVF->VVF_VOLUM1  ,Nil})
	aAdd(aCabNFE,{"F1_ESPECIE2",VVF->VVF_ESPEC2  ,Nil})
	aAdd(aCabNFE,{"F1_VOLUME2" ,VVF->VVF_VOLUM2  ,Nil})
	aAdd(aCabNFE,{"F1_ESPECIE3",VVF->VVF_ESPEC3  ,Nil})
	aAdd(aCabNFE,{"F1_VOLUME3" ,VVF->VVF_VOLUM3  ,Nil})
	aAdd(aCabNFE,{"F1_ESPECIE4",VVF->VVF_ESPEC4  ,Nil})
	aAdd(aCabNFE,{"F1_VOLUME4" ,VVF->VVF_VOLUM4  ,Nil})
	//
	lMsErroAuto := .f.
	MSExecAuto({|x,y,z|Mata103(x,y,z)},aCabNFE,aIteNFE,5)
	//
	If lMsErroAuto
		DisarmTransaction()
		Return .f.
	EndIf
EndIf
//
cTipoDP := Left("DP"+space(10),TamSX3("E2_TIPO")[1])
// Ponto de Entrada p/ excluir outros titulos
If ExistBlock("VM000EXC")
	ExecBlock("VM000EXC",.f.,.f.)
EndIf
//
If lExcluiNF
	DBSelectArea("SE2")
	DBSetOrder(6)
	DBSeek(cStrSE2)
	//
	while !eof() .and.	cStrSE2 == SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM
		// JANELA DE ABORTO
		If VX000ABORT()
			Return .f.
		EndIf
		DBSelectArea("SE2")
		//
		aVetDesp := {}
		aAdd(aVetDesp,{"E2_PREFIXO"  ,SE2->E2_PREFIXO	,Nil})
		aAdd(aVetDesp,{"E2_NUM"      ,SE2->E2_NUM    	,Nil})
		aAdd(aVetDesp,{"E2_TIPO"     ,SE2->E2_TIPO		,Nil})
		aAdd(aVetDesp,{"E2_NATUREZ"  ,SE2->E2_NATUREZ	,Nil})
		aAdd(aVetDesp,{"E2_PARCELA"  ,SE2->E2_PARCELA	,Nil})
		aAdd(aVetDesp,{"E2_FORNECE"  ,SE2->E2_FORNECE	,Nil})
		aAdd(aVetDesp,{"E2_LOJA"     ,SE2->E2_LOJA		,Nil})
		aAdd(aVetDesp,{"E2_EMISSAO"  ,SE2->E2_EMISSAO	,Nil})
		aAdd(aVetDesp,{"E2_VENCTO"   ,SE2->E2_VENCTO	,Nil})
		aAdd(aVetDesp,{"E2_VALOR"    ,SE2->E2_VALOR		,Nil})
		aAdd(aVetDesp,{"E2_VLCRUZ"   ,SE2->E2_VLCRUZ	,Nil})
		//
		pergunte("FIN050",.F.)
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z| FINA050(x,y,z)},aVetDesp,,5)
		If lMsErroAuto
			DisarmTransaction()
			Return .f.
		EndIf
		dbSelectArea("SE2")
		dbskip()
	enddo
	//
EndIf
If VVG->(FieldPos("VVG_NUMPED"))>0
	dbSelectArea("VVG")
	dbSetOrder(1)
	dbGotop()
	If dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
		While !EOF() .and. VVG->VVG_FILIAL == VVF->VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA
			cNumPed := VVG->VVG_NUMPED
			cItPed	:= VVG->VVG_ITPED
			if !Empty(cNumPed)
				//verifica se existe o pedido
				dbSelectArea("SC7")
				dbSetOrder(1)
				If dbSeek(xFilial("SC7")+cNumPed+cItPed)
					// Grava os dados na tabela SC7
					RecLock("SC7",.F.)
					//Se o pedido estiver encerrado, reabre o pedido
					If SC7->C7_QUANT == SC7->C7_QUJE
						SC7->C7_ENCER := "" //Reabre o pedido
					EndIf
					//
					If SC7->C7_QUJE > 0
						SC7->C7_QUJE := SC7->C7_QUJE - 1     //Sempre subtraio um pq no VVG cada item eh um registro
					EndIf
					MsUnLock()
				EndIf
			endif
			dbSelectArea("VVG")
			DbSkip()
		Enddo
	EndIf
endif
//
dbSelectArea("VVF")
RecLock("VVF",.f.)
VVF->VVF_SITNFI := "0"
MsUnlock()
//
if cX0OpeMov $ "5/7/8" // DEVOLUCAO/ RETORNO DE REMESSA/ RETORNO DE CONSIGNADO
	// ATUALIZA O STATUS DA NF DE "DEVOLVIDA" PARA "VALIDA"
	DBSelectArea("VV0")
	DBSetOrder(4)
	if DBSeek(xFilial("VV0")+cChaveOri)
		reclock("VV0",.f.)
		VV0->VV0_SITNFI := "1"
		msunlock()
	endif
endif

// ATUALIZA STATUS DE IMOBILIZACAO DO VEICULO
dbSelectArea("VVG")
dbSetOrder(1)
dbGotop()
If dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
	While !EOF() .and. VVG->VVG_FILIAL == VVF->VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA

		nRecSF4 := FM_SQL("SELECT SF4.R_E_C_N_O_ FROM "+RetSqlName("SF4")+" SF4 WHERE  SF4.F4_FILIAL='"+xFilial("SF4")+"' AND  SF4.F4_CODIGO='"+VVG->VVG_CODTES+"' AND SF4.D_E_L_E_T_=' '")
		nRecVV1 := FM_SQL("SELECT VV1.R_E_C_N_O_ FROM "+RetSqlName("VV1")+" VV1 WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHASSI='"+VVG->VVG_CHASSI+"' AND VV1.D_E_L_E_T_=' '")
		SF4->(DbGoTo(nRecSF4))
		VV1->(DbGoTo(nRecVV1))
		If ( Alltrim(SF4->F4_CF) == "1551" .or. SF4->F4_OPEMOV == "07" ) .and. VV1->VV1_IMOBI == "1"
			DbSelectArea("VV1")
			RecLock("VV1",.f.)
			VV1->VV1_IMOBI := "0" // Cancela Imobilização
			MsUnlock()
		Endif

		DbSelectArea("VVG")
		DbSkip()

	Enddo

Endif

// Movimentos gerados por integração com SIGAEIC e SIGAPCP serão deletados da base quando CANCELADOS
If VVF->VVF_TIPDOC $ "3/4"

	dbSelectArea("VVG")
	dbSetOrder(1)
	dbSeek(xFilial("VVG") + VVF->VVF_TRACPA )
	While !EOF() .and. VVG->VVG_FILIAL == VVF->VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA
		RecLock("VVG",.f.)
		VVG->(dbDelete())
		MsUnlock()
		dbSkip()
	End

	dbSelectArea("VVF")
	RecLock("VVF",.f.)
	VVF->(dbDelete())
	MsUnlock()
EndIf

// ###############################################
// # FINAL DA TRANSACAO                          #
// ###############################################
End Transaction
// ###############################################
// # ATUALIZA O STATUS DO VEICULO                #
// ###############################################
For nCntFor = 1 to len(acols)
	n = nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	// ALTERA STATUS DOS VEICULOS
	FGX_AMOVVEI(xFilial("VV1"),aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
	If FindFunction("VXX04REVJ1")
		VXX04REVJ1(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")],"","0")//realiza o cancelamento da reserva do veiculo
	EndIf
Next
//
dbSelectArea("VVF")
//
If lExcluiNF
	if lMostraMsg .and. !lMsErroAuto
		FMX_TELAINF( "1" , { { Alltrim(VVF->VVF_SERNFI) , Alltrim(VVF->VVF_NUMNFI) , STR0067 } } ) // "CANCELADO"
	endif
Else
	MsgInfo(STR0122) // "Movimento cancelado."
EndIf
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000DLIN   | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000DLIN(lValidVV1)
Default lValidVV1 := .t.
If lValidVV1
	If !Empty(aCols[n,FG_POSVAR("VVG_CHAINT")])
		VV1->(DbSetOrder(1))
		If VV1->(DbSeek(xFilial("VV1")+aCols[n,FG_POSVAR("VVG_CHAINT")]))
			If VV1->VV1_GRASEV == "6" // '6' = SEM CHASSI
				Return()
			EndIf
		EndIf
	EndIf
EndIf
//
If aCols[n,Len(aCols[n])]
	aCols[n,Len(aCols[n])] := .f.
Else
	aCols[n,Len(aCols[n])] := .t.
EndIf
//
If lAtuFiscal // Atualiza Fiscal
	MaFisDel(n,aCols[n,Len(aCols[n])])
EndIf
//
VX000FIELDOK()
//
oGetDados:obrowse:SetFocus()
//
Return()
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000KEYF4  | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Chamada da tecla de atalho <F4>. Executa comandos dependen-  |##
##|Descri‡„o | do do campo selecionado ( ReadVar() ).                       |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000KEYF4()
//
If ReadVar() == "M->VVG_CHASSI"
	DBSelectArea("VV1")
	DBSetOrder(2)
	If DBSeek(xFilial("VV1")+M->VVG_CHASSI)
		VXA010A("VV1",RecNo(),3)
	EndIf
EndIf
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000ABORT  | Autor |  Luis Delorme         | Data | 27/01/09 |##
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
Function VX000ABORT()
//
If lAbortPrint
	//"Tem certeza que deseja abortar esta operacao ?", STR0017
	If MsgYesNo(STR0068,STR0017)//Tem certeza que deseja abortar esta operacao ?","Atencao
		Help("  ",1,"M160PROABO")
		DisarmTransaction()
		lMSErroAuto := .t.
		Return .t.
	Else
		lAbortPrint := .F.
	EndIf
EndIf
//
Return .f.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000BRWNOME| Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Browse do Nome do Cliente/Fornecedor - Depependendo do tipo  |##
##|          | de operacao a funcao retorna o cliente ou o fornecedor.      |##
##|          | As operacoes de remessa, consignacao e devolucao tomam o     |##
##|          | cliente ao inves do fornecedor. As demais utilizam o forne-  |##
##|          | cedor (padrao).                                              |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000BRWNOME()
Local cAlias := Alias()
Local nRecSA1 := SA1->(RecNo())
Local nRecSA2 := SA2->(RecNo())
Local cNome
Local cTipoCliVVF := " "
//
if VVF->(FieldPos("VVF_TIPO")) >= 0
	if VVF->VVF_TIPO $ "DB"
		cTipoCliVVF := "C"
	endif
endif
if VVF->(FieldPos("VVF_CLIFOR")) >= 0
	if !Empty(VVF->VVF_CLIFOR)
		If VVF->VVF_CLIFOR == "C"
			DBSelectArea("SA1")
			DBSetOrder(1)
			DBSeek(xFilial("SA1")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
			cNome :=  SA1->A1_NREDUZ
		Else
			DBSelectArea("SA2")
			DBSetOrder(1)
			DBSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
			cNome :=  SA2->A2_NREDUZ
		EndIf
	Else
		cNome	:= ""
	Endif
Else
	If VVF->VVF_OPEMOV $ "245" .or. cTipoCliVVF == "C"
		DBSelectArea("SA1")
		DBSetOrder(1)
		DBSeek(xFilial("SA1")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
		cNome :=  SA1->A1_NREDUZ
	Else
		DBSelectArea("SA2")
		DBSetOrder(1)
		DBSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
		cNome :=  SA2->A2_NREDUZ
	EndIf
Endif
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
##|Fun‡„o    |VX000BRWNOME| Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Browse do Nome do Cliente/Fornecedor - Depependendo do tipo  |##
##|          | de operacao a funcao retorna o cliente ou o fornecedor.      |##
##|          | As operacoes de remessa, consignacao e devolucao tomam o     |##
##|          | cliente ao inves do fornecedor. As demais utilizam o forne-  |##
##|          | cedor (padrao).                                              |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000ATUF1(cCampo)
Local cVar1, cVar2
Local nCntFor
Local cRatDesp := GetMv("MV_RATDESP")
Local cTipo    := "0" // 0=Qtde Default - Rateio por: 1=Valor / 2=Peso
Local nAux     := 0
Local nTot     := 0
Local aTot     := {}
Local cObj     := ""

Default cCampo := "DESPESA"

If cCampo == "DESPESA"
	// DESPESA
	cVar1 := "DESPESA"
	cVar2 := "DESACE"
	cTipo := SubStr(cRatDesp,At("DESP=",cRatDesp)+5,1)
Else
	// FRETE
	cVar1 := "FRETE"
	cVar2 := "TOTFRE"
	cTipo := SubStr(cRatDesp,At("FR=",cRatDesp)+3,1)
	If ValType(oGetE101) == "O" // Existe o Objeto
		cObj  := "oGetE101" // Necessario para refresh na tela - Total Frete
	EndIf
EndIf

If lAtuFiscal .and. MaFisFound('NF') // Atualiza Fiscal

	If ReadVar() == "M->VVG_DESACE" // nao deixa alterar o campo de despesa
		M->VVG_DESACE := aCols[n,FG_POSVAR("VVG_DESACE")]
		MaFisRef("IT_DESPESA","VVG00", M->VVG_DESACE ) // Volta - Não Altera a Despesa, pois ela é calculada novamente no MATA103
	EndIf

	if ReadVar() <> "M->VVG_TOTFRE"

		for nCntFor := 1 to Len(aCols) // Totalizar variaveis para calculo proporcional
			nAux := 0
			// pula itens deletados
			if !aCols[nCntFor,Len(aCols[nCntFor])] .and. !Empty(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
				Do Case
					Case cTipo == "1" // Valor
						nAux := aCols[nCntFor,FG_POSVAR("VVG_VALUNI")]
					Case cTipo == "2" // Peso
						FGX_VV1SB1("CHAINT", aCols[nCntFor,FG_POSVAR("VVG_CHAINT")] , /* cMVMIL0010 */ , cGruVei )
						nAux := SB1->B1_PESBRU
					OtherWise
						nAux := 1
				EndCase
			EndIf
			nTot += nAux
			aAdd(aTot,{nAux,0})
		Next
		For nCntFor := 1 to Len(aTot)
			aTot[nCntFor,2] := (aTot[nCntFor,1]/nTot) // indice para % correspondente
		Next

		If ReadVar() == "M->VVF_TOTFRE"
			nAnt := n
			for nCntFor := 1 to Len(aCols)
				// pula itens deletados
				if !aCols[nCntFor,Len(aCols[nCntFor])] .and. !Empty(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
					n := nCntFor
					MaFisRef("IT_"+cVar1,"VVG00",&("M->VVF_"+cVar2)*aTot[nCntFor,2])
				endif
			next
			n := nAnt
		EndIf

	Else // Recalcula o TOTAL do Frete na cabeca da NF
		&("M->VVF_"+cVar2) := 0
		nTot := &("M->VVG_"+cVar2)
		for nCntFor := 1 to Len(aCols)
			// pula itens deletados
			if n <> nCntFor .and. !aCols[nCntFor,Len(aCols[nCntFor])] .and. !Empty(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
				nTot += aCols[nCntFor,FG_POSVAR("VVG_"+cVar2)]
			EndIf
		next
		&("M->VVF_"+cVar2) := nTot
		If !Empty(cObj)
			&(cObj+":Refresh()") // Necessario para refresh na tela - Total
		EndIf
	EndIf

	If &("M->VVF_"+cVar2) > 0
		MaFisAlt("NF_"+cVar1,&("M->VVF_"+cVar2))
	EndIf
	for nCntFor := 1 to Len(aOrc)
		aOrc[nCntFor,3] := &(aOrc[nCntFor,1])
	next
	If ReadVar() == "M->VVF_TOTFRE"
		for nCntFor := 1 to Len(aCols)
			// pula itens deletados
			if !aCols[nCntFor,Len(aCols[nCntFor])] .and. !Empty(aCols[nCntFor,FG_POSVAR("VVG_CHASSI")])
				&("M->VVG_"+cVar2) := aCols[nCntFor,FG_POSVAR("VVG_"+cVar2)] := MaFisRet(nCntFor,"IT_"+cVar1)
			endif
		next
	Endif
	If !lVX000Auto
		oGetDados:oBrowse:refresh()
		olBox:nAt := 1
		olBox:SetArray(aOrc)
		olBox:bLine := { || { aOrc[olBox:nAt,2],;
			FG_AlinVlrs(Transform(aOrc[olBox:nAt,3],"@E 999,999,999.99")) }}
		olBox:Refresh()
	EndIf
EndIf
return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |  VX000RB1  | Autor |  Luis Delorme         | Data | 12/11/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Funcao para trigeer do tes inteligente (ver sx7)             |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000RB1()
	FGX_VV1SB1("CHAINT", M->VVG_CHAINT , /* cMVMIL0010 */ , /* cGruVei */ )
return SB1->B1_COD

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VXVlChvNfe  | Autor |  Manoel               | Data | 01/08/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Funcao para chamada da a103ConsNfeSef()                      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VXVlChvNfe(cPar01,cPar02)

Local lRet := .f.
Local lSlv103Auto

Private cFormul  := ""
Private cEspecie := ""

If cPar01 == "0" // Formulario Proprio = Nao
	cFormul := "N"
Endif
cEspecie := cPar02 // Especie da NF

//lSlv103Auto	:= IIF(l103Auto==NIL,.f.,l103Auto)
lSlv103Auto	:= IIF(Type("l103Auto")=="U",.f.,l103Auto)
l103Auto := .f.
lRet := a103ConsNfeSef()
l103Auto := lSlv103Auto

Return lRet

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |VX000VLD    | Autor |  Luis Delorme         | Data | 30/01/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Função de Validação para compatibilidade com VM000VLD        |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX000VLD()

If FM_PILHA("VEIVM006")
	// VVF
	if ReadVar() == "M->VVF_CODFOR"
		return FG_Seek("SA2","M->VVF_CODFOR",1,.f.) .and. FS_INIIMP(M->VVF_CODFOR,M->VVF_LOJA)
	endif
	if ReadVar() == "M->VVF_LOJA"
		return FG_Seek("SA2","M->VVF_CODFOR+M->VVF_LOJA",1,.f.,"VVF_NOMFOR","A2_NREDUZ").and.FS_INIIMP(M->VVF_CODFOR,M->VVF_LOJA)
	endif
	if ReadVar() == "M->VVF_FORPAG"
		return Empty(M->VVF_FORPAG).or.FG_Seek("SE4","M->VVF_FORPAG",1,.f.,"VVF_DESFPG","E4_DESCRI") .and. FS_FPGAUTO()
	endif
	if ReadVar() == "M->VVF_TESFRE"
		return FG_Seek("SF4","M->VVF_TESFRE",1,.f.) .and. FMX_TESTIP(M->VVF_TESFRE) == "E"
	end
	if ReadVar() == "M->VVF_VALMOV"
		return Positivo() .and. FG_AtrVal("VVF_VBAICM","M->VVF_VALMOV") .and. FG_AtrVal("VVF_TOTICM","M->VVF_VBAICM*(M->VVF_ALIICM/100)")
	endif
	if ReadVar() == "M->VVF_TOTSEG"
		return Positivo()
	endif
	if ReadVar() == "M->VVF_TOTFRE"
		return Positivo()
	endif
	if ReadVar() == "M->VVF_DESACE"
		return Positivo()
	endif
	if ReadVar() == "M->VVF_VBAIPI"
		return Positivo()
	endif
	if ReadVar() == "M->VVF_ALIIPI"
		return Positivo()
	endif
	if ReadVar() == "M->VVF_VALIPI"
		return Positivo()
	endif
	if ReadVar() == "M->VVF_VBAICM"
		return Positivo() .and. FG_AtrVal("VVF_TOTICM","M->VVF_VBAICM*(M->VVF_ALIICM/100)")
	endif
	if ReadVar() == "M->VVF_ALIICM"
		return Positivo() .and. FG_AtrVal("VVF_TOTICM","M->VVF_VBAICM*(M->VVF_ALIICM/100)")
	endif
	if ReadVar() == "M->VVF_TOTICM"
		return Positivo()
	endif
	if ReadVar() == "M->VVF_ICMRET"
		return Positivo()
	endif
	if ReadVar() == "M->VVF_CODBCO"
		return Vazio() .or. FG_StrZero("M->VVF_CODBCO",3,.f.) .and. FG_Seek("SA6","M->VVF_CODBCO",1,.f.,"VVF_CODAGE","A6_AGENCIA")
	endif
	If ReadVar() == "M->VVF_MOEDA"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVF_TXMOED"
		return Positivo()
	EndIf

	// VVG
	If ReadVar() == "M->VVG_II"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVG_ALIQII"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVG_BASCOF"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVG_ALICOF"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVG_VALCOF"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVG_BASPIS"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVG_ALIPIS"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVG_VALPIS"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVG_BAIMP5"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVG_ALIMP5"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVG_VLIMP5"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVG_BAIMP6"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVG_ALIMP6"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVG_VLIMP6"
		return Positivo()
	EndIf
	If ReadVar() == "M->VVG_CF"
		return FG_Seek("13","M->VVG_CF",1,.f.)
	EndIf
Endif

return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ VX000Help    ºAutor  ³Thiago           º Data ³  20/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Função para exibir os Helps do campo VVF_CHVNFE ao finalizarº±±
±±            o documento de entrada                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³                                               		      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX000Help(cFormul,cEspecie)

Local lDigChv := GetNewPar("MV_DCHVNFE",.F.)
Local lRetorno := .T.
cFormul := Iif(cFormul == "1","S","N")

DbselectArea("SX3")
DbSetOrder(2)

If lDigChv
	If VVF->(FieldPos("VVF_CHVNFE"))>0
		If (cFormul == "N" .and. AllTrim(cEspecie) == "SPED") .or. (cFormul == "N" .and. AllTrim(cEspecie) == "CTE")
			If Empty(M->VVF_CHVNFE)
				Help(" ",1,"DCHVNFE")
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX000CLIFORºAutor  ³Thiago              º Data ³  10/04/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao do campo VVF_CLIFOR.							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 11                                              		      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX000CLIFOR()

If !(FM_PILHA("VEIXA006")) .and. !(FM_PILHA("VEIXA007"))  .and. !(FM_PILHA("VEIXA008")) .and. !(FM_PILHA("VEIXA002")) .and. !(FM_PILHA("VEIXA004")) .and. !(FM_PILHA("VEIXA040")) .and. !(FM_PILHA("VEIVM006"))
	If ReadVar() == "M->VVF_CLIFOR"
		If !Empty(M->VVF_CLIFOR)
			cCliForA := M->VVF_CLIFOR
		Endif
	Endif

	If ! lVX000Auto
		if cCliForA == "C" //cOpeMov $ "35" .and. cCliForA == "C"
			oSayE34:lVisible := .f.
			oSayE21:lVisible := .t.
			oGetE21:cf3 := "SA1"
		Else
			oSayE21:lVisible := .f.
			oSayE34:lVisible := .t.
			oGetE21:cf3 := "SA2"
		Endif
	EndIf
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX000RDVForºAutor  ³Thiago/Manoel         Data ³  12/06/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Força o ReadVar quando chamada pelo IMPXML				  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX000RDVFOR()
Local nCntFor  := 0
Local nCntFor2 := 0

If lImpXML
	// Faz o get Automático do Fornecedor/Loja e Nota Fiscal e Série quando utilizado o IMPXMLV
	__ReadVar := "M->VVF_CODFOR"
	VX000VLDENC()
	__ReadVar := "M->VVF_LOJA"
	VX000VLDENC()
	__ReadVar := "M->VVF_NUMNFI"
	VX000VLDENC()
	__ReadVar := "M->VVF_SERNFI"
	VX000VLDENC()
	__ReadVar := "M->VVF_FORPAG"
	VX000VLDENC()

	Do Case
		Case FM_PILHA("U_IMPXMLV")
			FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			// SETA VARIAVEL FISCAL
			If lAtuFiscal // Atualiza Fiscal
				MaFisRef("IT_PRODUTO","VVG00",SB1->B1_COD)
				MaFisRef("IT_PRCUNI","VVG00",M->VVG_VALUNI)
				MaFisRef("IT_VALMERC","VVG00",M->VVG_VALUNI)
				MaFisRef("IT_TES","VVG00",M->VVG_CODTES)
			EndIf
			// Faz o get Automático dos campos da GetDados quando utilizado o IMPXMLV
			__ReadVar := "M->VVG_CHASSI"
			VX000FIELDOK()
		
		Case FM_PILHA("U_IXMLVJD")

			For nCntFor := 1 to len(aColsV)
				For nCntFor2:=1 to len(aHeaderV)
					&("M->"+aHeaderV[nCntFor2,2]) := aColsV[nCntFor,nCntFor2]
				Next
				VV1->(DbSetOrder(1))
				VV1->(DbSeek(xFilial("VV1")+M->VVG_CHAINT))
				FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
				// SETA VARIAVEL FISCAL
				If lAtuFiscal // Atualiza Fiscal
					n := nCntFor
					MaFisRef("IT_PRODUTO","VVG00",SB1->B1_COD)
					MaFisRef("IT_PRCUNI" ,"VVG00",M->VVG_VALUNI)
					MaFisRef("IT_VALMERC","VVG00",M->VVG_VALUNI)
					MaFisRef("IT_TES"    ,"VVG00",M->VVG_CODTES)
					MaFisRef("IT_BASEICM","VVG00",M->VVG_VBAICM)
					MaFisRef("IT_ALIQICM","VVG00",M->VVG_ALIICM)
					MaFisRef("IT_VALICM" ,"VVG00",M->VVG_ICMCOM)
					MaFisRef("IT_ALIQCOF","VVG00",M->VVG_ALICOF)
					MaFisRef("IT_ALIQPIS","VVG00",M->VVG_ALIPIS)
					MaFisRef("IT_BASEIPI","VVG00",M->VVG_VBAIPI)
					MaFisRef("IT_ALIQIPI","VVG00",M->VVG_ALIIPI)
					MaFisRef("IT_VALIPI" ,"VVG00",M->VVG_VALIPI)
				EndIf
				// Faz o get Automático dos campos da GetDados quando utilizado o IMPXMLV
				__ReadVar := "M->VVG_CHASSI"
				VX000FIELDOK()
			Next
			
	EndCase

Endif

return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX000IAMS rºAutor  ³   Manoel             Data ³  27/06/18  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Insere AMS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX000IAMS()
Local cQuery     := ""
Local cAlVV1     := "SQLVV1"
Local nCntFor    := 0
Local nForX3     := 0
Local aVeicAms   := {}
Local aIntCab    := {}
Local aIntIte    := {}
Local aRet       := {}
Local _aVRetVIS  := {}
Local lOpcDisp   := .f.
Local cTxtAMS    := GetNewPar("MV_MIL0106","AMS") // Nome Padrao: "AMS"
//
// HABILITA DIGITACAO DOS ITENS CASO A ROTINA NAO SEJA AUTOMATICA
If !lVX000Auto .and. !lImpXml
	If lAtuFiscal // Atualiza Fiscal
		If MaFisFound('NF')
			lOpcDisp := .t. // Habilitar opção caso iniciou o Fiscal
		EndIf
	EndIf
EndIf
If !lOpcDisp // Se opção NAO esta disponivel ainda
	If !lVX000Auto .and. !lImpXml
		MsgAlert(STR0103,STR0017) // Favor preencher os Dados da Entrada por Compra. / Atenção
	EndIf
	Return
EndIf
//
aRet := {}
aParamBox := {}
aAdd(aParamBox,{2,cTxtAMS,STR0104,{STR0104,STR0105},70,"",.f.,".t."}) // Existentes / Existentes / Novos
aAdd(aParamBox,{1,RetTitle("VVG_OPER")  ,Space(TamSX3("VVG_OPER")[1]),"@!","Existcpo('SX5','DJ'+MV_Par02)" ,"DJ ","",0,.f.})
//
If !ParamBox(aParamBox,STR0106+" "+cTxtAMS,@aRet,,,,,,,,.f.) // Incluir
	Return
EndIf
M->VVG_OPER := aRet[2]
If aRet[1] == STR0105 // Novos
	//
	aVeicAms := VXA010IAMS()
	If ValType(aVeicAms) == "A"
		If Len(aVeicAms) == 0
			Return
		Endif
	Else
		Return
	Endif
	For nCntFor := 1 to len(aVeicAms)
		aAdd(_aVRetVIS,{ .t. , aVeicAms[nCntFor,1] , aVeicAms[nCntFor,2] ,aVeicAms[nCntFor,3] , aVeicAms[nCntFor,4] })
	Next
	//
Else
	//
	cQuery := "SELECT VV1_CHAINT, VV1_CHASSI , VV1_CODMAR , VV1_MODVEI "
	cQuery += "FROM "+RetSqlName("VV1")+" "
	cQuery += "WHERE VV1_FILIAL = '"+xFilial("VV1")+"' AND "
	cQuery += "VV1_GRASEV = '6' AND "
	cQuery += "VV1_FILENT = ' ' AND "
	cQuery += "D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY VV1_CHASSI"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlVV1, .F., .T. )
	While !( cAlVV1 )->( Eof() )
		aAdd(aIntIte,{ ( cAlVV1 )->( VV1_CHAINT ) , ( cAlVV1 )->( VV1_CHASSI ) , ( cAlVV1 )->( VV1_CODMAR )  , ( cAlVV1 )->( VV1_MODVEI ) })
		( cAlVV1 )->( DBSkip() )
	EndDo
	( cAlVV1 )->( dbCloseArea() )
	DbSelectArea("VV1")
	//
	aAdd(aIntCab,{ RetTitle("VV1_CHAINT"), "C" ,  40 , "@!" })
	aAdd(aIntCab,{ RetTitle("VV1_CHASSI"), "C" ,  80 , "@!" })
	aAdd(aIntCab,{ RetTitle("VV1_CODMAR"), "C" ,  25 , "@!" })
	aAdd(aIntCab,{ RetTitle("VV1_MODVEI"), "C" , 150 , "@!" })
	//
	FGX_VISINT( cCadastro , cTxtAMS+" - "+aRet[1] , aIntCab , aIntIte , .t., @_aVRetVIS ) //
	//
EndIf
//
For nCntFor := 1 to Len(_aVRetVIS)
	//
	If _aVRetVIS[nCntFor,1] .and. ascan(aCols,{|x| x[FG_POSVAR("VVG_CHAINT")] == _aVRetVIS[nCntFor,2] }) == 0 // CHAINT NAO DIGITADO
		//
		DbSelectArea("VV1")
		DbSetOrder(1)
		If DbSeek(xFilial("VV1")+_aVRetVIS[nCntFor,2])
			VV1->(DbSetOrder(2))
			//
			If !Empty(aCols[len(aCols),FG_POSVAR("VVG_CHAINT")])
				aAdd(aCols,Array(nUsadoV+1))
			EndIf
			n := nLin := Len(aCols)
			aCols[nLin,nUsadoV+1] := .F.
			//
			DBSelectArea("SB1")
			FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			DBSetOrder(1)
			cTESEnt := SB1->B1_TE
			For nForX3 := 1 to nUsadoV
				aCols[nLin,nForX3] := CriaVar(aHeaderV[nForX3,2])
			Next
			//
			aCols[nLin,FG_POSVAR("VVG_CHASSI","aHeaderV")] := M->VVG_CHASSI := VV1->VV1_CHASSI
			aCols[nLin,FG_POSVAR("VVG_CHAINT","aHeaderV")] := M->VVG_CHAINT := VV1->VV1_CHAINT
			aCols[nLin,FG_POSVAR("VVG_ESTVEI","aHeaderV")] := M->VVG_ESTVEI := VV1->VV1_ESTVEI
			aCols[nLin,FG_POSVAR("VVG_OPER"  ,"aHeaderV")] := M->VVG_OPER   := aRet[2]
			aCols[nLin,FG_POSVAR("VVG_LOCPAD","aHeaderV")] := M->VVG_LOCPAD := VV1->VV1_LOCPAD
			aCols[nLin,FG_POSVAR("VVG_CODORI","aHeaderV")] := M->VVG_CODORI := VV1->VV1_CODORI
			aCols[nLin,FG_POSVAR("VVG_SITTRI","aHeaderV")] := M->VVG_SITTRI := IIF(VV1->VV1_PROVEI=="1","0","1")
			aCols[nLin,FG_POSVAR("VVG_VALUNI","aHeaderV")] := M->VVG_VALUNI := VV1->VV1_SUGVDA
			//
			MaFisRef("IT_PRODUTO","VVG00",SB1->B1_COD)
			MaFisRef("IT_PRCUNI","VVG00",M->VVG_VALUNI)
			MaFisRef("IT_VALMERC","VVG00",M->VVG_VALUNI)
			//
			__ReadVar := "M->VVG_OPER"
			VX000FIELDOK()
			If Empty(aRet[2])
				aCols[nLin,FG_POSVAR("VVG_CODTES","aHeaderV")] := M->VVG_CODTES := cTESEnt
			EndIf
			MaFisRef("IT_TES","VVG00",M->VVG_CODTES)
			//
			__ReadVar := "M->VVG_CHASSI"
			VX000FIELDOK()
			//
		Endif
		//
	Endif
	//
Next
//
oGetDados:oBrowse:Refresh()
//
Return



Function VX000POSVVF(aAutoCab)
	Local nRecRet := 0

	nPosNUMTRA := aScan(aAutoCab, { |x| x[1] == "VVF_NUMTRA"})
	If nPosNUMTRA <> 0
		VVF->(dbSetOrder(1))
		If !VVF->(dbSeek(xFilial("VVF") + aAutoCab[nPosNUMTRA,2]))
			FMX_HELP("REGNOIS",STR0123) // "Movimento de entrada não encontrado."
			Return nRecRet
		EndIf
		Return VVF->(Recno())
	EndIf

	nPosNUMNFI := aScan(aAutoCab, { |x| x[1] == "VVF_NUMNFI" })
	If nPosNUMNFI <> 0
		nPosSERNFI := aScan(aAutoCab, { |x| x[1] == "VVF_SERNFI" })
		nPosCODFOR := aScan(aAutoCab, { |x| x[1] == "VVF_CODFOR" })
		nPosLOJA   := aScan(aAutoCab, { |x| x[1] == "VVF_LOJA"   })

		cSQL := " FROM " + RetSQLName("VVF") + " VVF " +;
				" WHERE VVF.VVF_FILIAL = '" + xFilial("VVF") + "'" +;
					" AND VVF.VVF_CODFOR = '" + aAutoCab[ nPosCODFOR , 2 ] + "'" +;
					" AND VVF.VVF_LOJA   = '" + aAutoCab[ nPosLOJA   , 2 ] + "'" +;
					" AND VVF.VVF_NUMNFI = '" + aAutoCab[ nPosNUMNFI , 2 ] + "'" +;
					" AND VVF.VVF_SERNFI = '" + aAutoCab[ nPosSERNFI , 2 ] + "'" +;
					" AND VVF.D_E_L_E_T_ = ' '"
		nRecRet := FM_SQL("SELECT R_E_C_N_O_ VVFRECNO " + cSQL + " AND VVF.VVF_SITNFI = '1' ")
		If nRecRet <> 0
			Return nRecRet
		EndIf

		If FM_SQL("SELECT COUNT(*) " + cSQL + " AND VVF.VVF_SITNFI <> '1' ") > 0
			FMX_HELP("VEIX000E13",STR0124) // "Nota fiscal não está válida para permitir o cancelamento do movimento de entrada."
			Return nRecRet
		Endif

		If FM_SQL("SELECT COUNT(*) " + cSQL) == 0
			FMX_HELP("REGNOIS",STR0125) // "Nota Fiscal não encontrada na tabela de Movimento de Entrada de Veículos."
			Return nRecRet
		EndIf
	EndIf

	
	nPosNUMOP := aScan(aAutoCab, { |x| x[1] == "VVF_NUMOP" })
	If nPosNUMOP <> 0

		cSQL := " FROM " + RetSQLName("VVF") + " VVF " +;
				" WHERE VVF.VVF_FILIAL = '" + xFilial("VVF") + "'" +;
					" AND VVF.VVF_NUMOP = '" + aAutoCab[ nPosNUMOP , 2 ] + "'" +;
					" AND VVF.D_E_L_E_T_ = ' ' "

		nRecRet := FM_SQL("SELECT R_E_C_N_O_ VVFRECNO " + cSQL + " AND VVF.VVF_SITNFI = '1' ")
		If nRecRet <> 0
			Return nRecRet
		EndIf

		If FM_SQL("SELECT COUNT(*) " + cSQL + " AND VVF.VVF_SITNFI <> '1' ") > 0
			FMX_HELP("VEIX000E17",STR0126) // "Movimento de produção não está válido para permitir o cancelamento do movimento de entrada."
			Return nRecRet
		Endif

		If FM_SQL("SELECT COUNT(*) " + cSQL) == 0
			FMX_HELP("REGNOIS",STR0127) // "Movimento de produção não encontrado na tabela de Movimento de Entrada de Veículos."
			Return nRecRet
		EndIf
	EndIf

	FMX_HELP("VEIX000E12",STR0128, STR0129 ) // "Movimento de entrada não pode ser encontrado.","Modifique a chave de pesquisa."

Return nRecRet
/*/{Protheus.doc} VX0000016_LoadMoeda
Atualiza Taxa da Moeda
@author Fernando Vitor Cavani
@since 24/10/2018
@version undefined
@type function
/*/
Static Function VX0000016_LoadMoeda()
nMoedaCor  := VVF->VVF_MOEDA
nTaxaMoeda := VVF->VVF_TXMOED
Return

/*/{Protheus.doc} VX0000026_AtualizaTaxa
Atualiza Taxa da Moeda
@author Fernando Vitor Cavani
@since 24/10/2018
@version undefined
@param oMoeda    , objeto, Moeda
@param oTaxaMoeda, objeto, Taxa Moeda
@param oSayMoeda , objeto, Descrição Moeda
@type function
/*/
Static Function VX0000026_AtualizaTaxa(oMoeda, oTaxaMoeda, oSayMoeda)
Local cMoeda := ""
Local cCampo := ReadVar()

cMoeda := SuperGetMv("MV_MOEDA" + AllTrim(Str(nMoedaCor, 2)))

If nMoedaCor <> 1
	If !"NTAXA" $ Upper(cCampo)
		If nTaxaMoeda <> 0
			MaFisAlt("NF_TXMOEDA", nTaxaMoeda)
		EndIf

		If nTaxaMoeda == 0
			nTaxaMoeda := MaFisRet(, "NF_TXMOEDA")
		EndIf

		If nTaxaMoeda == 0
			nTaxaMoeda := xMoeda(1, nMoedaCor, MaFisRet(, "NF_MOEDA"), M->VVF_DATEMI, TamSx3("VVF_TXMOED")[2])
			MaFisAlt("NF_TXMOEDA", nTaxaMoeda)
		EndIf

		If ("NMOEDA"$Upper(cCampo))
			nTaxaMoeda := RecMoeda(M->VVF_DATEMI, nMoedaCor)
			MaFisAlt("NF_TXMOEDA", nTaxaMoeda)
		EndIf
	Else
		MaFisAlt("NF_TXMOEDA", nTaxaMoeda)
	EndIf
Else
	nTaxaMoeda := 0
	MaFisAlt("NF_TXMOEDA", nTaxaMoeda)
EndIf

// Atualizar Como Pagar
VX000ATUCP()

If oMoeda <> Nil
	oMoeda:Refresh()
EndIf

If oTaxaMoeda <> Nil
	oTaxaMoeda:lReadOnly := IIF((INCLUI .Or. ALTERA) .And. nMoedaCor <> 1, .f., .t.)
	oTaxaMoeda:Refresh()
EndIf

If oSayMoeda <> Nil
	If nMoedaCor == 1
		cMoeda := RetTitle("VVF_MOEDA")
	EndIf
	oSayMoeda:SetText(cMoeda)
EndIf
Return

/*/{Protheus.doc} VX0000036_AtualizaValorPelaMoedaETaxaMoeda
Atualiza Valor caso houve mudança da Moeda e Taxa da Moeda
@author Fernando Vitor Cavani
@since 28/12/2018
@version undefined
@return nValor, numérico, Valor Total
@type function
/*/
Static Function VX0000036_AtualizaValorPelaMoedaETaxaMoeda()
Local nValor := MaFisRet(,"NF_BASEDUP")

If nValor > 0 .And. lMoeda
	If nMoedaCor <> 1 .And. nTaxaMoeda > 0
		nValor := Round(xMoeda(nValor, MaFisRet(,"NF_MOEDA"), nMoedaCor, VVF->VVF_DATEMI, Nil, Nil, nTaxaMoeda), 2)
	EndIf
EndIf
Return nValor

/*/{Protheus.doc} VX0000041_CarregaDefaultCamposCustomizadosParcelas
SOMENTE para ENTRADA POR COMPRA - Carrega Valor Default dos Campos Customizados das Parcelas aIteParc
@author Andre Luis Almeida
@since 03/06/2019
@version undefined
@type function
/*/
Static Function VX0000041_CarregaDefaultCamposCustomizadosParcelas(nLinha)
Local nCntFor  := 0
Default nLinha := 1
If (FM_PILHA("VEIXA001")) // Somente Entrada de Veiculos por Compra
	For nCntFor := 1 to len(aParcCust)
		aAdd(aIteParc[nLinha,3],aParcCust[nCntFor,6])
	Next
EndIf
Return
